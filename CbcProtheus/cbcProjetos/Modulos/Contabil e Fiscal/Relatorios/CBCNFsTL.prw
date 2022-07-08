//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} CBCNFsTL
Relação de Notas Fiscais de Três Lagoas com filtro por CFOP e Bitola
@author zReport
@since 06/04/18
@version 1.0
	@example
	u_CBCNFsTL()
	@obs Função gerada pelo zReport()
/*/
	
User Function CBCNFsTL()
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
	oReport := TReport():New(	"CBCNFsTL",;		//Nome do Relatório
								"Rel.NFs TL por CFOPs e Bitolas",;		//Título
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
	TRCell():New(oSectDad, "NF_ITEM", "QRY_AUX", "Nf_item", /*Picture*/, 12, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "EMISSAO", "QRY_AUX", "Emissao", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PRODUTO", "QRY_AUX", "Produto", /*Picture*/, 17, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DESCRICAO", "QRY_AUX", "Descricao", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "BITOLA", "QRY_AUX", "Bitola", /*Picture*/, 7, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CFOP", "QRY_AUX", "Cfop", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_TOTAL", "QRY_AUX", "Vl_total", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "BASE_ICMS", "QRY_AUX", "Base_icms", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_ICMS", "QRY_AUX", "Vl_icms", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
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
	cQryAux += "SELECT D2.D2_DOC+'-'+D2.D2_ITEM	NF_ITEM,"		+ STR_PULA
	cQryAux += "SUBSTRING(D2.D2_EMISSAO,1,4)+'-'+SUBSTRING(D2.D2_EMISSAO,5,2)+'-'+SUBSTRING(D2.D2_EMISSAO,7,2)	EMISSAO,"		+ STR_PULA
	cQryAux += "D2.D2_COD PRODUTO,"		+ STR_PULA
	cQryAux += "D2.D2_DESCRI DESCRICAO,"		+ STR_PULA
	cQryAux += "CASE"		+ STR_PULA
	cQryAux += "WHEN B1.B1_BITOLA = '04'"		+ STR_PULA
	cQryAux += "THEN '1,5 MM'"		+ STR_PULA
	cQryAux += "WHEN B1.B1_BITOLA = '05'"		+ STR_PULA
	cQryAux += "THEN '2,5 MM'"		+ STR_PULA
	cQryAux += "WHEN B1.B1_BITOLA = '06'"		+ STR_PULA
	cQryAux += "THEN '4,0 MM'"		+ STR_PULA
	cQryAux += "WHEN B1.B1_BITOLA = '07'"		+ STR_PULA
	cQryAux += "THEN '6,0 MM'"		+ STR_PULA
	cQryAux += "WHEN B1.B1_BITOLA = '08'"		+ STR_PULA
	cQryAux += "THEN '10,0 MM'"		+ STR_PULA
	cQryAux += "ELSE"		+ STR_PULA
	cQryAux += "'N/A'"		+ STR_PULA
	cQryAux += "END	BITOLA,"		+ STR_PULA
	cQryAux += "D2.D2_CF CFOP, 	"		+ STR_PULA
	cQryAux += "D2.D2_TOTAL	VL_TOTAL,"		+ STR_PULA
	cQryAux += "D2.D2_BASEICM BASE_ICMS,"		+ STR_PULA
	cQryAux += "D2.D2_VALICM VL_ICMS"		+ STR_PULA
	cQryAux += "FROM SD2010 D2"		+ STR_PULA
	cQryAux += "INNER JOIN SB1010 B1 ON ''	= B1.B1_FILIAL AND D2.D2_COD = B1.B1_COD AND D2.D_E_L_E_T_ = B1.D_E_L_E_T_"		+ STR_PULA
	cQryAux += "WHERE D2.D2_FILIAL	= '02'"		+ STR_PULA
	cQryAux += "AND D2.D2_EMISSAO BETWEEN '"+ DtoS(MV_PAR01) + "' AND '"+ DtoS(MV_PAR02)+"'"		+ STR_PULA
	cQryAux += "AND D2.D2_CF IN ('5101','5401')"		+ STR_PULA
	cQryAux += "AND B1.B1_BITOLA	IN ('04','05','06','07')"		+ STR_PULA
	cQryAux += "AND D2.D_E_L_E_T_ = ''"		+ STR_PULA
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
