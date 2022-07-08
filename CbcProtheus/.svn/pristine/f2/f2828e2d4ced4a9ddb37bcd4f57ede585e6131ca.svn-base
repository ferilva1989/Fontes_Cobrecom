#Include 'Protheus.ch'

static aAcond := StrTokArr(getNewPar('ZZ_CBCACON', 'L;R;C;M;B'), ';' )


class cbcJsFld
	data oObj
	
	method newcbcJsFld() constructor
	method objFromMemo()
	method addMemo()
	method remMemo()
	method isCurve()
	
endclass


method newcbcJsFld() Class cbcJsFld
return(self)


method objFromMemo(aItm, oMDl) Class cbcJsFld
	local oJson		:= jsonTypes():newjsonTypes()
	local cMemo		:= oMdl:GetValue('ZZZ_JSFLD')
	if empty(cMemo)
		cMemo 	:= '{ "aItm":[] }'
	endif
	::oObj	:= oJson:fromJson(cMemo)
	aItm := ::oObj:aItm
	
	ordena(@aItm)
	
	FreeObj(oJson)
return(self)


method addMemo(aItm, oMdl) Class cbcJsFld
	local nPos		:= 0
	local cNewValue	:= ''
	local cNewMemo	:= ''
	
	if ! empty( cNewValue := obterValue() )
		if ( nPos := AScan(aItm ,{|a| lower(Alltrim(a)) == lower(Alltrim(cNewValue))}) == 0 )
			aadd(aItm, cNewValue)
			resolvMemo(Self, oMdl, aItm)
		endif
	endif
return(self)


method remMemo(aItm,oLstBox, oMdl) class cbcJsFld
	local nPos 		:= 0
	local nNovo		:= 0
	local cItem		:= oLstBox:GetSelText()
	local nNovo		:= (len(aItm) - 1)
	
	if MsgNoYes('Deseja excluir o item: ' + cItem )
		if (nPos := AScan(aItm,{|a| Alltrim(a) == Alltrim(cItem) })) > 0
			Adel(aItm,nPos )
			ASize(aItm, nNovo)
			oLstBox:Select(nNovo)
			resolvMemo(Self, oMdl, aItm)
		endIf
	endif
return(self)


method isCurve(cProd, cAcondMtr, nRecZZZ) class cbcJsFld
	local lRet		:= .F.
	local oMemo 		:= nil
	local oJson		:= nil
	local oSql 		:= nil
	local oCurva		:= nil 
	local cJsString	:= ''
	local nPos		:= 0
	default cProd		:= ''
	default cAcondMtr	:= ''
	default nRecZZZ	:= 0
	
	if ( empty(nRecZZZ) .and. ( ! empty(cProd) .and. ! empty(cAcondMtr) ) )
		oSql := LibSqlObj():newLibSqlObj()
		nRecZZZ 	:= oSql:getFieldValue("ZZZ", "R_E_C_N_O_",;
		"%ZZZ.XFILIAL% AND ZZZ_TIPO = 'CUR' AND ZZZ_CODPRO ='" + cProd + "'")
		FreeObj(oSql)
	endif

	if ! empty(nRecZZZ)
		oMemo := ManBaseDados():newManBaseDados()
		cJsString := oMemo:getMemo('ZZZ', 'ZZZ_JSFLD', nRecZZZ, .T. )
		if oMemo:getOk()
			oJson := jsonTypes():newjsonTypes()
				oCurva := oJson:fromJson(cJsString)
				lRet := ((AScan(oCurva:aItm,{|a| Alltrim(a) == Alltrim(cAcondMtr) })) > 0)
			
			FreeObj(oJson)
			FreeObj(oCurva)
		else
			oMemo:getMsgErro()
		endif
		FreeObj(oMemo)
	endif
return(lRet)


static function resolvMemo(oSelf, oMdl, aItm)
	local cNewMemo := ''
	local oJson		:= jsonTypes():newjsonTypes()
	local cMemo		:= oMdl:GetValue('ZZZ_JSFLD')
	
	if empty(cMemo)
		cMemo 	:= '{ "aItm":[] }'
	endif
	ordena(@aItm)
	
	oSelf:oObj	:= oJson:fromJson(cMemo)
	oSelf:oObj:aItm := aItm
	cNewMemo := oJson:toJson(oSelf:oObj, .F.)
	oMdl:loadValue('ZZZ_JSFLD',cNewMemo)
	
	FreeObj(oJson)
return(nil)


static function obterValue()
	local cNewValue	:= ''
	local aParamBox	:= {}
	local aRet		:= {}
	
	aAdd(aParamBox,{2,"Acondicionamento",'R',aAcond,40,"",.T.})
	aAdd(aParamBox,{1,"Metragem"  ,Space(5),"","","","",5,.T.})
	
	if ParamBox(aParamBox,"Adicionar...",@aRet)
		cNewValue := Alltrim(aRet[1]) + StrZero(Val(aRet[2]),5)
	endif
return(cNewValue)


static function ordena(aItm)
	default aItm := {}
	if !empty(aItm)
		ASort(aItm,,,{|x,y|  x >  y })
	endif
return(nil)


/* TESTE ZONE */
user function zCadCur()
local oCurva := cbcJsFld():newcbcJsFld()

	oCurva:isCurve('1150507401', 'M01000')
	// oCurva:(,, nRecZZZ)

FreeObj(oCurva)

return(nil)

