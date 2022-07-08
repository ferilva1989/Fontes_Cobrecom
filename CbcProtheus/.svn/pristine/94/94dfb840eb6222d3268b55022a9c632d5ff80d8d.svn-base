//Bibliotecas
#include "Protheus.ch"
#include "TopConn.ch"
	
//Constantes
#define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} cbcRelCt
Relatório - CTes importados               
@author zReport
@since 19/03/20
@version 1.0
	@example
	u_cbcRelCt()
	@obs Função gerada pelo zReport()
/*/
user function cbcRelCte()
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
	local oBreak := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"cbcRelCt",;		//Nome do Relatório
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
	TRCell():New(oSectDad, "SEQIMPORT", "QRY_AUX", "Seqimport", /*Picture*/, 16, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_SERIE", "QRY_AUX", "Cte_serie", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_DOC", "QRY_AUX", "Cte_doc", /*Picture*/, 16, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_EMISSAO", "QRY_AUX", "Cte_emissao", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_ENTRADA", "QRY_AUX", "Cte_entrada", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_IMPORTA", "QRY_AUX", "Cte_importa", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_EMISSOR", "QRY_AUX", "Cte_emissor", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_EMISRAZAO", "QRY_AUX", "Cte_emisrazao", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "CTE_EMISCID", "QRY_AUX", "Cte_emiscid", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "CTE_EMISUF", "QRY_AUX", "Cte_emisuf", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "CTE_REMETENTE", "QRY_AUX", "Cte_remetente", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_REMRAZAO", "QRY_AUX", "Cte_remrazao", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "CTE_REMCID", "QRY_AUX", "Cte_remcid", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "CTE_REMUF", "QRY_AUX", "Cte_remuf", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_DESTINATARIO", "QRY_AUX", "Cte_destinatario", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_DESTRAZAO", "QRY_AUX", "Cte_destrazao", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "CTE_DESTCID", "QRY_AUX", "Cte_destcid", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "CTE_DESTUF", "QRY_AUX", "Cte_destuf", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_IDTOMADOR", "QRY_AUX", "Cte_idtomador", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_DESCTOMADOR", "QRY_AUX", "Cte_desctomador", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_TPDF", "QRY_AUX", "Cte_tpdf", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_CFOP", "QRY_AUX", "Cte_cfop", /*Picture*/, 4, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_UFINICIO", "QRY_AUX", "Cte_ufinicio", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_UFFIM", "QRY_AUX", "Cte_uffim", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_PERCICM", "QRY_AUX", "Cte_percicm", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_TRIMP", "QRY_AUX", "Cte_trimp", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_PESOC", "QRY_AUX", "Cte_pesoc", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_PESOR", "QRY_AUX", "Cte_pesor", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_FRETEPESO", "QRY_AUX", "Cte_fretepeso", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_FRETEVALOR", "QRY_AUX", "Cte_fretevalor", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_VLIIMP", "QRY_AUX", "Cte_vliimp", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_PEDAGIO", "QRY_AUX", "Cte_pedagio", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_TAXAS", "QRY_AUX", "Cte_taxas", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_VLFRETE", "QRY_AUX", "Cte_vlfrete", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_BASIMP", "QRY_AUX", "Cte_basimp", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_IMPRETIDO", "QRY_AUX", "Cte_impretido", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_PERCRETIDO", "QRY_AUX", "Cte_percretido", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_SERIEORI", "QRY_AUX", "Cte_serieori", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_DOCORI", "QRY_AUX", "Cte_docori", /*Picture*/, 16, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_CHAVE", "QRY_AUX", "Cte_chave", /*Picture*/, 44, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_FILDOC", "QRY_AUX", "Cte_fildoc", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_QTDCARGA", "QRY_AUX", "Cte_qtdcarga", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_VOLUME", "QRY_AUX", "Cte_volume", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_QTDVOLUM", "QRY_AUX", "Cte_qtdvolum", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_TIPOCTE", "QRY_AUX", "Cte_tipocte", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_VLCARGA", "QRY_AUX", "Cte_vlcarga", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NFE_SEQUEN", "QRY_AUX", "Nfe_sequen", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NFE_SERIE", "QRY_AUX", "Nfe_serie", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NFE_DOC", "QRY_AUX", "Nfe_doc", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NFE_CHAVE", "QRY_AUX", "Nfe_chave", /*Picture*/, 60, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NFE_PES_BRUT", "QRY_AUX", "Nfe_PesBrut", /*Picture*/, 60, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NFE_PES_LIQ", "QRY_AUX", "Nfe_PesLiq", /*Picture*/, 60, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CTE_OBSERV", "QRY_AUX", "Cte_observ", /*Picture*/, 500, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
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
	cQryAux := ""
	cQryAux += " SELECT	GXG.GXG_FILIAL	[FILIAL],"              + STR_PULA
	cQryAux += "        GXG.GXG_NRIMP	[SEQIMPORT], "          + STR_PULA
	cQryAux += "        GXG.GXG_SERDF	[CTE_SERIE], "          + STR_PULA
	cQryAux += "        GXG.GXG_NRDF	[CTE_DOC], "            + STR_PULA
	cQryAux += "        GXG.GXG_DTEMIS	[CTE_EMISSAO], "        + STR_PULA
	cQryAux += "        GXG.GXG_DTENT	[CTE_ENTRADA], "        + STR_PULA
	cQryAux += "        GXG.GXG_DTIMP	[CTE_IMPORTA], "        + STR_PULA
	cQryAux += "        GXG.GXG_EMISDF	[CTE_EMISSOR], "        + STR_PULA
	cQryAux += "        (   "                                   + STR_PULA
	cQryAux += "        SELECT GU3_NMEMIT [RAZAO_SOCIAL] "      + STR_PULA
    cQryAux += "            FROM GU3010 GU3  "      + STR_PULA
    cQryAux += "            WHERE GU3.GU3_FILIAL = '' 	 "      + STR_PULA
    cQryAux += "            AND GU3.GU3_IDFED = GXG.GXG_EMISDF 	 "      + STR_PULA
    cQryAux += "            AND GU3.D_E_L_E_T_ = '' "      + STR_PULA
	cQryAux += "        ) [CTE_EMISRAZAO], "      + STR_PULA
	cQryAux += "        ( "      + STR_PULA
	cQryAux += "        SELECT GU7.GU7_NMCID [CIDADE]  "      + STR_PULA
	cQryAux += "            FROM GU3010 GU3 "      + STR_PULA
	cQryAux += "                INNER JOIN GU7010 GU7  "      + STR_PULA
	cQryAux += "                ON GU7.GU7_FILIAL = GU3.GU3_FILIAL "      + STR_PULA
	cQryAux += "                AND GU7.GU7_NRCID = GU3.GU3_NRCID "      + STR_PULA
	cQryAux += "                AND GU7.D_E_L_E_T_ = GU3.D_E_L_E_T_ "      + STR_PULA
	cQryAux += "        WHERE GU3.GU3_FILIAL = '' "      + STR_PULA
	cQryAux += "        AND GU3.GU3_IDFED = GXG.GXG_EMISDF "      + STR_PULA
	cQryAux += "        AND GU3.D_E_L_E_T_ = '' "      + STR_PULA
	cQryAux += "        )[CTE_EMISCID], "      + STR_PULA
	cQryAux += "        ( "      + STR_PULA
	cQryAux += "        SELECT GU7.GU7_CDUF [ESTADO] "      + STR_PULA
	cQryAux += "            FROM GU3010 GU3 "      + STR_PULA
	cQryAux += "                INNER JOIN GU7010 GU7  "      + STR_PULA
	cQryAux += "                ON GU7.GU7_FILIAL = GU3.GU3_FILIAL "      + STR_PULA
	cQryAux += "                AND GU7.GU7_NRCID = GU3.GU3_NRCID "      + STR_PULA
	cQryAux += "                AND GU7.D_E_L_E_T_ = GU3.D_E_L_E_T_ "      + STR_PULA
	cQryAux += "        WHERE GU3.GU3_FILIAL = '' "      + STR_PULA
	cQryAux += "        AND GU3.GU3_IDFED = GXG.GXG_EMISDF "      + STR_PULA
	cQryAux += "        AND GU3.D_E_L_E_T_ = '' "      + STR_PULA
	cQryAux += "        )[CTE_EMISUF], "      + STR_PULA
	cQryAux += "        GXG.GXG_CDREM	[CTE_REMETENTE], "      + STR_PULA
	cQryAux += "        ( "      + STR_PULA
	cQryAux += "        SELECT GU3_NMEMIT [RAZAO_SOCIAL] FROM GU3010 GU3 WHERE GU3.GU3_FILIAL = '' 	AND GU3.GU3_IDFED = GXG.GXG_CDREM 	AND GU3.D_E_L_E_T_ = '' "      + STR_PULA
	cQryAux += "        ) [CTE_REMRAZAO], "      + STR_PULA
	cQryAux += "        ( "      + STR_PULA
	cQryAux += "        SELECT GU7.GU7_NMCID [CIDADE]  "      + STR_PULA
	cQryAux += "            FROM GU3010 GU3 "      + STR_PULA
	cQryAux += "                INNER JOIN GU7010 GU7  "      + STR_PULA
	cQryAux += "                ON GU7.GU7_FILIAL = GU3.GU3_FILIAL "      + STR_PULA
	cQryAux += "                AND GU7.GU7_NRCID = GU3.GU3_NRCID "      + STR_PULA
	cQryAux += "                AND GU7.D_E_L_E_T_ = GU3.D_E_L_E_T_ "      + STR_PULA
	cQryAux += "        WHERE GU3.GU3_FILIAL = '' "      + STR_PULA
	cQryAux += "        AND GU3.GU3_IDFED = GXG.GXG_CDREM "      + STR_PULA
	cQryAux += "        AND GU3.D_E_L_E_T_ = '' "      + STR_PULA
	cQryAux += "        )[CTE_REMCID], "      + STR_PULA
	cQryAux += "        ( "      + STR_PULA
	cQryAux += "        SELECT GU7.GU7_CDUF [ESTADO]  "      + STR_PULA
	cQryAux += "            FROM GU3010 GU3 "      + STR_PULA
	cQryAux += "                INNER JOIN GU7010 GU7  "      + STR_PULA
	cQryAux += "                ON GU7.GU7_FILIAL = GU3.GU3_FILIAL "      + STR_PULA
	cQryAux += "                AND GU7.GU7_NRCID = GU3.GU3_NRCID "      + STR_PULA
	cQryAux += "                AND GU7.D_E_L_E_T_ = GU3.D_E_L_E_T_ "      + STR_PULA
	cQryAux += "        WHERE GU3.GU3_FILIAL = '' "      + STR_PULA
	cQryAux += "        AND GU3.GU3_IDFED = GXG.GXG_CDREM "      + STR_PULA
	cQryAux += "        AND GU3.D_E_L_E_T_ = '' "      + STR_PULA
	cQryAux += "        )[CTE_REMUF], "      + STR_PULA
	cQryAux += "        GXG.GXG_CDDEST	[CTE_DESTINATARIO], "      + STR_PULA
	cQryAux += "        ( "      + STR_PULA
	cQryAux += "        SELECT GU3_NMEMIT [RAZAO_SOCIAL] FROM GU3010 GU3 WHERE GU3.GU3_FILIAL = '' 	AND GU3.GU3_IDFED = GXG.GXG_CDDEST 	AND GU3.D_E_L_E_T_ = '' "      + STR_PULA
	cQryAux += "        ) [CTE_DESTRAZAO], "      + STR_PULA
	cQryAux += "        ( "      + STR_PULA
	cQryAux += "        SELECT GU7.GU7_NMCID [CIDADE]  "      + STR_PULA
	cQryAux += "            FROM GU3010 GU3 "      + STR_PULA
	cQryAux += "                INNER JOIN GU7010 GU7  "      + STR_PULA
	cQryAux += "                ON GU7.GU7_FILIAL = GU3.GU3_FILIAL "      + STR_PULA
	cQryAux += "                AND GU7.GU7_NRCID = GU3.GU3_NRCID "      + STR_PULA
	cQryAux += "        	    AND GU7.D_E_L_E_T_ = GU3.D_E_L_E_T_ "      + STR_PULA
	cQryAux += "        WHERE GU3.GU3_FILIAL = '' "      + STR_PULA
	cQryAux += "        AND GU3.GU3_IDFED = GXG.GXG_CDDEST "      + STR_PULA
	cQryAux += "        AND GU3.D_E_L_E_T_ = '' "      + STR_PULA
	cQryAux += "	    )[CTE_DESTCID], "      + STR_PULA
	cQryAux += "	    ( "      + STR_PULA
	cQryAux += "		SELECT GU7.GU7_CDUF [ESTADO] "      + STR_PULA
	cQryAux += "			FROM GU3010 GU3 "      + STR_PULA
	cQryAux += "				INNER JOIN GU7010 GU7  "      + STR_PULA
	cQryAux += "				ON GU7.GU7_FILIAL = GU3.GU3_FILIAL "      + STR_PULA
	cQryAux += "				AND GU7.GU7_NRCID = GU3.GU3_NRCID "      + STR_PULA
	cQryAux += "				AND GU7.D_E_L_E_T_ = GU3.D_E_L_E_T_ "      + STR_PULA
	cQryAux += "			WHERE GU3.GU3_FILIAL = '' "      + STR_PULA
	cQryAux += "			AND GU3.GU3_IDFED = GXG.GXG_CDDEST "      + STR_PULA
	cQryAux += "			AND GU3.D_E_L_E_T_ = '' "      + STR_PULA
	cQryAux += "	)[CTE_DESTUF], "      + STR_PULA
	cQryAux += "	GXG.GXG_ZZIDTO	[CTE_IDTOMADOR], "      + STR_PULA
	cQryAux += "	GXG.GXG_ZZDTOM	[CTE_DESCTOMADOR], "      + STR_PULA
	cQryAux += "	GXG.GXG_TPDF	[CTE_TPDF], "      + STR_PULA
	cQryAux += "	GXG.GXG_CFOP	[CTE_CFOP], "      + STR_PULA
	cQryAux += "	GXG.GXG_ZZUFIN	[CTE_UFINICIO], "      + STR_PULA
	cQryAux += "	GXG.GXG_ZZUFFI	[CTE_UFFIM], "      + STR_PULA
	cQryAux += "	GXG.GXG_PCIMP	[CTE_PERCICM], "      + STR_PULA
	cQryAux += "	GXG.GXG_TRBIMP	[CTE_TRIMP], "      + STR_PULA
	cQryAux += "	GXG.GXG_PESOC	[CTE_PESOC], "      + STR_PULA
	cQryAux += "	GXG.GXG_PESOR	[CTE_PESOR], "      + STR_PULA
	cQryAux += "	GXG.GXG_FRPESO	[CTE_FRETEPESO], "      + STR_PULA
	cQryAux += "	GXG.GXG_FRVAL	[CTE_FRETEVALOR], "      + STR_PULA
	cQryAux += "	GXG.GXG_VLIMP	[CTE_VLIIMP], "      + STR_PULA
	cQryAux += "	GXG.GXG_PEDAG	[CTE_PEDAGIO], "      + STR_PULA
	cQryAux += "	GXG.GXG_TAXAS	[CTE_TAXAS], "      + STR_PULA
	cQryAux += "	GXG.GXG_VLDF	[CTE_VLFRETE], "      + STR_PULA
	cQryAux += "	GXG.GXG_BASIMP	[CTE_BASIMP], "      + STR_PULA
	cQryAux += "	GXG.GXG_IMPRET	[CTE_IMPRETIDO], "      + STR_PULA
	cQryAux += "	GXG.GXG_PCRET	[CTE_PERCRETIDO], "      + STR_PULA
	cQryAux += "	GXG.GXG_ORISER	[CTE_SERIEORI], "      + STR_PULA
	cQryAux += "	GXG.GXG_ORINR	[CTE_DOCORI], "      + STR_PULA
	cQryAux += "	GXG.GXG_CTE		[CTE_CHAVE], "      + STR_PULA
	cQryAux += "	GXG.GXG_FILDOC	[CTE_FILDOC], "      + STR_PULA
	cQryAux += "	GXG.GXG_QTDCS	[CTE_QTDCARGA], "      + STR_PULA
	cQryAux += "	GXG.GXG_VOLUM	[CTE_VOLUME], "      + STR_PULA
	cQryAux += "	GXG.GXG_QTVOL	[CTE_QTDVOLUM], "      + STR_PULA
	cQryAux += "	GXG.GXG_TPCTE	[CTE_TIPOCTE], "      + STR_PULA
	cQryAux += "	GXG.GXG_VLCARG	[CTE_VLCARGA], "      + STR_PULA
	cQryAux += "	ISNULL( CONVERT( VARCHAR(6144), CONVERT(VARBINARY(6144), GXG.GXG_OBS)),'') 	[CTE_OBSERV], "      + STR_PULA
	cQryAux += "	GXH.GXH_SEQ		[NFE_SEQUEN], "      + STR_PULA
	cQryAux += "	CASE "      + STR_PULA
	cQryAux += "		WHEN SF2.F2_SERIE <> '' THEN SF2.F2_SERIE "      + STR_PULA
	cQryAux += "		WHEN SF1.F1_SERIE <> '' THEN SF1.F1_SERIE "      + STR_PULA
	cQryAux += "		ELSE 'N.ENCONTRADO' "      + STR_PULA
	cQryAux += "	END AS [NFE_SERIE], "      + STR_PULA
	cQryAux += "	CASE  "      + STR_PULA
	cQryAux += "		WHEN SF2.F2_DOC <> '' THEN SF2.F2_DOC "      + STR_PULA
	cQryAux += "		WHEN SF1.F1_DOC	 <> '' THEN SF1.F1_DOC	 "      + STR_PULA
	cQryAux += "		ELSE 'N.ENCONTRADO' "      + STR_PULA
	cQryAux += "	END AS [NFE_DOC], "      + STR_PULA
	cQryAux += "	GXH_DANFE		[NFE_CHAVE], "      + STR_PULA
	cQryAux += "	CASE "      + STR_PULA
	cQryAux += "		WHEN SF2.F2_PLIQUI <> '' THEN CONVERT(varchar,SF2.F2_PLIQUI) "      + STR_PULA
	cQryAux += "		WHEN SF1.F1_PLIQUI <> '' THEN CONVERT(varchar,SF1.F1_PLIQUI) "      + STR_PULA
	cQryAux += "		ELSE 'N.ENCONTRADO' "      + STR_PULA
	cQryAux += "	END AS [NFE_PES_LIQ], "      + STR_PULA
	cQryAux += "	CASE "      + STR_PULA
	cQryAux += "		WHEN SF2.F2_PBRUTO <> '' THEN CONVERT(varchar,SF2.F2_PBRUTO) "      + STR_PULA
	cQryAux += "		WHEN SF1.F1_PBRUTO <> '' THEN CONVERT(varchar,SF1.F1_PBRUTO) "      + STR_PULA
	cQryAux += "		ELSE 'N.ENCONTRADO' "      + STR_PULA
	cQryAux += "	END AS [NFE_PES_BRUT] "      + STR_PULA
	cQryAux += "FROM GXG010 GXG  "		        + STR_PULA
	cQryAux += "	LEFT JOIN GXH010 GXH  "    + STR_PULA
	cQryAux += "		ON GXG.GXG_FILIAL = GXH.GXH_FILIAL"	    + STR_PULA
	cQryAux += "		AND GXG.GXG_NRIMP = GXH_NRIMP"		    + STR_PULA
	cQryAux += "		AND GXG.D_E_L_E_T_ = GXH.D_E_L_E_T_"    + STR_PULA
	cQryAux += "		AND GXH.GXH_DANFE <> ''"	+ STR_PULA
	cQryAux += "	 LEFT JOIN SF2010 SF2  "	    + STR_PULA
	cQryAux += "		ON  GXH.GXH_DANFE = SF2.F2_CHVNFE"	    + STR_PULA
	cQryAux += "		AND GXH.D_E_L_E_T_ = SF2.D_E_L_E_T_"	+ STR_PULA
	cQryAux += "	 LEFT JOIN SF1010 SF1  "	    + STR_PULA
	cQryAux += "		ON  GXH.GXH_DANFE = SF1.F1_CHVNFE"	    + STR_PULA
	cQryAux += "		AND GXH.D_E_L_E_T_ = SF1.D_E_L_E_T_"	+ STR_PULA
	cQryAux += "WHERE GXG_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'"		+ STR_PULA
	cQryAux += "AND GXG_DTEMIS BETWEEN '" +  DtoS(MV_PAR03) + "' AND '" +  DtoS(MV_PAR04) + "'"		+ STR_PULA
	cQryAux += "AND GXG.D_E_L_E_T_ = ''"		                + STR_PULA
	cQryAux += "ORDER BY GXG.GXG_FILIAL, GXG_DTEMIS, GXG_NRDF, GXG_SERDF,GXH_SEQ"		+ STR_PULA
	cQryAux := ChangeQuery(cQryAux)
	
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	TCSetField("QRY_AUX", "CTE_EMISSAO", "D")
	TCSetField("QRY_AUX", "CTE_ENTRADA", "D")
	TCSetField("QRY_AUX", "CTE_IMPORTA", "D")

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
