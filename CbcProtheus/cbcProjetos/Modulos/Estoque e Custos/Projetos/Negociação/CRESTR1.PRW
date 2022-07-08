#Include "protheus.ch"
#Include "topconn.ch"
static lNewSdc := GetNewPar('ZZ_SDCNEW', .T.)

/*/{Protheus.doc} CREstR1
//TODO Exibir tela para atender pedido de venda com estoque.
@author Robert Santos 
@since 27/03/2013
@version undefined

@type function
/*/
User Function CREstR1()   // Roberto - Função principal
	Local cPerg := "CRESTR1   "
	
	Local aSize		:= GetScreenRes()
	Local nLargura	:= aSize[1] - (aSize[1] * 0.033)
	Local nAltura	:= aSize[2] - (aSize[2] * 0.23)
	
	Private aXZZE	:= {}
	Private lZZE , nZZE
	
	Private aSdPv := {} // registrar vinculo Saldo marcado x Pedido venda marcado, exemplo x[1,1] == SD_BOBIN x[1,2] == PV_ID //
	
	Private SD_MARCA:=01 // COLUNAS DA TELA DE SEPARACAO - LISTA DE SALDO
	Private SD_MCNEG:=02
	Private SD_ACOND:=03
	Private SD_ALMOX:=04
	Private SD_METRA:=05
	Private SD_LANCE:=06
	Private SD_TOTAL:=07
	Private SD_USADO:=08
	Private SD_USADL:=09
	Private SD_RETRA:=10
	Private SD_BOBIN:=11
	Private SD_SEQCL:=12
	Private SD_ORIG :=13
	Private SD_IDRE :=14 // ID DO RETRABALHO
	Private SD_TPBOB:=15
	
	Private PV_MARCA :=	01 // COLUNAS DA TELA DE SEPARACAO - LISTA DE PEDIDO DE VENDAS
	Private PV_MCNEG :=	02
	Private PV_PEDID :=	03
	Private PV_ITEM	 :=	04
	Private PV_SEQUE :=	05
	Private PV_ACOND :=	06
	Private PV_METRA :=	07
	Private PV_LANCE :=	08
	Private PV_TOTAL :=	09
	Private PV_USADO :=	10
	Private PV_USADL :=	11
	Private PV_CLIEN :=	12
	Private PV_LOJA	 :=	13
	Private PV_NOMEC :=	14
	Private PV_ENTRE :=	15
	Private PV_SEQCL :=	16
	Private PV_ID :=	17 // ID UNICO
	Private PV_XPCP  := 18
	Private PV_PRODU := 19
	Private PV_NEGOC := 20 // STATUS DA NEGOCIACAO
	
	Private AL_MARCA :=	01 // COLUNAS DA TELA DE SEPARACAO - LISTA DE PRODUTOS ALTERNATIVOS
	Private AL_PRODU :=	02
	Private AL_ACOND :=	03
	Private AL_METRA :=	04
	Private AL_LANCE :=	05
	Private AL_TOTAL :=	06
	Private AL_USADO :=	07
	Private AL_USADL :=	08
	Private AL_RETRA :=	09
	Private AL_BOBIN :=	10
	Private AL_DESCR :=	11
	Private AL_ALMOX :=	12
	Private AL_TPBOB :=	13
	
	Private V1_MARCA :=	01 // POSICOES DA LISTA DE PEDIDO DE VENDA DA PRIMEIRA TELA - FILTRADOS
	Private V1_PEDID :=	02
	Private V1_ITEM	 :=	03
	Private V1_PRODU :=	04
	Private V1_CLIEN :=	05
	Private V1_LOJA	 :=	06
	Private V1_NOMEC :=	07
	Private V1_ACOND :=	08
	Private V1_METRA :=	09
	Private V1_LANCE :=	10
	Private V1_TOTAL :=	11
	Private V1_ENTRE :=	12
	Private V1_SEQUE :=	13
	Private V1_XPCP :=	14
	Private V1_NEGOC :=	15 // STATUS DA NEGOCIACAO
	
	Private lParar := .F.
	
	Private oOk		:= LoadBitmap( GetResources(), "LBOK")
	Private oNo		:= LoadBitmap( GetResources(), "LBNO")
	
	Private oAmarelo	:= LoadBitmap( GetResources(), "BR_AMARELO")
	Private oAzul		:= LoadBitmap( GetResources(), "BR_AZUL")
	Private oVermelho	:= LoadBitmap( GetResources(), "BR_VERMELHO")
	Private oPink		:= LoadBitmap( GetResources(), "BR_PINK")
	Private oMarrom		:= LoadBitmap( GetResources(), "BR_MARROM")
	Private oBranco		:= LoadBitmap( GetResources(), "BR_BRANCO")
	Private oVerde		:= LoadBitmap( GetResources(), "BR_VERDE")
	Private oPreto		:= LoadBitmap( GetResources(), "BR_PRETO")
	
	If oApp:lMdi
		ValidPerg( cPerg )
		If pergunte( cPerg, .T.)
			/*/
			If MV_PAR10 == 2 .And. cUserName # "ROBERTO" // If(MV_PAR10==1," - Pedidos Novos", " - Pedidos em Produção")
				Alert("Atenção: Rotina Habilitada Somente Para Pedidos Novos - Parâmente 10 Alterado para Pedidos Novos")
				MV_PAR10 := 1
			EndIf
			/*/
			SC5->(DbSetOrder(1))
			Tela01() // Mostrar tela dos pedidos antes de fazer separacao
		EndIf
	Else
		Alert("Esta rotina precisa ser executada através do programa inicial: SIGAMDI")
	EndIf
Return(.T.)


/*/{Protheus.doc} Tela01
//TODO Tela de escolher itens de pedidos de venda antes de processar.
@author Robert Santos
@since 27/03/2013
@version undefined

@type function
/*/
Static Function Tela01()// Roberto
	Local aSize		:= GetScreenRes() //Variaveis de Largura/Altura da Janela
	Local nLargura  := aSize[1]-(aSize[1]*0.033)
	Local nAltura   := aSize[2]-(aSize[2]*0.23)
	Local nLargObj	:= (nLargura * (0.5)) - 5
	Local nAltObj	:= (nAltura * (0.5)) - 5
	local cCombo	:= "04"
	Static oOrdPV1	:= nil
	Static oDlg1 	:= nil
	
	Static oTela02
	Static oGridSD, oGridPV, oGridAL
	
	DEFINE MSDIALOG oDlg1 TITLE "Selecionar Itens Pedido Venda" + If(MV_PAR10==1," - Pedidos Novos", " - Pedidos em Produção") FROM 10,0 TO nAltura,nLargura OF oMainWnd PIXEL // Interface tela
	
	@ 005 , 005 SAY oSay1 PROMPT "Ordenar por: " SIZE 150, 007 OF oDlg1 COLORS 0, 16777215 Pixel
	@ 005 , 045 COMBOBOX oOrdPV1 var cCombo ITEMS {"Pedido","Cliente","Produto","Data Entrega"} Size 60,10 of oDlg1 pixel
	oOrdPV1:bChange := {|| ChCbPV1() }	
	@ 005 , 110 BUTTON oButton1 PROMPT "Marcar Tudo" SIZE 037, 010 OF oDlg1 Action {|| McaPV1( .T. )} PIXEL
	@ 005 , 150 BUTTON oButton2 PROMPT "Desmarcar Tudo" SIZE 047, 010 OF oDlg1 Action { || McaPV1( .F. ) } PIXEL
	
	GridPV1( 020 , 005 , (nAltObj * (0.80)) ,nLargObj-25 )
	
	@ nAltObj-030 , 005 BUTTON oButton PROMPT "Processar" SIZE 037, 010 OF oDlg1 Action { || ProcT01() } PIXEL
	@ nAltObj-030 , 045 BUTTON oButton PROMPT "Filtrar"   SIZE 037, 010 OF oDlg1 Action { || FTela01( oDlg1 ) } PIXEL
	@ nAltObj-030 , 085 BUTTON oButton PROMPT "Sair"      SIZE 037, 010 OF oDlg1 Action { || saitela() } PIXEL
	
	ACTIVATE MSDIALOG oDlg1 CENTERED

Return(.T.) //nil


/*/{Protheus.doc} Saitela
//TODO Ação do botão SAIR.
@author Robert Santos
@since 27/03/2013
@version undefined

@type function
/*/
Static Function Saitela()// Roberto
	If MsgYesNo("Confirma sair ?")
		oDlg1:Refresh()
		oDlg1:End()
	EndIf
Return(.T.)


/*/{Protheus.doc} ChCbPV1
//TODO Chaves de ordenação.
@author Robert Santos
@since 27/03/2013
@version undefined

@type function
/*/
Static Function ChCbPV1()
	Do Case
		Case oOrdPV1:nAt == 1
			oGridPV1:aArray := aSort( oGridPV1:aArray , , , { |x,y| x[V1_PEDID]+x[V1_ITEM] <= y[V1_PEDID]+y[V1_ITEM] } ) // ordenar por pedido
		Case oOrdPV1:nAt == 2
			oGridPV1:aArray := aSort( oGridPV1:aArray, , , { |x,y| x[V1_CLIEN]+x[V1_LOJA] >= y[V1_CLIEN]+y[V1_LOJA] } ) // ordenar por cliente
		Case oOrdPV1:nAt == 3
			oGridPV1:aArray := aSort( oGridPV1:aArray, , , { |x,y| x[V1_PRODU] >= y[V1_PRODU] } ) // ordenar por produto
		Case oOrdPV1:nAt == 4
			oGridPV1:aArray := aSort( oGridPV1:aArray, , , { |x,y| (x[V1_ENTRE]) <= (y[V1_ENTRE]) } ) // ordenar por data
	EndCase
	oGridPV1:Refresh()
Return(.T.)


/*/{Protheus.doc} ProcT01
//TODO Processar pedidos marcados, deve separar por produto .
@author Robert Santos
@since 27/03/2013
@version undefined

@type function
/*/
Static Function ProcT01()    // Roberto
	Local aProdut	:= {}
	Local i,j,k, nID
	Local aBak		:= aClone( oGridPv1:aArray )
	Local aPedido	:= aClone( aSort( oGridPv1:aArray , , , {|x,y| x[2] >= y[2] } ) )
	Local aC9		:= {}
	Local aPv1		:= {}
	
	lParar := .F.
	
	For i:=1 to len(aPedido) // separar produtos para processar
		If aPedido[i,1] // apenas pedidos marcados
			If( aScan(aProdut, { |x| x[1] == aPedido[i,4]} ) == 0 ) // processar so um produto de varios pedidos selecionados
				aAdd( aProdut , { aPedido[i,4], aPedido[i,2] } )
			EndIf
		EndIf
	Next
	
	nId := 0
	For i :=1 to len( aProdut )
		If lParar == .F.
			j := aScan( aPedido, { |x| x[2] == aProdut[i,2]} )
			aC9 := {}
			Do While .T.
				If( apedido[j,1] .And. apedido[j,4] == aProdut[i,1] )
					// asc9		=>	"", "Pedido","Item", "Sequenc.", "Acondic.", "Tam. Lance","Lance","Total", "Qtde.Utilizada","Usado Lance", "Cliente", "Loja", "Nome Cliente", "Dt.Entrega" ;
					If .T. // ! apedido[j,8] $ "R/M/C" // NAO AGLUTINAR ITENS NO PEDIDO ?
						If apedido[j,11] > 0
							// FUNÇÃO SEM SENTIDO  		aStNeg := RtStNeg(xFilial("SC6"),apedido[j,2],apedido[j,3]) // BUSCAR TODOS STATUS EM NEGOCIACAO DO ITEM
							//	nStNeg := 1
							nQtdLances := Int(( apedido[j,11] / apedido[j,09] ))
							For k := 1 to nQtdLances
								nId ++
								aadd( aC9 , { ;
								.F.,;
								.F.,;
								apedido[j,2],;
								apedido[j,3],;
								apedido[j,13],;
								dAcond(apedido[j,8]),;
								apedido[j,9],;
								1,;
								apedido[j,9],;
								0,;
								0,;
								apedido[j,5],;
								apedido[j,6],;
								apedido[j,7],;
								apedido[j,12],;
								"",;
								nId,;
								aPedido[j,V1_XPCP], ;
								aProdut[i,1], ;
								" " ;// iIf(nStNeg > len(aStNeg)," ",aStNeg[nStNeg]) ;
								})
								//nStNeg ++
							Next
						EndIf
					Else
						nId ++
						aadd( aC9 , { ;
						.F.,;
						.F.,;
						apedido[j,2],;
						apedido[j,3],;
						apedido[j,13],;
						dAcond(apedido[j,8]),;
						apedido[j,9],;
						int(apedido[j,11]/apedido[j,9]),;
						(apedido[j,11]),;
						0,;
						0,;
						apedido[j,5],;
						apedido[j,6],;
						apedido[j,7],;
						apedido[j,12],;
						" ",;
						nId,;
						aPedido[j,V1_XPCP], ;
						aProdut[i,1], ;
						aPedido[j,V1_NEGOC] ;
						})
					EndIf
				EndIf
				
				j ++
				If !(j <= len(aPedido))
					exit
				EndIf
			EndDo
			SB1->(DbSeek(xFilial("SB1")+aProdut[i,1]))
			
			MtaTela(aC9)
		EndIf
	Next
	
	pergunte( "CRESTR1   " , .F. ) // reprocessar pedidos de entrada
	MSGRUN("Aguarde..","Aguarde..",{|| FillPV1( @aPV1 )})
	If Empty(aPV1)
		aPv1 := RsetApv1()
	EndIf
	
	oGridPv1:aArray := aClone( aPv1 )
	oGridPv1:Refresh()

Return(.T.)


/*/{Protheus.doc} FTEla01
//TODO Mostrar tela dos pedidos antes de fazer separacao.
@author Robert Santos
@since 27/03/2013
@version undefined

@type function
/*/
Static Function FTEla01()// Roberto
	Local cPerg := "CRESTR1   "
	
	If MsgYesNo("Deseja continuar? Você perderá os dados selecionados.")
		ValidPerg( cPerg )
		If pergunte( cPerg, .T.)
			Tela01( ) // Mostrar tela dos pedidos antes de fazer separacao
		EndIf
	EndIf

Return(.T.)

/*/{Protheus.doc} McaPv1
//TODO Marca/desmarca todas as linhas.
@author Robert Santos
@since 27/03/2013
@version undefined
@param lMarcar, logical, descricao
@type function
/*/
Static Function McaPv1(lMarcar) // Roberto// 
	Local i
	For i := 1 to len( oGridPV1:aArray )
		oGridPV1:aArray[i,1] := lMarcar
	Next
	oGridPV1:Refresh()
Return(.T.)


/*/{Protheus.doc} GridPV1
//TODO Grid de Produtos X Pedidos.
@author Robert Santos
@since 27/03/2013
@version undefined
@param nAltIni, numeric, descricao
@param nColIni, numeric, descricao
@param nAltFin, numeric, descricao
@param nLargFin, numeric, descricao
@type function
/*/
Static Function GridPV1(nAltIni,nColIni,nAltFin,nLargFin )// Roberto
	Local aPV1		:= {}
	Static oGridPV1	:= nil
	
	@ nAltIni,nColIni LISTBOX oGridPV1 FIELDS HEADER ;
	"", "Pedido","Item", "Produto", "Cliente", "Loja", "Nome Cliente", "Acondic.", "Metragem", "Lance", "Total", "Dt.Entrega", "Sequencia", "Analisado" ;
	SIZE nLargFin,nAltFin OF oDlg1 PIXEL
	MsgRun("Buscando dados conforme parâmetros.......favor aguarde", "Seleção de dados", {|| FillPV1( @aPV1) } )
	
	If Empty(aPV1)
		aPv1 := RsetAPV1()
	EndIf
	
	oGridPV1:SetArray( aPV1 )
	
	oGridPV1:blDblClick := {|| SelPV1() }
	
	oGridPV1:bLine := {|| {;
	iIf(oGridPV1:aArray[oGridPV1:nAt,1],oOk,oNo),;
	oGridPV1:aArray[oGridPV1:nAt,2],;
	oGridPV1:aArray[oGridPV1:nAt,3],;
	oGridPV1:aArray[oGridPV1:nAt,4],;
	oGridPV1:aArray[oGridPV1:nAt,5],;
	oGridPV1:aArray[oGridPV1:nAt,6],;
	oGridPV1:aArray[oGridPV1:nAt,7],;
	oGridPV1:aArray[oGridPV1:nAt,8],;
	oGridPV1:aArray[oGridPV1:nAt,9],;
	oGridPV1:aArray[oGridPV1:nAt,10],;
	oGridPV1:aArray[oGridPV1:nAt,11],;
	oGridPV1:aArray[oGridPV1:nAt,12],;
	oGridPV1:aArray[oGridPV1:nAt,13],;
	oGridPV1:aArray[oGridPV1:nAt,14],;
	oGridPV1:aArray[oGridPV1:nAt,15],;
	}}

Return(.T.)


/*/{Protheus.doc} SelPV1
//TODO Marca/Desmarca a linha.
@author Roberto
@since 27/03/2013
@version undefined

@type function
/*/
Static Function SelPV1() 
	If( oGridPV1:aArray[oGridPv1:nat, 1] )
		oGridPV1:aArray[oGridPv1:nat, 1] := .F.
	Else
		oGridPV1:aArray[oGridPv1:nat, 1] := .T.
	EndIf
	
	oGridPV1:Refresh()

Return(.T.)


