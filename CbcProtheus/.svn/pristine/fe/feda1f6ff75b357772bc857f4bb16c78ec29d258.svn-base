#include "rwmake.ch"
//
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDNFES                               Modulo : SIGAFAT    //
//                                                                          //
//   Autor ......: PAULO ROBERTO DE OLIVEIRA            Data ..: 16/07/04   //
//                                                                          //
//   Objetivo ...: Emissao de Notas Fiscais de Entrada/Saida                //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//   Observacoes : A emissao da nota fiscal sera com 1/8 e comprimida       //
//                                                                          //
//   Atualizacao : 16/07/04 - PAULO ROBERTO DE OLIVEIRA                     //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
//

User Function CDNFES()
	SetPrvt("CBTXT,CBCONT,xMensage1,xMensage2,xMensage3")
	SetPrvt("xMensage4,xMensage5,xMensage6,XAPOLICE,XFRETMOT")
	SetPrvt("NORDEM,ALFA,Z,M,TAMANHO,XPLACA,XESTPLA,XMARCA")
	SetPrvt("LIMITE,TITULO,CDESC1,CDESC2,CDESC3,CNATUREZA")
	SetPrvt("ARETURN,NOMEPROG,CPERG,NLASTKEY,LCONTINUA,NLIN")
	SetPrvt("WNREL,NTAMNF,CSTRING,NLININI,XNUM_NF")
	SetPrvt("XSERIE,XEMISSAO,XTOT_FAT,XLOJA,XFRETE,XSEGURO")
	SetPrvt("XDESPESA,XBASE_ICMS,XBASE_IPI,XVALOR_ICMS,XICMS_RET,XVALOR_IPI")
	SetPrvt("XVALOR_MERC,XNUM_DUPLIC,XCOND_PAG,XPLIQUI,xTIPO,XESPECIE")
	SetPrvt("XVOLUME,XDESCZFR,CPEDATU,CITEMATU,XORD,XORDENA,XDATA_DV")
	SetPrvt("XPED_VEND,XITEM_PED,XNUM_NFDV,XPREF_DV,XITEM_DV,XICMS,XCOD_PRO")
	SetPrvt("XQTD_PRO,XPRE_UNI,XPRE_TAB,XIPI,XVAL_IPI,XDESC,XDESCON")
	SetPrvt("XVAL_DESC,XVAL_MERC,XTES,XCF,XNATUREZA,XICMSOL,XQTD_DV,XVAL_DV,xAcond")
	SetPrvt("XICM_PROD,XICMSITE,XUNID_PRO,XCOD_TRIB,XCLAS_FIS")
	SetPrvt("XISS,xTIPO_PRO,XCLFISCAL,xTIPOPRO,XMEN_TRIB,XLUCRO")
	SetPrvt("I,NPELEM,NPTESTE,XCLASFIS,XPOSIPI")
	SetPrvt("XPED,XP_LIQ_PED,XC5_VEND1,XC5_NUM,XCLIENTE,xTIPO_CLI")
	SetPrvt("XCOD_MENS,XTPFRETE,XCONDPAG,XBANCO,XPESOLIQUI,xPesoCS,xPesoBt,XPESOBRUTO")
	SetPrvt("XCOD_VEND,XDESC_NF,XDESC_PAG,XPED_CLI,XDESC_PRO,J,xVlrMetal")
	SetPrvt("XNOME_CLI,XEND_CLI,XBAIRRO,XCEP_CLI,XCOB_CLI,XREC_CLI")
	SetPrvt("XMUN_CLI,XEST_CLI,XCGC_CLI,XINSC_CLI,XTRAN_CLI,XTEL_CLI")
	SetPrvt("XFAX_CLI,XSUFRAMA,XCALCSUF,ZFRANCA,XCOD_CLI,XVENDEDOR")
	SetPrvt("XBSICMRET,XNOME_TRANSP,XEND_TRANSP,XMUN_TRANSP,XEST_TRANSP,XVIA_TRANSP")
	SetPrvt("XCGC_TRANSP,XTEL_TRANSP,XINSC_TRANSP,XPARC_DUP,XVENC_DUP,XVALOR_DUP")
	SetPrvt("XDUPLICATAS,XPORTADOR,XPEDCLI,XFORNECE,XNFORI,XPEDIDO")
	SetPrvt("NOPC,CCOR,NTAMDET,XB_ICMS_SOL,XV_ICMS_SOL")
	SetPrvt("XX,AA,XORDIMP,WVALISS,WTOTSER,WTOTPRO,LPASSA,XORDPRO")
	SetPrvt("NCOL,NCONT,XNLIN,XLINDUP01,XLINDUP02,LPESO")
	SetPrvt("XLINDUP03,XLINDUP04,XLINDUP05,XLINDUP06,XLINDUP07,XLINDUP08")
	SetPrvt("XNATOP,XCOLUNA,xNOMVEND1,xConfig,XDesconf,_lReEmissao,_lImpPeso")
	//
	CbTxt     := ""                   // Variaveis de Ambiente
	CbCont    := ""
	xMensage1 := ""
	xMensage2 := ""
	xMensage3 := ""
	xMensage4 := ""
	xMensage5 := ""
	xMensage6 := ""
	nOrdem    := 0
	Tamanho   := "G"
	Limite    := 132
	Titulo    := "Emissao de Nota Fiscal"
	cDesc1    := "Este programa ira emitir a Nota Fiscal de Entrada/Saida."
	cDesc2    := ""
	cDesc3    := ""
	cNatureza := ""
	aReturn   := {"Especial", 1, "Administracao", 1, 2, 1, "", 1}
	NomeProg  := "CDNFES"
	cPerg     := "CDNFES"
	nLastKey  := 0
	lContinua := .T.
	nLin      := 0
	wnRel     := "CDNFES"
	nTamNf    := 66                   // Apenas Informativo
	cString   := "SF2"
	wSERV     := .F.
	wPROD     := .F.
	xAPOLICE  := ""

	xConfig   := Chr(27) + Chr(48) + Chr(15)    // Impressao em 1/8 e Comprimido
	xDesConf  := Chr(18) + Chr(27) + Chr(50)    // Descomprimir e Desativar 1/8

	ValidPerg()
	Pergunte(cPerg, .F.)

	wnRel := SetPrint(cString, wnRel, cPerg, Titulo, cDesc1, cDesc2, cDesc3, .T.)

	If nLastKey == 27
		Return (.T.)
	Endif

	SetDefault(aReturn, cString)

	If nLastKey == 27
		Return (.T.)
	Endif

	RptStatus({|| ImpNotaF()})        // Impressao da Nota Fiscal

	Set Device To Screen
	If aReturn[5] == 1
		Set Printer To
		DbcommitAll()
		OurSpool(wnRel)
	Else
		Ms_Flush()
	Endif
Return (.T.)

