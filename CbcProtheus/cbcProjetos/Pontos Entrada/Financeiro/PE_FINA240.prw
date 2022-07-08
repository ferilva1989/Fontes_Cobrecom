#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"

//Fina240 - Rotina Bordero de Pagamentos
*
**********************
User Function F240TBOR
	**********************
	*
	//O ponto de entrada F240TBOR sera executado apos a gravacao dos dados do bordero de pagamento.
	Local _aArea   := GetArea()
	Local _aAreaEA

	DbSelectArea("SEA")
	_aAreaEA := GetArea()
	SEA->EA_VENCREA := SE2->E2_VENCTO // CAMPO EA_VENCREA propr. usuário

	RestArea(_aAreaEA)
	RestArea(_aArea)

	Return(.T.)

	
/*/{Protheus.doc} F240IND
(long_description)
@type function
@author bolognesi
@since 20/03/2018
@version 1.0
@description	O retorno do ponto de entrada passa a ser do tipo numérico, tornando necessário 
indicar o número do índice padrão (SIX) a ser considerado. Obs: Caso o índice seja alfanumérico 
(exemplo: A, B, C), o retorno do ponto de entrada deve seguir a mesma regra da função "DBSetOrder", 
ou seja, o retorno deve ser numérico.
/*/
user Function F240IND()
	// E2_FILIAL+DTOS(E2_VENCTO)+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
	local nIndice	:= 21
Return(nIndice)

	*
	************************
User Function F240MARK() // Funï¿½ï¿½o Usada para seleï¿½ï¿½o das colunas a serem exibidas
	************************
	*
	_cString := "E2_OK     E2_NOMFOR E2_VALOR  E2_SALDO  E2_PREFIXOE2_NUM    E2_PARCELAE2_TIPO   E2_PORTADOE2_NUMCX  E2_VENCTO E2_VENCREAE2_BANCO  E2_AGENCIAE2_DVAGENCE2_NUMCON E2_TPCTA  E2_HIST   E2_FORNECEE2_LOJA   E2_EMISSAOE2_CODBAR "
	_aVoltar := {}
	Do While Len(_cString) > 0
		_cStrAtu := Left(_cString,10)
		_cString := Right(_cString,Len(_cString)-10)
		For _nQtds := 1 To Len(ParamIXB)
			If Left(ParamIXB[_nQtds,1]+Space(10),10) ==_cStrAtu
				AAdd(_aVoltar,Array(Len(ParamIXB[_nQtds])))
				For _nQtdsEl := 1 To Len(ParamIXB[_nQtds])
					_aVoltar[Len(_aVoltar),_nQtdsEl] := ParamIXB[_nQtds,_nQtdsEl]
				Next
				Exit
			EndIf
		Next
	EndDo
	Return(_aVoltar)


	*
	***********************
User Function F240FIL() // Filtro do FINA240
	***********************
	*
	//LEONARDO - 29/05/2015 - Voltei a opção para filtrar as formas de pagamento quando bordero destinado ao banco pagamento. (Solicitado Morais 29/05) 

	//Caso o bordero a ser criado tenha como destino o portador 000, somente deverïa aparecer titulos com o campo E2_PORTADO
	//Diferente de 000 - Evitando duplicidade
	If cPort240 == "000" .And. cAgen240 == "00000" .And. cConta240 == "0000000000"
		_cFiltro := ' E2_PORTADO # "000" '
	Else
		// Filtro para criação do bordero de pagamentos
		// E2_FORMA -> Forma de Pagamento   -> 1=Banco    2=Caixa
		// E2_UNPAG -> Unidade de Pagamento -> 1=Itu      2=São Paulo
		// Só pode ser incluido no bordero o que for pago em BANCO em ITU
		/*

		If cPort240 == "000" .And. cAgen240 == "00000" .And. cConta240 == "0000000000" //  Conta Corrente
		// O titulo tem que estar em um caixa e o pagamento tem que ser pelo conta corrente
		_cFiltro := '!Empty(E2_NUMCX) .And. E2_UNPAG == "2"'
		Alert("Filtrando Pagamentos Programados por São Paulo")
		Else
		*/
		_aArea := GetArea()
		// Salva o conteudo dos parametros
		// quantos forem necessários para o pergunte abaixo
		_Old_Par01 := MV_PAR01
		_Old_Par02 := MV_PAR02
		_Old_Par03 := MV_PAR03

		DbSelectArea("SX1")
		DbSetOrder(1)
		cPerg := PadR("PAGFOR",Len(SX1->X1_GRUPO))

		aRegs:={}
		//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
		aAdd(aRegs,{cPerg,"01","Forma de Pagamento           ?","mv_ch1","N",01,0,0,"C","","mv_par01","Banco","","","Caixa","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"02","Unid. de Pagamento           ?","mv_ch2","N",01,0,0,"C","","mv_par02","Itu","","","São Paulo","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"03","Filtra Boletos               ?","mv_ch3","N",01,0,0,"C","","mv_par03","Sim","","","Não","","","","","","","","","","",""})

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
		_cFiltro := ''
		If Pergunte(cPerg,.T.)
			_cFiltro := 'E2_FORMA=="'+Str(MV_PAR01,1) +'" .And. E2_UNPAG == "'+Str(MV_PAR02,1) +'"'
			If MV_PAR03 == 1
				_cFiltro := _cFiltro + ' .And. !Empty(E2_CODBAR)' 
				//_cFiltro := _cFiltro + ' .And. !Empty(E2_BANCO)'
			EndIf
		EndIf
		MV_PAR01 := _Old_Par01
		MV_PAR02 := _Old_Par02
		MV_PAR03 := _Old_Par03

	EndIf

	Return(_cFiltro)

	*
	***************************
