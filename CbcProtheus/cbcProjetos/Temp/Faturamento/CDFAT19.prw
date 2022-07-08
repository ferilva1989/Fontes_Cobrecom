#include "rwmake.ch"
#include "protheus.ch"


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDFAT19                            Modulo : SIGAFAT      //
//                                                                          //
//                                                    Data ..: 22/12/2011   //
//                                                                          //
//   Objetivo ...: Apresentar histórico de clientes, referente a liberação  //
//                 ou rejeição de pedido de venda ou de investimento.       //
//                                                                          //
//   Uso ........: Especifico da Cobrecom                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
*
***********************
User Function CDFAT19()
	***********************
	*
	cCadastro := "Histórico de Clientes"
	aRotina := {{ "Pesquisar" , "AxPesqui"           , 0 , 1},;
	{ "Visualizar", "u_VisuHist(' ',' ')", 0 , 2},;
	{ "Incluir"   , "u_InclHist(.F.)"    , 0 , 3}}
	DbSelectArea("ZZ1")
	DbSetOrder(1) // ZZ1_FILIAL+ZZ1_CLIENT+ZZ1_LOJA+DTOS(ZZ1_DATA)
	DbSeek(xFilial("ZZ1"),.F.)

	mBrowse(001,040,200,390,"ZZ1",,,,,,)
	Set Filter to //Sempre desativar filtro após mBrowse

	Return(.T.)        
	*
	***********************************
User Function VisuHist(_cCli,_cLoj)
	***********************************
	*
	Local aButtons := {}
	*       
	_aArea := GetArea()

	DbSelectArea("SX3")
	_aAreaX3 := GetArea()
	DbSetOrder(1)
	DbSeek("ZZ1",.F.)

	DbSelectArea("ZZ1")
	DbSetOrder(1) // ZZ1_FILIAL+ZZ1_CLIENT+ZZ1_LOJA+DTOS(ZZ1_DATA)
	If !Empty(_cCli) .And. !Empty(_cLoj)           

		M->A1_CODMARC := Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_CODMARC") // Inicializar esta variavel para não dar erro no inicializador padrão

		// Posicionar no ultimo histórico desse cliente
		_cChv := xFilial("ZZ1") + _cCli + _cLoj
		If !DbSeek(_cChv,.F.)
			Alert("Não Há Históricos para Esse Cliente")
			RestArea(_aAreaX3)
			RestArea(_aArea)
			Return(.T.)
		EndIf
		_cChv2 := xFilial("ZZ1") + _cCli + "ZZ"
		DbSeek(_cChv2,.T.)
		Do While ZZ1->ZZ1_FILIAL+ZZ1->ZZ1_CLIENT+ZZ1->ZZ1_LOJA # _cChv .And. !ZZ1->(Bof())
			DbSkip(-1)
		EndDo
	EndIf
	aAdd( aButtons, { "PGPREV", { || u_PuleZZ1(1) }, "Primeiro"} )
	aAdd( aButtons, { "PREV"  , { || u_PuleZZ1(2) }, "Anterior"} )
	aAdd( aButtons, { "NEXT" ,  { || u_PuleZZ1(3) }, "Próximo" } )
	aAdd( aButtons, { "PGNEXT", { || u_PuleZZ1(4) }, "Ultimo"  } )

	AxVisual("ZZ1",Recno(),2,,,,, aButtons )

	/*/               
	_Volta := .T.
	Do While _Volta
	_VOLTA := AxVisual("ZZ1",Recno(),2,,,,, aButtons )
	EndDo
	/*/

	RestArea(_aAreaX3)
	RestArea(_aArea)
	Return(.T.)
	*
	****************************
