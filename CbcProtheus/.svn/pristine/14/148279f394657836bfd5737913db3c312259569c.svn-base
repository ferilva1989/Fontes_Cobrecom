#include 'protheus.ch'

class cbcDistEst
    data lOk
    data cMsgErro
    data oHashEstoque
    data aLstPedido

    method newcbcDistEst() constructor
    method setStatus()
    method isOk()
    method getMsgErr()
    method getEstoque()
    method getPedidos()
    method doSimul()
    method ctrlTrain()
endclass


method newcbcDistEst() class cbcDistEst
    ::setStatus()
    ::oHashEstoque := HMNew()
    ::aLstPedido    := {}
return (self)

method isOk() class cbcDistEst
return(::lOk)

method getMsgErr() class cbcDistEst
return(::cMsgErro)

method setStatus(lSts, cMsg, lEx) class cbcDistEst
    private lException	:= .F.
    default lSts		:= .T.
    default cMsg 		:= ''
    default lEx			:= .F.
    ::lOk				:= lSts
    if !lException
        if !lSts
            cMsg := ('[cbcLibEmp]-' + cMsg)
        endif
        ::cMsgErro	:= cMsg
        if lEx
            lException := .T.
            UserException(cMsg)
        endif
    endif
return(self)

method getEstoque() class cbcDistEst
    local oSql		:= nil
    local cProd		:= ''
    local nSaldo	:= 0
    local xValue	:= nil
    default oHash	:= nil
    HMClean(::oHashEstoque)
    oSql := LibSqlObj():newLibSqlObj()
    oSql:newAlias(u_cbcQRYBFEst())
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            cProd 	:= ( oSql:getValue("Alltrim(Produto)") +;
                oSql:getValue("Alltrim(Acond)") )
            nSaldo 	:= oSql:getValue("Disponivel")
            if  ! HMGet( ::oHashEstoque , cProd , @xValue )
                HMAdd(::oHashEstoque,{cProd,nSaldo})
            endif
            oSql:skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)
return(self)


method getPedidos(cOrderBy, cWhere) class cbcDistEst
    local oSql		 := nil
    local cProd		 := ''
    local cPed       := ''
    local nQtd	     := 0
    local nPos       := 0
    local nPrcItem   := 0
    local nRecC5     := 0
    local nRecC6     := 0
    local nRecC9     := 0
    default cOrderBy := nil
    default cWhere   := nil
    oSql := LibSqlObj():newLibSqlObj()
    oSql:newAlias(qryPed(cOrderBy, cWhere))
    if oSql:hasRecords()
        ::aLstPedido := {}
        oSql:goTop()
        while oSql:notIsEof()
            cPed     := oSql:getValue("Alltrim(PEDIDO)")
            cProd 	 := oSql:getValue("Alltrim(PRODUTO)") + oSql:getValue("Alltrim(ACOND_MTR)")
            cAcond   := oSql:getValue("Alltrim(ACONDICIONAMENTO)")
            nQtd 	 := oSql:getValue("QTD_BLOQUEADO")
            nPrcItem := oSql:getValue("PRC_VENDA")
            nRecC5   := oSql:getValue("RECC5")
            nRecC6   := oSql:getValue("RECC6")
            nRecC9   := oSql:getValue("RECC9")
            if ( nPos := AScan(::aLstPedido,{|a| a[1] == cPed }) ) > 0
                ::aLstPedido[nPos][2] += (nQtd * nPrcItem)
                ::aLstPedido[nPos][3] += (nQtd * nPrcItem)
                aadd(::aLstPedido[nPos][5],;
                    {cPed, cProd, cAcond, nQtd, nPrcItem, nRecC5, nRecC9, nRecC6, 0})
            else
                aadd(::aLstPedido, {cPed, (nQtd * nPrcItem), (nQtd * nPrcItem), nRecC5,;
                    {{cPed, cProd, cAcond, nQtd, nPrcItem, nRecC5, nRecC9, nRecC6, 0}}})
            endif
            oSql:skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)
return(self)


