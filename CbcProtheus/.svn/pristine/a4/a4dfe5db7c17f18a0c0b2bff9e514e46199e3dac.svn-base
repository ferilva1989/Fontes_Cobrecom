#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

#define CRLF Chr(13)+Chr(10)
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ PAGFOR   ³ Autor ³ Roberto Oliveira      ³ Data ³ 29/07/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funçoes para uso do pagfor                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIN                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                              
*
***********************
User Function Pagagen() // Função revisada
	***********************
	*
	_cAgen := StrZero(0,5)
	_cDvAg := " "
	If !Empty(SE2->E2_CODBAR)
		If Substr(SE2->E2_CODBAR,1,3) == "237" // é Bradesco?
			_cAgen := "0"+Substr(SE2->E2_CODBAR,20,4)
			_cDvAg := CalcDV(Substr(SE2->E2_CODBAR,20,4))
		EndIf
	Else
		_cAgen := StrZero(Val(Left(AllTrim(SE2->E2_AGENCIA),5)),5)
		_cDvAg := Left(AllTrim(SE2->E2_DVAGENC),1)
	EndIf
Return(_cAgen+_cDvAg)
	*
	**********************
User Function Pagmod() // Função revisada
	**********************
	*
	SetPrvt("_AMODEL,")

	/////  PROGRAMA PARA INDICAR A MODALIDADE DO PAGAMENTO
	/////  CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (264-265)
	IF !Empty(SE2->E2_CODBAR,1,3) // Boletos de Cobrança
		_aModel := "31"
	ElseIf SE2->E2_BANCO == "237" // Credito em conta corrente
		_aModel := "01"
	Else
		_aModel := "08" // TED para outros bancos
	EndIf

Return(_aModel)
	*
	**********************
User Function Pagban() // Função revisada
	**********************
	*
	SetPrvt("_BANCO,")
	*
	IF SUBSTR(SE2->E2_CODBAR,1,3) == "   "
		_BANCO := SE2->E2_BANCO
	ELSE
		_BANCO := SUBSTR(SE2->E2_CODBAR,1,3)
	ENDIF
Return(_BANCO)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
	*
	**********************
User Function Pagcar() // Função revisada
	**********************
	*
	SetPrvt("_RETCAR,")
	IF Substr(SE2->E2_CODBAR,01,3) # "237"
		_Retcar := "000"
	Else
		_Retcar := "0" + Substr(SE2->E2_CODBAR,24,2)
	EndIf
Return(_Retcar)
	*
	**********************
User Function Pagnos() // Função revisada
	**********************
	*
	SetPrvt("_RETNOS,")

	//// RETORNA O NOSSO NUMERO QUANDO COM VALOR NO E2_CODBAR, E ZEROS QUANDO NAO
	//// TEM VALOR POSICAO ( 142 - 150 )

	IF Substr(SE2->E2_CODBAR,01,3) # "237"
		_RETNOS := "000000000000"
	Else
		_RETNOS := Substr(SE2->E2_CODBAR,26,11) + " "
	EndIf
Return(_RETNOS)
	*
	**********************
User Function Pagdoc() // Função revisada
	**********************
	*
	SetPrvt("_Doc")
	/////  PROGRAMA GRAVAR AS INFORMACOES COMPLEMENTARES
	/////  CNAB BRADESCO A PAGAR (PAGFOR) - POSICOES (374-413)
	IF !Empty(SE2->E2_CODBAR,1,3) // Titulos em boletos
		_Doc := Substr(SE2->E2_CODBAR,20,25)+Substr(SE2->E2_CODBAR,5,1)+Substr(SE2->E2_CODBAR,4,1)+Space(13)
	ElseIf SE2->E2_BANCO == "237" // Credito em conta corrente
		_Doc := Space(40)
	Else // Credito em conta corrente outro banco (DOC ou TED)
		If Left(SA2->A2_CGC,8) == "02544042" // Mesma Titularidade
			_Doc := "D0000000101"+Space(29)
		Else
			If SE2->E2_TPCTA # "2" // Cta.Corrente Individual
				_Doc := "C0000000101"+Space(29)
			Else
				_Doc := "C0000001102"+Space(29)
			EndIf
		EndIf
	EndIf
Return(_Doc)
	*
	**********************
User Function PagTip() // Função revisada
	**********************
	*
	SetPrvt("_Tip")
	_Tip := "0"
	If u_Pagmod() == "01" // Credito em conta corrente
		If SE2->E2_TPCTA == "1" // Cta.Corrente Individual
			_Tip := "1"
		Else
			_Tip := "2"
		EndIf
	EndIf
