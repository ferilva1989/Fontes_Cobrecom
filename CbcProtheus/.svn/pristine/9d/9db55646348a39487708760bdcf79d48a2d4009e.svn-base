#include "rwmake.ch"
#include 'protheus.ch'
#include 'topconn.ch'

// Robert Santos
// 27/09/2013
// Abrir tela para separar produtos
user function CRESTR3a()

local aPed := {}

Private aSize := MsAdvSize( .T. , SetMDIChild() )

Private oOk		:= LoadBitmap( GetResources(), "LBOK")
Private oNo		:= LoadBitmap( GetResources(), "LBNO")

private IND_PEDI := 01 // CONSTANTES OINDICE
private IND_CLIE := 02
private IND_PROD := 03
private IND_ENTR := 04
private IND_ACON := 05

private PV_MARCA := 01
private PV_IDPED := 02
private PV_PEDID := 03
private PV_ITEM  := 04
private PV_PRODU := 05
private PV_CLIEN := 06
private PV_ACOND := 07
private PV_NUMBO := 08
private PV_METRA := 09
private PV_LANCE := 10
private PV_TOTAL := 11
private PV_ENTRE := 12
private PV_NZZF  := 13
private PV_ID	 := 14
private oIndice	 := nil
private cCombo	 := ''
static oSeparar := nil

SelDados(@aPed)
if( !empty(aPed) )
	DEFINE MSDIALOG oSeparar TITLE "SEPARAR PRODUTOS" FROM aSize[7], 0 TO aSize[6], aSize[5] OF oMainWnd PIXEL
	oSeparar:lMaximized := .T.
	
	@ 005 , 005 SAY oSay1 PROMPT "Ordenar por: " SIZE 50, 7 OF oSeparar Pixel
	@ 005 , 040 COMBOBOX oIndice Var cCombo ITEMS { "Pedido" , "Cliente" , "Produto" , "Data Entrega", "Acondicionamento", "I.D. + Pedido" } Size 60,10 of oSeparar pixel
	oIndice:bChange := {|| ChCbPV1() }
	
	@ 005 , 110 BUTTON oButton1 PROMPT "Marcar Tudo" SIZE 037, 010 OF oSeparar Action {|| MarcarTudo(.T.) } PIXEL
	@ 005 , 150 BUTTON oButton2 PROMPT "Limpar"      SIZE 037, 010 OF oSeparar Action {|| MarcarTudo(.F.) } PIXEL
	@ 005 , 190 BUTTON oButton3 PROMPT "Separar"     SIZE 037, 010 OF oSeparar Action {|| Separar() }       PIXEL
	@ 005 , 230 BUTTON oButton4 PROMPT "Fechar"      SIZE 037, 010 OF oSeparar Action {|| oSeparar:End() }  PIXEL
	
	@ 018 , 005 LISTBOX oLstPd FIELDS HEADER "", "ID Retr.", "Pedido","Item", "Produto", "Nome Cliente", "Acondic.", "Bobina", "Metragem", "Lance", "Total", "Dt.Entrega","ZZF","Seq" SIZE 800 , 400  OF oSeparar PIXEL
	oLstPd:NHEIGHT := oLstPd:NHEIGHT := oSeparar:OWND:NHEIGHT - 70
	oLstPd:Nwidth  := oLstPd:Nwidth  := oSeparar:OWND:NWIDTH - 20
	
	ResetAPED(@aPed)
	oLstPd:SetArray( aPed )
	
	oLstPd:blDblClick := {|| MarcarPedido() }
	
	oLstPd:bLine := {|| {;
	iif(oLstPd:aArray[oLstPd:nAt,1],oOk,oNo),;
	oLstPd:aArray[oLstPd:nAt,02],;
	oLstPd:aArray[oLstPd:nAt,03],;
	oLstPd:aArray[oLstPd:nAt,04],;
	oLstPd:aArray[oLstPd:nAt,05],;
	oLstPd:aArray[oLstPd:nAt,06],;
	oLstPd:aArray[oLstPd:nAt,07],;
	oLstPd:aArray[oLstPd:nAt,08],;
	oLstPd:aArray[oLstPd:nAt,09],;
	oLstPd:aArray[oLstPd:nAt,10],;
	oLstPd:aArray[oLstPd:nAt,11],;
	oLstPd:aArray[oLstPd:nAt,12],;
	oLstPd:aArray[oLstPd:nAt,13],;
	oLstPd:aArray[oLstPd:nAt,14];
	}}
	
	ACTIVATE MSDIALOG oSeparar CENTERED
endif

return nil


static function MarcarPedido() // DUPLO CLIQUE

local aPd := oLstPd:aArray[oLstPd:nAt]

if( aPd[PV_TOTAL] > 0 )
	aPd[PV_MARCA] := iif(aPd[PV_MARCA],.F.,.T.)
else
	aPd[PV_MARCA] := .F.
