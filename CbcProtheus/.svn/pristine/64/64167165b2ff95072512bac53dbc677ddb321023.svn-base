#include "rwmake.ch"
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: 	cdest05                           Modulo : SIGAEST      //
//                                                                          //
//                                                    Data ..: 27/04/2006   //
//                                                                          //
//   Objetivo ...: Browse para montagem da programação da produção.         //
//                                                                          //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
////////////////////////////////////////////'//////////////////////////////////
//
*
***********************
User Function CdEst05() //*ok
***********************
*
Private _cNmArq1  := _cNmArq2 := ""                               // Arquivo Temporario
Private _aCampos  := {}
Private cPerg     := "CDET05"
Private cMarca    := GetMark()
Private lInverte  :=.T.
Private _aInsumos := {}
Private aHeader   := {}
Private aCols     := {}
Private _cOpc	  := ""

aCampos := {}

aAdd(_aCampos, {"OK"     , "C", 02, 0})
aAdd(_aCampos, {"SEMANA" , "C", 07, 0})
aAdd(_aCampos, {"NUM"    , "C", TamSX3("C6_NUM")[1], 0})
aAdd(_aCampos, {"ITEM"   , "C", TamSX3("C6_ITEM")[1], 0})
aAdd(_aCampos, {"PRODUTO", "C", TamSX3("B1_COD")[1], 0})
aAdd(_aCampos, {"DESCRI" , "C", 50, 0})
aAdd(_aCampos, {"UM"     , "C", 02, 0})
aAdd(_aCampos, {"QUANT"  , "N", 12, 2})
aAdd(_aCampos, {"DTINI"  , "D", 08, 0})
aAdd(_aCampos, {"DTPREV" , "D", 08, 0})
aAdd(_aCampos, {"PROGR"  , "C", 06, 0})
aAdd(_aCampos, {"QTDORI" , "N", 12, 2})
aAdd(_aCampos, {"NIVEL"  , "N", 12, 0})
aAdd(_aCampos, {"ACONDIC", "C", 05, 0})

If Select("TRB1") > 0
	DbSelectArea("TRB1")
	DbCloseArea()
EndIf

_cNmArq1 := CriaTrab(_aCampos, .T.)
DbUseArea(.T.,, _cNmArq1, "TRB1", .F., .F.) // Abrir exclusivo

Private _cInd1 := CriaTrab(Nil, .F.)
IndRegua("TRB1", _cInd1, "PRODUTO+SEMANA",,, "Selecionando Registros...")
DbSetIndex(_cInd1 + OrdBagExt())

ValidPerg()
_lRefre := .F.
If !u_ParProg()
	DbSelectArea("TRB1")
	DbCloseArea("TRB1")
	Delete File (_cNmArq1 + ".DTC")
	Delete File (_cInd1 + OrdBagExt())
	Return(.T.)
EndIf
_lRefre := .T.

aAdd(aCampos, {"OK"     ,, "Ok","XX"})
aAdd(aCampos, {"PRODUTO",, "Produto",Replicate("X",TamSX3("B1_COD")[1])})
aAdd(aCampos, {"DESCRI" ,, "Descrição",Replicate("X",50)})
aAdd(aCampos, {"UM"     ,, "U.M.","XX"})
aAdd(aCampos, {"QUANT"  ,, "Quantidade","@E 99,999,999.99"})
aAdd(aCampos, {"SEMANA" ,, "Sem.Progr.","XXXXXX"})
aAdd(aCampos, {"NUM"    ,, "Num.OP.","XXXXXX"})
aAdd(aCampos, {"ITEM"   ,, "Item","XX"})
aAdd(aCampos, {"DTINI"  ,, "Dt.Inic.Prod."})
aAdd(aCampos, {"DTPREV" ,, "Dt.Prev.Prod."})
aAdd(aCampos, {"PROGR"  ,, "Nro.Progr.","XXXXXX"})
aAdd(aCampos, {"QTDORI" ,, "Qtd.Orig.","@E 99,999,999.99"})
aAdd(aCampos, {"ACONDIC",, "Num.OP.","XXXXX"})

l_Confirma := .F.

cCadastro:="Programação Produção - Resumos das Semanas: de " + Transform(Mv_PAR01,"@R 9999/99-9") + " a " + Transform(Mv_PAR02,"@R 9999/99-9")
aRotina := {{ "Parâmetros","u_ParProg()", 0 , 4},;
			{ "Confirma"  ,"u_GrvMar()" , 0 , 4}}

MarkBrow("TRB1","OK","PROGR",aCampos,lInverte,cMarca,"u_MrkAll()",,,,)

DbSelectArea("TRB1")
DbCloseArea("TRB1")
Delete File (_cNmArq1 + ".DTC")
Delete File (_cInd1 + OrdBagExt())
Return(.T.)
*
**************************
Static Function GravaMar() // OK
**************************
local aArea 	:= GetArea()
local aAreaSC2 	:= SC2->(GetArea())
local aAreaSC6 	:= SC6->(GetArea())

DbSelectArea("SC2")
DbSetOrder(1)// C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

DbSelectArea("SC6")
DBOrderNickName("SC6SEMANA")
//DbSetOrder(10)// C6_FILIAL+C6_SEMANA+C6_PRODUTO+C6_ACONDIC+ STRZERO(C6_METRAGE,5)

