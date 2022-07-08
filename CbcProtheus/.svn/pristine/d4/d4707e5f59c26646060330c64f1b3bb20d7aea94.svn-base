#include 'protheus.ch'
#include 'parmtype.ch'
#define linha chr(10) + chr(13)

user function zOnNew(cCodCli, cLojaCli, cCodProd, Acond, nQtd, nPrcSug,nRgDes,cFrete,cCond )

	Local oProd 	:= cbcProductValues():newcbcProductValues(cCodCli, cLojaCli, cCodProd, Acond, nQtd,nPrcSug)	
	Local cMostra	:= ""
	Local oDesc		:= Nil
	Default nRgDes := ""
	/*AVISTA*/
	oProd:setPayTerm(cCond)
	/*OUTROS*/
	//oProd:setPayTerm('025')
	oProd:setTpFreight(cFrete)
	//oProd:setTpFreight('F')
	oProd:setRetail(.F.)
	oProd:initCalc()
	
	if !oProd:lOk
		Help(" ",1, "ERR_PORTAL",, oProd:cMsg,3,1)
	Else
		cMostra += "TABELA DE PREÇO:..............." + oProd:cPriceTable   				+ linha
		cMostra += "TABELA PREÇO VALIDA:..........." + if(oProd:isVldPriceTab(),'SIM','NÃO')   + linha
		cMostra += "CUSTO DO PRODUTO:............." + cValToChar(oProd:nCostProduct) 	+ linha
		cMostra += "QUANTIDADE VENDIDA............" + cValToChar(nQtd)					+ linha
		cMostra += linha

		cMostra += "PREÇO DE TABELA:..............." + cValToChar(oProd:nPrice)   	+ linha
		cMostra += "RG TABELA:......................"+ cValToChar(oProd:nStdRg)   	+ linha
		cMostra += linha

		cMostra += "PREÇO DE VENDA:..............." + cValToChar(oProd:getPrcSug()) + linha
		cMostra += "RG VENDA:......................"+ cValToChar(oProd:nCalcRg)   	+ linha
		cMostra += linha

		cMostra += "PREÇO MINIMO:.............." 	+ cValToChar(oProd:nMinPrice)  + linha
		cMostra += "RG PREÇO MINIMO:..........." 	+ cValToChar(oProd:nMinRg)  + linha
		cMostra += linha

		cMostra += "DESC. ( VENDA X TABELA ):..." + oProd:cCalcDiscRange   		+ linha
		cMostra += "DESC. PADRÂO:..............." + oProd:cStdDiscRange   		+ linha
		cMostra += "DESC. APLICADO PRC. MINIMO:............." + oProd:cActDiscRange   		+ linha
		cMostra += linha

		cMostra += "% COMISSÂO:...................." + cValToChar(oProd:nCommission)+ linha
		cMostra += linha
		cMostra += linha

		If !Empty(nRgDes)
			cMostra += "PREÇO PARA RG DE " + cValToChar(nRgDes) + '%    R$' + cValToChar(oProd:getPrcFrmRG(nRgDes)) + linha
			//cMostra += "PREÇO DO RG MINIMO:..........." + cValToChar(oProd:getPrcFrmRG(oProd:nMinRg)) + linha
			//cMostra += "PREÇO DO RG VENDA:......................"+ cValToChar(oProd:getPrcFrmRG(oProd:nCalcRg)) + linha
		EndIf
		//oProd:getPrcFrmRG(nRg, nQtdVen, cCodPro)

	EndIf

return cMostra


