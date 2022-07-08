#INCLUDE 'PROTHEUS.CH'
#include "rwmake.ch"
#include "topconn.ch"

user function CBCeSocR()
	//CHAMADA VIA DEBUG, SEM PRECISAR ABRIR O SISTEMA
	//RPCSetType(3)
	//RPCSetEnv("01","0101","","","","",{"SX5"})
	
	Private cPerg       := "XMES5001"
	ValidPerg()
	Pergunte(cPerg,.T.) //Apresenta os parametros logo na entrada da rotina
	
	cLog 	   := ""
	cLogRes	   := ""
	cLogOk	   := ""
	cSem5001   := ""
	cDifSem5001 := ""
	cSem1200   := ""
	c2299      := ""
	cTpValT2T  := ""
	cDif		:= ""
	cVerbas    := "('"
	cRubricas  := "('"
	XcFilial   := MV_PAR01
	XcPeriodo  := MV_PAR02
	cArqLoc    := MV_PAR03
	cDifFol1200  := ""
	cDifFol5001  := ""
	cDif12005001 := ""
	cOK			 := ""
	nTotINSS	 := 0
	xcFil 		:= ' '

	nTotINSSSRD	:= 0
	aFunc		:= {}
	x	:= 0
	cFuncNaoTem := ""
	
	cArq := alltrim(cArqLoc) + "\" + XcFilial + "_" + MV_PAR02 + "_CONF_INSS_FUNCIONARIOS.TXT"  


	//VERIFICA O COMPARTILHAMENTO DA SRV E C8R
	xnTamFil := TamSX3("RV_FILIAL")[1] //PEGA O TAMANHO DO CAMPO
	xnLenSRV := LEN(ALLTRIM(XFILIAL("SRV")))
	
	xcEmp := FWModeAccess("SRV", 1) //EMPRESA
	xcUni := FWModeAccess("SRV", 2) //UNID NEGOCIO
	xcFil := FWModeAccess("SRV", 3) //FILIAL
	
	IF xcFil = 'C' .AND. xcUni = 'C' .AND. xcEmp = 'E'
		xcFil := substr(XcFilial,1,xnLenSRV)
	ElseIf xcEmp = 'C'
		xcFil := ' '
	EndIf
	
	If xcFil = 'C'
		xcFil := ''
	EndIf

	//VERIFICA O TIPO DO BANCO DE DADOS, PARA MONTAR A STRING DA SELEÇÃO DE DADOS
	//LINHA DE EXEMPLO
	//cSelect := If( "MSSQL" $ AllTrim(Upper(TcGetDb())) .Or. AllTrim(Upper(TcGetDb())) == 'SYBASE' , " SELECT TOP 1 ", " SELECT " )
	//cOracle := If( "ORACLE" $ AllTrim(Upper(TcGetDb())) , " AND ROWNUM <= 1 " , " " )
	//cDB2 	:= If( "DB2" $ AllTrim(Upper(TcGetDb())) , " FETCH FIRST 1 ROWS ONLY " , " "  )
	
	//VARIAVEL A SER UTILIZADA NO SELECT
	//TRATAMENTO APENAS PARA SQL E ORACLE
	xcSubStr := If("MSSQL" $ AllTrim(Upper(TcGetDb())),"SUBSTRING","SUBSTR")

	
	//PRIMEIRO PEGO AS VERBAS DO INSS DESCONTADO DO FUNCIONARIO 
	//0064 INSS
	//0065 INSS FERIAS
	//0070 INSS 13º
	//cQuery := " SELECT RV_CODFOL , RV_COD FROM " + RETSQLNAME("SRV") + " WHERE RV_CODFOL IN ('0064','0065','0070') AND D_E_L_E_T_ = ' ' "
	cQuery := " SELECT RV_CODFOL , RV_COD FROM " + RETSQLNAME("SRV") + " WHERE RV_FILIAL = '" + xcFil +;
	 				"' AND RV_CODFOL IN ('0064','0065','0070','0232','0222','0209') AND D_E_L_E_T_ = ' ' "
	TcQuery cQuery New Alias "QTEMP"
	DbSelectArea("QTEMP")
	While !Eof()
		cVerbas += QTEMP->RV_COD + "','"
		dbSkip()
	EndDo
	cVerbas += "')"
	QTEMP->(dbCloseArea())
	
	//AGORA VERIFICO A RUBRICA DESSAS VERBAS
	cQuery := " SELECT * FROM " + RETSQLNAME("C8R") + " WHERE C8R_FILIAL = '" + xcFil + "' AND C8R_CODRUB IN " + cVerbas + " AND D_E_L_E_T_ = ' '  AND C8R_ATIVO = '1'  AND C8R_STATUS = '4'"
	//cQuery := " SELECT * FROM " + RETSQLNAME("C8R") + " WHERE C8R_CODRUB IN " + cVerbas + " AND D_E_L_E_T_ = ' ' "
	TcQuery cQuery New Alias "QTEMP"
	DbSelectArea("QTEMP")
	While !Eof()
		cRubricas += QTEMP->C8R_ID + "','"
		dbSkip()
	EndDo
	cRubricas += "')"
	QTEMP->(dbCloseArea())
	
	//VERIFICO O CÓD DO TIPO 21 DA TABELA T2T, QUE ESTÁ NO RETORNO S-5001
	//21 - VALOR TOTAL DESCONTADO DO TRABALHADOR PARA RECOLHIMENTO À PREVIDÊNCIA SOCIAL
	cQuery := " SELECT * FROM " + RETSQLNAME("T2T") + " WHERE T2T_CODIGO = '21' AND D_E_L_E_T_ = ' ' "
	TcQuery cQuery New Alias "QTEMP"
	DbSelectArea("QTEMP")
	cTpValT2T += QTEMP->T2T_ID
	QTEMP->(dbCloseArea())
	
	
	//AGORA FAÇO A SELEÇÃO DE DADOS, COMPARANDO A SRD COM O QUE ESTÁ NO S-2299, S1200 E S5001
	cQuery := 	" SELECT RA_FILIAL , RA_MAT , RA_CIC , RA_NOME , C9V_ID , " 
	cQuery +=   "	SUM(RD_VALOR) AS VAL_FOLHA "  
	cQuery +=   "   FROM " + RETSQLNAME("SRD")+ " SRD " 
	cQuery +=   " INNER JOIN " + RETSQLNAME("SRA") + " SRA ON RA_FILIAL  = RD_FILIAL  AND RA_MAT     = RD_MAT     AND SRA.D_E_L_E_T_ = ' ' " 
	cQuery +=   " INNER JOIN " + RETSQLNAME("C9V") + " C9V ON C9V_FILIAL = RA_FILIAL  AND C9V_CPF    = RA_CIC     AND C9V.D_E_L_E_T_ = ' ' AND C9V_ATIVO  = '1' " 
	cQuery +=   " WHERE RD_FILIAL = '" + XcFilial + "' AND RD_PD IN " + cVerbas + " AND RD_PERIODO = '" + XcPeriodo + "' AND SRD.D_E_L_E_T_ = ' ' "
	cQuery +=   " GROUP BY RA_FILIAL , RA_MAT , RA_CIC , RA_NOME , C9V_ID " 
	cQuery +=   " ORDER BY RA_FILIAL, RA_MAT "
	
	TcQuery cQuery New Alias "QTEMP"
	DbSelectArea("QTEMP")
	While !Eof()

		//VERIFICA A S1200
		cQuery := 	" SELECT C91_PROTUL , SUM(C9M_VLRRUB) AS VAL_S1200 FROM " + RETSQLNAME("C91") + " C91 " + ; 
					" 	LEFT JOIN " + RETSQLNAME("C9M") + " C9M ON C9M_FILIAL = C91_FILIAL AND C9M_ID = C91_ID " + ;
					"	AND C9M.D_E_L_E_T_ = ' ' AND C9M_VERSAO = C91_VERSAO AND C9M_ID = C91_ID AND C9M_CODRUB IN " + cRubricas + ;
					" WHERE C91_FILIAL = '" + QTEMP->RA_FILIAL + "'  AND C91_TRABAL = '" + QTEMP->C9V_ID + "' " + ;
					" AND C91.D_E_L_E_T_ = ' ' AND C91_ATIVO  = '1' AND C91_PERAPU = '" + XcPeriodo + "' " + ;
					" GROUP BY C91_PROTUL "
		
		TcQuery cQuery New Alias "QS1200"
		DbSelectArea("QS1200")
		XVAL_S1200 	:= QS1200->VAL_S1200
		XPROTUL		:= ALLTRIM(QS1200->C91_PROTUL)
		QS1200->(dbCloseArea())

		//S-5001
		//ESSE TOTALIZADOR DEVE SER LEVADO EM CONSIDERAÇÃO O RECIBO
		//POIS A 5001 VOLTA SEMPRE PARA A MATRIZ
		cQuery := 	" SELECT SUM(T2R_VALOR) AS VAL_S5001 FROM " + RETSQLNAME("T2M") + " T2M" + ; 
					" 	LEFT  JOIN " + RETSQLNAME("T2R") + " T2R ON T2R_FILIAL = T2M_FILIAL AND T2R_ID = T2M_ID " + ;
					"	AND T2R.D_E_L_E_T_ = ' ' AND T2R_TPVLR  = '" + cTpValT2T + "' " + ;
					"   AND T2R_VERSAO = T2M_VERSAO " + ;
					" WHERE T2M_NRRECI = '" + XPROTUL + "' " + ;  //" WHERE T2M_FILIAL = '" + QTEMP->RA_FILIAL + "' AND T2M_CPFTRB = '" + QTEMP->RA_CIC + "' " + ;
					" AND T2M.D_E_L_E_T_ = ' ' AND T2M_PERAPU = '" + XcPeriodo + "' AND T2M_ATIVO = '1' " 
		TcQuery cQuery New Alias "QS5001"
		DbSelectArea("QS5001")
		XVAL_S5001 := QS5001->VAL_S5001
		QS5001->(dbCloseArea())
										 

		//S-2299
		cQuery := 	" SELECT SUM(T05_VLRRUB) AS VAL_S2299 FROM " + RETSQLNAME("T05") + " T05 " + ; 
					" 	LEFT  JOIN " + RETSQLNAME("CMD") + " CMD ON CMD_FILIAL = '" + QTEMP->RA_FILIAL + "' " + ;
					"	AND CMD_FUNC   = '" + QTEMP->C9V_ID + "' AND CMD.D_E_L_E_T_ = ' ' AND CMD_ATIVO  = '1' " + ;
					"	AND " + xcSubStr + "(CMD_DTDESL,1,6) = '" + xcPeriodo + "' " + ;
					"	AND CMD_VERSAO = T05_VERSAO " + ;
					" WHERE T05_FILIAL = CMD_FILIAL AND T05_ID = CMD_ID     AND T05.D_E_L_E_T_ = ' ' AND T05_CODRUB IN " + cRubricas 
		TcQuery cQuery New Alias "QS2299"
		DbSelectArea("QS2299")
		XVAL_S2299 := QS2299->VAL_S2299
		QS2299->(dbCloseArea())


		
		//AGORA MONTA O LOG
		cLog := QTEMP->RA_FILIAL + "   | " + QTEMP->RA_MAT + "    | " + QTEMP->RA_NOME + " | " + TRANSFORM(QTEMP->VAL_FOLHA,"@E 999,999.99") + " | " + TRANSFORM(XVAL_S1200,"@E 999,999.99") + " | " + TRANSFORM(XVAL_S2299,"@E 999,999.99") + " | " + TRANSFORM(XVAL_S5001,"@E 999,999.99") + " | " + CHR(13) + CHR(10)

		aadd(aFunc, { QTEMP->RA_MAT, QTEMP->RA_NOME } )
	
		nTotINSS += QTEMP->VAL_FOLHA
	
		//TEM 1200 MAS NAO TEM 5001 - PROBLEMA	
		If     (QTEMP->VAL_FOLHA > 0 .OR.  XVAL_S2299 = 0) .AND. XVAL_S1200 > 0 .AND. XVAL_S5001 = 0
			
			If QTEMP->VAL_FOLHA <> XVAL_S1200
				cDifSem5001 += cLog
			Else
				cSem5001 += cLog 
			EndIf
	
		//TEM FOLHA MAS NAO TEM 1200 - PROBLEMA	
		ElseIf (QTEMP->VAL_FOLHA > 0 .AND. XVAL_S2299 = 0) .AND. XVAL_S1200 = 0 .AND. XVAL_S5001 = 0
			
			cSem1200 += cLog 
					
		//NAO TEM 5001 MAS TEM 2299 E FOLHA - OK EM PARTES (TOTVS AINDA VAI DIZER SE É PRA TER 5001 OU NÃO)
		ElseIf (QTEMP->VAL_FOLHA > 0 .AND. XVAL_S2299 > 0) .AND. XVAL_S1200 = 0 .AND. XVAL_S5001 = 0
			
			c2299 += cLog
	
		//DEMAIS CASOS, AGORA COMPARA 
		ElseIf (QTEMP->VAL_FOLHA > 0 .AND. XVAL_S2299 = 0) .AND. XVAL_S1200 > 0 .AND. XVAL_S5001 > 0
			
			//DIFERENÇA ENTRE FOLHA E S1200
			If QTEMP->VAL_FOLHA <> XVAL_S1200
				cDifFol1200 += cLog
			//DIFERENÇA ENTRE FOLHA E S-5001
			ElseIf QTEMP->VAL_FOLHA <> XVAL_S5001
				cDifFol5001 += cLog
			//DIFERENÇA ENTRE S1200 E S5001
			ElseIf XVAL_S1200 <> XVAL_S5001
				cDif12005001 += cLog
			Else
				//VALOR OK
				cOK	+= cLog
			EndIf
		
		EndIf
		
		DbSelectArea("QTEMP")
		dbSkip()
	
	EndDo
	
	QTEMP->(dbCloseArea())

	//AGORA MONTA O LOG COMPLETO
	
	cTraco  := "=======|===========|================================|============|============|============|============|" + chr(13) + chr(10)
	cTraco1 := "========================================================================================================="
	
	cCAB   := "FILIAL | MATRICULA | NOME                           | FOLHA      | S-1200     | S-2299     | S-5001     |" + chr(13) + chr(10)
	cCab += cTraco
