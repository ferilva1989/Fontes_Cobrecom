#include 'totvs.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

#Define linha chr(13)+chr(10)

/*/{Protheus.doc} CSFatur
//TODO Realiza Faturamento Personalizado.
@author z
@since 01/01/2006
@version undefined

@type function
/*/
User Function CSFatur()
Local nFatRet, nFatAva
Private _cFiltro
Private cNomTrb
Private cNomTrb1
Private cNomTrb2
Private cNomTrb0
Private cNomTrb01
	
	
	_UlMes := GetMv("MV_ULMES")
	nFatRet := GetMv("ZZ_RETFAT")//Dias liberados para Retroceder database do Faturamento
	nFatAva := GetMv("ZZ_AVAFAT")//Dias liberados para Avancar database do Faturamento
	
	If dDataBase <= _UlMes
		Alert("Data Anterior ao Último Fechamento do Estoque")
		Return(.T.)
	EndIf

	_nDias := Date()-dDataBase

	If _nDias > nFatRet .Or. _nDias < nFatAva
		Alert("Não é possível Processar Notas fiscais com a data de " + DtoC(dDataBase))
		Return(.T.)
	EndIf

	DbSelectArea("SC9")
	DbSetOrder(1)
	
	DbSelectArea("SA4")
	DbSetOrder(1)

	DbSelectArea("SA2")
	DbSetOrder(1)
	
	DbSelectArea("SA1")
	DbSetOrder(1)	

	MV_xPAR01 := 0
	MV_xPAR02 := ' '
	MV_xPAR03 := ' '
	MV_xPAR04 := ' '
	MV_xPAR05 := ' '
	MV_xPAR06 := ' '
	MV_xPAR07 := ' '
	MV_xPAR08 := 0
	MV_xPAR09 := 0
	_lNewBrow := .T.

	Pergunte("MT460A",.T.)
	cCadastro:="Seleção dos Itens para Faturamento      (" + cFilAnt + " - " + Alltrim(FWFilialName('01',cFilAnt)) + ")"
	aRotina := {{ "Parâmetros","U_BackPar"  , 0 , 2},;
				{ "Lib.Risco" ,"U_LibFat"   , 0 , 2},;
				{ "Fechar"    ,"U_FecharFt(.F.)" , 0 , 2}}
	
	cPerg := "CDFT04"
	ValidPerg()

	Do While _lNewBrow
		_lNewBrow := .F.
		cPerg := "CDFT04"
	
		If !u_ParFat()
			Exit
			//		Return(.T.)
		EndIf
	
		lInverte:=.F.
		cMarca := GetMark()
		cMarca := Left(cMarca+Space(Len(SC9->C9_OK)),Len(SC9->C9_OK))
		_lCom := .F.
		If _lCom
			MarkBrow("SC9"  ,"C9_OK","SC9->C9_BLEST+SC9->C9_BLCRED+SC9->C9_RISCO",        ,@lInverte,@cMarca,,,,,"u_DesMark()")
		Else
			MarkBrow("SC9"  ,"C9_OK","SC9->C9_BLEST+SC9->C9_BLCRED+SC9->C9_RISCO",        ,@lInverte,@cMarca)
		EndIf
	EndDo
	
	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea("TRB")
		Delete File(cNomTrb+".*")
		Delete File(cNomTrb1+".*")
		Delete File(cNomTrb2+".*")
	EndIf

	If Select("TRB0") > 0
		DbSelectArea("TRB0")
		DbCloseArea("TRB0")
		Delete File(cNomTrb0+".*")
		Delete File(cNomTrb01+".*")
	EndIf

	dbSelectArea("SC9")
	Set Filter to
	dbSetOrder(1)
	
	if InTransaction()
		MsgAlert('TRANSAÇÃO AINDA EM ABERTO!!!','ERRO DE TRANSAÇÃO')
	endif	
Return(.t.)


/*/{Protheus.doc} FecharFt
//TODO Realiza a montagem da NFe.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
User Function FecharFt(lNewPar)
	Private _aCondFt 	:= {} // {Nro.Pedido,Cond.Pagto}
	private lNewFatur 	:= .F.
	default lNewPar		:= .F.

	lNewFatur := lNewPar
// Lock do Semáforo Cobrecom	
	if !u_prxCanOp('FAT', 'EMP')
		Alert("Rotina de Empenho em uso! Aguarde!")
		Return(.T.)
	endif

	//If MsgYesNo("Confirma Processamento da(s) Nota(s) Fiscal(is) ?")
		DbSelectArea("SC9")
		DbSetOrder(1)
		Set Filter to
		If !Empty(_cFiltro)
			Set Filter to &(_cFiltro)
		EndIf
		_cBadPed  := "" // Pedidos que não podem ser faturados
		_cTemDesc := ""
		if !lNewFatur
			nQuantR   := 0
			Processa( {|| PoeMrk() },"Selecionando Registros...")
		endif
		If nQuantR > 0
			Do While .T.
				_cBadPed2 := "" // Pedidos que não podem ser faturados
				_aPedBob  := {} // {Pedido+item,Quant.SDC,Quant.SZE,Peso Liq SZE,Tara SZE,Quant.Faturando Agora}
				Processa( {|| ArruPed()  },"Ajustando Pedidos...")
				If !Empty(_cBadPed2) // Pedidos que não podem ser faturados
					Exit
				elseif !lNewFatur
					if MsgYesNo("Todas as Alterações Estão Corretas?")
						Exit
					endif
				else
					Exit
				EndIf
			EndDo
			if !lNewFatur
				_cSerEsc := "   "
			endif
			If !Empty(_cBadPed2) // Pedidos que não podem ser faturados
				_lRet    := .F.
				Alert(If(Len(_cBadPed2)>8,"Não Selecionar os Pedidos -> ","Não Selecionar o Pedido -> ")+ _cBadPed2)
			ElseIf "1" $ _cTemDesc .And. MV_xPAR08 == 1
				_lRet    := .F.
				Alert("Não Usar Desconto de Descarregamento Com Notas Aglutinadas")
			ElseIf "2" $ _cTemDesc
				_lRet    := .F.
				Alert("Não Usar Desconto de Descarregamento Com Romaneios")
			Else
				_lRet    := .T.
			EndIf
			Do While Empty(_cSerEsc) .And. _lRet
				cSerie  := ""
				_lRet   := Sx5NumNota(@cSerie,)
				If !_lRet
					Exit
				ElseIf !cSerie $ "UNI/1  /UM "
					If MsgYesNo("Utiliza a Série '" + cSerie + "' para o Processamento Dessas Notas?")
						_cSerEsc := cSerie
					EndIf
				Else
					_cSerEsc := cSerie
				EndIf
			EndDo
			If _lRet
				Processa( {|| JuntaC9()  },"Ajustando Tabela...")
				// Garante que tenha somente UM SC9 com quantidade total para cada acondicionamento.
	
				Processa( {|| AjustaNI() },"Ajustando Tabela...")
	
				If _lRet
					Processa( {|| AjustaC9() },"Ajustando Tabela...")
				EndIf
				If _lRet
					If MV_xPAR08 == 1
						Processa( {|| MontaNFa()},"Gerando Notas Fiscais...")
					Else
						Processa( {|| MontaNF() },"Gerando Notas Fiscais...")
					EndIf
				EndIf
				DbSelectArea("SC9")
				DbSetOrder(1)
				DbSeek(xFilial("SC9"),.F.)
			EndIf
		Endif
		// Retorna a cond.Pagamento original caso tenha sido trocada
		DbSelectArea("SC5")
		DbSetOrder(1)
		For _nCtdCnd := 1 to Len(_aCondFt)
			If DbSeek(xFilial("SC5")+_aCondFt[_nCtdCnd,1],.F.)
				If SC5->C5_CONDPAG # _aCondFt[_nCtdCnd,2]
					RecLock("SC5",.F.)
					SC5->C5_CONDPAG := _aCondFt[_nCtdCnd,2]
					MsUnLock()
				EndIf
			EndIf
		Next
		CloseBrowse()
		_lNewBrow := .T.
	//Endif
	
	// UnLock do Semáforo Cobrecom	
	u_prxCanCl('FAT')	
Return(.T.)


/*/{Protheus.doc} PoeMrk
//TODO Gera MarkBrow para seleção dos pedidos para faturar.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
Static Function PoeMrk() //OK 09/10
	Local cDiaFat 	:= StrZero(Day(dDataBase),2)
	Local cPerFat		:= ""
	local aOperRes	:= {}
	_DtVld := dDataBase-1
	For _nDU := 1 to 5  // Adicionar 5 dias uteis
		_DtVld++
		_DtVld := DataValida(_DtVld)
	Next
	
	_cPedVisto := ""
	DbSelectArea("SC9")
	DbSetOrder(1)
	DbSeek(xFilial("SC9")+MV_xPAR02,.T.)
	
	cPerFat	:= Alltrim(Posicione("SA1",1,xFilial("SA1")+SC9->C9_CLIENTE+SC9->C9_LOJA,"A1_ZZPRFAT"))
	
	ProcRegua(LastRec())
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO <= MV_xPAR03 .And. SC9->(!Eof())
		IncProc()
		_lib := Marked("C9_OK")
	
		If !(SC9->C9_PEDIDO $ _cPedVisto) .And. _lib
			_cPedVisto := _cPedVisto + "//" + SC9->C9_PEDIDO
			_DtFat   := Posicione("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,"C5_DTFAT")
			
			dumbAlerts( SC9->(C9_PEDIDO + C9_ITEM), @aOperRes )
			/*
			05/07/2016
			Realizado ajuste conforme solicitação Jeferson/Andreia/Juliana_ven
			Juliana Leme
			*/
			If SC5->C5_ZZBLVEN == "S"
				If !Empty(SC5->C5_VEND1)
					SA3->(DbSetOrder(1))  // A3_FILIAL+A3_COD
					If SA3->(DbSeek(xFilial("SA3")+SC5->C5_VEND1,.F.))
						If !Empty(SA3->A3_SUPER)
							If SA3->(DbSeek(xFilial("SA3")+SA3->A3_SUPER,.F.))
								Alert("Pedido " + SC9->C9_PEDIDO + " BLOQUEADO pelo COMERCIAL para faturamento!")
								Alert("Solicitar ao Assistente " + AllTrim(SA3->A3_NOME) + " responsavel por este faturamento")
							EndIf
						Else
							Alert("Pedido " + SC9->C9_PEDIDO + " BLOQUEADO pelo COMERCIAL para faturamento!")
						EndIf
					Else
						Alert("Pedido " + SC9->C9_PEDIDO + " BLOQUEADO pelo COMERCIAL para faturamento!")
					EndIf
				Else
					Alert("Pedido " + SC9->C9_PEDIDO + " BLOQUEADO pelo COMERCIAL para faturamento!")
				EndIf
				_cBadPed := _cBadPed + "//" + SC9->C9_PEDIDO
			EndIf
	
			If ! Empty(cPerFat) .and. !(cDiaFat $ cPerFat)
				Alert("Pedido " + SC9->C9_PEDIDO + " NÃO LIBERADO para faturamento nesta data conforme regra estabelecida no cadastro do cliente.")
				_cBadPed := _cBadPed + "//" + SC9->C9_PEDIDO
			EndIf
			/* Fim Ajuste */
	
			If SC9->C9_PEDIDO $ GetMv("MV_XPEDIN1") .Or. SC9->C9_PEDIDO $ GetMv("MV_XPEDIN2")
				If SC9->C9_FILIAL == "01"
					Alert("Não efetuar o retorno dessa industrialização. O pedido original deve ser faturado por Itu")
				Else
					Alert("Pedido " + SC9->C9_PEDIDO + " não poderá ser faturado. Deve ser faturado por Itu")
				EndIf
				_cBadPed := _cBadPed + "//" + SC9->C9_PEDIDO
			ElseIf dDataBase < _DtFat
				Alert("Pedido " + SC9->C9_PEDIDO + " não será faturado antes de " + Dtoc(_DtFat))
				_cBadPed := _cBadPed + "//" + SC9->C9_PEDIDO
			ElseIf Date() >= Ctod("09/01/2012") .And. FWCodEmp()+FWCodFil() == "0101" // Somente a partir de 01/01/2012 e em Itu
				DbSelectArea("SC5")
				DbSetOrder(1)
				DbSeek(xFilial("SC5")+SC9->C9_PEDIDO,.F.)
				If SC5->C5_ZSTATUS # "2" .and. SC9->C9_LOCAL <> "04" .and. !(Substr(SC9->C9_PRODUTO,1,2) = "SC") 
					If SC5->C5_TIPO == "N"
						//Se movimenta estoque e financeiro
						SC6->(DbsetOrder(1))
						SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.))
						_cMyTES := If(Empty(SC6->C6_TESORI),SC6->C6_TES,SC6->C6_TESORI)
						If Upper(Posicione("SF4",1,xFilial("SF4")+_cMyTES,"F4_ESTOQUE+F4_DUPLIC")) == "SS"
							Alert("Pedido " + SC9->C9_PEDIDO + " não habilitado para faturamento")
							_cBadPed := _cBadPed + "//" + SC9->C9_PEDIDO
						EndIf
					EndIf
				Else
					//	Adiciona o pedido e sua cond.pagto para depois retornar
					Aadd(_aCondFt,{SC5->C5_NUM,SC5->C5_CONDPAG}) // {Nro.Pedido,Cond.Pagto}
				EndIf
			EndIf
		EndIf
		//	If Empty(SC9->C9_BLCRED+SC9->C9_BLEST+SC9->C9_RISCO) .And. Marked("C9_OK") .And. !(SC9->C9_PEDIDO $ _cBadPed)
		If Empty(SC9->C9_BLCRED+SC9->C9_BLEST+SC9->C9_RISCO) .And. _lib .And. !(SC9->C9_PEDIDO $ _cBadPed)
			RecLock("SC9",.F.)
			SC9->C9_OK := cMarca
			MsUnLock()
			nQuantR++
		Else
			RecLock("SC9",.F.)
			SC9->C9_OK := "  "
			MsUnLock()
		EndIf
		SC9->(DbSkip())
	EndDo
	dumbAlerts( '', @aOperRes, .T. )
Return(.T.)


