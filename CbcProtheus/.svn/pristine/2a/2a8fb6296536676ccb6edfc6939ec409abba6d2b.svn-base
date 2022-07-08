#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"

User Function _NQOFGWO ; Return


WSCLIENT cbcCadWs

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD consulta

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWS                       AS SCHEMA
	WSDATA   cUF                       AS String
	WSDATA   cCNPJ                     AS String
	WSDATA   cIDEmp					   AS String

ENDWSCLIENT

WSMETHOD NEW WSCLIENT cbcCadWs
	::Init()
Return Self

WSMETHOD INIT WSCLIENT cbcCadWs
	::oWS                := NIL 
Return

WSMETHOD RESET WSCLIENT cbcCadWs
	::oWS                := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT cbcCadWs
	local oClone := cbcCadWs():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
Return oClone


WSMETHOD consulta WSSEND cUF,cCNPJ, cIDEmp WSRECEIVE NULLPARAM WSCLIENT cbcCadWs
	local cSoap := "" , oXmlRet
    local cUr  := ::_URL

	BEGIN WSMETHOD

	cSoap += '<CONSULTACONTRIBUINTE xmlns="http://webservices.totvs.com.br/nfsebra.apw">'
	cSoap += WSSoapValue("USERTOKEN",, 'TOTVS' , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("ID_ENT",::cIDEmp, cIDEmp, "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("UF",   ::cUF, cUF , "string", .T. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CNPJ", ::cCNPJ, cCNPJ , "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("CPF",,, "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += WSSoapValue("IE",,, "string", .F. , .F., 0 , NIL, .F.,.F.) 
	cSoap += "</CONSULTACONTRIBUINTE>"

	oXmlRet := SvcSoapCall(Self,cSoap,; 
		"http://webservices.totvs.com.br/nfsebra.apw/CONSULTACONTRIBUINTE",; 
		"DOCUMENT","http://webservices.totvs.com.br/nfsebra.apw",,"1.031217",cUr)

	::Init()
	::oWS   :=  WSAdvValue( oXmlRet,"_CONSULTACONTRIBUINTERESPONSE:_CONSULTACONTRIBUINTERESULT:_NFECONSULTACONTRIBUINTE","Object") 
	END WSMETHOD
	oXmlRet := NIL
Return .T.

