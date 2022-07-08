#include "protheus.ch"
#include "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDGEN21                            Modulo : SIGAEST/FAT  //
//                                                                          //
//   Autor ......: Roberto F. de Oliveira             Data ..: 26/02/2014   //
//                                                                          //
//   Objetivo ...: Cadastro de Ocorrências nos Pedidos de Vendas            //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
*
***********************
User Function CDGEN21()
***********************
*
aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
			{ "Visualizar", "AxVisual", 0 , 2	},;
			{ "Incluir"   , "AxInclui", 0 , 3	},;
			{ "Alterar"   , "AxAltera", 0 , 4	}}
//			{ "Excluir"   , "U_DelFun", 0 , 5	}}

cCadastro := "Ocorrências dos Pedidos de Vendas"
DbSelectArea("ZZI")
DbSetOrder(1) //ZZI_FILIAL+DTOS(ZZI_DATA)+ZZI_HORA+ZZI_PEDIDO+ZZI_ITEMPV
DbSeek(xFilial("ZZI"))

mBrowse(001,040,200,390,"ZZI",,,,,,)

Return(.T.)
*
***********************************************
User Function HistPed(_cPedido,_cLoja,_lPedido)
***********************************************
*
Local aButtons := {}

DEFAULT _cPedido := "      "
DEFAULT _cLoja   := "  "
DEFAULT _lPedido := .T.

_aArea := GetArea()

If !_lPedido
	// A variável _cPedido na verdade tem um código de cliente e não um nro de pedido
	// então estou na rotina de analise de credito por cliente
	_cCodCli := _cPedido
	_cPedido := "ZZZZZZ"
	_cPedPED := ""
	DbSelectArea("PED") // tabela de trabalho na ordem C5_CLIENTE+C5_LOJACLI+C5_NUM
	_aAreaPED := GetArea()
	DbSeek(_cCodCli+_cLoja,.F.)
	Do While PED->C5_CLIENTE+PED->C5_LOJACLI == _cCodCli+_cLoja .And. PED->(!Eof())
		If !PED->C5_NUM $ _cPedPED
			_cPedPED := _cPedPED + "//" + PED->C5_NUM
		EndIf
		//_cPedido := Min(_cPedido,PED->C5_NUM)
		// Linha substituida... na nova build a função Min está dando erro
		// By Roberto Oliveira - 06/02/15 - Email do Bittar
		_cPedido := If((PED->C5_NUM<_cPedido),PED->C5_NUM,_cPedido)
		PED->(DbSkip())
	EndDo
	RestArea(_aAreaPED)
	DbSelectArea("ZZI")
	Set Filter to ZZI_PEDIDO $ _cPedido
EndIf

DbSelectArea("SX3")
_aAreaX3 := GetArea()
DbSetOrder(1)
DbSeek("ZZI",.F.)

DbSelectArea("ZZI")
//DbSetOrder(1) // ZZI_FILIAL+DTOS(ZZI_DATA)+ZZI_HORA+ZZI_PEDIDO+ZZI_ITEMPV
//DbSetOrder(2) // ZZI_FILIAL+ZZI_CODEVE+ZZI_PEDIDO+ZZI_ITEMPV
DbSetOrder(3) // ZZI_FILIAL+ZZI_PEDIDO+DTOS(ZZI_DATA)+ZZI_HORA
_cChv := xFilial("ZZI") + _cPedido
If !_lPedido
	If !DbSeek(_cChv,.T.)
		Alert("Não Há Históricos para o(s) Pedido(s)")
		RestArea(_aAreaX3)
		RestArea(_aArea)
		Return(.T.)
	EndIf
ElseIf !Empty(_cPedido)
	// Posicionar no ultimo histórico desse cliente
	_cChv := xFilial("ZZI") + _cPedido
	If !DbSeek(_cChv,.F.)
		Alert("Não Há Históricos para o Pedido " + _cPedido)
		RestArea(_aAreaX3)
		RestArea(_aArea)
		Return(.T.)
	EndIf
	_cChv2 := xFilial("ZZI") +_cPedido + "ZZ"
	DbSeek(_cChv2,.T.)
	Do While ZZI->ZZI_FILIAL+ZZI->ZZI_PEDIDO # _cChv .And. !Bof()
		DbSkip(-1)
	EndDo
EndIf
aAdd( aButtons, { "PGPREV", { || u_PuleZZI(1,_lPedido) }, "Primeiro"} )
aAdd( aButtons, { "PREV"  , { || u_PuleZZI(2,_lPedido) }, "Anterior"} )
aAdd( aButtons, { "NEXT" ,  { || u_PuleZZI(3,_lPedido) }, "Próximo" } )
aAdd( aButtons, { "PGNEXT", { || u_PuleZZI(4,_lPedido) }, "Ultimo"  } )

