#include "TOPCONN.ch"
#include "protheus.ch"
#Define linha chr(13)+chr(10)

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ..Funções Diversas .:                           Modulo :      //
//                                                                          //
//   Autor ......:Leonardo Bolognesi               Data ..: 24/08/2015   	//
//   Modificações                                                           //
//   Data..:28/01/2016......Novas regras e recursos (e-mail / documentado)  //
//   Objetivo ...:Tratar as Validações na inclusão de pedidos				//
//considerando o processo de triangulação e gerar os PV entre empresas para //
//atender estes pedidos                                                     //
//                                                                          //
//   Uso ........:Colocação de Pedidos Triangulação                         //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

User Function valRegiao(cCliente, cLojaCli)  //u_valRegiao("009973","01")
	Local aArea				:= GetArea()
	Local aSC5 				:= SC5->(GetArea())
	Local aSC6				:= SC6->(GetArea())
	Local lRetorno
	Local oRegra			:= Nil
	Local oIndl				:= Nil
	Local cErr				:= ""

	Local nX				:= 0

	Default cCliente 		:= M->C5_CLIENTE
	Default cLojaCli 		:= M->C5_LOJACLI

	If Empty(cCliente) .Or. Empty(cLojaCli) .Or. M->C5_TIPO # "N"
		Return(.T.)
	EndIf

	//CLASSE REGRAS
	oIndl 	:= CbcIndRules():newCbcIndRules(cCliente, cLojaCli,'', .F., .T.)

	//CARREGA AS REGRAS
	oIndl:loadRules()

	//REGRAS DEFINIDAS PELO ADMINISTRATIVO
	If !Empty(M->C5_ZZAPR)

		oRegra := fromJson( Alltrim(M->C5_ZZAPR) )
		If FWCodEmp()+FWCodFil() # oRegra:REGRA:FATURA

			cErr := "<b>[Aviso]</b> <p> O Pedido deste cliente deve ser digitado em <b>" +;
			IIF(FWCodEmp()+FWCodFil() == "0102"," Itu/SP"," Três Lagoas/MS") + "</b> </p>"
			u_autoAlert(cErr,,'Info','Pedido')
			lRetorno := .F.
		Else
			lRetorno := .T.

		EndIf

		//REGRAS PADRÂO DEFINIDAS PELO SISTEMA
	else

		//VALIDAÇÂO DO CLIENTE
		If !oIndl:lClientVld // (.T.)= APLICAR ROTINA  (.F.) = NÃO APLICAR ROTINA
			lRetorno := .T.
		Else
			//Funcionario
			If oIndl:lFunc

				u_autoAlert("Pedido para funcionario",.F.,'Info','AVISO')
				Return(.T.)

				//Consumidor Final , pessoa fisica e não funcionario
			ElseIf oIndl:lCfPf
				Return(oIndl:lContinua)
			EndIf                                              '

			If Empty(oIndl:cUFCli)
				cErr := "<b>[Erro]</b> <p> O Cliente não existe ou cadastrado sem Estado(UF)</p>"

				//TRATAR MENSAGENS PARA ROTINA AUTOMATICA
				If oIndl:isAuto()
					oIndl:lOk 		:= .F.
					oIndl:cMsgErr	:= cErr
				Else
					MsgInfo(cErr ,"Erro")
				EndIf
				lRetorno := .F.

			Else
				If oIndl:IsVldBranch()
					lRetorno := .T.
				Else
					cErr := "<b>[Aviso]</b> <p> O Pedido deste cliente deve ser digitado em <b>" +;
					IIF(FWCodEmp()+FWCodFil() == "0102"," Itu/SP"," Três Lagoas/MS") + "</b> </p>"

					//TRATAR MENSAGENS PARA ROTINA AUTOMATICA
					If oIndl:isAuto()

						oIndl:lOk 		:= .F.
						oIndl:cMsgErr	:= cErr
					Else

						MsgInfo(cErr,"Pedido")
						oIndl:msgRules()

					EndIf

					lRetorno := .F.
				EndIf
			EndIf
		EndIf
	EndIf

	RestArea(aSC6)
	RestArea(aSC5)
	RestArea(aArea)
Return(lRetorno)


User Function valProdu(cCliente, cLojaCli, cCodProd, nAcols, oIndl)  //u_valProdu("008577", "01", "1120704201")
	Local aArea			:= GetArea()
	Local aSC5 			:= SC5->(GetArea())
	Local aSC6			:= SC6->(GetArea())
	Local cRetorno		:= ""

	Default cCliente 	:= M->C5_CLIENTE
	Default cLojaCli 	:= M->C5_LOJACLI
	Default cCodProd	:= M->C6_PRODUTO
	Default nAcols		:= 0 //POR ENQUANTO A UNICA CHAMADA VEM DO FONTE M410LIOK(M410TOK()), PASSANDO A POSSIÇÃO DO aCols PARA ALTERAÇÃO


	//REGRAS DEFINIDAS PELO ADMINISTRATIVO
	If !Empty(M->C5_ZZAPR)

		GDFieldPut("C6_SEMANA", ''  ,nAcols)

		oRegra := fromJson( Alltrim(M->C5_ZZAPR) )

		//Se tem armazem definido utiliza o armazem
		if !Empty(oRegra:REGRA:ARMAZEM)

			cRetorno := Alltrim(oRegra:REGRA:ARMAZEM)
			//Não tem armazem divisão por fabricação
		else

			If !u_Tem3Lag(cCodProd)

				If oRegra:REGRA:FLAG $ "TAUTOM"
					cRetorno := "01"
					GDFieldPut("C6_SEMANA", 'TAUTOM'  ,nAcols)
				ElseIf oRegra:REGRA:FLAG $ "10"
					cRetorno := "10"
					lTeveDiv := oRegra:REGRA:DIV_VALOR == "T"
				EndIf
			Else
				cRetorno := "01"
			EndIf
		EndIf
		//REGRAS PADRÂO DEFINIDAS PELO SISTEMA
	Else
		If Empty(oIndl:cUFCli) //.OR. Empty(cCorProd)

			If oIndl:isAuto()
				oIndl:lOk 		:= .F.
				oIndl:cMsgErr	:= cErr
			Else
				MsgInfo( "<b>[Erro]</b> <p> O Cliente esta cadastrado sem Estado(UF)</p>","Erro" )
			EndIf
			cRetorno := ""

		Else
			//APLICA AS REGRAS ( oIndl, Estanciado no fonte M410LIOK na função
			cRetorno := oIndl:defOper(cCodProd, nAcols, M->C5_DRCPROD)
		EndIf
	EndIf

	RestArea(aSC6)
	RestArea(aSC5)
	RestArea(aArea)

Return(cRetorno)


User Function divPedido()

	//Aplicar a regra de divisão considerandio o valor minimo
	Local aArea			:= GetArea()
	Local aAreaSC6		:= SC6->(GetArea())
	Local lRet			:= .T.
	Local nZeroUm		:= 0
	Local nDez			:= 0
	Local aEmail		:= {}
	Local cSaida		:= ""
	Local nVlrPed		:= GetMV("MV_VLRPED")

	If FWCodEmp()+FWCodFil() == "0102"

		//Obter as somas dos valores( Itu(10) e TL(01) )
		DbSelectArea("SC6")
		DbSetOrder(1)
		For nI:= 1 to Len(aCols)
			If !GDDeleted(nI)

				If GDFieldGet("C6_LOCAL",nI) == "10"

					nDez += GDFieldGet("C6_VALOR",nI)

				ElseIf GDFieldGet("C6_LOCAL",nI) == "01"

					nZeroUm += GDFieldGet("C6_VALOR",nI)

				EndIf
			EndIf
		Next

		//Algum dos dois é zero não teve divisão (mesmo a função MT410TOK chamando somente se teve divisão)
		If nZeroUm == 0 .Or.  nDez == 0
			lRet := .F.
		Else

			//Valida as regras
			//Apos divisão os dois pedido são iguais ou maior que o limite minimo
			If nZeroUm >= nVlrPed .And. nDez >= nVlrPed
				cSaida := "PARCIAL"

				//Apos divisão somente o pedido de 3lagoas é maior que o limite minimo
			ElseIf nZeroUm >= nVlrPed
				cSaida := "TL"

				//Outros casos, apos divisão Itu é maior ou os dois são menores que o limite minimo
			Else
				cSaida := "ITU"
			EndIf

			//Aplica as modificações (somente se não for parcial), neste caso deixa a divisão como esta
			If cSaida # "PARCIAL"

				DbSelectArea("SC6")
				DbSetOrder(1)
				For nI:= 1 to Len(aCols)
					If !GDDeleted(nI)

						If cSaida $ "TL" .And. GDFieldGet("C6_LOCAL",nI) == "10"

							GDFieldPut("C6_LOCAL"	, '01'  	,nI)
							GDFieldPut("C6_SEMANA"	, 'TAUTOM'  ,nI)

						ElseIf cSaida $ "ITU"

							GDFieldPut("C6_LOCAL"	, '10'  	,nI)

						EndIf

					EndIf
				Next
				//Enviar e-mail para documentar a divisão
				aEmail := {{Alltrim(M->C5_NUM),Transform(nDez + nZeroUm,"@E 9999,999,999.99"),Transform(nDez, "@E 9999,999,999.99"),Transform(nZeroUm,"@E 9999,999,999.99"),cSaida}}
				u_envmail({Alltrim(GetMv("MV_PVDIVID"))}, "[PV]-Divisão por valor", {"Pedido","Total","Itu", "3Lagoas","Saida"},aEmail)

			EndIF


		EndIf
	EndIf
	Return (lRet)

	**********************
