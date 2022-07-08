//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} CBCUSR01
Relatório - Relatorio Compras X Custos    
@author zReport
@since 10/04/2017
@version 1.0
	@example
	u_CBCUSR01()
	@obs Função gerada pelo zReport()
/*/
	
User Function CBCUSR01()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	
	//Definições da pergunta
	cPerg := "CDCUSR01  "
	
	//Se a pergunta não existir, zera a variável
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	If ! SX1->(DbSeek(cPerg))
		cPerg := Nil
	EndIf
	
	//Cria as definições do relatório
	oReport := fReportDef()
	
	//Será enviado por e-Mail?
	If lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail := cPara
		oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
	//Senão, mostra a tela
	Else
		oReport:PrintDialog()
	EndIf
	
	RestArea(aArea)
Return
	
/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Desc:  Função que monta a definição do relatório                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oBreak := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"CBCUSR01",;						//Nome do Relatório
								"Relatorio Compras X Custos",;		//Título
								cPerg,;								//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| fRepPrint(oReport)},;	//Bloco de código que será executado na confirmação da impressão
								)									//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetLandscape()
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"Dados",;		//Descrição da seção
									{"QRY_AUX1"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(oSectDad, "FILIAL", "QRY_AUX1", "Filial", /*Picture*/, 11, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TIPO_PRODUTO", "QRY_AUX1", "Tipo_produto", /*Picture*/, 55, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DATA", "QRY_AUX1", "Data", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SERIE_NF", "QRY_AUX1", "Serie_nf", /*Picture*/, 19, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "FORNECEDOR", "QRY_AUX1", "Fornecedor", /*Picture*/, 34, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_CUSTO", "QRY_AUX1", "Vl_custo", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_NF", "QRY_AUX1", "Vl_nf", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_IPI", "QRY_AUX1", "Vl_ipi", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_ICMS", "QRY_AUX1", "Vl_icms", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_DESCONTO", "QRY_AUX1", "Vl_desconto", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_COFINS", "QRY_AUX1", "Vl_cofins", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_PIS", "QRY_AUX1", "Vl_pis", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_FRETE", "QRY_AUX1", "Vl_frete", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_DESPESAS", "QRY_AUX1", "Vl_despesas", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_ICMS_COMPL", "QRY_AUX1", "Vl_icms_compl", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TES", "QRY_AUX1", "Tes", /*Picture*/, 7, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TRANSF_FILIAL", "QRY_AUX1", "Transf_filial", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux1 := " "
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	// faz as perguntas sem abrir a tela para o usuário
    Pergunte(cPerg,.F.)
	
	//Montando consulta de dados
	cQryAux1 := " "
	cQryAux1 += "SELECT"		+ STR_PULA
	cQryAux1 += "	CASE"		+ STR_PULA
	cQryAux1 += "		WHEN D1_FILIAL = '01'"		+ STR_PULA
	cQryAux1 += "			THEN 'ITU'"		+ STR_PULA
	cQryAux1 += "		WHEN D1_FILIAL = '02'"		+ STR_PULA
	cQryAux1 += "			THEN 'TRES LAGOAS'"		+ STR_PULA
	cQryAux1 += "		WHEN D1_FILIAL = '03'"		+ STR_PULA
	cQryAux1 += "			THEN 'POUSO ALEGRE'"	+ STR_PULA
	cQryAux1 += "		ELSE 'N/I'"		+ STR_PULA
	cQryAux1 += "	END																						FILIAL,"		+ STR_PULA
	cQryAux1 += "	X5_DESCRI																				TIPO_PRODUTO,"		+ STR_PULA
	cQryAux1 += "	SUBSTRING(D1_DTDIGIT,1,4)+'-'+SUBSTRING(D1_DTDIGIT,5,2)+'-'+SUBSTRING(D1_DTDIGIT,7,2)	DATA,"		+ STR_PULA
	cQryAux1 += "	'[ '+RTRIM(D1_SERIE)+' - '+RTRIM(D1_DOC)+' ]'											SERIE_NF,"		+ STR_PULA
	cQryAux1 += "	ISNULL('[ '+D1_FORNECE+'-'+D1_LOJA+' ] '+A2_NREDUZ,'[ '+D1_FORNECE+'-'+D1_LOJA+' ]')	FORNECEDOR,															"		+ STR_PULA
	cQryAux1 += "	D1_CUSTO																				VL_CUSTO,"		+ STR_PULA
	cQryAux1 += "	D1_TOTAL																				VL_NF,"		+ STR_PULA
	cQryAux1 += "	D1_VALIPI																				VL_IPI,"		+ STR_PULA
	cQryAux1 += "	D1_VALICM																				VL_ICMS,"		+ STR_PULA
	cQryAux1 += "	D1_VALDESC																				VL_DESCONTO,"		+ STR_PULA
	cQryAux1 += "	D1_VALIMP5																				VL_COFINS,"		+ STR_PULA
	cQryAux1 += "	D1_VALIMP6																				VL_PIS,"		+ STR_PULA
	cQryAux1 += "	D1_VALFRE																				VL_FRETE,"		+ STR_PULA
	cQryAux1 += "	D1_DESPESA																				VL_DESPESAS,"		+ STR_PULA
	cQryAux1 += "	D1_ICMSCOM																				VL_ICMS_COMPL,"		+ STR_PULA
	cQryAux1 += "	'[ '+D1_TES+' ]'																		TES,"		+ STR_PULA
	cQryAux1 += "	CASE"		+ STR_PULA
	cQryAux1 += "		WHEN F4_TRANFIL = '1'"		+ STR_PULA
	cQryAux1 += "			THEN 'SIM'"		+ STR_PULA
	cQryAux1 += "		ELSE 'NAO'"		+ STR_PULA
	cQryAux1 += "	END																						TRANSF_FILIAL"		+ STR_PULA
	cQryAux1 += "FROM SD1010 D1"		+ STR_PULA
	cQryAux1 += "INNER JOIN SF4010 F4"		+ STR_PULA
	cQryAux1 += "	ON ''				= F4_FILIAL"		+ STR_PULA
	cQryAux1 += "	AND D1_TES			= F4_CODIGO"		+ STR_PULA
	cQryAux1 += "	AND D1.D_E_L_E_T_	= F4.D_E_L_E_T_"		+ STR_PULA
	cQryAux1 += "LEFT JOIN SA2010 A2"		+ STR_PULA
	cQryAux1 += "	ON ''				= A2_FILIAL"		+ STR_PULA
	cQryAux1 += "	AND D1_FORNECE		= A2_COD"		+ STR_PULA
	cQryAux1 += "	AND D1_LOJA			= A2_LOJA"		+ STR_PULA
	cQryAux1 += "	AND D1.D_E_L_E_T_	= A2.D_E_L_E_T_"		+ STR_PULA
	cQryAux1 += "INNER JOIN SX5010 X5"		+ STR_PULA
	cQryAux1 += "	ON D1_FILIAL		= X5_FILIAL"		+ STR_PULA
	cQryAux1 += "	AND '02'			= X5_TABELA"		+ STR_PULA
	cQryAux1 += "	AND D1_TP			= X5_CHAVE"		+ STR_PULA
	cQryAux1 += "	AND D1.D_E_L_E_T_	= X5.D_E_L_E_T_"		+ STR_PULA
	cQryAux1 += "WHERE "		+ STR_PULA
	cQryAux1 += "	D1_FILIAL IN ('01','02','03')"		+ STR_PULA
	cQryAux1 += "	AND D1_DTDIGIT BETWEEN '"+ DtoS(MV_PAR01) + "' AND '"+ DtoS(MV_PAR02)+"'"		+ STR_PULA
	cQryAux1 += "	AND D1_TIPO IN ('N','P','C')"		+ STR_PULA //B=BENEFICIAMENTO,C=COMPL.PRECO-FRETE,D=DEVOLUCAO,I=COMPL.ICMS,N=NORMAL,P=COMPL.IPI
	cQryAux1 += "	AND D1.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux1 += "	AND F4_ESTOQUE = 'S'"		+ STR_PULA
	cQryAux1 += "	AND F4_PODER3 = 'N'"		+ STR_PULA
	cQryAux1 += "ORDER BY D1_FILIAL, D1_TP, D1_DTDIGIT"		+ STR_PULA
	cQryAux1 := ChangeQuery(cQryAux1)
	
	//Executando consulta e setando o total da régua
	TCQuery cQryAux1 New Alias "QRY_AUX1"
	
	//Enquanto houver dados
	oSectDad:Init()

	Count to nTotal
	oReport:SetMeter(nTotal)
	
	QRY_AUX1->(DbGoTop())
	oReport:SetMsgPrint("Imprimindo ...")
	
	While ! QRY_AUX1->(Eof())
		//Incrementando a régua
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		QRY_AUX1->(DbSkip())
	EndDo
	
	oSectDad:Finish()
	QRY_AUX1->(DbCloseArea())
	
	RestArea(aArea)
Return
