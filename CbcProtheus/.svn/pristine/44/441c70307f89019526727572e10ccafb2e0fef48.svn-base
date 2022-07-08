#include 'protheus.ch'
#include 'topconn.ch'

// Robert Santos
// 30/09/2013
// Abrir tela para selecionar produtos para ordem de retrabalho
user function crest13()

	local aPed := {}
	local cPerg := "crest13   "
	local cCombo	:= ''
	Private aSize := MsAdvSize( .T. , SetMDIChild() )

	Private oOk		:= LoadBitmap( GetResources(), "LBOK")
	Private oNo		:= LoadBitmap( GetResources(), "LBNO")

	private IND_PEDI := 01 // CONSTANTES OINDICE
	private IND_CLIE := 02
	private IND_PROD := 03
	private IND_ACON := 04
	private IND_METR := 05

	private PV_MARCA := 01
	private PV_RETRA := 02
	private PV_PRODU := 03
	private PV_ACOND := 04
	private PV_NUMBO := 05
	private PV_METRA := 06
	private PV_LANCE := 07
	private PV_TOTAL := 08
	private PV_PEDID := 09
	private PV_ITEM  := 10
	private PV_CLIEN := 11
	private PV_ZZE   := 12
	private PV_ID    := 13
	private oIndice	 := nil
	static oSeparar := nil

	ValidPerg( cPerg )
	if pergunte( cPerg, .t.)
		SelDados(@aPed)
		if( !empty(aPed) )
			DEFINE MSDIALOG oSeparar TITLE "PRODUTOS PARA ORDEM DE RETRABALHO" FROM aSize[7], 0 TO aSize[6], aSize[5] OF oMainWnd PIXEL
			oSeparar:lMaximized := .T.

			@ 005 , 005 SAY oSay1 PROMPT "Ordenar por: " SIZE 50, 7 OF oSeparar Pixel
			@ 005 , 040 COMBOBOX oIndice VAR cCombo ITEMS {  "Pedido", "Cliente", "Produto", "Acondicionamento", "Metragem" } Size 60,10 of oSeparar pixel
			oIndice:bChange := {|| ChCbPV1() }

			@ 005 , 110 BUTTON oButton1 PROMPT "Marcar Tudo" SIZE 037, 010 OF oSeparar Action {|| MarcarTudo(.T.) } PIXEL
			@ 005 , 150 BUTTON oButton2 PROMPT "Limpar" SIZE 037, 010 OF oSeparar Action {|| MarcarTudo(.F.) } PIXEL
			@ 005 , 190 BUTTON oButton3 PROMPT "Gerar" SIZE 037, 010 OF oSeparar Action {|| (Baixar()) } PIXEL
			@ 005 , 230 BUTTON oButton4 PROMPT "Fechar" SIZE 037, 010 OF oSeparar Action {|| oSeparar:End() } PIXEL

			@ 018 , 005 LISTBOX oLstPd FIELDS HEADER "", "Retrabalho", "Produto", "Acondic.", "Bobina", "Metragem", "Lance", "Total", "Pedido", "Item", "Cliente" "ZZE", "ID" SIZE 800 , 400  OF oSeparar PIXEL
			oLstPd:NHEIGHT := oLstPd:NHEIGHT := oSeparar:OWND:NHEIGHT - 70
			oLstPd:Nwidth  := oLstPd:Nwidth  := oSeparar:OWND:NWIDTH - 20

			ResetAPED(@aPed)
			oLstPd:SetArray( aPed )

			oLstPd:blDblClick := {|| MarcarPedido() }

			oLstPd:bLine := {|| {;
			iif(oLstPd:aArray[oLstPd:nAt,1],oOk,oNo),;
			oLstPd:aArray[oLstPd:nAt,2],;
			oLstPd:aArray[oLstPd:nAt,3],;
			oLstPd:aArray[oLstPd:nAt,4],;
			oLstPd:aArray[oLstPd:nAt,5],;
			oLstPd:aArray[oLstPd:nAt,6],;
			oLstPd:aArray[oLstPd:nAt,7],;
			oLstPd:aArray[oLstPd:nAt,8],;
			oLstPd:aArray[oLstPd:nAt,9],;
			oLstPd:aArray[oLstPd:nAt,10],;
			oLstPd:aArray[oLstPd:nAt,11],;
			oLstPd:aArray[oLstPd:nAt,12],;
			oLstPd:aArray[oLstPd:nAt,13];
			}}

			ACTIVATE MSDIALOG oSeparar CENTERED
		endif
	endif
return

static function MarcarPedido() // DUPLO CLIQUE

	local aPd := oLstPd:aArray[oLstPd:nAt]
	local aPds := oLstPd:aArray
	local i          
	local lMarcar := .F. // ??

	if( aPd[PV_TOTAL] > 0 ) // controlar tela em branco
		lMarcar := iif(aPd[PV_MARCA],.F.,.T.)
	else  
		lMarcar := .F.
	endif

	for i := 1 to len(aPds)
		if( aPds[i,PV_RETRA] == aPd[PV_RETRA] )
			aPds[i,PV_MARCA] := lMarcar
		endif
	next

	oLstPd:Refresh()

