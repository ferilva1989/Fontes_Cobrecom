/*/{Protheus.doc} CDFAT14
@author legado
@since 24/07/2017
@version 0.0
@type function
@description Carta de Descontos a ser aplicado ao pedido de venda
/*/
User Function CDFAT14()

	If Alltrim(cUserName)+"|" $ GetMv("MV_USERLIB")+GetMv("MV_USERADM")
		aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
		{ "Visualizar", "AxVisual", 0 , 2	},;
		{ "Incluir"   , "u_IncAltZY(1)", 0 , 3	},;
		{ "Alterar"   , "u_IncAltZY(2)", 0 , 4	},;
		{ "Excluir"   , "AxDeleta", 0 , 5	}}
	Else
		aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
		{ "Visualizar", "AxVisual", 0 , 2	}}
	EndIf	                                         
	cCadastro := "Cartas de Desconto"
	DbSelectArea("SZY")
	DbSetOrder(1) // ZY_FILIAL+ZY_CODIGO+ZY_ITEM
	DbSeek(xFilial("SZY"),.T.)
	mBrowse(001,040,200,390,"SZY",,,,,,)
Return(.T.)

User Function IncAltZY(nRot)

	If nRot == 1 // Inclusao
		nOpca := AxInclui("SZY",0,3, , , ,)
	Else
		nOpca := AxAltera("SZY",Recno(),4, , , ,)
	EndIf
	If nOpca == 1
		aAreaZY := GetArea()
		_ZY_CMMIN   := SZY->ZY_CMMIN
		_ZY_DESCPAD := SZY->ZY_DESCPAD    
		_ZY_CODIGO  := SZY->ZY_CODIGO

		DbSelectArea("SZY")
		DbSetOrder(1) //ZY_FILIAL+ZY_CODIGO+ZY_ITEM
		DbSeek(xFilial("SZY")+_ZY_CODIGO,.F.)
		Do While SZY->ZY_FILIAL == xFilial("SZY") .And. SZY->ZY_CODIGO == _ZY_CODIGO .And. SZY->(!Eof())
			RecLock("SZY",.F.)
			SZY->ZY_CMMIN   := _ZY_CMMIN
			SZY->ZY_DESCPAD := _ZY_DESCPAD
			MsUnLock()
			SZY->(DbSkip())
		EndDo
		RestArea(aAreaZY)
	EndIf
Return(.T.)

User Function CacDir(_ZY_DESCONT)

	// Calcula o desconto direto conforme o desconto em cascata
	_Vari := AllTrim(_ZY_DESCONT)+"Z" // Tem que colocar um caracter (não pode ser número) no final, senão não calcula
	_ValBase := 100
	_nPerc := ""
	For _xc := 1 to Len(_Vari)
		If Substr(_Vari,_xc,1) $ "1234567890"
			_nPerc := _nPerc + Substr(_Vari,_xc,1)
		ElseIf Substr(_Vari,_xc,1) == ","
			_nPerc := _nPerc + "."
		Else      
			_nPerc   := Val(_nPerc)
			_nDscAtu := Round((_ValBase * _nPerc) / 100,4)
			_ValBase := _ValBase - _nDscAtu
			_nPerc := ""
		EndIf
	Next
Return(Round((100-_ValBase),2))

User Function ConfMCm()
	_aArea := GetArea()
	_ZY_ITEM   := Space(Len(SZY->ZY_ITEM))
	_ZY_ITEMATU := If(Inclui,_ZY_ITEM,SZY->ZY_ITEM)
	_ZY_COMIS := 100
	DbSelectArea("SZY")
	DbSetOrder(1) //ZY_FILIAL+ZY_CODIGO+ZY_ITEM
	DbSeek(xFilial("SZY")+M->ZY_CODIGO,.F.)
	Do While SZY->ZY_FILIAL == xFilial("SZY") .And. SZY->ZY_CODIGO == M->ZY_CODIGO .And. SZY->(!Eof())
		If SZY->ZY_COMIS < _ZY_COMIS .And. SZY->ZY_ITEM # _ZY_ITEMATU .And. SZY->ZY_COMIS > 0
			_ZY_COMIS := SZY->ZY_COMIS    
			_ZY_ITEM  := SZY->ZY_ITEM
		EndIf
		SZY->(DbSkip())
	EndDo      
	RestArea(_aArea) 
	If M->ZY_CMMIN > _ZY_COMIS
		Alert("O Item  " + _ZY_ITEM + " está com Comissão de " + Transform(_ZY_COMIS,"@E 99.99"))
		Return(.F.)
	EndIf
Return(.T.)
