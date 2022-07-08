#include "rwmake.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CDFINA05  ³ Autor ³ Roberto Oliveira      ³ Data ³ 12/08/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Montagem de Caixas                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CDFINA05()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
************************
User Function CDFINA05()
	************************
	*
	Private _cFiltro

	aRotina := {{ "Pesquisar"  , "AxPesqui"  		, 0 , 1	},;
	{ "Visualizar" , "AxVisual"  		, 0 , 2	},;
	{ "Incl.Caixa" , "u_CdFi5B()"		, 0 , 3	},;
	{ "Excl.Caixa" , "u_CdFi5E()"		, 0 , 4	},;
	{ "Incl.Item"  , "u_CdFi5I"  		, 0 , 3	},;
	{ "Altera Item", "u_AltFina05()"  	, 0 , 4	},;
	{ "Exclui Item", "u_CdFi5D()"		, 0 , 5	},;
	{ "Transf.C/C" , "u_fecharCC()"		, 0 , 4	}}
	//{ "Transf.C/C" , "u_CdFi5T()"		, 0 , 4	}} LINHA ORIGINAL

	Private cString := "SZM"
	cCadastro := "Caixas"

	dbSelectArea(cString)
	dbSetOrder(1)
	DbSeek(xFilial(cString),.F.)

	mBrowse(001,040,200,390,cString,,,,,,)

	Return(.T.)
	*
	**********************
User Function CdFi5B() //ok
	**********************
	*
	cPerg := "CDFI05B"
	VldPerg()
	If !u_ParCx()
		Return(.T.)
	EndIf

	dbSelectArea("SX3")
	dbSetOrder(2)
	aCampos:= {	{"E2_OK"     ,"","  "}}

	DbSeek("E2_FORNECE")
	AADD(aCampos,{  x3_campo,"", TRIM(X3Titulo()),x3_picture } )
	DbSeek("E2_NOMFOR")
	AADD(aCampos,{  x3_campo,"", TRIM(X3Titulo()),x3_picture } )
	DbSeek("E2_NATUREZ")
	AADD(aCampos,{  x3_campo,"", TRIM(X3Titulo()),x3_picture } )
	DbSeek("E2_EMISSAO")
	AADD(aCampos,{  x3_campo,"", TRIM(X3Titulo()),x3_picture } )
	DbSeek("E2_VENCTO")
	AADD(aCampos,{  x3_campo,"", TRIM(X3Titulo()),x3_picture } )
	DbSeek("E2_VENCREA")
	AADD(aCampos,{  x3_campo,"", TRIM(X3Titulo()),x3_picture } )
	DbSeek("E2_VALOR")
	AADD(aCampos,{  x3_campo,"", TRIM(X3Titulo()),x3_picture } )
	DbSeek("E2_HIST")
	AADD(aCampos,{  x3_campo,"", TRIM(X3Titulo()),x3_picture } )
	DbSeek("E2_TIPO")
	AADD(aCampos,{  x3_campo,"", TRIM(X3Titulo()),x3_picture } )
	DbSeek("E2_NUM")
	AADD(aCampos,{  x3_campo,"", TRIM(X3Titulo()),x3_picture } )

	DbSelectArea("SE2")
	DbSetOrder(1)

	cCadastro:="Inclusão de Caixa"
	aRotina := {{ "Pesquisar" ,"AxPesqui"  , 0 , 1},;
	{ "Parâmetros","U_ParCx"   , 0 , 2},;
	{ "Confirma"  ,"U_FecharCx", 0 , 2} }

	lInverte:=.F.
	cMarca := GetMark()
	//mBrowse(001,040,200,390,"SBF",aCampos,,,,,)
	DbSelectArea("SE2")
	DbSetOrder(1)
	MarkBrow("SE2","E2_OK",,aCampos,@lInverte,@cMarca,,,,,)
	dbSelectArea("SE2")
	Set Filter to
	dbSetOrder(1)

	cCadastro := "Caixas"
	dbSelectArea(cString)
	dbSetOrder(1)
	Return(.T.)
	*
	*************************
Static Function VldPerg()
	*************************
	*
	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Caixa Numero              ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Do Vencimento             ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Até o Vencimento          ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Unid.Pagamento            ?","mv_ch4","N",01,0,0,"C","","mv_par04","Itu","","","","","São Paulo","","","","","","","","",""})

	For i := 1 To Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2],.F.)
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
	Return(.T.)
	*
	*********************
