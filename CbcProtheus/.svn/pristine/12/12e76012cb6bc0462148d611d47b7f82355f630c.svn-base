#include 'totvs.ch'
#include "Fileio.ch"
#include "rwmake.ch"
#include "rwmake.ch"

class cbcXmlCte
	data lOk
	data cMsgErro	
	data cCNPJ
	data cBranch
	data cNsuMaxx
	data cUf
	data oCfg
	
	method newcbcXmlCte() constructor
	method getMaxNsu()
	method setMaxNsu()
	method getUltNsu()
	method setUltNsu()
	method keepWalk()
	method isOk()
	method setStatus()
	method getErr()
	method defFil()
	method seqSearch()
	method getFromNSU()
endclass

method newcbcXmlCte() class cbcXmlCte
	::setStatus()
	::defFil()
return(self)

method getMaxNsu() class cbcXmlCte
return(::oCfg:cNSUMax)

method setMaxNsu(cNsu) class cbcXmlCte
	default cNsu := ''
	::oCfg:cNSUMax 	:= cNsu
	::cNsuMaxx		:= cNsu
return(self)

method getUltNsu() class cbcXmlCte
	::cNsuMaxx		:= ::oCfg:cNSUAtual
return(::oCfg:cNSUAtual)

method setUltNsu(cNsu) class cbcXmlCte
	default cNsu := ''
	::oCfg:cNSUAtual 	:= cNSU
	::cNsuMaxx			:= cNSU
	::oCfg:AtualizNSU()
return(self)

method keepWalk() class cbcXmlCte
	local lRet := ((::getUltNsu() <= ::getMaxNsu()) .and. ::isOk())
return(lRet)

method isOk() class cbcXmlCte
return(::lOk)

method setStatus(lSts, cMsg) class cbcXmlCte
	default lSts := .T.
	if !(::lOk := lSts)
		::cMsgErro := '[cbcXmlCte]- '  + cMsg
		::oCfg:lLastSts 	:= lSts
		::oCfg:cLastStsMsg 	:= cMsg
		::oCfg:cLastStsMsg 	:= cMsg
		::oCfg:cNSUAtual	:= ::cNsuMaxx
		::oCfg:cNSUMax		:= ::cNsuMaxx
		::oCfg:release()
		ConsoleLog(cMsg)
	endif
return(self)

method getErr() class cbcXmlCte
return(::cMsgErro)

method defFil(cBranch) class cbcXmlCte
	default cBranch := Alltrim(FwFilial())
	::cBranch := cBranch
	SM0->(DbGoTop())
	SM0->(DbSeek("01"+cBranch))
	::cCNPJ 	:= SM0->M0_CGC
	::cUf 		:= SM0->M0_ESTCOB
return(nil)

method seqSearch() class cbcXmlCte
	local bErro	:= nil
	bErro		:= ErrorBlock({|oErr| HandleEr(oErr, self)})
	BEGIN SEQUENCE
		while ::keepWalk()
			::getFromNSU(::getUltNsu())
		enddo
	RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
return(self)

