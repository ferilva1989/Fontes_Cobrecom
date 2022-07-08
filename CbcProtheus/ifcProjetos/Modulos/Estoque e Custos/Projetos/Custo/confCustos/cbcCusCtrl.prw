#include 'TOTVS.ch'

class cbcCusCtrl
    data aCtaTpp    as array
    data aTpProd    as array
    data aRefTipo   as array
    data aPeriodo   as array
    data aMainMdl   as array
    data aAuxCta    as array
    method newcbcCusCtrl() constructor 
    method perDe()
    method perAte()
    method setupContaTipo()
    method setPeriodo()
    method loadData()
    method confx()
    method sndPlan()
    method detPlan()
endClass


method newcbcCusCtrl() class cbcCusCtrl
    local aSetProd as array
    ::aTpProd   := {}
    ::aCtaTpp   := {}
    ::aPeriodo  := {'',''}
    ::aMainMdl  := {}
    ::aAuxCta     := {}
    aadd(::aAuxCta, {'ME',{'113140000'}})
    aadd(::aAuxCta, {'PA',{'113200000'}})
    refTipo(@self)
    aSetProd := {}
    aadd(aSetProd, {'113060000','ME'})
    aadd(aSetProd, {'113040000','MP'})
    aadd(aSetProd, {'113100000','OI'})
    aadd(aSetProd, {'113010000','PA'})
    aadd(aSetProd, {'113050000','PI'})
    aadd(aSetProd, {'113090000','SC'})
    aadd(aSetProd, {'113080000','SV'})
    aadd(aSetProd, {'113070000','MR'})
    ::setupContaTipo(aSetProd)
return(self)


method setPeriodo(aPer) class cbcCusCtrl
    ::aPeriodo := aPer
return(self)


method perDe()  class cbcCusCtrl
return ::aPeriodo[1]


method perAte() class cbcCusCtrl
return ::aPeriodo[2]


method setupContaTipo(aSetup) class cbcCusCtrl
    local nX as numeric
    ::aTpProd   := {}
    ::aCtaTpp   := aSetup
    for nX := 1 to len(::aCtaTpp)
        aadd(::aTpProd, ::aCtaTpp[nX][2])
    next nX
return(self)


method loadData() class cbcCusCtrl
    local oMdlES    as object
    local oMdlCon   as object
    local oMdlBal   as object
    local oMdlMod   as object
    local oSrv      as object

    oSrv    := cbcCusService():newcbcCusService()
    
    oMdlES  := cbcCusMdl():newcbcCusMdl('ES', ::aTpProd, getTipo('ES', self))
    oSrv:fillData(@oMdlES, 'ES', ::perDe(), ::perAte())
    aadd(::aMainMdl,oMdlES)
    
    oMdlCon := cbcCusMdl():newcbcCusMdl('CONTAB', ::aTpProd, getTipo('CONTAB', self))
    oSrv:fillData(@oMdlCon, 'CONTAB', ::perDe(), ::perAte())
    aadd(::aMainMdl, oMdlCon)
    
    oMdlBal := cbcCusMdl():newcbcCusMdl('BALANCETE', ::aTpProd, getTipo('BALANCETE', self))
    oSrv:fillData(@oMdlBal, 'BALANCETE', ::perDe(), ::perAte())
    aadd(::aMainMdl, oMdlBal)

    oMdlMod := cbcCusMdl():newcbcCusMdl('MODELO7', ::aTpProd, getTipo('MODELO7', self))
    oSrv:fillData(@oMdlMod, 'MODELO7', ::perDe(), ::perAte())
    aadd(::aMainMdl, oMdlMod)

    FreeObj(oSrv)
return(self)

//cbcxCusCtrl
method confx(cWho, aExclude) class cbcCusCtrl
    local oConfer   as object
    local cFrm      as character
    cFrm  := 'ES'
    oConfer := cbcCusConfer():newcbcCusConfer()
    if cWho == 'CONTAB'
        aRet := oConfer:esXContab(cFrm, cWho, aExclude, ::aMainMdl)
    elseif cWho == 'BALANCETE'
        aRet := oConfer:esXBalancete(cFrm, cWho, aExclude, ::aMainMdl)
    elseif cWho == 'MODELO7'
        aRet := oConfer:esXModelo7(cFrm, cWho, aExclude, ::aMainMdl)
    endif
    FreeObj(oConfer)
return aRet


