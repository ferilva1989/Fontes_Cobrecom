#include 'protheus.ch'


class cbcImpService
	method newcbcImpService() constructor 

	method putPvpPed()
	method putPvpOrc()
endclass

method newcbcImpService() class cbcImpService
return (self)

method putPvpPed(aHeader,aCols) class cbcImpService
	local nX 		:= 0
	for nX := 1 to Len(aCols)
		if !GDDeleted(nX)
			if Empty( GDFieldGet("C6_XFTPVC",nX) )
				GDFieldPut("C6_XFTPVC", getValPvc( GDFieldGet("C6_PRODUTO",nX) ) ,nX)
			endif
		endif
	next nX
return (self)

method putPvpOrc() class cbcImpService
local oArea := nil 
	oArea := SigaArea():newSigaArea()
	oArea:saveArea( {'TMP1'} )	
	
	DbSelectArea("TMP1")
	TMP1->(DbGoTop())
	while !Eof()
		if !TMP1->(CK_FLAG)
			if empty(TMP1->(CK_XFTPVC))
				RecLock("TMP1", .F. )
					TMP1->(CK_XFTPVC) := getValPvc( TMP1->(CK_PRODUTO) )
				TMP1->(MsUnLock())
			endif
		endif
		TMP1->(DbSkip())
	EndDo
	oArea:backArea()
	
	freeObj(oArea)
return (self)

static function getValPvc(cCodProd)
	local nRet	:= 0
	nRet := Posicione("SB1", 1 ,xFilial("SB1") + Padr(cCodProd, TamSx3('B1_COD')[1] ),"B1_VALPVC")
return(nRet)