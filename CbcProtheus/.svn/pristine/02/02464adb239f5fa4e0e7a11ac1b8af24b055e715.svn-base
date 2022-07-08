#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch" 

//Fina330
//Rotina de Compensação do Contas a Receber
*
************************
User Function Fa330Vld()//PE executado na confirmação da compensação ( após selecionados os titulos )
	************************
	*      
	/*
	SE1      -> posicionado
	nValTot  -> Valor total de compensação
	aTitulos -> Contem todos titulos que aparecem na MBrowse, sendo importante 
	[1 a 4 ]     - Prefixo, Num ,Parcela, Tipo
	[8] Logico   - Selecionado
	[9] Numerico - Valor a compensar
	*/   
	Local aArea   := GetArea()
	Local aAreaE1 := SE1->(GetArea())
	Local aAreaE5 := SE5->(GetArea())
	Public aItemsFI2 := {}

	// |Cobrança descontada. ( Gerou E5 ao entrar nesta situação )                                      |
	// |Agora preciso gerar estorno com o valor de compensação. Pois no padrão não está fazendo isso    |
	If Alltrim(SE1->E1_SITUACA) == "2"
		RecLock("SE5",.T.)
		SE5->E5_FILIAL     := xFilial("SE5")
		SE5->E5_DATA       := dDataBase
		SE5->E5_TIPO       := SE1->E1_TIPO
		SE5->E5_VALOR      := nValTot
		SE5->E5_VLMOED2    := nValTot
		SE5->E5_LA         := "N"
		SE5->E5_NATUREZ    := "DESCONT"
		SE5->E5_BANCO      := SE1->E1_PORTADO
		SE5->E5_AGENCIA    := SE1->E1_AGEDEP
		SE5->E5_CONTA      := SE1->E1_CONTA
		SE5->E5_RECPAG     := "P"
		SE5->E5_PREFIXO    := SE1->E1_PREFIXO
		SE5->E5_NUMERO     := SE1->E1_NUM
		SE5->E5_PARCELA    := SE1->E1_PARCELA
		SE5->E5_HISTOR     := "Baixa/Debita Estorno Tit Desc"
		SE5->E5_TIPODOC    := "E2"
		SE5->E5_DTDIGIT    := dDataBase
		SE5->E5_DTDISPO    := dDataBase
		SE5->E5_MOTBX      := "NOR"
		SE5->E5_SEQ        := "01"
		SE5->E5_CLIFOR     := SE1->E1_CLIENTE
		SE5->E5_CLIENTE    := SE1->E1_CLIENTE
		SE5->E5_LOJA       := SE1->E1_LOJA
		SE5->E5_LOTE       := "F330"
		SE5->E5_DOCUMENT   := SE1->E1_NUMBOR
		MsUnLock()
		AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,"-")

		_nValAnt := TransForm(SE1->E1_VALOR,PesqPict("SE1","E1_VALOR"))
		_nValNov := TransForm(nValTot,PesqPict("SE1","E1_VALOR"))
		aAdd( aItemsFI2, {"01","",_nValAnt,_nValNov,"NCC","N"})

		F040GrvFI2()//Funcao de gravação da tabela FI2	
	EndIf	               
	RestArea(aAreaE5)
	RestArea(aAreaE1)
	RestArea(aArea)
	Return(.T.)

	*
	*************************
User Function F300VALID()//PE executado logo após botão Compensação 
	*************************
	*
	If Alltrim(SE1->E1_TIPO)$ MVPAGANT+"/"+MVTAXA+"/"+MVPROVIS+"/"+MVRECANT+"/"+MVABATIM+"/"+MV_CPNEG+"/"+MV_CRNEG 
		//If Alltrim(SE1->E1_TIPO)$ MVPAGANT+"/"+MVTAXA+"/"+MVPROVIS+"/NF/"+MVABATIM+"/"+MV_CPNEG+"/"+MV_CRNEG
		MsgInfo("Selecione o titulo que dever� ser compensado ( NF/FT )","Aten��o")
		Return(.F.)
	EndIf

	Return(.T.)

	*
	*************************
