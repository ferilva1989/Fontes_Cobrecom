#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#include "protheus.ch"
//#INCLUDE "TOTVS.CH"
//#include "tbiconn.ch"


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: ACD_PEDVOL                       Modulo : SIGAEST        //
//                                                                          //
//                                                  Data ..: 04/04/2017     //
//                                                                          //
//   Objetivo ...: Manutenção da tabela ZZR Log.das Ordens de Separação.    //
//                 para aglutinar O.S. em um mesmo ID para separação  e     //
//                 para montagem dos volumes.                               //
//                                                                          //
//                 Só é permitida esta aglutinação de Ordens de Separação   //
//                 que ainda não tenham montado nenhum volume.              //
//                                                                          //
//   Uso ........: Especifico da Cobrecom                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
*
**************************
User Function ACD_PEDVOL()   // u_ACD_PEDVOL()
**************************
*

cCadastro := "Aglutinação de O.S. para Volumes"

aCores    := {{"!Empty(ZZR_ID)","DISABLE"   },;
			  {"Empty(ZZR_ID)","ENABLE"   }}

aRotina := {{ "Pesquisar"   , "AxPesqui"      , 0 , 1	},;
			{ "Incluir"     , "u_MontaID('I')", 0 , 3	},;
			{ "Visualizar"  , "u_MontaID('V')", 0 , 2	},;
			{ "Imprimir"    , "u_ImprID()"    , 0 , 2	},;
		    { "Legenda"     , "u_IDLEG()"     , 0 , 2  }}

//		{ "Excluir"     , "u_MontaID('E')", 0 , 4	},;

DbSelectArea("ZZR")
DbSetOrder(1) 
DbSeek(xFilial("ZZR"),.F.)

mBrowse(001,040,200,390,"ZZR",,,,,,aCores)
Return(.T.)
*
*********************
User Function IDLEG() // ok
*********************
*
BrwLegenda(cCadastro,"Legenda",{{"DISABLE"    ,"O.S. Já Aglutinada"},;
								{"ENABLE"     ,"O.S. a Aglutinar"}})
Return(.T.)
*
*****************************
User Function MontaID(_cRot)
*****************************
*     
Private aHeader := {}
Private _nCARRE := 0
Private _nB1 := 0.00
Private _nB2 := 0.00
Private _nB3 := 0.00
Private _nB4 := 0.00
Private _nB5 := 0.00
Private _nB6 := 0.00
Private _nB7 := 0.00
Private _nCAIXA := 0
Private _nROLOS := 0
Private _nPLIQ := 0.00
Private _nPBRUT := 0.00
Private _ZZRID := ZZR->ZZR_ID
aAltEnchoice :={}

_ZZRArea := GetArea()
If _cRot == "V" // VISUALIZAR ou EXCLUIR
	If Empty(ZZR->ZZR_ID)
		Alert("Posicione em Uma ID Válido")
		Return(.F.)
	EndIf
EndIf

/*/
If _cRot == "E" // EXCLUIR
	If ZZR->ZZR_SITUAC == "3"
		Alert("Carregamento já Efetuado")
		Return(.F.)
	ElseIf ZZR->ZZR_SITUAC == "4"
		Alert("Carregamento Já Expedido")
		Return(.F.)
	EndIf
EndIf
/*/

DbSelectArea("SX3")
DbSetOrder(2) // X3_CAMPO

