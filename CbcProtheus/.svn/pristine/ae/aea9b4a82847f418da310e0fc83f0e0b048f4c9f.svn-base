#INCLUDE 'Protheus.ch' 

/*/{Protheus.doc} PrintPo
//TODO Realiza a impressão da eiqueta conforme array passado com 6 linhas maximo.
@author lucas.clementino
@since 04/01/2019
@version 1.0
@param aInfo, array, descricao
@param cPort, characters, descricao
@param nQuant, numeric, descricao
@type function
/*/
user function PrintPo(aInfo,cPort,nQuant) 
//PrintPo({"Descricao: Cabo Flexicom 16,0 mm2 VD     ","Lote: 000/000","Quantidade: 100","Num Proj: 123456","Nome do Projeto: Ferias","Num. da Ordem de Compra: 123546"},"LPT1",1) 
	local cModel := "Z4M" 
	local cLogo := "C:\Cobrecom\LOGO30A.GRF" 
	local cData := "Data: " + DtoC(dDataBase) 
	local n1 	:= 1, nCol := 3
	local CLetr := "35,40" 
	
	MSCBPRINTER(cModel,cPort,,,.F.) 
	MSCBCHKStatus(.F.) 
	MSCBLOADGRF(cLogo) 
	for nCont := 1 To nQuant step 1 
		nCol := 3
		MSCBBEGIN(1,6) 
		MSCBGRAFIC(065,003,"LOGO30A")
		for n1 := 1 to len(aInfo)
			nCol := nCol + 10
			MSCBSay(002,nCol,alltrim(aInfo[n1]),"N","0",AltTam(alltrim(aInfo[n1]))) 
		next
		MSCBSay(002,073,cData,"N","0","35,40") 
		MSCBEND() 
	next 
	MSCBClosePrinter() 
return 

/*/{Protheus.doc} AltTam
//TODO Caso o tamanho do campo ultrapsse a quantidade de caracteres maximo, altera  tamanho da fonte.
@author lucas.clementino
@since 04/01/2019
@version 1.0
@param cLin, characters, descricao
@type function
/*/
static Function AltTam(cLin) 
	local nLetra := Len(cLin) 
	
	if nLetra <= 40 
		cLetr := "35,40" 
	elseif nLetra < 50
		cLetr := "25,30" 
	else 
		cLetr := "20,25" 
	endif 
return cLetr 

user function cbcPrintEti(aString,cPort,nQuant)
	local cModel 	:= "Z4M" 
	local n1 		:= 1, nCol := 3, nCont := 1
	default aString	:= {}
	default	cPort	:= "LPT1"
	default	nQuant	:= 3
	
	MSCBPRINTER(cModel,cPort,,,.F.) 
	MSCBCHKStatus(.F.) 
	for nCont := 1 To nQuant step 1 
		MSCBBEGIN(1,6)
		nCol := 3
		for n1 := 1 to len(aString)
			If (aString[n1][4])
				MSCBBOX(001,(nCol-1),100,(nCol+aString[n1][3]-1),60,"B")
			EndIf
			MSCBSay(002,nCol,alltrim(aString[n1][1]),"N","0",alltrim(aString[n1][2]),aString[n1][4])
			nCol := nCol + aString[n1][3]
		next
		MSCBEND() 
	next 
	MSCBClosePrinter()
return

user function xxtstzncbceti()
	local aString 	:= {{"Numero do Pedido","35,40",,.F.},{"255000","85,90",,.F.},{"Numero da Bobina","35,40",,.F.},{"999999","85,90",,.F.}}
	local cPort 	:= "LPT1"
	local nQuant	:= 1
	u_cbcPrintEti(aString,cPort,nQuant)
return
