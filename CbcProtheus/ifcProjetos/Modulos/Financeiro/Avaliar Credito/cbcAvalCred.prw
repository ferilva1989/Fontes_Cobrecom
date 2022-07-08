/* User Function MAAVCRED()
    Local lRet  := .F.
	Local bErro := ErrorBlock({|oErr| HandleEr(oErr)})

	BEGIN TRANSACTION
		lRet := libCred(SC5->(Recno()))
	RECOVER
    	lRet := .F.
    END SEQUENCE
	ErrorBlock(bErro)
Return lRet */

Static Function libCred(nRec)
	Local lRet 	   := .F.
	Local aHeader  := { 'Content-Type: application/json' }
	Local aArea    := GetArea()
    Local aAreaSC5 := SC5->(GetArea())
	Local aParam   := StrTokArr(GetNewPar('ZZ_APICRED', 'https://192.168.1.25:6235/api;0'), ';')
	Local oRest    := Nil
    Local oRet     := JsonObject():New()
	Local oBody    := JsonObject():New()
	Local cCGC	   := Posicione("SA1", 1, xFilial("SA1")+SC5->(C5_CLIENTE)+SC5->(C5_LOJACLI), "A1_CGC")
	Local cBody	   := ''

	DbSelectArea("SC5")
	SC5->(DbGoTo(nRec))

	if Posicione("SA1", 1, xFilial("SA1")+SC5->(C5_CLIENTE)+SC5->(C5_LOJACLI), "A1_RISCO") == "A"
		lRet  := .T.
	else
		oRest := FWRest():New(aParam[1])
		oRest:setPath("/consulta")
		oBody['cnpj'] := cCGC
		oBody['valorCredito'] := SC5->(C5_TOTAL)
		oBody['score'] :=  'true'
		cBody := oBody:ToJson()
		oRest:SetPostParams(cBody)
		if oRest:Post(aHeader)
			oRet:fromJson(oRest:GetResult())
			if  oRet['score'] <= Val(aParam[2])
				lRet  := .T.
			endif
		else
			MsgInfo(oRest:GetLastError(), 'Erro')
		endif
	endif
    FreeObj(oRest)
	RestArea(aAreaSC5)
    RestArea(aArea)
Return lRet

static function HandleEr(oErr)
	if InTransact()
        DisarmTransaction()
    endif
    MsgInfo(oErr:Description, 'Erro')
    BREAK
return 
