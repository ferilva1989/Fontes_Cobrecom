#include "rwmake.ch"
#include "TOPCONN.ch"
#include "protheus.ch"
#define CRLF Chr(13)+Chr(10)

static cDrive := if(U_zIs12(),'CTREECDX','')

/*/{Protheus.doc} CDGEN09
//TODO Descrição auto-gerada.
@author zzz
@since 30/05/2017
@version undefined

@type function
/*/
User Function CDGEN09()

// Atenção ... ficar de olho nos produtos com cód de barras novo...e com as bobinas de 3 lagoas...
// Pode existrir com duplicidade.
	cPerg := "CDGN09"
	ValidPerg()
	_lPerg := Pergunte(cPerg, .T.)
	MV_PAR06 := Left(Upper(Alltrim(MV_PAR06))+Space(10),10)
	
	If AllTrim(cUserName)+"|" $ GetMV("MV_USERADM")
		// Menu para administradores
		aRotina := {{ "Pesquisar"		, "AxPesqui"	, 0 , 1	},;
					{ "Visualizar"		, "AxVisual"	, 0 , 2	},;
					{ "Incluir"			, "AxInclui"	, 0 , 3	},;
					{ "Alterar"			, "AxAltera"	, 0 , 4	},;
					{ "Excluir"			, "AxDeleta"	, 0 , 5	},;
					{ "Imp.Coletor"		, "u_LE_COLETOR()"  , 0 , 2	},;
					{ "Est. Liber."		, "u_EstDC()"	, 0 , 2	},;
					{ "Cria B7 Zerado"	, "u_CriaB7()"	, 0 , 2	},;
					{ "Transf. ZG B7"	, "u_TrfZGB7()"	, 0 , 2	},;
					{ "Ajust. Invent"	, "u_PrcB7()"	, 0 , 2	},;
					{ "Imp. Bobinas"	, "u_SalBob()"	, 0 , 2	},;
					{ "Plan. Vania"	    , "u_CriaPln()"	, 0 , 2	},;
					{ "Col. cbcWMS"	    , "u_cbcWmsInvent()", 0 , 2	},;
					{ "Parâmetros"		, "u_IncInv()"	, 0 , 2}}

		//			{ "Refaz Liber."  , "u_LibDC()"  , 0 , 2	},;
	Else
		// Menu para não administradores
		aRotina := {{ "Pesquisar"     , "AxPesqui"   , 0 , 1	},;
					{ "Visualizar"    , "AxVisual"   , 0 , 2	},;
					{ "Incluir"       , "AxInclui"   , 0 , 3	},;
					{ "Alterar"       , "AxAltera"   , 0 , 4	},;
					{ "Excluir"       , "AxDeleta"   , 0 , 5	},;
					{ "Imp.Coletor"   , "u_LE_COLETOR()"  , 0 , 2	},;
					{ "Col. cbcWMS"	  , "u_cbcWmsInvent()", 0 , 2	},;
					{ "Parâmetros"    , "u_IncInv()" , 0 , 2	}}
	EndIf
	
	cCadastro := "Inventário"
	DbSelectArea("SZG")
	DbSetOrder(1)
	DbSeek(xFilial("SZG"))
	mBrowse(001,040,200,390,"SZG",,,,,,)
Return(.T.)

/*/{Protheus.doc} IncInv
//TODO Descrição auto-gerada.
@author roberto
@since 30/05/2017
@version undefined
@param lFirst, logical, descricao
@type function
/*/
User Function IncInv(lFirst)
	cPerg := "CDGN09"
	_Volta := Pergunte(cPerg, .T.)
	MV_PAR06 := Left(Upper(Alltrim(MV_PAR06))+Space(10),10)
Return(_Volta)


Static Function ValidPerg()

	_aArea := GetArea()
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	
	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Data do Inventário           ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Nro. da Contagem             ?","mv_ch2","C",01,0,0,"G","Pertence('123')","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Armazém                      ?","mv_ch3","C",02,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Acond.Padrão                 ?","mv_ch4","C",01,0,0,"G","Pertence('RBCTM')","mv_par04","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Lance Padrão                 ?","mv_ch5","N",05,0,0,"G","Positivo()","mv_par05","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Lote de Contagem (Ilha)      ?","mv_ch6","C",10,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Retalhos Inventariados       ?","mv_ch7","N",01,0,0,"C","","mv_par07","Sim","","","","","Não","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Data Inventário PCFactory    ?","mv_ch8","D",08,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Data Inventário Protheus     ?","mv_ch9","D",08,0,0,"G","","mv_par09","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","Do Processo                  ?","mv_cha","N",01,0,0,"C","","mv_par10","Atual.Saldo","","","Atual.Sobras","","","Atual.Faltas","","","","","","","",""})
	aAdd(aRegs,{cPerg,"11","Até o Processo               ?","mv_chb","N",01,0,0,"C","","mv_par11","Atual.Saldo","","","Atual.Sobras","","","Atual.Faltas","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","Rodar ?               		 ?","mv_chc","N",01,0,0,"C","","mv_par12","Tudo","","","Só o PA","","","Fora o PA","","","","","","","",""})
	//0-Tudo 1-Só PA 2-Fora o PA
	
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
Return(.T.)


/*/{Protheus.doc} CriaB7
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined

@type function
/*/
User Function CriaB7()
	If !AllTrim(cUserName)+"|" $ GetMV("MV_USERADM")
		Alert("Somente Administrador")
		Return(.T.)
	EndIf
	
	If !u_IncInv()
		Return(.T.)
	EndIf
	
	If MV_PAR01 # MV_PAR08 .And. MV_PAR01 # MV_PAR09
		Alert("Atenção: As datas do Inventário PCFactory ou Inventário Protheus tem que ser igual a Data do Inventário")
		Return(.T.)
	/*
	ElseIf MV_PAR08 == MV_PAR09
		Alert("Atenção: As datas do Inventário PCFactory não pode ser igual a Data do Inventário Protheus")
		Return(.T.)
	*/
	ElseIf Empty(MV_PAR01) .Or. Empty(MV_PAR08) .Or. Empty(MV_PAR09)
		Alert("Atenção: Todas as datas devem estar preenchidas")
		Return(.T.)
		//ElseIf !Str(Dow(MV_PAR01),1) $ "17" .Or. Dow(MV_PAR08) # 7 .Or. Dow(MV_PAR09) # 1 .Or. MV_PAR08>MV_PAR09 .Or. (MV_PAR09-MV_PAR08) # 1
		//	Alert("Atenção: Datas Inválidas")
		//	Return(.T.)
	EndIf
	
	_lInvProt := (MV_PAR01 == MV_PAR09) // Estou fazendo o inventário do protheus?
	
	//Processa( {|| TrateSB7(_lInvProt) },"Ajustando SB7...")
	
	If _lInvProt  // Estou fazendo o inventário do protheus?
		_UltFech := GetMv("MV_ULMES")
		Processa( {|| LeiaDB(_lInvProt) },"Ajustando Tabela Via SDB...")
		Processa( {|| LeiaBK(_lInvProt) },"Ajustando Tabela Via SBK...")
		//If xFilial("SB2") == "01"
		Processa( {|| LeiaB2(_lInvProt) },"Ajustando Tabela Via SB2...") // Somente almoxarifado 99 processos
		//EndIf
	EndIf
Return(.T.)


/*/{Protheus.doc} TrateSB7
//TODO Descrição auto-gerada.
@author 
@since 30/05/2017
@version undefined
@param _lInvProt, , descricao
@type function
/*/
Static Function TrateSB7(_lInvProt)
	DbSelectArea("SB7")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	ProcRegua(LastRec())
	If _lInvProt
		// Inventário no Protheus -> Matar todos os registros que também foram
		// inventariados no inventário do PCFactory
		SB7->(DbSeek(xFilial("SB7")+Dtos(MV_PAR01),.F.))
		Do While SB7->B7_FILIAL == xFilial("SB7") .And. SB7->B7_DATA == MV_PAR01 .And. SBF->(!Eof())
			IncProc()
			_nRegAtu  := SB7->(Recno())
			_cChvSB7  := Dtos(MV_PAR08)+SB7->B7_COD+SB7->B7_LOCAL+SB7->B7_LOCALIZ+SB7->B7_NUMSERI+SB7->B7_LOTECTL+SB7->B7_NUMLOTE
			_lMataReg := SB7->(DbSeek(xFilial("SB7")+_cChvSB7,.F.))
			SB7->(DbGoTo(_nRegAtu))
			If _lMataReg
				RecLock("SB7",.F.)
				DbDelete()
				MsUnLock()
			EndIf
			SB7->(DbSkip())
		EndDo
	Else
		// Inventário do PCFACTORY -- Matar todos dos registros do SB7 dessa data
		Do While SB7->(DbSeek(xFilial("SB7")+Dtos(MV_PAR01),.F.))
			IncProc()
			RecLock("SB7",.F.)
			DbDelete()
			MsUnLock()
		EndDo
	EndIf
Return(.T.)


/*/{Protheus.doc} LeiaB2
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined
@param _lInvProt, , descricao
@type function
/*/
Static Function LeiaB2(_lInvProt)
	_lTemPCF := .F.
	DbSelectArea("SB7")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	
	DbSelectArea("SB2")
	DbSetOrder(1)
	DbSeek(xFilial("SB2"),.F.)
	ProcRegua(LastRec())
	Do While SB2->B2_FILIAL == xFilial("SB2") .And. SB2->(!Eof())
		IncProc()
		SB1->(DbSeek(xFilial("SB1")+SB2->B2_COD,.F.))
		If SB1->B1_LOCALIZ # "S" .And. SB1->B1_TIPO # "MO" //.And. !(SB2->B2_LOCAL $ "03!04!95")
			//SB1->B1_LOCALIZ # "S" -> Produtos com controle de localização vão pelo SBK
			//SB1->B1_TIPO # "MO" -> Não são inventariado
	
			If _lInvProt // Inventário no Protheus?
				// Vejo se o produto já foi inventariado no PCFactory
				_lTemPCF := SB7->(DbSeek(xFilial("SB7")+Dtos(MV_PAR08)+SB2->B2_COD+SB2->B2_LOCAL,.F.))
			EndIf
			If !_lTemPCF
				If !SB7->(DbSeek(xFilial("SB7")+Dtos(MV_PAR01)+SB2->B2_COD+SB2->B2_LOCAL,.F.))
					RecLock("SB7",.T.)
					SB7->B7_FILIAL  := xFilial("SB7")
					SB7->B7_COD     := SB2->B2_COD
					SB7->B7_LOCAL   := SB2->B2_LOCAL
					SB7->B7_DOC     := "0001"
					SB7->B7_QUANT   := 0.00
					SB7->B7_DATA    := MV_PAR01
					SB7->B7_DTVALID := MV_PAR01
					//			SB7->B7_LOCALIZ := SDB->DB_LOCALIZ
					MsUnLock()
					DbSelectArea("SB2")
				EndIf
			EndIf
		EndIf
		SB2->(DbSkip())
	EndDo
Return(.T.)


/*/{Protheus.doc} LeiaDB
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined
@param _lInvProt, , descricao
@type function
/*/
Static Function LeiaDB(_lInvProt)
	_lTemPCF := .F.
	DbSelectArea("SB7")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	
	DbSelectArea("SDB")
	DbSetOrder(4) // DB_FILIAL+ DTOS(DB_DATA)+DB_RECHUM+DB_SERVIC+DB_TAREFA+DB_ATIVID
	DbSeek(xFilial("SDB") + DTOS(_UltFech+1),.T.)
	ProcRegua(LastRec())
	Do While SDB->DB_FILIAL == xFilial("SDB") .And. SDB->DB_DATA <= MV_PAR01 .And. SDB->(!Eof())
		IncProc()
		If _lInvProt // Inventário no Protheus?
			// Vejo se o produto já foi inventariado no PCFactory
			_lTemPCF := SB7->(DbSeek(xFilial("SB7")+Dtos(MV_PAR08)+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_LOCALIZ,.F.))
		EndIf
		If !_lTemPCF //.And. !(SDB->DB_LOCAL $ "03!04!95")
	
			// Se não existir no inventário do Protheus
			If !SB7->(DbSeek(xFilial("SB7")+Dtos(MV_PAR01)+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_LOCALIZ,.F.))
				// E NÃO existir no inventário
				RecLock("SB7",.T.)
				SB7->B7_FILIAL  := xFilial("SB7")
				SB7->B7_COD     := SDB->DB_PRODUTO
				SB7->B7_LOCAL   := SDB->DB_LOCAL
				SB7->B7_DOC     := "0001"
				SB7->B7_QUANT   := 0.00
				SB7->B7_DATA    := MV_PAR01
				SB7->B7_DTVALID := MV_PAR01
				SB7->B7_LOCALIZ := SDB->DB_LOCALIZ
				MsUnLock()
				DbSelectArea("SDB")
			EndIf
		EndIf
		SDB->(DbSkip())
	EndDo
Return(.T.)


/*/{Protheus.doc} LeiaBK
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined
@param _lInvProt, , descricao
@type function
/*/
Static Function LeiaBK(_lInvProt)
Local cQuery  := ""
	_lTemPCF := .F.
	
	DbSelectArea("SB7")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	
	cQuery += " SELECT COUNT(*) TOTAL FROM "+RetSqlName("SBK")
	cQuery += " WHERE BK_FILIAL = '"+xFilial("SBK")+"'"
	cQuery += " AND BK_DATA = '"+dtos(_UltFech)+"'"
	//cQuery += " AND BK_LOCAL <> '04'"
	//cQuery += " AND BK_LOCAL <> '03'"
	//cQuery += " AND BK_LOCAL <> '95'"
	cQuery += " AND D_E_L_E_T_ <>'*'"
	cQuery := ChangeQuery(cQuery)
	
	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"
	
	DbSelectArea("TRB")
	DbGotop()
	
	_nQtReg := TRB->TOTAL
	
	cQuery := ""
	cQuery += " SELECT BK_COD , BK_LOCAL, BK_LOCALIZ FROM "+RetSqlName("SBK")
	cQuery += " WHERE BK_FILIAL = '"+xFilial("SBK")+"'"
	cQuery += " AND BK_DATA = '"+dtos(_UltFech)+"'"
	//cQuery += " AND BK_LOCAL <> '03'"
	//cQuery += " AND BK_LOCAL <> '04'"
	//cQuery += " AND BK_LOCAL <> '95'"
	cQuery += " AND D_E_L_E_T_ <>'*'"
	cQuery := ChangeQuery(cQuery)
	
	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"
	
	DbSelectArea("TRB")
	DbGotop()
	ProcRegua(_nQtReg)
	
	Do While !TRB->(Eof())
		IncProc()
		//_lInvProt
		If _lInvProt // Inventário no Protheus?
			// Vejo se o produto já foi inventariado no PCFactory
			_lTemPCF := SB7->(DbSeek(xFilial("SB7")+Dtos(MV_PAR08)+TRB->BK_COD+TRB->BK_LOCAL+TRB->BK_LOCALIZ,.F.))
		EndIf
		If !_lTemPCF
			If !SB7->(DbSeek(xFilial("SB7")+Dtos(MV_PAR01)+TRB->BK_COD+TRB->BK_LOCAL+TRB->BK_LOCALIZ,.F.))
				RecLock("SB7",.T.)
				SB7->B7_FILIAL  := xFilial("SB7")
				SB7->B7_COD     := TRB->BK_COD
				SB7->B7_LOCAL   := TRB->BK_LOCAL
				SB7->B7_DOC     := "0001"
				SB7->B7_QUANT   := 0.00
				SB7->B7_DATA    := MV_PAR01
				SB7->B7_DTVALID := MV_PAR01
				SB7->B7_LOCALIZ := TRB->BK_LOCALIZ
				MsUnLock()
			EndIf
		EndIf
	
		TRB->(dbSkip())
	EndDo
	
	DbCloseArea("TRB")
Return(.T.)


/*/{Protheus.doc} TrfZGB7
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined

@type function
/*/
User Function TrfZGB7()
	If !AllTrim(cUserName)+"|" $ GetMV("MV_USERADM")
		Alert("Somente Administrador")
		Return(.T.)
	EndIf
	If !u_IncInv()
		Return(.T.)
	EndIf
	_UltFech := GetMv("MV_ULMES")
	
	Processa( {|| ZereB7() },"Zerando Tabela SB7...")
	
	Processa( {|| CrieB7() },"Transferindo Dados para SB7...")
	//If MV_PAR07 == 2 // Retalhos Inventariados? -> não
	//	Processa( {|| SldRetB7() },"Verificando Saldos de Retalhos...")
	//EndIf
	u_CDESTR18()
Return(.T.)


/*/{Protheus.doc} ZereB7
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined

@type function
/*/
Static Function ZereB7()
	DbSelectArea("SB7")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	ProcRegua(LastRec())
	SB7->(DbSeek(xFilial("SB7")+Dtos(MV_PAR01),.T.))
	Do While SB7->B7_FILIAL == xFilial("SB7") .And. SB7->B7_DATA == MV_PAR01 .And. SB7->(!Eof())
		IncProc()
		If SB7->B7_QUANT # 0.00
			RecLock("SB7",.F.)
			SB7->B7_QUANT   := 0.00
			//SB7->B7_KILOS   := 0.00
			MsUnLock()
		EndIf
		SB7->(DbSkip())
	EndDo
Return(.T.)


