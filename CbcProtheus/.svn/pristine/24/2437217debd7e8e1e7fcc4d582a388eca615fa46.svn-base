#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

user function cbcGFEA118()
    private oBrowse115
    private CCHAVEREL   := ''
	oBrowse115 := FWMarkBrowse():New()
	oBrowse115:SetAlias("GXG")
	oBrowse115:SetMenuDef("cbcGFEA118")
	//oBrowse115:SetFieldMark("GXG_MARKBR")
	oBrowse115:SetDescription("Auditoria de Documento de Frete")
	oBrowse115:SetFilterDefault("(GXG_ORIGEM == '2' .Or. GXG_ORIGEM == 'W' ) .And. (GXG_AUDITS == 'Z' .Or. GXG_AUDITS == 'W' ) ")
	oBrowse115:AddLegend("GXG_AUDITS == 'Z'", "GREEN", "Pendência")
	oBrowse115:AddLegend("GXG_AUDITS == 'W'", "RED",   "Rejeitado")
	oBrowse115:Activate()
return(Nil)


static function MenuDef()
    local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"         ACTION "AxPesqui"                          OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE "Visualizar"        ACTION "VIEWDEF.cbcGFEA118"                OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE "Liberar"           ACTION "StaticCall(cbcGFEA118,liberar)"    OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Rejeitar"          ACTION "StaticCall(cbcGFEA118,rejeitar)"   OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Voltar Analise"    ACTION "StaticCall(cbcGFEA118,voltar)"     OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Regras"            ACTION "u_cbcViewFrete()"    				OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Simular"           ACTION "u_cbcSimuFrete()"    				OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Imprimir"          ACTION "VIEWDEF.cbcGFEA118"                OPERATION 8 ACCESS 0
Return aRotina


