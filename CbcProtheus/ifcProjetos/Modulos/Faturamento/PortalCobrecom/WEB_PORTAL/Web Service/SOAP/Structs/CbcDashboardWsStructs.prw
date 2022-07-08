#include "protheus.ch"
#include "apwebsrv.ch"


/*/{Protheus.doc} WsCbcRequestQuotationStatus

Requisi��o dos Status dos Or�amentos 
	
@author victorhugo
@since 11/10/2017
/*/
wsStruct WsCbcRequestQuotationStatus
	
	wsData userId as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseQuotationStatus

Retorno dos Status dos Or�amentos 
	
@author victorhugo
@since 11/10/2017
/*/
wsStruct WsCbcResponseQuotationStatus
	
	wsData status as WsCbcResponseStatus
	wsData data as array of WsCbcQuotationStatus optional
	
endWsStruct


/*/{Protheus.doc} WsCbcQuotationStatus

Status dos Or�amentos 
	
@author victorhugo
@since 11/10/2017
/*/
wsStruct WsCbcQuotationStatus
	
	wsData statusId as string
	wsData description as string
	wsData colorClass as string
	wsData color as string
	wsData icon as string
	wsData value as float
	wsData quantity as float
	wsData formatValue as string	
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestConfirmedQuotations

Requisi��o dos Or�amentos Confirmados 
	
@author victorhugo
@since 11/10/2017
/*/
wsStruct WsCbcRequestConfirmedQuotations
	
	wsData userId as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseConfirmedQuotations

Retorno dos Or�amentos Confirmados 
	
@author victorhugo
@since 11/10/2017
/*/
wsStruct WsCbcResponseConfirmedQuotations
	
	wsData status as WsCbcResponseStatus
	wsData data as array of WsCbcConfirmedQuotation optional
	
endWsStruct


/*/{Protheus.doc} WsCbcConfirmedQuotation

Or�amentos Confirmados 
	
@author victorhugo
@since 11/10/2017
/*/
wsStruct WsCbcConfirmedQuotation
	
	wsData month as string
	wsData value as float
	wsData quantity as float
	wsData formatValue as string	
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestBillingValue

Requisi��o dos Totais de Faturamento 
	
@author victorhugo
@since 11/10/2017
/*/
wsStruct WsCbcRequestBillingValue
	
	wsData userId as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseBillingValue

Retorno dos Totais de Faturamento 
	
@author victorhugo
@since 11/10/2017
/*/
wsStruct WsCbcResponseBillingValue
	
	wsData status as WsCbcResponseStatus
	wsData data as array of WsCbcBillingValue optional
	
endWsStruct


/*/{Protheus.doc} WsCbcBillingValue

Total de Faturamento por M�s
	
@author victorhugo
@since 11/10/2017
/*/
wsStruct WsCbcBillingValue
	
	wsData month as string
	wsData value as float
	wsData formatValue as string	
	
endWsStruct
