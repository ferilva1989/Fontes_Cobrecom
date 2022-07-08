#Include 'FWMVCDef.ch'

user function cbcOrMng()
	local aCoors 			:= FWGetDialogSize( oMainWnd )
	local oPanelUp		:= nil
	local oPanelLeft		:= nil
	local oRelPedIt		:= nil
	local oRelItLib		:= nil
	local oRelItVol		:= nil
	local oPainelFldr		:= nil
	local aCoorsFldr 		:= nil
	local oTFolder		:= nil
	local aFldSC5			:= {}
	local aFldSC6			:= {}
	local aFldSC9			:= {}
	local aFldSZN			:= {}
	local aFldrs			:= {}
	private oBrowseUp		:= nil
	private oBrowseItens	:= nil
	private oBrowseLibs	:= nil
	private oBrowseVol	:= nil
	private oPanelRight	:= nil
	private oWndRight		:= nil
	private cTextHtml		:= '<html bgcolor="#FFFFFF"></html>'
	private oSay			:= nil
	private LinePanel		:= nil
	
	Define MsDialog oDlgPrinc Title 'Gestao de Pedidos' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	// Cria o conteiner onde serão colocados os browses
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )
	
	oFWLayer:AddLine( 'UP', 30, .F. )
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	// oFWLayer:setColSplit ('ALL')

	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )
	montaBrw(@oBrowseUp,oPanelUp,'Pedidos','SC5','1',"cbcOrderMngr",aFldSC5)
	
	oFWLayer:AddLine( 'DOWN', 70, .F. )
	oFWLayer:AddCollumn( 'FOLDER' , 100, .T., 'DOWN' )
	oPainelFldr 	:= oFWLayer:GetColPanel('FOLDER', 'DOWN')
	
	aCoorsFldr	:= FWGetDialogSize(oPainelFldr)
	aadd(aFldrs,'Itens')
	aadd(aFldrs,'Liber.')
	aadd(aFldrs,'Volumes')
	oTFolder := TFolder():New( aCoorsFldr[1],aCoorsFldr[2],aFldrs,,oPainelFldr,,,,.T.,,aCoorsFldr[3],aCoorsFldr[4])
	
	montaBrw(@oBrowseItens,oTFolder:aDialogs[1],'Itens','SC6','2',"cbcOrderMngr",aFldSC6)
	
	aadd(aFldSC9, 'C9_ITEM')
	aadd(aFldSC9, 'C9_DATALIB')
	aadd(aFldSC9, 'C9_PRODUTO')
	aadd(aFldSC9, 'C9_DESCRI')
	aadd(aFldSC9, 'C9_QTDLIB')
	aadd(aFldSC9, 'C9_LIBEST')
	aadd(aFldSC9, 'C9_BLEST')
	aadd(aFldSC9, 'C9_BLCRED')
	aadd(aFldSC9, 'C9_RISCO')
	aadd(aFldSC9, 'C9_SEQOS')
	aadd(aFldSC9, 'C9_SEQUEN')
	montaBrw(@oBrowseLibs,oTFolder:aDialogs[2],'Liberações','SC9','3',"cbcOrderMngr",aFldSC9)
	
	aadd(aFldSZN, 'ZN_CTRLE')
	aadd(aFldSZN, 'ZN_ITEM')
	aadd(aFldSZN, 'ZN_TIPO')
	aadd(aFldSZN, 'ZN_STATUS')
	aadd(aFldSZN, 'ZN_PRODUTO')
	aadd(aFldSZN, 'ZN_DESCRI')
	aadd(aFldSZN, 'ZN_ACONDIC')
	aadd(aFldSZN, 'ZN_QTDROM')
	aadd(aFldSZN, 'ZN_QTDCOL')
	aadd(aFldSZN, 'ZN_QTDORI')
	aadd(aFldSZN, 'ZN_QUANT')
	aadd(aFldSZN, 'ZN_BOBS')
	aadd(aFldSZN, 'ZN_NUMBOB')
	aadd(aFldSZN, 'ZN_CARR')
	aadd(aFldSZN, 'ZN_NUMVOL')
	montaBrw(@oBrowseVol,oTFolder:aDialogs[3],'Volumes','SZN','4',"cbcOrderMngr",aFldSZN)
	
	// montaComp(oPanelRight)
	oRelPedIt:= FWBrwRelation():New()
	oRelPedIt:AddRelation(oBrowseUp,oBrowseItens,{{'C6_FILIAL','XFilial("SC6")'},{'C6_NUM','C5_NUM'}} )
	oRelPedIt:Activate()
	
	oRelItLib:= FWBrwRelation():New()
	oRelItLib:AddRelation(oBrowseUp,oBrowseLibs,{{'C9_FILIAL','XFilial("SC9")'},{'C9_PEDIDO','C5_NUM'}})
	oRelItLib:Activate()
	
	oRelItVol:= FWBrwRelation():New()
	oRelItVol:AddRelation(oBrowseUp,oBrowseVol,{{'ZN_FILIAL','XFilial("SZN")'},{'ZN_PEDIDO','C5_NUM'}})
	oRelItVol:Activate()

	Activate MsDialog oDlgPrinc Center
	
