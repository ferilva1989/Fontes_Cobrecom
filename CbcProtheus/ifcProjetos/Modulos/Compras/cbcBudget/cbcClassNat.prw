#include 'totvs.ch'

user function cbcClasNat()
    local oAcl		:= cbcAcl():newcbcAcl()
    if oAcl:usrIsGrp({'000000','000136'})
        // iniciar View
        FWMsgRun(, { || initView() }, 	"Classificação de Naturezas de Compras", "Iniciando...")
    else
        MsgAlert('Usuário sem permissão para classificar compras!', 'Acesso negado')
    endif
    FreeObj(oAcl)
return(nil)

static function initView()
    local aCoors        := FWGetDialogSize( oMainWnd )
    private oDlgPrinc   := nil
    private oTable      := nil
    private oPanelBrw   := nil
    private oBrw        := nil
    private cAls        := ''
    
    // Componentes Visuais
    DEFINE MSDIALOG oDlgPrinc TITLE 'Classificação de Naturezas de Compras' ;
        FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] ;
        OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL

    oDlgPrinc:lMaximized := .T.
    oPanelBrw := TPanel():New( ,,, oDlgPrinc)
	oPanelBrw:Align := CONTROL_ALIGN_ALLCLIENT

    mountTable()
    mountBrw()

    Activate MsDialog oDlgPrinc Center

    oTable:Delete()

    FreeObj(oBrw)
    FreeObj(oTable)
    FreeObj(oPanelBrw)
    FreeObj(oDlgPrinc)
return(nil)

static function mountTable(lNew)
    local aFlds := getFields('TBL')
    local cQry  := qryBrw()
    default lNew:= .T.

    if lNew
        oTable := FWTemporaryTable():New(nextAlias())
        oTable:SetFields(aFlds)
        oTable:AddIndex('COMPRA', {aFlds[1,1]} )
        oTable:Create()
        cAls := oTable:GetAlias()
    endif
    //Carregar a Temp
    SQLToTrb(cQry, aFlds, (cAls))
return(nil)

static function mountBrw()
    oBrw := FWMBrowse():New()
    oBrw:SetOwner( oPanelBrw )
    oBrw:SetDescription("Classificação de Natureza")
    oBrw:SetFixedBrowse(.T.)
    oBrw:SetAlias(cAls)
    oBrw:SetMenuDef('')
    oBrw:SetFields(getFields('BRW'))
    oBrw:SetProfileID('BRWCLASNAT')
    oBrw:ForceQuitButton(.T.)
    oBrw:DisableDetails()
    oBrw:DisableReport()
    oBrw:setIgnoreaRotina(.T.)
    oBrw:SetUseFilter(.T.)
    oBrw:SetSeek(.T.,;
        {;
        {"COMPRA" ,{{"",GetSx3Cache('C7_NUM', 'X3_TIPO'),;
        TamSx3('C7_NUM')[1],;
        0,"COMPRA",,PesqPict('SC7', 'C7_NUM')}}};
        };
        )
    oBrw:AddLegend(".T.", "BR_MARRON_OCEAN" , "Aguardando Classificação")
    oBrw:bldblclick := {|| dblClick()}
    oBrw:Activate()
return(nil)

