#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"


User Function _ONTKDJP ; Return

/* -------------------------------------------------------------------------------
WSDL Service WSSaoPauloNFSE
------------------------------------------------------------------------------- */
WSCLIENT WSSaoPauloNFSE

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD EnvioRPS
	WSMETHOD EnvioLoteRPS
	WSMETHOD TesteEnvioLoteRPS
	WSMETHOD CancelamentoNFe
	WSMETHOD ConsultaNFe
	WSMETHOD ConsultaNFeRecebidas
	WSMETHOD ConsultaNFeEmitidas
	WSMETHOD ConsultaLote
	WSMETHOD ConsultaInformacoesLote
	WSMETHOD ConsultaCNPJ

	WSDATA   _URL                      AS String
	WSDATA   _CERT                     AS String
	WSDATA   _PRIVKEY                  AS String
	WSDATA   _PASSPHRASE               AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   nVersaoSchema             AS int
	WSDATA   cMensagemXML              AS string
	WSDATA   cRetornoXML               AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSSaoPauloNFSE
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.191205P-20210114] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSSaoPauloNFSE
Return

WSMETHOD RESET WSCLIENT WSSaoPauloNFSE
	::nVersaoSchema      := NIL 
	::cMensagemXML       := NIL 
	::cRetornoXML        := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSSaoPauloNFSE
Local oClone := WSSaoPauloNFSE():New()
	oClone:_URL          := ::_URL 
	oClone:_CERT         := ::_CERT 
	oClone:_PRIVKEY      := ::_PRIVKEY 
	oClone:_PASSPHRASE   := ::_PASSPHRASE 
	oClone:nVersaoSchema := ::nVersaoSchema
	oClone:cMensagemXML  := ::cMensagemXML
	oClone:cRetornoXML   := ::cRetornoXML
Return oClone

// WSDL Method EnvioRPS of Service WSSaoPauloNFSE

WSMETHOD EnvioRPS WSSEND nVersaoSchema,cMensagemXML WSRECEIVE cRetornoXML WSCLIENT WSSaoPauloNFSE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EnvioRPSRequest xmlns="http://www.prefeitura.sp.gov.br/nfe">'
cSoap += WSSoapValue("VersaoSchema", ::nVersaoSchema, nVersaoSchema , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MensagemXML", ::cMensagemXML, cMensagemXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</EnvioRPSRequest>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.prefeitura.sp.gov.br/nfe/ws/envioRPS",; 
	"DOCUMENT","http://www.prefeitura.sp.gov.br/nfe",,,; 
	"https://nfe.prefeitura.sp.gov.br/ws/lotenfe.asmx")

