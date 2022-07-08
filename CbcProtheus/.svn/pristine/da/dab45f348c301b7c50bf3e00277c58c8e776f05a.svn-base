#include "rwmake.ch"
#include "TOPCONN.ch"
#include "TOTVS.ch"

//////////////////////////////////////////////////////////////////////////////
//
//   Programa ...: CDFAT01                            Modulo : SIGAFAT
//
//   Autor ......: Jaime Ranulfo                      Data ..: 11/07/2005
//
//   Objetivo ...: Função para Importação de Tabelas de Preços a partir de
//
//                 arquivo texto gerado por Planilha Excel
//
//   Uso ........: Especifico da Condusul
//
//////////////////////////////////////////////////////////////////////////////

User Function CDFAT01()

	Private cPerg := "CDFT02"
	ValidPerg()
	Do While .T.
		If !Pergunte(cPerg,.T.)
			Exit
		EndIf
		If Empty(MV_PAR01)
			Alert("Informar o Nome do Arquivo")
			Loop
		EndIf
		_cArq := "\CONDUSUL\"+AllTrim(MV_PAR01)
		If !File(_cArq)
			Alert("O Arquivo " + MV_PAR01 + " tem que estar na Pasta CONDUSUL")
			Loop
		EndIf
		If MV_PAR05 == 1  // Tabela
			If "VANIA" $ Upper(cUserName)
				Alert("Vânia, Você só Pode Atualizar Custos")
				Loop
			EndIf
		ElseIf MV_PAR05 == 2  // Custo
			If !"ADMINISTRADOR" $ Upper(cUserName) .And. !"ROBERTO" $ Upper(cUserName) .And. !"VANIA" $ Upper(cUserName)
				Alert("Transferência de Custo Somente Vânia Pode Realizar - Escolha Tabela")
				Loop
			EndIf
		Else
			Alert("Opção Inválida")
			Loop
		EndIf
		If MsgBox("Confirma a configuração dos parâmetros?","Confirma?","YesNo")
			Processa({|| Importa()})
			Exit
		EndIf
		Exit
	EndDo
Return(.T.)