Static Function ImpNotaF()
	_lImpPeso := .T.
	If Mv_Par04 == 2                       // Saidas
		DbSelectArea("SF2")
		SF2->(DbSetOrder(1))
		SF2->(DbSeek(xFilial("SF2") + Mv_Par01, .T.))

		DbSelectArea("SD2")
		SD2->(DbSetOrder(3))
	Else
		DbSelectArea("SF1")                 // Entradas
		SF1->(DbSetOrder(1))
		SF1->(DbSeek(xFilial("SF1") + Mv_Par01, .T.))

		DbSelectArea("SD1")
		SD1->(DbSetOrder(1))

		_lReEmissao := .F.
	Endif
	If Mv_Par02 < Mv_Par01
		Mv_Par02 := Mv_Par01
	Endif

	SetRegua(Val(Mv_Par02) - Val(Mv_Par01))

	If Mv_Par04 == 2                       // Saidas
		DbSelectArea("SF2")
		_lReEmissao := If(Empty(Mv_Par05),.F.,.T.)

		Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_DOC <= Mv_Par02 .And. lContinua .And. SF2->(!Eof())
			If SF2->F2_SERIE # Mv_Par03
				SF2->(DbSkip())
				Loop
			Endif
			If lAbortPrint
				lContinua := .F.
				Exit
			Endif

			nLinIni 	:= nLin               		// Linha Inicial da Impressao
			xNUM_NF     := SF2->F2_DOC              // Numero
			xSERIE      := SF2->F2_SERIE            // Serie
			xEMISSAO    := SF2->F2_EMISSAO          // Data de Emissao
			xTOT_FAT    := SF2->F2_VALBRUT          // Valor Total da Fatura
			xPesoCS     :=  0
			xPesoBt     := SF2->F2_PESOBOB
			xVlrMetal   := SF2->F2_VLRDESC

			If xTOT_FAT == 0
				xTOT_FAT := SF2->F2_VALMERC + SF2->F2_VALIPI + SF2->F2_SEGURO + SF2->F2_FRETE
			Endif

			xCLIENTE    := SF2->F2_CLIENTE          // Codigo do Cliente
			xLOJA       := SF2->F2_LOJA             // Loja do Cliente
			xFRETE      := SF2->F2_FRETE            // Frete
			xSEGURO     := SF2->F2_SEGURO           // Seguro
			xDESPESA    := SF2->F2_DESPESA          // Despesas acessorias
			xBASE_ICMS  := SF2->F2_BASEICM          // Base do ICMS
			xBASE_IPI   := SF2->F2_BASEIPI          // Base do IPI
			xVALOR_ICMS := SF2->F2_VALICM           // Valor do ICMS
			xICMS_RET   := SF2->F2_ICMSRET          // Valor do ICMS Retido
			xBSICMRET   := SF2->F2_BRICMS			// Base do ICMS Retido
			xVALOR_IPI  := SF2->F2_VALIPI           // Valor do IPI
			xVALOR_MERC := SF2->F2_VALMERC          // Valor da Mercadoria
			xNUM_DUPLIC := SF2->F2_DUPL             // Numero da Duplicata
			xCOND_PAG   := SF2->F2_COND             // Condicao de Pagamento
			xTIPO       := SF2->F2_TIPO             // Tipo da Nota
			xVOLUME		:= SF2->F2_VOLUME1			// Volume 1 no Pedido
			XESPECIE	:= SF2->F2_ESPECI1			// Especie 1 no Pedido
			xPESOLIQUI  := SF2->F2_PLIQUI			// Especie 1 no Pedido
			xPESOBRUTO  := SF2->F2_PBRUTO			// Especie 1 no Pedido
			xDESCZFR	:= 0                        // Desc. Zona Franca
			xDESCONT	:= SF2->F2_DESCONT          // Desconto da Nota Fiscal
			wVALISS		:= 0                        // Valor do ISS
			wTOTSER		:= 0                        // Total dos Servicos
			wTOTPRO		:= 0                        // Total dos Peodutos
			xPEDIDO		:= ""                    // Numero do Pedido de Compra do cliente
			_lImpPeso	:= .T.

			DbSelectArea("SD2")
			SD2->(DbSetOrder(3))
			SD2->(DbSeek(xFilial("SD2") + xNUM_NF + xSERIE, .F.))

			cPedAtu   := SD2->D2_PEDIDO
			cItemAtu  := SD2->D2_ITEMPV
			xORD      := {}                    // Ordem Original
			xORDENA   := {}                    // Ordena Impressao DETALHE N.F. - ORDEM PEDIDO DE VENDA
			xPED_VEND := {}                    // Numero do Pedido de Venda
			xITEM_PED := {}                    // Numero do Item do Pedido de Venda
			xNUM_NFDV := {}                    // Numero NF Qdo Houver Devolucao
			xPREF_DV  := {}                    // Serie Qdo Houver Devolucao
			xITEM_DV  := {}                    // Item Qdo Houver Devolucao
			xDATA_DV  := {}                    // Data Qdo Houver Devolucao
			xQTD_DV   := {}                    // Quantidade Qdo Houver Devolucao
			xVAL_DV   := {}                    // Valor Qdo Houver Devolucao
			xICMS     := {}                    // Porcentagem do ICMS
			xCOD_PRO  := {}                    // Codigo  do Produto
			xQTD_PRO  := {}                    // Peso/Quantidade do Produto
			xPRE_UNI  := {}                    // Preco Unitario de Venda
			xPRE_TAB  := {}                    // Preco Unitario de Tabela
			xIPI      := {}                    // Porcentagem do IPI
			xVAL_IPI  := {}                    // Valor do IPI
			xDESC     := {}                    // Desconto por Item
			xVAL_DESC := {}                    // Valor do Desconto
			xVAL_MERC := {}                    // Valor da Mercadoria
			xTES      := {}                    // TES
			xCF       := {}                    // Classificacao quanto natureza da Operacao
			xNATUREZA := {}                    // Nat. de Operacao
			xICMSOL   := {}                    // Base do ICMS Solidario
			xICM_PROD := {}                    // ICMS do Produto
			xICMSITE  := {}
			xAcond    := {}				       // Acondicionamento
			xDESP_FIN := 0                     // Total das Despesas Financeiras
			xPEDIDO   := ""                    // Numero do Pedido de Compra do cliente
			_lImpPeso := .T.

			Do While SD2->(!Eof()) .And. SD2->D2_FILIAL == xFilial("SD2") .And. SD2->D2_DOC == xNUM_NF .And. SD2->D2_SERIE == xSERIE
				If SD2->D2_SERIE # Mv_Par03
					SD2->(DbSkip())
					Loop
				Endif

				If !Empty(SD2->D2_PEDIDO)
					Aadd(xORDENA  , SD2->D2_ITEMPV)
					Aadd(xORD     , {SD2->D2_ITEMPV, Len(xORDENA)})
					Aadd(xPED_VEND, SD2->D2_PEDIDO)
					Aadd(xITEM_PED, SD2->D2_ITEMPV)
					If Empty(xPEDIDO)
						xPEDIDO  := Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_PEDCLI")
					EndIf
					If _lImpPeso
						_lImpPeso  := !(Posicione("SC5",1,xFilial("SC5")+SD2->D2_PEDIDO,"C5_DESCEQT") > 0)
					EndIf
				EndIf

				xPesoCS += (Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_PESO") * SD2->D2_QUANT)
				xPesoBt += (Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_PESO") * SD2->D2_QUANT)

				Aadd(xNUM_NFDV, SD2->D2_NFORI)
				Aadd(xPREF_DV , SD2->D2_SERIORI)
				Aadd(xITEM_DV , SD2->D2_ITEMORI)
				Aadd(xDATA_DV , SD2->D2_EMISSAO)
				Aadd(xQTD_DV  , SD2->D2_QTDEDEV)
				Aadd(xVAL_DV  , SD2->D2_VALDEV)
				Aadd(xICMS    , IIf(Empty(SD2->D2_PICM), 0, SD2->D2_PICM))
				Aadd(xCOD_PRO , SD2->D2_COD)
				Aadd(xQTD_PRO , SD2->D2_QUANT)

				If SD2->D2_DESCZFR == 0
					Aadd(xVAL_MERC, (SD2->D2_TOTAL ))
					Aadd(xPRE_UNI , (SD2->D2_PRCVEN ))
					//
				Else
					//
					Aadd(xVAL_MERC, SD2->D2_TOTAL + SD2->D2_DESCZFR)
					Aadd(xPRE_UNI , (SD2->D2_TOTAL + SD2->D2_DESCZFR) / SD2->D2_QUANT)
					//
					xDESCZFR := xDESCZFR + SD2->D2_DESCZFR
					//
				Endif
				//
				Aadd(xPRE_TAB, SD2->D2_PRUNIT)
				Aadd(xIPI    , IIf(Empty(SD2->D2_IPI), 0, SD2->D2_IPI))
				Aadd(xVAL_IPI, SD2->D2_VALIPI)
				Aadd(xDESC   , SD2->D2_DESC)
				Aadd(xICMSITE, SD2->D2_VALICM)
				Aadd(xTES , SD2->D2_TES)
				Aadd(xCF  , SD2->D2_CF)
				Aadd(xICM_PROD, IIf(Empty(SD2->D2_PICM), 0, SD2->D2_PICM))

				xDESP_FIN := xDESP_FIN + ((SD2->D2_PRCVEN - SD2->D2_PRUNIT) * SD2->D2_QUANT)

				DbSelectArea("SDB")
				DbSetOrder(1) // sdb->(DB_FILIAL+sdb->(DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM)

				_cAcondic := "    "
				DbSeek(xFilial("SDB") + SD2->D2_COD + SD2->D2_LOCAL + SD2->D2_NUMSEQ+ SD2->D2_DOC + SD2->D2_SERIE+ SD2->D2_CLIENTE + SD2->D2_LOJA,.F.)
				If SDB->(Eof()) .And.  SD2->D2_SERIE == "U  " // Transferência para sucata
					DbSetOrder(7) // DB_FILIAL+DB_PRODUTO+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_SERVIC+DB_TAREFA+DB_ATIVID
					DbSeek(xFilial("SDB") + SD2->D2_COD + "RM" + SD2->D2_NUMSEQ,.F.)
				EndIf
				If SDB->(!Eof())
					If Left(SDB->DB_LOCALIZ,6)=="R00015"
						_cAcondic := "Rl.15mt"
					ElseIf Left(SDB->DB_LOCALIZ,6)=="R00050"
						_cAcondic := "Rl.50mt"
					ElseIf Left(SDB->DB_LOCALIZ,6)=="L00015"
						_cAcondic := "Bl.15mt"
					ElseIf Left(SDB->DB_LOCALIZ,1)=="R"
						_cAcondic := "ROLO"
					ElseIf Left(SDB->DB_LOCALIZ,1)=="B"
						_cAcondic := "BOB."
					ElseIf Left(SDB->DB_LOCALIZ,1)=="M"
						_cAcondic := "CAR."
					ElseIf Left(SDB->DB_LOCALIZ,1)=="C"
						_cAcondic := "CAR."
					ElseIf Left(SDB->DB_LOCALIZ,1)=="T"
						_cAcondic := "RET."
					ElseIf Left(SDB->DB_LOCALIZ,1)=="L"
						_cAcondic := "BLIS"
					EndIf
				EndIf
				Aadd(xAcond, _cAcondic)

				DbSelectArea("SD2")
				SD2->(DbSkip())
			Enddo
			xDESP_FIN := IIf(xDESP_FIN < 0, 0, xDESP_FIN)
			Asort(xORDENA,,,{|X,Y| X<Y})            // Ordem Crescente Itens Ped. Vda
			DbSelectArea("SF4")
			SF4->(DbSetOrder(1))

			For A := 1 To Len(xTES)
				SF4->(DbSeek(xFilial("SF4") + xTES[A], .F.))
				Aadd(xNATUREZA , SF4->F4_TEXTO)  // Natureza da Operacao
			Next
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))

			xDESC_PRO	:= {}                    // Descricao do Produto
			xUNID_PRO	:= {}                   // Unidade do Produto
			xCOD_TRIB	:= {}                   // Codigo de Tributacao
			xMEN_TRIB	:= {}                   // Mensagens de Tributacao
			xISS		:= {}                   // Aliquota de ISS
			xTIPO_PRO	:= {}                   // Tipo do Produto
			xLUCRO		:= {}                   // Margem de Lucro p/ ICMS Solidario
			xTIPOPRO	:= {}
			xCLASSIF	:= {}
			For I := 1 To Len(xCOD_PRO)
				DbSelectArea("SB1")
				SB1->(DbSeek(xFilial("SB1") + xCOD_PRO[I], .F.))

				Aadd(xDESC_PRO, u_CortaDesc(SB1->B1_DESC))
				Aadd(xUNID_PRO, SB1->B1_UM)
				Aadd(xTIPOPRO, SB1->B1_TIPO)

				If Ascan(xMEN_TRIB, Substr(SC6->C6_CLASFIS, 1, 2)) == 0
					Aadd(xMEN_TRIB, Substr(SC6->C6_CLASFIS, 1, 2))
				Endif

				If Ascan(xCLASSIF, SB1->B1_POSIPI) == 0 .And. !Empty(SB1->B1_POSIPI)
					Aadd(xCLASSIF, SB1->B1_POSIPI)
				Endif

				Aadd(xISS     , SB1->B1_ALIQISS)
				Aadd(xTIPO_PRO, SB1->B1_TIPO)
				Aadd(xLUCRO   , SB1->B1_PICMRET)
			Next
			//
			xMensage1 := ""
			xMensage2 := ""
			xMensage3 := ""
			xMensage4 := ""
			xMensage5 := ""
			xMensage6 := ""
			//
			SX3->(DbSetOrder(1))     // Dicionario de Dados
			//
			lPLACA   := .F.          // Status de Existencia do Campo SC5->C5_PLACA
			lUFP     := .F.          // Status de Existencia do Campo SC5->C5_UFP
			lFRETMOT := .F.          // Status de Existencia do Campo SC5->C5_FRETMOT
			//
			DbSelectArea("SX3")
			SX3->(DbSeek("SC5", .F.))
			//
			While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SC5"
				//
				If Upper(Alltrim(SX3->X3_CAMPO)) == "C5_PLACA"
					lPLACA := .T.
				Endif
				//
				If Upper(Alltrim(SX3->X3_CAMPO)) == "C5_UFP"
					lUFP := .T.
				Endif
				//
				If Upper(Alltrim(SX3->X3_CAMPO)) == "C5_FRETMOT"
					lFRETMOT := .T.
				Endif
				//
				If lPLACA .And. lUFP .And. lFRETMOT
					Exit
				Endif
				//
				SX3->(DbSkip())
				//
			Enddo
			//
			DbSelectArea("SC5")
			SC5->(DbSetOrder(1))
			//
			xPED      := {}
			xC5_VEND1 := ""
			xCONDPAG  := ""
			xCOD_VEND := {}
			xTPFRETE  := ""
			xPLACA    := ""
			xESTPLA   := ""
			//
			For I := 1 To Len(xPED_VEND)
				//
				SC5->(DbSeek(xFilial("SC5") + xPED_VEND[I], .F.))
				//
				If Ascan(xPED,xPED_VEND[I]) == 0
					//
					SC5->(DbSeek(xFilial("SC5") + xPED_VEND[I], .F.))
					//
					xC5_VEND1   := SC5->C5_VEND1          // Codigo do Vendedor
					xC5_NUM     := SC5->C5_NUM            // Numero do Pedido
					xC5_EMISSAO := SC5->C5_EMISSAO        // Data de Emissao
					xTIPO_CLI   := SC5->C5_TIPOCLI        // Tipo de Cliente
					xCOD_MENS   := SC5->C5_MENPAD         // Codigo da Mensagem Padrao
					xMensage2   := SC5->C5_MENNOTA        // Mensagem da Nota Fiscal
					xTPFRETE    := SC5->C5_TPFRETE        // Tipo de Entrega
					xCONDPAG    := SC5->C5_CONDPAG        // Condicao de Pagamento
					xBANCO      := SC5->C5_BANCO          // Banco
					//xESPECIE    := SC5->C5_ESPECI1 + SC5->C5_ESPECI2 + SC5->C5_ESPECI3
					//xESPECIE    := Substr(xESPECIE, 1, 30)
					//xVOLUME     := SC5->C5_VOLUME1        // Volume de Embalagem
					//xPESOLIQUI  := SC5->C5_PESOL
					//xPESOBRUTO  := SC5->C5_PBRUTO
					xPLACA      := IIf(lPLACA  , SC5->C5_PLACA  , Space(8))
					xESTPLA     := IIf(lUFP    , SC5->C5_UFP    , Space(2))
					xFRETMOT    := IIf(lFRETMOT, SC5->C5_FRETMOT, SC5->C5_FRETAUT)
					xMARCA      := "     "                // Marca do Cliente
					//
					Aadd(xPED, xPED_VEND[I])
					//
					xCOD_VEND   := {SC5->C5_VEND1,;       // Codigo do Vendedor 1
					SC5->C5_VEND2,;        // Codigo do Vendedor 2
					SC5->C5_VEND3,;        // Codigo do Vendedor 3
					SC5->C5_VEND4,;        // Codigo do Vendedor 4
					SC5->C5_VEND5}         // Codigo do Vendedor 5
					xDESC_NF    := {SC5->C5_DESC1,;       // Desconto Global 1
					SC5->C5_DESC2,;        // Desconto Global 2
					SC5->C5_DESC3,;        // Desconto Global 3
					SC5->C5_DESC4}         // Desconto Global 4
					//
				Endif
				//
			Next
			//
			If !Empty(xC5_VEND1)
				DbSelectArea("SA3")                // Vendedor
				SA3->(DbSetOrder(1))
				SA3->(DbSeek(xFilial("SA3") + xC5_VEND1, .F.))
				//
				xNOMVEND1 := Substr(SA3->A3_NOME, 1, 30)
			Else
				xNOMVEND1 := ""
			EndIf
			//
			DbSelectArea("SE4")                // Condicao de Pagamento
			SE4->(DbSetOrder(1))
			SE4->(DbSeek(xFilial("SE4") + xCONDPAG, .F.))
			//
			xDESC_PAG := Substr(SE4->E4_COND, 1, 30)
			//
			DbSelectArea("SC6")
			SC6->(DbSetOrder(1))
			//
			If Len(xPED_VEND) > 0
				xPED_CLI  := {}                    // Numero de Pedido
				xPEDCLI   := ""
				xORDPRO   := ""
				xDESC_PRO := {}                    // Descricao do Produto
			EndIf
			//
			For I := 1 To Len(xPED_VEND)
				//
				SC6->(DbSeek(xFilial("SC6") + xPED_VEND[I] + xITEM_PED[I], .F.))
				//
				Aadd(xPED_CLI, SC6->C6_PEDCLI)
				//
				xPEDCLI := IIf(Empty(xPEDCLI), SC6->C6_PEDCLI, xPEDCLI)
				xORDPRO := IIf(Empty(xORDPRO), SC6->C6_NUMOP, xORDPRO)
				//
				If !Empty(SC6->C6_DESCRI)
					Aadd(xDESC_PRO, u_CortaDesc(SC6->C6_DESCRI))
				Else
					Aadd(xDESC_PRO, u_CortaDesc(Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_DESC")))
				EndIf
				Aadd(xVAL_DESC, SC6->C6_VALDESC)
				Aadd(xCOD_TRIB, Substr(SC6->C6_CLASFIS, 1, 2))
				//
			Next
			//
			If xTIPO == 'N' .Or. xTIPO == 'C' .Or. xTIPO == 'P' .Or. xTIPO == 'I' .OR. xTIPO == 'S' .Or. xTIPO == 'T' .Or. xTIPO == 'O'
				//
				DbSelectArea("SA1")
				SA1->(DbSetOrder(1))
				SA1->(DbSeek(xFilial("SA1") + xCLIENTE + xLOJA, .F.))
				//
				xCOD_CLI  := SA1->A1_COD             // Codigo do Cliente
				xNOME_CLI := SA1->A1_NOME            // Nome
				xNREDUZ   := SA1->A1_NREDUZ          // Nome Reduzido ou Fantasia
				xEND_CLI  := SA1->A1_END             // Endereco
				xBAIRRO   := SA1->A1_BAIRRO          // Bairro
				xCEP_CLI  := SA1->A1_CEP             // CEP
				xCOB_CLI  := SA1->A1_ENDCOB          // Endereco de Cobranca
				xREC_CLI  := SA1->A1_ENDENT          // Endereco de Entrega
				xMUN_CLI  := SA1->A1_MUN             // Municipio
				xEST_CLI  := SA1->A1_EST             // Estado
				xCGC_CLI  := SA1->A1_CGC             // CGC
				xINSC_CLI := SA1->A1_INSCR           // Inscricao estadual
				xTRAN_CLI := SA1->A1_TRANSP          // Transportadora
				xTEL_CLI  := "(" + SA1->A1_DDD + ") " + SA1->A1_TEL             // Telefone
				xFAX_CLI  := SA1->A1_FAX             // Fax
				xSUFRAMA  := SA1->A1_SUFRAMA         // Codigo Suframa
				xCALCSUF  := SA1->A1_CALCSUF         // Calcula Suframa
				xENDCOB   := SA1->A1_ENDCOB          // Endereco de Cobranca
				xMUNCOB   := SA1->A1_MUNC            // Municipio de Cobranca
				xBAICOB   := SA1->A1_BAIRROC         // Bairro de Cobranca
				xESTCOB   := SA1->A1_ESTC            // Estado de Cobranca
				xCEPCOB   := SA1->A1_CEPC            // CEP de Cobranca
				xENDENT   := SA1->A1_ENDENT          // Endereco de Entrega
				xMUNENT   := SA1->A1_MUNE            // Municipio de Entrega
				xBAIENT   := SA1->A1_BAIRROE         // Bairro de Entrega
				xESTENT   := SA1->A1_ESTE            // Estado de Entrega
				xCEPENT   := SA1->A1_CEPE            // CEP de Entrega
				//
				If !Empty(xSUFRAMA) .And. xCALCSUF == "S"
					//
					If xTIPO == 'D' .Or. xTIPO == 'B'
						zFranca := .F.
					Else
						zFranca := .T.
					Endif
					//
				Else
					zFranca := .F.
				Endif
				//
			Else
				//
				zFranca := .F.
				//
				DbSelectArea("SA2")
				SA2->(DbSetOrder(1))
				SA2->(DbSeek(xFilial("SA2") + xCLIENTE + xLOJA, .F.))
				//
				xCOD_CLI := SA2->A2_COD              // Codigo do Fornecedor
				xNOME_CLI:= SA2->A2_NOME             // Nome Fornecedor
				xNREDUZ  := SA2->A2_NREDUZ           // Nome Reduzido ou Fantasia
				xEND_CLI := SA2->A2_END              // Endereco
				xBAIRRO  := SA2->A2_BAIRRO           // Bairro
				xCEP_CLI := SA2->A2_CEP              // CEP
				xCOB_CLI := ""                       // Endereco de Cobranca
				xREC_CLI := ""                       // Endereco de Entrega
				xMUN_CLI := SA2->A2_MUN              // Municipio
				xEST_CLI := SA2->A2_EST              // Estado
				xCGC_CLI := SA2->A2_CGC              // CGC
				xINSC_CLI:= SA2->A2_INSCR            // Inscricao estadual
				xTRAN_CLI:= SA2->A2_TRANSP           // Transportadora
				xTEL_CLI := "(" + SA2->A2_DDD + ") " + SA2->A2_TEL              // Telefone
				xFAX_CLI := SA2->A2_FAX              // Fax
				xENDCOB  := ""                       // Endereco de Cobranca
				xMUNCOB  := ""                       // Municipio de Cobranca
				xBAICOB  := ""                       // Bairro de Cobranca
				xESTCOB  := ""                       // Estado de Cobranca
				xCEPCOB  := ""                       // CEP de Cobranca
				xENDENT  := ""                       // Endereco de Entrega
				xMUNENT  := ""                       // Municipio de Entrega
				xBAIENT  := ""                       // Bairro de Entrega
				xESTENT  := ""                       // Estado de Entrega
				xCEPENT  := ""                       // CEP de Entrega
				//
			Endif
			//
			DbSelectArea("SA3")
			SA3->(DbSetOrder(1))
			//
			xVENDEDOR := {}                         // Nome do Vendedor
			//
			For I := 1 To Len(xCOD_VEND)
				//
				SA3->(DbSeek(xFilial("SA3") + xCOD_VEND[I], .F.))
				//
				If Type("SA3->A3_CONTAT") == "C"
					Aadd(xVENDEDOR, SA3->A3_CONTAT)
				Else
					Aadd(xVENDEDOR, SA3->A3_NREDUZ)
				EndIf
				//
			Next
			//
			//		If xICMS_RET > 0                        // Apenas se ICMS Retido > 0
			//			//
			//			DbSelectArea("SF3")
			//			SF3->(DbSetOrder(4))
			//			SF3->(DbSeek(xFilial("SF3") + SA1->A1_COD + SA1->A1_LOJA + SF2->F2_DOC + SF2->F2_SERIE, .F.))
			//			//
			//			If SF3->(Found())
			//				xBSICMRET := SF3->F3_VALOBSE
			//			Else
			//				xBSICMRET := 0
			//			Endif
			//			//
			//		Else
			//			xBSICMRET := 0
			//		Endif
			//
			DbSelectArea("SA4")
			SA4->(DbSetOrder(1))
			SA4->(DbSeek(xFilial("SA4") + SF2->F2_TRANSP, .F.))
			//
			xNOME_TRANSP := SA4->A4_NOME       // Nome Transportadora
			xEND_TRANSP  := SA4->A4_END        // Endereco da Transportadora
			xMUN_TRANSP  := SA4->A4_MUN        // Municipio
			xEST_TRANSP  := SA4->A4_EST        // Estado
			xVIA_TRANSP  := SA4->A4_VIA        // Via de Transporte
			xCGC_TRANSP  := SA4->A4_CGC        // CGC
			xTEL_TRANSP  := SA4->A4_TEL        // Fone
			xINSC_TRANSP := SA4->A4_INSEST     // Insc. Estadual
			//
			DbSelectArea("SE1")
			SE1->(DbSetOrder(1))
			//
			xPARC_DUP   := {}                  // Parcela
			xVENC_DUP   := {}                  // Vencimento
			xVALOR_DUP  := {}                  // Valor
			xDUPLICATAS := IIf(DbSeek(xFilial("SE1") + xSERIE + xNUM_DUPLIC, .T.),.T.,.F.) // Flag p/Impressao de Duplicatas
			//
			xPORTADOR := " "
			xCOB_CLI  := " "                   // Endereco de Cobranca
			//
			If xDUPLICATAS
				//
				DbSelectArea("SA6")
				SA6->(DbSetOrder(1))
				SA6->(DbSeek(xFilial("SA6") + xBANCO, .F.))
				//
				xPORTADOR := Trim(xBANCO) + " - " + Left(SA6->A6_NOME, 27)
				//
			Endif
			//
			DbSelectArea("SE1")
			//
			Do While SE1->E1_FILIAL = xFilial("SE1") .And. SE1->E1_NUM == xNUM_DUPLIC .And. xDUPLICATAS .And.;
			SE1->E1_PREFIXO == xSERIE .And. SE1->(!Eof())
				//
				If SE1->E1_ORIGEM == "MATA460 "
					Aadd(xPARC_DUP , SE1->E1_PARCELA)
					Aadd(xVENC_DUP , SE1->E1_VENCTO)
					Aadd(xVALOR_DUP, SE1->E1_VALOR)
				EndIf
				//
				SE1->(DbSkip())
				//
			Enddo
			//
			ImpDetalhe()                  // Impressao da NF
			//
			IncRegua()
			//
			DbSelectArea("SF2")
			Reclock("SF2",.F.)
			SF2->F2_FIMP := "S"
			MsUnLock()
			//
			SF2->(DbSkip())               // Passa para a Proxima Nota Fiscal
			//
		Enddo
		//
	Else                                   // Entradas
		//
		DbSelectArea("SF1")
		//
		Do While SF1->F1_FILIAL == xFilial("SF1") .And. SF1->(!Eof()) .And. SF1->F1_DOC <= Mv_Par02 .And. lContinua
			//
			If SF1->F1_SERIE # Mv_Par03 .Or. SF1->F1_FORMUL # "S"
				//
				SF1->(DbSkip())
				Loop
				//
			Endif
			//
			If lAbortPrint
				//
				lContinua := .F.
				Exit
				//
			Endif
			//
			nLinIni := nLin                    // Linha Inicial da Impressao
			//
			xDESCZFR    := 0                   // Desconto ZONA FRANCA
			xNUM_NF     := SF1->F1_DOC         // Numero
			xDESPESA    := SF1->F1_DESPESA     // Despesa
			xC5_VEND1   := ""                  // Vendedor
			xNOMVEND1   := ""                  // Nome do Vendedor
			xC5_NUM     := ""                  // Numero do Pedido
			xC5_EMISSAO := ""                  // Data de Emissao
			xPEDCLI     := ""                  // Nro Pedido
			xORDPRO     := ""
			xPLACA      := " "                 // Placa do Veiculo
			xESTPLA     := " "                 // Estado do Veiculo
			xFRETMOT    := 0                   // Frete do Motorista
			xMARCA      := " "                 // Marca do Cliente
			xSERIE      := SF1->F1_SERIE       // Serie
			xFORNECE    := SF1->F1_FORNECE     // Cliente/Fornecedor
			xEMISSAO    := SF1->F1_EMISSAO     // Data de Emissao
			xTOT_FAT    := SF1->F1_VALBRUT     // Valor Bruto da Compra
			xLOJA       := SF1->F1_LOJA        // Loja do Cliente
			xFRETE      := SF1->F1_FRETE       // Frete
			xSEGURO     := 0                   // Seguro
			xBASE_ICMS  := SF1->F1_BASEICM     // Base do ICMS
			xBASE_IPI   := SF1->F1_BASEIPI     // Base do IPI
			xBSICMRET   := SF1->F1_BRICMS      // Base do ICMS Retido
			xVALOR_ICMS := SF1->F1_VALICM      // Valor do ICMS
			xICMS_RET   := SF1->F1_ICMSRET     // Valor do ICMS Retido
			xVALOR_IPI  := SF1->F1_VALIPI      // Valor do IPI
			xVALOR_MERC := SF1->F1_VALMERC     // Valor da Mercadoria
			xNUM_DUPLIC := SF1->F1_DUPL        // Numero da Duplicata
			xCOND_PAG   := SF1->F1_COND        // Condicao de Pagamento
			xTIPO       := SF1->F1_TIPO        // Tipo do Cliente
			xNFORI      := ""                  // SF1->F1_NFORI       // NF Original
			xPREF_DV    := ""                  // SF1->F1_SERIORI     // Serie Original
			xPESOLIQUI  := xPesoCS := xPesoBt := SF1->F1_PESOL       // Peso Liquido
			xPESOBRUTO  := SF1->F1_PESOL       // Peso Bruto
			xDESCONT    := 0                   // Desconto da Nota Fiscal
			wVALISS     := 0                   // Valor do ISS
			wTOTSER     := 0                   // Total dos Servicos
			wTOTPRO     := 0                   // Total dos Produtos
			//
			xMensage1 := ""
			xMensage2 := ""
			xMensage3 := ""
			xMensage4 := ""
			xMensage5 := ""
			xMensage6 := ""
			//
			DbSelectArea("SD1")
			SD1->(DbSetOrder(1))
			SD1->(DbSeek(xFilial("SD1") + xNUM_NF + xSERIE + xFORNECE + xLOJA, .F.))
			//
			cPedAtu   := SD1->D1_PEDIDO
			cItemAtu  := SD1->D1_ITEMPC
			xPEDIDO   := ""                    // Numero do Pedido de Compra do cliente
			xITEM_PED := {}                    // Numero do Item do Pedido de Compra
			xNUM_NFDV := {}                    // Numero NF Qdo Houver Devolucao
			xPREF_DV  := {}                    // Serie Qdo Houver Devolucao
			xITEM_DV  := {}                    // Item Qdo Houver Devolucao
			xDATA_DV  := {}                    // Data Qdo Houver Devolucao
			xQTD_DV   := {}                    // Quantidade Qdo Houver Devolucao
			xVAL_DV   := {}                    // Valor Qdo Houver Devolucao
			xICMS     := {}                    // Porcentagem do ICMS
			xCOD_PRO  := {}                    // Codigo  do Produto
			xQTD_PRO  := {}                    // Peso/Quantidade do Produto
			xPRE_UNI  := {}                    // Preco Unitario de Compra
			xIPI      := {}                    // Porcentagem do IPI
			xVAL_IPI  := {}                    // Valor do IPI
			xDESC     := {}                    // Desconto por Item
			xVAL_DESC := {}                    // Valor do Desconto
			xVAL_MERC := {}                    // Valor da Mercadoria
			xTES      := {}                    // TES
			xCF       := {}                    // Classificacao quanto natureza da Operacao
			xNATUREZA := {}                    // NATUREZA OPERACAO
			xICMSOL   := {}                    // Base do ICMS Solidario
			xICM_PROD := {}                    // ICMS do Produto
			xICMS     := {}
			xICMSITE  := {}
			xAcond    := {}				       // Acondicionamento
			xDESP_FIN := 0                     // Total das Despesas Financeiras
			//
			Do While SD1->D1_FILIAL == xFilial("SD") .And. SD1->(!Eof()) .And. SD1->D1_DOC == xNUM_NF
				//
				If SD1->D1_SERIE # Mv_Par03
					//
					SD1->(DbSkip())
					Loop
					//
				Endif
				//
				Aadd(xITEM_PED, SD1->D1_ITEMPC)        // Item da O.C.
				Aadd(xNUM_NFDV, SD1->D1_NFORI)         // Nf Original
				Aadd(xPREF_DV , SD1->D1_SERIORI)       // Serie Original
				Aadd(xITEM_DV , SD1->D1_ITEMORI)       // Item Original
				Aadd(xDATA_DV , SD1->D1_EMISSAO)       // Data Original
				Aadd(xQTD_DV  , SD1->D1_QTDEDEV)
				Aadd(xVAL_DV  , SD1->D1_VALDEV)
				Aadd(xICMS    , IIf(Empty(SD1->D1_PICM), 0, SD1->D1_PICM))
				Aadd(xCOD_PRO , SD1->D1_COD)           // Produto
				Aadd(xQTD_PRO , SD1->D1_QUANT)         // Guarda as quant. da NF
				Aadd(xPRE_UNI , SD1->D1_VUNIT)         // Valor Unitario
				Aadd(xIPI     , SD1->D1_IPI)           // % IPI
				Aadd(xVAL_IPI , SD1->D1_VALIPI)        // Valor do IPI
				Aadd(xDESC    , SD1->D1_DESC)          // % Desconto
				Aadd(xVAL_MERC, SD1->D1_TOTAL)         // Valor Total
				Aadd(xICMSITE , 0)
				Aadd(xCF  , SD1->D1_CF)
				If SD1->D1_COD == "2010000001     " .And. SF1->F1_TIPO == "N" .And. SF1->F1_FORMUL== "S"
					xMensage1 := "Art.392 Paragrafo I Inc.III do RICMS/00"
				EndIf
				//
				//If Ascan(xCF, SD1->D1_CF) == 0
				Aadd(xTES , SD1->D1_TES)           // Tipo de Entrada/Saida
				//Endif
				//
				Aadd(xICM_PROD, IIf(Empty(SD1->D1_PICM), 0, SD1->D1_PICM))
				Aadd(xAcond, "    ")

				//
				DbSelectArea("SD1")
				SD1->(DbSkip())
				//
			Enddo
			//
			DbSelectArea("SF4")
			SF4->(DbSetOrder(1))
			//
			For A := 1 To Len(xTES)
				//
				SF4->(DbSeek(xFilial("SF4") + xTES[A], .F.))
				//
				//			If Ascan(xNATUREZA, SF4->F4_TEXTO) == 0
				Aadd(xNATUREZA , SF4->F4_TEXTO)       // Natureza da Operacao
				//			Endif
				//
			Next
			//
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1))
			//
			xUNID_PRO  := {}                   // Unidade do Produto
			xDESC_PRO  := {}                   // Descricao do Produto
			xCOD_TRIB  := {}                   // Codigo de Tributacao
			xMEN_TRIB  := {}                   // Mensagens de Tributacao
			xISS       := {}                   // Aliquota de ISS
			xTIPO_PRO  := {}                   // Tipo do Produto
			xLUCRO     := {}                   // Margem de Lucro p/ ICMS Solidario
			xTIPOPRO   := {}
			xSUFRAMA   := ""
			xCALCSUF   := ""
			xCLASSIF   := {}
			//
			For I := 1 To Len(xCOD_PRO)
				//
				DbSelectArea("SB1")
				SB1->(DbSeek(xFilial("SB1") + xCOD_PRO[I], .F.))
				//
				Aadd(xDESC_PRO, u_CortaDesc(SB1->B1_DESC))
				Aadd(xTIPOPRO , SB1->B1_TIPO)
				Aadd(xUNID_PRO, SB1->B1_UM)
				Aadd(xCOD_TRIB, SB1->B1_ORIGEM)
				//
				If Ascan(xMEN_TRIB, SB1->B1_ORIGEM) == 0
					Aadd(xMEN_TRIB , SB1->B1_ORIGEM)
				Endif
				//
				If Ascan(xCLASSIF, SB1->B1_POSIPI) == 0 .And. !Empty(SB1->B1_POSIPI)
					Aadd(xCLASSIF, SB1->B1_POSIPI)
				Endif
				//
				Aadd(xISS     , SB1->B1_ALIQISS)
				Aadd(xTIPO_PRO, SB1->B1_TIPO)
				Aadd(xLUCRO   , SB1->B1_PICMRET)
				//
			Next
			//
			DbSelectArea("SE4")
			SE4->(DbSetOrder(1))
			SE4->(DbSeek(xFilial("SE4") + xCOND_PAG, .F.))
			//
			xDESC_PAG := Substr(SE4->E4_COND, 1, 30)
			//
			If xTIPO == "D" .Or. xTIPO == "B"
				//
				DbSelectArea("SA1")
				SA1->(DbSetOrder(1))
				SA1->(DbSeek(xFilial("SA1") + xFORNECE, .F.))
				//
				xCOD_CLI  := SA1->A1_COD             // Codigo do Cliente
				xNOME_CLI := SA1->A1_NOME            // Nome
				xNREDUZ   := SA1->A1_NREDUZ          // Nome Reduzido ou Fantasia
				xEND_CLI  := SA1->A1_END             // Endereco
				xBAIRRO   := SA1->A1_BAIRRO          // Bairro
				xCEP_CLI  := SA1->A1_CEP             // CEP
				xCOB_CLI  := SA1->A1_ENDCOB          // Endereco de Cobranca
				xREC_CLI  := SA1->A1_ENDENT          // Endereco de Entrega
				xMUN_CLI  := SA1->A1_MUN             // Municipio
				xEST_CLI  := SA1->A1_EST             // Estado
				xCGC_CLI  := SA1->A1_CGC             // CGC
				xINSC_CLI := SA1->A1_INSCR           // Inscricao estadual
				xTRAN_CLI := SA1->A1_TRANSP          // Transportadora
				xTEL_CLI  := "(" + SA1->A1_DDD + ") " + SA1->A1_TEL             // Telefone
				xFAX_CLI  := SA1->A1_FAX             // Fax
				xENDCOB   := SA1->A1_ENDCOB          // Endereco de Cobranca
				xMUNCOB   := SA1->A1_MUNC            // Municipio de Cobranca
				xBAICOB   := SA1->A1_BAIRROC         // Bairro de Cobranca
				xESTCOB   := SA1->A1_ESTC            // Estado de Cobranca
				xCEPCOB   := SA1->A1_CEPC            // CEP de Cobranca
				xENDENT   := SA1->A1_ENDENT          // Endereco de Entrega
				xMUNENT   := SA1->A1_MUNE            // Municipio de Entrega
				xBAIENT   := SA1->A1_BAIRROE         // Bairro de Entrega
				xESTENT   := SA1->A1_ESTE            // Estado de Entrega
				xCEPENT   := SA1->A1_CEPE            // CEP de Entrega
				//
			Else
				//
				DbSelectArea("SA2")
				SA2->(DbSetOrder(1))
				SA2->(DbSeek(xFilial("SA2") + xFORNECE + xLOJA, .F.))
				//
				xCOD_CLI  := SA2->A2_COD             // Codigo do Cliente
				xNOME_CLI := SA2->A2_NOME            // Nome
				xNREDUZ   := SA2->A2_NREDUZ          // Nome Reduzido ou Fantasia
				xEND_CLI  := SA2->A2_END             // Endereco
				xBAIRRO   := SA2->A2_BAIRRO          // Bairro
				xCEP_CLI  := SA2->A2_CEP             // CEP
				xCOB_CLI  := ""                      // Endereco de Cobranca
				xREC_CLI  := ""                      // Endereco de Entrega
				xMUN_CLI  := SA2->A2_MUN             // Municipio
				xEST_CLI  := SA2->A2_EST             // Estado
				xCGC_CLI  := SA2->A2_CGC             // CGC
				xINSC_CLI := SA2->A2_INSCR           // Inscricao estadual
				xTRAN_CLI := SA2->A2_TRANSP          // Transportadora
				xTEL_CLI  := "(" + SA2->A2_DDD + ") " + SA2->A2_TEL             // Telefone
				xFAX_CLI  := SA2->A2_FAX             // Fax
				xENDCOB   := ""                      // Endereco de Cobranca
				xMUNCOB   := ""                      // Municipio de Cobranca
				xBAICOB   := ""                      // Bairro de Cobranca
				xESTCOB   := ""                      // Estado de Cobranca
				xCEPCOB   := ""                      // CEP de Cobranca
				xENDENT   := ""                      // Endereco de Entrega
				xMUNENT   := ""                      // Municipio de Entrega
				xBAIENT   := ""                      // Bairro de Entrega
				xESTENT   := ""                      // Estado de Entrega
				xCEPENT   := ""                      // CEP de Entrega
				//
			Endif
			//
			DbSelectArea("SE1")
			SE1->(DbSetOrder(1))
			//
			xPARC_DUP   := {}                       // Parcela
			xVENC_DUP   := {}                       // Vencimento
			xVALOR_DUP  := {}                       // Valor
			xDUPLICATAS := IIf(DbSeek(xFilial("SE1") + xSERIE + xNUM_DUPLIC, .T.), .T., .F.)  // Flag p/ Impressao de Duplicatas
			//
			Do While SE1->E1_FILIAL == xFilial("SE1") .And. SE1->(!Eof()) .And. SE1->E1_NUM == xNUM_DUPLIC .And. xDUPLICATAS .And.SE1->E1_PREFIXO == xSERIE
				If SE1->E1_ORIGEM # "MATA460 "
					//
					Aadd(xPARC_DUP , SE1->E1_PARCELA)
					Aadd(xVENC_DUP , SE1->E1_VENCTO)
					Aadd(xVALOR_DUP, SE1->E1_VALOR)
					//
				EndIf
				SE1->(DbSkip())
				//
			Enddo
			//
			xNOME_TRANSP := " "           // Nome Transportadora
			xEND_TRANSP  := " "           // Endereco
			xMUN_TRANSP  := " "           // Municipio
			xEST_TRANSP  := " "           // Estado
			xVIA_TRANSP  := " "           // Via de Transporte
			xCGC_TRANSP  := " "           // CGC
			xINSC_TRANSP := " "           // Inscr. Estad.
			xTEL_TRANSP  := " "           // Fone
			xTPFRETE     := " "           // Tipo de Frete
			xVOLUME      := 0             // Volume
			xESPECIE     := " "           // Especie
			xCOD_MENS    := " "           // Codigo da Mensagem
			//
			ImpDetalhe()                  // Impressao da NF
			//
			IncRegua()
			//
			DbSelectArea("SF1")
			SF1->(DbSkip())
			//
		Enddo
		//
	Endif
	//
	DbSelectArea("SF2")
	Retindex("SF2")
	DbSelectArea("SF1")
	Retindex("SF1")
	DbSelectArea("SD2")
	Retindex("SD2")
	DbSelectArea("SD1")
	Retindex("SD1")
	//
