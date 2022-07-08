#include "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDGEN12                            Modulo : SIGAEST      //
//                                                                          //
//   Autor ......: Roberto Oliveira                   Data ..: 12/06/2008   //
//                                                                          //
//   Objetivo ...: Cadastro de amara��o Produto X Localiz. X C�d. Barras    //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

User Function CDGEN12()

	aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
	{ "Visualizar", "AxVisual", 0 , 2	},;
	{ "Incluir"   , "AxInclui", 0 , 3	},;
	{ "Alterar"   , "AxAltera", 0 , 4	},;
	{ "Excluir"   , "AxDeleta", 0 , 5	}}

	cCadastro := "Amarra��o Produto X Localiz. X C�d. Barras"
	DbSelectArea("SZJ")
	DbSetOrder(1)
	DbSeek(xFilial("SZJ"))

	mBrowse(001,040,200,390,"SZJ",,,,,,)

Return(.T.)