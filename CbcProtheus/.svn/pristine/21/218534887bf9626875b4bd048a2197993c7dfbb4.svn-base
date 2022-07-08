//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/* 
	Centralizar todos os relatorio MG(Pedido) aqui
	u_xMGReport('IDVEND')
*/	
User function xMGReport(cRel)
	if cRel == 'IDVEND'
		idVendReport()
	endif
return(nil)

Static Function idVendReport()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	
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
	
	//Criação do componente de impressão
	oReport := TReport():New(	"Pedido MG",;		//Nome do Relatório
								"Relatorio",;		//Título
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
								)		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetLandscape()
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"Dados",;		//Descrição da seção
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(oSectDad, "NOME_CLIENTE", "QRY_AUX", "Nome_cliente", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "EMISSAO_MG", "QRY_AUX", "Emissao_mg", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ENTREGA_MG", "QRY_AUX", "Entrega_mg", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "FAT_PARTIR_MG", "QRY_AUX", "Fat_partir_mg", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PED_MG", "QRY_AUX", "Numero_pedido_mg", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PED_3L", "QRY_AUX", "Numero_pedido_3l", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PED_ITU", "QRY_AUX", "Numero_pedido_itu", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "F_PARC_MG", "QRY_AUX", "Fatura_parcial_mg", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "OBSERVACAO_MG", "QRY_AUX", "Observacao_mg", /*Picture*/, 57, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "BLOQ_FATURAMENTO_MG", "QRY_AUX", "Bloq_faturamento_mg", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DRC_MG", "QRY_AUX", "Drc_mg", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PALLET_MG", "QRY_AUX", "Pallet_mg", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "LAUDO_MG", "QRY_AUX", "Laudo_mg", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "INSPECAO_MG", "QRY_AUX", "Inspecao_mg", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT "		+ STR_PULA
	cQryAux += "	SA1.A1_NOME							AS [NOME_CLIENTE],"			+ STR_PULA
	cQryAux += "	CONVERT(DATE,  SC5_MG.C5_EMISSAO)   AS [EMISSAO_MG],"			+ STR_PULA
	cQryAux += "	CONVERT(DATE,  SC5_MG.C5_ENTREG)    AS [ENTREGA_MG],"			+ STR_PULA
	cQryAux += "	CONVERT(DATE,  SC5_MG.C5_DTFAT)     AS [FAT_PARTIR_MG],"		+ STR_PULA
	cQryAux += "	SC5_MG.C5_NUM						AS [PED_MG],"				+ STR_PULA
	cQryAux += "	ISNULL(SC5_TL.C5_NUM, '')			AS [PED_3L],"				+ STR_PULA
	cQryAux += "	ISNULL(SC5_ITU.C5_NUM, '')			AS [PED_ITU],"				+ STR_PULA
	cQryAux += "	SC5_MG.C5_PARCIAL					AS [F_PARC_MG],"	        + STR_PULA
	cQryAux += "	SC5_MG.C5_OBS						AS [OBSERVACAO_MG],"		+ STR_PULA
	cQryAux += "	SC5_MG.C5_ZZBLVEN					AS [BLOQ_FATURAMENTO_MG],"	+ STR_PULA
	cQryAux += "	SC5_MG.C5_DRC                       AS [DRC_MG],"				+ STR_PULA
	cQryAux += "	SC5_MG.C5_PALLET                    AS [PALLET_MG],"			+ STR_PULA
	cQryAux += "	SC5_MG.C5_LAUDO                     AS [LAUDO_MG],"				+ STR_PULA
	cQryAux += "	SC5_MG.C5_ZZINSPE                   AS [INSPECAO_MG]"			+ STR_PULA
	cQryAux += "FROM SC5010 SC5_MG"									+ STR_PULA
	cQryAux += "LEFT JOIN SC5010 SC5_TL ON"							+ STR_PULA
	cQryAux += "	'02'  = SC5_TL.C5_FILIAL"						+ STR_PULA
	cQryAux += "	AND SC5_MG.C5_X_IDVEN =  SC5_TL.C5_X_IDVEN"		+ STR_PULA
	cQryAux += "	AND SC5_MG.D_E_L_E_T_ =  SC5_TL.D_E_L_E_T_"		+ STR_PULA
	cQryAux += "LEFT JOIN SC5010 SC5_ITU ON"						+ STR_PULA
	cQryAux += "	'01'  = SC5_ITU.C5_FILIAL"						+ STR_PULA
	cQryAux += "	AND SC5_MG.C5_X_IDVEN =  SC5_ITU.C5_X_IDVEN"	+ STR_PULA
	cQryAux += "	AND SC5_MG.D_E_L_E_T_ =  SC5_ITU.D_E_L_E_T_"	+ STR_PULA
	cQryAux += "INNER JOIN SA1010 SA1 ON"							+ STR_PULA
	cQryAux += "	''  = SA1.A1_FILIAL"							+ STR_PULA
	cQryAux += "	AND SC5_MG.C5_CLIENTE = SA1.A1_COD"				+ STR_PULA
	cQryAux += "	AND SC5_MG.C5_LOJACLI = SA1.A1_LOJA"			+ STR_PULA
	cQryAux += "	AND SC5_MG.D_E_L_E_T_ = SA1.D_E_L_E_T_"			+ STR_PULA
	cQryAux += "WHERE "												+ STR_PULA
	cQryAux += "	SC5_MG.C5_FILIAL = '03'"						+ STR_PULA
	cQryAux += "	AND SC5_MG.C5_LIBEROK = 'S'"					+ STR_PULA
	cQryAux += "    AND SC5_MG.C5_NOTA = ''"						+ STR_PULA
	cQryAux += "	AND SC5_MG.C5_X_IDVEN <> ''"					+ STR_PULA
	cQryAux += "	AND SC5_MG.D_E_L_E_T_ = ''"						+ STR_PULA
	cQryAux += "	ORDER BY SA1.A1_NOME, SC5_MG.C5_ENTREG, SC5_MG.C5_DTFAT, SC5_MG.C5_NUM " + STR_PULA

	cQryAux := ChangeQuery(cQryAux)
	
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		//Incrementando a régua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		QRY_AUX->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())
	
	RestArea(aArea)
Return
