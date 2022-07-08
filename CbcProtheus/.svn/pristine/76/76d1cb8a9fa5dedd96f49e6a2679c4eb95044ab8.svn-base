#include "rwmake.ch"
#include "TOPCONN.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDFATR03                           Modulo : SIGAFAT      //
//                                                                          //
//   Autor ......: RODRIGO O. T. CAETANO              Data ..: 04/11/2004   //
//                                                                          //
//   Objetivo ...: Relatório de Carteira de Pedidos sem as LB% e com filtro //
//                 por bloqueio.                                            //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
*
************************
User Function CDFATRCLB() //Solicitado pela Daniela para gerar sem as LB% e com tipo de bloqueio       
	************************
	*


	_lEhVendas := !(cModulo == "FAT")          


	//_cGrupo := PSWRET()
	//_lEhVendas := .F.
	//_cGrupos := ""
	//For _nnn:=1 to Len(_cGrupo[1,10])
	//	If _cGrupo[1,10,_nnn] == "000001" // Grupo de vendas
	//		_lEhVendas := .T.
	//		Exit
	//	EndIf
	//Next

	If _lEhVendas
		// Imprime no formato novo
		u_CDFTRNewL()
	Else
		// Imprime no formato anterior conforme solicitação do Crispilho
		u_CDFTROldL()
	EndIf
	Return(.T.)


	// ***************************************************************************
	// Todas as funções abaixo até a próxima observação são usadas no formato novo
	// ***************************************************************************


	*
	*
	**************************