Return(_Tip)
	*
	***********************
User Function Pagacta() // Função revisada
	***********************
	*
	_PosIfem := At("-",SE2->E2_NUMCON)

	_cConta := StrZero(Val(Left(Left(SE2->E2_NUMCON,_PosIfem-1) + Space(15),13)),13)
	_cDvCon := Left(Right(SE2->E2_NUMCON,Len(SE2->E2_NUMCON)-_PosIfem) + "  ",2)

	If !Empty(SE2->E2_CODBAR)
		If Substr(SE2->E2_CODBAR,1,3) == "237" // é Bradesco?
			_cConta := "000000"+Substr(SE2->E2_CODBAR,37,7)
			_cDvCon := CalcDV(_cConta)
		Else
			_cConta := StrZero(0,13)
			_cDvCon := "  "
		EndIf
	EndIf
Return(_cConta+_cDvCon)

	*
	**********************
User Function Pagide() // Função revisada
	**********************
	*
	_cCgc := "0"+AllTrim(SA2->A2_CGC)
	If Len(_cCgc) == 12 // CPF
		_cCgc := Substr(_cCgc,2,9) + "0000" + Right(_cCgc,2)
	ElseIf Len(_cCgc) # 15 // Em branco ou inválido
		_cCgc := Repl("0",15)
	EndIf
Return(_cCgc)
	*
	******************************
Static Function CalcDV(_nBase) // Função revisada
	******************************
	*
	Local _nFat
	_Mult := Right("9876543298765432987654329876543298765432987654329876543298765432987654329876543298765432987654329876543298765432",Len(_nBase))
	_nResult := 0

	For _nFat := 1 to Len(_nBase)
		_nResult := _nResult + (Val(Substr(_nBase,_nFat,1)) * Val(Substr(_Mult,_nFat,1)))
	Next

	_nDig := (_nResult % 11)
	If _nDig == 1 .Or. _nDig == 0
		_nDig := 0
	Else
		_nDig := 11 - (_nResult % 11)
	EndIf
Return(Str(_nDig,1))
	// Não sei se as funções abaixo são usadas

	*
	**********************