method doSimul(oEst, aPed, lFech) class cbcDistEst
    local oHmClone    as object
    local nX          as numeric
    default lFech   := .T.
    for nX := 1 to len(aPed)
        if lFech
            oHmClone := HMNew()
            zHMClone(oEst, @oHmClone)
            doItem(@aPed[nX], @oHmClone, lFech)
            if (aPed[nX][3] == 0)
                zHMClone(oHmClone, @oEst)
            else
                zeroPed(@aPed[nX])
            endif
        else
             doItem(@aPed[nX], @oEst, lFech)
        endif
    next nX
return(aPed)

/*
    ::oHashEstoque 
    {Produto+Acond, Disponivel}
    ::aLstPedido
    {Pedido, TotalBloq, SaldoBloq, Recno, 
    {{Pedido, ProdAcond, Acond, QtdBloq, PreçoUn, SC5, SC9, SC6, nAtendido}}}
*/
method ctrlTrain() class cbcDistEst
    local results as array
    local cFilter as character
    local cOrder  as character
    
    results := {}

    // OBTEM ESTOQUE
    ::getEstoque()
    
    // ATRASADO
    cFilter := "AND SC5.C5_DTFAT <='" + DToS( Date() ) + "' "
    cOrder  := "C5_TIPOLIB, C5_DTFAT, C5_ENTREG, C5_PARCIAL, C5_NUM"
    ::getPedidos(cOrder, cFilter)
    ::doSimul(@::oHashEstoque , @::aLstPedido, .T.)
    aadd(results,resul(::aLstPedido))

    // RESTANTE (FECHA PEDIDO)
    cFilter := "AND SC5.C5_DTFAT >'" + DToS( Date() ) + "' "
    cOrder  := "C5_TIPOLIB, C5_DTFAT, C5_ENTREG, C5_PARCIAL, C5_NUM"
    ::getPedidos(cOrder, cFilter)
    ::doSimul(@::oHashEstoque , @::aLstPedido, .T.)
    aadd(results,resul(::aLstPedido))

    // RESTANTE (ACEITA PARCIAL)
    cFilter := "AND C5_PARCIAL ='S'" + " AND SC5.C5_DTFAT <='" + DToS( Date() ) + "' "
    cOrder  := "C5_TIPOLIB, C5_DTFAT, C5_ENTREG, C5_PARCIAL, C5_NUM"
    ::getPedidos(cOrder, cFilter)
    ::doSimul(@::oHashEstoque , @::aLstPedido, .F.)
    aadd(results,resul(::aLstPedido))

    MsgInfo('FIM','FIM')
return(self)


/* UTEIS STATICS*/
static function zeroPed(aPed)
    local nX as numeric
    for nX := 1 to len(aPed[5])
        aPed[3]         += (aPed[5][nX][9] * aPed[5][nX][5])
        aPed[5][nX][9]  := 0
    next nX
return(nil)


static function resul(aRes)
    local nPedFech  as numeric
    local nVlrAtend as numeric
    local nX        as numeric
    local aRet      as array
    nVlrAtend       := 0
    nPedFech        := 0
    for nX := 1 to len(aRes)
        nVlrAtend += (aRes[nX][2] - aRes[nX][3])
        if aRes[nX][3] = 0
            nPedFech += 1
        endif
    next nX
    aRet := { nPedFech, nVlrAtend, aClone(aRes) }
return(aRet)


static function doItem(aItm, oHmEst, lFech)
    local nY          as numeric
    local cProdAcon   as character
    local cPedido     as character
    local nQtdBlq     as numeric
    local nLiberado   as numeric
    local nPrc        as numeric
    local nRecC6      as numeric
    default lFech := .T.
    for nY := 1 to len(aItm[5])
        cPedido   := aItm[5][nY][1]
        cProdAcon := aItm[5][nY][2]
        cAcond    := aItm[5][nY][3]
        nQtdBlq   := aItm[5][nY][4]
        nPrc      := aItm[5][nY][5]
        nRecC6    := aItm[5][nY][8]
        if cAcond == 'B'
            nLiberado := getBobPed(cPedido, nRecC6, @oHmEst, cProdAcon)
        else
            nLiberado := zLVirEmp(oHmEst, cProdAcon, nQtdBlq)
        endif
        if lFech
            if ( nLiberado == nQtdBlq )
                aItm[3]         -= ( nLiberado * nPrc )
                aItm[5][nY][9]  := nLiberado
            endif
        else
            aItm[3]         -= ( nLiberado * nPrc )
            aItm[5][nY][9]  := nLiberado
        endif
    next nY
