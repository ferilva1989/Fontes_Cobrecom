#include 'protheus.ch'
#include 'topconn.ch'

// 30/09/2013
// FAZER A BAIXA DA SEPARACAO PARA O ENVIAR NO RETRABALHO
user function crestr7a()

	local aPed := {}
	local cPerg := "crestr7a  "
	local cCombo := ''
	Private aSize := MsAdvSize( .T. , SetMDIChild() )

	Private oOk		:= LoadBitmap( GetResources(), "LBOK")
	Private oNo		:= LoadBitmap( GetResources(), "LBNO")

	private IND_PEDI := 01 // CONSTANTES OINDICE
	private IND_CLIE := 02
	private IND_PROD := 03
	private IND_ENTR := 04
	private IND_ACON := 05
	
	private PV_MARCA := 01
	private PV_SEPAR := 02
	private PV_PRODU := 03
	private PV_ACOND := 04
	private PV_NUMBO := 05
	private PV_METRA := 06
	private PV_LANCE := 07
	private PV_TOTAL := 08
	private PV_ZZU := 09
	private PV_ID := 10
	private PV_ZZEID := 11
	private PV_ZZEFIL := 12
	private oIndice	:= nil
	static oSeparar := nil

	ValidPerg( cPerg )
	if pergunte( cPerg, .t.)
		SelDados(@aPed)
		if( !empty(aPed) )
			DEFINE MSDIALOG oSeparar TITLE "BAIXAR SEPARACAO" FROM aSize[7], 0 TO aSize[6], aSize[5] OF oMainWnd PIXEL
			oSeparar:lMaximized := .T.

			@ 005 , 005 SAY oSay1 PROMPT "Ordenar por: " SIZE 50, 7 OF oSeparar Pixel
			@ 005 , 040 COMBOBOX oIndice VAR cCombo ITEMS {  "Produto", "Acondicionamento", "Metragem" } SIZE 60,10 OF oSeparar PIXEL
			oIndice:bChange := {|| ChCbPV1() }

			@ 005 , 110 BUTTON oButton1 PROMPT "Marcar Tudo" SIZE 037, 010 OF oSeparar Action {|| MarcarTudo(.T.) } PIXEL
			@ 005 , 150 BUTTON oButton2 PROMPT "Limpar" SIZE 037, 010 OF oSeparar Action {|| MarcarTudo(.F.) } PIXEL
			@ 005 , 190 BUTTON oButton3 PROMPT "Baixar" SIZE 037, 010 OF oSeparar Action {|| (Baixar()) } PIXEL
			@ 005 , 230 BUTTON oButton4 PROMPT "Fechar" SIZE 037, 010 OF oSeparar Action {|| oSeparar:End() } PIXEL

			@ 018 , 005 LISTBOX oLstPd FIELDS HEADER "", "Separa��o", "Produto", "Acondic.", "Bobina", "Metragem", "Lance", "Total", "ZZU", "ID", "RETRABALHO", "Filial" SIZE 800 , 400  OF oSeparar PIXEL
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
			oLstPd:aArray[oLstPd:nAt,12];
			}}

			ACTIVATE MSDIALOG oSeparar CENTERED
		endif
	endif
return

static function MarcarPedido() // DUPLO CLIQUE

	local aPd := oLstPd:aArray[oLstPd:nAt]
	local i    

	if( aPd[PV_TOTAL] > 0 )
		aPd[PV_MARCA] := iif(aPd[PV_MARCA],.F.,.T.)
	else
		aPd[PV_MARCA] := .F.
	endif

	for i := 1 to len(oLstPd:aArray)
		if oLstPd:aArray[i,PV_ZZEID] == aPd[PV_ZZEID]
			oLstPd:aArray[i,PV_MARCA] := aPd[PV_MARCA]
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

	do case
		case oIndice:nAt == 1
		oLstPd:aArray := aSort( oLstPd:aArray , , , { |x,y| x[PV_PRODU] <= y[PV_PRODU] } ) // ordenar por produto
		case oIndice:nAt == 2
		oLstPd:aArray := aSort( oLstPd:aArray, , , { |x,y| x[PV_ACOND] >= y[PV_ACOND] } )// ordenar por acondic
		case oIndice:nAt == 3
		oLstPd:aArray := aSort( oLstPd:aArray, , , { |x,y| x[PV_METRA] >= y[PV_METRA] } )	// ordenar por METRA
	endcase
	oLstPd:Refresh()

