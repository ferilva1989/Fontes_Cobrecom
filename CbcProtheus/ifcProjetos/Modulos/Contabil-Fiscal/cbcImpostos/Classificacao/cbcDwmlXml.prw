#Include "Protheus.ch"
#Include "ApWebSrv.ch"
#Include "TopConn.ch"
#include 'fileio.ch'
#Include 'FWMVCDef.ch'

#define SEM_MANIFESTACAO    "0"
#define CONFIRMADA          "1"
#define DESCONHECIDA        "2"
#define NAO_REALIZADA       "3"
#define CIENCIA             "4"

#define OP_CONFIRMAR        "0"
#define OP_CIENCIA          "1"
#define OP_DESC             "2"
#define OP_NAO_REALIZ       "4"
/*
    ZX_DFEURL:    Endere?o do WebService das fun??es de manifesto receita.
    ZX_OBRPCXM:   Define se obrigatorio PC para importar XML (.T.=Obrigatorio) / (.F.=Opcional)
    ZX_VLDCHV:    Define se deve validar a chave nota entrada receita
    ZX_CAPEM:     ,"\certs\000001_ca.pem")
    ZX_CERTPEM:   ,"\certs\000001_cert.pem")
    ZX_KEYPEM:    ,"\certs\000001_key.pem")
    ZX_PASSPEM:   ,"Senha Certificado")
    ZX_SSLVERS:   ,"0"
    ZX_SSLSECU:   ,.T.
    ZX_WSLPRES:   ,.F.
    ZX_WSLTOUT:   ,120
*/

class cbcxmlMngr
	data lStatus
	data cErrMsg
	data lTemXml
	data lSetupXml
	data jsInfo
	data cURL
	data cUnXML
	data oWsdl
	data cChvNfe
	data oXml
	method newcbcxmlMngr() constructor
	method setStatus()
	method isOk()
	method getStsMsg()
	method getXmlwS()
	method getXmlFile()
	method showThre()
	method getInfo()
	method manifest()
	method xmlToErp()
	method setupOXml()
	method getValue()
endclass

method newcbcxmlMngr() class cbcxmlMngr
	::setStatus()
	::cURL          := GetNewPar("ZX_DFEURL","https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx?WSDL")
	::cUnXML        := ""
	::lTemXml       := .F.
	::oXml          := nil
	::lSetupXml     := .F.
	::cChvNfe       := ''
return (self)

method setStatus(lSts, cMsg) class cbcxmlMngr
	default lSts    := .T.
	default cMsg    := ''
	::lStatus       := lSts
	::cErrMsg       := cMsg
return (self)

method isOk() class cbcxmlMngr
return (::lStatus)

method getStsMsg() class cbcxmlMngr
return (::cErrMsg)


method getValue(cVl, lItem) class cbcxmlMngr
	local oNfe    := nil
	local xVl     := nil
	local cExe    := ''
	local bErro   := ErrorBlock({|oErr| HandleEr(oErr, @self)})
	default cVl   := ''
	default lItem := .F.
	BEGIN SEQUENCE
		if ::lSetupXml
			oNfe    := XmlChildEx(::oXml:_NFEPROC:_NFE, "_INFNFE")
			if lItem
				xVl := if(ValType(oNfe:_Det) == "O",{oNfe:_Det},oNfe:_Det)
			else
				cExe    := "oNfe:" + cVl + ":TEXT"
				xVl     := &cExe
			endif
		endif
		RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
return xVl


method setupOXml() class cbcxmlMngr
	local cError    := ''
	local cWarning  := ''
	local oResumo   := nil
	::setStatus()
	::oXml  := nil
	if !::lTemXml
		::setStatus(.F., 'XML inexistente')
	else
		::oXml  := XmlParser( ::cUnXML, "_", @cError, @cWarning )
		oResumo := XmlChildEx( ::oXml, "_RESNFE" )
		if !empty(cError)
			::setStatus(.F., cError)
		elseif oResumo
			::setStatus(.F., 'XML n?o disponivel, verifique processo de manifesto')
		else
			::lSetupXml := .T.
		endif
	endif
return self


method xmlToErp() class cbcxmlMngr
	local aProc      := {}
	local aErros     := {}
	local aErroERP   := {}
	local bErro      := ErrorBlock({|oErr| HandleEr(oErr, @self)})
	local nW         := 0
	local cMsg       := ''
	private aRegMark := {}
	private oSC7Temp := nil
	::setStatus()
	if !::lTemXml
		::setStatus(.F., "XML n?o foi definido")
	else
		if ::getInfo('CAD_OK') == 0
			::setStatus(.F., "Fornecedor n?o cadastrado")
		else
			SA2->(DbGoto(::getInfo('CAD_OK')))

			viewProdFor(self, resProd(self, ::getValue(, .T.)) )
			validNcm(self, resProd(self, ::getValue(, .T.)))

			if !self:isOk()
				MsgInfo(::getStsMsg(), 'Erro Entrada, NCM')
			else
				BEGIN SEQUENCE
					BEGIN TRANSACTION
						oSC7Temp := FWTemporaryTable():New()
						if !(ImpXML_NFe("", .F., @aProc, @aErros, .F., ::oXml:_NFEPROC:_NFE,.F.,::cUnXML,@aErroErp))
							if Len(aErros) > 0
								cMsg := ''
								for nW:=1 to Len(aErros)
									cMsg +=  aErros[nW]
								next nW
								disarmtransaction()
								::setStatus(.F., cMsg)
							endif
						else
							if !geraDoc(self)
								disarmtransaction()
							else
								MsgInfo( ::getStsMsg(), 'Sucesso')
							endif
						endif
					END TRANSACTION
					if ::isOk() .And. GetNewPar('ZX_MNFCONF', .T.)
						if ::getInfo('STATUS') == CIENCIA
							if ! ::manifest(::cChvNfe, OP_CONFIRMAR):isOk()
								MsgInfo(::getStsMsg(), 'Erro Manifesto')
							endif
						endif
					endif
					RECOVER
				END SEQUENCE
				if oSC7Temp:LCREATED
					oSC7Temp:Delete()
				endif
				ErrorBlock(bErro)
			endif
		endif
	endif
return(self)


method manifest(cChave, cSts, cJust) class cbcxmlMngr
	local aMontXml  := {}
	local cRetorno  := ""
	local lEnvOk 	:= .F.
	Local oStatic   := IfcXFun():newIfcXFun()
	default cJust   := ""
	::setStatus()
	if erpInfo(self,cChave, .F.)
		if (cSts == OP_NAO_REALIZ .Or. cSts == OP_DESC) .And. empty(cJust)
			::setStatus(.F., "Justificativa obrigatoria")
		endif
		if ::isOk()
			aadd(aMontXml, {01,cChave})
			cCbCpo := "2102"+ cSts +"0"
			MsgRun("Aguarde Manifesta??o","Processando",{|| lEnvOk := oStatic:sP(4):callStatic('SPEDMANIFE', 'MontaXmlManif',cCbCpo,aMontXml,@cRetorno,cJust)})
			if !lEnvOk
				::setStatus(.F., cRetorno)
			else
				::setStatus(.T., cRetorno)
			endif
		endif
	endif
