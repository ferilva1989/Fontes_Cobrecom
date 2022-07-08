#INCLUDE "TOTVS.CH"
#include "tbiconn.ch"

#define CRLF Chr(13)+Chr(10)

User Function verMoedas()//U_VERMOEDAS()
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"
	dbselectarea("SM2")
	SM2->(dbSetOrder(1))
	u_zxCtrDLm()
	SM2->(dbcloseArea())
	Reset Environment
return(nil)


user function zxCtrDLm(cMeslme)
	local aDolar  as array
	local aCobre  as array
	local bErro   as object
	default cMeslme := cValToChar(MONTH(DATE())) + '-' + cValToChar(YEAR(DATE()))

	bErro		:= ErrorBlock({|oErr| HandleEr(oErr)})
	BEGIN SEQUENCE
		aCobre  	:= jsToArr(u_xzDlrLme('cobre',cMeslme),cMeslme,'cobre')
		aDolar  	:= dolarBc(aCobre, cMeslme, 'dolar')
		if !empty(aDolar) .and. !empty(aCobre)
			Begin Transaction
				save(aDolar)
				save(aCobre)
				sendEml()
			End Transaction
		endif
		RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
return(nil)


/*
	https://shockmetais.com.br/lme/graflme
	POST:      (Query Parameters)
	indice:    (dolar/cobre)
	meslme:    (5-2020) mes/ano
	tipograf:  diario/mensal
*/
user function xzDlrLme(cIndice, cMeslme, cGraf)
	local oRestClient as object
	local aHeadOut    as array
	local cPostParms  as character
	local nX          as numeric
	local oJs		  as object

	default cIndice := 'cobre'
	default cMeslme := cValToChar(MONTH(DATE())) + '-' + cValToChar(YEAR(DATE()))
	default cGraf   := 'diario'

	// Preparar Header e QueryParams
	aHeadOut   := {}
	aadd(aHeadOut,'Content-Type: multipart/form-data; boundary=----WebKitFormBoundaryFbmu0bODj7UvfQEV')
	aDados := {{'indice', cIndice}, {'meslme', cMeslme}, {'tipograf', cGraf}}
	cPostParms := ''
	for nX := 1 to len(aDados)
		cPostParms += '------WebKitFormBoundaryFbmu0bODj7UvfQEV'
		cPostParms += CRLF
		cPostParms += 'Content-Disposition: form-data; name="' + aDados[nX,1] + '"'
		cPostParms += CRLF
		cPostParms += CRLF
		cPostParms += aDados[nX,2]
		cPostParms += CRLF
	next nX
	oJs 		:= JsonObject():New()
	oRestClient := FWRest():New(GetNewPar('ZZ_SCKMURL', 'https://shockmetais.com.br'))
	oRestClient:SetPath(GetNewPar('ZZ_SCKPATH','/lme/graflme'))
	oRestClient:SetPostParams(cPostParms)
	if oRestClient:Post(aHeadOut)
		oJs:FromJson(oRestClient:GetResult())
	else
		msgShow(oRestClient:GetLastError())
	endif
	FreeObj(oRestClient)
return(oJs)


static function msgShow(cTxt)
	if isBlind()
		conout('[ERRO]-MOEDAS ' + cTxt)
	else
		MsgInfo(cTxt)
	endif
return(nil)


static function jsToArr(oJs, cMeslme, cIndice)
	local aRet    as array
	local nX      as numeric
	local nCot    as numeric
	local cDtMd   as character
	aRet := {}
	for nX := 1 to len(oJs['labels'])
		cDtMd := oJs['labels'][nX]
		nCot  := oJs['datasets'][1]['data'][nX]
		aadd(aRet,{cIndice, (cValToChar(cDtMd) + '-' + cMeslme), nCot})
	next nX
return(aRet)


static function save(aSalve)
	local cData as character
	local lUpd  as logic
	local nX    as numeric
	for nX := 1 to len(aSalve)
		cData :=  DtoS(CtoD(aSalve[nX,2]))
		lUpd := SM2->(DbSeek(cData + Space((TamSX3("M2_DATA")[1] - Len(cData)))))
		if reclock("SM2", !lUpd)
			SM2->(M2_DATA) 		:= STOD(cData)
			if aSalve[nX,1] == 'dolar'
				SM2->(M2_MOEDA2) := aSalve[nX,3]
			elseif aSalve[nX,1] == 'cobre'
				SM2->(M2_MOEDA4) 	:= aSalve[nX,3]
			endif
			SM2->(M2_INFORM)	:= "S"
			SM2->(msunlock())
		endif
	next nX
return(nil)


static function HandleEr(oErr)
	local cMsg as character
	if InTransact()
		DisarmTransaction()
	endif
	cMsg	:= "[Moedas - "+DtoC(Date())+" - "+Time()+" ] "+ '[ERRO]' + oErr:Description + ' [FROM] ' + ProcName(3)
	msgShow(cMsg)
	BREAK
return(nil)


