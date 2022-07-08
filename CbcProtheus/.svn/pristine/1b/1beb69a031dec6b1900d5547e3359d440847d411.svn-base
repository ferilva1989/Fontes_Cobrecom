#include "rwmake.ch"
#include "topconn.ch"

//#include "protheus.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CARGAS                             Modulo : SIGAEST      //
//                                                                          //
//                                                    Data ..: 30/08/2016   //
//                                                                          //
//   Objetivo ...: Manutenção da tabela ZZR Log.das Ordens de Separação.    //
//                 para montagem de cargas.                                 //
//                                                                          //
//                 Só é permitida a montagem da carga de itens que ainda    //
//                 não tenha sido montado carga, independentemente se ter   //
//                 ou não sido faturado ou montado volumes.                 //
//                 Esta aglutinar itens iguais quanto ao acondicionamento   //
//                 dando resumo da quantidade de fardos, carretéis, bobi-   //
//                 nas tipos 1,2,3,4,5,6 e 7, Pallets, caixas e rolos.      //
//                                                                          //
//   Uso ........: Especifico da Cobrecom                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
*
**********************
User Function Cargas()
**********************
*

cCadastro := "Montagem de Cargas"

aCores    := {{"!Empty(ZZR_CARGA)","DISABLE"   },;
			  {"Empty(ZZR_CARGA)","ENABLE"   }}

/*/
aRotina := {{ "Pesquisar"          , "AxPesqui"    ,0,4},;
		    { "Visualizar"         , "AxVisual"    ,0,2},;
		    { "Incluir"            , "u_MontaCar()",0,2},;
		    { "Legenda"            , "U_CARGALEG"  ,0,2}}
/*/		    

aRotina := {{ "Pesquisar"   , "AxPesqui"       , 0 , 1	},;
			{ "Visualizar"  , "u_MontaCar('V')", 0 , 2	},;
			{ "Incluir"     , "u_MontaCar('I')", 0 , 3	},;
			{ "Excluir"     , "u_MontaCar('E')", 0 , 4	},;
		    { "Legenda"     , "u_CARGALEG()"   , 0 , 2  }}

DbSelectArea("ZZR")
DbSetOrder(1) 
DbSeek(xFilial("ZZR"),.F.)

mBrowse(001,040,200,390,"ZZR",,,,,,aCores)
Return(.T.)
*
************************
User Function CARGALEG() // ok
************************
*

BrwLegenda(cCadastro,"Legenda",{{"DISABLE"    ,"Carga Já Montada"},;
								{"ENABLE"     ,"Carga a Montar"}})
Return(.T.)
*
*****************************
User Function MontaCar(_cRot)
*****************************
*     
Private aCols
aAltEnchoice :={}

_ZZRArea := GetArea()
Private _nFARDOS := 0
Private _nCARRE := 0
Private _nB1 := 0.00
Private _nB2 := 0.00
Private _nB3 := 0.00
Private _nB4 := 0.00
Private _nB5 := 0.00
Private _nB6 := 0.00
Private _nB7 := 0.00
Private _nPALLET := 0
Private _nCAIXA := 0
Private _nROLOS := 0
Private _nPLIQ := 0.00
Private _nPBRUT := 0.00

If _cRot $ "VE" // VISUALIZAR ou EXCLUIR
	If Empty(ZZR->ZZR_CARGA)
		Alert("Posicione em Uma Carga Válida")
		Return(.F.)
	ElseIf ZZR->ZZR_SITUADA == "9"
		Alert("Ordem de Separação Cancelada")
		Return(.F.)
	EndIf
EndIf

If _cRot == "E" // EXCLUIR
	If ZZR->ZZR_SITUADA == "3"
		Alert("Carregamento já Efetuado")
		Return(.F.)
	ElseIf ZZR->ZZR_SITUADA == "4"
		Alert("Carregamento Já Expedido")
		Return(.F.)
	EndIf
