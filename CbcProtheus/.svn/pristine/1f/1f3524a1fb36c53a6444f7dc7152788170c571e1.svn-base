#include 'protheus.ch'
#include 'parmtype.ch'

user function FilialFaz(xFilial, cProd)
	local lDo	:= .F.
	
	default xFilial := ''
	default cProd	:= ''
	
	if (!empty(xFilial)) .and. (!empty((cProd)))
		lDo := (aScan( u_OndeProduz(cProd) , xFilial ) > 0)
	endif
return(lDo)

user function OndeProduz(cProd)
	local aFiliais 	:= {}
	local cOpc		:= ''
	
	default cProd	:= ''
	
	if !empty(cProd)
		cOpc := U_fWhereMn(cProd)
		if cOpc == '1'
			aAdd(aFiliais, '01')
		elseif cOpc == '2'
			aAdd(aFiliais, '02')
		else
			aAdd(aFiliais, '01')
			aAdd(aFiliais, '02')
		endif
	endif
return(aFiliais)

user function cbcProcTriangle(aRecsC5)
	local nX 		:= 0
	local oTriang 	:= ctrlTriangle():newctrlTriangle()
	default aRecsC5	:= {}
	
	for nX := 1 to len(aRecsC5)
		oTriang:setDivPed(aRecsC5[nX])
		FWMsgRun(, 	{|| oTriang:genPedDiv()}, "Realizar Triagulação", "Processando..."	)
	next nX
return(nil)

user function cbcResidTriangle(nRecC5)
	local oTriang 	:= ctrlTriangle():newctrlTriangle(, .T.)
	
	default nRecC5	:= 0

	oTriang:setDivPed(nRecC5)
	FWMsgRun(, 	{|| oTriang:eliminaResiduo()}, "Eliminar Resíduo", "Processando..."	)
return(nil)

user function zTriangLocks(lLock, cIdVen, oRec)
	local lRet		:= .T.
	local oHash		:= HMNew()
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local aValues	:= {}
	local nX		:= 0
	local cAls		:= ''
	local nRecno	:= 0
	
	default oRec 	:= cbcLockCtrl():newcbcLockCtrl()	
	default cIdVen	:= ''
	default lLock	:= .F.
	
	if lLock
		oSql:newAlias(u_qryLockTriangle(cIdVen))
		if oSql:hasRecords()
			oSql:goTop()
			while oSql:notIsEof()
				aValues := {}
				aadd(aValues, {"SC5", oSql:getValue("RECSC5")})
				aadd(aValues, {"SC6", oSql:getValue("RECSC6")})
				aadd(aValues, {"SC9", oSql:getValue("RECSC9")})
				aadd(aValues, {"SDC", oSql:getValue("RECSDC")})
				if !( lRet := addInHash(aValues, @oHash))
					EXIT
				endif
				oSql:skip()
			endDo
		endif	
		oSql:close()
		FreeObj(oSql)	
				
		if lRet
			aValues	:= {}
			if ( HMList( oHash, @aValues ) )	
				ASort(aValues, , , {|x,y| Alltrim(x[2,1,2,2]) > Alltrim(y[2,1,2,2]) } )
				for nX := 1 to len(aValues)
					cAls	:= aValues[nX,2,1,2,1]
					nRecno  := aValues[nX,2,1,2,2]					
					if !(lRet := oRec:prepLock({{cAls, nRecno, .T.}}):okLock())
						EXIT
					endif
				next nX
			endif		
		endif
	else
		oRec:libLock()
	endif
return(lRet)


static function addInHash(aValues, oHash)
	local nX		:= 0
	local xValue	:= {}
	local lRet		:= .T.
	local cKey		:= ''
	local aValue	:= {}
	
	default oHash	:= HMNew()
	default aValues	:= {}
			
	for nX := 1 to len(aValues)
		cKey := aValues[nX, 1] + cValToChar(aValues[nX, 2])
		aValue	:= {aValues[nX, 1], aValues[nX, 2]}
		if !(HMGet( oHash , cKey , @xValue ))
			if!(lRet := HMAdd( oHash, {cKey , aValue} ))
				EXIT
			endif
		endif
	next nX
return(lRet)

user function cbcTriangResiduo(nRecC5)
	local oTriang 	:= ctrlTriangle():newctrlTriangle(nRecC5)
	
	u_zTriangLocks(.T., cIdVen)
return(nil)

/* TEST ZONE */
user function tstsrvTriangle(cCod) //tstsrvTriangle('1010401101')
	local lRet := .T.
	
	if u_FilialFaz('01', cCod)
		alert('Produz Itú')
	endif
	
	if u_FilialFaz('02', cCod)
		alert('Produz TL')
	endif
	
	if u_FilialFaz('03', cCod)
		alert('Produz MG')
	endif
	
	alert('FIM')
	
return(lRet)