DbSelectArea("TRB1")
ProcRegua(RecCount())
TRB1->(DbGoTop())
Do While TRB1->(!Eof())
	IncProc()
	If TRB1->OK == "XX" // Foi selecionado
		DbSelectArea("SC2")
		If DbSeek(xFilial("SC2")+TRB1->NUM+TRB1->ITEM+"001",.F.)
			RecLock("SC2",.F.)
			SC2->C2_PROGR := _cProgr
			SC2->C2_DATPRF := TRB1->DTPREV
			MsUnLock()
			
			DbSelectArea("SC6")
			DbSeek(xFilial("SC6")+SC2->C2_SEMANA+SC2->C2_PRODUTO,.F.)
			Do While SC6->C6_FILIAL+SC6->C6_SEMANA+SC6->C6_PRODUTO == xFilial("SC6")+SC2->C2_SEMANA+SC2->C2_PRODUTO .And. SC6->(!Eof())
				RecLock("SC6",.F.)
				SC6->C6_DTPROGR := dDataBase
				//		SC6->C6_DTINI   := TRB1->DTINI
				//		SC6->C6_DTEPA   := TRB1->DTPREV --- esta data será gravada no retorno do PreActor
				MsUnLock()
				SC6->(DbSkip())
			EndDo
		EndIf
		// Deletar o TRB1
		RecLock("TRB1",.F.)
		DbDelete()
		MsUnLock()
	EndIf
	TRB1->(DbSkip())
EndDo
DbSelectArea("TRB1")
Pack

RestArea(aAreaSC2)
RestArea(aAreaSC6)
RestArea(aArea)
Return(.T.)
*
**********************
User Function GrvMar()        //* ok
**********************
*
// A função Marked não funciona se fechar a janela (oDLG1)
// por isso vou marcar com "XX" para que possa ser "vista" depois.
DbSelectArea("TRB1")
ProcRegua(RecCount())
TRB1->(DbGoTop())
Do While TRB1->(!Eof())
	IncProc()
	_Mck := If(Marked("OK"),"XX","  ")
	RecLock("TRB1",.F.)
	TRB1->OK := _Mck
	MsUnLock()
	TRB1->(DbSkip())
EndDo

_aInsumos := {} // {1-COMP    , 2-Descr.do comp.,3-UM            ,4-QUANT   , 5-LE      ,
//  6-LM      , 7-Qtd.Base      ,8-Maior Nivel   ,9-Grp.Opcional, 10-Recalcula Quantidade?,
//	11-Acondic

Processa({|| CalcPI()},"Calculando Quants. de Produtos Intermediários...")
aSort(_aInsumos,,,{ |x, y| x[08]+x[01] < y[08]+y[01]}) // Ordena por nível + Cód. Componente
If Len(_aInsumos) > 0
	// Recalcula Lotes desde o primeiro registro
	Processa({|| CalcLt(1)},"Calculando Lotes...")
EndIf

//
// Cria a Header e aCols
nUsado := 0
aHeader := {}

AADD(aHeader,{"Componente" ,"PRODUTO","@!"              ,TamSX3("B1_COD")[1],0,".F."         ,"","C","TRB1"} )
AADD(aHeader,{"Descric."   ,"DESCRI" ,"@!"              ,50,0,".F."                          ,"","C","TRB1"} )
AADD(aHeader,{"Unid.Med."  ,"UM"     ,"@!"              ,TamSX3("B1_UM")[1],0,".F."          ,"","C","TRB1"} )
AADD(aHeader,{"Quantidade" ,"QUANT"  ,"@E 99,999,999.99",10,2,"Positivo() .And. u_TrocaQtd()","","N","TRB1"} )
AADD(aHeader,{"Lt.Econom." ,"LOTEEC" ,"@E 999,999"      ,06,0,".F."                          ,"","N","TRB1"} )
AADD(aHeader,{"Lt.Minimo"  ,"LOTEMI" ,"@E 999,999"      ,06,0,".F."                          ,"","N","TRB1"} )
AADD(aHeader,{"Qtd.Base."  ,"BASE"   ,"@E 99,999,999.99",10,2,".F."                          ,"","N","TRB1"} )
AADD(aHeader,{"Nivel Estr.","NIVEL"  ,"@E 999"          ,03,0,".F."                          ,"","C","TRB1"} )
AADD(aHeader,{"Grp. Opc."  ,"OPCIO"  ,""                ,03,0,".F."                          ,"","C","TRB1"} )
AADD(aHeader,{"Acondic"  	,"ACONDIC","@!"             ,05,0,".F."                          ,"","C","TRB1"} )

aCols   := {}
For _nx := 1 to Len(_aInsumos)
	Aadd(aCols,Array(Len(aHeader)+1))
	aCols[_nx,01] := _aInsumos[_nx,01] // Componente
	aCols[_nx,02] := _aInsumos[_nx,02] // Descrição
	aCols[_nx,03] := _aInsumos[_nx,03] // Unid.Medida
	aCols[_nx,04] := _aInsumos[_nx,04] // Quantidade à Produzir
	aCols[_nx,05] := _aInsumos[_nx,05] // Lote economico
	aCols[_nx,06] := _aInsumos[_nx,06] // Lote minimo
	aCols[_nx,07] := _aInsumos[_nx,07] // Quant.Base pela Estrutura
	aCols[_nx,08] := _aInsumos[_nx,08] // Nível da estrutura
	aCols[_nx,09] := _aInsumos[_nx,09] // Nível da estrutura
	aCols[_nx,10] := .F.
Next
l_Confirma := .F.
If Len(aCols) == 0
	Alert("Não há Dados a Apresentar")