USER FUNCTION CodBar()
	**********************
	*
	Local nPosStr 	:= 0
	Local aArea := GetArea()

	///--------------------------------------------------------------------------\
	//| Função: CODBAR				Autor: Flávio Novaes				Data: 19/10/2003 |
	//|--------------------------------------------------------------------------|
	//| Essa Função foi desenvolvida com base no Manual do Bco. Itaú e no RDMAKE:|
	//| CODBARVL - Autor: Vicente Sementilli - Data: 26/02/1997.                 |
	//|--------------------------------------------------------------------------|
	//| Descrição: Função para Validação de Código de Barras (CB) e Representação|
	//|            Numérica do Código de Barras - Linha Digitável (LD).			  |
	//|                                                                          |
	//|            A LD de Bloquetos possui três Digitos Verificadores (DV) que  |
	//|				são consistidos pelo Módulo 10, além do Dígito Verificador    |
	//|				Geral (DVG) que é consistido pelo Módulo 11. Essa LD têm 47   |
	//|            Dígitos.                                                      |
	//|                                                                          |
	//|            A LD de Títulos de Concessinárias do Serviço Público e IPTU   |
	//|				possui quatro Digitos Verificadores (DV) que são consistidos  |
	//|            pelo Módulo 10, além do Digito Verificador Geral (DVG) que    |
	//|            também é consistido pelo Módulo 10. Essa LD têm 48 Dígitos.   |
	//|                                                                          |
	//|            O CB de Bloquetos e de Títulos de Concessionárias do Serviço  |
	//|            Público e IPTU possui apenas o Dígito Verificador Geral (DVG) |
	//|            sendo que a única diferença é que o CB de Bloquetos é         |
	//|            consistido pelo Módulo 11 enquanto que o CB de Títulos de     |
	//|            Concessionárias é consistido pelo Módulo 10. Todos os CB´s    |
	//|            têm 44 Dígitos.                                               |
	//|                                                                          |
	//|            Para utilização dessa Função, deve-se criar o campo E2_CODBAR,|
	//|            Tipo Caracter, Tamanho 48 e colocar na Validação do Usuário:  |
	//|            EXECBLOCK("CODBAR",.T.).                                      |
	//|                                                                          |
	//|            Utilize também o gatilho com a Função CONVLD() para converter |
	//|            a LD em CB.																     |
	//\--------------------------------------------------------------------------/

	SETPRVT("cStr,lRet,cTipo,nConta,nMult,nVal,nDV,cCampo,i,nMod,nDVCalc")

	// Retorna .T. se o Campo estiver em Branco.
	IF VALTYPE(M->E2_CODBAR) == NIL .OR. EMPTY(M->E2_CODBAR)
		RETURN(.T.)

	ELSEIF Len(Alltrim(M->E2_CODBAR)) < 33
		MessageBox("[AVISO] - Verifique o Codigo de Barras", "Aviso", 48)
		RETURN(.F.)
	ENDIF

	cStr := AllTrim(M->E2_CODBAR)

	// Se o Tamanho do String for 45 ou 46 está errado! Retornará .F.
	lRet := IF(LEN(cStr)==45 .OR. LEN(cStr)==46,.F.,.T.)

	// Se o Tamanho do String for menor que 44, completa com zeros até 47 dígitos. Isso é
	// necessário para Bloquetos que NÂO têm o vencimento e/ou o valor informados na LD.

	IF Len(cStr)<44
		cStr1 	:= Left(cStr,33) //33 posições
		cStr2 	:= Right(cStr,Len(cStr)-33)   //34 em diante
		cStr := cStr1 + Replicate("0",47-Len(cStr)) + cStr2
	EndIf

	//cStr := IF(LEN(cStr)<44,cStr+REPL("0",47-LEN(cStr)),cStr)

	// Verifica se a LD é de (B)loquetos ou (C)oncessionárias/IPTU. Se for CB retorna (I)ndefinido.
	cTipo := IF(LEN(cStr)==47,"B",IF(LEN(cStr)==48,"C","I"))

	// Verifica se todos os dígitos são numérios.
	FOR i := LEN(cStr) TO 1 STEP -1
		lRet := IF(SUBSTR(cStr,i,1) $ "0123456789",lRet,.F.)
	NEXT

	IF LEN(cStr) == 47 .AND. lRet
		// Consiste os três DV´s de Bloquetos pelo Módulo 10.
		nConta  := 1
		WHILE nConta <= 3
			nMult  := 2
			nVal   := 0
			nDV    := VAL(SUBSTR(cStr,IF(nConta==1,10,IF(nConta==2,21,32)),1))
			cCampo := SUBSTR(cStr,IF(nConta==1,1,IF(nConta==2,11,22)),IF(nConta==1,9,10))
			FOR i := LEN(cCampo) TO 1 STEP -1
				nMod  := VAL(SUBSTR(cCampo,i,1)) * nMult
				nVal  := nVal + IF(nMod>9,1,0) + (nMod-IF(nMod>9,10,0))
				nMult := IF(nMult==2,1,2)
			NEXT
			nDVCalc := 10-MOD(nVal,10)
			// Se o DV Calculado for 10 é assumido 0 (Zero).
			nDVCalc := IF(nDVCalc==10,0,nDVCalc)
			lRet    := IF(lRet,(nDVCalc==nDV),.F.)
			nConta  := nConta + 1
		ENDDO
		// Se os DV´s foram consistidos com sucesso (lRet=.T.), converte o número para CB para consistir o DVG.
		cStr := IF(lRet,SUBSTR(cStr,1,4)+SUBSTR(cStr,33,15)+SUBSTR(cStr,5,5)+SUBSTR(cStr,11,10)+SUBSTR(cStr,22,10),cStr)
	ENDIF

	IF LEN(cStr) == 48 .AND. lRet
		// Consiste os quatro DV´s de Títulos de Concessionárias de Serviço Público e IPTU pelo Módulo 10.
		nConta  := 1
		WHILE nConta <= 4
			nMult  := 2
			nVal   := 0
			nDV    := VAL(SUBSTR(cStr,IF(nConta==1,12,IF(nConta==2,24,IF(nConta==3,36,48))),1))
			cCampo := SUBSTR(cStr,IF(nConta==1,1,IF(nConta==2,13,IF(nConta==3,25,37))),11)
			FOR i := 11 TO 1 STEP -1
				nMod  := VAL(SUBSTR(cCampo,i,1)) * nMult
				nVal  := nVal + IF(nMod>9,1,0) + (nMod-IF(nMod>9,10,0))
				nMult := IF(nMult==2,1,2)
			NEXT
			nDVCalc := 10-MOD(nVal,10)
			// Se o DV Calculado for 10 é assumido 0 (Zero).
			nDVCalc := IF(nDVCalc==10,0,nDVCalc)
			lRet    := IF(lRet,(nDVCalc==nDV),.F.)
			nConta  := nConta + 1
		ENDDO
		// Se os DV´s foram consistidos com sucesso (lRet=.T.), converte o número para CB para consistir o DVG.
		cStr := IF(lRet,SUBSTR(cStr,1,11)+SUBSTR(cStr,13,11)+SUBSTR(cStr,25,11)+SUBSTR(cStr,37,11),cStr)
	ENDIF

	IF LEN(cStr) == 44 .AND. lRet
		IF cTipo $ "BI"
			// Consiste o DVG do CB de Bloquetos pelo Módulo 11.
			nMult  := 2
			nVal   := 0
			nDV    := VAL(SUBSTR(cStr,5,1))
			cCampo := SUBSTR(cStr,1,4)+SUBSTR(cStr,6,39)
			FOR i := 43 TO 1 STEP -1
				nMod  := VAL(SUBSTR(cCampo,i,1)) * nMult
				nVal  := nVal + nMod
				nMult := IF(nMult==9,2,nMult+1)
			NEXT
			nDVCalc := 11-MOD(nVal,11)
			// Se o DV Calculado for 0,10 ou 11 é assumido 1 (Um).
			nDVCalc := IF(nDVCalc==0 .OR. nDVCalc==10 .OR. nDVCalc==11,1,nDVCalc)
			lRet    := IF(lRet,(nDVCalc==nDV),.F.)
			// Se o Tipo é (I)ndefinido E o DVG NÂO foi consistido com sucesso (lRet=.F.), tentará
			// consistir como CB de Título de Concessionárias/IPTU no IF abaixo.
		ENDIF
		IF cTipo == "C" .OR. (cTipo == "I" .AND. !lRet)
			// Consiste o DVG do CB de Títulos de Concessionárias pelo Módulo 10.
			lRet   := .T.
			nMult  := 2
			nVal   := 0
			nDV    := VAL(SUBSTR(cStr,4,1))
			cCampo := SUBSTR(cStr,1,3)+SUBSTR(cStr,5,40)
			FOR i := 43 TO 1 STEP -1
				nMod  := VAL(SUBSTR(cCampo,i,1)) * nMult
				nVal  := nVal + IF(nMod>9,1,0) + (nMod-IF(nMod>9,10,0))
				nMult := IF(nMult==2,1,2)
			NEXT
			nDVCalc := 10-MOD(nVal,10)
			// Se o DV Calculado for 10 é assumido 0 (Zero).
			nDVCalc := IF(nDVCalc==10,0,nDVCalc)
			lRet    := IF(lRet,(nDVCalc==nDV),.F.)
		ENDIF
	ENDIF
	IF !lRet
		HELP(" ",1,"ONLYNUM")
	ElseIf !Empty(M->E2_CODBAR)
		//Converter e verificar Valor
		M->E2_CODBAR := cStr
		_cMyCodBar := u_ConvLD(M->E2_CODBAR)

		If INCLUI
			_nValTit := (M->E2_VALOR+M->E2_ACRESC+M->E2_JUROS-M->E2_DECRESC-M->E2_ISS-M->E2_IRRF)
		Else
			if Empty(_nValTit := SALDOTIT(M->E2_PREFIXO,M->E2_NUM,M->E2_PARCELA,M->E2_TIPO,M->E2_NATUREZ,"P",M->E2_FORNECE,M->E2_MOEDA,dDataBase,M->E2_VENCREA,M->E2_LOJA,M->E2_FILIAL) )
				_nValTit := (M->E2_VALOR+M->E2_ACRESC+M->E2_JUROS-M->E2_DECRESC-M->E2_ISS-M->E2_IRRF)
			EndIf
		EndIf

		_nValCod := Val(Substr(_cMyCodBar,10,08) + "." + Substr(_cMyCodBar,18,02))
		_dFator  := CtoD("07/10/1997") + Val(SUBSTR(_cMyCodBar,6,4))
		_nVlAbat := SomaAbat(M->E2_PREFIXO,M->E2_NUM,M->E2_PARCELA,"P",1,,M->E2_FORNECE,M->E2_LOJA)

		If _nValCod # (_nValTit - _nVlAbat) .And. _nValCod > 0.00
			If !MsgBox("Valor do codigo de barras não confere com valor do titulo?"  +CRLF+;
					"Codigo Barras R$ "+ Transform(_nValCod           , "@E 999,999.99") +CRLF+;
					"Saldo Titulo  R$ "+ Transform(_nValTit - _nVlAbat, "@E 999,999.99"),"Confirma?","YesNo")
				lRet := .F.
			EndIf
		EndIf
		If _dFator # M->E2_VENCTO .And. _dFator # CtoD("07/10/1997") //Boleto sem registro, Quer dizer que fator de vencimento veio com 0000
			If !MsgBox("Vencimento do codigo de barras não confere com a vencimento do titulo?"  +CRLF+;
					"Vencimento do codigo de Barras "+ DtoC(_dFator) +CRLF+;
					"Vencimento do titulo "+DtoC(M->E2_VENCTO),"Confirma?","YesNo")
				lRet := .F.
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
RETURN(lRet)
	*
	*******************************************
