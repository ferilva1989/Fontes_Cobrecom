#include "PROTHEUS.CH"
#Include "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LTROCATAB ºAutor  ³Leonardo Bolognesi  º Data ³  23/04/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Utilização para manutenção das tabelas de descontos         º±±
±±º          ³ nos pedidos e clientes  "uso exclusivo Denise"            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºTabela utilizadas                                                      º±±
±±SA1 (Clientes) - Campos alterados no processo ( A1_DESCQTD, A1_DESCVLR) º±±
±±SC5 (Pedidos)  - Campos alterados no processo ( C5_DESCEQT, C5_DESCESP) º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
CLASS lTabela
	//ATRIBUTOS DA CLASSE
	DATA cC5NUM
	DATA cC5CLIENTE
	DATA cC5LOJACLI
	DATA nC5DESCESP
	DATA nC5DESCEQT
	DATA cA1NOME
	DATA nA1DESCQTD
	DATA nA1DESCVLR
	DATA nTabela
	DATA cTpDesc
	DATA lRetOk
	DATA dC5ENTREG
	DATA cC5Tipo
	DATA cCondPag
	DATA mObs

	//METODOS DA CLASSE
	METHOD Create() CONSTRUCTOR
	METHOD Atualiza()
	METHOD gravaPedido()
	METHOD gravaCondPag()
	METHOD alteraCliente()
	METHOD gravaLog()

ENDCLASS

METHOD Create() CLASS lTabela
	//CONSTRUTOR DA CLASSE
RETURN SELF

//GRAVA OS LOGS DOS EVENTOS
//RECEBE PARAMETRO O IDENTIFICADOR DO EVENTO
METHOD gravaLog(cEvento, cNova) CLASS lTabela
	Local aDadC5
	Default cNova := "" //PARAMETRO ALTERAÇÃO EM COND PAGAMENTO

	//ALTERAÇÃO NO PEDIDO EVENTO 13
	if cEvento == "13"
		aDadC5 := {::cC5NUM,::cC5CLIENTE, ::cC5LOJACLI,::dC5ENTREG ,::cC5Tipo,"", ::mObs}

		//PARAMETRO ALTERAÇÃO EM COND PAGAMENTO
		if !Empty(cNova)

			U_CDGEN21I(13,"C5_CONDPAG",::cCondPag, cNova, aDadC5 )

		EndIf

		if ::nTabela == 0 .or. ::nTabela == 100

			//ALTERAÇÕES REALIZADAS
			//SC5->C5_DESCEQT := 0
			//SC5->C5_DESCESP := 0
			if ::nC5DESCEQT != 0
				U_CDGEN21I(13,"C5_DESCEQT",str(::nC5DESCEQT,3), "0", aDadC5 )
			endif
			if ::nC5DESCESP != 0
				U_CDGEN21I(13,"C5_DESCESP",str(::nC5DESCESP,3), "0", aDadC5 )
			endif

		elseif ::cTpDesc == "QTD"
			//ALTERAÇÕES REALIZADAS
			//SC5->C5_DESCEQT := ::nTabela
			//SC5->C5_DESCESP := 0
			if ::nC5DESCEQT != ::nTabela
				U_CDGEN21I(13,"C5_DESCEQT",str(::nC5DESCEQT,3), str(::nTabela,3), aDadC5 )
			endif
			if ::nC5DESCESP != 0
				U_CDGEN21I(13,"C5_DESCESP",str(::nC5DESCESP,3), "0", aDadC5 )
			endif

		elseif ::cTpDesc == "VLR"
			//ALTERAÇÕES REALIZADAS
			//SC5->C5_DESCESP := ::nTabela
			//SC5->C5_DESCEQT := 0
			if ::nC5DESCESP != ::nTabela
				U_CDGEN21I(13,"C5_DESCESP",str(::nC5DESCESP,3), str(::nTabela,3), aDadC5 )
			endif
			if ::nC5DESCEQT != 0
				U_CDGEN21I(13,"C5_DESCEQT",str(::nC5DESCEQT,3), "0", aDadC5 )
			endif

		endif
		//ALTERAÇÃO NO CLIENTE
	elseif cEvento == "14" 
		if ::nTabela == 0 .or. ::nTabela == 100
			//ALTERAÇÕES REALIZADAS
			//SA1->A1_DESCQTD := 100
			//SA1->A1_DESCVLR := 100
			if ::nA1DESCQTD != 100
				U_GrvZZ1({::cC5CLIENTE,::cC5LOJACLI},"A1_DESCQTD", {str(::nA1DESCQTD,3),"100"}, 'Alterar', ::mObs )
			endif
			if ::nA1DESCVLR != 100
				U_GrvZZ1({::cC5CLIENTE,::cC5LOJACLI},"A1_DESCVLR", {str(::nA1DESCVLR,3),"100"}, 'Alterar', ::mObs )
			endif
		elseif ::cTpDesc == "QTD"
			//ALTERAÇÕES REALIZADAS
			//SA1->A1_DESCQTD := ::nTabela
			//SA1->A1_DESCVLR := 0
			if ::nA1DESCQTD != ::nTabela
				U_GrvZZ1({::cC5CLIENTE,::cC5LOJACLI},"A1_DESCQTD", {str(::nA1DESCQTD,3),str(::nTabela,3)}, 'Alterar', ::mObs )
			endif
			if ::nA1DESCVLR != 0
				U_GrvZZ1({::cC5CLIENTE,::cC5LOJACLI},"A1_DESCVLR", {str(::nA1DESCVLR,3),"0"}, 'Alterar', ::mObs )
			endif

		elseif ::cTpDesc == "VLR"
			//ALTERAÇÕES REALIZADAS
			//SA1->A1_DESCVLR := ::nTabela
			//SA1->A1_DESCQTD := 0
			if ::nA1DESCVLR != ::nTabela
				U_GrvZZ1({::cC5CLIENTE,::cC5LOJACLI},"A1_DESCVLR", {str(::nA1DESCVLR,3),str(::nTabela,3)}, 'Alterar', ::mObs )
			endif
			if ::nA1DESCQTD != 0
				U_GrvZZ1({::cC5CLIENTE,::cC5LOJACLI},"A1_DESCQTD", {str(::nA1DESCQTD,3),"0"}, 'Alterar', ::mObs )
			endif
		endif
	endif
