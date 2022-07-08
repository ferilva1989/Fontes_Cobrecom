#include 'protheus.ch'
#include 'FWMVCDef.ch'

class ctrlIniFormul
	data lShowMsg
	data lOk
	data cMsgErr
	data cKey
	data aFormulas
	data lValidAccess

	method newctrlIniFormul() constructor

	method setStatus()
	method isOk()
	method doValid()
	method getErrMsg()
	method isShowing()
	method getKeyForm()
	method setKeyForm()
	method getFormulas()
	method setFormulas()
	method loadFormulas()
	method addFormula()
	method editFormula()
	method delFormula()
	method validAccess()
	method validFormula()
	method getTip()
endclass

method newctrlIniFormul(cKey, lShowMsg, lValid) class ctrlIniFormul
	default lShowMsg := .T.
	default cKey     := ''
	default lValid	 := .T.

	::lShowMsg 		:= lShowMsg
	::lValidAccess 	:= lValid
	::setStatus()
	::setKeyForm(cKey)
	::setFormulas()
return(self)

method setStatus(lOk, cMsg, lEx) class ctrlIniFormul
	default lOk			:= .T.
	default cMsg 		:= ''
	default lEx			:= .F.

	::lOk				:= lOk

	if !lOk
		::cMsgErr	:= "[ctrlIniFormul - "+DtoC(Date())+" - "+Time()+" ] " + '[ERRO]' + cMsg
		if lEx
			UserException(::cMsgErr)
		endif
		if ::isShowing()
			MsgAlert(::cMsgErr, 'Aviso')
		endif
	endif
return(self)

method isOk() class ctrlIniFormul
return(::lOk)

method doValid() class ctrlIniFormul
return(::lValidAccess)

method getErrMsg() class ctrlIniFormul
return(::cMsgErr)

method isShowing() class ctrlIniFormul
return(::lShowMsg)

method getKeyForm() class ctrlIniFormul
return(::cKey)

method setKeyForm(cKey) class ctrlIniFormul
	::cKey := cKey
	::setFormulas()
return(self)

method getFormulas() class ctrlIniFormul
	local aFormulas := ::aFormulas
	if empty(aFormulas)
		::loadFormulas()
		aFormulas := ::aFormulas
	endif
return(aFormulas)

method setFormulas(aFormulas) class ctrlIniFormul
	default aFormulas := {}
	::aFormulas := aFormulas
return(self)

method loadFormulas() class ctrlIniFormul
	local oSql		:= NIL
	local cAdd 		:= ''
	local aFormulas := {}
	Local oStatic   := IfcXFun():newIfcXFun()

	::setFormulas()
	oSql 	 := LibSqlObj():newLibSqlObj()
	oSql:newAlias(oStatic:sP(1):callStatic('qryIniFormul', 'qryIniForm', ::getKeyForm()))
	If oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			cAdd :=  &(oSql:getValue("FORMULA"))//TRANSFORMA EM STRING
			aAdd(aFormulas, {oSql:getValue("FILIAL"),;
				oSql:getValue("KEY"),;
				cAdd,;
				oSql:getValue("CODIGO"),;
				oSql:getValue("REC");
				})
			oSql:skip()
		endDo
		::setFormulas(aFormulas)
		oSql:close()
		FreeObj(oSql)
	endif
return(self)

method addFormula(aFormulas) class ctrlIniFormul
	local nX 		:= 0
	local aReg		:= {}
	local aGrava 	:= {}
	local aRet		:= {}
	local cSM4Id	:= getNextID()

	if ::setStatus(!empty(::getKeyForm()), 'CHAVE não atribuida!', .T.):isOk()
		if ::validAccess(::getKeyForm()):isOk()
			for nX := 1 to len(aFormulas)
				aReg := {}
				if ::validFormula(aFormulas[nX, 2]):isOk()
					aAdd(aReg, {'M4_CODIGO', cSM4Id})
					aAdd(aReg, {'M4_DESCR',iif(empty(aFormulas[nX, 1]), '00', aFormulas[nX, 1]) + '-' + ::getKeyForm()})
					aAdd(aReg, {'M4_FORMULA', '"' + AllTrim(aFormulas[nX, 2]) + '"'})
					cSM4Id := getNextID()
					aAdd(aGrava, {0,aClone(aReg)})
				endif
			next nX
			if (::isShowing() .and. (len(aGrava) == len(aFormulas)))
				if !MsgYesNo('Fórmula(s) aprovada(s) ' + cValToChar(len(aGrava)) + ' de '  + cValToChar(len(aFormulas))+ '. Serão alteradas apenas as Aprovadas, continua?', 'Continuar')
					aGrava := {}
				endif
			endif
			if !empty(aGrava)
				aRet := gravaFormula(MODEL_OPERATION_INSERT, aGrava, @self)
				::setStatus(aRet[1],aRet[2],.T.)
			endif
		endif
		if ::isOk() .and. ::isShowing()
			MsgInfo('Fórmula Incluída!','Sucesso')
		endif
	endif
