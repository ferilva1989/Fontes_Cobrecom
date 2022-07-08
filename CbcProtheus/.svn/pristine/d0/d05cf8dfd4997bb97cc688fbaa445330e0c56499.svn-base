#include "rwmake.ch"
#include 'protheus.ch'
#include 'topconn.ch'

/*/{Protheus.doc} PPI_OP
//TODO Realiza a Exportação de Informações para o banco de Integração do PCFactory.
@author juliana.leme
@since 26/04/2016
@version 1.0

@type function
/*/
User Function PPI_OP()
	Private nHndErp 		:= AdvConnection()
	//Private cDB_PPI 		:= "MSSQL/PCF_Integ"//Tipo e nome do banco de integração (PC-Factory) (TESTE)
	//Private cSrvPPI 		:= "192.168.1.220"	//Servidor onde está o banco de integração (TESTE)
	Private nPrtPPI 		:= GetNewPar("ZZ_PORTADB", "7890")				// Porta
	Private nHndPPI								//Handler do banco de dados de integração
	Private aParamBox  		:= {}
	Private nQtdBom 		:= 0
	Private nQtdRui 		:= 0
	Private aRet  			:= {}
	Private _aDadProds 		:= {} 				// terá todas as informações do produto.
	Private _aPrIncNow 		:= {} 				//	3 - Para evitar dar diversos selects no banco, tratar o array  {Código do produto}
	Private _aPrIncBef 		:= {} 				//	Esta variável somente será incrementada se nã der erro na integração
	Private _nNumCarga 		:= 0

	_lSai := .F.
	Do While .T.
		aParamBox := {}
		aRet      := {}
		aAdd(aParamBox,{3,"Exportar Por             ",1,{"Nro.da Programação","Nro.das O.P.s"},060,"",.F.})
		aAdd(aParamBox,{3,"Tipo das Ordens          ",1,{"Programadas","Planejadas"},060,"",.F.})
		aAdd(aParamBox,{1,"Da O.P. / Programação.   ",Space(06),"","","","",035,.F.})
		aAdd(aParamBox,{1,"Até a O.P. / Programação.",Space(06),"","","","",035,.F.})
		aAdd(aParamBox,{3,"Integra Tabela de Estruturas (SG1) ",1,{"Sim","Não"},035,"",.F.})
		aAdd(aParamBox,{3,"Integra Produtos de ESTOQUE (MP/PI/PA/OI/ME) ",1,{"Sim","Não"},035,"",.F.})

		If !ParamBox(aParamBox, "Processamento", @aRet)
			_lSai := .T.
			Exit
		EndIf
		If aRet[2] == 2 // Previstas
			Exit
		ElseIf aRet[3] > aRet[4] .Or. Empty(aRet[3]) // Não pode ser de Vazio.. tem que ser programação feita
			Alert("Informar Corretamente os Parâmetros De/Até Programação")
		Else
			Exit
		EndIf
	EndDo
	If _lSai
		Return(.F.)
	EndIf
	
	Private cDB_PPI 	:= GetNewPar('ZZ_HNDPPI', "MSSQL/PCF_Integ")//Tipo e nome do banco de integração (PC-Factory) (OFICIAL)
	Private cSrvPPI 	:= GetNewPar('ZZ_SRVPPI', "192.168.3.2") 	//Servidor onde está o banco de integração (OFICIAL)

	// Cria uma conexão com um outro banco, outro DBAcces
	nHndPPI := TcLink(cDb_PPI,cSrvPPI,nPrtPPI)

	// Seleciono a conexão de origem
	TcSetConn(nHndErp)

	If nHndPPI < 0
		Alert("Falha ao conectar com " + cDB_PPI + " em " + cSrvPPI + ":" + Str(nPrtPPI,4))
		Return(.T.)
	Endif

	DbSelectArea("SA1")
	DbSetOrder(1) 

	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

	DbSelectArea("SB1")
	DbSetOrder(1) // B1_FILIAL+B1_COD

	DbSelectArea("SC5")
	DbSetOrder(1) 

	DbSelectArea("SG1")
	DbSetOrder(2) // G1_FILIAL+G1_COMP+G1_COD

	DbSelectArea("SZ9")
	DbSetOrder(5) // Z9_FILIAL+Z9_PROGR+Z9_PRODUTO+Z9_NUM+Z9_ITEM+Z9_LOCALIZ

	DbSelectArea("SD4")
	DbSetOrder(2) // D4_FILIAL+D4_OP+D4_COD+D4_LOCAL

	DbSelectArea("SC2")
	DbSetOrder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

	//cQuery := "SELECT * "
	cQuery := " FROM " + RetSqlName("SC2")
	cQuery += " WHERE "
	cQuery += "C2_FILIAL = '" + xFilial("SC2") + "' AND D_E_L_E_T_ <> '*' AND "
	cQuery += "(C2_STATINT = 'A' OR C2_STATINT = ' ') AND "

	If aRet[1] == 2 // Exportar pelo Nro das OPs
		cQuery += "C2_NUM >= '" + aRet[3] + "' AND "
		cQuery += "C2_NUM <= '" + aRet[4] + "' AND "
	Else
		cQuery += "C2_PROGR >= '" + aRet[3] + "' AND "
		cQuery += "C2_PROGR <= '" + aRet[4] + "' AND "
	EndIf

	If aRet[2] == 2 // Planejadas
		cQuery += "C2_STATOP  = 'P'"
	Else // Programadas
		cQuery += "C2_STATOP  = 'L'"
	EndIf

	// Primeiro quero saber quantos registros tem

	cQuery1 := "SELECT Count(*) as QTDREG " + cQuery

	cQuery1 := ChangeQuery(cQuery1)

	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery1 NEW ALIAS "TRB"

	_nQtdReg := TRB->QTDREG

	DbSelectArea("TRB")
	DbCloseArea()

	If _nQtdReg > 0

		cQuery1 := "SELECT * " + cQuery
		cQuery1 := ChangeQuery(cQuery1)

		TCQUERY cQuery1 NEW ALIAS "TRB"

		Processa({|| IntegrPPI()},"Ordens de Produção")

		DbSelectArea("TRB")
		DbCloseArea()
	EndIf

	If aRet[5] == 1 // Exportar SG1
		Processa({|| IntegrSG1()},"Estruturas")
	EndIf    

	If aRet[6] == 1 // Exportar SB1 ME (Material de Embalagem)
		Processa({|| IntegrSB1ME()},"Produtos de Embalagem")
	EndIf    

	// Fecha a conexão com o banco PPI
	TcUnlink(nHndPPI)

	// Volta para conexão ERP
	tcSetConn(nHndErp)

	//Avisar se deu erro ou está tudo ok AQUI
	Alert("Exportação Realizada!!")
Return(.T.) 


