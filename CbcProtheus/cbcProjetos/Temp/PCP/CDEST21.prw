#include "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDEST21                            Modulo : SIGAEST      //
//                                                                          //
//   Autor ......: Roberto Oliveira                   Data ..: 26/02/2010   //
//                                                                          //
//   Objetivo ...: Controle de Reservas                                     //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
*
***********************
User Function CDEST21()
***********************
*
//Primeiro cancelo reservas
cPerg := "CDEST21"
ValidPerg()

cUserNm := Left(AllTrim(UsrRetName(oApp:cUserId)) + Space(15),15)

u_CDESTRES()

aCores    := {{"ZE_STATUS $ 'IL'"  ,"BR_PINK"},;
{"ZE_STATUS == 'C'"  ,"BR_BRANCO"},;
{"ZE_STATUS $ 'VW'"  ,"BR_AMARELO"},; // W -reserva por vendas
{"ZE_STATUS == 'N'"  ,"DISABLE"},;
{"ZE_STATUS $  'RP'" ,"BR_CINZA"},;
{"ZE_STATUS == 'E'"  ,"BR_LARANJA"},;
{"ZE_STATUS $  'FD'" ,"BR_AZUL" },;
{"ZE_STATUS == 'X'"  ,"BR_PRETO" },;
{"ZE_STATUS == 'T'"  ,"ENABLE"}}

aRotina := {{ "Pesquisar"   , "AxPesqui"       , 0 , 1	},;
{ "Reservar"    , "U_CDES21A(.T.)" , 0 , 4	},;
{ "Conf.Reserva", "U_CDES21B"      , 0 , 4	},;
{ "Canc.Reserva", "U_CDES21A(.F.)" , 0 , 4	},;
{ "Legenda"     , "U_CDES21X"      , 0 , 2 }}

aCampos := {}

aAdd(aCampos, {"Nro.Bobina"  ,"ZE_NUMBOB"})
aAdd(aCampos, {"Produto"     ,"ZE_PRODUTO"})
aAdd(aCampos, {"Descrição"   ,"ZE_DESCPRO"})
aAdd(aCampos, {"Quant."      ,"ZE_QUANT"})
aAdd(aCampos, {"Responsavel" ,"ZE_RESP"})
aAdd(aCampos, {"Dt.Res."     ,"ZE_DTRES"})
aAdd(aCampos, {"Cód.Cliente" ,"ZE_CLIRES"})
aAdd(aCampos, {"Loja"        ,"ZE_LJRES"})
aAdd(aCampos, {"Mome Cliente","ZE_NOMRES"})

cCadastro := "Reservas de Bobinas"
DbSelectArea("SZE")
DbSetOrder(1)
Set Filter to ZE_STATUS $ "TVN"  // esToque/reserVada/reserva coNfirmada
DbSeek(xFilial("SZE"),.F.)

mBrowse(001,040,200,390,"SZE",aCampos,,,,,aCores)
DbSelectArea("SZE")
Set Filter to
Return(.T.)
*
*******************************
User Function CDES21A(_lReser)
*******************************
*
If SZE->ZE_DTRES+1 < Date() .And. SZE->ZE_STATUS == "V" // Expirou a data da reserva e a reserva é provisória
	RecLock("SZE",.F.)
	SZE->ZE_DTRES  := Ctod("//")
	SZE->ZE_STATUS := "T"
	SZE->ZE_RESP   := Space(Len(SZE->ZE_RESP))
	SZE->ZE_CLIRES := Space(Len(SZE->ZE_CLIRES))
	SZE->ZE_LJRES  := Space(Len(ZE_LJRES))
	MsUnLock()
