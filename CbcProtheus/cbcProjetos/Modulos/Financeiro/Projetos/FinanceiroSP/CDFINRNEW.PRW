#include "protheus.ch"
#define CRLF Chr(13)+Chr(10)

***************************************
User Function CDTITREL()
	***************************************
	//A PERFORMANCE DESTE RELATORIO N�O ESTA SATISFATORIA ANALISAR E ARRUMAR POSTERIORMENTE
	//IMPLEMENTAR FILTROS POR EMISS�O DE TITULOS E POR NUMERO BORDERO ITU

	//RELATORIO QUE MOSTRA OS TITULOS TRANSFERIDOS PARA SAO PAULO, QUE EST�O NAS SEGUINTES SITUA��ES:
	//1-) TITULOS S�O PAULO, QUE AINDA N�O FORAM COLOCADOS EM BANCO
	//2-) TITULOS S�O PAULO, QUE J� EST�O EM BANCO
	Local oReport
	Local cPerg 	:= "CDTITREL"
	Local oFonteRel := TFont():New( "Arial", , 08, .T.)
	Local aBox		:={}
	Local aRet		:={}
	Private lBanco	:=.F.//PADR�O TITULOS QUE N�O EST�O EM BANCO
	Private lTodos	:=.F.//IMPRIMIR VALOR NUMERO DE TODOS OS BORDEROS NO FINAL DO RELATORIO


	//PERGUNTA QUAL O TIPO DE RELATORIO � DESEJADO (1=BANCO (.T.) e 2=N�O BANCO(.F.))
	aAdd(aBox,{3,"Imprimir os titulos?",1,{"Em banco","N�o banco"},80,"",.T.})
	aAdd(aBox,{3,"Incluir ao final o numero e total de todos os borderos?",2,{"SIM","N�O"},100,"",.T.})
	// Tipo 3 -> Radio
	//           [2]-Descricao
	//           [3]-Numerico contendo a opcao inicial do Radio
	//           [4]-Array contendo as opcoes do Radio
	//           [5]-Tamanho do Radio
	//           [6]-Validacao
	//           [7]-Flag .T./.F. Parametro Obrigatorio ?

	If ParamBox(aBox,"Filtrar titulo que n�o est�o em banco...",@aRet)

		//RADIO SELECIONADO 1, TITULOS EM BANCO
		If aRet[1] == 1

			lBanco := .T.

		EndIF

		//IMPRIMIR NUMERO E TOTAL DE TODOS OS BORDEROS
		If aRet[2] == 1

			lTodos := .T.

		EndIf

	EndIf

	//Cria o objeto relatorio
	oReport := ReportDef()

	//Configura��es do relatorio
	oReport:OFONTBODY 	:= oFonteRel 	//Fonte utilizada no relatorio
	oReport:NFONTBODY 	:= 08 			//Tamanho da Fonte
	oReport:NLINEHEIGHT := 40 			//Altura da linha
	oReport:SetPortrait()				//Orienta��o da paginas
	oReport:SetTotalInLine(.F.)

	oReport:SetTotalText("Valor Total")	//Definir a string que ser� mostrada no total
	oReport:PrintDialog()				//Tela para configura��o de impressão

	Return Nil

	*
	***************************
Static Function ReportDef()
	***************************
	*
	//DEVOLVE OBJETO OREPORT COM AS DEFINI��ES DO RELATORIO

	Local oReport
	Local oSection1
	Local oSection2


	oReport := TReport():New("TITULOS RECEBER","Consulta situa��o de banco dos titulos" ,"CDTITREL",{|oReport| PrintReport(oReport)},"Consulta de Titulos")

	//Defini as sessões que teremos no relatorio
	oSection1 := TRSection():New(oReport,"Titulos" 					,"SE1")
	oSection2 := TRSection():New(oReport,"Borderos" 				,"SE1")
	oSection3 := TRSection():New(oReport,"De" 						,"SE1")

	//Tipo de dados para a Sess�01 na tela com base no SX3
	//ESTRUTURA PARA OS TITULOS
	TRCell():New(oSection1,"E1_PREFIXO"			,"SE1","NUM")
	TRCell():New(oSection1,"E1_NUM"				,"SE1","DUPLIC")
	TRCell():New(oSection1,"E1_PARCELA"			,"SE1","PARCELA")
	TRCell():New(oSection1,"E1_EMISSAO"			,"SE1","EMISSAO")
	TRCell():New(oSection1,"E1_CLIENTE"			,"SE1","CLIENTE")
	TRCell():New(oSection1,"E1_NOMCLI"			,"SA1","RAZAO_SOCIAL",,,,,,.T.) //Para quebra de linha automatica
	TRCell():New(oSection1,"E1_VENCTO"			,"SE1","VENCTO")
	TRCell():New(oSection1,"E1_PORTADO"			,"SE1","BANCO")
	TRCell():New(oSection1,"E1_ZZBOR1"			,"SE1","BORD_ITU")
	TRCell():New(oSection1,"E1_NUMBOR"			,"SE1","BORD_BANCO")
	TRCell():New(oSection1,"E1_DATABOR"			,"SE1","DATA_BORD")
	TRCell():New(oSection1,"E1_SALDO"			,"SE1","VALOR",,,,,"RIGHT",.T.,"RIGHT")


	//IMPRIMIR TOTALIZADORES POR BORDERO
	oBreak1 := TRBreak():New(oSection1,{ || oSection1:Cell("E1_ZZBOR1"):uPrint },"Total ",.F.)
	TRFunction():New(oSection1:Cell("E1_SALDO") ,"Total","SUM",oBreak1,"Total","@E 999,999,999.99",,.F.,.T.)

	//TOTAL DOS BORDEROS
	TRCell():New(oSection2,"E1_ZZBOR1"			,"SE1","NRO.BORD.ITU")
	TRCell():New(oSection2,"E1_VALOR"			,"SE1","VALOR TOTAL")

	TRCell():New(oSection3,"De" 				,"" ,"" ,"@!"/*Picture*/,70/*Tamanho*/,/*lPixel*/,/*{|| "" }*/,"LEFT",.T.,"LEFT")

	//Devolve o relatorio com estrutura de dados formada
	Return oReport

	*
	**************************************
