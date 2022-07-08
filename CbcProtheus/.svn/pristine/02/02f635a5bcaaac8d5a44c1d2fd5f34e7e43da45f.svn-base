#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'


user function zCliForMvc(oJsData)
    local aArea         := GetArea()
    local nX            := 0
    private cRealName   := ''
    private cAliasTmp   := ''
    private cTitle      := 'Produto x Fornecedor'
    
    // Cria a temporária   
    cAliasTmp := GetNextAlias()
    aFields := {}
    aadd(aFields, {"ProdFor",  "C", 100,   0})
    aadd(aFields, {"ProdSis",  "C", TamSX3('B1_COD')[01],   0})
    aadd(aFields, {"XX_COD",   "C", TamSX3('A2_COD')[01],   0})
    aadd(aFields, {"XX_LOJA",  "C", TamSX3('A2_LOJA')[01],  0})
    aadd(aFields, {"XX_DESC",  "C", TamSX3('B1_DESC')[01],  0})
    aadd(aFields, {"B1NCM"  ,  "C", TamSX3('B1_POSIPI')[01],  0})
    aadd(aFields, {"XX_RECB1", "N", 14,  0})
    
    if Select(cAliasTmp) == 0
        cArqs := CriaTrab( aFields, .T. )        
        DbUseArea(.T.,"DBFCDX",cArqs,cAliasTmp,.T., .F.)
        cRealName := cArqs+GetDBExtension()
        cArqNtx  := CriaTrab(NIL,.f.)
        cIndCond :="ProdFor"
        IndRegua(cAliasTmp,cArqNtx,cIndCond)
        cArqNtx  := CriaTrab(NIL,.f.)
        cIndCond :="XX_COD+XX_LOJA"
        IndRegua(cAliasTmp,cArqNtx,cIndCond)
    endif
    
    // Preencher os campos
    for nX := 1 to len(oJsData['PROD'])
        reclock(cAliasTmp, .T.)
        (cAliasTmp)->XX_COD     := SA2->(A2_COD)
        (cAliasTmp)->XX_LOJA    := SA2->(A2_LOJA)
        (cAliasTmp)->ProdFor    := oJsData['PROD'][nX]['Cod'] + '-' + oJsData['PROD'][nX]['Descr'] + '-' + Alltrim(oJsData['PROD'][nX]['Ncm'])
        (cAliasTmp)->ProdSis    := oJsData['PROD'][nX]['CodInt']
        (cAliasTmp)->XX_DESC    := oJsData['PROD'][nX]['DescInt']
        (cAliasTmp)->XX_RECB1   := oJsData['PROD'][nX]['RecB1']
        (cAliasTmp)->B1NCM      := oJsData['PROD'][nX]['B1NCM']
        (cAliasTmp)->(MsUnlock())
    next nX
    (cAliasTmp)->(DbGoTop())
    
    FWExecView('Produto x Fornecedor', "VIEWDEF.cbcCliForMVC", MODEL_OPERATION_UPDATE, , { || .T. }, , 30)
 
    (cAliasTmp)->(DbGoTop())
    while ! (cAliasTmp)->(EoF())
        oJsData['PROD'][(cAliasTmp)->(Recno())]['CodInt']  := (cAliasTmp)->ProdSis
        oJsData['PROD'][(cAliasTmp)->(Recno())]['DescInt'] := (cAliasTmp)->XX_DESC
        (cAliasTmp)->(DbSkip())
    enddo
   
    (cAliasTmp)->(DbCloseArea())
    FErase(cArqs + GetDbExtension()) 
    FErase(cArqs + OrdBagExt()) 
    RestArea(aArea)
return