/*/{Protheus.doc} CrieB7
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined

@type function
/*/
Static Function CrieB7()
	_tt1 := 0
	_tt2 := 0
	_tt3 := 0
	_ttE := 0
	dbSelectArea("SB1")
	dbSetOrder(1)
	
	dbSelectArea("SAH")
	dbSetOrder(1)
	_tot := 0.00
	dbSelectArea("SZG")
	dbSetOrder(1) // ZG_FILIAL+ DTOS(ZG_DATA)+ZG_PRODUTO+ZG_LOCAL+ZG_ACOND+ STRZERO(ZG_LANCE,5)
	ProcRegua(RecCount())
	DbSeek(xFilial("SZG")+DTOS(MV_PAR01),.T.)
	Do While SZG->ZG_FILIAL == xFilial("SZG") .And. SZG->ZG_DATA == MV_PAR01 .And. SZG->(!EOF())
		If Posicione("SB1",1,xFilial("SB1")+SZG->ZG_PRODUTO,"B1_LOCALIZ") # "S"
			xxxy := 1
		EndIf
		_cProd := SZG->ZG_PRODUTO
		_cDesc := SZG->ZG_DESC
		_cLoca := SZG->ZG_LOCAL
		_cAcon := SZG->ZG_ACOND
		_cLanc := SZG->ZG_LANCE
		_cLote := SZG->ZG_LOTE
		If SZG->ZG_LOCAL == "90" //RETRABALHO
			//If SZG->ZG_LOTE == "PROATIVA  "
			_cLocaliz := SZG->ZG_ACOND + StrZero(SZG->ZG_LANCE,5)
			//Else
			//	_cLocaliz := Left("RTB"+Space(40),Len(SBE->BE_LOCALIZ))
			//EndIf
			//		_cLocaliz := Left(_cLocaliz+Space(40),Len(SBE->BE_LOCALIZ))
			//		_cLocaliz := Left("RTB"+Space(40),Len(SBE->BE_LOCALIZ))
		ElseIf SZG->ZG_LOCAL == "98" // C.Q.
			_cLocaliz := Left("CQ"+Space(40),Len(SBE->BE_LOCALIZ))
		ElseIf SZG->ZG_LOCAL == "20" // Produções no PCF
			_cLocaliz := Left("PROD_PCF"+Space(40),Len(SBE->BE_LOCALIZ))
		Else //If SZG->ZG_LOCAL == "01"
			If Empty(SZG->ZG_ACOND)
				_cLocaliz := ""
			Else
				_cLocaliz := If(_cLoca=="00","PROD",SZG->ZG_ACOND + StrZero(SZG->ZG_LANCE,5))
			EndIf
			_cLocaliz := Left(_cLocaliz+Space(40),Len(SBE->BE_LOCALIZ))
		EndIf
		_nTPri := 0
		_nTSeg := 0
		_nTTer := 0
		_nTErr := 0
		_lTTer := .F.
		If _cLoca == "00"
			_ppp := 1
		EndIf
	
		Do While SZG->ZG_FILIAL == xFilial("SZG") .And. SZG->ZG_DATA == MV_PAR01 .And. SZG->(!EOF()) .And.;
			SZG->ZG_PRODUTO == _cProd .And. SZG->ZG_LOCAL == _cLoca .And. SZG->ZG_ACOND == _cAcon .And. SZG->ZG_LANCE == _cLanc .And. ;
			SZG->ZG_LOTE == _cLote
	
			IncProc()
			If SZG->ZG_CONTAG == "1"
				_nTPri += SZG->ZG_METROS
			ElseIf SZG->ZG_CONTAG == "2"
				_nTSeg += SZG->ZG_METROS
			ElseIf SZG->ZG_CONTAG == "3"
				_nTTer += SZG->ZG_METROS
				_lTTer := .T.
			Else
				_nTErr += SZG->ZG_METROS
			EndIf
			SZG->(DbSkip())
		EndDo
		If (_nTPri # _nTSeg .And. !_lTTer) .Or. _nTErr > 0
			Loop
		EndIf
	
		SB1->(DbSeek(xFilial("SB1")+_cProd,.F.))
		If SB1->B1_LOCALIZ == "S"
			DbSelectArea("SBE")
			DbSetOrder(1)
			If !DbSeek(xFilial("SBE") + _cLoca + _cLocaliz,.F.)
				If _cAcon == "T"
					_cDesLo :=  "Retalho de "
				ElseIf _cAcon == "B"
					_cDesLo :=  "Bobina de "
				ElseIf _cAcon == "M"
					_cDesLo :=  "Carretel de Mad.de "
				ElseIf _cAcon == "C"
					_cDesLo :=  "Carretel de "
				ElseIf _cAcon == "R"
					_cDesLo :=  "Rolo de "
				ElseIf _cAcon == "L"
					_cDesLo :=  "Blister de "
				EndIf
				_cDesLo +=  Str(_cLanc,5) + " " + Posicione("SAH",1,xFilial("SAH")+SB1->B1_UM,"AH_DESCPO")
	
				RecLock("SBE",.T.)
				SBE->BE_FILIAL   := xFilial("SBE")
				SBE->BE_LOCAL    := _cLoca
				SBE->BE_LOCALIZ  := _cLocaliz
				SBE->BE_DESCRIC  := _cDesLo
				SBE->BE_PRIOR    := "ZZZ"
				SBE->BE_STATUS   := "1"
				MsUnLock()
			EndIf
		EndIf
	
		If SB1->(DbSeek(xFilial("SB1")+_cProd,.F.))
			If AllTrim(_cLocaliz) == "X00001"
				_cLocaliz := Space(Len(_cLocaliz))
			EndIf
			If !SB7->(DbSeek(xFilial("SB7")+Dtos(MV_PAR01)+_cProd+_cLoca+_cLocaliz,.F.))
				RecLock("SB7",.T.)
				SB7->B7_FILIAL  := xFilial("SB7")
				SB7->B7_DATA    := MV_PAR01
				SB7->B7_COD     := _cProd
				SB7->B7_LOCAL   := _cLoca
				SB7->B7_LOCALIZ := _cLocaliz
				SB7->B7_DOC     := "0001"
				SB7->B7_DTVALID := MV_PAR01
			Else
				RecLock("SB7",.F.)
			EndIf
			If !Empty(SB7->B7_LOTECTL)
				_PPP := 0
			EndIf
			SB7->B7_QUANT += If(_lTTer,_nTTer,_nTPri)
			/*/
			If SB1->B1_UM == "KG"
				SB7->B7_KILOS := SB7->B7_QUANT
			Else
				SB7->B7_KILOS := (SB7->B7_QUANT * SB1->B1_PESCOB)
			EndIf
			/*/
			_tot +=If(_lTTer,_nTTer,_nTPri)
			MsUnLock()
			If _lTTer
				_tt3 += _nTTer
			Else
				_tt1 += _nTPri
				_tt2 += _nTSeg
			EndIf
			_ttE += _nTErr
			DbSelectArea("SZG")
		Else
			Alert("Não Localizado Produto " + _cProd)
			mmm := 1
		EndIf
	EndDo
	
	If _ttE > 0
		Alert("Existe contagem fora de padrão")
		Alert(STR(_ttE))
	EndIf
	Alert(STR(_TT1))
	Alert(STR(_TT2))
	Alert(STR(_TT3))
	Alert(STR(_tot))
Return(.T.)


/*/{Protheus.doc} CriaRetal
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined

@type function
/*/
User Function CriaRetal()
	cPerg := "CDGN09"
	If !Pergunte(cPerg, .T.)
		Return(.T.)
	EndIf
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SZG")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	If FWCodEmp()+FWCodFil() == "0102" /// Cobrecom 3 Lagoas
		DbUseArea(.T.,cDrive,"\CONDUSUL\DIGRET3L.DTC","TRB",.T.,.F.)
	Else
		DbUseArea(.T.,cDrive,"\CONDUSUL\DIGRET.DTC","TRB",.T.,.F.)
	EndIf
	DbSelectArea("TRB")
	
	_nTotPlan := 0
	Do While TRB->(!Eof())
		_Prod := Left(Alltrim(Str(TRB->CODIGO)) + Space(TAMSX3("B1_COD")[1]),TAMSX3("B1_COD")[1])
		SB1->(DbSeek(xFilial("SB1")+ _Prod,.F.))
		For _ct := 1 to 60
			_Vari := "TRB->N"+AllTrim(Str(_ct))
			_Qtd  := &_Vari.
			If ValType(_Qtd) # "N"
				_Qtd  := Val(_Qtd)
			EndIf
			If _Qtd > 0
				_nTotPlan += _Qtd
	
				RecLock("SZG",.T.)
				SZG->ZG_FILIAL := xFilial("SZG")
				SZG->ZG_PRODUTO := _Prod
				SZG->ZG_DATA   := MV_PAR01 //CTOD("01/12/07")
				SZG->ZG_CONTAG := "1"
				SZG->ZG_LOCAL  := "01"
				SZG->ZG_DESC   := SB1->B1_DESC
				SZG->ZG_ACOND  := "T"
				SZG->ZG_QUANT  := 1
				SZG->ZG_LANCE  := _Qtd
				SZG->ZG_METROS := _Qtd
				SZG->ZG_LOTE   := "RETALHO"
				MsUnLock()
	
				RecLock("SZG",.T.)
				SZG->ZG_FILIAL := xFilial("SZG")
				SZG->ZG_PRODUTO := _Prod
				SZG->ZG_DATA   := MV_PAR01 //CTOD("01/12/07")
				SZG->ZG_CONTAG := "2"
				SZG->ZG_LOCAL  := "01"
				SZG->ZG_DESC   := SB1->B1_DESC
				SZG->ZG_ACOND  := "T"
				SZG->ZG_QUANT  := 1
				SZG->ZG_LANCE  := _Qtd
				SZG->ZG_METROS := _Qtd
				SZG->ZG_LOTE   := "RETALHO"
				MsUnLock()
	
			EndIf
		Next
		TRB->(DbSkip())
	EndDo
	Alert(_nTotPlan)
	
	DbSelectArea("TRB")
	DbCloseArea("TRB")
Return(.T.)


/*/{Protheus.doc} ValEmpe
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined

@type function
/*/
User Function ValEmpe()

	DbSelectArea("SC9")
	DbSetOrder(1) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	
	DbSelectArea("SBF")
	DbSetOrder(1) //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	
	DbSelectArea("SDC")
	DbSetOrder(3) //DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI+DC_ORIGEM
	DbSeek(xFilial("SDC"),.F.)
	Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->(!Eof())
		If SDC->DC_ORIGEM # "SC6"
			SDC->(DbSkip())
			Loop
		EndIf
		DbSelectArea("SC9")
		DbSetOrder(1)
		SC9->(DbSeek(xFilial("SC9")+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ+SDC->DC_PRODUTO,.F.))
		If SC9->(Eof()) .Or. !Empty(SC9->C9_BLEST ) .Or. !Empty(SC9->C9_BLCRED)
			DbSelectArea("SDC")
			RecLock("SDC",.F.)
			DbDelete()
			MsUnLock()
			SDC->(DbSkip())
		Else
			DbSelectArea("SBF")
			DbSetOrder(1)
			If !DbSeek(xFilial("SBF")+SDC->DC_LOCAL+SDC->DC_LOCALIZ+SDC->DC_PRODUTO,.F.)
				DbSelectArea("SDC")
				SDC->(DbSkip())
				_RegSDC := SDC->(Recno())
				DbSkip(-1)
				U_CDLibEst("E",SDC->DC_PRODUTO,SDC->DC_QUANT,SDC->DC_LOCAL,SDC->DC_LOCALIZ,SDC->DC_PEDIDO,SDC->DC_ITEM,SDC->DC_SEQ)
				DbSelectArea("SDC")
				DbGoTo(_RegSDC)
			Else
				RecLock("SBF",.F.)
				SBF->BF_EMPENHO += SDC->DC_QUANT
				MsUnLock()
				SDC->(DbSkip())
			EndIf
		EndIf
	EndDo
Return(.T.)


/*/{Protheus.doc} PesoZG
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined

@type function
/*/
User Function PesoZG()
	dbSelectArea("SB1")
	dbSetOrder(1)
	
	dbSelectArea("SZG")
	dbSetOrder(1) // ZG_FILIAL+ DTOS(ZG_DATA)+ZG_PRODUTO+ZG_LOCAL+ZG_ACOND+ STRZERO(ZG_LANCE,5)
	DbSeek(xFilial("SZG"),.T.)
	Do While SZG->ZG_FILIAL == xFilial("SZG") .And. SZG->(!EOF())
		_cProd := SZG->ZG_PRODUTO
	
		If SB1->(DbSeek(xFilial("SB1")+_cProd,.F.))
			RecLock("SZG",.F.)
			SZG->ZG_PESCOB := SZG->ZG_METROS*SB1->B1_PESCOB
			SZG->ZG_PESPVC := SZG->ZG_METROS*SB1->B1_PESPVC
			MsUnLock()
		EndIf
		DbSkip()
	EndDo
Return(.T.)


/*/{Protheus.doc} CriaBob
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function CriaBob()
	
	cPerg := "CDGN09"
	If !Pergunte(cPerg, .T.)
		Return(.T.)
	EndIf
	DbSelectArea("SB1")
	DbSetOrder(1)
	//DBOrderNickName("SB1CODCON")
	
	DbSelectArea("SZG")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	
	
	DbUseArea(.T.,cDrive,"\CONDUSUL\DIGBOB.DTC","TRB",.T.,.F.)
	DbSelectArea("TRB")
	
	Do While TRB->(!Eof())
		If TRB->LANCE > 0
			//		_Prod := Left(Alltrim(TRB->CODIGO)+"              " ,Len(SB1->B1_CODCON))
			_Prod := Left(Alltrim(TRB->CODIGO)+"              " ,Len(SB1->B1_COD))
			If SB1->(DbSeek(xFilial("SB1")+_Prod,.F.))
				RecLock("SZG",.T.)
				SZG->ZG_FILIAL := xFilial("SZG")
				SZG->ZG_PRODUTO := SB1->B1_COD
				SZG->ZG_DATA   := MV_PAR01 //CTOD("01/12/07")
				SZG->ZG_CONTAG := "1"
				SZG->ZG_LOCAL  := "01"
				SZG->ZG_DESC   := SB1->B1_DESC
				SZG->ZG_ACOND  := "B"
				SZG->ZG_QUANT  := 1
				SZG->ZG_LANCE  := TRB->LANCE
				SZG->ZG_METROS := TRB->LANCE
				SZG->ZG_LOTE   := "DIGBOB"
				MsUnLock()
	
				RecLock("SZG",.T.)
				SZG->ZG_FILIAL := xFilial("SZG")
				SZG->ZG_PRODUTO := SB1->B1_COD
				SZG->ZG_DATA   := MV_PAR01 //CTOD("01/12/07")
				SZG->ZG_CONTAG := "2"
				SZG->ZG_LOCAL  := "01"
				SZG->ZG_DESC   := SB1->B1_DESC
				SZG->ZG_ACOND  := "B"
				SZG->ZG_QUANT  := 1
				SZG->ZG_LANCE  := TRB->LANCE
				SZG->ZG_METROS := TRB->LANCE
				SZG->ZG_LOTE   := "DIGBOB"
				MsUnLock()
			EndIf
		EndIf
		TRB->(DbSkip())
	EndDo
	DbSelectArea("TRB")
	DbCloseArea("TRB")
Return(.T.)


/*/{Protheus.doc} EstDC
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined

@type function
/*/
User Function EstDC()
	If !AllTrim(cUserName)+"|" $ GetMV("MV_USERADM")
		Alert("Somente Administrador")
		Return(.T.)
	EndIf
	Processa( {|| Liber(.T.) },"Processando Tabela...")
Return(.T.)


/*/{Protheus.doc} LibDC
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined

@type function
/*/
User Function LibDC()
	If !AllTrim(cUserName)+"|" $ GetMV("MV_USERADM")
		Alert("Somente Administrador")
		Return(.T.)
	EndIf
	Processa( {|| Liber(.F.) },"Processando Tabela...")
Return(.T.)


/*/{Protheus.doc} Liber
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined
@param _lModo, , descricao
@type function
/*/
Static Function Liber(_lModo)
//_lModo=.t. -> Estorna Liberações do SDC
//_lModo=.f. -> Refaz Liberações do SDC
Local _PrxDC
	
	DbSelectArea("SC9")
	DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	
	_xSeek := If(xFilial("SDC") == "01","ZA","ZB")
	
	_cFili := If(_lModo,xFilial("SDC"),"ZZ")
	DbSelectArea("SBF")
	DbSetOrder(1)
	
	DbSelectArea("SC5")
	DbSetOrder(1)
	
	DbSelectArea("SDC")
	DbSetOrder(1)
	ProcRegua(LastRec())
	
	SDC->(DbSeek(xFilial("SDC"),.F.))
	Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->(!Eof())
		IncProc()
	
		If SDC->DC_ORIGEM # "SC6" .Or. SDC->DC_LOCAL == "10" .Or. Left(SDC->DC_LOCALIZ,1) == "B" // Usado quando o Rene pede pra estornar tudo que não é bobina
			SDC->(DbSkip())
			Loop
		EndIf
	
		//Não estornar tudo que esta em Faturamento
		DbSelectArea("SC5")
		If DbSeek(xFilial("SC5")+SDC->DC_PEDIDO,.F.)
			If SC5->C5_STATUS == "2" // -OK
				SDC->(DbSkip())
				Loop
			EndIf
		EndIf
	
		DbSelectArea("SC6")
		DbSetOrder(1)
		DbSeek(xFilial("SC6")+SDC->DC_PEDIDO+SDC->DC_ITEM,.F.)
	
		If !Empty(SC6->C6_RES_SZZ+SC6->C6_ITE_SZZ) // Não estorna o que estiver reservado
			SDC->(DbSkip())
			Loop
		EndIf
	
		//Não estornar quando material é retorno de industrialização.
		//Juliana - 01/08/2016
		If SC6->C6_FILIAL == '02' .And. !Empty(SC6->C6_ZZPVORI) .And. SC6->C6_QTDVEN > SC6->C6_QTDENT
			SDC->(DbSkip())
			Loop
		EndIf
	
		SDC->(DbSkip())
		_PrxDC := SDC->(Recno())
		//_PrxDC := SDC->(DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI)
		SDC->(DbSkip(-1))
	
		SC9->(DbSeek(xFilial("SC9")+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ,.F.))
		If !_lModo // Refaz as Liberações
			If SBF->(!DbSeek(xFilial("SBF")+SDC->DC_LOCAL+SDC->DC_LOCALIZ+SDC->DC_PRODUTO,.F.)) .Or. SC9->(Eof())
				DbSelectArea("SDC")
				RecLock("SDC",.F.)
				SDC->DC_FILIAL := _xSeek
				MsUnLock()
				Loop
			ElseIf (SBF->BF_QUANT-SBF->BF_EMPENHO) < SDC->DC_QUANT .Or. SBF->BF_EMPENHO < 0 .Or.;
				(SC9->C9_BLCRED+SC9->C9_BLEST) # "  02"
				// Não tem Saldo ou o SC9 já está Liberado/faturado
				DbSelectArea("SDC")
				RecLock("SDC",.F.)
				SDC->DC_FILIAL := _xSeek
				MsUnLock()
				Loop
			EndIf
		EndIf
		If SC9->(!Eof()) .And. SDC->DC_QUANT == SC9->C9_QTDLIB .And. ((_lModo .And. SC9->C9_BLEST == "  ")  .Or. (!_lModo .And. SC9->C9_BLEST == "02"))
			// Atenção: O 11ro parâmetro deve ser diferente em cada chamada da função CDLibEst para poder
			// identificar a origem da liberação. Esta informação será gravada no campo DC_TPLIB.
			// Incluir este comentário em todas as chamadas da função quando for LIBERAÇÃO.
			U_CDLibEst(If(_lModo,"E","L"),SDC->DC_PRODUTO,SDC->DC_QUANT,SDC->DC_LOCAL,SDC->DC_LOCALIZ,SDC->DC_PEDIDO,SDC->DC_ITEM,SDC->DC_SEQ,.T.,,"C")
		Else
			DbSelectArea("SDC")
			RecLock("SDC",.F.)
			SDC->DC_FILIAL := _xSeek
			MsUnLock()
		EndIf
	    SDC->(DbSetOrder(1))
		SDC->(DbGoTo(_PrxDC))
		SDC->(DbSeek(xFilial("SDC"),.F.))
		//SDC->(DbSeek(_PrxDC,.F.))
	
		//	SDC->(DbSkip())
	EndDo
	
	If !_lModo .And. SDC->(DbSeek(_xSeek,.F.))// Refaz as Liberações
		Do While SDC->(DbSeek(_xSeek,.F.))
			RecLock("SDC",.F.)
			DbDelete()
			//		SDC->DC_FILIAL := "ZZ"
			MsUnLock()
		EndDo
		//	Alert("Verifique Liberações não Realizadas - (Sem Saldo")
	EndIf
Return(.T.)


/*/{Protheus.doc} LE_COLETOR
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined

@type function
/*/
User Function LE_COLETOR()
	If !u_IncInv()
		Return(.T.)
	EndIf
	_cMens := "Lendo Arquivos Baixados..."
	Processa( {|| LeiaDir() },_cMens)
Return(.T.)


/*/{Protheus.doc} LeiaDir
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined

@type function
/*/
Static Function LeiaDir()
	If FWCodEmp()+FWCodFil() == "0101" /// Cobrecom Itu
		aFiles := ARRAY(ADIR("\COLETORES\INVENT*.T?T"))
		ADIR("\COLETORES\INVENT*.T?T",aFiles)
	ElseIf FWCodEmp()+FWCodFil() == "0102" /// Cobrecom 3 Lagoas
		// Copiar do Drive D: para o servidor na pasta \COLET3L
		aFilesMs := Array(ADIR("D:\COLETORES\INVENT*.T?T"))
		ADIR("D:\COLETORES\INVENT*.T?T",aFilesMs)
		For _nArqs := 1 to Len(aFilesMS)
			IncProc()
			_cArqOrig := "D:\COLETORES\" + AllTrim(aFilesMS[_nArqs])
			CPYT2S(_cArqOrig,"\COLET3L\",.F.)
			DELETE FILE &_cArqOrig.
		Next
		aFiles := ARRAY(ADIR("\COLET3L\INVENT*.T?T"))
		ADIR("\COLET3L\INVENT*.T?T",aFiles)
	EndIf
	
	If Len(aFiles) <= 0
		Return(.T.)
	EndIf
	
	aStruTrb := {}
	AADD(aStruTrb,{"CAMPO","C",40,0} ) // Tipo do registro
	
	if U_zIs12()
		cNomTrb0 := AllTrim(CriaTrab(,.F.))
		FWDBCreate( cNomTrb0 , aStruTrb , "CTREECDX")
	else
		cNomTrb0 := CriaTrab(aStruTrb)
	endif
	dbUseArea(.T.,cDrive,cNomTrb0,"TRB",.F.,.F.) // Abre o arquivo de forma exclusiva
	DbSelectArea("TRB")
	
	ProcRegua(Len(aFiles))
	For _nArqs := 1 to Len(aFiles)
		IncProc()
		If FWCodEmp()+FWCodFil() == "0101" /// Cobrecom Itu
			_cArqT := "\COLETORES\"+aFiles[_nArqs]
		ElseIf FWCodEmp()+FWCodFil() == "0102" /// Cobrecom 3 Lagoas
			_cArqT := "\COLET3L\"+aFiles[_nArqs]
		EndIf
		Append from &_cArqT. SDF
		DbGoBottom()
		If "COLETORES\INVENTARIO" $ Upper(_cArqT) // Layout/coletor  Novo
			_cArqR := Left(_cArqT,Len(_cArqT)-3)+"OLI"
		Else  // Coletor velho
			_cContag := Substr(TRB->CAMPO,01,01)
			If Substr(TRB->CAMPO,09,04)	$ "8000/9600" .And. _cContag == "9" // Transferência de Bobinas - não interessa aqui
				_cArqR := Left(_cArqT,Len(_cArqT)-3)+"TXB" //
			Else
				_cArqR := Left(_cArqT,Len(_cArqT)-3)+"OLI"
			EndIf
		EndIf
		Rename &(_cArqT) to &(_cArqR)
	Next
	_cMens := "Processando Dados dos Coletores"
	DbSelectArea("SB1")
	DbSetOrder(5) //B1_FILIAL+B1_CODBAR
	
	_nLidos := 0
	_nGravs := 0
	_nDuplic := 0
	
	DbSelectArea("TRB")
	ProcRegua(LastRec())
	DbGoTop()
	Do While TRB->(!Eof())
		++_nLidos
		IncProc()
	
		If Empty(TRB->CAMPO)
			DbSelectArea("TRB")
			TRB->(DbSkip())
			Loop
		EndIf
	
		_cLinhaTRB := AllTrim(TRB->CAMPO)
		If Len(_cLinhaTRB) == 22
			_cLinhaTRB := Left(_cLinhaTRB,16) + "X" + Right(_cLinhaTRB,6)
			RecLock("TRB",.F.)
			TRB->CAMPO := _cLinhaTRB
			MsUnLock()
		EndIf
	
		_TpColet := (Len(AllTrim(TRB->CAMPO)) == 23) // Coletor novo tem 23 bytes e o velho tem 32
		XXX:= " "
		If _TpColet // Novo
			_cContag := Substr(TRB->CAMPO,04,01)
			_cOperad := Substr(TRB->CAMPO,01,03)
			_cCorred := Substr(TRB->CAMPO,05,01)
			_cBarras := Substr(TRB->CAMPO,06,12)
			_cQuant  := Substr(TRB->CAMPO,18,06)
		Else
			_cContag := Substr(TRB->CAMPO,01,01)
			_cOperad := Substr(TRB->CAMPO,02,06)
			_cCorred := Substr(TRB->CAMPO,08,01)
			_cBarras := Substr(TRB->CAMPO,09,12)
			_cQuant  := Substr(TRB->CAMPO,27,06)
		EndIf
		If Left(_cBarras,2) == "97" // Sacaria não entra no inventário
			XXX:= "X"
			//		DbSelectArea("TRB")
			//		TRB->(DbSkip())
			//		Loop
		EndIf
		_cAcond := " "
		_cLocal := "01"
		_lAchei := .F. // controla se deve gravar no SZG
	
		// Verificar se uma bobina do EPA ou do ESA
		If Left(_cBarras,5) == "95000" // Bobina do ESA
			_cLocal   := "95"
			_cControl := Substr(_cBarras,06,06)
			DbSelectArea("SZU")
			DbSetOrder(3) // ZU_FILIAL+ZU_CONTROL
			If DbSeek(xFilial("SZU") + _cControl,.F.)
				If SZU->ZU_DTINV # MV_PAR01
					_lAchei := .T.
					RecLock("SZU",.F.)
					SZU->ZU_STATUS := "3"
					SZU->ZU_DTINV  := MV_PAR01
					MsUnLock()
	
					// Posiciona SB1
					DbSelectArea("SB1") //B1_FILIAL+B1_CODBAR
					DbSetOrder(1) //B1_FILIAL+B1_COD
					DbSeek(xFilial("SB1") + SZU->ZU_PRODUTO,.F.)
				Else
					Alert("Bobina ESA " + _cControl + " capturado em duplicidade -> Desconsiderado!!!")
				EndIf
			EndIf
			_nLance := SZU->ZU_TOTAL
		ElseIf Left(_cBarras,4) $  "/9600/9601/9602" .Or. (Left(_cBarras,4) == "8000" .And. Substr(_cBarras,5,2) $ "09/10") // Bobina do EPA
			_cnBob := Substr(_cBarras,05,07)
			_cFilb := Substr(_cBarras,03,02)
			If _cFilb == "00"
				_cFilb := xFilial("SZE")
			EndIf
			DbSelectArea("SZE")
			DbSetOrder(6) // ZE_FILORIG+ZE_NUMBOB
			If !DbSeek(_cFilb+_cnBob,.F.)
				RecLock("SZE",.T.)
				SZE->ZE_FILIAL  := xFilial("SZE")
				SZE->ZE_NUMBOB  := _cnBob
			Else
				RecLock("SZE",.F.)
			EndIf
			//		SZE->ZE_FILIAL := xFilial("SZE") // Gravar sempre a filial atual
			If SZE->ZE_DTINV == MV_PAR01
				_nDuplic++
			Else
				_nGravs++
			EndIf
			SZE->ZE_DTINV  := MV_PAR01
			MsUnLock()
	
			DbSelectArea("TRB")
			TRB->(DbSkip())
			Loop
		Else // Trata-se de Rolo/Carretel/ CM /Blister
			// Verificar se o cod de barras é no formato antigo ou novo
			_cNewBar := Left(_cBarras,11)
			_lNewBar := (Val(Right(_cNewBar,5)) > 9000) // Formato novo do cod de barras
			// Verifica se os ultimos 5 digitos é maior que 9000, pois no formato antigo
			// era 100100 e agora é 10100 onde o primeiro 1 é o cacondidonamento
			// tirei um dígito da metragem.
	
			_nDigBb := If(_lNewBar,7,6)
			_cAcond := Substr("RCMBTL",Val(Substr(_cBarras,_nDigBb,1)),1)
	
			// Verificar se é uma bobina com cod de barras velho
			If _cAcond == "B" // Trata-se de bobina... DESCONSIDERAR
				Alert("Erro 1 " + TRB->CAMPO)
				TRB->(DbSkip())
				Loop
			EndIf
	
			If _lNewBar // Formato novo do cod de barras
				If Left(_cBarras,1) == "9"
					_cCodBar := "789825925"+Substr(_cBarras,2,3)
				Else
					_cCodBar := "78996747"+Left(_cBarras,4)
				EndIf
			Else
				_cCodBar := "789825925"+Left(_cBarras,3)
			EndIf
			// _cCodBar := Left(_cCodBar + Space(20),Len(SB1->B1_CODBAR))
			_cCodBar := Left(_cCodBar + Space(20),12)
			// Somente os 12 primeiro dígitos pois pode haver no cadastro SB1 oi SZJ com 13... (com dígito verificador)
	
			If _lNewBar // Formato novo do cod de barras
				_cEspeci := Substr(_cBarras,5,2)
				_nLance  := Val(Substr(_cBarras,8,4))
			Else
				_cEspeci := Substr(_cBarras,4,2)
				_nLance  := Val(Substr(_cBarras,7,5))
			EndIf
	
			_lAchei := .F.
	
			DbSelectArea("SZJ")
			DbSetOrder(2)
			If DbSeek(xFilial("SZJ")+_cCodBar,.F.)
				DbSelectArea("SB1") //B1_FILIAL+B1_CODBAR
				DbSetOrder(1) //B1_FILIAL+B1_CODIGO
				DbSeek(xFilial("SB1")+SZJ->ZJ_PRODUTO,.F.)
				_lAchei := .T.
			Else
				DbSelectArea("SB1") //B1_FILIAL+B1_CODBAR
				DbSetOrder(5) //B1_FILIAL+B1_CODBAR
				DbSeek(xFilial("SB1")+_cCodBar,.F.)
				Do While SB1->B1_FILIAL == xFilial("SB1") .And. Left(SB1->B1_CODBAR,12) == _cCodBar .And. SB1->(!Eof())
					If _cEspeci == Substr(SB1->B1_COD,9,2)
						_lAchei := .T.
						Exit
					EndIf
					SB1->(DbSkip())
				EndDo
			EndIf
		EndIf
	
		If Left(SB1->B1_COD,3) == "153"
			ssddf := 1
		EndIf
	
		If Val(_cCorred) > 0
			_cCorred := Substr("XABCDEFGHI",Val(_cCorred)+1,1)
		EndIf
		_cCorred := Upper(_cCorred)
		If _lAchei
			RecLock("SZG",.T.)
			SZG->ZG_FILIAL  := xFilial("SZG")
			SZG->ZG_PRODUTO := SB1->B1_COD
			SZG->ZG_DATA    := MV_PAR01
			SZG->ZG_CONTAG  := _cContag
			SZG->ZG_LOCAL   := _cLocal
			SZG->ZG_DESC    := SB1->B1_DESC
			SZG->ZG_ACOND   := _cAcond
			SZG->ZG_QUANT   := Val(_cQuant)
			SZG->ZG_LANCE   := _nLance
			SZG->ZG_METROS  := (SZG->ZG_QUANT*SZG->ZG_LANCE)
			SZG->ZG_PESCOB  := SZG->ZG_METROS*SB1->B1_PESCOB
			SZG->ZG_PESPVC  := SZG->ZG_METROS*SB1->B1_PESPVC
			SZG->ZG_LOTE    := _cCorred
			SZG->ZG_FORMA   := If(!Empty(XXX),"X","C")
			MsUnLock()
		Else
			Alert(	"Atenção: ERRO 2" + Chr(13) + Chr(13) + ;
			"A coleta abaixo não foi identificada, verifique a etiqueta no produto: " + Chr(13) + Chr(13) + ;
			"Usuário...: " + Substr(TRB->CAMPO,01,03) + Chr(13) + ;
			"Contagem..: " + Substr(TRB->CAMPO,04,01) + Chr(13) + ;
			"Local.....: " + Substr(TRB->CAMPO,05,01) + Chr(13) + ;
			"Cód.Barras: " + Substr(TRB->CAMPO,06,11) + Chr(13) + ;
			"Tam.Lance.: " + Substr(TRB->CAMPO,12,05) + Chr(13) + ;
			"Quantidade: " + Substr(TRB->CAMPO,18,06) + Chr(13))
			ddd:="n"
		EndIf
		DbSelectArea("TRB")
		TRB->(DbSkip())
	EndDo
	
	DbSelectArea("TRB")
	DbCloseArea("TRB")
	
	DbSelectArea("SZG")
Return(.T.)


/*/{Protheus.doc} SldRetB7
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined

@type function
/*/
Static Function SldRetB7() // Função em desuso-Serve para repetir a quantidade em estoque dos retalhos para o inventário.
	DbSelectArea("SB7")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	ProcRegua(LastRec())
	SB7->(DbSeek(xFilial("SB7")+Dtos(MV_PAR01),.T.))
	_tot := 0.00
	Do While SB7->B7_FILIAL == xFilial("SB7") .And. SB7->B7_DATA == MV_PAR01 .And. SB7->(!Eof())
		IncProc()
		//	If (SB7->B7_LOCAL == "01" .And. Left(SB7->B7_LOCALIZ,1)== "T") .Or. SB7->B7_LOCAL $ "90/95" // "90/98/95"
	
		If SB7->B7_LOCAL == "01" .And. Left(SB7->B7_LOCALIZ,1)== "T" //Só retalhos
			If MV_PAR01 <> ctod("30/01/2017")
				Alert("1-erro MV_PAR01 " + Dtoc(mv_par01))
			EndIf
			_aEst := CalcEstL(SB7->B7_COD,SB7->B7_LOCAL,MV_PAR01+1,,,SB7->B7_LOCALIZ,,)
			If SB7->B7_QUANT # _aEst[1]
				RecLock("SB7",.F.)
				SB7->B7_QUANT := _aEst[1]
				_tot += SB7->B7_QUANT
				MsUnLock()
			EndIf
		EndIf
		SB7->(DbSkip())
	EndDo
	Alert(STR(_tot))
Return(.T.)


/*/{Protheus.doc} BaixeSuc
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined

@type function
/*/
User Function BaixeSuc()
Private __cNomArq := ""                               // Arquivo Temporario
Private _aCampos := {}
	
	lMsErroAuto := .F.
	
	aAdd(_aCampos, {"PRODUTO", "C", TamSX3("B1_COD")[1], 0})
	aAdd(_aCampos, {"DESCRI" , "C", 45, 0})
	aAdd(_aCampos, {"LOCALIZ", "C", TamSX3("BE_LOCALIZ")[1], 0})
	aAdd(_aCampos, {"QTDABX" , "N", 12, 2})
	aAdd(_aCampos, {"QTDBX"  , "N", 12, 2})
	aAdd(_aCampos, {"QTDBF"  , "N", 12, 2})
	aAdd(_aCampos, {"EMPBF"  , "N", 12, 2})
	
	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	
	if U_zIs12()
		_cNomArq := AllTrim(CriaTrab(,.F.))
		FWDBCreate( _cNomArq , _aCampos , "CTREECDX")
	else
		_cNomArq := CriaTrab(_aCampos, .T.)
	endif
	
	DbUseArea(.T.,cDrive, _cNomArq, "TRB", .T., .F.)
	
	_MV_PAR01 := Ctod("26/06/2015")
	
	dbSelectArea("SB1")
	dbSetOrder(1)
	
	dbSelectArea("SZG")
	dbSetOrder(1) // ZG_FILIAL+ DTOS(ZG_DATA)+ZG_PRODUTO+ZG_LOCAL+ZG_ACOND+ STRZERO(ZG_LANCE,5)
	DbSeek(xFilial("SZG")+DTOS(_MV_PAR01),.T.)
	Do While SZG->ZG_FILIAL == xFilial("SZG") .And. SZG->ZG_DATA == _MV_PAR01 .And. SZG->(!EOF())
		_cProd := SZG->ZG_PRODUTO
		_cDesc := SZG->ZG_DESC
		_cLoca := SZG->ZG_LOCAL
		_cAcon := SZG->ZG_ACOND
		_cLanc := SZG->ZG_LANCE
		_DESC := SZG->ZG_DESC
		If SZG->ZG_LOCAL == "90" //RETRABALHO
			_cLocaliz := Left("RTB"+Space(40),Len(SBE->BE_LOCALIZ))
		ElseIf SZG->ZG_LOCAL == "98" // C.Q.
			_cLocaliz := Left("CQ"+Space(40),Len(SBE->BE_LOCALIZ))
		Else //If SZG->ZG_LOCAL == "01"
			_cLocaliz := If(_cLoca=="00","PROD",SZG->ZG_ACOND + StrZero(SZG->ZG_LANCE,5))
			_cLocaliz := Left(_cLocaliz+Space(40),Len(SBE->BE_LOCALIZ))
		EndIf
	
		_nQuant := 0.00
	
		Do While SZG->ZG_FILIAL == xFilial("SZG") .And. SZG->ZG_DATA == _MV_PAR01 .And. SZG->(!EOF()) .And.;
			SZG->ZG_PRODUTO == _cProd .And. SZG->ZG_LOCAL == _cLoca .And. SZG->ZG_ACOND == _cAcon .And. SZG->ZG_LANCE == _cLanc
			If AllTrim(SZG->ZG_LOTE) $ "TO"
				_nQuant += SZG->ZG_METROS
			EndIf
			SZG->(DbSkip())
		EndDo
	
		If _nQuant <= 0
			Loop
		EndIf
	
		RecLock("TRB",.T.)
		TRB->PRODUTO := _cProd
		TRB->DESCRI  := _DESC
		TRB->LOCALIZ := _cLocaliz
		TRB->QTDABX  := _nQuant
		MsUnLock()
	
		SB1->(DbSeek(xFilial("SB1")+_cProd,.F.))
	
		DbSelectArea("SBE")
		DbSetOrder(1)
		If !DbSeek(xFilial("SBE") + _cLoca + _cLocaliz,.F.)
			If _cAcon == "T"
				_cDesLo :=  "Retalho de "
			ElseIf _cAcon == "B"
				_cDesLo :=  "Bobina de "
			ElseIf _cAcon == "M"
				_cDesLo :=  "Carretel de Mad.de "
			ElseIf _cAcon == "C"
				_cDesLo :=  "Carretel de "
			ElseIf _cAcon == "R"
				_cDesLo :=  "Rolo de "
			ElseIf _cAcon == "L"
				_cDesLo :=  "Blister de "
			EndIf
			//_cDesLo +=  Str(_cLanc,5) + " metros"
			_cDesLo +=  Str(_cLanc,5) + " " + Posicione("SAH",1,xFilial("SAH")+SB1->B1_UM,"AH_DESCPO")
			RecLock("SBE",.T.)
			SBE->BE_FILIAL   := xFilial("SBE")
			SBE->BE_LOCAL    := _cLoca
			SBE->BE_LOCALIZ  := _cLocaliz
			SBE->BE_DESCRIC  := _cDesLo
			SBE->BE_PRIOR    := "ZZZ"
			SBE->BE_STATUS   := "1"
			MsUnLock()
		EndIf
	
	
		If SB1->(DbSeek(xFilial("SB1")+_cProd,.F.))
			DbSelectArea("SBF")
			DbSetOrder(1) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
			If DbSeek(xFilial("SBF")+_cLoca+_cLocaliz+_cProd,.F.)
				RecLock("TRB",.F.)
				TRB->QTDBF := SBF->BF_QUANT
				TRB->EMPBF := SBF->BF_EMPENHO
				MsUnLock()
	
				//			If Left(_cLocaliz,1) == "T" // Se for retalho tirar o que dá se não tiver tudo
				If (SBF->BF_QUANT-SBF->BF_EMPENHO) < _nQuant .And. SBF->BF_EMPENHO >= 0
					_nQuant := (SBF->BF_QUANT-SBF->BF_EMPENHO)
				EndIf
				//			EndIf
	
				If (SBF->BF_QUANT-SBF->BF_EMPENHO) >= _nQuant .And. SBF->BF_EMPENHO >= 0 .And. _nQuant > 0
	
					// Prepara o Movimento no SD3
					SD3->(DbSetOrder(2))
					Do While .T.
						_DocD3 :=GetSx8Num("SD3","D3_DOC")
						ConfirmSx8()
						If SD3->(!DbSeek(xFilial("SD3")+_DocD3,.F.))
							Exit
						EndIf
					EndDo
					//_aVetor:={{"D3_TM"      ,"520"             ,NIL},;  -> MATERIAL SUCATEADO
					//_aVetor:={{"D3_TM"      ,"523"             ,NIL},;  -> ENVIO PARA RETRABALGO
					//_aVetor:={{"D3_TM"      ,"506"             ,NIL},;  -> REQ.PARA REPROCESSO
					_aVetor:={	{"D3_TM"      ,"506"             ,NIL},;
								{"D3_COD"     ,_cProd   ,NIL},;
								{"D3_LOCAL"   ,_cLoca     ,NIL},;
								{"D3_LOCALIZ" ,_cLocaliz   ,NIL},;
								{"D3_DOC"     ,_DocD3            ,NIL},;
								{"D3_QUANT"   ,_nQuant           ,NIL},;
								{"D3_EMISSAO" ,dDataBase         ,NIL}}
	
					// Realiza o Movimento no SD3
					_cVoltaMSE := MSExecAuto({|x,y| Mata240(x,y)},_aVetor,3)
					If lMsErroAuto
						MOSTRAERRO()
						lMsErroAuto := .F.
					Else
						RecLock("TRB",.F.)
						TRB->QTDBX := _nQuant
						MsUnLock()
					EndIf
				EndIf
			EndIf
		Else
			xx := "não achei o produto"
		EndIf
		dbSelectArea("SZG")
	EndDo
Return(.t.)


/*/{Protheus.doc} PrcB7
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function PrcB7()
	If !AllTrim(cUserName)+"|" $ GetMV("MV_USERADM")
		Alert("Somente Administrador")
		Return(.T.)
	EndIf
	
	If MsgBox("Deseja Iniciar o Processamento do Inventário?","Confirma?","YesNo")
	
		//_cLangAtu := __LANGUAGE
		//__LANGUAGE := "ENGLISH"
	
		_Mv_par01 := MV_PAR01
		_Mv_par02 := MV_PAR02
		_Mv_par03 := MV_PAR03
		_Mv_par04 := MV_PAR04
		_Mv_par05 := MV_PAR05
		_Mv_par06 := MV_PAR06
		_Mv_par07 := MV_PAR07
		_Mv_par08 := MV_PAR08
		_Mv_par09 := MV_PAR09
		_Mv_par10 := MV_PAR10
		_Mv_par11 := MV_PAR11
	
		// Como estou usando diversas rotinas no EXECAUTO, altero dDataBase para que não haja movimento com data errada
		_MyDtBase := dDataBase
		dDataBase := MV_PAR01
	
		//	Processa( {|| UpdEmp() },"Atualizando Saldo de Empenho...")
		If GetMv("MV_XMODOIN") == 1 // 	Modo de calculo do Inventario 1-Normal 2-Bloco K
			Processa( {|| ProcSB7() },"Processando Ajuste do Inventário (SB7)...")
		Else
			// Processar da forma Bloco K
			Processa( {|| ProcBLK() },"Processando Ajuste do Inventário (BlK)...")
		EndIf
	
		MsgBox("Processamento Concluido" , "Atencao !!!", "INFO")
	
		dDataBase := _MyDtBase
		Mv_par01 := _MV_PAR01
		Mv_par02 := _MV_PAR02
		Mv_par03 := _MV_PAR03
		Mv_par04 := _MV_PAR04
		Mv_par05 := _MV_PAR05
		Mv_par06 := _MV_PAR06
		Mv_par07 := _MV_PAR07
		Mv_par08 := _MV_PAR05
		Mv_par09 := _MV_PAR09
		Mv_par10 := _MV_PAR10
		Mv_par11 := _MV_PAR11
		//__LANGUAGE := _cLangAtu
	EndIf
Return(.T.)


/*/{Protheus.doc} UpdEmp
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
Static Function UpdEmp()
Local aCAB    := {}
Local aITENS  := {}

	// Zero o empenho da SBF - Saldo por Endereço
	cQuery := ""
	cQuery := " UPDATE " + RetSqlName("SBF")
	cQuery += " SET BF_EMPENHO = 0 "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND BF_FILIAL = '" + xFilial("SBF")+"'"
	TCSqlExec(cQuery)
	
	// Zero o empenho da SB2
	cQuery := ""
	cQuery := " UPDATE " + RetSqlName("SB2")
	cQuery += " SET B2_RESERVA = 0 "
	cQuery += " WHERE D_E_L_E_T_ <> '*'"
	cQuery += " AND B2_FILIAL = '" + xFilial("SB2")+"'"
	TCSqlExec(cQuery)
	
	DbSelectArea("SBE")
	DbSetOrder(1)
	
	DbSelectArea("SDB")
	DbSetOrder(1)
	
	DbSelectArea("SB7")
	DbSetOrder(1) //B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE+B7_CONTAGE
	
	// Distribuição dos saldos a distribuir
	cQuery :=""
	cQuery +=" SELECT * FROM " +RetSqlName("SDA")
	cQuery +=" WHERE D_E_L_E_T_ <> '*' "
	cQuery +=" AND DA_FILIAL = '" +xFilial("SDA")+"'"
	cQuery +=" AND DA_DATA <= '" +DtoS(_Mv_par01)+"'"
	cQuery +=" AND DA_SALDO > 0 "
	
	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea("TRB")
	EndIf
	
	TCQUERY cQuery NEW ALIAS "TRB"
	//TCSETFIELD("TRB","C6_METRAGE","N",12,2)
	//TCSETFIELD("TRB","QUANT","N",12,2)
	//TCSETFIELD("TRB","C6_ENTREG","D")
	
	DbSelectArea("TRB")
	DbGoTop()
	ProcRegua(RecCount())
	
	While TRB->(!Eof())
		IncProc()
	
		DbSelectArea("SBE")
		If !DbSeek(xFilial("SBE") + TRB->DA_LOCAL + "NAODISTRI",.F.)
	
			RecLock("SBE",.T.)
			SBE->BE_FILIAL   := xFilial("SBE")
			SBE->BE_LOCAL    := TRB->DA_LOCAL
			SBE->BE_LOCALIZ  := "NAODISTRI"
			SBE->BE_DESCRIC  := "NAO DISTRIBUIDO"
			SBE->BE_PRIOR    := "ZZZ"
			SBE->BE_STATUS   := "1"
			MsUnLock()
		EndIf
	
		// Efetua a distribuição das quantidades.
		aCAB  := {	{"DA_PRODUTO" ,TRB->DA_PRODUTO             , nil},;
					{"DA_QTDORI"  ,TRB->DA_QTDORI              , nil},;
					{"DA_SALDO"   ,TRB->DA_SALDO               , nil},;
					{"DA_DATA"    ,TRB->DA_DATA                , nil},;
					{"DA_LOCAL"   ,TRB->DA_LOCAL               , nil},;
					{"DA_DOC"     ,TRB->DA_DOC                 , nil},;
					{"DA_ORIGEM"  ,TRB->DA_ORIGEM              , nil},;
					{"DA_NUMSEQ"  ,TRB->DA_NUMSEQ              , nil},;
					{"DA_QTSEGUM" ,TRB->DA_QTSEGUM             , nil},;
					{"DA_QTDORI2" ,TRB->DA_QTDORI2             , nil}}
	
		//DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM
		SDB->(dbSeek(xFilial("SDB")+TRB->DA_PRODUTO+TRB->DA_LOCAL+TRB->DA_NUMSEQ+TRB->DA_DOC+TRB->DA_SERIE+TRB->DA_CLIFOR+TRB->DA_LOJA,.F.))
	
		_cDbItem := Replicate("0",Len(SDB->DB_ITEM))
	
		While SDB->(!Eof()) .And. ;
			xFilial("SDB")+TRB->DA_PRODUTO+TRB->DA_LOCAL+TRB->DA_NUMSEQ+TRB->DA_DOC+TRB->DA_SERIE+TRB->DA_CLIFOR+TRB->DA_LOJA == ;
			SDB->DB_FILIAL+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_NUMSEQ+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA
	
			If SDB->DB_ITEM > _cDbItem
				_cDbItem := SDB->DB_ITEM
			EndIf
	
	 		SDB->(dbSkip())
		EndDo
	
		_cDbItem := Soma1(_cDbItem)
	
		aITENS:={{	{"DB_ITEM"    , _cDbItem         , nil},;
					{"DB_LOCALIZ" , SBE->BE_LOCALIZ            , nil},;
					{"DB_QUANT"   , TRB->DA_SALDO              , nil},;
					{"DB_DATA"    , _Mv_par01                  , nil},;
					{"DB_ESTORNO" ," "                         , nil} }}
	
		lMsErroAuto:=.f.
		_cVoltaMSE := msExecAuto({|x,y|mata265(x,y)},aCAB,aITENS)
		If lMsErroAuto
			MostraErro()
		EndIf
	
		If SB7->(!DbSeek( xFilial("SB7")+ DTOS(_Mv_par01) + TRB->DA_PRODUTO + TRB->DA_LOCAL + SBE->BE_LOCALIZ,.F.))
	
			RecLock("SB7",.T.)
			SB7->B7_FILIAL  := xFilial("SB7")
			SB7->B7_COD     := TRB->DA_PRODUTO
			SB7->B7_LOCAL   := TRB->DA_LOCAL
			SB7->B7_LOCALIZ := SBE->BE_LOCALIZ
			SB7->B7_DOC     := "0001"
			SB7->B7_QUANT   := 0.00
			SB7->B7_DATA    := _Mv_par01
			SB7->B7_DTVALID := _Mv_par01
			MsUnLock()
		EndIf
		TRB->(dbSkip())
	
	EndDo
	
	// Atualizo SBF conforme SDC
	cQuery := ""
	cQuery := " UPDATE " + RetSqlName("SBF")
	cQuery += " SET SBF010.BF_EMPENHO =   (SELECT SUM(DC.DC_QUANT) "
	cQuery += " 						  FROM " + RetSqlName("SDC") + " DC "
	cQuery += " 						  WHERE DC.D_E_L_E_T_ <> '*' "
	cQuery += " 					      AND DC.DC_FILIAL  = '" + xFilial("SDC") + "'"
	cQuery += "							  AND DC.DC_PRODUTO = SBF010.BF_PRODUTO "
	cQuery += "							  AND DC.DC_LOCAL   = SBF010.BF_LOCAL "
	cQuery += " 					      AND DC.DC_LOCALIZ = SBF010.BF_LOCALIZ "
	cQuery += "							  GROUP BY DC.DC_FILIAL,DC.DC_PRODUTO,DC.DC_LOCAL,DC.DC_LOCALIZ) "
	cQuery += " WHERE "
	cQuery += "	SBF010.D_E_L_E_T_ <> '*' "
	cQuery += "	AND SBF010.BF_FILIAL = '" +xFilial("SBF") + "'"
	cQuery += " AND (SELECT SUM(DC.DC_QUANT) "
	cQuery += "		 FROM " + RetSqlName("SDC") + " DC "
	cQuery += "		 WHERE DC.D_E_L_E_T_ <> '*'"
	cQuery += "		 AND DC.DC_FILIAL  = '" + xFilial("SDC") + "'"
	cQuery += "		 AND DC.DC_PRODUTO = SBF010.BF_PRODUTO "
	cQuery += "		 AND DC.DC_LOCAL   = SBF010.BF_LOCAL "
	cQuery += "		 AND DC.DC_LOCALIZ = SBF010.BF_LOCALIZ "
	cQuery += "		 GROUP BY DC.DC_FILIAL,DC.DC_PRODUTO,DC.DC_LOCAL,DC.DC_LOCALIZ) >= 0"
	TCSqlExec(cQuery)
	
	// Atualizo SB2 conforme SDC
	cQuery := ""
	cQuery := " UPDATE " + RetSqlName("SB2")
	cQuery += " SET SB2010.B2_RESERVA = (SELECT SUM(DC.DC_QUANT) "
	cQuery += " 						 FROM " + RetSqlName("SDC") + " DC "
	cQuery += " 						 WHERE DC.D_E_L_E_T_ <> '*' "
	cQuery += "       					 AND DC.DC_FILIAL  = '" + xFilial("SDC") + "'"
	cQuery += "		  					 AND DC.DC_PRODUTO = B2.B2_COD "
	cQuery += "		  					 AND DC.DC_LOCAL   = B2.B2_LOCAL "
	cQuery += " 						 GROUP BY DC.DC_FILIAL,DC.DC_PRODUTO,DC.DC_LOCAL)"
	cQuery += " FROM " + RetSqlName("SB1")+ " B1 "
	cQuery += " WHERE B2.B2_COD   = B1.B1_COD "
	cQuery += " AND B1.B1_LOCALIZ = 'S'  AND B1.D_E_L_E_T_ <> '*' "
	cQuery += " AND B2.B2_RESERVA <> ( SELECT SUM(DC.DC_QUANT) "
	cQuery += " 						 FROM " + RetSqlName("SDC") + " DC "
	cQuery += " 						 WHERE DC.D_E_L_E_T_ <> '*' "
	cQuery += "       					 AND DC.DC_FILIAL  = '" + xFilial("SDC") + "'"
	cQuery += "		  					 AND DC.DC_PRODUTO = B2.B2_COD "
	cQuery += "		  					 AND DC.DC_LOCAL   = B2.B2_LOCAL "
	cQuery += " 						 GROUP BY DC.DC_FILIAL,DC.DC_PRODUTO,DC.DC_LOCAL) > 0 "
	TCSqlExec(cQuery)

Return(.T.)


/*/{Protheus.doc} ProcSB7
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined

@type function
/*/
Static Function ProcSB7()
Private Mv_par01,Mv_par02,Mv_par03,Mv_par04,Mv_par05,Mv_par06,Mv_par07,_nValEst
	
	_aRelato := {}
	
	If !u_IncInv()
		Return(.T.)
	EndIf
	
	cQuery := ""
	cQuery += " SELECT COUNT(*) QTDREG FROM "+RetSqlName("SB7")
	cQuery += " WHERE B7_FILIAL = '"+xFilial("SB7")+"'"
	cQuery += " AND B7_DATA = '"+dtos(_Mv_par01)+"'"
	cQuery += " AND D_E_L_E_T_ <>'*'"
	cQuery := ChangeQuery(cQuery)
	
	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"
	
	DbSelectArea("TRB")
	DbGotop()
	
	_nQtReg := TRB->QTDREG
	
	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	
	DbSelectArea("SBF")
	DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
	
	DbSelectArea("SB7")
	DbSetOrder(1) // B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE+B7_CONTAGE
	
	ProcRegua(_nQtReg)
	DbSeek(xFilial("SB7") + DTOS(_Mv_par01),.F.)
	
	XXX := 1
	_lSegue := .T.  // Para interromper o processamento dentro do debug
	
	// Montagem de loop para primeiro tratar as faltas (físico < sistema) e depois tratar as sobras (físico > sistema)
	
	DbSeek(xFilial("SB7") + DTOS(_Mv_par01),.F.)
	
	Do While SB7->B7_FILIAL == xFilial("SB7") .And. SB7->B7_DATA == _Mv_par01 .And. SB7->(!Eof()) .And. _lSegue
	
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SB7->B7_COD,.F.))
	
		cB7_COD     := SB7->B7_COD
		cB7_LOCAL   := SB7->B7_LOCAL
		cB7_LOCALIZ := SB7->B7_LOCALIZ
		cB7_NUMSERI := SB7->B7_NUMSERI
		cB7_LOTECTL := SB7->B7_LOTECTL
		cB7_NUMLOTE := SB7->B7_NUMLOTE
		cB7_CONTAGE := SB7->B7_CONTAGE
		aRegsB7 := {}
		_nQtdSB7 := 0
	
		Do While SB7->(!Eof()) .And. SB7->B7_FILIAL == xFilial("SB7") .And. SB7->B7_DATA == _Mv_par01 .And. ;
			SB7->B7_COD+SB7->B7_LOCAL+SB7->B7_LOCALIZ+SB7->B7_NUMSERI+SB7->B7_LOTECTL+SB7->B7_NUMLOTE+SB7->B7_CONTAGE == ;
			cB7_COD+  cB7_LOCAL+  cB7_LOCALIZ+  cB7_NUMSERI+  cB7_LOTECTL+  cB7_NUMLOTE+  cB7_CONTAGE
			IncProc()
			_nQtdSB7 += SB7->B7_QUANT
			Aadd(aRegsB7,{SB7->(Recno()),SB7->B7_NUMSEQ})
			SB7->(DbSkip())
		EndDo
	
		//If cB7_LOCAL == "90"
		//	Loop
		//EndIf
	
		SB2->(DbSetOrder(1))
		If !SB2->(DbSeek(xFilial("SB2")+cB7_COD+cB7_LOCAL,.F.))
			CriaSB2(cB7_COD,cB7_LOCAL)
		EndIf
	
		If SB1->B1_LOCALIZ == "S"
			If _Mv_par01 <> ctod("30/01/2017")
				Alert("2-erro MV_PAR01 " + Dtoc(_mv_par01))
			EndIf
			_aEst := CalcEstL(cB7_COD,cB7_LOCAL,_Mv_par01+1,,,cB7_LOCALIZ,,)
			_nSaldo := _aEst[1] // SBF->BF_QUANT
			_nQtdMov := _nQtdSB7 - _nSaldo //
			If _nQtdMov < 0
				_nSldSBF := 0.00
				SBF->(DbSetOrder(1)) //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
				If SBF->(DbSeek(xFilial("SBF")+cB7_LOCAL+cB7_LOCALIZ+cB7_COD,.F.))
					If SBF->BF_EMPENHO >= 0
						_nSldSBF := SBF->BF_QUANT - SBF->BF_EMPENHO
					EndIf
				EndIf
	
				If _nSldSBF < Abs(_nQtdMov)
					Aadd(_aRelato,{xFilial("SBF"),cB7_COD,cB7_LOCAL,cB7_LOCALIZ,_nQtdMov,SBF->BF_QUANT,SBF->BF_EMPENHO})
					Loop
				EndIf
			EndIf
		Else // NÃO TEM CONTROLE DE LOCALIZAÇÃO
			// Vejo o saldo no SB2
			SB2->(DbSetOrder(1))
			If !SB2->(DbSeek(xFilial("SB2")+cB7_COD+cB7_LOCAL,.F.))
				CriaSB2(cB7_COD,cB7_LOCAL)
			EndIf
			If _Mv_par01 <> ctod("30/01/2017")
				Alert("3-erro MV_PAR01 " + Dtoc(_mv_par01))
			EndIf
			_aEst := CalcEst(cB7_COD,cB7_LOCAL,_Mv_par01+1,,,,,)
			_nSaldo := _aEst[1]
			//		_nSaldo := SB2->B2_QATU
		EndIf
	
		If _nSaldo < 0.0001 .And. _nSaldo > 0.00
			_nSaldo := 0.00
		EndIf
	
		If _nQtdSB7 # _nSaldo
			// ponto de parada para debug
			XXX := 1
		EndIf
	
		If _nQtdSB7 # _nSaldo
			If SB1->B1_TIPO $ "ME/OI" .And. Empty(SB1->B1_CC)
				Aadd(_aRelato,{xFilial("SB7"),cB7_COD,cB7_LOCAL,"Falta CC",_nQtdMov,0,0})
				Loop
			EndIf
	
			lMsErroAuto	:= .F.
			For _nPosD3 := 1 to Len(aRegsB7)
				If !Empty(aRegsB7[_nPosD3,2]) // Já fiz um Lançamento desse inventário e ainda o saldo está errado
					_nValEst := 0
					If EstMovD3() // Não deu erro no estorno
						_nSaldo += _nValEst
						aRegsB7[_nPosD3,2] := "      " // Como foi estornado, não tenho mais o NumSeq
					Else // Deu erro no estorno
						Aadd(_aRelato,{xFilial("SB7"),cB7_COD,cB7_LOCAL,"Erro Estorno",_nQtdMov,0,0})
						lMsErroAuto	:= .T.
						Exit // Não faz nada pois já mostrou o erro
					EndIf
				EndIf
			Next
			If lMsErroAuto
				Loop // Não faz nada pois já mostrou o erro
			EndIf
		EndIf
	
		cNumSeq := "      "
		If _nQtdSB7 # _nSaldo
			_nQtdMov := _nQtdSB7 - _nSaldo
			If _nQtdMov > 0 // Preciso dar uma entrada pois tenho MENOR quantidade no estoque
				_cTM := "499" // Fazer um movimento de devolução por inventário
			Else
				_cTM := "999" // Fazer uma transferência do 01 para o 05
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pega o proximo numero sequencial de movimento      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNumSeq := ProxNum()
	
			If !SB2->(DbSeek(xFilial("SB2")+cB7_COD+cB7_LOCAL,.F.))
				CriaSB2(cB7_COD,cB7_LOCAL)
				SB2->(DbSeek(xFilial("SB2")+cB7_COD+cB7_LOCAL,.F.))
			EndIf
	
			RecLock("SB2",.F.)
	
			DbSelectArea("SD3")
			RecLock("SD3",.T.)
			SD3->D3_FILIAL  := xFilial("SD3")
			SD3->D3_COD     := SB1->B1_COD
			SD3->D3_DOC     := "INVENT     "
			SD3->D3_UM      := SB1->B1_UM
			SD3->D3_QUANT   := Abs(_nQtdMov)
			SD3->D3_LOCAL   := cB7_LOCAL
			SD3->D3_CF      := If(_cTM == "499","DE0","RE0")
			SD3->D3_GRUPO   := SB1->B1_GRUPO
			SD3->D3_CONTA   := SB1->B1_CONTA
			SD3->D3_TIPO    := SB1->B1_TIPO
			SD3->D3_USUARIO := cUserName
			SD3->D3_EMISSAO := _Mv_par01
			SD3->D3_NUMSEQ  := cNumSeq
			SD3->D3_SEGUM   := SB1->B1_SEGUM
			SD3->D3_TEMPES  := "N"
			SD3->D3_CHAVE   := "E0"
			SD3->D3_LOCALIZ := cB7_LOCALIZ
			If SB1->B1_TIPO $ "ME/OI"
				SD3->D3_TM      := If(_cTM == "499","200","700")
				SD3->D3_CC      := SB1->B1_CC
				SD3->D3_STSERV  := "1"
			Else
				SD3->D3_TM      := _cTM
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Pega os 15 custos medios atuais            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	 		//³ Grava o custo da movimentacao              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCusto := GravaCusD3(aCM)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza o saldo atual (VATU) com os dados do SD3     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			_lErrAtu := B2AtuComD3(aCusto,,.F.) // .F.->Não mostra help se der erro // Retorna .T. se deu erro na atualização
	
			SB1->(MsUnLock())
			SB2->(MsUnLock())
			SD3->(MsUnLock())
		EndIf
	
		DbSelectArea("SB7")
		For _nPosD3 := 1 to Len(aRegsB7)
			//DbGoTo(aRegsB7[_nPosD3,1]
			If SB7->B7_NUMSEQ # cNumSeq
				RecLock("SB7",.F.)
				SB7->B7_NUMSEQ := cNumSeq
				MsUnLock()
			EndIf
		Next
	
		//Gravação da data do Inventario
		SB2->(DbSetOrder(1))
		SB2->(DbSeek(xFilial("SB2")+cB7_COD+cB7_LOCAL,.F.))
		If SB2->B2_DTINV # _Mv_par01
			RecLock("SB2",.F.)
			SB2->B2_DTINV   := _Mv_par01
			MsUnlock()
		EndIf
	
		DbSelectArea("SB7")
	EndDo
	
	If Len(_aRelato) > 0
	
		cTexto := ""
		MsgBox("Alguns produtos possuem mais empenho do que estoque inventariado (BF_EMPENHO > Inventario (SB7))"+CRLF+;
		"Um arquivo texto será gerado, e deverá ser tratado posteriormente" , "Atencao !!!", "INFO")
	
		While .T.
			_cArqTxt := cGetFile("Arquivo Texto| *.TXT ",OemToAnsi("Salvar Arquivo Como..."),0,"C:\",.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE)
			nHdl 	 := fCreate(_cArqTxt)
			If nHdl == -1
				MsgAlert("O arquivo de nome " + _cArqTxt + " nao pode ser executado! Verifique os parametros.","Atencao!")
			Else
				Exit
			EndIf
		EndDo
	
		//cabecalho
		cTexto := "|BF_FILIAL |BF_PRODUTO|BF_LOCAL  |BF_LOCALIZ|Qtd.Mov.  |BF_QUANT  |BF_EMPEN  |"+CRLF
		fWrite(nHdl,cTexto,Len(cTexto))
	
		For nI := 1 to Len(_aRelato)
			cTexto:= "|"+;
			Left(_aRelato[nI][1]+Space(10),10)+"|"+;
			Left(_aRelato[nI][2]+Space(10),10)+"|"+;
			Left(_aRelato[nI][3]+Space(10),10)+"|"+;
			Left(_aRelato[nI][4]+Space(10),10)+"|"+;
			Str(_aRelato[nI][5],10)+"|"+;
			Str(_aRelato[nI][6],10)+"|"+;
			Str(_aRelato[nI][7],10)+"|"+CRLF
	
			fWrite(nHdl,cTexto,Len(cTexto))
		Next
		fClose(nHdl)//Fecha o Arquivo
	EndIf
Return(.T.)


/*/{Protheus.doc} ProcBLK
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined

@type function
/*/
Static Function ProcBLK()
/*/
	Este programa é composto de 3 fazes no processamento :

	1 - Verificar se há necessidade de ajuste do saldo e se já houve um ajuste de saldo neste inventário:
		- Ação -> Estornar o ajuste efetuado anteriormente.

	2 - Verificar se há necessidade de ajuste de saldo e se o ajuste é uma requisição (sobra):
		- Ação -> O produto é material de embalagem (ME)?
				  Sim -> Consumir contra o centro de custo "FRACIONAMENTO";
				  Não -> Transferir para o armazém 03-PCP.

	3 - Verificar se há necessidade de ajuste de saldo e se o ajuste é uma devolução (falta):
		- Ação -> O produto é material de consumo (ME)?
				  Sim -> Fazer estorno do consumo contra o centro de custo "FRACIONAMENTO";
				  Não -> Tem saldo no armazém 03?
				  		 Sim -> Transferir do armazém 03;
				  		 Não -> O produto é um PI?
								Sim -> Tem OP no período?
									   Sim -> Produz nessa OP;
									   Não -> Cria nova OP e produz "sem consumo".
								Não é PI (é MP!) -> Tem outro consumo no período?
											   Sim -> Devolve contra a OP;
											   Não -> Criar log de erro.

/*/
Private Mv_par01,Mv_par02,Mv_par03,Mv_par04,Mv_par05,Mv_par06,Mv_par07,_nValEst := 0
Private _nValEst := 0

	_aRelato := {}
	
	If !u_IncInv()
		Return(.T.)
	EndIf
	
	_nInicio	:= MV_PAR10
	_nFinal		:= MV_PAR11	
	_nSoPA		:= MV_PAR12		// 	1-Tudo 2-Só PA 3-Fora o PA
	
	_dDtTrv := Max(GetMv("MV_DBLQMOV"),GetMv("MV_ULMES"))
	dDataBase := MV_PAR01
	
	If _dDtTrv >= MV_PAR01
		Alert("Ajustar Parâmetros MV_DBLQMOV / MV_ULMES")
		Return(.F.)
	EndIf
	
	If ! MsgBox("Confirma Filial de Processamento " + IIF(xFilial("SB7") == "01", "Itu ?", "Tres Lagoas ?"),"Confirma?","YesNo")
		Alert("Processo Cancelado")
		Return(.F.)
	EndIf
		
	If _nInicio = 1 
		If MsgBox("Deseja Zerar Saldos na SB7 (SLDANT/SALDO/QTDTERC)?","Confirma?","YesNo")
			cQuery := ""
			cQuery += " UPDATE "+RetSqlName("SB7")+" SET B7_SALDO = 0, B7_SLDANT = 0, B7_QTNP = 0 "
			cQuery += " WHERE B7_FILIAL = '"+xFilial("SB7")+"'"
			cQuery += " AND B7_DATA = '"+dtos(MV_PAR01)+"'"
			cQuery += " AND D_E_L_E_T_ <>'*'"
			TCSqlExec(cQuery)
		EndIf
	EndIf
	
	cQuery := ""
	cQuery += " SELECT COUNT(*) QTDREG FROM "+RetSqlName("SB7")
	cQuery += " WHERE B7_FILIAL = '"+xFilial("SB7")+"'"
	cQuery += " AND B7_DATA = '"+dtos(MV_PAR01)+"'"
	cQuery += " AND D_E_L_E_T_ <>'*'"
	cQuery := ChangeQuery(cQuery)
	
	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"
	
	DbSelectArea("TRB")
	DbGotop()
	
	_nQtReg := TRB->QTDREG
	
	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	
	DbSelectArea("SBF")
	DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SDA")
	DbSetOrder(1)
	
	DbSelectArea("SDB")
	DbSetOrder(1) // DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM
	
	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
	
	DbSelectArea("SB7")
	DbSetOrder(1) // B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE+B7_CONTAGE
	
	ProcRegua(_nQtReg*3)
	DbSeek(xFilial("SB7") + DTOS(_Mv_par01),.F.)
	
	Alert(_nInicio)
	Alert(_nFinal )
	Alert(If(_nSoPA==1,"Tudo",If(_nSoPA==2,"Só Expedição","Só Fábrica"))) // 	0-Tudo 1-Só PA 2-Fora o PA
	
	_lSegue := .T.
	
	// Montagem de loop para primeiro tratar as faltas (físico < sistema) e depois tratar as sobras (físico > sistema)
	For _nVez := _nInicio To _nFinal
	//For _nVez := _Mv_par10 To _Mv_par11
		// 1-Calcular o saldo na data do inventário e gravar em B7_SLDANT
		// 2 e 3 - Dar um select no banco com os registros que necessitam fazer algum movimento
		// 		2-Movimento de requisição(para CC ou OP) ou para transferência para o local 03
		// 		3-Movimento de devolução  (do CC ou da OP) ou de transferência do local 03
	
		// Estornar movimentos necessários
		// 2-Fazer somente movimentos de REQUISIÇÃO:
		//			É produto ME-Mat.Embalagem - Requisitar para o Centro de custo FRACIONAMENTO
		//			Não é produto ME-Mat.Embalagem - Transferir quantidade para o armazém 03 - PCP
		// 3-Fazer somente movimentos de DEVOLUÇÃO:
		//			É produto ME-Mat.Embalagem - Devolver para o Centro de custo FRACIONAMENTO
		//			Não é produto ME-Mat.Embalagem E tem saldo no armazém 03-PCP - Transferir a quantidade do armazém 03-PCP
		//			Não é produto ME-Mat.Embalagem E NÃO tem saldo no armazém 03-PCP E é um PI E tem produção no período - Faz uma produção nessa OP
		//			Não é produto ME-Mat.Embalagem E NÃO tem saldo no armazém 03-PCP E é um PI E NÃO tem produção no período - Cria uma OP e Faz uma produção sem consumo
		//			Não é produto ME-Mat.Embalagem E NÃO tem saldo no armazém 03-PCP E é uma MP  E tem um consumo no período - Devolve contra a OP
		//
		//			NENHUMA DAS ANTERIORES - Criar Log de erro
	
		If _nVez == 1 // Somente atualizar os dados do SB7
			DbSelectArea("SB7")
			DbSetOrder(1) // B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE+B7_CONTAGE
			DbSeek(xFilial("SB7") + DTOS(_Mv_par01),.F.)
			Do While SB7->B7_FILIAL == xFilial("SB7") .And. SB7->B7_DATA == _Mv_par01 .And. SB7->(!Eof()) .And. _lSegue
	
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+SB7->B7_COD,.F.))
	
				If _nSoPA==2 .And. (SB1->B1_TIPO # "PA" .And. SB7->B7_LOCAL # "01") // 1-Tudo 2-Só PA 3-Fora o PA
					SB7->(DbSkip())
					Loop
				ElseIf _nSoPA==3 .And. (SB1->B1_TIPO == "PA" .And. SB7->B7_LOCAL == "01") // 1-Tudo 2-Só PA 3-Fora o PA
					SB7->(DbSkip())
					Loop
				EndIf
	
				cB7_COD     := SB7->B7_COD
				cB7_LOCAL   := SB7->B7_LOCAL
				cB7_LOCALIZ := SB7->B7_LOCALIZ
				cB7_NUMSERI := SB7->B7_NUMSERI
				cB7_LOTECTL := SB7->B7_LOTECTL
				cB7_NUMLOTE := SB7->B7_NUMLOTE
				cB7_CONTAGE := SB7->B7_CONTAGE
				_nRegsB7    := 0
				_nQtdSB7    := 0
	
				// Atenção : Em princípio é pra ter somente um SB7 para cada chave. Se isso ocorrer, atualizar o primeiro pelo total e
				// deletar os demais.
				// ETAPA 1 - Verificar qual produto e quantidade que foi inventariada
				Do While SB7->(!Eof()) .And. SB7->B7_FILIAL == xFilial("SB7") .And. SB7->B7_DATA == _Mv_par01 .And. ;
					SB7->(B7_COD  + B7_LOCAL  + B7_LOCALIZ  + B7_NUMSERI  + B7_LOTECTL  + B7_NUMLOTE  + B7_CONTAGE )  == ;
					(cB7_COD + cB7_LOCAL + cB7_LOCALIZ + cB7_NUMSERI + cB7_LOTECTL + cB7_NUMLOTE + cB7_CONTAGE)
					IncProc()
	
					_nQtdSB7 += SB7->B7_QUANT
					If _nRegsB7 == 0
						_nRegsB7   := SB7->(Recno())
					Else
						RecLock("SB7",.F.)
						DbDelete()
						MsUnLock()
					EndIf
					SB7->(DbSkip())
				EndDo
				_nB7Atu := SB7->(Recno())
				 _nSldTer := 0.00
				If SB1->B1_TIPO $ "OI//ME"
					_nSldTer := MySaldoTer()[1]
					_xx := 1
				EndIf
				_nSaldo := MySaldo()[1] // Retorna CalcEst ou CalcEstl
				If Abs(_nSaldo) < 0.01 .And. _nSaldo <> 0.00
					_nSaldo := 0.00
				EndIf
	
				_QtdMov    := MyMovto() // Retorna a quantidade movimentada (entradas-saídas) que deve sempre ser subtraída do saldo atual (na dt do inventário)
				_nSaldo    := Round(_nSaldo,TamSX3("B7_QUANT")[2])
				_nB7SLDANT := Round((_nSaldo-_QtdMov),TamSX3("B7_SLDANT")[2])
	
				SB7->(DbGoTo(_nRegsB7))
				If SB7->B7_QUANT # _nQtdSB7 .Or. SB7->B7_SALDO # _nSaldo .Or. SB7->B7_SLDANT # _nB7SLDANT .Or. SB7->B7_QTNP <> _nSldTer
					SB7->(RecLock("SB7",.F.))
					SB7->B7_QUANT  := _nQtdSB7
					SB7->B7_SALDO  := _nSaldo
					SB7->B7_SLDANT := _nB7SLDANT
					SB7->B7_QTNP   := _nSldTer
					SB7->(MsUnLock())
				EndIf
				SB7->(DbGoTo(_nB7Atu))
			EndDo // Volta para o Do While do B7
			Loop // Volta para o For/Next
		EndIf
	
	
		// Só chega aqui se _nVez for maior que 1
	
		cQuery := "SELECT B7.R_E_C_N_O_ REG_B7, B1.R_E_C_N_O_ REG_B1, B7_FILIAL, B7_DATA, B7_COD, B1_TIPO, B7_LOCAL, B7_LOCALIZ,"
		cQuery += "  B7_NUMSERI, B7_LOTECTL, B7_NUMLOTE, B7_CONTAGE, B7_QUANT, B7_SALDO, B7_SLDANT, B7_QTNP"
		cQuery += " FROM "+RetSqlName("SB7") + " B7"
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " B1"
		cQuery += " ON '  ' = B1_FILIAL"
		cQuery += " AND B7_COD = B1_COD"
		cQuery += " AND B7.D_E_L_E_T_ = B1.D_E_L_E_T_"
		cQuery += " WHERE B7_FILIAL = '"+xFilial("SB7")+"'"
		cQuery += " AND B7_DATA = '"+Dtos(_Mv_par01)+"'"
		cQuery += " AND B7_LOCAL NOT IN('03','04','90','91','95','98')"
		If _nVez == 2 // Fazer os movimentos de requisição
			cQuery += " AND (B7_SALDO-B7_QUANT) > 0 " // Tenho mais no sistema do que no físico (Tirar (requisitar) e transferir para local 03 ou para CC/OP)
		ElseIf _nVez == 3 // Fazer os movimentos de devolução
			cQuery += " AND (B7_SALDO-B7_QUANT) < 0 " // Tenho mais no físico do que no sistema (Adicionar (devolver) do local 03 ou de CC/OP)
		EndIf
		If _nSoPA == 2 // 1-Tudo 2-Só PA 3-Fora o PA
			cQuery += " AND (B1_TIPO = 'PA' AND B7_LOCAL = '01') "
		ElseIf _nSoPA == 3  // 1-Tudo 2-Só PA 3-Fora o PA
			cQuery += " AND NOT (B1_TIPO = 'PA' AND B7_LOCAL = '01') "
		EndIf
		cQuery += " AND B7.D_E_L_E_T_ <>'*'"
		cQuery := ChangeQuery(cQuery)
		If Select("TRB")>0
			DbSelectArea("TRB")
			DbCloseArea()
		EndIf
		TCQUERY cQuery NEW ALIAS "TRB"
	
		DbSelectArea("TRB")
		DbGotop()
		Do While !TRB->(Eof())
	
			// Atualizar as variáveis que serão utilizadas nas rotinas dos movimentos
			cB7_COD     := TRB->B7_COD
			cB7_LOCAL   := TRB->B7_LOCAL
			cB7_LOCALIZ := TRB->B7_LOCALIZ
			cB7_NUMSERI := TRB->B7_NUMSERI
			cB7_LOTECTL := TRB->B7_LOTECTL
			cB7_NUMLOTE := TRB->B7_NUMLOTE
			cB7_CONTAGE := TRB->B7_CONTAGE
			_nQtdMov := Abs(TRB->B7_QUANT - TRB->B7_SALDO)
	
			// Posiciona SB7
			SB7->(DbGoTo(TRB->REG_B7))
			// Posiciona SB1
			SB1->(DbGoTo(TRB->REG_B1))
			_lMovOk   := .F.
			_lAtuSdB7 := .F.
			If _nVez == 2
				// Tenho que fazer uma requisição
				// Tenho mais no sistema do que no físico (Tirar (requisitar) e transferir para local 03 ou para CC/OP)
				If SB1->B1_TIPO $ "ME/OI"
					// Só fazer a requisição se o saldo ficar maior ou igual a quantidade de terceito em nosso poder
					IF TRB->B7_QUANT >= TRB->B7_QTNP .And. !Empty(SB1->B1_CC)  // Tenho quantidade e tenho CC
						_lMovOk := FazMovD3("1",_nQtdMov,SB1->B1_CC) // TM 700 - Consumir contra o centro de custo do cadastro do produto
					EndIf
				Else
					_lMovOk := FazMovD3("2",_nQtdMov) //  Transferir para 03-PCP  // CORRETO
				EndIf
			ElseIf _nVez == 3
				// _nQtdSB7 -> Quantidade Inventariada
				// _nSldLoc03 -> Saldo do produto na data do inventário (armaz. 03)
	
				// Tenho que fazer uma devolução
				// Tenho mais no físico do que no sistema (Adicionar (devolver) do local 03 ou de CC/OP)
	
				If SB1->B1_TIPO $ "ME/OI"
					// Aqui não preciso comparar com a quantidade de terceiros, pois esou devolvento para o armazém 01
					// De onde eu tiro? R.: Do centro de custo 300111-FRACIONAMENTO
					If !Empty(SB1->B1_CC)
						_lMovOk := FazMovD3("3",_nQtdMov,SB1->B1_CC) // TM 200  - Fazer uma devolução do consumo contra o centro de custo 300111-FRACIONAMENTO
					EndIf
				Else
					// Verificar se tem saldo no Local 03
					// Calcula o saldo do produto no local 03
					If SB1->B1_LOCALIZ == "S"
						_aEst      := CalcEstL(cB7_COD,"03",_Mv_par01+1,,,PadR("PROD_PCP",TamSX3("BF_LOCALIZ")[1]),,,)
						_nSldLoc03 := _aEst[1]
						SBF->(DbSetOrder(1)) //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
						If SBF->(DbSeek(xFilial("SBF")+"03"+PadR("PROD_PCP",TamSX3("BF_LOCALIZ")[1])+cB7_COD,.F.))
							If SBF->BF_EMPENHO >= 0 // Vejo a quantidade empenhada na data fisica
								_nSldLoc03 -= SBF->BF_EMPENHO // Na verdade, o empenho aqui tem que ser 0 (zero)
							EndIf
						EndIf
					Else // NÃO TEM CONTROLE DE LOCALIZAÇÃO
						// Vejo o saldo no SB2
						SB2->(DbSetOrder(1))
						If !SB2->(DbSeek(xFilial("SB2")+cB7_COD+"03",.F.))
							CriaSB2(cB7_COD,"03")
						EndIf
						_aEst := CalcEst(cB7_COD,"03",_Mv_par01+1,,,,,)
						_nSldLoc03  := _aEst[1]
					EndIf
	
					If Abs(_nSldLoc03) < 0.01
						_nSldLoc03 := 0.00
					EndIf
	
					// _nQtdSB7 -> Quantidade Inventariada
					// _nSaldo  -> Saldo do produto na data do inventário (armaz. 01)
					// _nSldLoc03 -> Saldo do produto na data do inventário (armaz. 03)
	
					If _nSldLoc03 >= _nQtdMov // Saldo em estoque é maior que a quantidade que preciso requisitar ?
						// De onde eu tiro? Se tem saldo no 03 transfiro de lá.
						_lMovOk := FazMovD3("4",_nQtdMov) //  Transferir do 03-PCP tudo
						If _lMovOk // Fez o movimento
							_nQtdMov := 0
						EndIf
					ElseIf _nSldLoc03 > 0 // Faz um movimento na quantidade que dá
						_lMovOk := FazMovD3("4",_nSldLoc03) //  Transferir do 03-PCP o que dá
						If _lMovOk // Fez o movimento
							_nQtdMov -= _nSldLoc03
							_lAtuSdB7 := .T.
							// Só neste caso atualizo a variável _lAtuSdB7, pois pode dar erro nos movimentos abaixo
						EndIf
					EndIf
	
					If _nQtdMov > 0  // Ainda tenho quantidade a corrigir
						If SB1->B1_TIPO $ 'PI/PA' // Não tem saldo para efetuar a transferência mas é um PI ou PA
							/*
							// De onde eu tiro?
							cQuery := "SELECT DISTINCT D3_OP, C2_DATRF "
							cQuery += "FROM " + RetSqlName("SD3") + " D3 "
							cQuery += "	INNER JOIN " + RetSqlName("SC2") + " C2 "
							cQuery += "	ON D3_FILIAL = C2_FILIAL "
							cQuery += "	AND D3_OP = C2_NUM+C2_ITEM+C2_SEQUEN "
							cQuery += "	AND D3.D_E_L_E_T_ = C2.D_E_L_E_T_ "
							cQuery += "WHERE D3_FILIAL = '" + xFilial("SD3") + "'  "
							cQuery += "AND D3_COD = '" + cB7_COD + "' "
							cQuery += "AND D3_EMISSAO > '" + Dtos(GetMv("MV_ULMES")) + "' "
							cQuery += "AND D3_EMISSAO < '" + Dtos(_Mv_par01) + "' "
							cQuery += "AND D3_CF = 'PR0' "
							cQuery += "AND D3_ESTORNO = '' "
							cQuery += "AND (C2_DATRF = '' OR (C2_DATRF > '" + Dtos(GetMv("MV_ULMES")) + "' AND C2_DATRF < '" + Dtos(_Mv_par01) + "')) "
							cQuery += "AND C2_LOCAL = '" + cB7_LOCAL + "' "
							cQuery += "AND D3.D_E_L_E_T_ = '' "
							cQuery += "ORDER BY C2_DATRF, D3_OP "
	
							aRetSQL  := u_qryarr(cQuery) // {D3_OP, C2_DATRF}
							_CriouOP := .F.
							_cOP     :=  " "
							If Len(aRetSQL) > 0
								_cOP    := aRetSQL[1,1]
								//_dDtEnc := Stod(aRetSQL[1,2])
							Else //Não Tem produção desse produto no período.
							*/
								// Cria  uma OP e produz sem consumo
								_cNmSeek := "55000001" // Nro da OP-item a ser criada
								DbSelectArea("SC2")
								DbSetOrder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
								Do While DbSeek(xFilial("SC2")+_cNmSeek,.F.)
									_cNmSeek := Soma1(_cNmSeek,,.F.)
								EndDo
								_NumOP   := Left (_cNmSeek,6)
								_Item    := Right(_cNmSeek,2)
								_cSeq    := "001"
								_cAlmo   := cB7_LOCAL
								_cProd   := cB7_COD
								_nQtd    := _nQtdMov
								_cStInt  := "N"  // Não enviar dados para integração com o PPI
								_Obs     := "PROD_PCP"
								lCriaOPI := .F. // Não cria OPs filhas
								_CriouOP := u_NovaOP("I",lCriaOPI,_Mv_par01," ",_cStInt)
								If _CriouOP
									_cOP := _NumOP + _Item + _cSeq
								EndIf
							//EndIf
							If !Empty(_cOP)
								_lMovOk := FazMovD3("5",_nQtdMov,'',_cOP) //,_dDtEnc)
							EndIf
						ElseIf SB1->B1_TIPO == 'MP' // Não tem saldo para efetuar a transferência mas é uma MP
							// De onde eu tiro?
							//Tem um consumo desse produto em alguma OP (quant. > quant. a devolver)
	
							cQuery := "SELECT DISTINCT D3_COD, D3_OP "
							cQuery += "FROM " + RetSqlName("SD3") + " D3 "
							cQuery += "	INNER JOIN " + RetSqlName("SC2") + " C2 "
							cQuery += "	ON D3_FILIAL = C2_FILIAL"
							cQuery += "	AND D3_OP = C2_NUM+C2_ITEM+C2_SEQUEN"
							cQuery += "	AND D3.D_E_L_E_T_ = C2.D_E_L_E_T_ "
							cQuery += "WHERE D3_FILIAL = '" + xFilial("SD3") + "'  "
							cQuery += "AND D3_COD = '" + cB7_COD + "' "
							cQuery += "AND D3_TM = '504' "
							cQuery += "AND D3_EMISSAO > '" + Dtos(GetMv("MV_ULMES")) + "' "
							cQuery += "AND D3_EMISSAO <= '" + Dtos(_Mv_par01) + "' "
							cQuery += "AND D3_ESTORNO = '' "
							cQuery += "AND (C2_DATRF = '' OR (C2_DATRF > '" + Dtos(GetMv("MV_ULMES")) + "' AND C2_DATRF < '" + Dtos(_Mv_par01) + "')) "
							cQuery += "AND D3.D_E_L_E_T_ = '' "
							cQuery += "ORDER BY D3_COD, D3_OP"
							aRetSQL := u_qryarr(cQuery) // {D3_OP, C2_DATRF}
							If Len(aRetSQL) == 0
								// Não tenho o consumo desse produto em alguma OP
								// Pego uma op qualquer, de qualquer produto
								cQuery := "SELECT DISTINCT D3_COD, D3_OP "
								cQuery += "FROM " + RetSqlName("SD3") + " D3 "
								cQuery += "	INNER JOIN " + RetSqlName("SC2") + " C2 "
								cQuery += "	ON D3_FILIAL = C2_FILIAL"
								cQuery += "	AND D3_OP = C2_NUM+C2_ITEM+C2_SEQUEN"
								cQuery += "	AND D3.D_E_L_E_T_ = C2.D_E_L_E_T_ "
								cQuery += "WHERE D3_FILIAL = '" + xFilial("SD3") + "'  "
								cQuery += "AND D3_TM = '504' "
								cQuery += "AND D3_EMISSAO > '" + Dtos(GetMv("MV_ULMES")) + "' "
								cQuery += "AND D3_EMISSAO < '" + Dtos(_Mv_par01) + "' "
								cQuery += "AND D3_ESTORNO = '' "
								cQuery += "AND (C2_DATRF = '' OR (C2_DATRF > '" + Dtos(GetMv("MV_ULMES")) + "' AND C2_DATRF < '" + Dtos(_Mv_par01) + "')) "
								cQuery += "AND D3.D_E_L_E_T_ = '' "
								cQuery += "ORDER BY D3_COD, D3_OP"
								aRetSQL := u_qryarr(cQuery) // {D3_OP, C2_DATRF}
							EndIf
							If Len(aRetSQL) > 0
								_cOP    := aRetSQL[1,2]
								_lMovOk := FazMovD3("3",_nQtdMov,'',_cOP) // Devolução contra OP
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
	
			If _lMovOk .Or. _lAtuSdB7 // Foi feito movimento, atualiza o SB7.
				_nSaldo := MySaldo()[1] // Retorna CalcEst ou CalcEstl
				_nSaldo := Round(_nSaldo,TamSX3("B7_QUANT")[2])
				If Abs(_nSaldo) < 0.01 .And. _nSaldo <> 0.00
					_nSaldo := 0.00
				EndIf
	
				_QtdMov := MyMovto() // Retorna a quantidade movimentada (entradas-saídas) que deve sempre ser subtraída do saldo atual (na dt do inventário)
				_nB7SLDANT := Round((_nSaldo-_QtdMov),TamSX3("B7_SLDANT")[2])
				SB7->(DbGoTo(TRB->REG_B7))
				If SB7->B7_SALDO # _nSaldo .Or. SB7->B7_SLDANT # _nB7SLDANT
					SB7->(RecLock("SB7",.F.))
					SB7->B7_SALDO  := _nSaldo
					SB7->B7_SLDANT := _nB7SLDANT
					SB7->(MsUnLock())
				EndIf
			EndIf
			//Gravação da data do Inventario
			SB2->(DbSetOrder(1))
			SB2->(DbSeek(xFilial("SB2")+cB7_COD+cB7_LOCAL,.F.))
			If SB2->B2_DTINV # _Mv_par01
				RecLock("SB2",.F.)
				SB2->B2_DTINV   := _Mv_par01
				MsUnlock()
			EndIf
			TRB->(DbSkip())
		EndDo
	Next
	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
Return(.T.)


/*/{Protheus.doc} ProcSB72
//TODO Descrição auto-gerada.
@author Roberto
@since 30/05/2017
@version undefined

@type function
/*/
User Function ProcSB72()
	DbSelectArea("SBF")
	DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
	
	DbSelectArea("SB7")
	DbSetOrder(1) // B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE+B7_CONTAGE
	
	MV_PAR01 := Ctod("14/11/09")
	DbSeek(xFilial("SB7") + DTOS(MV_PAR01),.F.)
	
	Do While SB7->B7_FILIAL == xFilial("SB7") .And. SB7->B7_DATA == MV_PAR01 .And. SB7->(!Eof())
	
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SB7->B7_COD,.F.))
	
		If SB1->B1_LOCALIZ # "S"
			SB7->(DbSkip())
			Loop
		EndIf
	
		cB7_COD     := SB7->B7_COD
		cB7_LOCAL   := SB7->B7_LOCAL
		cB7_LOCALIZ := SB7->B7_LOCALIZ
		cB7_NUMSERI := SB7->B7_NUMSERI
		cB7_LOTECTL := SB7->B7_LOTECTL
		cB7_NUMLOTE := SB7->B7_NUMLOTE
		cB7_CONTAGE := SB7->B7_CONTAGE
	
		_nQtdSB7  := SB7->B7_QUANT
		_nQtdSB72 := SB7->B7_QTSEGUM
	
		_nSdSBF := 0.00
		DbSelectArea("SBF")
		DbSetOrder(1)
		If SBF->(DbSeek(xFilial("SBF")+cB7_LOCAL+cB7_LOCALIZ+cB7_COD,.F.))
			_nSdSBF := SBF->BF_QUANT
		EndIf
	
		_lFaz  := .F.
		If _nQtdSB7 # _nSdSBF
			_nDif :=  _nQtdSB7 - _nSdSBF
			If _nDif < 0 // Tenho que Tirar! Posso Tirar????
				If (SBF->BF_QUANT-SBF->BF_EMPENHO) >= Abs(_nDif)  .And. SBF->BF_EMPENHO >= 0
					_lFaz  := .T.
					_cTM := "999"
				EndIf
			Else // Tenho que devolver
				_cTM := "499"
				_lFaz  := .T.
			EndIf
	
			If !_lFaz
				xxxxl := "nao fiz"
			Else
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pega o proximo numero sequencial de movimento      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cNumSeq := ProxNum()
	
				If !SB2->(DbSeek(xFilial("SB2")+cB7_COD+cB7_LOCAL,.F.))
					CriaSB2(cB7_COD,cB7_LOCAL)
					SB2->(DbSeek(xFilial("SB2")+cB7_COD+cB7_LOCAL,.F.))
				EndIf
	
				RecLock("SB2",.F.)
	
				DbSelectArea("SD3")
				RecLock("SD3",.T.)
				SD3->D3_FILIAL  := xFilial("SD3")
				SD3->D3_TM      := _cTM
				SD3->D3_COD     := SB1->B1_COD
				SD3->D3_DOC     := "INVENT     "
				SD3->D3_UM      := SB1->B1_UM
				SD3->D3_QUANT   := Abs(_nDif)
				SD3->D3_CF      := If(_cTM == "499","DE0","RE0")
				SD3->D3_LOCAL   := cB7_LOCAL
				SD3->D3_EMISSAO := dDatabase // MV_PAR01
				SD3->D3_NUMSEQ  := cNumSeq
				SD3->D3_TIPO    := SB1->B1_TIPO
				SD3->D3_USUARIO := cUserName
				SD3->D3_CHAVE   := "E0"
				SD3->D3_GRUPO   := SB1->B1_GRUPO
				SD3->D3_SEGUM   := SB1->B1_SEGUM
				SD3->D3_CONTA   := SB1->B1_CONTA
				SD3->D3_LOCALIZ := cB7_LOCALIZ
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pega os 15 custos medios atuais            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava o custo da movimentacao              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCusto := GravaCusD3(aCM)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o saldo atual (VATU) com os dados do SD3     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_lErrAtu := B2AtuComD3(aCusto,,.F.) // .F.->Não mostra help se der erro // Retorna .T. se deu erro na atualização
				SB2->(MsUnLock())
			EndIf
		EndIf
		DbSelectArea("SB7")
		SB7->(DbSkip())
	EndDo
	Alert("Terminei")
