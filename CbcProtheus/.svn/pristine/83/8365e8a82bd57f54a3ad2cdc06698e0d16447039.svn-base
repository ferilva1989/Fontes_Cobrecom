#include 'protheus.ch'
#include 'parmtype.ch'
#include 'TOTVS.ch'

static function qryTable(dDtFim, cTable)
    local cQry := ""

    cQry += "SELECT SC9.C9_FILIAL AS [FILIAL], "
    cQry += "SC9.C9_PRODUTO AS [PRODUTO], "
    cQry += "SB1.B1_DESC AS [DESCRI], "
    cQry += "CASE  "
    cQry += "	WHEN SB1.B1_LOCALIZ = 'S' "
    cQry += "		THEN SC6.C6_ACONDIC + REPLICATE('0',(5- LEN(SC6.C6_METRAGE))) + CAST(SC6.C6_METRAGE AS VARCHAR(5))  "
    cQry += "	ELSE '' "
    cQry += "END AS [ACONDIC], "
    cQry += "CASE "
    cQry += "	WHEN (SC9.C9_FILIAL = '01' AND (SB1.B1_ZZFILFB = 1 OR SB1.B1_ZZFILFB = 3)) "
    cQry += "		THEN 'PRODUZIDO' "
    cQry += "	WHEN (SC9.C9_FILIAL = '02' AND (SB1.B1_ZZFILFB = 2 OR SB1.B1_ZZFILFB = 3)) "
    cQry += "		THEN 'PRODUZIDO' "
    cQry += "	ELSE 'TRANSFERIDO' "
    cQry += "END AS [TIPO], "
    cQry += "SUM(SC9.C9_QTDLIB) AS [NECESSI], "
    cQry += "ISNULL(ZAI.ZAI_ESTSEG, 0) AS [SEGURO], "
    cQry += "ISNULL(ZAI.ZAI_LTECON, 0) AS [ECONOM], "
    cQry += "CASE  "
    cQry += "	WHEN SB1.B1_LOCALIZ = 'S' "
    cQry += "		THEN SUM(ISNULL(EST.QTDORIG,0)) "
    //cQry += "		THEN SUM((ISNULL(SBF.BF_QUANT,0)-ISNULL(SBF.BF_EMPENHO,0))) "
    cQry += "	ELSE SUM(SB2.B2_QATU - SB2.B2_RESERVA) "
    cQry += "END AS [ESTOQUE], "
    cQry += "ISNULL(( "
    cQry += "				SELECT SUM(SSC9.C9_QTDLIB) "
    cQry += "				FROM " + RetSqlName('SC9') + " AS SSC9 "
    cQry += "				INNER JOIN " + RetSqlName('SC6') + " SSC6 ON SSC9.C9_FILIAL = SSC6.C6_FILIAL "
    cQry += "									AND SSC9.C9_PEDIDO = SSC6.C6_NUM "
    cQry += "									AND SSC9.C9_ITEM = SSC6.C6_ITEM "
    cQry += "									AND SSC9.D_E_L_E_T_ = SSC6.D_E_L_E_T_ "
    cQry += "				INNER JOIN " + RetSqlName('SA1') + " SSA1 ON '' = SSA1.A1_FILIAL "
    cQry += "									AND SSC6.C6_CLI = SSA1.A1_COD "
    cQry += "									AND SSC6.C6_LOJA = SSA1.A1_LOJA "
    cQry += "									AND SSC6.D_E_L_E_T_ = SSA1.D_E_L_E_T_ "
    cQry += "				INNER JOIN " + RetSqlName('SF4') + " SSF4 ON '' = SSF4.F4_FILIAL "
    cQry += "									AND SSC6.C6_TES = SSF4.F4_CODIGO "
    cQry += "									AND SSC6.D_E_L_E_T_ = SSF4.D_E_L_E_T_ "
    cQry += "				WHERE SSC9.C9_FILIAL <> SC9.C9_FILIAL "
    cQry += "				AND SSC9.C9_BLCRED = '' "
    cQry += "				AND SSC9.D_E_L_E_T_ = '' "
    cQry += "				AND SSF4.F4_ESTOQUE = 'S' "
    cQry += "				AND SSA1.A1_FILTRF = SC9.C9_FILIAL "
    cQry += "				AND SSC6.C6_BLQ <> 'S' "
    cQry += "				AND SSC6.C6_PRODUTO = SC9.C9_PRODUTO "
    cQry += "				AND SSC6.C6_ACONDIC + REPLICATE('0',(5- LEN(SSC6.C6_METRAGE))) + CAST(SSC6.C6_METRAGE AS VARCHAR(5)) = SC6.C6_ACONDIC + REPLICATE('0',(5- LEN(SC6.C6_METRAGE))) + CAST(SC6.C6_METRAGE AS VARCHAR(5)) "
    cQry += "),0) AS [SOLICIT], "
    cQry += "ISNULL(( "
    cQry += "				SELECT SUM(SD2.D2_QUANT) "
    cQry += "				FROM " + RetSqlName('SD2') + " SD2 "
    cQry += "				INNER JOIN " + RetSqlName('SF4') + " SSSF4 ON '' = SSSF4.F4_FILIAL "
    cQry += "										AND SD2.D2_TES = SSSF4.F4_CODIGO "
    cQry += "										AND SD2.D_E_L_E_T_ = SSSF4.D_E_L_E_T_ "
    cQry += "				INNER JOIN " + RetSqlName('SA1') + " SA1 ON '' = SA1.A1_FILIAL "
    cQry += "										AND SD2.D2_CLIENTE = SA1.A1_COD "
    cQry += "										AND SD2.D2_LOJA = SA1.A1_LOJA "
    cQry += "										AND SD2.D_E_L_E_T_ = SA1.D_E_L_E_T_ "
    cQry += "				INNER JOIN " + RetSqlName('SF2') + " SF2 ON SD2.D2_FILIAL = SF2.F2_FILIAL "
    cQry += "										AND SD2.D2_DOC = SF2.F2_DOC "
    cQry += "										AND SD2.D2_SERIE = SF2.F2_SERIE "
    cQry += "										AND SD2.D_E_L_E_T_ = SF2.D_E_L_E_T_ "
    cQry += "				WHERE SD2.D2_FILIAL <> SC9.C9_FILIAL "
    cQry += "				AND SD2.D2_COD = SC9.C9_PRODUTO "
    cQry += "				AND SD2.D2_LOCALIZ = SC6.C6_ACONDIC + REPLICATE('0',(5- LEN(SC6.C6_METRAGE))) + CAST(SC6.C6_METRAGE AS VARCHAR(5)) "
    cQry += "				AND SSSF4.F4_ESTOQUE = 'S' "
    cQry += "				AND SA1.A1_FILTRF = SC9.C9_FILIAL "
    cQry += "				AND SD2.D_E_L_E_T_ = '' "
    cQry += "				AND SD2.D2_EMISSAO >= '20210101' "
    cQry += "				AND SF2.F2_CHVNFE NOT IN ( "
    cQry += "											SELECT SF1.F1_CHVNFE "
    cQry += "											FROM " + RetSqlName('SF1') + " SF1 "
    cQry += "											WHERE SF1.F1_FILIAL = SC9.C9_FILIAL "
    cQry += "											AND SF1.F1_CHVNFE = SF2.F2_CHVNFE "
    cQry += "											AND SF1.D_E_L_E_T_ = SF2.D_E_L_E_T_ "
    cQry += "				) "
    cQry += "),0) AS [TRANSIT], "
    cQry += " 0 AS [MRP], "
    cQry += " 0 AS [EXCEDE], "
    cQry += " 0 AS [PRODUZ], "
    cQry += " 0 AS [TRANSF], "
    cQry += " 0 AS [ESA], "
    cQry += " 0 AS [RETRAB], "
    cQry += " SC6.C6_METRAGE AS [METRAGE] "
    cQry += "FROM " + RetSqlName('SC9') + " SC9 "
    cQry += "INNER JOIN " + RetSqlName('SC6') + " SC6 ON SC9.C9_FILIAL = SC6.C6_FILIAL "
    cQry += "					AND SC9.C9_PEDIDO = SC6.C6_NUM "
    cQry += "					AND SC9.C9_ITEM = SC6.C6_ITEM "
    cQry += "					AND SC9.D_E_L_E_T_ = SC6.D_E_L_E_T_ "
    cQry += "INNER JOIN " + RetSqlName('SF4') + " SF4 ON '' = SF4.F4_FILIAL "
    cQry += "					AND SC6.C6_TES = SF4.F4_CODIGO "
    cQry += "					AND SC6.D_E_L_E_T_ = SF4.D_E_L_E_T_ "
    cQry += "INNER JOIN " + RetSqlName('SB1') + " SB1 ON '' = SB1.B1_FILIAL "
    cQry += "						AND SC9.C9_PRODUTO = SB1.B1_COD "
    cQry += "						AND SC9.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
    cQry += "LEFT JOIN " + RetSqlName('ZAI') + " ZAI ON SC6.C6_FILIAL = ZAI.ZAI_FILIAL "
    cQry += "						AND SC6.C6_PRODUTO = ZAI.ZAI_COD "
    cQry += "						AND SC6.C6_ACONDIC + REPLICATE('0',(5- LEN(SC6.C6_METRAGE))) + CAST(SC6.C6_METRAGE AS VARCHAR(5)) = ZAI.ZAI_ACOND "
    cQry += "						AND SC6.D_E_L_E_T_ = ZAI.D_E_L_E_T_ "
    cQry += "LEFT JOIN " + cTable + " EST ON SC6.C6_FILIAL = EST.FILIAL "
    cQry += "						AND SC6.C6_PRODUTO = EST.PRODUTO "
    cQry += "						AND SC6.C6_ACONDIC + REPLICATE('0',(5- LEN(SC6.C6_METRAGE))) + CAST(SC6.C6_METRAGE AS VARCHAR(5)) = EST.ACONDIC "
    /*
    cQry += "LEFT JOIN " + RetSqlName('SBF') + " SBF ON SC6.C6_FILIAL = SBF.BF_FILIAL "
    cQry += "						AND SC6.C6_PRODUTO = SBF.BF_PRODUTO "
    cQry += "						AND SC6.C6_ACONDIC + REPLICATE('0',(5- LEN(SC6.C6_METRAGE))) + CAST(SC6.C6_METRAGE AS VARCHAR(5)) = SBF.BF_LOCALIZ "
    cQry += "						AND SB1.B1_LOCPAD  = SBF.BF_LOCAL "
    cQry += "						AND SC6.D_E_L_E_T_ = SBF.D_E_L_E_T_ "
    */
    cQry += "INNER JOIN " + RetSqlName('SB2') + " SB2 ON SC9.C9_FILIAL = SB2.B2_FILIAL "
    cQry += "						AND SC9.C9_PRODUTO = SB2.B2_COD "
    cQry += "						AND SB1.B1_LOCPAD  = SB2.B2_LOCAL "
    cQry += "						AND SC9.D_E_L_E_T_ = SB2.D_E_L_E_T_ "
    cQry += "WHERE SC9.C9_FILIAL IN ('01','02','03') "
    cQry += "AND SC9.C9_BLEST = '02' "
    cQry += "AND SC9.C9_BLCRED = '' "
    cQry += "AND SC9.D_E_L_E_T_ = '' "
    cQry += "AND SF4.F4_ESTOQUE = 'S' "
    cQry += "AND SB1.B1_TIPO = 'PA' "
    cQry += "AND SC6.C6_BLQ <> 'R' "
    cQry += "AND SC6.C6_ENTREG <= '" + DtoS(dDtFim) + "' "
    cQry += "AND SC6.C6_SEMANA NOT IN ('RESERVA','ZP4') "
    cQry += "AND SUBSTRING(SC6.C6_SEMANA,1,1) NOT IN ('R','N','r') "
    cQry += "AND SUBSTRING(SC6.C6_SEMANA,1,3) <> 'DRC' "
    cQry += "GROUP BY SC9.C9_FILIAL, SC9.C9_PRODUTO,  SB1.B1_DESC,"
    cQry += "SC6.C6_ACONDIC + REPLICATE('0',(5- LEN(SC6.C6_METRAGE))) + CAST(SC6.C6_METRAGE AS VARCHAR(5)), "
    cQry += "SB1.B1_ZZFILFB, SB1.B1_LOCALIZ, ISNULL(ZAI.ZAI_ESTSEG, 0), ISNULL(ZAI.ZAI_LTECON, 0), SC6.C6_METRAGE "
    cQry += "ORDER BY SC9.C9_FILIAL, SC9.C9_PRODUTO "