/*/{Protheus.doc} AjustaC9
//TODO Ajusta tabela SC9 conforme solicitação de Faturamento.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
Static Function AjustaC9()
	
	If Select("TRB0") > 0
		DbSelectArea("TRB0")
		Zap
	Else
		aStruTrb := {}
		aTam := TamSX3("C9_PEDIDO")
		AADD(aStruTrb,{"C9PEDIDO","C",aTam[1],aTam[2] } )
	
		aTam := TamSX3("C9_ITEM")
		AADD(aStruTrb,{"C9ITEM","C",aTam[1],aTam[2] } )
	
		aTam := TamSX3("C9_AGREG")
		AADD(aStruTrb,{ "C9AGREG","C",aTam[1],aTam[2] } )
	
		aTam := TamSX3("C9_LOCAL")
		AADD(aStruTrb,{"C9LOCAL","C",aTam[1],aTam[2] } )
	
		aTam := TamSX3("DC_LOCALIZ")
		AADD(aStruTrb,{ "DCLOCALIZ","C",aTam[1],aTam[2] } )
	
		aTam := TamSX3("DC_QUANT")
		AADD(aStruTrb,{ "DCQUANT","N",aTam[1],aTam[2] } )
	
		aTam := TamSX3("C9_QTDLIB")
		AADD(aStruTrb,{"C9QTDLIB","N",aTam[1],aTam[2] } )
	
		AADD(aStruTrb,{"QTDLIB2","N",aTam[1],aTam[2] } )
	
		AADD(aStruTrb,{ "C9NUMREG","N",10,0 } )
	
		AADD(aStruTrb,{ "PRIM","C",1,0 } )
		// Este campo serve somente para identificar os primeiros C9's encontrados
		// pois os mesmos devem ser tratados por último - o "S" vem depois do "N"
	
		cNomTrb0 := CriaTrab(aStruTrb)
		dbUseArea(.T.,,cNomTrb0,"TRB0",.F.,.F.) // Abre o arquivo de forma exclusiva
	
		cOrdem  :='C9PEDIDO+C9ITEM+C9AGREG+C9LOCAL+DCLOCALIZ+PRIM'
	
		cNomTrb01 := Subs(cNomTrb0,1,7)+"A"
		IndRegua("TRB0",cNomTrb01,cOrdem,,,OemToAnsi("Selecionando Registros..."))
		DbSetOrder(1)
	EndIf
	
	// Le o C9 marcado e carrega o TRB0
	DbSelectArea("SDC")
	DbSetOrder(1)  //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
	
	DbSelectArea("SC9")
	DBOrderNickName("SC9ITEM")
	//DbSetOrder(9) // FILIAL+OK+PEDIDO+ITEM
	DbSeek(xFilial("SC9")+cMarca,.T.)
	ProcRegua(nQuantR)
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_OK == cMarca .And. SC9->(!Eof())
		IncProc()
		If !Empty(SC9->C9_BLEST+SC9->C9_BLCRED)
			SC9->(DbSkip())
			Loop
		EndIf
	
		SDC->(DbSetOrder(1))  //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
		SDC->(DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.F.))
		_cLocaliz := If(SDC->(Found()),SDC->DC_LOCALIZ,Space(Len(SDC->DC_LOCALIZ)))
		_nDcQtd   := If(SDC->(Found()),SDC->DC_QUANT,0.00)
		_nQTDLIB  := SC9->C9_QTDLIB
	
		If TRB0->(DbSeek(SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_AGREG+SC9->C9_LOCAL+_cLocaliz+"S",.F.))
			//Ordem do TRB 'C9PEDIDO+C9ITEM+C9AGREG+C9LOCAL+DCLOCALIZ+PRIM'
			RecLock("TRB0",.F.)
			TRB0->QTDLIB2 := TRB0->QTDLIB2 + _nQTDLIB
			TRB0->DCQUANT := TRB0->DCQUANT + _nDcQtd // Quanto tem empenhado no SDC nesse pedido+item+sequen
			MsUnLock()
			_nQTDLIB := 0
		EndIf
	
		RecLock("TRB0",.T.)
		TRB0->C9PEDIDO  := SC9->C9_PEDIDO
		TRB0->C9ITEM    := SC9->C9_ITEM
		TRB0->C9AGREG   := SC9->C9_AGREG
		TRB0->C9LOCAL   := SC9->C9_LOCAL
		TRB0->DCLOCALIZ := _cLocaliz
		TRB0->PRIM      := If(_nQTDLIB>0,"S","N")
		TRB0->C9QTDLIB  := SC9->C9_QTDLIB
		TRB0->QTDLIB2   := _nQTDLIB
		TRB0->DCQUANT   := _nDcQtd
		TRB0->C9NUMREG  := SC9->(Recno())
		MsUnLock()
	
		DbSelectArea("SC9")
		SC9->(DbSkip())
	EndDo
	
	// Por medida de segurança vou verificar se tem saldo nas respectivas localizações
	// O sistema está em alguns casos usando o saldo de outras localizações e não as liberadas
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SBF")
	DbSetOrder(1)
	
	Dbselectarea("SF4")
	DbsetOrder(1)
	
	Dbselectarea("SC6")
	DbsetOrder(1)
	
	_cErros := "  " // Tem que ser dois espaços
	
	DbSelectArea("TRB0")
	DbSetOrder(1) // C9PEDIDO + C9ITEM + C9AGREG + C9LOCAL + DCLOCALIZ + PRIM
	ProcRegua(LastRec())
	DbGoTop()
	Do While TRB0->(!Eof())
		IncProc()
		If TRB0->PRIM == "S" // É o primeiro?
			SC6->(DbSeek(xFilial("SC6")+TRB0->C9PEDIDO+TRB0->C9ITEM,.F.))
			SF4->(DbSeek(xFilial("SF4")+SC6->C6_TESORI,.F.))
			SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.))
	
			If SF4->F4_ESTOQUE == "S" .And. SB1->B1_LOCALIZ == "S"
				If TRB0->QTDLIB2 #	TRB0->DCQUANT  // A quantidade do SC9 tem que ser igual a _nDcQtd
					If Empty(Left(_cErros,1))
						_cErros := "X" + Right(_cErros,1)
					EndIf
				ElseIf Empty(Right(_cErros,1)) // Verifica se tem saldo
					If !SBF->(DbSeek(xFilial("SBF")+TRB0->C9LOCAL+TRB0->DCLOCALIZ+SC6->C6_PRODUTO,.F.))
						_cErros := Left(_cErros,1) + "X"
					ElseIf SBF->BF_QUANT < TRB0->DCQUANT
						_cErros := Left(_cErros,1) + "X"
					EndIf
				EndIf
			EndIf
			If !Empty(_cErros)
				Exit
			EndIf
		EndIf
		DbSelectArea("TRB0")
		TRB0->(DbSkip())
	EndDo
	
	If !Empty(_cErros)
		_lRet := .F.
		MsgStop( 'Erro nos Saldos dos Produtos' )
		Return(.F.)
	EndIf
	
	// Le o arquivo TRB0 e trata os dados
	
	DbSelectArea("TRB0")
	DbSetOrder(1) // C9PEDIDO+C9ITEM+C9AGREG+C9LOCAL+DCLOCALIZ+PRIM
	ProcRegua(LastRec())
	DbGoTop()
	Do While TRB0->(!Eof())
		IncProc()
		If  TRB0->QTDLIB2 == 0.00 .Or. TRB0->QTDLIB2 > TRB0->C9QTDLIB
			SC9->(DbGoTo(TRB0->C9NUMREG))
			//            1,             2,             3,            4,              5,             6,           7,             8,9,10,11, 12
			U_CDLibEst("E",SC9->C9_PRODUTO,SC9->C9_QTDLIB,SC9->C9_LOCAL,TRB0->DCLOCALIZ,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN, ,  ,  ,.T.)
	
			SC9->(DbGoTo(TRB0->C9NUMREG))
			RecLock("SC9",.F.)
			If  TRB0->QTDLIB2 > TRB0->C9QTDLIB
				// Altero quantidades e libero de novo
				SC9->C9_QTDLIB := TRB0->QTDLIB2
				MsUnLock()
				// Atenção: O 11ro parâmetro deve ser diferente em cada chamada da função CDLibEst para poder
				// identificar a origem da liberação. Esta informação será gravada no campo DC_TPLIB.
				// Incluir este comentário em todas as chamadas da função quando for LIBERAÇÃO.
	
				//PODE SER
				//           1,              2,             3,            4,              5,             6,           7,             8,9,10, 11, 12
				U_CDLibEst("L",SC9->C9_PRODUTO,SC9->C9_QTDLIB,SC9->C9_LOCAL,TRB0->DCLOCALIZ,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN, ,  ,"7",.T.)
				// EDVAR  U_CDLibEst("L",SC9->C9_PRODUTO,SC9->C9_QTDLIB,"01","T"+strzero(QTD,5),SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,,,"7")
			Else
				DbDelete()
				MsUnLock()
				// Deleto o SC9
			EndIf
		Else
			// Mantem o registro do SC9 como está
		EndIf
		DbSelectArea("TRB0")
		TRB0->(DbSkip())
	EndDo
	
	If MV_xPAR08 == 1 // Aglutina pedidos Iguais - Criar arquivo de trabalho
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define array para arquivo de trabalho 				  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Select("TRB") > 0
			DbSelectArea("TRB")
			Zap
		Else
			aStruTrb := {}
			aTam := TamSX3("C5_TIPO")
			AADD(aStruTrb,{ "C5TIPO","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C5_CLIENTE")
			AADD(aStruTrb,{ "C5CLIENTE","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C5_LOJACLI")
			AADD(aStruTrb,{ "C5LOJACLI","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C5_CONDPAG")
			AADD(aStruTrb,{ "C5CONDPAG","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C5_CLIENT ")
			AADD(aStruTrb,{ "C5CLIENT","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C5_LOJAENT")
			AADD(aStruTrb,{ "C5LOJAENT","C",aTam[1],aTam[2] } )
			//		aTam := TamSX3("C5_ENDENT1")
			//		AADD(aStruTrb,{ "C5ENDENT1","C",aTam[1],aTam[2] } )
			//		aTam := TamSX3("C5_ENDENT2")
			AADD(aStruTrb,{ "C5ENDENT2","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C5_REAJUST")
			AADD(aStruTrb,{ "C5REAJUST","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C5_VEND1")
			AADD(aStruTrb,{ "C5VEND1","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C5_VEND2")
			AADD(aStruTrb,{ "C5VEND2","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C5_VEND3")
			AADD(aStruTrb,{ "C5VEND3","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C5_VEND4")
			AADD(aStruTrb,{ "C5VEND4","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C5_VEND5")
			AADD(aStruTrb,{ "C5VEND5","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C5_TPFRETE")
			AADD(aStruTrb,{ "C5TPFRETE","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C5_INCISS")
			AADD(aStruTrb,{ "C5INCISS","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C9_CLIENTE")
			AADD(aStruTrb,{ "C9CLIENTE","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C9_LOJA")
			AADD(aStruTrb,{ "C9LOJA","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C9_AGREG")
			AADD(aStruTrb,{ "C9AGREG","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C9_DATALIB")
			AADD(aStruTrb,{ "C9DATALIB","D",aTam[1],aTam[2] } )
	
			aTam := TamSX3("C9_FILIAL")
			AADD(aStruTrb,{ "C9FILIAL","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C9_PEDIDO")
			AADD(aStruTrb,{ "C9PEDIDO","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C9_ITEM")
			AADD(aStruTrb,{ "C9ITEM","C",aTam[1],aTam[2] } )
			aTam := TamSX3("C9_SEQUEN")
			AADD(aStruTrb,{ "C9SEQUEN","C",aTam[1],aTam[2] } )
	
			AADD(aStruTrb,{ "C9NUMREG","N",10,0 } )
	
			cNomTrb := CriaTrab(aStruTrb)
			//	dbUseArea(.T.,,cNomTrb,"TRB",.F.,.F.) // Abre o arquivo de forma compartilhada
			dbUseArea(.T.,,cNomTrb,"TRB",.F.,.F.) // Abre o arquivo de forma exclusiva
	
			/*/ By Roberto Oliveira - 25/08/16
			Verifiquei que o cliente loja de entrega não está na chave para aglutinação de pedidos iguais.
			Conversei com Juliana e concordamos em corrigir.
			/*/
			// Atenção - Se alterar aqui, alterar também a rotina de aglutinação de O.S. (ordem de separação) para os volumes
			// fonte ACD_PEDVOL()
			cOrdem  :='C5TIPO+C5CLIENTE+C5LOJACLI+C5CLIENT+C5LOJAENT+C5CONDPAG+C5REAJUST+C5VEND1+C5VEND2+C5VEND3+C5VEND4+C5VEND5'
			cOrdem  +='+C5TPFRETE+C5INCISS+C9AGREG+C9PEDIDO+C9ITEM+C9SEQUEN'
			//cOrdem  +='+C5INCISS+C9AGREG+C9PEDIDO+C9ITEM+C9SEQUEN'
			//cOrdem  +='+C5INCISS+C9AGREG+C9PEDIDO+C9ITEM+C9SEQUEN+C5CLIENT+C5LOJAENT+C5ENDENT1+C5ENDENT2'
	
			//		cOrdem  :='C5TIPO+C5CLIENTE+C5LOJACLI+C5CONDPAG+C5REAJUST+C5VEND1+C5VEND2+C5VEND3+C5VEND4+C5VEND5'
			//		cOrdem  +='+C5INCISS+C9CLIENTE+C9LOJA+C9AGREG'
			//		cOrdem  +='+C9FILIAL+C9PEDIDO+C9ITEM+C9SEQUEN'
	
			cNomTrb1 := Subs(cNomTrb,1,7)+"A"
			IndRegua("TRB",cNomTrb1,cOrdem,,,OemToAnsi("Selecionando Registros..."))
	
			cOrdem  :="C9NUMREG"
			cNomTrb2 := Subs(cNomTrb,1,7)+"B"
			IndRegua("TRB",cNomTrb2,cOrdem,,,OemToAnsi("Selecionando Registros..."))
	
			DbClearIndex() // Fecha todos s arquivos de indices
			DbSetIndex(cNomTrb1 + OrdBagExt())
			DbSetIndex(cNomTrb2 + OrdBagExt())
			DbSetOrder(1)
		EndIf
	EndIf
	
	DbSelectArea("SC9")
	DBOrderNickName("SC9ITEM")
	//DbSetOrder(9) // FILIAL+OK+PEDIDO+ITEM
	DbSeek(xFilial("SC9")+cMarca,.T.)
	ProcRegua(nQuantR)
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_OK == cMarca .And. SC9->(!Eof())
	
		cNumPed := SC9->C9_PEDIDO
	
		Dbselectarea("SC5")
		DbsetOrder(1)
		DbSeek(xFilial("SC5")+cNumPed,.F.)
	
		Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_OK == cMarca .And. ;
			SC9->C9_PEDIDO == cNumPed .And. SC9->(!Eof())
			IncProc()
	
			If (!Empty(SC9->C9_BLCRED+SC9->C9_BLEST+SC9->C9_RISCO)) .Or. AllTrim(SC9->C9_AGREG) == "ROMA" // Este já é uma quebra do C9 principal.
				SC9->(DbSkip())
				Loop
			EndIf
	
			Dbselectarea("SC6")
			DbsetOrder(1)
			DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.)
	
			DbSelectArea("SC9")
	
			If SC6->C6_TES $ "505//617"
				If !SC6->C6_TES $ SC9->C9_AGREG // # "505 "
					RecLock("SC9",.F.)
					SC9->C9_AGREG := SC6->C6_TES //"505 "
					MsUnLock()
				EndIf
			EndIf
	
			// If (!Empty(SC9->C9_SEQRM)) .Or. (SC5->C5_DESCESP+SC5->C5_DESCEQT <= 0.00) .Or. (SC6->C6_TES $ "505//617")
			// If (!Empty(SC9->C9_SEQOS)) .Or. (SC5->C5_DESCESP+SC5->C5_DESCEQT <= 0.00) .Or. (SC6->C6_TES $ "505//617") ERRO NA TABELA D - Roberto Oliveira
			If (SC5->C5_DESCESP+SC5->C5_DESCEQT <= 0.00) .Or. (SC6->C6_TES $ "505//617")
				If MV_xPAR08 == 1 // Aglutina pedidos Iguais - Criar arquivo de trabalho
					CriaTRB()
				EndIf
				SC9->(DbSkip())
				Loop
			EndIf
	
			_aAreaSC9 := GetArea()
	
			// Salvo Dados do C9 Atual
			_aRegSC9 := Array(1,FCount())
			For _j := 1 to FCount()
				_aRegSC9[1][_j] := FieldGet(_j)
			Next
	
			Dbselectarea("SF4")
			DbsetOrder(1)
			DbSeek(xFilial("SF4")+SC6->C6_TESORI,.F.)
	
			//Alterado devido ao error que estava aparecendo no momento de faturar
			//indice de chave duplicada
			//_cSeqOS := SC9->C9_SEQOS
			_cSeq   := SC9->C9_SEQUEN
			nVunit1 := nQtd1 := 0.00
			nVunit2 := nQtd2 := 0.00
			cTES2   := If(!Empty(SF4->F4_TESVL),SF4->F4_TESVL,'809') // '809'-valor '810'-quantidade
			_lSoFin := .T.
	
			If SC5->C5_DESCESP > 0.00
				nVunit1 := Round((SC6->C6_PRCVEN * SC5->C5_DESCESP) / 100,4)
			Else
				nVunit1 := SC6->C6_PRCVEN
			EndIf
			If SC5->C5_DESCEQT > 0.00
				_lSoFin := .F.
				nQtd1 := Int((SC9->C9_QTDLIB * SC5->C5_DESCEQT)/100)
	
				If nQtd1  == 0.00
					nQtd1 := Round(((SC9->C9_QTDLIB * SC5->C5_DESCEQT)/100),2)
				EndIf
	
				// Se for rolo de 100, 50 ou 15
				DbSelectArea("SDC")
				DbSetOrder(1)  //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
				DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.F.)
				_cLocaliz := SDC->DC_LOCALIZ
				If AllTrim(_cLocaliz) $ "R00100//R00050//R00015//L00015"
					//
					_nLance   := Val(Substr(AllTrim(_cLocaliz),2,5))
					_nQtdQueb := Int(nQtd1 / _nLance) * _nLance
					If _nQtdQueb < nQtd1
						nQtd1 := Min((_nQtdQueb+_nLance),SC9->C9_QTDLIB)
					EndIf
				EndIf
	
				nQtd2 := SC9->C9_QTDLIB - nQtd1
				cTES2 := If(!Empty(SF4->F4_TESQT),SF4->F4_TESQT,'810') // '809'-valor '810'-quantidade
			Else
				nQtd1 := nQtd2 := SC9->C9_QTDLIB
			EndIf
			nVunit2 := Round((((SC9->C9_QTDLIB * SC6->C6_PRCVEN) - (nQtd1 * nVunit1)) / nQtd2),4)
	
			If _lSoFin
				// Altera o Valor do C9 Atual
				RecLock("SC9",.F.)
				SC9->C9_QTDORI := SC9->C9_QTDLIB
				SC9->C9_QTDLIB := nQtd1
				SC9->C9_PRCVEN := NoRound(nVunit1,4)
				// SC9->C9_SEQOS  := _cSeqOs ***
				SC9->C9_TES    := SC6->C6_TESORI
				SC9->C9_AGREG  := "    "
				MsUnLock()
	
				_cProduto := SC9->C9_PRODUTO
				_nQtdLib  := SC9->C9_QTDLIB
				_cLocal   := SC9->C9_LOCAL
				_cPedido  := SC9->C9_PEDIDO
				_cItem    := SC9->C9_ITEM
				_cSequen  := SC9->C9_SEQUEN
	
				CrieC9(_lSoFin)
			Else
				/*/
				Roberto Oliveira 07/02/17
				Alterada a forma de distribuição das quantidades no SC9 e SDC para não mais envolver as tabelas SB2 e SBF no processo.
				Como esta rotina estorna a liberação e a refaz essas liberações com dados alterados no SC9 e SDC, ficam as quantidades
				"disponíveis" momentaneamente onde um outro processo pode comprometer a quantidade.
	
				Para que ainda esta alteração não faça no ambiente de produção, criei a variável _lFrmNew que controla entre a forma nova ou não
				/*/
				_lFrmNew := .T.
				If _lFrmNew // Forma Nova
					Begin Transaction
	
						//DisarmTransaction()
						// Nesta rotina não prevejo nenhum erro para chamar a DisarmTransaction... somente estou colocando dentro de uma
						// transação para o casso de dar error.log
	
						DbSelectArea("SDC")
						DbSetOrder(1)  //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
						_lTemSDC := .F.
						If DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.F.)
							RegToMemory("SDC",.F.) // Cria as variáveis em memória do SDC
							RecLock("SDC",.F.) // Altera a quantidade no SDC
							SDC->DC_QUANT   := nQtd1
							SDC->DC_QTDORIG := nQtd1
							MsUnLock()
							_lTemSDC := .T.
						EndIf
	
						RecLock("SC9",.F.)
						SC9->C9_QTDORI := SC9->C9_QTDLIB
						SC9->C9_QTDLIB := nQtd1
						SC9->C9_PRCVEN := NoRound(nVunit1,4)
						SC9->C9_TES    := SC6->C6_TESORI
						SC9->C9_AGREG := "    "
						MsUnLock()
	
						If nQtd2 > 0
							_cProduto := SC9->C9_PRODUTO
							_nQtdLib  := SC9->C9_QTDLIB
							_cLocal   := SC9->C9_LOCAL
							_cPedido  := SC9->C9_PEDIDO
							_cItem    := SC9->C9_ITEM
							_cSequen  := SC9->C9_SEQUEN
	
							CrieC9(_lSoFin)
							RecLock("SC9",.F.)
							SC9->C9_BLEST := ' '
							MsUnLock()
							If _lTemSDC
								// Altera as variáveis da chave com o SC9
								M->DC_QUANT   := SC9->C9_QTDLIB
								M->DC_QTDORIG := SC9->C9_QTDLIB
								M->DC_SEQ     := SC9->C9_SEQUEN
								DbSelectArea("SDC")
								_nQtCpo := SDC->(FCount())
	
								RecLock("SDC",.T.)
								For nCntFor := 1 To _nQtCpo
									FieldPut(nCntFor,M->&(FieldName(nCntFor)))
								Next
								MsUnLock()
							EndIf
						EndIf
					End Transaction
				Else // Forma velha
					// Estornar o C9 atual
	
					DbSelectArea("SDC")
					DbSetOrder(1)  //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
					DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.F.)
					_cLocaliz := SDC->DC_LOCALIZ
					_cSeqOs   := SC9->C9_SEQOS
					//			If Found()
					//           1,              2,             3,            4,              5,             6,           7,             8,9,10,11, 12
					U_CDLibEst("E",SC9->C9_PRODUTO,SC9->C9_QTDLIB,SC9->C9_LOCAL,SDC->DC_LOCALIZ,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN, ,  ,  ,.T.)
					//			EndIf
	
					RestArea(_aAreaSC9)
					RecLock("SC9",.F.)
					SC9->C9_QTDORI := SC9->C9_QTDLIB
					SC9->C9_QTDLIB := nQtd1
					SC9->C9_PRCVEN := NoRound(nVunit1,4)
					//SC9->C9_SEQOS  := _cSeqOs *** // Não gravar... está com BLEST == 02
					SC9->C9_TES    := SC6->C6_TESORI
					SC9->C9_AGREG := "    "
					MsUnLock()
	
					// Liberar c9 atual
					_cProduto := SC9->C9_PRODUTO
					_nQtdLib  := SC9->C9_QTDLIB
					_cLocal   := SC9->C9_LOCAL
					_cPedido  := SC9->C9_PEDIDO
					_cItem    := SC9->C9_ITEM
					_cSequen  := SC9->C9_SEQUEN
	
					// Atenção: O 1ro parâmetro deve ser diferente em cada chamada da função CDLibEst para poder
					// identificar a origem da liberação. Esta informação será gravada no campo DC_TPLIB.
					// Incluir este comentário em todas as chamadas da função quando for LIBERAÇÃO.
					//PODE SER
					//           1,        2,       3,      4,        5,       6,     7,       8,9,10, 11, 12
					U_CDLibEst("L",_cProduto,_nQtdLib,_cLocal,_cLocaliz,_cPedido,_cItem,_cSequen, ,  ,"8",.T.)
	
					RecLock("SC9",.F.)
					SC9->C9_SEQOS  := _cSeqOs
					MsUnLock()
	
					If nQtd2 > 0
						CrieC9(_lSoFin)
	
						_cProduto := SC9->C9_PRODUTO
						_nQtdLib  := SC9->C9_QTDLIB
						_cLocal   := SC9->C9_LOCAL
						_cPedido  := SC9->C9_PEDIDO
						_cItem    := SC9->C9_ITEM
						_cSequen  := SC9->C9_SEQUEN
						// Atenção: O 11ro parâmetro deve ser diferente em cada chamada da função CDLibEst para poder
						// identificar a origem da liberação. Esta informação será gravada no campo DC_TPLIB.
						// Incluir este comentário em todas as chamadas da função quando for LIBERAÇÃO.
	
						//           1,        2,       3,      4,        5,       6,     7,       8,9,10, 11, 12
						U_CDLibEst("L",_cProduto,_nQtdLib,_cLocal,_cLocaliz,_cPedido,_cItem,_cSequen, ,  ,"9",.T.)
					EndIf
				EndIf
			EndIf
			nQuantR++
			RestArea(_aAreaSC9)
			If MV_xPAR08 == 1 // Aglutina pedidos Iguais - Criar arquivo de trabalho
				CriaTRB()
			EndIf
			SC9->(DbSkip())
		EndDo
	EndDo
	/*
	Condições para o processamento:
	Estoque	Fiscal	Financeiro
	- Sem descontos					S		S		S
	- Desconto valor				N		N		S
	- Desconto quantidade           S		N		S
	- Desconto valor e quantidade	S		N		S
	
	Campos a serem criados/Usados :
	
	C6_TESORI C 3 - Código original do TES;
	C9_SEQOS  C 6 - Número da amarração dos registros do SC9;
	C9_TES    C 3 - Código do TES a ser usado na operação;
	F4_TESVL  C 3 - Código do TES para desconto so em valor
	F4_TESQT  C 3 - Código do TES para desconto em quatidade ou quantidade + valor
	*/
	DbSetOrder(1)
Return(.T.)


/*/{Protheus.doc} MontaNF
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
Static Function MontaNF()
	
	DbSelectArea("SC9")
	DBOrderNickName("SC9AGREG")
	//DbSetOrder(8) // Filial+OK+Pedido+Agreg
	DbSeek(xFilial("SC9")+cMarca,.T.)
	ProcRegua(nQuantR)
	cNumPed := "      "
	_aTipoCli := {}
	NfDe := NfAte := RomDe := RomAte := Space(6)
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_OK == cMarca .And. SC9->(!Eof())
	
		If SC9->C9_PEDIDO # cNumPed
			cNumPed := SC9->C9_PEDIDO
			_cNumRom := Soma1(GETMV("MV_CDROMA"))
			DbSelectArea("SX6")
			If !Dbseek(FWCodFil()+"MV_CDROMA",.F.)
				Dbseek("  MV_CDROMA",.F.)
			EndIf
			If !SX6->(Eof())
				Reclock("SX6",.F.)
				SX6->X6_CONTEUD := _cNumRom
				SX6->(MsUnlock())
			Endif
	
			_cNumCar := Soma1(GETMV("MV_CDCARGA"))
			DbSelectArea("SX6")
			If !Dbseek(FWCodFil()+"MV_CDCARGA",.F.)
				Dbseek("  MV_CDCARGA",.F.)
			EndIf
			If !SX6->(Eof())
				Reclock("SX6",.F.)
				SX6->X6_CONTEUD := _cNumCar
				SX6->(MsUnlock())
			Endif
	
			Dbselectarea("SC5")
			DbsetOrder(1)
			DbSeek(xFilial("SC5")+cNumPed,.F.)
		Else
			Dbselectarea("SC5")
			DbsetOrder(1)
			DbSeek(xFilial("SC5")+cNumPed,.F.)
		EndIf
	
		_aTipoCli := {}
		aAdd(_aTipoCli,{cNumPed,SC5->C5_TIPOCLI})
	
		_cAgreg := SC9->C9_AGREG
		aPvlNfs := {}
	
		Dbselectarea("SE4")
		DbsetOrder(1)
		DbSeek(xFilial("SE4")+SC5->C5_CONDPAG,.F.)
		_PrxReg := SC9->(Recno())
		
		Dbselectarea("SA1")
		DbsetOrder(1)
		DbSeek(xFilial("SA1")+SC9->C9_CLIENTE+SC9->C9_LOJA,.F.)		
		If !Empty(SA1->A1_ZZQINF) .And. SA1->A1_ZZQINF > 0
		 	_nMaxItem := SA1->A1_ZZQINF
		Else
		 	_nMaxItem := GetMv("MV_NUMITEN")
		EndIf		
		
		_nMaxLoop := If(Empty(SC9->C9_AGREG),_nMaxItem,99999)
	
		//xPesoCS := 0.00
	
		//	If FWCodEmp()+FWCodFil() == "0101" /// Cobrecom Matriz
		//by roberto 13/01/14
		// Zerar o que está sendo faturado Agora
		For _nBb := 1 to Len(_aPedBob)
			_aPedBob[_nBb,6] := 0
		Next
		//	EndIf
	
		_nReg505 := 0
		Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_OK == cMarca .And.;
			SC9->C9_AGREG == _cAgreg .And. SC9->C9_PEDIDO == cNumPed .And.;
			Len(aPvlNfs) < _nMaxLoop .And. SC9->(!Eof())
	
			If !Empty(SC9->C9_BLCRED+SC9->C9_BLEST+SC9->C9_RISCO)
				SC9->(DbSkip())
				Loop
			EndIf
			IncProc()
	
			Dbselectarea("SB1")
			DbsetOrder(1)
			DbSeek(xFilial("SB1")+SC9->C9_PRODUTO,.F.)
	
			Dbselectarea("SB2")
			DbsetOrder(1)
			DbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL,.F.)
	
			Dbselectarea("SC6")
			DbsetOrder(1)
			DbSeek(xFilial("SC6")+cNumPed+SC9->C9_ITEM,.F.)
			If SC6->C6_PRUNIT > SC9->C9_PRCVEN .Or. SC6->C6_TES # SC9->C9_TES
				RecLock("SC6",.F.)
				SC6->C6_PRUNIT := Min(SC9->C9_PRCVEN,SC6->C6_PRUNIT)
				If !Empty(SC9->C9_TES)
					SC6->C6_TES    := SC9->C9_TES
				EndIf
				MsUnLock()
			EndIf
	
			Dbselectarea("SB5")
			DbsetOrder(1)
			DbSeek(xFilial("SB5")+SC9->C9_PRODUTO,.F.)
	
			Dbselectarea("SF4")
			DbsetOrder(1)
			DbSeek(xFilial("SF4")+SC6->C6_TES,.F.)
			If 	SC6->C6_TES == "505" .And. _nReg505 == 0
				_nReg505 := Recno()
			EndIf
	
			If !Empty(SC6->C6_RES_SZZ + SC6->C6_ITE_SZZ) .And. SF4->F4_ESTOQUE == "S"
				DbSelectArea("SZZ")
				DbSetOrder(1) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
				If DbSeek(xFilial("SZZ") + SC6->C6_RES_SZZ + SC6->C6_ITE_SZZ,.F.)
					RecLock("SZZ",.F.)
					If (SC6->C6_QTDENT+SC9->C9_QTDLIB) >= SC6->C6_QTDVEN
						SZZ->ZZ_STATUS := "3"
					Else
						SZZ->ZZ_STATUS := "2"
					EndIf
					MsUnLock()
				EndIf
			EndIf
	
			If SA1->A1_COD # SC5->C5_CLIENTE .Or. SA1->A1_LOJA # SC5->C5_LOJACLI
				Dbselectarea("SA1")
				DbSetOrder(1)
				DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.)
			EndIf
	
			// Chama a função   para cálculo do IVA, se houver
			//F4_SITTRIB está preenchido com as opções 10, 30, 70 ou 90
			/*
			If SA1->A1_REGESIM <> "1"
				_C6_PICMRET := u_M460SOLI(.T.)
				If (SC6->C6_PICMRET # _C6_PICMRET)
					RecLock("SC6",.F.)
					SC6->C6_PICMRET := _C6_PICMRET
					MsUnLock()
				EndIf
			EndIf
			*/
	
			Dbselectarea("SC9")
	
			// Em 05/07/12 alterei o conteudo deste array conforme verifiquei nos fontes MATA461
			//
			//aAdd(aPvlNfs,{SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,SC9->C9_QTDLIB,SC9->C9_PRCVEN,;
			//			SC9->C9_PRODUTO,SF4->F4_ISS=="S",SC9->(RecNo()),;
			//			SC5->(RecNo()),SC6->(RecNo()),SE4->(RecNo()),;
			//			SB1->(RecNo()),SB2->(RecNo()),SF4->(RecNo()),SC9->C9_AGREG})
			// Basicamente a alteração é a retirada do C9_AGREG e inclusão do B2_LOCAL, de um 0 (tabela SDK) e do C9_QTDLIB2
	
			If Empty(SC6->C6_PEDCLI)
				_cPedCli := SC5->C5_PEDCLI
				_cIteCli := " "
			Else
				_cPedCli := SC6->C6_PEDCLI
				_cIteCli := SC6->C6_ITPDCLI
			EndIf
	
	
	
			aAdd(aPvlNfs,{SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,SC9->C9_QTDLIB,SC9->C9_PRCVEN,;
			SC9->C9_PRODUTO,SF4->F4_ISS=="S",SC9->(RecNo()),;
			SC5->(RecNo()),SC6->(RecNo()),SE4->(RecNo()),;
			SB1->(RecNo()),SB2->(RecNo()),SF4->(RecNo()),SB2->B2_LOCAL,0,SC9->C9_QTDLIB2,;
			AllTrim(_cPedCli),AllTrim(_cIteCli)})
	
			SC9->(DbSkip())
		EndDo
	
		_PrxReg := SC9->(Recno())
	
		If Len(aPvlNfs)>0
			CriaNF()
		EndIf
		DbSelectArea("SC9")
		DBOrderNickName("SC9AGREG")
		//	DbSetOrder(8) // Filial+OK+Pedido+Agreg
		SC9->(DbGoTo(_PrxReg))
	
		If SC9->C9_FILIAL # xFilial("SC9") .Or. SC9->C9_OK # cMarca .Or. SC9->(Eof()) .Or. SC9->C9_PEDIDO # cNumPed
			DbSelectArea("SE1")
			DBOrderNickName("SE1CHAVE")
			//		DbSetOrder(19)
			_lTemMenor:= .F.
			_cChaveE1 := Left(_cNumRom + Space(Len(SE1->E1_CHAVE)),Len(SE1->E1_CHAVE))
			DbSeek(xFilial("SE1")+_cChaveE1,.F.)
	
			_GoFluxo := Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_FLUXO")
			_GoFluxo := If(_GoFluxo=="N","N","S")
	
			Do While SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CHAVE == _cChaveE1  .And. SE1->(!Eof())
				If SE1->E1_TIPO == "NFE" .Or. SE1->E1_FLUXO # _GoFluxo
					RecLock("SE1",.F.)
					SE1->E1_TIPO  := "NF "
					SE1->E1_FLUXO := _GoFluxo
					MsUnLock()
				EndIf
				If SE1->E1_VALOR < GetMv("MV_CDMINDP") // 250.00 // Se necessário definir parâmetro para tratar o vlr. mnimo de duplicata
					_lTemMenor:= .T.
				EndIf
				SE1->(DbSkip())
			EndDo
	
			If _lTemMenor
				MostrePar()
			EndIf
	
			DbSelectArea("SE1")
			DbSetOrder(1)
	
			DbSelectArea("SC9")
			SC9->(DbGoTo(_PrxReg))
		EndIf
	EndDo
	DbSetOrder(1)
	
	If !Empty(NfDe) .Or. !Empty(RomDe)
		_aAreaRom := GetArea()
		_cQuery := "SELECT D2_PEDIDO, D2_SEQOS, D2_ITEMPV, F2_CDROMA, D2_COD, DB_LOCALIZ, SUM(DB_QUANT) DBQUANT, 0 AS ZZRQUANT, "
		_cQuery += "((SELECT ISNULL(SUM(ZZR_QUAN),0) FROM "+RetSqlName("ZZR")+" ZZR " + ;
						" WHERE ZZR_FILIAL = D2_FILIAL" + ;
						" AND ZZR_PEDIDO = D2_PEDIDO" + ;
						" AND ZZR_ITEMPV = D2_ITEMPV" + ;
						" AND ZZR_SEQOS = D2_SEQOS" + ;
						" AND Left(ZZR_PRODUT,10) = Left(D2_COD ,10)" + ;
						" AND ZZR_LOCALI = DB_LOCALIZ" + ;
						" AND ZZR.D_E_L_E_T_ = '')) ZZRQUANT2, D2_FILIAL"
		_cQuery += "FROM "+RetSqlName("SF2")+" F2 "
		_cQuery += "INNER JOIN "+RetSqlName("SD2")+" D2 ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND " + ;
							   "F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA AND F2.D_E_L_E_T_ = D2.D_E_L_E_T_ "
		_cQuery += "INNER JOIN "+RetSqlName("SB1")+" B1 ON '"+xFilial("SB1")+"' = B1_FILIAL AND D2_COD = B1_COD AND D2.D_E_L_E_T_ = B1.D_E_L_E_T_ "
		_cQuery += "INNER JOIN "+RetSqlName("SF4")+" F4 ON '"+xFilial("SF4")+"' = F4_FILIAL AND D2_TES = F4_CODIGO	AND D2.D_E_L_E_T_ = F4.D_E_L_E_T_ "
		_cQuery += "LEFT  JOIN "+RetSqlName("SDB")+" DB ON D2_FILIAL = DB_FILIAL AND D2_COD = DB_PRODUTO AND D2_LOCAL =  DB_LOCAL " + ;
							   "AND D2_NUMSEQ = DB_NUMSEQ AND D2_DOC = DB_DOC AND D2_SERIE = DB_SERIE AND D2.D_E_L_E_T_ = F4.D_E_L_E_T_ "
		_cQuery += "WHERE F2_FILIAL = '"+xFilial("SF2")+"' AND F2_CDROMA >= '" + RomDe + "' AND F2_CDROMA <= '"+RomAte+"' AND F2.D_E_L_E_T_ = '' AND  " + ;
						 "F4_ESTOQUE = 'S' AND D2_SEQOS <> '  ' AND B1_LOCALIZ = 'S' "
		_cQuery += "GROUP BY D2_FILIAL,F2_CDROMA,D2_PEDIDO, D2_ITEMPV, D2_SEQOS, D2_COD, DB_LOCALIZ "
		_cQuery += "ORDER BY D2_FILIAL,D2_PEDIDO, D2_SEQOS, D2_ITEMPV, D2_COD, DB_LOCALIZ"
	
		_aDadFat := u_QryArr(_cQuery) // Executa a Query, joga os dados num array e fecha o arquivo temporário da Query.
		/*/
		 Exemmplo de retorno da query
	
		1-D2_PEDIDO 2-D2_SEQOS  3-D2_ITEMPV 4-F2_CDROMA 5-D2_COD    	6-DB_LOCALIZ    7-DBQUANT   8-ZZRQUANT (SEMPRE ZERO PARA GRAVAR A QUANT.DO ZZR)	9-ZZRQUANT2	10-D2_FILIAL
		169708		02			01			293494		1150504401      R00100         	3000		0
		169708		02			02			293494		1150502401      R00100         	2000		0
		169708		02			03			293494		1150802401      R00100         	 200		0
		169708		02			05			293494		1150905401      B00200         	 200		0
		/*/
		If Len(_aDadFat) > 0
			_cOrdens := ""
			For _nOrdem := 1 to Len(_aDadFat)
				If !(_aDadFat[_nOrdem,1] + _aDadFat[_nOrdem,2]) $ _cOrdens
					_cOrdens += _aDadFat[_nOrdem,1] + _aDadFat[_nOrdem,2] + "//"
				EndIf
			Next
	
			cMsqErr := ""
	
			Do While Len(_cOrdens) > 0
				DbSelectArea("ZZR")
				DbSetOrder(2) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_SEQOS+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_LOCALI
				//DbSetOrder(1) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_SEQOS
				DbSeek(xFilial("ZZR")+Left(_cOrdens,8),.F.)
				Do While ZZR->ZZR_FILIAL == xFilial("ZZR") .And. ZZR->(ZZR_PEDIDO+ZZR_SEQOS) == Left(_cOrdens,8) .And. ZZR->(!Eof())
					_cCdRoman := ""
					_lTemArr := .F. // Indica se tem algum ZZR que não está no array do SELECT
					For _nMyOrd := 1 To Len(_aDadFat)
						// 1-D2_PEDIDO, 2-D2_SEQOS, 3-D2_ITEMPV, 4-F2_CDROMA, 5-D2_COD, 6-DB_LOCALIZ, 7-DBQUANT, 8-ZZRQUANT (SEMPRE ZERO PARA GRAVAR A QUANT.DO ZZR)
						If ZZR->ZZR_PEDIDO == _aDadFat[_nMyOrd,1] .And. ZZR->ZZR_SEQOS == _aDadFat[_nMyOrd,2]
							If Empty(_cCdRoman)
								_cCdRoman := _aDadFat[_nMyOrd,4]
							EndIf
							If ZZR->ZZR_ITEMPV == _aDadFat[_nMyOrd,3] .And. ZZR->ZZR_LOCALI == _aDadFat[_nMyOrd,6]
								_aDadFat[_nMyOrd,8] += ZZR->ZZR_QUAN
								_lTemArr := .T.
								Exit
							EndIf
						EndIf
					Next
					If !_lTemArr
						cMsqErr += If(Len(cMsqErr)>0,", ","") + ZZR->ZZR_PEDIDO + "-" + ZZR->ZZR_SEQOS
						Exit
					EndIf
					ZZR->(DbSkip())
				EndDo
				If Len(_cOrdens) == 10
					_cOrdens := ''
				Else
					_cOrdens := Right(_cOrdens,(Len(_cOrdens)-10))
				EndIf
			EndDo
			If Empty(cMsqErr) // Todos os ZZR's estão no array do SELECT?
				// Avalia se as quantidades estão corretas
				For _nMyOrd := 1 To Len(_aDadFat)
					// 1-D2_PEDIDO, 2-D2_SEQOS, 3-D2_ITEMPV, 4-F2_CDROMA, 5-D2_COD, 6-DB_LOCALIZ, 7-DBQUANT, 8-ZZRQUANT (SEMPRE ZERO PARA GRAVAR A QUANT.DO ZZR)
					If _aDadFat[_nMyOrd,7] # _aDadFat[_nMyOrd,8] .And. !((_aDadFat[_nMyOrd,1] + "-" + _aDadFat[_nMyOrd,2]) $ cMsqErr)
						// A quantidade do SELECT é diferente da quantidade do ZZR
						cMsqErr += If(Len(cMsqErr)>0,", ","") + _aDadFat[_nMyOrd,1] + "-" + _aDadFat[_nMyOrd,2]
					EndIf
				Next
			EndIf
			If !Empty(cMsqErr) // Tem erro no faturamento
				_Msg := "Erro no processamento da(s) O.S. abaixo: " + Chr(13) + Chr(13)
				_Msg := _Msg + cMsqErr + Chr(13) + Chr(13)
				_Msg := _Msg + "Comunique Expedição." + Chr(13) + Chr(13)
				_Msg := _Msg + cMsqErr + Chr(13) + Chr(13)
				u_MandeErro(_Msg)
				Alert(_Msg)
			EndIf
		EndIf
		_Msg := "Processamento Concluído" + Chr(13) + Chr(13)
		_Msg := _Msg + "Nota Fiscal : de " + NfDe + " a " + NfAte + Chr(13)
		_Msg := _Msg + "Romaneio   : de " + RomDe + " a " + RomAte
		if !lNewFatur
			MsgBox(_Msg,"Atenção", "INFO")
		endif
		RestArea(_aAreaRom)
	EndIf
