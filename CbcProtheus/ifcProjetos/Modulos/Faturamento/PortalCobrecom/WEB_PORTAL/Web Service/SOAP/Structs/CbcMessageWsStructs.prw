#include "protheus.ch"
#include "apwebsrv.ch"


/*/{Protheus.doc} WsCbcMessage

Mensagens do Portal Cobrecom
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcMessage
	
	wsData id as string optional
	wsData fromUser as string optional
	wsData fromUserName as string optional
	wsData toUser as string optional
	wsData toUserName as string optional
	wsData date as date optional
	wsData time as string optional
	wsData subject as string optional
	wsData dateDisplay as date optional
	wsData timeDisplay as string optional
	wsData text as string optional
	wsData dateEmail as date optional
	wsData timeEmail as string optional
	wsData when as string optional
	wsData isFiled as boolean optional
	wsData quotationId as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcMessageBySender

Mensagens do Portal Cobrecom por Remetente
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcMessageBySender
	
	wsData fromUserId as string
	wsData fromUserName as string
	wsData notDisplayedCount as integer
	wsData messages as array of WsCbcMessage optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestCreateMessage

Requisição de Criação de Mensagem para um Usuário
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestCreateMessage	
	
	wsData fromUser as string
	wsData toUsers as string optional
	wsData toGroups as string optional
	wsData subject as string
	wsData text as string
	wsData quotationId as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseCreateMessage

Retorno de Criação de Mensagem para um Usuário
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseCreateMessage
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestMessagesByUser

Requisição de Mensagens por Usuário
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestMessagesByUser	
	
	wsData userId as string
	wsData showDisplayed as boolean optional
	wsData fromUser as string optional
	wsData lastId as string optional
	wsData maxRegs as integer optional
	wsData setDisplayed as boolean optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseMessagesByUser

Retorno de Mensagens por Usuário
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseMessagesByUser
	
	wsData status as WsCbcResponseStatus
	wsData notDisplayedCount as integer
	wsData messages as array of WsCbcMessage optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestMessagesBySender

Requisição de Mensagens de um Usuário agrupadas por Remetentes
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestMessagesBySender	
	
	wsData userId as string
	wsData showDisplayed as boolean optional
	wsData maxRegs as integer optional
	wsData setDisplayed as boolean optional
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseMessagesBySender

Retorno de Mensagens de um Usuário agrupadas por Remetentes
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseMessagesBySender
	
	wsData status as WsCbcResponseStatus
	wsData senders as array of WsCbcMessageBySender optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestMessagesByQuotation

Requisição de Mensagens de um Orçamento
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestMessagesByQuotation	
	
	wsData quotationId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseMessagesByQuotation

Retorno de Mensagens de um Orçamento
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseMessagesByQuotation
	
	wsData status as WsCbcResponseStatus
	wsData messages as array of WsCbcMessage optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestSetMessageDisplayed

Requisição de Definição de uma Mensagem como Visualizada
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestSetMessageDisplayed	
	
	wsData messageId as string
	wsData userId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseSetMessageDisplayed

Retorno de Definição de uma Mensagem como Visualizada
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseSetMessageDisplayed	
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestToUsersMessage

Requisição de Usuários disponíveis para criação de Mensagens
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestToUsersMessage	
	
	wsData fromUser as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseToUsersMessage

Retorno de Usuários disponíveis para criação de Mensagens
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseToUsersMessage	
	
	wsData status as WsCbcResponseStatus
	wsData users as array of WsCbcGenericObject optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestToGroupsMessage

Requisição de Grupos de Usuários disponíveis para criação de Mensagens
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestToGroupsMessage	
	
	wsData fromUser as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseToGroupsMessage

Retorno de Grupos de Usuários disponíveis para criação de Mensagens
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseToGroupsMessage	
	
	wsData status as WsCbcResponseStatus
	wsData groups as array of WsCbcGenericObject optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestDeleteMessage

Requisição de Remoção de uma Mensagem
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestDeleteMessage	
	
	wsData messageId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseDeleteMessage

Retorno de Remoção de uma Mensagem
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseDeleteMessage	
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestArchiveMessage

Requisição de Arquivação de uma Mensagem
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestArchiveMessage	
	
	wsData messageId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseArchiveMessage

Retorno de Arquivação de uma Mensagem
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseArchiveMessage	
	
	wsData status as WsCbcResponseStatus
	
endWsStruct