::Init()
::cRetornoXML        :=  WSAdvValue( oXmlRet,"_ENVIORPSRESPONSE:_RETORNOXML:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method EnvioLoteRPS of Service WSSaoPauloNFSE

WSMETHOD EnvioLoteRPS WSSEND nVersaoSchema,cMensagemXML WSRECEIVE cRetornoXML WSCLIENT WSSaoPauloNFSE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<EnvioLoteRPSRequest xmlns="http://www.prefeitura.sp.gov.br/nfe">'
cSoap += WSSoapValue("VersaoSchema", ::nVersaoSchema, nVersaoSchema , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MensagemXML", ::cMensagemXML, cMensagemXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</EnvioLoteRPSRequest>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.prefeitura.sp.gov.br/nfe/ws/envioLoteRPS",; 
	"DOCUMENT","http://www.prefeitura.sp.gov.br/nfe",,,; 
	"https://nfe.prefeitura.sp.gov.br/ws/lotenfe.asmx")

::Init()
::cRetornoXML        :=  WSAdvValue( oXmlRet,"_ENVIOLOTERPSRESPONSE:_RETORNOXML:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method TesteEnvioLoteRPS of Service WSSaoPauloNFSE

WSMETHOD TesteEnvioLoteRPS WSSEND nVersaoSchema,cMensagemXML WSRECEIVE cRetornoXML WSCLIENT WSSaoPauloNFSE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<TesteEnvioLoteRPSRequest xmlns="http://www.prefeitura.sp.gov.br/nfe">'
cSoap += WSSoapValue("VersaoSchema", ::nVersaoSchema, nVersaoSchema , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MensagemXML", ::cMensagemXML, cMensagemXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</TesteEnvioLoteRPSRequest>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.prefeitura.sp.gov.br/nfe/ws/testeenvio",; 
	"DOCUMENT","http://www.prefeitura.sp.gov.br/nfe",,,; 
	"https://nfe.prefeitura.sp.gov.br/ws/lotenfe.asmx")

::Init()
::cRetornoXML        :=  WSAdvValue( oXmlRet,"_TESTEENVIOLOTERPSRESPONSE:_RETORNOXML:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method CancelamentoNFe of Service WSSaoPauloNFSE

WSMETHOD CancelamentoNFe WSSEND nVersaoSchema,cMensagemXML WSRECEIVE cRetornoXML WSCLIENT WSSaoPauloNFSE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<CancelamentoNFeRequest xmlns="http://www.prefeitura.sp.gov.br/nfe">'
cSoap += WSSoapValue("VersaoSchema", ::nVersaoSchema, nVersaoSchema , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MensagemXML", ::cMensagemXML, cMensagemXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</CancelamentoNFeRequest>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.prefeitura.sp.gov.br/nfe/ws/cancelamentoNFe",; 
	"DOCUMENT","http://www.prefeitura.sp.gov.br/nfe",,,; 
	"https://nfe.prefeitura.sp.gov.br/ws/lotenfe.asmx")

::Init()
::cRetornoXML        :=  WSAdvValue( oXmlRet,"_CANCELAMENTONFERESPONSE:_RETORNOXML:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaNFe of Service WSSaoPauloNFSE

WSMETHOD ConsultaNFe WSSEND nVersaoSchema,cMensagemXML WSRECEIVE cRetornoXML WSCLIENT WSSaoPauloNFSE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaNFeRequest xmlns="http://www.prefeitura.sp.gov.br/nfe">'
cSoap += WSSoapValue("VersaoSchema", ::nVersaoSchema, nVersaoSchema , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MensagemXML", ::cMensagemXML, cMensagemXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultaNFeRequest>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.prefeitura.sp.gov.br/nfe/ws/consultaNFe",; 
	"DOCUMENT","http://www.prefeitura.sp.gov.br/nfe",,,; 
	"https://nfe.prefeitura.sp.gov.br/ws/lotenfe.asmx")

::Init()
::cRetornoXML        :=  WSAdvValue( oXmlRet,"_CONSULTANFERESPONSE:_RETORNOXML:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaNFeRecebidas of Service WSSaoPauloNFSE

WSMETHOD ConsultaNFeRecebidas WSSEND nVersaoSchema,cMensagemXML WSRECEIVE cRetornoXML WSCLIENT WSSaoPauloNFSE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

msgAssig := strtran(strtran(u_cbcSignXml('<MensagemXML>'+cMensagemXML+'</MensagemXML>'), '<MensagemXML>', ''),'</MensagemXML>','')

cSoap += '<ConsultaNFeRecebidasRequest xmlns="http://www.prefeitura.sp.gov.br/nfe">'
cSoap += WSSoapValue("VersaoSchema", ::nVersaoSchema, nVersaoSchema , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MensagemXML", ::cMensagemXML, msgAssig , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultaNFeRecebidasRequest>"


oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.prefeitura.sp.gov.br/nfe/ws/consultaNFeRecebidas",; 
	"DOCUMENT","http://www.prefeitura.sp.gov.br/nfe",,,; 
	"https://nfe.prefeitura.sp.gov.br/ws/lotenfe.asmx")

::Init()
::cRetornoXML  :=  WSAdvValue( oXmlRet,"_CONSULTANFERECEBIDASRESPONSE:_RETORNOXML:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD
// GetWSCError()
oXmlRet := NIL
Return .T.

// WSDL Method ConsultaNFeEmitidas of Service WSSaoPauloNFSE

WSMETHOD ConsultaNFeEmitidas WSSEND nVersaoSchema,cMensagemXML WSRECEIVE cRetornoXML WSCLIENT WSSaoPauloNFSE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaNFeEmitidasRequest xmlns="http://www.prefeitura.sp.gov.br/nfe">'
cSoap += WSSoapValue("VersaoSchema", ::nVersaoSchema, nVersaoSchema , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MensagemXML", ::cMensagemXML, cMensagemXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultaNFeEmitidasRequest>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.prefeitura.sp.gov.br/nfe/ws/consultaNFeEmitidas",; 
	"DOCUMENT","http://www.prefeitura.sp.gov.br/nfe",,,; 
	"https://nfe.prefeitura.sp.gov.br/ws/lotenfe.asmx")

::Init()
::cRetornoXML        :=  WSAdvValue( oXmlRet,"_CONSULTANFEEMITIDASRESPONSE:_RETORNOXML:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaLote of Service WSSaoPauloNFSE

WSMETHOD ConsultaLote WSSEND nVersaoSchema,cMensagemXML WSRECEIVE cRetornoXML WSCLIENT WSSaoPauloNFSE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaLoteRequest xmlns="http://www.prefeitura.sp.gov.br/nfe">'
cSoap += WSSoapValue("VersaoSchema", ::nVersaoSchema, nVersaoSchema , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MensagemXML", ::cMensagemXML, cMensagemXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultaLoteRequest>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.prefeitura.sp.gov.br/nfe/ws/consultaLote",; 
	"DOCUMENT","http://www.prefeitura.sp.gov.br/nfe",,,; 
	"https://nfe.prefeitura.sp.gov.br/ws/lotenfe.asmx")

::Init()
::cRetornoXML        :=  WSAdvValue( oXmlRet,"_CONSULTALOTERESPONSE:_RETORNOXML:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaInformacoesLote of Service WSSaoPauloNFSE

WSMETHOD ConsultaInformacoesLote WSSEND nVersaoSchema,cMensagemXML WSRECEIVE cRetornoXML WSCLIENT WSSaoPauloNFSE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaInformacoesLoteRequest xmlns="http://www.prefeitura.sp.gov.br/nfe">'
cSoap += WSSoapValue("VersaoSchema", ::nVersaoSchema, nVersaoSchema , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MensagemXML", ::cMensagemXML, cMensagemXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultaInformacoesLoteRequest>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.prefeitura.sp.gov.br/nfe/ws/consultaInformacoesLote",; 
	"DOCUMENT","http://www.prefeitura.sp.gov.br/nfe",,,; 
	"https://nfe.prefeitura.sp.gov.br/ws/lotenfe.asmx")

::Init()
::cRetornoXML        :=  WSAdvValue( oXmlRet,"_CONSULTAINFORMACOESLOTERESPONSE:_RETORNOXML:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method ConsultaCNPJ of Service WSSaoPauloNFSE

WSMETHOD ConsultaCNPJ WSSEND nVersaoSchema,cMensagemXML WSRECEIVE cRetornoXML WSCLIENT WSSaoPauloNFSE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<ConsultaCNPJRequest xmlns="http://www.prefeitura.sp.gov.br/nfe">'
cSoap += WSSoapValue("VersaoSchema", ::nVersaoSchema, nVersaoSchema , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MensagemXML", ::cMensagemXML, cMensagemXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultaCNPJRequest>"

oXmlRet := SvcSoapCall(Self,cSoap,; 
	"http://www.prefeitura.sp.gov.br/nfe/ws/consultaCNPJ",; 
	"DOCUMENT","http://www.prefeitura.sp.gov.br/nfe",,,; 
	"https://nfe.prefeitura.sp.gov.br/ws/lotenfe.asmx")

::Init()
::cRetornoXML        :=  WSAdvValue( oXmlRet,"_CONSULTACNPJRESPONSE:_RETORNOXML:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



