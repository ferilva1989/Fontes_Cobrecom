#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"


/*/{Protheus.doc} cbcWSDistribuicaoDFe
@type class
@author bolognesi
@since 21/06/2018
@version 1.0
@description Classe cliente do 
WS: https://www1.cte.fazenda.gov.br/CTeDistribuicaoDFe/CTeDistribuicaoDFe.asmx?WSDL 
/*/
wsclient cbcWSDistribuicaoDFe
	
	wsmethod NEW
	wsmethod INIT
	wsmethod RESET
	wsmethod CLONE
	wsmethod cteDistDFeInteresse
	
	wsdata   _URL                      		AS String
	wsdata   _CERT                     		AS String
	wsdata   _PRIVKEY                  		AS String
	wsdata   _PASSPHRASE               		AS String
	wsdata  ccteCabecMsg					AS String
	wsdata   _HEADOUT                  		AS Array of String
	wsdata   _COOKIES                  		AS Array of String
	wsdata   oWScteDadosMsg            		AS SCHEMA
	wsdata   oWScteDistDFeInteresseResult 	AS SCHEMA
	
endwsclient


/*/{Protheus.doc} NEW
@type method
@author bolognesi
@since 21/06/2018
@version 1.0
@description Construtor da classe
/*/
wsmethod NEW wsclient cbcWSDistribuicaoDFe
	::Init()
	if !FindFunction("XMLCHILDEX")
		UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20180104 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
	endif
return Self


/*/{Protheus.doc} cteDistDFeInteresse
@type method
@author bolognesi
@since 21/06/2018
@version 1.0
@description Metodo que consome o metodo cteDistDFeInteresse do WS
CTeDistribuicaoDFe que disponibilizará para os atores do CT-e informações e documentos fiscais
eletrônicos de seu interesse. A distribuição será realizada para emitentes, remetentes, destinatários,
expedidores, recebedores, tomadores e terceiros informados no conteúdo do CT-e respectivamente
no grupo do Emitente (tag: emit), nos grupos do Remetente (tag: rem), Destinatário (tag: dest),
Expedidor (tag: exped), Recebedor (tag: receb), Tomador (tag: toma4) e no grupo de pessoas
autorizadas a acessar o XML (tag:autXML). 
/*/
wsmethod cteDistDFeInteresse wssend oWScteDadosMsg wsreceive oWScteDistDFeInteresseResult wsclient cbcWSDistribuicaoDFe
	local cSoap := "" , oXmlRet
	BEGIN WSMETHOD
		cSoap += '<cteDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/cte/wsdl/CTeDistribuicaoDFe">'
		cSoap += WSSoapValue("cteDadosMsg", ::oWScteDadosMsg, oWScteDadosMsg , "SCHEMA", .F. , .F., 0 , NIL, .F.,.F.)
		cSoap += "</cteDistDFeInteresse>"	
		oXmlRet := SvcSoapCall(	Self,cSoap,;
			"http://www.portalfiscal.inf.br/cte/wsdl/CTeDistribuicaoDFe/cteDistDFeInteresse",;
			"DOCUMENTSOAP12","http://www.portalfiscal.inf.br/cte/wsdl/CTeDistribuicaoDFe",::ccteCabecMsg,,;
			"https://www1.cte.fazenda.gov.br/CTeDistribuicaoDFe/CTeDistribuicaoDFe.asmx")
		::Init()
		::oWScteDistDFeInteresseResult :=  WSAdvValue( oXmlRet,"_CTEDISTDFEINTERESSERESPONSE","SCHEMA",NIL,NIL,NIL,"O",NIL,NIL)
	END WSMETHOD
	oXmlRet := NIL
return(.T.)


/*/{Protheus.doc} INIT
@type method
@author bolognesi
@since 21/06/2018
@version 1.0
@description Inicia propriedades de comunicação (envio/recebimento)
/*/
wsmethod INIT wsclient cbcWSDistribuicaoDFe
	::oWScteDadosMsg     			:= NIL
	::oWScteDistDFeInteresseResult 	:= NIL
return


/*/{Protheus.doc} RESET
@type method
@author bolognesi
@since 21/06/2018
@version 1.0
@description Reseta as propriedades da clase
e utiliza metodo Init() para uma nova definição
/*/
wsmethod RESET wsclient cbcWSDistribuicaoDFe
	::oWScteDadosMsg     			:= NIL
	::oWScteDistDFeInteresseResult 	:= NIL
	::Init()
return


/*/{Protheus.doc} CLONE
@type method
@author bolognesi
@since 21/06/2018
@version 1.0
@description Retorma um objeto identico a classe instanciada.
/*/
wsmethod CLONE wsclient cbcWSDistribuicaoDFe
	local oClone 			:= cbcWSDistribuicaoDFe():New()
	oClone:_URL          	:= ::_URL
	oClone:_CERT         	:= ::_CERT
	oClone:_PRIVKEY      	:= ::_PRIVKEY
	oClone:_PASSPHRASE   	:= ::_PASSPHRASE
return(oClone)


/*/{Protheus.doc} _PNLPOYI
@type function
@author bolognesi
@since 21/06/2018
@version 1.0
@description "dummy" function - Internal Use
/*/
user function _PNLPOYI ; return
