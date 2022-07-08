#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} SPDPIS07
//TODO  Ponto de Entrada para possibilitar a geração do registro 0500 
		quando o código da conta contábil é diferente do informado na nota fiscal.
		Parametros :
		Nome	 	 	Tipo	 	 		Descrição	 	 	Default	 	 	Obrigatório	 	 	Referência	 
		PARAMIXB[1]	 	Caracter	 	 	FT_FILIAL	 	 	 	 	 	 	 	 	 	 
		PARAMIXB[2]	 	Array of Record	 	FT_TIPOMOV	 	 	 	 	 	 	 	 	 	 
		PARAMIXB[3]	 	Array of Record	 	FT_SERIE	 	 	 	 	 	 	 	 	 	 
		PARAMIXB[4]	 	Array of Record	 	FT_NFISCAL	 	 	 	 	 	 	 	 	 	 
		PARAMIXB[5]	 	Array of Record	 	FT_CLIEFOR	 	 	 	 	 	 	 	 	 	 
		PARAMIXB[6]	 	Array of Record	 	FT_LOJA	 	 	 	 	 	 	 	 	 	 
		PARAMIXB[7]	 	Array of Record	 	FT_ITEM	 	 	 	 	 	 	 	 	 	 
		PARAMIXB[8]	 	Array of Record	 	FT_PRODUTO	 	 	 	 	 	 	 	 	 	 
@author juliana.leme
@since 29/11/2017
@version 1.0
@return cConta, caracter, Código da Conta Contábil

@type function
/*/
User Function SPDPIS07()
	Local	cFilial		:=	PARAMIXB[1]	//FT_FILIAL
	Local	cTpMov		:=	PARAMIXB[2]	//FT_TIPOMOV
	Local	cSerie		:=	PARAMIXB[3]	//FT_SERIE
	Local	cDoc		:=	PARAMIXB[4]	//FT_NFISCAL
	Local	cClieFor	:=	PARAMIXB[5]	//FT_CLIEFOR
	Local	cLoja		:=	PARAMIXB[6]	//FT_LOJA
	Local	cItem		:=	PARAMIXB[7]	//FT_ITEM
	Local	cProd		:=	PARAMIXB[8]	//FT_PRODUTO	 	
	Local	cConta		:=	""
	Local	aAreaAnt 	:= GetArea()
	Local	cTes		:= ""
	
	//Movimento de Saida 
	If cTpMov == "S"
		cTes	:=	Posicione("SD2",3,xFilial("SD2")+cDoc+cSerie+cClieFor+cLoja+cProd+cItem,"D2_TES")
		If cTes <> ""
			cConta := Posicione("SF4",1,xFilial("SF4")+cTes,"F4_ZZCONTA") 
		EndIf
		If Empty(Alltrim(cConta))
			cConta := Posicione("SD2",3,xFilial("SD2")+cDoc+cSerie+cClieFor+cLoja+cProd+cItem,"D2_CONTA")
		EndIf
		If Empty(Alltrim(cConta))
			cConta := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_CONTA")
		EndIf
	ElseIf cTpMov == "E"
		cTes	:=	Posicione("SD1",1,xFilial("SD1")+cDoc+cSerie+cClieFor+cLoja+cProd+cItem,"D1_TES")
		If cTes <> ""
			cConta := Posicione("SF4",1,xFilial("SF4")+cTes,"F4_ZZCONTA") 
		EndIf
		If Empty(Alltrim(cConta))
			cConta := Posicione("SD1",1,xFilial("SD1")+cDoc+cSerie+cClieFor+cLoja+cProd+cItem,"D1_CONTA")
		EndIf
		If Empty(Alltrim(cConta))
			cConta := Posicione("SB1",1,xFilial("SB1")+cProd,"B1_CONTA")
		EndIf
	EndIf
	
	RestArea(aAreaAnt)
Return (cConta)