User Function PuleZZ1(nOnde)
	****************************
	*    
	_cChv := ZZ1->ZZ1_FILIAL+ZZ1->ZZ1_CLIENT+ZZ1->ZZ1_LOJA
	DbSelectArea("ZZ1")
	DbSetOrder(1) // ZZ1_FILIAL+ZZ1_CLIENT+ZZ1_LOJA+DTOS(ZZ1_DATA)

	If nOnde == 1 // 1 - Inicio
		ZZ1->(DbSeek(_cChv,.F.))
	ElseIf nOnde == 2 // 2 - Anterior
		ZZ1->(DbSkip(-1))
		If ZZ1->ZZ1_FILIAL+ZZ1->ZZ1_CLIENT+ZZ1->ZZ1_LOJA # _cChv .Or. ZZ1->(Bof())
			ZZ1->(DbSeek(_cChv,.F.))
			Alert("Primeiro Registro Localizado")		
		EndIf
	ElseIf nOnde == 3 // 3 - Próximo
		_nRegAtu := Recno()
		ZZ1->(DbSkip())
		If ZZ1->ZZ1_FILIAL+ZZ1->ZZ1_CLIENT+ZZ1->ZZ1_LOJA # _cChv .Or. ZZ1->(Eof())
			DbGoTo(_nRegAtu)
			Alert("Último Registro Localizado")
		EndIf
	ElseIf nOnde == 4 // 4 - Fim
		_cChv2:= ZZ1->ZZ1_FILIAL+ZZ1->ZZ1_CLIENT+"ZZ"
		ZZ1->(DbSeek(_cChv2,.T.))
		Do While ZZ1->ZZ1_FILIAL+ZZ1->ZZ1_CLIENT+ZZ1->ZZ1_LOJA # _cChv .And. ZZ1->(!Bof())
			ZZ1->(DbSkip(-1))
		EndDo
	EndIf         
	//Close(oDlg)
	RegToMemory("ZZ1",.F.)
	Return(.T.)
	*
	**************************************************
User Function InclHist(_lMmCl,_cCli,_cLj,_lCampos)
	**************************************************
	*
	DEFAULT _lCampos := .F.
	DEFAULT _lMmCl := .T.
	Private _lMmCli := _lMmCl

	If _lMmCli

		_aArea := GetArea()

		DbSelectArea("SA1")
		_aAreaA1 := GetArea()

		DbSetOrder(1)
		DbSeek(xFilial("SA1")+_cCli+_cLj,.F.)

		M->A1_CODMARC := SA1->A1_CODMARC // Inicializar esta variavel para não dar erro no inicializador padrão

		DbSelectArea("SX3")
		_aAreaX3 := GetArea()
		DbSetOrder(1)
		DbSeek("ZZ1",.F.)
		If _lCampos
			_aCampos := {}
			Do While SX3->(!Eof()) .And. SX3->X3_ARQUIVO=="ZZ1"
				If X3USO(SX3->X3_USADO) .And. cNivel>=SX3->X3_NIVEL
					Aadd(_aCampos,AllTrim(SX3->X3_CAMPO))
				Endif
				SX3->(DbSkip())
			EndDo
		EndIf

		DbSelectArea("ZZ1")
		DbSetOrder(1) // ZZ1_FILIAL+ZZ1_CLIENT+ZZ1_LOJA+DTOS(ZZ1_DATA)
		If _lCampos
			AxInclui("ZZ1",0,3,,,_aCampos,)
		Else
			AxInclui("ZZ1",0,3,,,,)
		EndIf

		RestArea(_aAreaA1)
		RestArea(_aAreaX3)
		RestArea(_aArea)
	Else
		AxInclui("ZZ1",0,3, , , ,)
	EndIf
	Return(.T.)
	*
	************************
User Function MA030ROT()
	************************
	*
	// Ponto de entrada para incluir duas rotinas no memu do MATA030 - Cadastro de Clientes 

	// No incluir deixar parametro 2 mesmo... e não 3 .. para que não fique em loop no axinclui
	//myRotina := {{ "Hist.Incluir", "U_InclHist(.T.,SA1->A1_COD,SA1->A1_LOJA)"    , 0 , 3},;  
	myRotina := {{ "Hist.Incluir", "u_InclHist(.T.,SA1->A1_COD,SA1->A1_LOJA)"    , 0 , 2},;  
	{ "Hist.Visual" , "u_VisuHist(SA1->A1_COD,SA1->A1_LOJA)", 0 , 2},;
	{ "CadReceita", "u_zCadReceita(AllTrim(SA1->A1_CGC))"    , 0 , 2}}
Return(myRotina)