/*/{Protheus.doc} IntegrSG1
//TODO Realiza a Integração dos produtos e sua estrutura para o banco de integração.
@author roberto
@since 26/04/2016
@version 1.0

@type function
/*/
Static Function IntegrSG1()

	Private _aDadProds := {} // terá todas as informações do produto.

	TcSetConn(nHndErp) // Seleciona o Banco Protheus
	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

	DbSelectArea("SB1")
	DbSetOrder(1)

	_G1Comp := "      "       
	DbSelectArea("SG1")
	DbSetOrder(2) //G1_FILIAL+G1_COMP+G1_COD        
	ProcRegua(RecCount())
	DbSeek(xFilial("SG1"),.F.)
	Do While SG1->G1_FILIAL == xFilial("SG1") .And. SG1->(!Eof())
		IncProc()
		If left(SG1->G1_COD,10) == '1190902401'
			nVal := 0 //Parei
		EndIf
		If SG1->G1_COMP # _G1Comp
			_G1Comp := SG1->G1_COMP
			SB1->(DbSeek(xFilial("SB1")+SG1->G1_COMP,.F.))

			_nQtSaldo := 0
			If SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD,.F.))
				_nQtSaldo += Max(0,SB2->B2_QATU)
			EndIf
			If SB1->B1_LOCPAD # "99"
				If SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"99",.F.))
					_nQtSaldo += Max(0,SB2->B2_QATU)
				EndIf
			EndIf                         

			_cTipo3 := "MT"
			_nConv3 := If(Upper(SB1->B1_UM)#"MT",SB1->B1_X_FATOR,1)

			aadd(_aDadProds,{;
			SB1->B1_TIPO,;
			Padr(SB1->B1_COD,20),;
			SB1->B1_DESC,;
			Upper(SB1->B1_UM),;
			_cTipo3,;
			_nConv3,;
			If(SB1->B1_LOCPAD=="99","01WIP","01EST"),;
			_nQtSaldo,;
			If("VERGALH"$Upper(SB1->B1_DESC),"VE",SB1->B1_TIPO),;
			If(SB1->B1_UM=="MT","KG","MT"),;
			SB1->B1_PESBRU})

			// Atenção: Caso mude o tamanho que qualquer campo, verificar a comparação 
			// para o comando INSERT da TBLInProduct.
		EndIf
		SG1->(DbSkip())
	EndDo
	If Len(_aDadProds) > 0
		// Seleciono a conexão do PPI
		TcSetConn(nHndPPI)
		InsProds(.T.)
		// Retorna para o banco Protheus
		TcSetConn(nHndErp)
	EndIf
	Return(.T.)


/*/{Protheus.doc} IntegrPPI
//TODO Função principal de Integrações com o PPI.
@author Roberto
@since 24/07/2017
@version 1.0

@type function
/*/
Static Function IntegrPPI()
	ProcRegua(_nQtdReg)
	DbSelectArea("TRB")
	DbGotop()
	Do While TRB->(!Eof())
		IncProc()
		DbSelectArea("SC2")
		If !DbSeek(xFilial("SC2")+TRB->C2_NUM+TRB->C2_ITEM+TRB->C2_SEQUEN+TRB->C2_ITEMGRD,.F.)
			DbSelectArea("TRB")
			DbSkip()
			Loop
		EndIf
		If !SC2->C2_STATINT $ 'A '
			DbSelectArea("TRB")
			DbSkip()
			Loop
		ElseIf SC2->C2_STATOP == 'C' // OP Cancelada para o PPI
			RecLock("SC2",.F.)
			SC2->C2_STATINT := "N" // Não integrar... OP Cancelada
			MsUnLock()
			DbSelectArea("TRB")
			DbSkip()
			Loop
		ElseIf (SC2->C2_QUANT-SC2->C2_QUJE) <= 0
			RecLock("SC2",.F.)
			SC2->C2_STATINT := "N" // Não integrar... quantidade zerada
			MsUnLock()
			DbSelectArea("TRB")
			DbSkip()
			Loop             
		ElseIf TRB->C2_NUM+TRB->C2_ITEM+TRB->C2_SEQUEN+TRB->C2_ITEMGRD	# ;
		Upper(TRB->C2_NUM+TRB->C2_ITEM+TRB->C2_SEQUEN+TRB->C2_ITEMGRD)
			RecLock("SC2",.F.)
			SC2->C2_STATINT := "N" // Não integrar... OPS com caracteres minúsculos
			MsUnLock()
			DbSelectArea("TRB")
			DbSkip()
			Loop             
		EndIf

		BeginTran()
		RecLock("SC2",.F.)
		SC2->C2_STATINT := "E"	

		/*/
		AQUI
		SC2->C2_OBS := If(_nArray==1,"Rolos 100 metros",If(_nArray==2,"Bobinas Diversas","Demais Acondics."))
		// Atenção: Estas expressões não podem ser alteradas pois estas são interpretadas na
		// User Function PPI_OP()
		/*/

		MsUnLock()

		_aDadProds := {} // terá todas as informações do produto.
		_aPrIncNow := {} //	3 - Para evitar dar diversos selects no banco, tratar o array  {Código do produto}

		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+SC2->C2_PRODUTO,.F.)

		_nPsCod := aScan(_aDadProds,{|x|x[2]==SB1->B1_COD})
		If _nPsCod == 0    

			_nQtSaldo := 0
			If SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD,.F.))
				_nQtSaldo += Max(0,SB2->B2_QATU)
			EndIf
			If SB1->B1_LOCPAD # "99"
				If SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"99",.F.))
					_nQtSaldo += Max(0,SB2->B2_QATU)
				EndIf
			EndIf            

			_cTipo3 := "MT"
			_nConv3 := If(Upper(SB1->B1_UM)#"MT",SB1->B1_X_FATOR,1)

			aadd(_aDadProds,{;
			SB1->B1_TIPO,;
			Padr(SB1->B1_COD,20),;
			SB1->B1_DESC,;
			Upper(SB1->B1_UM),;
			_cTipo3,;
			_nConv3,;
			If(SB1->B1_LOCPAD=="99","01WIP","01EST"),;
			_nQtSaldo,;
			If("VERGALH"$Upper(SB1->B1_DESC),"VE",SB1->B1_TIPO),;
			If(SB1->B1_UM=="MT","KG","MT"),;
			SB1->B1_PESBRU})

			// Atenção: Caso mude o tamanho que qualquer campo, verificar a comparação
			// para o comando INSERT da TBLInProduct.
			_nPsCod := Len(_aDadProds)
		EndIf

		If SB1->B1_TIPO == "PA" // Olhar a tabela ZZM
			// Conforme a OP é criada na UF CdEst03() - Montagem do Resumo, são gravadas as seguintes 
			// expressões em C2_OBS:
			// "Rolos 100 metros"
			// "Bobinas Diversas"
			// "Carreteis"
			// "Demais Acondics."
			// Essas expressões devem ser interpretadas para localização no ZZM o Grupo de Recursos correto.
			DbSelectArea("ZZM")
			DbSetOrder(1) // ZZM_FILIAL+ZZM_NOME+ZZM_BITOLA+ZZM_ACOND+ZZM_LANCE
			_cGpoMaq := ""
			If SC2->C2_OBS <> '' 
				If Substr(SC2->C2_OBS,1,1)=="R"
					Dbseek(xFilial("ZZM")+SB1->B1_NOME+SB1->B1_BITOLA+"R00100",.F.)
					_cGpoMaq := ZZM->ZZM_GPOREC
				ElseIf Substr(SC2->C2_OBS,1,1)=="B" 
					Dbseek(xFilial("ZZM")+SB1->B1_NOME+SB1->B1_BITOLA+"B00000",.F.)
					_cGpoMaq := ZZM->ZZM_GPOREC
				ElseIf Substr(SC2->C2_OBS,1,1)$"CM"
					If !(Dbseek(xFilial("ZZM")+SB1->B1_NOME+SB1->B1_BITOLA+"M00000",.F.))
						Dbseek(xFilial("ZZM")+SB1->B1_NOME+SB1->B1_BITOLA+"C00000",.F.)   
					EndIf
					_cGpoMaq := ZZM->ZZM_GPOREC
				ElseIf Substr(SC2->C2_OBS,1,1)=="D" 
					Dbseek(xFilial("ZZM")+SB1->B1_NOME+SB1->B1_BITOLA+"R00000",.F.)
					_cGpoMaq := ZZM->ZZM_GPOREC
				Else
					_cGpoMaq := "ERRO"+xFilial("SC2")
				EndIf                            	   		
			EndIf
			If Empty(_cGpoMaq)
				_cGpoMaq := "ERRO"+xFilial("SC2")
			EndIf   

			_cGpoMtzs := Left(ZZM->ZZM_MTZALI,6) //+Left(SB1->B1_MTZCOR,15)+Left(SB1->B1_MTZDIAM,6)+Left(SB1->B1_MTZGRAV,12)+Left(SB1->B1_MTZMATP,15)
			// Esta informação vai para a coluna WODetTechDoc da tabela TBLinWOComplete, que
			// está configurada para receber as informações das matrizes de Alimentação, Cor,
			// Diâmetro, Gravação e MP como varchar (concatenado) sendo os tamanhos 6, 15, 6,
			// 12 e 15 posições, respectivamente.
		Else
			_cGpoMaq := SB1->B1_GPOREC
			_cGpoMtzs := Left(SB1->B1_MTZALIM,6)+Left(SB1->B1_MTZCOR,15)+Left(SB1->B1_MTZDIAM,6)+Left(SB1->B1_MTZGRAV,12)+Left(SB1->B1_MTZMATP,15)
			// Esta informação vai para a coluna WODetTechDoc da tabela TBLinWOComplete, que
			// está configurada para receber as informações das matrizes de Alimentação, Cor,
			// Diâmetro, Gravação e MP como varchar (concatenado) sendo os tamanhos 6, 15, 6,
			// 12 e 15 posições, respectivamente.
		EndIf

		DbSelectArea("SX5")
		If DbSeek(xFilial("SX5")+"ZU"+_cGpoMaq,.F.)
			_cGpoMaq := AllTrim(SX5->X5_DESCRI)
			_cAtivid := AllTrim(SX5->X5_DESCSPA)
		Else
			_cGpoMaq := "ERRO"+xFilial("SC2")
			_cAtivid := "ERRO"+xFilial("SC2")
		EndIf
		// Esta informação vai para a coluna ManagerGrpCode da tabela TBLinWOComplete, que
		// está configurada como varchar(15)

		_aLances := {} // {Z9_PEDIDO, Z9_ITEMPV, Z9_LOCALIZ,Z9_LANCES,Z9_QUANT,Z9_PRODUTO,Z9_DESCRI,Nome do Cliente,Dt.Entrega do Pedido}
		// Falar antes com Juliana para tratar as OPs de PA's _aLanAcd := {} // {Z9_LOCALIZ,Z9_QUANT}

		DbSelectArea("SZ9")
		DbSetOrder(2) // Z9_FILIAL+Z9_NUM+Z9_ITEM+Z9_SEQUEN+Z9_PRODUTO+Z9_LOCALIZ
		DbSeek(xFilial("SZ9")+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+SC2->C2_PRODUTO,.F.)
		Do While SZ9->Z9_FILIAL == xFilial("SZ9")  .And. SZ9->(!Eof()) .And. ;
		SZ9->(Z9_NUM+Z9_ITEM+Z9_SEQUEN+Z9_PRODUTO) == SC2->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_PRODUTO)

			If !Empty(SZ9->Z9_PEDIDO)
				_nPsLanc := aScan(_aLances,{|x|x[1]==SZ9->Z9_PEDIDO.And.x[2]==SZ9->Z9_ITEMPV}) //.And.x[3]==SZ9->Z9_LOCALIZ})			
				If _nPsLanc == 0
					_cNomeCli := " "   
					_cDtEntr := "        "
					DbSelectArea("SC5")
					If DbSeek(xFilial("SC5")+SZ9->Z9_PEDIDO,.F.)
						_cDtEntr := Dtos(SC5->C5_ENTREG)
						//_cDtEntr := "20141231"
						If !SC5->C5_TIPO $ "DB" // Devolução de compras ou Envio para beneficiamento
							DbSelectArea("SA1")
							If DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.)
								_cNomeCli := SA1->A1_NOME
							EndIf
						EndIf
						Aadd(_aLances,{SZ9->Z9_PEDIDO,SZ9->Z9_ITEMPV,SZ9->Z9_LOCALIZ,SZ9->Z9_LANCES,SZ9->Z9_QUANT,;
						SZ9->Z9_PRODUTO,SZ9->Z9_DESCRI,_cNomeCli,_cDtEntr})
					EndIf
				Else
					_aLances[_nPsLanc,4] += SZ9->Z9_LANCES
					_aLances[_nPsLanc,5] += SZ9->Z9_QUANT
				EndIf
			EndIf                              
			SZ9->(DbSkip())
		EndDo

		_aGpoOpc  := {}
		_aGpoOpc1 := {}  // Grupos+Itens Opcionais deste nível
		DbSelectArea("SG1")      
		DbSetOrder(1) // G1_FILIAL+G1_COD+G1_COMP+G1_TRT
		DbSeek(xFilial("SG1")+SC2->C2_PRODUTO,.F.)
		Do While SG1->G1_FILIAL == xFilial("SG1") .And. SG1->G1_COD == SC2->C2_PRODUTO .And. SG1->(!Eof())
			If !Empty(SG1->G1_GROPC)
				If aScan(_aGpoOpc1,{|x|x[1]==SG1->G1_GROPC .And. x[2]==SG1->G1_OPC}) == 0
					_cOpc := Posicione("SGA",1,xFilial("SGA")+(SG1->G1_GROPC+SG1->G1_OPC),"GA_PADRAO")
					Aadd(_aGpoOpc1,{SG1->G1_GROPC,SG1->G1_OPC,If(_cOpc=="S","01","99")})
				EndIf
			EndIf
			SG1->(DbSkip())
		EndDo	

		If Len(_aGpoOpc1) > 0 // Tenho opcionais nesse nível
			aSort(_aGpoOpc1,,,{ |x, y| x[1]+x[3] < y[1]+y[3] })
			_cBse := ""
			For _nOpc := 1 to Len(_aGpoOpc1)
				If _aGpoOpc1[_nOpc,1] # _cBse
					_cBse := _aGpoOpc1[_nOpc,1]
					_nUltSq := 1
				EndIf
				_aGpoOpc1[_nOpc,3] := StrZero(_nUltSq++,2)
			Next

			DbSelectArea("SG1")      
			DbSetOrder(1) // G1_FILIAL+G1_COD+G1_COMP+G1_TRT
			DbSeek(xFilial("SG1")+SC2->C2_PRODUTO,.F.)
			Do While SG1->G1_FILIAL == xFilial("SG1") .And. SG1->G1_COD == SC2->C2_PRODUTO .And. SG1->(!Eof())
				If Empty(SG1->G1_GROPC)
					For _nOpc := 1 to Len(_aGpoOpc1)
						Aadd(_aGpoOpc,{;
						SG1->G1_COMP,		SG1->G1_TRT,			_aGpoOpc1[_nOpc,1],	_aGpoOpc1[_nOpc,2],;
						_aGpoOpc1[_nOpc,3],	SG1->G1_QUANT,			" ",				0,;
						SG1->G1_ZZCARGA })
						//  1-Código,			2-Sequencia,			3-Gpo.Opc.,			4-Item OPC        ,
						//  5-Ordem Opcional, 		6-Fator                 7-					8-
						//  9-NumCarga
					Next
				Else
					// _aGpoOpc1 -> {SG1->G1_GROPC,SG1->G1_OPC,If(_cOpc=="S","01","99")}
					_nPsOpc := aScan(_aGpoOpc1,{|x|x[1]==SG1->G1_GROPC .And. x[2]==SG1->G1_OPC})
					Aadd(_aGpoOpc,{;
					SG1->G1_COMP,			SG1->G1_TRT,			SG1->G1_GROPC,		SG1->G1_OPC,;
					_aGpoOpc1[_nPsOpc,3],	SG1->G1_QUANT,			" ",				0,;
					SG1->G1_ZZCARGA })
					//  1-Código,				2-Sequencia,			3-Gpo.Opc.,			4-Item OPC        ,
					//  5-Ordem Opcional, 		6-Fator                 7-					8-
					//  9-NumCarga
				EndIf
				SG1->(DbSkip())
			EndDo
			// Ordena por
			aSort(_aGpoOpc,,,{ |x, y| x[1]+x[2]+x[3]+x[4] < y[1]+y[2]+y[3]+y[4] })
		EndIf

		// Como todas as informações do SC2 tenho no TRB, agora só
		// preciso acumular as informações do SD4 em um array.

		DbSelectArea("SG1")
		DbSetOrder(1) // G1_FILIAL+G1_COD
		DbSeek(xFilial("SG1")+SC2->C2_PRODUTO,.F.)
		_aEmpen := {}

		Do While SG1->G1_FILIAL == xFilial("SG1") .And. ;
		SG1->G1_COD == SC2->C2_PRODUTO .And. G1_FIM > dDataBase .And. SG1->(!Eof())

			// Aglutinar as quantidades de D4 iguais;
			// Retornar ao último D4 para poder 
			_D4_COD     := SG1->G1_COMP
			_D4_OP      := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)
			_D4_QTDEORI := IIf(SG1->G1_FIXVAR == "V",SC2->C2_QUANT * SG1->G1_QUANT,SG1->G1_QUANT)

			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+_D4_COD,.F.)

			_nPsCod := aScan(_aDadProds,{|x|x[2]==SB1->B1_COD})
			If _nPsCod == 0
				_nQtSaldo := 0
				If SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD,.F.))
					_nQtSaldo += Max(0,SB2->B2_QATU)
				EndIf
				If SB1->B1_LOCPAD # "99"
					If SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"99",.F.))
						_nQtSaldo += Max(0,SB2->B2_QATU)
					EndIf
				EndIf

				_cTipo3 := "MT"
				_nConv3 := If(Upper(SB1->B1_UM)#"MT",SB1->B1_X_FATOR,1)

				aadd(_aDadProds,{;
				SB1->B1_TIPO,;
				Padr(SB1->B1_COD,20),;
				SB1->B1_DESC,;
				Upper(SB1->B1_UM),;
				_cTipo3,;
				_nConv3,;
				If(SB1->B1_LOCPAD=="99","01WIP","01EST"),;
				_nQtSaldo,;
				If("VERGALH"$Upper(SB1->B1_DESC),"VE",SB1->B1_TIPO),;
				If(SB1->B1_UM=="MT","KG","MT"),;
				SB1->B1_PESBRU})

				// Atenção: Caso mude o tamanho que qualquer campo, verificar a comparação 
				// para o comando INSERT da TBLInProduct.
			EndIf

			// Verifica quantos ítens tem no array
			_cOpcNow := ""
			_cDscOpc := ""
			_nQtdOpc := 1
			For _nPsGpo := 1 To Len(_aGpoOpc)
				If _aGpoOpc[_nPsGpo,1] == _D4_COD
					_nQtdOpc++
					_aGpoOpc[_nPsGpo,7] := "S" // Grupo de opcionais já incluido no _aEmpen
					_cOpcNow := _aGpoOpc[_nPsGpo,3]+"/"+_aGpoOpc[_nPsGpo,4] //3-Gpo.Opc. //4-Item OPC 
					_cDscOpc := Posicione("SGA",1,xFilial("SGA")+(_aGpoOpc[_nPsGpo,3]+_aGpoOpc[_nPsGpo,4]),"GA_DESCOPC")
				EndIf
			Next

			If Len(_aGpoOpc) == 0 .Or. _nQtdOpc == 1 // Não tem opcionais ou Só tem um cara

				_cQuant := AllTrim(Str(_D4_QTDEORI,24,4))

				//Não importa o saldo do empenho... o consumo sempre será pelo fator -> _cCoef
				// Em reunião dia 27/11/14 (Pedro, Danilo, Jeferson, Roberto e Juliana), Pedro solicitou
				// multiplicar o coeficiente por 100.000 para dar um número que ele possa tratar no PC-FACTORY

				_cCoef := AllTrim(Str(((_D4_QTDEORI/SC2->C2_QUANT)*100000),29,9))

				_nPsCod1 	:= 1
				_nPsCod1 	:= aScan(_aGpoOpc,{|x|x[1]==_D4_COD})

				If _nPsCod1 <> 0
					_nNumCarga 	:= Max(_aGpoOpc[_nPsCod1,9],1)
				Else                                                 
					_cCodPai 	:= SC2->C2_PRODUTO
					_nNumCarga 	:= SG1->G1_ZZCARGA
				EndIf
				_D4_OP      := IIf(Empty(Alltrim(_D4_OP)), SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),_D4_OP)

				Aadd(_aEmpen,Array(12)) // 12 elementos na tabela
				_nPosEmp := Len(_aEmpen)
				_aEmpen[_nPosEmp,01] := _D4_OP// Nro da OP
				_aEmpen[_nPosEmp,02] := "10"				// Código da Operação-> Conf.Pedro é igual ao campo WODetCode da tabela TBLinWOComplete
				_aEmpen[_nPosEmp,03] := _D4_COD				// Código do produto
				_aEmpen[_nPosEmp,04] := _cQuant				// Quantidade necessária
				_aEmpen[_nPosEmp,05] := "-10"				// Rendimento do material - fixar -10
				_aEmpen[_nPosEmp,06] := "1"					// Quant.prevista a ser consumida - fixar 1
				_aEmpen[_nPosEmp,07] := _cCoef				// Coeficiente relac.a quant.da WO
				_aEmpen[_nPosEmp,08] := "1"					// Determina se o item deve ser baixado fixar 0
				_aEmpen[_nPosEmp,09] := SB1->B1_TIPO		// Tipo do Produto
				_aEmpen[_nPosEmp,10] := _cOpcNow			// Grupo de Opcionais
				_aEmpen[_nPosEmp,11] := _cDscOpc			// Descrição do Grupo de Opcionais
				_aEmpen[_nPosEmp,12] := _nNumCarga			// Numero de Cargas
			Else // Tenho Opcionais

				// Posiciona o B1 do SD4
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+_D4_COD,.F.)
				_nQtdOpc := 1
				For _nPsGpo := 1 To Len(_aGpoOpc)
					If _aGpoOpc[_nPsGpo,1] == _D4_COD
						GrvEmpen()
					EndIf
				Next
			EndIf
			SG1->(DbSkip())
		EndDo

		// Verificar se algum opcional não foi para _aEmpen

		_D4_COD  := " "
		_nQtdOpc := 1
		For _nPsGpo := 1 To Len(_aGpoOpc)
			If Empty(_aGpoOpc[_nPsGpo,7])
				If _aGpoOpc[_nPsGpo,1] # _D4_COD
					_nQtdOpc := 1
				EndIf

				_nQtdOpc++  // Enviar > 1 para o Preactor não considerar.
				_D4_COD  := _aGpoOpc[_nPsGpo,1]
				// Posiciona o B1 do SD4
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+_D4_COD,.F.)			
				GrvEmpen()
			EndIf
		Next

		// Variável para controlar se ocorreu erro ao gravar os dados
		_lErroInt := .F.
		// Já tenho os dados da OP e dos empenhos
		// Dar os Inserts nas tabelas OP - TBLinWOComplete e LDM - TBLinBillMat

		// Seleciono a conexão do PPI
		TcSetConn(nHndPPI)

		// Inicio uma transação no Banco de Integração
		BeginTran()

		// Gravo os dados dos produtos envolvidos nesta OP
		_lErroInt := InsProds(.F.)
		// Esta função irá atualizar a variável _aPrdsIncs conforme a _aDadProds := {}
		// e também retornará .T. ou .F. para _lErroInt se deu erro ou não.
		If _lErroInt
			// Desarma a transação do Banco de Integração
			DisarmTransaction()
			// Retorna para o banco Protheus
			TcSetConn(nHndErp)
			// Desarma a transação do Banco Protheus
			DisarmTransaction()
			MsUnlockAll()

			DbSelectArea("SC2")
			RecLock("SC2",.F.)
			SC2->C2_STATINT := "X" // Erro na Integração
			MsUnLock()

			DbSelectArea("TRB")
			DbSkip()
			Loop
		EndIf

		// Gravo os dados dos empenhos
		For _nElePPI := 1 to Len(_aEmpen)

			cQuery := "INSERT TBLinBillMat " + ;
			"( WOCode,   WODetCode, ProductCode,  TotalQty, MatYield, " + ;
			"  BatchQty, MatFactor, FlgBackFlush, ExtCode,  Comments, Proportion ) " + ;
			"VALUES ( " + ;
			"'" + xFilial("SC2")+AllTrim(_aEmpen[_nElePPI,01]) + "', " + ;
			"'" + AllTrim(_aEmpen[_nElePPI,02]) + "', " + ;
			"'" + AllTrim(_aEmpen[_nElePPI,03]) + "', " + ;
			AllTrim(_aEmpen[_nElePPI,04]) + ", " + ;
			AllTrim(_aEmpen[_nElePPI,05]) + ", " + ;
			AllTrim(_aEmpen[_nElePPI,06]) + ", " + ;
			AllTrim(_aEmpen[_nElePPI,07]) + ", " + ;
			AllTrim(_aEmpen[_nElePPI,08]) + ", " + ;
			"'" + AllTrim(_aEmpen[_nElePPI,09]) + "'," + ;
			"'" + If(Empty(_aEmpen[_nElePPI,10]),"001/0001 - SEM OPCIONAL",; //Alterado para tratamento dos OPCIONAIS - Juliana Leme
			AllTrim(_aEmpen[_nElePPI,10]) + " - " + AllTrim(_aEmpen[_nElePPI,11])) + "'," + ;
			Alltrim(Str(Max(_aEmpen[_nElePPI,12],1))) + " ) "

			//Executa e testa se INSERT foi executado corretamente
			If (TCSqlExec(cQuery) < 0) // Deu Erro
				_lErroInt := .T.
				cMsg := TCSQLError()// + linha
				MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
				Exit
			EndIf   		
		Next


		If _lErroInt
			// Desarma a transação do Banco de Integração
			DisarmTransaction()
			// Retorna para o banco Protheus
			TcSetConn(nHndErp)
			// Desarma a transação do Banco Protheus
			DisarmTransaction()
			MsUnlockAll()

			DbSelectArea("SC2")
			RecLock("SC2",.F.)
			SC2->C2_STATINT := "X" // Erro na Integração
			MsUnLock()

			DbSelectArea("TRB")
			DbSkip()
			Loop
		EndIf

		//_aLances - // {Z9_PEDIDO, Z9_ITEMPV, Z9_LOCALIZ,Z9_LANCES,Z9_QUANT,Z9_PRODUTO,;
		//Z9_DESCRI,Nome do Cliente,Dt.Entrega do Pedido}
		// Em reunião dia 26/11/14 Jeferson, Juliana, Roberto, Pedro e Danilo ficou acordado que o campo
		// TECHDOC terá as informações dos pedidos e dos acondicionamentos sendo:
		// PEDIDO;QUANT.;ACOND.|
		// XXXXXX;999999;X99999|XXXXXX;999999;X99999|XXXXXX;999999;X99999|XXXXXX;999999;X99999|
		_cLances := ""             
		_nQLcs := 0
		For nCtd := 1 to Len(_aLances)
			_xLances :=AllTrim(_aLances[nCtd,01]) + ";" + AllTrim(Transform(_aLances[nCtd,04],"@E 999,999")) + ";" + AllTrim(_aLances[nCtd,03]) + "|"
			If Len(_cLances + _xLances) <= 2000
				_cLances := _cLances + _xLances
				_nQLcs   += _aLances[nCtd,04]
			Else
				Exit
			EndIf
		Next
		_cLances := If(Len(_cLances)==0," ",_cLances)


		_DtEmm1 := Ctod(Right(TRB->C2_EMISSAO,2) + "/" + Substr(TRB->C2_EMISSAO,5,2) + "/" + Left(TRB->C2_EMISSAO,4))
		_DtEmm2 := Ctod(Right(TRB->C2_DATPRF ,2) + "/" + Substr(TRB->C2_DATPRF ,5,2) + "/" + Left(TRB->C2_DATPRF ,4))

		_DtEmm1 := Transform(Dtos(_DtEmm1),"@R 9999-99-99") + " 12:00:00.000"
		_DtEmm2 := Transform(Dtos(_DtEmm2),"@r 9999-99-99") + " 12:00:00.000"


		// Dar o Insert na tabela OP - TBLinWOComplete

		//    Pedro ligou as 11:45 solicitando 
		//    Enviar coluna AUXCODE2 COM O RANGE DE TOLERÂNCIA DE REPORTE  9999;9999

		cQuery := "INSERT Into TBLinWOComplete " + ;
		"( WOCode       , ProductCode    , WOSituation    , WOTypeCode    , TechDoc     , " + ;
		"DtIssue      , DtDue          , TotalQty       , Status        , WODetCode   , " + ;
		"WODetName    , SetUpTime      , SetUpTimeFormat, StdSpeedFormat, StdSpeed    , " + ;
		"WODetStatus  , ManagerGrpCode , Qty            , AuxCode1      , Unit1Code   , " + ;
		"DefaultOrigin, DefaultType    , PlanType       , ReportTrigger , DisablePrint, " + ;
		"BaseQty      , FlgQCInspection, WODetFlgEnable , WODetTechDoc  , Unit1Factor ) " + ;
		"VALUES ( "

		// quebrei os VALUES abaixo de 5 em 5 para facilitar a licalização                                           
		//Inclusão do numero da OP a filial de cada OP.
		//Trabalhando no PCFactory com Filial + OP - Juliana Leme
		cQuery += 	"'" + XFilial("SC2")+AllTrim(TRB->C2_NUM+TRB->C2_ITEM+TRB->C2_SEQUEN+TRB->C2_ITEMGRD) + "', " + ;
		"'" + AllTrim(TRB->C2_PRODUTO) + "', " + ;
		"'-10', " + ;
		"'-10', " + ;
		"'" + AllTrim(_cLances)  + "', " //DADOS DOS PEDIDOS ENVOLVIDOS NESSA OP


		cQuery += 	"'" + AllTrim(_DtEmm1) + "', " + ;
		"'" + If(Empty(TRB->C2_DATPRF),AllTrim(_DtEmm1),AllTrim(_DtEmm2)) + "', " + ;
		AllTrim(Str(TRB->C2_QUANT,19,4))  + ", " + ; //AllTrim(Str(TRB->C2_QUANT-TRB->C2_QUJE,19,4)) + ", " + ;//
		If(TRB->C2_STATOP=='P',"30","20") + ", " + ;
		"'10', "

		cQuery += 	"'"+_cAtivid+"', " + ;
		"0, " + ;
		"2, " + ;
		"2, " + ;
		"0, "

		cQuery += 	If(TRB->C2_STATOP=='P',"30, ","20, ")   + ;
		"'" + AllTrim(_cGpoMaq) + "', "         + ;
		AllTrim(Str(TRB->C2_QUANT,19,4)) + ", " + ; // AllTrim(Str(TRB->C2_QUANT-TRB->C2_QUJE,19,4)) + ", " + ; //
		"'" + AllTrim(Str(_nQLcs,10)) + "', "   + ;
		"'" + AllTrim(TRB->C2_UM) + "', "

		cQuery += 	"2, " + ;
		"2, " + ;
		"3, " + ;
		"1, " + ;
		"1, "

		cQuery += 	"1, " + ;
		"0, " + ;
		"1, " + ;
		"'" + AllTrim(_cGpoMtzs) + "', " + ;
		"1 " + ;
		" )"

		If (TCSqlExec(cQuery) < 0) // Deu Erro
			//cMsg := "Erro ao tentar gravar no banco de integração:" + linha
			cMsg := TCSQLError()// + linha
			//cMsg += "Comunique o Departamento de TI!"
			MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
			// Desarma a transação do Banco de Integração
			DisarmTransaction()
			// Retorna para o banco Protheus
			TcSetConn(nHndErp)
			// Desarma a transação do Banco Protheus
			DisarmTransaction()
			MsUnlockAll()

			DbSelectArea("SC2")
			RecLock("SC2",.F.)
			SC2->C2_STATINT := "X" // Erro na Integração
			MsUnLock()

			DbSelectArea("TRB")
			DbSkip()
			Loop
		EndIf


		// Gravar os dados dos pedidos na tabela nova	 - DEMANDAS

		// Variável para controlar se ocorreu erro ao gravar os dados
		_lErroInt := .F.

		For nCtd := 1 to Len(_aLances)
			cQuery := "INSERT cTblDemanda " + ;
			"( Integrated, NumerodoPedido  , ItemdoPedido, Cliente      , ProdutoPV, " + ;
			"DescProdPV, Acondicionamento, Quantidade  , DataEntregaPV, OrdemProducao," + ;
			"ProdutoOP, DescProdOP )" + ;
			"VALUES ( " 
			cQuery += "0" + ", "    // iNTEGRAÇÃO
			cQuery += "'" + AllTrim(_aLances[nCtd,01]) + "', "    // Número do Pedido
			cQuery += "'" + AllTrim(_aLances[nCtd,02]) + "', "    // Item do Pedido
			cQuery += "'" + AllTrim(_aLances[nCtd,08]) + "', "    // Nome do Cliente
			cQuery += "'" + AllTrim(_aLances[nCtd,06]) + "', "    // Código do Produto no Pedido de Vendas

			cQuery += "'" + AllTrim(_aLances[nCtd,07]) + "', "    // Descrição do Produto no Pedido de Vendas
			cQuery += "'" + AllTrim(_aLances[nCtd,03]) + "', "    // Acondicionamento
			cQuery += AllTrim(Str(_aLances[nCtd,05],15,4)) + ", " // Quantidade no Pedido de Vendas
			cQuery += "'" + AllTrim(_aLances[nCtd,09]) + "', "    // Data da Entrega do Pedido de Venda
			cQuery += "'"+ xFilial("SC2")+AllTrim(TRB->C2_NUM+TRB->C2_ITEM+;
			TRB->C2_SEQUEN+TRB->C2_ITEMGRD)+"', "// Número da OP

			cQuery += "'" + AllTrim(TRB->C2_PRODUTO) + "', "        // Produto da OP
			cQuery += "'" + AllTrim(TRB->C2_DESCRI)  + "' )"        // Descrição do Produto da OP

			//Executa e testa se INSERT foi executado corretamente
			If (TCSqlExec(cQuery) < 0) // Deu Erro
				_lErroInt := .T.
				//cMsg := "Erro ao tentar gravar no banco de integração:" + linha
				cMsg := TCSQLError()// + linha
				//cMsg += "Comunique o Departamento de TI!"
				MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
				Exit
			EndIf
			_ggff := "SÓ PARA EU PODER COLOCAR UM PONTO DE PARADA"
		Next

		If _lErroInt
			// Desarma a transação do Banco de Integração
			DisarmTransaction()
			// Retorna para o banco Protheus
			TcSetConn(nHndErp)
			// Desarma a transação do Banco Protheus
			DisarmTransaction()
			MsUnlockAll()

			DbSelectArea("SC2")
			RecLock("SC2",.F.)
			SC2->C2_STATINT := "X" // Erro na Integração
			MsUnLock()

			DbSelectArea("TRB")
			DbSkip()
			Loop
		EndIf

		// Liberar as transações
		EndTran()   // Libera a transação do banco PPI

		TcSetConn(nHndErp) // Seleciona o Banco Protheus
		RecLock("SC2",.F.)
		SC2->C2_STATINT := "I" // OP Integrada com o PPI
		MsUnLock()

		EndTran()   
		MsUnlockAll()

		// Transfere os dados de _aPrIncNow para _aPrIncBef
		For _nVez := 1 to Len(_aPrIncNow)
			aadd(_aPrIncBef,_aPrIncNow[_nVez])
		Next

		DbSelectArea("TRB")
		DbSkip()
	EndDo
