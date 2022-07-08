#include "rwmake.ch"
#include "TOPCONN.ch"


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDEST22                            Modulo : SIGAEST      //
//                                                                          //
//   Autor ......: Roberto Oliveira                   Data ..: 12/03/2010   //
//                                                                          //
//   Objetivo ...: Reservas Confirmadas                                     //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //

//                                                                          //
//////////////////////////////////////////////////////////////////////////////

User Function CDEST22()

	aCores    := {{"Empty(ZR_NUMBMM)"      ,"ENABLE"},;  
	{"ZR_NUMBMM == 'ERRO  '" ,"BR_AMARELO"},;  
	{"!Empty(ZR_NUMBMM)"     ,"DISABLE"}}        

	cCadastro := "Bobinas Reservadas Confirmadas"

	aRotina := {{ "Pesquisar"          , "AxPesqui"  , 0 , 1 },;
	{ "Visualizar"         , "AxVisual"  , 0 , 2 },;
	{ "Cancelar Reserva"   , "u_CanReser", 0 , 2 },;
	{ "Envio P/Retrabalho" , "U_ACReser" , 0 , 2 },;
	{ "Legenda"            , "U_CDEST22X", 0 , 2 }}

	//			{ "Incluir"            , "AxInclui"  , 0 , 3 },;

	DbSelectArea("SZR")
	DbSetOrder(1)        

	DbSeek(xFilial("SZR"),.F.)
	mBrowse(001,040,200,390,"SZR",,,,,,aCores)
	Return(.T.)
	*                       
	**********************
User Function CDEST22X
	**********************
	*
	BrwLegenda(cCadastro,"Legenda",{{"DISABLE"   ,"Já Enviado para Retrabalho"},;
	{"BR_AMARELO","Com Erro Saldo da Bobina"},;
	{"ENABLE"    ,"A Processar Envio para Retrabalho"}})
	Return(.T.)
	*
	***********************
User Function ACReser()
	***********************
	*
	If MsgBox("Processa Envio das Reservas para Retrabalho?","Confirma?","YesNo")
		_MsgRet := ""
		Processa( {|| ProcSZRb() },"Processando Reservas de Bobinas...")
		//	Processa( {|| ProcSZRr() },"Processando Reservas de Rolos/Carretéis...")
		Alert("Processamento Concluido - " +  _MsgRet )
	EndIf
	Return(.T.)
	*
	*************************
