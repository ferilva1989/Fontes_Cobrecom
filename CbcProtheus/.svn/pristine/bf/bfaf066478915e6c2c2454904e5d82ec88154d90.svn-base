#include "rwmake.ch"
#include "TOPCONN.ch"
#include "protheus.ch"
#include "portalcobrecom.ch"
#Define linha chr(13)+chr(10)


////////////////////////////////////////////////////////////////////////////////
//																						//
//   Programa .. .: M410LIOK                           Modulo : SIGAFAT		//
//																						//
//																						//
//   Autor ......: RODRIGO O. T. CAETANO              Data ..: 27/07/2004		//
//																						//
//   Objetivo ...: Cálculo do Lucro Bruto do Item e do Total do PV				//
//																						//
//   Uso ........: Especifico da Condusul											//
//																						//
////////////////////////////////////////////////////////////////////////////////
*

User Function M410LIOK // Função revisada
**********************
* DEIXAR SE AUTO
Local _aArea    		:= GetArea()
Local aSC6				:= SC6->(GetArea())
Local oPed				:= Nil //[LEO] - 18/10/16
Local cMsgAlt			:= ""  //[LEO] - 18/10/16
Private _cProduto 	:= GDFieldGet("C6_PRODUTO",n)

	//[LEO] - 14/07/17 Validações do Varejo
	if !U_vareLiOk()
		return(.F.)
	endif

	//[LEO] - 18/10/16 (SE EXISTIR ALGUMA CONDIÇÂO PARA NÂO EXECUTAR A VALIDAÇÂO COLOCAR NA cbcPedido:vldFab())
	 If Altera
		 oPed := cbcPedido():newcbcPedido(M->(C5_NUM))
		 If !GDDeleted(n)
			oPed:vldFab(GDFieldGet("C6_PRODUTO",n),M->(C5_CLIENTE), M->(C5_LOJACLI))
			 If oPed:lselfOk .And. ( !oPed:lfab3l .And. oPed:lDiv .And. !oPed:lMix2 )
			 	If Empty(oPed:cselfMsg)
			 		cMsgAlt := '[ERRO] O Item ' + GDFieldGet("C6_ITEM",n) + ' não pode ser incluido nesta filial!'
			 	Else
			 		cMsgAlt := oPed:cselfMsg
			 	EndIf
			 		u_autoAlert(cMsgAlt,,'Info')
			 	FreeObj(oPed)
			 	Return(.F.)
			 EndIf
		 EndIf
		 FreeObj(oPed)
	 EndIf
	//[FIM] - 18/10/16

//Leonardo
If Altera .And. GDDeleted(n)
	// Verificar se foi deletada uma linha que já esta em produção e não permitir
	If !u_VejaSZ9("V",M->C5_NUM, GDFieldGet("C6_SEMANA",n), GDFieldGet("C6_ITEM",n), GDFieldGet("C6_ACONDIC",n)+StrZero(GDFieldGet("C6_METRAGE",n),5), GDFieldGet("C6_LANCES",n))
		Return(.F.)
	EndIf
EndIf

If Altera .And. FWCodFil() == "02" .And. !Empty(GDFieldGet("C6_ZZPVORI",n))
	If !U_vPedReg({"podeAlterar",{aCols[n]},"" }) .And. (u_temAlt({aCols[n]}) .Or. GDDeleted(n))
		u_autoAlert("O Item:" + GDFieldGet("C6_ITEM",n) + " deste pedido esta relacionado com Pedido+Item de industrialização Numero: " + GDFieldGet("C6_ZZPVORI",n) + ;
		" em Itu É não pode ser alterado (Resumo/Bloqueado/Faturado)" )
		Return(.F.)
	EndIf

EndIf
//Fim

_cProduto := u_PrdNacion(_cProduto)

_lSair := 0             // atenção neste aqui
For _i := 1 To Len(aCols)
	If GDDeleted(_i)
		_cNrRes := GDFieldGet("C6_RES_SZZ",_i)
		_cItRes := GDFieldGet("C6_ITE_SZZ",_i)
		If !Empty(_cNrRes+_cItRes)
			_lSair := 1
			Exit
		EndIf
		If !Empty(GDFieldGet("C6_X_FLDES",_I)+GDFieldGet("C6_X_PVDES",_I)+GDFieldGet("C6_X_ITDES",_I)) .And. !Inclui
			_lSair := 2
			Exit
		EndIf
		If GDFieldGet("C6_SEMANA",_i) == "RESERVA";
		.Or. Left(GDFieldGet("C6_SEMANA",_i),1) == "r"; // Tem que ser "r" mesmo
		.Or. Alltrim(GDFieldGet("C6_SEMANA",_i)) == "ZP4"
			_lSair := 3
			Exit
		EndIf
	EndIf
Next
If _lSair == 1
	u_autoAlert("Para Excluir o Item, Os Campos Nro.Reserva e Item Reserva Devem Estar em Branco")
	Return(.F.)
ElseIf _lSair == 2
	u_autoAlert("Não é Permitido a Exclusão de Itens para Transferência")
	Return(.F.)
ElseIf _lSair == 3
	u_autoAlert("Não é Permitido a Exclusão de Itens Reservados")
	Return(.F.)
EndIf

If  M->C5_TIPO # "N"
	Return(.T.)
EndIf

_cTES := GDFieldGet("C6_TES",n)

If _cTES == "505" .And. (M->C5_DESCESP # 0 .Or. M->C5_DESCEQT # 0)
	u_autoAlert("Não Usar TES 505 Juntamente com Descontos")
	Return(.F.)
EndIf


If (M->C5_DESCESP # 0 .Or. M->C5_DESCEQT # 0) .and. (M->C5_TIPO # "B")
	SF4->(DbSetOrder(1))
	SF4->(DbSeek(xFilial("SF4") + _cTES, .F.))
	If (M->C5_DESCESP # 0 .And. Empty(SF4->F4_TESVL)) .Or.;
		(M->C5_DESCEQT # 0 .And. Empty(SF4->F4_TESQT))
		u_autoAlert("Atenção: Corrigir o Cadastro do TES " + _cTES)
		Return(.F.)
	EndIf
EndIf

GDFieldPut("C6_TESORI",GDFieldGet("C6_TES",n),n)

If M->C5_TIPO == "N" .And. Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_LOCALIZ") == "S"
	If (Empty(GDFieldGet("C6_ACONDIC",n)) .Or. Empty(GDFieldGet("C6_LANCES",n)) .Or. Empty(GDFieldGet("C6_METRAGE",n))) .And.;
		!aCols[n,Len(aCols[n])]

		u_autoAlert("Os campos Acondicionamento, Lances e Metragem devem ser preenchidos para Produtos Acabados!")
		Return(.F.)
	EndIf
EndIf
/*
Trava para que o Lance seja do tamanho que o cliente especifica
USAR AQUI NO PEDIDO DE VENDA PARA BLOQUEIO JULIANA
*/
If GDFieldGet("C6_ACONDIC",n) == "B"
	_cTipoBob := "00"
	_cTipoBob := u_CalcBob(GDFieldGet("C6_PRODUTO",n),GDFieldGet("C6_METRAGE",n),,M->C5_CLIENTE, M->C5_LOJACLI) //PRODUTO, METROS, TP_RETORNO(TF),CODCLI,LOJA
	If _cTipoBob[3]
		u_autoAlert("Cadastro do Produto Incompleto! Solicite Correção dos dados de Cálculo da Bobina.")
		Return(.F.)
	EndIf
	If Alltrim(_cTipoBob[1]) = "65/25"
		cTpBob := "1"
	ElseIf Alltrim(_cTipoBob[1]) = "65/45"
		cTpBob := "2"
	ElseIf Alltrim(_cTipoBob[1]) = "80/45"
		cTpBob := "3"
	ElseIf Alltrim(_cTipoBob[1]) = "100/60"
		cTpBob := "4"
	ElseIf Alltrim(_cTipoBob[1]) = "125/70"
		cTpBob := "5"
	ElseIf Alltrim(_cTipoBob[1]) = "150/80"
		cTpBob := "6"
	ElseIf Alltrim(_cTipoBob[1]) = "170/80"
		cTpBob := "7"
	EndIf

	SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,.F.))
	If SA1->A1_MENORBB+SA1->A1_MAIORBB # "00" // Tem Bobina específica
		 If AllTrim(cTpBob) < SA1->A1_MENORBB .Or. AllTrim(cTpBob) > SA1->A1_MAIORBB
		// 18/01/17 - Vitor veio e chegamos no consenso de que não deve bloquear se a bobina calculada for menor
		// que a bobina que o cliente aceita.
		//If AllTrim(cTpBob) > SA1->A1_MAIORBB
			_cMenor := AllTrim(Substr(" 65x25/ 65x45/ 80x45/100x60/125x70/150x80/",(((Val(AllTrim(SA1->A1_MENORBB))-1) * 7) + 1),6))
			_cMaior := AllTrim(Substr(" 65x25/ 65x45/ 80x45/100x60/125x70/150x80/",(((Val(AllTrim(SA1->A1_MAIORBB))-1) * 7) + 1),6))
			If SA1->A1_MENORBB == SA1->A1_MAIORBB
				u_autoAlert("Lance Incompativel!" + Chr(13)+Chr(13)+;
							"Para esse lance terá que ser usada uma bobina " + _cTipoBob[1] + "." + Chr(13)+;
							"O Cliente só aceita bobinas do tamanho " + _cMenor)
			Else
				u_autoAlert("Lance Incompativel!" + Chr(13)+Chr(13)+;
							"Para esse lance terá que ser usada uma bobina " + _cTipoBob[1] + "." + Chr(13)+;
							"O Cliente só aceita bobinas do tamanho " + _cMenor + " até " + _cMaior)
			EndIf
			Return(.F.)
		EndIf
	EndIf
EndIf
/*
Termina aqui
*/

Private _nPrcVen  := 0
Private _nTPrcVen := 0
Private _nTCustd  := 0
Private _Itens    := 0	// Esta variável esté usada no sx3

For _i := 1 To Len(aCols)
	If !aCols[_i,Len(aCols[_i])]
		_Itens++ // Esta variável esté usada no sx3
	Endif
	If !GDDeleted(_i)
		GDFieldPut("C6_ENTREG",M->C5_ENTREG,_i)
		_cProduto := GDFieldGet("C6_PRODUTO",_i)
		_cProduto := u_PrdNacion(_cProduto) // Retorna código prod. nacional
		If Inclui .Or. GDFieldGet("C6_CSTUNRG",_i) <= 0
			If FWCodEmp()+FWCodFil() == "0102" /// Cobrecom 3 Lagoas
				_nCustd   := Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_CUSTD3L")
			Else
				_nCustd   := Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_CUSTD")
			EndIf
			GDFieldPut("C6_CSTUNRG",_nCustd,_i) // Atribui o custo unitário ao item do pedido
		ElseIf Altera
			// Alterou o produto ?
			If _cProduto # Posicione("SC6",1,xFilial("SC6")+M->C5_NUM+GDFieldGet("C6_ITEM",_i),"C6_PRODUTO")
				If FWCodEmp()+FWCodFil() == "0102" /// Cobrecom 3 Lagoas
					_nCustd   := Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_CUSTD3L")
				Else
					_nCustd   := Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_CUSTD")
				EndIf
				GDFieldPut("C6_CSTUNRG",_nCustd,_i) // Atribui o custo unitário ao item do pedido
			EndIf
		EndIf
		_nCustd   := GDFieldGet("C6_CSTUNRG",_i) * GDFieldGet("C6_QTDVEN",_i)
		_nPrcVen  := GDFieldGet("C6_PRCVEN" ,_i) * GDFieldGet("C6_QTDVEN",_i)
		_nTPrcVen += _nPrcVen
		_nTCustd  += _nCustd
		GDFieldPut("C6_LUCROBR",If(_nCustd==0,0,((_nPrcVen * 100) / _nCustd) - 100),_i)
	EndIf
Next

M->C5_LUCROBR := If(_nTCustd==0,0,((_nTPrcVen * 100) / _nTCustd) - 100)

// Valida o campo C6_LOCALIZ conforme os campos C6_ACONDIC+C6_METRAGE
If !Empty(GDFieldGet("C6_LOCALIZ",n))
	_Localiz := GDFieldGet("C6_ACONDIC",n)+StrZero(GDFieldGet("C6_METRAGE",n),5)
	If Left(GDFieldGet("C6_LOCALIZ",n),Len(_Localiz)) # _Localiz
		u_autoAlert("Localizacao Invalida, use -> " + _Localiz)
		Return(.F.)
	EndIf
EndIf
//Valida MP/PI se  estoque é sufciente
If  ! Altera
	If ! U_ValidEst() 
		Return(.F.)
	EndIf
EndIf

RestArea(aSC6)
RestArea(_aArea)

Return(.T.)
*
**********************
User Function M410ALOK() // ENTROU QUANDO CLIQUEI EM ALTERAR OU EM EXCLUIR // em alterar chamou após o MT410ACE
**********************
*
Local aArea		:= getArea()
Local aSC6		:= SC6->(GetArea())
/*
QUANDO ALTERAR A LOGICA DESTA FUNÇÃO, VERIFICAR O FONTE PEDINDL,A FUNÇÃO vPedReg() COM O PARAMTERO podeAlterar
POIS NESTA FUNÇÃO TEM A MESMA LOGICA (UTILIZADA NA DELEÇÃO E ALTERAÇÃO DE PEDIDOS SINCRONIZADOS PARA INDUSTRIALIZAÇÃO )
*/
// Valida se o Pedido de venda pode ser alterado
// Foi criado o Campo C5_SEMANA/C6_SEMANA que é a semana que foi programada a produção e se estiver preenchido
// não permite a Alteração do Pedido de Venda, dando um Box dizendo que este pedido já foi programado na produção
// Vide UF A410EXC, abaixo
_Volta := .T.

/*
LEONARDO 11/02/2016 - MELHORIA
PEDIDO EM ITU, CUJO CLIENTE SEJA A COBRECOM(008918) E ZZPVORIG NÃO VAZIO, NÃO PODE SER (EDITADO/EXCLUIDO)
DIRETAMENTE ESTAS AÇÕES, DEVEM SER FEITAS ATRAVEZ DO PEDIDO DE 3 LAGOAS
*/
If !Inclui .And. !_SetAutoMode()
	DbSelectArea("SC6")
	SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM,.F.))
	Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())
		If !Empty(SC6->C6_ZZPVORI) .And. SC6->C6_CLI == "008918"
			u_autoAlert("Este Pedido possui solicitação de industrialização para " + ;
			" Itu, e não pode ser alterado" + chr(13) + chr(13) + ;
			" Comunicar obrigatoriamente os responsáveis e se necessário alterar, " + chr(13) + chr(13) +;
			" deve-se realizar a alteração no pedido original Numero: "  + Substr(SC6->C6_ZZPVORI,1,6) + " em Três Lagoas!!",,'MsgBox')
			Return(.F.)
		EndIf
		SC6->(DbSkip())
	EndDo
EndIf

If !_SetAutoMode()
	//SDC->(DbSetOrder(4)) // DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_LOCALIZ
	SDC->(DBOrderNickName("SDCPED")) // DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_LOCALIZ

	SDC->(DbSeek(xFilial("SDC")+SC5->C5_NUM,.F.))
	Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->DC_PEDIDO == SC5->C5_NUM .And.;
		SDC->DC_ORIGEM # "SC6" .And. SDC->(!Eof())
		SDC->(DbSkip())
	EndDo
	_lTem := (SDC->DC_FILIAL == xFilial("SDC") .And. SDC->DC_PEDIDO == SC5->C5_NUM .And.;
	SDC->DC_ORIGEM == "SC6" .And. SDC->(!Eof()))
	If _lTem
		If SC5->C5_ZSTATUS < "1" //-OK .And. !GetMv("MV_ZZUSAC9")
			RecLock("SC5",.F.)
			SC5->C5_ZSTATUS := "1" // No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento
			MsUnLock()
		EndIf
	ElseIf SC5->C5_ZSTATUS > "0" // -OK  .And. !GetMv("MV_ZZUSAC9")
		RecLock("SC5",.F.)
		SC5->C5_ZSTATUS := "0" // No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento
		MsUnLock()
	EndIf
	If !Inclui .And. !AllTrim(cUserName)+"|" $ GetMV("MV_USERADM") .And. !u_turnOff()
		If SC5->C5_SEMANA == Replicate("X",Len(SC5->C5_SEMANA))
			u_autoAlert("Este Pedido está sendo programado na Produção e não pode ser Alterado ou Excluido!!!",,'MsgBox')
			_Volta := .F.
		ElseIf SC5->C5_DTPCP # Date()
			If Left(SC5->C5_SEMANA,3) == "DRC"
				_cTxt := If(Altera,". Altera?",".Exclui?")
				//_Volta := MsgBox("Este Pedido Refere-se a DRC " + Right(SC5->C5_SEMANA,4) + _cTxt,"Confirma?","YesNo")
				_Volta := u_autoAlert("Este Pedido Refere-se a DRC " + Right(SC5->C5_SEMANA,4) + _cTxt,.T.,'MsgBox','Confirma?',,'YesNo',.T.)
			ElseIf !Empty(SC5->C5_SEMANA)
				u_autoAlert("Este Pedido já está programado na Produção e não pode ser Alterado ou Excluido!!!",,'MsgBox')
				_Volta := .F.
			EndIf
		EndIf
		If _Volta .And. SC5->C5_ZSTATUS > "0" // -OK  .And. !GetMv("MV_ZZUSAC9")// No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento
			u_autoAlert("Este Pedido tem itens liberados para faturamento... Informe a expedição!!!",,'MsgBox')
			_Volta := .F.
		EndIf

		If SC5->C5_EMISSAO <  CTOD("25/10/16") .And. SC5->C5_DTALT < CTOD("25/10/16") .And. SC5->C5_FILIAL == '02'
			u_autoAlert("Devido Alteração na Regra, contatar T.I.",,'MsgBox')
			_Volta := .F.
		EndIf

		If _Volta .And. SC5->C5_DTVEN # Date()
			SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM,.F.))
			_lTrf := .F.
			_lRes := .F.
			_lNeg := .F. // Controle de Negociação
			Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())
				If SC6->C6_QTDENT > 0 // Tem quantidade faturada
					_Volta := .F.
					Exit
				ElseIf SC6->C6_XNEGOC $ "12345" // Pedido em fase de negociação
					_lNeg := .T. // Controle de Negociação
					_Volta := .F.
					Exit
				ElseIf !Altera .And. !Inclui .And. Left(SC6->C6_SEMANA,1) == "T" // Foi solicitado transferência de materiais para a outra unidade
					_lTrf := .T.
					_Volta := .F.
					Exit
				ElseIf !Altera .And. !Inclui .And. ("RESERVA" $ SC6->C6_SEMANA .Or.;
					Left(SC6->C6_SEMANA,1) == "r") // Tem que ser "r" mesmo  /*/ Possui itens reservados /*/
					// Avalia somente se for exclusão
					_lRes := .T.
					_Volta := .F.
					Exit
				Endif
				SC6->(DbSkip())
			EndDo
			If !_Volta
				If !_lTrf .And. !_lRes .And. !_lNeg // Não é por reserva nem por transferência nem por negociação
					u_autoAlert("Este Pedido já possui itens faturados e não pode ser Alterado ou Excluido!!!"+Chr(13)+Chr(13)+;
								"Solicitar Autorizacão da Supervisão ou Coordenação de Vendas",,'MsgBox')
					/*/
					Este If foi alterado para permitir a alteração dos pedidos de transferência
					alertando a necessidade de comunicação aos responsáveis.
					By Jeferson e Roberto Oliveira 14/11/14 11:15H

				ElseIf _lTrf
					u_autoAlert("Este Pedido possui solicitação de transferência para " + ;
					If(FWCodFil()=="02","Itu","3 Lagoas") +;
						" e não pode ser Alterado ou Excluido!!!",,'MsgBox')
						/*/
				ElseIf _lTrf
					u_autoAlert("Este Pedido possui solicitação de transferência para " + ;
					If(FWCodFil()=="02","Itu.","3 Lagoas.") + chr(13) + chr(13) + ;
						" Comunicar obrigatoriamente os responsáveis e se necessário alterar " + chr(13) + chr(13) +;
						" também o pedido de transferência!!",,'MsgBox')
						_Volta := .T.
				ElseIf _lNeg
					u_autoAlert("Este Pedido possui itens em negociação" + ;
					" e não pode ser Alterado ou Excluido!!!",,'MsgBox')
				ElseIf _lRes
					u_autoAlert("Este Pedido possui itens reservados" + ;
					" e não pode ser Alterado ou Excluido!!!",,'MsgBox')
				EndIf
			EndIf
		EndIf
	EndIf
	//If _Volta .And. (Altera .Or. Inclui) .And. M->C5_ENTREG < M->C5_EMISSAO .And. M->C5_CONDPAG == "000"
	//	u_autoAlert("Data de Entrega anterior a data de emissão do pedido de venda.",,'MsgBox')
	//	_Volta := .F.
	//EndIf
EndIf
RestArea(aSC6)
RestArea(aArea)
Return(_Volta)

/*/{Protheus.doc} MT410CPY
//TODO Ponto de Entrada para alteração na Copia de um pedido.
		Alterado em 29/11/2017 - Juliana Leme - Para zerar campo TES para engatilhar Tipo de Operação.
@author 0
@since 29/11/2017
@version 1.0

@type function
/*/
User Function MT410CPY()
// Usado para refazer a data de entrega do pedido quando criado por cópia
// Esta rotina é chamada somente uma vez pela MATA410 opção cópia.
	Local _aArea    := GetArea()
	Local aSC6		:= SC6->(GetArea())
	Local _aAreaB1, _aAreaX3, _cVar
	
	// By Roberto Oliveira 12/07/16
	// Conversei com Leonardo e Juliana e chegamos acordamos quie os campos que não são padrão do Protheus não devem ser
	// "copiados", devem receber conteúdo conforme inicializador padrão.
	DbSelectArea("SX3")
	_aAreaX3 := GetArea()
	DbSetOrder(1)
	DbSeek("SC5",.F.)
	Do While SX3->X3_ARQUIVO == "SC5" .And. SX3->(!Eof())
		If SX3->X3_PROPRI == "U" // Campo do uisuário
			_cVar    := AllTrim(SX3->X3_CAMPO)
			M->&(_cVar) := CriaVar(_cVar,.T.)
		EndIf
		SX3->(DbSkip())
	EndDo
	
	For _nCols := 1 to Len(aCols)
		DbSeek("SC6",.F.)
		Do While SX3->X3_ARQUIVO == "SC6" .And. SX3->(!Eof())
			If SX3->X3_PROPRI == "U" // Campo do usuário
				_cVar := AllTrim(SX3->X3_CAMPO)
				GDFieldPut(_cVar,CriaVar(_cVar,.T.),_nCols)
			EndIf
			SX3->(DbSkip())
		EndDo
	Next
	RestArea(_aAreaX3)
	// Fim By Roberto
	
	DbSelectArea("SB1")
	_aAreaB1  := GetArea()
	
	DbSetOrder(1)
	For _nCols := 1 to Len(aCols)
	
		//Leonardo
		GDFieldPut("C6_LOCAL" ,'01',_nCols)
		//Fim
		
		GDFieldPut("C6_TES" ,'',_nCols)
	
		_cProdNow := GDFieldGet("C6_PRODUTO",_nCols)
		DbSeek(xFilial("SB1")+_cProdNow,.F.)
		//If Len(AllTrim(_cProdNow)) > 10 .And. SB1->B1_TIPO == "PA"
		If Len(AllTrim(_cProdNow)) > 10 .And. SB1->B1_LOCALIZ == "S"
			If DbSeek(xFilial("SB1")+PadR(Left(_cProdNow,10),TamSX3("B1_COD")[1]),.F.)
				GDFieldPut("C6_PRODUTO",SB1->B1_COD,_nCols)
			EndIf
		EndIf
		//Verificar se os campos de outros cadastros tem o campo MSBLQL e estão bloqueados
	Next
	
	RestArea(_aAreaB1)
	RestArea(_aArea)
	
	u_AvalPrz("SC6",.T.) // Recalcula os prazos de entrega do pedido de venda
	
	M->C5_CLIENTE := CriaVar("C5_CLIENTE",.T.)
	M->C5_LOJACLI := CriaVar("C5_LOJACLI",.T.)
	M->C5_CLIENT  := CriaVar("C5_CLIENT" ,.T.)
	M->C5_LOJAENT := CriaVar("C5_LOJAENT",.T.)
	M->C5_DESCEQT := CriaVar("C5_DESCEQT",.T.)
	M->C5_DESCESP := CriaVar("C5_DESCESP",.T.)
	
	RestArea(aSC6)

Return(.T.)
*
*************************
User Function MT410TOK()   // INCLUSÃO CHAMOU ANTES DOS OBRIGATÓRIOS // chamou tb após clicar em ok em alterar
//User Function A410TudOk()
*************************
Local aArea			:= getArea()
Local aSC6			:= SC6->(GetArea())
Local oOrder		:= nil
Local oPed			:= nil //LEO 10/11/16
Local lPedRet		:= nil //LEO 10/11/16
Local lBndes		:= nil //LEO 10/11/16
Local pedMirr		:= nil //LEO 21/11/16
local oImp			:= nil //LEO 08/02/17
Local aParamBox 	:= {}  //JUL 06/06/2017
Local aRet 			:= ""	//JUL 06/06/2017
Local cCondAprov	:= ""	//JUL 06/06/2017
local nRegAtual		:= 0
local nCtrlReg		:= 0
Private lTeveDiv	:= .F.

