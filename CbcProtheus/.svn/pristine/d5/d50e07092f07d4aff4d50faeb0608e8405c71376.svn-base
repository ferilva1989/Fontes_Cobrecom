#include 'Totvs.ch'

user function trgNatureza(cCod, cFornece, cLoja)
    local cNatur    := ""
    local oSql      := LibSqlObj():newLibSqlObj()
    default cCod    := ""
    default cFornece:= ""
    default lAtua   := .F.
    
    if !empty(cCod) .and. !empty(cFornece) .and. !empty(cLoja)
        oSql:newAlias(qrytrgNat(AllTrim(cCod), AllTrim(cFornece), AllTrim(cLoja)))
        if oSql:hasRecords()
            oSql:goTop()
            //while oSql:notIsEof()
                cNatur := oSql:getValue('NATUREZA')
                //oSql:skip()
            //endDo
        else
            oSql:close()
            oSql:newAlias(qrytrgNat(AllTrim(cCod), AllTrim(cFornece), AllTrim(cLoja), .T.))
            if oSql:hasRecords()
                oSql:goTop()
                //while oSql:notIsEof()
                    cNatur := oSql:getValue('NATUREZA')
                    //oSql:skip()
                //endDo
            endif
        endif
        oSql:close()
    endif
    FreeObj(oSql)
return(cNatur)

user function AtuNatPc(nRecC7)
    local aArea         := getArea()
    local aAreaC7       := SC7->(getArea())
    local cNaturez      := ""

    if u_cbcUseBudget()
        DbSelectArea("SC7")
        SC7->(DbGoTo(nRecC7))
        if empty(SC7->C7_NATUREZ)
            cNaturez := u_trgNatureza(SC7->C7_PRODUTO, SC7->C7_FORNECE, SC7->C7_LOJA)
            if !empty(cNaturez)
                if RecLock("SC7",.F.)
                    SC7->C7_NATUREZ := cNaturez
                    SC7->(MsUnlock()) 
                endif
            else
                if RecLock("SC7",.F.)
                    SC7->C7_APROV := AllTrim(GetNewPar('ZZ_GRPCNAT', '000007'))
                    SC7->(MsUnlock()) 
                endif
            endif
        endif
    endif
    RestArea(aAreaC7)
    RestArea(aArea)
return(nil)

user function budgetPCMov(cPed, cMsg)
    local aArea     := getArea()
    local aAreaCR   := SCR->(getArea())
    local aAreaC7   := SC7->(getArea())
    local lRet      := .T.
    local aSaldo    := {}
    local oSql      := nil
    local oInt      := ctrlCbcBudget():newctrlCbcBudget()
    default cMsg    := ""

    if u_cbcUseBudget()
        oSql := LibSqlObj():newLibSqlObj()
        oSql:newAlias(qryNatTotal(cPed))
        if oSql:hasRecords()
            oSql:GoTop()
            while oSql:notIsEof()
                if (lRet := !(empty(oSql:getValue('NATUREZ'))))
                    aSaldo := oInt:libMov(, AllTrim(oSql:getValue('NATUREZ')), oSql:getValue('TOTAL'))
                    if !(lRet := aSaldo[1])
                        cMsg := 'Natureza: ' + AllTrim(oSql:getValue('NATUREZ')) + ' não possui saldo de budget!' + CHR(13)+CHR(10) + 'Disponível: ' + cValtochar(TRANSFORM(aSaldo[2], PesqPict('SD1', 'D1_TOTAL'))) + CHR(13)+CHR(10) + 'Requisitado: ' + cValToChar(TRANSFORM(oSql:getValue('TOTAL'), PesqPict('SD1', 'D1_TOTAL')))
                        EXIT
                    endif
                else
                    cMsg := 'Pedido com natureza do budget não classificada!'
                    EXIT
                endif
                oSql:skip()
            enddo
        endif
        oSql:close()
        Freeobj(oSql)
    endif
    FreeObj(oInt)
    RestArea(aAreaC7)
    RestArea(aAreaCR)
    RestArea(aArea)
return(lRet)

