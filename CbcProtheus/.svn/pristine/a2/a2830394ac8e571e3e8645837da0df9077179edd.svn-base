#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

Static cTitulo := "Cadastro ZF1"

Static Function ModelDef()
    Local oModel   := Nil
    Local oStTmp   := FWFormModelStruct():New()
    Local oStFilho := FWFormStruct(1, 'ZF1')
    Local bVldPos  := {|| u_zVldZF1Tab()}
    Local bVldCom  := {|| u_zSaveMd2()}
    Local aZF1Rel  := {}
      
    //Adiciona a tabela na estrutura temporária
    oStTmp:AddTable('ZF1', {'ZF1_FILIAL', 'ZF1_TRANSP', 'ZF1_DTINC', 'ZF1_DTFIM'}, "Cabecalho ZF1")
      
    //Adiciona o campos
    oStTmp:AddField(;
        "Filial",;                                                                                  // [01]  C   Titulo do campo
        "Filial",;                                                                                  // [02]  C   ToolTip do campo
        "ZF1_FILIAL",;                                                                              // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        TamSX3("ZF1_FILIAL")[1],;                                                                   // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZF1->ZF1_FILIAL,FWxFilial('ZF1'))" ),;  // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual
      
    oStTmp:AddField("Transportadora", "Transportadora", "ZF1_TRANSP", "C", 6, 0, Nil, Nil, {}, .T.,;
        FwBuildFeature(STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZF1->ZF1_TRANSP,'')" ), .T., .F., .F.)
    oStTmp:AddField("Inicio Vigencia", "Inicio Vigencia", "ZF1_DTINC", "D", TamSX3("ZF1_DTINC")[1], 0, Nil, Nil,;
        {}, .T., FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZF1->ZF1_DTINC,'')" ), .F., .F., .F.)
    oStTmp:AddField("Fim Vigencia", "Fim Vigencia", "ZF1_DTFIM", "D", TamSX3("ZF1_DTFIM")[1], 0, Nil, Nil, {},;
        .T., FwBuildFeature( STRUCT_FEATURE_INIPAD, "Iif(!INCLUI,ZF1->ZF1_DTFIM,'')" ), .F., .F., .F.)   
      
    //Setando as propriedades na grid, o inicializador da Filial e Tabela, para não dar mensagem de coluna vazia
    oStFilho:SetProperty('ZF1_FILIAL', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, Iif(!INCLUI, 'ZF1->ZF1_FILIAL', 'FWxFilial("ZF1")')))
    oStFilho:SetProperty('ZF1_TRANSP', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, Iif(!INCLUI, 'ZF1->ZF1_TRANSP', '0')))
    oStFilho:SetProperty('ZF1_DTINC', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, Iif(!INCLUI, 'ZF1->ZF1_DTINC', 'Date()')))
    oStFilho:SetProperty('ZF1_DTFIM', MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, Iif(!INCLUI, 'ZF1->ZF1_DTFIM', 'Date()')))
      
    //Criando o FormModel, adicionando o Cabeçalho e Grid
    oModel := MPFormModel():New("cbcMVCZF1M",, bVldPos, bVldCom)
    oModel:AddFields("FORMCAB",/*cOwner*/,oStTmp)
    oModel:AddGrid('ZF1DETAIL','FORMCAB',oStFilho)
      
    //Adiciona o relacionamento de Filho, Pai
    aAdd(aZF1Rel, {'ZF1_FILIAL', 'Iif(!INCLUI, ZF1->ZF1_FILIAL, FWxFilial("ZF1"))'} )
    aAdd(aZF1Rel, {'ZF1_TRANSP', 'Iif(!INCLUI, ZF1->ZF1_TRANSP,  "")'} ) 
    aAdd(aZF1Rel, {'ZF1_DTINC', 'Iif(!INCLUI, ZF1->ZF1_DTINC,  "")'} )
    aAdd(aZF1Rel, {'ZF1_DTFIM', 'Iif(!INCLUI, ZF1->ZF1_DTFIM,  "")'} )
      
    //Criando o relacionamento
    oModel:SetRelation('ZF1DETAIL', aZF1Rel, ZF1->(IndexKey(1)))
      
    //Setando o campo único da grid para não ter repetição
    oModel:GetModel('ZF1DETAIL'):SetUniqueLine({"ZF1_FILIAL","ZF1_TRANSP","ZF1_NRREG","ZF1_ROTA"})
      
    //Setando outras informações do Modelo de Dados
    oModel:SetDescription("Modelo de Dados do " + cTitulo)
    oModel:SetPrimaryKey({})
    oModel:GetModel("FORMCAB"):SetDescription("Formulário do  " + cTitulo)
Return oModel


