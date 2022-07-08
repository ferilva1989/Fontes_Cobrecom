#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

user function cbcZATIni()
	BrowseDef()
return(nil)

static function BrowseDef()
	local cFiltro	:= ""
	local oBrw		:= nil
	private oFont 	:= TFont():New( "Arial", , -12, .T.)
	
	oBrw := FWMBrowse():New()
	oBrw:SetAlias('ZAT')
	oBrw:SetDescription('Usuários Sistema Boletos')
	oBrw:SetMenuDef("cbcZATModel")
	defLegenda(@oBrw, .F.)
	oBrw:Activate()
return(oBrw)

static function ModelDef()
	local oStruZAT 	:= FWFormStruct( 1, 'ZAT' )
	local oModel	:= nil
	
	oModel := MPFormModel():New('COMPZAT',,,{||vldModel(self)})
	oModel:AddFields( 'ZATMASTER', /*cOwner*/, oStruZAT)
	oModel:SetPrimaryKey({'ZAT_FILIAL', 'ZAT_PESSOA', 'ZAT_CODIGO'})
	oModel:SetDescription( 'Usuários Sistema Boletos' )
	oModel:GetModel( 'ZATMASTER' ):SetDescription( 'Usuários Sistema Boletos' )
return (oModel)

static function ViewDef()
	local oModel 		:= FWLoadModel( 'cbcZATModel' )
	local oStruSC5 		:= FWFormStruct( 2, 'ZAT' )
	local oView			:= nil
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_ZAT', oStruSC5, 'ZATMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_ZAT', 'TELA' )
return (oView)

static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Incluir'    	ACTION 'VIEWDEF.cbcZATModel' OPERATION MODEL_OPERATION_INSERT 	ACCESS 0 //OPERATION 3
	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.cbcZATModel' OPERATION MODEL_OPERATION_VIEW 	ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'      ACTION 'VIEWDEF.cbcZATModel' OPERATION MODEL_OPERATION_UPDATE 	ACCESS 0 //OPERATION 4
return(aRotina)

static function defLegenda(oBrw, lShow)
	default lShow := .F.
return (nil)

static function vldModel(oModel)
	local lVld	:= .F.
	if(lVld := (vldUser(@oModel)))
		if (lVld := vldSenha(@oModel))
			lVld := FwFormCommit(oModel)
		endif
	endif
return(lVld)

static function vldUser(oModel)
	local lRet		:= .F.
	local oSql		:= LibSqlObj():newLibSqlObj()
	local nTam		:= 0
	local cMyCnpj 	:= SubStr(FWArrFilAtu( FWGrpCompany(), FWCodEmp() + FWUnitBusiness() + FwFilial() )[18],1,8)
	local cId		:= oModel:GetValue( 'ZATMASTER','ZAT_CODIGO')
	local cPessoa	:= oModel:GetValue( 'ZATMASTER','ZAT_PESSOA')
	
	if(oModel:GetOperation() <> 3 .and. oModel:GetOperation() <> 4)
		lRet := .T.
	else	
		if!(lRet := (cPessoa $ "FJ"))
			oModel:SetErrorMessage('ZATMASTER', 'ZAT_CODIGO' , 'ZATMASTER' , 'ZAT_CODIGO' , "Erro", 'Tipo escolhido inválido.', 'Informar (F)ísica ou (J)uridica!') 
		else
			iif(cPessoa == 'F', nTam := 11, nTam := 8)
			if !(lRet := (len(AllTrim(cId)) == nTam))
				oModel:SetErrorMessage('ZATMASTER', 'ZAT_CODIGO' , 'ZATMASTER' , 'ZAT_CODIGO' , "Erro", 'Tamanho do Código inválido.', 'Tipo: ' + cPessoa + ' necessita código com tamanho: ' + cValtoChar(nTam))  
			else						
				oSql:newTable("SA1", "*", "%SA1.XFILIAL% AND A1_CGC LIKE '"+AllTrim(cId)+"%' AND A1_MSBLQL <> '1' AND A1_PESSOA = '" + cPessoa + "'")
				if!(lRet := (oSql:hasRecords() .or. (AllTrim(cId) == cMyCnpj)))
					oModel:SetErrorMessage('ZATMASTER', 'ZAT_CODIGO' , 'ZATMASTER' , 'ZAT_CODIGO' , "Erro", 'Cliente não Localizado', 'Cliente não localizado no cadastro!') 
				else
					if(oModel:GetOperation() == 3)
						oSql:close()
						FreeObj(oSql)
						oSql	:= LibSqlObj():newLibSqlObj()
						oSql:newTable("ZAT", "*", "%ZAT.XFILIAL% AND ZAT_CODIGO = '"+AllTrim(cId)+"'") 
						if(oSql:hasRecords())
							lRet := .F.
							oModel:SetErrorMessage('ZATMASTER', 'ZAT_CODIGO' , 'ZATMASTER' , 'ZAT_CODIGO' , "Erro", 'Cliente Já Cadastrado', 'Cliente já está cadastrado!')
						endif
					endif
				endif
				oSql:close()
			endif
		endif
	endif
	FreeObj(oSql)	
return(lRet)

static function vldSenha(oModel)
	local lRet	:= .F.
	local nTam	:= 0
	local cSenha:= oModel:GetValue( 'ZATMASTER','ZAT_SENHA')
	
	if(oModel:GetOperation() <> 3 .and. oModel:GetOperation() <> 4)
		lRet := .T.
	else
		if!(lRet := (Len(AllTrim(cSenha)) >= 6))
			oModel:SetErrorMessage('ZATMASTER', 'ZAT_SENHA' , 'ZATMASTER' , 'ZAT_SENHA' , "Erro", 'Tamanho inválido', 'Senha necessita no mínimo 6 caracteres')
		else
			nTam := len(AllTrim(cSenha))
			cSenha	:= StrTran(cSenha, " ", "")
			cSenha	:= StrTran(cSenha, "'", "")
			cSenha	:= StrTran(cSenha, "-", "")
			if!(lRet := (len(cSenha) == nTam))
				oModel:SetErrorMessage('ZATMASTER', 'ZAT_SENHA' , 'ZATMASTER' , 'ZAT_SENHA' , "Erro", 'Caracteres inválidos', 'Senha contem caracteres inválidos')
			endif
		endif
	endif
return(lRet)