user function NFBudget()
    local lRet      := .T.
    local nX        := 0
    local nCalcItem := 0
    local nNFTotal  := MaFisRet(,"NF_TOTAL")
    local cNaturez  := ""
    local aNaturez  := {}
    local aSaldo    := {}
    local oInt      := ctrlCbcBudget():newctrlCbcBudget()

    if u_cbcUseBudget()
        if !FWIsInCallStack("U_CDEST20") .or. !FWIsInCallStack("U_vwTransFilial")
            if Type("aNatArr") == "U"
                aAdd(aNaturez, {MaFisRet(,"NF_NATUREZA"), nNFTotal, 0})
            else
                for nX := 1 to len(aNatArr)
                    nCalcItem := Round(nNFTotal * Round((aNatArr[nX,02] / 100),2),2)
                    aAdd(aNaturez, {aNatArr[nX,01], nCalcItem, 0})
                next nX
            endif
            for nX := 1 to len(aCols)
                if !empty(gdFieldGet("D1_PEDIDO",nX)) .and. !empty(gdFieldGet("D1_ITEMPC",nX)) .and. !gdDeleted(nX)
                    cNaturez  := AllTrim(srvItemNat(AllTrim(gdFieldGet("D1_PEDIDO",nX)), AllTrim(gdFieldGet("D1_ITEMPC",nX))))
                    if !empty(cNaturez)
                        nPos := aScan(aNaturez, {|x| x[1] == cNaturez})
                        if nPos > 0
                            aPCInfo := PCNatInfo(AllTrim(gdFieldGet("D1_PEDIDO",nX)), cNaturez)
                            aNaturez[nPos, 3] := aPCInfo[2]
                        endif
                    endif
                endif
            next nX
            for nX := 1 to len(aNaturez)
                if aNaturez[nX, 02] > aNaturez[nX, 03]
                    aSaldo := oInt:libMov(, AllTrim(aNaturez[nX,1]), (aNaturez[nX, 02] - aNaturez[nX, 03]))
                    if !(lRet := aSaldo[1])
                        cMsg := 'Natureza: ' + AllTrim(aNaturez[nX,1]) + ' não possui saldo de budget!' + CHR(13)+CHR(10) + 'Disponível: ' + cValtochar(TRANSFORM(aSaldo[2], PesqPict('SD1', 'D1_TOTAL'))) + CHR(13)+CHR(10) + 'Requisitado: ' + cValToChar(TRANSFORM((aNaturez[nX, 02] - aNaturez[nX, 03]), PesqPict('SD1', 'D1_TOTAL')))
                        EXIT
                    endif
                endif
            next nX
        endif
    endif
    if !lRet
        u_AutoAlert(cMsg)
    endif
    FreeObj(oInt)
return(lRet)

user function MT103SEV()
    local aItensSEV := PARAMIXB[2]
    local lNoVar    := Type("aNatArr") == "U"
    if u_cbcUseBudget()
        if lNoVar
            SetPrvt("aNatArr")
        endif
        aNatArr := aItensSEV
        if lNoVar
            _SetNamedPrvt( "aNatArr", aNatArr, 'MATA103')
        endif
    endif
return(aItensSEV)

/*
user function MT103NTZ()
    local ExpC1 := ParamIxb[1] 
return(ExpC1)
*/
user function cbcUseBudget()
    local lUse := GetNewPar('ZZ_USEBUDG', .T.)
return(lUse)

