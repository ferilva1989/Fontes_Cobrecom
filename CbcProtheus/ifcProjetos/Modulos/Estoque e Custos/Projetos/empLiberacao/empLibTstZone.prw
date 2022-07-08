#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'


user function zEmpLbTZ()
	local aCoors 		:= FWGetDialogSize(oMainWnd)
	local oFWLayer		:= nil
	local oDlgPrinc		:= nil
	local oSimulPnl		:= nil
	local oPedPnl		:= nil
	local oResPnl		:= nil
	local oEstPnl		:= nil
	local aSimulBrw		:= {}
	local aEstBrw		:= {}
	local oPedBrw		:= nil
	local aResBrw		:= {}
	local aBfRef 		:= TamSX3('BF_QUANT')
	local aC5Ref 		:= TamSX3('C5_NUM')
	local cRefPic		:= PesqPict('SBF', 'BF_QUANT' )
	local cSimulAls		:= ''
	local cEstoqAls		:= ''
	local cResulAls		:= ''
	private RECNO     	:= 1
	private PRIOR     	:= 2
	private DT_ENTR   	:= 3
	private PARCIAL   	:= 4
	private DT_FAT    	:= 5
	private TOTAL     	:= 6
	private CHAVE     	:= 7
	private ESTOQUE		:= 1
	private RESULTADO	:= 2
	private CAMPO		:= 1
	private VALOR	    := 2
	private OBJ			:= 1
	private DESCR		:= 2
	private oEstBrw		:= nil
	private oResBrw		:= nil
	private oSimulBrw	:= nil
	private oSimulTable := FWTemporaryTable():New()
	private oEstoqTable := FWTemporaryTable():New()
	private oResulTable := FWTemporaryTable():New()
	private aSimOrd		:= { {'Padrão(Fecha Pedido)',{PRIOR, DT_ENTR, PARCIAL, DT_FAT, TOTAL},.T.} }
	mkTable()
	cSimulAls		:= oSimulTable:GetAlias()
	cEstoqAls		:= oEstoqTable:GetAlias()
	cResulAls		:= oResulTable:GetAlias()
	
	Define MsDialog oDlgPrinc Title 'Empenho de Pedidos ' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )

	oFWLayer:AddCollumn('ESQUERDA', 35, .F.)
	oFWLayer:SetColSplit('ESQUERDA', CONTROL_ALIGN_LEFT)
	oFWLayer:AddWindow('ESQUERDA', 'ESQUERDA_CIMA' , 'Simulação', 30, .T., .F.)
	oFWLayer:AddWindow('ESQUERDA', 'ESQUERDA_BAIXO','Pedidos'	, 60, .T., .F.)
	
	oSimulPnl := oFWLayer:GetWinPanel('ESQUERDA', 'ESQUERDA_CIMA')
	oPedPnl   := oFWLayer:GetWinPanel('ESQUERDA', 'ESQUERDA_BAIXO')
	
	oFWLayer:AddCollumn('DIREITA', 65, .F.)
	oFWLayer:SetColSplit('DIREITA', CONTROL_ALIGN_RIGHT)
	
	oFWLayer:AddWindow('DIREITA', 'DIREITA_CIMA', 'Resultado', 60, .T., .F.)
	oResPnl := oFWLayer:GetWinPanel('DIREITA', 'DIREITA_CIMA')
	
	oFWLayer:AddWindow('DIREITA', 'DIREITA_BAIXO','Estoque', 40, .T., .F.)
	oEstPnl := oFWLayer:GetWinPanel('DIREITA', 'DIREITA_BAIXO')
	oFWLayer:winChgState ( 'DIREITA','DIREITA_BAIXO') 
	
	// Simulação	
	aAdd(aSimulBrw, {"Simulação",   "C_ID", "C", 6, 0})
	aAdd(aSimulBrw, {"Descrição",   "C_DESC", "C", 6, 0})
	oSimulBrw := FWMarkBrowse():New()
	bornBrw(@oSimulBrw, cSimulAls, oSimulPnl, aSimulBrw, 'ID_EMP_SIM', .T.)

	// Estoque
	aAdd(aEstBrw, {"Produto"	, "C_PROD", "C", 16, 0})
    aAdd(aEstBrw, {"Saldo"		,"N_SALDO","N", aBfRef[1], aBfRef[2]})
	oEstBrw := FWMarkBrowse():New()
	bornBrw(@oEstBrw, cEstoqAls, oEstPnl, aEstBrw, 'ID_EST_SIM', .T.)

	// Resultado
    aAdd(aResBrw, {"Pedido"			, "C_PEDIDO"  	,"C", aC5Ref[1], 0})
	aAdd(aResBrw, {"Prioridade"		, "C_PRIOR"     ,"C",1,  0})
	aAdd(aResBrw, {"DtPCP"			, "C_DT_ENTR"   ,"D",8,  0})
	aAdd(aResBrw, {"Parcial"		, "C_PARCIAL"   ,"C",1,  0})
	aAdd(aResBrw, {"DtFat"			, "C_DT_FAT"    ,"D",8,  0})
	aAdd(aResBrw, {"Vlr. Necess"	, "N_VNECES"	,"N", aBfRef[1], aBfRef[2], cRefPic})
	aAdd(aResBrw, {"Vlr.Atend"		, "N_VATEND"	,"N", aBfRef[1], aBfRef[2], cRefPic})
	aAdd(aResBrw, {"Pes.Neces(KG)"	, "N_PBNECE"	,"N", aBfRef[1], aBfRef[2], cRefPic})
	aAdd(aResBrw, {"Pes.Aten(KG)"	, "N_PBATEN"	,"N", aBfRef[1], aBfRef[2], cRefPic})
	aAdd(aResBrw, {"Tot.Bob"		, "N_TBOB"  	,"N", aBfRef[1], aBfRef[2], cRefPic})
	aAdd(aResBrw, {"Tot.BobP"		, "N_TPBOB" 	,"N", aBfRef[1], aBfRef[2], cRefPic})
	aAdd(aResBrw, {"Dif.Bob"		, "N_DFBOB" 	,"N", aBfRef[1], aBfRef[2], cRefPic})
	aAdd(aResBrw, {"ObsBob"			, "C_DFBOB" 	,"C",40, 0})
	aAdd(aResBrw, {"Status"			, "C_STS"   	,"C",40, 0})
	aAdd(aResBrw, {"Fechado"		, "N_FINAL" 	,"N",1,  0})

	oResBrw := FWMarkBrowse():New()
	bornBrw(@oResBrw, cResulAls, oResPnl, aResBrw, 'ID_RES_SIM', .T.)

	// Pedido SC5	
	oPedBrw := FWMarkBrowse():New()
	bornBrw(@oPedBrw,'SC5', oPedPnl,,'ID_PED',.F.)

	// Relacionamento Simulação x Resultado
	bornRel(oSimulBrw, oResBrw, {{'C_ID', 'C_ID'}} )
	// Relacionamento Simulação x Estoque
	bornRel(oSimulBrw, oEstBrw, {{'C_ID', 'C_ID'}} )
    // Relacionamento Resultado Pedido
	bornRel(oResBrw , oPedBrw, {;
		{'SC5->(C5_FILIAL)', 'xFilial( "SC5" )'},;
		{'SC5->(C5_NUM)', 	 'C_PEDIDO'} } )

	Activate MsDialog oDlgPrinc Center
	oSimulTable:Delete()
	oEstoqTable:Delete()
	oResulTable:Delete()
