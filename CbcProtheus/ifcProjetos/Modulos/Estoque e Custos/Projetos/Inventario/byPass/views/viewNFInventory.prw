#include 'protheus.ch'
#include 'parmtype.ch'

user function viewNFInventory()
	local lCloseButt 	:= !(oAPP:lMdi)
	private aCoors 		:= FWGetDialogSize( oMainWnd )
	private oDlgPrinc	:= nil	
	private oSqlBrw		:= FWTemporaryTable():New(nextAlias())
	private cDtIni		:= ''
	private cDtFim		:= ''
	private oBrw		:= nil
	private cAls		:= ''
	private oPanel		:= nil
	private oFWLayer	:= nil
	
	if(getDateInterval(@cDtIni, @cDtFim))		
		DEFINE MSDIALOG oDlgPrinc TITLE 'Inventário' ;
		FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] ;
	    OF oMainWnd COLOR "W+/W" STYLE nOR(WS_VISIBLE,WS_POPUP) PIXEL
		oDlgPrinc:lMaximized := .T.
		
		oFWLayer := FWLayer():New()
		oFWLayer:Init(oDlgPrinc, lCloseButt)
	    oFWLayer:AddCollumn('PRINC', 100, .F.)
		oFWLayer:AddWindow('PRINC', 'WND_PRINC', 'NFs Processar', 100, .T., .F.)
		oPanel := oFWLayer:GetWinPanel('PRINC', 'WND_PRINC')
				
		//oPanel := TPanel():New( ,,, oDlgPrinc )
		mntTabTemp(@oSqlBrw, cDtIni, cDtFim)
		cAls := oSqlBrw:GetAlias()
		mntBrowser(@oBrw, cAls, @oPanel)
		oBrw:Activate()
		
		Activate MsDialog oDlgPrinc Center
		
		oSqlBrw:Delete()
	endif
	FreeObj(oBrw)
	FreeObj(oSqlBrw)
	FreeObj(oPanel)
	FreeObj(oFWLayer)
	FreeObj(oDlgPrinc)
return(nil)

static function getDateInterval(cDtIni, cDtFim)
	local aPergs	:= {}
	local aRet		:= {}
	local dDateIni	:= dDataBase
	local dDateFim	:= dDataBase
	local lRet		:= .T.
	
	aAdd( aPergs ,{1,"da  Dt. de Emissão: ", dDateIni, PesqPict("SF2","F2_EMISSAO"),'.T.',,'.T.',TamSX3("F2_EMISSAO")[1],.F.})
	aAdd( aPergs ,{1,"até Dt. de Emissão: ", dDateFim, PesqPict("SF2","F2_EMISSAO"),'.T.',,'.T.',TamSX3("F2_EMISSAO")[1],.F.})
	if !ParamBox(aPergs ,"Parâmetros do Processamento",aRet)      
		Alert("Processamento Cancelado!")
		lRet := .F.
	else
	     cDtIni := DTOS(MV_PAR01)
	     cDtFim := DTOS(MV_PAR02)
	endif	
return(lRet)

static function mntTabTemp(oSqlBrw, cDtIni, cDtFim)
	local cAls		:= ''
	local aIdx		:= {}
	Local oStatic   := IfcXFun():newIfcXFun()
	local cQry		:= oStatic:sP(2):callStatic('qryInventory', 'qryBrw',  cDtIni, cDtFim)
	local aFlds		:= oStatic:sP(1):callStatic('defInventory', 'defFldTab')

	aIdx := {aFlds[1,1], aFlds[2,1], aFlds[3,1]}

	oSqlBrw:SetFields( aFlds )
	oSqlBrw:AddIndex('01', aIdx )
	oSqlBrw:Create()
	cAls := oSqlBrw:GetAlias()
	SQLToTrb(cQry, aFlds, (cAls))
return(oSqlBrw)

static function  nextAlias()
	local cAls := ''
	while .T.
		cAls := GetNextAlias()
		if (Select(cAls) <= 0)
			exit
		endIf
	endDo
return(cAls)

static function mntBrowser(oBrw, cAls, oPanel)
	local bMark 	:= { || doMark() }
	Local oStatic   := IfcXFun():newIfcXFun()
	local aFlds 	:= oStatic:sP(1):callStatic('defInventory', 'defFldBrw')
	
	oBrw := FWMarkBrowse():New()
	oBrw:SetFieldMark('OK')
	oBrw:SetCustomMarkRec(bMark)
	oBrw:SetSemaphore(.T.)
	oBrw:SetOwner( oPanel )
	oBrw:SetDescription('Notas Fiscais')
	oBrw:SetAlias(cAls)
	oBrw:SetMenuDef('')
	oBrw:SetFields(aFlds)
	oBrw:SetProfileID('INB1')
	oBrw:ForceQuitButton(.T.)
	oBrw:DisableDetails()
	oBrw:DisableReport()
	oBrw:setIgnoreaRotina(.T.)
	oBrw:SetUseFilter(.T.)
	oBrw:AddButton('Inverter', {|| allMark()	} ,,7,)
	oBrw:AddButton('Processar',{|| doProcess() 	} ,,4,)
return(oBrw)

static function allMark()
	local nRegAtual := 0
	local nMarks	:= 0
	
	oBrw:GoTop(.T.)
	nRegAtual := oBrw:At()
	//Percorrer os registros do browser 
	while .T.
		doMark()			
		nMarks++		
		oBrw:GoDown(1, .F.)
		//Saida do loop Desceu um registro e continuou no mesmo significa que é o ultimo
		if nRegAtual == oBrw:At()
			EXIT
		endIf
		nRegAtual := oBrw:At()
	endDo
	oBrw:GoTop(.T.)
return(nMarks)

static function doMark()
	local cFld	:= oBrw:cFieldMark
	local cAls	:= oBrw:Alias()
	local cMark := oBrw:Mark()
	
	if (oBrw:CheckSemaphore(.F.))
		if (cAls)->(RecLock(cAls, .F.))
			if (cAls)->(&cFld) <> cMark
				(cAls)->(&cFld) := cMark
			else
				(cAls)->(&cFld) := ' '
			endif
			(cAls)->(MSUnlock())
		endif
	endif
return(nil)

static function doProcess()
	local cMark := oBrw:Mark()
	Local oStatic    := IfcXFun():newIfcXFun()
	if (msgYesNo('Esta rotina irá alterar as contagens da tabela de inventário. Confirma processamento?',;
				'Confirma?'))
				FWMsgRun(, { || oStatic:sP(2):callStatic('ctrlInventory', 'procDeduct', oSqlBrw, cMark) }, "Debitando NFs das Contagens", "Processando...")
	endif
	oDlgPrinc:End()
return(nil)