return(cQry)


static function qryPrinc(cTable)
    local cQry := ""

    cQry += " SELECT TAB.PRODUTO AS [PRODUTO], "
    cQry += " TAB.DESCRI AS [DESCRI] "
    //cQry += " TAB.TIPO AS [TIPO] "
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.D_E_L_E_T_ = '' "
    cQry += " GROUP BY TAB.PRODUTO, TAB.DESCRI "
return(cQry)

static function qryTotal(cOpc, cMyFili, cProd, cTable)
    local cQry := ""
    cQry += " SELECT  "
    if cOpc == "NEC"
        cQry += " SUM(NECESSI) "
    elseif cOpc == "TRANS"
        cQry += " SUM(TRANSIT) "
    elseif cOpc == "SOLIC"
        cQry += " SUM(SOLICIT) "
    elseif cOpc == "ESTOQ"
        cQry += " SUM(ESTOQUE) "
    endif
    cQry += " AS [TOTAL] "
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.FILIAL = '" + cMyFili + "' "
    cQry += " AND TAB.PRODUTO = '" + cProd + "' "
    cQry += " AND TAB.D_E_L_E_T_ = '' "
return(cQry)

static function qryESA(lIn, cMyFili, cProd)
    local cQry := ""

    cQry += " SELECT SUM(B2_QATU) AS [TOTAL] "
    cQry += " FROM " + RetSqlName('SB2') + "  SB2 "
    cQry += " INNER JOIN " + RetSqlName('SB1') + " SB1 ON '' = SB1.B1_FILIAL "
    cQry += " 						AND SB2.B2_COD = SB1.B1_COD "
    cQry += " 						AND SB2.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
    cQry += " WHERE SB2.B2_FILIAL  "
    if !lIn
        cQry += " NOT  "
    endif
    cQry += " IN ('" + cMyFili + "') "
    cQry += " AND SB2.B2_COD = 'Q" + AllTrim(cProd) + "' "
    cQry += " AND SB2.B2_LOCAL = SB1.B1_LOCPAD "
    cQry += " AND SB2.D_E_L_E_T_ = '' "
