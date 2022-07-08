#include "rwmake.ch"
#include 'topconn.ch'
#include 'protheus.ch'

// Tela da negociação - Acionada por CREST161 Menu

*
****************************************
User Function REST161a(cAlias,nReg,nOpc)
****************************************
*
Local aArea := GetArea()
Local nLin := 5
Local nCol := 5
Local oFolder1 := nil
Local cAtend

Private PV_PEDID 	:= 01
Private PV_ITEM 	:= 02
Private PV_PROD 	:= 03
Private PV_DESC		:= 04
Private PV_QTDPV 	:= 08
Private PV_ACOND 	:= 05
Private PV_METRA 	:= 06
Private PV_LANCE 	:= 07
Private PV_TOTAL 	:= 09
Private PV_ZZVID 	:= 10

Private AL_PRODU	:= 01
Private AL_DESCR	:= 02
Private AL_ACOND	:= 03
Private AL_METRA	:= 04
Private AL_LANCE	:= 05
Private AL_TOTAL	:= 06
Private AL_BOBIN	:= 07
Private AL_TPBOB	:= 08
Private AL_ALMOX	:= 09

Private aSize	:= MsAdvSize( .T. , SetMDIChild() )
Private oOk		:= LoadBitmap( GetResources(), "LBOK")
Private oNo		:= LoadBitmap( GetResources(), "LBNO")

Private oScroll
Private oPanel
Private oLstPd
Private oLstProd
Private __lAutor	:= .F.

Static oDlg1	:= nil


If ZZV->ZZV_STATUS > "3"
	Alert("Negociação já Realizada")
	Return(.T.)
EndIf

_cNmVend := "Representante: " + AllTrim(ZZV->ZZV_VEND) + " - " + AllTrim(Posicione("SA3",1,xFilial("SA3")+ZZV->ZZV_VEND,"A3_NOME"))

ZZW->(DbSetOrder(1))
ZZV->(DbSetOrder(1))
SB1->(DbSetOrder(1))
SC5->(DbSetOrder(1))
SC6->(DbSetOrder(1))

ZZX->(DbSetOrder(2)) // analisar poder do atendente do representante
ZZX->(DbSeek(xFilial("ZZX") + ZZV->ZZV_VEND))
cAtend := ZZX->ZZX_ATENDE

ZZX->(DbSetOrder(3))
ZZX->(DbSeek(xFilial("ZZX") + cAtend + "S"))
__lAutor := (ZZX->ZZX_APR01 == "S")