/*/{Protheus.doc} FillPV1
//TODO Monta Pedidos a mostrar.
@author Robert Santos
@since 27/03/2013
@version undefined
@param aPV1, array, descricao
@type function
/*/
Static Function FillPV1(aPV1)// Roberto
	Local cqry, nqry, aC9, nQtdLances, ni, nj
	Local aHistSd := {}
	Local nZZD_PRODUT := TamSX3("ZZD_PRODUT")[1]
	
	cqry := ""// selecionar os produtos de pedidos
	cqry += " SELECT C9.R_E_C_N_O_ nC9, C6.R_E_C_N_O_ nC6, C9_PEDIDO from "+RetSqlName("SC9")+" C9 "
	
	cqry += " inner join "+RetSqlName("SC6")+" C6 on '' = C6.D_E_L_E_T_ "
	cqry += " and C6_FILIAL = C9_FILIAL and C6_PRODUTO = C9_PRODUTO "
	cqry += " and C6_NUM = C9_PEDIDO and C6_ITEM = C9_ITEM "
	/*
	Observação Parte 1
	Dia 22/10/2015 Vitor reclamou que os pedidos de industrialização não estão aparecendo neste processo.
	Conforme abaixo, esses pedidos não aparecem mas devem aparecer para RETRABALHO.
	Estamos desabilitando esta linha e orientando Vitor e Natanael que NÃO DEVEM FAZER NEGOCIAÇÕES 
	PRA A PRÓRPIA COBRECOM - SOMENTE RETRABALHO.
	*/
	/*
	Observação Parte 2
	Conforme tivemos alguns casos em 15/02/2016 de pedidos de industrialização que foram negociados pra retrabalho mas não tiveram seus pedidos
	de venda Cliente (Tres Lagoas) alterados, os pedidos ficaram divergentes.
	Foi realizada a habilitação do filtro para que os pedidos de Industrialização não apareçam nesta rotina.
	Conforme solicitação.
	*/
	//cqry += " and C6_ZZPVORI = ' '  " // Não negociar pedidos de industrialização // By Roberto/Jeferson/Leonardo 09/09/15 //Verificar Obs acima
	cqry += " and C6_ENTREG between '"+dtos(mv_par07)+"' and '"+dtos(mv_par08)+"' "
	/*/
	cqry += " and  C6_XNEGOC = ' ' "  // Itens que já tenham entrado em ALGUMA negociação não pode entrar mais, 
	// mesmo que tenha sido recusado.
	/*/								  
	
	// By Roberto Oliveira 12/01/15
	cqry += " inner join "+RetSqlName("SC5")+" C5 on C5.D_E_L_E_T_ = ' ' "
	cqry += " and C5_FILIAL = C9_FILIAL and C5_NUM = C9_PEDIDO "
	cqry += " and (C5_DRC = 0 OR C5_DRCPROD = 'S')" // Não é devolução e se for vai produzir
	// Fim By Roberto Oliveira 12/01/15
	
	cqry += " where C9.D_E_L_E_T_ = ' ' "
	cqry += " and  C9_PRODUTO between '"+mv_par01+"' and '"+mv_par02+"' "
	cqry += " and  C9_CLIENTE + C9_LOJA between '"+mv_par03+mv_par04+"' and '"+mv_par05+mv_par06+"' "
	//cqry += " and  C9_BLCRED = '  ' and C9_BLEST = '02' "
	cqry += " and  C9_BLCRED = '  ' "  // AIRTON
	cqry += " and  C9_BLEST = '02' "  // By Roberto Oliveira 19/06/15
	cqry += " and  C9_FILIAL = '"+xFilial("SC9")+"' "
	If MV_PAR10==1 // " Pedidos Novos"
		cqry += " AND (C6_SEMANA = '       ' OR (LEFT(C6_SEMANA,1) IN ('N','R','r') AND C6_LANCES > (C6_XQTDNEG+C6_XQTDRET)))" // Pode não ter negociado tudo
	Else // Pedidos já incluidos em uma produção mas que nunca tenham sido negociados
		cqry += " AND C6_SEMANA between '0000000' and '9999999' "
		cqry += " AND (C6_XQTDNEG+C6_XQTDRET) = 0"
		// Pode não ter negociado tudo
	EndIf
	
	cqry += " Order by C6_ENTREG, C9_PRODUTO, C9_ITEM desc "
	
	If Select("TMP_BF1") > 0
		TMP_BF1->(DbCloseArea())
	EndIf
	
	TcQuery cqry New Alias "TMP_BF1"
	Count to nqry
	If nqry > 0	
		SB1->(DbSetOrder(1))
		SF4->(DbSetOrder(1))
		SA1->(DbSetOrder(1))
		SC5->(DbSetOrder(1))
		dbSelectarea("ZZD") // arquivo de produtos excluidos das listagens
		ZZD->(DbSetOrder(1))
		
		DbSelectArea("SZE")
		DbSetOrder(2) // ZE_FILIAL+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
		
		DbSelectArea("SZL")
		DbSetOrder(4) // ZL_FILIAL+ZL_NUMBOB
		
		dbSelectarea("SC9")
		SC9->(DbSetOrder(1))
		
		dbSelectarea("SC6")
		SC6->(DbSetOrder(1))
		
		// Estou alterando a lógica para tratar todos os registros do SC9 de uma vez só.
		// Da forma que está, se houver dois registros no SC9 pode dar erro na quantidade,
		// pois ele trata as quantidades do SC6 contra o SC9 e não as quantidades do SC9 (bloqueado estoque) .
		// Crio um array que tenha pedido + item e se já estiver gravado não faz de novo.
		_aC9Visto := {} // C9_PEDIDO+C9_ITEM
		
		TMP_BF1->( DbGoTop() )
		Do While !TMP_BF1->(Eof())
		
			SC9->(DbGoTo(TMP_BF1->(nC9)))
		
			If aScan( _aC9Visto,{ |x| x == SC9->C9_PEDIDO+SC9->C9_ITEM } ) > 0
				// Já vi este item
				TMP_BF1->(dbskip())
				Loop
			EndIf
		
			Aadd(_aC9Visto,SC9->C9_PEDIDO+SC9->C9_ITEM)
			_cChvSC9 := SC9->C9_PEDIDO+SC9->C9_ITEM
		
			SC6->(DbGoTo(TMP_BF1->(nC6)))
			If   Alltrim(SC6->C6_SEMANA) $ "RESERVA//ZP4"
				TMP_BF1->(dbskip())
				Loop
			EndIf
			
			If MV_PAR10 == 2 // Pedidos em Produção
				// Somente pedidos em produção que não tenham emitido etiquetas
				DbselectArea("SZ9")
				DbSetOrder(1) // Z9_FILIAL+Z9_SEMANA+Z9_PRODUTO+Z9_LOCAL+Z9_LOCALIZ+Z9_PEDIDO+Z9_ITEMPV
				_C6LOCALIZ := Left(SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5)+Space(400),Len(SZ9->Z9_LOCALIZ))
				If !(DbSeek(xFilial("SZ9")+SC6->C6_SEMANA+SC6->C6_PRODUTO+SC6->C6_LOCAL+_C6LOCALIZ+SC6->C6_NUM+SC6->C6_ITEM,.F.))
					// Não está em produção
					TMP_BF1->(dbskip())
					Loop
				EndIf
				_lPode := .T.
				Do While SZ9->Z9_FILIAL == xFilial("SZ9") .And. SZ9->(Z9_SEMANA+Z9_PRODUTO+Z9_LOCAL) == SC6->(C6_SEMANA+C6_PRODUTO+C6_LOCAL) .And. ;
						 SZ9->Z9_LOCALIZ == _C6LOCALIZ .And. SZ9->(Z9_PEDIDO+Z9_ITEMPV) == SC6->(C6_NUM+C6_ITEM) .And. SZ9->(!Eof()) .And. _lPode
				
					_lPode := (SZ9->Z9_IMPETIQ $ "N " .AND. SZ9->Z9_ETIQIMP == 0)
					SZ9->(DbSkip())
				EndDo
				If !_lPode
					TMP_BF1->(dbskip())
					Loop
				EndIf
			EndIf
				
			SB1->(DbSeek(xFilial("SB1")+SC6->(C6_PRODUTO),.F.))
			SA1->(DbSeek(xFilial("SA1")+SC6->(C6_CLI + C6_LOJA),.F.))
			SC5->(DbSeek(xFilial("SC5")+SC6->(C6_NUM),.F.))
			
			SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES,.F.))
			
			// By Roberto Oliveira 29/06/15 - Verificar se já tem bobinas prontas para este
			// pedido. Pode ocorrer de efetuar uma troca de etiqueta e depois fazer o retrabalho.
			_nQtdBobs := 0
			If SC6->C6_ACONDIC == "B"
				DbSelectArea("SZE")
				DbSetOrder(2) // ZE_FILIAL+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
				DbSeek(xFilial("SZE")+SC6->C6_NUM+SC6->C6_ITEM,.F.)
				Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->(!Eof()) .And. ;
					SZE->(ZE_PEDIDO+ZE_ITEM) == SC6->(C6_NUM+C6_ITEM)
					If SZE->ZE_STATUS # "C" // não Canceladas
						// Verifica se a pesagem não é Retorno de Retrabalho
						SZL->(DbSetOrder(4)) // ZL_FILIAL+ZL_NUMBOB
						SZL->(DbSeek(xFilial("SZL")+SZE->ZE_NUMBOB,.F.))
						If SZL->ZL_TIPO # "R" // Não é retorno de retrabalho
							_nQtdBobs++ // Soma somente e quantidade de bobinas
						EndIf
					EndIf
					SZE->(DbSkip())
				EndDo  
			EndIf
			
	
			// Este If  substitui o de baixo By Roberto Oliveira 26/01/2015
			If 	SC6->C6_ENTREG >= Mv_Par07 .And. ;
				SC6->C6_ENTREG <= Mv_Par08 .And. ;
				SF4->F4_ESTOQUE == "S" .And. ;
				(SC6->C6_LANCES-_nQtdBobs) > (SC6->C6_XQTDRET+SC6->C6_XQTDNEG) .And. ;
				(SC5->C5_DRC == 0 .Or. SC5->C5_DRCPROD == "S") .And. ;
				( (MV_PAR10 == 1 .And. Left(SC6->C6_SEMANA,1) $ " NR") .Or. (MV_PAR10 == 2 .And. SC6->C6_SEMANA>="0000000" .And. SC6->C6_SEMANA<="9999999") )
			
				cqry := "SELECT ZZD_PRODUT from " + RetSqlName("ZZD") + " WHERE D_E_L_E_T_ = ' ' AND SUBSTRING(ZZD_COD,1,5) = '" + PADR(SC6->C6_PRODUTO, 05 ) + "' "
				cQry += " AND ZZD_ACONDI = '" + SC6->(C6_ACONDIC) + "' AND ZZD_FILIAL = '" + xFilial("ZZD") + "'  "
				// Linha alterada
				//cQry += " AND ZZD_METRAG = '" + padl(alltrim(str(SC6->C6_METRAGE)),5,"0") + "'  "
				cQry += " AND ZZD_METRAG = '" + StrZero(SC6->C6_METRAGE,5) + "'  "
			
				If Select("MTMP1") > 0
					MTMP1->(DbCloseArea())
				EndIf
				TcQuery cqry New Alias "MTMP1"
				Count to nQry
				MTMP1->(DbCloseArea())
			
				If nQry == 0 // ! ZZD->(DbSeek(xFilial("ZZD")+PADR(SC9->C9_PRODUTO, 03 )+padl(alltrim(str(SC6->C6_METRAGE)),5,"0")+SC6->(C6_ACONDIC) )) // RETIRAR PRODUTOS NAO CONTROLADOS PELO PCP  AIRTON
					// ** validar se tem estoque que atende PULAR
			
					// If !Etqe( SC6->C6_PRODUTO, SC6->C6_METRAGE, (SC9->C9_QTDLIB - (SC6->C6_METRAGE * SC6->C6_XQTDRET)), SC6->(C6_ACONDIC), @aHistSd ) // RETIRAR ITEMS QUE TEM NO ESTOQUE !!
			
					// By Roberto Oliveira + Natanael em 23/04/14 14:54h, verIficamos em debug que apesar de a rotina
					// ETQE Localizar o que precisava, o If estava negando, não permitindo a entrada para adicionar em 
					// aPV1.
			
					_nQtdSC9 := 0                    
					// Daqui pra baixo troquei tudo que era SC9->C9_QTDLIB para _nQtdSC9. 29/06/2015
			
					DbSelectArea("SC9")
					DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
					DbSeek(xFilial("SC9")+_cChvSC9,.F.)
					Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO+SC9->C9_ITEM == _cChvSC9 .And. SC9->(!Eof())
						If SC9->C9_BLEST == '02'
							_nQtdSC9 += SC9->C9_QTDLIB
						EndIf
						SC9->(DbSkip())
					EndDo
			
					// If Etqe( SC6->C6_PRODUTO, SC6->C6_METRAGE, (SC9->C9_QTDLIB - (SC6->C6_METRAGE * (SC6->C6_XQTDRET+SC6->C6_XQTDNEG))), SC6->(C6_ACONDIC), @aHistSd ) // RETIRAR ITEMS QUE TEM NO ESTOQUE !!
					If Etqe( SC6->C6_PRODUTO, SC6->C6_METRAGE, (_nQtdSC9 - (SC6->C6_METRAGE * (SC6->C6_XQTDRET+SC6->C6_XQTDNEG))), SC6->(C6_ACONDIC), @aHistSd ) // RETIRAR ITEMS QUE TEM NO ESTOQUE !!
						//	If /*(SC6->C6_ACONDIC # "R" .Or. SC6->C6_METRAGE # 100) .And. SC6->C6_METRAGE <= _nMaiorLc .And.*/ Empty(SC6->C6_SEMANA)        AIRTON
						nj := aScan( aPv1, {|x| x[V1_PEDID] + x[V1_ITEM] == SC6->(C6_NUM + C6_ITEM) })
						If( nj > 0)                             
			
							//aPv1[nj,V1_TOTAL] += (SC9->C9_QTDLIB - (SC6->C6_METRAGE * (SC6->C6_XQTDRET+SC6->C6_XQTDNEG)))
			
							aPv1[nj,V1_TOTAL] += (_nQtdSC9 - (SC6->C6_METRAGE * (SC6->C6_XQTDRET+SC6->C6_XQTDNEG)))
							aPv1[nj,V1_LANCE] += Int( aPv1[nj,V1_TOTAL] / aPv1[nj,V1_METRA] )
						Else
							aadd( aPV1 , { ;
										.T.,;
										SC6->(C6_NUM),;
										SC6->(C6_ITEM),;
										SC6->(C6_PRODUTO),;
										SA1->A1_COD,;
										SA1->A1_LOJA,;
										SA1->A1_NOME,;
										dAcond(SC6->(C6_ACONDIC)),;
										SC6->C6_METRAGE,;
										int((_nQtdSC9 - (SC6->C6_METRAGE * (SC6->C6_XQTDRET+SC6->C6_XQTDNEG))) / SC6->C6_METRAGE) ,;
										(_nQtdSC9 - (SC6->C6_METRAGE * (SC6->C6_XQTDRET+SC6->C6_XQTDNEG))),;
										SC6->C6_ENTREG,;
										SC9->C9_SEQUEN, ;
										SC6->C6_XPCP, ;
										(SC6->C6_XNEGOC) ;
										})
						EndIf
					EndIf
				EndIf
			EndIf
			TMP_BF1->(dbskip())
		EndDo
		aPV1 := aSort( aPV1, , , { |x,y| (x[V1_ENTRE]) <= (y[V1_ENTRE]) } )
		oOrdPV1:nAt := 04
		oOrdPV1:Refresh()
	EndIf
	
	TMP_BF1->(DbCloseArea())

Return(.T.)


/*/{Protheus.doc} Etqe
//TODO VerIficar saldo de produto .
@author Robert Santos
@since 27/03/2013
@version undefined
@param cC6_PRODUTO, characters, descricao
@param nC6_METRAGE, numeric, descricao
@param nC9_QTDLIB, numeric, descricao
@param cC6_ACONDIC, characters, descricao
@param aHistSd, array, descricao
@type function
/*/
Static Function Etqe( cC6_PRODUTO, nC6_METRAGE, nC9_QTDLIB, cC6_ACONDIC, aHistSd )// Roberto
	Local cqry, nqry, i, nCompl
	Local lTemEst := .F.
	
	// Primeiro avalio o SBF
	cqry := ""
	cqry += " SELECT ISNULL(SUM(BF_QUANT-BF_EMPENHO),0) TOTAL "
	cQry += " from "+RetSqlName("SBF")+" BF"
	cQry += " where BF.D_E_L_E_T_ = ' ' AND BF_FILIAL = '"+xFilial("SBF")+"' and BF_LOCAL = '01' and"
	cQry += " (BF_QUANT-BF_EMPENHO) > 0 "
	cQry += " and SUBSTRING(BF_LOCALIZ,1,1) <> 'B' "
	cQry += " and BF_PRODUTO = '"+cC6_PRODUTO+"' "
	
	iIf( Select("TMP_BF5")>0,TMP_BF5->(DbCloseArea()), )
	TcQuery cqry New Alias "TMP_BF5"
	Count to nqry
	If nqry > 0
		TMP_BF5->(DbGoTop())
		
		i := ascan( aHistSd , {|x| x[1] == cC6_PRODUTO+padl(alltrim(str(nC6_METRAGE)),5,"0") })
		nCompl := 0
		If i>0
			nCompl := aHistSd[i,2]
		EndIf
		If (TMP_BF5->(TOTAL)-nCompl) >= (nC9_QTDLIB)
			lTemEst := .T.
			aadd( aHistSd, {cC6_PRODUTO+padl(alltrim(str(nC6_METRAGE)),5,"0"), nC9_QTDLIB } )
		EndIf
	EndIf
	TMP_BF5->(DbCloseArea())
	
	
	// depois avalio o SZE
	
	cqry := ""
	cqry += " SELECT ISNULL(SUM(ZE_QUANT),0) TOTAL"
	cQry += " "
	cQry += " from "+RetSqlName("SZE")+" ZE "
	cQry += " where ZE.D_E_L_E_T_ = ' ' AND ZE_FILIAL = '"+xFilial("SZE")+"' and ZE_STATUS = 'T' "
	cQry += " and ZE_PRODUTO = '"+cC6_PRODUTO+"' "
	iIf( Select("TMP_BF5")>0,TMP_BF5->(DbCloseArea()), )
	TcQuery cqry New Alias "TMP_BF5"
	Count to nqry
	If nqry > 0
		TMP_BF5->(DbGoTop())
		
		i := ascan( aHistSd , {|x| x[1] == cC6_PRODUTO+padl(alltrim(str(nC6_METRAGE)),5,"0")+cC6_ACONDIC })
		nCompl := 0
		If i>0
			nCompl := aHistSd[i,2]
		EndIf
		// If (TMP_BF5->(TOTAL)-nCompl) >= (nC9_QTDLIB)
		// Observação -> Roberto e Natanael 10/09/2014 16:30h
		// Tiramos este If porque está comparando a quantidade da somatoria das bobinas disponíveis
		// com a quantidade liberada do SC9. Acontece que se o pedido for 20.000 metros em lances de 2.000 metros
		// e tenho 3 bobinas de 4.000 metros no estoque, ele não mostra, pois faz a pergunta se, no caso,
		// 12.000 é maior ou igual a 20.000. Como não é, não deixa sequer eu usar o que tenho para poder atender
		// parte do pedido.
		lTemEst := .T.
		aadd( aHistSd, {cC6_PRODUTO+padl(alltrim(str(nC6_METRAGE)),5,"0"), nC9_QTDLIB } )
		// EndIf
	EndIf
	TMP_BF5->(DbCloseArea())
	//By Roberto/Natanael - Fim

Return(lTemEst)