nOpcE:=2
nOpcG:=2
aHeader:={}
aAdd(aHeader,{"Sel"         ,"MARC"      ,"X"           , 1,0,"u_VejaChv()",,"C",," "})
DbSeek("C5_NUM",.F.)
aAdd(aHeader,{"Nro Pedido"  ,"NUMPV"     ,SX3->X3_PICTURE, SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
DbSeek("C9_SEQOS",.F.)
aAdd(aHeader,{"Seq."        ,"SEQUEN"    ,SX3->X3_PICTURE, SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
DbSeek("C5_CLIENTE",.F.)
aAdd(aHeader,{"Cliente"     ,"CLIENTE"   ,SX3->X3_PICTURE, SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
DbSeek("C5_LOJACLI",.F.)
aAdd(aHeader,{"Loja"        ,"LOJA"      ,SX3->X3_PICTURE, SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
DbSeek("A1_NOME",.F.)
aAdd(aHeader,{"Nome Cliente","NOMECLI"   ,SX3->X3_PICTURE, SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
DbSeek("A1_MUN",.F.)
aAdd(aHeader,{"Cidade"      ,"CIDADE"    ,SX3->X3_PICTURE, SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
aAdd(aHeader,{"Carretéis"   ,"CARRE"     ,"@E 9,999"    , 4,0,.F.,,"N",," "})
aAdd(aHeader,{"Bob.B1"      ,"B1"        ,"@E 9,999"    , 4,0,.F.,,"N",," "})
aAdd(aHeader,{"Bob.B2"      ,"B2"        ,"@E 9,999"    , 4,0,.F.,,"N",," "})
aAdd(aHeader,{"Bob.B3"      ,"B3"        ,"@E 9,999"    , 4,0,.F.,,"N",," "})
aAdd(aHeader,{"Bob.B4"      ,"B4"        ,"@E 9,999"    , 4,0,.F.,,"N",," "})
aAdd(aHeader,{"Bob.B5"      ,"B5"        ,"@E 9,999"    , 4,0,.F.,,"N",," "})
aAdd(aHeader,{"Bob.B6"      ,"B6"        ,"@E 9,999"    , 4,0,.F.,,"N",," "})
aAdd(aHeader,{"Bob.B7"      ,"B7"        ,"@E 9,999"    , 4,0,.F.,,"N",," "})
aAdd(aHeader,{"Caixas"      ,"CAIXA"     ,"@E 99,999"   , 5,0,.F.,,"N",," "})
aAdd(aHeader,{"Rolos"       ,"ROLOS"     ,"@E 99,999"   , 5,0,.F.,,"N",," "})
aAdd(aHeader,{"Peso Liq."   ,"PLIQ"      ,"@E 99,999.99", 8,2,.F.,,"N",," "})
aAdd(aHeader,{"Peso Bruto"  ,"PBRUT"     ,"@E 99,999.99", 8,2,.F.,,"N",," "})
DbSeek("C5_TIPO",.F.)
aAdd(aHeader,{"Tipo"  ,"_C5TIPO"   ,SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
DbSeek("C5_REAJUST",.F.)
aAdd(aHeader,{"Reaj."  ,"_C5REAJUST",SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
DbSeek("C5_CONDPAG",.F.)
aAdd(aHeader,{"Cond.Pg."  ,"_C5CONDPAG",SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
DbSeek("C5_VEND1",.F.)
aAdd(aHeader,{"Vend.1"  ,"_C5VEND1"  ,SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
DbSeek("C5_VEND2",.F.)
aAdd(aHeader,{"Vend.2"  ,"_C5VEND2"  ,SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
DbSeek("C5_VEND3",.F.)
aAdd(aHeader,{"Vend.3"  ,"_C5VEND3"  ,SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
DbSeek("C5_VEND4",.F.)
aAdd(aHeader,{"Vend.4"  ,"_C5VEND4"  ,SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
DbSeek("C5_VEND5",.F.)
aAdd(aHeader,{"Vend.5"  ,"_C5VEND5"  ,SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
DbSeek("C5_CLIENT",.F.)
aAdd(aHeader,{"Cli.Ent."  ,"_C5CLIENT" ,SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
DbSeek("C5_LOJAENT",.F.)
aAdd(aHeader,{"Loja Ent."  ,"_C5LOJAENT",SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})

If _cRot == "I" //INCLUIR
	_aAlter := {"MARC"}
Else 
	_aAlter := {}
EndIf
nUsado:=Len(aHeader)

aCols    := {}
_MyaCols := {}

Processa( {|| CriaAcolId(_cRot)},"Carregando Dados...")

If Len(aCols) == 0
	RestArea(_ZZRArea)
	Alert("Não existem Pedidos Para Aglutinas O.S.")
	Return(.T.)
EndIf

DbSelectArea("ZZR")

_lRet:= .F.
aButtons := {}
cAliasEnchoice := ""
cAliasGetD     := "ZZR"

If _cRot == "V" //VISUALIZAR
	cTitulo        := "Aglutinação de O.S - Visualizar"
	cLinOk         := "AllwaysTrue()"
	cFieldOk       := "AllwaysTrue()"
ElseIf _cRot == "I" //INCLUIR
	cTitulo        := "Aglutinação de O.S - Incluir"
	cLinOk         := "u_VlLinId()" 
	cFieldOk       := "U_RefrId()" //"AllwaysTrue()"
ElseIf _cRot == "E" //EXCLUIR
	cTitulo        := "Aglutinação de O.S - Excluir"
	cLinOk         := "AllwaysTrue()"
	cFieldOk       := "AllwaysTrue()"
EndIf
cTudOk         := "AllwaysTrue()"
aCpoEnchoice   := {}
_lRet:=u_JanCrgId(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,,_cRot)

If _lRet .And. _cRot # "V" //VISUALIZAR
	// Antes de perguntar, verifico se tem alguma linha não deletada
	If MsgYesNo("Confirma a " + If(_cRot=="E","Exclusão","Aglutinação") + " do ID ?")
		GraveId(_cRot) // Incluindo ou Excluindo
	EndIf
EndIf
DbSelectArea("ZZR")
DbSetOrder(1)
Return(.T.)
*
**********************************************************************************************************************************
User Function JanCrgId(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze,_cRot)
**********************************************************************************************************************************
*
Local aArea    := GetArea()
Local aAreaC5
Local aAreaX3
Local lRet, nOpca := 0,cSaveMenuh,nReg:=0
Local aSize      := {}
Local aPosObj    := {}
Local aObjects 	 := {}
Local aInfo 	 := {}
Local oCombo     := Nil
Local aCbTpLib   := {}
Local aCbStatus  := {}
Local nPosTpLib  := 0
Local nPosStatus := 0
Local cbSX3TpLib := ""
Local cbSX3Stat  := ""

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
Private Altera:=.T.,Inclui:=.F.,lRefresh:=.T.,aTELA:=Array(0,0),aGets:=Array(0),;
bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0

nOpcE    := If(nOpcE==Nil,2,nOpcE)
nOpcG    := If(nOpcG==Nil,2,nOpcG)
lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
nLinhas  := Iif(nLinhas==Nil,99,nLinhas)

DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
nLiGet := 5                  

If _cRot # "I" //INCLUIR
	@ nLiGet,005 Say "I.D.:" Size 40,10
	@ nLiGet,040 Get _ZZRID Picture "XXXXXX" When .F. Size 40,10
EndIf

nLiGet+=15
@ nLiGet,005 Say "Totais:" Size 40,10
nLiGet+=10
@ nLiGet,005 Say "Qtd.Carretéis:" Size 40,10
@ nLiGet,040 Get _nCARRE Picture "@E 9,999" Object _oCARRE When .F. Size 40,10
@ nLiGet,085 Say "Qtd.Bob.B1:" Size 40,10
@ nLiGet,120 Get _nB1 Picture "@E 999" Object _oB1 When .F. Size 40,10
@ nLiGet,165 Say "Qtd.Bob.B2:" Size 40,10
@ nLiGet,200 Get _nB2 Picture "@E 999" Object _oB2 When .F. Size 40,10
@ nLiGet,250 Say "Qtd.Bob.B3:" Size 40,10
@ nLiGet,285 Get _nB3 Picture "@E 999" Object _oB3 When .F. Size 40,10
@ nLiGet,330 Say "Qtd.Bob.B4:" Size 40,10
@ nLiGet,365 Get _nB4 Picture "@E 999" Object _oB4 When .F. Size 40,10

nLiGet+=15
@ nLiGet,005 Say "Qtd.Bob.B5:" Size 40,10
@ nLiGet,040 Get _nB5 Picture "@E 999" Object _oB5 When .F. Size 40,10
@ nLiGet,085 Say "Qtd.Bob.B6:" Size 40,10
@ nLiGet,120 Get _nB6 Picture "@E 999" Object _oB6 When .F. Size 40,10
@ nLiGet,165 Say "Qtd.Bob.B7:" Size 40,10
@ nLiGet,200 Get _nB7 Picture "@E 999" Object _oB7 When .F. Size 40,10
@ nLiGet,250 Say "Qtd.Caixas:" Size 40,10
@ nLiGet,285 Get _nCAIXA Picture "@E 99,999" Object _oCAIXA When .F. Size 40,10
@ nLiGet,330 Say "Qtd.Rolos:" Size 40,10
@ nLiGet,365 Get _nROLOS Picture "@E 99,999" Object _oROLOS When .F. Size 40,10

nLiGet+=15
@ nLiGet,005 Say "Peso Liquido:" Size 40,10
@ nLiGet,040 Get _nPLIQ Picture "@E 99,999.99" Object _oPLIQ When .F. Size 40,10
@ nLiGet,085 Say "Peso Bruto:" Size 40,10
@ nLiGet,120 Get _nPBRUT Picture "@E 99,999.99" Object _oPBRUT When .F. Size 40,10

//@ nLiGet,165 Say 
//@ nLiGet,200 Get 
//@ nLiGet,250 Say 
//@ nLiGet,285 Get 

oGetDados := MsNewGetDados():New(nLiGet+20, aPosObj[2,2], 310, aPosObj[2,4], GD_INSERT+GD_DELETE+GD_UPDATE, cLinOk, cTudoOk,;
             "",_aAlter,0,Len(aCols),"AllwaysTrue","","AllwaysTrue", oDlg, @aHeader, @aCols)
oGetDados:oBrowse:bChange := {|| U_RefoBrow()}

If _cRot # "I" //INCLUIR
	u_VlLinId()
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,;
                               oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons) CENTERED
lRet:=(nOpca==1)
Return(lRet)
*
***********************
User Function VlLinId()
***********************
*                     
_nCARRE := 0
_nB1 := 0
_nB2 := 0
_nB3 := 0
_nB4 := 0
_nB5 := 0
_nB6 := 0
_nB7 := 0
_nCAIXA := 0
_nROLOS := 0
_nPLIQ := 0
_nPBRUT := 0
For _ni := 1 To Len(aCols) 
	If GDDeleted(_ni)        
		aCols[_ni,nUsado+1] := .F. // Tira a deleção
		// GDFieldPut("MARC"," ",_ni)  // aAdd(aHeader,{"Sel"         ,"MARC"   ,"X"           , 1,0,"Pertence('X| ')",,"C",," "})
		aCols[_ni,1] :=  " "
	EndIf

	_MyaCols[_ni,1] := GDFieldGet("MARC",_ni)

	If GDFieldGet("MARC",_ni) == "X"
		_nCARRE  += GDFieldGet("CARRE",_ni)
		_nB1     += GDFieldGet("B1",_ni)
		_nB2     += GDFieldGet("B2",_ni)
		_nB3     += GDFieldGet("B3",_ni)
		_nB4     += GDFieldGet("B4",_ni)
		_nB5     += GDFieldGet("B5",_ni)
		_nB6     += GDFieldGet("B6",_ni)
		_nB7     += GDFieldGet("B7",_ni)
		_nCAIXA  += GDFieldGet("CAIXA",_ni)
		_nROLOS  += GDFieldGet("ROLOS",_ni)
		_nPLIQ   += GDFieldGet("PLIQ",_ni)
		_nPBRUT  += GDFieldGet("PBRUT",_ni)
	EndIf
Next
u_RefrId()
Return(.T.)
*
***********************
User Function RefrId()
***********************
xxx:= 1
_oCARRE:Refresh()
_oB1:Refresh()
_oB2:Refresh()
_oB3:Refresh()
_oB4:Refresh()
_oB5:Refresh()
_oB6:Refresh()
_oB7:Refresh()
_oCAIXA:Refresh()
_oROLOS:Refresh()
_oPLIQ:Refresh()
_oPBRUT:Refresh()
oGetDados:Refresh()
Return(.T.)
*
*******************************
Static Function GraveId(_cToDo)
*******************************
*
If _cToDo == "I"
	_cPedsUpDate := ""
	For _ni := 1 To Len(_MyaCols) 
		If _MyaCols[_ni,1] == "X"
			_cPedOs := _MyaCols[_ni,2] + _MyaCols[_ni,3]
			If !(_cPedOs $ _cPedsUpDate)
				_cPedsUpDate += "'"+_cPedOs+"',"
			EndIf
		EndIf
	Next
	If !Empty(_cPedsUpDate)
		_cZZR_ID := u_MVPXZZRID()
		If	_cZZR_ID == "ERRO_ID"
			// Este erro ocorre quando não tenho lacuna de ID entre 000001 e 999999
			// alterar o tamanho dos campos ZZR_ID E ZZO_ID, bem como o tratamento em impressões
			Alert("Erro no Identificador -> Comunique T.I.")
			Return(.F.)
		Else
			_cPedsUpDate := Left(_cPedsUpDate,Len(_cPedsUpDate)-1)
			cQuery := "UPDATE "+RetSqlName("ZZR") + " SET ZZR_ID = '"+_cZZR_ID+"'"
			cQuery += " WHERE ZZR_FILIAL = '"+xFilial("ZZR")+"'"
			cQuery += " AND ZZR_PEDIDO+ZZR_SEQOS IN ("+_cPedsUpDate+")"
			cQuery += " AND ZZR_ID = '      '"
			cQuery += " AND ZZR_SITUAC <> '9'"
			cQuery += " AND D_E_L_E_T_ = ''"
			TCSqlExec(cQuery)
		
			cQuery := "UPDATE "+RetSqlName("ZZO") + " SET ZZO_ID = '"+_cZZR_ID+"'"
			cQuery += " WHERE ZZO_FILIAL = '"+xFilial("ZZO")+"'"
			cQuery += " AND ZZO_PEDIDO+ZZO_SEQOS IN ("+_cPedsUpDate+")"
			cQuery += " AND ZZO_ID = '      '"
			cQuery += " AND D_E_L_E_T_ = ''"
			TCSqlExec(cQuery)
		EndIf
	EndIf
EndIf
Return(.T.)
*
*
********************************
Static Function CriaAcolId(_cRot)
********************************
*
If _cRot == "I" //INCLUIR
	cPerg := "ACDPDVAL"
	ValidPerg()
	Pergunte(cPerg,.T.)
EndIf

cQuery := ""
cQuery += "SELECT ZZR_PEDIDO, ZZR_SEQOS, C5_CLIENTE, C5_LOJACLI, A1_NOME, A1_MUN, ZZR_LOCALI, ZZR_NROBOB, IsNull(ZE_TPBOB,' ') ZETPBOB, "
cQuery += "	Sum(ZZR_LANCES) LANCES, Sum(ZZR_LANCES/ZZR_QTCAIX) QTCAIX, Sum(ZZR_EMBALA) EMBALA, Sum(ZZR_PESPRO) PESPRO, "
cQuery += "	C5_TIPO, C5_REAJUST, C5_CONDPAG, C5_VEND1, C5_VEND2, C5_VEND3, C5_VEND4, C5_VEND5, C5_CLIENT, C5_LOJAENT "
cQuery += "FROM " + RetSqlName("ZZR") + " ZZR "
cQuery += "	INNER JOIN " + RetSqlName("SC5") + " C5 "
cQuery += "	ON '"+xFilial("SC5") + "' = C5_FILIAL "
cQuery += "	AND ZZR_PEDIDO = C5_NUM "
cQuery += "	AND ZZR.D_E_L_E_T_ = C5.D_E_L_E_T_ "
cQuery += "	INNER JOIN " + RetSqlName("SA1") + " A1 "
cQuery += "	ON '"+xFilial("SA1") + "' = A1_FILIAL "
cQuery += "	AND C5_CLIENTE = A1_COD "
cQuery += "	AND C5_LOJACLI = A1_LOJA "
cQuery += "	AND C5.D_E_L_E_T_ = A1.D_E_L_E_T_ "
cQuery += "	LEFT JOIN " + RetSqlName("SZE") + " ZE "
cQuery += "	ON '"+xFilial("SZE") + "' = ZE_FILIAL "
cQuery += "	AND ZZR_NROBOB = ZE_NUMBOB "
cQuery += "	AND ZZR.D_E_L_E_T_ = ZE.D_E_L_E_T_ "
cQuery += "WHERE ZZR_FILIAL = '"+xFilial("ZZR") + "' "
cQuery += "AND ZZR_SITUAC <> '9' "
If _cRot == "I" //INCLUIR
	cQuery += "AND ZZR_ID = '      ' "
	cQuery += "AND ZZR_DATA > '20170301' "
	cQuery += "	AND C5_CLIENTE+C5_LOJACLI = '" + MV_PAR01+MV_PAR02 + "' "
//	cQuery += "	AND C5_CLIENTE+C5_LOJACLI <= '" + MV_PAR03+MV_PAR04 + "' "
Else
	cQuery += "AND ZZR_ID = '"+ ZZR->ZZR_ID + "' "
EndIf
cQuery += "AND ( SELECT COUNT(*)  "
cQuery += "	  FROM " + RetSqlName("ZZO") + " ZZO "
cQuery += "	  WHERE ZZO_FILIAL = '"+xFilial("ZZO") + "' "
cQuery += "		AND ZZO_PEDIDO = ZZR_PEDIDO "
cQuery += "		AND ZZO_SEQOS  = ZZR_SEQOS ) = 0 "
cQuery += "GROUP BY ZZR_PEDIDO, ZZR_SEQOS, C5_CLIENTE, C5_LOJACLI, A1_NOME, A1_MUN, ZZR_LOCALI, ZZR_NROBOB, ZE_TPBOB, C5_TIPO, C5_REAJUST, C5_CONDPAG, C5_VEND1, C5_VEND2, C5_VEND3, C5_VEND4, C5_VEND5, C5_CLIENT, C5_LOJAENT "
cQuery += "ORDER BY ZZR_PEDIDO, ZZR_SEQOS, C5_CLIENTE, C5_LOJACLI, A1_NOME, A1_MUN, ZZR_LOCALI, ZZR_NROBOB, ZE_TPBOB, C5_TIPO, C5_REAJUST, C5_CONDPAG, C5_VEND1, C5_VEND2, C5_VEND3, C5_VEND4, C5_VEND5, C5_CLIENT, C5_LOJAENT"

_aDadZZR := u_QryArr(cQuery)

ProcRegua(Len(_aDadZZR))
XXX := "PARADA DEBUG"

For _nQtdArray := 1 to Len(_aDadZZR)
	IncProc()
	_nPos   := aScan(aCols,{|x| x[2] == _aDadZZR[_nQtdArray,1] .And. x[3] == _aDadZZR[_nQtdArray,2]})
	If _nPos == 0
		aAdd(aCols,Array(nUsado+1))
		aAdd(_MyaCols,Array(3)) // 
		_nPos := Len(aCols)
		/*/
		01-ZZR_PEDIDO							02-ZZR_SEQOS				03-C5_CLIENTE					04-C5_LOJACLI					05-A1_NOME					
		06-A1_MUN				  				07-ZZR_LOCALI				08-ZZR_NROBOB					09-IsNull(ZE_TPBOB,' ') ZETPBOB	10-Sum(ZZR_LANCES) LANCES
		11-Sum(ZZR_LANCES/ZZR_QTCAIX) QTCAIX	12-Sum(ZZR_EMBALA) EMBALA	13-Sum(ZZR_PESPRO) PESPRO		14-C5_TIPO						15-C5_REAJUST
		16-C5_CONDPAG							17-C5_VEND1					18-C5_VEND2						19-C5_VEND3						20-C5_VEND4
		21-C5_VEND5								22-C5_CLIENT				23-C5_LOJAENT
		/*/               
		

		_MyaCols[_nPos,1] := " "
		_MyaCols[_nPos,2] := _aDadZZR[_nQtdArray,01]
		_MyaCols[_nPos,3] := _aDadZZR[_nQtdArray,02]
		
		GDFieldPut("MARC"      ,If(_cRot=="I"," ","X") ,_nPos)  // aAdd(aHeader,{"Sel"         ,"MARC"   ,"X"           , 1,0,"Pertence('X| ')",,"C",," "})
		GDFieldPut("NUMPV"     ,_aDadZZR[_nQtdArray,01],_nPos)  // aAdd(aHeader,{"Nro Pedido"  ,"NUMPV"  ,"XXXXXX"      , 6,0,.F.,,"C",," "})
		GDFieldPut("SEQUEN"    ,_aDadZZR[_nQtdArray,02],_nPos)  // aAdd(aHeader,{"Seq."        ,"SEQUEN" ,"XX"          , 2,0,.F.,,"C",," "})
		GDFieldPut("CLIENTE"   ,_aDadZZR[_nQtdArray,03],_nPos)  // aAdd(aHeader,{"Cliente"     ,"CLIENTE","XXXXXX"      , 6,0,.F.,,"C",," "})
		GDFieldPut("LOJA"      ,_aDadZZR[_nQtdArray,04],_nPos)  // aAdd(aHeader,{"Loja"        ,"LOJA"   ,"XX"          , 2,0,.F.,,"C",," "})
		GDFieldPut("NOMECLI"   ,_aDadZZR[_nQtdArray,05],_nPos)  // aAdd(aHeader,{"Nome Cliente","NOMECLI",Repl("X",30)  ,30,0,.F.,,"C",," "})
		GDFieldPut("CIDADE"    ,_aDadZZR[_nQtdArray,06],_nPos)  // aAdd(aHeader,{"Cidade"      ,"CIDADE" ,Repl("X",22)  ,22,0,.F.,,"C",," "})
		
		GDFieldPut("CARRE"     ,0,                      _nPos)  // aAdd(aHeader,{"Carretéis"   ,"CARRE"  ,"@E 9,999"    , 4,0,.T.,,"N",," "})
		GDFieldPut("B1"        ,0,                      _nPos)  // aAdd(aHeader,{"Bob.B1"      ,"B1"     ,"@E 9,999"    , 4,0,.T.,,"N",," "})
		GDFieldPut("B2"        ,0,                      _nPos)  // aAdd(aHeader,{"Bob.B2"      ,"B2"     ,"@E 9,999"    , 4,0,.T.,,"N",," "})
		GDFieldPut("B3"        ,0,                      _nPos)  // aAdd(aHeader,{"Bob.B3"      ,"B3"     ,"@E 9,999"    , 4,0,.T.,,"N",," "})
		GDFieldPut("B4"        ,0,                      _nPos)  // aAdd(aHeader,{"Bob.B4"      ,"B4"     ,"@E 9,999"    , 4,0,.T.,,"N",," "})
		GDFieldPut("B5"        ,0,                      _nPos)  // aAdd(aHeader,{"Bob.B5"      ,"B5"     ,"@E 9,999"    , 4,0,.T.,,"N",," "})
		GDFieldPut("B6"        ,0,                      _nPos)  // aAdd(aHeader,{"Bob.B6"      ,"B6"     ,"@E 9,999"    , 4,0,.T.,,"N",," "})
		GDFieldPut("B7"        ,0,                      _nPos)  // aAdd(aHeader,{"Bob.B7"      ,"B7"     ,"@E 9,999"    , 4,0,.T.,,"N",," "})
		GDFieldPut("CAIXA"     ,0,                      _nPos)  // aAdd(aHeader,{"Caixas"      ,"CAIXA"  ,"@E 99,999"   , 5,0,.T.,,"N",," "})
		GDFieldPut("ROLOS"     ,0,                      _nPos)  // aAdd(aHeader,{"Rolos"       ,"ROLOS"  ,"@E 99,999"   , 5,0,.T.,,"N",," "})
		GDFieldPut("PLIQ"      ,0,                      _nPos)  // aAdd(aHeader,{"Peso Liq."   ,"PLIQ"   ,"@E 99,999.99", 8,2,.T.,,"N",," "})
		GDFieldPut("PBRUT"     ,0,                      _nPos)  // aAdd(aHeader,{"Peso Bruto"  ,"PBRUT"  ,"@E 99,999.99", 8,2,.T.,,"N",," "})

		GDFieldPut("_C5TIPO"   ,_aDadZZR[_nQtdArray,14],_nPos)  // aAdd(aHeader,{"Tipo"  ,"_C5TIPO"   ,SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
		GDFieldPut("_C5REAJUST",_aDadZZR[_nQtdArray,15],_nPos)  // aAdd(aHeader,{"Reaj."  ,"_C5REAJUST",SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
		GDFieldPut("_C5CONDPAG",_aDadZZR[_nQtdArray,16],_nPos)  // aAdd(aHeader,{"Cond.Pg."  ,"_C5CONDPAG",SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
		GDFieldPut("_C5VEND1"  ,_aDadZZR[_nQtdArray,17],_nPos)  // aAdd(aHeader,{"Vend.1"  ,"_C5VEND1"  ,SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
		GDFieldPut("_C5VEND2"  ,_aDadZZR[_nQtdArray,18],_nPos)  // aAdd(aHeader,{"Vend.2"  ,"_C5VEND2"  ,SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
		GDFieldPut("_C5VEND3"  ,_aDadZZR[_nQtdArray,19],_nPos)  // aAdd(aHeader,{"Vend.3"  ,"_C5VEND3"  ,SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
		GDFieldPut("_C5VEND4"  ,_aDadZZR[_nQtdArray,20],_nPos)  // aAdd(aHeader,{"Vend.4"  ,"_C5VEND4"  ,SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
		GDFieldPut("_C5VEND5"  ,_aDadZZR[_nQtdArray,21],_nPos)  // aAdd(aHeader,{"Vend.5"  ,"_C5VEND5"  ,SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
		GDFieldPut("_C5CLIENT" ,_aDadZZR[_nQtdArray,22],_nPos)  // aAdd(aHeader,{"Cli.Ent."  ,"_C5CLIENT" ,SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})
		GDFieldPut("_C5LOJAENT",_aDadZZR[_nQtdArray,23],_nPos)  // aAdd(aHeader,{"Loja Ent."  ,"_C5LOJAENT",SX3->X3_PICTURE,SX3->X3_TAMANHO,0,.F.,,SX3->X3_TIPO,," "})

		aCols[_nPos,nUsado+1] := .F.
	EndIf

	/*/
	01-ZZR_PEDIDO							02-ZZR_SEQOS				03-C5_CLIENTE					04-C5_LOJACLI					05-A1_NOME					
	06-A1_MUN				  				07-ZZR_LOCALI				08-ZZR_NROBOB					09-IsNull(ZE_TPBOB,' ') ZETPBOB	10-Sum(ZZR_LANCES) LANCES
	11-Sum(ZZR_LANCES/ZZR_QTCAIX) QTCAIX	12-Sum(ZZR_EMBALA) EMBALA	13-Sum(ZZR_PESPRO) PESPRO		14-C5_TIPO						15-C5_REAJUST
	16-C5_CONDPAG							17-C5_VEND1					18-C5_VEND2						19-C5_VEND3						20-C5_VEND4
	21-C5_VEND5								22-C5_CLIENT				23-C5_LOJAENT
	/*/
	If Left(_aDadZZR[_nQtdArray,07],1)$"CM"
		GDFieldPut("CARRE"  ,GDFieldGet("CARRE",_nPos) + _aDadZZR[_nQtdArray,10],_nPos)          // aAdd(aHeader,{"Carretéis"   ,"CARRE"  ,"@E 9,999"    , 4,0,.T.,,"N",," "})
	ElseIf Left(_aDadZZR[_nQtdArray,07],1)=="B"
		GDFieldPut("B1"  , GDFieldGet("B1",_nPos) + If(_aDadZZR[_nQtdArray,09]=="1",1,0),_nPos)  // aAdd(aHeader,{"Bob.B1"      ,"B1"     ,"@E 9,999"    , 4,0,.T.,,"N",," "})
		GDFieldPut("B2"  , GDFieldGet("B2",_nPos) + If(_aDadZZR[_nQtdArray,09]=="2",1,0),_nPos)  // aAdd(aHeader,{"Bob.B2"      ,"B2"     ,"@E 9,999"    , 4,0,.T.,,"N",," "})
		GDFieldPut("B3"  , GDFieldGet("B3",_nPos) + If(_aDadZZR[_nQtdArray,09]=="3",1,0),_nPos)  // aAdd(aHeader,{"Bob.B3"      ,"B3"     ,"@E 9,999"    , 4,0,.T.,,"N",," "})
		GDFieldPut("B4"  , GDFieldGet("B4",_nPos) + If(_aDadZZR[_nQtdArray,09]=="4",1,0),_nPos)  // aAdd(aHeader,{"Bob.B4"      ,"B4"     ,"@E 9,999"    , 4,0,.T.,,"N",," "})
		GDFieldPut("B5"  , GDFieldGet("B5",_nPos) + If(_aDadZZR[_nQtdArray,09]=="5",1,0),_nPos)  // aAdd(aHeader,{"Bob.B5"      ,"B5"     ,"@E 9,999"    , 4,0,.T.,,"N",," "})
		GDFieldPut("B6"  , GDFieldGet("B6",_nPos) + If(_aDadZZR[_nQtdArray,09]=="6",1,0),_nPos)  // aAdd(aHeader,{"Bob.B6"      ,"B6"     ,"@E 9,999"    , 4,0,.T.,,"N",," "})
		GDFieldPut("B7"  , GDFieldGet("B7",_nPos) + If(_aDadZZR[_nQtdArray,09]=="7",1,0),_nPos)  // aAdd(aHeader,{"Bob.B7"      ,"B7"     ,"@E 9,999"    , 4,0,.T.,,"N",," "})
	ElseIf Left(_aDadZZR[_nQtdArray,07],1)=="L" // Blisters
		GDFieldPut("CAIXA",GDFieldGet("CAIXA",_nPos) + _aDadZZR[_nQtdArray,10],_nPos) // aAdd(aHeader,{"Caixas"      ,"CAIXA"  ,"@E 99,999"   , 5,0,.T.,,"N",," "})
	Else // Demais acondicionamentos (Rolos)
		GDFieldPut("ROLOS",GDFieldGet("ROLOS",_nPos) + _aDadZZR[_nQtdArray,10],_nPos) // aAdd(aHeader,{"Rolos"       ,"ROLOS"  ,"@E 99,999"   , 5,0,.T.,,"N",," "})
	EndIf
	GDFieldPut("PLIQ" ,GDFieldGet("PLIQ" ,_nPos) + _aDadZZR[_nQtdArray,13],_nPos) // aAdd(aHeader,{"Peso Liq."   ,"PLIQ"   ,"@E 99,999.99", 8,2,.T.,,"N",," "})
	GDFieldPut("PBRUT",GDFieldGet("PBRUT",_nPos) + _aDadZZR[_nQtdArray,13] + _aDadZZR[_nQtdArray,12],_nPos) // aAdd(aHeader,{"Peso Bruto"  ,"PBRUT"  ,"@E 99,999.99", 8,2,.T.,,"N",," "})
Next
// Corrige a ordem
aSort(aCols,,,{|x,y| x[02]+x[03]<y[02]+y[03]})
Return(.T.)
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
aAdd(aRegs,{cPerg,"01","Do Cliente                   ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SA1"})
aAdd(aRegs,{cPerg,"02","Da Loja                      ?","mv_ch2","C",02,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
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
***********************
User Function VejaChv()
***********************
*
Local _cChave := ""
Local _Volta := .T.
If GDDeleted(n)
	aCols[n,nUsado+1] := .F. // Tira a deleção
	M->MARC       := " "
EndIf
If !M->MARC $ " |X|x"
	Return(.F.)
ElseIf Empty(M->MARC)
	Return(.T.)
EndIf      
M->MARC       := Upper(M->MARC)

// Primeiro pego a chave da linha "n"
// Chave de pedidos iguais 'C5TIPO+C5CLIENTE+C5LOJACLI+C5CLIENT+C5LOJAENT+C5CONDPAG+C5REAJUST+C5VEND1+C5VEND2+C5VEND3+C5VEND4+C5VEND5'

_cChave := GDFieldGet("_C5TIPO",n)+GDFieldGet("CLIENTE",n)+GDFieldGet("LOJA",n)+GDFieldGet("_C5CLIENT",n)+GDFieldGet("_C5LOJAENT",n)+;
		   GDFieldGet("_C5CONDPAG",n)+GDFieldGet("_C5REAJUST",n)+GDFieldGet("_C5VEND1",n)+GDFieldGet("_C5VEND2",n)+GDFieldGet("_C5VEND3",n)+;
		   GDFieldGet("_C5VEND4",n)+GDFieldGet("_C5VEND5",n)
// Primeiro verificar se pode para depois marcar os demais.

For _ni := 1 To Len(aCols)
	If _ni # n .And. !GDDeleted(_ni)
		If _cChave # GDFieldGet("_C5TIPO",_ni)+GDFieldGet("CLIENTE",_ni)+GDFieldGet("LOJA",_ni)+GDFieldGet("_C5CLIENT",_ni)+GDFieldGet("_C5LOJAENT",_ni)+;	
					 GDFieldGet("_C5CONDPAG",_ni)+GDFieldGet("_C5REAJUST",_ni)+GDFieldGet("_C5VEND1",_ni)+GDFieldGet("_C5VEND2",_ni)+GDFieldGet("_C5VEND3",_ni)+;
					 GDFieldGet("_C5VEND4",_ni)+GDFieldGet("_C5VEND5",_ni) .And. GDFieldGet("MARC",_ni) == "X"
			Alert("Não é Possivel Aglutinar Pedidos com Características Diferentes")
			_Volta := .F.
			Exit     
		EndIf
	EndIf
Next

If _Volta 
	For _ni := 1 To Len(aCols)
		If _ni # n .And. !GDDeleted(_ni)
			If _cChave == GDFieldGet("_C5TIPO",_ni)+GDFieldGet("CLIENTE",_ni)+GDFieldGet("LOJA",_ni)+GDFieldGet("_C5CLIENT",_ni)+GDFieldGet("_C5LOJAENT",_ni)+;	
							  GDFieldGet("_C5CONDPAG",_ni)+GDFieldGet("_C5REAJUST",_ni)+GDFieldGet("_C5VEND1",_ni)+GDFieldGet("_C5VEND2",_ni)+GDFieldGet("_C5VEND3",_ni)+;
							  GDFieldGet("_C5VEND4",_ni)+GDFieldGet("_C5VEND5",_ni) .And. Empty(GDFieldGet("MARC",_ni))
				//	Se achar outro cara igual, marcar
				aCols[_ni,1]    := "X"
	
				//GDFieldPut("MARC","X",_ni)  // aAdd(aHeader,{"Sel"         ,"MARC"   ,"X"           , 1,0,"Pertence('X| ')",,"C",," "})
			EndIf
		EndIf
	Next
EndIf
Return(_Volta)
*
**************************
User Function ImprID(_cID)
**************************
*
Default _cID := ZZR->ZZR_ID

DbSelectArea("SA1")
DbSelectArea("ZZR")

Do While .T.
	aRet := {}
   	aParamBox := {}
	aAdd(aParamBox,{1,"I.D. Separação",Padr(" ",TamSx3('ZZR_ID')[1]),"","",""      ,"",50,.F.})
	If !ParamBox(aParamBox,"Relatório para Separação",@aRet,,,,,,,,.T.,.T.)
		Exit
	EndIf      
	ImpRelSep(MV_PAR01)
EndDo
Return(.T.)
*
***************************
Static Function ImpRelSep(MV_PAR01)
***************************
*
Local cQuery, _aPeds, _cPeds, _cPeds1,_cPeds2,_cPeds3, _aDadZZR, _cCliente, _nCtd
Local oFont3 := TFont():New( "Arial",,30,,.T.,,,,.T.,.F.) // oFont3 := TFont():New( "Arial",,18,,.T.,,,,.T.,.F.)
Local oFont4 := TFont():New( "Arial",,15,,.T.,,,,   ,.F.) 
Local oFont5 := TFont():New( "Arial",,12,,.T.,,,,   ,.F.) // Negrito
Local oFont7 := TFont():New( "Arial",,10,,.T.,,,,   ,.F.) 
Local oFont8 := TFont():New( "Arial",,08,,.T.,,,,   ,.F.) 
Local _nPagAtu, _nPagCalc, nLinhas
Local _aNomes := {"Rolo","Carretel","Carr.Mad.","Bobina","Blister","Retalho"}

cQuery := "SELECT DISTINCT ZZR_PEDIDO, ZZR_SEQOS, C5_CLIENTE, C5_LOJACLI, A1_NOME, ZZR_NROBOB"
cQuery += " FROM "+RetSqlName("ZZR") + " ZZR"
cQuery += " INNER JOIN "+RetSqlName("SC5") + " C5 ON ZZR_FILIAL = C5_FILIAL	AND ZZR_PEDIDO = C5_NUM AND ZZR.D_E_L_E_T_ = C5.D_E_L_E_T_"
cQuery += " INNER JOIN "+RetSqlName("SA1") + " A1 ON '  ' = A1_FILIAL AND C5_CLIENTE = A1_COD AND C5_LOJACLI = A1_LOJA  AND C5.D_E_L_E_T_ = A1.D_E_L_E_T_"
cQuery += " WHERE ZZR_FILIAL = '"+xFilial("ZZR")+"'"
cQuery += " AND ZZR_ID = '" + MV_PAR01 +"'"
cQuery += " AND ZZR.D_E_L_E_T_ = ''"
cQuery += " ORDER BY ZZR_PEDIDO, ZZR_SEQOS"
_aPeds := u_QryArr(cQuery)
If Len(_aPeds) == 0
	Return(.T.)
EndIf
_cCliente := _aPeds[1,3] + "-" + _aPeds[1,4] + '  ' + AllTrim(_aPeds[1,5])
_cPeds := ""
_cPeds1 := ""
_cPeds2 := ""
_cPeds3 := ""
For _nCtd := 1 To Len(_aPeds)
	If Len(_cPeds) > 0
		_cPeds += " / "
	EndIf
	_cPeds += _aPeds[_nCtd,1] + "-" + _aPeds[_nCtd,2]
	If Len(_cPeds) > 140
		If Empty(_cPeds1)
			_cPeds1 := _cPeds
		ElseIf Empty(_cPeds2)
			_cPeds2 := _cPeds
		ElseIf Empty(_cPeds3)
			_cPeds3 := _cPeds
		EndIf
		_cPeds := ""
	EndIf
Next
If Empty(_cPeds1)
	_cPeds1 := _cPeds
ElseIf Empty(_cPeds2)
	_cPeds2 := _cPeds
ElseIf Empty(_cPeds3)
	_cPeds3 := _cPeds
EndIf

cQuery := "SELECT ZZR_PRODUT, ZZR_DESCRI, ZZR_LOCALI, "
cQuery += " SUM(ZZR_QUAN) QUAN, SUM(ZZR_LANCES) LANCES , SUM(ZZR_QTCAIX) QTCAIX, COUNT(*) QTDREG, ZZR_NROBOB, " // Estou ZZE_NROBOB para a função u_QryArr criar + 1 elementono array de retorno
cQuery += " FROM "+RetSqlName("ZZR") + " ZZR"
cQuery += " WHERE ZZR_FILIAL = '"+xFilial("ZZR")+"'"
cQuery += " AND ZZR_ID = '" + MV_PAR01 +"'"
cQuery += " AND Left(ZZR_LOCALI,1) <> 'B'"
cQuery += " AND D_E_L_E_T_ = ''"
cQuery += " GROUP BY ZZR_LOCALI, ZZR_PRODUT, ZZR_DESCRI, ZZE_NROBOB"
cQuery += " ORDER BY ZZR_LOCALI, ZZR_PRODUT, ZZR_DESCRI, ZZE_NROBOB"
_aDadZZR := u_QryArr(cQuery)
If Len(_aDadZZR) == 0
	Return(.T.)
EndIf

cQuery := "SELECT ZZR_PRODUT, ZZR_DESCRI, ZZR_LOCALI, ZZR_QUAN, ZZR_LANCES, ZZR_QTCAIX, 1 COLUNA, ZZR_NROBOB, Substring(ZZR_PEDIDO,5,2) FIMPED, ZE_TPBOB "
cQuery += " FROM "+RetSqlName("ZZR") + " ZZR"
cQuery += " 	INNER JOIN "+RetSqlName("SZE") + "SZE "
cQuery += " 	ON ZZR_FILIAL = ZE_FILIAL"
cQuery += " 	AND ZZR_NROBOB = ZE_NUMBOB"
cQuery += " 	AND ZZR.D_E_L_E_T_ = ZE.D_E_L_E_T_"
cQuery += " WHERE ZZR_FILIAL = '"+xFilial("ZZR")+"'"
cQuery += " AND ZZR_ID = '" + MV_PAR01 +"'"
cQuery += " AND Left(ZZR_LOCALI,1) = 'B'"
cQuery += " AND ZZR.D_E_L_E_T_ = ''"
_aDadSZE := u_QryArr(cQuery)


// _aDadZZR -> 1-ZZR_PRODUT, 2-ZZR_DESCRI, 3-ZZR_LOCALI, 4-ZZR_QUAN, 5-ZZR_LANCES, 6-ZZR_QTCAIX, 7-QTDREG, 8-ZZE_NROBOB
// _aDadSZE -> 1-ZZR_PRODUT, 2-ZZR_DESCRI, 3-ZZR_LOCALI, 4-ZZR_QUAN, 5-ZZR_LANCES, 6-ZZR_QTCAIX, 7-COLUNA, 8-ZZR_NROBOB, 9-Substring(ZZR_PEDIDO,5,2) FIMPED, 10-ZE_TPBOB
aSort(aCols,,,{|x,y| x[10]+x[09]+x[08]<y[10]+y[09]+x[08]})

For _nCtSZE := 1 To  Len(_aDadSZE)
	aADD(_aDadZZR,Array(7))
	_nLinZZR := Len(_aDadZZR)
	_aDadZZR[_nLinZZR,01] := _aDadSZE[_nCtSZE,01]
	_aDadZZR[_nLinZZR,02] := _aDadSZE[_nCtSZE,02]
	_aDadZZR[_nLinZZR,03] := _aDadSZE[_nCtSZE,03]
	_aDadZZR[_nLinZZR,04] := _aDadSZE[_nCtSZE,04]
	_aDadZZR[_nLinZZR,05] := _aDadSZE[_nCtSZE,05]
	_aDadZZR[_nLinZZR,06] := _aDadSZE[_nCtSZE,06]
	_aDadZZR[_nLinZZR,08] := "Bob.Tp." + _aDadSZE[_nCtSZE,10] + " PV." + _aDadSZE[_nCtSZE,09] + " Nro." + _aDadSZE[_nCtSZE,08]

Next

_nPagAtu := 0
_nMaxLin := 37
_nPagCalc :=  Int((Len(_aDadZZR) / _nMaxLin))
nLinhas := 0
If Len(_aDadZZR) > (_nPagCalc * _nMaxLin)
	_nPagCalc++
EndIf

cImpr	:= ""
cPorta	:= ""
_nPasso := 17
lServer := .F. //.T.
PreparePrint(.T.,cImpr, .F.,cPorta)
InitPrint(2,"ORDEMSEP","080",,"ORDEMSEP")
lAdjustToLegacy := .F.
lDisableSetup := .T.
Private oPrn := FWMSPrinter():New("ORDEMSEP.REL",IMP_SPOOL,lAdjustToLegacy,"\spool\",lDisableSetup,,,"",lServer,,,,1 )

oPrn:SetPortrait() // Formato pagina Retrato

For _nLinAtu := 1 To Len(_aDadZZR)
	
	If ++nLinhas > _nMaxLin
		oPrn:EndPage() // Encerra a página atual
		nLinhas := 1
	EndIf
	If nLinhas == 1
		oPrn:StartPage() //inicializa nova pagina
		_nPagAtu++

		oPrn:Box (0020,0020,0090,0570) // Box 1 Cabeçalho
		oPrn:Line(0055,0140,0055,0570) // Linha horizontal que divide o cabeçalho em dois
		oPrn:Line(0020,0140,0090,0140) // Linha vertical que fecha o retangulo do cód. de barras
		oPrn:Line(0020,0484,0090,0484) // Linha vertical que fecha os retangulos da página e do peso bruto
		oPrn:Say(0050,0180,"SEPARAÇÃO Nº  " + MV_PAR01,oFont3)
		oPrn:Say(0030,0489,"Página:"      ,oFont5)
		oPrn:Say(0040,0530,StrZero(_nPagAtu,2) + "/" + StrZero(_nPagCalc,2)  ,oFont4)      // Página
		oPrn:Say(0065,0145,"Cliente:"     ,oFont7)
		oPrn:Say(0065,0489,"Data:"        ,oFont5)
		oPrn:Say(0080,0145,AllTrim(_cCliente),oFont7)
		oPrn:Say(0080,0505,Transform(Date(),"@E"),oFont4) // Data do volume
       	
       	If Len(_cPeds1) == 9 // Só tem um cara
			oPrn:Say(0100,0020,"Pedido:  ",oFont7)
		Else
			oPrn:Say(0100,0020,"Pedidos:  ",oFont7)
		EndIf
		oPrn:Say(0100,0060,_cPeds1    ,oFont7)
		oPrn:Say(0110,0060,_cPeds2    ,oFont7)
		oPrn:Say(0120,0060,_cPeds3    ,oFont7)

		oPrn:Line(0130,0020,0130,0570) // Linha horizontal de Abertura do cabeçalho
		oPrn:Line(0130,0020,0155,0020) // Linha vertical de Abertura do cabeçalho
		oPrn:Line(0130,0090,0155,0090) // Linha vertical de Abertura da descrição

		oPrn:Line(0130,0350,0155,0350) // Linha vertical de Abertura Embalagem
		oPrn:Line(0130,0405,0155,0405) // Linha vertical de Abertura Tam. Lance
		oPrn:Line(0130,0460,0155,0460) // Linha vertical de Abertura Acondicionamento
		oPrn:Line(0130,0515,0155,0515) // Linha vertical de Abertura Quant. Lances
		oPrn:Line(0130,0570,0155,0570) // Linha vertical de fechamento
		
		// Titulos das colunas
		oPrn:Say(0145,0025,"Código"   ,oFont4)
		oPrn:Say(0145,0095,"Descrição",oFont4)
		oPrn:Say(0145,0355,"Embal."   ,oFont4)
		oPrn:Say(0145,0410,"Tam.Lance" ,oFont4)
		oPrn:Say(0145,0465,"Qtd.Emb."   ,oFont4)
		oPrn:Say(0145,0520,"Qtd.Mts."   ,oFont4)
		oPrn:Line(0155,0020,0155,0570) // Linha horizontal de fechamento do cabeçalho
		_nLInGrd := 0155
	EndIf
	
	oPrn:Line(_nLInGrd,0020,_nLInGrd+_nPasso,0020) // Linha vertical de Abertura do cabeçalho
	oPrn:Line(_nLInGrd,0090,_nLInGrd+_nPasso,0090) // Linha vertical de Abertura da descrição
	oPrn:Line(_nLInGrd,0350,_nLInGrd+_nPasso,0350) // Linha vertical de Abertura do acondicionamento
	
	If Empty(_aDadZZR[_nLinAtu,8])
		oPrn:Line(_nLInGrd,0405,_nLInGrd+_nPasso,0405) // Linha vertical de Abertura da quantidade
		oPrn:Line(_nLInGrd,0460,_nLInGrd+_nPasso,0460) // Linha vertical de Abertura da quantidade METROS
	EndIf
	oPrn:Line(_nLInGrd,0515,_nLInGrd+_nPasso,0515) // Linha vertical de Abertura do embalagem
	oPrn:Line(_nLInGrd,0570,_nLInGrd+_nPasso,0570) // Linha vertical de fechamento

	// DADOS DAS COLUNAS
	oPrn:Say(_nLInGrd+15,0025,Transform(_aDadZZR[_nLinAtu,1],"@R 999.99.99.9.99"),oFont5)
	oPrn:Say(_nLInGrd+15,0095,AllTrim(_aDadZZR[_nLinAtu,2])                      ,oFont5)
	If Empty(_aDadZZR[_nLinAtu,8])
		oPrn:Say(_nLInGrd+15,0355, _aNomes[At(Left(_aDadZZR[_nLinAtu,3],1),"RCMBLT")] ,oFont5)
		oPrn:Say(_nLInGrd+15,0420,AllTrim(_aDadZZR[_nLinAtu,3])                      ,oFont5)
		oPrn:Say(_nLInGrd+15,0465,Transform(_aDadZZR[_nLinAtu,5] / (_aDadZZR[_nLinAtu,6]/_aDadZZR[_nLinAtu,7]),"@E 9,999,999")     ,oFont5)
	Else
		oPrn:Say(_nLInGrd+15,0355, _aDadZZR[_nLinAtu,8],oFont5)
	EndIf
	oPrn:Say(_nLInGrd+15,0520,Transform(_aDadZZR[_nLinAtu,4],"@E 9,999,999")     ,oFont5)

	oPrn:Line(_nLInGrd+_nPasso,0020,_nLInGrd+_nPasso,0570) // Linha horizontal de fechamento do cabeçalho
	_nLInGrd += _nPasso
Next
oPrn:EndPage() // Encerra a página atual
_lPrepImp := .T.
If _lPrepImp
	oPrn:SetUp()
	oPrn:Print()
Else
	oPrn:Print()
EndIf
Return(.T.)