EndIf 
/*/
If _cRot == "V" //VISUALIZAR 
	nOpcE:=2
	nOpcG:=2
ElseIf _cRot == "I" //INCLUIR
	nOpcE:=3
	nOpcG:=3
ElseIf _cRot == "E" //EXCLUIR
	nOpcE:=2
	nOpcG:=2
EndIf 
/*/
nOpcE:=2
nOpcG:=2
aHeader:={}
aAdd(aHeader,{"Nro Pedido"  ,"NUMPV"  ,"XXXXXX"      , 6,0,.F.,,"C",,"R"})	
aAdd(aHeader,{"Sequência"   ,"SEQUEN" ,"XX"          , 2,0,.F.,,"C",,"R"})	
aAdd(aHeader,{"Nome Cliente","NOMECLI",Repl("X",30)  ,30,0,.F.,,"C",,"R"})	
aAdd(aHeader,{"Situação"    ,"SITUACA",Repl("X",22)  ,22,0,.F.,,"C",,"R"})
aAdd(aHeader,{"Fardos"      ,"FARDOS" ,"@E 99,999"   , 5,0,.T.,,"N",,"R"})
aAdd(aHeader,{"Carretéis"   ,"CARRE"  ,"@E 9,999"    , 4,0,.T.,,"N",,"R"})
aAdd(aHeader,{"Bob.B1"      ,"B1"     ,"@E 9,999"    , 4,0,.T.,,"N",,"R"})
aAdd(aHeader,{"Bob.B2"      ,"B2"     ,"@E 9,999"    , 4,0,.T.,,"N",,"R"})
aAdd(aHeader,{"Bob.B3"      ,"B3"     ,"@E 9,999"    , 4,0,.T.,,"N",,"R"})
aAdd(aHeader,{"Bob.B4"      ,"B4"     ,"@E 9,999"    , 4,0,.T.,,"N",,"R"})
aAdd(aHeader,{"Bob.B5"      ,"B5"     ,"@E 9,999"    , 4,0,.T.,,"N",,"R"})
aAdd(aHeader,{"Bob.B6"      ,"B6"     ,"@E 9,999"    , 4,0,.T.,,"N",,"R"})
aAdd(aHeader,{"Bob.B7"      ,"B7"     ,"@E 9,999"    , 4,0,.T.,,"N",,"R"})
aAdd(aHeader,{"Pallets"     ,"PALLET" ,"@E 999"      , 3,0,.T.,,"N",,"R"})
aAdd(aHeader,{"Caixas"      ,"CAIXA"  ,"@E 99,999"   , 5,0,.T.,,"N",,"R"})
aAdd(aHeader,{"Rolos"       ,"ROLOS"  ,"@E 99,999"   , 5,0,.T.,,"N",,"R"})
aAdd(aHeader,{"Peso Liq."   ,"PLIQ"   ,"@E 99,999.99", 8,2,.T.,,"N",,"R"})
aAdd(aHeader,{"Peso Bruto"  ,"PBRUT"  ,"@E 99,999.99", 8,2,.T.,,"N",,"R"})

nUsado:=Len(aHeader)

aCols := {}

cQuery := "SELECT ZZR_FILIAL, ZZR_PEDIDO, ZZR_SEQOS, ZZR_ITEMPV, ZZR_SEQUEN, ZZR_LOCALI, ZZR_BARINT, ZZR_QTCAIX, ZZR_NROBOB,"
cQuery += "	SUM(ZZR_QUAN) ZZR_QUAN, SUM(ZZR_LANCES) ZZR_LANCES, SUM(ZZR_EMBALA) ZZR_EMBALA, SUM(ZZR_PESPRO) ZZR_PESPRO,"

cQuery += "		ISNULL((SELECT SUM(ZZO_QUANT) "
cQuery += "		FROM "+RetSqlName("ZZO") + " ZZO_A"
cQuery += "		WHERE ZZO_A.ZZO_FILIAL = '"+xFilial("ZZO")+"'"
cQuery += "		AND ZZO_A.ZZO_PEDIDO   = ZZR_PEDIDO"
cQuery += "		AND ZZO_A.ZZO_SEQOS    = ZZR_SEQOS"
cQuery += "		AND ZZO_A.ZZO_ITEMPV   = ZZR_ITEMPV"
cQuery += "		AND ZZO_A.ZZO_SEQUEN   = ZZR_SEQUEN"
cQuery += "		AND ZZO_A.ZZO_LOCALI   = ZZR_LOCALI"
cQuery += "		AND ZZO_A.ZZO_STATUS   in ('01')"  // 0=Não Conferido;1=Conferido;2=Carregado;3-Expedido
cQuery += "		AND ZZO_A.ZZO_VOLDES   = '  '" // Volume válido. Se preenchido este volume não vale.
cQuery += "		AND ZZO_A.ZZO_TIPO     <> 'A'" // Aberto/Fechado,Sacos
cQuery += "		AND ZZO_A.D_E_L_E_T_   = ''),0) ZZO_QUANT," // Quantidade em metros de volumes fechados e sacos