User Function F240BORD()
	***************************
	/*
	Programa  ï¿½ MYF240TBORD ï¿½Autor  ï¿½Leonardo Bolognesi ï¿½ Data ï¿½  02/07/14  ï¿½ï¿½ï¿½
	ï¿½ï¿½ï¿½Desc.     ï¿½ Rotina para contabilizar no CT2 os titulos do Bordero SEA  ï¿½ï¿½ï¿½
	ï¿½ï¿½ï¿½Uso       ï¿½ Financeiro Cobrecom                                        ï¿½ï¿½ï¿½
	ï¿½ï¿½ï¿½																		   ï¿½ï¿½ï¿½
	ï¿½ï¿½ï¿½O ponto de entrada F240BORD sera utilizado para tratamento complementar,ï¿½ï¿½ï¿½
	ï¿½ï¿½ï¿½apos a gravacao do bordero.                                             ï¿½ï¿½ï¿½
	ï¿½ï¿½ï¿½F240BORD - Tratamento complementar ( ) --> URET                         ï¿½ï¿½ï¿½
	ï¿½ï¿½ï¿½URET(nulo)                                                              ï¿½ï¿½ï¿½
	ï¿½ï¿½ï¿½nil                                                                     ï¿½ï¿½ï¿½
	ï¿½ï¿½ï¿½ Tabelas envolvidas: 												   ï¿½ï¿½ï¿½
	ï¿½ï¿½ï¿½ SE2 - Titulos a pagar 												   ï¿½ï¿½ï¿½
	ï¿½ï¿½ï¿½ SEA - Borderï¿½ de titulos                                               ï¿½ï¿½ï¿½
	ï¿½ï¿½ï¿½ Definido o 'CLOTE' ,"018850" fixo para esta modalidade de lanï¿½amento   ï¿½ï¿½ï¿½
	*/

	//Salva as areas de trabalho
	Local aArea    := Getarea()
	Local aAreaSE2 := SE2->(Getarea())
	Local aAreaSEA := SEA->(Getarea())
	Local aAreaCT2 := CT2->(Getarea())

	Local cNroBord  
	Local nTotalBord := 0                                
	Local _lOk := .T.
	Local aItens := {}
	Local nLinha := 1
	Local aCab  := {}

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.                 

	//Posicionar para relacionamento com SEA 
	DbSelectArea("SE2")
	SE2->(DbSetOrder(1))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

	//Na chamada do ponto de entrada, ja vem posicionado
	DbSelectArea("SEA")

	SEA->(DbSetOrder(1))//EA_FILIAL+EA_NUMBOR+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA                         

	If SEA->(EA_PORTADO) == "000"

		//Obtem o numero do bordero
		cNroBord :=SEA->(EA_NUMBOR) 

		//Cria o cabeçalho para o lançamento
		aCab := { 	{'DDATALANC' 	,SEA->(EA_DATABOR) 	,NIL},;
		{'CLOTE' 		,"018850" 			,NIL},;
		{'CSUBLOTE' 	,'001' 				,NIL},;
		{'CDOC' 		, cNroBord 			,NIL},;
		{'CPADRAO' 		,'' 				,NIL},;
		{'NTOTINF' 		,0 					,NIL},;
		{'NTOTINFLOT' 	,0 					,NIL} }

		//Procura no SEA lançamento com o numero do bordero posicionando no primeiro
		If SEA->(dbseek(xFilial("SEA")+ cNroBord, .F.) )

			//Loop nos registros enquanto for o numero do bordero
			While  SEA->EA_NUMBOR == cNroBord .and. !(SEA->(eof()))

				//Verifica se o titulo já existe no SEA com o mesmo portador (evitar duplicidade portador 000)

				//Procura o correspondente no SE2 utilizando o filtro 1
				//E2_FILIAL+   E2_PREFIXO+        E2_NUM+           E2_PARCELA+      E2_TIPO+   E2_FORNECE+            E2_LOJA
				if SE2->(dbseek(xFilial("SEA")+SEA->(EA_PREFIXO)+SEA->(EA_NUM)+SEA->(EA_PARCELA)+SEA->(EA_TIPO)+SEA->(EA_FORNECE)+SEA->(EA_LOJA)))                                       

					//Adiciona os itens no array para lançamento
					aAdd(aItens,{  	{'CT2_FILIAL'  	,XFilial("SEA")   															, NIL},;
					{'CT2_LINHA'  	, StrZero(nLinha,3) 														, NIL},;
					{'CT2_MOEDLC' 	,'01'   																	, NIL},;
					{'CT2_DC'   	,'3'   																		, NIL},;  
					{'CT2_DEBITO'  	,'DEB' 																		, NIL},; 
					{'CT2_CREDIT'  	,'CRE' 																		, NIL},;
					{'CT2_VALOR'  	, SE2->(E2_VALOR)  															, NIL},;
					{'CT2_ORIGEM' 	,'CTBBORDERO'																, NIL},;
					{'CT2_HP'   	,''   																		, NIL},; 
					{'CT2_EMPORI'   ,'01'   																	, NIL},; 
					{'CT2_FILORI'   ,XFilial("SE2")   															, NIL},;
					{'CT2_TPSALD'   ,'6'   																		, NIL},; 	
					{'CT2_CLVLCR'   ,SE2->(E2_CLVLDB)   														, NIL},;
					{'CT2_HIST'   	,SE2->(E2_PREFIXO) + SE2->(E2_NUM) + SE2->(E2_PARCELA)+SE2->(E2_NOMFOR)		, NIL} } )

					//Incremento do total do bordero
					nTotalBord += SE2->(E2_VALOR)

					//Zera o numero do bordero para poder incluir no banco correto apos este bordero 
					reclock("SE2",.f.)
					SE2->(E2_NUMBOR) := ""
					SE2->(msunlock())            

					//Incremental da linha para este lote       		 
					nLinha ++      

				EndIf

				//Proximo registro
				SEA->(DbSkip())

			EndDo
			//Realiza o lançamento do total
			aAdd(aItens,{  	{'CT2_FILIAL'  	,XFilial("SEA")   			, NIL},;
			{'CT2_LINHA'  	, StrZero(nLinha,3) 		, NIL},;
			{'CT2_MOEDLC'  	,'01'   					, NIL},;
			{'CT2_DC'   	,'3'   						, NIL},;  
			{'CT2_DEBITO'  	,'DEB' 						, NIL},; 
			{'CT2_CREDIT'  	,'CRE' 						, NIL},;
			{'CT2_VALOR'  	, nTotalBord  				, NIL},;
			{'CT2_ORIGEM' 	,'CTBBORDERO'				, NIL},;
			{'CT2_HP'   	,''   						, NIL},; 
			{'CT2_EMPORI'   ,'01'   					, NIL},; 
			{'CT2_FILORI'   ,XFilial("SE2")   			, NIL},;
			{'CT2_TPSALD'   ,'6'   						, NIL},; 
			{'CT2_CLVLCR'   ,'1101'   					, NIL},;
			{'CT2_CLVLDB'   ,'9101'   					, NIL},;
			{'CT2_HIST'   	,'CAIXA Nro. ' + cNroBord  	, NIL} } )


			//terceiro parametro do CTBAL102
			//1=Pesquisa
			//2=Visualização
			//3=Inclusção
			//4=Alteração
			//5=Exclusção
			Begin Transaction
				MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)

				_cErrLog := MOSTRAERRO("C:\Temp","siga.log")

				If !Empty(_cErrLog)

					DisarmTransaction()
					Alert(_cErrLog)

				EndIf

			End Transaction

		EndIf

	EndIf
	//Restaura as areas de trabalho
	RestArea(aAreaCT2)
	RestArea(aAreaSEA)
	RestArea(aAreaSE2)
	RestArea(aArea)    

	return nil

	*
	***********************