return


Static Function SelDados(aPed)
	local cqry, nqry, nCount
	local lPrimVez := .t.
	local nInd := 0

	cqry := " SELECT ZZU.R_E_C_N_O_ nZZU, ZZE.R_E_C_N_O_ nZZE " + CRLF
	cqry += " FROM " + RetSqlName("ZZU") + " ZZU " + CRLF
	cqry += " INNER JOIN " + RetSqlName("ZZE") + " ZZE ON ZZE_FILIAL = ZZU_FILIAL AND ZZE_ID = ZZU_ZZEID " + CRLF
	cqry += " WHERE " + CRLF
	cqry += " ZZU_FILIAL =  '" + xFilial("ZZU") + "'  AND " + CRLF
	cqry += " ZZU.ZZU_ZZFID BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND ZZU_STATUS = '1' AND " + CRLF
	cqry += " ZZU.D_E_L_E_T_ = ' ' " + CRLF

	iif( select("ZZFX") > 0, ZZFX->(dbclosearea()),  )

	tcquery cqry new alias "ZZFX"
	count to nqry
	if nqry > 0
		dbselectarea("ZZU")
		dbselectarea("ZZE")

		ZZFX->(DbGoTop())
		nCount := 0
		while !ZZFX->(eof())
			ZZU->(dbgoto(ZZFX->(NZZU)))
			ZZE->(dbgoto(ZZFX->(NZZE)))
			nCount ++          

			if aScan(aPed, {|x| x[PV_ZZEID] == ZZE->ZZE_ID .AND. x[PV_ZZEFIL] == ZZU->ZZU_FILIAL }) == 0    
				//.AND. ZZE->ZZE_PEDIDO != "000001"
				aAdd(aPed,{ .T.,ZZU->ZZU_ZZFID,ZZU->ZZU_DESCRI,u_TRACEXT(ZZU->ZZU_ACOND),IIF(ZZU->ZZU_ACOND=="B",ZZU->ZZU_NUMBOB,""),ZZU->ZZU_METRA,ZZU->ZZU_LANCE,ZZU->ZZU_TOTAL,ZZFX->(NZZU),nCount,ZZE->ZZE_ID, ZZU->ZZU_FILIAL })
			endif
			ZZFX->( DBSKIP() )
		enddo
		aPed := aSort( aPed , , , { |x,y| x[PV_PRODU] <= y[PV_PRODU] } )
	else
		alert("N�o existem registros para gerar Ordem de Separa��o")
	endif

return


static function Baixar()

	local aPv := oLstPd:aArray
	local i

	private oDlg
	Private cTitulo		:= "BAIXA DA ORDEM DE SEPARA��O RETRAB. SELECIONADOS"
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

		@ 20, 10  Say "Data recebimento: "   Size  45,08 of oDlg pixel
		@ 20, 70  MsGet oDtRec Var dDtRec    When .t. Size 60,08 of oDlg pixel

		@ 30, 10  Say "Hora recebimento: "   Size  45,08 of oDlg pixel
		@ 30, 70  MsGet oHrRec Var cHrRec    When .t. Size 60,08 picture "99:99" of oDlg pixel valid val( subst(cHrRec,1,2) ) >= 01 .and.;
		val( subst(cHrRec,1,2) ) <= 23 .and.;
		val( subst(cHrRec,4,2) ) >= 01 .and.;
		val( subst(cHrRec,4,2) ) <= 59

		@ 40, 10 Say "Respons�vel: "        Size  45,08 of oDlg pixel
		@ 40, 70 MsGet oResp Var cResp      When .t. Size 290,08 PICTURE "@!"of oDlg pixel   valid !empty(cResp)

		@ 70, 10 Button "Confirmar" 	     SIZE 50, 10 PIXEL OF oDlg ACTION ( MsgRun("Atualizando.......favor aguarde", "Atualiza��o", {|| ( oDlg:End(), Atualiza( aPv ) ) } ) )
		@ 70, 70 Button "Sair"   		     SIZE 50, 10 PIXEL OF oDlg ACTION ( oDlg:End() )

		ACTIVATE DIALOG oDlg centered
	else
		MsgInfo( "Sem itens marcados!" )
	endif