User Function ParCx()
	*********************
	*
	_Volta := .T.
	cPerg := "CDFI05B"
	Do While _Volta
		DbSelectArea("SZM")
		DbSetOrder(1) // ZM_FILIAL+SMZ->ZM_NUMCX
		_Volta := Pergunte(cPerg,.T.)
		MV_PAR04 := Str(MV_PAR04,1)
		If _Volta
			If DbSeek(xFilial("SZM")+MV_PAR01,.F.)
				Alert("Nro da Caixa já Existe")
				Loop
			ElseIf MV_PAR02 > MV_PAR03 .Or. (Empty(MV_PAR02) .And. Empty(MV_PAR03))
				Alert("Corrigir a Abrangência das Datas de Vencimento")
				Loop
			EndIf
		EndIf
		Exit
	EndDo
	DbSelectArea("SE2")
	Set Filter to
	If _Volta
		_cFiltro := "E2_FILIAL == '" + xFilial("SE2") + "' .And. " + 'E2_NUMCX == "      " .And. DTOS(E2_VENCREA) >= "'+DTOS(MV_PAR02)+;
		'" .And. DTOS(E2_VENCREA) <= "'+DTOS(MV_PAR03)+'" .And. !E2_TIPO $ "'+MVABATIM+;
		"/"+MVPROVIS+"/"+MVRECANT+"/"+MV_CPNEG+'" .And. E2_UNPAG == "'+MV_PAR04+;
		'" .And. (Empty(E2_FATURA) .Or. (E2_SALDO == 0 .And. !Empty(E2_FATURA) .And. !"NOTFAT" $ E2_FATURA))'

		Set Filter to &_cFiltro.

		//	Set Filter to E2_NUMCX == "      " .And. E2_VENCREA >= MV_PAR02 .And. E2_VENCREA <= MV_PAR03 .And.;
		//			      !E2_TIPO $ MVABATIM+"/"+MVPROVIS+"/"+MVRECANT+"/"+MV_CPNEG .And. E2_UNPAG == MV_PAR04 .And. ;
		//				  (Empty(E2_FATURA) .Or. (E2_SALDO == 0 .And. !Empty(E2_FATURA) .And. !"NOTFAT" $ E2_FATURA))
		DbSeek(xFilial("SE2"),.F.)
	EndIf
	Return(_Volta)
	*
	************************
User Function FecharCx()
	************************
	*
	If !MsgBox("Confirma a Inclusão do Caixa?","Confirma?","YesNo")
		Return(.T.)
	EndIf

	DbSelectArea("SEV")
	DbSetOrder(1)//EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_NATUREZ

	DbSelectArea("SE2")
	DbSetOrder(1)//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	Set Filter to
	Set Filter to E2_NUMCX == "      " .And. E2_VENCREA >= MV_PAR02 .And. E2_VENCREA <= MV_PAR03 .And. ((Empty(E2_FATURA)) .Or. (E2_SALDO == 0 .And. !Empty(E2_FATURA) .And. !"NOTFAT" $ E2_FATURA))

	DbSeek(xFilial("SE2"),.T.)
	Do While SE2->E2_FILIAL == xFilial("SE2") .And. SE2->(!Eof())
		//If Marked("E2_OK") 
		// Troquei o IF acima pois estava dando como marcado registros não marcados.
		If SE2->E2_OK == cMarca
			GravaSZM(MV_PAR01)
			DbSelectArea("SE2")
			RecLock("SE2",.F.)
			SE2->E2_NUMCX := MV_PAR01
			MsUnLock()
		EndIf
		DbSkip()
	EndDo

	If !u_ParCx()
		CLOSEBROWSE()
	EndIf

	Return(.T.)
	*
	**********************
User Function CdFi5E()
	**********************
	*
	If SZM->ZM_STATUS == "D" // Deposito ja realizado
		Alert("Cancelamento não Efetuado -> Depósito já Realizado!!")
		Return(.T.)
	ElseIf !MsgBox("Confirma a Exclusão do Caixa " + SZM->ZM_NUMCX +" ?","Confirma?","YesNo")
		Return(.T.)
	EndIf
	_cNumCx := SZM->ZM_NUMCX
	DbSelectArea("SE2")
	DbSetOrder(1)

	DbSelectArea("SZM")
	DbSetOrder(1) // ZM_FILIAL+SMZ->ZM_NUMCX
	DbSeek(xFilial("SZM")+_cNumCx,.F.)
	Do While SZM->ZM_FILIAL == xFilial("SZM") .And. SZM->ZM_NUMCX == _cNumCx .And. SZM->(!Eof())
		DbSelectArea("SE2")
		If DbSeek(xFilial("SE2") + SZM->ZM_PREFIXO+SZM->ZM_NUMERO+SZM->ZM_PARCELA+SZM->ZM_TIPO+SZM->ZM_FORNEC+SZM->ZM_LOJA,.F.)
			If !Empty(SE2->E2_NUMCX)
				RecLock("SE2",.F.)
				SE2->E2_NUMCX  := "        "
				MsUnLock()
			EndIf
		EndIf

		DbSelectArea("SZM")
		RecLock("SZM",.F.)
		DbDelete()
		MsUnLock()
		SZM->(DbSeek(xFilial("SZM")+_cNumCx,.F.))
	EndDo
	Return(.T.)
	*
	**********************
