//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} cbcRnoNF
Relat�rio - Relatorio NF sem entrada      
@author zReport
@since 10/08/21
@version 1.0
	@example
	u_cbcRnoNF()
	@obs Fun��o gerada pelo zReport()
/*/
	
User Function cbcRnoNF()
	local aArea   	:= GetArea()
	local oReport
	local lEmail  	:= .F.
	local cPara   	:= ""
    local aPerg     := {}
	private aOpc  	:= {'Sem entrada', 'N�o Class', 'Todas'}
	private aRet    := {}
	private cPerg 	:= ""
	
	aadd(aPerg,{1,"Data De: ",   dDataBase,"",".T.","",".T.",50,.T.})
    aadd(aPerg,{1,"Data At�: ",  dDataBase,"","MV_PAR01 <= MV_PAR02","",".T.",50,.T.})
	aadd(aPerg ,{2, "Filtro: ", aOpc[01], aOpc, 50, ".T.", .T.})

	if !(ParamBox(aPerg,"Par�metros - Relatorio NF sem entrada",@aRet))
		return(.F.)
	endif

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
	local oReport
	local oSectDad := Nil
	
	//Cria��o do componente de impress�o
	oReport := TReport():New(	"cbcRnoNF",;		//Nome do Relat�rio
								"Relatorio NF sem entrada",;		//T�tulo
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
	
	//Executando consulta e setando o total da r�gua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		//Incrementando a r�gua
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