Static Function Importa(aDt)
	local aStru 		:= {}
	local nCont			:= 1
	local cArq			:= "", cOrigem := ""
	private lCbcRg		:= .F.
	private aDados		:= {}
	Private _cTabela	:= MV_PAR04
	Private _cProduto	:= Space(15)
	Private _nCusSTD	:= 0
	Private _nPrcVen	:= 0
	Private _cItem		:= StrZero(0,Len(DA1->DA1_ITEM))
	Default aDt			:= {}

	if empty(aDt)
		cArq 	:= AllTrim(MV_PAR01)
		cOrigem	:= "\CONDUSUL\"
		Processa( {|| aDados:= U_CargaXLS(cArq,cOrigem,,.F.)},"Aguarde, carregando planilha...Pode demorar")
	else
		aDados := AClone(aDt)
		lCbcRg := .T.
	endif
	if MV_PAR05 == 1  // Tabela
		DbSelectArea("DA0")
		DbSetOrder(1)  //DA0_FILIAL+DA0_CODTAB
		if !DbSeek(xFilial("DA0")+_cTabela,.F.)
			RecLock("DA0",.T.)
			DA0->DA0_FILIAL := xFilial("DA0")
			DA0->DA0_CODTAB := _cTabela
			DA0->DA0_DESCRI := "TABELA "+_cTabela
			DA0->DA0_DATDE  := dDataBase
			DA0->DA0_HORADE := "00:00"
			DA0->DA0_HORATE := "23:59"
			DA0->DA0_TPHORA := "1"
			DA0->DA0_ATIVO  := "1"
			MsUnLock()
		endif
		DbSelectArea("DA1")
		DbSetOrder(3)//Ordem 3 - DA1_FILIAL+DA1_CODTAB+DA1_ITEM
		DbSeek(xFilial("DA1")+Soma1(_cTabela),.T.)
		DbSkip(-1)
		If DA1->DA1_FILIAL == xFilial("DA1") .And. DA1->DA1_CODTAB == _cTabela
			_cItem := DA1->DA1_ITEM
		endif
		DbSetOrder(1)  //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
	endif
	DbSelectArea("SB1")
	DbSetOrder(1)  //B1_FILIAL+B1_COD
	if len (aDados) > 1
		if aDados[1][1] $ "TABPR1"
			nCont += 1
		endif
		Do While nCont <= len(aDados)
			IncProc()
			if !empty(aDados[nCont][3]) 
				_cProduto := aDados[nCont][3]       //Código do Produto "10105XX101"
				if lCbcRg
					_nCusSTD  := aDados[nCont][6]/100
					_nCusST2  := aDados[nCont][5]/100
					_nCusST3L := aDados[nCont][4]/100
					_nPrcVen  := aDados[nCont][7]/100
				else
					_nCusSTD  := Val(StrTran(StrTran(aDados[nCont][6],".",""),",","."))/100 //Custo Standard do Arquivo Texto
					_nCusST2  := Val(StrTran(StrTran(aDados[nCont][5],".",""),",","."))/100	//Custo 2 Arquivo Texto
					_nCusST3L := Val(StrTran(StrTran(aDados[nCont][4],".",""),",","."))/100	//Custo 2 Arquivo Texto
					_nPrcVen  := Val(StrTran(StrTran(aDados[nCont][7],".",""),",","."))/100 //Preço de Venda do Arquivo Texto
				endif
				_TamProd := If("XX"$_cProduto,5,Len(SB1->B1_COD))
		
				DbSelectArea("SB1")
				DbSeek(xFilial("SB1")+Subst(_cProduto,1,_TamProd),.F.)
				do while SB1->(!Eof()) .And. xFilial("SB1")+Subs(_cProduto,1,_TamProd) == SB1->B1_FILIAL+Subs(SB1->B1_COD,1,_TamProd)
					if SB1->B1_COD < Mv_Par02 .Or. SB1->B1_COD > Mv_Par03 .Or. Subs(SB1->B1_COD,8,8) <> Subst(_cProduto,8,8)
						DbSelectArea("SB1")
						DbSkip()
						Loop
					endif
					if MV_PAR05 == 1  // Tabela
						DbSelectArea("DA1")
						DbSetOrder(1)  //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
						if !DbSeek(xFilial("DA1")+_cTabela+SB1->B1_COD,.F.)
							_cItem := Soma1(_cItem)
							RecLock("DA1",.T.)
							DA1->DA1_FILIAL := xFilial("DA1")
							DA1->DA1_ITEM   := _cItem
							DA1->DA1_CODTAB := _cTabela
							DA1->DA1_CODPRO := SB1->B1_COD
						else
							RecLock("DA1",.F.)
						endif
						DA1->DA1_PRCVEN := _nPrcVen
						DA1->DA1_QTDLOT := 999999.99
						DA1->DA1_INDLOT := StrZero(DA1->DA1_QTDLOT,Len(DA1->DA1_INDLOT),2)
						DA1->DA1_MOEDA  := 1
						DA1->DA1_TPOPER := "4"
						MsUnLock()
						
						DbSelectArea("SB1")
						RecLock("SB1",.F.)
						SB1->B1_PRV1   := _nPrcVen
						SB1->B1_CUSTD  := _nCusSTD
						SB1->B1_CUSTD2 := _nCusST2
						SB1->B1_CUSTD3L:= _nCusST3L
						if lCbcRg
							SB1->B1_VALCOB := aDados[nCont][14]
							SB1->B1_VALPVC := aDados[nCont][13]
						else
							SB1->B1_LINHA  := aDados[nCont][12] 
							SB1->B1_VALCOB := Val(StrTran(StrTran(aDados[nCont][14],".",""),",","."))
							SB1->B1_VALPVC := Val(StrTran(StrTran(aDados[nCont][13],".",""),",","."))
						endif
						MsUnLock()
					else
						DbSelectArea("SB1")
						RecLock("SB1",.F.)
						SB1->B1_CSTINVI := _nCusSTD
						SB1->B1_CSTINV3 := _nCusST3L
						MsUnLock()
					endif
					_NewCod := Left("Q"+SB1->B1_COD,Len(SB1->B1_COD))
					SB1->(Dbskip()) // Pula para o próximo registro
					_nRegB1 := SB1->(Recno()) // Guarda o nro desse registro para posterior reposicionamento
		
					if DbSeek(xFilial("SB1")+_NewCod,.F.)
						// Faz a mesma atualização para os Quase acabados
						if MV_PAR05 == 1  // Tabela
							RecLock("SB1",.F.)
							SB1->B1_PRV1   := _nPrcVen
							SB1->B1_CUSTD  := _nCusSTD
							SB1->B1_CUSTD2 := _nCusST2
							SB1->B1_CUSTD3L:= _nCusST3L
							if lCbcRg
								SB1->B1_VALCOB := aDados[nCont][14]
								SB1->B1_VALPVC := aDados[nCont][13]
							else			
								SB1->B1_LINHA  := aDados[nCont][12]  // Falei com Alex 31/07/14 as 17:08 e concordou que a atualização dos
								SB1->B1_VALCOB := Val(StrTran(StrTran(aDados[nCont][14],".",""),",",".")) // pesos serão realizados pela tabela do Valter Sanavio.
								SB1->B1_VALPVC := Val(StrTran(StrTran(aDados[nCont][13],".",""),",","."))
							endif
							MsUnLock()
						else
							DbSelectArea("SB1")
							RecLock("SB1",.F.)
							SB1->B1_CSTINVI := _nCusSTD
							SB1->B1_CSTINV3 := _nCusST3L
							MsUnLock()
						endif
					endif
					SB1->(DbGoTo(_nRegB1))
				enddo
			endif
			nCont += 1
		enddo

		If MV_PAR05 == 1  // Tabela
			U_RELIMP()  //Relação dos Produtos Atualizados
		EndIf
	endif
	aDados := {}