User Function F330VEEX() //Botão Estornar ou Excluir
	*************************
	*

	// Deleto o registro criado via PE Fa330Vld
	Local aArea    := GetArea()
	Local aAreaE5  := SE5->(GetArea())
	Local nTam     := TamSX3("E5_NATUREZ")[1]
	Local cNaturez := Left("DESCONT"+Space(nTam),nTam)
	Local cProcura
	Local aItens := {}

	SE5->(DbSetOrder(4))
	If SE5->(dbSeek(xFilial("SE5")+cNaturez+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DTOS(E5_DTDIGIT)+"P"+E5_CLIFOR+E5_LOJA,.T.))
		If Alltrim(SE5->E5_LOTE) == "F330"
			RecLock("SE5",.F.)
			DbDelete()
			MsUnlock()
		EndIf
	EndIf

	//Leonardo 02/09/2014 
	//Procurar lançamento utilizando a chave CT2_HIST e  CT2_CLVLDB(8101), apos verificar se CT2_ORIGEM == 'CCOK'
	//se ok realiza o lançamento (C) no CT2(1101), o que caracteriza o estorno, logo apos muda-se o CT2_ORIGEM para 'VVCANCEL'

	RestArea(aAreaE5)

	//Verificar se a compensação e do titulo ou do RA (LP 596 grava as informações do RA CT2_HIST)

	If AllTrim(SE5->E5_TIPO) == 'NF' //Titulo

		//Chave de busca no campo CT2_HIST (da mesma forma que é gravada (LP 596)
		cProcura := SE5->(Alltrim(E5_FILORIG+ ";" +SubStr(E5_DOCUMEN,1,3)+ ";" +SubStr(E5_DOCUMEN,4,9)+ ";" +SubStr(E5_DOCUMEN,13,3)+ ";" +SubStr(E5_DOCUMEN,16,3)+ ";" +E5_CLIFOR+ ";" +E5_LOJA ))

	Else //RA

		//Chave de busca no campo CT2_HIST (da mesma forma que é gravada (LP 596)
		cProcura := SE5->(Alltrim(E5_FILORIG+ ";" +E5_PREFIXO+ ";" +E5_NUMERO+ ";" +E5_PARCELA+ ";" +E5_TIPO+ ";" +E5_CLIFOR+ ";" +E5_LOJA ))
	EndIf


	//Posiciona e ordena o CT2  
	DbSelectArea("CT2")
	DbOrderNickName("CT2ORIGEM") //CT2_FILIAL+CT2_ORIGEM

	//Posiciona na primeira ocorrencia com status 'CCOK'
	If CT2->(DbSeek(xFilial("CT2") + "CCOK" ,.F.))

		While CT2->(!eof()) .AND. Alltrim(CT2->CT2_ORIGEM) == "CCOK"
			//Verifica se o campo CT2_HIST é o que procuramos
			If Alltrim(CT2->CT2_HIST) == Alltrim(cProcura) .AND. SE5->E5_VALOR == CT2->CT2_VALOR 
				Begin Transaction
					//Excluir CT2 (1101)
					//Adiciona os itens no array para lançamento
					aAdd(aItens,{  {'CT2_FILIAL'  ,XFilial("CT2")   							, NIL},;
					{'CT2_LINHA'  	, StrZero(1,3) 											, NIL},;
					{'CT2_MOEDLC'  	,'01'   													, NIL},;
					{'CT2_DC'   		,'3'   													, NIL},;
					{'CT2_DEBITO'  	,'DEB' 													, NIL},;
					{'CT2_CREDIT'  	,'CRE' 													, NIL},;
					{'CT2_VALOR'  	, CT2->CT2_VALOR  										, NIL},;
					{'CT2_ORIGEM' 	,'VVCANCEL'												, NIL},;
					{'CT2_HP'   		,''   														, NIL},;
					{'CT2_EMPORI'   	,'01'   													, NIL},;
					{'CT2_FILORI'   	,XFilial("CT2")   										, NIL},;
					{'CT2_TPSALD'   	,'6'   													, NIL},;
					{'CT2_CLVLDB'   	,'8101'   													, NIL},;     //Para zerar a conta transitoria
					{'CT2_CLVLCR'   	,'1101'   													, NIL},;     //Quando Estorno o campo correto éCT2_CLVLCR,Quando estorno informar no historico
					{'CT2_HIST'   	,'CANC. DE COMPENSACAO RA. ' + DtoC(dDataBase)	, NIL} } )

					//Efetiva o lançamento no Conta-Corrente
					incluirCt2(aItens)

					RecLock("CT2",.F.)
					CT2->CT2_ORIGEM := "VVCANCEL"
					CT2->(MsUnlock())
				End Transaction
				Exit	

			EndIf
			//Proximo registro
			CT2->(dbskip())
		EndDo
	EndIf



	RestArea(aAreaE5)
	RestArea(aArea)

	Return(.T.)
	*

	************************
User Function F330ESE5()
	************************
	*
	// Se der EOF() no SE5, tento reposicionar, pois existe histórico de falha no DbSeek
	// Ordem 2-E5_FILIAL+E5_TIPODOC+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+DtoS(E5_DATA)+E5_CLIFOR+E5_LOJA+E5_SEQ
	// _MyFil :=
	// _MyTpD :=
	// _MyPre :=
	// _MyNum :=
	// _MyPar := 
	// _MyTip :=
	If SE5->(Eof())
		SE5->(DbSeek(ParamIxb[1,ParamIxb[5],1]+ParamIxb[2]+Substr(ParamIxb[1,ParamIxb[5],2],1,ParamIxb[3]+ParamIxb[4]),.F.))
	EndIf
	Return(.T.)

	****************************
Static Function incluirCt2(aItens)
	****************************
	*   
	Local lMsErroAuto := .F.
	Local lMsHelpAuto := .T.
	Local aCab := {}
	Local cNroLcto :=  MesDia(dDataBase) + cValToChar(Randomize(100,200)) 

	//Cria o cabeçalho para o lançamento
	aCab := 	{ {'DDATALANC' ,dDataBase 		,NIL},;
	{'CLOTE' 		,"028850" 			,NIL},;
	{'CSUBLOTE' 	,'001' 			,NIL},;
	{'CDOC' 		,cNroLcto 			,NIL},;
	{'CPADRAO' 	,'' 				,NIL},;
	{'NTOTINF' 	,0 					,NIL},;
	{'NTOTINFLOT' ,0 					,NIL} }		

	Begin Transaction
		MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)

		If lMsErroAuto
			MOSTRAERRO()
			DisarmTransaction()

		EndIf
	End Transaction                      

Return


