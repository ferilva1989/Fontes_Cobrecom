#INCLUDE "COLORS.CH"
#Include "PROTHEUS.CH"
#include "rwmake.ch"
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDBAL04                            Modulo : SIGAEST      //
//                                                                          //
//   Autor ......: Roberto Oliveira                   Data ..: 30/06/2010   //
//                                                                          //
//   Objetivo ...: Transferir produtos Quase Acabados para o almox.95       //
//                 ESA - Estoque Semi Acabados. Somente poderão ser rea-    //
//                 lizados novimentos de transferência do 99 para o 95 e    //
//                 do 95 para o 99, não podendo envolver o almox. 95 com    //
//                 outro qualquer e sempre a transferência será na quan-    //
//                 tidade total da bobina.                                  //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
*
************************
User Function CDBAL04()
	************************
	*
	*
	Private _lFiltro := .F.
	If SM0->M0_CODIGO == "01"
		Processa({|| U_Movin95()},"Aguarde Atualização das Tabelas...")
	EndIf

	aCores    := {{"ZU_STATUS$'13'","ENABLE"  },;  // Verde    - Bobina em estoque
	{"ZU_STATUS$'24'","DISABLE"}}    // Vermelho - Bobina baixada

	cCadastro := "Transferência de Bobinas Para/Do ESA"
	aRotina := {{ "Pesquisar"        , "AxPesqui"     , 0, 1},;
	{ "Visualizar"       , "AxVisual"     , 0, 2},;
	{ "Enviar P/ESA"     , "U_BAL04ENV()" , 0, 3},;
	{ "Devolver do ESA"  , "U_BAL04DEV()" , 0, 2},;
	{ "Impr.Etiqueta"    , "u_ImprEtESA()", 0, 2},;
	{ "Filtrar/Limpar Filtro"    , "u_FiltraESA()", 0, 2},;
	{ "Legenda"          , "U_CDBAL04LG"  , 0, 2}}
	DbSelectArea("SZU")
	DbSetOrder(1) //ZU_FILIAL+ZU_LOTE+ZU_PRODUTO
	DbSeek(xFilial("SZU"),.F.)

	mBrowse(001,040,200,390,"SZU",,,,,,aCores)
	DbSelectArea("SZU")
	DbClearFilter()

	Return(.T.)           
	*
	*************************
User Function CDBAL04LG()
	*************************
	*
	BrwLegenda(cCadastro,"Legenda",{{"ENABLE"  ,"Bobina em Estoque no ESA"},;
	{"DISABLE" ,"Bobina já Retornada para a Fábrica"}})
	Return(.T.)  
	*
	************************
User Function BAL04ENV()
	************************
	*
	*
	Local cOrder

	DbSelectArea("SZU")
	cOrder := IndexOrd()

	nOpca := AxInclui("SZU",0,3,,,,"u_Valbal04()")
	If nOpca == 1         
		_nRegSZU   := SZU->(Recno())
		_cNewContr := SZU->ZU_CONTROL
		SZU->(DbSetOrder(3))
		SZU->(DbSkip(-1)) // Volta 1
		_cNumCt1 := SZU->ZU_CONTROL
		SZU->(DbSkip(2))  // Avança 2 (o seguinte ao registro incluido)
		_cNumCt2 := SZU->ZU_CONTROL                                    
		SZU->(DbGoTo(_nRegSZU)) // Volta para o registro corrente

		If SZU->ZU_CONTROL $ _cNumCt1 + "//" + _cNumCt2 .Or. ;
		StrZero(Val(SZU->ZU_CONTROL),Len(SZU->ZU_CONTROL)) # SZU->ZU_CONTROL // Ve se tem alguma letra na variavel -> não pode
			// Já existe esse nro ou tem letra - não pode pelo cód de barras

			SZU->(DbSetOrder(3)) // ZU_FILIAL+ZU_CONTROL
			SZU->(DbSeek(xFilial("SZU") + Replicate("9",Len(SZU->ZU_CONTROL)),.T.)) // DbSeek com SoftSeek = .T.
			Do While SZU->ZU_FILIAL # xFilial("SZU") .And. !SZU->(Bof())
				SZU->(DbSkip(-1))
			EndDo
			Do While SZU->ZU_FILIAL == xFilial("SZU") .And. !SZU->(Bof()) .And. StrZero(Val(SZU->ZU_CONTROL),Len(SZU->ZU_CONTROL)) # SZU->ZU_CONTROL
				SZU->(DbSkip(-1))
			EndDo
			If SZU->(Bof()) .Or. SZU->ZU_FILIAL # xFilial("SZU")
				_cNewContr := StrZero(1,Len(SZU->ZU_CONTROL))
			Else
				_cNewContr := StrZero(Val(SZU->ZU_CONTROL)+1,Len(SZU->ZU_CONTROL))
			EndIf
			SZU->(DbGoTo(_nRegSZU))
		EndIf
		RecLock("SZU",.F.)
		SZU->ZU_CONTROL := _cNewContr
		SZU->ZU_DTINC   := Date()
		SZU->ZU_TURNOIN := u_CalcTurno(Time())
		SZU->ZU_STATUS := "1"
		MsUnLock()
		If SM0->M0_CODIGO == "01"
			Transfere("E") // _cMovic = E_nvio ou R_etorno
			RecLock("SZU",.F.)
			SZU->ZU_STATUS := "3"
			MsUnLock()
		EndIf      
		u_ImprEtESA()
	EndIf            
	DbSelectArea("SZU")
	DbSetOrder(cOrder)
	Return(.T.)
	*
	************************