Static Function ProcSZRb() // Envia Bobinas para retrabalho
	*************************
	*       
	_lTemBMM := .F.

	DbSelectArea("SBF")
	DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

	DbSelectArea("SZB")
	DbSetOrder(1) // ZB_FILIAL+ZB_NUM

	// Acha o Nro.do ultimo BMM com R no inicio
	SZB->(DbSeek(xFilial("SZB") +"S     ",.T.))
	SZB->(DbSkip(-1))
	If Left(SZB->ZB_NUM,1) == "R"
		_cNumBMM := SZB->ZB_NUM
	Else
		_cNumBMM := "R00000"
	EndIf       
	Do While SZB->(DbSeek(xFilial("SZB")+_cNumBMM,.F.))
		_cNumBMM := Soma1(_cNumBMM)
	EndDo       
	_cItBmm := "000"

	// Acha o Nro.do ultimo "BMM" com A no inicio -> usado somente para marcar o SZR para somente troca de etiquetas
	DbSelectArea("SZR")
	DbSetOrder(3) // ZR_FILIAL+ZR_NUMBMM

	SZR->(DbSeek(xFilial("SZR") +"B     ",.T.))
	SZR->(DbSkip(-1))
	If Left(SZR->ZR_NUMBMM,1) == "A"
		_cNumTrc := SZR->ZR_NUMBMM
	Else
		_cNumTrc := "A00000"
	EndIf       
	Do While SZR->(DbSeek(xFilial("SZR")+_cNumTrc,.F.))
		_cNumTrc := Soma1(_cNumTrc)
	EndDo                                     
	_lFizTrc := .F.

	DbSelectArea("SC9")
	DbSetOrder(1) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

	DbSelectArea("SC6")
	DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	DbSelectArea("SB1")
	DbSetOrder(1) // B1_FILIAL+B1_COD

	DbSelectArea("SZR")
	DbSetOrder(1) // ZR_FILIAL+ZR_NUMBOB

	DbSelectArea("SZE")
	// DbSetOrder(4)  //ZE_FILIAL+ZE_STATUS+ZE_PRODUTO 
	DbSetOrder(1) // ZE_FILIAL+ZE_NUMBOB
	// Procurar as bobinas com status "N" reserva coNfirmada
	//
	// Atentção: Em 20/06/14 tive que alterar a lógica de envio das bobinas para retrabalho
	// porque a rotina de retrabalho (Proativa) também grava o status da bobina como 'N' e 
	// ao fazer a transferência para o armazém 90 não encontra saldo no armazém 01.
	// Então vou dar um select no banco e trazer todos os SZEs com status 'N' e tratar se
	// a reserva foi feita pela rotina que usa o SZR.
	cQuery := " SELECT ZE_NUMBOB FROM "+RetSqlName("SZE")
	cQuery += " WHERE ZE_FILIAL = '"+xFilial("SZE")+"'"
	cQuery += " AND ZE_STATUS = 'N' AND D_E_L_E_T_ <>'*'"

	cQuery := ChangeQuery(cQuery)     

	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"
	Count to nQry

	DbSelectArea("TRB")
	DbGotop()        

	// ProcRegua(LastRec())
	// Do While SZE->(DbSeek(xFilial("SZE")+"N",.F.))

	ProcRegua(nQry)
	Do While TRB->(!Eof())

		IncProc()

		// Verifico se é uma reserva "NOSSA"

		SZR->(DbSetOrder(1)) // ZR_FILIAL+ZR_NUMBOB
		If !SZR->(DbSeek(xFilial("SZR")+TRB->ZE_NUMBOB,.F.))
			TRB->(DbSkip())
			Loop
		EndIf

		// Travo o SZE para ninguém mais usar 
		// SZE->(DbSeek(xFilial("SZE")+ZE_NUMBOB,.F.))
		If !SZE->(DbSeek(xFilial("SZE")+TRB->ZE_NUMBOB,.F.))
			TRB->(DbSkip())
			Loop
		ElseIf !SZE->(RecLock("SZE",.F.))
			TRB->(DbSkip())
			Loop
		ElseIf SZE->ZE_STATUS # 'N' // Já Fizeram outra coisa com essa bobina
			SZE->(MsUnLock())
			TRB->(DbSkip())
			Loop
		EndIf

		// primeiro verifico se nÃo É somente troca de etiqueta

		DbSelectArea("SZR")
		DbSetOrder(1) // ZR_FILIAL+ZR_NUMBOB
		If DbSeek(xFilial("SZR")+SZE->ZE_NUMBOB,.F.)

			// Este If foi incluído juntamente com Felipe para que as bobinas reservadas e ainda não liberadas
			// no financeiro não sejam enviadas para efetuar o "retrabalho" -> troca de etiqueta.
			// By Roberto Oliveira 


			SC9->(DbSeek(xFilial("SC9")+SZR->ZR_PEDIDO+SZR->ZR_ITEMPV,.F.))
			// Ordem 1 do SC9  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
			_nTotSB9 := 0
			Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == SZR->ZR_PEDIDO .And. ;
			SC9->C9_ITEM == SZR->ZR_ITEMPV .And. SC9->(!Eof())
				_nTotSB9 += If(Empty(SC9->C9_BLCRED).And.SC9->C9_BLEST=="02",SC9->C9_QTDLIB,0)
				SC9->(DbSkip())
			EndDo     
			If _nTotSB9 < SZR->ZR_QTDPV
				SZE->(MsUnLock())
				TRB->(DbSkip())
				Loop
			EndIf

			SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			If SC6->(DbSeek(xFilial("SC6")+SZR->ZR_PEDIDO+SZR->ZR_ITEMPV+SZR->ZR_PRODUTO,.F.))
				// Deixar a chave completa pois já ocorreu de terem alterado o produto sem alterar a reserva
				// e assim o DbSeek cai em EOF() e é tratado no ELSE abaixo
				If SZE->ZE_QUANT == SC6->C6_METRAGE // Só trocar etiqueta
					If Empty(SZR->ZR_NUMBMM) .Or. "ERRO" $ SZR->ZR_NUMBMM
						RecLock("SZR",.F.)
						SZR->ZR_NUMBMM := _cNumTrc
						SZR->(MsUnLock())
						_lFizTrc := .T.
					EndIf
					DbSelectArea("SZE")
					SZE->ZE_STATUS := "n" //Não posso cancelar a bobina senÃo a balanca nao aceita a troca de etiqueta
					MsUnLock()          
					TRB->(DbSkip())
					Loop
				EndIf
			Else
				// Já aconteceu que foi exluído o item e não foi cancelada a reserva
				// SZE->ZE_STATUS := "#"  // Troco o STATUS devido a condição do DO WHILE acima
				SZE->(MsUnLock())
				TRB->(DbSkip())
				Loop
			EndIf
		EndIf

		_cLocaliz := Left("B"+StrZero(SZE->ZE_QUANT,5)+Space(40),Len(SBE->BE_LOCALIZ))

		DbSelectArea("SBF") //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		DbSeek(xFilial("SBF")+"01"+_cLocaliz+SZE->ZE_PRODUTO,.F.)
		If SBF->(Eof()) .Or. (SBF->BF_QUANT - SBF->BF_EMPENHO) < SZE->ZE_QUANT .Or. SBF->BF_EMPENHO < 0

			DbSelectArea("SZR")
			DbSetOrder(1) // ZR_FILIAL+ZR_NUMBOB
			DbSeek(xFilial("SZR")+SZE->ZE_NUMBOB,.F.)
			Do While SZR->ZR_FILIAL == xFilial("SZR") .And. SZR->ZR_NUMBOB == SZE->ZE_NUMBOB .And. SZR->(!Eof())
				RecLock("SZR",.F.)
				SZR->ZR_NUMBMM := "ERRO  "
				MsUnLock()
				SZR->(DbSkip())
			EndDo

			//RecLock("SZE",.F.) // SZE já está travado
			// SZE->ZE_STATUS := "#"
			SZE->(MsUnLock())
			TRB->(DbSkip())
			Loop
		EndIf                                           

		// Gravo o BF_RESERVA para garantir a quantidade
		RecLock("SBF",.F.)
		SBF->BF_EMPENHO += SZE->ZE_QUANT
		MsUnLock()

		SB1->(DbSeek(xFilial("SB1")+SZE->ZE_PRODUTO,.F.))

		_cItBmm := Soma1(_cItBmm,,.T.)

		// Gravo o SZB
		RecLock("SZB",.T.)
		SZB->ZB_FILIAL  := xFilial("SZB")
		SZB->ZB_DATA    := dDataBase
		SZB->ZB_NUM     := _cNumBMM
		SZB->ZB_ITBMM   := _cItBmm
		SZB->ZB_PRODUTO := SZE->ZE_PRODUTO
		SZB->ZB_DESCPRO := SZE->ZE_DESCPRO
		SZB->ZB_UM      := SB1->B1_UM
		SZB->ZB_QUANT   := SZE->ZE_QUANT
		SZB->ZB_LOCAL   := "01"         
		SZB->ZB_PESO    := SZE->ZE_PLIQ
		SZB->ZB_ACOND   := "B0"+SZE->ZE_TPBOB
		SZB->ZB_LOCALIZ := _cLocaliz
		SZB->ZB_PMEDIO  := (SZB->ZB_PESO*100)/SZB->ZB_QUANT
		SZB->ZB_STATUS  := "1"
		SZB->ZB_COBRE   := SZB->ZB_QUANT*SB1->B1_PESCOB
		SZB->ZB_LINHA   := SB1->B1_LINHA
		MsUnLock()

		If !_lTemBMM
			_lTemBMM := .T.
			_MsgRet := "Criado BMM " +  _cNumBMM + " para Bobinas"
		EndIf

		DbSelectArea("SZR")
		DbSetOrder(1) // ZR_FILIAL+ZR_NUMBOB
		DbSeek(xFilial("SZR")+SZE->ZE_NUMBOB,.F.)
		Do While SZR->ZR_FILIAL == xFilial("SZR") .And. SZR->ZR_NUMBOB == SZE->ZE_NUMBOB .And. SZR->(!Eof())
			RecLock("SZR",.F.)
			SZR->ZR_NUMBMM := _cNumBMM
			SZR->ZR_ITBMM  := _cItBmm
			MsUnLock()
			SZR->(DbSkip())
		EndDo

		cNumSeq := ProxNum()

		// Fazer Movimento no SD3 de Saída RE4
		u_CriaSD3("RE4",cNumSeq) // 

		// Fazer Movimento no SD3 de Entrada DE4
		u_CriaSD3("DE4",cNumSeq)
		/*/ 

		// Grava movimento de requisição no SD3
		u_GraveD3Rt("523")
		/*/

		DbSelectArea("SZE")
		RecLock("SZE",.F.) // SZE já está travado
		SZE->ZE_STATUS := "C"
		MsUnLock()

		TRB->(DbSkip())
	EndDo

	Do While SZE->(DbSeek(xFilial("SZE")+"n",.F.))
		RecLock("SZE",.F.)
		SZE->ZE_STATUS := "N"
		MsUnLock()          
	EndDo

	DbSelectArea("TRB")
	DbCloseArea()

	If !_lTemBMM
		_MsgRet := "Nenhum BMM Criado!!!"
	EndIf  
	If _lFizTrc
		_MsgRet += Chr(13) +  Chr(13) + "BMM de troca Nro. " + _cNumTrc
	EndIf
	Return(_MsgRet)
	*
	*************************
