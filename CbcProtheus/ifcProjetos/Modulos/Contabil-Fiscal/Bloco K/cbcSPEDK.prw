#include 'totvs.ch'

user function cbcSPEDK()
    // iniciar View
    FWMsgRun(, { || view() }, 	"SPED Fiscal - Bloco K", "Iniciando...")
return(nil)

static function view()
    local dDataPer  := nil
    local nOpc      := 0
    local lSPEDK    := GetNewPar('ZZ_SPEDBLK', .T.)

    if perg(@dDataPer, @nOpc)
        if lSPEDK
            process(dDataPer, nOpc)
        else
            chamaOpc(nOpc)
        endif
    endif
return(nil)

static function perg(dDataPer, nOpc)
    local aRet      := {}
    local aPerg     := {}
    local lRet      := .F.

    aadd(aPerg,{1,"Fechamento: ", dDataBase,"",".T.","",".T.",50,.T.})
    aadd(aPerg,{3,"Finalidade: ",1,{"Arq. TXT", "Relatório"},50,"",.T.})

    if (lRet := ParamBox(aPerg,"SPED Fiscal - Bloco K",@aRet))
        dDataPer := aRet[01]
        nOpc     := aRet[02]
    endif
return(lRet)

static function vldProc(dDataP)
    local lVld      := .T.
    local dUlMes    := GetMv("MV_ULMES")
    
    if dDataP <= dUlMes
        lVld := .F.
        MsgAlert('Data Invalida','MV_ULMES - Data invalida!')
    endif
return(lVld)

static function process(dDataP, nOpc)
    local aArea    	:= GetArea()
    local aAreaSB6	:= SB6->(getArea())
    local aAreaD3K	:= D3K->(getArea())
    local bErro     := ErrorBlock({|oErr| HandleEr(oErr, dDataP)})

    if !LockByName("cbcSPEDK_"+cFilAnt,.F.,.F.,.T.)
	    Alert("Rotina está sendo executada por outro usuário.")
	else
        BEGIN SEQUENCE
            //BEGIN TRANSACTION
                zeraAltera(dDataP)
                TcSqlExec(qrySB6E(dDataP))
                TcSqlExec(qrySB6D(dDataP))
                //procAdd(dDataP)
                //TcSqlExec(qryMudaReq(dDataP))
                ProcDebita(dDataP)
                chamaOpc(nOpc)
                zeraAltera(dDataP)
            //END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
        UnLockByName("cbcSPEDK_"+cFilAnt,.F.,.F.,.T.)
    endif
    RestArea(aAreaD3K)
    RestArea(aAreaSB6)
    RestArea(aArea)
return(nil)

static function zeraAltera(dDataP)
    TcSqlExec(qryRestDebita())
    TcSqlExec(qrySB6E(dDataP, .F.))
    TcSqlExec(qrySB6D(dDataP, .F.))    
    procDel()    
return(nil)

static function ProcDebita(dDataP)
    local aArea    	:= GetArea()
    local aAreaSB6	:= SB6->(getArea())
    local oSql      := LibSqlObj():newLibSqlObj()

    oSql:newAlias(qryDebita(dDataP))
    if oSql:hasRecords()
        oSql:goTop()
        DbSelectArea('SB6')
        while oSql:notIsEof()
            SB6->(DbGoTo(oSql:getValue("REC")))
            SB6->(RecLock("SB6",.F.))
                SB6->B6_ZDEBITA += oSql:getValue("QUANT")
                SB6->B6_QUANT -= oSql:getValue("QUANT")
			SB6->(MsUnLock())
            DebitaOrigem(oSql:getValue("IDENT"), oSql:getValue("PROD"), oSql:getValue("QUANT"), dDataP)
            oSql:Skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)

    RestArea(aAreaSB6)
    RestArea(aArea)
return(nil)

static function DebitaOrigem(cIdent, cProd, nQuant, dDataP)
    local aArea    	:= GetArea()
    local aAreaSB6	:= SB6->(getArea())
    local oSql      := LibSqlObj():newLibSqlObj()

    oSql:newAlias(qryOrigem(cIdent, cProd, dDataP))
    if oSql:hasRecords()
        oSql:goTop()
        DbSelectArea('SB6')
        while oSql:notIsEof()
            SB6->(DbGoTo(oSql:getValue("REC")))
            SB6->(RecLock("SB6",.F.))
                SB6->B6_ZDEBITA += nQuant
                SB6->B6_QUANT -= nQuant
			SB6->(MsUnLock())
            oSql:Skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)

    RestArea(aAreaSB6)
    RestArea(aArea)
return(nil)

static function procAdd(dDataP)
    local oSql := LibSqlObj():newLibSqlObj()
    local oSql2:= nil

    oSql:newAlias(qryAdd(dDataP))
    if oSql:hasRecords()
        oSql:goTop()
        DbSelectArea('D3K')
        while oSql:notIsEof()
            oSql2 := LibSqlObj():newLibSqlObj()
            oSql2:newAlias(qrySD3(AllTrim(oSql:getValue("PROD")), dDataP))
            if oSql2:hasRecords()
                oSql2:goTop()
                RecLock("D3K",.T.)
                    D3K->D3K_FILIAL := FwFilial()
                    D3K->D3K_CLIENT := oSql:getValue("CLI_FOR")
                    D3K->D3K_LOJA   := oSql:getValue("LOJA")
                    D3K->D3K_COD    := oSql:getValue("PROD")
                    D3K->D3K_NUMSEQ := oSql2:getValue("SEQ")
                    D3K->D3K_OP     := oSql2:getValue("OP")
                    D3K->D3K_QTDE   := (oSql:getValue("QUANT"))
                D3K->(MsUnLock())
            endif
            oSql2:close()
            FreeObj(oSql2)
            oSql:Skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)
return(nil)

static function procDel()
        DbSelectArea('D3K')
        D3K->(DbGoTop())
        while !D3K->(EOF())
            D3K->(RecLock("D3K",.F.))
                D3K->(DbDelete())
			D3K->(MsUnLock())
            D3K->(DbSkip())
        endDo
