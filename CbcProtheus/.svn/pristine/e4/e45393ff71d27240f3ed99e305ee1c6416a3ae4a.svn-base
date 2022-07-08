#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'

class cbcRestLogin 

	data cCod
	data cSenha
	data cToken

	method newcbcRestLogin() constructor 
	method setCod()
	method getCod()
	method setSenha()
	method getSenha()
	method vldLogin()

endclass
//Inicializar a classe
method newcbcRestLogin(Cod, Senha) class cbcRestLogin
	Default Cod 	:= ""
	Default Senha	:= ""
	::setCod(Cod):setSenha(Senha)
return

/*GETTERS E SETTERS*/
method getCod() 	class cbcRestLogin
return ::cCod

method setCod(cCodigo) 	class cbcRestLogin
	Default cCodigo := ""
	::cCod := cCodigo
return self

method getSenha() 	class cbcRestLogin
return ::cSenha

method setSenha(cPass) 	class cbcRestLogin
	::cSenha := cPass
return self

/*FIM GETTER E SETTER*/

//Validar Operador Siga
method vldLogin(apiRes, oRes) class cbcRestLogin
	Local oToken	:= cbcToken():newcbcToken(::getCod())
	
	If Login( self ) 
		oRes:sucesso 	:= .T.
		oRes:msg		:= 'LOGIN OK'
		oRes:body		:= oToken:gerToken()
	Else
		oRes:sucesso 	:= .F.
		oRes:msg		:= 'LOGIN INVALIDO'
	EndIf

	//Response da requisição
	apiRes:SetResponse(oRes:toJson())

return

static function Login(oSelf)
	local lRet 		:= .T.
	local cCod		:= ''
	local cSenha	:= ''
	default oSelf	:= Nil

	if !Empty(oSelf)		
		cCod 	:= FwNoAccent(Escape(oSelf:getCod()))
		cSenha 	:= FwNoAccent(Escape(oSelf:getSenha()))
	endIf
return lRet