return nil

static function MarcarTudo( lMarcar)

	local aPd := oLstPd:aArray
	local i

	for i := 1 to len(aPd)
		if( aPd[i,PV_TOTAL] > 0 )
			aPd[i,PV_MARCA] := lMarcar
		else
			aPd[i,PV_MARCA] := .F.
		endif
	next
	oLstPd:Refresh()

return nil


static function ChCbPV1()

	do case //"Pedido", "Cliente", "Produto", "Acondicionamento", "Metragem"
		case oIndice:nAt == 1
		oLstPd:aArray := aSort( oLstPd:aArray , , , { |x,y| x[PV_PEDID] <= y[PV_PEDID] } )
		case oIndice:nAt == 2
		oLstPd:aArray := aSort( oLstPd:aArray, , , { |x,y| x[PV_CLIEN] >= y[PV_CLIEN] } )
		case oIndice:nAt == 3
		oLstPd:aArray := aSort( oLstPd:aArray, , , { |x,y| x[PV_PRODU] >= y[PV_PRODU] } )
		case oIndice:nAt == 4
		oLstPd:aArray := aSort( oLstPd:aArray, , , { |x,y| x[PV_ACOND] >= y[PV_ACOND] } )
		case oIndice:nAt == 5
		oLstPd:aArray := aSort( oLstPd:aArray, , , { |x,y| x[PV_METRA] >= y[PV_METRA] } )	// ordenar por METRA
	endcase
	oLstPd:Refresh()

return


Static Function SelDados(aPed)
	local cqry, nqry, nCount
	local lPrimVez := .t.

	cqry := " SELECT ZZE.R_E_C_N_O_ nZZE " + CRLF
	cqry += " FROM " + RetSqlName("ZZF") + " ZZF " + CRLF
	cqry += " INNER JOIN "+RetSqlName("ZZE")+" ZZE ON ZZE_ID = ZZF_ZZEID " + CRLF
	cqry += " AND ZZE.D_E_L_E_T_ = ' ' AND ZZF_FILIAL = ZZE_FILIAL  " + CRLF
	cqry += " AND ZZE_ORDEM = '' " + CRLF // AGUARD. ORDEM DE SERVICO
	cqry += " WHERE " + CRLF
	cqry += " ZZF_FILIAL = '"+xFilial("ZZF")+"' AND " + CRLF
	cqry += " ZZF.ZZF_ZZEID BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND ZZF_STATUS = '6' AND " + CRLF
	cqry += " ZZF.D_E_L_E_T_ = ' ' " + CRLF
	iif( select("ZZFX") > 0, ZZFX->(dbclosearea()),  )

	tcquery cqry new alias "ZZFX"
	count to nqry
	if nqry > 0
		dbselectarea("ZZE")
		dbselectarea("SB1")
		SB1->(DBSETORDER(1))

		ZZFX->(DbGoTop())
		nCount := 0
		while !ZZFX->(eof())
			ZZE->(dbgoto(ZZFX->(NZZE)))
			nCount ++
			// "", "Retrabalho", "Produto", "Acondic.", "Bobina", "Metragem", "Lance", "Total", "Pedido", "Item", "Cliente" "ZZE", "ID"
			SB1->( dbseek(xFilial("SB1") + ZZE->ZZE_PRODUT) )

			aAdd( aPed , { .T. ,;
			ZZE->ZZE_ID,;
			SB1->B1_DESC,;
			u_TRACEXT(ZZE->ZZE_ACONDS),;
			IIF( ZZE->ZZE_ACONDS == "B" , ZZE->ZZE_NUMBOB , "" ),;
			ZZE->ZZE_METRAS ,;
			ZZE->ZZE_LANCES ,;
			ZZE->(ZZE_METRAS * ZZE_LANCES) ,;
			ZZE->ZZE_PEDIDO ,;
			ZZE->ZZE_ITEMPV ,;
			ZZE->ZZE_NOMCLI ,;
			ZZFX->NZZE ,;
			nCount } )

			ZZFX->( DBSKIP() )
		enddo
		aPed := aSort( aPed , , , { |x,y| x[PV_PRODU] <= y[PV_PRODU] } )
	else
		alert("Não existem registros para gerar Ordem de Retrabalho, ou Ordem de Separação não foi terminada!")
	endif

return