return(nil)

static function chamaOpc(nOpc)
    if nOpc == 1
        FWMsgRun(, { || SPEDFISCAL() }, 	"Arquivo TXT do SPED", "Processando...")
    elseif nOpc == 2
        FWMsgRun(, { || U_CBCMT241() }, 	"Relatório Bloco K", "Processando...")
    else
        MsgAlert('Opção não localizada!', 'Inválida')
    endif
return(nil)

static function HandleEr(oErr, dDataP)
    default dDataP := dDataBase
    if InTransact()
        DisarmTransaction()
    endif
    zeraAltera(dDataP)
    Alert(oErr:Description, 'Error')
    BREAK
return(nil)

/*QUERY ZONE*/
static function qryAdd(dDataP)
    local cQry := ""
    cQry += " SELECT  "
    cQry += " SB6.B6_PRODUTO AS [PROD], "
    cQry += " SB6REM.B6_CLIFOR AS [CLI_FOR], "
    cQry += " SB6REM.B6_LOJA AS [LOJA], "
    cQry += " SUM(SB6.B6_QUANT) AS [QUANT] "
    cQry += " FROM " + retSqlName('SB6') + " SB6  "
    cQry += " INNER JOIN " + retSqlName('SB1') + " SB1 ON  "
    cQry += " 						SB1.B1_FILIAL = '  '  "
    cQry += " 						AND SB1.B1_COD = SB6.B6_PRODUTO  "
    cQry += " 						AND SB1.B1_COD NOT LIKE 'MOD%'  "
    cQry += " 						AND SB1.B1_CCCUSTO = ' '  "
    cQry += " 						AND SB1.D_E_L_E_T_ = ' '  "
    cQry += " LEFT JOIN " + retSqlName('SB6') + " SB6REM ON  "
    cQry += " 						SB6REM.B6_FILIAL = SB6.B6_FILIAL  "
    cQry += " 						AND SB6REM.B6_IDENT = SB6.B6_IDENT  "
    cQry += " 						AND SB6REM.B6_TIPO = 'D'  "
    cQry += " 						AND SB6REM.B6_PRODUTO = SB6.B6_PRODUTO  "
    cQry += " 						AND SB6REM.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
    cQry += " 						AND SB6REM.D_E_L_E_T_ = ' '  "
    cQry += " INNER JOIN " + retSqlName('SF4') + " SF4REM ON  "
    cQry += " 						SF4REM.F4_FILIAL = '  '  "
    cQry += " 						AND SF4REM.F4_CODIGO = SB6REM.B6_TES  "
    cQry += " 						AND SF4REM.F4_PODER3 = 'R'  "
    cQry += " 						AND SF4REM.D_E_L_E_T_ = ' '  "
    cQry += " INNER JOIN " + retSqlName('SF4') + " SF4 ON  "
    cQry += " 						SF4.F4_FILIAL = '  '  "
    cQry += " 						AND SF4.F4_CODIGO = SB6.B6_TES  "
    cQry += " 						AND SF4.F4_PODER3 = 'D'  "
    cQry += " 						AND SF4.D_E_L_E_T_ = ' '  "
    cQry += " WHERE  SB6.B6_FILIAL = '" + xFilial('SB6') + "'  "
    cQry += " AND SB6.B6_TIPO = 'D'  "
    cQry += " AND SF4REM.F4_ESTOQUE = 'S' "
    cQry += " AND SB6.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
    cQry += " AND SB6.D_E_L_E_T_ = ' '  "
    cQry += " AND SB1.B1_TIPO IN ('MP','PI')  "
    cQry += " AND SB6.B6_ORIGLAN <> 'BK' "
    cQry += " GROUP BY SB6.B6_PRODUTO, SB6REM.B6_CLIFOR, SB6REM.B6_LOJA "
return(cQry)

static function qryDebita(dDataP)
    local cQry := ""
    cQry += " SELECT "
    cQry += " SB6.B6_PRODUTO AS [PROD],
    cQry += " SB6.B6_QUANT AS [QUANT], "
    cQry += " SB6.B6_IDENT AS [IDENT], "
    cQry += " SB6.R_E_C_N_O_ AS [REC] "
    cQry += " FROM " + retSqlName('SB6') + " SB6  "
    cQry += " INNER JOIN " + retSqlName('SB1') + " SB1 ON  "
    cQry += " 						SB1.B1_FILIAL = '  '  "
    cQry += " 						AND SB1.B1_COD = SB6.B6_PRODUTO  "
    cQry += " 						AND SB1.B1_COD NOT LIKE 'MOD%'  "
    cQry += " 						AND SB1.B1_CCCUSTO = ' '  "
    cQry += " 						AND SB1.D_E_L_E_T_ = ' '  "
    cQry += " LEFT JOIN " + retSqlName('SB6') + " SB6REM ON  "
    cQry += " 						SB6REM.B6_FILIAL = SB6.B6_FILIAL  "
    cQry += " 						AND SB6REM.B6_IDENT = SB6.B6_IDENT  "
    cQry += " 						AND SB6REM.B6_TIPO = 'D'  "
    cQry += " 						AND SB6REM.B6_PRODUTO = SB6.B6_PRODUTO  "
    cQry += " 						AND SB6REM.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
    cQry += " 						AND SB6REM.D_E_L_E_T_ = ' '  "
    cQry += " INNER JOIN " + retSqlName('SF4') + " SF4REM ON  "
    cQry += " 						SF4REM.F4_FILIAL = '  '  "
    cQry += " 						AND SF4REM.F4_CODIGO = SB6REM.B6_TES  "
    cQry += " 						AND SF4REM.F4_PODER3 = 'R'  "
    cQry += " 						AND SF4REM.D_E_L_E_T_ = ' '  "
    cQry += " INNER JOIN " + retSqlName('SF4') + " SF4 ON  "
    cQry += " 						SF4.F4_FILIAL = '  '  "
    cQry += " 						AND SF4.F4_CODIGO = SB6.B6_TES  "
    cQry += " 						AND SF4.F4_PODER3 = 'D'  "
    cQry += " 						AND SF4.D_E_L_E_T_ = ' '  "
    cQry += " WHERE  SB6.B6_FILIAL = '" + xFilial('SB6') + "'  "
    cQry += " AND SB6.B6_TIPO = 'D'  "
    cQry += " AND SF4REM.F4_ESTOQUE = 'S' "
    cQry += " AND SB6.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
    cQry += " AND SB6.D_E_L_E_T_ = ' '  "