Static Function ViewDef()
    Local oModel     := FWLoadModel("cbcMVCZF1")
    Local oStTmp     := FWFormViewStruct():New()
    Local oStFilho   := FWFormStruct(2, 'ZF1')
    Local oView      := Nil
      
    montaGrid(oStTmp, .T.)
  
    oView := FWFormView():New()
    oView:SetModel(oModel)
    oView:AddField("VIEW_CAB", oStTmp, "FORMCAB")
    oView:AddGrid('VIEW_ZF1',oStFilho,'ZF1DETAIL')
    oView:CreateHorizontalBox('CABEC',30)
    oView:CreateHorizontalBox('GRID',70)
    oView:SetOwnerView('VIEW_CAB','CABEC')
    oView:SetOwnerView('VIEW_ZF1','GRID')
    oView:EnableTitleView('VIEW_CAB','Cabeçalho - Tabela Fretes')
    oView:EnableTitleView('VIEW_ZF1','Itens - Tabela Fretes')
    oView:SetCloseOnOk({||.T.})

    oStFilho:RemoveField('ZF1_FILIAL')
    oStFilho:RemoveField('ZF1_TRANSP')
    oStFilho:RemoveField('ZF1_ROTA')
    oStFilho:RemoveField('ZF1_NRREG')
    oStFilho:RemoveField('ZF1_JSCALC')
    oStFilho:RemoveField('ZF1_DTINC')
    oStFilho:RemoveField('ZF1_DTFIM')

    montaGrid(oStFilho)
Return oView


User Function zVldZF1Tab()
    Local aArea      := GetArea()
    Local lRet       := .T.
    Local oModelDad  := FWModelActive()
    Local cFilZF1    := oModelDad:GetValue('FORMCAB', 'ZF1_FILIAL')
    Local cTransp    := oModelDad:GetValue('FORMCAB', 'ZF1_TRANSP')
    Local nOpc       := oModelDad:GetOperation()
      
    If nOpc == MODEL_OPERATION_INSERT
        DbSelectArea('ZF1')
        ZF1->(DbSetOrder(1)) //ZF1_FILIAL + ZF1_TRANSP
        
        If ZF1->(DbSeek(cFilZF1 + cTransp))
            Aviso('Atenção', 'Esse código de tabela já existe!', {'OK'}, 02)
            lRet := .F.
        EndIf
    EndIf
      
    RestArea(aArea)
Return lRet


