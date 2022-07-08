#include "rwmake.ch"

/*/{Protheus.doc} CDBAL02
//TODO Descrição auto-gerada.
@author Roberto
@since 26/03/2010
@version undefined

@type function
/*/
User Function CDBAL02()
	aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
				{ "Visualizar", "AxVisual", 0 , 2	},;
				{ "Incluir"   , "AxInclui", 0 , 3	},;
				{ "Alterar"   , "AxAltera", 0 , 4	}}
	
	cCadastro := "Usuários da Balança"
	DbSelectArea("SZS")
	DbSetOrder(1)
	DbSeek(xFilial("SZS"))
	
	mBrowse(001,040,200,390,"SZS",,,,,,)
Return(.T.)