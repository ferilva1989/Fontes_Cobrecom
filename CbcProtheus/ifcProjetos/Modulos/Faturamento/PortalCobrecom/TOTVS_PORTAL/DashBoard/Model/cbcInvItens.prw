#include 'protheus.ch'

class cbcInvItens 

	data cOrder
	data cItemPv
	data cItemInv
	data nSalesPrice
	data nSalesQtd
	data cProductDesc
	data nTotalItm
	data cWhere
	method newcbcInvItens() constructor 
	method getQuery()
	method setWhere()
	method execAfterQry()

endclass

method newcbcInvItens() class cbcInvItens

return


method getQuery() class cbcInvItens
	local cQuery := ''
	if !empty(::cWhere)

		cQuery += " SELECT "
		cQuery += " SD2.D2_ITEMPV 							AS cItemPv, 		"
		cQuery += " SD2.D2_ITEM 							AS cItemInv, 		"
		cQuery += " SD2.D2_PRCVEN 							AS nSalesPrice, 	"
		cQuery += " SD2.D2_QUANT 							AS nSalesQtd, 		"
		cQuery += " SD2.D2_TOTAL 							AS nTotalItm,		"
		cQuery += " SD2.D2_PEDIDO 							As cOrder,			"
		cQuery += " SB1.B1_DESC 							AS cProductDesc 	"

		cQuery += " FROM  %SD2.SQLNAME% " 
		cQuery += " LEFT JOIN %SB1.SQLNAME% ON "
		cQuery += " %SB1.XFILIAL% "
		cQuery += " AND SD2.D2_COD		= SB1.B1_COD   "
		cQuery += " AND SD2.D_E_L_E_T_	= SB1.D_E_L_E_T_ "
		cQuery += ::cWhere
		cQuery += " ORDER BY SD2.D2_ITEM ASC

	endif
return (cQuery)

method setWhere(cFil, cInvoiceNumber, cSerie) class cbcInvItens
	default cFil			:= ''
	default cInvoiceNumber	:= ''
	default cSerie	:= ''
	if ! empty(cFil) .and. ! empty(cInvoiceNumber) .and. ! empty(cSerie)		
		::cWhere := " WHERE SD2.D2_FILIAL = '" + cFil + "' "
		::cWhere += " AND SD2.D2_DOC = '" + cInvoiceNumber + "' "
		::cWhere += " AND SD2.D2_SERIE = '" + cSerie + "' "
		::cWhere += " AND %SD2.NOTDEL% "
	endif
return(self)

method execAfterQry() class cbcInvItens
	clearSer(Self)
return(self)


static function clearSer(oSelf) 
	oSelf:cWhere := ''
return (nil)