static function Baixar()

	local aPv := oLstPd:aArray
	local i

	private oDlg
	Private cTitulo		:= "GERAR ORDEM DE SERVICO DE RETRABALHO"
	PRIVATE oDtRec
	private dDtRec := ddatabase
	private oResp
	private cResp := space(50)
	private oHrRec
	private cHrRec := substr(time(),1,5)

	i := aScan(aPv,{|x| x[PV_MARCA] == .T. })
	if i > 0
		DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD

		Define MsDialog oDlg Title cTitulo From 000,000 To 25, 100 Of oMainWnd

		@ 20, 10 Say "Será gerado um número de ordem de serviço para os retrabalhos selecionados." SIZE 300,07 OF oDLG PIXEL

		@ 50, 10 Button "Confirmar" 	     SIZE 50, 10 PIXEL OF oDlg ACTION ( MsgRun("Atualizando.......favor aguarde", "Atualização", {|| ( oDlg:End(), Atualiza( aPv ) ) } ) )
		@ 50, 70 Button "Sair"   		     SIZE 50, 10 PIXEL OF oDlg ACTION ( oDlg:End() )

		ACTIVATE DIALOG oDlg centered
	else
		MsgInfo( "Sem itens marcados!" )
	endif

return nil


static function Atualiza( aPv )

	local i, cQry, nQry, j
	local aLPv := {}
	local lClose := .F.
	local cZZE_ORDEM := GetSXENum("ZZE","ZZE_ORDEM")
	ConfirmSX8()

	dbselectarea("ZZE")

	for i := 1 to len(aPv)
		if( aPv[i,PV_MARCA] )
			ZZE->(DBGOTO(aPv[i,PV_ZZE]))

			reclock("ZZE",.F.)
			ZZE->ZZE_STATUS := "3" // EM RETRABALHO
			ZZE->ZZE_ORDEM := cZZE_ORDEM
			ZZE->( MSUNLOCK() )

			aAdd( aLpv, aPv[i,PV_ID] )
		endif
	next

	for i := 1 to len(aLpv)
		j := aScan( aPv, { |x| x[PV_ID] == aLpv[i] } )
		if( j > 0)
			if(len(aPv)==1)
				lClose := .T.
				aPv := {}
				ResetAPED(@aPv)
			else
				aPv := aDel( aPv , j )
				aPv := aSize(aPv,len(aPv)-1)
			endif
		endif
	next

	if( lClose )
		oSeparar:End()
	else
		oLstPd:Refresh()
	endif
	LjMsgRun("Processado!")

return nil

static function ResetAPED(aPed)

	if empty(aPed) //"", "Retrabalho", "Produto", "Acondic.", "Bobina", "Metragem", "Lance", "Total", "Pedido", "Item", "Cliente" "ZZE", "ID"
		aadd( aPed , {;
		.f.,;
		"",;
		"",;
		"",;
		"",;
		0,;
		0,;
		0,;
		"",;
		"",;
		"",;
		0,;
		0;
		} )
	endif

return

Static Function ValidPerg( cPerg )

	local _aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Retrabalho De","mv_ch1","C",TamSX3("ZZE_ID")[1] ,0,0,"G","","mv_par01",""   ,"","",""   ,"","","","","","","","","","","ZZE"})
	aAdd(aRegs,{cPerg,"02","Retrabalho Ate","mv_ch2","C",TamSX3("ZZE_ID")[1] ,0,0,"G","","mv_par02",""   ,"","",""   ,"","","","","","","","","","","ZZE"})


	For i := 1 To Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			SX1->X1_GRUPO   := aRegs[i,01]
			SX1->X1_ORDEM   := aRegs[i,02]
			SX1->X1_PERGUNT := aRegs[i,03]
			SX1->X1_VARIAVL := aRegs[i,04]
			SX1->X1_TIPO    := aRegs[i,05]
			SX1->X1_TAMANHO := aRegs[i,06]
			SX1->X1_DECIMAL := aRegs[i,07]
			SX1->X1_PRESEL  := aRegs[i,08]
			SX1->X1_GSC     := aRegs[i,09]
			SX1->X1_VALID   := aRegs[i,10]
			SX1->X1_VAR01   := aRegs[i,11]
			SX1->X1_DEF01   := aRegs[i,12]
			SX1->X1_CNT01   := aRegs[i,13]
			SX1->X1_VAR02   := aRegs[i,14]
			SX1->X1_DEF02   := aRegs[i,15]
			SX1->X1_CNT02   := aRegs[i,16]
			SX1->X1_VAR03   := aRegs[i,17]
			SX1->X1_DEF03   := aRegs[i,18]
			SX1->X1_CNT03   := aRegs[i,19]
			SX1->X1_VAR04   := aRegs[i,20]
			SX1->X1_DEF04   := aRegs[i,21]
			SX1->X1_CNT04   := aRegs[i,22]
			SX1->X1_VAR05   := aRegs[i,23]
			SX1->X1_DEF05   := aRegs[i,24]
			SX1->X1_CNT05   := aRegs[i,25]
			SX1->X1_F3      := aRegs[i,26]
			MsUnlock()
			DbCommit()
		Endif
	Next

	RestArea(_aArea)

Return