/*/{Protheus.doc} MtaTela
//TODO Monta Tela.
@author Robert Santos
@since 27/03/2013
@version undefined
@param aPV, array, descricao
@type function
/*/
Static Function MtaTela(aPV)
	//Variaveis de Largura/Altura da Janela
	Local aSize		:= GetScreenRes()
	Local nLargura  := aSize[1]-(aSize[1]*0.046)
	Local nAltura   := aSize[2]-(aSize[2]*0.26)
	
	Local nLargObj		:= (nLargura*(0.5))-10
	Local nAltObj		:= (nAltura*(0.5))-5
	
	Local aButtons	:= {}
	Local nopca		:= 0
	
	Local aSD := {}
	Local aAL := {}
	
	Local nLin := 005
	Local nCol := 005
	
	Local i
	Local aC6Mark := {}
	
	// definir valores da tela
	Private cB1_COD	:= SB1->B1_COD
	Private cB1_DESC	:= SB1->B1_DESC
	
	// corte
	Private nQtdLance	:= 0
	Private nQtdUsar	:= 0
	Private nQtdSobra	:= 0
	Private nAcond	:= 1
	Private aAcond	:= {"B- Bobina","M- Carretel Mra.","R- Rolo","T- Retalho", "C- Carretel", "S- Sucata"}
	Private nLanceC	:= 0
	Private nTamanC	:= 0
	Private cObserv	:= space(TamSX3("ZR_OBS")[1])
	Private nPosSdCt	:= 0
	Private nPosPvCt	:= 0
	
	Private aSepRet		:= {}
	
	Private oQtdLance, oB1_COD, oB1_DESC, oQtdUsar, oQtdSobra, oLanceC, oTamanC, oObserv, oAcond, oSRet
	Private lCortar		:= .F.
	
	aXZZE	:= {} // identIficadores de sobras de retrabalho em processamento
	nZZE	:= 0
	lZZE	:= .F.
	
	aSdPv	:= {} // limpar sessao anterior Sd x Pv
	
	/*
	aAdd(aButtons,{"PMSRRFSH",{|| MsgInfo("Implementar ..") }, "Negociação"})
	aAdd(aButtons,{"HISTORIC",{|| MsgInfo("Implementar ..") }, "Produção"})
	aAdd(aButtons,{"SVM",{|| MsgInfo("Implementar ..") }, "Pular"})
	*/
	
	// oTela02 := MsDialog():New(10,0,nAltura,nLargura,"Atender pedido com estoque",,,,,CLR_BLACK,CLR_WHITE,,,.T.)
	
	/*/ 
		By Roberto Oliveira 18/04/17
		Definir antes a
	/*/
	
	
	DEFINE MSDIALOG otela02 TITLE "Atender pedidos com estoque" + If(MV_PAR10==1," - Pedidos Novos", " - Pedidos em Produção") FROM 10,0 TO nAltura,nLargura OF oMainWnd PIXEL
	oTela02:lEscClose := .F.
	
	//********************************
	// ** definir cabecalho
	//********************************
	@ nlin ,nCol Say "Produto:" Size  45,08 of oTela02 pixel
	@ nlin ,nCol+=40 MsGet oB1_COD Var cB1_COD Picture "@R 999.99.99.999" When .F. Size 60,08 of oTela02 pixel
	@ nlin ,ncol+=70 MsGet oB1_DESC Var cB1_DESC When .F. Size 290,08 of oTela02 pixel
	
	nLin += 12
	ncol := 005
	@ nlin,ncol Say "Qtd Lance:" Size 45,08 of oTela02 pixel
	@ nlin,ncol+=40 MsGet oQtdLance Var nQtdLance Picture "@E 999,999" When .F. Size 60,08 of oTela02 pixel
	
	@ nLin,ncol+=70 Say "Qtd Usar:" Size 45,08 of oTela02 pixel
	@ nLin,ncol+=30 MsGet oQtdUsar Var nQtdUsar Picture "@E 999,999" When .F. Size 60,08 of oTela02 pixel
	
	@ nLin,ncol+=70 Say "Qtd Sobra:" Size 45,08 of oTela02 pixel
	@ nLin,ncol+=30 MsGet oQtdSobra Var nQtdSobra Picture "@E 999,999" When .F. Size 60,08 of oTela02 pixel
	
	nLin += 15
	ncol := 005
	@ nLin,ncol Say "Destinar Retorno" Size  150,08 of oTela02 pixel
	
	nLin += 10
	@ nLin,ncol Say "Acondic.:" Size 45,08 of oTela02 pixel
	@ nLin,ncol+=40 COMBOBOX oAcond Var nAcond ITEMS aAcond Size 60,08 of oTela02 When {|| lCortar } pixel
	
	@ nLin,ncol+=70 Say "Lance:" Size 45,08 of oTela02 pixel
	@ nLin,ncol+=30 MsGet oLanceC Var nLanceC When {|| lCortar } Picture "@E 999,999" Size 60,08 of oTela02 pixel
	
	@ nLin,ncol+=70 Say "Metragem:" Size 45,08 of oTela02 pixel
	@ nLin,ncol+=30 MsGet oTamanC Var nTamanC When {|| lCortar } Picture "@E 999,999" Size 60,08 of oTela02 pixel
	
	nlin += 12
	ncol := 5
	@ nLin,ncol Say "Observ." Size 45,08 of oTela02 pixel
	@ nLin,ncol+=40 MsGet oObserv Var cObserv /*When {|| lCortar }*/ Size 360,08 of oTela02 pixel
	
	//********************************
	// ** definir listas
	//********************************
	
	// Montar grade de saldos
	@ nLin+=15,005 Say "Saldos Estoque" Size 45,08 of oTela02 PIXEL
	@ nLin+=08,001 LISTBOX oGridSD FIELDS HEADER ;
				"S","N","Acondic.", "Almox.", "Metragem","Lance","Total","Uso Metros",;
				"Uso Lance","Retrabalho","Bobina/IdentIf","Seq.Class.","Origem","ID Unico";
	SIZE nLargObj*0.4 , (nAltObj*0.60) OF oTela02 PIXEL
	//
	nlin -= 23
	
	//
	oGridSD:blDblClick := { || SelSD() }       // airton saldo double click
	If Empty(aSD)
		aSd := ResetSd()
	EndIf
	
	oGridSD:SetArray( aSD )
	
	oGridSD:bLine := {|| { ;
	iIf(oGridSD:aArray[oGridSD:nAt,1],oOk,oNo),;
	iIf(oGridSD:aArray[oGridSD:nAt,2],oOk,oNo),;
		oGridSD:aArray[oGridSD:nAt,3],;
		oGridSD:aArray[oGridSD:nAt,4],;
		oGridSD:aArray[oGridSD:nAt,5],;
		oGridSD:aArray[oGridSD:nAt,6],;
		oGridSD:aArray[oGridSD:nAt,7],;
		oGridSD:aArray[oGridSD:nAt,8],;
		oGridSD:aArray[oGridSD:nAt,9],;
		oGridSD:aArray[oGridSD:nAt,10],;
		oGridSD:aArray[oGridSD:nAt,11],;
		oGridSD:aArray[oGridSD:nAt,12],;
		oGridSD:aArray[oGridSD:nAt,13],;
		oGridSD:aArray[oGridSD:nAt,14],;
		oGridSD:aArray[oGridSD:nAt,15]}}
	
	GetSaldo( SB1->B1_COD ) // Busca Saldos
	
	ClassSd() // sorteia saldo
	
	@ nlin+=15,(nLargObj*0.4)+5 Say "Pedido Vendas - Quadro Mestre" Size 80,08 of oTela02 PIXEL
	@ nlin+=08,(nLargObj*0.4)+5 LISTBOX oGridPV FIELDS HEADER ;
			"S","N", "Vendas", "Pedido","Item", "Sequenc.", "Acondic.", ;
			"Metragem","Lance","Total", "Uso Metros","Uso Lance","Cliente",;
			"Loja", "Nome Cliente", "Dt.Entrega", "Seq.Class.", "ID Retrabalho",;
			"Analisado" ;
	SIZE nLargObj*0.56 ,(nAltObj*0.3) OF oTela02 PIXEL
	
	If Empty(aPV)
		aPv := ResetAPV()
	EndIf
	
	oGridPV:SetArray( aPV )
	
	oGridPV:blDblClick := { || SelPV() }
	
	oGridPV:bLine := {|| { ;
			iIf(oGridPV:aArray[oGridPV:nAt,1],oOk,oNo),;
			iIf(oGridPV:aArray[oGridPV:nAt,2],oOk,oNo),;
			XNegoc(oGridPV:aArray[oGridPV:nAt,20]),;
			oGridPV:aArray[oGridPV:nAt,3],;
			oGridPV:aArray[oGridPV:nAt,4],;
			oGridPV:aArray[oGridPV:nAt,5],;
			oGridPV:aArray[oGridPV:nAt,6],;
			oGridPV:aArray[oGridPV:nAt,7],;
			oGridPV:aArray[oGridPV:nAt,8],;
			oGridPV:aArray[oGridPV:nAt,9],;
			oGridPV:aArray[oGridPV:nAt,10],;
			oGridPV:aArray[oGridPV:nAt,11],;
			oGridPV:aArray[oGridPV:nAt,12],;
			oGridPV:aArray[oGridPV:nAt,13],;
			oGridPV:aArray[oGridPV:nAt,14],;
			oGridPV:aArray[oGridPV:nAt,15],;
			oGridPV:aArray[oGridPV:nAt,16],;
			oGridPV:aArray[oGridPV:nAt,17],;
			oGridPV:aArray[oGridPV:nAt,18],;
			oGridPV:aArray[oGridPV:nAt,19];
			}}
	
	DelMaior() // elimina metragens de pedidos maior que o saldo
	ClassPV()
	
	If !( oGridPV:aArray[oGridPV:nAt, 8] == 0 ) .And. ;
		(Len(oGridSD:aArray) > 0 .Or. Len(oGridAL:aArray) > 0) // .Or. oGridSD:aArray[oGridSD:nAt,5] == 0 )
		LimpTla()
		nlin += (nAltObj*0.3) // Montar grade de saldos de alternativos
		
		@ nlin ,(nLargObj*0.4)+5 Say "Saldos Alternativos" Size 45,08 of oTela02 PIXEL
		@ nLin+=08,(nLargObj*0.4)+5 LISTBOX oGridAL FIELDS HEADER ;
					"N","Descrição","Acondic","Metragem","Lance","Total","Qtde.Utilizada",;
					"Qtd. Uso Lance","Retrabalho","Bobina","Produto";
					SIZE nLargObj*0.56 , (nAltObj*0.27) OF oTela02 PIXEL
		
		oGridAL:blDblClick := { || SelAL() }
		oGridAL:SetArray(ResetAL())
		
		oGridAL:bLine := {|| { ;
				iIf(oGridAL:aArray[oGridAL:nAt,1],oOk,oNo),;
					oGridAL:aArray[oGridAL:nAt,AL_DESCR],;
					oGridAL:aArray[oGridAL:nAt,3],;
					oGridAL:aArray[oGridAL:nAt,4],;
					oGridAL:aArray[oGridAL:nAt,5],;
					oGridAL:aArray[oGridAL:nAt,6],;
					oGridAL:aArray[oGridAL:nAt,7],;
					oGridAL:aArray[oGridAL:nAt,8],;
					oGridAL:aArray[oGridAL:nAt,9],;
					oGridAL:aArray[oGridAL:nAt,10],;
					oGridAL:aArray[oGridAL:nAt,AL_PRODU],;
					oGridAL:aArray[oGridAL:nAt,12],;
					oGridAL:aArray[oGridAL:nAt,13];
					}}
		
		GetSdoA( SB1->B1_COD ) // buscar saldo alternativo para o produto
		
		For i := 1 to len(oGridPV:aArray)
			If SC6->(DbSeek(xFilial("SC6")+oGridPV:aArray[i,PV_PEDID]+oGridPV:aArray[i,PV_ITEM]),.F.) .And.;
				aScan(aC6Mark,{|x| x == xFilial("SC6") + oGridPV:aArray[i,PV_PEDID] + oGridPV:aArray[i,PV_ITEM]}) == 0
				
				SC6->(RecLock("SC6",.F.)) // INCREMENTAR NUMERO DE ANALISE DO ITEM
				SC6->C6_XPCP := SC6->C6_XPCP + 1
				SC6->(MsUnLock())
				aadd(aC6Mark,xFilial("SC6") + oGridPV:aArray[i,PV_PEDID] + oGridPV:aArray[i,PV_ITEM])
			EndIf
		Next
		
		// BOTOES
		//nLin := (nAltObj)-20
		nLin := (nAltObj)-40
		nCol := 5
		@ nLin+=08 , ncol BUTTON oButton PROMPT "Separar / Retrabalho" SIZE 057, 010 OF oTela02 Action { || SepRetr( oTela02 ) } PIXEL
		@ nLin , ncol+=60 BUTTON oButton PROMPT "Negociação" SIZE 037, 010 OF oTela02 Action { || MsgRun( "Favor aguarde", "Aguarde", {|| CriarNeg()} ) } PIXEL
		// @ nLin ,ncol+=40 BUTTON oButton PROMPT "Produção" SIZE 037, 010 OF oTela02 Action { || Producao() } PIXEL
		@ nLin , ncol+=40 BUTTON oButton PROMPT "Pular" SIZE 037, 010 OF oTela02 Action { || Pular( oTela02 ) } PIXEL
		@ nLin , ncol+=40 BUTTON oButton PROMPT "Sair" SIZE 037, 010 OF oTela02 Action { || Cancel( oTela02 ) } PIXEL
		//@ nLin , ncol+=150 BUTTON oButton PROMPT "Filtra PV " SIZE 047, 010 OF oTela02 /*Action { || SepRetr() }*/ PIXEL
		//@ nLin , ncol+=050 BUTTON oButton PROMPT "Limpa Filtro"  SIZE 047, 010 OF oTela02 /*Action { || SepRetr() }*/ PIXEL
		
		
		// oTela02:Activate()
		ACTIVATE MSDIALOG oTela02 CENTERED
	EndIf

Return(.T.)


/*/{Protheus.doc} SelAL
//TODO selecionar alternativos.
@author juliana.leme
@since 14/07/2017
@version undefined

@type function
/*/
Static Function SelAL()
	Local aAl	:= oGridAl:aArray[oGridAl:nAt]
	Local aSds	:= oGridSd:aArray
	Local aAls	:= oGridAl:aArray
	Local i
	
	If aAl[AL_MARCA]
		aAl[AL_MARCA] := .F.
	Else
		i := AScan(aSds,{|x| x[SD_MCNEG] == .T. })
		If i > 0
			Alert("Já possui saldo em negociação")
		Else
			i := AScan(aAls,{|x| x[AL_MARCA] == .T. })
			If i > 0
				Alert("Já possui saldo alternativo em negociação")
			Else
				aAl[AL_MARCA] := .T.
			EndIf
		EndIf
	EndIf
	
	oGridAL:Refresh()

Return(.T.)


/*/{Protheus.doc} Cancel
//TODO Ação do botao cancelar.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function Cancel()
	If MsgYesNo("Deseja sair ?")
		lParar := .T.
		oTela02:End()
		oTela02:Refresh()
	EndIf
Return(.T.)


/*/{Protheus.doc} Pular
//TODO Ação do botao pular.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function Pular()
	oTela02:End()
	oTela02:Refresh()
Return(.T.)


/*/{Protheus.doc} SepRetr
//TODO BOTAO Separar / Retrabalho.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function SepRetr()
	Local lValTela	:= .T.
	
	If oAcond:nAt == 6 // sucata  airton
		If nQtdSobra == 0
			Alert("Não pode ser SUCATA porque Sobra é zero")
			Return(.T.)
		ElseIf !MsgYesNo("Deseja realmente destinar a SUCATA?")
			Return(.T.)
		EndIf
	EndIf
	
	//Validar se a bobina ou o saldo ainda está disponível para efetuar o retrabalho
	
	If ValidTla( .T. )
		Retrab() // ROTINA FINAL DE ENVIO PARA SEPARAR / RETRABALHO
		LimpaSD() // tirar da tela os saldos marcados e RESERVAR OS PRODUTOS
		LimpSD()
		//oGridSd:aArray := ResetSD()
		//GetSaldo( SB1->B1_COD )
		//ClassSd() // sorteia saldo
		LimpaPV() // recalcular a sobra dos pedidos de venda e desmarcar / tirar da tela
		
		Delmaior()
		ClassPV()
		aSepRet := {} // limpar sessao de retrabalho processada
		
		If oGridSD:aArray[1,SD_TOTAL] == 0 .Or. oGridPV:aArray[1,PV_TOTAL] == 0
			MsgInfo("Saldo ou PV sem itens.... Pulando para o próximo produto")
			oTela02:End()
			oTela02:Refresh()
		EndIf
		oAcond:nAt := 1  // bobina
	EndIf

Return(.T.)


/*/{Protheus.doc} Retrab
//TODO Funcao para enviar produto para o retrabalho.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function Retrab() 
	Local i, j, k, lProcess, nPos, cPNum
	Local cZZE_ID := ""
	Local cIdTrans := 0
	Local aSd, aPv, nPosSd, cIdRetr, lZZF, cQry, nQry, lTemRet
	Local cPara := GetMv("MV_XLocalA") // Local PARA RESERVA DE PRODUTOS AGUARDANDO SEPARACAO
	Local lTransf := .F.
	Local nC6_NUM := TamSX3("C6_NUM")[1]
	Local aRet := {.F.,"NAO DEFINIDO"}
	Local lSobra := .F.
	Local lUnico := .F.
	Local cZZEACONDE, nZZEMETRAE,nZZELANCEE,nZZETOTEN
	
	Private _aSepPed := {} // Pedidos a separar { Pedido+Item,ID,quant.PV,Quant.Retrab}
	
	SZE->(DbSetOrder(1))
	ZZE->(DbSetOrder(2))
	SC6->(DbSetOrder(1))
	
	LjMsgRun("Iniciado processo de RETRABALHO! :: FAVOR AGUARDE :: ")
	
	For i := 1 to len(aSepRet)
		nPosSd := aScan( oGridSd:aArray , {|x| x[SD_BOBIN] == aSepRet[i,1] } )
		aSd := oGridSd:aArray[nPosSd]
		
		aPedRets := aSepRet[i,2]
		aPedRets := aSort( aPedRets , , , {|x,y| x[2] + x[6] > y[2] + y[6] } ) // juntar mesmos pedidos e distinguir separacao de retrabalho
		
		lZZF	:= .T. // Gerar uma separacao de retrabalho
		lSobra	:= .T. // Gerar uma sobra de retrabalho
		lTransf	:= .F.
		lUnico	:= .T.
		_aSepPed := {} // Pedidos a separar { Pedido,Item,PV_MARCA,SD_MARCA,ID,quant.PV,Quant.Retrab,}
		
		BeginTran()
		
		For j := 1 to len(aPedRets)
			If(!Empty(aPedRets[j]))
				aPv := oGridPv:aArray[ aScan( oGridPv:aArray , {|x| x[PV_ID] ==aPedRets[j,1] } ) ]
				
				If lUnico
					SaldoSobras(@lZZE,@cIdRetr,nPosSd ,@nZZE) // validar se o saldo é de sobras e gerar numero de retrabalho
					If( lZZE == .F.)
						ConfirmSX8()
					EndIf
					lUnico := .F.
				EndIf
				aPedRets[j,07] := cIdRetr // ATUALIZAR ID DO RETRABALHO EM MEMORIA
				
				If( aPedRets[j,2] == "S" .And. Empty(aSd[SD_IDRE])  )// Separacao direta
					Alert("Favor utilizar esta ferramenta apenas para geração de retrabalhos! Para a separação de produto em estoque converse diretamente com a expedição.")
					aPv[PV_MARCA] := .F.
					aSd[SD_MARCA] := .F.
				Else // retrabalho
					If lZZF
						If Empty(aSd[SD_IDRE])
							aRet := u_EmpSDC(.T. /* .T.=Empenhar .F.=Cancelar Empenho*/,;
							"ZZF"/*Origem*/,;
							cB1_COD/*Produto*/,;
							"01"/*Local*/,;
							PadR(Substr(aSd[SD_ACOND],1,1) + StrZero(aSd[SD_METRA],5,0),TamSX3("BE_LocalIZ")[1])/*cLocaliz*/,;
							(aSd[SD_METRA] * aSd[SD_USADL])/*Quant*/,;
							cIdRetr/*Docto*/,;
							aSd[SD_BOBIN]/*Nro.Bobina*/,;
							.F. /*Trata ou não Transação*/;
							)
						Else
							If lUnico
								SaldoSobras(@lZZE,@cIdRetr,nPosSd ,@nZZE) // validar se o saldo é de sobras e gerar numero de retrabalho
								If( lZZE == .F.)
									ConfirmSX8()
								EndIf
								lUnico := .F.
							EndIf
							aRet := {.T.,"EM RETRABALHO"}
						EndIf
					EndIf
					If aRet[1] // Transferido com sucesso ????
						If( lZZF .And. Empty(aSd[SD_IDRE]) ) // Gerar uma única separacao de retrabalho (ZZF) para todos itens deste ZZE (retrabalho)
							ZZF->( RecLock("ZZF", .T.) )
							ZZF->ZZF_FILIAL := xFilial("ZZF")
							ZZF->ZZF_ZZEID  := cIdRetr
							ZZF->ZZF_STATUS := "2" // AGUARDANDO
							ZZF->ZZF_TIPO   := "R"
							ZZF->ZZF_DTINC  := ddatabase
							ZZF->ZZF_LANCES	:= aSd[SD_USADL]
							ZZF->ZZF_METRAS	:= aSd[SD_METRA]
							ZZF->ZZF_ACONDS	:= Substr(aSd[SD_ACOND],1,1)
							ZZF->ZZF_FILPV	:= xFilial("SC6")
							ZZF->ZZF_PRODUT	:= cB1_COD
							ZZF->ZZF_PEDIDO	:= aPv[PV_PEDID]
							ZZF->ZZF_ITEMPV	:= aPv[PV_ITEM]
							ZZF->ZZF_LANCEP	:= aPv[PV_LANCE]
							ZZF->ZZF_METRAP	:= aPv[PV_METRA]
							ZZF->ZZF_ACONDP	:= Substr(aPv[PV_ACOND],1,1) // By Robert 08/04/14
							ZZF->ZZF_NUMBOB	:= IIf(ZZF->ZZF_ACONDS == "B",aSd[SD_BOBIN],"")
							ZZF->ZZF_TPBOB	:= aSd[SD_TPBOB]
							ZZF->ZZF_Local := cPara
							ZZF->(MsUnLock())
							lZZF := .F.
						EndIf
						
						ZZE->(DbSetOrder(2))
						lTemRet := ZZE->(DbSeek(xFilial("ZZE")+cIdRetr+aPv[PV_PEDID]+aPv[PV_ITEM],.F.))
						ZZE->(RecLock("ZZE", If(lTemRet,.F.,.T.) ))
						ZZE->ZZE_FILIAL	:= xFilial("ZZE")
						ZZE->ZZE_ID		:= cIdRetr
						ZZE->ZZE_PRODUT	:= cB1_COD
						ZZE->ZZE_PEDIDO	:= aPv[PV_PEDID]
						ZZE->ZZE_ITEMPV	:= aPv[PV_ITEM]
						ZZE->ZZE_CODCLI	:= aPv[PV_CLIEN]
						ZZE->ZZE_LOJA	:= aPv[PV_LOJA]
						ZZE->ZZE_NOMCLI	:= aPv[PV_NOMEC]
						ZZE->ZZE_PVENTR	:= aPv[PV_ENTRE]
						ZZE->ZZE_DTINI	:= ddatabase
						ZZE->ZZE_NUMBOB	:= IIf(Substr(aSd[SD_ACOND],1,1) == "B",aSd[SD_BOBIN],"") //By Robert 08/04/14
						ZZE->ZZE_OBSERV	:= ""
						If( lZZE )
							ZZE->ZZE_ACONDE	:= aXZZE[nZZE,3]
							ZZE->ZZE_METRAE	:= aXZZE[nZZE,4]
							ZZE->ZZE_LANCEE	:= aXZZE[nZZE,5]
							ZZE->ZZE_TOTEN	:= aXZZE[nZZE,6]
						Else
							ZZE->ZZE_ACONDE	:= Substr(aSd[SD_ACOND],1,1)
							ZZE->ZZE_METRAE	:= aSd[SD_METRA]
							ZZE->ZZE_LANCEE	:= aSd[SD_USADL]
							ZZE->ZZE_TOTEN	:= ( aSd[SD_USADL] * aSd[SD_METRA] )
						EndIf
						ZZE->ZZE_ACONDS	:= Substr(aPv[PV_ACOND],1,1)
						ZZE->ZZE_METRAS	:= aPedRets[j,04]
						If( lTemRet )
							ZZE->ZZE_TOTSA	+= aPedRets[j,03]
							ZZE->ZZE_LANCES	:= Int( ZZE->ZZE_TOTSA / ZZE->ZZE_METRAS )
						Else
							ZZE->ZZE_TOTSA	:= aPedRets[j,03]
							ZZE->ZZE_LANCES	:= aPedRets[j,05]
						EndIf
						ZZE->ZZE_STATUS	:= "1"
						ZZE->ZZE_SALDO	:= ZZE->ZZE_TOTEN
						ZZE->(MsUnLock())
						
						If SC6->(DbSeek(xFilial("SC6") + Padr(aPv[PV_PEDID],nC6_NUM) + aPv[PV_ITEM] + cB1_COD,.F. ))
							SC6->(RecLock("SC6",.F.))    
							If MV_PAR10 == 1 // Só Altera se for para pedidos novos
								SC6->C6_SEMANA := "r" + cIdRetr 
							Endif
							SC6->C6_QTDRES  := SC6->C6_QTDRES  + aPedRets[j,03] // Quantidade em metros
							SC6->C6_XQTDRET := SC6->C6_XQTDRET + aPedRets[j,05] // Quantidade em lances
							SC6->(MsUnLock())
							
							If MV_PAR10 == 2 // Se for já programado
								u_GraveSZ9("r") // Mandou para retrabalho
							EndIf
							
							//_aSepPed := {} // Pedidos a separar { Pedido,Item,PV_MARCA,SD_MARCA,ID,quant.PV,Quant.Retrab}
							_nPsSep := aScan( _aSepPed, {|x| x[1] == SC6->C6_NUM .And. ;
							x[2] == SC6->C6_ITEM .And. ;
							x[3] == PV_MARCA .And. ;
							x[4] == SD_MARCA .And. ;
							x[5] == cIdRetr })
							If _nPsSep == 0 // Adicionar
								Aadd(_aSepPed,{SC6->C6_NUM,SC6->C6_ITEM,PV_MARCA,SD_MARCA,cIdRetr,SC6->C6_QTDVEN,ZZE->ZZE_TOTSA})
								// Pedidos a separar { 1-Pedido,2-Item,3-PV_MARCA,4-SD_MARCA,5-ID,6-quant.PV,7-Quant.Retrab}
							Else
								_aSepPed[_nPsSep,7] := ZZE->ZZE_TOTSA
							EndIf
						Else
							Alert("Pedido: '" + Padr(aPv[PV_PEDID],nC6_NUM)  + "' não Localizado!")
						EndIf
						
						If(lCortar .And. nPosSdCt == nPosSd .And. lSobra) // validar se o corte é deste saldo
							If ! Empty(aSd[SD_IDRE])
								If ZZE->(DbSeek(aSd[SD_IDRE] + "000001",.F. ))
									ZZE->(RecLock("ZZE", .F. ))
									ZZE->(DbDelete())
									ZZE->(MsUnLock())
								EndIf
							EndIf
							
							ZZE->(DbSeek(xFilial("ZZE") + cIdRetr,.F.))
							cZZEACONDE	:= ZZE->ZZE_ACONDE
							nZZEMETRAE	:= ZZE->ZZE_METRAE
							nZZELANCEE	:= ZZE->ZZE_LANCEE
							nZZETOTEN	:= ZZE->ZZE_TOTEN
							
							ZZE->(RecLock("ZZE", .T. ))
							ZZE->ZZE_FILIAL	:= xFilial("ZZE")
							ZZE->ZZE_ID		:= cIdRetr
							ZZE->ZZE_PRODUT	:= cB1_COD	// rtrim( SB1->B1_COD )
							ZZE->ZZE_PEDIDO	:= "000001" // oGridPv:aArray[nPosPvCt,PV_PEDID]
							ZZE->ZZE_ITEMPV	:= "99"
							ZZE->ZZE_CODCLI	:= "000001"
							ZZE->ZZE_LOJA	:= ""
							ZZE->ZZE_NOMCLI	:= ""
							ZZE->ZZE_PVENTR	:= ctod("//")
							ZZE->ZZE_DTINI	:= dDataBase // ctod("//")
							ZZE->ZZE_NUMBOB	:= IIf(cZZEACONDE == "B",aSd[SD_BOBIN],"") //By Robert 08/04/14
							ZZE->ZZE_OBSERV	:= cObserv
							ZZE->ZZE_ACONDE	:= cZZEACONDE
							ZZE->ZZE_METRAE	:= nZZEMETRAE
							ZZE->ZZE_LANCEE	:= nZZELANCEE
							ZZE->ZZE_TOTEN	:= nZZETOTEN
							ZZE->ZZE_ALMOXE	:= aSd[SD_ALMOX]
							ZZE->ZZE_ACONDS	:= Substr(aAcond[oAcond:nAt ],1,1)
							ZZE->ZZE_METRAS	:= nTamanC
							ZZE->ZZE_LANCES	:= nLanceC
							ZZE->ZZE_TOTSA	:= (nTamanC * nLanceC)
							ZZE->ZZE_STATUS	:= "1"
							ZZE->ZZE_SALDO	:= ZZE->ZZE_TOTEN
							ZZE->(MsUnLock())
							
							dbSelectarea("ZZT") 				// grava tabela de ZZT SOBRAS DE RETRABALHO
							cIdTrans := GetSXENum("ZZT","ZZT_ID")
							
							ZZT->(DbSetOrder(1))
							Do While ZZT->(DbSeek(xFilial("ZZT") + cIdTrans,.F.))
								ConfirmSX8()
								cIdTrans := GetSXENum("ZZT","ZZT_ID")
							EndDo
							
							RecLock("ZZT",.T.)
							ZZT->ZZT_FILIAL := xFilial("ZZT")
							ZZT->ZZT_ID     := cIdTrans
							ZZT->ZZT_ZZEID  := cIdRetr
							
							If oAcond:nAt == 6 // sucata
								ZZT->ZZT_STATUS := "2" // sucata
							Else
								ZZT->ZZT_STATUS := "1" // AGUARDANDO DESTINACAO
							EndIf
							
							ZZT->ZZT_TIPO   := "T" // SEPARAR MATERIAL PARA PEDIDO DE VENDA
							ZZT->ZZT_DTINC  := ddatabase
							ZZT->ZZT_PEDIDO	:= ""
							ZZT->ZZT_ITEMPV	:= ""
							ZZT->ZZT_LANCES	:= nLanceC
							ZZT->ZZT_METRAS	:= nTamanC
							ZZT->ZZT_ACONDS	:= Substr(aAcond[ oAcond:nAt ],1,1)
							ZZT->ZZT_NUMBOB := IIf(ZZT->ZZT_ACONDS == "B",aSd[SD_BOBIN],"") // By Robert 08/04/14
							ZZT->ZZT_PRODUT := cB1_COD
							ZZT->ZZT_DESCP  := POSICIONE("SB1", 1, xFilial("SB1")+cB1_COD, "B1_DESC")
							ZZT->(MsUnLock())
							
							ConfirmSX8()
							
							cObserv := space(TamSX3("ZR_OBS")[1])
							lSobra	:= .F.
						EndIf
					Else
						aSd[SD_MARCA] := .F. // Erro ao realizar a transferencia do item **reserva**
						aPv[PV_MARCA] := .F.
						Alert(aRet[2])
					EndIf
				EndIf
			EndIf
		Next
	
		If !aRet[1]
			DisarmTransaction()
		EndIf
		//EndTransaction
		EndTran()
	Next
	
	oGridPv:Refresh()
	oGridSd:Refresh()
	MSobra(0,0,0,0) // limpar o saldo de sobra