User Function Pagcodbar(_Ccodbar,_Ctiporet)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
	*******************************************
	*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de variaveis utilizadas no programa atraves da funcao    ³
	//³ SetPrvt, que criara somente as variaveis definidas pelo usuario,    ³
	//³ identificando as variaveis publicas do sistema utilizadas no codigo ³
	//³ Incluido pelo assistente de conversao do AP5 IDE                    ³
	//* DENISE VIU - 24/01/2001
	//* LEITOR DE CODIGO DE BARRA DE VARIOS BANCOS
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetPrvt("_CTACED,_RETDIG,_DIG1,_DIG2,_DIG3,_DIG4")
	SetPrvt("_DIG5,_DIG6,_DIG7,_MULT,_RESUL,_RESTO")
	SetPrvt("_DIGITO,_CAGCED,_CDIGCTA,_CDIGAG,_CRET")

	/////  PROGRAMA PARA SEPARAR COM BASE NO CODIGO DE BARRA
	/////  OS CAMPOS BANCO DO CEDENTE
	/////            AGENCIA DO CEDENTE
	/////			 CONTA CORRENTE DO CEDENTE
	/////            DIGITO DA CONTA CORRENTE DO CEDENTE
	/////            DIGITO DA AGENCIA DO CEDENTE
	/////  DE VARIOS BANCOS

	_Cret   := SPACE(10)
	_Cagced := SPACE(4)
	_Cdigag := SPACE(3)
	_Ctaced := SPACE(12)
	_Cdigcta:= SPACE(4)
	_cBanco := SUBSTR(_Ccodbar,1,3)
	Do Case
	Case _cBanco == "237" 	// BRADESCO
		// Agencia-Digito do cedente
		_Cagced  := SUBSTR(_Ccodbar,20,4)

		_RETDIG := " "
		_DIG1   := SUBSTR(_Ccodbar,20,1)
		_DIG2   := SUBSTR(_Ccodbar,21,1)
		_DIG3   := SUBSTR(_Ccodbar,22,1)
		_DIG4   := SUBSTR(_Ccodbar,23,1)

		_MULT   := (VAL(_DIG1)*5) +  (VAL(_DIG2)*4) +  (VAL(_DIG3)*3) +   (VAL(_DIG4)*2)
		_RESUL  := INT(_MULT /11 )
		_RESTO  := INT(_MULT % 11)
		_DIGITO := STRZERO((11 - _RESTO),1,0)

		_RETDIG := IF( _resto == 0,"0",IF(_resto == 1,"P",_DIGITO))
		_Cdigag := _RETDIG

		// Conta-Digito do cedente
		_Ctaced  := SUBSTR(_Ccodbar,37,7)

		_RETDIG := " "
		_DIG1   := SUBSTR(_Ccodbar,37,1)
		_DIG2   := SUBSTR(_Ccodbar,38,1)
		_DIG3   := SUBSTR(_Ccodbar,39,1)
		_DIG4   := SUBSTR(_Ccodbar,40,1)
		_DIG5   := SUBSTR(_Ccodbar,41,1)
		_DIG6   := SUBSTR(_Ccodbar,42,1)
		_DIG7   := SUBSTR(_Ccodbar,43,1)

		_MULT   := (VAL(_DIG1)*2) +  (VAL(_DIG2)*7) +  (VAL(_DIG3)*6) +   (VAL(_DIG4)*5) +  (VAL(_DIG5)*4) +  (VAL(_DIG6)*3)  + (VAL(_DIG7)*2)
		_RESUL  := INT(_MULT /11 )
		_RESTO  := INT(_MULT % 11)
		_DIGITO := STRZERO((11 - _RESTO),1,0)

		_RETDIG := IF( _resto == 0,"0",IF(_resto == 1,"P",_DIGITO))
		_Cdigcta:= _RETDIG

	Case _cBanco == "341"		// ITAU
		// Agencia do cedente
		_Cagced  := SUBSTR(_Ccodbar,32,4)

		// Conta-Digito do cedente
		_Ctaced  :=  SUBSTR(_Ccodbar,36,5)
		_Cdigcta :=  SUBSTR(_Ccodbar,41,1)

	Case _cBanco == "275"		// REAL
		// Agencia do cedente
		_Cagced  := SUBSTR(_Ccodbar,20,4)

		// Conta-Digito do cedente
		_Ctaced  :=  SUBSTR(_Ccodbar,24,7)
		_Cdigcta :=  SUBSTR(_Ccodbar,31,1)

	Case _cBanco == "641"		// BBVA
		// Agencia do cedente
		_Cagced  := SUBSTR(_Ccodbar,35,4)

		// Conta do cedente
		_Ctaced  := SUBSTR(_Ccodbar,39,5)

	Case _cBanco == "409"		// UNIBANCO
		// Agencia-Digito do cedente
		_Cagced  := SUBSTR(_Ccodbar,28,4)
		_Cdigag  := SUBSTR(_Ccodbar,32,1)

	Case _cBanco == "001"		// BRASIL
		// Agencia do cedente
		_Cagced  := SUBSTR(_Ccodbar,31,4)

		// Conta do cedente
		_Ctaced  :=  SUBSTR(_Ccodbar,38,5)

	Case _cBanco == "392"		// FINASA  ???????????????
		// Conta-Digito do cedente
		_Ctaced  :=  SUBSTR(_Ccodbar,20,7)
		_Cdigcta :=  SUBSTR(_Ccodbar,27,1)

	Case _cBanco == "399"		// HSBC
		// Agencia do cedente
		_Cagced  := SUBSTR(_Ccodbar,31,4)

		// Conta do cedente
		_Ctaced  := SUBSTR(_Ccodbar,31,11)

	Case _cBanco == "320"		// BICBANCO
		// Agencia do cedente
		_Cagced  := SUBSTR(_Ccodbar,20,3)

		// Conta-Digito do cedente
		_Ctaced  := SUBSTR(_Ccodbar,23,8)
		_Cdigcta := SUBSTR(_Ccodbar,31,1)

	Case _cBanco == "291"		// BCN
		// Agencia do cedente
		_Cagced  := SUBSTR(_Ccodbar,19,4)

		// Conta-Digito do cedente
		_Ctaced  := SUBSTR(_Ccodbar,23,6)
		_Cdigcta := SUBSTR(_Ccodbar,29,1)

	Case _cBanco == "347"		// SUDAMERIS
		// Agencia do cedente
		_Cagced  := SUBSTR(_Ccodbar,20,3)

		// Conta-Digito do cedente
		_Ctaced  := SUBSTR(_Ccodbar,23,7)
		_Cdigcta := SUBSTR(_Ccodbar,30,1)

	Case _cBanco == "422"		// SAFRA
		// Agencia do cedente
		_Cagced  := SUBSTR(_Ccodbar,21,5)

		// Conta-Digito do cedente
		_Ctaced  := SUBSTR(_Ccodbar,26,8)
		_Cdigcta := SUBSTR(_Ccodbar,34,1)

	Case _cBanco == "453"		// BANCO RURAL   ??????????
		// Agencia-Digito do cedente
		_Cagced  := SUBSTR(_Ccodbar,20,4)
		_Cdigag  := SUBSTR(_Ccodbar,24,2)

		// Conta-Digito do cedente
		_Ctaced  :=  SUBSTR(_Ccodbar,26,7)
		_Cdigcta :=  SUBSTR(_Ccodbar,33,1)

	Case _cBanco == "244"		// BANCO CIDADE
		// Agencia do cedente
		_Cagced  := SUBSTR(_Ccodbar,20,3)

		// Conta-Digito do cedente
		_Ctaced  := SUBSTR(_Ccodbar,23,6)
		_Cdigcta := SUBSTR(_Ccodbar,29,1)

	Case _cBanco == "151"		// NOSSA CAIXA NOSSO BANCO
		// Agencia-Digito do cedente
		_Cagced  := SUBSTR(_Ccodbar,29,4)
		_Cdigag  := SUBSTR(_Ccodbar,33,1)

		// Conta do cedente
		_Ctaced  :=  SUBSTR(_Ccodbar,34,6)

	Case _cBanco == "033"		// BANESPA
		// Agencia-Digito do cedente
		_Cagced  := SUBSTR(_Ccodbar,20,3)
		_Cdigag  := SUBSTR(_Ccodbar,23,2)

		// Conta-Digito do cedente
		_Ctaced  :=  SUBSTR(_Ccodbar,25,5)
		_Cdigcta :=  SUBSTR(_Ccodbar,30,1)

	Case _cBanco == "104"		// CAIXA ECONOMICA FEDERAL
		// Agencia-Digito do cedente
		_Cagced  := SUBSTR(_Ccodbar,30,4)
		_Cdigag  := SUBSTR(_Ccodbar,34,3)

		// Conta do cedente
		_Ctaced  :=  SUBSTR(_Ccodbar,37,8)

	Case _cBanco == "611"		// BANCO PAULISTA
		// Agencia do cedente
		_Cagced  := SUBSTR(_Ccodbar,20,4)

		// Conta-Digito do cedente
		_Ctaced  :=  SUBSTR(_Ccodbar,24,9)
		_Cdigcta :=  SUBSTR(_Ccodbar,33,1)

	Case _cBanco == "389"		// MERCANTIL DO BRASIL
		// Agencia do cedente
		_Cagced  := SUBSTR(_Ccodbar,20,4)

		// Conta do cedente
		_Ctaced  := SUBSTR(_Ccodbar,35,9)

	Case _cBanco == "041"		// BANRISUL
		// Agencia do cedente
		_Cagced  := SUBSTR(_Ccodbar,22,3)

		// Conta do cedente
		_Ctaced  := SUBSTR(_Ccodbar,25,7)

	Case _cBanco == "353"		// BANCO SANTANDER
		// Conta-Digito do cedente
		_Ctaced  := SUBSTR(_Ccodbar,22,5)
		_Cdigcta := SUBSTR(_Ccodbar,27,1)

	Case _cBanco == "231"		// BANCO BOAVISTA
		// Agencia do cedente
		_Cagced  := SUBSTR(_Ccodbar,21,4)

		// Conta do cedente
		_Ctaced  := SUBSTR(_Ccodbar,25,8)

	Case _cBanco == "230"		// BANCO BANDEIRANTES
		// Agencia do cedente
		_Cagced  := SUBSTR(_Ccodbar,23,3)

		// Conta-Digito do cedente
		_Ctaced  :=  SUBSTR(_Ccodbar,26,4)
		_Cdigcta :=  SUBSTR(_Ccodbar,30,1)

	EndCase
	if _ctiporet == "AGE"			// agencia do cedente
		_cret := _Cagced
	elseif _ctiporet == "DAG"       // digito da agencia
		_cret := _Cdigag
	elseif _ctiporet == "CTA"       // conta corrente do cedente
		_cret := _Ctaced
	elseif _ctiporet == "DCT"       // digito da conta corrente
		_cret := _Cdigcta
	endif

	// Substituido pelo assistente de conversao do AP5 IDE em 26/09/00 ==> __return(_Ctaced)
