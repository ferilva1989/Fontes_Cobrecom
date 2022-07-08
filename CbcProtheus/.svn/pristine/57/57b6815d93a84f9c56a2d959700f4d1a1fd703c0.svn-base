#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch" 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PE_MATA150ºAutor  ³Leonardo Bolognesi  º Data ³  03/03/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Pontos de entrada do programa MATA150 (Atualização de Cotações deº±±
±±ºcompras          ³                                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso Compras       ³ AP                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ MT150ROT																³
//³EM QUE PONTO:Logo apos terminar o aRotina padrão permite a				³ 
//³inclusão de uma opçãono array aRotina                					³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function MT150ROT()
	//	Aadd(aRotina, { "Conhecimento" , "MsDocument", 0 , 4, 0, nil} )
Return (aRotina)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ FTMSREL																	³
//³EM QUE PONTO:Logo apos terminar o aRotina padrão permite adicionar		³ 
//³CHAVE PRIMARIA PARA UTILIZAR O BANCO DE CONHEIMENTO COM OUTRAS TABELAS   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
User Function FTMSREL()
	Local aEntidade := {}
	/*
	//LEONARDO 24/03/16 - NÃO MAIS UTILIZAR DOCUMENTO NA COTAÇÂO
	AAdd(aEntidade, {"SC8", {"C8_FILIAL","C8_NUM","C8_FORNECE","C8_LOJA","C8_ITEM","C8_NUMPRO","C8_ITEMGRD"},;
	{|| SC8->(	AllTrim(RetTitle("C8_FILIAL"))	+ " : " + C8_FILIAL + " " +;
	AllTrim(RetTitle("C8_NUM"))		+ " : " + C8_NUM	+ " " +;
	AllTrim(RetTitle("C8_FORNECE")) + " : " + C8_FORNECE+ " " +;
	AllTrim(RetTitle("C8_LOJA"))	+ " : " + C8_LOJA	+ " " +;
	AllTrim(RetTitle("C8_ITEM"))	+ " : " + C8_ITEM	+ " " +;
	AllTrim(RetTitle("C8_NUMPRO"))	+ " : " + C8_NUMPRO + " " +;
	AllTrim(RetTitle("C8_ITEMGRD")) + " : " + C8_ITEMGRD) }})
	*/                                                                                             

	/*LEONARDO 24/03/16 - PEDIDO JEF, MUDAR CHAVE PARA ADICIONAR DOCUMENTOS NO PEDIDO E NÃO NO ITEM*/
	AAdd(aEntidade, {"SC7", {"C7_FILIAL","C7_NUM"},;
	{|| SC7->(	AllTrim(RetTitle("C7_FILIAL"))	+ " : " + C7_FILIAL + " " +;
	AllTrim(RetTitle("C7_NUM")) 	+ " : " + C7_NUM) }})         


Return aEntidade