AxVisual("ZZI",Recno(),2,,,,, aButtons )

DbSelectArea("ZZI")
Set Filter to

RestArea(_aAreaX3)
RestArea(_aArea)
Return(.T.)
*
*************************************
User Function PuleZZI(nOnde,_lPedido)
*************************************
*
_cChv := ZZI->ZZI_FILIAL+ZZI->ZZI_PEDIDO
DbSelectArea("ZZI")
DbSetOrder(3) // ZZI_FILIAL+ZZI_PEDIDO+DTOS(ZZI_DATA)+ZZI_HORA

If !_lPedido
	If nOnde == 1 // 1 - Inicio
		ZZI->(DbGoTop())
	ElseIf nOnde == 2 // 2 - Anterior
		ZZI->(DbSkip(-1))
		If ZZI->(Bof())
			ZZI->(DbGoTop())
			Alert("Primeiro Registro Localizado")
		EndIf
	ElseIf nOnde == 3 // 3 - Próximo
		ZZI->(DbSkip())
		If ZZI->(Eof())
			ZZI->(DbGoBottom())
			Alert("Último Registro Localizado")
		EndIf
	ElseIf nOnde == 4 // 4 - Fim
		ZZI->(DbGoBottom())
	EndIf
Else
	If nOnde == 1 // 1 - Inicio
		ZZI->(DbSeek(_cChv,.F.))
	ElseIf nOnde == 2 // 2 - Anterior
		ZZI->(DbSkip(-1))
		If ZZI->ZZI_FILIAL+ZZI->ZZI_PEDIDO # _cChv .Or. ZZI->(Bof())
			ZZI->(DbSeek(_cChv,.F.))
			Alert("Primeiro Registro Localizado")
		EndIf
	ElseIf nOnde == 3 // 3 - Próximo
		_nRegAtu := Recno()
		ZZI->(DbSkip())
		If ZZI->ZZI_FILIAL+ZZI->ZZI_PEDIDO # _cChv .Or. ZZI->(Eof())
			DbGoTo(_nRegAtu)
			Alert("Último Registro Localizado")
		EndIf
	ElseIf nOnde == 4 // 4 - Fim
		_cChv2:= ZZI->ZZI_FILIAL+ZZI->ZZI_PEDIDO+"ZZ"
		ZZI->(DbSeek(_cChv2,.T.))
		Do While ZZI->ZZI_FILIAL+ZZI->ZZI_PEDIDO # _cChv .And. ZZI->(!Bof())
			ZZI->(DbSkip(-1))
		EndDo
	EndIf
EndIf
RegToMemory("ZZI",.F.)
Return(.T.)
*
******************************************************************
User Function CDGEN21I(_nEvento,_cCampo,_nValAnt,_nValAtu,_aDadC5)
******************************************************************
*
// Os parâmetros _cCampo,_nValAnt,_nValAtu só são passados quando _nEvento for 9
/*/
_nEvento - Código do Evento

Ordem 1 -> ZZI_FILIAL+DTOS(ZZI_DATA)+ZZI_HORA+ZZI_PEDIDO+ZZI_ITEMPV
Ordem 2 -> ZZI_FILIAL+ZZI_CODEVE+ZZI_PEDIDO+ZZI_ITEMPV
/*/
Local _aArea := GetArea()

Private _nEvento

// Somente pedidos tipo "N" serão monitorados
If _aDadC5[5] # "N" // C5_TIPO
	Return(.T.)
EndIf


_aEventos := {}
Aadd(_aEventos,"01-Inclusao  de Pedidos")			// OK
Aadd(_aEventos,"02-Alteracao de Pedidos")			// OK
Aadd(_aEventos,"03-Exclusao  de Pedidos")			// OK
Aadd(_aEventos,"04-Liberacao Pedido (Vendas)")		// OK
Aadd(_aEventos,"05-Liberacao Pedido (Credito)")
Aadd(_aEventos,"06-Autorizacao PCP p/Alteracao")	// OK
Aadd(_aEventos,"07-Eliminacao de Residuos")			// ok
Aadd(_aEventos,"08-Autoriz.Vendas p/Alteracao")		// OK
Aadd(_aEventos,"09-Alteracao Tabela Preço")
Aadd(_aEventos,"10-Analise Credito Rejeicao")		// ok
Aadd(_aEventos,"11-Analise Cred.Rej. (Item)")		// ok
Aadd(_aEventos,"12-Faturamento")					// ok
Aadd(_aEventos,"13-Alteração Tabela Pedido")		// ok
Aadd(_aEventos,"14-Alteração Tabela Cliente")		// ok
Aadd(_aEventos,"15-Renegociacao de Pedidos")		// OK
Aadd(_aEventos,"16-Reneg/Faturar")					// OK
Aadd(_aEventos,"17-Confirmação Neg. de Prazo")		// OK 
Aadd(_aEventos,"18-Conf.Neg.de Prazo-Dt.Fat.")		// OK

