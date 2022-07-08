#include "TbiCode.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#include "topconn.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDBAL03                            Modulo : SIGAEST      //
//                                                                          //
//   Autor ......: Roberto Oliveira                   Data ..: 26/09/2010   //
//                                                                          //
//   Objetivo ...: Fazer a Pesagem nas balancas, tanto de rolos como de     //
//                 bobinas                                                  //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//   Alteração em 11/04/11 - A pesagem será imediatamente confirmada no esto//
//   que quando finalizada. Somete ficará para posterior confirmação quando //
//   esta estiver fora dos  parâmetros do CQ. Cada um pode confirmar a sua  //
//   pesagem.                                                               //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

/*/{Protheus.doc} CDBAL03R
//TODO Chamada da Pesagem de ROLOS/CARRETEIS/BLISTER.
@author .
@since 30/08/2016
@version undefined

@type function
/*/
*
***********************
User Function CDGEN22()
***********************
*
cCadastro := "Tipos de Bobinas x Clientes"
aRotina := {{ "Pesquisar" ,"AxPesqui"       , 0 , 1},;
			{ "Visualizar","u_IncTpBob('V')", 0 , 2},;
			{ "Incluir"   ,"u_IncTpBob('I')", 0 , 3},;
			{ "Alterar"   ,"u_IncTpBob('A')", 0 , 3},;
			{ "Excluir"   ,"u_IncTpBob('E')", 0 , 3}}  //U_ImprBol1(1) Grafico //U_IMPRBOLET(1) Matricial

DbSelectArea("SZA")
DbSetOrder(1) //ZA_FILIAL+ZA_CLIENTE+ZA_LOJA+ZA_CODIGO
DbSeek(xFilial("SZA"),.F.)

mBrowse(001,040,200,390,"SZA")

Return(.T.)
*
*******************************
User Function IncTpBob(_cForma)
*******************************
*
nOpcE:=3
nOpcG:=3
inclui := (_cForma == "I")
altera := (_cForma == "A")
exclui := (_cForma == "E")

If exclui .And. SZA->ZA_CLIENTE+SZA->ZA_LOJA == AllTrim(GetMv("MV_ORCLIPD"))
	Alert("Exclusão não permitida")
	Return(.F.)
EndIf

aButtons := {}
aAltEnchoice :={}
DbSelectArea("SA1")
SA1->(DbSetOrder(1))
DbSelectArea("SZA")
SZA->(DbSetOrder(1))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
SX3->(DbSetOrder(1))
DbSeek("SZA")
aHeader:={}
Do While !Eof().And.(sx3->x3_arquivo=="SZA")
	If X3USO(sx3->x3_usado) .And. cNivel>=sx3->x3_nivel .And. !(AllTrim(sx3->x3_campo) $ "ZA_FILIAL//ZA_CLIENTE//ZA_LOJA//ZA_NOMCLI//") .And. SX3->X3_BROWSE # "N"
		_cValid := AllTrim(sx3->x3_valid)
		If !Empty(sx3->x3_vlduser) .And. !Empty(_cValid)
			_cValid += " .and. "
		EndIf
		_cValid += AllTrim(sx3->x3_vlduser)

		If AllTrim(sx3->x3_campo) ==  "ZA_FATOR"
			If !Empty(_cValid)
				_cValid += " .and. "
			EndIf
			_cValid += "u_VejaFat()"
		EndIf
 		nUsado:=nUsado+1
		Aadd(aHeader,{ TRIM(sx3->x3_titulo), sx3->x3_campo, sx3->x3_picture,;
		sx3->x3_tamanho, sx3->x3_decimal,_cValid,;
		sx3->x3_usado, sx3->x3_tipo, sx3->x3_arquivo, sx3->x3_context } )
	Endif
	DbSkip()
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executa a Modelo 3                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Inclui
	cTitulo        := "Tipos de Bobinas X Clientes - Incluir"
ElseIf altera
	cTitulo        := "Tipos de Bobinas X Clientes - Alterar"
ElseIf exclui
	cTitulo        := "Tipos de Bobinas X Clientes - Excluir"
Else
	cTitulo        := "Tipos de Bobinas X Clientes - Visualizar"
EndIf

cAliasEnchoice := ""
cAliasGetD     := "SZA"
cLinOk         := "AllwaysTrue()"
cTudOk         := "AllwaysTrue()"
cFieldOk       := "AllwaysTrue()"
aCpoEnchoice   := {}
_lRet:= .T.

If Inclui
	_ZACLIENTE:= CriaVar("ZA_CLIENTE")
	_ZALOJA   := CriaVar("ZA_LOJA")
	_ZANOMCLI := Space(TamSX3("ZA_NOMCLI")[1])
	_cCliBase := Left(GetMv("MV_ORCLIPD"),(TamSX3("A1_COD")[1]))
	_cLojBase := Substring(GetMv("MV_ORCLIPD"),(TamSX3("A1_COD")[1]+1),TamSX3("A1_LOJA")[1])
Else
	_ZACLIENTE:= SZA->ZA_CLIENTE
	_ZALOJA   := SZA->ZA_LOJA
	_ZANOMCLI := Posicione("SA1",1,xFilial("SA1")+_ZACLIENTE+_ZALOJA,"A1_NOME")
	_cCliBase := SZA->ZA_CLIENTE
	_cLojBase := SZA->ZA_LOJA
EndIf