return(cQry)

static function qryMRP(cTable)
    local cQry := ""

    cQry += " UPDATE " + cTable + "  "
    cQry += " SET MRP = (TAB.NECESSI - (TAB.ESTOQUE + TAB.SOLICIT + TAB.TRANSIT + TAB.RETRAB)) "
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.D_E_L_E_T_ = '' "
    cQry += " AND (TAB.NECESSI - (TAB.ESTOQUE + TAB.SOLICIT + TAB.TRANSIT + TAB.RETRAB)) > 0 "
return(cQry)

static function qryExced(cTable)
    local cQry := ""

    cQry += "UPDATE " + cTable + " SET EXCEDE = "
    cQry += "ISNULL(( "
    cQry += "SELECT SUM(((SUB.ESTOQUE + SUB.SOLICIT + SUB.TRANSIT + SUB.RETRAB) - SUB.NECESSI) - SUB.SEGURO) "
    cQry += "FROM " + cTable + " SUB "
    cQry += "WHERE SUB.FILIAL <> TAB.FILIAL "
    cQry += "AND SUB.PRODUTO = TAB.PRODUTO "
    cQry += "AND SUB.ACONDIC = TAB.ACONDIC "
    cQry += "AND SUB.D_E_L_E_T_ = TAB.D_E_L_E_T_ "
    cQry += "AND SUB.MRP = 0 "
    cQry += "AND (((SUB.ESTOQUE + SUB.SOLICIT + SUB.TRANSIT + SUB.RETRAB) - SUB.NECESSI) - SUB.SEGURO) > 0 "
    cQry += "),0) "
    cQry += "FROM " + cTable + " TAB "
    cQry += "WHERE TAB.D_E_L_E_T_ = '' "
return(cQry)

