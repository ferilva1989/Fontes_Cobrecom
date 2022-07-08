#include "protheus.ch"
#include "apwebsrv.ch"


/*/{Protheus.doc} WsCbcQuotation

Orçamentos do Portal Cobrecom
	
@author victorhugo
@since 23/05/2016
/*/
wsStruct WsCbcQuotation
	
	wsData status as string optional
	wsData id as string optional
	wsData lastRevision as string optional
	wsData date as date optional  
	wsData time as string optional
	wsData idUser as string optional
	wsData nameUser as string optional
	wsData type as string optional
	wsData validDate as date optional
	wsData codeCustomer as string optional
	wsData unitCustomer as string optional
	wsData nameCustomer as string optional
	wsData delCodeCustomer as string optional
	wsData delUnitCustomer as string optional
	wsData delNameCustomer as string optional
	wsData delAddress as string optional
	wsData delCity as string optional
	wsData delState as string optional
	wsData freight as string optional
	wsData paymentCondition as string optional
	wsData descPayment as string optional
	wsData idApprover as string optional
	wsData nameApprover as string optional
	wsData canEdit as boolean optional
	wsData canTakeApproval as boolean optional
	wsData canRequestTecnicalApproval as boolean optional
	wsData comments as string optional
	wsData reasonCancel as string optional
	wsData cancelComments as string optional
	wsData deliveryType as string optional
	wsData standardDelivery as date optional
	wsData storedStandardDelivery as date optional
	wsData billingDate as date optional
	wsData isIssueReport as boolean optional
	wsData isPallets as boolean optional
	wsData isPartialBilling as boolean optional
	wsData customerSalesOrder as string optional
	wsData shippingMessage as string optional
	wsData invoiceMessage as string optional
	wsData messages as array of WsCbcMessage optional 
	wsData items as array of WsCbcQuotationItem optional
	wsData documents as array of WsCbcQuotationDocument optional
	wsData rules as array of WsCbcQuotationRule optional
	wsData revisions as array of WsCbcQuotationRevision optional
	wsData competitors as array of WsCbcGenericObject optional
	wsData fixedCommission as float optional
	wsData sugTotal as float optional
	wsData appTotal as float optional
	wsData minRgTotal as float optional
	wsData sugRgTotal as float optional
	wsData appRgTotal as float optional
	wsData copperTotal as float optional
	wsData sugDiscountAvg as float optional
	wsData appDiscountAvg as float optional
	wsData sugCommissionAvg as float optional
	wsData appCommissionAvg as float optional
	wsData sugImp as float optional
	wsData appImp as float optional
	wsData procDate as date optional
	wsData procTime as string optional
	wsData procComments as string optional
	wsData isRetail as boolean optional
	wsData canPrint as boolean optional	
	
endWsStruct


/*/{Protheus.doc} WsCbcQuotationDocument

Documentos gerados a partir dos Orçamentos do Portal Cobrecom
	
@author victorhugo
@since 23/05/2016
/*/
wsStruct WsCbcQuotationDocument
	
	wsData branchId as string optional
	wsData type as string optional
	wsData id as string optional
	wsData series as string optional
	wsData date as date optional
	wsData time as string optional
	wsData isDeleted as boolean
	wsData comments as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcQuotationItem

Itens dos Orçamentos do Portal Cobrecom
	
@author victorhugo
@since 23/05/2016
/*/
wsStruct WsCbcQuotationItem
	
	wsData item as string optional
	wsData name as string optional
	wsData codeName as string optional
	wsData bitola as string optional
	wsData codeBitola as string optional
	wsData package as string optional
	wsData idPackage as string optional
	wsData amountPackage as float optional
	wsData isSpecificPackageAmount as boolean optional
	wsData specialty as string optional
	wsData description as string optional
	wsData quantity as float optional
	wsData idListPrice as string optional
	wsData listPrice as float optional
	wsData cashPaymentDiscount as float optional
	wsData freightDiscount as float optional
	wsData minPrice as float optional
	wsData minTotal as float optional
	wsData minRg as float optional
	wsData sugPrice as float optional
	wsData sugTotal as float optional
	wsData sugCommission as float optional
	wsData sugRg as float optional
	wsData appPrice as float optional
	wsData appTotal as float optional
	wsData appCommission as float optional
	wsData appRg as float optional
	wsData isAppAuto as boolean optional
	wsData isFixedCommission as boolean optional
	wsData priceDiff as float optional	
	wsData branchReserve as string optional
	wsData idReserve as string optional
	wsData customerSalesOrder as string optional
	wsData itemCustomerSalesOrder as string optional
	wsData colors as array of WsCbcQuotationItemColor optional
	wsData defDiscount as string optional
	wsData sugDiscount as string optional
	wsData appDiscount as string optional
	wsData isFlex25 as boolean optional
	wsData descSpecialty as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcQuotationItemColor

Cores dos Itens dos Orçamentos
	
@author victorhugo
@since 23/05/2016
/*/
wsStruct WsCbcQuotationItemColor
	
	wsData colorId as string optional
	wsData colorName as string optional
	wsData quantity as float optional
	wsData total as float optional
	wsData poShip as string optional
	wsData requireApproval as boolean optional
	