user function MT103MNT()
    local ExpA1     := PARAMIXB[1]
    local ExpA2     := PARAMIXB[2]
    local nX        := 0
    local nPos      := 0
    local nTotal    := 0
    local nDist     := 0
    local aTemp     := {}
    local aNaturez  := {}
    local cNaturez  := ""
    local nNFTotal  := MaFisRet(,"NF_TOTAL")
    local lNoVar    := Type("aCtrlNatArr") == "U"

    if u_cbcUseBudget()
        if (ValType(ExpA1) <> "U") .and. (ValType(ExpA2) <> "U")
            for nX := 1 to len(aCols)
                if !empty(gdFieldGet("D1_PEDIDO",nX)) .and. !empty(gdFieldGet("D1_ITEMPC",nX)) .and. !gdDeleted(nX)
                    cNaturez  := AllTrim(srvItemNat(AllTrim(gdFieldGet("D1_PEDIDO",nX)), AllTrim(gdFieldGet("D1_ITEMPC",nX))))
                    if !empty(cNaturez)
                        nPos := aScan(aNaturez, {|x| x[1] == cNaturez})
                        if nPos > 0
                            aNaturez[nPos, 2] += gdFieldGet("D1_TOTAL",nX)
                        else
                            aAdd(aNaturez, {cNaturez, gdFieldGet("D1_TOTAL",nX)})
                        endif
                    endif
                endif
            next nX
            if lNoVar
                SetPrvt("aCtrlNatArr")
                aCtrlNatArr := aClone(aNaturez)
                _SetNamedPrvt( "aCtrlNatArr", aCtrlNatArr, 'MATA103')
            else
                for nX := 1 to len(aNaturez)
                    nPos := aScan(aCtrlNatArr, {|x| x[1] == aNaturez[nX, 1]})
                    if nPos > 0
                        if aNaturez[nX, 2] <> aCtrlNatArr[nPos, 2]
                            aAdd(aTemp, aNaturez[nX])
                        endif
                    else
                        aAdd(aTemp, aNaturez[nX])
                    endif
                next nX
                aNaturez := aClone(aTemp)
            endif
            nTotal := 0
            for nX := 1 to len(ExpA2)
                nPos := aScan(aNaturez, {|x| AllTrim(x[1]) == AllTrim(ExpA2[aScan(ExpA1, {|x| Upper(AllTrim(x[2])) == "EV_NATUREZ"})])})
                if nPos == 0
                    nTotal += ExpA2[nX, aScan(ExpA1, {|x| Upper(AllTrim(x[2])) == "EV_PERC"})]
                endif
            next nX
            nTotal := (100-nTotal)
            if nTotal > 0
                nNFTotal := (nNFTotal * (nTotal/100))
                for nX := 1 to len(aNaturez)
                    nPos    := aScan(ExpA2, {|z| AllTrim(z[aScan(ExpA1, {|x| Upper(AllTrim(x[2])) == "EV_NATUREZ"})]) == aNaturez[nX, 1]})
                    nPerc   := Round((aNaturez[nX, 2] / nNFTotal) * 100, 2)
                    if nPos == 0
                        if empty(ExpA2[1, aScan(ExpA1, {|x| Upper(AllTrim(x[2])) == "EV_NATUREZ"})])
                            ExpA2[1, aScan(ExpA1, {|x| Upper(AllTrim(x[2])) == "EV_NATUREZ"})] := aNaturez[nX, 1]
                            ExpA2[1, aScan(ExpA1, {|x| Upper(AllTrim(x[2])) == "EV_PERC"})]    := nPerc
                        else
                            aAdd(ExpA2, {aNaturez[nX, 1], nPerc, "SEV", 0, .F.})
                        endif
                    else
                        ExpA2[nPos, aScan(ExpA1, {|x| Upper(AllTrim(x[2])) == "EV_NATUREZ"})] := aNaturez[nX, 1]
                        ExpA2[nPos, aScan(ExpA1, {|x| Upper(AllTrim(x[2])) == "EV_PERC"})]    := nPerc
                    endif
                next nX
            endif
            nTotal := 0
            for nX := 1 to len(ExpA2)
                nTotal += ExpA2[nX, aScan(ExpA1, {|x| Upper(AllTrim(x[2])) == "EV_PERC"})]
            next nX
            while (nTotal > 0 .and. nTotal <> 100)
                nDist := Round((100 - nTotal),2)
                for nX := 1 to len(ExpA2)
                    ExpA2[nX, aScan(ExpA1, {|x| Upper(AllTrim(x[2])) == "EV_PERC"})] += (nDist * (100-ExpA2[nX, aScan(ExpA1, {|x| Upper(AllTrim(x[2])) == "EV_PERC"})]))
                next nX
            endDo
        endif
    endif
return(ExpA2)

