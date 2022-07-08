#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch"


/*/{Protheus.doc} CbcUser

Objeto que representa um Usuário do Portal Cobrecom
    
@author victorhugo
@since 24/02/2016
/*/
class CbcUser from LongClassName
	
	data cId
	data cName
	data cLastName
	data cLogin
	data cPassword
	data cEmail
	data cDepartment
	data cGroup
	data cGroupName
	data oCustomer
	data oSeller
	data cErpId
	data lBlocked
	data dLastLogin	
	data lUseTerms
	data lApprover
	data lShowDashboard
	data lPswChanged
	data oAppProfile
	
	method newCbcUser() constructor
	
	method getId()
	method setId()
	method getName()
	method setName()
	method getLastName()
	method setLastName() 
	method getLogin()
	method setLogin()
	method getPassword()
	method setPassword()
	method getEmail()
	method setEmail()
	method getDepartment()
	method setDepartment() 
	method getGroup()
	method setGroup()
	method getGroupName()
	method setGroupName()
	method getCustomer()
	method setCustomer()
	method getSeller()
	method setSeller()  
	method getErpId()
	method setErpId()
	method isBlocked()
	method setBlocked()
	method getLastLogin()
	method setLastLogin()
	method isUseTerms()
	method setUseTerms()
	method isApprover()
	method setApprover()
	method showDashboard()
	method setShowDashboard()
	method getAppProfile()
	method setAppProfile()
	method isPswChanged()
	method setPswChanged() 
	method getSalesId()

	method isAdministrator()
	method isSeller()
	method isProspect()
	method isCustomer()
	method isAssistant()
	method isSupervisor()
	method isManager()
	method isDirector()
	method getFullName()
		
	method toWsObject()
	method fromWsObject() 
	method toJsonObject()
	method toJsonString()
	method fromJsonObject()	
	
endClass


/*/{Protheus.doc} newCbcUser

Construtor
    
@author victorhugo
@since 24/02/2016
/*/
method newCbcUser() class CbcUser
return self


/*/{Protheus.doc} getId

Coleta o ID do Usuário
	
@author victorhugo
@since 24/02/2016

@return String ID do Usuário
/*/
method getId() class CbcUser
return ::cId


/*/{Protheus.doc} setId

Define o ID do Usuário
	
@author victorhugo
@since 24/02/2016

@param cId, String, ID do Usuário
/*/
method setId(cId) class CbcUser
	::cId := cId
return


/*/{Protheus.doc} getName

Coleta o Nome do Usuário
	
@author victorhugo
@since 24/02/2016

@return String Nome do Usuário
/*/
method getName() class CbcUser
return ::cName


/*/{Protheus.doc} setName

Define o Nome do Usuário
	
@author victorhugo
@since 24/02/2016

@param cName, String, Nome do Usuário
/*/
method setName(cName) class CbcUser
	::cName := cName
return


/*/{Protheus.doc} getLastName

Coleta o Sobrenome do Usuário
	
@author victorhugo
@since 09/03/2016

@return String Sobrenome do Usuário
/*/
method getLastName() class CbcUser
return ::cLastName


/*/{Protheus.doc} setLastName

Define o Sobrenome do Usuário
	
@author victorhugo
@since 09/03/2016

@param cLastName, String, Sobrenome do Usuário
/*/
method setLastName(cLastName) class CbcUser
	::cLastName := cLastName
return


/*/{Protheus.doc} getLogin

Coleta o Login do Usuário
	
@author victorhugo
@since 24/02/2016

@return String Login do Usuário
/*/
method getLogin() class CbcUser
return ::cLogin


/*/{Protheus.doc} setLogin

Define o Login do Usuário
	
@author victorhugo
@since 24/02/2016

@param cLogin, String, Login do Usuário
/*/
method setLogin(cLogin) class CbcUser
	::cLogin := cLogin
return


/*/{Protheus.doc} getPassword

Coleta a Senha do Usuário
	
@author victorhugo
@since 24/02/2016

@return String Senha do Usuário
/*/
method getPassword() class CbcUser
return ::cPassword