static function qryExport(cTable)
    local cQry := ""
    cQry += "SELECT  "
    cQry += "TAB.FILIAL AS [FILIAL], "
    cQry += "TAB.PRODUTO AS [PRODUTO], "
    cQry += "TAB.DESCRI AS [DESCRI], "
    cQry += "TAB.ACONDIC AS [ACONDIC], "
    cQry += "TAB.NECESSI AS [NECESSI], "
    cQry += "TAB.SEGURO AS [SEGURO], "
    cQry += "TAB.ESTOQUE AS [ESTOQUE], "
    cQry += "TAB.SOLICIT AS [SOLICIT], "
    cQry += "TAB.TRANSIT AS [TRANSIT], "
    cQry += "TAB.MRP AS [MRP], "
    cQry += "TAB.EXCEDE AS [EXCEDE], "
    cQry += "TAB.PRODUZ AS [PRODUZ], "
    cQry += "TAB.TRANSF AS [TRANSF], "
    cQry += "TAB.ESA AS [ESA], "
    cQry += "TAB.RETRAB AS [RETRAB], "
    cQry += "TAB.TIPO AS [TIPO] "
    cQry += "FROM " + cTable + " TAB "
    cQry += "WHERE TAB.D_E_L_E_T_ = '' "
return(cQry)

static function qryLoadUnimov()
	local cQry := ''
    
    /*
	cQry += " select Prod.Code as [PRODUTO],
	cQry += " MovUn.IDMovUn as [UNIMOV], "
	cQry += " MovUn.MovUnQty as [SALDO] "
	cQry += " from [PCF_PROD].PCFactory.dbo.TBLMovUn as MovUn "
	cQry += " inner join [PCF_PROD].PCFactory.dbo.TBLProduct as Prod on MovUn.IDProduct = Prod.IDProduct "
	cQry += " inner join SB1010 SB1 ON RTRIM(LTRIM(Prod.Code)) = RTRIM(LTRIM(SB1.B1_COD)) COLLATE Latin1_General_BIN  AND '' = SB1.D_E_L_E_T_ "
	cQry += " where MovUn.MovUnQty > 0 "
	cQry += " and SB1.B1_ZESA = 'S' "
    */
    
    cQry += " SELECT * FROM VW_UNIMOVSESA "
return(cQry)

static function qryProduzir(cTable)
    local cQry := ""

    cQry += " UPDATE " + cTable + " SET PRODUZ = "
    cQry += " MRP - (TRANSF + ESA + PRODUZ + RETRAB) "
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.D_E_L_E_T_ = '' "
    cQry += " AND (MRP - (TRANSF + ESA + PRODUZ + RETRAB)) > 0 "
return(cQry)

static function qryTransferir(cTable)
    local cQry := ""

    cQry += " UPDATE " + cTable + " SET TRANSF = "
    cQry += " CASE WHEN (MRP - (ESA + PRODUZ + TRANSF + RETRAB)) > EXCEDE "
    cQry += " THEN EXCEDE "
    cQry += " ELSE (MRP - (ESA + PRODUZ + TRANSF + RETRAB)) "
    cQry += " END "
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.D_E_L_E_T_ = '' "
    cQry += " AND (MRP - (ESA + PRODUZ + TRANSF + RETRAB)) > 0 "
return(cQry)

static function qryloadEsa(cTable)
    local cQry := ""
    cQry += " SELECT TAB.R_E_C_N_O_ AS [REC], "
    cQry += " TAB.FILIAL AS [FILIAL], "
    cQry += " TAB.PRODUTO AS [PRODUTO], "
    cQry += " TAB.ACONDIC AS [ACONDIC], "
    cQry += " TAB.METRAGE AS [METRAGE], "
    cQry += " TAB.MRP - (TAB.TRANSF + TAB.PRODUZ + TAB.ESA + TAB.RETRAB) AS [SALDO] " 
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.D_E_L_E_T_ = '' "
    cQry += " AND (TAB.MRP - (TAB.TRANSF + TAB.PRODUZ + TAB.ESA + TAB.RETRAB)) > 0 "
    //cQry += " AND TAB.PRODUTO = '1141504401'"
    cQry += " ORDER BY TAB.METRAGE DESC,  (TAB.MRP - (TAB.TRANSF + TAB.PRODUZ + TAB.ESA + TAB.RETRAB)) DESC "
return(cQry)

static function qrygetUnimovs(cTable, cFili, cProd, nMetrage)
    local cQry := ""
    
    cQry += " SELECT TAB.R_E_C_N_O_ AS [REC],   "
    cQry += " TAB.SALDO AS [SALDO]   "
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.D_E_L_E_T_ = ''   "
    cQry += " AND TAB.FILIAL = '" + AllTrim(cFili) + "' "
    cQry += " AND TAB.PRODUTO IN ( "
					    cQry += " SELECT SG1.G1_COMP "
					    cQry += " FROM " + RetSqlName('SG1') + " SG1 "
					    cQry += " INNER JOIN " + RetSqlName('SB1') + " SB1 ON SG1.G1_COMP = SB1.B1_COD AND SG1.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
					    cQry += " WHERE SG1.G1_COD = '" + AllTrim(cProd) + "' "
					    cQry += " AND SB1.B1_ZESA = 'S' "
					    cQry += " AND SG1.D_E_L_E_T_ = '' "
    cQry += " ) "
    cQry += " AND TAB.SALDO >= " + cValToChar(nMetrage)
    cQry += " ORDER BY TAB.SALDO "
return(cQry)

static function grvUniSaldo(cTable, nRecUni, nSaldo, cOper)
    local cQry      := ""
    default cOper   := "-"
    cQry += " UPDATE " + cTable + " SET SALDO = (SALDO " + cOper + " " + cValToChar(nSaldo) + ")"
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.D_E_L_E_T_ = '' "
    cQry += " AND TAB.R_E_C_N_O_ = " + cValToChar(nRecUni)
