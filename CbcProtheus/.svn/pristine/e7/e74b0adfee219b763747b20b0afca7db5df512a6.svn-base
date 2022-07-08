#include 'protheus.ch'
#include 'parmtype.ch'

static function procDeduct(oSqlBrw, cMark)
	local oSql 			:= LibSqlObj():newLibSqlObj()
	local lRet			:= .T.
	local nRecB7		:= 0
	local cDtInventory 	:= setDtProc()
	local bErro			:= ErrorBlock({|oErr| HandleEr(oErr, @lRet)})
	Local oStatic    	:= IfcXFun():newIfcXFun()
	
	if !empty(cDtInventory)		
		BEGIN SEQUENCE
			if hasProc(cDtInventory)
				if (lRet := MsgYesNo('Processamento anterior localizado! Rotina irá desfazer este processamento, confirma?','Confirmar'))
					lRet := fallBack(cDtInventory)
				endif
			endif
			if lRet
				oSql:newAlias(oStatic:sP(2):callStatic('qryInventory', 'qryDeduct', oSqlBrw, cMark))
				if oSql:hasRecords()
					oSql:goTop()
					BEGIN TRANSACTION				
						while oSql:notIsEof()
							if(empty(nRecB7 := getSB7Rec( cDtInventory, oSql:getValue('COD'), oSql:getValue('LOCAL'), oSql:getValue('ACOND') )))
								lRet := .F.
								EXIT
							endif
							if !(lRet := updTabInventory( nRecB7, oSql:getValue('QTDE') ))
								EXIT
							endif
							oSql:skip()
						endDo
						if !lRet
							DisarmTransaction()				
						endif
					END TRANSACTION
				endif
				oSql:close()
			endif
			if !lRet
				MsgAlert('Processamento não encontrou problema. Nenhuma aletração foi exexutada!','Erro no Processamento')
			else
				MsgInfo('Processado com sucesso!','Sucesso')
			endif
			RECOVER
		END SEQUENCE
	endif
	FreeObj(oSql)
return(lRet)

static function setDtProc()
	local cDtRet := ''
	
	if MsgYesNo('Confirma data do Inventário em: ' + DTOC(dDataBase), 'Data do Inventário')
		cDtRet := DTOS(dDataBase)
	else
		msgAlert('A data base do sistema deve ser a mesma do Inventário!','Data Base Inválida')
	endif	
return(cDtRet)

static function hasProc(cDtInventory)
	local oSql		:= LibSqlObj():newLibSqlObj()
	local lHas		:= .T.
	Local oStatic   := IfcXFun():newIfcXFun()
	
	oSql:newAlias(oStatic:sP(1):callStatic('qryInventory', 'qryFallBack', cDtInventory))
	lHas := oSql:hasRecords()	
	oSql:close()
	FreeObj(oSql)
return(lHas)

static function fallBack(cDtInventory)
	local oSql		:= LibSqlObj():newLibSqlObj()
	local aFldVlr	:= {}
	local nRec		:= 0
	local nQtde		:= 0
	local lRet		:= .T.
	Local oStatic   := IfcXFun():newIfcXFun()
	
	oSql:newAlias(oStatic:sP(1):callStatic('qryInventory', 'qryFallBack', cDtInventory))
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			aFldVlr := {}
			nRec 	:= oSql:getValue('REC')
			nQtde 	:= oSql:getValue('QTD') + oSql:getValue('DEBITA')
			aadd(aFldVlr, {'B7_QUANT'	, nQtde })
			aadd(aFldVlr, {'B7_ZDEBITA'	, 0 	})
			if !(lRet:= execModel( nRec, aFldVlr ))
				EXIT
			endif
			oSql:skip()
		endDo
	endif
	oSql:close()
	FreeObj(oSql)
return(lRet)

static function getSB7Rec(cDtInventory, cCod, cLocal, cAcond)
	local nRec		:= 0
	local oSql		:= LibSqlObj():newLibSqlObj()
	Local oStatic   := IfcXFun():newIfcXFun()
	
	oSql:newAlias(oStatic:sP(4):callStatic('qryInventory', 'qryRecTab', cDtInventory, cCod, cLocal, cAcond))
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			nRec := oSql:getValue('REC')
			oSql:skip()
		endDo
	endif
	oSql:close()
	FreeObj(oSql)
return(nRec)

static function updTabInventory( nRecB7, nQtde )
	local aArea			:= getArea()
	local aAreaSB7		:= SB7->(getArea())
	local lRet 			:= .T.
	local aFldVlr		:= {}
	local nQtdUpd		:= 0
	
	dbSelectArea('SB7')
	SB7->(DbGoTo(nRecB7))
	nQtdUpd := (SB7->B7_QUANT - nQtde)
	aadd(aFldVlr, {'B7_QUANT'	, nQtdUpd })
	aadd(aFldVlr, {'B7_ZDEBITA'	, nQtde	  })
	lRet := execModel( nRecB7, aFldVlr )

	RestArea(aAreaSB7)
	RestArea(aArea)
return(lRet)

static function execModel( nRecB7, aFldVlr )
	local aArea			:= getArea()
	local aAreaSB7		:= SB7->(getArea())
	local ocbcMdlCtrl	:= nil
	local oSB7Model		:= nil
	local aErr			:= {}
	local cErro			:= ''
	local lRet			:= .T.
	
	default aFldVlr 	:= {}
	default nRecB7		:= 0
	
	if !empty(aFldVlr) .and. !empty(nRecB7)
		dbSelectArea('SB7')
		SB7->(DbGoTo(nRecB7))
		ocbcMdlCtrl := cbcMdlCtrl():newcbcMdlCtrl()
		ocbcMdlCtrl:setInitSet('SB7MASTER', 'cbcSB7Model', 'SB7')
		oSB7Model 	:= ocbcMdlCtrl:getNewModel('UPDATE')
		ocbcMdlCtrl:setVlrModel(oSB7Model,aFldVlr)
		if ! ocbcMdlCtrl:SaveAModel(oSB7Model):isOk()
			aErr := ocbcMdlCtrl:getErro()
			cErro += aErr[2] + '-'
			cErro += aErr[4] + '-'
			cErro += aErr[5] + '-'
			cErro += aErr[6] 
			Help( ,, cErro ,, 'Erro', 1,0)
			lRet := .F.
		endif
	endif	
	FreeObj(ocbcMdlCtrl)
	FreeObj(oSB7Model)
	RestArea(aAreaSB7)
	RestArea(aArea)
return(lRet)

static function HandleEr(oErr, lRet)
	local cErro	:=  "[CBC-INVENTORY - "+DtoC(Date())+" - "+Time()+" ] "+ '[ERRO]' + oErr:Description + ' [FROM] ' + ProcName(3)
	if (InTransaction())
		DisarmTransaction()
	endif
	lRet := .F.
	ConOut(cErro)
	BREAK
return(nil)
