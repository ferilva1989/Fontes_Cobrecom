#INCLUDE "rwmake.CH"
#include "topconn.ch"

#define CRLF Chr(13)+Chr(10)


/*/{Protheus.doc} CSFAT01
//TODO Transferência de materiais para a outra unidade da empresa.
@author juliana.leme
@since 19/02/2015
@version undefined

@type function
/*/
User Function CSFAT01()
	Local lTransf := GetMV("MV_ZZTRANS")
	
	Pergunte("MT460A",.T.)
	cCadastro := "Retorno de Industrialização/Transferencia"
	aRotina := {{ "Pesquisar"  	, "AxPesqui"    , 0 , 1	},;
						{ "Visualizar" 	, "AxVisual"    , 0 , 2	},;
						{ "Transferir"  	, "U_CSFAT01A()", 0 , 3	}}

	DbSelectArea("SC9")
	SC9->(DbSeek(xFilial("SC9")))
	mBrowse(001,040,200,390,"SC9",,,,,,)
Return(.T.)


/*/{Protheus.doc} SelPedid
//TODO Função para Montagem do MarkBrow do SC5  .
@author juliana.leme
@since 24/08/2015 
@version undefined

@type function
/*/
User Function SelPedid()
Local aParamBox 			:= {}
Local aRet 					:= ""
Local cNomArq				:= ""
Local lTriang				:= .F.
Public cTesPed				:= ""
Public cMarca				:= ""
Public aSelPed 				:= {}
Private cAlias 	  			:= "TRBSC5"
Private aRotina				:= {}
Private aIndexSC5			:= {}
Private aFiltro 			:= {}
Private bFiltraBrw			:= {|| Nil }
Private aCampos				:= {}
Private _aCampos			:= {}
Private cCondicao 			:= ""

	aAdd(aParamBox,{1,"Cliente: ", Space(6)	,""	,""	,"SA1"	,"",0,.F.})
	aAdd(aParamBox,{1,"Loja: ", "01"		,""	,""	,""		,"",0,.F.})
	aAdd(aParamBox,{3,"Triangulação(10): ",2,{"Habilitado","Desabilitado"}, 50,"",.F.})
	If !ParamBox(aParamBox, "Parametros", @aRet)
		Return(.F.)
	EndIf
	
	lTriang := (aRet[3] == 1)
	valTipoFat(lTriang)

	cCliente := Alltrim(aRet[1])
	cLoja := aRet[2]
	Aadd(aRotina,{"Confirmar"				,"U_cValida"	, 0,4})

	DbSelectArea("SC5")
	DbSetOrder(1)

	DbSelectArea("SC6")
	DbSetOrder(1)

	// Cria arquivo
	If Select("TRBSC5")>0
		DbSelectArea("TRBSC5")
		DbCloseArea("TRBSC5")
	EndIf

	aAdd(aCampos, {'C5_OK'					,'C',2,0})
	aAdd(aCampos, {'C5_NUM'				,'C',TAMSX3("C5_NUM")[1]				,TAMSX3("C5_NUM")[2]})
	aAdd(aCampos, {'C5_CLIENTE'		,'C',TAMSX3("C5_CLIENTE")[1]		,TAMSX3("C5_CLIENTE")[2]})
	aAdd(aCampos, {'C5_LOJACLI'		,'C',TAMSX3("C5_LOJACLI")[1]		,TAMSX3("C5_LOJACLI")[2]})
	aAdd(aCampos, {'C6_TES'				,'C',TAMSX3("C6_TES")[1]				,TAMSX3("C6_TES")[2]})
	aAdd(aCampos, {'C6_LOCAL'			,'C',TAMSX3("C6_LOCAL")[1]			,TAMSX3("C6_LOCAL")[2]})
	aAdd(aCampos, {'C5_ZZBLVEN'		,'C',TAMSX3("C5_ZZBLVEN")[1]		,TAMSX3("C5_ZZBLVEN")[2]})
	
	cNomArq := AllTrim(CriaTrab(aCampos, .T.))
	DbUseArea(.T.,"",cNomArq, "TRBSC5",.T.,.F.)

	cQuery := " SELECT DISTINCT  C5.C5_OK,C5.C5_NUM,C5.C5_CLIENTE,C5.C5_LOJACLI, C6.C6_TES, C6.C6_LOCAL, C5.C5_ZZBLVEN "
	cQuery += " FROM "+RetSqlName('SC5')+" C5 WITH(NOLOCK) "
	cQuery += " INNER JOIN "+RetSqlName('SC6')+" C6 WITH(NOLOCK) ON C5.C5_FILIAL	= C6.C6_FILIAL "
	cQuery += " 												AND C5.C5_NUM		= C6.C6_NUM "
	cQuery += " 												AND C5.D_E_L_E_T_	= C6.D_E_L_E_T_ "
	cQuery += " WHERE  C5.C5_FILIAL = '"+xFilial("SC5")+"'	"
	cQuery += " AND C6.C6_TES 		<> 	'842' "
	cQuery += " AND C5.C5_NOTA 		= '' "
	cQuery += " AND C5.C5_TIPO 		= 'N' "
	cQuery += " AND C5.C5_CLIENTE 	= '"+cCliente+"' "
	cQuery += " AND C5.C5_LOJACLI 	= '"+cLoja+"' "
	cQuery += " AND C5.C5_LIBEROK 	<> 'E' "
	cQuery += " AND C5.D_E_L_E_T_ 	<> '*' "
	cQuery += " AND C5.C5_NUM "
	if !lTriang
		cQuery += " NOT "
	endif
	cQuery += " IN ( "
	cQuery += " 				SELECT DISTINCT(SC5.C5_NUM) "
	cQuery += " 				FROM "+RetSqlName('SC5')+" SC5 WITH(NOLOCK) "
	cQuery += " 				INNER JOIN "+RetSqlName('SC5')+" SSC5 WITH(NOLOCK) ON SC5.C5_X_IDVEN	= SSC5.C5_X_IDVEN "
	cQuery += " 																AND SC5.D_E_L_E_T_		= SSC5.D_E_L_E_T_ "
	cQuery += " 				INNER JOIN "+RetSqlName('SC6')+" SC6 WITH(NOLOCK) ON SSC5.C5_FILIAL	= SC6.C6_FILIAL "
	cQuery += " 																AND SSC5.C5_NUM			= SC6.C6_NUM "
	cQuery += " 																AND SSC5.D_E_L_E_T_		= SC6.D_E_L_E_T_ "
	cQuery += " 				WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " 				AND SC5.C5_NUM = C5.C5_NUM "
	cQuery += " 				AND SC5.C5_X_IDVEN <> '' "
	cQuery += " 				AND SC6.C6_LOCAL = '10' "
	cQuery += " 				AND SC5.D_E_L_E_T_ = '' "
	cQuery += " 				UNION ALL "
	cQuery += " 				SELECT DISTINCT(SC5.C5_NUM) "
	cQuery += " 				FROM "+RetSqlName('SC5')+" SC5 WITH(NOLOCK) "
	cQuery += " 				INNER JOIN "+RetSqlName('SC6')+" SC6 WITH(NOLOCK) ON SC5.C5_FILIAL		= SC6.C6_FILIAL "
	cQuery += " 																AND SC5.C5_NUM			= SC6.C6_NUM "
	cQuery += " 																AND SC5.D_E_L_E_T_		= SC6.D_E_L_E_T_ "
	cQuery += " 				INNER JOIN "+RetSqlName('SC5')+" SSC5 WITH(NOLOCK) ON LEFT(SC6.C6_ZZPVORI, 6) = SSC5.C5_NUM "
	cQuery += " 																AND SC6.D_E_L_E_T_		= SSC5.D_E_L_E_T_ "
	cQuery += " 				INNER JOIN "+RetSqlName('SC6')+" SSC6 WITH(NOLOCK) ON SSC5.C5_FILIAL	= SSC6.C6_FILIAL "
	cQuery += " 																AND SSC5.C5_NUM			= SSC6.C6_NUM "
	cQuery += " 																AND SSC5.D_E_L_E_T_		= SSC6.D_E_L_E_T_ "
	cQuery += " 				WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery += " 				AND SC5.C5_NUM = C5.C5_NUM "
	cQuery += " 				AND SC6.C6_ZZPVORI <> '' "
	cQuery += " 				AND SSC6.C6_LOCAL = '10' "
	cQuery += " 				AND SC5.D_E_L_E_T_ 	= '' "
	cQuery += " ) "
	cQuery += " ORDER BY C5.C5_NUM "

	if Select("Result1") <> 0
		DBSelectArea("Result1")
		DBCloseArea()
	endif
	//cQuery :=ChangeQuery(cQuery)      // otimiza a query 
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"Result1",.T.,.T.)

	If Result1->(EOF())
		MsgInfo("Não Existe Pedido(s) apto(s) a faturar!","Info")
	Else
		while Result1->(!EOF())
			if vldTriang(xFilial("SC5"), Result1->C5_NUM)
				If Reclock("TRBSC5",.T.)
					TRBSC5->C5_OK     			:= Result1->C5_OK
					TRBSC5->C5_NUM				:= Result1->C5_NUM
					TRBSC5->C5_CLIENTE	 		:= Result1->C5_CLIENTE
					TRBSC5->C5_LOJACLI			:= Result1->C5_LOJACLI
					TRBSC5->C6_TES				:= Result1->C6_TES
					TRBSC5->C6_LOCAL			:= Result1->C6_LOCAL
					TRBSC5->C5_ZZBLVEN			:= Result1->C5_ZZBLVEN
					TRBSC5->(msUnlock())
				EndIf
			endif
			Result1->(dbSkip())
		Enddo

		cMarca := GetMark()
		dbSelectArea("TRBSC5")
		dbSetOrder(0)
		TRBSC5->(DbGotop())

		Aadd(_aCampos, {'C5_OK'				,'C','Ok'			,2,0,'@!'})
		Aadd(_aCampos, {'C5_NUM'			,'C','Pedido'	,PesqPict("SC5","C5_NUM")			,TAMSX3("C5_NUM")[1]			,TAMSX3("C5_NUM")[2]})
		Aadd(_aCampos, {'C5_CLIENTE'		,'C','Cliente'	,PesqPict("SC5","C5_CLIENTE")		,TAMSX3("C5_CLIENTE")[1]	,TAMSX3("C5_CLIENTE")[2]})
		Aadd(_aCampos, {'C5_LOJACLI'		,'C','Loja'		,PesqPict("SC5","C5_LOJACLI")		,TAMSX3("C5_LOJACLI")[1]	,TAMSX3("C5_LOJACLI")[2]})
		Aadd(_aCampos, {'C6_TES'			,'C','TES'		,PesqPict("SC6","C6_TES")			,TAMSX3("C6_TES")[1]			,TAMSX3("C6_TES")[2]})
		Aadd(_aCampos, {'C6_LOCAL'		,'C','Local'		,PesqPict("SC6","C6_LOCAL")		,TAMSX3("C6_LOCAL")[1]		,TAMSX3("C6_LOCAL")[2]})
		Aadd(_aCampos, {'C5_ZZBLVEN'	,'C','Blq.Ven'	,PesqPict("SC5","C5_ZZBLVEN")	,TAMSX3("C5_ZZBLVEN")[1]	,TAMSX3("C5_ZZBLVEN")[2]})
		MarkBrow("TRBSC5","C5_OK","",_aCampos,.F.,@cMarca,,,,,"U_MarkClk()",,,,)

		TRBSC5->(DbGotop())
	EndIf
