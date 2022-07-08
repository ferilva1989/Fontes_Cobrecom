#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch" 

/*/{Protheus.doc} MT140APV
//Grupo aprovadores Pre-Nota
@author bolognesi
@since 24/03/2016
@version 1.0
@description Ponto de entrada para a gravação do grupo de 
aprovadores, executado pela rotina MA140Grava()
/*/
User Function MT140APV
	Local cOldGrp	:= PARAMIXB[1]
	Local cNewGrp 	:= ""
	Local oArea 	:= SigaArea():newSigaArea()
	Local ogroup 

	oArea:saveArea({'SF1','SD1'})

	ogroup := groupApprovers():newgroupApprovers()
	If ogroup:haveGroup()
		cNewGrp := ogroup:getGrpAprov()
	Else
		cNewGrp := cOldGrp
	endIf

	oArea:backArea()

Return cNewGrp