RETURN

//METODO PARA ALTERAR/TRAVAR A TABELA DO CLIENTE EVENTO DE LOG É 14
METHOD alteraCliente(cCodCli, cLojaCli, nTabela, cTpDesc) CLASS lTabela
	//Evento do log é 14
	Local aArea := GETAREA()
	default cCodCli		:= ::cC5CLIENTE
	default cLojaCli	:= ::cC5LOJACLI
	default nTabela		:= ::nTabela
	default cTpDesc		:= ::cTpDesc
	
	dbselectarea("SA1")
	SA1->(dbsetorder(1)) //A1_FILIAL, A1_COD

	if SA1->(dbseek(xFilial("SA1")+ cCodCli + cLojaCli, .f.))
		if nTabela == 0 .or. nTabela == 100 //ALTERAÇÃO PARA TABELA E/Z O QUE MUDA È O TES
			reclock("SA1",.f.)
			SA1->A1_DESCQTD := 100
			SA1->A1_DESCVLR := 100
		elseif cTpDesc == "QTD" //TABELA DESCONTO NA QUANTIDADE
			reclock("SA1",.F.)
			SA1->A1_DESCQTD := nTabela //VALOR INFORMADO PELO USUARIO MESMO DO PEDIDO
			SA1->A1_DESCVLR := 100//CONCEITO LIGA UM DESLIGA OUTRO
		elseif cTpDesc == "VLR" //TABELA DESCONTO NO VALOR
			reclock("SA1",.f.)
			SA1->A1_DESCVLR := nTabela //VALOR INFORMADO PELO USUARIO MESMO DO PEDIDO
			SA1->A1_DESCQTD := 100//CONCEITO LIGA UM DESLIGA OUTRO
		endif
		MessageBox("Cliente alterado","Alteração Tabela Cliente",64)
		SA1->(msunlock())
	else
		MessageBox("Cliente nao encontrado","Erro",16)

	endif

	SA1->(RESTAREA(aArea))
	//GRAVA O LOG
	SELF:gravaLog("14")
	
