//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} CBCUSR05
Relatório - Conf. Contas Sem CC           
@author zReport
@since 11/05/2017
@version 1.0
	@example
	u_CBCUSR05()
	@obs Função gerada pelo zReport()
/*/
	
User Function CBCUSR05()
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
	oReport := TReport():New(	"CBCUSR05",;		//Nome do Relatório
								"Conf. Contas Sem CC",;		//Título
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
	TRCell():New(oSectDad, "DATA", "QRY_AUX", "Data", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CONTA_CREDITO", "QRY_AUX", "Conta_credito", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CONTA_DEBITO", "QRY_AUX", "Conta_debito", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CC_CREDITO", "QRY_AUX", "Cc_credito", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CC_DEBITO", "QRY_AUX", "Cc_debito", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VALOR", "QRY_AUX", "Valor", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "HISTORICO", "QRY_AUX", "Historico", /*Picture*/, 51, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
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
	cQryAux += "SELECT CT2_FILIAL FILIAL,"		+ STR_PULA
	cQryAux += "		CT2_DATA DATA,"		+ STR_PULA
	cQryAux += "		CT2_CREDIT CONTA_CREDITO,"		+ STR_PULA
	cQryAux += "		CT2_DEBITO CONTA_DEBITO,"		+ STR_PULA
	cQryAux += "		CT2_CCC CC_CREDITO,"		+ STR_PULA
	cQryAux += "		CT2_CCD CC_DEBITO,"		+ STR_PULA
	cQryAux += "		CT2_VALOR VALOR,"		+ STR_PULA
	cQryAux += "		CT2_HIST HISTORICO"		+ STR_PULA
	cQryAux += "FROM CT2010"		+ STR_PULA
	cQryAux += "WHERE CT2_FILIAL IN ('01','02')"		+ STR_PULA
	cQryAux += "AND CT2_CREDIT BETWEEN '412020001' AND '412020097'"		+ STR_PULA
	cQryAux += "AND CT2_CREDIT BETWEEN '511020001' AND '511020097'"		+ STR_PULA
	cQryAux += "AND CT2_CCC = ''"		+ STR_PULA
	cQryAux += "AND CT2_DATA BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' " + STR_PULA
	cQryAux += "AND D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND CT2_TPSALD = '1'"		+ STR_PULA
	cQryAux += "UNION "		+ STR_PULA
	cQryAux += "SELECT CT2_FILIAL FILIAL,"		+ STR_PULA
	cQryAux += "		CT2_DATA DATA,"		+ STR_PULA
	cQryAux += "		CT2_CREDIT CONTA_CREDITO,"		+ STR_PULA
	cQryAux += "		CT2_DEBITO CONTA_DEBITO,"		+ STR_PULA
	cQryAux += "		CT2_CCC CC_CREDITO,"		+ STR_PULA
	cQryAux += "		CT2_CCD CC_DEBITO,"		+ STR_PULA
	cQryAux += "		CT2_VALOR VALOR,"		+ STR_PULA
	cQryAux += "		CT2_HIST HISTORICO"		+ STR_PULA
	cQryAux += "FROM CT2010"		+ STR_PULA
	cQryAux += "WHERE CT2_FILIAL IN ('01','02')"		+ STR_PULA
	cQryAux += "AND CT2_DEBITO BETWEEN '412020001' AND '412020097'"		+ STR_PULA
	cQryAux += "AND CT2_DEBITO BETWEEN '511020001' AND '511020097'"		+ STR_PULA
	cQryAux += "AND CT2_CCD = ''"		+ STR_PULA
	cQryAux += "AND CT2_DATA BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' " + STR_PULA
	cQryAux += "AND D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "AND CT2_TPSALD = '1'"		+ STR_PULA
	cQryAux += "ORDER BY CT2_FILIAL, CT2_DATA"		+ STR_PULA
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