return self


method getInfo(cField) class cbcxmlMngr
	local cInfo := ""
	if ::lTemXml
		cInfo := ::jsInfo[cField]
	endif
return cInfo


method showThre() class cbcxmlMngr
	::setStatus()
	if !::lTemXml
		::setStatus(.F., "Nenhum Xml Carregado ")
	else
		showT(self)
	endif
return (self)


method getXmlFile(cChave) class cbcxmlMngr
	::lTemXml := .F.
	::setStatus()
	if vldChve(cChave, self):isOk()
		::cChvNfe := cChave
		if (gtFrmDisk(self,cChave))
			erpInfo(self, cChave, .F., .F.)
		endif
	endif
return (self)


method getXmlwS(cChave, lJob) class cbcxmlMngr
	local oXmlDocZip := nil
	default lJob := .F.
	::lTemXml := .F.
	::setStatus()
	if vldChve(cChave, self, lJob):isOk()
		::cChvNfe := cChave
		defWsdl(@self)
		if erpInfo(self,cChave)
			if !(::oWsdl:ParseURL(::cURL))
				::setStatus(.F., "Erro ParseURL: " + ::oWsdl:cError)
			else
				if !(::oWsdl:SetOperation("nfeDistDFeInteresse"))
					::setStatus(.F., "Erro SetOperation: " + ::oWsdl:cError)
				else
					if !(::oWsdl:SendSoapMsg(gMsg(cChave)) )
						::setStatus(.F., "Erro SendSoapMsg: " + ::oWsdl:cError)
					else
						if xPars(self, ::oWsdl:GetSoapResponse(), @oXmlDocZip)
							if (::lTemXml := rZip(self, oXmlDocZip))
								::setupOXml()
							endif
						endif
					endif
				endif
			endif
		endif
	endif
return (self)


/* PONTOS DE ENTRADA */
// Antes de Gravar SF1/SD1
user Function COLF1D1()
	local aCab      := PARAMIXB[1]
	local aItens    := PARAMIXB[2]
	local aRet      := {}
	aRet := {aCab,aItens}
return aRet


// Obter o TES para gera??o do documento
user function COMCOLF4()
	// local cForn := PARAMIXB[1]
	// local cLoja := PARAMIXB[2]
	// local cPrd  := PARAMIXB[3]
	local cTes  := PARAMIXB[4]
	// local cTpOp := "51"
	// cTes := u_cbcGetTes(cTpOp,cForn,cLoja,cPrd)
	// 2) Busca na amarra??o produto x fornecedor (SA5 - A5_TESBP)
return cTes


// Logo depois de Gravar SDS/SDT
user function A140IGRV()
    /* 08-06-22 - Leonardo Bolognesi - voltar o SC7 padr?o */
	if FwIsInCallStack("xmlToErp")
		SC7->(DbCloseArea())
		ChkFile("SC7")
		DbSelectArea("SC7")
		SC7->(DbGoTop())
	endif
return

// Relacionar PC com XML 
user function A140IVPED()
	local aArea     := GetArea()
	local aRet      := nil
	local lValida   := .F.
	local cCodigo   := ''
	local cLoja     := ''
	local cProduto  := ''
	local nQuant    := 0
	local cFil      := ''
	local oSql      := nil
	local oFWLayer  := nil
	local oPnlPC    := nil
	local oDlgPC    := nil
	local oMarkSC7  := nil
	local aPCFields := {}
	local aMrk      := {}
	local nX        := 0
	local nQtd      := 0
	local nQtdPed   := 0
	local nToUse    := 0

	cCodigo   := PARAMIXB[1]
	cLoja     := PARAMIXB[2]
	cProduto  := PARAMIXB[3]
	nQuant    := PARAMIXB[4]

	if FwIsInCallStack("ImpXML_NFe")
		aRet      := {}
		oSql      := LibSqlObj():newLibSqlObj()
		oSql:newAlias(qryPC(xFilial('SC7'),cProduto, cCodigo, cLoja, nQuant))
		oSql:GoTop()
		if !oSql:hasRecords()
			oSql:close()
			FreeObj(oSql)
			RestArea(aArea)
			if GetNewPar('ZX_OBRPCXM', .F.)
				UserException("Nenhum pedido disponivel")
			else
				if MsgYesNo('Deseja seguir sem pedido?','Nenhum pedido disponivel')
					return aRet
				else
					UserException("Nenhum pedido,fechado pelo usuario")
				endif
			endif
		else
            /* 08-06-22 - Leonardo Bolognesi - Preparar o SC7 quando grupo de entrega */
			prepSC7(oSql, @cFil, @nQtd, cCodigo, cLoja)

			if nQtd == 1
				SC7->(DbGoTo(Val(cFil)))
				if SC7->(C7_QUANT - C7_QUJE - C7_QTDACLA) >= nQuant
					aadd(aRet,{SC7->(C7_NUM),SC7->(C7_ITEM), MIN(nQuant, SC7->(C7_QUANT - C7_QUJE - C7_QTDACLA) ), lValida})
				else
					UserException("Saldo no pedido insuficiente para entrada da NF!")
				endif
			else
				aPCFields := {'C7_EMISSAO','C7_FORNECE','C7_LOJA','C7_NUM', 'C7_ITEM', 'C7_PRODUTO','C7_DESCRI','C7_QUANT'}
				Define MsDialog oDlgPC Title 'Pedido x Nota' From 5, 0 To 550, 1100 Pixel
				oFWLayer := FWLayer():New()
				oFWLayer:Init( oDlgPC, .F., .T. )
				oFWLayer:AddLine('CIMA', 100, .F. )
				oFWLayer:AddCollumn('CONTEUDO_CIMA'	,100, .T., 'CIMA' )
				oPnlPC     := oFWLayer:GetColPanel('CONTEUDO_CIMA','CIMA')
				oMarkSC7   := FWMarkBrowse():New()
				oMarkSC7:SetOwner(oPnlPC)
				oMarkSC7:SetAlias("SC7")
				oMarkSC7:SetProfileID('pedCom')
				oMarkSC7:SetIgnoreARotina(.T.)
				oMarkSC7:SetMenuDef('')
				oMarkSC7:SetDescription("( Fornecedor: " + cCodigo + " Loja: " + cLoja + " ) - Qtd Nota: " + cValToChar(nQuant))
				oMarkSC7:SetOnlyFields(aPCFields)
				oMarkSC7:SetFieldMark( "C7_OK" )
				oMarkSC7:DisableReport()
				oMarkSC7:CleanFilter()
				oMarkSC7:SetFilterDefault("SC7->(cValToChar(Recno())) $ '" + cFil + "' ")
				oMarkSC7:SetSemaphore(.T.)
				oMarkSC7:OpenSemaphore()
				oMarkSC7:SetCustomMarkRec({||doMark(@aMrk, oMarkSC7:Mark())})
				oMarkSC7:AddButton('Confirmar', {||oDlgPC:End() },,3, 1)
				oMarkSC7:Activate()
				ACTIVATE MSDIALOG oDlgPC CENTERED
				AEval( aMrk, {|aDt| SC7->(DbGoTo(aDt)), nQtdPed += SC7->(C7_QUANT - C7_QUJE - C7_QTDACLA) } )
				if nQtdPed >= nQuant
					for nX := 1 to len(aMrk)
						if nQuant > 0
							nToUse := MIN(nQuant,SC7->(C7_QUANT - C7_QUJE - C7_QTDACLA))
							SC7->(DbGoTo(aMrk[nX]))
							aadd(aRet,{SC7->C7_NUM,SC7->C7_ITEM,nToUse,lValida})
							nQuant := (nQuant - nToUse)
						else
							exit
						endif
					next nX
				else
					UserException("Saldo nos pedidos selecionados insuficiente para entrada da NF!")
				endif
				FreeObj(oFWLayer)
				FreeObj(oMarkSC7)
			endif
		endif
		oSql:close()
		FreeObj(oSql)
		FreeObj(oPnlPC)
		FreeObj(oDlgPC)

		if empty(aRet)
			UserException("Nenhum registro selecionado, ou pedido inexistente")
		endif
	endif

	RestArea(aArea)