//_aDadC5 := {SC5->C5_NUM,M->C5_CLIENTE,M->C5_LOJACLI,M->C5_ENTREG,M->C5_TIPO}
// Parâmetros da Static Function GrvEvent(_lCab,_cItem,_cCampo,_cInfOld,_cInfNew,_aDadC5)
// _lCab    - Cabeçalho T/F
// _cItem   - Item do Pedido
// _cCampo  - Nome do

If Type("_nValAnt")== "N"
	_nValAnt := Right(Space(TamSX3("ZZI_DADOAN")[1]) + Transform(_nValAnt,"@E 9999,999,999.99"),TamSX3("ZZI_DADOAN")[1])
EndIf
If Type("_nValAtu")== "N"
	_nValAtu := Right(Space(TamSX3("ZZI_DADOAT")[1]) + Transform(_nValAtu,"@E 9999,999,999.99"),TamSX3("ZZI_DADOAT")[1])
EndIf

If _nEvento == 4 .Or. _nEvento == 5 // 04-Liberacao Pedido (Vendas) - 05-Liberacao Pedido (Credito)
	// Altera a data uma vez que foi realizada a liberação do pedido por vendas
	_aArea_XX := GetArea()
	DbSelectArea("SC5")
	_aArea_C5 := GetArea()
	M->C5_DTPCP := Ctod("  /  /  ")
	If SC5->C5_NUM # _aDadC5[1]
		SC5->(DbSetOrder(1))
		SC5->(DbSeek(xFilial("SC5")+_aDadC5[1],.F.))
	EndIf
	If SC5->C5_NUM == _aDadC5[1] .And. !Empty(SC5->C5_DTPCP) .And. SC5->(!Eof())
		GrvEvent(.T.,_nEvento,,"C5_DTPCP",Dtoc(SC5->C5_DTPCP),"  /  /  ",_aDadC5)
		RecLock("SC5",.F.)
		SC5->C5_DTPCP := Ctod("  /  /  ")
		MsUnLock()
	EndIf
	RestArea(_aArea_C5)
	RestArea(_aArea_XX)
EndIf

If _nEvento == 9 .Or. _nEvento == 13 .Or. _nEvento == 14
	// -Alteração Tabela Preço // Alteração tabela pedido // Alteração tabela cliente
	GrvEvent(.F.,;
	_nEvento,;
	"  ",;
	_cCampo,;
	_nValAnt,;
	_nValAtu,;
	_aDadC5)
ElseIf _nEvento == 11 // Analise Cred.Rej. (Item)
	
	_nValAtu := Right(Space(TamSX3("ZZI_DADOAT")[1]) + Transform((SC9->C9_QTDLIB*SC9->C9_PRCVEN),"@E 9999,999,999.99"),TamSX3("ZZI_DADOAT")[1])
	
	GrvEvent(	.F.,;
	_nEvento,;
	SC9->C9_ITEM,;
	,;
	"SEQ."+SC9->C9_SEQUEN,;
	_nValAtu,;
	_aDadC5)
Else
	GrvEvent(.T.,_nEvento,,,,,_aDadC5)  // If _nEvento == 1 .Or. _nEvento == 3 // 1-Inclusão  de Pedidos OU 3-Exclusão  de Pedidos
EndIf