User Function BAL04DEV()
	************************
	*
	If !SZU->ZU_STATUS $ "13"
		Alert("Material já devolvido")
	Else	
		nOpca := AxVisual("SZU",Recno(),2) //	nOpca := AxAltera("SZU",Recno(),4, , , ,)
		If nOpca == 1
			If MsgBox("Confirma a devolução do material do ESA?","Confirma?","YesNo")
				RecLock("SZU",.F.)
				SZU->ZU_DTRETOR := Date()
				SZU->ZU_TURNORE := u_CalcTurno(Time())
				If SZU->ZU_STATUS == "1"
					SZU->ZU_STATUS := "4"
				Else
					SZU->ZU_STATUS := "2" //Marca como devolvido mas nãp movimentado no SD3.// porque se estiver fora do ambiente oficial o movimento nÃo pode ser realizado agora
				EndIf
				MsUnLock()
				If SM0->M0_CODIGO == "01" .And. SZU->ZU_STATUS == "2"
					Transfere("R") // _cMovic = E_nvio ou R_etorno
					RecLock("SZU",.F.)
					SZU->ZU_STATUS := "4"
					MsUnLock()
				EndIf
			EndIf
		EndIf            
	EndIf
	DbSelectArea("SZU")
	Return(.T.)  
	*
	************************
User Function Valbal04()
	************************
	*
	If M->ZU_LANCE1+M->ZU_LANCE2+M->ZU_LANCE3+M->ZU_LANCE4+M->ZU_LANCE5+M->ZU_LANCE6 # M->ZU_TOTAL
		Alert("A soma dos lances deve ser igual a quantidade total")
		Return(.F.)
	EndIf
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+M->ZU_PRODUTO,.F.))
	If Left(SB1->B1_COD,1) # "Q"
		Alert("Usar somente produtos semi acabados")
		Return(.F.)
	ElseIf SB1->B1_LOCALIZ == "S" .Or. SB1->B1_RASTRO == "S"
		Alert("Não usar produtos com controle de lote/localização")
		Return(.F.)
	EndIf
	Return(.T.)
	*
	***********************
User Function ValLote()
	***********************
	*         
	_lVolta := .T.
	If !Empty(M->ZU_PRODUTO) .and. !Empty(M->ZU_LOTE)
		DbSelectArea("SZU")
		DbSetOrder(1) //ZU_FILIAL+ZU_LOTE+ZU_PRODUTO
		If DbSeek(xFilial("SZU")+M->ZU_LOTE+M->ZU_PRODUTO,.F.)
			Alert("Lote já informado para esse produto")
			_lVolta := .F.
		EndIf
	EndIf
	Return(_lVolta)
	*
	*******************************
User Function CalcTurno(_cCHra)
	*******************************
	*
	_MyTime := Left(_cCHra,5) 
	If _MyTime >= "06:01" .And. _MyTime <= "14:00"
		_MyTurbo := "1"
	ElseIf _MyTime >= "14:01" .And. _MyTime <= "22:00"
		_MyTurbo := "2"
	ElseIf _MyTime >= "22:01" .Or.  _MyTime <= "06:00"
		_MyTurbo := "3"
	EndIf        
	Return(_MyTurbo)
	*
	********************************
