#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDef.ch'

user function cbcViewImpost(lPrint, cPar)
    private aCoors 	    := FWGetDialogSize( oMainWnd )
    private oModal 		:= nil
    private oFWExpLayer := nil
    private oCabPanel   := nil
    private oDetPanel   := nil
    private oGrid       := nil
    private oFont	    := TFont():New("Arial",,15,,.F.)
    private oGetNome    := nil
    private oGetPess    := nil
    private oGetTipo    := nil
    private oGetEst     := nil
    private oGetCgc     := nil
    private oGetInsc    := nil
    private oGetVend    := nil
    private oGetGrp     := nil
    private oGetCtrb    := nil
    private oGetSimp    := nil
    private oGetSiaf    := nil
    private oGetClSuf   := nil
    private oGetReidi   := nil
    private oGetSufra   := nil
    private oGetTab     := nil
    private aHeader     := {}
    private aColsGrid   := {}
    private cNome       := Space(TamSx3('A1_NOME')[1])
    private cPessoa     := 'F'
    private cTipo       := 'F'
    private cEst        := Space(TamSx3('A1_EST')[1])
    private cCgc        := Space(TamSx3('A1_CGC')[1])
    private cInsc       := Space(TamSx3('A1_INSCR')[1])
    private cVend       := Space(TamSx3('A1_VEND')[1])
    private cGrp        := Space(TamSx3('A1_GRPTRIB')[1])
    private cCtrb       := '1'
    private cSimp       := Space(TamSx3('A1_SIMPNAC')[1])
    private cSiaf       := Space(TamSX3('A1_CODSIAF')[1])
    private cCalcSuf    := 'N-Não'
    private cReid       := 'N-Não'
    private cSuframa    := Space(TamSx3('A1_SUFRAMA')[1])
    private cTab        := Space(TamSx3('DA0_CODTAB')[1])
    private nLarg       := ((aCoors[4] * 0.3) -20)
    private nAlt        := (((aCoors[3] * 0.48)/2) - 35)
    private cResult     := '{}'
    default lPrint      := .T.
    default cPar        := ''

    oModal  := FWDialogModal():New()
    oModal:setSize((aCoors[3] * 0.48),(aCoors[4] * 0.3))
    oModal:SetEscClose(.T.)
    oModal:setTitle('Cálculo Impostos')
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    if lPrint
        oModal:addOkButton({||FWMsgRun(,{|| printRpt()},"Calculo de Impostos", "Calculando...")}, "Imprimir",{||.T.} )
    else
        oModal:addOkButton({||FWMsgRun(,{|| procCalc(.T.)},"Calculo de Impostos", "Calculando...")}, "Concluir",{||.T.} )
    endif
    defLayout(oModal:getPanelMain())
    mntHead()
    mntDet()
    loadFromPar(cPar)
    oModal:Activate()

    
    FreeObj(oFont)
    FreeObj(oGetNome)
    FreeObj(oGetPess)
    FreeObj(oGetTipo)
    FreeObj(oGetEst)
    FreeObj(oGetCgc)
    FreeObj(oGetInsc)
    FreeObj(oGetVend)
    FreeObj(oGetGrp)
    FreeObj(oGetCtrb)
    FreeObj(oGetSimp)
    FreeObj(oGetSiaf)
    FreeObj(oGetClSuf)
    FreeObj(oGetReidi)
    FreeObj(oGetSufra)
    FreeObj(oGetTab)
    FreeObj(oGrid)
    FreeObj(oCabPanel)
    FreeObj(oDetPanel)
    FreeObj(oFWExpLayer)
    FreeObj(oModal)
return(cResult)

