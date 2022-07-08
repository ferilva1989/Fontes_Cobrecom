#include 'totvs.ch'

#Define linha chr(13)+chr(10)

#define TABELA 			1
#define NRORECNO 			2
#define FAZER   			3
#define USUARIO 			1
#define ROTINA 			2
#define INTER_TAM_ARRAY 	2
#define INTER_USR_ROTINA 	53

static nTryLock := GetNewPar('ZZ_SDCLCKVZ', 3)

class cbcLockCtrl
	
	data lResult
	data aLocks
	data cLockMsg

	method newcbcLockCtrl() constructor

	method setResult()
	method okLock()
	method getErr()
	
	method prepLock()
	method libLock()
	
	method qryToRec()
	method lockFrmQry()
	
endclass


method newcbcLockCtrl() class cbcLockCtrl
	::aLocks 	:= {}
	::setResult()
return(self)


method setResult(lResult, cMsg) class cbcLockCtrl
	default lResult	:= .T.
	default cMsg		:= ''
	::lResult 	:= lResult
	::cLockMsg 	:= cMsg
return(self)


method okLock() class cbcLockCtrl
return(::lResult)


method getErr() class cbcLockCtrl
return(::cLockMsg )


method prepLock(aRecno) class cbcLockCtrl
	local aArea		:= GetArea()
	local nX			:= 0
	local nVez		:= 0
	local lLock		:= .F.
	local nRec		:= 0
	local cTab		:= ''
	default aRecno 	:= {}
	
	::setResult()
	
	for nX := 1 to len(aRecno)
		if aRecno[nX,FAZER]
			cTab := aRecno[nX,TABELA]
			nRec := aRecno[nX,NRORECNO]
			DbSelectArea( cTab )
			while  !(lLock := (cTab)->(DBRLock(nRec)) ) .And. (nVez < nTryLock)
				nVez ++
				sleep(1000)
			enddo
	  		
			if !lLock
				::setResult(.F., getErrMsg(cTab, nRec) )
				return(self)
			else
				aadd(::aLocks, {cTab, nRec})
			endif
		endif
	next nX
	
	restArea(aArea)
return(self)


method libLock(aRecno) class cbcLockCtrl
	local nX 		:= 0
	local nRec		:= 0
	local cTab		:= ''
	local aArea		:= GetArea()
	default aRecno 	:= ::aLocks
	
		// TODO Liberas locks especificos atualizando ::aLocks
	for nX := 1 to len(aRecno)
		cTab := aRecno[nX,TABELA]
		nRec := aRecno[nX,NRORECNO]
		DbSelectArea( cTab )
		
		if InTransact()
			(cTab)->(MsUnlock())
		else
			(cTab)->(DBRUnlock(nRec))
		endif
		
	next nx
	::aLocks := {}
	
	restArea(aArea)
return(self)


static function getErrMsg(cTab, nRec)
	local aUsrRot		:= {}
	local cMsgErr		:= ''
	
	cMsgErr := "[Registro em uso] - Tabela: " + cTab + " Registro: " + cValToChar(nRec)
	if len(aUsrRot := StrToKArr(TCInternal(INTER_USR_ROTINA), '|')) == INTER_TAM_ARRAY
		cMsgErr += " Usuario: " + Alltrim(aUsrRot[USUARIO]) + " Rotina: " + Alltrim(aUsrRot[ROTINA])
	endif
return(cMsgErr)


/*TEST ZONE*/
user function ztsLock()
	local oRec := cbcLockCtrl():newcbcLockCtrl()
	local lOpc	:= .F.
	local nSBFRec := 5382555
	local nSZERec := 498356
	local nSB2Rec := 664
	
	if ! oRec:prepLock({{'SB2', nSB2Rec, .T.}}):okLock()
		MsgAlert( oRec:getErr(),'ERRO' )
	else
		oRec:libLock()
	endif
	
	if ! oRec:prepLock({ {'SBF',nSBFRec, .T.}, {'SB2', nSB2Rec, .T.}, {'SZE', nSZERec, lOpc } }):okLock()
		MsgAlert( oRec:getErr(),'ERRO' )
	else
		// Libera apenas os recnos informados no array
		// oRec:libLock( { {'SBF',nSBFRec} } )
		
		// Libera todos os recnos na propriedade ::aLocks 
		oRec:libLock()
	endif

	oRec:qryToRec()


	FreeObj(oRec)
return(nil)