return(cQry)

static function grvESASaldo(cTable, nRecProd, nSaldo)
    local cQry := ""

    cQry += " UPDATE " + cTable + " SET ESA = " + cValToChar(nSaldo)
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.D_E_L_E_T_ = '' "
    cQry += " AND TAB.R_E_C_N_O_ = " + cValToChar(nRecProd)
return(cQry)

static function expUnimovs(cTable, cTableProd, cTableUni)
    local cQry := ""

    cQry += " SELECT TAB.FILIAL AS [FILIAL], "
    cQry += " PROD.PRODUTO AS [PRODUTO], "
    cQry += " PROD.DESCRI AS [DESCRI], "
    cQry += "PROD.ACONDIC AS [ACONDIC], "
    cQry += "UNI.UNIMOV AS [UNIMOV], "
    cQry += "UNI.PRODUTO AS [ESACOD], "
    cQry += "UNI.DESCR AS [ESADESCR], "
    cQry += "TAB.QTD AS [QTD], "
    cQry += "UNI.QTDORIG AS [QTDORIG] "
    cQry += "FROM " + cTable + " TAB "
    cQry += "INNER JOIN " + cTableProd + " PROD ON TAB.RECMRP = PROD.R_E_C_N_O_ AND TAB.D_E_L_E_T_ = PROD.D_E_L_E_T_ "
    cQry += "INNER JOIN " + cTableUni + " UNI ON TAB.RECMOV = UNI.R_E_C_N_O_ AND TAB.D_E_L_E_T_ = UNI.D_E_L_E_T_ "
    cQry += "WHERE TAB.D_E_L_E_T_ = '' "
return(cQry)


static function getAcondic(cTableProd, nRec)
    local cQry := ""

    cQry += " SELECT PROD.ACONDIC AS [ACONDIC] "
    cQry += " FROM " + cTableProd + " PROD "
    cQry += " WHERE PROD.R_E_C_N_O_ = '" + cValToChar(nRec) + "'" 
    cQry += " AND PROD.D_E_L_E_T_ = '' "
return(cQry)

static function qrygetEsa(cProd)
    local cQry := ""    
    
    cQry += " SELECT SG1.G1_COMP AS [PROD] "
    cQry += " FROM " + RetSqlName('SG1') + " SG1 "
    cQry += " INNER JOIN " + RetSqlName('SB1') + " SB1 ON SG1.G1_COMP = SB1.B1_COD AND SG1.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
    cQry += " WHERE SG1.G1_COD = '" + AllTrim(cProd) + "' "
    cQry += " AND SB1.B1_ZESA = 'S' "
    cQry += " AND SG1.D_E_L_E_T_ = '' "
return(cQry)

static function clearTable(cTable)
    local cQry := ""

    cQry += " DELETE "
    cQry += " FROM " + cTable + " "
    cQry += " WHERE D_E_L_E_T_ = '' "
return(cQry)

static function resetUni(cTable)
    local cQry := ""

    cQry += " UPDATE " + cTable + " SET SALDO = QTDORIG "
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.D_E_L_E_T_ = '' "
return(cQry)

static function resetMRP(cTable)
    local cQry := ""

    cQry += " UPDATE " + cTable + " SET PRODUZ = 0, ESA = 0, TRANSF = 0, RETRAB = 0"
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.D_E_L_E_T_ = '' "
return(cQry)

static function isUtiliza(cTable, cFili, nRecMRP, nRecMov)
    local cQry := ""

    cQry += " SELECT TAB.R_E_C_N_O_ AS [REC] "
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.FILIAL = '" + cFili + "'"
    cQry += " AND TAB.RECMRP = " + cValToChar(nRecMRP)
    cQry += " AND TAB.RECMOV = " + cValToChar(nRecMov)
    cQry += " AND TAB.D_E_L_E_T_ = '' "
return(cQry)

static function qryTipo(cTable, cFili, cProd)
    local cQry := ""

    cQry += " SELECT TAB.TIPO AS [TIPO] "
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.D_E_L_E_T_ = '' "
    cQry += " AND TAB.FILIAL = '" + cFili + "'"
    cQry += " AND TAB.PRODUTO = '" + cProd + "'"
    cQry += " GROUP BY TAB.TIPO "
return(cQry)