Return(.T.)


/*/{Protheus.doc} MandeErro
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined
@param cMsqErr, characters, descricao
@type function
/*/
User Function MandeErro(cMsqErr)
	Local oSch 		:= cbcSchCtrl():newcbcSchCtrl()
	oSch:setIDEnvio('CSFATUR')
	oSch:addEmailTo('wfti@cobrecom.com.br')
	//oSch:addEmailCc('leonardonhesi@gmail.com')
	oSch:setAssunto("[ATENÇÃO] - Erro Processamento Nota. ")
	oSch:setBody(cMsqErr)
	oSch:schedule()
	freeobj(oSch)
Return(.T.)


/*/{Protheus.doc} MontaNFa
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
Static Function MontaNFa()
	_nMaxItem := GetMv("MV_NUMITEN")
	DbSelectArea("TRB")
	// Chave anterior - Roberto Oliveira  23/08/16
	//DbSetOrder(1) //C5TIPO+C5CLIENTE+C5LOJACLI+C5CONDPAG+C5REAJUST+C5VEND1+C5VEND2+C5VEND3+C5VEND4+C5VEND5+C5INCISS+C9AGREG+C9PEDIDO+C9ITEM+C9SEQUEN
	// Chave anterior - Roberto Oliveira  23/08/16
	//DbSetOrder(1) //C5TIPO+C5CLIENTE+C5LOJACLI+C5CLIENT+C5LOJAENT+C5CONDPAG+C5REAJUST+C5VEND1+C5VEND2+C5VEND3+C5VEND4+C5VEND5          +C5INCISS+C9AGREG+C9PEDIDO+C9ITEM+C9SEQUEN'
	// Chave atual - Roberto Oliveira  03/03/17
	DbSetOrder(1)  //C5TIPO+C5CLIENTE+C5LOJACLI+C5CLIENT+C5LOJAENT+C5CONDPAG+C5REAJUST+C5VEND1+C5VEND2+C5VEND3+C5VEND4+C5VEND5+C5TPFRETE+C5INCISS+C9AGREG+C9PEDIDO+C9ITEM+C9SEQUEN'
	
	DbGoTop()
	ProcRegua(LastRec())
	cChave := "      "
	_aTipoCli := {}
	NfDe := NfAte := RomDe := RomAte := Space(6)
	Do While TRB->(!Eof())
		If cChave # TRB->(C5TIPO+C5CLIENTE+C5LOJACLI+C5CLIENT+C5LOJAENT+C5CONDPAG+C5REAJUST+C5VEND1+C5VEND2+C5VEND3+C5VEND4+C5VEND5+C5TPFRETE+C5INCISS) //considerar C5_CLIENT (entrega)
			cChave := TRB->(C5TIPO+C5CLIENTE+C5LOJACLI+C5CLIENT+C5LOJAENT+C5CONDPAG+C5REAJUST+C5VEND1+C5VEND2+C5VEND3+C5VEND4+C5VEND5+C5TPFRETE+C5INCISS)
			_cNumRom := Soma1(GETMV("MV_CDROMA"))
			DbSelectArea("SX6")
			If !Dbseek(FWCodFil()+"MV_CDROMA",.F.)
				Dbseek("  MV_CDROMA",.F.)
			EndIf
			If !SX6->(Eof())
				Reclock("SX6",.F.)
				SX6->X6_CONTEUD := _cNumRom
				SX6->(MsUnlock())
			Endif
	
			_cNumCar := Soma1(GETMV("MV_CDCARGA"))
			DbSelectArea("SX6")
			If !Dbseek(FWCodFil()+"MV_CDCARGA",.F.)
				Dbseek("  MV_CDCARGA",.F.)
			EndIf
			If !SX6->(Eof())
				Reclock("SX6",.F.)
				SX6->X6_CONTEUD := _cNumCar
				SX6->(MsUnlock())
			Endif
	
		EndIf
		_aTipoCli := {}
	
		_cAgreg := TRB->C9AGREG
		aPvlNfs := {}
	
		Dbselectarea("SE4")
		DbsetOrder(1)
		DbSeek(xFilial("SE4")+TRB->C5CONDPAG,.F.)
	
		//	xPedBob := ""
		// _cPedidos := ""
	
		//	If FWCodEmp()+FWCodFil() == "0101" /// Cobrecom Matriz
		// Se for Itu não somar as bobinas
		// Zerar o que está sendo faturado Agora
		For _nBb := 1 to Len(_aPedBob)
			_aPedBob[_nBb,6] := 0
		Next
		//	EndIf
	
		_nMaxLoop := If(Empty(SC9->C9_AGREG),_nMaxItem,99999)
		_nReg505  := 0
	
		Do While cChave == TRB->(C5TIPO+C5CLIENTE+C5LOJACLI+C5CLIENT+C5LOJAENT+C5CONDPAG+C5REAJUST+C5VEND1+C5VEND2+C5VEND3+C5VEND4+C5VEND5+C5TPFRETE+C5INCISS) .And. ;
			TRB->C9AGREG == _cAgreg .And. TRB->(!Eof()) .And. Len(aPvlNfs) < _nMaxLoop
			DbSelectArea("SC9")
			SC9->(DbGoTo(TRB->C9NUMREG))
			If !Empty(SC9->C9_BLCRED+SC9->C9_BLEST+SC9->C9_RISCO)
				TRB->(DbSkip())
				Loop
			EndIf
			IncProc()
	
			Dbselectarea("SC5")
			DbsetOrder(1)
			DbSeek(xFilial("SC5")+SC9->C9_PEDIDO,.F.)
			aAdd(_aTipoCli,{SC9->C9_PEDIDO,SC5->C5_TIPOCLI})
	
			Dbselectarea("SB1")
			DbsetOrder(1)
			DbSeek(xFilial("SB1")+SC9->C9_PRODUTO,.F.)
	
			Dbselectarea("SB2")
			DbsetOrder(1)
			DbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL,.F.)
	
			Dbselectarea("SC6")
			DbsetOrder(1)
			DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.)
			If SC6->C6_PRUNIT > SC9->C9_PRCVEN .Or. (SC6->C6_TES # SC9->C9_TES .And. !Empty(SC9->C9_TES))
				RecLock("SC6",.F.)
				SC6->C6_PRUNIT := Min(SC9->C9_PRCVEN,SC6->C6_PRUNIT)
				If !Empty(SC9->C9_TES)
					SC6->C6_TES    := SC9->C9_TES
				EndIf
				MsUnLock()
			EndIf
	
			Dbselectarea("SB5")
			DbsetOrder(1)
			DbSeek(xFilial("SB5")+SC9->C9_PRODUTO,.F.)
	
			Dbselectarea("SF4")
			DbsetOrder(1)
			DbSeek(xFilial("SF4")+SC6->C6_TES,.F.)
	
			If 	SC6->C6_TES == "505" .And. _nReg505 == 0
				_nReg505 := Recno()
			EndIf
	
			If !Empty(SC6->C6_RES_SZZ + SC6->C6_ITE_SZZ) .And. SF4->F4_ESTOQUE == "S"
				DbSelectArea("SZZ")
				DbSetOrder(1) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
				If DbSeek(xFilial("SZZ") + SC6->C6_RES_SZZ + SC6->C6_ITE_SZZ,.F.)
					RecLock("SZZ",.F.)
					If (SC6->C6_QTDENT+SC9->C9_QTDLIB) >= SC6->C6_QTDVEN
						SZZ->ZZ_STATUS := "3"
					Else
						SZZ->ZZ_STATUS := "2"
					EndIf
					MsUnLock()
				EndIf
			EndIf
			/*
			// Chama a função   para cálculo do IVA, se houver
				_C6_PICMRET := u_M460SOLI(.T.)
				If SC6->C6_PICMRET # _C6_PICMRET
					RecLock("SC6",.F.)
					SC6->C6_PICMRET := _C6_PICMRET
					MsUnLock()
				EndIf
			*/
			Dbselectarea("SC9")
			// Em 05/07/12 alterei o conteudo deste array conforme verifiquei nos fontes MATA461
			//
			//aAdd(aPvlNfs,{SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,SC9->C9_QTDLIB,SC9->C9_PRCVEN,;
			//			SC9->C9_PRODUTO,SF4->F4_ISS=="S",SC9->(RecNo()),;
			//			SC5->(RecNo()),SC6->(RecNo()),SE4->(RecNo()),;
			//			SB1->(RecNo()),SB2->(RecNo()),SF4->(RecNo()),SC9->C9_AGREG})
			// Basicamente a alteração é a retirada do C9_AGREG e inclusão do B2_LOCAL, de um 0 (tabela SDK) e do C9_QTDLIB2
	
			If Empty(SC6->C6_PEDCLI)
				_cPedCli := SC5->C5_PEDCLI
				_cIteCli := " "
			Else
				_cPedCli := SC6->C6_PEDCLI
				_cIteCli := SC6->C6_ITPDCLI
			EndIf
	
			aAdd(aPvlNfs,{SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,SC9->C9_QTDLIB,SC9->C9_PRCVEN,;
						  SC9->C9_PRODUTO,SF4->F4_ISS=="S",SC9->(RecNo()),;
						  SC5->(RecNo()),SC6->(RecNo()),SE4->(RecNo()),;
						  SB1->(RecNo()),SB2->(RecNo()),SF4->(RecNo()),SB2->B2_LOCAL,0,SC9->C9_QTDLIB2,;
						  AllTrim(_cPedCli),AllTrim(_cIteCli)})
			//					  SC6->C6_PEDCLI,SC6->C6_ITPDCLI})
			TRB->(DbSkip())
		EndDo
	
		If Len(aPvlNfs)>0
			CriaNF()
		EndIf
		DbSelectArea("TRB")
	EndDo
	If !Empty(NfDe) .Or. !Empty(RomDe)
		_Msg := "Processamento Concluído" + Chr(13) + Chr(13)
		_Msg := _Msg + "Nota Fiscal : de " + NfDe + " a " + NfAte + Chr(13)
		_Msg := _Msg + "Romaneio   : de " + RomDe + " a " + RomAte
		if !lNewFatur
			Alert(_Msg)
		endif
	EndIf
	DbSetOrder(1)
Return(.T.)


/*/{Protheus.doc} ValidPerg
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
Static Function ValidPerg //OK 09/10

	_aArea := GetArea()
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	
	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Filtra as Já Emitidas     ?","mv_ch1","N",01,0,0,"C","","MV_PAR01","Sim","","","Não","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Da Ordem de Separação     ?","mv_ch2","C",06,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Até a Ordem de Separação  ?","mv_ch3","C",06,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Do Cliente                ?","mv_ch4","C",06,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"05","Da Loja                   ?","mv_ch5","C",02,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Até o Cliente             ?","mv_ch6","C",06,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"07","Até a Loja                ?","mv_ch7","C",02,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Aglutina Pedidos Iguais   ?","mv_ch8","N",01,0,0,"C","","MV_PAR08","Sim","","","Não","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Só p/3Lagoas -> Armazém 10?","mv_ch9","N",01,0,0,"C","","MV_PAR09","Sim","","","Não","","","","","","","","","","",""})
	
	For i := 1 To Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2],.F.)
			RecLock("SX1",.T.)
			SX1->X1_GRUPO   := aRegs[i,01]
			SX1->X1_ORDEM   := aRegs[i,02]
			SX1->X1_PERGUNT := aRegs[i,03]
			SX1->X1_VARIAVL := aRegs[i,04]
			SX1->X1_TIPO    := aRegs[i,05]
			SX1->X1_TAMANHO := aRegs[i,06]
			SX1->X1_DECIMAL := aRegs[i,07]
			SX1->X1_PRESEL  := aRegs[i,08]
			SX1->X1_GSC     := aRegs[i,09]
			SX1->X1_VALID   := aRegs[i,10]
			SX1->X1_VAR01   := aRegs[i,11]
			SX1->X1_DEF01   := aRegs[i,12]
			SX1->X1_CNT01   := aRegs[i,13]
			SX1->X1_VAR02   := aRegs[i,14]
			SX1->X1_DEF02   := aRegs[i,15]
			SX1->X1_CNT02   := aRegs[i,16]
			SX1->X1_VAR03   := aRegs[i,17]
			SX1->X1_DEF03   := aRegs[i,18]
			SX1->X1_CNT03   := aRegs[i,19]
			SX1->X1_VAR04   := aRegs[i,20]
			SX1->X1_DEF04   := aRegs[i,21]
			SX1->X1_CNT04   := aRegs[i,22]
			SX1->X1_VAR05   := aRegs[i,23]
			SX1->X1_DEF05   := aRegs[i,24]
			SX1->X1_CNT05   := aRegs[i,25]
			SX1->X1_F3      := aRegs[i,26]
			MsUnlock()
			DbCommit()
		Endif
	Next
	RestArea(_aArea)
Return(.T.)


/*/{Protheus.doc} ParFat
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
User Function ParFat() // OK 09/10
	_Volta := .T.
	Do While _Volta
		_Volta := Pergunte(cPerg,.T.)
		If (MV_PAR02 > MV_PAR03 .Or. MV_PAR04+MV_PAR05 > MV_PAR06+MV_PAR07) .And. _Volta
			Alert("Corrigir a Abrangência das Ordens de Separação")
			Loop
		EndIf
		Exit
	EndDo
	
	MV_xPAR01 := MV_PAR01
	MV_xPAR02 := MV_PAR02
	MV_xPAR03 := MV_PAR03
	MV_xPAR04 := MV_PAR04
	MV_xPAR05 := MV_PAR05
	MV_xPAR06 := MV_PAR06
	MV_xPAR07 := MV_PAR07
	MV_xPAR08 := MV_PAR08
	MV_xPAR09 := MV_PAR09
	
	If _Volta
		DbSelectArea("SC9")
		_cFiltro := ""
		If MV_xPAR01 == 1
			_cFiltro := _cFiltro + "C9_BLCRED <> '10' .And. "
		EndIf
		If Upper(MV_xPAR02+MV_xPAR03) # "      ZZZZZZ"
			If !Empty(MV_xPAR02)
				_cFiltro := _cFiltro + "C9_PEDIDO >= '" + MV_xPAR02 + "' .And. "
			EndIf
			If !Empty(MV_xPAR03)
				_cFiltro := _cFiltro + "C9_PEDIDO <= '" + MV_xPAR03 + "' .And. "
			EndIf
		EndIf
		If Upper(MV_xPAR04+MV_xPAR05+MV_xPAR06+MV_xPAR07) # "        ZZZZZZZZ"
			If !Empty(MV_xPAR04+MV_xPAR05)
				_cFiltro := _cFiltro + "C9_CLIENTE+C9_LOJA >= '" + MV_xPAR04+MV_xPAR05 + "' .And. "
			EndIf
			If !Empty(MV_xPAR06+MV_xPAR07)
				_cFiltro := _cFiltro + "C9_CLIENTE+C9_LOJA <= '" + MV_xPAR06+MV_xPAR07 + "' .And. "
			EndIf
		EndIf
		If xFilial("SC9") == "02"
			If MV_xPAR09 == 1
				// Em 3 Lagoas faturar somente itens do Armazém 10
				_cFiltro := _cFiltro + "C9_LOCAL == '10' .And. "
			Else
				// Em 3 Lagoas faturar somente itens diferentes do Armazém 10
				_cFiltro := _cFiltro + "C9_LOCAL # '10' .And. "
			EndIf
		EndIf
	
		DbCloseArea("SC9")
		DbSelectArea("SC9")

		Set Filter to
		If !Empty(_cFiltro)
			_cFiltro := "C9_FILIAL=='" + xFilial("SC9") + "' .And. "+Left(_cFiltro,Len(_cFiltro)-7)
			Set Filter to &(_cFiltro)
		EndIf
		//	_oObjMark := GetMarkBrow()
		//	If !Empty(_oObjMark)
		//		MarkbRefresh()
		//	EndIf
		If DbSeek(xFilial("SC9"),.F.)
			Processa( {|| PoeDesc(MV_xPAR02,MV_xPAR03) },"Selecionando Registros...")
		Else
			Alert("Não há dados a Serem Apresentados - Filtro Desconsiderado")
			If xFilial("SC9") == "02"
				// Em 3 Lagoas manter o filtro do Armazém
				If MV_xPAR09 == 1
					// Em 3 Lagoas faturar somente itens do Armazém 10
					_cFiltro := "C9_LOCAL == '10'"
				Else
					// Em 3 Lagoas faturar somente itens diferentes do Armazém 10
					_cFiltro := "C9_LOCAL # '10'"
				EndIf
				Set Filter to &(_cFiltro)
			Else
				Set Filter to
			EndIf
		EndIf
		DbSeek(xFilial("SC9"),.F.)
	Else
		DbSelectArea("SC9")
		Set Filter to
		DbSeek(xFilial("SC9"),.F.)
	EndIf
Return(_Volta)


/*/{Protheus.doc} PoeDesc
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined
@param MV_xPAR02, , descricao
@param MV_xPAR03, , descricao
@type function
/*/
Static Function PoeDesc(MV_xPAR02,MV_xPAR03) // 0K 09/10
	dbSelectArea("SE1")
	dbSetOrder(8)
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SC9")
	DbSetOrder(1) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	
	DbSeek(xFilial("SC9")+MV_xPAR02,.T.)
	ProcRegua(LastRec())
	_cPedAtu := "      "
	_cCliVis := ""
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO <= MV_xPAR03 .And. !SC9->(Eof())
		IncProc()
		If _cPedAtu # SC9->C9_PEDIDO
			_cPedAtu := SC9->C9_PEDIDO
			_cRisco  := Posicione("SA1",1,xFilial("SA1")+SC9->C9_CLIENTE+SC9->C9_LOJA,"A1_RISCO")
			If !(SC9->C9_CLIENTE+SC9->C9_LOJA) $ _cCliVis
				_cCliVis := _cCliVis + "/"+ (SC9->C9_CLIENTE+SC9->C9_LOJA)
				_nDiasCad:= (Date() - Posicione("SA1",1,xFilial("SA1")+SC9->C9_CLIENTE+SC9->C9_LOJA,"A1_ULTCOM"))
				If _nDiasCad > 180 // 6 meses
					_NmCli := Posicione("SA1",1,xFilial("SA1")+SC9->C9_CLIENTE+SC9->C9_LOJA,"A1_NOME")
					MsgAlert("O cliente "+SC9->C9_CLIENTE+"/"+SC9->C9_LOJA+'-'+AllTrim(_NmCli)+;
					" Fez última compra há " + AllTrim(Str(_nDiasCad)) + " dias","Atencao!")
				EndIf
			EndIf
	
			_C9_Risco := " "
			If _cRisco $ "BCD"
				_nNDias := GetMv("MV_RISCO"+_cRisco)
				dbSelectArea("SE1")
				dbSetOrder(8)
				DbSeek(xFilial("SE1")+SC9->C9_CLIENTE+SC9->C9_LOJA+"A")
				Do While ( SE1->(!Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CLIENTE == SC9->C9_CLIENTE .And.;
					SE1->E1_LOJA == SC9->C9_LOJA .And. SE1->E1_STATUS == "A" )
	
					If ( !SE1->E1_TIPO$MVRECANT+"/"+MVPROVIS+"/"+MV_CRNEG .And. !SE1->E1_TIPO $ MVABATIM)
						If ( ( dDataBase - SE1->E1_VENCREA ) >= _nNDias )
							_C9_Risco := "X"
							Exit
						EndIf
					EndIf
					dbSelectArea("SE1")
					dbSkip()
				EndDo
			ElseIf _cRisco == "E"
				_C9_Risco := "E"
			EndIf
		EndIf
	
		If Empty(SC9->C9_DESCRI) .Or. SC9->C9_RISCO # _C9_Risco
			SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO,.F.))
			RecLock("SC9",.F.)
			SC9->C9_DESCRI := SB1->B1_DESC
			SC9->C9_RISCO := _C9_Risco
			MsUnLock()
		EndIf
		SC9->(DbSkip())
	EndDo
Return(.T.)


/*/{Protheus.doc} CrieC9
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined
@param _lSoFin, , descricao
@type function
/*/
Static Function CrieC9(_lSoFin)
	cQuery := ""
	cQuery += " SELECT *"
	cQuery += " FROM "+RetSqlName("SC9")+" C9"
	cQuery += " WHERE"
	cQuery += " C9_FILIAL = '" + xFilial("SC9") + "' AND"
	cQuery += " C9_PEDIDO = '" + _cPedido + "' AND"
	cQuery += " C9_ITEM = '" + _cItem   + "' AND"
	cQuery += " C9.D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY C9_FILIAL,C9_PEDIDO,C9_ITEM,C9_SEQUEN"
	
	TCQUERY cQuery NEW ALIAS "TR_SEQ"
	
	DbSelectArea("TR_SEQ")
	DbGoTop()
	
	_cSeqTem := ""
	Do While TR_SEQ->(!Eof())
		_cSeqTem := _cSeqTem + TR_SEQ->C9_SEQUEN  + "//"
		TR_SEQ->(DbSkip())
	EndDo
	
	DbCloseArea("TR_SEQ")
	
	_cSequen := StrZero(1,Len(SC9->C9_SEQUEN))
	Do While _cSequen $ _cSeqTem
		_cSequen := Soma1(_cSequen)
	EndDo
	// Verificado quanto a gravação do C9_SEQOS e C9_STATUS
	// os mesmos tem que estar igual ao original.
	DbSelectArea("SC9")
	RecLock("SC9",.T.)
	For _j := 1 To FCount()
		FieldPut(_j,_aRegSC9[1,_j])
	Next
	SC9->C9_SEQUEN := _cSequen
	SC9->C9_QTDORI := 0.00
	SC9->C9_QTDLIB := nQtd2
	SC9->C9_PRCVEN := NoRound(nVunit2,4)
	// SC9->C9_SEQOS  := _cSeqOS ***
	SC9->C9_TES    := cTES2
	SC9->C9_BLEST  := If(_lSoFin,"  ","02")
	SC9->C9_BLCRED := "  "
	SC9->C9_AGREG  := "ROMA"
	MsUnLock()
	
	//If !Empty(_cFiltro)
	//	Set Filter to &(_cFiltro)
	//EndIf
	
	If MV_xPAR08 == 1 // Aglutina pedidos Iguais - Criar arquivo de trabalho
		CriaTRB()
	EndIf
