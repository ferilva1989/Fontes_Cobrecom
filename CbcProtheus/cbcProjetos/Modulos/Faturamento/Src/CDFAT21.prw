#include "rwmake.ch"
#include "protheus.ch"

User Function MA415BUT()
	If Altera
		If M->CJ_CONDPAG == "000" .And. M->CJ_EMISSAO > Ctod("12/04/2015")
			DbSelectArea("SCK")
			DbSetOrder(1) //CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO
			If Type("_a415BNDES") # "U"
				For _nBNDES := 1 to Len(_a415BNDES)
					If DbSeek(xFilial("SCK")+SCJ->CJ_NUM+_a415BNDES[_nBNDES,1],.F.)
						RecLock("SCK",.F.)
						SCK->CK_PRCVEN := Round(_a415BNDES[_nBNDES,2],TamSX3("CK_PRCVEN")[2])
						SCK->CK_VALOR  := Round(_a415BNDES[_nBNDES,3],TamSX3("CK_VALOR")[2])
						MsUnLock()
						SCK->(DbSkip())
					EndIf
				Next
			EndIf
		EndIf
		// Verificar se o TES não está bloqueado ou não é o 505 - Conforme orientação do Jeferson 06/11/15
		DbSelectArea("TMP1")
		_cAreaTMP1 := GetArea()
		Do While TMP1->(!Eof())
			If Posicione("SF4",1,xFilial("SF4")+TMP1->CK_TES,"F4_MSBLQL") == "1"
				TMP1->CK_TES := Space(Len(TMP1->CK_TES))
			EndIf
			TMP1->(DbSkip())
		EndDo
		RestArea(_cAreaTMP1)
	EndIf
	aButtons := {}
	aAdd( aButtons, {"S4WB005N",{|| u_ValMemo(.T.) }, "Le Texto"})
	aAdd( aButtons, {"S4WB005N",{|| u_ValOrc(.T.) }, "ORC.DTC"})
	aAdd( aButtons, {"S4WB005N",{|| u_CbcWEdi(.T.) }, "WebEdi Ped."})
Return(aButtons)

User Function ValMemo(_lBotao)

	If Empty(M->CJ_CLIENTE) .Or. Empty(M->CJ_LOJA) .Or. Empty(M->CJ_TABELA)
		If _lBotao
			MsgAlert("Os Campos Cliente, Loja e Tabela devem estar preenchidos!","Atenção!")
		EndIf
		Return(.T.)
	EndIf
	_VarTXT := AllTrim(M->CJ_TEXTO)
	_VarNew := ""
	_cMProd := ""
	_nMQtd  := ""
	_cMAcon := ""
	_nMVlUn := ""
	_nTab   := 0
	_nLin   := 0
	_lVolta := .T.
	_nTot1 := 0
	_nTot2 := 0

	For _nPos := 1 to Len(_VarTXT)
		_cCarac := Substr(_VarTXT,_nPos,1)
		_cASCII := Asc(_cCarac)
		If _cASCII == 9 // TAB
			// Verificar qual TAB é e acumular na variável correta
			//2ndo TAB -> Código do produto
			//14o  TAB -> Quantidade com ponto de milhar e virgula decimal
			//16o  TAB -> Acondic
			//18o  TAB -> Valor Unitário com R$ na frente e  com ponto de milhar e virgula decimal
			_nTab++
			If _nTab == 02 //2ndo TAB -> Código do produto
				_cMProd := AllTrim(_VarNew)
				If Len(_cMProd) # 10
					Alert("Erro na Linha "+ AllTrim(Str(_nPos)) + " - Código do Produto Inválido")
					_lVolta := .F.
					Exit
				EndIf
				_cMProd := Left(AllTrim(_VarNew) + Space(Len(SCK->CK_PRODUTO)),Len(SCK->CK_PRODUTO))
				SB1->(DbSetOrder(1))
				If !SB1->(DbSeek(xFilial("SB1") + _cMProd,.F.))
					Alert("Erro na Linha "+ AllTrim(Str(_nPos)) + " - Código do Produto não Cadastrado")
					_lVolta := .F.
					Exit
				EndIf
			ElseIf _nTab == 14//14o  TAB -> Quantidade com ponto de milhar e virgula decimal
				_VarNew := Upper(_VarNew)
				_VarNew := StrTran(_VarNew,"R","")
				_VarNew := StrTran(_VarNew,"$","")
				_VarNew := StrTran(_VarNew,".","")
				_VarNew := StrTran(_VarNew,",",".")
				_VarNew := AllTrim(_VarNew)
				_nMQtd  := Val(_VarNew)
				If _nMQtd <= 0
					Alert("Erro na Linha "+ AllTrim(Str(_nPos)) + " - Quantidade Inválida")
					_lVolta := .F.
					Exit
				EndIf
			ElseIf _nTab == 16//16o  TAB -> Acondic
				_VarNew := Left(AllTrim(Upper(_VarNew)),1)
				_cMAcon := _VarNew
			ElseIf _nTab == 18 //18o  TAB -> Valor Unitário com R$ na frente e  com ponto de milhar e virgula decimal
				_VarNew := Upper(_VarNew)
				_VarNew := StrTran(_VarNew,"R","")
				_VarNew := StrTran(_VarNew,"$","")
				_VarNew := StrTran(_VarNew,".","")
				_VarNew := StrTran(_VarNew,",",".")
				_VarNew := AllTrim(_VarNew)
				_nMVlUn := Val(_VarNew)
				If _nMVlUn <= 0
					Alert("Erro na Linha "+ AllTrim(Str(_nPos)) + " - Valor Unitário Inválido")
					_lVolta := .F.
					Exit
				EndIf

				DbSelectArea("TMP1")
				// Adicionar linha no TMP1
				If ++_nLin == 1
					// Somente na primeira vez mata o conteúdo da tabela
					Zap
				EndIf

				dbAppend()
				For nCont := 1 To Len(aHeader)
					_PosTMP  := FieldPos(aHeader[nCont,2])
					_PosSCK  := SCK->(FieldPos(aHeader[nCont,2]))
					If _PosSCK > 0
						If (aHeader[nCont,08] <> "M" .And. aHeader[nCont,10] <> "V" )
							DbSelectArea("TMP1")
							_cCnt := CriaVar(aHeader[nCont,2])
							FieldPut(_PosTMP,_cCnt)
						EndIf
					Else
						xxx := 1
					EndIf
				Next nCont

				// A criação dos campos e a inclusão dos dados tem que ser na mesma ordem do aHeader
				_lVerAcon := .T.
				For nCont := 1 To Len(aHeader)
					If AllTRim(aHeader[nCont,2]) == "CK_ITEM"
						TMP1->CK_ITEM := StrZero(_nLin,Len(TMP1->CK_ITEM))
						TMP1->CK_FLAG := .F.
					ElseIf AllTRim(aHeader[nCont,2]) == "CK_ZZNRRES"
						TMP1->CK_ZZNRRES 	:=  Space(TamSx3("CK_ZZNRRES")[1])
						M->CK_ZZNRRES		:=	TMP1->CK_ZZNRRES
					ElseIf AllTRim(aHeader[nCont,2]) == "CK_PRODUTO"
						// Executa o gatilho do CK_PRODUTO
						SB1->(DbSetOrder(1))
						SB1->(DbSeek(xFilial("SB1") + _cMProd,.F.))

						M->CK_PRODUTO := _cMProd
						TMP1->CK_PRODUTO := _cMProd

						If SB1->B1_BLQVEN == "S" .Or. SB1->B1_MSBLQL == "1"
							//Alert("Erro na Linha "+ AllTrim(Str(_nPos)) + " - Produto Bloqueado Para Venda!!!!")
							Alert("Erro na Linha "+ AllTrim(Str(_nLin)) + " - Produto Bloqueado Para Venda!!!!")
							_lVolta := .F.
							Exit
						EndIf
						If !VjaValid("CK_PRODUTO")
							Alert("Erro na Linha "+ AllTrim(Str(_nLin)) + " - Produto Inválido")
							_lVolta := .F.
							Exit
						EndIf
					ElseIf AllTRim(aHeader[nCont,2]) == "CK_METRAGE"
						If 	_lVerAcon .And. _cMAcon == "R" .And. (_nMQtd%100) == 0
							TMP1->CK_METRAGE := 100
							M->CK_METRAGE    := TMP1->CK_METRAGE // esta variável tem que ser criada para a rotina de validação
							If !VjaValid("CK_METRAGE")
								_lVerAcon := .F.
								TMP1->CK_LANCES  := 0
								TMP1->CK_ACONDIC := " "
								TMP1->CK_METRAGE := 0
							EndIf
						EndIf
					ElseIf AllTRim(aHeader[nCont,2]) == "CK_LANCES"
						If 	_lVerAcon .And. _cMAcon == "R" .And. (_nMQtd%100) == 0
							TMP1->CK_LANCES  := _nMQtd / 100
							M->CK_LANCES  := TMP1->CK_LANCES // esta variável tem que ser criada para a rotina de validação
							If !VjaValid("CK_LANCES")
								_lVerAcon := .F.
								TMP1->CK_LANCES  := 0
								TMP1->CK_ACONDIC := " "
								TMP1->CK_METRAGE := 0
							EndIf
						EndIf
					ElseIf AllTRim(aHeader[nCont,2]) == "CK_ACONDIC"
						If 	_lVerAcon .And. _cMAcon == "R" .And. (_nMQtd%100) == 0
							TMP1->CK_ACONDIC := _cMAcon
							M->CK_ACONDIC := TMP1->CK_ACONDIC// esta variável tem que ser criada para a rotina de validação
							If !VjaValid("CK_ACONDIC")
								_lVerAcon := .F.
								TMP1->CK_LANCES  := 0
								TMP1->CK_ACONDIC := " "
								TMP1->CK_METRAGE := 0
							EndIf
						EndIf
					ElseIf AllTRim(aHeader[nCont,2]) == "CK_QTDVEN"
						M->CK_QTDVEN     := _nMQtd
						TMP1->CK_QTDVEN  := _nMQtd
						If !VjaValid("CK_QTDVEN")
							M->CK_QTDVEN     := 0
							TMP1->CK_QTDVEN  := 0
						EndIf
					ElseIf AllTRim(aHeader[nCont,2]) == "CK_PRCVEN"
						M->CK_PRCVEN  := _nMVlUn
						TMP1->CK_PRCVEN := _nMVlUn

						If !VjaValid("CK_PRCVEN")
							M->CK_PRCVEN    := 0
							TMP1->CK_PRCVEN := 0
						EndIf
						_nTot1 += (TMP1->CK_QTDVEN*TMP1->CK_PRCVEN)
						_nTot2 += TMP1->CK_VALOR
					EndIf
				Next
				If !_lVolta
					Exit
				EndIf
			EndIf
			_VarNew := ""
			Loop
		ElseIf _cASCII == 13 .Or.  _cASCII == 10
			_nTab   := 0
			_VarNew := ""
			Loop
		EndIf
		_VarNew := _VarNew + _cCarac
	Next
	DbSelectArea("TMP1")
	DbGoBottom()
	If Recno() == 0
		_lVolta := .F.
		_nLin := 1
	EndIf
	If !_lVolta // Deu erro em algum campo
		Zap // Mata todos os registros
		// Cria novo Zerado
		dbAppend()
		For nCont := 1 To Len(aHeader)
			_PosTMP  := FieldPos(aHeader[nCont,2])
			_PosSCK  := SCK->(FieldPos(aHeader[nCont,2]))
			If _PosSCK > 0
				If (aHeader[nCont,08] <> "M" .And. aHeader[nCont,10] <> "V" )
					DbSelectArea("TMP1")
					_cCnt := CriaVar(aHeader[nCont,2])
					FieldPut(_PosTMP,_cCnt)
				EndIf
			Else
				xxx := 1
			EndIf
		Next nCont
		TMP1->CK_ITEM := StrZero(_nLin,Len(TMP1->CK_ITEM))
		TMP1->CK_FLAG := .F.
	EndIf
	DbGoTop()

	If ValType(oGetDB) <> "U"
		oGetDB:nCount:=_nLin
		oGetDB:lNewLine:=.F.

		If _lVolta
			u_BudgetMngr('EXL')
		EndIf

	EndIf