* TIRAR SE AUTO OK   ???????
//[LEO] - 14/07/17 Validações do Varejo
if ! U_vareTdOk()
	return(.F.)
endif

if FwIsInCallStack('MATA416')
	if Type('oGetDad') <> "U"
		nRegAtual 	:= oGetDad:oBrowse:nAt
		oGetDad:oBrowse:goBottom()
		nCtrlReg	:= oGetDad:oBrowse:nAt
		oGetDad:oBrowse:GoTop()
		while .T.		
			oGetDad:oBrowse:GoDown()
			if nCtrlReg == oGetDad:oBrowse:nAt
				EXIT
			endIf
		endDo
		oGetDad:oBrowse:goPosition(nRegAtual)
	endif
endif

lShow := .F. // Só para documentação -> Não mostrar tela do obrigatório
lObrig := Obrigatorio(aGets,aTela,,lShow)
If Type("_aCols2") == "U"      //nao usar este
	_aCols2 := {}
EndIf

/*LEO - 26/06/20 Evitar qualquer mudança em um pedido multifilial*/
if  !Inclui .and. !Empty(M->(C5_X_IDVEN))
	u_autoAlert("Este pedido possui divisão multifilial",,'MsgBox')
	return(.F.)
endif

/*
	LEO - 08/02/17 Preencher o campo C6_XFTPVC com conteudo do B1_VALPVP
	utilizado posteriormente no calculo da IMP (indice de materia prima)
*/
oImp := cbcImpService():newcbcImpService()
oImp:putPvpPed(aHeader,aCols)
freeObj(oImp)

/*LEO - 10/11/16 -TRATAMENTO CONDIÇÃO DE PAGAMENTO BNDES
	Sendo que pedidos incluidos/gravado com condição de pagamento BNDES
	uma vez incluidos nesta condição não podem ser mais alterar a condição de pagamento
	outras alterações pode fazer.
	Bem como os pedidos inluidos/gravados com condição de pagamento diferente de BNDES
	não podem mais ser alterados para BNDES.
	Por que agora a condição de pagamento é fator que determina a Industrialização. e uma vez incluido
	com BNDES gerou o pedido na outra ponte "PEDINDL", e alterar a condição do pedido original
	pode mudar completamente a divisão que foi feita. o correto é excluir a contra-parte em itu
*/
If Altera
	oPed 	:= cbcPedido():newcbcPedido(M->C5_NUM)
	lBndes 	:= oPed:isEqual('C5_CONDPAG','000')
	lPedRet	:= .T.
	If lBndes .And. M->(C5_CONDPAG) != '000'
		U_AutoAlert('[ERRO] - Uma vez o pedido cadastrado como BNDES não pode mais ser alterado!')
		lPedRet := .F.
	Else
		If M->(C5_CONDPAG) == '000' .And. !lBndes
			U_AutoAlert('[ERRO] - Pedido não BNDES, não podem ser alterados para BNDES!')
			lPedRet := .F.
		EndIf
	EndIf
	If !lPedRet
		FreeObj(oPed)
		Return(.F.)
	EndIF
EndIF
//FIM LEO 10/11/16

//LEO - 01/08/16 -EXPIRAR RESERVA PORTAL AO EXCLUIR/ALTERAR PEDIDO
//DELETANDO
if !Altera .And. !Inclui

	/*[LEO]-[21/11/16] - Enviar espelho do pedido quando cancelado*/
	If  M->(C5_ZZSMAIL) == 'S'
			pedMirr := cbcPedido():newcbcPedido(M->(C5_NUM))
			pedMirr:sendMirror(.F., .F., .T.)
			FreeObj(pedMirr)
	EndIF
	/*[LEO]-[21/11/16]-[FIM]*/

	//LEO = 13/10/16 AO DELETAR SE EXISTIR DIVISÂO PEDIDO AVISAR PEDIDO NA OUTRA FILIAL
	U_checkDiv(M->C5_NUM)
	oOrder := CbcInternalReserves():newCbcInternalReserves()
	oOrder:killOrder(aHeader,aCols)
	FreeObj(oOrder)
//INCLUINDO/ALTERANDO
Else
	oOrder := CbcInternalReserves():newCbcInternalReserves()
	oOrder:orderOk(aHeader,aCols)
	If !oOrder:lOk
		FreeObj(oOrder)
		Return(.F.)
	EndIf
	FreeObj(oOrder)
EndIf
//FIM LEO 01/08/16

// Verificar a data de entrega conforme Crispilho - 05/01/12

If  M->C5_TIPO $ "N" .And. !_SetAutoMode() .And. (!Altera .And. !Inclui) .And.  FWCodFil() == "02" .And. !u_turnOff()

	If !u_sDelPed(aCols, aHeader)
		Return(.F.)
	EndIf

EndIf

// Roberto Oliveira 26/11/10
If M->C5_TIPO # "N" .Or. (!Inclui .And. !Altera)  //Não Inclui e não Altera ou seja EXCLUI!
	//TODO LEO quando EXCLUIR, Cancelar as reservas no portal
	Return(.T.)
EndIf

If M->C5_DRC > 0 .And. Empty(M->C5_DRCPROD) // Tem uma devolução e não disse se vai ou não produzir
	u_autoAlert("Informar se o PCP deverá ou não produzir os materiais desse pedido")
	Return(.F.)
EndIf

If M->C5_TIPO == "N" .And. (Inclui .Or. Altera)
	// Alteração de 09/04/2015 solicitada por Denise/Jeferson
	// Buscar dados dos parâmetros MV_X_COND0 , 1, 2, 3 , 4
	If !u_ValCondPg("SC5",M->C5_EMISSAO,M->C5_CONDPAG,M->C5_CLIENTE+M->C5_LOJACLI)
		Return(.F.)
	EndIf

	//LEO - NOVO CONCEITO PARA REGRAS DE INDUSTRIALIZAÇÂO
	oIndl 	:= CbcIndRules():newCbcIndRules(M->C5_CLIENTE, M->C5_LOJACLI, M->C5_NUM, .F., .T.)
	//CARREGA AS REGRAS
	oIndl:configOper()
	DbSelectArea("SC6")
	DbSetOrder(1)
	//Verifica as condições para conjunto armazenador (191)
	lConjArmz := .F.
	For nI:= 1 to Len(aCols)
		If !GDDeleted(nI)
			// 22/01/20 - Novas Regras para Minas
			if !isInCallStack('U_ZCBVIEWPED')
				//Verifica as condições para conjunto armazenador (191)
				If Left(Alltrim(GDFieldGet("C6_PRODUTO",nI)),3) == "191" .AND.;
				 	Empty(M->C5_ZZAPR) .and. M->C5_TIPO $ "N" .and. FWCodFil() == "02"	
					lConjArmz := .T.
					//Solicita Condição Especifica.
					aAdd(aParamBox,{1,"Regra de Industrialização","  ","","","Z7","",2,.F.})
					If !ParamBox(aParamBox,"Parametros", @aRet)
						Return(.F.)
					EndIf
					M->C5_ZZAPR := aRet[1]
					lConjArmz := .T.	
				EndIf
				//Valida o Pedido para que contenha apenas conjuntos armazenadores
				If lConjArmz .and. !(Left(Alltrim(GDFieldGet("C6_PRODUTO",nI)),3) == "191") .and. nI > 1
					u_autoAlert("Pedido Só pode conter Conjuntos Armazenadores e Expositores, Favor Corrigir!")
					Return (.F.)
				EndIf
			endif
			
			//Leonardo (Fazer Somente para pedido tipo normal)
			If M->C5_TIPO $ "N" .And. !u_turnOff()
				_aPar := {}

				Aadd(_aPar,"valArmaz")
				Aadd(_aPar,Alltrim(M->C5_CLIENTE))
				Aadd(_aPar,AllTrim(M->C5_LOJACLI))
				Aadd(_aPar,Alltrim(M->C5_TIPO))
				Aadd(_aPar,AllTrim(GDFieldGet("C6_TES",nI)))
				
				// u_vPedReg Retorna (.T.)= APLICAR ROTINA  (.F.) = NÃO APLICAR ROTINA
				//Alteração para Expositor e Cojunto Armaz Juliana 19/05/2017
				If !Empty(Alltrim(GDFieldGet("C6_ACONDIC",nI))) .or. (Left(Alltrim(GDFieldGet("C6_PRODUTO",nI)),3) == "191") 
					If u_vPedReg(_aPar)
						GDFieldPut("C6_LOCAL",u_valProdu( Alltrim(M->C5_CLIENTE), AllTrim(M->C5_LOJACLI),AllTrim(GDFieldGet("C6_PRODUTO",nI)),nI,oIndl),nI)

					ElseIf GDFieldGet("C6_LOCAL",nI) == '10' .And.;
						SubStr(Posicione("SA1",1,xFilial("SA1")+M->(C5_CLIENTE)+M->(C5_LOJACLI),"A1_CGC"),1,8) # "02544042"
						GDFieldPut("C6_LOCAL",'01',nI)
					EndIf
				EndIf

				//Não validou a Cliente(Região) OU o Armazem esta vazio (ver "pedindl.pwr" Cliente sem estado(A1_EST) ou Produto sem Cor(B1_COR)
				If !u_valRegiao(Alltrim(M->C5_CLIENTE), AllTrim(M->C5_LOJACLI) ) .Or. Empty(GDFieldGet("C6_LOCAL",nI))
					Return (.F.)
				EndIf

				If Altera .And. FWCodFil() == "02" .And. !Empty(GDFieldGet("C6_ZZPVORI",nI))
					If !U_vPedReg({"podeAlterar",{aCols[nI]},"" }) .And. (u_temAlt({aCols[nI]}) .Or. GDDeleted(nI))
						u_autoAlert("O Item:" + GDFieldGet("C6_ITEM",nI) + " deste pedido esta relacionado com Pedido+Item de industrialização Numero: " + GDFieldGet("C6_ZZPVORI",n) + ;
						" em Itu É não pode ser alterado (Resumo/Bloqueado/Faturado)"  )
						Return(.F.)
					EndIf

				EndIf

			EndIf

			//Fim Leonardo

			If !Empty(AllTrim(GDFieldGet("C6_X_FLDES",nI)+GDFieldGet("C6_X_PVDES",nI)+GDFieldGet("C6_X_ITDES",nI)))
				If Empty(GDFieldGet("C6_X_FLDES",nI)) .Or. Empty(GDFieldGet("C6_X_PVDES",nI)) .Or. Empty(GDFieldGet("C6_X_ITDES",nI))
					u_autoAlert("Informar Corretamente Filial, Pedido e Item a que se Destina" + Chr(13) + Chr(13) +;
					"A - Item " +  GDFieldGet("C6_ITEM",nI))
					Return(.F.)
				ElseIf !SC6->(DbSeek(GDFieldGet("C6_X_FLDES",nI)+GDFieldGet("C6_X_PVDES",nI)+GDFieldGet("C6_X_ITDES",nI),.F.))
					u_autoAlert("Pedido/Item não existe na filial de destino" + Chr(13) + Chr(13) +;
					"B - Item " +  GDFieldGet("C6_ITEM",nI))
					Return(.F.)
				ElseIf !Empty(SC6->C6_SEMANA)
					If Left(SC6->C6_SEMANA,1) # "T"
						u_autoAlert("Dados do Pedido de Origem Inválidos" +Chr(13) + Chr(13) + ;
						"O Pedido " + GDFieldGet("C6_X_PVDES",nI)+"/"+ GDFieldGet("C6_X_ITDES",nI) + "Já Foi Programado")
						Return(.F.)
					ElseIf SC6->C6_SEMANA # ("T"+M->C5_NUM)
						u_autoAlert("Dados do Pedido de Origem Inválidos" +Chr(13) + Chr(13) + ;
						"O Pedido " + GDFieldGet("C6_X_PVDES",nI)+"/"+ GDFieldGet("C6_X_ITDES",nI) + "Já tem Transferência")
						Return(.F.)
					EndIf
				Else
					SC6->(DbSeek(xFilial("SC6")+ M->C5_NUM + GDFieldGet("C6_ITEM",nI)))
					If SC6->C6_PRODUTO # GDFieldGet("C6_PRODUTO",nI)
						// Alteração realizada em 17/12/13 pois estava comparando produto nacional com o importado
						// que na verdade é o mesmo.
						_cPrdNIa := AllTrim(SC6->C6_PRODUTO)
						_cPrdNIb := AllTrim(GDFieldGet("C6_PRODUTO",nI))
						If "I" == Right(_cPrdNIa,1) .Or. "I" == Right(_cPrdNIb,1)
							// Suponho que um dos dois é importado, então verifico o código raiz
							_nTamPq  := Min(Len(_cPrdNIa),Len(_cPrdNIb))
							If Left(_cPrdNIa,_nTamPq) # Left(_cPrdNIb,_nTamPq)
								u_autoAlert("Alteração do Produto não Permitida!" + Chr(13) + Chr(13) +;
								"C - Item " +  GDFieldGet("C6_ITEM",nI))
								Return(.F.)
							EndIf
						Else
							u_autoAlert("Alteração do Produto não Permitida!" + Chr(13) + Chr(13) +;
							"C - Item " +  GDFieldGet("C6_ITEM",nI))
							Return(.F.)
						EndIf
					EndIf
				EndIf
			EndIf //ElseIf "RESERVA" $ GDFieldGet("C6_SEMANA",n)       atenção neste aqui	u_autoAlert("Não é Permitido a Exclusão de Itens Reservados")	Return(.F.)

			// Atenção:
			// Pedidos da Huawei tem que obrigatoriamente estar preenchido os campos C6_ITPDCLI/C6_PEDCLI /C6_POSHPHU,
			// pois estes farão parte do XML da NFe.
			If "HUAWEI" $ Upper(Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_NOME"))
				If Empty(GDFieldGet("C6_ITPDCLI",nI)) .Or. Empty(GDFieldGet("C6_PEDCLI",nI)) .Or. Empty(GDFieldGet("C6_POSHPHU",nI))
					u_autoAlert("Atenção:" + Chr(13) + Chr(13) +;
					"Os campos Pedido do Cliente, Item do Pedido e P.O. Shipment" + Chr(13) +;
					"devem estar Preenchidos")
					Return(.F.)
				EndIf
			EndIf
		EndIf

		//Alteração Valida Pedidos sem Acondicionamento em qualquer item    Alt: Juliana Leme (27/11/2014)
		//If M->C5_TIPO == "N" .And. Posicione("SB1",1,xFilial("SB1")+GDFieldGet("C6_PRODUTO",n),"B1_TIPO") == "PA"
		If M->C5_TIPO == "N" .And. Posicione("SB1",1,xFilial("SB1")+GDFieldGet("C6_PRODUTO",nI),"B1_LOCALIZ") == "S"
			If (Empty(GDFieldGet("C6_ACONDIC",nI)) .Or. Empty(GDFieldGet("C6_LANCES",nI)) .Or. Empty(GDFieldGet("C6_METRAGE",nI))) .And.;
				!aCols[nI,Len(aCols[nI])]
				u_autoAlert("Os campos Acondicionamento, Lances e Metragem devem ser preenchidos para Produtos Acabados!")
				Return(.F.)
			Endif
		Endif
		//Fim Alteração
	Next
	//LEONARDO - Chamada para função que aplica regra dos valores minimos (somente nos pedidos que tiveram divisão)
	If lTeveDiv
		u_divPedido()
	EndIf

EndIf
If Inclui .And. !Empty(M->C5_TABELA)
	DbSelectArea("SZX")
	DbSetOrder(2) //ZX_FILIAL+ZX_CODTAB
	SZX->(DbSeek(xFilial("SZX")+M->C5_TABELA,.F.))

	DbSelectArea("SZY")
	DbSetOrder(1) // ZY_FILIAL+ZY_CODIGO+ZY_ITEM
	SZY->(DbSeek(xFilial("SZY")+SZX->ZX_CARTA,.F.))
	M->C5_DESCPAD := SZY->ZY_DESCPAD
EndIf

_lVolta   := .T.
_TESCli   := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_TES")
_UFCli    := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_EST")
_CGCCli   := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_CGC")
_lConstru := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_CONTRUT")=="S"
_lCtrb    := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_CONTRIB")=="1"

_lTesDif := .F.

// Divisão Política do Brasil
// Norte: 			AM, PA, AC, RO, RR, AP e TO.
// Nordeste: 		MA, PI, CE, RN, PB, PE, AL, SE, BA.
// Centro-oeste: 	GO, MT, MS e DF.
// Sudeste: 		SP, RJ, MG e ES.
// Sul: 			PR, SC e RS.

_cMyNorte := "AM//PA//AC//RO//RR//AP//TO//"
_cMyNodte := "MA//PI//CE//RN//PB//PE//AL//SE//BA//"
_cMyCtOst := "GO//MT//MS//DF//"
_cMySdste := "SP//RJ//MG//ES//"
_cMySul   := "PR//SC//RS//"


// Se for a propria cobrecom ou for construtora
// não fazer esta validação

// Atenção O IF abaixo está sendo substituído pela função User Function ConfFil()
// conforme determinação do Rafael/Denise 11/04/13
If "02544042" # Left(_CGCCli,8) .And. Inclui .And. ;
	M->C5_CLIENTE+M->C5_LOJACLI # "01565801" .And. M->C5_CLIENTE+M->C5_LOJACLI # "01622701" .And. ;
	M->C5_CLIENTE+M->C5_LOJACLI # "01701001" .And. M->C5_CLIENTE+M->C5_LOJACLI # "01701101" .And. ;
	M->C5_CLIENTE+M->C5_LOJACLI # "01133701"

	// Não é Ifc e estou incluindo
	// Regra válida a partir de Janeiro/2013 - As demais regras são revogadas
	// cliente 015658-01 - LOOK METAIS INDUSTRIA E COMERCIO LTDA
	// cliente 016227-01 - I.C.A LIGAS DE ALUMINIO LTDA

	// Em 17/06/14 Vânia solicitou inclusão dos dois clientes abaixo
	// 017010 - DAFMETAL INDUSTRIA E COMERCIO DE METAIS - EIRELI
	// 017011 - LINGOMETAL INDUSTRIA E COM. DE METAIS LTDA

	// Em 22/05/15 incluído o cliente 011337-01-SANHIDREL INSTALACOES E COMERCIO LTDA conforme
	// CI de 21/05/15 assinado por Cristiane e autorizado por Denise, a mim entregue em 22/05/15
	// as 09:37 h.
	If .F.  //u_turnOff()

		// By Leonardo e Roberto Oliveira
		// Foi colocado o If .F. devido a novas Regras a partir de 30/10/2014.
		// Para desabilitar essas novas regras, procurar nos fontes as chamadas das
		// função u_turnOff().
		// Vide email:
		/*/
		// Solicitação de 29/10/2014. Email da denise conforme abaixo:
		Boa tarde, senhores:

		O Rafael /Gustavo em reunião hoje alteraram o faturamento de todas as Construtoras e
		Consumidores Finais ( contribuintes ou não do ICMS ), deverão sair por Itu a partir de
		agora observando as seguintes regras:

		1-	Construtoras e Consumidores Finais ( Contribuintes de ICMS )-deverão sair com
		original NACIONAL ( Alíquota de ICMS do estado destinatário ),
		2-	Construtoras e Consumidores Finais ( NÃO Contribuintes de ICMS )-deverão sair
		com original de  IMPORTADO ( Alíquota de ICMS do estado remetente nesta caso SP 18% ),
		3-	Os pedidos em carteira até hoje 30/10/14 seguirão ainda regra anterior.

		- Peço ao nosso departamento de T.I. que tome as providências necessárias junto ao Sistema.

		Desde já, obrigada.

		/*/
		_lIsConsFin := (_lConstru .Or. M->C5_TIPOCLI == "F") // É construtora ou o pedido é para consumidor final

		If SM0->M0_ESTENT == "SP" .And. _UFCli == "MS"
			// Denise ligou 07/11/14 17:30h disse que clientes de MS por 3 Lagoas
			u_autoAlert("Clientes do Estado de Mato Grosso do Sul o faturamento deverá ser por Tres Lagoas")
			_lVolta := .F.
		ElseIf SM0->M0_ESTENT == "MS" .And. _lIsConsFin .And. _UFCli # "MS"
			// Estou incluindo em 3 Lagoas e é construtora ou Cons.Final
			// Denise ligou 07/11/14 17:30h disse que clientes de MS por 3 Lagoas
			u_autoAlert("Atenção - Pedidos para Construtoras ou Para Cons.Final Somente por Itu")
			_lVolta := .F.
		ElseIf SM0->M0_ESTENT == "MS" .And. _UFCli $ _cMySdste
			// Não pode -> Para Sul e Sudeste, somente por ITU
			u_autoAlert("Clientes das regiões Sudeste e Sul o Faturamento deverá ser por Itú")
			_lVolta := .F.
		ElseIf SM0->M0_ESTENT == "SP" .And. _UFCli $ _cMyNorte+_cMyNodte+_cMySul+_cMyCtOst .And. !_lIsConsFin
			u_autoAlert("Clientes das regiões Norte, Nordeste, Centro-Oeste e Sul o faturamento deverá ser por Tres Lagoas")
			_lVolta := .F.
		EndIf
	EndIf
EndIf

If SM0->M0_ESTENT == "SP" .And. _UFCli == "MS" .And. M->C5_TIPOCLI == "S" .And. u_turnOff()
	u_autoAlert("Faturamento de São Paulo para Mato Grosso do Sul -> Tipo do Cliente -> Não pode ser Solidário")
	_lVolta := .F.
EndIf

If _lVolta .And. M->C5_TIPO == "N"
	// Verifico se é venda....e não é TES 505
	// ou se o TES não movimenta estoque nem financeiro
	SF4->(DbSetOrder(1))
	_lGravar := .T.
	_lSoNota := .T.
	For _i := 1 To Len(aCols)
		If !GDDeleted(_i)
			_cTES := GDFieldGet("C6_TES",_i)
			If "S" $ Posicione("SF4",1,xFilial("SF4")+_cTES,"F4_DUPLIC+F4_ESTOQUE")
				_lSoNota := .F.
			EndIf
			If _cTES == "505" .And. M->C5_EMISSAO < Ctod("01/09/2015")
				_lGravar := .F.
				M->C5_DESCESP := 0
				M->C5_DESCEQT := 0
				Exit
			ElseIf Posicione("SF4",1,xFilial("SF4")+_cTES,"F4_DUPLIC") == "S"
				Exit
			EndIf
			If !_lTesDif .And. !Empty(_TESCli) .And. _TESCli # _cTES
				_lTesDif := .T.
			EndIf
		EndIf
	Next
	If _lSoNota
		M->C5_DESCESP := 0
		M->C5_DESCEQT := 0
	EndIf

	If _lGravar
		DbSelectArea("SA1")
		DbSetOrder(1)
		DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,.F.)
		//Valido de novo a regra de desconto
		_MyDescV := M->C5_DESCESP
		_MyDescQ := M->C5_DESCEQT
		u_ConfDesc(.F.)
		If _MyDescV # M->C5_DESCESP .Or. _MyDescQ # M->C5_DESCEQT
			u_autoAlert("Regra de Desconto Inválida!! Assumido Padrão",.F.)
		ElseIf !_lSoNota  .And. u_turnOff()
			DbSelectArea("SA1")
			DbSetOrder(1)
			DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,.F.)
			RecLock("SA1",.F.)
			SA1->A1_DESCVLR := If(M->C5_DESCESP==0,100,M->C5_DESCESP)
			SA1->A1_DESCQTD := If(M->C5_DESCEQT==0,100,M->C5_DESCEQT)
			MsUnLock()
		EndIf
	EndIF
EndIf

//Validação p/ BNDES
If M->C5_TIPO == "N" .And. M->C5_CONDPAG == "000"
	If M->C5_DESCESP > 0 .Or. M->C5_DESCEQT > 0
		_lVolta := .F.
		u_autoAlert("Pedidos com condição de pagamento BNDES, somente 100%")
	EndIf
EndIf

If (Inclui .Or. Altera) 
	If M->(C5_PARCIAL) == 'S' .and. M->(C5_CONDPAG) $( '000//097/413')
		_lVolta := .F.
		U_AutoAlert('[ERRO] - Pedido BNDES ou A VISTA  ANTECIPADO(Cond.Pagto = "000"/ "097"/"413") não podem ser PARCIAL = "SIM, Favor Verificar!"')
	EndIf
EndIf

//Validação p/ Pedidos de 3 Lagoas
If FWCodEmp()+FWCodFil() == "0102" /// Cobrecom 3 Lagoas
	If M->C5_DESCESP > 0 .Or. M->C5_DESCEQT > 0
		_lVolta := .F.
		u_autoAlert("Pedidos de 3 Lagoas, somente 100%")
	EndIf
EndIf

//Somente se for alteração e passou em todas as validações
If _lVolta .And. Altera .And. FWCodEmp()+FWCodFil() == "0102" .And. M->(C5_TIPO) == "N"
	//Sincronizar quando 3L com o pedido de (INDL ITU)
	_lVolta := u_sAltPed(aCols, aHeader)
