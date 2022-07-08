//Bibliotecas
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
 
//Vari�veis Est�ticas
Static cTitulo := ""
 
/*/{Protheus.doc} zCadSX5
Cadastro de tabelas SX5
@author Atilio
@since 05/08/2016
@version 1.0
    @param cTabela, character, C�digo da tabela gen�rica
    @param cTitRot, character, T�tulo da Rotina
    @example
    u_zCadSX5("01", "S�ries de NF")
/*/
 
User Function zCadSX5(cTabela, cTitRot)
    Local aArea   := GetArea()
    Local aAreaSX5:= SX5->(GetArea())
    Local oBrowse
    Local cFunBkp := FunName()
    Default cTitRot := ""
    Private cTabX := cTabela
     
    //Sen�o tiver chave, finaliza    
    If Empty(cTabela)
        Return
    EndIf
     
    DbSelectArea('SX5')
    SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
    SX5->(DbGoTop())
     
    //Se vier t�tulo por par�metro
    If !Empty(cTitRot)
        cTitulo := cTitRot
    EndIf
     
    //Se ainda tiver em branco, pega o da pr�pria tabela
    If Empty(cTitulo)
        //Se conseguir posicionar
        If SX5->(DbSeek(FWxFilial("SX5") + "00" + cTabela))
            cTitulo := SX5->X5_DESCRI
             
        Else
            MsgAlert("Tabela n�o encontrada!", "Aten��o")
            Return
        EndIf
    EndIf
     
    //Inst�nciando FWMBrowse - Somente com dicion�rio de dados
    SetFunName("zCadSX5")
    oBrowse := FWMBrowse():New()
     
    //Setando a tabela de cadastro de Autor/Interprete
    oBrowse:SetAlias("SX5")
 
    //Setando a descri��o da rotina
    oBrowse:SetDescription(cTitulo)
     
    //Filtrando
    oBrowse:SetFilterDefault("SX5->X5_TABELA = '"+cTabela+"'")

    oBrowse:SetMenuDef('cbcSX5Model')
    oBrowse:DisableDetails() 
    oBrowse:DisableReport()
    oBrowse:SetUseFilter(.T.)
    
    //Ativa a Browse
    oBrowse:Activate()
     
    SetFunName(cFunBkp)
    RestArea(aAreaSX5)
    RestArea(aArea)
Return
 
 
static function MenuDef()
    Local aRot := {}
     
    //Adicionando op��es
    ADD OPTION aRot TITLE 'Visualizar' ACTION 'VIEWDEF.cbcSX5Model' OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
    ADD OPTION aRot TITLE 'Incluir'    ACTION 'VIEWDEF.cbcSX5Model' OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
    ADD OPTION aRot TITLE 'Alterar'    ACTION 'VIEWDEF.cbcSX5Model' OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
    ADD OPTION aRot TITLE 'Excluir'    ACTION 'VIEWDEF.cbcSX5Model' OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
 
return(aRot)
 
static function ModelDef()
    local oStruSX5	:= FWFormStruct( 1, 'SX5' )
	local oModel	:= nil
    
    //Editando caracter�sticas do dicion�rio
    oStruSX5:SetProperty('X5_TABELA',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.F.'))                       //Modo de Edi��o
    oStruSX5:SetProperty('X5_TABELA',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'cTabX'))                     //Ini Padr�o
    oStruSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    'Iif(INCLUI, .T., .F.)'))     //Modo de Edi��o
    oStruSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'u_zSX5Chv()'))               //Valida��o de Campo
    oStruSX5:SetProperty('X5_CHAVE',    MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigat�rio
    oStruSX5:SetProperty('X5_DESCRI',   MODEL_FIELD_OBRIGAT, .T. )                                                                //Campo Obrigat�rio
    
    oModel := MPFormModel():New('COMPSX5')
	oModel:AddFields('SX5MASTER', /*cOwner*/, oStruSX5)
	oModel:SetPrimaryKey({'X5_FILIAL', 'X5_TABELA', 'X5_CHAVE'})
	oModel:SetDescription('Tabelas do Sistema')
	oModel:GetModel('SX5MASTER'):SetDescription('Tabelas do Sistema')    
return(oModel)

static function ViewDef()
    local oModel 	:= FWLoadModel( 'cbcSX5Model' )
	local oStruSX5 	:= FWFormStruct( 2, 'SX5' )
	local oView		:= nil
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_SX5', oStruSX5, 'SX5MASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SX5', 'TELA' )
return(oView)
 
/*/{Protheus.doc} zSX5Chv
Fun��o que valida a digita��o do campo Chave, para verificar se j� existe
@type function
@author Atilio
@since 05/08/2016
@version 1.0
/*/ 
User Function zSX5Chv()
    Local aArea    := GetArea()
    Local lRet     := .T.
    Local cX5Chave := M->X5_CHAVE
     
    DbSelectArea('SX5')
    SX5->(DbSetOrder(1)) // X5_FILIAL+X5_TABELA+X5_CHAVE
    SX5->(DbGoTop())
     
    //Se conseguir posicionar, j� existe
    If SX5->(DbSeek(FWxFilial('SX5') + cTabX + cX5Chave))
        MsgAlert("J� existe chave com esse c�digo (<b>"+cX5Chave+"</b>)!", "Aten��o")
        lRet := .F.
    EndIf
     
    RestArea(aArea)
Return lRet
