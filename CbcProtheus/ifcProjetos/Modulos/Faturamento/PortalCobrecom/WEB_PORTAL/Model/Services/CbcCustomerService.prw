#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch"

#define PROSPECT_STATUS_STAND_BY   "4"
#define PROSPECT_STATUS_CUSTOMER   "6"
#define MAX_SEARCH_RECORDS		   100

/*/{Protheus.doc} CbcCustomerService

Serviços referentes aos Clientes da Cobrecom
    
@author victorhugo
@since 24/02/2016
/*/
class CbcCustomerService from CbcService			
	
	method newCbcCustomerService() constructor
	
	method findByCode()
	method findByCnpj()
	method createProspect()
	method updateProspectStatus()	
	method search() 
	
endClass


/*/{Protheus.doc} newCbcCustomerService

Construtor
    
@author victorhugo
@since 24/02/2016
/*/
method newCbcCustomerService() class CbcCustomerService
return self


/*/{Protheus.doc} findByCode

Retorna um Cliente pelo Código e Loja
	
@author victorhugo
@since 24/02/2016

@param cCode, String, Código do Cliente
@param cUnit, String, Loja do Cliente
@paral lProspect, Logico, Indica se o código informado é referente a um Prospect (por padrão assume .F.)
@paral cUserId, String, ID o Usuário do Portal (opcional)

@return CbcCustomer Cliente solicitado
/*/
method findByCode(cCode, cUnit, lProspect, cUserId) class CbcCustomerService
	
	local cQuery		:= ""
	local cWhere		:= ""
	local oUser			:= nil
	local oCustomer 	:= nil
	local cIdSeller		:= ""
	local oSrvUser		:= CbcUserService():newCbcUserService()  
	local oSql			:= LibSqlObj():newLibSqlObj() 		
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	default lProspect	:= .F.
	default cUserId		:= ""
	
	if !Empty(cUserId)
		oUser := oSrvUser:findById(cUserId)
		if oUtils:isNull(oUser)
			::cErrorMessage := "Usuário inválido"
			return nil
		elseIf (oUser:getGroup() == USER_SELLER)
			cIdSeller := oUser:getSeller():getId()
		endIf
	endIf
	
	if lProspect
		cWhere  := " %SUS.XFILIAL% AND US_COD = '"+cCode+"' AND US_LOJA = '"+cUnit+"' AND %SUS.NOTDEL% "
		if !Empty(cIdSeller)
			cWhere += " AND US_VEND = '"+cIdSeller+"' "
		endIf		
	else
		cWhere  := " %SA1.XFILIAL% AND A1_COD = '"+cCode+"' AND A1_LOJA = '"+cUnit+"' AND %SA1.NOTDEL% "
		if !Empty(cIdSeller) .and. !(cCode == DEFAULT_CUSTOMER_CODE .and. cUnit == DEFAULT_CUSTOMER_UNIT)
			cWhere += " AND A1_VEND = '"+cIdSeller+"' "
		endIf
	endIf
	
	cQuery := createSql(cWhere, lProspect)
	
	oSql:newAlias(cQuery)	
	
	if oSql:hasRecords()
		oCustomer := createFromSql(oSql, lProspect)		 
	endIf
	
	oSql:close() 

return oCustomer

/**
 * Monta a consulta SQL
 */
