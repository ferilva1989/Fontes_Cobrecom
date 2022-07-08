#include "totvs.ch"
#include "fwmvcdef.ch"

*************************************
User Function BROWCLIENT()
	*************************************
	//Função que permite consultar a tabela SA1 Contem as praças dos bancos
	Local oBrw
	Local cFiltro
	Private oFont 		:= TFont():New( "Arial", , -12, .T.)

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA

	//Instaciamento
	oBrw := FWMBrowse():New()
	SET DELETED ON 

	//tabela que sera utilizada
	oBrw:SetAlias("SA1")

	//fonte utilizada
	oBrw:SetFontBrowser(oFont)

	//Titulo
	oBrw:SetDescription( "Cadastro de Clientes" )

	// Definir os campos que aparecem 

	oBrw:SetOnlyFields({'A1_COD', 'A1_LOJA','A1_CGC','A1_NOME','A1_NREDUZ','A1_END','A1_MUN','A1_EST','A1_BAIRRO','A1_CEP','A1_ENDCOB','A1_MUNC','A1_ESTC',;
	'A1_BAIRROC','A1_CEPC','A1_DDD','A1_TEL'} )

	// Definição do filtro de aplicacao
	//cFiltro +=	" !DELETED()"
	//oBrw:SetFilterDefault( cFiltro )

	//Menu def a ser utilizado
	oBrw:SetMenuDef("BROWCLIENTE")

	//ativa
	oBrw:Activate()

	Return      

	**********************************
Static Function MenuDef()
	**********************************

	Local aRotina := {}

	ADD OPTION aRotina TITLE '' 	ACTION '' OPERATION 2 ACCESS 0

Return aRotina 