#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'

user function zCbViewPed() 
	local aCoors 		:= FWGetDialogSize( oMainWnd )
	local bErro	 		as object
	local oFWLayer 		as object
	local oFilDestino	as object
	local oFilMS		as object
	local oFilITU		as object
	local oRelMGMS		as object
	local oRelITUMS		as object
	local aArea 		as array
	local aConfig		as array
	private oMainFact	as object
	private oSecFact	as object
	private oTerFact	as object
	private cMainAlias  := GetNextAlias()
	private cSecAlias   := GetNextAlias()
	private cTerAlias   := GetNextAlias()
	private oDlgPrinc	as object
	
	aArea 	  	  := GetArea() 
	bErro		 := ErrorBlock({|oErr| trataErro(oErr)})
	BEGIN SEQUENCE
		Define MsDialog oDlgPrinc Title 'Controle Multi Filial'  From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		oFWLayer := FWLayer():New()
		oFWLayer:Init( oDlgPrinc, .F., .T. )

		// POSICIONAMENTO TELA
		oFWLayer:AddLine('CIMA', 50, .F. )
		oFWLayer:AddCollumn('CONTEUDO_CIMA'	,100, .T., 'CIMA' )
		oFilDestino	:= oFWLayer:GetColPanel('CONTEUDO_CIMA','CIMA')
		oFWLayer:AddLine('BAIXO'			,50, .F. )
		oFWLayer:AddCollumn('01_CONTEUDO_BAIXO',50, .T., 'BAIXO' )
		oFilMS 	:= oFWLayer:GetColPanel('01_CONTEUDO_BAIXO','BAIXO')
		oFWLayer:AddCollumn('CONTEUDO_BAIXO',50, .T., 'BAIXO' )
		oFilITU 	:= oFWLayer:GetColPanel('CONTEUDO_BAIXO','BAIXO')
		
		// PREPARAR ALIAS
		prepAls({cMainAlias,cSecAlias,cTerAlias})

		// PREPARA OS BROWSERS NOS PAINEIS
		// OBTEM AS CONFIGURAÇÔES DOS BROWSERS
		aConfig 	:= defCfg()
		oMainFact 	:= defFactBrw('MAIN',oFilDestino, cMainAlias, aConfig[1])
		oSecFact 	:= defFactBrw('SEC', oFilMS, cSecAlias, aConfig[2])
		oTerFact 	:= defFactBrw('TER', oFilITU, cTerAlias, aConfig[3])

		// RELACIONAMENTOS
		oRelMGMS 	:= FWBrwRelation():New()
		oRelITUMS	:= FWBrwRelation():New()
		oRelMGMS:AddRelation(oMainFact , oSecFact, {;
		{'C5_X_IDVEN'			, 'C5_X_IDVEN'} } )
		oRelITUMS:AddRelation(oMainFact , oTerFact, {;
		{'C5_X_IDVEN'			, 'C5_X_IDVEN'} } )
		oRelMGMS:Activate()
		oRelITUMS:Activate()
		
		updAllBrw()
		Activate MsDialog oDlgPrinc Center
		RECOVER
	END SEQUENCE
	ErrorBlock(bErro)

	closeAls({cMainAlias,cSecAlias,cTerAlias})
	RestArea(aArea)
	FreeObj(oFWLayer)
	FreeObj(oFilDestino)
	FreeObj(oFilMS)
	FreeObj(oFilITU)
	FreeObj(oRelMGMS)
	FreeObj(oRelITUMS)
	FreeObj(oMainFact)
	FreeObj(oSecFact)
	FreeObj(oTerFact)
return (nil)


static function defFactBrw(cFor, oPanel, cDefAls, aConfig)
	local aStruct	as array
	local oDefBrw	as object
	aStruct 	:= getStruct()
	if cFor == 'MAIN'
		oDefBrw := montaBrw(oPanel	,aConfig[1], aConfig[2], aConfig[3], cDefAls, aConfig[4], aStruct, canEdit(), .T.)
	elseif cFor == 'SEC'
		oDefBrw := montaBrw(oPanel	,aConfig[1], aConfig[2], aConfig[3], cDefAls, aConfig[4], aStruct, .F., .F.)
	elseif cFor == 'TER'
		oDefBrw := montaBrw(oPanel	,aConfig[1], aConfig[2], aConfig[3], cDefAls, aConfig[4], aStruct, .F., .F.)
	endif
return(oDefBrw)


