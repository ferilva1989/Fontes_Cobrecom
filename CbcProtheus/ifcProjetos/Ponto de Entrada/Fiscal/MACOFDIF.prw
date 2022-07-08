#include 'protheus.ch'
#include 'parmtype.ch'

user function MACOFDIF()
	local cbcArea	:= GetArea()
	local nItem		:= PARAMIXB[1] //Item atual do processo
	local nAliCof	:= PARAMIXB[2] //Alíquota do Cofins de Apuração
	local sUsaAlq	:= "N"                   
	local sTes		:= MaFisRet(nItem,"IT_TES") 
	local nCbcCof	:= GetNewPar("ZZ_ALIMCOF",9.65)
	local cTesImp	:= ""
	
	cTesImp		:= Posicione("SF4", 1 ,xFilial("SF4") + Padr(sTes, TamSx3('F4_CODIGO')[1] ),"F4_INTBSIC")
	//cTesImp 0=Não Calcula; 1=PIS Import; 2=Cofins Import; 3=Ambos
	if (cTesImp == "2" .or. cTesImp == "3") .and. nAliCof > 0
		sUsaAlq	:= "S"
		nAliCof	:= nCbcCof
	endif
	RestArea(cbcArea)
return {sUsaAlq,nAliCof}