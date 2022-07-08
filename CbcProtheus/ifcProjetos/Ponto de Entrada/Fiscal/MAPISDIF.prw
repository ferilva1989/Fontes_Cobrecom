#include 'protheus.ch'
#include 'parmtype.ch'

user function MAPISDIF()
	local cbcArea	:= GetArea()
	local nItem		:= PARAMIXB[1] //Item atual do processo
	local nAliPIS	:= PARAMIXB[2] //Alíquota do Cofins de Apuração
	local sUsaAlq	:= "N"                   
	local sTes		:= MaFisRet(nItem,"IT_TES") 
	local nCbcCof	:= GetNewPar("ZZ_ALIMPIS",2.1)
	local cTesImp	:= ""
	
	cTesImp		:= Posicione("SF4", 1 ,xFilial("SF4") + Padr(sTes, TamSx3('F4_CODIGO')[1] ),"F4_INTBSIC")
	//cTesImp 0=Não Calcula; 1=PIS Import; 2=Cofins Import; 3=Ambos
	if (cTesImp == "1" .or. cTesImp == "3") .and. nAliPIS > 0
		sUsaAlq	:= "S"
		nAliPIS	:= nCbcCof
	endif
	RestArea(cbcArea)
return {sUsaAlq,nAliPIS} 