Else
	nUsado := Len(aHeader)+1
	
	DbSelectArea("TRB1")
	ntamacols := Len(aCols)
	@ 150,001 TO 650,950 DIALOG oDlg2 TITLE "Programação da Produção - Produtos Intermediários"
	//	@ 006,005 TO 220,470  MULTILINE MODIFY DELETE OBJECT oMultiline VALID u_Line3Ok()
	@ 006,005 TO 220,470  MULTILINE MODIFY OBJECT oMultiline
	@ 230,005 BMPBUTTON TYPE 01 ACTION Cria_oDlg2() // Ok
	@ 230,045 BMPBUTTON TYPE 02 ACTION Close(oDlg2) // Cancela
	omultiline:nmax:= ntamacols
	ACTIVATE DIALOG oDlg2 CENTERED
EndIf
If l_Confirma
	DbSelectArea("SX5")
	If !DbSeek(xFilial("SX5")+"00"+"Z2",.F.)
		RecLock("SX5",.T.)
		SX5->X5_FILIAL := xFilial("SX5")
		SX5->X5_TABELA := "00"
		SX5->X5_CHAVE  := "Z2"
		SX5->X5_DESCRI    := "Nro da proxima programacao"
		SX5->X5_DESCSPA   := "Nro da proxima programacao"
		SX5->X5_DESCENG   := "Nro da proxima programacao"
		MsUnLock()
	EndIf
	If !DbSeek(xFilial("SX5")+"Z2",.F.)
		RecLock("SX5",.T.)
		SX5->X5_FILIAL  := xFilial("SX5")
		SX5->X5_TABELA  := "Z2"
		SX5->X5_CHAVE   := "      "
		SX5->X5_DESCRI  := "000001"
		SX5->X5_DESCSPA := "000001"
		SX5->X5_DESCENG := "000001"
		MsUnLock()
	EndIf
	_cProgr := AllTrim(SX5->X5_DESCRI)
	RecLock("SX5",.F.)
	SX5->X5_DESCRI  := Soma1(_cProgr)
	SX5->X5_DESCSPA := SX5->X5_DESCRI
	SX5->X5_DESCENG := SX5->X5_DESCRI
	MsUnLock()
	
	// Grava os SC2 selecionados, deleta o TRB1 e dá um Pack
	Processa({|| GravaMar()},"Marcando Registros Selecionados...")
	
	// Cria as OPs dos Intermediários conforme as quantidades corrigidas
	Processa({|| CriaInter()},"Criando OP's Intermediárias...")
	
	Alert("Processo Concluído!!! Programação Nro " + _cProgr)
EndIf

Return(.T.)
*
***************************
Static Function CriaInter()
***************************
*
//Variaveis da u_novaOP
Private _NumOP
Private _AnoOP	:= StrZero(Year(dDataBase),4)
Private _SemOP	:= "ZZ"
Private _cAlmo	:= "99"
Private _dDtOp	:= dDataBase
Private _Obs  	:= ""
Private _cOpDel := "" // OPs a serem excluídas
Private _aInsuSG1 := {}
Private _aCriaPV := {} // {Código,Quantidade}


If (FWCodEmp()+FWCodFil()) # "0101" // Não sendo a matriz
	Private _cMVPrdInd := AllTrim(GetMv("MV_X_PRIND"))
Else
	Private _cMVPrdInd := ""
EndIf

_cItem := "01"

SB1->(DbSetOrder(1))
SC2->(DbSetOrder(1))

Do While SC2->(DbSeek(xFilial("SC2")+_AnoOP+_SemOP+"ZZ",.T.)) // Procuro a ultima OP Possivel com softseek em .T.
	// Se Achei, procuro no ano seguinte
	_AnoOP := Str(Val(_AnoOP) + 1,4)
EndDo
SC2->(DbSkip(-1))

_AnoOP	:= Left(SC2->C2_NUM,4)
_SemOP	:= Right(SC2->C2_NUM,2)
If _SemOP < "55"
	_SemOP := "55"
Else
	_cItem := SC2->C2_ITEM
EndIf

ProcRegua(Len(_aInsumos))

For nI:= 1 to Len(_aInsumos)
	IncProc()
	If _aInsumos[nI,4] <= 0
		Loop
	ElseIf ("/" + AllTrim(_aInsumos[nI,1]) + "/") $ _cMVPrdInd
		// Criar pedido para a matriz e não OP
		Aadd(_aCriaPV,{_aInsumos[nI,1],_aInsumos[nI,4]}) // {Código,Quantidade}  Aadd(_aCriaPV,{"Q1200403401",500})
		Loop
	EndIf


	// Calcula o Nro da próxima OP
	CalcNxtOP()
	
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1") + _aInsumos[nI,1],.F.))
	
	_Item   := _cItem
	_cSeq   := "001"
	_cProd	:= _aInsumos[nI,1]
	_nQtd 	:= _aInsumos[nI,4]
	_cOpc   := ""
	_cOpDel := "" // OPs Criadas indevidamente -> deletar posteriormente.
	
	If u_NovaOP("I",.F.,cTod(""),_cOpc,,.F.)//Cria OP Inclusao / não gera intermediarias
		DbSelectArea("SC2")
		DbSetOrder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
		DbSeek(xFilial("SC2")+_NumOP+_cItem,.F.)
		Do While SC2->C2_FILIAL == xFilial("SC2") .And. SC2->C2_NUM+SC2->C2_ITEM == _NumOP+_Item .And. SC2->(!Eof())
			RecLock("SC2",.F.)
			SC2->C2_PROGR	:= _cProgr
			SC2->C2_STATINT	:="A"
			SC2->C2_STATOP	:="L"
			SC2->C2_BATCH 	:="S"
			MsUnLock()
			SC2->(DbSkip())
		EndDo
	EndIf