EndIF

// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO
// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO
// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO/// ATENÇÃO

// A partir deste ponto não pode retornar .F. em _lVolta
// Caso tenha alguma validação a fazer que deva retornar .F. para _lVolta, desenvolver acima desta linha

If !U_isDivid()
	If _lVolta .And. lObrig .And. M->C5_TIPO == "N" .And. M->C5_CONDPAG == "000" .And. M->C5_EMISSAO > Ctod("12/04/2015")
		_aTam:=TamSX3("C6_PRCVEN")
		For _i := 1 To Len(aCols)
			If !GDDeleted(_i)
				_nPrcVen := GDFieldGet("C6_PRCVEN",_i)
				_nPrcVen += ((_nPrcVen * 2.8) / 100)
				_nPrcVen := Round(_nPrcVen,_aTam[2])
				GDFieldPut("C6_PRCVEN",Round(_nPrcVen,TamSX3("C6_PRCVEN")[2]),_i)
				GDFieldPut("C6_VALOR" ,Round((GDFieldGet("C6_QTDVEN",_i)*GDFieldGet("C6_PRCVEN",_i)),TamSX3("C6_VALOR")[2]),_i)
			EndIf
		Next
	EndIf
EndIf
/*VALIDAÇÃO TABELA DE PRECO EDVAR*/
_cCnpj := Left(Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_CGC"),8)
If M->C5_TIPO == "N" .And. _cCnpj # "02544042" .And. ;
	M->C5_CLIENTE+M->C5_LOJACLI # "01565801" .And. ;
	M->C5_CLIENTE+M->C5_LOJACLI # "01622701" .And. ;
	M->C5_CLIENTE+M->C5_LOJACLI # "01701001" .And. ;
	M->C5_CLIENTE+M->C5_LOJACLI # "01701101"
	//Só válido se o pedido for normal e o cliente não for IFC ou Look Metais ou I.C.A

	// Em 17/06/14 Vânia solicitou inclusão dos dois clientes abaixo
	// 017010 - DAFMETAL INDUSTRIA E COMERCIO DE METAIS - EIRELI
	// 017011 - LINGOMETAL INDUSTRIA E COM. DE METAIS LTDA

	_nTotPV := 0
	lOK     := .F.
	cTabela := M->C5_TABELA
	u_CalcComis("SC5") // Faz o cálculo das comissões item a item do pedido
	If Alltrim(cUserName)+"|" $ GetMv("MV_USERLIB")
		//If "DANIELA" $ Alltrim(cUserName)
		M->C5_AUTORIZ := Alltrim(cUserName)
	Else
		lMoviment := .F. // .F. = Não há movimentação  -> .T. = há movimentação
		For nI:= 1 to Len(aCols)
			_nTotPV += GDFieldGet("C6_QTDVEN",nI) * GDFieldGet("C6_PRCVEN",nI)

			//VERIFICAR SE TES MOVIMENTA ESTOQUE / FINANCEIRO
			_cDuplic := Posicione("SF4",1,xFilial("SF4")+GDFieldGet("C6_TES",nI),"F4_DUPLIC")
			_cEstoq  := Posicione("SF4",1,xFilial("SF4")+GDFieldGet("C6_TES",nI),"F4_ESTOQUE")
			_cOpSuc  := Posicione("SF4",1,xFilial("SF4")+GDFieldGet("C6_TES",nI),"F4_OPERSUC")

			If (_cDuplic == "S" .Or. _cEstoq == "S") .And. _cOpSuc # "1"
				//Se não movimenta e não for operação com sucata, pode liberar
				lMoviment := .T.
				// Verificar se tem algum item que esteja com o valor abaixo do desconto máximo
			EndIf
			//SC6->(dbSkip()) ???? O QUE FAZ ESTE DBSKIP AQUI ????
		Next

		If lMoviment
			DbSelectArea("SZX")
			DbSetOrder(2) //ZX_FILIAL+ZX_CODTAB
			SZX->(DbSeek(xFilial("SZX")+cTabela,.F.))
			//POSICIONO NO ZX
			_ZX_CONDPG1 := ""
			_ZX_CONDPG2 := ""
			_nProx :=  -1
			_cCarta := "  "
			Do While !SZX->(Eof()) .And. xFilial("SZX") == SZX->ZX_FILIAL .And. Alltrim(SZX->ZX_CODTAB) == Alltrim(cTabela)
				_cCarta := SZX->ZX_CARTA
				If _nTotPV >= SZX->ZX_VLRINI //.And. _nTotPV <= SZX->ZX_VLRFIM
					If _nProx == -1 .Or. _nProx > (SZX->ZX_VLRFIM - _nTotPV) // Primeira vez ou tem um registro mais exato
						_nProx := SZX->ZX_VLRFIM - _nTotPV
						_ZX_CONDPG1 := SZX->ZX_CONDPG1
						_ZX_CONDPG2 := SZX->ZX_CONDPG2
						lOK := .T.
					EndIf
				EndIf
				SZX->(dbSkip())
			EndDo

			If lOk
				//Formula Somatoria ( Dias * Valor parcela ) / Valor Total

				// Calculo Prazo Medio Pedido de Venda
				nSomat  := 0
				aCond   := Condicao(_nTotPV,M->C5_CONDPAG,,M->C5_EMISSAO)
				For nI := 1 to Len(aCond)
					nSomat += (aCond[nI,1] - M->C5_EMISSAO) * aCond[nI,2]
				Next
				nPrazoPV := Int(nSomat / _nTotPV)

				// Calculo Prazo Medio Tabela Preço
				// Igualo os dois prazos para ter um valor inicial
				nPrazo01 := nPrazoPV
				nPrazo02 := nPrazoPV
				For nJ := 1 to 2
					If nJ == 1
						_xPrz := _ZX_CONDPG1
					Else
						_xPrz := _ZX_CONDPG2
					EndIf
					If Empty(_xPrz)
						Loop
					EndIf

					aCond := condicao(_nTotPV,_xPrz,,M->C5_EMISSAO)
					nSomat  := 0
					For nI := 1 to Len(aCond)
						nSomat += (aCond[nI,1] - M->C5_EMISSAO) * aCond[nI,2]
					Next
					If nJ == 1
						nPrazo01 := Int(nSomat / _nTotPV)
					Else
						nPrazo02 := Int(nSomat / _nTotPV)
					EndIf
				Next

				_C5_AUTORIZ := ""
				If nPrazoPV < nPrazo01 .Or. nPrazoPV < nPrazo02
					_C5_AUTORIZ := "PRAZO"
				EndIf
				If Empty(_cCarta)
					If !Empty(_C5_AUTORIZ)
						_C5_AUTORIZ += "+"
					EndIf
					_C5_AUTORIZ += "S/CARTA"
				Else
					// Calcular se os preços estão dentro da carta de desconto
					For nI := 1 to Len(aCols)
						If !GDDeleted(nI)
							_cTES     := GDFieldGet("C6_TES",nI)
							_cDuplic  := If(Empty(_cTES),"  ",Posicione("SF4",1,xFilial("SF4")+_cTES,"F4_DUPLIC"))
							If _cDuplic == "N"
								Loop
							EndIf
							_cProduto := GDFieldGet("C6_PRODUTO",nI)
							_nPrcVen  := GDFieldGet("C6_PRCVEN",nI)
							_cAcond   := GDFieldGet("C6_ACONDIC",nI) + StrZero(GDFieldGet("C6_METRAGE",nI),5)
							_PrcTab   := u_TabBruto(M->C5_TABELA,_cProduto,_cAcond)

							/*/
							_PrcTab   := 0
							DbSelectArea("DA1")
							DA1->(DbSetOrder(1)) // DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
							If DA1->(DbSeek(xFilial("DA1")+M->C5_TABELA+_cProduto,.F.))
								If _cAcond == "R00050" .And. DA1->DA1_PRC50M > 0
									_PrcTab := DA1->DA1_PRC50M
								ElseIf _cAcond == "R00015" .And. DA1->DA1_PRC15M > 0
									_PrcTab := DA1->DA1_PRC15M
								Else
									_PrcTab := DA1->DA1_PRCVEN
								EndIf
							EndIf
							/*/

							If _PrcTab == 0
								// Não tem preço na tabela
								If !Empty(_C5_AUTORIZ)
									_C5_AUTORIZ += "+"
								EndIf
								_C5_AUTORIZ += "FORA PRECO"
								Exit // Não preciso ver o resto
							EndIf

							// Verificar se tem adicional de desconto - Tabela SZW
							_cAdicDes := u_CalcAdic(M->C5_TABELA,M->C5_VEND1,_cProduto,.F.) // O ultimo parâmento é pra retornar o que era (.F.) ou o array (.T.)
							_cDescVis := Posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_AVISTA")
							// Verificar carta de descontos
							// Calcular o menor preço possível
							_nValMim := _PrcTab
							DbSelectArea("SZY")
							DbSetOrder(1) // ZY_FILIAL+ZY_CODIGO+ZY_ITEM
							SZY->(DbSeek(xFilial("SZY")+_cCarta,.F.))

							If _cDescVis == "S" .And. SZY->ZY_DESCVIS > 0
								_cAdicDes := AllTrim(_cAdicDes) + "+" + AllTrim(Str(SZY->ZY_DESCVIS,10,2))
							EndIf
							Do While SZY->ZY_FILIAL == xFilial("SZY") .And. SZY->ZY_CODIGO == _cCarta .And. SZY->(!Eof())
								_ZY_DESCONT := AllTrim(SZY->ZY_DESCONT)+_cAdicDes+"Z" // Colocar o Z no final pra poder calcular o ultimo
								_nValLiq := _PrcTab
								_nPerc := ""
								For _nPrc := 1 To Len(_ZY_DESCONT)
									If Substr(_ZY_DESCONT,_nPrc,1) $ "1234567890"
										_nPerc += Substr(_ZY_DESCONT,_nPrc,1)
									ElseIf Substr(_ZY_DESCONT,_nPrc,1) $ ".,"
										_nPerc += "."
									Else
										If Val(_nPerc) > 0
											_nPerc := Val(_nPerc)
											//If Substr(_ZY_DESCONT,_nPrc,1) == "Z" //é o último cara
											//	_nApliPer := Round((_nValLiq * _nPerc) / 100,4)
											//	_nValLiq := Round(_nValLiq - _nApliPer,4)
											//Else
											_nApliPer := (_nValLiq * _nPerc) / 100
											_nValLiq := _nValLiq - _nApliPer
											//EndIf
										EndIf
										_nPerc := ""
									EndIf
								Next
								_nValMim := Min(_nValMim,Round(_nValLiq,4))
								SZY->(DbSkip())
							EndDo

							If _nPrcVen < _nValMim
								// Não tem preço na tabela
								If !Empty(_C5_AUTORIZ)
									_C5_AUTORIZ += "+"
								EndIf
								_C5_AUTORIZ += "FORA PRECO"
								Exit // Não preciso ver o resto
							EndIf
						EndIf
					Next
				EndIf
				M->C5_AUTORIZ := _C5_AUTORIZ
			Else
				M->C5_AUTORIZ := "SEM TABELA"
			EndIf
		Else
			M->C5_AUTORIZ := " "
		EndIf
	EndIf
Else
	M->C5_AUTORIZ := " "
EndIf


If _lVolta
	If !Inclui // Exclui ou Altera
		SZZ->(DbSetOrder(1)) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
		SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM,.F.))
		Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())
			If SZZ->(DbSeek(xFilial("SZZ") + SC6->C6_RES_SZZ + SC6->C6_ITE_SZZ,.F.))
				RecLock("SZZ",.F.)
				SZZ->ZZ_QTDPED -= SC6->C6_QTDVEN
				MsUnLock()
			EndIf
			SC6->(DbSkip())
		EndDo
	EndIf
	If (INCLUI .Or. ALTERA) .and. (!isInCallStack('U_ZCBVIEWPED'))
		// Se for digitado uma DRC - Gravar os campos C5_SEMANA e C6_SEMANA
		_cNumDRC := "       " // O campo C6_SEMANA é C 7.
		If M->C5_DRC > 0
			If M->C5_DRCPROD == "N"
				_cNumDRC := "DRC"+StrZero(M->C5_DRC,4) // O campo C6_SEMANA é C 7.
				M->C5_SEMANA := _cNumDRC
			ElseIf Left(M->C5_SEMANA,3) == "DRC"
				_cNumDRC := "       " // O campo C6_SEMANA é C 7.
				M->C5_SEMANA := _cNumDRC
			EndIf
		ElseIf Left(M->C5_SEMANA,3) == "DRC"
			_cNumDRC := "       " // O campo C6_SEMANA é C 7.
			M->C5_SEMANA := _cNumDRC
		EndIf

		// Gravar o SZZ das Reservas digitadas no Pedido de Vendas
		_cItResC6 := ""
		SZZ->(DbSetOrder(1)) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
		For _nx :=1 to Len(aCols)
			If !GDDeleted(_nx)
				_lGravei := .F.
				If !Empty(GDFieldGet("C6_RES_SZZ",_nx)) .And. !Empty(GDFieldGet("C6_ITE_SZZ",_nx))
					If SZZ->(DbSeek(xFilial("SZZ") + GDFieldGet("C6_RES_SZZ",_nx)+GDFieldGet("C6_ITE_SZZ",_nx),.F.))
						RecLock("SZZ",.F.)
						If SZZ->ZZ_QTDPED == 0.00
							SZZ->ZZ_QTDPED += GDFieldGet("C6_QTDVEN",_nx)
							SZZ->ZZ_TIPO := "1" // 0=A Confirmar;1=Confirmada -> Se não estiver confirmada, confirma agora
							GDFieldPut("C6_SEMANA","RESERVA",_nx)
							GDFieldPut("C6_QTDRES",GDFieldGet("C6_QTDVEN",_nx),_nx)
							_lGravei := .T.
						EndIf
						MsUnLock()
					EndIf
				ElseIf Empty(GDFieldGet("C6_RES_SZZ",_nx)) .And. Empty(GDFieldGet("C6_ITE_SZZ",_nx))
					_lGravei := .T.
				EndIf
				If !_lGravei
					GDFieldPut("C6_RES_SZZ",Space(Len(SC6->C6_RES_SZZ)),_nx)
					GDFieldPut("C6_ITE_SZZ",Space(Len(SC6->C6_ITE_SZZ)),_nx)
					GDFieldPut("C6_SEMANA" ,Space(Len(SC6->C6_SEMANA )),_nx)
					GDFieldPut("C6_QTDRES" ,0.00,_nx)
					If !Empty(_cItResC6)
						_cItResC6 := _cItResC6 + ", "
					EndIf
					_cItResC6 := _cItResC6 + GDFieldGet("C6_ITEM",_nx)
				EndIf

				// Grava o Nro.da DRC no campo C6_SEMANA para não produzir, reservar ou avaliar bobinas.
				// C6_SEMANA está vazio e tem uma DRC ou era de uma DRC e agora não é mais
				If (Empty(GDFieldGet("C6_SEMANA",_nx)) .And. !Empty(_cNumDRC)) .Or. ;
					( Left(GDFieldGet("C6_SEMANA",_nx),3)=="DRC" .And. Empty(_cNumDRC))

					GDFieldPut("C6_SEMANA" ,_cNumDRC,_nx)
				EndIf
			EndIf
		Next
		If !Empty(_cItResC6)
			u_autoAlert("A(s) Reserva(s) do(s) Item(ns) abaixo Foram DESCONSIDERADAS." + Chr(13) + Chr(13) + _cItResC6,.F., 'Msg' )
		EndIf
	EndIf
EndIf
If M->C5_TIPO == "N"
	_CGCCli := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_CGC")
	//	If !"02544042" # Left(_CGCCli,8)
	// Alterar o C6_CLASFIS sendo que:
	//			 para os pedidos que são faturados por 3 lagoas sair dom 4% de ICMS
	//           e de Itu com 12%
	For nI := 1 to Len(aCols)
		If !GDDeleted(nI)
			_cNacImp  := u_CliPed12(M->C5_CLIENTE,M->C5_LOJACLI,M->C5_NUM,GDFieldGet("C6_PRODUTO",nI),;
			M->C5_EMISSAO,M->C5_TIPOCLI,GDFieldGet("C6_ITEM",nI),;
			GDFieldGet("C6_ACONDIC",nI),GDFieldGet("C6_METRAGE",nI))

			_cClasFis := Left(_cNacImp,1) + Posicione("SF4",1,xFilial("SF4")+GDFieldGet("C6_TES",nI),"F4_SITTRIB")
			GDFieldPut("C6_CLASFIS",_cClasFis,nI)
			GDFieldPut("C6_X_NACIM",Right(_cNacImp,1),nI)
		EndIf
	Next
	//	EndIf
EndIf
If M->C5_TIPO == "N" .And. (Inclui .Or. Altera) .And. _lVolta
	DbSelectArea("SC6")
	DbSetOrder(1)
	For nI:= 1 to Len(aCols)
		If !GDDeleted(nI)
			If !Empty(AllTrim(GDFieldGet("C6_X_FLDES",nI)+GDFieldGet("C6_X_PVDES",nI)+GDFieldGet("C6_X_ITDES",nI)))
				If SC6->(DbSeek(GDFieldGet("C6_X_FLDES",nI)+GDFieldGet("C6_X_PVDES",nI)+GDFieldGet("C6_X_ITDES",nI),.F.))
					RecLock("SC6",.F.)
					SC6->C6_SEMANA  := ("T"+M->C5_NUM)
					MsUnLock()
				EndIf
			EndIf
		EndIf
	Next
EndIf

//Leonardo Bolognesi ( 12/11/2014 )
//Apos realizar todas as validações necessarias verificar criação etiqueta para os itens do pedido
//OBS: Sempre deixar esta rotina como ultimo processamento deste fonte
//para somente verificar ZAA quando todos as validações estiverem corretas (_lVolta := (.T.))
//Somente fazer quando for inclusão do pedido

If _lVolta .And. (Inclui .Or. Altera)
	oIndl:enviaEmail()
	For nI:= 1 To Len(aCols)
		If !GDDeleted(nI) .And. GDFieldGet("C6_METRAGE",nI) > 0 .And.;
			!GDFieldGet("C6_ACONDIC",nI) $ " B" .And. !Empty(GDFieldGet("C6_PRODUTO",nI))

			// Não executar a função em caso de:
			// Linha do aCols esteja deletada;
			// Metragem seja Menor ou igual a zero;
			// Acondicionamento não pode ser bobina ou estar em branco
			// Código de produto não pode estra em branco.

			/*/
			Colocar esta funcionalidade somente após falar com Leonardo / Jeferson
			Apagar os 3 primeiros comandos abaixo

			// By Roberto Oliveira 29/09/2015 - Inicio
			// Pode haver no pedido alterado códigos que tenham sido utilizados somente para faturamento
			// (importado ou "JABÚ"). Em virtude disso, somente os 10 primeiros números do ´codigo devem
			// ser considerados.
			//
			// Programação original
			//_cChave := AllTrim(GDFieldGet("C6_PRODUTO",nI))+AllTrim(GDFieldGet("C6_ACONDIC",nI))+;
			//		   StrZero(GDFieldGet("C6_METRAGE",nI),5)
			//_cAcond	:= AllTrim(GDFieldGet("C6_ACONDIC",nI))+StrZero(GDFieldGet("C6_METRAGE",nI),5)
			//_cCod	:= AllTrim(GDFieldGet("C6_PRODUTO",nI))

			// Programação alterada conforme explicação acima -> Incluído Left(,10) no C6_PRODUTO
			_cChave := AllTrim(Left(GDFieldGet("C6_PRODUTO",nI),10))+AllTrim(GDFieldGet("C6_ACONDIC",nI))+;
			StrZero(GDFieldGet("C6_METRAGE",nI),5)
			_cAcond	:= AllTrim(GDFieldGet("C6_ACONDIC",nI))+StrZero(GDFieldGet("C6_METRAGE",nI),5)
			_cCod	:= AllTrim(Left(GDFieldGet("C6_PRODUTO",nI),10))
			// By Roberto Oliveira 29/09/2015 - Fim

			/*/

			_cChave := Left(AllTrim(GDFieldGet("C6_PRODUTO",nI)),10) +AllTrim(GDFieldGet("C6_ACONDIC",nI))+;
			StrZero(GDFieldGet("C6_METRAGE",nI),5)
			_cAcond	:= AllTrim(GDFieldGet("C6_ACONDIC",nI))+StrZero(GDFieldGet("C6_METRAGE",nI),5)
			_cCod	:= Left(AllTrim(GDFieldGet("C6_PRODUTO",nI)),10)
		EndIf
	Next
EndIf
//FIM LEONARDO

// By Roberto Oliveira 20/03/2017 -
// Correção da tabela SZ9 referente aos lances a serem cortados.
If !Inclui .And. _lVolta
	For nI:= 1 To Len(aCols)
		u_VejaSZ9(If(GDDeleted(nI).Or.!Altera,"E","A"),M->C5_NUM, GDFieldGet("C6_SEMANA",nI), ;
		          GDFieldGet("C6_ITEM",nI), GDFieldGet("C6_ACONDIC",nI)+StrZero(GDFieldGet("C6_METRAGE",nI),5), ;
		          GDFieldGet("C6_LANCES",nI), GDFieldGet("C6_PRODUTO",nI), GDFieldGet("C6_LOCAL",nI), GDFieldGet("C6_ENTREG",nI))
	Next
EndIf

RestArea(aSC6)
RestArea(aArea)
Return(_lVolta)
*
************************
User Function MT410INC()  //Na inclusão chamou depois da MTA410T depois dos dados gravados
************************
*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Está em todas as rotinas de alteração, inclusão, exclusão e devolução de compras. ³
//³Executado após todas as alterações no arquivo de pedidos terem sido feitas.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*
Local aArea		:= getArea()
Local aSC6		:= SC6->(GetArea())
Local lEstoque	:= .F.
Local lDupl		:= .F.
Local lLocal	:= .F.
Local cEmailTxt	:= ""
Local pedMirr 	:= Nil //[LEO]-07/11/2016 Espelho do Pedido

If Type("_lIncAuto") == "U"
	Public _lIncAuto := .F.
EndIf

// Verifica se tem itens marcados para transferência e atualiza o C6_SEMANA do destino
SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
SC6->(DbSeek(xFilial("SC6")+ SC5->C5_NUM,.F.))
Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())
	If !Empty(SC6->C6_X_FLDES)
		_cItemC6 >= SC6->C6_ITEM
		If SC6->(DbSeek(SC6->C6_X_FLDES+SC6->C6_X_PVDES+SC6->C6_X_ITDES,.F.))
			If Empty(SC6->C6_SEMANA)
				RecLock("SC6",.F.)
				SC6->C6_SEMANA := "T" + SC5->C5_NUM
				MsUnLock()
			EndIf
		EndIf
		SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM + _cItemC6,.F.))
	EndIf
	SC6->(DbSkip())
EndDo

If !INCLUI
	Return(.T.)
EndIf
If Type("_aCols2") == "U"
	_aCols2 := {}
EndIf

/*/
04/09/14 -> Estou criando a variável lQuebraPV com .F. para qua sequêcia abaixo não mais seja executada,
uma vez que conforme e-mail da Denise de 01/09/14 os pedidos não mais serão quebrados entre 3 Lagoas / Itu e vice-versa.

Vide observação na User Function MTA410() "Email de Denise de 19/08/13 10:57h"

Caso esta funcionalidade volte a ser executada, corrigir a User Function MTA410() e retirar a variável
lQuebraPV e If lQuebraPV

/*/

