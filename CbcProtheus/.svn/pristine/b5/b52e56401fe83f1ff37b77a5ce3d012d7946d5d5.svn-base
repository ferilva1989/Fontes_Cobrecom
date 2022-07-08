#include "totvs.ch"
#include "rwmake.ch"
#include "fwmvcdef.ch"
#include "portalcobrecom.ch"

#define MVC_MAIN_ID       "CadUsrPort"
#define MVC_MODEL_ID      "mUsrPort"
#define MVC_VIEW_ID       "vUsrPort"
#define MVC_TITLE         "Cadastro de Usuários do Portal Cobrecom"


/*/{Protheus.doc} CadUsrPort

Cadastro de Usuários do Portal Cobrecom

@author victorhugo
@since 22/02/2016
@history 10/02/2017,LEO,Restrição de acesso apenas para usuario administrador
/*/
user function CadUsrPort()

	local oBrowse  		:= FwMbrowse():new()
	local oAcl			:= cbcAcl():newcbcAcl()
	private nOperation  := 0
	private oUtils 		:= LibUtilsObj():newLibUtilsObj()
	private bResetPsw	:= {|| createPsw("reset") }

	if !oAcl:aclValid('CadUsrPort')
		Alert( oAcl:getAlert() )
	else
		oBrowse:setAlias("ZP1") 
		oBrowse:setDescription(MVC_TITLE)
		oBrowse:addLegend("ZP1_GRUPO == '"+USER_ADMINISTRATOR+"'", "RED", "Administradores")
		oBrowse:addLegend("ZP1_GRUPO == '"+USER_SELLER+"'", "GREEN", "Representantes")
		oBrowse:addLegend("ZP1_GRUPO == '"+USER_PROSPECT+"'", "WHITE", "Prospects")
		oBrowse:addLegend("ZP1_GRUPO == '"+USER_CUSTOMER+"'", "PINK", "Clientes")
		oBrowse:addLegend("ZP1_GRUPO == '"+USER_ASSISTANT+"'", "YELLOW", "Assistentes")
		oBrowse:addLegend("ZP1_GRUPO == '"+USER_SUPERVISOR+"'", "ORANGE", "Supervisores")
		oBrowse:addLegend("ZP1_GRUPO == '"+USER_MANAGER+"'", "BROWN", "Gerentes")
		oBrowse:addLegend("ZP1_GRUPO == '"+USER_DIRECTOR+"'", "BLACK", "Diretores")  
		oBrowse:activate()
	endif
	FreeObj(oAcl)
return

/**
* Opções do browse
*/
static function menuDef()

	local aOpcoes 	  := {}
	local cViewId 	  := "viewDef."+MVC_MAIN_ID
	local cResetPsw	  := "Eval(bResetPsw)"

	ADD OPTION aOpcoes TITLE "Pesquisar"   	   ACTION "PesqBrw" 	OPERATION 1 ACCESS 0
	ADD OPTION aOpcoes TITLE "Visualizar"  	   ACTION cViewId   	OPERATION 2 ACCESS 0
	ADD OPTION aOpcoes TITLE "Incluir"     	   ACTION cViewId   	OPERATION 3 ACCESS 0
	ADD OPTION aOpcoes TITLE "Alterar"     	   ACTION cViewId   	OPERATION 4 ACCESS 0
	ADD OPTION aOpcoes TITLE "Excluir"     	   ACTION cViewId   	OPERATION 5 ACCESS 0
	ADD OPTION aOpcoes TITLE "Imprimir"   	   ACTION cViewId   	OPERATION 8 ACCESS 0
	ADD OPTION aOpcoes TITLE "Copiar"     	   ACTION cViewId   	OPERATION 9 ACCESS 0
	ADD OPTION aOpcoes TITLE "Redefinir Senha" ACTION cResetPsw     OPERATION 2 ACCESS 0

return aOpcoes

/**
* Modelagem
*/
static function modelDef()

	local bValidModel 	:= {|oModel| validModel(oModel)}    
	local oModel 		:= MpFormModel():new(MVC_MODEL_ID, nil, bValidModel)
	local oZP1   		:= FwFormStruct(MVC_MODEL_STRUCT, "ZP1")   

	oModel:setDescription(MVC_TITLE)
	oModel:addFields("ZP1", nil, oZP1)
	oModel:getModel("ZP1"):setDescription(MVC_TITLE)     
	oModel:setPrimaryKey({"ZP1_FILIAL","ZP1_CODIGO"})
return oModel

