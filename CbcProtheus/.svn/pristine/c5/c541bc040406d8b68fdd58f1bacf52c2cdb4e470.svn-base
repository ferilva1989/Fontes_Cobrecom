#include 'protheus.ch'
#include 'topconn.ch'

//TELA DO RETRABALHO
User Function CRESTR8()

Local aIndex  := {}

Local aCores := {}
Local cAlias := "ZZE"

Private cCadastro 	:= "IMPRIME ORDEM DE RETRABALHO"
Private aRotina 	:= {	{"Pesquisar" 		    ,"AxPesqui"  ,0,1} ,;
							{"Visualizar"		    ,"AxVisual"  ,0,2} ,;
							{"Legenda"	 			,"U_EstR8Lg" ,0,6} ,;
							{"Gerar Ord.Servico"	,"u_crest13" ,0,5} ,;
							{"Imprimir Ord.Servico","U_CRESTR8A",0,6} ,;
							{"Cancelar Retrabalho"	,"U_CREST21" ,0,6} ,;
							{"Encerrar Retr.Autom.","U_CRESTR8C",0,6} ,;
							{"Encerrar Retr.Manual","U_CRESTR8B",0,6} }
// {"Baixa Retrabalho"	 	                               		,"U_CREST20"   ,0,6} ,;


Private oOk			:= LoadBitmap( GetResources(), "LBOK" )
Private oNo			:= LoadBitmap( GetResources(), "LBNO" )
Private cTitulo		:= "GERENCIAMENTO RETRABALHO"
Private oDlg
Private aDados      := {}
Private cVarSep

AADD(ACORES,{"ZZE_SITUAC == '1'","BR_VERDE"}) 	// Encerrado
AADD(ACORES,{"ZZE_STATUS == '1'","BR_VERMELHO"})	// AGUARD. SEPARAR
AADD(ACORES,{"ZZE_STATUS == '2'","BR_AZUL"})		// AGUARD. ORDEM DE SERVICO
AADD(ACORES,{"ZZE_STATUS == '3'","BR_AMARELO"})		// EM RETRABALHO ..
AADD(ACORES,{"ZZE_STATUS == '4'","BR_VERDE"})		// REALIZADO -> Alterei o Status 4 de FINALIZADO para REALIZADO pq a finalização será por outro campo
AADD(ACORES,{"ZZE_STATUS == '9'","BR_MARRON"})		// CANCELADO
AADD(ACORES,{"ZZE_STATUS == 'A'","BR_VIOLETA"})		// RETORNO NÃO PLANEJADO PARA ESTOQUE
AADD(ACORES,{"ZZE_STATUS == 'B'","BR_CINZA"})		// REALIZADO (FINALIZADO) SEM ATENDER TODO O PEDIDO

DbSelectArea(cAlias)
DbSeek(xFilial(cAlias),.F.)
mBrowse(6,1,22,75,cAlias,,,,,,aCores)

Return Nil


/* legenda */
//User Function EstR8Lg(cAlias,nReg,nOpc) // By Roberto Oliveira 18/02/14 - Se colocar os parâmetros ele trava o registro
User Function EstR8Lg()

Local aLegenda	:= {}

AADD(ALEGENDA,{"BR_PRETO","Encerrado"})
AADD(ALEGENDA,{"BR_VERMELHO","AGUARD. Separar"})
AADD(ALEGENDA,{"BR_AZUL","Aguard. Ordem de Servico"})
AADD(ALEGENDA,{"BR_AMARELO","Em Retrabalho .."})
AADD(ALEGENDA,{"BR_VERDE","Finalizado"})
AADD(ALEGENDA,{"BR_MARRON","Cancelado"})
AADD(ALEGENDA,{"BR_VIOLETA","Ret.Estoque nao Planej."})
AADD(ALEGENDA,{"BR_CINZA","Finalizado s/atender todo pedido"})

BrwLegenda("Retrabalho", "Legenda" , aLegenda)

Return .T.


/*
BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime ordem retrabalho                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC
*/
User Function ESTR8r()

Local i
Local cDesc1         := "Imprime Ordem de Retrabalho"
Local cDesc2         := ""
Local cDesc3         := ""
Local cPict          := ""
Local titulo       := "ORDEM DE RETRABALHO"
Local nLin         := 80
Local cACExt       := ""


