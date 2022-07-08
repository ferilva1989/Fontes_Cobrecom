#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

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


user Function cbcMarkZBA(oCbcTitManut)
	local aCoors 			:= FWGetDialogSize( oMainWnd )
	local oPanelUp		:= nil
	local oFWLayer		:= nil
	local oPanelLeft		:= nil
	local oPanelRight		:= nil
	local oRelacZA4		:= nil
	local oRelacZA5		:= nil
	local aColunas		:= {}
	local bBxDoMark		:= {|| doMark(oBrowseUp,oSqlBx)}
	local bDsDoMark		:= {|| doMark(oBrowseLeft,oSqlDes)}
	local bPrDoMark		:= {|| doMark(oBrowseRight,oSqlPro)}
	private oDlgPrinc		:= nil
	private oBrowseUp		:= nil
	private oBrowseLeft	:= nil
	private oBrowseRight	:= nil
	private oCtrl 		:= nil
	private oSqlBx		:= FWTemporaryTable():New(nextAlias())
	private oSqlDes		:= FWTemporaryTable():New(nextAlias())
	private oSqlPro		:= FWTemporaryTable():New(nextAlias())
	default oCbcTitManut	:= cbcTitManut():newcbcTitManut()
	
	prepTemp(oSqlBx, 'BAIXAR')
	prepTemp(oSqlDes, 'DESCONTO')
	prepTemp(oSqlPro, 'PRORROGACAO')
	oCtrl	:= oCbcTitManut
	
	Define MsDialog oDlgPrinc Title 'Relatorio Manut. Titulos Receber' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] Pixel
	
	// Cria o conteiner onde serão colocados os browses
	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )
	
	// Painel Superior
	// Cria uma "linha" com 50% da tela
	oFWLayer:AddLine( 'UP', 50, .F. )
	// Na "linha" criada eu crio uma coluna com 100% da tamanho dela
	oFWLayer:AddCollumn( 'ALL', 100, .T., 'UP' )
	oPanelUp := oFWLayer:GetColPanel( 'ALL', 'UP' )
	
	// Painel Inferior
	oFWLayer:AddLine( 'DOWN', 50, .F. )
	// Cria uma "linha" com 50% da tela
	oFWLayer:AddCollumn( 'LEFT' , 50, .T., 'DOWN' )
	// Na "linha" criada eu crio uma coluna com 50% da tamanho dela
	oFWLayer:AddCollumn( 'RIGHT', 50, .T., 'DOWN' )
	// Na "linha" criada eu crio uma coluna com 50% da tamanho dela
	oPanelLeft := oFWLayer:GetColPanel('LEFT' , 'DOWN')
	oPanelRight := oFWLayer:GetColPanel('RIGHT', 'DOWN')
	
	// Colunas exibidas no browser
	aColunas := getFlds('BRW')
	
	// FWmBrowse Superior Baixar
	montaBrw(@oBrowseUp,oPanelUp,'Baixas',oSqlBx:GetAlias(),aColunas,'1',bBxDoMark,"cbcMarkZBA")
	
	// Lado Esquerdo Descontos
	montaBrw(@oBrowseLeft,oPanelLeft,'Descontos',oSqlDes:GetAlias(),aColunas,'2',bDsDoMark)
	
	// Lado Direito Prorrogação
	montaBrw(@oBrowseRight,oPanelRight,'Prorrogação',oSqlPro:GetAlias(),aColunas,'3',bPrDoMark)
	
	// Relacionamento entre os Paineis
	/*
	oRelacZA4:= FWBrwRelation():New()
	oRelacZA4:AddRelation( oBrowseUp , oBrowseLeft , { { 'ZA4_FILIAL', 'xFilial( "ZA4" )' }, { 'ZA4_ALBUM' , 'ZA3_ALBUM' } } )
	oRelacZA4:Activate()
	oRelacZA5:= FWBrwRelation():New()
	oRelacZA5:AddRelation( oBrowseLeft, oBrowseRight, { { 'ZA5_FILIAL', 'xFilial( "ZA5" )' }, { 'ZA5_ALBUM' , 'ZA4_ALBUM' }, { 'ZA5_MUSICA', 'ZA4_MUSICA' } } )
	oRelacZA5:Activate()
	*/
	Activate MsDialog oDlgPrinc Center
	
	oSqlBx:Delete()
	oSqlDes:Delete()
	oSqlPro:Delete()
	FreeObj(oSqlBx)
	FreeObj(oSqlDes)
	FreeObj(oSqlPro)
return (nil)