RETURN


//METODO PARA ALTERAR A TABELA DO PEDIDO EVENTO DE LOG É 13
METHOD gravaCondPag(cNova)CLASS lTabela
	Local cLinha := Chr(13)
	Local aArea := GETAREA()

	dbselectarea("SC5")
	SC5->(dbsetorder(1)) //C5_FILIAL, C5_NUM

	if SC5->(dbseek(xFilial("SC5")+::cC5NUM, .F.))

		reclock("SC5",.F.)
		SC5->C5_CONDPAG := cNova
		SC5->(msunlock())

		//GRAVA O LOG
		SELF:gravaLog("13",cNova)

		MessageBox("[AVISO] - Alteração Realizada", "Aviso", 01)

	else
		MessageBox("Pedido não encontrado","Erro",16)
	endif

	RESTAREA(aArea)

RETURN

//METODO PARA ALTERAR A TABELA DO PEDIDO EVENTO DE LOG É 13
METHOD gravaPedido()CLASS lTabela
	Local cLinha := Chr(13)
	Local aArea := GETAREA()

	dbselectarea("SC5")
	SC5->(dbsetorder(1)) //C5_FILIAL, C5_NUM

	if SC5->(dbseek(xFilial("SC5")+::cC5NUM, .f.))
		if ::nTabela == 0 .or. ::nTabela == 100  //ALTERAÇÃO PARA A TABELA E/Z - O QUE DEFINE È O TES
			reclock("SC5",.f.)
			SC5->C5_DESCEQT := 0
			SC5->C5_DESCESP := 0
		elseif ::cTpDesc == "QTD"//ALTERAÇÃO PARA QUANTIDADE
			reclock("SC5",.f.)
			SC5->C5_DESCEQT := ::nTabela//VALOR INFORMADO PELO USUARIO
			SC5->C5_DESCESP := 0//CONCEITO LIGA UM DESLIGA OUTRO
		elseif ::cTpDesc == "VLR"
			reclock("SC5",.f.)
			SC5->C5_DESCESP := ::nTabela //VALOR INFORMADO PELO USUARIO
			SC5->C5_DESCEQT := 0//CONCEITO LIGA UM DESLIGA OUTRO
		endif
		SC5->(msunlock())
		//GRAVA O LOG
		SELF:gravaLog("13")
		If ::nTabela == 100
			DbSelectArea("SC6")
			DbSetOrder(1)
			DbSeek(xFilial("SC6") + SC5->C5_NUM,.F.)
			Do While SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())
				RecLock("SC6",.F.)
				If SC6->C6_XOPER == "04" //Bonificação
					SC6->C6_TES		:= "617"
					SC6->C6_TESORI	:= "617"
				Else //Vendas
					SC6->C6_TES		:= "505"
					SC6->C6_TESORI	:= "505"
				Endif
				MsUnLock()
				SC6->(DbSkip())
			EndDo
			DbSelectArea("SC9")
			DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
			DbSeek(xFilial("SC9") + SC5->C5_NUM,.F.)
			Do While SC9->C9_PEDIDO == SC5->C5_NUM .And. SC6->(!Eof())
				If SC9->C9_BLCRED # "10" // Não faturado
					RecLock("SC9",.F.)
					SC9->C9_TES == "505"
					MsUnLock()
				EndIf
				SC9->(DbSkip())
			EndDo
		EndIf
	else
		MessageBox("Pedido não encontrado","Erro",16)
	endif

	RESTAREA(aArea)

RETURN

