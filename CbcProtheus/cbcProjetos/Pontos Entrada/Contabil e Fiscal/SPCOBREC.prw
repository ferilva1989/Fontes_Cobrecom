#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} SPCOBREC
//TODO Descrição auto-gerada
	Paramixb[1] => Tipo GNRE.
	Paramixb[2] => ESTADO da GNRE
@author juliana.leme
@since 28/11/2017
@version 1.0
@param cNumChave, characters, descricao
@type function
/*/
user function SPCOBREC()
	Local cTipoImp 	:= Paramixb[1]	// Tipo de Imposto (3 - ICMS ST ou B - Difal e Fecp de Difal)
	Local cEstado 	:= Paramixb[2]	// Estado da GNRE
	Local cCod 		:= "" 			// Codigo a ser gravado no campo F6_COBREC
	 
	If cTipoImp == "B"
		cCod := "000"
	Else 
		cCod := "999" 
	EndIf
Return cCod