#include 'protheus.ch'

class cbcOrderDetails 

	data cBranch
	data cOrderNum
	data dIssueDate
	data cNameClient
	data dDeliveryDate
	data cQuotationId
	data dDateQuotation
	data dDtProcQuotation
	data nTotal
	data cStatus
	data cColor
	data cIcon
	data aItem
	data cWhere

	method newcbcOrderDetails() constructor 
	method getQuery()
	method setWhere()
	method execAfterQry()

endclass


method newcbcOrderDetails() class cbcOrderDetails
return (self)

method getQuery() class cbcOrderDetails
	local cQuery := ''
	if !empty(::cWhere)

		cQuery += " SELECT "
		cQuery += " SC5.C5_EMISSAO AS dIssueDate, "
		cQuery += " SC5.C5_TOTAL	AS nTotal, "
		cQuery += " SC5.C5_ENTREG	AS dDeliveryDate, "
		cQuery += " SA1.A1_NOME 	AS cNameClient, "
		cQuery += " ISNULL ( ZP5.ZP5_NUM , '' ) 		AS cQuotationId, "  
		cQuery += " ISNULL ( ZP5.ZP5_DATA, '' ) 		AS dDateQuotation, " 
		cQuery += " ISNULL ( ZP5.ZP5_DTPROC, '' ) 	AS dDtProcQuotation "
		
		cQuery += " FROM  %SC5.SQLNAME% "

		cQuery += " INNER JOIN %SA1.SQLNAME% ON "
		cQuery += " %SA1.XFILIAL% "
		cQuery += " AND SC5.C5_CLIENTE 	= SA1.A1_COD  "
		cQuery += " AND SC5.C5_LOJACLI 	= SA1.A1_LOJA  "
		cQuery += " AND SC5.D_E_L_E_T_	= SA1.D_E_L_E_T_ "

		cQuery += " LEFT JOIN %ZP5.SQLNAME% ON "
		cQuery += " %ZP5.XFILIAL% "
		cQuery += " AND SC5.C5_DOCPORT 	= ZP5.ZP5_NUM  "
		cQuery += " AND SC5.D_E_L_E_T_	= ZP5.D_E_L_E_T_ "

		cQuery += ::cWhere
		
		cQuery += " ORDER BY SC5.C5_EMISSAO DESC  "

	endif
return (cQuery)


method setWhere(cFil, cOrderNum) class cbcOrderDetails
	default cFil		:= ''
	default cOrderNum	:= ''

	if ! empty(cFil) .and. ! empty(cOrderNum)
		::cBranch 	:= cFil 
		::cOrderNum := cOrderNum
		
		::cWhere := " WHERE SC5.C5_FILIAL = '" + cFil + "' "
		::cWhere += " AND SC5.C5_NUM = '" + cOrderNum + "' "
		::cWhere += " AND %SC5.NOTDEL% "
	endif
return(self)


method execAfterQry() class cbcOrderDetails
	
	local oQryExec 		:= cbcQryExecutor():newcbcQryExecutor()
	local oItensOrder 	:= nil
	
	if ! empty(::cBranch) .and. ! empty(::cOrderNum)
		
		aStatus := U_StVld04(::cBranch,::cOrderNum)
		::cStatus := '[' + aStatus[1] + '] - ' + Alltrim(aStatus[2])
		statusColor(Alltrim(aStatus[2]), self)
		
		oItensOrder := cbcItensOrder():newcbcItensOrder()
		oItensOrder:setWhere(::cBranch, ::cOrderNum) 
		::aItem := oQryExec:execQuery(oItensOrder)
	endif
	clearSer(Self)
	
return(self)


static function clearSer(oSelf) 
	oSelf:cWhere := ''
return (nil)

/*/{Protheus.doc} statusColor
@author bolognesi
@since 24/10/2017
@version 1.0
@param cStatus, characters, descricao
@param oSelf, object, descricao
@type function
@description Definições para exibição de cores na web
e dos icones com base no fontawesome
/*/
static function statusColor(cStatus, oSelf)
	oSelf:cColor 	:= 'danger'
	oSelf:cIcon		:= 'fa fa-exclamation'
return(nil)