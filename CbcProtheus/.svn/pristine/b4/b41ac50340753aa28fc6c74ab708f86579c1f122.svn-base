#include "topconn.ch"
#include "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDGEN08                            Modulo : SIGAEST      //
//                                                                          //
//   Autor ......: Roberto Oliveira                   Data ..: 20/08/2007   //
//                                                                          //
//   Objetivo ...: Cadastro de Saída de Materiais                           //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
*                       
***********************
User Function CDGEN08()
***********************
*                                    
If "ADMINISTRADOR" $ Upper(cUserName) .Or. "ROBERTO" $ Upper(cUserName)
	aRotina := {{ "Pesquisar"  , "AxPesqui"     , 0 , 1	},;
	   			{ "Visualizar" , "AxVisual"     , 0 , 2	},;
				{ "Saída Carga", "u_IncCarga()" , 0 , 4	},;
				{ "Incluir"    , "u_IncSaida(1)", 0 , 3	},;
				{ "Alterar"    , "u_IncSaida(2)", 0 , 4	},;
				{ "Excluir"    , "u_ExcSaida()" , 0 , 5	}}
	// A rotina Saída Carga ainda não está concluída
Else
	aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
				{ "Visualizar", "AxVisual", 0 , 2	},;
				{ "Incluir"   , "u_IncSaida(1)", 0 , 3	},;
				{ "Alterar"   , "u_IncSaida(2)", 0 , 4	},;
				{ "Excluir"   , "u_ExcSaida()", 0 , 5	}}
EndIf
	

cCadastro := "Saídas de Materiais"
DbSelectArea("SZF")
DbSetOrder(1)
DbSeek(xFilial("SZF"))

mBrowse(001,040,200,390,"SZF",,,,,,)

Return(.T.)
*
****************************
User Function IncSaida(nRot)
****************************
*
If nRot == 1 // Inclusao
	nOpca := AxInclui("SZF",0,3, , , ,)
Else
	nOpca := AxAltera("SZF",Recno(),4, , , ,)
EndIf
If nOpca == 1
	_Peds := u_BuscaPv() // Retorna: {1-Pedidos da nota, 2-Peso Padrão, 3-Vlr.Mercadoria, 4-Peso Cobre, 5-Peso PVC}
	RecLock("SZF",.F.)
	SZF->ZF_PEDIDOS := _Peds[1]
	SZF->ZF_PESO    := _Peds[2]
	SZF->ZF_TOTAL   := _Peds[3]
	MsUnLock()
	
	DbSelectArea("SF2")
	DBOrderNickName("SF2CDROMA")
	//DbSetOrder(7)
	DbSeek(xFilial("SF2")+SZF->ZF_CDROMA,.F.)
	Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_CDROMA == SZF->ZF_CDROMA .And. SF2->(!Eof())
		RecLock("SF2",.F.)
		SF2->F2_DTENTR := SZF->ZF_DATA
		SF2->F2_HRENTR := SZF->ZF_HORA
		SF2->F2_TRANSP := SZF->ZF_TRANS
		SF2->F2_MOTOR  := SZF->ZF_MOTOR
		SF2->F2_CARREG := SZF->ZF_CARREG
		SF2->F2_DTRETCA := SZF->ZF_DTRETCA
		MsUnLock()
		DbSkip()
	EndDo
	DbSelectArea("SZF")
EndIf
If nRot == 2 // Alteração
	If SZF->ZF_EMAIL == "E"
		u_CdFat05(.F.)
	EndIf
EndIf
Return(.T.)
*
***********************
User Function TrcNota()
***********************
*
M->ZF_NOTA := StrZero(Val(M->ZF_NOTA),Len(M->ZF_NOTA))
Return(.T.)
*
************************
User Function ExcSaida()
************************
*
_cRomanDel := SZF->ZF_CDROMA
nOpca := AxDeleta("SZF",SZF->(Recno()),5,,,,)
If nOpca == 1
	DbSelectArea("SF2")
	DBOrderNickName("SF2CDROMA")
	//DbSetOrder(7)
	DbSeek(xFilial("SF2")+_cRomanDel,.F.)
	Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_CDROMA == _cRomanDel .And. SF2->(!Eof())
		RecLock("SF2",.F.)
		SF2->F2_DTENTR := Ctod("//")
		SF2->F2_HRENTR := "   "
		//		SF2->F2_TRANSP := "  "
		SF2->F2_MOTOR  := "  "
		SF2->F2_CARREG := "  "
		SF2->F2_DTRETCA := Ctod("//")
		MsUnLock()
		DbSkip()
	EndDo
	DbSelectArea("SZF")