Return( .T. )

/*/{Protheus.doc} MyA415Inclui
@author bolognesi
@since 24/07/2017
@version undefined
@param cAlias, characters, descricao
@param nReg, numeric, descricao
@param nOpcx, numeric, descricao
@param xPar, , descricao
@param cNumOrc, characters, descricao
@param cCodCli, characters, descricao
@param cLoja, characters, descricao
@type function
@description 
Reproduzimos a rotina A415Inclui como uma USER FUNCTION  porque pelo padrão não há possibilidade
de dar um REFRESH no BROWSE ficando a grid de dados GETDB "louca".
Basicamente a alteração entre A415Inclui e a MyA415Inclui é a retirada do comando "Local oGetDB"
e e inclusão do comando Private oGetDB.
Nas opções do menu de ORÇAMENTOS incluimos uma chamada no MENUDEF() para esta função, uma vez que
não estamos retirando a função padrão do sistema.
/*/
User Function MyA415Inclui(cAlias,nReg,nOpcx,xPar,cNumOrc,cCodCli,cLoja)
	Local aArea		:= SCJ->(GetArea())
	Local nStack    := GetSX8Len()
	Local nX 		:= 0
	Local nOpcA		:= 0
	Local cArqSCL	:= ""
	Local cArqSCK	:= ""
	Local cNumAnt   := ""
	Local oDlg
	Local aPosObj   := {}
	Local aObjects  := {}
	Local aSize     := {}
	Local aPosGet   := {}
	Local aInfo     := {}
	Local nGetLin   := 0
	Local lBloqueia	:= .F.
	Local lGrade	:= SCK->(FieldPos("CK_ITEMGRD")) > 0 .And. MaGrade()

	Private oGetDB //Alterado LCB
	Private oSay

	Private aTela[0][0]
	Private aGets[0]
	Private bCampo		:= { |nField| Field(nField) }
	Private aHeader		:= {}
	Private aHeaderSCL	:= {}
	Private aHeaderSCK	:= {}
	PRIVATE aGEMCVnd    := {"",{},{}} //Template GEM - Condicao de Venda

	Private oGrade := MsMatGrade():New('oGrade',,"CK_QTDVEN",,"A415VlCpGr()",;
	{ 	{VK_F4,{|| A440Saldo(.T.,oGrade:aColsAux[oGrade:nPosLinO][aScan(oGrade:aHeadAux,{|x| AllTrim(x[2])=="CK_LOCAL"})])}} },;
	{ 	{"CK_QTDVEN",NIL,NIL},;
	{"CK_OPC",NIL,NIL}})

	l415Auto := If(Type("l415Auto")<>"U",l415Auto,.F.)
	l416Auto := If(Type("l416Auto")<>"U",l416Auto,.F.)

	DEFAULT cNumOrc := ""
	DEFAULT cCodCli := ""
	DEFAULT cLoja   := ""

	// By Roberto Oliveira 27/01/12 -- não tem no fonte original
	nOpcx := 3

	//Inicializa as Variaveis da Enchoice
	dbSelectArea("SCJ")
	For nX:= 1 To FCount()
		M->&(EVAL(bCampo,nX)) := CriaVar(FieldName(nX),.T.)
	Next nX
	If !Empty(cCodCli)
		M->CJ_CLIENTE := cCodCli
		M->CJ_CLIENT  := cCodCli
		M->CJ_LOJA    := cLoja
		M->CJ_LAUDO   := Posicione("SA1",1,xFilial("SA1")+cCodCli+cLoja,"A1_LAUDO")
	EndIf

	If IsInCallStack("Ft300Orc")
		M->CJ_PROSPE := M->AD1_PROSPE
		M->CJ_LOJPRO := M->AD1_LOJPRO
	EndIf

	// Monta aHeader
	A415Monta(@cArqSCK,@cArqSCL,.T.)
	aHeader := aHeaderSCK

	//Atualiza o aHeader para a Rotina Automatica
	dbSelectArea("TMP1")

	// Montagem da Tela
	If ( !l415Auto )
		//Habilita a Tecla F4
		//Faz o calculo automatico de dimensoes de objetos
		aSize := MsAdvSize()

		aObjects := {}
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 100, .t., .t. } )
		AAdd( aObjects, { 100, 015, .t., .f. } )

		aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
		aPosObj := MsObjSize( aInfo, aObjects )

		aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,;
		{{005,070,110,175,215,280}} )
		nGetLin := aPosObj[3,1]
		SetKey(VK_F6,{||u_BudgetMngr('EXL')})
		SetKey(VK_F4,{||A415F4()})
		DEFINE MSDIALOG oDlg TITLE OemtoAnsi("Orçamentos de Venda") From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		EnChoice( "SCJ" ,nReg,nOpcx,,,,,aPosObj[1],,3,,,"A415VldTOk",,,.F.)
		oGetDb := MsGetDB():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"A415LinOk","A415TudOk","+CK_ITEM",.T., , ,.T.,,"TMP1","A415FldOk")
		Private oGetDad := oGetDb
		@ nGetLin,aPosGet[1,1] SAY oSay PROMPT OemToAnsi("Total do Orçamento ") 	SIZE 060,009 PIXEL OF oDlg
		@ nGetLin,aPosGet[1,3] SAY oSay PROMPT OemToAnsi("Descontos ") 	SIZE 060,009 PIXEL OF oDlg
		@ nGetLin,aPosGet[1,5] SAY oSay PROMPT OemToAnsi("=")		SIZE 060,009 PIXEL OF oDlg //"="
		@ nGetLin,aPosGet[1,2] SAY oSay PROMPT 0 SIZE 040,009 PICTURE PesqPict("SCK","CK_VALOR",16) PIXEL OF oDlg
		oSay:Cargo := "Valor"
		@ nGetLin,aPosGet[1,4] SAY oSay PROMPT 0 SIZE 040,009 PICTURE PesqPict("SCK","CK_VALOR",14) PIXEL OF oDlg
		oSay:Cargo := "Desconto"
		@ nGetLin,aPosGet[1,6] SAY oSay PROMPT 0 SIZE 040,009 PICTURE PesqPict("SCK","CK_VALOR",16) PIXEL OF oDlg
		oSay:Cargo := "Total"
		ACTIVATE MSDIALOG oDlg ON INIT Ma415Bar(oDlg,{||nOpcA:=1,IIf(oGetDb:TudoOk().And.Obrigatorio(aGets,aTela).And.A415VldTOk(@lBloqueia),oDlg:End(),nOpcA:=0)},{||oDlg:End()}, nOpcx)

		//Desabilita a Tecla F4
		SetKey(VK_F4,Nil)
		SetKey(VK_F6,Nil)
	Else

		// Tratamento da Rotina automatica
		nOpcA := 0
		If EnchAuto(cAlias,aAutoCab,{|| Obrigatorio(aGets,aTela)}) .And. MsGetDBAuto("TMP1",aAutoItens,"A415LinOk",{|| A415TudOk() .And. A415VldTOk(@lBloqueia)},aAutoCab,aRotina[nOpcx][4])
			nOpcA := 1
		EndIf
	EndIf

	If ( nOpcA == 1 )
		Begin Transaction

			//Efetua tratamento do Bonus
			cNumAnt := M->CJ_NUM
			A415Bonus(1)
			If Type("lOnUpDate") == "U" .Or. lOnUpdate
				If lGrade
					A415Gr2SCK() //Transforma grade em itens da SCK
				EndIf
				If ( A415Grava(1,lBloqueia) )
					// Seta a varivel de numero ( chamada do FATA300 )
					cNumOrc := M->CJ_NUM
					While GetSX8Len() > nStack
						ConfirmSX8()
					EndDo
					EvalTrigger()
					// Exibe mensagem caso tenha alterado o numero do orcamento
					If ( cNumAnt <> M->CJ_NUM )
						If !( Type("l415Auto") <> "U" .And. l415Auto )
							Help(" ",1,"NUMSEQ",,M->CJ_NUM,4,15)
						EndIf
					EndIf
					MEnviaMail("026",{SCJ->CJ_NUM,SCJ->CJ_CLIENTE,SCJ->CJ_LOJA,SA1->A1_NOME})
				EndIf
			Else
				aAutoCab := MsAuto2Ench("SCJ")
				aAutoItens := MsAuto2GDb(aHeader,"TMP1")
			EndIf
		End Transaction
	Else
		While GetSX8Len() > nStack
			RollBackSX8()
		EndDo
	EndIf

	// Executa ponto de entrada na saida
	If ExistBlock( "MA415END" )
		ExecBlock( "MA415END", .F., .F., { nOpcA, 1 } )
	EndIf

	A415DesMonta(@cArqSCK,@cArqSCL)
	MsUnLockAll()
	If SCJ->(!Eof())
		// Retornar no último orçamento incluído.
		_RegSCJ := SCJ->(Recno())
		RestArea(aArea)
		SCJ->(DbGoTo(_RegSCJ))
	Else
		RestArea(aArea)
	EndIf
Return (nOpcA == 1)

