#include 'protheus.ch'

user function cbcIniFormulas()
    local lCloseButt 	:= !(oAPP:lMdi)
    private oDlgPrinc	:= nil
	private oFWLayer	:= nil	
	private aCoors 		:= FWGetDialogSize( oMainWnd )
    private oFont     	:= TFont():New("Arial",,20,,.T.)
    private aOptions    := {}
    private oFormulas   := nil
    private oPnlPrinc	:= nil
    private oPnlCtrl	:= nil
	private oBrw        := nil
    private oBtnClose   := nil
    private oCombo 	    := nil
    private oTabTemp    := nil
    private cAls        := ''
    private xFilial     := ''
    private cCodigo     := ''
    private cKey        := ''
    private cForm       := ''
    private nRec        := 0

    DEFINE MSDIALOG oDlgPrinc TITLE 'Inicializador com Formulas' ;
		    FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] ;
          OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL

	oDlgPrinc:lMaximized := .T.
    oFWLayer := FWLayer():New()
	oFWLayer:Init(oDlgPrinc, lCloseButt)
    
    oFormulas   := ctrlIniFormul():newctrlIniFormul()    
    configLayout()
    configCtrl()
        
    Activate MsDialog oDlgPrinc Center
    
    cleanService()    
	
    FreeObj(oFont)	
    FreeObj(oFormulas)	 
    FreeObj(oBtnClose)
    FreeObj(oCombo)
    FreeObj(oBrw)
    FreeObj(oTabTemp)
    FreeObj(oPnlPrinc)
    FreeObj(oPnlCtrl)
    FreeObj(oFWLayer)
    FreeObj(oDlgPrinc)
return(nil)

static function configLayout()
	// Coluna Esquerda
	oFWLayer:AddCollumn('PRINC', 80, .F.)		
	// Janela Informação
	oFWLayer:AddWindow('PRINC', 'WND_PRINC', 'Fórmulas', 100, .T., .F.)
	oPnlPrinc := oFWLayer:GetWinPanel('PRINC', 'WND_PRINC')

	// Coluna Direita
	oFWLayer:AddCollumn('CTRL', 20, .F.)
	// Janela Controles
	oFWLayer:AddWindow('CTRL', 'WND_CTRL', 'Controles', 100, .T., .F.)
	oPnlCtrl := oFWLayer:GetWinPanel('CTRL', 'WND_CTRL')
return(nil)

static function configCtrl()
    local cOptions  := GetNewPar('ZZ_OPCFORM', 'OPC_FORMULAS')
    local nX        := 0
	local cCombo 	:= ''
    local aReg      := {}
	local aItems 	:= {}
	local aOptions	:= {}
    local aKeys     := {}

    oFormulas:setKeyForm(cOptions)
    aOptions := oFormulas:getFormulas()

    aAdd(aItems,'')
	aAdd(aKeys, '')

	for nX := 1 to len(aOptions)
		aReg := &(aOptions[nX,3])
        aAdd(aItems,aReg[1])
		aAdd(aKeys, aReg[2])
	next nX

	oCombo := TComboBox():New(02,05,{|u|if(PCount()>0, cCombo:=u, '')},;
        aItems,105,20,oPnlCtrl,,;
        {|| FWMsgRun(, { || loadBrowser(aKeys[oCombo:nAt]) }, 	"Aguarde...", "Alternando Visão...")};
        ,,,,.T.,,,,,,,,,'cCombo')

    oBtnClose 	:= TButton():New( 35, 05,  'Fechar', 	oPnlCtrl , {|| oDlgPrinc:End()}, 80,25,,oFont,.F.,.T.,.F.,,.F.,,,.F. )

return(nil)

static function loadBrowser(cOpc)
    local aRegs := {}
    cleanService()
    cKey := cOpc
    if !empty(cKey)
        if oFormulas:validAccess(cKey):isOk()
            if oFormulas:setKeyForm(cKey):isOk()
                aRegs := oFormulas:getFormulas()
                makeTempTable(aRegs)
                mountBrowser()
            endif
        endif
    endif
return(nil)

static function cleanService()
    cKey := ''
    oFormulas:setKeyForm(cKey)
    if oBrw <> nil
        oBrw:DeActivate()
    endif
    oBrw := nil
    if oTabTemp <> nil
		oTabTemp:Delete()
	endif
	oTabTemp	:= nil
    if oPnlPrinc <> NIL
        oPnlPrinc:FreeChildren()
    endif    
    cAls := ''
return(nil)

