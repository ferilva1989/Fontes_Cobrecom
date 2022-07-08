//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} CBCRCBAR
Relatório - Código de Barras por Produto  
@author zReport
@since 06/06/18
@version 1.0
	@example
	u_CBCRCBAR()
	@obs Função gerada pelo zReport()
/*/
	
User Function CBCRCBAR()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Local aPergs  := {}
	Local aRet	  := {}
	Private cPerg := ""
	
	//Cria as definições do relatório
	oReport := fReportDef()
	
	
	aAdd( aPergs ,{1,"do Produto: ",Space(TamSX3("B1_COD")[1]),"@!",'.T.',,'.T.',80,.F.})
	aAdd( aPergs ,{1,"até Produto: ",Replicate("Z", TamSX3("B1_COD")[1]) ,"@!",'.T.',,'.T.',80,.F.})
	
	
	If !ParamBox(aPergs,"Parâmetros do Relatório",aRet)
		Alert("Relatório Cancelado!")
		Return
	EndIf
	
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
	oReport := TReport():New(	"CBCRCBAR",;		//Nome do Relatório
								"Código de Barras por Produto",;		//Título
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
	TRCell():New(oSectDad, "B1_COD", "QRY_AUX", "Codigo", /*Picture*/, 17, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_DESC", "QRY_AUX", "Descricao", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_CODBAR", "QRY_AUX", "Cod Barras", /*Picture*/, 17, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "LOCALIZ", "QRY_AUX", "Acondic.", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
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
	Local cDoProd  := MV_PAR01
	Local cAteProd := MV_PAR02
	local oSql	   := nil
	local lRolo	   := .F.
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT B1_COD, B1_DESC, B1_CODBAR "		+ STR_PULA
	cQryAux += "FROM SB1010"		+ STR_PULA
	cQryAux += "WHERE B1_COD >= '" + cDoProd + "'"		+ STR_PULA
	cQryAux += "AND B1_COD <= '" + cAteProd + "'"		+ STR_PULA
	//cQryAux += "AND B1_CODBAR <> ''"		+ STR_PULA
	cQryAux += "AND B1_TIPO = 'PA'"		+ STR_PULA
	cQryAux += "AND B1_MSBLQL = '2'"		+ STR_PULA
	cQryAux += "AND D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "ORDER BY B1_COD"		+ STR_PULA
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
		
		lRolo := .F.

		cQryAux := ""
		cQryAux += " SELECT SZJ.ZJ_LOCALIZ AS [ACOND],                        "
		cQryAux += " SZJ.ZJ_CODBAR AS [CODBAR]		                          "
		cQryAux += " FROM %SZJ.SQLNAME% WITH(NOLOCK)                          "
		cQryAux += " WHERE %SZJ.XFILIAL%                                      "
		cQryAux += " AND SZJ.ZJ_PRODUTO = '" + AllTrim(QRY_AUX->B1_COD) + "'  "
		cQryAux += " AND SZJ.D_E_L_E_T_ = ''                                  "
		
		oSql := LibSqlObj():newLibSqlObj()	
		oSql:newAlias( cQryAux )				
		If (oSql:hasRecords())		
			oSql:goTop()
			While oSql:notIsEof()
				//Incrementando a régua
				nAtual++
				oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
				oReport:IncMeter()
				
				lRolo := (AllTrim(oSql:getValue("ACOND")) == 'R00100')
					
				//atribuindo valores da tabela SZJ
				oSectDad:Cell("B1_COD"):SetValue(AllTrim(QRY_AUX->B1_COD))
				oSectDad:Cell("B1_DESC"):SetValue(AllTrim(QRY_AUX->B1_DESC))
				oSectDad:Cell("B1_CODBAR"):SetValue(AllTrim(oSql:getValue("CODBAR")))		
				oSectDad:Cell("LOCALIZ"):SetValue(AllTrim(oSql:getValue("ACOND")))	
				//imprimindo linha			
				oSectDad:PrintLine()					
				oSql:skip()
			EndDo			
		EndIf
		
		//atribuindo B1_CODBAR para R00100 caso não tenha o mesmo na tabela SZJ
		if (!lRolo) .and. (!empty(QRY_AUX->B1_CODBAR))
			oSectDad:Cell("B1_COD"):SetValue(AllTrim(QRY_AUX->B1_COD))
			oSectDad:Cell("B1_DESC"):SetValue(AllTrim(QRY_AUX->B1_DESC))
			oSectDad:Cell("B1_CODBAR"):SetValue(AllTrim(QRY_AUX->B1_CODBAR))		
			oSectDad:Cell("LOCALIZ"):SetValue('R00100')
			
			//Imprimindo a linha atual
			oSectDad:PrintLine()	
		endif		
		oSql:close() 
		FreeObj(oSql)
		QRY_AUX->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())	
	RestArea(aArea)
Return