/*/{Protheus.doc} setPassword

Define a Senha do Usuário
	
@author victorhugo
@since 24/02/2016

@param cPassword, String, Senha do Usuário
/*/
method setPassword(cPassword) class CbcUser
	::cPassword := cPassword
return


/*/{Protheus.doc} getEmail

Coleta o E-mail do Usuário
	
@author victorhugo
@since 24/02/2016

@return String E-mail do Usuário
/*/
method getEmail() class CbcUser
return ::cEmail


/*/{Protheus.doc} setEmail

Define o E-mail do Usuário
	
@author victorhugo
@since 24/02/2016

@param cEmail, String, E-mail do Usuário
/*/
method setEmail(cEmail) class CbcUser
	::cEmail := cEmail
return


/*/{Protheus.doc} getDepartment

Coleta o Departamento do Usuário
	
@author victorhugo
@since 09/03/2016

@return String Departamento do Usuário
/*/
method getDepartment() class CbcUser
return ::cDepartment


/*/{Protheus.doc} setDepartment

Define o Departamento do Usuário
	
@author victorhugo
@since 09/03/2016

@param cDepartment, String, Departamento do Usuário
/*/
method setDepartment(cDepartment) class CbcUser
	::cDepartment := cDepartment
return


/*/{Protheus.doc} getGroup

Coleta o Grupo do Usuário
	
@author victorhugo
@since 24/02/2016

@return String Grupo do Usuário
/*/
method getGroup() class CbcUser
return ::cGroup


/*/{Protheus.doc} setGroup

Define o Grupo do Usuário
	
@author victorhugo
@since 24/02/2016

@param cGroup, String, Grupo do Usuário
/*/
method setGroup(cGroup) class CbcUser
	::cGroup := cGroup
return


/*/{Protheus.doc} getGroupName

Coleta o Nome do Grupo do Usuário
	
@author victorhugo
@since 24/02/2016

@return String Nome do Grupo do Usuário
/*/
method getGroupName() class CbcUser
return ::cGroupName


/*/{Protheus.doc} setGroupName

Define o Nome do Grupo do Usuário
	
@author victorhugo
@since 24/02/2016

@param cGroupName, String, Nome do Grupo do Usuário
/*/
method setGroupName(cGroupName) class CbcUser
	::cGroupName := cGroupName
return


/*/{Protheus.doc} getCustomer

Coleta o Cliente vinculado ao Usuário
	
@author victorhugo
@since 24/02/2016

@return CbcCustomer Cliente vinculado ao Usuário
/*/
method getCustomer() class CbcUser
return ::oCustomer


/*/{Protheus.doc} setCustomer

Define o Cliente vinculado ao Usuário
	
@author victorhugo
@since 24/02/2016

@param oCustomer, CbcCustomer, Cliente vinculado ao Usuário
/*/
method setCustomer(oCustomer) class CbcUser
	::oCustomer := oCustomer
return


/*/{Protheus.doc} getSeller

Coleta o Vendedor do Usuário
	
@author victorhugo
@since 10/03/2016

@return CbcSeller Vendedor do Usuário
/*/
method getSeller() class CbcUser
return ::oSeller

method getSalesId() class CbcUser
	local cSalesId as character
	local oSql	   as object			
	oSql := LibSqlObj():newLibSqlObj()
	cSalesId := oSql:getFieldValue("ZP1", "ZP1_CODVEN",;
	"%ZP1.XFILIAL% AND ZP1_CODIGO = '" + ::getId() + "'")
	FreeObj(oSql)
return (cSalesId)

/*/{Protheus.doc} setSeller

Define o Vendedor do Usuário
	
@author victorhugo
@since 10/03/2016

@param oSeller, CbcSeller, Vendedor do Usuário
/*/
method setSeller(oSeller) class CbcUser
	::oSeller := oSeller
return


/*/{Protheus.doc} getErpId

Coleta o Código de Usuário do Protheus
	
@author victorhugo
@since 24/02/2016

@return String Código de Usuário do Protheus
/*/
method getErpId() class CbcUser
return ::cErpId


/*/{Protheus.doc} setErpId

Define o Código de Usuário do Protheus
	
@author victorhugo
@since 24/02/2016

@param cErpId, String, Código de Usuário do Protheus
/*/
method setErpId(cErpId) class CbcUser
	::cErpId := cErpId
