#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcSeller

Vendedor Cobrecom
    
@author victorhugo
@since 10/03/2016
/*/
class CbcSeller
	
	data cId
	data cName
	data cEmail
	data cDDD
	data cPhone	
	data aBranches
	data lFired
	
	method newCbcSeller() constructor
	
	method getId()
	method setId()
	method getName()
	method setName()
	method getEmail()
	method setEmail()
	method getDDD()
	method setDDD()
	method getPhone()
	method setPhone() 
	method getBranches()
	method setBranches()
	method isFired()
	method setFired()
	
	method toWsObject()
	method fromWsObject()
	method toJsonObject()
	method toJsonString()
	method fromJsonObject()
	
endClass


/*/{Protheus.doc} newCbcSeller

Construtor
    
@author victorhugo
@since 10/03/2016

@param cId, String, ID do Vendedor
/*/
method newCbcSeller(cId) class CbcSeller
	
	::setId(cId)

return self


/*/{Protheus.doc} getId

Coleta o ID do Vendedor
	
@author victorhugo
@since 10/03/2016

@return String ID do Vendedor
/*/
method getId() class CbcSeller
return ::cId


/*/{Protheus.doc} setId

Define o ID do Vendedor
	
@author victorhugo
@since 10/03/2016

@param cId, String, ID do Vendedor
/*/
method setId(cId) class CbcSeller
	
	local aBranches  		:= {}
	local oItuBranch 		:= CbcBranch():newCbcBranch(BRANCH_ITU)
	local oTresLagoasBranch := CbcBranch():newCbcBranch(BRANCH_TRES_LAGOAS) 
	local oSql 		 		:= LibSqlObj():newLibSqlObj()
	
	::cId := cId
	
	if Empty(cId)
		return
	endIf
	
	oSql:newTable("SA3", "A3_NOME NAME, A3_EMAIL EMAIL, A3_DDDTEL DDD, A3_TEL PHONE, A3_XREGRA [RULE], A3_DEMISS RESIGNATION_DATE", ; 
				  "%SA3.XFILIAL% AND A3_COD = '"+cId+"'")
	
	::setName(oSql:getValue("AllTrim(NAME)"))
	::setEmail(oSql:getValue("AllTrim(EMAIL)"))
	::setDDD(oSql:getValue("AllTrim(DDD)"))
	::setPhone(oSql:getValue("AllTrim(PHONE)"))
	::setFired(oSql:getValue("!Empty(RESIGNATION_DATE)"))
	
	if (oSql:getValue("RULE") == "1")
		aAdd(aBranches, oItuBranch)
	elseIf (oSql:getValue("RULE") == "2")
		aAdd(aBranches, oTresLagoasBranch)
	else
		aBranches := {oItuBranch, oTresLagoasBranch}
	endIf 
	
	::setBranches(aBranches)
	
	oSql:close()
	
return


/*/{Protheus.doc} getName

Coleta o Nome do Vendedor
	
@author victorhugo
@since 10/03/2016

@return String Nome do Vendedor
/*/
method getName() class CbcSeller
return ::cName


/*/{Protheus.doc} setName

Define o Nome do Vendedor
	
@author victorhugo
@since 10/03/2016

@param cName, String, Nome do Vendedor
/*/
method setName(cName) class CbcSeller
	::cName := cName
return


/*/{Protheus.doc} getEmail

Coleta o E-mail do Vendedor
	
@author victorhugo
@since 20/04/2016

@return String E-mail do Vendedor
/*/
method getEmail() class CbcSeller
return ::cEmail


/*/{Protheus.doc} setEmail

Define o E-mail do Vendedor
	
@author victorhugo
@since 20/04/2016

@param cEmail, String, E-mail do Vendedor
/*/
method setEmail(cEmail) class CbcSeller
	::cEmail := cEmail
return


/*/{Protheus.doc} getDDD

Coleta o DDD do Vendedor
	
@author victorhugo
@since 20/04/2016

@return String DDD do Vendedor
/*/
method getDDD() class CbcSeller
return ::cDDD


/*/{Protheus.doc} setDDD

Define o DDD do Vendedor
	
@author victorhugo
@since 20/04/2016

@param cDDD, String, DDD do Vendedor
/*/
method setDDD(cDDD) class CbcSeller
	::cDDD := cDDD
return


/*/{Protheus.doc} getPhone

Coleta o Telefone do Vendedor
	
@author victorhugo
@since 20/04/2016

@return String Telefone do Vendedor
/*/
method getPhone() class CbcSeller
return ::cPhone


/*/{Protheus.doc} setPhone

Define o Telefone do Vendedor
	
@author victorhugo
@since 20/04/2016