return(self)

method editFormula(aFormulas) class ctrlIniFormul
	local nX 		:= 0
	local aRet		:= {}
	local aGrava	:= {}
	local aReg		:= {}

	if ::setStatus(!empty(::getKeyForm()), 'CHAVE não atribuida!', .T.):isOk()
		if ::validAccess(::getKeyForm()):isOk()
			for nX := 1 to len(aFormulas)
				aReg := {}
				if ::validFormula(aFormulas[nX, 3]):isOk()
					aAdd(aReg, {'M4_DESCR',iif(empty(aFormulas[nX, 2]), '00', aFormulas[nX, 2]) + '-'+ ::getKeyForm()})
					aAdd(aReg, {'M4_FORMULA', '"' + AllTrim(aFormulas[nX, 3]) + '"'})
					aAdd(aGrava, {aFormulas[nX, 1], aClone(aReg)})
				endif
			next nX
			if (::isShowing() .and. (len(aGrava) == len(aFormulas)))
				if !MsgYesNo('Fórmula(s) aprovada(s) ' + cValToChar(len(aGrava)) + ' de '  + cValToChar(len(aFormulas))+ '. Serão inseridas apenas as Aprovadas, continua?', 'Continuar')
					aGrava := {}
				endif
			endif
			if !empty(aGrava)
				aRet := gravaFormula(MODEL_OPERATION_UPDATE, aGrava, @self)
				if ::setStatus(aRet[1],aRet[2],.T.):isOk() .and. ::isShowing()
					MsgInfo('Fórmula Alterada!','Sucesso')
				endif
			endif
		endif
	endif
return(self)

method delFormula(aFormulas) class ctrlIniFormul
	local nX 		:= 0
	local aRet		:= {}
	local aGrava	:= {}

	if ::setStatus(!empty(::getKeyForm()), 'CHAVE não atribuida!', .T.):isOk()
		if ::validAccess(::getKeyForm()):isOk()
			for nX := 1 to len(aFormulas)
				aAdd(aGrava, {aFormulas[nX, 1], {}})
			next nX
			if !empty(aGrava)
				aRet := gravaFormula(MODEL_OPERATION_DELETE, aGrava, @self)
				if ::setStatus(aRet[1],aRet[2],.T.):isOk() .and. ::isShowing()
					MsgInfo('Fórmula Deletada!','Sucesso')
				endif
			endif
		endif
	endif
return(self)

method validAccess(cKey) class ctrlIniFormul
	local oAcl		:= cbcAcl():newcbcAcl()
	local oFormulas	:= ctrlIniFormul():newctrlIniFormul()
	local cOptions  := AllTrim(GetNewPar('ZZ_OPCFORM', 'OPC_FORMULAS'))
	local aOptions	:= {}
	local nPosi		:= 0
	default cKey	:= ::getKeyForm()

	if (AllTrim(cKey) <> cOptions) .and. ::doValid()
		oFormulas:setKeyForm(cOptions)
		aOptions := oFormulas:getFormulas()
		nPosi := aScan(aOptions, {|x| "'" + AllTrim(cKey) + "'" $ AllTrim(x[3])})
		if ::setStatus(nPosi > 0,'Dados de acessos não localizados!', .F.):isOk()
			aReg := &(aOptions[nPosi,3])
			if len(aReg) > 2
				if !empty(aReg[3])
					::setStatus(oAcl:usrIsGrp(aReg[3]),'Acesso Negado!',.F.):isOk()
				endif
			endif
		endif
	endif
	FreeObj(oAcl)
	FreeObj(oFormulas)
return(self)

method validFormula(cForm, cKey) class ctrlIniFormul
	local oFormulas	:= ctrlIniFormul():newctrlIniFormul()
	local cOptions  := AllTrim(GetNewPar('ZZ_OPCFORM', 'OPC_FORMULAS'))
	local aOptions	:= {}
	local nPosi		:= 0
	local xForm		:= ''
	default cKey	:= ::getKeyForm()

	if !empty(cForm)
		xForm	:= &(cForm)
		oFormulas:setKeyForm(cOptions)
		aOptions := oFormulas:getFormulas()
		nPosi := aScan(aOptions, {|x| "'" + AllTrim(cKey) + "'" $ AllTrim(x[3])})
		if ::setStatus(nPosi > 0,'Dados de Validação da Formula não localizados!', .F.):isOk()
			xReg := &(aOptions[nPosi,3])[4]
			::setStatus(validElement(xReg, xForm),'Tipo de dado incorreto!',.F.):isOk()
		endif
	endif
	FreeObj(oFormulas)
return(self)