/*/{Protheus.doc} Ma415Bar
@author legado
@since 24/07/2017
@version 0.0
@param oDlg, object, descricao
@param bOk, block, descricao
@param bCancel, block, descricao
@param nOpc, numeric, descricao
@type function
@description EnchoiceBar especIfica do Mata415
/*/
Static Function Ma415Bar(oDlg,bOk,bCancel,nOpc)

	Local aUsButtons:= {}
	Local aButtons 	:= {}
	Local lOpcPadrao:= GetNewPar("MV_REPGOPC","N") == "N"
	Local nPOpcional:= If(lOpcPadrao,aScan(aHeader,{|x| AllTrim(x[2])=="CK_OPC"}),aScan(aHeader,{|x| AllTrim(x[2])=="CK_MOPC"}))

	aadd(aButtons,{"POSCLI",{|| If(!Empty(M->CJ_CLIENTE),a450F4Con(),.F.)},OemToAnsi("Posicao de Cliente"), OemToAnsi("Clientes") })
	If ( RpcCheckTbi() )
		aadd(aButtons,{"VENDEDOR",{|| Ma415TbiCl()},OemToAnsi("Inclusao do cliente TBI"),OemToAnsi("TBI")})
	EndIf

	If aRotina[ nOpc, 4 ] == 2
		AAdd(aButtons,{ "BMPVISUAL", {|| A415Track() }, OemToAnsi("System Tracker"),OemToAnsi("Tracker") } )
	EndIf
	If ( nOpc == 1 .Or. nOpc == 2 .Or. nOpc == 5 ) .And. nPOpcional > 0
		Aadd(aButtons,{"SDUCOUNT", {|| SeleOpc(2,"MATA415",TMP1->CK_PRODUTO,,,Ma415Opc(lOpcPadrao),"M->CK_PRODUTO",.T.,TMP1->CK_QTDVEN,TMP1->CK_ENTREG) } ,"Opcionais Selecionados","Opcionais"})
	EndIf

	// Adiciona botoes do usuario na EnchoiceBar
	If ExistBlock("MA415BUT")
		If ValType( aUsButtons := ExecBlock( "MA415BUT", .F., .F. ) ) == "A"
			AEval( aUsButtons, { |x| AAdd( aButtons, x ) } )
		EndIf
	EndIf
Return(EnchoiceBar(oDlg,bOK,bcancel,,aButtons))

/*/{Protheus.doc} A415Bonus
@author legado
@since 24/07/2017
@version 0.0
@param nTipo, numeric, descricao
@type function
@description Esta rotina tem como objetivo avaliar a regra de bonificacaoe adicionar na respectiva interface
/*/
Static Function A415Bonus(nTipo)

	Local aArea     := GetArea()
	Local aBonus    := {}
	Local nX        := 0
	Local nY        := 0
	Local nZ        := 0
	Local nW		:= 0
	Local cItem     := ""

	// Verifica os bonus
	If nTipo == 1

		// Verifica os bonus por item de venda
		aBonus   := FtRgrBonus("TMP1",{"CK_PRODUTO","CK_QTDVEN","CK_TES"},M->CJ_CLIENTE,M->CJ_LOJA,M->CJ_TABELA,M->CJ_CONDPAG)

		// Recupera os bonus ja existentes
		aBonus   := FtRecBonus("TMP1",{"CK_PRODUTO","CK_QTDVEN","CK_TES","CK_FLAG"},aBonus)

		// Grava os novos bonus
		nY := Len(aBonus)
		If nY > 0
			nZ := TMP1->(RecNo())
			TMP1->(dbGoBottom())
			cItem := TMP1->CK_ITEM
			TMP1->(dbGoto(nZ))
			For nX := 1 To nY
				cItem := Soma1(cItem)
				RecLock("TMP1",.T.)
				For nW := 1 To Len(aHeader)
					If !( AllTrim(aHeader[nW,2]) $ "CK_ALI_WT/CK_REC_WT")
						FieldPut(nW,CriaVar(aHeader[nW,2],.T.))
					EndIf
				Next nW
				TMP1->CK_ITEM    := cItem
				TMP1->CK_PRODUTO := aBonus[nX][1]
				A415Prod(TMP1->CK_PRODUTO)
				TMP1->CK_QTDVEN  := aBonus[nX][2]
				TMP1->CK_TES     := aBonus[nX][3]
				If ( TMP1->CK_PRCVEN == 0 )
					TMP1->CK_PRCVEN := 1
					TMP1->CK_VALOR  := TMP1->CK_QTDVEN
				Else
					TMP1->CK_VALOR := A410Arred(TMP1->CK_QTDVEN*TMP1->CK_PRCVEN,"CK_VALOR")
				EndIf
				MsUnLock()
			Next nX
		EndIf
	Else
		FtDelBonus("TMP1",{"CK_PRODUTO","CK_QTDVEN","CK_TES","CK_FLAG"})
	EndIf
	RestArea(aArea)
Return(.T.)

/*/{Protheus.doc} A415Gr2SCK
@author legado
@since 24/07/2017
@version 0.0
@type function
@description Converte registros em formato de grade em itens prontos a serem gravados na tabela SCK.
/*/
Static Function A415Gr2SCK()

	Local aArea     := GetArea()
	Local nX        := 0
	Local nLin      := 0
	Local nCol	    := 0
	Local aCampos   := {}
	Local cItemGrd  := "01"
	Local lNewLine  := .F.
	Local cProdRef  := ""
	Local nRatDesc  := 0
	Local nRecno    := 0

	dbSelectArea("TMP1")
	dbGoTop()
	While !Eof()
		cProdRef := AllTrim(CK_PRODUTO)
		nRecno := Recno()
		If MatGrdPrrf(@cProdRef)
			aCampos  := {}
			lNewLine := .F.
			cItemGrd := "01"
			For nX := 1 To Len(aHeader)
				aAdd(aCampos,&(aHeader[nX,2]))
			Next nX
			oGrade:nPosLinO := Val(CK_ITEM)

			For nLin := 1 To Len(oGrade:aColsGrade[Val(CK_ITEM)])
				For nCol := 2 To Len(oGrade:aHeadGrade[Val(CK_ITEM)])
					If oGrade:aColsFieldByName("CK_QTDVEN",Val(CK_ITEM),nLin,nCol) <> 0
						RecLock("TMP1",lNewLine)
						//Preenche todos os campos como copia
						If lNewLine
							For nX := 1 to Len(aHeader)
								FieldPut(FieldPos(aHeader[nX,2]),aCampos[nX])
							Next nX
						Else
							nRatDesc := CK_VALDESC / CK_QTDVEN
							lNewLine := .T.
						EndIf

						//Preenche campos especificos
						Replace CK_ITEMGRD With cItemGrd
						Replace CK_PRODUTO With oGrade:GetNameProd(cProdRef,nLin,nCol)
						Replace CK_DESCRI  With Posicione("SB1",1,xFilial("SB1")+CK_PRODUTO,"B1_DESC")
						Replace CK_QTDVEN  With oGrade:aColsFieldByName("CK_QTDVEN",Val(CK_ITEM),nLin,nCol)
						Replace CK_VALOR   With A410Arred(CK_QTDVEN * CK_PRCVEN,"CK_VALOR")
						Replace CK_VALDESC With A410Arred(nRatDesc * CK_QTDVEN,"CK_VALDESC")

						MsUnLock()
						cItemGrd := Soma1(cItemGrd)
					EndIf
				Next nCol
			Next nLin
		EndIf
		dbGoTo(nRecno)
		dbSkip()
	End

	RestArea(aArea)
Return

User Function MA415MNU()

	Private cUserLib := GetMv("MV_USERLIB")
	Private cUserAdm := GetMv("MV_USERADM")

	If cUserName+"|" $ cUserAdm .Or. (cModulo == "FAT" .And. cUserName+"|" $ cUserLib)
		aRotina := {	{"Pesquisar"   ,"AxPesqui"        , 0 , 1, 0 ,.F.},;
		{"Visualizar"  ,"A415Visual"      , 0 , 2, 0 ,NIL},;
		{"Incluir"     ,"u_MyA415Inclui"  , 0 , 3, 0 ,NIL},;
		{"Alterar"     ,"u_MyA415Altera"  , 0 , 4, 0 ,NIL},;
		{"Alterar LB"  ,"u_MudaLB()"      , 0 , 4, 0 ,NIL},;
		{"Exclui"      ,"A415Exclui"      , 0 , 5, 0 ,NIL},;
		{"Cancela"     ,"A415Cancel"      , 0 , 2, 0 ,NIL},;
		{"impRimir"    ,"u_CDFATR17()"    , 0 , 2, 0 ,NIL},;
		{"Copiar"      ,"A415PCpy"        , 0 , 4, 0 ,NIL},;
		{"Legenda"     ,"A415Legend"      , 0 , 2, 0 ,.F.},;
		{"Conhecimento","MsDocument"      , 0 , 4, 0 ,NIL} }

	Else
		aRotina := {	{"Pesquisar"   ,"AxPesqui"        , 0 , 1, 0 ,.F.},;
		{"Visualizar"  ,"A415Visual"      , 0 , 2, 0 ,NIL},;
		{"Incluir"     ,"u_MyA415Inclui"  , 0 , 3, 0 ,NIL},;
		{"Alterar"     ,"u_MyA415Altera"  , 0 , 4, 0 ,NIL},;
		{"Exclui"      ,"A415Exclui"      , 0 , 5, 0 ,NIL},;
		{"Cancela"     ,"A415Cancel"      , 0 , 2, 0 ,NIL},;
		{"impRimir"    ,"u_CDFATR17()"    , 0 , 2, 0 ,NIL},;
		{"Copiar"      ,"A415PCpy"        , 0 , 4, 0 ,NIL},;
		{"Legenda"     ,"A415Legend"      , 0 , 2, 0 ,.F.},;
		{"Conhecimento","MsDocument"      , 0 , 4, 0 ,NIL} }

	EndIf
Return(.T.)