static function ModelDef()
return FWLoadModel('cbcZBAModel')


static function ViewDef()
return FWLoadView( 'cbcZBAModel' )


static function MenuDef()
	local aOpcoes     := {}
	ADD OPTION aOpcoes TITLE "Gerar Relatorio" ACTION 'StaticCall(cbcMarkZBA, procOpc, "NEW")' OPERATION 3 ACCESS 0
	ADD OPTION aOpcoes TITLE "Cancelar" ACTION 'StaticCall(cbcMarkZBA, procOpc, "DEL")' OPERATION 3 ACCESS 0
return (aOpcoes)


static function  doMark(oBrowse,oSql)
	local aArea    	:= GetArea()
	local cMarca		:= oBrowse:Mark()
	local cAls		:= oSql:GetAlias()
	
	if (cAls)->(RecLock(cAls, .F.))
		if oCtrl:doMark({(cAls)->(REC),{(cAls)->(OPER),cAls,(cAls)->(Recno())} }):isOk()
			if (cAls)->(ZBA_MKB) <> cMarca
				(cAls)->(ZBA_MKB) := cMarca
			else
				(cAls)->(ZBA_MKB) := ' '
			endif
		endif
		(cAls)->(MSUnlock())
	endif
	
	RestArea(aArea)
return (nil)


static function procOpc(nOpc)
	oCtrl:procMark(nOpc)
	if ! oCtrl:lOk
		Help( ,, 'Help','Erro', oCtrl:cMsgErr, 1, 0 )
	else
		oBrowseUp:Refresh()
		oBrowseLeft:Refresh()
		oBrowseRight:Refresh()
		oBrowseLeft:executefilter(.T.)
		oBrowseRight:executefilter(.T.)
	endif
return(nil)