static function makeTempTable(aRegs)
    local aFlds := {}
    local aIdx  := {}
    local nX    := 0

    aFlds := getFields('T')
    aIdx  := getFields('I')

    oTabTemp := FWTemporaryTable():New(nextAlias())
    oTabTemp:SetFields(aFlds)
    oTabTemp:AddIndex('01', aClone(aIdx))
	oTabTemp:Create()
	cAls := oTabTemp:GetAlias()
    for nX := 1 to len(aRegs)
        updateAls('A', aRegs[nX])
    next nX
return(nil)

static function forcedRefresh()
    local nX    := 0
    local aRegs := {}

    (cAls)->(DbGoTop())
    while !(cAls)->(EOF())
        updateAls('D')
        (cAls)->(dbskip())
    endDo
    oFormulas:loadFormulas()
    aRegs := oFormulas:getFormulas()
    for nX := 1 to len(aRegs)
        updateAls('A', aRegs[nX])
    next nX
    oBrw:Refresh()
return(nil)

static function updateAls(cOper, aReg)
    local lRet      := .F.
    default aReg    := {}

    if cOper == 'A'
        if (lRet := (cAls)->(RecLock(cAls, .T.)))
            (cAls)->FILIAL   := iif(aReg[01] == '00', '  ', aReg[01])
            (cAls)->CODIGO   := aReg[04]
            (cAls)->CHAVE    := aReg[02]
            (cAls)->FORMULA  := aReg[03]
            (cAls)->RECNO    := aReg[05]
            (cAls)->(MsUnlock())
        endif
    elseif cOper == 'E'
        if (lRet := (cAls)->(RecLock(cAls, .F.)))
            (cAls)->FILIAL   := iif(aReg[01] == '00', '  ', aReg[01])
            (cAls)->CODIGO   := aReg[04]
            (cAls)->CHAVE    := aReg[02]
            (cAls)->FORMULA  := aReg[03]
            (cAls)->RECNO    := aReg[05]
            (cAls)->(MsUnlock())
        endif
    elseif cOper == 'D'
        if (lRet := (cAls)->(RecLock(cAls, .F.)))
			(cAls)->(DbDelete())
        endif
    endif
return(nil)

static function getFields(cOpc)
    local aFlds := {}
    default cOpc:= ''

    if cOpc == 'T'
        aAdd(aFlds, {'FILIAL',  'C', TamSx3('M4_FILIAL')[1], 0})
        aAdd(aFlds, {'CODIGO',  'C', TamSx3('M4_CODIGO')[1], 0})
        aAdd(aFlds, {'CHAVE',   'C', TamSx3('M4_DESCR')[1],  0})
        aAdd(aFlds, {'FORMULA', 'C', TamSx3('M4_FORMULA')[1],0})
        aAdd(aFlds, {'RECNO',   'N', 12,                     0})
    elseif cOpc == 'B'       
		aAdd(aFlds, {'Filial',  {||(oTabTemp:GetAlias())->(FILIAL)}, 'C',PesqPict('SM4','M4_FILIAL'), 1,TamSx3('M4_FILIAL')[1],0})
        aAdd(aFlds, {'Código',  {||(oTabTemp:GetAlias())->(CODIGO)}, 'C',PesqPict('SM4','M4_CODIGO'), 1,TamSx3('M4_CODIGO')[1],0})
        aAdd(aFlds, {'Chave',   {||(oTabTemp:GetAlias())->(CHAVE)},  'C',PesqPict('SM4','M4_DESCR'),  1,TamSx3('M4_DESCR')[1],0})
        aAdd(aFlds, {'Fórmula', {||(oTabTemp:GetAlias())->(FORMULA)},'C',PesqPict('SM4','M4_FORMULA'),1,TamSx3('M4_FORMULA')[1],0})
        //aAdd(aFlds, {'RECNO',{||(oTabTemp:GetAlias())->(RECNO)},'N','@E 999999999999',1,12,0})
    elseif cOpc == 'I'
        aAdd(aFlds, 'FILIAL')
        aAdd(aFlds, 'CODIGO')
        aAdd(aFlds, 'CHAVE')
    endif
return(aFlds)


static function mountBrowser()
    local aFlds := getFields('B')

    oBrw := FWMBrowse():New()
	oBrw:bldblclick := {|| accessRegister('E')}
	oBrw:SetOwner( oPnlPrinc )
	oBrw:SetDescription( 'INICIALIZADOR COM FORMULAS - ' + cKey )
	oBrw:SetAlias(cAls)
	oBrw:SetMenuDef('')
	oBrw:SetFields(aFlds)
	oBrw:SetProfileID('INIFORM')
	oBrw:ForceQuitButton(.T.)
	oBrw:DisableDetails()
	oBrw:DisableReport()
	oBrw:setIgnoreaRotina(.T.)
	oBrw:SetUseFilter(.T.)
	oBrw:AddButton('Adicionar', {|| accessRegister('A')},,,, .F., 7 )
    oBrw:AddButton('Editar',    {|| accessRegister('E')},,,, .F., 7 )
    oBrw:AddButton('Deletar',   {|| accessRegister('D')},,,, .F., 7 )
	oBrw:Activate()