lQuebraPV := .F. //Bolognesi
If lQuebraPV
	If Type("_lTdPed") == "U"
		_lTdPed := .T. // Esta variável é definida na função MTA410() como pública
	EndIf
	If Type("_cMyNmEmp") == "U"
		_cMyNmEmp := cNumEmp
	EndIf

	//If cFilAnt == "01"
	If !_lTdPed .And. Len(_aCols2) > 0// Tem SP e MS

		_cMyNmEmp := cNumEmp

		If cFilAnt == "01" // Se estou em Itu
			cNumEmp := Left("0102"+Space(Len(cNumEmp)),Len(cNumEmp))  // crio o pedido na filial
			cFilAnt := "02"
		ElseIf cFilAnt == "02" // Se estou em 3L
			cNumEmp := Left("0101"+Space(Len(cNumEmp)),Len(cNumEmp))  // crio o pedido na filial
			cFilAnt := "01"
		EndIf
		SM0->(DbSeek(Left(cNumEmp,4),.F.))

		//Pego numero do pedido de venda da filial
		// E gravo no acols caso exista este campo
		cPV02 := Space(6)
		Do While .T.
			cPV02 := GetSx8Num("SC5","C5_NUM")
			ConfirmSX8()
			If !SC5->(DbSeek(xFilial("SC5")+cPV02,.F.))
				Exit
			EndIf
		EndDo
		M->C5_NUM := cPV02

		If cFilAnt == "01" // Se estou em Itu
			u_autoAlert("Pedido Itu = " +cPV02,.F.,'Info',"Ponto Entrada MT410TOK")
		ElseIf cFilAnt == "02" // Se estou em Itu
			u_autoAlert("Pedido 3 Lagoas = " +cPV02,.F.,'Info',"Ponto Entrada MT410TOK")
		EndIf

		// Comando GDFieldGet só pega do ACOLS
		// Portanto jogar o que precisa em acols
		aCols := aClone(_aCols2)
		aItens:={}
		_cItem := StrZero(0,Len(SC6->C6_ITEM))
		For  _nMyxx := 1 To Len(_aCols2)
			IncProc()
			_cItem := Soma1(_cItem)
			aAdd(aItens,{})

			For _nCab := 1 to Len(aHeader)
				_cContd := GDFieldGet(aHeader[_nCab,2],_nMyxx)
				If Empty(_cContd)
					Loop
				EndIf
				aAdd(aItens[_nMyxx],Array(3))
				_nPosIt := Len(aItens[_nMyxx])
				aItens[_nMyxx,_nPosIt,1] := aHeader[_nCab,2] // Nome do campo
				If AllTrim(aHeader[_nCab,2]) == "C6_NUM"
					aItens[_nMyxx,_nPosIt,2] := cPV02
				ElseIf AllTrim(aHeader[_nCab,2]) == "C6_ITEM"
					aItens[_nMyxx,_nPosIt,2] := _cItem
				ElseIf AllTrim(aHeader[_nCab,2]) == "C6_LOCAL" .And. ;
					cFilAnt == "02" .And. .f. // (sera atendido por itu)
					aItens[_nMyxx,_nPosIt,2] := "02"
				Else
					aItens[_nMyxx,_nPosIt,2] := GDFieldGet(aItens[_nMyxx,_nPosIt,1],_nMyxx)
				EndIf
				aItens[_nMyxx,_nPosIt,3] := Nil
			Next
		Next

		DbSelectArea("SX3")
		DbSetOrder(1)
		SX3->(DbSeek("SC5", .F.))

		aCabPV:={}

		Do While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SC5"

			_cCampo := "M->"+Alltrim(SX3->X3_CAMPO)

			If Type(_cCampo) <> "U"
				aAdd(aCabPV,array(3))
				aCabPV[Len(aCabPV),1] := Alltrim(SX3->X3_CAMPO)
				aCabPV[Len(aCabPV),2] := Iif("C5_NUM"==Right(Alltrim(SX3->X3_CAMPO),6), cPV02, &_cCampo )
				aCabPV[Len(aCabPV),3] := nil
			EndIf

			SX3->(dbSkip())
		EndDo

		_lIncAuto := .T.
		lMsErroAuto:=.f.
		MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItens,3)
		_lIncAuto := .F.
		If lMsErroAuto
			MostraErro()
		EndIf
	EndIf
	//EndIf

	If cNumEmp <> _cMyNmEmp .And. _cMyNmEmp <> nil
		// Voltar para a filial original
		cNumEmp := _cMyNmEmp  // 0102 -> 0101
		cFilAnt := Substr(cNumEmp,3,2)
		SM0->(DbSeek(Left(cNumEmp,4),.F.))
	EndIf

	_aCols2   := nil
	_lTdPed   := nil
	_cMyNmEmp := nil

EndIf

RestArea(aSC6)
RestArea(aArea)
Return(.T.)
*
************************
User Function M410STTS() //Chama sempre que termina gravação SC5/SC6 ( A410INCLUI/A410ALTERA/A410DELETA/A410COPIA )
************************
*
Local aArea		:= getArea()
Local aSC6		:= SC6->(GetArea())
Local aSC5		:= SC5->(GetArea())
Local aSA1		:= SA1->(GetArea())

Local lEstoque	:= .F.
Local lDupl		:= .F.
Local lLocal	:= .F.
Local lTautom	:= .F.
Local cEmailTxt	:= ""
Local _cCgc		:= ""
Local pedMirr	:= Nil

local lCreate := (Type("INCLUI") != "U" .and. INCLUI)
local lUpdate := (Type("ALTERA") != "U" .and. ALTERA)
local lDelete := (!lCreate .and. !lUpdate)
local bErro	:= Nil


	/*
		[PORTAL][CHAMADA] - Manutenção do relacionamento entre os documentos do portal e os documentos do sistema
		manter a partir de um documento no portal sua rastreabilidade interna no sistema(Chamada com tratamento de
		erro)
	*/
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr)})
	BEGIN SEQUENCE
		if ExistBlock("_CbcService") .and. lDelete
			checkQuotationDocument()
		endIf
    RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
	/*
		[PORTAL][FIM]
	*/

/*
[LEO]-[ESPELHO_PEDIDO]-11/11/2016 -
1-)Este ponto de entrada (M410STTS), ocorre depois de gravar as alterações na tabela.
2-)Melhor momento para enviar o e-mail. considerando que o metodo de envio utiliza os dados
da tabela para formar o e-mail.
3-)Objetivo Enviar o e-mail para o cliente do Espelho do Pedido somente
quando de fato foi alterado (algum do campos considerados importantes foram Alterados).
4-) A logica aplicada é utilizar o flag definido pelo P.E. M410AGRV onde se o campo M->(C5_ZZSMAIL) == 'C'
significa que foi alterado e precisa enviar o email.
5-) Realiza o envio do email flegando o campo SC5->(C5_ZZSMAIL) com 'S' quando enviou email ok e 'E' quando houve erros
no envio, este flag 'E' somente é definido pela rotina de envio e deve ser fator de filtro para o schedule enviar e-mails
que não foram enviados no momento correto. .
*/
	If  Altera .And. SC5->(C5_ZZSMAIL) == 'C'
		pedMirr := cbcPedido():newcbcPedido(SC5->(C5_NUM))
		pedMirr:sendMirror(Altera,.F.)
		FreeObj(pedMirr)
	EndIF
/*[LEO]-[ESPELHO_PEDIDO]-11/11/2016 - FIM*/


/*
1-) Esta fonte originalmente estava no arquivo PE_NFE.prw, criado pela Juliana, Transferi 20/10/2015 para
fonte M410LIOK.prw, da utilização antiga a unica coisa que tinha era a chamada para esta função: (U_WFPedVenda())
2-) Função PROCNAME(2) Retorna a origem da chamada A410INCLUI/A410ALTERA/A410DELETA/A410COPIA

3-) LEONARDO - 19/10/2015 - GERAR INDUSTRIALIZAÇÃO PARA PEDIDO COM TES REMESSA ENTREGA FUTURA
ONDE O TES NÃO GERA FINANCEIRO LOGO NÃO PASSA POR CREDITO E TAMBEM NÃO CHAMA FUNÇÃO QUE GERA INDUSTRIALIZAÇÃO.
NESTE CASO REALIZAR A CHAMADA MANUALMENTE (REGRA LEONARDO/JULIANA DEFINIRAM:
( TES NÃO GERA FINANCEIRO E MOVIMENTO ESTOQUE )
*/
_cCgc := SubStr(Posicione("SA1",1,xFilial("SA1")+ SC5->(C5_CLIENTE + C5_LOJACLI),"A1_CGC"),1,8)

If !U_turnOff() .And. !_SetAutoMode() .And. FWCodFil() == "02" .And.  _cCgc # "02544042"

	If  ProcName(2) # "A410DELETA"  .And. SC5->(C5_TIPO) $ "N"

		SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		SC6->(DbSeek(xFilial("SC6")+ SC5->C5_NUM,.F.))
		Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())

			/*	LEONARDO - 19/10/2015 - GERAR INDUSTRIALIZAÇÃO PARA PEDIDO COM TES REMESSA ENTREGA FUTURA
			ONDE O TES NÃO GERA FINANCEIRO LOGO NÃO PASSA POR CREDITO E TAMBEM NÃO CHAMA FUNÇÃO QUE GERA INDUSTRIALIZAÇÃO.
			NESTE CASO REALIZAR A CHAMADA MANUALMENTE (REGRA LEONARDO/JULIANA DEFINIRAM:
			( TES NÃO GERA FINANCEIRO E MOVIMENTO ESTOQUE )
			*/
			lEstoque  	:= Posicione("SF4",1,xFilial("SF4")+SC6->(C6_TES),"F4_ESTOQUE") $ "S"
			lDupl 		:= Posicione("SF4",1,xFilial("SF4")+SC6->(C6_TES),"F4_DUPLIC")  $ "N"
			
			If Alltrim(SC6->(C6_SEMANA)) == 'TAUTOM'
				lTautom		:= .T.
			EndIf 

			If Alltrim(SC6->(C6_LOCAL)) $ '10'
				lLocal	:= .T.
			EndIf
			SC6->(DbSkip())
		EndDo

		If 	( lEstoque .And. lDupl ) .And. ( lLocal .Or. lTautom )

			U_pedIndl(Alltrim(SC5->(C5_NUM))) //Cria a industrialização
			//Texto e-mail
			cEmailTxt += "PEDIDO: " + Alltrim(SC5->(C5_NUM) ) + " Gerou industrialização sem passar pelo crédito "
			//Aviso sobre a operação
			u_envmail({"wfti@cobrecom.com.br"}, "[Aviso] - Gerar Industrialização - Pedidos TES não gera financeiro (3L x INDL-ITU)", {"Rotina","Linha","Função","Fonte","Obs"},{{"Mata410",cValToChar(ProcLine(0)),"MT410INC()","M410LIOK.PRW",cEmailTxt}} )

		EndIf
	EndIf

EndIf

RestArea(aSA1)
RestArea(aSC6)
RestArea(aSC5)
RestArea(aArea)
Return
*
************************
User Function MT410ACE()    // Em alterar chamou logo ao clicar o botão alterar
************************
*

Local aArea		:= getArea()
Local aSC6		:= SC6->(GetArea())
Local _cMot1    := ""
Local _cMot2    := ""
Local _lMyPedCan	:= .F.

if FwIsInCallStack('MATA410') .and. !Empty(SC5->(C5_X_IDVEN)) .and. !FwIsInCallStack('U_ZCBVIEWPED')
	u_autoAlert("Este pedido possui divisão multifilial",,'MsgBox')
	return(.F.)
endif

_Volta := .T.
_nMyOPC := ParamIXB[1]
/*/
1 - Excluir // 2 - Resíduo // 3 - Copiar // 4 - Alterar /
/*/
_nRot    := 1
_cRotina := " "
Do While _nRot < 11
	_cRotina := Upper(ProcName(_nRot++))
	If "410" $ _cRotina
		Exit
	EndIf
EndDo

//Criado para exclusão dos pedidos chamados pela função CSFAT01 - Juliana Leme
If Type("lMyPedCan") == "L"
	_lMyPedCan := lMyPedCan
Else
	_lMyPedCan := .F.
EndIf

//Criado para exclusão dos pedidos chamados pela função CSFAT01 - Juliana Leme
If Type("_myPed") == "C"
	If !Empty(_myPed)
		SC5->(dbSetOrder(1))
		SC5->(DbSeek(xFilial("SC5")+_myPed,.F.))
	EndIf
EndIf

If ("A410DELETA" $ _cRotina .Or. "MA410RESID" $ _cRotina) .and. !_lMyPedCan
	//If !ALTERA .And. (_nMyOPC == 1 .Or. _nMyOPC == 2) // Só entrar se for 1 - Excluir ou 2 - Resíduo
	// Verificar se os campos SC6->C6_RES_SZZ ou SC6->C6_ITE_SZZ estão preenchidos ... não pode
	SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM,.F.))
	_cMot1 := ""
	_cMot2 := ""
	Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())
		If Left(SC6->C6_SEMANA,1) == "r" // Tem que ser "r" mesmo -> Verificar se o retrabalho já está ou não concluído.
			_Volta := .F. // Em princípio não permite - se não achar nada no ZZE retirna falso
			_cMot1 := "Retrabalho em Aberto"
			_cMot2 := "Solicite Cancelamento do Retrabalho"
			DbSelectArea("ZZE")
			DBOrderNickName("ZZEPEDITPR") //4-ZZE_FILIAL+ZZE_PEDIDO+ZZE_ITEMPV+ZZE_PRODUT
			DbSeek(xFilial("ZZE")+SC6->C6_NUM+SC6->C6_ITEM+SC6->C6_PRODUTO,.F.)
			Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE_PEDIDO == SC6->C6_NUM .And. ;
			         ZZE_ITEMPV == SC6->C6_ITEM .And. ZZE_PRODUT == SC6->C6_PRODUTO .And. ZZE->(!Eof())
				If ZZE->ZZE_DEVTOT == ZZE->ZZE_TOTSA .Or. ZZE->ZZE_STATUS == '9' // Já retornou tudo
					_Volta := .T.
				Else
					_Volta := .F. // Tem algum em aberto não importa os outros
					_cMot1 := "Retrabalho em Aberto"
					_cMot2 := "Solicite Cancelamento do Retrabalho"
					Exit
				EndIf
				ZZE->(DbSkip())
			EndDo
			If !_Volta
				// Não achou nada no ZZE ou achou um cara ainda não terminado
				Exit
			EndIf
		ElseIf !Empty(SC6->C6_RES_SZZ+SC6->C6_ITE_SZZ) .Or. Alltrim(SC6->C6_SEMANA) $ "RESERVA"
			_cMot1 := "Reserva"
			_cMot2 := "Solicite Cancelamento da Reserva"
			If _nMyOPC == 1      // Estou excluindo
				_Volta := .F.
				Exit
			ElseIf _nMyOPC == 2  // Estou matando resíduo
				If SC6->C6_QTDVEN > SC6->C6_QTDENT
					// É reserva e não foi faturado tudo
					_Volta := .F.
					Exit
				Endif
			Endif
		Endif
		SC6->(DbSkip())
	EndDo
	If !_Volta
		u_autoAlert("Este Pedido Possue " + _cMot1 + " -> Primeiro " + _cMot2,,'MsgBox')
	EndIf
EndIf

RestArea(aSC6)
RestArea(aArea)
Return(_Volta)
*
************************
User Function M410AGRV() // PE após a confirmação da inclusão, alteração ou exclusão e
************************ // antes da gravação do pedido de venda.
*
/*/
_nEvento - Código do Evento

Os eventos são:
1-Inclusão  de Pedidos
2-Alteração de Pedidos
3-Exclusão  de Pedidos
4-Liberação Pedido (Vendas)
5-Liberação Pedido (Crédito)
6-Autorização PCP p/ Alteração
7-Eliminação de Resíduos
8-Autoriz.Vendas p/ Alteração
/*/

Local aArea		:= getArea()
Local aSC6		:= SC6->(GetArea())
Local pedMirr	:= Nil //LEO 11/11/16

/*
[LEO]-[ESPELHO_PEDIDO]-11/11/2016 -
1-)Este ponto de entrada (M410AGRV), ocorre antes de gravar as alterações
realizadas na tabela e depois dos obrigatorios e validações.
2-)Melhor momento para verificar se existe alterações pois temos os dados
em memoria e podemos comparar com os dados na tabela afinal ainda não
foram gravados.
3-)Objetivo Enviar o e-mail para o cliente do Espelho do Pedido somente
quando de fato foi alterado (algum do campos considerados importantes foram Alterados).
4-) A logica aplicada é utilizar este ponto para verificar alterações somente em pedidos
onde o primeiro e-mail(enviado na liberação de vendas) já tenha sido enviado M->(C5_ZZSMAIL) == 'S',
justamente para enviar notificações de alterações somente para pedidos cujas notificações de inclusão
já tenha sido enviadas, neste ponto o objetivo é somente flegar o campo M->C5_ZZSMAIL com o conteudo 'C'
caso existam alterações.
5-) Esta logica trabalha em conjunto com P.E. M410STTS que ocorre apos a gravação dos dados na tabela, enviando
email somente do pedido flegados com M->(C5_ZZSMAIL) := 'C'.
6-) O Email não pode ser enviado neste ponto de entrada pois a rotina de envio atualiza a tabela com o status
do envio SC5->(C5_ZZSMAIL) := 'S', se atualizar a tabela agora, a gravação que ocorrerá na sequencia sobrescreverá este status
bem como os dados enviados no email são baseados na tabela que neste momento ainda não foi atualizada.
*/
	If  Altera .And. M->(C5_ZZSMAIL) == 'S'
		pedMirr := cbcPedido():newcbcPedido(M->(C5_NUM))
		If pedMirr:hasChanged()
			M->(C5_ZZSMAIL) := 'C'
		EndIf
		FreeObj(pedMirr)
	EndIF
/*[LEO]-[ESPELHO_PEDIDO]-11/11/2016 - FIM */

If Inclui
	_nMyEvent := 1
ElseIf Altera
	_nMyEvent := 2
Else
	// Varrer o SC6 e excluir a lista de repasse para não mais imprimir etiquetas.
	aAreaNow    := GetArea()
	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek(xFilial("SC6")+M->C5_NUM,.F.)
	Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())
		u_VejaSZ9("E", SC6->C6_NUM, SC6->C6_SEMANA, SC6->C6_ITEM, SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5), ;
				  SC6->C6_LANCES, SC6->C6_PRODUTO, SC6->C6_LOCAL, SC6->C6_ENTREG)
		SC6->(DbSkip())
	EndDo
	RestArea(aAreaNow)
	_nMyEvent := 3
EndIf
_aDadC5 := {M->C5_NUM,M->C5_CLIENTE,M->C5_LOJACLI,M->C5_ENTREG,M->C5_TIPO}
u_CDGEN21I(_nMyEvent,,,,_aDadC5)

RestArea(aSC6)
RestArea(aArea)
Return(.T.)
*
***********************
User Function M410GET()
***********************
*
If M->C5_EMISSAO > Ctod("12/04/2015") .And. M->C5_CONDPAG == "000"
	For _i := 1 To Len(aCols)
		GDFieldPut("C6_PRCVEN",GDFieldGet("C6_PRCBAS",_i),_i)
		GDFieldPut("C6_VALOR",A410Arred((GDFieldGet("C6_QTDVEN",_i)*GDFieldGet("C6_PRCVEN",_i)),"C6_VALOR"),_i)
	Next
EndIf
Return(.T.)


**********************
User Function MT500ANT()
**********************
//Eliminar residuo de forma parametrizada (Pedido de: até:)
//So permite eliminar residuos de itens que não estão em processo de industrialização
//ou outros itens elimina residuo
Local aArea		:= GetArea()
Local lRet		:= .T.
Local cMsg		:=""

if !Empty(SC5->(C5_X_IDVEN))
	u_autoAlert("Este pedido possui divisão multifilial",,'MsgBox')
	return(.F.)
endif

If !U_turnOff()

	If 	!Empty(SC6->C6_ZZPVORI)
			//lRet := .F.
			cMsg +=	" O Item " + Alltrim(SC6->(C6_ITEM)) + " do Pedido:" + Alltrim(SC5->(C5_NUM)) + chr(13)
			cMSg += "possui solicitação de industrialização referente ao: " + chr(13)
			cMsg +=	" O Item " + Substr(SC6->C6_ZZPVORI,7,2) + " do Pedido: " + Substr(SC6->C6_ZZPVORI,1,6)
			cMSg += IIF(FWCodFil() == '02', " em Itu", " em Três Lagoas") + chr(13) + chr(13)
			u_autoAlert("<b>[Aviso]</b>" + cMSg,.F.,'Info')
	EndIf

EndIf

RestArea(aArea)
Return(lRet)

**********************
User Function M410VRES
**********************
//Executado pelo MATA410 quando confirma "eliminar residuo" no pedido de forma individual
//Se o pedido tiver um item no processo de industrialização por esta rotina não será possivel eliminar redisuo do pedido
//para isso utilizar a rotina Automatica Eliminar Residuo (Chama PEMT500ANT()) nesta e possivel eliminar residuo por item
Local aSC6		:= SC6->(GetArea())
Local aSC5		:= SC5->(GetArea())
Local aArea		:= GetArea()
Local cMsg		:= ""
Local cLog		:=""
Local aPBox	:={}
Local aRet		:={}
Local _Volta 	:= .T.

if !Empty(SC5->(C5_X_IDVEN))
	u_autoAlert("Este pedido possui divisão multifilial",,'MsgBox')
	return(.F.)
endif

If !U_turnOff()
	DbSelectArea("SC6")
	DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	If( SC6->(DbSeek(xFilial("SC5")+SC5->(C5_NUM) ,.T.)) )
		While SC6->(!Eof()) .AND. SC6->C6_FILIAL == xFilial("SC5") .AND. SC6->(C6_NUM) == SC5->(C5_NUM)

			If  !_SetAutoMode() .And. !Empty(SC6->C6_ZZPVORI)    //.And. SC6->C6_CLI == "008918"

				cMsg +=	"* O Item " + Alltrim(SC6->(C6_ITEM)) + " do Pedido:" + Alltrim(SC5->(C5_NUM)) + chr(13)
				cMSg += "possui solicitação de industrialização referente ao: " + chr(13)
				cMsg +=	"* O Item " + Substr(SC6->C6_ZZPVORI,7,2) + " do Pedido: " + Substr(SC6->C6_ZZPVORI,1,6)
				cMSg += IIF(FWCodFil() == '02', " em Itu", " em Três Lagoas") + chr(13) + chr(13)
				_Volta := .F.
			EndIf

			SC6->(DbSkip())
		EndDo

		If  !_Volta
			cMsg += " O Pedido não pode ser alterado"
			cMSg += " Comunicar obrigatoriamente os responsáveis e se necessário alterar "

			 if ! U_isAuto()
				aAdd(aPBox,{11,"Pedidos INDL-ITU/3LAGOAS",cMsg,".T.",".T.",.T.})
				ParamBox(aPBox,"Atenção...",@aRet)
			Else
				u_autoAlert(cMsg,,'Info')
			EndIf
			u_autoAlert("<b>[Aviso]</b>" + "Caso existam itens neste pedido que não estão relacionados com processo de Industrialização" + chr(13) + ;
			"utilize a rotina propria para eliminiar residuo",,'Info')

		EndIF

	Else
		_Volta := .F.

	EndIf

EndIf

RestArea(aSC5)
RestArea(aSC6)
RestArea(aArea)
Return(_Volta)
*
***********************
User Function VldProd()  // Validar a reserva
***********************
* TIRAR SE AUTO OK MESMO 3/
Local _lRot := .F. // É rotina de transferência?
Local _nRot := 1

Do While .T.
	_cRotina := ProcName(_nRot++)
	If "CSFAT11" $ _cRotina // Acabou ou é a Rotina de Produção
		_lRot := .T.
		Exit
	ElseIf Empty(_cRotina)
		Exit
	EndIf
EndDo

If _lRot // Se for rotina de transferência retorna .T.
	Return(.T.)
EndIf
SB1->(DbSetOrder(1)) //23/08

If Altera .And. GDFieldGet("C6_PRODUTO",n) # M->C6_PRODUTO  .And. !Empty(GDFieldGet("C6_SEMANA",n)) .And. ;
	(GDFieldGet("C6_ACONDIC",n)+StrZero(GDFieldGet("C6_METRAGE",n),5)) # "R00100"
	// Alteração by Roberto Oliveira - Contempla a integridade dos dados que estão na fábrica para não permitir
	// fazer alteração se já estiver sendo produzido.
	If !u_VejaSZ9("V",M->C5_NUM, GDFieldGet("C6_SEMANA",n), GDFieldGet("C6_ITEM",n), GDFieldGet("C6_ACONDIC",n)+StrZero(GDFieldGet("C6_METRAGE",n),5), GDFieldGet("C6_LANCES",n))
		// u_VejaSZ9("V",PEDIDO, ITEM, ACONDIC (R00100), QTD.LANCES)
		Return(.F.)
	EndIf
EndIf

_cProduto := u_PrdNacion(M->C6_PRODUTO)

If SB1->(DbSeek(xFilial("SB1")+_cProduto,.F.))
	If SB1->B1_TIPO == "PA" .And. ;
		((FWCodEmp()+FWCodFil() == "0102" .And. SB1->B1_CUSTD3L <= 0.00) .Or.;
		(FWCodEmp()+FWCodFil() == "0101" .And. SB1->B1_CUSTD   <= 0.00))
		u_autoAlert("Atenção - Custo do Produto Zerado - Corrigir!!!")
		Return(.F.)
	ElseIf (!U_isPortal() .and. !U_isAuto()) .and. (SB1->B1_BLQVEN == "S" .And. !"ADMINISTRADOR" $ Upper(cUserName))
		u_autoAlert("Produto Bloqueado Para Venda!!!!")
		Return(.F.)
	//ElseIf !Empty(M->C5_CLIENTE) .And. !Empty(M->C5_LOJACLI) .And. M->C5_TIPO == "N" .And. SB1->B1_TIPO == "PA"
	ElseIf !Empty(M->C5_CLIENTE) .And. !Empty(M->C5_LOJACLI) .And. M->C5_TIPO == "N" .And. SB1->B1_LOCALIZ == "S"
		// Verificar se o cliente é a Huawei e se o produto está no SA7.. amarração Prod.Cliente
		SA1->(DbSetOrder(1))
		If SA1->(DbSeek(xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI,.F.))
			If "HUAWEI" $ Upper(SA1->A1_NOME)
				SA7->(DbSetOrder(1)) //A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_PRODUTO
				// Procurar no SA7 sempre os produtos cadastrados para o cliente 014642-04"

				// _cPrdHwy := Left(Left(M->C6_PRODUTO,10) + Space(Len(SB1->B1_COD)),Len(SB1->B1_COD))
				_cPrdHwy := u_PrdNacion(M->C6_PRODUTO)

				If !SA7->(DbSeek(xFilial("SA7")+SA1->A1_COD+SA1->A1_LOJA+_cPrdHwy,.F.))
					u_autoAlert("Produtos Destinados a Huawei Devem ser Cadastrados na Tabela Produto X Cliente")
					Return(.F.)
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
Return(.T.)
*
********************************
User Function ConfDesc(_lVldDem)
********************************
*TIRAR SE AUTO // OK 1/2/
//If !"ADMINISTRADOR" $ Upper(cUserName)
//	Return(.T.)
//EndIf
DEFAULT _lVldDem := .T. // Rotina chamada em validação e não em processamento