If _nEvento == 2 .Or. _nEvento == 15 .Or. _nEvento == 16 //02-Alteração de Pedidos / 15-Renegociação Pedidos
	
	For j := 1 To SC5->(FCount())
		_cVariv := AllTrim(SC5->(FieldName(j)))
		_xTpDado := Upper(Type(_cVariv))
		If _xTpDado # "U"
			_cVdd1 := M->&(_cVariv)
			If _nEvento == 16 .And. "C5_PESOBOB" $ _cVariv
				_cVdd2 := _nPesos
			Else
				_cVdd2 := SC5->(FieldGet(j))
			EndIf
			If _cVdd1 # _cVdd2
				If _xTpDado == "N"
					_cVdd1 := AllTrim(Str(_cVdd1,10,2))
					_cVdd2 := AllTrim(Str(_cVdd2,10,2))
				ElseIf _xTpDado == "L"
					_cVdd1 := If(_cVdd1,".T.",".F.")
					_cVdd2 := If(_cVdd2,".T.",".F.")
				ElseIf _xTpDado == "D"
					_cVdd1 := Dtoc(_cVdd1)
					_cVdd2 := Dtoc(_cVdd2)
				EndIf
				GrvEvent(.F.,_nEvento,"  ",_cVariv,_cVdd2,_cVdd1,_aDadC5)
			EndIf
		EndIf
	Next
	
	/*/
	If M->C5_CLIENTE # SC5->C5_CLIENTE
		//Alterado o Cliente
		GrvEvent(.F.,_nEvento,"  ","C5_CLIENTE",SC5->C5_CLIENTE,M->C5_CLIENTE,_aDadC5)
	EndIf
	If M->C5_LOJACLI # SC5->C5_LOJACLI
		//Alterado a Loja
		GrvEvent(.F.,_nEvento,"  ","C5_LOJACLI",SC5->C5_LOJACLI,M->C5_LOJACLI,_aDadC5)
	EndIf
	If M->C5_ENTREG # SC5->C5_ENTREG
		//Alterado a Loja
		GrvEvent(.F.,_nEvento,"  ","C5_ENTREG",Dtoc(SC5->C5_ENTREG),Dtoc(M->C5_ENTREG),_aDadC5)
	EndIf
	/*/
	
	SC6->(DbSetOrder(1))
	
	For _nN := 1 to Len(aCols)
		// Procurar o item no SC6
		SC6->(DbSeek(xFilial("SC6") + M->C5_NUM + GDFieldGet("C6_ITEM",_nN),.F.))
		If GDDeleted(_nN) // Esta deletado
			If SC6->(!Eof())
				// Está deletado e não foi incluído agora
				GrvEvent(.F.,_nEvento,GDFieldGet("C6_ITEM",_nN),"  ","Item Excluido","  ",_aDadC5)
			EndIf
		Else // Não está deletado
			If SC6->(Eof())
				// Foi incluído agora
				GrvEvent(.F.,_nEvento,GDFieldGet("C6_ITEM",_nN),"  ","Item Incluido","  ",_aDadC5)
			Else
				// Não foi incluído agora
				If GDFieldGet("C6_PRODUTO",_nN) # SC6->C6_PRODUTO
					// Alterou o Produto
					GrvEvent(.F.,_nEvento,GDFieldGet("C6_ITEM",_nN),"C6_PRODUTO",SC6->C6_PRODUTO,GDFieldGet("C6_PRODUTO",_nN),_aDadC5)
				EndIf
				
				If GDFieldGet("C6_DESCRI",_nN) # SC6->C6_DESCRI
					// Alterou a descrição
					GrvEvent(.F.,_nEvento,GDFieldGet("C6_ITEM",_nN),"C6_DESCRI",SC6->C6_POSHPHU,GDFieldGet("C6_DESCRI",_nN),_aDadC5)
				EndIf
				
				If GDFieldGet("C6_QTDVEN",_nN) # SC6->C6_QTDVEN
					// Alterou a Quantidade
					
					_nValAnt := Right(Space(TamSX3("ZZI_DADOAN")[1]) + Transform(SC6->C6_QTDVEN,"@E 9999,999,999.99"),TamSX3("ZZI_DADOAN")[1])
					_nValAtu := Right(Space(TamSX3("ZZI_DADOAT")[1]) + Transform(GDFieldGet("C6_QTDVEN",_nN),"@E 9999,999,999.99"),TamSX3("ZZI_DADOAT")[1])
					GrvEvent(.F.,;
					_nEvento,;
					GDFieldGet("C6_ITEM",_nN),;
					"C6_QTDVEN",;
					_nValAnt,;
					_nValAtu,;
					_aDadC5)
				EndIf
				If GDFieldGet("C6_PRCVEN",_nN) # SC6->C6_PRCVEN
					// Alterou o Preço de Venda
					_nValAnt := Right(Space(TamSX3("ZZI_DADOAN")[1]) + Transform(SC6->C6_PRCVEN,"@E 9999,999,999.99"),TamSX3("ZZI_DADOAN")[1])
					_nValAtu := Right(Space(TamSX3("ZZI_DADOAT")[1]) + Transform(GDFieldGet("C6_PRCVEN",_nN),"@E 9999,999,999.99"),TamSX3("ZZI_DADOAT")[1])
					GrvEvent(.F.,;
					_nEvento,;
					GDFieldGet("C6_ITEM",_nN),;
					"C6_PRCVEN",;
					_nValAnt,;
					_nValAtu,;
					_aDadC5)
				EndIf
				If GDFieldGet("C6_TES",_nN) # SC6->C6_TES
					// Alterou o TES
					GrvEvent(.F.,_nEvento,GDFieldGet("C6_ITEM",_nN),"C6_TES",;
					SC6->C6_TES,GDFieldGet("C6_TES",_nN),_aDadC5)
				EndIf
				If GDFieldGet("C6_PEDCLI",_nN) # SC6->C6_PEDCLI
					GrvEvent(.F.,_nEvento,GDFieldGet("C6_ITEM",_nN),"C6_PEDCLI",;
					SC6->C6_PEDCLI,GDFieldGet("C6_PEDCLI",_nN),_aDadC5)
				EndIf
				If GDFieldGet("C6_ITPDCLI",_nN) # SC6->C6_ITPDCLI
					GrvEvent(.F.,_nEvento,GDFieldGet("C6_ITEM",_nN),"C6_ITPDCLI",;
					SC6->C6_ITPDCLI,GDFieldGet("C6_ITPDCLI",_nN),_aDadC5)
				EndIf
				If GDFieldGet("C6_POSHPHU",_nN) # SC6->C6_POSHPHU
					GrvEvent(.F.,_nEvento,GDFieldGet("C6_ITEM",_nN),"C6_POSHPHU",;
					SC6->C6_POSHPHU,GDFieldGet("C6_POSHPHU",_nN),_aDadC5)
				EndIf
				If GDFieldGet("C6_ACONDIC",_nN) # SC6->C6_ACONDIC
					GrvEvent(.F.,_nEvento,GDFieldGet("C6_ITEM",_nN),"C6_ACONDIC",;
					SC6->C6_ACONDIC,GDFieldGet("C6_ACONDIC",_nN),_aDadC5)
				EndIf
				If GDFieldGet("C6_METRAGE",_nN) # SC6->C6_METRAGE
					GrvEvent(.F.,_nEvento,GDFieldGet("C6_ITEM",_nN),"C6_METRAGE",;
					SC6->C6_METRAGE,GDFieldGet("C6_METRAGE",_nN),_aDadC5)
				EndIf
			EndIf
		EndIf
	Next