User Function CanReser()
	*************************
	*                                                                         
	If !Empty(SZR->ZR_NUMBMM)
		Alert("Reserva não pode ser cancelada - Já processada")
		Return(.T.)
	EndIf   
	If !Empty(SZR->ZR_NUMBOB)
		If MsgBox("Confirma o Cancelamento da Reserva da Bobina " + SZR->ZR_NUMBOB,"Confirma?","YesNo")
			DbSelectArea("SC6")
			DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

			DbSelectArea("SZE")
			DbSetOrder(1) // ZE_FILIAL+ZE_NUMBOB

			DbSelectArea("SZR")
			DbSetOrder(1) // ZR_FILIAL+ZR_NUMBOB
			_ZR_NUMBOB := SZR->ZR_NUMBOB
			If SZR->(DbSeek(xFilial("SZR")+_ZR_NUMBOB,.F.))
				If SZE->(DbSeek(xFilial("SZE")+SZR->ZR_NUMBOB,.F.))
					If SZE->ZE_STATUS == "N"
						RecLock("SZE",.F.)  
						SZE->ZE_STATUS := "T" // Volta para em estoque
						MsUnLock()
					EndIf
				EndIf
			EndIf
			Do While SZR->ZR_FILIAL == xFilial("SZR") .And. SZR->ZR_NUMBOB == _ZR_NUMBOB .And. SZR->(!Eof())
				If SC6->(DbSeek(xFilial("SC6")+SZR->ZR_PEDIDO+SZR->ZR_ITEMPV,.F.))
					If SC6->C6_QTDRES >= SZR->ZR_QTDPV
						RecLock("SC6",.F.)            
						SC6->C6_QTDRES := Max((SC6->C6_QTDRES - SZR->ZR_QTDPV),0)
						If SC6->C6_QTDRES == 0 .And. Alltrim(SC6->C6_SEMANA) $ "RESERVA//ZP4"
							SC6->C6_SEMANA := "       "
						EndIf
						MsUnLock()
					EndIf
				EndIf
				DbSelectArea("SZR")
				RecLock("SZR",.F.)
				DbDelete()
				MsUnLock()
				SZR->(DbSkip())
			EndDo
			DbSelectArea("SC0")                                      
			DBOrderNickName("SC0NUMBOB") // C0_FILIAL+C0_NUMBOB
			Do While SC0->(DbSeek(xFilial("SC0")+_ZR_NUMBOB,.F.))
				u_EmpReser(.F.) // Cancela a reserva
				DbSelectArea("SC0")                                      
				DBOrderNickName("SC0NUMBOB")
			EndDo
		EndIf
	Else // Não é Bobina
		If MsgBox("Confirma o Cancelamento da Reserva ?","Confirma?","YesNo")
			DbSelectArea("SC6")
			DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

			If SC6->(DbSeek(xFilial("SC6")+SZR->ZR_PEDIDO+SZR->ZR_ITEMPV,.F.))
				If SC6->C6_QTDRES >= SZR->ZR_QTDPV
					RecLock("SC6",.F.)            
					SC6->C6_QTDRES := Max((SC6->C6_QTDRES - SZR->ZR_QTDPV),0)
					If SC6->C6_QTDRES == 0 .And. Alltrim(SC6->C6_SEMANA) $ "RESERVA//ZP4"
						SC6->C6_SEMANA := "       "
					EndIf
					MsUnLock()
				EndIf

				DbSelectArea("SZR")
				RecLock("SZR",.F.)
				DbDelete()
				MsUnLock()
				SZR->(DbSkip())
			EndIf
		EndIf
	EndIf
	DbSelectArea("SZR")
	Return(.T.)
	*
	*************************