User Function pedIndl(cNrPed)  //u_pedIndl(cNrPed)
	**********************
	//SC5 está posicionado
	Local aArea			:= GetArea()
	Local aSA1			:= SA1->(GetArea())
	Local aSC5 			:= SC5->(GetArea())
	Local aCabec		:={}
	Local aItens		:={}
	Local cPV
	Local cItemPv
	Local cBkNmEmp
	Local cQry			:=""
	Local cPV 			:= Space(6)
	Local nNx
	Local cBkRisco
	Local nExec			:= 3 //Inclusão
	Local aPar			:={}
	Local cLog			:=""
	Local cUltIndl		:=""
	Local cNrInc		:=""
	Local _cFatParcial	:=""//C5_PARCIAL - Pedidos BNDES tem que ser não
	Local 	lNProduz		:= .F.
	Local 	cCliNPrd 		:= GetNewPar('ZZ_NAOPROD', "")//CLIENTES COM PEDIDO DE PRODUÇÃO FIXO(PEDIDO GUARDA-CHUVA), POR ISSO TRANFERÊNCIA NÃO PRODUZ 
	local cOPer			:= ''	
	Private	lMsErroAuto	:=.F.
	Private lIsInd		:= .T.
	//Public _cPedC9
	//Default _cPedC9 := "      "

	Aadd(aPar, "gerIndl")
	If(Empty(cNrPed))
		Aadd(aPar, SC5->(C5_CLIENTE))
		Aadd(aPar, SC5->(C5_LOJACLI))
	Else
		Aadd(aPar, "")
		Aadd(aPar, "")
	EndIf

	If U_vPedReg(aPar) // (.T.)= APLICAR ROTINA  (.F.) = NÃO APLICAR ROTINA

		If(Empty(cNrPed))

			cNrPed := SC5->(C5_NUM)

		Else

			DbSelectArea("SC5")
			DbSetOrder(1) // C5_FILIAL+C5_NUM
			If( !SC5->(DbSeek(xFilial("SC5")+cNrPed,.T.)) )
				u_autoAlert("<b>Pedido não existe!</b>",,'Info','[AVISO]')
				return nil
			EndIf

		EndIf

		If FWCodEmp()+FWCodFil() == "0102" .And. trbPed()

			//Troca a filial para o novo pedido
			cBkNmEmp := cNumEmp
			cNumEmp := Left("0101"+Space(Len(cNumEmp)),Len(cNumEmp))
			cFilAnt := "01"
			SM0->(DbSeek(Left(cNumEmp,4),.F.))

			//Posiciona para criar o armazem
			DbSelectArea("SB2")
			SB2->(DbSetOrder(1))

			//Altera o risco do cliente para liberar credito automatico
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))

			If SA1->(DbSeek(xFilial("SA1")+"00891801",.F.))
				cBkRisco := SA1->(A1_RISCO)
				RecLock("SA1",.F.)
				SA1->A1_RISCO  := 'A'
				MsUnlock()
			Else
				u_autoAlert("<b>Verifique Cliente ITU/TL!</b>",,'Info','[AVISO]')
				return nil
			EndIf

			//Define se Incluir ou Alterar
			While !TRPED->(Eof())

				If !Empty(TRPED->(C6_ZZPVORI))
					cNrInc := SubStr(TRPED->(C6_ZZPVORI),1,6)
					Exit
				EndIf

				TRPED->(DbSkip())
			EndDo

			TRPED->(DbGoTop())

			If Empty(cNrInc)
				__aAreaC5 := SC5->(GetArea())
				cPV 	:= GetSx8Num("SC5","C5_NUM")
				ConfirmSX8()
				cItemPv := "01"
				DbSelectArea("SC5")
				DbSetOrder(1) // C5_FILIAL+C5_NUM
				Do While SC5->(DbSeek(xFilial("SC5")+cPV,.F.))
					cPV := GetSx8Num("SC5","C5_NUM")
					ConfirmSX8()
				EndDo
				RestArea(__aAreaC5)
			Else
				cPv 	:= cNrInc
				nExec 	:= 4 //Alteração
				cItemPv := 	Soma1(U_maiorItem(cPv,,'01')[2]) //Não Filtra Deletados
			EndIf

			//Salvar as datas originais
			_dDtEntOr	:= SC5->(C5_ENTREG)
			_dDtFatOr	:= SC5->(C5_DTFAT)

			//Definir a data de entrega devido a validação do campo C5_DTFAT  (M->C5_DTFAT+2 <= M->C5_ENTREG)
			If Max(SC5->(C5_ENTREG),Date()) == Max(SC5->(C5_DTFAT),Date())
				_dENTREG 	:= Max(SC5->(C5_ENTREG),Date())+2
			else
				_dENTREG	:= Max(SC5->(C5_ENTREG),Date())
			EndIf

			//Diferenciar BNDES pelo condição de pagamento
			If SC5->(C5_CONDPAG) == '000'
				_cCondPag := '000'
				_cFatParcial := 'N'
			Else
				_cCondPag := '263'
				_cFatParcial := SC5->(C5_PARCIAL) //COPIA O PARCIAL DO PEDIDO DO CLIENTE
			EndIf
			
			lNProduz := Alltrim(SC5->(C5_CLIENTE) + SC5->(C5_LOJACLI)) $ cCliNPrd

			//!EMPTY(M->C5_DTFAT) .And. M->C5_DTFAT+2 <= M->C5_ENTREG .And. M->C5_DTFAT >= M->C5_EMISSAO

			aCabec := {{"C5_FILIAL"		,"01"										,Nil},; 	// Filial Pedido		(OK)
							{"C5_NUM"			,cPV										,Nil},; 	// Numero do Pedido		(OK)
							{"C5_TIPO"			,"N"										,Nil},; 	// Tipo do Pedido		(OK)
							{"C5_CLIENTE"		,"008918"								,Nil},; 	// Codigo do Cliente	(OK)
							{"C5_LOJACLI"		,"01"										,Nil},; 	// Loja do Cliente		(OK)
							{"C5_TIPOCLI"		,"R"										,Nil},; 	// Tipo do Cliente		(OK)
							{"C5_CONDPAG"	,_cCondPag								,Nil},; 	// Condicao de pgto		(OK)
							{"C5_CLIENT"		,"008918"								,Nil},; 	// Cliente Entrega		(OK)
							{"C5_LOJAENT"	,"01"										,Nil},; 	// Loja para entrega	(OK)
							{"C5_EMISSAO"	,SC5->(C5_EMISSAO)				,Nil},; 	// Emissão Pedido		(OK)
							{"C5_ENTREG"		,_dENTREG								,Nil},; 	// Data de Entrega		(OK)
							{"C5_DTFAT"		,Max(SC5->(C5_DTFAT),Date())	,Nil},; 	// Data de Faturamento	(OK)
							{"C5_TABELA"		,SC5->(C5_TABELA)					,Nil},;	// Tabela para igualar camppos de preços (OK)
							{"C5_DIASNEG"	,SC5->(C5_DIASNEG)				,Nil},;	// Qtd.Dias uteis de negociação. (OK)
							{"C5_LAUDO"		,SC5->(C5_LAUDO)					,Nil},;	// Qtd.Dias uteis de negociação. (OK)
							{"C5_TPFRETE"	,'C'										,Nil},; 	// Tipo do frete		(OK)
							{"C5_PARCIAL"		,_cFatParcial							,Nil},; 	//Faturamento Parcial
							{"C5_ZZINSPE"		,SC5->(C5_ZZINSPE)							,Nil}} 	//INSPEÇÃO
			
			//Cliente tem pedido de produção fixo (Pedido Guarda-Chuva) e não deve produzir este pedido, apenas faturar
			If lNProduz
				AAdd(aCabec, {"C5_DRC"	    , 9999  ,Nil})
				AAdd(aCabec, {"C5_DRCPROD"	, "N"   ,Nil})
			EndIf

			While !TRPED->(Eof())
				//Se produto = 191 (Expositor ou Conjunto Armazenador) Juliana 19/05/2017
				_cTes := IIF(Left(TRPED->(C6_PRODUTO),3) == "191","849",IIF( Alltrim(TRPED->(C6_SEMANA)) == 'TAUTOM','551','540')) // Juliana - 21/05/2016 Alterado para 540 pois não é triangulação
				cOper := iif(GetMV("MV_ZZTRANS"), AllTrim(GetNewPar('ZZ_OPRSTRF','09')), iif(Alltrim(TRPED->(C6_SEMANA)) == 'TAUTOM', AllTrim(GetNewPar('ZZ_OPRSINF','11')), AllTrim(GetNewPar('ZZ_OPRSIND','17'))))
				If Empty(TRPED->(C6_ZZPVORI)) 	//Inclusão novo item
					//TODA VEZ QUE MUDAR "AITENS", CUIDADO , MANTER A POSIÇÃO 14 DO ARRAY COM O CONTEUDO DO CAMPO CAMPO ZZPVORI
					aAdd(aItens, {	{"C6_FILIAL"	,"01"													,Nil},; // Filial Item(OK)
										{"C6_NUM"			,cPV											,Nil},; // Numero Pedido 				(OK)
										{"C6_ITEM"			,cItemPv										,Nil},; // Sequencial com letras 		(OK)
										{"C6_PRODUTO"	,TRPED->(C6_PRODUTO)								,Nil},; // Codigo do Produto	 		(OK)
										{"C6_QTDVEN"		,TRPED->(C6_QTDVEN)								,Nil},; // Quantidade Vendida	 		(OK)
										{"C6_ACONDIC"	,TRPED->(C6_ACONDIC)								,Nil},; // Acondicionamento			(OK)
										{"C6_LANCES"		,TRPED->(C6_LANCES)								,Nil},; // Lances				 			(OK)
										{"C6_METRAGE"	,TRPED->(C6_METRAGE)								,Nil},; // Metragem				 		(OK)
										{"C6_TES"			,_cTes											,Nil},; // TES Item 						(OK)
										{"C6_LOCAL"		,"01"												,Nil},; // Armazem  						(OK)
										{"C6_CLI"			,"008918"										,Nil},; // Cliente							(OK)
										{"C6_QTDLIB"		,TRPED->(C6_QTDVEN)								,Nil},; // Quantidade Lib. Pedido		(OK)
										{"C6_LOJA"			,"01"											,Nil},; // Loja								(OK)
										{"C6_ZZPVORI"	,SC5->(C5_NUM)+TRPED->(C6_ITEM)						,Nil},; // Campo Amarração	(OK)  MATER POSIÇÃO 14 ARRAY
										{"C6_PRCVEN"		,TRPED->(C6_PRCVEN)								,Nil},; // Preço de venda ped original	(OK) 
										{"C6_ENTREG"		,_dENTREG										,Nil},; 
										{"C6_XOPER"	, 	cOper												,Nil}} ) // Tipo de Operação CBC (OK)

					cItemPv := soma1(cItemPv)

				Else 		//Alteração Item Existente

					//Somente manda ExecAuto Itens que foram alterados (pois mandar itens que não alterados cancela liber.SC9)
					If foiAlt()
						aAdd(aItens, {	{"C6_FILIAL"	,"01"							,Nil},; // Filial Item(OK)
						{"C6_NUM"		,cPV													,Nil},; // Numero Pedido 				(OK)
						{"C6_ITEM"		,SubStr(TRPED->(C6_ZZPVORI),7,2)		,Nil},; // Sequencial com letras 		(OK)
						{"C6_PRODUTO"	,TRPED->(C6_PRODUTO)					,Nil},; // Codigo do Produto	 		(OK)
						{"C6_QTDVEN"	,TRPED->(C6_QTDVEN)							,Nil},; // Quantidade Vendida	 		(OK)
						{"C6_ACONDIC"	,TRPED->(C6_ACONDIC)					,Nil},; // Acondicionamento		 		(OK)
						{"C6_LANCES"	,TRPED->(C6_LANCES)							,Nil},; // Lances				 		(OK)
						{"C6_METRAGE"	,TRPED->(C6_METRAGE)					,Nil},; // Metragem				 		(OK)
						{"C6_TES"		,_cTes												,Nil},; // TES Item 					(OK)
						{"C6_LOCAL"		,"01"												,Nil},; // Armazem  					(OK)
						{"C6_CLI"		,"008918"											,Nil},; // Cliente						(OK)
						{"C6_QTDLIB"	,TRPED->(C6_QTDVEN)							,Nil},; // Quantidade Lib. Pedido		(OK)
						{"C6_LOJA"		,"01"													,Nil},; // Loja							(OK)
						{"C6_ZZPVORI"	,SC5->(C5_NUM)+TRPED->(C6_ITEM)	,Nil},; // Campo Amarração				(OK) MATER POSIÇÃO 14 ARRAY
						{"C6_SEMANA"	,Posicione("SC6",1,xFilial("SC6")+TRPED->(C6_ZZPVORI) ,"C6_SEMANA")		,Nil},; // Loja							(OK)
						{"C6_QTDENT"	,Posicione("SC6",1,xFilial("SC6")+TRPED->(C6_ZZPVORI) ,"C6_QTDENT")		,Nil},; // Loja							(OK)
						{"C6_PRCVEN"	,TRPED->(C6_PRCVEN)							,Nil},; // Preço de venda ped original	(OK)
						{"C6_ENTREG"	,_dENTREG											,Nil},; //Data da Entrega				(OK)
						{"C6_XOPER"	, 	cOper												,Nil}} ) // Tipo de Operação CBC (OK)
					EndIf
				EndIf

				If Alltrim(TRPED->(C6_SEMANA)) == 'TAUTOM'
					If !SB2->(DbSeek(xFilial("SB2")+TRPED->(C6_PRODUTO)+"10",.F.))
						CriaSB2(TRPED->(C6_PRODUTO),"10")
					EndIf
				EndIf

				TRPED->(DbSkip())
			EndDo

			If Len(aItens) > 0
				BeginTran()
				//Adicionar historico de acordo com o TES (Juliana Pediu)
				If _cTes == '540'
					AADD(aCabec,{"C5_OBS"	, "PEDIDO DE INDUSTRIALIZAÇÃO REF.PV.ORIG.  NRO. " + SC5->(C5_NUM),Nil})
				ElseIf _cTes = '551'
					AADD(aCabec,{"C5_OBS"	, "Pedido Industr. Retorno para Tres Lagoas/MS",Nil})
				ElseIf _cTes = '849' .and. TRPED->(C6_LOCAL) == "10"
					AADD(aCabec,{"C5_OBS"	, "Pedido Transferencia ENTREGA ITU Ref. PV. Orig. Nro. " + SC5->(C5_NUM),Nil})	
				ElseIf _cTes = '849' .and. TRPED->(C6_LOCAL) <> "10" 
					AADD(aCabec,{"C5_OBS"	, "Pedido Transferencia. Retorno para Tres Lagoas/MS",Nil})	
				EndIf

				MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItens,nExec)

				If lMsErroAuto
					u_envmail({"wfti@cobrecom.com.br"}, "[Erro] - MSExecAuto - Criação do Pedido de Industrialização", {"Rotina","Linha","Função","Fonte","Obs"},{{"Mata410",cValToChar(ProcLine(0)),"pedIndl()","PEDINDL.PRW",MostraErro()}} )
					DisarmTransaction()

				Else

					EndTran()
					MsUnlockAll()

					// Pedidos de industrialização tem que ter as mesmas datas de entrega
					// pois serão entregues pela prória matriz.

					__aAreaC5 := SC5->(GetArea())
					DbSelectArea("SC5")
					DbSetOrder(1)					
				
					DbSeek(xFilial("SC5")+cPV,.F.)
					RecLock("SC5",.F.)						
						SC5->(C5_ENTREG) := _dDtEntOr
						SC5->(C5_DTFAT)  := _dDtFatOr
						SC5->(C5_NOTA)	 := ""
						SC5->(C5_SERIE)	 := ""		
					MsUnLock()
					
					DbSelectArea("SC6")
					DbSetOrder(1)
					DbSeek(xFilial("SC6")+cPV,.F.)
					Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == cPV .And. SC6->(!Eof())
						RecLock("SC6",.F.)
							SC6->(C6_ENTREG) := _dDtEntOr
						MsUnLock()
						SC6->(DbSkip())
					EndDo
					if cOper == AllTrim(GetNewPar('ZZ_OPRSINF','11'))
						if(SC5->(DbSeek(xFilial("SC5")+cPV,.F.)))
							u_AvalPrz("SC5",,,SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI) // Corrige o prazo de entrega
						endif
					endif
					RestArea(__aAreaC5)

					//aItens[1][14][2] //pedido(6)item(02) PedidoItem Original antigo
					//aItens[1][2][2]  //pedido novo(indl)
					//aItens[1][3][2]  //item novo
					DbSelectArea("SC6")
					DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM
					For nNx := 1 To Len(aItens)

						If SC6->(DbSeek('02'+cNrPed+SubStr(aItens[nNx][14][2],7,2), .T.))

							If SC6->(!Eof()) .And. ( SC6->(C6_LOCAL) == '10' .Or. Alltrim(SC6->(C6_SEMANA)) == 'TAUTOM' )
								RecLock("SC6",.F.)
								SC6->(C6_SEMANA) 	:= IIF( _cTes == '551','TAUTOM' ,"T" + cPV)
								SC6->(C6_ZZPVORI)	:= cPV + aItens[nNx][3][2]
								SC6->(MsUnLock())
							EndIF

						Else

							u_envmail({"wfti@cobrecom.com.br"}, "[Erro] - Atualização C6_ZZPVORI (Entre os pedidos(3LxITU) apresentou erro)", {"Rotina","Linha","Função","Fonte","Obs"},{{"UPDATE PV 3L",cValToChar(ProcLine(0)),;
							"pedIndl()","PEDINDL.PRW","LOG SQL: DbSeek Filial+Ped+Item ( 02"+cNrPed+SubStr(aItens[nNx][14][2],7,2) + " )" }} )
							//DisarmTransaction()
							Exit

						EndIf

					Next nNx

				EndIf
				//EndTran()
				//MsUnlockAll()
				//End Transaction
			EndIf

			TRPED->(dbCloseArea())
			FErase( "TRPED" + GetDbExtension())

			//Volta o risco original do cliente
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			If SA1->(DbSeek(xFilial("SA1")+"00891801",.F.))
				RecLock("SA1",.F.)
				SA1->A1_RISCO  := cBkRisco
				MsUnlock()
			EndIf

			//Volta a empresa original
			cNumEmp := cBkNmEmp
			cFilAnt := Substr(cNumEmp,3,2)
			SM0->(DbSeek(Left(cNumEmp,4),.F.))

		EndIf

	EndIf

	RestArea(aSC5)
	RestArea(aSA1)
	RestArea(aArea)

	Return nil


	**********************
