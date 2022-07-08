#Include 'Protheus.ch'

User Function cbcZBARelat(lAuto,cNroDoc, cOper)
	
	local oReport		:= nil
	local cPerg 		:= "RELBX"
	local oFonteRel 	:= TFont():New( "Arial", , 07, .T.)
	local aTRB 		:= {}
	default lAuto 	:= .T.
	default cNroDoc 	:= ""
	
	if lAuto
		Pergunte(cPerg, .T.)
		if  mv_Par02 == 1
			oReport := ReportDef("BXDB")
		elseif mv_Par02 == 2
			oReport := ReportDef("DESC")
		elseif mv_Par02 == 3
			oReport := ReportDef("PRO")
		elseif mv_Par02 == 4
			oReport := ReportDef("PROT")
		elseif mv_Par02 == 5
			oReport := ReportDef("SUB")
		endif
	else
		mv_Par01 := cNroDoc
		oReport := ReportDef(cOper)
	endif
	
	//Configurações do relatorio
	oReport:OFONTBODY 	:= oFonteRel
	oReport:NFONTBODY 	:= 06
	oReport:NLINEHEIGHT 	:= 40
	oReport:LBOLD			:= .T.
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:PrintDialog()
Return(nil)


Static Function ReportDef(cOper)
	local oReport
	local oSection1
	local oSection2
	local cCabec		:= ""
	
	oReport := TReport():New("Contas a receber","Relatorio - N.  " + AllTrim(mv_Par01) ,"RELFIN",{|oReport| PrintReport(oReport,cOper)},"RELSFIN")
	// dois layouts diferentes de relatorios (baixar e substituir é muito diferente dos outros)
	if cOper == 'SUB'
		//Defini as sessões que teremos no relatorio
		oSection1 := TRSection():New(oReport,"Titulo Baixado" ,"ZBA")
		oSection2 := TRSection():New(oReport,"Substituir Por" ,"ZBA")
		oSection3 := TRSection():New(oReport,"TEXTO" ,"ZBA")
		
		//Celulas (Titulo baixado)
		TRCell():New(oSection1,"ZBA_NOMCLI"			,"ZBA","CLIENTE")
		TRCell():New(oSection1,"ZBA_EMISS"			,"ZBA","EMISSAO")
		TRCell():New(oSection1,"ZBA_NUM"			,"ZBA","DUPLICATA")
		TRCell():New(oSection1,"ZBA_PARC"			,"ZBA","PARCELA")
		TRCell():New(oSection1,"ZBA_VALOR"			,"ZBA","VALOR")
		TRCell():New(oSection1,"ZBA_VENCTO"			,"ZBA","VENCIMENTO")
		TRCell():New(oSection1,"ZBA_OPER"			,"ZBA","OPERACAO")
		TRCell():New(oSection1,"ZBA_HISTOP"			,"ZBA","HISTORICO")
		//Celulas (Titulo novo)
		TRCell():New(oSection2,"ZBA_NOMCLI"			,"ZBA","CLIENTE")
		TRCell():New(oSection2,"ZBA_EMISS"			,"ZBA","EMISSAO")
		TRCell():New(oSection2,"ZBA_NUM"			,"ZBA","DUPLICATA")
		TRCell():New(oSection2,"ZBA_PARC"			,"ZBA","PARCELA")
		TRCell():New(oSection2,"ZBA_VALOR"			,"ZBA","VALOR")
		TRCell():New(oSection2,"ZBA_VENCTO"			,"ZBA","VENCIMENTO")
		TRCell():New(oSection2,"ZBA_OPER"			,"ZBA","OPERACAO")
		//Celulas (Campos assinatura)
		//Tipo de dados para a Sessão criada com os parametros sem dicioanario
		TRCell():New(oSection3,"TEXTO" 				,"" ,"" ,"@!"/*Picture*/,190/*Tamanho*/,/*lPixel*/,/*{|| "" }*/,"",.T.,"")
		
		//Operações e totalizadores
		TRFunction():New(oSection1:Cell("ZBA_VALOR"),NIL,"SUM"	,NIL,"                       Total Baixado......."	,NIL,NIL,.F.,.T.,.F.)
		TRFunction():New(oSection2:Cell("ZBA_VALOR"),NIL,"SUM"	,NIL,"                       Total Novo.........."	,NIL,NIL,.F.,.T.,.F.)
		
	else
		//Defini as sessões que teremos no relatorio
		oSection1 := TRSection():New(oReport,"Baixa Debita" ,"ZBA")
		oSection2 := TRSection():New(oReport,"De" 			,"ZBA")
		
		//Celulas
		TRCell():New(oSection1,"ZBA_NOMCLI"			,"ZBA","CLIENTE")
		TRCell():New(oSection1,"ZBA_EMISS"			,"ZBA","EMISSAO")
		TRCell():New(oSection1,"ZBA_NUM"			,"ZBA","DUPLICATA")
		TRCell():New(oSection1,"ZBA_PARC"			,"ZBA","PARCELA")
		TRCell():New(oSection1,"ZBA_VALOR"			,"ZBA","VALOR")
		TRCell():New(oSection1,"ZBA_VENCTO"			,"ZBA","VENCIMENTO")
		TRCell():New(oSection1,"ZBA_OPER"			,"ZBA","OPERACAO")
		
		if cOper == "BXDB"
			TRCell():New(oSection1,"ZBA_BAIXA"		,"ZBA","DIA.REC.")
			TRCell():New(oSection1,"ZBA_VLROPE"		,"ZBA","VLR.BAIXA")
		elseif cOper == "DESC"
			TRCell():New(oSection1,"ZBA_VLROPE"		,"ZBA","VALOR")
		elseif	cOper == "PRO"
			TRCell():New(oSection1,"ZBA_VENCRE"		,"ZBA","Venc.Real")
		endif
		
		TRCell():New(oSection1,"ZBA_HISTOP"			,"ZBA","HISTORICO")
		
		if cOper == "BXDB"
			TRFunction():New(oSection1:Cell("ZBA_VLROPE"),NIL,"SUM"	,NIL," Total Relatorio......."	,NIL,NIL,.F.,.T.,.F.)
		elseif cOper == "PROT"
			TRFunction():New(oSection1:Cell("ZBA_VALOR"),NIL,"SUM",NIL," Total Relatorio......."	,NIL,NIL,.F.,.T.,.F.)
		elseif cOper == "DESC"
			TRFunction():New(oSection1:Cell("ZBA_VLROPE"),NIL,"SUM"	,NIL,"  Total Descontos......."	,NIL,NIL,.F.,.T.,.F.)
		endif
		
		TRCell():New(oSection2,"De" 				,"" ,"" ,"@!"/*Picture*/,190/*Tamanho*/,/*lPixel*/,/*{|| "" }*/,"",.T.,"")
	endif