Return(.T.)


/*/{Protheus.doc} ValidTla
//TODO Validar dados da tela do acondicionamento e quantidade digitada.
@author Robert Santos
@since 23/03/2013
@version undefined
@param lMsg, logical, descricao
@type function
/*/
Static Function ValidTla( lMsg )
	Local aVal
	Local lOk := .F.
	Local cAcond := ""
	Local aPv := oGridPV:aArray
	Local i
	Local nQtTotal := nQtdSobra
	
	If aScan( oGridPV:aArray, {|x| x[PV_MARCA] == .T. }) > 0 // validar se possui algum item marcado para processar
		lOk := .T.
		If lOk
			If lCortar // validar corte manual do usuario se houver
				If oAcond:nAt == 6 // sucata
					nTamanC := nQtTotal
					nLanceC := 1
				EndIf
				If (nTamanC * nLanceC) # nQtTotal
					lOk := .F.
					If lMsg
						MsgInfo("Favor informar lance na mesma quantidade de sobras = " + Transform(nQtTotal,"@E 999,999") + " !!")
					EndIf
				Else
					Do Case
						Case oAcond:nAt == 1
							cAcond := "B"
						Case oAcond:nAt == 2
							cAcond := "M"
						Case oAcond:nAt == 3
							cAcond := "R"
						Case oAcond:nAt == 4
							cAcond := "T"
						Case oAcond:nAt == 5
							cAcond := "C"
						Case oAcond:nAt == 6
							cAcond := "S"
					EndCase
					
					If( cAcond != "S" )
						
						//SB1->B1_COD esta retornando vazio pois em algum momento desposicionou
						//Estou passando como parametro direto a variavel cB1_COD, declarada no inicio programa
						//aval	:= u_StVld01( cAcond /*acondicionamento*/, nTamanC /*metragem*/, SB1->B1_COD /*produto*/ )
						aval	:= u_StVld01( cAcond /*acondicionamento*/, nTamanC /*metragem*/, cB1_COD /*produto*/ )
						
						lok		:= aval[1]
					Else
						lOk := .T.
					EndIf
					
					If !lok .And. lMsg // retornar
						MsgInfo( aval[2] )
					EndIf
				EndIf
			Else
				lOk := .T.
			EndIf
		EndIf
	Else
		lOk := .F.
		If lMsg
			MsgInfo("Sem item pedido de venda marcado para processar")
		EndIf
	EndIf

Return(lOK)


/*/{Protheus.doc} SelPV
//TODO Selecionar item do pedido de venda para saldo selecionado.
@author Robert Santos
@since 23/03/2017
@version undefined

@type function
/*/
Static Function SelPV()
	Local aPv := oGridPv:aArray[oGridPv:nat]
	
	If !Empty(aPv[PV_PEDID]) //Cobrecom
		Do Case
			Case oGridPV:ColPos == PV_MARCA
				If aPv[PV_NEGOC] $ "6 " // rejeitado / nao negociado
					MsgRun("Favor aguarde!!" , "Aguardar", { || Sep01() }) // separar / retrabalho
				Else
					Alert("Item em negociação / Negociado !!")
				EndIf
			Case oGridPV:ColPos == PV_MCNEG
				If !Empty(aPv[PV_NEGOC])
					Alert("Item já negociado anteriormente!!")
				Else
					Neg01() // marcar negociacao
				EndIf
			Case oGridPV:ColPos == 3 // PV_NEGOC
				LVendas()
		EndCase
	EndIf

Return(.T.)


/*/{Protheus.doc} Sep01
//TODO Marcar Pv x Sd (melhor opção).
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function Sep01()
	Local nsd	:= 0 //
	Local aPV	:= oGridPV:aArray
	Local nPv	:= oGridPV:nAt
	Local i,j,k,l,m, lRolo, aAux, nTAtendPV, aSd, lPrim
	Local lOk	:= .F.
	
	Do Case
		Case aPv[nPv,PV_MCNEG]
			MsgInfo("Item marcado para Negociação!!")
		otherwise
			If( aPv[nPv,PV_MARCA] ) // DESMARCAR PEDIDO VENDA X SALDO
				aAux := aClone( aSdPv )
				lPrim := .T.
				For i := 1 to len( aAux )
					If( aAux[i,2] == aPv[nPv,PV_ID] ) // validar amarracao
						j := aScan( oGridSd:aArray , {|x| x[SD_BOBIN] == aAux[i,1] } )
						aSd := oGridSd:aArray[j]
						
						k := aScan( aSepRet , {|x| x[1] == aSd[SD_BOBIN] })
						If( k > 0)
							aPedRets := aSepRet[k,2]
							k := aScan( aPedRets , {|x| x[1] == aPv[nPv,PV_ID] })
							Do While k > 0
								If( aSd[SD_METRA] != aPv[nPv,PV_METRA] .And. lCortar .And. nPosSdCt != j )
									If(lPrim)
										Alert( "Voce nao pode desmarcar este item devido sobras!" )
										lPrim := .F.
									EndIf
									k := 0
								Else
									aSd[SD_USADO] -= aPedRets[k,03]
									aSd[SD_USADL] := iIf( (aSd[SD_USADO] % aSd[SD_METRA]) > 0 , NoRound(aSd[SD_USADO]/aSd[SD_METRA],0) + 1 , Round(aSd[SD_USADO]/aSd[SD_METRA],0) )
									aSd[SD_MARCA] := !( Empty(aSd[SD_USADL]) )
									
									aPv[nPv,PV_USADO] -= aPedRets[k,03]
									aPv[nPv,PV_USADL] := iIf( (aPv[nPv,PV_USADO] % aPv[nPv,PV_METRA]) > 0 , NoRound(aPv[nPv,PV_USADO]/aPv[nPv,PV_METRA],0) + 1 , Round(aPv[nPV,PV_USADO]/aPv[nPv,PV_METRA],0) )
									aPv[nPv,PV_MARCA] := !( Empty(aPv[nPv,PV_USADL]) )
									
									If( lCortar .And. nPosSdCt == j )
										mSobra( (aSd[SD_METRA] * aSd[SD_USADL]) , ((aSd[SD_METRA] * aSd[SD_USADL])-aSd[SD_USADO]), j , nPV )
									Else
										If( lCortar == .F. )
											mSobra( (aSd[SD_METRA] * aSd[SD_USADL]) , ((aSd[SD_METRA] * aSd[SD_USADL])-aSd[SD_USADO]), j , nPV )
										Else
											If( ((aSd[SD_METRA] * aSd[SD_USADL])-aSd[SD_USADO]) > 0 )
												Alert("ERRO GRAVE 02")
											EndIf
										EndIf
									EndIf
									aPedRets := aDel( aPedRets , k )
									aPedRets := aSize( aPedRets , len(aPedRets) - 1 )
									
									If( len(aSdPv) == 1 )
										aSdPv := {}
									Else
										aSdPv := aDel( aSdPv , i )
										aSdPv := aSize( aSdPv , len(aSdPv) -1 )
									EndIf
									
									k := aScan( aPedRets , {|x| x[1] == aPv[nPv,PV_ID] })
								EndIf
							EndDo
						Else
							Alert("ERRO GRAVE 01") // ERROR 01
						EndIf
					EndIf
				Next
				
				oGridSd:Refresh()
				oGridPv:Refresh()
			Else
				MarcarPedido(nPv, aPv) // Marcar Pv x Sd (melhor opção)
			EndIf
	EndCase

Return(.T.)


/*/{Protheus.doc} Neg01
//TODO Mark/Unmark the order to deal.
@author Robert Santos
@since 27/03/2013
@version undefined

@type function
/*/
Static Function Neg01()  
	Local i, j
	Local aPv := oGridPv:aArray[oGridPv:nAt]
	Local aPvs := ogridPv:aArray
	Local lOk
	
	If aPv[PV_MARCA]
		MsgInfo("Item marcado para separação/ retrabalho!!")
	Else
		If( aPv[PV_MCNEG] ) // Unmark
			aPv[PV_MCNEG] := .F.
		Else // Mark orders
			lOk := .T.
			
			For i := 1 to len(aPvs) // analisar se foi marcado algum pedido + item dIferente do requisitado
				If aPvs[i,PV_MCNEG] .And. (aPvs[i,PV_PEDID]+aPvs[i,PV_ITEM]) # (aPv[PV_PEDID]+aPv[PV_ITEM])
					lOk := .F.
					Alert("Você só pode marcar linhas do mesmo pedido/itens!")
					Exit
				EndIf
			Next
			
			If lOk
				aPv[PV_MCNEG] := .T.
			EndIf
		EndIf
		
		oGridPv:Refresh()
	EndIf
Return(.T.)

/*

*/

/*/{Protheus.doc} SelSD
//TODO Selecionar Saldo.
@author Robert Santos
@since 23/03/2017
@version undefined

@type function
/*/
Static Function SelSD()
	If !Empty(oGridSd:aArray[oGridSd:nAt,SD_ACOND])
		Do Case
			Case oGridSD:ColPos == SD_MARCA
				MsgRun("VerIficando Pedidos de Venda....... Favor aguarde", "VerIfica PVs", {|| SelSdA() } )
			Case oGridSD:ColPos == SD_MCNEG
				SelSdB()
		EndCase
	EndIf

Return(.T.)


/*/{Protheus.doc} SelSda
//TODO Descrição auto-gerada.
@author Robert Santos
@since 27/03/2017
@version undefined

@type function
/*/
Static Function SelSda()
	If !classMult()  // teve multiplos
		ClassPV()
	EndIf
	
	If oGridSD:aArray[oGridSD:nAt,SD_MCNEG]
		MsgInfo("Saldo marcado para negociação!")
	Else
		// validar desmarcar mesmo saldo
		If (oGridSD:aArray[oGridSD:nAt,SD_MARCA])
			// Limpar tela
			LimpTla()
		Else
			MarcarSaldo()
			
			oGridPV:aArray := aSort( oGridPV:aArray , , , { |x,y| iIf( x[PV_MARCA],"X"," " )+StrZero(x[PV_METRA],10,3) > iIf( y[PV_MARCA],"X"," " )+StrZero(y[PV_METRA],10,3) } )
			oGridPV:Refresh()     // airton
		EndIf
	EndIf
Return(.T.)


/*/{Protheus.doc} SelSdB
//TODO Descrição auto-gerada.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function SelSdB()
Local aSd	:= oGridSd:aArray[oGridSd:nAt]
Local aSds	:= oGridSd:aArray
Local aAls	:= oGridAl:aArray
Local i

If oGridSd:aArray[oGridSd:nAt,SD_MARCA]
	MsgInfo("Saldo marcado para separação / retrabalho!")
Else
	If aSd[SD_MCNEG]
		aSd[SD_MCNEG] := .F.
	Else
		If !Empty(ogridsd:aarray[ogridsd:nat,SD_IDRE])
			Alert("Não pode negociar é item de sobra de retrabalho!")
		Else
			i := AScan(aSds,{|x| x[SD_MCNEG] == .T. })
			If i > 0
				Alert("Já possui saldo em negociação")
			Else
				i := AScan(aAls,{|x| x[AL_MARCA] == .T. })
				If i > 0
					Alert("Já possui saldo alternativo em negociação")
				Else
					aSd[SD_MCNEG] := .T.
				EndIf
			EndIf
		EndIf
	EndIf
	oGridSd:Refresh()
EndIf

Return(.T.)


/*/{Protheus.doc} MSobra
//TODO Ativar sobra cabecalho.
@author Robert Santos
@since 23/03/2013
@version undefined
@param nTotal, numeric, descricao
@param nSobra, numeric, descricao
@param nPosSd, numeric, descricao
@param nPosPv, numeric, descricao
@type function
/*/
Static Function MSobra( nTotal , nSobra,  nPosSd, nPosPv )
	lCortar := iIf( nSobra == nTotal , .F. , iIf(nSobra>0, .T., .F. ) )
	
	If lCortar
		nQtdLance	:= nTotal
		nQtdUsar	:= nTotal-nSobra
		nQtdSobra	:= nSobra
		nLanceC		:= 0
		nTamanC		:= 0
		
		nPosSDCt	:= nPosSd // posicao do saldo para corte
		nPosPvCt	:= nPosPv // posicao do saldo para corte
	Else
		nQtdLance	:= 0
		nQtdUsar	:= 0
		nQtdSobra	:= 0
		nLanceC		:= 0
		nTamanC		:= 0
		
		nPosSDCt	:= 0 // posicao do saldo para corte
		nPosPvCt	:= 0 // posicao do saldo para corte
	EndIf
	
	oQtdLance:Refresh()
	oQtdUsar:Refresh()
	oQtdSobra:Refresh()
	oLanceC:Refresh()
	oTamanC:Refresh()
	
	oGridPV:SetFocus()
	oGridPV:Refresh()

Return(.T.)


/*/{Protheus.doc} LimpTla
//TODO Limpar Tela.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function LimpTla()
	LimpCab() // limpar valores do cabecalho
	LimpPV() // limpar selecionamento de pedidos
	LimpSD() // limpar selecao do saldo
	
	// limpar retrabalho
	aSepRet	:= {}
	aSdPv	:= {}

