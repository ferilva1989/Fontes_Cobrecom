#include "TOPCONN.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "COLORS.CH"
#Include "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณNOVO6     บ Autor ณ AP6 IDE            บ Data ณ  19/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Codigo gerado pelo AP6 IDE.                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function CDESTR24()


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Relatorio de Carregamentos"
	Local cPict          := ""
	Local titulo         := "Relatorio de Carregamentos"
	Local nLin           := 80

	Local Cabec1         := "| Docto.    | Dt.Fatur.| Cliente                     | Dt.Entr. | Transportadora           | Motorista         | Carregador        |"
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd           := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "M"
	Private nomeprog     := "CDESTR24"
	Private nTipo        := 18
	Private aReturn      := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "CDESTR24" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cPerg        := "CDES24"
	Private cString      := "SF2"

	ValidPerg()

	Pergunte(cPerg,.F.)

	dbSelectArea("SF2")
	dbSetOrder(1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  19/04/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescrio ณ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS บฑฑ
ฑฑบ          ณ monta a janela com a regua de processamento.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Programa principal                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem


	DbSelectArea("SA4")
	DbSetOrder(1)   //A4_FILIAL+A4_COD

	DbSelectArea("SA1")
	DbSetOrder(1)   //A1_FILIAL+A1_COD+A1_LOJA

	DbSelectArea("SA2")
	DbSetOrder(1)   //A1_FILIAL+A1_COD+A1_LOJA

	DbSelectArea("SZF")
	DbSetOrder(1)   //ZF_FILIAL+ZF_SERIE+ZF_NOTA+ZF_CDROMA

	#IFDEF TOP

	MV_PAR03 := DTOS(MV_PAR03)
	MV_PAR04 := DTOS(MV_PAR04)

	cQUERY := "SELECT * "
	cQUERY += " FROM "+RetSqlName("SF2")
	cQUERY += " WHERE F2_FILIAL = '"+ xFILIAL("SF2")+ "'"
	cQUERY += " AND D_E_L_E_T_ <> '*'"
	cQUERY += " AND F2_DOC  >= '" + mv_par01 + "'"
	cQUERY += " AND F2_DOC  <= '" + mv_par02 + "'"
	cQUERY += " AND F2_EMISSAO >= '"+ MV_PAR03 +"'"
	cQUERY += " AND F2_EMISSAO <= '"+ MV_PAR04 +"'"

	If mv_par05 == 2 // Somente as entregues
		cQUERY += " AND F2_DTENTR <> '        '"
	ElseIf mv_par05 == 3 // Somente as nao entregues
		cQUERY += " AND F2_DTENTR = '        '"
	EndIf
	cQUERY += " ORDER BY F2_DOC"  

	If Select("RSF2") > 0
		DbSelectArea("RSF2")
		DbCloseArea("RSF2")
	EndIf

	TCQUERY cQuery NEW ALIAS "RSF2"
	cString := "RSF2"
	dbSelectArea("RSF2")
	dbGoTop()
	#ELSE
	dbSelectArea(cString)
	dbSetOrder(1)
	DbSeek(xFilial("SF2")+mv_par01,.T.)
	#ENDIF

	SetRegua(RecCount())

	Do While (cString)->F2_FILIAL == xFilial("SF2") .And. (cString)->F2_DOC <= MV_PAR02 .And. (cString)->(!EOF())

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		IncRegua()

		If (cString)->F2_EMISSAO < MV_PAR03 .Or. (cString)->F2_EMISSAO > MV_PAR04 .Or.;
		(MV_PAR05 == 2 .And. Empty((cString)->F2_DTENTR)) .Or. (MV_PAR05 == 3 .And. !Empty((cString)->F2_DTENTR))
			DbSkip()
			Loop
		EndIf

		If nLin > 55
			If nLin # 80
				@ nLin,001 PSay Replicate("-",130)
				@ ++nLin,063 PSay "* -> Documentos devolvidos posteriormente"
			EndIf
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif        

		If (cString)->F2_TIPO == "D"
			SA2->(DbSeek(xFilial("SA2") + (cString)->F2_CLIENTE + (cString)->F2_LOJA,.F.))
			_cNmDes := SA2->A2_NOME
		Else
			SA1->(DbSeek(xFilial("SA1") + (cString)->F2_CLIENTE + (cString)->F2_LOJA,.F.))
			_cNmDes := SA1->A1_NOME
		EndIf

		SZF->(DbSeek(xFilial("SZF") + (cString)->F2_SERIE + (cString)->F2_DOC,.F.))
		Do While SZF->ZF_FILIAL == xFilial("SZF")  .And. SZF->ZF_SERIE == (cString)->F2_SERIE  .And. ;
		SZF->ZF_NOTA == (cString)->F2_DOC .And. SZF->ZF_CDROMA # (cString)->F2_CDROMA .And.  (cString)->(!Eof())
			SZF->(DbSkip())
		EndDo

		@ nLin,000 PSay "| " + (cString)->F2_DOC
		@ nLin,012 PSay "|"
		#IFDEF TOP
		@ nLin,014 PSay Stod((cString)->F2_EMISSAO)
		#Else
		@ nLin,014 PSay (cString)->F2_EMISSAO
		#EndIF
		@ nLin,023 PSay "| " +(cString)->F2_CLIENTE + "-" +  (cString)->F2_LOJA + " " + Left(_cNmDes,17)
		@ nLin,053 PSay "|"

		If SZF->ZF_FILIAL == xFilial("SZF")  .And. SZF->ZF_SERIE  == (cString)->F2_SERIE  .And. ;
		SZF->ZF_NOTA == (cString)->F2_DOC .And. SZF->ZF_CDROMA == (cString)->F2_CDROMA .And.  (cString)->(!Eof())

			SA4->(DbSeek(xFilial("SA4") + SZF->ZF_TRANS,.F.))

			#IFDEF TOP
			@ nLin,055 PSay Stod((cString)->F2_DTENTR)
			#Else
			@ nLin,055 PSay (cString)->F2_DTENTR
			#EndIF

			If !Empty(SZF->ZF_DTRETCA)
				@ nLin,063 PSay "*"
			EndIf
			@ nLin,064 PSay "| " + SZF->ZF_TRANS + " " + Left(SA4->A4_NOME,17)
			@ nLin,091 PSay "| " + Left(SZF->ZF_MOTOR,17)
			@ nLin,111 PSay "| " + Left(SZF->ZF_CARREG,17)
		Else
			@ nLin,064 PSay "|"
			@ nLin,091 PSay "|"
			@ nLin,111 PSay "|"
		EndIf
		@ nLin,131 PSay "|"
		nLin := nLin + 1

		(cString)->(DbSkip())
	EndDo
	If nLin # 80
		@ nLin,001 PSay Replicate("-",130)
		@ ++nLin,063 PSay "* -> Documentos devolvidos posteriormente"
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Finaliza a execucao do relatorio...                                 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	SET DEVICE TO SCREEN

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Se impressao em disco, chama o gerenciador de impressao...          ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

	Return
	*
	***************************
Static Function ValidPerg()
	***************************
	*
	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Da Nota                        ?","mv_ch1","C",09,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","At้ a Nota                     ?","mv_ch2","C",09,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Da Emissao                     ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","At้ a Emissao                  ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Imprimir                       ?","mv_ch5","N",01,0,0,"C","","mv_par05","Todos","","","Entregues","","","Nใo Entregues","","","","","","","",""})

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
