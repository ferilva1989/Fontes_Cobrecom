#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'
#Include 'statusPedido.ch'

#define NOME_CAMPO 1
#define TAMANHO	1
#define DECIMAL 2
#define TIPO 3
#define TIPO_TRB 2
#define TAM_TRB 3
#define DEC_TRB 4
#define NOME_SQL 2
#define INFO_TRB 3
#define INFO_BROWSER 4
#define TITULO_BROWSE 2
#define TIPO_BROWSE	3
#define TAM_BROWSE 4
#define DEC_BROWSE 5
#define PIC_BROWSE 6
#define TEM_INFO 5
#define LINHA	chr(13) + chr(10)


/*/{Protheus.doc} cbcLibEmpDash
@author bolognesi
@since 12/02/2019
@version 1.0
@param oCtrl, object, Objeto da classe cbcLibEmp (Controller)
@type function
@description Função inicial que recebe estancia unica do controller oferecendo seus metodos
e propriedades na forma (static oMainCtrl) , inicia as montagens de telas e opções de marcação.
/*/
user function cbcLibEmpDash(oCtrl)
	local aCoors 		:= FWGetDialogSize( oMainWnd )
	local oFWLayer		:= nil
	local oPanelPedido	:= nil
	local oPanelItem	:= nil
	local oPanelLiber	:= nil
	local oPanelEmp		:= nil
	local aColPed		:= {}
	local aColItm		:= {}
	local aColLib		:= {}
	local aColEmp		:= {}
	local bPedDoMark	:= {|| doMark(oBrwPedido,'C5_OK')}
	local bLibDoMark	:= {|| doMark(oBrwLiber,'C9_OK')}
	local bEmpDoMark	:= {|| doMark(oBrwEmp,'DC_OK')}
	local cAlsPed		:= ''
	local BFQUANT		:= {}
	local aArea			:= GetArea()
	local aAreaC5		:= SC5->(GetArea())
	local aAreaC6		:= SC6->(GetArea())
	local aAreaC9		:= SC9->(GetArea())
	local aAreaBF		:= SBF->(GetArea())
	local aAreaB2		:= SB2->(GetArea())
	local aAreaDC		:= SDC->(GetArea())
	local aAreaZE		:= SZE->(GetArea())
	Local oStatic    	:= IfcXFun():newIfcXFun()
	local bErro			:= nil
	private cFilterPed	:= ''
	private oBrwPedido	:= nil
	private oBrwItem	:= nil
	private oBrwLiber	:= nil
	private oBrwEmp		:= nil
	private oRelItmPed	:= nil
	private oRelLib		:= nil
	private oRelEmp		:= nil
	private oHashFilter := HMNew()
	private oHashDados  := HMNew()
	private oHashBobin	:= HMNew()
	private oHashPedFil := HMNew()
	private oHashFilItu	:= HMNew()
	private oHashFilTl	:= HMNew()
	static oMainCtrl	:= nil

	oCtrl:retSelf(@oMainCtrl)
	SetKey(VK_F12, {|| defPercDes()})
	bErro		:= ErrorBlock({|oErr| oStatic:sP(2):callStatic('cbcLibEmp','HandleEr',oErr, oMainCtrl)})
	BEGIN SEQUENCE
		cAlsPed := 'SC5'
		DbSelectArea('SC5')
		cFilterPed := u_zLVldPed('SC5',,,'01')  
		SC5->(DBSetOrder(3))

		Define MsDialog oDlgPrinc Title 'Liberação e Empenho de Pedidos ' + Alltrim(oMainCtrl:getId()) From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
		// Posicionamentos de Tela
		oFWLayer := FWLayer():New()
		oFWLayer:Init( oDlgPrinc, .F., .T. )

		oFWLayer:AddCollumn('ESQUERDA', 35, .F.)
		oFWLayer:SetColSplit('ESQUERDA', CONTROL_ALIGN_LEFT)
		oFWLayer:AddWindow('ESQUERDA', 'ESQUERDA_BAIXO', 'Pedidos', 100, .T., .F.)
		oPanelPedido := oFWLayer:GetWinPanel('ESQUERDA', 'ESQUERDA_BAIXO')

		oFWLayer:AddCollumn('MEIO', 35, .F.)
		oFWLayer:SetColSplit('MEIO', CONTROL_ALIGN_RIGHT)
		oFWLayer:AddWindow('MEIO', 'MEIO_CIMA01', 'Bloqueio Estoque', 100, .T., .F.)
		oPanelLiber := oFWLayer:GetWinPanel('MEIO', 'MEIO_CIMA01')

		oFWLayer:AddCollumn('DIREITA', 30, .F.)
		oFWLayer:SetColSplit('DIREITA', CONTROL_ALIGN_RIGHT)
		oFWLayer:AddWindow('DIREITA', 'DIREITA_CIMA01', 'Itens', 50, .T., .F.)
		oPanelItem := oFWLayer:GetWinPanel('DIREITA', 'DIREITA_CIMA01')	
		oFWLayer:AddWindow('DIREITA', 'DIREITA_CIMA02', 'Empenhos', 50, .T., .F.)
		oPanelEmp := oFWLayer:GetWinPanel('DIREITA', 'DIREITA_CIMA02')

		// Iniciar com os layer ocultos
		oFWLayer:winChgState ( 'DIREITA','DIREITA_CIMA01') 
		oFWLayer:clickColSplit('DIREITA')
		oFWLayer:clickColSplit('MEIO')

		// Pedidos
		aColPed 	:= getFlds('BRW', 'PEDIDOS')
		montaBrw(@oBrwPedido,oPanelPedido,'Pedidos',cAlsPed,aColPed,'2',bPedDoMark,'cbcMnPed','C5_OK', .T.,cFilterPed)

		// Itens Pedido
		aColItm		:= getFlds('BRW', 'ITEM')
		montaBrw(@oBrwItem,oPanelItem,'Itens','SC6',aColItm,'3',{||.T.},'','', .F.,'', 'C6_QTDVEN')

		// Blq. Estoque
		aColLib		:= getFlds('BRW', 'LIBER')
		montaBrw(@oBrwLiber,oPanelLiber,'Blq. Estoque','SC9',aColLib,'4',bLibDoMark,'cbcMnLib','C9_OK', .T., '', 'C9_QTDLIB')

		// Empenhos
		aColEmp		:= getFlds('BRW', 'EMP')
		montaBrw(@oBrwEmp,oPanelEmp,'Empenhos','SDC',aColEmp,'5',bEmpDoMark,'cbcMnEmp','DC_OK', .T., '','DC_QUANT')

		// Relacionamento dos Browsers
		oRelItmPed 	:= FWBrwRelation():New()
		oRelLib		:= FWBrwRelation():New()
		oRelEmp		:= FWBrwRelation():New()

		// Itens
		oRelItmPed:AddRelation(oBrwPedido , oBrwItem, {;
		{'SC6->(C6_FILIAL)', 'xFilial( "SC6" )'},;
		{'SC6->(C6_NUM)', 	 'C5_NUM'} } )
		// Blq. Estoque
		oRelLib:AddRelation(oBrwPedido , oBrwLiber,{;
		{"SC9->(C9_FILIAL)", " xFilial('SC9') "},;
		{"SC9->(C9_PEDIDO)", " C5_NUM "},;
		{"SC9->(C9_BLCRED)", " Space( " + Alltrim(Str(TamSx3('C9_BLCRED')[1])) + " ) "},;
		{"SC9->(C9_BLEST)",  " StrZero(2,2) "} } )
		// Empenhos
		oRelEmp:AddRelation(oBrwPedido , oBrwEmp,{;
		{'SDC->(DC_FILIAL)', 'xFilial( "SDC" )'},;
		{'SDC->(DC_PEDIDO)', 'C5_NUM'} } )

		oRelItmPed:Activate()
		oRelLib:Activate()
		oRelEmp:Activate()

		// Remove oChange para não mais sincronizar os relacionamentos
		// a função updRel() que agora atualiza os relacionamentos 
		oBrwPedido:SetChange({|| onChange()})

		initHash()
		defRelPed()
		defPedFil() 
		oBrwPedido:AddFilter('FIXO'	,"staticcall(cbcLibEmpDash, helpPedFil)",.T.,.T.)
		oBrwPedido:FwFilter():ExecuteFilter()
		if MsgNoYes('Distribuir Saldo?', 'Pergunta')
			FWMsgRun(,{|oSay|iniAnali(oBrwPedido, 'C5_OK', oMainCtrl)}, "Distribuindo Saldos","Distribuindo Saldos...")
		endif
		Activate MsDialog oDlgPrinc Center

		RECOVER
	END SEQUENCE
	ErrorBlock(bErro)

	SetKey(VK_F12, {||})
	FreeObj(oFWLayer)
	FreeObj(oPanelPedido)
	FreeObj(oPanelItem)	
	FreeObj(oPanelLiber)	
	FreeObj(oPanelEmp)	
	FreeObj(oRelItmPed)		
	FreeObj(oRelLib)	
	FreeObj(oRelEmp)		
	FreeObj(oBrwPedido)
	FreeObj(oBrwItem)
	FreeObj(oBrwLiber)
	FreeObj(oBrwEmp)
	FreeObj(oMainCtrl)	
	RestArea(aAreaZE)
	RestArea(aAreaDC)
	RestArea(aAreaB2)
	RestArea(aAreaBF)
	RestArea(aAreaC9)
	RestArea(aAreaC5)
	RestArea(aArea)
return(nil)


