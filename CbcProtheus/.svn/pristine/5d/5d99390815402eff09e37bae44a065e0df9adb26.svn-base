#INCLUDE 'Protheus.ch'
#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "tbiconn.ch"
#define CRLF Chr(13)+Chr(10)

//Utilizar função para definir os filttros de acordo com o grupo dos usuarios
User Function PGTOSP()    //transferir Itu para São Paulo

	Local cCodRec 			:= space(08)
	Local cPerg 			:= "BORDSP"
	Private cMarkDestino 	:= ""


	//Mandar os titulos para São Paulo

	//Pergunta para obter os paramtros
	CriaSX1(cPerg)

	If Pergunte(cPerg, .T.)

		//cMarkDestino := "SP"
		montarTela( mv_Par01,mv_Par02, mv_Par03,mv_Par04,mv_Par05)

	EndIf

	Return NIL

	**************************************************************************
Static Function montarTela(cCodCli,dEmisIni,EmisFin,dDtIni, dDtFinal)
	**************************************************************************
	//MONTAR A TELA PARA SELEÇÂO DOS TITULOS

	Private dDtaInicial := dDtIni
	Private dDtaFinal 	:= dDtFinal
	Private dEmiInicial := dEmisIni
	Private dEmiFinal	:= EmisFin
	Private cCodCli		:= cCodCli 
	Private oMark
	Private oFont 		:= TFont():New( "Arial", , -12, .T.)

	DbSelectArea("SE1")
	SE1->(DbOrderNickName("FINSP")) //E1_FILIAL+E1_NUMBOR+DTOS(E1_VENCREA)+ E1_SALDO+E1_TIPO+E1_SITUACA+E1_ZZBC2+E1_ZZBOR1+E1_PORTADO

	// Instanciamento do classe
	oMark := FWMarkBrowse():New()
	// Definição da tabela a ser utilizada
	oMark:SetAlias('SE1')
	//Defini a fonte utilizada
	oMark:SetFontBrowser(oFont)

	// Define se utiliza controle de marcação exclusiva do oMark:SetSemaphore(.T.)
	// Define a titulo do browse de marcacao
	oMark:SetDescription('Bordero titulos para baixar e debitar Itu')

	// Define o campo que sera utilizado para a marcação
	oMark:SetFieldMark( 'E1_ZZOK' )

	/*Filtro utilizado na rotina padrão obtido via trace
	WHERE  E1_FILIAL BETWEEN '01' AND '01' AND E1_NUMBOR = '      ' AND E1_EMISSAO BETWEEN '20140729' AND '20140729' AND E1_CLIENTE BETWEEN '      '
	AND 'ZZZZZZ' AND E1_VENCREA BETWEEN '20140101' AND '20140130' AND E1_MOEDA = 1 AND E1_PREFIXO BETWEEN '   ' AND 'ZZZ' AND E1_NUM BETWEEN '         '
	AND 'ZZZZZZZZZ' AND E1_SALDO > 0 AND E1_TIPO NOT IN ('PR ','RA ','NCC',' ') AND E1_SITUACA IN ('0','F','G') AND D_E_L_E_T_ <> '*'
	*/

	cFiltro := 	"  E1_FILIAL == '" +  xFilial('SE1') + "'"
	cFiltro +=	" .AND. Empty(E1_NUMBOR)"

	//FORNECEDOR
	If !Empty(cCodCli)

		cFiltro +=  " .AND. E1_CLIENTE == '" + cCodCli + "'" 

	EndIf 

	//EMISSÂO
	If !Empty(dEmiInicial) .AND. !Empty(dEmiFinal)
		cFiltro +=  " .AND. ( dtos(E1_EMISSAO) >= '" + dTos(dEmiInicial) + "' .AND. dtos(E1_EMISSAO) <= '" + dTos(dEmiFinal) + "')"
	EndIf	

	//VENCIMENTO
	If !Empty(dDtIni) .AND. !Empty(dDtFinal)
		cFiltro +=	" .AND. ( dtos(E1_VENCREA) >= '" + dTos(dDtIni) + "' .AND.  dtos(E1_VENCREA) <= '" + dTos(dDtFinal) + "')"
	EndIf		

	cFiltro +=  " .AND. E1_SALDO > 0 "
	cFiltro +=	" .AND. ( !Empty(E1_TIPO) .AND. E1_TIPO # 'PR' .AND. E1_TIPO # 'RA' .AND. E1_TIPO # 'NCC' .AND. E1_TIPO # 'CHD' )" //.AND. E1_TIPO # 'NDC')
	cFiltro +=  " .AND. ( E1_SITUACA $ '0' .OR. E1_SITUACA $ 'F' .OR. E1_SITUACA $ 'G' )    "
	cFiltro += 	" .AND. Empty(E1_ZZBC2) .AND. Empty(E1_ZZBOR1) .AND. Empty(E1_PORTADO)"

	// Definir os campos que aparecem 
	oMark:SetOnlyFields({'E1_FILIAL','E1_CHAVE','E1_PREFIXO','E1_NUM','E1_PARCELA','E1_TIPO','E1_NATUREZ','E1_CLIENTE','E1_LOJA','E1_NOMCLI','E1_EMISSAO',;
	'E1_VENCTO','E1_VENCREA','E1_VALOR'})

	// Definição do filtro de aplicacao
	oMark:SetFilterDefault( cFiltro )

	//Definir o menu a utilizar
	oMark:SetMenuDef("PGTOSP")

	oMark:SetSemaphore(.F.)

	//Executado logo apos a marcação Individual
	oMark:SetAfterMArk( {|| recMarca()} )

	//Desabilitando marca todos canto browser
	oMark:SetAllMark( {|| U_allMarca() }  )

	// Ativacao da classe
	oMark:Activate()
	Return nil

	*****************************
