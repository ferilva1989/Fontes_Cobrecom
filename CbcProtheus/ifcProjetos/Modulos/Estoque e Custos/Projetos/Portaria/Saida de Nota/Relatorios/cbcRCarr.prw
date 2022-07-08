//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} cbcRCarr
Relatório - Relatório de Carregamentos    
@author zReport
@since 07/03/19
@version 1.0
	@example
	u_cbcRCarr()
	@obs Função gerada pelo zReport()
/*/
	
user function cbcRCarr()
	local aArea   := GetArea()
	local oReport
	local lEmail  := .F.
	local cPara   := ""
	local aPergs  := {}
	local aRet	  := {}
	local cFilAtu := FWFilialName()
	private cPerg := ""
	
	//Cria as definições do relatório
	oReport := fReportDef()
	
	aAdd( aPergs ,{1,"da NF: ",Space(TamSX3("F2_DOC")[1]),"@!",'.T.',,'.T.',80,.F.})
	aAdd( aPergs ,{1,"até NF: ",Replicate("Z", TamSX3("F2_DOC")[1]), "@!",'.T.',,'.T.',80,.F.})
	aAdd( aPergs ,{1,"da Série: ",Space(TamSX3("F2_SERIE")[1]),"@!",'.T.',,'.T.',80,.F.})
	aAdd( aPergs ,{1,"até Série: ",Replicate("Z", TamSX3("F2_SERIE")[1]), "@!",'.T.',,'.T.',80,.F.})  
	aAdd( aPergs ,{1,"da Dt. de Emissão: ",dDataBase,PesqPict("SF2", "F2_EMISSAO"),'.T.',,'.T.',80,.F.})
	aAdd( aPergs ,{1,"até Dt. de Emissão: ",dDataBase,PesqPict("SF2", "F2_EMISSAO"),'.T.',,'.T.',80,.F.})
	aAdd( aPergs ,{2,"Filial Saída: ",'Filial Saída', {'Todas',cFilAtu}, 80,'.T.',.T.})
	aAdd( aPergs ,{2,"Tipo: ",'Todas', {'Todas','Entregues', 'Não Entregues'}, 80,'.T.',.T.}) 	
		
	if !ParamBox(aPergs,"Parâmetros do Relatório",aRet)
		Alert("Relatório Cancelado!")
		return(nil)
	endif
	
	//Será enviado por e-Mail?
	if lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail := cPara
		oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
	//Senão, mostra a tela
	else
		oReport:PrintDialog()
	endif
	
	RestArea(aArea)
return(nil)
	
/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Desc:  Função que monta a definição do relatório                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oBreak := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"cbcRCarr",;		//Nome do Relatório
								"Relatório de Carregamentos",;		//Título
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
	TRCell():New(oSectDad, "DOCTO", "QRY_AUX", "Docto", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DTFATUR", "QRY_AUX", "Dt.Fatur", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "HRFATUR", "QRY_AUX", "Hr.Fatur", /*Picture*/, 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CLIENTE", "QRY_AUX", "Cliente", /*Picture*/, 60, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "FILSAIDA", "QRY_AUX", "Fil.Saida", /*Picture*/, 11, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DTENTREG", "QRY_AUX", "Dt.Entreg", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "HRENTREG", "QRY_AUX", "Hr.Entreg", /*Picture*/, 4, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TRANSPORTADORA", "QRY_AUX", "Transportadora", /*Picture*/, 47, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "MOTORISTA", "QRY_AUX", "Motorista", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CARREGADOR", "QRY_AUX", "Carregador", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
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
	cQryAux += " SELECT SF2.F2_DOC + ' / ' + SF2.F2_SERIE AS [DOCTO], "		+ STR_PULA
	cQryAux += "		SF2.F2_EMISSAO AS [DTFATUR], "		+ STR_PULA
	cQryAux += "		SF2.F2_HORA AS [HRFATUR], "		+ STR_PULA
	cQryAux += "		SA1.A1_COD + '-' + SA1.A1_LOJA + ' ' + SA1.A1_NOME AS [CLIENTE], "		+ STR_PULA
	cQryAux += "		CASE  "		+ STR_PULA
	cQryAux += "            WHEN SZF.ZF_FILSAI = '01' "		+ STR_PULA
	cQryAux += "				THEN '01 - MATRIZ' "		+ STR_PULA
	cQryAux += "            WHEN SZF.ZF_FILSAI = '02' "		+ STR_PULA
	cQryAux += "				THEN '02 - FILIAL' "		+ STR_PULA
	cQryAux += "			WHEN SZF.ZF_FILIAL = '01' "		+ STR_PULA
	cQryAux += "				THEN '01 - MATRIZ' " 		+ STR_PULA
	cQryAux += "            WHEN SZF.ZF_FILIAL = '02' "		+ STR_PULA
	cQryAux += "				THEN '02 - FILIAL' "		+ STR_PULA
	cQryAux += "			ELSE ISNULL(SZF.ZF_FILIAL, '-') "		+ STR_PULA
	cQryAux += "		END AS [FILSAIDA],	"		+ STR_PULA
	cQryAux += "		ISNULL(SZF.ZF_DATA,'-') AS [DTENTREG], "		+ STR_PULA
	cQryAux += "		ISNULL(SZF.ZF_HORA,'-') AS [HRENTREG], "		+ STR_PULA
	cQryAux += "		ISNULL(SA4.A4_COD + ' ' + SA4.A4_NOME,'NÃO INFO') AS [TRANSPORTADORA], "		+ STR_PULA
	cQryAux += "		ISNULL(SZF.ZF_MOTOR,'NÃO INFO') AS [MOTORISTA], "		+ STR_PULA
	cQryAux += "		ISNULL(SZF.ZF_CARREG,'NÃO INFO') AS [CARREGADOR] "		+ STR_PULA
	cQryAux += " FROM " + RetSqlName('SF2') + " SF2"		+ STR_PULA
	cQryAux += " INNER JOIN " + RetSqlName('SA1') + " SA1 ON '' = SA1.A1_FILIAL"		+ STR_PULA
	cQryAux += "						AND SF2.F2_CLIENTE = SA1.A1_COD"		+ STR_PULA
	cQryAux += "						AND SF2.F2_LOJA = SA1.A1_LOJA"		+ STR_PULA
	cQryAux += "						AND SA1.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += " LEFT JOIN " + RetSqlName('SZF') + " SZF ON SF2.F2_FILIAL = SZF.ZF_FILIAL"		+ STR_PULA
	cQryAux += "						AND SF2.F2_SERIE = SZF.ZF_SERIE"		+ STR_PULA
	cQryAux += "						AND SF2.F2_DOC = SZF.ZF_NOTA"		+ STR_PULA
	cQryAux += "						AND SF2.F2_CDROMA = SZF.ZF_CDROMA"		+ STR_PULA
	cQryAux += "						AND SZF.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += " LEFT JOIN " + RetSqlName('SA4') + " SA4 ON '' = SA4.A4_FILIAL"		+ STR_PULA
	cQryAux += "						AND SZF.ZF_TRANS = SA4.A4_COD"		+ STR_PULA
	cQryAux += "						AND SA4.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += " WHERE SF2.F2_FILIAL = '" + xFilial('SF2') + "'"		+ STR_PULA
	cQryAux += " AND SF2.F2_DOC >= '" + AllTrim(MV_PAR01) + "'"		+ STR_PULA
	cQryAux += " AND SF2.F2_DOC <= '" + AllTrim(MV_PAR02) + "'"		+ STR_PULA
	cQryAux += " AND SF2.F2_SERIE >= '" + AllTrim(MV_PAR03) + "'"	+ STR_PULA
	cQryAux += " AND SF2.F2_SERIE <= '" + AllTrim(MV_PAR04) + "'"	+ STR_PULA
	cQryAux += " AND SF2.F2_EMISSAO >= '" + DtoS(MV_PAR05) + "'"	+ STR_PULA
	cQryAux += " AND SF2.F2_EMISSAO <= '" + DtoS(MV_PAR06) + "'"	+ STR_PULA
	if MV_PAR07 <> 'Todas'
		cQryAux += " AND SZF.ZF_FILSAI = '" + FwFilial() + "'"		+ STR_PULA
	endif
	if MV_PAR08 == 'Entregues'
		cQryAux += " AND SZF.ZF_FILIAL IS NOT NULL "		+ STR_PULA
	elseif MV_PAR08 == 'Não Entregues'
		cQryAux += " AND SZF.ZF_FILIAL IS NULL "			+ STR_PULA
	endif
	cQryAux += "AND SF2.D_E_L_E_T_ = ''"							+ STR_PULA
	cQryAux += "ORDER BY SF2.F2_EMISSAO, SF2.F2_DOC"				+ STR_PULA
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