Return (.T.)

////////////////////////////
Static Function ImpDetalhe()
	////////////////////////////
	//
	nTamDet    := 32 //GetMv("MV_NUMITEN") // 32                  // Tamanho da Area de Impressao p/ os Detalhes
	nItensProd := 0                   // Nro de Itens da NF Referente a Produtos
	//
	For I := 1 To Len(xCOD_PRO)       // Contagem dos Itens da NF             '
		nItensProd += 1
	Next
	//
	If nItensProd > nTamDet
		//
		//	MsgBox("O Numero de Itens Ultrapassa o Maximo de 32 !!!", "Atencao c/ a Area de Impressao !!!", "INFO")
		//	Return (.T.)
		//
	Endif
	//
	xCLASFIS := {}                    // Letra da Classificacao Fiscal
	xPOSIPI  := {}                    // Classificacao Fiscal ou Posicao do IPI
	//
	nLin := 0
	//
	ImpCabec()                        // Impressao do Cabecalho da NF
	//
	If Mv_Par04 == 2                       // Saidas
		If xVlrMetal > 0.00
			// Fazer a distribuição desse valor  nos itens
			// Primeiro somar os valores totais
			_nTotNta := 0.00
			For I := 1 To nTamDet
				//
				If I <= Len(xCOD_PRO)
					_nTotNta += xVAL_MERC[I]
				EndIf
			Next

			// Depois Distribuo proporcionalmente
			_nSomait := 0.00
			_nUltIt  := 0
			For I := 1 To nTamDet
				If I <= Len(xCOD_PRO)
					_nIndice := (xVAL_MERC[I] / _nTotNta)
					xVAL_MERC[I] := NoRound((_nTotNta+xVlrMetal) * _nIndice,2)
					xPRE_UNI[I] :=  NoRound(xVAL_MERC[I] / xQTD_PRO[I],4)
					_nSomait += xVAL_MERC[I]
					_nUltIt := I
				EndIf
			Next
			If _nSomait # (_nTotNta+xVlrMetal)
				xVAL_MERC[_nUltIt] +=  (_nTotNta+xVlrMetal) - _nSomait
				xPRE_UNI[_nUltIt] :=  NoRound(xVAL_MERC[_nUltIt] / xQTD_PRO[_nUltIt],4)
			EndIf
		EndIf
	EndIf
	//nLin := 25
	nLin := 22
	_lClasB := .F.
	//
	For I := 1 To nTamDet
		//
		If I <= Len(xCOD_PRO)
			//
			SB1->(DbSeek(xFilial("SB1") + xCOD_PRO[I], .F.))
			//
			SF4->(DbSeek(xFilial("SF4") + xTES[I], .F.))
			//
			@ nLin, 001 Psay Transform(Substr(xCOD_PRO[I], 1, 11), "@R XXX.XX.XX.X.XX")
			@ nLin, 017 Psay Substr(xDESC_PRO[I], 1, 39)
			@ nLin, 056 Psay xAcond[I]
			//
			If SB1->B1_CLASFIS == "A " //.And. xNUM_NF <= "059000"
				@ nLin, 064 Psay SB1->B1_CLASFIS
			Else
				_lClasB := .T.
				@ nLin, 064 Psay "B"
			EndIf

			@ nLin, 068 Psay Alltrim(SB1->B1_ORIGEM) + SF4->F4_SITTRIB
			@ nLin, 073 Psay If(xAcond[I]$"Rl.50mt//Rl.15mt","Un",SB1->B1_UM)
			If xQTD_PRO[I]-Int(xQTD_PRO[I]) == 0.00
				@ nLin, 078 Psay If(xAcond[I]=="Rl.50mt",(xQTD_PRO[I]/50),If(xAcond[I]=="Rl.15mt",(xQTD_PRO[I]/15),xQTD_PRO[I])) Picture "@E 9999,999"
			Else
				@ nLin, 078 Psay If(xAcond[I]=="Rl.50mt",xQTD_PRO[I]/50,If(xAcond[I]=="Rl.15mt",xQTD_PRO[I]/15,xQTD_PRO[I])) Picture "@E 99999.99"
			EndIf
			If xTIPO == "I"
				//
				@ nLin, 087 Psay 0            Picture "@E 9999999.9999"
				@ nLin, 103 Psay 0            Picture "@E 999,999,999.99"
				@ nLin, 118 Psay xICM_PROD[I] Picture "@EZ 99.9"
				@ nLin, 123 Psay 0            Picture "@EZ 99.9"
				@ nLin, 127 Psay 0            Picture "@EZ 99,999.99"
				//
			Else
				//
				@ nLin, 087 Psay If(xAcond[I]=="Rl.50mt",xPRE_UNI[I]*50,If(xAcond[I]=="Rl.15mt",xPRE_UNI[I]*15,xPRE_UNI[I]))  Picture "@E 999999.9999"
				@ nLin, 103 Psay xVAL_MERC[I] Picture "@E 99,999,999.99"
				@ nLin, 118 Psay xICM_PROD[I] Picture "@EZ 99.9"
				@ nLin, 123 Psay xIPI[I]      Picture "@EZ 99.9"
				@ nLin, 127 Psay xVAL_IPI[I]  Picture "@EZ 99,999.99"
				//
			Endif
			//
			nLin := nLin + 1
			//
			wTOTPRO := wTOTPRO + xVAL_MERC[I]
			//
			If !(Upper(Alltrim(SB1->B1_CLASFIS)) $ "A,") .And.;
			!Empty(SB1->B1_CLASFIS) .And. !Empty(SB1->B1_POSIPI)
				//
				If Ascan(xCLASFIS, SB1->B1_CLASFIS) == 0
					//
					Aadd(xCLASFIS, SB1->B1_CLASFIS)
					Aadd(xPOSIPI , SB1->B1_POSIPI)
					//
				Endif
				//
			Endif
			//
		Endif
		//
	Next
	//
	If Mv_Par04 == 2                       // Saidas
		If xVlrMetal > 0.00
			@ 051, 001 Psay "Desconto R$ " + Transform(xVlrMetal,"@E 99,999.99")
		EndIf
	EndIf
	If xICMS_RET # 0.00
		@ 052, 001 Psay "O destinatario devera, com relacao as operacoes com mercadoria ou prest. de servico recebidas com imposto retido, escriturar o"
		@ 053, 001 Psay "documento fiscal nos termos do art. 278 do RICMS // Substituicao Tributaria conf. art. 313-Y do RICMS"
	EndIf

	nLin := 56
	//
	ImpRodape()                       // Impressao do Rodape da NF
	//
