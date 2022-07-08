#include 'protheus.ch'

// Robert Santos
// 06 JAN 2014 - NEGOCIACAO PENDENTE DE APROVACAO PARA ALTERAR PEDIDO
user Function REST16D()

	Local aCores := {}

	private __cAlias := "ZZV"
	private __aIndex  := {}  
	private __cFiltro := "!EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'S' .AND. EMPTY(ZZV_USERA) .AND. ZZV_LIBEOK $ 'N '"
	Private cCadastro 	:= "CONTROLE DE NEGOCIACAO"
	Private bFiltraBrw := { || FilBrowse( __cAlias , @__aIndex , @__cFiltro ) }
	Private aRotina 	:= {}
	//Private cMV_DNEG := strzero(GETMV('MV_DNEG'),4,0) //By Roberto Oliveira 29/05/14
	Private nMV_DNEG := GETMV('MV_DNEG') //By Roberto Oliveira 29/05/14

	private __lAltPed := .F.

	AAdd( aCores, {" !EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'S' .AND. !EMPTY(ZZV_USERA)"	,"BR_VERDE"} ) // Finalizado COM ACEITE
	AAdd( aCores, {" !EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'S' .AND. EMPTY(ZZV_USERA) .AND. ZZV_LIBEOK $ 'N '"		,"BR_PINK"} ) // FALTA SER APROVADO PARA ALTERAR O PEDIDO
	AAdd( aCores, {" !EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'S' .AND. EMPTY(ZZV_USERA) .AND. ZZV_LIBEOK == 'S'"		,"BR_MARROM"} ) // FALTA ENCERRAR PELO APROVADOR INTERNO COBRECOM
	AAdd( aCores, {" !EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'N' "							,"BR_BRANCO"} ) // Finalizado REJEITADO

	//AAdd( aCores, {" ZZV_DIASEN < cMV_DNEG ","BR_VERMELHO"} ) // VENCIDO  //By Roberto Oliveira 29/05/14
	AAdd( aCores, {" Val(ZZV_DIASEN) < nMV_DNEG ","BR_VERMELHO"} ) // VENCIDO  //By Roberto Oliveira 29/05/14

	AAdd( aCores, {" EMPTY(ZZV_DTPRIM)"														,"BR_AMARELO"} ) // FALTA INICIAR ATENDIMENTO
	AAdd( aCores, {" !EMPTY(ZZV_DTPRIM) "													,"BR_AZUL"} ) // EM NEGOCIACAO

	AAdd( aRotina, {"Pesquisar"    ,"AxPesqui"  ,0,1} )
	AAdd( aRotina, {"Visualizar"   ,"u_REST16v" ,0,2} )
	AAdd( aRotina, {"Liberar"      ,"u_CREST16b(.F.)",0,2} )   
	AAdd( aRotina, {"Rejeitar Alt.","u_CEST162b",0,4} )
	AAdd( aRotina, {"Imprimir"     ,"u_CEST162i",0,4} )
	AAdd( aRotina, {"Legenda"      ,"u_REST16l" ,0,2} ) 

	MsgRun("Aguarde","Aguarde",{||u_Rest16x()}) // atualiza o status dos pendentes (dias em atraso aberto etc)

	Eval( bFiltraBrw )
	mBrowse(6,1,22,75,__cAlias,,,,,,aCores)
	EndFilBrw( __cAlias , @__aIndex )
return nil