EndIf
If _lReser // é uma reserva nova?
	If SZE->ZE_STATUS # "T" //  Status é # de  EM ESTOQUE
		Alert("Bobina não Disponivel para Reserva")
	Else
		_cLocaliz := Left("B"+StrZero(SZE->ZE_QUANT,5)+Space(Len(SBF->BF_LOCALIZ)),Len(SBF->BF_LOCALIZ))
		SBF->(DbSetOrder(1))  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		SBF->(DbSeek(xFilial("SBF")+"01"+_cLocaliz+SZE->ZE_PRODUTO,.F.))
		If SBF->BF_EMPENHO < 0
			Alert("Erro no Saldo do Empenho - Contate Administrador")
		ElseIf SBF->(Eof()) .Or. (SBF->BF_QUANT - SBF->BF_EMPENHO) < SZE->ZE_QUANT
			Alert("Não há Saldo Disponível para Reserva dessa Bobina, Contate a Expedição")
		ElseIf RecLock("SZE",.F.)
			//			Do While .T.
			_lPerg := Pergunte(cPerg,.T.)
			//				If _lPerg .And. (Empty(MV_PAR01) .Or. Empty(MV_PAR02))
			//					Alert("Informar Corretamente os Parâmetros")
			//				ElseIf _lPerg
			If _lPerg
				SZE->ZE_DTRES  := Date()
				SZE->ZE_STATUS := "V" // Bobina reservada para posterior confirmação ou candelamento da reserva
				SZE->ZE_RESP   := cUserNm
				SZE->ZE_CLIRES := MV_PAR01
				SZE->ZE_LJRES  := MV_PAR02
				//					Exit
				//				Else
				//					Exit
			EndIf
			//			EndDo
			MsUnLock()
		Else
			Alert("Os Dados dessa Bobina Estão em Uso em Outra Rotina")
		EndIf
	EndIf
ElseIf SZE->ZE_STATUS $ "VN" // é um cancelamento de reserva
	
		// Primeiro Indisponibilizo a Bobina
		DbSelectArea("SZE")
		RecLock("SZE",.F.)
		
		// Depois deleto SZR
		// Deletar SZR se existir
		
		DbSelectArea("SZR")
		SZR->(DbSetOrder(1)) // ZR_FILIAL+ZR_NUMBOB
		DbSeek(xFilial("SZR")+SZE->ZE_NUMBOB,.F.)
		
	If AllTrim(SZE->ZE_RESP) == SubStr(AllTrim(cUserName), 1, TamSx3('ZE_RESP')[1]) .Or. AllTrim(SZR->ZR_RESP) == SubStr(AllTrim(cUserName), 1, TamSx3('ZR_RESP')[1]) .Or. AllTrim(cUserNm) == "ROBERTO" .Or. Upper(AllTrim(cUserNm)) == "JULIANA.LEME"
		Do While SZR->ZR_FILIAL == xFilial("SZR") .And. SZR->ZR_NUMBOB == SZE->ZE_NUMBOB .And. SZR->(!Eof())
			DbSelectArea("SC6")
			DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			If DbSeek(xFilial("SC6") + SZR->ZR_PEDIDO + SZR->ZR_ITEMPV,.F.)
				If AllTrim(SC6->C6_SEMANA) $ "RESERVA//ZP4"
					RecLock("SC6",.F.)
					SC6->C6_SEMANA := "       "
					SC6->C6_QTDRES := 0
					MsUnLock()
				EndIf
			EndIf
			RecLock("SZR",.F.)
			DbDelete()
			MsUnLock()
			SZR->(DbSkip())
		EndDo
		
		// E por fim eu libero a bobina
		// Volta o status da bobina para em estoque
		
		DbSelectArea("SZE")
		SZE->ZE_DTRES  := Ctod("//")
		SZE->ZE_STATUS := "T"
		SZE->ZE_RESP   := Space(Len(SZE->ZE_RESP))
		SZE->ZE_CLIRES := Space(Len(SZE->ZE_CLIRES))
		SZE->ZE_LJRES  := Space(Len(ZE_LJRES))
		MsUnLock()
	Else
		Alert("Bobina Reservada para " + AllTrim(SZR->ZR_RESP) + '/' + AllTrim(SZE->ZE_RESP))
	EndIf
