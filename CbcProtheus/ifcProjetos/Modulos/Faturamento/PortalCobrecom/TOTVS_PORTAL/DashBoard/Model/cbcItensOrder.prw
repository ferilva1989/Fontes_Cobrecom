#include 'protheus.ch'

class cbcItensOrder 
	
	data cItem
	data cProduct
	data cDescription
	data cFullDescription
	data nSalesPrice
	data nValue
	data cPackage
	data nLances
	data nSalesQuant
	data nMetrage
	data nInvoiceQuant
	data cItmStatus
	data cItmColor
	data cItmIcon
	data cFamilia
	data cBitola
	data cCor
	data cUM
	
	data cWhere
	
	method newcbcItensOrder() constructor 
	
	method getQuery()
	method setWhere()
	method execAfterQry()

endclass

method newcbcItensOrder() class cbcItensOrder
return(self)


method getQuery() class cbcItensOrder
	local cQuery := ''
	if !empty(::cWhere)

		cQuery += " SELECT "
		cQuery += " SC6.C6_ITEM 	AS cItem, 		"
		cQuery += " SC6.C6_PRODUTO	AS cProduct, 	"
		cQuery += " SC6.C6_DESCRI	AS cDescription,"
		cQuery += " SC6.C6_PRCVEN	AS nSalesPrice, "
		cQuery += " SC6.C6_VALOR	AS nValue, 		"
		cQuery += " SC6.C6_ACONDIC	AS cPackage, 	"
		cQuery += " SC6.C6_LANCES	AS nLances, 	"
		cQuery += " SC6.C6_QTDVEN	AS nSalesQuant, 	"
		cQuery += " SC6.C6_METRAGE	AS nMetrage, 	"
		cQuery += " SC6.C6_QTDENT	AS nInvoiceQuant, "
		cQuery += " SB1.B1_UM 		AS cUM, "
		cQuery += " SZ1.Z1_DESC 	AS cFamilia, "
		cQuery += " SZ2.Z2_DESC 	AS cBitola, "
		cQuery += " SZ3.Z3_DESC 	AS cCor "
		
		cQuery += " FROM  %SC6.SQLNAME% "
		
		cQuery += " INNER JOIN %SB1.SQLNAME% ON "
		cQuery += " %SB1.XFILIAL% "
		cQuery += " AND SC6.C6_PRODUTO	= SB1.B1_COD   "
		cQuery += " AND SC6.D_E_L_E_T_	= SB1.D_E_L_E_T_ "
	
		cQuery += " INNER JOIN %SZ1.SQLNAME% ON "
		cQuery += " %SZ1.XFILIAL% "
		cQuery += " AND SB1.B1_NOME	= SZ1.Z1_COD   "
		cQuery += " AND SB1.D_E_L_E_T_	= SZ1.D_E_L_E_T_ "
		
		cQuery += " INNER JOIN %SZ2.SQLNAME% ON "
		cQuery += " %SZ2.XFILIAL% "
		cQuery += " AND SB1.B1_BITOLA	= SZ2.Z2_COD   "
		cQuery += " AND SB1.D_E_L_E_T_	= SZ2.D_E_L_E_T_ "
		
		cQuery += " INNER JOIN %SZ3.SQLNAME% ON "
		cQuery += " %SZ3.XFILIAL% "
		cQuery += " AND SB1.B1_COR		= SZ3.Z3_COD   "
		cQuery += " AND SB1.D_E_L_E_T_	= SZ3.D_E_L_E_T_ "
		
		cQuery += ::cWhere
		cQuery += " ORDER BY SC6.C6_ITEM ASC "

	endif
return (cQuery)

method setWhere(cFil, cOrderNum) class cbcItensOrder
	default cFil		:= ''
	default cOrderNum	:= ''

	if ! empty(cFil) .and. ! empty(cOrderNum)
		::cWhere := " WHERE SC6.C6_FILIAL = '" + cFil + "' "
		::cWhere += " AND SC6.C6_NUM = '" + cOrderNum + "' "
		::cWhere += " AND %SC6.NOTDEL% "
	endif
return(self)

method execAfterQry() class cbcItensOrder
	::cPackage 	 		:= U_getNamePack(::cPackage)
	::cItmStatus 			:= '' 
	::cItmColor			:= 'success'
	::cItmIcon			:= ''	
	getFullDescr(self)
	clearSer(Self)
return(self)


static function clearSer(oSelf) 
	oSelf:cWhere 		:= ''
	oSelf:cFamilia 	:= ''
	oSelf:cBitola		:= ''
	oSelf:cPackage	:= ''
	oSelf:cUM		:= ''
	oSelf:cCor		:= ''
return (nil)


static function getFullDescr(oSelf)
	oSelf:cFullDescription := Alltrim(oSelf:cFamilia) + ' '+ Alltrim(oSelf:cBitola)  + ' ' + Alltrim(oSelf:cPackage) + ' ' + Alltrim(cValToChar(oSelf:nMetrage) + ' '+ Alltrim(oSelf:cUM)) + ' '+ Alltrim(oSelf:cCor)
return(nil)