return nil


static function bornBrw(oBrw, cAls, oOwn, aFld, cId, lisTmp, cFiltro)
	default cFiltro := ''
	oBrw:SetAlias(cAls)
	oBrw:SetOwner(oOwn)
	oBrw:SetDescription('')
	oBrw:SetTemporary(lisTmp)
	if lisTmp
		oBrw:SetFields(aFld)
	endif
	oBrw:SetProfileID(cId)
	oBrw:ForceQuitButton(.F.)
	oBrw:SetChange({|| .T.})
	oBrw:setignorearotina(.T.)
	oBrw:SetUseFilter(.T.)
	oBrw:SetSeeAll(.F.)
	oBrw:DisableReport()
	if !empty(cFiltro)
		oBrw:SetFilterDefault(cFiltro)
	endif
	if cId == 'ID_RES_SIM'
		oBrw:AddStatusColumns({|| iif (N_FINAL == 1, 'BR_VERDE','BR_VERMELHO')}, {|| statusLegend('atendido')})
		oBrw:AddFilter('ATENDIDO'		,cAls + "->(N_FINAL) == 1" ,.F.,.F.)
		oBrw:AddFilter('NÃO ATENDIDO'	,cAls + "->(N_FINAL) == 2" ,.F.,.F.)
		oBrw:AddButton('Resultado', 	{|| FWMsgRun(,{|oSay| SimulRes() },"Resultado","Resultado...") },,7,)
		oBrw:AddButton('Empenhar', 		{|| FWMsgRun(,{|oSay| DoEmp() },"Empenhar","Empenhar...") },,7,)
	elseif cId == 'ID_EMP_SIM'
		oBrw:AddButton('Adicionar'		, {|| FWMsgRun(,{|oSay| editSimul(.T.) },"Adicionar","Adicionar...") },,7,)
		oBrw:AddButton('Visualizar'		, {|| FWMsgRun(,{|oSay| editSimul(.F.) },"Visualizar","Visualizar...") },,7,)
		oBrw:AddButton('Simular'	    , {|| FWMsgRun(,{|oSay| zLbTZ(oSay) },"Simulação","Simulação...") },,7,)
	elseif cId == 'ID_PED'
		oBrw:AddButton('Detalhes'		, {|| alert('oi') },,7,)
	endif
	/*
	oMarkLib:AddButton('Cancelar', {|| doProcRefr(oMarkLib) },,7,)
	aFields	:= {'C9_ITEM', 'C9_PRODUTO', 'C9_QTDLIB'}
	oMarkLib:SetOnlyFields(aFields)
	*/
	oBrw:Activate()
return nil


static function statusLegend(cDesc)
	local oLegenda  :=  FWLegend():New()
	if cDesc == 'atendido'
		oLegenda:Add( '', 'BR_VERDE'    , 'Pedido pode fechado' )
		oLegenda:Add( '', 'BR_VERMELHO' , 'Não pode fechar ou Parcial' )
	endif
	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()
	FreeObj(oLegenda)
return (nil)


static function bornRel(oBrwMaster, oBrwDet, aRel)
	local oRel := nil 
	oRel := FWBrwRelation():New()
	oRel:AddRelation(oBrwMaster, oBrwDet, aRel)
	oRel:Activate()
return nil


static function DoEmp() // zEmpLbTZ
	alert('quase la')
return nil


static function SimulRes() 
	local oSql := nil
	local cTxt := ''
	local cMascara	:= PesqPict('SC5', 'C5_TOTAL')
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(qryReslTmp(oResulTable:GetRealName()))
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			cTxt := 'Simulação ' 		+ Alltrim(oSql:getValue("SIMULACAO")) 			+ Chr(13)+Chr(10)
			cTxt += 'Qtd Pedidos ' 		+ cValToChar(oSql:getValue("QTD_PEDIDO"))	  	+ Chr(13)+Chr(10)
			cTxt += 'Pedidos Fechados ' + cValToChar(oSql:getValue("PEDIDO_FECHADO"))	+ Chr(13)+Chr(10)
			cTxt += 'Valor Necessario ' + Transform(oSql:getValue("VALOR_NECESSARIO"), cMascara) + Chr(13)+Chr(10)
			cTxt += 'Valor Atendido '   + Transform(oSql:getValue("VALOR_ATENDIDO"),   cMascara) + Chr(13)+Chr(10)
			oSql:skip()
			MsgInfo(cTxt, 'Resultado')
		endDo
	endif	
	oSql:close()
	FreeObj(oSql)	
return nil


