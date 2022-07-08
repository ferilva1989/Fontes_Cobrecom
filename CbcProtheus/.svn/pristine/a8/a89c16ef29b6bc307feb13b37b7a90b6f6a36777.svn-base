#include 'protheus.ch'
#include 'parmtype.ch'


user function cbcInventWizard(cOper)
	local oPanel		:= nil
	local oNewPag		:= nil
	local oStepWiz 		:= nil
	local oMainCtrl		:= nil
	local oStep01		:= nil
	local oStep02		:= nil
	local oStep03		:= nil
	local cMsg			:= ''
	local cSemNom		:= 'cbcInventWizard'
	
	oMainCtrl			:= cbcCtrInvent():newcbcCtrInvent()
	
	// Controle de transação
	// Controle de erros
	oMainCtrl:setInternal("[INICIO][Wizard Inventario - U_cbcInventWizard ]")
	
	if ! MayIUseCode(cSemNom)
		cMsg := "[SEMAFORO][Bloqueio semaforo - U_cbcInventWizard ]"
		oMainCtrl:setInternal(cMsg)
		MsgAlert('[ERRO] - Rotina deve rodar em modo exclusivo !')
	else
		oStepWiz		:= FWWizardControl():New()
		oStepWiz:SetSize({700,960})
		oStepWiz:ActiveUISteps()
		oStep01		:= cbcstp01invent():newcbcstp01invent(oMainCtrl)
		oStep02		:= cbcstp02invent():newcbcstp02invent(oMainCtrl)
		oStep03		:= cbcstp03invent():newcbcstp03invent(oMainCtrl)

		// TODO iniciar no ultimo passo salvo bd
		if cOper == 'INCLUIR'
			oStep01:setup(oStepWiz:AddStep("1"))
		elseif cOper == 'ATUALIZAR'
			oStep02:setup(oStepWiz:AddStep("2"))	
			oStep03:setup(oStepWiz:AddStep("3"))
		else
			// erro exceção
		endif
		
		// oStepWiz:NextPage()
		oStepWiz:Activate()
		oStepWiz:Destroy()
		oMainCtrl:setInternal("[FIM][Wizard Inventario - U_cbcInventWizard ]")
		Leave1Code(cSemNom)
		
		FreeObj(oStep01)
		FreeObj(oStep02)
		FreeObj(oStep03)
	endif
	
	FreeObj( oMainCtrl )
return(nil)

