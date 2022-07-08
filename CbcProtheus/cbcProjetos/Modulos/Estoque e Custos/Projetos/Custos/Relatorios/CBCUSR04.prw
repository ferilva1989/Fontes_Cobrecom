//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} CBCUSR04
Relatório - Conf. de Acertos Valor Estoque
@author zReport
@since 11/04/2017
@version 1.0
	@example
	u_CBCUSR04()
	@obs Função gerada pelo zReport()
/*/
	
User Function CBCUSR04()
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
	oReport := TReport():New(	"CBCUSR04",;		//Nome do Relatório
								"Conf. de Acertos Valor Estoque",;		//Título
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
	TRCell():New(oSectDad, "FILIAL", "QRY_AUX", "Filial", /*Picture*/, 11, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TIPO_PRODUTO", "QRY_AUX", "Tipo_produto", /*Picture*/, 55, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "EMISSAO", "QRY_AUX", "Data", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CF", "QRY_AUX", "Codigo", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PRODUTO", "QRY_AUX", "Produto", /*Picture*/, 72, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_CUSTO", "QRY_AUX", "Vl_custo", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "HISTORICO", "QRY_AUX", "Historico", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NUMSEQ", "QRY_AUX", "Numseq", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
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
	
	// faz as perguntas sem abrir a tela para o usuário
    Pergunte(cPerg,.F.)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT"		+ STR_PULA
	cQryAux += "	CASE"		+ STR_PULA
	cQryAux += "		WHEN D3_FILIAL = '01'"		+ STR_PULA
	cQryAux += "			THEN 'ITU'"		+ STR_PULA
	cQryAux += "		WHEN D3_FILIAL = '02'"		+ STR_PULA
	cQryAux += "			THEN 'TRES LAGOAS'"		+ STR_PULA
	cQryAux += "		WHEN D3_FILIAL = '03'"		+ STR_PULA
	cQryAux += "			THEN 'POUSO ALEGRE'"		+ STR_PULA
	cQryAux += "		ELSE 'N/I'"		+ STR_PULA
	cQryAux += "	END																						FILIAL,"		+ STR_PULA
	cQryAux += "	X5_DESCRI																				TIPO_PRODUTO,"		+ STR_PULA
	cQryAux += "	SUBSTRING(D3_EMISSAO,1,4)+'-'+SUBSTRING(D3_EMISSAO,5,2)+'-'+SUBSTRING(D3_EMISSAO,7,2)	EMISSAO,"		+ STR_PULA
	cQryAux += "	D3_CF																					CF,"		+ STR_PULA
	cQryAux += "	'[ '+D3_COD+' ] '+B1_DESC																PRODUTO,"		+ STR_PULA
	cQryAux += "	D3_CUSTO1																				VL_CUSTO,"		+ STR_PULA
	cQryAux += "	D3_HIST																					HISTORICO,"		+ STR_PULA
	cQryAux += "	D3_NUMSEQ																				NUMSEQ"		+ STR_PULA
	cQryAux += "FROM SD3010 D3"		+ STR_PULA
	cQryAux += "INNER JOIN SB1010 B1"		+ STR_PULA
	cQryAux += "	ON ''				= B1_FILIAL"		+ STR_PULA
	cQryAux += "	AND D3_COD			= B1_COD"		+ STR_PULA
	cQryAux += "	AND D3.D_E_L_E_T_	= B1.D_E_L_E_T_"		+ STR_PULA
	cQryAux += "INNER JOIN SX5010 X5"		+ STR_PULA
	cQryAux += "	ON D3_FILIAL		= X5_FILIAL"		+ STR_PULA
	cQryAux += "	AND '02'			= X5_TABELA"		+ STR_PULA
	cQryAux += "	AND D3_TIPO			= X5_CHAVE"		+ STR_PULA
	cQryAux += "	AND D3.D_E_L_E_T_	= X5.D_E_L_E_T_"		+ STR_PULA
	cQryAux += "WHERE"		+ STR_PULA
	cQryAux += "	D3_FILIAL IN ('01','02','03')"		+ STR_PULA
	cQryAux += "	AND D3_EMISSAO >= '" + DtoS(MV_PAR01) + "'"		+ STR_PULA
	cQryAux += "	AND D3_EMISSAO <= '" + DtoS(MV_PAR02) + "'"		+ STR_PULA
	cQryAux += "	AND D3_QUANT = 0"		+ STR_PULA
	cQryAux += "	AND D3_ESTORNO = ''"		+ STR_PULA
	cQryAux += "	AND D3.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "ORDER BY D3_FILIAL, D3_TIPO"		+ STR_PULA
	cQryAux := ChangeQuery(cQryAux)
	
	//Executando consulta e setando o total da régua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	
	oReport:SetMsgPrint("Imprimindo ...")
	
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		//Incrementando a régua
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		QRY_AUX->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())
	
	RestArea(aArea)
Return
