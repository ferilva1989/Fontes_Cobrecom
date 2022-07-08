#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"

User Function cbcIntManut()
    Private aButtons   as array
    Private oTFont     as object
    Private oModal     as object
    Private oContainer as object
    Private oBrwMk     as object
    Private aProds     as array

    oTFont := TFont():New("Courier new",,-16,.T.)
    oModal := FWDialogModal():New()

    aButtons := {}
    aadd(aButtons,{,'EXPORTAR',{||FWMsgRun(,{|| export(aProds)}, "Integrando", "Aguarde")}, 'exportar',,.T.,.F.})
    aadd(aButtons,{,'SELECIONAR TUDO',{||SelectAll(oBrwMk, 01, aProds)}, 'selecionar',,.T.,.F.})
    aadd(aButtons,{,'FILTRO',{||Filter()}, 'filtro',,.T.,.F.})

    oModal:SetEscClose(.T.)
    oModal:setTitle("Produtos")
    oModal:setSubTitle("Exportar Produtos - WMS")
    oModal:setSize(300, 670)
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    oModal:AddButtons(aButtons)

    GetSB1(@aProds)
    MtnBrw(aProds)

    oModal:Activate()
    FreeObj(oBrwMk)
    FreeObj(oContainer)
    FreeObj(oModal)
    FreeObj(oTFont)
Return Nil

Static Function MtnBrw(aProds)
    oContainer := TPanel():New(0,0,,oModal:getPanelMain(),,,,,,0,0)
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT

    oBrwMk := fwBrowse():New()
    oBrwMk:setOwner(oContainer)
    oBrwMk:setDataArray()
    oBrwMk:setArray(aProds)
    oBrwMk:disableConfig()
    oBrwMk:disableReport()
    oBrwMk:lHeaderClick := .F.
    oBrwMk:SetFontBrowse(oTFont) 
    oBrwMk:setEditCell(.T., {|| .T. })
    oBrwMk:SetUniqueKey({"CODIGO"})
    oBrwMk:AddMarkColumns({|| IIf(aProds[oBrwMk:nAt,01], "LBOK", "LBNO")},;
        {|| SelectOne(oBrwMk, aProds)},; 
        {|| SelectAll(oBrwMk, 01, aProds)})
    oBrwMk:addColumn({"CODIGO"      , {||aProds[oBrwMk:nAt,02]}, "C", pesqPict("SB1","B1_COD"), 1,  tamSx3("B1_COD")[1],, .F. , , .F.,, 'aProds[oBrwMk:nAt,02]',, .F., .T.,, "xPRODCOD"})
    oBrwMk:addColumn({"TIPO"        , {||aProds[oBrwMk:nAt,03]}, "C", pesqPict("SB1","B1_TIPO"), 1, tamSx3("B1_TIPO")[1],, .F. , , .F.,, 'aProds[oBrwMk:nAt,03]',, .F., .T.,, "xPRODTIPO"})
    oBrwMk:addColumn({"DESCRICAO"   , {||Padr(aProds[oBrwMk:nAt,04], 150)}, "C", "@!", 1, 150,, .T. , {|| .T. } , .F., , "aProds[oBrwMk:nAt,04]",, .F., .T.,, "xPRODDESC"})
    oBrwMk:addColumn({"ESTOQUE MINIMO" , {||aProds[oBrwMk:nAt,06]}, "C", pesqPict("SB1","B1_EMIN"), 1,  tamSx3("B1_EMIN")[1],, .T. , {|| .T. } , .F., , "aProds[oBrwMk:nAt,06]",, .F., .T.,, "xPRODEMIN"})
    oBrwMk:SetSeek(, {{"CODIGO" ,{{"",GetSx3Cache('B1_COD', 'X3_TIPO'),;
        TamSx3('B1_COD')[1], 0,"CODIGO", PesqPict('SB1', 'B1_COD'), "CODIGO"}}, 1},;
        {"DESCRICAO" ,{{"",GetSx3Cache('B1_DESC', 'X3_TIPO'),;
        TamSx3('B1_DESC')[1], 0,"DESCRICAO", PesqPict('SB1', 'B1_DESC'), "DESCRICAO"}},2}})
    oBrwMk:Activate()
Return Nil

Static Function SelectOne(oBrwMk, aArquivo)
    aArquivo[oBrwMk:nAt,1] := !aArquivo[oBrwMk:nAt,1]
    oBrwMk:Refresh()
Return Nil
 
 
Static Function SelectAll(oBrwMk, nCol, aArquivo)
    Local _ni := 1

    For _ni := 1 to len(aArquivo)
        aArquivo[_ni,1] := !aArquivo[_ni,1]
    Next
    oBrwMk:Refresh()
Return Nil
 
 
Static Function GetSB1(aProds, cTipo)
    Local cQuery    as Character
    Local cQryT3    as Character
    Default cTipo := ""

    cQryT3 := GetNextAlias()
    aProds := {}
    
    cQuery := " SELECT B1_COD, B1_TIPO, B1_DESC, B1_MSBLQL, B1_EMIN"
    cQuery += " FROM " + RetSqlName("SB1")
    cQuery += " WHERE B1_FILIAL = '' "
    If Empty(cTipo)
        cQuery += " AND B1_TIPO NOT IN ('PA','PI','MP','ME','MO','SV')"
    Else
        cQuery += " AND B1_COD like '%" + cTipo + "%'"
    EndIf
    cQuery += " AND B1_MSBLQL <> '1'"
    cQuery += " AND D_E_L_E_T_='' "
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T., "TOPCONN", TcGenQry(,, cQuery), cQryT3, .T., .F.)
    
    (cQryT3)->(DbGoTop())
    While (cQryT3)->(!EOF())
        aadd(aProds,{.F.,alltrim((cQryT3)->B1_COD),alltrim((cQryT3)->B1_TIPO),(cQryT3)->B1_DESC,alltrim((cQryT3)->B1_MSBLQL),(cQryT3)->B1_EMIN})
        (cQryT3)->(dbSkip())
    EndDo
    (cQryT3)->(dbCloseArea())
    DbSelectArea('SB1')

    If  !Empty(cTipo) .And. !Empty(aProds)
        oBrwMk:DeActivate(.T.)
        MtnBrw(aProds)
    EndIf
Return Nil


Static Function Filter()
    Local cFilter as string

    cFilter := FWInputBox('Digite o Filtro', cFilter)
    If !Empty(cFilter)
        GetSB1(@aProds, cFilter)
    EndIf
Return Nil


Static Function export(aProds)
    Local nCont as numeric
    Local nX    as numeric

    nCont := 0

    BEGIN TRANSACTION
        For nX := 1 to Len(aProds)
            If (aProds[nX][1])
                u_ztmntAdd(aProds[nX][2], aProds[nX][4], aProds[nX][6])
                aProds[nX][1] := !aProds[nX][1]
                nCont += 1
            Endif
        Next nX
    END TRANSACTION

    If (nCont == 0)
        MsgAlert("Selecione pelo menos Registro", "Resultado")
    Else 
        MsgInfo(cValToChar(nCont) + " Registros exportados", "Resultado")
    EndIf
    oBrwMk:Refresh()
Return Nil
