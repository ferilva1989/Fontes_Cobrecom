#include "totvs.ch"
#include "rwmake.ch"


/*/{Protheus.doc} CbcService

Objeto pai de todos os Serviços da Cobrecom
    
@author victorhugo
@since 26/02/2016
/*/
class CbcService from LongClassName
	
	data cErrorMessage
	
	method newCbcService() constructor
	
	method getErrorMessage() 
	method setWsArray()
	method getJsArray()
	
endClass


/*/{Protheus.doc} newCbcService

Construtor
    
@author victorhugo
@since 26/02/2016
/*/
method newCbcService() class CbcService

	::cErrorMessage := "" 	
	
return self


/*/{Protheus.doc} getErrorMessage

Coleta as Mensagens de Erro do Objeto
	
@author victorhugo
@since 26/02/2016

@param lHtml, Logico, Define se deve preparar a Mensagem para exibição em HTML

@return String Mensagens de Erro do Objeto
/*/
method getErrorMessage(lHtml) class CbcService
	
	default lHtml := .F.
	
	if lHtml
		::cErrorMessage := StrTran(::cErrorMessage, CRLF, "<br>")
	endIf

return ::cErrorMessage


/*/{Protheus.doc} setWsArray

Converte uma Lista de Objetos para o formato de Web Service
	
@author victorhugo
@since 31/03/2016

@param aObjects, Vetor, Lista de Objetos para conversão
/*/
method setWsArray(aObjects) class CbcService
	
	local nI	   	 := 0
	local aWsObjects := {}
	
	for nI := 1 to Len(aObjects)
		aAdd(aWsObjects, aObjects[nI]:toWsObject())
	next nI
	
	aObjects := aClone(aWsObjects) 
	
return


/*/{Protheus.doc} getJsArray

Converte uma Lista de Objetos para o formato JSON
	
@author victorhugo
@since 31/03/2016

@param aObjects, Vetor, Lista de Objetos para conversão
/*/
method getJsArray(aObjects) class CbcService
	
	local nI	   	 := 0
	local aJsObjects := {}
	
	for nI := 1 to Len(aObjects)
		aAdd(aJsObjects, aObjects[nI]:toJsonObject())
	next nI 
	
return aJsObjects