Return

static function valTipoFat(lTriang)
	local aRet		:= {}
	local aParamBox	:= {}

	if lTriang
		aAdd(aParamBox,{3,"Tipo Faturamento: ",iif(lTransf, 1, 2),{"Transferir","Industrializar"}, 50, '',.F.})
		If !ParamBox(aParamBox, "Parâmetro de Faturamento", @aRet)
			Return(.F.)
		EndIf
		if lTransf .and. (aRet[1] == 2)
			lTransf := !(MsgYesNo('Parâmetro(MV_ZZTRANS) configurado para Transferência, confirma alteração para Industrialização?',;
			'Alterando Operação'))
		elseif !lTransf .and. (aRet[1] == 1)
			lTransf := MsgYesNo('Parâmetro(MV_ZZTRANS) configurado para Industrialização, confirma alteração para Transferência?',;
			'Alterando Operação')
		endif				
	endif
	MsgInfo('Parâmetro(MV_ZZTRANS) configurado para ' + iif(lTransf, 'Transferência', 'Industrialização') + '!', 'Tipo de Faturamento')
return(lTransf)

/*/{Protheus.doc} MarkClk
//TODO Função para marcar o OK no MarBrow .
@author juliana.leme
@since 24/08/2015
@version undefined

@type function
/*/
User Function MarkClk()
	If TRBSC5->C5_OK == cMarca
		RecLock("TRBSC5",.F.)
		TRBSC5->C5_OK := " "
		MsUnLock()
		Return(.T.)
	Else
		If TRBSC5->C5_ZZBLVEN <> "S"
			If Empty(cTesPed) .or. (cTesPed = TRBSC5->C6_TES) .or. (TRBSC5->C6_TES == "849") .or. (cTesPed == "849")
				cTesPed	:=  TRBSC5->C6_TES
				RecLock("TRBSC5",.F.)
				TRBSC5->C5_OK := cMarca
				MsUnLock()
				Return(.T.)
			Else
				Alert("Pedido Selecionado não correponde a mesma TES dos pedidos anteriores selecionados")
				Return(.F.)
			EndIf
		Else
			Alert("Pedido com Bloqueio de Faturamento, Não Liberado!")
			Return(.F.)
		EndIf
	EndIf
	MarkBRefresh()
Return(.T.)


/*/{Protheus.doc} cValida
//TODO Função de Validação do Mark .
@author juliana.leme
@since 24/08/2015 
@version undefined

@type function
/*/
User Function cValida()
If ApMsgYesNo("Confirma os pedidos selecionados ?")
	dbSelectArea("TRBSC5")
	dbSetOrder(0)
	TRBSC5->(DbGotop())
	While TRBSC5->(!Eof())
		If Marked("C5_OK")
			Aadd(aSelPed,TRBSC5->C5_NUM)
		EndIf
		TRBSC5->(DbSkip())
	EndDo
	CloseBrowse()
Endif
Return()


/*/{Protheus.doc} CargaPed
//TODO Função de cancelamento da rotina  .
@author juliana.leme
@since 19/02/2015 
@version undefined

@type function
/*/
Static Function CargaPed()
	_cPedi1:= ""
	For n1 := 1 to Len(aSelPed)
		_cPedi1 := _cPedi1 + aSelPed[n1]+","
	Next
Return


/*/{Protheus.doc} CSFAT01a
//TODO Monta a Janela Principal.
@author juliana.leme
@since 19/02/2015
@version undefined

@type function
/*/
User Function CSFAT01a()
	Public cCliente		:= ""
	Public cLoja		:= ""
	Public aProdSB6		:= {}
	Private 	cCadastro := "Retorno de Industrialização/Transferencia"
	nOpcE:=3
	nOpcG:=3
	inclui := .T.
	altera := .F.
	exclui := .F.
	
	aAltEnchoice :={}
	
	DbSelectArea("SC5")
	DbSetOrder(1)
	
	DbSelectArea("SC6")
	DbSetOrder(1)
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SC9")
	DbSetOrder(1) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	
	_cPedi1 := Space((Len(SC5->C5_NUM)*20)+18)
	_cPedi2 := Space(Len(SC5->C5_NUM))
	
	_nValCob := 0.00
	_nPerMO  := 0.00
	_nValPVC := 0.00
	
	_nPesCob := 0.00
	_nPesPvc := 0.00
	_nTotCob := 0.00
	_nTotPvc := 0.00
	_nTotMO  := 0.00
	
	_cEspec := Space(10)
	_nVolum := 0
	_nPBrut := 0.0000
	_nPLiqu := 0.0000
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria aHeader e aCols da GetDados                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsado:=0
	dbSelectArea("SX3")
	DbSetOrder(2)
	aHeader:={}
	For _nx := 1 to 11
		nUsado:=nUsado+1
		Aadd(aHeader,{" "," "," ",0,0," "," "," "," "," "} )
		If _nx == 1
			aHeader[_nx,1] := "Pedido"
			aHeader[_nx,2] := "C9_PEDIDO"
		ElseIf _nx == 2
			aHeader[_nx,1] := "Item"
			aHeader[_nx,2] := "C9_ITEM"
		ElseIf _nx == 3
			aHeader[_nx,1] := "Sequenc."
			aHeader[_nx,2] := "C9_SEQUEN"
		ElseIf _nx == 4
			aHeader[_nx,1] := "Produto"
			aHeader[_nx,2] := "C9_PRODUTO"
		ElseIf _nx == 5
			aHeader[_nx,1] := "Descricao"
			aHeader[_nx,2] := "C9_DESCRI"
		ElseIf _nx == 6
			aHeader[_nx,1] := "Quantidade"
			aHeader[_nx,2] := "C9_QTDLIB"
		ElseIf _nx == 7
			aHeader[_nx,1] := "Peso Cobre"
			aHeader[_nx,2] := "C9_QTDLIB2"
		ElseIf _nx == 8
			aHeader[_nx,1] := "Peso PVC"
			aHeader[_nx,2] := "C9_QTDORI"
		ElseIf _nx == 9
			aHeader[_nx,1] := "Vlr.Cobre"
			aHeader[_nx,2] := "C9_PRCVEN"
		ElseIf _nx == 10
			aHeader[_nx,1] := "Valor PVC"
			aHeader[_nx,2] := "C9_PRCVEN2"
		ElseIf _nx == 11
			aHeader[_nx,1] := "Valor MO"
			aHeader[_nx,2] := "C9_PRCVEN3"
		EndIf
		DbSeek(aHeader[_nx,2],.F.)
		aHeader[_nx,03] := SX3->X3_PICTURE
		aHeader[_nx,04] := SX3->X3_TAMANHO
		aHeader[_nx,05] := SX3->X3_DECIMAL
		aHeader[_nx,06] := ".F." //SX3->X3_VLDUSER // "AllwaysTrue()"
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
	cTitulo        := "Retorno de Industrialização/Transferencia"
	cAliasEnchoice := ""
	cAliasGetD     := "SC9"
	cLinOk         := "AllwaysTrue()"
	cTudOk         := "u_ValTd()" //"AllwaysTrue()"
	cFieldOk       := "AllwaysTrue()"
	aCpoEnchoice   := {}
	
	lTransf := GetMV("MV_ZZTRANS")
		
	//Chama janela de pedidos
	Processa( {|| U_SelPedid() },"Escolha o Pedido")

	If lTransf //TROCA O TES PARA TRANSFERÊNCIAS
		cTesPed := "849"
	EndIf

	_lRet:=u_JanFat01(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,)
	If (_lRet) .and. ( !Empty(Alltrim(_cPedi2)) .or.  lTransf)
			Processa( {|| CSFature() },"Processando Notas Fiscais...")
	Else
		If !Empty(_cPedi2)
			U_ExPVDados(_cPedi2)
			MsgInfo("Pedido de MP Num.:"+_cPedi2+" excluído com sucesso", "Info" )
		Else
			Return (.F.)
		EndIf
	EndIf
Return(.T.)


