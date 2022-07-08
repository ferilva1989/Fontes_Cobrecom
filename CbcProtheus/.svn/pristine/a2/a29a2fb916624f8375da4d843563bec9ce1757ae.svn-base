#include 'protheus.ch'

class cbcDetailsInvoice 

	data cBranch
	data cInvoiceNumber
	data cSerie
	data dIssueData
	data cTransp
	data dDelivery
	data nTotal
	data cCustName
	data cCustomer
	data cCustUnit
	data aItem
	data cWhere

	method newcbcDetailsInvoice() constructor 
	method getQuery()
	method setWhere()
	method execAfterQry()

endclass


method newcbcDetailsInvoice() class cbcDetailsInvoice

return(self)

method getQuery() class cbcDetailsInvoice
	local cQuery := ''
	if !empty(::cWhere)
		cQuery += " SELECT " 
		cQuery += " SF2.F2_FILIAL 			AS cBranch, "
		cQuery += " SF2.F2_DOC 				As cInvoiceNumber, "
		cQuery += " SF2.F2_SERIE 			As cSerie, "
		cQuery += " SF2.F2_EMISSAO 			As dIssueData, " 
		cQuery += " SF2.F2_CLIENTE 			As cCustomer, "
		cQuery += " SF2.F2_LOJA 			As cCustUnit, "
		cQuery += " SF2.F2_VALMERC 			As nTotal, "
		cQuery += " ISNULL(SA4.A4_NOME,'') 	As cTransp, "
		cQuery += " SA1.A1_NOME 			As cCustName, " 
		cQuery += " SF2.F2_DTENTR 			As dDelivery "

		cQuery += " FROM  %SF2.SQLNAME% " 

		cQuery += " LEFT JOIN %SA4.SQLNAME% ON "
		cQuery += " %SA4.XFILIAL% "
		cQuery += " AND SF2.F2_TRANSP	= SA4.A4_COD   "
		cQuery += " AND SF2.D_E_L_E_T_	= SA4.D_E_L_E_T_ "

		cQuery += " LEFT JOIN %SA1.SQLNAME% ON "
		cQuery += " %SA1.XFILIAL% "
		cQuery += " AND SF2.F2_CLIENTE	= SA1.A1_COD   "
		cQuery += " AND SF2.F2_LOJA		= SA1.A1_LOJA   "
		cQuery += " AND SF2.D_E_L_E_T_	= SA1.D_E_L_E_T_ "

		cQuery += ::cWhere

		cQuery += " ORDER BY F2_EMISSAO DESC "

	endif
return (cQuery)

method setWhere(cFil, cInvoiceNumber, cSerie) class cbcDetailsInvoice
	default cFil			:= ''
	default cInvoiceNumber	:= ''
	default cSerie			:= ''

	if  ! empty(cFil) .AND. ! empty(cInvoiceNumber) .AND. ! empty(cSerie)		
		::cWhere := " WHERE SF2.F2_FILIAL = '" + cFil + "' "
		::cWhere += " AND SF2.F2_DOC = '" + cInvoiceNumber + "' "
		::cWhere += " AND SF2.F2_SERIE = '" + cSerie + "' "
		::cWhere += " AND %SF2.NOTDEL% "
	endif

return(self)


method execAfterQry() class cbcDetailsInvoice

	local oQryExec 		:= cbcQryExecutor():newcbcQryExecutor()
	local oInvItens 	:= nil

	if ! empty(::cBranch) .and. ! empty(::cInvoiceNumber) .and. ! empty(::cSerie)

		oInvItens := cbcInvItens():newcbcInvItens()
		oInvItens:setWhere(::cBranch, ::cInvoiceNumber,::cSerie) 
		::aItem := oQryExec:execQuery(oInvItens)
	endif
	clearSer(Self)

return(self)

static function clearSer(oSelf) 
	oSelf:cWhere := ''
return (nil)