EndIf
Return(.T.)
*
*
//////////////////////////
User Function CDES21X()
//////////////////////////
*
BrwLegenda(cCadastro,"Legenda",{{"DISABLE"   ,"Com Reserva Definitiva"},;
{"BR_AMARELO","Com Reserva"},;
{"BR_PINK"   ,"Importada ou Laboratório"},;
{"BR_BRANCO" ,"Cancelada"},;
{"BR_CINZA","Recebida ou A Liberar"},;
{"BR_LARANJA","Empenhada"},;
{"BR_AZUL"   ,"Faturada ou Adiantada"},;
{"BR_PRETO"  ,"Expedida"},;
{"ENABLE"    ,"Estoque Disponível"}})
Return(.T.)
*
************************
User Function CDESTRES()
************************
*
Processa({|| AvalRes()},"Verificando Reservas de Bobinas")
Return(.T.)
*
*************************
Static Function AvalRes()
*************************
*
DbSelectArea("SZE")
ProcRegua(LastRec())
DbSetOrder(3) // ZE_FILIAL+ZE_STATUS+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
DbSeek(xFilial("SZE")+"V",.F.) // Somente bobinas reservadas
Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_STATUS == "V" .And. SZE->(!Eof())
	IncProc()
	If SZE->ZE_DTRES+1 < Date() // Expirou a data da reserva e a reserva é provisória
		_nAtuReg := SZE->(Recno()) // Pego o proximo registro pois o campo status é chave de indice e eu vou trocar para "T"
		
		SZE->(DbSkip())
		_nPrxReg := SZE->(Recno()) // Pego o proximo registro pois o campo status é chave de indice e eu vou trocar para "T"
		
		SZE->(DbGoTo(_nAtuReg))
		RecLock("SZE",.F.)
		SZE->ZE_DTRES  := Ctod("//")
		SZE->ZE_STATUS := "T"
		SZE->ZE_RESP   := Space(Len(SZE->ZE_RESP))
		MsUnLock()
		SZE->(DbGoTo(_nPrxReg))
	Else
		SZE->(DbSkip())
	EndIf
EndDo
Return(.T.)
*
************************
User Function CDES21B()
************************
*
*
If SZE->ZE_DTRES+1 < Date() .And. SZE->ZE_STATUS == "V" // Expirou a data da reserva e a reserva é provisória
	RecLock("SZE",.F.)
	SZE->ZE_DTRES  := Ctod("//")
	SZE->ZE_STATUS := "T"
	SZE->ZE_RESP   := Space(Len(SZE->ZE_RESP))
	MsUnLock()
