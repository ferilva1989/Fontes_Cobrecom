//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} CBCSaida
Relatório - Cobrecom Saidas KG_Cobre      
@author zReport
@since 16/06/2017
@version 1.0
	@example
	u_CBCSaida()
	@obs Função gerada pelo zReport()
/*/
User Function CBCSaida()
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
	
	
/*/{Protheus.doc} fReportDef
//TODO Função que monta a definição do relatório.
@author juliana.leme
@since 19/07/2017
@version undefined

@type function
/*/
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oBreak := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"CBCSaida",;		//Nome do Relatório
								"Cobrecom Saidas KG_Cobre",;		//Título
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
								)		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetPortrait()
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"Dados",;		//Descrição da seção
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(oSectDad, "FILIAL", "QRY_AUX", "Filial", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "EMISSAO", "QRY_AUX", "Emissao", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NFISCAL", "QRY_AUX", "Nfiscal", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SERIE", "QRY_AUX", "Serie", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CLIENTE_LOJA", "QRY_AUX", "Cliente_loja", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PRODUTO", "QRY_AUX", "Produto", /*Picture*/, 17, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DESCRICAO", "QRY_AUX", "Descricao", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "UM", "QRY_AUX", "Cargo", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QTDE", "QRY_AUX", "Qtde", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QTDE_PESCOB", "QRY_AUX", "Qtde_pescob", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QTDE_PESPVC", "QRY_AUX", "Qtde_pespvc", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CFOP", "QRY_AUX", "Cfop", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TES", "QRY_AUX", "Tes", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PRC_VENDA", "QRY_AUX", "Prc_venda", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PRC_TOTAL", "QRY_AUX", "Prc_total", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "BASE_ICM", "QRY_AUX", "Base_icm", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PERC_ICM", "QRY_AUX", "Perc_icm", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ICMS", "QRY_AUX", "Icms", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ESTOQUE", "QRY_AUX", "Estoque", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ARMZ", "QRY_AUX", "Armz", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport
	
/*/{Protheus.doc} fRepPrint
//TODO Função que imprime o relatório  .
@author juliana.leme
@since 19/07/2017
@version undefined
@param oReport, object, descricao
@type function
/*/
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	// faz as perguntas sem abrir a tela para o usuário
    Pergunte(cPerg,.F.)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT D2_FILIAL FILIAL, "			+ STR_PULA
	cQryAux += "		D2_EMISSAO EMISSAO,"		+ STR_PULA
	cQryAux += "		D2_DOC NFISCAL, "			+ STR_PULA
	cQryAux += "		D2_SERIE SERIE,"			+ STR_PULA
	cQryAux += "		D2_CLIENTE + '/' + D2_LOJA CLIENTE_LOJA,"	+ STR_PULA
	cQryAux += "		D2_COD PRODUTO, "			+ STR_PULA
	cQryAux += "		D2_DESCRI DESCRICAO, "		+ STR_PULA
	cQryAux += "		D2_UM UM, "					+ STR_PULA
	cQryAux += "		D2_QUANT QTDE, "			+ STR_PULA
	cQryAux += "		B1.B1_PESCOB * D2_QUANT QTDE_PESCOB,"		+ STR_PULA
	cQryAux += "		B1.B1_PESPVC * D2_QUANT QTDE_PESPVC,"		+ STR_PULA
	cQryAux += "		D2_CF CFOP,"				+ STR_PULA
	cQryAux += "		D2_TES TES, "				+ STR_PULA
	cQryAux += "		D2_PRCVEN PRC_VENDA, "		+ STR_PULA
	cQryAux += "		D2_TOTAL PRC_TOTAL,"		+ STR_PULA
	cQryAux += "		D2_BASEICM BASE_ICM,"		+ STR_PULA
	cQryAux += "		D2_PICM PERC_ICM, "			+ STR_PULA
	cQryAux += "		D2_VALICM ICMS,"			+ STR_PULA
	cQryAux += "		D2_LOCAL ARMZ, "			+ STR_PULA
	cQryAux += "		F4_ESTOQUE ESTOQUE "		+ STR_PULA
	cQryAux += "FROM SD2010 D2"						+ STR_PULA
	cQryAux += "	INNER JOIN SB1010 B1 " 			+ STR_PULA
	cQryAux += "		ON B1_FILIAL = '  ' " 		+ STR_PULA
	cQryAux += "		AND B1_COD = D2_COD " 		+ STR_PULA
	cQryAux += "		AND B1.D_E_L_E_T_ = D2.D_E_L_E_T_"		+ STR_PULA
	cQryAux += "	INNER JOIN SF4010 F4 "		+ STR_PULA
	cQryAux += "		ON ''				= F4_FILIAL "		+ STR_PULA
	cQryAux += "		AND D2_TES			= F4_CODIGO "		+ STR_PULA
	cQryAux += "		AND D2.D_E_L_E_T_	= F4.D_E_L_E_T_ "	+ STR_PULA
	cQryAux += "WHERE D2_FILIAL = '" + FWCodFil() + "' "	+ STR_PULA
	cQryAux += "AND D2.D_E_L_E_T_ = ''"							+ STR_PULA
	cQryAux += "AND D2_EMISSAO BETWEEN '"+ DtoS(MV_PAR01) + "' AND '"+ DtoS(MV_PAR02)+"'"		+ STR_PULA
	cQryAux := ChangeQuery(cQryAux)
	
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	oReport:SetMsgPrint("Imprimindo ...")
	While ! QRY_AUX->(Eof())
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		QRY_AUX->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())
	
	RestArea(aArea)
Return