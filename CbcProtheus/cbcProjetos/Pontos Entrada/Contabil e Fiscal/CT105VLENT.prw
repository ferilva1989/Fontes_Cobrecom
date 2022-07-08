#Include 'Protheus.ch'
#include "rwmake.ch"

User Function  CT105VLENT()
Local lRet	:= .T.
Local cTipo	:= Paramixb[1] // Tipo de lanc. contabil 1-> Debito, 2-> Credito, 3-> Partida Dobrada
Local cDebito	:= Paramixb[2] // Conta Debito
Local cCredito	:= Paramixb[3] // Conta Credito
Local cCustoDeb	:= Paramixb[4] // C.Custo Debito
Local cCustoCrd	:= Paramixb[5] // C.Custo Credito
Local cItemDeb	:= Paramixb[6] // Item Contabil Debito
Local cItemCrd	:= Paramixb[7] // Item Contabil Credito
Local cCLVLDeb	:= Paramixb[8] // Cl Valor Debito
Local cCLVLCrd	:= Paramixb[9] // Cl Valor Credito

	// Valida Contas de Despesas X Centro de Custo
	If ((cDebito >= "412020001" .and. cDebito <= "412020097") .or. ;
		(cDebito >= "511020001" .and. cDebito <= "511020097")) .and. ;
		Empty(Alltrim(cCustoDeb))
		MsgBox("Lançamento em contas de Despesas sem Centro de Custo informado.","CT105VLENT","ALERT")
		lRet := .F.
	ElseIf ((cCredito >= "412020001" .and. cCredito <= "412020097") .or. ;
		(cCredito >= "511020001" .and. cCredito <= "511020097")) .and. ;
		Empty(Alltrim(cCustoCrd))
		MsgBox("Lançamento em contas de Despesas sem Centro de Custo informado.","CT105VLENT","ALERT")
		lRet := .F.
	EndIf

	//Valida Centro de Custo
	If ! Empty(cCustoDeb) .and. Left(cDebito,1,1) == "4" .and. ! Left(cCustoDeb,1,1) $ "3/4"
		MsgBox("Centro de Custo não permitido para a conta de Despesa informada.","CT105VLENT","ALERT")
		lRet := .F.
	ElseIf ! Empty(cCustoCrd) .and. Left(cCredito,1,1) == "5" .and. ! Left(cCustoCrd,1,1) $ "1/2/4"
		MsgBox("Centro de Custo não permitido para a conta de Despesa informada.","CT105VLENT","ALERT")
		lRet := .F.
	Endif

	//Valida Informação de Centro de Custo em Contas Passivo
	//Debito com  Centro de Custo Dif de 3 com conta 4 (Não)
	If ! Empty(cCustoDeb) .and. ;
		((Left(cDebito,1,1) $ ("1/2/4/") .and. ! Left(cCustoDeb,1,1) $ "/3/4").or.;
		(Left(cDebito,1,1) $ ("1/2/5/") .and. ! Left(cCustoDeb,1,1) $ "/1/2/4"))
		MsgBox("Centro de Custo não permitido para a conta informada.","CT105VLENT","ALERT")
		lRet := .F.
	ElseIf ! Empty(cCustoCrd) .and. ;
		((Left(cCredito,1,1) $("1/2/4/") .and.  ! Left(cCustoCrd,1,1) $ "3/4").or.;
		(Left(cCredito,1,1) $ ("1/2/5/") .and. ! Left(cCustoCrd,1,1) $ "1/2/4"))
		MsgBox("Centro de Custo não permitido para a conta de Despesa informada.","CT105VLENT","ALERT")
		lRet := .F.
	Endif
	
		// Valida Contas Fornecedores e Clientes X Item Contabil
	If ((cDebito = "211019999" ) .or. 	(cDebito = "112019999")) .and. Empty(Alltrim(cItemDeb))
		MsgBox("Lançamento em contas Clientes ou Fornecedores sem Item Contabil informado.","CT105VLENT","ALERT")
		lRet := .F.
	ElseIf ((cCredito = "211019999") .or.	(cCredito = "112019999" )) .and. 	Empty(Alltrim(cItemCrd))
		MsgBox("Lançamento em contas Clientes ou Fornecedores sem Item Contabil informado.","CT105VLENT","ALERT")
		lRet := .F.
	EndIf
Return lRet
// se lRet = .F.  o sistema emite a  mensagem informando que as
// entidades não podem ser iguais e cancela a operação