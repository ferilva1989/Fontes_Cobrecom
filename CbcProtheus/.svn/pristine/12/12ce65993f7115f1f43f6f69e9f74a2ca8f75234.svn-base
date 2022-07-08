#include 'protheus.ch'
#include 'topconn.ch'

/*
BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³GERA SEPARACAO                 AIRTON ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC    CRESTR3a CRESTR3
*/

User Function CRESTR3()
local cFiltro := "ZZF_STATUS <> 'A'"
local aIndex  := {}

Local aCores := {}
local cAlias := "ZZF"

Private cCadastro 	:= "SELECIONA ITENS PARA SEPARAÇÃO"
Private bFiltraBrw := { || FilBrowse( cAlias , @aIndex , @cFiltro ) }
private cZZEID := ""

Private aRotina 	:= { 	{"Pesquisar" 		   ,"AxPesqui"	,0,1} ,;
							{"Visualizar"		   ,"AxVisual"	,0,2} ,;
							{"Legenda"	 		   ,"U_EstR3Lg"	,0,2} ,;
							{"Visualiza Retrabalho","U_VisRetr"	,0,2} ,;
							{"Gera Separação"	   ,"u_CRESTR3a",0,2} ,; // U_EstR301
							{"Imprimir Separação"  ,"u_CRESTR5X",0,2} ,;
							{"Imprimir Etiqueta"   ,"u_CRESTET1",0,2} ,;
							{"Baixa O.Separ."	   ,"U_crestr7a",0,2} ,; // U_BAIXAOS
							{"Cancelar"			   ,"U_crestr7b",0,2} }

Private oOk			:= LoadBitmap( GetResources(), "LBOK" )
Private oNo			:= LoadBitmap( GetResources(), "LBNO" )
Private cTitulo		:= "SELECIONA ITENS PARA SEPARAÇÃO"
private oDlg
private aDados      := {}
private cVarSep

AADD(ACORES,{ "ZZF_STATUS == '2'", "BR_AMARELO"	}) // AGUARDANDO SEPARAR
AADD(ACORES,{ "ZZF_STATUS == 'A'", "BR_MARROM"	}) // DIRETO FATURAMENTO
AADD(ACORES,{ "ZZF_STATUS == '3'", "BR_AZUL"	}) // ORDEM NAO IMPRESSA
AADD(ACORES,{ "ZZF_STATUS == '4'", "BR_PINK"	}) // ORDEM IMPRESSA
AADD(ACORES,{ "ZZF_STATUS == '5'", "BR_LARANJA"	}) // ORDEM PARCIAL
AADD(ACORES,{ "ZZF_STATUS == '6'", "BR_VIOLETA"}) // ORDEM SEPARADA TOTAL BAIXADA
// AADD(ACORES,{ "ZZF_STATUS == '7'", "BR_BRANCO"	}) // ORDEM RETRABALHO IMPRESSO
AADD(ACORES,{ "ZZF_STATUS == '8'", "BR_CINZA"	}) // ORDEM RETRABALHO PARCIAL
AADD(ACORES,{ "ZZF_STATUS == '9'", "BR_PRETO"	}) // ORDEM RETRABALHO TOTAL
AADD(ACORES,{ "ZZF_STATUS == 'X'", "BR_VERMELHO"	}) // CANCELADO
AADD(ACORES,{ "ZZF_STATUS == 'Y'", "BR_VERDE"	}) // RETRABALHO CANCELADO - FALTA CANCELAR SEPARACAO

LjMsgRun("Irá mostrar tela....aguarde")

Eval( bFiltraBrw )
mBrowse( 6,1,22,75,cAlias,,,,,,aCores)
EndFilBrw( cAlias , @aIndex )

Return Nil


/* legenda SEPARACAO */
User Function EstR3Lg(cAlias,nReg,nOpc)

Local aLegenda	:= {}

