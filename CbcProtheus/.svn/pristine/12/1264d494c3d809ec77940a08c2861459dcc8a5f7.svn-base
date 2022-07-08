#include 'protheus.ch'

class cbcJwtAuth 
	data aResult
    data defKey
	
	method newcbcJwtAuth() constructor 
	method toJson()
	method gerToken()
	method vldToken()
endclass

method newcbcJwtAuth() class cbcJwtAuth
    ::defKey	:= GetNewPar('ZZ_JWTKEY','COBRECOM_IFC##@@45cbFonte' )
    ::aResult := {.F., 'Sem validacao'}
return self

method gerToken(cInfoPay, nDayToExp, cKey ) class cbcJwtAuth
	local cTk			:= ''
	local cHj			:= ''
	local cDtEx			:= '' 
	local cHeader		:= ''
	local cPayload		:= '' 
    local oJsPay        := JsonObject():new()
	local cAssinat		:= ''
    local nSHA256		:= 5
	local nHexRet		:= 1
    default cInfoPay	:= '{"user": "defaultInfo"}'
	default nDayToExp	:= 1
	default cKey		:= ::defKey
    
    cHj	            := FWTimeStamp(4, Date(), Time())
    cDtEx           := FWTimeStamp(4, DaySum(Date(), nDayToExp), Time()) 
    cHeader	        := '{"typ":"JWT","alg":"HS256"}' 
    oJsPay['user']  := cInfoPay
    oJsPay['iat']   := cHj
    oJsPay['exp']   := cDtEx
    oJsPay['iss']   := "ifc-cobrecom"
    cPayload	    := oJsPay:toJson()
    cAssinat        := HMAC( Encode64(cHeader) + "." +  Encode64(cPayload), cKey, nSHA256, nHexRet)
    cTk             := Encode64(cHeader) + "." + Encode64(cPayload) + "." + Encode64(cAssinat)
    freeobj(oJsPay)
return cTk


method vldToken(cToken, cKey) class cbcJwtAuth
    local aTk       := {}
    local cAssinat  := ''
    local cVldAss   := ''
    local nSHA256	:= 5
	local nHexRet	:= 1
    local oJsPay    := JsonObject():new()
    default cKey    := ::defKey
    ::aResult        := {.T., 'OK'}
    aTk             := StrTokArr(cToken, ".") 
    if len(aTk) != 3
        ::aResult[1] := .F.
        ::aResult[2] := 'Token Invalido'
    else
        cAssinat        := decode64(aTk[3])
        cVldAss         := HMAC( aTk[1] + "." +  aTk[2], cKey, nSHA256, nHexRet)
        if cAssinat != cVldAss
        ::aResult[1] := .F.
           ::aResult[2] := 'Assinatura invalida'
        else
            oJsPay:fromJson(decode64(aTk[2]))
            if oJsPay['exp'] < FWTimeStamp(4,Date(),Time()) 
                ::aResult[1] := .F.
                ::aResult[2] := 'Token Expirou, realize novo login'
            endif
        endif
    endif
return ::aResult


/* TEST ZONE */
user function zcbJwttst()
    local oJwt  := cbcJwtAuth():newcbcJwtAuth()
    cToken      := oJwt:gerToken('payload', 5)
    oJwt:vldToken(cToken)
    if(oJwt:aResult[1])
        MsgInfo('ok')
    else  
        alert(oJwt:aResult[2])
    endif
    FreeObj(oJwt)
return nil