/**
* Interface Visual
*/
static function viewDef()

	local oView  := FwFormView():new()
	local oModel := FwLoadModel(MVC_MAIN_ID)
	local oZP1   := FwFormStruct(MVC_VIEW_STRUCT, "ZP1")

	oView:setModel(oModel)
	oView:addField("ZP1", oZP1, "ZP1")    

return oView

/**
* Validação do Model
*/
static function validModel(oActiveModel)
	local lOk 		:= .T.
	local cRespCode	:= '' 
	local oSql    	:=  nil    
	
	nOperation := oActiveModel:getOperation()

	if nOperation == MODEL_OPERATION_DELETE
	
		cRespCode	:= oActiveModel:GetValue('ZP1','ZP1_CODIGO')
		oSql  		:= LibSqlObj():newLibSqlObj()

		if oSql:exists("ZP5", "%ZP5.XFILIAL%  AND ( ZP5_RESPON = '" + cRespCode + "'" + " OR ZP5_APROVA = '" + cRespCode + "')" ) 
			lOk := .F.
			Help( ,, 'Help',, 'Deleção não permitida, usuario tem pedidos no portal!', 1, 0 )
		endIf

		FreeObj(oSql)
		
	endif

return lOk

/**
* Validação dos Campos do Cadastro de Usuários do Portal
*/
user function VldUsrPort(cCampo) 

	local lOk          := .T.
	local aArea        := GetArea()
	local oActiveModel := FwModelActive()
	local oModel 	   := oActiveModel:getModel("ZP1")

	cCampo := Upper(AllTrim(cCampo))

	if (cCampo == "ZP1_LOGIN")
		lOk := vldLogin(@oModel)
	elseIf (cCampo == "ZP1_GRUPO")
		lOk := vldGrupo(@oModel)
	elseIf (cCampo $ "ZP1_CODPRO,ZP1_LOJPRO")
		lOk := vldProspect(@oModel)
	elseIf (cCampo $ "ZP1_CODCLI,ZP1_LOJCLI")
		lOk := vldCliente(@oModel)
	elseIf (cCampo == "ZP1_CODVEN")
		lOk := vldVendedor(@oModel)
	elseIf (cCampo == "ZP1_CODERP")
		lOk := vldCodErp(@oModel)				
	endIf

	RestArea(aArea)

return lOk

/**
* Validação do Login do Usuário
*/
static function vldLogin(oModel)

	local lOk     := .T.
	local cCodigo := oModel:getValue("ZP1_CODIGO") 
	local cLogin  := oModel:getValue("ZP1_LOGIN")
	local oSql    := LibSqlObj():newLibSqlObj()

	cLogin := AllTrim(Lower(cLogin))

	if oSql:exists("ZP1", "%ZP1.XFILIAL% AND ZP1_LOGIN = '"+cLogin+"' AND ZP1_CODIGO != '"+cCodigo+"'") 
		lOk := .F.
		MsgBox("Login já cadastrado", "Atenção", "ALERT") 
	endIf

return lOk

/**
* Validação do Grupo do Usuário
*/
static function vldGrupo(oModel)

	local lOk     	:= .T.
	local cGrupo  	:= oModel:getValue("ZP1_GRUPO") 
	local oSql    	:= LibSqlObj():newLibSqlObj()

	oSql:newTable("SX5", "X5_DESCRI NOME_GRUPO", "%SX5.XFILIAL% AND X5_TABELA = '_1' AND X5_CHAVE = '"+cGrupo+"'")

	if oSql:hasRecords()		
		oModel:setValue("ZP1_NOMGRP", oUtils:padrSx3(oSql:getValue("NOME_GRUPO"), "ZP1_NOMGRP")) 
		limpaCamposGrupo(@oModel)
	else
		lOk := .F.
		MsgBox("Grupo inválido", "Atenção", "ALERT") 
	endIf

	oSql:close()

return lOk

/**
* Limpa o conteúdo dos campos que possuem relação com o grupo selecionado
*/
static function limpaCamposGrupo(oModel)

	local nI 		:= 0
	local cCampo	:= "" 
	local aCampos	:= {"ZP1_CODPRO","ZP1_LOJPRO","ZP1_CODCLI","ZP1_LOJCLI","ZP1_NOMCLI","ZP1_CODVEN","ZP1_NOMVEN"} 

	for nI := 1 to Len(aCampos)
		cCampo := aCampos[nI]
		oModel:loadValue(cCampo, "") 
	next nI		

return

