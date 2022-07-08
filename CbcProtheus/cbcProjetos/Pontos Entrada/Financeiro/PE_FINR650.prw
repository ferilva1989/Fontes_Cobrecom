#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch" 

*
*********************
User Function FR650FIL()// PE - Localiza o titulo ( Está posicionado )
	*********************
	*                   
	/*
	// PE que acerta a descrição no relatorio de retorno do banco, quando 
	// o cliente possui desconto ou abatimento mais paga em valor integral.
	
	If mv_par07 == 1 .And. !SE1->(Eof())//Receber
		_aArea    := GetArea()
		_aAreaSE1 := SE1->(GetArea()) 

		//_nValTit := SALDOTIT(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,SE1->E1_MOEDA,dDataBase,SE1->E1_VENCREA,SE1->E1_LOJA,SE1->E1_FILIAL)
		_nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
		IF _nAbatim # ( PARAMIXB[1][7] + PARAMIXB[1][6] ) //ABATIMENTO + DESCONTO
			cOcorr := "98 " //DIFERENÇA DE VALORES
		EndIf

		RestArea(_aAreaSE1)
		RestArea(_aArea)
	EndIf
	*/
Return(.T.)                          
