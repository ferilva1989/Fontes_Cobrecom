#include 'TOTVS.ch'

class cbcCusQry
    data perDe
    data perAte
    method newcbcCusQry() constructor 
    method compras()
    method movIntReqProd()
    method producao()
    method venda()
    method devVenda()
    method devCompra()
    method entraTercei()
    method saidaTercei()
    method saldoInicial()
    method balxCompras()
    method ct2Lote()
    method balancete()
    method detLotect2()
    method modelo7()
    method allES()
    method groupES()
    method execQuery()    
endClass


method newcbcCusQry(perDe,perAte) class cbcCusQry
    ::perDe     := perDe
    ::perAte    := perAte
return(self)


method execQuery(cQry) class cbcCusQry
    local oObj      as object
    local bErro     as object
    local aRet      as array    
    bErro         := ErrorBlock({|oErr| HandleEr(oErr, @aRet)})
    BEGIN SEQUENCE
        oObj := u_cbcQRYexec(cQry)
        aRet := aclone(oObj['data'])
        RECOVER
    END SEQUENCE
    ErrorBlock(bErro)
return aRet


method groupES(aResult, lHash) class cbcCusQry
    local aResp     as array
    local oResp     as object
    local aRef      as array
    local nX        as numeric
    local nY        as numeric
    local nVlr      as numeric
    local cChave    as character
    local cProd     as character
    local oHash     as object
    local xValue    as object
    Local oStatic   := IfcXFun():newIfcXFun()
    default lHash := .T.
    
    oHash  := HMNew()
    for nX := 1 to len(aResult)
        if !empty(aResult[nX][1])
            for nY := 1 to len(aResult[nX][1])         
                if abs(aResult[nX][1][nY]:ALL_CUSTO) <> 0
                    xValue  := nil
                    cProd   := Alltrim(left(aResult[nX][1][nY]:ALL_PROD,10))
                    cChave  := Alltrim(aResult[nX][1][nY]:ALL_TIPO) + '_' + alltrim(cProd)
                    nVlr    := oStatic:sP(2):callStatic('cbcCusConfer', 'ajuNum', aResult[nX][1][nY]:ALL_CUSTO, aResult[nX][2])
                    if  HMGet(oHash, cChave, @xValue)
                        nVlr := xValue[1][2] + nVlr 
                        HMSet(oHash, cChave, {{cChave, nVlr}} )
                    else
                        HMAdd(oHash,{cChave, nVlr})
                    endif
                endif
            next nY
        endif
    next nX
    aRef := {}
    HMList(oHash, aRef)
    aResp := {}
    for nX := 1 to len(aRef)
        if aRef[nX][2][1][2] <> 0
            oResp		:= JsonObject():new()
            oResp['PRODUTO']    := aRef[nX][1]
            oResp['SALDO']      := aRef[nX][2][1][2]
            aadd(aResp,oResp)
        endif
    next nX
    HMClean(oHash)
return aResp


method allES() class cbcCusQry
    local aResult as array
    aResult := {}
    aadd(aResult, {::saldoInicial(.F.)      , ''} )
    aadd(aResult, {::compras(.F.)           , 'compras'} )
    aadd(aResult, {::movIntReqProd(.F.,.T.)     , ''})
    aadd(aResult, {::producao(.F.)          , 'producao'})
    aadd(aResult, {::venda(.F.)             , 'vendas'})
    aadd(aResult, {::devVenda(.F.)          , 'dev.venda'})
    aadd(aResult, {::devCompra(.F.)         , 'dev.compras'})
    aadd(aResult, {::entraTercei(.F.)       , 'entr.poder terc'})
    aadd(aResult, {::saidaTercei(.F.)       , 'saida poder terc'})
return(::groupES(aResult))


method modelo7(lSintetico) class cbcCusQry
    local cQry          as character
    local cTableName    as character
    default lSintetico  := .T.
    cTableName := "H_" + ::perAte + "01_"+FwFilial()
    cQry := " SELECT "
    if lSintetico
        cQry += " SB1.B1_TIPO  AS TIPO, "
        cQry += " ROUND(SUM(MODELO.TOTAL),2) AS CUSTO "
    else
        cQry += " CASE WHEN MODELO.SITUACAO = 1 THEN 'EM ESTOQUE' WHEN MODELO.SITUACAO = 4 THEN 'DE TERCEIROS'  "
        cQry += " END AS SITUACAO, "
        cQry += " SB1.B1_TIPO AS PROD_TIPO, SB1.B1_DESC AS PROD_DESC, MODELO.* "
    endif
    cQry += " FROM  "
    cQry +=   cTableName +" AS MODELO "
    cQry += " INNER JOIN SB1010 SB1 ON '' = SB1.B1_FILIAL "
    cQry += " AND MODELO.PRODUTO = SB1.B1_COD "
    cQry += " AND '' = SB1.D_E_L_E_T_ "
    cQry += " WHERE SB1.B1_TIPO  IN ('ME','MO', 'MP', 'OI', 'PA','PI','SC','SV','MR') "
    cQry += " AND MODELO.SITUACAO IN ('1','4') "
    cQry += " AND MODELO.FILIAL = '" + FwFilial() + "' "
    if lSintetico
        cQry += " GROUP BY SB1.B1_TIPO "
    endif
return(::execQuery(cQry))


