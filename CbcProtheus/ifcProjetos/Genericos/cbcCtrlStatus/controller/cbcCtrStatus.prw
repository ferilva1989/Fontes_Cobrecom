#include 'protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'statusPedido.ch'

class cbcCtrStatus 
	data cAlsMaster
	data nRecMaster
	data cIdSecao

	method newcbcCtrStatus() constructor 
	method setStatus()
	method getStatus()
	method clrStatus()
	method getRegEnv()
	method setMaster()
	method chgFromTo()
	method getSecBySts()
	method getMstBySts()
	method getDetByMst()
	method getAllFrmSts()
	method lvlCompare()
	method getAllStatus()
	method moveInSts()
	method getGroup()
	method groupRec()
	method getFrmOs()
	method getAllOs()

endclass


method newcbcCtrStatus() class cbcCtrStatus
	::setMaster()
return(self)


method setStatus(cAls, nRec, cNewSts) class cbcCtrStatus
	local lRet	:= .F.
	default cAls 	:= '' 
	default nRec	:= 0
	if vldSelf(self)
		if posChv(cAls, nRec, self)
			lRet := updZZ9(cNewSts)
		else
			lRet := insZZ9(cAls, nRec,cNewSts, self)
		endif
	endif
return(lRet)


method getStatus(cAls, nRec) class cbcCtrStatus
	local lRet		:= .F.
	local cStatus	:= ''
	default cAls 	:= '' 
	default nRec	:= 0
	if vldSelf(self)
		if posChv(cAls, nRec, self)
			cStatus := Alltrim(ZZ9->(ZZ9_STATUS))
		else
			cStatus := ''
		endif
	endif
return(cStatus)


method clrStatus(cAls, nRec) class cbcCtrStatus
	local lRet	:= .F.
	if vldSelf(self)
		if posChv(cAls, nRec, self)
			lRet := delZZ9()
		endif
	endif
return(lRet)


method setMaster(cAls, nRec, cIdSecao) class cbcCtrStatus
	default cAls 		:= ''
	default nRec 		:= 0
	default cIdSecao	:= ''
	::cAlsMaster 		:= cAls 
	::nRecMaster		:= nRec
	::cIdSecao			:= cIdSecao
	if !empty(cAls) .and. ( nRec > 0 ) .and. !empty(cIdSecao)
		(::cAlsMaster)->(DbGoTo(::nRecMaster))
	endif
return(self)


method getRegEnv(cSts) class cbcCtrStatus
	local oSql 			:= LibSqlObj():newLibSqlObj()
	local cQry			:= ''
	local aReg			:= {}
	local nPos			:= 0
	if vldSelf(self)
		cQry += " SELECT  "
		cQry += " ZZ9.ZZ9_ALSDET AS [ALIAS_DET], "
		cQry += " ZZ9.ZZ9_RECDET AS [REC_DET] "
		cQry += " FROM  %ZZ9.SQLNAME% "
		cQry += " WHERE %ZZ9.XFILIAL% "
		cQry += " AND ZZ9.ZZ9_ALSMST = '" + ::cAlsMaster + "' "
		cQry += " AND ZZ9.ZZ9_RECMST = " + cValToChar(::nRecMaster)
		cQry += " AND ZZ9.ZZ9_STATUS = '" + cSts + "' "
		cQry += " AND %ZZ9.NOTDEL% "
		cQry += " ORDER BY ZZ9.ZZ9_ALSDET, ZZ9.ZZ9_RECDET,  ZZ9.ZZ9_STATUS "

		oSql:newAlias(cQry)
		if oSql:hasRecords()
			oSql:goTop()
			while oSql:notIsEof()
				nPos := 0
				if (nPos := Ascan(aReg, {|aReg| aReg[1]  == oSql:getValue('ALIAS_DET') }) ) > 0
					aadd(aReg[nPos,2] , oSql:getValue('REC_DET'))
				else
					aadd(aReg, {oSql:getValue('ALIAS_DET'),{oSql:getValue('REC_DET')} })
				endif
				oSql:skip()
			endDo
			oSql:close() 
		endif
	endif
	FreeObj(oSql)