Return(.T.)


/*/{Protheus.doc} EstBob
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function EstBob() //Estorno de liberação de Bobinas
	DbSelectArea("SB1")
	DbSetOrder(1)  //B1_FILIAL+B1_COD
	
	DbSelectArea("SZ2")
	DbSetOrder(1) // Z2_FILIAL+Z2_COD
	
	DbSelectArea("SC9")
	DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	
	DbSelectArea("SBF")
	DbSetOrder(1)
	
	DbSelectArea("SDC")
	DbSetOrder(1)
	ProcRegua(LastRec())
	DbSeek(xFilial("SDC"),.F.)
	Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->(!Eof())
		IncProc()
		If SDC->DC_ORIGEM # "SC6"
			SDC->(DbSkip())
			Loop
		EndIf
		If Left(SDC->DC_LoCALIZ,1) $ "BT" // Retalho e bobinas não estornar
			SDC->(DbSkip())
			Loop
		EndIf
	
		SB1->(DbSeek(xFilial("SB1")+TRB->PRODUTO,.F.))
		SZ2->(DbSeek(xFilial("SZ2")+SB1->B1_BITOLA,.F.))
		_nBitol := AllTrim(SZ2->Z2_BITOLA)
		_nBitol := Val(StrTran(_nBitol,",","."))
		If !(_nBitol <= 35) // não é curva A
			SDC->(DbSkip())
			Loop
		EndIf
	
		_RegAtu := SDC->(Recno())
	
		SC9->(DbSeek(xFilial("SC9")+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ,.F.))
	
		U_CDLibEst("E",SDC->DC_PRODUTO,SDC->DC_QUANT,SDC->DC_LOCAL,SDC->DC_LOCALIZ,SDC->DC_PEDIDO,SDC->DC_ITEM,SDC->DC_SEQ,.F.)
	
		DbSelectArea("SDC")
		DbSetOrder(1)
		SDC->(DbGoTo(_RegAtu))
		SDC->(DbSkip())
	EndDo
	Alert("TERMINEI")
Return(.T.)


/*/{Protheus.doc} Bob_dez
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function Bob_dez()
	
	//_cArqOrig := "D:\TRANSF\3L\BOBINAS.DBF"
	//CPYT2S(_cArqOrig,"\BALAN3L\",.F.)
	//DbUseArea(.T.,cDrive,"\BALAN3L\BOBINAS.DBF","TRB",.T.,.F.)
	
	DbUseArea(.T.,cDrive,"\CONDUSUL\INVBOB.DTC","TRB",.T.,.F.)
	
	DbSelectArea("SZE")
	DbSetOrder(1)
	
	DbSelectArea("TRB")
	DbGoTop()
	Do While TRB->(!Eof())
		//	_cNum := Right("0" + AllTrim(Str(VAl(TRB->NUMBOB))),7)
		_cNum := StrZero(TRB->NUMBOB,7)
		DbSelectArea("SZE")
		If DbSeek(xFilial("SZE")+_cNum,.F.)
			If "LIBERAR" $ Upper(TRB->STATUS)
				_cStat := "P"
			ElseIf "ESTOQUE" $ Upper(TRB->STATUS)
				_cStat := "T"
			ElseIf "FATURADA" $ Upper(TRB->STATUS)
				_cStat := "F"
			Else
				_cStat := "?"
			EndIf
			RecLock("SZE",.F.)
			//		SZE->ZE_STATUS := _cStat
			SZE->ZE_DTINV  := Date() -2
			SZE->ZE_OK := SZE->ZE_STATUS+_cStat
			SZE->ZE_STATUS := _cStat
			MsUnLock()
		Else
			xx := "Erro"
		EndIf
		DbSelectArea("TRB")
		DbSkip()
	EndDo
	DbCloseArea()