User Function zSaveMd2()
    Local aArea      := GetArea()
    Local lRet       := .F.
    Local oModelDad  := FWModelActive()
    Local oModelGrid := oModelDad:GetModel('ZF1DETAIL')
    Local aHeadAux   := oModelGrid:aHeader
    Local aColsAux   := oModelGrid:aDataModel
    Local nPosFil    := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_FILIAL")})
    Local nPosRota   := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_ROTA")})
    Local nPosUf     := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_NRREG")})
    Local nPosIcms   := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_ICMS")})
    Local nPosJs     := aScan(aHeadAux, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_JSCALC")})
    Local nAtual     := 0
    Local oCbcCtrl   := ctrlFrete():newctrlFrete()
    Local aDados     := {}
      
    DbSelectArea('ZF1')
    ZF1->(DbSetOrder(2)) //ZF1_FILIAL+ZF1_TRANSP+ZF1_NRREG+ZF1_ROTA
    For nAtual := 1 To Len(aColsAux)
        If aColsAux[nAtual][2] == .T.
            If ZF1->(DbSeek(aColsAux[nAtual][1][1][nPosFil] + oModelDad:GetValue('FORMCAB', 'ZF1_TRANSP') + aColsAux[nAtual][1][1][nPosUf] + aColsAux[nAtual][1][1][nPosRota]);
                .Or. !EMPTY(aColsAux[nAtual][4]))
                aAdd(aDados, { aColsAux[nAtual][1][1][nPosFil], 'ZF1_FILIAL' })
                aAdd(aDados, { oModelDad:GetValue('FORMCAB', 'ZF1_TRANSP'), 'ZF1_TRANSP' })
                aAdd(aDados, { aColsAux[nAtual][1][1][nPosUf], 'ZF1_NRREG' })
                aAdd(aDados, { aColsAux[nAtual][1][1][nPosRota], 'ZF1_ROTA' })
                aAdd(aDados, { aColsAux[nAtual][1][1][nPosJs], 'ZF1_JSCALC' })
                aAdd(aDados, { oModelDad:GetValue('FORMCAB', 'ZF1_DTINC'), 'ZF1_DTINC' })
                aAdd(aDados, { oModelDad:GetValue('FORMCAB', 'ZF1_DTFIM'), 'ZF1_DTFIM' })
                aAdd(aDados, { aColsAux[nAtual][1][1][nPosIcms], 'ZF1_ICMS' })
                lRet := oCbcCtrl:update(aDados, aColsAux[nAtual][4])
            Else
                aAdd(aDados, { aColsAux[nAtual][1][1][nPosFil], 'ZF1_FILIAL' })
                aAdd(aDados, { oModelDad:GetValue('FORMCAB', 'ZF1_TRANSP'), 'ZF1_TRANSP' })
                aAdd(aDados, { aColsAux[nAtual][1][1][nPosUf], 'ZF1_NRREG' })
                aAdd(aDados, { aColsAux[nAtual][1][1][nPosRota], 'ZF1_ROTA' })
                aAdd(aDados, { aColsAux[nAtual][1][1][nPosJs], 'ZF1_JSCALC' })
                aAdd(aDados, { oModelDad:GetValue('FORMCAB', 'ZF1_DTINC'), 'ZF1_DTINC' })
                aAdd(aDados, { oModelDad:GetValue('FORMCAB', 'ZF1_DTFIM'), 'ZF1_DTFIM' })
                 aAdd(aDados, { aColsAux[nAtual][1][1][nPosIcms], 'ZF1_ICMS' })
                lRet := oCbcCtrl:add(aDados)
            EndIf
        Else
            aAdd(aDados, { aColsAux[nAtual][1][1][nPosFil], 'ZF1_FILIAL' })
            aAdd(aDados, { oModelDad:GetValue('FORMCAB', 'ZF1_TRANSP'), 'ZF1_TRANSP' })
            aAdd(aDados, { aColsAux[nAtual][1][1][nPosUf], 'ZF1_NRREG' })
            aAdd(aDados, { aColsAux[nAtual][1][1][nPosRota], 'ZF1_ROTA' })
            aAdd(aDados, { aColsAux[nAtual][1][1][nPosJs], 'ZF1_JSCALC' })
            aAdd(aDados, { oModelDad:GetValue('FORMCAB', 'ZF1_DTINC'), 'ZF1_DTINC' })
            aAdd(aDados, { oModelDad:GetValue('FORMCAB', 'ZF1_DTFIM'), 'ZF1_DTFIM' })
            aAdd(aDados, { aColsAux[nAtual][1][1][nPosIcms], 'ZF1_ICMS' })
            lRet := oCbcCtrl:delete(aDados, .F., aColsAux[nAtual][4])
        EndIf
        aDados := {}
    Next
    RestArea(aArea)
    FreeObj(oCbcCtrl)
Return lRet


Static Function montaGrid(oGrid, cCab)
    Default oGrid   := Nil
    Default cCab    := .F.

    If cCab <> .F.
        oGrid:AddField(;
            "ZF1_TRANSP",;              // [01]  C   Nome do Campo
            "01",;                      // [02]  C   Ordem
            "Transportadora",;          // [03]  C   Titulo do campo
            "Transportadora",;          // [04]  C   Descricao do campo
            Nil,;                       // [05]  A   Array com Help
            "C",;                       // [06]  C   Tipo do campo
            Nil,;                       // [07]  C   Picture
            Nil,;                       // [08]  B   Bloco de PictTre Var
            'SA4',;                     // [09]  C   Consulta F3
            .T.,;                       // [10]  L   Indica se o campo é alteravel
            Nil,;                       // [11]  C   Pasta do campo
            Nil,;                       // [12]  C   Agrupamento do campo
            Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
            Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
            Nil,;                       // [15]  C   Inicializador de Browse
            Nil,;                       // [16]  L   Indica se o campo é virtual
            Nil,;                       // [17]  C   Picture Variavel
            Nil)                        // [18]  L   Indica pulo de linha após o campo
      
        oGrid:AddField("ZF1_DTINC", "02", "Inicio Vigencia", X3Descric('ZF1_DTINC'), Nil, "D", X3Picture("ZF1_DTINC"),;
            Nil, Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil)

        oGrid:AddField("ZF1_DTFIM", "03", "Fim Vigencia", X3Descric('ZF1_DTFIM'), Nil, "D", X3Picture("ZF1_DTFIM"),;
            Nil, Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil)
    Else
        oGrid:AddField("ZF1_FILIAL", "04", "Filial", X3Descric('ZF1_FILIAL'), Nil, "C", X3Picture("ZF1_FILIAL"),;
            Nil, Nil, .F., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil)
        oGrid:AddField("ZF1_ROTA", "05", "Nome Rota", X3Descric('ZF1_ROTA'), Nil, "C", X3Picture("ZF1_ROTA"),;
            Nil, Nil, .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil)
        oGrid:AddField("ZF1_NRREG", "06", "Região", X3Descric('ZF1_NRREG'), Nil, "C", X3Picture("ZF1_NRREG"),;
            Nil, "GU9GUA", .T., Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil)
    EndIf
Return oGrid

Static Function ZF1JSCALC()
    Local oFrete    := cbcAuditFrete():newcbcAuditFrete()
    Local oJson     := JsonObject():New() 
    Local oModel    := FWModelActive()
    Local aArea     := GetArea()
    Local cValue    := oModel:GetValue('ZF1DETAIL', 'ZF1_JSCALC')
    local cTitulo   := 'TRANSP: [' + SA4->(Alltrim(Alltrim(A4_COD) + '-' +;
    Alltrim(A4_NOME))) + '] - ROTA: [' + Alltrim(oModel:GetValue('ZF1DETAIL', 'ZF1_ROTA')) + ']'
    
    If !Empty(cValue)
        oJson:FromJson(cValue)
        oFrete:showJsCrud(@oJson,cTitulo)
    Else
        oFrete:showJsCrud(@oJson,cTitulo)
    EndIf
    if oFrete:lSalvar
        oModel:LoadValue('ZF1DETAIL', 'ZF1_JSCALC',oJson:ToJson())
        If !(oFrete:doCalc(1276.00, 65401.03, @oJson, 'SP', 'PR'))
            MsgInfo('Erro na Formula', 'Erro')
        else
             MsgInfo('Adicionado', 'Componente')
        EndIf
    endif
    RestArea(aArea)
    FreeObj(oFrete)
Return oJson:ToJson()



user function zCidXReg()
    local oModel    := FWModelActive()
    local cValue    := oModel:GetValue('ZF1DETAIL', 'ZF1_NRREG')
    local cQry      := ''
    local oSql      := nil
    local aCombo    := {}
    local cRet      := ''
    
    if !empty(Alltrim(cValue))    
        cQry := " SELECT  
	    cQry += " GU9_NMREG AS REGIAO,
	    cQry += " GU9_CDUF  AS ESTADO,
	    cQry += " GU7_NMCID AS CIDADE
        cQry += " FROM " + RetSqlName("GU9") + " GU9 WITH(NOLOCK)  
        cQry += " INNER JOIN " + RetSqlName("GUA") + " GUA  WITH(NOLOCK)  
        cQry += " ON GU9.GU9_FILIAL  = GUA.GUA_FILIAL  
        cQry += " AND GU9.GU9_NRREG  = GUA.GUA_NRREG  
        cQry += " AND GU9.D_E_L_E_T_ = GUA.D_E_L_E_T_  
        cQry += " INNER JOIN " + RetSqlName("GU7") + " GU7 WITH(NOLOCK)  
        cQry += " ON GUA.GUA_FILIAL  = GU7.GU7_FILIAL  
        cQry += " AND GUA.GUA_NRCID  = GU7.GU7_NRCID  
        cQry += " AND GUA.D_E_L_E_T_ = GU7.D_E_L_E_T_  
        cQry += " WHERE  
        cQry += " GU9.GU9_FILIAL     = '" + XFilial('GU9') + "'  
        cQry += " AND GU9.GU9_NRREG  = '" + cValue + "'" 
        cQry += " AND GU9.D_E_L_E_T_ = ''
        oSql      := LibSqlObj():newLibSqlObj()
        oSql:newAlias(cQry)
        oSql:GoTop()
        while oSql:notIsEof()
            aadd(aCombo, Alltrim(oSql:getValue("CIDADE")) + '-' + Alltrim(oSql:getValue("ESTADO")) )
            oSql:skip()
        enddo
        oSql:close()
        FreeObj(oSql)
        f_Opcoes(@cRet,"Cidades",@aCombo ,,Nil,Nil,.T.,50,50,.F.,.F.,Nil,.F.,.F.,.F.,Nil)
    endif

return


User Function cbcMVCZF1M()
    Local aParam     := PARAMIXB
	Local xRet       := .T.
	Local oObj       := Nil
	Local cIdPonto   := ''
	Local cIdModel   := ''
    Local oStatic    := Nil

	If aParam <> NIL
		ConOut("> "+aParam[2])
		oObj     := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		If cIdPonto == 'BUTTONBAR'
            oStatic := IfcXFun():newIfcXFun()
			xRet := {}
			aAdd(xRet, {"Componentes", "", {|| oStatic:sP(1):callStatic('cbcMVCZF1' , 'ZF1JSCALC')}, "Componentes"})
            aAdd(xRet, {"Regiões", "", {|| GFEA021() }, "Regiões"})
            aAdd(xRet, {"Cidade x Região", "", {|| u_zCidXReg() }, "Cidade x Região"})
		EndIf
	EndIf
Return xRet