return(cQry)

static function qryOrigem(cIdent, cProd, dDataP)
    local cQry := ""
    cQry += " SELECT SB6REM.R_E_C_N_O_ AS [REC] "
    cQry += " FROM " + retSqlName('SB6') + " SB6REM "
    cQry += " INNER JOIN " + retSqlName('SF4') + " SF4REM ON "
    cQry += " 							SF4REM.F4_FILIAL = '  ' "
    cQry += " 							AND SF4REM.F4_CODIGO = SB6REM.B6_TES "
    cQry += " 							AND SF4REM.F4_PODER3 = 'R' "
    cQry += " 							AND SF4REM.D_E_L_E_T_ = ' ' "
    cQry += " WHERE SB6REM.B6_FILIAL = '" + xFilial('SB6') + "' "
    cQry += " AND SB6REM.B6_IDENT = '" + cIdent + "' "
    cQry += " AND SB6REM.B6_TIPO = 'D' "
    cQry += " AND SB6REM.B6_PRODUTO = '" + cProd + "' "
    cQry += " AND SB6REM.B6_DTDIGIT <= '" + DTOS(dDataP) + "' "
    cQry += " AND SB6REM.D_E_L_E_T_ = ' ' "
return(cQry)

static function qryRestDebita()
    local cQry := ""
    cQry += " UPDATE " + retSqlName('SB6') + " SET B6_QUANT = B6_QUANT + B6_ZDEBITA, B6_ZDEBITA = 0 "
    cQry += " FROM " + retSqlName('SB6') + " SB6 "
    cQry += " WHERE  SB6.B6_FILIAL = '" + xFilial('SB6') + "' "
    cQry += " AND SB6.D_E_L_E_T_ = '' "
    cQry += " AND SB6.B6_ZDEBITA <> 0 "
return(cQry)

static function qrySD3(cCod, dDataP)
    local cQry := ""
    cQry += " SELECT TOP 1  "
    cQry += " SD3.D3_NUMSEQ AS [SEQ], "
    cQry += " SD3.D3_OP AS [OP] "
    cQry += " FROM " + retSqlName('SD3') + " SD3 "
    cQry += " WHERE SD3.D3_FILIAL = '" + xFilial('SD3') + "' "
    cQry += " AND SD3.D3_COD = '" + AllTrim(cCod) + "' "
    cQry += " AND SD3.D3_EMISSAO <= '" + DTOS(dDataP) + "' "
    cQry += " AND SD3.D3_ESTORNO <> 'S' "
    cQry += " AND SD3.D3_OP <> '' "
    cQry += " AND SD3.D_E_L_E_T_ = '' "
    cQry += " ORDER BY SD3.D3_EMISSAO DESC, SD3.D3_QUANT "
return(cQry)

static function qryDel()
    local cQry := ""

    cQry += " SELECT D3K.R_E_C_N_O_ AS [REC] "
    cQry += " FROM " + retSqlName('D3K') + " D3K "
    cQry += " WHERE D3K.D3K_FILIAL = '" + xFilial('D3K') + "' "
    cQry += " AND D3K.D3K_IDTB6 <> '' "
    cQry += " AND D3K.D3K_IDTB6 NOT IN ( "
    cQry += " 							SELECT SB6.B6_IDENT "
    cQry += " 							FROM " + retSqlName('SB6') + " SB6 "
    cQry += " 							WHERE SB6.B6_FILIAL = D3K.D3K_FILIAL "
    cQry += " 							AND SB6.B6_PRODUTO = D3K.D3K_COD "
    cQry += " 							AND SB6.B6_CLIFOR = D3K.D3K_CLIENT "
    cQry += " 							AND SB6.B6_LOJA = D3K.D3K_LOJA "
    cQry += " 							AND SB6.D_E_L_E_T_ = D3K.D_E_L_E_T_ "
    cQry += " ) "
    cQry += " AND D3K.D_E_L_E_T_ = '' "
return(cQry)