return(aReg)


method chgFromTo(cStsFr, cStsTo) class cbcCtrStatus
	local aReg	:= {}
	local nX	:= 0
	local nY	:= 0
	if vldSelf(self)
		if !empty(aReg := ::getRegEnv(cStsFr))
			for nX := 1 to len(aReg)
				for nY := 1 to len(aReg[nX,2])
					::setStatus(aReg[nX,1], aReg[nX,2,nY], cStsTo)
				next nY
			next nX
		endif
	endif
return(self)


method getSecBySts(cBySts) class cbcCtrStatus
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local cQry		:= ''
	local aSec		:= {}
	default cBySts	:= ''
	if !empty(cBySts)
		cQry += " SELECT  "
		cQry += " DISTINCT ZZ9.ZZ9_SECAO AS [ID_SEC] "
		cQry += " FROM  %ZZ9.SQLNAME% "
		cQry += " WHERE %ZZ9.XFILIAL% "
		cQry += " AND ZZ9.ZZ9_STATUS = '" + cBySts + "' "
		cQry += " AND %ZZ9.NOTDEL% "
		oSql:newAlias(cQry)
		if oSql:hasRecords()
			oSql:goTop()
			while oSql:notIsEof()
				aadd(aSec, oSql:getValue('ID_SEC') )
				oSql:skip()
			endDo
			oSql:close() 
		endif
	endif
	FreeObj(oSql)
return(aSec)


method getMstBySts(cBySts) class cbcCtrStatus
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local cQry		:= ''
	local aReg		:= {}
	local nPos		:= 0
	default cBySts	:= ''
	if !empty(cBySts)
		cQry += " SELECT  "
		cQry += " DISTINCT ZZ9.ZZ9_RECMST AS [REC],"
		cQry += " ZZ9.ZZ9_ALSMST AS [ALIAS]"
		cQry += " FROM  %ZZ9.SQLNAME% "
		cQry += " WHERE %ZZ9.XFILIAL% "
		cQry += " AND ZZ9.ZZ9_STATUS = '" + cBySts + "' "
		cQry += " AND %ZZ9.NOTDEL% "
		cQry += " GROUP BY ZZ9.ZZ9_ALSMST, ZZ9.ZZ9_RECMST "
		oSql:newAlias(cQry)
		if oSql:hasRecords()
			oSql:goTop()
			while oSql:notIsEof()
				nPos := 0
				if (nPos := Ascan(aReg, {|aReg| aReg[1]  == oSql:getValue('ALIAS') }) ) > 0
					aadd(aReg[nPos,2] , oSql:getValue('REC'))
				else
					aadd(aReg, {oSql:getValue('ALIAS'),{oSql:getValue('REC')} })
				endif
				oSql:skip()
			endDo
			oSql:close() 
		endif
	endif
	FreeObj(oSql)
return(aReg)


method getDetByMst(cMstAls, cRecMst) class cbcCtrStatus
	local oSql 			:= LibSqlObj():newLibSqlObj()
	local cQry			:= ''
	local aReg			:= {}
	local nPos			:= 0
	default cMstAls		:= ::cAlsMaster
	default cRecMst		:= ::nRecMaster

	cQry += " SELECT  "
	cQry += " ZZ9.ZZ9_ALSDET AS [ALIAS_DET], "
	cQry += " ZZ9.ZZ9_RECDET AS [REC_DET] "
	cQry += " FROM  %ZZ9.SQLNAME% "
	cQry += " WHERE %ZZ9.XFILIAL% "
	cQry += " AND ZZ9.ZZ9_ALSMST = '" + cMstAls + "' "
	cQry += " AND ZZ9.ZZ9_RECMST = " + cValToChar(cRecMst)
	cQry += " AND %ZZ9.NOTDEL% "
	cQry += " ORDER BY ZZ9.ZZ9_ALSDET, ZZ9.ZZ9_RECDET,  ZZ9.ZZ9_STATUS "

	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			nPos := 0
			if (nPos := Ascan(aReg, {|aReg| aReg[1]  == oSql:getValue('ALIAS_DET') }) ) > 0
				aadd(aReg[nPos,2] , oSql:getValue('REC_DET'))
			else
				aadd(aReg, {oSql:getValue('ALIAS_DET'),{oSql:getValue('REC_DET')} })
			endif
			oSql:skip()
		endDo
		oSql:close() 
	endif

	FreeObj(oSql)