Return(.T.)


/*/{Protheus.doc} LimpCab
//TODO Limpar cabecalho.
@author Robert Santos
@since 27/03/2013
@version undefined

@type function
/*/
Static Function LimpCab()
	lCortar		:= .F.
	
	nQtdLance	:= 0
	nQtdUsar	:= 0
	nQtdSobra	:= 0
	nLanceC		:= 0
	nTamanC		:= 0
	
	oQtdLance:Refresh()
	oQtdUsar:Refresh()
	oQtdSobra:Refresh()
	oLanceC:Refresh()
	oTamanC:Refresh()

Return(.T.)


/*/{Protheus.doc} LimpPV
//TODO Limpar cabeçalho.
@author juliana.leme
@since 14/07/2017
@version undefined

@type function
/*/
Static Function LimpPV()
	Local ni := 0
	
	For ni:=1 to len(oGridPV:aArray)
		oGridPV:aArray[ni,PV_MARCA] := .F.
		oGridPV:aArray[ni,PV_USADO] := 0
		oGridPV:aArray[ni,PV_USADL] := 0
	Next
	
	oGridPV:Refresh()

Return(.T.)


/*/{Protheus.doc} LimpSD
//TODO Limpar cabecalho.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function LimpSD()
	Local ni := 0
	
	For ni:=1 to len(oGridSD:aArray)
		oGridSD:aArray[ni,SD_MARCA] := .F.
		oGridSD:aArray[ni,SD_USADO] := 0
		oGridSD:aArray[ni,SD_USADL] := 0
	Next
	oGridSD:Refresh()
	
Return(.T.)


/*/{Protheus.doc} GetSaldo
//TODO PREENCHER GRADE DE SALDO DE PRODUTOS.
@author Robert Santos
@since 23/03/2013
@version undefined
@param cB1_COD, characters, descricao
@type function
/*/
Static Function GetSaldo( cB1_COD )
	Local cqry, nqry, adados, nQtdSZR
	Local i, nQtd
	Local nIdentSD := 0
	Local cIdentSD := ""
	Local cDtIdent := ""
	Local cHrIdent := ""
	
	// ve se é produto fora
	dbSelectarea("ZZD")
	DbSetOrder(2) // ZZD_FILIAL+ZZD_COD
	//If ! ZZD->(DbSeek(xFilial("ZZD")+PADR(SC9->C9_PRODUTO,nZZD_PRODUT)+padl(alltrim(str(SC6->C6_METRAGE)),5,"0")+SC6->(C6_ACONDIC) )) // RETIRAR PRODUTOS NAO CONTROLADOS PELO PCP  AIRTON
	
	//If !ZZD->(DbSeek(xFilial("ZZD")+cB1_COD ))
	
	cDtIdent := DTOS(dDatabase)
	cHrIdent := time()
	cHrIdent := substr(cHrIdent,1,2)+substr(cHrIdent,4,2)+substr(cHrIdent,7,2)
	
	// saldo para nao bobinas
	cqry := ""
	cqry += "Select * FROM ( "
	cqry += " SELECT BF_LOCAL, BF_PRODUTO, "
	cQry += "    isnull(BF_QUANT-BF_EMPENHO,0) TOTAL "
	cQry += "    , SUBSTRING(BF_LOCALIZ,1,1) ACONDIC "
	cQry += "    , ISNULL(CAST( isnull(SUBSTRING(BF_LOCALIZ,2,5),'1') AS NUMERIC ),0) LANCE " // NAO É LANCE ->METRAGEM (NUMERICO)
	cQry += "    , ISNULL(( isnull(SUBSTRING(BF_LOCALIZ,2,5),'1') ),'') METRAG_S  " // METRAGEM (STRING EX. '00100')
	cQry += "    , 'E' SD_ORIG  "
	cQry += " "
	cQry += " from "+RetSqlName("SBF")+" BF"
	
	cQry += " where BF.D_E_L_E_T_ = ' ' AND BF_FILIAL = '"+xFilial("SBF")+"' and BF_LOCAL = '01' and (BF_QUANT-BF_EMPENHO) > 0 "
	cQry += " and SUBSTRING(BF_LOCALIZ,1,1) <> 'B' "
	cQry += " and BF_PRODUTO = '"+cB1_COD+"' "
	
	cQry += " UNION " // AGRUPAR PRODUTOS EM RETRABALHO
	
	cqry += " SELECT '01' AS BF_LOCAL, ZZE_PRODUT AS BF_PRODUTO, "
	cQry += "    ZZE_TOTSA AS TOTAL "
	cQry += "    , ZZE_ACONDS AS ACONDIC "
	cQry += "    , ZZE_TOTSA AS LANCE "
	//cQry += "    , ZZE_METRAS AS LANCE "
	cQry += "    , 'X' METRAG_S  "
	cQry += "    , (ZZE_FILIAL + ZZE_ID) AS SD_ORIG  "
	cQry += " "
	cQry += " from "+RetSqlName("ZZE")+" ZZE "
	
	cQry += " where ZZE.D_E_L_E_T_ = ' ' AND ZZE_FILIAL = '"+xFilial("ZZE")+"' and ZZE_DEVTOT = 0 AND ZZE_STATUS != '9' " // RETIRAR RETRABALHO FINALIZADOS
	cQry += " and ZZE_PEDIDO = '000001' AND ZZE_ACONDS <> 'S'  AND ZZE_SITUAC <> '1'"
	cQry += " and ZZE_PRODUT = '"+cB1_COD+"' "
	
	cQry += " ) AS T "
	
	cQry += "WHERE "
	cQry += "SUBSTRING(T.BF_PRODUTO,1,5) NOT IN ( Select SUBSTRING(ZZD_COD,1,5)  FROM "+RetSqlName("ZZD")+" ZZD WHERE "
	cQry += " ZZD_FILIAL = '"+xFilial("ZZD")+"' AND ZZD.D_E_L_E_T_ = ' ' "
	cQry += " AND ( T.ACONDIC = ZZD_ACONDI AND T.METRAG_S = ZZD_METRAG AND SUBSTRING(T.BF_PRODUTO,1,5) = SUBSTRING(ZZD_COD,1,5) )  ) "
	
	iIf( Select("TMP_BF3")>0,TMP_BF3->(DbCloseArea()), )
	TcQuery cqry New Alias "TMP_BF3"
	Count to nqry
	
	If nqry > 0
		
		If Empty(oGridSD:aArray[1,SD_ACOND])
			aDados := {}
		Else
			aDados := oGridSD:aArray
		EndIf
		
		TMP_BF3->( DbGoTop() )
		Do While !TMP_BF3->(Eof())
			
			//"","Acondic.", "Metragem","Lance","Total","Qt.Uso","Qt.Uso Lance","Retrabalho","Bobina"
			If ! TMP_BF3->(ACONDIC) $ "R/C/M" .Or. .T. == .T. // _NOVO_ Tratar dIferenciado de Rolo item a item. O rolo pode estar aglutinado
				nQtd := Int( TMP_BF3->(TOTAL/LANCE) )
				For i := 1 to nQtd
					
					nIdentSD++   // airton
					// cIdentSD := cDtIdent+cHrIdent+StrZero(nIdentSD,3,0)
					cIdentSD := "SEQ" + StrZero(Len(aDados),4,0)
					
					aadd( aDados  ,	{;
					.F.;
					, .F.;
					, 	dAcond(TMP_BF3->(ACONDIC)) ;
					,   TMP_BF3->BF_LOCAL ;
					, 	TMP_BF3->(LANCE) ;
					, 	1 ;
					, 	TMP_BF3->(LANCE) ;
					, 	0 ;
					, 	0 ;
					, "" ;
					, cIdentSD ;    // identIf/bobina
					, "" ;
					, IIf(alltrim(TMP_BF3->(SD_ORIG))=="E","ESTOQUE","RETRABALHO") ;
					, IIf(alltrim(TMP_BF3->(SD_ORIG))=="E","",TMP_BF3->(SD_ORIG)) ;
					, "" ; // ZE_TPBOB
					} )
				Next
			Else
				
				nIdentSD++   // airton
				//cIdentSD := cDtIdent+cHrIdent+StrZero(nIdentSD,3,0)
				cIdentSD := "SEQ" + StrZero(Len(aDados),4,0)
				
				aadd( aDados  , {;
				.F.;
				, .F.;
				, 	dAcond(TMP_BF3->(ACONDIC)) ;
				,   TMP_BF3->BF_LOCAL ;
				, 	TMP_BF3->(LANCE) ;
				, 	Int( TMP_BF3->(TOTAL/LANCE) ) ;
				, 	TMP_BF3->(TOTAL) ;
				, 	0 ;
				, 	0 ;
				, "" ;
				, cIdentSD ; //identIf/bobina
				, "" ;
				, IIf(alltrim(TMP_BF3->(SD_ORIG))=="E","ESTOQUE","RETRABALHO") ;
				, IIf(alltrim(TMP_BF3->(SD_ORIG))=="E","",TMP_BF3->(SD_ORIG)) ;
				, "" ; // ZE_TPBOB
				} )
			EndIf
			
			TMP_BF3->(dbskip())
		EndDo
		
		oGridSD:aArray := aDados
		oGridSD:Refresh()
		
	EndIf
	TMP_BF3->(DbCloseArea())
	
	
	// pegar saldo de bobinas
	
	cqry := ""
	cqry += " SELECT "
	cQry += "     ZE_NUMBOB, ZE_QUANT, ZE_TPBOB "
	cQry += " "
	cQry += " from "+RetSqlName("SZE")+" ZE "
	cQry += " where ZE.D_E_L_E_T_ = ' ' AND ZE_FILIAL = '"+xFilial("SBF")+"' and ZE_STATUS = 'T' "
	cQry += " and ZE_PRODUTO = '"+cB1_COD+"' "
	
	iIf( Select("TMP_BF3")>0,TMP_BF3->(DbCloseArea()), )
	TcQuery cqry New Alias "TMP_BF3"
	Count to nqry
	If nqry > 0
		
		If Empty(oGridSD:aArray[1,SD_ACOND])
			aDados := {}
		Else
			aDados := oGridSD:aArray
		EndIf
		
		DbSelectArea("SZR")
		SZR->(DbSetOrder(1)) // ZR_FILIAL+ZR_NUMBOB
		
		TMP_BF3->( DbGoTop() )
		Do While !TMP_BF3->(Eof())
			
			// "","Acondic", "Almox.", "Metragem","Lance","Total","Qtde.Utilizada","Retrabalho","Bobina"
			aadd( aDados  , {;
			.F.;
			, .F.;
			, 	dAcond("B") ;
			, "01" ;  // no caso de bobinas ver o que colocar Airton ** Local DE BOBINAS
			, 	(TMP_BF3->(ZE_QUANT)) ;
			, 	1 ;
			, 	TMP_BF3->(ZE_QUANT) ;
			, 	0 ;
			, 	0 ;
			,"";
			,TMP_BF3->(ZE_NUMBOB);
			, "" ;
			, "ESTOQUE" ;
			, "" ;
			, TMP_BF3->ZE_TPBOB ;
			} )
			
			TMP_BF3->(dbskip())
			
		EndDo
		
		oGridSD:aArray := aDados
		oGridSD:Refresh()
		
	EndIf
	TMP_BF3->(DbCloseArea())

Return(.T.)


/*/{Protheus.doc} GetSdoA
//TODO PREENCHER GRADE DE SALDO DE PRODUTOS ALTERNATIVOS.
@author Robert Santos
@since 23/03/2013
@version undefined
@param cB1_COD, characters, descricao
@type function
/*/
Static Function GetSdoA(cB1_COD)
	Local cqry, nqry, adados, nQtdSZR
	Local i, nQtd
	Local cBitola	:= ""
	Local cCor		:= ""
	Local aSB1		:= SB1->(GetArea())
	
	cB1_COD := alltrim(cB1_COD)
	If len(cB1_COD) >= 7
		cBitola		:= substr( cB1_COD, 4, 2 )
		cCor		:= substr( cB1_COD, 6, 2 )
		
		cqry := " SELECT ZZA_PRDALT, Z1_COD, Z1_DESC from "
		cqry += "  "+RetSqlName("ZZA")+" ZZA "
		cqry += " inner join  "+RetSqlName("SZ1")+" Z1 on Z1_COD = ZZA_PRDALT and Z1.D_E_L_E_T_ = '' "
		cqry += " where ZZA.D_E_L_E_T_ = '' and ZZA_PROD = '"+Substr(cB1_COD,1,3)+"' order by ZZA_PRDALT "
		iIf( Select("TMP_BF4")>0,TMP_BF4->(DbCloseArea()), )
		TcQuery cqry New Alias "TMP_BF4"
		Count to nqry
		If nqry > 0
			
			TMP_BF4->(DbGoTop())
			Do While !TMP_BF4->(Eof())
				If SB1->(DbSeek(xFilial("SB1")+TMP_BF4->(ZZA_PRDALT)+cBitola+cCor,.F.))
					cqry := ""
					cqry += " SELECT "
					cQry += "    isnull(BF_QUANT-BF_EMPENHO,0) TOTAL "
					cQry += "    , SUBSTRING(BF_LOCALIZ,1,1) ACONDIC "
					cQry += "    , ISNULL(CAST( isnull(SUBSTRING(BF_LOCALIZ,2,5),'1') AS NUMERIC ),0) LANCE "
					cQry += "    , BF_LOCAL "
					cQry += " "
					cQry += " from "+RetSqlName("SBF")+" BF"
					cQry += " where BF.D_E_L_E_T_ = ' ' AND BF_FILIAL = '"+xFilial("SBF")+"' and BF_LOCAL = '01' and (BF_QUANT-BF_EMPENHO) > 0 "
					cQry += " and SUBSTRING(BF_LOCALIZ,1,1) <> 'B' "
					cQry += " and BF_PRODUTO = '"+SB1->B1_COD+"' "
					
					iIf( Select("TMP_BF3")>0,TMP_BF3->(DbCloseArea()), )
					TcQuery cqry New Alias "TMP_BF3"
					Count to nqry
					If nqry > 0
						
						If Empty(oGridAL:aArray[1,AL_ACOND])
							aDados := {}
						Else
							aDados := oGridAL:aArray
						EndIf
						
						TMP_BF3->( DbGoTop() )
						Do While !TMP_BF3->(Eof())
							
							//"","Produto","Acondic.", "Metragem","Lance","Total","Uso Metros","Uso Lance","cod retraba","bobina";
							//By Roberto Oliveira 18/04/17
							//If !TMP_BF3->(ACONDIC) $ "R/C/M" // _NOVO_ Tratar dIferenciado de Rolo item a item. O rolo pode estar aglutinado
							If TMP_BF3->(ACONDIC) #  "B" // _NOVO_ Tratar dIferenciado de Rolo item a item. O rolo pode estar aglutinado
								nQtd := Int( TMP_BF3->(TOTAL/LANCE) )
								For i := 1 to nQtd
									aadd( aDados  , {;
									.F.;
									,	rtrim(SB1->B1_COD) ;
									, 	dAcond(TMP_BF3->(ACONDIC)) ;
									, 	TMP_BF3->(LANCE) ;
									, 	1 ;
									, 	TMP_BF3->(LANCE) ;
									, 	0 ;
									, 	0 ;
									, 	"" ;
									, 	"SEQ" + StrZero(Len(aDados),4,0) ; // , 	"SEQ" + StrZero(Len(aDados),5,0) ; // Linha alterara Robert 08/04/14
									, 	ALLTRIM(SB1->B1_DESC) ;
									,	TMP_BF3->BF_LOCAL ;
									,	"" ;
									} )
								Next
							Else // o Que? Como trabar os blisters
								aadd( aDados  , {;
								.F.;
								,	rtrim(SB1->B1_COD) ;
								, 	dAcond(TMP_BF3->(ACONDIC)) ;
								, 	TMP_BF3->(LANCE) ;
								, 	Int( TMP_BF3->(TOTAL/LANCE) ) ;
								, 	TMP_BF3->(TOTAL) ;
								, 	0 ;
								, 	0 ;
								,	"" ;
								,	"SEQ" + StrZero(Len(aDados),4,0) ; //	,	"SEQ" + StrZero(Len(aDados),5,0) ; // Linha alterara Robert 08/04/14
								, 	ALLTRIM(SB1->B1_DESC) ;
								, 	TMP_BF3->BF_LOCAL ;
								, 	"" ;
								} )
							EndIf
							
							TMP_BF3->(dbskip())
						EndDo
						
						oGridAL:aArray := aDados
						oGridAL:Refresh()
					EndIf
					TMP_BF3->(DbCloseArea())
					
					
					cqry := "" // pegar saldo de bobinas
					cqry += " SELECT "
					cQry += "     ZE_NUMBOB, ZE_QUANT, ZE_TPBOB "
					cQry += " "
					cQry += " from "+RetSqlName("SZE")+" ZE "
					cQry += " where ZE.D_E_L_E_T_ = ' ' AND ZE_FILIAL = '"+xFilial("SBF")+"' and ZE_STATUS = 'T' "
					cQry += " and ZE_PRODUTO = '"+SB1->B1_COD+"' "
					
					iIf( Select("TMP_BF3")>0,TMP_BF3->(DbCloseArea()), )
					TcQuery cqry New Alias "TMP_BF3"
					Count to nqry
					If nqry > 0
						
						If Empty(oGridAL:aArray[1,AL_ACOND])
							aDados := {}
						Else
							aDados := oGridAL:aArray
						EndIf
						
						DbSelectArea("SZR")
						SZR->(DbSetOrder(1)) // ZR_FILIAL+ZR_NUMBOB
						
						TMP_BF3->( DbGoTop() )
						Do While !TMP_BF3->(Eof())
							aadd( aDados  , {;
							.F.;
							,	rtrim(SB1->B1_COD) ;
							, 	dAcond("B") ;
							, 	(TMP_BF3->(ZE_QUANT)) ;
							, 	1 ;
							, 	TMP_BF3->(ZE_QUANT) ;
							, 	0 ;
							, 	0 ;
							,	"";
							,	TMP_BF3->(ZE_NUMBOB);
							, 	ALLTRIM(SB1->B1_DESC) ;
							, 	"01" ;
							, 	TMP_BF3->ZE_TPBOB ;
							} )
							
							TMP_BF3->(dbskip())
						EndDo
						
						oGridAL:aArray := aDados
						oGridAL:Refresh()
					EndIf
					
					TMP_BF3->(DbCloseArea())
				EndIf
				TMP_BF4->(dbskip())
			EndDo
		EndIf
		TMP_BF4->(DbCloseArea())
	EndIf
	
	RestArea(aSB1)

Return(.T.)


/*/{Protheus.doc} dAcond
//TODO Retornar o nome do acondicionamento.
@author Robert Santos
@since 23/03/2013
@version undefined
@param cAcond, characters, descricao
@type function
/*/
Static Function dAcond( cAcond )
	Do Case
		Case cAcond == "R"
			Return("R- Rolo")
		Case cAcond == "T"
			Return("T- Retalho")
		Case cAcond == "B"
			Return("B- Bobina")
		Case cAcond == "M"
			Return("M- Carretel")
		Case cAcond == "C"
			Return("C- Carretel")
		Case cAcond == "S"
			Return("S- Sucata")
	EndCase

Return(cAcond)


/*/{Protheus.doc} ValidPerg
//TODO Valida Perguntas.
@author Roberto
@since 23/03/2013
@version undefined
@param cPerg, characters, descricao
@type function
/*/
Static Function ValidPerg( cPerg ) 
	Local _aArea := GetArea()
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	
	aRegs:={}
	aAdd(aRegs,{cPerg,"01","Do Produto                   ?","mv_ch1","C",TamSX3("B1_COD")[1] ,0,0,"G","","mv_par01",""   ,"","",""   ,"","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"02","Até o Produto                ?","mv_ch2","C",TamSX3("B1_COD")[1] ,0,0,"G","","mv_par02",""   ,"","",""   ,"","","","","","","","","","","SB1"})
	aAdd(aRegs,{cPerg,"03","Do Cliente                   ?","mv_ch3","C",TamSX3("A1_COD")[1] ,0,0,"G","","mv_par03",""   ,"","",""   ,"","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"04","Da Loja                      ?","mv_ch4","C",TamSX3("A1_LOJA")[1],0,0,"G","","mv_par04",""   ,"","",""   ,"","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Até o Clinte                 ?","mv_ch5","C",TamSX3("A1_COD")[1] ,0,0,"G","","mv_par05",""   ,"","",""   ,"","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"06","Até a Loja                   ?","mv_ch6","C",TamSX3("A1_LOJA")[1],0,0,"G","","mv_par06",""   ,"","",""   ,"","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Da Dt.Entrega                ?","mv_ch7","D",08                  ,0,0,"G","","mv_par07",""   ,"","",""   ,"","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"08","Até a Dt. Entrega            ?","mv_ch8","D",08                  ,0,0,"G","","mv_par08",""   ,"","",""   ,"","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Elimina Metrag.Maior PV      ?","mv_ch9","N",01                  ,0,1,"C","","mv_par09","Sim","","","Nao","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"10","Avaliar                      ?","mv_cha","N",01                  ,0,1,"C","","mv_par10","Pedidos Novos","","","Pedidos em Produção","","","","","","","","","","",""})
	
	For i := 1 To Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2],.F.)
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
			MsUnLock()
			DbCommit()
		EndIf
	Next
	
	RestArea(_aArea)

Return(.T.)


/*/{Protheus.doc} LimpaSD
//TODO 	Deleta itens marcados do saldo
		FAZER RESERVA DO PRODUTO EM SALDO.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function LimpaSD()
	Local n := 0
	n := aScan( oGridSd:aArray, { |x| x[1] == .T. })
	
	Do While n > 0
		aDel( oGridSd:aArray, n ) // APAGAR DA TELA O ESTOQUE
		If len(oGridSd:aArray)==1
			oGridSd:aArray	:= ResetSd()
		Else
			oGridSd:aArray := aSize( oGridSd:aArray , len(oGridSd:aArray)-1 )
		EndIf
		n := aScan( oGridSd:aArray, { |x| x[1] == .T. })
	EndDo
	oGridSd:Refresh()
	
