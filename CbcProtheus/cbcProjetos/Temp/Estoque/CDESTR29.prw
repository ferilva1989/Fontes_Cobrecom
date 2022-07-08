#include "rwmake.ch"
#include "TOPCONN.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CDESTR29 บ Autor ณ EDVAR VASSAITIS    บ Data ณ  29/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Relatorio de Ordens de Carga                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6 IDE                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/

User Function CDESTR29()


	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Declaracao de Variaveis                                             ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Ordens de Carga"
	Local cPict          := ""
	Local titulo         := "Ordens de Carga"
	Local nLin           := 80

	Local Cabec1         := ""
	Local Cabec2         := ""
	Local imprime        := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite       := 132
	Private tamanho      := "P"
	Private nomeprog     := "CDESTR29" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo        := 15
	Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
	Private nLastKey     := 0
	Private cPerg        := "CDESTR29"
	Private cbtxt        := Space(10)
	Private cbcont       := 00
	Private CONTFL       := 01
	Private m_pag        := 01
	Private wnrel        := "CDESTR29" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString      := "SF2"

	ValidPerg()
	If !Pergunte(cPerg, .T.)
		Return(.T.)
	EndIf

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Monta a interface padrao com o usuario...                           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	If aReturn[4] == 1 //Retrato ou paisagem

		If tamanho == "P"
			nMaxLin := 55
			nMaxCol := 80
		Else
			nMaxLin := 70
			nMaxCol := 131
		EndIf
	Else 
		If tamanho == "P"
			nMaxLin := 55
			nMaxCol := 80
		Else
			nMaxLin := 55
			nMaxCol := 164  //Aproximadamente 25 % de colunas a mais em paisagem
		EndIf
	EndIf

	titulo         := "Ordens de Carga - De "+DToC(Mv_Par01)+" Ate "+DToC(Mv_Par02) 

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Processamento. RPTSTATUS monta janela com a regua de processamento. ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFuno    ณRUNREPORT บ Autor ณ AP6 IDE            บ Data ณ  15/08/06   บฑฑ
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

	Local lImpNF  := .F.
	Local cIdent  := ""
	Local cQuery  := ""
	Local nTamCpo := TamSx3("F2_ESPECIE1")[1]


	dbSelectArea("SF2")
	dbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL

	/*
	SELECT F2_SERIE,F2_DOC,F2_CDROMA,F2_CDCARGA,F2_EMISSAO,
	F2_CLIENTE,F2_LOJA,F2_TRANSP,A1_NOME,A1_END,A1_MUN,A1_EST,A4_NOME,D2_PEDIDO 
	FROM SF2010 F2 
	INNER JOIN SD2010 D2 ON F2.F2_SERIE = D2.D2_SERIE AND F2.F2_DOC = D2.D2_DOC 
	INNER JOIN SA1010 A1 ON F2.F2_CLIENTE = A1.A1_COD AND F2.F2_LOJA = A1.A1_LOJA 
	INNER JOIN SA4010 A4 ON F2.F2_TRANSP = A4.A4_COD 
	WHERE F2.F2_FILIAL = '01' 
	AND D2.D2_FILIAL = '01' 
	AND A1.A1_FILIAL = '  ' 
	AND A4.A4_FILIAL = '  ' 
	AND F2_EMISSAO BETWEEN '20101025' AND '20101025' 
	AND F2.D_E_L_E_T_ <> '*' 
	AND D2.D_E_L_E_T_ <> '*' 
	AND A1.D_E_L_E_T_ <> '*' 
	AND A4.D_E_L_E_T_ <> '*' 
	GROUP BY F2_SERIE, F2_DOC,F2_CDROMA,F2_CDCARGA,F2_EMISSAO,F2_CLIENTE,
	F2_LOJA,F2_TRANSP, A1_NOME,A1_END,A1_MUN,A1_EST,A4_NOME,D2_PEDIDO 
	ORDER BY F2_EMISSAO, F2_CDROMA
	*/

	cQuery += " SELECT F2_SERIE, F2_DOC,F2_CDROMA,F2_CDCARGA,F2_EMISSAO,F2_CLIENTE,F2_LOJA,F2_TRANSP,"
	cQuery += " A1_NOME,A1_END,A1_MUN,A1_EST,A4_NOME,D2_PEDIDO,"
	cQuery += " F2_ESPECI1,F2_ESPECI2,F2_ESPECI3,F2_ESPECI4,"
	cQuery += " F2_VOLUME1,F2_VOLUME2,F2_VOLUME3,F2_VOLUME4"
	cQuery += " FROM "+RetSqlName("SF2")+ " F2"
	cQuery += " INNER JOIN "+RetSqlName("SD2")+ " D2 ON F2.F2_SERIE  = D2.D2_SERIE AND F2.F2_DOC = D2.D2_DOC"
	cQuery += " INNER JOIN "+RetSqlName("SA1")+ " A1 ON F2.F2_CLIENTE = A1.A1_COD AND F2.F2_LOJA = A1.A1_LOJA"
	cQuery += " INNER JOIN "+RetSqlName("SA4")+ " A4 ON F2.F2_TRANSP = A4.A4_COD"
	cQuery += " WHERE F2.F2_FILIAL = '"+xFilial("SF2")+"'"
	cQuery += " AND D2.D2_FILIAL = '"+xFilial("SD2")+"'"
	cQuery += " AND A1.A1_FILIAL = '"+xFilial("SA1")+"'"
	cQuery += " AND A4.A4_FILIAL = '"+xFilial("SA4")+"'"
	cQuery += " AND F2_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"'"
	cQuery += " AND D2_PEDIDO BETWEEN '"+mv_par04+"' AND '"+mv_par05+"'"
	cQuery += " AND F2.D_E_L_E_T_ <> '*'"
	cQuery += " AND D2.D_E_L_E_T_ <> '*'"
	cQuery += " AND A1.D_E_L_E_T_ <> '*'"
	cQuery += " AND A4.D_E_L_E_T_ <> '*'"
	cQuery += " GROUP BY F2_SERIE, F2_DOC,F2_CDROMA,F2_CDCARGA,F2_EMISSAO,F2_CLIENTE,F2_LOJA,F2_TRANSP,"
	cQuery += " A1_NOME,A1_END,A1_MUN,A1_EST,A4_NOME,D2_PEDIDO,"
	cQuery += " F2_ESPECI1,F2_ESPECI2,F2_ESPECI3,F2_ESPECI4,"
	cQuery += " F2_VOLUME1,F2_VOLUME2,F2_VOLUME3,F2_VOLUME4"
	cQuery += " ORDER BY F2_EMISSAO, F2_CDROMA"
	cQuery := ChangeQuery(cQuery)

	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"

	DbSelectArea("TRB")
	DbGotop()
	SetRegua(RecCount())

	Do While !TRB->(Eof())
		IncRegua()

		lImpNF  := .F.
		cPedido := ""
		cIdent  := TRB->F2_CDROMA

		_F2_SERIE   := TRB->F2_SERIE
		_F2_DOC 	:= TRB->F2_DOC
		_F2_CDROMA  := TRB->F2_CDROMA
		_F2_CDCARGA := TRB->F2_CDCARGA
		_F2_EMISSAO := TRB->F2_EMISSAO 
		_F2_CLIENTE := TRB->F2_CLIENTE
		_F2_LOJA 	:= TRB->F2_LOJA
		_F2_TRANSP	:= TRB->F2_TRANSP
		_A1_NOME	:= TRB->A1_NOME
		_A1_END 	:= TRB->A1_END 
		_A1_MUN 	:= TRB->A1_MUN 
		_A1_EST 	:= TRB->A1_EST
		_A4_NOME    := TRB->A4_NOME
		_D2_PEDIDO	:= TRB->D2_PEDIDO
		_F2_ESP1    := TRB->F2_ESPECI1
		_F2_ESP2    := TRB->F2_ESPECI2
		_F2_ESP3    := TRB->F2_ESPECI3
		_F2_ESP4    := TRB->F2_ESPECI4
		_F2_VOL1    := TRB->F2_VOLUME1
		_F2_VOL2    := TRB->F2_VOLUME2
		_F2_VOL3    := TRB->F2_VOLUME3
		_F2_VOL4    := TRB->F2_VOLUME4

		dbSelectArea("SF2")
		dbSeek(xFilial("SF2")+_F2_DOC+_F2_SERIE+_F2_CLIENTE+_F2_LOJA)
		// Imprime somente nใo impressas
		If mv_par03 == 2 .AND. SF2->F2_FLAGIMP == "S"
			TRB->(dbSkip())
			Loop
		EndIf

		If Empty(SF2->F2_FLAGIMP)
			RecLock("SF2",.F.)
			SF2->F2_FLAGIMP := "S"
			MsUnlock()
		EndIf

		Do While !TRB->(Eof()) .And. TRB->F2_CDROMA == cIdent

			If !(TRB->D2_PEDIDO $ _D2_PEDIDO)
				_D2_PEDIDO := _D2_PEDIDO +" / "+ TRB->D2_PEDIDO 
			EndIf

			If TRB->F2_SERIE == "1  "
				lImpNF := .T.
			EndIf

			TRB->(dbSkip())
		EndDo

		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Impressao do cabecalho do relatorio. . .                            ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If nLin > nMaxLin
			nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := nLin + 1 
		Endif                 

		@ nLin,000 Psay "|"
		@ nLin,nMaxCol Psay "|"   
		@ nLin,002 Psay "Nบ Carga       :"
		@ nLin,020 Psay _F2_CDCARGA
		@ nLin,030 Psay "Nบ Nf/Romaneio :"
		@ nLin,048 Psay Iif( lImpNF ,_F2_SERIE +" - "+_F2_DOC , _F2_CDROMA)
		nLin := nLin + 1 

		@ nLin,000 Psay "|"
		@ nLin,nMaxCol Psay "|"   
		@ nLin,002 Psay "Cliente        :"
		@ nLin,020 Psay Alltrim(_F2_CLIENTE) + "/" + Alltrim(_F2_LOJA) + " " + _A1_NOME
		nLin := nLin + 1 

		@ nLin,000 Psay "|"
		@ nLin,nMaxCol Psay "|"   
		@ nLin,002 Psay "Endere็o       :  " + Left(Alltrim(_A1_END),40) + " /" + Alltrim(_A1_MUN) + " /" +_A1_EST
		nLin := nLin + 1 

		@ nLin,000 Psay "|"
		@ nLin,nMaxCol Psay "|"   	
		@ nLin,002 Psay "Transportadora :"
		@ nLin,020 Psay _F2_TRANSP  + " - " + _A4_NOME
		nLin := nLin + 1 

		For nI:=1 to Len( _D2_PEDIDO ) //CONDICAO P/ N PASSAR o maximo de colunas

			@ nLin,000 Psay "|"
			@ nLin,nMaxCol Psay "|"   	  
			@ nLin,002 Psay "Nบ Pedidos     :"
			@ nLin,020 Psay Substr( _D2_PEDIDO , nI, 80 )

			nLin := nLin + 1 

			nI +=80
		Next

		For nI:= 1 to 4
			nJ:=Str(nI,1)

			If !Empty(&("_F2_ESP"+nJ)) .Or. &("_F2_VOL"+nJ) > 0
				@ nLin,000 Psay "|"
				@ nLin,nMaxCol Psay "|"
				@ nLin,002 Psay "Volume/Especie"
				@ nLin,016 Psay &(nJ)
				@ nLin,017 Psay ":"
				@ nLin,020 Psay &("_F2_ESP"+nJ) 
				@ nLin,032 Psay "/" 
				@ nLin,034 Psay &("_F2_VOL"+nJ)
				nLin := nLin + 1
			EndIf   	
		Next

		@ nLin,000 Psay "|"
		@ nLin,nMaxCol Psay "|"   
		@ nLin,001 Psay Replicate("-",nMaxCol+1)

		nLin := nLin + 1

		If nLin < nMaxLin
			@ nLin,000 Psay "|"
			@ nLin,nMaxCol Psay "|"  
			nLin := nLin + 1
		EndIf


		TRB->(dbSkip())
	EndDo		

	dbCloseArea("TRB")

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

	Return(.T.)

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

	//Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Data de   ?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Data ate  ?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Imprime   ?","mv_ch3","N",01,0,0,"C","","mv_par03","Todas","","","Nใo Impressas","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Pedido de ?","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SC5"})
	aAdd(aRegs,{cPerg,"05","Pedido ate?","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SC5"})

	For i := 1 To Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2] , .F.)
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
