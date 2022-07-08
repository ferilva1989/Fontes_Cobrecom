#include "Totvs.ch"

class cbcCredErp
    data lOk
    data cMsgErr
    data lShowErr
    data cCgc

	method newccbcCredErp() constructor
    method setStatus()
    method getErrMsg()
    method showErr()
    method isOk()
    method HandleEr()
    method getValPed()
    method getTitVencer()
    method getTitBaixado()
    method getPedEmProd()
    method getMaiorSaldo()
    method getDadosJson()
    method vldCGC()

endClass

method newccbcCredErp(cCGC, lShowErr) class cbcCredErp
    default cCgc := ''
    default lShowErr  := .T.

    ::lShowErr := lShowErr
    ::cCgc := cCGC
    ::setStatus()
return(self)

method setStatus(lOk, cMsgErr, lEx, lShow) class cbcCredErp
    default lOk     := .T.
    default cMsgErr := ''
    default lEx     := .F.
    default lShow   := ::showErr()

    ::lOk := lOk

    if !(lOk)
        ::cMsgErr := '[cbcCredErp] - ' + cMsgErr
        if lEx
            UserException(::getErrMsg())
        else
            if (lShow)
                MsgAlert(::getErrMsg(),'Erro - cbcCredErp')
            endif
        endif
    endif
return(self)

method getErrMsg() class cbcCredErp
return(::cMsgErr)

method showErr() class cbcCredErp
return(::lShowErr)

method isOk() class cbcCredErp
return(::lOk)

method HandleEr(oErr) class cbcCredErp
    if InTransact()
        DisarmTransaction()
    endif
    ::setStatus(.F., oErr:Description)
    BREAK
return(self)

method getValPed() class cbcCredErp
    Local oSql     := LibSqlObj():newLibSqlObj()
    Local cQry     := getQry('ValPed', ::cCgc)
    Local aTmpData := {}

    oSql:newAlias(cQry)
    if oSql:hasRecords()
        oSql:goTop()
	    while oSql:notIsEof()
            aadd(aTmpData, {{ 'FILIAL', oSql:getValue('FILIAL') }, { 'PEDIDO', oSql:getValue('PEDIDO') }, { 'VALOR_PED', oSql:getValue('VALOR_PED') }} )
            oSql:skip()
		enddo
    endif
    oSql:Close()
    FreeObj(oSql)
return(aTmpData)

method getTitVencer() class cbcCredErp
    Local oSql     := LibSqlObj():newLibSqlObj()
    Local cQry     := getQry('TitVencer', ::cCgc)
    Local aTmpData := {}

    oSql:newAlias(cQry)
    if oSql:hasRecords()
        aadd(aTmpData, {{ 'TOTAL_ABERTO', oSql:getValue('TOTAL_ABERTO') }, { 'VENCIDO', oSql:getValue('VENCIDO') }})
    endif
    oSql:Close()
    FreeObj(oSql)
return(aTmpData)

method getTitBaixado() class cbcCredErp
    Local oSql     := LibSqlObj():newLibSqlObj()
    Local cQry     := getQry('TitBaixado', ::cCgc)
    Local aTmpData := {}
    
    oSql:newAlias(cQry)
    if oSql:hasRecords()
        aadd(aTmpData, {'MEDIA_ATRASO', oSql:getValue('MEDIA_ATRASO')})
    endif
    oSql:Close()
    FreeObj(oSql)
return(aTmpData)

method getPedEmProd() class cbcCredErp
    Local oSql     := LibSqlObj():newLibSqlObj()
    Local cQry     := getQry('PedEmProd', ::cCgc)
    Local aTmpData := {}
    
    oSql:newAlias(cQry)
    if oSql:hasRecords()
        aadd(aTmpData, { 'SALDO_EM_PROD', oSql:getValue('SALDO_EM_PROD') })
    endif
    oSql:Close()
    FreeObj(oSql)
return(aTmpData)

