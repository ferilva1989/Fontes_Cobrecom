#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch" 

//Fina090
//Rotina de Baixas a Pagar Automatica
*
***********************
User Function FA090SE5()
	***********************
	*      
	//|-----------------------------------------------------------------------------------------|
	//| FA090SE5                                                                                |     
	//| O ponto de entrada FA090SE5 sera executado apos gravar os dados no SE5 e apos           |
	//| a confirmacao da baixa automática                                                       |
	//|-----------------------------------------------------------------------------------------|

	Local cHist := ""

	cHist:= "Caixa "+IIf(xFilial("SE5")=="01","SP","MS")+cLoteFin

Return(cHist)