return


/*/{Protheus.doc} isBlocked

Indica se o Usuário está Bloqueado
	
@author victorhugo
@since 24/02/2016

@return Logico o Usuário está Bloqueado
/*/
method isBlocked() class CbcUser
return ::lBlocked


/*/{Protheus.doc} setBlocked

Define se o Usuário está Bloqueado
	
@author victorhugo
@since 24/02/2016

@param lBlocked, Logico, o Usuário está Bloqueado
/*/
method setBlocked(lBlocked) class CbcUser
	::lBlocked := lBlocked
return


/*/{Protheus.doc} getLastLogin

Coleta a Data do Ultimo Login do Usuário
	
@author victorhugo
@since 20/04/2016

@return Data Ultimo Login do Usuário
/*/
method getLastLogin() class CbcUser
return ::dLastLogin


/*/{Protheus.doc} setLastLogin

Define a Data do Ultimo Login do Usuário
	
@author victorhugo
@since 20/04/2016

@param dLastLogin, Data, Ultimo Login do Usuário
/*/
method setLastLogin(dLastLogin) class CbcUser
	::dLastLogin := dLastLogin
return


/*/{Protheus.doc} isUseTerms

Indica se Usuário aceitou os termo de Uso
	
@author victorhugo
@since 20/04/2016

@return Logico Usuário aceitou os termo de Uso
/*/
method isUseTerms() class CbcUser
return ::lUseTerms


/*/{Protheus.doc} setUseTerms

Define se Usuário aceitou os termo de Uso
	
@author victorhugo
@since 20/04/2016

@param lUseTerms, Logico, Usuário aceitou os termo de Uso
/*/
method setUseTerms(lUseTerms) class CbcUser
	::lUseTerms := lUseTerms
return

method isApprover() class CbcUser
return ::lApprover

method setApprover(lApprover) class CbcUser
	::lApprover := lApprover
return

method showDashboard() class CbcUser
return ::lShowDashboard

method setShowDashboard(lShowDashboard) class CbcUser
	::lShowDashboard := lShowDashboard
return

method getAppProfile() class CbcUser
return ::oAppProfile

method setAppProfile(oAppProfile) class CbcUser
	::oAppProfile := oAppProfile
return

method isPswChanged() class CbcUser
return ::lPswChanged

method setPswChanged(lPswChanged) class CbcUser
	::lPswChanged := lPswChanged
return


/*/{Protheus.doc} isAdministrator

Indica se o usuário faz parte do grupo Administradores
	
@author victorhugo
@since 24/02/2016

@return Logico Usuário Administrador
/*/
method isAdministrator() class CbcUser
return (::getGroup() == USER_ADMINISTRATOR)


/*/{Protheus.doc} isSeller

Indica se o usuário faz parte do grupo Representantes
	
@author victorhugo
@since 24/02/2016

@return Logico Usuário Representante
/*/
method isSeller() class CbcUser
return (::getGroup() == USER_SELLER) 
 
 
/*/{Protheus.doc} isProspect

Indica se o usuário faz parte do grupo Prospects
	
@author victorhugo
@since 24/02/2016

@return Logico Usuário Prospect
/*/ 
method isProspect() class CbcUser
return (::getGroup() == USER_PROSPECT)


/*/{Protheus.doc} isCustomer

Indica se o usuário faz parte do grupo Clientes
	
@author victorhugo
@since 24/02/2016

@return Logico Usuário Cliente
/*/
method isCustomer() class CbcUser
return (::getGroup() == USER_CUSTOMER)


/*/{Protheus.doc} isAssistant

Indica se o usuário faz parte do grupo Assistentes
	
@author victorhugo
@since 24/02/2016

@return Logico Usuário Assistente
/*/
method isAssistant() class CbcUser
return (::getGroup() == USER_ASSISTANT)


/*/{Protheus.doc} isSupervisor

Indica se o usuário faz parte do grupo Supervisores
	
@author victorhugo
@since 24/02/2016

@return Logico Usuário Supervisor
/*/
method isSupervisor() class CbcUser
return (::getGroup() == USER_SUPERVISOR)


