#include "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDGEN13                            Modulo : SIGAEST      //
//                                                                          //
//   Autor ......: Roberto Oliveira                   Data ..: 22/04/2009   //
//                                                                          //
//   Objetivo ...: Cadastro de Rotas de Entregas                            //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
///////////////////////////////////////////////////////////////////////'///////

User Function CDGEN13()

	aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
	{ "Visualizar", "AxVisual", 0 , 2	},;
	{ "Incluir"   , "AxInclui", 0 , 3	},;
	{ "Alterar"   , "AxAltera", 0 , 4	}} 

	cCadastro := "Rotas de Entregas"
	DbSelectArea("SZK")
	DbSetOrder(1)
	DbSeek(xFilial("SZK"))

	mBrowse(001,040,200,390,"SZK",,,,,,)

Return(.T.)