Return(.T.)


Static Function ValidPerg
	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	aAdd(aRegs,{cPerg,"01","Arquivo a ser importado      ?","mv_ch1","C",40,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Do Produto                   ?","mv_ch2","C",15,0,0,"G","","mv_par02","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"03","Até o Produto                ?","mv_ch3","C",15,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"04","Tabela                       ?","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","DA0"})
	aAdd(aRegs,{cPerg,"05","Tabela / Custo               ?","mv_ch5","N",01,0,0,"C","","mv_par05","Tabela","","","","","Custo","","","","","","","","",""})

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

User Function RELIMP
	Local cArq,cInd
	Local cString        := "DA1"
	Local cDesc1         := "Este programa tem como objetivo imprimir relação "
	Local cDesc2         := "dos produtos com custo e preço atualizados pela "
	Local cDesc3         := "Importação de Planilha Excel"
	Local cPict          := ""
	Local titulo         := "Relação de Produtos Atualizados"
	Local nLin           := 80
	Local Cabec1         := "Produto                                        Tab              C  U  S  T  O                 P  R  E  Ç  O    "
	Local Cabec2         := "                                                    "
	Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "RELIMP"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "RELIMP"

	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	endif
	nTipo := If(aReturn[4]==1,15,18)
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Private _nCont := 0, nCont1 := 1

	Do While nCont1 <= len(aDados)
		If lAbortPrint
			@ nLin,000 PSay "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		If nLin > 60
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 7
		Endif
		@ nLin,000 PSay aDados[nCont1][3]  //10105XX101
		@ nLin,016 PSay Left(Posicione("SB1",1,xFilial("SB1")+aDados[nCont1][3],"B1_DESC"),30)
		@ nLin,047 PSay Strzero(Val(aDados[nCont1][1]),3)
		if lCbcRg
			@ nLin,066 PSay aDados[nCont1][6]  Picture "@E 999,999,999.99"
			@ nLin,096 PSay aDados[nCont1][7]  Picture "@E 999,999,999.99"		
		else
			@ nLin,066 PSay Val(StrTran(StrTran(aDados[nCont1][6],".",""),",","."))  Picture "@E 999,999,999.99"
			@ nLin,096 PSay Val(StrTran(StrTran(aDados[nCont1][7],".",""),",","."))  Picture "@E 999,999,999.99"
		endif
		_nCont++
		nLin++
		nCont1++
	EndDo

	@ nLin,000 PSay "Total de Produtos Atualizados: "+Str(_nCont,10)

	Roda(0,"","M")

	@ 0,0 Psay Chr(27) + "@"
	SET DEVICE TO SCREEN
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
Return(.T.)