Local Cabec1       := ""
Local Cabec2       := ""
Local imprime      := .T.
Local aOrd := {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite           := 80
Private tamanho          := "P"
Private nomeprog         := "CRESTR8" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo            := 18
Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey        := 0
Private cbtxt      := Space(10)
Private cbcont     := 00
Private CONTFL     := 01
Private m_pag      := 01
Private wnrel      := "CRESTR5" // Coloque aqui o nome do arquivo usado para impressao em disco

Private cString := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//  Monta a interface padrao com o usuario...
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
EndIf

nTipo := If(aReturn[4]==1,15,18)



RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
// finaliza
///////////////////////////////////////AtuZZF()
Return


/*
BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄDh/Dh/¿
// Funcao de Impressao
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC
*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
Local lPrimVez := .t.
Local lCabec   := .f.
Local nOrdem
Local cACExt := ""
Local i := 0
Local cQuebra := ""
Local cTpBob := ""
Local cACExt := ""
Local nquery := 0
Local cTpBob := ""
Local nMetEnt := 0
Local nMetSai := 0
Local nMetSob := 0

//  vai imprimir para BOBINA


If lAbortPrint
	@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
	Return
EndIf
// faz query no ZZE PARA PEGAR OS NUMEROS DOS ZZES ASSOCIADOS

// select * from ZZE990 ZZE inner join ZZF990 ZZF on ZZE.ZZE_ID = ZZF.ZZF_ZZEID where  ZZF.ZZF_ID = '000027'

cQuery :=  " SELECT * "+;
" FROM "+RetSqlName("ZZE")+" ZZE " +;
" INNER JOIN "+RetSqlName("ZZF") + " ZZF " +;
" ON ZZE.ZZE_ID = ZZF.ZZF_ZZEID " +;
" WHERE "+;
" ZZF_FILIAL =  '"+xFilial("ZZF")+"'  AND "+;
" ZZF.ZZF_ID = '"+ cZZF_ID  +"'  AND "+;
" ZZE.D_E_L_E_T_ <> '*' AND ZZF.D_E_L_E_T_ <> '*'"+;
" ORDER BY ZZE.ZZE_ID, ZZE.ZZE_PEDIDO, ZZE.ZZE_ITEMPV"

cQuery := ChangeQuery(cQuery)

If select("ZZEX") > 0
	DbSelectArea("ZZEX")
	ZZEX->(DbCloseArea())
EndIf

DbUseArea( .T., "TOPCONN", TCGENQRY(,, cQuery ), "ZZEX", .F., .T. )
DbSelectArea( "ZZEX" )
ProcRegua(ZZEX->(recno()))
DbGoTop()
count to nquery
If nquery == 0
	alert("Nao selecionou nada....encerra")
	Return
EndIf
DbGoTop()


// imprime as entradas

While ZZEX->(!Eof())
	
	If lPrimVez
		lPrimVez := .f.
		
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 7
		ImpIdSep(@nLin)    // imprime Id separacao
		
		cQuebra := ""
	EndIf
	
	//	If cQuebra # ZZEX->ZZE_NUMBOB
	If cQuebra # ZZEX->ZZE_ID
		
		If nLin > 49 // Salto de Página. Neste caso o formulario tem 51 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 7
			ImpIdSep(@nLin)    // imprime Id separacao
			
		EndIf
		
		nlin++
		@ nlin , 000 psay replicate("-",80)
		nlin++
		@ nlin , 000 psay "ID. RETRABALHO: " + ZZEX->ZZE_ID
		nlin++
		@ nlin , 000 psay replicate("-",80)
		
		nlin++
		nLin++
		@ nlin , 000 psay "Data término: _____/_____/_____         Hora: ____:____ "
		nLin++
		nlin++
		@ nlin , 000 psay "Responsável: ______________________________________________ "
		nlin++
		@ nlin , 000 psay replicate("-",80)
		nlin++
		
		cACExt := u_TRACEXT(ZZEX->ZZE_ACONDE)
		@ nlin , 000 psay "Entrada-->  "+transform(ZZEX->ZZE_LANCEE,"@E 999,999.99")+cACExt+" X "+transform(ZZEX->ZZE_METRAE,"@E 999,999.99")+" metros = "+;
		transform(ZZEX->ZZE_TOTEN,"@E 999,999.99")+" metros"
		
		If ZZEX->ZZE_ACONDE == "B"
			nLin ++
			@ nlin , 000 psay "BOBINA = " + ZZEX->ZZE_NUMBOB
			cTpBob := posicione("SZE", 1, xFilial("SZE")+ZZEX->ZZE_NUMBOB, "ZE_TPBOB")
			@ nLin , 034 PSAY "Tipo Bobina = "+ Substr("65x25; 65x45; 80x45;100x60;125x70;150x80;170x80",((Val(cTpBob)*7)-6)-1,6)
		EndIf
		nlin++
		@ nlin , 000 psay replicate("-",80)
		
		nMetEnt += ZZEX->ZZE_TOTEN
		
		// carrega chave para quebra
		
		//	cQuebra := ZZEX->ZZE_NUMBOB
		cQuebra := ZZEX->ZZE_ID
		
	EndIf
	
	
	If ZZEX->ZZE_PEDIDO == "000001" //  SOBRA
		
		If nLin > 49 // Salto de Página. Neste caso o formulario tem 51 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 7
			ImpIdSep(@nLin)    // imprime Id separacao
			lCabec :=.t.
		EndIf
		
		If lCabec
			lCabec := .f.
			
			@ nlin , 000 psay replicate("-",80)
			nlin++
		EndIf
		@ nlin , 000 psay "ID. RETRABALHO: " + ZZEX->ZZE_ID
		nlin++
		
		//
		cACExt := u_TRACEXT(ZZEX->ZZE_ACONDS)
		//
		@ nlin , 000 psay "Sobra-->  "+transform(ZZEX->ZZE_LANCES,"@E 999,999.99")+cACExt+" X "+transform(ZZEX->ZZE_METRAS,"@E 99999")+" metros = "+;
		transform(ZZEX->ZZE_TOTSA,"@E 999,999.99")+" metros"
		
		nMetSob += ZZEX->ZZE_TOTSA
		
		nlin++
		@ nlin , 000 psay replicate("-",80)
		nlin++
		
	else
		
		If nLin > 49 // Salto de Página. Neste caso o formulario tem 51 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 7
			ImpIdSep(@nLin)    // imprime Id separacao
		EndIf
		
		@ nlin , 000 psay replicate("-",80)
		nlin++
		//@ nlin , 000 psay "ID. RETRABALHO: " + ZZEX->ZZE_ID
		//nlin++
		@ nlin , 000 psay "Cliente: " + ZZEX->ZZE_CODCLI
		@ nlin , 017 psay "Lj: " + ZZEX->ZZE_LOJA
		@ nlin , 025 psay "Nome: " + ZZEX->ZZE_NOMCLI
		nlin++
		@ nlin , 000 psay "Pedido: " + ZZEX->ZZE_PEDIDO
		@ nlin , 015 psay "Item: " + ZZEX->ZZE_ITEMPV
		@ nlin , 030 psay "Dt.Entrega: " + dtoc(stod(ZZEX->ZZE_PVENTR))
		@ nlin , 058 psay "Dt.Inicio: " + dtoc(stod(ZZEX->ZZE_DTINI))
		nlin++
		@ nlin , 000 psay "Observ: "// + ZZEX->ZZE_OBSERV              // campo memo ver se usa depois o memoline
		//
		nlin++
		cACExt := u_TRACEXT(ZZEX->ZZE_ACONDS)
		@ nlin , 000 psay "Saída--->  "+transform(ZZEX->ZZE_LANCES,"@E 999,999.99")+cACExt+" X "+transform(ZZEX->ZZE_METRAS,"@E 999,999.99")+" metros = "+;
		transform(ZZEX->ZZE_TOTSA,"@E 999,999.99")+" metros"
		nlin ++
		/*
		nlin++
		nLin++
		@ nlin , 000 psay "Data término: _____/_____/_____         Hora: ____:____ "
		nLin++
		nlin++
		@ nlin , 000 psay "Responsável: ______________________________________________ "
		nlin++
		@ nlin , 000 psay replicate("-",80)
		nlin++
		*/
		nMetSai += ZZEX->ZZE_TOTSA
		
	EndIf
	
	ZZEX->( dbskip() )
enddo

nlin++
nlin++




// imprime totais

Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin := 7

nLin++
@ nlin , 000 psay replicate("-",80)
nlin++
@ nlin , 000 psay "Total Metrag Entrada-->  "+transform(nMetEnt,"@E 999,999.99")
nlin++
@ nlin , 000 psay "Total Metrag Saída---->  "+transform(nMetSai,"@E 999,999.99")
nlin++
@ nlin , 000 psay "Total Metrag Sobra---->  "+transform(nMetSob,"@E 999,999.99")
@ nlin , 050 psay "Diferença---->  "+transform(  nMetEnt - (nMetSob + nMetSai) ,"@E 999,999.99")
nLin++
@ nlin , 000 psay replicate("-",80)
//
// atualiza STATUS DO ZZF

If cZZF_STAT == "6"
	cQuery :=  " UPDATE " +RetSqlName("ZZF")+ " SET ZZF_STATUS = '7' WHERE ZZF_ID = '"+cZZF_ID+"'"
	
	TcSqlExec( cQuery )
else
	alert("Status será deixado como está para refletir situação das Baixas da Separação")
EndIf

SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIf

MS_FLUSH()

Return


/*
BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ(¿
// Mostra produtos já separados
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ(Ù
ENDDOC
*/
User Function ProdSep(cZZFID)

Local cFiltro := "ZZU->ZZU_ZZFID == '"+cZZFID+"'"
Local aIndex  := {}

Local aCores := { { "ZZU_STATUS == '1'"                 	 , "BR_VERDE"	},;
{ "ZZU_STATUS == '2'"                     	     , "BR_VERMELHO"} }


Local cAlias := "ZZU"

Private cCadastro 	:= "ORDENS DE SEPARAÇÃO PARA RETRABALHO"
Private bFiltraBrw := { || FilBrowse( "ZZU" , @aIndex , @cFiltro ) }

Private aRotina 	:= { {"Pesquisar" 			,"AxPesqui"		,0,1} ,;
{"Visualizar"			,"AxVisual"		,0,2}  }


Private oOk			:= LoadBitmap( GetResources(), "LBOK" )
Private oNo			:= LoadBitmap( GetResources(), "LBNO" )
Private cTitulo		:= "MOSTRA PRODUTOS JÁ SEPARADOS"
Private oDlg

Private oDtRec
Private dDtRec := ddatabase
Private oResp
Private cResp := space(50)
Private oHrRec
Private cHrRec := substr(time(),1,5)

Private cZZFID := ""
//
LjMsgRun("Irá mostrar tela....aguarde")

Eval( bFiltraBrw )
mBrowse( 6,1,22,75,cAlias,,,,,,aCores)
EndFilBrw( "ZZU" , @aIndex )

Return Nil



/*
BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³imprime id separacao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC
*/
Static Function ImpIdSep( nLin)

Local cDescPro := ""

@ nLin , 000 PSAY "ID. ORDEM DE SERIVO : " + ZZE->ZZE_ORDEM

@ nLin , 030 psay "Data: "+ dtoc(dDatabase)

nlin++
@ nLin , 000 psay "Prod: "+ ZZE->ZZE_PRODUT
cDescPro := posicione("SB1", 1, xFilial("SB1")+ZZE->ZZE_PRODUT, "B1_DESC")
@ nlin , 022 psay "Descr: "+ cDescPro
nLin++


Return
*
************************
User Function CRESTR8B() // Encerra o retrabalho sem produção
************************
*
*
Local aArea		:= GetArea()
Local cChave	:= ZZE->(ZZE_FILIAL + ZZE_ID)
Local lOk		:= .T.
Local aPvFora	:= {} // pedidos em retrabalho nao atendidos
Local i

If !"ADMINISTRADOR" $ Upper(cUserName) .And. !"ROBERTO" $ Upper(cUserName)
	Alert("Rotina em Teste")
	Return(.T.)
EndIf


If ZZE->ZZE_SITUAC == "1" // Já Encerrado
	Alert("Retrabalho já Encerrado!")
	Return(.T.)
ElseIf ZZE->ZZE_STATUS $ "1/2"
	Alert("Retrabalho não Separado!")
	Return(.T.)
ElseIf ZZE->ZZE_DTINI < Ctod("01/12/2015")
	Alert("Encerrar retrabalhos de 01/12/2015 em diante")
	Return(.T.)
EndIf

_ZZEID := ZZE->ZZE_ID
_ZZEDT := 0
DbSelectArea("ZZE")
DbSetOrder(1) // ZZE_FILIAL+ZZE_ID
DbSeek(xFilial("ZZE") + _ZZEID,.F.)
Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE->ZZE_ID == _ZZEID .And. ZZE->(!Eof())
	_ZZEDT += ZZE->ZZE_DEVTOT
	ZZE->(DbSkip())
EndDo
DbSeek(xFilial("ZZE") + _ZZEID,.F.)
_lVolta := .F.
If _ZZEDT > 0 // Foi devolvido algo -> Verificar se tudo ou se o saldo é menor ou igual a sucata
	_lVolta := AvalZZe(ZZE->ZZE_ID, ZZE->ZZE_SALDO, _ZZEDT, ZZE->ZZE_TOTEN)
EndIf

If !_lVolta
	SC6->(dbsetorder(1))
	ZZE->(dbsetorder(2))
	If MsgYesNo("Confirma encerrar o retrabalho?")
		ZZE->(dbseek(cChave))
		while ZZE->(ZZE_FILIAL + ZZE_ID) == cChave .and. !ZZE->(eof())
			If ZZE->ZZE_PEDIDO != "000001" .and. !Empty(ZZE->ZZE_PEDIDO) .and. ZZE->ZZE_STATUS == "3" // PEDIDO EM RETRABALHO NAO ATENDIDO
				aadd(aPvFora,{ZZE->(ZZE_FILIAL + ZZE_PEDIDO + ZZE_ITEMPV),Int(ZZE->((ZZE_TOTSA - ZZE_DEVPED) / ZZE_METRAS))}) // ACUMULADOR DE ITENS EM RETRABALHO NAO ATENDIDOS
			elseIf ZZE->ZZE_STATUS == "3" // SOBRA EM RETRABALHO NAO ATENDIDA
				ZZE->(RECLOCK("ZZE",.F.))
				ZZE->ZZE_STATUS := "B" // FINALIZADO SEM ATENDER TODO PEDIDO/ PLANEJADO
				ZZE->(MSUNLOCK())
			EndIf
			ZZE->(dbskip())
		enddo
		for i := 1 to len(aPvFora)
			If SC6->(dbseek(aPvFora[i,1]))
				SC6->(RECLOCK("SC6",.F.))
				SC6->C6_QTDRES -= (aPvFora[i,2]*SC6->C6_METRAGE)  // Linha adicionada por Roberto Oliveria - 09/05/17
				SC6->C6_XQTDRET -= aPvFora[i,2]
				if SC6->C6_XQTDRET <= 0
					SC6->C6_XQTDRET := 0
					SC6->C6_QTDRES := 0
				EndIf
				if SC6->C6_XQTDRET <= 0 .And. SC6->C6_XQTDNEG <= 0
					SC6->C6_XQTDNEG := 0
					SC6->C6_SEMANA := ""
				EndIf
				SC6->(MSUNLOCK())
				
				If ZZE->(dbseek(cChave + SC6->(C6_NUM + C6_ITEM)))
					ZZE->(RECLOCK("ZZE",.F.))
					ZZE->ZZE_STATUS := "B" // FINALIZADO SEM ATENDER TODO PEDIDO/ PLANEJADO
					ZZE->(MSUNLOCK())
				EndIf
			EndIf
		next
	EndIf
EndIf
RestArea(aArea)
Return(.T.)
*
************************
User Function CRESTR8C() // Encerra o retrabalho automatico
************************
*
If MsgYesNo("Confirma Processamento para Encerrar o Retrabalho?")
	Processa({|| EncRetrab()})
	Alert("Processamento Concluído")
EndIf
Return(.T.)
*
***************************
Static Function EncRetrab()
***************************
*
Private lMsErroAuto := .F.

cQuery :=	"SELECT ZZE_ID,MAX(ZZE_TOTEN) TOTEN, SUM(ZZE_TOTSA) TOTSA, SUM(ZZE_DEVTOT) DEVTOT, MAX(ZZE_SALDO) SALDO"+;
" FROM "+RetSqlName("ZZE")+;
" WHERE ZZE_FILIAL =  '"+xFilial("ZZE")+"'"	+;
" AND ZZE_SITUAC <> '1'"	+;
" AND ZZE_DTINI  > '20151201'"	+;
" AND D_E_L_E_T_ = ''"	+;
" GROUP BY ZZE_ID"	+;
" ORDER BY ZZE_ID"
cQuery := ChangeQuery(cQuery)
If Select("ZZEX") > 0
	DbSelectArea("ZZEX")
	ZZEX->(DbCloseArea())
EndIf

DbUseArea( .T., "TOPCONN", TCGENQRY(,, cQuery ), "ZZEX", .F., .T. )
DbSelectArea( "ZZEX" )
Count to nQuery
ProcRegua(nQuery)
DbGoTop()
Do While ZZEX->(!Eof())
	IncProc()
	If ZZEX->DEVTOT > 0 // Foi devolvido algo -> Verificar se tudo ou se o saldo é menor ou igual a sucata
		AvalZZe(ZZEX->ZZE_ID, ZZEX->SALDO, ZZEX->DEVTOT, ZZEX->TOTEN)
	EndIf
	ZZEX->(DbSkip())
EndDo
If Select("ZZEX") > 0
	DbSelectArea("ZZEX")
	ZZEX->(DbCloseArea())
EndIf
Return(.T.)
*
*****************************************************************
Static Function AvalZZe(_cAvZZE_ID,_nAvSALDO,_nAvDEVTOT,_nAvTOTEN)
*****************************************************************
*
_nQtdSuc := 0
DbSelectArea("ZZE")
DbSetOrder(1) // ZZE_FILIAL+ZZE_ID
DbSeek(xFilial("ZZE") + _cAvZZE_ID,.F.)
Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE->ZZE_ID == _cAvZZE_ID .And. ZZE->(!Eof()) .And. _nAvSALDO > 0
	If ZZE->ZZE_ACONDS == "S"
		_nQtdSuc := ZZE->ZZE_TOTSA
	EndIf
	ZZE->(DbSkip())
EndDo

If Max(_nAvSALDO,0) < _nQtdSuc
	_nQtdSuc := Max(_nAvSALDO,0)
EndIf

If (_nAvDEVTOT+_nQtdSuc) # _nAvTOTEN
	Return(.F.)
EndIf

DbSelectArea("ZZE")
DbSetOrder(1) // ZZE_FILIAL+ZZE_ID
DbSeek(xFilial("ZZE") + _cAvZZE_ID,.F.)

If _nQtdSuc > 0
	// Fazer transferência da quantidade para sucata
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+ZZE->ZZE_PRODUT,.F.)
	
	_cAcond := Pad(ZZE->ZZE_ACONDE+StrZero(ZZE->ZZE_METRAE,5), Len(SD3->D3_LOCALIZ))
	lMsErroAuto := .F.
	aAutoCab := {	{"cProduto"  , ZZE->ZZE_PRODUT				, Nil},;
					{"cLocOrig"  , "90"							, Nil},;
					{"cLocaliza" , _cAcond						, Nil},;
					{"nQtdOrig"  , _nQtdSuc						, Nil},;
					{"cDocumento", Pad("RT"+AllTrim(_cAvZZE_ID), Len(SD3->D3_DOC)), Nil}}
	
	_nQtdSuc := Max((_nQtdSuc * (SB1->B1_PESCOB+SB1->B1_PESPVC)),1)
	If SB1->B1_PESPVC == 0
		_cPrdSct := "SC01000001" // Cobre Nú
	Else
		_cPrdSct := "SC01000002" // Cobre Isolado
	EndIf
	
	aAutoItens := {{	{"D3_COD"    , Pad(_cPrdSct, Len(SD3->D3_COD)) , Nil}, ;
						{"D3_LOCAL"  , "01"                            , Nil}, ;
						{"D3_QUANT"  , _nQtdSuc                        , Nil}, ;
						{"D3_RATEIO" , 100                             , Nil}}}
	
	MSExecAuto({|v,x,y,z| Mata242(v,x,y,z)},aAutoCab,aAutoItens,3,.T.)
	// O Execauto abaixo é para estorno
	//MSExecAuto({|v,x,y,z| Mata242(v,x,y,z)},aAutoCab,aAutoItens,5,.T.)
	If lMsErroAuto
		Mostraerro()
		Return(.F.)
	EndIf
EndIf
// Grava ZZE_SITUAC := '1' que indica que o retrabalho foi finalizado

Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE->ZZE_ID == _cAvZZE_ID .And. ZZE->(!Eof())
	RecLock("ZZE",.F.)
	ZZE->ZZE_SITUAC := '1' // que indica que o retrabalho foi finalizado
	MsUnLock()
	ZZE->(DbSkip())
EndDo
Return(.T.)