Return(.T.)


/*/{Protheus.doc} CriaTRB
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
Static Function CriaTRB()
	DbSelectArea("TRB")
	DbSetOrder(2)
	If !(DbSeek(SC9->(Recno()),.F.))
		RecLock("TRB",.T.)
		TRB->C5TIPO     := SC5->C5_TIPO
		TRB->C5CLIENTE  := SC5->C5_CLIENTE
		TRB->C5LOJACLI  := SC5->C5_LOJACLI
		TRB->C5CLIENT   := SC5->C5_CLIENT
		TRB->C5LOJAENT  := SC5->C5_LOJAENT
		TRB->C5CONDPAG  := SC5->C5_CONDPAG
		TRB->C5REAJUST  := SC5->C5_REAJUST
		TRB->C5VEND1    := SC5->C5_VEND1
		TRB->C5VEND2    := SC5->C5_VEND2
		TRB->C5VEND3    := SC5->C5_VEND3
		TRB->C5VEND4    := SC5->C5_VEND4
		TRB->C5VEND5    := SC5->C5_VEND5
		TRB->C5INCISS   := SC5->C5_INCISS
		TRB->C5TPFRETE   := SC5->C5_TPFRETE
		TRB->C9CLIENTE  := SC9->C9_CLIENTE
		TRB->C9LOJA     := SC9->C9_LOJA
		TRB->C9AGREG    := SC9->C9_AGREG
		TRB->C9DATALIB  := SC9->C9_DATALIB
		TRB->C9FILIAL   := SC9->C9_FILIAL
		TRB->C9PEDIDO   := SC9->C9_PEDIDO
		TRB->C9ITEM     := SC9->C9_ITEM
		TRB->C9SEQUEN   := SC9->C9_SEQUEN
		TRB->C9NUMREG   := SC9->(Recno())
		MsUnLock()
	EndIf
	DbSetOrder(1)
Return(.T.)


/*/{Protheus.doc} CriaNF
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
Static Function CriaNF()
	Local nHradd		:= 1
	Local nHoraSF2		:= HoraToInt(Time())
	Local _aMyArea		:= {}
	Local _nPesolDiv	:= 0
	Local _nPesosDiv	:= 0
	Local lPesoDiv		:= .F.
	Local aPergs 		:= {}
	Local cPediFat		:= ""
	Local cItensPedis 	:= ""
	Local aParamRet		:= {}
	
	If Len(aPvlNfs) == _nMaxLoop
		lPesoDiv	 := .T.
		cPediFat	 := aPvlNfs[01,01]
	EndIf
	// aSort(aPvlNfs,,,{|x,y| x[6]>y[6]}) // Ordena do maior para o menor
	
	// Assim sendo,
	
	_lTemPC := .F.
	aMyPvlNfs := {}
	For _nVt1 := 1 to Len(aPvlNfs)
		// Transfere de aPvlNfs para aMyPvlNfs todos os 18 elementos de todas as linhas
		aAdd(aMyPvlNfs,{aPvlNfs[_nVt1,01],aPvlNfs[_nVt1,02],aPvlNfs[_nVt1,03],;
		aPvlNfs[_nVt1,04],aPvlNfs[_nVt1,05],aPvlNfs[_nVt1,06],;
		aPvlNfs[_nVt1,07],aPvlNfs[_nVt1,08],aPvlNfs[_nVt1,09],;
		aPvlNfs[_nVt1,10],aPvlNfs[_nVt1,11],aPvlNfs[_nVt1,12],;
		aPvlNfs[_nVt1,13],aPvlNfs[_nVt1,14],aPvlNfs[_nVt1,15],;
		aPvlNfs[_nVt1,16],aPvlNfs[_nVt1,17],aPvlNfs[_nVt1,18],aPvlNfs[_nVt1,19]})
		If !_lTemPC .And. !Empty(aPvlNfs[_nVt1,18]) .And. !Empty(aPvlNfs[_nVt1,19])
			_lTemPC := .T.
		EndIf
		If lPesoDiv
			u_CbPesoDv(aPvlNfs[_nVt1], @_nPesolDiv, @_nPesosDiv)
			cItensPedis += aPvlNfs[_nVt1,02] + " | "
		EndIf
	Next
	
	If _lTemPC // Tem pedido de compra - ordenar por ele
		aSort(aMyPvlNfs,,,{|x,y| x[18]+x[19]<y[18]+y[19]}) // Ordena do menor para o maior
	Else
		aSort(aMyPvlNfs,,,{|x,y| x[6]<y[6]}) // Ordena do menor para o maior
	EndIf
	
	// Volta os dados para a aPvlNfs somente com os 17 elementos	
	aPvlNfs := {}
	For _nVt1 := 1 to Len(aMyPvlNfs)
		// Transfere de aMyPvlNfs para aPvlNfs todos os 18 elementos de todas as linhas
		aAdd(aPvlNfs,{aMyPvlNfs[_nVt1,01],aMyPvlNfs[_nVt1,02],aMyPvlNfs[_nVt1,03],;
		aMyPvlNfs[_nVt1,04],aMyPvlNfs[_nVt1,05],aMyPvlNfs[_nVt1,06],;
		aMyPvlNfs[_nVt1,07],aMyPvlNfs[_nVt1,08],aMyPvlNfs[_nVt1,09],;
		aMyPvlNfs[_nVt1,10],aMyPvlNfs[_nVt1,11],aMyPvlNfs[_nVt1,12],;
		aMyPvlNfs[_nVt1,13],aMyPvlNfs[_nVt1,14],aMyPvlNfs[_nVt1,15],;
		aMyPvlNfs[_nVt1,16],aMyPvlNfs[_nVt1,17]})
	Next
	
	cNumero :=Space(6)
	If Empty(_cAgreg) .And. _cSerEsc $ "UNI//J  //1  //UM //"
		//	cSerie := "UNI"
		cSerie := _cSerEsc
	Else
		cSerie := "U  "
	EndIf
	
	DbSelectArea("SC5")
	_cPedsSee := ""
	_nPedBru  := 0
	_nPedLiq  := 0
	For _nCtd := 1 to Len(_aTipoCli)
		If DbSeek(xFilial("SC5")+_aTipoCli[_nCtd,1],.F.)
			If !(SC5->C5_NUM $ _cPedsSee)
				_nPedBru  += SC5->C5_PBRUTO
				_nPedLiq  += SC5->C5_PESOL
				_cPedsSee := _cPedsSee + SC5->C5_NUM + "//"
			EndIf
	
	
			If  (_aTipoCli[_nCtd,2] == "S" .And. cSerie $ "J  //U  " .And. SC5->C5_TIPOCLI # "R") .Or. ;
				(_aTipoCli[_nCtd,2] == "S" .And. cSerie $ "UNI//1  //UM //" .And. SC5->C5_TIPOCLI # "S") .Or. ;
				SC5->C5_ZSTATUS > "0" // -OK .And. !GetMv("MV_ZZUSAC9")) // No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento
	
				RecLock("SC5",.F.)
				If _aTipoCli[_nCtd,2] == "S" .And. cSerie $ "J  //U  " .And. SC5->C5_TIPOCLI # "R"
					SC5->C5_TIPOCLI := "R"
				ElseIf _aTipoCli[_nCtd,2] == "S" .And. cSerie $ "UNI//1  //UM //" .And. SC5->C5_TIPOCLI # "S"
					SC5->C5_TIPOCLI := "S"
				EndIf
				SC5->C5_ZSTATUS := "0"// No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento
				MsUnLock()
			EndIf
			If SC5->C5_ZSTATUS > "0" // -OK .And. !GetMv("MV_ZZUSAC9")// No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento
				RecLock("SC5",.F.)
				SC5->C5_ZSTATUS := "0"// No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento
				MsUnLock()
			EndIf
		EndIf
	Next
	
	DbSelectArea("SC5")
	DbGoTo(aPvlNfs[1,9])
	//_nTotPeso := SC5->C5_PESOBOB
	_nTotDesc := 0.00
	If cSerie $ "UNI//1  //UM "
		If SC5->C5_TXDESC + SC5->C5_DCDESC > 0
	
			// Verifico o Total do Faturamento
			_nTotAFat := 0.00
			_nDcPr    := 0.00
			For _nxx := 1 to Len(aPvlNfs)
				_nTotAFat += (aPvlNfs[_nxx,4] * aPvlNfs[_nxx,5])
				_nDcPr    +=  NoRound((((aPvlNfs[_nxx,4] * aPvlNfs[_nxx,5]) * SC5->C5_TXDESC) / 100),2)
			Next
	
			// Verifico o % real de desconto
			_nDcPr += SC5->C5_DCDESC
			_PercDes := (_nDcPr /_nTotAFat) * 100
	
			// Aplico o % sobre o preço Unitário
			DbSelectArea("SC9")
			_nTotDesc := 0.00
			For _nxx := 1 to Len(aPvlNfs)
				_nTotItem := (aPvlNfs[_nxx,4] * aPvlNfs[_nxx,5])
				_nDcPr := NoRound((aPvlNfs[_nxx,5] * _PercDes) / 100,5)
				aPvlNfs[_nxx,5] :=  aPvlNfs[_nxx,5] - _nDcPr
				_nTotDesc += (_nTotItem - (aPvlNfs[_nxx,4] * aPvlNfs[_nxx,5]))
	
				SC9->(DbGoTo(aPvlNfs[_nxx,8]))
				RecLock("SC9",.F.)
				SC9->C9_PRCVEN :=  NoRound(aPvlNfs[_nxx,5],4)
				MsUnLock()
			Next
			RecLock("SC5",.F.)
			If SC5->C5_DCDESC > 0.00
				//			SC5->C5_TXDESC  := 0.00
				SC5->C5_DCDESC  := 0.00
			EndIf
			MsUnLock()
		EndIf
	EndIf
	//RecLock("SC5",.F.) ?????
	//MsUnLock()
	
	/*/
	Parâmator da função MaPvlNfs
	±±³Parametros³ExpA1: Array com os itens a serem gerados                   ³±±
	±±³          ³ExpC2: Serie da Nota Fiscal                                 ³±±
	±±³          ³ExpL3: Mostra Lct.Contabil                                  ³±±
	±±³          ³ExpL4: Aglutina Lct.Contabil                                ³±±
	±±³          ³ExpL5: Contabiliza On-Line                                  ³±±
	±±³          ³ExpL6: Contabiliza Custo On-Line                            ³±±
	±±³          ³ExpL7: Reajuste de preco na nota fiscal                     ³±±
	±±³          ³ExpN8: Tipo de Acrescimo Financeiro                         ³±±
	±±³          ³ExpN9: Tipo de Arredondamento                               ³±±
	±±³          ³ExpLA: Atualiza Amarracao Cliente x Produto                 ³±±
	±±³          ³ExplB: Cupom Fiscal                                         ³±±
	±±³          ³ExpCC: Numero do Embarque de Exportacao                     ³±±
	±±³          ³ExpBD: Code block para complemento de atualizacao dos titu- ³±±
	±±³          ³       los financeiros.                                     ³±±
	±±³          ³ExpBE: Code block para complemento de atualizacao dos dados ³±±
	±±³          ³       apos a geracao da nota fiscal.                       ³±±
	±±³          ³ExpBF: Code Block de atualizacao do pedido de venda antes   ³±±
	±±³                  da geracao da nota fiscal                            ³±±
	/*/
	DbSelectArea("DAK") // Garantir que a tabela DAK esteja aberta
	DbSelectArea("SC9") // Garantir que a tabela SC9 seja a principal
	
	//MaPvlNfs(aPvlNfs,cSerieNFS,lMostraCtb,lAglutCtb,lCtbOnLine,lCtbCusto,lReajuste,nCalAcrs,nArredPrcLis,lAtuSA7,lECF,cEmbExp,
	//         1      ,2        ,3         ,4        ,5         ,6        ,7        ,8       ,9           ,10     ,11  ,12
	If cSerie $ "1  /UNI"
		// Tenho que trocar no SB1 o B1_ORIGEM pois no faturamento não esta pegando o C6_CLASFIS
		// e sim o B1_ORIGEM, por isso troco temporariamente.
		//		aAdd(aPvlNfs,{
		//	01-SC9->C9_PEDIDO	02-SC9->C9_ITEM,    	03-SC9->C9_SEQUEN 	04-SC9->C9_QTDLIB 	05-SC9->C9_PRCVEN,;
		//	06-SC9->C9_PRODUTO 	07-SF4->F4_ISS=="S" 	08-SC9->(RecNo()) 	09-SC5->(RecNo()) 	10-SC6->(RecNo()),
		//  11-SE4->(RecNo())  	12-SB1->(RecNo())   	13-SB2->(RecNo()) 	14-SF4->(RecNo()) 	15-SB2->B2_LOCAL,
		//  16-?? 0            	17-SC9->C9_QTDLIB2})
		_aB1_ORIGEM := {} //SB1->B1_ORIGEM  / PARA PODER VOLTAR O QUE ERA
		For _nArray := 1 to Len(aPvlNfs)
			SC6->(DBGOTO(aPvlNfs[_nArray,10]))
			SB1->(DBGOTO(aPvlNfs[_nArray,12]))
			Aadd(_aB1_ORIGEM,SB1->B1_ORIGEM) // PARA PODER VOLTAR O QUE ERA
	
			If SB1->B1_ORIGEM # Left(SC6->C6_CLASFIS,1) .And. Left(SC6->C6_CLASFIS,1) # " " // .And. SB1->B1_ORIGEM $ "35"
				RecLock("SB1",.F.)
				SB1->B1_ORIGEM := Left(SC6->C6_CLASFIS,1)
				MsUnLock()
			EndIf
		Next
	EndIf
	
	If 	_nReg505 # 0
		DbSelectArea("SF4")
		DbGoTo(_nReg505)
		RecLock("SF4",.F.)
		SF4->F4_MSBLQL := "2"
		MsUnLock()
	EndIf
	
	Pergunte("MT460A",.F.)
	cNumAtu := MaPvlNfs(aPvlNfs,cSerie,.F.,.F.,.F.,.F.,.F.,0,0,.F.,.F.)
	//                  1      ,2     ,3  ,4  ,5  ,6  ,7  ,8,9,10 ,11
	If 	_nReg505 # 0
		DbSelectArea("SF4")
		DbGoTo(_nReg505)
		If 	SF4->F4_MSBLQL # "1"
			RecLock("SF4",.F.)
			SF4->F4_MSBLQL := "1"
			MsUnLock()
		EndIf
	EndIf
	
	If cSerie $ "1  /UNI"
		// Tenho que trocar no SB1 o B1_ORIGEM pois no faturamento não esta pegando o C6_CLASFIS
		// e sim o B1_ORIGEM, por isso troco temporariamente.
		//		aAdd(aPvlNfs,{
		//	01-SC9->C9_PEDIDO	02-SC9->C9_ITEM,    	03-SC9->C9_SEQUEN 	04-SC9->C9_QTDLIB 	05-SC9->C9_PRCVEN,;
		//	06-SC9->C9_PRODUTO 	07-SF4->F4_ISS=="S" 	08-SC9->(RecNo()) 	09-SC5->(RecNo()) 	10-SC6->(RecNo()),
		//  11-SE4->(RecNo())  	12-SB1->(RecNo())   	13-SB2->(RecNo()) 	14-SF4->(RecNo()) 	15-SB2->B2_LOCAL,
		//  16-?? 0            	17-SC9->C9_QTDLIB2})
	
		For _nArray := 1 to Len(aPvlNfs)
			SB1->(DBGOTO(aPvlNfs[_nArray,12]))
			// If SB1->B1_ORIGEM == "3" .Or. (SB1->B1_TIPO == "PA" .And. SB1->B1_ORIGEM # "5")
			If SB1->B1_ORIGEM # _aB1_ORIGEM[_nArray]
				RecLock("SB1",.F.)
				//			SB1->B1_ORIGEM := "5"
				SB1->B1_ORIGEM := _aB1_ORIGEM[_nArray]
				MsUnLock()
			EndIf
		Next
	EndIf
	
	Dbselectarea("SF2")
	RecLock("SF2",.F.)
	//If SF2->F2_SERIE == "U  " .And. SC5->C5_DESCESP > 0 .And. SC5->C5_DESCEQT == 0
	If SF2->F2_SERIE == "U  " .And. (SC5->C5_DESCESP + SC5->C5_DESCEQT) > 0 // Só zera se não for tabela Z
		// aqui Zerar pesos
		SF2->F2_PLIQUI  := 0.00
		SF2->F2_PBRUTO  := 0.00
		SF2->F2_ESPECI1 := "  "
		SF2->F2_ESPECI2 := "  "
		SF2->F2_ESPECI3 := "  "
		SF2->F2_ESPECI4 := "  "
		SF2->F2_VOLUME1 := 0
		SF2->F2_VOLUME2 := 0
		SF2->F2_VOLUME3 := 0
		SF2->F2_VOLUME4 := 0
	ElseIf SF2->F2_SERIE $ "1  /UNI"
		If lPesoDiv
			_nPesosBrut := _nPesosDiv+_nPesolDiv
			aAdd( aPergs ,{9,"Pedido: " + cPediFat,150,7,.T.})
			aAdd( aPergs ,{9,"Itens: " + cItensPedis,150,7,.T.})
			aAdd( aPergs ,{9,"Peso Bruto: " + cValToChar(_nPesosBrut)+" | Peso Líquido: " +  cValToChar(_nPesolDiv),180,10,.T.})	
			aAdd( aPergs ,{1,"Volumes: ",0,"@E 999999","","","",80,.F.})
			aAdd( aPergs ,{1,"Especies ",Space(10),"@!","","","",80,.F.})
			aAdd( aPergs ,{1,"Peso Adicional: ",0,"@E 999999999","","","",80,.F.})
			
			If !ParamBox(aPergs ,"Volumes e Pesos da NF",aParamRet)      
				MsgInfo("Serão utilizados os pesos e volumes informados no PEDIDO!", "Atenção")
				SF2->F2_PLIQUI  := _nPedLiq
				SF2->F2_PBRUTO  := _nPedBru			     
			Else			
				SF2->F2_PLIQUI  := _nPesolDiv
				SF2->F2_PBRUTO  := _nPesosDiv + _nPesolDiv + MV_PAR06
				SF2->F2_ESPECI1 := MV_PAR05
				SF2->F2_ESPECI2 := "  "
				SF2->F2_ESPECI3 := "  "
				SF2->F2_ESPECI4 := "  "
				SF2->F2_VOLUME1 := MV_PAR04
				SF2->F2_VOLUME2 := 0
				SF2->F2_VOLUME3 := 0
				SF2->F2_VOLUME4 := 0
			EndIf
		Else		
			SF2->F2_PLIQUI  := _nPedLiq
			SF2->F2_PBRUTO  := _nPedBru
		EndIf
	EndIf
	
	If (cFilAnt = "02")
		SF2->F2_HORA := Left(IntToHora(nHoraSF2-nHradd),Len(SF2->F2_HORA))
	EndIf
	
	SF2->F2_CDROMA  := _cNumRom
	SF2->F2_CDCARGA := _cNumCar
	SF2->F2_EMISORI := SF2->F2_EMISSAO
	SF2->F2_VLRDESC  := _nTotDesc
	
	SF2->(MsUnlock())
	
	// Devido a erro no Siga, que não está deletando o SF3 refeito, tento garantir que não fique "sujeira" nessa tabela.
	
	DbSelectArea("SF3")
	DbSetOrder(5) // F3_FILIAL+F3_SERIE+F3_NFISCAL+F3_CLIEFOR+F3_LOJA+F3_IDENTFT
	DbSeek(xFilial("SF3")+SF2->F2_SERIE+SF2->F2_DOC,.F.)
	Do While SF3->F3_FILIAL==xFilial("SF3") .And. SF3->F3_SERIE+SF3->F3_NFISCAL == SF2->F2_SERIE+SF2->F2_DOC .And. SF3->(!Eof())
		If !Empty(SF3->F3_DTCANC) .And. Left(SF3->F3_CFO,1) $ "56"
			RecLock("SF3",.F.)
			DbDelete()
			MsUnLock()
		EndIf
		SF3->(DbSkip())
	EndDo
	
	//If cSerie == "UNI"
	If cSerie $ "UNI/J  //1  //UM "
		If Empty(NfDe)
			NfDe := SF2->F2_DOC
		EndIf
		NfAte := SF2->F2_DOC
	EndIf
	If Empty(RomDe)
		RomDe := _cNumRom
	EndIf
	RomAte := _cNumRom
	
	DbSelectArea("SE1")
	DbSetOrder(1)
	
	DbSeek(xFilial("SE1")+SF2->F2_PREFIXO + SF2->F2_DUPL,.F.)
	Do While SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_PREFIXO == SF2->F2_PREFIXO .And. SE1->E1_NUM == SF2->F2_DUPL .And. SE1->(!Eof())
		If SE1->E1_ORIGEM == "MATA460 "
			RecLock("SE1",.F.)
			SE1->E1_CHAVE := SF2->F2_CDROMA
			MsUnLock()
		EndIf
		SE1->(DbSkip())
	EndDo
	
	DbSelectArea("SE3")
	DbSetOrder(1) //E3_FILIAL+E3_PREFIXO+E3_NUM+E3_PARCELA+E3_SEQ+E3_VEND
	DbSeek(xFilial("SE3")+SF2->F2_PREFIXO + SF2->F2_DUPL,.F.)
	Do While SE3->E3_FILIAL+SE3->E3_PREFIXO+SE3->E3_NUM == xFilial("SE3")+SF2->F2_PREFIXO + SF2->F2_DUPL .And. SE3->(!Eof())
		If Empty(SE3->E3_ROMAN) // # SF2->F2_CDROMA
			RecLock("SE3",.F.)
			SE3->E3_ROMAN := SF2->F2_CDROMA
			MsUnLock()
		EndIf
		SE3->(DbSkip())
	EndDo
	
	_lTemQt := .F.
	DbSelectArea("SC5")
	For _nCtd := 1 to Len(_aTipoCli)
		DbSeek(xFilial("SC5")+_aTipoCli[_nCtd,1],.F.)
	
		If !_lTemQt .And. SC5->C5_DESCEQT > 0.00
			_lTemQt := .T.
		EndIf
	
		If _aTipoCli[_nCtd,2] # SC5->C5_TIPOCLI
			RecLock("SC5",.F.)
			SC5->C5_TIPOCLI := _aTipoCli[_nCtd,2]
			MsUnLock()
		EndIf
		// aqui tbm dá pra zerar os campos do c5
		If SC5->C5_DESCESP > 0 .And. SC5->C5_DESCEQT == 0
			RecLock("SC5",.F.)
			SC5->C5_VOLUME1 := 0.00
			SC5->C5_VOLUME2 := 0.00
			SC5->C5_VOLUME3 := 0.00
			SC5->C5_VOLUME4 := 0.00
			SC5->C5_ESPECI1 := " "
			SC5->C5_ESPECI2 := " "
			SC5->C5_ESPECI3 := " "
			SC5->C5_ESPECI4 := " "
			SC5->C5_PESOBOB := 0.00
			MsUnLock()
		EndIf
	Next
	DbSelectArea("SC6")
	For _nX := 1 to Len(aPvlNfs)
		DbGoTo(aPvlNfs[_nX,10]) // Nro do registro do SC6
		If SC6->C6_TES # SC6->C6_TESORI //.Or. SC6->C6_CF # SC6->C6_CFORI
			RecLock("SC6",.F.)
			SC6->C6_TES := SC6->C6_TESORI
			//		SC6->C6_CF  := SC6->C6_CFORI
			MsUnLock()
		EndIf
	Next
	
	//Informações de Veiculos 
	If Alltrim(SF2->F2_TIPO) == "B" 
		If MsgBox("Deseja informar Placa do Veiculo ?","Confirma?","YesNo")
			_aMyArea := GetArea()
			A512Manut()
			RestArea(_aMyArea)
		EndIf
	EndIf
	
	// Criar Registro de controle de Fretes no ZZ4
	If SF2->F2_SERIE == "1  " .And. !Empty(SF2->F2_TRANSP) .And. SF2->F2_TIPO $ "DBN"
		_cCGCTrp := Posicione("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"A4_CGC")
		//	If !Empty(_cCGCTrp) .And. !("02544042" $ _cCGCTrp) //Não está Vazio e não é IFC
		If !("02544042" $ _cCGCTrp) //Tem transportadora e não é IFC => Wellington 11/09/12
			u_CrieFrete()
		EndIf
	EndIf
Return(.T.)


/*/{Protheus.doc} ArruPed
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
Static Function ArruPed()
Local _nPesol, _lArruma, _nPesoItem
Local oStatic    := IfcXFun():newIfcXFun()
Private aRet :={}

_cListPed := ""
DbSelectArea("SC9")
DBOrderNickName("SC9ITEM")
//DbSetOrder(9) // FILIAL+OK+PEDIDO+ITEM
DbSeek(xFilial("SC9")+cMarca,.T.)
Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_OK == cMarca .And. SC9->(!Eof())
	_Itens := ""
	_nPesos := 0 // Variável para calcular o peso das embalagens (bobinas e carretéis)
	_nPesol := 0 // Peso Líquido
	_PedC9  := SC9->C9_PEDIDO

	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_OK == cMarca .And. SC9->(!Eof()) .And. SC9->C9_PEDIDO == _PedC9
		// Procuro o SDC deste C9... se for bobina não soma em _nPesol
		DbSelectArea("SDC")
		DbSetOrder(1) // DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
		If !(DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.F.))
			_nPesoItem := (Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_PESO") * SC9->C9_QTDLIB)
			_nPesol += _nPesoItem
		Else
			Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->DC_PRODUTO == SC9->C9_PRODUTO .And. ;
					 SDC->DC_LOCAL  == SC9->C9_LOCAL  .And. SDC->DC_ORIGEM  == "SC6"           .And. ;
					 SDC->DC_PEDIDO == SC9->C9_PEDIDO .And. SDC->DC_ITEM    == SC9->C9_ITEM    .And. ;
					 SDC->DC_SEQ    == SC9->C9_SEQUEN .And. SDC->(!Eof())
				If Left(SDC->DC_LOCALIZ,1) # "B"
					_nPesoItem := (Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_PESO") * SDC->DC_QUANT)
					_nPesol += _nPesoItem
				EndIf
				SDC->(DbSkip())
			EndDo
		EndIf

		If !(SC9->C9_ITEM $ _Itens)
			_Itens += SC9->C9_ITEM + "//"
			_ItSDC := ""

			DbSelectArea("SDC")
			DbSetOrder(1) // DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
			DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.)
			Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->DC_PRODUTO == SC9->C9_PRODUTO .And. ;
				SDC->DC_LOCAL == SC9->C9_LOCAL .And. SDC->DC_ORIGEM == "SC6" .And. ;
				SDC->DC_PEDIDO == SC9->C9_PEDIDO .And. SDC->DC_ITEM == SC9->C9_ITEM .And. SDC->(!Eof())

				_nQtdLc := SDC->DC_QUANT / Val(Substr(SDC->DC_LOCALIZ,2,5))
				_nPesoEmb := 0
				If Left(SDC->DC_LOCALIZ,1) == "B"  // SZE->ZE_STATUS == "E" .And. SZE->ZE_SEQOS == SC9->C9_SEQOS // Bobina empenhada para a mesma Seq.da O.S.
					_nPosi := aScan(_aPedBob, {|x|x[1]==SDC->DC_PEDIDO+SDC->DC_ITEM})
					If _nPosi == 0
						Aadd(_aPedBob,{SDC->DC_PEDIDO+SDC->DC_ITEM,0,0,0,0,0}) // {Pedido+item,Quant.SDC,Quant.SZE,Peso Liq SZE,Tara SZE,Quant.Faturando Agora}
						_nPosi := Len(_aPedBob)
					EndIf
					_aPedBob[_nPosi,2] += SDC->DC_QUANT
				EndIf

				// Atenção: Outros lugares também fazem o mesmo cálculo
				If AllTrim(SDC->DC_LOCALIZ) == "R00015"
					// Se for rolo de 15 Encartelado
					_nRolCx := 0
					If Left(SDC->DC_PRODUTO,3) == "115"  // Cabo Flexicom
						If Substr(SDC->DC_PRODUTO,4,2) $ "04/05" //Se for cabo flex 1,5 ou 2,5 vão 10 rolos por caixa
							_nRolCx := 10
						ElseIf Substr(SDC->DC_PRODUTO,4,2) $ "06/07" //Se for cabo flex 4 ou 6     vão 08 rolos por caixa
							_nRolCx := 8
						ElseIf Substr(SDC->DC_PRODUTO,4,2) == "08" //Se for cabo flex 10         vão 06 rolos por caixa
							_nRolCx := 6
						EndIf
					ElseIf Left(SDC->DC_PRODUTO,3) == "120"  .And. Substr(SDC->DC_PRODUTO,4,2) $ "04/05"// Cordão Paralelo 1,5 ou 2,5
						_nRolCx := 8
					EndIf
					_nIlhos   := (_nQtdLc*1.1624)/1000        // Peso unitário do conjunto de ilhós em gramas
					_nSaco    := (_nQtdLc*7.2660)/1000        // Peso unitário do saco plastico     em gramas
					_nCart    := (_nQtdLc*8.5232)/1000        // Peso unitário da cartela de papel  em gramas
					_nCaixa   := (Int(_nQtdLc/_nRolCx)*0.320) // Peso unitário da caixa de papelão  em kilos
					_nPesoEmb := (_nIlhos+_nSaco+_nCart+_nCaixa)
				ElseIf Left(SDC->DC_LOCALIZ,1) == "L" // Blister
					_nPesoEmb  := u_cbcAcInf(Alltrim(SDC->DC_PRODUTO), AllTrim(SDC->DC_LOCALIZ), , _nQtdLc, , .T., .F.,.T.)[2,2]
				ElseIf Left(SDC->DC_LOCALIZ,1) == "C" // Carretel N8
					_nPesoEmb := (_nQtdLc*2.00)
				ElseIf Left(SDC->DC_LOCALIZ,1) == "B" .And. !SC9->C9_ITEM$_ItSDC
					// Considero o peso pelas bobinas
					_nPesoItem := 0

					// Bobinas de madeira -> Somar as taras do SZE
					_ItSDC += SC9->C9_ITEM + "//"

					SC6->(DbsetOrder(1))
					SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.))
					_cItemZE := If(!Empty(SC6->C6_ITEMIMP),SC6->C6_ITEMIMP,SC9->C9_ITEM)

					DbSelectArea("SZE")
					DbSetOrder(2) // ZE_FILIAL+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
					// DbSeek(xFilial("SZE")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.)        ERRO AQUI

					DbSeek(xFilial("SZE")+SC9->C9_PEDIDO+_cItemZE,.F.)
					Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_PEDIDO == SC9->C9_PEDIDO .And. ;
						SZE->ZE_ITEM == _cItemZE .And. SZE->(!Eof())
						If SZE->ZE_STATUS == "E" .And. SZE->ZE_SEQOS == SC9->C9_SEQOS // Bobina empenhada para a mesma Seq.da O.S.
							_nPosi := aScan(_aPedBob, {|x|x[1]==SDC->DC_PEDIDO+SDC->DC_ITEM})
							If _nPosi == 0
								Aadd(_aPedBob,;
								{SDC->DC_PEDIDO+SDC->DC_ITEM,0          ,0          ,0             ,0         ,0})
								//   {1-Pedido+item              ,2-Quant.SDC,3-Quant.SZE,4-Peso Liq SZE,5-Tara SZE,6-Quant.Faturando Agora}}
								_nPosi := Len(_aPedBob)
								//_aPedBob[_nPosi,2] += SDC->DC_QUANT
							EndIf
							_aPedBob[_nPosi,3] += SZE->ZE_QUANT
							_aPedBob[_nPosi,4] += SZE->ZE_PLIQ
							_aPedBob[_nPosi,5] += SZE->ZE_TARA
							_nPesoEmb := _nPesoEmb + SZE->ZE_TARA
							_nPesol += (SZE->ZE_PESO-SZE->ZE_TARA)
						EndIf
						SZE->(DbSkip())
					EndDo
				ElseIf Left(SDC->DC_LOCALIZ,1) == "M" // Carretel madeira
					_nPesoEmb := (_nQtdLc*1.45)
				EndIf
				_nPesos := _nPesos + _nPesoEmb
				SDC->(DbSkip())
			EndDo
		EndIf
		SC9->(DbSkip())
	EndDo

	// Verificar se tem itens que são bobinas e as bobinas não estão corretamente empenhadas
	_lArruma := .T.
	For _nQtBob := 1 to Len(_aPedBob)
		//If Left(_aPedBob[_nQtBob,1],6) == _PedC9 .And. Int(_aPedBob[_nQtBob,2]) # Int(_aPedBob[_nQtBob,3]) //Quant.Emp. <> Quant.Bob. no SZE
		If (Left(_aPedBob[_nQtBob,1],6) == _PedC9) .And. (Int(_aPedBob[_nQtBob,2]) # Int(_aPedBob[_nQtBob,3]))
		//Quant.Emp. <> Quant.Bob. no SZE
			//TODO Realizado ajuste para que possa ser realizao Troca de Nf sem movimentar nossas bobinas internas - Juliana Leme
			If ! MsgBox("Operação Referente a Troca de NF ?","Confirma?","YesNo")
				Alert("O Pedido " + _PedC9 + " Não Será Faturado -> Divergência Liberação de Bobinas")
				_lArruma := .F.
				If Empty(_cBadPed2)
					_cBadPed2 := _PedC9
				Else
					_cBadPed2 := _cBadPed2 + "//" + _PedC9
				EndIf
			EndIf
			Exit
		EndIf
	Next

	If !Empty(_Itens) .And. _lArruma
		cNumPed := _PedC9
		_nC9Reg := SC9->(Recno())

		Dbselectarea("SC5")
		DbsetOrder(1)
		DbSeek(xFilial("SC5")+cNumPed,.F.)
		RecLock("SC5",.F.)
		//		If FWCodEmp()+FWCodFil() == "0101" /// Cobrecom Matriz
		//by roberto 13/01/14
		//Só atualizar se for a Matriz - 3 Lagoas não!!!
		SC5->C5_PESOBOB := _nPesos // 0.00
		//		Else
		//			SC5->C5_PESOBOB := 0.00
		//		EndIf
		SC5->C5_PBRUTO  := _nPesol+_nPesos
		SC5->C5_PESOL   := _nPesol
		SC5->C5_VOLUME1 := 0.00
		SC5->C5_VOLUME2 := 0.00
		SC5->C5_VOLUME3 := 0.00
		SC5->C5_VOLUME4 := 0.00
		SC5->C5_ESPECI1 := " "
		SC5->C5_ESPECI2 := " "
		SC5->C5_ESPECI3 := " "
		SC5->C5_ESPECI4 := " "
		MsUnLock()
		/*
			[LEO] - 09/11/16 - Pedidos do BNDES, que foram dividos, deve-se avisar na hora do faturamento
			que o pedido foi divido informando o numero do pedido na outra filial, mas não deve bloquear
			o processo de faturamento. [LEO/JEF/ROB].
			OBS: Verifico C5_ZZPVDIV diferente de C5_NUM, pois quando no processo de divisão todos os itens
			são transferidos para outra filial, caracteriza um processo de divisão, mas sem a outra ponta,
			nete caso pode faturar, alertar somente quando existir pedidos na outra filial.
		*/
		//	If ( SC5->(C5_ZZPVDIV) != SC5->(C5_NUM) ) .And. SC5->(C5_CONDPAG) == "000"
		//		U_checkDiv(SC5->(C5_NUM), 'BNDES-Verificar os pedidos para faturar junto.' )
		//	EndIF
		/*[LEO] - 09/11/16 - Fim */
		if !lNewFatur
			u_CDFAT02F(_Itens)
		else
			Dbselectarea("SC5")
			DbsetOrder(1)
			DbSeek(xFilial("SC5")+cNumPed,.F.)
			oStatic:sP(1):callStatic('cbcCtrlFatur', 'ajustaVol')
		endif
		//Dbselectarea("SC5")
		//DbsetOrder(1)
		//DbSeek(xFilial("SC5")+cNumPed,.F.)
		//RecLock("SC5",.F.)
		//SC5->C5_PBRUTO  := SC5->C5_PESOL + SC5->C5_PESOBOB
		//MsUnLock()

		If 	!"1"$_cTemDesc .And. (!Empty(SC5->C5_TXDESC) .Or. !Empty(SC5->C5_DCDESC)) // Taxa de Descarga % ou vlr
			_cTemDesc := "1"
		EndIf
		If 	!"2"$_cTemDesc .And. SC5->C5_DESCESP+SC5->C5_DESCEQT > 0 .And. (!Empty(SC5->C5_TXDESC) .Or. !Empty(SC5->C5_DCDESC))
			_cTemDesc := "2"
		EndIf

		If SC5->C5_TIPO == "N"
			// Verificar se no cadastro do cliente o endereço e endereço de cobrança está ok
			DbSelectArea("SA1")
			DbSetOrder(1)
			Dbseek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.F.)
			If !"REVISADO" $ SA1->A1_ENDBKP
				Do While .T.
					aRet :={}
					aParamBox := {}
					aAdd(aParamBox,{1,"Código..:",SA1->A1_COD                    ,"XXXXXX","","",".F.",6,.F.})
					aAdd(aParamBox,{1,"Loja....:",SA1->A1_LOJA                   ,"XX","","",".F.",2,.F.})
					aAdd(aParamBox,{1,"Nome....:",SA1->A1_NOME                   ,"","","",".F.",125,.F.})
					aAdd(aParamBox,{1,"End/Orig:",SA1->A1_ENDBKP                 ,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","","",".F.",125,.F.})
					aAdd(aParamBox,{1,"Endereço:",SA1->A1_END                    ,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","","",,125,.F.})
					//aAdd(aParamBox,{1,"Tipo....:",Left(SA1->A1_END,3)            ,"XXX","","","",3,.F.})
					//aAdd(aParamBox,{1,"Nome Log:",Subst(SA1->A1_END,5,40)        ,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","","","",125,.F.})
					//aAdd(aParamBox,{1,"Número..:",VAL(SUBST(SA1->A1_END,46,5))   ,"@E 99,999","","","",6,.F.})
					aAdd(aParamBox,{1,"Complem.:",SA1->A1_COMPLEM                ,"XXXXXXXXXXXXXXX","","","",125,.F.})
					aAdd(aParamBox,{1,"End.Cobr:",SA1->A1_ENDCOB                 ,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","","",,125,.F.})
					//aAdd(aParamBox,{1,"Tipo....:",Left(SA1->A1_ENDCOB,3)         ,"XXX","","","",3,.F.})
					//aAdd(aParamBox,{1,"Nome Log:",Subst(SA1->A1_ENDCOB,5,40)     ,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX","","","",125,.F.})
					//aAdd(aParamBox,{1,"Número..:",VAL(SUBST(SA1->A1_ENDCOB,46,5)),"@E 99,999","","","",6,.F.})
					aAdd(aParamBox,{1,"Complem.:",SA1->A1_COMPLC                 ,"XXXXXXXXXXXXXXX","","","",125,.F.})

					//Chamada da Função ParamBox -> Retorno logico
					_lResp := ParamBox(aParamBox, "Atualização Endereço do Cliente", @aRet)
					If _lResp
						If MsgBox(	"Operação Confirmada - Dados Serão Gravados"+ Chr(13)+Chr(13)+;
									"Escolha: SIM para Gravar ou NÃO para Retornar a Digitar","Confirma?","YesNo")

							// Grava Dados
							RecLock("SA1",.F.)
							// SA1->A1_END     := aRet[6] + " " + aRet[7] + "," + Str(aRet[8],5)
							SA1->A1_END     := aRet[5]
							// SA1->A1_COMPLEM := aRet[9]
							SA1->A1_COMPLEM := aRet[6]

							If Empty(aRet[7])
								SA1->A1_ENDCOB := " "
								SA1->A1_COMPLC := "  "
							Else
								//SA1->A1_ENDCOB := aRet[11] + " " + aRet[12] + "," + Str(aRet[13],5)
								//SA1->A1_COMPLC := aRet[14]
								SA1->A1_ENDCOB := aRet[7]
								SA1->A1_COMPLC := aRet[8]
							EndIf
							SA1->A1_ENDBKP := "REVISADO"
							MsUnLock()

							// Sai
							Exit
						EndIf
					ElseIf MsgBox("Operação Cancelada - Dados Não Serão Gravados"+ Chr(13)+Chr(13)+;
						"Escolha: SIM para Sair SEM Gravar ou NÃO para Retornar a Digitar","Confirma?","YesNo")
						// Sai sem gravar
						Exit
					EndIf
				EndDo
			EndIf
		EndIf

		DbSelectArea("SC9")
		DBOrderNickName("SC9ITEM")
		//		DbSetOrder(9) // FILIAL+OK+PEDIDO+ITEM
		DbGoTo(_nC9Reg)
	EndIf
EndDo
Return(.T.)


/*/{Protheus.doc} GrvDesc
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
User Function GrvDesc()
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SD2")
	DbSetOrder(1)
	
	DbSeek(xFilial("SD2"),.f.)
	Do While SD2->D2_FILIAL == xFilial("SD2") .And. SD2->(!Eof())
		If Empty(SD2->D2_DESCRI)
			RecLock("SD2",.F.)
			SD2->D2_DESCRI := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")
			MsUnLock()
		EndIf
		SD2->(DbSkip())
	EndDo
Return(.T.)


/*/{Protheus.doc} GrvChave
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
User Function GrvChave()
	DbSelectArea("SF2")
	DbSetOrder(1)
	DbSeek(xFilial("SF2"),.F.)
	Do While SF2->F2_FILIAL == xFilial("SF2") .And. !Eof()
		If SF2->F2_EMISSAO > Ctod("04/03/2007")
			DbSelectArea("SE1")
			DbSetOrder(1)
			DbSeek(xFilial("SE1")+SF2->F2_PREFIXO + SF2->F2_DUPL,.F.)
			Do While SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_PREFIXO == SF2->F2_PREFIXO .And. SE1->E1_NUM == SF2->F2_DUPL .And. SE1->(!Eof())
				If SE1->E1_ORIGEM == "MATA460 "
					RecLock("SE1",.F.)
					SE1->E1_CHAVE := SF2->F2_CDROMA
					SE1->E1_NOMCLI := Posicione("SA1",1,xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,"A1_NOME")
					MsUnLock()
				EndIf
				SE1->(DbSkip())
			EndDo
		EndIf
		DbSelectArea("SF2")
		DbSkip()
	EndDo
Return(.T.)


/*/{Protheus.doc} MostrePar
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
Static Function  MostrePar()
	_cCP1 := "E1_PREFIXO"
	_cCP2 := "E1_NUM"
	_cCP3 := "E1_PARCELA"
	_cCP4 := "E1_VENCTO"
	_cCP5 := "E1_VALOR"
	_cCP6 := "E1_CLIENTE"
	_cCP7 := "E1_LOJA"
	_cCP8 := "E1_NOMCLI"
	_cCP9 := "E1_TIPO"
	//_nBasesCm := {}
	//_nBasesCd := {}
	
	dbSelectArea("SX3")
	dbSetOrder(2)
	
	aHeader:={}
	
	DbSeek(_cCP1)
	AADD(aHeader,{ "Prefixo", "PREFIXO", x3_picture, x3_tamanho, x3_decimal,".F.", x3_usado, x3_tipo, "   " , x3_context } )
	
	DbSeek(_cCP2)
	AADD(aHeader,{ "Numero", "NUMERO", x3_picture, x3_tamanho, x3_decimal,".F.", x3_usado, x3_tipo, "   ", x3_context } )
	
	DbSeek(_cCP3)
	AADD(aHeader,{ "Parc.", "PARCELA", x3_picture, x3_tamanho, x3_decimal,".F.", x3_usado, x3_tipo, "   ", x3_context } )
	
	DbSeek(_cCP4)
	AADD(aHeader,{ "Vencimento", "VENCTO", x3_picture, x3_tamanho, x3_decimal,"M->VENCTO>=dDatabase", x3_usado, x3_tipo, "   ", x3_context } )
	
	DbSeek(_cCP5)
	AADD(aHeader,{ "Valor", "VALOR", "@E 999,999.99", x3_tamanho, x3_decimal,"u_SomePar()", x3_usado, x3_tipo, "   ", x3_context } )
	
	AADD(aHeader,{ "Total", "Total", "@E 999,999.99", x3_tamanho, x3_decimal,".F.", x3_usado, x3_tipo, "   ", x3_context } )
	
	DbSeek(_cCP6)
	AADD(aHeader,{ "Cliente", "CLIENTE", x3_picture, x3_tamanho, x3_decimal,".F.", x3_usado, x3_tipo, "   ", x3_context } )
	
	DbSeek(_cCP7)
	AADD(aHeader,{ "Loja", "LOJA", x3_picture, x3_tamanho, x3_decimal,".F.", x3_usado, x3_tipo, "   ", x3_context } )
	
	DbSeek(_cCP8)
	AADD(aHeader,{ "Nome Cliente", "NOMCLI", x3_picture, x3_tamanho, x3_decimal,".F.", x3_usado, x3_tipo, "   ", x3_context } )
	
	DbSeek(_cCP9)
	AADD(aHeader,{ "Tipo do Titulo", "TIPO", x3_picture, x3_tamanho, x3_decimal,".F.", x3_usado, x3_tipo, "   ", x3_context } )
	
	//_nBasesCm := {0,0,0,0,0}
	aCols:={}
	_aCopia:={}
	aTotPar := {}
	_TotOri := _TotAlt := 0.00
	DbSelectArea("SE1")
	DbSeek(xFilial("SE1")+_cChaveE1,.F.)
	Do While SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_CHAVE == _cChaveE1  .And. SE1->(!Eof())
		AADD(aCols,Array(Len(aHeader)+1))
		aCols[Len(aCols),01] := SE1->E1_PREFIXO
		aCols[Len(aCols),02] := SE1->E1_NUM
		aCols[Len(aCols),03] := SE1->E1_PARCELA
		aCols[Len(aCols),04] := SE1->E1_VENCTO
		aCols[Len(aCols),05] := SE1->E1_VALOR
		aCols[Len(aCols),06] := 0.00
		aCols[Len(aCols),07] := SE1->E1_CLIENTE
		aCols[Len(aCols),08] := SE1->E1_LOJA
		aCols[Len(aCols),09] := SE1->E1_NOMCLI
		aCols[Len(aCols),10] := SE1->E1_TIPO
		aCols[Len(aCols),11] := .F.
	
		AADD(_aCopia,Array(Len(aHeader)+1))
		_aCopia[Len(_aCopia),01] := SE1->E1_PREFIXO
		_aCopia[Len(_aCopia),02] := SE1->E1_NUM
		_aCopia[Len(_aCopia),03] := SE1->E1_PARCELA
		_aCopia[Len(_aCopia),04] := SE1->E1_VENCTO
		_aCopia[Len(_aCopia),05] := SE1->E1_VALOR
		_aCopia[Len(_aCopia),06] := 0.00
		_aCopia[Len(_aCopia),07] := SE1->E1_CLIENTE
		_aCopia[Len(_aCopia),08] := SE1->E1_LOJA
		_aCopia[Len(_aCopia),09] := SE1->E1_NOMCLI
		_aCopia[Len(_aCopia),10] := SE1->E1_TIPO
		_aCopia[Len(_aCopia),11] := .F.
	
		//_nBasesCm[1] += SE1->E1_BASCOM1
		//_nBasesCm[2] += SE1->E1_BASCOM2
		//_nBasesCm[3] += SE1->E1_BASCOM3
		//_nBasesCm[4] += SE1->E1_BASCOM4
		//_nBasesCm[5] += SE1->E1_BASCOM5
	
		_nElem := 0
		For _nn := 1 To Len(aTotPar)
			If aTotPar[_nn,1] == SE1->E1_PREFIXO+SE1->E1_NUM
				_nElem := _nn
				Exit
			EndIf
		Next
		If	_nElem == 0
			AADD(aTotPar,Array(2))
			_nElem := Len(aTotPar)
			aTotPar[_nElem,1] := SE1->E1_PREFIXO+SE1->E1_NUM
			aTotPar[_nElem,2] := 0.00
		EndIf
		aTotPar[_nElem,2] += SE1->E1_VALOR
		_TotOri += SE1->E1_VALOR
		_TotAlt  += SE1->E1_VALOR
		SE1->(DbSkip())
	EndDo
	For _n := 1 to Len(aCols)
		For _nn := 1 To Len(aTotPar)
			If aTotPar[_nn,1] == aCols[_n,01]+aCols[_n,02]
				aCols[_n,06]   := aTotPar[_nn,2]
				_aCopia[_n,06] := aTotPar[_nn,2]
				Exit
			EndIf
		Next
	Next
	ntamaCols := Len(aCols)
	
	Do While .T.
		cCadastro := OemToAnsi("Composição do Contas a Receber")
		//@ 000,000 TO 210,500 DIALOG oDlg1 TITLE cCadastro
		@ 000,000 TO 280,500 DIALOG oDlg1 TITLE cCadastro
		//@ 004,005 TO 70,205 MULTILINE MODIFY DELETE VALID u_SomePar() //LineOk() FREEZE 1
		@ 004,005 TO 100,230 MULTILINE MODIFY DELETE  OBJECT oMultiline VALID u_SomePar() //LineOk() FREEZE 1
		@ 105,020 Say "Valor Orig. R$."
		@ 105,080 Get _TotOri Object oGet1 SIZE 50,7 Picture "@E 9,999,999.99" When .F.
		@ 105,200 BMPBUTTON TYPE 01 ACTION If(ValTudo(),Close(oDlg1),.F.) //oOk()
		@ 120,020 Say "Valor Alterado    R$."
		@ 120,080 Get _TotAlt Object oGet2 SIZE 50,7 Picture "@E 9,999,999.99" When .F.
		@ 120,200 BMPBUTTON TYPE 02 ACTION u_CancAcols() //Cancela
		omultiline:nmax:=ntamaCols
	
		ACTIVATE DIALOG oDlg1 CENTERED
	
		If ValTudo()
			Exit
		EndIf
	EndDo
	
	// Verificar quantas parcelas sobraram e qual a última útil
	_nQtdPrc := 0
	_nUltUti := 0
	For _x := 1 to Len(aCols)
		If !(GDDeleted(_x) .Or. aCols[_x,5] <= 0) // Parcela útil
			_nQtdPrc++
			_nUltUti := _x
		EndIf
	Next
	
	//_nBasesCd[1] := If(_nBasesCm[1]>0,Round(_nBasesCm[1]/_nQtdPrc,2),0)
	//_nBasesCd[2] := If(_nBasesCm[2]>0,Round(_nBasesCm[2]/_nQtdPrc,2),0)
	//_nBasesCd[3] := If(_nBasesCm[3]>0,Round(_nBasesCm[3]/_nQtdPrc,2),0)
	//_nBasesCd[4] := If(_nBasesCm[4]>0,Round(_nBasesCm[4]/_nQtdPrc,2),0)
	//_nBasesCd[5] := If(_nBasesCm[5]>0,Round(_nBasesCm[5]/_nQtdPrc,2),0)
	
	DbSelectArea("SE1")
	DbSetOrder(1)
	For _x := 1 to Len(aCols)
		If DbSeek(xFilial("SE1")+aCols[_x,1]+aCols[_x,2]+aCols[_x,3]+aCols[_x,10],.F.)
			RecLock("SE1",.F.)
			If GDDeleted(_x) .Or. aCols[_x,5] <= 0 // Deletado
				DbDelete()
			Else
				SE1->E1_VENCTO  := aCols[_x,4]
				SE1->E1_VENCREA := DataValida(aCols[_x,4])
				SE1->E1_VENCORI := aCols[_x,4]
				SE1->E1_VALOR   := aCols[_x,5]
				SE1->E1_SALDO   := aCols[_x,5]
				SE1->E1_VLCRUZ  := aCols[_x,5]
			EndIf
			MsUnLock()
		EndIf
	Next
Return(.T.)


/*/{Protheus.doc} SomePar
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
User Function SomePar()
	_TotAlt  := 0.00
	For _x := 1 to Len(aCols)
		If !GDDeleted(_x) // Não Deletado
			If aCols[_x,5] <= 0
				aCols[_x,5] := 0
			EndIf
			_TotAlt += aCols[_x,5]
		EndIf
	Next
	oGet1:Refresh()
	oGet2:Refresh()
	oMultiline:Refresh()
Return(.T.)


/*/{Protheus.doc} ValTudo
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
Static Function ValTudo()
	_Volta := .T.
	For _nn := 1 To Len(aTotPar)
		_nSoma := 0.00
		For _x := 1 to Len(aCols)
			If aCols[_x,5] <= 0
				aCols[_x,5] := 0
			EndIf
			If !GDDeleted(_x) .And. aTotPar[_nn,1] == aCols[_x,1]+aCols[_x,2]            // Não Deletado
				_nSoma += aCols[_x,5]
			EndIf
		Next
		If aTotPar[_nn,2] # _nSoma
			_Volta := .F.
			Alert("Não alterar o Total Por Prefixo+Numero")
			Exit
		EndIf
	Next
Return(_Volta)


/*/{Protheus.doc} CancAcols
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
User Function CancAcols()
	aCols := {}
	For _nN := 1 to Len(_aCopia)
		AADD(aCols,Array(Len(aHeader)+1))
		For _nN1 := 1 to Len(_aCopia[_nN])
			aCols[_nN,_nN1] := _aCopia[_nN,_nN1]
		Next
	Next
	u_SomePar()
Return(.T.)


/*/{Protheus.doc} LibFat
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
User Function LibFat() // 0K 09/10
	Private _aArea
	
	_C9_CLIENTE := SC9->C9_CLIENTE
	_C9_LOJA    := SC9->C9_LOJA
	
	DbSelectArea("SC9")
	_aArea := GetArea()
	
	DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	If !Empty(_cFiltro)
		Set Filter to
		Set Filter to &(_cFiltro)
	EndIf
	
	_cNaoPode := ""
	_cSC9Atu  := ""
	_cSC9Pula := ""
	DbSeek(xFilial("SC9")+MV_xPAR02,.T.)
	ProcRegua(LastRec())
	Do While SC9->C9_FILIAL ==xFilial("SC9") .And. SC9->C9_PEDIDO <= MV_xPAR03 .And. SC9->(!Eof())
		IncProc()
		If !SC9->C9_PEDIDO $ _cSC9Pula
			SC5->(DbSetOrder(1))
			SC5->(DbSeek(xFilial("SC5")+SC9->C9_PEDIDO,.F.))
	
			If !(SC5->C5_TIPO $ "DB") .And. Posicione("SA1",1,xFilial("SA1")+SC9->C9_CLIENTE+SC9->C9_LOJA,"A1_MSBLQL") == '1' // Sim
				Alert("Pedido " + SC9->C9_PEDIDO + " - Cliente Bloqueado - Não Será Faturado")
				_cSC9Pula += "//" + SC9->C9_PEDIDO
			Else
				If SC9->C9_PEDIDO # _cSC9Atu
					_cIttSC9 := u_AvalCST(SC9->C9_PEDIDO,.F.)
					_cSC9Atu := SC9->C9_PEDIDO
				EndIf
				If SC9->C9_ITEM $ _cIttSC9
					Alert("Pedido " + SC9->C9_PEDIDO + "Possui Item com CST Errada - Não Será Faturado")
					_cSC9Pula += "//" + SC9->C9_PEDIDO
				EndIf
			EndIf
		EndIf
	
		SC9->(DbSkip())
	EndDo
	
	SC9->(DbSeek(xFilial("SC9")+MV_xPAR02,.T.))
	ProcRegua(LastRec())
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO <= MV_xPAR03 .And. SC9->(!Eof())
		IncProc()
		RecLock("SC9",.F.)
		If !SC9->C9_PEDIDO $ _cSC9Pula .And. Empty(SC9->C9_BLEST+SC9->C9_BLCRED)
		//.And.; SC9->C9_CLIENTE == _C9_CLIENTE .And. SC9->C9_LOJA == _C9_LOJA
		//Alteração realiada pois não permitia realizar multiplos faturamentos de clientes diferentes
		//Juliana Leme  - 26/08/2016
			SC9->C9_OK := cMarca
			SC9->C9_RISCO := " "
		Else
			SC9->C9_OK := "  "
			SC9->C9_RISCO := "E"
		EndIf
		MsUnLock()
		SC9->(DbSkip())
	EndDo
	RestArea(_aArea)
Return(.T.)


/*/{Protheus.doc} BackPar
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
User FuncTion BackPar()
	// Fecha o Browse e volta para o loop principal
	_lNewBrow := .T.
	CloseBrowse()
Return(.T.)


/*/{Protheus.doc} AjustaNI
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
Static Function AjustaNI()
	Dbselectarea("SA1")
	DbsetOrder(1)
	
	Dbselectarea("SF4")
	DbsetOrder(1)
	
	DbSelectArea("SBE")
	DbSetOrder(1)
	
	DbSelectArea("SF5")
	DbSetOrder(1)
	
	DbSelectArea("SD3")
	DbSetOrder(1)
	
	DbSelectArea("SC6")
	DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	
	DbSelectArea("SBF")
	DbSetOrder(1)
	
	DbSelectArea("SB2")
	SB2->(DbSetOrder(1))
	
	// Le o C9 marcado e carrega o TRB0
	DbSelectArea("SDC")
	DbSetOrder(1)  //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
	
	DbSelectArea("SC9")
	DBOrderNickName("SC9ITEM")
	//DbSetOrder(9) // FILIAL+OK+PEDIDO+ITEM+C9_CTRLE
	DbSeek(xFilial("SC9")+cMarca,.T.)
	ProcRegua(nQuantR)
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_OK == cMarca .And. SC9->(!Eof())
		If !Empty(SC9->C9_BLEST+SC9->C9_BLCRED)
			IncProc()
			SC9->(DbSkip())
			Loop
		EndIf
	
		SC5->(DbSeek(xFilial("SC5")+SC9->C9_PEDIDO,.F.))
		If SC5->C5_TIPO # "N"
			IncProc()
			SC9->(DbSkip())
			Loop
		EndIf
	
		SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.))
		SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.))
	
		_xlSitOk := "I" // Tratar Importado/Nacional
		If (Left(SC6->C6_CLASFIS,1) $ "05" .And. Right(AllTrim(SC6->C6_PRODUTO),1) #  "I") .Or.;  // NACIONAL-OK
			(Left(SC6->C6_CLASFIS,1) $ "38" .And. Right(AllTrim(SC6->C6_PRODUTO),1) == "I")        // IMPORTADO-OK
			// Situação está correta
			_xlSitOk := " " // Não tratar nada
		ElseIf Left(SC6->C6_CLASFIS,1) == "0"
			// Situação está correta
			_xlSitOk := " " // Não tratar nada
		EndIf
	
		SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE + SC5->C5_LOJACLI,.F.))
		// By Roberto Oliveira 23/09/2015
		// Controle de acondicionamento no código
		// O parâmentro MV_XTRCCOD contém quais raiz de CNPJs que devem receber
		// códigos específicos para diferentes acondicionamentos.
		If Left(SA1->A1_CGC,8) $ GetMv("MV_XTRCCOD")
			_xlSitOk := AllTrim(_xlSitOk) + "A" // Tratar mais o acondicionamento
		EndIf
	
		If Empty(_xlSitOk) // Se nada a tratar
			IncProc()
			SC9->(DbSkip())
			Loop
		EndIf
	
		If SDC->(DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.F.))
			_cProdBase := Left(SC6->C6_PRODUTO,10)
		Else
			_cProdBase := AllTrim(SC6->C6_PRODUTO)
		EndIf
	
		_cNewProd := _cProdBase
	
		If SB1->B1_TIPO == "PA"
			If "A" $ _xlSitOk .And. !Empty(SC6->C6_ACONDIC)// Tratar o acondicionamento
				If SC6->C6_ACONDIC == "B"
					// Para bobinas não incluir a metragem
					_cNewProd := _cNewProd+SC6->C6_ACONDIC+StrZero(0,5)
				Else
					// Pàra os demais acondicionamentos, incluir a metragem
					_cNewProd := _cNewProd+SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5)
				EndIf
			EndIf
			
			If ("I" $ _xlSitOk) // Tratar Importado/Nacional
				If (_cProdBase <> _cNewProd + "I")
					_cNewProd := _cNewProd + "I"
				Else
					_cNewProd := _cProdBase
				EndIf
			EndIf
	
			_cProdBase := Left((_cProdBase + Space(Len(SB1->B1_COD))),Len(SB1->B1_COD))
			_cNewProd  := Left((_cNewProd  + Space(Len(SB1->B1_COD))),Len(SB1->B1_COD))
		EndIf
	
		If _cNewProd == SC6->C6_PRODUTO // É o mesmo produto... não tem o que corrigir
			IncProc()
			SC9->(DbSkip())
			Loop
		EndIf
	
		_lTemErro:= .F. // Controle se deu erro em algum movimento. Se der cancelar todos os movimento e não faturar esse item
		_nRegSC6 := SC6->(Recno())
	
		_aLibSC9 := {} // {ACONDIC,QUANTIDADE,Recno SC9}
		_nTotSC9 := 0
		_cChvSC9 := (SC9->C9_PEDIDO+SC9->C9_ITEM) //PRECISA DA SEQUENCIA????
		_nProxSC9 := 0
	
		// Reposiciona o cadastro do produto
		SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.))
		SF4->(DbSeek(xFilial("SF4")+SC6->C6_TESORI,.F.))
	
		_lTemErro := FatTrans(_cProdBase,_cNewProd)
	
		DbSelectArea("SC9")
		DBOrderNickName("SC9ITEM")
		//DbSetOrder(9) // FILIAL+OK+PEDIDO+ITEM
		If _lTemErro //Deu erro em algo
			// Deu erro e esse pedido não pode ser faturado
			Do While DbSeek(xFilial("SC9")+cMarca+_cChvSC9,.F.)
				RecLock("SC9",.F.)
				SC9->C9_OK := " "
			EndDo
			Alert("O Item " + Right(_cChvSC9,2) + " do Pedido " + Left(_cChvSC9,6) + " não será faturado -> Erro na atualização de tabelas")
			If !MsgBox("Continua o processamento sem o Item " + Right(_cChvSC9,2) + "?","Confirma?","YesNo")
				_lRet := .F.
				Exit
			EndIf
		EndIf
		SC9->(DbGoTo(_nProxSC9))
	EndDo
Return(.T.)


/*/{Protheus.doc} FatTrans
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined
@param _cProdBase, , descricao
@param _cNewProd, , descricao
@type function
/*/
Static Function	FatTrans(_cProdBase,_cNewProd)
	Local _cProdBase,_cNewProd
	
	Begin Transaction
	
	// Verifica se existe o novo produto e efetua a atualização dos dados
	u_ReplSB1(_cProdBase,_cNewProd)
	
	_PP := "Ponto de parada para debug"
	
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_OK == cMarca .And. SC9->(!Eof()) .And. ;
		(SC9->C9_PEDIDO+SC9->C9_ITEM) == _cChvSC9 .And. !_lTemErro
		IncProc()
		If !Empty(SC9->C9_BLEST+SC9->C9_BLCRED)
			SC9->(DbSkip())
			Loop
		EndIf
	
		SDC->(DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.F.))
		_cLocaliz := If(SDC->(Found()),SDC->DC_LOCALIZ,Space(Len(SDC->DC_LOCALIZ)))
		_nTotSC9 += SC9->C9_QTDLIB
		_nRgAtC9 := SC9->(Recno())
	
		Aadd(_aLibSC9,{_cLocaliz,SC9->C9_QTDLIB,SC9->(Recno()),SC9->C9_SEQOS})
	
		U_CDLibEst("E",SC9->C9_PRODUTO,SC9->C9_QTDLIB,SC9->C9_LOCAL,_cLocaliz,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN, ,  ,  ,.T.)
	
		DbSelectArea("SC9")
		DBOrderNickName("SC9ITEM") // Dar este DBOrderNickName porque o retorno da função CDLibEst volta com o SC9 na ordem 1
		SC9->(DbGoTo(_nRgAtC9))
		If SF4->F4_ESTOQUE == "S" .and. SB1->B1_LOCALIZ=="S"
			// Fazer movimento Interno SD3 540
			// Tira o saldo do produto na quantidade
			// _lTemErro := (u_MoviSD3("540",SC9->C9_PRODUTO,SB1->B1_UM,SC9->C9_QTDLIB,SC9->C9_LOCAL,_cLocaliz))
	
			// Efetua Transferência RE4/DE4
			_lTemErro := (u_MoviTrf(SC9->C9_PRODUTO,_cNewProd,SC9->C9_LOCAL, SC9->C9_LOCAL, _cLocaliz, _cLocaliz, SC9->C9_QTDLIB))
			//_lTemErro :=  U_CBCTraProdI(SC9->C9_PRODUTO,_cNewProd,SC9->C9_LOCAL,SC9->C9_LOCAL,SC9->C9_QTDLIB,"PV"+SC9->(C9_PEDIDO),_cLocaliz,_cLocaliz) 
	
			DbSelectArea("SC9")
			DBOrderNickName("SC9ITEM") // Dar este DBOrderNickName porque o retorno da função CDLibEst volta com o SC9 na ordem 1
			SC9->(DbGoTo(_nRgAtC9))
		EndIf
		SC9->(DbSkip())
	EndDo
	_nProxSC9 := SC9->(Recno())
	
	If _lTemErro // Tem erro
		// Continuar o loop para achar o próximo SC9 válido
		DbSelectArea("SC9")
		DBOrderNickName("SC9ITEM")
		Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_OK == cMarca .And. SC9->(!Eof()) .And. ;
			(SC9->C9_PEDIDO+SC9->C9_ITEM) == _cChvSC9
			SC9->(DbSkip())
		EndDo
		DisarmTransaction()
	Else
	
		SC6->(DbGoTo(_nRegSC6))
		_cPrxIt := "  "
	
		If _nTotSC9 >= SC6->C6_QTDVEN .And. SC6->C6_QTDENT == 0
			// Estou faturando o total do item
			// Trocar código no SC6 e alterar SB2
	
			SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
			If SB2->(DbSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL,.F.))
				SB2->(RecLock("SB2",.F.))
				SB2->B2_QPEDVEN := (SB2->B2_QPEDVEN - SC6->C6_QTDVEN)
				SB2->(MsUnLock())
			EndIf
	
			RecLock("SC6",.F.)
			SC6->C6_PRODUTO := _cNewProd
			MsUnLock()
			_cPrxIt := SC6->C6_ITEM
	
			SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
			If !SB2->(DbSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL,.F.))
				CriaSB2(SC6->C6_PRODUTO,SC6->C6_LOCAL)
				SB2->(DbSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL,.F.))
			EndIf
	
			SB2->(RecLock("SB2",.F.))
			SB2->B2_QPEDVEN := (SB2->B2_QPEDVEN + SC6->C6_QTDVEN)
			SB2->(MsUnLock())
		Else
			// Já tenho outro ítem faturado?
			// Qual a quantidade que tenho que transferir para outro item ?
			SC6->(DbSetOrder(1))
			SC6->(DbSeek(xFilial("SC6")+Left(_cChvSC9,Len(SC9->C9_PEDIDO))))
	
			_nIttSC6 := 0		// Qual outro item já criado para esse cara?
			_lUsaMesmo := .F.
			// Estou criando esta variável para não alterar muito a programação original.
			// Se estiver correto, as linhas desprezadas pela aplicalão da _lUsaMesmo podem ser retiradas.
	
			// Esta variável controla se deve ou não usar o mesmo item em caso de precisar
			// criar outro SC6 (produto + acond + importado)
			// É utilizada juntamente com a _nIttSC6
	
			Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == Left(_cChvSC9,Len(SC9->C9_PEDIDO)) .And. SC6->(!Eof())
				// By Roberto Oliveira - 27/02/14
				// Estou tirando este IF e forçar a criação de novo item para não dar possível erro no valor do item
				// tendo em vista que pode haver diferença entre o item que estou faturando agora com o item que já
				// foi faturado anteriormente.
				// Assim sendo, a variável _nIttSC6 mentem-se com valor 0 e força a criação de novo item
				//
				If SC6->C6_ITEMIMP == Right(_cChvSC9,Len(SC9->C9_ITEM))
					_nIttSC6 := SC6->(Recno()) // Qual outro item já criado para esse cara?
				EndIf
				If SC6->C6_ITEM > _cPrxIt
					_cPrxIt := SC6->C6_ITEM
				EndIf
				SC6->(DbSkip())
			EndDo
	
			SC6->(DbGoTo(_nRegSC6))
			_cAtuIt := SC6->C6_ITEM
			_cPrxIt := Soma1(_cPrxIt)
	
			If SC6->C6_QTDENT >= SC6->C6_QTDVEN .And. _nIttSC6 == 0 // Não tenho outro registro
				// não tenho quantidade a ser faturada para jogar para outro item e também não tenho
				// outro item já criado
				// não posso criar outro item porque alteraria o valor do pedido de venda
				_lTemErro := .T.
			Else
				// Quanto posso tirar desse item?
				// O menor entre (Quant.Vendida - Quant.Entregue) e _nTotSC9
				//SC6->(DbGoTo(_nRegSC6))
				RegToMemory("SC6",.F.)
				_nQtdTrf := Max((SC6->C6_QTDVEN-SC6->C6_QTDENT),0)
				_nQtdTrf := Min(_nQtdTrf,_nTotSC9)
	
				RecLock("SC6",.F.)
				SC6->C6_QTDVEN := Round((SC6->C6_QTDVEN - _nQtdTrf),TamSX3("C6_QTDVEN")[2])
				SC6->C6_QTDEMP := Round((SC6->C6_QTDEMP - _nTotSC9),TamSX3("C6_QTDEMP")[2])
				SC6->C6_VALOR  := Round((SC6->C6_QTDVEN * SC6->C6_PRCVEN),TamSX3("C6_VALOR")[2])
				If !Empty(SC6->C6_LANCES)
					SC6->C6_LANCES := (SC6->C6_QTDVEN / SC6->C6_METRAGE)
				EndIf
				MsUnLock()
	
				SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
				If !SB2->(DbSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL,.F.))
					CriaSB2(SC6->C6_PRODUTO,SC6->C6_LOCAL)
					SB2->(DbSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL,.F.))
				EndIf
	
				SB2->(RecLock("SB2",.F.))
				SB2->B2_QPEDVEN := (SB2->B2_QPEDVEN - _nQtdTrf)
				SB2->(MsUnLock())
	
				If _nIttSC6 == 0 .Or. !_lUsaMesmo	// Se não tenho outro ou não quero usar o mesmo,
					// forço a criação de um novo
					_nQtCpo := SC6->(FCount())
					RecLock("SC6",.T.)
					For nCntFor := 1 To _nQtCpo
						If AllTrim(FieldName(nCntFor)) == "C6_ITEM"
							FieldPut(nCntFor,_cPrxIt)
						Else
							FieldPut(nCntFor,M->&(FieldName(nCntFor)))
						EndIf
					Next
					SC6->C6_QTDVEN  := _nQtdTrf
					SC6->C6_QTDEMP  := _nTotSC9
					SC6->C6_ITEMIMP := M->C6_ITEM
					SC6->C6_QTDENT  := 0
					SC6->C6_PRODUTO := _cNewProd
				Else
					SC6->(DbGoTo(_nIttSC6)) // Posiciona no item achado
					RecLock("SC6",.F.)
					SC6->C6_QTDVEN := SC6->C6_QTDVEN + _nQtdTrf
					SC6->C6_QTDEMP := SC6->C6_QTDEMP + _nTotSC9
					_cPrxIt := SC6->C6_ITEM
				EndIf
				SC6->C6_PRCVEN := M->C6_PRCVEN // Corrijo o preço de venda.. pode ter havido alteração
				SC6->C6_VALOR  := Round((SC6->C6_QTDVEN * SC6->C6_PRCVEN),TamSX3("C6_VALOR")[2])
				// If !Empty(SC6->C6_LANCES) Troquei pelo IF Abaixo -
				If SC6->C6_METRAGE > 0
					SC6->C6_LANCES := (SC6->C6_QTDVEN / SC6->C6_METRAGE)
				EndIf
				MsUnLock()
	
				SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
				If !SB2->(DbSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL,.F.))
					CriaSB2(SC6->C6_PRODUTO,SC6->C6_LOCAL)
					SB2->(DbSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL,.F.))
				EndIf
	
				SB2->(RecLock("SB2",.F.))
				SB2->B2_QPEDVEN := (SB2->B2_QPEDVEN + _nQtdTrf)
				SB2->(MsUnLock())
	
				If SC6->C6_ACONDIC == "B"
					DbSelectArea("SZE")
					DbSetOrder(2) // ZE_FILIAL+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
					_nLances := SC6->C6_LANCES
					DbSeek(xFilial("SZE") + SC6->C6_NUM + _cAtuIt,.F.)
					Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_PEDIDO == SC6->C6_NUM .And. ;
						SZE->ZE_ITEM == _cAtuIt .And. _nLances > 0 .And. SZE->(!Eof())
						If SZE->ZE_STATUS == "E" // Bobina empenhada
							_nLances--
							RecLock("SZE",.F.)
							SZE->ZE_ITEM := SC6->C6_ITEM
							MsUnLock()
	
							DbSelectArea("SZL")
							DbSetOrder(4) // ZL_FILIAL+ZL_NUMBOB
							If DbSeek(xFilial("SZL") + SZE->ZE_NUMBOB,.F.)
								RecLock("SZL",.F.)
								SZL->ZL_ITEMPV := SC6->C6_ITEM
								MsUnLock()
							EndIf
							DbSelectArea("SZE")
							DbSetOrder(2) // ZE_FILIAL+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
							// Dá novo dbseek pois alterei a chave de indice
							DbSeek(xFilial("SZE") + SC6->C6_NUM + _cAtuIt,.F.)
						Else
							DbSkip()
						EndIf
					EndDo
				EndIf
			EndIf
			If _lTemErro // Tenho erro
				DisarmTransaction()
			EndIf
		EndIf
	
		If !_lTemErro // Não tem erro
	
			// Devolver o saldos para o novo produto e refazer as liberações
			For _nRegsC9 := 1 to Len(_aLibSC9)
	
				SC9->(DbGoTo(_aLibSC9[_nRegsC9,3]))
	
				cQuery :="SELECT TOP 1 C9_PEDIDO,C9_ITEM,C9_SEQUEN,R_E_C_N_O_ AS NUMREG"
				cQuery +=" FROM " + RetSqlName("SC9")  + " C9"
				cQuery +=" WHERE C9_FILIAL = '" +xFilial("SC9")+"'"
				cQuery +=" AND C9_PEDIDO + C9_ITEM = '" + SC9->C9_PEDIDO+_cPrxIt+"'"
				cQuery +=" AND C9.D_E_L_E_T_ = ''"
				cQuery +=" ORDER BY C9_PEDIDO,C9_ITEM,C9_SEQUEN DESC"
	
				If Select("TRB")>0
					DbSelectArea("TRB")
					DbCloseArea()
				EndIf
				TCQUERY cQuery NEW ALIAS "TRB"
				DbSelectArea("TRB")
				DbGotop()
	
				If TRB->(Eof())
					_xC9_SEQ := "01"
				ElseIf TRB->NUMREG == _aLibSC9[_nRegsC9,3]
					_xC9_SEQ := TRB->C9_SEQUEN
				Else
					_xC9_SEQ := Soma1(TRB->C9_SEQUEN)
				EndIf
	
				If Select("TRB")>0
					DbSelectArea("TRB")
					DbCloseArea()
				EndIf
	
				_cOldIt := SC9->C9_ITEM
				_cOldSq := SC9->C9_SEQUEN
				_cOldOs := _aLibSC9[_nRegsC9,4]
	
				SC9->(RecLock("SC9",.F.))
				SC9->C9_PRODUTO := _cNewProd
				SC9->C9_ITEM    := _cPrxIt
				SC9->C9_SEQUEN  := _xC9_SEQ
				SC9->C9_SEQOS   := _aLibSC9[_nRegsC9,4]
				SC9->(MsUnLock())
	
				If SF4->F4_ESTOQUE == "S"
					// Devolve a quantidade no produto
	
					SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO,.F.))
					// Fazer movimento Interno SD3 040
					// Adiciona saldo do produto na quantidade
					//_lTemErro := (u_MoviSD3("040",SC9->C9_PRODUTO,SB1->B1_UM,_aLibSC9[_nRegsC9,2],SC9->C9_LOCAL,_aLibSC9[_nRegsC9,1]))
					If _lTemErro
						DisarmTransaction()
						Exit
					EndIf
					u_CDLibEst("L",SC9->C9_PRODUTO,_aLibSC9[_nRegsC9,2],SC9->C9_LOCAL,_aLibSC9[_nRegsC9,1],SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN, ,  ,"7",.T.)
					//
					If SC9->C9_ITEM # _cOldIt .or. SC9->C9_SEQUEN # _cOldSq
						ArrumaZRZO()
					EndIf
				EndIf
			Next
		EndIf
	EndIf
	_PP := "Ponto de parada para debug"
	
	End Transaction
Return(_lTemErro)


/*/{Protheus.doc} JuntaC9
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
Static Function JuntaC9()
	SDC->(DbSetOrder(1)) //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
	
	DbSelectArea("SC9")
	DBOrderNickName("SC9ITEM")
	//DbSetOrder(9) // FILIAL+OK+PEDIDO+ITEM+C9_CTRLE
	
	_aC9Chave := {}
	DbSeek(xFilial("SC9")+cMarca,.T.)
	ProcRegua(nQuantR)
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_OK == cMarca .And. SC9->(!Eof())
		IncProc()
	
		If Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED)
	
			SDC->(DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.F.))
	
			_cChave := SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_CTRLE+SDC->DC_LOCAL+SDC->DC_LOCALIZ
	
			_nEleChv := 0
			For _nChv := 1 to Len(_aC9Chave)
				If _aC9Chave[_nChv,1] == _cChave
					_nEleChv := _nChv
					Exit
				EndIf
			Next
			If _nEleChv == 0 // Não achei nada
				Aadd(_aC9Chave,{_cChave,SC9->(Recno())})
			ElseIf SDC->(!Eof()) .And. SC9->C9_QTDLIB == SDC->DC_QUANT
				// Pega a Quantidade
				_nQtdAgl := SC9->C9_QTDLIB
	
				// Deleta o SC9
				SC9->(RecLock("SC9",.F.))
				SC9->(DbDelete())
				SC9->(MsUnLock())
	
				// Deleta o SDC e o SC9
				SDC->(RecLock("SDC",.F.))
				SDC->(DbDelete())
				SDC->(MsUnLock())
	
				// Posiciona no SC9 principal
				SC9->(DbGoTo(_aC9Chave[_nEleChv,2]))
				SC9->(RecLock("SC9",.F.))
				SC9->C9_QTDLIB := SC9->C9_QTDLIB + _nQtdAgl
				SC9->(MsUnLock())
	
				SDC->(DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.F.))
				SDC->(RecLock("SDC",.F.))
				SDC->DC_QUANT   := SDC->DC_QUANT   + _nQtdAgl
				SDC->DC_QTDORIG := SDC->DC_QTDORIG + _nQtdAgl
				SDC->(MsUnLock())
			EndIf
		EndIf
		SC9->(DbSkip())
	EndDo
Return(.T.)


/*/{Protheus.doc} MoviSD3
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined
@param _xxTm, , descricao
@param _xxPR, , descricao
@param _xxUM, , descricao
@param _xxQT, , descricao
@param _xxLC, , descricao
@param _xxLZ, , descricao
@type function
/*/
User Function MoviSD3(_xxTm,_xxPR,_xxUM,_xxQT,_xxLC,_xxLZ) // OK 09/10
	// Verificar se tem a localização no SBE
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+_xxPR,.F.))
	If !Empty(_xxLZ)
		DbSelectArea("SBE")
		DbSetOrder(1)
		If !DbSeek(xFilial("SBE") + _xxLC + _xxLZ,.F.)
			_cAcon := Left(_xxLZ,1)
			If _cAcon == "T"
				_cDesLo :=  "Retalho de "
			ElseIf _cAcon == "B"
				_cDesLo :=  "Bobina de "
			ElseIf _cAcon == "M"
				_cDesLo :=  "Carretel de Mad.de "
			ElseIf _cAcon == "C"
				_cDesLo :=  "Carretel de "
			ElseIf _cAcon == "R"
				_cDesLo :=  "Rolo de "
			ElseIf _cAcon == "L"
				_cDesLo :=  "Blister de "
			EndIf
			//_cDesLo +=  Str(_cLanc,5) + " metros"
			_cDesLo +=  Str(Val(Substr(_xxLZ,2,5)),5) + " " + Posicione("SAH",1,xFilial("SAH")+SB1->B1_UM,"AH_DESCPO")
	
			RecLock("SBE",.T.)
			SBE->BE_FILIAL   := xFilial("SBE")
			SBE->BE_LOCAL    := _xxLC
			SBE->BE_LOCALIZ  := _xxLZ
			SBE->BE_DESCRIC  := _cDesLo
			SBE->BE_PRIOR    := "ZZZ"
			SBE->BE_STATUS   := "1"
			MsUnLock()
		EndIf
	EndIf
	
	SB2->(DbsetOrder(1))
	SB2->(DbSeek(xFilial("SB2")+_xxPR+_xxLC,.F.))
	If !Empty(SB2->B2_STATUS)
		RecLock("SB2",.F.)
		SB2->B2_STATUS := "  "
		MsUnLock()
	EndIf
	
	lMsErroAuto := .F.
	
	If _xxLC == "99" .Or. Empty(_xxLZ)
		// Chao de fábrica OU prod. que não contr. localização,
		// não pode ser por execauto... da erro
		// Fazer o Movimento na mão
		SB1->(DbSeek(xFilial("SB1")+_xxPR,.F.))
	
		cNumSeq := ProxNum()
	
		If !SB2->(DbSeek(xFilial("SB2")+_xxPR+_xxLC,.F.))
			CriaSB2(_xxPR,_xxLC)
			SB2->(DbSeek(xFilial("SB2")+_xxPR+_xxLC,.F.))
		EndIf
	
		RecLock("SB2",.F.)
	
		DbSelectArea("SD3")
		RecLock("SD3",.T.)
		SD3->D3_FILIAL  := xFilial("SD3")
		SD3->D3_TM      := _xxTM
		SD3->D3_COD     := _xxPR
		SD3->D3_DOC     := "FATUR"
		SD3->D3_UM      := _xxUM
		SD3->D3_QUANT   := _xxQT
		SD3->D3_CF      := If(_xxTM <= "499","DE0","RE0")
		SD3->D3_LOCAL   := _xxLC
		SD3->D3_EMISSAO := dDatabase // MV_PAR01
		SD3->D3_NUMSEQ  := cNumSeq
		SD3->D3_TIPO    := SB1->B1_TIPO
		SD3->D3_USUARIO := cUserName
		SD3->D3_CHAVE   := "E0"
		SD3->D3_GRUPO   := SB1->B1_GRUPO
		SD3->D3_SEGUM   := SB1->B1_SEGUM
		SD3->D3_CONTA   := SB1->B1_CONTA
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pega os 15 custos medios atuais            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o custo da movimentacao              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCusto := GravaCusD3(aCM)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o saldo atual (VATU) com os dados do SD3     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_lErrAtu := B2AtuComD3(aCusto,,.F.) // .F.->Não mostra help se der erro // Retorna .T. se deu erro na atualização
	
		SB2->(MsUnLock())
		SD3->(MsUnLock())
	Else
		_aVetor:={{"D3_TM"      , _xxTM ,NIL},;
		{"D3_COD"     , _xxPR ,NIL},;
		{"D3_UM"      , _xxUM ,NIL},;
		{"D3_QUANT"   , _xxQT ,NIL},;
		{"D3_LOCAL"   , _xxLC ,NIL},;
		{"D3_EMISSAO" , dDataBase ,NIL},;
		{"D3_LOCALIZ" , _xxLZ ,NIL}}
		lMsErroAuto := .F.
		_xVolta := MSExecAuto({|x,y| Mata240(x,y)},_aVetor,3)
		If lMsErroAuto
			MostraErro()
		EndIf
	EndIf
	If !lMsErroAuto .And. _xxTM == "040" .And. _xxLC # "99" .And. !Empty(_xxLZ)// Devolução ...
		// Verificar se efetuou a distribuição
	
		DbSelectArea("SDA")
		DbSetOrder(1) // DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ
		If !DbSeek(xFilial("SDA")+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ,.F.)
			lMsErroAuto := .T.
		ElseIf SDA->DA_SALDO > 0
			_RegSDA := Recno()
			aCAB  := {	{"DA_PRODUTO" ,SDA->DA_PRODUTO             , nil},;
			{"DA_QTDORI"  ,SDA->DA_QTDORI              , nil},;
			{"DA_SALDO"   ,SDA->DA_SALDO               , nil},;
			{"DA_DATA"    ,SDA->DA_DATA                , nil},;
			{"DA_LOCAL"   ,SDA->DA_LOCAL               , nil},;
			{"DA_DOC"     ,SDA->DA_DOC                 , nil},;
			{"DA_ORIGEM"  ,SDA->DA_ORIGEM              , nil},;
			{"DA_NUMSEQ"  ,SDA->DA_NUMSEQ              , nil},;
			{"DA_QTSEGUM" ,SDA->DA_QTSEGUM             , nil},;
			{"DA_QTDORI2" ,SDA->DA_QTDORI2             , nil}}
			aITENS:={ { {"DB_ITEM"    , "0001"                     , nil},;
			{"DB_LOCALIZ" , _xxLZ                      , nil},;
			{"DB_QUANT"   , SDA->DA_SALDO              , nil},;
			{"DB_DATA"    , SDA->DA_DATA               , nil},;
			{"DB_ESTORNO" ," "                         , nil} }}
			lMsErroAuto := .F.
			msExecAuto({|x,y|mata265(x,y)},aCAB,aITENS)
			If lMsErroAuto
				MostraErro()
			EndIf
		EndIf
	EndIf
Return(lMsErroAuto)


/*/{Protheus.doc} SF2460I
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
User Function SF2460I()
	// Ponto de entrada para gravar o LOG do pedido faturado
	// Guardar o posicionamento das tabelas a serem utilizadas
	_aArea := GetArea()
	
	DbSelectArea("SF2")
	_aAreaF2 := GetArea()
	
	DbSelectArea("SC5")
	_aAreaC5 := GetArea()
	DbSetOrder(1)
	
	DbSelectArea("CD2")
	DbSetOrder(1) //CD2_FILIAL+CD2_TPMOV+CD2_SERIE+CD2_DOC+CD2_CODCLI+CD2_LOJCLI+CD2_ITEM+CD2_CODPRO+CD2_IMP
	
	DbSelectArea("SD2")
	_aAreaD2 := GetArea()
	DbSetOrder(3) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	
	_aD2Peds := {}
	DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.)
	Do While SD2->D2_FILIAL == xFilial("SD2") .And. ;
		SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == ;
		SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA .And. SD2->(!Eof())
	
		nPos := aScan(_aD2Peds, {|x|x[1]==SD2->D2_PEDIDO})
		If nPos == 0
			AAdd(_aD2Peds,{SD2->D2_PEDIDO,0.00})
			nPos := Len(_aD2Peds)
		EndIf
		_aD2Peds[nPos,2] += SD2->D2_TOTAL
		/*
		// Corrige o CD2 conforme o SD2
		CD2->(DbSeek(xFilial("CD2")+"S"+SD2->D2_SERIE+SD2->D2_DOC+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_ITEM,.F.))
		Do While CD2->CD2_FILIAL == xFilial("CD2") .And. CD2->CD2_TPMOV == "S" .And. CD2->CD2_SERIE == SD2->D2_SERIE .And.;
			CD2->CD2_DOC == SD2->D2_DOC .And. CD2->CD2_CODCLI == SD2->D2_CLIENTE .And. CD2->CD2_LOJCLI == SD2->D2_LOJA .And.;
			Left(CD2->CD2_ITEM,Len(SD2->D2_ITEM)) == SD2->D2_ITEM .And. CD2->CD2_CODPRO == SD2->D2_COD .And. CD2->(!Eof())
			If AllTrim(CD2->CD2_IMP) == "SOL" .And. CD2->CD2_ALIQ # SD2->D2_ALIQSOL
				RecLock("CD2",.F.)
				CD2->CD2_ALIQ := SD2->D2_ALIQSOL
				MsUnLock()
				Exit
			EndIf
			CD2->(DbSkip())
		EndDo
		*/
	
		SD2->(DbSkip())
	EndDo
	
	For nPos := 1 to Len(_aD2Peds)
		SC5->(DbSeek(xFilial("SC5")+_aD2Peds[nPos,1],.F.))
	
		_aDadC5 := {SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_ENTREG,SC5->C5_TIPO,_aD2Peds[nPos,2]}
		U_CDGEN21I(12,,,,_aDadC5)
	Next
	
	// Temporariamente apresentar na tela o peso liquido e peso bruto das notas de
	// 3 Lagoas, pois está ocorrendo divergências no cálculo do peso das bobinas
	/*
	if !lNewFatur
		If xFilial("SF2") == "02"
			Alert( "Favor conferir os pesos: " + CHR(13) + CHR(13) + ;
			"Peso Liquido : " + Transform(SF2->F2_PLIQUI,"@E 999,999.9999") + CHR(13) + ;
			"Peso Bruto   : " + Transform(SF2->F2_PBRUTO,"@E 999,999.9999") )
		EndIf
	endif
	*/
	RestArea(_aAreaD2)
	RestArea(_aAreaC5)
	RestArea(_aAreaF2)
	RestArea(_aArea)

Return(.T.)


/*/{Protheus.doc} ArruPesos
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
Static Function ArruPesos()
	// Rotina desenvolvida para atender ao chamado 1739 de 01/06/15
	// Rotina desenvolvida em 15/06/15 RFO
	// Transferir os pesos das notas série U para as de série 1
	Local _aArea  , _aAreaF2
	Local _nUSmPlq, _nUSmPBt
	Local _nSmPlq , _nSmPBt
	Local _xCdRoma, _nQtNt
	
	If (SF2->F2_PLIQUI > 0 .Or. SF2->F2_PBRUTO > 0)
		_aArea := GetArea()
	
		DbSelectArea("SF2")
		_aAreaF2 := GetArea()
	
		_xCdRoma := SF2->F2_CDROMA
		_nUSmPlq := SF2->F2_PLIQUI
		_nUSmPBt := SF2->F2_PBRUTO
	
		DBOrderNickName("SF2CDROMA")
		DbSeek(xFilial("SF2") + _xCdRoma,.F.)
		_nSmPlq := 0
		_nSmPBt := 0
		_nQtNt:= 0
		Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_CDROMA == _xCdRoma .And. SF2->(!Eof())
			If SF2->F2_SERIE == "1  "
				_nSmPlq += SF2->F2_PLIQUI
				_nSmPBt += SF2->F2_PBRUTO
				_nQtNt++ // Quantidade de notas série 1
			EndIf
			SF2->(DbSkip())
		EndDo
	
		DbSeek(xFilial("SF2") + _xCdRoma,.F.)
		Do While SF2->F2_CDROMA == _xCdRoma .And. SF2->(!Eof()) .And. _nQtNt > 0 // Tem notas série 1
			RecLock("SF2",.F.)
			If SF2->F2_SERIE == "U  " // Zera os pesos da série U
				SF2->F2_PLIQUI := 0
				SF2->F2_PBRUTO := 0
			ElseIf _nQtNt == 1 // Se tiver somente uma nota série 1, assume todo o peso da série U para essa nota
				SF2->F2_PLIQUI := SF2->F2_PLIQUI + _nUSmPlq
				SF2->F2_PBRUTO := SF2->F2_PBRUTO + _nUSmPBt
			Else // If _nQtNt > 1 // Se tiver mais de uma nota série 1, rateia o peso da série U nessas notas
				SF2->F2_PLIQUI := SF2->F2_PLIQUI + (Round((_nUSmPlq / _nSmPlq) * SF2->F2_PLIQUI,2))
				SF2->F2_PBRUTO := SF2->F2_PBRUTO + (Round((_nUSmPBt / _nSmPBt) * SF2->F2_PBRUTO,2))
			EndIf
			MsUnLock()
			SF2->(DbSkip())
		EndDo
	
		RestArea(_aAreaF2)
		RestArea(_aArea)
	EndIf
Return(.T.)


/*/{Protheus.doc} DesMark
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
User Function DesMark()
	Local _MyMarca := " "
	// Não permitir que itens marcados sejam desmarcados e vice-versa
	If Empty(SC9->C9_BLEST+SC9->C9_BLCRED+SC9->C9_RISCO)
		_MyMarca := cMarca
		MsgBox("O Item não Pode ser Desmarcado" , "Atenção !!!", "INFO")
	Else
		_MyMarca := " "
		MsgBox("O Item não Pode ser Marcado" , "Atenção !!!", "INFO")
	EndIf
	If SC9->C9_OK # _MyMarca
		RecLock("SC9",.F.)
		SC9->C9_OK := _MyMarca
		MsUnLock()
	EndIf
	_xxVolta := .T.
Return(_xxVolta)


/*/
Esta Função é para ser chamada por fórmulas.... não é chamada em lugar algum
/*/


/*/{Protheus.doc} AglitaC9
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined
@param cPedido, characters, descricao
@type function
/*/
User Function AglitaC9(cPedido)
	
	DbSelectArea("SDC")
	SDC->(DbSetOrder(1)) //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
	
	DbSelectArea("SC9")
	DbSetOrder(1)
	
	_cChave := " "
	_nRegC9 := 0
	_nRegDC := 0
	DbSeek(xFilial("SC9")+cPedido,.T.)
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == cPedido .And. SC9->(!Eof())
		IncProc()
	
		SDC->(DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.F.))
	
		If Empty(SC9->C9_BLEST) .And. Empty(SC9->C9_BLCRED)
			If SC9->C9_PEDIDO+SC9->C9_ITEM # _cChave
				_cChave := SC9->C9_PEDIDO+SC9->C9_ITEM
				_nRegC9 := SC9->(Recno())
			ElseIf SDC->(!Eof()) .And. SC9->C9_QTDLIB == SDC->DC_QUANT
				// Pega a Quantidade
				_nQtdAgl := SC9->C9_QTDLIB
	
				// Deleta o SC9
				SC9->(RecLock("SC9",.F.))
				SC9->(DbDelete())
				SC9->(MsUnLock())
	
				// Deleta o SDC e o SC9
				SDC->(RecLock("SDC",.F.))
				SDC->(DbDelete())
				SDC->(MsUnLock())
	
				// Posiciona no SC9 principal
				SC9->(DbGoTo(_nRegC9))
				SC9->(RecLock("SC9",.F.))
				SC9->C9_QTDLIB := SC9->C9_QTDLIB + _nQtdAgl
				SC9->(MsUnLock())
	
				SDC->(DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN,.F.))
				SDC->(RecLock("SDC",.F.))
				SDC->DC_QUANT   := SDC->DC_QUANT   + _nQtdAgl
				SDC->DC_QTDORIG := SDC->DC_QTDORIG + _nQtdAgl
				SDC->(MsUnLock())
			EndIf
		EndIf
		SC9->(DbSkip())
	EndDo
Return(.T.)


/*/{Protheus.doc} CSFATSUC
//TODO Gera Sucata do faturamento 
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
User Function CSFATSUC()
	Local aAutoCab
	Local aAutoItens
	Local lSeeError := .T.
	Local oApp_ori
	Private lMsErroAuto := .F.
	
	If Select("SX2") = 0
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"
		DbSelectArea("SB1")
		DbSelectArea("SB2")
		DbSelectArea("SB9")
		DbSelectArea("SBF")
		DbSelectArea("SBK")
		DbSelectArea("SD1")
		DbSelectArea("SD2")
		DbSelectArea("SD3")
		DbSelectArea("SDA")
		DbSelectArea("SDB")
		DbSelectArea("SF4")
		DbSelectArea("SF5")
		lSeeError 		:= .F.
		nHndErp			:= AdvConnection()
		TcSetConn(nHndERP)
	Endif
	
	_cDtMin := GetMv("MV_ULMES")
	_cDtMin := Max(_cDtMin,GetMv("MV_DBLQMOV"))
	
	// Esta função corrige os movimentos do SD2 série U para SD3 - sucata (Desmontagem de produtos)
	cQuery := ""
	cQuery += "SELECT D2.R_E_C_N_O_ D2_RECNO, D2_FILIAL, D2_DOC, D2_ITEM, D2_COD, D2_QUANT, D2_NUMSEQ, D2_EMISSAO, "
	cQuery += "       ISNULL(DB.R_E_C_N_O_,0) DB_RECNO,DB_PRODUTO, DB_LOCAL, DB_LOCALIZ, DB_QUANT, DB_DATA,"
	cQuery += "       B1_PESCOB, B1_PESPVC, B1_LOCALIZ, B1_TIPO,"
	cQuery += "       ISNULL(F4.R_E_C_N_O_,0) F4_RECNO, F4_TES_U,"
	cQuery += "       ISNULL(B2.R_E_C_N_O_,0) B2_RECNO,"
	cQuery += "       ISNULL(BF.R_E_C_N_O_,0) BF_RECNO"
	cQuery += " FROM "+RetSqlName("SD2")+" D2"
	cQuery += " 	INNER JOIN "+RetSqlName("SF4")+" F4"
	cQuery += "	ON  '  ' = F4_FILIAL"
	cQuery += "	AND D2_TES = F4_CODIGO"
	cQuery += "	AND 'S' = F4_ESTOQUE"
	cQuery += "	AND D2.D_E_L_E_T_ = F4.D_E_L_E_T_"
	cQuery += " 	LEFT JOIN "+RetSqlName("SDB")+" DB"
	cQuery += "	ON D2_FILIAL = DB_FILIAL"
	cQuery += "	AND D2_NUMSEQ = DB_NUMSEQ"
	cQuery += "	AND D2.D_E_L_E_T_ =  DB.D_E_L_E_T_"
	cQuery += " 	INNER JOIN "+RetSqlName("SB1")+" B1"
	cQuery += "	ON '  ' = B1_FILIAL"
	cQuery += "	AND D2_COD = B1_COD"
	cQuery += "	AND D2.D_E_L_E_T_ = B1.D_E_L_E_T_"
	cQuery += " 	INNER JOIN "+RetSqlName("SB2")+" B2"
	cQuery += "	ON  D2_FILIAL = B2_FILIAL"
	cQuery += "	AND D2_COD = B2_COD"
	cQuery += "	AND D2_LOCAL = B2_LOCAL"
	cQuery += "	AND D2.D_E_L_E_T_ = B2.D_E_L_E_T_"
	cQuery += " 	LEFT JOIN "+RetSqlName("SBF")+" BF"
	cQuery += "	ON  DB_FILIAL = BF_FILIAL"
	cQuery += "	AND DB_PRODUTO = BF_PRODUTO"
	cQuery += "	AND DB_LOCAL = BF_LOCAL"
	cQuery += "	AND DB_LOCALIZ = BF_LOCALIZ"
	cQuery += "	AND D2.D_E_L_E_T_ = BF.D_E_L_E_T_"
	cQuery += " WHERE D2_SERIE = 'U'"
	cQuery += " AND D2_EMISSAO > '" + Dtos(_cDtMin) + "'"
	cQuery += " AND D2_EMISSAO <= '" + Dtos((Date()-1)) + "'"
	cQuery += " AND D2.D_E_L_E_T_ = ''"
	cQuery += " ORDER BY D2_FILIAL, D2_DOC, D2_ITEM"
	
	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea("TRB")
	EndIf
	
	TCQUERY cQuery NEW ALIAS "TRB"
	
	DbSelectArea("TRB")
	DbGoTop()
	
	_cMyEmp   := cNumEmp
	_cMyFilAn := cFilAnt
	_cTRBFil := "  "
	_lErro := .F.
	_MyDtBase := dDataBase
	
	Do While !TRB->(Eof())
	
		If _cTRBFil # TRB->D2_FILIAL
	
			DbSelectArea("SM0")
			DbSetOrder(1)
			If !DbSeek(cEmpAnt+TRB->D2_FILIAL,.F.)
				TRB->(DbSkip())
				Loop
			EndIf
			_cTRBFil := TRB->D2_FILIAL
			cFilAnt  := TRB->D2_FILIAL
			cNumEmp  := cEmpAnt+cFilAnt
		EndIf
	
		// alterar a data base para adata de emissão da nota
		dDataBase := Ctod(Right(TRB->D2_EMISSAO,2) + "/" + Substr(TRB->D2_EMISSAO,5,2) + "/" + Left(TRB->D2_EMISSAO,4))
	
		BeginTran()
	
		_cChave := (TRB->D2_FILIAL+TRB->D2_DOC+TRB->D2_ITEM)
		Do While !TRB->(Eof()) .And. !_lErro .And. (TRB->D2_FILIAL+TRB->D2_DOC+TRB->D2_ITEM) == _cChave
			If TRB->B1_PESCOB == 0 //.Or. TRB->B1_TIPO == "SC" // Se não tem cobre no produto ou já for sucata
				// Não fazer a desmontagem e mandar e-mail para TI
				TRB->(DbSkip())
				Loop
			EndIf
	
			// Se eu tiver diversos registros do mesmo item
			DbSelectArea("SF4")
			SF4->(DbGoTo(TRB->F4_RECNO))
			RegToMemory("SF4",.F.)
			_cCodTES_u := SF4->F4_TES_U
			If Empty(SF4->F4_TES_U) // TES correspondente não existe
				DbSelectArea("SF4")
				DbSetOrder(1)
				_cCodTES_u := 800
				Do While DbSeek(xFilial("SF4")+StrZero(_cCodTES_u,3),.F.)
					If ++_cCodTES_u > 999
						Exit
					EndIf
				EndDo
				If _cCodTES_u > 999
					// Sair com Erro na criação do TES_u
					_lErro := .T.
					Exit
				EndIf
	
				_cCodTES_u := StrZero(_cCodTES_u,3)
				DbSelectArea("SF4")
				SF4->(DbGoTo(TRB->F4_RECNO))
				RecLock("SF4",.F.)
				SF4->F4_TES_U := _cCodTES_u
				MsUnLock()
	
				RecLock("SF4",.T.)
				SF4->F4_FILIAL := xFilial("SF4")
				SF4->F4_CODIGO := _cCodTES_u
				MsUnLock()
			EndIf

			// Transfiro os dados da memória para o SF4
			_nQtCpo       := SF4->(FCount())
			M->F4_CODIGO  := _cCodTES_u
			M->F4_ESTOQUE := "N"
			M->F4_MSBLQL  := "1" // Deixar bloqueado
			M->F4_TES_U	  := "   "
	
			DbSelectArea("SF4")
			DbSetOrder(1)
			DbSeek(xFilial("SF4")+_cCodTES_u,.F.)
			RecLock("SF4",.F.)
			For nCntFor := 1 To _nQtCpo
				FieldPut(nCntFor,M->&(FieldName(nCntFor)))
			Next
			MsUnLock()
	
			// Troco o TES no SD2
			DbSelectArea("SD2")
			SD2->(DbGoTo(TRB->D2_RECNO))
	
			// Primeiro assumo os dados do SD2, pois não sei se o produto controla localização
			_cPrdOri := SD2->D2_COD
			_cLocOri := SD2->D2_LOCAL
			_nQtdOri := SD2->D2_QUANT
			_cLczOri := ""
	
			If SD2->D2_TES # _cCodTES_u
				// É a primeira vez que passo por este registro do SD2 ?
				// Tomar cuidado para fazer somente uma vez, sendo que o LEFT JOIN com o SBF pode trazer mais de uma vez o mesmo registro do SD2

				RecLock("SD2",.F.)
				SD2->D2_TESORI := SD2->D2_TES
				SD2->D2_TES    := _cCodTES_u
				SD2->D2_ESTOQUE := "N"
				MsUnLock()
	
				DbSelectArea("SB2")
				SB2->(DbGoTo(TRB->B2_RECNO))
				RecLock("SB2",.F.)
				SB2->B2_QATU += SD2->D2_QUANT // "Estorno" a quantidade no SB2 para depois poder fazer o envio para sucata
				MsUnLock()
			EndIf
	
			If TRB->B1_LOCALIZ == "S" // Controla localização?

				DbSelectArea("SDB")
				SDB->(DbGoTo(TRB->DB_RECNO))
	
				DbSelectArea("SBF")
				If TRB->BF_RECNO == 0
					// Não tem registro no SBF para voltar o saldo
					// Criar registro de saldo
					SBE->(dbSetOrder(1))
					SBE->(DbSeek(xFilial('SBE')+SDB->DB_LOCAL+SDB->DB_LOCALIZ, .F.))
	
					RecLock("SBF",.T.)
					SBF->BF_FILIAL    := xFilial('SBF')
					SBF->BF_PRODUTO   := SDB->DB_PRODUTO
					SBF->BF_LOCAL     := SDB->DB_LOCAL
					SBF->BF_LOCALIZ   := SDB->DB_LOCALIZ
					SBF->BF_NUMSERI   := SDB->DB_NUMSERI
					If Rastro(SBF->BF_PRODUTO,"S")
						SBF->BF_NUMLOTE := SDB->DB_NUMLOTE
					EndIf
					SBF->BF_LOTECTL   := SDB->DB_LOTECTL
					SBF->BF_PRIOR     := If(Empty(SBE->BE_PRIOR),"",SBE->BE_PRIOR)
				Else
					DbGoto(TRB->BF_RECNO)
					RecLock("SBF",.F.)
				EndIf

				SBF->BF_QUANT     := SBF->BF_QUANT   + SDB->DB_QUANT
				SBF->BF_QTSEGUM   := SBF->BF_QTSEGUM + SDB->DB_QTSEGUM
				MsUnlock()
	
				_cPrdOri := SDB->DB_PRODUTO
				_cLocOri := SDB->DB_LOCAL
				_nQtdOri := SDB->DB_QUANT
				_cLczOri := SDB->DB_LOCALIZ
			EndIf
	
			lMsErroAuto := .F.
			aAutoCab := {	{"cProduto"   , _cPrdOri				, Nil},;
		                    {"cLocOrig"   , _cLocOri  				, Nil},;
		                    {"cLocaliza"  , _cLczOri				, Nil},;
							{"nQtdOrig"   , _nQtdOri  				, Nil},;
		                    {"cDocumento" , Left(TRB->D2_DOC,6) + "-" + TRB->D2_ITEM, Nil}}
	
			ConOut("Roberto - CRIEI O aAautocab")
			
			_nQtdSuct := _nQtdOri * TRB->B1_PESCOB
			
		 	// Conforme conversa com Jeferson e com Juliano (telefone) jogar para sucata somente o cobre
				aAutoItens := {{{"D3_COD"    , Pad("SC01000001", Len(SD3->D3_COD))	, Nil},	;
								{"D3_LOCAL"  , "04"									, Nil}, ;
								{"D3_QUANT"  , _nQtdSuct							, Nil}, ;
								{"D3_USUARIO", cUserName							, Nil}, ;
								{"D3_HIST"   , "U-"+TRB->D2_DOC+"-"+TRB->D2_ITEM	, Nil}, ;
								{"D3_RATEIO" , 100									, Nil}}}
	
			 ConOut("Roberto - CRIEI O aAutoItens")
	
			If TRB->B1_LOCALIZ == "S" // Controla localização?
				// Deletar o SDB antes de criar a transferência para sucata

				DbSelectArea("SDB")
				SDB->(DbGoTo(TRB->DB_RECNO))
				// Atenção: Conforme testes realizados, se mesmo que o registro do SDB estiver deletado e existir o registro do SD2,
				// que é ocaso porque estamos somente trocando o TES no SD2 e não estamos alterando o NUMSEQ, esse registro do SDB
				// deletado é listadomno KARDEX por localização. Para que isso não ocorra, temos que alterar o campo DB_ATUEST para N.
				RecLock("SDB",.F.)
				SDB->DB_ATUEST := "N"
				DbDelete()
				MsUnLock()
			EndIf
	
			SB2->(DbSetOrder(1))
			If !SB2->(DbSeek(xFilial("SB2")+Pad("SC01000001", Len(SD3->D3_COD))+"04",.F.))
				CriaSB2(Pad("SC01000001", Len(SD3->D3_COD)),"04")
			EndIf
			
			RPCSetType(3)
			RPCSetEnv('01',xFilial("SD3"),,,'EST',GetEnvServer(),{} )
	
			MSExecAuto({|v,x,y,z| Mata242(v,x,y,z)},aAutoCab,aAutoItens,3,.T.)
	
			ConOut("EXECUTEI O MATA242 ")
	
			If lMsErroAuto
				_cMens := MemoRead(NomeAutoLog())
				nTamMsg	:= Len(_cMens)
				cErro := StrTran(StrTran(Alltrim(Left(_cMens,nTamMsg)),chr(13) + chr(10)," "),chr(10),"")
				cMsg := SubsTr(cErro,1,180)
	
				If lSeeError
					Mostraerro()
				EndIf
				_lErro := .T.
				Exit
			Else
				//ConOut("Roberto - Legal, fez O MATA242 ")
			EndIf
			TRB->(DbSkip())
		EndDo
	
		If _lErro
			DisarmTransaction()
			_lErro := .F.
		EndIf
	
		// Se deu erro, não confirmar os dados desse item do SD2
		// posicionar no próximo item da nota
		Do While (TRB->D2_FILIAL+TRB->D2_DOC+TRB->D2_ITEM) == _cChave .And. !TRB->(Eof())
			TRB->(DbSkip())
		EndDo
	
		EndTran()
	EndDo
	
	// Voltar configurações iniciais
	cNumEmp   := _cMyEmp
	cFilAnt   := _cMyFilAn
	dDataBase := _MyDtBase
	
	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea("TRB")
	EndIf
	
	DbSelectArea("SM0")
	DbSetOrder(1)
	DbSeek(cNumEmp,.F.)
Return(.T.)


/*/{Protheus.doc} TSTAcon
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
User Function TSTAcon() //U_TSTAcon()
	
	DbselectArea("SF2")
	DbselectArea("SD2")
	DbselectArea("SA1")
	DbselectArea("SB1")
	DbselectArea("SDB")
	DbselectArea("ZZR")
	
	_cQuery := "SELECT D2_PEDIDO, D2_SEQOS, D2_ITEMPV, F2_CDROMA, D2_COD, DB_LOCALIZ, SUM(DB_QUANT) DBQUANT, 0 AS ZZRQUANT, "
	_cQuery += "((SELECT ISNULL(SUM(ZZR_QUAN),0) FROM "+RetSqlName("ZZR")+" ZZR " + ;
				" WHERE ZZR_FILIAL = D2_FILIAL" + ;
				" AND ZZR_PEDIDO = D2_PEDIDO" + ;
				" AND ZZR_ITEMPV = D2_ITEMPV" + ;
				" AND ZZR_SEQOS = D2_SEQOS" + ;
				" AND Left(ZZR_PRODUT,10) = Left(D2_COD ,10)" + ;
				" AND ZZR_LOCALI = DB_LOCALIZ" + ;
				" AND ZZR.D_E_L_E_T_ = '')) ZZRQUANT2, D2_FILIAL "
	_cQuery += "FROM "+RetSqlName("SF2")+" F2 "
	_cQuery += "INNER JOIN "+RetSqlName("SD2")+" D2 ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND " + ;
					   "F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA AND F2.D_E_L_E_T_ = D2.D_E_L_E_T_ "
	_cQuery += "INNER JOIN "+RetSqlName("SB1")+" B1 ON '"+xFilial("SB1")+"' = B1_FILIAL AND D2_COD = B1_COD AND D2.D_E_L_E_T_ = B1.D_E_L_E_T_ "
	_cQuery += "INNER JOIN "+RetSqlName("SF4")+" F4 ON '"+xFilial("SF4")+"' = F4_FILIAL AND D2_TES = F4_CODIGO	AND D2.D_E_L_E_T_ = F4.D_E_L_E_T_ "
	_cQuery += "LEFT  JOIN "+RetSqlName("SDB")+" DB ON D2_FILIAL = DB_FILIAL AND D2_COD = DB_PRODUTO AND D2_LOCAL =  DB_LOCAL " + ;
					   "AND D2_NUMSEQ = DB_NUMSEQ AND D2_DOC = DB_DOC AND D2_SERIE = DB_SERIE AND D2.D_E_L_E_T_ = F4.D_E_L_E_T_ "
	_cQuery += "WHERE F2_FILIAL = '"+xFilial("SF2")+"' AND F2_EMISSAO >= '20170305' AND F2_EMISSAO <= '20170322' AND F2.D_E_L_E_T_ = '' AND  " + ;
				 "F4_ESTOQUE = 'S' AND D2_SEQOS <> '  ' AND B1_LOCALIZ = 'S' "
	_cQuery += "GROUP BY D2_FILIAL,F2_CDROMA,D2_PEDIDO, D2_ITEMPV, D2_SEQOS, D2_COD, DB_LOCALIZ "
	_cQuery += "ORDER BY D2_FILIAL,D2_PEDIDO, D2_SEQOS, D2_ITEMPV, D2_COD, DB_LOCALIZ"
	
	_aDadFat := u_QryArr(_cQuery) // Executa a Query, joga os dados num array e fecha o arquivo temporário da Query.
	/*/
	 Exemmplo de retorno da query
	
	1-D2_PEDIDO 2-D2_SEQOS  3-D2_ITEMPV 4-F2_CDROMA 5-D2_COD    	6-DB_LOCALIZ    7-DBQUANT   8-ZZRQUANT (SEMPRE ZERO PARA GRAVAR A QUANT.DO ZZR)	9-ZZRQUANT2	10-D2_FILIAL
	169708		02			01			293494		1150504401      R00100         	3000		0
	169708		02			02			293494		1150502401      R00100         	2000		0
	169708		02			03			293494		1150802401      R00100         	 200		0
	169708		02			05			293494		1150905401      B00200         	 200		0
	/*/
	If Len(_aDadFat) > 0
		_cOrdens := ""
		For _nOrdem := 1 to Len(_aDadFat)
			If !(_aDadFat[_nOrdem,1] + _aDadFat[_nOrdem,2]) $ _cOrdens
				_cOrdens += _aDadFat[_nOrdem,1] + _aDadFat[_nOrdem,2] + "//"
			EndIf
		Next
	
		cMsqErr := ""
	
		Do While Len(_cOrdens) > 0
			DbSelectArea("ZZR")
			DbSetOrder(2) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_SEQOS+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_LOCALI
			//DbSetOrder(1) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_SEQOS
			DbSeek(xFilial("ZZR")+Left(_cOrdens,8),.F.)
			Do While ZZR->ZZR_FILIAL == xFilial("ZZR") .And. ZZR->(ZZR_PEDIDO+ZZR_SEQOS) == Left(_cOrdens,8) .And. ZZR->(!Eof())
				_cCdRoman := ""
				_lTemArr := .F. // Indica se tem algum ZZR que não está no array do SELECT
				For _nMyOrd := 1 To Len(_aDadFat)
					// 1-D2_PEDIDO, 2-D2_SEQOS, 3-D2_ITEMPV, 4-F2_CDROMA, 5-D2_COD, 6-DB_LOCALIZ, 7-DBQUANT, 8-ZZRQUANT (SEMPRE ZERO PARA GRAVAR A QUANT.DO ZZR)
					If ZZR->ZZR_PEDIDO == _aDadFat[_nMyOrd,1] .And. ZZR->ZZR_SEQOS == _aDadFat[_nMyOrd,2]
						If Empty(_cCdRoman)
							_cCdRoman := _aDadFat[_nMyOrd,4]
						EndIf
						If ZZR->ZZR_ITEMPV == _aDadFat[_nMyOrd,3] .And. ZZR->ZZR_LOCALI == _aDadFat[_nMyOrd,6]
							_aDadFat[_nMyOrd,8] += ZZR->ZZR_QUAN
							_lTemArr := .T.
							Exit
						EndIf
					EndIf
				Next
				If !_lTemArr
					cMsqErr += If(Len(cMsqErr)>0,", ","") + ZZR->ZZR_PEDIDO + "-" + ZZR->ZZR_SEQOS
					Exit
				EndIf
				ZZR->(DbSkip())
			EndDo
			If Len(_cOrdens) == 10
				_cOrdens := ''
			Else
				_cOrdens := Right(_cOrdens,(Len(_cOrdens)-10))
			EndIf
		EndDo
		If Empty(cMsqErr) // Todos os ZZR's estão no array do SELECT?
			// Avalia se as quantidades estão corretas
			For _nMyOrd := 1 To Len(_aDadFat)
				// 1-D2_PEDIDO, 2-D2_SEQOS, 3-D2_ITEMPV, 4-F2_CDROMA, 5-D2_COD, 6-DB_LOCALIZ, 7-DBQUANT, 8-ZZRQUANT (SEMPRE ZERO PARA GRAVAR A QUANT.DO ZZR)
				If _aDadFat[_nMyOrd,7] # _aDadFat[_nMyOrd,8] .And. !((_aDadFat[_nMyOrd,1] + "-" + _aDadFat[_nMyOrd,2]) $ cMsqErr)
					// A quantidade do SELECT é diferente da quantidade do ZZR
					cMsqErr += If(Len(cMsqErr)>0,", ","") + _aDadFat[_nMyOrd,1] + "-" + _aDadFat[_nMyOrd,2]
				EndIf
			Next
		EndIf
		If ! Empty(cMsqErr) // Tem erro no faturamento
			_Msg := "Erro no processamento da(s) O.S. abaixo: " + Chr(13) + Chr(13)
			_Msg := _Msg + cMsqErr + Chr(13) + Chr(13)
			_Msg := _Msg + "Comunique Expedição." + Chr(13) + Chr(13)
			_Msg := _Msg + cMsqErr 
			u_MandeErro(_Msg)
			Alert(_Msg)
		EndIf
	EndIf
Return(.T.)



/*/{Protheus.doc} ArrumaZRZO
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined

@type function
/*/
Static Function ArrumaZRZO()
	// Alterar as tabelas ZZR e ZZO se o item do pedido for alterado
	DbSelectArea("ZZR")
	DbSetOrder(1) //    ZZR_FILIAL+ZZR_PEDIDO    +ZZR_ITEMPV+ZZR_SEQUEN+ZZR_SEQOS+ZZR_LOCALI
	Do While DbSeek(xFilial("ZZR")+SC9->C9_PEDIDO+_cOldIt   +_cOldSq   +_cOldOs  +_aLibSC9[_nRegsC9,1],.F.)
		RecLock("ZZR",.F.)
		ZZR->ZZR_ITEMPV := SC9->C9_ITEM
		ZZR->ZZR_SEQUEN := SC9->C9_SEQUEN
		MsUnLock()
	EndDo
	
	DbSelectArea("ZZO")
	DbSetOrder(1) //    ZZO_FILIAL+ZZO_PEDIDO    +ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN+ZZO_LOCALI
	Do While DbSeek(xFilial("ZZO")+SC9->C9_PEDIDO+_cOldOs  +_cOldIt   +_cOldSq   +_aLibSC9[_nRegsC9,1],.F.)
		RecLock("ZZO",.F.)
		ZZO->ZZO_ITEMPV := SC9->C9_ITEM
		ZZO->ZZO_SEQUEN := SC9->C9_SEQUEN
		MsUnLock()
	EndDo
Return(.T.)

/*/{Protheus.doc} MoviTrf
//TODO Descrição auto-gerada.
@author zzz
@since 31/05/2017
@version undefined
@param _PrdOri, , descricao
@param _PrdDes, , descricao
@param _LocOri, , descricao
@param _LocDes, , descricao
@param _LozOri, , descricao
@param _LozDes, , descricao
@param _Quant, , descricao
@type function
/*/
User Function MoviTrf(_PrdOri, _PrdDes, _LocOri, _LocDes, _LozOri, _LozDes, _Quant)
	_PrdOri := Padr(_PrdOri,TamSX3("B1_COD")[1])
	_PrdDes := Padr(_PrdDes,TamSX3("B1_COD")[1])
	
	_LocOri := Padr(_LocOri,TamSX3("B1_LOCPAD")[1])
	_LocDes := Padr(_LocDes,TamSX3("B1_LOCPAD")[1])
	
	_LozOri := Padr(_LozOri,TamSX3("BE_LOCALIZ")[1])
	_LozDes := Padr(_LozDes,TamSX3("BE_LOCALIZ")[1])
	
	// Verificar se existe o local destino
	If !SB2->(DbSeek(xFilial("SB2")+_PrdDes+_LocDes,.F.))
		CriaSB2(_PrdDes,_LocDes)
	EndIf
	
	SB1->(DbSetOrder(1))
	//SB1->(DbSeek(xFilial("SB1")+If(_nMovi==1, _PrdDes,_PrdOri),.F.))
	SB1->(DbSeek(xFilial("SB1")+_PrdDes,.F.))
	If SB1->B1_LOCALIZ=="S"
		// Verificar se existe a localização destino
		DbSelectArea("SBE")
		DbSetOrder(1)
		If !DbSeek(xFilial("SBE") + _LocDes + _LozDes,.F.)
			_cAcon := Left(_LozDes,1)
			If _cAcon == "T"
				_cDesLo :=  "Retalho de "
			ElseIf _cAcon == "B"
				_cDesLo :=  "Bobina de "
			ElseIf _cAcon == "M"
				_cDesLo :=  "Carretel de Mad.de "
			ElseIf _cAcon == "C"
				_cDesLo :=  "Carretel de "
			ElseIf _cAcon == "R"
				_cDesLo :=  "Rolo de "
			ElseIf _cAcon == "L"
				_cDesLo :=  "Blister de "
			EndIf
	
			_cDesLo +=  Str(Val(Substr(_LozDes,2,5)),5) + " " + Posicione("SAH",1,xFilial("SAH")+SB1->B1_UM,"AH_DESCPO")
	
			RecLock("SBE",.T.)
			SBE->BE_FILIAL   := xFilial("SBE")
			SBE->BE_LOCAL    := _LocDes
			SBE->BE_LOCALIZ  := _LozDes
			SBE->BE_DESCRIC  := _cDesLo
			SBE->BE_PRIOR    := "ZZZ"
			SBE->BE_STATUS   := "1"
			MsUnLock()
		EndIf
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pega o proximo numero sequencial de movimento      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cNumSeq := ProxNum()
	_lErrAtu := .F.
	For _nMovi := 1 to 2
	
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+If(_nMovi==1, _PrdDes,_PrdOri),.F.))
	
		RecLock("SD3",.T.)
		_nRegSD3 := SD3->(Recno())
		SD3->D3_FILIAL  := xFilial("SD3")
		SD3->D3_TM      := If(_nMovi==1,"499","999")
		SD3->D3_COD     := If(_nMovi==1, _PrdDes,_PrdOri)
		SD3->D3_UM      := SB1->B1_UM                   '
		SD3->D3_QUANT   := _Quant
		SD3->D3_LOCAL   := If(_nMovi==1,_LocDes,_LocOri)
		SD3->D3_CF      := If(_nMovi==1,"DE4","RE4")
		SD3->D3_GRUPO   := SB1->B1_GRUPO
		SD3->D3_EMISSAO := dDataBase
		SD3->D3_NUMSEQ  := cNumSeq
		SD3->D3_TIPO    := SB1->B1_TIPO
		SD3->D3_USUARIO := cUserName
		SD3->D3_CHAVE   := If(_nMovi==1,"E9","E0")
		If SB1->B1_LOCALIZ=="S"
			SD3->D3_LOCALIZ := If(_nMovi==1,_LozDes,_LozOri)
		EndIf
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pega os 15 custos medios atuais            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o custo da movimentacao              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCusto := GravaCusD3(aCM)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o saldo atual (VATU) com os dados do SD3     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_lErrAtu := B2AtuComD3(aCusto,,.F.) // .F.->Não mostra help se der erro // Retorna .T. se deu erro na atualização
		SB1->(MsUnLock())
		SB2->(MsUnLock())
		SBF->(MsUnLock())
		SD3->(MsUnLock())
		SDA->(MsUnLock())
		SD3->(DbGoTo(_nRegSD3))
	
		If SD3->D3_CF == "DE4"// Estou processando a entrada
			// Efetua a distribuição das quantidades.
			DbSelectArea("SDA")
			DbSetOrder(1) // DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ
			If DbSeek(xFilial("SDA")+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ,.F.)
				If SDA->DA_SALDO > 0
					_RegSDA := Recno()
					aCAB  := {	{"DA_PRODUTO" ,SDA->DA_PRODUTO             , nil},;
					{"DA_QTDORI"  ,SDA->DA_QTDORI              , nil},;
					{"DA_SALDO"   ,SDA->DA_SALDO               , nil},;
					{"DA_DATA"    ,SDA->DA_DATA                , nil},;
					{"DA_LOCAL"   ,SDA->DA_LOCAL               , nil},;
					{"DA_DOC"     ,SDA->DA_DOC                 , nil},;
					{"DA_ORIGEM"  ,SDA->DA_ORIGEM              , nil},;
					{"DA_NUMSEQ"  ,SDA->DA_NUMSEQ              , nil},;
					{"DA_QTSEGUM" ,SDA->DA_QTSEGUM             , nil},;
					{"DA_QTDORI2" ,SDA->DA_QTDORI2             , nil}}
	
					aITENS:={{	{"DB_ITEM"    , "0001"                     , nil},;
					{"DB_LOCALIZ" , _LozDes                    , nil},;
					{"DB_QUANT"   , SDA->DA_SALDO              , nil},;
					{"DB_DATA"    , SDA->DA_DATA               , nil},;
					{"DB_ESTORNO" ," "                         , nil} }}
	
					lMsErroAuto := .F.
					_xVolta := msExecAuto({|x,y|mata265(x,y)},aCAB,aITENS)
					If lMsErroAuto
						Exit
					EndIf
				EndIf
			EndIf
		EndIf
	Next