User Function CdFi5I()
	**********************
	*
	*
	If SZM->ZM_STATUS == "D" // Deposito ja realizado
		Alert("Inclusão não Permitida -> Depósito já Realizado!!")
		Return(.T.)
	EndIf
	nOpca := AxInclui("SZM",0,3, , , ,)
	If nOpca == 1
		DbSelectArea("SEV")
		DbSetOrder(1)//EV_FILIAL+EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA+EV_NATUREZ

		DbSelectArea("SE2")
		DbSetOrder(1)
		If SE2->(DbSeek(xFilial("SE2")+SZM->ZM_PREFIXO+SZM->ZM_NUMERO+SZM->ZM_PARCELA+SZM->ZM_TIPO+SZM->ZM_FORNEC+SZM->ZM_LOJA,.F.))
			RecLock("SE2",.F.)
			SE2->E2_NUMCX := SZM->ZM_NUMCX
			MsUnLock()
		EndIf

		If SE2->E2_MULTNAT == "1"
			RecLock("SZM",.F.)
			DbDelete()
			MsUnLock()
			GravaSZM(SZM->ZM_NUMCX)
		EndIf

	EndIf
	DbSelectArea("SZM")
	Return(.T.)
	*
	**********************
User Function CdFi5D()
	**********************
	*
	If SZM->ZM_STATUS == "D" // Deposito ja realizado
		Alert("Exclusão não Permitida -> Depósito já Realizado!!")
		Return(.T.)
	ElseIf MsgBox("Confirma a Exclusão do Item do Caixa?","Confirma?","YesNo")
		DbSelectArea("SZM")
		_cCaixa := SZM->ZM_NUMCX
		_cChave := SZM->ZM_PREFIXO+SZM->ZM_NUMERO+SZM->ZM_PARCELA+SZM->ZM_TIPO+SZM->ZM_FORNEC+SZM->ZM_LOJA
		DbSetOrder(1)
		DbSeek(xFilial("SZM")+_cCaixa,.F.)
		Do While SZM->ZM_FILIAL == xFilial("SZM") .And. SZM->ZM_NUMCX == _cCaixa .And. SZM->(!Eof())
			If SZM->ZM_PREFIXO+SZM->ZM_NUMERO+SZM->ZM_PARCELA+SZM->ZM_TIPO+SZM->ZM_FORNEC+SZM->ZM_LOJA == _cChave
				RecLock("SZM",.F.)
				DbDelete()
				MsUnLock()
			EndIf
			SZM->(DbSkip())
		EndDo

		DbSelectArea("SE2")
		DbSetOrder(1)
		If SE2->(DbSeek(xFilial("SE2")+_cChave,.F.))
			RecLock("SE2",.F.)
			SE2->E2_NUMCX := "        "
			MsUnLock()
		EndIf
	EndIf
	DbSelectArea("SZM")
	DbSkip()
	Return(.T.)
	*
	**********************
User Function ValTit()
	**********************
	*
	local nSaldo 	:= 0
	local nVlAbat	:= 0

	_lVolta := .T.
	If !Empty(M->ZM_TIPO) .And. M->ZM_TIPO == "AB-"
		M->ZM_TIPO := "   "
		Alert("Não Inclir Títulos Tipo Abatimento")
		_lVolta := .F.
	ElseIf !Empty(M->ZM_NUMERO) .And. !Empty(M->ZM_TIPO) .And. !Empty(M->ZM_FORNEC) .And. !Empty(M->ZM_LOJA)
		SE2->(DbSetOrder(1))
		If !SE2->(DbSeek(xFilial("SE2")+M->ZM_PREFIXO+M->ZM_NUMERO+M->ZM_PARCELA+M->ZM_TIPO+M->ZM_FORNEC+M->ZM_LOJA,.F.))
			Alert("Titulo não Localizado")
			M->ZM_VENCTO  := Ctod(" / /  ")
			M->ZM_VALOR   := 0.00
			M->ZM_NATUREZ := Space(Len(SE2->E2_NATUREZ))
			If M->ZM_TPDADO == "C"
				M->ZM_TPDADO := " "
			EndIf
			_lVolta := .F.
		/*
		ElseIf !Empty(SE2->E2_NUMBOR)
			Alert("Titulo já Incluido no Caixa " + SE2->E2_NUMBOR)
			_lVolta := .F.
		*/
		Else
			nVlAbat := SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,,SE2->E2_FORNECE,SE2->E2_LOJA)
			nSaldo 	:= ( SE2->E2_VALOR + SE2->E2_ACRESC + SE2->E2_JUROS - SE2->E2_DECRESC )
			M->ZM_VENCTO  := SE2->E2_VENCTO
			M->ZM_VALOR   := (nSaldo - nVlAbat)
			M->ZM_NATUREZ := SE2->E2_NATUREZ
			M->ZM_TPDADO  := "C"
			If Empty(M->ZM_HIST)
				M->ZM_HIST    := SE2->E2_HIST
			EndIf
		EndIf
	EndIf
	If Empty(M->ZM_NUMERO)
		M->ZM_VENCTO  := Ctod(" / /  ")
		M->ZM_VALOR   := 0.00
		M->ZM_NATUREZ := Space(Len(SE2->E2_NATUREZ))
		If M->ZM_TPDADO == "C"
			M->ZM_TPDADO := " "
		EndIf
	EndIf
	Return(_lVolta)
	*
	**********************