cQuery += "		ISNULL((SELECT SUM(ZZO_LANCES)"
cQuery += "		FROM "+RetSqlName("ZZO") + " ZZO_B"
cQuery += "		WHERE ZZO_B.ZZO_FILIAL = '"+xFilial("ZZO")+"'"
cQuery += "		AND ZZO_B.ZZO_PEDIDO   = ZZR_PEDIDO"
cQuery += "		AND ZZO_B.ZZO_SEQOS    = ZZR_SEQOS"
cQuery += "		AND ZZO_B.ZZO_ITEMPV   = ZZR_ITEMPV"
cQuery += "		AND ZZO_B.ZZO_SEQUEN   = ZZR_SEQUEN"
cQuery += "		AND ZZO_B.ZZO_LOCALI   = ZZR_LOCALI"
cQuery += "		AND ZZO_B.ZZO_STATUS   in ('01')"  // 0=Não Conferido;1=Conferido;2=Carregado;3-Expedido
cQuery += "		AND ZZO_B.ZZO_VOLDES   = '  '"  // Volume válido. Se preenchido este volume não vale.
cQuery += "		AND ZZO_B.ZZO_TIPO     <> 'A'"  // Aberto/Fechado,Sacos
cQuery += "		AND ZZO_B.D_E_L_E_T_   = ''),0) ZZO_LANCES," // Quantidade em lances de volumes fechados ou em sacos

cQuery += "		ISNULL((SELECT SUM(ZZO_QUANT) "
cQuery += "		FROM "+RetSqlName("ZZO") + " ZZO_C"
cQuery += "		WHERE ZZO_C.ZZO_FILIAL = '"+xFilial("ZZO")+"'"
cQuery += "		AND ZZO_C.ZZO_PEDIDO   = ZZR_PEDIDO"
cQuery += "		AND ZZO_C.ZZO_SEQOS    = ZZR_SEQOS"
cQuery += "		AND ZZO_C.ZZO_ITEMPV   = ZZR_ITEMPV"
cQuery += "		AND ZZO_C.ZZO_SEQUEN   = ZZR_SEQUEN"
cQuery += "		AND ZZO_C.ZZO_LOCALI   = ZZR_LOCALI"
cQuery += "		AND ZZO_C.ZZO_STATUS   in ('01')"  // 0=Não Conferido;1=Conferido;2=Carregado;3-Expedido
cQuery += "		AND ZZO_C.ZZO_VOLDES   = '  '" // Volume válido. Se preenchido este volume não vale.
cQuery += "		AND ZZO_C.ZZO_TIPO     = 'A'" // Aberto/Fechado,Sacos
cQuery += "		AND ZZO_C.D_E_L_E_T_   = ''),0) ZZO_QUANT_A," // Quantidade em metros de volumes abertos

cQuery += "		ISNULL((SELECT SUM(ZZO_LANCES)"
cQuery += "		FROM "+RetSqlName("ZZO") + " ZZO_D"
cQuery += "		WHERE ZZO_D.ZZO_FILIAL = '"+xFilial("ZZO")+"'"
cQuery += "		AND ZZO_D.ZZO_PEDIDO   = ZZR_PEDIDO"
cQuery += "		AND ZZO_D.ZZO_SEQOS    = ZZR_SEQOS"
cQuery += "		AND ZZO_D.ZZO_ITEMPV   = ZZR_ITEMPV"
cQuery += "		AND ZZO_D.ZZO_SEQUEN   = ZZR_SEQUEN"
cQuery += "		AND ZZO_D.ZZO_LOCALI   = ZZR_LOCALI"
cQuery += "		AND ZZO_D.ZZO_STATUS   in ('01')"  // 0=Não Conferido;1=Conferido;2=Carregado;3-Expedido
cQuery += "		AND ZZO_D.ZZO_VOLDES   = '  '" // Volume válido. Se preenchido este volume não vale.
cQuery += "		AND ZZO_D.ZZO_TIPO     = 'A'"  // Aberto/Fechado,Sacos
cQuery += "		AND ZZO_D.D_E_L_E_T_   = ''),0) ZZO_LANCES_A" // Quantidade em landes de volumes abertos

