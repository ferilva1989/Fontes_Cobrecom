//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} cbcRnoNF
Relatório - Relatorio NF sem entrada      
@author zReport
@since 10/08/21
@version 1.0
	@example
	u_cbcRnoNF()
	@obs Função gerada pelo zReport()
/*/
	
User Function cbcRnoNF()
	local aArea   	:= GetArea()
	local oReport
	local lEmail  	:= .F.
	local cPara   	:= ""
    local aPerg     := {}
	private aOpc  	:= {'Sem entrada', 'Não Class', 'Todas'}
	private aRet    := {}
	private cPerg 	:= ""
	
	aadd(aPerg,{1,"Data De: ",   dDataBase,"",".T.","",".T.",50,.T.})
    aadd(aPerg,{1,"Data Até: ",  dDataBase,"","MV_PAR01 <= MV_PAR02","",".T.",50,.T.})
	aadd(aPerg ,{2, "Filtro: ", aOpc[01], aOpc, 50, ".T.", .T.})

	if !(ParamBox(aPerg,"Parâmetros - Relatorio NF sem entrada",@aRet))
		return(.F.)
	endif

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
	local oReport
	local oSectDad := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"cbcRnoNF",;		//Nome do Relatório
								"Relatorio NF sem entrada",;		//Título
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
	TRCell():New(oSectDad, "NF", "QRY_AUX", "Nf", PesqPict('SD1', 'D1_DOC'), TamSx3('D1_DOC')[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SERIE", "QRY_AUX", "Serie", PesqPict('SD1', 'D1_SERIE'), TamSx3('D1_SERIE')[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "RAZAO", "QRY_AUX", "Razao", PesqPict('SA2', 'A2_NOME'), TamSx3('A2_NOME')[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CNPJ", "QRY_AUX", "Cnpj", PesqPict('SA2', 'A2_CGC'), TamSx3('A2_CGC')[1] + 5, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CHAVE", "QRY_AUX", "Chave", PesqPict('SF1', 'F1_CHVNFE'), TamSx3('F1_CHVNFE')[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "TOTAL", "QRY_AUX", "Total", PesqPict('SD1', 'D1_TOTAL'), TamSx3('D1_TOTAL')[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "EMISSAO", "QRY_AUX", "Emissao", PesqPict('SD1', 'D1_EMISSAO'), TamSx3('D1_EMISSAO')[1], /*lPixel*/,{|| DTOC(STOD(QRY_AUX->EMISSAO)) },/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CLAS", "QRY_AUX", "Clas.", PesqPict('SF1', 'F1_STATUS'), TamSx3('F1_STATUS')[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,.T./*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
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
	cQryAux += "SELECT C00.C00_NUMNFE AS [NF],"		+ STR_PULA
	cQryAux += "C00.C00_SERNFE AS [SERIE],"		+ STR_PULA
	cQryAux += "C00.C00_NOEMIT AS [RAZAO],"		+ STR_PULA
	cQryAux += "C00.C00_CNPJEM AS [CNPJ],"		+ STR_PULA
	cQryAux += "C00.C00_CHVNFE AS [CHAVE],"		+ STR_PULA
	cQryAux += "C00.C00_VLDOC AS [TOTAL],"		+ STR_PULA
	cQryAux += "C00.C00_DTEMI AS [EMISSAO],"		+ STR_PULA
	cQryAux += " CASE  " + STR_PULA
	cQryAux += " 	WHEN SF1.F1_STATUS IS NULL " + STR_PULA
	cQryAux += " 		THEN '' " + STR_PULA
	cQryAux += " 	WHEN SF1.F1_STATUS = '' " + STR_PULA
	cQryAux += " 		THEN 'N' " + STR_PULA
	cQryAux += " 	ELSE 'S' " + STR_PULA
	cQryAux += " END AS [CLAS] " + STR_PULA
	cQryAux += "FROM C00010 C00" + STR_PULA
	cQryAux += "LEFT JOIN SF1010 SF1 ON C00.C00_FILIAL = SF1.F1_FILIAL AND C00.C00_CHVNFE = SF1.F1_CHVNFE AND C00.D_E_L_E_T_ = SF1.D_E_L_E_T_"		+ STR_PULA
	cQryAux += "WHERE C00.C00_FILIAL = '" + FwFilial() + "'"		+ STR_PULA
	cQryAux += "AND C00.C00_DTEMI >= '" + DtoS(aRet[01]) + "'"		+ STR_PULA
	cQryAux += "AND C00.C00_DTEMI <= '" + DtoS(aRet[02]) + "'"		+ STR_PULA
	if aRet[03] == aOpc[01]
		cQryAux += "AND SF1.F1_CHVNFE IS NULL"		+ STR_PULA
	elseif aRet[03] == aOpc[02]
		cQryAux += "AND SF1.F1_STATUS = ''"		+ STR_PULA
	endif
	cQryAux += "AND C00.D_E_L_E_T_ = ''"		+ STR_PULA
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
