#include "protheus.ch"
#include "rwmake.ch"
#include "TOPCONN.ch"
#INCLUDE 'tbiconn.ch'

/*
/////////////////////////////////////////////////////////////////////////////////
//                                                                             //
//   Programa ...: CDPCP03                            Modulo : SIGAEST/PCP     //
//                                                                             //
//   Autor ......: Roberto Oliveira                   Data ..: 26/02/2016      //
//                                                                             //
//   Objetivo ...: Solicitar nro.PV e permitir a alteração da data de en-      //
//                 trega efetuando o cálculo (Dt.Lib.Cred. + C5_DIASNEG uteis) //
//                 permitindo ainda a sua alteração.                           //
//   Uso ........: Especifico da Cobrecom                                      //
//                                                                             //
/////////////////////////////////////////////////////////////////////////////////
*/
***********************
User Function CDPCP03()
***********************
*
Private _C5_NUM
Private _A1_NOME
Private _C5_EMISSAO
Private _C5_DATALIB
Private _C5_DTLICRE
Private _C5_ENTREG
Private _C5_DIASNEG
Private _C5_DTENTR
Private _C5DTENTR // Usado para comparação se a data for diferente

nOpcE:=3
nOpcG:=3
inclui := .F.
altera := .F.
exclui := .F.
aButtons := {}
//AAdd(aButtons, { "BALANCA" ,{|| u_SomeAcols()}, "Captura Peso"} )

aAltEnchoice :={}

DbSelectArea("SA1")
SA1->(DbSetOrder(1))

DbSelectArea("SC5")
SC5->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a Modelo 3                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cTitulo        := "Confirmação Data Negociada"
_lRet:= .T.

Do While _lRet
	_lRet:=.F.
	M->_C5_NUM     := PadR("      ",TamSX3("C5_NUM")[1])
	M->_A1_NOME    := Space(TamSX3("A1_NOME")[1])
	M->_C5_EMISSAO := Ctod("  /  /  ")
	M->_C5_DATALIB := Ctod("  /  /  ")
	M->_C5_DTLICRE := Ctod("  /  /  ")
	M->_C5_ENTREG  := Ctod("  /  /  ")
	M->_C5_DIASNEG := 0
	M->_C5_DTENTR  := Ctod("  /  /  ")
	M->_C5DTENTR   := Ctod("  /  /  ") // Usado para comparação se a data for diferente
	
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000, 000  TO 380, 430 PIXEL
	@ 020, 015 SAY "Nro. Pedido   :" SIZE 40,15
	@ 020, 060 Get _C5_NUM           Valid BuscaPv() F3 "SC5ZZI" SIZE 40,15
	
	@ 037, 015 SAY "Nome Cliente  :" SIZE 40,15
	@ 037, 060 Get _A1_NOME          When .F. Object _O_A1_NOME SIZE 150,15
	
	@ 054, 015 SAY "Dt. Emissão   :" SIZE 40,15
	@ 054, 060 Get _C5_EMISSAO       When .F. Object _O_C5_EMISSAO SIZE 40,15
	
	@ 071, 015 SAY "Dt.Lib.Vendas :" SIZE 40,15
	@ 071, 060 Get _C5_DATALIB       When .F. Object _O_C5_DATALIB SIZE 40,15
	
	@ 088, 015 SAY "Dt.Lib.Credito:" SIZE 40,15
	@ 088, 060 Get _C5_DTLICRE       When .F. Object _O_C5_DTLICRE SIZE 40,15
	
	@ 105, 015 SAY "Dt.Entrega    :" SIZE 40,15
	@ 105, 060 Get _C5_ENTREG        When .F. Object _O_C5_ENTREG SIZE 40,15
	
	@ 122, 015 SAY "Prz.Cliente   :" SIZE 40,15
	@ 122, 060 Get _C5_DIASNEG       Picture "@E 9,999" Object _O_C5_DIASNEG When .F. SIZE 40,15
	
	@ 139, 015 SAY "Dt.Negociada  :" SIZE 40,15
	@ 139, 060 Get _C5_DTENTR        When !Empty(M->_C5_NUM) Valid u_VldDtEntr() Object _O_C5_DTENTR SIZE 40,15
	
	@ 165, 110 BUTTON oSButton1 PROMPT "Confirmar" Size 37,10 OF oDlg ACTION {|| (If(Confirm(),oDlg:End(),_lRet:=.T.))} PIXEL // OK
	@ 165, 160 BUTTON oSButton2 PROMPT "Cancelar" Size 37,10 OF oDlg ACTION {|| oDlg:End() } PIXEL // CANCEL
	
	ACTIVATE MSDIALOG oDlg CENTERED
	_nmay := .T.
