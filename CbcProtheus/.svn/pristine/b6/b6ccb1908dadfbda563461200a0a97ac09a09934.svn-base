#INCLUDE "rwmake.ch"
#include "TOPCONN.ch"
#include 'Totvs.ch'
#define CRLF Chr(13)+Chr(10)

static cDrive := if(U_zIs12(),'CTREECDX','')

/*/{Protheus.doc} CdEstR16
//TODO Relatorio de Entregas/Faltas.
@author zzz
@since 16/04/2007
@version undefined

@type function
/*/
User Function CdEstR16()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Declaracao de Variaveis                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local cDesc1		:= "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2		:= "de acordo com os parametros informados pelo usuario."
	Local cDesc3		:= "Relatorio de Entregas/Faltas"
	Local cPict			:= ""
	Local titulo			:= "Relatório de Entregas/Faltas"
	Local Cabec1		:= "Nro.PV.   Emissao   Entrega  Client-Lj Tp Nome                         TF Cidade                 UF TFt Cad Vr.Pedido Ftr. Vlr.Liber.   % Vlr.em Est Vlr.Out.PV    Vlr.ESA     Peso Observacao"
	Local Cabec2		:= ""
	Local imprime		:= .T.
	Local aOrd			:= {}
	
	Private nLin		:= 80
	Private lEnd		:= .F.
	Private lAbortPrint	:= .F.
	Private CbTxt		:= ""
	Private limite		:= 220
	Private tamanho	:= "G"
	Private nomeprog:= "CDESTR09a"
	Private nTipo		:= 18
	Private aReturn	:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey	:= 0
	Private cPerg		:= "CDES09"
	Private cbtxt		:= Space(10)
	Private cbcont	:= 00
	Private CONTFL	:= 01
	Private m_pag	:= 01
	Private wnrel		:= "CDESTR09a"
	
	Private cString := "SC6"
	
	dbSelectArea("SC6")
	dbSetOrder(3)
	
	u_VldR09()
	pergunte(cPerg,.t.)

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)
	If nLastKey == 27
		Return
	Endif
	
	SetDefault(aReturn,cString)
	
	If nLastKey == 27
		Return
	Endif
	
	nTipo := If(aReturn[4]==1,15,18)
	
	titulo       := "Relatório de Entregas/Faltas de " + Dtoc(mv_par03) + " ate " + Dtoc(mv_par04)
	If MV_PAR19 > 0
		titulo := titulo + "   ( R$ >= " + AllTrim(Transform(MV_PAR19,"@E 999,999")) + " )"
	EndIf
	
	_cCentury := Upper(Set(_SET_DATEFORMAT))
	Set Century off
	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	If "YYYY" $ _cCentury
		Set Century on
	EndIf

Return(.T.)


