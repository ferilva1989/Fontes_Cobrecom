#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

#define MODEL_NAME  'cbcCadPass'
#define VIEW_NAME 'VIEW_TABELA'
Static cTitulo := "IFC Acessos"


User Function cbcCadPass() //u_cbcCadPass()
	local aArea   := GetArea()
	local oBrowse

	//Inst�nciando FWMBrowse - Somente com dicion�rio de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZQ1")

	//Setando a descri��o da rotina
	oBrowse:SetDescription(cTitulo)

	//Legendas
	//oBrowse:AddLegend( "ALIAS->CAMPO == '1'", "GREEN", "Original" )
	//oBrowse:AddLegend( "ALIAS->CAMPO == '0'", "RED",   "N�o Original" )

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)
Return Nil

Static Function MenuDef()
	local aRot := {}
	local cAction := 'VIEWDEF.'+ MODEL_NAME

	//Adicionando op��es
	ADD OPTION aRot TITLE 'Visualizar' ACTION  cAction OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION cAction OPERATION MODEL_OPERATION_INSERT 	ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION cAction OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION cAction OPERATION MODEL_OPERATION_DELETE 	ACCESS 0 //OPERATION 5
	//ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_MOD1Leg'     OPERATION 6                      ACCESS 0 //OPERATION X

Return (aRot)

Static Function ModelDef()
	local bPre 		:= {|oModel| decry(oModel)}
	local bCommit 	:= {|oModel| crypt(oModel)}
	//Cria��o do objeto do modelo de dados
	local oModel := Nil

	//Cria��o da estrutura de dados utilizada na interface
	local oStZQ1 := FWFormStruct(1, "ZQ1")

	//Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New(MODEL_NAME, bPre, /*bPos*/,bCommit,/*bCancel*/) 

	//Atribuindo formul�rios para o modelo
	oModel:AddFields("FORMZQ1",/*cOwner*/,oStZQ1)

	//Setando a chave prim�ria da rotina
	oModel:SetPrimaryKey({'ZQ1_FILIAL','ZQ1_ID'})

	//Adicionando descri��o ao modelo
	oModel:SetDescription("Manuten��o "+cTitulo)

	//Setando a descri��o do formul�rio
	oModel:GetModel("FORMZQ1"):SetDescription("Formul�rio do Cadastro "+cTitulo)
Return (oModel)

Static Function ViewDef()
	local oModel := FWLoadModel(MODEL_NAME)

	//pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
	local oStZQ1 := FWFormStruct(2, "ZQ1")
	local oView := Nil

	//Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formul�rios para interface
	oView:AddField(VIEW_NAME, oStZQ1, "FORMZQ1")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	//Colocando t�tulo do formul�rio
	oView:EnableTitleView(VIEW_TABELA, 'Dados do Grupo de Produtos' )  

	//For�a o fechamento da janela na confirma��o
	oView:SetCloseOnOk({||.F.})

	//O formul�rio da interface ser� colocado dentro do container
	oView:SetOwnerView(VIEW_NAME, "TELA")
return (oView)


/*Auxiliares */
User Function MOD1Leg()
	local aLegenda := {}
	//Monta as cores
	// AADD(aLegenda,{"BR_VERDE",      "Original"  })
	// AADD(aLegenda,{"BR_VERMELHO",   "N�o Original"})
	//BrwLegenda("Grupo de Produtos", "Procedencia", aLegenda)
Return

static function crypt(oModel)
	local lRet 			:= .T.
	local oModel 		:= FWModelActive()
	local oView			:= FwViewActive()
	local cOrig			:= ""
	local cCrypt		:= ""
	if !empty( cOrig :=  oModel:GetModel(MODEL_NAME):GetValue('CAMPO') )
		cCrypt := WebEncript(Encode64( cOrig , .F. )) 
		if !empty(cCrypt)
			oModel:GetModel(MODEL_NAME):SetValue('CAMPO', cCrypt)
		endif
	endif
return(nil)

static function decry(oModel)
	local lRet 			:= .T.
	local oModel 		:= FWModelActive()
	local oView			:= FwViewActive()
	local cOrig			:= ""
	local cDecry		:= ""
	if !empty( cOrig :=  oModel:GetModel(MODEL_NAME):GetValue('CAMPO') )
		cDecry := WebEncript(Decode64( cOrig , .T. ) )
		if !empty(cDecry)
			oModel:GetModel(MODEL_NAME):SetValue('CAMPO', cDecry)
		endif
	endif
return(lRet)