Static Function Transfere(_cMovic)
	********************************
	*                              
	// _cMovic = E_nvio ou R_etorno

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Pega o proximo numero sequencial de movimento      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea("SD3")
	DbSetOrder(4) //D3_FILIAL+D3_NUMSEQ+D3_CHAVE+D3_COD

	// continuar aqui

	cNumSeq := ProxNum()

	DbSelectArea("SB1")
	DbSeek(xFilial("SB1")+SZU->ZU_PRODUTO,.F.)

	For _nMovts := 1 To 2
		If     _nMovts == 1 .And. _cMovic == "E" // Fazer Requisição no Local 99
			_cTM := "RE4"
			_cLocal := "99"
		ElseIf _nMovts == 1 .And. _cMovic == "R" // Fazer Requisição no Local 95
			_cTM := "RE4"
			_cLocal := "95"
		ElseIf _nMovts == 2 .And. _cMovic == "E" // Fazer Devolução  no Local 95
			_cTM := "DE4"
			_cLocal := "95"
		ElseIf _nMovts == 2 .And. _cMovic == "R" // Fazer Devolução  no Local 95
			_cTM := "DE4"
			_cLocal := "99"
		EndIf

		DbSelectArea("SB2") 
		If !DbSeek(xFilial("SB2")+SZU->ZU_PRODUTO+_cLocal,.F.)
			CriaSB2(SZU->ZU_PRODUTO,_cLocal)
		EndIf
		RecLock("SB2",.F.)

		RecLock("SD3",.T.)
		SD3->D3_FILIAL  := xFilial("SD3")
		SD3->D3_TM      := If(_cTM == "RE4","999","499")
		SD3->D3_COD     := SZU->ZU_PRODUTO
		SD3->D3_UM      := SB1->B1_UM
		SD3->D3_QUANT   := SZU->ZU_TOTAL
		SD3->D3_CF      := _cTM
		SD3->D3_LOCAL   := _cLocal
		SD3->D3_EMISSAO := dDataBase
		SD3->D3_NUMSEQ  := cNumSeq
		SD3->D3_TIPO    := SB1->B1_TIPO
		SD3->D3_USUARIO := cUserName
		SD3->D3_CHAVE   := If(_cTM == "RE4","E0","E9")
		SD3->D3_GRUPO   := SB1->B1_GRUPO
		SD3->D3_SEGUM   := SB1->B1_SEGUM
		SD3->D3_CONTA   := SB1->B1_CONTA

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Pega os 15 custos medios atuais            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava o custo da movimentacao              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCusto := GravaCusD3(aCM)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza o saldo atual (VATU) com os dados do SD3     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_lErrAtu := B2AtuComD3(aCusto,,.F.) // .F.->Não mostra help se der erro // Retorna .T. se deu erro na atualização
		SB1->(MsUnLock())
		SB2->(MsUnLock())
		SD3->(MsUnLock())
	Next
	Return(.T.)
	*                        
	*************************