Static Function MenuDef()
	*****************************
	//Definições de menu e funões chamadas

	Local aRotina := {}
	ADD OPTION aRotina TITLE 'GERAR' 		ACTION 'U_geraMark()' 	OPERATION 3 ACCESS 0 
	ADD OPTION aRotina TITLE 'Nro.BORD' 	ACTION 'U_verNro()' 	OPERATION 4 ACCESS 1
	ADD OPTION aRotina TITLE 'FECHAR' 		ACTION 'U_feharMark()' 	OPERATION 3 ACCESS 2
	ADD OPTION aRotina TITLE 'TODOS' 		ACTION 'U_allMarca()' 	OPERATION 4 ACCESS 2

	Return aRotina                          

	*************************************
User Function feharMark()
	*************************************

	CloseBrowse()	

	Return nil

	*************************************
User Function verNro()
	*************************************
	local oSeq		:= nil
	oSeq := cbcCtrlSeq():newcbcCtrlSeq()
	MessageBox( "Marca " + oMark:Mark() +  CRLF +  " BORDERO Nro.:  " + oSeq:getNext("SE1", "E1_ZZBOR1", " SUBSTRING(E1_ZZBOR1,1,1) = '9' AND %SE1.NOTDEL% "),"INFORMATIVO",0) 
	
	FreeObj(oSeq)
	Return nil

	************************************
Static Function recMarca()
	//FWMarkBrowser não gera a marcação como o esperado
	//Fiz a marcação eu mesmo
	************************************

	//Verifica se o registro esta marcado
	If oMark:IsMark()

		reclock("SE1", .F.)
		SE1->E1_ZZOK := oMark:Mark() //Chumba a marca
		SE1->(Msunlock())

	Else
		reclock("SE1", .F.)
		SE1->E1_ZZOK := ""  //Quando desmarcar o registro retira a marca
		SE1->(Msunlock())
	EndIf    

	Return Nil

	************************************