If(SC5->(DbSeek(xFilial("SC5") + ZZV->ZZV_PEDIDO )))

	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	If SA1->(DbSeek(xFilial("SA1") + SC5->(C5_CLIENTE + C5_LOJACLI)))
		DEFINE MSDIALOG oDlg1 TITLE "NEGOCIAÇÃO COM CLIENTE" FROM aSize[7], 0 TO aSize[6], aSize[5] OF oMainWnd PIXEL
		oDlg1:lMaximized := .T.
		oDlg1:Refresh()

		oScroll := TScrollArea():New(oDlg1,01,01,100,100,.T.,.T.,.T.) // Cria objeto Scroll
		oScroll:Align := CONTROL_ALIGN_ALLCLIENT
		//SIZE 970              ,594 
		@ 000,000 MSPANEL oPanel OF oScroll SIZE oDlg1:OWND:NWIDTH,oDlg1:OWND:NHEIGHT // Cria painel
		oScroll:SetFrame( oPanel ) // Define objeto painel como filho do scroll
		oPanel:OWND:NWIDTH := oDlg1:OWND:NWIDTH

		@ nLin , 5 SAY "Negociação com o Cliente" SIZE 70, 7 OF oPanel COLORS 16711680, 16777215 Pixel
		@ nLin += 8 , 7 SAY "Cliente: " + SA1->A1_NOME SIZE 200, 7 OF oPanel Pixel

		@ nLin , 200 SAY _cNmVend SIZE 200, 7 OF oPanel Pixel

		@ nLin += 12 , 5 SAY "Pedidos em Negociação" SIZE 70, 7 OF oPanel COLORS 16711680, 16777215 Pixel

		nLin += 8
		@ nLin , 7 LISTBOX oLstPd FIELDS ;
		HEADER "Pedido"  , "Item" , "Produto" , "Descrição" , "Qt.Orig.PV.", "Acondic."    ,;
		"Metragem", "Lance", "Total"   , "ID"        , "Observações" ;
		SIZE 5 , 5  OF oPanel PIXEL
		oLstPd:NHEIGHT := nLin + 100
		oLstPd:Nwidth  := oPanel:OWND:NWIDTH - 40

		oLstPd:SetArray(GtPedidos(SA1->A1_COD,SA1->A1_LOJA))

		oLstPd:bLine := {|| {;
		oLstPd:aArray[oLstPd:nAt,01],;
		oLstPd:aArray[oLstPd:nAt,02],;
		oLstPd:aArray[oLstPd:nAt,03],;
		oLstPd:aArray[oLstPd:nAt,04],;
		oLstPd:aArray[oLstPd:nAt,05],;
		u_TRACEXT(oLstPd:aArray[oLstPd:nAt,06]),;
		oLstPd:aArray[oLstPd:nAt,07],;
		oLstPd:aArray[oLstPd:nAt,08],;
		oLstPd:aArray[oLstPd:nAt,09],;
		oLstPd:aArray[oLstPd:nAt,10],;
		Alltrim(oLstPd:aArray[oLstPd:nAt,11]);
		}}

		oLstPd:bChange := {|| SetOfer() }

		nLin += 65
		@ nLin += 12 , 5 SAY "Produto oferecido" SIZE 70, 7 OF oPanel COLORS 16711680, 16777215 Pixel

		nLin += 8
		@ nLin , 7 LISTBOX oLstProd FIELDS ;
		HEADER "Produto", "Descrição", "Acondic.", "Metragem", "Lance", "Total" SIZE 5 , 5  OF oPanel PIXEL

		oLstProd:NHEIGHT := (nLin + 17)
		oLstProd:Nwidth  := oPanel:OWND:NWIDTH - 40

		oLstProd:SetArray(ResetLstProd())

		oLstProd:bLine := {|| {;
		oLstProd:aArray[oLstProd:nAt,1],;
		oLstProd:aArray[oLstProd:nAt,2],;
		u_TRACEXT(oLstProd:aArray[oLstProd:nAt,3]),;
		oLstProd:aArray[oLstProd:nAt,4],;
		oLstProd:aArray[oLstProd:nAt,5],;
		oLstProd:aArray[oLstProd:nAt,6];
		}}

		nLin += 65
		@ nLin += 12 , 5 SAY "Saldos e contatos (Duplo clique Operações)" SIZE 180, 7 OF oPanel COLORS 16711680, 16777215 Pixel
		nLin += 8
		@ nLin , 7 FOLDER oFolder1 SIZE 5 , 5 OF oPanel ITEMS "Produtos Alternativos","Contatos Realizados","Contatos Futuros" COLORS 0, 16777215 PIXEL
		oFolder1:Nwidth  := oPanel:OWND:NWIDTH - 40
		oFolder1:nHeight := (nLin + 110)

		@ 5,5 LISTBOX oGridAL FIELDS HEADER "Produto","Descrição","Acondic","Metragem","Lance","Total","Bobina" SIZE 5 , 5 OF oFolder1:aDialogs[1] PIXEL
		oGridAL:Nwidth  := oPanel:OWND:NWIDTH - 65
		oGridAL:nHeight := (nLin + 70)

		oGridAL:SetArray(ResetAAl())

		oGridAL:bLine := {|| { ;
		oGridAL:aArray[oGridAL:nAt,1],;
		oGridAL:aArray[oGridAL:nAt,2],;
		oGridAL:aArray[oGridAL:nAt,3],;
		oGridAL:aArray[oGridAL:nAt,4],;
		oGridAL:aArray[oGridAL:nAt,5],;
		oGridAL:aArray[oGridAL:nAt,6],;
		oGridAL:aArray[oGridAL:nAt,7],;
		oGridAL:aArray[oGridAL:nAt,8],;
		oGridAL:aArray[oGridAL:nAt,9];
		}}

		oGridAl:blDblClick := { || TrocaOfer() }

		@ 5,5 LISTBOX oGridCo FIELDS HEADER "Data","Horario","Contato Com" SIZE 5 , 5 OF oFolder1:aDialogs[2] PIXEL
		oGridCo:Nwidth  := oPanel:OWND:NWIDTH - 65
		oGridCo:nHeight := (nLin + 70)

		oGridCo:SetArray(ResetACon())

		oGridCo:bLine := {|| { ;
		oGridCo:aArray[oGridCo:nAt,1],;
		oGridCo:aArray[oGridCo:nAt,2],;
		oGridCo:aArray[oGridCo:nAt,3],;
		oGridCo:aArray[oGridCo:nAt,4];
		}}

		oGridCo:blDblClick := { || GtMessage(1) }

		@ 5,5 LISTBOX oGridFu FIELDS HEADER "Data","Horario","Contato Com" SIZE 5 , 5 OF oFolder1:aDialogs[3] PIXEL
		oGridFu:Nwidth  := oPanel:OWND:NWIDTH - 65
		oGridFu:nHeight := (nLin + 70)

		oGridFu:SetArray(ResetACon())

		oGridFu:bLine := {|| { ;
		oGridFu:aArray[oGridFu:nAt,1],;
		oGridFu:aArray[oGridFu:nAt,2],;
		oGridFu:aArray[oGridFu:nAt,3],;
		oGridFu:aArray[oGridFu:nAt,4];
		}}

		oGridFu:blDblClick := { || GtMessage(2) }

		nCol := 0
		nLIn += 155
		// Tirando o botão Agendar
		//@ nLin += 12 , nCol += 05 BUTTON "Agendar" SIZE 040, 010 OF oPanel Action {|| Agendamento() } PIXEL
		nLin += 12
		@ nLin       , nCol += 42 BUTTON "Aceite"  SIZE 040, 010 OF oPanel Action {|| Aceite(.T.) } PIXEL
		@ nLin       , nCol += 42 BUTTON "Recusa"  SIZE 040, 010 OF oPanel Action {|| Aceite(.F.) } PIXEL
		@ nLin       , nCol += 42 BUTTON "Sair"    SIZE 040, 010 OF oPanel Action {|| Sair() } PIXEL

		SetOfer() // buscar produto oferecido e saldo dos alternativos

		ACTIVATE MSDIALOG oDlg1 CENTERED
	Else
		alert("Cliente não encontrado!")
	EndIf
Else
	alert("Pedido não encontrado!")
EndIf

ZZX->(DbSetOrder(1))

RestArea(aArea)

Eval( bFiltraBrw )

Return(nil)
*
**********************
Static Function Sair()
**********************
*
If( MsgYesNo("Deseja sair?") )
	oDlg1:End()
EndIf
Return(.T.)
*
***************************
Static Function ResetAPED()
***************************
*
Local aPed := {}
aadd( aPed , {;
"",;
"",;
"",;
"",;
"",;
0,;
0,;
0,;
0,;
"";
} )
Return(aPed)   
*
******************************
Static Function ResetLstProd()
******************************
*
Local aProd := {} //"Produto", "Descrição", "Acondic.", "Metragem", "Lance", "Total"
aadd( aProd , {;
"",;
"",;
"",;
0,;
0,;
0;
})
Return(aProd)
*
**************************
Static Function ResetAAl()
**************************
*
Local aRet := {}   
aadd( aRet , {;
"",;
"",;
"",;
0,;
0,;
0,;
"",;
"",;
"";
} )
Return(aRet)
*
***************************
Static Function ResetACon()
***************************
*
Local aRet := {}
aadd( aRet , {;
ctod("//"),;
"00:00",;
"",;
0;
} )
Return(aRet)
*
********************************************
Static Function GtPedidos(cA1_COD, cA1_LOJA)
********************************************
*
Local aRet := {}
Local cQry, nQry

If(select("TMP") > 0)
	TMP->(DBCLOSEAREA())
