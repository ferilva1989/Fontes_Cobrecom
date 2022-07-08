#include 'protheus.ch'

/*/{Protheus.doc} MTValAvC
@type function
@author bolognesi/juliana
@since 16/08/2018
@version 1.0
@description Utilizada nas liberações de Credito, qualquer risco
e permite realizar processamento apos liberações.
* Utilizado para cancelar reservas do portal assumindo ela para
o pedido agora em diante.
/*/
user function MTValAvC()
	if type('PARAMIXB[3]') == 'N'
		if PARAMIXB[3] == 3
			cbcReLib() 
		endif
	endif
return(PARAMIXB[2])


static Function cbcReLib()    
	local aArea		:= getArea()
	local aSC6Area	:= SC6->(getArea())
	local aSC9Area	:= SC9->(getArea())
	local oResInter 
	
	if Empty(SC9->C9_BLCRED) .And. SC9->C9_BLEST == '02' .And. !Empty(SC6->C6_ZZNRRES)
		oResInter := CbcInternalReserves():newCbcInternalReserves( SC6->(Recno()) , SC9->(Recno())  )
		oResInter:creditRelease()
	endif
	
	RestArea(aSC9Area)
	RestArea(aSC6Area)
	RestArea(aArea)
return(nil)
