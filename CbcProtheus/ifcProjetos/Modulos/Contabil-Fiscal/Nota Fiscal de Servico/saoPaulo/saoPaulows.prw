#INCLUDE "protheus.ch"
#INCLUDE "apwebsrv.ch"


User Function _ONTKDJP ; Return

WSCLIENT WSSaoPauloNFSE

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD ConsultaNFe
	WSMETHOD ConsultaNFeRecebidas

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

cSoap += '<ConsultaNFeRecebidasRequest  xmlns="http://www.prefeitura.sp.gov.br/nfe">'
cSoap += WSSoapValue("VersaoSchema", ::nVersaoSchema, nVersaoSchema , "int", .T. , .F., 0 , NIL, .F.,.F.) 
cSoap += WSSoapValue("MensagemXML", ::cMensagemXML, cMensagemXML , "string", .F. , .F., 0 , NIL, .F.,.F.) 
cSoap += "</ConsultaNFeRecebidasRequest>"

WSDLDbgLevel(2)
oXmlRet := SvcSoapCall(	Self,cSoap,;
			"http://www.prefeitura.sp.gov.br/nfe/ws/consultaNFeRecebidas",;
			"DOCUMENT","http://www.prefeitura.sp.gov.br/nfe",,,;
			"https://nfe.prefeitura.sp.gov.br/ws/lotenfe.asmx")

::Init()
::cRetornoXML  :=  WSAdvValue( oXmlRet,"_CONSULTANFERECEBIDASRESPONSE:_RETORNOXML:TEXT","string",NIL,NIL,NIL,NIL,NIL,NIL) 

END WSMETHOD

alert(GetWSCError())
oXmlRet := NIL
Return .T.