EndIf
cQry := " select ZZV.R_E_C_N_O_ NZZV from " + RETSQLNAME("ZZV") + " ZZV " + CRLF // BUSCAR TODAS NEGOCIACOES EM ABERTO PARA O CLIENTE
cQry += " INNER JOIN " + RETSQLNAME("SC5") + " C5 ON " + CRLF
cQry += " C5.D_E_L_E_T_ = ' ' AND C5_CLIENTE = '" + cA1_COD + "' " + CRLF
cQry += " AND C5_LOJACLI = '" + cA1_LOJA + "' " + CRLF
cQry += " AND C5_FILIAL = ZZV_FILPV " + CRLF
cQry += " AND C5_NUM = ZZV_PEDIDO " + CRLF
cQry += " where ZZV.D_E_L_E_T_ = ' ' " + CRLF
cQry += " AND ZZV_FILIAL = '" + ZZV->ZZV_FILIAL + "' " + CRLF
cQry += " AND ZZV_VEND = '" + ZZV->ZZV_VEND + "' " + CRLF
cQry += " AND ZZV_STATUS IN ('1','2','3') " + CRLF
TCQUERY CQRY NEW ALIAS "TMP"
COUNT TO nQRY
If nQry > 0
	DbSelectArea("ZZV")

	TMP->(DBGOTOP())
	Do While !TMP->(EOF())
		ZZV->(DBGOTO(TMP->NZZV))

		SB1->(DbSeek(xFilial("SB1") + ZZV->ZZV_PRODUT))
		AADD(aRet, {ZZV->ZZV_PEDIDO,;
		ZZV->ZZV_ITEM,;
		ZZV->ZZV_PRODUT,;
		SB1->B1_DESC,;
		Posicione("SC6",1,xFilial("SC6")+ZZV->ZZV_PEDIDO+ZZV->ZZV_ITEM,"C6_QTDVEN"),;
		ZZV->ZZV_ACOND,;
		ZZV->ZZV_METRAG,;
		ZZV->ZZV_LANCES,;
		ZZV->(ZZV_METRAG * ZZV_LANCES),;
		ZZV->(ZZV_ID),;
		ZZV->(ZZV_OBS01);
		})
		TMP->(DBSKIP())
	EndDo
Else
	aRet := ResetAPED()
EndIf
TMP->(DBCLOSEAREA())

Return(aRet)
*
*************************
Static Function SetOfer()
*************************
*
Local aRet := {}
Local cQry, nQry

ZZV->(DbSeek(xFilial("ZZV") + oLstPd:aArray[oLstPd:nAt,PV_ZZVID]))

SB1->(DbSeek(xFilial("SB1") + ZZV->ZZV_PROALT))

AADD(aRet, {;
ZZV->ZZV_PROALT,;
SB1->B1_DESC,;
ZZV->ZZV_ACONAL,;
ZZV->ZZV_METRAL,;
ZZV->ZZV_LANCEA,;
ZZV->(ZZV_METRAL * ZZV_LANCEA);
}) // "Produto", "Descrição", "Acondic.", "Metragem", "Lance", "Total"

oLstProd:aArray := aClone(aRet)
oLstProd:Refresh()

GetSdoA() // Buscar saldo Alternativos
oGridCo:aArray := GtContat(1) // retornar lista de ligacoes da negociacao
oGridFu:aArray := GtContat(2) // retornar lista de ligacoes da negociacao

oGridCo:Refresh()
oGridFu:Refresh()

Return(.T.)    
*
/* PREENCHER GRADE DE SALDO DE PRODUTOS */
*************************
Static Function GetSdoA()
*************************
*
Local cqry, nqry, nQtdSZR
Local i, nQtd
Local cBitola	:= ""
Local cCor		:= ""
Local aSB1		:= SB1->(GetArea())
Local cB1_cod	:= oLstPd:AArray[oLstPd:nAt,PV_PROD]
Local aDados := {}

cB1_COD := alltrim(cB1_COD)
If len(cB1_COD) >= 7
	cBitola		:= substr( cB1_COD, 4, 2 )
	cCor		:= substr( cB1_COD, 6, 2 )

	cqry := " select ZZA_PRDALT, Z1_COD, Z1_DESC from "+CRLF
	cqry += "  "+RETSQLNAME("ZZA")+" ZZA "+CRLF
	cqry += " inner join  "+RETSQLNAME("SZ1")+" Z1 on Z1_COD = ZZA_PRDALT and Z1.D_E_L_E_T_ = '' "+CRLF
	cqry += " where ZZA.D_E_L_E_T_ = '' and ZZA_PROD = '"+Substr(cB1_COD,1,3)+"' order by ZZA_PRDALT "+CRLF
	If( select("TMP_BF4")>0,TMP_BF4->(dbclosearea()), )
	tcquery cqry new alias "TMP_BF4"
	count to nqry
	If nqry > 0

		TMP_BF4->(dbgotop())
		Do While !TMP_BF4->(eof())
			If SB1->(DbSeek(xfilial("SB1")+TMP_BF4->(ZZA_PRDALT)+cBitola+cCor))
				cqry := ""
				cqry += " select "+CRLF
				cQry += "    isnull(BF_QUANT-BF_EMPENHO,0) TOTAL, BF_LOCAL "+CRLF
				cQry += "    , SUBSTRING(BF_LOCALIZ,1,1) ACONDIC "+CRLF
				cQry += "    , ISNULL(CAST( isnull(SUBSTRING(BF_LOCALIZ,2,5),'1') AS NUMERIC ),0) LANCE "+CRLF
				cQry += " "+CRLF
				cQry += " from "+RetSqlName("SBF")+" BF"+CRLF
				cQry += " where BF.D_E_L_E_T_ = ' ' AND BF_FILIAL = '"+xFilial("SBF")+"' and BF_LOCAL = '01' and (BF_QUANT-BF_EMPENHO) > 0 "+CRLF
				cQry += " and SUBSTRING(BF_LOCALIZ,1,1) <> 'B' "+CRLF
				cQry += " and BF_PRODUTO = '"+SB1->B1_COD+"' "+CRLF

				If( select("TMP_BF3")>0,TMP_BF3->(dbclosearea()), )
				tcquery cqry new alias "TMP_BF3"
				count to nqry
				If nqry > 0

					aDados := {}
					TMP_BF3->( dbgotop() )
					Do While !TMP_BF3->(eof())
						If !TMP_BF3->(ACONDIC) $ "R/C/M" // _NOVO_ Tratar diferenciado de Rolo item a item. O rolo pode estar aglutinado
							nQtd := Int( TMP_BF3->(TOTAL/LANCE) )
							for i := 1 to nQtd
								aadd( aDados  , {;
								(SB1->B1_COD) ;
								,	(SB1->B1_DESC) ;
								, 	(TMP_BF3->(ACONDIC)) ;
								, 	TMP_BF3->(LANCE) ;
								, 	1 ;
								, 	TMP_BF3->(LANCE) ;
								,	"" ;
								,	"" ;
								,	TMP_BF3->(BF_LOCAL) ;
								} )//"Produto","Descrição","Acondic","Metragem","Lance","Total","Bobina",'TPBOB', LOCA
							Next
						Else
							aadd( aDados  , {;
							rtrim(SB1->B1_COD) ;
							,	rtrim(SB1->B1_DESC) ;
							, 	(TMP_BF3->(ACONDIC)) ;
							, 	TMP_BF3->(LANCE) ;
							, 	Int( TMP_BF3->(TOTAL/LANCE) ) ;
							, 	TMP_BF3->(TOTAL) ;
							, 	"" ;
							, 	"" ;
							,	TMP_BF3->(BF_LOCAL) ;
							} )
						EndIf

						TMP_BF3->(dbskip())
					EndDo
				EndIf
				TMP_BF3->(dbclosearea())


				cqry := "" // pegar saldo de bobinas
				cqry += " select "+CRLF
				cQry += "     ZE_NUMBOB, ZE_QUANT, ZE_TPBOB "+CRLF
				cQry += " "+CRLF
				cQry += " from "+RetSqlName("SZE")+" ZE "+CRLF
				cQry += " where ZE.D_E_L_E_T_ = ' ' AND ZE_FILIAL = '"+xFilial("SBF")+"' and ZE_STATUS = 'T' "+CRLF
				cQry += " and ZE_PRODUTO = '"+SB1->B1_COD+"' "+CRLF

				If( select("TMP_BF3")>0,TMP_BF3->(dbclosearea()), )
				tcquery cqry new alias "TMP_BF3"
				count to nqry
				If nqry > 0
					DbSelectArea("SZR")
					SZR->(DbSetOrder(1)) // ZR_FILIAL+ZR_NUMBOB

					TMP_BF3->( dbgotop() )
					Do While !TMP_BF3->(eof())
						aadd( aDados  , {;
						rtrim(SB1->B1_COD) ;
						,	rtrim(SB1->B1_DESC) ;
						, 	("B") ;
						, 	(TMP_BF3->(ZE_QUANT)) ;
						, 	1 ;
						, 	TMP_BF3->(ZE_QUANT) ;
						, 	TMP_BF3->(ZE_NUMBOB) ;
						, 	TMP_BF3->(ZE_TPBOB) ;
						, 	"01" ;
						} )

						TMP_BF3->(dbskip())
					EndDo
				EndIf

				TMP_BF3->(dbclosearea())
			EndIf
			TMP_BF4->(dbskip())
		EndDo
	EndIf
	TMP_BF4->(dbclosearea())
