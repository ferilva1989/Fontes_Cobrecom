#include 'protheus.ch'

/*/{Protheus.doc} SigaArea

@author bolognesi
@since 07/04/2016
@version 1.0
@example
oArea := SigaArea():newSigaArea()
@description Classe para abstrair os controles relacionados a areas de trabalho
com o metodo saveArea() e backArea() possibilita salvar e restaurar as areas
alem das areas solicitadas atraves do parametro a area global (GetArea()), é salva
por default
/*/
class SigaArea 
	data aAreas

	method newSigaArea() constructor
	method getAreas()
	method setAreas() 
	method saveArea()
	method backArea()

endclass

/*/{Protheus.doc} newSigaArea
@author bolognesi
@since 07/04/2016 
@version 1.0
@description Construtor do metodo
/*/
method newSigaArea() class SigaArea
	::aAreas := {}
return self

/*/{Protheus.doc} getAreas
@author bolognesi
@since 07/04/2016
@version 1.0
@type method
@description Metodo que obtem o valor da propriedade aAreas
/*/
method getAreas() class SigaArea
return ::aAreas

/*/{Protheus.doc} setAreas
@author bolognesi
@since 07/04/2016
@version 1.0
@param cNewArea, string, Area a ser guardada
@type function
/*/
method setAreas(cNewArea) class SigaArea	

	AAdd(::aAreas, cNewArea)

return

/*/{Protheus.doc} saveArea
@author bolognesi
@since 07/04/2016
@version 1.0
@param aArea, array, Contem a string de cada area a ser preservada
@param lLimpa, Boolean, Paramtero opcional que permite limpa o array que contem as areas salvas
@type function
@description Metodo para salvar a area, de acordo com o parametro, por padrão
sempre que chamado limpa o array que contém as areas, caso queria concatenar
utilizar o 2 parametro como .F.
/*/
method saveArea(aArea, lLimpa)	class SigaArea
	Local nX 		:= 0
	Local cTmpArea 	:= "" 
	Default aArea	:= {}
	Default lLimpa	:= .T.

	If lLimpa
		::aAreas := {}
		::setAreas(GetArea())
	EndIf

	For nX := 1 To Len(aArea)
		If Select(aArea[nX]) > 0 
			cTmpArea := aArea[nX] + '->(GetArea())'
			::setAreas(&cTmpArea)
		EndIf 
	Next

return

/*/{Protheus.doc} backArea
@author bolognesi
@since 07/04/2016
@version 1.0
@type method
@param aBArea, utilizado em caso de restaurar areas especificas
@description restaura as areas anteriormente salvas
pode restaurar todas as areas salvas com o metodo saveArea
bem como uma area especifica no paramtero de entrada aBArea
/*/
method backArea(aBArea)	class SigaArea
	Local nY		:= 0
	Private aArea 	:= ::getAreas()
	Private nX		:= 0
	Default aBArea	:= {}

	If !Empty(aArea)
		For nX := Len(aArea) To 1  Step -1
			If !Empty(aArea[nX]) 

				If !Empty(aBArea) 
					For nY := 1 To Len(aBArea)
						If aBArea[nY] == aArea[nX,1] 
							cTmpArea := "RestArea(aArea[nX])"
							&cTmpArea
						EndIf
					Next nY
				Else
					cTmpArea := "RestArea(aArea[nX])"
					&cTmpArea

				EndIf

			EndIf 
		Next

	EndIf
return