static function getFields(cOpc)
    local aRet      := {}

    if cOpc == 'BRW'
        aAdd(aRet, {'Pedido',       {|| (oTable:GetAlias())->(PEDIDO)},  GetSx3Cache('C7_NUM','X3_TIPO'),    PesqPict('SC7', 'C7_NUM'),     1,TamSx3('C7_NUM')[1],    0})
        aAdd(aRet, {'Item',         {|| (oTable:GetAlias())->(ITEM)},    GetSx3Cache('C7_ITEM','X3_TIPO'),   PesqPict('SC7', 'C7_ITEM'),    1,TamSx3('C7_ITEM')[1],   0})
        aAdd(aRet, {'Produto',      {|| (oTable:GetAlias())->(PRODUTO)}, GetSx3Cache('C7_PRODUTO','X3_TIPO'),PesqPict('SC7', 'C7_PRODUTO'), 1,TamSx3('C7_PRODUTO')[1],0})
        aAdd(aRet, {'Desc.Prod',    {|| (oTable:GetAlias())->(DESCRIC)}, GetSx3Cache('C7_DESCRI','X3_TIPO'), PesqPict('SC7', 'C7_DESCRI'),  1,TamSx3('C7_DESCRI')[1], 0})
        aAdd(aRet, {'U.M.',         {|| (oTable:GetAlias())->(UM)},      GetSx3Cache('C7_UM','X3_TIPO'),     PesqPict('SC7', 'C7_UM'),      1,TamSx3('C7_UM')[1],     0})
        aAdd(aRet, {'Quant.',       {|| (oTable:GetAlias())->(QUANT)},   GetSx3Cache('C7_QUANT','X3_TIPO'),  PesqPict('SC7', 'C7_QUANT'),   1,TamSx3('C7_QUANT')[1],  0})
        aAdd(aRet, {'Cod.Forn',     {|| (oTable:GetAlias())->(FORNECE)}, GetSx3Cache('A2_COD','X3_TIPO'),    PesqPict('SC7', 'A2_COD'),     1,TamSx3('A2_COD')[1],    0})
        aAdd(aRet, {'Nome.Forn',    {|| (oTable:GetAlias())->(NOME)},    GetSx3Cache('A2_NOME','X3_TIPO'),   PesqPict('SC7', 'A2_NOME'),    1,TamSx3('A2_NOME')[1],   0})
        aAdd(aRet, {'Natureza',     {|| (oTable:GetAlias())->(NATUREZ)}, GetSx3Cache('C7_NATUREZ','X3_TIPO'),PesqPict('SC7', 'C7_NATUREZ'), 1,TamSx3('C7_NATUREZ')[1],0})
        aAdd(aRet, {'Solic.',       {|| (oTable:GetAlias())->(SOLICIT)}, GetSx3Cache('C1_SOLICIT','X3_TIPO'),PesqPict('ZZ9', 'C1_SOLICIT'), 1,TamSx3('C1_SOLICIT')[1],0})
    elseif cOpc == 'TBL'
        aAdd(aRet, {'PEDIDO',  GetSx3Cache('C7_NUM','X3_TIPO'),    TamSx3('C7_NUM')[1],    0})
        aAdd(aRet, {'ITEM',    GetSx3Cache('C7_ITEM','X3_TIPO'),   TamSx3('C7_ITEM')[1],   0})
        aAdd(aRet, {'PRODUTO', GetSx3Cache('C7_PRODUTO','X3_TIPO'),TamSx3('C7_PRODUTO')[1],0})
        aAdd(aRet, {'DESCRIC', GetSx3Cache('C7_DESCRI','X3_TIPO'), TamSx3('C7_DESCRI')[1], 0})
        aAdd(aRet, {'UM',      GetSx3Cache('C7_UM','X3_TIPO'),     TamSx3('C7_UM')[1],     0})
        aAdd(aRet, {'QUANT',   GetSx3Cache('C7_QUANT','X3_TIPO'),  TamSx3('C7_QUANT')[1],  0})
        aAdd(aRet, {'FORNECE', GetSx3Cache('A2_COD','X3_TIPO'),    TamSx3('A2_COD')[1],    0})
        aAdd(aRet, {'NOME',    GetSx3Cache('A2_NOME','X3_TIPO'),   TamSx3('A2_NOME')[1],   0})
        aAdd(aRet, {'NATUREZ', GetSx3Cache('C7_NATUREZ','X3_TIPO'),TamSx3('C7_NATUREZ')[1],0})
        aAdd(aRet, {'SOLICIT', GetSx3Cache('C1_SOLICIT','X3_TIPO'),TamSx3('C1_SOLICIT')[1],0})
    endif
return(aRet)

static function nextAlias()
    local cAls := ''
    while .T.
        cAls := GetNextAlias()
        if (Select(cAls) <= 0)
            exit
        endIf
    endDo
return(cAls)

static function dblClick()
    local aRet      := {}
    local aPerg     := {}
    local lOk       := .T.
    local oSql      := nil

    aAdd(aPerg,{1,"Natureza",Space(TamSX3("ED_CODIGO")[01]),"","Vazio() .or. ExistCpo('SED')","SED","",50,.T.})    

    if (ParamBox(aPerg,"Informe Natureza",@aRet))
        oSql := LibSqlObj():newLibSqlObj()
        oSql:newAlias(qryRecC7((cAls)->PEDIDO, (cAls)->ITEM))
        if oSql:hasRecords()
            BEGIN TRANSACTION
                oSql:GoTop()
                DbSelectArea("SC7")
                while oSql:notIsEof()
                    SC7->(DbGoTo(oSql:getValue("REC")))
                    if RecLock("SC7",.F.)
                        SC7->C7_NATUREZ := AllTrim(aRet[01])
                        SC7->(MsUnlock())
                    else
                        lOk := .F.
                        EXIT
                    endif
                    oSql:skip()
                enddo
                if lOk
                    oSql:close()
                    oSql:newAlias(qrySemNatur((cAls)->PEDIDO))
                    if !oSql:hasRecords()
                        oSql:close()
                        oSql:newAlias(qryRecCR((cAls)->PEDIDO))
                        if oSql:hasRecords()
                            oSql:GoTop()
                            DbSelectArea("SCR")
                            while oSql:notIsEof()
                                SCR->(DbGoTo(oSql:getValue("REC")))
                                if RecLock("SCR",.F.)
                                    SCR->CR_ACLASSI := 'N'
                                    SCR->(MsUnlock())
                                else
                                    lOk := .F.
                                    EXIT
                                endif
                                oSql:skip()
                            enddo
                        endif
                    endif
                endif
                if !lOk
                    DisarmTransaction()
                endif
            END TRANSACTION
            reboot()
        endif
        oSql:close()
        Freeobj(oSql)
    endif