Return(.T.)


/*/{Protheus.doc} LimpaPV
//TODO Deleta itens marcados do saldo.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function LimpaPV()
	Local n := 0
	Local aPv := aClone(oGridPv:aArray)
	
	If aScan( aPv, { |x| x[1] == .T. }) > 0 // recalcula os que foram deixados marcados e nao foram atendidos totalmente
		For n := 1 to len(aPv)
			If aPv[n, 1] == .T. // está marcado
				If aPv[n, PV_TOTAL] <> aPv[n, PV_USADO] // recalcula
					aPv[n, PV_LANCE] := aPv[n, PV_LANCE] - aPv[n, PV_USADL]
					aPv[n, PV_TOTAL] := aPv[n, PV_LANCE] * aPv[n, PV_METRA]
					aPv[n, PV_USADO] := 0
					aPv[n, PV_USADL] := 0
					aPv[n, 1]        := .F.
				EndIf
			EndIf
		Next
	EndIf
	
	oGridPV:Refresh()
	
	n := aScan( aPv, { |x| x[1] == .T. }) // apaga o que restou marcado
	Do While n > 0
		If aPv[n, 1] == .T.
			aDel( aPv, n ) // o item do pedido foi atendido...tem que ser apagado
			If len(aPv)==1
				aPv	:= ResetAPV()
			Else
				aPv := aSize( aPv , len(aPv)-1 )
			EndIf
		EndIf
		n := aScan( aPv, { |x| x[1] == .T. })
	EndDo
	
	oGridPv:aArray := aClone(aPv)
	oGridPV:Refresh()

Return(.T.)


/*/{Protheus.doc} ClassSd
//TODO ClassIfica Saldos de acordo com a sequencia:.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function ClassSd()
	Local aArray := oGridSD:aArray
	
	For i:= 1 to len(aArray)
		Do Case
			Case SUBSTR(aArray[i, SD_ACOND],1,1)  == "B"
				aArray[i,SD_SEQCL] := "9"
			Case SUBSTR(aArray[i, SD_ACOND],1,1)  == "C"
				aArray[i,SD_SEQCL] := "8"
			Case SUBSTR(aArray[i, SD_ACOND],1,1)  == "M"
				aArray[i,SD_SEQCL] := "7"
			Case SUBSTR(aArray[i, SD_ACOND],1,1)  == "R" .And. aArray[i, SD_METRA] > 100
				aArray[i,SD_SEQCL] := "6"
			Case SUBSTR(aArray[i, SD_ACOND],1,1)  == "R" .And. aArray[i, SD_METRA] == 100
				aArray[i,SD_SEQCL] := "5"
			Case SUBSTR(aArray[i, SD_ACOND],1,1)  == "R" .And. aArray[i, SD_METRA] > 50 .And. aArray[i, SD_METRA] < 100
				aArray[i,SD_SEQCL] := "4"
			Case SUBSTR(aArray[i, SD_ACOND],1,1)  == "R" .And. aArray[i, SD_METRA] = 50
				aArray[i,SD_SEQCL] := "3"
			Case SUBSTR(aArray[i, SD_ACOND],1,1)  == "R" .And. aArray[i, SD_METRA] < 50
				aArray[i,SD_SEQCL] := "2"
			Case SUBSTR(aArray[i, SD_ACOND],1,1)  == "T"
				aArray[i,SD_SEQCL] := "1"
		EndCase
	Next
	//// sorteia por sequencia e metragem
	aArray := aSort( aArray , , , { |x,y| x[SD_SEQCL]+StrZero(x[SD_METRA],10,3) > y[SD_SEQCL]+StrZero(y[SD_METRA],10,3) } )
	
	oGridSD:aArray := aclone(aArray)

Return(.T.)


/*/{Protheus.doc} ClassPV
//TODO ClassIfica Pedidos Venda de acordo com a sequencia:.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function ClassPV()
	Local aArray := oGridPV:aArray

	/*
	BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³For i:= 1 to len(aArray)                                                                                     ³
	//³	Do Case                                                                                                     ³
	//³		Case SUBSTR(aArray[i, PV_ACOND],1,1)  == "B"                                                               ³
	//³			aArray[i,PV_SEQCL] := "9"                                                                                 ³
	//³		Case SUBSTR(aArray[i, PV_ACOND],1,1)  == "C"                                                               ³
	//³			aArray[i,PV_SEQCL] := "8"                                                                                 ³
	//³		Case SUBSTR(aArray[i, PV_ACOND],1,1)  == "M"                                                               ³
	//³			aArray[i,PV_SEQCL] := "7"                                                                                 ³
	//³		Case SUBSTR(aArray[i, PV_ACOND],1,1)  == "R" .And. aArray[i, PV_METRA] > 100                               ³
	//³			aArray[i,PV_SEQCL] := "6"                                                                                 ³
	//³		Case SUBSTR(aArray[i, PV_ACOND],1,1)  == "R" .And. aArray[i, PV_METRA] == 100                              ³
	//³			aArray[i,PV_SEQCL] := "5"                                                                                 ³
	//³		Case SUBSTR(aArray[i, PV_ACOND],1,1)  == "R" .And. aArray[i, PV_METRA] > 50 .And. aArray[i, PV_METRA] < 100³
	//³			aArray[i,PV_SEQCL] := "4"                                                                                 ³
	//³		Case SUBSTR(aArray[i, PV_ACOND],1,1)  == "R" .And. aArray[i, PV_METRA] = 50                                ³
	//³			aArray[i,PV_SEQCL] := "3"                                                                                 ³
	//³		Case SUBSTR(aArray[i, PV_ACOND],1,1)  == "R" .And. aArray[i, PV_METRA] < 50                                ³
	//³			aArray[i,PV_SEQCL] := "2"                                                                                 ³
	//³		Case SUBSTR(aArray[i, PV_ACOND],1,1)  == "T"                                                               ³
	//³			aArray[i,PV_SEQCL] := "1"                                                                                 ³
	//³	EndCase                                                                                                     ³
	//³Next                                                                                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	EndDoC
	*/
	//// sorteia por sequencia e metragem
	aArray := aSort( aArray , , , { |x,y| StrZero(x[PV_METRA],10,3) + x[PV_PEDID] + x[PV_ITEM] > StrZero(y[PV_METRA],10,3) + y[PV_PEDID] + y[PV_ITEM] } )
	
	oGridPV:aArray := aArray

Return(.T.)


/*/{Protheus.doc} DelMaior
//TODO Deleta os PVs  com metragens maiores que as do Saldo do PV.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function DelMaior()
	Local aPV := aclone(oGridPV:aArray)
	Local aSD := aclone(oGridSD:aArray)
	
	If mv_par09 == 1 // Sim = elimina maiores
		// classIfica array do saldo por metragem descendente
		aSD := aSort( aSD , , , { |x,y| x[SD_METRA] > y[SD_METRA] } )
		// marca "X" no item com metragem de PV maior que todas no SD
		For i:= 1 to len(aPV)
			If aPV[i, PV_METRA] > aSD[1, SD_METRA]
				aPV[i, PV_SEQCL] := "X"
			EndIf
		Next
		
		// apaga o que restou marcado
		n := aScan( aPV, { |x| x[PV_SEQCL] == "X" })
		Do While n > 0
			If aPV[n, PV_SEQCL] == "X"
				// o item tem metragem maior que todas do SD...tem que ser apagado
				aDel( aPV, n )
				If len(aPV)==1
					aPV	:= ResetAPV()
				Else
					aPV := aSize( aPV , len(aPV)-1 )
				EndIf
			EndIf
			
			n := aScan( aPV, { |x| x[PV_SEQCL] == "X" })
		EndDo
		
		oGridPV:aArray := aclone(aPV)
		oGridPV:Refresh()
		
	EndIf
Return(.T.)


/*/{Protheus.doc} ClassMult
//TODO	ClassIfica Pedidos Venda de acordo com a sequencia:
		multiplos.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function ClassMult()
	Local aPV := oGridPV:aArray
	Local nRes := 0
	Local lret := .F.
	
	For i:= 1 to len(aPV)
		nRes := Int( oGridSD:aArray[oGridSD:nAt,SD_METRA] / apv[i,PV_METRA] )  * apv[i,PV_METRA]
		
		If oGridSD:aArray[oGridSD:nAt, SD_METRA] == nRes   // é multiplo
			If oGridSD:aArray[oGridSD:nAt, SD_ACOND] == apv[i,PV_ACOND]
				aPV[i, PV_SEQCL] := "T"  // multiplos de mesmo acondicionamento
			Else
				aPV[i, PV_SEQCL] := "M"  // multiplos de outros acondicionamentos
			EndIf
			lret := .T.
		Else
			aPV[i, PV_SEQCL] := " "
		EndIf
	Next
	//// sorteia por sequencia e metragem
	aPV := aSort( aPV , , , { |x,y| x[PV_SEQCL] + StrZero(x[PV_METRA],10,3) + x[PV_PEDID] + x[PV_ITEM] > y[PV_SEQCL]+StrZero(y[PV_METRA],10,3) + y[PV_PEDID] + y[PV_ITEM] } )
	
	oGridPV:aArray := aclone(aPV)

Return(lret)


/*/{Protheus.doc} SaldoSobras
//TODO Saldos das Sobras.
@author Robert Santos
@since 23/03/2013
@version undefined
@param lZZE, logical, descricao
@param cIdRetr, characters, descricao
@param nPosSd, numeric, descricao
@param nZZE, numeric, descricao
@type function
/*/
Static Function SaldoSobras(lZZE,cIdRetr,nPosSd,nZZE)
	Local cQry, nQry, nRec
	
	cQry := " SELECT R_E_C_N_O_ ZZEREC from " + RetSqlName("ZZE") + " where ZZE_FILIAL = '" + xFilial("ZZE") + ;
	"' AND D_E_L_E_T_ = ' ' and ZZE_PEDIDO = '000001' and ZZE_FILIAL + ZZE_ID = '" + oGridSd:aArray[nPosSd,SD_IDRE] + ;
	"' AND ZZE_STATUS <> '9' AND ZZE_SITUAC <> '1' AND ZZE_DEVTOT = 0"
	If( Select("TMPSOB") > 0 )
		TMPSOB->(DbCloseArea())
	EndIf
	TcQuery cqry New Alias "TMPSOB"
	Count to nQry
	If nQry > 0
		TMPSOB->(DbGoTop())
		ZZE->(DbGoTo(TMPSOB->(ZZEREC)))
		
		aAdd( aXZZE , { ; // armazenar ID retrabalho
		ZZE->ZZE_FILIAL ;
		, ZZE->ZZE_ID ;
		, ZZE->ZZE_ACONDE ;
		, ZZE->ZZE_METRAE ;
		, ZZE->ZZE_LANCEE ;
		, ZZE->ZZE_TOTEN ;
		} )
		
		nZZE := len(aXZZE)
		lZZE := .T.
		ZZE->(RecLock("ZZE",.F.))
		If ZZE->ZZE_TOTSA <= oGridSd:aArray[nPosSd,SD_USADO]
			ZZE->(DbDelete())
		Else
			// ZZE->ZZE_TOTSA -= oGridSd:aArray[nPosSd,SD_USADO]
			// ZZE->ZZE_LANCES := Int(ZZE->(ZZE_TOTSA / ZZE_METRAS))
			ZZE->ZZE_LANCES := ZZE->ZZE_LANCES - 1
			ZZE->ZZE_TOTSA  := ZZE->(ZZE_METRAS * ZZE_LANCES)
		EndIf
		ZZE->(MsUnLock())
		
		ZZT->(DbSetOrder(3))
		If ZZT->(DbSeek(ZZE->(ZZE_FILIAL + ZZE_ID),.F.))
			ZZT->(RecLock("ZZT",.F.))
			If ZZT->(ZZT_LANCES * ZZT_METRAS) <= oGridSd:aArray[nPosSd,SD_USADO]
				ZZT->(DbDelete())
			Else
				ZZT->ZZT_LANCES -- // SEMPRE O SALDO É INDIVIDUAL
			EndIf
			ZZT->(MsUnLock())
		EndIf
		/*
		cQry := " delete " + RetSqlName("ZZT") + " where D_E_L_E_T_ = ' ' and ZZT_ZZEID = '" + aXZZE[nZZE,2] + "' and ZZT_FILIAL = '" + aXZZE[nZZE,1] + "'  " // Apagar ZZT
		If tcSqlExec( cQry ) < 0
		Alert( tcSqlError() )
		EndIf
		*/
		
		ZZE->(DbSeek(aXZZE[nZZE,1] + aXZZE[nZZE,2],.F.)) // AJUSTAR TOTAIS DE ENTRADA CONDIZENTE COM O RETRABALHO INICIAL
		aXZZE[nZZE,3] := ZZE->ZZE_ACONDE
		aXZZE[nZZE,4] := ZZE->ZZE_METRAE
		aXZZE[nZZE,5] := ZZE->ZZE_LANCEE
		aXZZE[nZZE,6] := ZZE->ZZE_TOTEN
	Else
		lZZE := .F.
	EndIf
	TMPSOB->(DbCloseArea())
	
	If( lZZE == .F. )
		If( Type("aXZZE") == "A" )
			lZZE :=  ( nZZE := aScan( aXZZE , {|x| x[1] + x[2] == oGridSd:aArray[nPosSd,SD_IDRE] }) ) > 0
		EndIf
	EndIf
	
	If lZZE
		cIdRetr := aXZZE[nZZE,2]
	Else
		cIdRetr := GetSXENum("ZZE","ZZE_ID")
		ZZE->(DbSetOrder(1))
		Do While ZZE->(DbSeek(xFilial("ZZE") + cIdRetr,.F.))
			ConfirmSX8()
			cIdRetr := GetSXENum("ZZE","ZZE_ID")
		EndDo
	EndIf

Return(.T.) //nil


/*/{Protheus.doc} MarcarPedido
//TODO Marcar Pedido venda x Estoque.
@author Roberto
@since 23/03/2013
@version undefined
@param nPv, numeric, descricao
@param aPv, array, descricao
@type function
/*/
Static Function MarcarPedido(nPv, aPv) // 
	Local aSd	:= oGridSD:aArray
	Local nId1 := 0 // menor sobra mesmo acondicionamento
	Local nId2 := 0 // menor sobra demais acondicionamento
	Local nId := 0
	Local nSobra := 0
	Local lAlertado := .F.
	
	For i := 1 to len( aSd ) // VerIficar ID de saldo disponivel em menor quantidade de sobra
		If( (aSd[i,SD_TOTAL] - aSd[i,SD_USADO]) >= aPv[nPv,PV_METRA] .And. aSd[i,SD_METRA] >= aPv[nPv,PV_METRA] ) // tem saldo ?
			nSobra := aSd[i,SD_METRA] - aPv[nPv,PV_METRA]
			If( aSd[i,SD_ACOND] == aPv[nPv,PV_ACOND] )
				If( !Empty(nId1) )
					If( nSobra < (aSd[nId1,SD_METRA] - aPv[nPv,PV_METRA]) )
						nId1 := i
					EndIf
				Else
					nId1 := i
				EndIf
			Else
				If( !Empty(nId2) )
					If( nSobra < (aSd[nId2,SD_METRA] - aPv[nPv,PV_METRA]) )
						nId2 := i
					EndIf
				Else
					nId2 := i
				EndIf
			EndIf
		EndIf
	Next
	
	If( nId1 > 0 ) // selecionar quem é o melhor para atender
		If( nId2 > 0)
			If( (aSd[nId2,SD_METRA] - aPv[nPv,PV_METRA]) < (aSd[nId1,SD_METRA] - aPv[nPv,PV_METRA]) ) // pegar a menor sobra independente do lance
				nId := nId2
			Else
				nId := nId1
			EndIf
		Else
			nId := nId1
		EndIf
	Else
		nId := nId2
	EndIf
	
	If( nId > 0 )
		GerarSR( nId , nPv , .F., @lAlertado )		
		If( aPv[nPv,PV_MARCA] == .F. )
			If( lCortar )
				GerarSR( nPosSdCt , nPv , .F., @lAlertado )
			EndIf
			If( aPv[nPv,PV_MARCA] == .F. )
				Alert( "Não foi possivel efetuar saldo! VerIficar para atender à sobra atual / Saldo Estoque !" )
			EndIf
		EndIf
	Else
		Alert( "Não foi possível encontrar saldo disponivel!" )
	EndIf

Return(.T.)


/*/{Protheus.doc} MarcarSaldo
//TODO SALDO SELECIONADO.
@author Roberto
@since 23/03/2013
@version undefined

@type function
/*/
Static Function MarcarSaldo()
	Local aSd := oGridSd:aArray[ oGridSd:nAt ] // SALDO SELECIONADO
	Local aPv := oGridPv:aArray
	Local i,j
	Local aAtend := {}
	Local lAlertado := .F.
	
	For i:=1 to len(aPV) // 1o - Buscar medidas exatas para separacao
		If( apv[i,PV_METRA] == aSd[SD_METRA] .And. aPv[i,PV_LANCE] > aPv[i,PV_USADL] .And. (!aPv[i, PV_MCNEG] ) .And. (aPv[i,PV_NEGOC] $ "6 ") )
			aAdd( aAtend , i ) // adicionar o pedido de venda que posso atender
		EndIf
	Next
	
	If( len(aAtend) > 0 )
		For i := 1 to Len(aAtend)
			GerarSR(oGridSd:nAt , aAtend[i], .F. , @lAlertado ) // Temporário de separar retrabalhar
		Next
	EndIf
	
	For i := 1 to len(aPv) // 2o - Buscar corte
		If( aPv[i,PV_USADO] < aPv[i,PV_TOTAL] .And. (aPv[i,PV_NEGOC] $ "6 ") ) // validar que o pedido está pendente
			GerarSR(oGridSd:nAt , i , .F. , @lAlertado )
		EndIf
	Next
	
	If( lAlertado == .F. .And. oGridSd:aArray[oGridSd:nAt,SD_MARCA] == .F. )
		Alert( "Não foi possivel marcar saldo, analise correspondencia com PV ou destine as sobras!" )
	EndIf
Return(.T.) //nil