return(aReg)


method getAllFrmSts(cBySts) class cbcCtrStatus
	local nX			:= 0
	local nY			:= 0
	local aTmpMaster	:= {}
	local aRet			:= {}
	default cBySts		:= ''
	if !empty(cBySts)
		aTmpMaster := ::getMstBySts(cBySts)
		for nX := 1 to len(aTmpMaster)
			cMstTmpAls := aTmpMaster[nX,1]
			for nY := 1 to len(aTmpMaster[nX,2])
				aadd(aRet,{cMstTmpAls,aTmpMaster[nX,2,nY],::getDetByMst(cMstTmpAls, aTmpMaster[nX,2,nY])}) 
			next nY
		next nX
	endif
return(aRet)


method lvlCompare(cStatus, cCompare) class cbcCtrStatus
	local aAllSts		:= {}
	local nPosFrm		:= 0
	local nPosTo		:= 0
	local nX			:= 0
	local cMacEx		:= ''
	private lRet		:= .F.
	default cCompare	:= '>='
	if (nPosFrm := AScan( ARRAY_STATUS,{|aSt| aSt == cStatus }) ) > 0
		aAllSts := ::getAllStatus()
		for nX := 1 to len(aAllSts)
			if(nPosTo := AScan(ARRAY_STATUS,{|aSt| aSt == aAllSts[nX] })) > 0
				cMacEx := 'lRet := (' + cValToChar(nPosFrm) + cCompare + cValToChar(nPosTo) + ' ) ' 
				&(cMacEx)
				if lRet
					exit
				endif 
			endif
		next nX
	endif
return(lRet)


method getAllStatus() class cbcCtrStatus
	local aRet	:= {}
	local oSql 			:= LibSqlObj():newLibSqlObj()
	local cQry			:= ''
	if vldSelf(self)
		cQry += " SELECT  "
		cQry += " DISTINCT ZZ9.ZZ9_STATUS AS [STATUS] "
		cQry += " FROM  %ZZ9.SQLNAME% "
		cQry += " WHERE %ZZ9.XFILIAL% "
		cQry += " AND ZZ9.ZZ9_ALSMST = '" + ::cAlsMaster + "' "
		cQry += " AND ZZ9.ZZ9_RECMST = " + cValToChar(::nRecMaster)
		cQry += " AND %ZZ9.NOTDEL% "
		cQry += " ORDER BY ZZ9.ZZ9_STATUS "
		oSql:newAlias(cQry)
		if oSql:hasRecords()
			oSql:goTop()
			while oSql:notIsEof()
				aadd(aRet, oSql:getValue('STATUS'))
				oSql:skip()
			endDo 
		endif
	endif
	oSql:close()
	FreeObj(oSql)
return(aRet)


method moveInSts(cFromSts, cDire)  class cbcCtrStatus
	local cExecMc	:= ''
	local nLimit	:= Len(ARRAY_STATUS)
	private nPos	:= 0
	default cDire 	:= '+'
	nPos := AScan(ARRAY_STATUS,{|aSt| aSt == cFromSts })
	if (nPos > 1) .and. (nPos < nLimit) 
		cExecMc := 'nPos' + cDire + cDire
		&(cExecMc)
		cFromSts := ARRAY_STATUS[nPos]
	endif