User Function AtuPed()

	DbSelectArea("SB1")
	DbSetOrder(1)

	DbSelectArea("SC5")
	DbSetOrder(1)

	DbSelectArea("SC6")
	DbSetOrder(1)

	_cQuery := " FROM SC6010 C6,SB1010 B1  " +;
		" WHERE C6.D_E_L_E_T_ <> '*' AND C6.C6_QTDENT = 0 AND C6.C6_BLQ <> 'R ' AND " +;
		" B1.D_E_L_E_T_ <> '*' AND B1.B1_TIPO = 'PA' AND " +;
		" C6.C6_PRODUTO = B1.B1_COD "
	_TcQry := "SELECT Count(C6.C6_FILIAL) as QTDREG " + _cQuery

	TCQUERY _TcQry NEW ALIAS "RSC6"
	DbSelectArea("RSC6")
	DbGoTop()
	_nTotReg := RSC6->QTDREG
	DbCloseArea()

	_TcQry := "SELECT C6.C6_FILIAL,C6.C6_NUM " + _cQuery + " ORDER BY C6.C6_FILIAL,C6.C6_NUM "

	TCQUERY _TcQry NEW ALIAS "RSC6"
	DbSelectArea("RSC6")
	DbGoTop()

	ProcRegua(_nTotReg)
	Do While RSC6->(!Eof())

		_cFil   := RSC6->C6_FILIAL
		_NumPed := RSC6->C6_NUM

		Do While RSC6->C6_FILIAL == _cFil .And. RSC6->C6_NUM == _NumPed .And. RSC6->(!Eof())
			IncProc()
			RSC6->(DbSkip())
		EndDo

		SC5->(DbSeek(_cFil+_NumPed,.F.))
		If SC5->C5_TIPO # "N"
			Loop
		EndIf

		_nTPrcVen := 0.00
		_nTCustd  := 0.00
		SC6->(DbSeek(_cFil+_NumPed,.F.))

		Do While SC6->C6_FILIAL == _cFil .And. SC6->(!Eof()) .And. SC6->C6_NUM == _NumPed
			IncProc()
			If SC5->C5_TIPO # "N"
				SC6->(DbSkip())
				Loop
			EndIf
			SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.))
			If SB1->B1_TIPO # "PA"
				SC6->(DbSkip())
				Loop
			EndIf
			If SC6->C6_QTDENT == 0.00 .And. SC6->C6_BLQ <> 'R '
				If _cFil == "02" // 3 lagoas
					_nLUCROBR := If(SB1->B1_CUSTD3L==0,0,(((SC6->C6_PRCVEN*100)/SB1->B1_CUSTD3L)-100))
				Else
					_nLUCROBR := If(SB1->B1_CUSTD==0,0,(((SC6->C6_PRCVEN*100)/SB1->B1_CUSTD)-100))
				EndIf
			EndIf
			_nTPrcVen += SC6->C6_PRCVEN
			If _cFil == "02" // 3 lagoas
				_nTCustd  += SB1->B1_CUSTD3L
			Else
				_nTCustd  += SB1->B1_CUSTD
			EndIf
			SC6->(DbSkip())
		EndDo
		If SC5->(DbSeek(_cFil+_NumPed,.F.))
			_nLUCROBR := If(_nTCustd==0,0,((_nTPrcVen * 100) / _nTCustd) - 100)
		EndIf
	EndDo
	DbSelectArea("RSC6")
	DbCloseArea("RSC6")
Return(.T.)


user function zGtCbcRG()
	local oRst 		:= nil
	local oJs  		:= nil
	local cRetJs	:= ''
	local chsId     := ''
	local aDad      := {}
	local nX		:= 0
	oRst := FWRest():New(GetNewPar("ZV_URLCRG", "http://192.168.1.207:3000"))
	oRst:setPath("/calculos?filter={%22where%22:{%22import%22:%22S%22}}")
	if oRst:Get()
		if !empty(cRetJs   := oRst:GetResult())
			Mv_Par02 := Space(TamSx3('B1_COD')[1])
			Mv_Par03 := Replicate('Z', TamSx3('B1_COD')[1])
			MV_PAR05 := 1 //'Tabela'
			MV_PAR04 := '001'
			oJs 	 := JsonObject():New()
			oJs:FromJson(cRetJs)
			if len(oJs) > 0
				chsId := oJs[1]['hashId']
				for nX := 1 to len(oJs)
					aadd(aDad, {'001','',oJs[nX]['codigo'],oJs[nX]['custo'],oJs[nX]['custo'],oJs[nX]['custo'],oJs[nX]['preco'],'','','','','', oJs[nX]['val_pvc'], oJs[nX]['val_cobre']})
				next nX
				Importa(aDad)
			endif
			FreeObj(oJs)
		endif
	else
		MsgShow(oRst:getLastError() + '-'+ oRst:getResult())
	endif
	FreeObj(oRst)
return nil