Static Function trbPed()  //u_trbPed()
	**********************
	Local cSQL  :=""
	Local lRet	:= .T.

	If Select("TRPED") > 0
		DbSelectArea("TRPED")
		TRPED->(dbclosearea())
		FErase( "TRPED" + GetDbExtension())
	EndIf

	//Filtros
	cSQL += " AND C6.C6_NUM = " + SC5->(C5_NUM)
	cSQL += " AND C6.C6_ITEM <> '' "
	cSQL += " AND ( C6.C6_LOCAL = '10' OR C6.C6_SEMANA = 'TAUTOM' ) "
	cSQL := "%"+cSQL+"%"

	BeginSQL Alias "TRPED"

	column C6_ENTREG as Date

	SELECT
	C6.C6_FILIAL,
	C6.C6_NUM,
	C6.C6_ITEM,
	C6.C6_PRODUTO,
	C6.C6_QTDVEN,
	C6.C6_ACONDIC,
	C6.C6_LANCES,
	C6.C6_METRAGE,
	C6.C6_VALOR,
	C6.C6_TES,
	C6.C6_LOCAL,
	C6.C6_CLI,
	C6.C6_LOJA,
	C6.C6_ZZPVORI,
	C6.C6_ENTREG,
	C6.C6_SEMANA,
	C6.C6_PRCVEN,
	C6.R_E_C_N_O_ 	AS RCNO

	FROM %Table:SC6% C6

	INNER JOIN %Table:SC5% C5
	ON  C6.C6_FILIAL		= C5.C5_FILIAL
	AND C6.C6_NUM			= C5.C5_NUM
	AND C6.D_E_L_E_T_		= C5.D_E_L_E_T_

	WHERE C6.C6_FILIAL = %xFilial:SC6% %exp:cSQL% AND C6.%NotDel%
	ORDER BY C6.C6_ZZPVORI DESC

	EndSql

	DbSelectArea("TRPED")
	TRPED->(DbGoTop())

	If TRPED->(EOF())
		lRet	:= .F.
		TRPED->(dbCloseArea())
		FErase( "TRPED" + GetDbExtension())
	EndIF

	Return(lRet)

	**********************
