#INCLUDE "rwmake.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO4     º Autor ³ AP6 IDE            º Data ³  24/11/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CDFINR04()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1       := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2       := "de acordo com os parametros informados pelo usuario."
	Local cDesc3       := "Relatório para Depósitos/Boletos"
	Local cPict        := ""
	Local titulo       := "Relatório para Depósitos/Boletos"
	Local nLin         := 80

	Local Cabec1       := ""

	// | Vencto.  | Favorecido                               | CNPJ / CPF         |Banco| Agencia  | Conta        | Valor R$.    | Caixa  |
	// | 99/99/99 | xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx | 99.999.999/9999-99 | 999 | xxxxx-22 | xxxxxxxxxx   | 9,999,999.99 | xxxxxx |

	Local Cabec2       := "| Vencto.  | Favorecido                               | CNPJ / CPF         |Banco| Agencia  | Conta        | Valor R$.    | Caixa  |"
	Local imprime      := .T.
	Local aOrd 		   := {}
	Private lEnd       := .F.
	Private lAbortPrint:= .F.
	Private CbTxt      := ""
	Private limite     := 132
	Private tamanho    := "M"
	Private nomeprog   := "CDFINR04" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo      := 18
	Private aReturn    := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey   := 0
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "CDFINR04" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString := "SZM"

	cPerg 	  := "CDFI04"
	_cFiliais := ""

	ValidPerg()
	Pergunte(cPerg, .F.)

	dbSelectArea("SZM")
	dbSetOrder(1)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.F.)

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

	Cabec1       := "Caixas Nros. "
	For _nQtdFil := 1 to Len(_cFiliais) / 2
		_Mv := "MV_PAR" + StrZero(_nQtdFil,2)
		If _nQtdFil > 1
			Cabec1 += ", "
		EndIf
		Cabec1 += &(_Mv)
	Next
	Cabec1 += "."
	_nSpace := Int((limite-Len(Cabec1)) / 2)

	Cabec1 := Space(_nSpace)+Cabec1

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	Return(.T.)

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  24/11/09   º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
	±±º          ³ monta a janela com a regua de processamento.               º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Programa principal                                         º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/
	****************************************************
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	****************************************************
	*
	Local nOrdem
	Local cNome := ""
	Local cCGC  := ""

	DbSelectArea("SE2")
	DbSetOrder(1)

	DbSelectArea("SA2")
	DbSetOrder(1)

	DbSelectArea("SRA")
	DbSetOrder(1) // RA_FILIAL+RA_MAT

	DbSelectArea("SZT")
	DbSetOrder(2) // ZT_FILIAL+ZT_PREFIXO+ZT_NUMSE2+ZT_PARCELA+ZT_TIPO

	dbSelectArea("SZM")
	dbSetOrder(1) // ZM_FILIAL+ZM_NUMCX+ZM_PREFIXO+ZM_NUMERO+ZM_PARCELA+ZM_TIPO+ZM_FORNEC+ZM_LOJA
	SetRegua(RecCount())

	nVez := 1
	_nSomaDp := 0.00
	_nSomaBl := 0.00
	_nSomaFc := 0.00
	_aDeps := {}

	Do While !Empty(_cFiliais)
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		_cFilAtu := Left(_cFiliais,2)
		_mMvAtu  := "MV_PAR"+StrZero(nVez++,2)
		_mMvAtu  := &(_mMvAtu)
		_cFiliais := AllTrim(Substr(_cFiliais,3,500))

		DbSelectArea("SZM")
		DbSeek(_cFilAtu+_mMvAtu,.F.)

		Do While SZM->ZM_FILIAL == _cFilAtu .And. SZM->ZM_NUMCX ==_mMvAtu .And. SZM->(!Eof())
			IncRegua()
			If lAbortPrint
				Exit
			Endif

			If SZM->ZM_TPDADO # "E" // Não lista estornos
				//_lFunc := .F.
				//_lFunc := SZT->(DbSeek(_cFilAtu+SZM->ZM_PREFIXO+SZM->ZM_NUMERO+SZM->ZM_PARCELA+SZM->ZM_TIPO,.F.))

				SE2->(DbSeek(_cFilAtu+SZM->ZM_PREFIXO+SZM->ZM_NUMERO+SZM->ZM_PARCELA+SZM->ZM_TIPO+SZM->ZM_FORNEC+SZM->ZM_LOJA,.F.))


				//TOTAIS DO RELATORIO
				If Empty(SE2->E2_CODBAR) //Deposito
					//			_nSomaDp += SZM->ZM_VALOR //SE2->E2_SALDO
					_cOrdem := "A"
				Else//Boletos
					_cOrdem := "B"
					//_nSomaBl += SZM->ZM_VALOR //SE2->E2_SALDO
				EndIf

				//Tratamento para pagamento de funcionarios
				//Ao inves de sair o total de pagamentos, este tratamento lista pagamento de cada funcionario

				_lSZT := .F.
				SZT->(DbSeek(_cFilAtu+SZM->ZM_PREFIXO+SZM->ZM_NUMERO+SZM->ZM_PARCELA+SZM->ZM_TIPO,.F.))
				Do While SZT->(!Eof()) .And. SZT->ZT_FILIAL+SZT->ZT_PREFIXO+SZT->ZT_NUMSE2+SZT->ZT_PARCELA+SZT->ZT_TIPO == ;
				_cFilAtu+SZM->ZM_PREFIXO+SZM->ZM_NUMERO+SZM->ZM_PARCELA+SZM->ZM_TIPO

					SRA->(DbSeek(_cFilAtu+SZT->ZT_MAT,.F.))
					_nSomaFc += SZT->ZT_VALOR
					_lSZT := .T.
					_cChave := SZM->ZM_NUMCX+Dtos(SZT->ZT_DTPAG)+SZM->ZM_FORNEC+SZM->ZM_LOJA + SRA->RA_BCDEPSA + SRA->RA_CTDEPSA + SRA->RA_CTADIG

					nPos :=  aScan(_aDeps,{|x| x[1] == _cChave})

					If nPos == 0
						Aadd(_aDeps,{_cChave,SZT->ZT_VALOR,"C"+Left(SRA->RA_BCDEPSA,3)+Dtos(SZT->ZT_DTPAG),SZT->ZT_DTPAG,"SZT",SZT->ZT_MAT,})
					Else
						_aDeps[nPos,2] += SZT->ZT_VALOR
					EndIf

					SZT->(DbSkip())
				EndDo

				//Desconsidero os titulos de pagamento de funcionario que já processei emcima
				//Que possuam registros na tabela SZT
				If !_lSZT

					_cChave := SZM->ZM_NUMCX+Dtos(SE2->E2_VENCREA)+SZM->ZM_FORNEC+SZM->ZM_LOJA+SE2->E2_BANCO + SE2->E2_AGENCIA + SE2->E2_DVAGENC+SE2->E2_NUMCON
					nPos :=  aScan(_aDeps,{|x| x[1] == _cChave})

					If nPos == 0 .Or. _cOrdem == "B"
						//			Aadd(_aDeps,{_cChave,SE2->E2_SALDO,_cOrdem+Dtos(SE2->E2_VENCREA),SE2->E2_VENCREA})
						Aadd(_aDeps,{_cChave,SZM->ZM_VALOR,_cOrdem+SE2->E2_BANCO+Dtos(SE2->E2_VENCREA),SE2->E2_VENCREA,"SE2","  "})
					Else
						_aDeps[nPos,2] += SZM->ZM_VALOR // SE2->E2_SALDO
					EndIf
				EndIf
			EndIf

			SZM->(DbSkip())
		EndDo
	EndDo

	If !lAbortPrint
		SetRegua(Len(_aDeps))
		aSort(_aDeps,,,{|x,y| x[3]<y[3]})
		_cDado := " "

		For _nCtdr := 1 To Len(_aDeps)
			IncRegua()
			If lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif

			If _cDado # Substr(_aDeps[_nCtdr,3],1,1)
				If _cDado == "A" // Imprimir total de depositos e cabeçalho de boletos
					If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 9
					Else
						@ nLin++,000 Psay "|----------------------------------------------------------------------------------------------------------|--------------|--------|"
					Endif
					@ nLin  ,000 Psay "|            Soma dos Depositos                                                                            |"
					@ nLin  ,109 Psay _nSomaDp Picture "@E 9,999,999.99"
					@ nLin++,122 Psay "|        |"
					@ nLin++,000 Psay "|----------------------------------------------------------------------------------------------------------|--------------|--------|"

					// Tratamento casa não tenha boletos
					If aScan(_aDeps,{|x| Substr(x[3],1,1) == "B"}) <> 0
						@ nLin++,000 Psay "|          | B O L E T O S                            |                    |     |          |              |              |        |"
					Else
						@ nLin  ,000 Psay "|            Soma dos Funcionarios                                                                         |"
						@ nLin  ,109 Psay _nSomaFc Picture "@E 9,999,999.99"
						@ nLin++,122 Psay "|        |"
						@ nLin++,000 Psay "|----------------------------------------------------------------------------------------------------------|--------------|--------|"
						@ nLin  ,000 Psay "|            Total do Relatorio                                                                            |"
						@ nLin  ,109 Psay _nSomaDp+_nSomaBl+_nSomaFc Picture "@E 9,999,999.99"
						@ nLin++,122 Psay "|        |"
						@ nLin++,000 Psay "|----------------------------------------------------------------------------------------------------------|--------------|--------|"

						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 9
						@ nLin++  ,000 Psay "|          | F U N C I O N A R I O S                  |                    |     |          |              |              |        |"
					EndIf
					@ nLin++,000 Psay "|          |                                          |                    |     |          |              |              |        |"

				ElseIf _cDado == "B"
					If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
						Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
						nLin := 9
					Else
						@ nLin++,000 Psay "|----------------------------------------------------------------------------------------------------------|--------------|--------|"
					Endif
					@ nLin  ,000 Psay "|            Soma dos Boletos                                                                              |"
					@ nLin  ,109 Psay _nSomaBl Picture "@E 9,999,999.99"
					@ nLin++,122 Psay "|        |"
					@ nLin++,000 Psay "|----------------------------------------------------------------------------------------------------------|--------------|--------|"
					@ nLin  ,000 Psay "|            Soma dos Funcionarios                                                                         |"
					@ nLin  ,109 Psay _nSomaFc Picture "@E 9,999,999.99"
					@ nLin++,122 Psay "|        |"
					@ nLin++,000 Psay "|----------------------------------------------------------------------------------------------------------|--------------|--------|"
					@ nLin  ,000 Psay "|            Total do Relatorio                                                                            |"
					@ nLin  ,109 Psay _nSomaDp+_nSomaBl+_nSomaFc Picture "@E 9,999,999.99"
					@ nLin++,122 Psay "|        |"
					@ nLin++,000 Psay "|----------------------------------------------------------------------------------------------------------|--------------|--------|"

					nLin := 56
				EndIf
				_cDado := Substr(_aDeps[_nCtdr,3],1,1)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao do cabecalho do relatorio. . .                            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
				nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 9
				If _cDado == "A"
					@ nLin++  ,000 Psay "|          | D E P O S I T O S                        |                    |     |          |              |              |        |"
				ElseIf _cDado == "B"
					@ nLin++  ,000 Psay "|          | B O L E T O S                            |                    |     |          |              |              |        |"
				Else
					@ nLin++  ,000 Psay "|          | F U N C I O N A R I O S                  |                    |     |          |              |              |        |"
				EndIf
				@ nLin++  ,000 Psay "|          |                                          |                    |     |          |              |              |        |"
			EndIf
			// 	_cChave := SZM->ZM_NUMCX + Dtos(SE2->E2_VENCREA) + SZM->ZM_FORNEC + SZM->ZM_LOJA + SE2->E2_BANCO + SE2->E2_AGENCIA + SE2->E2_DVAGENC + SE2->E2_NUMCON
			//             1,6             7,8                     15,6             21,2           23,3            26,5              31,2              33,10

			If _cDado == "A"
				_nSomaDp += _aDeps[_nCtdr,2]
			ElseIf _cDado == "B"
				_nSomaBl += _aDeps[_nCtdr,2]
			EndIf

			If _aDeps[_nCtdr,5] == "SE2"
				SA2->(DbSeek(xFilial("SA2")+Substr(_aDeps[_nCtdr,1],15,8),.F.))
				cNome := SA2->A2_NOME
				cCGC  := SA2->A2_CGC
				cBanco:= Substr(_aDeps[_nCtdr,1],23,3)
				cAge  := Substr(_aDeps[_nCtdr,1],26,5) + If(Empty(Substr(_aDeps[_nCtdr,1],31,2)),"","-"+Substr(_aDeps[_nCtdr,1],31,2))
				cConta:= Substr(_aDeps[_nCtdr,1],33,10)
			Else
				SRA->(DbSeek(xFilial("SRA")+_aDeps[_nCtdr,6],.F.))
				cNome := SRA->RA_NOME
				cCGC  := SRA->RA_CIC+"   "
				cBanco:= Substr(_aDeps[_nCtdr,1],23,3)
				cAge  := Substr(_aDeps[_nCtdr,1],26,4) + If(Empty(Substr(_aDeps[_nCtdr,1],30,1)),"","-"+Substr(_aDeps[_nCtdr,1],30,1))
				cConta:= Alltrim(Substr(_aDeps[_nCtdr,1],31,12))+Iif(Empty(Substr(_aDeps[_nCtdr,1],43,2)),"","-"+Alltrim(Substr(_aDeps[_nCtdr,1],43,2)))
			EndIf

			@ nLin,000 Psay "|"
			@ nLin,002 Psay _aDeps[_nCtdr,4]
			@ nLin,011 Psay "|"
			@ nLin,013 Psay Left(cNome,41)
			@ nLin,054 Psay "|"
			@ nLin,056 Psay Alltrim(cCGC) Picture If(" " $ cCGC,"@R 999.999.999-99","@R 99.999.999/9999-99")
			@ nLin,075 Psay "|"
			@ nLin,077 Psay If(!Empty(cBanco),cBanco,"   ")
			@ nLin,081 Psay "|"
			@ nLin,083 Psay If(!Empty(cBanco),cAge,"   ")
			@ nLin,092 Psay "|"
			@ nLin,094 Psay If(!Empty(cBanco),cConta,"   ")
			@ nLin,107 Psay "|"
			@ nLin,109 Psay _aDeps[_nCtdr,2] Picture "@E 9,999,999.99"
			@ nLin,122 Psay "|"
			@ nLin,124 Psay Substr(_aDeps[_nCtdr,1],1,6)
			@ nLin,131 Psay "|"
			nLin := nLin + 1 // Avanca a linha de impressao

			If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
				@ nLin  ,000 Psay "|----------------------------------------------------------------------------------------------------------|--------------|--------|"
			EndIf
		Next
	EndIf
	If _nSomaDp+_nSomaBl > 0 .And. !lAbortPrint
		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
			If _cDado == "A"
				@ nLin++  ,000 Psay "|          | D E P O S I T O S                        |                    |     |          |              |              |        |"
			ElseIf _cDado == "B"
				@ nLin++  ,000 Psay "|          | B O L E T O S                            |                    |     |          |              |              |        |"
				@ nLin++  ,000 Psay "|          |                                          |                    |     |          |              |              |        |"
			Else
				@ nLin++  ,000 Psay "|          | F U N C I O N A R I O S                  |                    |     |          |              |              |        |"
				@ nLin++  ,000 Psay "|          |                                          |                    |     |          |              |              |        |"
			EndIf
			@ nLin++  ,000 Psay "|          |                                          |                    |     |          |              |              |        |"
		Else
			@ nLin++  ,000 Psay "|----------------------------------------------------------------------------------------------------------|--------------|--------|"
		Endif
		If _cDado == "A" // Imprimir total de depositos e cabeçalho de boletos
			@ nLin  ,000 Psay "|            Soma dos Depositos                                                                            |"
			@ nLin  ,109 Psay _nSomaDp Picture "@E 9,999,999.99"
		ElseIf _cDado == "B"
			@ nLin  ,000 Psay "|            Soma dos Boletos                                                                              |"
			@ nLin  ,109 Psay _nSomaBl Picture "@E 9,999,999.99"
		Else
			@ nLin  ,000 Psay "|            Soma dos Funcionarios                                                                         |"
			@ nLin  ,109 Psay _nSomaFc Picture "@E 9,999,999.99"
		EndIf
		@ nLin++,122 Psay "|        |"

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 9
		Else
			@ nLin++,000 Psay "|----------------------------------------------------------------------------------------------------------|--------------|--------|"
		Endif
		//	@ nLin  ,000 Psay "|            Total do Relatorio                                                                            |"
		//	@ nLin  ,109 Psay _nSomaDp+_nSomaBl+_nSomaFc Picture "@E 9,999,999.99"
		//	@ nLin++,122 Psay "|        |"
		//	@ nLin  ,000 Psay " ---------------------------------------------------------------------------------------------------------------------------------- "
	EndIf

	SET DEVICE TO SCREEN

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

	Return(.T.)
*
/////////////////////////
Static Function ValidPerg
	/////////////////////////

	_aArea := GetArea()
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	aRegs:={}
	_nVez := 1

	DbSelectArea("SM0")
	_RegSM0 := SM0->(Recno())
	DbSeek("01",.F.)
	Do While SM0->M0_CODIGO == "01" .And. SM0->(!Eof())
		_cFiliais += FWCodFil()

		//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
		aAdd(aRegs,{cPerg,StrZero(_nVez,2),"Nro. Caixa "+Left(SM0->M0_ESTENT,2)+"                ?","mv_ch"+StrZero(_nVez,1),"C",06,0,0,"G","","mv_par"+StrZero(_nVez,2),"","","","","","","","","","","","","","",""})
		_nVez++
		SM0->(DbSkip())
	EndDo
	DbGoTo(_RegSM0)

	DbSelectArea("SX1")
	DbSetOrder(1)

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