/*/{Protheus.doc} GerarSR
//TODO Gerar Separacao ou Retrabalho.
@author Robert Santos
@since 23/03/2013
@version undefined
@param nPosSD, numeric, descricao
@param nPosPV, numeric, descricao
@param lAlertar, logical, descricao
@param lAlertado, logical, descricao
@type function
/*/
Static Function GerarSR(nPosSD, nPosPV, lAlertar, lAlertado ) 
	Local aSd		:= oGridSd:aArray[ nPosSD ]
	Local aPv		:= oGridPv:aArray
	Local nSDLivre	:= aSd[SD_TOTAL] - aSd[SD_USADO]
	Local nSdPedido	:= aPv[nPosPV,PV_TOTAL] - aPv[nPosPV,PV_USADO]
	Local nUsado, cErro
	
	If( nSDLivre > 0 .And. nSdPedido > 0)
		If( aSd[SD_METRA] == aPv[nPosPv,PV_METRA] ) // validar separacao em medida exata
			nUsado		:= iIf( nSDLivre <= nSdPedido , nSDLivre , nSdPedido ) // lances a serem usados
			
			aSd[SD_MARCA] := .T. // Atualizar variaveis da tela
			aSd[SD_USADO] += nUsado
			aSd[SD_USADL] := iIf( (aSd[SD_USADO] % aSd[SD_METRA]) > 0 , NoRound(aSd[SD_USADO]/aSd[SD_METRA],0) + 1 , Round(aSd[SD_USADO]/aSd[SD_METRA],0) )
			
			aPv[nPosPv,PV_MARCA] := .T.
			aPv[nPosPv,PV_USADO] += nUsado
			aPv[nPosPv,PV_USADL] := aPv[nPosPv,PV_USADO] / aPv[nPosPv,PV_METRA]
			
			i := aScan( aSdPv , {|x| x[1] == aSd[SD_BOBIN] .And. x[2] == aPv[nPosPv,PV_ID] }) // relacao (n) SD x (n) PV
			If( i == 0 )
				aAdd( aSdPv , { aSd[SD_BOBIN] , aPv[nPosPv,PV_ID] } )
			EndIf
			
			GerarSRa(nPosSd, nPosPv, nUsado, ( aSd[SD_ACOND] == aPv[nPosPv,PV_ACOND] .And. Empty(aSd[SD_IDRE]) ) ) // gerar arquivo de separacao temporarios
		Else
			If( aSd[SD_METRA] >= aPv[nPosPv,PV_METRA] )
				If( lCortar == .F. .Or. (nPosSd == nPosSdCt .And. (aSd[SD_TOTAL] - aSd[SD_USADO] >= aPv[nPosPv,PV_METRA] ) ) )
					nUsado		:= aPv[nPosPv,PV_METRA]
					
					aSd[SD_MARCA] := .T. // Atualizar variaveis da tela
					aSd[SD_USADO] += nUsado
					aSd[SD_USADL] := iIf( (aSd[SD_USADO] % aSd[SD_METRA]) > 0 , NoRound(aSd[SD_USADO]/aSd[SD_METRA],0) + 1 , Round(aSd[SD_USADO]/aSd[SD_METRA],0) )
					
					aPv[nPosPv,PV_MARCA] := .T.
					aPv[nPosPv,PV_USADO] += nUsado
					aPv[nPosPv,PV_USADL] := aPv[nPosPv,PV_USADO] / aPv[nPosPv,PV_METRA]
					
					mSobra( aSd[SD_METRA] * aSd[SD_USADL] , (aSd[SD_METRA] * aSd[SD_USADL]) - aSd[SD_USADO ],  nPosSD , nPosPV )  // registrar sobras
					
					i := aScan( aSdPv , {|x| x[1] == aSd[SD_BOBIN] .And. x[2] == aPv[nPosPv,PV_ID] }) // relacao (n) SD x (n) PV
					If( i == 0 )
						aAdd( aSdPv , { aSd[SD_BOBIN] , aPv[nPosPv,PV_ID] } )
					EndIf
					
					GerarSRa(nPosSd, nPosPv, nUsado, .F. ) // gerar arquivo de separacao temporarios
				Else
					If( nPosSd == nPosSdCt ) // validar corte no mesmo estoque
						If( nQtdSobra >= aPv[nPosPv,PV_METRA] )
							nUsado := NoRound( nQtdSobra / ( aPv[nPosPv,PV_TOTAL] - aPv[nPosPv,PV_USADO] ) , 0 ) * aPv[nPosPv,PV_METRA]
							
							aSd[SD_USADO] += nUsado
							aSd[SD_USADL] := iIf( (aSd[SD_USADO] % aSd[SD_METRA]) > 0 , NoRound(aSd[SD_USADO]/aSd[SD_METRA],0) + 1 , Round(aSd[SD_USADO]/aSd[SD_METRA],0) )
							
							aPv[nPosPv,PV_USADO] += nUsado
							aPv[nPosPv,PV_USADL] := aPv[nPosPv,PV_USADO] / aPv[nPosPv,PV_METRA]
							
							mSobra( (aSd[SD_METRA] * aSd[SD_USADL]) , ((aSd[SD_METRA] * aSd[SD_USADL])-aSd[SD_USADO]), nPosSDCt, nPosPv )
							
							i := aScan( aSdPv , {|x| x[1] == aSd[SD_BOBIN] .And. x[2] == aPv[nPosPv,PV_ID] }) // relacao (n) SD x (n) PV
							If( i == 0 )
								aAdd( aSdPv , { aSd[SD_BOBIN] , aPv[nPosPv,PV_ID] } )
							EndIf
							aPv[nPosPv,PV_MARCA] := .T.
							
							GerarSRa(nPosSd, nPosPv, nUsado, .F. ) // gerar arquivo de separacao temporarios
						Else
							cErro := "Quantidade em sobra insuficiente!"
						EndIf
					Else
						cErro := "Já possui Sobras por outra seleção de estoque!"
					EndIf
				EndIf
			Else
				cErro := "Medida do pedido superior à do estoque!"
			EndIf
		EndIf
		oGridSd:Refresh()
		oGridPv:Refresh()
	Else
		cErro := "Sem saldo disponivel!"
	EndIf
	
	If( lAlertar .And. !Empty( cErro ) )
		Alert( cErro )
		lAlertado := .T.
	EndIf
Return(.T.)


/*/{Protheus.doc} GerarSRa
//TODO atualizar arquivo temporario de sep / retrabalho APEDRET.
@author Robert Santos
@since 23/03/2013
@version undefined
@param nPosSd, numeric, descricao
@param nPosPv, numeric, descricao
@param nUsado, numeric, descricao
@param lSeparar, logical, descricao
@type function
/*/
Static Function GerarSRa(nPosSd, nPosPv, nUsado, lSeparar ) // 
	Local i,j
	Local aSd		:= oGridSd:aArray[nPosSd]
	Local aPv		:= oGridPv:aArray[nPosPv]
	Local aPedRets	:= {}
	Local aPedRet	:= {}
	
	i := aScan( aSepRet , { |x| x[1] == aSd[SD_BOBIN] } )
	If( i == 0 )
		aAdd( aSepRet, { aSd[SD_BOBIN] , aPedRets } )
		i := len( aSepRet )
	EndIf
	aPedRets := aSepRet[i,2]
	
	If( Empty(aPedRets) )
		j := 0
	Else
		j := aScan( aPedRets, {|x| x[1] == aPv[PV_ID] .And. x[2] == iIf(lSeparar,"S","R") } )
	EndIf
	
	If( j == 0 )
		aAdd( aPedRets , Array(10) )
		j := len( aPedRets )
	EndIf
	aPedRet := aPedRets[j]
	
	If( !Empty(aPedRet[03]) ) // validar se ja possui saldo
		nUsado += aPedRet[03]
	EndIf
	
	aPedRet[01] := aPv[PV_ID]
	aPedRet[02] := iIf(lSeparar,"S","R")
	aPedRet[03] := nUsado
	aPedRet[04] := aPv[PV_METRA]
	aPedRet[05] := Int( nUsado / aPv[PV_METRA] ) //lance
	aPedRet[06] := aPv[PV_PEDID]
	aPedRet[07] := "" // ID DO RETRABALHO GERADO

Return(.T.)


/*/{Protheus.doc} PegarBf
//TODO Posicionar no Sbf com saldo aberto (se houver).
@author Robert Santos
@since 23/03/2013
@version undefined
@param cBF_FILIAL, characters, descricao
@param cBF_LOCAL, characters, descricao
@param cBF_LOCALIZ, characters, descricao
@param cBF_PRODUTO, characters, descricao
@type function
/*/
Static Function PegarBf( cBF_FILIAL, cBF_LOCAL, cBF_LOCALIZ, cBF_PRODUTO )
	Local cQry, nQry, lRet
	
	cqry := " SELECT R_E_C_N_O_ NBF from " + RetSqlName("SBF") + " WHERE D_E_L_E_T_ = ' ' and BF_FILIAL = '" + cBF_FILIAL + "' and BF_LOCALIZ = '" + cBF_LOCALIZ + "' " + CRLF
	cqry += " and BF_PRODUTO = '" + cBF_PRODUTO + "' " + CRLF
	cqry += " and BF_LOCAL = '" + cBF_LOCAL + "' " + CRLF
	cqry += " and BF_QUANT - BF_EMPENHO > 0 " + CRLF
	If( Select("TMPBFC") > 0 )
		TMPBFC->(DbCloseArea())
	EndIf
	TcQuery cQry New Alias "TMPBFC"
	Count to nqry
	If nqry > 0
		lret := .T.
		TMPBFC->(DbGoTop())
		SBF->( DbGoTo( TMPBFC->(NBF) ) )
	Else
		lret := .F.
		SBF->( DbGoBottom() )
	EndIf
	TMPBFC->( DbCloseArea() )

Return(lRet)

/*/{Protheus.doc} ResetSD
//TODO Reseta Saldo.
@author Roberto
@since 23/03/2013
@version undefined

@type function
/*/
Static Function ResetSD()
	Local aSd := {}
	aadd( aSD , {.F.,.F.,"","",0,0,0,0,0,"","","","","",""} )
Return(aSd)


/*/{Protheus.doc} CriarNeg
//TODO Cria Negociação.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function CriarNeg() // Bottom to send itens from Order to Deal
	Local aPv := aClone(oGridPv:aArray)
	Local aPvNeg := {} // ARRAY TO RETAINS THE ORDERS TO DEAL
	Local aSd := {}
	Local aAl := {}
	Local aProdOfer := {}
	Local i, j, lok
	Local cZZVID := ""
	Local _lSuspProd := .T.
	
	//Validar se a bobina ou o saldo ainda está disponível para efetuar a negociação
	
	If Empty(cObserv)
		Alert("Atenção!!" + CRLF + "Digite uma observação para o setor de Vendas!")
	Else
		For i := 1 to len(aPv) // acumular itens de pedido marcados
			If( aPv[i,PV_MCNEG] )
				// By Roberto Oliveira // Verificar se o ítem já não foi ou está sendo negociado
				DbSelectArea("SC6")
				DbSetOrder(1)
				DbSeek(xFilial("SC6")+aPv[i,3]+aPv[i,4],.F.)
				If !Empty(SC6->C6_XNEGOC)
					Alert("Pedido " + aPv[i,3] + "-" + aPv[i,4] + "Já Passou por Negociação!")
				Else
					_lSuspProd := .T. // Produção suspensa ?
					If MV_PAR10==2
						_lSuspProd := u_GraveSZ9("P") // Atenção... o SC6 tem que estar posicionado
					EndIf     
					If !_lSuspProd
						Alert("Pedido " + aPv[i,3] + "-" + aPv[i,4] + "Entrou em Produção!")
					Else
						If( Empty(aPvNeg) )
							aAdd( aPvNeg, aPv[i] )
						Else
							aPvNeg[1,PV_LANCE] ++
							aPvNeg[1,PV_TOTAL] := Int( aPvNeg[1,PV_METRA] * aPvNeg[1,PV_LANCE])
						EndIf
					EndIf
				EndIf
			EndIf
		Next
		If len(aPvNeg) > 0
			
			lOk := .F.
			
			aSd := aClone(oGridSd:aArray)
			i := AScan( aSd , {|x| x[SD_MCNEG] == .T. } )
			If( i > 0 ) // Gera negociacao com saldo de estoque
				aProdOfer := {}
				AAdd(aProdOfer,cB1_COD)
				AAdd(aProdOfer,Substr(aSd[i,SD_ACOND],1,1))
				AAdd(aProdOfer,aSd[i,SD_LANCE])
				AAdd(aProdOfer,aSd[i,SD_METRA])
				AAdd(aProdOfer,aSd[i,SD_ALMOX])
				AAdd(aProdOfer,aSd[i,SD_TPBOB])
				AAdd(aProdOfer,aSd[i,SD_BOBIN])
				
				If GvNeg(aPvNeg , aProdOfer, @cZZVID) // Enviou para negociacao ????
					If Len(aSd) == 1  // retirar o estoque da tela !!!
						aSd := ResetSd()
					Else
						aSd := aDel(aSd,i)
						aSd := aSize(aSd, len(aSd) -1 )
					EndIf
					oGridSd:aArray := aClone(aSd)
					oGridSd:Refresh()
					lOk := .T.
				EndIf
			EndIf
			
			aAl := aClone(oGridAl:aArray)
			i := AScan( aAl , {|x| x[AL_MARCA] == .T. } )
			If( i > 0 ) // Gerar negociacao com o alternativo selecionado
				aProdOfer := {}
				AAdd(aProdOfer,aAl[i,AL_PRODU])
				AAdd(aProdOfer,Substr(aAl[i,AL_ACOND],1,1))
				AAdd(aProdOfer,aAl[i,AL_LANCE])
				AAdd(aProdOfer,aAl[i,AL_METRA])
				AAdd(aProdOfer,aAl[i,AL_ALMOX])
				AAdd(aProdOfer,aAl[i,AL_TPBOB])
				AAdd(aProdOfer,aAl[i,AL_BOBIN])
				
				If GvNeg(aPvNeg , aProdOfer, @cZZVID)
					If Len(aAl) == 1  // retirar o estoque da tela !!!
						aAl := ResetAl()
					Else
						aAl := aDel(aAl,i)
						aAl := aSize(aAl, len(aAl) -1 )
					EndIf
					oGridAl:aArray := aClone(aAl)
					oGridAl:Refresh()
					lOk := .T.
				EndIf
			EndIf
			
			If lOk
				SC6->(DbSetOrder(1))
				_cUltPed := " "
				For i := 1 to len(aPv)// atualizar pedidos marcados na negociacao
					If( aPv[i,PV_MCNEG] )
						aPv[i,PV_MCNEG] := .F.
						aPV[i,PV_NEGOC] := "1"
						
						If _cUltPed # (aPv[i,PV_PEDID]+aPv[i,PV_ITEM])
							_cUltPed := (aPv[i,PV_PEDID]+aPv[i,PV_ITEM])
							SC6->(DbSeek(xFilial("SC6") + aPv[i,PV_PEDID] + aPv[i,PV_ITEM] ,.F.))
							SC6->(RecLock("SC6",.F.))
							SC6->C6_XNEGOC := "1" // EM NEGOCIACAO
							SC6->C6_XQTDNEG := TotNegCO("ZZV_LANCES",aPv[i,PV_PEDID],aPv[i,PV_ITEM],xFilial("SC6")) // TOTAL DE LANCES EM NEGOCIACAO
							If SC6->C6_XQTDNEG == SC6->C6_LANCES // Roberto/Juliana
								SC6->C6_SEMANA := "N" + cZZVID
							EndIf
							SC6->(MsUnLock())
						EndIf
					EndIf
				Next
				oGridPv:aArray := aClone(aPv)
				oGridPv:Refresh()
			EndIf
			
			cObserv := space(TamSX3("ZR_OBS")[1])
			oObserv:Refresh()
		Else
			Alert("Nenhum pedido marcado para negociação!")
		EndIf
	EndIf
Return(.T.)


/*/{Protheus.doc} GvNeg
//TODO Grava Negociação.
@author Robert Santos
@since 23/03/2017
@version undefined
@param aPvNeg, array, descricao
@param aProdOfer, array, descricao
@param cZZVID, characters, descricao
@type function
/*/
Static Function GvNeg(aPvNeg, aProdOfer, cZZVID)
	Local cPara := GETMV("MV_XLocalC")
	Local lTransf := .F.
	Local lOk := .F.
	Local aRet
	
	cZZVID := GetSXENum("ZZV","ZZV_ID")
	ConfirmSX8()
	ZZV->(DbSetOrder(1))
	Do While ZZV->(DbSeek(xFilial("ZZV") + cZZVID,.F.))
		cZZVID := GetSXENum("ZZV","ZZV_ID")
		ConfirmSX8()
	EndDo
	
	SC5->(DbSeek(xFilial("SC5") + aPvNeg[1,PV_PEDID],.F.))
	
	// By Roberto Oliveira - 23/01/2015
	// Alterada a forma de tgratamento da reserva de materiais tanto para negociação como para retrabalho.
	// Os materiais não mais serão transferidos de Aarmazéns e sim controlados na tabela SDC como empenhos,
	// sendo a origem a tabela ZZV-Negociação ou ZZ?-Retrabalho
	// A chamada da função CRESTXT fica desativada e criamos a função EmpSDC para tratar essa condição
	
	
	// Inicio Roberto Oliveira 19/03/14
	//aRet := u_CRESTXT(.F./*lRetrab*/,aProdOfer[1],aProdOfer[2] + StrZero(aProdOfer[4],5,0)/*cLocaliz*/,aProdOfer[2]/*cAcond*/,aProdOfer[5]/*cDe*/,cPara,aProdOfer[3] * aProdOfer[4] /*nQuant*/, aProdOfer[6] /*cZE_TPBOB*/, .T., aProdOfer[7]) // Transferir o Material
	// Chamada desativada em 23/01/2015   aRet := u_CRESTXT(	.F./*lRetrab*/,aProdOfer[1],;
	//												PadR(aProdOfer[2] + StrZero(aProdOfer[4],5,0),TamSX3("BE_LocalIZ")[1])/*cLocaliz*/,;
	//												aProdOfer[2]/*cAcond*/,aProdOfer[5]/*cDe*/,cPara,aProdOfer[3] * aProdOfer[4] /*nQuant*/, aProdOfer[6] /*cZE_TPBOB*/, .T., aProdOfer[7]) // Transferir o Material
	// Fim Roberto Oliveira 19/03/14

	// Chamada da nova função para gravar o empenho no SDC com origem ZZV
	//u_EmpSDC(.t.:.f.,Origem:ZZV:ZZF,Produto,Local,Localiz,Quant,Docto:IdRetrab:IdNegoc,Nro.Bobina)
	
	aRet := u_EmpSDC(.T. /* .T.=Empenhar .F.=Cancelar Empenho*/,;
			"ZZV"/*Origem*/,;
			aProdOfer[1]/*Produto*/,;
			"01"/*Local*/,;
			PadR(aProdOfer[2]+StrZero(aProdOfer[4],5),TamSX3("BE_LOCALIZ")[1])/*Localiz*/,;
			(aProdOfer[3] * aProdOfer[4])/*Quant*/,;
			cZZVID/*Docto*/,;
			aProdOfer[7]/*Nro.Bobina*/,;
			.F. /*Trata ou não Transação*/;
			)

	If aRet[1] //
		
		DbSelectArea("ZZV")
		
		ZZV->(RecLock("ZZV",.T.))
		ZZV->ZZV_FILIAL	:= xFilial("ZZV")
		ZZV->ZZV_STATUS	:= "1" // FALTA INICIAR ATENDIMENTO
		ZZV->ZZV_ID		:= cZZVID
		ZZV->ZZV_FILPV	:= xFilial("SC5")
		ZZV->ZZV_PEDIDO	:= aPvNeg[1,PV_PEDID]
		ZZV->ZZV_ITEM 	:= aPvNeg[1,PV_ITEM]
		ZZV->ZZV_PRODUT	:= aPvNeg[1,PV_PRODU] // SB1->B1_COD
		// ZZV->ZZV_DESC	:= SB1->B1_DESC // Está trazendo dados errado... Fiz a linha de baixo para corrigir
		ZZV->ZZV_DESC	:= 	Posicione("SB1",1,xFilial("SB1")+ZZV->ZZV_PRODUT,"B1_DESC")
		ZZV->ZZV_ACOND	:= aPvNeg[1,PV_ACOND]
		ZZV->ZZV_LANCES	:= aPvNeg[1,PV_LANCE]
		ZZV->ZZV_METRAG	:= aPvNeg[1,PV_METRA]
		ZZV->ZZV_PROALT	:= aProdOfer[1] // NEGOCIAR COMO
		ZZV->ZZV_ACONAL	:= aProdOfer[2]
		ZZV->ZZV_LANCEA	:= aProdOfer[3]
		ZZV->ZZV_METRAL	:= aProdOfer[4]
		ZZV->ZZV_NOMEC	:= aPvNeg[1,PV_NOMEC]
		ZZV->ZZV_ENTREG	:= aPvNeg[1,PV_ENTRE]
		ZZV->ZZV_DATA	:= dDATABASE
		ZZV->ZZV_VEND	:= SC5->C5_VEND1
		ZZV->ZZV_RESP	:= Posicione("SA3",1,xFilial("SA3") + SC5->C5_VEND1, "A3_NOME")
		ZZV->ZZV_TPBOB	:= aProdOfer[6]
		ZZV->ZZV_Local	:= cPara
		ZZV->ZZV_OBS01	:= cObserv
		ZZV->ZZV_NUMBOB	:= aProdOfer[7]
		ZZV->ZZV_SUPER  := Posicione("SA3",1,xFilial("SA3") + SC5->C5_VEND1, "A3_SUPER")
		ZZV->(MsUnLock())
		lOk := .T.
	Else
		lOk := .F.
	EndIf
