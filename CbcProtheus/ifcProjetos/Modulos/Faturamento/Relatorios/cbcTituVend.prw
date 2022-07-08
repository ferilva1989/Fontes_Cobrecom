#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} tituVend
RelatÃ³rio - Titulos por Vendedores        
@author zReport
@since 12/02/20
@version 1.0
	@example
	u_tituVend()
	@obs FunÃ§Ã£o gerada pelo zReport()
/*/

User Function xTituVend()
	Local oReport
	Local bBlock 	:= ErrorBlock()
	Local aPergs  	:= {}
	Local aRet	  	:= {}
	Local aArea   	:= GetArea()
	Private cCodUsr	:= ''
	Private cPerg   := ""

	ErrorBlock( {|e| ChecErro(e)})

	BEGIN SEQUENCE
		cCodUsr	:= getVend(RetCodUsr())

		aAdd( aPergs ,{2,"Considerar: ","VENCIMENTO",{"VENCIMENTO", "EMISSAO"},80,'.T.',.F.})
		aAdd( aPergs ,{1,"Da data: ",dDataBase,PesqPict("SE1", "E1_EMISSAO"),'.T.',,'.T.',80,.T.})
		aAdd( aPergs ,{1,"Até data: ",dDataBase,PesqPict("SE1", "E1_EMISSAO"),'.T.',,'.T.',80,.T.})

		if !ParamBox(aPergs,"Parâmetros do Relatório",aRet)
			Alert("Relatório Cancelado!")
			return(nil)
		endif

		//Cria as definições do relatório
		oReport := fReportDef()
		oReport:PrintDialog()
		ErrorBlock(bBlock)
		RECOVER
		ErrorBlock(bBlock)
	END SEQUENCE

	RestArea(aArea)
	FreeObj(oReport)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Desc:  Funï¿½ï¿½o que monta a definiï¿½ï¿½o do relatï¿½rio                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	
	//Criaï¿½ï¿½o do componente de impressï¿½o
	oReport := TReport():New(	"tituVend",;		//Nome do Relatï¿½rio
								"Titulos por Vendedores",;		//Tï¿½tulo
								cPerg,;	
								{|oReport| fRepPrint(oReport)},;		//Bloco de cï¿½digo que serï¿½ executado na confirmaï¿½ï¿½o da impressï¿½o
								)		//Descriï¿½ï¿½o
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetPortrait()
	
	//Criando a seï¿½ï¿½o de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seï¿½ï¿½o pertence
									"Dados",;		//Descriï¿½ï¿½o da seï¿½ï¿½o
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira serï¿½ considerada como principal da seï¿½ï¿½o
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serï¿½o impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatï¿½rio
	TRCell():New(oSectDad, "FILIAL", "QRY_AUX", "Filial", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "EMISSAO", "QRY_AUX", "Emissao", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NF", "QRY_AUX", "Nf", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VALOR_BRUTO", "QRY_AUX", "Valor_Bruto", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "COD_VENDEDOR", "QRY_AUX", "Cod_Vendedor", /*Picture*/, 7, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NOME_VENDEDOR", "QRY_AUX", "Nome_Vendedor", /*Picture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "CLIENTE", "QRY_AUX", "Cliente", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "COND_PAG", "QRY_AUX", "Cond_Pag", /*Picture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PEDIDO", "QRY_AUX", "Pedido", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VENCIMENTO", "QRY_AUX", "Vencimento", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PARCELA", "QRY_AUX", "Parcela", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VALOR", "QRY_AUX", "Valor", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "BAIXA", "QRY_AUX", "Baixa", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Funï¿½ï¿½o que imprime o relatï¿½rio                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	Local aArea    := GetArea()
	Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as seï¿½ï¿½es do relatï¿½rio
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := " SELECT "
	cQryAux += "	E1.E1_FILIAL AS FILIAL, "
	cQryAux += "	CONVERT(VARCHAR, CONVERT(DATE,F2.F2_EMISSAO), 103) AS EMISSAO, "
	cQryAux += "	F2.F2_DOC     AS NF, "
	cQryAux += "	F2.F2_VALBRUT AS 'VALOR_BRUTO', "
	cQryAux += "	A3.A3_COD	  AS 'COD_VENDEDOR', "
	cQryAux += "	A3.A3_NOME	  AS 'NOME_VENDEDOR', "
	cQryAux += "	E1.E1_NOMCLI  AS CLIENTE, "
	cQryAux += "	E4.E4_DESCRI  AS 'COND_PAG', "
	cQryAux += "	E1.E1_PEDIDO  AS PEDIDO, "
	cQryAux += "	CONVERT(VARCHAR, CONVERT(DATE, E1.E1_VENCREA), 103) AS VENCIMENTO, "
	cQryAux += "	E1.E1_PARCELA AS PARCELA, "
	cQryAux += "	E1.E1_VALOR   AS VALOR, "
	cQryAux += "	CASE "
	cQryAux += "	WHEN E1_BAIXA <> '' "
	cQryAux += "	THEN CONVERT(VARCHAR, CONVERT(DATE, E1.E1_BAIXA), 103) "
	cQryAux += "	END AS BAIXA "
	cQryAux += " FROM "
	cQryAux += RetSqlName('SE1') + " E1 WITH(NOLOCK) "
	cQryAux += "		INNER JOIN "
	cQryAux += RetSqlName('SF2') + " F2 WITH(NOLOCK) "
	cQryAux += "				ON  E1_FILIAL	  = F2.F2_FILIAL "
	cQryAux += "				AND E1.E1_NUM	  = F2.F2_DOC "
	cQryAux += "		INNER JOIN "
	cQryAux += RetSqlName('SE4') + " E4 WITH(NOLOCK) "
	cQryAux += "				ON F2.F2_COND  = E4.E4_CODIGO "
	cQryAux += "		INNER JOIN "
	cQryAux += RetSqlName('SA3') + " A3 WITH(NOLOCK) "
	cQryAux += "				ON E1.E1_VEND1    = A3.A3_COD "
	cQryAux += " WHERE "
	cQryAux += "	E1.E1_VEND1 IN (" + cCodUsr + ") " 
	If (MV_PAR01 == 'VENCIMENTO')
		cQryAux += " AND E1.E1_VENCREA BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "'"
	Else
		cQryAux += " AND E1.E1_EMISSAO BETWEEN '" + DtoS(MV_PAR02) + "' AND '" + DtoS(MV_PAR03) + "'"
	EndIf
	cQryAux += "	AND E1.D_E_L_E_T_ = '' "
	cQryAux += " ORDER BY "
	cQryAux += "	A3.A3_NOME, "
	cQryAux += "	E1.E1_PEDIDO, "
	cQryAux += "	E1.E1_VENCREA "
	// cQryAux := ChangeQuery(cQryAux)
	
	//Executando consulta e setando o total da rï¿½gua
	TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal
	oReport:SetMeter(nTotal)
	
	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())
		//Incrementando a rï¿½gua
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
Return nil