static function createSql(cWhere, lProspect)
	
	local cQuery	  	:= "" 
	local cRetail		:= if(GetNewPar("ZZ_ONVAREJ", .T.), "A1_ZZVAREJ", "'N'")
	default lProspect 	:= .F.	
	
	cQuery := "SELECT TOP "+AllTrim(Str(MAX_SEARCH_RECORDS))		
	
	if lProspect
	
		cQuery += " US_COD CODE, US_LOJA UNIT, US_NOME NAME, US_NREDUZ SHORT_NAME, US_CGC CNPJ, US_INSCR IE, US_END ADDRESS, ' ' ADD_COMPLEM, "
		cQuery += " US_MUN CITY, US_EST STATE, US_ZZCODMU CITY_CODE, US_CEP ZIP_CODE, US_EMAIL EMAIL, US_DDD DDD, US_TEL PHONE, ' ' BLOCKED, "		
		cQuery += " US_VEND SELLER_CODE, ' ' PAYMENT_CONDITION, ' ' DESC_PAYMENT_COND, ' ' ISSUE_REPORT, ' ' BILL_ADDRESS, ' ' BILL_ADD_COMPLEM, " 
		cQuery += " ' ' BILL_CITY,  ' ' BILL_STATE, ' ' BILL_ZIP_CODE, ' ' CNAE, ' ' DESC_CNAE, ' ' SEGMENT, ' ' PERSON, US_TIPO TYPE, "
		cQuery += " ' ' TAX_PAYER, ' ' NATIONAL_SIMPLE, ' ' SUFRAMA, ' ' SPECIAL_TAX, ' ' RETAIL, ' ' LAST_PURCHASE, "
		cQuery += " US_BAIRRO DISTRICT, ' ' BILL_DISTRICT, ' ' CONTACT, ' ' MAIL_CONTACT, ' ' MAIL_FINANCE "
		cQuery += " FROM %SUS.SQLNAME% "		
		 
	else
	
		cQuery += " A1_COD CODE, A1_LOJA UNIT, A1_NOME NAME, A1_NREDUZ SHORT_NAME, A1_CGC CNPJ, A1_INSCR IE, A1_END ADDRESS, A1_COMPLEM ADD_COMPLEM, "
		cQuery += " A1_MUN CITY, A1_EST STATE, A1_COD_MUN CITY_CODE, A1_CEP ZIP_CODE, A1_EMAIL EMAIL, A1_DDD DDD, A1_TEL PHONE, A1_MSBLQL BLOCKED, "
		cQuery += " A1_VEND SELLER_CODE, A1_COND PAYMENT_CONDITION, E4_DESCRI DESC_PAYMENT_COND, A1_LAUDO ISSUE_REPORT, A1_ENDCOB BILL_ADDRESS, A1_COMPLC BILL_ADD_COMPLEM, " 
		cQuery += " A1_MUNC BILL_CITY,  A1_ESTC BILL_STATE, A1_CEPC BILL_ZIP_CODE, A1_CNAE CNAE, CC3_DESC DESC_CNAE, X5_DESCRI SEGMENT, A1_PESSOA PERSON, A1_TIPO TYPE, "
		cQuery += " A1_CONTRIB TAX_PAYER, A1_SIMPNAC NATIONAL_SIMPLE, A1_CALCSUF SUFRAMA, A1_REGESIM SPECIAL_TAX, " + cRetail + " RETAIL, A1_ULTCOM LAST_PURCHASE, "
		cQuery += " A1_BAIRRO DISTRICT, A1_BAIRROC BILL_DISTRICT, A1_CONTATO CONTACT, A1_EMAILCT MAIL_CONTACT, A1_EMAILFI MAIL_FINANCE, SA1.R_E_C_N_O_ RECNO "
		cQuery += " FROM %SA1.SQLNAME%"
		cQuery += "  	LEFT JOIN %SE4.SQLNAME% ON "
		cQuery += " 		%SE4.XFILIAL% AND E4_CODIGO = A1_COND AND %SE4.NOTDEL% "
		cQuery += "  	LEFT JOIN %CC3.SQLNAME% ON "
		cQuery += " 		%CC3.XFILIAL% AND CC3_COD = A1_CNAE AND %CC3.NOTDEL% "
		cQuery += " 	LEFT JOIN %SX5.SQLNAME% ON "
		cQuery += " 		%SX5.XFILIAL% AND X5_TABELA = 'ZK' AND X5_CHAVE = A1_SEGMENT AND %SX5.NOTDEL% "
		 
	endIf
	
	cQuery += " WHERE " + cWhere		
	
return cQuery

/**
 * Criação do cliente a partir do objeto SQL
 */