Next

If Len(_aCriaPV) > 0
	DbSelectArea("SM0")
	DbSetOrder(1)
	
	_cMyNmEmp := cNumEmp
	_cMyFilAn := cFilAnt
	cNumEmp := Left("0101"+Space(30),Len(cNumEmp))  // crio o pedido na matriz
	cFilAnt := "01"

	DbSelectArea("SM0")
	DbSetOrder(1)
	SM0->(DbSeek(cNumEmp,.F.))
	
	DbSelectArea("SB1")
	DbSetOrder(1) // B1_FILIAL+B1_COD

	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

	DbSelectArea("SC5")
	DbSetOrder(1)
	
	cNumPed := GetSX8Num("SC5","C5_NUM") // Pega o próximo nro do pedido
	
	Do While SC5->(DbSeek(xFilial("SC5")+cNumPed,.F.))
		ConfirmSX8()
		cNumPed := GetSX8Num("SC5","C5_NUM") // Pega o próximo nro do pedido
		// Confirmar o SX8 somente no final
	EndDo

	aItens := {}

	For _nQtItens := 1 To Len(_aCriaPV)
		SB1->(DbSeek(xFilial("SB1") + _aCriaPV[_nQtItens,1],.F.))
		SB2->(DbSeek(xFilial("SB2") + SB1->B1_COD+SB1->B1_LOCPAD,.F.))
		_nValVen := SB2->B2_CM1
		If _nValVen <= 0       
			_nValVen := 1.00
		EndIf

		aItem := {	{"C6_NUM"	 , cNumPed				,Nil},; // Numero do Item no Pedido
					{"C6_ITEM"	 , StrZero(_nQtItens,2)	,Nil},; // Numero do Item no Pedido
					{"C6_PRODUTO", SB1->B1_COD			,Nil},; // Codigo do Produto
					{"C6_UM"	 , SB1->B1_UM			,Nil},; // Unidade de Medida Primar.
					{"C6_QTDVEN" , _aCriaPV[_nQtItens,2],Nil},; // Quantidade Vendida
					{"C6_QTDLIB" , _aCriaPV[_nQtItens,2],Nil},; // Quantidade Vendida
					{"C6_PRCVEN" , _nValVen				,Nil},; // Preco Venda
					{"C6_PRUNIT" , _nValVen				,Nil},; // Preco Unitario
					{"C6_VALOR"	 , Round(_aCriaPV[_nQtItens,2] * _nValVen,TamSX3("C6_VALOR")[2])	,Nil},; // Valor Total do Item 
					{"C6_TES"	 , "551"				,Nil},; // Tipo de Entrada/Saida do Item
					{"C6_LOCAL"	 , SB1->B1_LOCPAD		,Nil},; // Almoxarifado 
					{"C6_CLI"	 , "008918"				,Nil},; // Cliente
					{"C6_LOJA"	 , "01"					,Nil}} // Loja
		aAdd(aItens,aItem)
	Next
	
	aCabec := {	{"C5_NUM"			,cNumPed		,Nil},; // Numero do Pedido 
				{"C5_TIPO"			,"N"			,Nil},; // Tipo do Pedido
				{"C5_CLIENTE"		,"008918"		,Nil},; // Codigo do Cliente
				{"C5_LOJACLI"		,"01"			,Nil},; // Loja do Cliente
				{"C5_CLIENT"		,"008918"		,Nil},; // Codigo do Cliente para entrega
				{"C5_LOJAENT"		,"01"			,Nil},; // Loja para entrega
				{"C5_TIPOCLI"		,"R"			,Nil},; // Tipo do Cliente
				{"C5_CONDPAG"		,"263"			,Nil},; // Condicao de pgto
				{"C5_EMISSAO"		,dDatabase		,Nil},; // Data de Emissao
				{"C5_MOEDA"			,1				,Nil},;
				{"C5_TPFRETE"		,"S"			,Nil}} // Data de Emissao} // Moeda

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+"00891801",.F.)
	_cRisco := SA1->A1_RISCO
	RecLock("SA1",.F.)
	SA1->A1_RISCO:= "A"
	MsUnLock()

	lMsErroAuto := .F.

	//Executa a inclusão do PV
	LjMsgRun("Gerando Pedido de Venda " + AllTrim(cNumPed),,{||MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aItens, 3)})

	dbSelectArea("SA1")
	dbSetOrder(1)
	dbSeek(xFilial("SA1")+"00891801",.F.)
	RecLock("SA1",.F.)
	SA1->A1_RISCO:= _cRisco
	MsUnLock()

	If lMsErroAuto
		RollBackSX8()
		MostraErro()
	Else
		ConfirmSX8()
	EndIf
    
	// Volta para a filial correta	
	cNumEmp := _cMyNmEmp
	cFilAnt := _cMyFilAn

	DbSelectArea("SM0")
	DbSetOrder(1)
	SM0->(DbSeek(cNumEmp,.F.))
	
EndIf
Return(.T.)
*
***************************
Static Function ValidPerg()    //*ok
***************************
*
_aArea := GetArea()

DbSelectArea("SX1")
DbSetOrder(1)
cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