return(cFromSts)


method getGroup(cTipo, cAls, cSts, cFld, xSearch) class cbcCtrStatus
	local aRet		:= {}
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local cQry		:= ''
	local cSpace 	:= Space(TamSx3('C9_BLEST')[1])
	local cSpaceCR 	:= Space(TamSx3('C9_BLCRED')[1])

	cQry += " SELECT  "

	if cTipo == 'MASTER'
		cQry += " DISTINCT ZZ9.ZZ9_RECMST AS [REC] "
	elseif cTipo == 'DETAIL'
		cQry += " SC5.R_E_C_N_O_ AS [REC_SC5], "
		cQry += " ZZ9.ZZ9_RECDET AS [REC_SDC], "
		cQry += " SC9.R_E_C_N_O_ AS [REC_SC9] "
	endif

	cQry += " FROM  %ZZ9.SQLNAME% WITH (NOLOCK) "
	if cTipo == 'DETAIL'
		cQry += " INNER JOIN  %SC5.SQLNAME% WITH (NOLOCK) "
		cQry += " ON ZZ9.ZZ9_RECMST = SC5.R_E_C_N_O_ "
		if cAls == 'SC9'
			cQry += " INNER JOIN  %SC9.SQLNAME% WITH (NOLOCK) "
			cQry += " ON ZZ9.ZZ9_RECDET = SC9.R_E_C_N_O_ "
		endif
	endif

	cQry += " WHERE %ZZ9.XFILIAL% "
	if cTipo == 'MASTER'
		cQry += " AND ZZ9.ZZ9_ALSMST = '" + cAls + "' "
	elseif cTipo == 'DETAIL'
		cQry += " AND ZZ9.ZZ9_ALSDET = '" + cAls + "' "
	endif
	cQry += " AND ZZ9.ZZ9_STATUS = '" + cSts + "' "
	if cFld <> '*'
		cQry += " AND ZZ9." + cFld + xSearch
	endif
	cQry += " AND %ZZ9.NOTDEL% "
	if cTipo == 'DETAIL'
		cQry += " ORDER BY SC5.R_E_C_N_O_, SC9.C9_ITEM "
	endif
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			if cTipo == 'MASTER'
				aadd(aRet, oSql:getValue('REC'))
			elseif cTipo == 'DETAIL'
				aadd(aRet, {; 
				oSql:getValue('REC_SC5'),;
				oSql:getValue('REC_SC9') })
			endif
			oSql:skip()
		endDo
		oSql:close() 
	endif
	FreeObj(oSql)
return(aRet)


method getFrmOs(cOrdem, cTipo, cAls, cSts) class cbcCtrStatus
	local aRet	:= {}
	local oSql 			:= LibSqlObj():newLibSqlObj()
	local cQry			:= ''
	default cSts		:= ''
	if vldSelf(self)
		cQry += " SELECT  "
		if cTipo == 'MASTER'
			cQry += " DISTINCT ZZ9.ZZ9_RECMST AS [REC] "
		elseif cTipo == 'DETAIL'
			cQry += " ZZ9.ZZ9_RECDET AS [REC] "
		endif
		cQry += " FROM  %ZZ9.SQLNAME% "
		cQry += " WHERE %ZZ9.XFILIAL% "
		if cTipo == 'MASTER'
			cQry += " AND ZZ9.ZZ9_ALSMST = '" + cAls + "' "
		elseif cTipo == 'DETAIL'
			cQry += " AND ZZ9.ZZ9_ALSDET = '" + cAls + "' "
		endif
		cQry += " AND ZZ9.ZZ9_NROS =  '" + cOrdem + "' "
		if !empty(cSts)
			cQry += " AND ZZ9.ZZ9_STATUS = '" + cSts + "' "
		endif
		cQry += " AND %ZZ9.NOTDEL% "
		oSql:newAlias(cQry)
		if oSql:hasRecords()
			oSql:goTop()
			while oSql:notIsEof()
				aadd(aRet, oSql:getValue('REC'))
				oSql:skip()
			endDo
			oSql:close() 
		endif
	endif
	FreeObj(oSql)