EndIf
/*/
Em reunião com Jeferson, Crispilho, Natanael e Roberto, verificou-se que a rotina de criação de
pedidos automática está trazendo muita mão de obra para gerenciar as alterações/ utilização de estoque,
etc e por isso estamos tirando do ar.

If _nEvento == 5 // -Liberacao Pedido (Credito)")
	// Chamar a rotina para verificação e criação de pedidos de transferência
	// dos produtos não fabricados na filial corrente.
	_nRot := 1
	_lRot := .F.
	Do While .T.
		_cRotina := ProcName(_nRot++)
		If "CSFAT11" $ _cRotina // Acabou ou é a Rotina de Produção
			_lRot := .T.
			Exit
		ElseIf Empty(_cRotina)
			Exit
		EndIf
	EndDo
	If !_lRot // Se não for rotina de transferência retorna .T.
		u_CSFAT11(.F.)
	EndIf
EndIf
/*/
RestArea(_aArea)
Return(.T.)
*
*********************************************************************************
Static Function GrvEvent(_lCab,_nEvento,_cItem,_cCampo,_cInfOld,_cInfNew,_aDadC5)
*********************************************************************************
*
// Parâmetros da Static Function GrvEvent(
// _lCab    - Cabeçalho T/F
// _cItem   - Item do Pedido
// _cCampo  - Nome do campo alterado
// _cInfOld - Conteúdo anterios do campo alterado
// _cInfNew - Conteúdo atual do campo alterado

Local _lCab    // Indica se é Cabeçalho ou não (item)
Local _cItem   // Campo Alterado
Local _cCampo  // Campo Alterado
Local _cInfOld // Conteúdo anterior
Local _cInfNew // Conteúdo atual
Local _nEvento // Evento

Default _cCampo := " "

If Type("_cInfOld") == "N"
	_cInfOld := Transform(_cInfOld,"@E 999,999,999.9999999")
	_cInfNew := Transform(_cInfNew,"@E 999,999,999.9999999")
	Do While .T.
		If Right(_cInfOld,1) == "0"
			_cInfOld := Left(_cInfOld,Len(_cInfOld)-1)
		EndIf
		If Right(_cInfNew,,1) == "0"
			_cInfNew := Left(_cInfNew,Len(_cInfNew)-1)
		EndIf
		If !("0" $ Right(_cInfOld,1)+Right(_cInfNew,,1))
			Exit
		EndIf
	EndDo
	If Right(_cInfOld) == "," // O Ultimo Cara é virgula
		_cInfOld := Left(_cInfOld,Len(_cInfOld)-1)
	EndIf
	If Right(_cInfNew) == "," // O Ultimo Cara é virgula
		_cInfNew := Left(_cInfNew,Len(_cInfNew)-1)
	EndIf            
