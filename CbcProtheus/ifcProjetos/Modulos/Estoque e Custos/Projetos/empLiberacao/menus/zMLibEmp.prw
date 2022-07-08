#include 'protheus.ch'
#include 'parmtype.ch'
#include "fwmvcdef.ch"

static function MenuDef(cDesc)
	local aRotina     	:= {}
	if cDesc == 'Pedidos'
		// ADD OPTION aRotina TITLE "Simula Liber." 	ACTION 'StaticCall(cbcLibEmpDash, procOpc, "PED_SIMUL")' 	OPERATION 4 ACCESS 0
		// ADD OPTION aRotina TITLE "Libera Autom." 	ACTION 'StaticCall(cbcLibEmpDash, procOpc, "PED_AUTOM")' 	OPERATION 4 ACCESS 0
		ADD OPTION aRotina TITLE "Calculos Pedido"	ACTION 'StaticCall(cbcLibEmpDash, procOpc, "PED_CALC",,.F.)' 	OPERATION 4 ACCESS 0
		ADD OPTION aRotina TITLE "Resumo Estoque" 	ACTION 'StaticCall(cbcLibEmpDash, procOpc, "EST_SIT",,.F.)' 		OPERATION 4 ACCESS 0
		ADD OPTION aRotina TITLE "Bobinas" 			ACTION 'StaticCall(cbcLibEmpDash, procOpc, "LIB_BOBINAS")' OPERATION 4 ACCESS 0
		// ADD OPTION aRotina TITLE "Manut. Status" 	ACTION 'StaticCall(cbcLibEmpDash, procOpc, "PED_DESMARCA")' OPERATION 9 ACCESS 0
	elseif cDesc == 'Blq. Estoque'
		ADD OPTION aRotina TITLE "Liberar" ACTION 'StaticCall(cbcLibEmpDash, procOpc, "LIB_LIBERAR")' OPERATION 4 ACCESS 0
	elseif cDesc == 'Empenhos'
		ADD OPTION aRotina TITLE "Cancelar Emp." ACTION 'StaticCall(cbcLibEmpDash, procOpc, "EMP_CANC")' OPERATION MODEL_OPERATION_DELETE ACCESS 0
	endif
return (aRotina)