static function defCfg()
	local aCfg		as array
	local nPos		as numeric
	aCfg := {}
	aadd(aCfg,;
	{'01',;
	{{'Pedido ITU','SP01', '01', "!empty(C5_X_IDVEN) .AND. C5_FILIAL == '01'"},;
	{'Pedido MS',  'MS02', '02', "C5_FILIAL == '02'"},;
	{'Pedido MG',  'MG03', '03', "C5_FILIAL == '03'"}}})
	aadd(aCfg,;
	{'02',;
	{{'Pedido MS',	'MS02',	 '02', "!empty(C5_X_IDVEN) .AND. C5_FILIAL == '02'"},;
	{'Pedido ITU', 	'SP01',  '01', "C5_FILIAL == '01'"},;
	{'Pedido MG', 	'MG03' , '03', "C5_FILIAL == '03'"}}})
	aadd(aCfg,;
	{'03',;
	{{'Pedido MG', 	'MG03', '03', "!empty(C5_X_IDVEN) .AND. C5_FILIAL == '03'"},;
	{'Pedido MS', 	'MS02', '02', "C5_FILIAL == '02'"},;
	{'Pedido ITU',	'SP01', '01', "C5_FILIAL == '01'"}}})
	nPos := AScan(aCfg,{|a| Alltrim(a[1]) == Alltrim(FwFilial()) })
return(aCfg[nPos,2])


static function montaBrw(oPanel, cDesc, cProfId, cFilBrw, cAls, cFilter, aStruct, lCanEdit, lSeekShw)
	local oBrw as object
	local aSeek	:= {}
	default cFilter	:= ''
	default lCanEdit := .T.
	default lSeekShw	:= .F.
	
	oBrw:= FWMBrowse():New()
	oBrw:SetAlias(cAls)
	oBrw:SetOwner(oPanel)
	oBrw:SetDescription(cDesc)
	oBrw:SetFields(aStruct)
	oBrw:ForceQuitButton(.F.)
	oBrw:SetSeeAll(.F.)
	oBrw:DisableReport()
	oBrw:DisableDetails()
	oBrw:SetFilial({cFilBrw})
	
	oBrw:AddStatusColumns({|| defStatusLegend(oBrw)}, {|| statusLegend(oBrw)})
	// oBrw:AddLegend(".T.","GREEN"   ,"Usuários Liberados")
	
	
	if !Empty(cFilter)
		oBrw:SetFilterDefault(cFilter)
	endif
	addCol(@oBrw, 'Cliente', ''  ,{||getDescPed(oBrw) },'C', 80, 0, 1,{|| .T.})
	
	if lSeekShw
		aadd(aSeek,{"Filial+Pedido" ,{{"",'C',TamSx3('C5_NUM')[1],0,"C5_NUM",PesqPict( 'SC5', 'C5_NUM' )}}})
		oBrw:SetSeek(.T.,aSeek)
	endif
	
	oBrw:AddButton('Visualizar'		,{|| callMenu('Visualizar', oBrw) },,7,)
	oBrw:AddButton('Status'			,{|| callMenu('Status', oBrw) },,7,)
	oBrw:AddButton('Alteração'		,{|| callMenu('Alter', oBrw) },,7,)
	oBrw:AddButton('Relat.Pedidos'	,{|| callMenu('RelPed', oBrw) },,7,)
	oBrw:AddButton('Trace'	,		 {|| callMenu('Trace', oBrw) },,7,)
	if lCanEdit
		oBrw:AddButton('Devolver Vendas'	,{|| callMenu('Devolver',oBrw) },,7,)
		oBrw:AddButton('Gerar Pedidos'		,{|| callMenu('Gerar'	,oBrw) },,7,)
		oBrw:AddButton('Eliminar Residuo'	,{|| callMenu('Residuo'	,oBrw) },,7,)
	endif
	oBrw:SetProfileID(cProfId)
	oBrw:Activate()	
return(oBrw)