return(aItm)


static function zHMClone(oFrom, oTo)
    local aLstFrm 	:= {}
    local nX		:= 0
    local cProd		:= ''
    local nSaldo	:= 0
    local xValue	:= nil
    HMList(oFrom, aLstFrm)
    HMClean(oTo)
    for nX := 1 to len(aLstFrm)
        cProd 	:= aLstFrm[nX,1]
        nSaldo 	:= aLstFrm[nX,2,1,2]
        if  ! HMGet( oTo , cProd , @xValue )
            HMAdd(oTo,{cProd,nSaldo})
        endif
    next nX
return(nil)


static function  zLVirEmp(oHash, cProd, nQtd)
    local aSld		:= {}
    local nSld		:= 0
    local nQtdAtend := 0
    default oHash	:= nil
    if !empty(oHash)
        if HMGet( oHash, cProd, @aSld )
            if empty(aSld)
                nQtdAtend := 0
            else
                if empty(aSld[1,2])
                    nQtdAtend := 0
                else
                    if ( (nSld := (aSld[1,2] - nQtd)) >= 0 )
                        if( HMSet(oHash, cProd, {{cProd, nSld}} ) )
                            nQtdAtend := nQtd
                        endif
                    else
                        if (HMSet(oHash, cProd, {{cProd, 0}} ))
                            nQtdAtend := aSld[1,2]
                        endif
                    endif
                endif
            endif
        else
            nQtdAtend := 0
        endif
    endif
return(nQtdAtend)


static function getBobPed(cPed, nRecC6, oHmClone, cProdAcon)
    local oSql 		:= nil
    local cQry		:= ''
    local nQtdAtend := 0
    cQry += " SELECT  "
    cQry += " SZE.R_E_C_N_O_ AS [REC], "
    cQry += " SC6.C6_ACONDIC AS [ACONDIC] "
    cQry += " FROM  %SZE.SQLNAME%  WITH (NOLOCK) "
    cQry += " INNER JOIN  %SC6.SQLNAME%   WITH (NOLOCK) "
    cQry += " 	ON SZE.ZE_FILIAL 	= SC6.C6_FILIAL "
    cQry += " 	AND SZE.ZE_PEDIDO  	= SC6.C6_NUM "
    cQry += " 	AND SZE.ZE_ITEM 	= SC6.C6_ITEM "
    cQry += " 	AND SC6.R_E_C_N_O_ 	= SC6.R_E_C_N_O_ "
    cQry += " 	AND SZE.D_E_L_E_T_ 	= SC6.D_E_L_E_T_ "
    cQry += " 	INNER JOIN  %SC9.SQLNAME%   WITH (NOLOCK) "
    cQry += " ON SZE.ZE_FILIAL 		= SC9.C9_FILIAL "
    cQry += " 	AND '  '  			= SC9.C9_BLCRED "
    cQry += " 	AND '02'  			= SC9.C9_BLEST "
    cQry += " 	AND SZE.ZE_PEDIDO  	= SC9.C9_PEDIDO "
    cQry += " 	AND SZE.ZE_ITEM 	= SC9.C9_ITEM "
    cQry += " 	AND SC9.R_E_C_N_O_ 	= SC9.R_E_C_N_O_ "
    cQry += " 	AND SZE.D_E_L_E_T_ 	= SC9.D_E_L_E_T_ "
    cQry += " WHERE %SZE.XFILIAL% "
    cQry += " 	AND ZE_STATUS = 'P' "
    cQry += " 	AND ZE_PEDIDO = '" + cPed + "' "
    cQry += " 	AND %SZE.NOTDEL% "
    cQry += " 	AND %SC6.NOTDEL% "
    oSql := LibSqlObj():newLibSqlObj()
    oSql:newAlias(cQry)
    if oSql:hasRecords()
        oSql:goTop()
        SC6->(DbGoTo(nRecC6))
        while oSql:notIsEof()
            if oSql:getValue("ACONDIC") == 'B'
                SZE->(DbGoTo(oSql:getValue("REC")))
                if SZE->(ZE_CLIENTE + ZE_LOJA + ZE_PEDIDO + ZE_ITEM + ZE_PRODUTO) ==;
                        SC5->(C5_CLIENTE + C5_LOJACLI + C5_NUM) + SC6->(C6_ITEM + C6_PRODUTO)

                    nQtdAtend += zLVirEmp(@oHmClone, cProdAcon, SZE->(ZE_QUANT))
                endif
            else
                MsgInfo('Bobina pesada para item que é rolo!','Erro')
            endif
            oSql:skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)