Return(.T.)


/*/{Protheus.doc} InsProds
//TODO Insere ou Atualiza Produtos no PCFactory.
@author juliana.leme
@since 24/07/2017
@version 1.0
@param _lRegua, , descricao
@type function
/*/
Static Function InsProds(_lRegua)
	//	1 - Verificar se o código desse produto ja existe na tabela de integração;
	//	2 - Como pode haver diversos registros com o mesmo código, resgatar somente o último incluído;
	//	3 - Para evitar dar diversos selects no banco, tratar o array _aPrdsIncs {Código do produto}, onde
	//		se já estiver o código neste array não precisa fazer nada, pois, acabou de ser incluído;
	//	4 - O array _aDadProds terá todas as informações do produto.
	Local _lVolta := .F. // Significa que não deu erro na função
	Local _nVez := 0

	If _lRegua                        
		ProcRegua(Len(_aDadProds))
	EndIf

	For _nVez := 1 To Len(_aDadProds)
		// Verificar se não foi integrado por esta OP ou OPs anteriores.
		If _lRegua                        
			IncProc()
		EndIf

		If Ascan(_aPrIncBef,_aDadProds[_nVez,2]) # 0 .Or. Ascan(_aPrIncNow,_aDadProds[_nVez,2]) # 0
			// Tem em um dos dois arrays
			// Não faz nada
			Loop
		EndIf

		Aadd(_aPrIncNow,_aDadProds[_nVez,2]) // Adiciona o produto para não mais tentar incluir na integração
		// Verifica no banco de integração se houve alguma alteração referente a última
		// inclusão na tabela TBLInProduct
		_xQuery := "SELECT  "
		_xQuery += "Max(IDInProduct) as NUMREC,  "
		_xQuery += "ProductTypeCode as B1_TIPO, "
		_xQuery += "Code as B1_COD,  "
		_xQuery += "Name as B1_DESC,  "
		_xQuery += "Unit1Code as B1_UM, "
		_xQuery += "Unit2Code as B1_TIPO2,  "
		_xQuery += "Unit2Factor as B1_PESCOB, "
		_xQuery += "Unit3Code as B1_TIPO3,  "
		_xQuery += "Unit3Factor as B1_X_FATOR, "
		_xQuery += "DefaultAddressCode as B1_LOCPAD,  "
		_xQuery += "FamilyProductCode as B1_FAMILY "
		_xQuery += "FROM TBLInProduct "                                
		_xQuery += "WHERE Code = '" + AllTrim(_aDadProds[_nVez,2]) + "' "
		_xQuery += "Group By ProductTypeCode, Code, Name,Unit1Code, "
		_xQuery += "Unit2Code, Unit2Factor, Unit3Code, Unit3Factor, "
		_xQuery += "DefaultAddressCode, FamilyProductCode"
		//_xQuery += "ORDER BY IDInProduct"

		_xQuery := ChangeQuery(_xQuery)

		If Select("TRB1")>0
			DbSelectArea("TRB1")
			DbCloseArea()
		EndIf
		TCQUERY _xQuery NEW ALIAS "TRB1"

		_lAlter := .T.
		_nNumRec := 0
		DbSelectArea("TRB1")
		DbGotop()
		Do While TRB1->(!Eof())
			If TRB1->NUMREC > _nNumRec
				_lAlter := .F.
				_nNumRec := TRB1->NUMREC
				M->B1_TIPO   := Left(TRB1->B1_TIPO   + Space(50),TamSX3("B1_TIPO")[1])
				M->B1_COD    := Left(TRB1->B1_COD    + Space(50),20)
				M->B1_DESC   := Left(TRB1->B1_DESC   + Space(50),TamSX3("B1_DESC")[1])
				M->B1_UM     := Left(TRB1->B1_UM     + Space(50),TamSX3("B1_UM")[1])
				M->B1_TIPO2  := Left(TRB1->B1_TIPO2  + Space(50),TamSX3("B1_TIPO")[1])
				M->B1_PESCOB := TRB1->B1_PESCOB
				M->B1_TIPO3  := Left(TRB1->B1_TIPO3  + Space(50),TamSX3("B1_TIPO")[1])
				M->B1_X_FATOR:= TRB1->B1_X_FATOR
				M->B1_LOCPAD := Left(TRB1->B1_LOCPAD + Space(50),Len(_aDadProds[_nVez,7]))
				M->B1_FAMILY := Left(TRB1->B1_FAMILY + Space(50),2)

				If _aDadProds[_nVez,01] # M->B1_TIPO
					_lAlter := .T.
				ElseIf _aDadProds[_nVez,02] # M->B1_COD
					_lAlter := .T.
				ElseIf _aDadProds[_nVez,03] # M->B1_DESC
					_lAlter := .T.
				ElseIf _aDadProds[_nVez,04] # M->B1_UM
					_lAlter := .T.
				ElseIf _aDadProds[_nVez,05] # M->B1_TIPO3
					_lAlter := .T.
				ElseIf _aDadProds[_nVez,06] # M->B1_X_FATOR
					_lAlter := .T.
				ElseIf _aDadProds[_nVez,07] # M->B1_LOCPAD
					_lAlter := .T.
				ElseIf _aDadProds[_nVez,09] # M->B1_FAMILY
					_lAlter := .T.
				ElseIf _aDadProds[_nVez,10] # M->B1_TIPO2
					_lAlter := .T.
				ElseIf _aDadProds[_nVez,11] # M->B1_PESCOB
					_lAlter := .T.
				EndIf
			EndIf
			TRB1->(DbSkip())
		EndDo

		DbSelectArea("TRB1")
		DbCloseArea()

		If _lAlter // Tem dado alterado
			cQuery := "INSERT TBLInProduct " + ;
			"( PlantCode  , ProductTypeCode, Code              , Name             , Unit1Code  , " + ;
			"  Unit2Code  , Unit2Factor    , FlgEnable         , FlgPrintP00      , FlgPrintP01, " + ;
			"  FlgPrintP02, FlgPrintP03    , FlgPrintP04       , FlgPrintP05      , FlgPrintP06, " + ;
			"  FlgPrintP07, FlgPrintP08    , FlgPrintP09       , FlgPrintP10      , FlgPrintP11, " + ;
			"  FlgPrintP12, FlgBackFlush   , DefaultAddressCode, FamilyProductCode, ExtCode    , " + ;
			"  Unit3Code  , Unit3Factor ) " + ;                 
			"VALUES ( " + ;
			"'-10', " + ;
			"'" + AllTrim(_aDadProds[_nVez,01]) + "', " + ;
			"'" + AllTrim(_aDadProds[_nVez,02]) + "', " + ;
			"'" + AllTrim(_aDadProds[_nVez,03]) + "', " + ;
			"'" + AllTrim(_aDadProds[_nVez,04]) + "', " + ;
			"'" + AllTrim(_aDadProds[_nVez,10]) + "', " + ;
			AllTrim(Str(_aDadProds[_nVez,11],10,4)) + ", " + ;
			"1, " + ;
			"0, " + ;
			"0, " + ;
			"0, " + ;
			"0, " + ;
			"0, " + ;
			"0, " + ;
			"0, " + ;
			"0, " + ;
			"0, " + ;
			"0, " + ;
			"0, " + ;                                    
			"0, " + ;
			"0, " + ;
			"1, " + ;
			"'" + AllTrim(_aDadProds[_nVez,07]) + "', " + ;
			"'" + AllTrim(_aDadProds[_nVez,09]) + "'," + ;
			If(Upper(_aDadProds[_nVez,04])#"MT","'1',","'',") + ;
			"'" + AllTrim(_aDadProds[_nVez,05]) + "', " + ;
			AllTrim(Str(_aDadProds[_nVez,06],10,4)) +;
			" ) "
			// 10/12/2014 - 17:30h
			// Referente ao campo ExtCode, falei com Pedro, da PPI, que para casos em que a unidade de medida 
			// do produto for diferente de METRO, enviar a SEGUNDA UM como METRO e o fator multiplicador da 
			// 1ra UM para metro - em Unit2Code, Unit2Factor respectivamente. Nesses casos, também enviar "1" 
			// para ExtCode, que indicará no PCFACTORY que nos REPORTs a quantidade digitada é em metros e tem
			// que ser converida para a 1ra UM e baseado nesse resultado efetuar O REPORT e o CONSUMO  (pela LDM)

			//Executa e testa se INSERT foi executado corretamente
			If _lRegua                        
				TCSqlExec(cQuery)
			Else
				If (TCSqlExec(cQuery) < 0) // Deu Erro
					_lVolta := .T. // Significa que deu erro na função
					//cMsg := "Erro ao tentar gravar no banco de integração:" + linha
					cMsg := TCSQLError() //+ linha
					//cMsg += "Comunique o Departamento de TI!"
					MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
					Exit
				EndIf
			EndIf
		EndIf

		// If _aDadProds[_nVez,1] # "PA" // Não envia saldos de PA
		// Conforme Mauricio em 08/12/14 12:10h ele só precisa dos estoques dos PIs. (não PA nem MP)

		If _aDadProds[_nVez,1] == "PI" // Não envia saldos de PA
			// Incluir os Saldos dos Produtos
			//atenção... verificar o insert de saldos
			cQuery := "INSERT cTblEstoquePreactor " + ;
			"( Codigo_Produto, Descricao , Qtd_Disponivel, Data_Atualizacao ) " + ;
			"VALUES ( " + ;
			"'" + AllTrim(_aDadProds[_nVez,2]) + "', " + ;
			"'" + AllTrim(_aDadProds[_nVez,3]) + "', " + ;
			AllTrim(Str(_aDadProds[_nVez,8],16,2)) + ", " + ;
			Dtos(Date()) + ;
			" ) "

			If (TCSqlExec(cQuery) < 0) // Deu Erro
				_lVolta := .T. // Significa que deu erro na função
				//cMsg := "Erro ao tentar gravar no banco de integração:" + linha
				cMsg := TCSQLError() //+ linha
				//cMsg += "CoRunique o Departamento de TI!"
				MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
				Exit
			EndIf
		EndIf
	Next               
Return(_lVolta)


/*/{Protheus.doc} GrvEmpen
//TODO Atualiza Lista de Materiais no PPI.
@author Roberto
@since 24/07/2017
@version 1.0

@type function
/*/
Static Function GrvEmpen()
	_cOpcNow := _aGpoOpc[_nPsGpo,3]+"/"+_aGpoOpc[_nPsGpo,4] //3-Gpo.Opc. //4-Item OPC
	_cDscOpc := Posicione("SGA",1,xFilial("SGA")+(_aGpoOpc[_nPsGpo,3]+_aGpoOpc[_nPsGpo,4]),"GA_DESCOPC")

	//_xD4_COD := AllTrim(_D4_COD)
	If _nQtdOpc > 0
		_xD4_COD := Left(AllTrim(_D4_COD) + Replicate("_",16),16) + StrZero(_nQtdOpc++,2)
	Else
		_xD4_COD := AllTrim(_D4_COD)
	EndIf                                       

	//Corrigindo tamanho Padrão PCFactory em 20 caracteres
	_xD4_COD := Padr(_xD4_COD,20)

	// Incluir na BillMat o código novo
	_nPsCod := aScan(_aDadProds,{|x|x[2]==_xD4_COD})
	If _nPsCod == 0
		// Uso as informações do produto normal
		_nQtSaldo := 0
		If SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD,.F.))
			_nQtSaldo += Max(0,SB2->B2_QATU)
		EndIf
		If SB1->B1_LOCPAD # "99"
			If SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+"99",.F.))
				_nQtSaldo += Max(0,SB2->B2_QATU)
			EndIf
		EndIf

		_cTipo3 := "MT"
		_nConv3 := If(Upper(SB1->B1_UM)#"MT",SB1->B1_X_FATOR,1)

		aadd(_aDadProds,{;
		SB1->B1_TIPO,;
		_xD4_COD,;
		SB1->B1_DESC,;
		Upper(SB1->B1_UM),;
		_cTipo3,;
		_nConv3,;
		If(SB1->B1_LOCPAD=="99","01WIP","01EST"),;
		_nQtSaldo,;
		If("VERGALH"$Upper(SB1->B1_DESC),"VE",SB1->B1_TIPO),;
		If(SB1->B1_UM=="MT","KG","MT"),;
		SB1->B1_PESBRU})

		// Atenção: Caso mude o tamanho que qualquer campo, verificar a comparação 
		// para o comando INSERT da TBLInProduct.
	EndIf

	_cQuant := AllTrim(Str(Round((SC2->C2_QUANT * _aGpoOpc[_nPsGpo,6]),2),24,4))
	_cCoef := AllTrim(Str((_aGpoOpc[_nPsGpo,6]*100000),29,9))
	Aadd(_aEmpen,Array(12))
	_nPosEmp := Len(_aEmpen)
	_aEmpen[_nPosEmp,01] := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)	// Nro da OP
	_aEmpen[_nPosEmp,02] := "10"				// Código da Operação-> Conf.Pedro é igual ao campo WODetCode da tabela TBLinWOComplete
	_aEmpen[_nPosEmp,03] := _xD4_COD			// Código do produto (Modificado)
	_aEmpen[_nPosEmp,04] := _cQuant				// Quantidade necessária
	_aEmpen[_nPosEmp,05] := "-10"				// Rendimento do material - fixar -10
	_aEmpen[_nPosEmp,06] := "1"					// Quant.prevista a ser consumida - fixar 1
	_aEmpen[_nPosEmp,07] := _cCoef				// Coeficiente relac.a quant.da WO
	_aEmpen[_nPosEmp,08] := "1"					// Determina se o item deve ser baixado fixar 0
	_aEmpen[_nPosEmp,09] := SB1->B1_TIPO		// Tipo do Produto
	_aEmpen[_nPosEmp,10] := _cOpcNow			// Grupo de Opcionais
	_aEmpen[_nPosEmp,11] := _cDscOpc			// Descrição do Grupo de Opcionais
	_aEmpen[_nPosEmp,12] := Max(_aGpoOpc[_nPsGpo,9],1)