User Function CdFi5T()
	**********************
	* 
	Local aFina100  := {}
	Local _nValTran := 0
	Local dDataMov  := CtoD("31/12/49")
	Local dMyData   := dDataBase
	Local mvControl := ""

	DbSelectArea("SZM")
	DbSetOrder(1)  // ZM_FILIAL+ZM_NUMCX+ZM_PREFIXO+ZM_NUMERO+ZM_PARCELA+ZM_TIPO+ZM_FORNEC+ZM_LOJA
	cPerg := "CDFI5Ta"
	ValidPerg()

	ValidPerg()
	If !Pergunte(cPerg, .T.)
		Return(.T.)
	EndIf

	myMvPar01 := mv_par01
	myMvPar02 := mv_par02
	Do While myMvPar01 <= myMvPar02

		_nValTran := 0
		dDataMov  := dDataBase

		If !SZM->(DbSeek(xFilial("SZM") + myMvPar01,.F.))
			Alert("Caixa nao Cadastrado")
			Return(.F.)
		EndIf

		SZM->(DbSeek(xFilial("SZM")+myMvPar01,.F.))
		Do While SZM->ZM_FILIAL == xFilial("SZM") .And. SZM->ZM_NUMCX == myMvPar01 .And. SZM->(!Eof())
			//If SZM->ZM_STATUS # "D"//Depositado
			If SZM->ZM_TPDADO == "C"
				_nValTran += SZM->ZM_VALOR
			ElseIf SZM->ZM_TPDADO == "E"//Estorno
				_nValTran -= SZM->ZM_VALOR
			EndIf
			/*
			RecLock("SZM",.F.)
			SZM->ZM_STATUS := "D"
			MsUnlock()
			*/
			//Pego menor data ( data que será a data efetiva da transferencia )
			dDataMov := Iif( dDataMov > SZM->ZM_DATA, SZM->ZM_DATA , dDataMov) 
			//EndIf
			SZM->(DbSkip())
		EndDo
		If _nValTran > 0 
			Begin Transaction

				dDataBase := dDataMov //Troco a data p/ transferencia ocorrer na data do primeiro caixa.
				// Transferencia do Banco 000 ( Jackson ) p/ banco 999 ( Intermediario )
				aFINA100 :={{"cBcoOrig"	  , "000" 		    				 						,	Nil},;
				{"cAgenOrig"  , "00000" 		  				 						,	Nil},;
				{"cCtaOrig"	  , "0000000000" 		  				 					,	Nil},;
				{"cNaturOri"  , "6" 		  				 							,	Nil},;
				{"cBcoDest"	  , "999" 		  				 							,	Nil},;
				{"cAgenDest"  , "99999"			  										,	Nil},;
				{"cCtaDest"	  , "9999999999"     	   					  				,	Nil},;
				{"cNaturDes"  , "6"	    										   		,	Nil},;//Outros
				{"cDocTran"	  , myMvPar01  												,	Nil},;
				{"cTipoTran"  , "TB"         	  					 		 			,	Nil},;
				{"nValorTran" , _nValTran		   							 			,	Nil},;
				{"cHist100"   , "Caixa Nº"+myMvPar01+"/"+CValtoChar(Year(dDataBase))	,	Nil},;
				{"cBenef100"  , "IFC-Bradesco(Itu)"                                		,	Nil}}

				lMsErroAuto := .F.
				MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,7)// 7- Transferencia Bancaria

				If lMsErroAuto
					DisarmTransaction()
					MostraErro()
				EndIf
				dDataBase := dMyData //Volto a data atual do sistema
			End Transaction             
		EndIf	
		myMvPar01 := Soma1(myMvPar01)
	EndDo

	Return(.T.)

	*
	*************************
