#include 'protheus.ch'
#include 'parmtype.ch'
#include "totvs.ch"
#include "cbcContabil.ch"

#define CLRF chr(13)

/*/{Protheus.doc} cbcImpContFolha
//TODO Descrição auto-gerada.
@author juliana.leme
@since 01/08/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function cbcImpContFolha()
	local lRet			:= .F.
	local aParamBox		:= {}, aRet		:= {}
	private dDataBaseAtual	:= dDataBase
	private aDadosCTB	:= {}
	private nContag		:= 0
	private oSay		:= nil
	
	aAdd(aParamBox,{1,'Data Contabiliz: '  	,Date(),PesqPict('CT2','CT2_DATA'),"","",".T.",50,.T.})
	if ParamBox(aParamBox,"Data da Contabilização",@aRet)
		dDataBase := aRet[1]
		FWMsgRun(, { |oSay| lRet := ContabilizaGPE(oSay)}, "Contabilização Folha de Pagto", "Processando a contabilizacao ... Aguarde ...")
	else
		MsgAlert("Processo Cancelado!!")
	endif
	if lRet
		MsgInfo("Processo Concluido!!")
	else
		MsgAlert("Processo com erro, contabilização não efetuada")
	endif
	dDataBase := dDataBaseAtual
return

static function ContabilizaGPE(oSay)
	local cLote		:= "008890" //gpe
	local cArquivo	:= ""
	local cLancPadrao := "Z01"
	local lLancOk	:= .T., lPadrao := .F.
	local nTotal	:= 0
	local nHdlPrv	:= 0
	local cProcess	:= ProcName()
	default oSay	:= nil
	
	DbSelectArea("CT5")
	DbSelectArea("CT2")
	if !VerPadrao(cLancPadrao)
		MsgAlert("Erro no LP " + cLancPadrao + ", Favor verificar!")
		Help(" ",,1,"NOLANCPADRAO")
		return(.F.)
	endif
	if VldLoteContab()
		MsgAlert("Ja existe contabilização desta filial e deste periodo." + CLRF +;
					"Exclua o lote referente a esta contabilização e refaça o processo!")
		return(.F.)
	endif
	aDadosCTB := RetDadGPE()
	if len(aDadosCTB) <= 0
		MsgAlert("Não há dados a serem contabilizados, reveja os parametros!")
		return(.F.)
	endif
	begin transaction
		nHdlPrv 	:= HeadProva(cLote,cProcess,SubStr(cUsuario,7,6),@cArquivo)
		if nHdlPrv <= 0
			Help(" ",,1,"A100NOPRV")
			DisarmTransaction()
			return(.F.)
		endif
		oSay:CtrlRefresh()
		oSay:SetText("Contabilizando ... Registro : 1 de "+ Alltrim(Str(len(aDadosCTB))))
		oSay:CtrlRefresh()
		for nContag := 1 to len(aDadosCTB)
			nTotal += DetProva(nHdlPrv,cLancPadrao,cProcess,cLote)
			oSay:CtrlRefresh()
			oSay:SetText("Contabilizando ... Registro : " + Alltrim(Str(nContag)) +;
			 				" de "+ Alltrim(Str(len(aDadosCTB))))
			oSay:CtrlRefresh()
		next
		if nTotal > 0
			RodaProva(nHdlPrv,nTotal)
			lLancOk := cA100Incl(cArquivo,nHdlPrv,3,cLote,.T.,.F.)
			if !lLancOK
				DisarmTransaction()
				return(lLancOk)
			endif
		endif
	end transaction
	CT5->(DbCloseArea())
	CT2->(DbCloseArea())
return(lLancOk)

static function GetInfGPE(nCampoCons)
	local cReturn 	:= ""
	default nCampoCons 	:= 0
	if nCampoCons > 0
		cReturn := aDadosCTB[nContag][nCampoCons]
	endif
return(cReturn)

static function RetDadGPE()
	local cQry		:= ""
	local aDadosTmp	:= {}
	private oDadGPE	:= LibSqlObj():newLibSqlObj()
	
	cQry := " SELECT "
	cQry += " 	CT2_DEBITO 	DEBITO, "
	cQry += " 	CT2_CREDIT 	CREDITO, "
	cQry += " 	CT2_CCD 	CCDEBITO, "
	cQry += " 	CT2_CCC 	CCCREDITO, " 
	cQry += " 	CT2_HIST 	HISTORICO, "
	cQry += " 	CT2_VALOR 	VALOR, "
	cQry += " 	CT2_ORIGEM 	ORIGEM "
	cQry += " FROM %CT2.SQLNAME% WITH (NOLOCK) "
	cQry += " WHERE CT2_FILIAL = '' "
	cQry += " 	AND CT2_LOTE = '008890' "
	cQry += " 	AND CT2_DATA = '" + DtoS(dDataBase) + "' "
	cQry += " 	AND CT2_FILORI = '" + FwFilial() + "' "
	cQry += " 	AND %CT2.NOTDEL% "
	cQry += " 	ORDER BY R_E_C_N_O_ "

	if oDadGPE:setExternalConnection("MSSQL","IFC_P12_RH","192.168.3.9",7890)
		oDadGPE:newAlias(cQry)
		if oDadGPE:hasRecords()
			oDadGPE:goTop()
			do while oDadGPE:notIsEof()
				aadd(aDadosTmp, {oDadGPE:getValue("DEBITO"),;
								oDadGPE:getValue("CREDITO"),;
								oDadGPE:getValue("CCDEBITO"),;
								oDadGPE:getValue("CCCREDITO"),;
								oDadGPE:getValue("HISTORICO"),;
								oDadGPE:getValue("VALOR"),;
								oDadGPE:getValue("ORIGEM")})
				oDadGPE:skip()
			enddo
		endif
	endif	
	oDadGPE:close()
	FreeObj(oDadGPE)
return(aDadosTmp)

static function VldLoteContab()
	local cQry		:= ""
	local lRetorno	:= .F.
	private oSql	:= LibSqlObj():newLibSqlObj()

	cQry := " SELECT "
	cQry += " 	COUNT(CT2_LOTE) REGISTROS  "
	cQry += " FROM %CT2.SQLNAME% WITH (NOLOCK) "
	cQry += " WHERE CT2_FILIAL = '" + FwFilial() + "' "
	cQry += " 	AND CT2_LOTE = '008890' "
	cQry += " 	AND CT2_DATA = '" + DtoS(dDataBase) + "' "
	cQry += " 	AND %CT2.NOTDEL% "
	
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		if oSql:getValue("REGISTROS") > 0
			lRetorno := .T.
		endif
	endif
	oSql:close()
	FreeObj(oSql)
return(lRetorno)