Static Function getVend(cCod)
	Local cVends as character
	Local cQryAx as character
	
	If !Empty(cCod)
		cVends := ''
		cQryAx := ''

		cQryAx := " SELECT " 
		cQryAx += "			A3_COD AS COD "
		cQryAx += "	FROM "
		cQryAx += "		SA3010 WITH(NOLOCK) "
		cQryAx += "	WHERE "
		cQryAx += "		A3_SUPER IN ( "
		cQryAx += "			SELECT "
		cQryAx += "				A3_COD "
		cQryAx += "			FROM "
		cQryAx += "				SA3010 WITH(NOLOCK) "
		cQryAx += "			WHERE "
		cQryAx += "			A3_CODUSR = '" + cCod + "' "
		cQryAx += "				AND A3_DEMISS = '' "
		cQryAx += "				AND D_E_L_E_T_ = '') "
		cQryAx += "		AND A3_DEMISS = '' "
		cQryAx += "		AND D_E_L_E_T_ = '' "
	
		//Executando consulta e setando o total da rï¿½gua
		TCQuery cQryAx New Alias "QRY_VENDS"
		QRY_VENDS->(DbGoTop())
		While !QRY_VENDS->(Eof())
			cVends += "'" + QRY_VENDS->COD + "'" + ','
			QRY_VENDS->(DbSkip())
		EndDo
		cVends := Left(cVends,Len(cVends)-1)
		QRY_VENDS->(DbCloseArea())		
	EndIf
Return cVends

Static Function ChecErro(e)
	Local lRet as boolean
	
	lRet := .T.
	If e:gencode > 0
		Help( " ",1,"ERRO",,e:Description,3,1)
	    lRet:=.F.
	EndIf
	Break
Return lRet
