#include 'protheus.ch'

// Robert Santos
// 10/10/2013
// Rotina para realizar a transferencia de materiais


// PARAMETROS ENTRADA
//  lRETRAB: .T. (TRANSFERENCIA RETRABALHO) .F. (TRANSFERENCIA NORMAL)
//  cPROD: CODIGO DO PRODUTO
//  cLOCALIZ: LOCALIZACAO DO PRODUTO EX. B00500
//  cDE: LOCAL DE, EX. '01'
//  cPARA: LOCAL DESTINO, EX. '70'
//  nQuant: Quantidade total para movimentar
//  cZE_TPBOB: Tp BObina (só quando lRetrab := .T.)
//  lRESERVB := .T. RESERVAR BOBINA, .F. NAO RESERVAR BOBINA
//  cNUMBOB	:= NUMERO DA BOBINA

// PARAMETRO SAIDA
//  aRET[1]: (.T. OK, .F. NAO OK)
//  aRET[2]: MENSAGEM
*
****************************************************************************************************************
User Function CRESTXT(lRetrab,cProd,cLocaliz,cAcond,cDe,cPara,nQuant,cZE_TPBOB, lRESERVB, cNumBob,lStBob,cTabId)
	****************************************************************************************************************
	*
	local aRet := {.f.,"NAO INICIADO"} // 1= OK?, 2=MENSAGEM
	local cPeso := 0 // INDICADOR DO PESO DO PRODUTO
	local nBF_LOCALIZ := TamSX3("BF_LOCALIZ")[1]

	private _lTemBMM := .F.
	private _cNumBMM, _cItBmm, _cLocaliz    

	Default cTabId := ""
	default cZE_TPBOB := ""
	Default lStBob := .T. // By Roberto Oliveira 10/07/14 - Controla se altera o status da Bobina. Em caso de retorno
	// para o 01 e for aprovado, não altera o status para T(estoque) deixa em N(reserva confirmada).

	DbSelectArea("SBF")
	DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

	DbSelectArea("SZB")
	DbSetOrder(1) // ZB_FILIAL+ZB_NUM

	SZB->(DbSeek(xFilial("SZB") +"S     ",.T.))// Acha o Nro.do ultimo BMM com R no inicio
	SZB->(DbSkip(-1))
	If Left(SZB->ZB_NUM,1) == "R"
		_cNumBMM := SZB->ZB_NUM
	Else
		_cNumBMM := "R00000"
	EndIf
	Do While SZB->(DbSeek(xFilial("SZB") + _cNumBMM,.F.))
		_cNumBMM := Soma1(_cNumBMM)
	EndDo
	_cItBmm := "000"

	DbSelectArea("SB1")
	DbSetOrder(1) // B1_FILIAL+B1_COD   

	dbselectarea("SZE")

	_cLocaliz := cLocaliz

	aRet[1] := .T. // Adicionado por Roberto Oliveira 30/05/14 -> ver outras observações de 30/05/14

	BeginTran()

	DbSelectArea("SBF") //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

	// Posiciona no armazem do parâmetro ou no 01 se for reserva
	DbSeek(xFilial("SBF") + If(Empty(cTabId),cDe,"01") + PADR(_cLocaliz,nBF_LOCALIZ) + cPROD , .F. )


	If Empty(cTabId) // Ainda da forma antiga -> com transf. e sem reserva

		// Verificar se tem saldo para fazer a movimentação
		If SBF->(Eof()) .Or. (SBF->BF_QUANT - SBF->BF_EMPENHO) < nQuant .Or. SBF->BF_EMPENHO < 0 // Acredite... já peguei casos em que o empenho estava negativo...
			aRet[1] := .f.
			aRet[2] := "SEM SALDO SUFICIENTE"
		ElseIf cACond == "B" // By Roberto Oliveira 30/05/14
			SZE->(dbsetorder(1))
			If !SZE->(DbSeek(xFilial("SZE") + Left(cNumBob,Len(SZE->ZE_NUMBOB)),.F.))
				aRet[1] := .f.
				aRet[2] := "BOBINA NÃO LOCALIZADA"
			Else
				If cDe == "01" .And. SZE->ZE_STATUS # "T"
					// RETIRAR DO 01 ?
					aRet[1] := .f.
					aRet[2] := "BOBINA NÃO MAIS ESTÁ DISPONÍVEL"
				ElseIf !SZE->(RECLOCK("SZE",.F.))
					aRet[1] := .f.
					aRet[2] := "BOBINA EM USO POR OUTRA ROTINA"
				Else
					If cDe == "01" // RETIRAR DO 01 ?
						SZE->ZE_STATUS := "N"
						// ElseIf cPara == "01" // DEVOLVER PARA O 01 ?? - linha retirada em 10/07/14 e adidionada a seguinte
					ElseIf cPara == "01" .And. lStBob  // DEVOLVER PARA O 01 ?? (10/07/14-lStBob=Volta a bobina como estoque?)
						SZE->ZE_STATUS := "T"
					EndIf
					SZE->(MsUnLock())
				EndIf
			EndIf
			//else
			//	aRet[1] := .T.
			// Retirado por Roberto Oliveira 30/05/14
		EndIf
	Else // If !Empty(cTabId) // Da forma nova... com reserva
		// Matar a reserva e transferir do 01 para o 90
		aRet := u_EmpSDC(.F.,cTabId,cProd,"01",cLocaliz,nQuant,ZZU->ZZU_ZZEID,cNumBob,.F.)
		//EmpSDC(.t.:.f.  ,Origem:ZZV:ZZF,Produto,Local ,Localiz,Quant,Docto:IdRetrab:IdNegoc,Nro.Bobina)
	EndIf

	if aRet[1]
		RecLock("SBF",.F.) // Gravo o BF_RESERVA para garantir a quantidade
		SBF->BF_EMPENHO += nQuant
		MsUnLock()

		SB1->(DbSeek(xFilial("SB1") + cProd,.F.))

		_cItBmm := Soma1(_cItBmm,,.T.) // Posso criar diversos SZBs com o mesmo número... incrementando o Item

		cNumSeq := ProxNum() // Pega o próximo número     

		//cPeso := SB1->(B1_PESPVC + B1_PESCOB)
		cPeso := SB1->B1_PESBRU

		RecLock("SZB",.T.) // Gravo o SZB
		SZB->ZB_FILIAL  := xFilial("SZB")
		SZB->ZB_DATA    := dDataBase
		SZB->ZB_NUM     := _cNumBMM
		SZB->ZB_ITBMM   := _cItBmm
		SZB->ZB_PRODUTO := SB1->B1_COD
		SZB->ZB_DESCPRO := SB1->B1_DESC
		SZB->ZB_UM      := SB1->B1_UM
		SZB->ZB_QUANT   := nQUANT
		SZB->ZB_LOCAL   := If(Empty(cTabId),cDe,"01")
		SZB->ZB_PESO    := cPeso
		SZB->ZB_ACOND   := iif(lRetrab,"B0"+cZE_TPBOB,cACond) // Somente se for bobina
		SZB->ZB_LOCALIZ := _cLocaliz
		SZB->ZB_PMEDIO  := (SZB->ZB_PESO * 100) / SZB->ZB_QUANT
		SZB->ZB_STATUS  := iif(lRetrab,"2","3") // 3-geral; (1- requi transf 2-devolução transferencia)
		SZB->ZB_COBRE   := nQuant * SB1->B1_PESCOB
		SZB->ZB_LINHA   := SB1->B1_LINHA
		MsUnLock()

		u_CriaSD3("RE4",cNumSeq) // Fazer Movimento no SD3 de Saída RE4

		/*/
		Mudei esta sequencia para cima 
		if cACond == "B" 
		SZE->(dbsetorder(1))
		if SZE->(DbSeek(xFilial("SZE") + Left(cNumBob,Len(SZE->ZE_NUMBOB)),.F.))
		SZE->(RECLOCK("SZE",.F.))
		if cDe == "01" // RETIRAR DO 01 ?
		SZE->ZE_STATUS := "N"
		else
		if cPara == "01" // DEVOLVER PARA O 01 ??
		SZE->ZE_STATUS := "T"
		endif
		endif
		SZE->(MSUNLOCK())
		endif
		endif
		/*/

		SB1->(DbSeek(xFilial("SB1") + cProd,.F.)) // reposicionar b1

		if u_CREST19(cProd, cpara, .t. ) // Verifica se tem saldo inicial (SB9) do local destino	
			SB1->(DbSeek(xFilial("SB1") + cProd,.F.)) // reposicionar b1 ;
			dbselectarea("SBE") // ajustar o endereço de destino
			SBE->(dbsetorder(1))
			if(!SBE->(dbseek( xFilial("SBE") + cPara + _cLocaliz )))
				SBE->(reclock("SBE", .T.))
				SBE->BE_FILIAL		:= xFilial("SBE")
				SBE->BE_LOCAL		:= cPara
				SBE->BE_LOCALIZ		:= _cLocaliz
				SBE->BE_DESCRIC		:= cPara + " " + _cLocaliz
				SBE->BE_PRIOR		:= "ZZZ"
				SBE->BE_STATUS		:= "1"
				SBE->BE_DATGER		:= dDatabase
				SBE->(msunlock())
			endif

			RecLock("SZB",.T.) // Gravo o SZB
			SZB->ZB_FILIAL  := xFilial("SZB")
			SZB->ZB_DATA    := dDataBase
			SZB->ZB_NUM     := _cNumBMM
			SZB->ZB_ITBMM   := _cItBmm
			SZB->ZB_PRODUTO := SB1->B1_COD
			SZB->ZB_DESCPRO := SB1->B1_DESC
			SZB->ZB_UM      := SB1->B1_UM
			SZB->ZB_QUANT   := nQUANT
			SZB->ZB_LOCAL   := cPara
			SZB->ZB_PESO    := cPeso
			SZB->ZB_ACOND   := iif(lRetrab,"B0"+cZE_TPBOB,cACond) // Somente se for bobina
			SZB->ZB_LOCALIZ := _cLocaliz
			SZB->ZB_PMEDIO  := (SZB->ZB_PESO * 100) / SZB->ZB_QUANT
			SZB->ZB_STATUS  := iif(lRetrab,"1","3")
			SZB->ZB_COBRE   := nqUANT * SB1->B1_PESCOB
			SZB->ZB_LINHA   := SB1->B1_LINHA
			MsUnLock()

			_cLocDes := cPara
			u_CriaSD3("DE4",cNumSeq) // Fazer Movimento no SD3 de Entrada DE4

			aRet := u_CREST18(cProd, cPara, cLocaliz, .T., nQUANT) // enderecar
		else
			aRet[1] := .F.
			aRet[2] := "Erro ao Gravar Saldo Inicial"
			//		aRet[2] := "Erro ao Gravar Dados -> Operação não Efetuada"
		endif
	endif 

	If !aRet[1]
		DisarmTransaction()                               '
	EndIf

	EndTran()
Return(aRET)