static function editSimul(lAdd)
	local oModal		:= nil
	local oContainer	:= nil
	local nList			:= 1
	local aItems		:= {'PRIOR','DT_ENTR','PARCIAL','DT_FAT','TOTAL', 'FECHA'}
	local aFinal		:= {}
	local cCombo1		:= ''
	local oCmbOpc		:= nil
	local oBtnAdd		:= nil
	local oBtnRem		:= nil
	local oLstSel		:= nil
	local oGetTit		:= nil
	local nX 			:= 0
	local aButtons		:= {}
	local cNomReg		:= Space(50)
	default lAdd		:= .F.

    oModal  := FWDialogModal():New()       
    oModal:SetEscClose(.T.)
    oModal:setTitle("Opções para simulação")
     
    oModal:setSize(200, 140)
 
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    oContainer := TPanel():New( ,,, oModal:getPanelMain() )
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT
     
    if lAdd
		cCombo1:= aItems[1]
		oCmbOpc := TComboBox():New(02,02,{|u|if(PCount()>0,cCombo1:=u,cCombo1)},aItems,100,20,oContainer,,{||},,,,.T.,,,,,,,,,'cCombo1')
		oBtnAdd := TButton():New( 04, 104, "Add",oContainer,{||crudLs(cCombo1,.T.,@oLstSel)}, 20,20,,,.F.,.T.,.F.,,.F.,,,.F. )   
		oLstSel := TListBox():New(24,02,{|u|if(Pcount()>0,nList:=u,nList)},aFinal,100,100,{||},oContainer,,,,.T.)
		oBtnRem := TButton():New( 100, 104, "Rem",oContainer,{||crudLs(aFinal[nList],.F.,@oLstSel)}, 20,20,,,.F.,.T.,.F.,,.F.,,,.F. )  
		oGetTit := TGet():New(130,02,{|u|if(PCount()>0,cNomReg:=u,cNomReg)},oContainer,110,010,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cNomReg,,,,,,,'Regra',2 )
		aadd(aButtons, {,'SALVAR',{||savethis(@aFinal, @aSimOrd, cNomReg, @oModal)}, 'SALVAR',,.T.,.F.})
	else
		aFinal := {}
		for nX := 1 to len(aSimOrd)
			aadd(aFinal, aSimOrd[nX][1])
		next nX
		aadd(aButtons, {,'SALVAR',{||saveAll(@aFinal, @aSimOrd, @oModal)}, 'SALVAR',,.T.,.F.})
		oLstSel := TListBox():New(02,02,{|u|if(Pcount()>0,nList:=u,nList)},aFinal,100,120,{||},oContainer,,,,.T.)
		oBtnRem := TButton():New( 124, 104, "Rem",oContainer,{||crudLs(aFinal[nList],.F.,@oLstSel)}, 20,20,,,.F.,.T.,.F.,,.F.,,,.F. ) 
	endif
	
	oModal:addButtons(aButtons)
	oModal:Activate()
	FreeObj(oModal)
return nil


static function saveAll(aFnl, aOrd, oMdl)
	local nx 	:= 0
	local aNew  := {}
	for nX := 1 to len(aOrd)
		if (nPos := Ascan(aFnl, {|cN| cN  == aOrd[nX][1] }) ) > 0
			aadd(aNew, aOrd[nX])
		endif
	next nx
  	if !empty(aNew)
		aOrd := {}
		aOrd := aClone(aNew)
	endif
	eval(oMdl:bClose)
return nil


static function savethis(aFnl, aOrd, cNomReg, oMdl) 
	local nX 		:= 0 
	local aPos  	:= {}
	local cForExe 	:= ''
	if empty(Alltrim(cNomReg))
		MsgInfo('Obrigatorio nome para regra', 'Validação')
	elseif empty(aFnl)
		MsgInfo('Obrigatorio opções para regra', 'Validação')
	else
		if Ascan(aOrd, {|cN| cN[1]  == 'Padrão(Fecha Pedido)' })  == 0
			aadd(aOrd, {'Padrão(Fecha Pedido)',{PRIOR, DT_ENTR, PARCIAL, DT_FAT, TOTAL},.T.})
		endif
		for nX := 1 to len(aFnl)
			if aFnl[nX] != 'FECHA'
				cForExe := aFnl[nX]
				aadd(aPos, &(cForExe))
			endif
		next nX
		aadd(aOrd, { Alltrim(cNomReg),aPos,(aScan(aFnl, {|x| x == 'FECHAR'})>0) } )
		eval(oMdl:bClose)
	endif
return nil


static function crudLs(cTxt, lInc, oComp)
	local nPos := 0
	if lInc
		if aScan(oComp:aItems, {|x| x == cTxt}) == 0
			oComp:add(cTxt)
		endif
	else
		if cTxt != 'Padrão(Fecha Pedido)'
			if (nPos := aScan(oComp:aItems, {|x| x == cTxt})) > 0
				oComp:Del(nPos)
			endif
		endif
	endif
	oComp:Refresh()
	ProcessMessage()
return nil


static function zLbTZ(oSay)
	local oHashEst 		:= HMNew()
	local aRecSC5		:= {}
	local aHashResult   := {}
	local nX			:= 0
	
	// Limpar as tabelas com os reultados anteriores
	setTxt(@oSay, "Limpando tabelas anteriores")		
	clrTable({oSimulTable,oEstoqTable,oResulTable})
	for nX := 1 to len(aSimOrd)
		// Carteira
		getCart(@aRecSC5)
		// Ordenação Pedidos
		mkOrd(@aRecSC5, aSimOrd[nX][2])
		// Aplicar a Ordem
		doOrd(@aRecSC5)
		// Estoque
		zLVirEst(@oHashEst)
		FWMsgRun(,{|oSay| aadd(aHashResult, {doWork(@aRecSC5,@oHashEst,aSimOrd[nX][3],oSay),aSimOrd[nX][1]})},"Empenho","Simulação...")
	next nX
	// Atualiza as tabelas
	FWMsgRun(,{|oSay| analytics(aRecSC5, aHashResult, oSay) },"Visualização","Preparando...")
	updBrw({oSimulBrw, oResBrw, oEstBrw})
return (nil)