return nil


static function Atualiza( aPv )

	local i, cQry, nQry, j
	local aLPv := {}
	local lClose := .F.
	local cPROD, cLocaliz, cAcond, cDe, cPara, nQuant, cZE_TPBOB

	local cLocalA := GetMV("MV_XLOCALA") // ARMAZEM EM SEPARACAO
	local cLocalB := GetMV("MV_XLOCALB") // ARMAZEM EM RETRABALHO
	local aRet


	ZZE->(DbSetOrder(1))
	ZZU->(dbsetorder(2))
	ZZF->(dbsetorder(2)) // FILIAL + ID_RETRABALHO

	for i := 1 to len(aPv)
		if(aPv[i,PV_MARCA])
			ZZE->(dbseek(xFilial("ZZE") + aPv[i,PV_ZZEID]))
			ZZF->(dbseek(xFilial("ZZF") + aPv[i,PV_ZZEID]))
			ZZU->(DBGOTO(aPv[i,PV_ZZU]))
			//		cPROD		:= ALLTRIM(ZZU->ZZU_PRODUT)
			cPROD		:= ZZU->ZZU_PRODUT  // Roberto Oliveira 19/03/14
			//		cLocaliz	:= (ZZU->ZZU_ACOND) + STRZERO(ZZU->ZZU_METRA,5,0)
			cLocaliz	:= PadR((ZZU->ZZU_ACOND) + STRZERO(ZZU->ZZU_METRA,5,0),TamSX3("BE_LOCALIZ")[1]) // Roberto Oliveira 19/03/14
			cAcond		:= (ZZU->ZZU_ACOND)
			cDe			:= cLocalA
			cPara		:= cLocalB
			nQuant		:= ZZU->(ZZU_METRA * ZZU_LANCE)
			cZE_TPBOB	:= ZZF->(ZZF_TPBOB)

			//aRet := u_CRESTXT(.F.,cProd,cLocaliz,cAcond,cDe,cPara,nQuant,cZE_TPBOB, .t.,ZZF->ZZF_NUMBOB) // TRANSFERIR DA SEPARACAO PARA O RETRABALHO
			aRet := u_CRESTXT(.F.,cProd,cLocaliz,cAcond,cDe,cPara,nQuant,cZE_TPBOB, .t.,ZZF->ZZF_NUMBOB,,"ZZF") // TRANSFERIR DA SEPARACAO PARA O RETRABALHO

			// By Roberto Oliveira 17/02/2014 - Inicio

			// O IF abaixo tem que obrigatoriamente ser executado ap�s a u_CRESTXT (logo acima), conf conversa por telefone
			// com o Robert (proativa) em 18/03/14 14:48h.

			// Localizar e cancelar a bobina enviada para o retrabalho
			If cAcond == "B" .And. !Empty(ZZF->ZZF_NUMBOB) .And. aREt[1]
				SZE->(DbSetOrder(1))
				If SZE->(DbSeek(xFilial("SZE") + Left(ZZF->ZZF_NUMBOB,Len(SZE->ZE_NUMBOB)),.F.))
					Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_NUMBOB == Left(ZZF->ZZF_NUMBOB,Len(SZE->ZE_NUMBOB)) .And. SZE->(!Eof())
						if !(SZE->ZE_STATUS $ "FC")
							SZE->(RecLock("SZE",.F.))
								SZE->ZE_STATUS := "C"
							SZE->(MsUnLock())
						endif
						SZE->(DbSkip())
					EndDo
				Endif
			Endif
			// By Roberto Oliveira 17/02/2014 - Fim

			if aREt[1]
				ZZU->(reclock("ZZU",.F.))
				ZZU->ZZU_STATUS := "2"
				ZZU->ZZU_DTREC := dDtRec
				ZZU->ZZU_HRREC := cHrRec
				ZZU->ZZU_RESPON := cResp
				ZZU->(MSUNLOCK())        

				ZZF->(RECLOCK("ZZF",.F.))
				ZZF->ZZF_LOCAL := cPara
				ZZF->(MSUNLOCK())

				cQry := " UPDATE " + RETSQLNAME("ZZE") + " SET ZZE_STATUS = '2' WHERE D_E_L_E_T_ = '' AND ZZE_ID = '" + aPv[i,PV_ZZEID] + "' AND ZZE_FILIAL = '" + aPv[i,PV_ZZEFIL] + "' " // AGUARD, ORDEM SERVICO
				if TcSqlExec(cQry) < 0
					Alert("Ao atualizar status do retrabalho: " + CRLF + TcSqlError() )
				endif
				aAdd(aLpv,aPv[i,PV_ID])
			else
				Alert("N�o foi possivel transferir o estoque do produto: '" + ALLTRIM(ZZU->ZZU_DESCRI) + "'" )
				alert(aRet[2])
			endif
		endif
	next

	for i := 1 to len(aPv) // atualizar o status das separacoes
		if( aPv[i,PV_MARCA] )
			ZZU->(DBGOTO(aPv[i,PV_ZZU]))
			cqry := " SELECT * " + CRLF
			cqry += " FROM "+RetSqlName("ZZU")+" ZZU " + CRLF
			cqry += " WHERE " + CRLF
			cqry += " ZZU_FILIAL =  '" + ZZU->ZZU_FILIAL + "'  AND " + CRLF
			cqry += " ZZU.ZZU_ZZFID = '" + ZZU->ZZU_ZZFID + "' AND ZZU.ZZU_STATUS = '1' AND " + CRLF
			cqry += " ZZU.D_E_L_E_T_ = ' ' "

			iif( select("ZZUX") > 0, ZZUX->(dbclosearea()),  )

			tcquery cqry new alias "ZZUX"
			count to nqry
			if nqry > 0  // TEM IGUAL A 1 ENTAO ZZF � parcial
				cQry :=  " UPDATE " +RetSqlName("ZZF")+ " SET ZZF_STATUS = '5' WHERE ZZF_ID = '" + ZZU->ZZU_ZZFID + "' AND D_E_L_E_T_ = ' ' AND ZZF_FILIAL = '" + ZZU->ZZU_FILIAL + "' " // Atualiza status do ZZF   = 5
			else
				cQry :=  " UPDATE " +RetSqlName("ZZF")+ " SET ZZF_STATUS = '6' WHERE ZZF_ID = '" + ZZU->ZZU_ZZFID + "' AND D_E_L_E_T_ = ' ' AND ZZF_FILIAL = '" + ZZU->ZZU_FILIAL + "' " // total = 6
			endif
			TcSqlExec( cqry )
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

	if empty(aPed)
		aadd( aPed , {;
		.f.,;
		"",;
		"",;
		"",;
		"",;
		0,;
		0,;
		0,;
		0,;
		0,;
		"",;
		"";
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
	aAdd(aRegs,{cPerg,"01","Separacao De","mv_ch1","C",TamSX3("ZZF_ID")[1] ,0,0,"G","","mv_par01",""   ,"","",""   ,"","","","","","","","","","","ZZF"})
	aAdd(aRegs,{cPerg,"02","Separaca Ate","mv_ch2","C",TamSX3("ZZF_ID")[1] ,0,0,"G","","mv_par02",""   ,"","",""   ,"","","","","","","","","","","ZZF"})


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