static function createFromSql(oSql, lProspect)
	
	local oCustomer   := CbcCustomer():newCbcCustomer()
	local oUtils	  := LibUtilsObj():newLibUtilsObj()
	default lProspect := .F.
	
	oCustomer:setCode(oSql:getValue("CODE"))
	oCustomer:setUnit(oSql:getValue("UNIT"))
	oCustomer:setName(oSql:getValue("AllTrim(NAME)"))
	oCustomer:setShortName(oSql:getValue("AllTrim(SHORT_NAME)"))
	oCustomer:setCnpj(oSql:getValue("CNPJ"))
	oCustomer:setIe(oSql:getValue("IE"))
	oCustomer:setAddress(oSql:getValue("AllTrim(ADDRESS) + if (!Empty(ADD_COMPLEM), ' - ' + AllTrim(ADD_COMPLEM), '') "))
	oCustomer:setCity(oSql:getValue("AllTrim(CITY)"))
	oCustomer:setState(oSql:getValue("STATE"))
	oCustomer:setZipCode(oSql:getValue("if (Empty(ZIP_CODE), '', Left(AllTrim(ZIP_CODE), 5)) + '-' + Right(AllTrim(ZIP_CODE), 3)"))
	oCustomer:setCityCode(oSql:getValue("CITY_CODE"))
	oCustomer:setBillAddress(oSql:getValue("AllTrim(BILL_ADDRESS) + if (!Empty(BILL_ADD_COMPLEM), ' - ' + AllTrim(BILL_ADD_COMPLEM), '') "))	
	oCustomer:setBillCity(oSql:getValue("AllTrim(BILL_CITY)"))
	oCustomer:setBillState(oSql:getValue("BILL_STATE"))
	oCustomer:setBillZipCode(oSql:getValue("if (Empty(BILL_ZIP_CODE), '', Left(AllTrim(BILL_ZIP_CODE), 5)) + '-' + Right(AllTrim(BILL_ZIP_CODE), 3)"))
	oCustomer:setEmail(oSql:getValue("AllTrim(EMAIL)"))
	oCustomer:setDDD(oSql:getValue("DDD"))
	oCustomer:setPhone(oSql:getValue("PHONE"))
	oCustomer:setBlocked(oSql:getValue("(BLOCKED == '1')")) 
	oCustomer:setProspect(lProspect)
	oCustomer:setIssueReport(oSql:getValue("AllTrim(ISSUE_REPORT)"))
	oCustomer:setSeller(CbcSeller():newCbcSeller(oSql:getValue("SELLER_CODE")))
	oCustomer:setPerson(oSql:getValue("if (PERSON == 'F', 'Física', 'Jurídica')"))	
	oCustomer:setTaxPayer(oSql:getValue("if (TAX_PAYER == '1', 'Sim', 'Não')"))
	oCustomer:setNationalSimple(oSql:getValue("if (NATIONAL_SIMPLE == '1', 'Sim', 'Não')"))
	oCustomer:setSpecialTax(oSql:getValue("if (SPECIAL_TAX == '1', 'Sim', 'Não')"))
	oCustomer:setRetail(oSql:getValue("(RETAIL == 'S')"))
	oCustomer:setSegment(oSql:getValue("AllTrim(SEGMENT)"))
	oCustomer:setDistrict(oSql:getValue("AllTrim(DISTRICT)"))
	oCustomer:setBillDistrict(oSql:getValue("AllTrim(BILL_DISTRICT)"))
	oCustomer:setContact(oSql:getValue("AllTrim(CONTACT)"))
	oCustomer:setMailContact(oSql:getValue("AllTrim(MAIL_CONTACT)"))
	oCustomer:setMailFinance(oSql:getValue("AllTrim(MAIL_FINANCE)"))
	oCustomer:setRecno(oSql:getValue("RECNO"))
	
	if oSql:getValue("!Empty(PAYMENT_CONDITION)")
		oCustomer:setPaymentCondition(oSql:getValue("PAYMENT_CONDITION"))	
		oCustomer:setDescPayment(oSql:getValue("AllTrim(DESC_PAYMENT_COND)"))
	endIf
	
	if oSql:getValue("!Empty(CNAE)")	
		oCustomer:setCnae(oSql:getValue("AllTrim(CNAE) + ' - ' + AllTrim(DESC_CNAE)"))
	endIf
	
	if oSql:getValue("!Empty(LAST_PURCHASE)")	
		oCustomer:setLastPurchase(oUtils:strAnyType(oSql:getValue("StoD(LAST_PURCHASE)"), "DD/MM/AAAA"))
	endIf		
	
	setType(oSql, @oCustomer)
	setSuframa(oSql, @oCustomer)
	
