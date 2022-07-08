#include 'protheus.ch'

/*/{Protheus.doc} cbcQryExecutor
@author bolognesi
@since 18/10/2017
@version 1.0
@type class
@description Classe utilzada para preencher as propriedades
de um objeto, com a query do proprio objeto, sendo sua utilização
generica, qualquer objeto com o metodo getQuery(), que retorna uma query onde o nome dos campos
seja igual a propriedade do objeto e que tambem tenha um metodo execAfterQry() ira funcionar. 
/*/
class cbcQryExecutor from LibSqlObj

	method newcbcQryExecutor() constructor
	method execQuery() 

endclass

method newcbcQryExecutor() class cbcQryExecutor
	::newLibSqlObj()
return (self)

/*/{Protheus.doc} execQuery
@author bolognesi
@since 18/10/2017
@version 1.0
@param oObj, object, Objeto que deverá ser preenchido, com o resultado da consulta.
@type method
@description Metodo que recebe um objeto, deste objeto obtem a query(SQL) de consulta
realiza a consulta populando um array com uma estancia do objeto por resultado.
O Objeto recebido deve obrigatoriamente conter um metodo getQuery(), que retorna
a string(SQL) a ser utilizada por este metodo na consulta.
Para que este metodo consiga popular a propriedades do objeto, os campos retornados
na query devem ter o mesmo nome das propriedades do objeto (utilizando AS NOME_IGUAL_PROPRIEDADE)
o objeto precisa ter tambem um metodo (execAfterQry()), que devera ser executado apos população
do objeto pela query

/*/
method execQuery(oObj) class cbcQryExecutor
	local aRet			:= {}
	local aProps 		:= ClassDataArr(oObj)
	local nX			:= 0
	local xPropVal		:= ''
	local cQuery		:= ''
	private cExeCmd		:= ''
	private cClassName	:= Alltrim(GetClassName(oObj))
		
	if empty( cQuery := vldObj(oObj) )
		u_autoalert('[QryExecutor] - Classe inválida')
	else
		::newAlias( cQuery )
		::goTop()
		while ::notIsEof()
			for nX := 1 to Len(aProps)
				if ((::cAlias)->(FieldPos(aProps[nX,1])) >0)
					xPropVal := self:getValue(aProps[nX,1] )
					cExeCmd := "{ || " + "oObj:" + Alltrim(aProps[nX,1]) + " := " +  defType(xPropVal)  + " }" 
					execMacro(cExeCmd, oObj)
				endif
			next nX
			Aadd(aRet, oObj) 
			cExeCmd := " { || oObj:execAfterQry() }"
			execMacro(cExeCmd, oObj)

			// Iniciar nova classe
			cExeCmd := " { || oObj := " + cClassName +"():new" + cClassName + "() }"
			oObj := execMacro(cExeCmd, oObj)
			::skip()		
		enddo
		::close()
	endif 
return (aRet)


/*/{Protheus.doc} execMacro
@author bolognesi
@since 18/10/2017
@version 1.0
@param cExeCmd, characters, descricao
@param oObj, object, descricao
@type function
@description Executa a macrosubstituição da string, para o 
objeto informado.
/*/
static function execMacro(cExeCmd, oObj)
	local bBloco := &( cExeCmd )
	EVAL(bBloco, 1)
return(oObj)


/*/{Protheus.doc} defType
@author bolognesi
@since 18/10/2017
@version 1.0
@param xPropVal, , descricao
@type function
@description Realiza o ajuste para compor uma string, 
conforme o tipo do dado recebido pelo parametro
/*/
static function defType(xPropVal)
	local xRet := ''
	if ValType(xPropVal) == 'C'
		xRet := "'" + xPropVal  + "'" 
	else
		xRet := cValToChar(xPropVal) 
	endif
return(xRet)


/*/{Protheus.doc} vldField
@author bolognesi
@since 18/10/2017
@version 1.0
@type function
@description Utilizado para validar o objeto de acordo com
as regras de utilização
/*/
static function vldObj(oObj)
	local aMeth		:= ClassMethArr(oObj)
	local cQry		:= ''
	// Validar existencia metodo getQuery()
	if (AScan(aMeth,{|a| Alltrim(Upper(a[1])) == Alltrim( Upper('getQuery') ) })) > 0
		// Validar existencia metodo execAfterQry()
		if (AScan(aMeth,{|a| Alltrim(Upper(a[1])) == Alltrim( Upper('execAfterQry') ) })) > 0 
			cQry := oObj:getQuery()
		endif
	endif
return(cQry)