return aRet


/* 
    08-06-22 Leonardo Bolognesi Criado para preparar um SC7 quando recebimento utiliza conceito
    de grupo de entrega, neste caso NF vem com um fornecedor mas o pedido ? de outro fornecedor 
*/
static function prepSC7(oSql, cFil, nQtd, cCodigo, cLoja)
	local nLoop     := 0
	local aStruct   := {}
	local lDoTemp   := FwIsInCallStack("xmlToErp")

	if (lDoTemp)
		lDoTemp := .F.
		if oSC7Temp:LCREATED
			dbChangeAlias("SC7", oSC7Temp:GetAlias())
			SC7->(DbCloseArea())
			ChkFile("SC7")
			DbSelectArea("SC7")
			SC7->(DbGoTop())
		endif
		oSql:GoTop()
		while oSql:notIsEof()
			SC7->(DbGoTo(oSql:getValue('REC')))
			if SC7->(Alltrim(C7_FORNECE + C7_LOJA)) != Alltrim((cCodigo + cLoja))
				lDoTemp := .T.
				EXIT
			endif
			oSql:skip()
		enddo
	endif

	if (lDoTemp)
		aStruct := SC7->(DBStruct())
		if ! oSC7Temp:LCREATED
			oSC7Temp:SetFields(aStruct)
			oSC7Temp:AddIndex( '1', {'C7_FILIAL', 'C7_NUM', 'C7_ITEM', 'C7_SEQUEN'} )
			oSC7Temp:Create()
		endif
	endif

	oSql:GoTop()
	while oSql:notIsEof()
		if !empty(cFil)
			cFil += ","
		endif
		if (lDoTemp)
			SC7->(DbGoTo(oSql:getValue('REC')))
			(oSC7Temp:GetAlias())->(DBAppend())
			for nLoop := 1 to Len(aStruct)
				if(aStruct[nLoop][1] == 'C7_FORNECE')
					(oSC7Temp:GetAlias())->&(aStruct[nLoop][1]) := cCodigo
				elseif (aStruct[nLoop][1] == 'C7_LOJA')
					(oSC7Temp:GetAlias())->&(aStruct[nLoop][1]) := cLoja
				else
					(oSC7Temp:GetAlias())->&(aStruct[nLoop][1]) := SC7->&(aStruct[nLoop][1])
				endif
			next nLoop
			(oSC7Temp:GetAlias())->(DBCommit())
			cFil += cValToChar((oSC7Temp:GetAlias())->(recno()))
		else
			cFil += cValToChar(oSql:getValue('REC'))
		endif
		nQtd++
		oSql:skip()
	endDo

	if (lDoTemp)
		SC7->(DbCloseArea())
		dbChangeAlias(oSC7Temp:GetAlias(), "SC7")
		SC7->(DBSetOrder(1))
		DbSelectArea("SC7")
		SC7->(DbGoTop())
	endif
return nil

static function doMark(aMrk, cMrk)
	local nPos := 0
	RecLock('SC7', .F.)
	if (nPos := Ascan(aMrk, {|nRe| nRe  == SC7->(Recno()) }) ) > 0
		aDel(aMrk, nPos)
		aSize(aMrk,(len(aMrk)-1))
		SC7->(C7_OK) := ''
	else
		aadd(aMrk, SC7->(Recno()))
		SC7->(C7_OK) := cMrk
	endif
	SC7->(MsUnlock())
return nil


static function vldChve(cChave, oSelf, lJob)
	local oSql          := nil
	local lRet          := .T.
	private cFormul     := "N"
	private cEspecie    := "SPED"
	private l103Auto    := .F.
	private aAutoCab    := nil
	default lJob := .F.
	oSelf:setStatus()
	if len(cChave) <> 44
		oSelf:setStatus(.F., "Chave menor que o esperado (44) caracteres" )
	else
		if GetNewPar('ZX_VLDCHV', .T.)
			if (l103Auto := lJob)
				lRet := A103ConsNfeSef(cChave,nil)
			else
				FWMsgRun(, {|| lRet := A103ConsNfeSef(cChave,nil)}, "Validar", "Validando Chave...")
			endif
		endif
		if !lRet
			oSelf:setStatus(.F., "Protocolo n?o validado na Receita" )
		else
			oSql      := LibSqlObj():newLibSqlObj()
			oSql:newAlias(qryChv(cChave))
			oSql:GoTop()
			if oSql:hasRecords()
				if oSql:getValue("TEM") > 0
					oSelf:setStatus(.F., "Chave j? existente nas notas de entrada" )
				endif
			endif
			oSql:close()
			FreeObj(oSql)
		endif
	endif
return oSelf