static function analytics(aRecSC5, aHashResult, oSay) 
	local nX 	:= 0
	local nY 	:= 0
	local nZ 	:= 0
	local jSRes := nil
	local cSimulAls := ''
	local cEstoqAls	:= ''
	local cResulAls	:= ''
	local aSimulUpd := {}
	local aEstoqUpd := {}
	local aResulUpd := {}
	local aLstEst	:= {}

	cSimulAls := oSimulTable:GetAlias()
	cEstoqAls := oEstoqTable:GetAlias() 
	cResulAls := oResulTable:GetAlias()

	// Em cada simulação
	for nX := 1 to len(aHashResult)
		setTxt(@oSay, "Simulação..." +  aHashResult[nX][DESCR])		
		aadd(aSimulUpd, {{'C_ID', cValToChar(nX)},;
		{'C_DESC', aHashResult[nX][DESCR]}})
		grvFld(cSimulAls, @aSimulUpd)		
		// Como ficou estoque nesta simulação
		if (HMList(aHashResult[nX][OBJ][ESTOQUE],@aLstEst))
			setTxt(@oSay, "Preparando Estoque...")		
			for nZ := 1 to len(aLstEst)
				aadd(aEstoqUpd, {{'C_ID', cValToChar(nX)},;
				{"C_PROD", aLstEst[nZ][2][1][1] },;
				{"N_SALDO",aLstEst[nZ][2][1][2] }})
			next nZ
			grvFld(cEstoqAls, @aEstoqUpd)
		endif
		
		// Situacao de cada pedido
		for nY := 1 to len(aRecSC5)
			setTxt(@oSay, "Preparando Pedidos...")
			SC5->( DbGoTo(aRecSC5[nY][RECNO] ))
			jSRes := getResult(,aHashResult[nX][OBJ][RESULTADO])
			aAdd(aResulUpd, {{"C_ID"     , cValToChar(nX)},;
				{"C_PEDIDO" , SC5->(C5_NUM)},;
				{"N_ATEND"  , jSRes['nAtendTot']},;
				{"N_NECES"  , jSRes['nNecesTot']},;
				{"N_VATEND" , jSRes['nVlrAtend']},;
				{"N_PBATEN" , jSRes['nPBrAtend']},;
				{"N_PBNECE" , jSRes['nPBruNeces']},;
				{"N_VNECES" , jSRes['nVlrNeces']},;
				{"N_TBOB"   , jSRes['nTotBob']},;
				{"N_TPBOB"  , jSRes['nTotBobP']},;
				{"N_DFBOB"  , jSRes['nDifBob']},;
				{"C_TXBOB"  , jSRes['cTextBob']},;
				{"C_STS"    , jSRes['cSts']},;
				{"C_PRIOR"  , SC5->(C5_TIPOLIB)},;
				{"C_DT_ENTR", SC5->(C5_ENTREG)},;
				{"C_PARCIAL", SC5->(C5_PARCIAL)},;
				{"C_DT_FAT" , SC5->(C5_DTFAT)},;
				{"N_FINAL"  , iif(jSRes['lFinal'],1,2)}})			
			grvFld(cResulAls, @aResulUpd)
		next nY
	next nX
return nil


static function updBrw(aBrw)
	local nX := 0
	for nX := 1 to len(aBrw)
		aBrw[nX]:FwFilter():ExecuteFilter()
		aBrw[nX]:Refresh(.T.)
		aBrw[nX]:GoTop(.T.)
		ProcessMessage()
	next nX 
return nil


static function grvFld(cAlias, aFldVl)
	local nX := 0
	local nY := 0
	for nY := 1 to len(aFldVl)
		(cAlias)->(DBAppend())
		for nX := 1 to len(aFldVl[nY])
			(cAlias)->(&(aFldVl[nY][nX][CAMPO])) := aFldVl[nY][nX][VALOR]
		next nX
	(cAlias)->(DBCommit())
	next nY
	aFldVl := {}
return nil


static function clrTable(aTable)
	local cQuerySQL := '' 
	local lRet		:= .T.
    local cErr		:= ''
	local nX		:= 0
	for nX :=  1 to len(aTable)
		cTableName := aTable[nX]:GetRealName()
		cQuerySQL := "DELETE FROM " + cTableName
		if TCSqlExec(cQuerySQL) < 0
			lRet := .F.
			cErr += TCSqlError() + ' '
		endif
	next
return {lRet, cErr} 


static function mkTable()
	local aSimulFlds := {}
	local aEstoqFlds := {}
	local aResulFlds := {}
	local aBfRef := TamSX3('BF_QUANT')
	local aC5Ref := TamSX3('C5_NUM')
	/*
    	1 - C - Nome do campo    2 - C - Tipo do campo
    	3 - N - Tamanho do campo 4 - N - Decimal do campo
    */
    // Tabelas das simulações realizadas
    aAdd(aSimulFlds, {"C_ID",   "C", 6, 0})
    aAdd(aSimulFlds, {"C_DESC", "C", 50, 0})
    oSimulTable:SetFields(aSimulFlds)
	oSimulTable:AddIndex("01", {"C_ID"} )
	oSimulTable:Create()
	// Estoque apos simulação
    aAdd(aEstoqFlds, {"C_ID",   "C", 6, 0})
	aAdd(aEstoqFlds, {"C_PROD", "C", 16, 0})
    aAdd(aEstoqFlds, {"N_SALDO","N", aBfRef[1], aBfRef[2]})
    oEstoqTable:SetFields(aEstoqFlds)
	oEstoqTable:AddIndex("01", {"C_ID"} )
	oEstoqTable:AddIndex("02", {"C_ID","C_PROD"} )
	oEstoqTable:Create()	
	// Pedidos forma foi atendido
    aAdd(aResulFlds, {"C_ID"      , "C", 6, 0})
    aAdd(aResulFlds, {"C_PEDIDO"  , "C", aC5Ref[1], 0})
	aAdd(aResulFlds, {"N_ATEND" ,"N", aBfRef[1], aBfRef[2]})
	aAdd(aResulFlds, {"N_NECES" ,"N", aBfRef[1], aBfRef[2]})
	aAdd(aResulFlds, {"N_VATEND","N", aBfRef[1], aBfRef[2]})
	aAdd(aResulFlds, {"N_PBATEN","N", aBfRef[1], aBfRef[2]})
	aAdd(aResulFlds, {"N_PBNECE","N", aBfRef[1], aBfRef[2]})
	aAdd(aResulFlds, {"N_VNECES","N", aBfRef[1], aBfRef[2]})
	aAdd(aResulFlds, {"N_TBOB"  ,"N", aBfRef[1], aBfRef[2]})
	aAdd(aResulFlds, {"N_TPBOB" ,"N", aBfRef[1], aBfRef[2]})
	aAdd(aResulFlds, {"N_DFBOB" ,"N", aBfRef[1], aBfRef[2]})
	aAdd(aResulFlds, {"C_DFBOB" ,"C",40, 0})
	aAdd(aResulFlds, {"C_STS"   ,"C",40, 0})
	aAdd(aResulFlds, {"N_FINAL" ,"N",1,  0})
    aAdd(aResulFlds, {"C_PRIOR"     ,"C",1,  0})
	aAdd(aResulFlds, {"C_DT_ENTR"   ,"D",8,  0})
	aAdd(aResulFlds, {"C_PARCIAL"   ,"C",1,  0})
	aAdd(aResulFlds, {"C_DT_FAT"    ,"D",8,  0})
	
	oResulTable:SetFields(aResulFlds)
	oResulTable:AddIndex("01", {"C_ID"} )
	oResulTable:AddIndex("02", {"C_ID", "C_PEDIDO"} )
	oResulTable:Create()
	
	aSimulFlds  := nil
	aEstoqFlds  := nil
	aResulFlds  := nil
	aBfRef		:= nil