//--------------------------------------------------------------
/*/{Protheus.doc} MyFunction
Description                                                     

@param xParam Parameter Description                             
@return xRet Return Description                                 
@author  -                                               
@since 16/09/2016                                                   
/*/                                                             
//--------------------------------------------------------------
User Function ProdValues()  //u_ProdValues()                      
	Local aButtons := {}
	Local oAcond
	Local oBtnOk
	Local oCliente
	Local oLoja
	Local oMostrar
	Local oPrcVen
	Local oProd
	Local oQtdVen
	Local oRgDes
	Local oFrete
	Local oCond
	Local oFont1 := TFont():New("Arial",,024,,.F.,,,,,.F.,.F.)
	Local oSay1
	Local oSay2
	Local oSay3
	Local oSay4
	Local oSay5
	Local oSay6
	Local oSay7
	Local oSay8
	Local oSay9

	Static cMostrar := ""
	Static cAcond 	:= Space(6)
	Static cCliente := Space(6)
	Static cLoja 	:= Space(2)
	Static nPrcVen 	:= Space(TAMSX3('C6_PRCVEN')[1])
	Static nRgDes	:= Space(TAMSX3('C6_PRCVEN')[1])
	Static cProd 	:= Space(10)
	Static nQtdVen 	:= Space(TAMSX3('C6_QTDVEN')[1])
	Static cFrete	:= Space(1)
	Static cCond	:= Space(8)
	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "New Dialog" FROM 000, 000  TO 600, 800 COLORS 0, 16777215 PIXEL

	@ 007, 009 SAY oSay1 PROMPT "CLIENTE" SIZE 046, 014 OF oDlg COLORS 0, 16777215 PIXEL
	@ 025, 009 SAY oSay2 PROMPT "LOJA" SIZE 046, 012 OF oDlg COLORS 0, 16777215 PIXEL
	@ 045, 009 SAY oSay8 PROMPT "FRETE" SIZE 046, 012 OF oDlg COLORS 0, 16777215 PIXEL
	@ 065, 009 SAY oSay9 PROMPT "COND_PAG" SIZE 046, 012 OF oDlg COLORS 0, 16777215 PIXEL
	@ 085, 009 SAY oSay3 PROMPT "PRODUTO" SIZE 046, 012 OF oDlg COLORS 0, 16777215 PIXEL
	@ 105, 009 SAY oSay4 PROMPT "ACOND" SIZE 046, 012 OF oDlg COLORS 0, 16777215 PIXEL
	@ 125, 009 SAY oSay5 PROMPT "QTD_VEN" SIZE 046, 012 OF oDlg COLORS 0, 16777215 PIXEL
	@ 145, 008 SAY oSay6 PROMPT "PRC_VEN" SIZE 048, 011 OF oDlg COLORS 0, 16777215 PIXEL
	@ 165, 008 SAY oSay7 PROMPT "%RG_DESEJADO" SIZE 048, 011 OF oDlg COLORS 0, 16777215 PIXEL

	@ 009, 065 MSGET oCliente 	VAR cCliente SIZE 140, 014 OF oDlg COLORS 	0	,16777215 PIXEL
	@ 025, 065 MSGET oLoja 		VAR cLoja SIZE 140, 014 OF oDlg COLORS 		0	,16777215 PIXEL

	@ 045, 065 MSGET oFrete 	VAR cFrete SIZE 140, 014 OF oDlg   COLORS 	0	,16777215 PIXEL
	@ 065, 065 MSGET oCond 		VAR cCond SIZE 140, 014 OF oDlg COLORS 		0	,16777215 F3 "SE4" PIXEL

	@ 085, 065 MSGET oProd 		VAR cProd SIZE 140, 014 OF oDlg COLORS 		0	,16777215 F3 "SB1" PIXEL
	@ 105, 065 MSGET oAcond 	VAR cAcond SIZE 140, 014 OF oDlg COLORS 	0	,16777215 PIXEL
	@ 125, 064 MSGET oQtdVen 	VAR nQtdVen SIZE 140, 014 OF oDlg COLORS 	0	,16777215 PIXEL
	@ 145, 063 MSGET oPrcVen 	VAR nPrcVen SIZE 140, 014 OF oDlg COLORS 	0	,16777215 PIXEL
	@ 165, 063 MSGET oRgDes 	VAR nRgDes SIZE 140, 014 OF oDlg  COLORS 	0	,16777215 PIXEL

	@ 185, 003 GET oMostrar 	VAR cMostrar OF oDlg MULTILINE SIZE 391, 100 COLORS 0, 16777215  FONT oFont1 HSCROLL PIXEL

	EnchoiceBar(oDlg, {||btnOk()}, {||oDlg:End()},,aButtons)

	ACTIVATE MSDIALOG oDlg CENTERED

Return

Static Function btnOk()
	Local oDesc := Nil
	Local cMsg	:= ""
	cMostrar := ""
	oDlg:Refresh()
	cMostrar := u_zOnNew(cCliente,cLoja,cProd,cAcond,Val(nQtdVen), Val(nPrcVen), Val(nRgDes),cFrete,cCond)
	oDlg:Refresh()
return Nil