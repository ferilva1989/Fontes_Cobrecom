#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} SIGAFAT
@author bolognesi
@since 19/06/2017
@version 1.0
@type function
@description Ponto de entrada executado ao iniciar-se o modulo SIGAFAT
utilizado para filtrar registros de acordo com o usuario logado
/*/
user function SigaFat()
	local ocbFil := nil
	if !GetNewPar('XX_RELPAD', .T.)
		ocbFil := cbcAclFil():newcbcAclFil("SIGAFAT")
		FreeObj(ocbFil)
	endif
return