return(nil)

static function accessRegister(cOpc)
    xFilial     := Space(TamSx3('M4_FILIAL')[1])
    cCodigo     := ''
    cForm       := Space(TamSx3('M4_FORMULA')[1])
    nRec        := 0

    if cOpc == 'E' .or. cOpc == 'D'
       xFilial  := (oTabTemp:GetAlias())->(FILIAL)
       cCodigo  := (oTabTemp:GetAlias())->(CODIGO)
       cForm    := (oTabTemp:GetAlias())->(FORMULA)
       nRec     := (oTabTemp:GetAlias())->(RECNO)
    endif
    regWindow(cOpc)
return(nil)

static function regWindow(cOpc)
    local oModal        := nil
    local oPnlModal     := nil
    local bConfirm      := {|| FWMsgRun(, { || regControl(cOpc, @oModal),"Atualizando Fórmula", "Processando..."})}
    local oSayFilial	:= nil
    local oGetFilial	:= nil
    local oSayCodigo	:= nil
    local oGetCodigo	:= nil
    local oSayKey	    := nil
    local oGetKey 	    := nil
    local oSayForm      := nil
    local oGetForm	    := nil

    
    default cOpc    := ''

    oModal  := FWDialogModal():New()
    oModal:setSize(200,300)
	oModal:SetEscClose(.T.)
	oModal:setTitle('Registro de Fórmula')
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
    oModal:addOkButton(bConfirm, "Confirma", {||.T.} )
    oPnlModal := TPanel():New( ,,, oModal:getPanelMain())
	oPnlModal:SetCss("")
	oPnlModal:Align := CONTROL_ALIGN_ALLCLIENT
    
    //COMPONETES
    oSayFilial	:= TSay():New(12,05,	{||'Filial:'}, oPnlModal,,oFont,,,,.T.,,, 100, 25)
    oGetFilial	:= TGet():New(05,55, 	{ | u | If( PCount() == 0, xFilial, xFilial := u ) }, oPnlModal, 220, 025,"@!",,0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,iif(cOpc=='D',.T.,.F.),.F.,,xFilial,,,, )


    oSayCodigo	:= TSay():New(42,05,	{||'Código:'}, oPnlModal,,oFont,,,,.T.,,, 100, 25)
    oGetCodigo	:= TGet():New(35,55, 	{ | u | If( PCount() == 0, cCodigo, cCodigo := u ) }, oPnlModal, 220, 025,"@!",,0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cCodigo,,,, )

    oSayKey	    := TSay():New(72,05,	{||'Key:'}, oPnlModal,,oFont,,,,.T.,,, 100, 25)
    oGetKey 	:= TGet():New(65,55, 	{ | u | If( PCount() == 0, cKey, cKey := u ) }, oPnlModal, 220, 025,"@!",,0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cKey,,,, )

    oSayForm    := TSay():New(102,05,	{||'Fórmula:'}, oPnlModal,,oFont,,,,.T.,,, 100, 25)
    oGetForm	:= TGet():New(95,55, 	{ | u | If( PCount() == 0, cForm, cForm := u ) }, oPnlModal, 220, 025,"@!",,0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,iif(cOpc=='D',.T.,.F.),.F.,,cForm,,,, )


    SetKey(VK_F5, {||oFormulas:getTip()})
    
    oModal:Activate()
    
    SetKey(VK_F5, {||})

    FreeObj(oSayFilial)	
    FreeObj(oGetFilial)	
    FreeObj(oSayCodigo)	
    FreeObj(oGetCodigo)	
    FreeObj(oSayKey)
    FreeObj(oGetKey)
    FreeObj(oSayForm)
    FreeObj(oGetForm)
    FreeObj(oPnlModal) 
    FreeObj(oModal)
return(nil)

static function regControl(cOpc, oModal)
    if cOpc == 'A'
        oFormulas:addFormula({{xFilial, cForm}})
    elseif cOpc == 'E'
        oFormulas:editFormula({{nRec, xFilial, cForm}})
    elseif cOpc == 'D'
        oFormulas:delFormula({{nRec}})
    endif
    oModal:DeActivate()
    forcedRefresh()
return(nil)

static function nextAlias()
	local cAls := ''
	while .T.
		cAls := GetNextAlias()
		if (Select(cAls) <= 0)
			exit
		endIf
	endDo
return(cAls)
