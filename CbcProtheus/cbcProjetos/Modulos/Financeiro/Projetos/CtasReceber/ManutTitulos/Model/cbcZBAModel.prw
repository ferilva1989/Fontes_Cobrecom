#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'cbcManutTit.ch'

user function cbcManTi()
	BrowseDef()
return(nil)


static function BrowseDef()
	local cFiltro		:= ""
	local oBrw		:= nil
	private oFont 	:= TFont():New( "Arial", , -12, .T.)
	oBrw := FWMBrowse():New()
	oBrw:SetAlias('ZBA')
	oBrw:SetDescription('Manutenção de Titulos a Receber')
	cFiltro +=	"!Empty(ZBA_DTREL)"
	oBrw:SetFilterDefault( cFiltro )
	oBrw:SetMenuDef("cbcZBAModel")
	defLegenda(@oBrw, .F.)
	oBrw:Activate()
return(oBrw)


static function ModelDef()
	local oStruZBA := FWFormStruct( 1, 'ZBA' )
	local oModel
	oModel := MPFormModel():New('COMPZBA' )
	oModel:AddFields( 'ZBAMASTER', /*cOwner*/, oStruZBA)
	
	oModel:SetPrimaryKey( {'ZBA_FILIAL', 'ZBA_PREFIX', 'ZBA_NUM', 'ZBA_PARC',;
		'ZBA_TIPO', 'ZBA_CLI', 'ZBA_LOJA', 'ZBA_NROREL', 'ZBA_OPER' } )
	
	oModel:SetDescription( 'Manutenção de Titulos a Receber' )
	oModel:GetModel( 'ZBAMASTER' ):SetDescription( 'Manutenção de Titulos a Receber' )
return (oModel)


static function ViewDef()
	local oModel 		:= FWLoadModel( 'cbcZBAModel' )
	local oStruZBA 	:= FWFormStruct( 2, 'ZBA' )
	local oView		:= nil
	
	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_ZBA', oStruZBA, 'ZBAMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_ZBA', 'TELA' )
return (oView)


static function MenuDef()
	local aRotina := {}
	// ADD OPTION aRotina TITLE 'Gerar' 		ACTION 'U_cbcMarkZBA()' 						OPERATION 3 					ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' 	ACTION 'VIEWDEF.cbcZBAModel' 					OPERATION MODEL_OPERATION_VIEW 	ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir' 	ACTION 'U_cbcZBARelat()' 						OPERATION 8 					ACCESS 0
	ADD OPTION aRotina TITLE 'Legendas' 	ACTION 'StaticCall(cbcZBAModel,defLegenda,,.T.)' 	OPERATION 5 					ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir' 		ACTION 'StaticCall(cbcZBAModel,excluir)' 		OPERATION MODEL_OPERATION_DELETE ACCESS 0
return(aRotina)


static function excluir()
	
	local oManutTit		:= nil
	local aParamBox		:= {}
	local aRet			:= {}
	local cNroRel			:= ''
	
	aAdd(aParamBox,{1,'Nro.Relatorio' ,space(TamSx3('ZBA_NROREL')[1]),PesqPict('ZBA','ZBA_NROREL' ),'', '','',80,.T.})
	if ParamBox(aParamBox,'Excluir Relatorio',@aRet)
		cNroRel := Alltrim(aRet[1])
		oManutTit := cbcTitManut():newcbcTitManut()
		if !oManutTit:delRelat(cNroRel):isOk()
			Help( ,, 'Help','Erro', oManutTit:getMsgErr(), 1, 0 )
		else
			MsgInfo('Movimento Cancelado', 'Sucesso')
		endif
		FreeObj(oManutTit)
	endif
	
return(nil)


static function defLegenda(oBrw, lShow)
	local aLegenda	:= {}
	local nX			:= 0
	default lShow		:= .F.
	
	AAdd(aLegenda, {"BR_AMARELO" 		,'BAIXAR E DEBITAR PROTESTO'})
	AAdd(aLegenda, {"BR_AZUL" 			,'PRORROGACAO'})
	AAdd(aLegenda, {"BR_AZUL_CLARO"		,'DESCONTO'})
	AAdd(aLegenda, {"BR_LARANJA"		,'SUBSTITUIR'})
	AAdd(aLegenda, {"BR_VERDE"			,'BAIXAR'})
	AAdd(aLegenda, {"BR_VERDE_ESCURO"	,'BAIXAR DEPOSITO'})
	AAdd(aLegenda, {"BR_VERMELHO"		,'BAIXAR E DEBITAR'})
	AAdd(aLegenda, {"BR_MARRON_OCEAN"	,'BAIXAR COM CHEQUE'})
	AAdd(aLegenda, {"BR_VIOLETA"		,'BAIXAR E DEBITAR DEP. ITU'})
	AAdd(aLegenda, {"BR_PINK"			,'BAIXAR E DEBITAR NCC'})
	AAdd(aLegenda, {"BR_BRANCO"		,'DESC. NÃO DEBITAR'})
	AAdd(aLegenda, {"BR_CINZA"			,'BAIXAR DEP. NAO AUTORIZADO'})
	
	if lShow
		BrWLegenda("Manutenção de Titulos", "Status", aLegenda)
	else
		for nX := 1 to len(aLegenda)
			oBrw:AddLegend( "alltrim(ZBA_OPER) == '" + aLegenda[nX,2]+ "'" , aLegenda[nX,1], aLegenda[nX,2])
		next nX
	endif
return (nil)