User Function F240CAN(cOldPortado) // Excluir o lanï¿½amento no CT2
	***********************
	*
	//Salva as areas de trabalho
	Local aArea    := Getarea()
	Local aAreaSE2 := SE2->(Getarea())
	Local aAreaSEA := SEA->(Getarea())
	Local aAreaCT2 := CT2->(Getarea())

	Local cNroBord
	Local nTotalBord := 0  
	Local _lOk := .T.
	Local aItens := {}
	Local nLinha 
	Local aCab  := {}
	Local lMsErroAuto := .F.
	Local lMsHelpAuto := .T.

	//Na chamada do ponto de entrada, ja vem posicionado
	DbSelectArea("SEA")

	SEA->(DbSetOrder(1))

	If SEA->(EA_PORTADO) == "000"

		//Obtem o numero do bordero
		cNroBord :=SEA->(EA_NUMBOR)

		//Cria o cabeï¿½alho para o lanï¿½amento
		aCab := { 	{'DDATALANC' 	,SEA->(EA_DATABOR) 	,NIL},;
		{'CLOTE' 		,"018850" 				,NIL},;
		{'CSUBLOTE' 	,'001' 				,NIL},;
		{'CDOC' 		, cNroBord 			,NIL},;
		{'CPADRAO' 	,'' 					,NIL},;
		{'NTOTINF' 	,0 						,NIL},;
		{'NTOTINFLOT' ,0 						,NIL} }

		//Obtem todos os lanï¿½amento no CT2 referentes a este bordero
		BeginSQL Alias "SQLCT2"
		column CT2_Data as Date

		SELECT CT2.CT2_LINHA, CT2.CT2_VALOR, CT2.CT2_CLVLDB, CT2.CT2_HIST
		FROM %Table:CT2% CT2
		WHERE CT2.CT2_FILIAL = %xFilial:CT2%			//Filial
		AND CT2.CT2_DATA = %exp:SEA->(EA_DATABOR)%	//Data
		AND CT2.CT2_LOTE = '018850'                  //Lote
		AND CT2.CT2_SBLOTE = '001'                   //Sub-Lote
		AND CT2.CT2_DOC = %exp:cNroBord%             //Documento Nro.Bordero
		AND CT2.%NotDel%                            //Nï¿½o deletado

		ORDER BY %Order:CT2,1%                      //Ordem pelo indice 1

		EndSql

		dbselectarea("SQLCT2")//ARQUIVO TRABALHO COM O RETORNO DO SELECT

		//verificar se o select retorna vazio (evitar erro)

		//Loop nos registros do bordero montando array exclusï¿½o
		While  !(SQLCT2->(eof()))

			//Adiciona os itens no array para lanï¿½amento
			aAdd(aItens,{  	{'CT2_FILIAL'  	,XFilial("SEA")   		, NIL},;
			{'CT2_LINHA'  	, SQLCT2->(CT2_LINHA)	, NIL},;
			{'CT2_MOEDLC'  	,'01'   					, NIL},;
			{'CT2_DC'   		,'3'   					, NIL},;
			{'CT2_DEBITO'  	,'DEB' 					, NIL},;
			{'CT2_CREDIT'  	,'CRE' 					, NIL},;
			{'CT2_VALOR'  	, SQLCT2->(CT2_VALOR)  	, NIL},;
			{'CT2_ORIGEM' 	,'CTBBORDERO'				, NIL},;
			{'CT2_HP'   		,''   						, NIL},;
			{'CT2_EMPORI'   	,'01'   					, NIL},;
			{'CT2_FILORI'   	,XFilial("SEA")   		, NIL},;
			{'CT2_TPSALD'   	,'6'   					, NIL},;
			{'CT2_CLVLDB'   	,SQLCT2->(CT2_CLVLDB)   	, NIL},;
			{'CT2_HIST'   	,SQLCT2->(CT2_HIST)		, NIL} } )


			//Proximo registro
			SQLCT2->(DbSkip())

		EndDo

		//Fechar e excluir arquivo de trabalho               
		SQLCT2->(dbclosearea())
		FErase("SQLCT2" + GetDbExtension())

		//terceiro parametro do CTBAL102
		//1=Pesquisa
		//2=VisualizaÃ§Ã£o
		//3=InclusÃ£o
		//4=AlteraÃ£oo
		//5=ExclusÃ£o
		If len(aItens) > 0

			Begin Transaction
				MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 5)

				_cErrLog := MOSTRAERRO("C:\Temp","siga.log")

				If !Empty(_cErrLog)

					DisarmTransaction()
					Alert(_cErrLog)

				EndIf
			End Transaction
		EndIf

	EndIf

	//Restaura as areas de trabalho
	RestArea(aAreaCT2)
	RestArea(aAreaSEA)
	RestArea(aAreaSE2)
	RestArea(aArea)

Return nil
