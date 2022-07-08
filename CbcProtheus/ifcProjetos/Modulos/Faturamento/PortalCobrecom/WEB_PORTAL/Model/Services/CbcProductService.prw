#include "totvs.ch"
#include "rwmake.ch"


/*/{Protheus.doc} CbcProductService

Serviços referentes aos Produtos do Portal Cobrecom
    
@author victorhugo
@since 24/02/2016
/*/
class CbcProductService from CbcService
	
	method newCbcProductService() constructor
	data lUsrEsp
	
	method findByCode()
	method getProperties()
	method getColors()
	method getPackageDescription()
	
endClass


/*/{Protheus.doc} newCbcProductService

Construtor
    
@author victorhugo
@since 24/02/2016
/*/
method newCbcProductService(lUsrEsp) class CbcProductService
	default lUsrEsp := .F.

	::lUsrEsp := lUsrEsp
return self


/*/{Protheus.doc} findByCode

Retorna um Produto pelo Código
	
@author victorhugo
@since 24/02/2016

@param cCode, String, Código do Produto

@return Vetor Lista de Notificações (CbcNotification) 
/*/
method findByCode(cCode) class CbcProductService
	
	local cQuery   := "" 
	local oProduct := nil
	local oSql 	   := LibSqlObj():newLibSqlObj()	
	
	cQuery := " SELECT B1_COD CODE, B1_DESC DESCRIPTION, B1_NOME CODE_NAME, Z1_DESC NAME, "
	cQuery += " 	   B1_BITOLA CODE_BITOLA, Z2_DESC BITOLA, B1_COR CODE_COLOR, Z3_DESC COLOR "
	cQuery += " FROM %SB1.SQLNAME% "
	cQuery += " 	INNER JOIN %SZ1.SQLNAME% ON "
	cQuery += " 		%SZ1.XFILIAL% AND Z1_COD = B1_NOME AND %SZ1.NOTDEL% "
	cQuery += " 	INNER JOIN %SZ2.SQLNAME% ON "
	cQuery += " 		%SZ2.XFILIAL% AND Z2_COD = B1_BITOLA AND %SZ2.NOTDEL% "
	cQuery += " 	INNER JOIN %SZ3.SQLNAME% ON "
	cQuery += " 		%SZ3.XFILIAL% AND Z3_COD = B1_COR AND %SZ3.NOTDEL% "
	cQuery += " WHERE %SB1.XFILIAL% AND B1_COD = '"+cCode+"' AND %SB1.NOTDEL% "  
	
	oSql:newAlias(cQuery)
	
	if oSql:hasRecords()
		oProduct := CbcProduct():newCbcProduct()
		oProduct:setCode(oSql:getValue("CODE"))
		oProduct:setDescription(oSql:getValue("AllTrim(DESCRIPTION)"))
		oProduct:setName(oSql:getValue("AllTrim(NAME)"))
		oProduct:setCodeName(oSql:getValue("CODE_NAME"))
		oProduct:setBitola(oSql:getValue("AllTrim(BITOLA)"))
		oProduct:setCodeBitola(oSql:getValue("CODE_BITOLA"))
		oProduct:setColor(oSql:getValue("AllTrim(COLOR)"))
		oProduct:setCodeColor(oSql:getValue("CODE_COLOR"))
	endIf
	
	oSql:close()
	
return oProduct