ElseIf Type("_cInfOld") == "D"
	_cInfOld := Dtoc(_cInfOld)
	_cInfNew := Dtoc(_cInfNew)
ElseIf Type("_cInfOld") == "L"
	_cInfOld := If(_cInfOld,".T.",".F.")
	_cInfNew := If(_cInfNew,".T.",".F.")
EndIf


DbSelectArea("ZZI")
_nTamN := Len(ZZI->ZZI_DADOAN)
_nTamT := Len(ZZI->ZZI_DADOAT)
//_cInfOld := Right(Space(_nTamN)+AllTrim(_cInfOld),_nTamN)
//_cInfNew := Right(Space(_nTamT)+AllTrim(_cInfNew),_nTamT)

RecLock("ZZI",.T.)
ZZI->ZZI_FILIAL := xFilial("ZZI")
ZZI->ZZI_DATA   := Date()
ZZI->ZZI_HORA   := Left(Time(),Len(ZZI->ZZI_HORA))
ZZI->ZZI_PEDIDO := _aDadC5[1]
ZZI->ZZI_CODCLI := _aDadC5[2]
ZZI->ZZI_LOJCLI := _aDadC5[3]
ZZI->ZZI_NOMCLI := Posicione("SA1",1,xFilial("SA1")+_aDadC5[2]+_aDadC5[3],"A1_NOME")
ZZI->ZZI_DTENTR := _aDadC5[4]
ZZI->ZZI_USER   := cUserName
ZZI->ZZI_CODEVE := Left(_aEventos[_nEvento],2)
ZZI->ZZI_EVENTO := _aEventos[_nEvento]
_cInfo := ""
If ZZI->ZZI_CODEVE == "17"
	ZZI->ZZI_CAMPO := "C5_ENTREG"
	ZZI->ZZI_DTENTR := _C5_DTENTR
	ZZI->ZZI_DADOAN := Dtoc(_aDadC5[4])
	ZZI->ZZI_DADOAT := Dtoc(_C5_DTENTR)
ElseIf ZZI->ZZI_CODEVE == "18"
	ZZI->ZZI_CAMPO := "C5_DTFAT"
	ZZI->ZZI_DTENTR := _C5_DTENTR
	ZZI->ZZI_DADOAN := Dtoc(_aDadC5[4])
	ZZI->ZZI_DADOAT := Dtoc(_C5_DTENTR)
ElseIf (_nEvento == 4 .Or. _nEvento == 5) .And. _cCampo == "C5_DTPCP"
	ZZI->ZZI_CAMPO  := "C5_DTPCP"
	ZZI->ZZI_DADOAN := _cInfOld
	ZZI->ZZI_DADOAT := _cInfNew
EndIf

If !_lCab
	ZZI->ZZI_ITEMPV := _cItem
	ZZI->ZZI_CAMPO  := _cCampo
	ZZI->ZZI_DADOAN := AllTrim(_cInfOld)
	ZZI->ZZI_DADOAT := AllTrim(_cInfNew)
	If Len(AllTrim(_cInfOld)) > Len(ZZI->ZZI_DADOAN) .Or. Len(AllTrim(_cInfNew)) > Len(ZZI->ZZI_DADOAT)
		_cInfo := "Cont.Anterior: " + If(Empty(_cInfOld), '**VAZIO**',AllTrim(_cInfOld)) + Chr(13) + "Cont.Atual: " + If(Empty(_cInfNew), '**VAZIO**',AllTrim(_cInfNew))
		ZZI->ZZI_OBS := _cInfo
		ZZI->ZZI_DADOAN := "Vide Observação"
		ZZI->ZZI_DADOAT := "Vide Observação"
	EndIf
EndIf
If Len(_aDadC5) > 5
	If !Empty(_aDadC5[6])
		_cDDat := Right(Space(TamSX3("ZZI_DADOAT")[1]) + Transform(_aDadC5[6],"@E 9999,999,999.99"),;
		TamSX3("ZZI_DADOAT")[1])
		ZZI->ZZI_DADOAT := _cDDat
	EndIf
	If Len(_aDadC5) == 7
		ZZI->ZZI_OBS := _aDadC5[7] + If(Empty(_cInfo),"",Chr(13)+_cInfo)
	EndIf