static function qrySB6E(dDataP, lDo)
    local cQry  := ""
    default lDo := .T.

    if lDo
        cQry += " UPDATE SB6010 SET B6_TIPO = 'T' "
    else
        cQry += " UPDATE SB6010 SET B6_TIPO = 'E' "
    endif
    cQry += " FROM " + retSqlName('SB6') + " SB6 "
    cQry += " WHERE SB6.B6_FILIAL = '" + xFilial("SB6") + "' "
    if lDo
        cQry += " AND SB6.B6_IDENT NOT IN ( "
        cQry += " SELECT TEMP.B6_IDENT AS [IDENT] "
        cQry += " FROM ( "
        cQry += " SELECT  "
        cQry += " B6_IDENT, "
        cQry += " CASE  "
        cQry += " 	WHEN SUM(REQUISICAO)<=0 AND SUM(RETORNO)*-1>SUM(REQUISICAO)*-1  "
        cQry += " 		THEN ROUND(SUM(REMESSA)+ SUM(RETORNO),4) "
        cQry += " 	ELSE ROUND(SUM(REMESSA)+ SUM(REQUISICAO), 4) "
        cQry += " END SALDO  "
        cQry += " FROM ( "
        cQry += " 		SELECT  "
        cQry += " 		B6_IDENT, "
        cQry += " 		F4_ESTOQUE , "
        cQry += " 		B6_QUANT REMESSA, "
        cQry += " 		0 RETORNO, "
        cQry += " 		0 REQUISICAO  "
        cQry += " 		FROM " + retSqlName('SB6') + " SB6  "
        cQry += " 		INNER JOIN " + retSqlName('SB1') + " SB1 ON  "
        cQry += " 								SB1.B1_FILIAL = '  '  "
        cQry += " 								AND SB1.B1_COD = SB6.B6_PRODUTO  "
        cQry += " 								AND SB1.B1_COD NOT LIKE 'MOD%'  "
        cQry += " 								AND SB1.B1_CCCUSTO = ' '  "
        cQry += " 								AND SB1.D_E_L_E_T_ = ' '  "
        cQry += " 		INNER JOIN " + retSqlName('SF4') + " SF4 ON  "
        cQry += " 								SF4.F4_FILIAL = '  '  "
        cQry += " 								AND SF4.F4_CODIGO = SB6.B6_TES  "
        cQry += " 								AND SF4.F4_PODER3 = 'R'  "
        cQry += " 								AND ((SF4.F4_ESTOQUE = 'S') OR (SF4.F4_ESTOQUE = 'N' AND SF4.F4_CONTERC <> '2'))  "
        cQry += " 								AND SF4.D_E_L_E_T_ = ' '  "
        cQry += " 		WHERE  SB6.B6_FILIAL = '" + xFilial("SB6") + "'  "
        cQry += " 		AND SB6.B6_TIPO = 'E'  "
        cQry += " 		AND SB6.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
        cQry += " 		AND SB6.D_E_L_E_T_ = ' '  "
        cQry += " 		AND SB1.B1_TIPO IN ('ME','MP','ME','PI','PA','SC','PI','OI')  "
        cQry += "  "
        cQry += " 		UNION ALL   "
        cQry += "  "
        cQry += " 		SELECT   "
        cQry += " 		SB6.B6_IDENT , "
        cQry += " 		SF4REM.F4_ESTOQUE, "
        cQry += " 		0 , "
        cQry += " 		SB6.B6_QUANT * - 1 B6_QUANT , "
        cQry += " 		0   "
        cQry += " 		FROM  " + retSqlName('SB6') + " SB6  "
        cQry += " 		INNER JOIN " + retSqlName('SB1') + " SB1 ON  "
        cQry += " 								SB1.B1_FILIAL = '  '  "
        cQry += " 								AND SB1.B1_COD = SB6.B6_PRODUTO  "
        cQry += " 								AND SB1.B1_COD NOT LIKE 'MOD%'  "
        cQry += " 								AND SB1.B1_CCCUSTO = ' '  "
        cQry += " 								AND SB1.D_E_L_E_T_ = ' '  "
        cQry += " 		LEFT JOIN " + retSqlName('SB6') + " SB6REM ON  "
        cQry += " 								SB6REM.B6_FILIAL = SB6.B6_FILIAL  "
        cQry += " 								AND SB6REM.B6_IDENT = SB6.B6_IDENT  "
        cQry += " 								AND SB6REM.B6_TIPO = 'E'  "
        cQry += " 								AND SB6REM.B6_PRODUTO = SB6.B6_PRODUTO  "
        cQry += " 								AND SB6REM.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
        cQry += " 								AND SB6REM.D_E_L_E_T_ = ' '  "
        cQry += " 		INNER JOIN " + retSqlName('SF4') + " SF4REM ON  "
        cQry += " 								SF4REM.F4_FILIAL = '  '  "
        cQry += " 								AND SF4REM.F4_CODIGO = SB6REM.B6_TES  "
        cQry += " 								AND SF4REM.F4_PODER3 = 'R'  "
        cQry += " 								AND ((SF4REM.F4_ESTOQUE = 'S') OR (SF4REM.F4_ESTOQUE = 'N' AND SF4REM.F4_CONTERC <> '2'))  "
        cQry += " 								AND SF4REM.D_E_L_E_T_ = ' '  "
        cQry += " 		INNER JOIN " + retSqlName('SF4') + " SF4 ON  "
        cQry += " 								SF4.F4_FILIAL = '  '  "
        cQry += " 								AND SF4.F4_CODIGO = SB6.B6_TES  "
        cQry += " 								AND SF4.F4_PODER3 = 'D'  "
        cQry += " 								AND ((SF4.F4_ESTOQUE = 'S') OR (SF4.F4_ESTOQUE = 'N' AND SF4.F4_CONTERC <> '2'))  "
        cQry += " 								AND SF4.D_E_L_E_T_ = ' '   "
        cQry += " 		WHERE  SB6.B6_FILIAL = '" + xFilial("SB6") + "'  "
        cQry += " 		AND SB6.B6_TIPO = 'E'  "
        cQry += " 		AND SB6.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
        cQry += " 		AND SB6.D_E_L_E_T_ = ' '  "
        cQry += " 		AND SB1.B1_TIPO IN ('ME','MP','ME','PI','PA','SC','PI','OI')  "
        cQry += " )  SALDOTERCEIRO  "
        cQry += " WHERE F4_ESTOQUE = 'S' "
        cQry += " GROUP BY B6_IDENT "
        cQry += " ) AS TEMP "
        cQry += " WHERE TEMP.SALDO <> 0 "
        cQry += "  "
        cQry += " UNION ALL "
        cQry += "  "
        cQry += " SELECT TEMP.B6_IDENT AS [IDENT] "
        cQry += " FROM ( "
        cQry += " SELECT  "
        cQry += " B6_IDENT, "
        cQry += " CASE  "
        cQry += " 	WHEN SUM(REQUISICAO)<=0 AND SUM(RETORNO)*-1>SUM(REQUISICAO)*-1  "
        cQry += " 		THEN ROUND(SUM(REMESSA)+ SUM(RETORNO),4) "
        cQry += " 	ELSE ROUND(SUM(REMESSA)+ SUM(REQUISICAO), 4) "
        cQry += " END SALDO  "
        cQry += " FROM ( "
        cQry += " 		SELECT  "
        cQry += " 		B6_IDENT, "
        cQry += " 		F4_ESTOQUE , "
        cQry += " 		B6_QUANT REMESSA, "
        cQry += " 		0 RETORNO, "
        cQry += " 		0 REQUISICAO  "
        cQry += " 		FROM " + retSqlName('SB6') + " SB6  "
        cQry += " 		INNER JOIN " + retSqlName('SB1') + " SB1 ON  "
        cQry += " 								SB1.B1_FILIAL = '  '  "
        cQry += " 								AND SB1.B1_COD = SB6.B6_PRODUTO  "
        cQry += " 								AND SB1.B1_COD NOT LIKE 'MOD%'  "
        cQry += " 								AND SB1.B1_CCCUSTO = ' '  "
        cQry += " 								AND SB1.D_E_L_E_T_ = ' '  "
        cQry += " 		INNER JOIN " + retSqlName('SF4') + " SF4 ON  "
        cQry += " 								SF4.F4_FILIAL = '  '  "
        cQry += " 								AND SF4.F4_CODIGO = SB6.B6_TES  "
        cQry += " 								AND SF4.F4_PODER3 = 'R'  "
        cQry += " 								AND ((SF4.F4_ESTOQUE = 'S') OR (SF4.F4_ESTOQUE = 'N' AND SF4.F4_CONTERC <> '2'))  "
        cQry += " 								AND SF4.D_E_L_E_T_ = ' '  "
        cQry += " 		WHERE  SB6.B6_FILIAL = '" + xFilial("SB6") + "'  "
        cQry += " 		AND SB6.B6_TIPO = 'D'  "
        cQry += " 		AND SB6.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
        cQry += " 		AND SB6.D_E_L_E_T_ = ' '  "
        cQry += " 		AND SB1.B1_TIPO IN ('ME','MP','ME','PI','PA','SC','PI','OI')  "
        cQry += "  "
        cQry += " 		UNION ALL   "
        cQry += "  "
        cQry += " 		SELECT   "
        cQry += " 		SB6.B6_IDENT, "
        cQry += " 		SF4REM.F4_ESTOQUE, "
        cQry += " 		0 , "
        cQry += " 		SB6.B6_QUANT * - 1 B6_QUANT , "
        cQry += " 		0   "
        cQry += " 		FROM  " + retSqlName('SB6') + " SB6  "
        cQry += " 		INNER JOIN " + retSqlName('SB1') + " SB1 ON  "
        cQry += " 								SB1.B1_FILIAL = '  '  "
        cQry += " 								AND SB1.B1_COD = SB6.B6_PRODUTO  "
        cQry += " 								AND SB1.B1_COD NOT LIKE 'MOD%'  "
        cQry += " 								AND SB1.B1_CCCUSTO = ' '  "
        cQry += " 								AND SB1.D_E_L_E_T_ = ' '  "
        cQry += " 		LEFT JOIN " + retSqlName('SB6') + " SB6REM ON  "
        cQry += " 								SB6REM.B6_FILIAL = SB6.B6_FILIAL  "
        cQry += " 								AND SB6REM.B6_IDENT = SB6.B6_IDENT  "
        cQry += " 								AND SB6REM.B6_TIPO = 'D'  "
        cQry += " 								AND SB6REM.B6_PRODUTO = SB6.B6_PRODUTO  "
        cQry += " 								AND SB6REM.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
        cQry += " 								AND SB6REM.D_E_L_E_T_ = ' '  "
        cQry += " 		INNER JOIN " + retSqlName('SF4') + " SF4REM ON  "
        cQry += " 								SF4REM.F4_FILIAL = '  '  "
        cQry += " 								AND SF4REM.F4_CODIGO = SB6REM.B6_TES  "
        cQry += " 								AND SF4REM.F4_PODER3 = 'R'  "
        cQry += " 								AND ((SF4REM.F4_ESTOQUE = 'S') OR (SF4REM.F4_ESTOQUE = 'N' AND SF4REM.F4_CONTERC <> '2'))  "
        cQry += " 								AND SF4REM.D_E_L_E_T_ = ' '  "
        cQry += " 		INNER JOIN " + retSqlName('SF4') + " SF4 ON  "
        cQry += " 								SF4.F4_FILIAL = '  '  "
        cQry += " 								AND SF4.F4_CODIGO = SB6.B6_TES  "
        cQry += " 								AND SF4.F4_PODER3 = 'D'  "
        cQry += " 								AND ((SF4.F4_ESTOQUE = 'S') OR (SF4.F4_ESTOQUE = 'N' AND SF4.F4_CONTERC <> '2'))  "
        cQry += " 								AND SF4.D_E_L_E_T_ = ' '   "
        cQry += " 		WHERE  SB6.B6_FILIAL = '" + xFilial("SB6") + "'  "
        cQry += " 		AND SB6.B6_TIPO = 'D'  "
        cQry += " 		AND SB6.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
        cQry += " 		AND SB6.D_E_L_E_T_ = ' '  "
        cQry += " 		AND SB1.B1_TIPO IN ('ME','MP','ME','PI','PA','SC','PI','OI')  "
        cQry += "  "
        cQry += " )  SALDOTERCEIRO  "
        cQry += " WHERE F4_ESTOQUE = 'S' "
        cQry += " GROUP BY B6_IDENT "
        cQry += " ) AS TEMP "
        cQry += " WHERE TEMP.SALDO <> 0 "
        cQry += " ) "
        cQry += " AND SB6.B6_TIPO = 'E'  "
        cQry += " AND SB6.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
    else
        cQry += " AND SB6.B6_TIPO = 'T'  "
    endif
    cQry += " AND SB6.D_E_L_E_T_ = '' "
