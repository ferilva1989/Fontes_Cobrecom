#include 'protheus.ch'

// Robert Santos
// 11/10/13
// Tela do vendedor para Gerenciar Negociacao com o Cliente
user Function CREST161

	Local aCores := {}
	local aPerg  := {}  
	local lOk := .t.

	Private cCadastro 	:= "CONTROLE DE NEGOCIACAO"
	Private aRotina 	:= {}
	Private nMV_DNEG := GETMV('MV_DNEG')  //By Roberto Oliveira 29/05/14
	Private _CdSuper16 := " "

	PUBLIC __cAlias := "ZZV"
	PUBLIC __aIndex  := {}  
	PUBLIC __cFiltro := ""
	PUBLIC bFiltraBrw := { || FilBrowse( __cAlias , @__aIndex , @__cFiltro) }

	AAdd( aCores, {" !EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'S' .AND. !EMPTY(ZZV_USERA)"	,"BR_VERDE"} ) // Finalizado COM ACEITE
	AAdd( aCores, {" !EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'S' .AND. EMPTY(ZZV_USERA) .AND. ZZV_LIBEOK $ 'N '"		,"BR_PINK"} ) // FALTA SER APROVADO PARA ALTERAR O PEDIDO
	AAdd( aCores, {" !EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'S' .AND. EMPTY(ZZV_USERA) .AND. ZZV_LIBEOK == 'S'"		,"BR_MARROM"} ) // FALTA ENCERRAR PELO APROVADOR INTERNO COBRECOM
	AAdd( aCores, {" !EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'N' "							,"BR_BRANCO"} ) // Finalizado REJEITADO

	AAdd( aCores, {" Val(ZZV_DIASEN) < nMV_DNEG ","BR_VERMELHO"} ) // VENCIDO  //By Roberto Oliveira 29/05/14
	AAdd( aCores, {" EMPTY(ZZV_DTPRIM)"														,"BR_AMARELO"} ) // FALTA INICIAR ATENDIMENTO
	AAdd( aCores, {" !EMPTY(ZZV_DTPRIM) "													,"BR_AZUL"} ) // EM NEGOCIACAO

	AAdd( aRotina, {"Pesquisar","AxPesqui",0,1} )
	AAdd( aRotina, {"Visualizar","u_REST16v",0,2} )
	AAdd( aRotina, {"Legenda","u_REST16l",0,2} )
	AAdd( aRotina, {"Negociar","u_REST161a",0,4} )      

	MsgRun("Aguarde","Aguarde",{||u_Rest16x()})

	dbselectarea("ZZX")

	DbSelectArea("SA3") // Buscar o vendedor logado!
	if MsgYesNo("Deseja abrir seus representantes mapeados?")
		SA3->(DbSetOrder(7)) // A3_FILIAL+A3_CODUSR
		lA3 := SA3->(DbSeek(xFilial("SA3") + __cUserId ))
	else
		ValidPerg("CREST161p1")
		if Pergunte("CREST161p1", .t.)	
			SA3->(DbSetOrder(1)) // A3_FILIAL+
			lA3 := SA3->(DbSeek(xFilial("SA3") + MV_PAR01 ))
		endif
	endif

	DbSelectArea("SA3") // Buscar o vendedor logado!
	_CdSuper16 := SA3->A3_COD
	DbSetOrder(5) // A3_FILIAL+A3_SUPER
	lA3 := DbSeek(xFilial("SA3") + _CdSuper16 ) // É supervisor de alguém ?

	DbSetOrder(1) // A3_FILIAL+A3_COD
	DbSeek(xFilial("SA3") + _CdSuper16 ) // É supervisor de alguém ?

	ZZX->(dbsetorder(1))

	if lA3
		__cFiltro := "ZZV_STATUS $ '1;2;3' .And. ZZV_SUPER == _CdSuper16"
		Eval( bFiltraBrw )
		mBrowse(6,1,22,75,__cAlias,,,,,,aCores)
	else
		Alert("Você precisa ter um código de supervisor válido!")
	endif     	

return nil

Static Function ValidPerg( cPerg )

	local _aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Vendedor","mv_ch1","C",TamSX3("A3_COD")[1] ,0,0,"G","","mv_par01",""   ,"","",""   ,"","","","","","","","","","","ZZX"})

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


static Function GTSenha()
	Local oGet1
	Local cGet1 := Space(TAMSX3("ZZX_SENHA")[1])
	Local oGroup1
	Local oSay1
	Local oSButton1
	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Acesso Restrito" FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL

	@ 002, 004 GROUP oGroup1 TO 082, 245 OF oDlg COLOR 0, 16777215 PIXEL
	DEFINE SBUTTON oSButton1 FROM 086, 214 TYPE 01 OF oDlg ENABLE ACTION BTNOK(cGET1)
	@ 009, 010 SAY oSay1 PROMPT "Senha" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 018, 010 GET cGet1 SIZE 230, 010 OF oDlg COLORS 0, 16777215 PIXEL PASSWORD

	ACTIVATE MSDIALOG oDlg CENTERED

Return

static function BTNOK(cGET1)

	MV_PAR01 := cGet1
	oDlg:End()

return

user function REST16v(cAlias,nReg,nOpc)

	AxVisual(cAlias,nReg,nOpc)
	Eval( bFiltraBrw )

return