#include "protheus.ch"
#define CRLF Chr(13)+Chr(10)

***************************************
User Function DEPPAG()
	***************************************

	Local oReport
	Local cPerg 	:= "CDDEPPAG"
	Local oFonteRel := TFont():New( "Arial", , 10, .F.)
	Local aBox		:={}
	Local aRet		:={}

	Private cDtDe 
	Private cDtAte

	//OBTEM OS PARAMETROS
	aAdd(aBox,{1,"Caixa De:"  ,dDataBase,"","","","",50,.T.})
	aAdd(aBox,{1,"Caixa Ate:"  ,dDataBase,"","","","",50,.T.})

	If ParamBox(aBox,"Depositos Caixa Semana...",@aRet)

		cDtDe   	:= aRet[1]
		cDtAte		:= aRet[2]

	Else

		MessageBox("Confirme os parametros","Aviso",48)
		Return nil
	EndIf

	//Cria o objeto relatorio
	oReport := ReportDef()

	//Configurações do relatorio
	oReport:OFONTBODY 	:= oFonteRel 	//Fonte utilizada no relatorio
	oReport:NFONTBODY 	:= 10 			//Tamanho da Fonte
	oReport:NLINEHEIGHT := 50 			//Altura da linha
	oReport:SetPortrait()				//Orientação da paginas
	oReport:SetTotalInLine(.F.)

	oReport:SetTotalText("Valor Total")	//Definir a string que será mostrada no total
	oReport:PrintDialog()				//Tela para configuração de impressÃ£o

	Return Nil

	*
	***************************
Static Function ReportDef()
	***************************
	*
	//DEVOLVE OBJETO OREPORT COM AS DEFINIÇÔES DO RELATORIO

	Local oReport
	Local oSection1
	Local oSection2

	oReport := TReport():New("DEP. SEMANA","Depositos semanais" ,"CDDEPPAG",{|oReport| PrintReport(oReport)},"Depositos Semanais")

	//Defini as sessões que teremos no relatorio
	oSection1 := TRSection():New(oReport,"Titulos" 					,"SE2")
	oSection2 := TRSection():New(oReport,"De" 						,"SE2")

	TRCell():New(oSection1,"E2_VENCREA"				,"SE2","DATA")
	TRCell():New(oSection1,"E2_VALOR"				,"SE2","VLR.DEP.",,15,,,"RIGHT",.T.,"RIGHT")

	TRFunction():New(oSection1:Cell("E2_VALOR")		,NIL,"SUM"	,NIL,"                       Valor Total ......."	,NIL,NIL,.F.,.T.,.F.)

	TRCell():New(oSection2,"De" 				,"" ,"" ,"@!"/*Picture*/,70/*Tamanho*/,/*lPixel*/,/*{|| "" }*/,"LEFT",.T.,"LEFT")


	//Devolve o relatorio com estrutura de dados formada
	Return oReport

	*
	**************************************
Static Function PrintReport(oReport)
	**************************************
	*
	Local oSection1 	:= oReport:Section(1)
	Local oSection2 	:= oReport:Section(2)
	Local cCabec		:= ""

	//Realiza a query para obter as informações do relatorio
	oSection1:BeginQuery()

	BeginSql alias "DEPCP"

	SELECT E2_VENCREA, SUM(E2_VALOR) AS E2_VALOR 

	FROM %table:SE2%

	WHERE E2_VENCREA BETWEEN %Exp:cDtDe% AND %Exp:cDtAte%
	AND SE2.%NotDel% 
	GROUP BY E2_VENCREA

	EndSql

	cCabec +=		"SEGUE OS VALORES PARA DEPOSITOS CONTA-CORRENTE ITU     "

	oSection1:EndQuery()    

	oSection2:Init()
	oSection2:ACELL[1]:UVALUE := cCabec
	oSection2:ACELL[1]:LBOLD := .T.
	oSection2:ACELL[1]:LCELLBREAK := .T.
	oSection2:PrintLine()
	oSection2:Finish()

	oSection1:Print()

Return