Return (.T.)

//////////////////////////
Static Function ImpCabec()
	//////////////////////////
	//
	SetPrc(0,0)
	//
	@ nLin, 000 Psay xConfig               // Impressao em 1/8 e Comprimido
	//nLin := nLin + 1
	//
	@ nLin, 125 Psay xNUM_NF
	nLin := nLin + 2
	//
	If Mv_Par04 == 1                       // NF de Entrada
		@ nLin, 097 Psay "X"
	Else                                   // NF de Saida
		@ nLin, 086 Psay "X"
	Endif
	//
	If Mv_Par04 == 2 // NF de Saída
		xMensage1 := Space(110)
		//
		If !Empty(xCOD_MENS)
			//
			DbSelectArea("SM4")
			SM4->(DbSetOrder(1))
			//
			xMensage1 := Substr(Formula(xCOD_MENS), 1, 110)
			//
		Endif
	Endif
	//
	xNATOP := {}
	//
	For A := 1 To Len(xCF)
		//
		If Ascan(xNATOP, xCF[A] + xNATUREZA[A]) == 0
			Aadd(xNATOP , xCF[A] + xNATUREZA[A])
		Endif
		//
	Next
	//
	Asort(xNATOP,,,{|X,Y| X<Y})       // Coloca em Ordem Crescente CFO
	//
	xTEXCFO := ""                     // Texto da Natureza da Operacao
	xCODCFO := ""                     // Codigo Fiscal da Operacao
	//
	For A := 1 To Len(xNATOP)
		//
		xBARRA  := IIf(A == 1, "", "/")
		xCODCFO := xCODCFO + xBARRA + Transform(Alltrim(Substr(xNATOP[A], 1, 4)), "@R 9.999")
		xTEXCFO := xTEXCFO + xBARRA + Alltrim(Substr(xNATOP[A], 5, IIf(A == 1, 20, 13)))
		//
		If A >= 2
			Exit
		Endif
		//
	Next
	//
	nLin := nLin + 5
	@ nLin, 001 Psay Substr(xTEXCFO, 1, 34)
	@ nLin, 039 Psay xCODCFO
	nLin := nLin + 3
	@ nLin, 001 Psay Substr(xNOME_CLI, 1, 40) + "     (" + xCOD_CLI + ")"  // Nome do Cliente e Codigo
	//
	If !Empty(xCGC_CLI)                         // C.G.C. ou C.P.F.
		//
		If Len(Alltrim(xCGC_CLI)) == 11
			@ nLin, 088 Psay xCGC_CLI Picture "@R 999.999.999-99"          // C.P.F.
		Else
			@ nLin, 088 Psay xCGC_CLI Picture "@R 99.999.999/9999-99"      // C.G.C.
		Endif
		//
	Else
		@ nLin, 088 Psay " "
	Endif
	//
	@ nLin, 122 Psay Substr(Dtoc(xEMISSAO), 1, 6) + Strzero(Year(xEMISSAO), 4)  // Data da Emissao do Documento
	//
	nLin := nLin + 2
	@ nLin, 001 Psay xEND_CLI                   // Endereco
	@ nLin, 070 Psay Substr(xBAIRRO, 1, 20)     // Bairro
	@ nLin, 102 Psay Transform(xCEP_CLI, "@R 99999-999")
	@ nLin, 122 Psay " "                        // dDataBase (Data da Saida)
	//
	nLin := nLin + 2
	@ nLin, 001 Psay xMUN_CLI                   // Municipio
	@ nLin, 057 Psay Substr(xTEL_CLI, 1, 20)    // Telefone/FAX
	@ nLin, 081 Psay xEST_CLI                   // U.F.
	@ nLin, 088 Psay Substr(xINSC_CLI, 1, 20)   // Inscricao Estadual
	@ nLin, 122 Psay " "                        // Time() (Hora da Saida)
	//
	xLinDup1 := ""                         // Duplicatas
	xLinDup2 := ""
	//
	If xDUPLICATAS == .T.
		//
		If Len(xPARC_DUP) > 0               // Parcela "A"
			xLinDup1 += xNUM_NF + Space(2) + Transform(xVALOR_DUP[1], "@E 999,999,999.99") + Space(5) + Substr(Dtoc(xVENC_DUP[1]), 1, 6) + Strzero(Year(xVENC_DUP[1]), 4) + Space(6)
		Endif
		//
		If Len(xPARC_DUP) > 1               // Parcela "B"
			xLinDup2 += xNUM_NF + Space(2) + Transform(xVALOR_DUP[2], "@E 999,999,999.99") + Space(5) + Substr(Dtoc(xVENC_DUP[2]), 1, 6) + Strzero(Year(xVENC_DUP[2]), 4) + Space(6)
		Endif
		//
		If Len(xPARC_DUP) > 2               // Parcela "C"
			xLinDup1 += xNUM_NF + Space(1) + Transform(xVALOR_DUP[3], "@E 999,999,999.99") + Space(6) + Substr(Dtoc(xVENC_DUP[3]), 1, 6) + Strzero(Year(xVENC_DUP[3]), 4) + Space(6)
		Endif
		//
		If Len(xPARC_DUP) > 3               // Parcela "D"
			xLinDup2 += xNUM_NF + Space(1) + Transform(xVALOR_DUP[4], "@E 999,999,999.99") + Space(6) + Substr(Dtoc(xVENC_DUP[4]), 1, 6) + Strzero(Year(xVENC_DUP[4]), 4) + Space(6)
		Endif
		//
		If Len(xPARC_DUP) > 4               // Parcela "E"
			xLinDup1 += xNUM_NF + Space(1) + Transform(xVALOR_DUP[5], "@E 999,999,999.99") + Space(6) + Substr(Dtoc(xVENC_DUP[5]), 1, 6) + Strzero(Year(xVENC_DUP[5]), 4)
		Endif
		//
		If Len(xPARC_DUP) > 5               // Parcela "F"
			xLinDup2 += xNUM_NF + Space(1) + Transform(xVALOR_DUP[6], "@E 999,999,999.99") + Space(6) + Substr(Dtoc(xVENC_DUP[6]), 1, 6) + Strzero(Year(xVENC_DUP[6]), 4)
		Endif
		//
	Endif
	//
	nLin := nLin + 3
	@ nLin, 003 Psay xLinDup1
	nLin := nLin + 1
	@ nLin, 003 Psay xLinDup2
	//
