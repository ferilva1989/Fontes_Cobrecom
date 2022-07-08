***************************************
User Function MAPADESP()
	***************************************

	Local oReport
	Local cPerg 	:= "CDMAPADESP"
	Local oFonteRel := TFont():New( "Arial", , 10, .F.)
	Local aBox		:={}
	Local aRet		:={}

	Private cDtDe 
	Private cDtAte

	//OBTEM OS PARAMETROS
	aAdd(aBox,{1,"Fechamento De:"  ,dDataBase,"","","","",50,.T.})
	aAdd(aBox,{1,"Fechamento Ate:"  ,dDataBase,"","","","",50,.T.})

	If ParamBox(aBox,"MAPA DE DESPESAS...",@aRet)

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
	Local oSection3

	oReport := TReport():New("MAPA DESPESAS","Mapa de Despesas" ,"CDMAPADESP",{|oReport| PrintReport(oReport)},"Mapa de Despesas")

	//Defini as sessões que teremos no relatorio
	oSection1 := TRSection():New(oReport,"SINTETICO" 				,"SZM")
	oSection2 := TRSection():New(oReport,"ANALITICO" 				,"SZM")
	oSection3 := TRSection():New(oReport,"CAIXAS" 					,"SZM")


	TRCell():New(oSection1,"E2_CLVLDB"			,"SE2"	,"NATUREZA")
	TRCell():New(oSection1,"CTH_DESC01"			,"CTH"	,"DESCRIÇÂO")
	TRCell():New(oSection1,"ZM_VALOR"			,"SZM"	,"TOTAL")
	TRFunction():New(oSection1:Cell("TOTAL")	,NIL,"SUM"	,NIL,"                       Valor Total ......."	,NIL,NIL,.F.,.T.,.F.)

	TRCell():New(oSection2,"SUP"				,"SZM"	,"")
	TRCell():New(oSection2,"SUB"				,"SE2"	,"")
	TRCell():New(oSection2,"ZM_NUMCX"			,"SZM"	,"")
	TRCell():New(oSection2,"ZM_DATA"			,"SZM"	,"")
	TRCell():New(oSection2,"E2_FORNECE"			,"SE2"	,"")
	TRCell():New(oSection2,"E2_NOMFOR"			,"SE2"	,"")
	TRCell():New(oSection2,"ZM_VALOR"			,"SZM"	,"")
	TRCell():New(oSection2,"E2_HIST"			,"SE2"	,"")

	//IMPRIMIR TOTALIZADORES POR BORDERO
	oBreak1 := TRBreak():New(oSection2,{ || oSection2:Cell("SUB"):uPrint },"Total ",.F.)
	TRFunction():New(oSection2:Cell("ZM_VALOR") ,"Total","SUM",oBreak1,"Total","@E 999,999,999.99",,.F.,.T.)


	TRCell():New(oSection3,"ZM_NUMCX"			,"SZM"	,"NRO.CAIXA")
	TRCell():New(oSection3,"ZM_DATA"			,"SZM"	,"DATA. CAIXA")
	TRCell():New(oSection3,"ZM_VALOR"			,"SZM"	,"TOTAL CAIXA")

	TRFunction():New(oSection3:Cell("ZM_VALOR")	,NIL,"SUM"	,NIL,"                       Valor Total ......."	,NIL,NIL,.F.,.T.,.F.)

	//Devolve o relatorio com estrutura de dados formada
	Return oReport

	*
	**************************************