static function geraDoc(oSelf)
	local oSql          := nil
	private aRegMark    := {}
	private cMarca	    := GetMark()
	Private cCadastro   := "Entrada XML"
	Private lToma4NFOri	:= .T.
	Private cFilQry     := ''

	oSql                := LibSqlObj():newLibSqlObj()
	oSql:newAlias(qryDs(xFilial('SDS'), oSelf:cChvNfe))
	oSql:GoTop()
	if !oSql:hasRecords()
		oSelf:setStatus(.F., "Nenhum registro foi importado, verifique SDS/SDT" )
	else
		SDS->(DbGoTo(oSql:getValue("DS_REC")))
		aadd(aRegMark,oSql:getValue("DS_REC"))
		RecLock('SDS', .F.)
		SDS->(DS_OK) := cMarca
		SDS->(MsUnlock())
		oSql:Close()
		FreeObj(oSql)
		COMCOLGER()
		if SDS->(DS_STATUS) == 'E'
			oSelf:setStatus(.F., Alltrim(SDS->DS_DOCLOG))
		else
			oSelf:setStatus(.T., 'Documento: ' + Alltrim(SDS->(DS_DOC)) + ' Serie: ' + Alltrim(SDS->(DS_SERIE)))
			CopytoClipboard(xFilial('SDS') + SDS->(DS_DOC + DS_SERIE + DS_FORNEC + DS_LOJA))
		endif
	endif
return oSelf:isOk()


static function viewProdFor(oSelf, oJs)
	if empty(oJs['PROD'])
		oSelf:setStatus(.F., "Nenhum item encontrado")
	else
		U_LbMsgRun({|oSay|procVw(oSelf,oJs)} ,"Produto Fornecedor", "Validando relacionamento!", 2, 0 )
	endif
return nil

static function validNcm(oSelf, oJs)
	if empty(oJs['PROD'])
		oSelf:setStatus(.F., "Nenhum item encontrado")
	else
		U_LbMsgRun({|oSay|procNcM(oSelf,oJs)} ,"Produto Fornecedor", "Validando NCM Produto x Nota!", 2, 0 )
	endif
return nil

static function procVw(oSelf,oJs)
	u_zCliForMvc(@oJs)
	grvProdFor(oSelf, @oJs)
return nil

static function procNcM(oSelf,oJs)
	local nX     := 1
	local aPrd   := {}
	local cMsg   := ''
	local linha	:= chr(13) + chr(10)
	for nX := 1 to len(oJs['PROD'])
		if(Alltrim(oJs['PROD'][nX]['Ncm']) <> Alltrim(oJs['PROD'][nX]['B1NCM']))
			aadd(aPrd, Alltrim(oJs['PROD'][nX]['Descr']))
		endif
	next nX
	if len(aPrd) > 0
		cMsg := 'Produto(s): ' + linha
		for nX := 1 to len(aPrd)
			cMsg += aPrd[nX] + linha
		next nX
		cMsg += ' apresenta(m) NCM diferente do cadastro de produtos interno!'
		oSelf:setStatus(.F., cMsg )
	endif
return nil

static function grvProdFor(oSelf, oJs)
	local nX         := 0
	local oModel     := nil
	local lInsert    := .T.
	local cDesPrf    := ''
	local cNomProd   := ''
	if iok(oSelf, oJs)
		BEGIN Transaction
			oModel := FWLoadModel('MATA061')
			for nX := 1 to len(oJs['PROD'])
				if (lInsert := isInsert(oJs['PROD'][nX]['CodInt'] + SA2->(A2_COD) + SA2->(A2_LOJA)) )
					nOpc    := MODEL_OPERATION_INSERT
				else
					nOpc    := MODEL_OPERATION_UPDATE
				endif
				oModel:SetOperation(nOpc)
				oModel:Activate()
				cDesPrf     := Substr(oJs['PROD'][nX]['Descr'],1,TamSx3('A5_DESCPRF')[1])
				cNomProd    := Substr(oJs['PROD'][nX]['DescInt'],1,TamSx3('A5_NOMPROD')[1])
				if lInsert
					oModel:LoadValue('MdFieldSA5','A5_PRODUTO', oJs['PROD'][nX]['CodInt'])
					oModel:SetValue('MdFieldSA5','A5_NOMPROD', cNomProd )
					oModel:GetModel("MdGridSA5"):AddLine()
					oModel:SetValue('MdGridSA5','A5_FORNECE'    ,SA2->(A2_COD))
					oModel:SetValue('MdGridSA5','A5_LOJA'       ,SA2->(A2_LOJA))
					oModel:SetValue('MdGridSA5','A5_CODPRF'     ,UPPER(oJs['PROD'][nX]['Cod']))
					oModel:SetValue('MdGridSA5','A5_DESCPRF'    ,cDesPrf)
				else
					oModel:SetValue('MdGridSA5','A5_CODPRF'     ,UPPER(oJs['PROD'][nX]['Cod']))
					oModel:SetValue('MdGridSA5','A5_DESCPRF'    ,cDesPrf)
				endif
				if !oModel:VldData()
					oSelf:setStatus(.F., oModel:GetErrorMessage()[6])
					DisarmTransaction()
					exit
				else
					oModel:CommitData()
				endif
				oModel:DeActivate()
			next nX
			oModel:Destroy()
		END Transaction
	endif
return oSelf:isOk()


static function isInsert(cChave)
	local lInsert := .T.
	// A5_FILIAL, A5_PRODUTO, A5_FORNECE, A5_LOJA
	SA5->(DbSetOrder(2))
	if SA5->(DbSeek(xFilial('SA5') + cChave))
		lInsert := .F.
	else
		lInsert := .T.
	endif
return lInsert


static function iok(oSelf, oJs)
	local nX := 0
	local lRet  := .T.
	for nX := 1 to len(oJs['PROD'])
		if empty(oJs['PROD'][nX]['CodInt'])
			oSelf:setStatus(.F., 'Erro Amarra??o produto: ' + oJs['PROD'][nX]['Cod'] + '-' + oJs['PROD'][nX]['Descr'])
			lRet := .F.
			exit
		endif
	next nX
return lRet


static function  resProd(oSelf, aIt)
	local nX        := 0
	local jsItem    := nil
	local oJsret    := nil
	default aIt     := {}
	oJsret := JsonObject():new()
	oJsret['PROD']  := {}
	for nX := 1 to len(aIt)
		jsItem              := JsonObject():new()
		jsItem['Cod']       := ''
		jsItem['Descr']     := ''
		jsItem['Ean']       := ''
		jsItem['Ncm']       := ''
		jsItem['CodInt']    := Space(TamSx3('B1_COD')[1])
		jsItem['DescInt']   := ''
		jsItem['RecB1']     := 0
		jsItem['B1NCM']     := ""
		if(ex(aIt[nX],'_PROD'))
			if ex(aIt[nX]:_PROD, '_CPROD')
				jsItem['Cod'] := UPPER(aIt[nX]:_PROD:_CPROD:TEXT)
			endif
			if ex(aIt[nX]:_PROD, '_XPROD')
				jsItem['Descr'] := aIt[nX]:_PROD:_XPROD:TEXT
			endif
			if ex(aIt[nX]:_PROD, '_CEAN')
				jsItem['Ean'] := aIt[nX]:_PROD:_CEAN:TEXT
			endif
			if ex(aIt[nX]:_PROD, '_NCM')
				jsItem['Ncm'] := aIt[nX]:_PROD:_NCM:TEXT
			endif
		endif
		aadd(oJsret['PROD'],jsItem)
	next nX
	bInt(@oJsret)