return nil


static function doWork(aRecSC5,oHash,lFchaPed,oSay)
	local nX   			:= 0
	local oHmClone		:= nil
	local nTam 			:= len(aRecSC5)
	local oHashResult   := HMNew()
	for nX := 1 to nTam
		SC5->( DbGoTo(aRecSC5[nX][RECNO] ))
		setTxt(@oSay, "Analisando Pedido..." + Alltrim(SC5->(C5_NUM)) + " Registro : " + cValToChar(nX) + " de " + cValToChar(nTam))
		if lFchaPed
			oHmClone := HMNew()
			zHMClone(oHash, @oHmClone)
            doVirEmp(@oHmClone, @oHashResult)
			if getResult('lFinal', oHashResult)
				zHMClone(oHmClone, @oHash)
			endif
			HMClean(oHmClone)
		else
			doVirEmp(@oHash,@oHashResult)
		endif		
	next nX
return {oHash, oHashResult}


static function doOrd(aSC5, lAsc)
	default lAsc := .T.
	if lAsc
		aSort(aSC5 ,,, { |x,y|( x[CHAVE] < y[CHAVE] ) } )
	else
		aSort(aSC5 ,,, { |x,y|( x[CHAVE] > y[CHAVE] ) } )
	endif
return nil


static function mkOrd(aTmp, aFld)
	local nX		:= 0
	local nY		:= 0
	default aFld 	:= {PRIOR, DT_ENTR, PARCIAL, DT_FAT, TOTAL}
	for nX := 1 to len(aTmp)
		aTmp[nX][CHAVE] 	:= ''
		for nY := 1 to len(aFld)
			aTmp[nX][CHAVE] += if(valtype(aTmp[nX][aFld[nY]]) <> 'C',;
			cValToChar(aTmp[nX][aFld[nY]]),;
			aTmp[nX][aFld[nY]])
		next nY
	next nX
return nil


static function getCart(aRecC5) 
	local oSql		:= nil
	aRecC5 			:= {}
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(getQryCart())
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			aadd(aRecC5, {oSql:getValue("RECNO"),;
			oSql:getValue("PRIOR"),;
			oSql:getValue("DT_ENTR"),;
			oSql:getValue("PARCIAL"),;
			oSql:getValue("DT_FAT"),;
			nBlEsTotal(oSql:getValue("PEDIDO")),;
			''})
			oSql:skip()
		endDo
	endif	
	oSql:close()
	FreeObj(oSql)
return nil


static function nBlEsTotal(cPedido) 
	local oSql 		:= nil 
	local nTotLib	:= 0
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(qryTotBlest(cPedido))
	if oSql:hasRecords()
		oSql:goTop()
		nTotLib := oSql:getValue("TOTAL")
	endif	
	oSql:close()
	FreeObj(oSql)
return(nTotLib)


static function zLVirEst(oHash)
	local oSql		:= nil
	local cProd		:= ''
	local nSaldo	:= 0 
	local xValue	:= nil
	default oHash	:= nil
	if !empty(oHash)
		HMClean(oHash)
		oSql := LibSqlObj():newLibSqlObj()
		oSql:newAlias(cbcQRYBFEst())
		if oSql:hasRecords()
			oSql:goTop()
			while oSql:notIsEof()
				cProd 	:= ( oSql:getValue("Alltrim(Produto)") + oSql:getValue("Alltrim(Acond)") )
				nSaldo 	:= oSql:getValue("Disponivel")
				if  ! HMGet( oHash , cProd , @xValue )
					HMAdd(oHash,{cProd,nSaldo})
				endif
				oSql:skip()
			endDo
		endif	
		oSql:close()
		FreeObj(oSql)
	endif
return(nil)


static function getTotBlq(cPed) 
	local oSql 			:= nil 
	local aRet			:= {}

	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(getBlq(cPed))
	if oSql:hasRecords()
		oSql:goTop()
		aRet := {}
		while oSql:notIsEof()
			aadd(aRet,{oSql:getValue("RECC9"),oSql:getValue("RECC6"),oSql:getValue("RECB1") })
			oSql:skip()
		endDo	
	endif
	oSql:close()
	FreeObj(oSql)
return(aRet)


