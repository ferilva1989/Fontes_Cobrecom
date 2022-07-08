#include "rwmake.ch"
*
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: FUNCOES LCTOS PADRAO               Modulo : SIGACTB      //
//                                                                          //
//   Autor ......: Roberto Oliveira                   Data ..: 17/08/10     //
//                                                                          //
//   Objetivo ...: Este programa tem todas as funções usadas noa lançamen-  //
//                 tos padrão.                                              //
//                                                                          //
//   Uso ........: Especifico da Cobrecom                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

*
****************************************
User Function ValConta(_cAlias,_cFilial)
	****************************************
	*
	*
	_aArea0 := GetArea()
	DbSelectArea("SA1")
	_aArea1 := GetArea()
	DbSelectArea("SA2")
	_aArea2 := GetArea()
	DbSelectArea("CT1")
	_aAreT1 := GetArea()
	DbSelectArea("CTK")
	_aAreTK := GetArea()

	/*
	If _cAlias == "SA1" 
	_cNumCta := IIf( _cFilial == "01" , SA1->A1_CONTA , SA1->A1_CONTA2 )
	Else
	_cNumCta := IIf( _cFilial == "01" , SA2->A2_CONTA , SA2->A2_CONTA2 )
	EndIf 
	*/
	If _cAlias == "SA1" 
		_cNumCta := IIf( _cFilial == "01" , SA1->A1_CONTA , If(Empty(SA1->A1_CONTA2),"114003000",SA1->A1_CONTA2) )

		//Criação de conta contabil para novos clientes
		If _cFilial == "01" .And. Empty(_cNumCta)
			IF !CT1->(DbSeek(xFilial("CT1")+"110009999",.T.))
				CT1->(DbSkip(-1))
				_cNumCta := Soma1(Alltrim(CT1->CT1_CONTA))
				_cNomCT1 := SA1->A1_NOME

				CriaCT1()

				RecLock("SA1",.F.)
				SA1->A1_CONTA := _cNumCta
				MsUnlock()
			Else
				Alert("Limite de contas do cliente atingido, verifique com o TI")
			EndIf
		EndIf
	Else
		_cNumCta := IIf( _cFilial == "01" , SA2->A2_CONTA , SA2->A2_CONTA2 )

		//Criação de conta contabil para novos fornecedores
		If _cFilial == "01" .And. Empty(_cNumCta)
			If !CT1->(DbSeek(xFilial("CT1")+"200002999",.T.))//Pego ultimo e volto 1.
				CT1->(DbSkip(-1))
				_cNumCta := Soma1(Alltrim(CT1->CT1_CONTA))
				_cNomCT1 := SA2->A2_NOME

				CriaCT1()

				RecLock("SA2",.F.)
				SA2->A2_CONTA := _cNumCta
				MsUnlock()
			Else
				Alert("Limite de contas do fornecedor atingido, verifique com o TI")
			EndIf
		EndIf
	EndIf 
	RestArea(_aAreTK)
	RestArea(_aAreT1)
	RestArea(_aArea2)
	RestArea(_aArea1)
	RestArea(_aArea0)

	Return(_cNumCta)
	*
	************************************************
Static Function GravaCTa(_cNumCta,_cAlias,_cCgc)
	************************************************
	*
	If _cAlias == "SA1"
		DbSelectArea("SA1")
		DbSetOrder(3) // A1_FILIAL+A1_CGC 
		DbSeek(xFilial("SA1") + _cCgc,.T.)
		Do While SA1->A1_FILIAL == xFilial("SA1")  .And. Left(SA1->A1_CGC,Len(_cCgc)) == _cCgc .And. SA1->(!Eof())
			If Empty(SA1->A1_CONTA) .Or. Left(SA1->A1_CONTA,6) # "112001"
				RecLock("SA1",.F.)
				SA1->A1_CONTA := _cNumCta
				MsUnLock()
			EndIf
			SA1->(DbSkip())
		EndDo
	Else
		DbSelectArea("SA2")
		DbSetOrder(3) // A2_FILIAL+A2_CGC
		DbSeek(xFilial("SA2") + _cCgc,.T.)
		Do While SA2->A2_FILIAL == xFilial("SA2")  .And. Left(SA2->A2_CGC,Len(_cCgc)) == _cCgc .And. SA2->(!Eof())
			If Empty(SA2->A2_CONTA) .Or. Left(SA2->A2_CONTA,6) # "211001"
				RecLock("SA2",.F.)
				SA2->A2_CONTA := _cNumCta
				MsUnLock()
			EndIf
			SA2->(DbSkip())
		EndDo
	EndIf                    
	Return(.T.)
	*
	*************************
Static Function CriaCT1()
	*************************
	*
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("CT1",.F.)
	_aCampos := {}
	Do While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "CT1"                
		If X3_CONTEXT # "V" // Não é campo virtual
			Aadd(_aCampos,{ TRIM(X3_CAMPO),""})
		Endif
		SX3->(DbSkip())
	EndDo              

	For _nCp := 1 to Len(_aCampos)
		If 	_aCampos[_nCp,1]     == "CT1_CONTA"
			_aCampos[_nCp,2] := _cNumCta
		ElseIf 	_aCampos[_nCp,1] == "CT1_DESC01"
			_aCampos[_nCp,2] := _cNomCT1
		ElseIf 	_aCampos[_nCp,1] == "CT1_CLASSE"
			_aCampos[_nCp,2] := "2"
		ElseIf 	_aCampos[_nCp,1] == "CT1_NORMAL"
			_aCampos[_nCp,2] := Left(_cNumCta,1)
		Else
			_aCampos[_nCp,2] := CriaVar(_aCampos[_nCp,1])
		EndIf
	Next
	// cria novo registro no CT1 e grava os dados
	DbSelectArea("CT1")
	RecLock("CT1",.T.)
	For _nCp := 1 to Len(_aCampos)
		FieldPut(FieldPos(_aCampos[_nCp,1]),_aCampos[_nCp,2])
	Next
	CT1->CT1_FILIAL := xFilial("CT1")
	MsUnLock()
	Return(.T.)
	*
	********************************
User Function mySomaAbt(_cAlias)
	********************************
	*              
	_nVolta := 0                                                                          
	If _cAlias == "SE1" .And. SE1->E1_SALDO == 0 .And. SE1->E1_VALLIQ == SE5->E5_VALOR
		_nVolta := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
	ElseIf _cAlias == "SE2" .And. SE2->E2_SALDO == 0 .And. SE2->E2_VALLIQ == SE5->E5_VALOR
		_nVolta := SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,,SE2->E2_FORNECE,SE2->E2_LOJA)
	EndIf                                   

Return(_nVolta)