EndIf
If (SZE->ZE_STATUS == "V" .And. SZE->ZE_RESP # cUserNm)
	Alert("Bobina Reservada para " + AllTrim(SZE->ZE_RESP))
	Return(.F.)
ElseIf SZE->ZE_STATUS == "N"
	Alert("Bobina com Reserva Confirmada")
	Return(.F.)
EndIf

DbSelectArea("SA1")
DbSetOrder(1)

DbSelectArea("SB1")
DbSetOrder(1)

DbSelectArea("SZE")
DbSetOrder(1)

DbSelectArea("SC5")
DbSetOrder(1)

DbSelectArea("SC6")
DbSetOrder(1)

DbSelectArea("SZR")
DbSetOrder(1)

nOpcE:=3
nOpcG:=3
inclui := .T.
altera := .F.
exclui := .F.

aAltEnchoice :={}

_ZR_NUMBOB  := SZE->ZE_NUMBOB
_QtdBob     := SZE->ZE_QUANT
_ZR_PRODUTO := SZE->ZE_PRODUTO
_ZR_DESCR   := SZE->ZE_DESCPRO
_ZR_PEDIDO  := Space(Len(SC5->C5_NUM))
_ZR_CODCLI  := Space(Len(SA1->A1_COD))
_ZR_LOJA    := Space(Len(SA1->A1_LOJA))
_ZR_NOMCLI  := Space(Len(SA1->A1_NOME))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
DbSetOrder(2)
aHeader:={}
For _nx := 1 to 6
	nUsado:=nUsado+1
	Aadd(aHeader,{" "," "," ",0,0," "," "," "," "," "} )
	If _nx == 1
		aHeader[_nx,1] := "Item PV"
		aHeader[_nx,2] := "ZR_ITEMPV"
	ElseIf _nx == 2
		aHeader[_nx,1] := "Quant.P.V."
		aHeader[_nx,2] := "ZR_QTDPV"
	ElseIf _nx == 3
		aHeader[_nx,1] := "Acondic."
		aHeader[_nx,2] := "ZR_ACONDIC"
	ElseIf _nx == 4
		aHeader[_nx,1] := "Qtd.Lances"
		aHeader[_nx,2] := "ZR_LANCES"
	ElseIf _nx == 5
		aHeader[_nx,1] := "Tam.do Lance"
		aHeader[_nx,2] := "ZR_METRAGE"
	ElseIf _nx == 6
		aHeader[_nx,1] := "Observação"
		aHeader[_nx,2] := "ZR_OBS"
	EndIf
	DbSeek(aHeader[_nx,2],.F.)
	If _nx == 1  // item PV
		aHeader[_nx,06] := "u_ACheItem()"
	ElseIf _nx == 6 // observaÇÃo
		aHeader[_nx,06] := SX3->X3_VALID
	Else
		aHeader[_nx,06] := ".F." //SX3->X3_VLDUSER // "AllwaysTrue()"
	EndIf
	aHeader[_nx,03] := SX3->X3_PICTURE
	aHeader[_nx,04] := SX3->X3_TAMANHO
	aHeader[_nx,05] := SX3->X3_DECIMAL
	aHeader[_nx,07] := SX3->X3_USADO
	aHeader[_nx,08] := SX3->X3_TIPO
	aHeader[_nx,09] := SX3->X3_ARQUIVO
	aHeader[_nx,10] := SX3->X3_CONTEXT
Next

aCols:={Array(nUsado+1)}
For _ni:=1 to nUsado
	aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
Next
aCols[1,nUsado+1]:=.F.

_lRet:= .F.
aButtons := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a Modelo 3                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo        := "Confirmação de Reserva de Materiais"
cAliasEnchoice := ""
cAliasGetD     := "SZR"
cLinOk         := "AllwaysTrue()"
cTudOk         := "u_ValideTd" // "AllwaysTrue()"
cFieldOk       := "AllwaysTrue()"
aCpoEnchoice   := {}

_lRet:=u_JanESt01(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,)
If _lRet
	_lTemRes := .F.
	For _n := 1 to Len(acols)
		If !GDDeleted(_n)
			DbSelectArea("SC6")
			DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			If DbSeek(xFilial("SC6") + _ZR_PEDIDO + GDFieldGet("ZR_ITEMPV" ,_n),.F.)
				If Empty(SC6->C6_SEMANA)
					If RecLock("SC6",.F.)
						SC6->C6_SEMANA := "RESERVA"
						SC6->C6_QTDRES := SC6->C6_QTDVEN
						MsUnLock()
						_lTemRes := .T.
						DbSelectArea("SZR")
						RecLock("SZR",.T.)
						SZR->ZR_FILIAL  := xFilial("SZR")
						SZR->ZR_NUMBOB  := _ZR_NUMBOB
						SZR->ZR_TAMBOB  := _QtdBob
						SZR->ZR_DATA    := dDataBase
						SZR->ZR_PRODUTO := _ZR_PRODUTO
						SZR->ZR_DESCR   := _ZR_DESCR
						SZR->ZR_PEDIDO  := _ZR_PEDIDO
						SZR->ZR_ITEMPV  := GDFieldGet("ZR_ITEMPV" ,_n)
						SZR->ZR_CODCLI  := _ZR_CODCLI
						SZR->ZR_LOJA    := _ZR_LOJA
						SZR->ZR_NOMCLI  := _ZR_NOMCLI
						SZR->ZR_QTDPV   := GDFieldGet("ZR_QTDPV"  ,_n)
						SZR->ZR_ACONDIC := GDFieldGet("ZR_ACONDIC",_n)
						SZR->ZR_LANCES  := GDFieldGet("ZR_LANCES" ,_n)
						SZR->ZR_METRAGE := GDFieldGet("ZR_METRAGE",_n)
						SZR->ZR_RESP    := cUserNm
						SZR->ZR_OBS     := GDFieldGet("ZR_OBS",_n)
						//SZR->ZR_NUMBMM   := // QUANDO ESSE CARA FOR <> DE VAZIO, JÁ FOI PARA RETRABALHO
						MsUnLock()
					EndIf
				Else
					If AllTrim(SC6->C6_SEMANA) $ "RESERVA//ZP4"
						Alert("Item "+SC6->C6_ITEM+" já tem Reserva")
					Else
						Alert("Item "+SC6->C6_ITEM+" já Programado na Produção")
					EndIf
				EndIf
			EndIf
		EndIf
	Next
	DbSelectArea("SZE")
	If _lTemRes
		RecLock("SZE",.F.)
		SZE->ZE_STATUS := "N" // Reserva confirmada
		SZE->ZE_CLIRES := _ZR_CODCLI
		SZE->ZE_LJRES  := _ZR_LOJA
		//I=Import..;C=Canc.;R=Recebida;P=A Liberar;E=Empenh.;F=Faturada;T=Estoque;
		//A=Adiantada;X=Expedida;D=Devolv.;V=Reserv.;N=Res.Conf.
		MsUnLock()
	EndIf
EndIf
Return(.T.)
*
*
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function JanEst01(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Local lRet, nOpca := 0,cSaveMenuh,nReg:=0
Local aSize := {}
Local aPosObj := {}
Local aObjects := {}
Local aInfo := {}

aSize := MsAdvSize()
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aAdd( aObjects, { 100, 100, .t., .t. } )
aAdd( aObjects, { 100, 100, .t., .t. } )
aAdd( aObjects, { 100, 015, .t., .f. } )
aPosObj := MsObjSize( aInfo, aObjects )
aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,265}} )
//                                            {15,2,40,355}  45,2,190,355
nGetLin := aPosObj[3,1]