//ATUALIZA AS INFORMAÇÕES DA CLASSE (ESTRUTURA DE DADOS)
METHOD Atualiza(cNum, nTabela, cTpDesc, cObs) CLASS lTabela
	//ALTERAÇÕES QUE SERÃO REALIZADAS
	::nTabela := nTabela 	//NOVO VALOR DA TABELA
	::cTpDesc := cTpDesc 	//ONDE ALTERAR VALOR OU NA QUANTIDADE
	::mObs	  := cObs	 	// OBSERVAÇÂO DO USUARIO

	BeginSQL Alias "TABCONSULTA"
	column C5_ENTREG as Date

	SELECT SC5.C5_ENTREG, SC5.C5_TIPO, SC5.C5_NUM, SA1.A1_COD, SA1.A1_LOJA, SC5.C5_DESCESP, SC5.C5_DESCEQT,
	SA1.A1_NOME, SA1.A1_DESCQTD, SA1.A1_DESCVLR,SC5.C5_CONDPAG, SC6.C6_TES
	FROM %Table:SC5% SC5
	INNER JOIN %Table:SA1% SA1 ON SC5.C5_CLIENTE+SC5.C5_LOJACLI = SA1.A1_COD + SA1.A1_LOJA
	INNER JOIN %Table:SC6% SC6 ON SC5.C5_FILIAL = SC6.C6_FILIAL AND SC5.C5_NUM = SC6.C6_NUM
	WHERE SC5.C5_FILIAL = %xFilial:SC5% AND SC5.C5_NUM = %exp:cNum% AND SC5.%NotDel% AND SC6.%NotDel%
	ORDER BY %Order:SC5,1%

	EndSql

	_lRetOk := .T.
	dbselectarea("TABCONSULTA")//ARQUIVO TRABALHO COM O RETORNO DO SELECT
	Do While !Eof()
		If TABCONSULTA->C6_TES == "505"
			_lRetOk := .F.
			Exit
		EndIf
		DbSkip()
	EndDo

	DbGoTop()

	if !TABCONSULTA->(Eof())
		//CARREGA AS INFORMAÇÕES NOS ATRIBUTOS DA CLASSE
		::cC5NUM 	 := TABCONSULTA->C5_NUM
		::cC5CLIENTE := TABCONSULTA->A1_COD
		::cC5LOJACLI := TABCONSULTA->A1_LOJA
		::nC5DESCESP := TABCONSULTA->C5_DESCESP
		::nC5DESCEQT := TABCONSULTA->C5_DESCEQT
		::dC5ENTREG  := TABCONSULTA->C5_ENTREG
		::cC5Tipo	 := TABCONSULTA->C5_TIPO
		::cA1NOME	 := TABCONSULTA->A1_NOME
		::nA1DESCQTD := TABCONSULTA->A1_DESCQTD
		::nA1DESCVLR := TABCONSULTA->A1_DESCVLR
		::cCondPag	 := TABCONSULTA->C5_CONDPAG
		::lRetOk	 := _lRetOk //INDICAR DE SUCESSO NA CARGA DOS DADOS
	else
		::lRetOk	 := .f.//INDICAR DE SUCESSO NA CARGA DOS DADOS
	endif

	dbselectarea("TABCONSULTA")
	dbclosearea("TABCONSULTA")

RETURN

