#include 'protheus.ch'

#define 	LOK 1
#define	CERRMSG 2
#define	ORESP 3
#define	CRESP 4

static URL_API 		:= GetNewPar('XX_ERSAPI', "http://192.168.1.129:3000") 
static PATH_INSERT	:= GetNewPar('XX_ERSINS', "/api/register/")
static PATH_LOGIN		:= GetNewPar('XX_ERSLOG', "/api/login/") 
static HEADER			:= GetNewPar('XX_ERSHDR', "Content-Type: application/json") 
static USER_ERS		:= GetNewPar('XX_ERSUSR', "ersOperador")
static PASS_ERS		:= GetNewPar('XX_ERSPAS', "45op63")


/*/{Protheus.doc} cbcServiceERS
@author bolognesi
@since 21/12/2017
@version 1.0
@type class
@description 
Classe de serviço utilizada pelo controlles (cbcControllerERS) para realizar a comunicação
com a API externo
Herança classe cbcRestAPI metodos:
::getURL()
::setURL(<cUrl>)
::getURLPath()
::setURLPath(<cPath>)
::getHeader()
::setHeader(<cHdr>)
::sendGet(cParams)
::sendPost(cParams)
::sendPut(cParams)
::sendDelete(cParams)
/*/
class cbcServiceERS FROM cbcRestAPI
	data lStatus
	data cResultMsg
	
	method newcbcServiceERS() constructor
	
	method setStatus()
	method isOk()
	method getResultMsg()
	
	method insert()
	method login()
	method vldModel()
	method getLogInf()
endclass


/*/{Protheus.doc} newcbcServiceERS
Construtor da classe
@type method
@author bolognesi
@since 15/01/2018
@version 1.0
@description Construtor da classe
/*/
method newcbcServiceERS() class cbcServiceERS
	::setStatus()
	::New(URL_API)
	::newcbcRestAPI()
return ( self )


/*/{Protheus.doc} setStatus
Definir status de um processamento e mensagem de erro
@type method
@author bolognesi
@since 15/01/2018
@version 1.0
@description Definir status de um processamento e mensagem de erro
/*/
method setStatus( lStatus, cMsg ) class cbcServiceERS
	default lStatus 	:= .T.
	default cMsg		:= ''
	::lStatus 		:= lStatus
	::cResultMsg 		:= cMsg
return(self)


/*/{Protheus.doc} isOk
Obtem o retorno do status para um processamento
@type method
@author bolognesi
@since 15/01/2018
@version 1.0
@description Obtem o retorno do status para um processamento
/*/
method isOk() class cbcServiceERS
return(::lStatus )


/*/{Protheus.doc} getResultMsg
Obtem o conteudo da propriedade cResultMsg
@type method
@author bolognesi
@since 15/01/2018
@version 1.0
@description Obtem o texto retornado pelo processamento
/*/
method getResultMsg() class cbcServiceERS
return( ::cResultMsg )


/*/{Protheus.doc} insert
Realiza a inclusão de um registro para API
@type method
@author bolognesi
@since 15/01/2018
@version 1.0
@description Realiza a inclusão, atraves de um post
no endpoint utilizado pela API
/*/
method insert(cJson) class cbcServiceERS
	local cMsgErr		:= ''
	::setStatus()
	::setURLPath(PATH_INSERT)
	::sendPost(cJson)
	
	if ! ::getResp( LOK )
		cMsgErr += '[ERRO] ' + ::getResp( CERRMSG )
	endif
	if AttIsMemberOff( ::getResp(ORESP) , 'message' )
		cMsgErr += ' [MSG] ' + ::getResp(ORESP):message
	endif
	
	::setStatus( ::getResp( LOK ) ,cMsgErr )
return( self )


/*/{Protheus.doc} login
Utilizado para realizar o login na API
@type method
@author bolognesi
@since 15/01/2018
@version 1.0
@description Utilizado para realizar o login na API
/*/
method login() class cbcServiceERS
	::setStatus()
	::setHeader(HEADER, .T.)
	::setURLPath(PATH_LOGIN)
	::sendPost( ::getLogInf() )
	::setStatus(::getResp( LOK ), ::getResp( CERRMSG) )	
	
	if  ::getResp( LOK ) .and. !AttIsMemberOff( ::getResp(ORESP) , 'token' )
		::setStatus(.F., 'Retorno API inválido,estrutura JSON inválida!' )
	elseIf ::getResp( LOK )
		if empty( ::getResp(ORESP):token )
			::setStatus(.F., 'Retorno API inválido,token não fornecido!' )
		else
			::setHeader( "Authorization: " + ::getResp(ORESP):token )
		endif
	endif	
return (self)


/*/{Protheus.doc} vldModel
Realiza a validação do modelo a ser enviado
@type method
@author bolognesi
@since 15/01/2018
@version 1.0
@description Realiza a validação do modelo a ser enviado, utiliza os metodos
de validaçao do modelo cbcRegErs
/*/
method vldModel( oModel ) class cbcServiceERS
	::setStatus()
	if empty(oModel)
		::setStatus(.F., '[ERRO] - Nenhum modelo para validação foi informado!')
	elseif empty(oModel:oRegister)
		::setStatus(.F., '[ERRO] - Nenhum registro para ser validado!' )
	elseif !oModel:oRegister:vldTotal()
		::setStatus(.F., '[ERRO] - Totais das parcelas diferente do total geral!' )
	endif
return (self )


/*/{Protheus.doc} getLogInf
Obtem a string JSON para autenticação na API
@type method
@author bolognesi
@since 15/01/2018
@version 1.0
@description Obtem a string JSON para autenticação na API
/*/
method getLogInf() class cbcServiceERS
return( '{"username": "' + USER_ERS + '", "password": "' +  PASS_ERS + '" }' )