If _lVldDem
	_cVendVez := 1
	Do While .T.
		_cCodVen:= "C5_VEND" + AllTrim(Str(_cVendVez++))
		If SC5->(FieldPos(_cCodVen)) # 0
			If !Empty(&("M->"+_cCodVen))
				If !Empty(Posicione("SA3",1,xFilial("SA3")+&("M->"+_cCodVen),"A3_DEMISS"))
					u_autoAlert("Não é Permitido a Inclusão de Representante Já Desligado")
					Return(.F.)
				EndIf
			EndIf
		Else
			Exit
		EndIf
	EndDo
EndIf
/*
If !u_turnOff()
M->C5_DESCESP := 0
M->C5_DESCEQT := 0
Return (.T.)
EndIF
*/
SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,.F.))

If !Inclui //23/08 CHAMOU (1/2/3) AO COLOCAR CODIGO DO CLIENTE / LOJA/VENDEDOR
	M->C5_DESCESP := SC5->C5_DESCESP
	M->C5_DESCEQT := SC5->C5_DESCEQT
	Return(.T.)
EndIf

If M->C5_TIPO # "N" .Or. Empty(M->C5_CLIENTE) .Or. Empty(M->C5_LOJACLI)
	M->C5_DESCESP := 0
	M->C5_DESCEQT := 0
	Return(.T.)
EndIf

SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,.F.))

// Se cond. pagto for BNDES
// ou
// nenhum dos itens do pedido movimentar estoque
// ou
// tipo do pedido não é normal
// Jogar 0 para os descontos
If M->C5_CONDPAG == "000"
	M->C5_DESCESP := 0
	M->C5_DESCEQT := 0
	Return(.T.)
EndIf
// Verificar o aCols

_cMovEst := "N"
For nTES := 1 to Len(aCols)
	If !GDDeleted(nTES)
		_cMovEst := Posicione("SF4",1,xFilial("SF4")+GDFieldGet("C6_TES",nTES),"F4_ESTOQUE")
		If _cMovEst == "S"
			Exit
		EndIf
	EndIf
Next

If _cMovEst == "N"
	M->C5_DESCESP := 0
	M->C5_DESCEQT := 0
	Return(.T.)
EndIf

_nVlDesCl := 0
_cTpDesCl := " "
If SA1->A1_DESCVLR > 0 .And. SA1->A1_DESCVLR < 100
	_cTpDesCl := "V"
	_nVlDesCl := SA1->A1_DESCVLR
ElseIf SA1->A1_DESCQTD > 0 .And. SA1->A1_DESCQTD < 100
	_cTpDesCl := "Q"
	_nVlDesCl := SA1->A1_DESCQTD
ElseIf SA1->A1_DESCVLR == 100 .And. SA1->A1_DESCQTD == 100
	_cTpDesCl := "V"
EndIf

// Se não digitou nada ou já tem uma configuração para esse cliete -> assume o do cadastro do cliente
If 	( (M->C5_DESCESP == 0 .And. M->C5_DESCEQT == 0) .Or. !Empty(_cTpDesCl) ) //'.And. u_turnOff()
	If _cTpDesCl == "V"
		M->C5_DESCESP := If(_nVlDesCl==100,0,_nVlDesCl)
		M->C5_DESCEQT := 0
	Else
		M->C5_DESCEQT := If(_nVlDesCl==100,0,_nVlDesCl)
		M->C5_DESCESP := 0
	EndIf
	Return(.T.)
EndIf


/*/ Devido a alterações nas regras, estamos desabilitando a análise de exceções
//Verifico se tem uma exceção para o cliente
DbSelectArea("SZP")
DbSetOrder(4) // ZP_FILIAL+SZP->ZP_CLIENTE+SZP->ZP_LOJA+SZP->ZP_VEND+SZP->ZP_CIDADE+ZP_UF

If SZP->(DbSeek(xFilial("SZP")+M->C5_CLIENTE+M->C5_LOJACLI,.F.)) // Tenho Exceção para o cliente
	// Se a exceção é maior ou igual que a usada no pedido e é do mesmo tipo
	If SZP->ZP_DESC1 >= _nVlDesCl .And. (_cTpDesCl == SZP->ZP_TIPO .Or. Empty(_cTpDesCl))
		If SZP->ZP_TIPO == "V"
			M->C5_DESCESP := SZP->ZP_DESC1
		Else
			M->C5_DESCEQT := SZP->ZP_DESC1
		EndIf
		Return(.T.)
	EndIf
	Return(.F.)
EndIf

If 	M->C5_DESCESP == 0 .And. M->C5_DESCEQT == 0
	Return(.T.)
EndIf

// Se digitou algo -> verifica se pode usar esse desconto
// Verifico se pode ser usado esse desconto
If M->C5_DESCESP > 0
	_nVlDesCl := M->C5_DESCESP
	_cTpDesCl := "V"
ElseIf M->C5_DESCEQT > 0
	_nVlDesCl := M->C5_DESCEQT
	_cTpDesCl := "Q"
EndIf

// ZP_FILIAL+ZP_CLIENTE+ZP_LOJA+ZP_VEND+ZP_CIDADE+ZP_UF
If !Empty(M->C5_VEND1)
	If SZP->(DbSeek(xFilial("SZP")+Space(Len(SZP->ZP_CLIENTE+SZP->ZP_LOJA))+M->C5_VEND1,.F.))
		If _cTpDesCl == SZP->ZP_TIPO .And. (SZP->ZP_DESC1 == _nVlDesCl .Or. SZP->ZP_DESC2 == _nVlDesCl)
			Return(.T.)
		EndIf
	EndIf
EndIf

// Verifico se pode usar pela Cidade
If SZP->(DbSeek(xFilial("SZP")+Space(Len(SZP->ZP_CLIENTE+SZP->ZP_LOJA+SZP->ZP_VEND))+SA1->A1_COD_MUN,.F.))
	If _cTpDesCl == SZP->ZP_TIPO .And. (SZP->ZP_DESC1 == _nVlDesCl .Or. SZP->ZP_DESC2 == _nVlDesCl)
		Return(.T.)
	EndIf
EndIf

// Verifico se pode usar pelo Estado
If SZP->(DbSeek(xFilial("SZP")+Space(Len(SZP->ZP_CLIENTE+SZP->ZP_LOJA+SZP->ZP_VEND+SZP->ZP_CIDADE))+SA1->A1_EST,.F.))
	If _cTpDesCl == SZP->ZP_TIPO .And. (SZP->ZP_DESC1 == _nVlDesCl .Or. SZP->ZP_DESC2 == _nVlDesCl)
		Return(.T.)
	EndIf
EndIf
/*/

M->C5_DESCESP := SA1->A1_DESCVLR
M->C5_DESCEQT := SA1->A1_DESCQTD
If M->C5_DESCESP == 100
	M->C5_DESCESP := 0
EndIf
If M->C5_DESCEQT == 100
	M->C5_DESCEQT := 0
EndIf