return(aRet)


method groupRec(aFldVlr, cTipo, cAls, nRec, aRelac) class cbcCtrStatus
	local nX		:= 0
	local nY		:= 0
	local cTab		:= ''
	local cWhere	:= ''
	local nLenFld	:= 0
	local aRecCh	:= {}
	local cTp		:= ''
	local cTpFld	:= ''
	local nConte	:= ''
	local lRet		:= .T.

	Begin Transaction
		// Posicionar no registro principal
		DbSelectArea(cAls)
		(cAls)->(DbGoTo(nRec))

		//Atualizar o principal
		changeFld({{nRec,cTipo}},aFldVlr, cAls)

		// Atualizar os relacionamentos
		for nX := 1 to len(aRelac)
			cWhere	:= 	''
			cTp		:= aRelac[nX,1]
			cTab 	:= aRelac[nX,2]
			nLenFld := len(aRelac[nX,3])
			for nY := 1 to  nLenFld 
				cTpFld := TamSX3(aRelac[nX,3,nY,2])[3]
				nConte	:= &(cAls + '->' + '(' + aRelac[nX,3,nY,2] + ')')
				if cTpFld == 'C'
					cWhere += aRelac[nX,3,nY,1] + " = '" + nConte + "' "
				elseif cTpFld == 'N'
					cWhere += aRelac[nX,3,nY,1] + " = " + cValToChar(nConte) + " "
				elseif cTpFld == 'D'
					cWhere += aRelac[nX,3,nY,1] + " = '" + DtoS(nConte) + "' "
				else
					loop
				endif
				if nY < nLenFld
					cWhere += ' AND '
				endif
			next nY
			if !empty(aRecCh := getARec(cTab, cWhere, cTp))
				if ! changeFld(aRecCh, aFldVlr, cTab)
					DisarmTransaction()
					lRet := .F.
				endif
			endif
		next nX
	End Transaction
return(lRet)


method getAllOs(cWhere) class cbcCtrStatus
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local cQry		:= ''
	local aRet		:= {}
	default cWhere	:= ''
	cQry += " SELECT  "
	cQry += " DISTINCT ZZ9.ZZ9_NROS AS [ORDEM] "
	cQry += " FROM  %ZZ9.SQLNAME% "
	cQry += " WHERE %ZZ9.XFILIAL% "
	cQry += " AND ZZ9.ZZ9_NROS <> '' "
	if !empty(cWhere)
		cQry += ' AND ' + cWhere
	endif
	cQry += " AND %ZZ9.NOTDEL% "
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			aadd(aRet, oSql:getValue('ORDEM'))
			oSql:skip()
		endDo
		oSql:close() 
	endif
	FreeObj(oSql)
return(aRet)


static function getARec(cTab, cWhere, cAddFld)
	local aRet		:= {}
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local cQry		:= ''
	default cAddFld	:= 'TIPO'

	cQry += " SELECT  "
	cQry +=  Alltrim(cTab) + ". R_E_C_N_O_ AS [REC], "
	cQry +=  "'" + Alltrim(cAddFld) + "' " + " AS [TIPO] "
	cQry += " FROM  %" + Alltrim(cTab) + ".SQLNAME% "
	cQry += " WHERE " + cWhere
	cQry += " AND %" + Alltrim(cTab) + ".NOTDEL% "
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			aadd(aRet, {oSql:getValue('REC'),oSql:getValue('TIPO')} )
			oSql:skip()
		endDo
		oSql:close() 
	endif
	FreeObj(oSql)

return(aRet)