User Function CDFTRNewL()
	**************************
	*
	*
	Local cDesc1        := "Este programa tem como objetivo imprimir relatório "
	Local cDesc2        := "da Carteira de Pedidos de acordo com os parâmetros "
	Local cDesc3        := "informados pelo usuário."
	Local cPict         := ""
	Local imprime       := .T.
	Local aOrd          := {}
	Private titulo        := "Carteira de Pedidos"
	Private nLin          := 80

	Private Cabec1        := "" //"Pedido Nome do Cliente    Cidade         UF Emis. Lib.   #  Entr. Repres.         Valor  Ft.    LB  Resumo Observacao"
	//-----------------------------------------------------------------------------------------------------------------------------------
	//edido Nome do Cliente    Cidade         UF Emis. Lib.   #  Entr. Repres.         Valor  Ft.    LB  Resumo Observacao"
	//99999 XXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXX XX 99/99 99/99 XXX XX/XX XXXXXXXXXX 999,999.99 99,9 99,99 x 99999 XXXXXXXXXXXXXXXXXXXXXX/BF
	//0     7                  26             41 44    50    56  60    66         77         88   93    99101   107                   129                
	Private Cabec2        := ""
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 220 // 132
	Private tamanho     := "G" //"M"
	Private nomeprog    := "CDFATR03"
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg       := "CDFTSLB"
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "CDFATR03"

	Private cString     := "SC5"

	DbSelectArea("SX1")
	DbSetOrder(1)
	aRegs:={}            
	aAdd(aRegs,{cPerg,"11","NAO Incluir Pedidos          ?","mv_chb","C",99,0,0,"G","","mv_par11","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","Continuação                  ?","mv_chc","C",99,0,0,"G","","mv_par12","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"14","Tipo Bloqueio BV/BF/RJ/**    ?","mv_che","C",02,0,0,"G","","mv_par14","","","","","","","","","","","","","","",""})
	For _xx := 1 to  Len(aRegs)
		If DbSeek(cPerg+aRegs[_xx,2])
			RecLock("SX1",.F.)
			SX1->X1_GRUPO   := aRegs[_xx,01]
			SX1->X1_ORDEM   := aRegs[_xx,02]
			SX1->X1_PERGUNT := aRegs[_xx,03]
			SX1->X1_VARIAVL := aRegs[_xx,04]
			SX1->X1_TIPO    := aRegs[_xx,05]
			SX1->X1_TAMANHO := aRegs[_xx,06]
			SX1->X1_DECIMAL := aRegs[_xx,07]
			SX1->X1_PRESEL  := aRegs[_xx,08]
			SX1->X1_GSC     := aRegs[_xx,09]
			SX1->X1_VALID   := aRegs[_xx,10]
			SX1->X1_VAR01   := aRegs[_xx,11]
			SX1->X1_DEF01   := aRegs[_xx,12]
			SX1->X1_CNT01   := aRegs[_xx,13]
			SX1->X1_VAR02   := aRegs[_xx,14]
			SX1->X1_DEF02   := aRegs[_xx,15]
			SX1->X1_CNT02   := aRegs[_xx,16]
			SX1->X1_VAR03   := aRegs[_xx,17]
			SX1->X1_DEF03   := aRegs[_xx,18]
			SX1->X1_CNT03   := aRegs[_xx,19]
			SX1->X1_VAR04   := aRegs[_xx,20]
			SX1->X1_DEF04   := aRegs[_xx,21]
			SX1->X1_CNT04   := aRegs[_xx,22]
			SX1->X1_VAR05   := aRegs[_xx,23]
			SX1->X1_DEF05   := aRegs[_xx,24]
			SX1->X1_CNT05   := aRegs[_xx,25]
			SX1->X1_F3      := aRegs[_xx,26]
			MsUnlock()               
			DbCommit()
		EndIf
	Next	
	DbSelectArea("SC5")
	DbSetOrder(2)


	ValidPerg()
	Pergunte(cPerg,.F.)

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	EndIf

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	EndIf

	limite      := 220 
	tamanho     := "G" 
	aReturn[4]  := 2

	nTipo := If(aReturn[4]==1,15,18)

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

////////////////////////////////////////////////////
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	////////////////////////////////////////////////////

	Private _nValTot := 0

	Private __cNomArq := ""                               // Arquivo Temporario
	Private _aCampos := {}

	/*/                     
	aAdd(_aCampos, {"TRB->OBS"    , "C", 40, 0})    // Observacoes do Pedido
	/*/


	aAdd(_aCampos, {"SETOR"  , "C", 01, 0})       // NNumero do Pedido de Venda
	aAdd(_aCampos, {"PEDIDO" , "C", TamSX3("C6_NUM")[1], 0})       // Numero do Pedido de Venda
	aAdd(_aCampos, {"NOME"   , "C", 30, 0})       // Nome do Cliente
	aAdd(_aCampos, {"MUN"    , "C", 20, 0})       // Municipio do Cliente
	aAdd(_aCampos, {"EST"    , "C", 02, 0})       // Estado do Cliente
	aAdd(_aCampos, {"EMISSA" , "D", 08, 0})       // Data de Emissao do Pedido
	aAdd(_aCampos, {"DTLIPV" , "D", 08, 0})       // Data de Liberacao do Pedido
	aAdd(_aCampos, {"DTLICR" , "D", 08, 0})       // Data de Liberacao do Credito
	aAdd(_aCampos, {"DIF"    , "C", 03, 0})       // Diferenca entre Liberacao e DataBase
	aAdd(_aCampos, {"ENTREG" , "D", 08, 0})       // Data de Entrega Prevista
	aAdd(_aCampos, {"VEND"   , "C", 20, 0})       // Nome do Vendedor
	aAdd(_aCampos, {"VRVENDA", "N", 15, 2})    // Total do pedido pelo valor de venda
	aAdd(_aCampos, {"PESOCOB", "N", 15, 2})    // Total do pedido pelo valor de venda

	aAdd(_aCampos, {"VRCUSTO", "N", 15, 2})     // Total do pedido pelo valor de custo        
	aAdd(_aCampos, {"VLUCRO" , "N", 15, 2})     
	aAdd(_aCampos, {"LUCROB" , "N", 15, 2})     
	aAdd(_aCampos, {"RESUMO" , "C", 07, 0})       // Semana do resumo              
	aAdd(_aCampos, {"OBS"    , "C", 40, 0})       // Observacoes do Pedido
	aAdd(_aCampos, {"SALDO"  , "C", 01, 0})       // É SALDO?
	aAdd(_aCampos, {"BLCRED" , "C", 02, 0})
	aAdd(_aCampos, {"COBRE"  , "N", 15, 3})       // É SALDO?
	aAdd(_aCampos, {"PVC"    , "N", 15, 3})       // É SALDO?

	aAdd(_aCampos, {"VLRTRF" , "N", 15, 2})    // Valor de transferência
	aAdd(_aCampos, {"COBTRF" , "N", 15, 2})    // Cobre na transferência
	aAdd(_aCampos, {"PVCTRF" , "N", 15, 3})    // PVC na transferência

	aAdd(_aCampos, {"CST_MP" , "N", 15, 3})    // Custo de Cobre e PVC
	aAdd(_aCampos, {"METROS" , "N", 15, 0})    // Quantidade em metros

	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf

	_cNomArq := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,, _cNomArq, "TRB", .T., .F.)

	Private _cInd := CriaTrab(Nil, .F.)
	If MV_PAR09 == 1 // Vendedor
		IndRegua("TRB", _cInd, "SETOR+VEND+MUN+NOME+PEDIDO",,, "Selecionando Registros...")
	Else
		IndRegua("TRB", _cInd, "SETOR+Dtos(DTLIPV)+MUN+NOME+PEDIDO",,, "Selecionando Registros...")
	EndIf

	DbSetIndex(_cInd + OrdBagExt())

	DbSelectArea("SA1")
	DbSetOrder(1)  //A1_FILIAL+A1_COD+A1_LOJA

	DbSelectArea("SA3")
	DbSetOrder(1)  //A3_FILIAL+A3_COD

	DbSelectArea("SC9")
	DbSetOrder(1)  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO


	#IFDEF TOP
	DbSelectArea("SC5")
	DbSetOrder(1)  //C5_FILIAL+C5_NUM

	cQUER := " FROM "+RetSqlName("SC5")+" C5, "+RetSqlName("SC6")+" C6,"+RetSqlName("SF4")+" F4"
	cQUER += " WHERE C6.C6_NUM = C5.C5_NUM"
	cQUER += " AND C6.C6_TES  = F4.F4_CODIGO"
	cQUER += " AND F4.F4_FILIAL = '" + xFilial("SF4") + "'"
	cQUER += " AND (F4.F4_ESTOQUE = 'S' OR F4.F4_DUPLIC = 'S')"
	cQUER += " AND C6.C6_FILIAL = '" + xFilial("SC6") + "'"
	cQUER += " AND C6.C6_QTDVEN > C6.C6_QTDENT"
	cQUER += " AND C6.C6_BLQ <> 'R '"
	cQUER += " AND C5.C5_FILIAL = '" + xFilial("SC5") + "'"
	cQUER += " AND C5.C5_EMISSAO >= '" + DToS(Mv_Par03) + "'"
	cQUER += " AND C5.C5_EMISSAO <= '" + DToS(Mv_Par04) + "'"
	cQUER += " AND C5.C5_NUM     >= '" + Mv_Par01 + "'"
	cQUER += " AND C5.C5_NUM     <= '" + Mv_Par02 + "'"
	cQUER += " AND C5.C5_CLIENTE+C5.C5_LOJACLI >= '" + Mv_Par05 + Mv_Par06 + "'"
	cQUER += " AND C5.C5_CLIENTE+C5.C5_LOJACLI <= '" + Mv_Par07 + Mv_Par08 + "'"
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

	SetRegua(_Total)
	_AliasC5 := "RSC5"
	Do While RSC5->(!Eof())                           

	_cNumPd := RSC5->C5_NUM
	Do While RSC5->(!Eof()) .And. RSC5->C5_NUM ==  _cNumPd
	IncRegua()
	RSC5->(DbSkip())
	EndDo
	SC5->(DbSeek(xFilial("SC5")+_cNumPd,.F.))

	#ELSE

	_AliasC5 := "SC5"
	DbSelectArea("SC5")
	DbSetOrder(2)  //C5_FILIAL+DTOS(C5_EMISSAO)+C5_NUM
	SetRegua(RecCount())
	DbSeek(xFilial("SC5")+DToS(Mv_Par03),.T.)

	Do While SC5->C5_EMISSAO <= Mv_Par04 .And. SC5->C5_FILIAL == xFilial("SC5") .And. SC5->(!Eof())
	IncRegua()


	#ENDIF

	If lAbortPrint
	@ nLin,000 PSay "*** CANCELADO PELO OPERADOR ***"
	Exit
	EndIf
	// se tiver eliminado residuo??
	If SC5->C5_NUM     < Mv_Par01 .Or. SC5->C5_NUM     > Mv_Par02 .Or. ;
	SC5->C5_CLIENTE+SC5->C5_LOJACLI < Mv_Par05+Mv_Par06 .Or. ;
	SC5->C5_CLIENTE+SC5->C5_LOJACLI > Mv_Par07+Mv_Par08 .Or. ;
	SC5->C5_LIBEROK == "E" .Or. SC5->C5_NUM $ MV_PAR11+"/"+MV_PAR12
	DbSelectArea(_AliasC5)
	DbSkip()
	Loop
	EndIf

	SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))


	If MV_PAR13 == 1 .And. SA1->A1_CONTRUT # "S"
	DbSelectArea(_AliasC5)
	DbSkip()
	Loop
	EndIf


	SA3->(DbSeek(xFilial("SA3")+SC5->C5_VEND1,.F.))
	SC9->(DbSeek(xFilial("SC9")+SC5->C5_NUM,.F.))
	_lTemFat := .F.
	_lBlCred := .F.
	_lRejeit := .F.
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == SC5->C5_NUM .And. SC9->(!Eof())  
	If SC9->C9_BLEST == "10" .Or. SC9->C9_BLCRED == "10"
	_lTemFat := .T.
	//		ElseIf !_lRejeit .And. SC9->C9_BLCRED == "09"
	ElseIf SC9->C9_BLCRED == "09"
	_lRejeit := .T.
	ElseIf !SC9->C9_BLCRED $ "  /10"
	_lBlCred := .T.
	EndIf
	If _lTemFat .And. _lBlCred
	Exit
	EndIf
	SC9->(DbSkip())
	EndDo           
	If _lRejeit .And. cModulo # "FAT" 
	// 24/01/12 - Denise solicitou que os rejeitados não apareçam na carteira
	// emitida pelo Crispilho /PCP
	DbSelectArea(_AliasC5)
	DbSkip()
	Loop
	EndIf
	// Reposiciona o SC9
	SC9->(DbSeek(xFilial("SC9")+SC5->C5_NUM,.F.))
	If Empty(SC5->C5_DATALIB)
	If RecLock("SC5",.F.)  
	SC5->C5_DATALIB := SC9->C9_DATALIB
	MsUnLock()
	EndIf
	EndIf

	_nValTot := u_SomaPed(SC5->C5_NUM,.F.,"S","S",MV_PAR10) //(Nro.PV,Tudo ou só saldo,TES Estoque, TES Financeiro),Tabela 1 ou 2
	// SomaPed retorna o Valor de Venda e o Valor de Custo
	If _nValTot[1]+_nValTot[5] > 0.00 
	RecLock("TRB",.T.)
	TRB->SETOR  := If(SA1->A1_SETOR=="I","2","1")
	TRB->PEDIDO := SC5->C5_NUM
	TRB->NOME   := SA1->A1_NOME
	TRB->MUN    := SA1->A1_MUN
	TRB->EST    := SA1->A1_EST
	TRB->EMISSA := SC5->C5_EMISSAO
	TRB->DTLICR := SC5->C5_DTLICRE
	TRB->DTLIPV := SC5->C5_DATALIB
	TRB->DIF    := Str(If(!Empty(SC5->C5_DATALIB),dDataBase-SC5->C5_DATALIB,0),3)
	TRB->ENTREG := SC5->C5_ENTREG
	If Type("SA3->A3_CONTAT") == "C"
	TRB->VEND   := SA3->A3_CONTAT
	Else
	TRB->VEND   := SA3->A3_NREDUZ
	EndIf
	TRB->VRVENDA:= _nValTot[1]
	TRB->VRCUSTO:= _nValTot[2] 
	TRB->PESOCOB:= _nValTot[3]
	TRB->VLUCRO := (TRB->VRVENDA-TRB->VRCUSTO)
	TRB->LUCROB := (TRB->VLUCRO / TRB->VRCUSTO) * 100
	TRB->RESUMO := SC5->C5_SEMANA
	TRB->OBS    := SC5->C5_OBS
	TRB->SALDO  := If(_lTemFat,"S"," ")
	TRB->BLCRED := If(_lRejeit,"RJ",If(_nValTot[8],"BV",If(_lBlCred,"BF","  ")))
	TRB->COBRE  := _nValTot[3] 
	TRB->PVC    := _nValTot[4] 

	TRB->VLRTRF := _nValTot[5]
	TRB->COBTRF := _nValTot[6]
	TRB->PVCTRF := _nValTot[7]

	TRB->CST_MP := _nValTot[9]    // Custo de Cobre e PVC
	TRB->METROS := _nValTot[10]   // Quantidade em metros

	MsUnLock()
	EndIf
	DbSelectArea(_AliasC5) 
	#IFNDEF TOP
	DbSkip()	// so dou o dbskip se nao for top
	#ENDIF
	EndDo

	#IFDEF TOP
	DbSelectArea("RSC5")
	DbCloseArea("RSC5")
	#ENDIF

	DbSelectArea("TRB")
	SetRegua(RecCount())
	DbGoTop()


	/*/
	_cGrupo := PSWRET()
	_lEhVendas := .F.
	_cGrupos := ""
	For _nnn:=1 to Len(_cGrupo[1,10])
	If _cGrupo[1,10,_nnn] == "000001" // Grupo de vendas
	_lEhVendas := .T.
	Exit
	EndIf
	Next
	/*/

	If _lEhVendas
	Cabec1 := "Pedido Nome do Cliente                Cidade               UF Dt.Emis. Dt.Lb.Cr. #Dias Dt.Entr. Nome Representante   Valor Pedido Fator   LB %   Ind.MP Sld? Resumo Observacao                                Sit."
	Else
	Cabec1 := "Pedido Nome do Cliente                Cidade               UF Dt.Emis. Dt.Lb.Cr. #Dias Dt.Entr. Nome Representante   Valor Pedido Dt.Ven.               Sld? Resumo Observacao                                Sit."
	EndIf

	_nTotG   := 0.00 // Total Geral Valor
	_nLucG   := 0.00 // Total geral Custo
	_nCstMPg := 0.00 // Total geral Custo de MP

	_nTtStVl := 0.00 // Total Setor Valor
	_nTtStCs := 0.00 // Total Setor Custo
	_nTtStMP := 0.00 // Total Setor Custo de MP

	_nTtVdVl := 0.00 // Total Vendedor Valor
	_nTtVdCs := 0.00 // Total Vendedor Custo
	_nTtVdPs := 0.00 // Total Vendedos Peso Cobre
	_nTtVdMP := 0.00 // Total Vendedor Custo MP

	_nSomaCb := 0.00 // Soma do Cobre
	_nSomaPV := 0.00 // Soma do PVC
	_nSomaMT := 0.00 // Soma do Cobre

	_nSomTCb := 0.00 // Soma do Cobre Transferência
	_nSomTPV := 0.00 // Soma do PVC Transferência

	_nTotaCb := 0.00 // Total do Cobre
	_nTotaPV := 0.00 // Total do PVC
	_nTotaMT := 0.00 // Total em Metros

	_nTotTCb := 0.00 // Total do Cobre Transferência
	_nTotTPV := 0.00 // Total do PVC Transferência


	_cAnt  := If(MV_PAR09==1,Space(Len(TRB->VEND)),Ctod(""))

	_Setor := " "

	Do While TRB->(!Eof())   

	If lAbortPrint
	@ nLin,000 PSay "*** CANCELADO PELO OPERADOR ***"
	Exit
	EndIf

	If (TRB->SETOR # _Setor .Or. TRB->(Eof()) .Or. _cAnt # If(MV_PAR09==1,TRB->VEND,TRB->DTLIPV)) .And. !Empty(_Setor)
	//		If _nTtVdVl # 0
	nLin := ImpTot(nLin,1,Cabec1) // Total do Vendedor
	nLin++
	@ nLin,000 PSay Replicate("-",limite)
	nLin++
	//		EndIf
	_nTtVdVl := 0.00 // Total Vendedor Valor
	_nTtVdCs := 0.00 // Total Vendedor Custo
	_nTtVdMP := 0.00 // Total Vendedor Custo MP
	_nTtVdPs := 0.00 // Total Vendedos Peso Cobre
	_cAnt  := If(MV_PAR09==1,TRB->VEND,TRB->DTLIPV)
	EndIf

	If TRB->SETOR # _Setor
	If _nTtStVl # 0 
	nLin := ImpTot(nLin,2,Cabec1) // Total do Setor
	nLin++
	@ nLin,000 PSay Replicate("-",limite)
	nLin++
	_nTtStVl := 0.00 // Total Setor Valor
	_nTtStCs := 0.00 // Total Setor Custo
	_nTtStMP := 0.00 // Total Setor Custo de MP
	_nSomaCb := 0.00 // Soma do Cobre
	_nSomaMT := 0.00 // Soma do Cobre
	_nSomaPV := 0.00 // Soma do PVC
	_nSomTCb := 0.00 // Soma do Cobre Transferência
	_nSomTPV := 0.00 // Soma do PVC Transferência
	EndIf
	_lStVazio := Empty(_Setor)
	_Setor := TRB->SETOR 
	If TRB->SETOR == "1" // Revenda
	Titulo := "Carteira de Pedidos - De "+DToC(Mv_Par03)+" Ate "+DToC(Mv_Par04) + " Revenda"
	ElseIf TRB->SETOR == "2" // Industria
	Titulo := "Carteira de Pedidos - De "+DToC(Mv_Par03)+" Ate "+DToC(Mv_Par04) + " Industria"
	EndIf
	If !_lStVazio
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 8
	EndIf
	EndIf	
	IncRegua()

	If nLin > 60
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 8
	EndIf

	_nFator := TRB->VRVENDA / TRB->PESOCOB

	@ nLin,000 PSay TRB->PEDIDO
	@ nLin,007 PSay TRB->NOME
	@ nLin,038 PSay TRB->MUN
	@ nLin,059 PSay TRB->EST
	@ nLin,062 PSay TRB->EMISSA
	//	If _lEhVendas Crispilho solicitou a inclusão da dt de lib de cred.no relatório em 23/11/11 e Sra. Denise autorizou
	@ nLin,071 PSay TRB->DTLICR
	//	EndIf
	@ nLin,083 PSay TRB->DIF
	@ nLin,087 PSay TRB->ENTREG
	@ nLin,096 PSay TRB->VEND
	@ nLin,117 PSay (TRB->VRVENDA+TRB->VLRTRF) Picture "@E 99999,999.99"
	If _nFator # 0 .And. _lEhVendas
	@ nLin,130 PSay _nFator   	    Picture "@E 999.99"
	@ nLin,137 PSay TRB->LUCROB		Picture "@E 999.99" // Picture "@E 999.99"
	@ nLin,145 PSay Round(((TRB->CST_MP / (TRB->VRVENDA+TRB->VLRTRF)) * 100),2) Picture "@E 999.99"
	ElseIf !_lEhVendas
	@ nLin,130 PSay TRB->DTLIPV
	EndIf
	@ nLin,153 PSay TRB->SALDO
	@ nLin,156 PSay TRB->RESUMO
	@ nLin,164 PSay TRB->OBS

	//	If _lEhVendas
	@ nLin,206 PSay If(!Empty(TRB->BLCRED),"/"+TRB->BLCRED,"")
	//	ElseIf !("BF" $ TRB->BLCRED)
	//		@ nLin,129 PSay If(!Empty(TRB->BLCRED),"/"+TRB->BLCRED,"")
	//	EndIf

	nLin++

	If TRB->VRVENDA > 0

	_nTotG   += TRB->VRVENDA  // Total Geral Valor
	_nLucG   += TRB->VRCUSTO  // Total Geral Custo          
	_nCstMPg += TRB->CST_MP   // Total geral Custo de MP

	_nTtStVl += TRB->VRVENDA  // Total Setor Valor
	_nTtStCs += TRB->VRCUSTO  // Total Setor Custo
	_nTtStMP += TRB->CST_MP   // Total Setor Custo de MP

	_nTtVdVl += TRB->VRVENDA  // Total Vendedor Valor
	_nTtVdCs += TRB->VRCUSTO  // Total Vendedor Custo
	_nTtVdMP += TRB->CST_MP   // Total Vendedor Custo MP

	EndIf

	_nTtVdPs += TRB->COBRE   // Total Vendedos Peso Cobre

	_nSomaCb += TRB->COBRE   // Soma do Cobre
	_nSomaPV += TRB->PVC     // Soma do PVC
	_nSomaMT += TRB->METROS  // Soma do Cobre

	_nSomTCb += TRB->COBTRF // Soma do Cobre Transferência
	_nSomTPV += TRB->PVCTRF // Soma do PVC Transferência

	_nTotaCb += TRB->COBRE   // Total do Cobre
	_nTotaPV += TRB->PVC     // Total do PVC
	_nTotaMT += TRB->METROS  // Total em Metros

	_nTotTCb += TRB->COBTRF  // Total do Cobre Transferência
	_nTotTPV += TRB->PVCTRF  // Total do PVC Transferência

	DbSelectArea("TRB")
	DbSkip()
	EndDo   
	If _nTtVdVl # 0 
	nLin := ImpTot(nLin,1,Cabec1) // Total do Setor
	nLin++
	@ nLin,000 PSay Replicate("-",limite)
	nLin++
	EndIf
	If _nTtStVl # 0 
	nLin := ImpTot(nLin,2,Cabec1) // Total do Setor
	nLin++
	@ nLin,000 PSay Replicate("-",limite)
	nLin++
	EndIf
	If _nTotG # 0 
	nLin := ImpTot(nLin,3,Cabec1) // Total da Carteira
	nLin++
	@ nLin,000 PSay Replicate("-",limite)
	nLin++
	EndIf

	Roda(0,"",Tamanho)

	DbSelectArea("TRB")
	DbCloseArea("TRB")
	Delete File (_cNomarq + ".DTC")
	Delete File (_cInd + OrdBagExt())
	@ 0,0 Psay Chr(27) + "@"
	SET DEVICE TO SCREEN
	If aReturn[5]==1
	DbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
	EndIf

	MS_FLUSH()

Return

/////////////////////////
Static Function ValidPerg
	/////////////////////////

	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Do Pedido                    ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até o Pedido                 ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Da Data de Emissão           ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Até a Data de Emissão        ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Do Cliente                   ?","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"06","Da Loja                      ?","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Até o Cliente                ?","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"08","Até a Loja                   ?","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Ordem                        ?","mv_ch9","N",01,0,0,"C","","mv_par09","Vendedor","","","Dt.Liberacão","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","Base de Custo                ?","mv_cha","N",01,0,0,"C","","mv_par10","Tabela 1","","","Tabela 2","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"11","NAO Incluir Pedidos          ?","mv_chb","C",99,0,0,"G","","mv_par11","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","Continuação                  ?","mv_chc","C",99,0,0,"G","","mv_par12","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"13","Somente Construt.?           ?","mv_chd","N",01,0,0,"C","","mv_par13","Sim","","","Não","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"14","Tipo Bloqueio BV/BF/RJ/**    ?","mv_che","C",02,0,0,"G","","mv_par14","","","","","","","","","","","","","","",""})

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

/////////////////////////////////
User Function SomaPdCLB(_cPedido,lTudo,cEstq,cFinan,nTab)
	/////////////////////////////////

	Private _aLucro := {0,0,0,0,0,0,0,.F.,0,0} 
	// 1-Total Vlr.Venda, 2-Total Vlr.Custo, 3-Peso Cobre,               4-PesoPVC   , 5-Vlr.Transferencia, 
	// 6-Cobre Transf.  , 7-PVC TRansf     , 8-Tem itens não liberados?, 9-Custo M.P.,10-Metragem Total
	//lTudo := If(Type("lTudo") == "U",.T.,lTudo)

	SB1->(DbSetOrder(1))

	SF4->(DbSetOrder(1))

	SA1->(DbSetOrder(1))

	DbSelectArea("SC6")
	DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	DbSeek(xFilial("SC6")+_cPedido,.F.)
	SA1->(DbSeek(xFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA,.F.))
	Do While SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+_cPedido .And. SC6->(!Eof())
		If SC6->C6_BLQ # "R " // "R" - Residuo não eliminado
			// Este item não está totalmente liberado?
			If !_aLucro[8] .And. (SC6->C6_QTDEMP+SC6->C6_QTDENT) < SC6->C6_QTDVEN
				_aLucro[8] := .T.
			EndIf

			SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.))
			SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES,.F.))
			If lTudo // De toda a quantidade vendida
				_aLucro[10] += SC6->C6_QTDVEN
				If SF4->F4_DUPLIC == "S"
					_aLucro[1] += SC6->C6_QTDVEN * SC6->C6_PRCVEN
					If FWCodEmp()+FWCodFil() == "0102" // 3 lagoas
						_aLucro[2] += SC6->C6_QTDVEN * SB1->B1_CUSTD3L
					Else
						_aLucro[2] += SC6->C6_QTDVEN * SB1->B1_CUSTD
					EndIf
					If SF4->F4_ESTOQUE == "S"
						_aLucro[3] += SC6->C6_QTDVEN * SB1->B1_PESCOB
						_aLucro[4] += SC6->C6_QTDVEN * SB1->B1_PESPVC
						_aLucro[9] += SC6->C6_QTDVEN * (SB1->B1_VALCOB+SB1->B1_VALPVC) // calcula o valor do Cobre e do PVC do item
					EndIf
				Else
					_aLucro[5] += SC6->C6_QTDVEN * SC6->C6_PRCVEN
					If SF4->F4_ESTOQUE == "S"
						//Verificar tambm se o material esta sendo enviado para Itu ou 3L
						If "02544042" $ SA1->A1_CGC
							_aLucro[6] += SC6->C6_QTDVEN * SB1->B1_PESCOB
							_aLucro[7] += SC6->C6_QTDVEN * SB1->B1_PESPVC
						Else
							_aLucro[3] += SC6->C6_QTDVEN * SB1->B1_PESCOB
							_aLucro[4] += SC6->C6_QTDVEN * SB1->B1_PESPVC 
						EndIf
						_aLucro[9] += SC6->C6_QTDVEN * (SB1->B1_VALCOB+SB1->B1_VALPVC) // calcula o valor do Cobre e do PVC do item
					EndIf
				EndIf
			ElseIf SC6->C6_QTDVEN > SC6->C6_QTDENT .And. (SF4->F4_ESTOQUE $ cEstq .Or. SF4->F4_DUPLIC $ cFinan)
				//		ElseIf SC6->C6_QTDVEN > SC6->C6_QTDENT .And. SF4->F4_ESTOQUE $ cEstq .And. SF4->F4_DUPLIC $ cFinan
				// Somente do saldo a faturar        

				_aLucro[10] += (SC6->C6_QTDVEN-SC6->C6_QTDENT)
				If SF4->F4_DUPLIC == "S" // E faturamento
					If FWCodEmp()+FWCodFil() == "0102" // 3 lagoas
						_aLucro[2] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_CUSTD3L
					Else
						_aLucro[2] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_CUSTD
					EndIf

					_aLucro[1] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SC6->C6_PRCVEN

					If SF4->F4_ESTOQUE == "S" // Se e faturamento, assumo o cobre e pvc para ele
						_aLucro[3] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_PESCOB
						_aLucro[4] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_PESPVC  
						_aLucro[9] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * (SB1->B1_VALCOB+SB1->B1_VALPVC) // calcula o valor do Cobre e do PVC do item
					EndIf				
				Else     // Nao e faturamento
					_aLucro[5] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SC6->C6_PRCVEN
					If SF4->F4_ESTOQUE == "S"// Se nao e faturamento, assumo o cobre e pvc como transferencia
						//Verificar tambem se o material esta sendo enviado para Itu ou 3L
						If "02544042" $ SA1->A1_CGC
							_aLucro[6] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_PESCOB
							_aLucro[7] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_PESPVC
						Else
							_aLucro[3] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_PESCOB
							_aLucro[4] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_PESPVC 
						EndIf
						_aLucro[9] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * (SB1->B1_VALCOB+SB1->B1_VALPVC) // calcula o valor do Cobre e do PVC do item
					EndIf
				EndIf           
			EndIf
		EndIf
		SC6->(DbSkip())
	EndDo

	Return(_aLucro)
	*
	******************************
Static Function ImpTot(nLin,_nQual,Cabec1)
	******************************
	*
	*
	If nLin > 58
		nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	EndIf
	If _nQual ==  1 // Vendedor/Representante
		_nFator := _nTtVdVl / _nTtVdPs
		@ nLin,050 PSay If(MV_PAR09==1,"Total do Representante: ","Total da Data: ")
		@ nLin,074 PSay _nTtVdVl		    				Picture "@E 99,999,999.99"
		If _lEhVendas
			@ nLin,088 PSay _nFator   	Picture "@E 99.9"
			@ nLin,094 PSay ((_nTtVdVl-_nTtVdCs)/_nTtVdCs)*100 	Picture "@E 999.99"
			@ nLin,102 PSay (_nTtVdMP/_nTtVdVl)*100          	Picture "@E 999.99"
		EndIf
	ElseIf _nQual == 2 // Setor
		@ nLin,050 PSay "Total " + If(_Setor == "1","Revenda:","Industria:")
		@ nLin,074 PSay _nTtStVl		    				Picture "@E 99,999,999.99"

		If _lEhVendas
			@ nLin  ,093 PSay ((_nTtStVl-_nTtStCs)/_nTtStCs)*100 	Picture "@E 999.99"
			@ nLin++,105 PSay (_nTtStMP/_nTtStVl)*100               Picture "@E 999.99"

			@ nLin,001 PSay "Materia Prima --> Cobre     ="
			@ nLin,031 PSay _nSomaCb Picture "@E 99,999,999"
			@ nLin,042 PSay "Kg (F="
			@ nLin,048 PSay _nTtStVl/_nSomaCb    Picture "@E 999.9"
			@ nLin,053 PSay ")    PVC     ="
			@ nLin,069 PSay _nSomaPV Picture "@E 99,999,999"
			@ nLin,080 PSay "Kg (F="
			@ nLin,086 PSay _nTtStVl/_nSomaPV    Picture "@E 999.9"
			@ nLin,091 PSay ")        Total ="
			@ nLin,109 PSay _nSomaCb+_nSomaPV Picture "@E 99,999,999"
			@ nLin,120 PSay "Kg (F="
			@ nLin,126 PSay _nTtStVl/(_nSomaCb+_nSomaPV)    Picture "@E 999.9"
			@ nLin,131 PSay ")"
		Else
			@ ++nLin,001 PSay "Materia Prima --> Cobre     ="
			@ nLin,031 PSay _nSomaCb Picture "@E 99,999,999"
			@ nLin,042 PSay "Kg"
			@ nLin,053 PSay "     PVC     ="
			@ nLin,069 PSay _nSomaPV Picture "@E 99,999,999"
			@ nLin,080 PSay "Kg"
			@ nLin,091 PSay "         Total ="
			@ nLin,109 PSay _nSomaCb+_nSomaPV Picture "@E 99,999,999"
			@ nLin,120 PSay "Kg"
		EndIf                       

		@ nLin,140 PSay "Kg/Km = "
		@ nLin,148 PSay (_nSomaCb/_nSomaMT) * 1000 Picture "@E 9,999.99" // (Total do Cobre / Total em Metros) * 1000

		nLin++

		@ nLin,001 PSay "                  Cobre(TRF)="
		@ nLin,031 PSay _nSomTCb Picture "@E 99,999,999"
		@ nLin,042 PSay "Kg"
		@ nLin,053 PSay "     PVC(TRF)="
		@ nLin,069 PSay _nSomTPV Picture "@E 99,999,999"
		@ nLin,080 PSay "Kg"	

	ElseIf _nQual == 3 // Total carteira
		@ nLin,050 PSay "Total Geral:"
		@ nLin,074 PSay _nTotG   		    				Picture "@E 99,999,999.99"

		If _lEhVendas
			@ nLin  ,093 PSay ((_nTotG-_nLucG)/_nLucG)*100 	Picture "@E 999.99"
			@ nLin++,105 PSay (_nCstMPg / _nTotG) * 100 	Picture "@E 999.99"

			@ nLin,001 PSay "Materia Prima --> Cobre     ="
			@ nLin,031 PSay _nTotaCb Picture "@E 99,999,999"
			@ nLin,042 PSay "Kg (F="
			@ nLin,048 PSay _nTotG/_nTotaCb    Picture "@E 999.9"
			@ nLin,053 PSay ")    PVC     ="
			@ nLin,069 PSay _nTotaPV Picture "@E 99,999,999"
			@ nLin,080 PSay "Kg (F="
			@ nLin,086 PSay _nTotG/_nTotaPV    Picture "@E 999.9"
			@ nLin,091 PSay ")        Total ="
			@ nLin,109 PSay _nTotaCb+_nTotaPV Picture "@E 99,999,999"
			@ nLin,120 PSay "Kg (F="
			@ nLin,126 PSay _nTotG/(_nTotaCb+_nTotaPV)    Picture "@E 999.9"
			@ nLin,131 PSay ")"
		Else
			@ ++nLin,001 PSay "Materia Prima --> Cobre     ="
			@ nLin,031 PSay _nTotaCb Picture "@E 99,999,999"
			@ nLin,042 PSay "Kg"
			@ nLin,053 PSay "     PVC     ="
			@ nLin,069 PSay _nTotaPV Picture "@E 99,999,999"
			@ nLin,080 PSay "Kg"
			@ nLin,091 PSay "         Total ="
			@ nLin,109 PSay _nTotaCb+_nTotaPV Picture "@E 99,999,999"
			@ nLin,120 PSay "Kg"
		EndIf

		@ nLin,140 PSay "Kg/Km = "
		@ nLin,148 PSay (_nTotaCb/_nTotaMT) * 1000 Picture "@E 9,999.99" // (Total do Cobre / Total em Metros) * 1000

		nLin++

		@ nLin,001 PSay "                  Cobre(TRF)="
		@ nLin,031 PSay _nTotTCb Picture "@E 99,999,999"
		@ nLin,042 PSay "Kg"
		@ nLin,053 PSay "     PVC(TRF)="
		@ nLin,069 PSay _nTotTPV Picture "@E 99,999,999"
		@ nLin,080 PSay "Kg"
	EndIf
	Return(nLin)          

	// Materia Prima --->    Cobre = 99,999,999 Kg (F=999.9)        PVC =  99,999,999 Kg (F=999.9)        Total =  99,999,999 Kg (F=999.9)
	// 
	// _nSomaCb := 0.00 // Soma do Cobre
	// _nSomaPV := 0.00 // Soma do PVC
	//
	// _nTotaCb := 0.00 // Total do Cobre
	// _nTotaPV := 0.00 // Total do PVC



	// ***************************************************************************
	// Todas as funções abaixo até a próxima observação são usadas no formato novo
	// ***************************************************************************
	*
	*
	*
	**************************
User Function CDFTROldL()
	**************************
	*
	*
	Local cDesc1        := "Este programa tem como objetivo imprimir relatório "
	Local cDesc2        := "da Carteira de Pedidos de acordo com os parâmetros "
	Local cDesc3        := "informados pelo usuário."
	Local cPict         := ""
	Local imprime       := .T.
	Local aOrd          := {}
	Private titulo        := "Carteira de Pedidos"
	Private nLin          := 80

	Private Cabec1        := "" //"Pedido Nome do Cliente    Cidade         UF Emis. Lib.   #  Entr. Repres.         Valor  Ft.    LB  Resumo Observacao"
	//-----------------------------------------------------------------------------------------------------------------------------------
	//edido Nome do Cliente    Cidade         UF Emis. Lib.   #  Entr. Repres.         Valor  Ft.    LB  Resumo Observacao"
	//99999 XXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXX XX 99/99 99/99 XXX XX/XX XXXXXXXXXX 999,999.99 99,9 99,99 x 99999 XXXXXXXXXXXXXXXXXXXXXX/BF
	//0     7                  26             41 44    50    56  60    66         77         88   93    99101   107                   129                
	Private Cabec2        := ""
	Private lEnd        := .F.
	Private lAbortPrint := .F.
	Private CbTxt       := ""
	Private limite      := 132
	Private tamanho     := "M"
	Private nomeprog    := "CDFATR03"
	Private nTipo       := 18
	Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey    := 0
	Private cPerg       := "CDFTSLB"
	Private cbtxt       := Space(10)
	Private cbcont      := 00
	Private CONTFL      := 01
	Private m_pag       := 01
	Private wnrel       := "CDFATR03"

	Private cString     := "SC5"

	DbSelectArea("SX1")
	DbSetOrder(1)
	aRegs:={}            
	aAdd(aRegs,{cPerg,"11","NAO Incluir Pedidos          ?","mv_chb","C",99,0,0,"G","","mv_par11","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","Continuação                  ?","mv_chc","C",99,0,0,"G","","mv_par12","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"14","Tipo Bloqueio BV/BF/RJ/**    ?","mv_che","C",02,0,0,"G","","mv_par14","","","","","","","","","","","","","","",""})
	For _xx := 1 to  Len(aRegs)
		If DbSeek(cPerg+aRegs[_xx,2])
			RecLock("SX1",.F.)
			SX1->X1_GRUPO   := aRegs[_xx,01]
			SX1->X1_ORDEM   := aRegs[_xx,02]
			SX1->X1_PERGUNT := aRegs[_xx,03]
			SX1->X1_VARIAVL := aRegs[_xx,04]
			SX1->X1_TIPO    := aRegs[_xx,05]
			SX1->X1_TAMANHO := aRegs[_xx,06]
			SX1->X1_DECIMAL := aRegs[_xx,07]
			SX1->X1_PRESEL  := aRegs[_xx,08]
			SX1->X1_GSC     := aRegs[_xx,09]
			SX1->X1_VALID   := aRegs[_xx,10]
			SX1->X1_VAR01   := aRegs[_xx,11]
			SX1->X1_DEF01   := aRegs[_xx,12]
			SX1->X1_CNT01   := aRegs[_xx,13]
			SX1->X1_VAR02   := aRegs[_xx,14]
			SX1->X1_DEF02   := aRegs[_xx,15]
			SX1->X1_CNT02   := aRegs[_xx,16]
			SX1->X1_VAR03   := aRegs[_xx,17]
			SX1->X1_DEF03   := aRegs[_xx,18]
			SX1->X1_CNT03   := aRegs[_xx,19]
			SX1->X1_VAR04   := aRegs[_xx,20]
			SX1->X1_DEF04   := aRegs[_xx,21]
			SX1->X1_CNT04   := aRegs[_xx,22]
			SX1->X1_VAR05   := aRegs[_xx,23]
			SX1->X1_DEF05   := aRegs[_xx,24]
			SX1->X1_CNT05   := aRegs[_xx,25]
			SX1->X1_F3      := aRegs[_xx,26]
			MsUnlock()               
			DbCommit()
		EndIf
	Next	
	DbSelectArea("SC5")
	DbSetOrder(2)

	VldPerOld()
	Pergunte(cPerg,.F.)

	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

	If nLastKey == 27
		Return
	EndIf

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	EndIf

	nTipo := If(aReturn[4]==1,15,18)

	RptStatus({|| RunRepOld(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

////////////////////////////////////////////////////
Static Function RunRepOld(Cabec1,Cabec2,Titulo,nLin)
	////////////////////////////////////////////////////

	Private _nValTot := 0

	Private __cNomArq := ""                               // Arquivo Temporario
	Private _aCampos := {}

	aAdd(_aCampos, {"SETOR"  , "C", 01, 0})       // NNumero do Pedido de Venda
	aAdd(_aCampos, {"PEDIDO" , "C", TamSX3("C6_NUM")[1], 0})       // Numero do Pedido de Venda
	aAdd(_aCampos, {"NOME"   , "C", 18, 0})       // Nome do Cliente
	aAdd(_aCampos, {"MUN"    , "C", 14, 0})       // Municipio do Cliente
	aAdd(_aCampos, {"EST"    , "C", 02, 0})       // Estado do Cliente
	aAdd(_aCampos, {"EMISSA" , "C", 05, 0})       // Data de Emissao do Pedido
	aAdd(_aCampos, {"DTLIB"  , "D", 08, 0})       // Data de Liberacao do Pedido
	aAdd(_aCampos, {"DIF"    , "C", 03, 0})       // Diferenca entre Liberacao e DataBase
	aAdd(_aCampos, {"ENTREG" , "C", 05, 0})       // Data de Entrega Prevista
	aAdd(_aCampos, {"VEND"   , "C", 10, 0})       // Nome do Vendedor
	aAdd(_aCampos, {"VRVENDA", "N", 15, 2})    // Total do pedido pelo valor de venda
	aAdd(_aCampos, {"PESOCOB", "N", 15, 2})    // Total do pedido pelo valor de venda

	aAdd(_aCampos, {"VRCUSTO", "N", 15, 2})     // Total do pedido pelo valor de custo        
	aAdd(_aCampos, {"VLUCRO" , "N", 15, 2})     
	aAdd(_aCampos, {"LUCROB" , "N", 15, 2})     
	aAdd(_aCampos, {"RESUMO" , "C", 05, 0})       // Semana do resumo              
	aAdd(_aCampos, {"OBS"    , "C", 22, 0})       // Observacoes do Pedido
	aAdd(_aCampos, {"SALDO"  , "C", 01, 0})       // É SALDO?
	aAdd(_aCampos, {"BLCRED" , "C", 02, 0})
	aAdd(_aCampos, {"COBRE"  , "N", 15, 3})       // É SALDO?
	aAdd(_aCampos, {"PVC"    , "N", 15, 3})       // É SALDO?

	aAdd(_aCampos, {"VLRTRF" , "N", 15, 2})    // Valor de transferência
	aAdd(_aCampos, {"COBTRF" , "N", 15, 2})    // Cobre na transferência
	aAdd(_aCampos, {"PVCTRF" , "N", 15, 3})    // PVC na transferência

	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf

	_cNomArq := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,, _cNomArq, "TRB", .T., .F.)

	Private _cInd := CriaTrab(Nil, .F.)
	If MV_PAR09 == 1 // Vendedor
		IndRegua("TRB", _cInd, "SETOR+VEND+MUN+NOME+PEDIDO",,, "Selecionando Registros...")
	Else
		IndRegua("TRB", _cInd, "SETOR+Dtos(DTLIB)+MUN+NOME+PEDIDO",,, "Selecionando Registros...")
	EndIf

	DbSetIndex(_cInd + OrdBagExt())

	DbSelectArea("SA1")
	DbSetOrder(1)  //A1_FILIAL+A1_COD+A1_LOJA

	DbSelectArea("SA3")
	DbSetOrder(1)  //A3_FILIAL+A3_COD

	DbSelectArea("SC9")
	DbSetOrder(1)  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO


	#IFDEF TOP
	DbSelectArea("SC5")
	DbSetOrder(1)  //C5_FILIAL+C5_NUM

	cQUER := " FROM "+RetSqlName("SC5")+" C5, "+RetSqlName("SC6")+" C6,"+RetSqlName("SF4")+" F4"
	cQUER += " WHERE C6.C6_NUM = C5.C5_NUM"
	cQUER += " AND C6.C6_TES  = F4.F4_CODIGO"
	cQUER += " AND F4.F4_FILIAL = '" + xFilial("SF4") + "'"
	cQUER += " AND (F4.F4_ESTOQUE = 'S' OR F4.F4_DUPLIC = 'S')"
	cQUER += " AND C6.C6_FILIAL = '" + xFilial("SC6") + "'"
	cQUER += " AND C6.C6_QTDVEN > C6.C6_QTDENT"
	cQUER += " AND C6.C6_BLQ <> 'R '"
	cQUER += " AND C5.C5_FILIAL = '" + xFilial("SC5") + "'"
	cQUER += " AND C5.C5_EMISSAO >= '" + DToS(Mv_Par03) + "'"
	cQUER += " AND C5.C5_EMISSAO <= '" + DToS(Mv_Par04) + "'"
	cQUER += " AND C5.C5_NUM     >= '" + Mv_Par01 + "'"
	cQUER += " AND C5.C5_NUM     <= '" + Mv_Par02 + "'"
	cQUER += " AND C5.C5_CLIENTE+C5.C5_LOJACLI >= '" + Mv_Par05 + Mv_Par06 + "'"
	cQUER += " AND C5.C5_CLIENTE+C5.C5_LOJACLI <= '" + Mv_Par07 + Mv_Par08 + "'"
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

	SetRegua(_Total)
	_AliasC5 := "RSC5"
	Do While RSC5->(!Eof())                           

	_cNumPd := RSC5->C5_NUM
	Do While RSC5->(!Eof()) .And. RSC5->C5_NUM ==  _cNumPd
	IncRegua()
	RSC5->(DbSkip())
	EndDo
	SC5->(DbSeek(xFilial("SC5")+_cNumPd,.F.))

	#ELSE

	_AliasC5 := "SC5"
	DbSelectArea("SC5")
	DbSetOrder(2)  //C5_FILIAL+DTOS(C5_EMISSAO)+C5_NUM
	SetRegua(RecCount())
	DbSeek(xFilial("SC5")+DToS(Mv_Par03),.T.)

	Do While SC5->C5_EMISSAO <= Mv_Par04 .And. SC5->C5_FILIAL == xFilial("SC5") .And. SC5->(!Eof())
	IncRegua()


	#ENDIF

	If lAbortPrint
	@ nLin,000 PSay "*** CANCELADO PELO OPERADOR ***"
	Exit
	EndIf
	// se tiver eliminado residuo??
	If SC5->C5_NUM     < Mv_Par01 .Or. SC5->C5_NUM     > Mv_Par02 .Or. ;
	SC5->C5_CLIENTE+SC5->C5_LOJACLI < Mv_Par05+Mv_Par06 .Or. ;
	SC5->C5_CLIENTE+SC5->C5_LOJACLI > Mv_Par07+Mv_Par08 .Or. ;
	SC5->C5_LIBEROK == "E" .Or. SC5->C5_NUM $ MV_PAR11+"/"+MV_PAR12
	DbSelectArea(_AliasC5)
	DbSkip()
	Loop
	EndIf
	SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
	SA3->(DbSeek(xFilial("SA3")+SC5->C5_VEND1,.F.))
	SC9->(DbSeek(xFilial("SC9")+SC5->C5_NUM,.F.))
	_lTemFat := .F.
	_lBlCred := .F.
	_lRejeit := .F.
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == SC5->C5_NUM .And. SC9->(!Eof())  
	IF sc9->c9_pedido $ "065436//065363"
	_xx := 1
	EndIf
	If SC9->C9_BLEST == "10" .Or. SC9->C9_BLCRED == "10"
	_lTemFat := .T.
	//		ElseIf !_lRejeit .And. SC9->C9_BLCRED == "09"
	ElseIf SC9->C9_BLCRED == "09"
	_lRejeit := .T.
	ElseIf !SC9->C9_BLCRED $ "  /10"
	_lBlCred := .T.
	EndIf
	If _lTemFat .And. _lBlCred
	Exit
	EndIf
	SC9->(DbSkip())
	EndDo
	SC9->(DbSeek(xFilial("SC9")+SC5->C5_NUM,.F.))
	If Empty(SC5->C5_DATALIB)
	If RecLock("SC5",.F.)  
	SC5->C5_DATALIB := SC9->C9_DATALIB
	MsUnLock()
	EndIf
	EndIf

	_nValTot := u_SomaPdOld(SC5->C5_NUM,.F.,"S","S",MV_PAR10) //(Nro.PV,Tudo ou só saldo,TES Estoque, TES Financeiro),Tabela 1 ou 2
	// SomaPed retorna o Valor de Venda e o Valor de Custo
	If _nValTot[1]+_nValTot[5] > 0.00 
	RecLock("TRB",.T.)
	TRB->SETOR  := If(SA1->A1_SETOR=="I","2","1")
	TRB->PEDIDO := SC5->C5_NUM
	TRB->NOME   := Left(SA1->A1_NOME,20)
	TRB->MUN    := Left(SA1->A1_MUN,15)
	TRB->EST    := SA1->A1_EST
	TRB->EMISSA := Left(DToC(SC5->C5_EMISSAO),5)
	TRB->DTLIB  := SC5->C5_DTLICRE // SC5->C5_DATALIB
	TRB->DIF    := Str(If(!Empty(SC5->C5_DATALIB),dDataBase-SC5->C5_DATALIB,0),3)
	TRB->ENTREG := Left(DToC(SC5->C5_ENTREG),5)
	If Type("SA3->A3_CONTAT") == "C"
	TRB->VEND   := Left(SA3->A3_CONTAT,10)
	Else
	TRB->VEND   := Left(SA3->A3_NREDUZ,10)
	EndIf
	TRB->VRVENDA:= _nValTot[1]
	TRB->VRCUSTO:= _nValTot[2] 
	TRB->PESOCOB:= _nValTot[3]
	TRB->VLUCRO := (TRB->VRVENDA-TRB->VRCUSTO)
	TRB->LUCROB := (TRB->VLUCRO / TRB->VRCUSTO) * 100
	TRB->RESUMO := Right(SC5->C5_SEMANA,5)
	TRB->OBS    := Left(SC5->C5_OBS,22)
	TRB->SALDO  := If(_lTemFat,"S"," ")
	TRB->BLCRED := If(_lRejeit,"RJ",If(_nValTot[8],"BV",If(_lBlCred,"BF","  ")))
	TRB->COBRE  := _nValTot[3] 
	TRB->PVC    := _nValTot[4] 

	TRB->VLRTRF := _nValTot[5]
	TRB->COBTRF := _nValTot[6]
	TRB->PVCTRF := _nValTot[7]
	MsUnLock()
	EndIf
	DbSelectArea(_AliasC5) 
	#IFNDEF TOP
	DbSkip()	// so dou o dbskip se nao for top
	#ENDIF
	EndDo

	#IFDEF TOP
	DbSelectArea("RSC5")
	DbCloseArea("RSC5")
	#ENDIF

	DbSelectArea("TRB")
	SetRegua(RecCount())
	DbGoTop()


	/*/
	_cGrupo := PSWRET()
	_lEhVendas := .F.
	_cGrupos := ""
	For _nnn:=1 to Len(_cGrupo[1,10])
	If _cGrupo[1,10,_nnn] == "000001" // Grupo de vendas
	_lEhVendas := .T.
	Exit
	EndIf
	Next
	/*/


	If _lEhVendas
	Cabec1 := "Pedido Nome do Cliente    Cidade         UF Emis. Lib.   #  Entr. Repres.         Valor  Ft.    LB  Resumo Observacao"
	Else
	Cabec1 := "Pedido Nome do Cliente    Cidade         UF Emis.        #  Entr. Repres.         Valor             Resumo Observacao"
	EndIf

	_nTotG := 0.00 // Total Geral Valor
	_nLucG := 0.00 // Total geral Custo

	_nTtStVl := 0.00 // Total Setor Valor
	_nTtStCs := 0.00 // Total Setor Custo

	_nTtVdVl := 0.00 // Total Vendedor Valor
	_nTtVdCs := 0.00 // Total Vendedor Custo
	_nTtVdPs := 0.00 // Total Vendedos Peso Cobre

	_nSomaCb := 0.00 // Soma do Cobre
	_nSomaPV := 0.00 // Soma do PVC

	_nSomTCb := 0.00 // Soma do Cobre Transferência
	_nSomTPV := 0.00 // Soma do PVC Transferência

	_nTotaCb := 0.00 // Total do Cobre
	_nTotaPV := 0.00 // Total do PVC

	_nTotTCb := 0.00 // Total do Cobre Transferência
	_nTotTPV := 0.00 // Total do PVC Transferência


	_cAnt  := If(MV_PAR09==1,Space(Len(TRB->VEND)),Ctod(""))

	_Setor := " "
	If !MV_PAR14 $ "BV///BF///RJ///**///"
	MV_PAR14 := "**"
	EndIf

	Do While TRB->(!Eof())   

	If lAbortPrint
	@ nLin,000 PSay "*** CANCELADO PELO OPERADOR ***"
	Exit
	EndIf

	If MV_PAR14 # "**" .And. TRB->BLCRED # MV_PAR14
	DbSkip()
	Loop
	EndIf


	If (TRB->SETOR # _Setor .Or. TRB->(Eof()) .Or. _cAnt # If(MV_PAR09==1,TRB->VEND,TRB->DTLIB)) .And. !Empty(_Setor)
	//		If _nTtVdVl # 0
	nLin := ImpTotOld(nLin,1) // Total do Vendedor
	nLin++
	@ nLin,000 PSay Replicate("-",limite)
	nLin++
	//		EndIf
	_nTtVdVl := 0.00 // Total Vendedor Valor
	_nTtVdCs := 0.00 // Total Vendedor Custo
	_nTtVdPs := 0.00 // Total Vendedos Peso Cobre
	_cAnt  := If(MV_PAR09==1,TRB->VEND,TRB->DTLIB)
	EndIf

	If TRB->SETOR # _Setor
	If _nTtStVl # 0 
	nLin := ImpTotOld(nLin,2) // Total do Setor
	nLin++
	@ nLin,000 PSay Replicate("-",limite)
	nLin++
	_nTtStVl := 0.00 // Total Setor Valor
	_nTtStCs := 0.00 // Total Setor Custo
	_nSomaCb := 0.00 // Soma do Cobre
	_nSomaPV := 0.00 // Soma do PVC
	_nSomTCb := 0.00 // Soma do Cobre Transferência
	_nSomTPV := 0.00 // Soma do PVC Transferência
	EndIf
	_lStVazio := Empty(_Setor)
	_Setor := TRB->SETOR 
	If TRB->SETOR == "1" // Revenda
	Titulo := "Carteira de Pedidos - De "+DToC(Mv_Par03)+" Ate "+DToC(Mv_Par04) + " Revenda"
	ElseIf TRB->SETOR == "2" // Industria
	Titulo := "Carteira de Pedidos - De "+DToC(Mv_Par03)+" Ate "+DToC(Mv_Par04) + " Industria"
	EndIf     

	If MV_PAR14 $ "BV///BF///RJ///"
	Titulo := Titulo + " (Bloq. " + MV_PAR14 + ")"
	EndIf
	If !_lStVazio
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 8
	EndIf
	EndIf	
	IncRegua()

	If nLin > 60
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 8
	EndIf

	_nFator := TRB->VRVENDA / TRB->PESOCOB

	@ nLin,000 PSay TRB->PEDIDO
	@ nLin,007 PSay TRB->NOME
	@ nLin,026 PSay TRB->MUN
	@ nLin,041 PSay TRB->EST
	@ nLin,044 PSay TRB->EMISSA
	If _lEhVendas
	@ nLin,050 PSay Left(DToC(TRB->DTLIB),5)
	EndIf
	@ nLin,056 PSay TRB->DIF
	@ nLin,060 PSay TRB->ENTREG
	@ nLin,066 PSay TRB->VEND
	@ nLin,076 PSay (TRB->VRVENDA+TRB->VLRTRF) Picture If((TRB->VRVENDA+TRB->VLRTRF)>9999999.99,"@E 99999999.99","@E 9999,999.99")
	If _nFator # 0 .And. _lEhVendas
	@ nLin,088 PSay _nFator   	Picture "@E 99.9"
	@ nLin,093 PSay TRB->LUCROB		Picture "@E 999.99" // Picture "@E 999.99"
	EndIf
	@ nLin,099 PSay TRB->SALDO
	@ nLin,101 PSay TRB->RESUMO
	@ nLin,107 PSay TRB->OBS       
	//	If _lEhVendas
	@ nLin,129 PSay If(!Empty(TRB->BLCRED),"/"+TRB->BLCRED,"")
	//	ElseIf !("BF" $ TRB->BLCRED)
	//		@ nLin,129 PSay If(!Empty(TRB->BLCRED),"/"+TRB->BLCRED,"")
	//	EndIf

	nLin++

	_nTotG += TRB->VRVENDA   // Total Geral Valor
	_nLucG += TRB->VRCUSTO   // Total Geral Custo

	_nTtStVl += TRB->VRVENDA // Total Setor Valor
	_nTtStCs += TRB->VRCUSTO // Total Setor Custo

	_nTtVdVl += TRB->VRVENDA // Total Vendedor Valor
	_nTtVdCs += TRB->VRCUSTO // Total Vendedor Custo
	_nTtVdPs += TRB->COBRE   // Total Vendedos Peso Cobre

	_nSomaCb += TRB->COBRE   // Soma do Cobre
	_nSomaPV += TRB->PVC     // Soma do PVC

	_nSomTCb += TRB->COBTRF // Soma do Cobre Transferência
	_nSomTPV += TRB->PVCTRF // Soma do PVC Transferência

	_nTotaCb += TRB->COBRE   // Total do Cobre
	_nTotaPV += TRB->PVC     // Total do PVC

	_nTotTCb += TRB->COBTRF  // Total do Cobre Transferência
	_nTotTPV += TRB->PVCTRF  // Total do PVC Transferência

	DbSelectArea("TRB")
	DbSkip()
	EndDo   
	If _nTtVdVl # 0 
	nLin := ImpTotOld(nLin,1) // Total do Setor
	nLin++
	@ nLin,000 PSay Replicate("-",limite)
	nLin++
	EndIf
	If _nTtStVl # 0 
	nLin := ImpTotOld(nLin,2) // Total do Setor
	nLin++
	@ nLin,000 PSay Replicate("-",limite)
	nLin++
	EndIf
	If _nTotG # 0 
	nLin := ImpTotOld(nLin,3) // Total da Carteira
	nLin++
	@ nLin,000 PSay Replicate("-",limite)
	nLin++
	EndIf

	Roda(0,"",Tamanho)

	DbSelectArea("TRB")
	DbCloseArea("TRB")
	Delete File (_cNomarq + ".DTC")
	Delete File (_cInd + OrdBagExt())
	@ 0,0 Psay Chr(27) + "@"
	SET DEVICE TO SCREEN
	If aReturn[5]==1
	DbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
	EndIf

	MS_FLUSH()

Return

/////////////////////////
Static Function VldPerOld()
	/////////////////////////

	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Do Pedido                    ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até o Pedido                 ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Da Data de Emissão           ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Até a Data de Emissão        ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Do Cliente                   ?","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"06","Da Loja                      ?","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Até o Cliente                ?","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"08","Até a Loja                   ?","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Ordem                        ?","mv_ch9","N",01,0,0,"C","","mv_par09","Vendedor","","","Dt.Liberacão","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","Base de Custo                ?","mv_cha","N",01,0,0,"C","","mv_par10","Tabela 1","","","Tabela 2","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"11","NAO Incluir Pedidos          ?","mv_chb","C",99,0,0,"G","","mv_par11","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","Continuação                  ?","mv_chc","C",99,0,0,"G","","mv_par12","","","","","","","","","","","","","","",""})

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

/////////////////////////////////
User Function SomPdOldL(_cPedido,lTudo,cEstq,cFinan,nTab)
	/////////////////////////////////

	Private _aLucro := {0,0,0,0,0,0,0,.F.} // Total Vlr.Venda,Total Vlr.Custo,Peso Cobre,PesoPVC,Vlr.Transferencia,Cobre Transf.,PVC TRansf,Tem itens não liberados?
	//lTudo := If(Type("lTudo") == "U",.T.,lTudo)

	SB1->(DbSetOrder(1))

	SF4->(DbSetOrder(1))

	SA1->(DbSetOrder(1))

	DbSelectArea("SC6")
	DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	DbSeek(xFilial("SC6")+_cPedido,.F.)
	SA1->(DbSeek(xFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA,.F.))
	Do While SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+_cPedido .And. SC6->(!Eof())
		If SC6->C6_BLQ # "R " // "R" - Residuo não eliminado
			// Este item não está totalmente liberado?
			If !_aLucro[8] .And. (SC6->C6_QTDEMP+SC6->C6_QTDENT) < SC6->C6_QTDVEN
				_aLucro[8] := .T.
			EndIf

			SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.))
			SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES,.F.))
			If lTudo // De toda a quantidade vendida
				If SF4->F4_DUPLIC == "S"
					_aLucro[1] += SC6->C6_QTDVEN * SC6->C6_PRCVEN                                                
					If FWCodEmp()+FWCodFil() == "0102" // 3 lagoas
						_aLucro[2] += SC6->C6_QTDVEN * SB1->B1_CUSTD3L
					Else
						_aLucro[2] += SC6->C6_QTDVEN * SB1->B1_CUSTD
					EndIf
					If SF4->F4_ESTOQUE == "S"
						_aLucro[3] += SC6->C6_QTDVEN * SB1->B1_PESCOB
						_aLucro[4] += SC6->C6_QTDVEN * SB1->B1_PESPVC 
					EndIf
				Else
					_aLucro[5] += SC6->C6_QTDVEN * SC6->C6_PRCVEN                                                
					If SF4->F4_ESTOQUE == "S" 
						//Verificar tambm se o material esta sendo enviado para Itu ou 3L  
						If "02544042" $ SA1->A1_CGC
							_aLucro[6] += SC6->C6_QTDVEN * SB1->B1_PESCOB
							_aLucro[7] += SC6->C6_QTDVEN * SB1->B1_PESPVC
						Else
							_aLucro[3] += SC6->C6_QTDVEN * SB1->B1_PESCOB
							_aLucro[4] += SC6->C6_QTDVEN * SB1->B1_PESPVC 
						EndIf
					EndIf
				EndIf
			ElseIf SC6->C6_QTDVEN > SC6->C6_QTDENT .And. (SF4->F4_ESTOQUE $ cEstq .Or. SF4->F4_DUPLIC $ cFinan)
				//		ElseIf SC6->C6_QTDVEN > SC6->C6_QTDENT .And. SF4->F4_ESTOQUE $ cEstq .And. SF4->F4_DUPLIC $ cFinan
				// Somente do saldo a faturar        

				If SF4->F4_DUPLIC == "S" // E faturamento
					If FWCodEmp()+FWCodFil() == "0102" // 3 lagoas
						_aLucro[2] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_CUSTD3L
					Else
						_aLucro[2] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_CUSTD
					EndIf

					_aLucro[1] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SC6->C6_PRCVEN

					If SF4->F4_ESTOQUE == "S" // Se e faturamento, assumo o cobre e pvc para ele
						_aLucro[3] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_PESCOB
						_aLucro[4] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_PESPVC  
					EndIf				
				Else     // Nao e faturamento
					_aLucro[5] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SC6->C6_PRCVEN
					If SF4->F4_ESTOQUE == "S"// Se nao e faturamento, assumo o cobre e pvc como transferencia
						//Verificar tambem se o material esta sendo enviado para Itu ou 3L
						If "02544042" $ SA1->A1_CGC
							_aLucro[6] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_PESCOB
							_aLucro[7] += (SC6->C6_QTDVEN-SC6->C6_QTDENT) * SB1->B1_PESPVC
						Else
							_aLucro[3] += SC6->C6_QTDVEN * SB1->B1_PESCOB
							_aLucro[4] += SC6->C6_QTDVEN * SB1->B1_PESPVC 
						EndIf
					EndIf
				EndIf           
			EndIf
		EndIf
		SC6->(DbSkip())
	EndDo

	Return(_aLucro)
	*
	******************************
