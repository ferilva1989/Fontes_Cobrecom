#include 'protheus.ch'
#Include 'FWMVCDef.ch'


class cbcMdlCtrl 
	data lOk
	data aErro
	data cIDModel
	data cPrgModel
	data cAls

	method newcbcMdlCtrl() constructor 

	method setStatus()
	method isOk()
	method getErro()
	method setInitSet()

	method getNewModel()
	method setVlrModel()
	method saveAModel()
endclass


method newcbcMdlCtrl(cIdModel, cPrgModel, cAls) class cbcMdlCtrl
	default cIdModel 	:= ''
	default cPrgModel 	:= ''
	default cAls		:= ''
	if !empty(cIdModel) .and. !empty(cPrgModel) .and. !empty(cAls)
		::setInitSet(cIdModel, cPrgModel, cAls)
	endif
return(self)


method setStatus(lSts, aErro) class cbcMdlCtrl
	default lSts := .T.
	default aErro := {}
	::lOk 	:= lSts
	::aErro	:= aErro
return(self)


method isOk() class cbcMdlCtrl
return(::lOk)


method getErro() class cbcMdlCtrl
return(::aErro)


method setInitSet(cIdModel, cPrgModel, cAls)class cbcMdlCtrl
	default cIdModel 	:= ''
	default cPrgModel 	:= ''
	default cAls		:= ''
	if empty(cIdModel) .or. empty(cPrgModel) .or. empty(cAls)
		::setStatus(.F., {'cIdModel, cPrgModel e cAls são parametros Obrigatorios!'})
	else
		::cIDModel 	:= cIdModel
		::cPrgModel	:= cPrgModel
		::cAls		:= cAls
		::setStatus()
	endif
return(self)


method getNewModel(xOper, nRec)class cbcMdlCtrl
	local oModel	:= nil
	default nRec := 0
	trataOp(@xOper)
	if !empty(nRec) .and. xOper <> MODEL_OPERATION_INSERT
		(::cAls)->(DbGoTo(nRec))
	endif
	oModel := FWLoadModel(::cPrgModel)
	oModel:SetOperation(xOper)
	oModel:Activate()
return(oModel)


method setVlrModel(oModel,aFldVlr) class cbcMdlCtrl
	default aFldVlr	:= {}
	if !empty(aFldVlr)
		for nX := 1 to len(aFldVlr)
			oModel:SetValue(::cIDModel,aFldVlr[nX,1],aFldVlr[nX,2])
		next nX
	endif
return(self)


method saveAModel(oModel) class cbcMdlCtrl
	local lRet	:= .T.
	local aErro	:= {}
	default oModel := nil
	if !empty(oModel)
		if ! (lRet := oModel:VldData())
			aErro := oModel:GetErrorMessage()
		else
			if ! (lRet := oModel:CommitData())
				aErro := oModel:GetErrorMessage()
			endif
			// FWFormCommit(oModel)
		endIf
	else
		lRet := .F.
		aadd(aErro, 'Não permitido salvar modelo de dados vazio!')
	endif
	oModel:DeActivate()
	::setStatus(lRet, aErro)
return(self)

static function trataOp(cOp)
	if cOp == 'INSERT'
		cOp := MODEL_OPERATION_INSERT
	elseif cOp == 'VIEW'
		cOp := MODEL_OPERATION_VIEW 
	elseif cOp == 'UPDATE'
		cOp := MODEL_OPERATION_UPDATE
	elseif cOp == 'DELETE'
		cOp := MODEL_OPERATION_DELETE
	endif
return(nil)