method sndPlan(aWho, cSaveDirName, lXls) class cbcCusCtrl
    local nPosWho   as numeric
    local oExcel    as object
    local oExcelApp as object
    local nX        as numeric
    local nY        as numeric
    local nZ        as numeric
    local cWorkName as character
    local aRow      as array
    local oTmp      as object
    local cName	    as character
    default cSaveDirName    := ''
    default lXls            := .F.
    
    if lXls
        oExcel      := FwMsExcelXlsx():New()
    else
        oExcel      := FWMsExcelEx():New()
    endif
    if empty(cSaveDirName)
        cName := GetTempPath() + "CONF_CUSTOS_" + Dtos(Date()) + cValToChar(Randomize(1000, 500000)) + ".xml"
    else
        cName := cSaveDirName
    endif

    for nZ := 1 to len(aWho)
        if (nPosWho := aScan(::aMainMdl, {|x| lower(Alltrim(x:CNAME)) == lower(Alltrim(aWho[nZ]))}) ) > 0
            cWorkName :=  ::aMainMdl[nPosWho]:CNAME
            oExcel:AddworkSheet(cWorkName)
            oExcel:AddTable(cWorkName,cWorkName)
            oExcel:AddColumn(cWorkName,cWorkName,"MOV",1,1)
            oExcel:AddColumn(cWorkName,cWorkName,"TPP",1,1)
            oExcel:AddColumn(cWorkName,cWorkName,"VLR",1,1)
            if lXls
                oExcel:SetFontSize(14)
            else
                oExcel:SetCelSizeFont(14)
            endif
            for nX := 1 to len(::aMainMdl[nPosWho]:AMOVS)
                for nY := 1 to len(::aMainMdl[nPosWho]:AMOVS[nX]:APROD)
                    aRow := {}
                    oTmp := ::aMainMdl[nPosWho]:AMOVS[nX]:APROD[nY]
                    aadd(aRow, ::aMainMdl[nPosWho]:AMOVS[nX]:CMOVID)
                    aadd(aRow,oTmp:CTIPO)
                    aadd(aRow,oTmp:NVALOR)
                    oExcel:AddRow(cWorkName,cWorkName,aClone(aRow),{})
                next nY    
            next nX
    endif    
    next nZ
    oExcel:Activate()
    oExcel:GetXMLFile(cName)

    if empty(cSaveDirName)
        if ApOleClient("MSExcel")
            oExcelApp := MsExcel():New()
            oExcelApp:WorkBooks:Open(cName)
            oExcelApp:SetVisible(.T.)
            FreeObj(oExcelApp)
        endif
    endif
    FreeObj(oExcel)
return self


method detPlan(cRepName, cMovimento, lXls, cFileName) class cbcCusCtrl
    local oQry      as object
    local nPos      as numeric
    local aAglut    as array
    local nX        as numeric
    default lXls        := .F.
    default cFileName   := ''

    oQry := cbcCusQry():newcbcCusQry(::perDe(), ::perAte())
    if Alltrim(cRepName) == 'ES'
        if Lower(Alltrim(cMovimento)) == 'mov.interna' .Or. Lower(Alltrim(cMovimento)) == 'req.p/prod.'
            doExcel({oQry:movIntReqProd(.F.)}, self, cFileName, lXls)        
        elseif Lower(Alltrim(cMovimento)) == 'producao'
            doExcel({oQry:producao(.F.)}, self, cFileName, lXls)
        elseif Lower(Alltrim(cMovimento)) == 'vendas'
            doExcel({oQry:venda(.F.)}, self, cFileName, lXls)
        elseif Lower(Alltrim(cMovimento)) == 'dev.venda'
            doExcel({oQry:devVenda(.F.)}, self, cFileName, lXls)
        elseif Lower(Alltrim(cMovimento)) == 'entr.poder terc'
            doExcel({oQry:entraTercei(.F.)}, self, cFileName, lXls)
        elseif Lower(Alltrim(cMovimento)) == 'saida poder terc'
            doExcel({oQry:saidaTercei(.F.)}, self, cFileName, lXls)
        elseif Lower(Alltrim(cMovimento)) == 'compras'
            doExcel({oQry:compras(.F.)}, self, cFileName, lXls)
        elseif Lower(Alltrim(cMovimento)) == 'all_es'
            doExcel({oQry:allES()}, self, cFileName, lXls)
        endif
    elseif Alltrim(cRepName) == 'CONTAB'
        aAglut := {}
        aadd(aAglut, oQry:ct2Lote(.F.,'SD1'))
        aadd(aAglut, oQry:ct2Lote(.F.,'SD2'))
        aadd(aAglut, oQry:ct2Lote(.F.,'SD2'))
        doExcel(aAglut, self, cFileName, lXls)
    elseif Alltrim(cRepName) == 'BALANCETE'
        if (nPos := aScan(::aCtaTpp, {|x| lower(Alltrim(x[2])) == lower(Alltrim(cMovimento))}) ) > 0
            doExcel({oQry:balancete(::aCtaTpp[nPos][1])}, self, cFileName, lXls)
        endif
     elseif Alltrim(cRepName) == 'MODELO7'
        doExcel({oQry:modelo7(.F.)}, self, cFileName, lXls)
    elseif Alltrim(cRepName) == 'CT2DET'
        doExcel({oQry:detLotect2(cMovimento)}, self, cFileName, lXls)
    elseif Alltrim(cRepName) == 'BALAN_3'
        if (nPos := aScan(::aAuxCta, {|x| lower(Alltrim(x[1])) == lower(Alltrim(cMovimento))}) ) > 0
            aAglut := {}
            for nX := 1 to len(::aAuxCta[nPos][2])
                aadd(aAglut, oQry:balancete(::aAuxCta[nPos][2][nX]))
            next nX
            if !empty(aAglut)
                if !empty(aAglut[1])
                    doExcel(aAglut, self, cFileName, lXls)
                endif
            endif
        endif
    elseif Alltrim(cRepName) == 'BALAN_COMPRAS'
         if (nPos := aScan(::aCtaTpp, {|x| lower(Alltrim(x[2])) == lower(Alltrim(cMovimento))}) ) > 0
            doExcel({oQry:balxCompras(::aCtaTpp[nPos][1])} , self, cFileName, lXls)
         endif
    endif
    FreeObj(oQry)
