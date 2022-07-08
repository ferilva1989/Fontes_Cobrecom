//Bibliotecas
#include "Protheus.ch"
#include "TopConn.ch"
	
//Constantes
#define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} relImpCte
Relatório - CTes importados               
@author zReport
@since 19/03/20
@version 1.0
	@example
	u_relImpCte()
	@obs Função gerada pelo zReport()
/*/
user function relImpCte()
	local aArea   := GetArea()
	local oReport
	local lEmail  := .F.
	local cPara   := ""
	private cPerg := ""
	
	//Definições da pergunta
	cPerg := "CBCRELCTE "
	//Se a pergunta não existir, zera a variável
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	If ! SX1->(DbSeek(cPerg))
		cPerg := Nil
	else
		Pergunte(cPerg)
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
	else
		oReport:PrintDialog()
	endIf
	RestArea(aArea)
return
	
static function fReportDef()
	local oReport
	local oSectDad := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"relImpCte",;		//Nome do Relatório
								"Relação de CTes ",;		//Título
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
	TRCell():New(oSectDad, "FILIAL", "QRY_AUX", "Filial", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DOC", "QRY_AUX", "Documento", /*Picture*/, 16, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SERIE", "QRY_AUX", "Serie", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TIPO", "QRY_AUX", "Tipo", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DT_IMPORT", "QRY_AUX", "Data_Importacao", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DT_EMISSAO", "QRY_AUX", "Data_Emissao", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_IMPORTA", "QRY_AUX", "Cte_importa", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "EMITENTE", "QRY_AUX", "Emitente", /*Picture*/, 16, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NOME_EMIT", "QRY_AUX", "Emit_Nome", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "UF_EMIT", "QRY_AUX", "Emit_Estado", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "CIDADE_EMIT", "QRY_AUX", "Emit_Municipio", /*Picture*/, 25, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "UF_ORIGEM", "QRY_AUX", "Orig_Estado", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CIDADE_ORIGEM", "QRY_AUX", "Orig_Municipio", /*Picture*/, 25, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "UF_DESTINO", "QRY_AUX", "Dest_Estado", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "CIDADE_DESTINO", "QRY_AUX", "Dest_Municipio", /*Picture*/, 25, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "FRETE", "QRY_AUX", "Frete", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DESPESA", "QRY_AUX", "Despesa", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "DESCONTO", "QRY_AUX", "Desconto", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "PESO_BRUTO", "QRY_AUX", "Peso_Bruto", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ESPECIE_1", "QRY_AUX", "Especie", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VOLUME_1", "QRY_AUX", "Volume", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ESPECIE_2", "QRY_AUX", "Especie_2", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VOLUME_2", "QRY_AUX", "Volume_2", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ESPECIE_3", "QRY_AUX", "Especie_3", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VOLUME_3", "QRY_AUX", "Volume_3", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TIPO_FRETE", "QRY_AUX", "Tipo_Frete", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VALOR", "QRY_AUX", "Valor", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "BASE_ICMS", "QRY_AUX", "Base_ICMS", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ICMS", "QRY_AUX", "Valor_ICMS", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CHAVE_NF_ORI", "QRY_AUX", "Chv_Nf_Orig", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SERIE_DOC_FISCAL", "QRY_AUX", "Serie_Doc_Fisc", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_PEDAGIO", "QRY_AUX", "Cte_pedagio", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CHV_CTE", "QRY_AUX", "Chv_CTe", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "STATUS", "QRY_AUX", "Status", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_BASIMP", "QRY_AUX", "Cte_basimp", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NFE_SERIE", "QRY_AUX", "Nf_Serie", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NFE_DOC", "QRY_AUX", "Nf_Doc", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NFE_CHAVE", "QRY_AUX", "Nf_Chave", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NFE_PES_BRUT", "QRY_AUX", "Nfe_PesBrut", /*Picture*/, 60, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NFE_PES_LIQ", "QRY_AUX", "Nfe_PesLiq", /*Picture*/, 60, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "OBS", "QRY_AUX", "Observacao", /*Picture*/, 500, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport
	