Return (.T.)

///////////////////////////
Static Function ImpRodape()
	///////////////////////////
	//
	If xTIPO == "I"
		//
		@ nLin, 006 Psay 0           Picture "@E 999,999,999.99"   // Base do ICMS
		@ nLin, 032 Psay xVALOR_ICMS Picture "@E 999,999,999.99"   // Valor do ICMS
		@ nLin, 059 Psay 0           Picture "@E 999,999,999.99"   // Base ICMS Ret.
		@ nLin, 086 Psay 0           Picture "@E 999,999,999.99"   // Valor ICMS Ret.
		@ nLin, 119 Psay 0           Picture "@E 999,999,999.99"   // Valor Tot. Prod.
		//
	Else
		//
		If xICMS_RET == 0.00
			@ nLin, 006 Psay xBASE_ICMS  Picture "@E 999,999,999.99"   // Base do ICMS
			@ nLin, 032 Psay xVALOR_ICMS Picture "@E 999,999,999.99"   // Valor do ICMS
			//	Else
			//		@ nLin, 006 Psay 0.00  Picture "@E 999,999,999.99"   // Base do ICMS
			//		@ nLin, 032 Psay 0.00  Picture "@E 999,999,999.99"   // Valor do ICMS
		EndIf
		@ nLin, 059 Psay xBSICMRET   Picture "@E 999,999,999.99"   // Base ICMS Ret.
		@ nLin, 086 Psay xICMS_RET   Picture "@E 999,999,999.99"   // Valor ICMS Ret.
		@ nLin, 119 Psay (xVALOR_MERC + xDESCZFR - wTOTSER) Picture "@E 999,999,999.99"  // Valor Tot. Prod.
		//
	Endif
	//
	nLin := nLin + 2
	@ nLin, 006 Psay xFRETE     Picture "@E 999,999,999.99"    // Valor do Frete
	@ nLin, 032 Psay xSEGURO    Picture "@E 999,999,999.99"    // Valor Seguro
	@ nLin, 059 Psay xDESPESA   Picture "@E 999,999,999.99"    // Desp. Acessorias
	@ nLin, 086 Psay xVALOR_IPI Picture "@E 999,999,999.99"    // Valor do IPI
	//
	If xTIPO # "I"
		@ nLin, 119 Psay xTOT_FAT Picture "@E 999,999,999.99"   // Valor Total NF
	Else
		@ nLin, 119 Psay 0        Picture "@E 999,999,999.99"   // Valor Total NF
	Endif
	//
	nLin := nLin + 3
	@ nLin, 001 Psay Substr(xNOME_TRANSP, 1, 40)     // Nome da Transport.
	//
	If xTPFRETE $ "C0"                                // Frete por Conta do
		@ nLin, 079 Psay "1"                          // Emitente (1)
	Elseif xTPFRETE $ "F1"                            //     ou
		@ nLin, 079 Psay "2"                          // Destinatario (2)
	Else
		@ nLin, 079 Psay " "
	Endif
	//
	@ nLin, 085 Psay Substr(xPLACA, 1, 8)            // Placa do Veiculo
	@ nLin, 098 Psay xESTPLA                         // U.F. do Veiculo
	//
	If !Empty(xCGC_TRANSP)
		@ nLin, 110 Psay xCGC_TRANSP Picture "@R 99.999.999/9999-99"
	Else
		@ nLin, 110 Psay " "
	Endif
	//
	nLin := nLin + 2
	@ nLin, 001 Psay Substr(xEND_TRANSP, 1, 40)      // Endereco Transp.
	@ nLin, 062 Psay xMUN_TRANSP                     // Municipio
	@ nLin, 098 Psay xEST_TRANSP                     // U.F.
	@ nLin, 110 Psay xINSC_TRANSP                    // Inscricao Estadual
	//
	nLin := nLin + 2
	@ nLin, 004 Psay xVOLUME    Picture "@EZ 999,999,999"       // Quantidade de Volumes
	@ nLin, 022 Psay xESPECIE                                   // Especie
	@ nLin, 044 Psay xMARCA                                     // Marca do Cliente
	@ nLin, 068 Psay xNUM_NF                                    // Numero
	If _lImpPeso
		@ nLin, 093 Psay xPesoBt    Picture "@REZ 9,999,999.999 Kg" // Peso Bruto Total
		@ nLin, 118 Psay xPesoCS    Picture "@REZ 9,999,999.999 Kg" // Peso Liquido Total
	EndIf
	//@ nLin, 093 Psay xPESOBRUTO Picture "@REZ 9,999,999.999 Kg" // Peso Bruto Total
	//@ nLin, 118 Psay xPESOLIQUI Picture "@REZ 9,999,999.999 Kg" // Peso Liquido Total
	nLin := nLin + 3
	//
	//If 	_lClasB // xNUM_NF <= "059000"
	//	@ nLin, 011 Psay "B-85.44.49.00"
	//EndIf

	nCol := 1
	//
	For x := 1 To Len(xCLASFIS)       // Classificacoes Fiscais Nao Especificadas
		//
		If nCol > 50
			//
			nCol := 1
			nLin := nLin + 1
			//
		Endif
		//
		@ nLin, nCol Psay Alltrim(xCLASFIS[x]) + "-" + Transform(xPOSIPI[x], "@R XX.XX.XX.XX")
		nCol := nCol + 17
		//
		If x >= 6
			Exit
		Endif
		//
	Next
	//
	If nCol > 1
		nLin := nLin + 1
	Endif
	//
	If xTIPO == "N"
		nLin := nLin + 1
		//	@ nLin,000 Psay "ISENCAO DO IPI CONFORME DECRETO 5697/2006"
		@ nLin,000 Psay "Aliquota zero de IPI conf. decreto 6.006/2006, seção XVI da TIPI"
	EndIf
	nLin := nLin + 1
	If xICMS_RET # 0.00
		@ nLin,000 Psay "ICMS.....: Base R$"
		@ nLin,019 Psay xBASE_ICMS  Picture "@E 9999,999.99"   // Base do ICMS
		@ nLin,032 Psay "Vlr.R$"
		@ nLin,039 Psay xVALOR_ICMS Picture "@E 9999,999.99"   // Valor do ICMS
		nLin := nLin + 1
		@ nLin,000 Psay "ICMS Ret.: Base R$"
		@ nLin,019 Psay xBSICMRET   Picture "@E 9999,999.99"   // Base ICMS Ret.
		@ nLin,032 Psay "Vlr.R$"
		@ nLin,039 Psay xICMS_RET   Picture "@E 9999,999.99"   // Valor ICMS Ret.
		nLin := nLin + 1
	EndIf
	If xTIPO == "N" .And. Mv_Par04 == 2 // NF de Saída
		_cPedv := xPED_VEND[1]
		For _nCt := 2 to Len(xPED_VEND)
			If !xPED_VEND[_nCt] $ _cPedv
				_cPedv += ", "+xPED_VEND[_nCt]
			EndIf
		Next
		@ nLin,000 Psay "Pedido(s): " + _cPedv
		If Len(AllTrim(XPEDIDO)) > 0
			@ ++nLin,000 Psay "O.C.: " + XPEDIDO
		EndIf
	EndIf
	nLin := nLin + 1
	If !Empty(Substr(xMensage1, 1, 55))
		//
		@ nLin, 001 Psay Substr(xMensage1, 1, 55)
		nLin := nLin + 1
		//
	Endif
	//
	If !Empty(Substr(xMensage1, 56, 55))
		//
		@ nLin, 001 Psay Substr(xMensage1, 56, 55)
		nLin := nLin + 1
		//
	Endif
	//
	If !Empty(Substr(xMensage2, 1, 55))
		//
		@ nLin, 001 Psay Substr(xMensage2, 1, 55)
		nLin := nLin + 1
		//
	Endif
	//
	If !Empty(Substr(xMensage2, 56, 55))
		//
		@ nLin, 001 Psay Substr(xMensage2, 56, 55)
		nLin := nLin + 1
		//
	Endif
	//
	If Mv_Par04 == 2 .And. xTIPO == "D"    // Saidas por Devolucao
		//
		For x := 1 To Len(xNUM_NFDV)
			//
			If !Empty(xNUM_NFDV)
				//
				xMensage3 += "DEV. S/ NF: " + xNUM_NFDV[x] + " ITEM: " + xITEM_DV[x] + " DE " + Dtoc(xDATA_DV[x]) +;
				IIf(xQTD_DV[x] > 0, " QTD: " + Alltrim(Transform(xQTD_DV[x], "@E 9,999,999")), "") +;
				IIf(xVAL_DV[x] > 0, " VLR: " + Alltrim(Transform(xVAL_DV[x], "@E 999,999,999.99")), "") + " / "
				//
			Endif
			//
		Next
		//
	Endif
	//
	If !Empty(Substr(xMensage3, 1, 55))
		//
		@ nLin, 001 Psay Substr(xMensage3, 1, 55)
		nLin := nLin + 1
		//
	Endif
	//
	If !Empty(Substr(xMensage3, 56, 55))
		//
		@ nLin, 001 Psay Substr(xMensage3, 56, 55)
		nLin := nLin + 1
		//
	Endif
	//
	nLin := 80
	@ nLin, 118 Psay xNUM_NF
	//
	nLin := 84
	If (Mv_Par01 == Mv_Par02 .Or. xNUM_NF == Mv_Par02)
		_nLinFin := 2
	Else
		_nLinFin := 4
	Endif
	//
	nLin := nLin + _nLinFin
	@ nLin, 000 Psay " " + xDesconf        // Reset de Impressao
	//
	SetPrc(0,0)
	//