static function ModelDef()
    local oModel    As Object
    local oStrField As Object
    local oStrGrid  As Object
    local aRelation As Array
    local aAux      As Array
   
    oStrField := FWFormStruct(1, 'SA2')
    oStrField:SetProperty( 'A2_EMAIL' 	, MODEL_FIELD_OBRIGAT,.F.)
    
    // Criamos aqui a estrutura da grid
    oStrGrid := FWFormModelStruct():New() 
    oStrGrid:AddTable(cAliasTmp, {'ProdFor'}, "Prod_Forne", {||cRealName})
    // Adiciona os campos da estrutura
    oStrGrid:AddField(;
        "Cod Fornecedor",;                                                                          // [01]  C   Titulo do campo
        "Cod Fornecedor",;                                                                          // [02]  C   ToolTip do campo
        "XX_COD",;                                                                                  // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        TamSx3('A2_COD')[1],;                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature(STRUCT_FEATURE_INIPAD, cAliasTmp+"->XX_COD" ),;                              // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual
    oStrGrid:AddField(;
        "Loja Fornecedor",;                                                                         // [01]  C   Titulo do campo
        "Loja Fornecedor",;                                                                         // [02]  C   ToolTip do campo
        "XX_LOJA",;                                                                                 // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        TamSx3('A2_LOJA')[1],;                                                                      // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature(STRUCT_FEATURE_INIPAD, cAliasTmp+"->XX_LOJA" ),;                             // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual
    oStrGrid:AddField(;
        "Prod_Fornecedor",;                                                                         // [01]  C   Titulo do campo
        "Prod_Fornecedor",;                                                                         // [02]  C   ToolTip do campo
        "ProdFor",;                                                                                 // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        100,;                                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->ProdFor" ),;                            // [11]  B   Code-block de inicializacao do campo
        .T.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual
    oStrGrid:AddField(;
        "Prod_Protheus",;                                                                           // [01]  C   Titulo do campo
        "Prod_Protheus",;                                                                           // [02]  C   ToolTip do campo
        "ProdSis",;                                                                                 // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        TamSx3('B1_COD')[1],;                                                                       // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        FWBuildFeature( STRUCT_FEATURE_VALID, "ExistCpo('SB1')"),;                                  // [07]  B   Code-block de validação do campo
        nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .T.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->ProdSis" ),;                            // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual
    oStrGrid:AddField(;
        "Desc_Protheus",;                                                                           // [01]  C   Titulo do campo
        "Desc_Protheus",;                                                                           // [02]  C   ToolTip do campo
        "XX_DESC",;                                                                                 // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        TamSx3('B1_DESC')[1],;                                                                      // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->XX_DESC" ),;                            // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual
    oStrGrid:AddField(;
        "NCM_Protheus",;                                                                           // [01]  C   Titulo do campo
        "NCM_Protheus",;                                                                           // [02]  C   ToolTip do campo
        "B1NCM",;                                                                                   // [03]  C   Id do Field
        "C",;                                                                                       // [04]  C   Tipo do campo
        TamSx3('B1_POSIPI')[1],;                                                                    // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->B1NCM" ),;                              // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual
    oStrGrid:AddField(;
        "RecnoSB1",;                                                                                // [01]  C   Titulo do campo
        "RecnoSB1",;                                                                                // [02]  C   ToolTip do campo
        "XX_RECB1",;                                                                                // [03]  C   Id do Field
        "N",;                                                                                       // [04]  C   Tipo do campo
        14,;                                                                                        // [05]  N   Tamanho do campo
        0,;                                                                                         // [06]  N   Decimal do campo
        Nil,;                                                                                       // [07]  B   Code-block de validação do campo
        Nil,;                                                                                       // [08]  B   Code-block de validação When do campo
        {},;                                                                                        // [09]  A   Lista de valores permitido do campo
        .F.,;                                                                                       // [10]  L   Indica se o campo tem preenchimento obrigatório
        FwBuildFeature( STRUCT_FEATURE_INIPAD, cAliasTmp+"->XX_RECB1" ),;                           // [11]  B   Code-block de inicializacao do campo
        .F.,;                                                                                       // [12]  L   Indica se trata-se de um campo chave
        .F.,;                                                                                       // [13]  L   Indica se o campo pode receber valor em uma operação de update.
        .F.)                                                                                        // [14]  L   Indica se o campo é virtual
    
    aAux := CreateTrigger('XX_DESC', 'SB1->(B1_DESC)')  
    oStrGrid:AddTrigger(aAux[1] ,aAux[2], aAux[3], aAux[4])
    aAux := CreateTrigger('B1NCM', 'SB1->(B1_POSIPI)')  
    oStrGrid:AddTrigger(aAux[1] ,aAux[2], aAux[3], aAux[4])

    aRelation := {}
    aadd(aRelation, {"XX_COD", "A2_COD"})
    aadd(aRelation, {"XX_LOJA","A2_LOJA"})

    oModel := MPFormModel():New('cbcCliForMVCM')
    oModel:AddFields('CABID', nil , oStrField)
    oModel:AddGrid('GRIDID', 'CABID', oStrGrid)
    oModel:SetRelation('GRIDID', aRelation,(cAliasTmp)->(IndexKey(1)))
    oModel:SetDescription(cTitle)
    // oModel:GetModel('GRIDID'):SetUniqueLine( {'ProdFor'} )
    oModel:GetModel('CABID'):SetPrimaryKey({'A2_COD', 'A2_LOJA'})
    oModel:GetModel('CABID'):SetOnlyView(.T.)
    oModel:GetModel('GRIDID'):SetDescription( 'Produto x Sistema' )
    
return oModel


static Function ViewDef()
    local oView    As Object
    local oModel   As Object
    local oStrCab  As Object
    local oStrGrid As Object
 
    oStrCab := FWFormStruct(2, 'SA2')
    //Agora a estrutura da Grid
    oStrGrid := FWFormViewStruct():New()
  
    oStrGrid:AddField(;
        "ProdFor",;                 // [01]  C   Nome do Campo
        "03",;                      // [02]  C   Ordem
        "Prod_Fornecedor",;         // [03]  C   Titulo do campo
        "Prod_Fornecedor",;         // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo
    oStrGrid:AddField(;
        "ProdSis",;                 // [01]  C   Nome do Campo
        "04",;                      // [02]  C   Ordem
        "Prod_Protheus",;           // [03]  C   Titulo do campo
        "Prod_Protheus",;           // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        'SB1ENT',;                  // [09]  C   Consulta F3
        .T.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo

    oStrGrid:AddField(;
        "XX_DESC",;                 // [01]  C   Nome do Campo
        "05",;                      // [02]  C   Ordem
        "Desc_Protheus",;           // [03]  C   Titulo do campo
        "Desc_Protheus",;           // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo
    oStrGrid:AddField(;
        "B1NCM",;                 // [01]  C   Nome do Campo
        "06",;                      // [02]  C   Ordem
        "NCM_Protheus",;           // [03]  C   Titulo do campo
        "NCM_Protheus",;           // [04]  C   Descricao do campo
        Nil,;                       // [05]  A   Array com Help
        "C",;                       // [06]  C   Tipo do campo
        "@!",;                      // [07]  C   Picture
        Nil,;                       // [08]  B   Bloco de PictTre Var
        Nil,;                       // [09]  C   Consulta F3
        .F.,;                       // [10]  L   Indica se o campo é alteravel
        Nil,;                       // [11]  C   Pasta do campo
        Nil,;                       // [12]  C   Agrupamento do campo
        Nil,;                       // [13]  A   Lista de valores permitido do campo (Combo)
        Nil,;                       // [14]  N   Tamanho maximo da maior opção do combo
        Nil,;                       // [15]  C   Inicializador de Browse
        Nil,;                       // [16]  L   Indica se o campo é virtual
        Nil,;                       // [17]  C   Picture Variavel
        Nil)                        // [18]  L   Indica pulo de linha após o campo
    //Carrega o ModelDef
    oModel  := FWLoadModel('cbcCliForMVC')
 
    oView := FwFormView():New()
    oView:SetModel(oModel)
    oView:AddField('CAB', oStrCab, 'CABID')
    oView:AddGrid('GRID', oStrGrid, 'GRIDID')
    oView:CreateHorizontalBox('TOHID', 30)
    oView:CreateHorizontalBox('TOSHOW',70)
    oView:SetOwnerView('CAB' , 'TOHID')
    oView:SetOwnerView('GRID', 'TOSHOW')
    oView:SetDescription(cTitle)
    /*oView:AddUserButton( 'Cad.ProdxForn', '', {|oView| u_xopnCliFor(oView) } ) */

return oView


static function CreateTrigger(cFld, cReg)
    local aAux :=   FwStruTrigger(;
      "ProdSis" ,;                                  // Campo Dominio
      cFld ,;                                       // Campo de Contradominio
      cReg,;                                        // Regra de Preenchimento
      .T. ,;                                        // Se posicionara ou nao antes da execucao do gatilhos
      "SB1" ,;                                      // Alias da tabela a ser posicionada
      1 ,;                                          // Ordem da tabela a ser posicionada
      "XFilial('SB1') + ProdSis" ,;                 // Chave de busca da tabela a ser posicionada
      NIL ,;                                        // Condicao para execucao do gatilho
      "01" )                                        // Sequencia do gatilho (usado para identificacao no caso de erro)   
Return aAux