return(cQry)

static function qrySB6D(dDataP, lDo)
    local cQry  := ""
    default lDo := .T.

    if lDo
        cQry += " UPDATE SB6010 SET B6_TIPO = 'Z' "
    else
        cQry += " UPDATE SB6010 SET B6_TIPO = 'D' "
    endif
    cQry += " FROM " + retSqlName('SB6') + " SB6 "
    cQry += " WHERE SB6.B6_FILIAL = '" + xFilial("SB6") + "' "
    if lDo
        cQry += " AND SB6.B6_IDENT NOT IN ( "
        cQry += " SELECT TEMP.B6_IDENT AS [IDENT] "
        cQry += " FROM ( "
        cQry += " SELECT  "
        cQry += " B6_IDENT, "
        cQry += " CASE  "
        cQry += " 	WHEN SUM(REQUISICAO)<=0 AND SUM(RETORNO)*-1>SUM(REQUISICAO)*-1  "
        cQry += " 		THEN ROUND(SUM(REMESSA)+ SUM(RETORNO),4) "
        cQry += " 	ELSE ROUND(SUM(REMESSA)+ SUM(REQUISICAO), 4) "
        cQry += " END SALDO  "
        cQry += " FROM ( "
        cQry += " 		SELECT  "
        cQry += " 		B6_IDENT, "
        cQry += " 		F4_ESTOQUE , "
        cQry += " 		B6_QUANT REMESSA, "
        cQry += " 		0 RETORNO, "
        cQry += " 		0 REQUISICAO  "
        cQry += " 		FROM " + retSqlName('SB6') + " SB6  "
        cQry += " 		INNER JOIN " + retSqlName('SB1') + " SB1 ON  "
        cQry += " 								SB1.B1_FILIAL = '  '  "
        cQry += " 								AND SB1.B1_COD = SB6.B6_PRODUTO  "
        cQry += " 								AND SB1.B1_COD NOT LIKE 'MOD%'  "
        cQry += " 								AND SB1.B1_CCCUSTO = ' '  "
        cQry += " 								AND SB1.D_E_L_E_T_ = ' '  "
        cQry += " 		INNER JOIN " + retSqlName('SF4') + " SF4 ON  "
        cQry += " 								SF4.F4_FILIAL = '  '  "
        cQry += " 								AND SF4.F4_CODIGO = SB6.B6_TES  "
        cQry += " 								AND SF4.F4_PODER3 = 'R'  "
        cQry += " 								AND ((SF4.F4_ESTOQUE = 'S') OR (SF4.F4_ESTOQUE = 'N' AND SF4.F4_CONTERC <> '2'))  "
        cQry += " 								AND SF4.D_E_L_E_T_ = ' '  "
        cQry += " 		WHERE  SB6.B6_FILIAL = '" + xFilial("SB6") + "'  "
        cQry += " 		AND SB6.B6_TIPO = 'E'  "
        cQry += " 		AND SB6.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
        cQry += " 		AND SB6.D_E_L_E_T_ = ' '  "
        cQry += " 		AND SB1.B1_TIPO IN ('ME','MP','ME','PI','PA','SC','PI','OI')  "
        cQry += "  "
        cQry += " 		UNION ALL   "
        cQry += "  "
        cQry += " 		SELECT   "
        cQry += " 		SB6.B6_IDENT , "
        cQry += " 		SF4REM.F4_ESTOQUE, "
        cQry += " 		0 , "
        cQry += " 		SB6.B6_QUANT * - 1 B6_QUANT , "
        cQry += " 		0   "
        cQry += " 		FROM  " + retSqlName('SB6') + " SB6  "
        cQry += " 		INNER JOIN " + retSqlName('SB1') + " SB1 ON  "
        cQry += " 								SB1.B1_FILIAL = '  '  "
        cQry += " 								AND SB1.B1_COD = SB6.B6_PRODUTO  "
        cQry += " 								AND SB1.B1_COD NOT LIKE 'MOD%'  "
        cQry += " 								AND SB1.B1_CCCUSTO = ' '  "
        cQry += " 								AND SB1.D_E_L_E_T_ = ' '  "
        cQry += " 		LEFT JOIN " + retSqlName('SB6') + " SB6REM ON  "
        cQry += " 								SB6REM.B6_FILIAL = SB6.B6_FILIAL  "
        cQry += " 								AND SB6REM.B6_IDENT = SB6.B6_IDENT  "
        cQry += " 								AND SB6REM.B6_TIPO = 'E'  "
        cQry += " 								AND SB6REM.B6_PRODUTO = SB6.B6_PRODUTO  "
        cQry += " 								AND SB6REM.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
        cQry += " 								AND SB6REM.D_E_L_E_T_ = ' '  "
        cQry += " 		INNER JOIN " + retSqlName('SF4') + " SF4REM ON  "
        cQry += " 								SF4REM.F4_FILIAL = '  '  "
        cQry += " 								AND SF4REM.F4_CODIGO = SB6REM.B6_TES  "
        cQry += " 								AND SF4REM.F4_PODER3 = 'R'  "
        cQry += " 								AND ((SF4REM.F4_ESTOQUE = 'S') OR (SF4REM.F4_ESTOQUE = 'N' AND SF4REM.F4_CONTERC <> '2'))  "
        cQry += " 								AND SF4REM.D_E_L_E_T_ = ' '  "
        cQry += " 		INNER JOIN " + retSqlName('SF4') + " SF4 ON  "
        cQry += " 								SF4.F4_FILIAL = '  '  "
        cQry += " 								AND SF4.F4_CODIGO = SB6.B6_TES  "
        cQry += " 								AND SF4.F4_PODER3 = 'D'  "
        cQry += " 								AND ((SF4.F4_ESTOQUE = 'S') OR (SF4.F4_ESTOQUE = 'N' AND SF4.F4_CONTERC <> '2'))  "
        cQry += " 								AND SF4.D_E_L_E_T_ = ' '   "
        cQry += " 		WHERE  SB6.B6_FILIAL = '" + xFilial("SB6") + "'  "
        cQry += " 		AND SB6.B6_TIPO = 'E'  "
        cQry += " 		AND SB6.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
        cQry += " 		AND SB6.D_E_L_E_T_ = ' '  "
        cQry += " 		AND SB1.B1_TIPO IN ('ME','MP','ME','PI','PA','SC','PI','OI')  "
        cQry += " )  SALDOTERCEIRO  "
        cQry += " WHERE F4_ESTOQUE = 'S' "
        cQry += " GROUP BY B6_IDENT "
        cQry += " ) AS TEMP "
        cQry += " WHERE TEMP.SALDO <> 0 "
        cQry += "  "
        cQry += " UNION ALL "
        cQry += "  "
        cQry += " SELECT TEMP.B6_IDENT AS [IDENT] "
        cQry += " FROM ( "
        cQry += " SELECT  "
        cQry += " B6_IDENT, "
        cQry += " CASE  "
        cQry += " 	WHEN SUM(REQUISICAO)<=0 AND SUM(RETORNO)*-1>SUM(REQUISICAO)*-1  "
        cQry += " 		THEN ROUND(SUM(REMESSA)+ SUM(RETORNO),4) "
        cQry += " 	ELSE ROUND(SUM(REMESSA)+ SUM(REQUISICAO), 4) "
        cQry += " END SALDO  "
        cQry += " FROM ( "
        cQry += " 		SELECT  "
        cQry += " 		B6_IDENT, "
        cQry += " 		F4_ESTOQUE , "
        cQry += " 		B6_QUANT REMESSA, "
        cQry += " 		0 RETORNO, "
        cQry += " 		0 REQUISICAO  "
        cQry += " 		FROM " + retSqlName('SB6') + " SB6  "
        cQry += " 		INNER JOIN " + retSqlName('SB1') + " SB1 ON  "
        cQry += " 								SB1.B1_FILIAL = '  '  "
        cQry += " 								AND SB1.B1_COD = SB6.B6_PRODUTO  "
        cQry += " 								AND SB1.B1_COD NOT LIKE 'MOD%'  "
        cQry += " 								AND SB1.B1_CCCUSTO = ' '  "
        cQry += " 								AND SB1.D_E_L_E_T_ = ' '  "
        cQry += " 		INNER JOIN " + retSqlName('SF4') + " SF4 ON  "
        cQry += " 								SF4.F4_FILIAL = '  '  "
        cQry += " 								AND SF4.F4_CODIGO = SB6.B6_TES  "
        cQry += " 								AND SF4.F4_PODER3 = 'R'  "
        cQry += " 								AND ((SF4.F4_ESTOQUE = 'S') OR (SF4.F4_ESTOQUE = 'N' AND SF4.F4_CONTERC <> '2'))  "
        cQry += " 								AND SF4.D_E_L_E_T_ = ' '  "
        cQry += " 		WHERE  SB6.B6_FILIAL = '" + xFilial("SB6") + "'  "
        cQry += " 		AND SB6.B6_TIPO = 'D'  "
        cQry += " 		AND SB6.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
        cQry += " 		AND SB6.D_E_L_E_T_ = ' '  "
        cQry += " 		AND SB1.B1_TIPO IN ('ME','MP','ME','PI','PA','SC','PI','OI')  "
        cQry += "  "
        cQry += " 		UNION ALL   "
        cQry += "  "
        cQry += " 		SELECT   "
        cQry += " 		SB6.B6_IDENT, "
        cQry += " 		SF4REM.F4_ESTOQUE, "
        cQry += " 		0 , "
        cQry += " 		SB6.B6_QUANT * - 1 B6_QUANT , "
        cQry += " 		0   "
        cQry += " 		FROM  " + retSqlName('SB6') + " SB6  "
        cQry += " 		INNER JOIN " + retSqlName('SB1') + " SB1 ON  "
        cQry += " 								SB1.B1_FILIAL = '  '  "
        cQry += " 								AND SB1.B1_COD = SB6.B6_PRODUTO  "
        cQry += " 								AND SB1.B1_COD NOT LIKE 'MOD%'  "
        cQry += " 								AND SB1.B1_CCCUSTO = ' '  "
        cQry += " 								AND SB1.D_E_L_E_T_ = ' '  "
        cQry += " 		LEFT JOIN " + retSqlName('SB6') + " SB6REM ON  "
        cQry += " 								SB6REM.B6_FILIAL = SB6.B6_FILIAL  "
        cQry += " 								AND SB6REM.B6_IDENT = SB6.B6_IDENT  "
        cQry += " 								AND SB6REM.B6_TIPO = 'D'  "
        cQry += " 								AND SB6REM.B6_PRODUTO = SB6.B6_PRODUTO  "
        cQry += " 								AND SB6REM.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
        cQry += " 								AND SB6REM.D_E_L_E_T_ = ' '  "
        cQry += " 		INNER JOIN " + retSqlName('SF4') + " SF4REM ON  "
        cQry += " 								SF4REM.F4_FILIAL = '  '  "
        cQry += " 								AND SF4REM.F4_CODIGO = SB6REM.B6_TES  "
        cQry += " 								AND SF4REM.F4_PODER3 = 'R'  "
        cQry += " 								AND ((SF4REM.F4_ESTOQUE = 'S') OR (SF4REM.F4_ESTOQUE = 'N' AND SF4REM.F4_CONTERC <> '2'))  "
        cQry += " 								AND SF4REM.D_E_L_E_T_ = ' '  "
        cQry += " 		INNER JOIN " + retSqlName('SF4') + " SF4 ON  "
        cQry += " 								SF4.F4_FILIAL = '  '  "
        cQry += " 								AND SF4.F4_CODIGO = SB6.B6_TES  "
        cQry += " 								AND SF4.F4_PODER3 = 'D'  "
        cQry += " 								AND ((SF4.F4_ESTOQUE = 'S') OR (SF4.F4_ESTOQUE = 'N' AND SF4.F4_CONTERC <> '2'))  "
        cQry += " 								AND SF4.D_E_L_E_T_ = ' '   "
        cQry += " 		WHERE  SB6.B6_FILIAL = '" + xFilial("SB6") + "'  "
        cQry += " 		AND SB6.B6_TIPO = 'D'  "
        cQry += " 		AND SB6.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
        cQry += " 		AND SB6.D_E_L_E_T_ = ' '  "
        cQry += " 		AND SB1.B1_TIPO IN ('ME','MP','ME','PI','PA','SC','PI','OI')  "
        cQry += "  "
        cQry += " )  SALDOTERCEIRO  "
        cQry += " WHERE F4_ESTOQUE = 'S' "
        cQry += " GROUP BY B6_IDENT "
        cQry += " ) AS TEMP "
        cQry += " WHERE TEMP.SALDO <> 0 "
        cQry += " ) "
        cQry += " AND SB6.B6_TIPO = 'D'  "
        cQry += " AND SB6.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
    else
        cQry += " AND SB6.B6_TIPO = 'Z'  "
    endif
    cQry += " AND SB6.D_E_L_E_T_ = '' "