Return(.T.)


/*/{Protheus.doc} CriaChao
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function CriaChao()
	
	cPerg := "CDGN09"
	If !Pergunte(cPerg, .T.)
		Return(.T.)
	EndIf
	
	DbSelectArea("SB7")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	
	If FWCodEmp()+FWCodFil() == "0102" /// Cobrecom 3 Lagoas
		Return(.T.)
	Else
		DbUseArea(.T.,cDrive,"\CONDUSUL\ALMOX99.DTC","TRB",.T.,.F.)
	EndIf
	DbSelectArea("TRB")
	DbGoTop()
	ProcRegua(LastRec())
	
	Do While TRB->(!Eof())
		IncProc()
		If TRB->QUANT > 0
			_Prod := Left(Alltrim(TRB->CODIGO) + Space(TAMSX3("B1_COD")[1]),TAMSX3("B1_COD")[1])
			If !SB7->(DbSeek(xFilial("SB7")+Dtos(MV_PAR01)+_Prod+"99",.F.))
				RecLock("SB7",.T.)
				SB7->B7_FILIAL  := xFilial("SB7")
				SB7->B7_COD     := _Prod
				SB7->B7_LOCAL   :="99"
				SB7->B7_DOC     := "0001"
				SB7->B7_QUANT   := 0.00
				SB7->B7_DATA    := MV_PAR01
				SB7->B7_DTVALID := MV_PAR01
			Else
				RecLock("SB7",.F.)
			EndIf
			SB7->B7_QUANT   := SB7->B7_QUANT + TRB->QUANT
			MsUnLock()
		EndIf
		DbSelectArea("TRB")
		TRB->(DbSkip())
	EndDo
Return(.T.)


/*/{Protheus.doc} AtuBob
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function AtuBob()
	DbSelectArea("SZE")
	DbSetOrder(1) // ZE_FILIAL+ZE_NUMBOB
	
	DbUseArea(.T.,cDrive,"\CONDUSUL\INVBOB.DTC","TRB",.T.,.F.)
	
	DbSelectArea("TRB")
	DbGoTop()
	
	Do While TRB->(!Eof())
		_cnBob := Left("0"+AllTrim(TRB->NUMBOB)+"                    ",Len(SZE->ZE_NUMBOB))
		DbSelectArea("SZE")
		DbSetOrder(1) // ZE_FILIAL+ZE_NUMBOB
		If DbSeek(xFilial("SZE")+_cnBob,.F.)
			RecLock("SZE",.F.)
			SZE->ZE_STATUS := AllTrim(TRB->STATUS)
		Else
			RecLock("TRB",.F.)
			TRB->SITUAC := Upper(TRB->SITUAC)
		EndIf
		MsUnLock()
		DbSelectArea("TRB")
		DbSkip()
	EndDo
	DbSelectArea("TRB")
	DbCloseArea("TRB")