/*/{Protheus.doc} RunReport
//TODO Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS monta a janela com a regua de processamento.
@author juliana.leme
@since 01/06/2017
@version undefined
@param Cabec1, , descricao
@param Cabec2, , descricao
@param Titulo, , descricao
@param nLin, numeric, descricao
@type function
/*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local aParamBox 	:= {}
	Local aRet 			:= ""
	local lEmpFatPar	:= .F.
	local aWSheet		:= {}, aTable := {}
	Private aUniMov		:= obtUnMov()
	
	// Se for imprimir por rota, criar arquivo temporario
	If MV_PAR16 > 1 //  1-Dt.Entrega // 2-Rotas //3-Num.Pedido // 4-Ambos
		_cNomArq := ""                               // Arquivo Temporario
		_aCampos := {}
	
		aAdd(_aCampos, {"CLIENTE"			, "C", TamSX3("C5_CLIENTE")[1]	, 0})	//1
		aAdd(_aCampos, {"LOJACLI"			, "C", TamSX3("C5_LOJACLI")[1]	, 0})	//2
		aAdd(_aCampos, {"NUM_PEDIDO"	, "C", TamSX3("C5_NUM")[1]		, 0}) 	//3
		aAdd(_aCampos, {"BLQ"				, "C", 01, 0})									//4
		aAdd(_aCampos, {"NOME"				, "C", 40, 0})									//5
		aAdd(_aCampos, {"ESTADO"			, "C", 02, 0})						//6
		aAdd(_aCampos, {"MUNICIPIO"		, "C", 22, 0})						//7
		aAdd(_aCampos, {"LOC_ENTREG"	, "C", 120,0})						//8
		aAdd(_aCampos, {"ROTA"				, "C", 03, 0})						//9
		aAdd(_aCampos, {"TP_FRETE"		, "C", 01, 0})						//10
		aAdd(_aCampos, {"VLRPED"			, "N", 08, 0})						//11
		aAdd(_aCampos, {"VLRLIB"			, "N", 08, 0})						//12
		aAdd(_aCampos, {"PERLIB"			, "N", 03, 0})						//12
		aAdd(_aCampos, {"VLREST"			, "N", 08, 0})						//13
		aAdd(_aCampos, {"PESO"				, "N", 07, 0})						//14
		aAdd(_aCampos, {"BLQ_VENDAS"	, "C", 15, 0})						//15
		aAdd(_aCampos, {"C5_DTFAT"		, "D", 08, 0})						//16
		aAdd(_aCampos, {"C5_ENTREG"		, "D", 08, 0})						//19
		aAdd(_aCampos, {"DIAS_FATUR"		, "C", 90, 0})						//18
		aAdd(_aCampos, {"OBS1"				, "C", 40, 0})						//20
		aAdd(_aCampos, {"OBS2"				, "C", 40, 0})						//21
		aAdd(_aCampos, {"STATUS"			, "C", 15, 0})						//22
		aAdd(_aCampos, {"PRODUZ"			, "C", 15, 0})						//23
		aAdd(_aCampos, {"C5_EMISSAO"	, "D", 08, 0})
		aAdd(_aCampos, {"C5_DIASNEG"	, "N", 03, 0})
		aAdd(_aCampos, {"C5_TIPOLIB"		, "C", 01, 0})
		aAdd(_aCampos, {"LIBVIR"    		, "C", 01, 0})
		aAdd(_aCampos, {"DIASFAB"   		, "N", 04, 0})
		aAdd(_aCampos, {"VLRFAT"    		, "N", 08, 0})
		aAdd(_aCampos, {"LIBFAT"    		, "N", 08, 0})
		aAdd(_aCampos, {"VLRTRF"    		, "N", 08, 0})
		aAdd(_aCampos, {"LIBTRF"    		, "N", 08, 0})
		aAdd(_aCampos, {"PESOLIB"   		, "N", 08, 0})
		aAdd(_aCampos, {"VLROUT"    		, "N", 08, 0})
		aAdd(_aCampos, {"VLRESA"    		, "N", 08, 0}) //[LEO]
		aAdd(_aCampos, {"TPFAT"     		, "C", 01, 0})
		aAdd(_aCampos, {"FATPARC"     	, "C", 01, 0}) //[LEO]
	
		If Select("TRB") > 0
			DbSelectArea("TRB")
			DbCloseArea()
		EndIf
		
		if U_zIs12()
			_cNomArq := AllTrim(CriaTrab(,.F.))
			FWDBCreate( _cNomArq , _aCampos , "CTREECDX")
		else
			_cNomArq := CriaTrab(_aCampos, .T.)
		endif
		
		DbUseArea(.T.,cDrive, _cNomArq, "TRB", .T., .F.)
		
		Private _cInd := CriaTrab(Nil, .F.)
		IndRegua("TRB", _cInd, "ROTA+NOME",,, "Selecionando Registros...")
		DbSetIndex(_cInd + OrdBagExt())
	EndIf
	DbSelectArea("SC2")
	DBOrderNickName("SC2SEMANA")
	//DbSetOrder(9) // C2_FILIAL+C2_SEMANA+C2_PRODUTO
	
	dbSelectArea("SC5")
	dbSetOrder(1) // C5_FILIAL+C5_NUM
	
	dbSelectArea("SA1")
	dbSetOrder(1) //A1_FILIAL+A1_COD
	
	dbSelectArea("SA3")
	dbSetOrder(1) //A3_FILIAL+A3_COD
	
	dbSelectArea("SF4")
	dbSetOrder(1) //F4_FILIAL+F4_CODIGO
	
	dbSelectArea("SB1")
	dbSetOrder(1) //B1_FILIAL+B1_COD
	
	dbSelectArea("SB2")
	dbSetOrder(1) //B2_FILIAL+B2_COD+B2_LOCAL
	
	dbSelectArea("SBF")
	dbSetOrder(1) //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	
	dbSelectArea("SDC")
	//dbSetOrder(4) //DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_LOCALIZ
	DBOrderNickName("SDCPED")// DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_LOCALIZ
	
	dbSelectArea("SC9")
	dbSetOrder(1)  // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	
	dbSelectArea("SC6")
	dbSetOrder(3)  // C6_FILIAL+ DTOS(C6_ENTREG)+C6_NUM+C6_ITEM
	SetRegua(RecCount())
	_nTotPed 	:= 0.00
	_nTotLib 	:= 0.00
	_nTotFat 	:= 0.00
	_nTLibFat 	:= 0.00
	_nTotTrf 	:= 0.00
	_nTLibTrf 	:= 0.00
	_nTotPeso	:= 0.00
	#IFDEF TOP
		cQUER := " FROM "+RetSqlName("SC5")+" C5,"+RetSqlName("SC6")+" C6,"+RetSqlName("SF4")+" F4"
		cQUER += " WHERE C6.C6_NUM = C5.C5_NUM"
		cQUER += " AND C6.C6_TES  = F4.F4_CODIGO"
		cQUER += " AND F4.F4_FILIAL = '" + xFilial("SF4") + "'"
		cQUER += " AND F4.F4_ESTOQUE = 'S'"
		cQUER += " AND C6.C6_FILIAL = '" + xFilial("SC6") + "'"
		cQUER += " AND C6.C6_QTDENT < C6.C6_QTDVEN"
		cQUER += " AND C6.C6_BLQ <> 'R '"
		cQUER += " AND C5.C5_FILIAL = '" + xFilial("SC5") + "'"
		cQUER += " AND C6.C6_ENTREG  >= '" + DToS(MV_PAR03) + "'"
		cQUER += " AND C6.C6_ENTREG  <= '" + DToS(MV_PAR04) + "'"
		cQUER += " AND C5.C5_EMISSAO >= '" + DToS(MV_PAR14) + "'"
		cQUER += " AND C5.C5_EMISSAO <= '" + DToS(MV_PAR15) + "'"
		cQUER += " AND C6.C6_NUM     >= '" + Mv_Par01 + "'"
		cQUER += " AND C6.C6_NUM     <= '" + Mv_Par02 + "'"
		cQUER += " AND C6.C6_CLI+C6.C6_LOJA >= '" + Mv_Par05+Mv_Par06 + "'"
		cQUER += " AND C6.C6_CLI+C6.C6_LOJA <= '" + Mv_Par07+Mv_Par08 + "'"
		If MV_PAR18 == 2
			cQUER += " AND C6.C6_LOCAL				= '01' "
		EndIf
		cQUER += " AND C5.D_E_L_E_T_ <> '*'"
		cQUER += " AND C6.D_E_L_E_T_ <> '*'"
		cQUER += " AND F4.D_E_L_E_T_ <> '*'"
	
		cQUERY := "SELECT C6.C6_ENTREG,C6.C6_NUM,C6.C6_ITEM,C6.C6_TES " + cQUER + " ORDER BY C6.C6_ENTREG,C5.C5_TOTAL,C6.C6_NUM,C6.C6_ITEM"
		TCQUERY cQuery NEW ALIAS "RSC6"
		dbSelectArea("RSC6")
		dbGoTop()
		
		Do While RSC6->(!Eof())
			_Chave := RSC6->C6_ENTREG+RSC6->C6_NUM
			SC6->(DbSeek(xFilial("SC6")+RSC6->C6_ENTREG+RSC6->C6_NUM+RSC6->C6_ITEM,.F.))
			DbSelectArea("RSC6")
			Do While RSC6->(!Eof()) .And. RSC6->C6_ENTREG+RSC6->C6_NUM == _Chave
				DbSkip()
			EndDo
			DbSelectArea("SC6")
		#ELSE
			DbSeek(xFilial("SC6")+Dtos(MV_PAR03),.T.)
		Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_ENTREG <= MV_PAR04 .And. SC6->(!Eof())
		#ENDIF
	
		If lAbortPrint
			Exit
		Endif
		
		_lTem := .F.
	
		If SC6->C6_NUM >= MV_PAR01 .And. SC6->C6_NUM <= MV_PAR02 .And. SC6->C6_CLI+SC6->C6_LOJA >= MV_PAR05+MV_PAR06 .And. ;
			SC6->C6_CLI+SC6->C6_LOJA <= MV_PAR07+MV_PAR08 .And. SC6->C6_QTDENT < SC6->C6_QTDVEN .And. SC6->C6_BLQ # "R "
	
			SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM,.F.))
			SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
	
			SDC->(DbSeek(xFilial("SDC")+SC6->C6_NUM,.F.))
			Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->DC_PEDIDO == SC6->C6_NUM .And.;
				SDC->DC_ORIGEM # "SC6" .And. SDC->(!Eof())
				SDC->(DbSkip())
			EndDo
	
			_lTemSDC := (SDC->DC_FILIAL == xFilial("SDC") .And. SDC->DC_PEDIDO == SC6->C6_NUM .And.;
						 SDC->DC_ORIGEM == "SC6" .And. SDC->(!Eof()))
	
			If SC5->C5_EMISSAO >= MV_PAR14 .And. SC5->C5_EMISSAO <= MV_PAR15 .And. (dDataBase-SC5->C5_EMISSAO) >= MV_PAR17 .And.;
				!(SC5->C5_VEND1 < MV_PAR09 .Or. SC5->C5_VEND1 > MV_PAR10 .Or. ;
				(MV_PAR11==1 .And. SA1->A1_EST # "SP") .Or. (MV_PAR11==2 .And. SA1->A1_EST == "SP") .Or.;
				(MV_PAR12==1 .And. _lTemSDC))
				_lTem := .T.
			EndIf
	
			SC9->(DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM,.F.))
			Do While SC9->C9_FILIAL ==xFilial("SC9") .And. SC9->C9_PEDIDO == SC6->C6_NUM .And. SC9->(!Eof()) .And. _lTem
				//			If SC9->C9_BLCRED == "09" // Rejeitado
				If SC9->C9_BLCRED $ "09" // Rejeitado por crédito
					_lTem := .F.
					Exit 
				EndIf
				SC9->(DbSkip())
			EndDo
		EndIf
		If _lTem
			SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
			SA3->(DbSeek(xFilial("SA3")+SC5->C5_VEND1,.F.))
			_cNumPed:= SC6->C6_NUM
			_nVlrPed := 0.00
			_nVlrFat := 0.00
			_nVlrTrf := 0.00
			// Liberado Total
			_nVlrLib := 0.00
			_nPesoLib := 0.00
			_nLibFat  := 0.00
			_nLibTrf  := 0.00
	
			_nVlrEst := 0.00
			_nVlrOut := 0.00
			_nVlrEsa := 0.00
			_nPeso   := 0 // Peso total
			_lBlq    	:= .F.
			_lBlqVen    := .F.
	
			//SEGUNGO LOOP APOS PRINCIPAL (POR ITEM ) ACUMULANDO OS VALORES
			Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == _cNumPed .And. SC6->(!Eof())
				IncRegua()
	
				SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES,.F.))
	
				If SC6->C6_QTDENT < SC6->C6_QTDVEN .And. SC6->C6_BLQ # "R " .And. SF4->F4_ESTOQUE == "S"
					dbSelectArea("SC9")
					dbSetOrder(1)  // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
					
					SC9->(DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM,.F.))
					_nQtdSC9 := 0.00
					
					If Alltrim(SC5->C5_LIBEROK) == ""
						_lBlqVen := .T.					
					Else
						Do While SC9->C9_FILIAL ==xFilial("SC9") .And. SC9->C9_PEDIDO == SC6->C6_NUM .And. SC9->C9_ITEM == SC6->C6_ITEM .And. SC9->(!Eof())
							//					If "ADMINISTRADOR" $ Upper(cUserName)
							If Empty(SC9->C9_BLEST+SC9->C9_BLCRED)
								_nQtdSC9 += SC9->C9_QTDLIB
							EndIf
							If !_lBlq .And. SC9->C9_BLCRED == "01"
								_lBlq := .T.
							EndIf
							
							SC9->(DbSkip())
						EndDo
					EndIf
					
					DbSelectArea("SB1")
					DbSetOrder(1)
					DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.)
	
					If SB1->B1_LOCALIZ == "S"
						_cLocaliz := Left(SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5)+Space(Len(SBF->BF_LOCALIZ)),Len(SBF->BF_LOCALIZ))
						_nSldEst := Posicione("SBF",1,xFilial("SBF")+SC6->C6_LOCAL+_cLocaliz+SC6->C6_PRODUTO,"BF_QUANT-BF_EMPENHO")
						_nSldEmp := Posicione("SBF",1,xFilial("SBF")+SC6->C6_LOCAL+_cLocaliz+SC6->C6_PRODUTO,"BF_EMPENHO")
						// 1-BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
					Else
						_nSldEst := Posicione("SB2",1,xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL,"B2_QATU-B2_QEMP")
						_nSldEmp := Posicione("SB2",1,xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL,"B2_QEMP")
						// 1-B2_FILIAL+B2_COD+B2_LOCAL
					EndIf
	
					//LEONARDO 24/02/16 - ( Obter Saldo Produto no ESA )
					_nSldEsa := U_pcfUniEsa('Q'+SC6->C6_PRODUTO,SC6->C6_METRAGE,(SC6->(C6_QTDVEN-SC6->C6_QTDENT)-_nQtdSC9), _nSldEst )
					//FIM LEONARDO
	
					_cTpFat := "N"
					If Left(SA1->A1_CGC,8) == "02544042"
						_nVlrTrf += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SC6->C6_PRCVEN
						_nLibTrf += (_nQtdSC9 * SC6->C6_PRCVEN)
						_cTpFat := "T"
					ElseIf SF4->F4_DUPLIC == "S"
						_nVlrFat += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SC6->C6_PRCVEN
						_nLibFat += (_nQtdSC9 * SC6->C6_PRCVEN)
						_cTpFat := "F"
					EndIf
	
					// Acumular os dados do Pedido
					_nVlrPed  += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SC6->C6_PRCVEN
	
					// Liberado Total
					_nVlrLib  += (_nQtdSC9 * SC6->C6_PRCVEN)
					_nPesoLib += (_nQtdSC9 * SB1->B1_PESCOB)
	
					// Peso Total
					//_nPeso    += (_nQtdSC9 * (SB1->B1_PESPVC + SB1->B1_PESCOB))
					_nPeso    += (_nQtdSC9 * SB1->B1_PESBRU)
	
					_nResto   := 0.00
					If (SC6->C6_QTDVEN-SC6->C6_QTDENT) > _nQtdSC9 // Ainda tem saldo a liberar
						_nQtdEst := Max(Min((SC6->C6_QTDVEN-SC6->C6_QTDENT-_nQtdSC9),_nSldEst),0)
						If _nQtdEst > 0.00 // Tenho Saldo Disponível para liberar
							_nVlrEst += _nQtdEst * SC6->C6_PRCVEN
						EndIf
						_nResto  := SC6->C6_QTDVEN-SC6->C6_QTDENT-_nQtdSC9-_nQtdEst
					EndIf
	
					If _nSldEmp > 0.00 .And.  _nResto > 0.00
						_nQtdEst := Max(Min(_nSldEmp,_nResto),0)
						If _nQtdEst > 0.00 // Tenho Saldo Disponível para liberar
							_nVlrOut += _nQtdEst * SC6->C6_PRCVEN
						EndIf
					EndIf
	
					If _nSldEsa > 0.00 .And.  _nResto > 0.00
						_nQtdEsa := Max(Min(_nSldEsa,_nResto),0)
						If _nQtdEsa > 0.00 // Tenho Saldo ESA Disponível para liberar
							_nVlrEsa += _nQtdEsa * SC6->C6_PRCVEN
						EndIf
					EndIf
	
				EndIf
				DbSelectArea("SC6")
				SC6->(DbSkip())
			EndDo
	
			If lAbortPrint
				@	nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif
			If nLin > 60 .And. (MV_PAR16 == 1 .Or. MV_PAR16 == 4)// Salto de Página. Neste caso o formulario tem 55 linhas...
				If nLin # 80
					@ ++nLin,006 PSAY "*XN = (*)Pedido Bloqueado Credito, (X)Pedido EM FATURAMENTO, (N)Data Entrega Negociada // TP = (N)ormal, (M)anual, (P)riorizado // TFt = (F)A Faturar, (T)A Transferir, (N)Sem Financeiro''
				EndIf
				nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := nLin +2
			Endif	
			_nVlrPed := If(MV_PAR19 > 0 .And. _nVlrPed<MV_PAR19,0,_nVlrPed)
			If _nVlrPed > 0.00
	
				aDados		:= Array(1,30)
				aDados		:= u_InfTrian(xFilial("SC5"),SC5->C5_NUM,"CDESTR09a")
				
				If Len(aDados) = 0
					aDados		:= Array(1,30)
				EndIf
	
				_cObs1 := IIf(Empty(aDados[1,10]),AllTrim(SC5->C5_OBS),(aDados[1,10]))
				_cObs1 += U_CBCRetInd(xFilial("SC5"),SC5->C5_NUM)
				If Len(_cObs1) > 40
					_cObs2 := AllTrim(Substr(_cObs1,41,Len(_cObs1)-40))
					_cObs1 := Left(_cObs1,40)
				Else
					_cObs2 := ""
				EndIf
	
				_nDiasFab := dDataBase-SC5->C5_EMISSAO
	
				If MV_PAR16 > 1 //  1-Dt.Entrega // 2-Rotas // 3-Dt.Entrega //4-Ambos
	
					_cRotaInd := If(Empty(If(FWCodFil() == "01",SA1->A1_ROTA,SA1->A1_ROTA3L)),"999",If(FWCodFil() == "01",SA1->A1_ROTA,SA1->A1_ROTA3L))
	
					//Valida Local de Entrega
					_LocEnt := ""
					If !Empty(Alltrim(SC5->C5_ENDENT1))
						_LocEnt := AllTrim(AllTrim(SC5->C5_ENDENT1) + " " + AllTrim(SC5->C5_ENDENT2))
					Else
						_aAreaA1 := SA1->(GetArea())
						DbSelectArea("SA1")
						DbSetOrder(1)
						If DBSeek(xFilial("SA1")+SC5->C5_CLIENT+SC5->C5_LOJAENT)
							_LocEnt := Alltrim(SA1->A1_END)
							_LocEnt += " - " + Alltrim(SA1->A1_BAIRRO)
							_LocEnt += "   " + Alltrim(SA1->A1_MUN)
							_LocEnt += " - " + Upper(SA1->A1_EST)
						EndIf
						RestArea(_aAreaA1)
					EndIf
	
					_cC5Status := ""
					IF SC5->C5_ZSTATUS<"1"
						_cC5Status := "NORMAL/LIBERADO"
					ElseIf SC5->C5_ZSTATUS==Padr('1',TamSX3("C5_ZSTATUS")[1])
						_cC5Status := "EM SEPARACAO"
					ElseIf SC5->C5_ZSTATUS==Padr('2',TamSX3("C5_ZSTATUS")[1])
						_cC5Status := "EM FATURAMENTO"
					EndIf
					
					_cBlqStat := ""
	
					RecLock("TRB",.T.)
					TRB->NUM_PEDIDO  := SC5->C5_NUM
					If _lBlqVen
						_cBlqStat	:= "V"
					ElseIf _lBlq 
						_cBlqStat	:=  "*"
					ElseIf SC5->C5_ZSTATUS == Padr("2",TamSX3("C5_ZSTATUS")[1])
						_cBlqStat	:= "X"
					EndIf
					
					TRB->BLQ         		:= _cBlqStat
					TRB->BLQ_VENDAS	:= If(SC5->C5_ZZBLVEN=="S","BLOQUEADO","NAO BLOQUEADO") // -OK
					TRB->STATUS			:= _cC5Status
					TRB->PRODUZ			:= If(SC5->C5_DRCPROD=="N","NAO PRODUZIR","PRODUZIR")
					TRB->C5_EMISSAO	:= SC5->C5_EMISSAO
					TRB->C5_DTFAT		:= SC5->C5_DTFAT
					TRB->C5_ENTREG		:= SC5->C5_ENTREG
					TRB->C5_DIASNEG	:= SC5->C5_DIASNEG
					TRB->CLIENTE			:= IIf(Empty(aDados[1,17]),SC5->C5_CLIENTE,aDados[1,17])
					TRB->LOJACLI			:= IIf(Empty(aDados[1,18]),SC5->C5_LOJACLI,aDados[1,18])
					TRB->TP_FRETE		:= SC5->C5_TPFRETE
					TRB->C5_TIPOLIB		:= SC5->C5_TIPOLIB
					TRB->LOC_ENTREG	:= _LocEnt
					TRB->NOME				:= IIf(Empty(aDados[1,2]),SA1->A1_NOME,aDados[1,2])
					TRB->MUNICIPIO		:= IIf(Empty(aDados[1,4]),SA1->A1_MUN,aDados[1,4])
					TRB->ESTADO			:= IIf(Empty(aDados[1,5]),SA1->A1_EST,aDados[1,5])
					TRB->DIAS_FATUR	:= SA1->A1_ZZPRFAT
					TRB->DIASFAB			:= _nDiasFab
					TRB->VLRPED			:= Int(_nVlrPed)
					TRB->VLRLIB			:= Int(_nVlrLib)
					TRB->PERLIB			:= Int(_nVlrLib/_nVlrPed*100)
					TRB->VLRFAT			:= Int(_nVlrFat)
					TRB->LIBFAT			:= Int(_nLibFat)
					TRB->VLRTRF			:= Int(_nVlrTrf)
					TRB->LIBTRF			:= Int(_nLibTrf)
					TRB->PESOLIB			:= _nPesoLib
					TRB->VLREST			:= _nVlrEst
					TRB->VLROUT			:= _nVlrOut
					TRB->VLRESA			:= _nVlrEsa
					TRB->PESO				:= _nPeso
					TRB->OBS1				:= _cObs1
					TRB->OBS2				:= _cObs2
					TRB->ROTA				:= _cRotaInd
					TRB->TPFAT			:= _cTpFat
					TRB->FATPARC			:=	SC5->(C5_PARCIAL)
					MsUnLock()
				EndIf
	
				If MV_PAR16 == 1 .Or. MV_PAR16 == 4 //  1-Dt.Entrega  // 4-Ambos
					@ nLin,000 PSAY SC5->C5_NUM
					
					If _lBlq
						@ nLin,007 PSAY "*"
					EndIf
					If _lBlqVen
						@ nLin,007 PSAY "V"
					EndIf
					If SC5->C5_ZSTATUS == Padr('2',TamSX3("C5_ZSTATUS")[1]) // -OK .And. !GetMv("MV_ZZUSAC9")
						@ nLin,007 PSAY "X"
					EndIf
					//If SC5->C5_DIASNEG > 0 .And. !Empty(SC5->C5_DTENTR)
					If !Empty(SC5->C5_DTENTR)
						@ nLin,007 PSay "N"
					EndIf
					
	
					aDados		:= {{"","","","","","","","","","","","","","","","","","","","",""}}
					aDados		:= u_InfTrian(xFilial("SC5"),SC5->C5_NUM,"CDESTR09a")
					If Len(aDados) = 0
						aDados		:= {{"","","","","","","","","","","","","","","","","","","","",""}}
					EndIf
	
					@ nLin,011 PSAY SC5->C5_EMISSAO
					@ nLin,021 PSAY SC5->C5_ENTREG
					If Empty(aDados[1,1])
						//IF MV_PARAM18
						//@ nLin,028 PSAY SC5->C5_CLIENTE + "-" + SC5->C5_LOJACLI + " " + SC5->C5_TIPOLIB +"  " + Left(SA1->A1_NOME,40)
						@ nLin,029 PSAY SC5->C5_CLIENTE + "-" + SC5->C5_LOJACLI + " " + SC5->C5_TIPOLIB +"  " + Left(SA1->A1_NOME,28)
					Else
						@ nLin,029 PSAY aDados[1,17]  + "-" + aDados[1,18] + " " + aDados[1,20] + "  " + Left(aDados[1,2],28)
					EndIf
	
					@ nLin,071 PSAY SC5->C5_TPFRETE
					@ nLin,074 PSAY IIf(Empty(aDados[1,4]),Left(SA1->A1_MUN,22),Left(aDados[1,4],22))
					@ nLin,097 PSAY IIf(Empty(aDados[1,5]),SA1->A1_EST,aDados[1,5])
					@ nLin,101 PSAY _cTpFat
					@ nLin,103 PSAY _nDiasFab Picture "9999"
					@ nLin,107 PSAY Int(_nVlrPed) Picture "@E 99,999,999"
					_nFator :=_nVlrLib / _nPesoLib
					@ nLin,118 PSAY _nFator Picture "@E 99.9"
					@ nLin,123 PSAY Int(_nVlrLib) Picture "@E 99,999,999"
					@ nLin,134 PSAY Int(_nVlrLib/_nVlrPed*100) Picture "@E 999"
					@ nLin,138 PSAY Int(_nVlrEst) Picture "@E 99,999,999"
					@ nLin,149 PSAY Int(_nVlrOut) Picture "@E 99,999,999"
					@ nLin,160 PSAY Int(_nVlrEsa) Picture "@E 99,999,999"
					@ nLin,171 PSAY Int(_nPeso) Picture "@E 9999,999"
	
					lEmpFatPar := (Alltrim(SC5->(C5_PARCIAL)) == 'N')  
					
					if lEmpFatPar
						@ nLin,180 PSAY '[ACEITA FAT. PARCIAL?] ' + if(SC5->(C5_PARCIAL) == 'S','Sim','Não')
					endif
					If SC5->C5_DTFAT > dDataBase .And. SC5->C5_DTFAT # SC5->C5_EMISSAO
						if lEmpFatPar
							nLin := nLin + 1
						endif
						@ nLin,180 PSAY "ATENCAO: Faturar a partir de"
						@ nLin,209 PSAY SC5->C5_DTFAT
						If !Empty(_cObs1)
							nLin := nLin + 1 // Avanca a linha de impressao
							@ nLin,180 PSAY _cObs1
						EndIf
					Else
						if !empty(_cObs1)
							if lEmpFatPar
								nLin := nLin + 1
							endif
							@ nLin,180 PSAY _cObs1
						endif
					EndIf
					If !Empty(_cObs2)
						nLin := nLin + 1 // Avanca a linha de impressao
						@ nLin,180 PSAY _cObs2
					EndIf
					_nTotPed += _nVlrPed
					_nTotFat += _nVlrFat
					_nTotTrf += _nVlrTrf
	
					If Int(_nVlrLib/_nVlrPed*100) > 99
						_nTotLib   += _nVlrLib
						_nTotPeso  += _nPesoLib
						_nTLibFat  += _nLibFat
						_nTLibTrf  += _nLibTrf
					EndIf
					nLin := nLin + 1 // Avanca a linha de impressao
				EndIf
			EndIf
		Else
			IncRegua()
			DbSelectArea("SC6")
			SC6->(DbSkip())
		EndIf
	EndDo//FIM LOOP SEM IDENTAÇÃO
	#IFDEF TOP
		dbSelectArea("RSC6")
		DbCloseArea("RSC6")
	#ENDIF
	
	If MV_PAR16 == 1 .Or. MV_PAR16 == 4 //  1-Dt.Entrega // 2-Rotas // 3-Ambos
		If _nTotPed+_nTotFat+_nTotLib > 0.00
			_nFator := _nTotLib / _nTotPeso
			@ nLin,086 PSAY "Total Relatorio....."
			@ nLin,107 PSAY Int(_nTotPed) Picture "@E 99,999,999"
			@ nLin,118 PSAY _nFator Picture "@E 99.9"
			@ nLin,123 PSAY Int(_nTotLib) Picture "@E 99,999,999"
			nLin++
			@ nLin,086 PSAY "Total a Faturar....."
			@ nLin,107 PSAY Int(_nTotFat) Picture "@E 99,999,999"
			@ nLin,123 PSAY Int(_nTLibFat) Picture "@E 99,999,999"
			nLin++
			@ nLin,086 PSAY "Total Transfêrencia."
			@ nLin,107 PSAY Int(_nTotTrf) Picture "@E 99,999,999"
			@ nLin,123 PSAY Int(_nTLibTrf) Picture "@E 99,999,999"
			@ ++nLin,006 PSAY '*VXN = (*)Pedido Bloqueado Credito, (V)Pedido Bloq. Vendas, (X)Pedido EM FATURAMENTO, (N)Data Entrega Negociada // TP = (N)ormal, (M)anual, (P)riorizado // TFt = (F)A Faturar, (T)A Transferir, (N)Sem Financeiro''
			//		@   nLin,144 PSAY "* -> Liberacao Virtual - Necessario Fazer Liberacao Efetiva"
		EndIf
	EndIf
	
	If MV_PAR16 > 1 //  1-Dt.Entrega // 2-Rotas // 3-Ambos
		DbSelectArea("TRB")
		DbGoTop()
		nLin  := 80
		m_pag := 01
		_nTotFat := 0
		_nTotPed := 0
		_nTotLib := 0
		_nTLibFat := 0
		_nTLibTrf := 0
		_cRota := "   "
		ProcRegua(LastRec())
		Do While TRB->(!Eof())
			If nLin > 60 // Salto de Página. Neste caso o formulario tem 55 linhas...
				If nLin # 80
					@ ++nLin,006 PSAY '*VXN = (*)Pedido Bloqueado Credito, (V)Pedido Bloq. Vendas, (X)Pedido EM FATURAMENTO, (N)Data Entrega Negociada // TP = (N)ormal, (M)anual, (P)riorizado // TFt = (F)A Faturar, (T)A Transferir, (N)Sem Financeiro''
					//				@   nLin,144 PSAY "* -> Liberacao Virtual - Necessario Fazer Liberacao Efetiva"
				EndIf
				nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := nLin + 2
			Endif
			If _cRota #	TRB->ROTA
				If nLin > 56
					nLin := 61
					Loop
				ElseIf nLin # 8
					nLin++
				EndIf
				_cRota := TRB->ROTA
				If _cRota == "999"
					_cDesRta := "999 - Diversos"
				Else
					DbSelectArea("SZK")
					DbSetOrder(1)
					DbSeek(xFilial("SZK") + _cRota,.F.)
					_cDesRta := _cRota + " - " + SZK->ZK_DESCR
				EndIf
				@ nLin,000 PSAY _cDesRta
				nLin++
			EndIf
			IncRegua()
	
			@ nLin,000 PSAY TRB->NUM_PEDIDO
	
			aDados		:= {{"","","","","","","","","","","","","","","","","","","","",""}}
			aDados		:= u_InfTrian(xFilial("SC5"),TRB->NUM_PEDIDO,"CDESTR09a")
			If Len(aDados) = 0
				aDados		:= {{"","","","","","","","","","","","","","","","","","","","",""}}
			EndIf
	
			@ nLin,007 PSAY TRB->BLQ
	
			//If TRB->C5_DIASNEG > 0 .And. !Empty(TRB->C5_DTENTR)
			/*If !Empty(TRB->C5_DTENTR)
				@ nLin,008 PSay "N"
			EndIf*/
	
			@ nLin,010 PSAY TRB->C5_EMISSAO
			@ nLin,020 PSAY TRB->C5_ENTREG
	
			If Empty(aDados[1,1])
				@ nLin,029 PSAY TRB->CLIENTE + "-" + TRB->LOJACLI + " " + TRB->C5_TIPOLIB +"  "+ Left(TRB->NOME,28)
			Else
				@ nLin,029 PSAY aDados[1,17]  + "-" + aDados[1,18] + " " + aDados[1,20] + "  " + Left(aDados[1,2],28)
			EndIf
			@ nLin,071 PSAY TRB->TP_FRETE
			@ nLin,074 PSAY IIf(Empty(aDados[1,4]),Left(TRB->MUNICIPIO,22),Left(aDados[1,4],22))
			@ nLin,097 PSAY IIf(Empty(aDados[1,5]),TRB->ESTADO,aDados[1,5])
			@ nLin,101 PSAY TRB->TPFAT
			@ nLin,103 PSAY TRB->DIASFAB Picture "9999"
			@ nLin,107 PSAY Int(TRB->VLRPED) Picture "@E 99,999,999"
			_nFator := TRB->VLRLIB / TRB->PESOLIB
			@ nLin,118 PSAY _nFator Picture "@E 99.9"
			@ nLin,123 PSAY Int(TRB->VLRLIB) Picture "@E 99,999,999"
			@ nLin,134 PSAY Int(TRB->VLRLIB/TRB->VLRPED*100) Picture "@E 999"
			@ nLin,138 PSAY Int(TRB->VLREST) Picture "@E 99,999,999"
			@ nLin,149 PSAY Int(TRB->VLROUT) Picture "@E 99,999,999"
			@ nLin,160 PSAY Int(TRB->VLRESA) Picture "@E 99,999,999"
			@ nLin,171 PSAY Int(TRB->PESO) Picture "@E 9999,999"
	
			lEmpFatPar := (Alltrim( TRB->(FATPARC) ) == 'N')
			if lEmpFatPar
				@ nLin,180 PSAY '[ACEITA FAT. PARCIAL?] ' + if(TRB->(FATPARC) == 'S','Sim','Não')
			endif
			If TRB->C5_DTFAT > dDataBase .And. TRB->C5_DTFAT # TRB->C5_EMISSAO
				if lEmpFatPar
					nLin := nLin + 1
				endif
				@ nLin,180 PSAY "ATENCAO: Faturar a partir de"
				@ nLin,209 PSAY TRB->C5_DTFAT
				If !Empty(TRB->OBS1)
					nLin := nLin + 1 // Avanca a linha de impressao
					@ nLin,180 PSAY TRB->OBS1
				EndIf
			Else
				if !empty(TRB->(OBS1))
					if lEmpFatPar
						nLin := nLin + 1
					endif
					@ nLin,180 PSAY TRB->OBS1
				endif
			EndIf
			If !Empty(TRB->OBS2)
				nLin := nLin + 1 // Avanca a linha de impressao
				@ nLin,180 PSAY TRB->OBS2
			EndIf
			_nTotPed += TRB->VLRPED
			_nTotFat += TRB->VLRFAT
			_nTotTrf += TRB->VLRTRF
	
			If Int(TRB->VLRLIB/TRB->VLRPED*100) > 99
				_nTotLib  += TRB->VLRLIB
				_nTotPeso += TRB->PESOLIB
				_nTLibFat  += TRB->LIBFAT
				_nTLibTrf  += TRB->LIBTRF
			EndIf
			nLin := nLin + 1 // Avanca a linha de impressao
			TRB->(DbSkip())
		EndDo
		If _nTotPed+_nTotFat+_nTotLib > 0.00
	
			@ nLin,086 PSAY "Total Relatorio....."
			@ nLin,107 PSAY Int(_nTotPed) Picture "@E 99,999,999"
			@ nLin,118 PSAY _nFator Picture "@E 99.9"
			@ nLin,123 PSAY Int(_nTotLib) Picture "@E 99,999,999"
			nLin++
			@ nLin,086 PSAY "Total a Faturar....."
			@ nLin,107 PSAY Int(_nTotFat) Picture "@E 99,999,999"
			@ nLin,123 PSAY Int(_nTLibFat) Picture "@E 99,999,999"
			nLin++
			@ nLin,086 PSAY "Total Transfêrencia."
			@ nLin,107 PSAY Int(_nTotTrf) Picture "@E 99,999,999"
			@ nLin,123 PSAY Int(_nTLibTrf) Picture "@E 99,999,999"
			@ ++nLin,006 PSAY '*VXN = (*)Pedido Bloqueado Credito, (V)Pedido Bloq. Vendas, (X)Pedido EM FATURAMENTO, (N)Data Entrega Negociada // TP = (N)ormal, (M)anual, (P)riorizado // TFt = (F)A Faturar, (T)A Transferir, (N)Sem Financeiro''
			//		@ nLin,144 PSAY "* -> Liberacao Virtual - Necessario Fazer Liberacao Efetiva"
		EndIf
		DbSelectArea("TRB")
	EndIf
	
	SET DEVICE TO SCREEN
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se impressao em disco, chama o gerenciador de impressao...          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif
	
	MS_FLUSH()
	if MV_PAR16 > 1 //  1-Dt.Entrega // 2-Rotas // 3-Ambos
		if (MsgBox("Deseja Exportar Relatorio para EXCEL? ","Confirma","YesNo"))
			DbSelectArea("TRB")
			TRB->(DbGoTop())
			aTrbArea := TRB->(GetArea())
			aColuna := u_RetTRBCol(aTrbArea)
			aDados 	:= u_RetTRBReg(aTrbArea)
			u_cntPedNF(@aColuna, @aDados)
			aadd(aWSheet,{"Rel.EntrFaltas"})
			aadd(aTable,{"Rel.EntrFaltas"})
			u_TExcArr(aDados,aColuna,aWSheet,aTable)
		endIf
		TRB->(DbCloseArea())
	endif
