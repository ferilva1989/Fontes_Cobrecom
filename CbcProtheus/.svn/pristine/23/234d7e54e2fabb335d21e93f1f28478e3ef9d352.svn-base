#include "protheus.ch"
#INCLUDE "rwmake.ch"
static cDrive := if(U_zIs12(),'CTREECDX','')

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CDESTR06  º Autor ³ AP6 IDE            º Data ³  15/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*/{Protheus.doc} CDESTR06
//TODO Gera Lista de Ordem para repasse de bobinas.
@author ..
@since 20/05/2016
@version 1.0

@type function
/*/
User Function CDESTR06()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//Z9_ETIQIMP
	Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2        := "de acordo com os parametros informados pelo usuario."
	Local cDesc3        := "Lista de Repasse"
	Local cPict         := ""
	Local titulo        := "Lista de Repasse"
	Local nLin          := 80
	Local Cabec1        := ""
	Local Cabec2        := ""
	Local imprime       := .T.
	Local aOrd          := {}
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "CDESTR06" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo       := 15
	Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg       := "CDES06"
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "CDESTR06" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString     := "SZ9"
	
	dbSelectArea("SZ9")
	dbSetOrder(4)
	ValidPerg()
	pergunte(cPerg,.F.)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
	
	If nLastKey == 27
		Return
	Endif
	
	If MV_PAR04 == 2 // Se for Rolos/Carreteis (não Bobinas) tem que listar tudo
		MV_PAR05 := 1
	EndIf
	
	If MV_PAR03 == 1 // Relatório
		SetDefault(aReturn,cString)
		If nLastKey == 27
			Return
		Endif
	
		If MV_PAR04 == 1 // Bobinas
			// Criar TRB para depois poder imprimir em ordem de produto + data de entrega
			_aCampos := {}
			aAdd(_aCampos, {"PRODUTO" , "C", 10, 0})
			aAdd(_aCampos, {"PEDIDO"  , "C", TamSX3("C6_NUM")[1], 0})
			aAdd(_aCampos, {"ITEM"    , "C", TamSX3("C6_ITEM")[1], 0})
			aAdd(_aCampos, {"LANCES"  , "N", 06, 0})
			aAdd(_aCampos, {"DESCZ1"  , "C", 27, 0})
			aAdd(_aCampos, {"DESCZ2"  , "C", 09, 0})
			aAdd(_aCampos, {"DESCZ3"  , "C", 06, 0})
			aAdd(_aCampos, {"METRAGE" , "N", 06, 0})
			aAdd(_aCampos, {"QUANT"   , "N", 12, 4})
			aAdd(_aCampos, {"TPBOB"   , "C", 06, 0})
			aAdd(_aCampos, {"DTENTR"  , "D", 08, 0})
			aAdd(_aCampos, {"ESPEC"   , "C", 01, 0}) // Indica se é bobina específica. Imprimir à parte
			If Select("TRB1") > 0
				DbSelectArea("TRB1")
				DbCloseArea()
				Delete File (_cNomArq1 + ".DTC")
				Delete File (_cNomArq1 + OrdBagExt())
			EndIf
			
			if U_zIs12()
				_cNomArq1 := AllTrim(CriaTrab(,.F.))
				FWDBCreate( _cNomArq1 , _aCampos , "CTREECDX")	
			else
				_cNomArq1 := CriaTrab(_aCampos, .T.)
			endif
			
			DbUseArea(.T.,cDrive, _cNomArq1, "TRB1", .T., .F.)
			
			IndRegua("TRB1",_cNomArq1,"PRODUTO+DTOS(DTENTR)+PEDIDO+ITEM",,,OemToAnsi("Selecionando Registros..."))
			DbSetOrder(1)
		EndIf
	ElseIf MV_PAR03 == 2
		// Criar Arquivo DBF para trabalhar
		_aCampos := {}
		aAdd(_aCampos, {"UNICO" , "C", 152, 0})
		If Select("TRB") > 0
			DbSelectArea("TRB")
			DbCloseArea()
			Delete File (_cNomArq + ".DTC")
		EndIf
		
		if U_zIs12()
			_cNomArq := AllTrim(CriaTrab(,.F.))
			FWDBCreate( _cNomArq , _aCampos , "CTREECDX")
		else
			_cNomArq := CriaTrab(_aCampos, .T.)
		endif
		
		DbUseArea(.T.,cDrive, _cNomArq, "TRB", .T., .F.)
	
	ElseIf MV_PAR03 == 3 // Etiquetas
		// SetDefault(aReturn,cString)
		If nLastKey == 27
			Return
		Endif
	
		// Criar TRB para depois poder imprimir em ordem de produto + data de entrega
		_aCampos := {}
		aAdd(_aCampos, {"OK"      , "C", 02, 0})
		aAdd(_aCampos, {"PRODUTO" , "C", 10, 0})
		aAdd(_aCampos, {"DESCZ1"  , "C", 50, 0})
		aAdd(_aCampos, {"QUANT"   , "N", 12, 4})
		aAdd(_aCampos, {"ACONDIC" , "C", 06, 0})
		aAdd(_aCampos, {"LANCES"  , "N", 06, 0})
		aAdd(_aCampos, {"NUMLCS"  , "N", 06, 0}) // Qtd.Lances a imprimir
		aAdd(_aCampos, {"TPBOB"   , "C", 06, 0})
		aAdd(_aCampos, {"PEDIDO"  , "C", TamSX3("C6_NUM")[1], 0})
		aAdd(_aCampos, {"ITEM"    , "C", TamSX3("C6_ITEM")[1], 0})
		aAdd(_aCampos, {"DTENTR"  , "D", 08, 0})
		aAdd(_aCampos, {"SEMANA"  , "C", TamSX3("C6_SEMANA")[1], 0})
		aAdd(_aCampos, {"REGSZ9"  , "N", 10, 0})
		aAdd(_aCampos, {"VAZIO"   , "C", 01, 0})
		aAdd(_aCampos, {"OP"   	  , "C", TamSX3("C2_NUM")[1]+TamSX3("C2_ITEM")[1]+TamSX3("C2_SEQUEN")[1], 0})
		If Select("TRB1") > 0
			DbSelectArea("TRB1")
			DbCloseArea()
			Delete File (_cNomArq1 + ".DTC")
			Delete File (_cNomArq1 + OrdBagExt())
		EndIf
		
		if U_zIs12()
			_cNomArq1 := AllTrim(CriaTrab(,.F.))
			FWDBCreate( _cNomArq1 , _aCampos , "CTREECDX")	
		else
			_cNomArq1 := CriaTrab(_aCampos, .T.)
		endif
		
		DbUseArea(.T.,cDrive, _cNomArq1, "TRB1", .T., .F.)
	
		IndRegua("TRB1",_cNomArq1,"PRODUTO+DTOS(DTENTR)+ACONDIC+PEDIDO+ITEM",,,OemToAnsi("Selecionando Registros..."))
		DbSetOrder(1)
	EndIf
	
	If MV_PAR03 == 3 // Etiquetas
		// Atenção
		// Quanto é chamada a função ParamBox, as variáveis MV_PAR?? são sobrepostas. Por isso, vou trabalhar
		// a partir deste momento com as variáveis _MyMvPar??, pois dá erro em determinado momento.
		// Assim sendo, se houver alteração na quantidade de perguntas, alterar e tratar também estas variáveis
		_MyMvPar01 := MV_PAR01
		_MyMvPar02 := MV_PAR02
		_MyMvPar03 := MV_PAR03
		_MyMvPar04 := MV_PAR04
		_MyMvPar05 := MV_PAR05
	
		Processa({|| LeSZ9()},"Carregando Dados")
		DbSelectArea("TRB1")
		DbGoTop()
		If Eof()
			Alert("Não há etiquetas a serem impressas")
		Else
			MarkItens()
			//		CDERPrint()
		EndIf
	Else
		nTipo := If(aReturn[4]==1,15,18)
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	EndIf
	
	If Select("TRB1") > 0
		DbSelectArea("TRB1")
		DbCloseArea()
		Delete File (_cNomArq1 + ".DTC")
		Delete File (_cNomArq1 + OrdBagExt())
	EndIf
	
	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea()
		If MV_PAR03 == 2
			Delete File (_cNomArq + ".DTC")
		EndIf
	EndIf
Return(.T.)

/*/{Protheus.doc} RunReport
//TODO Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS 
		monta a janela com a regua de processamento.