cQuery += " FROM "+RetSqlName("ZZR") + " ZZR"
cQuery += " WHERE ZZR_FILIAL = '"+xFilial("ZZR")+"'"
cQuery += " AND ZZR_SITUAC <> '9'" // 1-Em Montagem 2-Montados, 3-Carregado, 4-Expedido, 9-Cancelado

If _cRot == "I" //INCLUIR
	cQuery += " AND ZZR_CARGA = '      '" // Sem estar em qualquer carga.
Else //VISUALIZAR  ou EXCLUIR
	cQuery += " AND ZZR_CARGA = '"+ ZZR->ZZR_CARGA +"'" // Tem estar em uma carga valida.
	cQuery += " AND ZZR_CARGA <>'      '" 
	cQuery += " AND ZZR_SITUAC in ('1','2')" // 1-Em Montagem 2-Montados 9-Cancelados
EndIf 

cQuery += " AND ZZR.D_E_L_E_T_ = ''"
cQuery += " GROUP BY ZZR_FILIAL, ZZR_PEDIDO, ZZR_SEQOS, ZZR_ITEMPV, ZZR_SEQUEN, ZZR_LOCALI, ZZR_BARINT, ZZR_QTCAIX, ZZR_NROBOB"
cQuery += " ORDER BY ZZR_FILIAL, ZZR_PEDIDO, ZZR_SEQOS, ZZR_ITEMPV, ZZR_SEQUEN, ZZR_LOCALI, ZZR_BARINT, ZZR_QTCAIX, ZZR_NROBOB"

cQuery := ChangeQuery(cQuery)

If Select("TB_ZZR")>0    
	TB_ZZR->(dbcloseArea())
	FErase( "TB_ZZR" + GetDbExtension())
EndIf

TCQUERY cQuery NEW ALIAS "TB_ZZR"

DbSelectArea("ZZO") // Volumes das O.S.
DbSetOrder(1) // ZZO_FILIAL+ZZO_PEDIDO+ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN+ZZO_LOCALI
_cNumVol := ""