return(cQry)

static function qryMudaReq(dDataP)
    local cQry := ""
    
    cQry += " UPDATE SB6010 SET B6_TIPO = 'Z'   "
    cQry += " FROM SB6010 SSB6 "
    cQry += " WHERE SSB6.R_E_C_N_O_ IN ( "
    cQry += " SELECT SB6.R_E_C_N_O_ "
    cQry += " FROM " + retSqlName('SB6') + " SB6  "
    cQry += " INNER JOIN " + retSqlName('SB1') + " SB1 ON  "
    cQry += " 						SB1.B1_FILIAL = '  '  "
    cQry += " 						AND SB1.B1_COD = SB6.B6_PRODUTO  "
    cQry += " 						AND SB1.B1_COD NOT LIKE 'MOD%'  "
    cQry += " 						AND SB1.B1_CCCUSTO = ' '  "
    cQry += " 						AND SB1.D_E_L_E_T_ = ' '  "
    cQry += " LEFT JOIN " + retSqlName('SB6') + " SB6REM ON  "
    cQry += " 						SB6REM.B6_FILIAL = SB6.B6_FILIAL  "
    cQry += " 						AND SB6REM.B6_IDENT = SB6.B6_IDENT  "
    cQry += " 						AND SB6REM.B6_TIPO = 'D'  "
    cQry += " 						AND SB6REM.B6_PRODUTO = SB6.B6_PRODUTO  "
    cQry += " 						AND SB6REM.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
    cQry += " 						AND SB6REM.D_E_L_E_T_ = ' '  "
    cQry += " INNER JOIN " + retSqlName('SF4') + " SF4REM ON  "
    cQry += " 						SF4REM.F4_FILIAL = '  '  "
    cQry += " 						AND SF4REM.F4_CODIGO = SB6REM.B6_TES  "
    cQry += " 						AND SF4REM.F4_PODER3 = 'R'  "
    cQry += " 						AND SF4REM.D_E_L_E_T_ = ' '  "
    cQry += " INNER JOIN " + retSqlName('SF4') + " SF4 ON  "
    cQry += " 						SF4.F4_FILIAL = '  '  "
    cQry += " 						AND SF4.F4_CODIGO = SB6.B6_TES  "
    cQry += " 						AND SF4.F4_PODER3 = 'D'  "
    cQry += " 						AND SF4.D_E_L_E_T_ = ' '  "
    cQry += " WHERE  SB6.B6_FILIAL = '" + xFilial('SB6') + "'  "
    cQry += " AND SB6.B6_TIPO = 'D'  "
    cQry += " AND SF4REM.F4_ESTOQUE = 'S' "
    cQry += " AND SB6.B6_DTDIGIT <= '" + DTOS(dDataP) + "'  "
    cQry += " AND SB6.D_E_L_E_T_ = ' '  "
    cQry += " AND SB1.B1_TIPO IN ('MP','PI'))  "
