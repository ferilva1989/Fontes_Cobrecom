#include "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDGEN15                            Modulo : SIGAEST      //
//                                                                          //
//   Autor ......: Roberto Oliveira                   Data ..: 19/09/2007   //
//                                                                          //
//   Objetivo ...: Consulta a Saldos em Estoque                             //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

User Function CDGEN15()

	aCores    := {{"ZE_STATUS $ 'IL'"  ,"BR_PINK"},;  
	{"ZE_STATUS == 'C'"  ,"BR_BRANCO"},;  
	{"ZE_STATUS == 'V'"  ,"BR_AMARELO"},;  
	{"ZE_STATUS == 'N'"  ,"DISABLE"},;  
	{"ZE_STATUS $  'RP'" ,"BR_CINZA"},;  
	{"ZE_STATUS == 'E'"  ,"BR_LARANJA"},;
	{"ZE_STATUS $  'FD'" ,"BR_AZUL" },;  
	{"ZE_STATUS == 'X'"  ,"BR_PRETO" },;  
	{"ZE_STATUS == 'T'"  ,"ENABLE"}}        

	cCadastro := "Posição de Estoques de Bobinas"


	aRotina := {{ "Pesquisar"     , "AxPesqui"  , 0 , 1	},;
	{ "Visualizar"    , "AxVisual"  , 0 , 2	},;
	{ "Legenda"       , "U_CDGEN15x", 0 , 2 }}

	DbSelectArea("SZE")
	DbSetOrder(1)        

	Set Filter to ZE_STATUS=="T"
	DbSeek(xFilial("SZE"),.F.)
	mBrowse(001,040,200,390,"SZE",,,,,,aCores)
	DbSelectArea("SZE")
	Set Filter to 
	Return(.T.)
	*                       
	************************
User Function CDGEN15x()
	************************
	*
	BrwLegenda(cCadastro,"Legenda",{{"DISABLE"   ,"Com Reserva Definitiva"},;
	{"BR_AMARELO","Com Reserva"},;
	{"BR_BRANCO" ,"Cancelada"},;
	{"BR_PINK"   ,"Importada ou Laboratório"},;
	{"BR_CINZA"  ,"Recebida ou A Liberar"},;
	{"BR_LARANJA","Empenhada"},;
	{"BR_AZUL"   ,"Faturada ou Adiantada"},;
	{"BR_PRETO"  ,"Expedida"},;
	{"ENABLE"    ,"Disponível no Estoque"}})
Return(.T.)