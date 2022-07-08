#Include 'Protheus.ch'


/*/{Protheus.doc} CDGEN01
@type function
@author legado
@since 27/02/2018
@version 1.0
@description Função para cadastro de familias de produto (ZP1)
/*/
user function CDGEN01()
	aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
		{ "Visualizar", "AxVisual", 0 , 2	},;
		{ "Incluir"   , "AxInclui", 0 , 3	},;
		{ "Alterar"   , "AxAltera", 0 , 4	},;
		{ "Excluir"   , "U_DelFun", 0 , 5	}}

	cCadastro := "Nomes dos Produtos"
	DbSelectArea("SZ1")
	DbSetOrder(1)
	DbSeek(xFilial("SZ1"))

	mBrowse(001,040,200,390,"SZ1",,,,,,)
return(.T.)


/*/{Protheus.doc} CDGEN02
@type function
@author legado
@since 27/02/2018
@version 1.0
@description Função para cadastro de bitolas de produto (ZP2)
/*/
user function CDGEN02()
	aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
		{ "Visualizar", "AxVisual", 0 , 2	},;
		{ "Incluir"   , "AxInclui", 0 , 3	},;
		{ "Alterar"   , "AxAltera", 0 , 4	}}

	cCadastro := "Bitolas dos Produtos"
	DbSelectArea("SZ2")
	DbSetOrder(1)
	DbSeek(xFilial("SZ2"))
	mBrowse(001,040,200,390,"SZ2",,,,,,)
return(.T.)


/*/{Protheus.doc} CDGEN03
@type function
@author legado
@since 27/02/2018
@version 1.0
@description Função para cadastro de Cores de produto (ZP3)
/*/
user function CDGEN03()

	aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
		{ "Visualizar", "AxVisual", 0 , 2	},;
		{ "Incluir"   , "AxInclui", 0 , 3	},;
		{ "Alterar"   , "AxAltera", 0 , 4	}}

	cCadastro := "Cores dos Produtos"
	DbSelectArea("SZ3")
	DbSetOrder(1)
	DbSeek(xFilial("SZ3"))

	mBrowse(001,040,200,390,"SZ3",,,,,,)

return(.T.)


/*/{Protheus.doc} CDGEN04
@type function
@author legado
@since 27/02/2018
@version 1.0
@description Função para cadastro de Especialidades de produto (ZP4)
/*/
user function CDGEN04()

	aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
		{ "Visualizar", "AxVisual", 0 , 2	},;
		{ "Incluir"   , "AxInclui", 0 , 3	},;
		{ "Alterar"   , "AxAltera", 0 , 4	}}

	cCadastro := "Especialidades dos Produtos"
	DbSelectArea("SZ4")
	DbSetOrder(1)
	DbSeek(xFilial("SZ4"))

	mBrowse(001,040,200,390,"SZ4",,,,,,)

return(.T.)


/*/{Protheus.doc} ConfCdImp
//TODO Descrição auto-gerada.
@author legado!!!
@since 20/03/2018
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
User Function ConfCdImp()

	If Upper(Right(AllTrim(M->B1_COD),1)) == "I"
		Alert("Não Use Códigos Terminados com 'I' - Reservado para Produtos Importados")
		Return(.F.)
	EndIf
Return(.T.)



/*/{Protheus.doc} ConfCdBar
//TODO Descrição auto-gerada.
@author Legado!!!
@since 20/03/2018
@version 1.0
@return ${return}, ${return_description}
@param _CODBAR, , descricao
@type function
/*/
User Function ConfCdBar(_CODBAR)
	// Atenção.. Se liberar o uso de algum cód de barras verificar
	// se não infuencia na função TpBarras.

	If Substr(_CODBAR,10,3) == "950" .Or. Substr(_CODBAR,10,2) $ "97/96"
		Alert("Para uso desse código contatar o administrador do sistema")
		Return(.F.)
	EndIf
Return(.T.)



/*/{Protheus.doc} TpBarras
//TODO Descrição auto-gerada.
@author Legado!!!
@since 20/03/2018
@version 1.0
@return ${return}, ${return_description}
@param _Codbar, , descricao
@type function
/*/
User Function TpBarras(_Codbar)
	_cVolta := "?"
	If Left(_Codbar,5) == "95000" // Bobina do ESA
		_cVolta := "E"
	ElseIf Left(_Codbar,2) == "96" .Or. (Left(_Codbar,4) == "8000" .And. Substr(_Codbar,6,1) == "0") // Bobina do EPA
		_cVolta := "P"
	ElseIf Left(_Codbar,2) == "97" // Etiqueta da Sacaria
		_cVolta := "S"
	Else // Só Sobrou "rolos"
		_cVolta := "R"
	EndIf
Return(_cVolta)



/*/{Protheus.doc} DelFun
@type function
@author legado
@since 27/02/2018
@version 1.0
@description Função para deletar familias de produto (ZP1)
/*/
user function DelFun()
	nOpca   := AxDeleta("SZ1",Recno(),5,,,)
return(.T.)