return oJsret


static function bInt(oJs)
	local nX    := 0
	local oSql  := nil
	oSql     := LibSqlObj():newLibSqlObj()
	for nX := 1 to len(oJs['PROD'])
		oSql:newAlias(qryProFor(SA2->(A2_COD), SA2->(A2_LOJA), oJs['PROD'][nX]['Cod']))
		oSql:GoTop()
		if oSql:hasRecords()
			oJs['PROD'][nX]['CodInt']   :=  oSql:getValue("CodInt")
			oJs['PROD'][nX]['DescInt']  :=  oSql:getValue("DescInt")
			oJs['PROD'][nX]['RecB1']    :=  oSql:getValue("RecB1")
			oJs['PROD'][nX]['B1NCM']    :=  oSql:getValue("B1NCM")
		endif
		oSql:close()
	next nX
	FreeObj(oSql)
return


static function ex(aObj,cProp)
return((aScan(ClassDataArr(aObj),{|it|it[1] == cProp })) > 0)


static function gtFrmDisk(oSelf, cChave)
	local cFile         := ''
	local oFile         := nil
	local cXml          := ''
	local oXmlDocZip    := nil
	default cChave      := '*'
	cChave              := alltrim(cChave)
	cFile:= cGetFile( cChave +".xml|"+ cChave +".xml" , 'Notas (XML)', 1,'',.F.,;
		nOR(GETF_LOCALHARD, GETF_NETWORKDRIVE ),.F., .T.)
	if empty(cFile)
		oSelf:setStatus(.F., "Nenhum arquivo foi selecionado")
	else
		oFile := FWFileReader():New(cFile)
		if (!oFile:Open())
			oSelf:setStatus(.F., "Problemas ao abrir o arquivo")
		else
			oFile:NBUFFERSIZE := (oFile:getFileSize() / 2)
			while (oFile:hasLine())
				cXml += oFile:GetLine()
			enddo
			if empty(cXml)
				oSelf:setStatus(.F., "Arquivo n?o lido")
			else
				if !xPars(oSelf, cXml, @oXmlDocZip)
					oSelf:setStatus(.F., "Estrutura XML invalida")
				else
					oSelf:lTemXml   := .T.
					oSelf:cUnXML    := cXml
					oSelf:setupOXml()
				endif
			endif
			oFile:Close()
		endif
	endif
return oSelf:isOk()


static function erpInfo(oSelf, cChave, lVldSts, lMdf)
	local oSql      := nil
	default lVldSts := .T.
	default lMdf    := .T.
	oSelf:jsInfo    := JsonObject():new()
	oSql            := LibSqlObj():newLibSqlObj()
	if lMdf
		oSql:newAlias(qryManif(cChave))
	else
		oSql:newAlias(qryFor(oSelf:getValue('_EMIT:_CNPJ')))
	endif

	oSql:GoTop()
	if !oSql:hasRecords()
		if !lMdf
			oSelf:jsInfo['CHAVE']   := cChave
			oSelf:jsInfo['CNPJ']    := oSelf:getValue('_EMIT:_CNPJ')
			oSelf:jsInfo['CAD_OK']  := 0
		else
			oSelf:setStatus(.F., "Nenhum registro encontrada MDF")
		endif
	else
		if lMdf
			oSelf:jsInfo['CHAVE']   := oSql:getValue("CHAVE")
			oSelf:jsInfo['SERIE']   := oSql:getValue("SERIE")
			oSelf:jsInfo['NOTA']    := oSql:getValue("NOTA")
			oSelf:jsInfo['EMIT']    := oSql:getValue("EMIT")
			oSelf:jsInfo['CNPJ']    := oSql:getValue("CNPJ")
			oSelf:jsInfo['ANO_MES'] := oSql:getValue("ANO_MES")
			oSelf:jsInfo['STATUS']  := oSql:getValue("STATUS")
			oSelf:jsInfo['CAD_OK']  := oSql:getValue("CAD_OK")
			if lVldSts .And. oSql:getValue("STATUS") != CONFIRMADA .And. oSql:getValue("STATUS") != CIENCIA
				oSelf:setStatus(.F., "Nota precisa ser manifestada para baixar XML")
			endif
		else
			oSelf:jsInfo['CHAVE']   := cChave
			oSelf:jsInfo['CNPJ']    := oSql:getValue("CNPJ")
			oSelf:jsInfo['CAD_OK']  := oSql:getValue("CAD_OK")
		endif
	endif
	oSql:Close()
return oSelf:isOk()


static function showT(oSelf)
	Local cTempPath := GetTempPath(.T.)
	Local cFile := cTempPath + oSelf:getInfo('CHAVE') +'.xml'
	oDlg := TDialog():New(150,300,600,900,'',,,,,,,,,.T.)
	ofileXML := FCREATE(cFile)
	if ofileXML>0
		FWrite(ofileXML, oSelf:cUnXML)
		FClose(ofileXML)
	endIf
	oXml := TXMLViewer():New(10, 10, oDlg , cFile, 280, 200, .T. )
	if oXml:setXML(cFile)
		alert("Arquivo n?o encontrado")
	endIf
	oDlg:Activate()
return


static function defWsdl(oSelf)
	oSelf:oWsdl                 := Nil
	oSelf:oWsdl                 := TWsdlManager():New()
	oSelf:oWsdl:cSSLCACertFile  := GetNewPar("ZX_CAPEM"     ,"\certs\000001_ca.pem")
	oSelf:oWsdl:cSSLCertFile    := GetNewPar("ZX_CERTPEM"   ,"\certs\000001_cert.pem")
	oSelf:oWsdl:cSSLKeyFile     := GetNewPar("ZX_KEYPEM"    ,"\certs\000001_key.pem")
	oSelf:oWsdl:cSSLKeyPwd      := GetNewPar("ZX_PASSPEM"   ,"Cobre1020")
	oSelf:oWsdl:nSSLVersion     := GetNewPar("ZX_SSLVERS"   ,"0")
	oSelf:oWsdl:lSSLInsecure    := GetNewPar("ZX_SSLSECU"   ,.T.)
	oSelf:oWsdl:lProcResp       := GetNewPar("ZX_WSLPRES"   ,.F.)
	oSelf:oWsdl:nTimeout        := GetNewPar("ZX_WSLTOUT"   ,120)
return nil


