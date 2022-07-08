#include 'protheus.ch'

#define FILIAL 01 
#define REC	02
#define NIVEL 03
#define ROTA 04

/*/{Protheus.doc} ctrlMultiPedidos
(long_description)
@author    alexandre.madeira
@since     14/02/2020
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
class ctrlMultiPedidos 
	
	data lShowMsg
	data lOk
	data cMsgErr
	data nRecPed
	data cIdVen
	data aPedTree
		
	method newctrlMultiPedidos() constructor 
	
	method isOk()
	method getErrMsg()
	method getIdVen()
	method getRefPed()
	method getPedTree()
	method getMain()
	method setStatus()
	method setPedido()
	method getMyRoute() 
		
endclass

/*/{Protheus.doc} newctrlMultiPedidos
Metodo construtor
@author    alexandre.madeira
@since     14/02/2020
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
method newctrlMultiPedidos() class ctrlMultiPedidos
	::nRecPed 	:= 0
	::cIdVen 	:= ''
	::aPedTree 	:= {}
	::setStatus()
return(self)

method isOk() class ctrlMultiPedidos
return(::lOk)

method getErrMsg() class ctrlMultiPedidos
return(::cMsgErr)

method getIdVen() class ctrlMultiPedidos
return(::cIdVen)

method getRefPed() class ctrlMultiPedidos
return(::nRecPed)

method getPedTree() class ctrlMultiPedidos
return(::aPedTree)

method getMain() class ctrlMultiPedidos
	local nRec := 0
	
	if !empty(::getPedTree())
		nRec := ::getPedTree()[01, REC]
	endif
return(nRec)

method setStatus(lOk, cMsg, lEx) class ctrlMultiPedidos
	private lException	:= .F.
	
	default lOk			:= .T.
	default cMsg 		:= ''
	default lEx			:= .F.
	
	::lOk				:= lOk
	
	if !lException
		if !lOk
			::cMsgErr	:= "[ctrlMultiPedidos - "+DtoC(Date())+" - "+Time()+" ] " + '[ERRO]' + cMsg
			if ::lShowMsg
				MsgAlert(::cMsgErr, 'Aviso')
			endif
			if lEx
				lException := .T.
				UserException(cMsg)
			endif
		endif
	endif
return(self)

method setPedido(nRec) class ctrlMultiPedidos
	local aArea			:= GetArea()
	local aSC5			:= SC5->(GetArea())
	
	default nRec 		:= 0
	
	if ::setStatus(!empty(nRec),'RECNO do Pedido não informado!'):isOk()
		dbSelectArea('SC5')
		SC5->(DbGoTo(nRec))
		if ::setStatus(!empty(SC5->(C5_X_IDVEN)),'ID de Venda não localizado!'):isOk()
			::nRecPed 	:= nRec
			::cIdVen 	:= SC5->(C5_X_IDVEN)
			::aPedTree 	:= AClone(loadTree(::getIdVen()))
		endif
	endif
	RestArea(aSC5)
	RestArea(aArea)
return(self)

method getMyRoute() class ctrlMultiPedidos
	local aRota		:= {}
	local aRet		:= {}
	local nMyPosi 	:= 0
	local nX		:= 0
	local nPosi		:= 0
	local cRota		:= ''
	
	if (!empty(::getRefPed())) .and. (!empty(::getPedTree()))
		if (nMyPosi := AScan(::getPedTree(),{|a| a[REC] ==  ::getRefPed()})) > 0
			aRota 		:= StrTokArr(::getPedTree()[nMyPosi, ROTA], '-' )		
			for nX := 1 to len(aRota)
				cRota += aRota[nX]
				if (nPosi := AScan(::getPedTree(),{|a| a[ROTA] == cRota .and. a[NIVEL] == StrZero(nX, 3)})) > 0
					aAdd(aRet, Aclone(::getPedTree()[nPosi]))
				endif
				cRota += "-"
			next nX
		endif
	endif
return(aRet)

static function loadTree(cIDVen)
	local aArea		:= GetArea()
	local aSC5		:= SC5->(GetArea())
	local aSA1		:= SA1->(GetArea())
	local aDoWork	:= {}
	local aTree 	:= {}
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local aEmpresas := FWLoadSM0()
	local nX		:= 0
	local nPosi		:= 0
	
	dbSelectArea('SC5')
	dbSelectArea('SA1')
		
	oSql:newAlias(U_qryMainPedido(cIdVen))
	if oSql:hasRecords()
		oSql:goTop()	
		while oSql:notIsEof()
			aAdd(aTree, {oSql:getValue("FILIAL"), oSql:getValue("REC_SC5"), '001', '001'})
			oSql:skip()
		endDo
	endif
	oSql:close()
	if !empty(aTree)		
		oSql:newAlias(u_qryMultiPedidos(cIdVen, aTree[01,REC]))
		if oSql:hasRecords()
			oSql:goTop()	
			while oSql:notIsEof()
				aAdd(aDoWork, {oSql:getValue("FILIAL"), oSql:getValue("REC_SC5"), oSql:getValue("REC_SA1"), ''})
				oSql:skip()
			endDo
		endif
		oSql:close()
		for nX := 1 to len(aDoWork)
			SA1->(DbGoTo(aDoWork[nX,03]))
			if (nPosi := AScan(aEmpresas,{|a| a[18] == SA1->A1_CGC })) > 0
				aDoWork[nX, 04] := aEmpresas[nPosi, 05]
			endif
		next nX
		//NIVEis	
		orderNivel(@aTree, @aDoWork)
	endif
	FreeObj(oSql)
	RestArea(aSC5)
	RestArea(aSA1)
	RestArea(aArea)
return(aTree)

static function orderNivel(aTree, aDoWork)
	local nPosiTree		:= 0
	
	while !empty(aDoWork)
		nPosiTree++
		recNivel(nPosiTree, @aTree, @aDoWork)
	endDo

return(aTree)

static function recNivel(nPosiTree, aTree, aDoWork)
	local nX			:= 0
	local nPosi			:= 0
	local cRota			:= '001'
	local aDelLin  		:= {}
	
	for nX := 1 to len(aDoWork)
		if aDoWork[nX, 04] == aTree[nPosiTree, FILIAL]
			aAdd(aTree, {aDoWork[nX, 01], aDoWork[nX, 02], Soma1(aTree[nPosiTree, NIVEL]), aTree[nPosiTree, ROTA] + '-' + cRota})
			cRota := Soma1(cRota)
			aAdd(aDelLin, aDoWork[nX, 02])
		endif
	next nX
	
	for nX := 1 to len(aDelLin) 
		if (nPosi := AScan(aDoWork,{|a| a[02] == aDelLin[nX] })) > 0
			aDel(aDoWork, nPosi)
			aSize(aDoWork, (len(aDoWork)-1))
		endif		
	next nX
return(aTree)

static function errHandle(oErr, oSelf)
	oSelf:setStatus(.F., oErr:Description, .T.) 
		
	if InTransact()
		DisarmTransaction()
	endif
	
	BREAK
return(nil)

user function tstctrlMultiPedidos(nRec) //tstctrlMultiPedidos(278548)
	local oMulti := ctrlMultiPedidos():newctrlMultiPedidos()
	local aArr	 := {}
	
	oMulti:setPedido(nRec)
	
	aArr := oMulti:getMyRoute()
	
	Alert(cValToChar(oMulti:getMain()))
return(nil)