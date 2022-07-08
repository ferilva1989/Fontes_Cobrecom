#include 'protheus.ch'
#include 'topconn.ch'
#include 'tbiconn.ch'

class cbcLogin 

	data cCod
	data cSenha
	data cToken

	method newcbcLogin() constructor 
	method setCod()
	method getCod()
	method setSenha()
	method getSenha()
	method vldOperador()

endclass
//Inicializar a classe
method newcbcLogin(Cod, Senha) class cbcLogin
	Default Cod 	:= ""
	Default Senha	:= ""
	::setCod(Cod):setSenha(Senha)
return

/*GETTERS E SETTERS*/
method getCod() 	class cbcLogin
return ::cCod

method setCod(cCodigo) 	class cbcLogin
	Default cCodigo := ""
	::cCod := cCodigo
return self

method getSenha() 	class cbcLogin
return ::cSenha

method setSenha(cPass) 	class cbcLogin
	::cSenha := cPass
return self

/*FIM GETTER E SETTER*/

//Validar Operador Siga
method vldOperador(apiRes, oRes) class cbcLogin
	Local oToken	:= cbcToken():newcbcToken(::getCod())
	
	If szsLogin(::getCod(),::getSenha()) .And. ::getSenha() == '1234' //TODO senha deve vir da base 
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

static function szsLogin(cCod,cSenha)
	Local lRet 		:= .F.
	Local cQuery 	:= ""
	Local nTamZS	:= TamSX3('ZS_CODIGO')[1]
	Local cZeros	:= Replicate("0",nTamZS )
	Default cCod	:= ""
	Default cSenha	:= ""

	If !Empty(cCod) .And. !Empty(cSenha)		
		
		cCod 	:= FwNoAccent(Escape(cCod))
		cSenha 	:= FwNoAccent(Escape(cSenha))
		
		If Select( "UsrLogin") > 0
			UsrLogin->(dbcloseArea())
			FErase( "UsrLogin" + GetDbExtension())
		EndIf
		//TODO verificar quais campos necessarios trazer
		cQuery 	:= " SELECT * "
		cQuery 	+= " FROM " + RETSQLNAME("SZS")  + " SZS"
		cQuery	+= " WHERE SZS.ZS_FILIAL + RIGHT('" + cZeros + "' + RTRIM(ZS_CODIGO)," + cValToChar(nTamZS) + ") = '" + cCod + "' "
		cQuery 	+= " AND   SZS.ZS_ATIVO = 'S' "
		cQuery  += " AND   SZS.D_E_L_E_T_	<>	'*' " 

		cQuery := ChangeQuery(cQuery)
		TCQUERY cQuery NEW ALIAS "UsrLogin"		
		
		DbSelectArea("UsrLogin")
		UsrLogin->(DbGotop())
		lRet := !UsrLogin->(Eof())

		If Select( "UsrLogin") > 0
			UsrLogin->(dbcloseArea())
			FErase( "UsrLogin" + GetDbExtension())
		End If	
	EndIf
return lRet