Static Function ValidPerg
	*************************
	*
	_aArea := GetArea()
	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	If "CDFI5Ta" $ cPerg
		//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
		aAdd(aRegs,{cPerg,"01","Nro. Caixa de                ?","mv_ch1","C",06,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"02","Nro. Caixa ate               ?","mv_ch2","C",06,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})
	Else
		//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
		aAdd(aRegs,{cPerg,"01","Nro. Caixa                   ?","mv_ch1","C",06,0,0,"G","","MV_PAR01","",_MyMV_PAR01,"","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"02","Banco Destino                ?","mv_ch2","C",03,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","SA6"})
		aAdd(aRegs,{cPerg,"03","Agencia Destino              ?","mv_ch3","C",05,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"04","Conta Destino                ?","mv_ch4","C",10,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"05","Data do Movimento            ?","mv_ch5","D",08,0,0,"G","","MV_PAR05","",Dtoc(dDataBase),"","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"06","Valor do Deposito            ?","mv_ch6","N",10,2,0,"G","Positivo()","MV_PAR06","",Str(_MyValor,10,2),"","","","","","","","","","","","",""})
	EndIf*/
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
		ElseIf !Empty(aRegs[i,13])
			RecLock("SX1",.F.)
			SX1->X1_CNT01   := aRegs[i,13]
			MsUnlock()
			DbCommit()
		Endif
	Next
	RestArea(_aArea)
	Return(.T.)
	************************
Static Function CalcCx(lGrava)
	************************
	*
	DbSelectArea("SZM")
	ProcRegua(LastRec())
	DbSetOrder(1)
	DbSeek(xFilial("SZM")+_MyMV_PAR01,.F.)
	Do While SZM->ZM_FILIAL == xFilial("SZM") .And. SZM->ZM_NUMCX == _MyMV_PAR01 .And. SZM->(!Eof())
		IncProc()
		If lGrava
			RecLock("SZM",.F.)
			SZM->ZM_TPDADO := "D"
			MsUnLock()
		Else
			If SZM->ZM_TPDADO == "C"
				_MyValor += SZM->ZM_VALOR
			Else
				_MyValor -= SZM->ZM_VALOR
			EndIf
		EndIf
		DbSkip()
	EndDo
	Return(.T.)
	*
	**********************
User Function ValCaixa()
	**********************
	*
	//Valida se o pode incluir no Bordero.
	_xaArea := GetArea()
	DbSelectArea("SZM")
	DbSetOrder(1) // ZM_FILIAL+SMZ->ZM_NUMCX
	_Volta := .T.
	If SZM->(DbSeek(xFilial("SZM")+M->ZM_NUMCX,.F.))
		If SZM->ZM_STATUS == "D" // Deposito ja realizado
			Alert("Deposito Ja Realizado!!!")
			_Volta := .F.
		EndIf
	EndIf
	RestArea(_xaArea)
Return(_Volta)

static function GravaSZM(cNumCx)	
	local _aDados 	:= {}
	
	if empty(cNumCx)
		Alert('[ERRO] - Caixa não incluido, verifique numero do caixa')
	else
		nVlAbat  := SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,,SE2->E2_FORNECE,SE2->E2_LOJA)
		nSaldo := ( SE2->E2_VALOR + SE2->E2_ACRESC + SE2->E2_JUROS - SE2->E2_DECRESC )

		//Multiplas naturezas //Edvar
		if SEV->(DbSeek(xFilial("SE2")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)))
			do While SEV->(!Eof()) .And. ;
			SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)==;
			SEV->(EV_PREFIXO+EV_NUM+EV_PARCELA+EV_TIPO+EV_CLIFOR+EV_LOJA)

				If SEV->EV_RECPAG == "P"
					Aadd(_aDados,{SEV->EV_PREFIXO,SEV->EV_NUM,SEV->EV_PARCELA,SEV->EV_TIPO,SEV->EV_CLIFOR,SEV->EV_LOJA,SEV->EV_NATUREZ,SEV->EV_VALOR,0})
					If nVlAbat > 0
						_aDados[len(_aDados)][9] := (nVlAbat / SE2->E2_VALOR) * SEV->EV_VALOR
					EndIf
				Endif
				SEV->(dbSkip())
			endDo
		else
			aadd(_aDados,{SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA,SE2->E2_NATUREZ,nSaldo,nVlAbat})
		endIf

		for i := 1 to Len(_aDados)

			DbSelectArea("SZM")
			RecLock("SZM",.T.)
			SZM->ZM_FILIAL  := xFilial("SZM")
			SZM->ZM_NUMCX   := cNumCx
			SZM->ZM_DATA    := dDataBase
			SZM->ZM_PREFIXO := _aDados[i][1]
			SZM->ZM_NUMERO  := _aDados[i][2]
			SZM->ZM_PARCELA := _aDados[i][3]
			SZM->ZM_TIPO    := _aDados[i][4]
			SZM->ZM_FORNEC  := _aDados[i][5]
			SZM->ZM_LOJA    := _aDados[i][6]
			SZM->ZM_VENCTO  := SE2->E2_VENCTO
			SZM->ZM_NATUREZ := _aDados[i][7]
			SZM->ZM_VALOR   := _aDados[i][8]-_aDados[i][9]
			SZM->ZM_HIST    := SE2->E2_HIST
			SZM->ZM_TPDADO  := "C"
			MsUnLock()
		next
	endif
return(.T.)    

	********************************
	/*
	FUNÇÔES LEONARDO PARA AO INCLUIR CAIXA SZM
	TAMBEM REALIZAR CT2 - LANÇAMENTO CLASSE DE VALOR(MAPA DESPESAS)
	TAMBEM REALIZAR CT2(1101) - TOTAL DO CAIXA CONTA-CORRENTË
	*/

	******************************
