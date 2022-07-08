#include 'totvs.ch'

static nTry	:= GetNewPar('ZZ_TRYSEQ', 5)

/*/{Protheus.doc} cbcCtrlSeq
(long_description)
@type class
@author bolognesi
@since 21/03/2018
@description Classe para controle de numero sequencial
/*/
class cbcCtrlSeq
	data lOk
	data cMsgErr
	data aNext
	data xLast
	
	method newcbcCtrlSeq() constructor
	method getNext()
	method commit()
endclass


method newcbcCtrlSeq() class cbcCtrlSeq
	::lOk		:= .T.
	::cMsgErr	:= ''
	::aNext 	:= {}
return(self)


method getNext(cTabela, cCampo, cWhere) class cbcCtrlSeq
	local xTmpNext		:= ''
	local oSql   	 		:= nil
	local bErro			:= nil
	
	::xLast 				:= ''
	default cTabela		:= ''
	default cCampo 		:= ''
	default cWhere 		:= ''
	
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, Self)})
	
	if ! empty(cTabela) .and. ! empty(cCampo)

		BEGIN SEQUENCE
			oSql := LibSqlObj():newLibSqlObj()
			if   ! canUse( oSql:getNextTableCode(cTabela, cCampo, cWhere),self )
				UserException('[cbcCtrlSeq] - Sequencial não disponvel !')
			endif
		RECOVER
		END SEQUENCE
		ErrorBlock(bErro)
		
		FreeObj(oSql)
	endif
return(::xLast)


method commit() class cbcCtrlSeq
	local nX := 0
	for nX := 1 to len(::aNext)
		UnLockByName('CBCCTRLSQE'+ ::aNext[nX],.F.,.F. )
	next nX
	::aNext := {}
return(self)


static function canUse(xNext, oSelf)
	local xVldNext 	:= ''
	local nX 		:= 0
	for nX := 1 to nTry
		if !LockByName('CBCCTRLSQE'+ xNext,.F.,.F. )
			xNext := soma1(xNext)
		else
			aadd(oSelf:aNext,xNext)
			oSelf:xLast := xNext
			return(.T.)
		endif
	next nX
return(.F.)


static function HandleEr(oErr, oSelf)
	oSelf:lOk		:= .F.
	oSelf:cMsgErr		:= "[cbcCtrlSeq - "+DtoC(Date())+" - "+Time()+" ] "+ '[ERRO]' + oErr:Description + ' [FROM] ' + ProcName(3)
	BREAK
return(nil)



/* TEST ZONE COMO OBTER NUMERO SEQUENCIAL */
user function zCtrlSeq()
	local oSeq		:= nil
	local cProx1		:= ''
	local cProx2		:= ''
	local cProx3		:= ''
	
	// Ultimo registro gravado E1_ZZBOR1 = '902665'
	
	oSeq := cbcCtrlSeq():newcbcCtrlSeq()
	
	// Retornou "902666" como proximo mas não utilizou commit(), neste caso "902666" fica reservado pelo LockByName
	cProx1 := oSeq:getNext("SE1", "E1_ZZBOR1", " SUBSTRING(E1_ZZBOR1,1,1) = '9' AND %SE1.NOTDEL% ")
	
	// Verificar erros
	if ! oSeq:lOk
		oSeq:cMsgErr
	endif
	
	// Liberar os locks
	oSeq:commit()
	
	FreeObj(oSeq)
	
return(nil)