static function fRepPrint(oReport)
	local aArea    := GetArea()
	local cQryAux  := ""
	local oSectDad := Nil
	local nAtual   := 0
	local nTotal   := 0
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	//Montando consulta de dados
	cQryAux := "SELECT "
    cQryAux += "    DS.DS_FILIAL [FILIAL], "
    cQryAux += "    DS.DS_DOC [DOC], "
    cQryAux += "    DS.DS_SERIE [SERIE], "
    cQryAux += "    DS.DS_TPCTE [TIPO], "
    cQryAux += "    DS.DS_DATAIMP [DT_IMPORT], "
    cQryAux += "    DS.DS_EMISSA [DT_EMISSAO], "
    cQryAux += "    DS.DS_CNPJ [EMITENTE], "
    cQryAux += "    A2.A2_NOME [NOME_EMIT], "
    cQryAux += "    A2.A2_MUN [CIDADE_EMIT], "
    cQryAux += "    A2.A2_EST [UF_EMIT], "
    cQryAux += "    DS.DS_UFORITR [UF_ORIGEM], "
    cQryAux += "    CC2_ORI.CC2_MUN [CIDADE_ORIGEM], "
    cQryAux += "    DS.DS_MUORITR, "
    cQryAux += "    DS.DS_UFDESTR [UF_DESTINO], "
    cQryAux += "    CC2_DEST.CC2_MUN [CIDADE_DESTINO], "
    cQryAux += "    DS.DS_FRETE [FRETE], "
    cQryAux += "    DS.DS_SEGURO [SEGURO], "
    cQryAux += "    DS.DS_DESPESA [DESPESA], "
    cQryAux += "    DS.DS_DESCONT [DESCONTO], "
    cQryAux += "    DS.DS_PBRUTO [PESO_BRUTO], "
    cQryAux += "    DS.DS_ESPECI1 [ESPECIE_1], "
    cQryAux += "    DS.DS_VOLUME1 [VOLUME_1], "
    cQryAux += "    DS.DS_ESPECI2 [ESPECIE_2], "
    cQryAux += "    DS.DS_VOLUME2 [VOLUME_2], "
    cQryAux += "    DS.DS_ESPECI3 [ESPECIE_3], "
    cQryAux += "    DS.DS_VOLUME3 [VOLUME_3, "
    cQryAux += "    DS.DS_TPFRETE [TIPO_FRETE], "
    cQryAux += "    DS.DS_VALMERC [VALOR], "
    cQryAux += "    DS.DS_BASEICM [BASE_ICMS], "
    cQryAux += "    DS.DS_VALICM [ICMS], "
    cQryAux += "    DS.DS_CHVNFOR [CHAVE_NF_ORI], "
    cQryAux += "    DS.DS_SDOC [SERIE_DOC_FISCAL], "
    cQryAux += "    DS.DS_CHAVENF [CHV_CTE], "
    cQryAux += "    CASE "
    cQryAux += "        WHEN DS.DS_STATUS = 'P' THEN 'PROCESSADO' "
    cQryAux += "        WHEN DS.DS_STATUS = 'E' THEN 'ERRO' "
    cQryAux += "        ELSE 'PENDENTE' "
    cQryAux += "    END AS [STATUS], "
    cQryAux += "    CASE "
    cQryAux += "        WHEN F2.F2_SERIE <> '' THEN F2.F2_SERIE "
    cQryAux += "        WHEN F1.F1_SERIE <> '' THEN F1.F1_SERIE "
    cQryAux += "        ELSE 'N.ENCONTRADO' "
    cQryAux += "    END AS [NFE_SERIE], "
    cQryAux += "    CASE "
    cQryAux += "        WHEN F2.F2_DOC <> '' THEN F2.F2_DOC "
    cQryAux += "        WHEN F1.F1_DOC <> '' THEN F1.F1_DOC "
    cQryAux += "        ELSE 'N.ENCONTRADO' "
    cQryAux += "    END AS [NFE_DOC], "
    cQryAux += "    CASE "
    cQryAux += "        WHEN F2.F2_CHVCTE <> '' THEN F2.F2_CHVNFE "
    cQryAux += "        WHEN F1.F1_CHVCTE <> '' THEN F1.F1_CHVNFE "
    cQryAux += "        ELSE 'N.ENCONTRADO' "
    cQryAux += "    END AS [NFE_CHAVE], "
	cQryAux += "	CASE "
	cQryAux += "		WHEN SF2.F2_PLIQUI <> '' THEN SF2.F2_PLIQUI "
	cQryAux += "		WHEN SF1.F1_PLIQUI <> '' THEN SF1.F1_PLIQUI "
	cQryAux += "		ELSE 'N.ENCONTRADO' "
	cQryAux += "	END AS [NFE_PES_LIQ], "
	cQryAux += "	CASE "
	cQryAux += "		WHEN SF2.F2_PBRUTO <> '' THEN SF2.F2_PBRUTO "
	cQryAux += "		WHEN SF1.F1_PBRUTO <> '' THEN SF1.F1_PBRUTO "
	cQryAux += "		ELSE 'N.ENCONTRADO' "
	cQryAux += "	END AS [NFE_PES_BRUT], "
    cQryAux += "    ISNULL( CONVERT( VARCHAR(6144), CONVERT(VARBINARY(6144), DS.DS_OBS)),'') [OBS] "
    cQryAux += "FROM "
    cQryAux += "    SDS010 DS WITH(NOLOCK) "
    cQryAux += "INNER JOIN "
    cQryAux += "    SA2010 A2 WITH(NOLOCK) "
    cQryAux += "        ON '' = A2.A2_FILIAL  "
    cQryAux += "        AND DS.DS_FORNEC = A2.A2_COD "
    cQryAux += "        AND DS.DS_LOJA = A2.A2_LOJA "
    cQryAux += "        AND DS.D_E_L_E_T_ = A2.D_E_L_E_T_ "
    cQryAux += "LEFT JOIN "
    cQryAux += "    SF2010 F2 WITH(NOLOCK) "
    cQryAux += "        ON DS.DS_CHAVENF = F2.F2_CHVCTE "
    cQryAux += "        AND DS.D_E_L_E_T_ = F2.D_E_L_E_T_ "
    cQryAux += "LEFT JOIN "
    cQryAux += "    SF1010 F1 WITH(NOLOCK) "
    cQryAux += "        ON DS.DS_CHAVENF = F1.F1_CHVCTE "
    cQryAux += "        AND DS.D_E_L_E_T_ = F1.D_E_L_E_T_ "
    cQryAux += "OUTER APPLY      (   SELECT "
    cQryAux += "    CC2_ORI.CC2_MUN FROM "
    cQryAux += "        CC2010 CC2_ORI "
    cQryAux += "    WHERE "
    cQryAux += "        CC2_ORI.CC2_FILIAL = '' "
    cQryAux += "        AND CC2_ORI.CC2_EST = DS.DS_UFORITR "
    cQryAux += "        AND CC2_ORI.CC2_CODMUN = DS.DS_MUORITR "
    cQryAux += "        AND CC2_ORI.D_E_L_E_T_ = DS.D_E_L_E_T_   ) CC2_ORI "
    cQryAux += "OUTER APPLY      (   SELECT "
    cQryAux += "    CC2_DEST.CC2_MUN FROM "
    cQryAux += "        CC2010 CC2_DEST "
    cQryAux += "    WHERE "
    cQryAux += "        CC2_DEST.CC2_FILIAL = '' "
    cQryAux += "        AND CC2_DEST.CC2_EST = DS.DS_UFDESTR "
    cQryAux += "        AND CC2_DEST.CC2_CODMUN = DS.DS_MUDESTR "
    cQryAux += "        AND CC2_DEST.D_E_L_E_T_ = DS.D_E_L_E_T_   ) CC2_DEST "
    cQryAux += "WHERE "
    cQryAux += "    DS.DS_FILIAL BETWEEN '" +  MV_PAR01 + "' AND '" +  MV_PAR02 +"' "
    cQryAux += "    AND DS.DS_EMISSA BETWEEN '" + DtoS(MV_PAR03) + "' AND '" + DtoS(MV_PAR04) +"' "
    cQryAux += "    AND DS.D_E_L_E_T_ = '' "
    cQryAux += "ORDER BY "
    cQryAux += "    DS.DS_FILIAL, "
    cQryAux += "    DS.DS_EMISSA, "
    cQryAux += "    DS_DOC "
	// cQryAux := ChangeQuery(cQryAux)
	
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	TCSetField("QRY_AUX", "DT_EMISSAO", "D")
	TCSetField("QRY_AUX", "DT_IMPORT", "D")

	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	while ! QRY_AUX->(Eof())
		//Incrementando a régua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()			
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		QRY_AUX->(DbSkip())
	enddo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())
	RestArea(aArea)
Return
