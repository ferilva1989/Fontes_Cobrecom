#include 'protheus.ch'
#Include 'FWMVCDef.ch'


class cbcstp01invent 
	data oMainCtrl
	method newcbcstp01invent() constructor 
	method setup()
endclass


method newcbcstp01invent(oCtrl) class cbcstp01invent
	default oCtrl := cbcCtrInvent():newcbcCtrInvent()
	::oMainCtrl := oCtrl 
return(self)


method setup(oNewPag) class cbcstp01invent
	local dDtIn		:= Ctod(' / / ')
	local dDtFi		:= Ctod(' / / ')
	oNewPag:SetStepDescription("CRIAR INVENTÁRIO")
	oNewPag:SetConstruction({|Panel|cria_pg(Panel,@dDtIn,@dDtFi)})
	oNewPag:SetNextAction({||valida_pg(@dDtIn,@dDtFi,self)})
	oNewPag:SetCancelAction({||cancela()})
return(self)


static function cria_pg(oPanel,dDtIn, dDtFi)
	local oSayDtIn	:= nil
	local oGetDtIn	:= nil // ZZB_DTINIC
	local oSayDtFi	:= nil
	local oGetDtFi	:= nil // ZZB_DTFINA	
	local cMaskDt	:= PesqPict( 'ZZB', 'ZZB_DTINIC' )	
		
	// ZZB_ETAPA := "C"
	
	oSayDtIn := TSay():New(10,10,{||'Data DE:'},oPanel,,,,,,.T.,,,200,20)	
	oGetDtIn := TGet():New( 20,10,{|u| if( PCount() > 0, dDtIn := u, dDtIn ) } ,oPanel,096,009,cMaskDt,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,, )
	oSayDtFi := TSay():New(40,10,{||'Data ATE:'},oPanel,,,,,,.T.,,,200,20)
	oGetDtFi := TGet():New( 50,10,{|u| if( PCount() > 0, dDtFi := u, dDtFi ) },oPanel,096,009,cMaskDt,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,,,,, )
return(nil)


static function valida_pg(dDtIn, dDtFi, oSelf)
	local lRet	:= .F.
	local aRet	:= {}
	if lRet := MsgNoYes('Confirma a criação de um novo inventário ? no periodo de: ' + dtoc(dDtIn) + ' até: ' + dtoc(dDtFi))
		// TODO verificar/validar duplicidade do periodo - 
		aRet := createInvent(dDtIn, dDtFi, oSelf)
		if ! (lRet := aRet[1])
			MsgAlert( aRet[2] )
		endif
	endif
return(lRet)


static function cancela()
	local lRet	:= .T.
	Alert("Cancelou primeira Etapa")
return(lRet)


static function createInvent(dDtIn, dDtFi, oSelf)
	local oModel 	:= FWLoadModel('cbcInventModel')
	local cIDModel	:= 'ZZB_MASTER'
	local cIDGRID	:= 'ZZC_GRID'
	local cIdZZB	:= ''
	local lRet		:= .F.
	local aErro		:= {}
	local cMsgErr	:= ''
	local oMdlGrid	:= oModel:getModel(cIDGRID)
	Local oStatic   := IfcXFun():newIfcXFun()
	local oDoc		:= JsonObject():new()
	
	
	oModel:SetOperation(MODEL_OPERATION_INSERT)
	oModel:Activate()	
	oModel:SetValue( cIDModel,'ZZB_FILIAL'	, FwFilial())
	oModel:SetValue( cIDModel,'ZZB_DTINIC'	, dDtIn)
	oModel:SetValue( cIDModel,'ZZB_DTFINA'	, dDtFi)
	oModel:SetValue( cIDModel,'ZZB_ETAPA'	, 'C')

	cIdZZB := oModel:GetValue(cIDModel,'ZZB_ID')
	oModel:SetValue(cIDGRID, 'ZZC_FILIAL'	,FwFilial())
	oModel:SetValue(cIDGRID, 'ZZC_ID'		,cIdZZB )
	oModel:SetValue(cIDGRID, 'ZZC_ITEM'		,'001')
	oModel:SetValue(cIDGRID, 'ZZC_TIPO'		,'L')
	
	//Chamada para preparar os dados do inventário para ser incluido no Couch
	oStatic:sP(5):callStatic('cbcInventModel','incluir', cIdZZB, FwFilial(), dDtIn, '', 'C')

	if ! (lRet := oModel:VldData())
		aErro := oModel:GetErrorMessage()
		cMsgErr := "Mensagem do Erro:" + ' [ ' + AllToChar(aErro[6]) + ' ]'
		AutoGrLog(cMsgErr)
	else
		FWFormCommit(oModel)
	endIf
	
	FreeObj(oDoc)
	oModel:DeActivate()
return( {lRet, cMsgErr} )
