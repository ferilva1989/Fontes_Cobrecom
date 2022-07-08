#include "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: MTA440L                            Modulo : SIGAFAT      //
//                                                                          //
//   Autor ......: RODRIGO O. T. CAETANO              Data ..: 17/08/2004   //
//                                                                          //
//   Objetivo ...: Ponto de Entrada na Liberação do Estoque de Pedidos de   //
//                 Vendas para Bloquear o Estoque dos Produtos com Controle //
//                 de Endereçamento, pois os mesmos serão liberados pela    //
//                 Ordem de Separação                                       //
//                 Na rotina de exclusão de NFS(MATA521A), estando o parâmetro (F12)  //
//                 como APTO A FATURAR, retornar com Zero para manter  a    //
//                 separação. (FUNCIONA)                                    //
//   31/03/07 - O bloqueio tem que ocorrer sempre e não somente quandoo pro //
//              duto tiver controle de loc.fisica.                          //
//                                                                          //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

User Function MTA440L // Função Revisada //chamou na liberação do pedido 
	Private _nSaldo := 0      //lib.cred. por pedido/cliente -> chamou quanto liberou tudo por item A ITEM
	_Var := " "
	For i := 0 to 30
		_Var := ProcName(i) 
		If "MATA521A" $ _Var   //MATA450 quando liberou o credido  por item
			Exit
		EndIf
	Next
	If !("MATA521A" $ _Var) // Na exclusão de NFS permitir a liberação do SC9
		_nSaldo := 999999999999 // Retorno com quantidade absurda para garantir que o estoque será bloqueado
	EndIf
Return(_nSaldo)    // Este saldo será subtraído no mata440 o que consequentemente não terá para liberação