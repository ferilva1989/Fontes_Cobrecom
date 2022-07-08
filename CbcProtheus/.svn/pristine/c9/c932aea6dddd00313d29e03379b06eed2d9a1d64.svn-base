#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CDFATR10 º Autor ³ EDVAR VASSAITIS    º Data ³  06/10/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatório Pedidos de Venda - BNDES                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CDFATR10()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Pedidos de Venda - BNDES"
	Local cPict          := ""
	Local titulo         := "Pedidos de Venda - BNDES"
	Local Cabec1         := ""
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Local nLin           := 999
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "CDFATR10" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "CDFATR10"
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "CDFATR10" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString      := "SC6"

	ValidPerg()
	If !Pergunte(cPerg, .T.)
		Return(.T.)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)
	titulo := "Pedidos de Venda - BNDES"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  15/08/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem
	Local aIcmRet      := {}
	Local nPos         := 0
	Local _nPosFisRet  := 0
	Local _B1_ORIGEM
	Private nMaxLin    := 65
	Private _BaseIcm   := 0.00
	Private _ValIcm    := 0.00
	Private _nLinha    := 999

	DbSelectArea("SZ1") // NOMES DE PRODUTOS
	DbSetOrder(1)//Z1_FILIAL+Z1_COD

	DbSelectArea("SF4")
	DbSetOrder(1)//F4_FILIAL+F4_CODIGO

	DbSelectArea("SA1")
	DbSetOrder(1)//A1_FILIAL+A1_COD+A1_LOJA

	DbSelectArea("SB1")
	DbSetOrder(1)//B1_FILIAL+B1_COD

	DbSelectArea("SC6")
	DbSetOrder(1)//C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	DbSelectArea("SC5")
	DbSetOrder(1)//C5_FILIAL+C5_NUM
	DbSeek(xFilial("SC5")+mv_par01,.F.)
	SetRegua(Val(mv_par02)-Val(mv_par01)+1)

	Do While !SC5->(Eof()) .And. SC5->C5_FILIAL == xFilial("SC5") .And. SC5->C5_NUM <= mv_par02
		IncRegua()

		aImpr   := {}
		_nTotBs := 0 // Total Base comissão
		_nTotCm := 0 // Vlr. Total comissão
		_nPosFisRet := 0

		//Somente pedido normal //Somente condicao de pagamento BNDES
		If Alltrim(SC5->C5_TIPO) <> "N" .And. SC5->C5_CONDPAG <> "000"
			SC5->(dbSkip())
			Loop
		EndIf

		SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
		SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM,.F.))

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa a funcao fiscal                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisSave()
		MaFisEnd()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Alimenta as variáveis de cabeçalho para utilizar no calculo dos impostos ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		MaFisIni(SC5->C5_CLIENTE,;					// 1-Codigo Cliente/Fornecedor
		SC5->C5_LOJACLI,;	    			// 2-Loja do Cliente/Fornecedor
		IIf(SC5->C5_TIPO $ "DB","F","C"),;	// 3-C:Cliente , F:Fornecedor
		SC5->C5_TIPO,;						// 4-Tipo da NF
		SC5->C5_TIPOCLI,;					// 5-Tipo do Cliente/Fornecedor
		Nil,;
		Nil,;
		Nil,;
		Nil,;
		"MATA461")

		Do While !SC6->(Eof()) .And. SC6->C6_FILIAL == xFilial("SC6") .And. SC5->C5_NUM == SC6->C6_NUM

			SZ1->(DbSeek(xFilial("SZ1")+Left(SC6->C6_PRODUTO,3),.F.))
			SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES,.F.))

			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.)

			_B1_ORIGEM := SB1->B1_ORIGEM
			If SB1->B1_ORIGEM # Left(SC6->C6_CLASFIS,1)
				RecLock("SB1",.F.)
				SB1->B1_ORIGEM := Left(SC6->C6_CLASFIS,1)
				MsUnLock()
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Agrega os itens para a funcao fiscal         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MaFisAdd(SC6->C6_PRODUTO,;	// 1-Codigo do Produto ( Obrigatorio )
			SC6->C6_TES,;	   			// 2-Codigo do TES ( Opcional )
			SC6->C6_QTDVEN,;		    // 3-Quantidade ( Obrigatorio )
			SC6->C6_PRCVEN,;   			// 4-Preco Unitario ( Obrigatorio )
			0,;                         // 5-Valor do Desconto ( Opcional )
			"",;	   				    // 6-Numero da NF Original ( Devolucao/Benef )
			"",;					    // 7-Serie da NF Original ( Devolucao/Benef )
			0,;     				    // 8-RecNo da NF Original no arq SD1/SD2
			0,;					 		// 9-Valor do Frete do Item ( Opcional )
			0,;					   		// 10-Valor da Despesa do item ( Opcional )
			0,;					 	    // 11-Valor do Seguro do item ( Opcional )
			0,;					    	// 12-Valor do Frete Autonomo ( Opcional )
			SC6->C6_VALOR,;  			// 13-Valor da Mercadoria ( Obrigatorio )
			0)						    // 14-Valor da Embalagem ( Opiconal )

			_nPosFisRet ++  //Obrigatorio, pois deve se manter a estrutura do array no mafisadd

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Retorna Imposto conforme segundo parametro   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_BaseIcm := MaFisRet(_nPosFisRet, "IT_BASEICM")
			_ValIcm  := MaFisRet(_nPosFisRet, "IT_VALICM")

			// Estas variáveis são para manter compatibilidade com as variáveis
			// criadas na U_M460Soli
			_MyBsICM := _BaseIcm
			_MyVlICM := _ValIcm

			_BasIcmRet 	:= MaFisRet(_nPosFisRet, "IT_BASESOL")
			_IcmRetido	:= MaFisRet(_nPosFisRet, "IT_VALSOL")

			If SA1->A1_COD # SC5->C5_CLIENTE .Or. SA1->A1_LOJA # SC5->C5_LOJACLI
				DbSetOrder(1)
				DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.)
			EndIf

			aIcmRet := {}
			aIcmRet := {_BasIcmRet,_IcmRetido}//Retorna Base e Valor de ICMS Retido

			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.)

			If SB1->B1_ORIGEM # _B1_ORIGEM
				RecLock("SB1",.F.)
				SB1->B1_ORIGEM := _B1_ORIGEM
				MsUnLock()
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Adiciona no Array para impressão            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nPos   := aScan( aImpr ,{|x| x[1] == SZ1->Z1_CODBNDE})
			If nPos == 0
				aAdd( aImpr,{SZ1->Z1_CODBNDE,SZ1->Z1_DESCBND,SC6->C6_QTDVEN,SC6->C6_VALOR + aIcmRet[2]})
			Else
				aImpr[nPos,3] += SC6->C6_QTDVEN
				aImpr[nPos,4] += SC6->C6_VALOR+aIcmRet[2]
			EndIf

			_nTotBs += SC6->C6_VALOR // Total Base comissão
			If SC6->C6_COMIS1 > 0
				_nTotCm += Round(((SC6->C6_VALOR * SC6->C6_COMIS1) / 100),2) // Vlr. Total comissão
			EndIf
			SC6->(dbSkip())
		EndDo

		_nLinha := 999//Nova Folha de Impressao
		If Len(aImpr) > 0
			Imprime(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		EndIf

		SC5->(dbSkip())
	EndDo

	MaFisEnd()
	MaFisRestore()

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

	Return(.T.)

	*
	*************************
Static Function Imprime(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	*************************
	*

	Local nPos     := 0
	Local aTotQtd  := 0
	Local aTotTot  := 0

	aSort(aImpr,,,{|x,y| x[1]<y[1]})

	For nPos := 1 to Len(aImpr)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do cabecalho do relatorio. . .                            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If _nLinha > nMaxLin // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			_nLinha := 8
			ImprCabec()
		Endif

		@ _nLinha,000 Psay "|"
		@ _nLinha,002 Psay Iif( !Empty(aImpr[nPos,1]) , aImpr[nPos,1] ,"??????")
		@ _nLinha,016 Psay "|"
		@ _nLinha,018 Psay aImpr[nPos,2]
		@ _nLinha,067 Psay "|"
		@ _nLinha,071 Psay aImpr[nPos,3] Picture "@E 99,999,999"
		@ _nLinha,084 Psay "|"
		@ _nLinha,087 Psay aImpr[nPos,4] / aImpr[nPos,3] Picture "@E 99,999,999.9999"
		@ _nLinha,107 Psay "|"
		@ _nLinha,111 Psay aImpr[nPos,4] Picture "@E 99,999,999.99"
		@ _nLinha,131 Psay "|"
		_nLinha := _nLinha + 1 // Avanca a linha de impressao


		//Totais do Relatorio
		aTotQtd  += aImpr[nPos,3]
		aTotTot  += aImpr[nPos,4]

		//Impressao de Totais do Relatorio
		If nPos == Len(aImpr)
			@ _nLinha,00 PSay Replicate("-",limite)
			_nLinha := _nLinha + 1
			@ _nLinha,000 Psay "|"
			@ _nLinha,002 Psay "TOTAL ->"
			@ _nLinha,016 Psay "|"
			@ _nLinha,067 Psay "|"
			@ _nLinha,071 Psay aTotQtd Picture "@E 99,999,999"
			@ _nLinha,084 Psay "|"
			@ _nLinha,107 Psay "|"
			@ _nLinha,111 Psay aTotTot Picture "@E 99,999,999.99"
			@ _nLinha,131 Psay "|"
			_nLinha := _nLinha + 1 // Avanca a linha de impressao
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao do rodape do relatorio. . .                               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If _nLinha == nMaxLin  .Or. nPos == Len(aImpr)
			@ _nLinha,00 PSay Replicate("-",limite)
			_nLinha := _nLinha + 1
			roda(1,"FIM DA PAGINA",tamanho)
		EndIf

	Next

Return(.T.)

/////////////////////////
Static Function ImprCabec()
	/////////////////////////

	DbSelectArea("SA1")
	DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.)

	@ _nLinha,00 PSay "PEDIDO: "+SC5->C5_NUM
	_nLinha++
	@ _nLinha,00 PSay "DATA DO PEDIDO: "+DToC(SC5->C5_EMISSAO)
	@ _nLinha,70 PSay "CIDADE: "+Left(SA1->A1_MUN,25)
	@ _nLinha,105 PSay "UF: "+SA1->A1_EST
	_nLinha++
	@ _nLinha,00 PSay "CLIENTE: "+SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI+" - "+SA1->A1_NOME

	_cMyTpCli := "?????"
	If SC5->C5_TIPOCLI == "S"
		_cMyTpCli := "Solidario"
	ElseIf SC5->C5_TIPOCLI == "F"
		_cMyTpCli := "Cons.Final"
	ElseIf SC5->C5_TIPOCLI == "R"
		_cMyTpCli := "Revend."
	EndIf
	@ _nLinha,105 PSay "TP.CLI.: "+_cMyTpCli
	_nLinha++
	@ _nLinha,00 PSay "CNPJ/CPF: "+If(Len(AllTrim(SA1->A1_CGC))==11,;
	Transform(SA1->A1_CGC,"@R 999.999.999-99"),;
	Transform(SA1->A1_CGC,"@R 99.999.999/9999-99"))
	@ _nLinha,70 PSay "FONE: "+SA1->A1_TEL
	_nLinha++
	@ _nLinha,00 PSay "VENDEDOR: "+SC5->C5_VEND1+" - "+Posicione("SA3",1,xFilial("SA3")+SC5->C5_VEND1,"A3_NOME")

	// By Roberto Oliveira 02/04/14 - Visto que a comissão estava pegando do C5 e como a comissão é por item,
	// estou calculando uma média da comissão do pedido de venda.
	//@ _nLinha,70 PSay "COMISSÃO: "
	//@ _nLinha,80 PSay SC5->C5_COMIS1 Picture "@E 999.99"

	_nMedia := Round(((_nTotCm / _nTotBs) / 100),2)
	@ _nLinha,70 PSay "COMISSÃO MEDIA:"
	@ _nLinha,86 PSay _nMedia Picture "@E 999.99"

	_nLinha++
	//@ _nLinha,00 PSay "DATA DE ENTREGA: "+DToC(SC5->C5_ENTREG)
	@ _nLinha,00 PSay "DATA DE EMBARQUE: "+DToC(SC5->C5_ENTREG)
	//-OK If !GetMv("MV_ZZUSAC9")
		@ _nLinha,40 PSay "Status: " + If(SC5->C5_ZSTATUS < "1","Normal",If(SC5->C5_ZSTATUS==Padr('1',TamSX3("C5_ZSTATUS")[1]),"Em Separ.","Em Fatur."))
	/*/Else
		@ _nLinha,40 PSay "Status: " + "VER SC9"
	EndIf/*/
	@ _nLinha,70 PSay "CIDADE: "+Left(SA1->A1_MUN,25)
	@ _nLinha,105 PSay "UF: "+SA1->A1_EST
	_nLinha++
	@ _nLinha,00 PSay "COND. DE PGTO: "+ AllTrim(SC5->C5_CONDPAG) + "  -  " + Posicione("SE4",1,xFilial("SE4")+SC5->C5_CONDPAG,"E4_DESCRI")
	_nLinha++
	@ _nLinha,00 PSay "OBSERVACOES: "+SC5->C5_OBS
	_nLinha++
	@ _nLinha,00 PSay "TRANSP.: " + SC5->C5_TRANSP + " " + If(!Empty(SC5->C5_TRANSP),Posicione("SA4",1,xFilial("SA4")+SC5->C5_TRANSP,"A4_NOME"),"")

	_cMyTpFrete := "????"
	If SC5->C5_TPFRETE == "C"
		_cMyTpFrete := "CIF"
	ElseIf SC5->C5_TPFRETE == "F"
		_cMyTpFrete := "FOB"
	EndIf

	@ _nLinha,70 PSay "TIPO FRETE : " + _cMyTpFrete
	_nLinha++
	@ _nLinha,00 PSay Replicate("-",limite)
	_nLinha++
	@ _nLinha,00 PSay "| CODIGO BNDES  | DESCRIÇÃO                                        |   QUANTIDADE   |    VALOR UNITÁRIO    |   TOTAL c/ IMPOSTOS   |"
	_nLinha++
	@ _nLinha,00 PSay Replicate("-",limite)
	_nLinha++

	Return(.T.)

	*
	***************************
Static Function ValidPerg()
	***************************
	*
	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	aAdd(aRegs,{cPerg,"01","Pedido de  ?","mv_ch1","C",TamSX3("C6_NUM")[1],0,0,"G","","mv_par01","","","","","","","","","","","","","","","SC6"})
	aAdd(aRegs,{cPerg,"02","Pedido ate ?","mv_ch2","C",TamSX3("C6_NUM")[1],0,0,"G","","mv_par02","","","","","","","","","","","","","","","SC6"})

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