return (oReport)


Static Function PrintReport(oReport,cOper)
	local oSection1 	:= oReport:Section(1)
	local oSection2 	:= oReport:Section(2)
	local oSection3	:= oReport:Section(3)
	local cCabec		:= ""
	local cSQL		:= ""
	local cSQL1		:= ""

	// etrutura do baixar e substituir é muito diferente (feito isaladamente)
	if cOper == "SUB"

		// where dos titulos antigos
		cSQL += "AND ZBA.ZBA_OPER = 'BAIXAR' AND  ZBA.ZBA_NROREL ='" + AllTrim(mv_Par01) + "'"
		cSQL += "AND ZBA.ZBA_BAIXA <> '' "
		cSQL := "%"+cSQL+"%"

		// where dos titulos novos
		cSQL1 += "AND ZBA.ZBA_OPER = 'SUBSTITUIR' AND  ZBA.ZBA_NROREL ='" + AllTrim(mv_Par01) + "'"
		cSQL1 += "AND ZBA.ZBA_BAIXA = '' "
		cSQL1 := "%"+cSQL1+"%"

		// query dos titulos antigos
		oSection1:BeginQuery()
		BeginSql alias "ANTIGO"

			SELECT	ZBA.ZBA_NOMCLI,ZBA.ZBA_EMISS, ZBA.ZBA_NUM, ZBA.ZBA_PARC, ZBA.ZBA_VALOR,
			ZBA.ZBA_VENCTO, ZBA.ZBA_OPER ,ZBA.ZBA_HISTOP
			FROM %table:ZBA% ZBA
			WHERE ZBA.%NotDel%  %Exp:cSQL%
			ORDER BY ZBA.ZBA_VENCTO
		EndSql
		oSection1:EndQuery()
		oSection1:Print()
		oSection1:Finish()

		// query dos titulos novos
		oSection2:BeginQuery()
		BeginSql alias "NOVO"
			SELECT	ZBA.ZBA_NOMCLI,ZBA.ZBA_EMISS, ZBA.ZBA_NUM, ZBA.ZBA_PARC, ZBA.ZBA_VALOR,
			ZBA.ZBA_VENCTO, ZBA.ZBA_OPER ,ZBA.ZBA_HISTOP

			FROM %table:ZBA% ZBA

			WHERE ZBA.%NotDel%  %Exp:cSQL1%
			ORDER BY ZBA.ZBA_VENCTO
		EndSql
		oSection2:EndQuery()
		oSection2:Print()
		oSection2:Finish()

		cCabec += CRLF+CRLF
		cCabec += CRLF+CRLF
		cCabec += "   _____________________             ______________________________________                   ___________________________________" 							+ CRLF
		cCabec += "         "+Alltrim(Upper(cUserName))+    "                      RAFAEL V. RUAS / GUSTAVO V. RUAS                          (CONFERIDO)-Andrei S.M. dos Anjos" 	+ CRLF
		cCabec += "  DEPTO.CONTAS A RECEBER                           DIRETORIA                                           Contas a Receber"										+ CRLF

		oSection3:Init()

		oSection3:ACELL[1]:UVALUE := cCabec
		oSection3:ACELL[1]:LBOLD := .T.
		oSection3:ACELL[1]:LCELLBREAK := .T.

		oSection3:PrintLine()
		oSection3:Finish()
	else
		
		if cOper == "BXDB"
			cSQL += " AND ZBA.ZBA_FILIAL = '"+  xFilial('ZBA')  +"'"
			cSQL += " AND ZBA.ZBA_NROREL ='" + AllTrim(mv_Par01) + "'"
		elseif cOper == "PROT"
			cSQL += "AND ZBA.ZBA_FILIAL = '"+  xFilial('ZBA')  +"'"
			cSQL += "AND ZBA.ZBA_OPER ='BAIXAR E DEBITAR PROTESTO'  AND ZBA.ZBA_NROREL ='" + AllTrim(mv_Par01) + "'"
		elseif cOper == "DESC"
			cSQL += " AND ZBA.ZBA_FILIAL = '"+  xFilial('ZBA')  +"'"
			cSQL += " AND (ZBA.ZBA_OPER = 'DESCONTO' OR ZBA.ZBA_OPER = 'DESC. NÃO DEBITAR' OR ZBA.ZBA_OPER = 'DESCONTO NCC') "
			cSQL += " AND  ZBA.ZBA_NROREL ='" + AllTrim(mv_Par01) + "'"
		elseif cOper == "PRO"
			cSQL += " AND ZBA.ZBA_FILIAL = '"+  xFilial('ZBA')  +"'"
			cSQL += "AND ZBA.ZBA_OPER = 'PRORROGACAO' AND  ZBA.ZBA_NROREL ='" + AllTrim(mv_Par01) + "'"
		endif

		cSQL := "%"+cSQL+"%"
		oSection1:BeginQuery()

		if cOper == "BXDB"
			BeginSql alias "QRYBXDBT"
				// quando mudar esta query mudar a do vvista.prw tambem
				SELECT	ZBA.ZBA_NOMCLI,ZBA.ZBA_EMISS, ZBA.ZBA_NUM, ZBA.ZBA_PARC, ZBA.ZBA_VALOR,
				ZBA.ZBA_VENCTO, ZBA.ZBA_OPER , ZBA.ZBA_BAIXA, ZBA.ZBA_VLROPE, ZBA.ZBA_HISTOP

				FROM %table:ZBA% ZBA

				WHERE ZBA.%NotDel%  %Exp:cSQL%
				ORDER BY ZBA.ZBA_VENCTO
			EndSql

		elseif cOper == "PROT"
			BeginSql alias "QRYPROT"
				SELECT	ZBA.ZBA_NOMCLI,ZBA.ZBA_EMISS, ZBA.ZBA_NUM, ZBA.ZBA_PARC,
				((ZBA.ZBA_SALDO + ZBA.ZBA_SDACRE) - ZBA.ZBA_SLDESC) AS ZBA_VALOR,
				ZBA.ZBA_VENCTO, ZBA.ZBA_OPER ,ZBA.ZBA_HISTOP

				FROM %table:ZBA% ZBA

				WHERE ZBA.%NotDel% %Exp:cSQL%
				ORDER BY ZBA.ZBA_VENCTO
			EndSql

		elseif cOper == "DESC"
			BeginSql alias "QRYDESC"
				SELECT	ZBA.ZBA_NOMCLI,ZBA.ZBA_EMISS, ZBA.ZBA_NUM, ZBA.ZBA_PARC, ZBA.ZBA_VALOR,
				ZBA.ZBA_VENCTO, ZBA.ZBA_OPER ,ZBA.ZBA_VLROPE, ZBA.ZBA_HISTOP

				FROM %table:ZBA% ZBA

				WHERE ZBA.%NotDel% %Exp:cSQL%
				ORDER BY ZBA.ZBA_VENCTO
			EndSql

		elseif cOper == "PRO"
			BeginSql alias "QRYPRO"
				SELECT	ZBA.ZBA_NOMCLI,ZBA.ZBA_EMISS, ZBA.ZBA_NUM, ZBA.ZBA_PARC, ZBA.ZBA_VALOR,
				ZBA.ZBA_VENORI, ZBA.ZBA_OPER ,ZBA.ZBA_VENCRE, ZBA.ZBA_HISTOP,ZBA_VENCTO

				FROM %table:ZBA% ZBA

				WHERE ZBA.%NotDel% %Exp:cSQL%
				ORDER BY ZBA.ZBA_VENCTO
			EndSql
		endif

		oSection1:EndQuery()
		oSection1:Print()
		oSection1:Finish()

		cCabec += CRLF+CRLF
		cCabec += CRLF+CRLF
		cCabec += "   _____________________             ______________________________________                   ___________________________________" 							+ CRLF
		cCabec += "         "+Alltrim(Upper(cUserName))+    "                      RAFAEL V. RUAS / GUSTAVO V. RUAS                          (CONFERIDO)-Andrei S.M. dos Anjos" 	+ CRLF
		cCabec += "  DEPTO.CONTAS A RECEBER                           DIRETORIA                                           Contas a Receber"										+ CRLF

		oSection2:Init()

		oSection2:ACELL[1]:UVALUE 		:= cCabec
		oSection2:ACELL[1]:LBOLD 		:= .T.
		oSection2:ACELL[1]:LCELLBREAK 	:= .T.
		oSection2:PrintLine()
		oSection2:Finish()

	endif
	
return(nil)
