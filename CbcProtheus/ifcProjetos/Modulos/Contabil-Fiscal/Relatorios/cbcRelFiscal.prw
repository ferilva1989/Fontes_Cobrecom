//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} cbcRelFi
Relatório - Relatorio Lançamentos Fiscais                 
@author zReport
@since 08/08/2019
@version 1.0
	@example
	u_cbcRelFi()
	@obs Função gerada pelo zReport()
/*/
	
user function cbcRelFiscal()
	local aArea   := GetArea()
	local oReport
	local lEmail  := .F.
	local cPara   := ""
	private cPerg := ""

	cPerg := "CBCRELFIS "
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	if ! SX1->(DbSeek(cPerg))
		cPerg := Nil
	endif
	oReport := fReportDef()
	if lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail := cPara
		oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
	else
		oReport:PrintDialog()
	endIf	
	restArea(aArea)
return
	

static Function fReportDef()
	local oReport
	local oSectDad := Nil
	local oBreak := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"cbcRelFis",;		//Nome do Relatório
								"Relatorio Lançamentos Fiscais",;		//Título
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
								)		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetLandscape()
	oReport:SetLineHeight(50)
	oReport:nFontBody := 08
	
	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"Dados",;		//Descrição da seção
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	TRCell():New(oSectDad, "EMISSAO", "QRY_AUX", "Emissao", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ESPECIE", "QRY_AUX", "Especie", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SERIE", "QRY_AUX", "Serie", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NFISCAL", "QRY_AUX", "Nfiscal", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CLIEFOR_LOJA", "QRY_AUX", "Cliefor_loja", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CNPJ_NOME", "QRY_AUX", "Cnpj_nome", /*Picture*/, 65, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ESTADO", "QRY_AUX", "Estado", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VLCONT", "QRY_AUX", "Vlcont", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CFOP", "QRY_AUX", "Cfop", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "BASE_ICM", "QRY_AUX", "Base_icm", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VAL_ICM", "QRY_AUX", "Val_icm", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ISEN_ICM", "QRY_AUX", "Isen_icm", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "OUT_ICM", "QRY_AUX", "Out_icm", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "BASE_IPI", "QRY_AUX", "Base_ipi", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VAL_IPI", "QRY_AUX", "Val_ipi", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ISEN_IPI", "QRY_AUX", "Isen_ipi", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "OUT_IPI", "QRY_AUX", "Out_ipi", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "BASE_ICM_RET", "QRY_AUX", "Base_icm_ret", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VAL_ICM_RET", "QRY_AUX", "Val_icm_ret", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VAL_FECP_ST", "QRY_AUX", "Val_fecp_st", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VAL_ICM_DIFAL", "QRY_AUX", "Val_icm_difal", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VAL_FCP_DIF", "QRY_AUX", "Val_fcp_dif", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "OBSERVA", "QRY_AUX", "Observa", /*Picture*/, 31, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NFORI", "QRY_AUX", "Nfori", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
return oReport