static function callMenu(cOp, oBrwFrom)
	local lExecuted as boolean
	
	if cOp == 'Visualizar'
		 FWMsgRun(, { |oSay|  verPedido((oBrwFrom:cAlias)->(Recno())) }, "Selecionando", " Abrindo Pedido...")
	elseif cOp == 'Devolver'
		FWMsgRun(, { |oSay|  u_cbcSrvAltTriangle((oBrwFrom:cAlias)->(Recno())) }, "Alteração", " Analisando Pedidos Envolvidos ... ")
		FWMsgRun(, { |oSay|  updAllBrw() }, "Atualizando", " Atualizando Browser...")
	elseif cOp == 'Residuo'
		FWMsgRun(, { |oSay|  u_cbcResidTriangle((oBrwFrom:cAlias)->(Recno())) }, "Residuo", " Eliminando Residuo ... ")
		FWMsgRun(, { |oSay|  updAllBrw() }, "Atualizando", " Atualizando Browser...")
	elseif cOp == 'Gerar'
		 lExecuted := .F.
		 FWMsgRun(, { |oSay|  u_cbcMrkRegVenda(FwFilial(), @lExecuted) }, "Selecionando", " Listando Pedidos...")
		 if lExecuted
		 	FWMsgRun(, { |oSay|  updAllBrw() }, "Atualizando", " Atualizando Browser...")
		 endif
	elseif cOp == 'Alter'
		FWMsgRun(, { |oSay| u_zCbcAltPed((oBrwFrom:cAlias)->(Recno())) }, "Selecionando", " Alterar Pedido...")
	elseif cOp == 'Status'
		MsgInfo(defStatusPed(oBrwFrom), 'Status')
	elseif cOp == 'RelPed'
		u_xMGReport('IDVEND')
	elseif cOp == 'Trace'
		FWMsgRun(, { |oSay| u_cbcTraceBck((oBrwFrom:cAlias)->(C5_NUM),,,(oBrwFrom:cAlias)->(C5_FILIAL)) }, "Selecionando", "Trace...")
	endif
return()


static function defStatusLegend(oBrwFrom)
	local cSts as character
	local aStsInfo as array
	local nPos as number
	cSts 		:= ''
	aStsInfo := getStatusInfo(oBrwFrom)
	if ( nPos := AScan(aStsInfo[2],{|a| a[1] == aStsInfo[1]  })) > 0
		cSts := aStsInfo[2][nPos][2]
	endif
return(cSts)


static function statusLegend(oBrwFrom)
	local oLegenda as object  
	local aStsInfo as array   
	local nX as number
	oLegenda :=  FWLegend():New()
	aStsInfo := getStatusInfo(oBrwFrom)
	for nX := 1 to len(aStsInfo[2])
		oLegenda:Add( '', aStsInfo[2][nX,2] , aStsInfo[2][nX,1] )
	next nX
	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()
	FreeObj(oLegenda)
return (nil)


static function updAllBrw()
	oMainFact:FWFILTER():ExecuteFilter()
	oMainFact:Refresh()
	oSecFact:FWFILTER():ExecuteFilter()
	oSecFact:Refresh()
	oTerFact:FWFILTER():ExecuteFilter()
	oTerFact:Refresh()
return(nil)


static function canEdit()
	local lCan as boolean
	local oAcl	as object		
	oAcl	:= cbcAcl():newcbcAcl()
	oAcl:aclValid('EditPousoAlegre')
	lCan := oAcl:aclValid('EditPousoAlegre')
	FreeObj(oAcl)
return(lCan)


static function prepAls(aAls)
	local nX := 0
	for nX := 1 to len(aAls)
		ChkFile("SC5")
		dbChangeAlias("SC5",aAls[nX])
		(aAls[nX])->(DBSetOrder(1) )
		(aAls[nX])->( dbGoTop() )
	next nX
	ChkFile("SC5")
return(nil)


static function closeAls(aAls)
	local nX := 0
	for nX := 1 to len(aAls)
		(aAls[nX])->( dbCloseArea() )
	next nX
return(nil)


static function getStruct()
	local aTmp	:= {}
	aadd(aTmp,"C5_NUM")
	aadd(aTmp,"C5_CLIENTE" )
	aadd(aTmp,"C5_LOJACLI")
	aadd(aTmp,"C5_ENTREG")
	aadd(aTmp,"C5_DTFAT")
	aadd(aTmp,"C5_OBS")
	aadd(aTmp,"C5_TPFRETE")
	aadd(aTmp,"C5_TOTAL")
	aadd(aTmp,"C5_EMISSAO")
	aadd(aTmp,"C5_PALLET")
	aadd(aTmp,"C5_DRC")
	aadd(aTmp,"C5_LAUDO")
	aadd(aTmp,"C5_DOCPORT")
	aadd(aTmp,"C5_PARCIAL")
	aadd(aTmp,"C5_ZZPVORI")
	aadd(aTmp,"C5_NOTA")
	aadd(aTmp,"C5_TIPO")
	aadd(aTmp,"C5_LIBEROK")
	aadd(aTmp,"C5_X_IDVEN")
	aadd(aTmp,"C5_OK")
	aadd(aTmp,"C5_FILIAL")
return( mountInfo(aTmp) )