return(nil)

static function reboot()
    TcSqlExec(qryDelTemp(oTable:GetRealName()))
    mountTable(.F.)
    oBrw:Refresh()
    oPanelBrw:Refresh()
return(nil)

static function qryDelTemp(cTable)
    local cQry := ""
    cQry += " DELETE "
    cQry += " FROM " + cTable
return(cQry)

static function qryRecC7(cNum, cItem)
    local cQry := ""
    cQry += " SELECT SC7.R_E_C_N_O_ AS [REC] "
    cQry += " FROM " + RetSqlName('SC7') + " SC7 "
    cQry += " WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "' "
    cQry += " AND SC7.C7_NUM = '" + cNum + "' "
    cQry += " AND SC7.C7_ITEM = '" + cItem + "' "
    cQry += " AND SC7.D_E_L_E_T_ = '' "
return(cQry)

static function qrySemNatur(cNum)
    local cQry := ""
    cQry += " SELECT SC7.R_E_C_N_O_ AS [REC] "
    cQry += " FROM " + RetSqlName('SC7') + " SC7 "
    cQry += " WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "' "
    cQry += " AND SC7.C7_NUM = '" + cNum + "' "
    cQry += " AND SC7.C7_NATUREZ = '' "
    cQry += " AND SC7.D_E_L_E_T_ = '' "
return(cQry)

static function qryRecCR(cNum)
    local cQry := ""
    cQry += " SELECT SCR.R_E_C_N_O_ AS [REC] "
    cQry += " FROM " + RetSqlName('SCR') + " SCR "
    cQry += " WHERE SCR.CR_FILIAL = '" + xFilial("SCR") + "' "
    cQry += " AND SCR.CR_NUM = '" + cNum + "' "
    cQry += " AND SCR.CR_ACLASSI = 'S' "
    cQry += " AND SCR.D_E_L_E_T_ = '' "
return(cQry)

static function qryBrw()
    local cQry := ""
    cQry += " SELECT SC7.C7_NUM AS [PEDIDO], "
    cQry += " SC7.C7_ITEM AS [ITEM], "
    cQry += " SC7.C7_PRODUTO AS [PRODUTO], "
    cQry += " SC7.C7_DESCRI AS [DESCRIC], "
    cQry += " SC7.C7_UM AS [UM], "
    cQry += " SC7.C7_QUANT AS [QUANT], "
    cQry += " SA2.A2_COD AS [FORNECE], "
    cQry += " SA2.A2_NOME AS [NOME], "
    cQry += " SC7.C7_NATUREZ AS [NATUREZ], "
    cQry += " ISNULL(SC1.C1_SOLICIT, 'SEM SOLICIT') AS [SOLICIT] "
    cQry += " FROM " + RetSqlName('SCR') + " SCR "
    cQry += " INNER JOIN " + RetSqlName('SC7') + " SC7 ON SCR.CR_FILIAL	= SC7.C7_FILIAL "
    cQry += " 					  AND SCR.CR_NUM	= SC7.C7_NUM "
    cQry += " 					  AND SCR.D_E_L_E_T_= SC7.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SA2') + " SA2 ON SC7.C7_FORNECE = SA2.A2_COD "
    cQry += " 					  AND SC7.D_E_L_E_T_ = SA2.D_E_L_E_T_ "
    cQry += " LEFT JOIN " + RetSqlName('SC1') + " SC1 ON SC7.C7_FILIAL	= SC1.C1_FILIAL "
    cQry += " 					  AND SC7.C7_NUMSC	= SC1.C1_NUM "
    cQry += " 					  AND SC7.D_E_L_E_T_ = SC1.D_E_L_E_T_ "
    cQry += " WHERE SCR.CR_FILIAL = '" + xFilial("SCR") + "' "
    cQry += " AND SCR.CR_ACLASSI = 'S' "
    cQry += " AND SC7.C7_NATUREZ = '' "
    cQry += " AND SCR.D_E_L_E_T_ = '' "
    cQry += " GROUP BY SC7.C7_NUM, SC7.C7_ITEM, SC7.C7_PRODUTO,  "
    cQry += " SC7.C7_DESCRI, SC7.C7_UM, SC7.C7_QUANT,  "
    cQry += " SA2.A2_COD, SA2.A2_NOME, SC7.C7_NATUREZ, ISNULL(SC1.C1_SOLICIT, 'SEM SOLICIT') "
return(cQry)