static function doVirEmp(oHash, oHashResult)
	local aRecBlq		:= {}
	local nX			:= 1
	local cQtdBlq		:= 0
	local nQtdAtend     := 0
	local cProdAcon		:= ''
	local aAr 			:= GetArea()
	local aArC5 		:= SC5->(GetArea())
	local aArC6 		:= SC6->(GetArea())
	local aArC9 		:= SC9->(GetArea())
	local aArB1 		:= SB1->(GetArea())
	local aArZE			:= SZE->(GetArea())
	local aBob			:= {}
	local nY			:= 0
	local oJson         := JsonObject():new()

	oJson['nAtendTot'] 		:= 0
	oJson['nNecesTot']		:= 0
	oJson['nVlrAtend']		:= 0
	oJson['nPBrAtend']		:= 0
	oJson['nPBruNeces']		:= 0
	oJson['nVlrNeces']		:= 0
	oJson['nTotBob']		:= 0
	oJson['nTotBobP']		:= 0
	oJson['nDifBob']		:= 0
	oJson['cTextBob'] 		:= 'OK'
	oJson['cSts']			:= 'INICIO'
	oJson['lFinal']		    := .F.

	if empty(aRecBlq := getTotBlq(SC5->(C5_NUM)))
		oJson['cSts']	:= 'NADA BLOQUEADO'
		oJson['lFinal'] := .F.
	else
		for nX := 1 to len(aRecBlq)
			SC9->(DbGoTO(aRecBlq[nX,1]))
			SC6->(DbGoTO(aRecBlq[nX,2]))
			SB1->(DbGoTO(aRecBlq[nX,3]))
			oJson['nPBruNeces']	+= (SC9->(C9_QTDLIB) * SB1->(B1_PESBRU))
			oJson['nVlrNeces']	+= (SC9->(C9_QTDLIB) * SC6->(C6_PRCVEN))
			oJson['nNecesTot']	+= SC9->(C9_QTDLIB)

			if SC6->(C6_ACONDIC) == 'B'
				oJson['nTotBob'] += SC9->(C9_QTDLIB)
				if !empty(aBob := getBobPed(SC5->(C5_NUM)))
					for nY := 1 to len(aBob)	
						SZE->(DbGoTo(aBob[nY]))
						if SZE->(ZE_CLIENTE + ZE_LOJA + ZE_PEDIDO + ZE_ITEM + ZE_PRODUTO) ==;
						SC5->(C5_CLIENTE + C5_LOJACLI + C5_NUM) + SC6->(C6_ITEM + C6_PRODUTO)
							cProdAcon 	:= SC9->(Alltrim(C9_PRODUTO)) + Alltrim(SC6->(C6_ACONDIC + StrZero(SZE->(ZE_QUANT),5)))
							nQtdAtend 	:= zLVirEmp(oHash, cProdAcon, SZE->(ZE_QUANT))
							oJson['nTotBobP']	+= nQtdAtend
							oJson['nPBrAtend']	+= (nQtdAtend * SB1->(B1_PESBRU))
							oJson['nVlrAtend']	+= (nQtdAtend * SC6->(C6_PRCVEN))
							oJson['nAtendTot']	+= nQtdAtend
						endif
					next nY
				endif
			else
				cQtdBlq 	:= SC9->(C9_QTDLIB)
				cProdAcon 	:= SC9->(Alltrim(C9_PRODUTO)) + Alltrim(SC6->(C6_ACONDIC + StrZero(SC6->C6_METRAGE,5)))
				nQtdAtend 	:= zLVirEmp(oHash, cProdAcon, cQtdBlq)
				oJson['nPBrAtend']	+= (nQtdAtend * SB1->(B1_PESBRU))
				oJson['nVlrAtend']	+= (nQtdAtend * SC6->(C6_PRCVEN))
				oJson['nAtendTot']	+= nQtdAtend
			endif
		next nX

		if oJson['nNecesTot'] == 0
			oJson['cSts']	:= 'NADA BLOQUEADO'
			oJson['lFinal'] := .F.
		elseif (oJson['nNecesTot'] == oJson['nAtendTot'] )
			oJson['cSts'] := 'ATENDIDO'
			oJson['lFinal'] := .T.
		elseif ( oJson['nAtendTot'] > oJson['nNecesTot'] )
			oJson['cSts'] := 'ATEND_MAIOR'
			oJson['lFinal'] := .T.
		else
			oJson['cSts'] := 'NAO_ATEND'
			oJson['lFinal'] := .F.
		endif
	endif
	if ( oJson['nTotBob'] == oJson['nTotBobP'] )
		oJson['cTextBob'] := 'OK'
	else
		oJson['nDifBob'] := (((oJson['nTotBobP'] - oJson['nTotBob']) * 100) / oJson['nTotBob'])
		if abs(oJson['nDifBob']) == 100
			oJson['cTextBob'] := ' FALTA'
		else
			oJson['cTextBob'] := 'DIF.' + Alltrim(Transform(oJson['nDifBob'], PesqPict('SC5', 'C5_TOTAL')))
		endif  
	endif
	HMSet(oHashResult, SC5->(Recno()),oJson)

	RestArea(aArZE)
	RestArea(aArB1)
	RestArea(aArC9)
	RestArea(aArC6)
	RestArea(aArC5)
	RestArea(aAr)
return(nil)


static function getBobPed(cPed) 
	local oSql 		:= nil 
	local aRec		:= {}
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(getBob(cPed))
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			if oSql:getValue("ACONDIC") == 'B'
				aadd(aRec, oSql:getValue("REC"))
			else
				/*
				oSelf:setNotif('Bobina', 'Bobina pesada para item que é rolo!',;
				{{'Pedido+Item+Recno', SZE->(ZE_PEDIDO + ZE_ITEM+ cValToChar(Recno()))}},.F.,,.T.)
				*/
			endif
			oSql:skip()
		endDo
	endif	
	oSql:close()
	FreeObj(oSql)
return(aRec)


static function zLVirEmp(oHash, cProd, nQtd)
	local aSld		:= {}
	local nSld		:= 0
	local nQtdAtend := 0
	default oHash	:= nil
	if !empty(oHash)
		if HMGet( oHash, cProd, @aSld )
			if empty(aSld)
				nQtdAtend := 0
			else
				if empty(aSld[1,2])
					nQtdAtend := 0
				else
					if ( (nSld := (aSld[1,2] - nQtd)) >= 0 )
						if( HMSet(oHash, cProd, {{cProd, nSld}} ) )
							nQtdAtend := nQtd
						endif
					else
						if (HMSet(oHash, cProd, {{cProd, 0}} ))
							nQtdAtend := aSld[1,2]
						endif
					endif
				endif
			endif
		else
			nQtdAtend := 0
		endif
	endif
return(nQtdAtend)


static function getResult(cProp, oHashTgt)
	local jValor		:= nil
	local xProp			:= nil
	default cProp		:= ''
	if hmGet(oHashTgt,SC5->(Recno()),@jValor)
		if empty(cProp)
			xProp := jValor
		else
			xProp := jValor[cProp]
		endif
	endif
return(xProp)


static function zHMClone(oFrom, oTo)
	local aLstFrm 	:= {}
	local nX		:= 0
	local cProd		:= ''
	local nSaldo	:= 0
	local xValue	:= nil
	HMList(oFrom, aLstFrm)
	HMClean(oTo)
	for nX := 1 to len(aLstFrm)
		cProd 	:= aLstFrm[nX,1]
		nSaldo 	:= aLstFrm[nX,2,1,2]
		if  ! HMGet( oTo , cProd , @xValue )
			HMAdd(oTo,{cProd,nSaldo})
		endif
	next nX
return(nil)


static function setTxt(oSay, cTxt)
	oSay:SetText(cTxt)
	oSay:CtrlRefresh()
	ProcessMessage()
return nil


/* QUERYES */

static function qryReslTmp(cTableName)
	local cQry := ''
	cQry += " SELECT " 
	cQry += " C_ID										   AS SIMULACAO, "
	cQry += " COUNT(DISTINCT C_PEDIDO)                     AS QTD_PEDIDO, "
	cQry += " SUM(CASE WHEN N_FINAL = 1 THEN 1 ELSE 0 END) AS PEDIDO_FECHADO, "
	cQry += " SUM(CASE WHEN (DATEDIFF(DAY , GETDATE(),CONVERT(DATE,C_DT_FAT)) < -3) "
	cQry += " THEN 1 ELSE 0 END)							AS QTD_ATRASADO, "
	cQry += " SUM(N_VNECES)								    AS VALOR_NECESSARIO, "
	cQry += " SUM(N_VATEND)								    AS VALOR_ATENDIDO, "
	cQry += " SUM( CASE WHEN C_PARCIAL = 'S' THEN N_VATEND  "
	cQry += " ELSE 0 END ) 								    AS ATEND_PARCIAL_VLR " 
	cQry += " FROM " + cTableName
	cQry += " GROUP BY C_ID "