EndIf

RestArea(aSB1)

If empty(aDados)
	oGridAl:aArray := ResetAAl()
Else
	oGridAL:aArray := aDados
EndIf
oGridAL:Refresh()

Return(.T.)
*
******************************
Static Function GtContat(nVal)
******************************
*
Local aRet := {} // "Data","Horario","Contato Com"
Local cQry, nQry

If(select("TMP") > 0)
	TMP->(DBCLOSEAREA())
EndIf
cQry := " select ZZW.R_E_C_N_O_ NZZW from " + RETSQLNAME("ZZW") + " ZZW " + CRLF // BUSCAR TODAS NEGOCIACOES EM ABERTO PARA O CLIENTE
cQry += " where ZZW.D_E_L_E_T_ = ' ' " + CRLF
cQry += " AND ZZW_FILIAL = '" + ZZV->ZZV_FILIAL + "' " + CRLF
cQry += " AND ZZW_ZZVID = '" + ZZV->ZZV_ID + "' " + CRLF
If nval == 1 // AGENDA OCORRIDA
	cQry += " AND ZZW_FUTUR <> 'S' " + CRLF
Else
	cQry += " AND ZZW_FUTUR = 'S' " + CRLF
EndIf
cQry += " ORDER BY ZZW.R_E_C_N_O_ DESC " + CRLF
TCQUERY CQRY NEW ALIAS "TMP"
COUNT TO nQRY
If nQry > 0
	TMP->(DBGOTOP())
	Do While !TMP->(EOF())
		ZZW->(DBGOTO(TMP->NZZW))

		If nVal == 1
			AADD(aRET,{;
			ZZW->ZZW_DATAR ;
			, ZZW->ZZW_HORAR ;
			, ZZW->ZZW_NOMER ;
			, TMP->NZZW ;
			})
		Else
			AADD(aRET,{;
			ZZW->ZZW_DATAF ;
			, ZZW->ZZW_HORAF ;
			, ZZW->ZZW_NOMEF ;
			, TMP->NZZW ;
			})
		EndIf
		TMP->(DBSKIP())
	EndDo
Else
	aRet := ResetACon()
EndIf
TMP->(DBCLOSEAREA())

Return(aRet)
*
**********************************
Static Function GtMessage(nInterr)
**********************************
*
Local oSButton1
Local oScrollB1
Local oGet1
Local cGet1 := ""

Static oDlg2

If nInterr == 1
	ZZW->(DBGOTO(oGridCo:aArray[oGridCo:nAt,4]))
	cGet1:=alltrim(ZZW->ZZW_OBSR)
Else
	ZZW->(DBGOTO(oGridFu:aArray[oGridFu:nAt,4]))
	cGet1:=alltrim(ZZW->ZZW_OBSF)
EndIf

DEFINE MSDIALOG oDlg2 TITLE "Detalhe contato" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 of oMainWnd PIXEL

// @ 006, 003 GET oGet1 VAR cGet1 SIZE 242, 224 OF oDlg2 MULTILINE COLORS 0, 16777215 HSCROLL PIXEL
@ 006, 003 GET cGet1 MEMO SIZE 242, 224 OF oDlg2 COLORS 0, 16777215 PIXEL HSCROLL
DEFINE SBUTTON oSButton1 FROM 235, 217 TYPE 02 OF oDlg2 ENABLE ACTION {||oDlg2:End()}

ACTIVATE MSDIALOG oDlg2 CENTERED

Return(.T.)
*
*****************************
Static Function Agendamento()
*****************************
*
Local cConAtual := Space(TamSX3("ZZW_NOMER")[1])
Local cConFuturo := cConAtual
Local dDataFuturo := Date()
Local cObsAtual
Local cObsFuturo
Local cHora := space(5)
Local oBtCancel
Local oBtOk
Static oDlg3

DEFINE MSDIALOG oDlg3 TITLE "Agendamento" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL

@ 004, 004 SAY "Contato Com:" 					SIZE 038, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
@ 002, 039 GET cConAtual 						SIZE 205, 010 OF oDlg3 COLORS 0, 16777215 PIXEL
@ 015, 003 SAY "Ocorrencia Atual:" 				SIZE 060, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
@ 024, 003 GET cObsAtual MEMO 					SIZE 242, 054 OF oDlg3 COLORS 0, 16777215 PIXEL HSCROLL
@ 097, 005 SAY "Falar Com:" 					SIZE 038, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
@ 095, 040 GET cConFuturo 						SIZE 205, 010 OF oDlg3 COLORS 0, 16777215 PIXEL
@ 110, 005 SAY "Quando:" 						SIZE 030, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
@ 108, 040 GET dDataFuturo 						SIZE 042, 010 OF oDlg3 COLORS 0, 16777215 PIXEL
@ 110, 085 SAY "Horário:" 						SIZE 030, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
@ 108, 110 GET cHora 							SIZE 022, 010 OF oDlg3 COLORS 0, 16777215 PICTURE "99:99" PIXEL
@ 121, 003 SAY  "Descrição atividade futura:" 	SIZE 100, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
@ 129, 004 GET cObsFuturo MEMO 					SIZE 242, 099 OF oDlg3 COLORS 0, 16777215 PIXEL HSCROLL

DEFINE SBUTTON oBtCancel FROM 234, 219 TYPE 02 OF oDlg3 ENABLE ACTION { || oDlg3:End() }
DEFINE SBUTTON oBtOk FROM 234, 189 TYPE 01 OF oDlg3 ENABLE ACTION { || MsgRun("Favor aguarde","Aguarde",{||Agendar(cObsAtual,cConAtual,cObsFuturo,cConFuturo,dDataFuturo,cHora)}) }

ACTIVATE MSDIALOG oDlg3 CENTERED

Return(.T.)
*
************************************************************************************
Static Function Agendar(cObsAtual,cConAtual,cObsFuturo,cConFuturo,dDataFuturo,cHora)
************************************************************************************
*
Local lOk := .T.
Local cZZV_ID := oLstPd:aArray[oLstPd:nAt,PV_ZZVID]
Local cQry, nQry, nZZW  

SC6->(DbSetOrder(1))

If empty(cObsAtual) .or. empty(cConAtual) .or. empty(cObsFuturo) .or. empty(cConFuturo) .or. empty(dDataFuturo) .or. empty(cHora) // Validar a tela
	Alert("Favor preencher todos os campos")
	lOk := .F.
Else
	If dDataFuturo < dDatabase
		Alert("Favor informar data da próxima ligação no minimo na data de hoje.")
		lOk := .F.
	EndIf
EndIf

If lOk
	ZZV->(DbSeek(xFilial("ZZV") + cZZV_ID ))

	If(select("TMP") > 0)
		TMP->(DBCLOSEAREA())
	EndIf
	cQry := " select ZZW.R_E_C_N_O_ NZZW from " + RETSQLNAME("ZZW") + " ZZW " + CRLF // BUSCAR TODAS NEGOCIACOES EM ABERTO PARA O CLIENTE
	cQry += " where ZZW.D_E_L_E_T_ = ' ' " + CRLF
	cQry += " AND ZZW_FILIAL = '" + ZZV->ZZV_FILIAL + "' " + CRLF
	cQry += " AND ZZW_ZZVID = '" + ZZV->ZZV_ID + "' " + CRLF
	cQry += " AND ZZW_FUTUR = 'S' " + CRLF
	TCQUERY CQRY NEW ALIAS "TMP"
	COUNT TO nZZW
	If nZZW  > 0
		ZZW->(DBGOTO(nZZW))
	EndIf

	ZZW->(RecLock("ZZW",If(nZZW>0,.F.,.T.))) // GRAVAR / ALTERAR CONTATO FUTURO (UM POR NEGOCIACAO SEMPRE)
	ZZW->ZZW_FILIAL := xFILIAL("ZZW")
	ZZW->ZZW_ZZVID := cZZV_ID
	ZZW->ZZW_DATAF := dDATAFUTURO
	ZZW->ZZW_HORAF := cHORA
	ZZW->ZZW_NOMEF := cCONFUTURO
	ZZW->ZZW_OBSF := cOBSFUTURO
	ZZW->ZZW_FUTUR := "S"
	ZZW->(MsUnLock())

	ZZW->(RecLock("ZZW",.T.)) // GRAVAR CONTATO ATUAL
	ZZW->ZZW_FILIAL := xFILIAL("ZZW")
	ZZW->ZZW_ZZVID := cZZV_ID
	ZZW->ZZW_DATAR := dDatabase
	ZZW->ZZW_HORAR := substr(Time(),1,5)
	ZZW->ZZW_NOMER := cConAtual
	ZZW->ZZW_OBSR := cObsAtual
	ZZW->(MsUnLock())

	ZZV->(RecLock("ZZV",.F.)) // ATUALIZAR O STATUS DA NEGOCIACAO COMO EM NEGOCIACAO
	ZZV->ZZV_STATUS := "3" // AGENDAMENTO FUTURO
	ZZV->ZZV_DATAF := dDataFuturo
	ZZV->ZZV_NOMEF := cCONFUTURO
	ZZV->ZZV_OBSF := cOBSFUTURO
	If empty(ZZV->ZZV_DTPRIM)
		ZZV->ZZV_DTPRIM := dDataFuturo
	EndIf
	ZZV->(MsUnLock())

	If SC6->(DbSeek(ZZV->(ZZV_FILPV + ZZV_PEDIDO + ZZV_ITEM ))) // ATUALIZAR A NEGOCIACAO DO ITEM DO PEDIDO DE VENDA
		SC6->(RecLock("SC6",.F.))
		SC6->C6_XNEGOC := ZZV->ZZV_STATUS
		SC6->(MsUnLock())
	EndIf

	oGridCo:aArray := GtContat(1) // retornar lista de ligacoes da negociacao
	oGridFu:aArray := GtContat(2) // retornar lista de ligacoes da negociacao

	oGridCo:Refresh()
	oGridFu:Refresh()

	oDlg3:End()

	LjMsgRun("Ok, gravado!")
EndIf

Return(.T.)
*
***************************
Static Function TrocaOfer()
***************************
*
Local aAl		:= aClone( oGridAl:aArray[oGridAl:nAt] )
Local cZZV_ID	:= oLstPd:aArray[oLstPd:nAt,PV_ZZVID]
Local lTransf	:= .F.
Local cDE		:= GETMV("MV_XLocalC") // Local DE PRODUTOS EM NEGOCIACAO
Local cPARA		:= "01" // Local DO RETORNO DA NEGOCIACAO
Local cPerg		:= PADR("REST161A1",10)
Local nVal		:= 0
Local nPermit	:= GETMV("MV_XLIMIT1")
Local aRet
Local nDiff
Local lConti	:= .F.