aRegs:={}
//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Da Semana AAAASS     ?","mv_ch1","C",07,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Até a Semana  AAAASS ?","mv_ch2","C",07,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"03","Seleciona Produtos   ?","mv_ch3","N",01,0,0,"C","","mv_par03","Sim","","","Não","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"04","Seleciona Bitolas    ?","mv_ch4","N",01,0,0,"C","","mv_par04","Sim","","","Não","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Dt.Inicio Producao   ?","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})

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
	Else
		RecLock("SX1",.F.)
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
		SX1->X1_DEF02   := aRegs[i,15]
		SX1->X1_DEF03   := aRegs[i,18]
		SX1->X1_DEF04   := aRegs[i,21]
		SX1->X1_DEF05   := aRegs[i,24]
		SX1->X1_F3      := aRegs[i,26]
		MsUnlock()
	Endif
	DbCommit()
Next
RestArea(_aArea)
Return(.T.)
*
**********************
User Function ParProg() //*ok
**********************
*
_Volta := .T.
Do While _Volta
	_Volta := Pergunte(cPerg,.T.)
	If _Volta .And. (MV_PAR01 > MV_PAR02)
		Alert("Corrigir Abrangência(s)")
		Loop
	EndIf
	If _Volta
		MV_PAR03 := If(MV_PAR03 == 1,u_Tipos("SZ1","Seleção de Produtos"),"*") // Seleciona Produtos
		If Empty(MV_PAR03)
			_Volta := .F.
		EndIf
		If _Volta
			MV_PAR04 := If(MV_PAR04 == 1,u_Tipos("SZ2","Seleção de Bitolas"),"*") // Seleciona Bitolas
			If Empty(MV_PAR04)
				_Volta := .F.
			EndIf
		EndIf
	EndIf
	Exit
EndDo
If _Volta
	DbSelectArea("TRB1")
	Processa({|| MontaTrab()},"Montando Arquivo de Trabalho...")
	DbSelectArea("TRB1")
	DbGoTop()
EndIf
Return(_Volta)
*
***************************
Static Function MontaTrab() //*ok
***************************
*
DbSelectArea("TRB1")
Zap

DbSelectArea("SC2")
DbSetOrder(1)  //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

ProcRegua(RecCount())

DbSeek(xFilial("SC2")+Left(Mv_Par01,6),.T.)
Do While SC2->C2_FILIAL == xFilial("SC2") .And. SC2->C2_NUM <= Left(MV_PAR02,6) .And. SC2->(!Eof())
	IncProc()
	//	If Empty(SC2->C2_PROGR) .And. SC2->C2_QUJE == 0 .And. SC2->C2_SEQUEN == "001" .And.;
	
	_lVai3   := (MV_PAR03 == "*" .Or. Left(SC2->C2_PRODUTO,3) $ MV_PAR03)		// Produto(s) Escolhido(s)
	_lVai4   := (MV_PAR04 == "*" .Or. Substr(SC2->C2_PRODUTO,4,2) $ MV_PAR04)	// Bitola(s) Escolhida(s)
	_nQtdSC2 := If(Empty(SC2->C2_DATRF).And.(SC2->C2_QUJE<SC2->C2_QUANT).And.SC2->C2_QUJE >= 0,(SC2->C2_QUANT-SC2->C2_QUJE),0)
	
	If Empty(SC2->C2_PROGR) .And. SC2->C2_SEQUEN == "001" .And.;
		SC2->C2_SEMANA >= MV_PAR01 .And. SC2->C2_SEMANA <= MV_PAR02 .And.;
		_lVai3 .And. _lVai4 .And. _nQtdSC2 > 0  .And. SC2->C2_STATOP # "P" // ATENÇÃO - NÃO PODE OPs planejadas
		
		_nPrazo := CalcPrazo(TRB1->PRODUTO,SC2->C2_QUANT)
		RecLock("TRB1",.T.)
		//	TRB1->OK      := cMarca
		TRB1->SEMANA  := SC2->C2_SEMANA
		TRB1->NUM     := SC2->C2_NUM
		TRB1->ITEM    := SC2->C2_ITEM
		TRB1->PRODUTO := SC2->C2_PRODUTO
		TRB1->DESCRI  := SC2->C2_DESCRI
		TRB1->UM      := SC2->C2_UM
		TRB1->QUANT   := _nQtdSC2 //SC2->C2_QUANT
		TRB1->QTDORI  := _nQtdSC2 //SC2->C2_QUANT
		TRB1->DTPREV  := MV_PAR05+_nPrazo
		
		DbSelectArea("SC6")
		If DbSeek(xFilial("SC6")+SC2->C2_SEMANA+SC2->C2_PRODUTO,.F.)
			While SC6->C6_FILIAL+SC6->C6_SEMANA+SC6->C6_PRODUTO == xFilial("SC6")+SC2->C2_SEMANA+SC2->C2_PRODUTO .And. SC6->(!Eof())
				TRB1->ACONDIC  := SC6->(C6_ACONDIC+STRZERO(C6_METRAGE,5))
				SC6->(DbSkip())
			EndDo
		Else
			TRB1->ACONDIC  := ""
		EndIf
		MsUnLock()
	EndIf
	DbSelectArea("SC2")
	SC2->(DbSkip())
EndDo
Return(.T.)
*
***********************
User Function MrkAll()  // ok
***********************
*
DbSelectArea("TRB1")
_RegAtu := Recno()
DbGoTop()
Do While !Eof()
	RecLock("TRB1",.F.)
	If TRB1->OK == cMarca
		TRB1->OK := " "
	Else
		TRB1->OK := cMarca
	EndIf
	MsUnLock()
	DbSkip()
