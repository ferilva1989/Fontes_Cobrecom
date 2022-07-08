#include 'totvs.ch'
#include 'topconn.ch'

/*
Robert Santos
Gerenciar Orçamentos WEB
05.08.2013
*/
user function XRot0002()

Local aCores := {;
{ "ZZJ_STATUS=='A'"	, "BR_VERDE"	},;
{ "ZZJ_STATUS=='R'"	, "BR_AZUL"		},;
{ "ZZJ_STATUS=='B'"	, "BR_CINZA"	},;
{ "ZZJ_STATUS=='F'"	, "BR_VERMELHO"	} }

local cAlias := "ZZJ"

Private cCadastro 	:= "Orçamentos Web"

Private aRotina 	:= {;
{"Pesquisar" 			,"AxPesqui"		,0,1} ,;
{"Visualizar"			,"U_xRot02a"	,0,2} ,;
{"Gerar Orçamento"		,"U_xRot02b"	,0,2} ,;
{"Alterar"	 			,"U_xRot02a"	,0,4} ,;
{"Legenda"	 			,"U_xRot02c"	,0,2} }  

DBSELECTAREA("ZZK")

mBrowse( 6,1,22,75,cAlias,,,,,,aCores)

Return Nil


/* Legenda */
User Function xRot02c(cAlias,nReg,nOpc)

Local aLegenda	:= {;
{"BR_VERDE"		,	"Aprovado" 	   			},;
{"BR_AZUL"		,	"Reprovado"				},;
{"BR_CINZA"		,	"Bloqueado"				},;
{"BR_VERMELHO"	,	"Falta enviar ERP"		}}

BrwLegenda("Separação", "Legenda" , aLegenda)

Return .T.


/* visualizar / alterar .. */
User function xRot02a(cAlias, nReg, nopc)

local aButtons := {}  

if !EMPTY(ZZJ_CJNUM) .and. nOpc >= 3
	Alert("Já possui orçamento gerado!")
else
	aAdd(aButtons,{"POSCLI"  , {|| u_xRot02d(nOpc) } ,"Itens de venda","Itens de venda"})
	
	if nOpc == 2
		AxVisual( cAlias, nReg , nOpc, , , , , aButtons , .t. )
	else
		AxAltera( cAlias, nReg, nOpc, , , , , , , , aButtons, , , , .t.)
	endif
endif

return nil

/* processar .. */
User function xRot02b(cAlias, nReg, nopc)

local aButtons := {} 
local aRet, nOpc

if !EMPTY(ZZJ_STATUS!="F")
	Alert("Só pode enviar com status de Falta enviar ERP!")
else
	LjMsgRun("Favor aguarde ..")
	if EMPTY(ZZJ->ZZJ_CJNUM) 
		nOpc := 3
	else         
		nOpc := 4
	endif
	aRet := u_xrot0003(ZZJ->ZZJ_ID, nOpc )   
	Alert(aRet[2])
endif

return nil


/* Mostrar cadastro de produtos */
user function xRot02d(nOpc)

Tela(1, nOpc)

return

static function Tela(nMod, nOpc)

Local oG1
Local oGroup1
Local oSButton1
Local oSButton2
local aData := {}

Static oDEpFat6 := nil

GetData(@aData, nMod)
if len(aData)>0
	DEFINE MSDIALOG oDEPFAT7 TITLE "" FROM 000, 000  TO 450, 750 COLORS 0, 16777215 PIXEL
	
	@ 003, 002 GROUP oG1 TO 208, 371 PROMPT "" OF oDEPFAT7 COLOR 0, 16777215 PIXEL
	DEFINE SBUTTON oSButton1 FROM 210, 312 TYPE 02 OF oDEPFAT7 ENABLE ACTION oDEPFAT7:End()
	DEFINE SBUTTON oSButton2 FROM 210, 344 TYPE 14 OF oDEPFAT7 ENABLE ACTION { || Abrir(nMod, nOpc) }
	
	@ 120, 005 GROUP oGroup1 TO 204, 368 PROMPT "" OF oDEPFAT7 COLOR 0, 16777215 PIXEL
	fWBrowse1(aData)
	
	ACTIVATE MSDIALOG oDEPFAT7 CENTERED
else
	MsgInfo("Sem valores informados!")
endif

return nil


Static Function fWBrowse1(aData)

local aLog := {}
local oGroup1, i

static oWLog := nil

@ 013 , 005 LISTBOX oWLog FIELDS HEADER ;
"Item", "Produto", "Descricao", "Valor", "RECNO" ;
SIZE 363,105 OF oDEPFAT7 PIXEL

for i:=1 to len(aData)
	aadd( aLog , {;
	aData[i,1] ,;
	aData[i,2] ,;
	aData[i,3] ,;
	aData[i,4] ,;
	aData[i,5] } )
next

//
oWLog:SetArray( aLog )

//
oWLog:bLine := {|| { ;
oWLog:aArray[oWLog:nAt,1],;
oWLog:aArray[oWLog:nAt,2],;
oWLog:aArray[oWLog:nAt,3],;
oWLog:aArray[oWLog:nAt,4],;
oWLog:aArray[oWLog:nAt,5] }}

Return


static function Abrir(nMod, nOpc)

private cCadastro := ""

do case
	case nMod == 1
		ZZK->(dbgoto(oWLog:aArray[oWLog:nAt,5]))
		if nOpc == 2
			AxVisual( "ZZK", ZZK->(RECNO()) , nOpc, , , , , , .t. )
		else
			AxAltera( "ZZK", ZZK->(RECNO()) , nOpc, , , , , , , , , , , , .t.)
		endif
endcase

return



static function GetData(aData,nMod)

local cQry, nQry, cDesc
local cItem := "000"

dbselectarea("ZZK")

dbselectarea("SB1")
SB1->(dbsetorder(1))

do case
	case nMod == 1 // itens de venda
		cQry := "SELECT R_E_C_N_O_ NZZK FROM "+RETSQLNAME("ZZK")+" WHERE D_E_L_E_T_ = ' ' and ZZK_ID = '"+alltrim((ZZJ->ZZJ_ID))+"' "
		if select("EPFAT7")>0
			EPFAT7->(dbclosearea())
		endif
		TcQuery cQry new Alias "EPFAT7"
		count to nQry
		if nQry > 0
			EPFAT7->(dbgotop())
			while !EPFAT7->(eof())
				ZZK->(dbgoto(EPFAT7->(NZZK)))
				cItem := soma1(cItem)
				
				if SB1->(dbseek(xFilial("SB1")+ZZK->ZZK_COD))
					cDesc := alltrim(SB1->B1_DESC)
				else
					cDesc := ""
				endif
				aadd(aData, {;
				cItem,;
				ZZK->ZZK_COD,;
				cDesc,;
				ZZK->ZZK_PRCVEN,;
				ZZK->(recno()) } )
				
				EPFAT7->(dbskip())
			enddo
		endif
		EPFAT7->(dbclosearea())
endcase

return
