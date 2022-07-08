#include 'protheus.ch'
#include 'parmtype.ch'

static cMasterLck 	:= 'CanLock'
static cGlbName		:= "CBCLOCKS"
static isActive		:=  GetNewPar('ZZ_SEMAPH', .T.)


user function prxCanOp(cIdRot, cExist) 
	local lRet 		:= .F.
	local aGlbPut	:= {}  
	default cIdRot 	:= ''
	default cExist 	:= ''
	if isActive
		bErro		:= ErrorBlock({|oErr| HandleEr(oErr)})
		BEGIN SEQUENCE
			if !empty(cIdRot)
				cIdRot := cIdRot + '_' + RetCodUsr()
				if canUseCode(cExist + '_')
					lRet := putInGlobal(cIdRot)
				endif
			endif
			RECOVER
		END SEQUENCE
		ErrorBlock(bErro)
	else
		lRet := .T.
	endif
return (lRet)


user function prxCanCl(cRot)
	local aLocks	:= {}
	local cSearch	:= cRot + '_' + RetCodUsr()
	local lRet		:= .F.
	local lKeepTry 	:= .T.
	local cCount	:= 0
	if isActive
		bErro		:= ErrorBlock({|oErr| HandleEr(oErr)})
		BEGIN SEQUENCE
			while lKeepTry
				cCount++
				if MayIUseCode(cMasterLck)
					GetGlbVars( cGlbName, @aLocks)
					for nX := 1 to Len(aLocks)
						if (cSearch  $ aLocks[nX])
							aDel(aLocks,nX)
							aSize(aLocks, Len(aLocks)-1)
							lRet := putInGlobal(aLocks)
						endif
					next nX
					Leave1Code(cMasterLck)
					lKeepTry 	:= .F.
					lRet 		:= .T.
				endif
				if cCount > 15
					lKeepTry := MsgYesNo('Não é possivel setar variavel global, deseja encerrar?')
					lRet := .F.
				endif
			enddo
			RECOVER
		END SEQUENCE
		ErrorBlock(bErro)
	else
		lRet := .T.
	endif
return (lRet)


user function prxGetLock()
	local aLocks	:= {}
	local nX		:= 0
	local cMsg		:= ''
	GetGlbVars( cGlbName, @aLocks)
	for nX := 1 to len(aLocks)
		cMsg += ( aLocks[nX] + chr(13) )
	next nX
return(cMsg)


user function prxClear()
	putInGlobal({})
return(nil)


static function putInGlobal(xPutGLb)
	local lKeepTry 	:= .T.
	local lRet		:= .T.
	local cCount	:= 0
	local aLocks	:= {}
	local cTp		:= ValType(xPutGLb)
	bErro		:= ErrorBlock({|oErr| HandleEr(oErr)})
	BEGIN SEQUENCE
		while lKeepTry
			cCount++
			if MayIUseCode(cMasterLck)
				GetGlbVars( cGlbName, @aLocks)
				if cTp == 'C'
					if aScan(aLocks, {|x| x == xPutGLb}) == 0
						aadd(aLocks,xPutGLb )
						PutGlbVars(cGlbName, aLocks)				
					endif
				elseif cTp == 'A'
					PutGlbVars(cGlbName, xPutGLb)
				endif
				Leave1Code(cMasterLck)
				lKeepTry 	:= .F.
				lRet		:= .T.
			endif
			if cCount > 15
				lKeepTry := MsgYesNo('Não é possivel setar variavel global, deseja encerrar?')
				lRet := .F.
			endif
		enddo
		RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
return(lRet)


static function canUseCode(cCode)
	local nX		:= 0
	local lRet 		:= .T.
	local aLocks	:= {}
	default cCode := ''
	GetGlbVars( cGlbName, @aLocks)
	if !empty(cCode)
		for nX := 1 to Len(aLocks)
			lRet := !(cCode  $ aLocks[nX])
		next nX
	endif
return (lRet)


static function HandleEr(oErr)
	Leave1Code(cMasterLck)
	BREAK
return (nil)


/* TEST ZONE */
user function ztstPrx()
	zTstProx('EMP', 'FAT')
	zTstProx('FAT', 'EMP')
return ()


static function zTstProx(cFrm, cTo)
	if U_prxCanOp(cFrm, cTo)
		alert('OK-01')
		if ! U_prxCanOp(cTo, cFrm)
			alert('OK-02')
		else
			alert('RUIM-01')
			U_prxCanCl(cTo)
		endif
		U_prxCanCl(cFrm)
	else
		alert('RUIM-INICIO')
	endif
return()