return oCustomer


/**
 * Define o Tipo do Cliente 
 */
static function setType(oSql, oCustomer)

	local cType := oSql:getValue("TYPE")
	
	if (cType == "F")
		cType := "Consumidor Final"
	elseIf (cType == "L")
		cType := "Produtor Rural"
	elseIf (cType == "R")
		cType := "Revendedor"
	elseIf (cType == "S")
		cType := "Solidário"
	elseIf (cType == "X")
		cType := "Exportação"
	endIf
	
	oCustomer:setType(cType)

return

/**
 * Define o SUFRAMA do Cliente 
 */
static function setSuframa(oSql, oCustomer)
	
	local cSuframa := oSql:getValue("SUFRAMA")
	
	if (cSuframa == "S")
		cSuframa := "Sim"
	elseIf (cSuframa == "N")
		cSuframa := "Não"
	elseIf (cSuframa == "I")
		cSuframa := "ICMS"
	endIf
	
	oCustomer:setSuframa(cSuframa)
	
return


/*/{Protheus.doc} findByCnpj

Retorna um Cliente pelo CNPJ
	
@author victorhugo
@since 24/02/2016

@param cCnpj, String, CNPJ do Cliente
@paral cUserId, String, ID o Usuário do Portal (opcional)

@return CbcCustomer Cliente solicitado
/*/
method findByCnpj(cCnpj, cUserId) class CbcCustomerService
	
	local oCustomer := nil
	local cCode		:= ""
	local cUnit		:= "" 
	local lProspect := .F.
	local oSql		:= LibSqlObj():newLibSqlObj()
	
	if Empty(cCnpj)
		return nil
	endIf
	
	cCnpj := clearCnpj(cCnpj) 
	
	oSql:newTable("SA1", "A1_COD CODE, A1_LOJA UNIT", "%SA1.XFILIAL% AND A1_CGC = '"+cCnpj+"'") 
	
	if oSql:hasRecords()
		cCode := oSql:getValue("CODE")
		cUnit := oSql:getValue("UNIT")	
	else
		oSql:newTable("SUS", "US_COD CODE, US_LOJA UNIT", "%SUS.XFILIAL% AND US_CGC = '"+cCnpj+"'")
		if oSql:hasRecords()
			lProspect := .T.
			cCode 	  := oSql:getValue("CODE")
			cUnit     := oSql:getValue("UNIT")	
		endIf
	endIf
	
	oSql:close()
	
	if !Empty(cCode)
		oCustomer := ::findByCode(cCode, cUnit, lProspect, cUserId) 
	endIf
	
return oCustomer

/**
 * Retorna só os numeros do CNPJ
 */
static function clearCnpj(cCnpj)
	
	cCnpj := AllTrim(cCnpj)
	cCnpj := StrTran(cCnpj, ".", "")
	cCnpj := StrTran(cCnpj, "-", "")
	cCnpj := StrTran(cCnpj, "/", "")
	
return cCnpj


/*/{Protheus.doc} createProspect

Cadastra um novo Cliente como Prospect
	
@author victorhugo
@since 24/02/2016

@param oCustomer, CbcCustomer, Cliente Cobrecom
@param cCode, String, Código gerado para o Prospect
@param cUnit, String, Loja gerada para o Prospect
/*/
method createProspect(oCustomer, cCode, cUnit) class CbcCustomerService
	
	local lOk := .F.
	
	if validRequiredData(@self, @oCustomer)
		lOk := createProspect(@self, oCustomer, @cCode, @cUnit)
	endIf
	
