#include "protheus.ch"
#include "apwebsrv.ch"


/*/{Protheus.doc} WsCbcNotification

Notifica��es do Portal Cobrecom
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcNotification
	
	wsData id as string
	wsData event as string
	wsData eventName as string
	wsData fromUser as string optional
	wsData toUser as string
	wsData date as date
	wsData time as string
	wsData dateDisplay as date optional
	wsData timeDisplay as string optional
	wsData message as string optional
	wsData email as boolean optional
	wsData dateEmail as date optional
	wsData timeEmail as string optional
	wsData icon as string optional
	wsData iconColor as string optional
	wsData when as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestNotificationsByUser

Requisi��o de Notifica��es por Usu�rio
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestNotificationsByUser	
	
	wsData userId as string
	wsData showDisplayed as boolean optional
	wsData lastId as string optional
	wsData maxRegs as integer optional
	wsData setDisplayed as boolean optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseNotificationsByUser

Retorno de Notifica��es por Usu�rio
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseNotificationsByUser
	
	wsData status as WsCbcResponseStatus
	wsData notDisplayedCount as integer
	wsData notifications as array of WsCbcNotification optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestSetNotificationDisplayed

Requisi��o de Defini��o de uma Notifica��o como Visualizada
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestSetNotificationDisplayed	
	
	wsData notificationId as string
	wsData userId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseSetNotificationDisplayed

Retorno de Defini��o de uma Notifica��o como Visualizada
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseSetNotificationDisplayed	
	
	wsData status as WsCbcResponseStatus
	
endWsStruct