/*/{Protheus.doc} JanFat01
//TODO Janela Secundaria.
@author juliana.leme
@since 19/02/2015   
@version undefined
@param cTitulo, characters, Titulo Janela
@param cAlias1, characters, Primeiro Alias
@param cAlias2, characters, Segundo Alias
@param aMyEncho, array, descricao
@param cLinOk, characters, descricao
@param cTudoOk, characters, descricao
@param nOpcE, numeric, descricao
@param nOpcG, numeric, descricao
@param cFieldOk, characters, descricao
@param lVirtual, logical, descricao
@param nLinhas, numeric, descricao
@param aAltEnchoice, array, descricao
@param nFreeze, numeric, descricao
@type function
/*/
User Function JanFat01(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze)
	Local lRet, nOpca	:= 0,cSaveMenuh,nReg:=0
	Local aSize 			:= {}
	Local aPosObj 		:= {}
	Local aObjects 		:= {}
	Local aInfo 			:= {}
	Local aItem 			:= {}
	Public _cTransp	:= "       "
	Public _cTpFrete	:= " "
	Private _lRet1 		:= .T.
	
	aItem := {"C=CIF","F=FOB","T=Por conta terceiros","S=Sem frete"}
	
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
	
	@ 030,005 Say "Nros.PV's: "																			Size 45,10
	@ 030,055 Get _cPedi1	When .F.	Valid ConfPds()											Size 290,10 //Object _ocPed
	@ 030,360 Say "PV MP/MO.: "																		Size 45,10
	@ 030,400 Get _cPedi2  Picture "XXXXXX"	When .F.	Valid ConfPd2() 				Size 60,10
	
	@ 045,005 Say "Vlr.Cobre Kg.:"																Size 45,10
	@ 045,055 Get _nValCob Picture "@E 9,999.99"	Valid Positivo() .And. u_CalcAcols() 	Size 60,10
	@ 045,130 Say "Vlr.P.V.C./Kg:"                                							Size 45,10
	@ 045,170 Get _nValPVC Picture "@E 9,999.99"	Valid Positivo() .And. u_CalcAcols() 	Size 60,10
	@ 045,245 Say "% Mao Obra...:"																Size 45,10
	@ 045,285 Get _nPerMO  Picture "@E   999.99"	Valid Positivo() .And. u_CalcAcols()	Size 60,10
	@ 045,360 Say "Peso Tot.Cobre:"																Size 45,10
	@ 045,400 Get _nPesCob Picture "@E 999,999.99" When .F.									Size 60,10 Object _O_nPesCob
	
	@ 060,005 Say "Vlr.Tot.Cobre:"																Size 45,10
	@ 060,055 Get _nTotCob Picture "@E 999,999.99" When .F.									Size 60,10 Object _O_nTotCob
	@ 060,130 Say "Vlr. Tot.PVC :"																Size 45,10
	@ 060,170 Get _nTotPvc Picture "@E 999,999.99" When .F.									Size 60,10 Object _O_nTotPvc
	@ 060,245 Say "Vlr. Tot. MO :"																Size 45,10
	@ 060,285 Get _nTotMO  Picture "@E 999,999.99" When .F.									Size 60,10 Object _O_nTotMO
	@ 060,360 Say "Peso Tot. PVC:"																Size 45,10
	@ 060,400 Get _nPesPvc Picture "@E 999,999.99" When .F.									Size 60,10 Object _O_nPesPvc
	
	@ 075,005 Say "Espécie :"																	Size 45,10
	@ 075,055 Get _cEspec  Picture "@! XXXXXXXXXX"											Size 60,10
	@ 075,130 Say "Volume :"																		Size 45,10
	@ 075,170 Get _nVolum  Picture "@E 99,999" Valid Positivo()								Size 60,10
	@ 075,245 Say "Peso.Liquido :"																Size 45,10
	@ 075,285 Get _nPLiqu  Picture "@E 999,999.9999" Valid Positivo()						Size 60,10
	@ 075,360 Say "Peso Bruto:   "																Size 45,10
	@ 075,400 Get _nPBrut  Picture "@E 999,999.9999" Valid Positivo()						Size 60,10
	
	@ 090,005 Say "Transp :"																		Size  45,10
	@ 090,055 Get _cTransp Picture "@! XXXXXXXX" 	F3 "SA4" When .T.							Size  60,10
	@ 090,130 Say "Tipo Frete : (C=CIF/F=FOB/T=Por conta terceiros/S=Sem frete)"			Size 150,10
	@ 090,285 Get _cTpFrete  Picture "@! X"	 When .T.										Size  20,10
	
	
	oGetDados := MsGetDados():New(105,aPosObj[2,2],280,aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,Len(aCols),cFieldOk)
	oGetDados:oBrowse:bChange := {|| U_RefFat01()}
	
	If Len(aSelPed)>0
		CargaPed()
	EndIf
	
	ConfPd2()
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons) CENTERED
	lRet:=(nOpca==1)
Return(lRet)


/*/{Protheus.doc} RefFat01
//TODO Atualiza Browse.
@author juliana.leme
@since 01/09/2015  
@version undefined

@type function
/*/
User Function RefFat01()
	_O_nPesCob:Refresh()
	_O_nPesPvc:Refresh()
	_O_nTotCob:Refresh()
	_O_nTotPvc:Refresh()
	_O_nTotMO:Refresh()
	oGetDados:Refresh()
Return(.T.)