DbSelectArea("TB_ZZR")
TB_ZZR->(DbGotop())
Do While TB_ZZR->(!Eof())
	_nTotLcVol := (TB_ZZR->ZZO_LANCES+TB_ZZR->ZZO_LANCES_A)
	If TB_ZZR->ZZR_LANCES > _nTotLcVol // Ainda tem lances não peletizados
		// Verificar se já tem algum aCols para o mesmo PEDIDO/SEQUENCIA
		_nPos   := aScan(aCols,{|x| x[1] == TB_ZZR->ZZR_PEDIDO .And. x[2] == TB_ZZR->ZZR_SEQOS})
		If _nPos == 0
			aAdd(aCols,Array(nUsado+1))
			aCols[Len(aCols),nUsado+1]:=.T. // Nasce deletado... falta montar volumes
			_nPos := Len(aCols)
			GDFieldPut("NUMPV"  ,TB_ZZR->ZZR_PEDIDO ,_nPos)
			GDFieldPut("SEQUEN" ,TB_ZZR->ZZR_SEQOS,_nPos)
			GDFieldPut("NOMECLI",Posicione("SA1",1,xFilial("SA1")+;
								 Posicione("SC5",1,xFilial("SC5")+TB_ZZR->ZZR_PEDIDO,"C5_CLIENTE+C5_LOJACLI");
								 ,"A1_NOME");
						,_nPos)
			GDFieldPut("FARDOS",0,_nPos)
			GDFieldPut("CARRE",0,_nPos)
			GDFieldPut("B1"   ,0,_nPos)
			GDFieldPut("B2"   ,0,_nPos)
			GDFieldPut("B3"   ,0,_nPos)
			GDFieldPut("B4"   ,0,_nPos)
			GDFieldPut("B5"   ,0,_nPos)
			GDFieldPut("B6"   ,0,_nPos)
			GDFieldPut("B7"   ,0,_nPos)
			GDFieldPut("PALLET",0,_nPos)
			GDFieldPut("CAIXA",0,_nPos)
			GDFieldPut("ROLOS",0,_nPos)
			GDFieldPut("PLIQ" ,0.00,_nPos)
			GDFieldPut("PBRUT",0.00,_nPos)
		EndIf
		_cLocali := Left(TB_ZZR->ZZR_LOCALI,1)
		GDFieldPut("SITUACA","3-Falta Montar Volumes",_nPos)
		If _cLocali $ "CM"
			GDFieldPut("CARRE"  ,GDFieldGet("CARRE",_nPos)+(TB_ZZR->ZZR_LANCES - _nTotLcVol),_nPos)
		ElseIf _cLocali == "B"
			_cTpBob := Posicione("SZE",1,xFilial("SZE")+TB_ZZR->ZZR_NROBOB,"ZE_TPBOB")
			If _cTpBob == "1"
				GDFieldPut("B1",GDFieldGet("B1",_nPos)+1,_nPos)
			ElseIf _cTpBob == "2"
				GDFieldPut("B2",GDFieldGet("B2",_nPos)+1,_nPos)
			ElseIf _cTpBob == "3"
				GDFieldPut("B3",GDFieldGet("B3",_nPos)+1,_nPos)
			ElseIf _cTpBob == "4"
				GDFieldPut("B4",GDFieldGet("B4",_nPos)+1,_nPos)
			ElseIf _cTpBob == "5"
				GDFieldPut("B5",GDFieldGet("B5",_nPos)+1,_nPos)
			ElseIf _cTpBob == "6"
				GDFieldPut("B6",GDFieldGet("B6",_nPos)+1,_nPos)
			ElseIf _cTpBob == "7"
				GDFieldPut("B7",GDFieldGet("B7",_nPos)+1,_nPos)
			EndIf
		ElseIf _cLocali == "L"
			GDFieldPut("CAIXA"  ,GDFieldGet("CAIXA",_nPos)+((TB_ZZR->ZZR_LANCES-_nTotLcVol) / TB_ZZR->ZZR_QTCAIX),_nPos)
		ElseIf _cLocali $ "RT"
			GDFieldPut("ROLOS"  ,GDFieldGet("ROLOS",_nPos)+(TB_ZZR->ZZR_LANCES - _nTotLcVol),_nPos)
		EndIf
		GDFieldPut("PLIQ",GDFieldGet("PLIQ",_nPos)+;
					(((TB_ZZR->ZZR_EMBALA+TB_ZZR->ZZR_PESPRO) / TB_ZZR->ZZR_LANCES) * ;
					  (TB_ZZR->ZZR_LANCES-_nTotLcVol)),;
					_nPos)
		GDFieldPut("PBRUT",GDFieldGet("PBRUT",_nPos)+;
					(((TB_ZZR->ZZR_EMBALA+TB_ZZR->ZZR_PESPRO) / TB_ZZR->ZZR_LANCES) * ;
					  (TB_ZZR->ZZR_LANCES-_nTotLcVol)),;
					_nPos)
	EndIf
	
	DbSelectArea("ZZO") // Volumes das O.S.
	DbSetOrder(1) // ZZO_FILIAL+ZZO_PEDIDO+ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN+ZZO_LOCALI
	DbSeek(xFilial("ZZO")+TB_ZZR->ZZR_PEDIDO+TB_ZZR->ZZR_SEQOS+TB_ZZR->ZZR_ITEMPV+TB_ZZR->ZZR_SEQUEN+TB_ZZR->ZZR_LOCALI,.F.)
	
	Do While ZZO->ZZO_FILIAL == xFilial("ZZO") .And. ZZO->(!Eof()) .And.;
			   ZZO->(ZZO_PEDIDO+ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN+ZZO_LOCALI) == ;
			TB_ZZR->(ZZR_PEDIDO+ZZR_SEQOS+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_LOCALI)

		If !(ZZO->ZZO_NUMVOL $ _cNumVol) 
			_nPos := aScan(aCols,{|x| x[1]==ZZO->ZZO_PEDIDO .And. x[2]==ZZO->ZZO_SEQOS})
			If ZZO->ZZO_TIPO $ "FS" // Fechado ou saco
				_cNumVol += "/" + ZZO->ZZO_NUMVOL
				If _nPos == 0
					aAdd(aCols,Array(nUsado+1))
					aCols[Len(aCols),nUsado+1]:=.F.
					_nPos := Len(aCols)
					GDFieldPut("NUMPV"  ,ZZO->ZZO_PEDIDO,_nPos)
					GDFieldPut("SEQUEN" ,ZZO->ZZO_SEQOS ,_nPos)
					GDFieldPut("NOMECLI",Posicione("SA1",1,xFilial("SA1")+;
									Posicione("SC5",1,xFilial("SC5")+ZZO->ZZO_PEDIDO,"C5_CLIENTE+C5_LOJACLI");
									,"A1_NOME");
								,_nPos)
					GDFieldPut("FARDOS",0,_nPos)
					GDFieldPut("CARRE",0,_nPos)
					GDFieldPut("B1"   ,0,_nPos)
					GDFieldPut("B2"   ,0,_nPos)
					GDFieldPut("B3"   ,0,_nPos)
					GDFieldPut("B4"   ,0,_nPos)
					GDFieldPut("B5"   ,0,_nPos)
					GDFieldPut("B6"   ,0,_nPos)
					GDFieldPut("B7"   ,0,_nPos)
					GDFieldPut("PALLET",0,_nPos)
					GDFieldPut("CAIXA",0,_nPos)
					GDFieldPut("ROLOS",0,_nPos)
					GDFieldPut("PLIQ" ,0.00,_nPos)
					GDFieldPut("PBRUT",0.00,_nPos)
				EndIf
			EndIf
			If ZZO->ZZO_STATUS == "0" //não conferido
				_cSitc := "2-Falta Conf.Volumes"
			Else
				_cSitc := "1-Volumes ok"
			EndIf
			If Left(_cSitc,1) > Left(GdFieldGet("SITUACA",_nPos),1) // Quanto maior, pior é!
				GDFieldPut("SITUACA",_cSitc,_nPos)
				/*/			
				1-Volumes ok
				2-Falta Conf.Volumes
				3-Falta Montar Volumes
				/*/
			EndIf	
			If Left(GdFieldGet("SITUACA",_nPos),1) # "1"
				aCols[_nPos,nUsado+1]:=.T.	// Se não 1-Volumes ok, não pode confirmar na carga 		
			EndIf
			If ZZO->ZZO_TIPO == "F" // Fechado é um pallet
				GDFieldPut("PALLET",GDFieldGet("PALLET",_nPos)+1,_nPos)
			Else
				GDFieldPut("FARDOS",GDFieldGet("FARDOS" ,_nPos)+1,_nPos)
			EndIf
			GDFieldPut("PLIQ", GDFieldGet("PLIQ",_nPos) +ZZO->ZZO_PESLIQ,_nPos)
			GDFieldPut("PBRUT",GDFieldGet("PBRUT",_nPos)+ZZO->ZZO_PESBRU,_nPos)
		EndIf
		ZZO->(DbSkip())
	EndDo
	TB_ZZR->(DbSkip())
