#INCLUDE "rwmake.ch"
#include "TOPCONN.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CDESTR14  º Autor ³ AP6 IDE            º Data ³  15/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CDESTR14()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := "de acordo com os parametros informados pelo usuario."
Local cDesc3         := "titulo"
Local cPict          := ""
Local titulo       	:= "Follow-up de Carteira de Pedidos de Venda"
Local nLin         	:= 80
Local Cabec1       	:= "Produto          Descrição                                         UM              Obs.:"
Local Cabec2       	:= "Pedido-It Cliente   Nome do Cliente                       Acond.  Emissao Previsao Data PCP  Semana Saldo PV  Qtd.Emp.  Qtd. Est.  A Produz.  Qtd.Entr  Ult. Ent  % Entr  Atend.  Vlr. Item Cobre-Kg PVC-Kg. Ft.Cobre Ft.Ac."
Local imprime      	:= .T.
Local aOrd 			:= {}
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private CbTxt        := ""
Private limite		:= 220
Private tamanho		:= "G"
Private nomeprog		:= "CDESTR14" // Coloque aqui o nome do programa para impressao no cabecalho
Private nTipo			:= GetMv("MV_COMP")
//Private nTipo		:= 18
Private aReturn		:= { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey		:= 0
Private cbtxt			:= Space(10)
Private cbcont		:= 00
Private CONTFL		:= 01
Private m_pag			:= 01
Private wnrel			:= "CDESTR14" // Coloque aqui o nome do arquivo usado para impressao em disco
Private cPerg        := "CDE014"
Private cString		:= "SC6"

dbSelectArea("SC6")
dbSetOrder(1)

ValidPerg()
pergunte(cPerg,.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho,,.T.)

If nLastKey == 27
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
	Return
Endif

nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cCentury := Upper(Set(_SET_DATEFORMAT))
Set Century off
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
If "YYYY" $ _cCentury
	Set Century on
EndIf
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPORT º Autor ³ AP6 IDE            º Data ³  15/01/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Programa principal                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
private aWSheet := {}, aTable := {}, aColuna := {}, aDados := {}
Private __cNomArq := ""                               // Arquivo Temporario
Private _aCampos := {}
private cPedItemMg	:= '', ccbcFil := ''

aAdd(_aCampos, {"PEDIDO" , "C", TamSX3("C6_NUM")[1], 0})       // Numero do Pedido de Venda
aAdd(_aCampos, {"ITEMPV" , "C", TamSX3("C6_ITEM")[1], 0})       // Item do Pedido de Vanda
aAdd(_aCampos, {"NOMECLI", "C", 30, 0})       // Nome do cliente - Solicitado pelo Pedro Natal em 13/02/17 By Roberto Oliveira 13/2/17
aAdd(_aCampos, {"STATPED", "C", 2, 0}) 
aAdd(_aCampos, {"PROD"   , "C", TamSX3("B1_COD")[1], 0})
aAdd(_aCampos, {"DESC"   , "C", 40, 0})
aAdd(_aCampos, {"ACOND"  , "C", TamSX3("BE_LOCALIZ")[1], 0})
aAdd(_aCampos, {"APROD"  , "N", 11, 2})
//aAdd(_aCampos, {"QTDCRD" , "N", 11, 2})
aAdd(_aCampos, {"QTDBLQ" , "N", 11, 2})
aAdd(_aCampos, {"QTDLIB" , "N", 11, 2})
aAdd(_aCampos, {"SALDOE" , "N", 14, 2})
aAdd(_aCampos, {"SEMANA" , "C", TamSX3("C6_SEMANA")[1], 2})
aAdd(_aCampos, {"NEGOC"  , "C", 10, 0})
aAdd(_aCampos, {"ENTRG"  , "D", 08, 0})

If xFilial("SC6") == '02' // Só para 3 Lagoas
	aAdd(_aCampos, {"PEDTRF" , "C", TamSX3("C6_NUM")[1], 0})	// Numero do Pedido de transferência
	aAdd(_aCampos, {"ITETRF" , "C", TamSX3("C6_ITEM")[1], 0})	// Item do Pedido de transferência
	aAdd(_aCampos, {"FATTRF" , "N", 11, 2})						// Qtd.Faturada - Transferência
	aAdd(_aCampos, {"LIBTRF" , "N", 11, 2})						// Qtd.LIBERADA - Transferência
	aAdd(_aCampos, {"APRODTRF" , "N", 11, 2})					// Qtd.AINDA NÃO LIBERADA - Transferência
EndIf

If Select("TRB") > 0
	DbSelectArea("TRB")
	DbCloseArea()
EndIf

_cNomArq := CriaTrab(_aCampos, .T.)
DbUseArea(.T.,, _cNomArq, "TRB", .T., .F.)

Private _cInd := CriaTrab(Nil, .F.)
If MV_PAR11 == 1 // Produto
	IndRegua("TRB", _cInd, "PROD + PEDIDO + ITEMPV",,, "Selecionando Registros...")
Else //  2 - Pedido de venda
	IndRegua("TRB", _cInd, "PEDIDO + ITEMPV",,, "Selecionando Registros...")
EndIf
DbSetIndex(_cInd + OrdBagExt())

If MV_PAR11 == 1 // Produto
	Cabec1       := "Produto             Descrição                                         UM           Obs.:"
	Cabec2       := "Pedido-It Cliente   Nome do Cliente                       Acond.  Emissao Previsao  Data PCP  Semana Saldo PV Qtd.Emp.  Qtd. Est.  A Produz.  Qtd.Entr  Ult. Ent  % Entr  Atend.  Vlr. Item Cobre-Kg PVC-Kg. Ft.Cobre Ft.Ac."
Else
	Cabec1       := "Pedido   Cliente    Nome do Cliente                                                  St.Ped.	            Obs.:""
	Cabec2       := "It Produto          Descrição                            Acond.   Emissao  Previsao  Data PCP   Semana  Saldo PV  Qtd.Emp.  Qtd. Est.  A Produz.  Qtd.Entr     Vlr. Item   Vlr.Dispon.  Cobre-Kg  PVC-Kg.  Ft.Cobre  Ft.Ac."
EndIf	

DbSelectArea("SC9")
DbSetOrder(1)  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

SF4->(DbSetOrder(1))                 

SBF->(DbSetOrder(1)) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE

DbSelectArea("SC5")
DbSetOrder(1)  //C5_FILIAL+C5_NUM


#IFDEF TOP
	cQUER := " FROM "+RetSqlName("SC5")+" C5, "+RetSqlName("SC6")+" C6,"+RetSqlName("SF4")+" F4"
	cQUER += " WHERE C6.C6_NUM = C5.C5_NUM"
	cQUER += " AND C6.C6_TES  = F4.F4_CODIGO"
	cQUER += " AND F4.F4_FILIAL = '" + xFilial("SF4") + "'"
	cQUER += " AND F4.F4_ESTOQUE = 'S'"
	cQUER += " AND C6.C6_FILIAL = '" + xFilial("SC6") + "'"
	cQUER += " AND C6.C6_QTDVEN > C6.C6_QTDENT"
	cQUER += " AND C6.C6_BLQ <> 'R '"
	cQUER += " AND C6.C6_PRODUTO >='" +  MV_PAR07 + "'"
	cQUER += " AND C6.C6_PRODUTO <='" +  MV_PAR08 + "'"
	cQUER += " AND C5.C5_FILIAL = '" + xFilial("SC5") + "'"
	cQUER += " AND C6.C6_ENTREG  >= '" + DToS(MV_PAR09) + "'"
	cQUER += " AND C6.C6_ENTREG  <= '" + DToS(MV_PAR10) + "'"
	cQUER += " AND C5.C5_NUM     >= '" + Mv_Par01 + "'"
	cQUER += " AND C5.C5_NUM     <= '" + Mv_Par02 + "'"
	cQUER += " AND C5.C5_CLIENTE+C5.C5_LOJACLI >= '" + Mv_Par03 + Mv_Par04 + "'"
	cQUER += " AND C5.C5_CLIENTE+C5.C5_LOJACLI <= '" + Mv_Par05 + Mv_Par06 + "'"
	If MV_PAR12 == 2
		// Filtrar ? Só Dt.Negoc.
		cQUER += " AND C5.C5_DTENTR <>  ''"
	EndIf
	cQUER += " AND C5.C5_LIBEROK <> 'E'"
	cQUER += " AND C5.D_E_L_E_T_ <> '*'"
	cQUER += " AND C6.D_E_L_E_T_ <> '*'"
	cQUER += " AND F4.D_E_L_E_T_ <> '*'"
	
	cQUERY := "SELECT Count(C5.C5_NUM) as QtdReg " + cQUER
	TCQUERY cQuery NEW ALIAS "RSC5"
	dbSelectArea("RSC5")
	dbGoTop()         
	_Total := RSC5->QtdReg
	DbCloseArea("RSC5")
	
	cQUERY := "SELECT C5.C5_NUM " + cQUER + " ORDER BY C5.C5_NUM"
	TCQUERY cQuery NEW ALIAS "RSC5"
	dbSelectArea("RSC5")
	dbGoTop()          
#ENDIF
#IFDEF TOP
	_AliasC5 := "RSC5"
	SetRegua(_Total)
	Do While RSC5->(!Eof())
		_cNumPd := RSC5->C5_NUM
		Do While RSC5->(!Eof()) .And. RSC5->C5_NUM ==  _cNumPd
			IncRegua()
			RSC5->(DbSkip())
		EndDo
		SC5->(DbSeek(xFilial("SC5")+_cNumPd,.F.))
	#ELSE
		_AliasC5 := "SC5"
		SetRegua(RecCount())
		DbSeek(xFilial("SC5")+Mv_Par01,.T.)
		Do While SC5->C5_FILIAL == xFilial("SC5") .And. SC5->C5_NUM <= Mv_Par02 .And. SC5->(!Eof())
			IncRegua()	
	#ENDIF

		If lAbortPrint
			@ nLin,000 PSay "*** CANCELADO PELO OPERADOR ***"
			Exit
		EndIf
		// se tiver eliminado residuo??
		If SC5->C5_CLIENTE+SC5->C5_LOJACLI < Mv_Par03+Mv_Par04 .Or. SC5->C5_CLIENTE+SC5->C5_LOJACLI > Mv_Par05+Mv_Par06 .Or. ;
			SC5->C5_LIBEROK == "E"
			DbSelectArea(_AliasC5)
			#IFNDEF TOP
				DbSkip()
			#ENDIF
			Loop
		EndIf
		
		DbSelectArea("SC6")
		DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		DbSeek(xFilial("SC6")+SC5->C5_NUM,.F.)
		Do While SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+SC5->C5_NUM .And. SC6->(!Eof())
			If SC6->C6_BLQ # "R " .And. ;
				SC6->C6_PRODUTO >= MV_PAR07 .And. SC6->C6_PRODUTO <= MV_PAR08 .And. ;
				SC6->C6_ENTREG  >= MV_PAR09 .And. SC6->C6_ENTREG  <= MV_PAR10
				// "R" - Residuo eliminado
			
				SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES,.F.))
				If SC6->C6_QTDVEN > SC6->C6_QTDENT .And. SF4->F4_ESTOQUE == "S" // Somente do saldo a faturar    
					//				_QTDCRD := 0.00
					_QTDBLQ := 0.00
					_QTDLIB := 0.00
			
					DbSelectArea("SC9")
					DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
					DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM,.F.)
					Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO+SC9->C9_ITEM == SC6->C6_NUM+SC6->C6_ITEM .And. SC9->(!Eof())
						//					If SC9->C9_BLCRED == "01" // Bloqueado
						//						_QTDCRD += SC9->C9_QTDLIB /
						//					Else
						If SC9->C9_BLCRED == "  " .And. SC9->C9_BLEST == "02" // Liberado Crédito e Bloqueado Estoque
							_QTDBLQ += SC9->C9_QTDLIB
						ElseIf SC9->C9_BLCRED == "  " .And. SC9->C9_BLEST == "  " // Liberado Crédito e Liberado  Estoque
							_QTDLIB += SC9->C9_QTDLIB
						EndIf
						SC9->(DbSkip())
					EndDo  
		
					If _QTDBLQ+_QTDLIB > 0.00
						_cAcond := Left(SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5)+Space(Len(SBF->BF_LOCALIZ)),Len(SBF->BF_LOCALIZ))
		
						SBF->(DbSeek(xFilial("SBF")+SC6->C6_LOCAL+_cAcond+SC6->C6_PRODUTO,.F.)) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		
						DbSelectArea("TRB")
						_cChave := If(MV_PAR11 == 1,SC6->C6_PRODUTO+SC6->C6_NUM+SC6->C6_ITEM,SC6->C6_NUM+SC6->C6_ITEM)
						If !DbSeek(_cChave,.F.)
							RecLock("TRB",.T.)
							TRB->PROD   := SC6->C6_PRODUTO
							TRB->DESC   := u_CortaDesc(Posicione("SB1",1,xFilial("SB1")+SC6->C6_PRODUTO,"B1_DESC"))
							TRB->PEDIDO := SC6->C6_NUM
							TRB->ITEMPV := SC6->C6_ITEM
							TRB->STATPED := IIf(SC5->C5_ZSTATUS=="2","Ft","")
							TRB->NOMECLI:= Posicione("SA1",1,xFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA,"A1_NOME")
							TRB->ACOND  := SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5)
							TRB->SEMANA := SC6->C6_SEMANA
						Else
							RecLock("TRB",.F.)
						EndIf      
						TRB->SALDOE := If(SBF->BF_EMPENHO >=0,(SBF->BF_QUANT-SBF->BF_EMPENHO),0)
						//					TRB->QTDCRD := _QTDCRD
						TRB->QTDBLQ := _QTDBLQ
						TRB->QTDLIB := _QTDLIB
						//If SC5->C5_DIASNEG > 0 .And. !Empty(SC5->C5_DTENTR)
						//If SC6->C6_FILIAL == '02'  
							If !Empty(SC5->C5_DTENTR)
								TRB->NEGOC := "Negoc."
							EndIf
							TRB->ENTRG := SC5->C5_ENTREG
						//EndIf
						MsUnLock()
						
						// Inicio - By Roberto Oliveira 21/09/16 - Renê solicitou a inclusão das quantidades que estão faturadas ou liberadas para 
						// transferir - pedidos de industrialização
						If !Empty(SC6->C6_ZZPVORI) .And. SC6->C6_FILIAL == '02' // Tem um pedido de transferência?
							_QTDLIB := 0.00
							_QTDFAT := 0.00
					
							DbSelectArea("SC9")
							DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
							DbSeek('01'+SC6->C6_ZZPVORI,.F.)
							Do While SC9->C9_FILIAL == '01' .And. SC9->C9_PEDIDO+SC9->C9_ITEM == SC6->C6_ZZPVORI .And. SC9->(!Eof())
								If SC9->C9_BLCRED == "  " .And. SC9->C9_BLEST == "  " // Liberado Crédito e Liberado  Estoque
									_QTDLIB += SC9->C9_QTDLIB
								ElseIf SC9->C9_BLCRED == "10" .Or.  SC9->C9_BLEST == "10" // Faturado
									_QTDFAT += SC9->C9_QTDLIB
								EndIf
								SC9->(DbSkip())
							EndDo  

							RecLock("TRB",.F.)
							TRB->PEDTRF := Left(SC6->C6_ZZPVORI,6)
							TRB->ITETRF := Right(SC6->C6_ZZPVORI,2)
							TRB->FATTRF := TRB->FATTRF + _QTDFAT
							TRB->LIBTRF := TRB->LIBTRF + _QTDLIB
							MsUnLock()
						elseif (!Empty(SC5->C5_X_IDVEN) .and. Alltrim(SC6->C6_SEMANA) == "TRIANG") .And.;
								SC6->C6_FILIAL == '02' // Tem um pedido de transferência?
							_QTDLIB := 0.00
							_QTDFAT := 0.00

							ccbcFil := cFilAnt
							cFilAnt := "01" // Itu
							cPedItemMg	:= u_pedTriangMG("02",SC6->C6_NUM, SC6->C6_ITEM)[2]
							cFilAnt := ccbcFil // Volta Filial
							if !empty(cPedItemMg)
								DbSelectArea("SC9")
								DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
								DbSeek('01'+ cPedItemMg,.F.)
								Do While SC9->C9_FILIAL == '01' .And. SC9->C9_PEDIDO+SC9->C9_ITEM == cPedItemMg	.And. SC9->(!Eof())
									If SC9->C9_BLCRED == "  " .And. SC9->C9_BLEST == "  " // Liberado Crédito e Liberado  Estoque
										_QTDLIB += SC9->C9_QTDLIB
									ElseIf SC9->C9_BLCRED == "10" .Or.  SC9->C9_BLEST == "10" // Faturado
										_QTDFAT += SC9->C9_QTDLIB
									EndIf
									SC9->(DbSkip())
								EndDo  

								RecLock("TRB",.F.)
								TRB->PEDTRF := Left(cPedItemMg,6)
								TRB->ITETRF := Right(cPedItemMg,2)
								TRB->FATTRF := TRB->FATTRF + _QTDFAT
								TRB->LIBTRF := TRB->LIBTRF + _QTDLIB
								MsUnLock()
							endif
						EndIf
						// Fim - By Roberto Oliveira 21/09/16 - Renê solicitou a inclusão das quantidades que estão faturadas ou liberadas para 
					EndIf
				Endif
			EndIf
			SC6->(DbSkip())
		EndDo
		DbSelectArea(_AliasC5)
		#IFNDEF TOP
			DbSkip()
		#ENDIF
	EndDo
		
	#IFDEF TOP
		DbSelectArea("RSC5")
		DbCloseArea("RSC5")
	#ENDIF
		
	If MV_PAR11 == 1
		SB1->(DbSetOrder(1))
		
		SC5->(DbSetOrder(1))
		
		SC6->(DbSetOrder(1))
		
		SA1->(DbSetOrder(1))
		
		_nTgQCob :=  0
		_nTgCbPr :=  0
		_nTgqPvc :=  0
		_nTgVlr  :=  0
		
		dbSelectArea("TRB")
		SetRegua(RecCount())
		dbGoTop()
		Do While TRB->(!EOF())
			If lAbortPrint
				@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
				Exit
			Endif
			_nImpProd := 0 // Imprime o produto
			_Prod := TRB->PROD
		
			SB1->(DbSeek(xFilial("SB1")+_Prod,.F.))
			_nTQtPv :=  0
			_nTQEmp :=  0
			_nTQPro :=  0
			_nTVlr  :=  0
			_nTQCob :=  0
			_nTqPvc :=  0
			_aSds := {}
			Do While  TRB->PROD  == _Prod .And. TRB->(!EOF())
				IncRegua()	
				If nLin > 63 .Or. (nLin > 60 .And. _nImpProd == 0)  // Salto de Página. Neste caso o formulario tem 55 linhas...
					nLin := Cabec(Titulo+If(MV_PAR12==2,"Negoc.",""),Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
					nLin++                                       
					If _nImpProd > 1
						_nImpProd := 1 // Imprime o produto
					EndIf
				Endif
				If _nImpProd < 2
					If _nImpProd == 0 .And. nLin > 9
						nLin++
					EndIf
					@ nLin,000 PSay _Prod
					@ nLin,020 PSay Left(SB1->B1_DESC,50)
					@ nLin,070 PSay SB1->B1_UM                   
					
					SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM,.F.))
					If SC5->C5_CONDPAG == "000"
						@ nLin,084 PSay "BNDES"
					EndIf
		
					If _nImpProd == 1
						@ nLin,099 PSay "Continuação"
					EndIf
					nLin++      
					_nImpProd := 2
				EndIf
				SC6->(DbSeek(xFilial("SC6")+TRB->PEDIDO+TRB->ITEMPV,.F.))
		
				SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM,.F.))
		
				SA1->(DbSeek(xFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA,.F.))
		
				/*Processo de Industrialização
				Juliana Leme - 16/09/2015
				*/
				aDados		:= {{"","","","","","","","","","","","","","","","","",""}}
				aDados		:= u_InfTrian(xFilial("SC5"),TRB->PEDIDO,"CDESTR14")
				If Len(aDados) = 0
					aDados		:= {{"","","","","","","","","","","","","","","","","",""}}
				EndIf			
		
				//If SC5->C5_DIASNEG > 0 .And. !Empty(SC5->C5_DTENTR)
				If !Empty(SC5->C5_DTENTR)
		   			RecLock("TRB",.F.)
					TRB->NEGOC := "Negoc."
					TRB->ENTRG := SC5->C5_ENTREG
					MsUnLock()	
				EndIf
		
				@ nLin,000 PSay TRB->PEDIDO+"-"+TRB->ITEMPV
				@ nLin,010 PSay Iif(Empty(aDados[1,17]),SC6->C6_CLI+"-"+SC6->C6_LOJA,Alltrim(aDados[1,17]+"-"+aDados[1,18]))
				@ nLin,020 PSay Iif(Empty(aDados[1,2]),Left(SA1->A1_NOME,37),Left(aDados[1,2],37))
				@ nLin,058 PSay AllTrim(TRB->ACOND)
				@ nLin,065 PSay IIf(Empty(aDados[1,13]),SC5->C5_EMISSAO,DtoC(StoD(aDados[1,13])))
				@ nLin,074 PSay IIf(Empty(aDados[1,12]),SC6->C6_ENTREG,DtoC(StoD(aDados[1,12])))
				@ nLin,081 PSay If(!Empty(TRB->NEGOC),"**","")
				@ nLin,091 PSay TRB->STATPED
				
				// By Roberto 09/01/15
				// Até que entre no ar o PreActor, será impresso o C5_DTEPA2
				// No SC5 e SC¨existem os campos C?_DTEPA E C?_DTEPA2. Esses campos recebem a data prevista 
				// para entrega do material no EPA e o C?_DTEPA somente será atualizado se estiver vazio e 
				// o C?_DTEPA2 será atualizado sempre.
				// No início, para não confundir, será impresso C5_DTEPA2 e depois que tivermos a informação 
				// correta por item o C6_DTEPA2.
				//
				// Alterar também CDESTR20 e CDESTR09
				
				@ nLin,084 PSay SC5->C5_DTEPA2
				
				If !Empty(SC6->C6_SEMANA)
					If Left(SC6->C6_SEMANA,1) $ "0123456789"
						@ nLin,093 PSay Substr(SC6->C6_SEMANA,5,2)+"/"+Left(SC6->C6_SEMANA,4)
					ElseIf Left(SC6->C6_SEMANA,3) == "DRC"
						// Em 15/04/14 Jeferson achou que não convem mostrar o campo C6_SEMANA que está
						// com DRC9999. Pediu para colocar a expressão Prod.=N.
						@ nLin,093 PSay "Prod.=N"
					Else
						@ nLin,093 PSay SC6->C6_SEMANA
					EndIf
				EndIf			                                            
		
				_nPosSd := aScan(_aSds, {|x|x[1]==TRB->ACOND})
				If _nPosSd == 0
					Aadd(_aSds,{TRB->ACOND,TRB->SALDOE})
					_nPosSd := Len(_aSds)
				EndIf
				if !Alltrim(SC6->C6_QTDVEN) == 'TRIANG' 
					_nQtdProd := (SC6->C6_QTDVEN-SC6->C6_QTDENT-TRB->QTDLIB)
					_nAProduz := 0.00
					If  _nQtdProd > _aSds[_nPosSd,2] .And. _aSds[_nPosSd,2]  > 0
						_nAProduz := _nQtdProd - _aSds[_nPosSd,2]
					ElseIf _aSds[_nPosSd,2]  <= 0
						_nAProduz := _nQtdProd
					EndIf
					_aSds[_nPosSd,2] := _aSds[_nPosSd,2]-_nQtdProd
					If Left(TRB->ACOND,1) == "T"
						_nAProduz := 0.00 // Não se produz retalho
					EndIf
				else
					_nAProduz := 0.00 // Armazem 10 Transferencia Itu X MG
				endif
				
				_nCBR     := (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_PESCOB
				_nPVC     := (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_PESPVC
				_nFtCB    := ((SC6->C6_QTDVEN-SC6->C6_QTDENT) * SC6->C6_PRCVEN) / _nCBR
				
				_nTQtPv +=  (SC6->C6_QTDVEN-SC6->C6_QTDENT)
				_nTQEmp +=  TRB->QTDLIB
				_nTQPro +=  _nAProduz
				_nTVlr  +=  (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SC6->C6_PRCVEN
				_nTQCob +=  _nCBR
				_nTqPvc +=  _nPVC
				_nTgQCob +=  _nCBR
				_nTgqPvc +=  _nPVC
				_nTgCbPr += _nAProduz * SB1->B1_PESCOB
				_nTgVlr  += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SC6->C6_PRCVEN
		
				@ nLin,101 PSay (SC6->C6_QTDVEN-SC6->C6_QTDENT) Picture "@E 9999,999"
				@ nLin,110 PSay TRB->QTDLIB Picture "@E 9999,999"
				@ nLin,120 PSay TRB->SALDOE Picture "@E 99999,999"
				@ nLin,131 PSay _nAProduz Picture "@E 99999,999"
				@ nLin,142 PSay SC6->C6_QTDENT Picture "@E 9999,999"
				@ nLin,152 PSay SC6->C6_DATFAT
				@ nLin,162 PSay (SC6->C6_QTDENT / SC6->C6_QTDVEN) * 100 Picture "@E 999.99"
				//		@ nLin,170 PSay 
				@ nLin,178 PSay (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SC6->C6_PRCVEN Picture "@E 99999,999"
				@ nLin,188 PSay _nCBR Picture "@E 9999,999"
				@ nLin,197 PSay _nPVC Picture "@E 999,999"
				@ nLin,206 PSay _nFtCB Picture "@E 9999.99"
				@ nLin,214 PSay(_nTVlr/_nTQCob) Picture "@E 999.99"
				nLin := nLin + 1 // Avanca a linha de impressao
				RecLock("TRB",.F.)
				TRB->APROD := _nAProduz
				MsUnLock()
				TRB->(DbSkip())
			EndDo
			@ nLin,065 PSay "Total do Produto"
			@ nLin,100 PSay _nTQtPv Picture "@E 9999,999"
			@ nLin,110 PSay _nTQEmp Picture "@E 9999,999"
			@ nLin,131 PSay _nTQPro Picture "@E 99999,999"
			@ nLin,178 PSay _nTVlr  Picture "@E 99999,999"
			@ nLin,188 PSay _nTQCob Picture "@E 9999,999"
			@ nLin,197 PSay _nTqPvc Picture "@E 999,999"
			nLin := nLin + 1 // Avanca a linha de impressao
		EndDo
		If (_nTgQCob + _nTgqPvc) > 0
			@ nLin,065 PSay "Totais do Valor, Cobre e PVC"
			@ nLin,178 PSay _nTgVlr  Picture "@E 99999,999"
			@ nLin,188 PSay _nTgQCob Picture "@E 9999,999"
			@ nLin,197 PSay _nTgqPvc Picture "@E 999,999"
			nLin := nLin + 1 // Avanca a linha de impressao
		EndIf                       
		If _nTgCbPr > 0
			@ nLin,065 PSay "Total Cobre a Produzir"
			@ nLin,188 PSay _nTgCbPr Picture "@E 9999,999"
			nLin := nLin + 1 // Avanca a linha de impressao
		EndIf                   
	Else         
	SB1->(DbSetOrder(1))
		
	SC5->(DbSetOrder(1))
		
	SC6->(DbSetOrder(1))
		
	SA1->(DbSetOrder(1))
		
	_nTgQCob :=  0
	_nTgCbPr :=  0
	_nTgqPvc :=  0
	_nTgVlr  :=  0
	_nTgLiq  :=  0
	_aSds := {}
	
	dbSelectArea("TRB")
	SetRegua(RecCount())
	dbGoTop()
	Do While TRB->(!EOF())
		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif
		
		_nImpPed := 0 // Imprime o produto
		_Pedi    := TRB->PEDIDO
		
		SC6->(DbSeek(xFilial("SC6")+TRB->PEDIDO+TRB->ITEMPV,.F.))
		SC5->(DbSeek(xFilial("SC5")+SC6->C6_NUM,.F.))
		SA1->(DbSeek(xFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA,.F.))
		
		
		_nTQtPv :=  0
		_nTQEmp :=  0
		_nTQPro :=  0
		_nTVlr  :=  0
		_nTLiq  :=  0
		_nTQCob :=  0
		_nTqPvc :=  0
		_dDtEntr:= Ctod("  /  /  ")
		_cNegoc := " "
		Do While  TRB->PEDIDO == _Pedi .And. TRB->(!EOF())
			IncRegua()	
			If nLin > 63 .Or. (nLin > 60 .And. _nImpPed == 0)  // Salto de Página. Neste caso o formulario tem 55 linhas...
				nLin := Cabec(Titulo+If(MV_PAR12==2,"Negoc.",""),Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin++                                       
				If _nImpPed > 1
					_nImpPed := 1 // Imprime o produto
				EndIf
			Endif
			If _nImpPed < 2
				If _nImpPed == 0 .And. nLin > 9
					nLin++
				EndIf
		
				/*Processo de Industrialização
				Juliana Leme - 16/09/2015
				*/
				aDados		:= {{"","","","","","","","","","","","","","","","","",""}}
				aDados		:= u_InfTrian(xFilial("SC6"),TRB->PEDIDO,"CDESTR14")
				If Len(aDados) = 0
					aDados		:= {{"","","","","","","","","","","","","","","","","",""}}
				EndIf							
		
				@ nLin,000 PSay TRB->PEDIDO
				@ nLin,009 PSay Iif(Empty(aDados[1,2]),SA1->A1_COD+"-"+SA1->A1_LOJA+" "+SA1->A1_NOME,;
				Alltrim(aDados[1,17]+"-"+aDados[1,18])+" "+Alltrim(aDados[1,2]))
				
				SC5->(DbSeek(xFilial("SC5")+TRB->PEDIDO,.F.))
				_dDtEntr := SC5->C5_ENTREG
				@ nLin,075 PSay "Dt.Entr.:"
				@ nLin,085 PSay SC5->C5_ENTREG
				//If SC5->C5_DIASNEG > 0 .And. !Empty(SC5->C5_DTENTR)
				If !Empty(SC5->C5_DTENTR)
					_cNegoc  := "Negoc."
					@ nLin,094 PSay "Negoc."
				EndIf
				If SC5->C5_CONDPAG == "000"
					@ nLin,101 PSay "BNDES"
				EndIf
				
				If TRB->STATPED== "Ft"
					@ nLin,110 PSay " Status: Em Faturamento "
				EndIf
		
				If _nImpPed == 1
					@ nLin,108 PSay "- Continuação "
				EndIf
				nLin++      
				_nImpPed := 2
			EndIf
		
			SC6->(DbSeek(xFilial("SC6")+TRB->PEDIDO+TRB->ITEMPV,.F.))
		
			SB1->(DbSeek(xFilial("SB1")+TRB->PROD,.F.))
		
			@ nLin,000 PSay TRB->ITEMPV
			@ nLin,003 PSay TRB->PROD
			@ nLin,019 PSay Left(u_CortaDesc(SB1->B1_DESC),37)
			@ nLin,057 PSay AllTrim(TRB->ACOND)
			@ nLin,065 PSay SC5->C5_EMISSAO
			@ nLin,075 PSay SC6->C6_ENTREG
			
			// Até que entre no ar o PreActor, será impresso o C5_DTEPA2
			// No SC5 e SC¨existem os campos C?_DTEPA E C?_DTEPA2. Esses campos recebem a data prevista 
			// para entrega do material no EPA e o C?_DTEPA somente será atualizado se estiver vazio e 
			// o C?_DTEPA2 será atualizado sempre.
			// No início, para não confundir, será impresso C5_DTEPA2 e depois que tivermos a informação 
			// correta por item o C6_DTEPA2.
			@ nLin,085 PSay SC5->C5_DTEPA2
		
			If !Empty(SC6->C6_SEMANA)
				If Left(SC6->C6_SEMANA,1) $ "0123456789"
					@ nLin,095 PSay Substr(SC6->C6_SEMANA,5,2)+"/"+Left(SC6->C6_SEMANA,4)
				ElseIf Left(SC6->C6_SEMANA,3) == "DRC"
					// Em 15/04/14 Jeferson achou que não convem mostrar o campo C6_SEMANA que está
					// com DRC9999. Pediu para colocar a expressão Prod.=N.
					@ nLin,095 PSay "Prod.=N"
				Else
					@ nLin,095 PSay SC6->C6_SEMANA
				EndIf
			EndIf			                                            
		
			_nPosSd := aScan(_aSds, {|x|x[1]==TRB->ACOND})
			If _nPosSd == 0
				Aadd(_aSds,{TRB->ACOND,TRB->SALDOE})
				_nPosSd := Len(_aSds)
			EndIf
		
			_nQtdProd := (SC6->C6_QTDVEN-SC6->C6_QTDENT-TRB->QTDLIB)
			_nAProduz := 0.00
			if ! Alltrim(SC6->C6_SEMANA) == 'TRIANG'
				if  _nQtdProd > _aSds[_nPosSd,2] .And. _aSds[_nPosSd,2]  > 0
					_nAProduz := _nQtdProd - _aSds[_nPosSd,2]
				elseif _aSds[_nPosSd,2]  <= 0
					_nAProduz := _nQtdProd
				endif
				_aSds[_nPosSd,2] := _aSds[_nPosSd,2]-_nQtdProd
				If Left(TRB->ACOND,1) == "T"
					_nAProduz := 0.00 // Não se produz retalho
				endif
			endif			
			_nCBR     := (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_PESCOB
			_nPVC     := (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_PESPVC
			_nFtCB    := ((SC6->C6_QTDVEN-SC6->C6_QTDENT) * SC6->C6_PRCVEN) / _nCBR
			
			_nTQtPv +=  (SC6->C6_QTDVEN-SC6->C6_QTDENT)
			_nTQEmp +=  TRB->QTDLIB
			_nTQPro +=  _nAProduz
			_nTVlr  +=  (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SC6->C6_PRCVEN
			_nTLiq  +=  TRB->QTDLIB * SC6->C6_PRCVEN
			_nTQCob +=  _nCBR
			_nTqPvc +=  _nPVC
			_nTgQCob +=  _nCBR
			_nTgqPvc +=  _nPVC
			_nTgCbPr += _nAProduz * SB1->B1_PESCOB
			_nTgVlr  += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SC6->C6_PRCVEN
			_nTgLiq  +=  TRB->QTDLIB * SC6->C6_PRCVEN
			
			/*/
			Produto          Descrição                               Acond.   Emissao  Previsao  Data PCP   Semana  Saldo PV  Qtd.Emp.  Qtd. Est.  
			xxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx R00100  99/99/99  99/99/99  99/99/99  99/9999  9999,999  9999,999  99999,999  
			0               16                                       57      65        75        85        95       104       114       124        
			
			A Produz.  Qtd.Entr     Vlr. Item   Vlr.Dispon.  Cobre-Kg  PVC-Kg.  Ft.Cobre  Ft.Ac."
			99999,999 99999,999   9999,999.99   9999,999.99  9999,999  999,999   9999.99  999.99
			135       145         157           171          184       194       204      213
			/*/
			@ nLin,104 PSay (SC6->C6_QTDVEN-SC6->C6_QTDENT) Picture "@E 9999,999"
			@ nLin,114 PSay TRB->QTDLIB Picture "@E 9999,999"
			@ nLin,124 PSay TRB->SALDOE Picture "@E 99999,999"
			@ nLin,135 PSay _nAProduz Picture "@E 99999,999"
			@ nLin,145 PSay SC6->C6_QTDENT Picture "@E 9999,999"
			@ nLin,157 PSay (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SC6->C6_PRCVEN Picture "@E 9999,999.99"
			@ nLin,171 PSay TRB->QTDLIB * SC6->C6_PRCVEN Picture "@E 9999,999.99"
			@ nLin,184 PSay _nCBR Picture "@E 9999,999"
			@ nLin,194 PSay _nPVC Picture "@E 999,999"
			@ nLin,204 PSay _nFtCB Picture "@E 9999.99"
			@ nLin,213 PSay(_nTVlr/_nTQCob) Picture "@E 999.99"
			nLin := nLin + 1 // Avanca a linha de impressao
			RecLock("TRB",.F.)
			TRB->APROD := _nAProduz
			TRB->ENTRG := _dDtEntr
			TRB->NEGOC := _cNegoc
			MsUnLock()
			TRB->(DbSkip())
		EndDo
		@ nLin,065 PSay "Total do Pedido " + _Pedi
		@ nLin,157 PSay _nTVlr  Picture "@E 9999,999.99"
		@ nLin,171 PSay _nTLiq  Picture "@E 9999,999.99"
		@ nLin,184 PSay _nTQCob Picture "@E 9999,999"
		@ nLin,194 PSay _nTqPvc Picture "@E 999,999"
		nLin := nLin + 1 // Avanca a linha de impressao
	EndDo
	If (_nTgQCob + _nTgqPvc) > 0
		@ nLin,065 PSay "Totais do Valor, Cobre e PVC"
		@ nLin,157 PSay _nTgVlr  Picture "@E 9999,999.99"
		@ nLin,157 PSay _nTgLiq  Picture "@E 9999,999.99"
		@ nLin,184 PSay _nTgQCob Picture "@E 9999,999"
		@ nLin,194 PSay _nTgqPvc Picture "@E 999,999"
		nLin := nLin + 1 // Avanca a linha de impressao
	EndIf                       
	If _nTgCbPr > 0
		@ nLin,065 PSay "Total Cobre a Produzir"
		@ nLin,188 PSay _nTgCbPr Picture "@E 9999,999"
		nLin := nLin + 1 // Avanca a linha de impressao
	EndIf                   
EndIf
		
SET DEVICE TO SCREEN
		
If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
		
MS_FLUSH()
		
DbSelectArea("TRB")
TRB->(DbGoTop())
aTrbArea := TRB->(GetArea())
aColuna := u_RetTRBCol(aTrbArea)
aDados 	:= u_RetTRBReg(aTrbArea)
aadd(aWSheet,{"FollowUpPedidos"}) 
aadd(aTable,{"FollowUpPedidos"})
u_TExcArr(aDados,aColuna,aWSheet,aTable)
DbCloseArea("TRB")
Return(.T.)

/////////////////////////
Static Function ValidPerg
/////////////////////////

_aArea := GetArea()

DbSelectArea("SX1")
DbSetOrder(1)
cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

aRegs:={}
//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Do Pedido Venda              ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","SC5"})
aAdd(aRegs,{cPerg,"02","Até Pedido Venda             ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","SC5"})
aAdd(aRegs,{cPerg,"03","Do Cliente                   ?","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","SA1"})
aAdd(aRegs,{cPerg,"04","Da Loja                      ?","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"05","Até Cliente                  ?","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SA1"})
aAdd(aRegs,{cPerg,"06","Até Loja                     ?","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"07","Do Produto                   ?","mv_ch7","C",15,0,0,"G","","mv_par07","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"08","Até Produto                  ?","mv_ch8","C",15,0,0,"G","","mv_par08","","","","","","","","","","","","","","","SB1"})
aAdd(aRegs,{cPerg,"09","Da Data Entrega              ?","mv_ch9","D",08,0,0,"G","","mv_par09","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"10","Até Data Entrega             ?","mv_cha","D",08,0,0,"G","","mv_par10","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"11","Ordem de Apresentação        ?","mv_chb","N",01,0,0,"C","","mv_par11","Produto","","","Pedido de Venda","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"12","Filtrar                      ?","mv_chc","N",01,0,0,"C","","mv_par12","Todos","","","Só Dt.Negoc.","","","","","","","","","","",""})
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

//edido Cliente   Nome do Cliente                          Acond.  Emissao Previsao
//XXXXX 999999-99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX R00100 99/99/99 99/99/99
//0     7         17                                       58     65       74
//
//Data PCP  Semana Saldo PV  Qtd.Emp.  Qtd. Est.  A Produz.
//99/99/99 99/9999 9999,999  9999,999  99999,999  99999,999
//83       92      100       110       120        131
//
//Qtd.Entr  Ult. Ent  % Entr  Atend.  Vlr. Item Cobre-Kg PVC-Kg. Ft.Cobre Ft.Ac.
//9999,999  99/99/99  999.99  99,999  99999,999 9999,999 999,999  9999.99 999.99
//142       152       162     170     178       188      197      206     214



/*/
Pedido Cliente   Nome do Cliente
XXXXX 999999-99 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

Produto          Descrição                               Acond.   Emissao  Previsao  Data PCP   Semana  Saldo PV  Qtd.Emp.  Qtd. Est.  A Produz.  Qtd.Entr     Vlr. Item   Vlr.Dispon.  Cobre-Kg  PVC-Kg.  Ft.Cobre  Ft.Ac."
xxxxxxxxxxxxxxx xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx R00100  99/99/99  99/99/99  99/99/99  99/9999  9999,999  9999,999  99999,999  99999,999 99999,999   9999,999.99   9999,999.99  9999,999  999,999   9999.99  999.99
0               16                                       57      65        75        85        95       104       114       124        135       145         157           171          184       194       204      213
//
//Data PCP  Semana Saldo PV  Qtd.Emp.  Qtd. Est.  A Produz.
//
//
//
//Qtd.Entr  Ult. Ent  % Entr  Atend.  Vlr. Item Cobre-Kg PVC-Kg. Ft.Cobre Ft.Ac.
//
//
/*/