Static Function PrintReport(oReport)
	**************************************
	*
	Local oSection1 	:= oReport:Section(1)
	Local oSection2 	:= oReport:Section(2)
	Local oSection3 	:= oReport:Section(3)
	Local cCabec		:= ""

	//SINTETICO
	oSection1:BeginQuery()

	BeginSql alias "SINT"

	SELECT E2_CLVLDB,CTH_DESC01, SUM(ZM_VALOR) AS ZM_VALOR

	FROM %table:SZM% SZM

	INNER JOIN %table:SE2% E2 ON		E2_FILIAL 		= SZM.ZM_FILIAL
	AND E2_PREFIXO	= SZM.ZM_PREFIXO
	AND E2_NUM		= SZM.ZM_NUMERO
	AND E2_PARCELA	= SZM.ZM_PARCELA
	AND E2_TIPO		= SZM.ZM_TIPO
	AND E2_FORNECE	= SZM.ZM_FORNEC
	AND E2_LOJA		= SZM.ZM_LOJA

	INNER JOIN %table:CTH% CTH ON E2_CLVLDB = CTH_CLVL	

	WHERE (ZM_DATA BETWEEN %Exp:cDtDe% AND %Exp:cDtAte%)

	AND E2.%NotDel% 
	AND SZM.%NotDel%
	AND CTH.%NotDel%
	AND E2_FILIAL = %xFilial:SE2%

	GROUP BY E2_CLVLDB,CTH_DESC01
	ORDER BY E2_CLVLDB,CTH_DESC01

	EndSql

	oSection1:EndQuery()    
	oSection1:Print()

	//ANALITICO
	oSection2:BeginQuery()

	BeginSql alias "ANALI"

	SELECT (RTRIM(CTH.CTH_CLSUP)+'-'+CT.CTH_DESC01) AS SUP,RTRIM(E2_CLVLDB)+'-'+LTRIM(CTH.CTH_DESC01) AS SUB,ZM_NUMCX,ZM_DATA,E2_FORNECE, E2_NOMFOR,ZM_VALOR,E2_HIST  

	FROM %table:SZM% SZM

	INNER JOIN %table:SE2% E2 	ON		E2_FILIAL 		= SZM.ZM_FILIAL
	AND E2_PREFIXO	= SZM.ZM_PREFIXO
	AND E2_NUM		= SZM.ZM_NUMERO
	AND E2_PARCELA	= SZM.ZM_PARCELA
	AND E2_TIPO		= SZM.ZM_TIPO
	AND E2_FORNECE	= SZM.ZM_FORNEC
	AND E2_LOJA		= SZM.ZM_LOJA

	INNER JOIN %table:CTH% CTH ON E2_CLVLDB = CTH.CTH_CLVL
	INNER JOIN %table:CTH% CT  ON CTH.CTH_CLSUP = CT.CTH_CLVL    

	WHERE (ZM_DATA BETWEEN %Exp:cDtDe% AND %Exp:cDtAte%)

	AND E2.%NotDel% 
	AND SZM.%NotDel%
	AND CTH.%NotDel%
	AND CT.%NotDel%
	AND E2_FILIAL = %xFilial:SE2%

	ORDER BY E2_CLVLDB

	EndSql

	oSection2:EndQuery()    
	oSection2:Print()

	oSection3:BeginQuery()

	BeginSql alias "CAIXA"

	SELECT ZM_NUMCX,ZM_DATA,SUM(ZM_VALOR) AS ZM_VALOR

	FROM %table:SZM% SZM

	INNER JOIN %table:SE2% E2 ON		E2_FILIAL 		= SZM.ZM_FILIAL
	AND E2_PREFIXO	= SZM.ZM_PREFIXO
	AND E2_NUM		= SZM.ZM_NUMERO
	AND E2_PARCELA	= SZM.ZM_PARCELA
	AND E2_TIPO		= SZM.ZM_TIPO
	AND E2_FORNECE	= SZM.ZM_FORNEC
	AND E2_LOJA		= SZM.ZM_LOJA

	INNER JOIN %table:CTH% CTH ON E2_CLVLDB = CTH_CLVL

	WHERE (ZM_DATA BETWEEN %Exp:cDtDe% AND %Exp:cDtAte%)

	AND E2.%NotDel% 
	AND SZM.%NotDel%
	AND CTH.%NotDel%

	AND E2_FILIAL = %xFilial:SE2%

	GROUP BY ZM_NUMCX,ZM_DATA
	ORDER BY ZM_NUMCX,ZM_DATA

	EndSql

	oSection3:EndQuery()    
	oSection3:Print()

Return