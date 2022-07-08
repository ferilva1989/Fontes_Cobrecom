#include 'protheus.ch'

/*/{Protheus.doc} cbcPortalQueries
@author bolognesi
@since 19/10/2017
@version 1.0
@type class
@description Classe que realiza a estancia de uma classe model
submete essa classe para o serviço cbcQryExecutor(), e deste 
obtem o array que devera ser retornado para exibição no portal
/*/
class cbcPortalQueries from cbcRetPortalQueries

	data oQryExec
	data lSerialize
	method newcbcPortalQueries() constructor 
	method clientOrderList()
	method orderDet()
	method orderInvoiceList()
	method clientInvoiceList()
	method invoiceDetail()

endclass

method newcbcPortalQueries(lSerialize) class cbcPortalQueries
	default lSerialize := .F.
	::lSerialize := lSerialize 
	::newcbcRetPortalQueries()
	::oQryExec := cbcQryExecutor():newcbcQryExecutor()
return (self)


/*/{Protheus.doc} clientOrderList
@author bolognesi
@since 19/10/2017
@version 1.0
@param cCliente, characters, descricao
@param cLoja, characters, descricao
@param dStartDate, date, descricao
@param dEndDate, date, descricao
@type method
@description Obtem todos os pedidos de um cliente em um periodo (apenas SC5)
/*/
method clientOrderList(cCliente, cLoja, dStartDate, dEndDate) class cbcPortalQueries
	local oOrderList	:= nil
	local aRet			:= {}
	local bErro			:= nil
	::setStatus(.T., '')
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, self)})
	BEGIN SEQUENCE
		oOrderList := cbcOrderClient():newcbcOrderClient()
		oOrderList:setWhere(cCliente, cLoja, dStartDate, dEndDate) 
		aRet := ::oQryExec:execQuery(oOrderList)
		RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
	::setReturn(aRet)
return ( retorno(self) )


/*/{Protheus.doc} orderDet
@author bolognesi
@since 20/10/2017
@version 1.0
@param cFil, characters, descricao
@param cOrderNum, characters, descricao
@type method
@description Obtem os detalhes de um pedido, recbe filial e numero do pedido
/*/
method orderDet(cFil, cOrderNum) class cbcPortalQueries
	local oOrderDetail	:= nil
	local aRet			:= {}
	local bErro			:= nil

	::setStatus(.T., '')
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, self)})
	BEGIN SEQUENCE
		oOrderDetail := cbcOrderDetails():newcbcOrderDetails()
		oOrderDetail:setWhere(cFil, cOrderNum) 
		aRet := ::oQryExec:execQuery(oOrderDetail)
		RECOVER
	END SEQUENCE

	ErrorBlock(bErro)
	::setReturn(aRet)
return ( retorno(self) )


/*/{Protheus.doc} orderInvoiceList
@author bolognesi
@since 23/10/2017
@version 1.0
@param cFil, characters, descricao
@param cOrderNum, characters, descricao
@type method
@description A partir de um pedido, obtem todas as notas
referentes. 
/*/
method orderInvoiceList(cFil, cOrderNum) class cbcPortalQueries
	local oInvOrder		:= nil
	local aRet			:= {}
	local bErro			:= nil

	::setStatus(.T., '')
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, self)})
	BEGIN SEQUENCE
		oInvOrder := cbcInvoiceOrder():newcbcInvoiceOrder()
		oInvOrder:setWhere(cFil, cOrderNum) 
		aRet := ::oQryExec:execQuery(oInvOrder)
		RECOVER
	END SEQUENCE

	ErrorBlock(bErro)
	::setReturn(aRet)
return ( retorno(self) )