Return(_lErrAtu)


/*/{Protheus.doc} dumbAlerts
@type function
@author bolognesi
@since 05/03/2018
@version 1.0
@param cChave, character, Chave Pedido Item, para buscar SC6
@param aOperRes, array, Array Referencia com os pedidos que precisam ser alertados
@param lShow, logico, Indica funcionalidade da função sendo (.T.)=Mostrar 
mensagem ou (.F.)=Validar e adicionar texto a mensagem
@description Função para verificar se o pedido em faturamento tem o campo
Tp.Operação 03, nesse caso associado com um pedido de remessa. Avisar sobre os
pedidos de remessa, desnecessario isso.   

/*/
static function dumbAlerts(cChave, aOperRes, lShow)
	local aArea			:= getArea()
	local nX				:= 0
	local oSql 			:= nil
	local cRetorno		:= ''
	local cErrMsg			:= ''
	default cChave		:= ''
	default lShow			:= .F.
	
	if lShow
		for nX := 1 to Len(aOperRes)
			cErrMsg += aOperRes[nX] + linha
		next nX
		if !empty(cErrMsg)
			MsgAlert(cErrMsg, 'VERIFICAR REMESSA')
		endif	
	else
		oSql 		:= LibSqlObj():newLibSqlObj()
		if !empty(cRetorno 	:= oSql:getFieldValue("SC6", "C6_NUM",;
		"%SC6.XFILIAL% AND (C6_NUM + C6_ITEM) ='" + cChave + "'" + " AND C6_XOPER = '03'") )
			aadd(aOperRes,'PEDIDO: ' + Alltrim(cRetorno))
		endif
		FreeObj(oSql)
	endif

	restArea(aArea)
