#include "totvs.ch"
#include "rwmake.ch"


/*/{Protheus.doc} CbcEvent

Objeto que representa um Evento do Portal Cobrecom
    
@author victorhugo
@since 28/02/2016
/*/
class CbcEvent from LongClassName
	
	data cId
	data cFromUser
	data aNotifyUsers
	data aEmailUsers
	data cMessage
	
	method newCbcEvent() constructor
	
	method getId()
	method setId()
	method getFromUser()
	method setFromUser()
	method getNotifyUsers()
	method setNotifyUsers()
	method addNotifyUser()
	method getEmailUsers()
	method setEmailUsers()
	method addEmailUser()
	method getMessage()
	method setMessage()
	
endClass


/*/{Protheus.doc} newCbcEvent

Construtor
    
@author victorhugo
@since 28/02/2016
/*/
method newCbcEvent(cId, cFromUser, cMessage, aNotifyUsers, aEmailUsers) class CbcEvent
	
	default cId 			:= ""
	default cFromUser		:= ""
	default cMessage		:= ""
	default aNotifyUsers	:= {}
	default aEmailUsers		:= {}
	
	::setId(cId)
	::setFromUser(cFromUser)
	::setMessage(cMessage)
	::setNotifyUsers(aNotifyUsers)
	::setEmailUsers(aEmailUsers) 

return self


/*/{Protheus.doc} getId

Coleta o ID do Evento
	
@author victorhugo
@since 28/02/2016

@return String ID do Evento
/*/
method getId() class CbcEvent
return ::cId


/*/{Protheus.doc} setId

Define o ID do Evento
	
@author victorhugo
@since 28/02/2016

@param cId, String, ID do Evento
/*/
method setId(cId) class CbcEvent
	::cId := cId
return


/*/{Protheus.doc} getFromUser

Coleta o ID do Usuário que gerou o Evento
	
@author victorhugo
@since 28/02/2016

@return String ID do Usuário que gerou o Evento
/*/
method getFromUser() class CbcEvent
return ::cFromUser


/*/{Protheus.doc} setFromUser

Define o ID do Usuário que gerou o Evento
	
@author victorhugo
@since 28/02/2016

@param cFromUser, String, ID do Usuário que gerou o Evento
/*/
method setFromUser(cFromUser) class CbcEvent
	::cFromUser := cFromUser
return


/*/{Protheus.doc} getNotifyUsers

Coleta os IDs dos Usuários que serão notificados sobre o Evento
	
@author victorhugo
@since 28/02/2016

@return Vetor IDs dos Usuários que serão notificados sobre o Evento
/*/
method getNotifyUsers() class CbcEvent
return ::aNotifyUsers


/*/{Protheus.doc} setNotifyUsers

Define os IDs dos Usuários que serão notificados sobre o Evento
	
@author victorhugo
@since 28/02/2016

@param aNotifyUsers, Vetor, IDs dos Usuários que serão notificados sobre o Evento
/*/
method setNotifyUsers(aNotifyUsers) class CbcEvent
	::aNotifyUsers := aNotifyUsers
return


/*/{Protheus.doc} addNotifyUser

Adiciona o ID de um usuário para Notificação
	
@author victorhugo
@since 28/02/2016

@param cUserId, String, ID do Usuário
/*/
method addNotifyUser(cUserId) class CbcEvent
	
	if (ValType(::aNotifyUsers) != "A")
		::aNotifyUsers := {} 
	endIf
	
	if (aScan(::aNotifyUsers, cUserId) == 0)
		aAdd(::aNotifyUsers, cUserId)
	endIf
	
return


/*/{Protheus.doc} getEmailUsers

Coleta os IDs dos Usuários que receberão uma notificação por E-mail sobre o Evento
	
@author victorhugo
@since 28/02/2016

@return Vetor IDs dos Usuários que receberão uma notificação por E-mail sobre o Evento
/*/
method getEmailUsers() class CbcEvent
return ::aEmailUsers


/*/{Protheus.doc} setEmailUsers

Define os IDs dos Usuários que receberão uma notificação por E-mail sobre o Evento
	
@author victorhugo
@since 28/02/2016

@param aEmailUsers, Vetor, IDs dos Usuários que receberão uma notificação por E-mail sobre o Evento
/*/
method setEmailUsers(aEmailUsers) class CbcEvent
	::aEmailUsers := aEmailUsers
return


/*/{Protheus.doc} addEmailUser

Adiciona o ID de um usuário para Recebimento de E-mail
	
@author victorhugo
@since 28/02/2016

@param cUserId, String, ID do Usuário
/*/
method addEmailUser(cUserId) class CbcEvent
	
	if (ValType(::aEmailUsers) != "A")
		::aEmailUsers := {} 
	endIf
	
	if (aScan(::aEmailUsers, cUserId) == 0)
		aAdd(::aEmailUsers, cUserId)
	endIf
	
return


/*/{Protheus.doc} getMessage

Coleta a Mensagem sobre o Evento
	
@author victorhugo
@since 28/02/2016

@return String Mensagem sobre o Evento
/*/
method getMessage() class CbcEvent
return ::cMessage


/*/{Protheus.doc} setMessage

Define a Mensagem sobre o Evento
	
@author victorhugo
@since 28/02/2016

@param cMessage, String, Mensagem sobre o Evento
/*/
method setMessage(cMessage) class CbcEvent
	::cMessage := cMessage
return