static function rZip(oSelf, oXmlDocZip)
	local cXmlGZip  := ''
	local nTamanho  := 0
	local cDecode64 := ''
	local cStat     := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT
	local cMotivo   := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_XMOTIVO:TEXT
	oSelf:cUnXML    := ""
	if ( cStat == "138" )
		cXmlGZip  := oXmlDocZip:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_LOTEDISTDFEINT:_DOCZIP:TEXT
		nTamanho  := Len(cXmlGZip)
		cDecode64 := Decode64(cXmlGZip)
		GzStrDecomp(cDecode64, nTamanho, @oSelf:cUnXML)
	else
		oSelf:setStatus(.F., "Status:" + cStat + " Motivo: " + cMotivo)
	endif
return oSelf:isOk()


static function xPars(oSelf, cMsgRet, oXmlDocZip)
	local cError     := ''
	local cWarning   := ''
	oXmlDocZip  := XmlParser(cMsgRet, "_", @cError, @cWarning)
	if ! Empty(cWarning)
		oSelf:setStatus(.F., "Alerta cWarning: " + cWarning)
	endif
	if ! Empty(cError)
		oSelf:setStatus(.F., "Erro cError: " + cError)
	endif
return oSelf:isOk()


static function gMsg(cChaveNFe)
	local cUfAutor  := "35"
	local cTpAmb    := "1"
	local cMsg      := ""
	local nPos      := 0
	local aCfgUf    := {}
	local aEmpInfo  := FWArrFilAtu(FWCodEmp(),FWCodFil())
	local cCNPJEmp  := Alltrim(Alltrim(aEmpInfo[18]))

	// Filial x Estado
	aadd(aCfgUf, {'01', '35'})
	aadd(aCfgUf, {'02', '50'})
	aadd(aCfgUf, {'03', '31'})
	if (nPos := aScan(aCfgUf, {|x| x[1] == aEmpInfo[5] }) ) > 0
		cUfAutor := aCfgUf[nPos][2]
	endif

	cMsg += '<soapenv:Envelope xmlns:soapenv="http://www.w3.org/2003/05/soap-envelope">'                         + CRLF
	cMsg += '    <soapenv:Header/>'                                                                              + CRLF
	cMsg += '    <soapenv:Body>'                                                                                 + CRLF
	cMsg += '        <nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'   + CRLF
	cMsg += '                <nfeDadosMsg>'                                                                      + CRLF
	cMsg += '                    <distDFeInt xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.01">'          + CRLF
	cMsg += '                        <tpAmb>'+cTpAmb+'</tpAmb>'                                                  + CRLF
	cMsg += '                     <cUFAutor>'+cUfAutor+'</cUFAutor>'                                             + CRLF
	cMsg += '                        <CNPJ>'+cCNPJEmp+'</CNPJ>'                                                  + CRLF
	cMsg += '                      <consChNFe>'                                                                  + CRLF
	cMsg += '                           <chNFe>'+alltrim(cChaveNFe)+'</chNFe>'                                   + CRLF
	cMsg += '                      </consChNFe>'                                                                 + CRLF
	cMsg += '                    </distDFeInt>'                                                                  + CRLF
	cMsg += '                </nfeDadosMsg>'                                                                     + CRLF
	cMsg += '            </nfeDistDFeInteresse>'                                                                 + CRLF
	cMsg += '        </soapenv:Body>'                                                                            + CRLF
	cMsg += '    </soapenv:Envelope>'                                                                            + CRLF
return cMsg


/* QUERYES*/
static function qryChv(cChave)
	local cQry := ''
	cQry += " SELECT COUNT(*) AS TEM
	cQry += " FROM " + RetSqlName('SF1')
	cQry += " WHERE F1_FILIAL NOT IN ('')
	cQry += " AND F1_CHVNFE = '"+cChave+"'"
	cQry += " AND D_E_L_E_T_ = ''
return cQry


static function qryDs(cFil,cChave)
	local cQry := ''
	default cFil    := xFilial('SDS')
	default cChave  := ''
	if !empty(cChave)
		cQry += " SELECT  SDS.R_E_C_N_O_ AS DS_REC "
		cQry += " FROM "+ RetSqlName('SDS') +" SDS with(nolock) "
		cQry += " WHERE  "
		cQry += " SDS.DS_FILIAL = '"+cFil+"' "
		cQry += " AND SDS.DS_CHAVENF = '"+cChave+"' "
		cQry += " AND SDS.D_E_L_E_T_ = '' "
	endif
return cQry


static function qryPC(cFil,cProd, cForn, cLoja, nQuant)
	local cQry      := ''
	default cFil    := xFilial('SC7')
	cQry += " SELECT"
	cQry += " R_E_C_N_O_ as REC,"
	cQry += " C7_NUM     as PC,"
	cQry += " C7_ITEM    as IT,"
	cQry += " C7_DESCRI  as DESCR,"
	cQry += " C7_QUANT   as QTD,"
	cQry += " C7_QUANT - C7_QUJE - C7_QTDACLA AS SLDPC" //add Filipe Silva - 24/06/2022
	cQry += " FROM " + RetSqlName("SC7")
	cQry += " WHERE "
	cQry += " C7_FILIAL      = '"   + cFil    + "'

	// Utilizado para encontrar grupo de fornecedores
	cQry += " AND ( ( C7_FORNECE + C7_LOJA IN ( "
	cQry += " SELECT CPX_CODIGO + CPX_LOJA FROM CPX010 WHERE  "
	cQry += " CPX_CODFOR = '" + cForn + "'"
	cQry += " AND CPX_LOJFOR = '" + cLoja + "'"
	cQry += " AND D_E_L_E_T_ = '' "
	cQry += " ) ) "
	cQry += " OR "
	cQry += " (C7_FORNECE = '" + cForn + "'"
	cQry += " AND C7_LOJA = '" + cLoja + "')"
	cQry += " ) "
	cQry += " AND C7_PRODUTO    = '"   + cProd   + "' "
//	cQry += " AND (C7_QUANT - C7_QUJE - C7_QTDACLA) >= " + cValToChar(nQuant)
	cQry += " AND C7_ENCER	    != 'E' "
	cQry += " AND C7_RESIDUO	!= 'S' "
	cQry += " AND C7_CONAPRO    = 'L'
	cQry += " AND D_E_L_E_T_ = '' "
return cQry