return(nil)




/*/{Protheus.doc} CbPesoDv
//TODO Descrição auto-gerada.
@author alexandre.madeira
@since 24/05/2018
@version 1.0
@return ${return}, ${return_description}
@param aPvlNfs, array, descricao
@param _nPesol, , descricao
@param _nPesos, , descricao
@type function
/*/
User Function CbPesoDv(aPvlNfs, _nPesol, _nPesos)
	
	Local _nPesoItem, _nQtdLc, _nPesoEmb, _nRolCx, _nIlhos, _nSaco, _nCart, _nCaixa, _nBlis := 0
	Local _ItSDC := ""
	
	SC9->(DbGoTo(aPvlNfs[8]))
	DbSelectArea("SDC")
	DbSetOrder(1) // DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
	DbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.)
	Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->DC_PRODUTO == SC9->C9_PRODUTO .And. ;
		SDC->DC_LOCAL == SC9->C9_LOCAL .And. SDC->DC_ORIGEM == "SC6" .And. ;
		SDC->DC_PEDIDO == SC9->C9_PEDIDO .And. SDC->DC_ITEM == SC9->C9_ITEM .And. SDC->(!Eof())
		
		_nPesoItem := (Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,"B1_PESO") * SC9->C9_QTDLIB)
		_nQtdLc := SDC->DC_QUANT / Val(Substr(SDC->DC_LOCALIZ,2,5))
		_nPesoEmb := 0
		
		// Atenção: Outros lugares também fazem o mesmo cálculo
		If AllTrim(SDC->DC_LOCALIZ) == "R00015"
			// Se for rolo de 15 Encartelado
			_nRolCx := 0
			If Left(SDC->DC_PRODUTO,3) == "115"  // Cabo Flexicom
				If Substr(SDC->DC_PRODUTO,4,2) $ "04/05" //Se for cabo flex 1,5 ou 2,5 vão 10 rolos por caixa
					_nRolCx := 10
				ElseIf Substr(SDC->DC_PRODUTO,4,2) $ "06/07" //Se for cabo flex 4 ou 6     vão 08 rolos por caixa
					_nRolCx := 8
				ElseIf Substr(SDC->DC_PRODUTO,4,2) == "08" //Se for cabo flex 10         vão 06 rolos por caixa
					_nRolCx := 6
				EndIf
			ElseIf Left(SDC->DC_PRODUTO,3) == "120"  .And. Substr(SDC->DC_PRODUTO,4,2) $ "04/05"// Cordão Paralelo 1,5 ou 2,5
				_nRolCx := 8
			EndIf
			_nIlhos   := (_nQtdLc*1.1624)/1000        // Peso unitário do conjunto de ilhós em gramas
			_nSaco    := (_nQtdLc*7.2660)/1000        // Peso unitário do saco plastico     em gramas
			_nCart    := (_nQtdLc*8.5232)/1000        // Peso unitário da cartela de papel  em gramas
			_nCaixa   := (Int(_nQtdLc/_nRolCx)*0.320) // Peso unitário da caixa de papelão  em kilos
			_nPesoEmb := (_nIlhos+_nSaco+_nCart+_nCaixa)
		ElseIf Left(SDC->DC_LOCALIZ,1) == "L" // Blister
			_nPesoEmb  := u_cbcAcInf(Alltrim(SDC->DC_PRODUTO), AllTrim(SDC->DC_LOCALIZ), , _nQtdLc, , .T., .F.,.T.)[2,2]
		ElseIf Left(SDC->DC_LOCALIZ,1) == "C" // Carretel N8
			_nPesoEmb := (_nQtdLc*2.00)
		ElseIf Left(SDC->DC_LOCALIZ,1) == "B" .And. !SC9->C9_ITEM$_ItSDC
			// Considero o peso pelas bobinas
			_nPesoItem := 0

			// Bobinas de madeira -> Somar as taras do SZE
			_ItSDC += SC9->C9_ITEM + "//"

			SC6->(DbGoTo(aPvlNfs[10]))
			_cItemZE := If(!Empty(SC6->C6_ITEMIMP),SC6->C6_ITEMIMP,SC9->C9_ITEM)

			DbSelectArea("SZE")
			DbSetOrder(2) // ZE_FILIAL+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
			DbSeek(xFilial("SZE")+SC9->C9_PEDIDO+_cItemZE,.F.)
			Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_PEDIDO == SC9->C9_PEDIDO .And. ;
				SZE->ZE_ITEM == _cItemZE .And. SZE->(!Eof())
				If SZE->ZE_STATUS == "F" .And. SZE->ZE_SEQOS == SC9->C9_SEQOS
					_nPesoEmb := _nPesoEmb + SZE->ZE_TARA
					_nPesoItem += (SZE->ZE_PESO-SZE->ZE_TARA)
				EndIf
				SZE->(DbSkip())
			EndDo
		ElseIf Left(SDC->DC_LOCALIZ,1) == "M" // Carretel madeira
			_nPesoEmb := (_nQtdLc*1.45)
		EndIf
		
		_nPesos := _nPesos + _nPesoEmb
		_nPesol += _nPesoItem
		SDC->(DbSkip())
	EndDo	
Return(nil)		