User Function fecharCC()  //PROCESSAR OS CAIXAS (MAPA DESPESAS X CONTA_CORRENTE)
	******************************
	Local aCab 		:= {}
	Local aItens	:= {}
	Local nLinha	:= 1
	Local cNroBord
	Local nCont		:= 0
	Local cqry		:= ""
	Local cSQL		:= ""
	Local cSQL1		:= ""
	Local nVlCxCC	:= 0
	Local aBox		:={}
	Local aRet		:={}
	Local dDtDe
	Local dDtAte
	Local dBkDtBase	:= dDataBase

	If FwFilial() == '02'	
		u_autoAlert('[ERRO] - Utilie a rotina de transferência C/C, apenas na filial 01-(ITU) ')	
	Else
		//OBTER INTERVALO DE DATA
		aAdd(aBox,{1,"Data De:"  	,dDataBase,"","","","",50,.T.}) 
		aAdd(aBox,{1,"Data Ate:"  	,dDataBase,"","","","",50,.T.})
		If ParamBox(aBox,"Consolidação Caixas...",@aRet)

			dDtDe    	:= aRet[1]
			dDtAte		:= aRet[2]
		Else
			MessageBox("Confirme os parametros","Aviso",48)
			Return nil
		EndIf

		//ARRUMAR NATUREZAS QUE NÂO ESTÂO ASSOCIADAS COM CLASSE DE VALOR (LEO 10/06/2015)
		cqry	+= " UPDATE "+ retsqlname("SE2") + " SET E2_CLVLDB = E2_NATUREZ "
		cqry	+= " WHERE D_E_L_E_T_ = '' "
		cqry    += " AND E2_CLVLDB = '' "
		cqry	+= " AND E2_NATUREZ <> 'COFINS' "
		cqry	+= " AND E2_NATUREZ <> 'CSLL' " 
		//Alterado por Juliana Leme - 01/07/2015
		//cqry	+= " AND E2_NATUREZ <> '' "
		cqry	+= " AND (SUBSTRING(E2_NATUREZ,1,1) = 'C' OR SUBSTRING(E2_NATUREZ,1,1) = 'D')"

		If (TCSQLexec(cqry) < 0)
			MsgStop("LOG SQL: " + TCSQLError())
		EndIf

		cqry	:=""

		//Fechar e excluir arquivo de trabalho
		If Select( "CLVL") > 0
			CLVL->(dbcloseArea())
			FErase( "CLVL" + GetDbExtension())
		End If

		cSQL := "AND (ZM_DATA BETWEEN '" + Dtos(dDtDe) + "' AND '" + Dtos(dDtAte) + " ')"
		cSQL += "AND (SUBSTRING(E2_CLVLDB,1,1) = 'C' OR SUBSTRING(E2_CLVLDB,1,1) = 'D')"
		cSQL := "%"+cSQL+"%"

		//Consulta no banco
		BeginSQL Alias "CLVL"

		column ZM_DATA 	as Date

		SELECT 	
		E2_PREFIXO,
		E2_NUM,
		E2_PARCELA,
		E2_NOMFOR,
		E2_NATUREZ,
		E2_CLVLDB,
		ZM_DATA,
		ZM_NUMCX,
		E2_NOMFOR,
		ZM_VALOR

		FROM %Table:SZM% ZM

		INNER JOIN %Table:SE2% E2 ON		E2_FILIAL 		= ZM_FILIAL
		AND E2_PREFIXO	= ZM_PREFIXO
		AND E2_NUM		= ZM_NUMERO
		AND E2_PARCELA	= ZM_PARCELA
		AND E2_TIPO		= ZM_TIPO
		AND E2_FORNECE	= ZM_FORNEC
		AND E2_LOJA		= ZM_LOJA

		WHERE E2.%NotDel% AND ZM.%NotDel% %exp:cSQL%
		ORDER BY ZM_NUMCX

		EndSql

		DbSelectArea("CLVL")
		CLVL->(DbGotop())

		While CLVL->(!Eof())

			//CABEÇALHO PARA CADA CAIXA
			//Obtem o numero do bordero
			cNroBord :=Alltrim(CLVL->(ZM_NUMCX))

			//ZERA OS ARRAYS
			aCab 		:= {}
			aItens 		:= {}
			nLinha		:= 1
			cSQL1		:= ""
			nVlCxCC		:= 0

			dDatabase 	:= CLVL->(ZM_DATA) 

			//Cria o cabeçalho para o lançamentoCLVL->(ZM_DATA)
			aCab := { 	{'DDATALANC' 	,dDatabase 					,NIL},;
			{'CLOTE' 		,"018850" 								,NIL},;
			{'CSUBLOTE' 	,'001' 									,NIL},;
			{'CDOC' 		, Alltrim(CLVL->(ZM_NUMCX)) 			,NIL},;
			{'CPADRAO' 		,'' 									,NIL},;
			{'NTOTINF' 		,0 										,NIL},;
			{'NTOTINFLOT' 	,0 										,NIL} }

			//CRIA ARRAY TODOS OS TITULOS DO CAIXA
			While Alltrim(CLVL->(ZM_NUMCX)) == cNroBord .AND. CLVL->(!Eof())

				//Adiciona os itens no array para lançamento
				aAdd(aItens,{  	{'CT2_FILIAL'  	,XFilial("SE2")   											, NIL},;
				{'CT2_LINHA'  	, StrZero(nLinha,3) 														, NIL},;
				{'CT2_MOEDLC' 	,'01'   																	, NIL},;
				{'CT2_DC'   	,'3'   																		, NIL},;
				{'CT2_DEBITO'  	,'DEB' 																		, NIL},;
				{'CT2_CREDIT'  	,'CRE' 																		, NIL},;
				{'CT2_VALOR'  	, CLVL->(ZM_VALOR)  														, NIL},;
				{'CT2_ORIGEM' 	,'CTBBORDERO'																, NIL},;
				{'CT2_HP'   	,''   																		, NIL},;
				{'CT2_EMPORI'   ,'01'   																	, NIL},;
				{'CT2_FILORI'   ,XFilial("SE2")   															, NIL},;
				{'CT2_TPSALD'   ,'6'   																		, NIL},;
				{'CT2_CLVLCR'   ,CLVL->(E2_CLVLDB)   														, NIL},;
				{'CT2_HIST'   	,CLVL->(E2_PREFIXO + E2_NUM  + E2_PARCELA + E2_NOMFOR)						, NIL} } )

				nVlCxCC += CLVL->(ZM_VALOR)//SOMA PARA CONTA_CORRENTE
				nCont ++                                                          
				nLinha ++
				ClVL->(DbSkip())
			EndDo

			//REALIZAR O CONTA_CORRENTE (CONSIDERANDO QUE NO SZM TEM O CAMPO TPDADO, ONDE DEFINE
			// V=ABATIMENTO PARA DEPOSITO
			// E=ABATIMENTO CONTA-CORRENTE
			// C=TITULO A SER ABATIDO DO VALORES ACIMA
			// ENTÃO VALOR CONTA-CORRENTE É (TODOS OS TPDADO=C MENOS TODOS OS TPDADO=E)

			//SOMENTE PROCURA ABATIMENTOS SE TIVER TIVER TITULOS
			If Len(aItens) > 0
				//OBTER O VALOR DO ABATIMENTO
				If Select( "ABAT") > 0
					ABAT->(dbcloseArea())
					FErase( "ABAT" + GetDbExtension())
				End If

				cSQL1 := " ZM.ZM_NUMCX = '" + cNroBord  + "'"
				cSQL1 += " AND ZM.ZM_TPDADO	= 'E'"
				cSQL1 := "%"+cSQL1+"%"

				BeginSQL Alias "ABAT"

				SELECT SUM(ZM.ZM_VALOR) AS ABATER
				FROM SZM010 ZM
				WHERE ZM.%NotDel%
				AND %exp:cSQL1%

				EndSql

				ABAT->(DbGoTop())

				If ABAT->(!Eof())

					nVlCxCC := ( nVlCxCC - ABAT->(ABATER) )

				EndIF

				If Select( "ABAT") > 0
					ABAT->(dbcloseArea())
					FErase( "ABAT" + GetDbExtension())
				End If

				aAdd(aItens,{  	{'CT2_FILIAL'  	,XFilial("SZM")   			, NIL},;
				{'CT2_LINHA'  	, StrZero(nLinha,3) 		, NIL},;
				{'CT2_MOEDLC'  	,'01'   					, NIL},;
				{'CT2_DC'   	,'3'   						, NIL},;
				{'CT2_DEBITO'  	,'DEB' 						, NIL},;
				{'CT2_CREDIT'  	,'CRE' 						, NIL},;
				{'CT2_VALOR'  	, nVlCxCC  					, NIL},;
				{'CT2_ORIGEM' 	,'CTBBORDERO'				, NIL},;
				{'CT2_HP'   	,''   						, NIL},;
				{'CT2_EMPORI'   ,'01'   					, NIL},;
				{'CT2_FILORI'   ,XFilial("SE2")   			, NIL},;
				{'CT2_TPSALD'   ,'6'   						, NIL},;
				{'CT2_CLVLCR'   ,'1101'   					, NIL},;
				{'CT2_CLVLDB'   ,'9101'   					, NIL},;
				{'CT2_HIST'   	,'CAIXA Nro. ' + cNroBord  	, NIL} } )

				//LANÇA NO CT2
				lmtCt2(aCab,aItens)   

			EndIF

		EndDo

		If Select( "CLVL") > 0
			CLVL->(dbcloseArea())
			FErase( "CLVL" + GetDbExtension())
		End If

		//RESTAURA DATA BASE ORIGINAL
		dDataBase := dBkDtBase
		u_autoAlert("Todos os caixas do periodo, foram consolidados no conta-corrente = " + cValToChar(nCont),.F.,'Box','Aviso',1)

	EndIf
	Return Nil
	********************************************
