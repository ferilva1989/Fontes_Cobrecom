//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} cbcRCte
Relatório - CTes Por periodo              
@author zReport
@since 26/02/2019
@version 1.0
	@example
	u_cbcRCte()
	@obs Função gerada pelo zReport()
/*/
	
User Function cbcRCte()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	
	//Definições da pergunta
	cPerg := "CBCRCTE   "
	
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
//TODO Função que monta a definição do relatório.
@author juliana.leme
@since 27/02/2019
@version 1.0
@type function
/*/
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oBreak := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"cbcRCte",;		//Nome do Relatório
								"CTes Por periodo",;		//Título
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
	TRCell():New(oSectDad, "DATA_EMISSAO", "QRY_AUX", "Data_emissao", /*Picture*/, 7, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CLIENTE_LOJA", "QRY_AUX", "Cliente_loja", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CLIENTE_NOME", "QRY_AUX", "Cliente_nome", /*Picture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CLIENTE_CNPJ", "QRY_AUX", "Cliente_cnpj", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TOTAL", "QRY_AUX", "Total", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport
		
/*/{Protheus.doc} fRepPrint
//TODO Função que imprime o relatório   .
@author juliana.leme
@since 27/02/2019
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
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT SUBSTRING(FT_EMISSAO,5,2)+'/'+SUBSTRING(FT_EMISSAO,1,4) DATA_EMISSAO,"		+ STR_PULA
	cQryAux += "	FT_CLIEFOR + '/' + FT_LOJA CLIENTE_LOJA,"		+ STR_PULA
	cQryAux += "	A2_NOME CLIENTE_NOME,"		+ STR_PULA
	cQryAux += "	A2_CGC CLIENTE_CNPJ,"		+ STR_PULA
	cQryAux += "	SUM(FT_TOTAL) TOTAL"		+ STR_PULA
	cQryAux += "FROM SFT010 FT "		+ STR_PULA
	cQryAux += "	INNER JOIN SA2010 A2 "		+ STR_PULA
	cQryAux += "		ON A2_FILIAL = '' "		+ STR_PULA
	cQryAux += "		AND A2_COD = FT_CLIEFOR "		+ STR_PULA
	cQryAux += "		AND A2_LOJA = FT_LOJA "		+ STR_PULA
	cQryAux += "		AND A2.R_E_C_N_O_ = A2.R_E_C_N_O_ "		+ STR_PULA
	cQryAux += "		AND A2.D_E_L_E_T_ = FT.D_E_L_E_T_"		+ STR_PULA
	cQryAux += "WHERE FT_FILIAL = '" + FwFilial() + "'"		+ STR_PULA
	cQryAux += "AND FT_TIPOMOV IN ('S','E') "		+ STR_PULA
	cQryAux += "AND FT_EMISSAO BETWEEN '" + DtoS(MV_PAR01) + "' AND '" + DtoS(MV_PAR02) + "'" + STR_PULA
	cQryAux += "AND FT_ESPECIE  = 'CTE'"		+ STR_PULA
	cQryAux += "AND FT.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "GROUP BY SUBSTRING(FT_EMISSAO,5,2)+'/'+SUBSTRING(FT_EMISSAO,1,4),"	+ STR_PULA
	cQryAux += "FT_CLIEFOR,FT_LOJA,A2_NOME,A2_CGC "		+ STR_PULA
	cQryAux += "ORDER BY SUBSTRING(FT_EMISSAO,5,2)+'/'+SUBSTRING(FT_EMISSAO,1,4) , A2_NOME"		+ STR_PULA
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