Return(lOk)

/*/{Protheus.doc} ResetAPV
//TODO Descrição auto-gerada.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function ResetAPV()
	Local aPv := {}
	aadd( aPV , {.F.,.F.,"","","","",0,0,0,0,0,"","","",ctod("//"),"","",0,"",""} )
Return(aPv)


/*/{Protheus.doc} ResetAl
//TODO Descrição auto-gerada.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function ResetAl()
	Local aAl := {}
	aadd( aAL , {.F.,"","",0,0,0,0,0,"","","","",""} )
Return(aAl)


/*/{Protheus.doc} RsetAPV1
//TODO Descrição auto-gerada.
@author juliana.leme
@since 23/03/2013
@version undefined

@type function
/*/
Static Function RsetAPV1()
	Local aPv1 := {}
	aadd( aPV1 , {.F.,"","","","","","","",0,0,0,ctod("//"),"",0,""} )
Return(aPV1)


/*/{Protheus.doc} XNegoc
//TODO Descrição auto-gerada.
@author juliana.leme
@since 14/07/2017
@version undefined
@param cC6_XNEGOC, characters, descricao
@type function
/*/
Static Function XNegoc(cC6_XNEGOC)
	Local oRet := nil
	Do Case
		Case cC6_XNEGOC == "1" // Falta iniciar atendimento ZZV_STATUS
			oRet := oAmarelo
		Case cC6_XNEGOC == "2" // Em negociacao
			oRet := oAzul
		Case cC6_XNEGOC == "3" // Agendamento futuro
			oRet := oVermelho
		Case cC6_XNEGOC == "4" // Falta aprovacao supervisao
			oRet := oPink
		Case cC6_XNEGOC == "5" // Falta alterar pedido
			oRet := oMarrom
		Case cC6_XNEGOC == "6" // Rejeitado cobrecom
			oRet := oBranco
		Case cC6_XNEGOC == "7" // Pedido Alterado
			oRet := oVerde
		Case cC6_XNEGOC == "" // NAO ESTA EM NEGOCIACAO
			oRet := oPreto
	EndCase
Return(If(Empty(oRet),oPreto,oRet))


/*/{Protheus.doc} Lvendas
//TODO Legenda Negociação.
@author Robert Santos
@since 23/03/2013
@version undefined

@type function
/*/
Static Function Lvendas()
	Local aLegenda	:= {}
	AAdd( aLegenda, {"BR_VERMELHO","Gerado agendamento contato"})
	AAdd( aLegenda, {"BR_AMARELO","Falta Iniciar Negociação"})
	AAdd( aLegenda, {"BR_AZUL","Em negociação"})
	AAdd( aLegenda, {"BR_PINK","Falta Aprovação supervisor"})
	AAdd( aLegenda, {"BR_MARROM","Falta Alterar Pedido"})
	AAdd( aLegenda, {"BR_VERDE","Finalizado Com Aceite"})
	AAdd( aLegenda, {"BR_BRANCO","Finalizado Rejeitado"})
	AAdd( aLegenda, {"BR_PRETO","Sem negociação"})
	BrwLegenda("Controle Negociacao", "Legenda" , aLegenda)
Return(.T.)


/*/{Protheus.doc} TotRetCO
//TODO Buscar total de lances em retrabalho.
@author Robert Santos
@since 23/03/2013
@version undefined
@param cCampo, characters, descricao
@param cPedido, characters, descricao
@param cItemPv, characters, descricao
@type function
/*/
Static Function TotRetCO(cCampo,cPedido,cItemPv) // 
	Local cQry, nQry, nValor
	If Select("EST1A") > 0
		EST1A->(DbCloseArea())
	EndIf
	cQry := " SELECT SUM(" + cCampo + ") TOTAL "
	cQry += " FROM " + RetSqlName("ZZE") + " ZZE "
	cQry += " WHERE ZZE_PEDIDO = '" + cPedido + "' "
	cQry += " AND ZZE_ITEMPV = '" + cItemPv + "' "
	cQry += " AND D_E_L_E_T_ = ' ' "
	cQry += " AND ZZE_STATUS <> '9' " // CANCELADO
	cQry += " AND ZZE_FILIAL = '" + xFilial("ZZE") + "' "
	TcQuery cqry New Alias "EST1A"
	Count to nqry
	If nqry > 0
		EST1A->(DbGoTop())
		nValor := EST1A->(TOTAL)
	Else
		nValor := 0
	EndIf
	EST1A->(DbCloseArea())
Return(nValor)


/*/{Protheus.doc} TotNegCO
//TODO TOTAL DE LANCES EM NEGOCIACAO.
@author Robert Santos
@since 23/03/2013
@version undefined
@param cCampo, characters, descricao
@param cPedido, characters, descricao
@param cItemPv, characters, descricao
@param cFilPv, characters, descricao
@type function
/*/
Static Function TotNegCO(cCampo,cPedido,cItemPv,cFilPv) // 
	Local cQry, nQry, nValor
	If Select("EST1A") > 0
		EST1A->(DbCloseArea())
	EndIf
	cQry := " SELECT SUM(" + cCampo + ") TOTAL " + CRLF
	cQry += " FROM " + RetSqlName("ZZV") + " ZZV " + CRLF
	cQry += " WHERE ZZV_PEDIDO = '" + cPedido + "' " + CRLF
	cQry += " AND ZZV_FILPV = '" + cFilPv + "' " + CRLF
	cQry += " AND ZZV_ITEM = '" + cItemPv + "' " + CRLF
	cQry += " AND D_E_L_E_T_ = ' ' " + CRLF
	cQry += " AND ZZV_FILIAL = '" + xFilial("ZZV") + "' " + CRLF
	TcQuery cqry New Alias "EST1A"
	Count to nqry
	If nqry > 0
		EST1A->(DbGoTop())
		nValor := EST1A->(TOTAL)
	Else
		nValor := 0
	EndIf
	EST1A->(DbCloseArea())
Return(nValor)


/*/{Protheus.doc} RtStNeg
//TODO BUSCAR TODOS STATUS EM NEGOCIACAO DO ITEM.
@author Roberto
@since 23/03/2013
@version undefined
@param cFilPv, characters, descricao
@param cPedido, characters, descricao
@param cItemPv, characters, descricao
@type function
/*/
Static Function RtStNeg(cFilPv,cPedido,cItemPv) // 
	Local aret := {}
	Local cQry, nQry, nValor
	If Select("EST1A") > 0
		EST1A->(DbCloseArea())
	EndIf
	cQry := " SELECT ZZV_STATUS " + CRLF
	cQry += " FROM " + RetSqlName("ZZV") + " ZZV " + CRLF
	cQry += " WHERE ZZV_PEDIDO = '" + cPedido + "' " + CRLF
	cQry += " AND ZZV_FILPV = '" + cFilPv + "' " + CRLF
	cQry += " AND ZZV_ITEM = '" + cItemPv + "' " + CRLF
	cQry += " AND D_E_L_E_T_ = ' ' " + CRLF
	cQry += " AND ZZV_FILIAL = '" + xFilial("ZZV") + "' " + CRLF
	TcQuery cqry New Alias "EST1A"
	Count to nqry
	If nqry > 0
		EST1A->(DbGoTop())
		Do While ! EST1A->(Eof())
			AADD(aRET,EST1A->ZZV_STATUS)
			EST1A->(dbskip())
		EndDo
	EndIf
	EST1A->(DbCloseArea())
Return(aRet)


/*/{Protheus.doc} EmpSDC
//TODO Empenha SDC.
@author Roberto
@since 23/03/2013
@version undefined
@param _lEmpenha, , descricao
@param _cOrigem, , descricao
@param _cPrd, , descricao
@param _cArmz, , descricao
@param _cAcond, , descricao
@param _nQtd, , descricao
@param _cDocto, , descricao
@param _nBob, , descricao
@param _lTrans, , descricao
@param _cItem, , descricao
@param lReserva, logical, descricao
@param lCancZZF, logical, descricao
@type function
/*/
User Function EmpSDC(_lEmpenha,_cOrigem,_cPrd,_cArmz,_cAcond,_nQtd,_cDocto,_nBob,_lTrans,_cItem,lReserva,lCancZZF)
	//EmpSDC(.t.:.f.  ,Origem:ZZV:ZZF,Produto,Local ,Localiz,Quant,Docto:IdRetrab:IdNegoc,Nro.Bobina,Trata Transação, Item do Documento)
	// U_EmpSDC(.F.,"ZZV","1151304401","01","B00218",218,"000736","1506364",.T.)
	local aRet        := {.F.,"NAO INICIADO"} // 1= OK?, 2=MENSAGEM
	local cPeso       := 0 // INDICADOR DO PESO DO PRODUTO
	local nBF_LOCALIZ := TamSX3("BF_LOCALIZ")[1]
	Local _lEmpenha // .T.=Empenhar  /  .F.=Cancelar Empenho
	Local _cItem
	Local lReserva, lCancZZF
	oEmpSdc	:=  nil 
	
	Default _lTrans := .T. // Tratar BeginTran() nesta função 
	Default _cItem := "  "
	Default lReserva := .F.
	Default lCancZZF := .F.
	
	if lNewSdc
		oEmpSdc	:= cbcEmpSdc():newcbcEmpSdc()
		oEmpSdc:setOrigEmp(_cOrigem)
		oEmpSdc:setCodProd(_cPrd)
		oEmpSdc:setArmazem(_cArmz)
		oEmpSdc:setAcond(_cAcond)
		oEmpSdc:setQtdEmp(_nQtd)
		oEmpSdc:setDoctoEmp(_cDocto)
		oEmpSdc:setItemDocto(_cItem)
		oEmpSdc:setNroBob(_nBob)
		oEmpSdc:setCancZZF(lCancZZF)
		
		if !oEmpSdc:procEmpenho(!_lEmpenha):isOk()
			aRet[1] := .F.
			aRet[2] := oEmpSdc:getMsgErr()
		else
			aRet[1] := .T.
			aRet[2] := ''
		endif
		
		freeobj(oEmpSdc)
	else
		
		_cItem  := PADR(_cItem,TamSX3("DC_ITEM")[1])
		_cPrd   := PADR(_cPrd ,TamSX3("B1_COD")[1])
		_cArmz  := PADR(_cArmz,TamSX3("B1_LOCPAD")[1])
		_cAcond := PADR(_cAcond,nBF_LOCALIZ)
		
		DbSelectArea("SBF")
		DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		
		DbSelectArea("SB1")
		DbSetOrder(1) // B1_FILIAL+B1_COD   
		SB1->(DbSeek(xFilial("SB1") + _cPrd,.F.))
		
		DbSelectArea("SB2")
		DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
		
		DbSelectArea("SZE")
		dbsetorder(1)
		
		DbSelectArea("SDC")
		DbSetOrder(1) // DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
		
		aRet[1] := .T. // Adicionado por Roberto Oliveira 30/05/14 -> ver outras observações de 30/05/14
		
		If _lTrans
			//	Begin Transaction
			BeginTran()
		EndIf
		
		// Verificar se tem saldo para fazer a movimentação
		DbSelectArea("SBF") //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		
		If _lEmpenha // Empenhar
			SBF->(DbSetOrder(1))  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
			SBF->(DbSeek(xFilial("SBF")+_cArmz+_cAcond+_cPrd,.F.))
			If SBF->(Eof()) .Or. (SBF->BF_QUANT - SBF->BF_EMPENHO) < _nQtd  .Or. SBF->BF_EMPENHO < 0 // Acredite... já peguei casos em que o empenho estava negativo...
				aRet[1] := .F.
				aRet[2] := "SEM SALDO SUFICIENTE"
			ElseIf Left(_cAcond,1) == "B"
				SZE->(dbsetorder(1))
				If !SZE->(DbSeek(xFilial("SZE") + Left(_nBob,Len(SZE->ZE_NUMBOB)),.F.))
					aRet[1] := .F.
					aRet[2] := "BOBINA NÃO LOCALIZADA"
				Else
					If SZE->ZE_STATUS # "T"
						aRet[1] := .F.
						aRet[2] := "BOBINA NÃO MAIS ESTÁ DISPONÍVEL"
					ElseIf !SZE->(RecLock("SZE",.F.))
						aRet[1] := .F.
						aRet[2] := "BOBINA EM USO POR OUTRA ROTINA"
					Else
						SZE->ZE_STATUS := "N"  
						SZE->ZE_RESERVA := _cOrigem // Inf ica se a reserva foi feita pela negociação ou retrabalho
						SZE->ZE_CTRLE	:= _cDocto /*LEO ADD*/
						SZE->(MsUnLock())
					EndIf
				EndIf
			EndIf                               
		
			If aRet[1]
				RecLock("SBF",.F.) // Gravo o BF_RESERVA para garantir a quantidade
				SBF->BF_EMPENHO += _nQtd
				MsUnLock()
		
				// Cria registro no SDC
				RecLock("SDC",.T.)
				SDC->DC_FILIAL  := xFilial("SDC")
				SDC->DC_ORIGEM  := _cOrigem
				SDC->DC_PRODUTO := _cPrd
				SDC->DC_LOCAL   := _cArmz
				SDC->DC_LOCALIZ := _cAcond
				SDC->DC_QUANT   := _nQtd
				SDC->DC_PEDIDO  := _cDocto
				SDC->DC_ITEM    := _cItem
				SDC->DC_QTDORIG := _nQtd
				SDC->DC_DTLIB   := dDataBase
				SDC->DC_HRLIB   := Left(Time(),Len(SDC->DC_HRLIB))
				MsUnLock()
				
				DbSelectArea("SB2")
				DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
				If DbSeek(xFilial("SB2")+SDC->DC_PRODUTO+SDC->DC_LOCAL,.F.)
					RecLock("SB2",.F.)
					SB2->B2_RESERVA := SB2->B2_RESERVA + SDC->DC_QUANT
					MsUnLock()
				EndIf
			EndIf
		Else // If !_lEmpenha -> Cancelar Empenho
			// Localizar saldo no SBF
			SBF->(DbSetOrder(1))  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
			SBF->(DbSeek(xFilial("SBF")+_cArmz+_cAcond+_cPrd,.F.))
		
			// Localizar o SDC referente ao empenho do material
			DbSelectArea("SDC")
			DbSetOrder(1) // DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
			If !(DbSeek(xFilial("SDC")+_cPrd+_cArmz+_cOrigem+_cDocto+_cItem,.F.))
				aRet[1] := .F.
				aRet[2] := "EMPENHO NÃO LOCALIZADO"
			ElseIf SBF->(Eof()) .Or. SBF->BF_EMPENHO < _nQtd
				aRet[1] := .F.
				aRet[2] := "SALDO DO EMPENHO INVÁLIDO"
			Else
				DbSelectArea("SB2")
				DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL
				If DbSeek(xFilial("SB2")+SDC->DC_PRODUTO+SDC->DC_LOCAL,.F.)
					RecLock("SB2",.F.)
					SB2->B2_RESERVA := SB2->B2_RESERVA - SDC->DC_QUANT
					MsUnLock()
				EndIf
		        DbSelectArea("SBF")
				RecLock("SBF",.F.) // Gravo o BF_RESERVA para garantir a quantidade
				SBF->BF_EMPENHO -= SDC->DC_QUANT
				MsUnLock()
				DbSelectArea("SDC")
				RecLock("SDC",.F.)
				DbDelete()
				MsUnLock()
		
				If Left(_cAcond,1) == "B"
					SZE->(dbsetorder(1))
					If SZE->(DbSeek(xFilial("SZE") + Left(_nBob,Len(SZE->ZE_NUMBOB)),.F.))
						If SZE->ZE_STATUS == "N"
							SZE->(RecLock("SZE",.F.))
							SZE->ZE_STATUS := "T"
							SZE->ZE_RESERVA := "      "
							SZE->ZE_CTRLE	:= "      " /*LEO ADD*/
							SZE->(MsUnLock())
						EndIf
					EndIf
				EndIf
			EndIf
		
			If _cOrigem == "ZZF" .And. lCancZZF// Estou cancelando um retrabalho
				ZZF->(DbSetOrder(2)) // FILIAL + ID_RETRABALHO
				ZZF->(DbSeek(xFilial("ZZF")+_cDocto,.F.))
				Do While ZZF->ZZF_FILIAL == xFilial("ZZF") .And. ZZF->ZZF_ZZEID == _cDocto .And. ZZF->(!Eof())
					ZZF->(RecLock("ZZF",.F.))
					ZZF->ZZF_STATUS := 'X' // CANCELADO  
					ZZF->(MsUnLock())
					ZZF->(DbSkip())
				EndDo
			
				DbSelectArea("ZZE")
				DbSetOrder(1) // ZZE_FILIAL+ZZE_ID
				DbSeek(xFilial("ZZE") + _cDocto,.F.)
				Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE->ZZE_ID == _cDocto .And. ZZE->(!Eof())
					RecLock("ZZE",.F.)
					ZZE->ZZE_STATUS := '9' // CANCELADO
					MsUnLock()
					ZZE->(DbSkip())
				EndDo
			EndIf
		EndIf
		If _lTrans
			If !aRet[1]
				DisarmTransaction()
			Else
				EndTran()
			EndIf
		EndIf
	endif
Return(aRET)


/*/{Protheus.doc} GraveSZ9
//TODO Grava SZ9.
@author Roberto
@since 23/03/2013
@version undefined
@param _cStatus, , descricao
@type function
/*/
User Function GraveSZ9(_cStatus)
	// Atenção... o SC6 tem que estar posicionado
	Local aArea := GetArea()
	Local _lVolta := .F.
	Local _cStatus
	DbselectArea("SZ9")
	DbSetOrder(1) // Z9_FILIAL+Z9_SEMANA+Z9_PRODUTO+Z9_LOCAL+Z9_LOCALIZ+Z9_PEDIDO+Z9_ITEMPV
	_C6LOCALIZ := Left(SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5)+Space(400),Len(SZ9->Z9_LOCALIZ))
	If DbSeek(xFilial("SZ9")+SC6->C6_SEMANA+SC6->C6_PRODUTO+SC6->C6_LOCAL+_C6LOCALIZ+SC6->C6_NUM+SC6->C6_ITEM,.F.)
		If RecLock("SZ9",.F.)                       
			If _cStatus == "P" // Adicionou uma negociação
				SZ9->Z9_ETIQIMP := SZ9->Z9_ETIQIMP + 1
				SZ9->Z9_EMNEGOC := SZ9->Z9_EMNEGOC + 1
			ElseIf _cStatus == "N" .And. SZ9->Z9_EMNEGOC > 0// Rejeitou a negociação
				SZ9->Z9_ETIQIMP := SZ9->Z9_ETIQIMP - 1
				SZ9->Z9_EMNEGOC := SZ9->Z9_EMNEGOC - 1
			ElseIf _cStatus == "C"  .And. SZ9->Z9_EMNEGOC > 0// Aceitou a negociação
				SZ9->Z9_EMNEGOC := SZ9->Z9_EMNEGOC - 1
			ElseIf _cStatus == "r" // Enviou para retrabalho
				SZ9->Z9_ETIQIMP := SZ9->Z9_ETIQIMP + 1
			EndIf
			If SZ9->Z9_ETIQIMP >= SZ9->Z9_LANCES .And. SZ9->Z9_EMNEGOC == 0
				SZ9->Z9_IMPETIQ := "S"
				_lVolta := .T.
			ElseIf SZ9->Z9_ETIQIMP >= SZ9->Z9_LANCES .And. SZ9->Z9_EMNEGOC > 0
				SZ9->Z9_IMPETIQ := "P" // Suspenso
				_lVolta := .T.
			ElseIf SZ9->Z9_ETIQIMP < SZ9->Z9_LANCES
				SZ9->Z9_IMPETIQ := "N" // Suspenso
				_lVolta := .T.
			EndIf
			MsUnLock()
		EndIf
	EndIf
	RestArea(aArea)
Return(_lVolta)