//##FUNÇÃO MAIN - ESTA FUNÇÃO QUE SERÁ CHAMADA NO MENU DO USUARIO, A PARTIR DELA INICIALIZAREMOS AS CLASSES
USER FUNCTION trocaTab()
	local aPergs 	:= {}
	local aRet 		:= {}
	local cCodRec 	:= space(08)
	local cMsg
	local cLinha 	:= Chr(13)
	local nOper
	local nPedido	:= ""
	local cCodCli 	:= space(TamSx3('A1_COD')[1])
	local cLojaCli 	:= space(TamSx3('A1_LOJA')[1])
	local nOpcao	:= 0
	local oSql	  	:= nil
	local oTabela	:= nil

	if !GetNewPar('ZZ_LIGATAB', .F.)
		U_autoAlert(' [AVISO] - ROTINA DESABILITADA !' )
	else		
		//ESTÂNCIA DAS CLASSES COM OS DADOS
		 oTabela := lTabela():Create()
	
		aAdd(aPergs 	,{3	,"Alteração de Tabela:",1,{"PEDIDO","CLIENTE"},80,"",.T.})//aRet[2] RADIOBOX - OBRIGATORIO
	
		If !ParamBox(aPergs ,"Alteração de Tabela...",@aRet)
	
			return .F.
	
		Else
			nOpcao := aRet[1] //SENDO 1=PEDIDO e 2=CLIENTE
			aPergs	:= {}
			aRet	:= {}
	
			// Alterar Pedido
			if nOpcao == 1
	
				aAdd(aPergs 	,{1	,"Nro. Pedido : "	,cCodRec,"@!","ExistCpo('SC5',MV_PAR01,1)",,'.T.',40,.T.})	//aRet[1] TEXTBOX  - OBRIGATORIO
				aAdd(aPergs 	,{3	,"Tipo de Alteração:",1,{"TABELA","COND.PAGAMENTO"},80,"",.T.})					//aRet[2] RADIOBOX - OBRIGATORIO
	
				If ParamBox(aPergs ,"Tipo de alteração...",@aRet)
	
					nPedido := aRet[1]
					nOper	:= aRet[2] //SENDO 1=TABELA e 2=COND.PAGAMENTO
	
					aPergs	:= {}
					aRet	:= {}
	
				Else
	
					return .F.
	
				EndIF
	
				If nOper == 1 //REALIZA A OPERAÇÃO PARA TROCA DE TABELAS
	
					//CARREGA OS ELEMENTOS DA TELA PARA OBTER INFORMAÇÕES
					aAdd(aPergs 	,{1	,"Nro. Pedido : "	,nPedido,"@!",'.T.',,'.T.',40,.T.})					//aRet[1] TEXTBOX  - OBRIGATORIO
					aAdd(aPergs 	,{2	,"Informe a Tabela:",1,{ "A","B","C","D","E","F","Z"},20,"",.T.})		//aRet[2] COMBOBOX - OBRIGATORIO
					aAdd(aPergs 	,{3	,"Tipo do Desconto:",1,{"Quantidade","Valor"},80,"",.T.}) 				//aRet[3] RADIOBOX - OBRIGATORIO
					aAdd(aPergs 	,{3	,"Travar o cliente nesta condição:",1,{"NÃO","SIM"},80,"",.T.}) 		//aRet[4] RADIOBOX - OBRIGATORIO
					aAdd(aPergs     ,{11,"Observações:","",".T.",".T.",.T.}) 									//aRet[5] TEXTMEMO - OBRIGATORIO
	
					//EXIBIR A TELA EM LOOP - AS OPÇÕES ESCOLHIDAS VOLTAM NO PARAMETRO @ARET PASSADO COMO PONTEIRO
					do while ParamBox(aPergs ,"Descontos...",@aRet)
						//ATUALIZA OS ATRIBUTOS DA CLASSE
						oTabela:Atualiza(aRet[1], devolveNumero(aRet[2]), iif(aRet[3] == 1,"QTD","VLR"), aRet[5])
						//VERIFICA SE CARREGOU CORRETAMENTE AS INFORMAÇÕES NA CLASSE
						if oTabela:lRetOk
							//EXIBE AS INFORMAÇÕES E SOLICITA UMA CONFIRMAÇÃO DO USUARIO
							cMsg := "Deseja efetivar as alterações descritas abaixo:"+cLinha
							cMsg += "Nro.Pedido: " + oTabela:cC5NUM + cLinha
							cMsg += "Cliente: " + oTabela:cA1NOME + cLinha+ cLinha
							cMsg += "Tabela Atual do pedido:" + cLinha
							cMsg += str(oTabela:nC5DESCEQT) + " Quantidade  " + str(oTabela:nC5DESCESP) + " Valor  " + cLinha+ cLinha
							cMsg += "Para nova tabela de pedido:" +cLinha
							if oTabela:nTabela == 100
								cMsg += "Tabela Z " + cLinha+ cLinha
							elseif oTabela:nTabela == 0
								cMsg += "Tabela E " + cLinha+ cLinha
							else
								cMsg +=  str(oTabela:nTabela) + " " + IIF(oTabela:cTpDesc =="QTD"," Quantidade  "," Valor  ") + cLinha+ cLinha
							endif
							if aRet[4] != 1 //ALTERAR O CLIENTE
								cMsg +=	"Tabela Atual do Cliente" + cLinha
								cMsg += str(oTabela:nA1DESCQTD) + " Quantidade  " + str(oTabela:nA1DESCVLR) +" Valor  " + cLinha+ cLinha
								cMsg +=	"Nova tabela do Cliente" + cLinha
								if oTabela:nTabela == 100
									cMsg += "Tabela Z " + cLinha+ cLinha
								elseif oTabela:nTabela == 0
									cMsg += "Tabela E " + cLinha+ cLinha
								else
									cMsg +=  str(oTabela:nTabela) + " " + IIF(oTabela:cTpDesc =="QTD"," Quantidade  "," Valor  ") + cLinha+ cLinha
								endif
							endif
							if MsgNoYes(cMsg,"Confirmação")
								if aRet[4] == 1
									//METODO QUE GRAVA O PEDIDO
									oTabela:gravaPedido()
								else
									oTabela:gravaPedido() 	//METODO QUE GRAVA O PEDIDO
									oTabela:alteraCliente() //METODO QUE ALTERA A TABELA DE CLIENTE
								endif
							endif
						else
							MessageBox("Pedido não encontrado ou Como Tabela Z","Erro",16)
						endif
					enddo
	
	
				Else //ALTERAÇÃO NA CONDIÇÃO DE PAGAMENTO
					//CARREGA OS ELEMENTOS DA TELA PARA OBTER INFORMAÇÕES
	
					aAdd(aPergs 	,{1	,"Nro. Pedido :          ",nPedido,"@!","ExistCpo('SC5',MV_PAR01,1)",,'.T.',40,.T.})														//aRet[1] TEXTBOX  - OBRIGATORIO
					aAdd(aPergs 	,{1	,"Nova Cond. Pagamento : ",space(TamSX3('C5_CONDPAG')[1]),"@!","ExistCpo('SE4',MV_PAR02,1)",'SE4','.T.',40,.T.})	//aRet[2] TEXTBOX  - OBRIGATORIO
					aAdd(aPergs     ,{11,"Observações:","",".T.",".T.",.T.})                           														//aRet[3] TEXTMEMO - OBRIGATORIO
	
					Do While	ParamBox(aPergs ,"Cond. Pagamento...",@aRet)
	
	
	
						oTabela:Atualiza()(aRet[1], , ,aRet[3] )
						if oTabela:lRetOk
	
							//EXIBE AS INFORMAÇÕES E SOLICITA UMA CONFIRMAÇÃO DO USUARIO
							cMsg := "Deseja efetivar as alterações descritas abaixo:"+cLinha
							cMsg += "Nro.Pedido: " + oTabela:cC5NUM + cLinha
							cMsg += "Cliente: " + oTabela:cA1NOME + cLinha+ cLinha
							cMsg += "Cond. Pagamento Atual: "
							cMsg += Posicione("SE4",1,xFilial("SE4")+oTabela:cCondPag,"E4_DESCRI")  + cLinha
							cMsg += "Nova Cond. Pagamento: "
							cMsg += Posicione("SE4",1,xFilial("SE4")+aRet[2],"E4_DESCRI")
	
							If MsgNoYes(cMsg,"Confirmação")
	
								oTabela:gravaCondPag(aRet[2])
	
							EndIf
	
						Else
	
							MessageBox("Pedido não encontrado","Erro",16)
	
						EndIf
	
					EndDo
	
				EndIf
	
				// Alterar Cliente
			elseif nOpcao == 2
				aAdd(aPergs 	,{1	,"Cliente : " ,cCodCli  ,"@!",'.T.','SA1','.T.',TamSx3('A1_COD')[1],.T.})	//aRet[1] TEXTBOX  - OBRIGATORIO
				aAdd(aPergs 	,{1	,"Loja : " ,cLojaCli	,"@!",'.T.',,'.T.',TamSx3('A1_LOJA')[1],.T.})		//aRet[2] TEXTBOX  - OBRIGATORIO
				aAdd(aPergs 	,{2	,"Informe a Tabela:",1,{ "A","B","C","D","E","F","Z"},20,"",.T.})			//aRet[3] COMBOBOX - OBRIGATORIO
				aAdd(aPergs 	,{3	,"Tipo do Desconto:",1,{"Quantidade","Valor"},80,"",.T.}) 					//aRet[4] RADIOBOX - OBRIGATORIO
				aAdd(aPergs     ,{11,"Observações:",""	,".T.",".T.",.T.}) 										//aRet[5] TEXTMEMO - OBRIGATORIO
	
				while ParamBox(aPergs ,"Tabela Cliente...",@aRet)
					oSql	  			:= LibSqlObj():newLibSqlObj()
	
					oTabela:cC5NUM 		:= ''
					oTabela:cC5CLIENTE	:= aRet[1]
					oTabela:cC5LOJACLI	:= aRet[2]
					oTabela:mObs		:= aRet[5]
					oTabela:nTabela		:= devolveNumero(aRet[3])
					oTabela:cTpDesc		:= if( aRet[4] == 1, "QTD", "VLR" )
	
					oTabela:nA1DESCQTD := oSql:getFieldValue("SA1", "A1_DESCQTD",;
					" %SA1.XFILIAL% " + ;
					"  AND A1_COD = '" + aRet[1] + "' " +;
					"  AND A1_LOJA = '" + aRet[2] + "' " )
	
					oTabela:nA1DESCVLR := oSql:getFieldValue("SA1", "A1_DESCVLR",;
					" %SA1.XFILIAL% " + ;
					"  AND A1_COD = '" + aRet[1] + "' " +;
					"  AND A1_LOJA = '" + aRet[2] + "' " )
	
					oTabela:cA1NOME := oSql:getFieldValue("SA1", "A1_NOME",;
					" %SA1.XFILIAL% " + ;
					"  AND A1_COD = '" + aRet[1] + "' " +;
					"  AND A1_LOJA = '" + aRet[2] + "' " )
	
					oSql:close()
					FreeObj(oSql)				
	
					cMsg := "Deseja efetivar as alterações descritas abaixo:"+cLinha
					cMsg +=	"Nome: " + oTabela:cA1NOME + cLinha
					cMsg +=	"Loja: " + aRet[2] + cLinha
					cMsg +=	"Tabela Atual do Cliente" + cLinha
					cMsg += str(oTabela:nA1DESCQTD) + " Quantidade  " + str(oTabela:nA1DESCVLR) +" Valor  " + cLinha+ cLinha
					cMsg +=	"Nova tabela do Cliente" + cLinha
					if oTabela:nTabela == 100
						cMsg += "Tabela Z " + cLinha+ cLinha
					elseif oTabela:nTabela == 0
						cMsg += "Tabela E " + cLinha+ cLinha
					else
						cMsg +=  str(oTabela:nTabela) + " " + IIF(oTabela:cTpDesc =="QTD"," Quantidade  "," Valor  ") + cLinha+ cLinha
					endif
	
					If MsgNoYes(cMsg,"Confirmação")
						oTabela:alteraCliente(,,,,.F.)
						MessageBox("Processo finalizado!!","Alterado",48)
					EndIf
	
				enddo
			endif 
		EndIF
	endif
return .T.

//OBTEM O NUMERO CORRESPONDENTE A TEBELA SELECIONADA NO COMBOBOX
STATIC FUNCTION devolveNumero(cLetra)

	//BUG NO COMPONENTE COMBOBOX, QUANDO SELECIONADO O PRIMEIRO ELEMENTO (A) ELE VOLTA 1
	Do CASE
		case valType(cLetra) == "N"
		Return 10
		case cLetra == "B"
		Return 20
		case cLetra == "C"
		Return 30
		case cLetra == "D"
		Return 50
		case cLetra == "E"
		Return 0
		case cLetra == "F"
		Return 40
		case cLetra == "Z"
		Return 100
		otherwise
		Return
	ENDCASE