return lOk


/**
 * Valida os campos obrigatórios para criação do Prospect
 */
static function validRequiredData(oSelf, oCustomer)
	
	local lOk   := .F.
	local cMsg  := ""
	local cCnpj := clearCnpj(oCustomer:getCnpj()) 
	local oSql	:= LibSqlObj():newLibSqlObj()
	
	oCustomer:setCnpj(cCnpj)
	
	begin sequence
		
		if Empty(oCustomer:getName())
			cMsg := "Razão Social não informada"
			break
		endIf
		
		if Empty(oCustomer:getCnpj())
			cMsg := "CNPJ não informado"
			break
		endIf
		
		if oSql:exists("SUS", "%SUS.XFILIAL% AND US_CGC = '"+oCustomer:getCnpj()+"'") .or. ;
		   oSql:exists("SA1", "%SA1.XFILIAL% AND A1_CGC = '"+oCustomer:getCnpj()+"'") 
			cMsg := "CNPJ já cadastrado"
			break
		endIf
		
		if Empty(oCustomer:getState())
			cMsg := "Estado não informado"
			break
		endIf
		
		if !oSql:exists("SX5", "%SX5.XFILIAL% AND X5_TABELA = '12' AND X5_CHAVE = '"+oCustomer:getState()+"'")
			cMsg := "Estado inválido"
			break
		endIf
		
		if Empty(oCustomer:getCityCode())
			cMsg := "Código do Município não informado"
			break
		endIf
		
		if !oSql:exists("CC2", "%CC2.XFILIAL% AND CC2_EST = '"+oCustomer:getState()+"' AND CC2_CODMUN = '"+oCustomer:getCityCode()+"'")
			cMsg := "Código do Município inválido"
			break
		endIf
		
		if Empty(oCustomer:getEmail())
			cMsg := "E-mail não informado"
			break
		endIf
		
		lOk := .T.
		
	end sequence
	
	if !lOk
		oSelf:cErrorMessage := cMsg
	endIf
	
return lOk


/**
 * Gravação do Prospect
 */
static function createProspect(oSelf, oCustomer, cCode, cUnit)
	
	local lOk 	 	 := .F.
	local aData  	 := {}	
	local cShortName := oCustomer:getShortName()
	local oSql		 := LibSqlObj():newLibSqlObj()		
	
	if Empty(cShortName)
		cShortName := oCustomer:getName() 
	endIf
	
	cCode := GetSxeNum("SUS", "US_COD")  
	cUnit := "01" 			
	
	aAdd(aData, {"US_FILIAL", xFilial("SUS")})
	aAdd(aData, {"US_COD", cCode})
	aAdd(aData, {"US_LOJA", cUnit})
	aAdd(aData, {"US_NOME", oCustomer:getName()})
	aAdd(aData, {"US_NREDUZ", cShortName})
	aAdd(aData, {"US_CGC", oCustomer:getCnpj()})
	aAdd(aData, {"US_END", oCustomer:getAddress()})
	aAdd(aData, {"US_MUN", oCustomer:getCity()})
	aAdd(aData, {"US_EST", oCustomer:getState()})
	aAdd(aData, {"US_ZZCODMU", oCustomer:getCityCode()})
	aAdd(aData, {"US_CEP", oCustomer:getZipCode()})
	aAdd(aData, {"US_EMAIL", oCustomer:getEmail()})
	aAdd(aData, {"US_DDD", oCustomer:getDDD()})
	aAdd(aData, {"US_TEL", oCustomer:getPhone()})
	aAdd(aData, {"US_TIPO", "R"})
	aAdd(aData, {"US_ORIGEM", "3"})
	aAdd(aData, {"US_STATUS", "4"}) 
		
	if oSql:insert("SUS", aData)
		lOk := .T.
		ConfirmSx8()
		sendWelcomeEmail(oCustomer)
	else
		RollBackSx8() 
		oSelf:cErrorMessage := "Falha ao gravar Prospect"
 	endIf
	
return lOk