method ct2Lote(lSintetico, cTabela) class cbcCusQry
    local cQry as character
    default lSintetico := .T.
    cQry := ""
    if lSintetico
        cQry := " SELECT "         
        cQry += " INTERNO.FILIAL, "
        cQry += " LOWER(REPLACE(REPLACE(INTERNO.MOVIMENTO,'[',''),']','')) AS MOV, "
        cQry += " INTERNO.TIPO										AS TIPO, "
        cQry += " ROUND(SUM(INTERNO.VALOR_SINAL),2)					AS CUSTO, "
        cQry += " ROUND(SUM(INTERNO.DIF_CTB_ORIG),2)				AS DIF "
        cQry += " FROM ( "
    endif
    cQry += " SELECT  "
    cQry += " CT2.CT2_FILIAL AS FILIAL, "
    cQry += " CT2.CT2_HIST HIST, "
    cQry += " LEFT(RIGHT(REPLACE(LTRIM(RTRIM(CT2_HIST)),' ',''),11),2) AS TIPO, "
    cQry += " SUBSTRING(CT2_HIST, 1, CHARINDEX(']', CT2_HIST)) AS MOVIMENTO, " 
    cQry += " CT2.CT2_DEBITO AS CTA_DEB, "
    cQry += " CT2.R_E_C_N_O_        AS RECNO, "
    cQry += " CT2.CT2_CREDIT		AS CTA_CRED, "
    cQry += " CT2.CT2_CCD			AS CC_DEB, "
    cQry += " CT2.CT2_CCC			AS CC_CRED, "
    cQry += " CT2.CT2_DOC			AS CT2_DOC, "
    cQry += " CT2.CT2_LINHA		    AS CT2_LINHA, "
    cQry += " CT2.CT2_LP			AS CT2_LP, "
    cQry += " CT2.CT2_SEQHIS		AS CT2_SEQLP, "
    cQry += " CASE WHEN CT2.CT2_HIST LIKE '%REQ.%' AND CT2.CT2_HIST NOT LIKE '%DEV.%' "
    cQry += " THEN (CV3.CV3_VLR01*-1) "
    cQry += " ELSE CV3.CV3_VLR01 "
    cQry += " END AS VALOR_SINAL, "
    if cTabela == 'SD1'
        cQry += " CASE WHEN ROUND(CV3.CV3_VLR01 - SD1.D1_CUSTO,2) > 0 "
        cQry += " THEN (ROUND(CV3.CV3_VLR01 - SD1.D1_CUSTO,2) - SD1.D1_VALICM) "
        cQry += " ELSE 0 "
        cQry += " END AS DIF_CTB_ORIG, "
    elseif cTabela == 'SD2'
         cQry += " ROUND(CV3.CV3_VLR01 - SD2.D2_CUSTO1,2) AS DIF_CTB_ORIG, "
    elseif cTabela == 'SD3'
        cQry += " ROUND(CV3.CV3_VLR01 - SD3.D3_CUSTO1,2) AS DIF_CTB_ORIG, "
    endif
    cQry += " SB1.B1_COD		AS COD_PROD, "
    cQry += " SB1.B1_DESC		AS DESC_PROD, "
    if cTabela == 'SD1'
        cQry += " SD1.D1_VALICM     AS ICMS, "
        cQry += " SD1.D1_CF		    AS DF_DOC, "
        cQry += " SD1.D1_QUANT	    AS QUANT_DOC, "
        cQry += " SD1.D1_LOCAL	    AS LOCAL_DOC, "
        cQry += " SD1.D1_CUSTO	    AS CUSTO_DOC, "
        cQry += " SD1.D1_DOC		AS NUM_DOC, "
        cQry += " SD1.D1_OP		    AS NUM_OP, "
        cQry += " ''				AS HIST_DOC, "
        cQry += " SD1.D1_SEQCALC	AS SEQ_CALCULO, "
        cQry += " ''				AS USUARIO "
    elseif cTabela == 'SD2'
        cQry += " SD2.D2_VALICM   AS ICMS, "
        cQry += " SD2.D2_CF		AS DF_DOC, "
        cQry += " SD2.D2_QUANT	AS QUANT_DOC, "
        cQry += " SD2.D2_LOCAL	AS LOCAL_DOC, "
        cQry += " SD2.D2_CUSTO1	AS CUSTO_DOC, "
        cQry += " SD2.D2_DOC		AS NUM_DOC, "
        cQry += " SD2.D2_OP		AS NUM_OP, "
        cQry += " ''				AS HIST_DOC, "
        cQry += " SD2.D2_SEQCALC	AS SEQ_CALCULO, "
        cQry += " ''				AS USUARIO "
    elseif cTabela == 'SD3'
        cQry += " 0				AS ICMS, "
        cQry += " SD3.D3_CF		AS DF_DOC, "
	    cQry += " SD3.D3_QUANT	AS QUANT_DOC, "
	    cQry += " SD3.D3_LOCAL	AS LOCAL_DOC, "
	    cQry += " SD3.D3_CUSTO1	AS CUSTO_DOC, "
	    cQry += " SD3.D3_DOC		AS NUM_DOC, "
	    cQry += " SD3.D3_OP		AS NUM_OP, "
	    cQry += " SD3.D3_HIST	AS HIST_DOC, "
	    cQry += " SD3.D3_SEQCALC	AS SEQ_CALCULO, "
	    cQry += " SD3.D3_USUARIO	AS USUARIO "
    endif
    cQry += " FROM " + RetSqlName('CT2') + " CT2 WITH(NOLOCK) "
    cQry += " INNER JOIN " + RetSqlName('CV3') + " CV3 ON CT2.R_E_C_N_O_ =  CV3.CV3_RECDES "
    cQry += " AND CT2.D_E_L_E_T_ = CV3.D_E_L_E_T_ "
    
    if cTabela == 'SD1'
        cQry += " INNER JOIN " + RetSqlName('SD1') + " SD1 WITH(NOLOCK) ON SD1.R_E_C_N_O_ = CV3_RECORI "
        cQry += " AND SD1.D_E_L_E_T_ = CV3.D_E_L_E_T_ "
    elseif cTabela == 'SD2'
        cQry += " INNER JOIN " + RetSqlName('SD2') + " SD2 WITH(NOLOCK) ON SD2.R_E_C_N_O_ = CV3_RECORI "
        cQry += " AND SD2.D_E_L_E_T_ = CV3.D_E_L_E_T_ "
    elseif cTabela == 'SD3'
        cQry += " INNER JOIN " + RetSqlName('SD3') + " SD3 WITH(NOLOCK) ON SD3.R_E_C_N_O_ = CV3_RECORI "
        cQry += " AND SD3.D_E_L_E_T_ = CV3.D_E_L_E_T_ "
    endif
    
    cQry += " INNER JOIN " + RetSqlName('SB1') + " SB1 WITH(NOLOCK) ON '' = SB1.B1_FILIAL "
    if cTabela == 'SD1'
        cQry += " AND SD1.D1_COD		= SB1.B1_COD "
        cQry += " AND SB1.D_E_L_E_T_	= SD1.D_E_L_E_T_ "
    elseif cTabela == 'SD2'
        cQry += " AND SD2.D2_COD		= SB1.B1_COD "
        cQry += " AND SB1.D_E_L_E_T_	= SD2.D_E_L_E_T_ "
    elseif cTabela == 'SD3'
        cQry += " AND SD3.D3_COD		= SB1.B1_COD "
        cQry += " AND SB1.D_E_L_E_T_	= SD3.D_E_L_E_T_ "
    endif

    cQry += " WHERE  "
    cQry += " CT2_FILIAL			IN ('" + FwFilial() + "') "
    cQry += " AND CT2.CT2_LOTE	= '008840' "
    cQry += " AND CT2.CT2_DATA	= '"+ ::perAte + "' "
    cQry += " AND CV3.CV3_TABORI	= '" + cTabela + "' "
    cQry += " AND CT2.D_E_L_E_T_	= '' "
    if lSintetico
        cQry += " ) AS INTERNO "
        cQry += " GROUP BY  INTERNO.FILIAL, INTERNO.MOVIMENTO, INTERNO.TIPO "
    endif

return(::execQuery(cQry))


method saldoInicial(lSintetico) class cbcCusQry
    local cQry as character
    default lSintetico := .T.
    cQry := "EXEC SALDO_ES_CUST '"+FwFilial()+"', '"+ ::perDe + "' , '" + if(lSintetico,'S','N') + "' " 