User Function sDelPed(aCols, aHeader)  //u_sDelPed()
	**********************
	/*
	Esta função deve sincronizar as exclusões nos (pedidos 3L) com os pedidos de (INDL ITU)
	Adotando a premissa de que para deletar o pedido de 3L o pedido de (INDL ITU) não deve ter nenhuma bloqueio
	pois tambem será deletado.
	Caso o pedido de 3L não tenha relação com nenhum pedido em ITU retorna .T. e exclui normalmente.
	*/
	Local aArea			:= GetArea()
	Local aSA1			:= SA1->(GetArea())
	Local aSC5 			:= SC5->(GetArea())
	Local aSC6			:= SC6->(GetArea())
	Local aCabec		:={}
	Local aItens		:={}
	Local lTemItu		:= .F.
	Local lPodeDel		:= .T.
	Local cPedInd		:= ""
	Local cBkNmEmp		:= ""
	Local nI
	Local lRet 			:= .T.
	Private lMsErroAuto := .F.

	//Begin Transaction

	For nI:= 1 To Len(aCols)
		If !Empty(GDFieldGet("C6_ZZPVORI",nI) )
			lTemItu := .T.
			If	!U_vPedReg({"podeAlterar",{aCols[nI]},"Del" })
				u_autoAlert("Este pedido originou um pedido INDL-ITU Numero:" + SubStr(GDFieldGet("C6_ZZPVORI"	,nI),1,TamSX3("C6_NUM")[1]) + Chr(13) +;
				"Onde o Item: " + SubStr(GDFieldGet("C6_ZZPVORI"	,nI),7,TamSX3("C6_ITEM")[1]) + " esta (Faturado/Em Resumo/Bloqueado)" + Chr(13) +;
				" o que impossibilita e exclusão deste pedido!!! " )
				Return(.F.)
			EndIf
			cPedInd := SubStr(GDFieldGet("C6_ZZPVORI"	,nI),1,TamSX3("C6_NUM")[1])

		EndIF
	Next

	If lTemItu
		//Troca a filial para o novo pedido
		cBkNmEmp := cNumEmp
		cNumEmp := Left("0101"+Space(Len(cNumEmp)),Len(cNumEmp))
		cFilAnt := "01"
		SM0->(DbSeek(Left(cNumEmp,4),.F.))

		aCabec := {	{"C5_FILIAL","01"	,Nil},; 	// Filial Pedido		(OK)
		{"C5_NUM"	,cPedInd 			,Nil},; 	// Numero do Pedido		(OK)
		{"C5_TIPO"	,"N"				,Nil} } 	// Tipo do Pedido		(OK)

		For nI:= 1 To Len(aCols)
			If !Empty(GDFieldGet("C6_ZZPVORI",nI) )

				aAdd(aItens, {	{"C6_FILIAL"	,"01"														,Nil},; 	// Filial Item				(OK)
				{"C6_NUM"		,SubStr(GDFieldGet("C6_ZZPVORI"	,nI),1,TamSX3("C6_NUM")[1]) 				,Nil},; 	// Numero Pedido 			(OK)
				{"C6_ITEM"		,SubStr(GDFieldGet("C6_ZZPVORI"	,nI),7,TamSX3("C6_ITEM")[1])				,Nil},; 	// Sequencial com letras 	(OK)
				{"C6_PRODUTO"	,GDFieldGet("C6_PRODUTO"		,nI)										,Nil},; 	// Codigo do Produto	 	(OK)
				{"C6_QTDVEN"	,GDFieldGet("C6_QTDVEN"			,nI)										,Nil},; 	// Quantidade Vendida	 	(OK)
				{"C6_ACONDIC"	,GDFieldGet("C6_ACONDIC"		,nI)										,Nil},; 	// Acondicionamento		 	(OK)
				{"C6_LANCES"	,GDFieldGet("C6_LANCES"			,nI)										,Nil},; 	// Lances				 	(OK)
				{"C6_METRAGE"	,GDFieldGet("C6_METRAGE"		,nI)										,Nil},; 	// Metragem				 	(OK)
				{"LINPOS"		,"C6_ITEM", SubStr(GDFieldGet("C6_ZZPVORI"	,nI),7,TamSX3("C6_ITEM")[1])	,Nil},;
				{"AUTDELETA"	,"S"																		,Nil} } )	//Deletar do pedido

			EndIf
		Next
		DbSelectArea("SC9")
		SC9->(DbSeek(FWCodFil() + cPedInd))

		While SC9->(!Eof()) .AND. SC9->C9_FILIAL == FWCodFil() .AND. SC9->C9_PEDIDO == cPedInd
			SC9->(A460Estorna())
			SC9->(DbSkip())
		EndDo

		DbSelectArea("SC5")
		SC5->(DbSeek(FWCodFil() + cPedInd,.F.))
		reclock("SC5", .F.)
		SC5->(C5_LIBEROK) := ""
		SC5->(Msunlock())

		SC6->(DbSeek(FWCodFil()+SC5->(C5_NUM),.F.))
		While SC6->C6_FILIAL == FWCodFil() .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())
			reclock("SC6", .F.)
			SC6->(C6_QTDLIB) := 0
			SC6->(C6_QTDEMP) := 0
			SC6->(Msunlock())
			SC6->(DbSkip())
		EndDo

		Begin Transaction
			MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItens,5)

			If lMsErroAuto
				u_envmail({"wfti@cobrecom.com.br"}, "[Erro] - MSExecAuto - Sincronizar Exclusão 3L  x INDL-ITU", {"Rotina","Linha","Função","Fonte","Obs"},{{"Mata410",cValToChar(ProcLine(0)),"pedIndl()","PEDINDL.PRW",MostraErro()}} )
				DisarmTransaction()
				u_autoAlert("[Erro] - Ao deletar o pedido Nro. " + cPedInd + " de INDL-ITU")
				lRet := .F.
			EndIf
		End Transaction

		//Volta a empresa original
		cNumEmp := cBkNmEmp
		cFilAnt := Substr(cNumEmp,3,2)
		SM0->(DbSeek(Left(cNumEmp,4),.F.))

	EndIf

	RestArea(aSC6)
	RestArea(aSC5)
	RestArea(aSA1)
	RestArea(aArea)

	Return(lRet)


	**********************