/**
* Validação do Código de Prospect do Usuário
*/
static function vldProspect(oModel)

	local lOk      := .T.
	local cCodigo  := oModel:getValue("ZP1_CODPRO")
	local cLoja    := oModel:getValue("ZP1_LOJPRO")	
	local oSql     := LibSqlObj():newLibSqlObj()

	if (Empty(cCodigo) .or. Empty(cLoja))
		return .T.
	endIf

	oSql:newTable("SUS", "US_NOME NOME", "%SUS.XFILIAL% AND US_COD = '"+cCodigo+"' AND US_LOJA = '"+cLoja+"'")

	if oSql:hasRecords()
		oModel:setValue("ZP1_NOMCLI", oUtils:padrSx3(oSql:getValue("NOME"), "ZP1_NOMCLI"))  
	else
		lOk := .F.
		MsgBox("Prospect inválido", "Atenção", "ALERT") 
	endIf

	oSql:close()

return lOk

/**
* Validação do Código de Cliente do Usuário
*/
static function vldCliente(oModel)

	local lOk      := .T.
	local cCodigo  := oModel:getValue("ZP1_CODCLI")
	local cLoja    := oModel:getValue("ZP1_LOJCLI")	
	local oSql     := LibSqlObj():newLibSqlObj()

	if (Empty(cCodigo) .or. Empty(cLoja))
		return .T.
	endIf

	oSql:newTable("SA1", "A1_NOME NOME", "%SA1.XFILIAL% AND A1_COD = '"+cCodigo+"' AND A1_LOJA = '"+cLoja+"'")

	if oSql:hasRecords()
		oModel:setValue("ZP1_NOMCLI", oUtils:padrSx3(oSql:getValue("NOME"), "ZP1_NOMCLI"))   
	else
		lOk := .F.
		MsgBox("Cliente inválido", "Atenção", "ALERT") 
	endIf

	oSql:close()

return lOk

/**
* Validação do Código de Vendedor do Usuário
*/
static function vldVendedor(oModel)

	local lOk      := .T.
	local cCodigo  := oModel:getValue("ZP1_CODVEN")
	local oSql     := LibSqlObj():newLibSqlObj()

	if Empty(cCodigo)
		return .T.
	endIf

	oSql:newTable("SA3", "A3_NOME NOME", "%SA3.XFILIAL% AND A3_COD = '"+cCodigo+"'")

	if oSql:hasRecords()
		oModel:setValue("ZP1_NOMVEN", oUtils:padrSx3(oSql:getValue("NOME"), "ZP1_NOMVEN"))  
	else
		lOk := .F.
		MsgBox("Vendedor inválido", "Atenção", "ALERT") 
	endIf

	oSql:close()

return lOk

/**
* Validação do Código do Usuário no Protheus
*/
static function vldCodErp(oModel)

	local lOk	  := .T.
	local cCodErp := oModel:getValue("ZP1_CODERP") 

	if !Empty(cCodErp)
		lOk := UsrExist(cCodErp)
	endIf

return lOk

/**
 * Criação/Redefinição de Senha
 */
static function createPsw(cOption)
	
	local lOk	    := .F.
	local lReset    := .F.
	local lCreate   := .F.
	local cLabel    := ""
	local cUserId   := ZP1->ZP1_CODIGO
	local cName     := AllTrim(ZP1->ZP1_NOME)
	local cEmail    := AllTrim(ZP1->ZP1_EMAIL)
	local oService  := CbcAuthService():newCbcAuthService()
	default cOption := "create"
	
	lReset  := (cOption == "reset")
	lCreate := (cOption == "create")
	cLabel  := if ( lReset, "Redefinindo senha...", "Gerando senha ..." )

	if lReset .and. !MsgYesNo("Confirma redefinição da senha de " + cName + " ?")
		return .F.
	endIf
	
	FwMsgRun(, { || lOk := oService:createPassword(cUserId) }, "Aguarde", cLabel)
	
	if lOk
		MsgInfo("Uma nova senha foi gerada e enviada para o e-mail " + cEmail)
	else
		Alert(oService:getErrorMessage())
	endIf

return lOk

/**
 * Ponto de Entrada
 */
user function mUsrPort()
	
	local oAuthSrv := CbcAuthService():newCbcAuthService()
	local aParams  := PARAMIXB
	local cEvent   := Upper(AllTrim(aParams[2]))		
	
	if (cEvent == "MODELCOMMITNTTS" .and. nOperation == MODEL_OPERATION_INSERT)
		createPsw()
	endIf
	
return .T.