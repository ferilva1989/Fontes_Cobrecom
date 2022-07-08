#INCLUDE "RWMAKE.CH"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CDFINA150 º Autor ³ Roberto Oliveira    º Data ³  28/01/13 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funções utilizadas na geração do CNAB receber              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºMotivo    ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/   
*
*****************************
User  Function MyMod11(cBase)
	*****************************
	*                           
	cBase := AllTrim(cBase)
	_nSoma := 0
	_nMult := 7 // Para começar com 2
	For _nAtu := Len(cBase) to 1 Step -1
		If ++_nMult == 8
			_nMult := 2
		EndIf  
		_nSoma += (Val(Substr(cBase,_nAtu,1)) * _nMult)
	Next
	_nDigito := 11 - (_nSoma % 11)
	If _nDigito == 11
		_nDigito := "0"
	ElseIf _nDigito == 10
		_nDigito := "P"
	Else       
		_nDigito := Str(_nDigito,1)
	EndIf
	Return(_nDigito)
	*
	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Fun‡…o    ³ NossoNum ³ Autor ³ Paulo Boschetti       ³ Data ³ 05/11/93 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Descri‡…o ³ Retorna digito de controle                                 ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³Sintaxe   ³ 		                                                     ³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
	±±³ Uso      ³ Generico                                                   ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/                 
	************************
User Function MyNsoNum()
	************************

	Local cNumero := ""
	Local nTam := Len(AllTrim(SEE->EE_FAXATU))

	// Enquanto nao conseguir criar o semaforo, indica que outro usuario
	// esta tentando gerar o nosso numero.
	cNumero := StrZero(Val(SEE->EE_FAXATU),nTam)

	While !MayIUseCode(SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))  //verifica se esta na memoria, sendo usado
		cNumero := Soma1(cNumero)										// busca o proximo numero disponivel 
	EndDo

	If Empty(SE1->E1_NUMBCO)
		RecLock("SE1",.F.)
		Replace SE1->E1_NUMBCO With cNumero
		SE1->(MsUnlock())

		RecLock("SEE",.F.)
		Replace SEE->EE_FAXATU With Soma1(cNumero, nTam)
		SEE->(MsUnlock())
	EndIf	
	Leave1Code(SEE->(EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA))
	DbSelectArea("SE1")
	Return(SE1->E1_NUMBCO)
	*
	************************
User Function F150ICNB()
	************************
	*
	// Função para validação do campo E1_IDCNAB pois tem ocorrido duplicidade na tabela
	_cIdCnab := PARAMIXB[1]

	_aOrdNow := GetArea()
	dbSelectArea("SE1")
	_aOrdSE1 := SE1->(GetArea())

	DbSetOrder(19)
	DbSeek(_cIdCnab,.F.)
	If !SE1->(Eof())
		DbSkip()
		If SE1->E1_IDCNAB == _cIdCnab .And. !SE1->(Eof())
			// Tem outro cara com o mesmo IDCNAB
			// Gera identificador do registro CNAB no titulo enviado
			DbSelectArea("SE1")
			DbSetOrder(19) // E1_IDCNAB // Este indice não tem campo filial no inicio
			Do While DbSeek(_cIdCnab,.F.)
				_cIdCnab := GetSxENum("SE1","E1_IDCNAB","E1_IDCNAB"+cEmpAnt,19)
				ConfirmSx8()
				DbSelectArea("SE1")
				DbSetOrder(19) // E1_IDCNAB // Este indice não tem  campo filial no inicio
			EndDo
		EndIf
	EndIf

	RestArea(_aOrdSE1)
	RestArea(_aOrdNow)
Return(_cIdCnab)