EndDo
Return(.T.)
*
*************************
User Function VldDtEntr()
*************************
*  
Local _cMsg, _lVolta := .T.
If _C5_DTENTR < Date()
	_lVolta := .F.
elseif empty(_C5_DTENTR)
	_lVolta := .F.
elseif !U_zGetDtVl(_C5_DTENTR)[1]
	_lVolta := .F.
	u_autoAlert('[ERRO] - Data informada não é uma data valida !' )
ElseIf M->_C5DTENTR # M->_C5_DTENTR // Usado para comparação se a data for diferente
	_cMsg := "Data de entrega alterada. " + Chr(13) + Chr(13) + ;
			 "   Data Sugerida : " + Dtoc(M->_C5DTENTR) + Chr(13) + ;
			 "   Data Informada: " + Dtoc(M->_C5_DTENTR) + Chr(13) + Chr(13) + ;
			 "Confirma a alteração para " +Dtoc(M->_C5_DTENTR) + " ?"
	_lVolta := u_autoAlert(_cMsg,.T.,'MsgBox','Confirma?',,'YesNo',.T.)
EndIf
If !_lVolta
	M->_C5_DTENTR := M->_C5DTENTR
EndIf
_O_A1_NOME:Refresh()
_O_C5_EMISSAO:Refresh()
_O_C5_DATALIB:Refresh()
_O_C5_DTLICRE:Refresh()
_O_C5_ENTREG:Refresh()
_O_C5_DIASNEG:Refresh()
_O_C5_DTENTR:Refresh()
Return(_lVolta)	
*
*************************
Static Function Confirm()
*************************
*
If Empty(M->_C5_NUM)
	Return(.F.)
EndIf
_cPedInd := ""
_MyNumEmp  := cNumEmp
_MycFilAnt := cFilAnt
_cEmpNow   := SM0->M0_CODIGO