Static Function ProcSZRr() // Envia Rolos/Bobinas para retrabalho
	*************************
	*       
	_lTemBMM := .F.
	_lFizTrc := .F.

	DbSelectArea("SBF")
	DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

	DbSelectArea("SZB")
	DbSetOrder(1) // ZB_FILIAL+ZB_NUM

	// Acha o Nro.do ultimo BMM com R no inicio
	SZB->(DbSeek(xFilial("SZB") +"S     ",.T.))
	SZB->(DbSkip(-1))
	If Left(SZB->ZB_NUM,1) == "R"
		_cNumBMM := SZB->ZB_NUM
	Else
		_cNumBMM := "R00000"
	EndIf       
	Do While SZB->(DbSeek(xFilial("SZB")+_cNumBMM,.F.))
		_cNumBMM := Soma1(_cNumBMM)
	EndDo       
	_cItBmm := "000"

	DbSelectArea("SC6")
	DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	DbSelectArea("SB1")
	DbSetOrder(1) // B1_FILIAL+B1_COD

	DbSelectArea("SZE")
	DbSetOrder(4)  //ZE_FILIAL+ZE_STATUS+ZE_PRODUTO
	// Procurar as bobinas com status "N" reserva coNfirmada
	ProcRegua(LastRec())
	Do While SZE->(DbSeek(xFilial("SZE")+"N",.F.))

		IncProc()

		// Travo o SZE para ninguém mais usar 

		If !RecLock("SZE",.F.)
			Loop
		EndIf

		// primeiro verifico se nÃo É somente troca de etiqueta


		_cLocaliz := Left("B"+StrZero(SZE->ZE_QUANT,5)+Space(40),Len(SBE->BE_LOCALIZ))

		DbSelectArea("SBF") //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		DbSeek(xFilial("SBF")+"01"+_cLocaliz+SZE->ZE_PRODUTO,.F.)
		If SBF->(Eof()) .Or. (SBF->BF_QUANT - SBF->BF_EMPENHO) < SZE->ZE_QUANT .Or. SBF->BF_EMPENHO < 0

			DbSelectArea("SZR")
			DbSetOrder(1) // ZR_FILIAL+ZR_NUMBOB
			DbSeek(xFilial("SZR")+SZE->ZE_NUMBOB,.F.)
			Do While SZR->ZR_FILIAL == xFilial("SZR") .And. SZR->ZR_NUMBOB == SZE->ZE_NUMBOB .And. SZR->(!Eof())
				RecLock("SZR",.F.)
				SZR->ZR_NUMBMM := "ERRO  "
				MsUnLock()
				SZR->(DbSkip())
			EndDo

			//RecLock("SZE",.F.) // SZE já está travado
			SZE->ZE_STATUS := "#"
			MsUnLock()

			Loop
		EndIf                                           

		// Gravo o BF_RESERVA para garantir a quantidade
		RecLock("SBF",.F.)
		SBF->BF_EMPENHO += SZE->ZE_QUANT
		MsUnLock()

		SB1->(DbSeek(xFilial("SB1")+SZE->ZE_PRODUTO,.F.))

		_cItBmm := Soma1(_cItBmm,,.T.)

		// Gravo o SZB
		RecLock("SZB",.T.)
		SZB->ZB_FILIAL  := xFilial("SZB")
		SZB->ZB_DATA    := dDataBase
		SZB->ZB_NUM     := _cNumBMM
		SZB->ZB_ITBMM   := _cItBmm
		SZB->ZB_PRODUTO := SZE->ZE_PRODUTO
		SZB->ZB_DESCPRO := SZE->ZE_DESCPRO
		SZB->ZB_UM      := SB1->B1_UM
		SZB->ZB_QUANT   := SZE->ZE_QUANT
		SZB->ZB_LOCAL   := "01"         
		SZB->ZB_PESO    := SZE->ZE_PLIQ
		SZB->ZB_ACOND   := "B0"+SZE->ZE_TPBOB
		SZB->ZB_LOCALIZ := _cLocaliz
		SZB->ZB_PMEDIO  := (SZB->ZB_PESO*100)/SZB->ZB_QUANT
		SZB->ZB_STATUS  := "1"
		SZB->ZB_COBRE   := SZB->ZB_QUANT*SB1->B1_PESCOB
		SZB->ZB_LINHA   := SB1->B1_LINHA
		MsUnLock()

		If !_lTemBMM
			_lTemBMM := .T.
			If !Empty(_MsgRet)
				_MsgRet += Chr(13) +  Chr(13)
			EndIf
			_MsgRet += "Criado BMM " +  _cNumBMM + " para Rolos"
		EndIf

		DbSelectArea("SZR")
		DbSetOrder(1) // ZR_FILIAL+ZR_NUMBOB
		DbSeek(xFilial("SZR")+SZE->ZE_NUMBOB,.F.)
		Do While SZR->ZR_FILIAL == xFilial("SZR") .And. SZR->ZR_NUMBOB == SZE->ZE_NUMBOB .And. SZR->(!Eof())
			RecLock("SZR",.F.)
			SZR->ZR_NUMBMM := _cNumBMM
			SZR->ZR_ITBMM  := _cItBmm
			MsUnLock()
			SZR->(DbSkip())
		EndDo

		/*/
		cNumSeq := ProxNum()

		// Fazer Movimento no SD3 de Saída RE4
		u_CriaSD3("RE4",cNumSeq) // 

		// Fazer Movimento no SD3 de Entrada DE4
		u_CriaSD3("DE4",cNumSeq)
		/*/

		u_GraveD3Rt("523")

		DbSelectArea("SZE")
		RecLock("SZE",.F.) // SZE já está travado
		SZE->ZE_STATUS := "C"
		MsUnLock()          
	EndDo

	Do While SZE->(DbSeek(xFilial("SZE")+"#",.F.))
		RecLock("SZE",.F.)
		SZE->ZE_STATUS := "N"
		MsUnLock()          
	EndDo
	//If !_lTemBMM
	//	_MsgRet := "Nenhum BMM Criado!!!"
	//EndIf  
	If _lFizTrc
		_MsgRet += Chr(13) +  Chr(13) + "BMM de troca Nro. " + _cNumTrc
	EndIf
Return(_MsgRet)