/*/{Protheus.doc} ConfPds
//TODO Confere Pedidos escolhidos.
@author juliana.leme
@since 01/09/2015 
@version undefined

@type function
/*/
Static Function ConfPds()
	aCols:={}
	_lRetFun := .T.
	
	DbSelectArea("SC9")
	DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	_cVarTRB := AllTrim(_cPedi1)
	_cPedVisto := ""
	Do While Len(_cVarTRB) > 0
		_cTRBNum := Left(_cVarTRB,6)
		If Len(_cVarTRB) > 6
			_cTRBVir := Substr(_cVarTRB,7,1)
		Else
			_cTRBVir := ","
		EndIf
		_cVarTRB := AllTrim(Substr(_cVarTRB,8))
	
		If _cTRBNum $ _cPedVisto // Se já fiz o pedido... pra não fazer mais de uma vez
			Loop
		EndIf
		_cPedVisto := _cPedVisto + "/" + _cTRBNum
	
		DbSelectArea("SC9")
		_lTem := .F.
		If SC9->(DbSeek(xFilial("SC9")+_cTRBNum,.F.))
			DbSelectArea("SC5")
			DbSetOrder(1)
			SC5->(DbSeek(xFilial("SC5")+_cTRBNum,.F.))
			DbSelectArea("SC9")
		EndIf
		Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == _cTRBNum .And. SC9->(!Eof())
			If Empty(SC9->C9_BLCRED) .And.  Empty(SC9->C9_BLEST)
				If !_lTem
					_lTem := .T.
				EndIf
				AADD(aCols,Array(Len(aHeader)+1))
				For _ni:=1 to Len(aHeader)
					If ( aHeader[_ni,10] # "V" )
						aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
					Else
						aCols[Len(aCols),_ni] := CriaVar(aHeader[_ni,2])
					EndIf
				Next
				aCols[Len(aCols),Len(aHeader)+1]:=.F.
			EndIf
			SC9->(DbSkip())
		EndDo
		If !_lTem
			Alert("O Pedido " + _cTRBNum + " Não Possui Itens Liberados para Retorno")
			_lRetFun := .F.
		EndIf
	EndDo
	
	If !_lRetFun
		aCols:={Array(nUsado+1)}
		For _ni:=1 to nUsado
			aCols[1,_ni]:= CriaVar(aHeader[_ni,2])
		Next
		aCols[1,nUsado+1]:= .F.
		_lRet1	:= .F.
	Else
		u_CalcAcols()	// Calcular todo
	EndIf
Return(_lRetFun)


/*/{Protheus.doc} CalcAcols
//TODO Calcula e recalcula o aCols baseado nos campos do cabeçalho.
@author juliana.leme
@since 01/09/2015  
@version undefined

@type function
/*/
User Function CalcAcols()
	// Buscar dados do SB1 e gravar no acols
	_nPesCob := 0.00
	_nPesPvc := 0.00
	_nTotCob := 0.00
	_nTotPvc := 0.00
	_nTotMO  := 0.00
	DbSelectArea("SB1")
	DbSetOrder(1)
	For _nXX := 1 to Len(aCols)
		_cONTEUD := GDFieldGet("C9_PRODUTO",_nXX)
		SB1->(DbSeek(xFilial("SB1")+GDFieldGet("C9_PRODUTO",_nXX),.F.))
		GDFieldPut("C9_DESCRI",SB1->B1_DESC,_nXX)
	
		GDFieldPut("C9_QTDLIB2" ,Round((GDFieldGet("C9_QTDLIB",_nXX)*SB1->B1_PESCOB),2),_nXX)
		GDFieldPut("C9_QTDORI"  ,Round((GDFieldGet("C9_QTDLIB",_nXX)*SB1->B1_PESPVC),2),_nXX)
	
		GDFieldPut("C9_PRCVEN"  ,Round((GDFieldGet("C9_QTDLIB2",_nXX)*_nValCOB),2),_nXX)
		GDFieldPut("C9_PRCVEN2" ,Round((GDFieldGet("C9_QTDORI" ,_nXX)*_nValPVC),2),_nXX)
		GDFieldPut("C9_PRCVEN3" ,Round((((GDFieldGet("C9_PRCVEN",_nXX)+GDFieldGet("C9_PRCVEN2",_nXX)) * _nPerMO)) / 100,2),_nXX)
	
		_nPesCob += GDFieldGet("C9_QTDLIB2" ,_nXX)
		_nPesPvc += GDFieldGet("C9_QTDORI"  ,_nXX)
		_nTotCob += GDFieldGet("C9_PRCVEN"  ,_nXX)
		_nTotPvc += GDFieldGet("C9_PRCVEN2" ,_nXX)
		_nTotMO  += GDFieldGet("C9_PRCVEN3" ,_nXX)
	Next
	u_RefFat01()
Return(.T.)


/*/{Protheus.doc} ValTd
//TODO Valida Todos os campos		.
@author juliana.leme
@since 01/09/2015   
@version undefined

@type function
/*/
User Function ValTd()
	Public _lFisico := .T.
	_lVolta := (!Empty(_cPedi2) .And. !Empty(_nValCob) .And. !Empty(_nPerMO) .And. !Empty(_nValPVC))
	If (Empty(_cPedi2) .and. ! lTransf)
		_cMens := "Informar Pedido MP/MO"
	ElseIf Empty(_nValCob)
		_cMens := "Informar Valor do Cobre"
	ElseIf Empty(_nPerMO)
		_cMens := "Informar % de Mão de Obra"
	ElseIf Empty(_nValPVC)
		_cMens := "Informar Valor P.V.C./Kg"
	EndIf
	If !_lVolta .and. !lTransf
		Alert(_cMens)
	EndIf
	_lVolta	    := MsgBox("Confirma o Processamento do Retorno de Industralização/Transferencia?","Confirma?","YesNo")
Return(_lVolta)


/*/{Protheus.doc} ConfPd2
//TODO Rotinas do Pedido de MP correlacionado aos Pedidos de PA.
@author juliana.leme
@since 01/09/2015
@version undefined

@type function
/*/
Static Function ConfPd2()
	Private nQtdCobre	:= 0
	Private nQtdPVC		:= 0
	Private aCabec		:= {}
	Private aItens			:= {}
	Private aItem			:= {}
	Private  nItem			:= 1
	If Empty(_cPedi1)
		oDlg:End()
		Return nil
	EndIf
	//Carrega grid com os proditos dos pedidos - Juliana Leme 25/08/2015
	ConfPds()
	
	If _lRet1 .and.! lTransf
		If (Empty(_cPedi2)).and.(!Empty(_cPedi1))
			//Valida Poder de terceiros para devolução de Materia Prima
			U_VldPodTerc(.T.)//Cobre
			If Len(aItem) == 0
				Alert("Nenhum Item Selecionado!")
				oDlg:End()
				Return nil
			Else
				U_VldPodTerc(.F.)//PVC
			EndIf
		EndIf
	EndIf
	
	If Empty(_cPedi2) .and. ! lTransf
		Alert("Nenhum Pedido MP criado!")
		oDlg:End()
		Return nil
	EndIf
	
Return(.T.)


/*/{Protheus.doc} VldPodTerc
//TODO Realiza a validação do Poder de Terceiros para seleção.
@author juliana.leme
@since 01/09/2015
@version undefined
@param lCobre, logical, descricao
@type function
/*/
User Function VldPodTerc(lCobre)
	Local aParamBox 	:= {}
	Local aRet 			:= ""
	Local cNomArq		:= ""
	Public _aSelB6 		:= {}
	Public aEstrPVC		:= {}
	Private cAlias 	  	:= "SB6"
	Private aRotina		:= {}
	Private aIndexSC5	:= {}
	Private aFiltro 	:= {}
	Private bFiltraBrw	:= {|| Nil }
	Private aCampos		:= {}
	Private cCondicao 	:= ""
	Private _aCampos	:= {}
	Private cCadastro	:= "Retorno de Industrialização"
	
	cMarca := ""
	If lCobre
		cCadastro		:= "Retorno de Industrialização - COBRE"
	Else
		cCadastro		:= "Retorno de Industrialização - PVC/MASTER"
	EndIf
	
	If lCobre
		Aadd(aRotina,{"Confirmar"				,"U_CargSB6(.T.)"	,0,4})
		nQtdCobre		:= _nPesCob
	Else
		Aadd(aRotina,{"Confirmar"				,"U_CargSB6(.F.)"	, 0,4})
		Aadd(aRotina,{"Consumo Estrutura"		,"U_EstrTela()"	, 0,4})
		nQtdPVC		:= _nPesPvc
	Endif
	
	aAdd(aCampos, {'B6_OK'			,'C',2,0})
	aAdd(aCampos, {'B6_PRODUTO'		,'C',TAMSX3("B6_PRODUTO")[1],TAMSX3("B6_PRODUTO")[2]})
	aAdd(aCampos, {'B1_DESC'			,'C',TAMSX3("B1_DESC")[1]	,TAMSX3("B1_DESC")[2]})
	aAdd(aCampos, {'B6_UM'			,'C',TAMSX3("B6_UM")[1]		,TAMSX3("B6_UM")[2]})
	aAdd(aCampos, {'B6_EMISSAO'		,'D',TAMSX3("B6_EMISSAO")[1],TAMSX3("B6_EMISSAO")[2]})
	aAdd(aCampos, {'B6_DOC'			,'C',TAMSX3("B6_DOC")[1]		,TAMSX3("B6_DOC")[2]})
	aAdd(aCampos, {'B6_SERIE'		,'C',TAMSX3("B6_SERIE")[1]	,TAMSX3("B6_SERIE")[2]})
	aAdd(aCampos, {'B6_TES'			,'C',TAMSX3("B6_TES")[1]		,TAMSX3("B6_TES")[2]})
	aAdd(aCampos, {'B6_LOCAL'		,'C',TAMSX3("B6_LOCAL")[1]	,TAMSX3("B6_LOCAL")[2]})
	aAdd(aCampos, {'B6_IDENT'		,'C',TAMSX3("B6_IDENT")[1]	,TAMSX3("B6_IDENT")[2]})
	aAdd(aCampos, {'B6_PRUNIT'		,'N',TAMSX3("B6_PRUNIT")[1]	,TAMSX3("B6_PRUNIT")[2]})
	aAdd(aCampos, {'B6_QUANT'		,'N',TAMSX3("B6_QUANT")[1]	,TAMSX3("B6_QUANT")[2]})
	aAdd(aCampos, {'B6_SALDO'		,'N',TAMSX3("B6_SALDO")[1]	,TAMSX3("B6_SALDO")[2]})
	aAdd(aCampos, {'B6_UTILIZ'		,'N',TAMSX3("B6_SALDO")[1]	,TAMSX3("B6_SALDO")[2]})
	aAdd(aCampos, {'B6_DEVOLUC'		,'C',1,0})
	
	// Cria arquivo
	If Select("TRBB6")>0
		DbSelectArea("TRBB6")
		DbCloseArea()
	EndIf
	
	cNomArq := AllTrim(CriaTrab(aCampos, .T.))
	DbUseArea(.T.,"",cNomArq, "TRBB6",.T.,.F.)
	
	cQuery := " SELECT	B6.B6_OK B6_OK, "
	cQuery += " 		 	B6.B6_PRODUTO B6_PRODUTO, "
	cQuery += " 		 	B1.B1_DESC B1_DESC, "
	cQuery += " 		 	B6.B6_EMISSAO B6_EMISSAO, "
	cQuery += " 			B6.B6_DOC B6_DOC, "
	cQuery += " 			B6.B6_SERIE B6_SERIE, "
	cQuery += " 			B6.B6_TES B6_TES, "
	cQuery += " 			B6.B6_LOCAL B6_LOCAL, "
	cQuery += " 			B6.B6_IDENT B6_IDENT, "
	cQuery += " 			B6.B6_PRUNIT B6_PRUNIT, "
	cQuery += " 			B6.B6_QUANT B6_QUANT, "
	cQuery += " 			B6.B6_UM B6_UM, "
	cQuery += " 			B6.B6_QULIB B6_QULIB, "
	cQuery += " 			B6.B6_SALDO-B6.B6_QULIB B6_SALDO, "
	cQuery += " 			0 B6_UTILIZ, "
	cQuery += " 			'N' B6_DEVOLUC "
	cQuery += " FROM "+RetSqlName('SB6')+" B6, "
	cQuery += " 		"+RetSqlName('SB1')+" B1 "
	cQuery += " WHERE B6.B6_FILIAL = '"+xfilial("SB6")+"' "
	cQuery += " 	AND B1.B1_FILIAL = '"+xfilial("SB1")+"' "
	cQuery += " 	AND B6.B6_PRODUTO = B1.B1_COD "
	cQuery += " 	AND B6.B6_PODER3 = 'R' "
	cQuery += " 	AND B6.B6_SALDO > 0 "
	cQuery += " 	AND B6.B6_TIPO = 'D' "
	cQuery += " 	AND B6.B6_CLIFOR+B6.B6_LOJA = '"+cCliente+cLoja+"' "
	If lCobre
		cQuery += " 	AND B1.B1_GRUPO NOT IN ('MP03','MP04') "
		cQuery += " 	AND B1.B1_TIPO IN ('MP','PI') "
	Else
		cQuery += " 	AND B1.B1_GRUPO IN ('MP03','MP04') "
	EndIf
	cQuery += " 	AND B1.D_E_L_E_T_ <> '*' "
	cQuery += " 	AND B6.D_E_L_E_T_ <> '*' "
	cQuery += " 	ORDER BY  B6.B6_EMISSAO"
	
	if Select("Result") <> 0
		DBSelectArea("Result")
		DBCloseArea()
	endif
	cQuery :=ChangeQuery(cQuery)      // otimiza a query
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"Result",.T.,.T.)
	
	If !lCobre .and. Result->(EOF())
		MsgInfo("Não existe saldo PVC","Info")
		U_CargSB6(.F.)
	Else
		while Result->(!EOF())
			If Reclock("TRBB6",.T.)
				TRBB6->B6_OK     			:= Result->B6_OK
				TRBB6->B6_PRODUTO		:= Result->B6_PRODUTO
				TRBB6->B1_DESC	 		:= Result->B1_DESC
				TRBB6->B6_UM		 		:= Result->B6_UM
				TRBB6->B6_EMISSAO 	:= StoD(Result->B6_EMISSAO)
				TRBB6->B6_DOC		 	:= Result->B6_DOC
				TRBB6->B6_SERIE	 	:= Result->B6_SERIE
				TRBB6->B6_TES		 		:= Result->B6_TES
				TRBB6->B6_LOCAL	 	:= Result->B6_LOCAL
				TRBB6->B6_IDENT 		:= Result->B6_IDENT
				TRBB6->B6_PRUNIT 		:= Result->B6_PRUNIT
				TRBB6->B6_QUANT 		:= Result->B6_QUANT
				TRBB6->B6_SALDO 		:= Result->B6_SALDO
				TRBB6->B6_UTILIZ 		:= Result->B6_UTILIZ
				TRBB6->B6_DEVOLUC		:= Result->B6_DEVOLUC
				TRBB6->(msUnlock())
			endif
			Result->(dbSkip())
		Enddo
	
		cMarca := GetMark()
		dbSelectArea("TRBB6")
		dbSetOrder(0)
		TRBB6->(DbGotop())
	
		If lCobre
			Do While TRBB6->(!Eof()) .and. (nQtdCobre > 0)
				RecLock("TRBB6",.F.)
				TRBB6->B6_OK		:= cMarca
				If (TRBB6->B6_SALDO > nQtdCobre)
					TRBB6->B6_UTILIZ	:= nQtdCobre
					nQtdCobre := 0
				Else
					nQtdCobre	:= nQtdCobre - TRBB6->B6_SALDO
					TRBB6->B6_UTILIZ	:= TRBB6->B6_SALDO
				EndIf
				TRBB6->B6_SALDO	:= TRBB6->B6_SALDO - TRBB6->B6_UTILIZ
				MsUnLock()
				DbSkip()
			EndDo
		Else
			LeEstrB6()
		EndIf
	
		aAdd(_aCampos, {'B6_OK'				,'C','Ok'				,2,0,'@!'})
		aAdd(_aCampos, {'B6_PRODUTO'	,'C','Produto'		,PesqPict("SB6","B6_PRODUTO")	,TAMSX3("B6_PRODUTO")[1]	,TAMSX3("B6_PRODUTO")[2]})
		aAdd(_aCampos, {'B1_DESC'			,'C','Descrição'	,PesqPict("SB1","B1_DESC")			,TAMSX3("B1_DESC")[1]		,TAMSX3("B1_DESC")[2]})
		aAdd(_aCampos, {'B6_UM	'			,'C','UM'				,PesqPict("SB1","B6_UM")					,TAMSX3("B6_UM")[1]			,TAMSX3("B6_UM")[2]})
		aAdd(_aCampos, {'B6_EMISSAO'	,'D','Emissão'	,PesqPict("SB6","B6_EMISSAO")		,TAMSX3("B6_EMISSAO")[1]	,TAMSX3("B6_EMISSAO")[2]})
		aAdd(_aCampos, {'B6_DOC'			,'C','N.Fiscal'		,PesqPict("SB6","B6_DOC")				,TAMSX3("B6_DOC")[1]		,TAMSX3("B6_DOC")[2]})
		aAdd(_aCampos, {'B6_SERIE'			,'C','Série'			,PesqPict("SB6","B6_SERIE")			,TAMSX3("B6_SERIE")[1]		,TAMSX3("B6_SERIE")[2]})
		aAdd(_aCampos, {'B6_PRUNIT'		,'N','Vl.Unit.'		,PesqPict("SB6","B6_PRUNIT")		,TAMSX3("B6_PRUNIT")[1]		,TAMSX3("B6_PRUNIT")[2]})
		aAdd(_aCampos, {'B6_QUANT'		,'N','Qt.Orig'		,PesqPict("SB6","B6_QUANT")			,TAMSX3("B6_QUANT")[1]		,TAMSX3("B6_QUANT")[2]})
		aAdd(_aCampos, {'B6_SALDO'		,'N','Saldo'			,PesqPict("SB6","B6_SALDO")			,TAMSX3("B6_SALDO")[1]		,TAMSX3("B6_SALDO")[2]})
		aAdd(_aCampos, {'B6_UTILIZ'			,'N','Qt.Utiliz'		,PesqPict("SB6","B6_SALDO")			,TAMSX3("B6_SALDO")[1]		,TAMSX3("B6_SALDO")[2]})
		aAdd(_aCampos, {'B6_DEVOLUC'	,'C','MP Utiliz'	,'@!',1,0})
		aAdd(_aCampos, {'B6_TES'				,'C','TES'				,PesqPict("SB6","B6_TES")				,TAMSX3("B6_TES")[1]		,TAMSX3("B6_TES")[2]})
		aAdd(_aCampos, {'B6_LOCAL'		,'C','Local'			,PesqPict("SB6","B6_LOCAL")			,TAMSX3("B6_LOCAL")[1]		,TAMSX3("B6_LOCAL")[2]})
		aAdd(_aCampos, {'B6_IDENT'			,'C','IdentB6'		,PesqPict("SB6","B6_IDENT")			,TAMSX3("B6_IDENT")[1]		,TAMSX3("B6_IDENT")[2]})
	
		MarkBrow("TRBB6","B6_OK","",_aCampos,.F.,@cMarca,,,,,"U_MarkClk2()",,,,)
	
		SET FILTER TO
		TRBB6->(DbGotop())
		dbCloseArea("TRBB6")
	EndIf