method getMaiorSaldo() class cbcCredErp
    Local oSql     := LibSqlObj():newLibSqlObj()
    Local cQry     := getQry('MaiorSaldo', ::cCgc)
    Local aTmpData := {}
    
    oSql:newAlias(cQry)
    if oSql:hasRecords()
        aadd(aTmpData, { 'MAIOR_SALDO', oSql:getValue('MAIOR_SALDO') })
    endif
    oSql:Close()
    FreeObj(oSql)
return(aTmpData)

method getDadosJson(cCgc) class cbcCredErp
    Local oJson := JsonObject():new()
    Local oArr  := JsonObject():new()
    Local bErro := ErrorBlock({|oErr| ::HandleEr(oErr)})
    Local aArr  := {}
    Local nX    := 0
    
    Begin Sequence
        if !Empty(cCgc)
            ::cCgc := cCgc
        endIf

        oJson['CGC'] := ::cCgc
        aArr := ::getValPed()
        oJson['VALOR_PEDIDOS'] := {}
        for nX := 1 to Len(aArr)
            oArr := Nil
            oArr := JsonObject():new()
            oArr[aArr[nX][1][1]] := aArr[nX][1][2]
            oArr[aArr[nX][2][1]] := aArr[nX][2][2]
            oArr[aArr[nX][3][1]] := aArr[nX][3][2]
            aadd(oJson['VALOR_PEDIDOS'], oArr)
        next

        aArr := ::getTitVencer()
        oJson['TIT_EM_ABERTO'] := JsonObject():new()
        if !Empty(aArr)
            oJson['TIT_EM_ABERTO'][aArr[1][1][1]] := aArr[1][1][2]
            oJson['TIT_EM_ABERTO'][aArr[1][2][1]] := aArr[1][2][2]
        endif

        aArr := ::getTitBaixado()
        if !Empty(aArr)
          oJson[aArr[1][1]] := aArr[1][2] 
        endif

        aArr := ::getPedEmProd()
        if !Empty(aArr)
          oJson[aArr[1][1]] := aArr[1][2]  
        endif
        
        aArr := ::getMaiorSaldo()
        if !Empty(aArr)
          oJson[aArr[1][1]] := aArr[1][2]
        endif
    RECOVER
    End Sequence
    ErrorBlock(bErro)
return(oJson)

method vldCGC(cCgc) class cbcCredErp
    Local oSql     := LibSqlObj():newLibSqlObj()
    Local cQry     := ''
    Local lRet := .F.

    if !Empty(cCgc)
        ::cCgc := cCgc
    endIf

    cQry := getQry('MaiorSaldo', ::cCgc)
    oSql:newAlias(cQry)
    lRet := oSql:hasRecords()
    oSql:Close()
    FreeObj(oSql)
return(lRet)