User Function allMarca()
	•************************************
	//Utilizado para marcar quando selecionado todos
	Local nRegAtual
	Local lMarca := .T.

	oMark:SetInvert(.T.)
	oMark:AllMark()

	//Posiciona no primeiro do browser
	oMark:GoTop(.T.)
	//Obtem o numero do registro
	nRegAtual := oMark:At()

	//Percorrer os registros do browser 
	While .T.

		//Verifica se o registro esta marcado
		If oMark:IsMark()

			reclock("SE1", .F.)
			SE1->E1_ZZOK := ""  //Quando desmarcar o registro retira a marca
			SE1->(Msunlock()) 
			lMarca := .F.

		Else
			reclock("SE1", .F.)
			SE1->E1_ZZOK := oMark:Mark() //Chumba a marca
			SE1->(Msunlock()) 

		EndIf    

		//Passa para o proximo registro 
		oMark:GoDown(1, .F.)

		//Saida do loop Desceu um registro e continuou no mesmo significa que é o ultimo
		If nRegAtual == oMark:At()

			EXIT

		EndIf

		//Obtem o numero do registro para comparar se é o ultimo
		nRegAtual := oMark:At() 

	EndDo

	//Atualiza Browser e posiciona no primeiro
	oMark:Refresh(.T.)

	If lMarca
		If ApMsgYesNo("Marcação concluida, gerar correspondencia?")

			U_geraMark()

		EndIf    
	Else

		MessageBox("Titulos desmarcados","AVISO",0)

	EndIf

	Return Nil

	*************************************
Static Function ModelDef()
	*************************************
	//Definição do modelo de dados
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruSE1 := FWFormStruct( 1, 'SE1' )
	Local oModel // Modelo de dados que serÃ¡ construÃ­do
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New('COMP011M' )
	// Adiciona ao modelo um componente de formulÃ¡rio
	oModel:AddFields( 'SE1MASTER', /*cOwner*/, oStruSE1)
	// Adiciona a descrição do Modelo de Dados
	oModel:SetDescription( 'Bordero' )
	// Adiciona a descrição do Componente do Modelo de Dados
	oModel:GetModel( 'SE1MASTER' ):SetDescription( 'Bordero' )
	// Retorna o Modelo de dados

	Return oModel


	********************************
Static Function ViewDef()
	********************************

	//Definições de exibição/visualização
	// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
	Local oModel := FWLoadModel( 'PGTOSP' )
	// Cria a estrutura a ser usada na View
	Local oStruSE1 := FWFormStruct( 2, 'SE1' )
	// Interface de visualização construÃ­da
	Local oView
	// Cria o objeto de View
	oView := FWFormView():New()
	// Define qual o Modelo de dados será¡ utilizado na View
	oView:SetModel( oModel )
	// Adiciona no nosso View um controle do tipo formulário
	// (antiga Enchoice)
	oView:AddField( 'VIEW_SE1', oStruSE1, 'SE1MASTER' )
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'TELA' , 100 )
	// Relaciona o identificador (ID) da View com o "box" para exibição
	oView:SetOwnerView( 'VIEW_SE1', 'TELA' )
	// Retorna o objeto de View criado
	Return oView

	****************************