User Function A415TdOk()
	local oBudget	:= nil
	local oImp		:= nil

	//[LEO] - 14/07/17 Validações do Varejo
	if ! U_vareTdOk()
		return(.F.)
	endif

	/*
	08/02/17 Preencher o campo CK_XFTPVC com conteudo do B1_VALPVP
	utilizado posteriormente no calculo da IMP (indice de materia prima)
	*/
	oImp := cbcImpService():newcbcImpService()
	oImp:putPvpOrc()
	freeObj(oImp)

	/* 02/02/16 - LOGICA DE TELA PARA REGRA TRIANGULAÇÃO */
	if !u_PE410REGRA()
		Return (.F.)
	EndIf


	// Pedidos BNDES acrescentar 2,8 %
	If !Obrigatorio(aGets,aTela,,.F.)
		// Algum campo obrigatório não preenchido, deixar o Protheus interromper e voltar
		Return(.T.)
	EndIf

	If M->CJ_CONDPAG == "000" .And. M->CJ_EMISSAO > Ctod("12/04/2015")
		// Todos os campos obrigatórios foram preenchidos e o .F. para não abrir o alert se houver algo errado.
		DbSelectArea("TMP1")
		DbGoTop()
		Do While !Eof()
			_nPrcVen := TMP1->CK_PRCBAS
			_nPrcVen += ((_nPrcVen * 2.8) / 100)
			TMP1->CK_PRCVEN := Round(_nPrcVen,TamSX3("CK_PRCVEN")[2])
			TMP1->CK_VALOR  := Round((TMP1->CK_QTDVEN*TMP1->CK_PRCVEN),TamSX3("CK_VALOR")[2])
			TMP1->(DbSkip())
		EndDo
	EndIf


	// 08/05/2014 - Jeferson Gardezani
	// Alteração: Travar registros e gravar alterações do Orçamento do Protheus (SCJ/SCK) no Orçamento do Portal (ZZJ/ZZK)
	// Código Anterior
	//_lxVolta := .T.
	// Código Atual
	_lxVolta := u_AtuPortal()
	If !_lxVolta
		If M->CJ_CONDPAG == "000" .And. M->CJ_EMISSAO > Ctod("12/04/2015")
			// Desfazer os valores
			DbSelectArea("TMP1")
			DbGoTop()
			Do While !Eof()
				TMP1->CK_PRCVEN := TMP1->CK_PRCBAS
				TMP1->CK_VALOR  := TMP1->CK_QTDVEN*TMP1->CK_PRCVEN
				TMP1->(DbSkip())
			EndDo
		EndIf
		u_CalcComis("SCJ") // Faz o cálculo das comissões item a item do orçamento
		u_AvalPrz("SCK",.T.) // Recalcula os prazos de entrega do orçamento
	EndIf

	/*04/04/2016 - ORÇAMENTO x RESERVAS NO PORTAL*/
	oBudget := CbcbudgetManager():newCbcbudgetManager()
	oBudget:budgetOk()
	If !oBudget:lOk
		Return(.F.)
	EndIf
	/*FIM LEONARDO*/

Return(_lxVolta)

/*/{Protheus.doc} MTA416PV
@author legado
@since 24/07/2017
@version 0.0
@type function
@description Este ponto de entrada é usado para a transferência das informações do SCJ para o SC5 
e do SCK para o ACOLS. 
/*/
User Function MTA416PV()
	Local aDadosCfo := {}

	If ParamIXB == 1 // O aCols só tem uma linha? -> Pra fazer somente uma vez
		_dDtEntr := u_AvalPrz("SCK",.T.,.T.) // Tabela //Rotina Tudo OK // Força o Recálculo
		If SCJ->CJ_ENTREG # _dDtEntr
			RecLock("SCJ",.F.)
			SCJ->CJ_ENTREG := _dDtEntr
			MsUnLock()
		EndIf

		M->C5_CLIOK   	:= If(SA1->A1_REVIS=="1","S"," ")
		M->C5_ENTREG  	:= SCJ->CJ_ENTREG
		M->C5_DTFAT   	:= Max(SCJ->CJ_DTFAT,Date())
		M->C5_TRANSP  	:= SCJ->CJ_TRANSP
		M->C5_CONDPAG 	:= SCJ->CJ_CONDPAG
		M->C5_VEND1   	:= SCJ->CJ_VEND1
		M->C5_OBS     	:= SCJ->CJ_OBS
		M->C5_TPFRETE 	:= SCJ->CJ_TPFRETE
		M->C5_TABELA  	:= SCJ->CJ_TABELA
		M->C5_PEDCLI  	:= SCJ->CJ_PEDCLI
		M->C5_CLIENT	:= SCJ->CJ_CLIENT
		M->C5_LOJAENT	:= SCJ->CJ_LOJAENT
		M->C5_ENDENT1 	:= SCJ->CJ_ENDENT1
		M->C5_ENDENT2 	:= SCJ->CJ_ENDENT2
		M->C5_LAUDO   	:= SCJ->CJ_LAUDO
		M->C5_DIASNEG 	:= SCJ->CJ_DIASNEG
		M->C5_XTELENT 	:= SCJ->CJ_XTELENT
		M->C5_ZZBLVEN 	:= SCJ->CJ_ZZBLVEN
		If !Empty(SA1->A1_MENPAD)
			M->C5_MENPAD  := SA1->A1_MENPAD
		EndIf

	EndIf

	Private _nPsProdu := 0
	Private _nPsAcond := 0
	Private _nPsLance := 0
	Private _nPsMetra := 0
	Private _nPsComis := 0
	Private _nPsQtdVe := 0
	Private _nPsPrcVe := 0
	Private _nPsValor := 0
	Private _nPsPrcBa := 0
	Private _nPsLcrBr := 0
	Private _nPsCstRg := 0
	Private _nPsDtEnt := 0
	Private _nPsTES   := 0
	Private _nPsCF    := 0

	If SCK->CK_ENTREG # SCJ->CJ_ENTREG
		RecLock("SCK",.F.)
		SCK->CK_ENTREG := SCJ->CJ_ENTREG
		MsUnLock()
	EndIf

	For _nPsHead := 1 to Len(_aHeader)
		If Upper(AllTrim(_aHeader[_nPsHead,2])) == "C6_ACONDIC"
			_nPsAcond := _nPsHead
		ElseIf Upper(AllTrim(_aHeader[_nPsHead,2])) == "C6_LANCES"
			_nPsLance := _nPsHead
		ElseIf Upper(AllTrim(_aHeader[_nPsHead,2])) == "C6_METRAGE"
			_nPsMetra := _nPsHead
		ElseIf Upper(AllTrim(_aHeader[_nPsHead,2])) == "C6_COMIS1"
			_nPsComis := _nPsHead
		ElseIf Upper(AllTrim(_aHeader[_nPsHead,2])) == "C6_QTDVEN"
			_nPsQtdVe := _nPsHead
		ElseIf Upper(AllTrim(_aHeader[_nPsHead,2])) == "C6_PRCVEN"
			_nPsPrcVe := _nPsHead
		ElseIf Upper(AllTrim(_aHeader[_nPsHead,2])) == "C6_VALOR"
			_nPsValor := _nPsHead
		ElseIf Upper(AllTrim(_aHeader[_nPsHead,2])) == "C6_PRCBAS"
			_nPsPrcBa := _nPsHead
		ElseIf Upper(AllTrim(_aHeader[_nPsHead,2])) == "C6_LUCROBR"
			_nPsLcrBr := _nPsHead
		ElseIf Upper(AllTrim(_aHeader[_nPsHead,2])) == "C6_CSTUNRG"
			_nPsCstRg := _nPsHead
		ElseIf Upper(AllTrim(_aHeader[_nPsHead,2])) == "C6_PRODUTO"
			_nPsProdu := _nPsHead
		ElseIf Upper(AllTrim(_aHeader[_nPsHead,2])) == "C6_ENTREG"
			_nPsDtEnt := _nPsHead
		ElseIf Upper(AllTrim(_aHeader[_nPsHead,2])) == "C6_TES"
			_nPsTES   := _nPsHead
		ElseIf Upper(AllTrim(_aHeader[_nPsHead,2])) == "C6_CF"
			_nPsCF    := _nPsHead
		ElseIf Upper(AllTrim(_aHeader[_nPsHead,2])) == "C6_XOPER"
			_nPsXOper    := _nPsHead
		ElseIf Upper(AllTrim(_aHeader[_nPsHead,2])) == "C6_OPER"
			_nPsOper    := _nPsHead
		EndIf
	Next
	If _nPsAcond > 0
		_aCols[ParamIXB,_nPsAcond] := SCK->CK_ACONDIC
	EndIf
	If _nPsLance > 0
		_aCols[ParamIXB,_nPsLance] := SCK->CK_LANCES
	EndIf
	If _nPsMetra > 0
		_aCols[ParamIXB,_nPsMetra] := SCK->CK_METRAGE
	EndIf
	If _nPsComis > 0
		_aCols[ParamIXB,_nPsComis] := SCK->CK_COMIS1
	EndIf
	If _nPsDtEnt > 0
		_aCols[ParamIXB,_nPsDtEnt] := SCK->CK_ENTREG
	EndIf
	If _nPsOper > 0
		_aCols[ParamIXB,_nPsOper] := SCK->CK_XOPER
	EndIf
	If _nPsXOper > 0
		_aCols[ParamIXB,_nPsXOper] := SCK->CK_XOPER
	EndIf
	If _nPsTES > 0
		If !Empty(SB1->B1_TS)
			_aCols[ParamIXB,_nPsTES] := SB1->B1_TS
		ElseIf !Empty(SA1->A1_TES)
			_aCols[ParamIXB,_nPsTES] := SA1->A1_TES
		EndIf

	EndIf
	If _nPsTES > 0
		If !Empty(_aCols[ParamIXB,_nPsTES])
			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+_aCols[ParamIXB,_nPsTES],.F.))
			If SF4->F4_MSBLQL == "1" 
				_aCols[ParamIXB,_nPsTES] := PadR("   ",Len(SF4->F4_CODIGO))
			EndIf
		EndIf
	EndIf
	If _nPsTES > 0 .And. _nPsCF > 0
		If !Empty(_aCols[ParamIXB,_nPsTES])
			aDadosCfo := {}
			SF4->(DbSetOrder(1))
			SF4->(DbSeek(xFilial("SF4")+_aCols[ParamIXB,_nPsTES],.F.))
			If SF4->F4_MSBLQL == "1" 
				_aCols[ParamIXB,_nPsTES] := PadR("   ",Len(SF4->F4_CODIGO))
			Else
				If At(M->C5_TIPO,"DB") == 0
					Aadd(aDadosCfo,{"OPERNF","S"})
					Aadd(aDadosCfo,{"TPCLIFOR",M->C5_TIPOCLI})
					Aadd(aDadosCfo,{"UFDEST",SA1->A1_EST})
					Aadd(aDadosCfo,{"INSCR" ,SA1->A1_INSCR})
					If SA1->(FieldPos("A1_CONTRIB")) > 0
						Aadd(aDadosCfo,{"CONTR", SA1->A1_CONTRIB})
					EndIf
				Else
					Aadd(aDadosCfo,{"OPERNF","S"})
					Aadd(aDadosCfo,{"TPCLIFOR",M->C5_TIPOCLI})
					Aadd(aDadosCfo,{"UFDEST",SA2->A2_EST})
					Aadd(aDadosCfo,{"INSCR" ,SA2->A2_INSCR})
				EndIf
				_aCols[ParamIXB,_nPsCF] := MaFisCfo(,SF4->F4_CF,aDadosCfo)
			EndIf
		EndIf
	EndIf
	If _nPsPrcBa > 0
		_aCols[ParamIXB,_nPsPrcBa] := Round(SCK->CK_PRCBAS,TamSX3("C6_PRCBAS")[2])
	EndIf
	If _nPsPrcBa > 0 .And. _nPsPrcVe > 0 .And. SCJ->CJ_CONDPAG == "000" .And. SCJ->CJ_EMISSAO > Ctod("12/04/2015")
		_aCols[ParamIXB,_nPsPrcVe] := Round(SCK->CK_PRCBAS,TamSX3("C6_PRCVEN")[2])
		_aCols[ParamIXB,_nPsValor] := Round(_aCols[ParamIXB,_nPsQtdVe] * _aCols[ParamIXB,_nPsPrcVe],TamSX3("C6_VALOR")[2])
	EndIf

	If 	_nPsPrcVe > 0 .And. _nPsLcrBr > 0
		Private _nPrcVen  := _aCols[ParamIXB,_nPsPrcVe]
		Private _cProduto := _aCols[ParamIXB,_nPsProdu]
		If FWCodEmp()+FWCodFil() == "0102" /// Cobrecom 3 Lagoas
			Private _nCustd   := Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_CUSTD3L")
		Else
			Private _nCustd   := Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_CUSTD")
		EndIf
		_aCols[ParamIXB,_nPsLcrBr] := If(_nCustd==0,0,((_nPrcVen*100)/_nCustd)-100)
		If _nPsCstRg > 0
			_aCols[ParamIXB,_nPsCstRg] := _nCustd
		EndIf
	EndIf

	/* 02/02/16 - REGRAS DE INDUSTRIALIZAÇÃO (SINCRONIZAR (SCJ-SC5))*/
	u_PE410SYNC()

	/* 04/04/16 -  ORÇAMENTO PORTAL (Nro Reserva) (SINCRONIZAR(SCK COM SC6) */
	u_BudgetMngr('ORD')
	
	/*LEONARDO 17/07/17 -  PROJETO VAREJO (SINCRONIZAR(SCJ COM SC5) */
		U_varejSyn()
	/*FIM LEONARDO */