Return(.T.)


/*/{Protheus.doc} Estorna
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function Estorna()
	DbSelectArea("SC5")
	DbSetOrder(1)
	
	DbSelectArea("SC6")
	DbSetOrder(1)
	
	DbSelectArea("SC9")
	DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	
	DbSelectArea("SBF")
	DbSetOrder(1)
	
	DbSelectArea("SDC")
	DbSetOrder(1)
	DbSeek(xFilial("SDC"),.F.)
	Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->(!Eof())
		If SDC->DC_ORIGEM # "SC6"
			SDC->(DbSkip())
			Loop
		EndIf
		If Left(SDC->DC_LOCALIZ,1)$ "BT"   // se for bobina ou retalho... nao estorno
			SDC->(DbSkip())
			Loop
		EndIf
	
		SC5->(DbSeek(xFilial("SC5")+SDC->DC_PEDIDO,.F.))
	
		If SC5->C5_ENTREG <= (dDataBase + 4)
			SDC->(DbSkip())
			Loop
		EndIf
	
		SC9->(DbSeek(xFilial("SC9")+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ,.F.))
		_nAtuSDC := SDC->(Recno())
		SDC->(DbSkip())
		_nProxSDC := SDC->(Recno())
		SDC->(DbGoTo(_nAtuSDC))
		If SC9->(!Eof()) .And. SDC->DC_QUANT == SC9->C9_QTDLIB
			U_CDLibEst("E",SDC->DC_PRODUTO,SDC->DC_QUANT,SDC->DC_LOCAL,SDC->DC_LOCALIZ,SDC->DC_PEDIDO,SDC->DC_ITEM,SDC->DC_SEQ)
		EndIf
		SDC->(DbGoTo(_nProxSDC))
	EndDo
Return(.T.)


/*/{Protheus.doc} GeraSZ
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function GeraSZ()
	cPerg := "CDGN09"
	If !Pergunte(cPerg, .T.)
		Return(.T.)
	EndIf
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SZG")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	
	DbSelectArea("SZU")
	DbSetOrder(1)
	
	DbSeek(xFilial("SZU"),.F.)
	ProcRegua(RecCount())
	
	Do While SZU->ZU_FILIAL == xFilial("SZU") .And. SZU->(!Eof())
		IncProc()
	
		//	If SZU->ZU_STATUS $ "13"
		If SZU->ZU_DTINC <= MV_PAR01 .And. (SZU->ZU_DTRETOR > MV_PAR01 .Or. Empty(SZU->ZU_DTRETOR))
			SB1->(DbSeek(xFilial("SB1")+ SZU->ZU_PRODUTO,.F.))
	
			RecLock("SZG",.T.)
			SZG->ZG_FILIAL := xFilial("SZG")
			SZG->ZG_PRODUTO := SZU->ZU_PRODUTO
			SZG->ZG_DATA   := MV_PAR01 //CTOD("01/12/07")
			SZG->ZG_CONTAG := "3"
			SZG->ZG_LOCAL  := "95"
			SZG->ZG_DESC   := SB1->B1_DESC
			SZG->ZG_QUANT  := 1
			SZG->ZG_METROS := SZU->ZU_TOTAL
			MsUnLock()
		EndIf
	
		SZU->(DbSkip())
	EndDo
	MsgBox("Processamento Concluido" , "Atencao !!!", "INFO")
