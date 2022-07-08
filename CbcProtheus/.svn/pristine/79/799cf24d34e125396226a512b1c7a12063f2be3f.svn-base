#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CDESTR19  º Autor ³ AP6 IDE            º Data ³  15/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CDESTR19()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo       := "Controle de Entregas de Pedidos de Venda"
	Local nLin         := 80

	Local Cabec1       := "Pedido Cliente   Nome do Cliente                          Dt.P.v.     Prev.Ent    Dt.Liber    Dt.Entr.     Atraso"
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 132
	Private tamanho          := "M"
	Private nomeprog         := "CDESTR19" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "CDESTR19" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cPerg        := "CDE019"

	Private cString := "SC5"

	dbSelectArea("SC5")
	dbSetOrder(1)

	ValidPerg()
	pergunte(cPerg,.F.)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)                                         

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  15/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	*

	_nAte00 := 0
	_nAte05 := 0
	_nAte10 := 0
	_nAte15 := 0
	_nAte20 := 0
	_nAte30 := 0
	_nPos30 := 0

	DbSelectArea("SF2")
	DbSetOrder(1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL

	DbSelectArea("SA1")
	DbSetOrder(1) 

	DbSelectArea("SC5")
	DbSetOrder(1)  //C5_FILIAL+C5_NUM
	SetRegua(RecCount())
	DbSeek(xFilial("SC5")+Mv_Par01,.T.)
	Do While SC5->C5_FILIAL == xFilial("SC5") .And. SC5->C5_NUM <= Mv_Par02 .And. SC5->(!Eof())
		IncRegua()	
		If lAbortPrint
			@ nLin,000 PSay "*** CANCELADO PELO OPERADOR ***"
			Exit
		EndIf
		// se tiver eliminado residuo??
		If SC5->C5_CLIENTE < Mv_Par03 .Or. SC5->C5_CLIENTE > Mv_Par05 .Or. SC5->C5_TIPO # "N" .Or. ;
		SC5->C5_LOJACLI < Mv_Par04 .Or. SC5->C5_LOJACLI > Mv_Par06 .Or. SC5->C5_LIBEROK == "E" .Or. Empty(SC5->C5_NOTA)
			DbSelectArea("SC5")
			DbSkip()
			Loop
		EndIf   

		SF2->(DbSeek(xFilial("SF2") + SC5->C5_NOTA + SC5->C5_SERIE,.F.))
		If SF2->F2_EMISSAO < MV_PAR07 .Or. SF2->F2_EMISSAO > MV_PAR08 .Or. SF2->(Eof())
			DbSelectArea("SC5")
			DbSkip()
			Loop
		EndIf   
		If nLin > 60 
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin++                                       
		Endif
		SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
		@ nLin,000 PSay SC5->C5_NUM
		@ nLin,007 PSay SC6->C6_CLI+"-"+SC6->C6_LOJA
		@ nLin,017 PSay Left(SA1->A1_NOME,40)
		@ nLin,058 PSay SC5->C5_EMISSAO
		@ nLin,070 PSay SC5->C5_ENTREG
		@ nLin,082 PSay SC5->C5_DTLICRE
		@ nLin,094 PSay SF2->F2_EMISSAO
		_nDiasAtr := Max(0,SF2->F2_EMISSAO - Max(SC5->C5_DTLICRE,SC5->C5_ENTREG))
		@ nLin,107 PSay _nDiasAtr Picture "@E 9999,999"
		If _nDiasAtr > 30
			_nPos30++
		ElseIf _nDiasAtr > 20
			_nAte30++
		ElseIf _nDiasAtr > 15
			_nAte20++
		ElseIf _nDiasAtr > 10
			_nAte15++
		ElseIf _nDiasAtr > 05
			_nAte10++
		ElseIf _nDiasAtr > 0
			_nAte05++
		Else
			_nAte00++
		EndIf
		nLin := nLin + 1 // Avanca a linha de impressao
		SC5->(DbSkip())
	EndDo
	_nTotPv := (_nAte00 + _nAte05 + _nAte10 + _nAte15 + _nAte20 + _nAte30 + _nPos30)
	If _nTotPv > 0.00
		@ nLin,000 PSay "Resumo:"
		nLin := nLin + 1 // Avanca a linha de impressao
		@ nLin,000 PSay "No Prazo:"
		@ nLin,013 PSay _nAte00 Picture "@E 9,999"
		@ nLin,019 PSay (_nAte00/_nTotPv) * 100 Picture "@E 99.9"
		@ nLin,023 PSay "%"
		@ nLin,027 PSay "Até 05 dias:"
		@ nLin,040 PSay _nAte05 Picture "@E 9,999"
		@ nLin,046 PSay (_nAte05/_nTotPv) * 100 Picture "@E 99.9"
		@ nLin,050 PSay "%"
		@ nLin,055 PSay "Até 10 dias:"
		@ nLin,073 PSay  _nAte10 Picture "@E 9,999"
		@ nLin,079 PSay (_nAte10/_nTotPv) * 100 Picture "@E 99.9"
		@ nLin,083 PSay "%"
		@ nLin,089 PSay "Até 15 dias:"
		@ nLin,102 PSay  _nAte15 Picture "@E 9,999"
		@ nLin,108 PSay (_nAte15/_nTotPv) * 100 Picture "@E 99.9"
		@ nLin,112 PSay "%"                                      

		nLin := nLin + 1 // Avanca a linha de impressao

		@ nLin,000 PSay "Até 20 dias:"
		@ nLin,013 PSay _nAte20 Picture "@E 9,999"
		@ nLin,019 PSay (_nAte20/_nTotPv) * 100 Picture "@E 99.9"
		@ nLin,023 PSay "%"                                    
		@ nLin,027 PSay "Até 30 dias:"
		@ nLin,040 PSay _nAte30 Picture "@E 9,999"
		@ nLin,046 PSay (_nAte30/_nTotPv) * 100 Picture "@E 99.9"
		@ nLin,050 PSay "%"
		@ nLin,055 PSay "Acima de 30 dias:"
		@ nLin,073 PSay  _nPos30 Picture "@E 9,999"
		@ nLin,079 PSay (_nPos30/_nTotPv) * 100 Picture "@E 99.9"
		@ nLin,083 PSay "%"
		@ nLin,089 PSay "Total:"
		@ nLin,101 PSay  _nTotPv Picture "@E 99,999"
	EndIf

	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

/////////////////////////
Static Function ValidPerg
	/////////////////////////

	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Do Pedido Venda              ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SC5"})
	aAdd(aRegs,{cPerg,"02","Até Pedido Venda             ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","SC5"})
	aAdd(aRegs,{cPerg,"03","Do Cliente                   ?","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"04","Da Loja                      ?","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Até Cliente                  ?","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"06","Até Loja                     ?","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Da Data                      ?","mv_ch7","D",08,0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Até Data                     ?","mv_ch8","D",08,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
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
/*/



Pedido Cliente   Nome do Cliente                          Dt.P.v.     Prev.Ent    Dt.Liber    Dt.Entr.     Atraso
XXXXXX 999999-99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99/99/99    99/99/99    99/99/99    99/99/99    9999,999
0               16                                       57      65        75        85        95       104       114       124        135       145         157           171          184       194       204      213
/*/