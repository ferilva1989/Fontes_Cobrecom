#include "rwmake.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} CDFat07
@author legado
@since 21/07/2017
@version 0.0
@type function
@description Função que gera planilha Excel contendo os carregamentos
/*/
User Function CDFat07()
	
	cPerg := "CDFA07"
	ValidPerg()

	If Pergunte(cPerg,.T.)              
	_aCmpTRB := {}                                             
	AAdd(_aCmpTRB,{"SERIE"  , "C", TamSX3("ZF_SERIE"  )[1], 0})
	AAdd(_aCmpTRB,{"NOTA"   , "C", TamSX3("ZF_NOTA"   )[1], 0}) 
	AAdd(_aCmpTRB,{"ROMAN"  , "C", TamSX3("ZF_CDROMA" )[1], 0}) 
	AAdd(_aCmpTRB,{"NOMCLI" , "C", TamSX3("A1_NOME"   )[1], 0}) 
	AAdd(_aCmpTRB,{"MUNCLI" , "C", TamSX3("A1_MUN"    )[1], 0}) 
	AAdd(_aCmpTRB,{"BAICLI" , "C", TamSX3("A1_BAIRRO" )[1], 0}) 
	AAdd(_aCmpTRB,{"ESTCLI" , "C", TamSX3("A1_EST"    )[1], 0})
	AAdd(_aCmpTRB,{"DTEMISS", "D", 8                      , 0}) 
	AAdd(_aCmpTRB,{"DTCARR" , "D", 8                      , 0}) 
	AAdd(_aCmpTRB,{"HORA"   , "C", TamSX3("ZF_HORA"   )[1], 0}) 
	AAdd(_aCmpTRB,{"TRANSP" , "C", TamSX3("ZF_TRANS"  )[1], 0}) 
	AAdd(_aCmpTRB,{"NOMETRP", "C", TamSX3("A4_NOME"   )[1], 0}) 
	AAdd(_aCmpTRB,{"MOTORIS", "C", TamSX3("ZF_MOTOR"  )[1], 0}) 
	AAdd(_aCmpTRB,{"CARREG" , "C", TamSX3("ZF_CARREG" )[1], 0}) 
	AAdd(_aCmpTRB,{"PEDIDOS", "C", TamSX3("ZF_PEDIDOS")[1], 0}) 
	AAdd(_aCmpTRB,{"PESO"   , "N", TamSX3("ZF_PESO"   )[1], 2}) 
	AAdd(_aCmpTRB,{"VALOR"  , "N", TamSX3("ZF_TOTAL"  )[1], 2})
	AAdd(_aCmpTRB,{"PESOCOB", "N", 12                     , 2})
	AAdd(_aCmpTRB,{"PESOPVC", "N", 12                     , 2})

	_cNomArq := CriaTrab(_aCmpTRB, .T.)

	If Select("TRB") > 0Ÿ
	DbSelectArea("TRB")
	DbCloseArea("TRB")
	EndIf
	DbUseArea(.T.,,_cNomArq,"TRB",.T.,.F.)
	DbSelectArea("TRB")           

	Processa({|| ProcCarr()},"Processando Tabela de Notas Fiscais")
	EndIf

Return(.T.)

Static Function ProcCarr()
	local aWSheet := {}, aTable := {}

	Local cAliasCli	:= ""    

	DbSelectArea("SF2")
	//DbSetOrder(7)
	DBOrderNickName("SF2CDROMA")


	DbSelectArea("SA1")
	DbSetOrder(1)

	DbSelectArea("SA2")
	DbSetOrder(1) //A2_FILIAL, A2_COD, A2_LOJA

	DbSelectArea("SB1")
	DbSetOrder(1)

	DbSelectArea("SZF")
	DbSetOrder(5) // ZF_FILIAL+DTOS(ZF_DATA)+ZF_CDROMA
	ProcRegua(LastRec())
	DbSeek(xFilial("SZF")+DTOS(MV_PAR01),.T.)
	Do While SZF->ZF_FILIAL == xFilial("SZF") .And. SZF->ZF_DATA <= MV_PAR02 .And. SZF->(!Eof())
		IncProc()
		SA4->(DbSeek(xFilial("SA4") + SZF->ZF_TRANS,.F.))
		SF2->(DbSeek(xFilial("SF2") + SZF->ZF_CDROMA,.F.))

		If SF2->F2_TIPO $ "DB"
			SA2->(DbSeek(xFilial("SA2") + SF2->F2_CLIENTE + SF2->F2_LOJA,.F.))		
			cAliasCli := 'SA2->A2_'
		Else
			SA1->(DbSeek(xFilial("SA1") + SF2->F2_CLIENTE + SF2->F2_LOJA,.F.))
			cAliasCli := 'SA1->A1_'
		EndIf

		_nValRom := u_BuscaPv() // Retorna: {1-Pedidos da nota, 2-Peso Padrão, 3-Vlr.Mercadoria, 4-Peso Cobre, 5-Peso PVC}

		RecLock("TRB",.T.)
		TRB->SERIE   :=	SZF->ZF_SERIE
		TRB->NOTA    :=	SZF->ZF_NOTA
		TRB->ROMAN   :=	SZF->ZF_CDROMA

		TRB->NOMCLI  := &(cAliasCli + 'NOME')
		TRB->MUNCLI  := &(cAliasCli + 'MUN')
		TRB->BAICLI  := &(cAliasCli + 'BAIRRO')
		TRB->ESTCLI  := &(cAliasCli + 'EST')

		TRB->DTEMISS := SF2->F2_EMISSAO
		TRB->DTCARR  :=	SZF->ZF_DATA
		TRB->HORA    :=	SZF->ZF_HORA
		TRB->TRANSP  :=	SZF->ZF_TRANS        
		TRB->NOMETRP := SA4->A4_NOME
		TRB->MOTORIS :=	SZF->ZF_MOTOR
		TRB->CARREG  :=	SZF->ZF_CARREG
		TRB->PEDIDOS :=	SZF->ZF_PEDIDOS
		TRB->PESO    :=	SZF->ZF_PESO
		TRB->VALOR   :=	SZF->ZF_TOTAL

		TRB->PESOCOB := _nValRom[4]
		TRB->PESOPVC := _nValRom[5]

		MsUnLock()

		DbSelectArea("SZF")
		DbSkip()
	EndDo

	If File("RESULT.DTC")
		FErase("RESULT.DTC")
	Endif

	DbSelectArea("TRB")
	TRB->(DbGoTop())
	aTrbArea := TRB->(GetArea())
	aColuna := u_RetTRBCol(aTrbArea)
	aDados 	:= u_RetTRBReg(aTrbArea)
	aadd(aWSheet,{"Carregamentos"})
	aadd(aTable,{"Carregamentos"})
	u_TExcArr(aDados,aColuna,aWSheet,aTable)
	TRB->(DbCloseArea())
Return(.T.)

/////////////////////////
Static Function ValidPerg
	/////////////////////////

	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Da Data                      ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até a Data                   ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})

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
		EndIf
	Next

	RestArea(_aArea)

Return(.T.)
