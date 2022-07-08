#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
*
***********************
User Function MTA450R()
	***********************
	*
	//Entrou nesta rotina assim que cliquei em rejeirar na rotina de liberação de credito
	// por pedido. Rejeita um item por vez.
	// Qual rotina chamou 	-> MATA450 -> Por PEDIDO -> item a item
	//						-> MATA450A -> Por CLIENTE -> Todos os Itens
	Local _nEvento 
	If Type("_cUltRej") # "C" 
		Public _cUltRej := " "
	EndIf

	_nRot:=1
	Do While .T.
		_cRotina := AllTrim(ProcName(_nRot++))
		If Empty(_cRotina) .Or. _cRotina == "MATA450A" .Or. _cRotina == "MATA450"
			Exit
		EndIf
	EndDo

	If (_cRotina == "MATA450A" .And. !("C"+SC9->C9_CLIENTE+SC9->C9_LOJA+"/") $ _cRejeit) .Or.;
	_cRotina == "MATA450"

		// Pergunto só cliente e loja mas adiciono o pedido para que no else abaixo eu faça 
		// também uma inclusão do evento de rejeição de pedido para outro pedido

		If   _cRotina == "MATA450A" // Por Cliente - Tudo numa só
			_cRejeit := _cRejeit + "//" + "C" + SC9->C9_CLIENTE + SC9->C9_LOJA + "/" + SC9->C9_PEDIDO 
			// Só adiciono aqui para não fazer diversas vezes para o mesmo cliente/pedido
			_nEvento := 10
		ElseIf _cRotina == "MATA450"  // Item a Item
			_nEvento := 11
		EndIf

		_aArea := GetArea()
		//	_lMmCl  := .T. // Esta variável é usada no DICIONÁRIO DE DADOS da tabela ZZ1.
		_lMmCli := .T. // Esta variável é usada no DICIONÁRIO DE DADOS da tabela ZZ1.
		DbSelectArea("ZZ1")
		RecLock("ZZ1",.T.)
		ZZ1->ZZ1_FILIAL := xFilial("ZZ1")
		ZZ1->ZZ1_USUARI := CriaVar("ZZ1_USUARI")
		ZZ1->ZZ1_DATA   := Date()
		ZZ1->ZZ1_CLIENT := SC9->C9_CLIENTE
		ZZ1->ZZ1_LOJA   := SC9->C9_LOJA
		ZZ1->ZZ1_NOME   := SA1->A1_NOME
		//	ZZ1->ZZ1_TPINVE := 
		//	ZZ1->ZZ1_DESCIN := 
		ZZ1->ZZ1_UNID   := CriaVar("ZZ1_UNID")
		ZZ1->ZZ1_HORA   := Left(Time(),Len(ZZ1->ZZ1_HORA))
		//	ZZ1->ZZ1_VALOR  := 
		MsUnLock()
		_nOpca := -1
		nOpcAltera := Len(aRotina) + 1
		aadd(aRotina,{"Alterar", "AxAltera", 0, 4})
		Do While _nOpca # 1
			If _nOpca # -1
				Alert("Favor Alterar os Campos Solicitados e CONFIRMAR a Operação")
			EndIf
			_nOpca := AxAltera("ZZ1",Recno(),nOpcAltera, , , ,)
		EndDo    
		ADEL(aRotina, nOpcAltera) 
		            
		_cUltRej := ZZ1->ZZ1_MOTIVO
		_aDadC5 := {SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_ENTREG,SC5->C5_TIPO}
		u_CDGEN21I(_nEvento,,,,_aDadC5) // 10-Analalise Credito Rejeicao") OU 11-Analise Cred.Rej. (Item)
		RestArea(_aArea)
	ElseIf (_cRotina == "MATA450A" .And. !("C"+SC9->C9_CLIENTE+SC9->C9_LOJA+"/"+SC9->C9_PEDIDO) $ _cRejeit)
		// Incluo Log da rejeição do próximo pedido
		_cRejeit := _cRejeit + "//" + "C" + SC9->C9_CLIENTE + SC9->C9_LOJA + "/" + SC9->C9_PEDIDO 
		_aDadC5  := {SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_ENTREG,SC5->C5_TIPO}
		RecLock("SC5",.F.)
		SC5->C5_DTLICRE := Ctod("  /  /  ")
		MsUnLock()
		u_CDGEN21I(10,,,,_aDadC5) // 10-Analalise Credito Rejeicao")
	EndIf

	If _cRotina == "MATA450A" .Or. _cRotina == "MATA450"
		RecLock("SC9",.F.)
		SC9->C9_X_REJEI := _cUltRej
		SC9->(MsUnlock())
	EndIf

Return(.T.)