return(::execQuery(cQry))


method balxCompras(cConta) class cbcCusQry
    local cQry as character
    cConta := left(cConta,5)
    cQry := "EXEC BAL_ES_CUST '" + cConta + "', '" + FwFilial() + "', '" + ::perDe + "', '" + ::perAte + "'"
return(::execQuery(cQry)) 


method saidaTercei(lSintetico) class cbcCusQry
    local cQry as character
    default lSintetico := .T.
    cQry := ""
    if lSintetico
        cQry := " SELECT "
        cQry += " DETALHES.B1_TIPO		AS TIPO, "
        cQry += " ROUND(SUM(DETALHES.D2_CUSTO1),2)  AS CUSTO "
        cQry += " FROM "
        cQry += " ( "
    endif
    cQry += " SELECT  "
    cQry += " SD2.D2_COD, "
    cQry += " SD2.D2_COD AS ALL_PROD, "
    cQry += " SD2.D2_CUSTO1 AS ALL_CUSTO, "
    cQry += " SB1.B1_TIPO AS ALL_TIPO,  "
    cQry += " SD2.D2_DOC, "
    cQry += " SD2.D2_SERIE, "
    cQry += " SD2.D2_CUSTO1, "
    cQry += " SB1.B1_DESC, "
    cQry += " SB1.B1_TIPO "
    cQry += " FROM "+ RetSqlName('SD2') + " SD2 WITH(NOLOCK) "
    cQry += " INNER JOIN "+ RetSqlName('SF4') + " SF4 WITH(NOLOCK) ON '' = SF4.F4_FILIAL AND SD2.D2_TES = SF4.F4_CODIGO AND SD2.D_E_L_E_T_ = SF4.D_E_L_E_T_ "
    cQry += " INNER JOIN "+ RetSqlName('SB1') + " SB1 WITH(NOLOCK) ON '' = SB1.B1_FILIAL AND SD2.D2_COD = SB1.B1_COD AND SD2.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
    cQry += " WHERE SD2.D2_FILIAL  = '" + FwFilial() + "'  "
    cQry += " AND SD2.D2_EMISSAO  BETWEEN '" + ::perDe + "' AND '" + ::perAte + "'   "
    cQry += " AND SF4.F4_ESTOQUE  = 'S'   "
    cQry += " AND SF4.F4_PODER3 IN ('D' , 'R' )   "
    cQry += " AND SD2.D2_ORIGLAN  <> 'LF'  "
    cQry += " AND SD2.D2_REMITO  = '         '   "
    cQry += " AND SB1.B1_TIPO  IN ('ME','MO', 'MP', 'OI', 'PA','PI','SC','SV','MR') "
    cQry += " AND SD2.D_E_L_E_T_  = ' '   "
    if lSintetico
        cQry += " ) AS DETALHES  "
        cQry += " GROUP BY DETALHES.B1_TIPO "
    endif
return(::execQuery(cQry))


method entraTercei(lSintetico) class cbcCusQry
    local cQry as character
    default lSintetico := .T.
    cQry := ""
    if lSintetico
        cQry := " SELECT "
        cQry += " DETALHES.B1_TIPO		AS TIPO, "
        cQry += " ROUND(SUM(DETALHES.D1_CUSTO),2)  AS CUSTO "
        cQry += " FROM "
        cQry += " ( "
    endif
    cQry += " SELECT  "
    cQry += " SD1.D1_COD, "
    cQry += " SD1.D1_COD AS ALL_PROD, "
    cQry += " SD1.D1_CUSTO AS ALL_CUSTO, "
    cQry += " SB1.B1_TIPO AS ALL_TIPO,  "
    cQry += " SD1.D1_DOC, "
    cQry += " SD1.D1_SERIE, "
    cQry += " SD1.D1_CUSTO, "
    cQry += " SB1.B1_DESC, "
    cQry += " SB1.B1_TIPO "
    cQry += " FROM "+ RetSqlName('SD1') + " SD1 WITH(NOLOCK) "
    cQry += " INNER JOIN "+ RetSqlName('SF4') + " SF4 WITH(NOLOCK) ON '' = SF4.F4_FILIAL AND SD1.D1_TES = SF4.F4_CODIGO AND SD1.D_E_L_E_T_ = SF4.D_E_L_E_T_ "
    cQry += " INNER JOIN "+ RetSqlName('SB1') + " SB1 WITH(NOLOCK) ON '' = SB1.B1_FILIAL AND SD1.D1_COD = SB1.B1_COD AND SD1.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
    cQry += " WHERE SD1.D1_FILIAL  = '" + FwFilial() + "'  "
    cQry += " AND SD1.D1_DTDIGIT  BETWEEN '" + ::perDe + "' AND '" + ::perAte + "'   "
    cQry += " AND SF4.F4_ESTOQUE  = 'S'   "
    cQry += " AND SF4.F4_PODER3 IN ('D' , 'R' )   "
    cQry += " AND SD1.D1_ORIGLAN  <> 'LF'  "
    cQry += " AND SD1.D1_REMITO  = '         '   "
    cQry += " AND SB1.B1_TIPO  IN ('ME','MO', 'MP', 'OI', 'PA','PI','SC','SV','MR') "
    cQry += " AND SD1.D_E_L_E_T_  = ' '   "
    if lSintetico
        cQry += " ) AS DETALHES  "
        cQry += " GROUP BY DETALHES.B1_TIPO "
    endif

return(::execQuery(cQry))


method devCompra(lSintetico) class cbcCusQry
    local cQry as character
    default lSintetico := .T.
    cQry := ""
    if lSintetico
        cQry := " SELECT "
        cQry += " DETALHES.B1_TIPO		AS TIPO, "
        cQry += " ROUND(SUM(DETALHES.D2_CUSTO1),2) AS CUSTO "
        cQry += " FROM "
        cQry += " ( "
    endif
    cQry += " SELECT  "
    cQry += " SD2.D2_COD, "
    cQry += " SD2.D2_DOC, "
    cQry += " SD2.D2_DOC AS ALL_PROD, "
    cQry += " SD2.D2_CUSTO1 AS ALL_CUSTO, "
    cQry += " SB1.B1_TIPO AS ALL_TIPO,  "
    cQry += " SD2.D2_SERIE, "
    cQry += " SD2.D2_CUSTO1, "
    cQry += " SB1.B1_DESC, "
    cQry += " SB1.B1_TIPO "
    cQry += " FROM "+ retsqlname('SD2') +" SD2 WITH(NOLOCK) "
    cQry += " INNER JOIN "+ retsqlname('SF4') +" SF4 WITH(NOLOCK) ON '' = SF4.F4_FILIAL AND SD2.D2_TES = SF4.F4_CODIGO AND SD2.D_E_L_E_T_ = SF4.D_E_L_E_T_ "
    cQry += " INNER JOIN "+ retsqlname('SB1') +" SB1 WITH(NOLOCK) ON '' = SB1.B1_FILIAL AND SD2.D2_COD = SB1.B1_COD AND SD2.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
    cQry += " WHERE SD2.D2_FILIAL  = '"+FwFIlial()+"'   "
    cQry += " AND SD2.D2_EMISSAO  BETWEEN '"+::perDe+"' AND '"+::perAte+"'   "
    cQry += " AND SF4.F4_ESTOQUE  = 'S'   "
    cQry += " AND SF4.F4_PODER3 IN (' ' , 'N' )   "
    cQry += " AND SD2.D2_TIPO  = 'D'   "
    cQry += " AND SD2.D2_ORIGLAN  <> 'LF'   "
    cQry += " AND SD2.D2_REMITO  = '         '   "
    cQry += " AND SB1.B1_TIPO  IN ('ME','MO', 'MP', 'OI', 'PA','PI','SC','SV','MR') "
    cQry += " AND SD2.D_E_L_E_T_  = ' '  "
    if lSintetico
        cQry += " ) AS DETALHES  "
        cQry += " GROUP BY DETALHES.B1_TIPO "
    endif