EndDo
If Select("TB_ZZR")>0    
	TB_ZZR->(dbcloseArea())
	FErase( "TB_ZZR" + GetDbExtension())
EndIf

If Len(aCols) == 0
 	RestArea(_ZZRArea)
	Alert("Não existem Pedidos de Vendas Para Montar Cargas!")
	Returm(.T.)
EndIf

aSort(aCols,,,{|x,y| x[01]+x[02]<y[01]+y[02]})

DbSelectArea("ZZR")

_lRet:= .F.
aButtons := {}
If Len(aCols)>0
	If _cRot == "V" //VISUALIZAR 
		cTitulo        := "Montagem de Cargas - Visualizar"
	ElseIf _cRot == "I" //INCLUIR
		cTitulo        := "Montagem de Cargas - Incluir"
	ElseIf _cRot == "E" //EXCLUIR
		cTitulo        := "Montagem de Cargas - Excluir"
	EndIf 
	cAliasEnchoice := ""
	cAliasGetD     := "ZZR"
	cLinOk         := "u_VlLinCg()"
	cFieldOk       := "U_RefrCar()" //"AllwaysTrue()"
	cTudOk         := "AllwaysTrue()"
	aCpoEnchoice   := {}
	_lRet:=u_JanCarga(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,)
Else
	Alert("Não existem Pedidos de Vendas Para Montar Cargas!")
