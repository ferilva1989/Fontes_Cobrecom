#include "protheus.ch"
#include "apwebsrv.ch"


/*/{Protheus.doc} WsCbcResponseStatus

Status dos Retornos de Requisições
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseStatus
	
	wsData success as boolean
	wsData message as string
	
endWsStruct


/*/{Protheus.doc} WsCbcGenericObject

Objeto Genérico 
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcGenericObject
	
	wsData id as string optional
	wsData value as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcBranch

Filial Cobrecom
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcBranch
	
	wsData id as string optional
	wsData name as string optional
	
endWsStruct