Static Function getQry(cTp, cCGC)
    Local cQry := ''

    if cTp == 'ValPed' // Obter o valor total do pedido liberado para analise de credito
        cQry := "SELECT "
        cQry += "    SC9.C9_FILIAL [FILIAL], "
        cQry += "    SC9.C9_PEDIDO [PEDIDO], "
        cQry += "    ISNULL(SUM(SC6.C6_PRCVEN * SC9.C9_QTDLIB),0) [VALOR_PED] "
        cQry += "FROM "
        cQry += "    SC9010 SC9 WITH(NOLOCK) "
        cQry += "INNER JOIN "
        cQry += "    SC6010 SC6 WITH(NOLOCK) "
        cQry += "ON "
        cQry += "        SC9.C9_FILIAL  = SC6.C6_FILIAL "
        cQry += "    AND SC9.C9_PEDIDO  = SC6.C6_NUM "
        cQry += "    AND SC9.C9_ITEM    = SC6.C6_ITEM "
        cQry += "    AND SC9.D_E_L_E_T_ = SC6.D_E_L_E_T_ "
        cQry += "INNER JOIN SA1010 SA1 WITH(NOLOCK) "
        cQry += "    ON SC9.C9_CLIENTE  = SA1.A1_COD "
        cQry += "    AND SC9.C9_LOJA    = SA1.A1_LOJA "
        cQry += "    AND SC9.D_E_L_E_T_ = SA1.D_E_L_E_T_ "
        cQry += "WHERE "
        cQry += "        SC9.C9_BLCRED NOT IN ('' , '10', 'ZZ') "
        cQry += "    AND SC9.C9_BLEST NOT IN  ('10', 'ZZ') "
        cQry += "    AND SC9.D_E_L_E_T_ = '' "
        cQry += "    AND SA1.A1_CGC = '" + cCGC + "' "
        cQry += "GROUP BY SC9.C9_FILIAL, SC9.C9_PEDIDO "
        cQry += "ORDER BY SC9.C9_FILIAL, SC9.C9_PEDIDO "
    elseif cTp == 'TitVencer' // Verifica Titulos em Aberto e valor total a vencer
        cQry := "SELECT "
        cQry += "    (ISNULL(SUM(SE1.E1_SALDO), 0) - ISNULL(( SELECT "
        cQry += "            SUM(SE1.E1_SALDO) [TOTAL_ABERTO] "
        cQry += "        FROM "
        cQry += "            SE1010 SE1 WITH(NOLOCK) "
        cQry += "        INNER JOIN "
        cQry += "            SA1010 SA1 WITH(NOLOCK) "
        cQry += "        ON "
        cQry += "                SE1.E1_CLIENTE = SA1.A1_COD "
        cQry += "            AND SE1.E1_LOJA    = SA1.A1_LOJA "
        cQry += "            AND SE1.D_E_L_E_T_ = SA1.D_E_L_E_T_ "
        cQry += "        WHERE "
        cQry += "                SE1.E1_TIPO IN ('NCC', 'RA') "
        cQry += "            AND SE1.E1_SALDO > 0 "
        cQry += "            AND SE1.D_E_L_E_T_ = '' "
        cQry += "            AND SA1.A1_CGC = '" + cCGC + "' "
        cQry += "        GROUP BY SA1.A1_CGC ), 0)) [TOTAL_ABERTO], "
        cQry += "        ISNULL(( SELECT "
        cQry += "            SUM(SE1.E1_SALDO) [TOTAL_ABERTO] "
        cQry += "        FROM "
        cQry += "            SE1010 SE1 WITH(NOLOCK) "
        cQry += "        INNER JOIN "
        cQry += "            SA1010 SA1 WITH(NOLOCK) "
        cQry += "        ON "
        cQry += "                SE1.E1_CLIENTE = SA1.A1_COD "
        cQry += "            AND SE1.E1_LOJA    = SA1.A1_LOJA "
        cQry += "            AND SE1.D_E_L_E_T_ = SA1.D_E_L_E_T_ "
        cQry += "        WHERE "
        cQry += "                SE1.E1_TIPO IN ('NF') "
        cQry += "            AND SE1.E1_SALDO > 0 "
        cQry += "            AND SE1.E1_VENCREA < CONVERT(date, (GETDATE()-5)) "
        cQry += "            AND SE1.D_E_L_E_T_ = '' "
        cQry += "            AND SA1.A1_CGC = '" + cCGC + "' "
        cQry += "        GROUP BY SA1.A1_CGC), 0) [VENCIDO] "
        cQry += "FROM "
        cQry += "    SE1010 SE1 WITH(NOLOCK) "
        cQry += "INNER JOIN "
        cQry += "    SA1010 SA1 WITH(NOLOCK) "
        cQry += "ON "
        cQry += "        SE1.E1_CLIENTE = SA1.A1_COD "
        cQry += "    AND SE1.E1_LOJA    = SA1.A1_LOJA "
        cQry += "    AND SE1.D_E_L_E_T_ = SA1.D_E_L_E_T_ "
        cQry += "WHERE "
        cQry += "        SE1.E1_TIPO IN ('NF') "
        cQry += "    AND SE1.E1_SALDO > 0 "
        cQry += "    AND SE1.D_E_L_E_T_ = '' "
        cQry += "    AND SA1.A1_CGC = '" + cCGC + "' "
        cQry += "GROUP BY SA1.A1_CGC "
    elseif cTp == 'TitBaixado' // Verifica Titulos Baixados e se foram baixados em atraso
        cQry := "SELECT "
        cQry += "    SUM(DATEDIFF(day, CONVERT(date, SE1.E1_VENCREA), CONVERT(date, SE1.E1_BAIXA)) * SE1.E1_VALOR) / SUM(SE1.E1_VALOR) MEDIA_ATRASO "
        cQry += "FROM "
        cQry += "    SE1010 SE1 WITH(NOLOCK) "
        cQry += "INNER JOIN "
        cQry += "    SA1010 SA1 WITH(NOLOCK) "
        cQry += "ON "
        cQry += "        SE1.E1_CLIENTE = SA1.A1_COD "
        cQry += "    AND SE1.E1_LOJA    = SA1.A1_LOJA "
        cQry += "    AND SE1.D_E_L_E_T_ = SA1.D_E_L_E_T_ "
        cQry += "WHERE  "
        cQry += "        SE1.E1_TIPO IN ('NF') "
        cQry += "    AND SE1.E1_BAIXA <> '' "
        cQry += "    AND SE1.D_E_L_E_T_ = '' "
        cQry += "    AND (DATEDIFF(month, CONVERT(date, SE1.E1_VENCREA), CONVERT(date, GETDATE()))) <= 6 "
        cQry += "    AND (DATEDIFF(day, CONVERT(date, SE1.E1_VENCREA), CONVERT(date, SE1.E1_BAIXA))) > 0 "
        cQry += "    AND SA1.A1_CGC = '" + cCGC + "' "
        cQry += "GROUP BY SA1.A1_CGC "
        cQry += "HAVING "
        cQry += "   COUNT(*) > 1 "
    elseif cTp == 'PedEmProd' // Verificar se tem pedidos em produção
        cQry := "SELECT "
        cQry += "    ISNULL(SUM(SC9.C9_QTDLIB * C6_PRCVEN), 0) [SALDO_EM_PROD] "
        cQry += "FROM "
        cQry += "    SC9010 SC9 WITH(NOLOCK) "
        cQry += "INNER JOIN "
        cQry += "    SC6010 SC6 WITH(NOLOCK) "
        cQry += "ON "
        cQry += "    SC9.C9_FILIAL      = SC6.C6_FILIAL "
        cQry += "    AND SC9.C9_PEDIDO  = SC6.C6_NUM "
        cQry += "    AND SC9.C9_ITEM    = SC6.C6_ITEM "
        cQry += "    AND SC9.D_E_L_E_T_ = SC6.D_E_L_E_T_ "
        cQry += "INNER JOIN "
        cQry += "    SA1010 SA1 WITH(NOLOCK) "
        cQry += "ON "
        cQry += "    SC9.C9_CLIENTE     = SA1.A1_COD "
        cQry += "    AND SC9.C9_LOJA    = SA1.A1_LOJA "
        cQry += "    AND SC9.D_E_L_E_T_ = SA1.D_E_L_E_T_ "
        cQry += "WHERE "
        cQry += "    SC9.C9_BLCRED = '' "
        cQry += "    AND SC9.C9_BLEST IN ('', '02') "
        cQry += "    AND SC9.D_E_L_E_T_ = '' "
        cQry += "    AND SC6.C6_BLQ = '' "
        cQry += "    AND SA1.A1_CGC = '" + cCGC + "' "
        cQry += "GROUP BY SA1.A1_CGC "
    elseif cTp == 'MaiorSaldo'
        cQry := "SELECT "
        cQry += "    ISNULL(A1_MSALDO, 0) [MAIOR_SALDO] "
        cQry += "FROM "
        cQry += "    SA1010 WITH(NOLOCK) "
        cQry += "WHERE "
        cQry += "        A1_CGC = '" + cCGC + "' "
        cQry += "    AND A1_MSBLQL <> '1' "
        cQry += "    AND D_E_L_E_T_ = '' "
    endif
Return cQry

User Function zzTst(cCNPJ)
    Local oCbcCredErp := cbcCredErp():newccbcCredErp(cCNPJ)
    Local oJson       := JsonObject():new()
    
    if oCbcCredErp:vldCGC(cCNPJ)
        oJson := oCbcCredErp:getDadosJson(cCNPJ)
        MsgAlert(oJson:ToJson(), 'Teste')
    endif
Return Nil