User Function geraMark()
	****************************

	Local aArea 		:= GetArea()
	Local cMarca 		:= oMark:Mark()
	Local nTotalBord 	
	Local nLinha 		:= 1
	Local cHistorico
	Local aItens 		:= {}
	Local lAchou		:= .F.
	local oSeq		:= nil
	Private nBordero


	//[HOM] VALIDAR CASO NÂO SELECIONE MARCA
	If Empty(cMarca)

		Alert("Selecione pelo menos um titulo")
		Return NIL	

	EndIf

	DbSelectArea("SE1")
	SE1->(DbOrderNickName("BORDSP")) //E1_FILIAL+DTOS(E1_VENCREA)+E1_OK

	//Fechar e excluir arquivo de trabalho
	If Select( "TRBSE1") > 0
		TRBSE1->(dbcloseArea())
		FErase( "TRBSE1" + GetDbExtension())
	End If

	//Variavel where da query de sql dDtaInicial
	//cSQL := " AND ( SE1.E1_VENCREA >=  '" + DtoS(dDtaInicial) + "'  AND SE1.E1_VENCREA <= '" + DtoS(dDtaFinal) + "' ) "

	//[HOM]-OCORRENCIA DEIXAR O FILTRO IGUAL PARA MONTAGEM DA TELA 
	cSQL := " AND ( SE1.E1_EMISSAO >=  '" + dTos(dEmiInicial) + "' ) "
	cSQL += " AND SE1.E1_ZZOK = '" + cMarca + "'"
	cSQL := "%"+cSQL+"%"

	//Consulta no banco
	BeginSQL Alias "TRBSE1"

	SELECT SE1.E1_ZZOK,SE1.R_E_C_N_O_
	FROM %Table:SE1% SE1
	WHERE SE1.E1_FILIAL = %xFilial:SE1% AND SE1.%NotDel% %exp:cSQL%
	ORDER BY %Order:SE1,1%

	EndSql

	DbSelectArea("SE1")
	DbSelectArea("TRBSE1")
	TRBSE1->(DbGotop())

	nTotalBord := 0

	//[HOM] VALIDAR CASO NÂO SELECIONE MARCA
	If TRBSE1->(EOF())

		Alert("Marca não encontrada")
		Return NIL	

	EndIf  •


	//OBTEM O NUMERO SEQUENCIA LOGO ANTES DE USA-LO
	oSeq := cbcCtrlSeq():newcbcCtrlSeq()
	nBordero := oSeq:getNext("SE1", "E1_ZZBOR1", " SUBSTRING(E1_ZZBOR1,1,1) = '9' AND %SE1.NOTDEL% ")
	if ! oSeq:lOk
		MsgAlert(oSeq:cMsgErr, 'Proximo Numero')
		return(nil)
	endif
	
	
	While !TRBSE1->(EOF())
		//Ele realiza a comparação da marcação do arquivo TRBSE1
		If oMark:IsMark(cMarca)

			SE1->( dbgoto( TRBSE1->(R_E_C_N_O_)  ) )
			reclock("SE1", .F.)
			SE1->E1_ZZBC2 	:= "000"
			SE1->E1_ZZDTBOR	:= dDataBase
			SE1->E1_ZZBOR1 	:= nBordero		
			lAchou := .T. //[HOM]-DEFINE SE ECONCONTROU ARQUIVO

			nTotalBord += SE1->(E1_SALDO)
			SE1->(msunlock())

			nLinha ++

		EndIf
		TRBSE1->( dbSkip() )
	EndDo

	If lAchou
		//Adiciona os Iitens no array para lançamento
		aAdd(aItens,{  	{'CT2_FILIAL'  	,XFilial("SE1")				, NIL},;
		{'CT2_LINHA'  	, StrZero(1,3) 				, NIL},;
		{'CT2_MOEDLC'  	,'01'   					, NIL},;
		{'CT2_DC'   	,'3'   						, NIL},;
		{'CT2_DEBITO'  	,'DEB' 						, NIL},;
		{'CT2_CREDIT'  	,'CRE' 						, NIL},;
		{'CT2_VALOR'  	, nTotalBord  				, NIL},;
		{'CT2_ORIGEM' 	,'CTBBORDRECEBER'			, NIL},;
		{'CT2_HP'   	,''   						, NIL},;
		{'CT2_EMPORI'   ,'01'   					, NIL},;
		{'CT2_FILORI'   ,XFilial("SE1")   			, NIL},;
		{'CT2_TPSALD'   ,'6'   						, NIL},;
		{'CT2_CLVLDB'   ,'1101'   					, NIL},;     //Quando Estorno o campo correto é CT2_CLVLCR,Quando estorno informar no historico
		{'CT2_HIST'   	,'CORRESP.NRO ' + nBordero  , NIL} } )
		
		//Fechar e excluir arquivo de trabalho
		If Select( "TRBSE1") > 0
			TRBSE1->(dbcloseArea())
			FErase( "TRBSE1" + GetDbExtension())
		End If

		//Lançamento CT2
		lmtoCT2(nBordero,dDataBase,aItens )
		ApMsgInfo( 'BORD. CORRESP.. Nro. ' + nBordero + ' gerada com sucesso!.' )

		//IMPRIMIR O BORDERO
		U_CDFINRSP(nBordero)

		//Confirma a utilização do numero gerado para o bordero
		oSeq:commit()
		CloseBrowse()

	Else
		Alert("Mark utilizado não encontrado")
		oSeq:commit()

	EndIf
	
	FreeObj(oSeq)

	Return NIL

	****************************************************