//	  														       | 999,999,99 | 999,999,99 | 999,999,99 | 999,999,99 |						


	If !Empty(cDifSem5001)
		cDifSem5001 := cTraco + "FUNCIONARIOS QUE POSSUEM VALORES NA FOLHA, MAS NÃO CONSTAM NA S-5001, COM VALORES DIVERGENTES" + CHR(13) + CHR(10) + cTraco + cCab + cDifSem5001 + CHR(13) + CHR(10)
	EndIf

	If !Empty(cSem5001)
		cSem5001 := cTraco + "FUNCIONARIOS QUE POSSUEM VALORES NA FOLHA, MAS NÃO CONSTAM NA S-5001, MAS VALORES ESTÃO OK" + CHR(13) + CHR(10) + cTraco + cCab + cSem5001 + CHR(13) + CHR(10)
	EndIf
	
	If !Empty(cSem1200)
		cSem1200 := cTraco + "FUNCIONARIOS QUE POSSUEM VALORES NA FOLHA, MAS NÃO CONSTAM NA S-1200" + CHR(13) + CHR(10) + cTraco + cCab + cSem1200 + CHR(13) + CHR(10)
	EndIf

	If !Empty(c2299)
		c2299 := cTraco + "FUNCIONARIOS DEMITIDOS - POSSUEM FOLHA E S-2299, MAS NÃO POSSUEM S-5001 (TOTVS IRÁ ANALISAR)" + CHR(13) + CHR(10) + cTraco + cCab + c2299 + CHR(13) + CHR(10)
	EndIf

	If !Empty(cDifFol1200)
		cDifFol1200 := cTraco + "DIVERGENCIA DE VALORES ENTRE FOLHA E S-1200" + CHR(13) + CHR(10) + cTraco + cCab + cDifFol1200 + CHR(13) + CHR(10)
	EndIf

	If !Empty(cDifFol5001)
		cDifFol5001 := cTraco + "DIVERGENCIA DE VALORES ENTRE FOLHA E S-5001" + CHR(13) + CHR(10) + cTraco + cCab + cDifFol5001 + CHR(13) + CHR(10)
	EndIf

	If !Empty(cDif12005001)
		cDif12005001 := cTraco + "DIVERGENCIA DE VALORES ENTRE S-1200 E S-5001" + CHR(13) + CHR(10) + cTraco + cCab + cDif12005001 + CHR(13) + CHR(10)
	EndIf

	If !Empty(cOK)
		cOK := cTraco + "VALORES OK ENTRE FOLHA, S-1200 E S-5001" + CHR(13) + CHR(10) + cTraco + cCab + cOK + CHR(13) + CHR(10)
	EndIf

	
	//AGORA MONTA O LOG PRA SABER O TOTAL DA SRD DAS VERBAS DO INSS, SEM VINCULAR A NENHUMA MATRICULA
	cQuery := 	" SELECT RD_FILIAL , RD_MAT , RA_NOME , SUM(RD_VALOR) AS RD_VALOR FROM " + RETSQLNAME("SRD") + " SRD " + ;
				" INNER JOIN " + RETSQLNAME("SRA") + " SRA ON RA_FILIAL = RD_FILIAL AND RA_MAT = RD_MAT AND SRA.D_E_L_E_T_ = ' ' " + ;
				" WHERE RD_FILIAL = '" + XcFilial + "' AND RD_PERIODO = '" + XcPeriodo + "' AND RD_PD IN " + cVerbas + " AND SRD.D_E_L_E_T_ = ' ' " + ;
				" GROUP BY RD_FILIAL,RD_MAT,RA_NOME " + ;
				" ORDER BY RD_FILIAL,RD_MAT "
				
	TcQuery cQuery New Alias "QTEMP"
	DbSelectArea("QTEMP")
	While !Eof()

		lAchou := .F.
		
		nTotINSSSRD += QTEMP->RD_VALOR

		//Procura o funcionário no select anterior
		For x := 1 to Len(aFunc)
			
			If aFunc[x][1] == QTEMP->RD_MAT
			
				lAchou := .T.
			
			EndIf
		Next

		If !lAchou
			cFuncNaoTem += QTEMP->RD_FILIAL + "   | " + QTEMP->RD_MAT + "    | " + QTEMP->RA_NOME + " | " + TRANSFORM(QTEMP->RD_VALOR,"@E 999,999.99") + CHR(13) + CHR(10)
		EndIf

		DbSelectArea("QTEMP")
		dbSkip()
	EndDo
	QTEMP->(dbCloseArea())
	
	If nTotINSS <> nTotINSSSRD
		cDif := "EXISTE DIFERENÇA ENTRE O TOTAL DA FOLHA COM O TOTAL AQUI APURADO. FAVOR VERIFICAR:" + CHR(13) + CHR(10) 
		cDif += "VALOR TOTAL NA FOLHA: " + TRANSFORM(nTotINSSSRD,"@E 999,999,999.99") + CHR(13) + CHR(10)
		cDif += "VALOR AQUI APURADO:   " + TRANSFORM(nTotINSS   ,"@E 999,999,999.99") + CHR(13) + CHR(10)
	EndIf

	If !(Empty(cFuncNaoTem))
		cDif += CHR(13) + CHR(10)
		cDif += "FUNCIONÁRIOS NÃO LISTADOS AQUI, MAS CONTEM VALORES DE INSS NA FOLHA" + CHR(13) + CHR(10)
		cDif += "POSSIVEIS MOTIVOS PARA ESSE PROBLEMA:" + CHR(13) + CHR(10)
		//cDif += " - CAMPO C9V_MATRIC PREENCHIDO E RA_CODUNIC NÃO, OU VICE-E-VERSA;" + CHR(13) + CHR(10)
		//cDif += " - CAMPO C9V_MATRIC DIFERENTE DO RA_CODUNIC;" + CHR(13) + CHR(10)
		cDif += " - NÃO EXISTIR O CADASTRO NO TAF" + CHR(13) + CHR(10) + CHR(13) + CHR(10)
		cDif += "FILIAL | MATRICULA | NOME                           | VALOR INSS FOLHA (SRD)" + CHR(13) + CHR(10)
		cDif += cFuncNaoTem
		cDif += " "
	End

	cLogINSS := chr(13) + chr(10) + chr(13) + chr(10) + cTraco1 + chr(13) + chr(10) + "TOTAL INSS DESCONTADO DOS FUNCIONÁRIOS/AUTONOMOS/PRÓ-LABORE: " + Transform(nTotINSS,"@E 999,999,999.99")+ chr(13) + chr(10) + chr(13) + cDif + chr(10) + cTraco1 + chr(13) + chr(10) + chr(13) + chr(10)


	cLogFim := cSem5001 + cSem1200 + cDifFol1200 + cDifFol5001 + cDif12005001 + c2299 + cOK + cLogINSS

	MemoWrite(CARQ , CLOGFIM)
	
	MsgBox("Arquivo de LOG " + cArq + " gerado com sucesso!","Arquivo Log","INFO")