User Function ImprEtESA()
	*************************
	*              
	Private wnrel   := "ETIBAL04"
	Private cString := "ETIBAL04"
	Private aReturn     := {"Zebrado",1,"Administracao",1,3,"COM2","",1}

	//If SM0->M0_CODIGO # "99" // Somente balanca pode imprimir a etiqueta
	//	Return(.T.)
	//EndIf

	// Posiciona Tabelas
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+Right(SZU->ZU_PRODUTO,Len(SB1->B1_COD)-1),.F.)

	DbSelectArea("SZ1")
	DbSetOrder(1)
	SZ1->(DbSeek(xFilial("SZ1")+SB1->B1_NOME,.F.))

	DbSelectArea("SZ2")
	DbSetOrder(1)
	SZ2->(DbSeek(xFilial("SZ2")+SB1->B1_BITOLA,.F.))

	DbSelectArea("SZ3")
	DbSetOrder(1)
	SZ3->(DbSeek(xFilial("SZ3")+SB1->B1_COR,.F.))

	SetDefault(aReturn,cString)

	// Copia o Logo para a impressora Zebra

	//! Copy "C:\BALANCA\LOGO30A.GRF" -> COM2


	@ 0,0 PSAY "^XA^LH8,16^PRC^FS"
	@ 0,0 PSAY "^FX ======================================================== ^FS"
	@ 0,0 PSAY "^FX =               *** ETIQUETA P/ BOBINAS ***            = ^FS"
	@ 0,0 PSAY "^FX =                                                      = ^FS"
	@ 0,0 PSAY "^FX =      Etiqueta desenvolvida por Valter Sanavio e      = ^FS"
	@ 0,0 PSAY "^FX =            Roberto Oliveira em 29/10/2008            = ^FS"
	@ 0,0 PSAY "^FX ======================================================== ^FS"
	@ 0,0 PSAY "^FO008,012,^GB800,600,6^FS"
	@ 0,0 PSAY "^FX ==== LINHAS HORIZONTAIS =============================== ^FS"
	@ 0,0 PSAY "^FO008,092^GB800,001,4^FS"
	@ 0,0 PSAY "^FO008,212^GB800,001,4^FS"
	@ 0,0 PSAY "^FO008,284^GB800,001,4^FS"
	@ 0,0 PSAY "^FO008,356^GB800,001,4^FS"
	@ 0,0 PSAY "^FO008,420^GB664,001,4^FS"
	@ 0,0 PSAY "^FO008,484^GB664,001,4^FS"
	@ 0,0 PSAY "^FX ==== LINHAS VERTICAIS ================================ ^FS"
	@ 0,0 PSAY "^FO608,092^GB001,120,4^FS"
	@ 0,0 PSAY "^FO208,212^GB001,144,4^FS"
	@ 0,0 PSAY "^FO568,212^GB001,072,4^FS"
	@ 0,0 PSAY "^FO404,284^GB001,072,4^FS"
	@ 0,0 PSAY "^FO604,284^GB001,072,4^FS"
	@ 0,0 PSAY "^FO232,356^GB001,130,4^FS"
	@ 0,0 PSAY "^FO452,356^GB001,130,4^FS"
	@ 0,0 PSAY "^FO672,356^GB001,256,4^FS"
	@ 0,0 PSAY "^FX ===== LOGO COBRECOM ==================================== ^FS"
	@ 0,0 PSAY "^FO024,014^XGLOGO30A.GRF^FS"
	@ 0,0 PSAY "^FO344,024^A0N,15,22^FDI.F.C. IND. COM. CONDUTORES ELETRICOS LTDA^FS"
	If FWCodFil() == "01" // Itu / Matriz
		@ 0,0 PSAY "^FO344,040^A0N,15,22^FDAv. Primo Schincariol, 670-Jd. Oliveira-ITU/SP^FS"
		@ 0,0 PSAY "^FO344,056^A0N,15,22^FDFone: (11) 2118.3200  -  CEP 13312.250^FS"
		@ 0,0 PSAY "^FO344,072^A0N,15,22^FDCNPJ 02.544.042/0001-19   I.E.387.086.243.118^FS"
	ElseIf FWCodFil() == "02" // Filial / 3 Lagoas
		@ 0,0 PSAY "^FO344,040^A0N,15,22^FDAv. Dois, s/n-Esq. Av. Cinco-Distr.Industrial^FS"
		@ 0,0 PSAY "^FO344,056^A0N,15,22^FDTres Lagoas-MS F: (67)3221-2500-CEP 79601-970^FS"
		@ 0,0 PSAY "^FO344,072^A0N,15,22^FDCNPJ 02.544.042/0002-08     I.E. 283.453.354^FS"
	EndIf
	@ 0,0 PSAY "^FO096,078^A0N,15,22^FDIndustria Brasileira^FS"
	@ 0,0 PSAY "^FX ===== 1a. LINHA DESCRICAO PRODUTO ====================== ^FS"
	@ 0,0 PSAY "^FO008,092^GB600,120,120^FS"
	@ 0,0 PSAY "^FO016,100^A0N,15,17^FR^FDPRODUTO^FS"
	@ 0,0 PSAY "^FO024,120^A0N,50,50^FR^FD" + AllTrim(SZ1->Z1_NOME) + "^FS"
	@ 0,0 PSAY "^FO024,184^A0N,20,20^FR^FDSECAO:^FS"
	@ 0,0 PSAY "^FO104,170^A0N,47,67^FR^FD" + Str(SZ1->Z1_VIAS,2) + "x" + AllTrim(SZ2->Z2_BITOLA) + "^FS"
	@ 0,0 PSAY "^FO312,184^A0N,25,25^FR^FDmm^FS"
	@ 0,0 PSAY "^FO354,176^A0N,20,20^FR^FD2^FS"
	@ 0,0 PSAY "^FO378,176^A0N,35,35^FR^FD" + AllTrim(SZ3->Z3_DESC) + "^FS"
	@ 0,0 PSAY "^FX ===== DEMAIS CAMPOS DA ETIQUETA ========================= ^FS"
	@ 0,0 PSAY "^FO616,100^A0N,15,22^FDCOMPRIMENTO (m)^FS"
	@ 0,0 PSAY "^FO624,132^A0N,75,65^FD" + AllTrim(Str(SZU->ZU_TOTAL)) + "^FS	
	@ 0,0 PSAY "^FO016,220^A0N,15,17^FDTENSAO ISOLAMENTO^FS"
	_cTensao := SZ1->Z1_DESC3
	If Type("SZ1->Z1_DESC3A") == "C"
		If SZ1->Z1_COD <= "03" .And. !Empty(SZ1->Z1_DESC3A)
			_cTensao := SZ1->Z1_DESC3A
		EndIf
	EndIf
	//@ 0,0 PSAY "^FO016,244^A0N,35,30^FD" + AllTrim(SZ1->Z1_DESC3) + "^FS"
	@ 0,0 PSAY "^FO016,244^A0N,35,30^FD" + AllTrim(_cTensao) + "^FS"
	@ 0,0 PSAY "^FO216,220^A0N,15,17^FDCOMPOSICAO PRODUTO^FS"
	@ 0,0 PSAY "^FO216,244^A0N,35,30^FD COBRE/PVC ^FS"
	@ 0,0 PSAY "^FO578,220^A0N,15,17^FDNORMA TECNICA^FS"
	@ 0,0 PSAY "^FO578,244^A0N,35,30^FD" + AllTrim(SB1->B1_NORMA) + "^FS"
	@ 0,0 PSAY "^FX ===== NOVOS CAMPOS ETIQ PRODUCAO ======================== ^FS"
	@ 0,0 PSAY "^FO016,292^A0N,15,17^FDN. LOTE^FS"
	@ 0,0 PSAY "^FO036,316^A0N,35,30^FD" + AllTrim(SZU->ZU_LOTE) + "^FS
	@ 0,0 PSAY "^FO216,292^A0N,15,17^FDDATA FABRICACAO.^FS"             
	_cDataB := DtoS(SZU->ZU_DTFABR)
	_cDataB := Right(_cDataB,2) + "/" + Substr(_cDataB,5,2) + "/" + Left(_cDataB,4)
	@ 0,0 PSAY "^FO236,316,^A0N,35,30^FD"+_cDataB+"^FS"
	@ 0,0 PSAY "^FO416,292^A0N,15,17^FDDATA MOVIMENTO^FS"
	_cDataB := DtoS(SZU->ZU_DTINC)
	_cDataB := Right(_cDataB,2) + "/" + Substr(_cDataB,5,2) + "/" + Left(_cDataB,4)
	@ 0,0 PSAY "^FO436,316^A0N,35,30^FD"+_cDataB+"^FS"
	@ 0,0 PSAY "^FO616,292^A0N,15,17^FDNRO. CONTROLE.^FS"
	@ 0,0 PSAY "^FO636,316^A0N,35,30^FD"+SZU->ZU_CONTROL+"^FS"
	@ 0,0 PSAY "^FO016,364^A0N,15,22^FDLANCE 1^FS
	@ 0,0 PSAY "^FO052,380^A0N,45,50^FD"+Transform(SZU->ZU_LANCE1,"@Z 999999")+"m^FS"
	@ 0,0 PSAY "^FO237,364^A0N,15,22^FDLANCE 2^FS
	If SZU->ZU_LANCE2 > 0
		@ 0,0 PSAY "^FO273,380^A0N,45,50^FD"+Transform(SZU->ZU_LANCE2,"@Z 999999")+"m^FS"
	EndIf
	@ 0,0 PSAY "^FO458,364^A0N,15,22^FDLANCE 3^FS
	If SZU->ZU_LANCE3 > 0
		@ 0,0 PSAY "^FO494,380^A0N,45,50^FD"+Transform(SZU->ZU_LANCE3,"@Z 999999")+"m^FS"
	EndIf
	@ 0,0 PSAY "^FO016,428^A0N,15,22^FDLANCE 4^FS
	If SZU->ZU_LANCE4 > 0
		@ 0,0 PSAY "^FO052,444^A0N,45,50^FD"+Transform(SZU->ZU_LANCE4,"@Z 999999")+"m^FS"
	EndIf
	@ 0,0 PSAY "^FO237,428^A0N,15,22^FDLANCE 5^FS
	If SZU->ZU_LANCE5 > 0
		@ 0,0 PSAY "^FO273,444^A0N,45,50^FD"+Transform(SZU->ZU_LANCE5,"@Z 999999")+"m^FS"
	EndIf
	@ 0,0 PSAY "^FO458,428^A0N,15,22^FDLANCE 6^FS
	If SZU->ZU_LANCE6 > 0
		@ 0,0 PSAY "^FO494,444^A0N,45,50^FD"+Transform(SZU->ZU_LANCE6,"@Z 999999")+"m^FS"
	EndIf
	@ 0,0 PSAY "^FO016,492^A0N,15,22^FDOBSERVACAO^FS

	// 1ra. linha da observação -> @ 0,0 PSAY "^FO032,512^A0N,35,30^FDXXXXXXXXX0XXXXXXXXX0XXXXXXXXX0XXXXXXX^FS
	@ 0,0 PSAY "^FO032,544^A0N,35,30^FD"+Left(SZU->ZU_OBS,35)+"^FS
	// 3ra. linha da observação -> @ 0,0 PSAY "^FO032,576^A0N,35,30^FDXXXXXXXXX0XXXXXXXXX0XXXXXXXXX0XXXXXXX^FS

	@ 0,0 PSAY "^FX ====== CODIGO DE BARRAS ================================ ^FS"
	@ 0,0 PSAY "^FO702,376^BY2,,60^BUB,80,Y,N,N^FD"+"95"+ StrZero(Val(SZU->ZU_CONTROL),09) + "^FS"
	@ 0,0 PSAY "^FO680,400^A0B,20,25^FD" + AllTrim(SZU->ZU_PRODUTO) + "^FS"
	@ 0,0 PSAY "^FX ======================================================== ^FS"
	@ 0,0 PSAY "^FX =                   Fim da Etiqueta                    = ^FS"
	@ 0,0 PSAY "^FX =   O comando PQ2 indica duas carreiras de etiquetas   = ^FS"
	@ 0,0 PSAY "^FX ======================================================== ^FS"
	@ 0,0 PSAY "^PQ"+"1"+"^FS"
	@ 0,0 PSAY "^MTT^FS"
	@ 0,0 PSAY "^MPE^FS"
	@ 0,0 PSAY "^JUS^FS"
	@ 0,0 PSAY "^XZ"
	SET DEVICE TO SCREEN
	If aReturn[5]==1
		DbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	EndIf
	MS_FLUSH()
	Return(.T.)
	*
	***********************