EndDo
DbGoTo(_RegAtu)
Return(.t.)
*
************************
Static Function CalcPI()  //*OK
************************
*
PRIVATE nEstru := 0                                                                      
/*/
Estrutura da tabela TRB1
"OK"     , "C", 02, 0
"SEMANA" , "C", 07, 0
"NUM"    , "C", 06, 0
"ITEM"   , "C", 02, 0
"PRODUTO", "C", 15, 0
"DESCRI" , "C", 50, 0
"UM"     , "C", 02, 0
"QUANT"  , "N", 12, 2
"DTINI"  , "D", 08, 0
"DTPREV" , "D", 08, 0
"PROGR"  , "C", 06, 0
"QTDORI" , "N", 12, 2

Indice "PRODUTO+SEMANA"
/*/

DbSelectArea("SB1")
DbSetOrder(1)

DbSelectArea("SG1")
DbSetOrder(1)

_aInsumos := {} 

If (FWCodEmp()+FWCodFil()) # "0101" // Não sendo a matriz
	_cMVPrdInd := AllTrim(GetMv("MV_X_PRIND"))
Else
	_cMVPrdInd := ""
EndIf

DbSelectArea("TRB1")
ProcRegua(RecCount())
TRB1->(DbGoTop())
Do While TRB1->(!Eof())
	_cProdTRB1 := TRB1->PRODUTO
	_nQtdTRB1  := 0.00
	Do While TRB1->PRODUTO == _cProdTRB1 .And. TRB1->(!Eof())
		IncProc()
		If TRB1->OK == "XX" // Foi selecionado
			_nQtdTRB1 += TRB1->QUANT
		EndIf
		TRB1->(DbSkip())
	EndDo
	
	If _nQtdTRB1 > 0
		nEstru := 0
		_cNomeArq := u_cbcStrut2(_cProdTRB1,_nQtdTRB1,"ESTRUT",,.T.)
		_cNvlLxo2 := "      "
		DbSelectArea("ESTRUT")
		// Para apresentar na mesma forma que mostra na tela, tem que estar com ordem 0  (zero)
		// A Função Estrut2 cria o arquivo com um índice NIVEL+CODIGO+COMPONENTE+NIVEL
		DbSetOrder(0)             
		DbGoTop()
		Do While ESTRUT->(!Eof())

			// Alteração de 13/10/16... não criar OPs dos produtos abaixo em 3 Lagoas.
			// Soliticação Diretoria/Gerência em e-mail de 05/10/16 para Jeferson 15:13h
			// Tais produtos devem ser solicitados para Itu:
			// PE2060A - Corda 6mm2 classe 2;
			// Q120.04.03.4.01, Q120.05.03.4.01 e Q120.06.03.4.01 , Cabos paralelos de 1,5 a 4 mm2 branco
			//If (FWCodEmp()+FWCodFil()) == "0102" .And. AllTrim(ESTRUT->CODIGO) $ "PE2060A/'/Q1200403401/'/Q1200503401/'/Q1200603401"
			_CodEst  := "/" + AllTrim(ESTRUT->CODIGO) + "/"
			_lTrfMtz := ("/" + AllTrim(ESTRUT->COMP) + "/") $ _cMVPrdInd // "/PE2060A/Q1200403401/Q1200503401/Q1200603401/"
				// Usar o _CodEst desta forma porque (exemplo) o PA 1200403401 está contido na string
			If _CodEst $ _cMVPrdInd // "/PE2060A/Q1200403401/Q1200503401/Q1200603401/"
				// Como "CODIGO" este produto não interessa, nem os que estiverem abaixo dele
				_cNvlLxo2 := ESTRUT->NIVEL
			ElseIf !Empty(_cNvlLxo2) .And.  ESTRUT->NIVEL <= _cNvlLxo2
				_cNvlLxo2 := "      "
			EndIf

			If Empty(_cNvlLxo2) // Posso Usar este cara? Se vazio, SIM!
				_lOpc := .T.
				If !Empty(ESTRUT->GROPC)
					// Tem um Grupo de Opcionais
					_lOpc := Posicione("SGA",1,xFilial("SGA")+(ESTRUT->GROPC+ESTRUT->OPC),"GA_PADRAO") == "S"
				EndIf
		
				If !_lOpc
					// Se este opcional não for usado 
					// desprezo todos os niveis dessa estrutura inclusive o posicionado
					_cNvLixo := ESTRUT->NIVEL
					ESTRUT->(DbSkip())
					// Este DbSkip tem que estar aqui mesmo. 
					// Não colocar dentro do Loop senão ele mata o resto dos dados.
					Do While ESTRUT->NIVEL > _cNvLixo .And. ESTRUT->(!Eof())
						ESTRUT->(DbSkip())
					EndDo
					Loop
				EndIf
		
				SB1->(DbSeek(xFilial("SB1")+ESTRUT->COMP,.F.))
		
				If SB1->B1_TIPO # "MP" //  .And. _lOpc
					_nPosi := aScan(_aInsumos, {|x|x[1]==ESTRUT->COMP})				
		
					//_aInsumos -> 
					// {1-COMP    , 2-Descr.do comp.,3-UM            ,4-QUANT   , 5-LE      ,
					//  6-LM      , 7-Qtd.Base      ,8-Maior Nivel   ,9-Grp.Opcional, 10-Recalcula Quantidade?
					//	11-Acondic
					
					If _nPosi == 0
						AADD(_aInsumos,{ESTRUT->COMP ,;
										AllTrim(SB1->B1_DESC) + If(_lTrfMtz," (Solic. da Matriz)","") ,;
										SB1->B1_UM   ,;
										0.00         ,;
										If(FWCodFil()=="01",SB1->B1_LE,SB1->B1_LE3L),;
										If(FWCodFil()=="01",SB1->B1_LM,SB1->B1_LM3L),;
										0.00         ,;
										"   ",;
										ESTRUT->GROPC+ESTRUT->OPC,;
										"S",;
										})
						_nPosi := Len(_aInsumos)
					EndIf
					// Adiciona somente se o nível for 1
					If Val(ESTRUT->NIVEL) == 1
						//_aInsumos[_nPosi,04] += ESTRUT->QUANT // Quantidade a produzir
						_aInsumos[_nPosi,07] += ESTRUT->QUANT // Quantidade Original pela estrutura
					EndIf
					If Val(ESTRUT->NIVEL)  > Val(_aInsumos[_nPosi,08])
						_aInsumos[_nPosi,08] := StrZero(Val(ESTRUT->NIVEL),3)
					EndIf
				EndIf
			EndIf
			ESTRUT->(DbSkip())
		EndDo
		FIMESTRUT2("ESTRUT")
		DbCloseArea("ESTRUT")
	EndIf