return(::execQuery(cQry))


method devVenda(lSintetico) class cbcCusQry
    local cQry as character
    default lSintetico := .T.
    cQry := ""
    if lSintetico
        cQry := " SELECT "
        cQry += " DETALHES.B1_TIPO		AS TIPO, "
        cQry += " ROUND(SUM(DETALHES.D1_CUSTO),2)  AS CUSTO "
        cQry += " FROM "
        cQry += " ( "
    endif
    cQry += "     SELECT  "
    cQry += " SD1.D1_COD, "
    cQry += " SD1.D1_COD AS ALL_PROD, "
    cQry += " SD1.D1_CUSTO AS ALL_CUSTO, "
    cQry += " SB1.B1_TIPO AS ALL_TIPO,  "
    cQry += " SD1.D1_DOC, "
    cQry += " SD1.D1_SERIE, "
    cQry += " SD1.D1_CUSTO, "
    cQry += " SB1.B1_DESC, "
    cQry += " SB1.B1_TIPO "
    cQry += " FROM "+RetSqlName('SD1') +" SD1 WITH(NOLOCK) "
    cQry += " INNER JOIN "+RetSqlName('SF4') +" SF4 WITH(NOLOCK) ON '' = SF4.F4_FILIAL AND SD1.D1_TES = SF4.F4_CODIGO AND SD1.D_E_L_E_T_ = SF4.D_E_L_E_T_ "
    cQry += " INNER JOIN "+RetSqlName('SB1') +" SB1 WITH(NOLOCK) ON '' = SB1.B1_FILIAL AND SD1.D1_COD = SB1.B1_COD AND SD1.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
    cQry += " WHERE SD1.D1_FILIAL  = '"+FwFilial()+"' "
    cQry += " AND SD1.D1_DTDIGIT  BETWEEN '" + ::perDe + "' AND '" + ::perAte + "'     "
    cQry += " AND SF4.F4_ESTOQUE  = 'S'   "
    cQry += " AND SF4.F4_PODER3 IN (' ' , 'N' )   "
    cQry += " AND SF4.D_E_L_E_T_  = ' '  "
    cQry += " AND SD1.D1_TIPO  = 'D'   "
    cQry += " AND SD1.D1_ORIGLAN  <> 'LF'   "
    cQry += " AND SD1.D1_REMITO  = '         '   "
    cQry += " AND SD1.D_E_L_E_T_  = ' '   "
    cQry += " AND SB1.B1_TIPO  IN ('ME','MO', 'MP', 'OI', 'PA','PI','SC','SV','MR') "
    if lSintetico
        cQry += " ) AS DETALHES  "
        cQry += " GROUP BY DETALHES.B1_TIPO "
    endif
return(::execQuery(cQry))


method venda(lSintetico) class cbcCusQry
    local cQry as character
    default lSintetico := .T.
    cQry := ""
    if lSintetico
        cQry := " SELECT " 
        cQry += " DETALHES.B1_TIPO		AS TIPO, "
        cQry += " ROUND(SUM(DETALHES.D2_CUSTO1),2) AS CUSTO "
        cQry += " FROM "
        cQry += " ( "
    endif
    cQry += " SELECT  "
    cQry += " SD2.D2_COD AS ALL_PROD, "
    cQry += " SD2.D2_CUSTO1 AS ALL_CUSTO, "
    cQry += " SB1.B1_TIPO AS ALL_TIPO,  "
    cQry += " SD2.D2_COD, "
    cQry += " SD2.D2_DOC, "
    cQry += " SD2.D2_SERIE, "
    cQry += " SD2.D2_CUSTO1, "
    cQry += " SB1.B1_DESC, "
    cQry += " SB1.B1_TIPO "
    cQry += " FROM " + RetSqlName('SD2') +" SD2 WITH(NOLOCK) "
    cQry += " INNER JOIN " + RetSqlName('SF4') +" SF4 WITH(NOLOCK) ON '' = SF4.F4_FILIAL AND SD2.D2_TES = SF4.F4_CODIGO AND SD2.D_E_L_E_T_ = SF4.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SB1') +" SB1 WITH(NOLOCK) ON '' = SB1.B1_FILIAL AND SD2.D2_COD = SB1.B1_COD AND SD2.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
    cQry += " WHERE SD2.D2_FILIAL  = '"+FwFilial()+"'   "
    cQry += " AND SD2.D2_EMISSAO  BETWEEN '"+::perDe+"' AND '"+::perAte+"'   "
    cQry += " AND SF4.F4_ESTOQUE  = 'S'   "
    cQry += " AND SF4.F4_PODER3 IN (' ' , 'N' )   "
    cQry += " AND SD2.D2_TIPO  <> 'D'  "
    cQry += " AND SD2.D2_ORIGLAN  <> 'LF'   "
    cQry += " AND SD2.D2_REMITO  = '         '   "
    cQry += " AND SB1.B1_TIPO  IN ('ME','MO', 'MP', 'OI', 'PA','PI','SC','SV','MR') "
    cQry += " AND SD2.D_E_L_E_T_  = ' '  "
    if lSintetico
        cQry += " ) AS DETALHES  "
        cQry += " GROUP BY DETALHES.B1_TIPO "
    endif
return(::execQuery(cQry))