Return(.T.)

/*/{Protheus.doc} MT415AUT
@author legado
@since 24/07/2017
@version 0.0
@type function
@description Valida se o orçamento pode ser efetivado 
Varificar se o cliente não é o padrão de orçamento e se este está revisto
/*/
User Function MT415AUT()
	_Volta := .T.
	_cTesCli := " "
	If SCJ->CJ_CLIENTE + SCJ->CJ_LOJA == Left(GetMv("MV_ORCLIPD"),Len(SCJ->CJ_CLIENTE + SCJ->CJ_LOJA)) .Or.;
	Empty(SCJ->CJ_CLIENTE) .Or. Empty(SCJ->CJ_LOJA)
		Alert("Somente Efetivar Orçamentos com Cliente Correto")
		_Volta := .F.
	Else
		SA1->(DbSetOrder(1))
		If SA1->(!DbSeek(xFilial("SA1")+SCJ->CJ_CLIENTE + SCJ->CJ_LOJA,.F.))
			Alert("Cliente Não Cadastrado")
			_Volta := .F.
		ElseIf SA1->A1_REVIS # "1"
			Alert("Atenção -> Cadastro do Cliente Deve ser Revisto")
			_Volta := .F.
		EndIf
	EndIf
	If _Volta
		_Volta := u_MY415Aut()
	EndIf
	If _Volta
		_aArea := GetArea()
		DbSelectArea("SCK")
		_aAreack := GetArea()

		SCK->(DbSetOrder(1)) // CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO
		SCK->(DbSeek(xFilial("SCK") + SCJ->CJ_NUM,.F.))
		Do While SCK->CK_FILIAL == xFilial("SCK") .And. SCK->CK_NUM == SCJ->CJ_NUM .And. SCK->(!Eof())
			If SCK->CK_FILVEN # cFilAnt .Or. SCK->CK_FILENT # cFilAnt .And. Empty(SCK->CK_NUMPV)
				RecLock("SCK",.F.)
				SCK->CK_FILVEN := cFilAnt
				SCK->CK_FILENT := cFilAnt
				MsUnLock()
			EndIf
			SCK->(DbSkip())
		EndDo
		RestArea(_aAreack)
		RestArea(_aArea)
	EndIf
Return(_Volta)

User Function ValOrc()

	If !MsgBox("Esta rotina lê arquivo ORC.DTC na Pasta Condusul e lança no orçamento"+Chr(13)+Chr(13)+;
	"Deverá conter os seguintes campos PROD, QUANT, ACOND, TES , LOCAL, VUNIT","Confirma?","YesNo")
		Return(.T.)
	EndIf

	DbSelectArea("SB1")
	DbSetOrder(1)

	_nTot1 := 0
	_nTot2 := 0

	DbSelectArea("TMP1")
	Zap

	_cItem := StrZero(0,Len(TMP1->CK_ITEM))
	_nitem := 0

	DbUseArea(.T.,"CTREECDX","\CONDUSUL\ORC.DTC","TXB",.T.,.F.)
	DbSelectArea("TXB")

	_cInd := CriaTrab(Nil, .F.)
	IndRegua("TXB", _cInd, "PROD+ACOND",,, "Selecionando Registros...")

	DbGoTop()
	Do While TXB->(!Eof()) .And. _nItem++ < 300 // 150

		_cProd  := TXB->PROD
		_cAcond := TXB->ACOND
		_cTES   := TXB->TES
		_cLocal := TXB->LOCAL

		If 	Type("TXB->PROD")=="N"
			_cMProd := Left(AllTrim(Str(TXB->PROD,TAMSX3("B1_COD")[1])) + Space(TAMSX3("B1_COD")[1]),TAMSX3("B1_COD")[1])
		Else
			_cMProd := Left(AllTrim(TXB->PROD)+Space(TAMSX3("B1_COD")[1]),TAMSX3("B1_COD")[1])
		EndIf

		If 	Type("TXB->QUANT")#"N"
			_nMQtd  := Val(TXB->QUANT)
		Else
			_nMQtd  := TXB->QUANT
		EndIf

		If 	Type("TXB->VUNIT")#"N"
			_nMvlUn := Val(TXB->VUNIT)
		Else
			_nMvlUn := TXB->VUNIT
		EndIf
		_cMAcon := AllTrim(TXB->ACOND)

		If !SB1->(DbSeek(xFilial("SB1") + _cMProd,.F.)) .Or.;
		_nMQtd <= 0 .Or. Empty(Left(_cMAcon,1)) .Or.;
		Val(Right(_cMAcon,5)) <= 0 .Or. _nMvlUn <= 0

			DbSelectArea("TXB")
			Reclock("TXB",.F.)
			DbDelete()
			MsUnLock()
			TXB->(DbSkip())
			_nItem--
			Loop
		EndIf

		_nMQtdt := 0
		Do While TXB->PROD == _cProd .And. TXB->ACOND == _cAcond .And. TXB->(!Eof())
			If 	Type("TXB->QUANT")#"N"
				_nMQtdt  += Val(TXB->QUANT)
			Else
				_nMQtdt  += TXB->QUANT
			EndIf

			Reclock("TXB",.F.)
			DbDelete()
			MsUnLock()
			TXB->(DbSkip())
		EndDo

		_cItem := Soma1(_cItem,,.T.)

		DbSelectArea("TMP1")
		dbAppend()
		For nCont := 1 To Len(aHeader)
			_PosTMP  := FieldPos(aHeader[nCont,2])
			_PosSCK  := SCK->(FieldPos(aHeader[nCont,2]))
			If _PosSCK > 0
				If (aHeader[nCont,08] <> "M" .And. aHeader[nCont,10] <> "V" )
					DbSelectArea("TMP1")
					_cCnt := CriaVar(aHeader[nCont,2])
					FieldPut(_PosTMP,_cCnt)
				EndIf
			Else
				xxx := 1
			EndIf
		Next nCont
		TMP1->CK_ITEM := _cItem
		TMP1->CK_FLAG := .F.

		// Executa o gatilho do CK_PRODUTO
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1") + _cMProd,.F.))

		M->CK_PRODUTO := _cMProd
		TMP1->CK_PRODUTO := _cMProd
		DbSelectArea( "SX3" )
		DbSetOrder(2)
		DbSeek("CK_PRODUTO")
		_cValid := Upper(AllTrim(SX3->X3_VALID)) + If(!Empty(SX3->X3_VLDUSER)," .AND. " + Upper(AllTrim(SX3->X3_VLDUSER)),"")
		_lVoltaVld := .T.
		If !Empty(_cValid)
			_lVoltaVld := &(_cValid)
		EndIf
		If _lVoltaVld .And. ExistTrigger("CK_PRODUTO")
			DbSelectArea("TMP1")
			RunTrigger(2,,,,"CK_PRODUTO")
		EndIf
		TMP1->CK_ACONDIC := Left(_cMAcon,1)
		TMP1->CK_METRAGE := Val(Right(_cMAcon,5))
		TMP1->CK_LANCES  := _nMQtdt / TMP1->CK_METRAGE
		TMP1->CK_TES     :=	_cTES
		TMP1->CK_LOCAL   :=	TXB->LOCAL // "501" // "521" // "849" //

		// Executa o gatilho do CK_QTDVEN
		M->CK_QTDVEN  := _nMQtdt 
		TMP1->CK_QTDVEN  := _nMQtdt
		DbSelectArea( "SX3" )
		DbSetOrder(2)
		DbSeek("CK_QTDVEN")
		_cValid := Upper(AllTrim(SX3->X3_VALID)) + If(!Empty(SX3->X3_VLDUSER)," .AND. " + Upper(AllTrim(SX3->X3_VLDUSER)),"")
		Do While "  " $ _cValid
			_cValid := StrTran(_cValid,"  "," ")
		EndDo
		If "POSITIVO() .AND." $ _cValid
			_cValid := AllTrim(StrTran(_cValid,"POSITIVO() .AND.",""))
		EndIf
		_lVoltaVld := .T.
		If !Empty(_cValid)
			_lVoltaVld := &(_cValid)
		EndIf
		If _lVoltaVld .And. ExistTrigger("CK_QTDVEN")
			DbSelectArea("TMP1")
			RunTrigger(2,,,,"CK_QTDVEN")
		EndIf

		// Executa o gatilho do CK_PRCVEN
		M->CK_PRCVEN  := _nMVlUn
		TMP1->CK_PRCVEN := _nMVlUn
		DbSelectArea( "SX3" )
		DbSetOrder(2)
		DbSeek("CK_PRCVEN")
		_cValid := Upper(AllTrim(SX3->X3_VALID) + If(!Empty(SX3->X3_VLDUSER),If(!Empty(SX3->X3_VALID)," .AND. ","") + AllTrim(SX3->X3_VLDUSER),""))

		If "POSITIVO()" $ _cValid
			_cValid := StrTran(_cValid,"POSITIVO()","POSITIVO('CK_PRCVEN')")
		EndIf
		_lVoltaVld := .T.
		If !Empty(_cValid)
			_lVoltaVld := &(_cValid)
		EndIf
		If _lVoltaVld .And. ExistTrigger("CK_PRCVEN")
			DbSelectArea("TMP1")
			RunTrigger(2,,,,"CK_PRCVEN")
		EndIf
		_nTot1 += (TMP1->CK_QTDVEN*TMP1->CK_PRUNIT)
		_nTot2 += TMP1->CK_VALOR
		DbSelectArea("TXB")
	EndDo
	Alert("Incluído "  + AllTrim(Str(_nItem-1,10)) + " Itens")
	DbSelectArea("TXB")
	DbCloseArea()
	DbSelectArea("TMP1")