method getFromNSU(cNsu) class cbcXmlCte
	local oWSCTE		:= nil
	local cXmlCabMsg 	:= ''
	local cXmlBody		:= ''
	local cAmbiente		:= ::oCfg:cAmbCte
	local cVersaoCte	:= ::oCfg:cVerCte
	local cUrlWs		:= 'https://www1.cte.fazenda.gov.br/CTeDistribuicaoDFe/CTeDistribuicaoDFe.asmx'
	//'https://www1.cte.fazenda.gov.br/CTeDistribuicaoDFe/CTeDistribuicaoDFe.asmx'
	local cUfCode		:= ''
	local oRet			:= nil
	local aAux			:= {}
	default cNsu 		:= ''
	
	if !empty(cNsu) .and. ::isOk()
		cUfCode 	:= GetUFCode(::cUf)
		oWSCTE 		:= cbcWSDistribuicaoDFe():New()
		// URL_WS
		oWSCTE:_URL := cUrlWs
		// HEADER
		cXmlCabMsg 	+= '<cteCabecMsg xmlns="http://www.portalfiscal.inf.br/cte">'
		cXmlCabMsg 	+= "<cUF>"+ cUfCode +"</cUF>"
		cXmlCabMsg 	+= "<versaoDados>" + cVersaoCte + "</versaoDados>"
		cXmlCabMsg 	+= "</cteCabecMsg>"
		oWSCte:ccteCabecMsg := cXmlCabMsg
		// BODY
		cXmlBody += " <distDFeInt xmlns='http://www.portalfiscal.inf.br/cte' versao='" + cVersaoCte + "'>"
		cXmlBody += "  <tpAmb>" + cAmbiente + "</tpAmb>"
		cXmlBody += "  <cUFAutor>" + cUfCode + "</cUFAutor>"
		cXmlBody += "  <CNPJ>" + ::cCNPJ + "</CNPJ>"
		cXmlBody += "  <distNSU><ultNSU>" + cNsu + "</ultNSU></distNSU>"
		cXmlBody += "</distDFeInt>"
		// REQ
		oWSCte:cteDistDFeInteresse(cXmlBody)
		oRet := oWSCTE:oWScteDistDFeInteresseResult:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT
		
		// 137=Nenhum documento 138=Localizado
		if oRet == nil
			::setStatus(.F., "Nenhum retorno Obtido pelo Governo")
		elseif oRet:_CSTAT:TEXT == '137'
			::setStatus(.F., oRet:_XMOTIVO:TEXT)
			// Nenhum documento encontrado
		elseif oRet:_CSTAT:TEXT == '138'
			// Ultimo NSU base receita
			::setMaxNsu(oRet:_MAXNSU:TEXT)
			// Lote de documentos retornados maximo 50 por consulta
			if ValType(oRet:_LOTEDISTDFEINT:_DOCZIP) == 'O'
				aAux := {oRet:_LOTEDISTDFEINT:_DOCZIP}
			else
				aAux := oRet:_LOTEDISTDFEINT:_DOCZIP
			endif
			prepLoteZip(aAux, self )
		else
			::setStatus(.F., "Cod. Erro: " + oRet:_CSTAT:TEXT + " Motivo: " + oRet:_XMOTIVO:TEXT)
		endif
		FreeObj(oWSCTE)
	endif
return(self)

static function prepLoteZip(aDocZip, oSelf)
	local nX 		:= 0
	local cXmlRet 	:= ''
	local cXmlDecode	:= ''
	for nX := 1 to Len(aDocZip)
		if ! oSelf:isOk()
			EXIT
		endif
		cXmlDecode	:= Decode64(aDocZip[nX]:TEXT)
		if ! GzStrDecomp( cXmlDecode, len(cXmlDecode), @cXmlRet)
			oSelf:setStatus(.F.,'Gzip Inválido')
		else
			saveXml(cXmlRet, Alltrim(aDocZip[nX]:_NSU:TEXT), oSelf)
		endif
	next nX
return(nil)

static function saveXml(cXmlRet, cNSU, oSelf)
	local cErro		:= ''
	local cAviso		:= ''
	local cNomeArq 	:= ''
	local oXmlResult	:= nil
	local lVld		:= .F.
	default cNSU		:= ''
	
	oXmlResult := XmlParser(cXmlRet,"_",@cErro,@cAviso)
	if ! empty(cErro)
		oSelf:setStatus(.F.,cErro)
	else
		if AttIsMemberOff(oXmlResult, '_PROCEVENTOCTE')
			cNomeArq := oSelf:oCfg:cSaveEvt
			cNomeArq += oSelf:cBranch + '_'
			cNomeArq += cNSU + '_'
			cNomeArq += 'procEventoCTE_'
			cNomeArq += Alltrim(oXmlResult:_PROCEVENTOCTE:_EVENTOCTE:_INFEVENTO:_CHCTE:TEXT)
			lVld := .T.
		elseIf AttIsMemberOff(oXmlResult, '_CTEPROC')
			cNomeArq := oSelf:oCfg:cSaveArq
			cNomeArq += oSelf:cBranch + '_'
			cNomeArq += cNSU + '_'
			cNomeArq += 'procCTE_'
			cNomeArq += Alltrim(oXmlResult:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT)
			lVld := .T.
		endif
		if lVld
			cNomeArq += '_' + DtoS(Date()) + StrTran(Time(),':','') + ".xml"
			if (nHandle := FCREATE(cNomeArq)) == -1
				oSelf:setStatus(.F. , "Erro ao criar arquivo - ferror " + Str(Ferror()))
			else
				if ! sendRedis(cXmlRet, oSelf)
					FClose(nHandle)
					FErase(cNomeArq)
				else
					FWrite(nHandle, cXmlRet)
					FClose(nHandle)
					oSelf:setUltNsu(cNSU)
				endif
			endif
		endif
	endif
	FreeObj(oXmlResult)
return(nil)

