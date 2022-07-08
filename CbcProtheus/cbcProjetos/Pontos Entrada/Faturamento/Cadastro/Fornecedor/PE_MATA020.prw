#INCLUDE "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATA020  � Autor � Roberto Oliveira      � Data �          ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Pontos de Entrada do programa MATA020.                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �     														  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
/*/

User Function CriaItContab()
	Local _aArea 		:= GetArea()
	Local aDados 		:= {}
	Local dData  		:= ctod("01/01/80")
	Local cItem 		:= ""
	Local lMsErroAuto 	:= .F.
	Local lMsHelpAuto 	:= .T.

	cItem := Alltrim("F"+SA2->(A2_COD+A2_LOJA))

	aadd(aDados,{"CTD_ITEM"    	,cItem 		,Nil})
	aadd(aDados,{"CTD_DESC01"   ,SA2->A2_NOME ,Nil})
	aadd(aDados,{"CTD_CLASSE"   ,"2"			,Nil})
	aadd(aDados,{"CTD_NORMAL"   ,"1"			,Nil})
	aadd(aDados,{"CTD_DTEXIS"   ,dData 		,Nil})
	aadd(aDados,{"CTD_ITSUP"   	,"F"			,Nil})

	MSExecAuto({|x,y| CTBA040(x,y)},aDados,3)

	If lMsErroAuto
		Alert("Erro na inclus�o do Item Contabil")
	Else
		M->A2_ZZITEM := Padr(cItem,TamSX3("A2_ZZITEM")[1])
	EndIf
Return(!lMsErroAuto)

/*/{Protheus.doc} MA020ALT
//TODO Cria Item Contabil na altera��o dos fornecedores.
@author juliana.leme
@since 07/08/2017
@version 1.0

@type function
/*/
User Function MA020ALT()
	If Empty(Alltrim(SA2->A2_ZZITEM))
		U_CriaItContab()
	EndIf
Return (.T.)

/*/{Protheus.doc} MA020TOK
//TODO Cria Item Contabil na inclus�o.
@author juliana.leme
@since 07/08/2017
@version 1.0

@type function
/*/
User Function MA020TOK()
	If Empty(Alltrim(SA2->A2_ZZITEM))
		U_CriaItContab()
	EndIf
Return (.T.)

User Function M020Exc //EXCLUS�O FORNECEDORES
	Local _aArea := GetArea()
	Local aDados := {}
	Local dData  := ctod("01/01/80")
	Local cItem := ""
	Local lMsErroAuto := .F.
	Local lMsHelpAuto := .T.

	cItem := Alltrim("F"+SA2->(A2_COD+A2_LOJA))

	aadd(aDados,{"CTD_ITEM"    	,cItem 		,Nil})
	aadd(aDados,{"CTD_DESC01"   ,SA2->A2_NOME ,Nil})
	aadd(aDados,{"CTD_CLASSE"   ,"2"			,Nil})
	aadd(aDados,{"CTD_NORMAL"   ,"1"			,Nil})
	aadd(aDados,{"CTD_DTEXIS"   ,dData 		,Nil})
	aadd(aDados,{"CTD_ITSUP"   	,"F"			,Nil})

	Begin Transaction
		MSExecAuto({|x,y| CTBA040(x,y)},aDados,5)

		If lMsErroAuto
			DisarmTransaction()
			break
		EndIf

	End Transaction
Return


/*/{Protheus.doc} CDMA20Obrig
//TODO Fun��o desenvolvida em 23/02/15 por Roberto Oliveira para tratar campos obrigat�rios na
		inclus�o de Fornecedores do exterior CEP e Inscr. Estadual.
@author Roberto Oliveira
@since 23/02/15
@version 1.0

@type function
/*/
User Function CDMA20Obrig()
	Local _nGet
	Local _nTamGet
	Local _nCEP := 0
	Local _nInscr := 0

	Return(.T.) // Para n�o interferir na produ��o pois a fun��o est� no sx3

	_Volta := .T.
	For _nGet := 1 to Len(aGets)
		If "A2_CEP"$ aGets[_nGet]
			_nCEP := _nGet
		ElseIf "A2_INSCR"$ aGets[_nGet]
			_nInscr := _nGet
		EndIf
		If _nCEP > 0 .And. _nInscr > 0
			Exit
		EndIf
	Next
	If !(M->A2_PAIS $ "   /105") .Or. M->A2_TIPO # "J"
		_nTamGet := Len(aGets[_nCEP])
		aGets[_nCEP] := Left(aGets[_nCEP],24) + "F" + Right(aGets[_nCEP],_nTamGet-25)

		_nTamGet := Len(aGets[_nInscr])
		aGets[_nInscr] := Left(aGets[_nInscr],24) + "F" + Right(aGets[_nInscr],_nTamGet-25)
	Else
		_nTamGet := Len(aGets[_nCEP])
		aGets[_nCEP] := Left(aGets[_nCEP],24) + "T" + Right(aGets[_nCEP],_nTamGet-25)

		_nTamGet := Len(aGets[_nInscr])
		aGets[_nInscr] := Left(aGets[_nInscr],24) + "T" + Right(aGets[_nInscr],_nTamGet-25)
	EndIf
Return(_Volta)