AADD(aLegenda, {"BR_AMARELO"	,	"Aguarda separ. retrab"		})
AADD(aLegenda, {"BR_MARROM"  	,	"Destino Faturam."})
AADD(aLegenda, {"BR_VERMELHO"   ,	"Ordem Separ. Cancelada"})
AADD(aLegenda, {"BR_AZUL"  	,	"Ordem Separ. nao Impr"})
AADD(aLegenda, {"BR_PINK" 	,	"Ordem Separ. Impressa"})
AADD(aLegenda, {"BR_LARANJA" 	,	"Ordem Separada Parcial"})
AADD(aLegenda, {"BR_VIOLETA" ,	"Ordem Separada Total"})
// AADD(aLegenda, {"BR_BRANCO"   ,	"Ordem Retrab. Impressa"})
AADD(aLegenda, {"BR_CINZA"   ,	"Ordem Retrab. Parcial"})
AADD(aLegenda, {"BR_PRETO"   ,	"Ordem Retrab. Total"})
AADD(aLegenda, {"BR_VERDE"   ,	"Retrabalho cancelado- Cancelar Separacao"})


BrwLegenda("Separação", "Legenda" , aLegenda)

Return .T.


/* Abrir tela para separar material de retrabalho */
user function EstR301(calias,nreg,nopc)

if !msgyesno("Confirma a geração de Ordens de Separação ? ")
	return
endif

MsgRun("Favor aguarde..selecionando dados", "SELECIONA ITENS PARA SEPARACAO", {|| SelecR3( @aDados) } )

return



/*
BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Atualiza ZZF com os registros marcados para separar³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC
*/
Static Function AtuZZF()

local i
local aMarcados	:= aClone( oGridSep:aArray )
local cZZFID := GetSXENum("ZZF","ZZF_ID")
//
// separar itens para processar

for i:=1 to len(aMarcados)
	if aMarcados[i,1] // apenas marcados
		// atualiza ZZF com registros marcados
		dbselectarea("ZZF")
		dbsetorder(2) //filial+ZZEID
		if ZZF->( dbseek( xFilial("ZZF")+aMarcados[i,2] ) )
			reclock("ZZF", .F.)
			
			ZZF->ZZF_ID     := cZZFID
			ZZF->ZZF_STATUS := "3"
			ZZF->ZZF_RESPON := cUserName
			ZZF->ZZF_DTSEPA := dDatabase
			
			ZZF->( msunlock() )
			ConfirmSX8()
		else
			alert( "registro nao encontrado ZZF: "+ xFilial("ZZF")+ " "+aMarcados[i,2] )
		endif
		
	endif
next


/*
BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Seleciona dados por query³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC
*/
Static Function SelecR3(aDados)
local cqry, nqry
local cZZFID := ""
local lPrimVez := .t.

cqry :=  " SELECT * "+;
" FROM "+RetSqlName("ZZF")+" ZZF " +;
" INNER JOIN "+RetSqlName("ZZE") + " ZZE " +;
" ON ZZE.ZZE_ID = ZZF.ZZF_ZZEID " +;
" WHERE "+;
" ZZF_FILIAL =  '"+xFilial("ZZF")+"'  AND "+;
" ZZF.ZZF_ID = '' AND "+;
" ZZF.ZZF_TIPO = 'R' AND "+;
" ZZE.D_E_L_E_T_ <> '*' AND ZZF.D_E_L_E_T_ <> '*'"+;
" ORDER BY ZZE.ZZE_PRODUT"


iif( select("ZZFX") > 0, ZZFX->(dbclosearea()),  )