EndIf
MsUnLock()
Return(.T.)
*
**************************
User Function MTA500PROC()
**************************
*
// Inicializo uma variável PUBLICA que será usada no PE MT500APO para
// saber se neste momento já gravei um log da eliminação do resíduo de cada pedido
//
Public _cPedRes := ""
Return(.T.)
*
************************
User Function MT500APO()
************************
// Menu PEDIDO DE VENDA RESÍDUO:
// ESTA POSICIONADO NO SC5  PARAMIXB[1] está com .T.
// PASSA A CADA SC6

// Utilizo a variável _cPedRes inicializada como PUBLICA no PE MTA500PROC onde vou armazenando
// os pedidos que já foram gravados os logs de eliminação de resíduos
If Type("_cPedRes") # "C"
	Public _cPedRes := ""
EndIf
If !SC6->C6_NUM $ _cPedRes
	// Gravar log da aliminação de resíduo
	_aDadC5 := {SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_ENTREG,SC5->C5_TIPO}
	u_CDGEN21I(7,,,,_aDadC5) // 07-Eliminacao de Residuos
	_cPedRes += "//" + SC6->C6_NUM
EndIf

// Exclui a tabela de corte (lista de repasse).
u_VejaSZ9("E", SC6->C6_NUM, SC6->C6_SEMANA, SC6->C6_ITEM, SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5), ;
		  SC6->C6_LANCES, SC6->C6_PRODUTO, SC6->C6_LOCAL, SC6->C6_ENTREG)
		  
Return(.T.)
*
***********************
User Function MTA450I()
***********************
*
// ANALISE DE CREDITO PEDIDO - MANUAL E OK - entrou uma vez
// /ESTÁ POSICIONADO NO SC5 E NO SC9
// /entrou uma vez assim que cliquei em ok... ou seja deve liberar somente um item (item 04) -posicionado no SC9
// /que já está com BLCRED EM BRANCO - LIBERADO.
// /Quando cliquei em LIBERA TODOS, 	o BLCRED ainda esta com 01...o PARAMIXB tem 2 elementos {4,04/04/14}
// /Chamou diversas vezes este PE mas não mudou nada nos posicionamentos ou no blcred que continua com 01
If PARAMIXB[1] == 1
	// Análise de crédito PEDIDO - clicou em ok
	// Esta rotina quando escolhida OK não chama a rotina u_CdAgreg(_Volta), por sua vez chamada pelo MV_AGREG
	// por isso tem que ser chamada quando o PARAMIXB[1] for igual a 1
	// Libera somete um item que está posicionado tento no SC9 como no SC5
	//
	
	//Leonardo
	U_CDAgreg(Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE)+SC5->(C5_LOJACLI),"A1_AGREG"))
	
	If   !_SetAutoMode() .And. FWCodFil() == "02" .And. SC5->(C5_TIPO) $ 'N'
		
		u_pedIndl()
		
	EndIf
	//Fim Leonardo
	
	
	_aDadC5 := {SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_ENTREG,SC5->C5_TIPO}
	u_CDGEN21I(5,,,,_aDadC5) // "05-Liberacao Pedido (Credito)")
	//ElseIf If PARAMIXB[1] == 4
	// Chamou a rotina LIBERA TODOS
	// Preparo a variável _lGrvLog com .T. e como pública para orientar a função u_CdAgreg(_Volta) a
	// Gravar somente uma vez.
	//	Public _lGrvLog := .T.
EndIf
Return(.T.)
*
************************
User Function MT440LIB()
************************
*
Local _aArea 	:= GetArea()
Local _aSC6		:= SC6->(GetArea())
local _aSC5		:= SC5->(GetArea())
Local _aSC9		:= SC9->(GetArea())
Local _aSA1		:= SA1->(GetArea())
Local _nALiberar:= PARAMIXB

If Type("_cPdnLbAu") # "C"
	Public _cPdnLbAu := ""
EndIf


// By Roberto Oliveira 18/04/2016
//
//Este ponto de entrada é executado na rotina de LIBERAçãO DE PEDIDOS opção AUTOMÁTICO.
//Se este pedido não puder ser liberado devido ao bloqueio no cadastro do cliente, retornar com a quantidade ZERO

SC5->(DbSetOrder(1))
SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM,.F.))
If !(SC5->C5_TIPO $ "DB") .And. Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_MSBLQL") == '1' // Sim
	// Solicitação Vânia/Denise e mail de 14/04/2016 14:24h
	If !(SC6->C6_NUM $ _cPdnLbAu)
		_cPdnLbAu := SC6->C6_NUM
		MsgInfo("Liberação do Pedido "+SC6->C6_NUM+" não Efetuada. Cliente Bloqueado","Ponto Entrada MT440AT")
	EndIf
	_nALiberar := 0