Return(_cret)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00
	*
	**********************
USER FUNCTION ConvLD() // Função usada no gatilho do campo E2_CODBAR
	**********************
	*
	///--------------------------------------------------------------------------\
	//| Função: CONVLD				Autor: Flávio Novaes				Data: 19/10/2003 |
	//|--------------------------------------------------------------------------|
	//| Descrição: Função para Conversão da Representação Numérica do Código de  |
	//|            Barras - Linha Digitável (LD) em Código de Barras (CB).       |
	//|                                                                          |
	//|            Para utilização dessa Função, deve-se criar um Gatilho para o |
	//|            campo E2_CODBAR, Conta Domínio: E2_CODBAR, Tipo: Primário,    |
	//|            Regra: EXECBLOCK("CONVLD",.T.), Posiciona: Não.               |
	//|                                                                          |
	//|            Utilize também a Validação do Usuário para o Campo E2_CODBAR  |
	//|            EXECBLOCK("CODBAR",.T.) para Validar a LD ou o CB.            |
	//\--------------------------------------------------------------------------/

	SETPRVT("cStr")

	cStr := LTRIM(RTRIM(M->E2_CODBAR))

	IF VALTYPE(M->E2_CODBAR) == NIL .OR. EMPTY(M->E2_CODBAR)
		// Se o Campo está em Branco não Converte nada.
		cStr := ""
	ELSE
		// Se o Tamanho do String for menor que 44, completa com zeros até 47 dígitos. Isso é
		// necessário para Bloquetos que NÂO têm o vencimento e/ou o valor informados na LD.

		// cStr := IF(LEN(cStr)<44,cStr+REPL("0",47-LEN(cStr)),cStr) // Usado antes

		// Substituido por este IF
		IF Len(cStr)<44
			cStr1 := Left(cStr,33)
			cStr2 := Right(cStr,Len(cStr)-33)
			cStr := cStr1 + Replicate("0",47-Len(cStr)) + cStr2
		EndIf
	ENDIF

	DO CASE
	CASE LEN(cStr) == 47
		cStr := SUBSTR(cStr,1,4)+SUBSTR(cStr,33,15)+SUBSTR(cStr,5,5)+SUBSTR(cStr,11,10)+SUBSTR(cStr,22,10)
	CASE LEN(cStr) == 48
		cStr := SUBSTR(cStr,1,11)+SUBSTR(cStr,13,11)+SUBSTR(cStr,25,11)+SUBSTR(cStr,37,11)
	OTHERWISE
		cStr := cStr+SPACE(48-LEN(cStr))
	ENDCASE

