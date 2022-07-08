//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} CBCNFPED
Relatório - Relatorio NFs x Pedidos       
@author zReport
@since 20/04/18
@version 1.0
	@example
	u_CBCNFPED()
	@obs Função gerada pelo zReport()
/*/
	
User Function CBCRNFPED()
	Local aArea   		:= GetArea()
	Local oReport
	Local lEmail  		:= .F.
	Local cPara   		:= ""
	Local aPergs := {}
	Local cNfDef := Space(TamSX3("D2_DOC")[1])
	Local cSerieDef := Space(TamSX3("D2_SERIE")[1])
	Local aRet := {}
	Local lRet    	
	Private cPerg := ""
	
	//Cria as definições do relatório
	oReport := fReportDef()
	
	aAdd( aPergs ,{1,"da NF: ",cNfDef,"@!",'.T.',,'.T.',TamSX3("D2_DOC")[1],.F.})
	aAdd( aPergs ,{1,"até NF: ",cNfDef,"@!",'.T.',,'.T.',TamSX3("D2_DOC")[1],.F.})
	aAdd( aPergs ,{1,"da Série: ",cSerieDef,"@!",'.T.',,'.T.',TamSX3("D2_SERIE")[1],.F.})
	aAdd( aPergs ,{1,"até Série: ",cSerieDef,"@!",'.T.',,'.T.',TamSX3("D2_SERIE")[1],.F.})  
	aAdd( aPergs ,{1,"da Dt. de Emissão: ",dDataBase,PesqPict("SD2", "D2_EMISSAO"),'.T.',,'.T.',TamSX3("D2_EMISSAO")[1],.F.})
	aAdd( aPergs ,{1,"até Dt. de Emissão: ",dDataBase,PesqPict("SD2", "D2_EMISSAO"),'.T.',,'.T.',TamSX3("D2_EMISSAO")[1],.F.})
	
	
	If !ParamBox(aPergs ,"Parâmetros do Relatório",aRet)      
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
	oReport := TReport():New(	"CBCNFPED",;		//Nome do Relatório
								"Relatorio NFs x Pedidos",;		//Título
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
	TRCell():New(oSectDad, "Pedido", "QRY_AUX", "Pedido", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SeqOS", "QRY_AUX", "SeqOS", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "Nota", "QRY_AUX", "Nota", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "Serie", "QRY_AUX", "Serie", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DtEmissao", "QRY_AUX", "Dt.Emissao", /*Picture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VlTotal", "QRY_AUX", "Vl.Total", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
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
	Local cSerieDe:= MV_PAR03
	Local cSerieAte := If(!Empty(MV_PAR04), MV_PAR04, Replicate("Z", TamSX3("D2_SERIE")[1])) 
	Local cNFDe := If(!Empty(MV_PAR01), MV_PAR01, Replicate("0", TamSX3("D2_DOC")[1])) 
	Local cNFAte:= If(!Empty(MV_PAR02), MV_PAR02, Replicate("9", TamSX3("D2_DOC")[1])) 
	
	
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT D2_PEDIDO Pedido, D2_SEQOS SeqOS, D2_DOC Nota, D2_SERIE Serie, CONVERT(VARCHAR, CAST(D2_EMISSAO AS DATETIME), 103) DtEmissao, SUM(D2_VALBRUT) VlTotal" + STR_PULA
	cQryAux += "FROM SD2010 D2"		+ STR_PULA
	cQryAux += "WHERE D2_FILIAL = '" + FWFilial() + "'"		+ STR_PULA
	cQryAux += "AND Cast(D2_DOC AS INT) >= " + cNFDe + STR_PULA
	If cNFAte # Replicate("9", TamSX3("D2_DOC")[1])
		cQryAux += "AND Cast(D2_DOC AS INT) <= " + cNFAte + STR_PULA
	EndIf
	cQryAux += "AND D2_SERIE >= '" + cSerieDe + "'"		+ STR_PULA
	cQryAux += "AND D2_SERIE <= '" + cSerieAte + "'"		+ STR_PULA
	cQryAux += "AND D2_EMISSAO BETWEEN '"+ DtoS(MV_PAR05) + "' AND '"+ DtoS(MV_PAR06)+"'"		+ STR_PULA
	cQryAux += "AND D2_PEDIDO <> ''"		+ STR_PULA
	cQryAux += "AND D2.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "GROUP BY D2_PEDIDO, D2_SEQOS, D2_DOC, D2_SERIE, D2_EMISSAO"		+ STR_PULA
	cQryAux += "ORDER BY Pedido"		+ STR_PULA
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