Private oDlg,oGetDados
Private lRefresh:=.T.,aTELA:=Array(0,0),aGets:=Array(0),;
bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

nOpcE    := If(nOpcE==Nil,2,nOpcE)
nOpcG    := If(nOpcG==Nil,2,nOpcG)
lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
nLinhas  := Iif(nLinhas==Nil,999,nLinhas)

DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL

@ 015,005 Say "Nro.Bobina.:"                                    Size  40,10
@ 015,055 GET _ZR_NUMBOB                               When .F. Size  40,10
@ 015,130 Say "Quantidade(m).:"                                 Size  40,10
@ 015,180 GET _QtdBob      Picture "@E 999,999"        When .F. Size  40,10
@ 030,005 Say "Produto.:"                                       Size  40,10
@ 030,055 GET _ZR_PRODUTO  Picture "@R 999.99.99.9.99" When .F. Size  60,10
@ 030,130 Say "Descrição.:"                                     Size  40,10
@ 030,180 GET _ZR_DESCR                                When .F. Size 250,10
@ 045,005 Say "Nro.Pedido.:"                                    Size  40,10
@ 045,055 GET _ZR_PEDIDO             Valid u_TemPed() F3 "SC5"  Size  40,10
@ 045,130 Say "Cliente.:"                                       Size  40,10
@ 045,180 GET _ZR_CODCLI                               When .F. Size  40,10 Object _O_ZR_CODCLI
@ 045,230 Say "Loja.:"                                          Size  40,10
@ 045,250 GET _ZR_LOJA                                 When .F. Size  40,10 Object _O_ZR_LOJA
@ 045,305 Say "Nome Cliente.:"                                  Size  40,10
@ 045,345 GET _ZR_NOMCLI                               When .F. Size 150,10 Object _O_ZR_NOMCLI

oGetDados := MsGetDados():New(60,aPosObj[2,2],280,aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,nLinhas,cFieldOk)
oGetDados:oBrowse:bChange := {|| U_RefESt01()}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons) CENTERED

lRet:=(nOpca==1)
Return(lRet)
*
**********************
User Function RefEst01()
**********************
*
_O_ZR_CODCLI:Refresh()
_O_ZR_LOJA:Refresh()
_O_ZR_NOMCLI:Refresh()
Return(.T.)
*
**********************
User Function TemPed()
**********************
*
/*/
// Falei com Felipe 16/04/14...
// Permitir usar pedido ainda com bloqueio de crédito

DbSelectArea("SC9")
DbSetOrder(1)  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
DbSeek(xFilial("SC9")+_ZR_PEDIDO,.F.)

Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == _ZR_PEDIDO .And. SC9->(!Eof())
	If Empty(SC9->C9_BLCRED)
		Exit
	EndIf
	SC9->(DbSkip())
EndDo
If SC9->C9_FILIAL # xFilial("SC9") .Or. SC9->C9_PEDIDO # _ZR_PEDIDO .Or. SC9->(Eof()) .Or. !Empty(SC9->C9_BLCRED)
	Alert("Pedido não Liberado ou Bloqueado pelo Crédito")
	Return(.F.)
EndIf
/*/
DbSelectARea("SC5")
DbSetOrder(1)
If !DbSeek(xFilial("SC5")+_ZR_PEDIDO,.F.)
	Alert("Pedido não Cadastrado")
	Return(.F.)