tcquery cqry new alias "ZZFX"
count to nqry
if nqry > 0
	ZZFX->(DbGoTop())
	while !ZZFX->(eof())
		
		if lPrimVez
			lPrimvez := .f.
			cChave := ZZFX->ZZE_PRODUT   // GUARDA CHAVE
			cZZFID := GetSXENum("ZZF","ZZF_ID")   // PEGA NUMERO ID SEPARACAO
			ConfirmSX8()
			alert("Id. Separação gerado = "+cZZFID+"  Produto: "+ZZFX->ZZE_PRODUT )
			
		endif
		
		if cChave #  ZZFX->ZZE_PRODUT
			cZZFID := GetSXENum("ZZF","ZZF_ID")   // PEGA NUMERO ID SEPARACAO
			ConfirmSX8()
			alert("Id. Separação gerado = "+cZZFID+"  Produto: "+ZZFX->ZZE_PRODUT )
			cChave := ZZFX->ZZE_PRODUT   // GUARDA CHAVE
		endif
		
		// atualiza ZZF com registros marcados
		dbselectarea("ZZF")
		dbsetorder(2) //filial+ZZEID
		
		if ZZF->( dbseek( xFilial("ZZF")+ZZFX->ZZF_ZZEID ) )
			reclock("ZZF", .F.)
			
			ZZF->ZZF_ID     := cZZFID
			ZZF->ZZF_STATUS := "3"
			ZZF->ZZF_RESPON := cUserName
			ZZF->ZZF_DTSEPA := dDatabase
			
			ZZF->( msunlock() )
			
		else
			alert( "registro nao encontrado ZZF: "+ xFilial("ZZF")+ " "+ZZFX->ZZF_ZZEID )
		endif
		
		ZZFX->( DBSKIP() )
	enddo
	
else
	alert("Não existem registros para gerar Ordem de Separação")
endif

return

/*
BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ(¿
// Mostra produtos já separados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ(Ù
ENDDOC
*/
User Function VisRetr()

local cFiltro := "ZZE->ZZE_ID == '" + ZZF->ZZF_ZZEID + "'"
local aIndex  := {}
Local aCores := {}
local cAlias := "ZZE"

Private cCadastro 	:= "RETRABALHOS A SEREM EFETUADOS"
Private bFiltraBrw := { || FilBrowse( "ZZE" , @aIndex , @cFiltro ) }

Private aRotina 	:= { {"Pesquisar" 			,"AxPesqui"		,0,1} ,;
{"Visualizar"			,"AxVisual"		,0,2}  }


Private oOk			:= LoadBitmap( GetResources(), "LBOK" )
Private oNo			:= LoadBitmap( GetResources(), "LBNO" )
Private cTitulo		:= "RETRABALHOS A SEREM EFETUADOS"
private oDlg

PRIVATE oDtRec
private dDtRec := ddatabase
private oResp
private cResp := space(50)
private oHrRec
private cHrRec := substr(time(),1,5)

AADD(ACORES,{"ZZE_STATUS == '1'","BR_VERMELHO"}) // AGUARD. SEPARAR
AADD(ACORES,{"ZZE_STATUS == '2'","BR_AZUL"}) // AGUARD. ORDEM DE SERVICO
AADD(ACORES,{"ZZE_STATUS == '3'","BR_AMARELO"}) // EM RETRABALHO ..
AADD(ACORES,{"ZZE_STATUS == '4'","BR_VERDE"}) // FINALIZADO REALIZADO -> Alterei o Status 4 de FINALIZADO para REALIZADO pq a finalização será por outro campo
AADD(ACORES,{"ZZE_STATUS == '9'","BR_MARRON"}) // CANCELADO
AADD(ACORES,{"ZZE_STATUS == 'A'","BR_VIOLETA"}) // RETORNO NÃO PLANEJADO PARA ESTOQUE
AADD(ACORES,{"ZZE_STATUS == 'B'","BR_CINZA"}) // FINALIZADO SEM ATENDER TODO O PEDIDO

LjMsgRun("Irá mostrar tela....aguarde")

Eval( bFiltraBrw )
DbSelectArea(cAlias)
DbSeek(xFilial(cAlias),.F.)
mBrowse(6,1,22,75,cAlias,,,,,,aCores)
EndFilBrw( "ZZE" , @aIndex )

Return Nil