// Gravar o campo C6_COMIS1 se o campo C5_VEND1 estiver preenchido
_lGrava0 := .T. // Presumo que a comissão seja 0
_cCnpj := Left(Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_CGC"),8)
If M->C5_TIPO == "N" .And. _cCnpj # "02544042"
	_lGrava0 := .F.
EndIf

/*/

DbSelectArea("DA1")
DbSetOrder(1) // DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM

// % Com.  Dsc1    Desc2   Desc3	% Desc.Real % Liquido
// 5,0		40		0		4		42,4000		57,6000
// 4,5		40		0		6		43,6000		56,4000
// 4,0		40		0		8		44,8000		55,2000
// 3,5		40		0		10		46,0000		54,0000
// 3,0		40		10		2		47,0800		52,9200
// 2,5		40		10		4		48,1600		51,8400
// 2,0		40		10		6		49,2400		50,7600
// 1,5		40		10		8		50,3200		49,6800
// 1,0		40		10		10		51,4000		48,6000

_aDescs := {}
aAdd(_aDescs,{57.60,5.0})
aAdd(_aDescs,{56.40,4.5})
aAdd(_aDescs,{55.20,4.0})
aAdd(_aDescs,{54.00,3.5})
aAdd(_aDescs,{52.92,3.0})
aAdd(_aDescs,{51.84,2.5})
aAdd(_aDescs,{50.76,2.0})
aAdd(_aDescs,{49.68,1.5})
aAdd(_aDescs,{48.60,1.0})

For _nx := 1 to Len(aCols)
	_cDuplic := Posicione("SF4",1,xFilial("SF4")+GDFieldGet("C6_TES",_nx),"F4_DUPLIC")
	If GDDeleted(_nx) .Or. _lGrava0 .Or. Empty(M->C5_VEND1) .Or. _cDuplic # "S"
		GDFieldPut(C6_COMIS1,0,_nx)
	Else
		// Verificar qual o % da comissão baseado no preço de venda - descontos com o preço do pedido

		_nPrcPV := GDFieldGet("C6_PRCVEN",_nx)
		_nPrcUnit := 0.00
		_nComiss  := 0.8 // Menor comissão
		If DA1->(DbSeek(xFilial("DA1")+M->C5_TABELA+GDFieldGet("C6_PRODUTO",_nx),.F.))
			_nPrcUnit := DA1->DA1_PRCVEN
		EndIf
		If _nPrcUnit > 0
			// Aplicar descontos para saber qual o % da comissão
			For _nx1 := 1 to Len(_aDescs)
				_PcMin := (_nPrcUnit * _aDescs[_nx1,1]) / 100
				If _nPrcPV >= _PcMin
					_nComiss  := _aDescs[_nx1,2]
					Exit
				EndIf
			Next
		EndIf
		GDFieldPut(C6_COMIS1,_nComiss,_nx)
	EndIf
Next
/*/
Return(.T.)
*
*************************
User Function MsgTabela()
*************************
*
u_autoAlert("A tabela de preços no pedido de vendas é " + Chr(13) + ;
"avaliada pelo representante. " + Chr(13) + ;
"Somente deve-se alterar a tabela neste cadastro " + Chr(13) + ;
"quando este cliente usar uma tabela específica, diferente da " + Chr(13) + ;
"tabela cadastrada no representante",.F.)
Return(.T.)
*
*************************
User Function ValTabela()
*************************
*
M->C5_COMIS1 := 0
If Empty(M->C5_TABELA) .Or. M->C5_TIPO # "N"
	// Zera as comissões no SC6
	For _i := 1 To Len(aCols)
		GDFieldPut("C6_COMIS1",0,_i)
	Next
EndIf
If  M->C5_TIPO == "N"
	u_CalcComis("SC5")  // Faz o cálculo das comissões item a item do pedido
EndIf
*
*******************************
User Function CalcComis(_cOnde)
*******************************
* TIRAR SE AUTO OK
// _cOnde pode ser SC5 - Pedido de Venda ou SCJ - Orçamento
Private _cProduto
Private _nPrcVen
Private _cTES
Private _cDuplic
Private _nComis
/*/
Conforme conversei com o Jeferson (14/05/2014 - 11:30h, vamos efetuar o cálculo da comissão somente quando:
- For inclusão de pedido
- Se alteração:
- Foi alterada a Ttbela de preços
- Foi alterada a condição de pagamento
- O % da comissão está em 0 (Zero)
- Alterou o valor unitário
- Alterou o produto
Essas condições são válidas tanto para pedidos de vendas quanto orçamentos.
/*/
If _cOnde == "SC5"
	For _i := 1 To Len(aCols)
		If !GDDeleted(_i)
			_lCalcula := .F.
			If Inclui .Or. GDFieldGet("C6_COMIS1",_i) <= 0 .Or. ;
				M->C5_TABELA  # Posicione("SC5",1,xFilial("SC5")+M->C5_NUM,"C5_TABELA")  .Or. ;
				M->C5_CONDPAG # Posicione("SC5",1,xFilial("SC5")+M->C5_NUM,"C5_CONDPAG")
				_lCalcula := .T.
			Else
				SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
				If SC6->(DbSeek(xFilial("SC6") + M->C5_NUM + GDFieldGet("C6_ITEM",_i),.F.))
					If GDFieldGet("C6_PRODUTO",_i) # SC6->C6_PRODUTO .Or. ;
						GDFieldGet("C6_PRCVEN" ,_i) # SC6->C6_PRCVEN
						_lCalcula := .T.
					EndIf
				Else
					_lCalcula := .T.
				EndIf
			EndIf
			If _lCalcula
				_cProduto := GDFieldGet("C6_PRODUTO",_i)
				_nPrcVen  := GDFieldGet("C6_PRCVEN",_i)
				_cTES     := GDFieldGet("C6_TES",_i)
				_cAcond   := GDFieldGet("C6_ACONDIC",_i) + StrZero(GDFieldGet("C6_METRAGE",_i),5)
				_cDuplic  := If(Empty(_cTES),"  ",Posicione("SF4",1,xFilial("SF4")+_cTES,"F4_DUPLIC"))
				_aDadCli  := {M->C5_CLIENTE,M->C5_LOJACLI,M->C5_VEND1,M->C5_TABELA}
				// No Pedido a comissão somente será calculada se for inclusão ou for um ítem novo
				//If !(SC6->(DbSeek(xFilial("SC6") + M->C5_NUM + GDFieldGet("C6_ITEM",_i),.F.))) //Comentado pois permitir sempre recalcular.
					If !U_isPortal()
						_nComis   := u_VejaComis(_cProduto,_nPrcVen,_cDuplic,_cAcond,_aDadCli,Posicione("SE4",1,xFilial("SE4")+M->C5_CONDPAG,"E4_AVISTA"))
						GDFieldPut("C6_COMIS1",_nComis,_i)
					EndIf
				//EndIf
			EndIf
		EndIf
	Next
ElseIf _cOnde == "SCJ"
	DbSelectArea("TMP1")
	DbGoTop()
	Do While TMP1->(!Eof())
		If !TMP1->CK_FLAG // Não deletado
			_lCalcula := .F.
			If Inclui .Or. TMP1->CK_COMIS1 <= 0 .Or. ;
				M->CJ_TABELA  # Posicione("SCJ",1,xFilial("SCJ")+M->CJ_NUM,"CJ_TABELA")
				M->CJ_CONDPAG # Posicione("SCJ",1,xFilial("SCJ")+M->CJ_NUM,"CJ_CONDPAG")
				_lCalcula := .T.
			Else
				SCK->(DbSetOrder(1)) //CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO
				If SCK->(DbSeek(xFilial("SCK") + M->CJ_NUM + TMP1->CK_ITEM,.F.))
					If TMP1->CK_PRODUTO # SCK->CK_PRODUTO .Or. ;
						TMP1->CK_PRCVEN  # SCK->CK_PRCVEN
						_lCalcula := .T.
					EndIf
				Else
					_lCalcula := .T.
				EndIf
			EndIf
			If _lCalcula
				_cProduto := TMP1->CK_PRODUTO
				_nPrcVen  := TMP1->CK_PRCVEN
				_cTES     := TMP1->CK_TES
				_cAcond   := TMP1->CK_ACONDIC + StrZero(TMP1->CK_METRAGE,5)
				_cDuplic  := If(Empty(_cTES),"  ",Posicione("SF4",1,xFilial("SF4")+_cTES,"F4_DUPLIC"))
				_aDadCli  := {M->CJ_CLIENTE,M->CJ_LOJA,M->CJ_VEND1,M->CJ_TABELA}
				_nComis   := u_VejaComis(_cProduto,_nPrcVen,_cDuplic,_cAcond,_aDadCli,Posicione("SE4",1,xFilial("SE4")+M->CJ_CONDPAG,"E4_AVISTA"))
				TMP1->CK_COMIS1 := _nComis
			EndIf
		EndIf
		TMP1->(DbSkip())
	EndDo
EndIf
Return(.T.)
*
******************************************************************************
User Function VejaComis(_cProduto,_nPrcVen,_cDuplic,_cAcond,_aDadCli,_cDescVis)
******************************************************************************
*TIRAR SE AUTO OK
/*/
Esta função passa a ser chamada também pela rotina de cadastro de orçamentos
e portanto todas as referências as tabelas SC5 tem que estar em um parâmetro da função.
Assim sendo, o parâmetro _aDadCli será um array com os seguintes componentes:
1 - Cód.Cliente(C6),2-Loja(C2),3-Cód Vendedor(C6), 4 - Tabela de preços do Pedido(C3))
_aDadCli := {M->C5_CLIENTE,M->C5_LOJACLI,M->C5_VEND1,lEN(M->C5_TABELA)}
/*/
DEFAULT _cDescVis := "N"

Private _PrcTab
Private _nComis := 0
Private _aDescCar

// A função TamSX3("C6_PRCVEN") retorna 1-Tamanho do campo - 2-Qtd.Decimais - 3-Tipo (NCDL)

_cProduto   := Padr(_cProduto,TamSX3("B1_COD")[1])
_nPrcVen    := Round(_nPrcVen,TamSX3("C6_PRCVEN")[2])
_cDuplic    := Padr(_cDuplic,TamSX3("F4_DUPLIC")[1])
_cAcond     := Padr(_cAcond,TamSX3("BE_LOCALIZ")[1])
_aDadCli[1] := Padr(_aDadCli[1],TamSX3("A1_COD")[1])
_aDadCli[2] := Padr(_aDadCli[2],TamSX3("A1_LOJA")[1])
_aDadCli[3] := Padr(_aDadCli[3],TamSX3("A3_COD")[1])
_aDadCli[4] := Padr(_aDadCli[4],TamSX3("DA1_CODTAB")[1])


If _cDuplic == "N" // Comissão = 0
	Return(0)
EndIf

_nComis := 0
_nComis := Posicione("SA1",1,xFilial("SA1")+_aDadCli[1]+_aDadCli[2],"A1_COMIS")
If _nComis <= 0
	_nComis := Posicione("SA3",1,xFilial("SA3")+_aDadCli[3],"A3_COMIS")
EndIf

// Se tenho a comissão num dos dois cadastros, não calcula pela carta de descontos
If _nComis > 0
	Return(_nComis)
EndIf

If TamSX3("B1_COD")[1] == 17
	//If Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_TIPO") == "PA" .And.;
	If Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_LOCALIZ") == "S" .And.;
		!Empty(Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_NOME"))
		_cProduto := Padr(Left(_cProduto,10),TamSX3("B1_COD")[1])
	EndIf
ElseIf Right(AllTrim(_cProduto),1) == "I" // Produto importado
	// Procurar os dados do produto Nacional
	_cProduto := AllTrim(_cProduto)
	_cProduto := Left(Left(_cProduto,Len(_cProduto)-1) + Space(Len(SB1->B1_COD)),Len(SB1->B1_COD))
EndIf

DbSelectArea("SZX")
DbSetOrder(1)

DbSelectArea("SZY")
DbSetOrder(1) // ZY_FILIAL+ZY_CODIGO+ZY_ITEM

DbSelectArea("DA1")
DA1->(DbSetOrder(1)) // DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
If !Empty(_cProduto) .And. _nPrcVen > 0 .And. !Empty(_cDuplic)
	_PrcTab   := u_TabBruto(_aDadCli[4],_cProduto,_cAcond)  // 1.1635
	If _PrcTab > 0
		_cDescs  := u_ClcDesc(_aDadCli[4],_aDadCli[3],_cProduto,_nPrcVen,_PrcTab,_cDescVis)
		// A função ClcDesc retorna:
		// {1-Desc.Efetivo,2-Desc.Padrão,3-% Comissão,4-% Min. Comissão,5-(*)Valor Minimo      }
		_nComis := If(_nPrcVen < _cDescs[5],_cDescs[4],_cDescs[3])
	EndIf
EndIf
Return(_nComis)
*
***************************************************************
User Function fCalcPreco(cProd,nPreco,cTabela,_nTotPV,cCondPag)
***************************************************************
*
Local nRet   := 0
Local nMin   := 0 //VARIAVEL QUE IRA DENIFIR MENOR VALOR POSSIVEL DO PRODUTO COM DESCONTOS
Local nX     := 0
Local nY     := 0
Local aDesc  := {}
Local aCond  := {}
Local cDesc  := ""
Local lOK    := .F.

DbSelectArea("DA1")
DbSetOrder(1) // DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM

DbSelectArea("SZX")
DbSetOrder(2) //ZX_FILIAL+ZX_CODTAB
If SZX->(DbSeek(xFilial("SZX")+cTabela,.F.))
	//POSICIONO NO ZX
	While !SZX->(Eof()) .And. xFilial("SZX") == SZX->ZX_FILIAL .And. Alltrim(SZX->ZX_CODTAB) == Alltrim(cTabela)
		If _nTotPV >= SZX->ZX_VLRINI //.And. _nTotPV <= SZX->ZX_VLRFIM
			lOK := .T.
			Exit
		EndIf
		SZX->(dbSkip())
	EndDo
	If lOK

		cDesc  := Alltrim(StrTran(SZX->ZX_DESCONT,"%",""))//35+18
		aDesc  := STRTOKARR(cDesc,"+")// Monta array { "35" ; "18" }

		DbSelectArea("DA1")
		If DbSeek(xFilial("DA1")+cTabela+cProd,.F.)
			nMin := DA1->DA1_PRCVEN
			For nZ := 1 to Len(aDesc)
				nMin := nMin * ( 1 - (Val(aDesc[nZ])/100) ) // 0,50 * (1 - (35/100)) => 0,325 ; 0,325 * ( 1-(18/100)) => 0,2665
			Next
			nRet := 100 - ((nPreco/nMin)*100)
		EndIf
	EndIf
EndIf
Return(nRet)
*
********************************************************
User Function CalcAdic(_xTabela,_xVend,_xProduto,lArray)
********************************************************
* TIRAR SE AUTO OK
// Procurar o Vendedor pra saber qual a regiao dele
DbSelectArea("SA3")
DbSetOrder(1)
DbSeek(xFilial("SA3") + _xVend,.F.)
_xRegi := SA3->A3_REGIAO         // 01

// Procurar a família no cadastro de nome dos produtos
DbSelectArea("SZ1")
DbSetOrder(1)
DbSeek(xFilial("SZ1")+Left(_xProduto,3),.F.)
_xFam := SZ1->Z1_FAMILIA           // 1
_nMaior := 0
_rMaior := 0
_lExata := .F.
// Fazer 3 Verificações - Se tem chave exata com familia,
//                        se tem chave exata sem familia,
//                        se tem alguma que se encaixe - Usar a maior
For _nVez := 1 to 3
	ConOut('LOOP ' + StrZero(_nVez,2))
	DbSelectArea("SZW") // Tabela de adicionais de descontos
	DbSetOrder(1)
	DbSeek(xFilial("SZW"),.F.)
	Do While SZW->ZW_FILIAL == xFilial("SZW") .And. SZW->(!Eof())
		If SZW->ZW_TABELA  == _xTabela .And. SZW->ZW_REGIAO == _xRegi .And. ;
			SZW->ZW_FAMILIA == _xFam    .And. _nVez == 1
			// Achei chave exata
			_rMaior := SZW->(Recno())
			_lExata := .T.
			Exit
		ElseIf _nVez == 2
			If (SZW->ZW_TABELA == _xTabela .And. SZW->ZW_REGIAO  == _xRegi .And. SZW->ZW_FAMILIA == "*"  ) .Or.;
				(SZW->ZW_TABELA == _xTabela .And. Empty(SZW->ZW_REGIAO)     .And. SZW->ZW_FAMILIA == _xFam) .Or.;
				(Empty(SZW->ZW_TABELA)      .And.  SZW->ZW_REGIAO == _xRegi .And. SZW->ZW_FAMILIA == _xFam)
				_DescAtu := u_CacDir(AllTrim(SZW->ZW_ADICION))
				If _DescAtu > _nMaior
					_nMaior := _DescAtu
					_rMaior := SZW->(Recno())
				EndIf
			EndIf
		ElseIf _nVez == 3
			If (SZW->ZW_TABELA == _xTabela .And. Empty(SZW->ZW_REGIAO)     .And. SZW->ZW_FAMILIA == "*"  ) .Or.;
				(Empty(SZW->ZW_TABELA)      .And. SZW->ZW_REGIAO == _xRegi  .And. SZW->ZW_FAMILIA == "*"  ) .Or.;
				(Empty(SZW->ZW_TABELA)      .And. Empty(SZW->ZW_REGIAO)     .And. SZW->ZW_FAMILIA == _xFam)
				_DescAtu := u_CacDir(AllTrim(SZW->ZW_ADICION))  // CHAMOU ESTA FUNÇÃO
				If _DescAtu > _nMaior
					_nMaior := _DescAtu
					_rMaior := SZW->(Recno())
				EndIf
			EndIf
		EndIf
		SZW->(DbSkip())
	EndDo
	If _lExata .Or. _nMaior > 0   // NAO ENTROU EM NENHU E VOLTOU COM F,0  3 -> F/8.35
		Exit
	EndIf
Next
_Volta := ''
If _rMaior > 0
	SZW->(DbGoTo(_rMaior))
	_Volta := "+"+AllTrim(SZW->ZW_ADICION)  // VOLTA COM +2,5+6
EndIf

If !lArray // Retornar o que era... e não o Array
	Return(_Volta)
EndIf


// Alteração de 14/10/14 ->  Após a Milca trazer um caso de cálculo de comissão errado, expliquei para a
// Daniela e chegamos a seguinte solução:
// Os adicionais de desconto deverão ser calculados um a um, ou seja, é ATÉ o percentual
// exemplo:
// Uma faixa de desconto de 35+22+10 e adicional de +8 pode ser:
// 35+22+10+1 ou 35+22+10+2 ou 35+22+10+3 ou 35+22+10+4
// 35+22+10+5 ou 35+22+10+6 ou 35+22+10+7 ou 35+22+10+8

// Se na mesma faixa de desconto o adicional for de +8+3 para cada faixa com o primeiro adicional, deve ser
// incluído outro adicional, no caso 3:
// Para a faixa 35+22+10+1 -> 35+22+10+1+1, 35+22+10+1+2, 35+22+10+1+3
// Para a faixa 35+22+10+2 -> 35+22+10+2+1, 35+22+10+2+2, 35+22+10+2+3
// Para a faixa 35+22+10+3 -> 35+22+10+3+1, 35+22+10+3+2, 35+22+10+3+3
// Para a faixa 35+22+10+4 -> 35+22+10+4+1, 35+22+10+4+2, 35+22+10+4+3
// Para a faixa 35+22+10+5 -> 35+22+10+5+1, 35+22+10+5+2, 35+22+10+5+3
// Para a faixa 35+22+10+6 -> 35+22+10+6+1, 35+22+10+6+2, 35+22+10+6+3
// Para a faixa 35+22+10+7 -> 35+22+10+7+1, 35+22+10+7+2, 35+22+10+7+3
// Para a faixa 35+22+10+8 -> 35+22+10+8+1, 35+22+10+8+2, 35+22+10+8+3

// Primeiro: Quantas"faixas de adicionais tem ?
_aFxAdics := {}
_xManip1 := AllTrim(Substr(_Volta,2)) + ";" // Retiro o primeiro sinal de + e coloco um ; pra saber que é o fim
_xManip2 := ""
Do While .T.
	_xManip3 := Left(_xManip1,1)
	If _xManip3 $ "1234567890"
		_xManip2 := _xManip2 + _xManip3
	ElseIf _xManip3 $ ",." .And. !"."$_xManip2
		_xManip2 := _xManip2 + "."
	ElseIf _xManip3 $ "+;"
		Aadd(_aFxAdics,Val(_xManip2))
		If _xManip3 == ";"
			Exit
		EndIf
		_xManip2 := ""
	EndIf
	_xManip1 := Right(_xManip1,Len(_xManip1)-1)
EndDo

_aResults := {}
MonteAdics(1,"")
//Return(_Volta)
Return(_aResults)
*
******************************
User Function VldReserv(_nCpo)
******************************
*
If GDDeleted(n)
	u_autoAlert("Não Alterar Este Campo com a Linha Excluída")
	Return(.F.)
EndIf
If _nCpo == 1 // C6_RES_SZZ
	_cNrRes := M->C6_RES_SZZ
	_cItRes := GDFieldGet("C6_ITE_SZZ",n)
Else
	_cNrRes := GDFieldGet("C6_RES_SZZ",n)
	_cItRes := C6_ITE_SZZ
EndIf
If Empty(_cNrRes) .And. Empty(_cItRes)
	Return(.T.)
ElseIf _nCpo == 2 .And. Empty(_cNrRes) // C6_ITE_SZZ
	u_autoAlert("Preencher Primeiro o Nro da Reserva")
	Return(.F.)
ElseIf Empty(M->C5_CLIENTE)              .Or. Empty(M->C5_LOJACLI)              .Or. Empty(GDFieldGet("C6_PRODUTO",n)) .Or. ;
	GDFieldGet("C6_QTDVEN",n) == 0.00 .Or. Empty(GDFieldGet("C6_ACONDIC",n)) .Or. Empty(GDFieldGet("C6_METRAGE",n))
	// Verificar se os todos os campos estão preenchidos
	u_autoAlert("Os Campos Cliente, Loja, Produto, Quantidade, Acondic. e Metragem devem estar Preenchidos")
	Return(.F.)
EndIf
If !Empty(_cNrRes) .And. Empty(_cItRes)
	// Verificar se existe essa reserva e se é desse cliente ( e se está confirmada ??)
	SZZ->(DbSetOrder(1)) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
	If !SZZ->(DbSeek(xFilial("SZZ") + _cNrRes,.F.))
		u_autoAlert("Reserva não Cadastrada")
		Return(.F.)
	ElseIf SZZ->ZZ_CLIENTE+SZZ->ZZ_LOJA # M->C5_CLIENTE+M->C5_LOJACLI
		u_autoAlert("Reserva Feita para Outro Cliente")
		Return(.F.)
		//	ElseIf SZZ->ZZ_TIPO == "0" // 0=A Confirmar;1=Confirmada
		//		u_autoAlert("Somente Reservas Confirmadas Podem Ser Utilizadas")
		//		Return(.F.)
	EndIf
ElseIf !Empty(_cNrRes) .And. !Empty(_cItRes)

	// Verificar se já não está informado em outro item do pedido
	For _nx :=1 to Len(aCols)
		If _nx # n .And. !GDDeleted(_nx)
			If GDFieldGet("C6_RES_SZZ",_nx)+GDFieldGet("C6_ITE_SZZ",_nx) == _cNrRes+_cItRes
				u_autoAlert("Reserva já Informada no Item " + Str(_nx,3))
				Return(.F.)
			EndIf
		EndIf
	Next

	// Verificar se existe essa reserva e se é desse cliente e produto
	_cAcond := GDFieldGet("C6_ACONDIC",n)+StrZero(GDFieldGet("C6_METRAGE",n),5)
	SZZ->(DbSetOrder(1)) // ZZ_FILIAL+ZZ_NUM+ZZ_ITEM
	If !SZZ->(DbSeek(xFilial("SZZ") + _cNrRes + _cItRes,.F.))
		u_autoAlert("Reserva não Cadastrada")
		Return(.F.)
	ElseIf SZZ->ZZ_CLIENTE+SZZ->ZZ_LOJA # M->C5_CLIENTE+M->C5_LOJACLI
		u_autoAlert("Reserva Feita para Outro Cliente")
		Return(.F.)
		//	ElseIf SZZ->ZZ_TIPO == "0" // 0=A Confirmar;1=Confirmada
		//		u_autoAlert("Somente Reservas Confirmadas Podem Ser Utilizadas")
		//		Return(.F.)
	ElseIf SZZ->ZZ_STATUS == "9" // 0=Em Aberto;1=Empenhada;9=Cancelada
		u_autoAlert("Reserva Cancelada")
		Return(.F.)
	ElseIf SZZ->ZZ_PRODUTO # GDFieldGet("C6_PRODUTO",n)
		u_autoAlert("Produtos da Reserva e do Item do Pedido São Diferentes")
		Return(.F.)
	ElseIf !(_cAcond $ SZZ->ZZ_LOCALIZ)
		u_autoAlert("Acondicionamento/Metragem Diferente da Reservada")
		Return(.F.)
	Elseif SZZ->ZZ_QUANT # GDFieldGet("C6_QTDVEN",n)
		u_autoAlert("Quantidade Diferente da Quantidade Reservada")
		Return(.F.)
	Elseif SZZ->ZZ_QTDPED > 0  //  VERIFICAR SE NÃO É O MESMO PEDIDO
		u_autoAlert("Reserva já Utilizada em Outro Pedido")
		Return(.F.)
	EndIf
EndIf
Return(.T.)
*
************************
User Function VerReser()
************************
* TIRAR SE AUTO OK MESMO
*
_cNrRes := GDFieldGet("C6_RES_SZZ",n) //23/08 CHAMOU (5/6/7) = ???/NA QUANTIDADE/
_cItRes := GDFieldGet("C6_ITE_SZZ",n)
If !Empty(_cNrRes+_cItRes)
	u_autoAlert("Não é Permitida a Alteração Deste Campo com os Campos Nro.Reserva ou Item Reserva Preenchidos")
	Return(.F.)
ElseIf  Alltrim(GDFieldGet("C6_SEMANA",n)) $ "RESERVA//ZP4"  .Or. Left(GDFieldGet("C6_SEMANA",n),1) == "r" // Tem que ser "r" mesmo
	u_autoAlert("Não é Permitido a Exclusão de Itens Reservados")
	Return(.F.)
EndIf
Return(.T.)
*
**************************************************
User Function TabBruto(_TabTab,_TabProd,_TabAcond, lPortal)
**************************************************
default lPortal	:= .F.
* TIRAR SE AUTO OK
// Esta função é utilizada em diversos programas e busca o preço bruto na tabela
// DA1 recebe os parâmetros Tabela, Produto e Acondicionamento

If Right(AllTrim(_TabProd),1) == "I" // Produto importado
	// Procurar os dados do produto Nacional
	_TabProd := AllTrim(_TabProd)
	_TabProd := Left(Left(_TabProd,Len(_TabProd)-1) + Space(Len(SB1->B1_COD)),Len(SB1->B1_COD))
EndIf

_PrcTab := 0
DA1->(DbSetOrder(1)) // DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
If DA1->(DbSeek(xFilial("DA1") + _TabTab + _TabProd,.F.))
	If AllTrim(_TabAcond) == "R00050" .And. DA1->DA1_PRC50M > 0
		_PrcTab := DA1->DA1_PRC50M
	ElseIf AllTrim(_TabAcond) $ "R00015//L00015" .And. DA1->DA1_PRC15M > 0
		_PrcTab := DA1->DA1_PRC15M
		if lPortal
			_PrcTab := ( _PrcTab/15 )
		endif
	ElseIf AllTrim(_TabAcond) $ "L00025" .And. DA1->DA1_PRC25M > 0
		_PrcTab := DA1->DA1_PRC25M
		if lPortal
			_PrcTab := ( _PrcTab/25 )
		endif
	ElseIf Left(AllTrim(_TabAcond),1) == "M" .And. DA1->DA1_PRCCAM > 0
		_PrcTab := DA1->DA1_PRCCAM
		/*
		if lPortal
			_PrcTab := ( _PrcTab/(Val(substr(Alltrim(_TabAcond),2, (len(Alltrim(_TabAcond))-1)))))
		endif
		*/
	Else
		_PrcTab := DA1->DA1_PRCVEN      //ESTE 1.1635
	EndIf
EndIf
Return(_PrcTab)  //1.1635


/*/{Protheus.doc} CliPed12
//TODO FDescrição Avalia condição para faturamento de material importado.
@author juliana.leme
@since 18/10/2016
@version undefined
@param _cCli, , descricao
@param _cLoj, , descricao
@param _cNum, , descricao
@param _cProd, , descricao
@param _dEmiss, , descricao
@param _TipoCli, , descricao
@param _ItPV, , descricao
@param _Acond, , descricao
@param _Metrag, , descricao
@type function
/*/
User Function CliPed12(_cCli,_cLoj,_cNum,_cProd,_dEmiss,_TipoCli,_ItPV,_Acond,_Metrag)
// ATENÇAO-- Se for para MT de Itu ou 3L, observar o ICMS
	Default _cCli   := Space(TamSX3("C5_CLIENTE")[1])
	Default _cLoj   := Space(TamSX3("C5_LOJACLI")[1])
	Default _cNum   := Space(TamSX3("C5_NUM")[1])
	Default _cProd  := Space(TamSX3("C6_COD")[1])
	Default _dEmiss := dDataBase
	Default _Acond  := ""
	Default _Metrag := 0
	
	DbSelectArea("ZZH")
	DbSetOrder(1)
	
	_dCST3 := Ctod("")
	_dCST5 := Ctod("")
	_dCST8 := Ctod("")
	
	_cProd  := AllTrim(_cProd) // Pego sempre o código principal
	_Acond  := AllTrim(_Acond)
	If Right(_cProd,1) == "I"
		_cProd  := Left(_cProd,Len(_cProd)-1)
	EndIf
	
	If !Empty(_Acond) .And. Len(_cProd) > 10
		_cProd := Left(_cProd,10)
	EndIf
	
	_cProdBase := _cProd
	_cProdI    := _cProd
	
	_lUsaAcond := Left(Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_CGC"),8) $ GetMv("MV_XTRCCOD")
	_lUsaAcond := (_lUsaAcond .And. !Empty(_Acond))
	If _lUsaAcond
		// Tem que agregar o acondicionamento no código do produto
		_Acond  := _Acond  + StrZero(If(Left(_Acond,1)=="B",0,_Metrag),5)
		_cProd  := _cProd  + _Acond
		_cProdI := _cProdI + _Acond
	EndIf
	_cProd     := Left(_cProd    +Space(50),Len(SB1->B1_COD))
	_cProdBase := Left(_cProdBase+Space(50),Len(SB1->B1_COD))
	
	//If SB1->B1_TIPO = "PA"
	If SB1->B1_LOCALIZ == "S"
		_cProdI    := _cProdI + "I"
	EndIf
	_cProdI    := Left(_cProdI   +Space(50),Len(SB1->B1_COD))
	
	DbSeek(xFilial("ZZH")+AllTrim(_cProdBase),.T.)
	Do While ZZH->ZZH_FILIAL == xFilial("ZZH") .And. AllTrim(_cProdBase) $ ZZH->ZZH_COD
		If (ZZH->ZZH_COD == _cProd .Or. ZZH->ZZH_COD == _cProdI) .And. !Empty(ZZH->ZZH_NFCI)
			If ZZH->ZZH_FCIX <= 40 .And. ZZH->ZZH_DTCAL > _dCST5
				_dCST5 := ZZH->ZZH_DTCAL
			ElseIf ZZH->ZZH_FCIX <= 70 .And. ZZH->ZZH_DTCAL > _dCST3
				_dCST3 := ZZH->ZZH_DTCAL
			ElseIf ZZH->ZZH_FCIX > 70 .And. ZZH->ZZH_DTCAL > _dCST8
				_dCST8 := ZZH->ZZH_DTCAL
			EndIf
		EndIf
		DbSkip()
	EndDo
	
	// Verificar se deve ou não ter FCI para o faturamento
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+_cProdBase,.F.))
	_lRegra		:= .F.   // a regra deve ser avaliada?
	_cCGC		:= Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_CGC")
	_lPedImp	:= .F.
	
	If SC5->C5_NUM $ GetMV("MV_ZZNOFCI")
		_lRegra := .F.
	ElseIf U_ValCadFCI(_cCli+_cLoj)
		_lRegra := .F.
	ElseIf SC5->C5_NUM $ GetMV("MV_ZZPVIMP")
		_lRegra := .T.
		_lPedImp := .T.
	ElseIf "02544042" $ _cCGC .And. xFilial("SC6") == "02" .And. Alltrim(SB1->B1_COD) = '2010000000';
		.and. DToS(dDataBase) < '20170901'
	// Estou transferindo de 3 Lagoas para Itu e é Vergalhão 
		_lRegra := .F.
	ElseIf "02544042" $ _cCGC .And. xFilial("SC6") == "02" .And. (SB1->B1_TIPO == "PA" .or. SB1->B1_TIPO == "SC") 
	// Estou transferindo de 3 Lagoas para Itu e é PA ou sucata
		_lRegra := .F.	
	ElseIf "02544042" $ _cCGC .And. xFilial("SC6") == "02" .And. SB1->B1_PESCOB > 0 .and. !(SB1->B1_TIPO == "PA" .or. SB1->B1_TIPO == "SC")
	// Estou transferindo de 3 Lagoas para Itu e é cobre
		_lRegra := .T.
	ElseIf (SB1->B1_TIPO == "PA" .And. SB1->B1_LOCALIZ == "S") .and. !("02544042" $ _cCGC .And. xFilial("SC6") == "02")
		_lRegra := .T.
	ElseIf Day(_dCST3)+Day(_dCST5)+Day(_dCST8) > 0 // Achei um cara no ZZH
		_lRegra := .T.
	ElseIf SB1->B1_PESCOB > 0	// Tem cobre envolvido?
		_lRegra := .T.
	EndIf
	
	If _lRegra .And. "85442000"$SB1->B1_POSIPI // É Cabo Coaxial
		_lRegra := .F.
	ElseIf Left(SC6->C6_CF,4) == "6910" // Remessa bonificação para outro estado
		_lRegra := .F.
	ElseIf Left(SC6->C6_CF,4) == "6118" // Remessa de venda por ordem e conta de terceiros
		_lRegra := .F.
	EndIf
	
	_Vlt2 := "N"
	_Volta := SB1->B1_ORIGEM
	
	If _lRegra
		_cEst := Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_EST")
		_cCtr := Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_CONTRUT")
		_cCGC := Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_CGC")
		_lCtrb:= Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_CONTRIB")=="1"
		_lCImp:= Posicione("SA1",1,xFilial("SA1")+_cCli+_cLoj,"A1_ZZIMPOR")=="1"
		_Vlt2 := "N"
		//Faturamento por Itu/SP
		/*
		18/10/2016 - Juliana Leme
		Alteração para faturamento importado conforme ultima versão da Industrialização v12
		*/
		//Faturamento Por Tres Lagoas/MS
		If xFilial("SC6") == "02"
			If _cCli == "002560" // IFC Itu
				If SB1->B1_TIPO # "PA//PI//MP"
					_Vlt2 := "I"
					_Volta := If(_dCST3>_dCST8,"3","8")// Com 4%
					If Day(_dCST3) == 0 .And. Day(_dCST8) == 0
						u_autoAlert("Item " + _ItPV + " com CST 3 sem FCI -> Produto " + _cProd, .F.)
					EndIf
				EndIf
			//Clientes Localizados no MS e não Construtora
			ElseIf (_cEst == "MS") .And. (_cCtr # "S")
				// Para MS ou Cons.Final ou Construtora
				_Vlt2 := "I"
				_Volta := If(_dCST3>_dCST8,"3","8")// Com 4%
				If Day(_dCST3) == 0 .And. Day(_dCST8) == 0
					u_autoAlert("Item " + _ItPV + " com CST 3 sem FCI -> Produto " + _cProd, .F.)
					// Não Tenho FCI para importado...tem que dar alert para fazer FCI do produto pois
					// deveria ser nacional com CST 3
				EndIf
			Else // Outros estados Mandar Nacional
				If Day(_dCST5) > 0
					_Volta := "5" //// Com 12%
				Else
					_Volta := "0"
				EndIf
			EndIf
		EndIf
		//Regras Importado Qualquer Origem - Pela Divisão de Pedidos
		If _lCImp .or. _lPedImp //Trava por cliente para importado
			_Vlt2 := "I"
			_Volta := If(_dCST3>_dCST8,"3","8")// Com 4%
			If Day(_dCST3) == 0 .And. Day(_dCST8) == 0
				u_autoAlert("Item " + _ItPV + " com CST 3 sem FCI -> Produto " + _cProd, .F.)
			EndIf
			//Clientes Localizados no MT
		/*ElseIf _cEst == "MT"
			_Vlt2 := "I"
			_Volta := If(_dCST3>_dCST8,"3","8")// Com 4%
			If Day(_dCST3) == 0 .And. Day(_dCST8) == 0
				u_autoAlert("Item " + _ItPV + " com CST 3 sem FCI -> Produto " + _cProd, .F.)
				// Não Tenho FCI para importado...tem que dar alert para fazer FCI do produto pois
				// deveria ser nacional com CST 3
			EndIf*/
		ElseIf xFilial("SC6") <> "02"// Outros estados Mandar Nacional
			If Day(_dCST5) > 0
				_Volta := "5" //// Com 12%
			Else
				_Volta := "0"
			EndIf
		EndIf
	EndIf
	
	If _Vlt2 == "I" // Verifica se tem o código do produto importado
		u_ReplSB1(_cProdBase,_cProdI)
	EndIf
	If _lUsaAcond
		u_ReplSB1(_cProdBase,_cProd)
	EndIf
Return(_Volta+_Vlt2)


***********************
User Function ConfFil()
***********************
*
// Valida se o pedido de venda pode ser incluído pela filial corrente
// Conforme solicitação Rafael/Denise todos os pedidos de venda cujo ICMS sai com
// taxa cheia deve ser incluídos em 3 Lagoas.
// Provisoriamente, quando incluir o pedido e for dessa forma e estiver incluindo em Itu
// Vou pedir para trocar a filial.
//
/*/
// Solicitação de 29/10/2014. Email da denise conforme abaixo:
Boa tarde, senhores:

O Rafael /Gustavo em reunião hoje alteraram o faturamento de todas as Construtoras e
Consumidores Finais ( contribuintes ou não do ICMS ), deverão sair por Itu a partir de
agora observando as seguintes regras:

1-	Construtoras e Consumidores Finais ( Contribuintes de ICMS )-deverão sair com
original NACIONAL ( Alíquota de ICMS do estado destinatário ),
2-	Construtoras e Consumidores Finais ( NÃO Contribuintes de ICMS )-deverão sair
com original de  IMPORTADO ( Alíquota de ICMS do estado remetente nesta caso SP 18% ),
3-	Os pedidos em carteira até hoje 30/10/14 seguirão ainda regra anterior.

- Peço ao nosso departamento de T.I. que tome as providências necessárias junto ao Sistema.

Desde já, obrigada.

/*/
_lVolta   := .T.
_CGCCli   := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_CGC")
_lConstru := (Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_CONTRUT")=="S") // Construtora ?
If Inclui .And. FWCodEmp()+FWCodFil() == "0102" .And. "02544042" # Left(_CGCCli,8) .And.;
	(_lConstru .Or. M->C5_TIPOCLI == "F")
	// Estou incluindo em 3 Lagoas e é construtora ou Cons.Final e não é a Cobrecom
	_lVolta  := .F.
	u_autoAlert("Atenção - Pedidos para Construtoras ou Para Cons.Final Somente por Itu")
EndIf
Return(_lVolta)
*******************************************
// As funções GetValor e PutValor foram escritas a pedido do Sr. Rafael devido a solicitação
// feita pelo setor de vendas para manter o valor unitário quando alteraR a quantidade no pedido de venda.
// Estas funções trabalham com uma variável pública (_nMyPrNow) que é inicializada na condição When do campo
// C6_QTDVEN, assumindo o valor anteriormante lançado em C6_PRCVEN e disparado no valid do campo
// C6_QTDVEN trocando o valor de C6_PRCVEN por _nMyPrNow se forem diferentes e _nMyPrNow seja > 0, atualizando
// também o valor total do item.
*
************************
User Function GetValor()
************************
*
Public _nMyPrNow

_nMyPrNow := 0
_cLances := GDFieldGet("C6_LANCES",n)
_cMetrag := GDFieldGet("C6_METRAGE",n)
If _cLances > 0 .And. _cMetrag > 0
	GDFieldPut("C6_LANCES",	0,n)
	//	u_autoAlert("Altere um dos campos Lances/Metragem para poder alterar a quantidade")
	//	Return(.F.)
EndIf
_nMyPrNow := GDFieldGet("C6_PRCVEN",n)
Return(.T.)
*
*************************
User Function IsReserva() //  !u_IsReserva()
*************************
*
local _cSeman 	:= GDFieldGet("C6_SEMANA",n)
local lRet		:= ( Alltrim( _cSeman) $ "RESERVA//ZP4//r" )
If lRet
	u_AutoAlert("Item do Pedido com Reserva. Não pode ser Alterado")
EndIf
Return(lRet)
*
************************
User Function PutValor()
************************
*
If Type("_nMyPrNow") == "U"
	_nMyPrNow := 0
EndIf

If _nMyPrNow > 0
	GDFieldPut("C6_PRCVEN",_nMyPrNow,n)
EndIf
GDFieldPut("C6_VALOR",GDFieldGet("C6_QTDVEN",n)*GDFieldGet("C6_PRCVEN",n),n)
A410MultT("C6_PRCVEN",GDFieldGet("C6_PRCVEN",n))
_nMyPrNow := 0
Return(.T.)
*
**********************************
User Function PrdNacion(_cCdPrd)
**********************************
*
Private _cCdPrd
*
If Right(AllTrim(_cCdPrd),1) == "I" // Produto importado
	// Procurar os dados do produto Nacional
	_cCdPrd := AllTrim(_cCdPrd)
	_cCdPrd := Padr((Left(_cCdPrd,Len(_cCdPrd)-1)),TamSX3("B1_COD")[1])
EndIf
Return(_cCdPrd)
*
********************************************************
User Function AvalPrz(_cTab,lTdOK,lForca,_NumPed,_CdCli,_CdLoja,AltEnt)
********************************************************
*
// Esta função é chamada pelo gatilho do campo C6_PRODUTO e do campo CK_PRODUTO e faz a
// avaliação do prazo de entrega do Pedido de venda usando os parâmetros MV_IFCPRZ1,
// MV_IFCPRZ2, MV_IFCPRZ3, MV_IFCPRZ4, MV_IFCPRZ5, MV_IFCPRZ6 com as regras abaixo:
//
// MV_IFCPRZ1 se bitola for <= a 1,00mm 	B1_BITOLA $ "01/02/03/20";
// MV_IFCPRZ2 se cabos especiais - 			B1_ESPECIA # "01"
// MV_IFCPRZ3 se cabos multiplos - 			Left(B1_NOME,2) $ "13/14/15/18"
// MV_IFCPRZ4 se cabos TORCIDOS/PARALELOS -	B1_NOME $ "120/122"
// MV_IFCPRZ5 se cabos RIGIDOS				B1_CLASENC == "2"
// MV_IFCPRZ6 se cabos Flexiveis 			B1_CLASENC == "4"
//
//
/*/ Tabela dos prazos por parâmetro X datas de alteração
Parâmetro	23/04/14	11/06/14	24/27/14
MV_IFCPRZ1	18			18			18
MV_IFCPRZ2	30			20			20
MV_IFCPRZ3	13			12
MV_IFCPRZ4	10			12			12
MV_IFCPRZ5	12			12			12
MV_IFCPRZ6	10			12			12
MV_IFCPRZ7	07			10			10
MV_IFCPRZ8	NOVO		10			05
/*/
// Observação de 23/04/14 -
// Daniela mandou e-mail solicitando alteração nos prazos de entrega para cabos flexives com
// bitolas entre 10 a 240mm2 ser 7 dias.
// Para isso, o parâmetro MV_IFCPRZ6 será utilizada para flexiveis com bitolas abaixo de 10 e acima de 240
// e o parâmetro MV_IFCPRZ7 também para flexiveis com bitolas entre 10 e 240 mm2, inclusive.
//
//
// Observação de 11/06/14 -
// Daniela mandou email em 10/06/14 para alterar os prazos de todos os produtos.
// Alterou também a lógica a ser aplicada.
// Abaixo texto do fonte da lógica alterada e foi incluída a do cabo coaxial.
/*/
If SB1->B1_BITOLA $ "01/02/03/20"
// Se bitola for <= a 1,00mm
_nPrz2 := GetMv("MV_IFCPRZ1")
ElseIf SB1->B1_ESPECIA # "01" .Or. SB1->B1_NOME $ "117/118"
// Se cabos especiais
_nPrz2 := GetMv("MV_IFCPRZ2")
ElseIf Left(SB1->B1_NOME,2) $ "13/14/15/18"
// Se cabos multiplos
_nPrz2 := GetMv("MV_IFCPRZ3")
ElseIf SB1->B1_NOME $ "120/121/122"
// Se cabos PARALELOS/PARALELO POLARIZADO/TORCIDO
_nPrz2 := GetMv("MV_IFCPRZ4")
ElseIf SB1->B1_CLASENC == "1" .Or. SB1->B1_CLASENC == "2"
// Se fios Sólidos ou cabos RIGIDOS
_nPrz2 := GetMv("MV_IFCPRZ5")
ElseIf SB1->B1_CLASENC == "4" .Or. SB1->B1_CLASENC == "5"
// Se cabos Flexiveis
If SB1->B1_BITOLA >= "08" .And. SB1->B1_BITOLA <= "18"
_nPrz2 := GetMv("MV_IFCPRZ7")
Else
_nPrz2 := GetMv("MV_IFCPRZ6")
EndIf
EndIf
/*/
// Observação 02/09/2014
// E mail enviado por Daniela alterando os prazos de entrega e também a regra dos produtos
// Cabo Flex 750V / Superatox 1kV / Atox 750V / Nax Flex 1kV / HEPR 1kV / Solda	, que entre as bitolas
// 1,5 ao 240 mm² tinha somente um prazo, agora os prazos são diferentes para 1,5 ao 16 mm² e 25 ao 240 mm².


Local _nPrz,_nCols,_dDtEntr,_nCtt,_lCont,lTdOK,lForca,_NumPed,_cCli,_dDtIni,AltEnt
local isVarejo	:= .F.
local nPrzVar	:= 0
local lNewPrz	:= GetNewPar('ZZ_NEWPRZ', .F.)
local cFili		:= FwFilial()
Default _CdCli := "      "
Default _CdLoja := "  '
Default AltEnt := .F.

If _cTab == "SC5" // Recalcular a data de entrega diretamente do SC5 e do SC6.
	lForca  := .F.
	lPvAuto := .F.
	lTdOK   := .F.
Else
	If ValType(lForca) == "U"
		lForca := .F.
	EndIf

	If !inclui .And. !lForca //    ???????????
		Return(Date())
	EndIf
	// _cTab pode ser SC6 ou SCK
	If Type("lPvAuto") == "U"
		lPvAuto := .F.
	EndIf
	If ValType(lTdOK) == "U"
		lTdOK := .F.
	EndIf
EndIf

//ATENÇÃO... No orçamento não trabalha com aCols... e sim com um DBF com alias de TMP1
//o campo TMP1->CK_FLAG indique se a linha esta ou não deletada. Este campo é do tipo lógico

_lCont := .T.
If _cTab == "SC5"
	_lCont 		:= .F.
	_cCli  		:= _CdCli
	_cLja  		:= _CdLoja
	isVarejo 	:= (SC5->C5_ZTPVEND == 'V')
	cFili		:= xFilial("SC5")
ElseIf _cTab == "SC6"
	If M->C5_TIPO # "N"
		// Ser for rotina automática OU o TIPO Não for  "N", não executar nada..
		// simplestmente retornar o que está lá
		_dDtEntr := M->C5_EMISSAO
		_lCont := .F.
	EndIf
	_cCli  		:= M->C5_CLIENTE
	_cLja  		:= M->C5_LOJACLI
	isVarejo 	:= (M->C5_ZTPVEND == 'V')
	cFili		:= xFilial("SC6")
Else
	_nRecTMP := TMP1->(RecNo())
	_cCli  		:= M->CJ_CLIENTE
	_cLja  		:= M->CJ_LOJA
	isVarejo 	:= (M->CJ_ZTPVEND == 'V')
	cFili		:= xFilial("SCJ")
EndIf

_nPrzCli := Posicione("SA1",1,xFilial("SA1")+_cCli+_cLja,"A1_PRZENTR")

If _cCli $ "002560//008918"
	/*/
	Solicitação feita pelo Natanael no chamado 1171:

	" Após conversa com Crispilho/Vitor este prazo de entrega precisa ser alterado para
	"7 DIAS UTEIS", quando se tratar de transferências.
	Códigos dos clientes:
	002560 - I.F.C. IND. E COM. DE CONDUTORES ELETRIC - ITU
	008918 - IFC IND. E COM. DE CONDUTORES ELETRICOS - TRES LAGOAS
	"

	/*/
	// 002560 - I.F.C. IND. E COM. DE CONDUTORES ELETRIC - ITU
	// 008918 - IFC IND. E COM. DE CONDUTORES ELETRICOS - TRES LAGOAS
	_nPrz := GetMv("MV_IFCPRZ9")
	_dDtEntr := Date()
	For _nCtt := 1 to _nPrz
		_dDtEntr := DataValida(++_dDtEntr)
	Next
	_dDtEntr := U_DataIFC(Date(),_dDtEntr)	//Verifica existência de feriados locais que não constam na tabela padrão do Protheus

	If _cTab == "SC5" .And. SC5->C5_ENTREG # _dDtEntr
		DbSelectArea("SC5")
		RecLock("SC5",.F.)
		SC5->C5_ENTREG := _dDtEntr
		MsUnLock()

		DbSelectArea("SC6")
		DbSetOrder(1)
		DbSeek(xFilial("SC6")+SC5->C5_NUM,.F.)
		Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())
			RecLock("SC6",.F.)
			SC6->C6_ENTREG := _dDtEntr
			MsUnLock()
			SC6->(DbSkip())
		EndDo
	ElseIf _cTab == "SC6"
		If M->C5_ENTREG < _dDtEntr
			M->C5_ENTREG := _dDtEntr // Manter esta linha... o gatilho não está atualizando o C5_ENTREG
		Else
			_dDtEntr := M->C5_ENTREG
		EndIf

		// Troca Todos os acols
		For _nCols := 1 to Len(aCols )
			GDFieldPut("C6_ENTREG",_dDtEntr,_nCols)
		Next
	EndIf
ElseIf _lCont

	If _nPrzCli > 0 // Cliente tem prazo fixo estipulado no SA1
		_nPrz := _nPrzCli
	Else
		
		if isVarejo
			if ( nPrzVar := U_dtEntrVar() ) > 0
				_nPrz := nPrzVar
			endif
		endif
		if nPrzVar == 0
		
			SB1->(DbSetOrder(1))
			//SB1->(DbSeek(xFilial("SB1")+GDFieldGet("C6_PRODUTO",n),.F.))
			// no gatilho o aCols ainda não foi atualizado -
			// Usar a variável M->C6_PRODUTO
			// Verificar em todos os aCols qual o maior prazo
			_nPrz := 0
			_nQtdCl := If(_cTab=="SC6",Len(aCols),TMP1->(RecCount()))
			For _nCols := 1 to _nQtdCl
				If _cTab=="SC6"
					_lDelLin := GDDeleted(_nCols)
				Else
					TMP1->(DbGoTo(_nCols))
					_lDelLin := TMP1->CK_FLAG
				EndIf
				If 	!_lDelLin
					If _nCols == Iif(_cTab=="SC6",n,TMP1->(Recno()))
						_cProd := Iif(_cTab=="SC6",;
						Iif(lTdOK,GDFieldGet("C6_PRODUTO",_nCols),M->C6_PRODUTO),;
						Iif(lTdOK,TMP1->CK_PRODUTO               ,M->CK_PRODUTO))
					Else
						_cProd := Iif(_cTab=="SC6",GDFieldGet("C6_PRODUTO",_nCols),TMP1->CK_PRODUTO)
					EndIf
					SB1->(DbSeek(xFilial("SB1")+_cProd,.F.))
					_nPrz2 := 0
					if lNewPrz
						u_cbcAvalPrz(cFili, AllTrim(SB1->B1_COD), _cCli, _cLja, isVarejo, @_nPrz2)
					else
						/*[LEO]- 09/01/17 -> O PORTAL TAMBEM UTILIZA ESTA LOGICA DE CONDIÇÔES MUDAR AQUI MUDAR EM cbcProductValues:dlvFromProd() */
						If Left(SB1->B1_NOME,1) == "3"
							// Cabos controle - Alteração efetuada em 14/03/16 - Roberto, conforme solicitação via fone
							// do Crispilho. Enviado e-mail para ele para confirmar a regra utilizada, ou seja, todos os
							// Cabos controle independentemente da bitola tem o mesmo prazo de entrega.
							_nPrz2 := GetMv("MV_IFCPRZE")
						ElseIf SB1->B1_NOME == "199"
							// Se cabos coaxial
							_nPrz2 := GetMv("MV_IFCPRZ8")
						ElseIf SB1->B1_ESPECIA # "01" .Or. SB1->B1_NOME $ "117/118"
							// Se cabos especiais
							_nPrz2 := GetMv("MV_IFCPRZ2")
						ElseIf SB1->B1_NOME $ "120/121/122"
							// Se cabos PARALELOS/PARALELO POLARIZADO/TORCIDO
							_nPrz2 := GetMv("MV_IFCPRZ4")
						ElseIf SB1->B1_CLASENC == "1" .Or. SB1->B1_CLASENC == "2"
							// Se fios Sólidos ou cabos RIGIDOS
							_nPrz2 := GetMv("MV_IFCPRZ5")
						ElseIf SB1->B1_BITOLA $ "01/02/03/20"
							// Se bitola for <= a 1,00mm
							_nPrz2 := GetMv("MV_IFCPRZ1")
						ElseIf SB1->B1_NOME $ "103/111/119/182/183/184"
							// Atox 750v/ Superatox 750v/ Múltiplos Superatox 2,3,4 c 1Kv
							If SB1->B1_BITOLA <= "18" // Até 240 mm2
								_nPrz2 := GetMv("MV_IFCPRZC")
							Else // Demais bitolas 300 ao 500
								_nPrz2 := GetMv("MV_IFCPRZD")
							EndIf
						ElseIf Left(SB1->B1_NOME,2) $ "13/14/15/18"
							// Se cabos multiplos
							If SB1->B1_BITOLA >= "04" .And. SB1->B1_BITOLA <= "07" // DO 1,5 AO 6,0 MM2
								_nPrz2 := GetMv("MV_IFCPRZ3")
							ElseIf SB1->B1_BITOLA >= "08" .And. SB1->B1_BITOLA <= "15" // DO 10 ao 120 mm2
								_nPrz2 := GetMv("MV_IFCPRZA")
							Else
								// Este Else é somente para o caso de haver um erro
								_nPrz2 := Max(GetMv("MV_IFCPRZ3"),GetMv("MV_IFCPRZA"))
							EndIf
						ElseIf SB1->B1_CLASENC == "4" .Or. SB1->B1_CLASENC == "5"
							// Se cabos Flexiveis
							If SB1->B1_BITOLA >= "04" .And. SB1->B1_BITOLA <= "09" // 1,5 AO 16
								_nPrz2 := GetMv("MV_IFCPRZB")
							ElseIf SB1->B1_BITOLA >= "10" .And. SB1->B1_BITOLA <= "18" // 25 ao 240
								_nPrz2 := GetMv("MV_IFCPRZ7")
							Else // Demais bitolas 300 ao 500
								_nPrz2 := GetMv("MV_IFCPRZ6")
							EndIf
						ElseIf SB1->B1_NOME == "104" .Or. SB1->B1_NOME == "123"
							//CABO DE COBRE NU TMD CL2A ou CABO DE COBRE NU TMD CLASSE 3A 
							_nPrz2 := GetNewPar("MV_IFCPRZF", 12)
						EndIf
					endif
					/* [LEO]- 09/01/17 */
					If !lPvAuto
						If _nPrz2 == 0
							u_autoAlert("Produto não possui regra para cálculo de data de entrega - Verifique")
						EndIf
					EndIf
					_nPrz := Max(_nPrz2,_nPrz)
				EndIf
			Next
		endif
	EndIf

	_dDtEntr := If(AltEnt,ddatabase,Date())

	For _nCtt := 1 to _nPrz
		_dDtEntr := DataValida(++_dDtEntr)
	Next

	_dDtEntr := U_DataIFC(Date(),_dDtEntr)	//Verifica existência de feriados locais que não constam na tabela padrão do Protheus

	_lAtuDt := .F.
	If _cTab == "SC6"
		If (M->C5_ENTREG < _dDtEntr .And. M->C5_CONDPAG # "000") .Or. _nPrzCli > 0 // Quando for BNDES ou tem prazo no cliente, aceitar o que foi digitado
			M->C5_ENTREG := _dDtEntr // Manter esta linha... o gatilho não está atualizando o C5_ENTREG
			M->C5_ENTRVT := _dDtEntr // Campo Virtual
			_lAtuDt := .T.
		//Else  -> Alterado por Roberto Oliveira 20/03/17 - Estava entrando neste Else e a M->CJ_ENTREG estava < Date()
		ElseIf M->C5_ENTREG > Date() //
			_dDtEntr := M->C5_ENTREG
		EndIf

		// Troca Todos os acols
		For _nCols := 1 to Len(aCols )
			GDFieldPut("C6_ENTREG",_dDtEntr,_nCols)
		Next
	Else
		If (M->CJ_ENTREG < _dDtEntr .And. M->CJ_CONDPAG # "000") .Or. _nPrzCli > 0 // Quando for BNDES ou tem prazo no cliente, aceitar o que foi digitado
			M->CJ_ENTREG := _dDtEntr // Manter esta linha... o gatilho não está atualizando o C5_ENTREG
			_lAtuDt := .T.
		//Else  -> Alterado por Roberto Oliveira 20/03/17 - Estava entrando neste Else e a M->CJ_ENTREG estava < Date()
		ElseIf M->CJ_ENTREG > Date() //
			_dDtEntr := M->CJ_ENTREG
		EndIf

		TMP1->(DbGoTop())
		Do While TMP1->(!Eof())
			//			RecLock("TMP1",.F.) O TMP1 está exclusivo
			TMP1->CK_ENTREG := _dDtEntr
			//			TMP1->(MsUnLock())
			TMP1->(DbSkip())
		EndDo
		If _nRecTMP <= TMP1->(RecCount())
			// Retornar o registro do TMP1 como estava, mesmo que seja o EOF.
			//
			TMP1->(DbGoTo(_nRecTMP))
		EndIf
	EndIf
	
	If _lAtuDt .And. !lPvAuto .And. !lTdOK .And. !U_isAuto()
		GETDREFRESH()
		SetFocus(oGetDad:oBrowse:hWnd) // Atualizacao por linha
		oGetDad:Refresh()
	EndIf
	
ElseIf _cTab == "SC5"
	_aArea := GetArea()
	DbSelectArea("SC5")
	_aAreaC5 := GetArea()
	SC5->(DbSetOrder(1))

	DbSelectArea("SC6")
	_aAreaC6 := GetArea()
	SC6->(DbSetOrder(1))

	DbSelectArea("SB1")
	_aAreaB1 := GetArea()
	SB1->(DbSetOrder(1))

	If _nPrzCli > 0 // Cliente tem prazo fixo estipulado no SA1
		_nPrz := _nPrzCli
	Else
		
		if isVarejo
			if ( nPrzVar := U_dtEntrVar() ) > 0
				_nPrz := nPrzVar
			endif
		endif
		if nPrzVar == 0
				
			SC5->(DbSeek(xFilial("SC5")+_NumPed,.F.))
	
			SC6->(DbSeek(xFilial("SC6")+_NumPed,.F.))
	
			_nPrz := 0
			Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == _NumPed .And. SC6->(!Eof())
				SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.))
				_nPrz2 := 0
				if lNewPrz
					u_cbcAvalPrz(cFili, AllTrim(SB1->B1_COD), _cCli, _cLja, isVarejo, @_nPrz2)
				else
					/*[LEO]- 09/01/17 -> O PORTAL TAMBEM UTILIZA ESTA LOGICA DE CONDIÇÔES MUDAR AQUI MUDAR EM cbcProductValues:dlvFromProd() */
					If Left(SB1->B1_NOME,1) == "3"
						// Cabos controle - Alteração efetuada em 14/03/16 - Roberto, conforme solicitação via fone
						// do Crispilho. Enviado e-mail para ele para confirmar a regra utilizada, ou seja, todos os
						// Cabos controle independentemente da bitola tem o mesmo prazo de entrega.
						_nPrz2 := GetMv("MV_IFCPRZE")
					ElseIf SB1->B1_NOME == "199"
						// Se cabos coaxial
						_nPrz2 := GetMv("MV_IFCPRZ8")
					ElseIf SB1->B1_ESPECIA # "01" .Or. SB1->B1_NOME $ "117/118"
						// Se cabos especiais
						_nPrz2 := GetMv("MV_IFCPRZ2")
					ElseIf SB1->B1_NOME $ "120/121/122"
						// Se cabos PARALELOS/PARALELO POLARIZADO/TORCIDO
						_nPrz2 := GetMv("MV_IFCPRZ4")
					ElseIf SB1->B1_CLASENC == "1" .Or. SB1->B1_CLASENC == "2"
						// Se fios Sólidos ou cabos RIGIDOS
						_nPrz2 := GetMv("MV_IFCPRZ5")
					ElseIf SB1->B1_BITOLA $ "01/02/03/20"
						// Se bitola for <= a 1,00mm
						_nPrz2 := GetMv("MV_IFCPRZ1")
					ElseIf SB1->B1_NOME $ "103/111/119/182/183/184"
						// Atox 750v/ Superatox 750v/ Múltiplos Superatox 2,3,4 c 1Kv
						If SB1->B1_BITOLA <= "18" // Até 240 mm2
							_nPrz2 := GetMv("MV_IFCPRZC")
						Else // Demais bitolas 300 ao 500
							_nPrz2 := GetMv("MV_IFCPRZD")
						EndIf
					ElseIf Left(SB1->B1_NOME,2) $ "13/14/15/18"
						// Se cabos multiplos
						If SB1->B1_BITOLA >= "04" .And. SB1->B1_BITOLA <= "07" // DO 1,5 AO 6,0 MM2
							_nPrz2 := GetMv("MV_IFCPRZ3")
						ElseIf SB1->B1_BITOLA >= "08" .And. SB1->B1_BITOLA <= "15" // DO 10 ao 120 mm2
							_nPrz2 := GetMv("MV_IFCPRZA")
						Else
							// Este Else é somente para o caso de haver um erro
							_nPrz2 := Max(GetMv("MV_IFCPRZ3"),GetMv("MV_IFCPRZA"))
						EndIf
					ElseIf SB1->B1_CLASENC == "4" .Or. SB1->B1_CLASENC == "5"
						// Se cabos Flexiveis
						If SB1->B1_BITOLA >= "04" .And. SB1->B1_BITOLA <= "09" // 1,5 AO 16
							_nPrz2 := GetMv("MV_IFCPRZB")
						ElseIf SB1->B1_BITOLA >= "10" .And. SB1->B1_BITOLA <= "18" // 25 ao 240
							_nPrz2 := GetMv("MV_IFCPRZ7")
						Else // Demais bitolas 300 ao 500
							_nPrz2 := GetMv("MV_IFCPRZ6")
						EndIf
					ElseIf SB1->B1_NOME == "104" .Or. SB1->B1_NOME == "123"
						//CABO DE COBRE NU TMD CL2A ou CABO DE COBRE NU TMD CLASSE 3A 
						_nPrz2 := GetNewPar("MV_IFCPRZF", 12)					
					EndIf
					/* [LEO]- 09/01/17 */
				endif
				_nPrz := Max(_nPrz2,_nPrz)
				SC6->(DbSkip())
			EndDo
		endif
	EndIf

	_dDtEntr := If(AltEnt,dDataBase,Date())
	For _nCtt := 1 to _nPrz
		_dDtEntr := DataValida(++_dDtEntr)
	Next
	_dDtEntr := U_DataIFC(Date(),_dDtEntr)	//Verifica existência de feriados locais que não constam na tabela padrão do Protheus

	If (SC5->C5_ENTREG < _dDtEntr .And. SC5->C5_CONDPAG # "000") .Or. _nPrzCli > 0 // Quando for BNDES ou tem prazo no cliente, aceitar o que foi digitado
		DbSelectArea("SC5")
		RecLock("SC5",.F.)
		SC5->C5_ENTREG := _dDtEntr
		MsUnLock()

		DbSelectArea("SC6")
		DbSetOrder(1)
		DbSeek(xFilial("SC6")+_NumPed,.F.)
		Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == _NumPed .And. SC6->(!Eof())
			RecLock("SC6",.F.)
			SC6->C6_ENTREG := _dDtEntr
			MsUnLock()
			SC6->(DbSkip())
		EndDo
		u_zVlValPr(_dDtEntr)
	EndIf

	RestArea(_aAreaB1)
	RestArea(_aAreaC6)
	RestArea(_aAreaC5)
	RestArea(_aArea)
EndIf
Return(_dDtEntr)
*
*
// Atenção:
// Esta função é chamada no gatilho do campo C6_PRODUTO sendo que se deve observar a ordem
// de chamada dos gatilhos, ou seja, após o gatilho que troca o TES.
************************
User Function AvalCFOP()
************************
*
Local aDadosCfo := {}

_cVolta := "  "
dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
dbSetOrder(1)
DbSeek(xFilial()+IIf(!Empty(M->C5_CLIENT),M->C5_CLIENT,M->C5_CLIENTE)+M->C5_LOJAENT)

dbSelectArea("SF4")
dbSetOrder(1)
If ( DbSeek(xFilial("SF4")+GDFieldGet("C6_TES",n),.F.) )
	If At(M->C5_TIPO,"DB") == 0
		Aadd(aDadosCfo,{"OPERNF","S"})
		Aadd(aDadosCfo,{"TPCLIFOR",M->C5_TIPOCLI})
		Aadd(aDadosCfo,{"UFDEST",SA1->A1_EST})
		Aadd(aDadosCfo,{"INSCR" ,SA1->A1_INSCR})
		If SA1->(FieldPos("A1_CONTRIB")) > 0
			Aadd(aDadosCfo,{"CONTR", SA1->A1_CONTRIB})
		EndIf
	Else
		Aadd(aDadosCfo,{"OPERNF","S"})
		Aadd(aDadosCfo,{"TPCLIFOR",M->C5_TIPOCLI})
		Aadd(aDadosCfo,{"UFDEST",SA2->A2_EST})
		Aadd(aDadosCfo,{"INSCR" ,SA2->A2_INSCR})
	EndIf
	_cVolta := MaFisCfo(,SF4->F4_CF,aDadosCfo)
EndIf
Return(_cVolta)


User Function Cod_c6()

DbSelectArea("SA1")
DbSelectArea("SA2")
dbSelectArea("SF4")

DbselectArea("SC5")
DbSetOrder(1)

DbSelectArea("SC6")
DbSetOrder(1)
DbSeek(xFilial("SC6"),.F.)
Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->(!Eof())

	_C6_NUM := SC6->C6_NUM
	SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM,.F.))
	M->C5_TIPO    := SC5->C5_TIPO
	M->C5_CLIENT  := SC5->C5_CLIENT
	M->C5_CLIENTE := SC5->C5_CLIENTE
	M->C5_LOJAENT := SC5->C5_LOJAENT
	M->C5_TIPOCLI := SC5->C5_TIPOCLI
	Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == _C6_NUM .And. SC6->(!Eof())
		If SC6->C6_QTDENT >= SC6->C6_QTDVEN .Or. SC6->C6_BLQ == "R "
			SC6->(DbSkip())
			Loop
		EndIf


		_cVolta := "  "
		aDadosCfo := {}
		dbSelectArea(IIF(M->C5_TIPO$"DB","SA2","SA1"))
		dbSetOrder(1)
		DbSeek(xFilial()+IIf(!Empty(M->C5_CLIENT),M->C5_CLIENT,M->C5_CLIENTE)+M->C5_LOJAENT)

		dbSelectArea("SF4")
		dbSetOrder(1)
		If ( DbSeek(xFilial("SF4")+SC6->C6_TES,.F.) )
			If At(M->C5_TIPO,"DB") == 0
				Aadd(aDadosCfo,{"OPERNF","S"})
				Aadd(aDadosCfo,{"TPCLIFOR",M->C5_TIPOCLI})
				Aadd(aDadosCfo,{"UFDEST",SA1->A1_EST})
				Aadd(aDadosCfo,{"INSCR" ,SA1->A1_INSCR})
				If SA1->(FieldPos("A1_CONTRIB")) > 0
					Aadd(aDadosCfo,{"CONTR", SA1->A1_CONTRIB})
				EndIf
			Else
				Aadd(aDadosCfo,{"OPERNF","S"})
				Aadd(aDadosCfo,{"TPCLIFOR",M->C5_TIPOCLI})
				Aadd(aDadosCfo,{"UFDEST",SA2->A2_EST})
				Aadd(aDadosCfo,{"INSCR" ,SA2->A2_INSCR})
			EndIf
			_cVolta := MaFisCfo(,SF4->F4_CF,aDadosCfo)

			If SC6->C6_TESORI # SC6->C6_TES .Or. SC6->C6_CF # _cVolta
				RecLock("SC6",.F.)
				SC6->C6_TESORI := SC6->C6_TES
				SC6->C6_CF     := _cVolta
				MsUnLock()
			Else
				RecLock("SC6",.F.)
				SC6->C6_CF     := _cVolta
				MsUnLock()
			EndIf

		Else
			cccc := "erro"
		EndIf
		SC6->(DbSkip())
	EndDo
EndDo
Return(.T.)
*
***************************************
Static Function MonteAdics(nVez,_cBase)
***************************************
*
Local nVez
Local _nVolta
Local _cBase
Local nQtd := _aFxAdics[nVez]
Local nNumAtu := 1

For _nVolta := 1 To nQtd
	_xBase := _cBase+StrZero(_nVolta,2)+"+"
	Aadd(_aResults,_xBase)
	If Len(_aFxAdics) > nVez
		MonteAdics(nVez+1,_xBase)
	EndIf
Next
Return(.T.)
*
**********************************
User Function DataIFC(_dDtI,_dDtF)
**********************************
*
///////////////////////////////////////
// Função para verificar existência de feriados locais que não constam na tabela padrão do Protheus,
// e aumentar a quantidade de dias úteis à data de entrega do pedido de vendas.
// Motivo: Ao cadastrar um feriado local na tabela padrão, o mesmo terá impacto sobre o vencimento dos títulos no financeiro.
// Observações:
// -O prazo para data de entrega sempre é contado em dias úteis (premissa).
// -Os feriados devem estar cadastrados na tabela ZV de cada filial.
///////////////////////////////////////
Local aArea, aAreaSX5, cDtAux, dAux

//Salva Ponteiros
aArea    := GetArea()
aAreaSX5 := SX5->(GetArea())

//Consulta se existe feriados no período
SX5->(DbSetOrder(1))					//X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_
SX5->(DbSeek(xFilial("SX5")+"ZV",.F.))	//Posiciona no primeiro item da tabela ZV

// ATENÇÃO - ESTA TABELA TRATA SOMENTE FERIADOS LOCAIS

//Percorre a tabela ZV procurando por feriados
Do While SX5->X5_FILIAL == xFilial("SX5") .And. SX5->X5_TABELA == "ZV" .And. SX5->(!Eof())
	//Verifica se o feriado está dentro do período (data atual - data de entrega)
	cDtAux := Substr(SX5->X5_DESCRI,1,8)
	If cDtAux >= DtoS(_dDtI) .And. cDtAux <= DtoS(_dDtF)
		//Verifica se o feriado é dia útil (só aumenta data de entrega se feriado cair em dia útil)
		dAux := StoD(cDtAux)
		If DataValida(dAux,.T.) == dAux
			//Aumenta 1 dia na data de entrega
			_dDtF += 1
		EndIf
	EndIf
	SX5->(DbSkip())
EndDo
//Recalcula Data Válida
_dDtF := DataValida(_dDtF,.T.)	//.T. = Considera próximo dia útil

//Restaura Ponteiros
RestArea(aAreaSX5)
RestArea(aArea)
Return(_dDtF)
*
************************
User Function ConfDtEn()
************************
*
// Função para validação da data de entrega.
// É chamada no X3_VLDUSER do campo C5_ENTREG.
Local _Volta,_nVez
//Default cOpcao := "MATA???"

If Type("cOpcao") == "U"
	cOpcao := "MATA???"
EndIf

u_autoAlert("Atenção:" + Chr(13) + Chr(13) + ;
			"A data de entrega somente deve ser alterada" + Chr(13) + ;
			"após a digitação de todos os itens do pedido",.F.)

_Volta := (M->C5_ENTREG>=M->C5_EMISSAO .And. M->C5_ENTREG>=M->C5_DTFAT)

If Type("M->C5_ENTRVT") == 'D' // Existe a variável
	If M->C5_ENTREG < M->C5_ENTRVT
		u_autoAlert("Atenção:" + Chr(13) + Chr(13) + ;
					"A data de entrega somente deve ser alterada" + Chr(13) + ;
					"para uma data maior que a data calculada.",.F.)
		M->C5_ENTREG := M->C5_ENTRVT
		Return(.F.)
	EndIf
EndIf

_dVolta := u_VejaDUtil(M->C5_ENTREG)
If M->C5_ENTREG # _dVolta
	If u_autoAlert("Data Inválida! Assume Dia Útil Posterior?",.T.,'MsgBox','Confirma?',,'YesNo',.T.)
		M->C5_ENTREG := _dVolta
	Else
	 	Return(.F.)
	EndIf
EndIf

If cOpcao == "RENEGOCIAR" .And. _Volta
	// A data de entrega somente poderá ser maior que a data que esteja no pedido
	_Volta := (M->C5_ENTREG >= SC5->C5_ENTREG)
	If _Volta
		// Verifica se a data é dia útil e se não é feriado local
		M->C5_ENTREG := DataValida(M->C5_ENTREG)

		Do While .T.
			//Consulta se existe feriados no período
			SX5->(DbSetOrder(1))					//X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_
			SX5->(DbSeek(xFilial("SX5")+"ZV",.F.))	//Posiciona no primeiro item da tabela ZV
			// ATENÇÃO - ESTA TABELA TRATA SOMENTE FERIADOS LOCAIS
			//Percorre a tabela ZV procurando por feriados
			Do While SX5->X5_FILIAL == xFilial("SX5") .And. SX5->X5_TABELA == "ZV" .And. SX5->(!Eof())
				//Verifica se a data é feriado local
				cDtAux := Substr(SX5->X5_DESCRI,1,8)
				If cDtAux == DtoS(M->C5_ENTREG)
					M->C5_ENTREG++
					Exit
				EndIf
				SX5->(DbSkip())
			EndDo
			cDtAux := M->C5_ENTREG
			M->C5_ENTREG := DataValida(M->C5_ENTREG)
			If cDtAux == M->C5_ENTREG
				// não teve alteração na data
				Exit
			EndIf
		EndDo
		// Trocar a data de entrega no ACOLS
		For _nVez := 1 to Len(aCols)
			GDFieldPut("C6_ENTREG",M->C5_ENTREG,_nVez)
		Next
	EndIf
EndIf
Return(_Volta)
*
*****************************************************
User Function ValCondPg(cTab,dEmiss,cCondic,cCliLj)
*****************************************************
*
Local _aConds := {}
Local nTotPV := 0
Local _lVolta := .F.
Local nI,cTab,dEmiss,cCondic,cCliLj
Local _lTemFin := .F. // Não tem financeiro no TES

If dEmiss < Ctod("12/04/2015") // Pedidos anteriores a 09/04/2015 não passam por esta validação
	Return(.T.)
ElseIf Empty(cCondic) // Campo obrigatório... vai bloquear depois
	Return(.T.)
ElseIf Left(Posicione("SA1",1,xFilial("SA1")+cCliLj,"A1_CGC"),8) == "02544042" // É a prórpia IFC
	Return(.T.)
ElseIf Altera
	_CndAtu := If(cTab=="SC5",SC5->C5_CONDPAG,SCJ->CJ_CONDPAG)
	If cCondic == _CndAtu // Mesma condição que já está no pedido de vendas
		Return(.T.)
	EndIf
EndIf

// Somar o Pedido e Verificar se tem financeiro no TES
If cTab == "SC5"
	For nI:= 1 to Len(aCols)
		If !GDDeleted(nI)
			nTotPV += GDFieldGet("C6_VALOR",nI)
			If !_lTemFin
				If Empty(GDFieldGet("C6_TES",nI))
					_lTemFin := .T. // Considero que tem financeiro na operação
				ElseIf Posicione("SF4",1,xFilial("SF4")+GDFieldGet("C6_TES",nI),"F4_DUPLIC") == "S"
					_lTemFin := .T. // Tem financeiro no TES
				EndIf
			EndIf
		EndIf
	Next
Else
	DbSelectArea("TMP1")
	DbGoTop()
	Do While TMP1->(!Eof())
		If !TMP1->CK_FLAG // Não deletado
			nTotPV += TMP1->CK_VALOR
			If !_lTemFin
				If Empty(TMP1->CK_TES)
					_lTemFin := .T. // Considero que tem financeiro na operação
				ElseIf Posicione("SF4",1,xFilial("SF4")+TMP1->CK_TES,"F4_DUPLIC") == "S"
					_lTemFin := .T. // Tem financeiro no TES
				EndIf
			EndIf
		EndIf
		TMP1->(DbSkip())
	EndDo
EndIf
If _lTemFin // Tem financeiro no TES
	If cCondic == "000"
		_nVMimBn := GetMV("MV_X_MINBN")
		If nTotPV < _nVMimBn
			u_autoAlert("Pedidos BNDES - Valor Mínimo R$ " + Transform(_nVMimBn,"@E 999,999.99"))
			Return(.F.)
		Else
			Return(.T.)
		EndIf
	EndIf

	// Em 27/04/2015 Denise solicita liberação da restrição da condição de pagamento conforme e-mail enviado:
	/*/
	Bom dia, Jeferson:
	Por solicitação do Gustavo, favor destravar( liberar ) o sistema para cadastramento dos pedidos de vendas sem limitação para condições de pagamento, de tal forma que o comercial consiga cadastrar de acordo como for emitido o Pedido.
	OBS: Precisamos o mais rápido possível, em decorrência de ser a última semana para fechamento do mês.
	Desde já, obrigada.

	ElseIf cCondic == Posicione("SA1",1,xFilial("SA1")+cCliLj,"A1_COND")
	Return(.T.)
	EndIf

	For _nCond := 0 to 9
	_cParam := "MV_X_COND"+Str(_nCond,1)

	DbSelectArea("SX6")
	DbSetOrder(1)

	If !DbSeek(FWCodFil()+_cParam,.F.)
	DbSeek("  "+_cParam,.F.)
	EndIf

	If !SX6->(Eof())
	AADD(_aConds,&(AllTrim(GetMV(_cParam))))
	EndIf
	Next

	// O Array _aConds{Valor de, Valor Até, String com cond.Pagtos Válidas
	_lVolta := .F.
	For nI:= 1 to Len(_aConds)
	If nTotPV >= _aConds[nI,1] .And. nTotPV <= _aConds[nI,2] .And. cCondic $ _aConds[nI,3]
	_lVolta := .T.
	Exit
	EndIf
	Next
	ElseIf cCondic == "569"
	_lVolta := .T.
	EndIf
	If !_lVolta
	If !_lTemFin // Não tem financeiro no TES
	u_autoAlert("Usar Condição de Pagamento 569-Não Cobrar!")
	Else
	u_autoAlert("Condição de Pagamento Inválida")
	EndIf
	EndIf
	Return(_lVolta)
	/*/
	// Fim 27/04/2015
EndIf
Return(.T.)

*
******************************************
User Function ReplSB1(_cProdOri,_cProdDes)
******************************************
*
*
 /*[LEO] - 25/10/16 - Não executar nada quando rotina automatica for uma divisão de pedido (LEO/ROBERTO/JU)*/
 if !U_isDivid()
	// Posiciona o cadastro de produtos
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1") + _cProdOri,.F.)

	// Joga todos os campos do SB1 num Array
	_aDadSB1 := {}
	_nQtdCpos := FCount()
	For _j := 1 to _nQtdCpos
		AAdd(_aDadSB1,FieldGet(_j))
	Next

	// Se não existir o produto, cria.
	If !(DbSeek(xFilial("SB1") + _cProdDes,.F.)) // Se não existe
		cData := Substr(DtoS(Date()),7,2)+Substr(DtoS(Date()),5,2)+Substr(DtoS(Date()),3,2)
		cHora := Substr(Time(),1,2)+Substr(Time(),4,2)
		RecLock("SB1",.T.)
		SB1->B1_FILIAL := xFilial("SB1")
		SB1->B1_COD    := _cProdDes
		SB1->B1_ZZUSERI:= cData+cHora+cUserName
		SB1->B1_XPORTAL := "N"	
		MsUnLock()
	EndIf

	RecLock("SB1",.F.)
	For _j := 1 to _nQtdCpos
		_cNameCpo := AllTrim(FieldName(_j))
		If _cNameCpo # "B1_FILIAL"  .And. _cNameCpo # "B1_COD" .And. _cNameCpo # "B1_ZZUSERI" .And.;
			_cNameCpo # "B1_USERLGI" .And. _cNameCpo # "B1_USERLGA" .And. _cNameCpo # "B1_XPORTAL"
			FieldPut(_j,_aDadSB1[_j])
		EndIf
	Next
	
	MsUnLock()

	DbSelectArea("SG1")
	DbSetOrder(1) // G1_FILIAL+G1_COD+G1_COMP+G1_TRT
	_cQProdNac := Padr("Q"+AllTrim(_cProdOri),TamSX3("B1_COD")[1])
	If DbSeek(xFilial("SG1")+_cProdOri+_cQProdNac,.F.)
		_aDadSG1 := {}
		_nQtdCpos := FCount()
		For _j := 1 to _nQtdCpos
			AAdd(_aDadSG1,FieldGet(_j))
		Next
		If !DbSeek(xFilial("SG1")+_cProdDes+_cQProdNac,.F.)
			RecLock("SG1",.T.)
			SG1->G1_FILIAL := xFilial("SG1")
			SG1->G1_COD    := _cProdDes
			SG1->G1_COMP   := _cQProdNac
		Else
			RecLock("SG1",.F.)
		EndIf

		For _j := 1 to _nQtdCpos
			_cNameCpo := AllTrim(FieldName(_j))
			If _cNameCpo # "G1_FILIAL" .And. _cNameCpo # "G1_COD" .And. _cNameCpo # "G1_COMP"
				FieldPut(_j,_aDadSG1[_j])
			EndIf
		Next
		MsUnLock()
	EndIf
EndIf
Return(.T.)

/*/{Protheus.doc} MT410BRW
@author bolognesi
@since 14/10/2016
@version 1.0
@type function
@description Utilizado para incluir a opção no Browser, para consultar
os numeros dos pedido originados pela divisão do pedido posicionado.
/*/

User Function MT410BRW()
AAdd(aRotina,{"Consult.Divis.","U_checkDiv(SC5->(C5_NUM))",0,3})
AAdd(aRotina,{"Email Espelho.","U_zManEsp(SC5->(C5_NUM))",0,3})
AAdd(aRotina,{"Leiaute Etiqueta","U_cbcfEtiq(xFilial('SC5'),SC5->(C5_NUM))",0,3})
AAdd(aRotina,{"Calc.Imposto","U_PedCalcImp('Pedido', SC5->(Recno()))",0,3})
AAdd(aRotina,{"Trace","U_cbcTraceBck(AllTrim(SC5->(C5_NUM)))",0,3})
Return(Nil)

/*
	[PORTAL][INICIO] - Manutenção do relacionamento entre os documentos do portal e os documentos do sistema
	manter a partir de um documento no portal sua rastreabilidade interna no sistema
*/
static function checkQuotationDocument()

	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local oService  	:= CbcQuotationService():newCbcQuotationService()
	local cBranchId		:= SC5->C5_FILIAL
	local cDocumentId	:= SC5->C5_NUM
	local cQuotationId	:= SC5->C5_DOCPORT
	local cType			:= QUOTATION_DOC_SALES_ORDER
	local cSeries		:= nil
	local cComments		:= "Pedido excluído por " + oUtils:getUserName() + " em "+DtoC(Date())+" às "+Left(Time(), 5)

	if !Empty(cQuotationId)
		oService:setDocumentDeleted(cQuotationId, cType, cBranchId, cDocumentId, cSeries, cComments)
	endIf

return
/*
	[PORTAL][FINAL] - Manutenção do relacionamento entre os documentos do portal e os documentos do sistema
	manter a partir de um documento no portal sua rastreabilidade interna no sistema
*/

/*/{Protheus.doc} HandleEr
@author bolognesi
@since 30/01/2017
@version undefined
@param oErr, object, Objeto contendo o erro
@type function
/*/
Static function HandleEr(oErr)
	local cMsg := ""
	cMsg := '[' + oErr:Description + ']-' + '-[' +  oErr:ERRORSTACK + ']'
	ConOut("[Pedido.Excl-Portal - " + DtoC(Date()) + " - " + Time() + " ] " + cMsg)
	BREAK
return
*
**********************************
User Function VejaDUtil(_dDataEnt)
**********************************
*
Local _dDataEnt := DataValida(_dDataEnt) // Inicio com uma data válida
Local aArea    := GetArea()
Local aAreaSX5 := SX5->(GetArea())

// Verificar se a data está na tabela (SX5)
SX5->(DbSetOrder(1))					//X5_FILIAL, X5_TABELA, X5_CHAVE, R_E_C_N_O_, D_E_L_E_T_
SX5->(DbSeek(xFilial("SX5")+"ZV",.F.))	//Posiciona no primeiro item da tabela ZV

// ATENÇÃO - ESTA TABELA TRATA SOMENTE FERIADOS LOCAIS
//Percorre a tabela ZV procurando por feriados
Do While SX5->X5_FILIAL == xFilial("SX5") .And. SX5->X5_TABELA == "ZV" .And. SX5->(!Eof())
	cDtAux := DtoS(_dDataEnt)
	If cDtAux == Substr(SX5->X5_DESCRI,1,8)
		_dDataEnt++
		_dDataEnt := DataValida(_dDataEnt)
		SX5->(DbSeek(xFilial("SX5")+"ZV",.F.))	//Posiciona no primeiro item da tabela ZV
	EndIf
	SX5->(DbSkip())
EndDo

//Restaura Ponteiros
RestArea(aAreaSX5)
RestArea(aArea)
Return(_dDataEnt)

/*/
C5_ENTRVT
Dt.Entr.VT
Data Entrega (virtual)   - Para controle da digitação da data de entrega real.
/*/
*
***************************************************************************************************************
User Function VejaSZ9(_cToDo,_C6_NUM, _C6_SEMANA, _C6_ITEM, _C6_ACONDIC, _C6_LANCES, _CPROD, _CLOCAL, _dDtEntr)
***************************************************************************************************************
*
Local _C6_NUM, _C6_SEMANA, _C6_ITEM, _C6_ACONDIC, _C6_LANCES, _CPROD, _CLOCAL, _dDtEntr
Local _cToDo // Verificar / Alterar / Excluir
Local aArea    := GetArea()
*
_C6_ACONDIC := Left((AllTrim(_C6_ACONDIC) + Space(Len(SZ9->Z9_LOCALIZ))),Len(SZ9->Z9_LOCALIZ))

If !Empty(_C6_SEMANA) .And. !IsAlpha(Left(_C6_SEMANA,1)) .And. !" " $ _C6_SEMANA
	SZ9->(DbSetOrder(7)) // Z9_FILIAL+Z9_PEDIDO+Z9_ITEMPV

	If !SZ9->(DbSeek(xFilial("SZ9")+_C6_NUM+_C6_ITEM,.F.)) // Não achei o Item
		If AllTrim(_C6_ACONDIC) # "R00100" .And. _cToDo == "A" // Verificar / Alterar / Excluir

			SZ9->(DbSetOrder(1)) // Z9_FILIAL+Z9_SEMANA+Z9_PRODUTO+Z9_LOCAL+Z9_LOCALIZ+Z9_PEDIDO+Z9_ITEMPV
			SZ9->(DbSeek(xFilial("SZ9")+_C6_SEMANA+_CPROD,.F.))
			_Z9NUM     := SZ9->Z9_NUM
			_Z9ITEM    := SZ9->Z9_ITEM
			_Z9SEQUEN  := SZ9->Z9_SEQUEN
			_Z9EMISSAO := SZ9->Z9_EMISSAO


			SZ9->(DbSetOrder(7)) // Z9_FILIAL+Z9_PEDIDO+Z9_ITEMPV
			RecLock("SZ9",.T.)
			SZ9->Z9_FILIAL	:= xFilial("SZ9")
			SZ9->Z9_SEMANA	:= _C6_SEMANA
			SZ9->Z9_PRODUTO := _CPROD
			SZ9->Z9_DESCRI	:= Posicione("SB1",1,xFilial("SB1")+SZ9->Z9_PRODUTO,"B1_DESC")
			SZ9->Z9_LOCAL	:= _CLOCAL
			SZ9->Z9_LOCALIZ	:= _C6_ACONDIC
			SZ9->Z9_ACONDIC	:= Left(_C6_ACONDIC,1)
			SZ9->Z9_METRAGE := Val(Substr(_C6_ACONDIC,2,5))
			SZ9->Z9_PEDIDO  := _C6_NUM
			SZ9->Z9_ITEMPV  := _C6_ITEM
			SZ9->Z9_CODINV  := 	Left(SZ9->Z9_PRODUTO,5)+Substr(SZ9->Z9_PRODUTO,8,3)+Substr(SZ9->Z9_PRODUTO,6,2)
			SZ9->Z9_LANCES	:= _C6_LANCES
			SZ9->Z9_QUANT	:= SZ9->Z9_LANCES*SZ9->Z9_METRAGE
			SZ9->Z9_SALDO	:= SZ9->Z9_QUANT
			SZ9->Z9_ENCERR  := 0
			SZ9->Z9_NUM     := _Z9NUM
			SZ9->Z9_ITEM    := _Z9ITEM
			SZ9->Z9_SEQUEN  := _Z9SEQUEN
			SZ9->Z9_EMISSAO := _Z9EMISSAO
			SZ9->Z9_DTENTR  := _dDtEntr
			MsUnLock()
		EndIf
	ElseIf _cToDo == "E"
		RecLock("SZ9",.F.)
		DbDelete()
		MsUnLock()
	EndIf

	// Procuto de novo
	SZ9->(DbSeek(xFilial("SZ9")+_C6_NUM+_C6_ITEM,.F.))
	Do While SZ9->Z9_FILIAL == xFilial("SZ9") .And. SZ9->Z9_PEDIDO == _C6_NUM .And. SZ9->Z9_ITEMPV == _C6_ITEM .And. SZ9->(!Eof())
		If _C6_SEMANA == SZ9->Z9_SEMANA
			If SZ9->Z9_ETIQIMP > 0 // Foi impressa alguma etiqueta
				If _cToDo == "V"
					u_autoAlert("Alteração não Permitida - Item esta em processo na lista de corte/repasse.")
					u_autoAlert("Solicite ao PCP a liberação.")
					RestArea(aArea)
					Return(.F.)
				EndIf
			ElseIf _cToDo == "A" .And. (SZ9->Z9_PRODUTO # _CPROD .Or. SZ9->Z9_LOCALIZ # _C6_ACONDIC)
				RecLock("SZ9",.F.)
				SZ9->Z9_PRODUTO := _CPROD
				SZ9->Z9_DESCRI	:= Posicione("SB1",1,xFilial("SB1")+SZ9->Z9_PRODUTO,"B1_DESC")
				SZ9->Z9_LOCAL	:= _CLOCAL
				SZ9->Z9_LOCALIZ	:= _C6_ACONDIC
				SZ9->Z9_ACONDIC	:= Left(_C6_ACONDIC,1)
				SZ9->Z9_METRAGE := Val(Substr(_C6_ACONDIC,2,5))
				SZ9->Z9_CODINV  := 	Left(SZ9->Z9_PRODUTO,5)+Substr(SZ9->Z9_PRODUTO,8,3)+Substr(SZ9->Z9_PRODUTO,6,2)
				SZ9->Z9_LANCES	:= _C6_LANCES
				SZ9->Z9_QUANT	:= SZ9->Z9_LANCES*SZ9->Z9_METRAGE
				SZ9->Z9_SALDO	:= SZ9->Z9_QUANT
				SZ9->Z9_ENCERR  := 0
				MsUnLock()
			EndIf
			Exit
		EndIf
		SZ9->(DbSkip())
	EndDo
EndIf
RestArea(aArea)
Return(.T.)