If __lAutor
	lConti := .T.
Else
	nDiff := GtPreco(aAl[AL_PRODU],ZZV->ZZV_PROALT,ZZV->ZZV_FILPV,ZZV->ZZV_PEDIDO) // Consultar diferenca de precos
	If nDiff > nPermit
		Alert("O preço para este produto ultrapassou o limite de '" + Alltrim(str(nPermit)) + "%' em '" + Alltrim(str(nDiff - nPermit)) + "%'! Solicite para um administrador Aprovar!")
		lConti := .F.
	Else
		lConti := .T.
	EndIf
EndIf

If lConti
	If MsgYesNo("Confirma a escolha deste produto pelo cliente?")
		ValidPerg(cPerg)
		If Pergunte(cPerg,.T.)
			nVal := MV_PAR01
			If nVal <= 0
				Alert("Valor inválido")
			Else
				If nVal % aAl[AL_METRA] > 0
					Alert("Valor precisa ser multiplo de: " + StrZero(aAl[AL_METRA],5,0) )
				Else
					If nVal > ( aAl[AL_METRA] * aAl[AL_LANCE] )
						Alert("Valor superior do que o estoque!")
					Else
						ZZV->(DbSeek(xFilial("ZZV") + cZZV_ID))
						// Inicio Roberto Oliveira 19/03/14
						//aRet := u_CRESTXT(.F.,ZZV->ZZV_PROALT,ZZV->ZZV_ACONAL + STRZERO(ZZV->ZZV_METRAL,5,0),ZZV->ZZV_ACONAL,cDE,cPara,ZZV->(ZZV_LANCEA * ZZV_METRAL), ZZV->ZZV_TPBOB, .F., ZZV->ZZV_NUMBOB) // TRANSFERIR O PRODUTO ALTERNATIVO PARA O ESTOQUE '01'
						aRet := u_CRESTXT(	.F.,ZZV->ZZV_PROALT,;
						PadR(ZZV->ZZV_ACONAL + STRZERO(ZZV->ZZV_METRAL,5,0),TamSX3("BE_LocalIZ")[1]),;
						ZZV->ZZV_ACONAL,cDE,cPara,ZZV->(ZZV_LANCEA * ZZV_METRAL), ZZV->ZZV_TPBOB, .F., ZZV->ZZV_NUMBOB) // TRANSFERIR O PRODUTO ALTERNATIVO PARA O ESTOQUE '01'
						// Fim Roberto Oliveira 19/03/14

						If aRet[1]         
							ZZV->(DbSeek(xFilial("ZZV") + cZZV_ID))
							ZZV->(RecLock("ZZV",.F.))
							ZZV->ZZV_Local := cPara
							ZZV->(MsUnLock())

							cPara := GETMV("MV_XLocalC") // Local DE PRODUTOS EM NEGOCIACAO


							// Inicio Roberto Oliveira 19/03/14
							//aRet := u_CRESTXT(.F.,aAl[AL_PRODU],aAl[AL_ACOND] + STRZERO(aAl[AL_METRA],5,0),aAl[AL_ACOND],aAL[AL_ALMOX],cPara,nVal, aAL[AL_TPBOB], .T., aAl[AL_BOBIN]) // TRANSFERIR O PRODUTO PARA NEGOCIAR
							aRet := u_CRESTXT(	.F.,;
							PadR(aAl[AL_PRODU],TamSX3("B1_COD")[1]),;
							PadR(aAl[AL_ACOND] + STRZERO(aAl[AL_METRA],5,0),TamSX3("BE_LocalIZ")[1]),;
							aAl[AL_ACOND],aAL[AL_ALMOX],cPara,nVal, aAL[AL_TPBOB], .T., aAl[AL_BOBIN]) // TRANSFERIR O PRODUTO PARA NEGOCIAR
							// Fim Roberto Oliveira 19/03/14

							If aRet[1] // TRANSFERIDO ????
								ZZV->(DbSeek(xFilial("ZZV") + cZZV_ID))
								ZZV->(RecLock("ZZV",.F.))
								ZZV->ZZV_PROALT	:= aAl[AL_PRODU]
								ZZV->ZZV_ACONAL	:= aAl[AL_ACOND]
								ZZV->ZZV_LANCEA	:= (nVal / aAl[AL_METRA])
								ZZV->ZZV_METRAL	:= aAl[AL_METRA]
								ZZV->ZZV_TPBOB	:= aAl[AL_TPBOB]
								ZZV->ZZV_Local := cPara
								ZZV->ZZV_NUMBOB := aAl[AL_BOBIN]
								ZZV->(MsUnLock())

								SetOfer() // atualizar a tela
							Else
								alert(aRet[2])


								// Inicio Roberto Oliveira 19/03/14
								//aRet := u_CRESTXT(.F.,ZZV->ZZV_PROALT,ZZV->ZZV_ACONAL + STRZERO(ZZV->ZZV_METRAL,5,0),ZZV->ZZV_ACONAL,"01",cPara,ZZV->(ZZV_LANCEA * ZZV_METRAL), ZZV->ZZV_TPBOB, .T., ZZV->ZZV_NUMBOB)	// ROLLBACK
								aRet := u_CRESTXT(	.F.,ZZV->ZZV_PROALT,;
								PadR(ZZV->ZZV_ACONAL + STRZERO(ZZV->ZZV_METRAL,5,0),TamSX3("BE_LocalIZ")[1]),;
								ZZV->ZZV_ACONAL,"01",cPara,ZZV->(ZZV_LANCEA * ZZV_METRAL), ZZV->ZZV_TPBOB, .T., ZZV->ZZV_NUMBOB)	// ROLLBACK
								// Fim Roberto Oliveira 19/03/14

								If aRet[1] == .F.
									Alert("Não foi possivel estornar a operação!")
								Else   
									ZZV->(DbSeek(xFilial("ZZV") + cZZV_ID))
									ZZV->(RecLock("ZZV",.F.))
									ZZV->ZZV_Local := cPara
									ZZV->(MsUnLock())
								EndIf
							EndIf
						Else
							alert(aRet[2])
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf
EndIf

Return(nil)
*
*******************************
Static Function Aceite(lAceite)
*******************************
*
Local cConAtual := Space(TamSX3("ZZW_NOMER")[1])
Local cObsAtual
Local cHora := space(5)
Local oBtCancel
Local oBtOk
Static oDlg3

