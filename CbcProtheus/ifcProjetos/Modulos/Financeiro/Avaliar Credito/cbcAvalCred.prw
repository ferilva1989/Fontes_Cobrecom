/*User Function MAAVCRED()
    Local lRet  := .F.

	lRet := libCred()
	// Conout(xFilial("SC6") + ' - ' + SC6->C6_NUM + ' - ' + SC6->C6_ITEM)
Return lRet*/

Static Function libCred()
	Local lRet 	   := .F.
	Local aHeader  := { 'Content-Type: application/json' }
	Local aArea    := GetArea()
    Local aAreaSC5 := SC5->(GetArea())
	Local aParam   := StrTokArr(GetNewPar('ZZ_APICRED', 'https://192.168.1.25:6235/;0'), ';')
	Local oRest    := Nil
    Local oRet     := JsonObject():New()
	Local oBody    := JsonObject():New()
	Local cCGC	   := Posicione("SA1", 1, xFilial("SA1")+SC5->(C5_CLIENTE)+SC5->(C5_LOJACLI), "A1_CGC")
	Local cBody	   := ''
	Local cFile	   := '\LibFin\' + xFilial("SC5")+SC5->C5_NUM + '_' + DtoS(Date())

	if Posicione("SA1", 1, xFilial("SA1")+SC5->(C5_CLIENTE)+SC5->(C5_LOJACLI), "A1_RISCO") == "A"
		lRet  := .T.
	else
		oRest := FWRest():New(aParam[1])
		oRest:setPath("api/consulta")
		oBody['cnpj'] := cCGC
		oBody['valorCredito'] := SC5->(C5_TOTAL)
		oBody['score'] :=  'true'
		cBody := oBody:ToJson()
		oRest:SetPostParams(cBody)
		if oRest:Post(aHeader)
			oRet:fromJson(oRest:GetResult())
			if  oRet['score'] <= Val(aParam[2])
				lRet  := .T.
				saveLog('Aprovado Automatico: ' + oRest:GetResult(), cFile + '_Aprovado.txt')
			else
				saveLog('Bloqueado: ' + oRest:GetResult(), cFile + '.txt')
				lRet  := .F.
			endif
		else
			MsgInfo(oRest:GetLastError(), 'Erro')
		endif
	endif
    FreeObj(oRest)
	FreeObj(oRet)
	FreeObj(oBody)
	RestArea(aAreaSC5)
    RestArea(aArea)
Return lRet

static function saveLog(cTxt, cFile)
	Local oFile as object
	oFile := LibFileObj():newLibFileObj(cFile)

	if oFile:exists()
		oFile:delete()
	endIf	
  
	lOk	:= oFile:writeLine(cTxt)
  
	oFile:close()
	FreeObj(oFile)
Return (Nil)

User Function zCbcWebCred(cCgc, nVal)
	Local oCbcCredErp 	:= Nil
    Local aParam        := StrTokArr(GetNewPar('ZZ_APICRED', 'https://192.168.1.25:6235/;0;protheus2WrgIFCcbc2022M3rdacobre1020'), ';')
	Local aValPeds		:= {}
	Local cInput		:= ''
	Local cUrl			:= ''
	Local nX			:= 0
	Local nPos			:= 0
    Private oWebEngine  := Nil 
    Private oModal      := Nil

	if FUNNAME() == 'MATA450A'
		oCbcCredErp := cbcCredErp():newccbcCredErp(cCgc)
		aValPeds := oCbcCredErp:getValped()
		if !Empty(aValPeds)
			for nX := 1 to Len(aValPeds)
				nVal += aValPeds[nX][3][2]
			next
		endif
	else
		cCgc := Posicione("SA1",1,xFilial("SA1")+SC9->(C9_CLIENTE)+SC9->(C9_LOJA),"A1_CGC")
		oCbcCredErp := cbcCredErp():newccbcCredErp(cCgc)
		aValPeds := oCbcCredErp:getValped()
		if !Empty(aValPeds)
			nPos := AScan(aValPeds, { |x| x[1][2] == SC9->(C9_FILIAL) .And. x[2][2] == SC9->(C9_PEDIDO) })
			nVal := aValPeds[nPos][3][2]
		endif
	endif
	
	cInput := "?cnpj=" + cCgc + "&valor=" + cValToChar(nVal)
	cUrl   := aParam[1] + iif(!EMPTY(aParam[3]), aParam[3], '') + cInput

    oModal  := FWDialogModal():New()
    oModal:SetEscClose(.T.)
    oModal:setTitle("Consulta Avaliacao de Credito")
    oModal:setSize(350, 600)
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    oWebEngine := TWebEngine():New(oModal:getPanelMain(), 0, 0, 100, 100)
    oWebEngine:navigate(cUrl)
    oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
    oModal:Activate()
    FreeObj(oModal)
    FreeObj(oWebEngine)
Return (Nil)