EndDo              
Return(.T.)
*
****************************
Static Function Cria_oDlg2()
****************************
*
l_Confirma := .T.
Close(oDlg2)
Return(.T.)
*
************************
User Function TrocaQtd()
************************
*
If M->QUANT # aCols[n,04] // Trocou a Quantidade
	_aArea := GetArea()
	CalcQtd(n,.T.)
	Processa({|| CalcLt(n+1)},"Calculando Lotes...")
	RestArea(_aArea)
	// Refazer o aCols
	aCols   := {}
	For _nx := 1 to Len(_aInsumos)
		Aadd(aCols,Array(Len(aHeader)+1))
		aCols[_nx,01] := _aInsumos[_nx,01] // Componente
		aCols[_nx,02] := _aInsumos[_nx,02] // Descrição
		aCols[_nx,03] := _aInsumos[_nx,03] // Unid.Medida
		aCols[_nx,04] := _aInsumos[_nx,04] // Quantidade à Produzir
		aCols[_nx,05] := _aInsumos[_nx,05] // Lote economico
		aCols[_nx,06] := _aInsumos[_nx,06] // Lote minimo
		aCols[_nx,07] := _aInsumos[_nx,07] // Quant.Base pela Estrutura
		aCols[_nx,08] := _aInsumos[_nx,08] // Nível da estrutura
		aCols[_nx,09] := _aInsumos[_nx,09] // Nível da estrutura
		aCols[_nx,10] := .F.
	Next
EndIf
Return(.T.)
*
******************************
Static Function CalcLt(_nInic)
******************************
*
Local _nN
ProcRegua(Len(_aInsumos)-_nInic+1)
For _nN := _nInic To Len(_aInsumos)
	// Calcular a necessidade pelo [5]Lote Econômico ou [6]Lote Minimo ou [4]Quantidade # [7]Ult.Quant.Calculada
	IncProc()
	_nQtdCal := _aInsumos[_nN,7]
	If _aInsumos[_nN,5] > 0 .Or. _aInsumos[_nN,6] > 0
		// Calcular quantidade lote
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+_aInsumos[_nN,1],.F.)
		_nQtdLot := CalcLote(_aInsumos[_nN,1],_aInsumos[_nN,7],"F")
		//_nQtdLot := Calclote(_cCodPrd,(_nBasLin-_nQtdSB2),"F")
		// Parâmetros da CalcLote
		//		ExpC1 = Produto a ser pesquisado
		//		ExpN1 = Necessidade de Producao
		//		ExpC2 = "C" - Comprado ou "F" - Fabricado
		If Type("_nQtdLot")== "N"
			_nQtdCal := _nQtdLot
		ElseIf Type("_nQtdLot")== "A"
			_nQtdCal := 0
			For _nLt := 1 to Len(_nQtdLot)
				_nQtdCal += _nQtdLot[_nLt]
			Next
		EndIf
	EndIf
	_aInsumos[_nN,4] := _nQtdCal
	CalcQtd(_nN,.F.)
Next
Return(.T.)
*
***********************************
Static Function CalcQtd(_nN,lNaQtd)
***********************************
*
Local _nN
DbSelectArea("SGA") // Grupo de Opcionais
DbSetOrder(1) // GA_FILIAL+GA_GROPC+GA_OPC

//For _nN := _nN To Len(_aInsumos)
If lNaQtd // Digitou na quantidade?
	_aInsumos[_nN,4] := Max(M->QUANT,0)
	_aInsumos[_nN,7] := Max(M->QUANT,0)
	If _aInsumos[_nN,5] > 0 .Or. _aInsumos[_nN,6] > 0 .And. _aInsumos[_nN,4] > 0
		// Calcular quantidade lote
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+_aInsumos[_nN,1],.F.)
		_nQtdLot := CalcLote(_aInsumos[_nN,1],_aInsumos[_nN,7],"F")
		//_nQtdLot := Calclote(_cCodPrd,(_nBasLin-_nQtdSB2),"F")
		// Parâmetros da CalcLote
		//		ExpC1 = Produto a ser pesquisado
		//		ExpN1 = Necessidade de Producao
		//		ExpC2 = "C" - Comprado ou "F" - Fabricado
		If Type("_nQtdLot")== "N"
			_nQtdCal := _nQtdLot
		ElseIf Type("_nQtdLot")== "A"
			_nQtdCal := 0
			For _nLt := 1 to Len(_nQtdLot)
				_nQtdCal += _nQtdLot[_nLt]
			Next
		EndIf
		_aInsumos[_nN,4] := _nQtdCal
	EndIf