EndIf


// PE na rotina de liberação de pedido (por item)
// Retornar PARAMIXB que é a quantidade liberada

If Type("_cPdLbAu") # "C"
	Public _cPdLbAu := ""
EndIf
If !SC6->C6_NUM $ _cPdLbAu .And. _nALiberar > 0
	// Gravar log da aliminação de resíduo
	// Atenção: Neste momento nenhuma tabela relacionada a liberação do pedido está posicionada,
	//  nem SC5, SC6, SC9, SA1, ETC...
	// o Protheus criou uma tabela de trabalho com alias QUERYSC6
	SC5->(DbSetOrder(1))
	SC5->(DbSeek(xFilial("SC5")+QUERYSC6->C6_NUM,.F.))
	
	If   !_SetAutoMode() .And. FWCodFil() == "02" .And. SC5->(C5_TIPO) $ 'N'
		
		If Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE)+SC5->(C5_LOJACLI),"A1_RISCO") == 'A'
			u_pedIndl()
		EndIf
		
	EndIf
	
	_aDadC5 := {SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_ENTREG,SC5->C5_TIPO}
	u_CDGEN21I(4,,,,_aDadC5) // 04-Liberação de Pedidos (Venda)
	_cPdLbAu := SC6->C6_NUM
EndIf

Restarea(_aSA1)
Restarea(_aSC9)
RestArea(_aSC5)
RestArea(_aSC6)
RestArea(_aArea)
Return(_nALiberar) // Retornar a quantidade liberada

/*/
User Function M450CMAN()
xxy := 1
Return(.T.)// Retornar .T. ou .F.
// Analise de credito CLIENTE - Cliquei em Rejeitar- o PARAMIXB[1] está com 3
// OPS - INTERESSANTE - Cliquei em liberar e PARAMIXB[1] está com 1


User Function MTA450CL()
xy := 1
Return(.T.)
// Na rotina ANALISE CRED.CLIENTE - REJEITAR - Após gravar todos os C9 como rejeitado
// C5 posicionado e PARAMIXB[1] = 3
// Na rotina ANALISE CRED.CLIENTE - LIBERA  - Após gravar todos os C9 como liberados
// PARAMIXB[1] = 1
// Na rotina ANALISE CRED.CLIENTE - SAIR    -
// PARAMIXB[1] = 0

User Function MTA456P()
xxy := 1
Return(.T.)// Retornar .T. ou .F.
// Rotina LIBERAÇÃO CRED/ESTOQUE cliquei em REEJEITAR -> PARAMIXB[1] = 3
// rejeitou só um item
// Rotina LIBERAÇÃO CRED/ESTOQUE cliquei em CANCELAR  -> PARAMIXB[1] = 0
// Rotina LIBERAÇÃO CRED/ESTOQUE cliquei em AUTOMATICO  -> PARAMIXB[1] = NIL
// Rotina LIBERAÇÃO CRED/ESTOQUE cliquei em LIB/TODOS  -> PARAMIXB[1] = 4

User Function MTA456R()
xxy := 1
Return(.T.)
// Rotina LIBERAÇÃO CRED/ESTQ... cliquei em rejeitar PARAMIXB NUL
// rejeitou só um item


User Function MTA456L()
xxy := 1
Return(.T.)
// Rotina LIBERAÇÃO CRED/ESTQ... cliquei em rejeitar PARAMIXB[1] = 3
// rejeitou só um item
// Rotina LIBERAÇÃO CRED/ESTOQUE cliquei em CANCELAR  -> PARAMIXB[1] = 0
// Rotina LIBERAÇÃO CRED/ESTOQUE cliquei em LIB TODOS  -> PARAMIXB[1] = 4 // ATENÇAO não chamou o agreg
// ACHO QUE DEVO GRAVAR O LOG AQUI QUANDO LIB TODOS

/*/
User Function TesteB2()

DbSelectArea("SB2")
DbSetOrder(1)//B2_FILIAL+B2_COD+B2_LOCAL

DbSelectArea("SB1")
DbSetOrder(1)

DbGoTop()
Do While SB1->(!Eof())
	For _nFil := 1 to 2
		_cFil := StrZero(_nFil,2)
		
		DbSelectArea("SB2")
		DbSeek(_cFil+SB1->B1_COD,.F.)
		Do While SB2->B2_FILIAL == _cFil .And. SB2->B2_COD == SB1->B1_COD .And. SB2->(!Eof())
			If !MsrLock()
				_Erro := .T.
			Else
				MsUnLock()
			EndIf
			SB2->(DbSkip())
		EndDo
	Next
	SB1->(DbSkip())
EndDo
Return(.T.)
