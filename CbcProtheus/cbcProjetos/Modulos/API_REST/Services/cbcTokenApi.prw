#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcTokenApi(cInfoPay, nDayToExp, cKey)
	
	local cTk			:= ''
	local cHj			:= ''
	local cDtEx			:= '' 
	local cHeader		:= ''
	local cPayload		:= '' 
	local cAssinat		:= ''
	local nSHA256		:= 5
	local nHexRet		:= 1
	default cInfoPay	:= '{"user": "defaultInfo"}'
	default nDayToExp	:= 1
	default cKey		:= GetNewPar('ZZ_JWTKEY','COBRECOM_IFC##@@45cbFonte' )
	
	cHj			:= FWTimeStamp(4, Date(), Time())
	cDtEx 		:= FWTimeStamp(4, DaySum(Date(), nDayToExp), Time()) 
	cHeader		:= '{"typ":"JWT","alg":"HS256"}' 
	cPayload	:= '{"user": ' + cInfoPay + ',"iat":' + cHj  + ',"exp":' + cDtEx + ',"iss":"ifc-cobrecom"}'
	
	cAssinat := HMAC( Encode64(cHeader) + "." +  Encode64(cPayload), cKey, nSHA256, nHexRet)
	cTk := Encode64(cHeader) + "." + Encode64(cPayload) + "." + Encode64(cAssinat)

return(cTk)
