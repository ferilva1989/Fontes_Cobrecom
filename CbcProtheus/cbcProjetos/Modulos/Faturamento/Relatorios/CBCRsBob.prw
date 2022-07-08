//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
	
//Constantes
#Define STR_PULA		Chr(13)+Chr(10)
	
/*/{Protheus.doc} CBCRsBob
Relatório - Reservas de Bobinas Cobrecom  
@author zReport
@since 23/08/2018
@version 1.0
	@example
	u_CBCRsBob()
	@obs Função gerada pelo zReport()
/*/
	
User Function CBCRsBob()
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := ""
	
	//Definições da pergunta
	cPerg := "CBCRESBOB "
	
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
	
/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Desc:  Função que monta a definição do relatório                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oBreak := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"CBCRsBob",;		//Nome do Relatório
								"Reservas de Bobinas Cobrecom. Filial : " +FwFilial() + " - " + FWFilialName(),;		//Título
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
	TRCell():New(oSectDad, "COD_ATEND", "QRY_AUX", "Atend.", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "SUPER_NOME", "QRY_AUX", "Nome Atend.", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "RESERV_NOME", "QRY_AUX", "Nome Reserv.", /*Picture*/, 20, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VENDEDOR", "QRY_AUX", "Vend.", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NOME_VENDEDOR", "QRY_AUX", "Nome Vend.", /*Picture*/, 40, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NUM_BOBINA", "QRY_AUX", "Num.Bob.", /*Picture*/, 7, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "COD_LOJA_CLIENTE", "QRY_AUX", "Cliente", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NOME_CLIENTE", "QRY_AUX", "Nome Cliente", /*Picture*/, 50, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PROD_BITOLA", "QRY_AUX", "Bitola", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PROD_COR", "QRY_AUX", "Cor", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "BOB_METRAGE", "QRY_AUX", "Bob.Metrg", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "NF_FATUR", "QRY_AUX", "NF.Fatur", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ITEM_NF_FATUR", "QRY_AUX", "It.NF", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "PEDIDO_RESERVA", "QRY_AUX", "Pedido", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "DATA_FATUR", "QRY_AUX", "Data Fatur", /*Picture*/, 12, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "VL_ITEM", "QRY_AUX", "VL Item","@E 99999,999.99", 19, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
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
	cQryAux += "SELECT SA3010.A3_SUPER COD_ATEND,"		+ STR_PULA
	cQryAux += "		ISNULL(A3B.A3_NOME,'') SUPER_NOME,"		+ STR_PULA
	cQryAux += "		ISNULL(ZR_RESP,'') RESERV_NOME,"		+ STR_PULA
	cQryAux += "		F2_VEND1 VENDEDOR,"		+ STR_PULA
	cQryAux += "		SA3010.A3_NOME NOME_VENDEDOR,"		+ STR_PULA
	cQryAux += "		ZR_NUMBOB NUM_BOBINA,"		+ STR_PULA
	cQryAux += "		ZR_CODCLI+ZR_LOJA COD_LOJA_CLIENTE,"		+ STR_PULA
	cQryAux += "		ZR_NOMCLI NOME_CLIENTE, "		+ STR_PULA
	cQryAux += "		Z2_DESC PROD_BITOLA,"		+ STR_PULA
	cQryAux += "		Z3_DESC PROD_COR,"		+ STR_PULA
	cQryAux += "		ZR_METRAGE BOB_METRAGE,"		+ STR_PULA
	cQryAux += "		ZE_DOC NF_FATUR,"		+ STR_PULA
	cQryAux += "		ZE_ITEM ITEM_NF_FATUR,"		+ STR_PULA
	cQryAux += "		ZE_PEDIDO PEDIDO_RESERVA,"		+ STR_PULA
	cQryAux += "		SUBSTRING(D2_EMISSAO,7,2)+'/'+SUBSTRING(D2_EMISSAO,5,2)+'/'+SUBSTRING(D2_EMISSAO,1,4) DATA_FATUR,"		+ STR_PULA
	cQryAux += "		D2_TOTAL VL_ITEM"		+ STR_PULA
	cQryAux += "FROM SZE010"		+ STR_PULA
	cQryAux += "	LEFT JOIN SZR010   ON ZE_FILIAL = ZR_FILIAL AND ZE_BOBORIG = ZR_FILIAL+ZR_NUMBOB AND SZR010.D_E_L_E_T_ = SZE010.D_E_L_E_T_ "		+ STR_PULA
	cQryAux += "	INNER JOIN SB1010 ON B1_FILIAL = '' AND ZE_PRODUTO = B1_COD AND SB1010.D_E_L_E_T_ = SZE010.D_E_L_E_T_ "		+ STR_PULA
	cQryAux += "	INNER JOIN SZ2010 ON Z2_FILIAL = '' AND Z2_COD = B1_BITOLA AND SB1010.D_E_L_E_T_ = SZ2010.D_E_L_E_T_ "		+ STR_PULA
	cQryAux += "	INNER JOIN SZ3010 ON Z3_FILIAL = '' AND Z3_COD = B1_COR AND SB1010.D_E_L_E_T_ = SZ3010.D_E_L_E_T_ "		+ STR_PULA
	cQryAux += "	INNER JOIN SD2010 ON D2_FILIAL = ZE_FILIAL AND D2_DOC = ZE_DOC AND D2_ITEM = ZE_ITEM AND SD2010.D_E_L_E_T_ = SZE010.D_E_L_E_T_ "		+ STR_PULA
	cQryAux += "	INNER JOIN SF2010 ON F2_FILIAL = D2_FILIAL AND D2_DOC = F2_DOC AND D2_SERIE = F2_SERIE AND SD2010.D_E_L_E_T_ = SF2010.D_E_L_E_T_ "		+ STR_PULA
	cQryAux += "	INNER JOIN SA3010 ON A3_FILIAL = '' AND A3_COD = F2_VEND1 AND SA3010.D_E_L_E_T_ = SF2010.D_E_L_E_T_ "		+ STR_PULA
	cQryAux += "	LEFT JOIN SA3010 A3B ON A3B.A3_FILIAL = SA3010.A3_FILIAL AND A3B.A3_COD = SA3010.A3_SUPER AND SA3010.D_E_L_E_T_ = A3B.D_E_L_E_T_ "		+ STR_PULA
	cQryAux += "WHERE ZR_FILIAL = '"+ FwFilial() + "'"		+ STR_PULA
	cQryAux += "AND D2_EMISSAO >= '" + DtoS(MV_PAR03)   + "'"		+ STR_PULA
	cQryAux += "AND D2_EMISSAO <= '" + DtoS(MV_PAR04)   + "'"		+ STR_PULA
	cQryAux += "AND D2_DOC >= '" + MV_PAR05  +  "' "		+ STR_PULA
	cQryAux += "AND D2_DOC <= '" + MV_PAR06  +  "' "		+ STR_PULA
	cQryAux += "AND ZE_PEDIDO >= '" + MV_PAR07  +  "' "		+ STR_PULA
	cQryAux += "AND ZE_PEDIDO <= '" + MV_PAR08  +  "' "		+ STR_PULA
	cQryAux += "AND F2_VEND1 >= '" + MV_PAR09  +  "' "		+ STR_PULA
	cQryAux += "AND F2_VEND1 <= '" + MV_PAR10  +  "' "		+ STR_PULA
	cQryAux += "AND ZR_CODCLI >= '" + MV_PAR11  +  "' "		+ STR_PULA
	cQryAux += "AND ZR_CODCLI <=  '" + MV_PAR12  +  "' "		+ STR_PULA
	cQryAux += "AND ZR_LOJA >= '" + MV_PAR13  +  "' "		+ STR_PULA
	cQryAux += "AND ZR_LOJA <= '" + MV_PAR14  +  "' "		+ STR_PULA
	cQryAux += "AND SA3010.A3_SUPER >= '" + MV_PAR01  +  "' "		+ STR_PULA
	cQryAux += "AND SA3010.A3_SUPER <= '" + MV_PAR02  +  "' "		+ STR_PULA
	cQryAux += "AND SZR010.D_E_L_E_T_ = ''"		+ STR_PULA
	cQryAux += "ORDER BY D2_EMISSAO"		+ STR_PULA
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