static function changeFld(aRecCh, aFldVlr, cAls)
	local nX		:= 0
	local nY		:= 0
	local cWhere	:= ''
	local aDo		:= {}
	local lRet		:= .T.

	for nX := 1 to len(aRecCh)
		cWhere := ''
		if aRecCh[nX,2] == 'MASTER'
			cWhere += " ZZ9_ALSMST = '" + Alltrim(cAls) + "' "
			cWhere += " AND ZZ9_RECMST = " + cValToChar(aRecCh[nX,1])
		elseif aRecCh[nX,2] == 'DETAIL'
			cWhere += " ZZ9_ALSDET = '" + Alltrim(cAls) + "' 
			cWhere += " AND ZZ9_RECDET = " + cValToChar(aRecCh[nX,1]) + " "
		endif
		if !empty(aDo := getARec('ZZ9', cWhere))
			for nY := 1 to len(aDo)
				ZZ9->(DbGoTo(aDo[nY,1]))
				lRet := updFld(aFldVlr)
			next nY
		endif
	next nX

return(lRet)


static function updFld(aFldVlr)
	local oZZ9Model := FWLoadModel('cbcMdlGenStatus')
	local cIDModel	:= 'ZZ9MASTER'
	local aErro		:= {}
	local lRet		:= .F.
	local nX		:= 0
	default aFldVlr	:= {}
	if !empty(aFldVlr)
		oZZ9Model:SetOperation(MODEL_OPERATION_UPDATE)
		oZZ9Model:Activate()
		for nX := 1 to len(aFldVlr)
			oZZ9Model:SetValue(cIDModel,aFldVlr[nX,1],aFldVlr[nX,2])
		next nX
		if ! (lRet := oZZ9Model:VldData())
			aErro := oZZ9Model:GetErrorMessage()
		else
			FWFormCommit(oZZ9Model)
		endIf	
		oZZ9Model:DeActivate()
	endif
	FreeObj(oZZ9Model)
return(lRet)


static function vldSelf(oSelf)
	local lRet	:= .T.
	if empty(oSelf:cAlsMaster) .or. ( oSelf:nRecMaster <= 0 ) .or. empty(oSelf:cIdSecao)
		lRet := .F.
	endif
return(lRet)


static function insZZ9(cAls, nRec, cNewSts, oSelf)
	local oZZ9Model 	:= FWLoadModel('cbcMdlGenStatus')
	local cIDModel		:= 'ZZ9MASTER'
	local aErro			:= {}
	local lRet			:= .F.
	local cAlsMaster	:= oSelf:cAlsMaster
	local nRecMaster	:= oSelf:nRecMaster
	local cIdSecao		:= oSelf:cIdSecao
	oZZ9Model:SetOperation(MODEL_OPERATION_INSERT)
	oZZ9Model:Activate()
	oZZ9Model:SetValue(cIDModel,'ZZ9_ALSMST',cAlsMaster)
	oZZ9Model:SetValue(cIDModel,'ZZ9_RECMST',nRecMaster)
	oZZ9Model:SetValue(cIDModel,'ZZ9_ALSDET',cAls)
	oZZ9Model:SetValue(cIDModel,'ZZ9_RECDET',nRec)
	oZZ9Model:SetValue(cIDModel,'ZZ9_STATUS',cNewSts)
	oZZ9Model:SetValue(cIDModel,'ZZ9_SECAO',cIdSecao)
	if ! (lRet := oZZ9Model:VldData())
		aErro := oZZ9Model:GetErrorMessage()
	else
		FWFormCommit(oZZ9Model)
	endIf	
	oZZ9Model:DeActivate()
	FreeObj(oZZ9Model)
return(lRet)


