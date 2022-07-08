//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} cbcRServ
Relatório - Relatorio Nfs de Serviços     
@author zReport, juliana.leme
@since 10/01/2019
@version 1.0
	@example
	u_cbcRServ()
	@obs Função gerada pelo zReport()
/*/
	
User Function cbcRServ()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	
	//Definições da pergunta
	cPerg := "CBCRELIMP "
	
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
//TODO Função que monta a definição do relatório  .
@author juliana.leme
@since 11/01/2019
@version 1.0
@type function
/*/
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil

	//Criação do componente de impressão
	oReport := TReport():New(	"cbcRServ",;		//Nome do Relatório
								"Relatorio Nfs de Serviços",;		//Título
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
	TRCell():New(oSectDad, "PRODUTO", "QRY_AUX", "Produto", /*Picture*/, 17, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DESCRICAO", "QRY_AUX", "Descricao", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_TOTAL", "QRY_AUX", "Vl_total", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CFOP", "QRY_AUX", "Cfop", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "COD_FORN", "QRY_AUX", "Cod_forn", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NOME_FORN", "QRY_AUX", "Nome_forn", /*Picture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CNPJ_FORN", "QRY_AUX", "CNPJ_Forn", /*Picture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SERIE_DOC", "QRY_AUX", "Serie_doc", /*Picture*/, 13, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DT_EMISSAO", "QRY_AUX", "Dt_emissao", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DT_DIGITACAO", "QRY_AUX", "Dt_digitacao", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "COD_SERVICO", "QRY_AUX", "Cod_servico", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ALQ_IRRF", "QRY_AUX", "Alq_irrf", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_IRRF", "QRY_AUX", "Vl_irrf", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ALQ_ISS", "QRY_AUX", "Alq_iss", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_ISS", "QRY_AUX", "Vl_iss", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ALQ_INSS", "QRY_AUX", "Alq_inss", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_INSS", "QRY_AUX", "Vl_inss", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ALQ_PIS", "QRY_AUX", "Alq_pis", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_PIS", "QRY_AUX", "Vl_pis", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ALQ_COF", "QRY_AUX", "Alq_cof", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_COF", "QRY_AUX", "Vl_cof", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "BASE_CSLL", "QRY_AUX", "Base_csll", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ALQ_CSLL", "QRY_AUX", "Alq_csll", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_CSLL", "QRY_AUX", "Vl_csll", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
Return oReport
	
/*/{Protheus.doc} fRepPrint
//TODO Função que imprime o relatório .
@author juliana.leme
@since 11/01/2019
@version 1.0
@param oReport, object, descricao
@type function
/*/
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	local aCfop		:= {}

	If !Empty(MV_PAR01) .OR. !Empty(MV_PAR02)
		//Pegando as seções do relatório
		oSectDad := oReport:Section(1)
		aCfop := StrTokArr(MV_PAR03,";" )
		
		//Montando consulta de dados
		cQryAux := ""
		cQryAux += "SELECT D1_FILIAL FILIAL,"		+ STR_PULA
		cQryAux += "		D1_COD PRODUTO,"		+ STR_PULA
		cQryAux += "		D1_DESCRI DESCRICAO,"		+ STR_PULA
		cQryAux += "		D1_TOTAL VL_TOTAL,"		+ STR_PULA
		cQryAux += "		D1_CF CFOP,"		+ STR_PULA
		cQryAux += "		D1_FORNECE+'/'+D1_LOJA COD_FORN,"		+ STR_PULA
		cQryAux += "		A2_NOME NOME_FORN,"		+ STR_PULA
		cQryAux += "		A2_CGC CNPJ_FORN,"		+ STR_PULA
		cQryAux += "		D1_SERIE+'/'+D1_DOC SERIE_DOC,"		+ STR_PULA
		cQryAux += "		SUBSTRING(D1_EMISSAO,7,2)+'/'+SUBSTRING(D1_EMISSAO,5,2)+'/'+SUBSTRING(D1_EMISSAO,1,4) DT_EMISSAO,"		+ STR_PULA
		cQryAux += "		SUBSTRING(D1_DTDIGIT,7,2)+'/'+SUBSTRING(D1_DTDIGIT,5,2)+'/'+SUBSTRING(D1_DTDIGIT,1,4) DT_DIGITACAO,"		+ STR_PULA
		cQryAux += "		D1_CODISS COD_SERVICO,"		+ STR_PULA
		cQryAux += "		D1_ALIQIRR ALQ_IRRF,"		+ STR_PULA
		cQryAux += "		D1_VALIRR VL_IRRF,"		+ STR_PULA
		cQryAux += "		D1_ALIQISS ALQ_ISS,"		+ STR_PULA
		cQryAux += "		D1_VALISS VL_ISS,"		+ STR_PULA
		cQryAux += "		D1_ALIQINS ALQ_INSS,"		+ STR_PULA
		cQryAux += "		D1_VALINS VL_INSS,"		+ STR_PULA
		cQryAux += "		D1_ALQPIS ALQ_PIS,"		+ STR_PULA
		cQryAux += "		D1_VALPIS VL_PIS,"		+ STR_PULA
		cQryAux += "		D1_ALQCOF ALQ_COF,"		+ STR_PULA
		cQryAux += "		D1_VALCOF VL_COF,"		+ STR_PULA
		cQryAux += "		D1_BASECSL BASE_CSLL,"		+ STR_PULA
		cQryAux += "		D1_ALQCSL ALQ_CSLL,"		+ STR_PULA
		cQryAux += "		D1_VALCSL VL_CSLL"		+ STR_PULA
		cQryAux += "FROM SD1010"		+ STR_PULA
		cQryAux += "	INNER JOIN SA2010 ON A2_FILIAL = '' AND D1_FORNECE = A2_COD AND D1_LOJA = A2_LOJA"		+ STR_PULA
		cQryAux += "WHERE D1_FILIAL BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' "		+ STR_PULA
		cQryAux += "AND D1_EMISSAO BETWEEN '" +DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "' "		+ STR_PULA
		cQryAux += "AND D1_CF IN ("
		For n := 1 to len(aCfop)
			cQryAux += "'" + Alltrim(aCfop[n]) + "' "
			if n<>len(aCfop)
				cQryAux += "," 
			endIf
		Next
		cQryAux += ")"		+ STR_PULA
		cQryAux += "AND SD1010.D_E_L_E_T_ = ''"		+ STR_PULA
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
			oReport:SetMsgPrint("Imprimindo aguarde, registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
			oReport:IncMeter()
			
			//Imprimindo a linha atual
			oSectDad:PrintLine()
			
			QRY_AUX->(DbSkip())
		EndDo
		oSectDad:Finish()
		QRY_AUX->(DbCloseArea())
	EndIf
	
	RestArea(aArea)
Return