Static Function PrintReport(oReport)
	**************************************
	*
	//FUN��O QUE OBTEM OS DADOS DO RELATORIO, E O IMPRIME

	Local oSection1 	:= oReport:Section(1)
	Local oSection2		:= oReport:Section(2)
	Local oSection3		:= oReport:Section(3)
	Local cCabec

	//WHERE DO SELECT
	Local cSP			:='000'
	Local cAntigo		:='ANTIGO'
	Local cVazio		:=''

	//Realiza a query para obter as informa��es do relatorio
	oSection1:BeginQuery()

	/*PARA ESTE CONSULTA CRIEI UM INDICE DIRETO NO BANCO (SE1010PER SENDO OS CAMPOS ( NUMBOR+ZZBC2+ZZBOR1+PORTADO )
	COMANDO UTILIZADO
	CREATE INDEX SE1010PER
	ON SE1010 (E1_NUMBOR,E1_ZZBC2,E1_ZZBOR1,E1_PORTADO)
	*/

	//lBanco (.F. = Somente o que n�o esta em banco e .T. = somente o que esta em banco
	If lBanco

		//ESTA EM BANCO
		BeginSql alias "QBCOS"

		SELECT	SE1.E1_PREFIXO,
		SE1.E1_NUM,
		SE1.E1_PARCELA,
		SE1.E1_EMISSAO,
		SE1.E1_CLIENTE,
		SE1.E1_NOMCLI,
		SE1.E1_VENCTO,
		SE1.E1_PORTADO,
		SE1.E1_ZZBOR1,
		SE1.E1_NUMBOR,
		SE1.E1_DATABOR,
		SE1.E1_SALDO

		FROM %table:SE1% SE1

		WHERE
		SE1.E1_NUMBOR 	<>  %Exp:cVazio%   											AND
		SE1.E1_SALDO 	> 	0														AND
		SE1.E1_ZZBC2 = %Exp:cSP% 													AND
		(SE1.E1_ZZBOR1 	<> 	%Exp:cVazio% AND SE1.E1_ZZBOR1 != %Exp:cAntigo%   )		AND
		SE1.E1_PORTADO 	<> 	%Exp:cVazio%

		ORDER BY SE1.E1_ZZBOR1,SE1.E1_CLIENTE, SE1.E1_EMISSAO, SE1.E1_VENCTO

		EndSql

	Else
		//N�O ESTA EM BANCO
		BeginSql alias "QBCON"

		SELECT	SE1.E1_PREFIXO,
		SE1.E1_NUM,
		SE1.E1_PARCELA,
		SE1.E1_EMISSAO,
		SE1.E1_CLIENTE,
		SE1.E1_NOMCLI,
		SE1.E1_VENCTO,
		SE1.E1_PORTADO,
		SE1.E1_ZZBOR1,
		SE1.E1_NUMBOR,
		SE1.E1_DATABOR,
		SE1.E1_SALDO

		FROM %table:SE1%  SE1

		WHERE
		SE1.E1_NUMBOR 	=  %Exp:cVazio%   											AND
		SE1.E1_SALDO 	> 	0														AND
		SE1.E1_ZZBC2 	= %Exp:cSP% 												AND
		(SE1.E1_ZZBOR1  <> 	%Exp:cVazio% AND SE1.E1_ZZBOR1 != %Exp:cAntigo%   )		AND
		SE1.E1_PORTADO 	= 	%Exp:cVazio%


		ORDER BY SE1.E1_ZZBOR1,SE1.E1_CLIENTE, SE1.E1_EMISSAO, SE1.E1_VENCTO

		EndSql

	EndIf

	oSection1:EndQuery()
	oSection1:Print()

	If lTodos//OP��O DE IMPRIMIR NUMERO E TOTAL DE TODOS OS BORDEROS

		oSection2:BeginQuery()

		BeginSql alias "BANCOS"

		SELECT DISTINCT(SE1.E1_ZZBOR1), SUM(SE1.E1_VALOR) AS E1_VALOR

		FROM %table:SE1% SE1

		WHERE (SE1.E1_ZZBOR1 <> %Exp:cVazio% AND SE1.E1_ZZBOR1 != %Exp:cAntigo% )

		GROUP BY SE1.E1_ZZBOR1
		ORDER BY SE1.E1_ZZBOR1

		EndSql


		//CABE�ALHO
		cCabec = 		"ABAIXO TODOS OS BORDEROS EM SEUS VALORES TOTAIS                    "
		cCabec +=		"INDEPENDENTE DE ESTAR EM BANCO OU N�O								   "

		oSection2:EndQuery()

		//Preencher as informa��eses na sess�o 02 do relatorio
		oSection3:Init()
		oSection3:ACELL[1]:UVALUE := cCabec
		oSection3:ACELL[1]:LBOLD := .T.
		oSection3:ACELL[1]:LCELLBREAK := .T.
		oSection3:PrintLine()
		oSection3:Finish()

		oSection2:Print()

	EndIF

Return
