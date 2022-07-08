#include 'TOTVS.ch'
#include "restful.ch"

wsRestful cbcCusQuery DESCRIPTION "API Rest queries de custos"
	wsMethod POST description "Rotas POST "
end wsRestful


wsMethod POST wsService cbcCusQuery
	local oRes		:= JsonObject():new()
    local oBody		:= JsonObject():new()
    local oQry      := nil 
    local oRet      := nil
    local nX        := 0
    local aBal      := {}
    local aBlR      := {}
    local aSetProd  := {}
    

    aadd(aSetProd, {'113060000','ME'})
    aadd(aSetProd, {'113040000','MP'})
    aadd(aSetProd, {'113100000','OI'})
    aadd(aSetProd, {'113010000','PA'})
    aadd(aSetProd, {'113050000','PI'})
    aadd(aSetProd, {'113090000','SC'})
    aadd(aSetProd, {'113080000','SV'})
    aadd(aSetProd, {'113070000','MR'})

    ::SetContentType("application/json")
    oBody:fromJson(::getContent())
    oQry := cbcCusQry():newcbcCusQry(oBody['dataDe'], oBody['dataAte'])
    
    oRes['es'] := {}
    doLoop(oQry:saldoInicial()      , @oRes['es']   , 'saldo inicial')
    doLoop(oQry:compras()           , @oRes['es']   , 'compras')
    oRet := oQry:movIntReqProd()
    doLoop(oRet                     , @oRes['es']   , 'mov.interna', 'TIPO', 'MOV_INTERNA')
    doLoop(oRet                     , @oRes['es']   , 'req.p/prod.', 'TIPO', 'REQ_PRODUCAO')
    doLoop(oQry:producao()          , @oRes['es']   , 'producao')
    doLoop(oQry:venda()             , @oRes['es']   , 'vendas')
    doLoop(oQry:devVenda()          , @oRes['es']   , 'dev.venda')
    doLoop(oQry:devCompra()         , @oRes['es']   , 'dev.compras')
    doLoop(oQry:entraTercei()       , @oRes['es']   , 'entr.poder terc')
    doLoop(oQry:saidaTercei()       , @oRes['es']   , 'saida poder terc')

    oRes['contab'] := {}
    doLoop(oQry:ct2Lote(,'SD1')     , @oRes['contab'])
    doLoop(oQry:ct2Lote(,'SD2')     , @oRes['contab'])
    doLoop(oQry:ct2Lote(,'SD3')     , @oRes['contab'])

    oRes['balancete'] := {}
    aBal := u_cbcCustBal(oBody['dataDe'], oBody['dataAte'])
    for nX := 1 to len(aBal)
        aBlR := {}
        aadd(aBlR,{'id'              , aBal[nX][2]})
        aadd(aBlR,{'saldo_inicial'   , aBal[nX][4]})
        aadd(aBlR,{'debito'          , aBal[nX][5]})
        aadd(aBlR,{'credito'         , aBal[nX][6]})
        aadd(aBlR,{'movimento'       , aBal[nX][7]})
        aadd(aBlR,{'saldo final'     , aBal[nX][8]})
        aadd(oRes['balancete']      , aClone(aBlR))
    next nX
    
    oRes['modelo7'] := {}
    doLoop(oQry:modelo7() , @oRes['modelo7'])

    oRes['es_det']              := JsonObject():new()
    oRes['es_det']['mov']       := oQry:movIntReqProd(.F.)
    oRes['es_det']['prod']      := oQry:producao(.F.)
    oRes['es_det']['venda']     := oQry:venda(.F.)
    oRes['es_det']['devvenda']  := oQry:devVenda(.F.)
    oRes['es_det']['ent3']      := oQry:entraTercei(.F.)
    oRes['es_det']['saida3']    := oQry:saidaTercei(.F.)
    oRes['es_det']['compras']   := oQry:compras(.F.)
    oRes['es_det']['det']       := oQry:allES()

    oRes['det_contab'] := {}
    aadd(oRes['det_contab'], oQry:ct2Lote(.F.,'SD1'))
    aadd(oRes['det_contab'], oQry:ct2Lote(.F.,'SD2'))
    aadd(oRes['det_contab'], oQry:ct2Lote(.F.,'SD3'))

    oRes['det_balan'] := {}
    for nX := 1 to len(aSetProd)
        aadd(oRes['det_balan'], aClone({aSetProd[nX][1], oQry:balancete(aSetProd[nX][1])}) ) 
    next nX
    
    oRes['det_modelo7'] := oQry:modelo7(.F.)

    oRes['balan_compr'] := {}
    for nX := 1 to len(aSetProd)
        aadd(oRes['balan_compr'], {aSetProd[nX][2], oQry:balxCompras(aSetProd[nX][1]) })
    next nX

    ::SetStatus(200)
	::SetResponse(oRes:toJson())
    
    FreeObj(oQry)
return(.T.)



static function doLoop(oRet, oMdl, cId, cTipo, cValor)
    local nX as numeric
    Local oStatic   := IfcXFun():newIfcXFun()
    default cId     := ''
    default cTipo   := 'TIPO'
    default cValor  := 'CUSTO'
    if !empty(oRet) 
        for nX := 1 to len(oRet)
            if !empty(cId)
                oRet[nX][cValor] := oStatic:sP(2):callStatic('cbcCusConfer', 'ajuNum', oRet[nX][cValor], cId)
            endif
            aadd(oMdl, oRet[nX])
        next nX
    endif
return nil