static function updZZ9(cNewSts)
	local oZZ9Model := FWLoadModel('cbcMdlGenStatus')
	local cIDModel	:= 'ZZ9MASTER'
	local aErro		:= {}
	local lRet		:= .F.
	oZZ9Model:SetOperation(MODEL_OPERATION_UPDATE)
	oZZ9Model:Activate()
	oZZ9Model:SetValue(cIDModel,'ZZ9_STATUS',cNewSts)
	if ! (lRet := oZZ9Model:VldData())
		aErro := oZZ9Model:GetErrorMessage()
	else
		FWFormCommit(oZZ9Model)
	endIf	
	oZZ9Model:DeActivate()
	FreeObj(oZZ9Model)
return(lRet)


static function delZZ9()
	local oZZ9Model := FWLoadModel('cbcMdlGenStatus')
	local cIDModel	:= 'ZZ9MASTER'
	local aErro		:= {}
	local lRet		:= .F.
	oZZ9Model:SetOperation(MODEL_OPERATION_DELETE)
	oZZ9Model:Activate()
	if ! (lRet := oZZ9Model:VldData())
		aErro := oZZ9Model:GetErrorMessage()
	else
		FWFormCommit(oZZ9Model)
	endIf	
	oZZ9Model:DeActivate()
	FreeObj(oZZ9Model)
return(lRet)


static function posChv(cAls, nRec, oSelf)
	local oSql 			:= LibSqlObj():newLibSqlObj()
	local nRecZZ9		:= 0
	local lExist		:= .F.
	local cAlsMaster	:= oSelf:cAlsMaster
	local nRecMaster	:= oSelf:nRecMaster

	ZZ9->(DbSelectArea('ZZ9'))
	ZZ9->(DbSetOrder(1))
	if !empty(nRecZZ9 	:= oSql:getFieldValue("ZZ9", "R_E_C_N_O_", "%ZZ9.XFILIAL% " +;
	"AND ZZ9_ALSMST  = '" + cAlsMaster + "' " +;
	"AND ZZ9_RECMST  = " + cValToChar(nRecMaster) +;
	"AND ZZ9_ALSDET  = '" + cAls + "' " +;
	"AND ZZ9_RECDET  = " + cValToChar(nRec)) )
		ZZ9->(DbGoTo(nRecZZ9))
		lExist := .T.
	endif
	FreeObj(oSql)
return(lExist)