static function getFlds(cWho)
	local aFlds		:= {}
	local aTmp		:= {}
	local aSx3		:= {}
	local nX			:= 0
	local aTratNom	:= {}
	
	aadd(aTmp,{ "ZBA_FILIAL" 	,	"AS [FILIAL], "	, {"","",0,0}, {"","" ,"",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_OPER"		,	"AS [OPER], "		, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_VLRCC"	,	"AS [VALOR_CC], "	, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_DTREL"	,	"AS [DTREL], "	, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_NOMCLI"	,	"AS [NOMCLI], "	, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_VENORI"	,	"AS [VENORI], "	, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_VENCRE"	,	"AS [VENCRE], "	, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_VALOR"	,	"AS [VALOR], "	, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_HISTOP"	,	"AS [HISTOP], "	, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_PREFIX"	,	"AS [PREFIXO], "	, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_NUM"		,	"AS [NUM], "		, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_PARC"		,	"AS [PARC], "		, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_TIPO"		,	"AS [TIPO], "		, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_CLI"		,	"AS [CLI], "		, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_LOJA"		,	"AS [LOJA], "		, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_DESCON"	,	"AS [DESCON], "	, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_SLDESC"	,	"AS [SLDESC], "	, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_SALDO"	,	"AS [SALDO], "	, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_VLROPE"	,	"AS [VLROPER], "	, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_EMISS"	,	"AS [EMISS], "	, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_VENCTO"	,	"AS [VENCTO], "	, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_BAIXA"	,	"AS [BAIXA], "	, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "ZBA_MKB"		,	"AS [ZBA_MKB], "	, {"","",0,0}, {"","", "",0,0,""},.T.}   )
	aadd(aTmp,{ "R_E_C_N_O_"	, 	"AS [REC] "		, {"REC","N",10,0},{"REC","REC","N",10,0,""},.F.}   )
	for nX := 1 to len(aTmp)
		cNomeCampo := Alltrim(StrTran(StrTran(StrToKArr(aTmp[nX,NOME_SQL],'[')[2], ']',''),',',''))
		aSx3 := TamSx3(aTmp[nX,NOME_CAMPO])
		if cWho == 'SQL'
			aadd(aFlds,{aTmp[nX,NOME_CAMPO] + ' ' + aTmp[nX,NOME_SQL]} )
		elseif cWho == 'TRB'
			aTmp[nX,INFO_TRB,NOME_CAMPO] 		:= 	cNomeCampo
			aTmp[nX,INFO_TRB,TIPO_TRB] 		:= 	if(aTmp[nX,TEM_INFO],aSx3[TIPO]		,aTmp[nX,INFO_TRB,TIPO_TRB])
			aTmp[nX,INFO_TRB,TAM_TRB]			:=	if(aTmp[nX,TEM_INFO],aSx3[TAMANHO]	,aTmp[nX,INFO_TRB,TAM_TRB])
			aTmp[nX,INFO_TRB,DEC_TRB]			:=	if(aTmp[nX,TEM_INFO],aSx3[DECIMAL]	,aTmp[nX,INFO_TRB,DEC_TRB])
			aadd(aFlds, aTmp[nX,INFO_TRB] )
		elseif cWho == 'BRW'
			aTmp[nX,INFO_BROWSER,NOME_CAMPO]	:= 	cNomeCampo
			aTmp[nX,INFO_BROWSER,TITULO_BROWSE]	:=	if(aTmp[nX,TEM_INFO],cNomeCampo						,aTmp[nX,INFO_BROWSER,TITULO_BROWSE])
			aTmp[nX,INFO_BROWSER,TIPO_BROWSE]	:=	if(aTmp[nX,TEM_INFO],aSx3[TIPO]						,aTmp[nX,INFO_BROWSER,TIPO_BROWSE])
			aTmp[nX,INFO_BROWSER,TAM_BROWSE]	:=	if(aTmp[nX,TEM_INFO],aSx3[TAMANHO]					,aTmp[nX,INFO_BROWSER,TAM_BROWSE])
			aTmp[nX,INFO_BROWSER,DEC_BROWSE]	:=  if(aTmp[nX,TEM_INFO],aSx3[DECIMAL]					,aTmp[nX,INFO_BROWSER,DEC_BROWSE])
			aTmp[nX,INFO_BROWSER,PIC_BROWSE]	:=  if(aTmp[nX,TEM_INFO],X3Picture(aTmp[nX,NOME_CAMPO])	,aTmp[nX,INFO_BROWSER,PIC_BROWSE])
			aadd(aFlds, aTmp[nX,INFO_BROWSER] )
		endif
	next nX
return(aFlds)


static function  nextAlias()
	local cAls := ''
	while .T.
		cAls := GetNextAlias()
		if (Select(cAls) <= 0)
			exit
		endIf
	endDo
return(cAls)


static function prepTemp(oTmpTab,cOper)
	local cQry		:= ''
	local aFlds		:= getFlds('TRB')
	local aQry		:= getFlds('SQL')
	local cAls		:= nextAlias()
	local nX			:= 0
	local cNewAls		:= ''
	
	oTmpTab:SetFields( aFlds )
	oTmpTab:AddIndex("01", {"OPER"} )
	oTmpTab:Create()
	
	cQry += " SELECT "
	for nX := 1 to Len(aQry)
		cQry += aQry[nX,1]
	next nX
	cQry += " FROM " + RetSqlName('ZBA')
	cQry += " WHERE  ZBA_NROREL = '' "
	cQry += " AND "
	if cOper == 'DESCONTO'
		cQry += " (ZBA_OPER LIKE '%DESCONTO%' OR ZBA_OPER LIKE '%DESC.%') "
	else
		cQry += " ZBA_OPER LIKE '%" + cOper + "%' "
	endif
	cQry += " AND  D_E_L_E_T_ <> '*' "
	
	oTmpTab:executeQuery(cQry, cAls, aFlds)
	
	cNewAls := oTmpTab:getAlias()
	(cAls)->(DbSelectArea((cAls)))
	(cAls)->(DbGoTop())
	while !((cAls)->(EOF()))
		(cNewAls)->(RecLock((cNewAls), .T.))
		for nX := 1 to (cAls)->(fcount())
			(cNewAls)->(&((cAls)->(fieldname(nX)))) := (cAls)->(fieldget(nX))
		next
		(cNewAls)->(MsUnLock())
		(cAls)->(DBSkip())
	enddo
	(cAls)->(DbCloseArea())
return(nil)


static function montaBrw(oBrw, oPanel, cDesc, cAls, aColunas, cProfId, bMark, cMenuDef)
	default cMenuDef := ''
	oBrw:= FWMarkBrowse():New()
	oBrw:SetFieldMark('ZBA_MKB')
	oBrw:SetOwner( oPanel )
	oBrw:SetDescription( cDesc )
	oBrw:SetAlias(cAls)
	oBrw:SetFields(aColunas)
	oBrw:SetMenuDef(cMenuDef)
	oBrw:SetTemporary(.T.)
	oBrw:SetProfileID( cProfId )
	oBrw:ForceQuitButton(.T.)
	oBrw:SetCustomMarkRec(bMark)
	oBrw:setignorearotina(.T.)
	oBrw:DisableSeek(.T.)
	oBrw:SetUseFilter(.F.)
	oBrw:Activate()
return(oBrw)

