#include 'protheus.ch'
#include 'parmtype.ch'

user function CBCadFCI()
	oCrud := jsonCrud():newjsonCrud("Cliente_FCI") 
	oCrud:showDialog()
	freeobj(oCrud)
return

User Function ValCadFCI(cCodLojCli)
	//Contrutor para visualizar (Portal)
	oCrud := jsonCrud():newjsonCrud("Cliente_FCI", .T. )
	// aItm :=  oCrud:getJson('AREGISTROS')
	lRet := oCrud:existe(cCodLojCli)
	freeobj(oCrud)
Return(lRet)