/*/{Protheus.doc} isManager

Indica se o usuário faz parte do grupo Gerentes
	
@author victorhugo
@since 24/02/2016

@return Logico Usuário Gerente
/*/
method isManager() class CbcUser
return (::getGroup() == USER_MANAGER)


/*/{Protheus.doc} isDirector

Indica se o usuário faz parte do grupo Diretores
	
@author victorhugo
@since 24/02/2016

@return Logico Usuário Diretor
/*/
method isDirector() class CbcUser
return (::getGroup() == USER_DIRECTOR)


/*/{Protheus.doc} toWsObject

Retorna o objeto como uma instancia da respectiva classe de Web Service
	
@author victorhugo
@since 26/02/2016

@return WsCbcUser Instancia da respectiva classe de Web Service
/*/
method toWsObject() class CbcUser
	
	local oWsObj 		:= WsClassNew("WsCbcUser")	
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local oCustomer 	:= ::getCustomer()
	local oSeller		:= ::getSeller()
	local oAppProfile	:= ::getAppProfile()
	
	oWsObj:id 				:= ::getId()
	oWsObj:name 			:= ::getName()
	oWsObj:lastName 		:= ::getLastName()
	oWsObj:login 			:= ::getLogin()
	oWsObj:password 		:= ::getPassword()
	oWsObj:email 			:= ::getEmail()
	oWsObj:department 		:= ::getDepartment()
	oWsObj:group 			:= ::getGroup()
	oWsObj:groupName		:= ::getGroupName()
	oWsObj:erpId 			:= ::getErpId()
	oWsObj:isBlocked 		:= ::isBlocked() 
	oWsObj:lastLogin		:= ::getLastLogin() 
	oWsObj:isUseTerms		:= ::isUseTerms()
	oWsObj:isApprover		:= ::isApprover()
	oWsObj:showDashboard	:= ::showDashboard()
	oWsObj:uploadToken		:= "" 

	if oUtils:isNotNull(oCustomer)
		oWsObj:customer := oCustomer:toWsObject() 
	endIf
	
	if oUtils:isNotNull(oSeller)
		oWsObj:seller := oSeller:toWsObject() 
	endIf
	
	if oUtils:isNotNull(oAppProfile)
		oWsObj:approverProfile := oAppProfile:toWsObject() 
	endIf

return oWsObj


/*/{Protheus.doc} fromWsObject

Popula as propriedades do objeto conforme a respectiva instancia da classe de Web Service
	
@author victorhugo
@since 26/02/2016

@param oWsObj, WsCbcUser, Instancia da respectiva classe de Web Service
/*/
method fromWsObject(oWsObj) class CbcUser
	
	local oCustomer := nil
	local oSeller	:= nil
	local oUtils    := LibUtilsObj():newLibUtilsObj()
	
	::setId(oWsObj:id)
	::setName(oWsObj:name)
	::setLastName(oWsObj:lastName)
	::setLogin(oWsObj:login)
	::setPassword(oWsObj:password)
	::setEmail(oWsObj:email)
	::setDepartment(oWsObj:department)
	::setGroup(oWsObj:group)
	::setGroupName(oWsObj:groupName)
	::setErpId(oWsObj:erpId)
	::setBlocked(oWsObj:isBlocked) 
	::setLastLogin(oWsObj:lastLogin) 
	::setUseTerms(oWsObj:isUseTerms)
	::setApprover(oWsObj:isApprover) 

	if oUtils:isNotNull(oWsObj:customer)
		 oCustomer := CbcCustomer():newCbcCustomer()
		 oCustomer:fromWsObject(oWsObj:customer) 
	endIf

	::setCustomer(oCustomer)
	
	if oUtils:isNotNull(oWsObj:seller)
		 oSeller := CbcSeller():newCbcSeller()
		 oSeller:fromWsObject(oWsObj:seller) 
	endIf 
	
	::setSeller(oSeller)

return


/*/{Protheus.doc} getFullName

Retorna o Nome Completo do Usuário
	
@author victorhugo
@since 12/08/2016
/*/
method getFullName() class CbcUser
	
	local cFullName := ""
	local cName     := ::getName()
	local cLastName := ::getLastName()
	
	if !Empty(cName)
		cFullName := AllTrim(Capital(cName))
	endIf
	
	if !Empty(cLastName)
		cFullName += " "+AllTrim(Capital(cLastName))
	endIf