User Function sAltPed(aCols, aHeader)  //u_sAltPed()
	**********************
	//Esta função deve sincronizar alterações no (pedido 3L) com o pedido de (INDL ITU)
	//Adotando a premissa de que alterou algo em 3L deve se deletar o item no pedido de (INDL ITU)
	//Caso a alteração seja e todos os Itens do Pedido de (INDL ITU), deve- se deletar o pedido inteiro

	Local aArea			:= GetArea()
	Local aSA1			:= SA1->(GetArea())
	Local aSC5 			:= SC5->(GetArea())
	Local aSC6			:= SC6->(GetArea())
	Local aSB2			:= SB2->(GetArea())
	Local aSC9			:= SC9->(GetArea())
	Local aCabec		:={}
	Local aItens		:={}
	Local cPedInd		:=""
	Local aIND			:={}
	Local aPvOri		:={}
	Local nI
	Local nAlt			:= 0
	Local cBkNmEmp
	Local cLog			:= ""
	Local cBkRisco		:= ""
	Local lRet			:= .T.
	Private lMsErroAuto := .F.

	For nI:= 1 To Len(aCols)

		If !Empty(GDFieldGet("C6_ZZPVORI",nI))

			If U_vPedReg({"podeAlterar",{aCols[nI]},"" }) .And. (u_temAlt({aCols[nI]}) .Or. GDDeleted(nI))
				nAlt++

				aAdd(aItens, {	{"LINPOS"		,"C6_ITEM", SubStr(GDFieldGet("C6_ZZPVORI"	,nI),7,TamSX3("C6_ITEM")[1])	,Nil},; 	// Filial Item				(OK)
				{"AUTDELETA"	,"S"																		,Nil} } )					//Deletar do pedido

				//Array com pedido item de industrialização
				aAdd(aPvOri,GDFieldGet("C6_ZZPVORI",nI))

				//Todos itens alterados no ped 3L devem ser deltados ped INDL-ITU, e o campo ZZPVORI tambem
				//Verificar se mantem este bloco
				SC6->( dbgoto( GDFieldGet("C6_REC_WT",nI) ) )
				reclock("SC6", .F.)
				SC6->C6_ZZPVORI := ""
				SC6->C6_SEMANA := ""
				SC6->(Msunlock())
				//#

				cPedInd := SubStr(GDFieldGet("C6_ZZPVORI"	,nI),1,TamSX3("C6_NUM")[1])

				GdFieldPut("C6_ZZPVORI"	,"", nI)

				//LEONARDO 28/04 - Quando pedido 3L´é alterado os itens que
				//são alterados caso existam em Itu(ZZPVORI) são deletados
				//e o campo semana do pedido de 3L é limpo, pois inicia-se
				//um novo processo com um novo item
				//quando o C6_SEMANA for TAUTOM significa que o novo item
				//deverá ser transferido ITU->3L, por isso não pode limpar
				If Alltrim(GDFieldGet("C6_SEMANA",nI)) # 'TAUTOM'
					GdFieldPut("C6_SEMANA"	,"", nI)
				EndIf

			EndIf
		EndIf

	Next nI

	If !Empty(cPedInd)

		//Array retorno aINDL[1] = Logico Sucesso(.T.=OK, .F. = Erro) aINDL[2] = MaxItem, aINDL[3] = qtdItem
		aIND 	:= U_maiorItem(cPedInd,.F.,'01' ) //Filtra Deletados

		//Troca a filial para o novo pedido
		cBkNmEmp := cNumEmp
		cNumEmp := Left("0101"+Space(Len(cNumEmp)),Len(cNumEmp))
		cFilAnt := "01"
		SM0->(DbSeek(Left(cNumEmp,4),.F.))

		aCabec := {	{"C5_FILIAL","01"	,Nil},; 	// Filial Pedido		(OK)
		{"C5_NUM"	,cPedInd 			,Nil},; 	// Numero do Pedido		(OK)
		{"C5_TIPO"	,"N"				,Nil} } 	// Tipo do Pedido		(OK)

		//Quantidade de itens alterados igual a quantidade de itens total do pedido (Deletar pedido inteiro)
		If nAlt == aIND[3]

			//Não pode exluir quando pedido tem itens liberados (Verificar Estorna Liberação)
			DbSelectArea("SC9")
			SC9->(DbSeek(FWCodFil() + cPedInd))

			While SC9->(!Eof()) .AND. SC9->C9_FILIAL == FWCodFil() .AND. SC9->C9_PEDIDO == cPedInd
				SC9->(A460Estorna())
				SC9->(DbSkip())
			EndDo

			DbSelectArea("SC5")
			SC5->(DbSeek(FWCodFil() + cPedInd,.F.))
			reclock("SC5", .F.)
			SC5->(C5_LIBEROK) := ""
			SC5->(Msunlock())

			SC6->(DbSeek(FWCodFil()+SC5->(C5_NUM),.F.))
			While SC6->C6_FILIAL == FWCodFil() .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())
				reclock("SC6", .F.)
				SC6->(C6_QTDLIB) := 0
				SC6->(C6_QTDEMP) := 0
				SC6->(Msunlock())
				SC6->(DbSkip())
			EndDo

			Begin Transaction
				MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItens,5)

				If lMsErroAuto
					u_envmail({"wfti@cobrecom.com.br"}, "[Erro] - MSExecAuto - Sincronizar Alteração 3L  x INDL-ITU", {"Rotina","Linha","Função","Fonte","Obs"},{{"Mata410",cValToChar(ProcLine(0)),"pedIndl()","PEDINDL.PRW",MostraErro()}} )
					DisarmTransaction()
					lRet := .F.
					u_autoAlert("[Erro] - Ao Sincronizar com o pedido Nro. " + cPedInd + " de INDL-ITU")
				EndIf
			End Transaction

			//Deletar somente os alterados quando menor que o total de itens do pedido
		Else
			//DELETAR ITENS PED(ITU) ONDE OS ITENS CORRESPONDENTES PED 3L SOFRERAM ALTERAÇÔES
			DbSelectArea("SC5")
			If SC5->(DbSeek(FWCodFil() + cPedInd,.F.))

				_cLiberok := SC5->(C5_LIBEROK)
				_nC6Tot := 0
				For nY:= 1 To Len(aPvOri)

					DbSelectArea("SC9")
					SC9->(DbSetOrder(1)) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

					If SC9->(DbSeek(FWCodFil() + aPvOri[nY]))
						SC9->(A460Estorna())
					EndIf

					DbSelectArea("SC6")
					SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM
					If SC6->(DbSeek(FWCodFil() + aPvOri[nY]))

						DbSelectArea("SB2")
						SB2->(DbSetOrder(1)) //B2_FILIAL, B2_COD, B2_LOCAL
						If SB2->(DbSeek(FWCodFil()+SC6->(C6_PRODUTO)+SC6->(C6_LOCAL),.F.))
							reclock("SB2", .F.)
							SB2->(B2_QPEDVEN) := (SB2->(B2_QPEDVEN) - SC6->(C6_QTDVEN) )
							SB2->(Msunlock())
						EndIF

					EndIf
					_nC6Tot += SC6->(C6_VALOR)

					reclock("SC6", .F.)
					SC6->(DbDelete())
					SC6->(Msunlock())

				Next nY

				reclock("SC5", .F.)
				SC5->(C5_TOTAL) 	:= ( SC5->(C5_TOTAL) - _nC6Tot )
				SC5->(C5_LIBEROK) 	:= _cLiberok
				SC5->(Msunlock())

				DbSelectArea("SA1")
				SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
				If SA1->(DbSeek(xFilial("SA1")+SC5->(C5_CLIENTE)+SC5->(C5_LOJACLI),.F.))
					reclock("SA1",.F.)
					SA1->(A1_SALPED) := ( SA1->(A1_SALPED) - _nC6Tot )
					SA1->(MsUnlock())
				EndIF

			Else

				lRet := .F.

			EndIf
		EndIf

		//Volta a empresa original
		cNumEmp := cBkNmEmp
		cFilAnt := Substr(cNumEmp,3,2)
		SM0->(DbSeek(Left(cNumEmp,4),.F.))

	EndIf


	RestArea(aSC9)
	RestArea(aSB2)
	RestArea(aSC6)
	RestArea(aSC5)
	RestArea(aSA1)
	RestArea(aArea)

	Return (lRet)



	**********************