method producao(lSintetico) class cbcCusQry
    local cQry as character
    default lSintetico := .T.
    cQry := ""
    if lSintetico
        cQry := " SELECT "
        cQry += " DETALHES.TP_PROD AS TIPO,"
        cQry += " ROUND(SUM(DETALHES.VLR_CUSTO),2) AS CUSTO "
        cQry += " FROM ("
    endif
    cQry += " SELECT "
    cQry += " SD3.D3_CF AS TP_MOV, "
    cQry += " SD3.D3_COD AS ALL_PROD, "
    cQry += " SB1.B1_TIPO AS ALL_TIPO,  "
    cQry += " CASE WHEN LEFT( D3_CF ,1 ) = 'R' "
    cQry += " THEN (SD3.D3_CUSTO1 * -1) "
    cQry += " ELSE SD3.D3_CUSTO1 "
    cQry += " END     AS ALL_CUSTO, "
    cQry += " SD3.D3_TIPO AS TP_PROD, "
    cQry += " SD3.D3_DOC  AS DCTO, "
    cQry += " SD3.D3_OP   AS OP, "
    cQry += " SD3.D3_SEQCALC AS SEQCALC, "
    cQry += " SD3.D3_NUMSEQ AS NUMSEQ, "
    cQry += " SB1.B1_DESC  AS DESC_PROD, "
    cQry += " CASE WHEN LEFT( D3_CF ,1 ) = 'R' "
    cQry += " THEN (SD3.D3_QUANT * -1) "
    cQry += " ELSE SD3.D3_QUANT "
    cQry += " END     AS QUANTIDADE, "
    cQry += " CASE WHEN LEFT( D3_CF ,1 ) = 'R' "
    cQry += " THEN (SD3.D3_CUSTO1 * -1) "
    cQry += " ELSE SD3.D3_CUSTO1 "
    cQry += " END     AS VLR_CUSTO, "
    cQry += " SB1.B1_PESCOB AS KG_COBRE, "
    cQry += " SD3.D3_QUANT * SB1.B1_PESCOB AS TOTAL_COBRE, "
    cQry += " SD3.D3_HIST AS HIST "

    cQry += " FROM " + RetSqlName('SD3') +" SD3 WITH(NOLOCK) "
    cQry += " INNER JOIN "+ RetSqlName('SB1') +" SB1 WITH(NOLOCK) ON '' = SB1.B1_FILIAL AND SD3.D3_COD = SB1.B1_COD AND SD3.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
    cQry += " WHERE  "
    cQry += " SD3.D3_FILIAL = '" + FwFilial() + "'" "
    cQry += " AND SD3.D3_EMISSAO BETWEEN '"+::perDe+"' AND '"+::perAte+"' "
    cQry += " AND SD3.D3_CF IN ('PR0' , 'PR1' )  "
    cQry += " AND SD3.D3_ESTORNO <> 'S' "
    cQry += " AND SD3.D3_TIPO	 IN ('ME','MO', 'MP', 'OI', 'PA','PI','SC','SV','MR') "
    cQry += " AND SD3.D_E_L_E_T_ = '' "
    if lSintetico
        cQry += " ) AS DETALHES  "
        cQry += " GROUP BY DETALHES.TP_PROD "
        cQry += " ORDER BY DETALHES.TP_PROD "
    endif
return(::execQuery(cQry))


method movIntReqProd(lSintetico, lProd) class cbcCusQry
    local cQry as character
    default lSintetico := .T.
    default lProd := .F.
            cQry := ""
            if lSintetico
                cQry := " SELECT "
                cQry += " ISNULL(MOV_INTERNA.TIPO,REQ_PROD.TIPO)							AS TIPO, "
                cQry += " ROUND(ISNULL(MOV_INTERNA.VLR_CUSTO,0), 2)							AS MOV_INTERNA, "
                cQry += " ROUND(ISNULL(MOV_INTERNA.VLR_CUSTO,0) - REQ_PROD.VLR_CUSTO ,2)	AS REQ_PRODUCAO	 "
                cQry += " FROM  "
                cQry += " ( "
                cQry += " SELECT  "
                cQry += " DETALHES.TP_PROD AS TIPO, "
                cQry += " SUM(DETALHES.VLR_CUSTO) AS VLR_CUSTO   "
                cQry += " FROM ( "
            endif
            if !lSintetico .and. lProd
                cQry += " SELECT MN.ALL_TIPO, MN.ALL_PROD, SUM(MN.VLR_CUSTO) AS ALL_CUSTO FROM "
                cQry += " ( "
            EndIf
            cQry += " SELECT  "
            cQry += " SD3.D3_CF		    AS TP_MOV, "
            cQry += " SD3.D3_COD AS ALL_PROD, " 
            cQry += " SB1.B1_TIPO AS ALL_TIPO,  "
            cQry += " CASE WHEN LEFT( D3_CF ,1 ) = 'R' "
            cQry += " THEN (SD3.D3_CUSTO1 * -1) "
            cQry += " ELSE SD3.D3_CUSTO1 "
            cQry += " END     AS ALL_CUSTO, "
            cQry += " SD3.D3_TIPO		AS TP_PROD, "
            cQry += " SB1.B1_DESC		AS DESC_PROD, "
            cQry += " SD3.D3_DOC		AS DCTO, "
            cQry += " SD3.D3_OP		    AS OP, "
            cQry += " SD3.D3_SEQCALC	AS SEQCALC, "
            cQry += " SD3.D3_NUMSEQ	AS NUMSEQ, "
            cQry += " CASE WHEN LEFT( D3_CF ,1 ) = 'R' "
            cQry += " THEN (SD3.D3_QUANT * -1) "
            cQry += " ELSE SD3.D3_QUANT "
            cQry += " END   AS QUANTIDADE, "
            cQry += " CASE WHEN LEFT( D3_CF ,1 ) = 'R' "
            cQry += " THEN (SD3.D3_CUSTO1 * -1) "
            cQry += " ELSE SD3.D3_CUSTO1 "
            cQry += " END     AS VLR_CUSTO, "
            cQry += " SB1.B1_PESCOB AS KG_COBRE, "
            cQry += " SD3.D3_QUANT * SB1.B1_PESCOB AS TOTAL_COBRE, "
            cQry += " SD3.D3_HIST AS HIST "
            cQry += " FROM "+ RetSqlName('SD3')+" SD3 WITH(NOLOCK) "
            cQry += " INNER JOIN "+ RetSqlName('SB1')+" SB1 WITH(NOLOCK) ON '' = SB1.B1_FILIAL AND SD3.D3_COD = SB1.B1_COD AND SD3.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
            cQry += " WHERE  "
            cQry += " SD3.D3_FILIAL = '" + FwFilial() + "' "
            cQry += " AND SD3.D3_EMISSAO BETWEEN '" +::perDe + "' AND '" + ::perAte +"' "
            cQry += " AND D3_CF NOT IN ('PR0','PR1') "
            cQry += " AND SUBSTRING ( D3_OP , 7 , 2 ) <> 'OS' "
            cQry += " AND (SD3.D3_TM  < '501' OR SD3.D3_TM > '500'   ) "
            cQry += " AND SD3.D3_ESTORNO <> 'S' "
            cQry += " AND SD3.D3_TIPO	 IN ('ME','MO', 'MP', 'OI', 'PA','PI','SC','SV','MR') "
            cQry += " AND SD3.D_E_L_E_T_ = '' "
            
            if lSintetico
                cQry += " ) AS DETALHES "
                cQry += " GROUP BY DETALHES.TP_PROD "
                cQry += " ) AS REQ_PROD "
                cQry += " LEFT JOIN ( "
                cQry += " SELECT  "
                cQry += " DETALHES.TP_PROD AS TIPO, "
                cQry += " SUM(DETALHES.VLR_CUSTO) AS VLR_CUSTO  "
                cQry += " FROM ( "
                cQry += " SELECT  "
                cQry += " SD3.D3_CF AS TP_MOV, "
                cQry += " CASE WHEN LEFT( D3_CF ,1 ) = 'R' "
                cQry += " THEN (SD3.D3_CUSTO1 * -1) "
                cQry += " ELSE SD3.D3_CUSTO1 "
                cQry += " END     AS ALL_CUSTO, "
                cQry += " SD3.D3_TIPO AS TP_PROD, "
                cQry += " SD3.D3_DOC  AS DCTO, "
                cQry += " SD3.D3_OP   AS OP, "
                cQry += " SD3.D3_SEQCALC AS SEQCALC, "
                cQry += " SD3.D3_NUMSEQ AS NUMSEQ, "
                cQry += " SB1.B1_DESC  AS DESC_PROD, "
                cQry += " CASE WHEN LEFT( D3_CF ,1 ) = 'R' "
                cQry += " THEN (SD3.D3_QUANT * -1) "
                cQry += " ELSE SD3.D3_QUANT "
                cQry += " END     AS QUANTIDADE, "
                cQry += " CASE WHEN LEFT( D3_CF ,1 ) = 'R' "
                cQry += " THEN (SD3.D3_CUSTO1 * -1) "
                cQry += " ELSE SD3.D3_CUSTO1 "
                cQry += " END     AS VLR_CUSTO, "
                cQry += " SB1.B1_PESCOB AS KG_COBRE, "
                cQry += " SD3.D3_QUANT * SB1.B1_PESCOB AS TOTAL_COBRE, "
                cQry += " SD3.D3_HIST AS HIST "
                cQry += " FROM "+ RetSqlName('SD3')+" SD3 WITH(NOLOCK) "
                cQry += " INNER JOIN "+ RetSqlName('SB1')+" SB1 WITH(NOLOCK) ON '' = SB1.B1_FILIAL AND SD3.D3_COD = SB1.B1_COD AND SD3.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
                cQry += " WHERE  "
                cQry += " SD3.D3_FILIAL = '" +FwFilial() +"' "
                cQry += " AND SD3.D3_EMISSAO BETWEEN '"+ ::perDe +"' AND '"+ ::perAte + "' "
                cQry += " AND D3_CF NOT IN ('RE4','DE4') "
                cQry += " AND D3_OP				= '' "
                cQry += " AND SD3.D3_ESTORNO		<> 'S' "
                cQry += " AND SD3.D3_TIPO			IN ('ME','MO', 'MP', 'OI', 'PA','PI','SC','SV','MR') "
                cQry += " AND SD3.D_E_L_E_T_		= '' "
                cQry += " ) AS DETALHES " 
                cQry += " GROUP BY DETALHES.TP_PROD "
                cQry += " ) AS MOV_INTERNA ON REQ_PROD.TIPO = MOV_INTERNA.TIPO "
                cQry += " ORDER BY ISNULL(MOV_INTERNA.TIPO,REQ_PROD.TIPO) "
            elseif !lSintetico .and. lProd
                cQry += " ) AS MN "
                cQry += " GROUP BY MN.ALL_TIPO, MN.ALL_PROD "
            endif