Endif
If _lRet .And. _cRot # "V" //VISUALIZAR 
	// Antes de perguntar, verifico se tem alguma linha não deletada
	If _cRot == "I" //INCLUIR
		_lRet := .F.
		For _ni := 1 To Len(aCols)
			If !GDDeleted(_ni)
				_lRet := .T.
				Exit
			EndIf
		Next
	EndIf
	If _lRet
		If MsgYesNo("Confirma a " + If(_cRot=="E","Exclusão","Montagem") + " da Carga?")
			GraveCarga(_cRot) // Incluindo ou Excluindo 
		EndIf
	EndIf
EndIf
DbSelectArea("ZZR")
DbSetOrder(1) 
Return(.T.)
*
**********************************************************************************************************************************
User Function JanCarga(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze)
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
_cnCarga := "      "
@ 005,005 Say "Nro.da Carga:" Size 40,10
@ 005,040 Get _cnCarga Picture "@R 999.999" When .F. Size 40,10


@ 020,005 Say "Totais:" Size 40,10

@ 030,005 Say "Qtd.Fardos:" Size 40,10
@ 030,040 Get _nFARDOS Picture "@E 99,999" Object _oFARDOS When .F. Size 40,10
@ 030,085 Say "Qtd.Carretéis:" Size 40,10
@ 030,120 Get _nCARRE Picture "@E 9,999" Object _oCARRE When .F. Size 40,10
@ 030,165 Say "Qtd.Bob.B1:" Size 40,10
@ 030,200 Get _nB1 Picture "@E 999" Object _oB1 When .F. Size 40,10
@ 030,250 Say "Qtd.Bob.B2:" Size 40,10
@ 030,285 Get _nB2 Picture "@E 999" Object _oB2 When .F. Size 40,10
@ 030,330 Say "Qtd.Bob.B3:" Size 40,10
@ 030,365 Get _nB3 Picture "@E 999" Object _oB3 When .F. Size 40,10

@ 045,005 Say "Qtd.Bob.B4:" Size 40,10
@ 045,040 Get _nB4 Picture "@E 999" Object _oB4 When .F. Size 40,10
@ 045,085 Say "Qtd.Bob.B5:" Size 40,10
@ 045,120 Get _nB5 Picture "@E 999" Object _oB5 When .F. Size 40,10
@ 045,165 Say "Qtd.Bob.B6:" Size 40,10
@ 045,200 Get _nB6 Picture "@E 999" Object _oB6 When .F. Size 40,10
@ 045,250 Say "Qtd.Bob.B7:" Size 40,10
@ 045,285 Get _nB7 Picture "@E 999" Object _oB7 When .F. Size 40,10
@ 045,330 Say "Qtd.Pallets:" Size 40,10
@ 045,365 Get _nPALLET Picture "@E 99" Object _oPALLET When .F. Size 40,10

@ 060,005 Say "Qtd.Caixas:" Size 40,10
@ 060,040 Get _nCAIXA Picture "@E 99,999" Object _oCAIXA When .F. Size 40,10
@ 060,085 Say "Qtd.Rolos:" Size 40,10
@ 060,120 Get _nROLOS Picture "@E 99,999" Object _oROLOS When .F. Size 40,10
@ 060,165 Say "Peso Liquido:" Size 40,10
@ 060,200 Get _nPLIQ Picture "@E 99,999.99" Object _oPLIQ When .F. Size 40,10
@ 060,250 Say "Peso Bruto:" Size 40,10
@ 060,285 Get _nPBRUT Picture "@E 99,999.99" Object _oPBRUT When .F. Size 40,10

