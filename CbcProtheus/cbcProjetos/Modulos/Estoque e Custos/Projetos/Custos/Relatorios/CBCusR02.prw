//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} CBCusR02
Relat�rio - Conf. Valor Vendas X Custos   
@author zReport
@since 11/04/2017
@version 1.0
	@example
	u_CBCusR02()
	@obs Fun��o gerada pelo zReport()
/*/
	
User Function CBCusR02()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	
	//Defini��es da pergunta
	cPerg := "CDCUSR01  "
	
	//Se a pergunta n�o existir, zera a vari�vel
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	If ! SX1->(DbSeek(cPerg))
		cPerg := Nil
	EndIf
	
	//Cria as defini��es do relat�rio
	oReport := fReportDef()
	
	//Ser� enviado por e-Mail?
	If lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail := cPara
		oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
	//Sen�o, mostra a tela
	Else
		oReport:PrintDialog()
	EndIf
	
	RestArea(aArea)
Return
	
/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Desc:  Fun��o que monta a defini��o do relat�rio                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oBreak := Nil
	
	//Cria��o do componente de impress�o
	oReport := TReport():New(	"CBCusR02",;		//Nome do Relat�rio
								"Conf. Valor Vendas X Custos",;		//T�tulo
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, ser� impresso uma p�gina com os par�metros, conforme privil�gio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de c�digo que ser� executado na confirma��o da impress�o
								)		//Descri��o
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetPortrait()
	
	//Criando a se��o de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a se��o pertence
									"Dados",;		//Descri��o da se��o
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira ser� considerada como principal da se��o
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores ser�o impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relat�rio
	TRCell():New(oSectDad, "FILIAL", "QRY_AUX", "Filial", /*Picture*/, 11, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CLIENTE", "QRY_AUX", "Cliente", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NF", "QRY_AUX", "Nf", /*Picture*/, 11, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ITEM", "QRY_AUX", "Item", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "COD_PROD", "QRY_AUX", "Cod_prod", /*Picture*/, 19, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PRODUTO", "QRY_AUX", "Produto", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "QTDE", "QRY_AUX", "Qtde", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PRECO_UNIT", "QRY_AUX", "Preco_unit", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CUSTO_UNIT", "QRY_AUX", "Custo_unit", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TOTAL_VENDA", "QRY_AUX", "Total_venda", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TOTAL_CUSTO", "QRY_AUX", "Total_custo", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DIF_VENDA_CUSTO", "QRY_AUX", "Dif_venda_custo", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Fun��o que imprime o relat�rio                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as se��es do relat�rio
	oSectDad := oReport:Section(1)
	
	// faz as perguntas sem abrir a tela para o usu�rio
    Pergunte(cPerg,.F.)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT"		+ STR_PULA
	cQryAux += "	CASE"		+ STR_PULA
	cQryAux += "		WHEN D2_FILIAL = '01'"		+ STR_PULA
	cQryAux += "			THEN 'ITU'"		+ STR_PULA
	cQryAux += "		WHEN D2_FILIAL = '02'"		+ STR_PULA
	cQryAux += "			THEN 'TRES LAGOAS'"		+ STR_PULA
	cQryAux += "		ELSE 'N/I'"		+ STR_PULA
	cQryAux += "	END					FILIAL,"		+ STR_PULA
	cQryAux += "	A1_NREDUZ			CLIENTE,"		+ STR_PULA
	cQryAux += "	'['+D2_DOC+']'		NF,"		+ STR_PULA
	cQryAux += "	D2_ITEM				ITEM,"		+ STR_PULA
	cQryAux += "	'['+D2_COD+']'		COD_PROD,"		+ STR_PULA
	cQryAux += "	B1_DESC				PRODUTO,"		+ STR_PULA
	cQryAux += "	D2_QUANT			QTDE,"		+ STR_PULA
	cQryAux += "	D2_PRCVEN			PRECO_UNIT,"		+ STR_PULA
	cQryAux += "	D2_CUSTO1/D2_QUANT	CUSTO_UNIT,"		+ STR_PULA
	cQryAux += "	D2_TOTAL			TOTAL_VENDA,"		+ STR_PULA
	cQryAux += "	D2_CUSTO1			TOTAL_CUSTO,"		+ STR_PULA
	cQryAux += "	D2_TOTAL-D2_CUSTO1	DIF_VENDA_CUSTO"		+ STR_PULA
	cQryAux += "FROM SD2010 D2"		+ STR_PULA
	cQryAux += "INNER JOIN SF4010 F4"		+ STR_PULA
	cQryAux += "	ON ''				= F4_FILIAL"		+ STR_PULA
	cQryAux += "	AND D2_TES			= F4_CODIGO"		+ STR_PULA
	cQryAux += "	AND D2.D_E_L_E_T_	= F4.D_E_L_E_T_"		+ STR_PULA
	cQryAux += "INNER JOIN SA1010 A1"		+ STR_PULA
	cQryAux += "	ON ''				= A1_FILIAL"		+ STR_PULA
	cQryAux += "	AND D2_CLIENTE		= A1_COD"		+ STR_PULA
	cQryAux += "	AND D2_LOJA			= A1_LOJA"		+ STR_PULA
	cQryAux += "	AND D2.D_E_L_E_T_	= A1.D_E_L_E_T_"		+ STR_PULA
	cQryAux += "INNER JOIN SB1010 B1"		+ STR_PULA
	cQryAux += "	ON ''				= B1_FILIAL"		+ STR_PULA
	cQryAux += "	AND D2_COD			= B1_COD"		+ STR_PULA
	cQryAux += "	AND D2.D_E_L_E_T_	= B1.D_E_L_E_T_"		+ STR_PULA
	cQryAux += "WHERE"		+ STR_PULA
	cQryAux += "	D2_FILIAL IN ('01','02')"		+ STR_PULA
	cQryAux += "	AND D2_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'"		+ STR_PULA
	cQryAux += "	AND D2_TIPO = 'N'"		+ STR_PULA
	cQryAux += "	AND D2.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "	AND F4_ESTOQUE = 'S'"		+ STR_PULA
	cQryAux += "	AND F4_PODER3 = 'N'"		+ STR_PULA
	cQryAux += "	AND F4_TRANFIL <> '1'"		+ STR_PULA
	cQryAux += "ORDER BY D2_FILIAL, D2_DOC, D2_ITEM"		+ STR_PULA
	cQryAux := ChangeQuery(cQryAux)
	
	//Executando consulta e setando o total da r�gua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	
	//Imprimindo
	oReport:SetMsgPrint("Imprimindo ...")
	
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		//Incrementando a r�gua
		oReport:IncMeter()
		
		//Imprimindo a linha atual
		oSectDad:PrintLine()
		
		QRY_AUX->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())
	
	RestArea(aArea)
Return