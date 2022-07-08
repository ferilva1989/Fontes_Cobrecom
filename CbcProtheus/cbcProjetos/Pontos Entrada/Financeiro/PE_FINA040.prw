#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"

// Rotina Contas a Receber.
*
**********************
User Function FA040FIN
	**********************
	*
	//  -------------------------------------------------------------------
	// | O ponto de entrada FA040FIN sera chamado no programa de inclusao  |
	// | de contas a receber, apos o fim do Begin Transaction.             |
	// | Posicionado SE1                                                   |
	//  -------------------------------------------------------------------
	If SE1->E1_TIPO == "AB-"
		fEstorno("INCLUI")
	EndIf

	Return(.T.)


	*
	**********************
User Function FA040INC
	**********************
	*
	//TITULOS RECEBER (CHD/RA) INCLUIDOS MANUALMENTE, N�O PODEM TER INFORMA��ES DE COMISS�ES, PARA N�O GERAR COMISS�ES
	Local aArea		:= GetArea()
	Local aAreaE1	:= SE1->(GetArea())
	Local lRet		:= .T.


	If   M->(E1_TIPO) $ "CHD/RA" .AND. (!Empty(M->(E1_VEND1 + E1_VEND2 + E1_VEND3  + E1_VEND4  +  E1_VEND5  ) ) .OR. ;
	M->(E1_COMIS1 + E1_COMIS2 + E1_COMIS3+ E1_COMIS4 + E1_COMIS5) > 0)

		//Nem precisa avisar tendo em vista que alteramos os campos abaixo, mas vou deixar por enquanto.
		lRet	:= .F.
		MessageBox("[AVISO]-Titulo incluidos manualmente n�o pode ter dados referentes a comiss�o" ,"Aviso",48)

		M->(E1_VEND1) := M->(E1_VEND2) := M->(E1_VEND3) := M->(E1_VEND4) := M->(E1_VEND5) 		:= ""
		M->(E1_COMIS1) := M->(E1_COMIS2) := M->(E1_COMIS3) := M->(E1_COMIS4) := M->(E1_COMIS5) 	:= 0

	EndIF


	RestArea(aArea)
	RestArea(aAreaE1)
	Return lRet


	*
	**********************