Return(.T.)


/*/{Protheus.doc} SalBob
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function SalBob()

	If Empty(MV_PAR01)
		Alert("Data Inventario Vazia!")
	EndIf
	
	If ! MsgBox("Data do Inventario é : " + DtoC(MV_PAR01),"Confirma?","YesNo")
		Return
	EndIf
	
	DbSelectArea("SB1")
	
	DbSetOrder(1)
	
	DbSelectArea("SF2")
	DbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	
	DbSelectArea("SZE")
	DbSetOrder(1)
	DbSeek(xFilial("SZE"),.F.)
	Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->(!Eof())
		If SZE->ZE_DTINV == MV_PAR01
			If SZE->ZE_STATUS == "F" // Está faturada OU CANCELADA
				// Verificar se a data do faturamento ocorreu após o inventário
				SF2->(DbSeek(xFilial("SF2")+SZE->ZE_DOC+SZE->ZE_SERIE,.F.))

				//If SF2->(Eof()) .Or. SF2->F2_EMISSAO < SZE->ZE_DTINV // onde estava com a cabeça quando fiz isto???
				// Claro... se a data do faturamento for anterior a data do inventário a bobina não deveria estar no estoque

				If SF2->(!Eof()) .And. SF2->F2_EMISSAO <= SZE->ZE_DTINV
					SZE->(DbSkip())
					Loop
				EndIf
			else
				If SZE->ZE_FILIAL == "01" // Em Itu avaliar as canceladas e faturadas em 3 lagoas não
					If SZE->ZE_STATUS == "C" // Está CANCELADA
						SZE->(DbSkip())
						Loop
					EndIf
				ElseIf SZE->ZE_FILIAL == "02" // Em Itu avaliar as canceladas e faturadas em 3 lagoas não
					If SZE->ZE_STATUS == "C" // Está CANCELADA
						RecLock("SZE",.F.)                                      '
						SZE->ZE_STATUS := "T"
						MsUnLock()
					EndIf
				EndIf
			EndIf
			SB1->(DbSeek(xFilial("SB1")+SZE->ZE_PRODUTO,.F.))
	
			DbSelectArea("SZG")
			RecLock("SZG",.T.)
			SZG->ZG_FILIAL := xFilial("SZG")
			SZG->ZG_PRODUTO := SZE->ZE_PRODUTO
			SZG->ZG_DATA   := MV_PAR01
			SZG->ZG_CONTAG := "1"
			SZG->ZG_LOCAL  := "01"
			SZG->ZG_DESC   := SZE->ZE_DESCPRO
			SZG->ZG_ACOND  := "B"
			SZG->ZG_QUANT  := 1
			SZG->ZG_LANCE  := SZE->ZE_QUANT
			SZG->ZG_METROS := SZE->ZE_QUANT
			SZG->ZG_PESCOB := SZE->ZE_QUANT*SB1->B1_PESCOB
			SZG->ZG_PESPVC := SZE->ZE_QUANT*SB1->B1_PESPVC
			SZG->ZG_LOTE   := "SalBob()"
			SZG->ZG_FORMA := "P"
			MsUnLock()
	
	
			DbSelectArea("SZG")
			RecLock("SZG",.T.)
			SZG->ZG_FILIAL := xFilial("SZG")
			SZG->ZG_PRODUTO := SZE->ZE_PRODUTO
			SZG->ZG_DATA   := MV_PAR01
			SZG->ZG_CONTAG := "2"
			SZG->ZG_LOCAL  := "01"
			SZG->ZG_DESC   := SZE->ZE_DESCPRO
			SZG->ZG_ACOND  := "B"
			SZG->ZG_QUANT  := 1
			SZG->ZG_LANCE  := SZE->ZE_QUANT
			SZG->ZG_METROS := SZE->ZE_QUANT
			SZG->ZG_PESCOB := SZE->ZE_QUANT*SB1->B1_PESCOB
			SZG->ZG_PESPVC := SZE->ZE_QUANT*SB1->B1_PESPVC
			SZG->ZG_LOTE   := "SalBob()"
			SZG->ZG_FORMA := "P"
			MsUnLock()
		EndIf
		SZE->(DbSkip())
	EndDo
Return(.T.)


/*/{Protheus.doc} ArruEmp
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function ArruEmp()
	DbSelectArea("SBF")
	DbSetOrder(1) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	
	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
	
	DbSelectArea("SDC")
	DbSetOrder(1)
	
	cQuery := ""
	cQuery := " UPDATE " + RetSqlName("SC9")
	cQuery += " SET C9_DAV = ' ' "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND C9_FILIAL = '" + xFilial("SC9")+"'"
	TCSqlExec(cQuery)
	
	cQuery := ""
	cQuery := " UPDATE " + RetSqlName("SDC")
	cQuery += " SET DC_STATUS = ' ' "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND DC_FILIAL = '" + xFilial("SDC")+"'"
	TCSqlExec(cQuery)
	
	cQuery := ""
	cQuery := " UPDATE " + RetSqlName("SBF")
	cQuery += " SET BF_EMPENHO = 0 "
	cQuery += " WHERE D_E_L_E_T_ <> '*' "
	cQuery += " AND BF_FILIAL = '" + xFilial("SBF")+"'"
	TCSqlExec(cQuery)
	
	// Zero o empenho da SB2
	cQuery := ""
	cQuery := " UPDATE " + RetSqlName("SB2")
	cQuery += " SET B2_RESERVA = 0 "
	cQuery += " WHERE D_E_L_E_T_ <> '*'"
	cQuery += " AND B2_FILIAL = '" + xFilial("SB2")+"'"
	TCSqlExec(cQuery)
	
	DbSelectArea("SC9")
	DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	
	DbSeek(xFilial("SDC"),.F.)
	DbSelectArea("SDC")
	DbSetOrder(1)
	DbSeek(xFilial("SDC"),.F.)
	Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->(!Eof())
		DbSelectArea("SC9")
		DbSeek(xFilial("SC9")+SDC->DC_PEDIDO+SDC->DC_ITEM+SDC->DC_SEQ,.F.)
		If (SC9->(Eof()) .Or. !Empty(SC9->C9_BLEST) .Or. SC9->C9_QTDLIB # SDC->DC_QUANT) .And. SDC->DC_ORIGEM == "SC6"
			RecLock("SDC",.F.)
			SDC->DC_STATUS := "X"
			MsUnLock()
		Else
			If SDC->DC_ORIGEM == "SC6"
				RecLock("SC9",.F.)
				If Empty(SC9->C9_DAV)
					SC9->C9_DAV := "0"
				Else
					SC9->C9_DAV := Soma1(SC9->C9_DAV)
				EndIf
				MsUnLock()
			EndIf
	
			DbSelectArea("SB2")
			DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
			If DbSeek(xFilial("SB2")+SDC->DC_PRODUTO+SDC->DC_LOCAL,.F.)
				RecLock("SB2",.F.)
				SB2->B2_RESERVA := SB2->B2_RESERVA + SDC->DC_QUANT
				MsUnLock()
			Else
				RecLock("SDC",.F.)
				SDC->DC_STATUS := "A"
				MsUnLock()
			EndIf
	
			DbSelectArea("SBF")
			DbSetOrder(1) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
			If DbSeek(xFilial("SBF")+SDC->DC_LOCAL+SDC->DC_LOCALIZ+SDC->DC_PRODUTO,.F.)
				RecLock("SBF",.F.)
				SBF->BF_EMPENHO := SBF->BF_EMPENHO + SDC->DC_QUANT
				MsUnLock()
			Else
				RecLock("SDC",.F.)
				SDC->DC_STATUS := If(SDC->DC_STATUS == "A","C","B")
				MsUnLock()
			EndIf
		EndIf
		DbSelectArea("SDC")
		SDC->(DbSkip())
	EndDo
	Alert("Terminei")
Return(.T.)


/*/{Protheus.doc} CriaPlan
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function CriaPlan()
	cPerg := "CDGN09"
	If !Pergunte(cPerg, .T.)
		Return(.T.)
	EndIf
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SZG")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	
	DbUseArea(.T.,cDrive,"\CONDUSUL\REAL_ITU.DTC","TRB",.T.,.F.)	
	DbSelectArea("TRB")
	
	_nTotPlan := 0
	Do While TRB->(!Eof())
		If TRB->QUANT > 0
			_Prod := Left(Alltrim(TRB->CODIGO) + Space(TAMSX3("B1_COD")[1]),TAMSX3("B1_COD")[1])
			If SB1->(DbSeek(xFilial("SB1")+ _Prod,.F.))
				RecLock("SZG",.T.)
				SZG->ZG_FILIAL := xFilial("SZG")
				SZG->ZG_PRODUTO := _Prod
				SZG->ZG_DATA   := MV_PAR01 //CTOD("01/12/07")
				SZG->ZG_CONTAG := "3"
				SZG->ZG_LOCAL  := TRB->LOCAL
				SZG->ZG_DESC   := SB1->B1_DESC
				SZG->ZG_QUANT  := 1
				SZG->ZG_METROS := TRB->QUANT
				SZG->ZG_LOTE   := "FABRICA"
				MsUnLock()
			Else
				xxx := 1
			EndIf
		EndIf
		TRB->(DbSkip())
	EndDo
	
	DbSelectArea("TRB")
	DbCloseArea("TRB")
Return(.T.)


/*/{Protheus.doc} GeraDoSDB
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function GeraDoSDB()
	cPerg := "CDGN09"
	If !Pergunte(cPerg, .T.)
		Return(.T.)
	EndIf
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SZG")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	
	DbUseArea(.T.,cDrive,"SDB0101.DTC","TRB",.T.,.F.)	
	ProcRegua(RecCount())
	
	Do While TRB->(!Eof())
		IncProc()
	
		SB1->(DbSeek(xFilial("SB1")+ TRB->DB_PRODUTO,.F.))
	
		RecLock("SZG",.T.)
		SZG->ZG_FILIAL  := xFilial("SZG")
		SZG->ZG_DATA    := MV_PAR01
		SZG->ZG_PRODUTO := TRB->DB_PRODUTO
		SZG->ZG_CONTAG  := "3"
		SZG->ZG_LOCAL   := "01"
		SZG->ZG_DESC    := SB1->B1_DESC
		SZG->ZG_ACOND   := Left(TRB->DB_LOCALIZ,1)
		SZG->ZG_LANCE   := Val(Substr(TRB->DB_LOCALIZ,2,5))
		SZG->ZG_METROS  := TRB->DB_QUANT
		SZG->ZG_QUANT   := (SZG->ZG_METROS / SZG->ZG_LANCE)
		SZG->ZG_LOTE    := TRB->DB_DOC
		SZG->ZG_PESCOB  := SZG->ZG_METROS*SB1->B1_PESCOB
		SZG->ZG_PESPVC  := SZG->ZG_METROS*SB1->B1_PESPVC
		SZG->ZG_FORMA   := "I"
		MsUnLock()
		TRB->(DbSkip())
	EndDo
	MsgBox("Processamento Concluido" , "Atencao !!!", "INFO")
Return(.T.)


/*/{Protheus.doc} CriaBob2
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function CriaBob2()
	local cDrive	:= ''
	cPerg := "CDGN09"
	If !Pergunte(cPerg, .T.)
		Return(.T.)
	EndIf
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SZG")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	
	For _nvez := 1 To 2
		If _nvez == 1
			DbUseArea(.T.,cDrive,"\CONDUSUL\Bob3L01.DTC","TRB",.T.,.F.)
		Else
			DbUseArea(.T.,cDrive,"\CONDUSUL\Bob3L02.DTC","TRB",.T.,.F.)
		EndIf
		DbSelectArea("TRB")
	
		_nTotPlan := 0
		Do While TRB->(!Eof())
	
			_Prod := Left(Alltrim(TRB->CODIGO) + Space(TAMSX3("B1_COD")[1]),TAMSX3("B1_COD")[1])
			SB1->(DbSeek(xFilial("SB1")+ _Prod,.F.))
			For _ct := 1 to 28
				_Vari := "TRB->QUANT"+StrZero(_ct,2)
				_Qtd  := &_Vari.
				If ValType(_Qtd) # "N"
					_Qtd  := Val(_Qtd)
				EndIf
				If _Qtd > 0
					_nTotPlan += _Qtd
					RecLock("SZG",.T.)
					SZG->ZG_FILIAL := xFilial("SZG")
					SZG->ZG_PRODUTO := _Prod
					SZG->ZG_DATA   := MV_PAR01 //CTOD("01/12/07")
					SZG->ZG_CONTAG := Str(_nvez,1)
					SZG->ZG_LOCAL  := "01"
					SZG->ZG_DESC   := SB1->B1_DESC
					SZG->ZG_ACOND  := "B"
					SZG->ZG_QUANT  := 1
					SZG->ZG_LANCE  := _Qtd
					SZG->ZG_METROS := _Qtd
					SZG->ZG_LOTE   := "IMPBOB"
					SZG->ZG_FORMA  := "I"
					MsUnLock()
				EndIf
			Next
			TRB->(DbSkip())
		EndDo
		Alert(_nTotPlan)
	
		DbSelectArea("TRB")
		DbCloseArea("TRB")
	Next
Return(.T.)


/*/{Protheus.doc} MovSB7
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function MovSB7()
	// As funções abaixo são chamadas diretamento em Fórmulas e
	// utiliza a tabela SB7 para tratar algumas situações que necessitam
	// de movimentação em estoque.
	
	//_MV_PAR01 := Ctod("26/09/12")
	//_MV_PAR01 := Ctod("07/10/12")
	//_MV_PAR01 := Ctod("27/09/12")
	//_MV_PAR01 := Ctod("08/02/13")
	//_MV_PAR01 := Ctod("03/01/14")
	//_MV_PAR01 := Ctod("14/11/16")
	_MV_PAR01 := Ctod("29/11/16")
	cQuery := ""
	cQuery += " SELECT COUNT(*) QTDREG FROM "+RetSqlName("SB7")
	cQuery += " WHERE B7_FILIAL = '"+xFilial("SB7")+"'"
	cQuery += " AND B7_DATA = '"+dtos(_MV_PAR01)+"'"
	cQuery += " AND D_E_L_E_T_ <>'*'"
	cQuery := ChangeQuery(cQuery)
	
	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"
	
	DbSelectArea("TRB")
	DbGotop()
	
	_nQtReg := TRB->QTDREG
	
	DbSelectArea("SBF")
	DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
	
	DbSelectArea("SB7")
	DbSetOrder(1) // B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE+B7_CONTAGE
	
	ProcRegua(_nQtReg)
	DbSeek(xFilial("SB7") + DTOS(_Mv_par01),.F.)
	
	// Alert("retirar o IF dos produtos")
	_lOutro := .T. // Variável para controle do loop... se quizer parar no memio do Debug
	Do While SB7->B7_FILIAL == xFilial("SB7") .And. SB7->B7_DATA == _Mv_par01 .And. SB7->(!Eof()) .And. _lOutro
	
		If !SB7->B7_STATUS $ " 1"
			IncProc()
			SB7->(DbSkip())
			Loop
		EndIf
	
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SB7->B7_COD,.F.))
	
		SBF->(DbSetOrder(1)) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BRF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		If !SBF->(DbSeek(xFilial("SBF")+SB7->B7_LOCAL+SB7->B7_LOCALIZ+SB7->B7_COD,.F.))
			IncProc()
			SB7->(DbSkip())
			Loop
		EndIf
		RecLock("SBF",.F.)
	
		cB7_COD     := SB7->B7_COD
		cB7_LOCAL   := SB7->B7_LOCAL
		cB7_LOCALIZ := SB7->B7_LOCALIZ
		cB7_NUMSERI := SB7->B7_NUMSERI
		cB7_LOTECTL := SB7->B7_LOTECTL
		cB7_NUMLOTE := SB7->B7_NUMLOTE
		cB7_CONTAGE := SB7->B7_CONTAGE
		_nQtdSB7 := 0
	
		Do While SB7->(!Eof()) .And. SB7->B7_FILIAL == xFilial("SB7") .And. SB7->B7_DATA == _Mv_par01 .And. ;
			SB7->B7_COD+SB7->B7_LOCAL+SB7->B7_LOCALIZ+SB7->B7_NUMSERI+SB7->B7_LOTECTL+SB7->B7_NUMLOTE+SB7->B7_CONTAGE == ;
			cB7_COD+  cB7_LOCAL+  cB7_LOCALIZ+  cB7_NUMSERI+  cB7_LOTECTL+  cB7_NUMLOTE+  cB7_CONTAGE
	
			IncProc()
			If !SB7->B7_STATUS $ " 1"
				SB7->(DbSkip())
				Loop
			EndIf
	
			If (SBF->BF_QUANT-SBF->BF_EMPENHO) >= (SB7->B7_QUANT-SB7->B7_QTSEGUM) .And. SBF->BF_EMPENHO >= 0
				SBF->BF_EMPENHO := SBF->BF_EMPENHO + (SB7->B7_QUANT-SB7->B7_QTSEGUM)
				_nQtdSB7 += (SB7->B7_QUANT-SB7->B7_QTSEGUM)
				RecLock("SB7",.F.)
				SB7->B7_STATUS := "2"
				SB7->(MsUnLock())
			ElseIf (SBF->BF_QUANT-SBF->BF_EMPENHO) > 0 .And. SBF->BF_EMPENHO >= 0
				// Se não tenho tudo - tiro o que tenho, desde que seja múltiplo da localização
				_nTmLance := Val(Substr(SB7->B7_LOCALIZ,2,5))
				_nQtTira := Int((SBF->BF_QUANT-SBF->BF_EMPENHO) / _nTmLance) * _nTmLance
				SBF->BF_EMPENHO := SBF->BF_EMPENHO + _nQtTira
				_nQtdSB7 += _nQtTira
				RecLock("SB7",.F.)
				SB7->B7_QTSEGUM := SB7->B7_QTSEGUM + _nQtTira
				SB7->(MsUnLock())
			EndIf
			SB7->(DbSkip())
		EndDo
	
		DbSelectArea("SBF")
		MsUnLock()
	
		If _nQtdSB7 <= 0
			Loop
		EndIf
	
		If _MV_PAR01 == Ctod("26/09/12") // Transferir quantidades para o armazém 05
	
			DbSelectArea("SD3")
			DbSetOrder(4) //D3_FILIAL+D3_NUMSEQ+D3_CHAVE+D3_COD
			cNumSeq := ProxNum()
	
			For _nMovts := 1 To 2
				If     _nMovts == 1  // .And. _cMovic == "E" // Fazer Requisição no Local 01
					_cTM := "RE4"
					_cLocal := "01"
					//		ElseIf _nMovts == 1 .And. _cMovic == "R" // Fazer Requisição no Local 95
					//			_cTM := "RE4"
					//			_cLocal := "95"
				ElseIf _nMovts == 2  // .And. _cMovic == "E" // Fazer Devolução  no Local 05 -- EPA Indisponível
					_cTM := "DE4"
					_cLocal := "05"
	
					DbSelectArea("SBE")
					DbSetOrder(1)
					If !DbSeek(xFilial("SBE") + _cLocal + cB7_LOCALIZ,.F.)
						If Left(cB7_LOCALIZ,1) == "T"
							_cDesLo :=  "Retalho de "
						ElseIf Left(cB7_LOCALIZ,1) == "B"
							_cDesLo :=  "Bobina de "
						ElseIf Left(cB7_LOCALIZ,1) == "M"
							_cDesLo :=  "Carretel de Mad.de "
						ElseIf Left(cB7_LOCALIZ,1) == "C"
							_cDesLo :=  "Carretel de "
						ElseIf Left(cB7_LOCALIZ,1) == "R"
							_cDesLo :=  "Rolo de "
						ElseIf Left(cB7_LOCALIZ,1) == "L"
							_cDesLo :=  "Blister de "
						EndIf
						//_cDesLo += Str(Val(Substr(cB7_LOCALIZ,2,5)),5) + " metros"
						_cDesLo += Str(Val(Substr(cB7_LOCALIZ,2,5)),5) + " " + Posicione("SAH",1,xFilial("SAH")+SB1->B1_UM,"AH_DESCPO")
	
						RecLock("SBE",.T.)
						SBE->BE_FILIAL   := xFilial("SBE")
						SBE->BE_LOCAL    := _cLocal
						SBE->BE_LOCALIZ  := cB7_LOCALIZ
						SBE->BE_DESCRIC  := _cDesLo
						SBE->BE_PRIOR    := "ZZZ"
						SBE->BE_STATUS   := "1"
						MsUnLock()
					EndIf
	
					//		ElseIf _nMovts == 2 .And. _cMovic == "R" // Fazer Devolução  no Local 95
					//			_cTM := "DE4"
					//			_cLocal := "99"
				EndIf
	
				If _cTM == "RE4" // Requisição
					RecLock("SBF",.F.)
					SBF->BF_EMPENHO := SBF->BF_EMPENHO - _nQtdSB7
					MsUnLock()
				EndIf
	
				DbSelectArea("SB2")
				If !DbSeek(xFilial("SB2")+cB7_COD+_cLocal,.F.)
					CriaSB2(cB7_COD,_cLocal)
				EndIf
				RecLock("SB2",.F.)
	
				RecLock("SD3",.T.)
				SD3->D3_FILIAL  := xFilial("SD3")
				SD3->D3_TM      := If(_cTM == "RE4","999","499")
				SD3->D3_COD     := cB7_COD
				SD3->D3_UM      := SB1->B1_UM
				SD3->D3_QUANT   := _nQtdSB7
				SD3->D3_CF      := _cTM
				SD3->D3_LOCAL   := _cLocal
				SD3->D3_LOCALIZ := cB7_LOCALIZ
				SD3->D3_EMISSAO := dDataBase
				SD3->D3_NUMSEQ  := cNumSeq
				SD3->D3_TIPO    := SB1->B1_TIPO
				SD3->D3_USUARIO := cUserName
				SD3->D3_CHAVE   := If(_cTM == "RE4","E0","E9")
				SD3->D3_GRUPO   := SB1->B1_GRUPO
				SD3->D3_SEGUM   := SB1->B1_SEGUM
				SD3->D3_CONTA   := SB1->B1_CONTA
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Pega os 15 custos medios atuais            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava o custo da movimentacao              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				aCusto := GravaCusD3(aCM)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Atualiza o saldo atual (VATU) com os dados do SD3     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				_lErrAtu := B2AtuComD3(aCusto,,.F.) // .F.->Não mostra help se der erro // Retorna .T. se deu erro na atualização
				SB1->(MsUnLock())
				SB2->(MsUnLock())
				SD3->(MsUnLock())
			Next
		ElseIf _MV_PAR01 == Ctod("07/10/12") .Or. _MV_PAR01 == Ctod("08/10/12") .Or.;
			_MV_PAR01 == Ctod("08/02/13") .Or. _MV_PAR01 == Ctod("03/01/14") .Or.;
			_MV_PAR01 == Ctod("06/03/14") .Or. _MV_PAR01 == Ctod("30/09/15")
			// Retirar as quantidades enviando para sucata
	
			RecLock("SBF",.F.)
			SBF->BF_EMPENHO := SBF->BF_EMPENHO - _nQtdSB7
			MsUnLock()
	
			_aVetor:={	{"D3_TM"      , "520"      ,NIL},;
			{"D3_COD"     , cB7_COD    ,NIL},;
			{"D3_UM"      , SB1->B1_UM ,NIL},;
			{"D3_QUANT"   , _nQtdSB7   ,NIL},;
			{"D3_LOCAL"   , cB7_LOCAL  ,NIL},;
			{"D3_EMISSAO" , dDataBase  ,NIL},;
			{"D3_LOCALIZ" , cB7_LOCALIZ,NIL}}
	
			lMsErroAuto := .F.
			_xVolta := MSExecAuto({|x,y| Mata240(x,y)},_aVetor,3)
			If lMsErroAuto
				MostraErro()
			EndIf
		EndIf
		DbSelectArea("SB7")
	EndDo