/*/{Protheus.doc} vLELibBob
@author bolognesi
@since 12/02/2019
@version 1.0
@param nRecC5, numeric, Recno do pedido 
@param oCbcLibEmp, object, Objeto controller
@type function
@description Partindo de um pedido localiza todos os itens (SC6) com
acondicionamento B(bobina), e os relaciona com bobinas pesadas (SZE)
para o pedido item, em um relacionamento ( SC6(1) -> SZE(N) )
/*/
user function vLELibBob(nRecC5,oCbcLibEmp)
	local aArea			:= GetArea()
	local aAreaC6		:= SC6->(GetArea())
	local oRelItm		:= nil
	local oPnlBob		:= nil
	local oPnlItm		:= nil
	local oFWLayer		:= nil
	local aItemFields	:= {} 
	local aBobFields	:= {}
	local aAr			:= {}
	private oMarkSZE 	:= nil
	private oItm		:= nil
	private nTotPed		:= 0
	private lOnlyPed	:= .F.

	default nRecC5		:= 0
	if nRecC5 > 0
		lOnlyPed := .T.
		SC5->(DbGoTo(nRecC5))
	endif

	Define MsDialog oDlgBob Title 'Liberação de Bobinas' From 5, 0 To 550, 1100 Pixel
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgBob, .F., .T. )
	oFWLayer:AddLine('CIMA', 50, .F. )
	oFWLayer:AddCollumn('CONTEUDO_CIMA'	,100, .T., 'CIMA' )
	oFWLayer:AddLine('BAIXO'			,50, .F. )
	oFWLayer:AddCollumn('CONTEUDO_BAIXO',100, .T., 'BAIXO' )

	oPnlBob 	:= oFWLayer:GetColPanel('CONTEUDO_BAIXO','BAIXO')
	oMarkSZE 	:= FWMarkBrowse():New()
	oMarkSZE:SetOwner(oPnlBob)
	oMarkSZE:SetAlias("SZE")
	oMarkSZE:SetDescription("Bobinas")
	aBobFields	:= {'ZE_QUANT', 'ZE_ITEM', 'ZE_PRODUTO','ZE_NUMBOB','ZE_PEDIDO', 'ZE_ITEM', 'ZE_QUANT'}
	oMarkSZE:SetOnlyFields(aBobFields)
	oMarkSZE:SetProfileID('bobItem')
	oMarkSZE:SetFieldMark( "ZE_OK" )
	oMarkSZE:SetUseFilter(.T.)
	oMarkSZE:SetMenuDef('zMLibBob')
	oMarkSZE:SetChange({|| .T.})
	oMarkSZE:DisableReport()
	oMarkSZE:CleanFilter()
	oMarkSZE:SetFilterDefault( u_zLVldPed('SC6SZE',lOnlyPed ) )
	oMarkSZE:SetSemaphore(.T.)
	oMarkSZE:OpenSemaphore()
	oMarkSZE:SetCustomMarkRec({||doMark(oMarkSZE,'ZE_OK')})
	oMarkSZE:AddButton('Total Bobinas', {|| calcTotBob(oCbcLibEmp) },,7,)
	oMarkSZE:AddButton('Inverter Marcação', {|| invertMark('SZE', oMarkSZE, 'ZE_OK', oCbcLibEmp) },,7,)
	oMarkSZE:Activate()

	oPnlItm := oFWLayer:GetColPanel('CONTEUDO_CIMA','CIMA')
	oItm 	:= FWMBrowse():New()
	oItm:SetOwner(oPnlItm)
	oItm:SetAlias("SC6")
	oItm:SetDescription('Itens Pedido ' + SC5->(C5_NUM) )
	aItemFields := {'C6_NUM', 'C6_ITEM', 'C6_PRODUTO','C6_DESCRI', 'C6_QTDVEN', 'C6_LANCES'}
	oItm:SetOnlyFields(aItemFields)
	oItm:SetChange({|| .T.})
	oItm:SetUseFilter(.T.)
	oItm:SetMenuDef('')
	oItm:SetProfileID('itemBob')
	oItm:DisableReport()
	oItm:Activate()

	oRelItm := FWBrwRelation():New()
	oRelItm:AddRelation(oMarkSZE ,oItm , {;
	{"C6_FILIAL"	, 	"ZE_FILIAL"},;
	{"C6_NUM"		, 	"ZE_PEDIDO"},;
	{"C6_ITEM"		,	"ZE_ITEM"}} )
	oRelItm:Activate()

	// oItm:ExecuteFilter(.T.)
	// oItm:Refresh()

	ACTIVATE MSDIALOG oDlgBob CENTERED
	SC6->(DbCloseArea())
	SZE->(DbCloseArea())
	FreeObj(oFWLayer)
	FreeObj(oPnlItm)
	FreeObj(oPnlBob)
	FreeObj(oRelItm)
	FreeObj(oMarkSZE)
	FreeObj(oItm)
	FreeObj(oDlgBob)
	RestArea(aAreaC6)
	RestArea(aArea)
return(nil)


/*/{Protheus.doc} vLERelPed
@author bolognesi
@since 12/02/2019
@version 1.0
@param nRecSc5, numeric, Recno pedido
@param nRecSC6, numeric, Recno Item
@type function
@description Utilizada para abrir tela mostrando os pedidos e itens
relacionados pelo campo (C6_ZZPVORI)
/*/
user function vLERelPed(nRecSc5, nRecSC6, lEmp, nRecFrm, nRecTo)
	local oModal		:= nil
	local oContainer	:= nil
	local oFWLayer		:= nil
	local oPedPanel		:= nil
	local oItmPanel		:= nil
	local oPed			:= nil
	local oItm			:= nil
	local oRelItm		:= nil
	local aPedFields	:= {}
	local aItmFields	:= {}
	local cPedFrom		:= ''
	local cPedTo		:= ''
	local cFilChv		:= iif(FwFilial() == '01', '02', '01')
	default lEmp		:= .T.
	default nRecFrm		:= 0
	default nRecTo		:= 0

	disAbleFilter()
	if lEmp
		SC5->(DbGoTo(nRecSc5))
		SC6->(DbGoTo(nRecSC6))
		cPedFrom 	:= SC5->(C5_NUM)
		cPedTo		:= SC6->(C6_ZZPVORI)
	else
		SC5->(DbGoTo(nRecFrm))
		cPedFrom 	:= SC5->(C5_NUM)
		nRecSc5		:= nRecFrm
		SC5->(DbGoTo(nRecTo))
		cFilChv	:= SC5->(C5_FILIAL)
		cPedTo 	:= SC5->(C5_NUM)
	endif

	if !empty(cPedTo)
		SC5->(DbSetOrder(1))
		if SC5->(DbSeek(cFilChv + Left(cPedTo,TamSx3('C5_NUM')[1])  ,.F.))
			nRecTo := SC5->(Recno())
			oModal  := FWDialogModal():New()        
			oModal:SetEscClose(.T.)
			oModal:setTitle("Relacionamento Pedidos")
			oModal:setSize(340, 440)
			oModal:createDialog()
			oModal:addCloseButton(nil, "Fechar")
			oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
			oContainer:SetCss("")
			oContainer:Align := CONTROL_ALIGN_ALLCLIENT

			oFWLayer := FWLayer():New()
			oFWLayer:Init( oContainer, .F., .T. )
			oFWLayer:AddLine('CIMA', 50, .F. )
			oFWLayer:AddCollumn('CONTEUDO_CIMA'	,100, .T., 'CIMA' )
			oFWLayer:AddLine('BAIXO'			,50, .F. )
			oFWLayer:AddCollumn('CONTEUDO_BAIXO',100, .T., 'BAIXO' )

			oPedPanel := oFWLayer:GetColPanel('CONTEUDO_CIMA','CIMA')
			oPed 	:= FWMBrowse():New()
			oPed:SetOwner(oPedPanel)
			oPed:SetAlias("SC5")
			oPed:SetMenuDef('')
			oPed:SetProfileID('pedRel')
			oPed:CleanFilter()
			oPed:SetFilterDefault( "@R_E_C_N_O_ IN(" + cValToChar(nRecSc5) + ", " + cValToChar(nRecTo) + " ) " )
			oPed:DisableReport()
			oPed:Activate()

			oItmPanel := oFWLayer:GetColPanel('CONTEUDO_BAIXO','BAIXO')
			oItm 	:= FWMBrowse():New()
			oItm:SetOwner(oItmPanel)
			oItm:SetAlias("SC6")
			aItmFields	:= {'C6_ITEM', 'C6_LOCAL', 'C6_SEMANA','C6_PRODUTO', 'C6_DESCRI', 'C6_LANCE', 'C6_ACONDIC', 'C6_QTDVEN', 'C6_ZZPVORI'}
			oItm:SetOnlyFields(aItmFields)
			oItm:SetMenuDef('')
			oItm:SetProfileID('itemCRel')
			oItm:CleanFilter()
			oItm:DisableReport()
			oItm:Activate()

			oRelItm := FWBrwRelation():New()
			oRelItm:AddRelation(oPed ,oItm , {;
			{'SC6->(C6_FILIAL)'	, 	'C5_FILIAL'},;
			{'SC6->(C6_NUM)'	, 	'C5_NUM'}})
			oRelItm:Activate()

			oModal:Activate()
			if lEmp
				oBrwPedido:SetFilterDefault(u_zLVldPed('SC5'))
				oBrwPedido:Goto(nRecSc5, .T.)
				oBrwPedido:Refresh()
				updRel()
			endif
			FreeObj(oRelItm)
			FreeObj(oPedPanel)
			FreeObj(oItmPanel)
			FreeObj(oItm)
			FreeObj(oPed)
			FreeObj(oFWLayer)
			FreeObj(oContainer)
			FreeObj(oModal)
		endif
	endif
	reloadFldr()
return(nil)


static function updRel()
	local aExecRel	:= {}
	local aIndEmp	:= {}
	local aIndLib	:= {}
	local aItmPed	:= {}

	// initHash()

	oBrwItem:oBrowse:show()
	oBrwLiber:oBrowse:show()
	oBrwEmp:oBrowse:show()

	aExecRel := {}
	aadd(aItmPed,oRelItmPed:aRelation[1,2] )
	aadd(aItmPed,oRelItmPed:aRelation[1,3] )
	aadd(aItmPed,oRelItmPed:aRelation[1,4] )
	aadd(aItmPed,{|| .T.})
	aadd(aExecRel, aItmPed)
	__ExecRelation(aExecRel,,"")

	aExecRel := {}
	aadd(aIndEmp,oRelEmp:aRelation[1,2] )
	aadd(aIndEmp,oRelEmp:aRelation[1,3] )
	aadd(aIndEmp,oRelEmp:aRelation[1,4] )
	aadd(aIndEmp,{|| .T.})
	aadd(aExecRel, aIndEmp)
	__ExecRelation(aExecRel,,"")

	aExecRel := {}
	aadd(aIndLib,oRelLib:aRelation[1,2] )
	aadd(aIndLib,oRelLib:aRelation[1,3] )
	aadd(aIndLib,oRelLib:aRelation[1,4] )
	aadd(aIndLib,{|| .T.})
	aadd(aExecRel, aIndLib)
	__ExecRelation(aExecRel,,"")

return(.T.)


static function onChange()
	oBrwItem:oBrowse:hide()
	oBrwLiber:oBrowse:hide()
	oBrwEmp:oBrowse:hide()
return(nil)


static function calcTotBob(oCbcLibEmp)
	local aAr 		:= SZE->(GetArea())
	local bSoma 	:= nil 
	private nTotal	:= 0
	bSoma := {|| nTotal += SZE->(ZE_QUANT)}
	SZE->(DbEval(bSoma) )
	oCbcLibEmp:setNotif('Totais' , 'Total Bobina: ' + Transform(nTotal,PesqPict('SC6', 'C6_QTDVEN')) +;
	' Total Item: ' + Transform(SC6->(C6_QTDVEN),PesqPict('SC6', 'C6_QTDVEN')), {}, .T., .F. )
	Restarea(aAr)
return(nil)


static function calcTot(oCbcLibEmp, cAls, cFldTot)
	local aAr 		:= (cAls)->(GetArea())
	local bSoma 	:= nil 
	private nTotal	:= 0
	bSoma := {|| nTotal += (cAls)->(&cFldTot)}
	(cAls)->(DbEval(bSoma) )
	oCbcLibEmp:setNotif('Totais' , 'Total: ' + Transform(nTotal,PesqPict('SC6', 'C6_QTDVEN')), {}, .T., .F. )
	Restarea(aAr)
return(nil)


static function invertMark(cAls, oBrw, cFldMrk, oCbcLibEmp)
	local aAr 		:= (cAls)->(GetArea())
	local bMark		:= nil
	local nPos		:= oBrw:at()
	bMark := {|| doMark(oBrw,cFldMrk) }
	FWMsgRun(, { |oSay| (cAls)->(DbEval(bMark) ) }, "Selecionando", " Aplicando marca aos registros...")
	Restarea(aAr)
	oBrw:GoTo(nPos)
	oBrw:Refresh()
return(nil)