User Function delBord()
	****************************************************
	Local aBox			:={}
	Local aRet			:={}
	Local cSQL			:=""
	Local nTotalBord	:= 0
	Local lPortado		:=.T.
	Local aCab			:={}
	Local aItens		:={}
	Local dDataCT		:={}
	aAdd(aBox,{01,"Cancelar Bordero",space(6),"","","","",50,.T.} )

	If ParamBox(aBox,"Informe Nro. Bordero para cancelamento...",@aRet)

		//Fechar e excluir arquivo de trabalho
		If Select( "CANC") > 0
			CANC->(dbcloseArea())
			FErase( "CANC" + GetDbExtension())
		End If

		cSQL += " AND SE1.E1_ZZBOR1 = '" + aRet[1] + "'"
		cSQL += " AND CT2.CT2_TPSALD = '6'  "
		cSQL += " AND CT2.CT2_LOTE = '028850'"
		cSQL := "%"+cSQL+"%"

		//Consulta no banco
		BeginSQL Alias "CANC"

		column CT2_DATA 	as Date

		SELECT  SE1.R_E_C_N_O_ , SE1.E1_PORTADO, CT2.CT2_DATA 
		FROM %Table:SE1% SE1
		INNER JOIN %Table:CT2% CT2 ON SE1.E1_ZZBOR1 = CT2_DOC
		WHERE SE1.E1_FILIAL = %xFilial:SE1% AND SE1.%NotDel% %exp:cSQL% 

		EndSql

		CANC->(DbGoTop())

		//BUSCA RETORNOU VAZIA
		If CANC->(EOF())

			Alert("Nenhum Bordero para cancelar")			

			//RETORNOU TITULOS NA BUSCA
		Else

			//VERIFICA OS TITULOS QUE NÂO TEM PORTADOR (CONDIÇÂO PARA PODER CANCELAR BORDERO)
			While !CANC->(EOF())

				If !Empty(CANC->(E1_PORTADO))
					//TEM PORTADO PODE SAIR
					MessageBox("Bordero tem titulos em banco, não pode cancelar","Aviso",48)
					lPortado := .F.
					EXIT

				EndIF

				CANC->( dbSkip() )

			EndDo

			//SOMENTE SE NENHUM TITULO ESTIVER EM BANCO PORTADO VAZIO
			If lPortado

				CANC->(DbGoTop())

				//OBTEM DATA CT2 PARA CANCELAMENTO
				dDataCT := CANC->(CT2_DATA) 

				//REALIZA O CANCELAMENTO UM POR UM DOS TITULOS
				While !CANC->(EOF())

					SE1->( dbgoto( CANC->(R_E_C_N_O_)  ) )
					reclock("SE1", .F.)
					SE1->E1_ZZBC2 	:= ""
					SE1->E1_ZZBOR1 	:= ""		
					SE1->E1_ZZDTBOR	:= StoD("")
					SE1->(msunlock())

					nTotalBord += SE1->(E1_VALOR) 

					CANC->( dbSkip() )

				EndDo

				//EXCLUIR CONTA CORRENTE
				//Cria o cabeçalho para o lançamento
				aCab := { 	{'DDATALANC' 	,dDataCT 			,NIL},;
				{'CLOTE' 		,"028850" 			,NIL},;
				{'CSUBLOTE' 	,'001' 				,NIL},;
				{'CDOC' 		, aRet[1] 			,NIL},;
				{'CPADRAO' 		,'' 				,NIL},;
				{'NTOTINF' 		,0 					,NIL},;
				{'NTOTINFLOT' 	,0 					,NIL} }


				//Adiciona os Iitens no array para lançamento
				aAdd(aItens,{  	{'CT2_FILIAL'  	,XFilial("SE1")				, NIL},;
				{'CT2_LINHA'  	, StrZero(1,3) 				, NIL},;
				{'CT2_MOEDLC'  	,'01'   					, NIL},;
				{'CT2_DC'   	,'3'   						, NIL},;
				{'CT2_DEBITO'  	,'DEB' 						, NIL},;
				{'CT2_CREDIT'  	,'CRE' 						, NIL},;
				{'CT2_VALOR'  	, nTotalBord  				, NIL},;
				{'CT2_ORIGEM' 	,'CTBBORDRECEBER'			, NIL},;
				{'CT2_HP'   	,''   						, NIL},;
				{'CT2_EMPORI'   ,'01'   					, NIL},;
				{'CT2_FILORI'   ,XFilial("SE1")   			, NIL},;
				{'CT2_TPSALD'   ,'6'   						, NIL},;
				{'CT2_CLVLDB'   ,'1101'   					, NIL},;  
				{'CT2_HIST'   	,'CANC. CORRESP.NRO ' + aRet[1]  , NIL} } )    


				excluirCt2(aCab,aItens)

				MessageBox("Bordero excluido","Aviso",01)

			EndIf

		EndIf  •

	EndIf

	//Fechar e excluir arquivo de trabalho
	If Select( "CANC") > 0
		CANC->(dbcloseArea())
		FErase( "CANC" + GetDbExtension())
	End If


	Return nil


	*****************************************************