/*/{Protheus.doc} getProperties

Retorna as Propriedades dos Produtos (Nomes, Bitolas ou Cores)
	
@author victorhugo
@since 22/06/2016
/*/
method getProperties(cProperty) class CbcProductService
	
	local aValues	:= {} 
	local cAlias	:= ""
	local cFields	:= ""
	local cWhere	:= ""
	local cGroupBy	:= "" 
	local cOrderBy	:= "2"
	local cProperty	:= AllTrim(Lower(cProperty))
	local oObj    	:= nil
	local oSql		:= LibSqlObj():newLibSqlObj()
	
	if (cProperty == "name")
		cAlias 	:= "SZ1"
		cFields	:= "Z1_COD ID, Z1_DESC VALUE"
		// cWhere	:= "%SZ1.XFILIAL% AND Z1_XPORTAL = 'S'"
		cWhere	:= "%SZ1.XFILIAL% AND " + iif(::lUsrEsp,"Z1_XPORTAL IN ('S', 'E')","Z1_XPORTAL = 'S'")
	elseIf (cProperty == "bitola")
		cAlias 	:= "SZ2"
		cFields	:= "Z2_COD ID, Z2_DESC VALUE"
		// cWhere	:= "%SZ2.XFILIAL% AND Z2_XPORTAL = 'S'"
		cWhere	:= "%SZ2.XFILIAL% AND " + iif(::lUsrEsp,"Z2_XPORTAL IN ('S', 'E')","Z2_XPORTAL = 'S'")
		cOrderBy:= "1" 
	elseIf (cProperty == "color")
		cAlias 	:= "SZ3"
		cFields	:= "Z3_COD ID, Z3_DESC VALUE"
		// cWhere	:= "%SZ3.XFILIAL% AND Z3_XPORTAL = 'S'"
		cWhere	:= "%SZ3.XFILIAL% AND " + iif(::lUsrEsp,"Z3_XPORTAL IN ('S', 'E')","Z3_XPORTAL = 'S'")
	else
		return {}
	endIf
	
	oSql:newTable(cAlias, cFields, cWhere, cGroupBy, cOrderBy)

	while oSql:notIsEof()
		
		oObj := CbcGeneric():newCbcGeneric(oSql:getValue("ID"), oSql:getValue("AllTrim(VALUE)"))
		
		aAdd(aValues, oObj) 
		
		oSql:skip()
	endDo
	
	oSql:close()
	
return aValues	


/*/{Protheus.doc} getColors

Retorna as Cores dos Produtos de acordo com o Nome e a Bitola
	
@author victorhugo
@since 22/06/2016
/*/
method getColors(cName, cBitola) class CbcProductService
	
	local oColor  := nil
	local aColors := {}
	local cQuery  := ""
	local oSql	  := LibSqlObj():newLibSqlObj()
	
	if (Empty(cName) .or. Empty(cBitola))
		return {}
	endIf
	
	cQuery := " SELECT DISTINCT B1_COR [ID], Z3_DESC [VALUE] "
	cQuery += " FROM %SB1.SQLNAME% "
	cQuery += " 	INNER JOIN %SZ3.SQLNAME% ON "
	cQuery += "  		%SZ3.XFILIAL% AND Z3_COD = B1_COR AND " + iif(::lUsrEsp,"Z1_XPORTAL IN ('S', 'E')","Z1_XPORTAL = 'S'") + " AND %SZ3.NOTDEL% "
	cQuery += " WHERE %SB1.XFILIAL% AND B1_NOME = '"+cName+"' AND B1_BITOLA = '"+cBitola+"' AND %SB1.NOTDEL% "
	cQuery += " ORDER BY 2  "
	
	oSql:newAlias(cQuery)
	
	while oSql:notIsEof()
		
		oColor := CbcGeneric():newCbcGeneric(oSql:getValue("ID"), oSql:getValue("AllTrim(VALUE)"))
		
		aAdd(aColors, oColor)
		
		oSql:skip()
	endDo
	
	oSql:close()

return aColors


/*/{Protheus.doc} getPackageDescription

Retorna a Descrição de um Acondicionamento
	
@author victorhugo
@since 15/09/2016
/*/
method getPackageDescription(cPackage) class CbcProductService
	
	local cDescription := ""
	
	if (cPackage == "R")
		cDescription := "Rolo"
	elseIf (cPackage == "B")
		cDescription := "Bobina"
	elseIf (cPackage == "C")
		cDescription := "Carretel Plastico"
	elseIf (cPackage == "M")
		cDescription := "Carretel Madeira"
	elseIf (cPackage == "T")
		cDescription := "Retalho"
	elseIf (cPackage == "L")
		cDescription := "Blister"
	endIf

return cDescription
