#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MA410MNU
//TODO Ponto de Entrada em que inclui funções especificas no Menu do Mata410.
@author juliana.leme
@since 14/07/2017
@version undefined

@type function
/*/
user function MA410MNU()
	Local i 					:= 0
	Local aUserCB 		:= PswRet(1)
	Local lOk				:= .F.
	
	Aadd(aRotina, {"Alt.Ped.Liberado", "U_AltBlqPed()", 0, 4})
	
	For i := 1 To Len(aUserCB[1][10])
		If aUserCB[1][10][i] == "000091"
			lOk := .T.
		EndIf
	Next
	If lOk  
		Aadd(aRotina, {"Alt.Aliq.Pedido", "U_AltAlPed()", 0, 5})
	EndIf
return