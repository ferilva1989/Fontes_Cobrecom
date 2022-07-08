#include 'protheus.ch'


class cbcstp02invent 
	data oMainCtrl
	method newcbcstp02invent() constructor 
	method setup()
endclass


method newcbcstp02invent(oCtrl) class cbcstp02invent
	default oCtrl := cbcCtrInvent():newcbcCtrInvent()
	::oMainCtrl := oCtrl 
return(self)


method setup(oNewPag) class cbcstp02invent
	local cCombo1	:= nil
	oNewPag:SetConstruction({|Panel|cria_pg(Panel, @cCombo1)})
	oNewPag:SetStepDescription("PC-Factory - Verificar Recursos Carregados")
	oNewPag:SetNextAction({||valida_pg(@cCombo1)})
	oNewPag:SetCancelAction({||Alert("Cancelou na pagina 2"), .T.})
	oNewPag:SetPrevAction({||Alert("Ops, voce não pode voltar a partir daqui"), .F.})
	oNewPag:SetPrevTitle("Voltar(ou não)")
return(self)


static function cria_pg(oPanel, cCombo1)
	local aItems 	:= {'Item1','Item2','Item3'}
	local oCombo1	:= nil
	cCombo1			:= aItems[1]   
	oCombo1 		:= TComboBox():New(20,20,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItems,100,20,oPanel,,{|| },,,,.T.,,,,,,,,,'cCombo1')
return(nil)


static function valida_pg(cCombo1)
	local lRet := .F.
	if cCombo1 == 'Item3'
		lRet := .T.
	else
		Alert("Você selecionou: " + cCombo1 + " para prossegir selecione Item3")
	endIf
return(lRet)