Return()


/*/{Protheus.doc} LeEstrB6
//TODO Le a estrutura do PA e carrega em tela a necessidade de utilizar.
@author juliana.leme
@since 01/09/2015	
@version undefined

@type function
/*/
Static Function LeEstrB6()
	Local nNum			:= 1
	Local cCodPai		:= ""
	Local nQtde 		:= 0
	Local nQtdPai		:= 0
	Local nQtdEstPVC	:= 0
	Local lEstTem		:= .F.
	Local _nPosPd		:= 0
	Local nQtdEst		:= 0
	Public _nTotal	:= 0
	
	aSort(aCols,,,{|x,y| x[4]<y[4]})
	While nNum <= Len(aCols)
		cCodPai 	:= GDFieldGet("C9_PRODUTO"  ,nNum)
		nQtdPai	:= 0
		While (nNum <= Len(aCols))
			If (cCodPai == GDFieldGet("C9_PRODUTO"  ,nNum))
				nQtdPai	+= GDFieldGet("C9_QTDLIB"  ,nNum)
				nNum 	+=  1
			Else
				Exit
			EndIf
		EndDo
	
		cQuery := " SELECT COD_COMP, "
		cQuery +=			" GRUPO_COMP,	"
		cQuery +=			" DESC_COMP,	"
		cQuery +=			" PADR,	"
		cQuery +=			Str(nQtdPai) + " * Sum(QTD) QTDE"
		cQuery += " FROM V_ESTRUTURA_OPC "
		cQuery += " WHERE CODIGO = '"+ Alltrim(cCodPai) +"'"
		cQuery += " AND GRUPO_COMP IN ('MP03','MP04') "
		cQuery += " GROUP BY COD_COMP,"
		cQuery += 			" GRUPO_COMP,"
		cQuery += 			" DESC_COMP,"
		cQuery += 			" PADR"
	
		If Select("Result") <> 0
			DBSelectArea("Result")
			DBCloseArea()
		EndIf
	
		cQuery := ChangeQuery(cQuery)      // otimiza a query
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"Result",.T.,.T.)
	
		//Abrindo os opcionais
		dbSelectArea("SGA")
		dbSetOrder(1)
	
		While Result->(!EOF())
			dbSelectArea("TRBB6")
			dbSetOrder(0)
			TRBB6->(DbGotop())
	
			nQtdEstPVC			:= Result->QTDE
			lEstTem			:= .F.
	
			If (Alltrim(Result->PADR) = "") .or. (Posicione("SGA",1,xFilial("SGA")+Result->PADR,"GA_PADRAO") = "S")
				While TRBB6->(!Eof())
					If (Alltrim(TRBB6->B6_PRODUTO) == Alltrim(Result->COD_COMP)).and.(nQtdEstPVC <> 0)
						RecLock("TRBB6",.F.)
						TRBB6->B6_OK		:= cMarca
						If (TRBB6->B6_SALDO > nQtdEstPVC)
							TRBB6->B6_UTILIZ	+= nQtdEstPVC
							nQtdEstPVC	:= 0
						Else
							nQtdEstPVC	:= nQtdEstPVC - TRBB6->B6_UTILIZ
							TRBB6->B6_UTILIZ	+= TRBB6->B6_SALDO
						EndIf
						TRBB6->B6_SALDO	:= TRBB6->B6_SALDO - TRBB6->B6_UTILIZ
						MsUnLock()
	
						_nPosPd := aScan(aEstrPVC, {|x|x[1]== Result->COD_COMP})
						If _nPosPd == 0
							//Carrega Array parar exibir o que foi validado na estrutura
							aAdd(aEstrPVC,{Result->COD_COMP,;
							Result->DESC_COMP,;
							Result->QTDE,;
							TRBB6->B6_UTILIZ})
						Else
							aEstrPVC[_nPosPd,3]+= Result->QTDE
							aEstrPVC[_nPosPd,4]:= TRBB6->B6_UTILIZ
						EndIf
						_nTotal	+= Result->QTDE
						lEstTem	:= .T.
					EndIf
					TRBB6->(dbSkip())
				EndDo
	
				If !(lEstTem)
					_nPosPd := aScan(aEstrPVC, {|x|x[1]== Result->COD_COMP})
					If _nPosPd == 0
						aAdd(aEstrPVC,{Result->COD_COMP,;
						Result->DESC_COMP,;
						Result->QTDE,;
						0})
					Else
						aEstrPVC[_nPosPd,3]+= Result->QTDE
					EndIf
					_nTotal	+= Result->QTDE
				EndIf
			EndIf
			Result->(dbSkip())
		EndDo
	EndDo
Return()