Return(.T.)


/*/{Protheus.doc} AtuGpo
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function AtuGpo()
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbUseArea(.T.,cDrive,"\CONDUSUL\GPROD.DTC","TRB",.T.,.F.)
	DbGoTop()
	Do While TRB->(!Eof())
		_B1_COD := Left(AllTrim(TRB->B1_COD) + Space(TAMSX3("B1_COD")[1]),TAMSX3("B1_COD")[1])
		_B1_GRUPO := Left(AllTrim(TRB->B1_GRUPO) + Space(Len(SB1->B1_GRUPO)),Len(SB1->B1_GRUPO))
	
		DbSelectArea("SB1")
		If DbSeek(xFilial("SB1")+_B1_COD,.F.)
			If SB1->B1_GRUPO # _B1_GRUPO
				RecLock("SB1",.F.)
				SB1->B1_GRUPO := _B1_GRUPO
				MsUnLock()
			EndIf
		EndIf
		TRB->(DbSkip())
	EndDo
Return(.T.)


/*/{Protheus.doc} CorrBob
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function CorrBob()
	DbUseArea(.T.,cDrive,"\CONDUSUL\BOB_3L.DTC","TRB",.T.,.F.)
	DbGoTop()
	Do While TRB->(!Eof())
		_Codigo := Substr(TRB->CODIGO_+ Space(TAMSX3("B1_COD")[1]),2,TAMSX3("B1_COD")[1])
		_nTotal := 0
		_nLances := {}
		For _nCol := 1 to 22
			_cColu := "TRB->QTD" + StrZero(_nCol,2)
			_nQtColu := &_cColu.
			If _nQtColu > 0
				_nTotal += _nQtColu
				_nPos := 0
				For _nLc := 1 to Len(_nLances)
					If _nLances[_nLc,1] == _nQtColu
						_nPos := _nLc
						Exit
					EndIf
				Next
				If _nPos == 0
					AAdd(_nLances,{_nQtColu,_nQtColu})
				Else
					_nLances[_nPos,2] += _nQtColu
				EndIf
			EndIf
		Next
	
		If Len(_nLances) > 0
			DbSelectArea("SB2")
			DbSetOrder(1)
	
			DbSelectArea("SB1")
			DbSetOrder(1)
	
			DbSeek(xFilial("SB1")+_Codigo,.F.)
	
			If !SB2->(DbSeek(xFilial("SB2")+_Codigo+"01",.F.))
				CriaSB2(_Codigo,"01")
				SB2->(DbSeek(xFilial("SB2")+_Codigo+"01",.F.))
			EndIf
		EndIf
	
		// Fazer o Movimento de Entrada pelo SD3
	
		For _nLc := 1 to Len(_nLances)
			_cAcond := Left("B" + StrZero(_nLances[_nLc,1],5) + Space(TAMSX3("B1_COD")[1]),TAMSX3("B1_COD")[1])
	
			DbSelectArea("SBE")
			DbSetOrder(1)
			If !DbSeek(xFilial("SBE") + "01" + _cAcond,.F.)
				//_cDesLo :=  "Bobina de " += Str(_nLances[_nLc,1],5) + " metros"
				_cDesLo := "Bobina de "
				_cDesLo += Str(_nLances[_nLc,1],5) + " " + Posicione("SAH",1,xFilial("SAH")+SB1->B1_UM,"AH_DESCPO")
	
				RecLock("SBE",.T.)
				SBE->BE_FILIAL   := xFilial("SBE")
				SBE->BE_LOCAL    := "01"
				SBE->BE_LOCALIZ  := _cAcond
				SBE->BE_DESCRIC  := _cDesLo
				SBE->BE_PRIOR    := "ZZZ"
				SBE->BE_STATUS   := "1"
				MsUnLock()
			EndIf
	
			SD3->(DbSetOrder(2))
			Do While .T.
				_DocD3 :=GetSx8Num("SD3","D3_DOC")
				ConfirmSx8()
				If SD3->(!DbSeek(xFilial("SD3")+_DocD3,.F.))
					Exit
				EndIf
			EndDo
			_aVetor:={	{"D3_TM"      ,"110"       ,NIL},;
						{"D3_COD"     ,SB1->B1_COD ,NIL},;
						{"D3_LOCAL"   ,"01"        ,NIL},;
						{"D3_LOCALIZ" ,_cAcond     ,NIL},;
						{"D3_DOC"     ,_DocD3      ,NIL},;
						{"D3_QUANT"   ,_nLances[_nLc,2],NIL},;
						{"D3_EMISSAO" ,dDataBase   ,NIL}}
	
			// Realiza o Movimento no SD3
			_cVoltaMSE := MSExecAuto({|x,y| Mata240(x,y)},_aVetor,3)
			If lMsErroAuto
				MOSTRAERRO()
				lMsErroAuto := .F.
			Else
				DbSelectArea("SDA")
				DbSetOrder(1) // DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
				If DbSeek(xFilial("SDA") + SD3->D3_COD + SD3->D3_LOCAL + SD3->D3_NUMSEQ,.F.)
					If SDA->DA_SALDO == SDA->DA_QTDORI
						DistSDA()
					EndIf
				EndIf
			EndIf
		Next
	
		TRB->(DbSkip())
	EndDo
Return(.T.)


/*/{Protheus.doc} DistSDA
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
Static Function DistSDA()
	aCAB  := {	{"DA_PRODUTO" ,SDA->DA_PRODUTO             , nil},;
				{"DA_QTDORI"  ,SDA->DA_QTDORI              , nil},;
				{"DA_SALDO"   ,SDA->DA_SALDO               , nil},;
				{"DA_DATA"    ,SDA->DA_DATA                , nil},;
				{"DA_LOCAL"   ,SDA->DA_LOCAL               , nil},;
				{"DA_DOC"     ,SDA->DA_DOC                 , nil},;
				{"DA_ORIGEM"  ,SDA->DA_ORIGEM              , nil},;
				{"DA_NUMSEQ"  ,SDA->DA_NUMSEQ              , nil},;
				{"DA_QTSEGUM" ,SDA->DA_QTSEGUM             , nil},;
				{"DA_QTDORI2" ,SDA->DA_QTDORI2             , nil}}
	
	//DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM
	SDB->(dbSeek(xFilial("SDB")+SDA->DA_PRODUTO+SDA->DA_LOCAL+SDA->DA_NUMSEQ+SDA->DA_DOC+SDA->DA_SERIE+SDA->DA_CLIFOR+SDA->DA_LOJA,.F.))
	
	_cDbItem := Replicate("0",Len(SDB->DB_ITEM))
	
	While SDB->(!Eof()) .And. ;
		xFilial("SDB")+SDA->DA_PRODUTO+SDA->DA_LOCAL+SDA->DA_NUMSEQ+SDA->DA_DOC+SDA->DA_SERIE+SDA->DA_CLIFOR+SDA->DA_LOJA == ;
		SDB->DB_FILIAL+SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_NUMSEQ+SDB->DB_DOC+SDB->DB_SERIE+SDB->DB_CLIFOR+SDB->DB_LOJA
	
		If SDB->DB_ITEM > _cDbItem
			_cDbItem := SDB->DB_ITEM
		EndIf
		SDB->(dbSkip())
	EndDo
	
	_cDbItem := Soma1(_cDbItem)
	
	aITENS:={{	{"DB_ITEM"    , _cDbItem         , nil},;
				{"DB_LOCALIZ" , _cAcond          , nil},;
				{"DB_QUANT"   , SDA->DA_SALDO    , nil},;
				{"DB_DATA"    , dDataBase        , nil},;
				{"DB_ESTORNO" ," "               , nil} }}
	
	lMsErroAuto:=.f.
	_cVoltaMSE := msExecAuto({|x,y|mata265(x,y)},aCAB,aITENS)
	If lMsErroAuto
		MostraErro()
	EndIf
Return(.T.)


/*/{Protheus.doc} ValSoma
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined
@param _lSoma, , descricao
@type function
/*/
User Function ValSoma(_lSoma)
	//_lSoma = .T. // Somar os Elementos
	//_lSoma = .F. // Validar os Elementos
	_cVarSm := AllTrim(M->ZG_SOMA)
	_Volta := ""
	If _lSoma
		_Volta := &(_cVarSm)
	Else
		_Volta := .T.
		For _nPos := 1 To Len(_cVarSm)
			If !Substr(_cVarSm,_nPos,1) $ "1234567890+"
				_Volta := .F.
				Alert("Utilizar Somente Números ou Sinal de Adição (+)")
				Exit
			EndIf
		Next
	EndIf
Return(_Volta)


/*/{Protheus.doc} _WhenSoma
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function _WhenSoma()

Return(Posicione("SB1",1,xFilial("SB1")+M->ZG_PRODUTO,"B1_LOCALIZ")#"S")


/*/{Protheus.doc} _WhenPesCob
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function _WhenPesCob()

Return(Posicione("SB1",1,xFilial("SB1")+M->ZG_PRODUTO,"B1_TIPO+B1_UM")=="PIMT")


/*/{Protheus.doc} TrcEstrt
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined
@param _xTab, , descricao
@type function
/*/
User Function TrcEstrt(_xTab)
	// Atualiza sx3 no banco... a tabela não pode estar em uso.
	_Volta := X31UPDTABLE(_xTab)
Return(.T.)


/*/{Protheus.doc} SalRet05
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function SalRet05() // ESTA ROTINA ERA USADA PARA PEGAR OS SALDOS DO ARMAZEM 05 E JOGAR NO INVENTÁRIO
	MV_PAR01 := Ctod("07/04/2013")
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SBF")
	DbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	
	DbSetOrder(1)
	DbSeek(xFilial("SBF"),.F.)
	Do While SBF->BF_FILIAL == xFilial("SBF") .And. SBF->(!Eof())
		If SBF->BF_LOCAL == "05"
			SB1->(DbSeek(xFilial("SB1")+SBF->BF_PRODUTO,.F.))
	
			DbSelectArea("SZG")
			RecLock("SZG",.T.)
			SZG->ZG_FILIAL := xFilial("SZG")
			SZG->ZG_PRODUTO := SBF->BF_PRODUTO
			SZG->ZG_DATA   := MV_PAR01
			SZG->ZG_CONTAG := "1"
			SZG->ZG_LOCAL  := "05"
			SZG->ZG_DESC   := SB1->B1_DESC
			SZG->ZG_ACOND  := "T" //Left(SBF->BF_LOCALIZ,1)
			SZG->ZG_METROS := SBF->BF_QUANT
			SZG->ZG_LANCE  := Val(Substr(SBF->BF_LOCALIZ,2,5))
			SZG->ZG_QUANT  := SBF->BF_QUANT / SZG->ZG_LANCE
			SZG->ZG_PESCOB := SZG->ZG_METROS*SB1->B1_PESCOB
			SZG->ZG_PESPVC := SZG->ZG_METROS*SB1->B1_PESPVC
			SZG->ZG_LOTE   := "RET_05"
			SZG->ZG_FORMA  := "P"
			MsUnLock()
	
			DbSelectArea("SZG")
			RecLock("SZG",.T.)
			SZG->ZG_FILIAL := xFilial("SZG")
			SZG->ZG_PRODUTO := SBF->BF_PRODUTO
			SZG->ZG_DATA   := MV_PAR01
			SZG->ZG_CONTAG := "2"
			SZG->ZG_LOCAL  := "05"
			SZG->ZG_DESC   := SB1->B1_DESC
			SZG->ZG_ACOND  := "T" // Left(SBF->BF_LOCALIZ,1)
			SZG->ZG_METROS := SBF->BF_QUANT
			SZG->ZG_LANCE  := Val(Substr(SBF->BF_LOCALIZ,2,5))
			SZG->ZG_QUANT  := SBF->BF_QUANT / SZG->ZG_LANCE
			SZG->ZG_PESCOB := SZG->ZG_METROS*SB1->B1_PESCOB
			SZG->ZG_PESPVC := SZG->ZG_METROS*SB1->B1_PESPVC
			SZG->ZG_LOTE   := "RET_05"
			SZG->ZG_FORMA  := "P"
			MsUnLock()
		EndIf
		SBF->(DbSkip())
	EndDo
Return(.T.)


/*/{Protheus.doc} recColet
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined
@param _xfilial, , descricao
@param _xtoDado, , descricao
@param _xDado, , descricao
@type function
/*/
User Function recColet(_xfilial,_xtoDado,_xDado)
	
	DbSelectArea("SZG")
	_xTpDado := Type("_xDado")
	If _xTpDado == "U"
		_xTpDado := Valtype(_xDado)
	EndIf
	
	_xTpDado := Upper(_xTpDado)
	
	If _xTpDado == "A"
		For _n := 1 to Len(_xDado)
			RecLock("SZG",.T.)
			SZG->ZG_FILIAL := xFilial("SZG")
			SZG->ZG_SOMA   := _xtoDado
			SZG->ZG_DESC   := _xDado
			MsUnLock()
		Next
	ElseIf _xTpDado == "C"
		_xDado := AllTrim(_xDado)
		_nTam := Len(SZG->ZG_DESC)
		Do While Len(_xDado) > 0
			RecLock("SZG",.T.)
			SZG->ZG_FILIAL := xFilial("SZG")
			SZG->ZG_SOMA   := _xtoDado
			SZG->ZG_DESC   := Left(_xDado,_nTam)
			MsUnLock()
			_nTamNow := Min(Len(_xDado),_nTam)
			_xDado := Right(_xDado,len(_xDado)-_nTamNow)
		EndDo
	Else
		RecLock("SZG",.T.)
		SZG->ZG_FILIAL := xFilial("SZG")
		SZG->ZG_DESC   := _xTpDado
		MsUnLock()
	EndIf
Return(.T.)


/*/{Protheus.doc} VeBloq
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function VeBloq()
	If Posicione("SB1",1,xFilial("SB1")+M->ZG_PRODUTO,"B1_MSBLQL") == "1" // -> Sim Produto Bloqueado
		Alert("Produto com Movimentação Bloqueada")
		Return(.F.)
	EndIf
Return(.T.)
//Todos os parâmetros são do tipo String (Texto)
//
//
//filial = "01"
//tipoDado = "I"
//Dado = "Um texto digitável pelo coletor"


/*/{Protheus.doc} ArruRetr
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function ArruRetr()
	DbSelectArea("SB7")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	
	DbSelectArea("ZZE")
	DbSetOrder(2)
	
	_cFeito := ""
	DbSelectArea("SZL")
	SZL->(DbSetOrder(2))  // ZL_FILIAL+ZL_STATUS+ZL_PRODUTO
	SZL->(DbSeek(xFilial("SZL") + "E",.F.))
	Do While SZL->ZL_FILIAL == xFilial("SZL") .And. SZL->ZL_STATUS == "E" .And. SZL->(!Eof())
		If SZL->ZL_TIPO # "R"
			SZL->(DbSkip())
			Loop
		EndIf
	
		If ZZE->(!DbSeek(xFilial("ZZE")+SZL->ZL_ZZEID,.F.))
			SZL->(DbSkip())
			Loop
		EndIf
	
		If !SZL->ZL_ZZEID $ _cFeito
			_cFeito += "/" + SZL->ZL_ZZEID
	
			_cAcond := (ZZE->ZZE_ACONDE+StrZero(ZZE->ZZE_METRAE,5))
			_cAcond := PadR(_cAcond,Len(SB7->B7_LOCALIZ))
	
			If !SB7->(DbSeek(xFilial("SB7") + "20160403" + SZL->ZL_PRODUTO + "90" + _cAcond,.F.))
				RecLock("SB7",.T.)
				SB7->B7_FILIAL  := xFilial("SB7")
				SB7->B7_COD     := SZL->ZL_PRODUTO
				SB7->B7_LOCAL   := "90"
				SB7->B7_DOC     := "0001"
				SB7->B7_DATA    := Ctod("03/04/2016")
				SB7->B7_DTVALID := Ctod("03/04/2016")
				SB7->B7_LOCALIZ := _cAcond
			Else
				RecLock("SB7",.F.)
			EndIf
			SB7->B7_QUANT := SB7->B7_QUANT + ZZE->ZZE_TOTEN
			MsUnLock()
		EndIf
	
		DbSelectArea("SZB")
		DbSetOrder(1) //ZB_FILIAL+ZB_NUM+ZB_ITBMM
		If DbSeek(xFilial("SZB") + SZL->ZL_NUMBMM + SZL->ZL_ITBMM,.F.)
			RecLock("SZB",.F.)
			DbDelete()
			MsUnLock()
		EndIf
	
		DbSelectArea("SZL")
		RecLock("SZL",.F.)
		SZL->ZL_STATUS := "A"
		SZL->ZL_NUMBMM := "  "
		SZL->ZL_ITBMM  := "  "
		MsUnLock()
	
		SZL->(DbSeek(xFilial("SZL") + "E",.F.))
	EndDo
Return(.T.)


/*/{Protheus.doc} EstMovD3
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined
@param _lPosic, , descricao
@type function
/*/
Static Function EstMovD3(_lPosic)
//Esta função precisa identiticar o tipo do movimento e efetuar o estorno pelo execauto correto.
// Posiciono o D3 correspondente e faço o estorno
//
Default _lPosic := .F.

	lMsErroAuto	:= .F.
	If !_lPosic // D3 não posicionado
		DbSelectArea("SD3")
		DbSetOrder(3) // D3_FILIAL+D3_COD+D3_LOCAL+D3_NUMSEQ+D3_CF
		DbSeek(xFilial("SD3") + cB7_COD + cB7_LOCAL + aRegsB7[_nPosD3,2],.F.)
	EndIf
	If SD3->D3_ESTORNO == "S" // Já foi estornado
		Return(.T.)
	EndIf
	If SD3->D3_NUMSEQ == aRegsB7[_nPosD3,2] .And. SD3->(!Eof()) // Registro válido
		If SD3->D3_TM <= "499" // É uma devolução
			// Corrijo o saldo para MENOS (estorno da devolução)
			_nValEst -= SD3->D3_QUANT // Pra retornar um nro negativo
		ElseIf SD3->D3_TM >= "500" // É uma requisição
			// Corrijo o saldo para MAIS (estorno da requisição)
			_nValEst += SD3->D3_QUANT // Pra retornar um nro positivo
		EndIf
	
		//verificar antes qual tipo do movimento que deve ser estornado
		If SD3->D3_CF $ "RE0/DE0" // Requisição ou devolução
		     //Estornar pela MATA240
			aItens 	:= {{"D3_TM"		,SD3->D3_TM		,NIL},;
						{"D3_COD"		,SD3->D3_COD	,NIL},;
						{"D3_DOC"		,SD3->D3_DOC	,NIL},;
						{"D3_UM"		,SD3->D3_UM		,NIL},;
						{"D3_LOCAL"		,SD3->D3_LOCAL	,NIL},;
						{"D3_LOCALIZ"	,SD3->D3_LOCALIZ,NIL},;
						{"D3_QUANT"		,SD3->D3_QUANT	,NIL},;
						{"D3_HIST"		,SD3->D3_HIST	,NIL},;
						{"D3_EMISSAO"	,SD3->D3_EMISSAO,NIL}}
			_cVoltaMSE := MSExecAuto({|x,y| mata240(x,y)},aItens,5) // 3-Inclusão 5-Estorno
		ElseIf SD3->D3_CF $ "RE4/DE4"  // Transferência
			_D3_NUMSEQ := SD3->D3_NUMSEQ
			//Dados da origem
			_cPrdO := " "
			_cLocO := " "
			_cLczO := " "
			_nQtdO := 0
			// Dados do destino
			_cPrdD := " "
			_cLocD := " "
			_cLczD := " "
			_nQtdD := 0
	
			DbSelectArea("SDB")
			DbSetOrder(1) // DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM
	
			DbSelectArea("SD3")
			DbSetOrder(4) // D3_FILIAL+D3_NUMSEQ+D3_CHAVE+D3_COD
			DbSeek(xFilial("SD3")+_D3_NUMSEQ,.F.)
			Do While SD3->D3_FILIAL == xFilial("SD3") .And. SD3->D3_NUMSEQ == _D3_NUMSEQ .And. SD3->(!Eof())
				If SD3->D3_CF == "RE4" // Origem
					_cPrdO := SD3->D3_COD
					_cLocO := SD3->D3_LOCAL
					_cLczO := SD3->D3_LOCALIZ
				ElseIf SD3->D3_CF == "DE4" // Destino
					_cPrdD := SD3->D3_COD
					_cLocD := SD3->D3_LOCAL
					_cLczD := SD3->D3_LOCALIZ
				EndIf
				If Empty(SD3->D3_LOCALIZ)
					// Verifica se não tem movimento no SDB
					DbSelectArea("SDB")
					DbSetOrder(1) // DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM
					DbSeek(xFilial("SDB")+SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ+D3_DOC),.F.) // SD3 não tem DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM
					Do While SDB->DB_FILIAL == xFilial("SDB") .And. SDB->(!Eof()) .And.;
							 SDB->(DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC) == SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ+D3_DOC)
						If SDB->DB_SERVIC == SD3->D3_TM .And. SDB->DB_ORIGEM == "SD3"
							If SD3->D3_CF == "RE4" // Origem
								_cLczO := SD3->D3_LOCALIZ
								Exit
							ElseIf SD3->D3_CF == "DE4" // Destino
								_cLczD := SD3->D3_LOCALIZ
								Exit
							EndIf
						EndIf
						SDB->(DbSkip())
					EndDo
				EndIf
				SD3->(DbSkip())
			EndDo
			// Volta para o SD3 inicial
			DbSelectArea("SD3")
			DbSetOrder(4) // D3_FILIAL+D3_NUMSEQ+D3_CHAVE+D3_COD
			DbSeek(xFilial("SD3")+_D3_NUMSEQ,.F.)
	
			aItens		:= 	{}
			aAdd(aItens,{SD3->D3_DOC,SD3->D3_EMISSAO})
	
			aAdd(aItens,{_cPrdO,;								//cProduto,;
						Posicione("SB1",1,xFilial("SB1")+_cPrdO,"B1_DESC"),;//cDescProd,;
						Posicione("SB1",1,xFilial("SB1")+_cPrdO,"B1_UM"),; 	//cUM Origem
						_cLocO,;											//cArmOri Origem
						_cLczO,;											//cEndOri Origem
						_cPrdD,;											//cProduto,;
						Posicione("SB1",1,xFilial("SB1")+_cPrdD,"B1_DESC"),;//cDescProd,;
						Posicione("SB1",1,xFilial("SB1")+_cPrdD,"B1_UM"),; 	//cUM Origem
						_cLocD,;											//cArmDest Destino
						_cLczD,;											//cEndDest Destino,;
						"",;												//cNumSer Num Serie
						"",;												//cLote
						"",;												//SubLote
						StoD(""),;											//cValidade
						0,;													//nPoten
						SD3->D3_QUANT,;										//nQuant
						0,;													//cQtSegUm
						"",;												//Estornado
						"",;			   									//cNumSeq
						"",; 												//cLoteDest
						StoD(""),;											//cValDest
						""})												//ItemGrade
			_cVoltaMSE := MSExecAuto({|x,y| mata261(x,y)},aItens,5) // 3-Inclusão 5-Estorno
		ElseIf SD3->D3_CF $ "PR0"  // Produção
			// Verificar se o produto tiver controle de localização, primeiro fazer os estornos
			// das distribuições.
			DbSelectArea("SC2")
			DbSetOrder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
			DbSeek(xFilial("SC2")+SD3->D3_OP,.F.)
	
			_nPosSD3 := SD3->(Recno())
	
			DbSelectArea("SDA")
			DbSetOrder(1) // DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
			If DbSeek(xFilial("SDA") + SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ+D3_DOC), .F.)
	
				DbSelectArea("SDB")
				DbSetOrder(1) // DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM
				DbSeek(xFilial("SDB") + SDA->(DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA),.F.)
	
				Do While 	SDB->DB_FILIAL == xFilial("SDB") .And. SDB->(!Eof()) .And. ;
							SDB->(DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA) == ;
							SDA->(DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA)
					If Empty(SDB->DB_ESTORNO)
						aCab  := {	{"DA_PRODUTO"	,SDA->DA_PRODUTO			, nil},;
									{"DA_NUMSEQ"	,SDA->DA_NUMSEQ				, nil}}
	
						aItens:={ { {"DB_ITEM"	  	, "0001"					, nil},;
									{"DB_ESTORNO" 	, "S"						, nil},;
									{"DB_LOCALIZ" 	, "PROD_PCF"				, nil},;
									{"DB_QUANT"   	, SDA->DA_QTDORI			, nil},;
									{"DB_DATA"    	, SDA->DA_DATA				, nil}}}
									lMsErroAuto := .F.
									//Executa o endereçamento do item
									MATA265( aCAB, aItens, 4)
						If lMsErroAuto
							Exit
						EndIf
	
						SD3->(DBgOtO(_nPosSD3))
	
						DbSelectArea("SDA")
						DbSetOrder(1) // DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
						DbSeek(xFilial("SDA") + SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ+D3_DOC), .F.)
	
						DbSelectArea("SDB")
						DbSetOrder(1) // DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM
						DbSeek(xFilial("SDB") + SDA->(DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA),.F.)
					Else
						SDB->(DbSkip())
					EndIf
				EndDo
				SD3->(DBgOtO(_nPosSD3))
			EndIf
	
			If !lMsErroAuto
				_cNumOP := SD3->D3_OP
				aItens:={	{"D3_TM"      , SD3->D3_TM                  ,NIL},;
							{"D3_COD"     , SD3->D3_COD                 ,NIL},;
							{"D3_DOC"     , SD3->D3_DOC                 ,NIL},;
							{"D3_UM"      , SD3->D3_UM                  ,NIL},;
							{"D3_LOCAL"   , SD3->D3_LOCAL               ,NIL},;
							{"D3_QUANT"   , SD3->D3_QUANT               ,NIL},;
							{"D3_HIST"    , SD3->D3_HIST                ,NIL},;
							{"D3_OP"      , SD3->D3_OP                  ,NIL},;
							{"D3_CONTA"   , SD3->D3_CONTA               ,NIL},;
							{"D3_EMISSAO" , SD3->D3_EMISSAO             ,NIL},;
							{"D3_PARCTOT" , SD3->D3_PARCTOT             ,NIL},;
							{"D3_TEMPES"  , SD3->D3_TEMPES              ,NIL}}
				MSExecAuto({|x,y| Mata250(x,y)},aItens,5)
			EndIf
			If !lMsErroAuto
				// Verificar se a OP foi criada por esta rotina
				DbSelectArea("SC2")
				DbSetOrder(1) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
				If DbSeek(xFilial("SC2") + _cNumOP,.F.)
					If "PROD_PCP" $ SC2->C2_OBS // OP criada para esta finalidade
						u_NovaOP("E",.T.,CtoD("")," ")  // Parâmetros: I=Incluir / E Excluir OP // .T.= Criar /.F. = Não criar OPs intermediárias
					EndIf
				EndIf
				lMsErroAuto := .F. // garanto que volte .F., pois não sei se a função NovaOP altera essa variável
			EndIf
		EndIf
		If lMsErroAuto
			MOSTRAERRO()
		EndIf
	EndIf