static function sendRedis(cXml, oSelf)
	local lRet		:= .T.
	local oRedis 		:= nil
	local lSendRedis	:= GetNewPar('ZZ_SNDCTRE', .F.)
	
	default cXml	:= ''
	if ! empty(cXml) .and. lSendRedis
		oRedis := cbcRedis():newcbcRedis()
		oRedis:setListName('CTE_XML')
		if oRedis:initList():isOk()
			oRedis:add(cXml)
		endif
		if ! ( lRet := oRedis:isOk() )
			oSelf:setStatus(.F. , 'Erro fila CTE_XML: ' + oRedis:getErrMsg())
		endif
		FreeObj(oRedis)
	endif
return(lRet)

static function loadConfig(oSelf)
	oSelf:oCfg := cbcCteConfig():newcbcCteConfig(oSelf:cBranch)
	if !oSelf:oCfg:lIsExcl
		oSelf:setStatus(.F., 'Acesso não exclusivo, rotina em uso.')
	endif
return(nil)

static function GetUFCode(cUF, lForceUF)
	local nX         := 0
	local cRetorno   := ""
	local aUF        := {}
	default lForceUF := .F.
	
	aadd(aUF,{"RO","11"})
	aadd(aUF,{"AC","12"})
	aadd(aUF,{"AM","13"})
	aadd(aUF,{"RR","14"})
	aadd(aUF,{"PA","15"})
	aadd(aUF,{"AP","16"})
	aadd(aUF,{"TO","17"})
	aadd(aUF,{"MA","21"})
	aadd(aUF,{"PI","22"})
	aadd(aUF,{"CE","23"})
	aadd(aUF,{"RN","24"})
	aadd(aUF,{"PB","25"})
	aadd(aUF,{"PE","26"})
	aadd(aUF,{"AL","27"})
	aadd(aUF,{"SE","28"})
	aadd(aUF,{"BA","29"})
	aadd(aUF,{"MG","31"})
	aadd(aUF,{"ES","32"})
	aadd(aUF,{"RJ","33"})
	aadd(aUF,{"SP","35"})
	aadd(aUF,{"PR","41"})
	aadd(aUF,{"SC","42"})
	aadd(aUF,{"RS","43"})
	aadd(aUF,{"MS","50"})
	aadd(aUF,{"MT","51"})
	aadd(aUF,{"GO","52"})
	aadd(aUF,{"DF","53"})
	if !Empty(cUF)
		nX := aScan(aUF,{|x| x[1] == cUF})
		if nX == 0
			nX := aScan(aUF,{|x| x[2] == cUF})
			if nX <> 0
				cRetorno := aUF[nX][1]
			endIf
		else
			cRetorno := aUF[nX][IIF(!lForceUF,2,1)]
		endIf
	else
		cRetorno := aUF
	endIf
return(cRetorno)

static function HandleEr(oErr, oSelf)
	local cMsg	:= "[ " + DtoC(Date())+" - "+Time()+" ] "+ '[ERRO]' + oErr:Description + ' [FROM] ' + ProcName(3)
	oSelf:setStatus(.F., cMsg)
	BREAK
return(nil)

static function ConsoleLog(cMsg)
	ConOut("[ CTE-XML-SCH -" + DtoC(Date())+" - "+Time()+" ] "+ cMsg)
return(nil )

/*/{Protheus.doc} zSchCte
@author bolognesi
@since 02/07/2018
@version 1.0
@type function
@description Função utilizada para baixar (XML/CTE), atraves de schedule
ou execução atraves do menu.
chamada schedule: u_zExecCte({.T.})
chamada Funcao: u_zExecCte({.F.})
/*/
user function zExecCte(aSch,oSay)
	local aRet	:= {}
	local nX		:= 0
	local cMsg	:= ''
	Local nCont := 0
	default aSch := {.T.}
	default oSay := nil
	
	if aSch[1]
		ConsoleLog('Inicio processo schedule')
		RPCClearEnv()
		RPCSetType(3)
		RPCSetEnv('01','01',,,'FAT',GetEnvServer(),{} )
		zGoCte(.F., @aRet)
	else
		if MsgBox("Deseja realizar a importação de todos os CTEs pendentes ?","Confirma?","YesNo")
			oSay:SetText("Processando Registro: " + Alltrim(Str(nCont)) + " ... Aguarde ...")
			oSay:CtrlRefresh()
			zGoCte(.T., @aRet)
		else
			return(nil)
		endif
	endif
	
	if aSch[1]
		ConsoleLog('Finalizou processo schedule')
		RPCClearEnv()
	else
		for nX := 1 to len(aRet)
			if (!aRet[nX,2]) .and. (aRet[nX,3] != "[cbcXmlCte]- Nenhum documento localizado.")
				cMsg += ('Erro Filial: ' + aRet[nX,1] + ' Descrição: ' + aRet[nX,3] )
			endif
		next nX
		if !empty(cMsg)
			MsgAlert(cMsg)
		else
			MsgInfo("Processo finalizado. XMLs Importados!")
		endif
	endif