/**
 * Envia e-mail de boas vindas para novos clientes
 */
static function sendWelcomeEmail(oCustomer)
	
	local lOk 			:= .F.
	local oMail 		:= LibMailObj():newLibMailObj()
	local cBody			:= ""	
	local cMailHtml 	:= COMPANY_WELCOME_HTML	
	local cTo	   		:= oCustomer:getEmail()
	local cSubject		:= "Seja bem-vindo(a) ao Portal Cobrecom"
	
	if File(cMailHtml)
		cBody := MemoRead(cMailHtml)
		cBody := StrTran(cBody, "%companyName%", oCustomer:getName())
	else	
		return 
	endIf
	
	oMail:send(cTo, cSubject, cBody)
	
return


/*/{Protheus.doc} updateProspectStatus

Atualiza o Status de um Prospect de acordo com o CNPJ
	
@author victorhugo
@since 16/03/2016

@param cCnpj, String, CNPJ do Cliente/Prospect
@param lIsCustomerDelete, Logico, Indica se a chamada está sendo feita a partir da Exclusão do Cliente
/*/
method updateProspectStatus(cCnpj, lIsCustomerDelete) class CbcCustomerService
	
	local oSql 					:= LibSqlObj():newLibSqlObj()
	local cCode					:= ""
	local cUnit					:= "" 
	local cStatus				:= PROSPECT_STATUS_STAND_BY
	default lIsCustomerDelete	:= .F.
	
	oSql:newTable("SUS", "US_COD CODE, US_LOJA UNIT", "%SUS.XFILIAL% AND US_CGC = '"+cCnpj+"'")
	
	if oSql:hasRecords()
		cCode	:= oSql:getValue("CODE")
		cUnit	:= oSql:getValue("UNIT")
	else
		oSql:close()
		return
	endIf
	
	if lIsCustomerDelete
		oSql:update("SUS", "US_CODCLI = '', US_LOJACLI = '', US_STATUS = '"+cStatus+"'", "%SUS.XFILIAL% AND US_CGC = '"+cCnpj+"'")
	else
		oSql:newTable("SA1", "A1_COD CODE, A1_LOJA UNIT", "%SA1.XFILIAL% AND A1_CGC = '"+cCnpj+"'")
		if oSql:hasRecords()
			cStatus := PROSPECT_STATUS_CUSTOMER
			cCode	:= oSql:getValue("CODE")
			cUnit	:= oSql:getValue("UNIT")
		endif
		oSql:close()
		oSql:update("SUS", "US_CODCLI = '"+cCode+"', US_LOJACLI = '"+cUnit+"', US_STATUS = '"+cStatus+"'", "%SUS.XFILIAL% AND US_CGC = '"+cCnpj+"'")	
	endIf		 
	
	updateUsersGroup(cCnpj, cStatus, cCode, cUnit)
	
return

/**
 * Atualiza os Grupos dos Usuários
 */
static function updateUsersGroup(cCnpj, cStatus, cCode, cUnit)

	local cQuery 	 := ""  
	local cGroup	 := "" 
	local oSql	 	 := LibSqlObj():newLibSqlObj() 
	local oUserSrv	 := CbcUserService():newCbcUserService() 
	
	cQuery := " SELECT ZP1_CODIGO USER_ID "
	cQuery += " FROM %ZP1.SQLNAME% "
	
	if (cStatus == PROSPECT_STATUS_STAND_BY)
		cGroup := USER_PROSPECT
		cQuery += " INNER JOIN %SA1.SQLNAME% ON "
		cQuery += " 	%SA1.XFILIAL% AND A1_COD = ZP1_CODCLI AND A1_LOJA = ZP1_LOJCLI AND "
		cQuery += " 	A1_CGC = '"+cCnpj+"' AND %SA1.NOTDEL% " 
	elseIf (cStatus == PROSPECT_STATUS_CUSTOMER)
		cGroup := USER_CUSTOMER
		cQuery += " INNER JOIN %SUS.SQLNAME% ON "
		cQuery += " 	%SUS.XFILIAL% AND US_COD = ZP1_CODPRO AND US_LOJA = ZP1_LOJPRO AND "
		cQuery += " 	US_CGC = '"+cCnpj+"' AND %SUS.NOTDEL% "
	endIf
	
	cQuery += " WHERE %ZP1.XFILIAL% AND %ZP1.NOTDEL% " 
	cQuery += " ORDER BY 1 "
	
	oSql:newAlias(cQuery)
	
	while oSql:notIsEof()
		
		oUserSrv:setUserGroup(oSql:getValue("USER_ID"), cGroup, cCode, cUnit)
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return