return(nQtdAtend)



static function qryPed(cOrderBy, cWhere)
    local cQry as character
    default cOrderBy := 'C5_TIPOLIB,C5_DTFAT, C5_ENTREG, C5_PARCIAL, C5_NUM'
    default cWhere   := ''
    cQry := ''
    cQry += " SELECT "
    cQry += " SC5.R_E_C_N_O_							AS [RECC5], "
    cQry += " SC9.R_E_C_N_O_							AS [RECC9], "
    cQry += " SC6.R_E_C_N_O_							AS [RECC6], "
    cQry += " SB1.R_E_C_N_O_							AS [RECB1], "
    cQry += " SC5.C5_NUM								AS [PEDIDO], "
    cQry += " SC5.C5_EMISSAO							AS [EMISSAO], "
    cQry += " SC5.C5_DTFAT								AS [FAT_APARTIR], "
    cQry += " SC5.C5_ENTREG								AS [DATA_ENTREGA], "
    cQry += " SC5.C5_PARCIAL							AS [PARCIAL], "
    cQry += " SC9.C9_PRODUTO							AS [PRODUTO], "
    cQry += " SC6.C6_ACONDIC + REPLICATE('0',(5- LEN(SC6.C6_METRAGE)))  "
    cQry += " + CAST(SC6.C6_METRAGE AS VARCHAR(5))		AS [ACOND_MTR], "
    cQry += " CASE  "
    cQry += " 	WHEN SC6.C6_METRAGE > 0 "
    cQry += " 	THEN (SC9.C9_QTDLIB/SC6.C6_METRAGE) "
    cQry += " 	ELSE SC9.C9_QTDLIB "
    cQry += " END										AS [LANCES_C9], "
    cQry += " SC6.C6_METRAGE							AS [METRAGEM], "
    cQry += " SC9.C9_QTDLIB								AS [QTD_BLOQUEADO], "
    cQry += " SC6.C6_PRCVEN								AS [PRC_VENDA], "
    cQry += " (SC9.C9_QTDLIB * SC6.C6_PRCVEN)			AS [VALOR_ITEM], "
    cQry += " SC9.C9_QTDLIB * SB1.B1_PESBRU				AS [PESO_BRUTO_NECESSARIO], "
    cQry += " SC6.C6_QTDVEN								AS [QTD_VENDIDA], "
    cQry += " SC6.C6_ACONDIC							AS [ACONDICIONAMENTO], "
    cQry += " SC6.C6_LANCES								AS [LANCES_C6] "
    cQry += " FROM " + r('SC9') + " SC9   "
    cQry += " INNER JOIN " + r('SC6') + " SC6  WITH (NOLOCK)  "
    cQry += " 	ON SC9.C9_FILIAL	= SC6.C6_FILIAL"
    cQry += " 	AND SC9.C9_PEDIDO	= SC6.C6_NUM "
    cQry += " 	AND SC9.C9_ITEM		= SC6.C6_ITEM "
    cQry += " 	AND SC9.C9_PRODUTO	= SC6.C6_PRODUTO "
    cQry += " 	AND SC6.R_E_C_N_O_	= SC6.R_E_C_N_O_ "
    cQry += " 	AND SC9.D_E_L_E_T_	= SC6.D_E_L_E_T_ "
    cQry += " INNER JOIN " + r('SC5') + " SC5 WITH (NOLOCK) "
    cQry += " 	ON  SC6.C6_FILIAL	= SC5.C5_FILIAL "
    cQry += " 	AND SC6.C6_NUM		= SC5.C5_NUM "
    cQry += " 	AND SC5.R_E_C_N_O_	= SC5.R_E_C_N_O_ "
    cQry += " 	AND SC6.D_E_L_E_T_	= SC5.D_E_L_E_T_ "
    cQry += " INNER JOIN " + r('SB1') + " SB1  WITH (NOLOCK) "
    cQry += " 	ON '  '	= SB1.B1_FILIAL  "
    cQry += " 	AND 'PA'			= SB1.B1_TIPO "
    cQry += " 	AND SC9.C9_PRODUTO	= SB1.B1_COD "
    cQry += " 	AND SB1.R_E_C_N_O_  = SB1.R_E_C_N_O_ "
    cQry += " 	AND SC9.D_E_L_E_T_  = SB1.D_E_L_E_T_  "
    cQry += " INNER JOIN " + r('SF4') + " SF4 WITH (NOLOCK)  "
    cQry += " 	ON ''				= SF4.F4_FILIAL "
    cQry += " 	AND SC6.C6_TES		= SF4.F4_CODIGO "
    cQry += " 	AND SC6.D_E_L_E_T_	= SF4.D_E_L_E_T_ "
    cQry += " WHERE "
    cQry += " 	SC9.C9_FILIAL IN ('" + FwFilial() + "') "
    cQry += " 	AND SC9.C9_PEDIDO NOT IN(' ') "
    cQry += " 	AND SC9.C9_BLCRED IN (' ') "
    cQry += " 	AND SC9.C9_BLEST  IN ('02') "
    cQry += " 	AND SC9.C9_SERIENF NOT IN ('U') "
    cQry += " 	AND SC5.C5_LIBEROK = 'S' "
    cQry += " 	AND C5_NOTA = '' "
    cQry += " 	AND C5_TIPO = 'N' "
    cQry += " 	AND SC6.C6_BLQ <> 'R' "
    cQry += " 	AND SF4.F4_ESTOQUE = 'S' "
    cQry += " 	AND SB1.B1_TIPO = 'PA' "
    cQry += " 	AND SB1.B1_LOCALIZ = 'S' "
    cQry += " 	AND CASE  "
    cQry += " 			WHEN SC6.C6_METRAGE > 0 "
    cQry += " 			THEN (SC9.C9_QTDLIB/SC6.C6_METRAGE) "
    cQry += " 			ELSE SC9.C9_QTDLIB "
    cQry += " 		END >= SC6.C6_LANCES "
    if !empty(cWhere)
        cQry += cWhere + " "
    endif
    cQry += " 	AND SC9.D_E_L_E_T_ = '' "
    cQry += " ORDER BY " + cOrderBy
return(cQry)


static function r(cTab)
return (RetSqlName(cTab))


/* TRATAIVA DE ERROS */
static function HandleEr(oErr, oSelf)
    local cErro	:=  "[LogDistEst-ErrHnd - "+DtoC(Date())+" - "+;
        Time()+" ] "+ '[ERRO]' + oErr:Description + ' [FROM] ' + ProcName(3)
    if InTransaction()
        DisarmTransaction()
    endif
    ConOut(cErro)
    BREAK
return (nil)



/* TEST ZONE */
user function zxDstEstZ()
    local oDist as object
    oDist := cbcDistEst():newcbcDistEst()
    oDist:ctrlTrain()
    FreeObj(oDist)
return(nil)