endif
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
		oLstPd:aArray := aSort( oLstPd:aArray , , , { |x,y| x[PV_PEDID]+x[PV_ITEM] <= y[PV_PEDID]+y[PV_ITEM] } ) // ordenar por pedido
	case oIndice:nAt == 2
		oLstPd:aArray := aSort( oLstPd:aArray, , , { |x,y| x[PV_CLIEN] >= y[PV_CLIEN] } )// ordenar por cliente
	case oIndice:nAt == 3
		oLstPd:aArray := aSort( oLstPd:aArray, , , { |x,y| x[PV_PRODU] >= y[PV_PRODU] } )	// ordenar por produto
	case oIndice:nAt == 4
		oLstPd:aArray := aSort( oLstPd:aArray, , , { |x,y| (x[PV_ENTRE]) <= (y[PV_ENTRE]) } )// ordenar por data
	case oIndice:nAt == 5
		oLstPd:aArray := aSort( oLstPd:aArray, , , { |x,y| (x[PV_ACOND]) <= (y[PV_ACOND]) } )// ordenar por data
	case oIndice:nAt == 6
		oLstPd:aArray := aSort( oLstPd:aArray, , , { |x,y| (x[PV_IDPED]+x[PV_PEDID]+x[PV_ITEM]) <= (y[PV_IDPED]+y[PV_PEDID]+y[PV_ITEM]) } )// ordenar ID + pedido + item
endcase
oLstPd:Refresh()

return


Static Function SelDados(aPed)
local cqry, nqry
local cZZFID := ""
local lPrimVez := .t.
local nCount

cqry := " SELECT ZZF.R_E_C_N_O_ nZZF " + CRLF
cqry += " FROM "+RetSqlName("ZZF")+" ZZF " + CRLF
cqry += " WHERE " + CRLF
cqry += " ZZF_FILIAL =  '"+xFilial("ZZF")+"'  AND " + CRLF
cqry += " ZZF_ID =  ''  AND " + CRLF
cqry += " ZZF_STATUS NOT IN ('A','X','Y')  AND " + CRLF
cqry += " ZZF.D_E_L_E_T_ = ' ' " + CRLF

iif( select("ZZFX") > 0, ZZFX->(dbclosearea()),  )

tcquery cqry new alias "ZZFX"
count to nqry
if nqry > 0
	dbselectarea("ZZF")
	
	SC6->(dbsetorder(1))
	SA1->(dbsetorder(1))
	SB1->(dbsetorder(1))
	
	ZZFX->(DbGoTop())
	nCount := 0
	while !ZZFX->(eof())
		ZZF->(dbgoto(ZZFX->(NZZF)))
		SC6->(dbseek(ZZF->(ZZF_FILPV + ZZF_PEDIDO + ZZF_ITEMPV + ZZF_PRODUT )))
		SA1->(dbseek(xFilial("SA1") + SC6->(C6_CLI + C6_LOJA )))
		// By Roberto Oliveira 04/12/15
		// Se não tiver pedido no ZZF, não acha o produto pelo SC6.
		//SB1->(dbseek(xFilial("SB1") + SC6->C6_PRODUTO ))
		SB1->(dbseek(xFilial("SB1") + ZZF->ZZF_PRODUT ))
		nCount ++
		
		aAdd(aPed,{.T.,ZZF->ZZF_ZZEID,ZZF->ZZF_PEDIDO,ZZF->ZZF_ITEMPV,SB1->B1_DESC,SA1->A1_NOME,u_TRACEXT(ZZF->ZZF_ACONDS),IIF(ZZF->ZZF_ACONDS=="B",ZZF->ZZF_NUMBOB,""),ZZF->ZZF_METRAS,ZZF->ZZF_LANCES,ZZF->(ZZF_LANCES*ZZF_METRAS),SC6->C6_ENTREG,ZZFX->NZZF,nCount})
		ZZFX->( DBSKIP() )
	enddo
	aPed := aSort( aPed, , , { |x,y| (x[PV_ENTRE]) <= (y[PV_ENTRE]) } )// ordenar por data
else
	Alert("Não existem registros para gerar Ordem de Separação")
endif

return


static function Separar()

local cZZFID := ""
local aPv := oLstPd:aArray
local i,j
local aLPv := {}
local lClose := .F.

If !MsgBox("Deseja Iniciar a Separação do Retrabalho?","Confirma?","YesNo")
	Return(.F.)
EndIf

dbselectarea("ZZF")

for i := 1 to len(aPv)
	if(aPv[i,PV_MARCA]) // está marcado ?
		if (empty(cZZFID))
			cZZFID := GetSXENum("ZZF","ZZF_ID")
			ConfirmSX8()
		endif
		
		ZZF->( DBGOTO( aPv[i,PV_NZZF]) )
		reclock("ZZF", .F.)
		ZZF->ZZF_ID     := cZZFID
		ZZF->ZZF_STATUS := "3"
		ZZF->ZZF_RESPON := cUserName
		ZZF->ZZF_DTSEPA := dDatabase
		ZZF->( msunlock() )
		
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

LjMsgRun( "Processado!" )

return nil

static function ResetAPED(aPed)

if empty(aPed)
	aadd( aPed , {;
	.f.,;
	"",;
	"",;
	"",;
	"",;
	"",;
	"",;
	"",;
	0,;
	0,;
	0,;
	ctod("//"),;
	0,;
	0;
	} )
endif

return