return self


/* STATIC ZONE */
static function doExcel(aObj, oSelf, cFileName, lXls)
    local oExcel    as object
    local oExcelApp as object
    local aColum    as array
    local nC        as numeric
    local nX        as numeric
    local nY        as numeric
    local cLocal    as character
    local lHaveCol  as logical
    local cWorkName as character
    local cExt      as character
    local cSaveName as character
    local aRow      as array
    
    default lXls        := .F.
    default cFileName   := ''
    if !empty(aObj[1])
        lHaveCol    := .F.
        if lXls
            oExcel      := FwMsExcelXlsx():New()
            cExt        := '.xlsx'
        else
            oExcel      := FWMsExcelEx():New()
            cExt        := '.xml'
        endif
        
        if !empty(cFileName)
            cWorkName := StrToKArr(cFileName,'.')[1]
            cSaveName := cWorkName + cExt
            cWorkName := left(cWorkName,6)
        else
            cWorkName   := 'detalhe_' + Dtos(Date()) + '_'+cValToChar(Randomize(1000, 500000))
            cLocal      := GetTempPath()
            cSaveName   := cLocal + Alltrim(cWorkName) + cExt
        endif

        
        oExcel:AddworkSheet(cWorkName)
        oExcel:AddTable(cWorkName,cWorkName)
        
        if lXls
            oExcel:SetFontSize(14)
        else
            oExcel:SetCelSizeFont(14)
        endif
        
        for nY := 1 to len(aObj)
            for nX := 1 to len(aObj[nY])
                aRow    := {}
                aColum  := aObj[nY][nX]:getNames()
                for nC := 1 to len(aColum)
                    if !lHaveCol
                        oExcel:AddColumn(cWorkName,cWorkName,aColum[nC],1,1)
                    endif  
                    aadd(aRow, aObj[nY][nX][aColum[nC]])
                next nC
                oExcel:AddRow(cWorkName,cWorkName,aClone(aRow),{})
                lHaveCol := .T.
            next nX
        next nY
        oExcel:Activate()
        oExcel:GetXMLFile(cSaveName)
        if empty(cFileName)
            if ApOleClient("MSExcel")
                oExcelApp := MsExcel():New()
                oExcelApp:WorkBooks:Open(cSaveName)
                oExcelApp:SetVisible(.T.)
                FreeObj(oExcelApp)
            endif
        endif
        FreeObj(oExcel)
    endif
return nil


static function getTipo(cTp, oSelf)
    local aTp   as array
    local nPos  as numeric
    nPos    := 0
    aTp     := {} 
    if (nPos := aScan(oSelf:aRefTipo, {|x| lower(Alltrim(x[1])) == lower(Alltrim(cTp)) }) ) > 0
       aTp := aClone(oSelf:aRefTipo[nPos][2])
    endif
return aTp

static function refTipo(oSelf)
    oSelf:aRefTipo  := {}
    aadd(oSelf:aRefTipo, {'ES', {'saldo inicial','compras','mov.interna',;
                                 'req.p/prod.', 'producao',;
                                 'vendas','dev.venda',;
                                 'dev.compras','entr.poder terc',;
                                 'saida poder terc'}})
    aadd(oSelf:aRefTipo, {'CONTAB', {'compras','mov.interna',;
                                 'req.p/prod.', 'producao',;
                                 'vendas','dev.venda','entr.poder terc',;
                                 'saida poder terc'}})
    aadd(oSelf:aRefTipo, {'BALANCETE', {'saldo inicial','debito',;
                                        'credito','movimento',;
                                        'saldo final'}})
    aadd(oSelf:aRefTipo, {'MODELO7', {'est'}})
return nil