static function qryEstoque(dDtFim)
    local cQry := ""
    
    cQry += " SELECT  "
    cQry += " TEMP.FILIAL AS [FILIAL], "
    cQry += " TEMP.PRODUTO AS [PRODUTO], "
    cQry += " TEMP.ACONDIC AS [ACONDIC], "
    cQry += " TEMP.METRAGE AS [METRAGE], "
    cQry += " TEMP.QTDORIG AS [QTDORIG], "
    cQry += " TEMP.QTDMRP AS [QTDMRP], "
    cQry += " TEMP.QTDRETR AS [QTDRETR] "
    cQry += " FROM( "
    cQry += " SELECT SBF.BF_FILIAL AS [FILIAL], "
    cQry += " SBF.BF_PRODUTO AS [PRODUTO], "
    cQry += " SBF.BF_LOCALIZ AS [ACONDIC], "
    cQry += " CAST(SUBSTRING(SBF.BF_LOCALIZ, 2, (LEN(SBF.BF_LOCALIZ)-1)) AS INT) AS [METRAGE], "
    cQry += " CASE "
    cQry += " 	WHEN SUBSTRING(SBF.BF_LOCALIZ, 1, 1) = 'B' "
    cQry += " 		THEN (SBF.BF_QUANT - SBF.BF_EMPENHO) - (ISNULL(( "
    cQry += " 			SELECT SUM(SZE.ZE_QUANT) "
    cQry += " 			FROM " + RetSqlName('SZE') + " SZE "
    cQry += " 			INNER JOIN " + RetSqlName('SC6') + " SC6 ON    SZE.ZE_FILIAL	= SC6.C6_FILIAL "
    cQry += " 									AND SZE.ZE_PEDIDO	= SC6.C6_NUM "
    cQry += " 									AND SZE.ZE_ITEM		= SC6.C6_ITEM "
    cQry += " 									AND SZE.D_E_L_E_T_	= SC6.D_E_L_E_T_ "
    cQry += " 			WHERE SZE.ZE_FILIAL = SBF.BF_FILIAL "
    cQry += " 			AND SZE.ZE_PRODUTO = SBF.BF_PRODUTO "
    cQry += " 			AND SZE.ZE_QUANT = CAST(SUBSTRING(SBF.BF_LOCALIZ, 2, (LEN(SBF.BF_LOCALIZ)-1)) AS INT) "
    cQry += " 			AND SZE.ZE_STATUS IN ('P') "
    cQry += " 			AND SC6.C6_ENTREG > '" + DtoS(dDtFim) + "' "
    cQry += " 			AND SZE.D_E_L_E_T_ = SBF.D_E_L_E_T_ "
    cQry += " 		),0)) + (ISNULL((  "
    cQry += " 			SELECT SUM(SZE.ZE_QUANT) "
    cQry += " 			FROM " + RetSqlName('SZE') + " SZE "
    cQry += " 			INNER JOIN " + RetSqlName('SC6') + " SC6 ON    SZE.ZE_FILIAL	= SC6.C6_FILIAL "
    cQry += " 									AND SZE.ZE_PEDIDO	= SC6.C6_NUM "
    cQry += " 									AND SZE.ZE_ITEM		= SC6.C6_ITEM "
    cQry += " 									AND SZE.D_E_L_E_T_	= SC6.D_E_L_E_T_ "
    cQry += " 			WHERE SZE.ZE_FILIAL = SBF.BF_FILIAL "
    cQry += " 			AND SZE.ZE_PRODUTO = SBF.BF_PRODUTO "
    cQry += " 			AND SZE.ZE_QUANT = CAST(SUBSTRING(SBF.BF_LOCALIZ, 2, (LEN(SBF.BF_LOCALIZ)-1)) AS INT) "
    cQry += " 			AND SZE.ZE_STATUS IN ('I') "
    cQry += " 			AND SZE.ZE_PEDIDO <> '000001' "
    cQry += " 			AND SC6.C6_ENTREG <= '" + DtoS(dDtFim) + "' "
    cQry += " 			AND SZE.D_E_L_E_T_ = SBF.D_E_L_E_T_ "
    cQry += " 		),0)) + (ISNULL((  "
    cQry += " 			SELECT SUM(SZE.ZE_QUANT) "
    cQry += " 			FROM " + RetSqlName('SZE') + " SZE "
    cQry += " 			WHERE SZE.ZE_FILIAL = SBF.BF_FILIAL "
    cQry += " 			AND SZE.ZE_PRODUTO = SBF.BF_PRODUTO "
    cQry += " 			AND SZE.ZE_QUANT = CAST(SUBSTRING(SBF.BF_LOCALIZ, 2, (LEN(SBF.BF_LOCALIZ)-1)) AS INT) "
    cQry += " 			AND SZE.ZE_STATUS IN ('I') "
    cQry += " 			AND SZE.ZE_PEDIDO = '000001' "
    cQry += " 			AND SZE.D_E_L_E_T_ = SBF.D_E_L_E_T_ "
    cQry += " 		),0)) "
    cQry += " 	ELSE (SBF.BF_QUANT - SBF.BF_EMPENHO)	 "
    cQry += " END AS [QTDORIG], "
    cQry += " 0 AS [QTDMRP], "
    cQry += " 0 AS [QTDRETR] "
    cQry += " FROM " + RetSqlName('SBF') + " SBF "
    cQry += " WHERE SBF.BF_FILIAL IN ('01','02','03') "
    cQry += " AND SBF.BF_LOCAL = '01' "
    cQry += " AND SBF.D_E_L_E_T_ = '' "
    cQry += " ) TEMP "
    cQry += " WHERE TEMP.QTDORIG > 0 "
return(cQry)

static function qryDistEst(cTable, cTableP)
    local cQry := ""

    cQry += " UPDATE " + cTable
    cQry += " SET QTDMRP = CASE "    
    cQry += "                WHEN ((TAB.NECESSI - (TAB.SOLICIT + TAB.TRANSIT + TAB.RETRAB)) > TEMP.ESTOQUE) "
    cQry += "                   THEN TEMP.ESTOQUE "
    cQry += "                ELSE (TAB.NECESSI - (TAB.SOLICIT + TAB.TRANSIT + TAB.RETRAB)) "
    cQry += "               END "
    cQry += " FROM " + cTable + " TAB "
    cQry += " INNER JOIN " + cTableP + " TEMP ON TAB.FILIAL  = TEMP.FILIAL "
    cQry += "                                AND TAB.PRODUTO = TEMP.PRODUTO "
    cQry += "                                AND TAB.ACONDIC = TEMP.ACONDIC "
    cQry += " WHERE TAB.D_E_L_E_T_ = '' "
    cQry += " AND TEMP.NECESSI > 0 "
    cQry += " AND TEMP.ESTOQUE > 0 "
    cQry += " AND TEMP.ACONDIC <> '' "
