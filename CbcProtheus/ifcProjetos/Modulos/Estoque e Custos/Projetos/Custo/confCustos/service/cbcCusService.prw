#include 'TOTVS.ch'

class cbcCusService
    method newcbcCusService() constructor 
    method fillData()
    method etlData()

endClass

method newcbcCusService(oMdl) class cbcCusService
   
return(self)


method etlData(oCtrl) class cbcCusService
    local oQry      as object
    local cSaveDir  as character
    
    oQry := cbcCusQry():newcbcCusQry(oCtrl:perDe(),  oCtrl:perAte())
    cSaveDir := cGetFile( '' , 'Salvar Como', 1, '', .T., nOR(GETF_RETDIRECTORY, GETF_LOCALHARD),.T., .T. )
    if ExistDir(cSaveDir)
        U_LbMsgRun({|oSay|etlProc(oCtrl,cSaveDir)} ,"ETL-CUSTOS", "Extraindo os dados!", 2, 0 )
    endif
    
    MsgInfo('Concluido','ETL-Custos')
    FreeObj(oQry)
 return self


method fillData(oMdl, cWho, perDe, perAte) class cbcCusService
    local oQry as object
    oQry := cbcCusQry():newcbcCusQry(perDe, perAte)
    
    if cWho == 'ES'
        es(@oMdl, oQry)
    elseif cWho == 'CONTAB'
        zconta(@oMdl, oQry)
    elseif cWho == 'BALANCETE'
        zbalan(@oMdl, oQry)
    elseif cWho == 'MODELO7'
        zmod7(@oMdl, oQry)
    endif
    FreeObj(oQry)
return(self)


/* STATIC ZONE */
static function etlProc(oCtrl,cSaveDir)
    local nX        as numeric
    oCtrl:sndPlan({'ES', 'CONTAB', 'BALANCETE', 'MODELO7'}, cSaveDir + 'RESUMO.xlsx', .T.)
    oCtrl:detPlan('BALAN_COMPRAS', 'MP', .T., cSaveDir +  'BAL_COMPRAS.xlsx')
    for nX := 1 to len(oCtrl:aCtaTpp)
        oCtrl:detPlan('BALANCETE', oCtrl:aCtaTpp[nX][2], .T., cSaveDir +  'BALAN_'+Alltrim(oCtrl:aCtaTpp[nX][2])+'.xlsx')
    next nX
    oCtrl:detPlan('ES', 'compras', .T., cSaveDir +  'COMPRAS.xlsx')
return nil


static function zmod7(oMdl, oQry)
     doLoop(oQry:modelo7() , @oMdl , 'est')
return nil

static function zbalan(oMdl, oQry)
    local aBal as array
    local nX   as numeric
    aBal := u_cbcCustBal(oQry:perDe, oQry:perAte)
    for nX := 1 to len(aBal)
        oMdl:addValue( 'saldo inicial'  ,aBal[nX][2] , aBal[nX][4] )
        oMdl:addValue( 'debito'         ,aBal[nX][2] , aBal[nX][5] )
        oMdl:addValue( 'credito'        ,aBal[nX][2] , aBal[nX][6] )
        oMdl:addValue( 'movimento'      ,aBal[nX][2] , aBal[nX][7] )
        oMdl:addValue( 'saldo final'    ,aBal[nX][2] , aBal[nX][8] )
    next nX
return nil


static function zconta(oMdl, oQry)
    doCtbLoop(oQry:ct2Lote(,'SD1'), @oMdl)
    doCtbLoop(oQry:ct2Lote(,'SD2'), @oMdl)
    doCtbLoop(oQry:ct2Lote(,'SD3'), @oMdl)
return nil

static function doCtbLoop(oRet, oMdl)
    local nX as numeric
    if !empty(oRet) 
        for nX := 1 to len(oRet)
            oMdl:addValue( oRet[nX]['MOV'], oRet[nX]['TIPO'], oRet[nX]['CUSTO'] )
        next nX
    endif
return nil


static function es(oMdl, oQry)
    local oRet as object
    doLoop(oQry:saldoInicial()      , @oMdl   , 'saldo inicial')
    doLoop(oQry:compras()           , @oMdl   , 'compras')
    oRet := oQry:movIntReqProd()
    doLoop(oRet                     , @oMdl   , 'mov.interna', 'TIPO', 'MOV_INTERNA')
    doLoop(oRet                     , @oMdl   , 'req.p/prod.', 'TIPO', 'REQ_PRODUCAO')
    doLoop(oQry:producao()          , @oMdl   , 'producao')
    doLoop(oQry:venda()             , @oMdl   , 'vendas')
    doLoop(oQry:devVenda()          , @oMdl   , 'dev.venda')
    doLoop(oQry:devCompra()         , @oMdl   , 'dev.compras')
    doLoop(oQry:entraTercei()       , @oMdl   , 'entr.poder terc')
    doLoop(oQry:saidaTercei()       , @oMdl   , 'saida poder terc')
return nil

static function doLoop(oRet, oMdl, cId, cTipo, cValor)
    local nX as numeric
    local nVlr as numeric
    Local oStatic   := IfcXFun():newIfcXFun()
    default cTipo   := 'TIPO'
    default cValor  := 'CUSTO'
    if !empty(oRet) 
        for nX := 1 to len(oRet)
            nVlr := oStatic:sP(2):callStatic('cbcCusConfer', 'ajuNum', oRet[nX][cValor], cId)
            oMdl:addValue(cId, oRet[nX][cTipo], nVlr)
        next nX
    endif
return nil
