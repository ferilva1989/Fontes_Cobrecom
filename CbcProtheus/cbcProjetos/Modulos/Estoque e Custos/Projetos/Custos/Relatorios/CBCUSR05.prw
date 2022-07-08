//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} CBCUSR05
Relat�rio - Conf. Contas Sem CC           
@author zReport
@since 11/05/2017
@version 1.0
	@example
	u_CBCUSR05()
	@obs Fun��o gerada pelo zReport()
/*/
	
User Function CBCUSR05()
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
	oReport := TReport():New(	"CBCUSR05",;		//Nome do Relat�rio
								"Conf. Contas Sem CC",;		//T�tulo
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
	
	//Executando consulta e setando o total da r�gua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	
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