User Function FA040ALT
	**********************
	*
	Local aArea    := Getarea()
	Local aAreaSE2 := SE2->(Getarea())
	Local aAreaCT2 := CT2->(Getarea())
	Local aCab  := {}
	Local aItens := {}
	Local cCt2Hist
	Local cSe1Hist
	Local cNroDcto := Str(Randomize(10,1000000))

	//Leonardo 26/08/2014
	//Usuario que estão no grupo SãoPaulo parametro "MV_ZZBORD1" não podem alterar titulo
	If U_vlsUsrSP()
		Return(.F.)
	EndIf
	/*
	*Tratar as altera��es em titulos no contas a receber, para que estas altera��es gerem automaticamente
	o lan�amento no CT2(Conta corrente), utilizando os campos (E1_ACRESC, E1_DESCRES, E1_SDACRESC, E1_SDDECRE)
	*Tabelas Envolvidas: SE1 e CT2
	*Valida��es: O lan�amento no CT2 s� deve ocorrer quando o Titulo tiver o campo SE1_ZZBC2 preenchido, o que indica
	que este titulo foi tranferido para S�o Paulo gerando o primeiro lan�amento no CT2(Conta-Corrente), sendo o objetivo
	agora arrumar o lan�amento inicial (Creditando ou Debitando) o CT2(Conta-Corrente).
	*Na grava��o do lan�amento padronizei o campo CT2_HIST(41 caracteres) de forma a conter a chave unica para o titulo
	(FILIAL+PREFIXO+NUM+PARCELA+TIPO+CLIENTE+LOJA+ZZBOR1(34 caracteres, separados por virgula) ), bem como o campo CT2_ORIGEM com o nome do usuario + data
	da altera��o (para fins de controles).
	*Logica dos procedimentos:
	O evento ocorre sempre que alteramos o titulo;
	Verificar se existe mudan�a comparando SE1 com M->SE1 Se mudan�a for para 0 Excluir lan�amento, diferente Excluir/incluir;
	Se n�o existe mudan�a n�o faz nada
	Procurar o lan�amento no CT2 com base no campo CT2_HIST
	Se achou excluir o lan�amento (Rotina padr�o)
	Incluir lan�amento no CT2 (Rotina padr�o)
	*/

	//  --------------------------------------------------------
	// | ExecBlock para validacao pos-confirmacao da alteracao  |
	// | Posicionado E1 com dados originais                     |
	//  --------------------------------------------------------
	//Leonardo - 26/08/14 Este trecho já estava não alterei
	If SE1->E1_TIPO == "AB-" .And. SE1->E1_VALOR # M->E1_VALOR
		fEstorno("ALTERA")
	EndIf

	//Validações iniciar a rotina
	//SE1->ZZBC2 não pode estar vazio
	If !empty(SE1->E1_ZZBC2)


		//Cria o cabeçalho para inclusão
		aCabInc := { 	{'DDATALANC' 	,Date()									,NIL},;
		{'CLOTE' 		,"018850" 									,NIL},;
		{'CSUBLOTE' 	,'001' 									,NIL},;
		{'CDOC' 		, cNroDcto									,NIL},; //Campos CT2 6 e Num 9
		{'CPADRAO' 	,'' 										,NIL},;
		{'NTOTINF' 	,0 											,NIL},;
		{'NTOTINFLOT' ,0 											,NIL} }

		//Obtem-se a string com o historico do titulo para o CT2_HIST
		cSe1Hist := xFilial("SE1") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA +;
		SE1->E1_ZZBOR1

		//VERIFICAR SE HOUVE MUDAN�AS
		//DECRESCIMO
		//Antigo Diferente do novo
		If SE1->E1_DECRESC # M->E1_DECRESC

			//Excluir lan�amento no CT2 caso exista
			DbSelectarea("CT2")
			DbOrderNickName("CT2ORIGEM") //CT2_FILIAL+CT2_ORIGEM

			If CT2->(DbSeek(xFilial("CT2") + "RELDPL" ,.F.) ) //Procura pelos registro relacionados aos relatorios de duplicatas

				While CT2->(!eof()).AND. Alltrim(CT2->CT2_ORIGEM) == "RELDPL" //Percorre os registros

					aItens	:= 	{} //Zera o array a cada lançamento..precaução
					aCab	:=	{}
					//Busca pelo campo CT2_HIST
					If Alltrim(CT2->CT2_HIST) == Alltrim('RELAT.DUPLICATAS. NRO. ' + Alltrim(SE1->(E1_ZZBXDB))) //Mudar aqui mudar fonte PGTOSP função exCT2

						//Cria o cabeçalho para exclusão
						aCab := { 	{'DDATALANC' 	,CT2->(CT2_DATA)					,NIL},;
						{'CLOTE' 		,"018850" 							,NIL},;
						{'CSUBLOTE' 	,'001' 							,NIL},;
						{'CDOC' 		,CT2->(CT2_DOC)					,NIL},;
						{'CPADRAO' 	,'' 								,NIL},;
						{'NTOTINF' 	,0 									,NIL},;
						{'NTOTINFLOT' ,0 									,NIL} }


						//criar aItens
						//Adiciona os itens no array para lançamento
						aAdd(aItens,{  	{'CT2_FILIAL' ,XFilial("SE1")   		, NIL},;
						{'CT2_LINHA'  	,'001'					, NIL},;
						{'CT2_MOEDLC'  	,'01'   				, NIL},;
						{'CT2_DC'   		,'3'   				, NIL},;
						{'CT2_DEBITO'  	,'DEB' 				, NIL},;
						{'CT2_CREDIT'  	,'CRE' 				, NIL},;
						{'CT2_VALOR'  	, SE1->E1_DECRESC  	, NIL},; //Ecluir o lançamento com o valor antigo
						{'CT2_ORIGEM' 	,'RELDPL'				, NIL},;
						{'CT2_HP'   		,''   					, NIL},;
						{'CT2_EMPORI'   	,'01'   				, NIL},;
						{'CT2_FILORI'   	,XFilial("SE1")   	, NIL},;
						{'CT2_TPSALD'   	,'6'   				, NIL},;
						{'CT2_CLVLCR'   	,'1101'   				, NIL},;
						{'CT2_HIST'   	,'RELAT.DUPLICATAS. NRO. ' + Alltrim(SE1->(E1_ZZBXDB)) , NIL} } )

						//Efetivar a exclusão
						excluirCt2(aCab,aItens)

					EndIf
					CT2->(dbskip())
				EndDo
			EndIf

			//Apos excluir o lançamento verifica se o novo valor não esta vazio ou zerado
			If  !Empty(M->E1_DECRESC) .OR. M->E1_DECRESC != 0

				aItens := {} //Zera o array a cada lançamento..precaução
				//criar aItens
				//Adiciona os itens no array para lançamento
				aAdd(aItens,{ {'CT2_FILIAL'  	,XFilial("SE1")   	, NIL},;
				{'CT2_LINHA'  	,'001'					, NIL},;
				{'CT2_MOEDLC'  	,'01'   				, NIL},;
				{'CT2_DC'   		,'3'   				, NIL},;
				{'CT2_DEBITO'  	,'DEB' 				, NIL},;
				{'CT2_CREDIT'  	,'CRE' 				, NIL},;
				{'CT2_VALOR'  	, M->E1_DECRESC  		, NIL},; //Incluir o lançamento com o novo valor
				{'CT2_ORIGEM' 	,'RELDPL'				, NIL},;
				{'CT2_HP'   		,''   					, NIL},;
				{'CT2_EMPORI'   	,'01'   				, NIL},;
				{'CT2_FILORI'   	,XFilial("SE1")   	, NIL},;
				{'CT2_TPSALD'   	,'6'   				, NIL},;
				{'CT2_CLVLCR'   	,'1101'   				, NIL},;
				{'CT2_HIST'   	,"DESC. " + cSe1Hist	, NIL} } )
				//Efetiva a inclusão utilizando o cabeçalho de inclusão
				incluirCt2(aCabInc,aItens)
			EndIf
		EndIf


		//ACRESCIMO
		//Antigo Diferente do novo
		If SE1->E1_ACRESC # M->E1_ACRESC

			//Excluir lançamento no CT2
			DbSelectarea("CT2")
			DbOrderNickName("CT2ORIGEM") //CT2_FILIAL+CT2_ORIGEM

			If CT2->(DbSeek(xFilial("CT2") + "RELDPL" ,.F.)) //Procura pelos registro relacionados aos relatorios de duplicatas

				While CT2->(!eof() .AND. Alltrim(CT2->CT2_ORIGEM) == "RELDPL" ) //Percorre os registros

					aItens	:= {} //Zera o array a cada lan�amento..precaução
					aCab	:= {}
					//Busca pelo campo CT2_HIST
					If Alltrim (CT2->CT2_HIST) == Alltrim("ACRES. " + cSe1Hist)  //Mudar aqui mudar fonte PGTOSP função exCT2

						//Cria o cabeçalho para a exclusão
						aCab := { 	{'DDATALANC' 	,CT2->(CT2_DATA)					,NIL},;
						{'CLOTE' 		,"018850" 							,NIL},;
						{'CSUBLOTE' 	,'001' 							,NIL},;
						{'CDOC' 		,CT2->(CT2_DOC)					,NIL},;
						{'CPADRAO' 	,'' 								,NIL},;
						{'NTOTINF' 	,0 									,NIL},;
						{'NTOTINFLOT' ,0 									,NIL} }
						//criar aItens
						//Adiciona os itens no array para lan�amento
						aAdd(aItens,{  	{'CT2_FILIAL'  	,XFilial("SE1")   		, NIL},;
						{'CT2_LINHA'  	,'001'						, NIL},;
						{'CT2_MOEDLC'  	,'01'   					, NIL},;
						{'CT2_DC'   		,'3'   					, NIL},;
						{'CT2_DEBITO'  	,'DEB' 					, NIL},;
						{'CT2_CREDIT'  	,'CRE' 					, NIL},;
						{'CT2_VALOR'  	, SE1->E1_ACRESC  		, NIL},;//Ecluir o lançamento com o valor antigo
						{'CT2_ORIGEM' 	,'RELDPL'					, NIL},;
						{'CT2_HP'   		,''   						, NIL},;
						{'CT2_EMPORI'   	,'01'   					, NIL},;
						{'CT2_FILORI'   	,XFilial("SE1")   		, NIL},;
						{'CT2_TPSALD'   	,'6'   					, NIL},;
						{'CT2_CLVLDB'   	,'1101'   					, NIL},;
						{'CT2_HIST'   	,"ACRES. " + cSe1Hist	, NIL} } )

						//Efetivar a exclusão
						excluirCt2(aCab,aItens)
					EndIf
					CT2->(dbskip())
				EndDo
			EndIf
			//Apos excluir o lançamento verifica se o novo valor não esta vazio ou zerado
			If  !Empty(M->E1_ACRESC) .OR. M->E1_ACRESC != 0
				aItens := {} //Zera o array a cada lançamento..precaução
				//criar aItens
				//Adiciona os itens no array para lançamento
				aAdd(aItens,{ {'CT2_FILIAL'  	,XFilial("SE1")   		, NIL},;
				{'CT2_LINHA'  	,'001'						, NIL},;
				{'CT2_MOEDLC'  	,'01'   					, NIL},;
				{'CT2_DC'   		,'3'   					, NIL},;
				{'CT2_DEBITO'  	,'DEB' 					, NIL},;
				{'CT2_CREDIT'  	,'CRE' 					, NIL},;
				{'CT2_VALOR'  	, M->E1_ACRESC  			, NIL},;//Incluir o lançamento com o novo valor
				{'CT2_ORIGEM' 	,'RELDPL'					, NIL},;
				{'CT2_HP'   		,''   						, NIL},;
				{'CT2_EMPORI'   	,'01'   					, NIL},;
				{'CT2_FILORI'   	,XFilial("SE1")   		, NIL},;
				{'CT2_TPSALD'   	,'6'   					, NIL},;
				{'CT2_CLVLDB'   	,'1101'   					, NIL},;
				{'CT2_HIST'   	,"ACRES. " + cSe1Hist	, NIL} } )
				//Efetiva a inclusão
				incluirCt2(aCabInc,aItens)
			EndIf
		EndIf
	EndIf

	//Restaura as areas de trabalho
	RestArea(aAreaCT2)
	RestArea(aAreaSE2)
	RestArea(aArea)

	Return(.T.)

	*
	**********************