return(::execQuery(cQry))


method compras(lSintetico)  class cbcCusQry
    local cQry as character
    default lSintetico := .T.
    cQry := ""
    cQry := " SELECT " 
    cQry += " 'compras'                         AS ID, "
    if lSintetico
        cQry += " SB1.B1_TIPO                   AS TIPO, "
        cQry += " ROUND(ISNULL( SUM(D1_CUSTO), 0 ),2)  AS CUSTO "
    else
        cQry += "SD1.D1_COD AS ALL_PROD, SD1.D1_CUSTO AS ALL_CUSTO, SB1.B1_TIPO AS ALL_TIPO, SD1.D1_DOC, SD1.D1_CUSTO "
    endif
    cQry += " FROM "+ RetSqlName('SD1') +" SD1, "+ RetSqlName('SF4') +" SF4, "+ RetSqlName('SB1') +" SB1 "
    cQry += " WHERE SD1.D1_FILIAL  IN ( '" + FwFilial() + "' ) "
    cQry += " AND SD1.D1_DTDIGIT  >= '" + ::perDe + "' "
    cQry += " AND SD1.D1_DTDIGIT  <= '" + ::perAte + "' "  
    cQry += " AND SF4.F4_FILIAL  = '' "
    cQry += " AND SD1.D1_TES  = SF4.F4_CODIGO   "
    cQry += " AND SF4.F4_ESTOQUE  = 'S'   "
    cQry += " AND SF4.F4_PODER3 IN (' ' , 'N' ) "  
    cQry += " AND SD1.D1_TIPO  <> 'D'  "
    cQry += " AND SD1.D1_ORIGLAN  <> 'LF' "  
    cQry += " AND SD1.D1_REMITO  = '         ' "  
    cQry += " AND SD1.D_E_L_E_T_  = ' ' "
    cQry += " AND SF4.D_E_L_E_T_  = ' ' " 
    cQry += " AND SB1.B1_FILIAL  ='' "
    cQry += " AND SB1.B1_COD  = SD1.D1_COD "
    cQry += " AND SB1.D_E_L_E_T_  = ' ' "
    if lSintetico
        cQry += " GROUP BY SB1.B1_TIPO
    endif
return(::execQuery(cQry))