Return(.T.)


/*/{Protheus.doc} VldR09
//TODO Valida Perguntas.
@author juliana.leme
@since 01/06/2017
@version undefined

@type function
/*/
User Function VldR09()

	_aArea := GetArea()
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	
	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	
	aAdd(aRegs,{cPerg,"01","Do Pedido                    ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até o Pedido                 ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Da Data de Entrega           ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Até a Data de Entrega        ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Do Cliente                   ?","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"06","Da Loja                      ?","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Até o Cliente                ?","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"08","Até a Loja                   ?","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Do Representante             ?","mv_ch9","C",06,0,0,"G","","mv_par09","","","","","","","","","","","","","","","SA3"})
	aAdd(aRegs,{cPerg,"10","Até o Representante          ?","mv_cha","C",06,0,0,"G","","mv_par10",""               ,"","",""        ,"","","","","","","","","","","SA3"})
	aAdd(aRegs,{cPerg,"11","UF Considerar                ?","mv_chb","N",01,0,0,"C","","mv_par11","Só S.P."        ,"","","Sem S.P.","","","Todas UFs","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","PV Considerar                ?","mv_chc","N",01,0,0,"C","","mv_par12","Só c/Empenhados","","","Todos"   ,"","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"13","Imprimir?                    ?","mv_chd","N",01,0,0,"C","","mv_par13","Somente Faltas","","","Todos"   ,"","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"14","Da Data de Emissao           ?","mv_che","D",08,0,0,"G","","mv_par14","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"15","Até a Data de Emissao        ?","mv_chf","D",08,0,0,"G","","mv_par15","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"16","Imprime Em Ordem de          ?","mv_chg","N",01,0,0,"C","","mv_par16","Dt.Entrega","","","Rotas","","","Num.Pedido","","","Ambos","","","","",""})
	aAdd(aRegs,{cPerg,"17","Acima de Quantos Dias        ?","mv_chh","N",03,0,0,"G","","mv_par17","","","","","","","","","","","","","","",""})
	
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
		EndIf
	Next
	
	RestArea(_aArea)