static function fRepPrint(oReport)
	local aArea    := GetArea()
	local cQryAux  := ""
	local oSectDad := Nil
	local nAtual   := 0
	local nTotal   := 0
	
	oSectDad := oReport:Section(1)
	cQryAux := ""
	cQryAux += "SELECT	FT_EMISSAO EMISSAO,"		+ STR_PULA
	cQryAux += "		FT_ESPECIE ESPECIE,"		+ STR_PULA
	cQryAux += "		FT_SERIE SERIE,"		+ STR_PULA
	cQryAux += "		FT_NFISCAL NFISCAL,"		+ STR_PULA
	cQryAux += "		FT_CLIEFOR+FT_LOJA CLIEFOR_LOJA,"		+ STR_PULA
	cQryAux += "		CASE   "		+ STR_PULA
	cQryAux += "			WHEN (FT_TIPOMOV = 'S' AND FT_NFORI = '' "		+ STR_PULA
	cQryAux += "				AND (SELECT DISTINCT F2_TIPO FROM SF2010 SF2"		+ STR_PULA
	cQryAux += "					WHERE F2_FILIAL = FT_FILIAL "		+ STR_PULA
	cQryAux += "					AND F2_DOC = FT_NFISCAL"		+ STR_PULA
	cQryAux += "					AND F2_SERIE = FT_SERIE"		+ STR_PULA
	cQryAux += "					AND F2_CLIENTE = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "					AND F2_LOJA = FT_LOJA"			+ STR_PULA
	cQryAux += "					AND SF2.D_E_L_E_T_ = SFT.D_E_L_E_T_) = 'N') THEN A1_CGC + '-' + A1_NOME"		+ STR_PULA
	cQryAux += "			WHEN (FT_TIPOMOV = 'S' AND FT_NFORI = '' "		+ STR_PULA
	cQryAux += "				AND (SELECT DISTINCT F2_TIPO FROM SF2010 SF2"		+ STR_PULA
	cQryAux += "					WHERE F2_FILIAL = FT_FILIAL "		+ STR_PULA
	cQryAux += "					AND F2_DOC = FT_NFISCAL"		+ STR_PULA
	cQryAux += "					AND F2_SERIE = FT_SERIE"		+ STR_PULA
	cQryAux += "					AND F2_CLIENTE = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "					AND F2_LOJA = FT_LOJA"			+ STR_PULA
	cQryAux += "					AND SF2.D_E_L_E_T_ = SFT.D_E_L_E_T_) = 'B') THEN A2_CGC + '-' + A2_NOME"		+ STR_PULA
	cQryAux += "			WHEN (FT_TIPOMOV = 'S' AND FT_NFORI = '' "		+ STR_PULA
	cQryAux += "				AND (SELECT DISTINCT F2_TIPO FROM SF2010 SF2"		+ STR_PULA
	cQryAux += "					WHERE F2_FILIAL = FT_FILIAL "		+ STR_PULA
	cQryAux += "					AND F2_DOC = FT_NFISCAL"		+ STR_PULA
	cQryAux += "					AND F2_SERIE = FT_SERIE"		+ STR_PULA
	cQryAux += "					AND F2_CLIENTE = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "					AND F2_LOJA = FT_LOJA"			+ STR_PULA
	cQryAux += "					AND SF2.D_E_L_E_T_ = SFT.D_E_L_E_T_) = 'I') THEN A1_CGC + '-' + A1_NOME"		+ STR_PULA
	cQryAux += "			WHEN (FT_TIPOMOV = 'S' AND FT_NFORI <> '' "		+ STR_PULA
	cQryAux += "				AND (SELECT DISTINCT F2_TIPO FROM SF2010 SF2"		+ STR_PULA
	cQryAux += "					WHERE F2_FILIAL = FT_FILIAL "		+ STR_PULA
	cQryAux += "					AND F2_DOC = FT_NFISCAL"		+ STR_PULA
	cQryAux += "					AND F2_SERIE = FT_SERIE"		+ STR_PULA
	cQryAux += "					AND F2_CLIENTE = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "					AND F2_LOJA = FT_LOJA"			+ STR_PULA
	cQryAux += "					AND SF2.D_E_L_E_T_ = SFT.D_E_L_E_T_) = 'N') THEN A1_CGC + '-' + A1_NOME"		+ STR_PULA
	cQryAux += "			WHEN (FT_TIPOMOV = 'S' AND FT_NFORI <> '' "		+ STR_PULA
	cQryAux += "				AND (SELECT DISTINCT F2_TIPO FROM SF2010 SF2"		+ STR_PULA
	cQryAux += "					WHERE F2_FILIAL = FT_FILIAL "		+ STR_PULA
	cQryAux += "					AND F2_DOC = FT_NFISCAL"		+ STR_PULA
	cQryAux += "					AND F2_SERIE = FT_SERIE"		+ STR_PULA
	cQryAux += "					AND F2_CLIENTE = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "					AND F2_LOJA = FT_LOJA"			+ STR_PULA
	cQryAux += "					AND SF2.D_E_L_E_T_ = SFT.D_E_L_E_T_) = 'B') THEN A2_CGC + '-' + A2_NOME"		+ STR_PULA
	cQryAux += "			WHEN (FT_TIPOMOV = 'S' AND FT_NFORI <> '' "		+ STR_PULA
	cQryAux += "				AND (SELECT DISTINCT F2_TIPO FROM SF2010 SF2"		+ STR_PULA
	cQryAux += "					WHERE F2_FILIAL = FT_FILIAL "		+ STR_PULA
	cQryAux += "					AND F2_DOC = FT_NFISCAL"		+ STR_PULA
	cQryAux += "					AND F2_SERIE = FT_SERIE"		+ STR_PULA
	cQryAux += "					AND F2_CLIENTE = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "					AND F2_LOJA = FT_LOJA"			+ STR_PULA
	cQryAux += "					AND SF2.D_E_L_E_T_ = SFT.D_E_L_E_T_) = 'I') THEN A1_CGC + '-' + A1_NOME"		+ STR_PULA
	cQryAux += "			WHEN (FT_TIPOMOV = 'S' AND FT_NFORI <> '' "		+ STR_PULA
	cQryAux += "				AND (SELECT DISTINCT F2_TIPO FROM SF2010 SF2"		+ STR_PULA
	cQryAux += "					WHERE F2_FILIAL = FT_FILIAL "		+ STR_PULA
	cQryAux += "					AND F2_DOC = FT_NFISCAL"		+ STR_PULA
	cQryAux += "					AND F2_SERIE = FT_SERIE"		+ STR_PULA
	cQryAux += "					AND F2_CLIENTE = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "					AND F2_LOJA = FT_LOJA"			+ STR_PULA
	cQryAux += "					AND SF2.D_E_L_E_T_ = SFT.D_E_L_E_T_) = 'D') THEN A2_CGC + '-' + A2_NOME"		+ STR_PULA
	cQryAux += "			WHEN (FT_TIPOMOV = 'E' AND FT_NFORI = '' "		+ STR_PULA
	cQryAux += "				AND (SELECT DISTINCT F1_TIPO FROM SF1010 SF1"		+ STR_PULA
	cQryAux += "					WHERE F1_FILIAL = FT_FILIAL "		+ STR_PULA
	cQryAux += "					AND F1_DOC = FT_NFISCAL"		+ STR_PULA
	cQryAux += "					AND F1_SERIE = FT_SERIE"		+ STR_PULA
	cQryAux += "					AND F1_FORNECE = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "					AND F1_LOJA = FT_LOJA"			+ STR_PULA
	cQryAux += "					AND SF1.D_E_L_E_T_ = SFT.D_E_L_E_T_) = 'N') THEN A2_CGC + '-' + A2_NOME"		+ STR_PULA
	cQryAux += "			WHEN (FT_TIPOMOV = 'E' AND FT_NFORI = '' "		+ STR_PULA
	cQryAux += "				AND (SELECT DISTINCT F1_TIPO FROM SF1010 SF1"		+ STR_PULA
	cQryAux += "					WHERE F1_FILIAL = FT_FILIAL "		+ STR_PULA
	cQryAux += "					AND F1_DOC = FT_NFISCAL"		+ STR_PULA
	cQryAux += "					AND F1_SERIE = FT_SERIE"		+ STR_PULA
	cQryAux += "					AND F1_FORNECE = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "					AND F1_LOJA = FT_LOJA"			+ STR_PULA
	cQryAux += "					AND SF1.D_E_L_E_T_ = SFT.D_E_L_E_T_) = 'B') THEN A1_CGC + '-' + A1_NOME"		+ STR_PULA
	cQryAux += "			WHEN (FT_TIPOMOV = 'E' AND FT_NFORI = '' "		+ STR_PULA
	cQryAux += "				AND (SELECT DISTINCT F1_TIPO FROM SF1010 SF1"		+ STR_PULA
	cQryAux += "					WHERE F1_FILIAL = FT_FILIAL "		+ STR_PULA
	cQryAux += "					AND F1_DOC = FT_NFISCAL"		+ STR_PULA
	cQryAux += "					AND F1_SERIE = FT_SERIE"		+ STR_PULA
	cQryAux += "					AND F1_FORNECE = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "					AND F1_LOJA = FT_LOJA"			+ STR_PULA
	cQryAux += "					AND SF1.D_E_L_E_T_ = SFT.D_E_L_E_T_) = 'I') THEN A2_CGC + '-' + A2_NOME"		+ STR_PULA
	cQryAux += "			WHEN (FT_TIPOMOV = 'E' AND FT_NFORI = '' "		+ STR_PULA
	cQryAux += "				AND (SELECT DISTINCT F1_TIPO FROM SF1010 SF1"		+ STR_PULA
	cQryAux += "					WHERE F1_FILIAL = FT_FILIAL "		+ STR_PULA
	cQryAux += "					AND F1_DOC = FT_NFISCAL"		+ STR_PULA
	cQryAux += "					AND F1_SERIE = FT_SERIE"		+ STR_PULA
	cQryAux += "					AND F1_FORNECE = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "					AND F1_LOJA = FT_LOJA"			+ STR_PULA
	cQryAux += "					AND SF1.D_E_L_E_T_ = SFT.D_E_L_E_T_) = 'C') THEN A1_CGC + '-' + A1_NOME"		+ STR_PULA
	cQryAux += "			WHEN (FT_TIPOMOV = 'E' AND FT_NFORI <> '' "		+ STR_PULA
	cQryAux += "				AND (SELECT DISTINCT F1_TIPO FROM SF1010 SF1"		+ STR_PULA
	cQryAux += "					WHERE F1_FILIAL = FT_FILIAL "		+ STR_PULA
	cQryAux += "					AND F1_DOC = FT_NFISCAL"		+ STR_PULA
	cQryAux += "					AND F1_SERIE = FT_SERIE"		+ STR_PULA
	cQryAux += "					AND F1_FORNECE = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "					AND F1_LOJA = FT_LOJA"			+ STR_PULA
	cQryAux += "					AND SF1.D_E_L_E_T_ = SFT.D_E_L_E_T_) = 'N') THEN A2_CGC + '-' + A2_NOME"		+ STR_PULA
	cQryAux += "			WHEN (FT_TIPOMOV = 'E' AND FT_NFORI <> '' "		+ STR_PULA
	cQryAux += "				AND (SELECT DISTINCT F1_TIPO FROM SF1010 SF1"		+ STR_PULA
	cQryAux += "					WHERE F1_FILIAL = FT_FILIAL "		+ STR_PULA
	cQryAux += "					AND F1_DOC = FT_NFISCAL"		+ STR_PULA
	cQryAux += "					AND F1_SERIE = FT_SERIE"		+ STR_PULA
	cQryAux += "					AND F1_FORNECE = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "					AND F1_LOJA = FT_LOJA"			+ STR_PULA
	cQryAux += "					AND SF1.D_E_L_E_T_ = SFT.D_E_L_E_T_) = 'B') THEN A1_CGC + '-' + A1_NOME"		+ STR_PULA
	cQryAux += "			WHEN (FT_TIPOMOV = 'E' AND FT_NFORI <> '' "		+ STR_PULA
	cQryAux += "				AND (SELECT DISTINCT F1_TIPO FROM SF1010 SF1"		+ STR_PULA
	cQryAux += "					WHERE F1_FILIAL = FT_FILIAL "		+ STR_PULA
	cQryAux += "					AND F1_DOC = FT_NFISCAL"		+ STR_PULA
	cQryAux += "					AND F1_SERIE = FT_SERIE"		+ STR_PULA
	cQryAux += "					AND F1_FORNECE = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "					AND F1_LOJA = FT_LOJA"			+ STR_PULA
	cQryAux += "					AND SF1.D_E_L_E_T_ = SFT.D_E_L_E_T_) = 'I') THEN A2_CGC + '-' + A2_NOME"		+ STR_PULA
	cQryAux += "			WHEN (FT_TIPOMOV = 'E' AND FT_NFORI <> '' "		+ STR_PULA
	cQryAux += "				AND (SELECT DISTINCT F1_TIPO FROM SF1010 SF1"		+ STR_PULA
	cQryAux += "					WHERE F1_FILIAL = FT_FILIAL "		+ STR_PULA
	cQryAux += "					AND F1_DOC = FT_NFISCAL"		+ STR_PULA
	cQryAux += "					AND F1_SERIE = FT_SERIE"		+ STR_PULA
	cQryAux += "					AND F1_FORNECE = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "					AND F1_LOJA = FT_LOJA"			+ STR_PULA
	cQryAux += "					AND SF1.D_E_L_E_T_ = SFT.D_E_L_E_T_) = 'D') THEN A1_CGC + '-' + A1_NOME"		+ STR_PULA
	cQryAux += "			WHEN (FT_TIPOMOV = 'E' AND FT_NFORI <> '' "		+ STR_PULA
	cQryAux += "				AND (SELECT DISTINCT F1_TIPO FROM SF1010 SF1"		+ STR_PULA
	cQryAux += "					WHERE F1_FILIAL = FT_FILIAL "		+ STR_PULA
	cQryAux += "					AND F1_DOC = FT_NFISCAL"		+ STR_PULA
	cQryAux += "					AND F1_SERIE = FT_SERIE"		+ STR_PULA
	cQryAux += "					AND F1_FORNECE = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "					AND F1_LOJA = FT_LOJA"			+ STR_PULA
	cQryAux += "					AND SF1.D_E_L_E_T_ = SFT.D_E_L_E_T_) = 'C') THEN A2_CGC + '-' + A2_NOME"		+ STR_PULA
	cQryAux += "		END  AS CNPJ_NOME,"		+ STR_PULA
	cQryAux += "		FT_ESTADO ESTADO,"		+ STR_PULA
	cQryAux += "		SUM(FT_VALCONT) VLCONT,"		+ STR_PULA
	cQryAux += "		FT_CFOP CFOP,"		+ STR_PULA
	cQryAux += "		SUM(FT_BASEICM) BASE_ICM,"		+ STR_PULA
	cQryAux += "		SUM(FT_VALICM) VAL_ICM,"		+ STR_PULA
	cQryAux += "		SUM(FT_ISENICM) ISEN_ICM,"		+ STR_PULA
	cQryAux += "		SUM(FT_OUTRICM) OUT_ICM,"		+ STR_PULA
	cQryAux += "		SUM(FT_BASEIPI) BASE_IPI,"		+ STR_PULA
	cQryAux += "		SUM(FT_VALIPI) VAL_IPI,"		+ STR_PULA
	cQryAux += "		SUM(FT_ISENIPI) ISEN_IPI,"		+ STR_PULA
	cQryAux += "		SUM(FT_OUTRIPI) OUT_IPI,"		+ STR_PULA
	cQryAux += "		SUM(FT_BASERET) BASE_ICM_RET,"		+ STR_PULA
	cQryAux += "		SUM(FT_ICMSRET) VAL_ICM_RET,"		+ STR_PULA
	cQryAux += "		SUM(FT_VFECPST) VAL_FECP_ST,"	+ STR_PULA
	cQryAux += "		SUM(FT_DIFAL) VAL_ICM_DIFAL,"		+ STR_PULA
	cQryAux += "		SUM(FT_VFCPDIF) VAL_FCP_DIF,"	+ STR_PULA
	cQryAux += "		FT_OBSERV OBSERVA,"		+ STR_PULA
	cQryAux += "		FT_NFORI NFORI"		+ STR_PULA
	cQryAux += "FROM SFT010 SFT"		+ STR_PULA
	cQryAux += "	LEFT JOIN SA1010 SA1 "		+ STR_PULA
	cQryAux += "		ON A1_FILIAL = ''"		+ STR_PULA
	cQryAux += "		AND A1_COD = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "		AND A1_LOJA = FT_LOJA"		+ STR_PULA
	cQryAux += "		AND SFT.D_E_L_E_T_ = SA1.D_E_L_E_T_"		+ STR_PULA
	cQryAux += "	LEFT JOIN SA2010 SA2"		+ STR_PULA
	cQryAux += "		ON A2_FILIAL = ''"		+ STR_PULA
	cQryAux += "		AND A2_COD = FT_CLIEFOR"		+ STR_PULA
	cQryAux += "		AND A2_LOJA = FT_LOJA"		+ STR_PULA
	cQryAux += "		AND SFT.D_E_L_E_T_ = SA2.D_E_L_E_T_"		+ STR_PULA
	cQryAux += "WHERE FT_FILIAL = '" + FwFilial() + "'"		+ STR_PULA
	cQryAux += "AND FT_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'"		+ STR_PULA
	cQryAux += "AND FT_TIPOMOV = '" + iif(MV_PAR03 == 1,"E","S") + "'"		+ STR_PULA
	cQryAux += "AND SFT.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "GROUP BY FT_FILIAL,FT_EMISSAO ,FT_ESPECIE ,FT_SERIE, FT_NFISCAL ,FT_TIPOMOV,A1_NOME, A2_NOME,A1_CGC, A2_CGC, FT_ESTADO ,"		+ STR_PULA
	cQryAux += "		FT_CFOP ,FT_NFORI, FT_CLIEFOR, FT_LOJA, FT_OBSERV, SFT.D_E_L_E_T_"		+ STR_PULA
	cQryAux += "ORDER BY FT_EMISSAO, FT_CFOP, FT_SERIE, FT_NFISCAL"		+ STR_PULA
	cQryAux := ChangeQuery(cQryAux)

	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)

	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	while ! QRY_AUX->(eof())
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()
		oSectDad:PrintLine()
		QRY_AUX->(DbSkip())
	enddo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())
	RestArea(aArea)
return