RETURN(cStr)

	*
	**********************
User Function Pagval() // Função revisada //Valor do Documento
	**********************
	*
	// VALOR DO DOCUMENTO  DO CODIGO DE BARRA DA POSICAO 06 - 19, NO ARQUIVO E
	// DA POSICAO 190 - 204, QUANDO NAO FOR CODIGO DE BARRA VAI O VALOR DO SE2

	// | Deve ser informado o valor constante do código de barras ou da Linha Digitável,           |
	// | inclusive, se o valor for igual a zero, independente do valor a ser pago. Obrigatório     |
	SetPrvt("_VALOR,")
	_VALOR :=Replicate("0",10)
	If !Empty(SE2->E2_CODBAR)
		_VALOR  :=  SUBSTR(SE2->E2_CODBAR,10,10)
	Endif
Return(_VALOR)        // incluido pelo assistente de conversao do AP5 IDE em 26/09/00

	*
	***********************
User Function PagaVlr() // Função revisada //Valor do pagamento
	***********************
	*
	// |Deve ser igual ao valor do documento, menos o Valor do Desconto ou mais Acréscimo, se houver. |
	// |Se o Valor do documento (195 à 204) for zero, deverá ser informado o valor do pagamento.      |
	// |Obrigatório                                                                                   |

	_aArea := GetArea()
	DbSelectArea("SE2")
	_aAreaE2 := SE2->(GetArea())
	nVlAbat := SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,,SE2->E2_FORNECE,SE2->E2_LOJA)
	RestArea(_aAreaE2)
	RestArea(_aArea)