DEFINE MSDIALOG oDlg3 TITLE "Negociação com Cliente" FROM 000, 000  TO 280, 500 COLORS 0, 16777215 PIXEL

@ 004, 004 SAY "Contato Com:" 				SIZE 038, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
@ 002, 039 GET cConAtual 					SIZE 205, 010 OF oDlg3 COLORS 0, 16777215 PIXEL
@ 015, 003 SAY "Detalhes da Negociação:" 	SIZE 060, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
@ 024, 003 GET cObsAtual MEMO 				SIZE 242, 094 OF oDlg3 COLORS 0, 16777215 PIXEL HSCROLL

DEFINE SBUTTON oBtCancel FROM 125 , 219 TYPE 02 OF oDlg3 ENABLE ACTION { || oDlg3:End() }
DEFINE SBUTTON oBtOk     FROM 125 , 189 TYPE 01 OF oDlg3 ENABLE ACTION { || MsgRun("Favor aguarde","Aguarde",{|| Aceitar(cObsAtual,cConAtual, lAceite)}) }

ACTIVATE MSDIALOG oDlg3 CENTERED

Return(.T.)
*
*****************************************************
Static Function Aceitar(cObsAtual,cConAtual, lAceite)
*****************************************************

Local lOk := .T.
Local cMsg
Local cZZV_ID := oLstPd:aArray[oLstPd:nAt,PV_ZZVID]
Local aPv := oLstPd:aArray[oLstPd:nAt]
Local cDE := GETMV("MV_XLocalC") // Local DE PRODUTOS EM NEGOCIACAO
Local cPARA := "01" // Local DO RETORNO DA NEGOCIACAO
Local aRet

Private _nNewPrV := 0.00 // Novo preço de venda, quando se tratar de produtos diferentes.

If !lAceite
	cMsg := "Confirma Recusa do Cliente da Negociação " + cZZV_ID + " ?"
EndIf                                    

If Empty(cObsAtual) .or. Empty(cConAtual) // Validar a tela
	Alert("Favor Preencher Todos os Campos")
	lOk := .F.
Else
	If !lAceite
		lOk := MsgYesNo(cMsg)
	Else
		lOk := .T.
	EndIf
EndIf