Static Function lmtoCT2(cNroBord,dDtBor,aItens)
	*****************************************************

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	//Cria o cabeçalho para o lançamento
	aCab := { 	{'DDATALANC' 	,dDtBor 	,NIL},;
	{'CLOTE' 		,"028850" 	,NIL},;
	{'CSUBLOTE' 	,'001' 		,NIL},;
	{'CDOC' 		, cNroBord 	,NIL},;
	{'CPADRAO' 		,'' 		,NIL},;
	{'NTOTINF' 		,0 			,NIL},;
	{'NTOTINFLOT' 	,0 			,NIL} }

	//terceiro parametro do CTBAL102
	//1=Pesquisa
	//2=Visualização
	//3=Inclusão
	//4=Alteração
	//5=Exclusão
	Begin Transaction

		MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)

		_cErrLog := MOSTRAERRO("C:\Temp","siga.log")

		If !Empty(_cErrLog)

			//DisarmTransaction()
			//RollbackSX8()
			//Alert(_cErrLog)

		EndIf

	End Transaction

	Return nil

	*
	****************************
Static Function exCT2(cMov)
	****************************
	*

	Local aCab  		:= {}
	Local aItens 		:= {}
	Local cSe1Hist
	Local lMsErroAuto 	:= .F.
	Local lMsHelpAuto 	:= .T.

	cSe1Hist := xFilial("SE1") + SE1->E1_PREFIXO + SE1->E1_NUM + SE1->E1_PARCELA + SE1->E1_TIPO + SE1->E1_CLIENTE + SE1->E1_LOJA +;
	SE1->E1_ZZBOR1

	//Verifica o tipo do movimento (Desconto ou Acrescimo)
	If cMov == "DEC"
		//Excluir lançamento no CT2 caso exista
		DbSelectarea("CT2")
		DbOrderNickName("CT2ORIGEM") //CT2_FILIAL+CT2_ORIGEM

		If CT2->(DbSeek(xFilial("CT2") + "RELDPL" ,.F.) ) //Procura pelos registro relacionados aos relatorios de duplicatas(alterações em titulos)

			While CT2->(!eof()).AND. Alltrim(CT2->CT2_ORIGEM) == "RELDPL" //Percorre os registros
				aItens 	:= {} //Zera os arrays a cada lançamento..precaução
				aCab	:= {}

				//Busca pelo campo CT2_HIST
				If Alltrim(CT2->CT2_HIST) == Alltrim("DESC. " + cSe1Hist)//Mudar aqui mudar fonte PE_FINA040 função FA040ALT

					//Cria o cabeçalho para o lançamento
					aCab := { 		{'DDATALANC' 	,CT2->(CT2_DATA)		,NIL},;
					{'CLOTE' 		,"018850" 				,NIL},;
					{'CSUBLOTE' 	,'001' 					,NIL},;
					{'CDOC' 		,CT2->(CT2_DOC)			,NIL},;
					{'CPADRAO' 		,'' 					,NIL},;
					{'NTOTINF' 		,0 						,NIL},;
					{'NTOTINFLOT' 	,0 						,NIL} }

					//criar aItens
					//Adiciona os itens no array para lançamento
					aAdd(aItens,{ 	{'CT2_FILIAL' 	,XFilial("SE1")   		, NIL},;
					{'CT2_LINHA'  	,'001'					, NIL},;
					{'CT2_MOEDLC'  	,'01'   				, NIL},;
					{'CT2_DC'   	,'3'   					, NIL},;
					{'CT2_DEBITO'  	,'DEB' 					, NIL},;
					{'CT2_CREDIT'  	,'CRE' 					, NIL},;
					{'CT2_VALOR'  	, SE1->E1_DECRESC  		, NIL},; //Ecluir o lançamento com o valor antigo
					{'CT2_ORIGEM' 	,'RELDPL'				, NIL},;
					{'CT2_HP'   	,''   					, NIL},;
					{'CT2_EMPORI'   ,'01'   				, NIL},;
					{'CT2_FILORI'   ,XFilial("SE1")   		, NIL},;
					{'CT2_TPSALD'   ,'6'   					, NIL},;
					{'CT2_CLVLCR'   ,'1101'   				, NIL},;
					{'CT2_HIST'   	,"DESC. " + cSe1Hist	, NIL} } )

					//Efetivar a exclusão
					excluirCt2(aCab,aItens)
				EndIf
				CT2->(dbskip())
			EndDo
		EndIf
	ElseIf cMov == "ACR"

		//Excluir laçamento no CT2
		DbSelectarea("CT2")
		DbOrderNickName("CT2ORIGEM") //CT2_FILIAL+CT2_ORIGEM

		If CT2->(DbSeek(xFilial("CT2") + "RELDPL" ,.F.)) //Procura pelos registro relacionados aos relatorios de duplicatas
			While CT2->(!eof() .AND. Alltrim(CT2->CT2_ORIGEM) == "RELDPL" ) //Percorre os registros
				aItens 	:= {} //Zera o array a cada lançamento..precaução
				aCab	:= {}
				//Busca pelo campo CT2_HIST
				If Alltrim (CT2->CT2_HIST) == Alltrim("ACRES. " + cSe1Hist)//Mudar aqui mudar fonte PE_FINA040 função FA040ALT

					//Cria o cabeçalho para o lançamento
					aCab := { 	{'DDATALANC' 	,CT2->(CT2_DATA)		,NIL},;
					{'CLOTE' 		,"018850" 				,NIL},;
					{'CSUBLOTE' 	,'001' 					,NIL},;
					{'CDOC' 		,CT2->(CT2_DOC)			,NIL},;
					{'CPADRAO' 		,'' 					,NIL},;
					{'NTOTINF' 		,0 						,NIL},;
					{'NTOTINFLOT' 	,0 						,NIL} }
					//criar aItens
					//Adiciona os itens no array para lanï¿½amento
					aAdd(aItens,{ 	{'CT2_FILIAL'  	,XFilial("SE1")   		, NIL},;
					{'CT2_LINHA'  	,'001'					, NIL},;
					{'CT2_MOEDLC'  	,'01'   				, NIL},;
					{'CT2_DC'   	,'3'   					, NIL},;
					{'CT2_DEBITO'  	,'DEB' 					, NIL},;
					{'CT2_CREDIT'  	,'CRE' 					, NIL},;
					{'CT2_VALOR'  	, SE1->E1_ACRESC  		, NIL},;//Ecluir o lanÃ§amento com o valor antigo
					{'CT2_ORIGEM' 	,'RELDPL'				, NIL},;
					{'CT2_HP'   	,''   					, NIL},;
					{'CT2_EMPORI'   ,'01'   				, NIL},;
					{'CT2_FILORI'   ,XFilial("SE1")   		, NIL},;
					{'CT2_TPSALD'   ,'6'   					, NIL},;
					{'CT2_CLVLDB'   ,'1101'   				, NIL},;
					{'CT2_HIST'   	,"ACRES. " + cSe1Hist	, NIL} } )
					//Efetivar a exclusão
					excluirCt2(aCab,aItens)
				EndIf
				CT2->(dbskip())
			EndDo
		EndIf
	EndIf

	Return nil

	*
	****************************