/*/{Protheus.doc} search

Pesquisa Clientes
	
@author victorhugo
@since 31/03/2016

@param cUserId, String, ID do Usuário solicitante
@param cKeyWord, String, Palavra-chave para busca
@param lShowBlocked, Logico, Indica se deve exibir os clientes bloqueados. Por padrão assume .F.
@param cSegment, String, Segmento do Cliente (opcional)

@return Vetor Lista de Clientes encontrados
/*/
method search(cUserId, cKeyWord, lShowBlocked, cSegment) class CbcCustomerService
	
	local aCustomers 		:= {}
	local oUtils	 		:= LibUtilsObj():newLibUtilsObj()
	local oSrvUser	 		:= CbcUserService():newCbcUserService()
	local oUser		 		:= oSrvUser:findById(cUserId)	
	default cKeyWord		:= ""
	default cSegment		:= ""
	default lShowBlocked	:= .F.
	
	if oUtils:isNull(oUser)
		::cErrorMessage := "Usuário inválido" 
	else
		aCustomers := searchCustomers(oUser, cKeyWord, lShowBlocked, cSegment)
		if (Len(aCustomers) == 0)
			::cErrorMessage := "Nenhum cliente encontrado" 
		endIf 
	endIf	

return aCustomers

/**
 * Pesquisa os Clientes
 */
static function searchCustomers(oUser, cKeyWord, lShowBlocked, cSegment)
	
	local cQuery	  := ""	
	local cWhere 	  := ""	
	local aCustomers  := {}
	local lProspect	  := .F.
	local oSql		  := LibSqlObj():newLibSqlObj()	
	
	cKeyWord := AllTrim(Lower(cKeyWord))
	cKeyWord := StrTran(cKeyWord, ".", "")
	cKeyWord := StrTran(cKeyWord, ",", "")
	cKeyWord := StrTran(cKeyWord, "/", "")
	cKeyWord := StrTran(cKeyWord, "-", "")
	
	cWhere := " %SA1.XFILIAL% AND ( RTrim(Lower(A1_COD)) LIKE '%"+cKeyWord+"%' OR A1_CGC LIKE '%"+cKeyWord+"%' OR "
	cWhere += " Rtrim(Lower(A1_NOME)) LIKE '%"+cKeyWord+"%' OR  Rtrim(Lower(A1_NREDUZ)) LIKE '%"+cKeyWord+"%' ) "
	
	if (oUser:getGroup() == USER_SELLER)
		cWhere += " AND (A1_VEND = '"+oUser:getSeller():getId()+"' OR ( A1_COD = '"+DEFAULT_CUSTOMER_CODE+"' AND A1_LOJA = '"+DEFAULT_CUSTOMER_UNIT+"' )) "
	endIf
	
	if (!lShowBlocked)
		cWhere += " AND A1_MSBLQL != '1' " 		
		cWhere += " AND A1_REVIS = '1' "
	endIf	
	
	if !Empty(cSegment)
		cWhere += " AND A1_SEGMENT = '" + cSegment + "' "
	endIf
	
	cWhere += " AND %SA1.NOTDEL% "
	
	cQuery := createSql(cWhere, lProspect)
	
	cQuery += " ORDER BY A1_NOME "
	
	oSql:newAlias(cQuery)
	
	while oSql:notIsEof()
		
		aAdd(aCustomers, createFromSql(oSql))
		
		oSql:skip() 		 
	endDo
	
	oSql:close()
	
return aCustomers

