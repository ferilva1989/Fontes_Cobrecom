#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"

*
************************
User Function fValidE4()
	************************
	*
	// Função chamada pelo SX3 X3_VLDUSER
	Local aArea   := GetArea()
	Local aAreaE4

	DbSelectArea("SE4")
	aAreaE4 := GetArea()

	DbOrderNickName("SE4CONDIC") //E4_FILIAL + E4_COND + E4_TIPO
	If dbSeek(xFilial("SE4")+M->E4_COND+M->E4_TIPO,.F.)
		Alert("Está condição de pagamento já existe !!!")
		Return(.F.)
	EndIf

	RestArea(aAreaE4)
	RestArea(aArea)

	Return(.T.)

	*
	************************
User Function fValidD3()
	************************
	*
	// Função chamada pelo SX3 X3_VLDUSER               
	Local _nModelo   := IIf(Type("aCols") # "U", 2,1)
	Local _cCampo    := Alltrim(__ReadVar)
	
	If FWCodEmp()+FWCodFil() == "0101" /// Cobrecom Matriz

		_nModelo   := IIf(Type("aCols") # "U", 2,1)
		_cCampo    := Alltrim(__ReadVar)

		_nRot := 1
		Do While .T.
			_cRotina := ProcName(_nRot++)
			If Empty(_cRotina) .Or. "MATA250" $ _cRotina // Acabou ou é a Rotina de Produção
				Exit
			EndIf
		EndDo

		If "MATA250" $ _cRotina // É a Rotina de Produção
			Return(.T.)
		EndIf

		// Chamada pela EXECAUTO retorna .T.   OU  Retorna .T. por passar 2 vezes na função
		If Type("aRotAuto") # "U" .Or. (Type("M->D3_TM") == "U" .And.  !"D3_LOCAL" $ __ReadVar) .And. !Empty(__ReadVar)
			Return(.T.)
		EndIf

		SF5->(dbSetOrder(1))
		If _nModelo == 1
			SF5->(dbSeek(xFilial("SF5")+M->D3_TM,.F.))
			If _cCampo == "M->D3_TM"
				//Verifico se movimento pode ser utilizado
				If SF5->F5_MANUAL == "N" // SF5->F5_MANUAL INDICA SE O MOVIMENTO SERÁ MANUAL OU NÃO (AUTOMÁTICO)
					Alert("Tipo de Movimentação não permitido")
					Return(.F.)
				EndIf
				//E se existir local, se é possivel utiliza-lo ?
				If Type("M->D3_LOCAL") # "U"
					If !Empty(SF5->F5_LOCAL) .And. !Empty(M->D3_LOCAL) .And. SF5->F5_LOCAL # M->D3_LOCAL
						Alert("Movimentação não permitida para este local.")
						Return(.F.)
					EndIf
				EndIf
			Else
				// Se entrar nesta condição só preciso ver local
				If Type("M->D3_LOCAL") # "U"
					If !Empty(SF5->F5_LOCAL) .And. !Empty(M->D3_LOCAL) .And. SF5->F5_LOCAL # M->D3_LOCAL
						Alert("Local não permitido")
						Return(.F.)
					EndIf
				EndIf
			EndIf
		Else
			SF5->(dbSeek(xFilial("SF5")+cTm,.F.))
			If _cCampo == "cTm" .Or. Empty(_cCampo)
				//Verifico se movimento pode ser utilizado
				If SF5->F5_MANUAL == "N" // SF5->F5_MANUAL INDICA SE O MOVIMENTO SERÁ MANUAL OU NÃO (AUTOMÁTICO)
					Alert("Tipo de Movimentação não permitido")
					Return(.F.)
				EndIf

				If !Empty(SF5->F5_LOCAL)
					For _n := 1 to Len(aCols)
						If !GDDeleted(_n)
							_cLocal := GDFieldGet("D3_LOCAL",_n)
							If !Empty(_cLocal) .And. SF5->F5_LOCAL # _cLocal
								Alert("Movimentação não permitida para este local.")
								Return(.F.)
							EndIf
						EndIf
					Next
				EndIf
			ElseIf !Empty(SF5->F5_LOCAL) .And. !Empty(M->D3_LOCAL) .And. SF5->F5_LOCAL # M->D3_LOCAL
				Alert("Movimentação não permitida para este local.")
				Return(.F.)
			EndIf
		EndIf
	EndIf

	Return(.T.)

	*
	**************************************
User Function fDescLocaliz(BF_LOCALIZ)
	**************************************
	*
	//Chamado via X3 da tabela SBF.
	cLocaliz:= ""
	Do Case
		Case Left(BF_LOCALIZ,3) =="RTB"
		cLocaliz :="Retrabalho"
		Case Left(BF_LOCALIZ,1) =="R"
		cLocaliz :="Rolo"
		Case Left(BF_LOCALIZ,1) =="C"
		cLocaliz :="Carretel"
		Case Left(BF_LOCALIZ,1) =="M"
		cLocaliz :="Carr. Madeira"
		Case Left(BF_LOCALIZ,1) =="B"
		cLocaliz :="Bobina"
		Case Left(BF_LOCALIZ,1) =="T"
		cLocaliz :="Retalho"
		Case Left(BF_LOCALIZ,1) =="L"
		cLocaliz :="Blister"
	EndCase

Return(cLocaliz)
