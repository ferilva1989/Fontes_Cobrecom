#include "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDGEN20                            Modulo : SIGAEST      //
//                                                                          //
//   Autor ......: Roberto Oliveira                   Data ..: 22/10/2013   //
//                                                                          //
//   Objetivo ...: Inclusão de FCI para produtos novos                      //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

*
***********************
User Function CDGEN20()
***********************
*
aCores    := {{"!Empty(ZZH_NFCI)"  ,'ENABLE'    },; //FCI Autorizada
			  {"ZZH_STATUS == 'E'" ,'BR_AZUL'   },; //FCI Enviada
			  {"ZZH_STATUS == 'S'" ,'BR_AMARELO'},; //FCI Não Enviada
			  {"ZZH_STATUS == 'S'" ,'BR_AMARELO'},; //FCI Não Enviada
			  {"ZZH_STATUS $  'NA'","DISABLE"   }}  //FCI Não Válida

aRotina := {{ "Pesquisar"  , "AxPesqui"  , 0 , 1	},;
			{ "Visualizar" , "AxVisual"  , 0 , 2	},;
			{ "Incluir"    , "AxInclui"  , 0 , 3	},;
			{ "Alterar"    , "u_AltZZH"  , 0 , 4	},;
			{ "Excluir"    , "u_DelZZH"  , 0 , 5	},;
			{ "Enviar FCI" , "u_CDFCITxt", 0 , 5	},;
			{ "Receber FCI", "u_CDFCIRET", 0 , 5	},;
			{ "Legenda"    , "u_CDGEN20L", 0 , 2 }}
			
cCadastro := "Ficha de Fator de Conteúdo de Importação"
DbSelectArea("ZZH")
DbSetOrder(1)
DbSeek(xFilial("ZZH"),.F.)

mBrowse(001,040,200,390,"ZZH",,,,,,aCores)

Return(.T.)
*
**********************
User Function AltZZH()
**********************
*
If Empty(ZZH->ZZH_NFCI) .And. ZZH->ZZH_STATUS # "E" // Não autorizado e não enviado
	nOpca   := AxAltera("ZZH",Recno(),4,,,)
Else
	Alert("FCI não pode ser Alterada")
EndIf
Retur(.T.)                                  
*
**********************
User Function DelZZH()
**********************
*
If Empty(ZZH->ZZH_NFCI) .And. ZZH->ZZH_STATUS # "E" // Não autorizado e não enviado
	nOpca   := AxDeleta("ZZH",Recno(),5,,,)
Else
	Alert("FCI não pode ser Excluída")
EndIf
Retur(.T.)                                  
*
***********************
User Function CDGEN20L()
***********************
*
BrwLegenda(cCadastro,"Legenda",{{"ENABLE"     ,"FCI Autorizada"},;
  	                            {"BR_AZUL"    ,"FCI Enviada"   },;  
   	                            {"BR_AMARELO" ,"FCI Não Enviada"},;
       	                        {"DISABLE"    ,"FCI Não Válida"}})
Return(.T.)
*       
***********************
User Function MT010OK()
***********************
*
xx:=.T.
Return(xx)
*       
************************
User Function MT010ALT()
************************
*
xx:=.T.
Return(xx)