EndIf
_nQtdLin := _aInsumos[_nN,4]

_nProdLin := _aInsumos[_nN,1]
nEstru := 0
_cNomeArq := u_cbcStrut2(_nProdLin,_nQtdLin,"ESTRUT",,.T.)
DbSelectArea("ESTRUT")
// Para apresentar na mesma forma que mostra na tela, tem que estar com ordem 0  (zero)
// A Função Estrut2 cria o arquivo com um índice NIVEL+CODIGO+COMPONENTE+NIVEL
DbSetOrder(0)
DbGoTop()
Do While ESTRUT->(!Eof())
	// Verificar o Grupo de Opcionais
	_lOpc := .T.
	If !Empty(ESTRUT->GROPC)
		// Tem um Grupo de Opcionais
		_lOpc := Posicione("SGA",1,xFilial("SGA")+(ESTRUT->GROPC+ESTRUT->OPC),"GA_PADRAO") == "S"
	EndIf
	
	If !_lOpc
		// Se este opcional não for usado
		// desprezo todos os niveis dessa estrutura inclusive o posicionado
		_cNvLixo := ESTRUT->NIVEL
		ESTRUT->(DbSkip())
		Do While ESTRUT->NIVEL > _cNvLixo .And. ESTRUT->(!Eof())
			ESTRUT->(DbSkip())
		EndDo
		Loop
	EndIf
	
	SB1->(DbSeek(xFilial("SB1")+ESTRUT->COMP,.F.))
	If SB1->B1_TIPO # "MP"
		_nPosi := aScan(_aInsumos, {|x|x[1]==ESTRUT->COMP})
		If _nPosi > 0
			If Val(ESTRUT->NIVEL) == 1
				_aInsumos[_nPosi,04] := 0
				_aInsumos[_nPosi,07] := ESTRUT->QUANT
			Else
				_aInsumos[_nPosi,04] := 0
				_aInsumos[_nPosi,07] := 0
			EndIf
			_aInsumos[_nPosi,08] := StrZero(Max(Val(_aInsumos[_nPosi,08]),Val(ESTRUT->NIVEL)),3)
		EndIf
	EndIf
	ESTRUT->(DbSkip())
EndDo
//DbSelectArea("ESTRUT")
// Zap
FIMESTRUT2("ESTRUT")
DbCloseArea("ESTRUT")
// _cNomeArq := _cNomeArq + ".*"
// DELETE FILE &_cNomeArq.
//Next
Return(.T.)
*
***************************
Static Function CalcNxtOP()
***************************
*
SC2->(DbSetOrder(1)) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
Do While SC2->(DbSeek(xFilial("SC2")+_AnoOP+_SemOP+_cItem,.F.)) .Or. "OS" $ Upper(_cItem) // Não pode ter item "OS", o sisteme pensa que é manut.Ativo.
	If _cItem == "ZZ"
		If _SemOP == "ZZ"
			_AnoOP := Str(Val(_AnoOP) + 1,4)
			_SemOP := "55"
		Else
			_SemOP := Soma1(_SemOP,,.F.) // .F. = Não inclui minusculas
		EndIf
		_cItem := "01"
	Else
		_cItem := Soma1(_cItem,,.F.) // .F. = Não inclui minusculas
	EndIf
EndDo
_NumOP := _AnoOP+_SemOP
Return(_NumOP)
*
***********************
User Function MtCalcL()
***********************
*
/*/
Esta função tem a finalidade de alteração das quantidades a serem calculados os lotes a serem produzidos.
É um ponto de entrada da função CalcLote()

Descrição:
Esse ponto de entrada será disparado na função calclote e permite que seja
alterado o valor dos campos utilizados para cálculo de necessidade.O conteúdo dos campos
utilizados está disponível através de variáveis private cujo conteúdo pode ser alterado;
são elas:
nB1_LM - Conteúdo do campo B1_LM (Lote Mínimo)
nB1_QE - Conteúdo do campo B1_QE (Quantidade por Embalagem)
nB1_LE - Conteúdo do campo B1_LE (Lote Econômico)
nB1_TOLER - Conteúdo do campo B1_TOLER (Tolerância)

Se as variáveis forem alteradas para um valor diferente de numérico,
o sistema assumirá o valor padrão de cada campo.

cMV_Quebra (a partir da versão 710) permite controlar se o retorno será em lotes
(cada um com 1 lote econômico) ou em um só lote.
/*/

If FWCodFil() == "01" //Itu
	nB1_LM 		:= SB1->B1_LM		// (Lote Mínimo)
	nB1_QE 		:= SB1->B1_QE		// (Quantidade por Embalagem)
	nB1_LE 		:= SB1->B1_LE		// (Lote Econômico)
	nB1_TOLER	:= SB1->B1_TOLER	// (Tolerância)
Else // 3 Lagoas
	nB1_LM 		:= SB1->B1_LM3L		// (Lote Mínimo)
	nB1_QE 		:= SB1->B1_QE3L		// (Quantidade por Embalagem)
	nB1_LE 		:= SB1->B1_LE3L		// (Lote Econômico)
	nB1_TOLER	:= SB1->B1_TOLER3L	// (Tolerância)
Endif
nQtdNeces	:= ParamIxb[3]			// Retornar sempre ParamIxb[3]. Se não retornar o PE calcula com 0 (zero).
Return(.T.)