Static Function foiAlt()
	**********************
	//Função que retorna se houve alteração entre a SC6 pedido de 3L com o SC6 pedido INDL-ITU
	//Nos campos importantes (Não valida todos os campos)
	//Vem posiconado no arquivo TRPED->(C6_CAMPO)
	//Retorna se 3L esta diferente de INDL-ITU, impedindo de adicionar no array MsexecAuto de alteração, itens sem alteração
	//que por sua vez não altera liberações SC9 já existentes.
	Local _aArea			:= GetArea()
	Local _aSC6			:= SC6->(GetArea())
	Local lRet 			:= .F.
	Local aC6INDL 		:={}
	/*
	Pata campos do ( TRPED->(CAMPO) ) verifica função que cria este arquivo trbPed()
	*/
	aC6INDL := GetAdvFVal("SC6",{"C6_PRODUTO", "C6_QTDVEN","C6_ACONDIC","C6_LANCES","C6_METRAGE"},;
	xFilial("SC6")+TRPED->(C6_ZZPVORI),1,{"","","","",""} )
	If !Empty(aC6INDL)

		If SubStr(TRPED->(C6_PRODUTO),1,10) # SubStr(aC6INDL[1],1,10)
			lRet := .T.
		ElseIf   TRPED->(C6_QTDVEN) 	#	aC6INDL[2]
			lRet := .T.
		ElseIf   TRPED->(C6_ACONDIC) 	#  	aC6INDL[3]
			lRet := .T.
		ElseIf   TRPED->(C6_LANCES) 	#  	aC6INDL[4]
			lRet := .T.
		ElseIf   TRPED->(C6_METRAGE) 	#  	aC6INDL[5]
			lRet := .T.
		EndIf

	EndIf

	RestArea(_aSC6)
	RestArea(_aArea)
	Return (lRet)

	**********************
User Function temAlt(aCTela)
	**********************
	//Função que retorna se houve alteração entre a tela(M ou aCols) e a tabela (BD)
	//Nos campos importantes (Não valida todos os campos)
	Local _aArea			:= GetArea()
	Local _aSC6				:= SC6->(GetArea())
	Local lRet := .F.

	SC6->( dbgoto( GDFieldGet("C6_REC_WT",1,,, aCTela)  ) )

	If SubStr(SC6->(C6_PRODUTO),1,10) # SubStr(GDFieldGet("C6_PRODUTO",1,,, aCTela),1,10)
		lRet := .T.
	ElseIf   SC6->(C6_QTDVEN) 	#	GDFieldGet("C6_QTDVEN"	,1,,, aCTela)
		lRet := .T.
	ElseIf   SC6->(C6_ACONDIC) 	#  	GDFieldGet("C6_ACONDIC"	,1,,, aCTela)
		lRet := .T.
	ElseIf   SC6->(C6_LANCES) 	#  	GDFieldGet("C6_LANCES"	,1,,, aCTela)
		lRet := .T.
	ElseIf   SC6->(C6_METRAGE) 	#  	GDFieldGet("C6_METRAGE"	,1,,, aCTela)
		lRet := .T.
	ElseIf   SC6->(C6_TES) 		#  	GDFieldGet("C6_TES"	,1,,, aCTela)
		lRet := .T.
	EndIf

	RestArea(_aSC6)
	RestArea(_aArea)

	Return (lRet)


	**********************
User Function maiorItem(cNumPed, lDel, cFil)  //u_maiorItem(cNumPed)
	**********************
	//Esta função devolve o maior numero do item de um pedido. ( lDel (.T.)=Não Filtra Deletados (.F.)=Filtra considera
	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local aRet		:={} //Array retorno aRet[1] = Logico Sucesso(.T.=OK, .F. = Erro) aRet[2] = MaxItem, aRet[3] = qtdItem

	//Padrão Não filtrar os deletados
	Default lDel := .T.

	If Select("TRITEM") > 0
		DbSelectArea("TRITEM")
		TRITEM->(dbclosearea())
		FErase( "TRITEM" + GetDbExtension())
	EndIf

	cQuery += " SELECT MAX(C6_ITEM) AS maxItem,"
	cQuery += " COUNT(*) AS qtdItem "
	cQuery += " FROM "+RetSqlName("SC6")
	cQuery += "	WHERE C6_FILIAL = '" + cFil + "'"
	cQuery += " AND C6_NUM = '" + cNumPed +"'"

	If !lDel
		cQuery += " AND D_E_L_E_T_ <> '*'"
	EndIf
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TRITEM', .F., .T.)

	TRITEM->(DbGoTop())

	If TRITEM->(EOF())

		Aadd(aRet,.F.)

	Else
		Aadd(aRet,.T.)
		Aadd(aRet,Alltrim(TRITEM->(maxItem)))
		Aadd(aRet,TRITEM->(qtdItem))

	EndIf

	TRITEM->(dbCloseArea())
	FErase( "TRITEM" + GetDbExtension())

	RestArea(aArea)
	Return (aRet)


	**********************