@param cPhone, String, Telefone do Vendedor
/*/
method setPhone(cPhone) class CbcSeller
	::cPhone := cPhone
return


/*/{Protheus.doc} getBranches

Coleta as Filiais do Vendedor
	
@author victorhugo
@since 10/03/2016

@return Vetor Filiais do Vendedor
/*/
method getBranches() class CbcSeller
return ::aBranches


/*/{Protheus.doc} setBranches

Define as Filiais do Vendedor
	
@author victorhugo
@since 10/03/2016

@param aBranches, Vetor, Filiais do Vendedor
/*/
method setBranches(aBranches) class CbcSeller
	::aBranches := aBranches
return

method isFired() class CbcSeller
return ::lFired

method setFired(lFired) class CbcSeller
	::lFired := lFired
return


/*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 26/02/2016

@return WsCbcUser Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcSeller
	
	local nI 		  := 0
	local aWsBranches := {}
	local aBranches	  := ::getBranches()
	local oWsObj      := WsClassNew("WsCbcSeller")
	local oUtils      := LibUtilsObj():newLibUtilsObj()	
	
	oWsObj:id 	   := ::getId()
	oWsObj:name    := ::getName()
	oWsObj:email   := ::getEmail()
	oWsObj:ddd	   := ::getDDD()
	oWsObj:phone   := ::getPhone()
	oWsObj:isFired := ::isFired() 

	if oUtils:isNotNull(aBranches)
		for nI := 1 to Len(aBranches)
			aAdd(aWsBranches, aBranches[nI]:toWsObject()) 
		next nI		
	endIf

	oWsObj:branches := aWsBranches

return oWsObj


/*/{Protheus.doc} fromWsObject

Popula as propriedades do objeto conforme a respectiva instancia da classe de Web Service
	
@author victorhugo
@since 26/02/2016

@param oWsObj, WsCbcUser, Instancia da respectiva classe de Web Service
/*/
method fromWsObject(oWsObj) class CbcSeller
	
	local nI		  := 0
	local oBranch	  := nil
	local aBranches	  := {}
	local aWsBranches := oWsObj:branches
	local oUtils 	  := LibUtilsObj():newLibUtilsObj()
	
	::setId(oWsObj:id)
	::setName(oWsObj:name)
	::setEmail(oWsObj:email)
	::setDDD(oWsObj:ddd)
	::setPhone(oWsObj:phone)
	::setFired(oWsObj:isFired)

	if oUtils:isNotNull(aWsBranches)
		for nI := 1 to Len(aWsBranches)
			oBranch := CbcBranch():newCbcBranch(aWsBranches[nI]:id, aWsBranches[nI]:name)
			aAdd(aBranches, oBranch)
		next nI
	endIf

	::setBranches(aBranches)

return


/*/{Protheus.doc} toJsonObject

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcSeller		
	
	local nI 		  := 0
	local aJsBranches := {}
	local aBranches	  := ::getBranches()
	local oUtils      := LibUtilsObj():newLibUtilsObj()
	local oJson 	  := JsonObject():new()	
	
	oJson["id"] 	 := ::getId()
	oJson["name"]    := ::getName()
	oJson["email"]   := ::getEmail()
	oJson["ddd"]	 := ::getDDD()
	oJson["phone"]   := ::getPhone()
	oJson["isFired"] := ::isFired() 

	if oUtils:isNotNull(aBranches)
		for nI := 1 to Len(aBranches)
			aAdd(aJsBranches, aBranches[nI]:toJsonObject()) 
		next nI		
	endIf

	oJson["branches"] := aJsBranches

return oJson


/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcSeller	
return ::toJsonObject():toJson()


/*/{Protheus.doc} fromJsonObject

Popula o objeto a partir de um JSON
	
@author victorhugo
@since 08/10/2018
/*/
method fromJsonObject(xJson) class CbcSeller
		
	local nI		  := 0
	local oBranch	  := nil
	local aBranches	  := {}
	local aJsBranches := {}
	local oUtils 	  := LibUtilsObj():newLibUtilsObj()
	local oJson 	  := JsonObject():new()
	
	if (ValType(xJson) == "C")
		oJson:fromJson(xJson)
	else
		oJson := xJson
	endIf
	
	::setId(oJson["id"])
	::setName(oJson["name"])
	::setEmail(oJson["email"])
	::setDDD(oJson["ddd"])
	::setPhone(oJson["phone"])
	::setFired(oJson["isFired"])
	
	aJsBranches := oJson["branches"]

	if oUtils:isNotNull(aJsBranches)
		for nI := 1 to Len(aJsBranches)
			oBranch := CbcBranch():newCbcBranch(aJsBranches[nI]["id"], aJsBranches[nI]["name"])
			aAdd(aBranches, oBranch)
		next nI
	endIf

	::setBranches(aBranches)

return