/*/{Protheus.doc} clientInvoiceList
@author bolognesi
@since 23/10/2017
@version 1.0
@param cCustomer, characters, descricao
@param cUnit, characters, descricao
@param dStartDate, date, descricao
@param dEndDate, date, descricao
@type method
@description Com base nas informações de um cliente e intrevalo de data
obtem-se todas as notas ficais relacionadas.
/*/
method clientInvoiceList(cCustomer, cUnit, dStartDate, dEndDate) class cbcPortalQueries
	local oInvOrder		:= nil
	local aRet			:= {}
	local bErro			:= nil

	::setStatus(.T., '')
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, self)})
	BEGIN SEQUENCE
		oInvOrder := cbcInvoiceOrder():newcbcInvoiceOrder()
		oInvOrder:setClientWhere(cCustomer, cUnit, dStartDate, dEndDate) 
		aRet := ::oQryExec:execQuery(oInvOrder)
		RECOVER
	END SEQUENCE

	ErrorBlock(bErro)
	::setReturn(aRet)	
return ( retorno(self) )


/*/{Protheus.doc} invoiceDetail
@author bolognesi
@since 23/10/2017
@version undefined
@param cFil, characters, descricao
@param cInvoiceNumber, characters, descricao
@param cSerie, characters, descricao
@type method
@description Obter os detalhes(Itens) de uma determinada Nota
/*/
method invoiceDetail(cFil, cInvoiceNumber, cSerie) class cbcPortalQueries
	local oInvDet		:= nil
	local aRet			:= {}
	local bErro			:= nil

	::setStatus(.T., '')
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, self)})
	BEGIN SEQUENCE
		oInvDet := cbcDetailsInvoice():newcbcDetailsInvoice()
		oInvDet:setWhere(cFil, cInvoiceNumber, cSerie) 
		aRet := ::oQryExec:execQuery(oInvDet)
		RECOVER
	END SEQUENCE

	ErrorBlock(bErro)
	
	::setReturn(aRet)
return ( retorno(self) )


// TODO Desenvolver a nova rotina de status..
static function orderStatus()

return(nil)


static function retorno(oSelf)
	if oSelf:lSerialize
		return(oSelf:toJson())
	else
		return(oSelf)
	endif
return(nil)


/*/{Protheus.doc} HandleEr
@author bolognesi
@since 20/10/2017
@version 1.0
@param oErr, object, descricao
@param oSelf, object, descricao
@type function
@description Controle da stack de erro
/*/
Static function HandleEr(oErr, oSelf)
	oSelf:setStatus(.F., '[' + oErr:Description + ']')
	ConOut("[PortalQueries - "+DtoC(Date())+" - "+Time()+" ] "+ '[ERRO]' + oErr:Description + ' [FROM] ' + ProcName(3) )
	BREAK
return


/* ZONE <----> TESTE*/
user function portalConsultas() // U_portalConsultas()
	local pConsulta 	:= cbcPortalQueries():newcbcPortalQueries() //newcbcPortalQueries(.T.) volta JSON serializado
	local pedidoCliente	:= ''
	local pedidoDetalhe	:= ''
	local notaPedido	:= ''
	local notaCli		:= ''
	local notaDetalhes	:= ''

	pedidoCliente := pConsulta:clientOrderList('003717', '01', StoD('20160101'), StoD('20171019') )
	if !pedidoCliente:getStatus()
		Alert(pedidoCliente:getErrMsg())
	else
		Alert('OK-Pedidos de um Cliente')
	endif

	pedidoDetalhe := pConsulta:orderDet('01', '169897') 
	if !pedidoDetalhe:getStatus()
		Alert(pedidoDetalhe:getErrMsg())
	else
		Alert('OK-Detalhes de um pedido')
	endif

	
	notaPedido := pConsulta:orderInvoiceList('01', '170955' )
	if !notaPedido:getStatus()
		Alert(notaPedido:getErrMsg())
	else
		Alert('OK-Notas de um pedidos')
	endif

	notaCli := pConsulta:clientInvoiceList('008918', '01', StoD('20170101'), StoD('20171031') )
	if !notaCli:getStatus()
		Alert(notaCli:getErrMsg())
	else
		Alert('OK-Notas de um Cliente')
	endif

	notaDetalhes := pConsulta:invoiceDetail('01', '000144767', '1')
	if !notaDetalhes:getStatus()
		Alert(notaDetalhes:getErrMsg())
	else
		Alert('OK-Detalhes de uma nota')
	endif


	freeObj(pConsulta)
return(nil)