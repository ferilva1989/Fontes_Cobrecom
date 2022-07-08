#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} fArrSx3
//TODO Carrega as informações a partir do SX3 que serão impressas na etiqueta conforme opção escolhida, retorna um array.
@author juliana.leme
@since 27/12/2018
@version 1.0
@param cAliasSX3, characters, Alias do X3
@param cCampo, characters, Campo
@type function
/*/
User function fArrSx3(cAliasSX3,cCampo)
	local aArea := GetArea("SX3")
	local aArrSx3Dad := {}
	
	dbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	SX3->(DbGoTop())
	
	If SX3->(DbSeek(cAliasSX3))
		While SX3->X3_ARQUIVO == cAliasSX3
			If Alltrim(SX3->X3_TITULO) == Alltrim(cCampo) .or. Alltrim(SX3->X3_CAMPO) == Alltrim(cCampo)
				aArrSx3Dad := {Alltrim(SX3->X3_TITULO) ,SX3->X3_CAMPO,SX3->X3_TIPO}
				RestArea(aArea)
				return(aArrSx3Dad)
			EndIf
			SX3->(DBSkip())
		EndDo
	EndIf	
	RestArea(aArea)
return(aArrSx3Dad)

/*/{Protheus.doc} MontaSx
//TODO Funcao criada para varrer o SX3, pois a funcao FWSX3Util nï¿½o esta disponivel na data atual
			FWSX3Util():GetAllFields( "SC6" , .F. )
@author juliana.leme
@since 05/12/2018
@version 1.0
@param cAliasSX, characters, descricao
@type function
/*/
user function MontaSx(cAliasSX)
	local aDadSx3 := {}
	SX3->(DBSetOrder(1))
	SX3->(DbGoTop())
	
	If SX3->(DbSeek(cAliasSX))
		While SX3->X3_ARQUIVO == cAliasSX
			if SX3->X3_CONTEXT <> "V"
				aAdd(aDadSx3,SX3->X3_TITULO)
			endif
			SX3->(DBSkip())
		EndDo
	EndIf
return(aDadSX3)

user function zzxxLeoTs()
	aVer := u_CalcBob('3996304501',1000, .T., '316425', '01')
	_cPsBobP := At(_TpBob," 65/25, 65/45, 80/45,100/60,125/70,150/80,170/80")
	_cPsBobP := Str(((_cPsBobP+6)/7),1)
return nil