return AllTrim(cFullName)


/*/{Protheus.doc} toJsonObject

Retorna uma instancia JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonObject() class CbcUser
	
	local oJson 	    := JsonObject():new()
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local oCustomer 	:= ::getCustomer()
	local oSeller		:= ::getSeller()
	local oAppProfile	:= ::getAppProfile()
	
	oJson["id"] 			 := ::getId()
	oJson["name"] 			 := ::getName()
	oJson["lastName"] 		 := ::getLastName()
	oJson["login"] 			 := ::getLogin()
	oJson["email"] 			 := ::getEmail()
	oJson["department"] 	 := ::getDepartment()
	oJson["group"] 			 := ::getGroup()
	oJson["groupName"]		 := ::getGroupName()
	oJson["erpId"] 			 := ::getErpId()
	oJson["isBlocked"] 		 := ::isBlocked() 
	oJson["lastLogin"]		 := oUtils:getJsDate(::getLastLogin()) 
	oJson["useTerms"]		 := ::isUseTerms()
	oJson["isApprover"]		 := ::isApprover()
	oJson["showDashboard"]	 := ::showDashboard()		
	oJson["isAdministrator"] := ::isAdministrator()
	oJson["isSeller"] 		 := ::isSeller()
	oJson["isProspect"]		 := ::isProspect()
	oJson["isCustomer"]		 := ::isCustomer()
	oJson["isAssistant"] 	 := ::isAssistant()
	oJson["isSupervisor"]    := ::isSupervisor()
	oJson["isManager"] 	     := ::isManager()
	oJson["isDirector"]      := ::isDirector()
	oJson["isPswChanged"]    := ::isPswChanged()		
	
	oJson["uploadToken"]	 := "" 		

	if oUtils:isNotNull(oCustomer)
		oJson["customer"] := oCustomer:toJsonObject() 
	endIf
	
	if oUtils:isNotNull(oSeller)
		oJson["seller"] := oSeller:toJsonObject() 
	endIf
	
	if oUtils:isNotNull(oAppProfile)
		oJson["approverProfile"] := oAppProfile:toJsonObject() 
	endIf	

return oJson


/*/{Protheus.doc} toJsonString

Retorna a string JSON do objeto
	
@author victorhugo
@since 08/10/2018
/*/
method toJsonString() class CbcUser	
return ::toJsonObject():toJson()


/*/{Protheus.doc} fromJsonObject

Popula o objeto a partir de um JSON
	
@author victorhugo
@since 08/10/2018
/*/
method fromJsonObject(xJson) class CbcUser
	
	local oCustomer := nil
	local oSeller	:= nil
	local oJson 	:= JsonObject():new()	
	local oUtils    := LibUtilsObj():newLibUtilsObj()
	
	if (ValType(xJson) == "C")
		oJson:fromJson(xJson)
	else
		oJson := xJson
	endIf
	
	::setId(oJson["id"])
	::setName(oJson["name"])
	::setLastName(oJson["lastName"])
	::setLogin(oJson["login"])
	::setPassword(oJson["password"])
	::setEmail(oJson["email"])
	::setDepartment(oJson["department"])
	::setGroup(oJson["group"])
	::setGroupName(oJson["groupName"])
	::setErpId(oJson["erpId"])
	::setBlocked(oJson["isBlocked"]) 
	::setLastLogin(oJson["lastLogin"]) 
	::setUseTerms(oJson["isUseTerms"])
	::setApprover(oJson["isApprover"]) 

	if oUtils:isNotNull(oJson["customer"])
		 oCustomer := CbcCustomer():newCbcCustomer()
		 oCustomer:fromJsonObject(oJson["customer"]) 
	endIf

	::setCustomer(oCustomer)
	
	if oUtils:isNotNull(oJson["seller"])
		 oSeller := CbcSeller():newCbcSeller()
		 oSeller:fromJsonObject(oJson["seller"]) 
	endIf 
	
	::setSeller(oSeller)

return

