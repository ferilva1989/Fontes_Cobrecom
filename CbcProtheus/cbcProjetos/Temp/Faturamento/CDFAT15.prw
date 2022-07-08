/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CDFAT15  ºAutor  ³Roberto Oliveira    º Data ³  17/16/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Adicionais de Desconto                                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico IFC                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CDFAT15()

	If Alltrim(cUserName)+"|" $ GetMv("MV_USERLIB")+GetMv("MV_USERADM")
		aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
		{ "Visualizar", "AxVisual", 0 , 2	},;
		{ "Incluir"   , "u_IncAltZW(1)", 0 , 3	},;
		{ "Alterar"   , "u_IncAltZW(2)", 0 , 4	},;
		{ "Excluir"   , "AxDeleta", 0 , 5	}}
	Else
		aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
		{ "Visualizar", "AxVisual", 0 , 2	}}
	EndIf	                                         
	cCadastro := "Adicionais de Desconto"
	DbSelectArea("SZW")
	DbSetOrder(1) // ZW_FILIAL+ZW_TABELA+ZW_CARTA+ZW_REGIAO+ZW_FAMILIA
	DbSeek(xFilial("SZW"),.T.)
	mBrowse(001,040,200,390,"SZW",,,,,,)
	Return(.T.)
	*
	*
	****************************
User Function IncAltZW(nRot)
	****************************
	*
	If nRot == 1 // Inclusao
		nOpca := AxInclui("SZW",0,3, , , ,)
	Else
		nOpca := AxAltera("SZW",Recno(),4, , , ,)
	EndIf
	If nOpca == 1
		/*/
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
		/*/
	EndIf
Return(.T.)