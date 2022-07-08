#include 'protheus.ch'
#include 'parmtype.ch'
#include "fwmvcdef.ch"

static function MenuDef()
	local aRotina     	:= {}
	ADD OPTION aRotina TITLE "Liberar Marcados." ACTION 'StaticCall(cbcLibEmpDash, procOpc, "LIB_BOB")' 	OPERATION 3 ACCESS 0
return(aRotina)