#include 'protheus.ch'


class cbcstp03invent 
	data oMainCtrl
	method newcbcstp03invent() constructor 
	method setup()
endclass


method newcbcstp03invent(oCtrl) class cbcstp03invent
	default oCtrl := cbcCtrInvent():newcbcCtrInvent()
	::oMainCtrl := oCtrl 
return(self)


method setup(oNewPag) class cbcstp03invent

	oNewPag:SetConstruction({|Panel|cria_pn(Panel)})
	oNewPag:SetStepDescription("PC-Factory - Bloquear Recursos")
	oNewPag:SetNextAction({||Alert("Fim"), .T.})
	oNewPag:SetCancelAction({||Alert("Cancelou na pagina 3"), .T.})
	oNewPag:SetCancelWhen({||.F.})

return(self)


static function cria_pn(oPanel)
	Local oBtnPanel := TPanel():New(0,0,"",oPanel,,,,,,40,40)
	oBtnPanel:Align := CONTROL_ALIGN_TOP
	oTButton1 := TButton():New( 010, 010, "Botão 01",oBtnPanel,{||alert("Botão 01")}, 80,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2 := TButton():New( 010, 0200, "Botão 02",oBtnPanel,{||alert("Botão 02")}, 80,20,,,.F.,.T.,.F.,,.F.,,,.F. )
return(nil)


static function valida_pg(cCombo1)
	local lRet := .F.
	if cCombo1 == 'Item3'
		lRet := .T.
	else
		Alert("Você selecionou: " + cCombo1 + " para prossegir selecione Item3")
	endIf
return(lRet)