Static Function lmtCt2(aCab,aItens) //Lançamento no CT2-TESTADO 02/02- Debugando(Exclui e Incluir normalmente o caixa 002506
	********************************************
	Local cErrLog  

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	Begin Transaction

		MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 5) //EFETUA A EXCLUSÃO

		If !lMsErroAuto //NÃO DEU ERRO NA EXCLUSÂO

			MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3) //EFETUA A INCLUSÂO

			If lMsErroAuto //ERRO TAMBEM NA INCLUSÂO
				DisarmTransaction()
				MOSTRAERRO()    
			EndIF
		Else
			DisarmTransaction()
			MOSTRAERRO()
		EndIf
	End Transaction

	Return nil   

	*********************************
User Function AltFina05()
	*********************************
	Local aAlias 	:= SZM->(GetArea()) 
	Local aCpos		:= {"ZM_HIST","ZM_NATUREZ"} //Campos que poderão ser editados
	Local nRet
	Local aHead		:= {}
	Local aContent	:= {}
	Local cNat		
	local oInt      := ctrlCbcBudget():newctrlCbcBudget()
	local aSaldo    := {}
	local lOk		:= .T.
	local cBckNat	:= AllTrim(SZM->(ZM_NATUREZ))

	Begin Transaction
	//nRet := AxAltera("SB1", SB1->(RecNo()), 4, aAcho, aAlter,,,/*cTudOk*/,,,,,,.T.)
	nRet := AxAltera("SZM",SZM->(RecNo()), 4,,aCpos,,,,,,,,,.T.,.T.)

	If nRet == 1
		if u_cbcUseBudget()
			if cBckNat <> AllTrim(SZM->(ZM_NATUREZ))
				aSaldo := oInt:libMov(, AllTrim(SZM->(ZM_NATUREZ)), SZM->(ZM_VALOR))
				if !(lOk := aSaldo[1])
					cMsg := 'Natureza: ' + AllTrim(SZM->(ZM_NATUREZ)) + ' não possui saldo de budget!' + CHR(13)+CHR(10) + 'Disponível: ' + cValtochar(TRANSFORM(aSaldo[2], PesqPict('SD1', 'D1_TOTAL'))) + CHR(13)+CHR(10) + 'Requisitado: ' + cValToChar(TRANSFORM(SZM->(ZM_VALOR), PesqPict('SD1', 'D1_TOTAL')))
					u_autoAlert(cMsg)
					DisarmTransaction()
				endif
			endif
		endif
		if lOk
			DbSelectArea("SE2")
			SE2->(DbSetOrder(1)) //E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA	

			//Posiciona no titulo que originou o SZM ( Tem que alterar SE2 e SZM) 
			If SE2->(DbSeek(xFilial("SE2") + SZM->(ZM_PREFIXO + ZM_NUMERO + ZM_PARCELA + ZM_TIPO + ZM_FORNEC + ZM_LOJA) ,.F.))

				//Salva a natureza antiga
				cNat := SE2->(E2_NATUREZ) 

				RecLock("SE2",.F.)
				SE2->(E2_NATUREZ)	:= SZM->(ZM_NATUREZ)
				SE2->(E2_CLVLDB)	:= SZM->(ZM_NATUREZ)
				SE2->(E2_HIST)		:= SZM->(ZM_HIST)
				SE2->(MsUnlock())
				
				Aadd(aHead,"NUM.TITULO")
				Aadd(aHead,"PARCELA")
				Aadd(aHead,"FORNECEDOR") 
				Aadd(aHead,"NAT. ANTIGA")
				Aadd(aHead,"NAT.NOVA")  

				Aadd(aContent,{ Alltrim(SZM->(ZM_NUMERO)),Alltrim(SZM->(ZM_PARCELA)),;
				Alltrim(SZM->(ZM_FORNEC)),cNat,Alltrim(SZM->(ZM_NATUREZ)) }  )  
				
				if cBckNat <> AllTrim(SZM->(ZM_NATUREZ))
					altMultiNat()
				endif

				//Mandar Email(Avisando da alteração)
				//envMail(aTo,cSubject,aHead,aContent)
				u_envMail({"contabil@cobrecom.com.br"},"Alteração Natureza- Fin.Ctas.Pagar",aHead,aContent)

			EndIf
		endif
	Else

		Restarea(aAlias)

	EndIF
	End Transaction
	FreeObj(oInt)
