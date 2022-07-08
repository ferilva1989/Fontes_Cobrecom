#include 'protheus.ch'

class classBolAuth
	data lOk
	data oUser
	data cToken
	data cMsgErro
	data cPIN
	
	method newclassBolAuth() constructor
	
	method isOk()
	method getUserId()
	method getUserPass()
	method getUserUltLog()
	method getUserMail()
	method getUserMobile()
	method getPIN()
	method getAuthToken()
	method getMsgErr()
	method setStatus()
	method setLogin()
	method setUserId()
	method setUserPass()
	method setUserMail()
	method setUserMobile()
	method setPIN()
	method setAuthToken()
	method authToken()
	method changePass()
	method recoveryPass()
	method authRecoveryToken()
	method resetPass()
endclass

method newclassBolAuth() class classBolAuth
	::oUser 	:= JsonObject():new()
	::cToken	:= ''
	::cPIN		:= ''
	::setStatus()	
return(self)

method isOk() class classBolAuth
return(::lOk)

method getUserId() class classBolAuth
	local cId := ''
	
	if !empty(::oUser:GetNames())
		cId	:= ::oUser["id"]
	endif
return(cId)

method getUserPass() class classBolAuth
	local cPass := ''
	
	if !empty(::oUser:GetNames())
		cPass	:= ::oUser["pass"]
	endif
return(cPass)

method getUserUltLog() class classBolAuth
	local cUltLog := ''
	
	if !empty(::oUser:GetNames())
		cUltLog	:= ::oUser["ultlog"]
	endif
return(cUltLog)

method getUserMail() class classBolAuth
	local cMail := ''
	
	if !empty(::oUser:GetNames())
		cMail	:= ::oUser["mail"]
	endif
return(cMail)

method getUserMobile() class classBolAuth
	local cMobile := ''
	
	if !empty(::oUser:GetNames())
		cMobile	:= ::oUser["mobile"]
	endif
return(cMobile)

method getPIN() class classBolAuth
return(::cPIN)

method getAuthToken() class classBolAuth
return(::cToken)

method getMsgErr() class classBolAuth
return(::cMsgErro)

method setStatus(lSts, cMsg, lEx) class classBolAuth
	private lException	:= .F.	
	default lSts		:= .T.
	default cMsg 		:= ''
	default lEx			:= .F.
	
	::lOk				:= lSts
	
	if !lException
		if !lSts
			::cMsgErro	:= '[bolAuth]-' + cMsg
			if lEx
				lException := .T.
				UserException(cMsg)
			endif
		else
			::cMsgErro	:= '[bolAuth]-' + cMsg
		endif
	endif
return(self)

method setLogin(cLogin, cPassword) class classBolAuth
	local aVld := {}
	Local oStatic    	:= IfcXFun():newIfcXFun()
	default cLogin 		:= ''
	default cPassword	:= ''
	
	if !empty(cLogin) .and. !empty(cPassword)
		cLogin 		:= AllTrim(Lower(cLogin))
		cLogin		:= StrTran(cLogin, "'", "")
		cLogin		:= StrTran(cLogin, "-", "") 	
		cPassword	:= AllTrim(cPassword)
		cPassword	:= StrTran(cPassword, "'", "")
		cPassword	:= StrTran(cPassword, "-", "")
		
		aVld := oStatic:sP(2):callStatic('srvBolAuth', 'findByLogin', cLogin, cPassword)
		
		if !aVld[1]
			::setStatus(aVld[1], aVld[2])
		else
			::oUser["id"]		:= cLogin
			::oUser["pass"]		:= cPassword
			::oUser["ultlog"]	:= aVld[4]
			::oUser["mail"]		:= aVld[5]
			::oUser["mobile"]	:= aVld[6]
			oStatic:sP(1):callStatic('srvBolAuth', 'setUltLogin', aVld[3])
		endif
		
	endif
return(self)

method setUserId(cLogin) class classBolAuth
	::oUser["id"]	:= cLogin
return(self)

method setUserPass(cPassword) class classBolAuth
	::oUser["pass"]	:= cPassword
return(self)

method setUserMail(cMail) class classBolAuth
	::oUser["mail"]	:= cMail
return(self)

method setUserMobile(cMobile) class classBolAuth
	::oUser["mobile"] := cMobile
return(self)

method setPIN(cPIN) class classBolAuth
	::cPIN	:= cPIN
return(self)

method setAuthToken() class classBolAuth
	local cId			:= ::getUserId()
	local cTokenPass	:= GetNewPar('ZZ_BOLAUTH', '!token#p@$$w0rd')
	Local oStatic    	:= IfcXFun():newIfcXFun()
	
	if !empty(cId)
		::cToken := oStatic:sP(2):callStatic('srvBolAuth', 'createToken', cId, cTokenPass)
	endif
return(self)

method authToken(cToken) class classBolAuth
	local aVld			:= {}
	local cTokenPass	:= GetNewPar('ZZ_BOLAUTH', '!token#p@$$w0rd')
	Local oStatic    	:= IfcXFun():newIfcXFun()
	
	default cToken 		:= ''
		
	aVld := oStatic:sP(2):callStatic('srvBolAuth', 'validToken', cToken, cTokenPass)
	::setStatus(aVld[1], aVld[2] + ' id: ' + cValToChar(aVld[3]))
	if aVld[1]
		::setUserId(cValToChar(aVld[3]))
	endif
return(self)

method changePass(cNewPass, cNewMail, cMobile) class classBolAuth
	local aVld := oStatic:sP(4):callStatic('srvBolAuth', 'changePass', ::getUserId(),cNewPass, cNewMail, cMobile)
	::setStatus(aVld[1], aVld[2])
return(self)

method recoveryPass(cId) class classBolAuth
	Local oStatic    := IfcXFun():newIfcXFun()
	local aVld := oStatic:sP(1):callStatic('srvBolAuth', 'recoveryPass', cId)
	::setStatus(aVld[1], aVld[2])
return(self)

method authRecoveryToken(cRecToken) class classBolAuth
	local cTokenPass	:= GetNewPar('ZZ_BOLAUTH', '!token#p@$$w0rd')
	local aVld 			:= {}
	Local oStatic		:= IfcXFun():newIfcXFun()
	
	aVld := oStatic:sP(2):callStatic('srvBolAuth', 'validRecoveryToken', cRecToken, cTokenPass)
	::setStatus(aVld[1], aVld[2])
	if aVld[1]
		::setUserId(cValToChar(aVld[3]))
		::setPIN(cValToChar(aVld[4]))
	endif
return(self)

method resetPass(cRecToken, cNewPass) class classBolAuth
	local aVld 		:= {}
	Local oStatic   := IfcXFun():newIfcXFun()
	
	if(::authRecoveryToken(cRecToken):isOk())
		aVld := oStatic:sP(3):callStatic('srvBolAuth', 'resetPass', ::getUserId(), ::getPIN(), cNewPass)
		::setStatus(aVld[1], aVld[2])
	endif
return(self)