Return(.T.)

User Function MudaLB()
	Local   lRet      := .T.
	Local   nRetAviso := 0
	Local   cRetAviso := ""
	Private aRet      := {}
	Private aParamBox := {}
	Private cCadastro := "Alteração LB"

	If !RecLock("SCJ",.F.)
		Alert("Orçamento Não Disponível Para Alteração")
		Return(.T.)
	EndIf
	If ( !SCJ->CJ_STATUS $ "A#D#E#F" )
		MsUnLock()
		Alert("Orçamento Não Pode Ser Alterado")
		Return(.T.)
	EndIf
	_cNomCli := Posicione("SA1",1,xFilial("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,"A1_NOME")
	_nTotVen  := 0.00 // Vlr. Total vendido
	_nTotCus  := 0.00 // Vlr. Total Custo
	_nLUCROBR := 0.00 // LB Total (médio)

	SB1->(DbSetOrder(1))
	SCK->(DbSetOrder(1)) // CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO
	SCK->(DbSeek(xFilial("SCK") + SCJ->CJ_NUM,.F.))
	Do While SCK->CK_FILIAL == xFilial("SCK") .And. SCK->CK_NUM == SCJ->CJ_NUM .And. SCK->(!Eof())
		_cProduto := SCK->CK_PRODUTO
		SB1->(DbSeek(xFilial("SB1")+_cProduto,.F.))

		// Recalcula o LB
		If FWCodEmp()+FWCodFil() == "0102" // 3 lagoas
			_nCustd := SB1->B1_CUSTD3L
		Else
			_nCustd := SB1->B1_CUSTD
		EndIf
		_nTotVen += SCK->CK_QTDVEN * SCK->CK_PRCVEN
		_nTotCus += SCK->CK_QTDVEN * _nCustd
		SCK->(DbSkip())
	EndDo

	_nLUCROBR := Round((((_nTotVen/_nTotCus)*100)-100),2)
	_nNewLB := 0

	aAdd(aParamBox,{1,"Nro. do Orçamento...:",SCJ->CJ_NUM,"","","",".F.",0,.F.})
	aAdd(aParamBox,{1,"Nome do Cliente.....:",_cNomCli,"","","",".F.",0,.F.})
	aAdd(aParamBox,{1,"Vlr.Total Orçamento.:",_nTotVen ,"@E 9,999,999.99","","",".F.",0,.F.})
	aAdd(aParamBox,{1,"LB do Orçamento.....:",_nLUCROBR,"@E 999.99","","",".F.",0,.F.})
	aAdd(aParamBox,{1,"Novo LB do Orçamento:",_nNewLB  ,"@E 999.99","","","",0,.F.})

	If !ParamBox(aParamBox, "Parametros", @aRet)
		MsUnLock()
		Alert("Operação Cancelada")
		Return(.T.)
	EndIf

	_nNewLB := aRet[5]
	If !MsgBox("Confirma a Alteração do LB para " + AllTrim(Str(_nNewLB,12,2)) + " ?","Confirma?","YesNo")
		MsUnLock()
		Return(.T.)
	EndIf

	_nPercDf := ((((_nTotVen / ((100 + _nLUCROBR) / 100)  * ((100 + _nNewLB) / 100)) / _nTotVen) - 1 ) * 100)

	SCK->(DbSeek(xFilial("SCK") + SCJ->CJ_NUM,.F.))
	Do While SCK->CK_FILIAL == xFilial("SCK") .And. SCK->CK_NUM == SCJ->CJ_NUM .And. SCK->(!Eof())
		_nMVlUn := SCK->CK_PRCVEN
		_nVlDif := Round((_nMVlUn * Abs(_nPercDf))/100,4)
		If _nPercDf > 0
			_nMVlUn += _nVlDif
		Else
			_nMVlUn -= _nVlDif
		EndIf
		RecLock("SCK",.F.)
		SCK->CK_PRCVEN := Round(_nMVlUn,TamSX3("CK_PRCVEN")[2])
		SCK->CK_VALOR := Round((SCK->CK_QTDVEN * SCK->CK_PRCVEN),TamSX3("CK_VALOR")[2])
		MsUnLock()
		SCK->(DbSkip())
	EndDo
	DbSelectArea("SCJ")
	MsUnLock()
	Alert("Cálculo Efetuado!")
Return(.T.)

User Function VlPrSCK()
	Local _lVolta := .T.
	SB1->(DbSetOrder(1))
	_cProduto := u_PrdNacion(M->CK_PRODUTO)
	If SB1->(DbSeek(xFilial("SB1")+_cProduto,.F.))
		If SB1->B1_BLQVEN == "S" .And. !"ADMINISTRADOR" $ Upper(cUserName)
			Alert("Produto Bloqueado Para Venda!!!!")
			_lVolta := .F.
		EndIf
	EndIf
Return(_lVolta)

Static Function	VjaValid(_cCampo)
	_nTamCpo := Len(SX3->X3_CAMPO)
	_cCampo := Left(AllTrim(_cCampo) + Space(_nTamCpo),_nTamCpo)
	DbSelectArea( "SX3" )
	DbSetOrder(2)
	DbSeek(_cCampo)
	_cValid := Upper(	"(" + ;
	If(Empty(SX3->X3_VALID),".T.",AllTrim(SX3->X3_VALID)) + ;
	") .AND. (" + ;
	If(Empty(SX3->X3_VLDUSER),".T.",AllTrim(SX3->X3_VLDUSER)) + ;
	")")
	If "POSITIVO()" $ _cValid
		_cValid := AllTrim(StrTran(_cValid,"POSITIVO()","POSITIVO(M->"+AllTrim(_cCampo)+")"))
	EndIf
	If "VAZIO()" $ _cValid
		_cValid := AllTrim(StrTran(_cValid,"VAZIO()","VAZIO(M->"+AllTrim(_cCampo)+")"))
	EndIf
	If ("U_CDFATV01" $ _cValid .Or. "U_CDFATV02"  $ _cValid) .And. '"OR"' $ _cValid
		_cValid := AllTrim(StrTran(_cValid,'"OR"','"ORX"'))
	EndIf
	_lVoltaVld := &(_cValid)
	If _lVoltaVld .And. ExistTrigger(_cCampo)
		DbSelectArea("TMP1")
		RunTrigger(2,,,,_cCampo)
	EndIf
Return(_lVoltaVld)

/*/{Protheus.doc} AtuPortal
@author legado
@since 24/07/2017
@version 0.0
@type function
@description
Função para Atualizar ZZJ/ZZK (Orçamento Portal) com as alterações realizadas em SCJ/SCK (Orçamento Protheus)
Lógica utilizada:
1-Verifica se existe ZZJ/ZZK
2-Trava ZZJ/ZZK
3-Exclui ZZJ/ZZK atuais
4-Inclui ZZJ/ZZK alterados no Protheus
5-Enviar e-mail avisando representante que o orçamento foi alterado
Relacionamentos:
SCK                          SCJ                            ZZJ                           ZZK
SCK->CK_NUM <--------------> SCJ->CJ_NUM <------------>ZZJ->ZZJ_CJNUM/ZZJ->ZZJ_ID <------> ZZK->ZZK_ID
/*/
User Function AtuPortal()

	Local lRetorno := .T.
	Local cMsgEmail :=""
	Local nZZJTotal := 0

	//Preservas as areas utilizadas
	Local _aArea		:= GetArea()
	Local _aAreaTMP1	:= TMP1->(GetArea())
	Local _aAreaSCJ		:= SCJ->(GetArea())
	Local _aAreaSCK 	:= SCK->(GetArea())
	Local _aAreaZZJ		:= ZZJ->(GetArea())
	Local _aAreaZZK		:= ZZK->(GetArea())
	Local _aAreaSA3		:= SA3->(GetArea())

	Public lOrcAlterou

	dbselectarea("ZZJ")
	ZZJ->(dbsetorder(2))	//ZZJ_FILIAL, ZZJ_CJNUM
	dbselectarea("ZZK")
	ZZK->(dbsetorder(1))	//ZZK_FILIAL, ZZK_ID, R_E_C_N_O_, D_E_L_E_T_

	//Verifica se existe ZZJ
	If  ZZJ->(dbseek( xFilial("ZZJ") + M->CJ_NUM, .F. ) )

		BeginTran()
		If ZZJ->(rlock())
			//Procura os itens do pedido na tabela ZZK, para exluir
			If ZZK->(dbseek(xFilial("ZZK")+ ZZJ->ZZJ_ID, .F.))
				While  ZZK->ZZK_ID == ZZJ->ZZJ_ID .and. !(ZZK->(eof()))
					If  ZZK->(rlock())
						ZZK->(dbDelete())
						ZZK->(msunlock())
						ZZK->(DbSkip())
					Else
						lRetorno := .F.
						cMsg := "[ERRO] Não conseguiu deletar ZZK. Comunique o Departamento de TI-Cobrecom."
						Exit
					EndIf
				EndDo
			Else
				lRetorno := .F.
				cMsg := "[ERRO] Não encontrou ZZK para deletar. Comunique o Departamento de TI-Cobrecom."
			EndIf

		Else
			MsgBox("[ALERTA] Não conseguiu travar orçamento do Portal (ZZJ). Tente novamente.","ATENÇÃO","ALERT")
			lRetorno := .F.
		EndIf

		If lRetorno

			DbSelectarea("TMP1")
			DbGoTop()
			While TMP1->(!eof())
				If !TMP1->(CK_FLAG)
					reclock("ZZK", .T.)
					ZZK->ZZK_FILIAL	:= ZZJ->(ZZJ_FILIAL)
					ZZK->ZZK_ID		:= ZZJ->(ZZJ_ID)
					ZZK->ZZK_COD	:= TMP1->(CK_PRODUTO)
					ZZK->ZZK_QTDVEN	:= TMP1->(CK_QTDVEN)
					ZZK->ZZK_PRCVEN	:= TMP1->(CK_PRCVEN)
					ZZK->ZZK_LANCES	:= TMP1->(CK_LANCES)
					ZZK->ZZK_METRAG	:= TMP1->(CK_METRAGE)
					ZZK->ZZK_VALOR	:= TMP1->(CK_VALOR)
					ZZK->ZZK_COMIS	:= TMP1->(CK_COMIS1)
					ZZK->ZZK_ACONDI	:= TMP1->(CK_ACONDIC)
					ZZK->ZZK_DESCDG	:= TMP1->(CK_XDESCDG)
					ZZK->ZZK_ZEROCM	:= TMP1->(CK_XZERACM)
					ZZK->ZZK_STATUS	:= TMP1->(CK_STSITE)
					ZZK->ZZK_TES	:= TMP1->(CK_TES)
					nZZJTotal += ZZK->ZZK_VALOR
					ZZK->(msunlock())
				Endif
				TMP1->(DbSkip())
			EndDo
			//Trava o registro para alteração
			reclock("ZZJ", .F.)
			ZZJ->ZZJ_FILIAL		:= M->(CJ_FILIAL)
			ZZJ->ZZJ_ID			:= M->(CJ_XZZJID)
			ZZJ->ZZJ_CLIENT		:= M->(CJ_CLIENTE)
			ZZJ->ZZJ_LOJA		:= M->(CJ_LOJA)
			ZZJ->ZZJ_TABELA		:= M->(CJ_TABELA)
			ZZJ->ZZJ_TRANSP		:= M->(CJ_TRANSP)
			ZZJ->ZZJ_VEND1		:= M->(CJ_VEND1)
			ZZJ->ZZJ_CONDPG		:= M->(CJ_CONDPAG)
			ZZJ->ZZJ_TPFRETE	:= M->(CJ_TPFRETE)
			ZZJ->ZZJ_ENDENT		:= M->(CJ_ENDENT1)
			ZZJ->ZZJ_MSGAPR		:= M->(CJ_OBSAPR)
			ZZJ->ZZJ_MSGREP		:= M->(CJ_OBSREPR)
			ZZJ->ZZJ_TOTAL		:= nZZJTotal
			ZZJ->ZZJ_FILORI		:= M->(CJ_XFILVEN)
			ZZJ->ZZJ_STATUS		:= "F" 

			//Destrava ZZJ
			ZZJ->(msunlock())

			//Verifica se o orçamento foi alterado
			lOrcAlterou := u_orcFoiAlterado()

			//Finaliza a tranzação
			EndTran()

			//Enviar o e-mail somente se tiver alteração
			If lOrcAlterou
				Dbselectarea("SA3")
				SA3->( Dbsetorder(1))
				SA3->(Dbseek(xfilial("SA3")+ M->(CJ_VEND1), .F. ))

				//Monta o corpo do e-mail
				cMsgEmail += "Orçamento Nro. "
				cMsgEmail += M->CJ_NUM
				cMsgEmail += "  Alterado pelo departamento de Vendas da Cobrecom."
				cMsgEmail += "Devido esta alteração este orçamento retornou ao seu status inicial,"
				cMsgEmail += "sendo necessario enviar novamente ao ERP."

				//Verifica se o vendedor tem e-mail cadastrado
				If !empty(SA3->A3_EMAIL)

					//Envia o workflow de alteração para o vendedor e para Cobrecom
					u_cwf03( M->CJ_NUM, cMsgEmail, "Alteração Orçamento", lower(SA3->A3_EMAIL), M->CJ_CLIENTE, M->CJ_LOJA )
					u_cwf03( M->CJ_NUM, cMsgEmail, "Alteração Orçamento", GetMv("MV_USERMAI") , M->CJ_CLIENTE, M->CJ_LOJA )

				Else
					//Envia workflow quando o vendedor não tiver e-mail cadastrado
					u_cwf03( M->CJ_NUM, cMsgEmail, "Cliente sem E-mail Cadastrado", "wfti@cobrecom.com.br", M->CJ_CLIENTE, M->CJ_LOJA )
					u_cwf03( M->CJ_NUM, cMsgEmail, "Cliente sem E-mail Cadastrado", GetMv("MV_USERMAI") , M->CJ_CLIENTE, M->CJ_LOJA )
				EndIf
			EndIf
		Else
			DisarmTransaction()
		EndIf

	EndIf

	MsUnlockAll()
	RestArea(_aArea)
	RestArea(_aAreaTMP1)
	RestArea(_aAreaSCJ)
	RestArea(_aAreaSCK)
	RestArea(_aAreaZZJ)
	RestArea(_aAreaZZK)
	RestArea(_aAreaSA3)

Return(lRetorno)

/*/{Protheus.doc} MyA415Altera
@author legado
@since 24/07/2017
@version 0.0
@type function
@description 
Objetivo: Verificar se o orçamento selecionado é um orçamento do portal e se seu status não é "F"
caso seja F não exibir a tela de alteração exibindo uma mensagem, Status F significa que neste orçamento
houve uma alteração por parte do Protheus que não obteve aceite ainda por parte do portal
/*/
User Function MyA415Altera()
	Local lPode 		:= .T.
	Local _aArea		:= GetArea()
	Local _aAreaSCJ		:= SCJ->(GetArea())
	Local _aAreaSCK		:= SCK->(GetArea())
	Local _aAreaZZJ		:= ZZJ->(GetArea())
	Public _a415BNDES 	:= {} // Esta variável será usada no PE MA415BUT que indica que
	// os valores da tabela SCK devem ser corrigidos

	If !Empty(SCJ->(CJ_XZZJID))
		DbSelectArea("ZZJ")
		DbSetOrder(1)
		DbSeek(xFilial("ZZJ")+SCJ->(CJ_XZZJID),.F.)
		If ZZJ->ZZJ_STATUS == "F"
			lPode := .F.
		EndIf
	EndIf

	RestArea(_aArea)
	RestArea(_aAreaSCJ)
	RestArea(_aAreaZZJ)

	If lPode

		_a415BNDES := {} // Esta variável será usada no PE MA415BUT que indica que
		// os valores da tabela SCK devem ser corrigidos
		If Altera .And. SCJ->CJ_CONDPAG == "000" .And. SCJ->CJ_CONDPAG == "000" .And. SCJ->CJ_EMISSAO > Ctod("12/04/2015")
			DbSelectArea("SCK")
			DbSetOrder(1) //CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO
			DbSeek(xFilial("SCK")+SCJ->CJ_NUM,.F.)
			Do While SCK->CK_FILIAL == xFilial("SCK") .And. SCK->CK_NUM  == SCJ->CJ_NUM .And. SCK->(!Eof())
				AADD(_a415BNDES,{SCK->CK_ITEM,SCK->CK_PRCVEN,SCK->CK_VALOR})
				RecLock("SCK",.F.)
				SCK->CK_PRCVEN := Round(SCK->CK_PRCBAS,TamSX3("CK_PRCVEN")[2])
				SCK->CK_VALOR  := Round((SCK->CK_QTDVEN*SCK->CK_PRCVEN),TamSX3("CK_VALOR")[2])
				MsUnLock()
				SCK->(DbSkip())
			EndDo
		EndIf
		A415Altera("SCJ",SCJ->(Recno()),4)
	Else
		MessageBox("[AVISO]- Orçamento foi alterado recentemente, aguardando aceite do representante","Aviso",64)
	EndIf

Return(.T.)

/*/{Protheus.doc} orcFoiAlterado
@author legado
@since 24/07/2017
@version 0.0
@type function
@description
Verificar se ao fechar a tela de alteração de orçamento
de fato foi realziada alguma alteração, caso tenha sido feito
alguma alteração não pode exibir a tela com a opção alterar
pois esta alteração ainda não teve o aceite do vendedor atraves do portal
Retornando .F. quando não existiu alteração
.V. quando ocorreu alteração
/*/
User Function orcFoiAlterado()

	Local _lDifer 		:= .F.
	Local _nQtCpoTMP1
	Local _nQtCpoSCJ
	Local  nCntForTMP1
	Local  nCntForSCJ
	Local _cNmeCpoTMP1
	Local _Dado1TMP1
	Local _nPosSCK
	Local _Dado2SCK
	Local _aArea		:= GetArea()
	Local _aAreaTMP1	:= TMP1->(GetArea())
	Local _aAreaSCK	    := SCK->(GetArea())
	Local _aAreaSCJ	    := SCJ->(GetArea())

	//Procura por alterações no cabeçalho do orçamento
	_nQtCpoSCJ := SCJ->(FCount())

	For nCntForSCJ := 1 To _nQtCpoSCJ

		If AllTrim(SCJ->(FieldName(nCntForSCJ))) != "CJ_STATUS"

			_cmpMem := &("M->(" +AllTrim(SCJ->(FieldName(nCntForSCJ))) + ")")

			If ValType( _cmpMem ) # "U"
				If SCJ->(FieldGet(nCntForSCJ)) # _cmpMem
					_lDifer := .T.
					Exit
				EndIf
			EndIf
		EndIf
	Next

	If !_lDifer

		//Procura por alterações nos itens do orçamento SCK
		DbSelectArea("TMP1")
		_nQtCpoTMP1 := TMP1->(FCount())

		DbGoTop()
		Do While TMP1->(!Eof()) .And. !_lDifer
			If !TMP1->CK_FLAG // Não deletado
				SCK->(DbSetOrder(1)) //CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO
				If SCK->(DbSeek(xFilial("SCK") + M->CJ_NUM + TMP1->CK_ITEM,.F.))
					For nCntForTMP1 := 1 To _nQtCpoTMP1
						_cNmeCpoTMP1 := TMP1->(FieldName(nCntForTMP1))
						_Dado1TMP1   := TMP1->(FieldGet(nCntForTMP1))
						_nPosSCK     := SCK->(FieldPos(_cNmeCpoTMP1))
						If _nPosSCK <> 0
							_Dado2SCK    := SCK->(FieldGet(_nPosSCK))
							If _Dado1TMP1 # _Dado2SCK
								_lDifer := .T.
								Exit
							EndIF
						EndIf
					Next
				Else
					_lDifer := .T.
				EndIf
			Else
				_lDifer := .T.

			EndIf
			TMP1->(DbSkip())
		EndDo
	EndIf

	RestArea(_aAreaTMP1)
	RestArea(_aAreaSCK)
	RestArea(_aAreaSCJ)
	RestArea(_aArea)

Return(_lDifer)

User Function CorrOrc(_Ret)
	If M->CJ_CONDPAG == "000" .And. M->CJ_EMISSAO > Ctod("12/04/2015") .And. Altera
		DbSelectArea("TMP1")
		DbGoTop()
		Do While !Eof()
			TMP1->CK_PRCVEN := TMP1->CK_PRCBAS
			TMP1->CK_VALOR  := TMP1->CK_QTDVEN*TMP1->CK_PRCVEN
			TMP1->(DbSkip())
		EndDo
	EndIf
Return(_Ret)



User Function CbcWEdi(_lBotao)

	If Empty(M->CJ_CLIENTE) .Or. Empty(M->CJ_LOJA) .Or. Empty(M->CJ_TABELA)
		If _lBotao
			MsgAlert("Os Campos Cliente, Loja e Tabela devem estar preenchidos!","Atenção!")
		EndIf
		Return(.T.)
	EndIf
	_VarTXT := AllTrim(M->CJ_TEXTO)
	_VarNew := ""
	_cMProd := ""
	_nMQtd  := ""
	_cMAcon := ""
	_nMVlUn := ""
	_nTab   := 0
	_nLin   := 0
	_lVolta := .T.
	_nTot1 := 0
	_nTot2 := 0

	For _nPos := 1 to Len(_VarTXT)
		_cCarac := Substr(_VarTXT,_nPos,1)
		_cASCII := Asc(_cCarac)
		If _cASCII == 9 // TAB
			// Verificar qual TAB é e acumular na variável correta
			//2ndo TAB -> Código do produto
			//14o  TAB -> Quantidade com ponto de milhar e virgula decimal
			//16o  TAB -> Acondic
			//18o  TAB -> Valor Unitário com R$ na frente e  com ponto de milhar e virgula decimal
			_nTab++
			If _nTab == 02 //2ndo TAB -> Código do produto
				_cMProd := AllTrim(_VarNew)
				If Len(_cMProd) # 10
					Alert("Erro na Linha "+ AllTrim(Str(_nPos)) + " - Código do Produto Inválido")
					_lVolta := .F.
					Exit
				EndIf
				_cMProd := Left(AllTrim(_VarNew) + Space(Len(SCK->CK_PRODUTO)),Len(SCK->CK_PRODUTO))
				SB1->(DbSetOrder(1))
				If !SB1->(DbSeek(xFilial("SB1") + _cMProd,.F.))
					Alert("Erro na Linha "+ AllTrim(Str(_nPos)) + " - Código do Produto não Cadastrado")
					_lVolta := .F.
					Exit
				EndIf
			ElseIf _nTab == 14//14o  TAB -> Quantidade com ponto de milhar e virgula decimal
				_VarNew := Upper(_VarNew)
				_VarNew := StrTran(_VarNew,"R","")
				_VarNew := StrTran(_VarNew,"$","")
				_VarNew := StrTran(_VarNew,".","")
				_VarNew := StrTran(_VarNew,",",".")
				_VarNew := AllTrim(_VarNew)
				_nMQtd  := Val(_VarNew)
				If _nMQtd <= 0
					Alert("Erro na Linha "+ AllTrim(Str(_nPos)) + " - Quantidade Inválida")
					_lVolta := .F.
					Exit
				EndIf
			ElseIf _nTab == 16//16o  TAB -> Acondic
				_cMAcon := Left(AllTrim(Upper(_VarNew)),1)
				_VarNew := AllTrim(Upper(_VarNew))
				_VarNew := StrTran(_VarNew,_cMAcon,"")
				If Len (_VarNew) < 5
					_VarNew := StrZero(VAL(_VarNew),5)
				EndIf				
				If _cMAcon == "M" .And. SB1->B1_CARMAD <> VAL(_VarNew)
					_cMAcon := "B" + _VarNew					
				Else
					_cMAcon := _cMAcon + _VarNew
				EndIf	 
			ElseIf _nTab == 18 //18o  TAB -> Valor Unitário com R$ na frente e  com ponto de milhar e virgula decimal
				_VarNew := Upper(_VarNew)
				_VarNew := StrTran(_VarNew,"R","")
				_VarNew := StrTran(_VarNew,"$","")
				_VarNew := StrTran(_VarNew,".","")
				_VarNew := StrTran(_VarNew,",",".")
				_VarNew := AllTrim(_VarNew)
				_nMVlUn := Val(_VarNew)
				If _nMVlUn <= 0
					Alert("Erro na Linha "+ AllTrim(Str(_nPos)) + " - Valor Unitário Inválido")
					_lVolta := .F.
					Exit
				EndIf

				DbSelectArea("TMP1")
				// Adicionar linha no TMP1
				If ++_nLin == 1
					// Somente na primeira vez mata o conteúdo da tabela
					Zap
				EndIf

				dbAppend()
				For nCont := 1 To Len(aHeader)
					_PosTMP  := FieldPos(aHeader[nCont,2])
					_PosSCK  := SCK->(FieldPos(aHeader[nCont,2]))
					If _PosSCK > 0
						If (aHeader[nCont,08] <> "M" .And. aHeader[nCont,10] <> "V" )
							DbSelectArea("TMP1")
							_cCnt := CriaVar(aHeader[nCont,2])
							FieldPut(_PosTMP,_cCnt)
						EndIf
					Else
						xxx := 1
					EndIf
				Next nCont

				// A criação dos campos e a inclusão dos dados tem que ser na mesma ordem do aHeader
				_lVerAcon := .T.
				For nCont := 1 To Len(aHeader)
					If AllTRim(aHeader[nCont,2]) == "CK_ITEM"
						TMP1->CK_ITEM := StrZero(_nLin,Len(TMP1->CK_ITEM))
						TMP1->CK_FLAG := .F.
					ElseIf AllTRim(aHeader[nCont,2]) == "CK_ZZNRRES"
						TMP1->CK_ZZNRRES 	:=  Space(TamSx3("CK_ZZNRRES")[1])
						M->CK_ZZNRRES		:=	TMP1->CK_ZZNRRES
					ElseIf AllTRim(aHeader[nCont,2]) == "CK_PRODUTO"
						// Executa o gatilho do CK_PRODUTO
						SB1->(DbSetOrder(1))
						SB1->(DbSeek(xFilial("SB1") + _cMProd,.F.))

						M->CK_PRODUTO := _cMProd
						TMP1->CK_PRODUTO := _cMProd

						If SB1->B1_BLQVEN == "S" .Or. SB1->B1_MSBLQL == "1"
							//Alert("Erro na Linha "+ AllTrim(Str(_nPos)) + " - Produto Bloqueado Para Venda!!!!")
							Alert("Erro na Linha "+ AllTrim(Str(_nLin)) + " - Produto Bloqueado Para Venda!!!!")
							_lVolta := .F.
							Exit
						EndIf
						If !VjaValid("CK_PRODUTO")
							Alert("Erro na Linha "+ AllTrim(Str(_nLin)) + " - Produto Inválido")
							_lVolta := .F.
							Exit
						EndIf
					ElseIf AllTRim(aHeader[nCont,2]) == "CK_METRAGE"
						If 	_lVerAcon .And. !Empty(_cMAcon)
							TMP1->CK_METRAGE := VAL(Right(_cMAcon,5))
							M->CK_METRAGE    := TMP1->CK_METRAGE // esta variável tem que ser criada para a rotina de validação
							If !VjaValid("CK_METRAGE")
								_lVerAcon := .F.
								TMP1->CK_LANCES  := 0
								TMP1->CK_ACONDIC := " "
								TMP1->CK_METRAGE := 0
							EndIf
						EndIf
					ElseIf AllTRim(aHeader[nCont,2]) == "CK_LANCES"
						If 	_lVerAcon .And. !Empty(_cMAcon)
							TMP1->CK_LANCES  := _nMQtd / VAL(Right(_cMAcon,5))
							M->CK_LANCES  := TMP1->CK_LANCES // esta variável tem que ser criada para a rotina de validação
							If !VjaValid("CK_LANCES")
								_lVerAcon := .F.
								TMP1->CK_LANCES  := 0
								TMP1->CK_ACONDIC := " "
								TMP1->CK_METRAGE := 0
							EndIf
						EndIf
					ElseIf AllTRim(aHeader[nCont,2]) == "CK_ACONDIC"
						If 	_lVerAcon .And. !Empty(Left(_cMAcon,1))
							TMP1->CK_ACONDIC := Left(_cMAcon,1)
							M->CK_ACONDIC := TMP1->CK_ACONDIC// esta variável tem que ser criada para a rotina de validação
							If !VjaValid("CK_ACONDIC")
								_lVerAcon := .F.
								TMP1->CK_LANCES  := 0
								TMP1->CK_ACONDIC := " "
								TMP1->CK_METRAGE := 0
							EndIf
						EndIf
					ElseIf AllTRim(aHeader[nCont,2]) == "CK_QTDVEN"
						M->CK_QTDVEN     := _nMQtd
						TMP1->CK_QTDVEN  := _nMQtd
						If !VjaValid("CK_QTDVEN")
							M->CK_QTDVEN     := 0
							TMP1->CK_QTDVEN  := 0
						EndIf
					ElseIf AllTRim(aHeader[nCont,2]) == "CK_PRCVEN"
						M->CK_PRCVEN  := _nMVlUn
						TMP1->CK_PRCVEN := _nMVlUn

						If !VjaValid("CK_PRCVEN")
							M->CK_PRCVEN    := 0
							TMP1->CK_PRCVEN := 0
						EndIf
						_nTot1 += (TMP1->CK_QTDVEN*TMP1->CK_PRCVEN)
						_nTot2 += TMP1->CK_VALOR
					EndIf
				Next
				If !_lVolta
					Exit
				EndIf
			EndIf
			_VarNew := ""
			Loop
		ElseIf _cASCII == 13 .Or.  _cASCII == 10
			_nTab   := 0
			_VarNew := ""
			Loop
		EndIf
		_VarNew := _VarNew + _cCarac
	Next
	DbSelectArea("TMP1")
	DbGoBottom()
	If Recno() == 0
		_lVolta := .F.
		_nLin := 1
	EndIf
	If !_lVolta // Deu erro em algum campo
		Zap // Mata todos os registros
		// Cria novo Zerado
		dbAppend()
		For nCont := 1 To Len(aHeader)
			_PosTMP  := FieldPos(aHeader[nCont,2])
			_PosSCK  := SCK->(FieldPos(aHeader[nCont,2]))
			If _PosSCK > 0
				If (aHeader[nCont,08] <> "M" .And. aHeader[nCont,10] <> "V" )
					DbSelectArea("TMP1")
					_cCnt := CriaVar(aHeader[nCont,2])
					FieldPut(_PosTMP,_cCnt)
				EndIf
			Else
				xxx := 1
			EndIf
		Next nCont
		TMP1->CK_ITEM := StrZero(_nLin,Len(TMP1->CK_ITEM))
		TMP1->CK_FLAG := .F.
	EndIf
	DbGoTop()

	If ValType(oGetDB) <> "U"
		oGetDB:nCount:=_nLin
		oGetDB:lNewLine:=.F.

		If _lVolta
			u_BudgetMngr('EXL')
		EndIf

	EndIf

Return( .T. )
