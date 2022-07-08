#include 'protheus.ch'
#include 'parmtype.ch'

#Define linha chr(13)+chr(10)


/*/{Protheus.doc} CbcInvEt
//TODO Descri��o auto-gerada.
@author alexandre.madeira
@since 04/10/2018
@version 1.0
@return ${return}, ${return_description}
@param cId, characters, descricao
@param dDtIni, date, descricao
@type function
/*/
user function CbcInvEt(cId, dDtIni)
	Local aPergs 	:= {}
	Local aRet		:= {}
	Local nQtde		:= 1
		
	// dDtIni := Ctod(dDtIni)
	
	aAdd( aPergs ,{4,"Contagens: ",.F.,"Contagem 1",90,'.T.',.F.})
	aAdd( aPergs ,{4,"",.F.,"Contagem 2",90,'.T.',.F.})
	aAdd( aPergs ,{4,"",.F.,"Outras Contagens",90,'.T.',.F.})
	aAdd( aPergs ,{1,"Informe Outras Contagens: ",Space(15),"@!","StaticCall(CbcInvEt, vldOutra)",,"MV_PAR03",0,.F.}) 
	aAdd( aPergs ,{2,"Quantidade de Etiquetas: ","1", {"1","100","500","1000"}, 50,"!Empty(MV_PAR05)",.T.})
	
	
	If !ParamBox(aPergs ,"Impress�o de Etiquetas de Invent�rio",aRet)    
		Alert("Impress�o Cancelada!")
		return(nil)
	Else
		vldEtiq(cId, dDtIni)
	EndIf
	
return(nil)
 
 
/*/{Protheus.doc} vldEtiq
Valida Estiqueta e Chama fun��o que faz a impress�o.
@author alexandre.madeira
@since 04/10/2018
@version 1.0
@return nil
@param cId, characters, Id do Invent�rio
@param dDtIni, date, Data do Invent�rio
@type function
/*/
static function vldEtiq(cId, dDtIni)
 	local aContag	:= {}
 	local nQtde		:= Val(MV_PAR05)
 	local cMes		:= ""
 	local cAno		:= ""
 	local nCount	:= 0
 	local nCount2	:= 0
 	local aOuCont	:= {}
 	local cDtInve	:= ""
 	local cMsg		:= ""
 	local cPort		:= ""
 	
 	cMes	:=	SubSTR(CMonth(dDtIni), 1, 3)
	cAno	:=	Alltrim( Str( Year ( dDtIni ) ) )
		
 	cDtInve := cMes + "/" + cAno
 	
 	for nCount := 1 to 3
 		if &( "MV_PAR" + StrZero( nCount, 2, 0 ) )
 			if nCount == 1
 				aAdd(aContag,1)
 			elseif nCount == 2
 				aAdd(aContag,2)
 			else
 				if !Empty(AllTrim(MV_PAR04))
 					aOuCont := contRange()
 					if len(aOuCont)>0
	 					for nCount2 := 1 to len(aOuCont)
	 						aAdd(aContag, aOuCont[nCount2])
	 					next
	 				endif
 				endif
 			endif
 		endif
 	next
 	
 	cPort  := cValToChar(pergPorta())
 	
 	if empty(cPort)
	 	alert("Impress�o cancelada!")
	 	return(nil)
	endif
	
	for nCount := 1 to len(aContag)
		//Fun��o de Impress�o
		PrintInv(cId,cDtInve,aContag[nCount],nQtde,cPort) 
 	next 
return(nil)


/*/{Protheus.doc} contRange
Devolve array com todos os elementos do Range.
@author alexandre.madeira
@since 04/10/2018
@version 1.0
@return aRet, Array, todos os elementos do Range.
@type function
/*/
static function contRange()
	local cRange	:= AllTrim(MV_PAR04)
	local nCount	:= 0
	local nCount2	:= 0
	local cSepAte	:= "-"
	local cSepInd	:= ","
	local cCarac	:= ""
	local cCarac2	:= ""
	local cDe		:= ""
	local cAte		:= ""
	local aRet		:= {}
	local cTRange	:= ""
	
	for nCount := 1 to len(cRange)
		cCarac := SubSTR(cRange, nCount, 1)
		if cCarac == cSepAte
			cTRange := SubSTR(cRange, (nCount+1))
			for nCount2 := 1 to len(cTRange)
				cCarac2 := SubSTR(cTRange, nCount2,1)
				if IsDigit(cCarac2)
					cAte += cCarac2
				else
					nCount2--
					EXIT
				endif				
			next
			nCount := nCount + nCount2
			if val(cDe) > val(cAte)
				alert("ERRO! Range de Contagens inv�lido.")
				return({})
			else
				for nCount2 := val(cDe) to val(cAte) 
					aAdd(aRet, nCount2)
				next
			endif
			cAte	:= ""
			cDe		:= ""
		elseif cCarac == cSepInd
			aAdd(aRet, val(cDe))
			cDe := ""
		else
			cDe += cCarac
		endif
	next
	// Adiciona o �ltimo elemento caso o cDe estiver vazio
	if !empty(cDe)
		aAdd(aRet, val(cDe))
	endif