EndIf
Return(.T.)
*
************************
User Function IncCarga()
************************
*
Private aCols := {}
Private aHeader := {}
aAltEnchoice :={}

nOpcE:=2
nOpcG:=2

M->_ZF_TRANS  := CriaVar("ZF_TRANS")
M->_ZF_NOMTRP := CriaVar("ZF_NOMTRP")
M->_ZF_MOTOR  := CriaVar("ZF_MOTOR")
M->_ZF_CARREG := CriaVar("ZF_CARREG")
M->_ZF_PESONF := CriaVar("ZF_PESONF")
M->_ZF_TARABL := CRIAVAR("ZF_TARABL")
M->_ZF_BRUTOBL:= CRIAVAR("ZF_BRUTOBL")
M->_ZF_DESVIO := CriaVar("ZF_DESVIO")
M->_ZF_OBSERVA:= CriaVar("ZF_OBSEVA")

aHeader:={}
aAdd(aHeader,{"Ordem"          ,"ORDEM"  ,"@E 9,999"    , 4,0,.T.,,"N",,"R"})
aAdd(aHeader,{"Nro NF/Rom."    ,"NUMDOC" ,Repl("X",TamSX3("D2_DOC")[1]) ,TamSX3("D2_DOC")[1] ,0,.F.,,"C",,"R"})	
aAdd(aHeader,{"Cliente"        ,"CODICLI",Repl("X",TamSX3("A1_COD")[1]) ,TamSX3("A1_COD")[1] ,0,.F.,,"C",,"R"})	
aAdd(aHeader,{"Loja"           ,"LOJACLI",Repl("X",TamSX3("A1_LOJA")[1]),TamSX3("A1_LOJA")[1],0,.F.,,"C",,"R"})	
aAdd(aHeader,{"Nome do Cliente","NOMECLI",Repl("X",TamSX3("A1_NOME")[1]),TamSX3("A1_NOME")[1],0,.F.,,"C",,"R"})	
aAdd(aHeader,{"Peso Padrão"    ,"PESOPAD","@E 99,999.99",29,2,.F.,,"C",,"R"})
aAdd(aHeader,{"Peso Bruto Nota","PESOBTO","@E 99,999.99",29,2,.F.,,"C",,"R"})
nUsado:=Len(aHeader)

aCols := {}

Processa( {|| MontaNotas()},"Carregando Dados...")
                                            
If Len(aCols) == 0
	Alert("Não existem Notas Para Sair")
	Returm(.T.)
EndIf

DbSelectArea("SZF")

_lRet:= .F.
aButtons := {}

cTitulo        := "Saída de Materiais"

cAliasEnchoice := ""
cAliasGetD     := "SZF"
cLinOk         := "u_VlLinSd()"
cFieldOk       := "U_RefrSd()" //"AllwaysTrue()"
cTudOk         := "AllwaysTrue()"
aCpoEnchoice   := {}
_lRet:=u_JanSaida(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice)

//continuar aqui depois de comcluir a JanSaida 

If _lRet
	// Antes de perguntar, verifico se tem alguma linha não deletada
	_lRet := .F.
	For _ni := 1 To Len(aCols)
		If !GDDeleted(_ni)
			_lRet := .T.
			Exit
		EndIf
	Next
	If _lRet
		If MsgYesNo("Confirma a " + If(_cRot=="E","Exclusão","Montagem") + " da Carga?")
			GraveSaida()
//			continuar aqui depois de comcluir a GraveSaida
		EndIf           
		
	EndIf