Return(.T.)


/*/{Protheus.doc} Arru_op
//TODO Atualiza OP Integrada no Protheus.
@author Roberto
@since 24/07/2017
@version 1.0

@type function
/*/
User Function Arru_op()
	DbSelectArea("SC2")
	DbSetOrder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

	DbSeek(xFilial("SC2"),.F.)
	Do While SC2->C2_FILIAL == xFilial("SC2") .And. SC2->(!Eof())
		If !Empty(SC2->C2_PROGR)
			_cOPAtu := SC2->C2_NUM+SC2->C2_ITEM
			_cProgr := SC2->C2_PROGR
			DbSkip()
			Do While SC2->C2_FILIAL == xFilial("SC2") .And. SC2->(!Eof()) .And. SC2->C2_NUM+SC2->C2_ITEM == _cOPAtu
				RecLock("SC2",.F.)
				SC2->C2_PROGR := _cProgr
				MsUnLock()
				DbSkip()
			EndDo
		Else        
			DbSkip()
		EndIf
	EndDo
Return(.t.)


/*/{Protheus.doc} IntegrSB1ME
//TODO Integra Cadastro de Produto ME (Material de Embalagem).
@author juliana.leme
@since 24/07/2017
@version 1.0

@type function
/*/
Static Function IntegrSB1ME()   
	Private _aDadProds := {} // terá todas as informações do produto.

	TcSetConn(nHndErp) // Seleciona o Banco Protheus
	DbSelectArea("SB1")
	DbSetOrder(1)

	ProcRegua(RecCount())
	DbSeek(xFilial("SB1"),.F.)
	Do While SB1->(!Eof())
		IncProc()

		If ( (SB1->B1_TIPO$ "ME//PA//PI//SC//OI//MP//") .or. (SB1->B1_GRUPO="MC17") ) .and. (SB1->B1_MSBLQL<>"1")                      
			_cTipo3 := "MT"
			_nConv3 := If(Upper(SB1->B1_UM)#"MT",SB1->B1_X_FATOR,1)

			aadd(_aDadProds,{;
			SB1->B1_TIPO,;
			Padr(SB1->B1_COD,20),;
			SB1->B1_DESC,;
			Upper(SB1->B1_UM),;
			_cTipo3,;
			_nConv3,;
			If(SB1->B1_LOCPAD=="99","01WIP","01EST"),;
			0,; //Saldo Zerado (não envia saldo para o PreActor) //Juliana
			If("VERGALH"$Upper(SB1->B1_DESC),"VE",SB1->B1_TIPO),;
			If(SB1->B1_UM=="MT","KG","MT"),;
			SB1->B1_PESBRU})

			// Atenção: Caso mude o tamanho que qualquer campo, verificar a comparação 
			// para o comando INSERT da TBLInProduct.
		EndIf
		SB1->(DbSkip())
	EndDo  

	If Len(_aDadProds) > 0
		// Seleciono a conexão do PPI
		TcSetConn(nHndPPI)
		InsProds(.T.)
		// Retorna para o banco Protheus
		TcSetConn(nHndErp)
	EndIf
Return(.T.)