static function qryProFor(cForn, cLoja, cProd)
	local cQry := ''
	cQry += " SELECT "
	cQry += " SB1.B1_COD        AS CodInt, "
	cQry += " SB1.B1_DESC       AS DescInt,  "
	cQry += " SB1.B1_POSIPI     AS B1NCM,  "
	cQry += " SB1.R_E_C_N_O_    AS RecB1  "
	cQry += " FROM " + RetSqlName('SA5') + " SA5  WITH(NOLOCK) "
	cQry += " INNER JOIN " + RetSqlName('SB1') + " SB1 WITH(NOLOCK) "
	cQry += " ON '"+ xFilial("SB1") +"' = SB1.B1_FILIAL  "
	cQry += " AND SA5.A5_PRODUTO = SB1.B1_COD "
	cQry += " AND SA5.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
	cQry += " WHERE SA5.A5_FILIAL = '' "
	cQry += " AND SA5.A5_FORNECE = '"+  cForn +"' "
	cQry += " AND SA5.A5_LOJA    = '" + cLoja + "'  "
	cQry += " AND UPPER(SA5.A5_CODPRF) = '" + UPPER(cProd) + "' "
	cQry += " AND SA5.D_E_L_E_T_ = '' "
return cQry


static function qryFor(cCnpj)
	local cQry := ''
	default cCnpj := ''
	if !empty(cCnpj)
		cQry += " SELECT
		cQry += " R_E_C_N_O_ AS CAD_OK,
		cQry += " A2_CGC	   AS CNPJ
		cQry += " FROM " + RetSqlName("SA2") + " WITH(NOLOCK)"
		cQry += " WHERE
		cQry += " A2_FILIAL = '"  + xFilial('SA2') +"'"
		cQry += " AND A2_CGC = '" + cCnpj + "'"
		cQry += " AND D_E_L_E_T_ = ''
	endif
return cQry


static function qryManif(cChave)
	local cQry := ''
	cQry += " SELECT
	cQry += " C00.C00_CHVNFE						AS CHAVE,"
	cQry += " C00.C00_SERNFE						AS SERIE,"
	cQry += " C00.C00_NUMNFE						AS NOTA,"
	cQry += " C00.C00_NOEMIT						AS EMIT,"
	cQry += " C00.C00_CNPJEM						AS CNPJ,"
	cQry += " C00.C00_ANONFE + '-' + C00_MESNFE	    AS ANO_MES,"
	cQry += " C00.C00_STATUS						AS STATUS,"
	cQry += " ISNULL(SA2.R_E_C_N_O_, 0)		        AS CAD_OK "
	cQry += " FROM "+ RetSqlName('C00') + "  C00 WITH(NOLOCK) "
	cQry += " LEFT JOIN " + RetSqlName('SA2') + " SA2 WITH(NOLOCK) "
	cQry += " ON '" + xFilial('SA2') +"' = SA2.A2_FILIAL "
	cQry += " AND C00.C00_CNPJEM = SA2.A2_CGC "
	cQry += " AND C00.D_E_L_E_T_ = SA2.D_E_L_E_T_ "
	cQry += " WHERE C00.C00_FILIAL = '" + xFilial('C00') + "'"
	cQry += " AND C00.C00_CHVNFE = '" + cChave + "'"
	cQry += " AND C00.D_E_L_E_T_ = '' "
return cQry


static function qryToManif()
	local cQry := ''
	cQry += " SELECT
	cQry += " C00.C00_FILIAL				 AS FILIAL, "
	cQry += " C00.C00_CHVNFE				 AS CHAVE   "
	cQry += " FROM " + RetSqlName('C00') + "  C00 WITH(NOLOCK) "
	cQry += " WHERE C00.C00_STATUS = '0'"
	cQry += " AND C00_ANONFE >= '2022' "
	cQry += " AND C00_SITDOC = '1' "
	cQry += " AND C00.D_E_L_E_T_ = '' "
	cQry += " ORDER BY C00.C00_FILIAL "
return cQry


static function HandleEr(oErr, oSelf)
	if InTransact()
		DisarmTransaction()
	endif
	oSelf:setStatus(.F., oErr:Description)
	BREAK
return nil


/* INTERFACE DE TELA */
user function zCbcInXML()
	local oFont			:= TFont():New("Arial",,30,,.T.)
	local bDisco 		:= {|| FWMsgRun(, {|| fromDisc(cChv)}, "XML em Disco", "Buscando Xml no disco...")}
	local bReceita		:= {|| FWMsgRun(, {|| fromMdfe(cChv)}, "XML Receita", "Buscando Xml na receita...")}
	local bMani		    := {|| FWMsgRun(, {|| frmMnfs(cChv)}, "Manifesto", "Enviando ci?ncia da opera??o...")}
	local bBlkVld       := {|| .T. }
	local aButtons      := {}
	private oModal 		:= nil
	private oGet		:= nil
	private cChv		:= Space(TamSX3("F1_CHVNFE")[1])
	private cFormul     := "N"
	private cEspecie    := "SPED"

	aadd(aButtons, {nil,'XML_Disco',    bDisco,     'Buscar XML no disco', nil,.T., .F.})
	aadd(aButtons, {nil,'XML_MDFe',     bReceita,   'Buscar XML no MDFe',  nil,.T., .F.})
	aadd(aButtons, {nil,'Manifest_MDFe',bMani,      'Buscar XML no MDFe',  nil,.T., .F.})

	oModal := FWDialogModal():New()
	oModal:setSize(100,300)
	oModal:SetEscClose(.T.)
	oModal:setTitle('Informe a Chave da Nota Fiscal')
	oModal:createDialog()
	oModal:addButtons(aButtons)
	oModal:addCloseButton(nil, "Fechar")
	oPnl := TPanel():New( ,,, oModal:getPanelMain() )
	oPnl:SetCss("")
	oPnl:Align := CONTROL_ALIGN_ALLCLIENT
	oGet := TGet():New(05,05, { | u | If( PCount() == 0, cChv,cChv:= u ) },oPnl,290,030,"@!", bBlkVld,0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cChv,,,, )

	setMsgCss(@oModal:oSayTitle)
	setMsgCss(@oModal:oTop)

	oModal:Activate()

	FreeObj(oGet)
	FreeObj(oFont)
	FreeObj(oPnl)
	FreeObj(oModal)
return nil


static function fromMdfe(cChave)
	local oMng      := cbcxmlMngr():newcbcxmlMngr()
	default cChave  := ''
	if empty(cChave)
		MsgInfo('Chave Obrigatoria', 'Erro')
	else
		if oMng:getXmlwS(cChave):isOk()
			if !oMng:xmlToErp():isOk()
				MsgInfo(oMng:getStsMsg(), 'Erro')
				CopytoClipboard(cChave)
			endif
		else
			MsgInfo(oMng:getStsMsg(), 'Erro')
			CopytoClipboard(cChave)
		endif
	endif
	cChv := Space(TamSX3("F1_CHVNFE")[1])
	FreeObj(oMng)
return nil