Return (.T.)

/////////////////////////
Static Function ValidPerg
	/////////////////////////

	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Do Documento                 ?","mv_ch1","C",Len(SF1->F1_DOC),0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até o Documento              ?","mv_ch2","C",Len(SF1->F1_DOC),0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Da Série                     ?","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Tipo de Movimento            ?","mv_ch4","N",01,0,0,"C","","mv_par04","Entrada","","","Saída","","","","","","","","","","",""})
	//aAdd(aRegs,{cPerg,"05","Data de Re-emissão           ?","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})

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

/*/
////////////////////
User Function Ajuste
////////////////////

_aArea := GetArea()

DbSelectArea("SF2")
RecLock("SF2",.F.)
SF2->F2_EMISORI := If(Empty(SF2->F2_EMISORI),SF2->F2_EMISSAO,SF2->F2_EMISORI)
SF2->F2_EMISSAO := Mv_Par05
MsUnLock()

DbSelectArea("SF3")
_aAreaSF3 := GetArea()
DbSetOrder(4)  //F3_FILIAL+F3_CLIEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE
DbSeek(xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE,.F.)
Do While SF3->F3_FILIAL+SF3->F3_CLIEFOR+SF3->F3_LOJA+SF3->F3_NFISCAL+SF3->F3_SERIE ==;
xFilial("SF3")+SF2->F2_CLIENTE+SF2->F2_LOJA+SF2->F2_DOC+SF2->F2_SERIE .And. SF3->(!Eof())

RecLock("SF3",.F.)
SF3->F3_ENTRADA := SF2->F2_EMISSAO
SF3->F3_EMISSAO := SF2->F2_EMISSAO
MsUnLock()

DbSkip()

EndDo

RestArea(_aAreaSF3)
RestArea(_aArea)

Return
/*/

User Function CortaDesc(_DescB1)

	_DescB1 := AllTrim(_DescB1)
	_DescTr := ""
	_Pri    := .T.
	For _n := 1 to Len(_DescB1)
		_cChar := Substr(_DescB1,_n,1)
		If _cChar == " " .And. _Pri
			_DescTr := _DescTr + _cChar
			_Pri    := .F.
		ElseIf _cChar # " "
			_DescTr := _DescTr + _cChar
			_Pri    := .T.
		EndIf
	Next
Return(_DescTr)