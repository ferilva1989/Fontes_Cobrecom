#include "rwmake.ch"
#include "protheus.ch"

/*/{Protheus.doc} CDFINA12
@author legado
@since 24/07/2017
@version 0.0
@type function
@description Alerta ao usuário da Tabela de Preço
Este fonte possui funções de validação de tabela de preços no cadastro do cliente
e no cadastro do cabeçalho do Pedido de Venda, sendo que se tiver uma tabela de preços 
no cadastro do cliente usar essa tabela, senão, usar a tabela no cadastro do vendedor. 
Se não tiver tabela no cadastro do vendedor não aceitar o vendedor.
/*/
User Function CDFINA12()

	If !Empty(M->A1_TABELA)
		MsgAlert("Somete usar tabela de preço no cadastro do clientes" +Chr(13) + ;
		"quando este utilizar uma tabela de preços específica," +Chr(13) + ;
		"pois a tabela de preços padrão está informada no cadastro de vendedores","Atenção!")
	EndIf
Return(.T.)


User Function cbcBustab(_cTabe,_lAcheTab) // cbcBustab -> Buscatab

	Local _cTabela
	Local _cTbPrec
	Local _cCliAtu
	Local _cLojAtu
	Local _cVenAtu
	Local _cCpo
	Local _cValid
	Local _nForma
	local _cVarejo
	
	Default _cTabe := "SC5"
	Default _lAcheTab := .T.

	If _cTabe == "SC5"
		_cTbPrec := M->C5_TABELA
		_cTabela := M->C5_TABELA
		_cCliAtu := M->C5_CLIENTE
		_cLojAtu := M->C5_LOJACLI
		_cVenAtu := M->C5_VEND1
		_cVarejo := M->(C5_ZTPVEND)
	ElseIf _cTabe == "SCJ"
		_cTbPrec := M->CJ_TABELA
		_cTabela := M->CJ_TABELA
		_cCliAtu := M->CJ_CLIENTE
		_cLojAtu := M->CJ_LOJA
		_cVenAtu := M->CJ_VEND1
		_cVarejo := M->(CJ_ZTPVEND)
	EndIf

	If _lAcheTab
		_cTabela := Space(Len(_cTbPrec))	
		if _cVarejo == 'V'
			_cTabela := Padr( GetNewPar('XX_VARTAB', '12'), TamSx3('A1_TABELA')[1] )
		else
			If !Empty(_cCliAtu) .And. ! Empty(_cLojAtu)
				DbSelectArea("SA1")
				DbSetOrder(1)
				If DbSeek(xFilial("SA1") + _cCliAtu+_cLojAtu,.F.)
					_cTabela := SA1->A1_TABELA
					If Upper(AllTrim(__ReadVar)) $ "M->C5_CLIENTE//M->C5_LOJACLI//M->CJ_CLIENTE//M->CJ_LOJA"
						_cVenAtu := SA1->A1_VEND
					EndIf
				EndIf
			EndIf
			If Empty(_cTabela) .And. !Empty(_cVenAtu)
				DbSelectArea("SA3")
				If DbSeek(xFilial("SA3")+_cVenAtu,.F.)
					_cTabela := SA3->A3_TABELA
					If _cTabe == "SCJ"
						M->CJ_NOMVEN := SA3->A3_NOME
					EndIf
				EndIf
			EndIf            
			If Empty(_cTabela) .And. "_TABELA" $ AllTrim(ReadVar())
				_cTabela := If(_cTabe == "SC5",M->C5_TABELA,M->CJ_TABELA)
			EndIf
	
			If _cTabe == "SC5"          
				_cCpo := "C5_TABELA"
				M->C5_TABELA := _cTabela
				_nForma := 1 // Pedido de venda usa Getdados
			ElseIf _cTabe == "SCJ"
				_cCpo := "CJ_TABELA"
				M->CJ_TABELA := _cTabela
				_nForma := 2 // Orçamento Usa GetDb
				If Inclui .And. !Empty(M->CJ_TABELA)
					M->CJ_DESCPAD := u_DescPad(M->CJ_TABELA)
				EndIf
			EndIf      
	
			// Executa Validação do campo, se tiver
			SX3->(DbSetOrder(2))
			SX3->(DbSeek(_cCpo))
			_cValid := Upper(AllTrim(SX3->X3_VALID))
			If !Empty(_cValid)
				_lVoltaVld := &(_cValid)
			EndIf
		Endif   
	EndIf

	If _cTabe == "SCJ" .And. Type("oGetDB") <> "U"
		oGetDB:oBrowse:Refresh()
	EndIf
Return(_cTabela)

User Function DescPad(_TABELA)

	SZX->(DbSetOrder(2)) //ZX_FILIAL+ZX_CODTAB
	SZX->(DbSeek(xFilial("SZX")+_TABELA,.F.))

	SZY->(DbSetOrder(1)) // ZY_FILIAL+ZY_CODIGO+ZY_ITEM
	SZY->(DbSeek(xFilial("SZY")+SZX->ZX_CARTA,.F.))
Return(SZY->ZY_DESCPAD)