return cQry


static function qryTotBlest(cPedido)
	local cQRy := ''
	cQry += " SELECT  "
	cQry += " ISNULL(SUM(SC9.C9_QTDLIB * SC6.C6_PRCVEN), 0) AS [TOTAL] "
	cQry += " FROM  %SC9.SQLNAME%  WITH (NOLOCK) "
	cQry += " INNER JOIN  %SC6.SQLNAME%  WITH (NOLOCK) "
	cQry += " ON SC9.C9_FILIAL 	= SC6.C6_FILIAL "
	cQry += " AND SC9.C9_PEDIDO = SC6.C6_NUM "
	cQry += " AND SC9.C9_ITEM 	 = SC6.C6_ITEM "
	cQry += " AND SC9.C9_PRODUTO = SC6.C6_PRODUTO "
	cQry += " AND SC6.R_E_C_N_O_ = SC6.R_E_C_N_O_ "
	cQry += " AND SC9.D_E_L_E_T_ = SC6.D_E_L_E_T_  "
	cQry += " WHERE %SC9.XFILIAL% "
	if empty(cPedido)
		cQry += " AND SC9.C9_PEDIDO NOT IN(' ')"
	else
		cQry += " AND SC9.C9_PEDIDO = '" + cPedido + "' "
	endif
	cQry += " AND SC9.C9_BLCRED IN (' ') "
	cQry += " AND SC9.C9_BLEST  IN ('02') "
	cQry += " AND SC9.C9_SERIENF NOT IN ('U') "
	cQry += " AND %SC9.NOTDEL% "
return cQry


static function cbcQRYBFEst()
	local cQry := ''
	cQry += " SELECT " 
	cQry += " LEFT(SBF.BF_PRODUTO,10)   AS [Produto], "
	cQry += " SBF.BF_LOCALIZ			AS [Acond], "
	cQry += " (SBF.BF_QUANT - SBF.BF_EMPENHO) AS [Disponivel] "
	cQry += " FROM  "
	cQry +=   RetSqlName('SBF') + " SBF WITH (NOLOCK) " 
	cQry += " INNER JOIN " +  RetSqlName('SB1') + " SB1 WITH (NOLOCK) " 
	cQry += " ON ''					= SB1.B1_FILIAL "
	cQry += " AND SBF.BF_PRODUTO	= SB1.B1_COD "
	cQry += " AND SBF.D_E_L_E_T_	= SB1.D_E_L_E_T_ "
	cQry += " WHERE  "
	cQry += " SBF.BF_FILIAL 		= '" + xFilial('SBF') + "' " 
	cQry += " AND SBF.BF_LOCAL 		= '01' "
	cQry += " AND ((SBF.BF_QUANT - SBF.BF_EMPENHO) > 0) "
	cQry += " AND SB1.B1_TIPO 		= 'PA' "
	cQry += " AND SBF.D_E_L_E_T_ 	= '' "
return(cQry)


static function getBob(cPed)
	local cQry := ''
	cQry += " SELECT  "
	cQry += " SZE.R_E_C_N_O_ AS [REC], "
	cQry += " SC6.C6_ACONDIC AS [ACONDIC] "
	cQry += " FROM  %SZE.SQLNAME%  WITH (NOLOCK) "
	cQry += " INNER JOIN  %SC6.SQLNAME%   WITH (NOLOCK) "
	cQry += " 	ON SZE.ZE_FILIAL 	= SC6.C6_FILIAL "
	cQry += " 	AND SZE.ZE_PEDIDO  	= SC6.C6_NUM "
	cQry += " 	AND SZE.ZE_ITEM 	= SC6.C6_ITEM "
	cQry += " 	AND SC6.R_E_C_N_O_ 	= SC6.R_E_C_N_O_ "
	cQry += " 	AND SZE.D_E_L_E_T_ 	= SC6.D_E_L_E_T_ "
	cQry += " 	INNER JOIN  %SC9.SQLNAME%   WITH (NOLOCK) "
	cQry += " ON SZE.ZE_FILIAL 		= SC9.C9_FILIAL "
	cQry += " 	AND '  '  			= SC9.C9_BLCRED "
	cQry += " 	AND '02'  			= SC9.C9_BLEST "
	cQry += " 	AND SZE.ZE_PEDIDO  	= SC9.C9_PEDIDO "
	cQry += " 	AND SZE.ZE_ITEM 	= SC9.C9_ITEM "
	cQry += " 	AND SC9.R_E_C_N_O_ 	= SC9.R_E_C_N_O_ "
	cQry += " 	AND SZE.D_E_L_E_T_ 	= SC9.D_E_L_E_T_ "
	cQry += " WHERE %SZE.XFILIAL% "
	cQry += " 	AND ZE_STATUS = 'P' "
	cQry += " 	AND ZE_PEDIDO = '" + cPed + "' "
	cQry += " 	AND %SZE.NOTDEL% "
	cQry += " 	AND %SC6.NOTDEL% "
return cQry