Static Function excluirCt2(aCab,aItens)
	****************************
	*
	Local lMsErroAuto := .F.
	Local lMsHelpAuto := .T.

	Begin Transaction
		MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 5)

		_cErrLog := MOSTRAERRO("C:\Temp","siga.log")

		If !Empty(_cErrLog)

			DisarmTransaction()
			Alert(_cErrLog)

		EndIf

	End Transaction

	Return


	****************************************************************
Static Function CriaSX1(cPerg) //CRIAR SX1 PERGUNTAS
	****************************************************************

	Local aHelp :={}

	//FORNECEDOR
	AAdd(aHelp, { {"Informe o cliente para filtro"}, {""},{""} }  )
	PutSX1(cPerg,	"01","Cliente          ?","","","mv_ch1","C",TamSX3("A1_COD")[1],00,00,"G","","SA1CLI",;
	"","","mv_Par01","","","","","","","","","","","","","","","","",aHelp[1,1],aHelp[1,2],aHelp[1,3],"")

	//EMISSÂO
	AAdd(aHelp, { {"Pode se filtrar pela emissão de:"}, {""},{""} }  )
	PutSX1(cPerg,	"02","Emissão de          ?","","","mv_ch2","D",TamSX3("E1_EMISSAO")[1],00,00,"G","","",;
	"","","mv_Par02","","","","","","","","","","","","","","","","",aHelp[2,1],aHelp[2,2],aHelp[2,3],"")

	AAdd(aHelp, { {"Pode se filtrar pela emissão ate:"}, {""},{""} }  )
	PutSX1(cPerg,	"03","Emissão até          ?","","","mv_ch3","D",TamSX3("E1_EMISSAO")[1],00,00,"G","","",;
	"","","mv_Par03","","","","","","","","","","","","","","","","",aHelp[3,1],aHelp[3,2],aHelp[3,3],"")

	//VENCIMENTO
	AAdd(aHelp, { {"Pode se filtrar pelo vencimento de:"}, {""},{""} }  )
	PutSX1(cPerg,	"04","Vencimento de          ?","","","mv_ch4","D",TamSX3("E1_VENCREA")[1],00,00,"G","","",;
	"","","mv_Par04","","","","","","","","","","","","","","","","",aHelp[4,1],aHelp[4,2],aHelp[4,3],"")

	AAdd(aHelp, { {"Pode se filtrar pelo vencimento até:"}, {""},{""} }  )
	PutSX1(cPerg,	"05","Vencimento até          ?","","","mv_ch5","D",TamSX3("E1_VENCREA")[1],00,00,"G","","",;
	"","","mv_Par05","","","","","","","","","","","","","","","","",aHelp[5,1],aHelp[5,2],aHelp[5,3],"")

Return