return(cQry)

static function resetRet(cTable)
    local cQry := ""

    cQry += " UPDATE " + cTable + " SET QTDRETR = 0 "
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.D_E_L_E_T_ = '' "
return(cQry)

static function qryLoadRetrab(cTable)
    local cQry := ""

    cQry += " SELECT TAB.FILIAL AS [FILIAL], "
    cQry += " TAB.PRODUTO AS [PRODUTO], "
    cQry += " TAB.ACONDIC AS [ACONDIC], "
    cQry += " TAB.METRAGE AS [METRAGE], "
    cQry += " (TAB.MRP - (TAB.EXCEDE+TAB.PRODUZ+TAB.TRANSF+TAB.ESA+TAB.RETRAB)) AS [NECESS], "
    cQry += " ((TAB.MRP - (TAB.EXCEDE+TAB.PRODUZ+TAB.TRANSF+TAB.ESA+TAB.RETRAB)) / TAB.METRAGE) AS [LANCES], "
    cQry += " CASE "
    cQry += " 	WHEN SUBSTRING(TAB.ACONDIC,1,1) = 'B' "
    cQry += " 		THEN 1 "
    cQry += " 	WHEN SUBSTRING(TAB.ACONDIC,1,1) = 'M' OR SUBSTRING(TAB.ACONDIC,1,1) = 'C' "
    cQry += " 		THEN 2 "
    cQry += " 	ELSE 3 "
    cQry += " END AS [ORDEM], "
    cQry += " TAB.R_E_C_N_O_ AS [REC] "
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.MRP <> 0 "
    cQry += " AND ((TAB.MRP - (TAB.EXCEDE+TAB.PRODUZ+TAB.TRANSF+TAB.ESA+TAB.RETRAB)) / TAB.METRAGE) >= 1 "
    cQry += " AND TAB.METRAGE <> '' "
    cQry += " ORDER BY ORDEM, TAB.PRODUTO, TAB.METRAGE, LANCES "
return(cQry)

static function sldDisponi(cTabEst, cTabRet, cFili, cProd, nMetrage, nTotal)
    local cQry      := ""
    default nTotal  := 0
    /*
    cQry += " SELECT TAB.R_E_C_N_O_ AS [REC], "
    cQry += " (TAB.QTDORIG - (TAB.QTDMRP + TAB.QTDRETR)) AS [SALDO], "
    cQry += " TAB.METRAGE AS [METRAGE], "
    cQry += " TAB.ACONDIC AS [ACONDIC] "
    cQry += " FROM " + cTab + " TAB "
    cQry += " WHERE TAB.FILIAL = '" + cFili + "' "
    cQry += " AND TAB.PRODUTO = '" + cProd + "' "
    cQry += " AND TAB.METRAGE >= " + cValToChar(nMetrage)
    if !empty(nTotal)
        cQry += " AND (TAB.QTDORIG - (TAB.QTDMRP + TAB.QTDRETR)) > " + cValToChar(nTotal)
    endif
    cQry += " ORDER BY SALDO "
    */
    cQry += " SELECT * FROM( "
    cQry += " SELECT  "
    cQry += " '000000' AS [ID], "
    cQry += " TAB.R_E_C_N_O_ AS [REC], "
    cQry += " ( "
    cQry += " 	(TAB.QTDORIG - (TAB.QTDMRP + TAB.QTDRETR)) "
    cQry += " 	- "
    cQry += " 	ISNULL(( "
    cQry += " 	SELECT SUM(((CAST(SUBSTRING(RET.ACONDORI,2,LEN(RET.ACONDORI)) AS INT) * RET.LANCORI) - RET.QTD)) "
    cQry += " 	FROM " + cTabRet + " RET "
    cQry += " 	WHERE RET.RECEST = TAB.R_E_C_N_O_ "
    cQry += " 	),0) "
    cQry += " ) AS [SALDO], "
    cQry += " TAB.METRAGE AS [METRAGE], "
    cQry += " TAB.ACONDIC AS [ACONDIC] "
    cQry += " FROM " + cTabEst + " AS TAB "
    cQry += " WHERE TAB.FILIAL = '" + cFili + "' "
    cQry += " AND TAB.PRODUTO = '" + cProd + "' "
    cQry += " AND TAB.METRAGE >= " + cValToChar(nMetrage)
    //cQry += " AND (TAB.QTDORIG - (TAB.QTDMRP + TAB.QTDRETR)) >= " + cValToChar(nTotal)
    cQry += " AND ( "
    cQry += " 	(TAB.QTDORIG - (TAB.QTDMRP + TAB.QTDRETR)) "
    cQry += " 	- "
    cQry += " 	ISNULL(( "
    cQry += " 	SELECT SUM(((CAST(SUBSTRING(RET.ACONDORI,2,LEN(RET.ACONDORI)) AS INT) * RET.LANCORI) - RET.QTD)) "
    cQry += " 	FROM " + cTabRet + " RET "
    cQry += " 	WHERE RET.RECEST = TAB.R_E_C_N_O_ "
    cQry += " 	),0) "
    cQry += " ) > 0 "
    cQry += " UNION "
    cQry += " SELECT  "
    cQry += " TRB.ID AS [ID], "
    cQry += " TRB.REC AS [REC], "
    cQry += " TRB.SALDO AS [SALDO], "
    cQry += " TRB.METRAGE AS [METRAGE], "
    cQry += " TRB.ACONDIC AS [ACONDIC] "
    cQry += " FROM ( "
    cQry += " 		SELECT  "
    cQry += " 		TEMP.ID AS [ID], "
    cQry += " 		TEMP.REC AS [REC], "
    cQry += " 		SUM(TEMP.SALDO) AS [SALDO], "
    cQry += " 		TEMP.METRAGE AS [METRAGE], "
    cQry += " 		TEMP.ACONDIC AS [ACONDIC] "
    cQry += " 		FROM ( "
    cQry += " 				SELECT  "
    cQry += " 				TAB.ID AS [ID], "
    cQry += " 				TAB.RECEST AS [REC], "
    cQry += " 				((CAST(SUBSTRING(TAB.ACONDORI,2,LEN(TAB.ACONDORI)) AS INT) * TAB.LANCORI) - TAB.QTD) [SALDO], "
    cQry += " 				CAST(SUBSTRING(TAB.ACONDORI,2,LEN(TAB.ACONDORI)) AS INT) AS [METRAGE], "
    cQry += " 				TAB.ACONDORI AS [ACONDIC] "
    cQry += " 				FROM " + cTabRet + " AS TAB "
    cQry += " 				WHERE TAB.FILIAL = '" + cFili + "' "
    cQry += " 				AND TAB.PRODUTO = '" + cProd + "' "
    cQry += " 		) AS TEMP "
    cQry += " 		GROUP BY TEMP.ID, TEMP.REC, TEMP.METRAGE, TEMP.ACONDIC "
    cQry += " ) AS TRB "
    cQry += " WHERE TRB.METRAGE >= " + cValToChar(nMetrage)
    //cQry += " AND TRB.SALDO >= " + cValToChar(nTotal)
    cQry += " ) FINAL ORDER BY FINAL.ID DESC, FINAL.SALDO "