EndIf

_ZR_PEDANT := _ZR_PEDIDO

SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
_ZR_CODCLI  := SA1->A1_COD
_ZR_LOJA    := SA1->A1_LOJA
_ZR_NOMCLI  := SA1->A1_NOME
_O_ZR_CODCLI:Refresh()
_O_ZR_LOJA:Refresh()
_O_ZR_NOMCLI:Refresh()
If _ZR_PEDIDO # _ZR_PEDANT // SE escolheu outro pedido.... zera o acols
	aCols:={Array(nUsado+1)}
	For _ni:=1 to nUsado
		aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
	Next
	aCols[1,nUsado+1]:=.F.
EndIf
Return(.T.)
*
************************
User Function ACheItem()
************************
*
If GDDeleted(n)
	Alert("Linhas Deletadas não Serão Consideradas")
	Return(.F.)
EndIf

_lVolta := .T.

//Verifico se esse item já foi incluido em nesta reserva
_nQtdRes := 0.00
For _n := 1 to Len(acols)
	If _n # n
		If !GDDeleted(_n)
			If M->ZR_ITEMPV == GDFieldGet("ZR_ITEMPV",_n)
				_lVolta := .F.
				Exit
			Else
				_nQtdRes += (GDFieldGet("ZR_LANCES",_n)*GDFieldGet("ZR_METRAGE",_n))
			EndIf
		EndIf
	EndIf
Next
If !_lVolta
	Alert("Item Já Incluido")
	Return(.F.)
EndIf

// Verifico se já tenho outra reserva para este ítem
DbSelectArea("SZR")
DbSetOrder(2) //ZR_FILIAL+ZR_PEDIDO+ZR_ITEMPV
If DbSeek(xFilial("SZR")+ _ZR_PEDIDO + GDFieldGet("ZR_ITEMPV",n),.F.)
	Alert("Já Efetuado Reserva de Bobina para este Pedido/Item")
	Return(.F.)
EndIf

// Localizo o item no pedido de venda - SC6
_lVolta := .F.
DbSelectArea("SC6")
DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
DbSeek(xFilial("SC6") + _ZR_PEDIDO + M->ZR_ITEMPV,.F.)

// O TES desse Item movimenta estoque???
DbSelectAreA("SF4")
DbSetOrder(1)
DbSeek(xFilial("SF4")+SC6->C6_TES,.F.)
If SF4->F4_ESTOQUE == "N"
	Alert("TES Inválido -> Sem Movimentação de Estoque")
	Return(.F.)
EndIf

// Soma a quantidade que já está liberada
DbSelectArea("SC9")
DbSetOrder(1)  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
DbSeek(xFilial("SC9")+_ZR_PEDIDO + GDFieldGet("ZR_ITEMPV",n),.F.)
_nTotLib := 0
Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == _ZR_PEDIDO .And. SC9->C9_ITEM == GDFieldGet("ZR_ITEMPV",n) .And. SC9->(!Eof())
	If Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLEST) // jÁ TEM ALGO LIBERADO
		_nTotLib += SC9->C9_QTDLIB
	EndIf
	SC9->(DbSkip())
EndDo
//_SldLcSC6 := Int((SC6->C6_QTDVEN-SC6->C6_QTDENT-_nTotLib) / SC6->C6_METRAGE)
_SldLcSC6 := (SC6->C6_QTDVEN-SC6->C6_QTDENT-_nTotLib)
If SC6->(Eof())
	Alert("Item não Localizado")
ElseIf SC6->C6_PRODUTO # _ZR_PRODUTO
	Alert("Produto Diferente do Produto do tem do Pedido")
ElseIf !Empty(SC6->C6_BLQ)
	Alert("Item com Resíduo Eliminado")
ElseIf _SldLcSC6 <= 0
	Alert("Quantidade do Item já Entregue")
ElseIf  Alltrim(SC6->C6_SEMANA) $ "RESERVA//ZP4"
	Alert("Já Consta Reserva para este Item")
