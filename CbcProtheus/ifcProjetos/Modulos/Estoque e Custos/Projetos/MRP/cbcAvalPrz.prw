#include "TOTVS.CH"

user function cbcAvalPrz(cFili, cProd, cCli, cLoja, lVarejo, nPrazo)
    local dEntrega	:= Date()
	local nX		:= 0
	default cFili	:= FwFilial()
	default cProd 	:= ""
	default cCli  	:= ""
	default cLoja 	:= ""
	default lVarejo := .F.
	default nPrazo	:= 0

	if (nPrazo := przCliente(cCli, cLoja)) == 0
		if (nPrazo := przVarejo(lVarejo)) == 0
			nPrazo := przProduto(cFili, cProd)
		endif
	endif
	
	for nX := 1 to nPrazo
		dEntrega := DataValida(++dEntrega)
	next nX
	dEntrega := U_DataIFC(Date(),dEntrega)

return(dEntrega)

static function przCliente(cCli, cLoja)
	local nPrzCli := 0
	if !empty(cCli) .and. !empty(cLoja)
		DbSelectArea("SA1")
		nPrzCli := Posicione("SA1",1,xFilial("SA1")+Padr(cCli, TamSX3("A1_COD")[1])+Padr(cLoja,TamSX3("A1_LOJA")[1]),"A1_PRZENTR")
	endif
return(nPrzCli)

static function przVarejo(lVarejo)
	local nPrzVar	:= 0
	if lVarejo
		nPrzVar := U_dtEntrVar()
	endif
return(nPrzVar)

static function przProduto(cFili, cProd)
	local nPrzProd	:= 0
	if !empty(cProd)
		nPrzProd := CalcPrazo(cProd,0,,,.T.,Date())
		nPrzProd += calcTrfPrz(cFili, cProd)
	endif
return(nPrzProd)

static function calcTrfPrz(cFili, cProd)
	local nPrzTrf	:= 0
	local nPrzAdd	:= GetNewPar('ZZ_PRZADDT', 2)
	local nX		:= 0
	local aFilis	:= {}

	if !u_FilialFaz(cFili, cProd)
		aFilis := Separa(AllTrim(GetNewPar('ZZ_TFILDIV','',cFili)),";",.F.)
		for nX := 1 to len(aFilis)
			if u_FilialFaz(aFilis[nX], cProd)
				nPrzTrf := nPrzAdd
				EXIT
			else
				nPrzTrf := calcTrfPrz(aFilis[nX], cProd)
				if nPrzTrf > 0
					nPrzTrf += nPrzAdd
					EXIT
				endif
			endif
		next nX
	endif
return(nPrzTrf)