User Function Movin95()
	***********************
	*
	// Faz os Movimentos da tabela SZU nos almoxarifados 99 para o 95 e vice-versa.
	If SM0->M0_CODIGO # "01"
		Return(.T.)
	EndIf
	DbSelectArea("SZU")
	DbSetOrder(4) // ZU_FILIAL+ZU_STATUS+ZU_PRODUTO
	For _nZu := 1 to 2
		If _nZu == 1
			_cStatus := "1"	// Fazer Entradas
		Else
			_cStatus := "2"	// Fazer Saídas
		EndIf
		Do While SZU->(DbSeek(xFilial("SZU") + _cStatus,.F.))
			If RecLock("SZU",.F.)
				If SZU->ZU_STATUS == "1"
					Transfere("E") // _cMovic = E_nvio ou R_etorno
				Else
					Transfere("R") // _cMovic = E_nvio ou R_etorno
				EndIf           
				SZU->ZU_STATUS := If(SZU->ZU_STATUS=="1","3","4")
				MsUnLock()
			EndIf
		EndDo
	Next
	Return(.T.)
	*
	*************************
User Function FiltraESA()
	*************************
	*                            

	DbSelectArea("SZU")
	If _lFiltro // Limpar Filtro
		DbClearFilter()
		Alert("Filtro Desativado")
	Else // Filtrar
		Set Filter to ZU_STATUS$'13'
		Alert("Filtro Ativado")
	EndIf      
	DbSeek(xFilial("SZU"),.F.)
	_lFiltro := !_lFiltro
Return(.T.)