endWsStruct


/*/{Protheus.doc} WsCbcQuotationRule

Regras de Negócios dos Orçamentos
	
@author victorhugo
@since 23/05/2016
/*/
wsStruct WsCbcQuotationRule
	
	wsData type as string optional
	wsData description as string optional
	wsData isOk as boolean optional
	wsData comments as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcQuotationRevision

Revisões dos Orçamentos
	
@author victorhugo
@since 23/05/2016
/*/
wsStruct WsCbcQuotationRevision
	
	wsData revision	as string optional
	wsData event as string optional
	wsData idUser as string optional
	wsData nameUser as string optional
	wsData date	as date optional	
	wsData time	as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcSalesOrderData

Dados para Geração de Pedidos de Vendas a partir de Orçamentos
	
@author victorhugo
@since 23/05/2016
/*/
wsStruct WsCbcSalesOrderData
	
	wsData deliveryType as string optional
	wsData billingDate as date optional
	wsData isIssueReport as boolean optional
	wsData isPallets as boolean optional
	wsData isPartialBilling as boolean optional
	wsData customerSalesOrder as string optional
	wsData shippingMessage as string optional
	wsData invoiceMessage as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestSearchQuotations

Requisição de Pesquisa de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcRequestSearchQuotations
	
	wsData userId as string
	wsData startDate as date optional
	wsData endDate as date optional
	wsData quotationId as string optional
	wsData salesOrderId as string optional
	wsData invoiceId as string optional
	wsData customerKeyWord as string optional
	wsData status as string optional
	wsData ownerId as string optional	 
	wsData sellerId as string optional
	wsData managerId as string optional
	wsData approval as string optional
	wsData codeCustomer as string optional
	wsData unitCustomer as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseSearchQuotations

Retorno de Pesquisa de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcResponseSearchQuotations
	
	wsData status as WsCbcResponseStatus
	wsData quotations as array of WsCbcQuotation optional 
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestQuotationById

Requisição de Orçamentos pelo ID
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcRequestQuotationById
	
	wsData userId as string
	wsData quotationId as string
	wsData revision as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseQuotationById

Retorno de Orçamentos pelo ID
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcResponseQuotationById
	
	wsData status as WsCbcResponseStatus
	wsData quotation as WsCbcQuotation optional 
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestCreateQuotation

Requisição de Criação de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcRequestCreateQuotation
	
	wsData quotation as WsCbcQuotation
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseCreateQuotation

Retorno de Criação de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcResponseCreateQuotation
	
	wsData status as WsCbcResponseStatus
	wsData quotationId as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestUpdateQuotation

Requisição de Alteração de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcRequestUpdateQuotation
	
	wsData userId as string
	wsData quotation as WsCbcQuotation
	wsData itemsChanged as boolean 
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseUpdateQuotation

Retorno de Alteração de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcResponseUpdateQuotation
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestDeleteQuotation

Requisição de Exclusão de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcRequestDeleteQuotation
	
	wsData userId as string
	wsData quotationId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseDeleteQuotation

Retorno de Exclusão de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcResponseDeleteQuotation
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestFinishMaintenanceQuotation

Requisição de Finalização da Manutenção de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcRequestFinishMaintenanceQuotation
	
	wsData userId as string
	wsData quotationId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseFinishMaintenanceQuotation

Retorno de Finalização da Manutenção de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcResponseFinishMaintenanceQuotation
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestTakeApprovalQuotation

Requisição de Assumir Aprovação de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcRequestTakeApprovalQuotation
	
	wsData userId as string
	wsData quotationId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseTakeApprovalQuotation

Retorno de Assumir Aprovação de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcResponseTakeApprovalQuotation
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestGiveUpApprovalQuotation

Requisição de Desistir da Aprovação de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcRequestGiveUpApprovalQuotation
	
	wsData userId as string
	wsData quotationId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseGiveUpApprovalQuotation

Retorno de Desistir da Aprovação de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcResponseGiveUpApprovalQuotation
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestApproveQuotation

Requisição de Aprovação de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcRequestApproveQuotation
	
	wsData userId as string
	wsData quotationId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseApproveQuotation

Retorno de Aprovação de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcResponseApproveQuotation
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestDisapproveQuotation

Requisição de Rejeição de Aprovação de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcRequestDisapproveQuotation
	
	wsData userId as string
	wsData quotationId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseDisapproveQuotation

Retorno de Rejeição de Aprovação de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcResponseDisapproveQuotation
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestUndoApprovalQuotation

Requisição para Desfazer a Aprovação/Rejeição de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcRequestUndoApprovalQuotation
	
	wsData userId as string
	wsData quotationId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseUndoApprovalQuotation

Retorno da requisição para Desfazer a Aprovação/Rejeição de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcResponseUndoApprovalQuotation
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestCancelQuotation

Requisição de Cancelamento de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcRequestCancelQuotation
	
	wsData userId as string
	wsData quotationId as string
	wsData reason as string
	wsData comments as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseCancelQuotation

Retorno de Cancelamento de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcResponseCancelQuotation
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestLockUpdateQuotation

Requisição de Bloqueio da Alteração de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcRequestLockUpdateQuotation
	
	wsData userId as string
	wsData quotationId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseLockUpdateQuotation

Retorno de Bloqueio da Alteração de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcResponseLockUpdateQuotation
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestUnlockUpdateQuotation

Requisição de Desbloqueio da Alteração de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcRequestUnlockUpdateQuotation
	
	wsData userId as string
	wsData quotationId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseUnlockUpdateQuotation

Retorno de Desbloqueio da Alteração de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcResponseUnlockUpdateQuotation
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestTecnicalApproval

Requisição de Aprovação Técnica dos Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcRequestTecnicalApproval
	
	wsData userId as string
	wsData quotationId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseTecnicalApproval

Retorno de Aprovação Técnica dos Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcResponseTecnicalApproval
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestQuotationsEntityList

Requisição de Lista de Entidades relacionadas aos Orçamentos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestQuotationsEntityList	
	
	wsData userId as string
	wsData entity as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseQuotationsEntityList

Retorno de Lista de Entidades relacionadas aos Orçamentos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseQuotationsEntityList	
	
	wsData status as WsCbcResponseStatus
	wsData values as array of WsCbcGenericObject optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestQuotationPaymentConditions

Requisição das Condições de Pagamentos dos Orçamentos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestQuotationPaymentConditions	
	
	wsData userId as string optional
	wsData quotationType as string optional
	wsData customerCode as string optional
	wsData customerUnit as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseQuotationPaymentConditions

Retorno das Condições de Pagamentos dos Orçamentos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseQuotationPaymentConditions	
	
	wsData status as WsCbcResponseStatus
	wsData values as array of WsCbcGenericObject optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestQuotationPdf

Requisição do PDF dos Orçamentos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestQuotationPdf	
	
	wsData userId as string
	wsData quotationId as string
	wsData quotationRevision as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseQuotationPdf

Retorno do PDF dos Orçamentos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseQuotationPdf	
	
	wsData link as string optional
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcProductPackage

Acondicionamentos dos Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcProductPackage
	
	wsData id as string optional
	wsData description as string optional
	wsData amounts as array of float optional
	
endWsStruct


/*/{Protheus.doc} WsCbcProductSpecialty

Especialidades dos Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcProductSpecialty
	
	wsData id as string optional
	wsData description as string optional
	wsData colors as array of WsCbcProductColor optional
	wsData specificColors as boolean optional
	
endWsStruct


/*/{Protheus.doc} WsCbcProductColor

Cores dos Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcProductColor
	
	wsData id as string optional
	wsData description as string optional
	wsData requireApproval as boolean optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestProductFamilies

Requisição das Familias de Produtos cadastradas
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestProductFamilies	

	wsData codeCustomer as string
	wsData unitCustomer as string
	wsData isRetail as boolean
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseProductFamilies

Retorno das Familias de Produtos cadastradas
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseProductFamilies	
	
	wsData status as WsCbcResponseStatus
	wsData families as array of WsCbcGenericObject optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestBitolas

Requisição das Bitolas de uma Familia
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestBitolas	
	
	wsData codeCustomer as string
	wsData unitCustomer as string
	wsData family as string
	wsData isRetail as boolean
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseBitolas

Retorno das Bitolas de uma Familia
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseBitolas	
	
	wsData status as WsCbcResponseStatus
	wsData bitolas as array of WsCbcGenericObject optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestProductPackages

Requisição dos Acondicionamentos e Especialidades
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestProductPackages	
	
	wsData codeCustomer as string
	wsData unitCustomer as string
	wsData family as string
	wsData bitola as string
	wsData isRetail as boolean
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseProductPackages

Retorno dos Acondicionamentos e Especialidades
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseProductPackages	
	
	wsData status as WsCbcResponseStatus
	wsData packages as array of WsCbcProductPackage optional
	wsData specialties as array of WsCbcProductSpecialty optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestConfirmQuotation

Requisição de Confirmação de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcRequestConfirmQuotation
	
	wsData userId as string
	wsData quotationId as string
	wsData salesOrderData as WsCbcSalesOrderData
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseConfirmQuotation

Retorno da Confirmação de Orçamentos
	
@author victorhugo
@since 02/06/2016
/*/
wsStruct WsCbcResponseConfirmQuotation

	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestProductPrice

Requisição de Informações sobre o Preço dos Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestProductPrice	
	
	wsData userId as string
	wsData customerCode as string
	wsData customerUnit as string
	wsData paymentCondition as string
	wsData freight as string
	wsData isRetail as boolean
	wsData item as WsCbcQuotationItem
	wsData unitPrice as float optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseProductPrice

Retorno de Informações sobre o Preço dos Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseProductPrice	
	
	wsData status as WsCbcResponseStatus
	wsData listPriceId as string optional
	wsData listPrice as float optional
	wsData defaultDiscountRange as string optional
	wsData cashPaymentDiscount as float optional
	wsData freightDiscount as float optional
	wsData minPrice as float optional
	wsData minRg as float optional
	wsData effectiveDiscountRange as string optional
	wsData unitPriceRg as float optional
	wsData commission as float optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestUpdateAppPrice

Requisição de Atualização da Aprovação dos Preços dos Itens dos Orçamentos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestUpdateAppPrice	
	
	wsData userId as string
	wsData quotationId as string
	wsData item as WsCbcQuotationItem
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseUpdateAppPrice

Retorno de Informações sobre o Preço dos Produtos
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseUpdateAppPrice	
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestPriceFromRg

Requisição de Preços a partir de um RG
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestPriceFromRg	
	
	wsData customerCode as string
	wsData customerUnit as string
	wsData isRetail as boolean
	wsData rg as float
	wsData item as WsCbcQuotationItem
	
endWsStruct


/*/{Protheus.doc} WsCbcResponsePriceFromRg

Retorno de Preços a partir de um RG
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponsePriceFromRg	
	
	wsData status as WsCbcResponseStatus
	wsData price as float
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestQuotationCustomerUpdate

Requisição de Alteração do Cliente de um Orçamento
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestQuotationCustomerUpdate	
	
	wsData userId as string
	wsData quotationId as string
	wsData customerCode as string
	wsData customerUnit as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseQuotationCustomerUpdate

Retorno da Alteração do Cliente de um Orçamento
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseQuotationCustomerUpdate	
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestQuotationBatchApproval

Requisição de Aprovação em Lote de um Orçamento
	
@author victorhugo
@since 01/06/2017
/*/
wsStruct WsCbcRequestQuotationBatchApproval	
	
	wsData userId as string
	wsData quotationId as string
	wsData option as string
	wsData value as float optional
	wsData product as string optional
	wsData bitola as string optional
	wsData pack as string optional  
	wsData onlyNotApproved as boolean optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseQuotationBatchApproval

Retorno da Aprovação em Lote de um Orçamento
	
@author victorhugo
@since 01/06/2017
/*/
wsStruct WsCbcResponseQuotationBatchApproval	
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestQuotationWaitingConfirmation

Requisição dos Orçamentos aguardando confirmação
	
@author victorhugo
@since 01/06/2017
/*/
wsStruct WsCbcRequestQuotationWaitingConfirmation	
	
	wsData userId as string	
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseQuotationWaitingConfirmation

Retorno dos Orçamentos aguardando confirmação
	
@author victorhugo
@since 01/06/2017
/*/
wsStruct WsCbcResponseQuotationWaitingConfirmation	
	
	wsData status as WsCbcResponseStatus
	wsData quotations as array of WsCbcQuotation optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestAttachmentsCategories

Requisição das Categorias de Anexos
	
@author victorhugo
@since 11/09/2018
/*/
wsStruct WsCbcRequestAttachmentsCategories	

	wsData userId as string	
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseAttachmentsCategories

Retorno das Categorias de Anexos
	
@author victorhugo
@since 11/09/2018
/*/
wsStruct WsCbcResponseAttachmentsCategories	
	
	wsData status as WsCbcResponseStatus
	wsData categories as array of WsCbcGenericObject optional
	
endWsStruct