static function getBlq(cPed)
	local cQry := ''
	cQry 	+= " SELECT  "
	cQry 	+= " SC9.R_E_C_N_O_ AS [RECC9], "
	cQry 	+= " SC6.R_E_C_N_O_ AS [RECC6], "
	cQry 	+= " SB1.R_E_C_N_O_ AS [RECB1] "
	cQry 	+= " FROM  %SC9.SQLNAME%  WITH (NOLOCK) "
	cQry	+= "  INNER JOIN " +  RetSqlName('SC6')  + " SC6  WITH (NOLOCK) "
	cQry	+= "  	ON SC9.C9_FILIAL 	= SC6.C6_FILIAL  " 
	cQry	+= "  	AND SC9.C9_PEDIDO	= SC6.C6_NUM  "
	cQry	+= "  	AND SC9.C9_ITEM 	= SC6.C6_ITEM  " 
	cQry	+= "  	AND SC9.C9_PRODUTO 	= SC6.C6_PRODUTO "
	cQry	+= "  	AND SC6.R_E_C_N_O_  = SC6.R_E_C_N_O_ "  
	cQry	+= "  	AND SC9.D_E_L_E_T_  = SC6.D_E_L_E_T_
	cQry	+= "  INNER JOIN " +  RetSqlName('SF4')  + " SF4  WITH (NOLOCK) "
	cQry	+= "  	ON '' 				= SF4.F4_FILIAL  " 
	cQry	+= "  	AND SC6.C6_TES		= SF4.F4_CODIGO  "
	cQry	+= "  	AND SF4.R_E_C_N_O_  = SF4.R_E_C_N_O_ "  
	cQry	+= "  	AND SC6.D_E_L_E_T_  = SF4.D_E_L_E_T_
	cQry	+= "  INNER JOIN " +  RetSqlName('SB1')  + " SB1  WITH (NOLOCK) "
	cQry	+= "  	ON '" + xFilial('SB1') + "'	= SB1.B1_FILIAL  " 
	cQry	+= "	AND 'PA'			= SB1.B1_TIPO "
	cQry	+= "  	AND SC9.C9_PRODUTO	= SB1.B1_COD  " 
	cQry	+= "  	AND SB1.R_E_C_N_O_  = SB1.R_E_C_N_O_ "  
	cQry	+= "  	AND SC9.D_E_L_E_T_  = SB1.D_E_L_E_T_
	cQry += " WHERE %SC9.XFILIAL% "
	cQry += " AND C9_PEDIDO = '" + cPed + "' "
	cQry += " AND C9_BLCRED IN (' ' ) "
	cQry += " AND C9_BLEST IN ('02' ) "
	cQry += " AND SC9.C9_SERIENF <> 'U' "
	cQry += " AND SF4.F4_ESTOQUE = 'S' "
	cQry += " AND %SC9.NOTDEL% "
return cQry


static function getQryCart()
	local cQry := ''
	cQry += " SELECT "
	cQry += " SC5.R_E_C_N_O_  AS [RECNO],"
	cQry += " SC5.C5_NUM      AS [PEDIDO],"
	cQry += " CASE WHEN SC5.C5_TIPOLIB = 'P' THEN '1' ELSE '2' END 					AS [PRIOR],   "
	cQry += " CASE WHEN SC5.C5_ENTREG  = ''  THEN 'ZZZZZ' ELSE SC5.C5_ENTREG END 	AS [DT_ENTR], "
	cQry += " CASE WHEN SC5.C5_PARCIAL = 'N' THEN '1' ELSE '2' END 					AS [PARCIAL], "
	cQry += " CASE WHEN SC5.C5_DTFAT   = ''  THEN 'ZZZZZ' ELSE SC5.C5_DTFAT END 	AS [DT_FAT]  "
	cQry += " FROM "+ retSqlName('SC5') + " SC5 WITH (NOLOCK) "
	/*
	cQry += " INNER JOIN " +  retSqlName('SA1') + " SA1 WITH (NOLOCK) "
	cQry += " ON ''				= SA1.A1_FILIAL "
	cQry += " AND SC5.C5_CLIENTE	= SA1.A1_COD "
	cQry += " AND SC5.C5_LOJACLI	= SA1.A1_LOJA "
	cQry += " AND SC5.D_E_L_E_T_	= SA1.D_E_L_E_T_ "
	*/
	cQry += " WHERE "
	cQry += " SC5.C5_FILIAL + SC5.C5_NUM  IN ( "
	cQry += "  SELECT " 
	cQry += " 	DISTINCT SC5.C5_FILIAL + SC9.C9_PEDIDO AS [CHAVE] "
	cQry += " FROM " + RetSqlName('SC9') + " SC9 WITH (NOLOCK) "
	cQry += " INNER JOIN " +  RetSqlName('SC6') + " SC6  WITH (NOLOCK) " 
	cQry += " ON SC9.C9_FILIAL	= SC6.C6_FILIAL "
	cQry += " AND SC9.C9_PEDIDO	= SC6.C6_NUM "
	cQry += " AND SC9.C9_ITEM		= SC6.C6_ITEM " 
	cQry += " AND SC9.C9_PRODUTO	= SC6.C6_PRODUTO  "
	cQry += " AND SC6.R_E_C_N_O_	= SC6.R_E_C_N_O_  "
	cQry += " AND SC9.D_E_L_E_T_	= SC6.D_E_L_E_T_  "
	cQry += " INNER JOIN " + RetSqlName('SC5') + " SC5 WITH (NOLOCK) " 
	cQry += " ON  SC6.C6_FILIAL	= SC5.C5_FILIAL " 
	cQry += " AND SC6.C6_NUM		= SC5.C5_NUM " 
	cQry += " AND SC5.R_E_C_N_O_	= SC5.R_E_C_N_O_ " 
	cQry += " AND SC6.D_E_L_E_T_	= SC5.D_E_L_E_T_ " 
	cQry += " INNER JOIN " + RetSqlName('SB1') + " SB1 WITH (NOLOCK) " 
	cQry += " ON ''				= SB1.B1_FILIAL "
	cQry += " AND SC9.C9_PRODUTO	= SB1.B1_COD "
	cQry += " AND SC9.D_E_L_E_T_	= SB1.D_E_L_E_T_ "
	cQry += " INNER JOIN " + RetSqlName('SF4') + " SF4 WITH (NOLOCK) "
	cQry += " ON ''				= SF4.F4_FILIAL "
	cQry += " AND SC6.C6_TES		= SF4.F4_CODIGO "
	cQry += " AND SC6.D_E_L_E_T_	= SF4.D_E_L_E_T_ "
	cQry += " WHERE " 
	cQry += " SC9.C9_FILIAL IN ('" + xFilial('SC9') + "') " 
	cQry += " AND SC9.C9_PEDIDO NOT IN(' ') " 
	cQry += " AND SC9.C9_BLCRED IN (' ') " 
	cQry += " AND SC9.C9_BLEST  IN ('02') " 
	cQry += " AND SC9.C9_SERIENF NOT IN ('U') " 
	cQry += " AND SC5.C5_LIBEROK = 'S' "
	cQry += " AND C5_NOTA = '' "
	cQry += " AND C5_TIPO = 'N' "
	cQry += " AND SC6.C6_BLQ <> 'R' "
	cQry += " AND SF4.F4_ESTOQUE = 'S' "
	cQry += " AND SB1.B1_TIPO = 'PA' "
	cQry += " AND SC9.D_E_L_E_T_ = '' "
	cQry += " ) "
return cQry