aCols:={}
DbSelectarea("SZA")
DbSetOrder(1)
DbSeek(xFilial("SZA")+_cCliBase+_cLojBase,.F.)
Do While SZA->ZA_FILIAL == xFilial("SZA") .And. SZA->ZA_CLIENTE == _cCliBase .And. SZA->ZA_LOJA == _cLojBase .And. SZA->(!Eof())
	aAdd(aCols,Array(nUsado+1))
	For _ni:=1 to nUsado
		If ( aHeader[_ni,10] # "V" )
			aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
		Else
			aCols[Len(aCols),_ni] := CriaVar(aHeader[_ni,2])
		EndIf
	Next
	aCols[Len(aCols),nUsado+1]:=.F.
	SZA->(DbSkip())
EndDo

_lRet:=u_JanbalZA(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,)
If _lRet .And. (inclui .Or. altera .Or. exclui)
	DbSelectArea("SZA")
	DbSetOrder(1) // ZA_FILIAL+ZA_CLIENTE+ZA_LOJA+ZA_CODIGO
	For _nVez := 1 to Len(aCols)
		_lGrava := .T.
		If SZA->(DbSeek(xFilial("SZA")+_ZACLIENTE+_ZALOJA+GDFieldGet("ZA_CODIGO",_nVez),.F.))
			RecLock("SZA",.F.)
		ElseIf !exclui
			RecLock("SZA",.T.)
		Else
			_lGrava := .F.
		EndIf
		If _lGrava
			If exclui .Or. GDDeleted(_nVez)
				DbDelete()
			Else
				For nY := 1 To Len(aHeader)
					SZA->&(aHeader[nY,2]) := aCols[_nVez,nY]
				Next
				SZA->ZA_FILIAL  := xFilial("SZA")
				SZA->ZA_CLIENTE := _ZACLIENTE
				SZA->ZA_LOJA    := _ZALOJA
			EndIf
			MsUnLock()
		EndIf
	Next
EndIf
Return(.T.)
*
*
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
User Function JanbalZA(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze)
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Local lRet, nOpca := 0,cSaveMenuh,nReg:=0
Local aSize 		:= {}
Local aPosObj 		:= {}
Local aObjects 		:= {}
Local aInfo 		:= {}

aSize := MsAdvSize()
aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
aAdd( aObjects, { 100, 100, .t., .t. } )
aAdd( aObjects, { 100, 100, .t., .t. } )
aAdd( aObjects, { 100, 015, .t., .f. } )
aPosObj := MsObjSize( aInfo, aObjects )
aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,265}} )

nGetLin := aPosObj[3,1]

Private oDlg,oGetDados
Private lRefresh:=.T.,aTELA:=Array(0,0),aGets:=Array(0),;
bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

nOpcE    := If(nOpcE==Nil,2,nOpcE)
nOpcG    := If(nOpcG==Nil,2,nOpcG)
lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
nLinhas  := Iif(nLinhas==Nil,999,nLinhas)

_nSize5 := aSize[5]
_nSize6 := aSize[6]
_nSize7 := aSize[7]
_n95    := 95
_n200 := 200
_nPosObj2 := aPosObj[2,2]
_nPosObj4 := aPosObj[2,4]
DEFINE MSDIALOG oDlg TITLE cTitulo From _nSize7,0 to _nSize6,_nSize5 of oMainWnd PIXEL

@ 040,005 Say "Cliente :"																			   	   		Size  40,10
@ 040,060 Get _ZACLIENTE	Picture PesqPict("SZA","ZA_CLIENTE")	Valid u_VldCli()   When Inclui  F3 "SA1"	Size  40,10
@ 055,005 Say "Loja :"																				   	  		Size  40,10
@ 055,060 Get _ZALOJA		Picture PesqPict("SZA","ZA_LOJA")		Valid u_VldCli()	When Inclui 			Size  40,10
@ 070,005 Say "Nome do Cliente :"                                           						   			Size  40,10
@ 070,060 Get _ZANOMCLI		Picture PesqPict("SZA","ZA_NOMCLI")					When .F.			   			Size  200,10
   
oGetDados := MsGetDados():New(_n95,_nPosObj2,_n200,_nPosObj4,nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,Len(aCols),cFieldOk)
//oGetDados:oBrowse:bChange := {|| U_Refbal03()}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons) CENTERED

lRet:=(nOpca==1)

Return(lRet)
*
**********************
User Function VldCli()
**********************
*
SZA->(DbSetOrder(1))
If SZA->(DbSeek(xFilial("SZA")+_ZACLIENTE+_ZALOJA,.F.))
	Alert("Já Informado Dados para Esse Cliente -> Use Alteração.")
	Return(.F.)
EndIf
SA1->(DbSetOrder(1))
If !SA1->(DbSeek(xFilial("SA1")+_ZACLIENTE+AllTrim(_ZALOJA),.F.))
	Alert("Cliente não Cadastrado.")
	Return(.F.)
EndIf
_ZANOMCLI := SA1->A1_NOME
Return(.T.)
*
***********************
User Function VejaFat()
***********************
*
// O Fator não pode ser menor que o anterior nem maior que o posterior
If M->ZA_FATOR <= 0
	Alert("Informe um Fator válido")
	Return(.F.)
EndIf
_nFatAnt := 0
_nFatPos := 999999999
_aCols := aClone(aCols)


If Len(aCols) > 1
	If n > 1
		_nFatAnt := GDFieldGet("ZA_FATOR",n-1)
	EndIf
	If n < Len(aCols)
		_nFatPos := GDFieldGet("ZA_FATOR",n+1)
	EndIf
EndIf
If !(M->ZA_FATOR < _nFatPos .And. M->ZA_FATOR > _nFatAnt)
	If n == 1
		Alert("O fator dever ser maior que o fator anterior.")
	ElseIf n == Len(aCols)
		Alert("O fator dever ser menor que o posterior.")
	Else
		Alert("O fator dever ser maior que o fator anterior e menor que o posterior.")
	EndIf
	Return(.F.)
EndIf
Return(.T.)