User Function vPedReg(aPar)
	**********************
	/*
	Função  para realizar as validações que definem quais pedidos devem ser submetidos as rotinas de filtro e criação de ped INDL-ITU
	basicamente so deve ser filtrados pedido de venda sendo as regras:
	NÂO FAZER quando
	1-(RAIZ CNPJ CLIENTE IGUAL '02544042')......................Pedido entre IFC/Cobrecom Empresas
	2-(TIPO DO PEDIDO C5_TIPO <> 'N')...........................Somente os pedidos normais
	3-(ITEM C6_TES ----> SF4_ESTOQUE ( F4_ESTOQUE ,. 'S').......Item pedido Não Movimenta Estoque

	RETORNA (.T.)= APLICAR ROTINA  (.F.) = NÃO APLICAR ROTINA

	RECEBE:

	aPar[1] = Qual Validação
	aPar[2] = cCliente
	aPar[3] = cLojaCli
	aPar[4] = cTpPed
	aPar[5] = cTesItem

	*/
	Local aArea			:= GetArea()
	Local aSC6			:= SC6->(GetArea())
	Local aSC5			:= SC5->(GetArea())
	Local aSC9			:= SC9->(GetArea())
	Local _cCgc			:= ""
	local cVarejo		:= ""
	Local lRet			:= .T. //Padrão retorna .T.
	Local cLog			:= ""
	
	If aPar[1] == "valArmaz" //chamada Fonte M410LIOK na função MT410TOK (Acerta o armazem Empresa de Produção)
		cVarejo := M->(C5_ZTPVEND)
		_cCgc			:= SubStr(Posicione("SA1",1,xFilial("SA1")+aPar[2]+aPar[3],"A1_CGC"),1,8)
		//turnOff (.T. = Desliga Rotina  .F. Não Desliga Rotina )
		lRet :=  !u_turnOff() .And. (   ( _cCgc # "02544042";
		.And. _cCgc # "43960335";
		.And. _cCgc # "09538989";
		.And. _cCgc # "52189420";
		.And. _cCgc # "08070508";
		.And. _cCgc # "62092739";
		.And. _cCgc # "08619844";
		.And. _cCgc # "33453598";
		) ;
		.And. aPar[4] $ 'N';
		.And. Posicione("SF4",1,xFilial("SF4")+aPar[5],"F4_ESTOQUE") $ "S";
		.and. cVarejo # 'V'    )

	ElseIf aPar[1] == "valCliFil" //(Valida Cliente x Empresa Faturamento)
		
		_cCgc			:= SubStr(Posicione("SA1",1,xFilial("SA1")+aPar[2]+aPar[3],"A1_CGC"),1,8)
		lRet :=  !u_turnOff() .And. ( _cCgc # "02544042";
		.And. _cCgc # "43960335";
		.And. _cCgc # "09538989";
		.And. _cCgc # "52189420";
		.And. _cCgc # "08070508";
		.And. _cCgc # "62092739";
		.And. _cCgc # "08619844";
		.And. _cCgc # "33453598";
		)
		
	ElseIf aPar[1] == "gerIndl" //Se deve gerar pedido INDL-ITU a partir de 3L
		_cCgc			:= SubStr(Posicione("SA1",1,xFilial("SA1")+aPar[2]+aPar[3],"A1_CGC"),1,8)

		//[LEO-JU 01/03/16]-Rotina negociação da Juliana, não pode gerar industrialização quando renegociado
		If SC5->(C5_XNEGOC) == 'S'
			lRet := .F.
			//*
		ElseIf Empty(aPar[2]) .Or. Empty(aPar[3])
			lRet :=  !u_turnOff()

		Else
			lRet := !u_turnOff() .And. ( _cCgc # "02544042";
			.And. _cCgc # "43960335";
			.And. _cCgc # "09538989";
			.And. _cCgc # "52189420";
			.And. _cCgc # "08070508";
			.And. _cCgc # "62092739";
			.And. _cCgc # "08619844";
			.And. _cCgc # "33453598";
			)
		EndIf

		//Validação quando alterar Item pedido 3L verificar a situação do Item no pedido INDL-ITU definindo se pode alterar ou não
		//CHAMADA no LINHAOK e no TUDOOK  SENDO retorno (.T.) = Pode Alterar e (.F.) não pode alterar
	ElseIf aPar[1] == "podeAlterar" .And. !u_turnOff() .And. FWCodFil() == "02" .And. !Empty(GDFieldGet("C6_ZZPVORI",1,,, aPar[2]))
		/*
		RECEBE
		aPar[1] = Qual Validação
		aPar[2] = aCols (Com as informações do item utilizar em conjunto aHeaer)
		aPar[3] = Identifica validar para deletar ("Del")
		GDFieldGet("C6_PRODUTO",1,,, aPar[2])
		MESMAS VALIDAÇÕES UTILIZADAS NO PONTO DE ENTRADA M410ALOK()
		*/
		//****    Validação para o PEDIDO
		DbSelectArea("SC5")
		DbSetOrder(1) //C5_FILIAL+C5_NUM
		SC5->(DbSeek('01' + SubStr(GDFieldGet("C6_ZZPVORI",1,,, aPar[2]),1,6), .T.) )

		If SC5->C5_SEMANA == Replicate("X",Len(SC5->C5_SEMANA))
			lRet := .F.
		ElseIf SC5->C5_DTPCP # Date()
			If !Empty(SC5->C5_SEMANA)
				lRet 	:= .F.
			EndIf
		EndIf
		/*
		If SC5->C5_ZSTATUS # "0"// No SC5->C5_ZSTATUS -> 0=Normal;1=Em Separacäo;2=Em Faturamento
		lRet := .F.
		EndIf
		*/
		If 	SC5->(C5_DTVEN) # Date()
			SC6->(DbSetOrder(1)) //C6_FILIAL+C6_NUM+C6_ITEM
			SC6->(DbSeek('01'+ GDFieldGet("C6_ZZPVORI",1,,, aPar[2]), .T.))

			If SC6->C6_QTDENT > 0 // Tem quantidade faturada
				lRet := .F.
			ElseIf SC6->C6_XNEGOC $ "12345" // Pedido em fase de negociação
				lRet := .F.
			ElseIf Left(SC6->C6_SEMANA,1) == "T" // Foi solicitado transferência de materiais para a outra unidade
				lRet := .F.
			ElseIf "Del" $ aPar[3] .And. Alltrim(SC6->C6_SEMANA) $ "RESERVA//ZP4//r" // Avalia somente se for exclusão?
				lRet := .F.
			ElseIf Empty(Posicione("SC9",1,'01' + GDFieldGet("C6_ZZPVORI",1,,, aPar[2]),"C9_BLEST"))
				lRet := .F.
			Endif

		EndIf
	EndIf

	RestArea(aSC9)
	RestArea(aSC5)
	RestArea(aSC6)
	RestArea(aArea)

	Return (lRet)



User Function turnOff()
	/*
	Como emergencia foi criado um grupo chamado: (LIBREGRA), o numero de ID deste grupo foi armazenado no parametro:(MV_LIBREGR)
	Esta função inicia .F. e percorre todos os grupos que o usuario corrente faz parte caso encontre o grupo (LIBREGRA), devolve .T.
	ou seja a este usuario não deve aplicar-se os filtros. (Sendo desligaFiltro (.T. ou .F.)

	Para adicionar usuarios a esta exceção deve-se adicio0nar o usuario ao grupo.

	*** VER PARA DESLIGAR GERAL ***
	MV_OFFREGR (.T. =Desliga Geral   .F. Liga Geral)
	*/
	Local cMV1
	Local lOffR
	Local lOff
	local oAcl	:= nil
	
	cMV1	:= Alltrim(GetMV("MV_LIBREGR"))	//Grupo de usuarios que não devem passar pelas validações
	lOffR	:= GetMV("MV_OFFREGR")			//Parametro Logico - Desliga regra para geral
	lOff 	:= .F.							//deve aplicar regras de filtro

	//Vazio assume falso como padrão
	If ValType(lOffR) != "L"

		lOffR := .F.

	EndIF

	//Desliga a regra de forma geral
	If lOffR

		lOff := .T.

		//Desliga a regra para usuario do grupo "LIBREGRA"
	ElseIf !Empty(cMV1)
		
		oAcl := cbcAcl():newcbcAcl()
			if oAcl:usrIsGrp({cMV1})
				lOff := .T.
			endif
		FreeObj(oAcl)
		
	EndIf

	Return lOff

	/*********************************************************************************PONTOS ENTRADA LIBERAÇÂO CREDITO (MOMENTO EM QUE É GERADO PEDIDO INDUSTRIALIZAÇÂO EM ITU*****************************/

	**********************
	//MT440LIB() //- Liberação de vendas / Tratar Lib.Credito Cliente Risco-A Esta no fonte CDGEn21 coloquei minha chamada nele
	//Automatico OK
	**********************

	**********************
	//MT440GR() //- Liberação de vendas / Tratar Lib.Credito Cliente Risco-A Esta no fonte PE_MATA440 coloquei minha chamada nele
	//Manual OK
	**********************

	**********************
User Function MT450FIM() //OK - An. Credito Pedido - Manual - Lib. Todos
	**********************
	Local aAreaL 	:= getArea()
	Local myaSC6	:= SC6->(Getarea())
	Local myaSC5	:= SC5->(Getarea())
	Local cNroPed	:= Paramixb[1]
	
	U_CDAgreg(Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE)+SC5->(C5_LOJACLI),"A1_AGREG")) 
	
	If   !_SetAutoMode() .And. FWCodFil() == "02" .And. SC5->(C5_TIPO) $ 'N'

		u_pedIndl()

	EndIf

	RestArea(myaSC5)
	RestArea(myaSC6)
	RestArea(aAreaL)
	Return(Nil)

	**********************
	//MTA450I() // - An. Credito Pedido - Manual -  (Libera apenas um item) Esta no fonte CDGEn21 coloquei minha chamada nele
	**********************

	**********************