oGetDados := MsGetDados():New(75,aPosObj[2,2],295,aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,Len(aCols),cFieldOk)

oGetDados:oBrowse:bChange := {|| u_VlLinCg()}

//aAdd(aButtons,{"CRITICA"   ,{|| Estoques() }  , "Estoque Detalhado"})
//aAdd(aButtons,{"EDITABLE"  ,{|| LibAll(.T.) } , "Libera Tudo"})
//aAdd(aButtons,{"S4WB005N"  ,{|| LibMult() }   , "Liberação Múltipla"})
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons) CENTERED
lRet:=(nOpca==1)
Return(lRet)
*
***********************
User Function VlLinCg()
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
u_RefrCar()
Return(.T.)
*
***********************
User Function RefrCar()
***********************
xxx:= 1
_oFARDOS:Refresh()
_oCARRE:Refresh()
_oB1:Refresh()
_oB2:Refresh()
_oB3:Refresh()
_oB4:Refresh()
_oB5:Refresh()
_oB6:Refresh()
_oB7:Refresh()
_oPALLET:Refresh()
_oCAIXA:Refresh()
_oROLOS:Refresh()
_oPLIQ:Refresh()
_oPBRUT:Refresh()
oGetDados:Refresh()
Return(.T.)
*
**********************************
Static Function GraveCarga(_cToDo)
**********************************
*
// Pega o número da próxima carga
// Como ainda não tenho dados na DAK, valido pelo ZZO
//_cNumCar := GetSx8Num("DAK","DAK_COD")
If _cToDo == "I"
	DbSelectArea("ZZO")
	ZZO->(DbSetOrder(5)) // ZZO_FILIAL+ZZO_CARGA
	_cNumCar := GetSx8Num("ZZO","ZZO_CARGA")
	Do While DbSeek(xFilial("ZZO")+_cNumCar,.F.)
		ConfirmSx8()
		_cNumCar := GetSx8Num("ZZO","ZZO_CARGA")
	EndDo
	ConfirmSx8()
Else
	_cNumCar := "      "
EndIf
For _ni := 1 To Len(aCols)
	If !GDDeleted(_ni)
		_cNumPv := GDFieldGet("NUMPV"  ,_ni)
		_cSeqPv := GDFieldGet("SEQUEN" ,_ni)
		
		// Grava os Logs de Liberações
		DbSelectArea("ZZR")
		DbSetOrder(2) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_SEQOS+ZZR_ITEMPV+ZZR_SEQUEN					
		DbSeek(xFilial("ZZR")+_cNumPv+_cSeqPv,.F.)
		Do While ZZR->ZZR_FILIAL == xFilial("ZZR") .And. ZZR->ZZR_PEDIDO == _cNumPv .And. ZZR->ZZR_SEQOS == _cSeqPv .And. ZZR->(!Eof())
			RecLock("ZZR",.F.)
			ZZR->ZZR_CARGA := _cNumCar
			MsUnLock()
			ZZR->(DbSkip())
		EndDo
		 
		// Grava os Volumes
		DbSelectArea("ZZO")
		DbSetOrder(2) // ZZO_FILIAL+ZZO_PEDIDO+ZZO_SEQOS+ZZO_NUMVOL
		DbSeek(xFilial("ZZO")+_cNumPv+_cSeqPv,.F.)
		Do While ZZO->ZZO_FILIAL == xFilial("ZZO") .And. ZZO->ZZO_PEDIDO == _cNumPv .And. ZZO->ZZO_SEQOS == _cSeqPv .And. ZZO->(!Eof())
			RecLock("ZZO",.F.)
			ZZO->ZZO_CARGA := _cNumCar
			MsUnLock()
			ZZO->(DbSkip())
		EndDo
		
		// Grava as liberações - SC9
		DbSelectArea("SC9")
		DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
		DbSeek(xFilial("ZZO")+_cNumPv,.F.)
		Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == _cNumPv .And. SC9->(!Eof())
			If SC9->C9_SEQOS  == _cSeqPv
				RecLock("SC9",.F.)
				SC9->C9_CARGA := _cNumCar
				MsUnLock()
			EndIf
			SC9->(DbSkip())
		EndDo
	EndIf
Next
Return(.T.)