static function infoLiber(cAls, oBrw, cMkFld, oMainCtrl)
	local oData 	:= oBrw:data()
	local nPosIni	:= oBrw:at()
	local lFind		:= .F.
	local lLoopCtrl	:= .T.
	local nTNecess	:= 0
	local nPbNecess := 0
	local nTAtendi	:= 0
	local nPbAtendi := 0
	local nTEmp		:= 0
	local nTFat		:= 0
	local cMask		:= PesqPict('SC5', 'C5_TOTAL')
	oData:Gotop()
	while !oData:isLast()
		nTNecess 	+= helpDados('necessario')
		nTAtendi 	+= helpDados('atendido')
		nTFat 	 	+= helpDados('faturado')
		nTEmp 	 	+= helpDados('empenhado')
		nPbNecess 	+= helpDados('peso_necessario')
		nPbAtendi	+= helpDados('peso_atendido')
		oData:Skip(1)
	enddo
	if nTNecess > 0
		oMainCtrl:setNotif('' ,;
		'Bloqueado: ' 	+ Transform(nTNecess, cMask) + LINHA +;
		'Atendemos: ' 	+ Transform(nTAtendi, cMask) + LINHA +;
		'Empenhado: ' 	+ Transform(nTEmp, 	cMask) + LINHA +;
		'Faturado: ' 	+ Transform(nTFat, 	cMask) + LINHA +;
		'PesoKG Bloq: '	+ Transform(nPbNecess, 	cMask) + LINHA +;
		'PesoKG Atend: '	+ Transform(nPbAtendi, 	cMask) + LINHA +;
		'% Blq/Atend: ' + Transform((((nTAtendi) * 100 ) / nTNecess), cMask), {}, .T., .F. )

	endif
	oData:GoTo(nPosIni)
	oBrw:Refresh()
return(nil)