method balancete(cConta) class cbcCusQry
    local cQry as character
    cConta := left(cConta,5)
    cQry := ""
    cQry += " SELECT " 
	cQry += " MATR.BALANCETE AS BALANCETE, "
    cQry += " MATR.ENTRADA_SAIDA AS ENTRADA_SAIDA, "
    cQry += " MATR.DIF AS DIF, "
    cQry += " CT2.R_E_C_N_O_ AS RECNO, "
    cQry += " CT2.CT2_DATA AS DATA, "
    cQry += " CT2.CT2_LOTE AS LOTE, "
    cQry += " CT2.CT2_DOC AS DOC, "
    cQry += " CT2.CT2_LINHA AS LINHA, "
    cQry += " CT2.CT2_DEBITO AS DEBITO, "
    cQry += " CT2.CT2_CREDIT AS CREDITO, "
    cQry += " CT2.CT2_HIST AS HIST, "
    cQry += " CT2.CT2_ORIGEM AS ORIGEM, "
    cQry += " CT2.CT2_LP AS LP, "
    cQry += " CT2.CT2_SEQHIS AS LP_SEQ "
    cQry += " FROM  "
    cQry += " ( "
    cQry += " SELECT  "
    cQry += " MOV.REC, "
    cQry += " ROUND(AVG(MOV.VALOR_MOVIMENTO),2) AS BALANCETE, "
    cQry += " ROUND(SUM(MOV.VALOR_CTK),2) AS ENTRADA_SAIDA, "
    cQry += " ROUND(AVG(MOV.VALOR_MOVIMENTO)-SUM(MOV.VALOR_CTK),2) AS DIF "
    cQry += " FROM ( "
    cQry += " SELECT  "
    cQry += " CT2.R_E_C_N_O_      AS REC, "
    cQry += " CASE WHEN CT2.CT2_DEBITO LIKE '" + cConta + "%' THEN 0 "
    cQry += " ELSE CT2.CT2_VALOR "
    cQry += " END  AS VALOR_CREDITO, "
    cQry += " CASE WHEN CT2.CT2_CREDIT LIKE '" + cConta + "%' THEN 0 "
    cQry += " ELSE CT2.CT2_VALOR "
    cQry += " END  AS VALOR_DEBITO, "
    cQry += " CASE WHEN CT2.CT2_DEBITO LIKE '" + cConta + "%' AND  CT2.CT2_CREDIT LIKE '" + cConta + "%' THEN 0 "
    cQry += " ELSE "
    cQry += " CASE WHEN CT2.CT2_CREDIT LIKE '" + cConta + "%'  THEN (CT2.CT2_VALOR * -1) ELSE  "
    cQry += " CASE WHEN CT2.CT2_DEBITO LIKE '" + cConta + "%' THEN CT2.CT2_VALOR END "
    cQry += " END "
    cQry += " END AS VALOR_MOVIMENTO, "
    cQry += " CASE WHEN CT2.CT2_DEBITO LIKE '" + cConta + "%' AND  CT2.CT2_CREDIT LIKE '" + cConta + "%' THEN 0 "
    cQry += " ELSE "
    cQry += " CASE WHEN CT2.CT2_CREDIT LIKE '" + cConta + "%'  THEN (ISNULL(CTK.CTK_VLR01,0) * -1) ELSE  "
    cQry += " CASE WHEN CT2.CT2_DEBITO LIKE '" + cConta + "%' THEN ISNULL(CTK.CTK_VLR01,0) END "
    cQry += " END "
    cQry += " END AS VALOR_CTK "
    cQry += " FROM " + RetSqlName('CT2') + " CT2 WITH(NOLOCK)  "
    cQry += " LEFT JOIN " + RetSqlName('CTK') + " CTK WITH(NOLOCK) ON  "
    cQry += " CT2.R_E_C_N_O_ =  CTK.CTK_RECDES  "
    cQry += " AND CT2.D_E_L_E_T_ = CTK.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('CT1') + " CTA WITH(NOLOCK) ON '' = CTA.CT1_FILIAL AND CTA.CT1_CONTA =   "
    cQry += " CASE  "
    cQry += " WHEN CT2.CT2_DEBITO LIKE '" + cConta + "%'  "
    cQry += " THEN CT2.CT2_DEBITO "
    cQry += " ELSE  "
    cQry += " CASE  "
    cQry += " WHEN CT2.CT2_CREDIT LIKE '" + cConta + "%'  "
    cQry += " THEN CT2.CT2_CREDIT  "
    cQry += " END "
    cQry += " END "
    cQry += " AND CT2.D_E_L_E_T_ = CTA.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('CT1') + " CTSUP WITH(NOLOCK)  ON '' = CTSUP.CT1_FILIAL AND CTA.CT1_CTASUP = CTSUP.CT1_CONTA "
    cQry += " AND CTSUP.D_E_L_E_T_ = CTA.D_E_L_E_T_ "
    cQry += " WHERE "
    cQry += " CT2.CT2_FILIAL IN ('"+FwFilial()+"') "
    cQry += " AND CT2.CT2_DATA BETWEEN '"+ ::perDe +"' AND '"+ ::perAte +"' "
    cQry += " AND (CT2.CT2_DEBITO LIKE '" + cConta + "%' OR CT2.CT2_CREDIT LIKE '" + cConta + "%') "
    cQry += " AND CT2.CT2_TPSALD = 1 "
    cQry += " AND CT2.D_E_L_E_T_ = '' "
    cQry += " ) AS MOV "
    cQry += " GROUP BY MOV.REC "
    cQry += " ) AS MATR "
    cQry += " INNER JOIN " + RetSqlName('CT2') + " CT2 WITH(NOLOCK) ON CT2.R_E_C_N_O_ = MATR.REC "
    cQry += " ORDER BY CT2.R_E_C_N_O_ "
return(::execQuery(cQry))


