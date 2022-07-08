#include 'protheus.ch'
#include 'parmtype.ch'

static function findByLogin(cLogin, cPassword)
	local aRet	:= {.F., 'Usuario ou senha invalido!',0,''}
	local oUser := nil
	local oSql	:= LibSqlObj():newLibSqlObj()

	if (Empty(cLogin) .or. Empty(cPassword))
		aRet := {.F., 'Informar usuario e senha',0,''}
	endIf
	
	cLogin 		:= AllTrim(Lower(cLogin))
	cLogin		:= StrTran(cLogin, "'", "")
	cLogin		:= StrTran(cLogin, "-", "") 	
	cPassword	:= AllTrim(cPassword)
	cPassword	:= StrTran(cPassword, "'", "")
	cPassword	:= StrTran(cPassword, "-", "")
	
	oSql:newTable("ZAT", "*", "%ZAT.XFILIAL% AND ZAT_CODIGO LIKE '"+cLogin+"' AND ZAT_SENHA = '"+cPassword+"'") 
	
	if oSql:hasRecords()
		oSql:goTop()
		if oSql:getValue("ZAT_MSBLQL") == '1'
			aRet	:= {.F., 'Usuario bloqueado!',0,''}
		else
			aRet	:= {.T., 'Acesso Liberado!', oSql:getValue("R_E_C_N_O_"), AllTrim(oSql:getValue("ZAT_ULTLOG")),; 
											AllTrim(oSql:getValue("ZAT_EMAIL")), AllTrim(oSql:getValue("ZAT_MOBILE"))}
		endif
	endIf
	oSql:close()
	FreeObj(oSql)
return(aRet)

static function setUltLogin(nRec)
	local oSql	:= LibSqlObj():newLibSqlObj()
	
	oSql:update("ZAT", "ZAT_ULTLOG = '"+DtoS(Date())+"'", "%ZAT.XFILIAL% AND R_E_C_N_O_= " + cValToChar(nRec))
	
	oSql:close()
	FreeObj(oSql) 
return(nil)

static function createToken(cKey, cTokenPass, nDaysToExp)
	local oPayload := JsonObject():new()
	local oJwt	   := LibJwtObj():newLibJwtObj()
	local cToken   := ''
	
	default nDaysToExp	:= 1
	
	if !empty(cKey) .and. !empty(cTokenPass)
		oPayload["id"]    := cKey
		oPayload["createdAt"] := DtoS(dDatabase)
		oPayload["expiresAt"] := DtoS(dDatabase + nDaysToExp)
		cToken := oJwt:encode(oPayload:toJson(), cTokenPass)
	endif
return(cToken)

static function validToken(cToken, cTokenPass)
	local cData		 	:= ""
	local dExpiresAt 	:= CtoD("")
	local lRet			:= .F.
	local cMsgErr		:= ''
	local cId			:= ''
	local oPayload	 	:= JsonObject():new()
	local oJwt	     	:= LibJwtObj():newLibJwtObj()
	local aRet			:= {}
		
	if Empty(cToken)
		lRet 	:= .F.
		cMsgErr	:= 'Token nao enviado!'	
	else
		cData := oJwt:decode(cToken, cTokenPass)
		if Empty(cData)
			lRet	:= .F.
			cMsgErr	:= 'Token invalido!'
		else		
			oPayload:fromJson(cData)				
			dExpiresAt := StoD(oPayload["expiresAt"])			
			if (dExpiresAt <= dDatabase)
				lRet	:= .F.
				cMsgErr	:= 'Token Expirado!!'
			else 
				lRet	:= .T.
				cMsgErr := 'Token Autenticado!'
				cId		:= oPayload["id"]
			endIf
		endIf
	endIf
	aRet := {lRet, cMsgErr, cId}
return(aRet)

static function getTitles(cId)
	local oJson 	:= JsonObject():new()
	local cQry		:= ''
	Local oStatic	:= IfcXFun():newIfcXFun()
		
	if !empty(cQry 	:= oStatic:sP(1):callStatic('qryBoletos', 'qryGetTitles', cId))
		oJson 	:= u_cbcQRYexec(cQry)
	endif
return(oJson)