Return(SE2->E2_SALDO-SE2->E2_DECRESC+SE2->E2_ACRESC-nVlAbat)

	*
	************************
User Function CalcDesc() // VALOR DESCONTO Antes era StrZero(SE2->E2_DECRESC*100,15)
	************************
	*
	//| Deve ser igual ao Valor do Documento, menos o Valor do Pagamento, |
	//| exceto se o Valor do Documento for igual a zeros. Obrigatório     |

	//| Utilizado também para o campo DATA LIMITE que era STRZERO(0,9)    |
	//| E é obrigatório, quando informado valor do Desconto               |

	Local nValDoc := Val(U_PagVal())/100  // A função retorna Caracter de 15 posições
	Local nValPag := U_PagaVlr()          // A função retorna Numerico

	If nValDoc > 0
		cRet := StrZero( Abs(nValDoc - nValPag) * 100, 15 )
	Else
		cRet := Replicate("0",15)
	EndIf

Return(cRet)

	*
	************************
User Function CalcVenc() //Antes era DTOS(SE2->E2_VENCREA) -  Posição 266 a 273
	************************
	*
	//| Retorna data efetiva para pagamento com base no fator de vencimento |

	Local dBase  := CtoD("07/10/1997")          // Data base para calculo do fator de vencimento
	Local cFator := SUBSTR(SE2->E2_CODBAR,6,4)  // Fator de vencimento
	Local cRet   := DTOS(SE2->E2_VENCREA)

	If !Empty(cFator)
		cRet:= DtoS(dBase + Val(cFator))
	EndIf

Return(cRet)