static function ModelDef()
    local oModel     := Nil
    local oStructGXG := FWFormStruct(1,"GXG")
    local oStructGXH := FWFormStruct(1,"GXH")
	oStructGXH:SetProperty("GXH_NRIMP", MODEL_FIELD_INIT, {|a,b,c| FWInitCpo(a,b,c),lRetorno:= GXG->GXG_NRIMP,FWCloseCpo(a,b,c,.t.),lRetorno } )
	oModel := MPFormModel():New("GFEA118", /*bPre*/,/*{ |oX| GFEA115PS( oX ) }*//*bPost*/, /*bCommit*/, /*bCancel*/)
	oModel:AddFields("GFEA118_GXG", Nil, oStructGXG,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid("GFEA118_GXH","GFEA118_GXG",oStructGXH,/*bLinePre*/,/*{ | oX | GFE103BW( oX ) }*/,/*bLinePost*/,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:SetRelation("GFEA118_GXH",{{"GXH_FILIAL",'GXG_FILIAL'},{"GXH_NRIMP","GXG_NRIMP"}},"GXH_NRIMP+GXH_SEQ")
	oModel:GetModel("GFEA118_GXH"):SetDelAllLine(.T.)
	oModel:SetOptional("GFEA118_GXH", .T. )
return oModel


static function ViewDef()
    local oModel     := ModelDef()
    local oView      := Nil
    local oStructGXG := FWFormStruct(2,"GXG")
    local oStructGXH := FWFormStruct(2,"GXH")

	oStructGXG:SetProperty( "GXG_ALTER"  , MVC_VIEW_CANCHANGE ,.F.)
	oStructGXG:SetProperty( "GXG_ACAO"   , MVC_VIEW_CANCHANGE ,.F.)
	oStructGXG:RemoveField("GXG_MARKBR")
	oStructGXH:RemoveField("GXH_CNPJEM")
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "GFEA118_GXG" , oStructGXG )
	oView:AddGrid( "GFEA118_GXH" , oStructGXH )
	oView:CreateHorizontalBox( "MASTER" , 55 )
	oView:CreateHorizontalBox( "DETAIL" , 45 )
	oView:CreateFolder("IDFOLDER","DETAIL")
	oView:AddSheet("IDFOLDER","IDSHEET01","Doc Carga")
	oView:CreateHorizontalBox( "DETAILFAI"  , 100,,,"IDFOLDER","IDSHEET01" )
	oStructGXH:RemoveField("GXH_NRIMP")
	oView:AddIncrementField("GFEA118_GXH","GXH_SEQ")
	oView:SetOwnerView( "GFEA118_GXG" , "MASTER" )
	oView:SetOwnerView( "GFEA118_GXH" , "DETAILFAI" )
	oView:AddUserButton( 'Detalhar', 'MAGIC_BMP', {|oModel| DoMagic(FwFldGet("GXG_CTE"))} )
return oView


static function DoMagic(cChave) 
	local oJs    as object
	oJs := JsonObject():New()
	oJs:fromJson(GXG->GXG_JSMSG)	
	modal(htmlText(oJs))
	FreeObj(oJs)
return nil


static function voltar()
local oJs as object
	if GXG->GXG_AUDITS == 'W'
		if MsgYesNo( 'Voltar CTe para analise? ', 'Confirmar Opção' )
			oJs := JsonObject():New()
			oJs:fromJson(GXG->GXG_JSMSG)
			oJs['USR_LIB']  := UsrRetName(RetCodUsr())
			oJs['LIB_DTHR'] := dToS(Date()) + "_" + StrTran(Time(), ':', '-')
			if RecLock("GXG",.F.)
				GXG->GXG_AUDITS := 'Z'
				GXG->GXG_JSMSG  := oJs:toJSon()
				GXG->(MsUnlock())
			endif
			FreeObj(oJs)
		endif
	endif
return nil

static function rejeitar()
	local oJs as object
	if GXG->GXG_AUDITS == 'Z'
		if MsgYesNo( 'Confirma Rejeição? ', 'Confirmar Rejeição' )
			oJs := JsonObject():New()
			oJs:fromJson(GXG->GXG_JSMSG)
			oJs['USR_LIB']  := UsrRetName(RetCodUsr())
			oJs['LIB_DTHR'] := dToS(Date()) + "_" + StrTran(Time(), ':', '-')
			if RecLock("GXG",.F.)
				GXG->GXG_AUDITS := 'W'
				GXG->GXG_JSMSG  := oJs:toJSon()
				GXG->(MsUnlock())
			endif
			FreeObj(oJs)
		endif
	endif
return nil


static function liberar()
    local oJs as object
	if GXG->GXG_AUDITS == 'W'
		Help(NIL, NIL, "Auditoria de Frete",NIL, "CTe Rejeitado", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Mudar o Status para liberar"})
	else
		if MsgYesNo( 'Confirma liberação? ', 'Liberação Divergencia' )
			oJs := JsonObject():New()
			oJs:fromJson(GXG->GXG_JSMSG)
			oJs['USR_LIB']  := UsrRetName(RetCodUsr())
			oJs['LIB_DTHR'] := dToS(Date()) + "_" + StrTran(Time(), ':', '-')
			if RecLock("GXG",.F.)
				GXG->GXG_AUDITS := '1'
				GXG->GXG_EDISIT := '1'
				GXG->GXG_ORIGEM := '2'
				GXG->GXG_JSMSG  := oJs:toJSon()
				GXG->(MsUnlock())
			endif
			FreeObj(oJs)
		endif
	endif
return nil

static function modal(cHtml)
	local oModal 		as object
	local oContainer 	as object
	local oEdit  	    as object

    oModal  := FWDialogModal():New()       
    oModal:SetEscClose(.T.)
    oModal:setTitle("Auditoria de Frete")
    oModal:setSubTitle("Conferência")
     
    //Seta a largura e altura da janela em pixel
    oModal:setSize(200, 440)
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    oContainer 			:= TPanel():New(,,,oModal:getPanelMain() )
    oContainer:Align 	:= CONTROL_ALIGN_ALLCLIENT
	oEdit 				:= TSimpleEditor():New(0, 0, oContainer, 435, 130)
    oEdit:Load(cHtml) 
    // TSay():New(1,1,{|| "Teste "},oContainer,,,,,,.T.,,,30,20,,,,,,.T.) 
	oModal:Activate()
return oContainer


static function htmlText(oJ)
	local cHtml as character
	local nX    as numeric
	local cPic  as character
	local lMem  as logical

	cPic        :=  X3Picture('C5_TOTAL')
	cHtml 		:= ' <div style="font-size:18px">'
	lMem		:= len(oJ['INFO']['CALC_MEM']) > 0
	
	if lMem
		cHtml += ' <table border="1" cellpadding="1" cellspacing="1" style="width:500px"> '
		cHtml += ' <tbody> '
		cHtml += ' <tr> '
		cHtml += ' <td><strong>TRANSPORTADORA</strong></td> '
		cHtml += ' <td>' + oJ['INFO']['CALC_MEM'][1]['TRANSP'] + ' </td> '
		cHtml += ' </tr>
		cHtml += ' <tr> '
		cHtml += ' <td><strong>MOT.</strong></td> '
		cHtml += ' <td>' + oJ['MSG'] + ' </td> '
		cHtml += ' </tr>
		cHtml += ' <tr> '
		cHtml += ' <td><strong>ROTA</strong></td> '
		cHtml += ' <td>' + oJ['INFO']['CALC_MEM'][1]['ROTA'] + ' </td> '
		cHtml += ' </tr> '
		cHtml += ' </tbody> '
		cHtml += ' </table> '
	endif
	cHtml += ' <table border="1" cellpadding="1" cellspacing="1" style="width:500px"> '
	cHtml += ' <tbody> '
	cHtml += ' <tr> '
	cHtml += ' <td><strong>CHAVE_CTE</strong></td> '
	cHtml += ' <td>'+ oJ['INFO']['CALC_CTE']['CHV_CTE']+ '</td> '
	cHtml += ' </tr> '
	cHtml += ' </tbody> '
	cHtml += ' </table> '

	cHtml += ' <table border="1" cellpadding="1" cellspacing="1" style="width:677px"> '
	cHtml += ' <tbody> '
	cHtml += ' <tr> '
	cHtml += ' <td><strong>NOTAS:</strong></td> '
	cHtml += ' <td style="width:207px"> '
	cHtml += ' <table border="1" cellpadding="1" cellspacing="1" style="width:500px"> '
	cHtml += ' <tbody> '
	for nX := 1 to len(oJ['INFO']['CALC_CTE']['CHAVE_NFE'])
		cHtml += ' <tr> '
		cHtml += ' <td>' + oJ['INFO']['CALC_CTE']['CHAVE_NFE'][nX] + '</td>'
		cHtml += ' </tr> '
	next nX
	cHtml += ' </tbody> '
	cHtml += ' </table> '
	cHtml += ' <p>&nbsp;</p> '
	cHtml += ' </td> '
	cHtml += ' </tr> '
	cHtml += ' </tbody> '
	cHtml += ' </table> '
	cHtml += ' <table border="1" cellpadding="1" cellspacing="1" style="width:500px"> '
	cHtml += ' <tbody> '
	cHtml += ' <tr> '
	cHtml += ' <td><strong>TOTAL CTE</strong></td> '
	cHtml += ' <td>' + Alltrim(TRANSFORM(val(oJ['INFO']['CALC_CTE']['VALOR_FRETE']),cPic)) + '</td> '
	cHtml += ' <td><strong>TOTAL_TABELA</strong></td> '
	if lMem
		cHtml += ' <td>' + Alltrim(TRANSFORM(oJ['INFO']['CALC_MEM'][1]['TOTAL'],cPic)) + '</td> '
	endif
	cHtml += ' </tr> '
	cHtml += ' </tbody> '
	cHtml += ' </table> '
	cHtml += ' <table border="1" cellpadding="1" cellspacing="1" style="width:500px"> '
	cHtml += ' <tbody> '
	cHtml += ' <tr> '
	cHtml += ' <td><strong>COMP.CTE</strong></td> '
	cHtml += ' <td><strong>COMP.TABELA</strong></td> '
	cHtml += ' </tr> '
	cHtml += ' <tr> '
	cHtml += ' <td> '
	cHtml += ' <table border="1" cellpadding="1" cellspacing="1" style="width:500px"> '
	cHtml += ' <tbody> '
	ASort(oJ['INFO']['CALC_CTE']['COMP'],,,{|x,y| x['NOME'] < y['NOME']})
	for nX := 1 to len( oJ['INFO']['CALC_CTE']['COMP'])
		cHtml += ' <tr> '
		cHtml += ' <td> <strong>' + oJ['INFO']['CALC_CTE']['COMP'][nX]['NOME'] + ' </strong></td> '
		cHtml += ' <td>' + Alltrim(TRANSFORM(val(oJ['INFO']['CALC_CTE']['COMP'][nX]['VALOR']),cPic)) + '</td> '
		cHtml += ' </tr> '
	next nX
	cHtml += ' </tbody> '
	cHtml += ' </table> '
	cHtml += ' <p>&nbsp;</p> '
	cHtml += ' </td> '
	cHtml += ' <td> '
	cHtml += ' <table border="1" cellpadding="1" cellspacing="1" style="width:500px"> '
	cHtml += ' <tbody> '
	if lMem
		ASort(oJ['INFO']['CALC_MEM'][1]['CALCULAR']['AUDIT_CALC'][1]['FRETE_CALCULO'],,,{|x,y| x[1] < y[1]})
		for nX := 1 to len(oJ['INFO']['CALC_MEM'][1]['CALCULAR']['AUDIT_CALC'][1]['FRETE_CALCULO'])
			cHtml += ' <tr> '
			cHtml += ' <td> <strong>' + oJ['INFO']['CALC_MEM'][1]['CALCULAR']['AUDIT_CALC'][1]['FRETE_CALCULO'][nX][1] + ' </strong></td> '
			cHtml += ' <td>' + Alltrim(TRANSFORM(oJ['INFO']['CALC_MEM'][1]['CALCULAR']['AUDIT_CALC'][1]['FRETE_CALCULO'][nX][2] ,cPic)) + '</td> '
			cHtml += ' </tr> '
		next nX
	endif
	if lMem
		cHtml += ' <tr> '
		cHtml += ' <td><strong>ICMS</strong></td> '
		cHtml += ' <td>' + Alltrim(TRANSFORM(oJ['INFO']['CALC_MEM'][1]['ICMS'],cPic)) + '</td> '
		cHtml += ' </tr> '
	endif
	cHtml += ' </tbody> '
	cHtml += ' </table> '
	cHtml += ' <p>&nbsp;</p> '
	cHtml += ' </td> '
	cHtml += ' </tr> '
	cHtml += ' </tbody> '
	cHtml += ' </table> '
	cHtml += ' <p>&nbsp;</p> '
	cHtml += ' </div>'
return cHtml
