#include 'protheus.ch'
#include 'parmtype.ch'
/*
	u_cbcChngFil('SZE', 663244, '03', {{'ZE_PEDIDO', '000702'}, {'ZE_NOME', 'AUTOTRANS'}}, 1)
*/
user function cbcChngFil(cTabelaAux, cRecTAux, cFilNovAux, aFldNwVal, xOrd)
	local aArea     	:= GetArea()
	local aEstru    	:= {}
	local aConteu   	:= {}
	local nPosFil   	:= 0
	local cCampoFil 	:= ""
	local cQryAux   	:= ""
	local nAtual    	:= 0
	local aNewValue		:= {}
	local lRecOpc		:= .T.
	default aFldNwVal	:= {} 
	default xOrd		:= 1

	DbSelectArea(cTabelaAux)
	(cTabelaAux)->(DbSetOrder(xOrd))

	// Pega a estrutura da tabela
	aEstru := (cTabelaAux)->(DbStruct())

	// Encontra o campo filial
	nPosFil   := aScan(aEstru, {|x| "FILIAL" $ AllTrim(Upper(x[1]))})
	cCampoFil := aEstru[nPosFil][1]

	// Posiciona nesse recno
	(cTabelaAux)->(DbGoTo(cRecTAux))

	// Percorre a estrutura
	ProcRegua(Len(aEstru))
	for nAtual := 1 to len(aEstru)
		// Se for campo filial
		if Alltrim(aEstru[nAtual][1]) == Alltrim(cCampoFil)
			aadd(aConteu, cFilNovAux)

		//(Campos que mudam na copia)
		elseIf (aNewValue := srchValue(aFldNwVal, Alltrim(aEstru[nAtual][1])))[1] > 0    
			aadd(aConteu, aNewValue[2])
		//Se não, adiciona
		else
			aadd(aConteu, &(cTabelaAux+"->"+aEstru[nAtual][1]))
		endIf
	next

	// Busca registro filial destino (incluir ou atualizar)
	lRecOpc := isInsert(cTabelaAux, cCampoFil, cFilNovAux)
	// Faz um RecLock
	RecLock(cTabelaAux, lRecOpc)
	// Percorre a estrutura
	for nAtual := 1 to len(aEstru)
		// Grava o novo valor
		&(aEstru[nAtual][1]) := aConteu[nAtual]
	next
	(cTabelaAux)->(MsUnlock())
	RestArea(aArea)

return(nil)


static function srchValue(aFldNwVal, cFld)
	local cValue := ''
	local nPos	 := 0
	if (nPos := AScan(aFldNwVal,{|a| a[1] == cFld })) > 0
		cValue := aFldNwVal[nPos][2]
	endif
return({nPos,cValue})


static function isInsert(cTab, cCampoFil, cNewFil)
	local lInsert 	:= .T.
	local aToke		:= {}
	local cChave	:= ''
	local nX		:= 0
	local cCont		:= '' 
	
	aToke := StrToKArr(OrdKey(), '+')
	for nX := 1 to len(aToke)
		if aToke[nX] == cCampoFil
			cChave += cNewFil
		else
			cCont := aToke[nX]
			cChave += (cTab)->(&cCont)
		endif
	next nX
	if !empty(cChave)
		if (cTab)->(DbSeek(cChave, .T.))
			lInsert := .F.
		else
			lInsert := .T.
		endif
	endif
return(lInsert)