/*STATIC ZONE*/
static function PCNatInfo(cPed, cNaturez)
    local aArea     := getArea()
    local aAreaCR   := SCR->(getArea())
    local aAreaC7   := SC7->(getArea())
    local aRet      := {}
    local oSql      := nil
    local nTotal    := 0
    local nNatTot   := 0
    local nPerc     := 0

    oSql := LibSqlObj():newLibSqlObj()
    oSql:newAlias(qryNatTotal(cPed))
    if oSql:hasRecords()
        oSql:GoTop()
        while oSql:notIsEof()
            if (AllTrim(cNaturez) == AllTrim(oSql:getValue('NATUREZ')))
                nNatTot += oSql:getValue('TOTAL')
            endif
            nTotal += oSql:getValue('TOTAL')
            oSql:skip()
        enddo
    endif
    if nTotal > 0 .and. nNatTot > 0
        nPerc := Round((nNatTot / nTotal) * 100, 2)
    endif
    aRet := {nTotal, nNatTot, nPerc}
    oSql:close()
    Freeobj(oSql)
    RestArea(aAreaC7)
    RestArea(aAreaCR)
    RestArea(aArea)
return(aRet)

static function srvItemNat(cPed, cItem)
    local aArea     := getArea()
    local aAreaCR   := SCR->(getArea())
    local aAreaC7   := SC7->(getArea())
    local oSql      := nil
    local cNaturez  := ""

    oSql := LibSqlObj():newLibSqlObj()
    oSql:newAlias(qryNatItem(cPed,cItem))
    if oSql:hasRecords()
        oSql:GoTop()
        cNaturez := AllTrim(oSql:getValue('NATUREZ'))
    endif
    oSql:close()
    Freeobj(oSql)
    RestArea(aAreaC7)
    RestArea(aAreaCR)
    RestArea(aArea)
return(cNaturez)

/*QUERY ZONE*/

static function qryNatTotal(cPed)
    local cQry := ""

    cQry += " SELECT SC7.C7_NATUREZ AS [NATUREZ], "
    cQry += " SUM(SC7.C7_TOTAL) AS [TOTAL] "
    cQry += " FROM " + RetSqlName('SC7') + " SC7 "
    cQry += " WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "' "
    cQry += " AND SC7.C7_NUM = '" + cPed + "' "
    cQry += " AND SC7.D_E_L_E_T_ = '' "
    cQry += " GROUP BY SC7.C7_NATUREZ "
return(cQry)

static function qryNatItem(cPed,cItem)
    local cQry := ""

    cQry += " SELECT SC7.C7_NATUREZ AS [NATUREZ] "
    cQry += " FROM " + RetSqlName('SC7') + " SC7 "
    cQry += " WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "' "
    cQry += " AND SC7.C7_NUM = '" + cPed + "' "
    cQry += " AND SC7.C7_ITEM = '" + cItem + "' "
    cQry += " AND SC7.D_E_L_E_T_ = '' "
return(cQry)


static function qrytrgNat(cCod, cFornece, cLoja, lGener)
    local cQry          := ""
    default lGener      := .F.
    default cFornece    := ""
    default cLoja       := ""

    if lGener
        cQry += " SELECT NAT.CLASSE AS [NATUREZA] "
        cQry += " FROM BI_ML_NATUREZA NAT "
        cQry += " INNER JOIN " + RetSqlName('SA2') + " SA2 WITH(NOLOCK) ON NAT.CNPJ_FORN = SA2.A2_CGC AND '' = SA2.D_E_L_E_T_ "
        cQry += " WHERE NAT.FILIAL = '" + FwFilial() + "' "
        cQry += " AND NAT.COD_PRODUTO = '" + cCod + "' "
        cQry += " AND SA2.A2_COD = '" + cFornece + "' "
        cQry += " AND SA2.A2_LOJA = '" + cLoja + "' "
        cQry += " ORDER BY NAT.FATOR_RATEIO DESC "
    else
        cQry += " SELECT NAT.CLASSE AS [NATUREZA], "
        cQry += " COUNT(*) AS [QTDE] "
        cQry += " FROM BI_ML_NATUREZA NAT "
        cQry += " WHERE NAT.FILIAL = '" + FwFilial() + "' "
        cQry += " AND NAT.COD_PRODUTO = '" + cCod + "' "
        cQry += " GROUP BY NAT.CLASSE "
        cQry += " ORDER BY QTDE DESC "
    endif
return(cQry)