static function mountInfo(aFields)
	local aInfo := {}
	local nX 	:= 0
	for nX := 1 to len(aFields)
		aadd(aInfo, { GetSx3Cache(aFields[nX],'X3_TITULO'),;
		aFields[nX],;
		GetSx3Cache(aFields[nX],'X3_TIPO'),;
		GetSx3Cache(aFields[nX],'X3_TAMANHO'),;
		GetSx3Cache(aFields[nX],'X3_DECIMAL'),;
		GetSx3Cache(aFields[nX],'X3_PICTURE')})	
	next nX	
return(aInfo)


static function addCol(oBrw, cFldName, cPicture, bLoad, cTipo, cTam, cDec, nAln, dblClick)  
	local aNewFld 		:= {}
	default bLoad 		:= {||.T.}
	default cTipo		:= 'C'
	default cTam		:= 2
	default cDec		:= 0
	default nAln		:= 2
	default dblClick	:= {||.T.}
	aadd(aNewFld, cFldName)
	aadd(aNewFld, bLoad)
	aadd(aNewFld, cTipo)
	aadd(aNewFld, cPicture )
	aadd(aNewFld,nAln)
	aadd(aNewFld,cTam)
	aadd(aNewFld,cDec)
	aadd(aNewFld,nil)
	aadd(aNewFld,{||.T.})
	aadd(aNewFld,.F.)
	aadd(aNewFld,dblClick)
	aadd(aNewFld,nil)
	aadd(aNewFld,{||.T.})
	aadd(aNewFld,.F.)
	aadd(aNewFld,.F.)
	aadd(aNewFld,{})
	oBrw:SetColumns({aNewFld})
return(nil)


static function getDescPed(oSelf)
	local oSql			:= nil
	local cNomeCli		:= ''
	private cConteudo		:= ''
	oSql 				:= LibSqlObj():newLibSqlObj()
	cNomeCli			:= oSql:getFieldValue("SA1", "A1_NOME",;
	"%SA1.XFILIAL% AND A1_COD = '" + (oSelf:cAlias)->(C5_CLIENTE) + "' AND A1_LOJA ='" + (oSelf:cAlias)->(C5_LOJACLI) + "'") 
	oSql:close()
	FreeObj(oSql)
return(cNomeCli)


static function defStatusPed(oSelf)
	local oPed as object
	local cStatus as character
	local oFil	as object	  
	oFil := cbcFiliais():newcbcFiliais()
	oFil:setFilial((oSelf:cAlias)->(C5_FILIAL))
	oPed :=  cbcModOrder():newcbcModOrder((oSelf:cAlias)->(C5_NUM), , ,(oSelf:cAlias)->(C5_FILIAL),)
	cStatus := oPed:getOrderStatus()
	oFil:backFil()
	FreeObj(oFil)
	FreeObj(oPed)
return('Filial: ' + (oSelf:cAlias)->(C5_FILIAL) + ' Pedido: ' + (oSelf:cAlias)->(C5_NUM) + ' Status: ' + cStatus)


static function getStatusInfo(oSelf)
	local oPed as object
	local cStatus as character
	local aDefSts as array
	local oFil	as object	  
	aDefSts := {}
	oFil := cbcFiliais():newcbcFiliais()
	oFil:setFilial((oSelf:cAlias)->(C5_FILIAL))
	oPed :=  cbcModOrder():newcbcModOrder((oSelf:cAlias)->(C5_NUM), , ,(oSelf:cAlias)->(C5_FILIAL),)
	cStatus := oPed:getOrderStatus()
	aDefSts := oPed:legDef()
	oFil:backFil()
	FreeObj(oFil)
	FreeObj(oPed)
return({cStatus, aDefSts})


static function verPedido(cRecPed)
	local aArea 	  := GetArea() 
	local oFil		  := cbcFiliais():newcbcFiliais()
	private Inclui    := .F.
	private Altera    := .F.
	private nOpca     := 1
	private cCadastro := "Pedido de Vendas"
	private aRotina := {}
	
	DbSelectArea("SC5") 
	SC5->(DbGoTo(cRecPed))
	oFil:setFilial(SC5->(C5_FILIAL))
	if SC5->(!EOF())
		MatA410(Nil, Nil, Nil, Nil, "A410Visual")
	endif
	oFil:backFil()
	RestArea(aArea)
	
	FreeObj(oFil)
return(nil)



static function trataErro(oErr)
	local cErro	:=  "[ViewPed-ErrHnd - "+DtoC(Date())+" - "+Time()+" ] "+ '[ERRO]' + oErr:Description 
	DisarmTransaction()
	ConOut(cErro)
	BREAK
return (nil)
