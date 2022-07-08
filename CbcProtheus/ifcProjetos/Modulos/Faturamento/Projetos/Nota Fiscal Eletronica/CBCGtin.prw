#include 'protheus.ch'
#include 'parmtype.ch'

user function CbcGtin(_cProd, _cAcond,_cPed, _cItem)
	Local cRetGtin := ""
	Local cLocaliz := ""
	
	If(_cPed == NIl, "", _cPed)
	If(_cItem == NIl, "", _cItem)
	If(_cAcond == NIl, "", _cAcond)
	
	//Pegar Acondicionamento do Pedido
	If !Empty(_cPed) .And. !Empty(_cItem) .And. Empty(_cAcond)	
		dbSelectArea("SC6")
		SC6->(dbSetOrder(1)) // FILIAL+PEDIDO+ITEM+PRODUTO
		If SC6->(DbSeek(xFilial("SC6") + Padr(_cPed,TamSX3("C6_NUM")[1]) + Padr(_cItem,TamSX3("C6_ITEM")[1])+ Padr(_cProd,TamSX3("C6_PRODUTO")[1]),.F.))			                                                                                                                           
			If SC6->C6_ACONDIC == "B"
				// Para bobinas não incluir a metragem
				cLocaliz := Padr("B", TamSX3("ZJ_LOCALIZ")[1])
			Else
				// Para os demais acondicionamentos, incluir a metragem
				cLocaliz := Padr(SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5),TamSX3("ZJ_LOCALIZ")[1])
			EndIf
		EndIf
	ElseIf !Empty(_cAcond)//Passou Acondicionamento na Chamada
		If Left(_cAcond,1) == "B"
			// Para bobinas não incluir a metragem
			cLocaliz := Padr("B", TamSX3("ZJ_LOCALIZ")[1])
		Else
			// Para os demais acondicionamentos, incluir a metragem
			cLocaliz := Padr(_cAcond, TamSX3("ZJ_LOCALIZ")[1])
		EndIf
	EndIf
	   
	If !Empty(cLocaliz)
		DbSelectArea("SZJ")
		SZJ->(DbSetOrder(1))//FILIAL+PRODUTO+LOCALIZ   
		If (DbSeek(xFilial("SZJ") + Padr(_cProd,TamSX3("ZJ_PRODUTO")[1]) + cLocaliz,.F.))
			cRetGtin := SZJ->ZJ_CODBAR
		EndIf
	EndIf
return cRetGtin