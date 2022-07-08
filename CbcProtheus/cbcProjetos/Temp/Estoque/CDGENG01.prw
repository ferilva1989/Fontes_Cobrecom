#include "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDGENG01                           Modulo : SIGAEST      //
//                                                                          //
//   Autor ......: RODRIGO O. T. CAETANO              Data ..: 29/06/2004   //
//                                                                          //
//   Objetivo ...: Gatilho acionado nos campos B1_NOME, B1_BITOLA, B1_COR,  //
//                 B1_CLASENC, B1_ESPECIA, B1_FORNECE e B1_IDENTIF para      //
//                 montar a Descrição do Produto                            //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

User Function CDGENG01

	_cDesc := ""

	DbSelectArea("SZ1")
	DbSetOrder(1)  //Z1_FILIAL+Z1_COD
	DbSeek(xFilial("SZ1")+M->B1_NOME,.F.)
	_cDesc += SZ1->Z1_DESC+Space(1)

	If M->B1_TIPO == "PA"
		DbSelectArea("SZ2")
		DbSetOrder(1)  //Z2_FILIAL+Z2_COD
		DbSeek(xFilial("SZ2")+M->B1_BITOLA,.F.)
		_cDesc += PadL(AllTrim(SZ2->Z2_DESC),10)+Space(1)
	EndIf

	DbSelectArea("SZ3")
	DbSetOrder(1)  //Z3_FILIAL+Z3_COD
	DbSeek(xFilial("SZ3")+M->B1_COR,.F.)
	_cDesc += SZ3->Z3_APELIDO

	If M->B1_TIPO == "PA" .And. !Empty(M->B1_CLASENC) .And. M->B1_ESPECIA # "00" .And. M->B1_ESPECIA # "01"  //Especial
		_cDesc += "(E)"
	EndIf
Return(u_CortaDesc(_cDesc))