return(cQry)

user function tstcbcSPEDK()
    Local oStatic    := IfcXFun():newIfcXFun()
    local cQry := ""
    private dDataDe     := STOD("20220101")
    private dDataAte    := STOD("20220131")
    private cAlmTerc    := oStatic:sP(1):callStatic('MATXSPED', 'GetAlmTerc')
    private lCpoBZTP    := .F.
    Private cTipo00		:= If(SuperGetMv("MV_BLKTP00",.F.,"'ME'")== " ","'ME'", SuperGetMv("MV_BLKTP00",.F.,"'ME'")) // 00: Mercadoria Revenda
    Private cTipo01		:= If(SuperGetMv("MV_BLKTP01",.F.,"'MP'")== " ","'MP'", SuperGetMv("MV_BLKTP01",.F.,"'MP'")) // 01: Materia-Prima
    Private cTipo02		:= If(SuperGetMv("MV_BLKTP02",.F.,"'EM'")== " ","'EM'", SuperGetMv("MV_BLKTP02",.F.,"'EM'")) // 02: Embalagem
    Private cTipo03		:= If(SuperGetMv("MV_BLKTP03",.F.,"'PP'")== " ","'PP'", SuperGetMv("MV_BLKTP03",.F.,"'PP'")) // 03: Produto em Processo
    Private cTipo04		:= If(SuperGetMv("MV_BLKTP04",.F.,"'PA'")== " ","'PA'", SuperGetMv("MV_BLKTP04",.F.,"'PA'")) // 04: Produto Acabado
    Private cTipo05		:= If(SuperGetMv("MV_BLKTP05",.F.,"'SP'")== " ","'SP'", SuperGetMv("MV_BLKTP05",.F.,"'SP'")) // 05: SubProduto
    Private cTipo06		:= If(SuperGetMv("MV_BLKTP06",.F.,"'PI'")== " ","'PI'", SuperGetMv("MV_BLKTP06",.F.,"'PI'")) // 06: Produto Intermediario
    Private cTipo10		:= If(SuperGetMv("MV_BLKTP10",.F.,"'OI'")== " ","'OI'", SuperGetMv("MV_BLKTP10",.F.,"'OI'")) // 10: Outros Insumos
    Private lEstMov		:= .F.
    Private lNegEst		:= SuperGetMv("MV_NEGESTR",.F.,.F.)
    Private nRegsto		:= 0	// Quantidade de Registros Gerados
    Private cVersSped	:= oStatic:sP(1):callStatic('MATXSPED', 'VerBlocoK', dDataDe)

    cQry := oStatic:sP(1):callStatic('MATXSPED', 'QryTerc', "D", STOD("20220131"),"2010000000","2010000000")
return(cQry)