static function exibSimu(oBrw, cMkFld, oMainCtrl, aInfDados, cTxtTotal)
	local aAreaC5 		:= SC5->(GetArea()) 
	local nX			:= 0
	local oBrowse		:= nil
	local oFont 		:= TFont():New('Courier new',,-12,.T.)
	local oModal		:= nil
	local oContainer	:= nil
	local oFWLayer		:= nil
	local oMainPanel 	:= nil
	local oSecPanel		:= nil
	default aInfDados	:= oMainCtrl:aPrioPed
	default cTxtTotal	:= oMainCtrl:cTxtTotal

	oModal  := FWDialogModal():New()        
	oModal:SetEscClose(.T.)
	oModal:setTitle("Distribuição de Saldos")
	oModal:setSize(240, 380)
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
	oModal:addOkButton({ || printTab(AClone(aInfDados), AClone(oBrowse:aColumns)) }, "Imprimir",{||.T.} )
	oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
	oContainer:SetCss("")
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT

	oFWLayer := FWLayer():New()
	oFWLayer:Init( oContainer, .F., .T. )
	oFWLayer:AddLine('CIMA', 70, .F. )
	oFWLayer:AddCollumn('CONTEUDO_CIMA'	,100, .T., 'CIMA' )
	oFWLayer:AddLine('BAIXO'			,30, .F. )
	oFWLayer:AddCollumn('CONTEUDO_BAIXO',100, .T., 'BAIXO' )

	oMainPanel := oFWLayer:GetColPanel('CONTEUDO_CIMA','CIMA')
	oSecPanel := oFWLayer:GetColPanel('CONTEUDO_BAIXO','BAIXO')

	oBrowse := MsBrGetDBase():new( 0, 0, 380, 130,,,, oMainPanel,,,,,,,,,,,, .F., "", .T.,, .F.,,, )
	oBrowse:setArray(aInfDados)
	oBrowse:addColumn( TCColumn():new( "Filial", 	 		{ || aInfDados[oBrowse:nAt, 1] },,,, "LEFT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "Info", 	 	 		{ || aInfDados[oBrowse:nAt, 2] },,,, "LEFT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "Prioriza", 	 		{ || aInfDados[oBrowse:nAt, 3] },,,, "LEFT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "Entrega", 	 		{ || aInfDados[oBrowse:nAt, 4] },,,, "LEFT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "Dt.Fatura",  		{ || aInfDados[oBrowse:nAt, 5] },,,, "LEFT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "Parcial", 	 		{ || aInfDados[oBrowse:nAt, 6] },,,, "LEFT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "Necessario", 		{ || aInfDados[oBrowse:nAt, 7] },,,, "RIGHT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "Atendido", 			{ || aInfDados[oBrowse:nAt, 8] },,,, "RIGHT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "Sld.Ped", 			{ || aInfDados[oBrowse:nAt, 9] },,,, "RIGHT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "Per_atendido", 		{ || aInfDados[oBrowse:nAt, 10] },,,, "RIGHT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "Empenhado", 		{ || aInfDados[oBrowse:nAt, 11] },,,,"RIGHT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "Faturado", 			{ || aInfDados[oBrowse:nAt, 12] },,,,"RIGHT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "Vendido", 			{ || aInfDados[oBrowse:nAt, 13] },,,,"RIGHT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "PesoKG Necessario", 	{ || aInfDados[oBrowse:nAt, 14] },,,,"RIGHT",, .F., .F.,,,, .F. ) )
	oBrowse:addColumn( TCColumn():new( "PesoKG Atendido", 	{ || aInfDados[oBrowse:nAt, 15] },,,,"RIGHT",, .F., .F.,,,, .F. ) )
	oBrowse:Refresh()	
	TSay():New(0,0,{||cTxtTotal},oSecPanel,,oFont,,,,.T.,CLR_RED,CLR_WHITE,320,220)

	oModal:Activate()
	FreeObj(oModal)
	FreeObj(oContainer)
	FreeObj(oFWLayer)
	FreeObj(oMainPanel)
	FreeObj(oSecPanel)
	FreeObj(oBrowse)
	RestArea(aAreaC5)
return(.T.)


static function printTab(aDados, aColu)
	local nX 		:= 0
	local aColuna	:= {}
	local aWSheet	:= {}
	local aTable	:= {}
	local aColun	:= {}
	local aDadCon	:= {}
	for nX := 1 to len(aColu)
		aadd(aColuna, aColu[nX]:cHeading)
	next nX
	Aadd(aColun, aColuna)
	if !empty(aColun) .and. !empty(aDados)
		Aadd(aWSheet,	{"Saldos"})
		Aadd(aTable,	{"Saldos"})
		Aadd(aDadCon,aDados)
		u_TExcArr(aDadCon,aColun,aWSheet,aTable)
	endif
return(.T.)


static function iniAnali(oBrw, cMkFld, oMainCtrl)
	FWMsgRun(,{|oSay|distSld(oBrw, cMkFld, oMainCtrl, oSay)}, "Distribuindo Saldos","Distribuindo Saldos...")
return(nil)


static function distSld(oBrw, cFldMrk, oCbcLibEmp, oSay, lSimu)
	local aAr 		:= GetArea()
	local aArC5 	:= SC5->(GetArea())
	local aArC6 	:= SC6->(GetArea())
	local aArC9 	:= SC9->(GetArea())
	local bMark		:= nil
	local nPos		:= oBrw:at()
	local oHash		:= nil
	local oHmClone	:= nil
	local aPed		:= {}
	local nX		:= 0
	local cIndex	:= ''
	local cIndex2   := ''
	local aParam	:= {}
	local nTam		:= 0
	local nTNecess	:= 0
	local nTPBNecess := 0
	local nTAtendi	:= 0
	local nTPBAtend	:= 0
	local nTFat		:= 0
	local nTEmp		:= 0
	local nTmpVlr	:= 0
	local nPedFech	:= 0
	local nTotPFech	:= 0
	local cMascara	:= PesqPict('SC5', 'C5_TOTAL')
	local aTmp		:= {}
	local oHmClone 	:= nil
	local lFchaPed	:= .F.
	default lSimu	:= .F.
	if !empty(aParam	:= howToOrder())
		cIndex 		:= aParam[1]
		cForma		:= aParam[2]
		cIndex2 	:= aParam[3]
		lFchaPed	:= aParam[4]
		oHash 		:= HMNew()
		// Prepara os dados para ordenação
		bMark := {|| orderPed(SC5->(Recno()), @aPed, cIndex, cIndex2)}
		SC5->(DbEval(bMark)) 
		// Ordenar o array
		if !empty(cIndex2)
			if !empty(cIndex)
				if cForma == 'ASC'
					aSort(aPed ,,, { |x,y| ( x[2] < y[2] ) .OR. ;
					( x[2] == y[2] .AND. x[3] > y[3] ) } )
				else
					aSort(aPed ,,, { |x,y| ( x[2] > y[2] ) .OR. ;
					( x[2] == y[2] .AND. x[3] > y[3] ) } )
				endif
			endif
		else
			if !empty(cIndex)
				if cForma == 'ASC'
					ASort(aPed,,,{|x,y| x[2] < y[2]})
				else
					ASort(aPed,,,{|x,y| x[2] > y[2]})
				endif
			endif
		endif
		// Prepara Estoque virtual
		u_zLVirEst(@oHash)

		// Realiza o atendimento com estoque
		nTam := len(aPed)
		if !lSimu
			oCbcLibEmp:aPrioPed := {}
			oCbcLibEmp:cTxtTotal := ''
		endif

		if lFchaPed
			oHmClone := HMNew()
		endif

		for nX := 1 to nTam
			SC5->(DbGoTo(aPed[nX,1]))
			oSay:SetText('Pedido ' + Alltrim(SC5->(C5_NUM))  + ' ' + cValToChar(nX) + '/' + cValToChar(nTam) )
			ProcessMessage()
			if lFchaPed
				// Obtem Copia do estoque quando opção de fechar pedido for prioridade, neste caso 
				// trabalhamos com dois hashs de estoque o clone inicia-se como uma copia do principal por pedido
				// e caso o pedido seja atendido por completo o commitamos o clone no principal do contrario não
				// empenhamos o produto deixando principal inalterado e livre para o proximo pedido			
				zHMClone(oHash, @oHmClone)
				doVirEmp(@oHmClone)
				if helpFilter() == 'BR_VERMELHO'
					HMSet(oHashDados, SC5->(Recno()), {{SC5->(Recno()),;
					{0, helpDados('necessario'),helpDados('peso_necessario'),0}}})
				else
					zHMClone(oHmClone, @oHash)
				endif
			else
				doVirEmp(@oHash)
			endif
			if !lSimu
				aTmp := {}
				aAdd(aTmp, Alltrim(SC5->(C5_FILIAL)))
				aAdd(aTmp, Alltrim(getDescPed()))
				aAdd(aTmp, Alltrim(SC5->(C5_TIPOLIB)))
				aAdd(aTmp, DtoC(SC5->(C5_ENTREG)) )
				aAdd(aTmp, DtoC(SC5->(C5_DTFAT)) )
				aAdd(aTmp, Alltrim(SC5->(C5_PARCIAL)))
				nTmpVlr := helpDados('necessario')
				nTNecess += nTmpVlr
				aAdd(aTmp, Transform(nTmpVlr,cMascara) ) 

				nTmpVlr := helpDados('atendido')
				nTAtendi += nTmpVlr
				aAdd(aTmp, Transform(nTmpVlr, cMascara))

				if helpDados('per_atendido') >= 100
					nPedFech++
					nTotPFech += nTmpVlr
				endif

				nTmpVlr := (helpDados('necessario') + helpDados('empenhado'))
				aAdd(aTmp, Transform(nTmpVlr, cMascara))

				nTmpVlr := helpDados('per_atendido')
				aAdd(aTmp, Transform(nTmpVlr, cMascara))

				nTmpVlr := helpDados('empenhado')
				nTEmp += nTmpVlr
				aAdd(aTmp, Transform(nTmpVlr, cMascara))

				nTmpVlr := helpDados('faturado')
				nTFat += nTmpVlr
				aAdd(aTmp, Transform(nTmpVlr, cMascara))

				aAdd(aTmp, Transform(SC5->(C5_TOTAL), cMascara))
				
				nTmpVlr := helpDados('peso_necessario')
				aAdd(aTmp, Transform(nTmpVlr, cMascara))
				nTPBNecess 	+= nTmpVlr
		
				nTmpVlr := helpDados('peso_atendido')
				aAdd(aTmp, Transform(nTmpVlr, cMascara))
				nTPBAtend 	+= nTmpVlr
				 
				aAdd(oCbcLibEmp:aPrioPed, aTmp)
			endif
		next nX
		if !lSimu
			oCbcLibEmp:cTxtTotal := ;
			'(A)-Bloqueado: ' 				+ Alltrim(Transform(nTNecess,cMascara)) 					 + LINHA +;
			'(B)-Atendemos: ' 				+ Alltrim(Transform(nTAtendi,cMascara))					 	 + LINHA +;
			'(C)-Ped(s) Fechados: ' 			+ Alltrim(Transform(nPedFech,cMascara)) +;
			' (D)-Total Ped(s) Fechados: '  	+ Alltrim(Transform(nTotPFech,cMascara)) 					 + LINHA +;
			'(E)-Empenhado: ' 				+ Alltrim(Transform(nTEmp,cMascara)) 						 + LINHA +;
			'(F)-Sld.Ped(s) (A+E): ' 			+ Alltrim(Transform((nTNecess + nTEmp) ,cMascara)) 			 + LINHA +;
			'(G)-PesoKG Necessario: ' 			+ Alltrim(Transform(nTPBNecess ,cMascara)) +;
			' (H)-PesoKG Atendido: ' 			+ Alltrim(Transform(nTPBAtend ,cMascara)) 			 		 + LINHA +;
			'(I)-Faturado: ' 					+ Alltrim(Transform(nTFat,cMascara )) 						 + LINHA
		endif	 
		FreeObj(oHash)
	endif
	RestArea(aArC9)
	RestArea(aArC6)
	RestArea(aArC5)
	RestArea(aAr)
	oBrw:GoTo(nPos)
return(nil)


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


static function howToOrder()
	local cIndex		:= ''
	local cIndex2		:= ''
	local cForma		:= ''
	local cVlr			:= ''
	local aFrom			:= {}
	local aTo			:= {}
	local aCmb			:= {}
	local aVlr			:= {}
	local aMacro		:= {}
	local oTFont 		:= nil
	local oModal		:= nil
	local oContainer	:= nil
	local oTree			:= nil
	local oList1		:= nil
	local nList1 		:= 1
	local oList2		:= nil
	local nList2 		:= 1
	local oSay1			:= nil
	local oSay2			:= nil
	local oSay3			:= nil
	local oCombo1		:= nil
	local oChkFchPed	:= nil
	local nX			:= 0
	local nPos			:= 0
	local lChk1			:= .F.

	oTFont 	:= TFont():New('Arial',,-16,.T.)
	oModal  := FWDialogModal():New()        
	oModal:SetEscClose(.T.)
	oModal:setTitle("Prioridades de empenho")
	oModal:setSize(240, 240)
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
	oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
	oContainer:SetCss("")
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT

	aadd(aMacro, {'Priorizado'		, 'SC5->(iif(C5_TIPOLIB == "P","1","2"))'} )
	aadd(aMacro, {'Entrega'			, 'SC5->(iif(empty(C5_ENTREG),"ZZZZZ", DtoS(C5_ENTREG)))'})
	aadd(aMacro, {'Parcial'			, 'SC5->(iif(C5_PARCIAL == "N","1","2"))'})
	aadd(aMacro, {'Dt.Faturamento'	, 'SC5->(iif(empty(C5_DTFAT),"ZZZZZ", DtoS(C5_DTFAT)))'})

	aTo		:= {'Priorizado','Dt.Faturamento','Entrega','Parcial'}
	aFrom 	:= {''}

	oSay1	:= TSay():New(01,20,{||'Opções'},oContainer,,oTFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	nList 	:= 1
	oList1 	:= TListBox():New(15,15,{|u|if(Pcount()>0,nList:=u,nList)},aFrom,100,100,,;
	oContainer,,,,.T.,,{||changeOpt(oList1, oList2)},oTFont)

	oSay2	:= TSay():New(01,125,{||'Selecionados'},oContainer,,oTFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	nList2	:= 1
	oList2 := TListBox():New(15,120,{|u|if(Pcount()>0,nList2:=u,nList2)},aTo,100,100,,;
	oContainer,,,,.T.,,{||changeOpt(oList2, oList1)}, oTFont)

	aVlr	:= {'', 'VALOR'}
	cVlr	:= aVlr[1]
	oSay3	:= TSay():New(130,15,{||'Valor'},oContainer,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oCombo1 := TComboBox():New(140,15,{|u|if(PCount()>0,cVlr:=u,cVlr)},;
	aVlr,100,20,oContainer,,,,,,.T.,,,,,,,,,'cVlr')

	aCmb	:= {'ASC', 'DESC'}
	cForma	:= aCmb[1]
	oSay3	:= TSay():New(130,120,{||'Ordem'},oContainer,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	oCombo1 := TComboBox():New(140,120,{|u|if(PCount()>0,cForma:=u,cForma)},;
	aCmb,100,20,oContainer,,,,,,.T.,,,,,,,,,'cForma')

	oChkFchPed := TCheckBox():New(160,15,'Fecha Pedido',{|u|if(PCount()>0,lChk1:=u,lChk1)},oContainer,100,210,,,,,,,,.T.,'Somente empenha se fecha pedido',,)

	oModal:Activate()
	for nX := 1 to len(aTo)
		if ( nPos := AScan(aMacro,{|a| a[1] == aTo[nX] })) > 0
			cIndex += aMacro[nPos,2]
			if nX < len(aTo)
				cIndex += ' + '
			endif
		endif
	next nX

	if !empty(cVlr)
		cIndex2 := 'SC5->(StaticCall(cbcLibEmpSrv, nBlEsTotal, C5_NUM))'
	endif

	FreeObj(oTFont)
	FreeObj(oModal)
	FreeObj(oContainer)
	FreeObj(oTree)
	FreeObj(oList1)
	FreeObj(oList2)
	FreeObj(oCombo1)
	FreeObj(oSay1)
	FreeObj(oSay2)
	FreeObj(oSay3)
return({cIndex, cForma, cIndex2, lChk1})


static function changeOpt(oLfr, oLto)
	local cText	:= oLfr:GetSelText()
	local nPos	:= oLfr:GetPos()
	if cText <> 'Priorizado'
		if !empty(cText) .and. !empty(nPos)
			oLto:Add(cText) 
			oLfr:Del(nPos)
		endif
		oLfr:GoTop()
		oLto:GoBottom()
	endif
return(nil)


static function orderPed(nRec, aPed, cIndex, cIndex2)
	aadd(aPed, {SC5->(Recno()), &(cIndex), &(cIndex2)})
return(nil)


static function doVirEmp(oHash)
	local aRecBlq		:= {}
	local nX			:= 1
	local cQtdBlq		:= 0
	local cProdAcon		:= ''
	local lAtende		:= .T.
	local cCor			:= 'BR_BRANCO'
	local aAr 			:= GetArea()
	local aArC5 		:= SC5->(GetArea())
	local aArC6 		:= SC6->(GetArea())
	local aArC9 		:= SC9->(GetArea())
	local aArB1 		:= SB1->(GetArea())
	local aArZE			:= SZE->(GetArea())
	local nAtendTot 	:= 0
	local nQtdAtend		:= 0
	local nNecesTot		:= 0
	local nVlrAtend		:= 0
	local nPBrAtend		:= 0
	local nPBruNeces 	:= 0
	local nVlrNeces		:= 0
	local nTotBob		:= 0
	local nTotBobP		:= 0
	local nDifBob		:= 0
	local cTextBob 		:= 'OK'
	local aBob			:= {}
	local nX			:= 0
	local nY			:= 0
	Local oStatic    	:= IfcXFun():newIfcXFun()

	default oHash 	:= HMNew()

	if empty(aRecBlq := u_zLTotBlq(SC5->(C5_NUM)))
		cCor	:= 'BR_AMARELO'
	else
		for nX := 1 to len(aRecBlq)
			SC9->(DbGoTO(aRecBlq[nX,1]))
			SC6->(DbGoTO(aRecBlq[nX,2]))
			SB1->(DbGoTO(aRecBlq[nX,3]))
			// SB1->B1_PESCOB SB1->B1_PESBRU
			nPBruNeces	+= (SC9->(C9_QTDLIB) * SB1->(B1_PESBRU))
			nVlrNeces	+= (SC9->(C9_QTDLIB) * SC6->(C6_PRCVEN))
			nNecesTot	+= SC9->(C9_QTDLIB)

			if SC6->(C6_ACONDIC) == 'B'
				if !empty(aBob := oStatic:sP(2):callStatic('cbcLibEmpSrv', 'getBobPed', SC5->(C5_NUM), oMainCtrl))
					nTotBob += SC9->(C9_QTDLIB)
					for nY := 1 to len(aBob)	
						SZE->(DbGoTo(aBob[nY]))
						if SZE->(ZE_CLIENTE + ZE_LOJA + ZE_PEDIDO + ZE_ITEM + ZE_PRODUTO) ==;
						SC5->(C5_CLIENTE + C5_LOJACLI + C5_NUM) + SC6->(C6_ITEM + C6_PRODUTO)

							cProdAcon 	:= SC9->(Alltrim(C9_PRODUTO)) + Alltrim(SC6->(C6_ACONDIC + StrZero(SZE->(ZE_QUANT),5)))
							nQtdAtend 	:= u_zLVirEmp(oHash, cProdAcon, SZE->(ZE_QUANT))
							nTotBobP	+= nQtdAtend
							nPBrAtend	+= (nQtdAtend * SB1->(B1_PESBRU))
							nVlrAtend	+= (nQtdAtend * SC6->(C6_PRCVEN))
							nAtendTot	+= nQtdAtend
						endif
					next nY
				endif
			else
				cQtdBlq 	:= SC9->(C9_QTDLIB)
				cProdAcon 	:= SC9->(Alltrim(C9_PRODUTO)) + Alltrim(SC6->(C6_ACONDIC + StrZero(SC6->C6_METRAGE,5)))
				nQtdAtend 	:= u_zLVirEmp(oHash, cProdAcon, cQtdBlq)
				nPBrAtend	+= (nQtdAtend * SB1->(B1_PESBRU))
				nVlrAtend	+= (nQtdAtend * SC6->(C6_PRCVEN))
				nAtendTot	+= nQtdAtend
			endif
		next nX

		if nNecesTot == 0
			cCor	:= 'BR_AMARELO'
		elseif (nNecesTot == nAtendTot )
			cCor := 'BR_VERDE'
		elseif ( nAtendTot > nNecesTot )
			cCor := 'BR_AZUL'
		else
			cCor := 'BR_VERMELHO'
		endif
		HMSet(oHashDados,  SC5->(Recno()), {{SC5->(Recno()),{nVlrAtend, nVlrNeces, nPBruNeces, nPBrAtend} }})
	endif
	HMSet(oHashFilter, SC5->(Recno()), {{SC5->(Recno()), cCor}} )

	if ( nTotBob == nTotBobP )
		cTextBob := 'OK'
	else
		nDifBob := (((nTotBobP - nTotBob) * 100) / nTotBob)
		if nDifBob == 100
			cTextBob := ' FALTA'
		else
			cTextBob := 'DIF.' + Alltrim(Transform(nDifBob, PesqPict('SC5', 'C5_TOTAL')))
		endif  
	endif
	HMSet(oHashBobin, SC5->(Recno()), {{SC5->(Recno()), cTextBob}} )

	RestArea(aArZE)
	RestArea(aArB1)
	RestArea(aArC9)
	RestArea(aArC6)
	RestArea(aArC5)
	RestArea(aAr)
return(nil)


static function disAbleFilter()
	oBrwPedido:SaveArea()
	SC5->(DbCloseArea())
	SC6->(DbCloseArea())
	SC9->(DbCloseArea())
	SDC->(DbCloseArea())
return(nil)


static function reloadFldr()
	local nPos	:= oBrwPedido:at()
	DbSelectArea('SC5')
	defPedFil()
	defRelPed()
	SC5->(DBSetOrder(3))
	// oBrwPedido:ExecuteFilter()
	oBrwPedido:FWFILTER():ExecuteFilter()
	oBrwPedido:Refresh()
	oBrwPedido:Goto(nPos)
	oBrwPedido:RestoreArea()
	updRel()
return(nil)


static function defLegend(oBrw, cWho)
	if cWho == 'Pedidos'
		oBrw:AddLegend("DTos(C5_ENTREG) < '"  + DToS(Date()) +  "' ", 'RED ', 'ATRASADO')
		oBrw:AddLegend("DTos(C5_ENTREG) >= '" + DToS(Date()) + "' ", 'GREEN ', 'EM DIA')	
	elseif cWho == 'Itens'
		oBrw:AddLegend('Empty(C6_ZZPVORI) '	, 'GREEN '	, 'NÃO EXISTE PROCESSSO DE IND/TRI/TRANSF')
		oBrw:AddLegend('! Empty(C6_ZZPVORI) '	, 'RED '	, 'EXISTE PROCESSSO DE IND/TRI/TRANSF')
	endif
return(nil)


static function procOpc(cOp,lYesNo,lUseReload)
	local lGoAhead	:= .T.
	local aAreaC5	:= SC5->(GetArea())
	local aAreaC6	:= SC6->(GetArea())
	local aAreaC9	:= SC9->(GetArea())
	local aAreaDC	:= SDC->(GetArea())
	local aAreaZE	:= SZE->(GetArea())
	local xParam	:= SC5->(Recno())

	default lUseReload	:= .T.
	default lYesNo		:= .T.
	if lYesNo
		lGoAhead := MsgNoYes('Confirma inicio do processamento?','Confirmação')
	endif
	if lGoAhead
		if lUseReload
			oMainCtrl:cPedFilter := ''
			FWMsgRun(,{|oSay|disAbleFilter()},"Preparando","Preparando...")
		endif
		oMainCtrl:procMark(cOp,xParam)
		RestArea(aAreaZE)
		RestArea(aAreaDC)
		RestArea(aAreaC9)
		RestArea(aAreaC6)
		RestArea(aAreaC5)
		if lUseReload
			FWMsgRun(,{|oSay|reloadFldr()},"Atualizando","Atualizando...")
		endif
	endif
return(nil)


static function doMark(oBrw,cFld)
	local aArea    	:= GetArea()
	local cMarca	:= oBrw:Mark()
	local cAls		:= oBrw:Alias()
	local cIdBw		:= oBrw:GetProfileID()
	local cKey		:= ''
	local aValue	:= {}
	local nQtdLib	:= 0
	local nOpcDlg	:= 1
	local cChvPLC	:= ""
	local oStatus 	:= nil 

	if ! oBrw:CheckSemaphore(.F.)
		oMainCtrl:setNotif('Aviso','Registro marcado por outro usuario!!')
	else
		if (cAls)->(RecLock(cAls, .F.))
			// Cancelar liberação quando não tem SDC
			if cIdBw == "c9LibItem"
				nQtdLib	:= SC9->(C9_QTDLIB)
				cChvPLC	:= SC9->(C9_PEDIDO + C9_ITEM)
				nOpcDlg	:= 1
				// Obter a quantidade para liberar
			elseif cAls == 'SC9'
				oStatus 		:= cbcCtrStatus():newcbcCtrStatus()
				oStatus:setMaster('SC5', SC5->(Recno()), oMainCtrl:getId()) 
				if oStatus:lvlCompare(LIBERADO_SEPARACAO, '>=')
					nOpcDlg := 2
					oMainCtrl:setNotif('Aviso','Empenho liberado para proximas etapas!!')
				else
					if (cAls)->(&cFld) <> cMarca
						u_zLEmpEnv(oMainCtrl, (cAls)->(Recno()))
						cChvPLC := SC9->(C9_PRODUTO)+SBF->(BF_LOCALIZ)
						nOpcDlg := u_zLEmShDl(@nQtdLib,cMarca, oMainCtrl)
					endif
				endif
				FreeObj(oStatus)
			elseif cAls == 'SDC'
				oStatus 		:= cbcCtrStatus():newcbcCtrStatus()
				oStatus:setMaster('SC5', SC5->(Recno()), oMainCtrl:getId()) 
				if oStatus:lvlCompare(LIBERADO_SEPARACAO, '>=')
					nOpcDlg := 2
					oMainCtrl:setNotif('Aviso','Empenho liberado para proximas etapas!!')
				endif
				FreeObj(oStatus)
				*/
			elseif cAls == 'SZE'
				cChvPLC := SZE->(ZE_PEDIDO + ZE_ITEM)
				nQtdLib	:= 1
				nOpcDlg := vldBobina()
			endif
			// Flegar o registro com a quantidade
			if nOpcDlg == 1
				cKey 	:= cAls + cValToChar((cAls)->(Recno()))
				aValue	:= {cAls, nQtdLib, (cAls)->(Recno()),cChvPLC}
				if oMainCtrl:doMark({cKey , aValue} ):isOk()
					if (cAls)->(&cFld) <> cMarca
						(cAls)->(&cFld) := cMarca
					else
						(cAls)->(&cFld) := ' '
					endif
				endif
				(cAls)->(MSUnlock())
			endif
		endif
	endif
	RestArea(aArea)
return(nil)


static function vldBobina()
	local nRet 		:= 2 // 1 .T. - 2 .F.
	local nContEmp	:= 0
	local nQtLanc	:= 0
	local nContMrk	:= 0
	Local oStatic   := IfcXFun():newIfcXFun()
	u_zLEmBEnv(oMainCtrl,SZE->(Recno()))
	nContEmp  	:= u_zLBobCnt(SZE->(ZE_PEDIDO), SZE->(ZE_ITEM))
	nQtLanc  	:= SC6->(C6_LANCES)
	nContMrk 	:= oStatic:sP(1):callStatic('cbcLibEmpSrv', 'getTotBobMk', oMainCtrl)
	if ( (nContMrk + nContEmp) > nQtLanc )  
		oMainCtrl:setNotif('Bobina', 'Pesado bobinas em maior quantidade que os lances do pedido, marcado apenas o possivel!',;
		{{'Filial+Pedido+Item', SC5->(C5_FILIAL + C5_PEDIDO) + SC6->(C6_ITEM)}},.F.,,.T.)
	else
		nRet := 1
	endif
return(nRet)


static function showStatus()
	local aAreaC5		:= SC5->(GetArea())
	local aAreaC6		:= SC6->(GetArea())
	local aAreaC9		:= SC9->(GetArea())
	local aAreaDC		:= SDC->(GetArea())
	local aAreaZE		:= SZE->(GetArea())
	local aAreaZ9		:= ZZ9->(GetArea())
	local cOpc			:= ''
	local xSearch		:= ''
	local aRecSC5		:= {}
	local oStatus		:= nil
	if !Empty(cOpc := parGet("Opções de filtro..."))
		oStatus := cbcCtrStatus():newcbcCtrStatus()
		if  makeSearch(@cOpc, @xSearch)
			if empty(aRecSC5 := oStatus:getGroup('MASTER','SC5','E', cOpc, xSearch ))
				oMainCtrl:setNotif('Validação', 'Nenhum registro atende ao filtro selecionado!!')
			else	
				FWMsgRun(,{|oSay|disAbleFilter()}, "Preparando","Preparando...")
				FWMsgRun(,{|oSay|u_cbcStsCtrl(aRecSC5)}, "Abrindo Status","Abrindo Status...")
				RestArea(aAreaZ9)
				RestArea(aAreaZE)
				RestArea(aAreaDC)
				RestArea(aAreaC9)
				RestArea(aAreaC6)
				RestArea(aAreaC5)
				FWMsgRun(,{|oSay|reloadFldr()}, "Atualizando","Atualizando...")
			endif
		endif
		FreeObj(oStatus)
	endif
	RestArea(aAreaZ9)
	RestArea(aAreaZE)
	RestArea(aAreaDC)
	RestArea(aAreaC9)
	RestArea(aAreaC6)
	RestArea(aAreaC5)
return(nil)


static function loteCanc(oBrw,cFld)
	local aAreaC5		:= SC5->(GetArea())
	local aAreaC6		:= SC6->(GetArea())
	local aAreaC9		:= SC9->(GetArea())
	local aAreaDC		:= SDC->(GetArea())
	local aAreaZE		:= SZE->(GetArea())
	local aAreaZ9		:= ZZ9->(GetArea())
	local aPedSC9		:= {}
	local cOpc			:= ''
	local xSearch		:= ''
	local aOnlyAcond	:= {}
	local oStatus 		:= nil
	if MsgNoYes('Processo de cancelamento direto, cancela todos os empenhos possiveis de acordo com as opções selecionadas?','Confirmação')
		aOnlyAcond := OnlyAcon()
		if !Empty(cOpc := parGet("Opções de cancelamento..."))
			oStatus := cbcCtrStatus():newcbcCtrStatus()
			if  makeSearch(@cOpc, @xSearch)
				if  empty(aPedSC9 := oStatus:getGroup('DETAIL','SC9','E', cOpc, xSearch ))
					oMainCtrl:setNotif('Validação', 'Nenhum registro atende ao filtro selecionado!!')
				else
					FWMsgRun(,{|oSay|disAbleFilter()}, "Preparando","Preparando...")
					FWMsgRun(,{|oSay|oMainCtrl:CancAutoWay(aPedSC9, aOnlyAcond)}, "Cancelando","Cancelando...")	
					RestArea(aAreaZ9)
					RestArea(aAreaZE)
					RestArea(aAreaDC)
					RestArea(aAreaC9)
					RestArea(aAreaC6)
					RestArea(aAreaC5)
					FWMsgRun(,{|oSay|reloadFldr()}, "Atualizando","Atualizando...")
				endif
			endif
			FreeObj(oStatus)
		endif
	endif
return(nil)


static function allDoMark(oBrw,cFld)
	local aElmMark		:= {}
	local cAliasRecn	:= ''
	local aCallToLib	:= {}
	local nX			:= 0 
	local aAreaC5		:= SC5->(GetArea())
	local aAreaC6		:= SC6->(GetArea())
	local aAreaC9		:= SC9->(GetArea())
	local aAreaDC		:= SDC->(GetArea())
	local aAreaZE		:= SZE->(GetArea())
	local aAreaZ9		:= ZZ9->(GetArea())

	if MsgNoYes('Processo de liberação direto, libera todos os itens dos pedidos que estão marcados de acordo com estoque disponivel?','Confirmação')
		// Obtem os recnos do SC5 marcado
		HMList( oMainCtrl:oHashMrk, @aElmMark )
		for nX := 1 to len(aElmMark)
			if aElmMark[nX,2,1,2,1] == 'SC5'
				SC5->(DbGoTo(aElmMark[nX,2,1,2,3]))
				cAliasRecn := 'SC5' + cValToChar(SC5->(Recno()))
				aadd(aCallToLib, aElmMark[nX,2,1,2,3])
				oMainCtrl:undoMark('SC5', 'C5_OK', cAliasRecn)
			endif
		next nX
		// Realiza a liberação dos recnos obtidos
		if ! empty(aCallToLib)
			FWMsgRun(,{|oSay|disAbleFilter()}, "Preparando","Preparando...")
			FWMsgRun(,{|oSay|oMainCtrl:autoWay(aCallToLib, .F.)}, "Trabalhando","Trabalhando...")	
			RestArea(aAreaZ9)
			RestArea(aAreaZE)
			RestArea(aAreaDC)
			RestArea(aAreaC9)
			RestArea(aAreaC6)
			RestArea(aAreaC5)
			FWMsgRun(,{|oSay|reloadFldr()}, "Atualizando","Atualizando...")
		endif
	endif
return(nil)


static function OnlyAcon()
	local aParamBox	:= {}
	local aRet		:= {}
	local lRet		:= .F.
	local aAcond	:= {{'R', 'Rolo',.T.},{'L', 'Blister',.T.},{'M', 'Carretel Madeira',.T.},{'B','Bobina',.F.}}
	local nX		:= 0
	local aSelAcon	:= {}

	for nX := 1 to len(aAcond)
		aadd(aParamBox,{4,aAcond[nX,2],aAcond[nX,3],aAcond[nX,1],50,"",.F.} )
	next nX

	if ParamBox(aParamBox,"Selecionar acondicionamento...",@aRet)
		for nX := 1 to len(aRet)
			if aRet[nX]
				aadd(aSelAcon, aAcond[nX,1] )
			endif
		next nX
	endif
return(aSelAcon)


static function defPercDes()
	local aParamBox	:= {}
	local aRet		:= {}
	aadd(aParamBox,{3,"Selecionar:",1,{"0","2","5","10","20"},90,"",.F.} )
	if ParamBox(aParamBox,"Percentual tolerado desvio em bobinas...",@aRet)
		if aRet[1] == 1
			oMainCtrl:nPercDes := 0
		elseif aRet[1] == 2
			oMainCtrl:nPercDes := 2
		elseif aRet[1] == 3 
			oMainCtrl:nPercDes := 5
		elseif aRet[1] == 4
			oMainCtrl:nPercDes := 10
		elseif aRet[1] == 5
			oMainCtrl:nPercDes := 20
		endif
		oMainCtrl:setNotif('LogEmp','Definido novo percentual de tolerancia para desvios de bobinas',{{'NovoValor',cValToChar(oMainCtrl:nPercDes)}},.F.,,.T.)
	endif
return(nil)


static function parGet(cTitulo)
	local aParamBox	:= {}
	local aRet		:= {}
	local aOpc		:= {"Sessão","Data","Tudo"}
	local nSel		:= 1
	aadd(aParamBox,{3,"Processar por:",1,aOpc,90,"",.F.} )
	if ParamBox(aParamBox,cTitulo,@aRet)
		nSel := aRet[1]
	endif
return( aOpc[nSel] )


static function makeSearch(cOpc, xSearch)
	local lRet			:= .F.
	local aParamBox		:= {}
	local aRet			:= {}
	local dDataDe		:= Date()
	local dDataAte	:= Date()
	if cOpc == "Sessão"
		cOpc 	:= 'ZZ9_SECAO'
		xSearch	:= " =  '" + Alltrim( oMainCtrl:getId() ) + "' "
		lRet	:= .T. 
		oMainCtrl:setNotif('LogEmp','Selecionada exclusão por sessão de todos os empenhos com status E',{{'Sessão:', Alltrim(xSearch)}},.F.,,.T.)
	elseif cOpc == "Data"
		cOpc := 'ZZ9_DATA' 
		aAdd(aParamBox,{1,'Data De: '  	,dDataDe,PesqPict('ZZ9','ZZ9_DATA'),"","",".T.",50,.T.})
		aAdd(aParamBox,{1,'Data Até: '  ,dDataAte,PesqPict('ZZ9','ZZ9_DATA'),"StaticCall(cbcLibEmpDash, vldDta, MV_PAR01, MV_PAR02)","",".T.",50,.T.})
		if ParamBox(aParamBox,"Data para cancelamento...",@aRet)
			xSearch := " BETWEEN '" +  dToS(aRet[1]) +  "' AND '" +  dToS(aRet[2]) + "' "
			lRet	:= .T.
			oMainCtrl:setNotif('LogEmp','Selecionada exclusão por data de todos os empenhos com status E',{{'Data:', Alltrim(xSearch)}},.F.,,.T.)
		endif
	elseif cOpc == "Tudo"
		cOpc 	:= '*'
		lRet	:= .T.
		oMainCtrl:setNotif('LogEmp','Selecionada exclusão de todos empenhos com status E',{},.F.,,.T.)
	endif 
return(lRet)


static function vldDta(dDe, dAt)
	local lRet := .T.
	if  dDe > dAt
		oMainCtrl:setNotif('Aviso','Data de maior que data Até!!')
		lRet := .F.
	endif
return(lRet)


static function modalLib(nRec)
	local aAreaC5		:= SC5->(GetArea())
	local aAreaC6		:= SC6->(GetArea())
	local aAreaC9		:= SC9->(GetArea())
	local aAreaDC		:= SDC->(GetArea())
	local aAreaZE		:= SZE->(GetArea())
	local aAreaZ9		:= ZZ9->(GetArea())
	local oModal		:= nil
	local oContainer	:= nil
	local oMarkLib		:= nil
	local aElmMark		:= {}
	local aFields		:= {}
	local cSC9Alias		:= 'SC9'
	local nX			:= 0

	// Guarda os registros, que esyiverem marcados da tela anterior
	HMList( oMainCtrl:oHashMrk, @aElmMark)
	// Limpa o objeto de marcação para receber as marcações desta tela
	HMClean( oMainCtrl:oHashMrk )
	oMainCtrl:cPedFilter := ''
	FWMsgRun(,{|oSay|disAbleFilter()},"Preparando","Preparando...")

	(cSC9Alias)->(DbGoTo(nRec))
	oModal  := FWDialogModal():New()        
	oModal:SetEscClose(.T.)
	oModal:setTitle("Empenho de Estoque")
	// Seta a largura e altura da janela em pixel
	oModal:setSize(240, 540)
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
	oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
	oContainer:SetCss("")
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT
	oMarkLib 	:= FWMarkBrowse():New()
	oMarkLib:SetOwner(oContainer)
	oMarkLib:SetAlias(cSC9Alias)
	oMarkLib:SetDescription("Cancelamento de liberações")
	aFields	:= {'C9_ITEM', 'C9_PRODUTO', 'C9_QTDLIB'}
	oMarkLib:SetOnlyFields(aFields)
	oMarkLib:SetProfileID('c9LibItem')
	oMarkLib:SetFieldMark( "C9_OK" )
	oMarkLib:SetUseFilter(.T.)
	oMarkLib:SetFilterDefault(u_zLVldPed('SC9LIB', ,cSC9Alias))
	oMarkLib:SetMenuDef('')
	oMarkLib:SetChange({|| .T.})
	oMarkLib:DisableReport()
	oMarkLib:SetSemaphore(.T.)
	oMarkLib:OpenSemaphore()
	oMarkLib:SetCustomMarkRec({||doMark(oMarkLib,'C9_OK')})
	oMarkLib:AddButton('Cancelar', {|| doProcRefr(oMarkLib) },,7,)
	oMarkLib:Activate()
	oModal:Activate()

	FreeObj(oMarkLib)
	FreeObj(oContainer)
	FreeObj(oModal)

	RestArea(aAreaZ9)
	RestArea(aAreaZE)
	RestArea(aAreaDC)
	RestArea(aAreaC9)
	RestArea(aAreaC6)
	RestArea(aAreaC5)
	// Limpa o objeto de marcação para retornar o que estava marcado antes
	HMClean( oMainCtrl:oHashMrk )
	// Volta informações marcadas na tela anterior
	for nX := 1 to len(aElmMark)
		HMAdd(oMainCtrl:oHashMrk,{aElmMark[nX,2,1,1],aElmMark[nX,2,1,2]} )
	next nX
	FWMsgRun(,{|oSay|reloadFldr()},"Atualizando","Atualizando...")	
Return


static function doProcRefr(oBrw)
	procOpc("SC9_CANC")
	oBrw:Refresh()
	oBrw:ExecuteFilter(.T.)
return(nil)


static function montaBrw(oBrw, oPanel, cDesc, cAls, aColunas, cProfId, bMark, cMenuDef, cMkFld, lIsMark, cFiltro, cFldTot)
	local aSize			:= {}
	local nX			:= 0
	Local oStatic    	:= IfcXFun():newIfcXFun()
	private aRotina		:= oStatic:sP(1):callStatic('zMLibEmp', 'MenuDef', cDesc)
	default cMenuDef 	:= ''
	default cFiltro 	:= ''
	default cFldTot		:= ''

	if lIsMark
		oBrw:= FWMarkBrowse():New()
		if !empty(cMkFld)
			needMrColum(@oBrw, cDesc)
			makeStatusCol(@oBrw, cDesc)
			oBrw:SetFieldMark(cMkFld)
			oBrw:SetCustomMarkRec(bMark)
			oBrw:SetAllMark({||msginfo('Marcar todos')})
			oBrw:SetAlias(cAls)
			oBrw:SetSemaphore(.T.)
			oBrw:OpenSemaphore()
			if cAls == 'SDC'
				oBrw:AddButton('Inverter Marcação', {|| invertMark(cAls, oBrw, cMkFld, oMainCtrl) },,7,)
			elseif cAls == 'SC9'
				oBrw:AddButton('Mostra. Liberados'	, {|| FWMsgRun(,{ |oSay| modalLib(SC9->(Recno())) }, "Aguarde...", "Buscando Liberados...") },,4,)
			elseif cAls == 'SC5'
				oBrw:AddButton('Liber. Direto'	, {|| allDoMark(oBrw,cMkFld) },,4,)
				oBrw:AddButton('Atualiza', {|| FWMsgRun(,{|oSay| updRel()}, "Atualizando Registros","Atualizando Registros...")},,4,)
				oBrw:AddButton('Canc. Lote'	, {|| FWMsgRun(,{|oSay|loteCanc(oBrw,cMkFld)}, "Selecionando Registros","Selecionando Registros...")},,4,)
				oBrw:AddButton('Inverter Marcação'	, {|| FWMsgRun(,{|oSay|invertMark(cAls, oBrw, cMkFld, oMainCtrl)}, "Processando Marcas","Processando Marcas...")},,4,)
				oBrw:AddButton('Dist.Saldo'	, {|| FWMsgRun(,{|oSay|iniAnali(oBrw, cMkFld, oMainCtrl)}, "Distribuindo Saldos","Distribuindo Saldos...")},,4,)
				oBrw:AddButton('Exibir Dist.'	, {|| FWMsgRun(,{|oSay|exibSimu(oBrw, cMkFld, oMainCtrl)}, "Preparando Simulação","Preparando Simulação...")},,4,)
				oBrw:AddButton('Controle Status', {|| showStatus() },,4,)
				oBrw:AddButton('Info Liber.', {|| FWMsgRun(,{|oSay|infoLiber(cAls, oBrw, cMkFld, oMainCtrl)}, "Obtendo totais","Obtendo totais...")},,4,)
				oBrw:AddButton('Ordenar', {|| orderBrw() },,4,)
				oBrw:SetDoubleClick({|| updRel()})
			endif
		endif
	else
		oBrw:= FWMBrowse():New()
		oBrw:SetAlias(cAls)
		needMrColum(@oBrw, cDesc)
		if cAls == 'SC6'
			oBrw:AddButton('Consulta',{|| FWMsgRun(,{|oSay| u_vLERelPed(SC5->(Recno()), SC6->(Recno()))},;
			"Buscando Relacionamentos","Buscando Relacionamentos...")},,7,)
		endif
		// oBrw:SetDoubleClick({||FWMsgRun(,{|oSay|syncBrw()},"Buscando","Buscando...")})
	endif
	oBrw:SetOwner(oPanel)
	oBrw:SetDescription(cDesc)
	oBrw:SetTemporary( .T.)
	oBrw:SetFields(aColunas)
	oBrw:SetProfileID(cProfId)
	oBrw:ForceQuitButton(.F.)
	oBrw:SetChange({|| .T.})
	oBrw:setignorearotina(.F.)
	oBrw:SetUseFilter(.T.)
	if !empty(cFiltro)
		oBrw:SetFilterDefault(cFiltro)
	endif
	if !empty(cFldTot)
		oBrw:AddButton('Total', {|| calcTot(oMainCtrl, cAls, cFldTot) },,0,)
	endif
	defLegend(@oBrw, cDesc)
	defSeek(@oBrw, cDesc)
	oBrw:SetSeeAll(.F.)
	oBrw:DisableReport()
	oBrw:Activate()	
return(oBrw)


static function orderBrw()
		DbSelectArea('SC5')  
		SC5->(DBSetOrder(3))
return(nil)


static function getDescPed()
	local bRet 			:= nil
	local oSql			:= nil
	local cNomeCli		:= ''
	private cConteudo		:= ''

	oSql 				:= LibSqlObj():newLibSqlObj()
	cNomeCli			:= oSql:getFieldValue("SA1", "A1_NOME",;
	"%SA1.XFILIAL% AND A1_COD = '" + SC5->(C5_CLIENTE) + "' AND A1_LOJA ='" + SC5->(C5_LOJACLI) + "'") 
	cConteudo := SC5->( Alltrim(C5_FILIAL) + ' - ' + Alltrim(C5_NUM) + ' - ' + Alltrim(cNomeCli) )

	FreeObj(oSql)
return(cConteudo)


static function needMrColum(oBrw, cDesc)
	local BFQUANT		:= {}
	local bBlocoItem	:= {||FWMsgRun(,{|oSay|syncBrw()},"Buscando","Buscando...")}
	local bBlocoPedido	:= {||FWMsgRun(,{|oSay|updRel()},"Atualizando","Atualizando...")}
	local refValor		:= TamSx3('C5_TOTAL')
	local refPic		:= PesqPict('SC5', 'C5_TOTAL')
	if cDesc == 'Saldos'
		BFQUANT := TamSx3('BF_QUANT')
		addCol(@oBrw, 'Disponivel', PesqPict('SBF', 'BF_QUANT'), {|| SBF->(BF_QUANT - BF_EMPENHO)}, BFQUANT[TIPO], BFQUANT[TAMANHO], BFQUANT[DECIMAL]) 
	elseif cDesc == 'Itens'		
		addCol(@oBrw, 'Item', '', {||SC6->(Alltrim(C6_ITEM) + ' - ' +;
		Alltrim(C6_DESCRI) + ' - ' + Alltrim(Str(C6_LANCES)) + ' X ' +;
		Alltrim(Padr(C6_ACONDIC + StrZero(SC6->C6_METRAGE,5), TamSx3('BF_LOCALIZ')[1]))+ ' - '+;
		cValToChar(C6_QTDVEN) ) }, 'C', 50, 0, 1, bBlocoItem)
	elseif cDesc == 'Pedidos' 
		addCol(@oBrw, 'Div', ''			,{|| getOthSide(SC5->(Recno()))}	,'C', 40, 0, 1,bBlocoPedido)
		addCol(@oBrw, 'Info', ''		,{|| getDescPed()}	,'C', 80, 0, 1,bBlocoPedido)
		addCol(@oBrw, 'Vlr.Necessario'	, refPic 	,{|| helpDados('necessario')}	,refValor[3], refValor[1], refValor[2], 1)
		addCol(@oBrw, 'Vlr.Atendido'	,  refPic 	,{|| helpDados('atendido')}		,refValor[3], refValor[1], refValor[2], 1)
		addCol(@oBrw, 'Perc.Atendido'	,  refPic 	,{|| helpDados('per_atendido')}	,refValor[3], refValor[1], refValor[2], 1)
		addCol(@oBrw, 'Bobinas',  '' 	,{|| helpBob()}	,'C', '10', 0, 1)
		addCol(@oBrw, 'Faturado'		, refPic 	,{|| helpDados('faturado')}	,refValor[3], refValor[1], refValor[2], 1)
		addCol(@oBrw, 'Empenhado'		, refPic 	,{|| helpDados('empenhado')}	,refValor[3], refValor[1], refValor[2], 1)
		addCol(@oBrw, 'PesoKG Necess.'	, refPic 	,{|| helpDados('peso_necessario')}	,refValor[3], refValor[1], refValor[2], 1)
		addCol(@oBrw, 'PesoKG Atend.'	, refPic 	,{|| helpDados('peso_atendido')}	,refValor[3], refValor[1], refValor[2], 1)
	endif
return(nil)


static function makeStatusCol(oBrw, cDesc) 

	if cDesc == 'Pedidos'
		oBrw:AddStatusColumns( {|| helpFilter() }, {|| statusLegend('PedEst')})
		oBrw:AddStatusColumns({|| iif (C5_PARCIAL == 'S', 'BR_VERDE','BR_VERMELHO')}, {|| statusLegend('PedParc')})
		oBrw:AddStatusColumns({|| iif (C5_TIPOLIB == 'P', 'BR_LARANJA','BR_VERDE')}, {|| statusLegend('Prioridade')})
		oBrw:AddStatusColumns({|| getOthSide(SC5->(Recno()), .F.)}, {|| statusLegend('Local')})

		oBrw:AddFilter('COM BLOQUEIO DE ESTOQUE'			,'staticcall(cbcLibEmpDash, helpFilter) <> "BR_AMARELO"' ,.F.,.F.)
		oBrw:AddFilter('NENHUM BLOQUEIO DE ESTOQUE'			,'staticcall(cbcLibEmpDash, helpFilter) == "BR_AMARELO"' ,.F.,.F.)
		oBrw:AddFilter('ESTOQUE ATENDE PEDIDO'				,'staticcall(cbcLibEmpDash, helpFilter) $ "BR_VERDE//BR_AZUL"' 	 ,.F.,.F.)
		oBrw:AddFilter('ESTOQUE NÃO ATENDE PEDIDO'			,'staticcall(cbcLibEmpDash, helpFilter) == "BR_VERMELHO"' ,.F.,.F.)
		oBrw:AddFilter('DATA FATURAMENTO MENOR IGUAL HOJE'	,"DtoS(C5_DTFAT) <= '" + DtoS(Date()) + "' " ,.F.,.F.)
		oBrw:AddFilter('ACEITA PARCIAL'						,"C5_PARCIAL == 'S'" 							,.F.,.F.)
		oBrw:AddFilter('NÃO ACEITA PARCIAL'					,"C5_PARCIAL <> 'S'"							,.F.,.F.)
		oBrw:AddFilter('PRIORIDADES'						,"C5_TIPOLIB == 'P'"							,.F.,.F.)
		oBrw:AddFilter('TRANSFERENCIA'						,"staticcall(cbcLibEmpDash, getOthSide,SC5->(Recno()), .F.) == 'BR_LARANJA'" ,.F.,.F.)
		oBrw:AddFilter('TRIANGULACAO'						,"staticcall(cbcLibEmpDash, getOthSide,SC5->(Recno()), .F.) == 'BR_AZUL'" ,.F.,.F.)
		oBrw:AddFilter('NORMAL'								,"staticcall(cbcLibEmpDash, getOthSide,SC5->(Recno()), .F.) == 'BR_VERDE'" ,.F.,.F.)
		
	endif	
return(nil)


static function statusLegend(cDesc)
	local oLegenda  :=  FWLegend():New()

	if cDesc == 'PedEst'
		oLegenda:Add( '', 'BR_AMARELO'  , 'Nenhum Item Bloqueado Estoque' )
		oLegenda:Add( '', 'BR_VERDE'   	, 'Estoque Atende Pedido' )
		oLegenda:Add( '', 'BR_VERMELHO' , 'Estoque Não Atende Pedido' )
		oLegenda:Add( '', 'BR_AZUL'   	, 'Estoque Supera Pedido' )
	elseif cDesc == 'PedParc'
		oLegenda:Add( '', 'BR_VERDE'   	 , 'Aceita Parcial' )
		oLegenda:Add( '', 'BR_VERMELHO'	 , 'Não Aceita Parcial' )
	elseif cDesc == 'Prioridade'
		oLegenda:Add( '', 'BR_LARANJA'   , 'Prioridade' )
		oLegenda:Add( '', 'BR_VERDE'	 , 'Normal' )
	elseif cDesc == 'Local'
		oLegenda:Add( '', 'BR_LARANJA'   , 'Transferencia' )
		oLegenda:Add( '', 'BR_AZUL'	 	, 'Triangulação' )
		oLegenda:Add( '', 'BR_VERDE'	, 'Normal' )
	endif
	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()
	FreeObj(oLegenda)
return (nil)


static function helpFilter()
	local aValor	:= {}
	local cCor		:= 'BR_BRANCO'
	if hmGet(oHashFilter,SC5->(Recno()),@aValor)
		cCor := aValor[1,2]
	endif
return(cCor)


static function defRelPed()
	hmClean(oHashFilItu)
	hmClean(oHashFilTl)
	u_cbcQrPRel(@oHashFilItu,@oHashFilTl)
return(nil)


static function getOthSide(nRecFrom, lDesc)
	local cText		:= ''
	local nRecTo	:= nil
	local aArea		:= SC5->(GetArea())
	default lDesc	:= .T.

	if hmGet(oHashFilItu,nRecFrom,@nRecTo)
		SC5->(DbGoTo(nRecTo))
		if lDesc
			cText := Alltrim(getDescPed())
		else
			cText := getLocal()		
		endif
	elseif hmGet(oHashFilTl,nRecFrom,@nRecTo)
		if lDesc
			SC5->(DbGoTo(nRecTo))
			cText := Alltrim(getDescPed())
		else
			cText := getLocal()
		endif
	endif
	if !lDesc
		if cText == '01'
			cText := 'BR_LARANJA'
		elseif cText == '10'
			cText := 'BR_AZUL'
		else
			cText := 'BR_VERDE'
		endif
	endif
	RestArea(aArea)
return(cText)


static function getLocal()
	local oSql  	:= nil 
	local cQry		:= ''
	local cLocal	:= ''
	cQry += " SELECT " 
	cQry += " DISTINCT C6_LOCAL AS [LOCAL] "
	cQry += " FROM  "
	cQry += RetSqlName('SC6')
	cQry += " WHERE  "
	cQry += " C6_FILIAL = '"+ SC5->(C5_FILIAL) +"' "
	cQry += " AND C6_NUM = '"+ SC5->(C5_NUM) +"' "
	cQry += " AND C6_ZZPVORI <> '' "
	cQry += " AND D_E_L_E_T_ = '' "
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		cLocal := oSql:getValue("LOCAL")
	endif	
	oSql:close()
	FreeObj(oSql)
return(cLocal)


static function defPedFil()
	local oSql := nil 
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(u_zLVldPed('SC5',,,'02'))
	if oSql:hasRecords()
		HMClean(oHashPedFil)
		oSql:goTop()
		while oSql:notIsEof()
			HMSet(oHashPedFil, oSql:getValue("RECNO"), .T. )
			oSql:skip()
		endDo
	endif	
	oSql:close()
	FreeObj(oSql)
return(nil)


static function helpPedFil()
	local lRet	:= .F.
	local aVlr	:= {}
	lRet := hmGet(oHashPedFil,SC5->(Recno()),@aVlr)
return(lRet)


static function helpDados(cQual)
	local aValor	:= {}
	local nVlr		:= 0
	Local oStatic   := IfcXFun():newIfcXFun()
	if hmGet(oHashDados,SC5->(Recno()),@aValor)
		if cQual == 'atendido'
			nVlr := aValor[1,2,1]
		elseif cQual == 'necessario'
			nVlr := aValor[1,2,2]
		elseif cQual == 'per_atendido' 
			nVlr := ((;
			oStatic:sP(1):callStatic('cbcLibEmpSrv','nFatTotal',SC5->(C5_NUM))  +;
			oStatic:sP(1):callStatic('cbcLibEmpSrv','nEmpTotal',SC5->(C5_NUM)) +;
			aValor[1,2,1] ) * 100 ) / SC5->(C5_TOTAL)
		elseif cQual == 'peso_necessario'
			nVlr := aValor[1,2,3]
		elseif cQual == 'peso_atendido' 
			nVlr := aValor[1,2,4]
		endif
	endif
	if cQual == 'faturado'
		nVlr := oStatic:sP(1):callStatic('cbcLibEmpSrv','nFatTotal',SC5->(C5_NUM))
	elseif cQual == 'empenhado'
		nVlr := oStatic:sP(1):callStatic('cbcLibEmpSrv','nEmpTotal',SC5->(C5_NUM))
	endif
return(nVlr)


static function helpBob()
	local aValor	:= {}
	local cRet		:= ''
	if hmGet(oHashBobin,SC5->(Recno()),@aValor)
		cRet = aValor[1,2]
	endif
return(cRet)


static function initHash()
	hmClean(oHashPedFil)
	hmClean(oHashFilter)
	hmClean(oHashDados)
	hmClean(oHashBobin)
	hmClean(oHashFilItu)
	hmClean(oHashFilTl)
return(nil)


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


static function syncBrw()
	local oData 	:= oBrwLiber:data()
	local nPosIni	:= oBrwLiber:at()
	local lFind		:= .F.
	local lLoopCtrl	:= .T.
	oData:Gotop()
	while lLoopCtrl
		if SC9->(C9_ITEM) == SC6->(C6_ITEM)
			lLoopCtrl 	:= .F.
			lFind		:= .T.
		else
			if oData:isLast()
				lLoopCtrl := .F.
			else
				oData:Skip(1)
			endif
		endif 
	enddo
	if ! lFind
		oData:GoTo(nPosIni)
	endif
	oBrwLiber:Refresh()
return(nil)


static function defSeek(oBrw, cDesc)
	local aSeek			:= {}
	local aSx3Fil		:= {}
	local aSx3Num		:= {}
	local aSx3Cli		:= {}
	local aSx3Loj		:= {}
	local aSx3DtEntr	:= {}
	local aSx3DtGen		:= {}
	if cDesc == 'Pedidos'
		aSx3Fil 	:= TamSx3("C5_FILIAL")	
		aSx3Num 	:= TamSx3("C5_NUM")
		aSx3Cli		:= TamSx3("C5_CLIENTE")
		aSx3Loj		:= TamSx3("C5_LOJACLI")
		aSx3DtGen	:= TamSx3("C5_DTFAT")

		aAdd(aSeek,{"Filial+Pedido" ,{;
		{"",aSx3Fil[TIPO],aSx3Fil[TAMANHO],aSx3Fil[DECIMAL],"C5_FILIAL",,X3Picture("C5_FILIAL")},;
		{"",aSx3Num[TIPO],aSx3Num[TAMANHO],aSx3Num[DECIMAL],"C5_NUM",,X3Picture("C5_NUM")}}})

		aAdd(aSeek,{"Cliente+Loja" ,{;
		{"",aSx3Cli[TIPO],aSx3Cli[TAMANHO],aSx3Cli[DECIMAL],"C5_CLIENTE",,X3Picture("C5_CLIENTE")},;
		{"",aSx3Loj[TIPO],aSx3Loj[TAMANHO],aSx3Loj[DECIMAL],"C5_LOJACLI",,X3Picture("C5_LOJACLI")}}})

		aAdd(aSeek,{"Dt.Faturamento" ,{;
		{"",aSx3DtGen[TIPO],aSx3DtGen[TAMANHO],aSx3DtGen[DECIMAL],"C5_DTFAT",,X3Picture("C5_DTFAT")}}})

		aAdd(aSeek,{"Dt.Entrega" ,{;
		{"",aSx3DtGen[TIPO],aSx3DtGen[TAMANHO],aSx3DtGen[DECIMAL],"C5_ENTREG",,X3Picture("C5_ENTREG")}}})

		oBrw:SetSeek(.T.,aSeek)
	endif
return(nil)


static function retFields(aTmp, cFrom)
	local aFlds			:= {}
	local aSx3			:= {}
	local nX			:= 0
	local cNomeCampo	:= ''
	for nX := 1 to len(aTmp)
		cNomeCampo := Alltrim(StrTran(StrTran(StrToKArr(aTmp[nX,NOME_SQL],'[')[2], ']',''),',',''))
		aSx3 := TamSx3(aTmp[nX,NOME_CAMPO])
		if cFrom == 'SQL'
			aadd(aFlds,{aTmp[nX,NOME_CAMPO] + ' ' + aTmp[nX,NOME_SQL]} ) 
		elseif cFrom == 'TRB'
			aTmp[nX,INFO_TRB,NOME_CAMPO] 		:= 	cNomeCampo
			aTmp[nX,INFO_TRB,TIPO_TRB] 			:= 	if(aTmp[nX,TEM_INFO],aSx3[TIPO]		,aTmp[nX,INFO_TRB,TIPO_TRB])
			aTmp[nX,INFO_TRB,TAM_TRB]			:=	if(aTmp[nX,TEM_INFO],aSx3[TAMANHO]	,aTmp[nX,INFO_TRB,TAM_TRB])
			aTmp[nX,INFO_TRB,DEC_TRB]			:=	if(aTmp[nX,TEM_INFO],aSx3[DECIMAL]	,aTmp[nX,INFO_TRB,DEC_TRB])
			aadd(aFlds, aTmp[nX,INFO_TRB] )
		elseif cFrom == 'BRW' 
			aTmp[nX,INFO_BROWSER,NOME_CAMPO]	:= 	if(aTmp[nX,TEM_INFO],GetSx3Cache(cNomeCampo,'X3_TITULO'),cNomeCampo)
			aTmp[nX,INFO_BROWSER,TITULO_BROWSE]	:=	if(aTmp[nX,TEM_INFO],cNomeCampo						,aTmp[nX,INFO_BROWSER,TITULO_BROWSE])
			aTmp[nX,INFO_BROWSER,TIPO_BROWSE]	:=	if(aTmp[nX,TEM_INFO],aSx3[TIPO]						,aTmp[nX,INFO_BROWSER,TIPO_BROWSE])
			aTmp[nX,INFO_BROWSER,TAM_BROWSE]	:=	if(aTmp[nX,TEM_INFO],aSx3[TAMANHO]					,aTmp[nX,INFO_BROWSER,TAM_BROWSE])
			aTmp[nX,INFO_BROWSER,DEC_BROWSE]	:=  if(aTmp[nX,TEM_INFO],aSx3[DECIMAL]					,aTmp[nX,INFO_BROWSER,DEC_BROWSE])
			aTmp[nX,INFO_BROWSER,PIC_BROWSE]	:=  if(aTmp[nX,TEM_INFO],X3Picture(aTmp[nX,NOME_CAMPO])	,aTmp[nX,INFO_BROWSER,PIC_BROWSE])
			aadd(aFlds, aTmp[nX,INFO_BROWSER] )
		endif
	next nX
return (aFlds)


static function getFlds(cTipo, cOper)
	local aTmp		:= {}
	local aBFSX3	:= TamSx3('BF_QUANT')
	if cOper == 'PEDIDOS'
		aadd(aTmp,{ "C5_CLIENTE"	,	"AS [C5_CLIENTE], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_LOJACLI"	,	"AS [C5_LOJACLI], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_ENTREG"		,	"AS [C5_ENTREG], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_DTFAT"		,	"AS [C5_DTFAT],  "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_OBS"		,	"AS [C5_OBS], "		,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_TPFRETE"	,	"AS [C5_TPFRETE], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_TOTAL"		,	"AS [C5_TOTAL],  "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_EMISSAO"	,	"AS [C5_EMISSAO], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_PALLET"		,	"AS [C5_PALLET], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_DRC"		,	"AS [C5_DRC], "		,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_LAUDO"		,	"AS [C5_LAUDO], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_DOCPORT"	,	"AS [C5_DOCPORT], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_PARCIAL"	,	"AS [C5_PARCIAL], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_ZZPVORI"	,	"AS [C5_ZZPVORI], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_LIBEROK"	,	"AS [C5_LIBEROK], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_NOTA"		,	"AS [C5_NOTA], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_TIPO"		,	"AS [C5_TIPO], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C5_LIBEROK"	,	"AS [C5_LIBEROK], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
	elseif cOper == 'ITEM' 
		aadd(aTmp,{ "C6_PRODUTO" 	,	"AS [C6_PRODUTO], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C6_ENTREG" 	,	"AS [C6_ENTREG], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C6_LOCAL" 		,	"AS [C6_LOCAL], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C6_ZZPVORI" 	,	"AS [C6_ZZPVORI], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C6_ITEM" 		,	"AS [C6_ITEM], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
	elseif cOper ==  'LIBER' 
		aadd(aTmp,{ "C9_ITEM" 		,	"AS [C9_ITEM], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C9_PRODUTO" 	,	"AS [C9_PRODUTO], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C9_QTDLIB" 	,	"AS [C9_QTDLIB], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C9_SEQUEN" 	,	"AS [C9_SEQUEN], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C9_BLCRED" 	,	"AS [C9_BLCRED], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "C9_BLEST" 		,	"AS [C9_BLEST], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
	elseif cOper == 'EMP'
		aadd(aTmp,{ "DC_ITEM" 		,	"AS [DC_ITEM], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "DC_QUANT" 		,	"AS [DC_QUANT], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "DC_LOCAL" 		,	"AS [DC_LOCAL], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "DC_LOCALIZ" 	,	"AS [DC_LOCALIZ], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "DC_SEQ" 		,	"AS [DC_SEQ], "		,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "DC_PRODUTO" 	,	"AS [DC_PRODUTO], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
	elseif cOper == 'SALDO'
		aadd(aTmp,{ "BF_LOCALIZ" 	,	"AS [BF_LOCALIZ], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )		
		aadd(aTmp,{ "BF_QUANT" 		,	"AS [BF_QUANT], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "BF_EMPENHO" 	,	"AS [BF_EMPENHO], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "BF_PRODUTO" 	,	"AS [BF_PRODUTO], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "BF_FILIAL" 	,	"AS [BF_FILIAL], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
	elseif cOper == 'CLIENTES'
		aadd(aTmp,{ "A1_COD" 	,	"AS [A1_COD], "		,{"","",0,0}, {"","", "",0,0,""},.T.} )		
		aadd(aTmp,{ "A1_LOJA" 	,	"AS [A1_LOJA], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
		aadd(aTmp,{ "A1_NOME" 	,	"AS [A1_NOME], "	,{"","",0,0}, {"","", "",0,0,""},.T.} )
	endif
return(retFields(aTmp,cTipo))


static function getQuery(cFrom)
	local cQry 	:= '' 
	local nX	:= 0
	local aQry		:= getFlds('SQL', cFrom)
	if cFrom == 'PEDIDOS'
		cQry += " SELECT "
		for nX := 1 to Len(aQry)
			cQry += aQry[nX,1]
		next nX
		cQry += " FROM " + RetSqlName('SC5')
		cQry += " WHERE "
		cQry += " C5_FILIAL = '" + xFilial('SC5') + "' "
		cQry += " AND C5_LIBEROK = 'S' "
		cQry += " AND C5_NOTA = '' " 
		cQry += " AND  D_E_L_E_T_ <> '*' "
	endif
return(cQry)