static function changePass (cId, cNewPass, cNewMail, cMobile)
	local lRet		:= .F.
	local cMsgErr	:= ''
	local aRet		:= {}
	local oSql		:= LibSqlObj():newLibSqlObj()
	local aFld		:= {}
	
	default cNewMail	:= ''
	default cMobile		:= ''
	
	oSql:newTable("ZAT", "*", "%ZAT.XFILIAL% AND ZAT_CODIGO = '" + cId + "' AND ZAT_MSBLQL = '2'")
	if(lRet := oSql:hasRecords())
		oSql:goTop()
		aAdd(aFld, {'ZAT_SENHA', cNewPass})
		if !empty(cNewMail)
			aAdd(aFld, {'ZAT_EMAIL', cNewMail})
		endif
		if !empty(cMobile)
			aAdd(aFld, {'ZAT_MOBILE', cMobile})
		endif
		aRet := updZAT(aFld, oSql:getValue("R_E_C_N_O_"))
	else
		cMsgErr := 'Usuario nao localizado!'
		aRet := {lRet, cMsgErr}
	endIf
	oSql:close()
	FreeObj(oSql)
return(aRet)

static function updZAT(aFldVlr, nRecZAT)
	local aArea			:= getArea()
	local aAreaZAT		:= ZAT->(getArea())
	local ocbcMdlCtrl	:= nil
	local oZATModel		:= nil
	local aErr			:= {}
	local cErro			:= ''
	local lRet			:= .T.
	
	default aFldVlr 	:= {}
	default nRecZAT		:= 0
	
	if !empty(aFldVlr) .and. !empty(nRecZAT)
		dbSelectArea('ZAT')
		ZAT->(DbGoTo(nRecZAT))
		ocbcMdlCtrl := cbcMdlCtrl():newcbcMdlCtrl()
		ocbcMdlCtrl:setInitSet('ZATMASTER', 'cbcZATModel', 'ZAT')
		oZATModel 	:= ocbcMdlCtrl:getNewModel('UPDATE')
		ocbcMdlCtrl:setVlrModel(oZATModel,aFldVlr)
		if ! ocbcMdlCtrl:SaveAModel(oZATModel):isOk()
			aErr := ocbcMdlCtrl:getErro()
			cErro += aErr[2] + '-'
			cErro += aErr[4] + '-'
			cErro += aErr[5] + '-'
			cErro += aErr[6] 
			//Help( ,, cErro ,, 'Erro', 1,0)
			lRet := .F.
		endif
	endif	
	FreeObj(ocbcMdlCtrl)
	FreeObj(oZATModel)
	RestArea(aAreaZAT)
	RestArea(aArea)
return({lRet, cErro})

static function recoveryPass(cId)
	local oSql			:= LibSqlObj():newLibSqlObj()
	local lRet			:= .F.
	local cMsgErr		:= ''
	local cLinha		:= '<br>'
	local cBody			:= ''
	local cFrontRoute	:= GetNewPar('ZZ_BOLLINK', 'http://192.168.1.220:8000')
	local cToken		:= ''
	
	oSql:newTable("ZAT", "*", "%ZAT.XFILIAL% AND ZAT_CODIGO = '" + cId + "' AND ZAT_MSBLQL = '2'")
	if(lRet := (oSql:hasRecords()))
		oSql:goTop()
		if!(lRet := !(empty(oSql:getValue("ZAT_EMAIL"))))
			cMsgErr := 'Email nao cadastrado para recuperacao!'
		else
			if !(lRet := !(empty(cToken := genarateRecoveryToken(oSql:getValue("ZAT_CODIGO"), oSql:getValue("ZAT_SENHA"),,1))))
				cMsgErr := 'Erro na geracao do Token de Recuperacao!'
			else
				cBody += 'IFC - Sistema de Boletos' 											+ cLinha
				cBody += 'Dados de acesso' 														+ cLinha
				cBody += 'Usuario: '	+ AllTrim(cValtoChar(oSql:getValue("ZAT_CODIGO")))		+ cLinha
				cBody += 'Ult.Acesso: ' + CtoD(StoD(cValtoChar(oSql:getValue("ZAT_ULTLOG")))) 	+ cLinha
				cBody += 'Link para recuperacao: ' + cFrontRoute + '/recpass?tkn=' + cToken  	+ cLinha
				u_SendMail(oSql:getValue("ZAT_EMAIL"),"[IFC - Sistema de Boletos] - Recuperacao de senha.", cBody)
			endif
		endif
	else
		cMsgErr := 'Usuario nao encontrado!'
	endif
	oSql:close()
	FreeObj(oSql)
return({lRet, cMsgErr})