return(cQry)

static function grvEstRet(cTable, nRec, nSaldo)
    local cQry := ""

    cQry += " UPDATE " + cTable + " SET QTDRETR = QTDRETR + " + cValToChar(nSaldo)
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.D_E_L_E_T_ = '' "
    cQry += " AND TAB.R_E_C_N_O_ = " + cValToChar(nRec)
return(cQry)

static function grvRetrab(cTable, nRec, nSaldo)
    local cQry := ""

    cQry += " UPDATE " + cTable + " SET RETRAB = RETRAB + " + cValToChar(nSaldo)
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.D_E_L_E_T_ = '' "
    cQry += " AND TAB.R_E_C_N_O_ = " + cValToChar(nRec)
return(cQry)

static function expRetrab(cTable)
    local cQry := ""

    cQry += " SELECT TAB.FILIAL AS [FILIAL], "
    cQry += " TAB.ID AS [ID], "
    cQry += " TAB.PRODUTO AS [PRODUTO], "
    cQry += " SB1.B1_DESC AS [DESCRI], " 
    cQry += " TAB.ACONDORI AS [ORIGEM], "
    cQry += " TAB.LANCORI AS [LANCORI], "
    cQry += " TAB.ACONDDEST AS [DESTINO], "
    cQry += " TAB.LANCDEST AS [LANCDEST], "
    cQry += " SUM(TAB.QTD) AS [QTD] "
    cQry += " FROM " + cTable + " TAB "
    cQry += " INNER JOIN " + RetSqlName('SB1') + " SB1 ON TAB.PRODUTO = SB1.B1_COD "
    cQry += "                                      AND TAB.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
    cQry += " WHERE TAB.D_E_L_E_T_ = '' "
    cQry += " GROUP BY TAB.FILIAL, TAB.ID, TAB.PRODUTO, SB1.B1_DESC, TAB.ACONDORI, TAB.ACONDDEST, TAB.LANCORI, TAB.LANCDEST "
return(cQry)

static function qrySobras(cTable)
    local cQry := ""
    cQry += " SELECT RET.FILIAL AS [FILIAL], "
    cQry += " RET.ID AS [ID], "
    cQry += " RET.PRODUTO AS [PRODUTO], "
    cQry += " RET.ACONDORI AS [ACONDORI], "
    cQry += " RET.RECEST AS [RECEST], "
    cQry += " SUM((CAST(SUBSTRING(RET.ACONDORI,2,LEN(RET.ACONDORI)) AS INT) * RET.LANCORI) - RET.QTD) AS [SOBRA] "
    cQry += " FROM " + cTable + " RET "
    cQry += " GROUP BY RET.FILIAL, RET.ID, RET.PRODUTO, RET.ACONDORI, RET.RECEST "
    cQry += " ORDER BY RET.ID "
return(cQry)

static function qryTabCurva()
    local cQry := ""
    cQry += " SELECT TAB.FILIAL AS [FILIAL], "
    cQry += " TAB.PRODUTO AS [PRODUTO], "
    cQry += " TAB.ACOND AS [ACONDIC], "
    cQry += " TAB.GRUPO AS [GRUPO], "
    cQry += " CAST(SUBSTRING(ACOND, 2, LEN(ACOND)) AS INT) AS [METRAGE] "
    cQry += " FROM BI_VW_EPACURVA_DETALHE TAB "
return(cQry)

static function qryAvalSobra(cTable, cFili, cProd, nQtd)
    local cQry := ""
    cQry += " SELECT TAB.ACONDIC AS [ACONDIC], "
    cQry += " TAB.GRUPO AS [GRUPO], "
    cQry += " TAB.METRAGE AS [METRAGE] "
    cQry += " FROM " + cTable + " TAB "
    cQry += " WHERE TAB.FILIAL = '" + cFili + "'"
    cQry += " AND TAB.PRODUTO = '" + cProd + "' "
    cQry += " AND TAB.METRAGE <= " + cValToChar(nQtd)
    cQry += " ORDER BY TAB.GRUPO "
return(cQry)