Return(.T.)


/*/{Protheus.doc} pcfUniEsa
//TODO Executa consulta no banco de dados PCFactory para obter o estoque do ESA, dividido por UniMov.
@author Leonardo
@since 01/03/2016
@version undefined
@param cCod, characters, o codigo do produto
@param cMtr, characters, Metragem do Item
@param nFalta, numeric, Quando falta
@param nTemEst, numeric, Quanto tem estoque
@type function
/*/
User Function pcfUniEsa(cCod, cMtr, nFalta, nTemEst)

	//RECEBE: 	o codigo do produto, Metragem do Item, Quando falta, Quanto tem estoque
	//nFalta = ((C6_QTDVEN-SC6->C6_QTDENT) - SC9->C9_QTDLIB)
	//nTemEst = ("BF_QUANT-BF_EMPENHO")  ou "B2_QATU-B2_QEMP"
	
	//RETORNA:  Saldo ESA utilizado
	Local aArea		:= GetArea()
	Local nPos		:= 0
	Local nSldEsa	:= 0
	Local nSigaEsa	:= 0
	Local nQtdEst	:= Max(Min(nFalta,nTemEst),0)
	Local nResto  	:= (nFalta-nTemEst-nQtdEst)
	
	//aUniMov[n][1] = Produto
	//aUniMov[n][2] = Quantidade
	If nResto > 0
	nPos := aScan(aUniMov,{|x|Alltrim(x[1]) $ Alltrim(cCod) })
	If nPos > 0
	While nPos <= Len(aUniMov)
	If Alltrim(aUniMov[nPos,1]) == Alltrim(cCod) .And. nResto > 0
	If aUniMov[nPos,2] >= cMtr
		aUniMov[nPos,2] := (aUniMov[nPos,2] - cMtr)
		nResto			:= (nResto - cMtr)
		nSldEsa			:= (nSldEsa + cMtr)
	EndIf
	EndIf
	nPos++
	EndDo
	EndIf
	EndIf
	
	RestArea(aArea)