static function genarateRecoveryToken(cId, cPass, cTokenPass, nDaysToExp)
	local cRecToken 	:= ''
	local oSql			:= LibSqlObj():newLibSqlObj()
	local cPin			:= ''
	local aFld			:= {}
	local oPayload 		:= JsonObject():new()
	local oJwt	   		:= LibJwtObj():newLibJwtObj()
	
	default cTokenPass	:= GetNewPar('ZZ_BOLAUTH', '!token#p@$$w0rd')	
	default nDaysToExp	:= 1
	
	if !(Empty(cId) .and. !Empty(cPass))
		oSql:newTable("ZAT", "*", "%ZAT.XFILIAL% AND ZAT_CODIGO LIKE '"+cId+"' AND ZAT_SENHA = '"+cPass+"'")	
		if oSql:hasRecords()
			oSql:goTop()
			cPin := genaratePIN()
			aAdd(aFld, {'ZAT_PIN', cPin})
			if(updZAT(aFld, oSql:getValue("R_E_C_N_O_"))[1])
				oPayload["id"]    		:= cId
				oPayload["createdAt"] 	:= DtoS(dDatabase)
				oPayload["expiresAt"] 	:= DtoS(dDatabase + nDaysToExp)
				oPayload["pin"] 		:= cPin
				cRecToken := oJwt:encode(oPayload:toJson(), cTokenPass)
			endif
		endIf
		oSql:close()
	endIf
	
	FreeObj(oSql)
return(cRecToken)

static function genaratePIN()
	local aBase		:= {}
	local cPIN 		:= ''
	local cChar		:= ''
	local nTamPin 	:= GetNewPar('ZZ_BOLTPIN', 6)
	
	while len(cPIN) < nTamPin
		cChar := CHR(Randomize(48, 126))
		if IsDigit(cChar) .or. IsAlpha(cChar)
			cPIN += cChar
		endif
		if len(cPIN) == nTamPin
			if hasThisPin(cPIN)
				cPIN := ''
			endif
		endif
	endDo
		
return(cPIN)

static function validRecoveryToken(cToken, cTokenPass)
	local cData		 	:= ""
	local dExpiresAt 	:= CtoD("")
	local lRet			:= .F.
	local cMsgErr		:= ''
	local cId			:= ''
	local oPayload	 	:= JsonObject():new()
	local oJwt	     	:= LibJwtObj():newLibJwtObj()
	local aRet			:= {}
	local cPin			:= ''
	
	default cTokenPass	:= GetNewPar('ZZ_BOLAUTH', '!token#p@$$w0rd')	
		
	if Empty(cToken)
		lRet 	:= .F.
		cMsgErr	:= 'Token nao enviado!'	
	else
		cData := oJwt:decode(cToken, cTokenPass)
		if Empty(cData)
			lRet	:= .F.
			cMsgErr	:= 'Token invalido!'
		else		
			oPayload:fromJson(cData)				
			dExpiresAt := StoD(oPayload["expiresAt"])			
			if (dExpiresAt <= dDatabase)
				lRet	:= .F.
				cMsgErr	:= 'Token Expirado!!'
			else				
				if !(lRet := hasThisPin(oPayload["pin"], oPayload["id"]))
					cMsgErr	:= 'PIN invalido!'
				else
					lRet	:= .T.
					cMsgErr := 'Token Autenticado!'
					cId		:= oPayload["id"]
					cPin	:= oPayload["pin"]
				endif
			endIf
		endIf
	endIf
	aRet := {lRet, cMsgErr, cId, cPin}
return(aRet)

static function hasThisPin(cPIN, cId, nRecZat)
	local oSql 	:= LibSqlObj():newLibSqlObj()
	local lHas	:= .F.
	local cWhere:= "%ZAT.XFILIAL% AND ZAT_PIN = '"+cPIN+"'"
	
	default cId		:= ''
	default nRecZat	:= 0
	
	if !empty(cId)
		cWhere += " AND ZAT_CODIGO = '" + cId + "'"
	endif
	oSql:newTable("ZAT", "*", cWhere)
	if (lHas := oSql:hasRecords())
		nRecZat := oSql:getValue("R_E_C_N_O_")
	endif
	oSql:close()
	FreeObj(oSql)
return(lHas)

static function resetPass(cId, cPIN, cNewPass)
	local aRet		:= {}
	local lRet		:= ''
	local nRecZAT	:= 0
	local cMsgErr	:= ''
	local aFld		:= {}
	
	if !(hasThisPin(cPIN, cId, @nRecZAT))
		aRet := {.F., 'PIN de recuperacao nao localizado!'}
	else
		aAdd(aFld, {'ZAT_SENHA', cNewPass})
		aAdd(aFld, {'ZAT_PIN', ''})
		aRet := updZAT(aFld, nRecZAT)
	endif
return(aRet)

/* TESTE ZONE */
user function ztstZonesrvBolAuth(xVari)
	//local aRet := recoveryPass('10280765')
	for nX := 1 to 10
		msgInfo(genaratePIN(), 'PIN')
	next nX
return(nil)