If lOk
	ZZV->(DbSetOrder(1))
	ZZV->(DbSeek(xFilial("ZZV") + cZZV_ID,.F.))
	_ChvSC6 := ZZV->(ZZV_PEDIDO + ZZV_ITEM)
	//lOk := .F.
	_Volta := .T.
	BeginTran() 

	If !lAceite
		// By Roberto Oliveira - 26/01/2015
		// Toda a rotina foi alterada para tratar os empenhos no próprio SDC
		aRet := u_EmpSDC(	.F.,"ZZV",ZZV->ZZV_PROALT,"01",;
		PadR(ZZV->ZZV_ACONAL + STRZERO(ZZV->ZZV_METRAL,5,0),TamSX3("BE_LocalIZ")[1]),;
		ZZV->(ZZV_LANCEA * ZZV_METRAL),ZZV->ZZV_ID,If(ZZV->ZZV_ACONAL=="B",ZZV->ZZV_NUMBOB,""),.F.)

		lOk := .T. // Aqui mesmo que EmpSDC retorne .F., continua o processamento
		//lOk := aRet[1]
		If !lOk
			Alert(aRet[2])
		EndIf
	Else
		// Verificar se os produtos são diferentes e solicitar o novo preço de venda, se for o caso.
		If Left(ZZV->ZZV_PROALT,5) # Left(ZZV->ZZV_PRODUT,5)
			_lCanc := .F.
			_nNewPrV := Posicione("SC6",1,xFilial("SC6")+ZZV->ZZV_PEDIDO+ZZV->ZZV_ITEM,"C6_PRCVEN")
			If Left(ZZV->ZZV_PROALT,3) # Left(ZZV->ZZV_PRODUT,3)
				_cTxtPrb := "Atenção: Esta negociação envolve Produtos diferentes:" + Chr(10) + Chr(13) + Chr(10) + Chr(13)
			Else
				_cTxtPrb := "Atenção: Esta negociação envolve Bitolas diferentes:" + Chr(10) + Chr(13) + Chr(10) + Chr(13)
			EndIf

			_cTxtPrb += "   Produto Solicitado:  " + AllTrim(ZZV->ZZV_PRODUT) + " - " + Left(u_CortaDesc(Posicione("SB1",1,xFilial("SB1")+ZZV->ZZV_PRODUT,"B1_DESC")),42) + Chr(10) + Chr(13) + ;
			            "   Produto Negociado :  " + AllTrim(ZZV->ZZV_PROALT) + " - " + Left(u_CortaDesc(Posicione("SB1",1,xFilial("SB1")+ZZV->ZZV_PROALT,"B1_DESC")),42) + Chr(10) + Chr(13) + ;
			            "   Quantidade Solicitada:  " + Transform((ZZV->ZZV_LANCES*ZZV->ZZV_METRAG), "@E 999,999.99") + Chr(10) + Chr(13) + ;
			            "   Quantidade Negociado :  " + Transform((ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL), "@E 999,999.99") + Chr(10) + Chr(13) + Chr(10) + Chr(13) + ;
			"   Vlr Unit. do Item :    R$ " + Transform(_nNewPrV,"@E 999,999.9999") + Chr(10) + Chr(13) + Chr(10) + Chr(13) + ;
			"   Informe o valor a ser considerado no novo item."

			DEFINE MSDIALOG oDlgX TITLE "Atenção" FROM 000, 000  TO 280, 500 COLORS 0, 16777215 PIXEL
			@ 004, 004 SAY "Novo Valor:" 				SIZE 038, 007 OF oDlgX COLORS 0, 16777215 PIXEL
			@ 002, 039 GET _nNewPrV Picture "@E 99,999.9999" Valid _nNewPrV>0	SIZE 60, 010 OF oDlgX COLORS 0, 16777215 PIXEL
			@ 015, 003 SAY "Atenção:" 	SIZE 060, 007 OF oDlgX COLORS 0, 16777215 PIXEL
			@ 024, 003 GET _cTxtPrb MEMO 				SIZE 242, 094 OF oDlgX COLORS 0, 16777215 PIXEL HSCROLL
			DEFINE SBUTTON oBtCancel FROM 125 , 219 TYPE 02 OF oDlgX ENABLE ACTION { || _lCanc:=.T.,oDlgX:End() }
			DEFINE SBUTTON oBtOk     FROM 125 , 189 TYPE 01 OF oDlgX ENABLE ACTION { || oDlgX:End()}
			ACTIVATE MSDIALOG oDlgX CENTERED
			If _lCanc
				lOk := .F.
				_Volta := .F.
			EndIf
		EndIf
	EndIf

	If lOk            
		DbSelectArea("ZZW")
		RecLock("ZZW",.T.) // GRAVAR CONTATO ATUAL
		ZZW->ZZW_FILIAL := xFILIAL("ZZW")
		ZZW->ZZW_ZZVID := cZZV_ID
		ZZW->ZZW_DATAR := dDatabase
		ZZW->ZZW_HORAR := substr(Time(),1,5)
		ZZW->ZZW_NOMER := cConAtual
		ZZW->ZZW_OBSR := cObsAtual
		ZZW->(MsUnLock())

		DbSelectArea("ZZV")
		RecLock("ZZV",.F.)
		ZZV->ZZV_DTENCE := dDatabase
		ZZV->ZZV_STATUS := If(lAceite,"4","6") // APROVADO PELO CLIENTE / REJEITADO
		ZZV->ZZV_ACEITE := If(lAceite,"S","N")
		If !lAceite
			ZZV->ZZV_Local	:= cPara
		EndIf
		ZZV->(MsUnLock())

		// Verificar se tem alguma outra negociação para esse item
		_ZZV_PEDIDO := ZZV->ZZV_PEDIDO+ZZV->ZZV_ITEM
		_ZZV_ID     := ""
		_ZZV_STATUS := "X" // Começo com X

		// Verificar se tem outra negociação em aberto para atualizar o SC6
		_aAreaZZV := ZZV->(GetArea())
		ZZV->(DbSetOrder(6)) // ZZV_FILIAL+ZZV_FILPV+ZZV_PEDIDO+ZZV_ITEM
		DbSeek(xFilial("ZZV")+xFilial("ZZV")+_ZZV_PEDIDO,.F.) // Não entendi o ZZV_FILPV
		Do While ZZV->ZZV_FILIAL == xFilial("ZZV") .And. ZZV->ZZV_FILPV == xFilial("ZZV") .And.;
		         ZZV->(ZZV_PEDIDO+ZZV_ITEM) == _ZZV_PEDIDO .And. ZZV->(!Eof())
			If ZZV->ZZV_STATUS < _ZZV_STATUS
				_ZZV_ID     := ZZV->ZZV_ID
				_ZZV_STATUS := ZZV->ZZV_STATUS
			EndIf
			ZZV->(DbSkip())
		EndDo

		RestArea(_aAreaZZV)

		If SC6->(DbSeek(ZZV->(ZZV_FILPV + ZZV_PEDIDO + ZZV_ITEM))) // ATUALIZAR A NEGOCIACAO DO ITEM DO PEDIDO DE VENDA
			SC6->(RecLock("SC6",.F.))
			SC6->C6_XNEGOC := ZZV->ZZV_STATUS
			If !lAceite
				// SC6->C6_XQTDNEG -= ZZV->ZZV_LANCEA  // By Roberto Oliveira 26/01/2015
				SC6->C6_XQTDNEG -= ZZV->ZZV_LANCES  // By Roberto Oliveira 26/01/2015
				SC6->C6_XQTDNEG := Max(SC6->C6_XQTDNEG,0)
				If !"DRC" $ SC6->C6_SEMANA //By Roberto Oliveira 12/01/15
					/*/If !Empty(_ZZV_ID) .And. SC6->C6_XQTDNEG > 0 .And. SC6->C6_XQTDNEG == SC6->C6_QTDVEN // Roberto/Juliana 
						By Roberto Oliveria - 09/05/17 - Achei este erro e falei com a Juliana... C6_XQTDNED é quant. de LANCES e 
						C6_QTDVEN quantidade em metros. Estou alterando no If abaixo.
					/*/
					If !Empty(_ZZV_ID) .And. SC6->C6_XQTDNEG > 0 .And. SC6->C6_XQTDNEG == SC6->C6_LANCES // Roberto/Juliana 
						SC6->C6_XNEGOC := _ZZV_STATUS
						SC6->C6_SEMANA := "N"+_ZZV_ID
					ElseIf SC6->C6_XQTDRET <= 0 .And. SC6->C6_XQTDNEG <= 0
						SC6->C6_XQTDRET := 0
						SC6->C6_XQTDNEG := 0
						SC6->C6_QTDRES  := 0
						SC6->C6_SEMANA := " "
					EndIf
				EndIf
			EndIf
			SC6->(MsUnLock())
		EndIf

		If lAceite
			_Volta := u_CREST16b(.T.,_nNewPrv) // tentar aprovar com usuario logado e transferir do 14 para 01
		EndIf       
		oDlg3:End()
		oDlg1:End()
	EndIf

	If _Volta
		// Verifica se tem que corrigir o SZ9
		SC6->(DbSetOrder(1))
		SC6->(DbSeek(xFilial("SC6") + _ChvSC6,.F.))
		u_GraveSZ9(If(lAceite,"C","N"))
		EndTran()
	Else			
		DisarmTransaction()
	EndIf
EndIf

Return(.T.)
*
**********************************
Static Function ValidPerg( cPerg )
**********************************
*
Local _aArea := GetArea()

DbSelectArea("SX1")
DbSetOrder(1)
cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

aRegs:={}
//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Valor Total Negociado","mv_ch1","N",5,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})

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
		MsUnLock()
		DbCommit()
	EndIf
Next

RestArea(_aArea)

Return(.T.)
*
*******************************************************
Static Function GtPreco(cAL_PRODU,cProd,cFILPV,cPEDIDO) // consultar diferenca de precos
*******************************************************
*
Local nPrecoOri	:= 0
Local nPrecoAlt	:= 0
Local nDiff		:= 0

DA1->(DbSetOrder(1))
SC5->(DbSetOrder(1))
SC5->(DbSeek(cFilPv + cPedido))

If DA1->(DbSeek(XFILIAL("DA1") + SC5->C5_TABELA + cProd))
	nPrecoOri := DA1->DA1_PRCVEN
EndIf
If DA1->(DbSeek(XFILIAL("DA1") + SC5->C5_TABELA + cAL_PRODU))
	nPrecoAlt := DA1->DA1_PRCVEN
EndIf
nDiff := Round((((nPrecoOri / nPrecoAlt) * 100) - 100),2)
If nDiff < 0
	nDiff *= -1
EndIf
Return(nDiff)