Return(nSldEsa)


/*/{Protheus.doc} obtUnMov
//TODO Obtem Informações da Unmov na base do PCFactory para retornar quantidades.
@author juliana.leme
@since 01/06/2017
@version undefined

@type function
/*/
Static Function obtUnMov()
	Local aUnMov	:= {}
	Local cQuery	:= ""
	
	If Select( "UNMOV") > 0
		UNMOV->(dbcloseArea())
		FErase( "UNMOV" + GetDbExtension())
	End If
	
	cQuery := " SELECT Produto, UnMov, Quantidade "
	cQuery += " FROM OpenDataSource('SQLOLEDB','Data Source=192.168.3.4;User ID=Sql_ppi;Password=pcf').PCFactory.dbo.BI_VW_ESTOQUE_PCF "
	cQuery += " WHERE SUBSTRING(Produto,1,1) IN ('Q') "
	cQuery += " AND SUBSTRING( LTRIM( RTRIM(Endereco) ), 1,5) IN ('" +Alltrim(FWCodFIl()) +"WIP')"
	cQuery += " ORDER BY Produto "
	
	TCQUERY cQuery NEW ALIAS "UNMOV"
	
	DbSelectArea("UNMOV")
	UNMOV->(DbGotop())
	
	While !UNMOV->(Eof())
		AAdd(aUnMov, {UNMOV->(Produto), UNMOV->(Quantidade) } )
		UNMOV->(DbSkip())
	EndDo