return(nil)

static function zGoCte(lTela, aRet)
	local cbcaArea	:= GetArea()
	local aAreaM0 	:= SM0->(GetArea())
	local oCte 		:= nil
	local aFil		:= FWAllFilial()
	local nX		:= 0
	local lOk		:= .T.
	local cMsg		:= ''
	local cFilOrig	:= cFilAnt
	
	default lTela 	:= .F.
	default aRet		:= {}
	
	if lTela
		ProcRegua(len(aFil))
	endif
	
	for nX := 1 to len(aFil)
		cFilAnt	:= aFil[nX]
		lOk 	:= .T.
		cMsg	:= ''
		if lTela
			incProc('Processando Filial: ' + aFil[nX] )
		endif
		oCte := cbcXmlCte():newcbcXmlCte()
		oCte:defFil(aFil[nX])
		loadConfig(oCte)
		if ! (lOk := oCte:isOk() )
			cMsg := oCte:getErr()
		else
			oCte:seqSearch()
			if ! (lOk := oCte:isOk())
				cMsg := oCte:getErr()
			endif
		endif
		oCte:oCfg:release()
		aadd(aRet,{aFil[nX],lOk,cMsg})
		FreeObj(oCte)
	next nX
	cFilAnt := cFilOrig
	restArea(aAreaM0)
	RestArea(cbcaArea)
return(aRet)

/* Definições para view da classe */
user function scCteXml()
	local oFont 		:= TFont():New('Courier new',,-12,.T.)
	local oMsgBar		:= nil
	local oMsgBar2	:= nil
	private oMsgItem	:= nil
	private oMsgItem2	:= nil
	private oMsgNSU	:= nil
	private oMsgNSU2	:= nil
	
	Define Dialog oDlg Title "Controle XML/CTE" From 180,180 To 760,890 Pixel COLORS 0, 16777215 PIXEL
	oDlg:setCSS("TButton{ background-color: #EDF0F1; } TButton{ border: 2px solid #CDD2E0; }"+;
		"TGet{ border: 1px solid #CDD2E0; }")
	
	oMsgBar  := TMsgBar():New(oDlg,'',,,,, RGB(116,116,116),,oFont,.F.)
	oMsgBar:SetMsg('ITU    ')
	oMsgItem := TMsgItem():New( oMsgBar, "", ,oFont,,,.T., {||} )
	oMsgNSU	:= TMsgItem():New( oMsgBar, "", ,oFont,,,.T., {||} )
	
	oMsgBar2  := TMsgBar():New(oDlg,'',,,,, RGB(116,116,116),,oFont,.F.)
	oMsgBar2:SetMsg('3LAGOAS')
	oMsgItem2 := TMsgItem():New( oMsgBar2, "", ,oFont,,,.T., {||} )
	oMsgNSU2	:= TMsgItem():New( oMsgBar2, "", ,oFont,,,.T., {||} )
	updInfo(.F.)
	
	TButton():New( 112, 145, "Baixar XML",oDlg,{|| updInfo(.T.) },90,40,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	Activate Dialog oDlg Centered
return (nil)

static function updInfo(lExec)
	default lExec	:= .T.
	if lExec
		u_zExecCte({.F.})
	endif
	popInfo('01', @oMsgItem, @oMsgNSU)
	popInfo('02', @oMsgItem2,@oMsgNSU2)
return(nil)

static function popInfo(cFil, oMsgSts, oMsgNSU)
	local oCte 	:= nil
	local cMsg	:= ''
	local cNsu	:= ''
	local cCss	:= ''
	oCte := cbcXmlCte():newcbcXmlCte()
	oCte:defFil(cFil)
	
	if oCte:isOk()
		cMsg	:= oCte:oCfg:cLastStsMsg
		cNsu	:= "NSU ATUAL: " + oCte:oCfg:cNSUAtual +  " MAX: " + oCte:oCfg:cNSUMax
		if  (!oCte:oCfg:lLastSts) .And. (cMsg != "Nenhum documento localizado.")
			cCss := "TMsgItem{ background-color: #D53811; }"
		else
			cCss := "TMsgItem{ background-color: #617517; }"
		endif
	else
		cMsg	:= oCte:getErr()
		cNsu	:= ''
		cCss := "TMsgItem{ background-color: #617517; }"
	endif
	
	oMsgSts:SetText(cMsg)
	oMsgSts:setCSS(cCss)
	oMsgNSU:SetText(cNsu)
	
	oCte:oCfg:release()
	FreeObj(oCte)
return(nil)