EndIf
DbSelectArea("SZF")
DbSetOrder(1) 
Return(.T.)
*
****************************
Static Function MontaNotas()
****************************
*                   
cQuery := "SELECT DISTINCT F2_SERIE, F2_DOC, F2_CDROMA, F2_CLIENT, F2_LOJA, F2_PBRUTO"
cQuery += "	FROM "+RetSqlName("SF2") + " F2"
cQuery += "		INNER JOIN "+RetSqlName("SD2") + " D2"
cQuery += "		ON F2_FILIAL = D2_FILIAL"
cQuery += "		AND ' ' = F2_ECF" // Estou usando o ECF porque é chave de indice
cQuery += "		AND F2_SERIE = D2_SERIE"
cQuery += "		AND F2_DOC = D2_DOC"
cQuery += "		AND F2.D_E_L_E_T_ = D2.D_E_L_E_T_"
cQuery += "		INNER JOIN "+RetSqlName("SF4") + " F4"
cQuery += "		ON '  ' = F4_FILIAL"
cQuery += "		AND D2_TES = F4_CODIGO"
cQuery += "		AND 'S' = F4_ESTOQUE"
cQuery += "		AND D2.D_E_L_E_T_ = F4.D_E_L_E_T_"
cQuery += "	WHERE F2_FILIAL = '"+xFilial("SF2")+"'"
cQuery += "	AND F2_EMISSAO > '20161020'"
cQuery += "	AND F2_DTENTR = ''"
cQuery += "	AND F2.D_E_L_E_T_ = ''"
cQuery += "	ORDER BY F2_CDROMA, F2_DOC"

cQuery := ChangeQuery(cQuery)

If Select("TB_SF2")>0    
	TB_SF2->(dbcloseArea())
	FErase( "TB_SF2" + GetDbExtension())
EndIf

TCQUERY cQuery NEW ALIAS "TB_SF2"

DbSelectArea("TB_SF2")
Count to nQtdZZR
TB_SF2->(DbGotop())
ProcRegua(nQtdZZR)

Do While TB_SF2->(!Eof())

	aAdd(aCols,Array(nUsado+1))
	aCols[Len(aCols),nUsado+1]:=.T. // Nasce deletado...
	_nPos := Len(aCols)
 
	GDFieldPut("ORDEM"  ,_nPos            ,_nPos)
	GDFieldPut("NUMDOC" ,TB_SF2->F2_DOC   ,_nPos)
	GDFieldPut("CODICLI",TB_SF2->F2_CLIENT,_nPos)
	GDFieldPut("LOJACLI",TB_SF2->F2_LOJA  ,_nPos)
	GDFieldPut("NOMECLI",Posicione("SA1",1,xFilial("SA1")+TB_SF2->F2_CLIENT + TB_SF2->F2_LOJA,"A1_NOME"),_nPos)
	GDFieldPut("PESOBTO",0,_nPos)
	_cNumRom := TB_SF2->F2_CDROMA
	_nPesTot := 0
	Do While TB_SF2->F2_CDROMA == _cNumRom .And. TB_SF2->(!Eof())
		IncProc()
		If TB_SF2->F2_SERIE == "U  "
			// Assumir o número do romaneio
			GDFieldPut("NUMDOC" ,TB_SF2->F2_CDROMA,_nPos)
		EndIf
		_nPesTot += TB_SF2->F2_PBRUTO
		TB_SF2->(DbSkip())
	EndDo
	GDFieldPut("PESOBTO",_nPesTot,_nPos)
EndDo
If Select("TB_SF2")>0    
	TB_SF2->(dbcloseArea())
	FErase( "TB_SF2" + GetDbExtension())
EndIf
    
// Corrige a ordem
aSort(aCols,,,{|x,y| x[02]<y[02]})
For _nPos := 1 to Len(aCols)
	GDFieldPut("ORDEM"  ,_nPos,_nPos)
Next
Return(.T.)
*
**********************************************************************************************************************************
User Function JanSaida(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze)
**********************************************************************************************************************************

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

@ 010,005 Say "Transportadora:"                                                                   Size 40,10
@ 010,050 Get _ZF_TRANS F3 "SA4" Picture PesqPict("SZF","ZF_TRANS")  Object _o_ZF_TRANS           Size 40,10
@ 010,095 Say "Nome Transp.:"                                                                     Size 40,10
@ 010,130 Get _ZF_NOMTRP         Picture PesqPict("SZF","ZF_NOMTRP") Object _o_ZF_NOMTRP When .F. Size 80,10

@ 025,005 Say "Nome Motorista:" Size 40,10
@ 025,050 Get _ZF_MOTOR          Picture PesqPict("SZF","ZF_MOTOR")                               Size 40,10

@ 040,005 Say "Nome Carregador:" Size 40,10
@ 040,050 Get _ZF_CARREG         Picture PesqPict("SZF","ZF_CARREG")                              Size 40,10

@ 055,005 Say "Peso Notas:" Size 40,10
@ 055,040 Get _nB4 Picture "@E 999" Object _oB4 When .F. Size 40,10

@ 055,085 Say "Qtd.Bob.B5:" Size 40,10
@ 055,120 Get _nB5 Picture "@E 999" Object _oB5 When .F. Size 40,10

