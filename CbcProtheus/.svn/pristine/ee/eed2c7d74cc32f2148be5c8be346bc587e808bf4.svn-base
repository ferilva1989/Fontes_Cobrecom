#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FwMVCDef.ch'

#define TIPO 3
#define TAMANHO	1
#define DECIMAL 2

user function cbcMrkRegVenda(cMstFil, lExecuted)
	local aStruct	   as array
	local aCoors 	   as array
	local oPanel	   as object
	local oFWLayer     as object
	Local oStatic    	:= IfcXFun():newIfcXFun()
	private oDlgPrinc  as object
	private oMark	   as object
	private tempInfo   as array
	private lEscolhido as boolean
	default cMstFil	  	:= '03'
	default lExecuted	:= .F.

	lEscolhido	:= .F.
	tempInfo 	:= createTemp(cMstFil)
	aStruct 	:= oStatic:sP(1):callStatic('cbcViewRegVenda', 'getStruct')
	aCoors 		:= FWGetDialogSize( oMainWnd )

	Define MsDialog oDlgPrinc Title 'Gerar Necessidade Pedido'  From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )

	oFWLayer:AddCollumn('COLUNA_PRINCIPAL', 100, .F.)
	oFWLayer:AddWindow('COLUNA_PRINCIPAL', 'JANELA_PRINCIPAL', 'Pedidos', 100, .T., .F.)
	oPanel := oFWLayer:GetWinPanel('COLUNA_PRINCIPAL', 'JANELA_PRINCIPAL')

	oMark := FWMarkBrowse():New()
	oMark:SetAlias(tempInfo[1])
	oMark:SetOwner(oPanel)
	oMark:SetDescription('Seleção Pedidos')
	oMark:SetTemporary(.T.)
	oMark:SetFields(aStruct)
	oMark:ForceQuitButton(.T.)
	defSeek()
	oMark:SetSeeAll(.F.)
	oMark:DisableReport()
	oMark:SetMenuDef('cbcMrkRegVenda')
	oMark:SetProfileID('MRK_MULTFIL')
	oMark:SetFieldMark( 'C5_OK' )
	oMark:SetSemaphore(.T.)
	oMark:OpenSemaphore()
	oMark:AddButton('Visualizar',{|| callMenu('Visualizar'	,oMark) },,7,)
	oMark:Activate()	
	Activate MsDialog oDlgPrinc Center

	lExecuted := lEscolhido
	tempInfo[2]:Delete()
	FreeObj(tempInfo[2])
	FreeObj(oFWLayer)
	FreeObj(oMark)
	FreeObj(oPanel)
return (nil)


static function MenuDef()
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Processar' ACTION 'StaticCall(cbcMrkRegVenda, escolhido)' OPERATION 3 ACCESS 0
return(aRotina)


static function callMenu(cOp, oBrwFrom)
	local nRecBrwReg as numeric
	Local oStatic    := IfcXFun():newIfcXFun()
	nRecBrwReg := getRecno(( (oBrwFrom:oBrowse:cAlias))->(C5_FILIAL + C5_NUM)) 
	if cOp == 'Visualizar'
		FWMsgRun(, { |oSay|  oStatic:sP(1):callStatic('cbcViewRegVenda', 'verPedido', nRecBrwReg) }, "Selecionando", " Abrindo Pedido...")
	endif
return(nil)


static function defLegenda()
	//oMark:AddLegend( "ZA0_TIPO=='2'", "BLUE" , "Interprete" )
return (nil)

static function isMark()
	local nCont as numeric
	local cMarca as char
	local cTab as char
	local aPedi as array

	cMarca  := oMark:Mark()
	cTab	:= tempInfo[1]
	aPedi 	:= {}
	
	(cTab)->( DbGoTop())
	nCont := 0
	While !(cTab)->(Eof())
		If (((cTab)->C5_OK) == cMarca)
			aadd(aPedi, getRecno((cTab)->(C5_FILIAL + C5_NUM)) )
			nCont++
		Endif
		(cTab)->( dbSkip() )
	EndDo
	if nCont == 0
		Alert("Nenhum Registro Marcado")
		return
	Endif
return (aPedi)


static function escolhido()
	Local aPed as array
	if !empty(aPed := isMark())
		lEscolhido := .T.
		u_cbcProcTriangle(aPed)
	endif
	oDlgPrinc:End()
	aPed := {}
return(nil)


static function getRecno(cFilPed)
	local nRecno		as numeric
	local oSql			as object 
	oSql 			:= LibSqlObj():newLibSqlObj()
	nRecno			:= oSql:getFieldValue("SC5", "R_E_C_N_O_", "C5_FILIAL + C5_NUM = '" + cFilPed + "'")
	oSql:close()
	FreeObj(oSql)	
return(nRecno)


static function createTemp(cMstFil)
	local aStruct 	 as array
	local oTempTable as object
	local cFields 	 as char
	local nLoop 	 as numeric
	local cQuery	 as char
	Local oStatic    := IfcXFun():newIfcXFun()
	local cAls	as char
	default cMstFil	:= FwFilial()

	aStruct := oStatic:sP(1):callStatic('cbcViewRegVenda', 'getStruct')
	oTempTable := FWTemporaryTable():New()
	oTempTable:SetFields(PrepStruct(aStruct) )
	oTempTable:AddIndex("01", {"C5_FILIAL","C5_NUM"} )
	oTempTable:Create()
	cFields := ""
	for nLoop := 1 to Len(aStruct)
		cFields += aStruct[nLoop][2] + ","
	next nLoop
	cFields := Left(cFields, Len(cFields) -1)

	cQuery := "INSERT INTO " + oTempTable:GetRealName()
	cQuery += " (" + cFields + ") " 
	cQuery += u_cbQryMrkBrw(cFields, cMstFil)

	if TCSqlExec(cQuery) < 0
		ConOut("O comando SQL gerou erro:", TCSqlError())
	else
		cAls := oTempTable:GetAlias()
	endif 
return ({cAls, oTempTable})


static function PrepStruct(aOrigem)
	local aStruct as array
	local nX as numeric
	aStruct := {}
	for nX := 1 to len(aOrigem)
		aadd(aStruct, {aOrigem[nX,2],;
		aOrigem[nX,3],;
		aOrigem[nX,4],;
		aOrigem[nX,5]})	
	next nX
return(aStruct)


static function defSeek()
	local aSeek			:= {}
	local aSx3Num		:= {}
	local aSx3Cli		:= {}
	local aSx3Loj		:= {}
	local aSx3DtEntr	:= {}
	local aSx3DtGen		:= {}
	aSx3Num 	:= TamSx3("C5_NUM")
	aSx3Cli		:= TamSx3("C5_CLIENTE")
	aSx3Loj		:= TamSx3("C5_LOJACLI")
	aSx3DtGen	:= TamSx3("C5_DTFAT")
	aSx3DtEntr	:= TamSx3("C5_ENTREG")
	aAdd(aSeek,{"Filial+Pedido" ,{{"",'C',TamSx3('C5_NUM')[1],0,"C5_NUM",PesqPict( 'SC5', 'C5_NUM' )}}})
	oMark:SetSeek(.T.,aSeek)
return(nil)