method detLotect2(nRecCT2)class cbcCusQry
    local cQry as character
    cQry := " "
    cQry += " SELECT " 
	cQry += " CT2.CT2_DATA AS DATA, "
    cQry += " CT2.CT2_LOTE AS LOTE, "
    cQry += " CT2.CT2_DOC AS DOC, "
    cQry += " CT2.CT2_LINHA AS LINHA, "
    cQry += " CT2.CT2_DEBITO AS DEBITO, "
    cQry += " CT2.CT2_CREDIT AS CREDITO, "
    cQry += " CT2.CT2_HIST AS HIST, "
    cQry += " CT2.CT2_ORIGEM AS ORIGEM, "
    cQry += " CT2.CT2_LP AS LP, "
    cQry += " CT2.CT2_SEQHIS AS LP_SEQ, "
	cQry += " CT2.CT2_VALOR AS VLR_LOTE, "
	cQry += " CV3.CV3_VLR01 AS VLR_CONTAB, "
	cQry += " CASE  "
	cQry += " WHEN CV3.CV3_TABORI = 'SD1'  "
	cQry += " THEN 'ENTRADA'  "
	cQry += " WHEN CV3.CV3_TABORI = 'SD2' "
	cQry += " THEN 'SAIDA' "
	cQry += " WHEN CV3.CV3_TABORI = 'SD3' "
	cQry += " THEN 'MOVIMENTO' "
	cQry += " ELSE	''			END AS ORIGEM, "
	cQry += " CASE  "
	cQry += " WHEN CV3.CV3_TABORI = 'SD1'  "
	cQry += " THEN SD1.D1_DOC  "
	cQry += " WHEN CV3.CV3_TABORI = 'SD2' "
	cQry += " THEN SD2.D2_DOC "
	cQry += " WHEN CV3.CV3_TABORI = 'SD3' "
	cQry += " THEN SD3.D3_DOC "
	cQry += " ELSE	''			END AS DOCUMENTO, "
	cQry += " CASE  "
	cQry += " WHEN CV3.CV3_TABORI = 'SD1'  "
	cQry += " THEN SD1.D1_CUSTO  "
	cQry += " WHEN CV3.CV3_TABORI = 'SD2' "
	cQry += " THEN SD2.D2_CUSTO1 "
	cQry += " WHEN CV3.CV3_TABORI = 'SD3' "
	cQry += " THEN SD3.D3_CUSTO1 "
	cQry += " ELSE	''			END AS CUSTO,  "
	cQry += " CASE  "
	cQry += " WHEN CV3.CV3_TABORI = 'SD1'  "
	cQry += " THEN SD1.D1_LOCAL "
	cQry += " WHEN CV3.CV3_TABORI = 'SD2' "
	cQry += " THEN SD2.D2_LOCAL "
	cQry += " WHEN CV3.CV3_TABORI = 'SD3' "
	cQry += " THEN SD3.D3_LOCAL "
	cQry += " ELSE	''			END AS LOCAL, "
	cQry += " CASE  "
	cQry += " WHEN CV3.CV3_TABORI = 'SD1'  "
	cQry += " THEN SD1.D1_QUANT "
	cQry += " WHEN CV3.CV3_TABORI = 'SD2' "
	cQry += " THEN SD2.D2_QUANT "
	cQry += " WHEN CV3.CV3_TABORI = 'SD3' "
	cQry += " THEN SD3.D3_QUANT "
	cQry += " ELSE	''			END AS QUANT, "
	cQry += " CASE  "
	cQry += " WHEN CV3.CV3_TABORI = 'SD1'  "
	cQry += " THEN SD1.D1_OP "
	cQry += " WHEN CV3.CV3_TABORI = 'SD2' "
	cQry += " THEN SD2.D2_OP "
	cQry += " WHEN CV3.CV3_TABORI = 'SD3' "
	cQry += " THEN SD3.D3_OP "
	cQry += " ELSE	''			END AS OP, "
	cQry += " CASE  "
	cQry += " WHEN CV3.CV3_TABORI = 'SD1'  "
	cQry += " THEN SD1.D1_CF "
	cQry += " WHEN CV3.CV3_TABORI = 'SD2' "
	cQry += " THEN SD2.D2_CF "
	cQry += " WHEN CV3.CV3_TABORI = 'SD3' "
	cQry += " THEN SD3.D3_CF "
	cQry += " ELSE	''			END AS CF, "
	cQry += " CASE  "
	cQry += " WHEN CV3.CV3_TABORI = 'SD1'  "
	cQry += " THEN SD1.D1_VALICM "
	cQry += " WHEN CV3.CV3_TABORI = 'SD2' "
	cQry += " THEN SD2.D2_VALICM "
	cQry += " WHEN CV3.CV3_TABORI = 'SD3' "
	cQry += " THEN 0 "
	cQry += " ELSE	''			END AS ICMS, "
	cQry += " SB1.B1_DESC				AS DESC_PRODUTO, "
	cQry += " SB1.B1_TIPO				AS TIPO_PRODUTO  "
    
    
    
    cQry += " FROM  " + RetSqlName('CV3') + " CV3 WITH(NOLOCK) "
    cQry += " LEFT JOIN  " + RetSqlName('SD1') + " SD1 WITH(NOLOCK) ON SD1.R_E_C_N_O_ = CV3_RECORI "
    cQry += " AND SD1.D_E_L_E_T_ = CV3.D_E_L_E_T_ "
    cQry += " LEFT JOIN  " + RetSqlName('SD2') + " SD2 WITH(NOLOCK) ON SD2.R_E_C_N_O_ = CV3_RECORI "
    cQry += " AND SD2.D_E_L_E_T_ = CV3.D_E_L_E_T_ "
    cQry += " LEFT JOIN  " + RetSqlName('SD3') + " SD3 WITH(NOLOCK) ON SD3.R_E_C_N_O_ = CV3_RECORI "
    cQry += " AND SD3.D_E_L_E_T_ = CV3.D_E_L_E_T_ "
    cQry += " INNER JOIN  " + RetSqlName('SB1') + " SB1 WITH(NOLOCK) ON '' = SB1.B1_FILIAL "
    cQry += " AND SB1.B1_COD = CASE  "
    cQry += " WHEN CV3.CV3_TABORI = 'SD1'  "
    cQry += " THEN SD1.D1_COD "
    cQry += " WHEN CV3.CV3_TABORI = 'SD2' "
    cQry += " THEN SD2.D2_COD "
    cQry += " WHEN CV3.CV3_TABORI = 'SD3' "
    cQry += " THEN SD3.D3_COD "
    cQry += " ELSE	''			END "
    cQry += " AND SB1.D_E_L_E_T_ = '' "
    cQry += " INNER JOIN " + RetSqlName('CT2') + " CT2 WITH(NOLOCK) ON CT2.R_E_C_N_O_ = CV3.CV3_RECDES "
    cQry += " AND CT2.D_E_L_E_T_ = '' "
    cQry += " WHERE CV3.CV3_RECDES = " + cValToChar(nRecCT2)
    cQry += " AND CV3.D_E_L_E_T_ = '' "

return(::execQuery(cQry))


static function HandleEr(oErr, aRet)
    aRet := {}
    BREAK
return(nil)


/*
SELECT D1.D1_COD AS [PRODUTO],
D1.D1_DOC AS [NF],
D1.D1_DTDIGIT AS [DIGIT],
D1.D1_EMISSAO AS [EMISSAO],
D1.D1_ITEM AS [ITEM],
D1.D1_TES AS [TES],
D1.D1_CUSTO AS [CM_ENTRA],
(
						SELECT D2.D2_CUSTO1 CUSTOD2
						FROM SD2010 D2
						WHERE D2.D2_FILIAL = A2.A2_FILTRF
						AND D2.D2_DOC = D1.D1_DOC
						AND D2.D2_SERIE = D1.D1_SERIE
						AND D2.D2_ITEM = D1.D1_ITEM
						AND D2.D_E_L_E_T_ = ''
) AS [CM_SAIDA]
FROM SD1010 D1
INNER JOIN SF4010 F4 ON '' = F4.F4_FILIAL AND D1.D1_TES = F4.F4_CODIGO AND F4.D_E_L_E_T_ = ''
INNER JOIN SA2010 A2 ON '' = A2.A2_FILIAL AND D1.D1_FORNECE = A2.A2_COD AND D1.D1_LOJA = A2.A2_LOJA AND D1.D_E_L_E_T_ = A2.D_E_L_E_T_
WHERE D1.D1_FILIAL = '01'
AND D1.D1_DTDIGIT BETWEEN '20210501' AND '20210531'
AND (F4.F4_TRANFIL = '1')
AND D1.D_E_L_E_T_ = ''
ORDER BY D1_DOC, D1_ITEM
*/