User Function MTA450T() // - An. Credito Cliente / Pedido - Automatica
	**********************
	Local aAreaL 	:= getArea()
	Local myaSC6	:= SC6->(Getarea())
	Local myaSC5	:= SC5->(Getarea())
	
	U_CDAgreg(Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE)+SC5->(C5_LOJACLI),"A1_AGREG")) 

	If   !_SetAutoMode() .And. FWCodFil() == "02" .And. SC5->(C5_TIPO) $ 'N'

		u_pedIndl()

	EndIf


	RestArea(myaSC5)
	RestArea(myaSC6)
	RestArea(aAreaL)
	Return(Nil)

	**********************
User Function MTA450CL() //Ok - An. Credito Cliente - Manual
	**********************
	Local aAreaL 	:= getArea()
	Local myaSC6	:= SC6->(Getarea())
	Local myaSC5	:= SC5->(Getarea())

	//SOMENTE LIBERAÇÂO
	If PARAMIXB[1] == 1
		
		U_CDAgreg(Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE)+SC5->(C5_LOJACLI),"A1_AGREG")) 

		If   !_SetAutoMode() .And. FWCodFil() == "02" .And. SC5->(C5_TIPO) $ 'N'

			u_pedIndl()

		EndIf
	EndIf

	RestArea(myaSC5)
	RestArea(myaSC6)
	RestArea(aAreaL)

Return(.T.)
/***************************************************************************( FIM  )*PONTOS ENTRADA LIBERAÇÂO CREDITO (MOMENTO EM QUE É GERADO PEDIDO INDUSTRIALIZAÇÂO EM ITU**( FIM  )*****************/

Static Function verConFinal(cCli, cLoja, cUFCli, lMsg)
	Local aArea 	:= SA1->(GetArea())
	Local cFinal
	//aRet[1] = è consumidor final e aRet[2] = é funcionario
	Local aRet		:= {.T.,.F.}
	Default lMsg	:= .T.

	cFinal 	:= Posicione("SA1",1,xFilial("SA1")+cCli+cLoja,"A1_TIPO")=="F"
	cPessoa := Posicione("SA1",1,xFilial("SA1")+cCli+cLoja,"A1_PESSOA")=="F"  //.And. cUFCli # 'SP'

	//É Consumidor final
	If   cFinal

		//Se Pessoa Fisica, verificar (não pode funcionario)
		If  cPessoa
			cCGC	:= Posicione("SA1",1,xFilial("SA1")+cCli+cLoja,"A1_CGC")

			DbSelectArea("SRA")
			DbSetOrder(5) //RA_FILIAL+RA_CIC

			If SRA->(DbSeek("01" + Padr(cCGC,TamSX3("A1_CGC")[1]) , .T.) )
				aRet 	:= {.F.,.T.}
			ElseIf SRA->(DbSeek("02" + Padr(cCGC,TamSX3("A1_CGC")[1]) , .T.) )
				aRet 	:= {.F.,.T.}
			Else

				if lMsg
					//Tratar quando for execauto, para não mostrar mensagem
					lRet	:= u_autoAlert("[Pergunta]-Cliente é consumidor final e Pessoa Fisica!, continuar inclusão?",.T.,'MsgBox','Titulo',,'YesNo',.T.)
					aRet	:={.T.,lRet}
				Else
					aRet	:={.T.,.F.}
				EndIf

			EndIf

			//Consumidor Final não é pessoa fisica
		ElseiF cUFCli $ 'SP'
			aRet 	:= {.F.,.F.}
		EndIf

		//Não é Consumidor final
	Else
		aRet 	:= {.F.,.F.}
	EndIf

	RestArea(aArea)
Return(aRet)

/****************************************************************************************************************/
User Function PE410SYNC()
	lRet := .T.

	//Somente quando vier da efetivação de um orçamento (acessos ao dados do pedido pela variavel "M->" )
	If IsInCallStack('MABXORC')
		//Levar campos do CJ para o C5
		IF SCJ->(CJ_ZZSTS) == 'A'
			M->(C5_ZZAPR) 	:= SCJ->(CJ_ZZAPR)
			M->(C5_ZZREGAP)	:= SCJ->(CJ_ZZREGAP)
		EndIf
	EndIf

Return (lRet)

/*
FUNÇÂO CHAMADA DO PONTO DE ENTRADA A415TdOk() aGets,aTela
*/
User Function PE410REGRA()
	Local cRegSol 	:= ""
	Local cNomCli	:= ""
	Local cAssina	:= ""
	Local dDt		:= ""
	Local dHora		:= ""
	Local cConstru	:= ""
	Local cFinal 	:= ""
	Local lRet		:= .T.


	if Altera .And. M->(CJ_ZZSTS) $ "A"
			
		If u_autoAlert("[AVISO] - Aprovação da regra de triangulaçao para este orçamento será cancelada, deseja continuar?",.T.,'MsgBox','Titulo',,'YesNo',.T.) 
			M->(CJ_ZZSTS) 	:= ""
			M->(CJ_ZZAPR) 	:= ""
			M->(CJ_MAILRET)	:= ""
			M->(CJ_ZZREGAP)	:= ""
			M->(CJ_ZZREG)	:= ""
		Else
			lRet := .F.
		EndIf

	ElseIf Altera .And. M->(CJ_ZZSTS) $ "S"
		u_autoAlert('[AVISO] - Somente pode-se alterar orçamento quando não existir regra de triangulação (Pendente ou Aprovada)',,'Box')
		lRet := .F.
	Else
		if !Empty(M->(CJ_ZZREG))

			if  M->(CJ_ZZSTS) $ "R" .Or. Empty(M->(CJ_ZZSTS))

				PswOrder(2)
				lAchou	:= PSWSeek(cUserName)
				aUserFi	:= PswRet(1)

				M->(CJ_ZZSTS) := "S"
				M->(CJ_ZZAPR) := M->(CJ_ZZREG)
				M->(CJ_MAILRET) := Alltrim(aUserFi[1][14])

				cRegSol 	:= Alltrim(posicione("SX5",1,XFILIAL("SX5")+'Z7'+M->CJ_ZZAPR,"X5_DESCRI"))
				cNomCli 	:= Alltrim(POSICIONE("SA1",1,XFILIAL("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_NOME") )
				cAssina 	:= Alltrim( UsrRetName(__CUSERID))
				dDt			:= cValToChar(Date())
				dHora		:= cValToChar(Time())
				cUFCli    	:= Alltrim(Posicione("SA1",1,xFilial("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_EST"))

				If Posicione("SA1",1,xFilial("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_CONTRUT")=="S" .And. cUFCli # 'SP'
					cConstru := "SIM"
				else
					cConstru := "NÃO"
				EndIf

				if Posicione("SA1",1,xFilial("SA1")+M->CJ_CLIENTE+M->CJ_LOJA,"A1_TIPO")=="F"
					cFinal := "SIM"
				else
					cFinal := "NÃO"
				EndIf

				//Enviar e-mail
				aEmail := { {Alltrim(M->(CJ_NUM)), cNomCli, cUFCli, cConstru, cFinal, cRegSol, cAssina, dDt, dHora }  }
				u_envmail({ GetMV("MV_MAILAPR") }, "[SOLICITAÇÃO DE APROVAÇÃO DE REGRA] - ORÇ. NRO. " + Alltrim(M->(CJ_NUM)), {"Orçamento","Cliente","Estado","Construtora", "Cons.Final", "Regra", "Solicitante", "Data", "Hora"},aEmail)

			endIf
		endIf

	EndIf

Return (lRet)


Static Function fromJson(cReg)
	Local oObj
	/*
	Devolve um objeto json com a configuração a ser aplicada no pedido
	modelo string json
	{"regra": {"fatura": "01", "armazem": "01" , "semana": "", "div_valor": "F", "t3lag": "F" } }
	*/
	FWJsonDeserialize( Alltrim(GetMv("MV_TRI" +cReg )),@oObj)

Return (oObj)


User Function M415COPIA
	Local lRet := .T.
	Local aArea := Getarea()

	If SCJ->CJ_ZZSTS $ 'A'

		If !_SetAutoMode()

			MessageBox("[AVISO] - Orçamento contem uma regra de triangulação aprovada, desta forma não pode ser copiado","Regra Triangulação",16)

		EndIf

		lRet := .F.

	EndIf

	RestArea(aArea)
Return (lRet)
