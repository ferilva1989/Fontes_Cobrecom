#include "totvs.ch"


/* TEST ZONE */
user function cbcxCusCtrl()
    local oCtrl as object
    local oQry as object
    local oSrv  as object
    //local aSetProd as array
    local aErr as array
    local nX as numeric
    /*
    //OPCIONAL
    aSetProd := {}
    aadd(aSetProd, {'113060000','ME'})
    aadd(aSetProd, {'113040000','MP'})
    aadd(aSetProd, {'113100000','OI'})
    aadd(aSetProd, {'113010000','PA'})
    aadd(aSetProd, {'113050000','PI'})
    aadd(aSetProd, {'113090000','SC'})
    aadd(aSetProd, {'113080000','SV'})
    */
   

    // Verificar as querys
    oQry := cbcCusQry():newcbcCusQry('20210501', '20210531')
     /*
    oQry:movIntReqProd()
    oQry:saidaTercei()
    oQry:entraTercei()
    oQry:devCompra()
    oQry:devVenda()
    oQry:venda()
    oQry:producao()
    oQry:compras()
    oQry:ct2Lote(.T., 'SD3')
    */
    // oQry:balxCompras('113040000')
    
    // oQry:balancete('113040000')
    oCtrl := cbcCusCtrl():newcbcCusCtrl()
    oCtrl:setPeriodo({'20210501','20210531'})
   
    //oCtrl:detPlan('ES', 'all_es')

    //oCtrl:setupContaTipo(aSetProd)
    oCtrl:detPlan('BALAN_3', 'ME')
    oCtrl:loadData()

    oSrv := cbcCusService():newcbcCusService()
    oSrv:etlData(oCtrl)
    
    /*
    aErr := oCtrl:confx('CONTAB',{'compras'})
    for nX := 1 to len(aErr)
        msginfo(aErr[nX],'DIFERENCA')
    next nX
    
    aErr := oCtrl:confx('BALANCETE',{})
    for nX := 1 to len(aErr)
        msginfo(aErr[nX],'DIFERENCA')
    next nX
     */
    
    aErr := oCtrl:confx('MODELO7',{})
    for nX := 1 to len(aErr)
        msginfo(aErr[nX],'DIFERENCA')
    next nX
    
    oCtrl:sndPlan({'ES', 'CONTAB', 'BALANCETE', 'MODELO7'})
    
    // oCtrl:detPlan('ES', 'mov.interna')
    // oCtrl:detPlan('ES', 'producao')
    // oCtrl:detPlan('ES', 'vendas')
    // oCtrl:detPlan('ES', 'dev.venda')
    // oCtrl:detPlan('ES', 'entr.poder terc')
    // oCtrl:detPlan('ES', 'saida poder terc')
    // oCtrl:detPlan('ES', 'req.p/prod.')
    // oCtrl:detPlan('CONTAB')
    // oCtrl:detPlan('MODELO7')    
    //oCtrl:detPlan('BALANCETE', 'PA')
    // oCtrl:detPlan('BALANCETE', 'MP')
    // oCtrl:detPlan('CT2DET', 3392653)
    //oCtrl:detPlan('BALAN_3', 'ME')
    //oCtrl:detPlan('BALAN_3', 'PA')

    oCtrl:detPlan('BALAN_COMPRAS', 'MP')
    FreeObj(oCtrl)
    FreeObj(oQry)
    FreeObj(oSrv)
return nil