/* TEST ZONE */
user function zxCtrStY()
	local oStatus		:= nil
	local aTmpStatus	:= {}
	local aTmpSecao		:= {}
	local cTmpStatus	:= ''
	local aTmpMaster	:= {}
	local cMstTmpAls	:= ''
	local aTmpDetFrmMst	:= {}
	local aTmpAll		:= {}
	local cIdSecao		:= ( Alltrim(RetCodUsr()) + Dtos(Date()) + StrTran(time(), ":", "") )
	local nX			:= 0
	local nY			:= 0
	local aRelac		:= {}
	local aWhreDC		:= {}
	local aWhreZE		:= {}
	oStatus := cbcCtrStatus():newcbcCtrStatus()

	// Definir Alias Master e Recno de Referencia
	oStatus:setMaster('SC5', 242263, cIdSecao) 

	// Adicionar registros detalhes ao registro Master
	oStatus:setStatus('SDC', 455, EMPENHADO)
	oStatus:setStatus('SDC', 456, EMPENHADO)
	oStatus:setStatus('SDC', 457, EMPENHADO)
	oStatus:setStatus('SC9', 455, EMPENHADO)
	oStatus:setStatus('SDC', 458, LIBERADO_SEPARACAO)

	// Busca todos os detais de um status para um master
	/*
	aRet[1][1] = Alias
	aRet[1][2]
	[1] = Recnos para este alias
	[2] = Recnos para este alias
	[3] = Recnos para este alias
	*/
	aTmpStatus := oStatus:getRegEnv(EMPENHADO)
	aTmpStatus := oStatus:getRegEnv(LIBERADO_SEPARACAO)

	// Obter um status individual 
	cTmpStatus := oStatus:getStatus('SDC', 455)

	// Limpar um status individual
	oStatus:clrStatus('SDC', 458)

	// Obtem de forma distinta todas as secoes de um determinado status
	aTmpSecao := oStatus:getSecBySts(EMPENHADO)

	// Realizar a troca de todos os status
	oStatus:chgFromTo(EMPENHADO, LIBERADO_FATURAMENTO)

	// Verificar apos alteração
	aTmpStatus := oStatus:getRegEnv(EMPENHADO)
	aTmpStatus := oStatus:getRegEnv(LIBERADO_FATURAMENTO)


	// Obtem de forma distinta todos os recnos de uma master em um determinado status
	/*
	aRet[1][1] = Alias
	aRet[1][2]
	[1] = Recnos para este alias
	[2] = Recnos para este alias
	[3] = Recnos para este alias
	*/
	aTmpMaster := oStatus:getMstBySts(LIBERADO_FATURAMENTO)

	// Obtem para um master todos os details (parametros default obtem do setmaster())
	oStatus:getDetByMst('SC5', 242263)
	// Obtem pelo setmaster()
	oStatus:getDetByMst()

	// Obter todos master/detail de um status
	/*
	aRet[1] <-- Array de Alias Recno master
	1= Alias Master
	2= Recno Alias Master
	[3] <-- Array de Alias com Array de Recnos do Detail
	1= Alias do Detail
	[2]
	1=Recno Detail
	2=Recno Detaiç
	*/
	aTmpAll := oStatus:getAllFrmSts(LIBERADO_FATURAMENTO)

	// Realizar movimentações a partir de um status
	MsgInfo(oStatus:moveInSts(EMPENHADO, '+') )
	MsgInfo(oStatus:moveInSts(LIBERADO_FATURAMENTO, '-') )
	MsgInfo(oStatus:moveInSts(LIBERADO_EMPENHO, '-') )
	MsgInfo(oStatus:moveInSts(CANCELADO_FATURAMENTO, '+') )

	// Realiza a comparação sinalizada de um determinado status contra o ststua ZZ9 do master
	oStatus:lvlCompare(EMPENHADO, '>')
	oStatus:lvlCompare(LIBERADO_FATURAMENTO, '<=')
	oStatus:lvlCompare(LIBERADO_EMPENHO, '>')

	// Atualização em Grupo, com relacionamento
	aadd(aWhreDC,	{'DC_FILIAL' 	, 'C9_FILIAL'} )
	aadd(aWhreDC,	{'DC_PEDIDO' 	, 'C9_PEDIDO'} )
	aadd(aWhreDC, 	{'DC_ITEM' 		, 'C9_ITEM'})
	aadd(aWhreDC, 	{'DC_SEQ' 		, 'C9_SEQUEN'})
	aadd(aWhreDC, 	{'DC_PRODUTO' 	, 'C9_PRODUTO'})
	aadd(aRelac,{'DETAIL', 'SDC', aWhreDC})

	aadd(aWhreZE,	{'ZE_FILIAL' 	, 'C9_FILIAL'} )
	aadd(aWhreZE,	{'ZE_PEDIDO' 	, 'C9_PEDIDO'} )
	aadd(aWhreZE, 	{'ZE_ITEM' 		, 'C9_ITEM'})
	aadd(aWhreZE, 	{'ZE_SEQUEN' 	, 'C9_SEQUEN'})
	aadd(aRelac,{'DETAIL', 'SZE', aWhreZE})
	oStatus:groupRec({{'ZZ9_NROS', '001'}}, 'DETAIL', 'SC9', 455, aRelac)

	// Obter os recnos de um determinado alias de uma detreminda Ordem Separação
	oStatus:getFrmOs('001', 'DETAIL', 'SC9', 'LF')

	FreeObj(oStatus)
return(nil)


/*
ModelDef / ViewDef
* cbcSeparacao
cbcMdlGenStatus
cbcZBAModel
zMVCMd3


*/