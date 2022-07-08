#include 'totvs.ch'
#include 'fileio.ch'

#define XML_SAVE_PATH			GetNewPar('ZZ_CTESAVE','\config_cte_xml\xml\inn\')
#define XML_SAVE_PATH_EVENTO	GetNewPar('ZZ_CTEEVEN','\config_cte_xml\xml\eventos\')
#define VER_CTE					GetNewPar('ZZ_VERCTE','1.00')
#define AMB_CTE					GetNewPar('ZZ_AMBCTE','1')
 
class cbcCteConfig
	data cNSUAtual
	data cNSUMax
	data lLastSts
	data cLastStsMsg
	data cSaveEvt
	data cSaveArq
	data cBranch
	data cVerCte
	data cAmbCte
	data lIsExcl
	
	method newcbcCteConfig() constructor
	method isExclusive()
	method release()
	method atualizNSU()
endclass


method newcbcCteConfig(cBranch) class cbcCteConfig
	default cBranch := FwFilial()
	::cBranch 		:= cBranch
	::cNSUMax 		:= GetMV('ZZ_NSUMAX')
	::cNSUAtual		:= GetMV('ZZ_NSUMAX')
	::cLastStsMsg	:= ""
	::lLastSts		:= .T.
	::cSaveArq		:= XML_SAVE_PATH
	::cSaveEvt		:= XML_SAVE_PATH_EVENTO
	::cVerCte		:= VER_CTE
	::cAmbCte		:= AMB_CTE
	::lIsExcl	:= .T.
return(self)

method isExclusive() class cbcCteConfig
	::lIsExcl := LockByName("CBCCTEXML",.F.,.F.,.T.)
	if !::lIsExcl
		::cLastStsMsg	:= "Ambiente Não esta Exclusivo! Rotina Abortada"
	endif
return(self)

method release() class cbcCteConfig
	UnLockByName("CBCCTEXML",.F.,.F.,.T.)
return(self)

method atualizNSU() class cbcCteConfig
	PutMV("ZZ_NSUMAX", ::cNSUAtual)
return(self)

