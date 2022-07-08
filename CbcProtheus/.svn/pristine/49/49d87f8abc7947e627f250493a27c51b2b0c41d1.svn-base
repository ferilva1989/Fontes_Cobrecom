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

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro de Autor/Interprete
	oBrowse:SetAlias("ZQ1")

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo)

	//Legendas
	//oBrowse:AddLegend( "ALIAS->CAMPO == '1'", "GREEN", "Original" )
	//oBrowse:AddLegend( "ALIAS->CAMPO == '0'", "RED",   "Não Original" )

	//Ativa a Browse
	oBrowse:Activate()

	RestArea(aArea)
Return Nil

Static Function MenuDef()
	local aRot := {}
	local cAction := 'VIEWDEF.'+ MODEL_NAME

	//Adicionando opções
	ADD OPTION aRot TITLE 'Visualizar' ACTION  cAction OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Incluir'    ACTION cAction OPERATION MODEL_OPERATION_INSERT 	ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    ACTION cAction OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Excluir'    ACTION cAction OPERATION MODEL_OPERATION_DELETE 	ACCESS 0 //OPERATION 5
	//ADD OPTION aRot TITLE 'Legenda'    ACTION 'u_MOD1Leg'     OPERATION 6                      ACCESS 0 //OPERATION X

Return (aRot)

Static Function ModelDef()
	local bPre 		:= {|oModel| decry(oModel)}
	local bCommit 	:= {|oModel| crypt(oModel)}
	//Criação do objeto do modelo de dados
	local oModel := Nil

	//Criação da estrutura de dados utilizada na interface
	local oStZQ1 := FWFormStruct(1, "ZQ1")

	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New(MODEL_NAME, bPre, /*bPos*/,bCommit,/*bCancel*/) 

	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMZQ1",/*cOwner*/,oStZQ1)

	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({'ZQ1_FILIAL','ZQ1_ID'})

	//Adicionando descrição ao modelo
	oModel:SetDescription("Manutenção "+cTitulo)

	//Setando a descrição do formulário
	oModel:GetModel("FORMZQ1"):SetDescription("Formulário do Cadastro "+cTitulo)
Return (oModel)

Static Function ViewDef()
	local oModel := FWLoadModel(MODEL_NAME)

	//pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SBM_NOME|SBM_DTAFAL|'}
	local oStZQ1 := FWFormStruct(2, "ZQ1")
	local oView := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)

	//Atribuindo formulários para interface
	oView:AddField(VIEW_NAME, oStZQ1, "FORMZQ1")

	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)

	//Colocando título do formulário
	oView:EnableTitleView(VIEW_TABELA, 'Dados do Grupo de Produtos' )  

	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.F.})

	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView(VIEW_NAME, "TELA")
return (oView)


/*Auxiliares */
User Function MOD1Leg()
	local aLegenda := {}
	//Monta as cores
	// AADD(aLegenda,{"BR_VERDE",      "Original"  })
	// AADD(aLegenda,{"BR_VERMELHO",   "Não Original"})
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