Static Function ImpTotOld(nLin,_nQual)
	******************************
	*
	*
	If nLin > 58
		nLin := Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	EndIf
	If _nQual ==  1 // Vendedor/Representante
		_nFator := _nTtVdVl / _nTtVdPs
		@ nLin,050 PSay If(MV_PAR09==1,"Total do Representante: ","Total da Data: ")
		@ nLin,074 PSay _nTtVdVl		    				Picture "@E 99,999,999.99"
		If _lEhVendas
			@ nLin,088 PSay _nFator   	Picture "@E 99.9"
			@ nLin,093 PSay ((_nTtVdVl-_nTtVdCs)/_nTtVdCs)*100 	Picture "@E 999.99"
		EndIf
	ElseIf _nQual == 2 // Setor
		@ nLin,050 PSay "Total " + If(_Setor == "1","Revenda:","Industria:")
		@ nLin,074 PSay _nTtStVl		    				Picture "@E 99,999,999.99"

		If _lEhVendas
			@ nLin++,093 PSay ((_nTtStVl-_nTtStCs)/_nTtStCs)*100 	Picture "@E 999.99"

			@ nLin,001 PSay "Materia Prima --> Cobre     ="
			@ nLin,031 PSay _nSomaCb Picture "@E 99,999,999"
			@ nLin,042 PSay "Kg (F="
			@ nLin,048 PSay _nTtStVl/_nSomaCb    Picture "@E 999.9"
			@ nLin,053 PSay ")    PVC     ="
			@ nLin,069 PSay _nSomaPV Picture "@E 99,999,999"
			@ nLin,080 PSay "Kg (F="
			@ nLin,086 PSay _nTtStVl/_nSomaPV    Picture "@E 999.9"
			@ nLin,091 PSay ")        Total ="
			@ nLin,109 PSay _nSomaCb+_nSomaPV Picture "@E 99,999,999"
			@ nLin,120 PSay "Kg (F="
			@ nLin,126 PSay _nTtStVl/(_nSomaCb+_nSomaPV)    Picture "@E 999.9"
			@ nLin,131 PSay ")"
		Else
			@ ++nLin,001 PSay "Materia Prima --> Cobre     ="
			@ nLin,031 PSay _nSomaCb Picture "@E 99,999,999"
			@ nLin,042 PSay "Kg"
			@ nLin,053 PSay "     PVC     ="
			@ nLin,069 PSay _nSomaPV Picture "@E 99,999,999"
			@ nLin,080 PSay "Kg"
			@ nLin,091 PSay "         Total ="
			@ nLin,109 PSay _nSomaCb+_nSomaPV Picture "@E 99,999,999"
			@ nLin,120 PSay "Kg"
		EndIf

		nLin++

		@ nLin,001 PSay "                  Cobre(TRF)="
		@ nLin,031 PSay _nSomTCb Picture "@E 99,999,999"
		@ nLin,042 PSay "Kg"
		@ nLin,053 PSay "     PVC(TRF)="
		@ nLin,069 PSay _nSomTPV Picture "@E 99,999,999"
		@ nLin,080 PSay "Kg"	

	ElseIf _nQual == 3 // Total carteira
		@ nLin,050 PSay "Total Geral:"
		@ nLin,074 PSay _nTotG   		    				Picture "@E 99,999,999.99"

		If _lEhVendas
			@ nLin++,093 PSay ((_nTotG-_nLucG)/_nLucG)*100 	Picture "@E 999.99"

			@ nLin,001 PSay "Materia Prima --> Cobre     ="
			@ nLin,031 PSay _nTotaCb Picture "@E 99,999,999"
			@ nLin,042 PSay "Kg (F="
			@ nLin,048 PSay _nTotG/_nTotaCb    Picture "@E 999.9"
			@ nLin,053 PSay ")    PVC     ="
			@ nLin,069 PSay _nTotaPV Picture "@E 99,999,999"
			@ nLin,080 PSay "Kg (F="
			@ nLin,086 PSay _nTotG/_nTotaPV    Picture "@E 999.9"
			@ nLin,091 PSay ")        Total ="
			@ nLin,109 PSay _nTotaCb+_nTotaPV Picture "@E 99,999,999"
			@ nLin,120 PSay "Kg (F="
			@ nLin,126 PSay _nTotG/(_nTotaCb+_nTotaPV)    Picture "@E 999.9"
			@ nLin,131 PSay ")"
		Else
			@ ++nLin,001 PSay "Materia Prima --> Cobre     ="
			@ nLin,031 PSay _nTotaCb Picture "@E 99,999,999"
			@ nLin,042 PSay "Kg"
			@ nLin,053 PSay "     PVC     ="
			@ nLin,069 PSay _nTotaPV Picture "@E 99,999,999"
			@ nLin,080 PSay "Kg"
			@ nLin,091 PSay "         Total ="
			@ nLin,109 PSay _nTotaCb+_nTotaPV Picture "@E 99,999,999"
			@ nLin,120 PSay "Kg"
		EndIf

		nLin++

		@ nLin,001 PSay "                  Cobre(TRF)="
		@ nLin,031 PSay _nTotTCb Picture "@E 99,999,999"
		@ nLin,042 PSay "Kg"
		@ nLin,053 PSay "     PVC(TRF)="
		@ nLin,069 PSay _nTotTPV Picture "@E 99,999,999"
		@ nLin,080 PSay "Kg"
	EndIf
Return(nLin)          

// Materia Prima --->    Cobre = 99,999,999 Kg (F=999.9)        PVC =  99,999,999 Kg (F=999.9)        Total =  99,999,999 Kg (F=999.9)
// 
// _nSomaCb := 0.00 // Soma do Cobre
// _nSomaPV := 0.00 // Soma do PVC
//
// _nTotaCb := 0.00 // Total do Cobre
// _nTotaPV := 0.00 // Total do PVC