Return(aUnMov)

user function cntPedNF(aColuna, aDados, lAnali)
	local nX, nY, nQtd 	:= 0
	local cPed	 	:= ""
	local cPedAtu	:= ""
	default lAnali 	:= .F.

	for nX := 1 to len(aColuna)
		aAdd(aColuna[nX],'Faturamentos')
	next nX

	for nX := 1 to len(aDados)
		for nY := 1 to len(aDados[nX])
			if lAnali
				cPed := aDados[nX,nY,01]
			else
				cPed := aDados[nX,nY,03]
			endif
			if cPedAtu <> cPed
				nQtd := faturado(cPed)
				cPedAtu := cPed
			endif
			aAdd(aDados[nX,nY], nQtd)
		next nY
	next nX
return(nil)

static function faturado(cPed)
	local nQtdF 	:= 0
    local oSql		:= LibSqlObj():newLibSqlObj()
	default cPed	:= ""

    oSql:newAlias(qryFaturado(AllTrim(cPed)))
    if oSql:hasRecords()
        oSql:goTop()
        nQtdF := oSql:count()
    endif
    oSql:close()
    FreeObj(oSql)
return(nQtdF)

static function qryFaturado(cPed)
	local cQry := ""

	cQry += " SELECT DISTINCT(D2_DOC+D2_SERIE) AS [QTDNF] "
	cQry += " FROM SD2010 SD2 "
	cQry += " WHERE SD2.D2_FILIAL = '" + xFilial('SD2') + "' "
	cQry += " AND SD2.D2_PEDIDO = '" + cPed + "' "
	cQry += " AND SD2.D_E_L_E_T_ = '' "
return(cQry)