User Function FA040B01
	**********************
	*
	//  ----------------------------------------------------------------------
	// |  Ponto de entrada para verificar informacoes antes de serem gravadas |
	// |  Na exclusao Posicionado SE1                                         |
	//  ----------------------------------------------------------------------
	If SE1->E1_TIPO == "AB-"
		fEstorno("EXCLUI")
	EndIf

	Return(.T.)

	*
	****************************
Static Function fEstorno(cOpc)
	****************************
	*
	//  -----------------------------------------------------------------------------------------------------
	// | Esta fun��o tem por objetivo gerar movimento no SE5 na inclus�o, altera�ao e exclus�o de um         |
	// | titulo de abatimento (AB-) no contas a receber, contanto que o titulo esteja em cobranca descontada |
	// | Necessario para que seja apresentado no relatorio de C/C.                                           |
	//  -----------------------------------------------------------------------------------------------------

	Local aArea   := GetArea()
	Local aAreaE1 := SE1->(GetArea())
	Local aAreaE5 := SE5->(GetArea())

	//Posiciono no titulo principal (NF / FT)
	DbSelectArea("SE1")
	SE1->(DbSetOrder(1))
	SE1->(DbSeek(xFilial("SE1")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO,.F.))
	Do While !SE1->(Eof()) .And. SE1->E1_FILIAL == xFilial("SE1") .And. SE1->E1_TIPO == "AB-"
		SE1->(DbSkip())
	EndDo
	nAbatim := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

	// |Cobran�a descontada. ( Gerou E5 ao entrar nesta situa��o )                                      |
	// |Agora preciso gerar estorno com o valor do abatimento. Necessario p/ controle IFC               |
	If Alltrim(SE1->E1_SITUACA) == "2"
		If cOpc == "INCLUI"
			RecLock("SE5",.T.)
			SE5->E5_FILIAL     := xFilial("SE5")
			SE5->E5_DATA       := dDataBase
			SE5->E5_TIPO       := SE1->E1_TIPO
			SE5->E5_VALOR      := nAbatim
			SE5->E5_VLMOED2    := nAbatim
			SE5->E5_LA         := "N"
			SE5->E5_NATUREZ    := "DESCONT"
			SE5->E5_BANCO      := SE1->E1_PORTADO
			SE5->E5_AGENCIA    := SE1->E1_AGEDEP
			SE5->E5_CONTA      := SE1->E1_CONTA
			SE5->E5_RECPAG     := "P"
			SE5->E5_PREFIXO    := SE1->E1_PREFIXO
			SE5->E5_NUMERO     := SE1->E1_NUM
			SE5->E5_PARCELA    := SE1->E1_PARCELA
			SE5->E5_HISTOR     := "Desconto Estorno Tit Desc"
			SE5->E5_TIPODOC    := "E2"
			SE5->E5_DTDIGIT    := dDataBase
			SE5->E5_DTDISPO    := dDataBase
			SE5->E5_MOTBX      := "NOR"
			SE5->E5_SEQ        := "01"
			SE5->E5_CLIFOR     := SE1->E1_CLIENTE
			SE5->E5_CLIENTE    := SE1->E1_CLIENTE
			SE5->E5_LOJA       := SE1->E1_LOJA
			SE5->E5_LOTE       := "F040"
			SE5->E5_DOCUMENT   := SE1->E1_NUMBOR
		Else
			//Posiciono no SE5
			SE5->(DbSetOrder(7))//E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
			SE5->(DbSeek(xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO,.F.))
			RecLock("SE5",.F.)

			If cOpc == "ALTERA" .And. SE5->E5_LOTE == "F040"
				//nAbatim            := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
				SE5->E5_VALOR      := M->E1_VALOR
				SE5->E5_VLMOED2    := M->E1_VALOR
				SE5->E5_DTDIGIT    := dDataBase
			ElseIf cOpc == "EXCLUI" .And. SE5->E5_LOTE == "F040"
				DbDelete()
			EndIf
		EndIf
		MsUnLock()
		AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,"-")
	EndIf

	RestArea(aAreaE5)
	RestArea(aAreaE1)
	RestArea(aArea)

	Return(.T.)


	*
	****************************
Static Function excluirCt2(aCab,aItens)
	****************************
	*
	//Leonardo 26/08/2014 - Utilizado no PE FA040ALT
	Local lMsErroAuto := .F.
	Local lMsHelpAuto := .T.

	Begin Transaction
		MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 5)

		If lMsErroAuto
			MOSTRAERRO()
			DisarmTransaction()

		EndIf
	End Transaction

	Return

	*
	****************************
Static Function incluirCt2(aCab,aItens)
	****************************
	*
	//Leonardo 26/08/2014 - Utilizado no PE FA040ALT
	Local lMsErroAuto := .F.
	Local lMsHelpAuto := .T.

	Begin Transaction
		MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)

		If lMsErroAuto
			MOSTRAERRO()
			DisarmTransaction()

		EndIf
	End Transaction

Return