return(aRet)



/*/{Protheus.doc} vldOutra
Validar conte�do de outras contagens. Deve ser seprado por ,(V�rgula) ou -(H�fen).
@author alexandre.madeira
@since 04/10/2018
@version 1.0
@return lRet, L�gico, .T. - Conte�do OK || .F. - Conte�do inv�lido
@type function
/*/
static function vldOutra()
	local lRet		:= .T.
	local cRange	:= AllTrim(MV_PAR04)
	local cCarac	:= ""
	local cSepAte	:= "-"
	local cSepInd	:= "," 
	local nCount	:= 0	
	
	// Loop todos os elementos da String
	for nCount := 1 to len(cRange)
		cCarac := SubSTR(cRange, nCount, 1)
		// verifica caracteres inv�lidos
		if !IsDigit(cCarac) .And. cCarac <> cSepAte .And. cCarac <> cSepInd
			lRet := .F.
			alert("ERRO! Informe as contagens separadas por -(h�fen) ou ,(virgula).")			
			EXIT
		elseif cCarac == cSepAte .Or. cCarac == cSepInd
			nCount++
			cCarac := SubSTR(cRange, nCount, 1)
			// Final da string sempre deve ser num�rico ou � conte�do inv�lido
			if !IsDigit(cCarac)
				lRet := .F.
				alert("ERRO! Informe as contagens separadas por -(h�fen) ou ,(virgula).")			
				EXIT
			endif					
		endif
	next
return(lRet)


/*FUN��ES DE IMPRESS�O*/
/*/{Protheus.doc} PrintInv
Impimir Etiquetas de Invent�rio.
@author lucas.clementino
@since 04/10/2018
@version 1.0
@return nil
@param cId, characters, Id do Invent�rio
@param cDt, characters, M�s/Ano do invent�rio
@param nCont, numeric, n�mero da contagem
@param nQuant, numeric, qtde de etiquetas a imprimir
@type function
/*/
static function PrintInv(cId,cDt,nCont,nQuant,cPort) //PrintInv(096,"NOV/2018",2,2) 
    Default cId    := "ETQ.INVE"
	Default cDt    := "Mes/Ano"
	Default nCont  := 1
	Default nQuant := 1
	Default cPort  := cValToChar(pergPorta())
	
	cCabec := "Invent�rio PCF - " + cDt
	cCont  := cValToChar(nCont) + " Contagem"
	cId	   := "ID " + cId	
	cModel := "GC420 T"
	
	MSCBPRINTER(cModel,cPort,,,.F.) 
	MSCBCHKStatus(.F.)	
	For nCont := 1 To nQuant Step 1
		MSCBBEGIN(1,6) 
		MSCBSay(030,007,cCabec,"N","0","35,40") 
		MSCBSay(030,021,cCont,"N","0","100,90") 
		MSCBSay(055-len(cId),047,cId,"N","0","30,35") 
		MSCBEND() 
	Next
	MSCBClosePrinter() 
Return(nil)


/*/{Protheus.doc} Porta
Perguntar e Configurar a Porta de impress�o.
@author lucas.clementino
@since 04/10/2018
@version 1.0
@return nil
@type function
/*/
Static Function pergPorta()
	local aRet 		:={}
	local aParamBox	:= {}
	local cPorta	:= ""
	
	aAdd(aParamBox,{3,"Porta de Impress�o..:",2,{"LPT1","LPT2","LPT3"},50,"",.F.})	
	If !ParamBox(aParamBox, "Informe Porta para Impress�o", @aRet)    
		Alert("Impress�o Cancelada!")
		return(cPorta)
	endif	
	cPorta  := Substr("LPT1/LPT2/LPT3/",((aRet[1]-1)*5)+1,4)		
Return(cPorta)
