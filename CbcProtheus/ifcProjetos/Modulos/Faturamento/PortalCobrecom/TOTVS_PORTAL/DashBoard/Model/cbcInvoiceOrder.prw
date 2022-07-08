#include 'protheus.ch'

class cbcInvoiceOrder 

	data cBranch
	data cOrder
	data cInvoiceNumber
	data cSerie
	data dIssueData
	data cTransp
	data dDelivery
	data nTotal
	data cCustName
	data cCustomer
	data cCustUnit
	data cWhere
	data cWho

	method newcbcInvoiceOrder() constructor 
	method getQuery()
	method setWhere()
	method setClientWhere()
	method execAfterQry()

endclass


method newcbcInvoiceOrder() class cbcInvoiceOrder

return


method getQuery() class cbcInvoiceOrder
	local cQuery := ''
	if !empty(::cWhere)

		cQuery += " SELECT DISTINCT " 
		cQuery += " SD2.D2_FILIAL 	AS cBranch, "
		cQuery += " SD2.D2_DOC 		As cInvoiceNumber, "
		cQuery += " SD2.D2_SERIE 	As cSerie, "
		cQuery += " SD2.D2_EMISSAO 	As dIssueData, " 
		cQuery += " SD2.D2_CLIENTE 	As cCustomer, "
		cQuery += " SD2.D2_LOJA 	As cCustUnit "
		
		if ::cWho == 'PEDIDO'
			cQuery += ","
			cQuery += " SD2.D2_PEDIDO As cOrder "
		endif
		
		
		cQuery += " FROM  %SD2.SQLNAME% " 
		cQuery += ::cWhere
		cQuery += " ORDER BY D2_EMISSAO DESC "

	endif
return (cQuery)

method setWhere(cFil, cOrder) class cbcInvoiceOrder
	default cOrder	:= ''
	default cFil	:= ''

	if  ! empty(cFil) .AND. ! empty(cOrder)		
		::cWho	 := 'PEDIDO'
		::cWhere := " WHERE SD2.D2_FILIAL = '" + cFil + "' "
		::cWhere += " AND SD2.D2_PEDIDO = '" + cOrder + "' "
		::cWhere += " AND SD2.D2_SERIE = '1' "
		::cWhere += " AND %SD2.NOTDEL% "
	endif

return(self)

method setClientWhere(cCliente, cLoja, dStartDate, dEndDate)  class cbcInvoiceOrder
	default cCliente	:= ''
	default cLoja		:= ''
	default dStartDate 	:= ''
	default dEndDate 	:= ''

	if ! empty(cCliente) .and. ! empty(cLoja)
		::cWho	 := 'CLIENTE'
		::cWhere := " WHERE SD2.D2_FILIAL IN ('','01','02', '03' )"
		::cWhere += " AND SD2.D2_CLIENTE = '" + cCliente + "' "
		::cWhere += " AND SD2.D2_LOJA = '" + cLoja + "' "

		if ! empty(dStartDate) .and. ! empty(dEndDate)
			::cWhere += " AND SD2.D2_EMISSAO BETWEEN '" + dToS(dStartDate) + "' AND '" + dToS(dEndDate) + "' "
		endif
		::cWhere += " AND SD2.D2_SERIE = '1' "
		::cWhere += " AND %SD2.NOTDEL% "
	endif
return(self)


method execAfterQry() class cbcInvoiceOrder
	getTotal(self)
	getDelivery(self)
	getNameCust(self)
	getDlvrydate(self)
	clearSer(Self)
return(self)

// Obter os totais da nota
static function getTotal(oSelf)
	local oSql := nil

	oSql := LibSqlObj():newLibSqlObj()	
	oSelf:nTotal :=  oSql:getFieldValue("SF2", "F2_VALMERC",;
	"F2_FILIAL = '" + oSelf:cBranch +;
	"' AND F2_DOC = '" + oSelf:cInvoiceNumber  +;
	"' AND F2_SERIE = '" + oSelf:cSerie + "' " )

	FreeObj(oSql)

return(nil)


// Obter o nome da transportadora
static function getDelivery(oSelf)
	local oSql 		:= nil
	local cTransCod	:= ''
	oSql := LibSqlObj():newLibSqlObj()	

	cTransCod := oSql:getFieldValue("SF2", "F2_TRANSP",;
	" F2_FILIAL = '" + oSelf:cBranch  +;
	"'  AND F2_DOC = '" + oSelf:cInvoiceNumber + ;
	"'  AND F2_SERIE = '" + oSelf:cSerie + "' ")

	if empty(cTransCod)
		oSelf:cTransp := ''
	else
		oSelf:cTransp :=  oSql:getFieldValue("SA4", "A4_NOME",;
		"%SA4.XFILIAL% AND A4_COD = '" +cTransCod + "'"   )
	endif

	FreeObj(oSql)
return(nil)


// Obter nome  cliente
static function getNameCust(oSelf)
	local oSql := nil
	oSql := LibSqlObj():newLibSqlObj()	
	oSelf:cCustName :=  oSql:getFieldValue("SA1", "A1_NOME",;
	"%SA1.XFILIAL% AND A1_COD = '" + oSelf:cCustomer  + "'  AND A1_LOJA = '" + oSelf:cCustUnit + "' " )

	FreeObj(oSql)
return(nil)


// Obter a data de entrega
static function getDlvrydate(oSelf)
	local oSql := nil

	oSql := LibSqlObj():newLibSqlObj()	

	oSelf:dDelivery :=  oSql:getFieldValue("SF2", "F2_DTENTR",;
	"F2_FILIAL = '" + oSelf:cBranch +;
	"' AND F2_DOC = '" + oSelf:cInvoiceNumber  +;
	"' AND F2_SERIE = '" + oSelf:cSerie + "' " )

	FreeObj(oSql)
return(nil) 


static function clearSer(oSelf) 
	oSelf:cWhere 	:= ''
	oSelf:cWho		:= ''
return (nil)