static function sendEml()
	local aHead1		:= {}
	local aContent1	:= {}
	local aTmpCont	:= {}
	local oSql		:= nil
	local cQry		:= ''

	aadd(aHead1,"DATA")
	aadd(aHead1,"L.M.E (US$/TON)")
	aadd(aHead1,"DÓLAR (R$/US$)*")
	aadd(aHead1,"EURO (R$/" + chr(128) + ")*")

	oSql 		:= LibSqlObj():newLibSqlObj()
	cQry += " SELECT TOP 5 "
	cQry += " SM2.M2_DATA		AS DT,	"
	cQry += " SM2.M2_MOEDA2	AS DOLAR, "
	cQry += " SM2.M2_MOEDA3	AS EURO, "
	cQry += " SM2.M2_MOEDA4	AS LME	"
	cQry += " FROM %SM2.SQLNAME%	"
	cQry += " WHERE	"
	cQry += " ( SM2.M2_MOEDA2 <> 0 AND SM2.M2_MOEDA3 <> 0 AND SM2.M2_MOEDA4 <> 0) "
	cQry += " AND %SM2.NOTDEL%	"
	cQry += " ORDER BY SM2.M2_DATA DESC "

	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			aTmpCont := {}
			aadd(aTmpCont, dtoc( stod(oSql:getValue("DT"))) )
			aadd(aTmpCont, cValToChar(oSql:getValue("LME")) )
			aadd(aTmpCont, cValToChar(oSql:getValue("DOLAR")) )
			aadd(aTmpCont, cValToChar(oSql:getValue("EURO")) )
			aadd(aContent1,aTmpCont)
			oSql:skip()
		enddo
	endif
	oSql:close()
	FreeObj(oSql)

	Aadd(aContent1,{"","","",""})
	u_envMail({"wf_moedas@cobrecom.com.br"} , "[INFORMATIVO] - Cotação de Moedas - (L.M.E / DÓLAR / EURO)", aHead1, aContent1,,,,'VERMOEDAS')
return(nil)


static function dolarBc(aCobre, cMeslme, cIndice)
	local aDolar   as array
	local dMinData as date
	local dMaxData as date
	local cUrl     as character
	local cretJs   as character
	local oJs      as object
	local nX       as numeric
    local aHeader  as array

	dMinData := DaySub(CtoD(aCobre[1][2]),3)
	dMaxData := CtoD(aCobre[len(aCobre)][2])
	aHeader  := {}
	aDolar   := {}

	cUrl     := "CotacaoDolarPeriodo(dataInicial=@dataInicial,dataFinalCotacao="
	cUrl     += "@dataFinalCotacao)"
	cUrl     += "?@dataInicial='"
	cUrl     += StrZero(Month(dMinData),2) + "-" + StrZero(Day(dMinData),2) + "-" + cValToChar(Year(dMinData))
	cUrl     += "'&@dataFinalCotacao='"
	cUrl     += StrZero(Month(dMaxData),2) + "-" + StrZero(Day(dMaxData),2) + "-" + cValToChar(Year(dMaxData))
	cUrl     += "'&$top=100&$format=json&$select=cotacaoVenda,dataHoraCotacao"

	aAdd(aHeader,"Accept-Encoding: UTF-8")
	aAdd(aHeader,"Content-Type: application/json")
	oRst := FWRest():New("https://olinda.bcb.gov.br/olinda/servico/PTAX/versao/v1/odata/")
	oRst:setPath(cUrl)
	if oRst:Post(aHeader)
		if !empty(cretJs   := oRst:GetResult())
			oJs 	 := JsonObject():New()
			oJs:FromJson(cretJs)
			for nX := 1 to len(aCobre)
				aadd(aDolar,{cIndice, (aCobre[nX][2]), schBack(aCobre[nX][2], oJs['value'])})
			next nX
			FreeObj(oJs)
		endif
	else
		MsgShow(oRst:getLastError() + '-'+ oRst:getResult())
	endif
	FreeObj(oRst)
return(aDolar)



user function zxHisBs()
	local cAnoDe  as character
	local cAnoAte as character
	local nX      as numeric
	local cBusca  as character
	cAnoDe  := '2019'
	cAnoAte := '2020'
	while cAnoDe <= cAnoAte
		for nX := 1 to 12
			cBusca := (StrZero(nX, 2) + '-' + cAnoDe )
			msgInfo(cBusca, 'busca')
			u_zxCtrDLm(cBusca)
		next nX
		cAnoDe := soma1(cAnoDe)
	enddo
return(nil)


static function schBack(cDtCobre, aDlr)
	local nPos    as numeric
	local nVlRet  as numeric
	local nCt     as numeric
	cDtCobre := cToD(cDtCobre)
	nPos     := 0
	nVlRet   := 0
	nCt      := len(aDlr)
	while nPos == 0 .and. (nCt > 0)
		cDtCobre := DaySub(cDtCobre,1)
		nPos := Ascan(aDlr, {|oDl| (toDate(oDl['dataHoraCotacao']) == cDtCobre ) })
		nCt -= 1
	enddo
	if nPos > 0
		nVlRet := aDlr[nPos]['cotacaoVenda']
	endif
return (nVlRet)


static function toDate(cVl)
return StoD(StrTran(StrToKArr(cVl, ' ')[1],'-',''))