method getTip(cKey) class ctrlIniFormul
	local oFormulas	:= ctrlIniFormul():newctrlIniFormul()
	local cOptions  := AllTrim(GetNewPar('ZZ_OPCFORM', 'OPC_FORMULAS'))
	local aOptions	:= {}
	local nPosi		:= 0
	local aReg		:= {}
	local cTip 		:= 'Sem Dicas cadastradas!'
	default cKey	:= ::getKeyForm()

	oFormulas:setKeyForm(cOptions)
	aOptions := oFormulas:getFormulas()
	nPosi := aScan(aOptions, {|x| "'" + AllTrim(cKey) + "'" $ AllTrim(x[3])})
	if (nPosi > 0)
		aReg := &(aOptions[nPosi,3])
		if len(aReg) >= 4
			cTip := aReg[5]
		endif
	endif
	MsgInfo(cTip, 'Dica')
	FreeObj(oFormulas)
return(self)

static function validElement(xReg, xForm)
	local lVld 	:= (ValType(xReg) == ValType(xForm))
	local nX 	:= 0

	if lVld
		if ValType(xReg) == 'A'
			if (len(xReg) == len(xForm)) .and. cValToChar(xReg[len(xReg)]) <> '...'
				lVld := .T.
				for nX := 1 to len(xReg)
					if !(lVld 	:= (ValType(xReg[nX]) == ValType(xForm[nX])))
						EXIT
					else
						if ValType(xReg[nX]) == 'A'
							if !(lVld := validElement(xReg[nX], xForm[nX]))
								EXIT
							endif
						endif
					endif
				next nX
			elseif cValtoChar(xReg[len(xReg)]) == '...' .and. len(xReg) == 2 .and. ValType(xForm) == 'A'
				lVld := .T.
				for nX := 1 to len(xForm)
					if !(lVld 	:= (ValType(xReg[01]) == ValType(xForm[nX])))
						EXIT
					else
						if ValType(xReg[01]) == 'A'
							if !(lVld := validElement(xReg[01], xForm[nX]))
								EXIT
							endif
						endif
					endif
				next nX
			else
				lVld := .F.
			endif
		endif
	endif
return(lVld)

static function gravaFormula(nOper, aGrava, oSelf)
	local aArea    	:= GetArea()
	local aAreaSM4	:= SM4->(getArea())
	local oModel	:= nil
	local aFldVlr	:= {}
	local nX		:= 0
	local nY		:= 0
	local bErro		:= nil
	local aErro		:= {}
	local cErro		:= ''
	default oSelf	:= ctrlIniFormul():newctrlIniFormul()

	bErro		:= ErrorBlock({|oErr| errHandle(oErr, @oSelf)})
	BEGIN SEQUENCE
		BEGIN TRANSACTION
			for nX := 1 to len(aGrava)
				oModel := FWLoadModel('cbcSM4Model')
				oModel:SetOperation(nOper)
				if !empty(aGrava[nX, 1]) .and. nOper <> MODEL_OPERATION_INSERT
					SM4->(DbGoTo(aGrava[nX, 1]))
				endif
				oModel:Activate()
				aFldVlr := aGrava[nX, 2]
				for nY := 1 to len(aFldVlr)
					oModel:LoadValue('SM4MASTER',aFldVlr[nY,1],aFldVlr[nY,2])
				next nY
				if !(lRet := FWFormCommit(oModel))
					aErro := oModel:GetErrorMessage()
					if !empty(aErro)
						cErro += aErro[2] + '-'
						cErro += aErro[4] + '-'
						cErro += aErro[5] + '-'
						cErro += aErro[6]
						Help( ,, cErro ,, 'Erro', 1,0)
					endif
				endif
				oModel:DeActivate()
				FreeObj(oModel)
				if !lRet
					EXIT
				endif
			next nX
		END TRANSACTION
		RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
	RestArea(aAreaSM4)
	RestArea(aArea)
return({lRet, cErro})

static function getNextID()
	local aArea    	:= GetArea()
	local aAreaSM4	:= SM4->(getArea())
	local cId		:= ''

	DbSelectArea('SM4')
	SM4->(DbSetOrder(1))
	cId	:= GetSXENum("SM4","M4_CODIGO")
	ConfirmSX8()
	While SM4->(DbSeek(xFilial("SM4")+ cId ,.F.))
		cId := GetSXENum("SM4","M4_CODIGO")
		ConfirmSX8()
	EndDo

	RestArea(aAreaSM4)
	RestArea(aArea)
return(cId)

static function errHandle(oErr, oSelf)
	local cErro	:= oErr:Description + ' [FROM] ' + ProcName(3)
	if InTransact()
		DisarmTransaction()
	endif
	ConOut(cErro)
	oSelf:setStatus(.F., cErro)
	BREAK
return(nil)