ElseIf !Empty(SC6->C6_SEMANA)
	Alert("Item já Programado na Produção")
ElseIf (_nQtdRes+_SldLcSC6) > _QtdBob
	Alert("Quantidade dos Itens dos Pedidos é Maior que a Quantidade da Bobina")
Else
	_cLocaliz := Left("B"+StrZero(SZE->ZE_QUANT,5)+Space(Len(SBF->BF_LOCALIZ)),Len(SBF->BF_LOCALIZ))
	DbSelectArea("SBF")
	DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	DbSeek(xFilial("SBF")+"01"+_cLocaliz+SZE->ZE_PRODUTO,.F.)
	If SBF->(EOF()) .Or. (SBF->BF_QUANT - SBF->BF_EMPENHO) < SZE->ZE_QUANT
		Alert("Não há Saldo Disponível para Reserva dessa Bobina, Contate a Expedição")
	ElseIf SBF->BF_EMPENHO < 0
		Alert("Erro no Empenho - Contate Administrador")
	Else
		GDFieldPut("ZR_QTDPV"  ,_SldLcSC6,N)
		GDFieldPut("ZR_ACONDIC",SC6->C6_ACONDIC,N)
		GDFieldPut("ZR_LANCES" ,(_SldLcSC6/SC6->C6_METRAGE),N)
		GDFieldPut("ZR_METRAGE",SC6->C6_METRAGE,N)
		_lVolta := .T.
	EndIf
EndIf
Return(_lVolta)
*
*************************
Static Function ValidPerg
*************************
*
_aArea := GetArea()

DbSelectArea("SX1")
DbSetOrder(1)
cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

aRegs:={}
//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Cód.Cliente                  ?","mv_ch1","C",6,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Loja                         ?","mv_ch2","C",2,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","",""})

For i := 1 To Len(aRegs)
	If !DbSeek(cPerg+aRegs[i,2])
		RecLock("SX1",.T.)
		SX1->X1_GRUPO   := aRegs[i,01]
		SX1->X1_ORDEM   := aRegs[i,02]
		SX1->X1_PERGUNT := aRegs[i,03]
		SX1->X1_VARIAVL := aRegs[i,04]
		SX1->X1_TIPO    := aRegs[i,05]
		SX1->X1_TAMANHO := aRegs[i,06]
		SX1->X1_DECIMAL := aRegs[i,07]
		SX1->X1_PRESEL  := aRegs[i,08]
		SX1->X1_GSC     := aRegs[i,09]
		SX1->X1_VALID   := aRegs[i,10]
		SX1->X1_VAR01   := aRegs[i,11]
		SX1->X1_DEF01   := aRegs[i,12]
		SX1->X1_CNT01   := aRegs[i,13]
		SX1->X1_VAR02   := aRegs[i,14]
		SX1->X1_DEF02   := aRegs[i,15]
		SX1->X1_CNT02   := aRegs[i,16]
		SX1->X1_VAR03   := aRegs[i,17]
		SX1->X1_DEF03   := aRegs[i,18]
		SX1->X1_CNT03   := aRegs[i,19]
		SX1->X1_VAR04   := aRegs[i,20]
		SX1->X1_DEF04   := aRegs[i,21]
		SX1->X1_CNT04   := aRegs[i,22]
		SX1->X1_VAR05   := aRegs[i,23]
		SX1->X1_DEF05   := aRegs[i,24]
		SX1->X1_CNT05   := aRegs[i,25]
		SX1->X1_F3      := aRegs[i,26]
		MsUnlock()
		DbCommit()
	Endif
Next

RestArea(_aArea)

Return(.T.)
*
************************
User Function ValideTd()
************************
*
// Verificar
_nQtdRes := 0.00
For _n := 1 to Len(acols)
	If !GDDeleted(_n)
		_nQtdRes += (GDFieldGet("ZR_LANCES",_n)*GDFieldGet("ZR_METRAGE",_n))
	EndIf
Next
If _nQtdRes # _QtdBob
	Alert("A reserva somente é permitida para a quantidade total da bobina")
	Return(.F.)
EndIf
Return(.T.)

//User Function MATA010()
//Alert("oi")
//Return(.T.)