@ 055,165 Say "Qtd.Bob.B6:" Size 40,10
@ 055,200 Get _nB6 Picture "@E 999" Object _oB6 When .F. Size 40,10

@ 055,250 Say "Qtd.Bob.B7:" Size 40,10
@ 055,285 Get _nB7 Picture "@E 999" Object _oB7 When .F. Size 40,10

@ 055,330 Say "Qtd.Pallets:" Size 40,10
@ 055,365 Get _nPALLET Picture "@E 99" Object _oPALLET When .F. Size 40,10


_ZF_PESONF := CriaVar("ZF_PESONF")
_ZF_TARABL := CRIAVAR("ZF_TARABL")
_ZF_BRUTOBL:= CRIAVAR("ZF_BRUTOBL")
_ZF_DESVIO := CriaVar("ZF_DESVIO")
_ZF_OBSERVA:= CriaVar("ZF_OBSEVA")



/*/
@ nLiGet,165 Say "Qtd.Bob.B1:" Size 40,10
@ nLiGet,200 Get _nB1 Picture "@E 999" Object _oB1 When .F. Size 40,10
@ nLiGet,250 Say "Qtd.Bob.B2:" Size 40,10
@ nLiGet,285 Get _nB2 Picture "@E 999" Object _oB2 When .F. Size 40,10
@ nLiGet,330 Say "Qtd.Bob.B3:" Size 40,10
@ nLiGet,365 Get _nB3 Picture "@E 999" Object _oB3 When .F. Size 40,10
nLiGet+=15
nLiGet+=15
@ nLiGet,005 Say "Qtd.Caixas:" Size 40,10
@ nLiGet,040 Get _nCAIXA Picture "@E 99,999" Object _oCAIXA When .F. Size 40,10
@ nLiGet,085 Say "Qtd.Rolos:" Size 40,10
@ nLiGet,120 Get _nROLOS Picture "@E 99,999" Object _oROLOS When .F. Size 40,10
@ nLiGet,165 Say "Peso Liquido:" Size 40,10
@ nLiGet,200 Get _nPLIQ Picture "@E 99,999.99" Object _oPLIQ When .F. Size 40,10
@ nLiGet,250 Say "Peso Bruto:" Size 40,10
@ nLiGet,285 Get _nPBRUT Picture "@E 99,999.99" Object _oPBRUT When .F. Size 40,10
/*/

oGetDados := MsGetDados():New(nLiGet+20,aPosObj[2,2],310,aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,Len(aCols),cFieldOk)
oGetDados:oBrowse:bChange := {|| u_VlLinSd()}

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons) CENTERED
lRet:=(nOpca==1)
Return(lRet)
*
***********************
User Function VlLinSd()
***********************
*
_nFARDOS := 0
_nCARRE := 0
_nB1 := 0
_nB2 := 0
_nB3 := 0
_nB4 := 0
_nB5 := 0
_nB6 := 0
_nB7 := 0
_nPALLET := 0
_nCAIXA := 0
_nROLOS := 0
_nPLIQ := 0
_nPBRUT := 0
For _ni := 1 To Len(aCols)
	If Left(GDFieldGet("SITUACA",_ni),1) # "1"
		// Se não for 1-Volumes OK não pode colocar em carga
		aCols[_ni,Len(ACols[_ni])] := .T.
	EndIf
	If !GDDeleted(_ni)
		_nFARDOS += GDFieldGet("FARDOS",_ni)
		_nCARRE  += GDFieldGet("CARRE",_ni)
		_nB1     += GDFieldGet("B1",_ni)
		_nB2     += GDFieldGet("B2",_ni)
		_nB3     += GDFieldGet("B3",_ni)
		_nB4     += GDFieldGet("B4",_ni)
		_nB5     += GDFieldGet("B5",_ni)
		_nB6     += GDFieldGet("B6",_ni)
		_nB7     += GDFieldGet("B7",_ni)
		_nPALLET += GDFieldGet("PALLET",_ni)
		_nCAIXA  += GDFieldGet("CAIXA",_ni)
		_nROLOS  += GDFieldGet("ROLOS",_ni)
		_nPLIQ   += GDFieldGet("PLIQ",_ni)
		_nPBRUT  += GDFieldGet("PBRUT",_ni)
	EndIf
Next
u_RefrSd()
Return(.T.)
*
**********************
User Function RefrSd()
**********************
*
Return(.T.)