Return(!lMsErroAuto)


/*/{Protheus.doc} FazMovD3
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined
@param _cTpMov, , descricao
@param _nQtdMov, , descricao
@param _cCC, , descricao
@param _cOP, , descricao
@type function
/*/
Static Function FazMovD3(_cTpMov,_nQtdMov,_cCC,_cOP) //,_dDtEnc)
/*/
Parâmetros:
	_cTpMov -> Tipo do movimento:
		1-Com TM 700 - Consumir contra o centro de custo 300111-FRACIONAMENTO
		2-Transferir para local 03-PCP, Localiz PROD_PCP
		3-Com TM 200 - Devolver consumo contra o centro de custo 300111-FRACIONAMENTO
		4-Transferir do local 03-PCP, Localiz PROD_PCP
		5-Produção
	_nQtdMov - Quantidade do movimento
	_cCC -> Centro de Custo
	_cOP -> Nro completo da OP
	_dDtEnc -> Data do encerramento da OP
/*/
Local _cPrxDoc

Private lMsErroAuto := .F.

Default _cCC := " "
Default _cOP := " "
//Default _dDtEnc := Ctod(" ")

	DbSelectArea("SD3")
	DbSetOrder(2) // D3_FILIAL+D3_DOC+D3_COD
	Do While .T.
		// GetSX8Num(cAlias,cCpoSx8,cAliasSX8,nOrdSX8)
		_cPrxDoc :=	GetSX8Num("SD3","D3_DOC","D3I",2)
		If !SD3->(DbSeek(xFilial("SD3")+_cPrxDoc,.F.))
			Exit
		EndIf
		ConfirmSX8()
	EndDo
	// Reposiciona o SB1
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+cB7_COD,.F.))
	
	If _cTpMov $ "1;3" // Requisição ou devolução para OP ou CC
		_cTM := If(_cTpMov=="1",'700','200')
		_cCC   := PadR(_cCC,TAMSX3("D3_CC")[1])
		_cOP   := PadR(_cOP,TAMSX3("D3_OP")[1])
		_dDtOP := Ctod("  /  /  ")
		_cHistPCP := "PROD_PCP"
		If !Empty(_cOP)
			DbSelectArea("SC2")
			DbSetOrder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
			If DbSeek(xFilial("SC2")+_cOP,.F.)
				_dDtOP := SC2->C2_DATRF
				_cHistPCP := "PROD_PCP  " + Dtoc(If(Empty(_dDtOP),_dDtOP,Max(_dDtOP,_Mv_par01)))
				RecLock("SC2",.F.)
				SC2->C2_DATRF := Ctod("  /  /  ")
				MsUnLock()
			EndIf
		EndIf
		aItens 	:= {{"D3_TM"		,_cTM			,NIL},;
					{"D3_COD"		,cB7_COD		,NIL},;
					{"D3_DOC"		,_cPrxDoc		,NIL},;
					{"D3_UM"		,SB1->B1_UM		,NIL},;
					{"D3_LOCAL"		,cB7_LOCAL		,NIL},;
					{"D3_LOCALIZ"	,cB7_LOCALIZ	,NIL},;
					{"D3_QUANT"		,_nQtdMov		,NIL},;
					{"D3_GRUPO"		,SB1->B1_GRUPO	,NIL},;
					{"D3_DESCRI"	,SB1->B1_DESC	,NIL},;
					{"D3_HIST"		,_cHistPCP		,NIL},;
					{"D3_OP"		,_cOP			,NIL},;
					{"D3_CC"		,_cCC			,NIL},;
					{"D3_EMISSAO"	,_Mv_par01		,NIL}}
		MSExecAuto({|x,y| mata240(x,y)},aItens,3) // 3-Inclusão 5-Estorno
		If !Empty(_cOP) .And. !Empty(_dDtOP) .And. !lMsErroAuto
			DbSelectArea("SC2")
			DbSetOrder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
			If DbSeek(xFilial("SC2")+_cOP,.F.)
				RecLock("SC2",.F.)
				SC2->C2_DATRF := Max(_dDtOP,_Mv_par01)
				MsUnLock()
			EndIf
		EndIf
	ElseIf _cTpMov $ "2;4" // Transferência para/de local 03
		If _cTpMov == "2" // 2-Transferir para local 03-PCP, Localiz PROD_PCP
			_cLocO := PadR(cB7_LOCAL  ,TAMSX3("BE_LOCAL")  [1])
			_cLocD := PadR("03"       ,TAMSX3("BE_LOCAL")  [1])
			_cLczO := PadR(cB7_LOCALIZ,TAMSX3("BE_LOCALIZ")[1])
			_cLczD := PadR("PROD_PCP" ,TAMSX3("BE_LOCALIZ")[1])
		Else // _cTpMov == "4"  // 4-Transferir do local 03-PCP, Localiz PROD_PCP
			_cLocO := PadR("03"       ,TAMSX3("BE_LOCAL")  [1])
			_cLocD := PadR(cB7_LOCAL  ,TAMSX3("BE_LOCAL")  [1])
			_cLczO := PadR("PROD_PCP" ,TAMSX3("BE_LOCALIZ")[1])
			_cLczD := PadR(cB7_LOCALIZ,TAMSX3("BE_LOCALIZ")[1])
		EndIf
		// Verifica se existe o SB2
		DbSelectArea("SB2")
		SB2->(DbSetOrder(1))
		If !SB2->(DbSeek(xFilial("SB2")+cB7_COD+_cLocO,.F.))
			CriaSB2(cB7_COD,_cLocO)
		EndIf
		SB2->(DbSetOrder(1))
		If !SB2->(DbSeek(xFilial("SB2")+cB7_COD+_cLocD,.F.))
			CriaSB2(cB7_COD,_cLocD)
		EndIf
	
		If SB1->B1_LOCALIZ == "S"
			DbSelectArea("SBE")
			DbSetOrder(1)
			For _nVzLcz := 1 To 2
				If !DbSeek(xFilial("SBE") + If(_nVzLcz==1,(_cLocO+_cLczO),(_cLocD+_cLczD)),.F.)
					If If(_nVzLcz==1,_cLocO,_cLocD) == "03"
						_cDesLo := "PROD_PCP"
					Else
						If Left(If(_nVzLcz==1,_cLczO,_cLczD),1) == "T"
							_cDesLo :=  "Retalho de "
						ElseIf Left(If(_nVzLcz==1,_cLczO,_cLczD),1) == "B"
							_cDesLo :=  "Bobina de "
						ElseIf Left(If(_nVzLcz==1,_cLczO,_cLczD),1) == "M"
							_cDesLo :=  "Carretel de Mad.de "
						ElseIf Left(If(_nVzLcz==1,_cLczO,_cLczD),1) == "C"
							_cDesLo :=  "Carretel de "
						ElseIf Left(If(_nVzLcz==1,_cLczO,_cLczD),1) == "R"
							_cDesLo :=  "Rolo de "
						ElseIf Left(If(_nVzLcz==1,_cLczO,_cLczD),1) == "L"
							_cDesLo :=  "Blister de "
						EndIf
						_cDesLo +=  Str(_cLanc,5) + " " + Posicione("SAH",1,xFilial("SAH")+SB1->B1_UM,"AH_DESCPO")
					EndIf
	
					RecLock("SBE",.T.)
					SBE->BE_FILIAL   := xFilial("SBE")
					SBE->BE_LOCAL    := If(_nVzLcz==1,_cLocO,_cLocD)
					SBE->BE_LOCALIZ  := If(_nVzLcz==1,_cLczO,_cLczD)
					SBE->BE_DESCRIC  := _cDesLo
					SBE->BE_PRIOR    := "ZZZ"
					SBE->BE_STATUS   := "1"
					MsUnLock()
				EndIf
			Next
		Else
			_cLczO := PadR(" ",TAMSX3("BE_LOCALIZ")[1])
			_cLczD := PadR(" ",TAMSX3("BE_LOCALIZ")[1])
		EndIf
	
		aItens		:= 	{}
		aAdd(aItens,{_cPrxDoc,_Mv_par01})
	
		aAdd(aItens,{cB7_COD,;		//cProduto,;
					SB1->B1_DESC,;	//cDescProd,;
					SB1->B1_UM,; 	//cUM Origem
					_cLocO,;		//cArmOri Origem
					_cLczO,;		//cEndOri Origem
					cB7_COD,;		//cProduto,;
					SB1->B1_DESC,;	//cDescProd,;
					SB1->B1_UM,; 	//cUM Origem
					_cLocD,;		//cArmDest Destino
					_cLczD,;		//cEndDest Destino,;
					"",;			//cNumSer Num Serie
					"",;			//cLote
					"",;			//SubLote
					StoD(""),;		//cValidade
					0,;				//nPoten
					_nQtdMov,;		//nQuant
					0,;				//cQtSegUm
					"",;			//Estornado
					"",;			//cNumSeq
					"",; 			//cLoteDest
					StoD(""),;		//cValDest
					"",;            //ItemGrade
					""})			//D3_OBSERVA
		MSExecAuto({|x,y| mata261(x,y)},aItens,3) // 3-Inclusão 5-Estorno		
	ElseIf _cTpMov == "5" // Produção
		_cNumOP := _cOP       //_cTpMov,_nQtdMov,_cCC,_cOP
		_cPartTot := "T"
		_dDtOP 	  := Ctod("  /  /  ")
		_cHistPCP := "PROD_PCP - Nova " //?????
		If !_CriouOP // Não é uma OP nova
			_cPartTot := "P"
			_cHistPCP := "PROD_PCP "
			DbSelectArea("SC2")
			DbSetOrder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
			If DbSeek(xFilial("SC2")+_cNumOP,.F.)
				_dDtOP := SC2->C2_DATRF
				_cHistPCP := "PROD_PCP  " + Dtoc(If(Empty(_dDtOP),_dDtOP,Max(_dDtOP,_Mv_par01)))
				RecLock("SC2",.F.)
				SC2->C2_DATRF := Ctod("  /  /  ")
				MsUnLock()
			EndIf
		EndIf
	
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+cB7_COD,.F.))
	
		aItens := {{"D3_TM"     , "006"			,NIL},;
				   {"D3_COD"    , cB7_COD		,NIL},;
				   {"D3_DOC"    , _cPrxDoc		,NIL},;
				   {"D3_UM"     , SB1->B1_UM	,NIL},;
				   {"D3_LOCAL"  , cB7_LOCAL		,NIL},;
				   {"D3_QUANT"  , _nQtdMov		,NIL},;
				   {"D3_DESCRI" , SB1->B1_DESC	,NIL},;
				   {"D3_HIST"   , _cHistPCP		,NIL},;
				   {"D3_OP"     , _cOP			,NIL},;
				   {"D3_EMISSAO", _MV_PAR01		,NIL},;
				   {"D3_PARCTOT", _cPartTot		,NIL},;
				   {"D3_GRUPO"  , SB1->B1_GRUPO	,NIL}}
		lMsErroAuto 	:= .F.
		MSExecAuto({|x,y| Mata250(x,y)},aItens,3)
	
		// Fazer a distribuição do PA
		DbSelectArea("SB1")
		DbSetOrder(1)
		SB1->(DbSeek(xFilial("SB1")+cB7_COD,.F.))
	
		If SB1->B1_LOCALIZ == "S" .And. !lMsErroAuto
			//Realiza a Distribuição
			DbSelectArea("SDA")
			DbSetOrder(1) // DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ
			DbSeek(xFilial("SDA")+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ,.F.)
	
			aCAB  := {	{"DA_PRODUTO" ,SDA->DA_PRODUTO             , nil},;
						{"DA_QTDORI"  ,SDA->DA_QTDORI              , nil},;
						{"DA_SALDO"   ,SDA->DA_SALDO               , nil},;
						{"DA_DATA"    ,SDA->DA_DATA                , nil},;
						{"DA_LOCAL"   ,SDA->DA_LOCAL               , nil},;
						{"DA_DOC"     ,SDA->DA_DOC                 , nil},;
						{"DA_ORIGEM"  ,SDA->DA_ORIGEM              , nil},;
						{"DA_NUMSEQ"  ,SDA->DA_NUMSEQ              , nil},;
						{"DA_QTSEGUM" ,SDA->DA_QTSEGUM             , nil},;
						{"DA_QTDORI2" ,SDA->DA_QTDORI2             , nil}}
	
			aITENS:={ { {"DB_ITEM"	  , "0001"						, nil},;
						{"DB_LOCALIZ" , cB7_LOCALIZ					, nil},;
						{"DB_QUANT"   , SDA->DA_SALDO				, nil},;
						{"DB_DATA"    , SDA->DA_DATA				, nil},;
						{"DB_ESTORNO" , " "							, nil} }}
			lMsErroAuto := .F.
			MsExecAuto({|x,y|mata265(x,y)},aCAB,aITENS)
			If lMsErroAuto
	
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1")+cB7_COD,.F.))
	
				// Estornar o SD3
				DbSelectArea("SD3")
				DbSetOrder(2) // D3_FILIAL+D3_DOC+D3_COD
				If SD3->(!DbSeek(xFilial("SD3")+_cPrxDoc,.F.))
					aItens:={	{"D3_TM"      , SD3->D3_TM                  ,NIL},;
								{"D3_COD"     , SD3->D3_COD                 ,NIL},;
								{"D3_UM"      , SD3->D3_UM                  ,NIL},;
								{"D3_QUANT"   , SD3->D3_QUANT               ,NIL},;
								{"D3_OP"      , SD3->D3_OP                  ,NIL},;
								{"D3_LOCAL"   , SD3->D3_LOCAL               ,NIL},;
								{"D3_DOC"     , SD3->D3_DOC                 ,NIL},;
								{"D3_EMISSAO" , SD3->D3_EMISSAO             ,NIL},;
								{"D3_PARCTOT" , SD3->D3_PARCTOT             ,NIL},;
								{"D3_NUMBTM"  , SD3->D3_NUMBTM              ,NIL},;
								{"D3_ITEBTM"  , Sd3->D3_ITEBTM              ,NIL},;
								{"D3_PERDA"   , SD3->D3_PERDA               ,NIL}}
					MSExecAuto({|x,y| Mata250(x,y)},aItens,5)
				EndIf
				lMsErroAuto := .T. // Mantenho a variável
			EndIf
	    EndIf
	
		If lMsErroAuto .And. _CriouOP // É OP nova
			// Excluir a OP criada agora
			DbSelectArea("SC2")
			DbSetOrder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
			If DbSeek(xFilial("SC2")+_cNumOP,.F.)
				u_NovaOP("E",.T.,CtoD("")," ")  // Parâmetros: I=Incluir / E Excluir OP // .T.= Criar /.F. = Não criar OPs intermediárias
			EndIf
		ElseIf !lMsErroAuto .And. !_CriouOP // Não é uma OP nova
			DbSelectArea("SC2")
			DbSetOrder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
			If DbSeek(xFilial("SC2")+_cNumOP,.F.)
				RecLock("SC2",.F.)
				SC2->C2_DATRF := _dDtOP
				MsUnLock()
			EndIf
		EndIf
	EndIf
	
	If lMsErroAuto // Deu Erro
		//MOSTRAERRO()
		RollBackSx8()
	Else
		ConfirmSx8()
		// Reposiciona o SD3 e pega o NUMSEQ
		DbSelectArea("SD3")
		DbSetOrder(2) // D3_FILIAL+D3_DOC+D3_COD
		If DbSeek(xFilial("SD3")+_cPrxDoc+cB7_COD,.F.)
			_cNmSqNow := SD3->D3_NUMSEQ
		EndIf
		DbSeek(xFilial("SD3")+_cPrxDoc,.F.)
		Do While SD3->D3_FILIAL == xFilial("SD3") .And. SD3->D3_DOC == _cPrxDoc .And. SD3->(!Eof())
			If SD3->D3_NUMSEQ == _cNmSqNow .And. Empty(SD3->D3_HIST)
				RecLock("SD3",.F.)
				SD3->D3_HIST := "PROD_PCP"
				MsUnLock()
			EndIf
			SD3->(DbSkip())
		EndDo
	EndIf
	// Os ExecAutos alteram as variáveis MV_PAR??, por isso corrigir o conteúdo de cada um.
	Mv_par01 := _MV_PAR01
	Mv_par02 := _MV_PAR02
	Mv_par03 := _MV_PAR03
	Mv_par04 := _MV_PAR04
	Mv_par05 := _MV_PAR05
	Mv_par06 := _MV_PAR06
	Mv_par07 := _MV_PAR07
Return(!lMsErroAuto)


/*/{Protheus.doc} MySaldo
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
Static Function MySaldo()
// Verifica se não tem SB2 e cria
Local _aEst
	SB2->(DbSetOrder(1))
	If !SB2->(DbSeek(xFilial("SB2")+cB7_COD+cB7_LOCAL,.F.))
		CriaSB2(cB7_COD,cB7_LOCAL)
	EndIf
	If SB2->B2_QTNP > 0
		XX_:=0
	EndIf
	// Reposicionar o SB1 - Em debug ele está em registro errado
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+cB7_COD,.F.))
	
	If SB1->B1_LOCALIZ == "S"
		_aEst := CalcEstL(cB7_COD,cB7_LOCAL,_Mv_par01+1,,,cB7_LOCALIZ,,)
	Else // NÃO TEM CONTROLE DE LOCALIZAÇÃO
		// Vejo o saldo no SB2
		_aEst := CalcEst(cB7_COD,cB7_LOCAL,_Mv_par01+1,,,,,)
		//		_nSaldo := SB2->B2_QATU
	EndIf
Return(_aEst)


/*/{Protheus.doc} MySaldoTer
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
Static Function MySaldoTer()
/*
*
Trecho tirado do arquivo SIGACUSA.PRX
*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ SaldoTerc³ Autor ³ Cristina M. Ogura     ³ Data ³ 31.05.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna o Saldo do Produto no arquivo SB6                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpA1 := SaldoTerc(ExpC1,ExpC2,ExpC3,ExpD4,ExpC4)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Produto                                  ³±±
±±³          ³ ExpC2 = Local do Produto                                   ³±±
±±³          ³ ExpC3 = Tipo de Poder de terceiros (D = De Terceiros,	  ³±±
±±³          ³                                     T = Em Terceiros)	  ³±±
±±³          ³ ExpD4 = Data de fechamento                                 ³±±
±±³          ³ ExpC5 = Local limite do produto                            ³±±
±±³          ³ ExpL6 = Indica se o saldo deve ser calculado por Cli/Forn. ³±±
±±³          ³ ExpC7 = Codigo do Produto ate, utilizado para gerar a      ³±±
±±³          ³         matriz aSaldoProd{}                                ³±±
±±³          ³ ExpL1 = Indica se considera TES de poder de 3os que nao    ³±±
±±³          ³ atualiza estoque                                           ³±±
±±³          ³ ExpL2 = Indica se Custo FIFO                               ³±±
±±³          ³ ExpL3 = Indica se o saldo deve ser calculado por Documento ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Function SaldoTerc(1-cCod,2-cLocal,3-cTipo,4-dDtFech,5-cLocalAte,6-lCliFor,7-cCodAte,8-lConsTesTerc,9-lCusFifo,10-lDocto,11-lTransito)
*/
Local aSaldoMov
	aSaldoMov := SaldoTerc(cB7_COD,cB7_LOCAL,"D",_Mv_par01,,,,,,,)
Return(aSaldoMov)


/*/{Protheus.doc} MyMovto
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
Static Function MyMovto()
Local _nEntrInv := 0 // Entradas pelo inventário
Local _nSairInv := 0 // Saídas pelo  inventário

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+cB7_COD,.F.))
	
	// Somar as quantidades já movimentadas pelo inventário
	DbSelectArea("SD3")
	DbSetOrder(7) // D3_FILIAL+D3_COD+D3_LOCAL+DTOS(D3_EMISSAO)+D3_NUMSEQ
	DbSeek(xFilial("SD3")+cB7_COD+cB7_LOCAL+Dtos(_Mv_par01),.F.)
	Do While SD3->D3_FILIAL == xFilial("SD3") .And. SD3->D3_COD == cB7_COD .And. SD3->D3_LOCAL == cB7_LOCAL .And. ;
	         SD3->D3_EMISSAO == _Mv_par01 .And. SD3->(!Eof())
	
		If Left(SD3->D3_DOC,3) == "INV" .And. Empty(SD3->D3_ESTORNO)
			If SB1->B1_LOCALIZ == "S"
				// Verificar se o acondicionamento no SDB é o mesmo do SB7
				DbSelectArea("SDB")
				DbSetOrder(1) // DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM
				DbSeek(xFilial("SDB")+SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ+D3_DOC),.F.)
				Do While SDB->DB_FILIAL == xFilial("SDB") .And. SDB->(!Eof()) .And.;
				         SDB->(DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC) == SD3->(D3_COD+D3_LOCAL+D3_NUMSEQ+D3_DOC)
					If SDB->DB_LOCALIZ == cB7_LOCALIZ
						If SD3->D3_TM >= '500' .Or. Left(SD3->D3_CF,2) == "RE" // Saídas
							_nSairInv += SDB->DB_QUANT
						ElseIf SD3->D3_TM <= '499' .Or. Left(SD3->D3_CF,2) == "DE" // Entradas
							_nEntrInv += SDB->DB_QUANT
						EndIf
					EndIf
					SDB->(DbSkip())
				EndDo
			Else
				If SD3->D3_TM >= '500' .Or. Left(SD3->D3_CF,2) == "RE" // Saídas
					_nSairInv += SD3->D3_QUANT
				ElseIf SD3->D3_TM <= '499' .Or. Left(SD3->D3_CF,2) == "DE" // Entradas
					_nEntrInv += SD3->D3_QUANT
				EndIf
			EndIf
		EndIf
		SD3->(DbSkip())
	EndDo
Return(_nEntrInv-_nSairInv)
