#include 'protheus.ch'

/*/{Protheus.doc} cbcOrderClient
@author bolognesi
@since 19/10/2017
@version 1.0
@type class
@description Classe que repesenta pedidos de um cliente
utilizado nas dashboards do portal.
/*/
class cbcOrderClient

	data cBranch
	data cOrderNum
	data dIssueDate
	data cNameClient
	data cCodClient
	data cUnitClient
	data dDeliveryDate
	data cQuotationId
	data dDateQuotation
	data dDtProcQuotation
	
	data cStatus
	data cColor
	data cIcon
	data nTotal
	data cWhere

	method newcbcOrderClient() constructor 
	method getQuery()
	method setWhere()
	method execAfterQry()

endclass


method newcbcOrderClient() class cbcOrderClient
return (self)


/*/{Protheus.doc} getQuery
@author bolognesi
@since 19/10/2017
@version 1.0
@type method
@description Função principal que possibilita a utilização
da classe cbcQryExecutor(), para executar a query que este
metodo retorna, e com o retorno preencher um array com
estancias desta classe, para cada registro, toda propriedade
desta classe com o mesmo nome de campo na query sera preenchida.
/*/
method getQuery() class cbcOrderClient
	local cQuery := ''
	if !empty(::cWhere)

		cQuery += " SELECT "
		cQuery += " SC5.C5_FILIAL 	AS cBranch,		"
		cQuery += " SC5.C5_NUM 		AS cOrderNum,	"
		cQuery += " SC5.C5_EMISSAO 	AS dIssueDate, 	"
		cQuery += " SA1.A1_NOME 	AS cNameClient, "
		cQuery += " SC5.C5_CLIENTE	AS cCodClient, 	"
		cQuery += " SC5.C5_TOTAL	AS nTotal, 	"
		cQuery += " SC5.C5_LOJACLI	AS cUnitClient, 	"
		cQuery += " SC5.C5_ENTREG	AS dDeliveryDate, "
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


/*/{Protheus.doc} setWhere
@author bolognesi
@since 19/10/2017
@version 1.0
@param cCliente, characters, descricao
@param cLoja, characters, descricao
@param dStartDate, date, descricao
@param dEndDate, date, descricao
@type method
@description Parametros recebidos  para compor a clausula where
da query retornada
/*/
method setWhere(cCliente, cLoja, dStartDate, dEndDate) class cbcOrderClient
	default cCliente	:= ''
	default cLoja		:= ''
	default dStartDate 	:= ''
	default dEndDate 	:= ''
	
	if ! empty(cCliente) .and. ! empty(cLoja)

		::cWhere := " WHERE SC5.C5_FILIAL IN ('','01','02','03')"
		::cWhere += " AND SC5.C5_CLIENTE = '" + cCliente + "' "
		::cWhere += " AND SC5.C5_LOJACLI = '" + cLoja + "' "

		if ! empty(dStartDate) .and. ! empty(dEndDate)
			::cWhere += " AND C5_EMISSAO BETWEEN '" + dToS(dStartDate) + "' AND '" + dToS(dEndDate) + "' "
		endif

		::cWhere += " AND %SC5.NOTDEL% "
	endif
return(self)


/*/{Protheus.doc} execAfterQry
@author bolognesi
@since 19/10/2017
@version undefined
@type method
@description Metodo chamado pela classe cbcQryExecutor()
logo apos popular um registro, utilizado para complementar o
retorno da query, buscando informações de outras fontes ex:
funções de usuarios. 
/*/
method execAfterQry() class cbcOrderClient
	local oPed 		:= nil 
	oPed := cbcModOrder():newcbcModOrder(::cOrderNum,,,::cBranch)
	// Obter o status
	::cStatus := Alltrim(oPed:getOrderStatus())
	// Definir a cor para o status
	statusColor(self)
	clearSer(Self)
	FreeObj(oPed)
return(self)


/*/{Protheus.doc} clearSer
@author bolognesi
@since 19/10/2017
@version 1.0
@type function
@description Limpeza dos dados desnecessario a serialização
colocar todas as propriedades que não devem ser serializadas
/*/
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
static function statusColor(oSelf)
	local aStatus := {}
	local nPos	:= 0
	
	aadd(aStatus, {'ENCERRADO','danger', 'fa fa-times-circle-o'})
	aadd(aStatus, {'BLQ. VENDAS','success', 'fa fa-lock' })
	aadd(aStatus, {'REJEITADO CREDITO','warning', 'fa fa-thumbs-o-down'})
	aadd(aStatus, {'ANALISE CREDITO','primary', 'fa fa-tasks'})
	aadd(aStatus, {'EM PRODUÇÂO','primary', 'fa fa-industry'})
	aadd(aStatus, {'EM FATURAMENTO','secondary', 'fa fa-money'})
	aadd(aStatus, {'EM SEPARAÇÂO','secondary', 'fa fa-shopping-basket'})
	
	if (nPos := AScan(aStatus,{|a| Alltrim(a[1]) == Alltrim(oSelf:cStatus) })) <> 0
		oSelf:cColor 	:= aStatus[nPos,2]
		oSelf:cIcon 	:= aStatus[nPos,3]
	else
		oSelf:cColor 	:= 'danger'
		oSelf:cIcon	:= 'fa fa-exclamation'
	endif
return(nil)