static function defLayout(oPnl)
    oFWExpLayer := FWLayer():New()
    oFWExpLayer:Init( oPnl, .F., .T. )

    //"Controles"
    oFWExpLayer:AddCollumn('SINGLE_COL', 100, .F.)
    oFWExpLayer:AddWindow('SINGLE_COL', 'WND_CAB', 'Cliente', 50, .T., .F.)
    oCabPanel := oFWExpLayer:GetWinPanel('SINGLE_COL', 'WND_CAB')
    oFWExpLayer:AddWindow('SINGLE_COL', 'WND_DET', 'Itens', 50, .T., .F.)
    oDetPanel := oFWExpLayer:GetWinPanel('SINGLE_COL', 'WND_DET')
return(nil)

static function mntHead()
    /*
    INSERIR EM EXECUÇÃO

    oJsCliente['A1_COD'] 		:= '008918'
    oJsCliente['A1_LOJA'] 		:= '01'
    oJsCliente['A1_TES'] 		:= '921'
    oJsCliente['A1_TIPCLI'] 	:= '1'
    */
    oGetNome  := TGet():New(05,05, 	{ |u| iif( PCount() == 0, cNome, cNome := u ) },; 
                oCabPanel, nLarg-10, 15,PesqPict('SA1', 'A1_COD'),,0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cNome",,,,.T.,,,"Cliente",1 )

    oGetPess := TComboBox():New(35,05,{|u|if(PCount()>0,cPessoa:=u,cPessoa)},;
                {'F-Física','J-Juridica'},((nLarg-10) / 3)-05,25,oCabPanel,,{||.T.};
                ,,,,.T.,,,,,,,,,'cPessoa','Física/Jurid', 1)
    
    oGetTipo := TComboBox():New(35,(((nLarg-10) / 3)+05),{|u|if(PCount()>0,cTipo:=u,cTipo)},;
                {'F-Cons.Final','L-Prod.Rural','R-Revendedor','S-Solidario','X-Exportacao'},;
                ((nLarg-10) / 3)-05,25,oCabPanel,,{||.T.};
                ,,,,.T.,,,,,,,,,'cTipo','Tipo', 1)

    oGetCgc := TGet():New(35,((((nLarg-10) / 3)*2) + 10), { |u| iif( PCount() == 0, cCgc, cCgc := u ) },; 
                oCabPanel, ((nLarg-10) / 6)-05, 15,PesqPict('SA1', 'A1_CGC'),,0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCgc",,,,.T.,,,"CNPJ/CPF",1 )

    oGetInsc := TGet():New(35,((((nLarg-10) / 3)*2) + 10) + (((nLarg-10) / 6)+05), { |u| iif( PCount() == 0, cInsc, cInsc := u ) },; 
                oCabPanel, ((nLarg-10) / 6)-05, 15,PesqPict('SA1', 'A1_INSCR'),,0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cInsc",,,,.T.,,,"I.E.",1 )    
    
    oGetEst := TGet():New(65,05, { |u| iif( PCount() == 0, cEst, cEst := u ) },; 
                oCabPanel, ((nLarg-10) / 5)-05, 15,PesqPict('SA1', 'A1_EST'),,0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"12","cEst",,,,.T.,,,"Estado",1 )    

    oGetVend := TGet():New(65,((((nLarg-10) / 5)) + 10), { |u| iif( PCount() == 0, cVend, cVend := u ) },; 
                oCabPanel, ((nLarg-10) / 5)-05, 15,PesqPict('SA1', 'A1_VEND'),,0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"SA3","cVend",,,,.T.,,,"Vendedor",1 )
    
    oGetCtrb  := TComboBox():New(65,((((nLarg-10) / 5)*2) + 10),{|u|if(PCount()>0,cCtrb:=u,cCtrb)},;
                {'1-Sim','2-Não'},((nLarg-10) / 5)-05,25,oCabPanel,,{||.T.};
                ,,,,.T.,,,,,,,,,'cCtrb','Contribuinte', 1)
    
    oGetSimp  := TComboBox():New(65,((((nLarg-10) / 5)*3) + 10),{|u|if(PCount()>0,cSimp:=u,cSimp)},;
                {'1-Sim','2-Não'},((nLarg-10) / 5)-05,25,oCabPanel,,{||.T.};
                ,,,,.T.,,,,,,,,,'cSimp','Simples Nac.', 1)
    
    oGetTab := TGet():New(65,((((nLarg-10) / 5)*4) + 10), { |u| iif( PCount() == 0, cTab, cTab := u ) },; 
                oCabPanel, ((nLarg-10) / 5)-05, 15,PesqPict('DA0', 'DA0_CODTAB'),,0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"DA0","cTab",,,,.T.,,,"Tabela",1 )

    oGetGrp  := TGet():New(95,05, { |u| iif( PCount() == 0, cGrp, cGrp := u ) },; 
                oCabPanel, ((nLarg-10) / 5)-05, 15,PesqPict('SA1', 'A1_GRPTRIB'),,0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cGrp",,,,.T.,,,"Grupo Trib.",1 )

    oGetSiaf  := TGet():New(95,((((nLarg-10) / 5)) + 10), { |u| iif( PCount() == 0, cSiaf, cSiaf := u ) },; 
                oCabPanel, ((nLarg-10) / 5)-05, 15,PesqPict('SA1', 'A1_CODSIAF'),,0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"CC2SIA","cSiaf",,,,.T.,,,"Cod.SIAF",1 )

    oGetClSuf := TComboBox():New(95,((((nLarg-10) / 5)*2) + 10),{|u|if(PCount()>0,cCalcSuf:=u,cCalcSuf)},;
                {'S-Sim','N-Não','I-ICMS'},((nLarg-10) / 5)-05,25,oCabPanel,,{||.T.};
                ,,,,.T.,,,,,,,,,'cCalcSuf','Desc.Suframa', 1)

    oGetSufra  := TGet():New(95,((((nLarg-10) / 5)*3) + 10), { |u| iif( PCount() == 0, cSuframa, cSuframa := u ) },; 
                oCabPanel, ((nLarg-10) / 5)-05, 15,PesqPict('SA1', 'A1_SUFRAMA'),,0,,oFont,;
                .F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cSuframa",,,,.T.,,,"Cod.SUFRAMA",1 )

    oGetReidi := TComboBox():New(95,((((nLarg-10) / 5)*4) + 10),{|u|if(PCount()>0,cReid:=u,cReid)},;
                {'S-Sim','N-Não'},((nLarg-10) / 5)-05,25,oCabPanel,,{||.T.};
                ,,,,.T.,,,,,,,,,'cReid','REIDI/REB', 1)
return(nil)

static function mntDet()
    mntBrw()
return(nil)

static function mntBrw()
    oGrid := FWBrowse():New()
    aHeader     := {}
    aColsGrid   := {}
    mntHeader()
    oGrid:DisableFilter()
    oGrid:DisableConfig()
    oGrid:DisableReport()
    oGrid:DisableSeek()
    oGrid:DisableSaveConfig()
    oGrid:SetFontBrowse(oFont)
    oGrid:SetDataArray()
    oGrid:lHeaderClick := .F.
    oGrid:SetColumns(aHeader)
    oGrid:SetArray(aColsGrid)
    oGrid:SetOwner(oDetPanel)
    oGrid:SetInsert(.T.)
    oGrid:setEditCell( .T. , { || validCell()} )
    //oGrid:SetAddLine({||preAddLine()})
    oGrid:SetAfterAddLine({|| afterAddLine()})
    oGrid:SetLineOk({|| validLine()})
    oGrid:SetDelete(.T.,{||delLine()})
    //oGrid:SetChange({|| changeLine()})
    mntDados()
    oGrid:Activate()
return(nil)

static function mntHeader()
    local aHeaderAux := {}
    local nAtual     := 0
    local cGrid      := 'oGrid'
    
    aHeader := {}
       
    aAdd(aHeaderAux, {"Código",     GetSx3Cache('B1_COD','X3_TIPO'),    TamSx3('B1_COD')[1],   GetSx3Cache('B1_COD',  'X3_DECIMAL'),    PesqPict('SB1', 'B1_COD'),.T.})
    aAdd(aHeaderAux, {"Descrição",  GetSx3Cache('B1_DESC','X3_TIPO'),   TamSx3('B1_DESC')[1],  GetSx3Cache('B1_DESC',  'X3_DECIMAL'),   PesqPict('SB1', 'B1_DESC'), .F.})
    aAdd(aHeaderAux, {"Qtd.Vend.",  GetSx3Cache('C6_QTDVEN','X3_TIPO'), TamSx3('C6_QTDVEN')[1],GetSx3Cache('C6_QTDVEN',  'X3_DECIMAL'), PesqPict('SC6', 'C6_QTDVEN'),.T.})
    aAdd(aHeaderAux, {"Preço Unit.",GetSx3Cache('C6_PRCVEN','X3_TIPO'), TamSx3('C6_PRCVEN')[1],GetSx3Cache('C6_PRCVEN',  'X3_DECIMAL'), PesqPict('SC6', 'C6_PRCVEN'),.T.})
    aAdd(aHeaderAux, {"Total",      GetSx3Cache('C6_VALOR','X3_TIPO'),  TamSx3('C6_VALOR')[1], GetSx3Cache('C6_VALOR',  'X3_DECIMAL'),  PesqPict('SC6', 'C6_VALOR'),.F.})

    for nAtual := 1 to Len(aHeaderAux)
        aAdd(aHeader, FWBrwColumn():New())
        aHeader[nAtual]:SetData(&("{||" + cGrid + ":oData:aArray[" + cGrid + ":At(),"+cValToChar(nAtual)+"]}"))
        aHeader[nAtual]:SetTitle( aHeaderAux[nAtual][1] )
        aHeader[nAtual]:SetType(aHeaderAux[nAtual][2] )
        aHeader[nAtual]:SetSize( aHeaderAux[nAtual][3] )
        aHeader[nAtual]:SetDecimal( aHeaderAux[nAtual][4] )
        aHeader[nAtual]:SetPicture( aHeaderAux[nAtual][5] )
        if aHeaderAux[nAtual][6]
            aHeader[nAtual]:ledit := .T.
            aHeader[nAtual]:cReadVar:= cGrid + ":oData:aArray[" + cGrid + ":At(),"+cValToChar(nAtual)+"]"
        endif
    next nAtual
return(aHeader)

static function mntDados()
    //Zera a grid
    aColsGrid := {}
    
    aAdd(aColsGrid, {Space(TamSx3('B1_COD')[1]), Space(TamSx3('B1_DESC')[1]), 0.00,0.00,0.00})
    
    oGrid:SetArray(aColsGrid)
    oGrid:Refresh()
return(nil)

static function afterAddLine()
    oGrid:oData:aArray[oGrid:At()]:= {Space(TamSx3('B1_COD')[1]), Space(TamSx3('B1_DESC')[1]), 0.00,0.00,0.00}
return(.T.)

static function validLine()
    local lRet      := .T.
    local nCount    := 0
    local nX        := 0

    if !empty(oGrid:oData:aArray)
        for nX := 1 to len(oGrid:oData:aArray[oGrid:At()])
            if !empty(oGrid:oData:aArray[oGrid:At(), nX])
                nCount++
            endif
        next nX

        if empty(nCount)
            oGrid:DelLine()
        elseif(nCount < len(oGrid:oData:aArray[oGrid:At()]))
            MsgAlert('Preencher todos os campos!','Dados Vazios')
            lRet := .F.
        endif
    endif
return(lRet)

static function delLine()
    if !empty(oGrid:oData:aArray)
        aDel(oGrid:oData:aArray, oGrid:At())
        aSize(oGrid:oData:aArray,(len(oGrid:oData:aArray)-1))
        if empty(oGrid:oData:aArray)
            preAddLine()
        endif
    endif
    oGrid:Refresh()
return(.T.)

static function preAddLine()
    if empty(oGrid:oData:aArray)
        aAdd(oGrid:oData:aArray, {Space(TamSx3('B1_COD')[1]), Space(TamSx3('B1_DESC')[1]), 0.00,0.00,0.00})
        oGrid:Refresh()
    endif
return(.T.)

static function validCell()
    local aArea     := GetArea()
    local aAreaSB1  := SB1->(GetArea())
    local lRet      := .T.
    DbSelectArea('SB1')
    SB1->(DbSetOrder(1))
    if oGrid:ColPos() == 01
        if(lRet := (SB1->(DbSeek(xFilial("SB1")+Padr(oGrid:oData:aArray[oGrid:At(), 01], TamSx3('B1_COD')[1]), .T.))))
            if (lRet := (SB1->B1_TIPO == 'PA'))
                oGrid:oData:aArray[oGrid:At(), 02] := AllTrim(SB1->B1_DESC)
                oGrid:oData:aArray[oGrid:At(), 04] := getPrc()
            endif            
        endif
    elseif oGrid:ColPos() == 03 .or. oGrid:ColPos() == 04
        if (lRet := (oGrid:ColPos() > 0.00))
            oGrid:oData:aArray[oGrid:At(), 05] := (oGrid:oData:aArray[oGrid:At(), 03] * oGrid:oData:aArray[oGrid:At(), 04])
        endif
    endif
    RestArea(aAreaSB1)
    RestArea(aArea)
return(lRet)

static function getPrc()
    local nPrc := 0.0000
    local oSql := nil

    if !empty(cTab)
        oSql := LibSqlObj():newLibSqlObj()
        oSql:newAlias(qryPrc(cTab, oGrid:oData:aArray[oGrid:At(), 01]))
        if oSql:hasRecords()
            oSql:goTop()
            nPrc := oSql:getValue("PRC")
        endif
        oSql:Close()
        FreeObj(oSql)
    else
        nPrc := oGrid:oData:aArray[oGrid:At(), 04]
    endif
return(nPrc)

static function qryPrc(cTabl, cProd)
    local cQry := ''

    cQry += " SELECT DA1.DA1_PRCVEN AS [PRC] "
    cQry += " FROM " + RetSqlName('DA0') + " DA0 WITH(NOLOCK) "
    cQry += " INNER JOIN " + RetSqlName('DA1') + " DA1 WITH(NOLOCK) ON DA0.DA0_FILIAL = DA1.DA1_FILIAL "
    cQry += " 								  AND DA0.DA0_CODTAB = DA1.DA1_CODTAB "
    cQry += " 								  AND DA0.D_E_L_E_T_ = DA1.D_E_L_E_T_ "
    cQry += " WHERE DA0.DA0_FILIAL = '" + xFilial('DA0') + "' "
    cQry += "  AND DA0.DA0_CODTAB = '" + AllTrim(cTabl) + "' "
    cQry += "  AND DA0.DA0_ATIVO IN ('','1') "
    cQry += "  AND DA0.DA0_DATDE <= '" + DtoS(dDataBase) + "' "
    cQry += "  AND (DA0.DA0_DATATE = '' OR DA0.DA0_DATATE >= '" + DtoS(dDataBase) + "') "
    cQry += "  AND DA0.D_E_L_E_T_ = '' "
    cQry += "  AND DA1.DA1_CODPRO = '" + AllTrim(cProd) + "' "
    cQry += "  AND DA1.DA1_ATIVO IN ('','1') "
    cQry += "  AND (DA1.DA1_DATVIG = '' OR DA1.DA1_DATVIG <= '" + DtoS(dDataBase) + "') "
return(cQry)

static function procCalc(lClose)
    local oReq      := prepJson()
    local oResp     := nil
    local oJson     := nil
    local aRet      := {}
    default lClose  := .F.

    aRet := u_cbcCalcImpost(oReq)
    if aRet[01]
        oResp     := JsonObject():new()
        oJson     := JsonObject():new()
        oJson:FromJson(aRet[02])
        oResp['impostos'] := oJson
        oResp['dados']    := oReq
        cResult := oResp:ToJson()
        FreeObj(oJson)
        FreeObj(oResp)
        if lClose
            oModal:DeActivate()
        endif
    endif
return(nil)

static function printRpt()
    procCalc()
    if !empty(cResult)
        U_cbcRptCImp(cResult)
        oModal:DeActivate()
    else
        MsgAlert('Erro no Calculo dos Impostos!','Não Calculado')
    endif
return(nil)

static function prepJson()
    local oJson         := JsonObject():new()
	local oJsCliente 	:= JsonObject():new()
	local oSA1			:= JsonObject():new()
    local oJsItem 		:= nil
    local aItns         := {}
    local nX            := 0

    //CABEÇALHO
	oJsCliente['A1_NOME'] 		:= AllTrim(cNome)
	oJsCliente['A1_PESSOA'] 	:= SubStr(cPessoa,1,1)
    oJsCliente['A1_TIPO'] 		:= SubStr(cTipo,1,1)
    oJsCliente['A1_EST'] 		:= AllTrim(cEst)
    oJsCliente['A1_CGC'] 		:= AllTrim(cCgc)
    oJsCliente['A1_INSCR'] 		:= AllTrim(cInsc)
    oJsCliente['A1_VEND'] 		:= AllTrim(cVend)
    oJsCliente['A1_GRPTRIB'] 	:= AllTrim(cGrp)
    oJsCliente['A1_CONTRIB'] 	:= SubStr(cCtrb,1,1)
    oJsCliente['A1_SIMPNAC'] 	:= SubStr(cSimp,1,1)
    oJsCliente['A1_CODSIAF'] 	:= AllTrim(cSiaf)
    oJsCliente['A1_CALCSUF'] 	:= SubStr(cCalcSuf,1,1)
    oJsCliente['A1_XREIDI'] 	:= SubStr(cReid,1,1)
	oJsCliente['A1_SUFRAMA']    := AllTrim(cSuframa)
	oSA1["SA1"] 				:= oJsCliente:toJson()
    
    //ITENS
    aItns 					    := {}
	for nX := 1 to len(oGrid:oData:aArray)
        oJsItem 		        := JsonObject():new()
        oJsItem["codigo"]		:= AllTrim(oGrid:oData:aArray[nX, 01])
        oJsItem["quantidade"]	:= oGrid:oData:aArray[nX, 03]
        oJsItem["precounit"]	:= oGrid:oData:aArray[nX, 04]
        oJsItem["total"]		:= oGrid:oData:aArray[nX, 05]
        aadd(aItns, oJsItem)
        FreeObj(oJsItem)
    next nX
    oJson["cliente"]            := oSA1
    oJson["itens"]              := aItns
    FreeObj(oJsCliente)
	FreeObj(oSA1)
return(oJson)

static function loadFromPar(cPar)
    local aArea    	    := GetArea()
	local aAreaSB1	    := SB1->(getArea())
    local oInfo 		:= cbcDocPorCtrl():newcbcDocPorCtrl()	
	local oJson         := JsonObject():new()
	local oJsCliente 	:= JsonObject():new()
    local nX            := 0
    local nY            := 0
    
    if !empty(cPar)
        oJson 				:= oInfo:load(cPar)

        oJsCliente:FromJSON(oJson['cliente']['SA1'])
        cNome       := AllTrim(oJsCliente['A1_NOME'])
        cPessoa     := iif(oJsCliente['A1_PESSOA'] == 'F', 'F-Física','J-Juridica')
        cTipo       := getStr('Tipo', oJsCliente['A1_TIPO'])
        cEst        := oJsCliente['A1_EST']
        cCgc        := oJsCliente['A1_CGC']
        cInsc       := oJsCliente['A1_INSCR']
        cVend       := oJsCliente['A1_VEND']
        cGrp        := oJsCliente['A1_GRPTRIB']
        cCtrb       := iif(oJsCliente['A1_CONTRIB'] == '1', '1-Sim', '2-Não')
        cSimp       := iif(oJsCliente['A1_SIMPNAC'] == '1', '1-Sim', '2-Não')
        cSiaf       := oJsCliente['A1_CODSIAF']
        cCalcSuf    := getStr('CalSuf', oJsCliente['A1_CALCSUF'])
        cReid       := iif(oJsCliente['A1_XREIDI'] == 'S','S-Sim','N-Não')
        cSuframa    := oJsCliente['A1_SUFRAMA']
        cTab        := oJsCliente['A1_TABELA']
        DbSelectArea('SB1')
        for nX := 1 to len(oJson["itens"])
            nY := Len(oGrid:oData:aArray)
            oGrid:oData:aArray[nY, 01] := AllTrim(oJson["itens"][nX]["codigo"])
            oGrid:oData:aArray[nY, 02] := Posicione("SB1",1,xFilial("SB1")+ Padr(oJson["itens"][nX]["codigo"],TamSx3('B1_COD')[01]),"B1_DESC")
            oGrid:oData:aArray[nY, 03] := oJson["itens"][nX]["quantidade"]
            oGrid:oData:aArray[nY, 04] := oJson["itens"][nX]["precounit"]
            oGrid:oData:aArray[nY, 05] := oJson["itens"][nX]["total"]
            if nX < len(oJson["itens"])
                aAdd(oGrid:oData:aArray, {Space(TamSx3('B1_COD')[1]), Space(TamSx3('B1_DESC')[1]), 0.00,0.00,0.00})
            endif
        next nX
        oGrid:Refresh()
    endif
    FreeObj(oJsCliente)
	FreeObj(oJson)    
    FreeObj(oInfo)
    RestArea(aAreaSB1)
	RestArea(aArea)
return(nil)

static function getStr(cTp, cStr)
    local aTemp := {}
    local cRet  := ''
    local nPosi := 0

    if cTp == 'Tipo'
        aTemp := {'F-Cons.Final',;
                    'L-Prod.Rural',;
                    'R-Revendedor',;
                    'S-Solidario',;
                    'X-Exportacao'}
        if (nPosi := aScan(aTemp, {|x| SubStr(x,1,1) == cStr})) > 0
            cRet := aTemp[nPosi]
        endif
    elseif cTp == 'CalcSuf'
        aTemp := {'S-Sim','N-Não','I-ICMS'}
        if (nPosi := aScan(aTemp, {|x| SubStr(x,1,1) == cStr})) > 0
            cRet := aTemp[nPosi]
        endif
    endif
return(cRet)

user function PedCalcImp(cTp, nRec)
    local aArea     := GetArea()
    local aAreaZP5  := ZP5->(GetArea())
    local aAreaZP6  := ZP6->(GetArea())
    local aAreaZP9  := ZP9->(GetArea())
    local aAreaSC5  := SC5->(GetArea())
    local aAreaSC6  := SC6->(GetArea())
    local aAreaSA1  := SA1->(GetArea())
    local oJson     := JsonObject():new()
    default nRec    := 0

    if nRec > 0
        if cTp == 'Portal'
            DbSelectArea('ZP5')
            ZP5->(DbGoTo(nRec))
            oJson['filial'] := ZP5->ZP5_FILIAL
            oJson['doc']    := ZP5->ZP5_NUM
            oJson['from']   := Capital(lower(cTp))
        else
            DbSelectArea('SC5')
            SC5->(DbGoTo(nRec))
            oJson['filial'] := SC5->C5_FILIAL
            oJson['doc']    := SC5->C5_NUM
            oJson['from']   := Capital(lower(cTp))
        endif
        u_cbcViewImpost(.T., oJson:ToJson())
    endif

    FreeObj(oJson)
    RestArea(aAreaSA1)
    RestArea(aAreaSC6)
    RestArea(aAreaSC5)
    RestArea(aAreaZP9)
    RestArea(aAreaZP6)
    RestArea(aAreaZP5)
    RestArea(aArea)
return(nil)