Return Nil

static function altMultiNat()
	local aArea     := getArea()
    local aAreaE2   := SE2->(getArea())
    local aAreaEV   := SEV->(getArea())
	local aAreaZM   := SZM->(getArea())
    local oSql      := nil

	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(qryFindSEV())
	if oSql:hasRecords()
		oSql:GoTop()
		DbSelectArea('SEV')
		SEV->(DbGoTo(oSql:getValue('REC')))
		RecLock("SEV",.F.)
			SEV->EV_NATUREZ := SZM->(ZM_NATUREZ)
		SEV->(MsUnlock())
	endif
	oSql:close()
	Freeobj(oSql)

	RestArea(aAreaZM)
    RestArea(aAreaEV)
    RestArea(aAreaE2)
    RestArea(aArea)
return(nil)

static function qryFindSEV()
	local cQry := ""

	cQry += " SELECT SEV.R_E_C_N_O_ AS [REC] "
	cQry += " FROM SEV010 SEV "
	cQry += " WHERE SEV.EV_FILIAL = '" + SZM->(ZM_FILIAL) + "' "
	cQry += " AND SEV.EV_PREFIXO = '" + SZM->(ZM_PREFIXO) + "' "
	cQry += " AND SEV.EV_NUM = '" + SZM->(ZM_NUMERO) + "' "
	cQry += " AND SEV.EV_TIPO = '" + SZM->(ZM_TIPO) + "' "
	cQry += " AND SEV.EV_CLIFOR = '" + SZM->(ZM_FORNEC) + "' "
	cQry += " AND SEV.EV_LOJA = '" + SZM->(ZM_LOJA) + "' "
	cQry += " AND SEV.EV_VALOR = " + cValToChar(SZM->(ZM_VALOR))
	cQry += " AND SEV.D_E_L_E_T_ = '' "
return(cQry)