return(nil)


static function montaBrw(oBrw,oPanel,cDesc,cAls,cProfId,cMenuDef,aOnlFld)
	oBrw := FWmBrowse():New()
	oBrw:SetOwner(oPanel)
	oBrw:SetDescription(cDesc)
	oBrw:SetAlias(cAls)
	oBrw:SetMenuDef(cMenuDef)
	oBrw:SetProfileID(cProfId)
	// oBrw:SetDoubleClick({||FWMsgRun(,{|oSay|dblClickBrw(cAls)},"Atualizando","Atualizando...")})
	// oBrw:SetChange({||FWMsgRun(,{|oSay|chnBrw(cAls)},"Atualizando","Atualizando...")})
	oBrw:DisableDetails()
	if !empty(aOnlFld)
		oBrw:SetOnlyFields(aOnlFld)
	endif
	oBrw:Activate()
return(oBrw)


static function montaComp(oPanel)
	local oFont1			:= nil
	local oScroll			:= nil
	local aCoors 			:= FWGetDialogSize(oPanel)
	oScroll := TScrollArea():New(oPanel,aCoors[1],aCoors[2],aCoors[3],aCoors[4])
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT
	oFont1 		:= TFont():New("Arial Narrow",,030,,.F.,,,,,.F.,.F.)
	oSay 		:= TSay():New(aCoors[1],aCoors[2],{||cTextHtml},,,oFont1,,,,.T.,,,aCoors[3],aCoors[4],,,,,,.T.)
	oScroll:SetFrame(oSay)
return(nil)


static function dblClickBrw(cAls)
	local oPed		:= nil
	local aArrIt		:= {}
	local nX			:= 0
	local cHtm		:= ''
	/*
	local oView		:= FWViewActive()
	local oMdl		:= oView:getModel("SA1_CLIENTE_MASTER")
	*/
	if cAls == 'SC5'
		oPed := cbcModOrder():newcbcModOrder(SC5->(C5_NUM), , ,FwFilial(),)
		
		cHtm += ' <p> '
		cHtm += ' <span style="color: black; font-size: medium;">'
		cHtm += ' <span style="color: black; font-size: medium;"> Status: ' 		+  oPed:getOrderStatus() + '<br />'
		cHtm += ' <span style="color: black; font-size: medium;"> Moeda: ' 		+ cValToChar(oPed:getField('C5_MOEDA')) + '<br />'
		cHtm += ' <span style="color: black; font-size: medium;"> Taxa: '		+ cValToChar(oPed:getField('C5_TXMOEDA')) + '<br />'
		cHtm += ' <span style="color: black; font-size: medium;"> RG Total :' 	+ cValToChar(Round(oPed:getRgTotal(,'HISTORICO'),2))
		cHtm += ' </span></span></span></span></span>
		cHtm += ' </p> '
				
		cHtm += '<table border=1>'
		cHtm += '<tbody>'
		cHtm += '<tr>'
		cHtm += '<th  bgcolor="#FFFFFF">Item</th>'
		cHtm += '<th  bgcolor="#FFFFFF">Produto</th>'
		cHtm += '<th  bgcolor="#FFFFFF">Qtd Vend</th>'
		cHtm += '<th  bgcolor="#FFFFFF">Prc Vend</th>'
		cHtm += '<th  bgcolor="#FFFFFF">RG</th>'
		cHtm += '/<tr>'
		
		aArrIt := oPed:getItens()
		for nX := 1 to len(aArrIt)
			cHtm += '<tr>'
			cHtm +='<td bgcolor="#FFFFFF">' + cValToChar(aArrIt[nX]) + '</td>'
			cHtm +='<td bgcolor="#FFFFFF">' + cValToChar(oPed:getItmField('C6_PRODUTO', aArrIt[nX])) + '</td>'
			cHtm +='<td bgcolor="#FFFFFF">' + cValToChar(oPed:getItmField('C6_QTDVEN', aArrIt[nX])) + '</td>'
			cHtm +='<td bgcolor="#FFFFFF">' + cValToChar(Round(oPed:getItmField('C6_PRCVEN', aArrIt[nX]),4)) + '</td>'
			cHtm +='<td bgcolor="#FFFFFF">' + cValToChar(Round(oPed:getRgItem(, aArrIt[nX],'HISTORICO'),2)) + '</td>'
			cHtm +='/<tr>'
		next nX
		cHtm += '</tbody>'
		cHtm +='</table>'
		oSay:setText(cHtm)
		FreeObj(oPed)
	endif
	
return(.T.)


static function chnBrw(cAls)
	
return(.T.)


static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Opcao'  ACTION "alert('oi')" OPERATION 6  ACCESS 0 //OPERATION X
return(aRotina)