static function fromDisc(cChave)
	local oMng      := cbcxmlMngr():newcbcxmlMngr()
	default cChave  := ''
	if empty(cChave)
		MsgInfo('Chave Obrigatoria', 'Erro')
	else
		if oMng:getXmlFile(cChave):isOk()
			if !oMng:xmlToErp():isOk()
				MsgInfo(oMng:getStsMsg(), 'Erro')
				CopytoClipboard(cChave)
			endif
		else
			MsgInfo(oMng:getStsMsg(), 'Erro')
			CopytoClipboard(cChave)
		endif
	endif
	cChv := Space(TamSX3("F1_CHVNFE")[1])
	FreeObj(oMng)
return nil


static function frmMnfs(cChave)
	local oMng      := cbcxmlMngr():newcbcxmlMngr()
	local lRet      := .F.
	default cChave  := ''
	if empty(cChave)
		MsgInfo('Chave Obrigatoria', 'Erro')
	else
		if GetNewPar('ZX_VLDCHV', .T.)
			FWMsgRun(, {|| lRet := A103ConsNfeSef(cChave,nil)}, "Validar", "Validando Chave...")
		endif
		if lRet
			if !oMng:manifest(cChave,OP_CIENCIA):isOk()
				MsgInfo(oMng:getStsMsg(), 'Erro')
			else
				MsgInfo(oMng:getStsMsg(), 'Sucesso')
				CopytoClipboard(cChave)
			endif
		endif
	endif
	cChv := Space(TamSX3("F1_CHVNFE")[1])
	FreeObj(oMng)
return nil


static function setMsgCss(oObj, cOpc)
	local cCss 		:= ''
	local cTpObj 	:= GetClassName(oObj)
	default cOpc	:= ''
	if cTpObj == "TSAY"
		cCss +=	"QLabel { ";
			+"  font-size: 23px; /*Tamanho da fonte*/";
			+"  color: #006d93; /*Cor da fonte*/";
			+"  font-weight: bold; /*Negrito*/";
			+"  text-align: center; /*Alinhamento*/";
			+"  vertical-align: middle; /*Alinhamento*/";
			+"  border-radius: 6px; /*Arrerondamento da borda*/";
			+"}"
	endif
	if !empty(cCss)
		oObj:SetCSS(cCss)
	endif
return(oObj)

static function ConsoleLog(cMsg)
	ConOut("[ MAN-DEST-CIENCIA -" + DtoC(Date())+" - "+Time()+" ] "+ cMsg)
return(nil )


/* Utilizado na API para obter os dados dos XML de entrada */
user function zApiXmlEnt(cChave) // zApiXmlEnt('35220162462676000154550010004957351284482818')
	local oMng as object
	local aItm as array
	local oResp as object
	local oInfo as object
	local nX as numeric
	default cChave  := ''

	oResp           := JsonObject():new()
	oResp['STS']    := .T.
	oResp['RESP']   := JsonObject():new()
	oResp['MSG']    := ''

	if empty(cChave)
		oResp['STS'] := .F.
		oResp['MSG'] := 'Chave Obrigatoria'
	else
		oMng := cbcxmlMngr():newcbcxmlMngr()
		if oMng:getXmlwS(cChave, .T.):isOk()
			oInfo    := XmlChildEx(oMng:oXml:_NFEPROC:_NFE, "_INFNFE")
			oResp['RESP']['EMIT']   := oInfo:_EMIT:_XNOME:TEXT
			oResp['RESP']['PBRUTO'] := oInfo:_TRANSP:_VOL:_PESOB:TEXT
			oResp['RESP']['PLIQU']  := oInfo:_TRANSP:_VOL:_PESOL:TEXT
			oResp['RESP']['QVOL']   := oInfo:_TRANSP:_VOL:_QVOL:TEXT
			oResp['RESP']['VESP']   := oInfo:_TRANSP:_VOL:_ESP:TEXT
			oResp['RESP']['PROD']   := {}
			aItm := oMng:getValue(, .T.)
			for nX := 1 to len(aItm)
				jNw := JsonObject():new()
				jNw['Produto']  := aItm[nX]:_PROD:_XPROD:TEXT
				jNw['Qtd']      := aItm[nX]:_PROD:_QCOM:TEXT
				jNw['Um']       := aItm[nX]:_PROD:_UCOM:TEXT
				aadd(oResp['RESP']['PROD'] , jNw)
			next nX
		else
			oResp['STS'] := .F.
			oResp['MSG'] := oMng:getStsMsg()
		endif
	endif
	FreeObj(oMng)
return oResp

/* Utilizado na SCHEDULE para manifestar ciencia automatica*/
user function zSchCiencia(aSch)
	local oSql      as object
	local aMontXml  as array
	local cCbCpo    as character
	local cRetorno  as character
	local cJust     as character
	local cEmail     as character
	local lEnvOk    as logical
	local oFil		as object
	local aFil      as array
	local nX        as numeric
	Local oStatic   := IfcXFun():newIfcXFun()
	default aSch    := {.F.}

	if aSch[1]
		ConsoleLog('Manifesto de Ciencia da Opera??o')
		RPCClearEnv()
		RPCSetType(3)
		RPCSetEnv('01','01',,,'FAT',GetEnvServer(),{} )
	endif

	oFil := cbcFiliais():newcbcFiliais()

	// Sincronizar as notas emitidas para depois manifestar ciencia
	aFil := StrTokArr(GetNewPar('ZX_FILSYNC', '01;02;03'), ';')
	for nX := 1 to len(aFil)
		oFil:setFilial(aFil[nX])
		JobMani()
		oFil:backFil()
	next nX
	Sleep(GetNewPar('ZX_MLSMAN', 3000))

	lEnvOk      := .F.
	cJust       := ""
	cRetorno    := ""
	cCbCpo      := ""
	aMontXml    := {}
	cEmail      := GetNewPar('ZZ_MNFERR', 'wfti@cobrecom.com.br')

	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(qryToManif())
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			oFil:setFilial(oSql:getValue("FILIAL"))
			aMontXml := {}
			aadd(aMontXml, {01,oSql:getValue("CHAVE")})
			cCbCpo := "2102"+ OP_CIENCIA +"0"
			cRetorno := ''
			if !(lEnvOk := oStatic:sP(4):callStatic('SPEDMANIFE', 'MontaXmlManif',cCbCpo,aMontXml,@cRetorno,cJust))
				ConsoleLog('Ciencia da opera??o erro ao manifestar chave: ' + oSql:getValue("CHAVE") )
				u_SendMail(cEmail,"[ERRO - Manifesto ciencia] - [ CHAVE ]", oSql:getValue("CHAVE"))
			endif
			oSql:skip()
			oFil:backFil()
			Sleep(GetNewPar('ZX_MLSMAN', 3000))
		endDo
	endif
	oSql:close()
	FreeObj(oSql)
	FreeObj(oFil)

	ConsoleLog('Ciencia da opera??o concluido')
	if aSch[1]
		RPCClearEnv()
	endif
return nil
