#include 'protheus.ch'
/* 
    NO EXCEL UTILIZAR 
    " =Siga("U_zExlXLSX";ARRUMAR(A2);ARRUMAR(B2);ARRUMAR(C2);ARRUMAR(D2)) "
    zExlXLSX('20200501','1150103401','1','R00100','10100')
*/
user function zExlXLSX(cB7Data,cB7Cod,cB7Local,cB7Loclz,nB7Quant,lUpd)
    local oSql      := LibSqlObj():newLibSqlObj()
    local cTxtret   := ''
    default lUpd    := .T.
    cB7Local        := StrZero(val(cB7Local), 2, 0)
    nB7Quant        := val(nB7Quant)
    aRet := getInfo(nB7Quant,cB7Data,cB7Cod,cB7Local,cB7Loclz,oSql)
    if aRet[1]
        Begin Transaction
            cTxtret += 'ANTES -> ' + aRet[2]
            if lUpd
                oSql:update("SB7",;
                    "B7_QUANT = " + cValToChar(nB7Quant), ;
                    "%SB7.XFILIAL% "+;
                    "AND B7_DATA    = '"+cB7Data+"'"+;
                    "AND B7_COD     = '"+cB7Cod+"'"+;
                    "AND B7_LOCAL   = '"+cB7Local+"'"+;
                    "AND B7_LOCALIZ = '"+cB7Loclz+"'"  )
            endif
        End Transaction
        cTxtret += ' DEPOIS -> ' + getInfo(nB7Quant,cB7Data,cB7Cod,cB7Local,cB7Loclz,oSql)[2]
    else
        cTxtret := 'Não Encontrado  registro'
    endif
    FreeObj(oSql)
return(cTxtret)


static function getQry(nB7Quant, cB7Data, cB7Cod, cB7Local, cB7Loclz )
    local cQry  as character
    cQry := ''
    cQry += ' SELECT B7_QUANT, B7_SLDANT, B7_SALDO, * '
    cQry += ' FROM ' + RetSqlName('SB7')
    cQry += " WHERE B7_FILIAL = '" + xFilial('SB7') + "' "
    cQry += " AND B7_DATA     = '" + cB7Data + "' "
    cQry += " AND B7_COD      = '" + cB7Cod  + "' "
    cQry += " AND B7_LOCAL    = '" + cB7Local + "' "
    cQry += " AND B7_LOCALIZ  = '" + cB7Loclz + "' "
    cQry += " AND D_E_L_E_T_  = '' "
return(cQry)


static function getInfo(nB7Quant,cB7Data,cB7Cod,cB7Local,cB7Loclz,oSql)
    local cInfo := ''
    local lSts  := .F.
    oSql:newAlias(getQry(nB7Quant,cB7Data,cB7Cod,cB7Local,cB7Loclz))
    if oSql:hasRecords()
        lSts  := .T.
        oSql:goTop()
        while oSql:notIsEof()
            cInfo := '#######'
            cInfo += ' B7_QUANT '  +  cValToChar(oSql:getValue('B7_QUANT'))
            cInfo += ' B7_SLDANT  '  +  cValToChar(oSql:getValue('B7_SLDANT'))
            cInfo += ' B7_SALDO  '   +  cValToChar(oSql:getValue('B7_SALDO'))
            cInfo += '#######'
            oSql:Skip()
        enddo
    else
        cInfo := 'Registro não encontrado'
        lSts  := .F.
    endif
    oSql:Close()
return({lSts, cInfo})