@author zzz
@since 29/06/2017
@version undefined
@param Cabec1, , descricao
@param Cabec2, , descricao
@param Titulo, , descricao
@param nLin, numeric, descricao
@type function
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local nOrdem
	local ldoChn := .F.
	local cChTpB := ''
	dbSelectArea("SA1")
	dbSetOrder(1)
	
	dbSelectArea("SC5")
	dbSetOrder(1)
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	
	DbSelectArea("SZ1")
	DbSetOrder(1)  //Z1_FILIAL+Z1_COD
	
	DbSelectArea("SZ2")
	DbSetOrder(1)  //Z2_FILIAL+Z2_COD
	
	DbSelectArea("SZ3")
	DbSetOrder(1)  //Z3_FILIAL+Z3_COD
	
	dbSelectArea("SZ9")
	dbSetOrder(1) // Z9_FILIAL+Z9_SEMANA+Z9_PRODUTO+Z9_LOCAL+Z9_LOCALIZ+Z9_PEDIDO
	
	SetRegua(RecCount())
	DbSeek(xFilial("SZ9")+MV_PAR01,.T.)
	Do While SZ9->Z9_FILIAL == xFilial("SZ9") .And. SZ9->Z9_SEMANA <= MV_PAR02 .And. SZ9->(!EOF())
		_cSeman := SZ9->Z9_SEMANA
		titulo  := "Lista Repasse - Semana " + Transform(MV_PAR01,"@R XXXXXX XX-X") + " - " + Transform(MV_PAR02,"@R XXXXXX XX-X")
	
		Do While SZ9->Z9_FILIAL == xFilial("SZ9") .And. SZ9->Z9_SEMANA == _cSeman .And. SZ9->(!EOF())
			IncRegua()
			If lAbortPrint
				If MV_PAR03 == 1 // Relatório
					@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				EndIf
				Exit
			Endif
	
			_MyZ9_LANCES := SZ9->Z9_LANCES
			_MyZ9_Metros := SZ9->Z9_QUANT
	
			If MV_PAR04 == 1 // Se é para bobinas
				If SZ9->Z9_ACONDIC # "B" // Somente Bobinas
					SZ9->(DbSkip())
					Loop
				EndIf
	
				If MV_PAR05 == 2 // Somente Saldos
					// Verificar qual o Saldo
					_MyZ9_Metros := (SZ9->Z9_QUANT - Max(SZ9->Z9_QTDMTS,0))
					// O Item do pedido já está totalmente faturado ou cancelado?
					// Quantos metros faltam entregar ?
					SC9->(DbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
					SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
					SC6->(DbSeek(xFilial("SC6")+SZ9->Z9_PEDIDO+SZ9->Z9_ITEMPV,.F.))
					_MyC9_Metros := 0
					If SC6->(!Eof()) .And. SC6->C6_QTDENT < SC6->C6_QTDVEN .And. SC6->C6_BLQ # "R " // Não achou ou Já entregue ou baixado por residuo
						SC9->(DbSeek(xFilial("SC9")+SZ9->Z9_PEDIDO+SZ9->Z9_ITEMPV,.F.))
						Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO+SC9->C9_ITEM == SZ9->Z9_PEDIDO+SZ9->Z9_ITEMPV .And. SC9->(!Eof())
							If SC9->C9_BLCRED == "09" // Pedido Rejeitado
								_MyC9_Metros := 0
								Exit
							ElseIf SC9->C9_BLEST == "02" // Ainda não liberado
								_MyC9_Metros += SC9->C9_QTDLIB
							EndIf
							SC9->(DbSkip())
						EndDo
					EndIf
					_MyZ9_Metros := Max(Min(_MyZ9_Metros,_MyC9_Metros),0)
					_MyZ9_Lances :=  _MyZ9_Metros / SZ9->Z9_METRAGE
				EndIf
	
				If MV_PAR03 == 1 .Or. MV_PAR03 == 3 // Relatório ou Etiquetas
					// Quando relatório de bobinas... tem que gravar no TRB1 pra poder estabelacer a ordem
					// de impressão - PRODUTO + DATA DE ENTREGA
					If _MyZ9_LANCES > 0
						SB1->(DbSeek(xFilial("SB1")+SZ9->Z9_PRODUTO,.F.))
						SZ1->(DbSeek(xFilial("SZ1")+SB1->B1_NOME,.F.))
						SZ2->(DbSeek(xFilial("SZ2")+SB1->B1_BITOLA,.F.))
						SZ3->(DbSeek(xFilial("SZ3")+SB1->B1_COR,.F.))
						SC5->(DbSetOrder(1))
						SC5->(DbSeek(xFilial("SC5")+SZ9->Z9_PEDIDO,.F.))
	
						_CodCliLj := SC5->C5_CLIENTE+SC5->C5_LOJACLI
						_TipSBob  := Posicione("SA1",1,xFilial("SA1")+_CodCliLj,"A1_MENORBB+A1_MAIORBB")
						_lBobCli  := .F.
	
						// Calcula o tipo da bobina padrão
						If SC5->C5_EMISSAO <= Ctod("06/05/2017") // Pedidos incluidos até dia 6 tem que calcular da forma antiga
							_TpBob := Right("     "+AllTrim(u_CalcBob(SZ9->Z9_PRODUTO,SZ9->Z9_METRAGE)[1]),6) 
						Else
							_TpBob := Right("     "+AllTrim(u_CalcBob(SZ9->Z9_PRODUTO,SZ9->Z9_METRAGE,,SC5->C5_CLIENTE,SC5->C5_LOJACLI)[1]),6) 
							                                //PRODUTO, METROS, TP_RETORNO(TF),CODCLI,LOJA
						EndIf
						If _TipSBob == "00" // Usar a Bobina padrão
							_TpBobCli := _TpBob
						Else
							_cPsBobP := At(_TpBob," 65/25, 65/45, 80/45,100/60,125/70,150/80,170/80")
							_cPsBobP := Str(((_cPsBobP+6)/7),1)
							If _cPsBobP < Left(_TipSBob,1) // A Bob.Padrão é menor que a menor que o cliente aceita
								_TpBob := Left(_TipSBob,1)
								_lBobCli := .T.
							ElseIf _cPsBobP > Right(_TipSBob,1) // A Bob.Padrão é maior que a maior que o cliente aceita
								_TpBob := Right(_TipSBob,1)
								_lBobCli := .T.
							Else
								_TpBob := _cPsBobP
								_lBobCli := .F.
							EndIf
	
							_TpBobCli := Substr(" 65/25, 65/45, 80/45,100/60,125/70,150/80,170/80",((7 * (Val(_TpBob)-1)) + 1),6)
						EndIf
	
						_DescZ1 := AllTrim(SZ1->Z1_DESC)
						If "  " $ _DescZ1
							_DescZ1 := Left(u_CortaDesc(_DescZ1),27)
						EndIf
						If !Empty(SB1->B1_CLASENC) .And. SB1->B1_ESPECIA # "01" .And. SB1->B1_ESPECIA # "01" .And. !"(E)"$ _DescZ1//Especial
							_DescZ1 := Left(_DescZ1,25) + " E"
						EndIf
						_DescZ1 := Left(_DescZ1+Space(50),27)
	
						RecLock("TRB1",.T.)
						TRB1->PRODUTO := SZ9->Z9_PRODUTO
						TRB1->PEDIDO  := SZ9->Z9_PEDIDO
						TRB1->ITEM    := SZ9->Z9_ITEMPV
						TRB1->LANCES  := _MyZ9_Lances
						TRB1->DESCZ1  := _DescZ1
						TRB1->DESCZ2  := SZ2->Z2_BITOLA
						TRB1->DESCZ3  := Left(SZ3->Z3_APELIDO,6)
						TRB1->METRAGE := SZ9->Z9_METRAGE
						TRB1->QUANT   := _MyZ9_Metros
						TRB1->TPBOB   := _TpBob
						TRB1->DTENTR  := SC6->C6_ENTREG
						TRB1->ESPEC   := If(!_lBobCli,"0","1") // Calcular a Bobina
						MsUnLock()
					EndIf
					SZ9->(DbSkip())
					Loop
				EndIf
	
			Else
				If (SZ9->Z9_ACONDIC == "R" .And. SZ9->Z9_METRAGE == 100) .Or. SZ9->Z9_ACONDIC $ "TB" // Retalhos e Bobinas não são incluídos
					SZ9->(DbSkip())
					Loop
				EndIf
			EndIf
	
			If _MyZ9_LANCES <= 0
				SZ9->(DbSkip())
				Loop
			ElseIf MV_PAR03 == 3// Etiquetas
				SZ9->(DbSkip())
				Loop
			EndIf
	
			SB1->(DbSeek(xFilial("SB1")+SZ9->Z9_PRODUTO,.F.))
			SZ1->(DbSeek(xFilial("SZ1")+SB1->B1_NOME,.F.))
			SZ2->(DbSeek(xFilial("SZ2")+SB1->B1_BITOLA,.F.))
			SZ3->(DbSeek(xFilial("SZ3")+SB1->B1_COR,.F.))
	
			If MV_PAR04 == 1
				_xcCli := ""
				_xcLoj := ""
				_xdC5_EMISSAO := Date()
				If !Empty(SZ9->Z9_PEDIDO)
					SC5->(DbSetOrder(1))
					SC5->(DbSeek(xFilial("SC5")+SZ9->Z9_PEDIDO,.F.))
					_xcCli := SC5->C5_CLIENTE
					_xcLoj := SC5->C5_LOJACLI
					_xdC5_EMISSAO := SC5->C5_EMISSAO
				EndIf
				If _xdC5_EMISSAO <= Ctod("06/05/2017") // Pedidos incluidos até dia 6 tem que calcular da forma antiga
					_TpBob := Right("     "+AllTrim(u_CalcBob(SZ9->Z9_PRODUTO,SZ9->Z9_METRAGE)[1]),6)//PRODUTO, METROS, TP_RETORNO(TF),CODCLI,LOJA
				Else
					_TpBob := Right("     "+AllTrim(u_CalcBob(SZ9->Z9_PRODUTO,SZ9->Z9_METRAGE,,_xcCli,_xcLoj)[1]),6)//PRODUTO, METROS, TP_RETORNO(TF),CODCLI,LOJA
				EndIf
			Else
				If SZ9->Z9_ACONDIC == "R"
					_TpBob := "Rolo"
				ElseIf SZ9->Z9_ACONDIC == "L"
					_TpBob := "Blister"
				ElseIf SZ9->Z9_ACONDIC == "C"
					_TpBob := "Carr."
				ElseIf SZ9->Z9_ACONDIC == "M"
					_TpBob := "C.Mad."
				Else
					_TpBob := "????"
				EndIf
			EndIf
	
			For _nQtd := 1 to _MyZ9_LANCES
	
				If MV_PAR03 == 1 .Or. MV_PAR03 == 3 // Relatório ou Etiquetas
					If nLin > 58 // Salto de Página. Neste caso o formulario tem 55 linhas...
						If nLin # 80
							@ nLin++,001 Psay Replicate("-",130)
							@ nLin  ,001 Psay "XX-Verifique Metragem Já Entregue//(*)a=Func.do Spark Tester  b=Aspecto Visual  c=Laudo //AR Aprovado-Reprovado// CF=Usa Fitilho"
						EndIf
						nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin++
						@ nLin++,000 Psay "| Codigo   |Nro. do    |                             | Bitola |      |Lance |        |Data    |Et|         |     |a*|b*|c*|    |Num|"
						If MV_PAR04 == 1
							@ nLin++,000 Psay "| Produto  |Pedido/Item| Material                    | (mm2)  | Cor  |  (m) | Bobina | Entrega|iq|Nro. Lote|Chapa|AR|AR|AR| CF |Maq|"
						Else
							@ nLin++,000 Psay "| Produto  |Pedido/Item| Material                    | (mm2)  | Cor  |  (m) | Acond. | Entrega|iq|Nro. Lote|Chapa|AR|AR|AR| CF |Maq|"
						EndIf
					Endif
					@ nLin,000 Psay "|----------|-----------|-----------------------------|--------|------|------|--------|--------|--|---------|-----|--|--|--|----|---|"
					nLin := nLin + 1 // Avanca a linha de impressao
					@ nLin,000 Psay "|"
					@ nLin,001 Psay Left(SZ9->Z9_PRODUTO,10)
					@ nLin,011 Psay "|"
					@ nLin,013 PSay SZ9->Z9_PEDIDO+"-"+SZ9->Z9_ITEMPV
					@ nLin,023 Psay "|"
	
					_DescZ1 := AllTrim(SZ1->Z1_DESC)
					If "  " $ _DescZ1
						_DescZ1 := Left(u_CortaDesc(_DescZ1),27)
					EndIf
	
					If !Empty(SB1->B1_CLASENC) .And. SB1->B1_ESPECIA # "01" .And. SB1->B1_ESPECIA # "01" .And. !"(E)"$ _DescZ1//Especial
						_DescZ1 := Left(_DescZ1,25) + " E"
					EndIf
	
					SC5->(DbSeek(xFilial("SC5")+SZ9->Z9_PEDIDO,.F.))
					SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
	
					_DescZ1 := Left(_DescZ1+Space(50),27)
					@ nLin,025 Psay _DescZ1
					@ nLin,053 Psay "|"
					@ nLin,055 Psay Left(Alltrim(SZ2->Z2_BITOLA),6)//Alltrim(Left(SZ2->Z2_DESC,5))
					@ nLin,062 Psay "|"
					@ nLin,064 Psay Left(SZ3->Z3_APELIDO,5)
					@ nLin,069 Psay "|"
					@ nLin,070 Psay SZ9->Z9_METRAGE PICTURE "@E 99,999"
					@ nLin,076 Psay "|"
					@ nLin,078 Psay _TpBob // tipo da bobina ou aconcicionamento
					@ nLin,085 Psay "|"
					_DtEn := Dtoc(SC6->C6_ENTREG)
					If Len(_DtEn) == 10
						_DtEn := Left(_DtEn,6) + Right(_DtEn,2)
					EndIf
					//				@ nLin,086 Psay SC6->C6_ENTREG
					@ nLin,086 Psay _DtEn
					@ nLin,094 Psay "|  |         |     |  |  |  |"
					@ nLin,124 Psay iIf(SA1->A1_FITILHO=="S","CF","  ")
					@ nLin,127 Psay "|"
					@ nLin,131 Psay "|"
					nLin := nLin + 1 // Avanca a linha de impressao
				Else
					SC5->(DbSeek(xFilial("SC5")+SZ9->Z9_PEDIDO,.F.))
					SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
					//Left(SZ2->Z2_DESC,9)+";"+Left(SZ3->Z3_APELIDO,4)+";"+Transform(SZ9->Z9_METRAGE,"@E 999,999")+";"+;
	
					DbSelectArea("TRB")
					RecLock("TRB",.T.)
					TRB->UNICO := SZ9->Z9_NUM+"-"+SZ9->Z9_ITEM+";"+SZ9->Z9_PEDIDO+"-"+SZ9->Z9_ITEMPV+";"+;
									Left(AllTrim(SZ1->Z1_DESC) + If(Substr(SZ9->Z9_PRODUTO,9,2)#"01"," E","") + Space(29),29)+";"+;
									SZ2->Z2_BITOLA+";"+Left(SZ3->Z3_APELIDO,4)+";"+Transform(SZ9->Z9_METRAGE,"@E 999,999")+";"+;
									If(MV_PAR04==2,Transform(SZ9->Z9_LANCES,"@E 999,999"),"")+";"+;
									If(MV_PAR04==2,SZ9->Z9_ACONDIC,_TpBob)+";"+Left(SA1->A1_NOME,30)+";"+DtoC(SC5->C5_ENTREG)+";"+SZ9->Z9_PRODUTO
									//
									//				If((_MyZ9_LANCES-_nQtd) > 0 .And. (_MyZ9_LANCES-_nQtd) < 1,"Verifique metragem ja entregue","  ")
					MsUnLock()
					DbSelectArea("SZ9")
					If MV_PAR04==2
						Exit
					EndIf
				EndIf
			Next
			SZ9->(DbSkip()) // Avanca o ponteiro do registro no arquivo
		EndDo
	EndDo
	
	If Select("TRB1") > 0
		For _nVolta :=1 to 2
			DbSelectArea("TRB1")
			titulo := "Lista Repasse - Semana " + Transform(MV_PAR01,"@R XXXXXX XX")
			If MV_PAR02 > MV_PAR01
				titulo := titulo + " - " + Transform(MV_PAR02,"@R XXXXXX XX")
			EndIf
			If _nVolta == 1
				Set Filter to ESPEC == "0"
				titulo := titulo + " - Bobinas Padrão"
			Else
				Set Filter to ESPEC == "1"
				titulo := titulo + " - Bobinas Especiais"
			EndIf
			DbGoTop()
			If !TRB1->(Eof())
				nLin := 80
			EndIf
	
			_aTpBobs := {}
	
			Do While !TRB1->(Eof())
				For _nQtd := 1 to TRB1->LANCES
					If nLin > 58 // Salto de Página. Neste caso o formulario tem 55 linhas...
						If nLin # 80
							@ nLin++,001 Psay Replicate("-",130)
							@ nLin  ,001 Psay "XX-Verifique Metragem Já Entregue//(*)a=Func.do Spark Tester  b=Aspecto Visual  c=Laudo //AR Aprovado-Reprovado// CF=Usa Fitilho"
						EndIf
						nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin++
						@ nLin++,000 Psay "| Codigo   |Nro. do    |                             | Bitola |      |Lance |        |Data    |Et|         |     |a*|b*|c*|    |Num|"
						@ nLin++,000 Psay "| Produto  |Pedido/Item| Material                    | (mm2)  | Cor  |  (m) | Bobina | Entrega|iq|Nro. Lote|Chapa|AR|AR|AR| CF |Maq|"
					Endif
					@ nLin,000 Psay       "|----------|-----------|-----------------------------|--------|------|------|--------|--------|--|---------|-----|--|--|--|----|---|"
					nLin := nLin + 1 // Avanca a linha de impressao
	
					If TRB1->QUANT # (TRB1->METRAGE*TRB1->LANCES)
						DDD:= 1
					EndIf
	
					SC5->(DbSeek(xFilial("SC5")+TRB1->PEDIDO,.F.))
					SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
	
					@ nLin,000 Psay "|"
					@ nLin,001 Psay TRB1->PRODUTO
					@ nLin,011 Psay "|"
					@ nLin,013 PSay TRB1->PEDIDO+"-"+TRB1->ITEM
					@ nLin,023 Psay "|"
					@ nLin,025 Psay TRB1->DESCZ1
					@ nLin,053 Psay "|"
					@ nLin,055 Psay Left(Alltrim(TRB1->DESCZ2),6)
					@ nLin,062 Psay "|"
					@ nLin,063 Psay Alltrim(TRB1->DESCZ3)
					@ nLin,069 Psay "|"
					@ nLin,070 Psay TRB1->METRAGE PICTURE "@E 99,999"
					@ nLin,076 Psay "|"
					@ nLin,078 Psay TRB1->TPBOB
					@ nLin,085 Psay "|"
					@ nLin,086 Psay TRB1->DTENTR
					@ nLin,094 Psay "|  |         |     |  |  |  |""
					@ nLin,124 Psay iIf(SA1->A1_FITILHO=="S","CF","  ")
					@ nLin,127 Psay "|"
					@ nLin,131 Psay "|"
					nLin := nLin + 1 // Avanca a linha de impressao
					
					ldoChn := .F.
					If ("/" $ TRB1->TPBOB) .Or. (ldoChn := !empty(cChTpB := Substr(" 65/25, 65/45, 80/45,100/60,125/70,150/80,170/80",((7 * (Val(TRB1->TPBOB)-1)) + 1),6)))
						cChTpB := iif(ldoChn,cChTpB,TRB1->TPBOB)
						_nPsBB := aScan(_aTpBobs, {|x|x[1]==cChTpB})
						If _nPsBB == 0
							AAdd(_aTpBobs,{cChTpB,1})
						Else
							_aTpBobs[_nPsBB,2] += 1
						EndIf
					EndIf
				Next
				TRB1->(DbSkip())
			EndDo
			If nLin # 80 .And. (MV_PAR03 == 1  .Or. MV_PAR03 == 3) // Relatório ou Etiquetas
				@ nLin++,001 Psay Replicate("-",130)
				aSort(_aTpBobs,,,{|x,y| x[1]<y[1]})
				If Len(_aTpBobs) > 0
					@ nLin  ,001 Psay "Resumo de Bobinas:"
					_nColAtu := 20
					For _nPsBB := 1 To Len(_aTpBobs)
						@ nLin  ,_nColAtu Psay _aTpBobs[_nPsBB,1] + " -"
						@ nLin  ,_nColAtu+10 Psay _aTpBobs[_nPsBB,2] Picture "@E 9,999"
						If _nColAtu >= 115
							_nColAtu := 20
							nLin++
						Else
							_nColAtu+=19
						EndIf
					Next
					nLin++
				EndIf
				@ nLin  ,001 Psay "XX-Verifique Metragem Já Entregue//(*)a=Func.do Spark Tester  b=Aspecto Visual  c=Laudo //AR Aprovado-Reprovado// CF=Usa Fitilho"
			EndIf
		Next
		DbCloseArea("TRB1")
	EndIf
	
	If MV_PAR03 == 1 .Or. MV_PAR03 == 3 // Relatório ou Etiquetas
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza a execucao do relatorio...                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		SET DEVICE TO SCREEN
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se impressao em disco, chama o gerenciador de impressao...          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aReturn[5]==1
			dbCommitAll()
			SET PRINTER TO
			OurSpool(wnrel)
		Endif
	
		MS_FLUSH()
	Else
		DbSelectArea("TRB")
		Copy to LISTAB.TXT SDF
		CPYS2T("LISTAB.TXT","C:\",.F.)
		DbCloseArea("TRB")
		_cNomArq := _cNomArq + ".DTC"
		DELETE FILE &_cNomArq.
		Alert("Criado arquivo C:\LISTA.TXT")
	EndIf

Return(.T.)


/*/{Protheus.doc} LeSZ9
//TODO Realiza a leitura da tabela SZ9 (Lista de Corte).
@author zzz
@since 29/06/2017
@version undefined

@type function
/*/
Static Function LeSZ9()
	dbSelectArea("SA1")
	dbSetOrder(1)
	
	dbSelectArea("SC5")
	dbSetOrder(1)
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	
	DbSelectArea("SZ1")
	DbSetOrder(1)  //Z1_FILIAL+Z1_COD
	
	DbSelectArea("SC9")
	DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	
	DbSelectArea("SC6")
	DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	
	DbSelectArea("SZ2")
	DbSetOrder(1)  //Z2_FILIAL+Z2_COD
	
	DbSelectArea("SZ3")
	DbSetOrder(1)  //Z3_FILIAL+Z3_COD
	
	dbSelectArea("SZ9")
	dbSetOrder(1) // Z9_FILIAL+Z9_SEMANA+Z9_PRODUTO+Z9_LOCAL+Z9_LOCALIZ+Z9_PEDIDO
	
	ProcRegua(LastRec())
	DbSeek(xFilial("SZ9")+MV_PAR01,.T.)
	Do While SZ9->Z9_FILIAL == xFilial("SZ9") .And. SZ9->Z9_SEMANA <= MV_PAR02 .And. SZ9->(!EOF())
		_cSeman := SZ9->Z9_SEMANA
		Do While SZ9->Z9_FILIAL == xFilial("SZ9") .And. SZ9->Z9_SEMANA == _cSeman .And. SZ9->(!EOF())
			IncProc()
			If SZ9->Z9_IMPETIQ $ "SC" .Or. SZ9->Z9_ETIQIMP >= SZ9->Z9_LANCES	// S=Etiqueta já Impressa // P-Impressão suspensa // C-Impressão Cancelada
				// A suspensa deixa passar pra mostrar na tela essa condição.
				SZ9->(DbSkip())
				Loop
			ElseIf MV_PAR04 == 1 .And. SZ9->Z9_ACONDIC # "B" // Se é para bobinas e não é uma bobina
				SZ9->(DbSkip())
				Loop
			ElseIf MV_PAR04 == 2 .And. SZ9->Z9_ACONDIC == "B" // Se é para rolos e é bobina
				SZ9->(DbSkip())
				Loop
			ElseIf Empty(SZ9->Z9_PEDIDO)
				SZ9->(DbSkip())
				Loop
			ElseIf Left(SZ9->Z9_PRODUTO,5) == "11601" .And. "R00500" $ SZ9->Z9_LOCALIZ
				//é CABO FLEXICOM 105 0,50 mm2 e é rolo de 500 metros
				SZ9->(DbSkip())
				Loop
			ElseIf SZ9->Z9_ACONDIC # "B" // Se não é uma bobina
				If u_fCurvaA(SZ9->Z9_PRODUTO,SZ9->Z9_LOCALIZ,.F.) // Verifica se é curva
					SZ9->(DbSkip())
					Loop
				EndIf
			ElseIf Posicione("SC5",1,xFilial("SC5")+SZ9->Z9_PEDIDO,"C5_DRCPROD") == "N"
				SZ9->(DbSkip())
				Loop
			ElseIf !(SC6->(DbSeek(xFilial("SC6")+SZ9->Z9_PEDIDO+SZ9->Z9_ITEMPV,.F.)))
				SZ9->(DbSkip())
				Loop
			EndIf
	
			SB1->(DbSeek(xFilial("SB1")+SZ9->Z9_PRODUTO,.F.))
			If AllTrim(SZ9->Z9_LOCALIZ) $ ("C" + StrZero(SB1->B1_CARRETE,5) + "//M" + StrZero(SB1->B1_CARMAD,5))
				//Se for carretel padrão não imprime etiqueta
				SZ9->(DbSkip())
				Loop
			EndIf
			
			If SZ9->Z9_QTDETQ >= SZ9->Z9_ETIQIMP .And. SZ9->Z9_IMPETIQ $ " N" //// N=Etiqueta não Impressa
				RecLock("SZ9",.F.)
				SZ9->Z9_ETIQIMP := Min(SZ9->Z9_QTDETQ,SZ9->Z9_LANCES)
				If SZ9->Z9_ETIQIMP >= SZ9->Z9_LANCES
					SZ9->Z9_IMPETIQ := "S"
					MsUnLock()
					SZ9->(DbSkip())
					Loop
				Else
					MsUnLock()
				EndIf
			EndIf
	
			//SZ1->(DbSeek(xFilial("SZ1")+SB1->B1_NOME,.F.))
			//SZ2->(DbSeek(xFilial("SZ2")+SB1->B1_BITOLA,.F.))
			//SZ3->(DbSeek(xFilial("SZ3")+SB1->B1_COR,.F.))
			SC5->(DbSetOrder(1))
			SC5->(DbSeek(xFilial("SC5")+SZ9->Z9_PEDIDO,.F.))
	
			_CodCliLj := SC5->(C5_CLIENTE+C5_LOJACLI)
			_TipBob   := Posicione("SA1",1,xFilial("SA1")+_CodCliLj,"A1_MENORBB+A1_MAIORBB")
			_lBobCli  := .F.
			_TpBob := ClcTpBob(SZ9->Z9_ACONDIC,SZ9->Z9_PRODUTO,SZ9->Z9_METRAGE,_CodCliLj,_TipBob,_lBobCli,SC5->C5_EMISSAO)
	
			///***///***
			// _MyZ9_Metros := (SZ9->Z9_QUANT - Max(SZ9->Z9_QTDMTS,0))
			_MyZ9_Metros := (SZ9->Z9_LANCES - SZ9->Z9_ETIQIMP)*SZ9->Z9_METRAGE
	
	
			// O Item do pedido já está totalmente faturado ou cancelado?
			// Quantos metros faltam entregar ?
			SC9->(DbSetOrder(1)) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
			SC6->(DbSetOrder(1)) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			SC6->(DbSeek(xFilial("SC6")+SZ9->Z9_PEDIDO+SZ9->Z9_ITEMPV,.F.))
			_MyC9_Metros := 0
			If SC6->(!Eof()) .And. SC6->C6_QTDENT < SC6->C6_QTDVEN .And. SC6->C6_BLQ # "R " // Não achou ou Já entregue ou baixado por residuo
				SC9->(DbSeek(xFilial("SC9")+SZ9->Z9_PEDIDO+SZ9->Z9_ITEMPV,.F.))
				Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO+SC9->C9_ITEM == SZ9->Z9_PEDIDO+SZ9->Z9_ITEMPV .And. SC9->(!Eof())
					If SC9->C9_BLCRED == "09" // Pedido Rejeitado
						_MyC9_Metros := 0
						Exit
					ElseIf SC9->C9_BLEST == "02" // Ainda não liberado
						_MyC9_Metros += SC9->C9_QTDLIB
					EndIf
					SC9->(DbSkip())
				EndDo
			EndIf
			_MyZ9_Metros := Max(Min(_MyZ9_Metros,_MyC9_Metros),0)
			_MyZ9_Lances :=  (_MyZ9_Metros / SZ9->Z9_METRAGE)
			///***///***
	
			IF _MyZ9_Lances <= 0
				SZ9->(DbSkip())
				Loop
			EndIf
	
			RecLock("TRB1",.T.)
			TRB1->PRODUTO := SZ9->Z9_PRODUTO
			TRB1->PEDIDO  := SZ9->Z9_PEDIDO
			TRB1->ITEM    := SZ9->Z9_ITEMPV
			TRB1->LANCES  := _MyZ9_Lances  // SZ9->Z9_LANCES - SZ9->Z9_ETIQIMP
			TRB1->DESCZ1  := SB1->B1_DESC //_DescZ1
			TRB1->QUANT   := SZ9->Z9_QUANT
			TRB1->TPBOB   := _TpBob
			TRB1->ACONDIC := SZ9->Z9_LOCALIZ
			TRB1->DTENTR  := SC5->C5_ENTREG
			TRB1->SEMANA  := SZ9->Z9_SEMANA
			TRB1->REGSZ9  := SZ9->(Recno())
			TRB1->VAZIO   := If(SZ9->Z9_IMPETIQ=="P","P","  ")
			TRB1->OP      := SZ9->(Z9_NUM+Z9_ITEM+Z9_SEQUEN)
			MsUnLock()
			SZ9->(DbSkip())
		EndDo
	EndDo
Return(.T.)


/*/{Protheus.doc} MarkItens
//TODO Marca Itens.
@author zzz
@since 29/06/2017
@version undefined

@type function
/*/
Static Function MarkItens()
// Cria o array para o cabeçalho do MarkBrow
	_aCampos2 := {}
	aAdd(_aCampos2, {"OK"      ,, "Ok","XX"})
	aAdd(_aCampos2, {"PRODUTO" ,, "Código","XXXXXXXXXX"})
	aAdd(_aCampos2, {"DESCZ1"  ,, "Descrição",})
	aAdd(_aCampos2, {"QUANT"   ,, "Qt.Metros","@E 9999,999"})
	aAdd(_aCampos2, {"ACONDIC" ,, "Acondic.","XXXXXX"})
	aAdd(_aCampos2, {"LANCES"  ,, "Qt.Lances","@E 999,999"})
	aAdd(_aCampos2, {"NUMLCS"  ,, "Lces Impr","@E 999,999"}) // Qtd.Lances a imprimir
	aAdd(_aCampos2, {"PEDIDO"  ,, "Pedido","XXXXXX"})
	aAdd(_aCampos2, {"ITEM"    ,, "Item","XX"})
	If _MyMvPar04 == 1
		aAdd(_aCampos2, {"TPBOB"   ,, "Tp.Bob." ,"XXXXXX"})
	EndIf
	aAdd(_aCampos2, {"DTENTR"  ,, "Dt.Entrega"})
	aAdd(_aCampos2, {"SEMANA"  ,, "Resumo","XXXXXXX"})
	aAdd(_aCampos2, {"VAZIO"   ,, "Impr.","X"})
	aAdd(_aCampos2, {"OP"   	,, "Num.OP","XXXXXXXXXXX"})
	cCadastro:="Etiquetas p/Produção"
	
	aRotina := {{ "Imprime Etiqueta"  ,'Processa({|| u_GrvMkt()},"Atualizando Tabela SZ9")', 0 , 4},;
				{ "Estorna Etiqueta"  ,'u_EstEtq()', 0 , 3}}
	
	lInverte := .F.
	cMarca   := GetMark()
	MarkBrow("TRB1","OK","VAZIO",_aCampos2,lInverte,cMarca,,,,,"u_DuploClk()")
Return(.T.)


/*/{Protheus.doc} DuploClk
//TODO Tratativa para Duplo Click no Browser.
@author zzz
@since 29/06/2017
@version undefined

@type function
/*/
User Function DuploClk()
	If !Empty(TRB1->VAZIO)
		Return(.T.)
	ElseIf TRB1->OK == cMarca
		RecLock("TRB1",.F.)
		TRB1->OK := " "
		TRB1->NUMLCS := 0
		MsUnLock()
		Return(.T.)
	ElseIf TRB1->LANCES == 1
		RecLock("TRB1",.F.)
		TRB1->OK := cMarca
		TRB1->NUMLCS := 1
		MsUnLock()
		Return(.T.)
	EndIf
	
	_MV_PAR01 := TRB1->PRODUTO
	_MV_PAR02 := TRB1->DESCZ1
	_MV_PAR03 := TRB1->ACONDIC
	_MV_PAR04 := TRB1->TPBOB
	_MV_PAR05 := TRB1->QUANT
	_MV_PAR06 := TRB1->LANCES
	_MV_PAR07 := TRB1->NUMLCS
	_MV_PAR08 := TRB1->PEDIDO
	_MV_PAR09 := TRB1->ITEM
	_MV_PAR10 := TRB1->DTENTR
	_MV_PAR11 := TRB1->SEMANA
	
	If Janela06()
		RecLock("TRB1",.F.)
		If _MV_PAR07 > 0
			TRB1->OK := cMarca
			TRB1->NUMLCS := _MV_PAR07
		Else
			TRB1->OK := "  "
			TRB1->NUMLCS := 0
		EndIf
		MsUnLock()
	EndIf
	MARKBREFRESH()
Return(.T.)


/*/{Protheus.doc} GrvMkt
//TODO Grava Itens Marcados no grid.
@author zzz
@since 29/06/2017
@version undefined

@type function
/*/
User Function GrvMkt()
	Local _nQtdEtIm
	// Marca o que é para ser impresso
	DbSelectArea("TRB1")
	ProcRegua(RecCount())
	TRB1->(DbGoTop())
	_nQtdEtq := 0
	Do While TRB1->(!Eof())
		IncProc()
		If Marked("OK")
			_nQtdEtIm := 0
			DbSelectArea("SZ9")
			SZ9->(DbGoTo(TRB1->REGSZ9))
			If SZ9->(Recno()) == TRB1->REGSZ9 .And. !SZ9->(Deleted()) // Agora pode ser que esteja deletado
				If RecLock("SZ9",.F.) // Primeiro travo o registro
					_nQtdEtIm := TRB1->NUMLCS
					If (SZ9->Z9_ETIQIMP+_nQtdEtIm) > SZ9->Z9_LANCES
						_nQtdEtIm := Max((SZ9->Z9_LANCES-SZ9->Z9_ETIQIMP),0)
					EndIf
					If _nQtdEtIm > 0
						SZ9->Z9_ETIQIMP := (SZ9->Z9_ETIQIMP + _nQtdEtIm)
						If SZ9->Z9_ETIQIMP >= SZ9->Z9_LANCES
							SZ9->Z9_IMPETIQ := "S"
						EndIf
					EndIf
					MsUnLock()
				EndIf
			EndIf
			DbSelectArea("TRB1")
			RecLock("TRB1",.F.)
			TRB1->NUMLCS := _nQtdEtIm
			If _nQtdEtIm > 0
				_nQtdEtq++
				TRB1->OK := "XX"
			Else
				TRB1->OK := "  "
			EndIf
			MsUnLock()
		EndIf
		TRB1->(DbSkip())
	EndDo
	DbSelectArea("TRB1")
	TRB1->(DbGoTop())
	//
	// Lê novamente o TRB1 e imprime as etiquetas
	
	DbSelectArea("TRB1")
	Set Filter to OK = "XX" .And. VAZIO == " "
	
	ProcRegua(_nQtdEtq)
	TRB1->(DbGoTop())
	// Ordem do TRB1 --> "PRODUTO+ACONDIC+DTOS(DTENTR)+PEDIDO+ITEM
	Do While TRB1->(!Eof())
		IncProc()
		If TRB1->OK == "XX" .And. TRB1->VAZIO == " "
			_nQtdEt := TRB1->NUMLCS //TRB1->LANCES
			RecLock("TRB1",.F.)
			If TRB1->NUMLCS >= TRB1->LANCES
				TRB1->VAZIO := "S"
			Else
				TRB1->VAZIO  := " "
				TRB1->LANCES := TRB1->LANCES - TRB1->NUMLCS
				TRB1->NUMLCS := 0
				TRB1->OK     := " "
			EndIf
			MsUnLock()
			If _nQtdEt > 0
				SC6->(DbSetOrder(1))
				If !SC6->(DbSeek(xFilial("SC6")+TRB1->PEDIDO+TRB1->ITEM,.F.))
					Alert("Pedido " + TRB1->PEDIDO +"-"+TRB1->ITEM + " cancelado")
				ElseIf SC6->C6_BLQ == "R "
					Alert("Pedido " + TRB1->PEDIDO +"-"+TRB1->ITEM + " cancelado (Resíduo)")
				ElseIf Left(TRB1->PRODUTO,10) # Left(SC6->C6_PRODUTO,10)
					Alert("Pedido " + TRB1->PEDIDO +"-"+TRB1->ITEM + " alterado produto - Verificar com PCP.")
					SZ9->(DbGoTo(TRB1->REGSZ9))
					If SZ9->(Recno()) == TRB1->REGSZ9
						RecLock("SZ9",.F.)
						SZ9->Z9_ETIQIMP -= TRB1->NUMLCS
						SZ9->Z9_IMPETIQ := "N"
						MsUnLock()
					EndIf
				ElseIf AllTrim(TRB1->ACONDIC) # SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5)
					Alert("Pedido " + TRB1->PEDIDO +"-"+TRB1->ITEM + " alterado acondicionamento - Verificar com o PCP.")
					SZ9->(DbGoTo(TRB1->REGSZ9))
					If SZ9->(Recno()) == TRB1->REGSZ9
						RecLock("SZ9",.F.)
						SZ9->Z9_ETIQIMP -= TRB1->NUMLCS
						SZ9->Z9_IMPETIQ := "N"
						MsUnLock()
					EndIf
				Else
					Imprima(.F.,aReturn,cString)
				EndIf
			EndIf
		EndIf
		TRB1->(DbSkip())
		//	EndDo
	EndDo
	DbSelectArea("TRB1")
	Set Filter to
	TRB1->(DbGoTop())
	//CloseBrowse()
Return(.T.)


/*/{Protheus.doc} ValidPerg
//TODO Função Valida Perguntas.
@author zzz
@since 29/06/2017
@version undefined

@type function
/*/
Static Function ValidPerg()
	_aArea := GetArea()
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	
	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Da Semana           ?","mv_ch1","C",07,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até a Semana        ?","mv_ch2","C",07,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Relat./Arq./Etiqueta?","mv_ch3","N",01,0,0,"C","","mv_par03","Relatório","","","Arquivo","","","Etiqueta","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Para                ?","mv_ch4","N",01,0,0,"C","","mv_par04","Bobinas","","","Rolos/Carreteis","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Listar (se Bobinas) ?","mv_ch5","N",01,0,0,"C","","mv_par05","Tudo","","","Saldo","","","","","","","","","","",""})
	
	For i := 1 To Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
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


/*/{Protheus.doc} Bal06Etq
//TODO Esta função serve de ponte da UF CDBAL06 para impressão das etiquetas dos retrabalhos.
@author zzz
@since 29/06/2017
@version undefined
@param aReturn, array, descricao
@param cString, characters, descricao
@type function
/*/
User Function Bal06Etq(aReturn,cString)
	Imprima(.T.,aReturn,cString)
Return(.T.)


/*/{Protheus.doc} Imprima
//TODO Static para Impressão.
@author juliana.leme
@since 29/06/2017
@version undefined
@param lRetrb, logical, descricao
@param aReturn, array, descricao
@param cString, characters, descricao
@type function
/*/
Static Function Imprima(lRetrb,aReturn,cString)
	Local _cNomeCli := ""
	Local _cRazaoCli := ""
	SetDefault(aReturn,cString)
	
	If lRetrb // chamada da CDBAL06
		_nQtdEt  	:= ZZE->ZZE_LANCES
		_cCdPrd0 	:= ZZE->ZZE_PRODUT
		_cCdPrd1 	:= AllTrim(Posicione("SB1",1,xFilial("SB1")+ZZE->ZZE_PRODUT,"B1_DESC"))
		_cCdClie 	:= Posicione("SC5",1,xFilial("SC5")+ZZE->ZZE_PEDIDO,"C5_CLIENTE+C5_LOJACLI")
		_cZZInsp 	:= u_xIsInspe(ZZE->ZZE_PEDIDO)[2]+;
						Posicione("SB1",1,xFilial("SB1")+ZZE->ZZE_PRODUT,"B1_ZZINSPE")
		_cNomeCli	:= Left(Alltrim(Posicione("SA1",1,xFilial("SA1")+_cCdClie,"A1_CGC")),8) //47674429 ANDRA
		_cAcond  	:= ZZE->ZZE_ACONDS+Strzero(ZZE->ZZE_METRAS,5)
		If ZZE->ZZE_ACONDS == "S"
			_cZZEPed := "SUCATA"
		Else                    
			SC5->(DbSetOrder(1))
			SC5->(DbSeek(xFilial("SC5") + ZZE->ZZE_PEDIDO,.F.))
			_CodCliLj 	:= SC5->C5_CLIENTE+SC5->C5_LOJACLI
			_TipBob   	:= Posicione("SA1",1,xFilial("SA1")+_CodCliLj,"A1_MENORBB+A1_MAIORBB")
			_lBobCli  	:= .F.                            
			_TpBob   	:= ClcTpBob(ZZE->ZZE_ACONDS,ZZE->ZZE_PRODUT,ZZE->ZZE_METRAS,_CodCliLj,_TipBob,_lBobCli,SC5->C5_EMISSAO)
			_nTpbob  	:= (At(AllTrim(_TpBob),"65/25 ,65/45 ,80/45 ,100/60,125/70,150/80,170/80,") + 6 ) / 7
			_cZZEPed 	:= ZZE->ZZE_PEDIDO + "-" + ZZE->ZZE_ITEMPV
		EndIf
	Else // Chamada por CDESTR06
		// Busco a descrição do SB1 pra vir inteira.
		_cCdPrd0 := TRB1->PRODUTO
		_cCdPrd1 := AllTrim(Posicione("SB1",1,xFilial("SB1")+TRB1->PRODUTO,"B1_DESC"))
		_cCdClie := Posicione("SC5",1,xFilial("SC5")+TRB1->PEDIDO,"C5_CLIENTE+C5_LOJACLI")
		_cZZInsp := u_xIsInspe(TRB1->PEDIDO)[2]+;
					Posicione("SB1",1,xFilial("SB1")+TRB1->PRODUTO,"B1_ZZINSPE")
		_cNomeCli:= Left(Alltrim(Posicione("SA1",1,xFilial("SA1")+_cCdClie,"A1_CGC")),8) 
		_cRazaoCli:= Posicione("SA1",1,xFilial("SA1")+_cCdClie,"A1_NREDUZ")
		_cAcond  := TRB1->ACONDIC
		_nTpbob  := (At(AllTrim(TRB1->TPBOB),"65/25 ,65/45 ,80/45 ,100/60,125/70,150/80,170/80") + 6 ) / 7
		_cNumOP	 := TRB1->OP
	EndIf
	
	If Len(_cCdPrd1) <= 33
		_cCdPrd2 := " "
	Else
		_nPsBom := 0
		For _nPsAtu := 1 to 33
			If Substr(_cCdPrd1,_nPsAtu,1) == " "
				_nPsBom := _nPsAtu
			EndIf
		Next
		If _nPsBom > 0
			_cCdPrd2 := AllTrim(Substr(_cCdPrd1,_nPsBom))
			_cCdPrd1 := AllTrim(Left(_cCdPrd1,_nPsBom))
		EndIf
	EndIf
	
	@ 0,0 PSAY "^XA^LH8,16^PRC^FS"
	
	If "S" $ Upper(_cZZInsp) 
		@ 0,0 PSAY "^FO335,10^GB230,30,30,4^FS"
	EndIf
	
	@ 0,0 PSAY "^FT017,030^A0N,28,28^FH\^FDC\A2digo:^FS"
	@ 0,0 PSAY "^FT145,030^A0N,28,28^FH\^FD"+Transform(_cCdPrd0,"@R XXX.XX.XX.X.XX")+"^FS"
	
	If "S" $ Upper(_cZZInsp) .and. !(_cNomeCli $ "47674429")
		@ 0,0 PSAY "^FT345,030^A0N,28,31^FH\^FR^FD*INSPECIONAR*^FS"  //35
	ElseIf (_cNomeCli $ "47674429")
		@ 0,0 PSAY "^FT345,030^A0N,28,31^FH\^FR^FD***ANDRA***^FS"  //35
	EndIf
	
	@ 0,0 PSAY "^FT017,055^A0N,26,28^FH\^FDDescri\87\C6o:^FS"        //65
	@ 0,0 PSAY "^FT145,055^A0N,25,28^FH\^FD"+_cCdPrd1+"^FS"          //65
	
	If !Empty(_cCdPrd2)
		@ 0,0 PSAY "^FT017,085^A0N,25,28^FH\^FD"+_cCdPrd2+"^FS"    //95
	EndIf
	
	@ 0,0 PSAY "^FT297,085^A0N,25,28^FH\^FDCliente:^FS"    //95
	@ 0,0 PSAY "^FT388,085^A0N,25,28^FH\^FD"+_cRazaoCli+"^FS"    //95
	
	If lRetrb // chamada da CDBAL06
		@ 0,0 PSAY "^FT017,125^A0N,26,28^FH\^FDN.Retr:^FS"     //135
		@ 0,0 PSAY "^FT145,125^A0N,26,31^FH\^FD" + ZZE->ZZE_ID + "^FS"
		@ 0,0 PSAY "^FT297,125^A0N,26,28^FH\^FDPedido:^FS"
		@ 0,0 PSAY "^FT396,125^A0N,26,31^FH\^FD" + _cZZEPed + "^FS"
	Else // Chamada por CDESTR06
		@ 0,0 PSAY "^FT017,125^A0N,26,28^FH\^FDResumo:^FS"
		@ 0,0 PSAY "^FT145,125^A0N,26,31^FH\^FD"+Transform(TRB1->SEMANA,"@R XXXXXX-X")+"^FS"
		@ 0,0 PSAY "^FT297,125^A0N,26,28^FH\^FDPedido:^FS"
		@ 0,0 PSAY "^FT396,125^A0N,26,31^FH\^FD"+TRB1->PEDIDO + "-" + TRB1->ITEM+"^FS"
	EndIf
	
	@ 0,0 PSAY "^FT017,155^A0N,26,28^FH\^FDAcondic.:^FS" //175
	If Left(_cAcond,1) == "B"
		@ 0,0 PSAY "^FT141,155^A0N,32,36^FH\^FD"+"Bobina"+"^FS"  //175
		@ 0,0 PSAY "^FT245,155^A0N,32,36^FH\^FD"+StrZero(_nTpbob,2)+"^FS" //175
	ElseIf Left(_cAcond,1) == "S"
		@ 0,0 PSAY "^FT141,155^A0N,32,36^FH\^FD"+"SUCATA"+"^FS"                //175
	Else
		@ 0,0 PSAY "^FT141,155^A0N,32,36^FH\^FD"+_cAcond+"^FS"
	EndIf
	@ 0,0 PSAY "^FT297,155^A0N,26,28^FH\^FDLance:^FS"
	@ 0,0 PSAY "^FT388,155^A0N,30,36^FH\^FD"+Transform(Val(Substr(_cAcond,2,5)),"@E 999,999")+"^FS"
	@ 0,0 PSAY "^FT496,155^A0N,25,28^FH\^FDm.^FS"
	
	@ 0,0 PSAY "^FT017,195^A0N,28,28^FH\^FDLote:^FS"   //215
	@ 0,0 PSAY "^FT297,195^A0N,28,28^FH\^FDReal (mts):^FS"
	
	If !lRetrb // chamada da CDBAL06
		//Acrescentada a Filial para trataiva por filial no PC-Factory - Juliana Leme 13/07/2015
		@ 0,0 PSAY "^FO027,205^BY3,,50^BCN,50,N,N,N^FD" + xFilial("SC5") + Left(AllTrim(_cNumOP),11) + "^FS"  //_cNumOP
	EndIf
	
	@ 0,0 PSAY "^PQ"+StrZero(_nQtdEt,3)+",0,1,Y^XZ"
	
	SET DEVICE TO SCREEN
	If aReturn[5]==1
		DbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	EndIf
	MS_FLUSH()
Return(.T.)


/*/{Protheus.doc} Janela06
//TODO Static para criação da Janela.
@author zzz
@since 29/06/2017
@version undefined

@type function
/*/
Static Function Janela06()
	Local lRet, nOpca := 0,cSaveMenuh,nReg:=0
	Local aSize := {}
	Local aPosObj := {}
	Local aObjects := {}
	Local aInfo := {}
	
	aSize := MsAdvSize()
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aAdd( aObjects, { 100, 100, .t., .t. } )
	aAdd( aObjects, { 100, 100, .t., .t. } )
	aAdd( aObjects, { 100, 015, .t., .f. } )
	aPosObj := MsObjSize( aInfo, aObjects )
	aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,265}} )
	
	Private oDlg
	
	cTitulo := "Etiquetas p/ Produção - Digite Quantidade de Lances"
	DEFINE MSDIALOG oDlg TITLE cTitulo From 0,0 to 27,50
	
	_nlinGet := 10
	@ _nlinGet,010 Say "Código:" Size  30,10 PIXEL
	@ _nlinGet,040 Get _MV_PAR01 Picture "XXXXXXXXXX" When .F. Size  40,04 PIXEL
	
	_nlinGet += 15
	@ _nlinGet,010 Say "Descrição:" Size  30,10 PIXEL
	@ _nlinGet,040 Get _MV_PAR02 Picture "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" When .F. Size  150,04 PIXEL
	
	_nlinGet += 15
	@ _nlinGet,010 Say "Acondic.:" Size  30,10 PIXEL
	@ _nlinGet,040 Get _MV_PAR03 Picture "XXXXXXXXXX" When .F. Size  40,04 PIXEL
	
	//If MV_PAR04 == 1
	If _MyMvPar04 == 1
		_nlinGet += 15
		@ _nlinGet,010 Say "Tp.Bob.:"  Size  30,10 PIXEL
		@ _nlinGet,040 Get _MV_PAR04 Picture "XXXXXXX" When .F. Size  40,04 PIXEL
	EndIf
	
	_nlinGet += 15
	@ _nlinGet,010 Say "Qt.Metros:" Size  30,10 PIXEL
	@ _nlinGet,040 Get _MV_PAR05 Picture "@E 99999,999" When .F. Size  40,04 PIXEL
	
	_nlinGet += 15
	@ _nlinGet,010 Say "Qt.Lances:" Size  30,10 PIXEL
	@ _nlinGet,040 Get _MV_PAR06 Picture "@E 99999,999" When .F. Size  40,04 PIXEL
	
	_nlinGet += 15
	@ _nlinGet,010 Say "Lces Impr:" Size  30,10 PIXEL
	@ _nlinGet,040 Get _MV_PAR07 Picture "@E 99999,999" Valid _MV_PAR07 >=0 .And. _MV_PAR07 <= _MV_PAR06 Size  40,04 PIXEL
	
	_nlinGet += 15
	@ _nlinGet,010 Say "Pedido:" Size  30,10 PIXEL
	@ _nlinGet,040 Get _MV_PAR08 Picture "XXXXXX" When .F. Size  40,04 PIXEL
	
	_nlinGet += 15
	@ _nlinGet,010 Say "Item:" Size  30,10 PIXEL
	@ _nlinGet,040 Get _MV_PAR09 Picture "XX" When .F. Size  40,04 PIXEL
	
	_nlinGet += 15
	@ _nlinGet,010 Say "Dt.Entrega:" Size  30,10 PIXEL
	@ _nlinGet,040 Get _MV_PAR10    When .F. Size  40,04 PIXEL
	
	_nlinGet += 15
	@ _nlinGet,010 Say "Resumo:" Size  30,10 PIXEL
	@ _nlinGet,040 Get _MV_PAR11 Picture "@R XXXXXX-X" When .F. Size  40,04 PIXEL
	
	@ 180,120 BMPBUTTON TYPE 01 ACTION Cria_oDlg() // Ok
	@ 180,160 BMPBUTTON TYPE 02 ACTION Close(oDlg) // Cancela
	
	l_Confirma := .F.
	
	oDlg:Refresh()
	
	ACTIVATE MSDIALOG oDlg CENTERED

Return(l_Confirma)


/*/{Protheus.doc} Cria_oDlg
//TODO Descrição auto-gerada.
@author zzz
@since 29/06/2017
@version undefined

@type function
/*/
Static Function Cria_oDlg()
	l_Confirma := .T.
	Close(oDlg)
Return(.T.)


/*/{Protheus.doc} ClcTpBob
//TODO Calcula Tipo Bobina para o lance informado.
@author zzz
@since 29/06/2017
@version undefined
@param _cAcd, , descricao
@param _cPrd, , descricao
@param _nMtr, , descricao
@param _CodCliLj, , descricao
@param _TipBob, , descricao
@param _lBobCli, , descricao
@param _C5EMISSAO, , descricao
@type function
/*/
Static Function ClcTpBob(_cAcd,_cPrd,_nMtr,_CodCliLj,_TipBob,_lBobCli,_C5EMISSAO)
	DEFAULT _C5EMISSAO := Date()
	If _cAcd == "B"
		// Calcula o tipo da bobina padrão
		If _C5EMISSAO <= Ctod("06/05/2017") // Pedidos incluidos até dia 6 tem que calcular da forma antiga
			_TpBob := Right("     "+AllTrim(u_CalcBob(_cPrd,_nMtr)[1]),6) //PRODUTO, METROS, TP_RETORNO(TF),CODCLI,LOJA
		Else
			_TpBob := Right("     "+AllTrim(u_CalcBob(_cPrd,_nMtr,,Left(_CodCliLj,TamSX3("A1_COD")[1]),;
											Substr(_CodCliLj,(TamSX3("A1_COD")[1]+1),TamSX3("A1_LOJA")[1]))[1]),6) //PRODUTO, METROS, TP_RETORNO(TF),CODCLI,LOJA
		EndIf
		If _TipBob == "00" .Or. Empty(_CodCliLj)// Usar a Bobina padrão ou não tem cliente
			_TpBobCli := _TpBob
		Else
			_cPsBobP := At(_TpBob," 65/25, 65/45, 80/45,100/60,125/70,150/80,170/80")
			_cPsBobP := Str(((_cPsBobP+6) / 7),1)
			If _cPsBobP < Left(_TipBob,1) // A Bob.Padrão é menor que a menor que o cliente aceita
				_TpBob := Left(_TipBob,1)
			ElseIf _cPsBobP > Right(_TipBob,1) // A Bob.Padrão é maior que a maior que o cliente aceita
				_TpBob := Right(_TipBob,1)
			Else
				_TpBob := _cPsBobP
			EndIf
			_TpBobCli := Substr(" 65/25, 65/45, 80/45,100/60,125/70,150/80,170/80",((7 * (Val(_TpBob)-1)) + 1),6)
		EndIf
	Else
		_TpBobCli := "  "
	EndIf
Return(_TpBobCli)

/*/{Protheus.doc} EstEtq
//TODO Estorna Etiquetas da Lista de Repasse.
@author zzz
@since 29/06/2017
@version undefined

@type function
/*/
User Function EstEtq()
	DbSelectArea("SZ9")
	DbSetOrder(1) // Z9_FILIAL+Z9_SEMANA+Z9_PRODUTO+Z9_LOCAL+Z9_LOCALIZ+Z9_PEDIDO+Z9_ITEMPV
	_aTamVari := {Len(SZ9->Z9_SEMANA),Len(SZ9->Z9_PRODUTO),Len(SZ9->Z9_LOCALIZ),Len(SZ9->Z9_PEDIDO),Len(SZ9->Z9_ITEMPV)}
	_lFiz := .F.
	Do While .T.
		aRet :={}
		aParamBox := {}
		aAdd(aParamBox,{1,"Cod.Produto..:",Space(_aTamVari[2]),"","","",".T.",55,.F.})
		aAdd(aParamBox,{1,"Resumo.......:",Space(_aTamVari[1]),"@R XXXXXX-X","","",".T.",26,.F.})
		aAdd(aParamBox,{1,"Nro. Pedido..:",Space(_aTamVari[4]),"","","",".T.",22,.F.})
		aAdd(aParamBox,{1,"Item Pedido..:",Space(_aTamVari[5]),"","","",".T.",10,.F.})
		aAdd(aParamBox,{1,"Acondic......:",Space(_aTamVari[3]),"","","",".T.",55,.F.})
	
		//Chamada da Função ParamBox -> Retorno logico
		//_lResp := ParamBox(aParamBox, "Estorno de Etiquetas (1 por Vez)", @aRet)
		_lResp := ParamBox(aParamBox, "Estorno de Etiquetas (1 por Vez)", @aRet,,,,,,,.F.,,)
	
		If !_lResp
			Exit
		EndIf
	
		// // Z9_FILIAL+Z9_SEMANA+Z9_PRODUTO+Z9_LOCAL+Z9_LOCALIZ+Z9_PEDIDO+Z9_ITEMPV
		If !SZ9->(DbSeek(xFilial("SZ9") + aRet[2] + aRet[1] + "01" + aRet[5] + aRet[3] + aRet[4],.F.))
			ALert(	"Dados Não Localizados - Etiqueta não Estornada" + Chr(13) + Chr(13) +;
			"Cod.Produto..: " + aRet[1] + Chr(13) +;
			"Resumo.......: " + aRet[2] + Chr(13) +;
			"Nro. Pedido..: " + aRet[3] + Chr(13) +;
			"Item Pedido..: " + aRet[4] + Chr(13) +;
			"Acondic......: " + aRet[5])
			Loop
		ElseIf SZ9->Z9_ETIQIMP <= 0
			Alert("Não há Etiquetas a Estornar" + Chr(13) + Chr(13) +;
			"Cod.Produto..: " + aRet[1] + Chr(13) +;
			"Resumo.......: " + aRet[2] + Chr(13) +;
			"Nro. Pedido..: " + aRet[3] + Chr(13) +;
			"Item Pedido..: " + aRet[4] + Chr(13) +;
			"Acondic......: " + aRet[5])
			Loop
		EndIf
		_lFiz := .T.
		RecLock("SZ9",.F.)
		SZ9->Z9_ETIQIMP := SZ9->Z9_ETIQIMP-1
		SZ9->Z9_IMPETIQ := "N"
		MsUnLock()
		Alert(	"Etiqueta Estornada:" + Chr(13) + Chr(13) +;
		"Cod.Produto..: " + aRet[1] + Chr(13) +;
		"Resumo.......: " + aRet[2] + Chr(13) +;
		"Nro. Pedido..: " + aRet[3] + Chr(13) +;
		"Item Pedido..: " + aRet[4] + Chr(13) +;
		"Acondic......: " + aRet[5])
	EndDo
	If _lFiz
		Alert(	"Para que as Alterações Realizadas Tenham Efeito "  + Chr(13) +;
		"é Necessário Reiniciar esta Rotina")
	EndIf
Return(.T.)

aSort(_aTpBobs,,,{|x,y| x[1]<y[1]})
