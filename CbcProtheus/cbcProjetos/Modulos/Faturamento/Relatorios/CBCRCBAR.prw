//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} CBCRCBAR
Relat�rio - C�digo de Barras por Produto  
@author zReport
@since 06/06/18
@version 1.0
	@example
	u_CBCRCBAR()
	@obs Fun��o gerada pelo zReport()
/*/
	
User Function CBCRCBAR()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Local aPergs  := {}
	Local aRet	  := {}
	Private cPerg := ""
	
	//Cria as defini��es do relat�rio
	oReport := fReportDef()
	
	
	aAdd( aPergs ,{1,"do Produto: ",Space(TamSX3("B1_COD")[1]),"@!",'.T.',,'.T.',80,.F.})
	aAdd( aPergs ,{1,"at� Produto: ",Replicate("Z", TamSX3("B1_COD")[1]) ,"@!",'.T.',,'.T.',80,.F.})
	
	
	If !ParamBox(aPergs,"Par�metros do Relat�rio",aRet)
		Alert("Relat�rio Cancelado!")
		Return
	EndIf
	
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
	oReport := TReport():New(	"CBCRCBAR",;		//Nome do Relat�rio
								"C�digo de Barras por Produto",;		//T�tulo
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
	TRCell():New(oSectDad, "B1_COD", "QRY_AUX", "Codigo", /*Picture*/, 17, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_DESC", "QRY_AUX", "Descricao", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "B1_CODBAR", "QRY_AUX", "Cod Barras", /*Picture*/, 17, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "LOCALIZ", "QRY_AUX", "Acondic.", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
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
	Local cDoProd  := MV_PAR01
	Local cAteProd := MV_PAR02
	local oSql	   := nil
	local lRolo	   := .F.
	//Pegando as se��es do relat�rio
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
				//Incrementando a r�gua
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
		
		//atribuindo B1_CODBAR para R00100 caso n�o tenha o mesmo na tabela SZJ
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