/*/{Protheus.doc} EstrTela
//TODO Mostra Estrutura dos Grupos MP03 e MP04 na tela.
@author juliana.leme
@since 01/09/2015
@version undefined

@type function
/*/
User Function EstrTela()
	Private oDlg2
	Private oBrowse
	Private cTittela	:= "Estrutura PVC/MASTER - SOMA TOTAL: "+TRANSFORM(_nTotal, "@E 999999.999999")
	
	DEFINE MSDIALOG oDlg2 TITLE cTittela FROM 200,200 TO 620,930 PIXEL
	
	// Cria Browse
	oBrowse := TCBrowse():New( 01 , 01, 365, 210,,;
	{'Codigo','Descr','Qtde Estr','Qtde Utiliz'},{40,50,50,50},;
	oDlg2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	// Seta array para o browse
	oBrowse:SetArray(aEstrPVC)
	
	// Adciona colunas
	oBrowse:AddColumn( TCColumn():New('Codigo'		,{ || aEstrPVC[oBrowse:nAt,1] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TCColumn():New('Descrição'  	,{ || aEstrPVC[oBrowse:nAt,2] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TCColumn():New('Qtde Estr' 	,{ || aEstrPVC[oBrowse:nAt,3] },"@E 999999.999999",,,"RIGHT",,.F.,.T.,,,,.F.,) )
	oBrowse:AddColumn( TCColumn():New('Qtde Utiliz' ,{ || aEstrPVC[oBrowse:nAt,4] },"@E 999999.999999",,,"RIGHT",,.F.,.T.,,,,.F.,) )
	
	
	ACTIVATE DIALOG oDlg2 CENTERED
Return()


/*/{Protheus.doc} CargSB6
//TODO Realiza Carga em Tela para o SB6	.
@author juliana.leme
@since 24/08/2015	
@version undefined
@param lCobr, logical, É Cobre ? .T./.F.
@type function
/*/
User Function CargSB6(lCobr)
	Local cNumPed      	:= ""
	local cTpxOper		:= ''
	Private lMsErroAuto 	:= .F.
	Private _cTes			:= ""
	
	nQtdCobre := 0
	
	If nQtdCobre = 0
		If ApMsgYesNo("Confirma os Produtos Selecionados ?")
			If !lCobr
				//Inclusão do Pedido de Vendas
				//Montagem do cabeçalho
				Do While .T.
					cNumPed := GetSX8Num("SC5","C5_NUM")
					ConfirmSX8()
					If !SC5->(DbSeek(xFilial("SC5")+cNumPed,.F.))
						Exit
					EndIf
				EndDo
	
				SC5->(dbSetOrder(1))
	
				aCabec := {	{"C5_NUM"			,cNumPed		,Nil},; // Numero do Pedido
				{"C5_TIPO"			,"N"			,Nil},; // Tipo do Pedido
				{"C5_CLIENTE"		,cCliente		,Nil},; // Codigo do Cliente
				{"C5_LOJACLI"			,cLoja			,Nil},; // Loja do Cliente
				{"C5_CLIENT"			,cCliente		,Nil},; // Codigo do Cliente para entrega
				{"C5_LOJAENT"		,cLoja			,Nil},; // Loja para entrega
				{"C5_TIPOCLI"			,"F"			,Nil},; // Tipo do Cliente
				{"C5_CONDPAG"		,"901"			,Nil},; // Condicao de pgto
				{"C5_EMISSAO"		,dDatabase		,Nil},; // Data de Emissao
				{"C5_MOEDA"			,1				,Nil},;
				{"C5_TPFRETE"		,"S"			,Nil}} // Data de Emissao} // Moeda
			EndIf
	
			dbSelectArea("TRBB6")
			dbSetOrder(0)
			TRBB6->(DbGotop())
			While TRBB6->(!Eof())
				If Marked("B6_OK")
					//Montagem dos Itens
					If 	TRBB6->B6_DEVOLUC = "S"
						_cTes := "550"
					Else
						_cTes := If(TRBB6->B6_TES == "096","537","539")
						cTpxOper :=  iif(TRBB6->B6_TES == "096","",AllTrim(GetNewPar('ZZ_OPERDRI','25')))
					EndIf
	
					aItem	 := {	{"C6_NUM"			,Space(6)									,Nil},; // Numero do Item no Pedido
					{"C6_ITEM"				,StrZero(nItem,2)										,Nil},; // Numero do Item no Pedido
					{"C6_PRODUTO"		,TRBB6->B6_PRODUTO						,Nil},; // Codigo do Produto
					{"C6_UM"					,TRBB6->B6_UM										,Nil},; // Unidade de Medida Primar.
					{"C6_QTDVEN"		,TRBB6->B6_UTILIZ								,Nil},; // Quantidade Vendida
					{"C6_QTDLIB"			,TRBB6->B6_UTILIZ								,Nil},; // Quantidade Vendida
					{"C6_PRCVEN"		,TRBB6->B6_PRUNIT							,Nil},; // Preco Venda
					{"C6_PRUNIT"			,TRBB6->B6_PRUNIT							,Nil},; // Preco Unitario
					{"C6_VALOR"			,Round(TRBB6->B6_PRUNIT * TRBB6->B6_UTILIZ,TamSX3("C6_VALOR")[2])	,Nil},; // Valor Total do Item
					{"C6_TES"					,_cTes														,Nil},; // Tipo de Entrada/Saida do Item
					{"C6_XOPER"					,cTpxOper						,Nil},; // Tipo de Operação CBC
					{"C6_LOCAL"			,TRBB6->B6_LOCAL								,Nil},; // Almoxarifado
					{"C6_CLI"					,cCliente													,Nil},; // Cliente
					{"C6_IDENTB6"		,TRBB6->B6_IDENT								,Nil},; //Identif Poder3
					{"C6_NFORI"			,TRBB6->B6_DOC									,Nil},; //Identif Poder3
					{"C6_SERIORI"		,TRBB6->B6_SERIE								,Nil},; //Identif Poder3
					{"C6_ITEMORI"			,Posicione("SD1",4,xFilial("SD1")+TRBB6->B6_IDENT,"D1_ITEM") ,Nil},; //Identif Poder3
					{"C6_SEMANA"			,"T"																,Nil},; //Identif Poder3
					{"C6_ENTREG"		,dDataBase												,Nil} }// Data da Entrega
	
					aAdd(aItens,aItem)
					nItem := nItem + 1
				EndIf
				TRBB6->(DbSkip())
			EndDo
			If !lCobr
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1")+cCliente+cLoja,.F.)
				_cRisco := SA1->A1_RISCO
				RecLock("SA1",.F.)
				SA1->A1_RISCO:= "A"
				MsUnLock()
	
				//Executa a inclusão do PV
				LjMsgRun("Gerando Pedido de Venda " + AllTrim(cNumPed),,{||MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCabec, aItens, 3)})
	
				dbSelectArea("SA1")
				dbSetOrder(1)
				dbSeek(xFilial("SA1")+cCliente+cLoja,.F.)
				RecLock("SA1",.F.)
				SA1->A1_RISCO:= _cRisco
				MsUnLock()
	
				If lMsErroAuto
					RollBackSX8()
					MostraErro()
				Else
					//ConfirmSX8()
					_cPedi2 := cNumPed
				EndIf
			EndIf
			CloseBrowse()
		Endif
	Else
		Alert("Possui saldo a utilizar, Favor verificar a seleção! SaldoCobre = "+Str(nQtdCobre))
	EndIf
Return()


/*/{Protheus.doc} MarkClk2
//TODO Função para marcar o OK no MarBrow  .
@author juliana.leme
@since 24/08/2015
@version undefined

@type function
/*/
User Function MarkClk2()
	Local aParamBox 		:= {}
	Local _aReto 			:= {}
	
	If TRBB6->B6_OK == cMarca
		//Valida Qtd Terceiros
		If !(Posicione("SB1",1,xFilial("SB1")+Padr(TRBB6->B6_PRODUTO,TamSX3("B1_COD")[1]),"B1_GRUPO")) $ ("MP03/MP04") //Cobre
			nQtdCobre 	:= nQtdCobre + TRBB6->B6_UTILIZ
		Else
			nQtdPVC	:= nQtdPVC + TRBB6->B6_UTILIZ
		EndIf
		RecLock("TRBB6",.F.)
		TRBB6->B6_OK 		:= " "
		TRBB6->B6_SALDO	:= TRBB6->B6_SALDO+TRBB6->B6_UTILIZ
		TRBB6->B6_UTILIZ 	:= 0
		MsUnLock()
	Else
		_nValSaldo := TRBB6->B6_SALDO-TRBB6->B6_UTILIZ
		aAdd(aParamBox,{9,"Saldo Disponivel: "+ TRANSFORM(_nValSaldo, "@E 999999999.99"),150,7,.F.})
		aAdd(aParamBox,{1,"Saldo a Utilizar: ",_nValSaldo,"@E 9999999.99","mv_par02>0.and.!(mv_par02>TRBB6->B6_SALDO)","","",50,.T.})
		aAdd(aParamBox,{3,"MP NÃO Utiizada ",2,{"Sim","Não"},50,"",.F.})
		If !ParamBox(aParamBox, "Parametros", @_aReto)
			Return(.F.)
		EndIf
		RecLock("TRBB6",.F.)
		TRBB6->B6_OK		:= cMarca
		TRBB6->B6_UTILIZ	:= _aReto[2]
		TRBB6->B6_SALDO	:= TRBB6->B6_SALDO - TRBB6->B6_UTILIZ
		If _aReto[3] = 1
			TRBB6->B6_DEVOLUC	:= "S"
		Else
			TRBB6->B6_DEVOLUC	:= "N"
		EndIf
		MsUnLock()
	EndIf
	MarkBRefresh()
Return(.T.)


/*/{Protheus.doc} ValidPod3
//TODO Função para verificar saldo de Mp no B6 conforme a situação e consumir conforme a necessidade indicada.
@author juliana.leme
@since 24/08/2015	
@version undefined

@type function
/*/
Static Function ValidPod3()
	If !(Posicione("SB1",1,xFilial("SB1")+Padr(TRBB6->B6_PRODUTO,TamSX3("B1_COD")[1]),"B1_GRUPO")) $ ("MP03/MP04") //Cobre
		If nQtdCobre > 0
			If TRBB6->B6_SALDO > nQtdCobre
				RecLock("TRBB6",.F.)
				TRBB6->B6_UTILIZ := nQtdCobre
				nQtdCobre 			:= 0
				MsUnLock()
			Else
				RecLock("TRBB6",.F.)
				TRBB6->B6_UTILIZ 	:= TRBB6->B6_SALDO
				nQtdCobre 			:= nQtdCobre - TRBB6->B6_SALDO
				MsUnLock()
			EndIf
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	ElseIf Posicione("SB1",1,xFilial("SB1")+Padr(TRBB6->B6_PRODUTO,TamSX3("B1_COD")[1]),"B1_GRUPO") $ "MP03/MP04" //PVC
		If nQtdPVC > 0
			If TRBB6->B6_SALDO > nQtdPVC
				RecLock("TRBB6",.F.)
				TRBB6->B6_UTILIZ 	:= nQtdPVC
				nQtdPVC 			:= 0
				MsUnLock()
			Else
				RecLock("TRBB6",.F.)
				TRBB6->B6_UTILIZ 	:= TRBB6->B6_SALDO
				nQtdPVC 			:= nQtdPVC - TRBB6->B6_SALDO
				MsUnLock()
			EndIf
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf
Return (lRet)


/*/{Protheus.doc} IncPedACols
//TODO Inclui Pedido de MP no Acols para faturamento.
@author juliana.leme
@since 24/08/2015
@version undefined
@param cPediMP, characters, descricao
@type function
/*/
User Function IncPedACols(cPediMP)
If cPediMP <> ""
	DbSelectArea("SC9")
	SC9->(DbSeek(xFilial("SC9")+cPediMP,.F.))
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == cPediMP .And. SC9->(!Eof())
		AADD(aCols,Array(Len(aHeader)+1))
		For _ni:= 1 to Len(aHeader)
			If ( aHeader[_ni,10] # "V" )
				aCols[Len(aCols),_ni] := FieldGet(FieldPos(aHeader[_ni,2]))
			Else
				aCols[Len(aCols),_ni] := CriaVar(aHeader[_ni,2])
			EndIf
		Next
		aCols[Len(aCols),Len(aHeader)+1]:=.F.
		SC9->(DbSkip())
	EndDo
EndIf
Return

/*------------------------------------------------------------------------*
| Func:  ExPVDados																|
| Autor: Juliana Leme															|
| Data:  														|
| Desc:  																|
| Obs.:  /																		|
*-----------------------------------------------------------------------*/
/*/{Protheus.doc} ExPVDados
//TODO Monta estrutura PV conforme informado no Parametro cPedExc para exclusão.
@author juliana.leme
@since 24/08/2015		
@version undefined
@param cPedExc, characters, descricao
@type function
/*/
User Function ExPVDados(cPedExc)
	Private aAux1, aCab	:= {}
	// Posiciona as demais tabelas
	Dbselectarea("SC5")
	DbsetOrder(1) // C5_FILIAL+C5_NUM
	SC5->(DbSeek(xFilial("SC5")+cPedExc,.F.))
	
	
	aCab := {}
	aAdd(aCab,{"C5_NUM"		, cPedExc			, Nil	, ""	})
	aAdd(aCab,{"C5_TIPO"	, "N"				, Nil	, ""	})
	aAdd(aCab,{"C5_CLIENTE"	, SC5->C5_CLIENTE	, Nil	, ""	})
	aAdd(aCab,{"C5_LOJACLI"	, SC5->C5_LOJACLI	, Nil	, ""	})
	aAdd(aCab,{"C5_EMISSAO"	, SC5->C5_EMISSAO	, Nil	, ""	})
	aAdd(aCab,{"C5_TIPOCLI"	, SC5->C5_TIPOCLI	, Nil	, ""	})
	aAdd(aCab,{"C5_CLIENT"	, SC5->C5_CLIENT	, Nil	, ""	})
	aAdd(aCab,{"C5_LOJAENT"	, SC5->C5_LOJAENT	, Nil	, ""	})
	aAdd(aCab,{"C5_CONDPAG"	, SC5->C5_CONDPAG	, Nil	, ""	})
	aAdd(aCab,{"C5_MOEDA"	, SC5->C5_MOEDA		, Nil	, ""	})
	aAdd(aCab,{"C5_TPFRETE"	, SC5->C5_TPFRETE	, Nil	, ""	})
	aAdd(aCab,{"C5_TPFRETE"	, SC5->C5_TPFRETE	, Nil	, ""	})
	
	
	Dbselectarea("SC6")
	DbsetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	SC6->(DbSeek(xFilial("SC6")+cPedExc,.F.))
	
	aAux1 := {}
	While (SC6->C6_FILIAL == xFilial("SC6")).and.(SC6->C6_NUM == cPedExc)
		aAdd(aAux1,{"C6_NUM"		, cPedExc			, Nil	, "" })
		aAdd(aAux1,{"C6_ITEM"		, SC6->C6_ITEM		, Nil	, "" })
		aAdd(aAux1,{"C6_CLI"		, SC6->C6_CLI		, Nil	, "" })
		aAdd(aAux1,{"C6_LOJA"		, SC6->C6_LOJA		, Nil	, "" })
		aAdd(aAux1,{"C6_PRODUTO"	, SC6->C6_PRODUTO	, Nil	, "" })
		aAdd(aAux1,{"C6_LOCAL"		, SC6->C6_LOCAL 	, Nil	, "" })
		aAdd(aAux1,{"C6_DESCRI"		, SC6->C6_DESCRI	, Nil	, "" })
		aAdd(aAux1,{"C6_IDENTB6"	, SC6->C6_IDENTB6	, Nil	, "" })
		aAdd(aAux1,{"C6_NFORI"		, SC6->C6_NFORI		, Nil	, "" })
		aAdd(aAux1,{"C6_ITEMORI"	, SC6->C6_ITEMORI	, Nil	, "" })
		aAdd(aAux1,{"C6_ENTREG"		, SC6->C6_ENTREG	, Nil	, "" })
		dbSkip()
	EndDo
	//Realiza a exclusão e o estorno do C9
	If Len(aAux1) > 0
		U_ExcluPv(cPedExc,aCab,aAux1)
	EndIf
Return()


/*/{Protheus.doc} ExcluPv
//TODO Exclui Pedido de Venda conforme informado no Parametro cPedExc.
@author juliana.leme
@since 24/08/2015	
@version undefined
@param cSC5Num, characters, descricao
@param aCab, array, descricao
@param aAux, array, descricao
@type function
/*/
User Function ExcluPv(cSC5Num,aCab,aAux)
	Public _myPed
	Private lMsErroAuto := .F.
	
	dbSelectArea("SC6")
	dbSetOrder(1) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	If MsSeek(xFilial("SC6")+cSC5Num)
		While !Eof() .and. cSC5Num == SC6->C6_NUM .and. xFilial("SC6") == SC6->C6_FILIAL
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Eliminacao de residuo por item de pedido ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SC6->C6_QTDEMP > 0
				dbSelectArea("SC9")
				dbSetOrder(1)
				If MsSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)
					SC9->(a460Estorna())
				Endif
			Endif
			dbSelectArea("SC6")
			dbSkip()
		EndDo
	Endif
	
	dbSelectArea("SC5")
	dbSetOrder(1) //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	SC5->(DbSeek(xFilial("SC5")+cSC5Num,.F.))
	//Executa rotina de exclusão
	MsExecAuto({|x, y, z| MATA410(x, y, z)}, aCab, aAux, 5)
	
	If lMsErroAuto
		MostraErro()
	EndIf
Return()


/*/{Protheus.doc} CSFature
//TODO Realiza o Faturamento da NF .
@author juliana.leme
@since 24/08/2015	
@version undefined

@type function
/*/
Static Function CSFature()

	Local _aPedsFat := {} // By Roberto Oliveira para tratar os pedidos faturados e depois alterar o C5_ZSTATUS
	Private cArq		:= "LogNFe.TXT"
	
	If ! lTransf
		U_IncPedACols(_cPedi2)
	EndIf
	
	// Verificar quantas notas são necessárias
	_naColsAtu  := 1
	_nPosSort := GDFieldPos("C9_PRODUTO")
	aSort(aCols,,,{|x,y| x[_nPosSort]<y[_nPosSort]})
	_ItensNotas := GetMv("MV_NUMITEN")
	_NumNotas   := Int(Len(aCols) / _ItensNotas)
	If (Len(aCols)/_ItensNotas) > _NumNotas
		_NumNotas++
	EndIf
	
	_cNumRom    := ""
	cSerie      := ""
	_lSerie     := .F.
	Do While Empty(cSerie) .And. !_lSerie
		cSerie  := ""
		_lSerie := Sx5NumNota(@cSerie,)
	EndDo
	ProcRegua(_NumNotas)
	For _nNFAtu := 1 to _NumNotas
		IncProc()
		DbSelectArea("SC6")
		DbSetOrder(1)
		_SeqMO := ""
		_SeqMP := ""
	
		// Carregar Array para faturamento
		_nSomaMO := 0.00
		_nSomaMP := 0.00
		_cGrvPed := ""
		aPvlNfs := {}
		For _nItens := 1 to (_ItensNotas-2)
			DbSelectArea("SC9")
			DbSetOrder(1) //C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+SC9->C9_PRODUTO)
			SC9->(DbSeek(xFilial("SC9")+GDFieldGet("C9_PEDIDO",_naColsAtu)+GDFieldGet("C9_ITEM",_naColsAtu)+GDFieldGet("C9_SEQUEN",_naColsAtu),.F.))
			// Calcular o valor de transferência -> Valor do Cobre / Quantidade em metros
			//                             Valor do Cobre                          Quantidade
			//If (Posicione("SB1",1,xFilial("SB1")+Padr(SC9->C9_PRODUTO,TamSX3("B1_COD")[1]),"B1_GRUPO"),2) == "PA" //Cobre
			if calcPrc(Padr(SC9->C9_PRODUTO,TamSX3("B1_COD")[1]))
				If ! lTransf
					_nValUni := Round((GDFieldGet("C9_PRCVEN3" ,_naColsAtu) /  GDFieldGet("C9_QTDLIB"  ,_naColsAtu)),4)
					_nValUni := _nValUni + Round((GDFieldGet("C9_PRCVEN2" ,_naColsAtu) /  GDFieldGet("C9_QTDLIB"  ,_naColsAtu)),4)
				Else
					_nValUni := Round((GDFieldGet("C9_PRCVEN"  ,_naColsAtu) /  GDFieldGet("C9_QTDLIB"  ,_naColsAtu)),4)
					_nValUni := _nValUni + Round((GDFieldGet("C9_PRCVEN3" ,_naColsAtu) /  GDFieldGet("C9_QTDLIB"  ,_naColsAtu)),4)
					_nValUni := _nValUni + Round((GDFieldGet("C9_PRCVEN2" ,_naColsAtu) /  GDFieldGet("C9_QTDLIB"  ,_naColsAtu)),4)
				EndIf
				if Round(_nValUni,4) > 0
					RecLock("SC9",.F.)
					SC9->C9_PRCVEN := Round(_nValUni,4)
					If lTransf 
						SC9->C9_TES 			:= "849"
					EndIf
					MsUnLock()
				endif
			EndIf
	
			// Posiciona as demais tabelas
			Dbselectarea("SC5")
			DbsetOrder(1) // C5_FILIAL+C5_NUM
			SC5->(DbSeek(xFilial("SC5")+SC9->C9_PEDIDO,.F.))
	
			If aScan(_aPedsFat, SC9->C9_PEDIDO) == 0
				Aadd(_aPedsFat, SC9->C9_PEDIDO)
			EndIf
	
			If !(SC9->C9_PEDIDO $ _cGrvPed)
				_cGrvPed := _cGrvPed + SC9->C9_PEDIDO + "/"
			EndIf
	
			Dbselectarea("SC6")
			DbsetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,.F.))
	
			//If Left(Posicione("SB1",1,xFilial("SB1")+Padr(SC9->C9_PRODUTO,TamSX3("B1_COD")[1]),"B1_GRUPO"),2) == "PA" //Cobre
			if calcPrc(Padr(SC9->C9_PRODUTO,TamSX3("B1_COD")[1]))
				if Round(_nValUni,4) > 0
					RecLock("SC6",.F.)
					SC6->C6_PRCVEN 	:= Round(_nValUni,4)
					SC6->C6_PRUNIT 		:= Round(_nValUni,4)
					SC6->C6_VALOR 		:= Round((_nValUni * SC6->C6_QTDVEN),4)
					If lTransf
						SC6->C6_XOPER		:= "09"
						SC6->C6_TES 			:= "849"
						SC6->C6_CF 			:= "6151"
					EndIf
					MsUnLock()
				endif
			EndIf
	
			Dbselectarea("SF4")
			DbsetOrder(1) // F4_FILIAL+F4_CODIGO
			SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES,.F.))
	
			Dbselectarea("SB1")
			DbsetOrder(1) // B1_FILIAL+B1_COD
			SB1->(DbSeek(xFilial("SB1")+SC9->C9_PRODUTO,.F.))
	
			Dbselectarea("SB2")
			DbsetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
			SB2->(DbSeek(xFilial("SB2")+SC9->C9_PRODUTO+SC9->C9_LOCAL,.F.))
	
			Dbselectarea("SB5")
			DbsetOrder(1) // B5_FILIAL+B5_COD
			SB5->(DbSeek(xFilial("SB5")+SC9->C9_PRODUTO,.F.))
	
			aAdd(aPvlNfs,{SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,SC9->C9_QTDLIB,SC9->C9_PRCVEN,;
			SC9->C9_PRODUTO,SF4->F4_ISS=="S",SC9->(RecNo()),;
			SC5->(RecNo()),SC6->(RecNo()),SE4->(RecNo()),;
			SB1->(RecNo()),SB2->(RecNo()),SF4->(RecNo()),SC9->C9_AGREG})
	
			If ++_naColsAtu > Len(aCols) // Não Tem mais nada a faturar
				Exit
			EndIf
		Next
	
		// Gravar Especie/Volume e pesos nos pedidos de venda
		Dbselectarea("SC5")
		DbsetOrder(1) // C5_FILIAL+C5_NUM
	
	
		For _nPsPed := 1 to Len(_cGrvPed)-1 Step Len(SC5->C5_NUM)+1
	
			SC5->(DbSeek(xFilial("SC5")+Substr(_cGrvPed,_nPsPed,Len(SC5->C5_NUM)),.F.))
			RecLock("SC5",.F.)
				
			If _nPsPed == 1
				// Só pode gravar em um pedido somente, caso esteja faturando mais de um
				If Empty(_cEspec) .And. (_nPBrut+_nPLiqu) > 0
					_cEspec := "."
				EndIf
				SC5->C5_TRANSP	:= _cTransp
				SC5->C5_TPFRETE	:= SUBSTR(_cTpFrete,1,1)
				SC5->C5_ESPECI1	:= _cEspec
				SC5->C5_VOLUME1	:= _nVolum
				SC5->C5_PBRUTO	:= _nPBrut
				SC5->C5_PESOL		:= _nPLiqu
				If !lTransf
					SC5->C5_MENNOTA	:= "Valor M.P. Aplic. R$ "+ Alltrim(TRANSFORM(_nTotPvc, "@E 999,999,999.99"))+"// Valor M.O. Aplic. R$ "+;
					Alltrim(TRANSFORM(_nTotMO, "@E 999,999,999.99"))
				endif
			Else
				SC5->C5_ESPECI1 := _cEspec
				SC5->C5_VOLUME1 := 0.0
				SC5->C5_PBRUTO  := 1
				SC5->C5_PESOL   := 1
			EndIf
			MsUnLock()
		Next
	
		If Len(aPvlNfs) > 0
			//Pergunte("MT460A",.F.)
			cNumAtu := MaPvlNfs(aPvlNfs,cSerie,.F.,.F.,.F.,.F.,.F.,0,0,.F., .F.)
			_cNumRom := Soma1(GETMV("MV_CDROMA"))
			DbSelectArea("SX6")
			If !Dbseek(FWCodFil()+"MV_CDROMA",.F.)
				Dbseek("  MV_CDROMA",.F.)
			EndIf
			If !SX6->(Eof())
				Reclock("SX6",.F.)
				SX6->X6_CONTEUD := _cNumRom
				SX6->(MsUnlock())
			Endif			
			//_cNumRom := "NFIND"
			DbSelectArea("SF2")
			RecLock("SF2",.F.)
			SF2->F2_CDROMA  := _cNumRom
			SF2->F2_EMISORI := SF2->F2_EMISSAO
			SF2->(MsUnlock())
		EndIf
	Next
	If !Empty(_cNumRom)
	
		// By Roberto Oliveira 14/10/16 - Inicio
		SC5->(DbSetOrder(1))
		For _nAltStat := 1 to Len(_aPedsFat)
			If SC5->(DbSeek(xFilial("SC5")+_aPedsFat[_nAltStat],.F.))
				RecLock("SC5",.F.)
				SC5->C5_ZSTATUS := '0'
				MsUnLock()
			EndIf
		Next
		// By Roberto Oliveira 14/10/16 - Fim
	
		MsgInfo( "Processamento Concluído, Nota Fiscal Criada! ", "Info" )
		cMsg 		:= ""
		cMsg 		+= "************ NF de INDUSTRIALIZAÇÃO/TRANSFERENCIA *********" + CRLF
		cMsg 		+= " NF Serie/Num: "+SF2->F2_SERIE+"/"+SF2->F2_DOC +"  Dt.Emissao: "+DtoC(SF2->F2_EMISSAO) + CRLF
		dDateLib	:= DaySum(SF2->F2_EMISSAO,1)
		cMsg 		+= " Liberada a Entrada da NFe no dia : " + DtoC(dDateLib) + CRLF
		cMsg 		+= " Favor se atentar ao prazo."+ CRLF
		U_ConsoleLog("NFE INDUSTRIALIZ. CRIADA",cMsg,cArq) //cTipo = (ERRO,CONCLUIDO,EXCESSAO) cMsg = (Mensagem destinada a informação)
	
		Processa({|| U_ArqPorEmail(cArq,"procind@cobrecom.com.br","[ITU - CONCLUIDO]NF de Industrialização/Transferencia")},"Enviando Email Concluido...")
	
		Return (.F.) //-> volta para a rotina pai
	Else
		If ! lTransf
			U_ExPVDados(_cPedi2)
			Alert("Pedido de MP Num.:"+_cPedi2+" EXCLUIDO com sucesso")
		EndIf
	EndIf
Return(.T.)

User Function CbAltPV()
	
Return()

static function vldTriang(cFilOri, cNumPed)
	local lOk := .T.



return(lOk)


static function calcPrc(cProd)
	local aArea    	    := GetArea()
	local aAreaSB1	    := SB1->(getArea())
	local lCalc 		:= .F.
	local lCobre		:= .F.
	local lPvc			:= .F.
	
	DbSelectArea("SB1")
	SB1->(DbsetOrder(1))

	lCobre 	:= ((Posicione("SB1",1,xFilial("SB1")+Padr(cProd,TamSX3("B1_COD")[1]),"B1_PESCOB")) > 0)
	lPvc	:= ((Posicione("SB1",1,xFilial("SB1")+Padr(cProd,TamSX3("B1_COD")[1]),"B1_PESPVC")) > 0)
	
	lCalc := (lCobre .or. lPvc)

	RestArea(aAreaSB1)
	RestArea(aArea)
return(lCalc)