Do While .T.
	DbSelectArea("SC5")
	DbSetOrder(1)
	If DbSeek(xFilial("SC5")+M->_C5_NUM,.F.)
		If (SC5->C5_ENTREG # M->_C5_DTENTR) .or. Empty(SC5->C5_DTENTR)
			// Gravar o log de Alteração do SC5
			_aDadC5 := {SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI,M->_C5_ENTREG,SC5->C5_TIPO}
			u_CDGEN21I(17,,,,_aDadC5)
			          
			If SC5->C5_DTFAT > M->_C5_DTENTR
				// Gravar o log de Alteração do SC5
				_aDadC5 := {SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_DTFAT,SC5->C5_TIPO}
				u_CDGEN21I(18,,,,_aDadC5)
			EndIf
			
			// Alterar dados do Pedido
			RecLock("SC5",.F.)
			SC5->C5_DTENTR := SC5->C5_ENTREG // Primeiro trocar o SC5->C5_DTENTR para constar a data de entrega anterior
			SC5->C5_ENTREG := M->_C5_DTENTR
			If SC5->C5_DTFAT > M->_C5_DTENTR
				SC5->C5_DTFAT  := M->_C5_DTENTR
			EndIf
			MsUnLock()
			
			// Alterar a data de entrega nos ítens do pedido
			DbSelectArea("SC6")
			DbSetOrder(1)
			DbSeek(xFilial("SC6") + M->_C5_NUM,.F.)
			Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == M->_C5_NUM .And. SC6->(!Eof())
				RecLock("SC6",.F.)
				SC6->C6_ENTREG := M->_C5_DTENTR
				MsUnLock()
				If !Empty(SC6->C6_ZZPVORI) .And. !(Left(SC6->C6_ZZPVORI,TamSX3("C5_NUM")[1]) $ _cPedInd) .And.;
					_MyNumEmp == cNumEmp // Somente para a mesma filial
					
					_cPedInd += Left(SC6->C6_ZZPVORI,TamSX3("C5_NUM")[1])
				EndIf
				SC6->(DbSkip())
			EndDo
			Alert("Alteração do Pedido " + M->_C5_NUM + " efetuada com Sucesso!")
		EndIf
	EndIf
	// Se for pedido de insdustrialização, efetuar a mesma alteração para o outro pedido.
	If Len(_cPedInd) > 0
		SM0->(DbSeek(_cEmpNow+If(cFilAnt == "01","02","01"),.F.))
		cNumEmp := FWCodEmp()+FWCodFil()
		cFilAnt := FWCodFil()
		M->_C5_NUM := Left(_cPedInd,TamSX3("C5_NUM")[1])
		If Len(_cPedInd) == TamSX3("C5_NUM")[1]
			_cPedInd := ""
		EndIF
	Else
		Exit
	EndIf
EndDo
If cNumEmp # _cEmpNow
	cNumEmp := _cEmpNow
	cFilAnt := _cFilNow
	SM0->(DbSeek(cNumEmp,.F.))
EndIf
_lRet:=.T.
Return(.T.)
*
*************************
Static Function BuscaPv()
*************************
*
Local _nCtt

If Empty(M->_C5_NUM)
	Return(.T.)
EndIf

DbSelectArea("SC5")
DbSetOrder(1)
If !(DbSeek(xFilial("SC5")+M->_C5_NUM,.F.))
	Alert("Pedido não Localizado")
	Return(.F.)
ElseIf !Empty(Alltrim(SC5->C5_NOTA))
	Alert("Pedido já Finalizado")
	Return(.F.)
ElseIf SC5->C5_TIPO # "N"
	Alert("Tipo de Pedido Inválido")
	Return(.F.)
ElseIf Empty(SC5->C5_DTLICRE)
	Alert("Pedido não Liberado o Crédito")
	Return(.F.)
ElseIf SoIndl(_C5_NUM)
	Alert("Pedido Solicitado Industrialização")
	Return(.F.)
ElseIf SC5->C5_DIASNEG == 0
	If !MsgBox("Pedido não Tem Prazo Negociado","Negocia Entrega?","YesNo")
		Return(.F.)
	EndIf
ElseIf !(Empty(SC5->C5_DTENTR))
	Alert("Pedido já teve o Prazo Negociado!")
	Return(.F.)
EndIf
aDados := u_InfTrian(xFilial("SC5"),M->_C5_NUM,"CDPCP03")
If Len(aDados) > 0
	M->_A1_NOME    := aDados[1,2]
Else
	M->_A1_NOME    := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME")
EndIf
M->_C5_EMISSAO := SC5->C5_EMISSAO
M->_C5_DATALIB := SC5->C5_DATALIB
M->_C5_DTLICRE := SC5->C5_DTLICRE
M->_C5_ENTREG  := SC5->C5_ENTREG
M->_C5_DIASNEG := SC5->C5_DIASNEG
M->_C5_DTENTR  := SC5->C5_DTENTR

If SC5->C5_DIASNEG == 0
	//Assumo a data de entrega
	M->_C5_DTENTR := SC5->C5_ENTREG
ElseIf Empty(SC5->C5_DTENTR) // Calcular a data de entrega
	M->_C5_DTENTR := CalcNeg(M->_C5_DIASNEG,.T.)
EndIf
M->_C5DTENTR := M->_C5_DTENTR // Assume a data calculada -> Usado para comparação se a data for diferente

// Dar Refresh nas variáveis
_O_A1_NOME:Refresh()
_O_C5_EMISSAO:Refresh()
_O_C5_DATALIB:Refresh()
_O_C5_DTLICRE:Refresh()
_O_C5_ENTREG:Refresh()
_O_C5_DIASNEG:Refresh()
_O_C5_DTENTR:Refresh()
Return(.T.)
*
***********************************************
Static Function CalcNeg(_C5_DIASNEG,_lDtRetBse)
***********************************************
*
Local _C5_DIASNEG
Local _C5_DTENTR
Local _lDtReal

Default _lDtRetBse := .T.
// Indica se a data calculada for menor que a data base, retorna a data base.

// Calcular "n" dias úteis da data de liberação de crédito
_C5_DTENTR := SC5->C5_DTLICRE
For _nCtt := 1 to _C5_DIASNEG
	_C5_DTENTR := DataValida(++_C5_DTENTR)
Next
_C5_DTENTR := u_DataIFC(SC5->C5_DTLICRE,_C5_DTENTR)	//Verifica existência de feriados locais que não constam na tabela padrão do Protheus

If _lDtRetBse
	_C5_DTENTR := Max(_C5_DTENTR,Date())
EndIf
Return(_C5_DTENTR)
*
**************************
User Function CDPCP03SCH()
**************************
*
// Rotina para envio de e-mail para Vitor, Crispilho, Daniela e Juliana
// informando os pedidos com prazo negociado e ainda não confirmado pelo PCP

// 14/04/2016 - Roberto Oliveria - Programa alterado para enviar e-mail também
// dos pedidos que foram negociados e

If Select("SX2") == 0
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"
EndIf

DbSelectArea("SA1")
DbSetOrder(1)

DbSelectArea("SC5")
DbSetOrder(1)

DbSelectArea("SC6")
DbSetOrder(1)

cQuery := " SELECT C5_FILIAL, C5_NUM"
cQuery += " FROM "+RetSqlName("SC5")
cQuery += " WHERE C5_DIASNEG > 0"
cQuery += " AND C5_TIPO = 'N' AND C5_NOTA = ''"
//cQuery += " AND C5_DTENTR = '' AND C5_TIPO = 'N' AND C5_NOTA = ''"
cQuery += " AND C5_DTLICRE <> '' AND C5_LIBEROK <> 'E'"
cQuery += " AND D_E_L_E_T_ = ''"
cQuery += " ORDER BY C5_FILIAL, C5_NUM"
cQuery := ChangeQuery(cQuery)

If Select("TRB")>0
	DbSelectArea("TRB")
	DbCloseArea()
EndIf
TCQUERY cQuery NEW ALIAS "TRB"

DbSelectArea("TRB")
DbGotop()
//Center Left Right
_aLado := {} // Informar a posição de cada item do acab
Aadd(_aLado,"Left",)
Aadd(_aLado,"Left",)
Aadd(_aLado,"Left",)
Aadd(_aLado,"Left",)
Aadd(_aLado,"Left",)
Aadd(_aLado,"Right")
Aadd(_aLado,"Right")
Aadd(_aLado,"Right")
Aadd(_aLado,"Right")
Aadd(_aLado,"Right")
Aadd(_aLado,"Right")

_aCab   := {}
Aadd(_aCab,"Filial",)
Aadd(_aCab,"Num.Pedido")
Aadd(_aCab,"Cod.Cliente")
Aadd(_aCab,"Loja")
Aadd(_aCab,"Nome do Cliente")
Aadd(_aCab,"Dt.Emissão")
Aadd(_aCab,"D.Lib.Cred.")
Aadd(_aCab,"Dias Negoc.")
Aadd(_aCab,"Dt.Entr.Neg.")
Aadd(_aCab,"Dt.Entr. à Confirmar")
Aadd(_aCab,"Vlr.Total")
_aDet01 := {}
_aDet02 := {}

_aCab_1   := {}
Aadd(_aCab_1,"Filial")
Aadd(_aCab_1,"Num.Pedido")
Aadd(_aCab_1,"Cod.Cliente")
Aadd(_aCab_1,"Loja")
Aadd(_aCab_1,"Nome do Cliente")
Aadd(_aCab_1,"Dt.Emissão")
Aadd(_aCab_1,"D.Lib.Cred.")
Aadd(_aCab_1,"Dias Negoc.")
Aadd(_aCab_1,"Dt.Entr.Neg.")
Aadd(_aCab_1,"Dt.Entr. Confirmada")
Aadd(_aCab_1,"Vlr.Total")
_aDet01_1 := {}
_aDet02_1 := {}

_MyNumEmp := FWCodEmp()+FWCodFil()
_MycFilAnt := FWCodFil()

Do While !TRB->(Eof())
	_cEmpNow := SM0->M0_CODIGO
	_cFilNow := TRB->C5_FILIAL
	SM0->(DbSeek(_cEmpNow+_cFilNow,.F.))
	cNumEmp := FWCodEmp()+FWCodFil()
	cFilAnt := FWCodFil()
	
	Do While TRB->C5_FILIAL == _cFilNow .And. !TRB->(Eof())
		If !SoIndl(TRB->C5_NUM)
			SC5->(DbSetOrder(1))
			SC5->(DbSeek(xFilial("SC5")+TRB->C5_NUM,.F.))
			aDados := u_InfTrian(xFilial("SC5"),TRB->C5_NUM,"CDPCP03SCH")
			If Len(aDados) >  0
				_cNmCli := aDados[1,2]
			Else
				_cNmCli := Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME")
			EndIf
			
			If Empty(SC5->C5_DTENTR) // Ainda não confirmada a data negociada
				If cFilAnt=="01"
					Aadd(_aDet01,{"Itu",;
					SC5->C5_NUM,;
					SC5->C5_CLIENTE,;
					SC5->C5_LOJACLI,;
					_cNmCli,;
					Transform(SC5->C5_EMISSAO,"@E"),;
					Transform(SC5->C5_DTLICRE,"@E"),;
					Transform(SC5->C5_DIASNEG,"@E 999"),;
					Transform(CalcNeg(SC5->C5_DIASNEG,.T.),"@E"),;
					Transform(SC5->C5_ENTREG,"@E"),;
					Transform(SC5->C5_TOTAL,"@E 999,999.99");
					})
				Else
					Aadd(_aDet02,{"3 Lagoas",;
					SC5->C5_NUM,;
					SC5->C5_CLIENTE,;
					SC5->C5_LOJACLI,;
					_cNmCli,;
					Transform(SC5->C5_EMISSAO,"@E"),;
					Transform(SC5->C5_DTLICRE,"@E"),;
					Transform(SC5->C5_DIASNEG,"@E 999"),;
					Transform(CalcNeg(SC5->C5_DIASNEG,.T.),"@E"),;
					Transform(SC5->C5_ENTREG,"@E"),;
					Transform(SC5->C5_TOTAL,"@E 999,999.99");
					})
				EndIf
			Else
				
				If cFilAnt=="01"
					Aadd(_aDet01_1,{"Itu",;
					SC5->C5_NUM,;
					SC5->C5_CLIENTE,;
					SC5->C5_LOJACLI,;
					_cNmCli,;
					Transform(SC5->C5_EMISSAO,"@E"),;
					Transform(SC5->C5_DTLICRE,"@E"),;
					Transform(SC5->C5_DIASNEG,"@E 999"),;
					Transform(CalcNeg(SC5->C5_DIASNEG,.F.),"@E"),;
					Transform(SC5->C5_ENTREG,"@E"),;
					Transform(SC5->C5_TOTAL,"@E 999,999.99");
					})
				Else
					Aadd(_aDet02_1,{"3 Lagoas",;
					SC5->C5_NUM,;
					SC5->C5_CLIENTE,;
					SC5->C5_LOJACLI,;
					_cNmCli,;
					Transform(SC5->C5_EMISSAO,"@E"),;
					Transform(SC5->C5_DTLICRE,"@E"),;
					Transform(SC5->C5_DIASNEG,"@E 999"),;
					Transform(CalcNeg(SC5->C5_DIASNEG,.F.),"@E"),;
					Transform(SC5->C5_ENTREG,"@E"),;
					Transform(SC5->C5_TOTAL,"@E 999,999.99");
					})
				EndIf
			EndIf
		EndIf
		TRB->(DbSkip())
	EndDo
EndDo

// Volta para a filial correta
cNumEmp := _MyNumEmp
cFilAnt := _MycFilAnt
DbSelectArea("SM0")
DbSetOrder(1)
SM0->(DbSeek(cNumEmp,.F.))

If Select("TRB")>0
	DbSelectArea("TRB")
	DbCloseArea()
EndIf

If Len(_aDet01) > 0
	
	//envMail(aTo,cSubject,aHead,aContent,lAuto,_aLado)
	
	u_envMail({"prazosaconfirmaritu@cobrecom.com.br"},;
	"Prazos de Negociações à Confirmar",;
	_aCab,;
	_aDet01,,;
	_aLado)
EndIf
If Len(_aDet02) > 0
	u_envMail({"prazosaconfirmartl@cobrecom.com.br"},;
	"Prazos de Negociações à Confirmar",;
	_aCab,;
	_aDet02,,;
	_aLado)
EndIf
If Len(_aDet01_1) > 0
	u_envMail({"prazosaconfirmadositu@cobrecom.com.br"},;
	"Prazos de Negociações Confirmados",;
	_aCab_1,;
	_aDet01_1,,;
	_aLado)
EndIf
If Len(_aDet02_1) > 0
	u_envMail({"prazosaconfirmadostl@cobrecom.com.br"},;
	"Prazos de Negociações Confirmados",;
	_aCab_1,;
	_aDet02_1,,;
	_aLado)
EndIf
Return(.T.)
*
*******************************
Static Function SoIndl(_C5_NUM)
*******************************
*
Local lSoIndl := .T.
Local _C5_NUM
DbSelectArea("SC6")
DbSetOrder(1)
DbSeek(xFilial("SC6")+_C5_NUM,.F.)
Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == _C5_NUM .And. SC6->(!Eof())
	If SC6->C6_LOCAL # "10"
		lSoIndl := .F.
		Exit
	EndIf
	SC6->(DbSkip())
EndDo
Return(lSoIndl)