Return

//Perguntas da execução do Calculo
Static Function ValidPerg()
	Local _sAlias,i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs:={}
	
			  //Grupo/Ordem/Pergunta				/espanhol	/ingles	/Variavel/Tipo/Tamanho/Decimal/Presel/ GSC /Valid /Var01	 /Def01 /DefSpa/DefEng/Cnt01/Var02/Def02/DefEsp/DefEng/Cnt02/Var03/Def03/DefEst/DefEng/Cnt03/Var04/Def04/Def4Esp/Def4Eng/Cnt04/Var05/Def05/Def5Esp/Def5Eng/Cnt05/ f3  /pyme/grpsxg/help/picture/idfil/
	AADD(aRegs,{cPerg,"01","Filial 				"	,"Espanhol","Ingles","mv_ch1","C",TamSX3("RA_FILIAL")[1],		0,		0,	"G",	"","mv_par01",""	,""	   ,""    ,""   ,""   ,""   ,""    ,""    ,""   ,""   ,""   ,""    ,""    ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"SM0", ""})
	AADD(aRegs,{cPerg,"02","Periodo				" 	,"Espanhol","Ingles","mv_ch2","C",06      				,		0,		0,	"G",	"","mv_par02",""	,""	   ,""    ,""   ,""   ,""   ,""    ,""    ,""   ,""   ,""   ,""    ,""    ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"", ""})
	AADD(aRegs,{cPerg,"03","Local arquivo log	"	,"Espanhol","Ingles","mv_ch3","C",99     				,		0,		0,	"G",	"","mv_par03",""	,""	   ,""    ,""   ,""   ,""   ,""    ,""    ,""   ,""   ,""   ,""    ,""    ,""   ,""   ,""   ,""     ,""     ,""   ,""   ,""   ,""     ,""     ,""   ,"", ""})
	For i:=1 to Len(aRegs)
		
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
				For j:=1 to FCount()
					If j <= Len(aRegs[i])
						FieldPut(j,aRegs[i,j])
					Endif
				Next
			MsUnlock()
			dbCommit()
		EndIf
	Next
	dbSelectArea(_sAlias)
Return


/*
IR - A DESENVOLVER

SELECT RD_PD , RD_VALOR , RD_PERIODO , RA_FILIAL , RA_MAT , RA_CIC , RA_NOME , C9V_ID FROM SRD010 SRD
INNER JOIN SRA010 SRA ON RA_FILIAL  = RD_FILIAL  AND RA_MAT     = RD_MAT AND SRA.D_E_L_E_T_ = ' '
INNER JOIN C9V010 C9V ON C9V_FILIAL = RA_FILIAL  AND C9V_CPF    = RA_CIC AND C9V.D_E_L_E_T_ = ' ' AND C9V_ATIVO  = '1'
WHERE RD_FILIAL = '1010' AND RD_MAT = '000830' AND ( (RD_PD IN ('710') AND RD_PERIODO = '201805') OR (RD_PD IN ('405') AND RD_PERIODO = '201804')) AND SRD.D_E_L_E_T_ = ' '


--ID 0009 - 710 - IR ADI
--ID 0066 - 405 - IR MES



*/
