#include 'topconn.ch'
#include "rwmake.ch"
#include "protheus.ch"
#Define linha chr(13)+chr(10)
#define CRLF Chr(13)+Chr(10)

// Robert Santos
// 09/10/13
// Tela para Gerenciar Negociacao com o Cliente
*
***********************
User Function CREST16()
***********************
*
Local aCores := {}
Local cAlias := "ZZV"
Private cCadastro 	:= "CONTROLE DE NEGOCIACAO"
Private aRotina 	:= {}
// Private cMV_DNEG := strzero(GETMV('MV_DNEG'),4,0) //By Roberto Oliveira 29/05/14
Private nMV_DNEG := GETMV('MV_DNEG') //By Roberto Oliveira 29/05/14

AAdd( aCores, {" !EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'S' .AND. !EMPTY(ZZV_USERA)"	,"BR_VERDE"} ) // Finalizado COM ACEITE
AAdd( aCores, {" !EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'S' .AND. EMPTY(ZZV_USERA) .AND. ZZV_LIBEOK $ 'N '"		,"BR_PINK"} ) // FALTA SER APROVADO PARA ALTERAR O PEDIDO
AAdd( aCores, {" !EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'S' .AND. EMPTY(ZZV_USERA) .AND. ZZV_LIBEOK == 'S'"		,"BR_MARROM"} ) // FALTA ENCERRAR PELO APROVADOR INTERNO COBRECOM
AAdd( aCores, {" !EMPTY(ZZV_DTENCE) .AND. ZZV_ACEITE == 'N' ","BR_BRANCO"} ) // Finalizado REJEITADO

// AAdd( aCores, {" ZZV_DIASEN < cMV_DNEG ","BR_VERMELHO"} ) // VENCIDO //By Roberto Oliveira 29/05/14

AAdd( aCores, {" Val(ZZV_DIASEN) < nMV_DNEG ","BR_VERMELHO"} ) // VENCIDO
//By Roberto Oliveira 29/05/14 .. O Update do campo ZZV_DIASEN não coloca zeros à esquerda e
// por isso não posso comparar com a variável cMV_DNEG se usar a função STRZERO nela.

AAdd( aCores, {" EMPTY(ZZV_DTPRIM) ","BR_AMARELO"} ) // FALTA INICIAR ATENDIMENTO
AAdd( aCores, {" !EMPTY(ZZV_DTPRIM) ","BR_AZUL"} ) // EM NEGOCIACAO


AAdd( aRotina, {"Pesquisar" ,"AxPesqui" ,0,1} )
AAdd( aRotina, {"Visualizar","AxVisual" ,0,2} )
AAdd( aRotina, {"Legenda"   ,"u_REST16l",0,2} )
If cModulo == "FAT"
	AAdd( aRotina, {"Atendentes"   ,"u_CREST17"      ,0,2} )
	AAdd( aRotina, {"Liberar"      ,"u_CREST16b(.F.)",0,2} )
	AAdd( aRotina, {"Rejeitar Alt.","u_CEST162b"     ,0,4} )
EndIf
AAdd( aRotina, {"Relatorio","u_CESTRL11",0,2} )

DbSelectArea("SC5")
DbSetOrder(1)

DbSelectArea("SA1")
DbSetOrder(1)

MsgRun("Aguarde","Aguarde",{||u_Rest16x()}) // atualiza o status dos pendentes (dias em atraso aberto etc)

mBrowse( 6,1,22,75,cAlias,,,,,,aCores)

Return(nil)
*
***************************************
User Function REST16l(cAlias,nReg,nOpc) // Legenda
***************************************
*
Local aLegenda	:= {}

AAdd( aLegenda, {"BR_VERMELHO","Menos de '" + strzero(getmv("MV_DNEG"),4,0) + "' dias para entrega"})
AAdd( aLegenda, {"BR_AMARELO","Falta Iniciar Negociação"})
AAdd( aLegenda, {"BR_AZUL","Em Negociação"})
AAdd( aLegenda, {"BR_PINK","Aprovado Cliente Falta Aprovador"})
AAdd( aLegenda, {"BR_MARROM","Aprovado Falta Alterar Pedido"})
AAdd( aLegenda, {"BR_VERDE","Finalizado Com Aceite"})
AAdd( aLegenda, {"BR_BRANCO","Finalizado Rejeitado"})

BrwLegenda("Controle Negociacao", "Legenda" , aLegenda)

Return(.T.)
*
*****************************************
User Function REST16a(cAlias, nReg, nOpc) // Todos Contatos
*****************************************
*
MsgInfo("Aguarde")
Return(nil)
*
***********************
User Function REst16c()
***********************
*

Local cDescri := ""

If SC5->(DBSEEK(ZZV->(ZZV_FILPV + ZZV_PEDIDO)))
	If SA1->(DBSEEK(XFILIAL("SA1") + SC5->(C5_CLIENTE + C5_LOJACLI )))
		cDESCRI := SA1->A1_NOME
	EndIf
EndIf

Return(cDescri)
*
***********************
User Function Rest16x() // Atualiza os campos de dias para vencer e dias em negociacao dos que estao pendentes
***********************
*
Local cQry

cQry := " UPDATE " + RETSQLNAME("ZZV") + " " + CRLF
cQry += " SET " + CRLF
cQry += "  ZZV_DIASEN = DATEDIFF(DAY, GETDATE(), ISNULL(ZZV_ENTREG,'" + DtoS(dDataBase) +"')) " + CRLF
cQry += " , ZZV_DIASNG = DATEDIFF(DAY, ISNULL(ZZV_DATA,'" + DtoS(dDataBase) +"'), GETDATE()) " + CRLF
cQry += " WHERE D_E_L_E_T_ = ' ' " + CRLF
cQry += " AND ZZV_STATUS not in ('6','7') " + CRLF // fechados
If TcSqlExec(cQry) < 0
	Alert("Erro: " + CRLF + TcSQLError() )
EndIf

Return(.T.)


// Realizar a liberação de itens antes de liberar para alterar o Pedido
*******************************
User Function CREST16b(_lTrans,_nNewPrV) // _lTrans = .T. -> Já Estou dentro de um transaction
*******************************
*
Local cMsg, lLiberOk
Local lNivel1 := __cUserID $ Alltrim(GetMV("MV_XNNEG1"))
Local lNivel2 := __cUserID $ Alltrim(GetMV("MV_XNNEG2"))
Local cDE := GETMV("MV_XLOCALC") // Local DE PRODUTOS EM NEGOCIACAO
Local cPARA := "01" // Local DO RETORNO DA NEGOCIACAO
Local aRet
Local nPermit := GETMV("MV_XLIMIT1")

Default _nNewPrV := 0.00

_lVolta := .T.

If !EMPTY(ZZV->ZZV_DTENCE) .AND. ZZV->ZZV_ACEITE == 'S' .AND. EMPTY(ZZV->ZZV_USERA) .AND. ZZV->ZZV_LIBEOK $ 'N '
	SC6->(DbSetOrder(1))
	If SC6->(dbseek(ZZV->(ZZV_FILPV + ZZV_PEDIDO + ZZV_ITEM)))
		lLiberOk := .F.
		
		// 05/03/14 - Jeferson Gardezani
		// Alterada lógica original da Proativa para consultar diferença de preços
		
		// PARÂMETROS:
		// 1 - Filial do Pedido de Vendas
		// 2 - NºPedido de Venda
		// 3 - Código Produto Original
		// 4 - Código Produto Negociado
		// RETORNO DA FUNÇÃO
		// Array com as informações:
		// 1 -> Percentual de diferença entre o preço unitário Original e Negociado
		// 2 -> Preço de Venda Produto Original
		// 3 -> Preço de Venda Produto Negociado
		// 4 -> Erro (T=Sim/F=Não)
		//aDiff := GtPreco(ZZV->ZZV_FILPV,ZZV->ZZV_PEDIDO,SC6->C6_PRODUTO,ZZV->ZZV_PROALT)
		//Se NÃO retornou erro, então testa os níveis de alçada
		
		If ZZV->ZZV_PROALT == ZZV->ZZV_PRODUT // Se for o mesmo produto, não tem porque pedir autorização
			lLiberOk := .T.
		Else  // O produto é diferente, então avaliar os preços abrindo janela para digitação ou aceitação do novo preço.
			lLiberOk := .T.
		EndIf
		
		If lLiberOk
			
			If lLiberOk
				If !_lTrans
					BeginTran()
				EndIf
				DbSelectArea("ZZV")
				RecLock("ZZV",.F.)
				ZZV->ZZV_LIBEOK := "S"
				ZZV->ZZV_Local := cPara
				ZZV->ZZV_STATUS := "5"
				MsUnLock()
				DbSelectArea("SC6")
				If dbseek(ZZV->ZZV_FILPV+ZZV->ZZV_PEDIDO+ZZV->ZZV_ITEM,.F.) // ATUALIZAR A NEGOCIACAO DO ITEM DO PEDIDO DE VENDA
					RecLock("SC6",.F.)
					SC6->C6_XNEGOC := ZZV->ZZV_STATUS
					MsUnLock()
				EndIf
				
				If ZZV->ZZV_PROALT # ZZV->ZZV_PRODUT .Or. ZZV->ZZV_ACONAL # ZZV->ZZV_ACOND .Or.;
					ZZV->ZZV_METRAL # ZZV->ZZV_METRAG .Or. (ZZV->ZZV_LANCES*ZZV->ZZV_METRAG) # (ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL) # ZZV->ZZV_METRAG
					// Se produto ou acondic. ou lance forem diferentes, ai altera o pedido
					If !u_REst16AtPd(_nNewPrV)
						If !_lTrans
							DisarmTransaction()
						EndIf
						_lVolta := .F.
					EndIf
				EndIf
				If !_lTrans
					EndTran()
				EndIf
			EndIf
		Else
			MsgBox("Negociação não foi liberada. Verifique!","ATENÇÃO","ALERT")
			_lVolta := .F.
		EndIf
	Else
		Alert("Filial/ Pedido/ Item: '" + ZZV->(ZZV_FILPV + ZZV_PEDIDO + ZZV_ITEM) + "' não localizado")
		_lVolta := .F.
	EndIf
Else
	MsgInfo("Este registro não se encontra em bloqueio para Alterar Pedido de vendas!" + CRLF + "Significa que precisa primeiro negociar com o cliente." + CRLF + "Ou o item já sofreu liberação!")
	_lVolta := .F.
EndIf

Return(_lVolta)
*
************************************************************
Static Function GtPreco(_cFilial,_cPedVen,_cProOri,_cProNeg) // consultar diferenca de precos
************************************************************
*
// PARÂMETROS RECEBIDOS:
// _cFilial - Filial do Pedido de Vendas
// _cPedVen - NºPedido de Venda
// _cProOri - Código Produto Original
// _cProNeg - Código Produto Negociado
// RETORNO DA FUNÇÃO
// Array com as informações:
// 1 - nDIf    -> Percentual de diferença entre o preço unitário Original e Negociado
// 2 - nPrcOri -> Preço de Venda Produto Original
// 3 - nPrcNeg -> Preço de Venda Produto Negociado
// 4 - lErro   -> Erro (T=Sim/F=Não)

Local i, cQuery, cMsg
Local aDados	:= {}
Local nPrcOri	:= 0
Local nPrcNeg	:= 0
Local nDif		:= 0
Local aRet		:= {}
Local lErro		:= .F.

//1ª passagem obtem preço do produto original e 2ª passagem obtem preço do produto negociado
For i := 1 to 2
	// Query planejada para usar os índices:
	// DA0: ÍNDICE 1: DA0_FILIAL, DA0_CODTAB, R_E_C_N_O_, D_E_L_E_T_
	// DA1: ÍNDICE 1: DA1_FILIAL, DA1_CODTAB, DA1_CODPRO, DA1_INDLOT, DA1_ITEM, R_E_C_N_O_, D_E_L_E_T_
	// SC5: ÍNDICE 1: C5_FILIAL, C5_NUM, R_E_C_N_O_, D_E_L_E_T_
	cQuery := "SELECT DA0_CODTAB,"													+ linha	//1-NºTabela de Preços
	cQuery += " DA1_CODPRO,"														+ linha	//2-Código do Produto na Tabela
	cQuery += " DA1_PRCVEN"															+ linha	//3-Preço de Venda da Tabela
	cQuery += "FROM DA0010"															+ linha
	cQuery += "INNER JOIN DA1010"													+ linha
	cQuery += " ON DA0_FILIAL = DA1_FILIAL"											+ linha
	cQuery += " AND DA0_CODTAB = DA1_CODTAB"										+ linha
	cQuery += " AND DA0010.D_E_L_E_T_ = DA1010.D_E_L_E_T_"							+ linha
	cQuery += "WHERE DA0_FILIAL = '" + xfilial("DA0") + "'"							+ linha
	cQuery += " AND DA0_CODTAB IN"													+ linha	//Tabela de Preço
	cQuery += " ( SELECT C5_TABELA"													+ linha
	cQuery += "   FROM SC5010"														+ linha
	cQuery += "   WHERE C5_FILIAL = '" + _cFilial + "'"								+ linha
	cQuery += "    AND C5_NUM = '" + _cPedVen + "'"									+ linha	//NºPedido de Venda
	cQuery += "    AND SC5010.D_E_L_E_T_= '' )"										+ linha
	cQuery += " AND DA0_ATIVO IN ('','1')"											+ linha	//Tabelas Ativas
	cQuery += " AND DA0_DATDE <= '" + DtoS(dDatabase) + "'"							+ linha	//Tabela Dentro da Vigência (De)
	cQuery += " AND ( DA0_DATATE = '' OR DA0_DATATE >= '" + DtoS(dDatabase) + "' )"	+ linha	//Tabela Dentro da Vigência (Até)
	cQuery += " AND DA0010.D_E_L_E_T_ = ''"											+ linha
	If i == 1
		cQuery += " AND DA1_CODPRO = '" + _cProOri + "'"							+ linha	//Código Produto Original
	Else
		cQuery += " AND DA1_CODPRO = '" + _cProNeg + "'"							+ linha	//Código Produto Negociado
	EndIf
	cQuery += " AND DA1_ATIVO IN ('','1')"											+ linha	//Item Ativo
	cQuery += " AND ( DA1_DATVIG = '' OR DA1_DATVIG <= '" + DtoS(dDatabase) + "' )"	+ linha	//Dt.Início de Vigência do Item
	aDados := u_qryarr(cQuery)
	If Len(aDados) == 0
		If i == 1
			//cMsg := "Produto Original: [" + _cProOri + "] não cadastrado na Tabela do Pedido: [" + _cPedVen + "]. Verifique!" + linha
			cMsg := "Produto: [" + _cProOri + "] não cadastrado na Tabela de Preços do Pedido: [" + _cPedVen + "]. Verifique!" + linha
		Else
			//cMsg := "Produto Negociado: [" + _cProNeg + "] não cadastrado na Tabela do Pedido : [" + _cPedVen + "]. Verifique!" + linha
			cMsg := "Produto: [" + _cProNeg + "] não cadastrado na Tabela de Preços do Pedido : [" + _cPedVen + "]. Verifique!" + linha
		EndIf
		MsgBox(cMsg,"ATENÇÃO " + iif(i==1,"(Produto Original)","(Produto Negociado)"),"ALERT")
		lErro := .T.
		Exit
	ElseIf Len(aDados) > 1
		cMsg := "Erro na quantidade de informações retornadas na pesquisa à Tabela de Preços." + linha
		If i == 1
			cMsg += "Produto Original: Registros esperados = 001 / Retornados = " + strzero(Len(aDados),3) + linha
		Else
			cMsg += "Produto Negociado: Registros esperados = 001 / Retornados = " + strzero(Len(aDados),3) + linha
		EndIf
		cMsg += "Comunique o Departamento de TI!" + linha
		MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
		lErro := .T.
		Exit
	Else
		If i == 1
			nPrcOri := aDados[1][3]	//Preço de Venda Produto Original
			//Se Produto Negociado == Produto Original, inicializa variável e sai do FOR ... NEXT
			If _cProOri == _cProNeg
				nPrcNeg := nPrcOri
				Exit
			EndIf
		Else
			nPrcNeg := aDados[1][3]	//Preço de Venda Produto Negociado
		EndIf
	EndIf
Next

If !lErro
	//Calcula percentual de diferença entre os preços
	If nPrcOri <= 0 .or. nPrcNeg <= 0
		cMsg := "Preços de tabela incorretos." + linha
		cMsg += "Preço Produto Original : " + transform(nPrcOri,"@E 999,999,999.9999") + linha
		cMsg += "Preço Produto Negociado: " + transform(nPrcNeg,"@E 999,999,999.9999") + linha
		cMsg += "Comunique o Departamento de TI!" + linha
		MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
		lErro := .T.
	Else
		//Calcula diferença entre os preços
		nDIf := nPrcOri - nPrcNeg
		//Se diferença negativa, converte em positiva (o que deve ser aprovado é a variação, independente se positiva ou negativa)
		If nDIf < 0
			nDIf := nDIf * -1
		EndIf
		//Calcula percentual de variação em relação ao Preço de Venda do Produto Original
		nDIf := ( nDIf / nPrcOri ) * 100
	EndIf
EndIf

//Carrega array para retorno
AADD(aRet,{nDif,nPrcOri,nPrcNeg,lErro})
Return(aRet)

*
**************************
User Function REst16AtPd(_nNewPrV)
**************************
*
// Fazer a alteração no pedido de vendas conforme o ZZV aprovado
// Registro da tabela ZZV deve estar posicionado

// Posicionar todas as tabelas
// Estornar a liberação do ítem do pedido de vendas
// Apurar a diferença do total do pedido de vendas
// Diminuir a quantidade de lances do item original
// Se a quantidade diminuida for tudo, deletar o item
// Criar novo SC6 para o produto/quantidade a ser incluida
// Efetuar a liberação no SC9
// Se a diferença for a menor, alterar o SA1 (A1_RISCO == A) para liberar crédito direto
Local cPedInd 	:= ""
local aRetEmp		:= {}
Default _nNewPrV 	:= 0

_lItemAtu := .F. // Utiliza o item atual/original ? Inicializo com Não -> Criar novo item
DbSelectArea("SC6")
DbSetOrder(1)	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
DbSeek(xFilial("SC6") + ZZV->ZZV_PEDIDO + ZZV->ZZV_ITEM,.F.)
cPedInd := IIf(SC6->C6_ZZPVORI # "", SC6->C6_ZZPVORI, "")
If _nNewPrV == 0
	_nNewPrV := SC6->C6_PRCVEN
EndIf
If SC6->C6_QTDENT == 0 						// Nada foi faturado
	If SC6->C6_LANCES == ZZV->ZZV_LANCES 	// Foram negociados Todos os Lances ?
		_lItemAtu := .T. 					// Substitui o item atual pelo negociado
	EndIf
Else 										// Alguma quantidade foi faturada
	// Se a quantidade negociada ainda não foi faturada
	_nQtdNeg := (ZZV->ZZV_LANCES*ZZV->ZZV_METRAG)  // Quantidade negociada em metros
	If _nQtdNeg > (SC6->C6_QTDVEN-SC6->C6_QTDENT)  // Quantidade negociada é MAIOR que a quantidade a entregaar.
		MsgBox("Negociação não foi liberada - Item já Faturado. Verifique!","ATENÇÃO","ALERT")
		Return(.F.)
	EndIf
EndIf

_aLibSDC := {} // {Produto,Acondic,Quant}
DbSelectArea("SDC")
DbSetOrder(5) // DC_FILIAL+DC_PEDIDO+DC_ITEM+DC_LOCALIZ
DbSeek(xFilial("SDC")+ZZV->ZZV_PEDIDO + ZZV->ZZV_ITEM,.F.)
Do While SDC->DC_FILIAL == xFilial("SDC") .And. SDC->DC_PEDIDO == ZZV->ZZV_PEDIDO .And. ;
	SDC->DC_ITEM == ZZV->ZZV_ITEM .And. SDC->(!Eof())
	If SDC->DC_ORIGEM == "SC6"
		nPos :=  aScan(_aLibSDC,{|x| x[1]==SDC->DC_PRODUTO .And. x[2]==SDC->DC_LOCALIZ})
		If nPos == 0
			Aadd(_aLibSDC,{SDC->DC_PRODUTO,SDC->DC_LOCALIZ,SDC->DC_QUANT})
		Else
			_aLibSDC[nPos,3] += SDC->DC_QUANT
		EndIf
	EndIf
	SDC->(DbSkip())
EndDo

// Verifica quanto entra e quanto sai em quantidade e valor.
_nQtdSai := (ZZV->ZZV_LANCES*ZZV->ZZV_METRAG) // Quantidade que sai do pedido
//_nVlrSai := Round((ZZV->ZZV_LANCES*ZZV->ZZV_METRAG) * SC6->C6_PRCVEN,2) // Quanto R$ sai   do pedido
_nQtdEnt := (ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL) // Quantidade que entra no pedido
_nVlrEnt := Round((ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL) * _nNewPrV,2) // Quanto R$ entra no pedido

DbSelectArea("SC5")
DbSetOrder(1) // C5_FILIAL+C5_NUM
DbSeek(xFilial("SC5") + ZZV->ZZV_PEDIDO,.F.)

DbSelectArea("SA1")
DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.F.)

_nVlrSai := SC6->C6_VALOR // Quanto R$ sai   do pedido - Digo que é tudo

lRet := .T.
_lMyAuto := .f.
If _lMyAuto
	aCabec   := {}
	aItens   := {}
	aLinha1  := {}
	aLinha2  := {}
	aadd(aCabec,{"C5_NUM"    ,SC5->C5_NUM    ,Nil})
	aadd(aCabec,{"C5_TIPO"   ,SC5->C5_TIPO   ,Nil})
	aadd(aCabec,{"C5_CLIENTE",SC5->C5_CLIENTE,Nil})
	aadd(aCabec,{"C5_LOJACLI",SC5->C5_LOJACLI,Nil})
	
	If _lItemAtu	// Substitui o item atual pelo negociado
		aadd(aLinha1,{"C6_NUM"    ,SC6->C6_NUM                                       ,Nil})
		aadd(aLinha1,{"C6_ITEM"   ,SC6->C6_ITEM                                      ,Nil})
		aadd(aLinha1,{"C6_PRODUTO",ZZV->ZZV_PROALT                                   ,Nil})
		aadd(aLinha1,{"C6_QTDVEN" ,(ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL)                 ,Nil})
		aadd(aLinha1,{"C6_PRCVEN" ,SC6->C6_PRCVEN                                    ,Nil})
		aadd(aLinha1,{"C6_PRUNIT" ,SC6->C6_PRUNIT                                    ,Nil})
		aadd(aLinha1,{"C6_QTDLIB" ,(ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL)                 ,Nil})
		aadd(aLinha1,{"C6_VALOR"  ,Round(((ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL)*SC6->C6_PRCVEN),2),Nil})
		aadd(aLinha1,{"C6_TES"    ,SC6->C6_TES                                       ,Nil})
		aadd(aLinha1,{"C6_ACONDIC",ZZV->ZZV_ACONAL                                   ,Nil})
		aadd(aLinha1,{"C6_LANCES" ,ZZV->ZZV_LANCEA                                   ,Nil})
		aadd(aLinha1,{"C6_METRAGE",ZZV->ZZV_METRAL                                   ,Nil})
		aadd(aLinha1,{"C6_XNEGOC" ,"7"                                               ,Nil})// ACEITE ALTERADO
		aadd(aLinha1,{"C6_SEMANA" ," "                                               ,Nil})
		_cNewItem := SC6->C6_ITEM
	Else			// Deixo o saldo no mesmo item e cria novo item negociado
		_cNewItem := ZZV->ZZV_ITEM
		DbSelectArea("SC6")
		DbSetOrder(1)	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		Do While DbSeek(xFilial("SC6") + ZZV->ZZV_PEDIDO + _cNewItem,.F.)
			_cNewItem := Soma1(_cNewItem)
		EndDo
		
		// Volta ao item em questão
		DbSeek(xFilial("SC6") + ZZV->ZZV_PEDIDO + ZZV->ZZV_ITEM,.F.)
		
		_nQtLcFim := (SC6->C6_LANCES - ZZV->ZZV_LANCES)
		aadd(aLinha1,{"C6_NUM"    ,SC6->C6_NUM                ,Nil})
		aadd(aLinha1,{"C6_ITEM"   ,SC6->C6_ITEM               ,Nil})
		aadd(aLinha1,{"C6_PRODUTO",SC6->C6_PRODUTO            ,Nil})
		aadd(aLinha1,{"C6_QTDVEN" ,(_nQtLcFim*SC6->C6_METRAGE),Nil})
		aadd(aLinha1,{"C6_PRCVEN" ,SC6->C6_PRCVEN             ,Nil})
		aadd(aLinha1,{"C6_PRUNIT" ,SC6->C6_PRUNIT             ,Nil})
		aadd(aLinha1,{"C6_QTDLIB" ,;
		Max((_nQtLcFim*SC6->C6_METRAGE)-SC6->C6_QTDENT,0) ,Nil})
		aadd(aLinha1,{"C6_VALOR"  ,;
		Round(((_nQtLcFim*SC6->C6_METRAGE)*SC6->C6_PRCVEN),2),Nil})
		aadd(aLinha1,{"C6_TES"    ,SC6->C6_TES                ,Nil})
		aadd(aLinha1,{"C6_ACONDIC",SC6->C6_ACONDIC            ,Nil})
		aadd(aLinha1,{"C6_LANCES" ,_nQtLcFim                  ,Nil})
		aadd(aLinha1,{"C6_METRAGE",SC6->C6_METRAGE            ,Nil})
		aadd(aLinha1,{"C6_COMIS1" ,SC6->C6_COMIS1             ,Nil})
		aadd(aLinha1,{"C6_XNEGOC" ," "                        ,Nil})// ACEITE ALTERADO
		aadd(aLinha1,{"C6_SEMANA" ," "                        ,Nil})
		
		// Incluir novo item
		
		aadd(aLinha2,{"C6_NUM"    ,SC6->C6_NUM                                       ,Nil})
		aadd(aLinha2,{"C6_ITEM"   ,_cNewItem                                         ,Nil})
		aadd(aLinha2,{"C6_PRODUTO",ZZV->ZZV_PROALT                                   ,Nil})
		aadd(aLinha2,{"C6_QTDVEN" ,(ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL)                 ,Nil})
		aadd(aLinha2,{"C6_PRCVEN" ,SC6->C6_PRCVEN                                    ,Nil})
		aadd(aLinha2,{"C6_PRUNIT" ,SC6->C6_PRUNIT                                    ,Nil})
		aadd(aLinha2,{"C6_QTDLIB" ,(ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL)                 ,Nil})
		aadd(aLinha2,{"C6_VALOR"  ,Round(((ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL)*SC6->C6_PRCVEN),2),Nil})
		aadd(aLinha2,{"C6_TES"    ,SC6->C6_TES                                       ,Nil})
		aadd(aLinha2,{"C6_ACONDIC",ZZV->ZZV_ACONAL                                   ,Nil})
		aadd(aLinha2,{"C6_LANCES" ,ZZV->ZZV_LANCEA                                   ,Nil})
		aadd(aLinha2,{"C6_METRAGE",ZZV->ZZV_METRAL                                   ,Nil})
		If SC6->C6_PRODUTO == ZZV->ZZV_PROALT
			aadd(aLinha1,{"C6_COMIS1" ,SC6->C6_COMIS1             ,Nil})
		EndIf
		aadd(aLinha2,{"C6_XNEGOC" ,"7"                                               ,Nil})// ACEITE ALTERADO
		aadd(aLinha2,{"C6_SEMANA" ," "                                               ,Nil})
	EndIf
	_nQSai := Round((ZZV->ZZV_LANCES*ZZV->ZZV_METRAG) * SC6->C6_PRCVEN,2) // Quanto R$ sai   do pedido
	_nQEnt := Round((ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL) * SC6->C6_PRCVEN,2) // Quanto R$ entra no pedido
	If !Empty(aLinha1)
		aadd(aItens,aLinha1)
		aLinha1 := {}
	EndIf
	If !Empty(aLinha2)
		aadd(aItens,aLinha2)
		aLinha2 := {}
	EndIf
	
	// Chama MATA410
	lMsErroAuto := .F.
	MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItens,4)
	If lMsErroAuto
		lRet := .F.
		MostraErro()
		Return(.F.)
	Endif
	
	//Caso o pedido seja aceito com a negociação
	RecLock("SC5",.F.)
	SC5->C5_XNEGOC := "S"
	MsUnLock()
	
	If Alltrim(cPedInd) <> "" .and. xFilial("SC5") == "01"
		U_REst16PdInd(_nNewPrV,cPedInd)
	EndIf
Else
	// Efetua estorno das liberações do item do pedido
	_lIsLiber := .F. // Crédito não está liberado
	DbSelectArea("SC9")
	DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	DbSeek(xFilial("SC9")+ZZV->ZZV_PEDIDO+ZZV->ZZV_ITEM,.F.)
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == ZZV->ZZV_PEDIDO .And.;
		SC9->C9_ITEM == ZZV->ZZV_ITEM .And. SC9->(!Eof())
		
		If SC9->C9_BLCRED # "10" .And. SC9->C9_BLEST # "10"
			If Empty(SC9->C9_BLCRED)
				_lIsLiber := .T. // Crédito está liberado
			EndIf
			SC9->(a460Estorna())
			DbSeek(xFilial("SC9")+ZZV->ZZV_PEDIDO+ZZV->ZZV_ITEM,.F.)
		Else
			SC9->(DbSkip())
		EndIf
	EndDo
	
	DbSelectArea("SC6")
	DbSetOrder(1)	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	DbSeek(xFilial("SC6") + ZZV->ZZV_PEDIDO + ZZV->ZZV_ITEM,.F.)
	// Transfere todos os dados do SC6 para a memória
	//RegToMemory("SC6",.F.)
	
	_cNewItem := ZZV->ZZV_ITEM
	If !_lItemAtu // Não utiliza o item atual/original, criar novo item
		DbSelectArea("SC6")
		DbSetOrder(1)	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		Do While DbSeek(xFilial("SC6") + ZZV->ZZV_PEDIDO + _cNewItem,.F.)
			_cNewItem := Soma1(_cNewItem)
		EndDo
	EndIf
	
	_aALib := {} //Itens para rodar a libdofat
	
	DbSelectArea("SC6")
	DbSetOrder(1)	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	DbSeek(xFilial("SC6") + ZZV->ZZV_PEDIDO + ZZV->ZZV_ITEM,.F.)
	RecLock("SC6",.F.)
	If _lItemAtu // Utiliza o item atual/original
		SC6->C6_QTDVEN  := (ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL)
		SC6->C6_VALOR   := Round(((ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL)*SC6->C6_PRCVEN),2)
		SC6->C6_ACONDIC := ZZV->ZZV_ACONAL
		SC6->C6_LANCES  := ZZV->ZZV_LANCEA
		SC6->C6_METRAGE := ZZV->ZZV_METRAL
		SC6->C6_XNEGOC  := "7"		// ACEITE ALTERADO
		SC6->C6_SEMANA  := " "
		SC6->C6_PRCVEN  := _nNewPrV
		SC6->C6_PRCBAS  := _nNewPrV
		//SC6->C6_VALOR   := (SC6->C6_QTDVEN*SC6->C6_PRCVEN)
		If ZZV->ZZV_PROALT # ZZV->ZZV_PRODUT
			SC6->C6_PRODUTO := ZZV->ZZV_PROALT
			SC6->C6_DESCRI  := Posicione("SB1",1,xFilial("SB1")+ZZV->ZZV_PROALT,"B1_DESC")
			SC6->C6_PRUNIT  := _nNewPrV
			//SC6->C6_LUCROBR
		EndIf
		MsUnLock()
		
		If SC6->C6_QTDVEN > (SC6->C6_QTDENT+SC6->C6_QTDEMP)
			AAdd(_aALib,{SC6->C6_NUM,SC6->C6_ITEM,(SC6->C6_QTDVEN - SC6->C6_QTDENT - SC6->C6_QTDEMP)})
		EndIf
		_nVlrEnt := SC6->C6_VALOR // Quanto R$ entra no pedido
	Else //!_lItemAtu // Não utiliza o item atual/original, criar novo item
		
		SC6->C6_LANCES  := (SC6->C6_LANCES-ZZV->ZZV_LANCES)
		SC6->C6_QTDVEN  := (SC6->C6_LANCES*SC6->C6_METRAGE)
		SC6->C6_VALOR   := (SC6->C6_QTDVEN*SC6->C6_PRCVEN)
		SC6->C6_XNEGOC  := " "
		SC6->C6_SEMANA  := " "
		SC6->C6_XQTDNEG := Max((SC6->C6_XQTDNEG-ZZV->ZZV_LANCES),0)
		MsUnLock()
		
		If SC6->C6_QTDVEN > (SC6->C6_QTDENT+SC6->C6_QTDEMP)
			AAdd(_aALib,{SC6->C6_NUM,SC6->C6_ITEM,(SC6->C6_QTDVEN - SC6->C6_QTDENT - SC6->C6_QTDEMP)})
		EndIf
		_nVlrEnt := SC6->C6_VALOR // Quanto R$ entra no pedido
		
		// Forma 1 de fazer
		RegToMemory("SC6",.F.)
		_nQtCpo := SC6->(FCount())
		RecLock("SC6",.T.)
		For nCntFor := 1 To _nQtCpo
			If AllTrim(FieldName(nCntFor)) == "C6_ITEM"
				FieldPut(nCntFor,_cNewItem)
			ElseIf AllTrim(FieldName(nCntFor)) == "C6_PRODUTO"
				FieldPut(nCntFor,ZZV->ZZV_PROALT)
			Else
				FieldPut(nCntFor,M->&(FieldName(nCntFor)))
			EndIf
		Next
		SC6->C6_DESCRI  := Posicione("SB1",1,xFilial("SB1")+ZZV->ZZV_PROALT,"B1_DESC")
		SC6->C6_ACONDIC := ZZV->ZZV_ACONAL
		SC6->C6_LANCES  := ZZV->ZZV_LANCEA
		SC6->C6_METRAGE := ZZV->ZZV_METRAL
		SC6->C6_QTDVEN  := SC6->C6_LANCES * SC6->C6_METRAGE
		SC6->C6_PRCVEN  := _nNewPrV
		SC6->C6_PRCBAS  := _nNewPrV
		SC6->C6_VALOR   := (SC6->C6_QTDVEN*SC6->C6_PRCVEN)
		If ZZV->ZZV_PROALT # ZZV->ZZV_PRODUT
			SC6->C6_DESCRI  := Posicione("SB1",1,xFilial("SB1")+ZZV->ZZV_PROALT,"B1_DESC")
			SC6->C6_PRUNIT  := _nNewPrV
		EndIf
		SC6->C6_XNEGOC  := "7"		// ACEITE ALTERADO
		SC6->C6_SEMANA  := " "
		SC6->C6_QTDENT  := 0
		SC6->C6_QTDENT2 := 0
		SC6->C6_DATFAT  := Ctod("")
		SC6->C6_NOTA    := " "
		SC6->C6_SERIE   := " "
		MsUnLock()
		
		AAdd(_aALib,{SC6->C6_NUM,SC6->C6_ITEM,(SC6->C6_QTDVEN - SC6->C6_QTDENT - SC6->C6_QTDEMP)})
		_nVlrEnt += SC6->C6_VALOR // Quanto R$ entra no pedido
	EndIf
	
	DbSelectArea("SA1")
	DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
	DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.F.)
	_A1_RISCO := SA1->A1_RISCO
	
	For _naLib := 1 to Len(_aALib)
		If _nVlrSai >= _nVlrEnt .Or. ;
			(_aALib[_naLib,2] == ZZV->ZZV_ITEM .And. ZZV->ZZV_ITEM # _cNewItem .And. _lIsLiber)
			// O pedido ficou com valor menor ou igual ao original OU
			// Estou liberando o mesmo item do ZZV E já estava liberado e
			// a nova liberação é de um item diferente
			If SA1->A1_RISCO # "A"
				DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
				DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.F.)
				
				RecLock("SA1",.F.)
				SA1->A1_RISCO := "A"  // Troco o risco para A para passar direto
				MsUnLock()
			EndIf
		ElseIf SA1->A1_RISCO # _A1_RISCO
			DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
			DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.F.)
			RecLock("SA1",.F.)
			SA1->A1_RISCO := _A1_RISCO
			MsUnLock()
		EndIf
		
		DbSelectArea("SC6")
		DbSetOrder(1)	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		DbSeek(xFilial("SC6") + _aALib[_naLib,1] + _aALib[_naLib,2],.F.)
		If _aALib[_naLib,3] > 0
			MaLibDoFat(SC6->(RecNo()),_aALib[_naLib,3],.T.     ,.F.     ,.T.    ,.T.   ,.F.    ,.F.,,)
			//MaLibDoFat(nRegSC6       ,nQtdaLib            ,lCredito,lEstoque,lAvCred,lAvEst,lLibPar,lTrfLocal,aEmpenho,bBlock,aEmpPronto,lTrocaLot,lOkExpedicao,nVlrCred,nQtdalib2)
			//±±³Parametros³ExpN1: Registro do SC6                                      ³±±
			//±±³          ³ExpN2: Quantidade a Liberar                                 ³±±
			//±±³          ³ExpL3: Bloqueio de Credito                                  ³±±
			//±±³          ³ExpL4: Bloqueio de Estoque                                  ³±±
			//±±³          ³ExpL5: Avaliacao de Credito                                 ³±±
			//±±³          ³ExpL6: Avaliacao de Estoque                                 ³±±
			//±±³          ³ExpL7: Permite Liberacao Parcial                            ³±±
			//±±³          ³ExpL8: Tranfere Locais automaticamente                      ³±±
			//±±³          ³ExpA9: Empenhos ( Caso seja informado nao efetua a gravacao ³±±
			//±±³          ³       apenas avalia ).                                     ³±±
			//±±³          ³ExpbA: CodBlock a ser avaliado na gravacao do SC9           ³±±
			//±±³          ³ExpAB: Array com Empenhos previamente escolhidos            ³±±
			//±±³          ³       (impede selecao dos empenhos pelas rotinas)          ³±±
			//±±³          ³ExpLC: Indica se apenas esta trocando lotes do SC9          ³±±
			//±±³          ³ExpND: Valor a ser adicionado ao limite de credito          ³±±
			//±±³          ³ExpNE: Quantidade a Liberar - segunda UM                    ³±±
			//SC9->C9_TES := SC6->C6_TESORI
			//SC9->(MsUnLock())
		EndIf
	Next
	
	If Empty(SC5->C5_LIBEROK)
		_cMyLib := "S"
		DbSelectArea("SC6")
		DbSetOrder(1)
		DbSeek(xFilial("SC6")+SC5->C5_NUM,.F.)
		Do While SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())
			If SC6->C6_QTDVEN > (SC6->C6_QTDEMP+SC6->C6_QTDENT) .And. SC6->C6_BLQ # 'R '
				_cMyLib := " "
			EndIf
			SC6->(DbSkip())
		EndDo
		If SC5->C5_LIBEROK # _cMyLib
			RecLock("SC5",.F.)
			SC5->C5_LIBEROK := _cMyLib
			MsUnLock()
		EndIf
	EndIf
	
	//Caso o pedido seja aceito com a negociação
	RecLock("SC5",.F.)
	SC5->C5_XNEGOC := "S"
	MsUnLock()
	
	If Alltrim(cPedInd) <> "" .and. xFilial("SC6") == "01"
		U_REst16PdInd(_nNewPrV,cPedInd)
	EndIf
EndIf

DbSelectArea("SA1")
DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.F.)
If SA1->A1_RISCO # _A1_RISCO .Or. !_lMyAuto
	RecLock("SA1",.F.)
	SA1->A1_RISCO := _A1_RISCO
	If !_lMyAuto .And. lRet
		SA1->A1_SALPED := SA1->A1_SALPED - _nVlrSai + _nVlrEnt
	EndIf
	MsUnLock()
EndIf

If !lRet
	Return(.F.)
EndIf
// Não permitir possível nova negociação nesse item, pois já é um item negociado.
// Alterar status para pedido alterado
ZZV->(RecLock("ZZV",.F.))
ZZV->ZZV_STATUS	:= "7" // PEDIDO ALTERADO
ZZV->ZZV_ACEITE	:= "S"
ZZV->ZZV_USERA	:= UPPER(alltrim(cUserName))
ZZV->ZZV_ITEALT := ZZV->ZZV_ITEM
ZZV->ZZV_ITEM   := _cNewItem
ZZV->(MsUnLock())

// Recalcular o LB dos itens e do pedido
DbSelectArea("SC5")
DbSetOrder(1) // C5_FILIAL+C5_NUM
DbSeek(xFilial("SC5") + ZZV->ZZV_PEDIDO,.F.)

_nTPrcVen := 0.00
_nTCustd  := 0.00
_nTTPed   := 0.00

DbSelectArea("SC6")
DbSetOrder(1)	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
DbSeek(xFilial("SC6") + SC5->C5_NUM,.F.)

Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->(!Eof()) .And. SC6->C6_NUM == SC5->C5_NUM
	If SC5->C5_TIPO # "N"
		SC6->(DbSkip())
		Loop
	EndIf
	SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.))
	If SB1->B1_TIPO # "PA"
		SC6->(DbSkip())
		Loop
	EndIf
	If SC6->C6_QTDENT == 0.00 .And. SC6->C6_BLQ <> 'R '
		If xFilial("SC6") == "02" // 3 lagoas
			_nLUCROBR := If(SB1->B1_CUSTD3L==0,0,(((SC6->C6_PRCVEN*100)/SB1->B1_CUSTD3L)-100))
		Else
			_nLUCROBR := If(SB1->B1_CUSTD==0,0,(((SC6->C6_PRCVEN*100)/SB1->B1_CUSTD)-100))
		EndIf
	EndIf
	_nTTPed   += SC6->C6_VALOR
	_nTPrcVen += SC6->C6_PRCVEN
	If xFilial("SC6") == "02" // 3 lagoas
		_nTCustd  += SB1->B1_CUSTD3L
	Else
		_nTCustd  += SB1->B1_CUSTD
	EndIf
	SC6->(DbSkip())
EndDo

_nLUCROBR := If(_nTCustd==0,0,((_nTPrcVen * 100) / _nTCustd) - 100)
If SC5->C5_LUCROBR # _nLUCROBR .Or. SC5->C5_TOTAL # _nTTPed
	RecLock("SC5",.F.)
	SC5->C5_TOTAL    := _nTTPed
	SC5->C5_LUCROBR  := _nLUCROBR
	SC5->(MsUnLock())
EndIf

DbSelectArea("SC6")
DbSetOrder(1)	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
If DbSeek(xFilial("SC6") + ZZV->ZZV_PEDIDO + _cNewItem,.F.)
	RecLock("SC6",.F.)
	SC6->C6_SEMANA  := "RESERVA"
	SC6->C6_QTDRES  := SC6->C6_QTDVEN
	MsUnLock()
EndIf

If ZZV->ZZV_ACONAL == "B"
	
	SZE->(DbSetOrder(1)) // ZE_FILIAL+ZE_NUMBOB
	SZE->(DbSeek(xFilial("SZE")+ZZV->ZZV_NUMBOB,.F.))
	
	// Fazer reserva no SZR para a expedição fazer a troca de etiqueta pela rotina User Function CDEST22(ACReser)
	DbSelectArea("SZR")
	RecLock("SZR",.T.)
	SZR->ZR_FILIAL  := xFilial("SZR")
	SZR->ZR_NUMBOB  := ZZV->ZZV_NUMBOB
	SZR->ZR_TAMBOB  := SZE->ZE_QUANT
	SZR->ZR_DATA    := dDataBase
	SZR->ZR_PRODUTO := SC6->C6_PRODUTO
	SZR->ZR_DESCR   := SC6->C6_DESCRI
	SZR->ZR_PEDIDO  := SC6->C6_NUM
	SZR->ZR_ITEMPV  := SC6->C6_ITEM
	SZR->ZR_CODCLI  := SC6->C6_CLI
	SZR->ZR_LOJA    := SC6->C6_LOJA
	SZR->ZR_NOMCLI  := Posicione("SA1",1,xFilial("SA1")+SC6->C6_CLI+SC6->C6_LOJA,"A1_NOME")
	SZR->ZR_QTDPV   := SC6->C6_QTDVEN
	SZR->ZR_ACONDIC := "B"
	SZR->ZR_LANCES  := 1
	SZR->ZR_METRAGE := SZE->ZE_QUANT
	SZR->ZR_RESP    := cUserName
	SZR->ZR_OBS     := "Negoc. " + ZZV->ZZV_ID
	SZR->(MsUnLock())
	
	// Mata a reserva no SDC
	aRetEmp := U_EmpSDC(.F.,"ZZV",SC6->C6_PRODUTO,"01","B"+StrZero(SZE->ZE_QUANT,5),SZE->ZE_QUANT,ZZV->ZZV_ID,ZZV->ZZV_NUMBOB,.F.)
	if !aRetEmp[1]
		return(.F.)
	endif
	
	SZE->(DbSetOrder(1)) // ZE_FILIAL+ZE_NUMBOB
	If SZE->(DbSeek(xFilial("SZE")+ZZV->ZZV_NUMBOB,.F.))
		RecLock("SZE",.F.)
		SZE->ZE_STATUS := "N" // Reserva confirmada
		SZE->ZE_CLIRES := SC6->C6_CLI
		SZE->ZE_LJRES  := SC6->C6_LOJA
		MsUnLock()
	EndIf
Else
	// Alterar a reserva no SDC do ZZV para SDC
	DbSelectArea("SDC")
	DbSetOrder(1) // DC_FILIAL+DC_PRODUTO+DC_LOCAL+DC_ORIGEM+DC_PEDIDO+DC_ITEM+DC_SEQ+DC_LOTECTL+DC_NUMLOTE+DC_LOCALIZ+DC_NUMSERI
	If DbSeek(xFilial("SDC")+SC6->C6_PRODUTO+SC6->C6_LOCAL+"ZZV"+ZZV->ZZV_ID,.F.)
		RecLock("SDC",.F.)
		SDC->DC_ORIGEM  := "SDC"
		SDC->DC_PEDIDO  := SC6->C6_NUM
		SDC->DC_ITEM    := SC6->C6_ITEM
		SDC->DC_DTLIB   := dDataBase
		SDC->DC_HRLIB   := Left(Time(),Len(SDC->DC_HRLIB))
		MsUnLock()
	EndIf
EndIf

// Tenho algo a empenhar e tenho C9 liberado credito e bloqueado estoque?
If Len(_aLibSDC) > 0 // Tenho coisas que foram estornadas
	
	DbSelectArea("SC6")
	DbSetOrder(1)	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	DbSeek(xFilial("SC6") + ZZV->ZZV_PEDIDO + ZZV->ZZV_ITEM,.F.)
	
	DbSelectArea("SC9")
	DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	DbSeek(xFilial("SC9")+ZZV->ZZV_PEDIDO+ZZV->ZZV_ITEM,.F.)
	
	Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == ZZV->ZZV_PEDIDO .And. ;
		SC9->C9_ITEM == ZZV->ZZV_ITEM .And. SC9->(!Eof())
		_lRepos := .F.
		If (SC9->C9_BLCRED+SC9->C9_BLEST) == "  02"
			
			// Definição do array _aLibSDC
			// _aLibSDC := {Produto,Acondic,Quant}
			// 	Aadd(_aLibSDC,{SDC->DC_PRODUTO,SDC->DC_LOCALIZ,SDC->DC_QUANT})
			For _nLib := 1 to Len(_aLibSDC)
				_nTmLance := Val(Right(AllTrim(_aLibSDC[_nLib,2]),5))
				If _aLibSDC[_nLib,3] < _nTmLance
					Loop
				EndIf
				
				_nQtdLib  := Min(_aLibSDC[_nLib,3],	SC9->C9_QTDLIB)
				_nQtdLib := (Int(_nQtdLib / _nTmLance)) * _nTmLance
				If _nQtdLib <= 0
					Loop
				EndIf
				_aLibSDC[_nLib,3] -= _nQtdLib
				
				// Atenção: O 11ro parâmetro deve ser diferente em cada chamada da função CDLibEst para poder
				// identificar a origem da liberação. Esta informação será gravada no campo DC_TPLIB.
				// Incluir este comentário em todas as chamadas da função quando for LIBERAÇÃO.
				u_CDLibEst("L",SC9->C9_PRODUTO,_nQtdLib,SC9->C9_LOCAL,_aLibSDC[_nLib,2],;
				SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN,,,"N")
				_lRepos := .T.
				Exit
			Next
		EndIf
		If _lRepos
			_lRepos := .F.
			DbSelectArea("SC9")
			DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
			DbSeek(xFilial("SC9")+ZZV->ZZV_PEDIDO+ZZV->ZZV_ITEM,.F.)
		Else
			SC9->(DbSkip())
		EndIf
	EndDo
EndIf
Return(.T.)

*
**************************
User Function REst16PdInd(_nNewPrV,cPedInd)
**************************
*
// Fazer a alteração no pedido de vendas conforme o ZZV aprovado
// Registro da tabela ZZV deve estar posicionado

// Posicionar todas as tabelas
// Estornar a liberação do ítem do pedido de vendas
// Apurar a diferença do total do pedido de vendas
// Diminuir a quantidade de lances do item original
// Se a quantidade diminuida for tudo, deletar o item
// Criar novo SC6 para o produto/quantidade a ser incluida
// Efetuar a liberação no SC9
// Se a diferença for a menor, alterar o SA1 (A1_RISCO == A) para liberar crédito direto
Default _nNewPrV := 0
_lItemAtu := .F. // Utiliza o item atual/original ? Inicializo com Não -> Criar novo item
DbSelectArea("SC6")
DbSetOrder(1)	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
DbSeek("02" + cPedInd,.F.)
If _nNewPrV == 0
	_nNewPrV := SC6->C6_PRCVEN
EndIf

If SC6->C6_QTDENT == 0 						// Nada foi faturado
	If SC6->C6_LANCES == ZZV->ZZV_LANCES 	// Foram negociados Todos os Lances ?
		_lItemAtu := .T. 					// Substitui o item atual pelo negociado
	EndIf
EndIf 										// Alguma quantidade foi faturada

// Verifica quanto entra e quanto sai em quantidade e valor.
_nQtdSai := (ZZV->ZZV_LANCES*ZZV->ZZV_METRAG) // Quantidade que sai do pedido
//_nVlrSai := Round((ZZV->ZZV_LANCES*ZZV->ZZV_METRAG) * SC6->C6_PRCVEN,2) // Quanto R$ sai   do pedido
_nQtdEnt := (ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL) // Quantidade que entra no pedido
_nVlrEnt := Round((ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL) * _nNewPrV,2) // Quanto R$ entra no pedido

DbSelectArea("SC5")
DbSetOrder(1) // C5_FILIAL+C5_NUM
DbSeek("02" + Substr(cPedInd,1,6),.F.)

DbSelectArea("SA1")
DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.F.)

_nVlrSai := SC6->C6_VALOR // Quanto R$ sai   do pedido - Digo que é tudo

lRet := .T.
_lMyAuto := .F.

If _lMyAuto
	aCabec   := {}
	aItens   := {}
	aLinha1  := {}
	aLinha2  := {}
	aadd(aCabec,{"C5_NUM"    ,SC5->C5_NUM    ,Nil})
	aadd(aCabec,{"C5_TIPO"   ,SC5->C5_TIPO   ,Nil})
	aadd(aCabec,{"C5_CLIENTE",SC5->C5_CLIENTE,Nil})
	aadd(aCabec,{"C5_LOJACLI",SC5->C5_LOJACLI,Nil})
	
	If _lItemAtu	// Substitui o item atual pelo negociado
		aadd(aLinha1,{"C6_NUM"    ,SC6->C6_NUM                                       ,Nil})
		aadd(aLinha1,{"C6_ITEM"   ,SC6->C6_ITEM                                      ,Nil})
		aadd(aLinha1,{"C6_PRODUTO",ZZV->ZZV_PROALT                                   ,Nil})
		aadd(aLinha1,{"C6_QTDVEN" ,(ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL)                 ,Nil})
		aadd(aLinha1,{"C6_PRCVEN" ,SC6->C6_PRCVEN                                    ,Nil})
		aadd(aLinha1,{"C6_PRUNIT" ,SC6->C6_PRUNIT                                    ,Nil})
		aadd(aLinha1,{"C6_QTDLIB" ,(ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL)                 ,Nil})
		aadd(aLinha1,{"C6_VALOR"  ,Round(((ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL)*SC6->C6_PRCVEN),2),Nil})
		aadd(aLinha1,{"C6_TES"    ,SC6->C6_TES                                       ,Nil})
		aadd(aLinha1,{"C6_ACONDIC",ZZV->ZZV_ACONAL                                   ,Nil})
		aadd(aLinha1,{"C6_LANCES" ,ZZV->ZZV_LANCEA                                   ,Nil})
		aadd(aLinha1,{"C6_METRAGE",ZZV->ZZV_METRAL                                   ,Nil})
		aadd(aLinha1,{"C6_XNEGOC" ,"7"                                               ,Nil})// ACEITE ALTERADO
		aadd(aLinha1,{"C6_SEMANA" ," "                                               ,Nil})
		_cNewItem := SC6->C6_ITEM
	Else			// Deixo o saldo no mesmo item e cria novo item negociado
		_cNewItem := ZZV->ZZV_ITEM
		DbSelectArea("SC6")
		DbSetOrder(1)	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		Do While DbSeek("02" + SubStr(cPedInd,1,6) + _cNewItem,.F.)
			_cNewItem := Soma1(_cNewItem)
		EndDo
		
		// Volta ao item em questão
		DbSeek("02" + cPedInd,.F.)
		
		_nQtLcFim := (SC6->C6_LANCES - ZZV->ZZV_LANCES)
		aadd(aLinha1,{"C6_NUM"    ,SC6->C6_NUM                ,Nil})
		aadd(aLinha1,{"C6_ITEM"   ,SC6->C6_ITEM               ,Nil})
		aadd(aLinha1,{"C6_PRODUTO",SC6->C6_PRODUTO            ,Nil})
		aadd(aLinha1,{"C6_QTDVEN" ,(_nQtLcFim*SC6->C6_METRAGE),Nil})
		aadd(aLinha1,{"C6_PRCVEN" ,SC6->C6_PRCVEN             ,Nil})
		aadd(aLinha1,{"C6_PRUNIT" ,SC6->C6_PRUNIT             ,Nil})
		aadd(aLinha1,{"C6_QTDLIB" ,;
		Max((_nQtLcFim*SC6->C6_METRAGE)-SC6->C6_QTDENT,0) ,Nil})
		aadd(aLinha1,{"C6_VALOR"  ,;
		Round(((_nQtLcFim*SC6->C6_METRAGE)*SC6->C6_PRCVEN),2),Nil})
		aadd(aLinha1,{"C6_TES"    ,SC6->C6_TES                ,Nil})
		aadd(aLinha1,{"C6_ACONDIC",SC6->C6_ACONDIC            ,Nil})
		aadd(aLinha1,{"C6_LANCES" ,_nQtLcFim                  ,Nil})
		aadd(aLinha1,{"C6_METRAGE",SC6->C6_METRAGE            ,Nil})
		aadd(aLinha1,{"C6_COMIS1" ,SC6->C6_COMIS1             ,Nil})
		aadd(aLinha1,{"C6_XNEGOC" ," "                        ,Nil})// ACEITE ALTERADO
		aadd(aLinha1,{"C6_SEMANA" ,"TAUTOM"                   ,Nil})
		
		// Incluir novo item
		
		aadd(aLinha2,{"C6_NUM"    ,SC6->C6_NUM                                       ,Nil})
		aadd(aLinha2,{"C6_ITEM"   ,_cNewItem                                         ,Nil})
		aadd(aLinha2,{"C6_PRODUTO",ZZV->ZZV_PROALT                                   ,Nil})
		aadd(aLinha2,{"C6_QTDVEN" ,(ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL)                 ,Nil})
		aadd(aLinha2,{"C6_PRCVEN" ,SC6->C6_PRCVEN                                    ,Nil})
		aadd(aLinha2,{"C6_PRUNIT" ,SC6->C6_PRUNIT                                    ,Nil})
		aadd(aLinha2,{"C6_QTDLIB" ,(ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL)                 ,Nil})
		aadd(aLinha2,{"C6_VALOR"  ,Round(((ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL)*SC6->C6_PRCVEN),2),Nil})
		aadd(aLinha2,{"C6_TES"    ,SC6->C6_TES                                       ,Nil})
		aadd(aLinha2,{"C6_ACONDIC",ZZV->ZZV_ACONAL                                   ,Nil})
		aadd(aLinha2,{"C6_LANCES" ,ZZV->ZZV_LANCEA                                   ,Nil})
		aadd(aLinha2,{"C6_METRAGE",ZZV->ZZV_METRAL                                   ,Nil})
		If SC6->C6_PRODUTO == ZZV->ZZV_PROALT
			aadd(aLinha1,{"C6_COMIS1" ,SC6->C6_COMIS1             ,Nil})
		EndIf
		aadd(aLinha2,{"C6_XNEGOC" ,"7"                                               ,Nil})// ACEITE ALTERADO
		aadd(aLinha2,{"C6_SEMANA" ," "                                               ,Nil})
	EndIf
	_nQSai := Round((ZZV->ZZV_LANCES*ZZV->ZZV_METRAG) * SC6->C6_PRCVEN,2) // Quanto R$ sai   do pedido
	_nQEnt := Round((ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL) * SC6->C6_PRCVEN,2) // Quanto R$ entra no pedido
	If !Empty(aLinha1)
		aadd(aItens,aLinha1)
		aLinha1 := {}
	EndIf
	If !Empty(aLinha2)
		aadd(aItens,aLinha2)
		aLinha2 := {}
	EndIf
	
	// Chama MATA410
	lMsErroAuto := .F.
	
	//Captura Area Tres Lagoas
	aAreaAtual := U_fGetEmp
	U_fGoEmp("01","02")
	//U_fRestEmp(aAreaAtual)
	MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItens,4)
	If lMsErroAuto
		lRet := .F.
		MostraErro()
		Return(.F.)
	Endif
	
	//Caso o pedido seja aceito com a negociação
	RecLock("SC5",.F.)
	SC5->C5_XNEGOC := "S"
	MsUnLock()
	
	//Retorna Empresa Atual
	U_fRestEmp(aAreaAtual)
Else
	// Efetua estorno das liberações do item do pedido
	_lIsLiber := .F. // Crédito não está liberado
	DbSelectArea("SC9")
	DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	DbSeek("02"+cPedInd,.F.)
	Do While SC9->C9_FILIAL == "02" .And. SC9->C9_PEDIDO == ZZV->ZZV_PEDIDO .And.;
		SC9->C9_ITEM == ZZV->ZZV_ITEM .And. SC9->(!Eof())
		
		If SC9->C9_BLCRED # "10" .And. SC9->C9_BLEST # "10"
			If Empty(SC9->C9_BLCRED)
				_lIsLiber := .T. // Crédito está liberado
			EndIf
			SC9->(a460Estorna())
			DbSeek("02"+cPedInd,.F.)
		Else
			SC9->(DbSkip())
		EndIf
	EndDo
	
	DbSelectArea("SC6")
	DbSetOrder(1)	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	DbSeek("02" + cPedInd,.F.)
	// Transfere todos os dados do SC6 para a memória
	//RegToMemory("SC6",.F.)
	
	_cNewItem := ZZV->ZZV_ITEM
	If !_lItemAtu // Não utiliza o item atual/original, criar novo item
		DbSelectArea("SC6")
		DbSetOrder(1)	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		Do While DbSeek("02" + SubStr(cPedInd,1,6) + _cNewItem,.F.)
			_cNewItem := Soma1(_cNewItem)
		EndDo
	EndIf
	
	_aALib := {} //Itens para rodar a libdofat
	
	DbSelectArea("SC6")
	DbSetOrder(1)	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
	DbSeek("02" + cPedInd,.F.)
	RecLock("SC6",.F.)
	
	If _lItemAtu // Utiliza o item atual/original
		SC6->C6_QTDVEN  := (ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL)
		SC6->C6_VALOR   := Round(((ZZV->ZZV_LANCEA*ZZV->ZZV_METRAL)*SC6->C6_PRCVEN),2)
		SC6->C6_ACONDIC := ZZV->ZZV_ACONAL
		SC6->C6_LANCES  := ZZV->ZZV_LANCEA
		SC6->C6_METRAGE := ZZV->ZZV_METRAL
		SC6->C6_XNEGOC  := "7"		// ACEITE ALTERADO
		SC6->C6_SEMANA  := "TAUTOM"
		SC6->C6_PRCVEN  := _nNewPrV
		SC6->C6_PRCBAS  := _nNewPrV
		//SC6->C6_VALOR   := (SC6->C6_QTDVEN*SC6->C6_PRCVEN)
		If ZZV->ZZV_PROALT # ZZV->ZZV_PRODUT
			SC6->C6_PRODUTO := ZZV->ZZV_PROALT
			SC6->C6_DESCRI  := Posicione("SB1",1,xFilial("SB1")+ZZV->ZZV_PROALT,"B1_DESC")
			SC6->C6_PRUNIT  := _nNewPrV
			//SC6->C6_LUCROBR
		EndIf
		MsUnLock()
		
		If SC6->C6_QTDVEN > (SC6->C6_QTDENT+SC6->C6_QTDEMP)
			AAdd(_aALib,{SC6->C6_NUM,SC6->C6_ITEM,(SC6->C6_QTDVEN - SC6->C6_QTDENT - SC6->C6_QTDEMP)})
		EndIf
		_nVlrEnt := SC6->C6_VALOR // Quanto R$ entra no pedido
	Else //!_lItemAtu // Não utiliza o item atual/original, criar novo item
		
		SC6->C6_LANCES  := (SC6->C6_LANCES-ZZV->ZZV_LANCES)
		SC6->C6_QTDVEN  := (SC6->C6_LANCES*SC6->C6_METRAGE)
		SC6->C6_VALOR   := (SC6->C6_QTDVEN*SC6->C6_PRCVEN)
		SC6->C6_XNEGOC  := " "
		SC6->C6_SEMANA  := "TAUTOM"
		SC6->C6_XQTDNEG := Max((SC6->C6_XQTDNEG-ZZV->ZZV_LANCES),0)
		MsUnLock()
		
		If SC6->C6_QTDVEN > (SC6->C6_QTDENT+SC6->C6_QTDEMP)
			AAdd(_aALib,{SC6->C6_NUM,SC6->C6_ITEM,(SC6->C6_QTDVEN - SC6->C6_QTDENT - SC6->C6_QTDEMP)})
		EndIf
		_nVlrEnt := SC6->C6_VALOR // Quanto R$ entra no pedido
		
		// Forma 1 de fazer
		RegToMemory("SC6",.F.)
		_nQtCpo := SC6->(FCount())
		RecLock("SC6",.T.)
		For nCntFor := 1 To _nQtCpo
			If AllTrim(FieldName(nCntFor)) == "C6_ITEM"
				FieldPut(nCntFor,_cNewItem)
			ElseIf AllTrim(FieldName(nCntFor)) == "C6_PRODUTO"
				FieldPut(nCntFor,ZZV->ZZV_PROALT)
			Else
				FieldPut(nCntFor,M->&(FieldName(nCntFor)))
			EndIf
		Next
		SC6->C6_DESCRI  := Posicione("SB1",1,xFilial("SB1")+ZZV->ZZV_PROALT,"B1_DESC")
		SC6->C6_ACONDIC := ZZV->ZZV_ACONAL
		SC6->C6_LANCES  := ZZV->ZZV_LANCEA
		SC6->C6_METRAGE := ZZV->ZZV_METRAL
		SC6->C6_QTDVEN  := SC6->C6_LANCES * SC6->C6_METRAGE
		SC6->C6_PRCVEN  := _nNewPrV
		SC6->C6_PRCBAS  := _nNewPrV
		SC6->C6_VALOR   := (SC6->C6_QTDVEN*SC6->C6_PRCVEN)
		If ZZV->ZZV_PROALT # ZZV->ZZV_PRODUT
			SC6->C6_DESCRI  := Posicione("SB1",1,xFilial("SB1")+ZZV->ZZV_PROALT,"B1_DESC")
			SC6->C6_PRUNIT  := _nNewPrV
		EndIf
		SC6->C6_XNEGOC  := "7"		// ACEITE ALTERADO
		SC6->C6_SEMANA  := "TAUTOM"
		SC6->C6_QTDENT  := 0
		SC6->C6_QTDENT2 := 0
		SC6->C6_DATFAT  := Ctod("")
		SC6->C6_NOTA    := " "
		SC6->C6_SERIE   := " "
		MsUnLock()
		
		AAdd(_aALib,{SC6->C6_NUM,SC6->C6_ITEM,(SC6->C6_QTDVEN - SC6->C6_QTDENT - SC6->C6_QTDEMP)})
		_nVlrEnt += SC6->C6_VALOR // Quanto R$ entra no pedido
	EndIf
	
	DbSelectArea("SA1")
	DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
	DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.F.)
	_A1_RISCO := SA1->A1_RISCO
	
	For _naLib := 1 to Len(_aALib)
		If _nVlrSai >= _nVlrEnt .Or. ;
			(_aALib[_naLib,2] == ZZV->ZZV_ITEM .And. ZZV->ZZV_ITEM # _cNewItem .And. _lIsLiber)
			// O pedido ficou com valor menor ou igual ao original OU
			// Estou liberando o mesmo item do ZZV E já estava liberado e
			// a nova liberação é de um item diferente
			If SA1->A1_RISCO # "A"
				DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
				DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.F.)
				
				RecLock("SA1",.F.)
				SA1->A1_RISCO := "A"  // Troco o risco para A para passar direto
				MsUnLock()
			EndIf
		ElseIf SA1->A1_RISCO # _A1_RISCO
			DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
			DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.F.)
			RecLock("SA1",.F.)
			SA1->A1_RISCO := _A1_RISCO
			MsUnLock()
		EndIf
		
		DbSelectArea("SC6")
		DbSetOrder(1)	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		DbSeek("02" + _aALib[_naLib,1] + _aALib[_naLib,2],.F.)
		If _aALib[_naLib,3] > 0
			
			aAreaAtual := U_fGetEmp()
			U_fGoEmp("01","02")
			
			MaLibDoFat(SC6->(RecNo()),_aALib[_naLib,3],.T.     ,.F.     ,.T.    ,.T.   ,.F.    ,.F.,,)
			
			U_fRestEmp(aAreaAtual)
			//MaLibDoFat(nRegSC6       ,nQtdaLib            ,lCredito,lEstoque,lAvCred,lAvEst,lLibPar,lTrfLocal,aEmpenho,bBlock,aEmpPronto,lTrocaLot,lOkExpedicao,nVlrCred,nQtdalib2)
			//±±³Parametros³ExpN1: Registro do SC6                                      ³±±
			//±±³          ³ExpN2: Quantidade a Liberar                                 ³±±
			//±±³          ³ExpL3: Bloqueio de Credito                                  ³±±
			//±±³          ³ExpL4: Bloqueio de Estoque                                  ³±±
			//±±³          ³ExpL5: Avaliacao de Credito                                 ³±±
			//±±³          ³ExpL6: Avaliacao de Estoque                                 ³±±
			//±±³          ³ExpL7: Permite Liberacao Parcial                            ³±±
			//±±³          ³ExpL8: Tranfere Locais automaticamente                      ³±±
			//±±³          ³ExpA9: Empenhos ( Caso seja informado nao efetua a gravacao ³±±
			//±±³          ³       apenas avalia ).                                     ³±±
			//±±³          ³ExpbA: CodBlock a ser avaliado na gravacao do SC9           ³±±
			//±±³          ³ExpAB: Array com Empenhos previamente escolhidos            ³±±
			//±±³          ³       (impede selecao dos empenhos pelas rotinas)          ³±±
			//±±³          ³ExpLC: Indica se apenas esta trocando lotes do SC9          ³±±
			//±±³          ³ExpND: Valor a ser adicionado ao limite de credito          ³±±
			//±±³          ³ExpNE: Quantidade a Liberar - segunda UM                    ³±±
			SC9->C9_TES := SC6->C6_TESORI
			SC9->(MsUnLock())
		EndIf
	Next
	
	If Empty(SC5->C5_LIBEROK)
		_cMyLib := "S"
		DbSelectArea("SC6")
		DbSetOrder(1)
		DbSeek("02"+SC5->C5_NUM,.F.)
		Do While SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())
			If SC6->C6_QTDVEN > (SC6->C6_QTDEMP+SC6->C6_QTDENT) .And. SC6->C6_BLQ # 'R '
				_cMyLib := " "
			EndIf
			SC6->(DbSkip())
		EndDo
		If SC5->C5_LIBEROK # _cMyLib
			RecLock("SC5",.F.)
			SC5->C5_LIBEROK := _cMyLib
			MsUnLock()
		EndIf
	EndIf
	
	//Caso o pedido seja aceito com a negociação
	RecLock("SC5",.F.)
	SC5->C5_XNEGOC := "S"
	MsUnLock()
EndIf

DbSelectArea("SA1")
DbSetOrder(1) // A1_FILIAL+A1_COD+A1_LOJA
DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.F.)
If SA1->A1_RISCO # _A1_RISCO .Or. !_lMyAuto
	RecLock("SA1",.F.)
	SA1->A1_RISCO := _A1_RISCO
	If !_lMyAuto .And. lRet
		SA1->A1_SALPED := SA1->A1_SALPED - _nVlrSai + _nVlrEnt
	EndIf
	MsUnLock()
EndIf

If !lRet
	Return(.F.)
EndIf

// Recalcular o LB dos itens e do pedido
DbSelectArea("SC5")
DbSetOrder(1) // C5_FILIAL+C5_NUM
DbSeek("02" + cPedInd,.F.)

_nTPrcVen := 0.00
_nTCustd  := 0.00
_nTTPed   := 0.00

DbSelectArea("SC6")
DbSetOrder(1)	// C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
DbSeek("02"+ SC5->C5_NUM,.F.)

Do While SC6->C6_FILIAL == "02" .And. SC6->(!Eof()) .And. SC6->C6_NUM == SC5->C5_NUM
	If SC5->C5_TIPO # "N"
		SC6->(DbSkip())
		Loop
	EndIf
	SB1->(DbSeek(xFilial("SB1")+SC6->C6_PRODUTO,.F.))
	If SB1->B1_TIPO # "PA"
		SC6->(DbSkip())
		Loop
	EndIf
	If SC6->C6_QTDENT == 0.00 .And. SC6->C6_BLQ <> 'R '
		If xFilial("SC6") == "02" // 3 lagoas
			_nLUCROBR := If(SB1->B1_CUSTD3L==0,0,(((SC6->C6_PRCVEN*100)/SB1->B1_CUSTD3L)-100))
		Else
			_nLUCROBR := If(SB1->B1_CUSTD==0,0,(((SC6->C6_PRCVEN*100)/SB1->B1_CUSTD)-100))
		EndIf
	EndIf
	_nTTPed   += SC6->C6_VALOR
	_nTPrcVen += SC6->C6_PRCVEN
	_nTCustd  += SB1->B1_CUSTD3L
	SC6->(DbSkip())
EndDo

_nLUCROBR := If(_nTCustd==0,0,((_nTPrcVen * 100) / _nTCustd) - 100)
If SC5->C5_LUCROBR # _nLUCROBR .Or. SC5->C5_TOTAL # _nTTPed
	RecLock("SC5",.F.)
	SC5->C5_TOTAL    := _nTTPed
	SC5->C5_LUCROBR  := _nLUCROBR
	SC5->(MsUnLock())
EndIf

Return(.T.)

*
*************************************************
Static Function MyVldCpo(_cNmCpo,_cCntUd,_cVlCpo)
*************************************************
*
Private _cNmCpo,_cCntUd,_cVlCpo

If "PERTENCE" $ Upper(_cVlCpo)
	_cVlCpo := StrTran(UPPER(_cVlCpo), "PERTENCE", _cNmCpo + " $ ")
EndIf
If "NAOVAZIO()" $ Upper(_cVlCpo)
	_cVlCpo := StrTran(UPPER(_cVlCpo), "NAOVAZIO()", "!Empty(" + _cNmCpo + ")")
EndIf
If "VAZIO()" $ Upper(_cVlCpo)
	_cVlCpo := StrTran(UPPER(_cVlCpo), "VAZIO()", "Empty(" + _cNmCpo + ")")
EndIf
If "POSITIVO()" $ Upper(_cVlCpo)
	_cVlCpo := StrTran(UPPER(_cVlCpo), "POSITIVO()", _cNmCpo + " >= 0")
EndIf
//If "A410PRODUTO()" $ Upper(_cVlCpo)
//	_cVlCpo := StrTran(UPPER(_cVlCpo), "A410PRODUTO()", "A410Produto('"+ _cCntUd + "')")
//EndIf

If _cNmCpo == "C6_PRODUTO"
	M->C6_PRODUTO := _cCntUd
	cProduto :=  _cCntUd
ElseIf _cNmCpo == "C6_QTDVEN"
	M->C6_QTDVEN := _cCntUd
ElseIf _cNmCpo == "C6_PRCVEN"
	M->C6_PRCVEN := _cCntUd
ElseIf _cNmCpo == "C6_ACONDIC"
	M->C6_ACONDIC := _cCntUd
ElseIf _cNmCpo == "C6_LANCES"
	M->C6_LANCES := _cCntUd
ElseIf _cNmCpo == "C6_METRAGE"
	M->C6_METRAGE := _cCntUd
ElseIf _cNmCpo == "C6_TES"
	M->C6_TES := _cCntUd
ElseIf _cNmCpo == "C6_COMIS1"
	M->C6_COMIS1 := _cCntUd
EndIf
_lRetVal  := &(_cVlCpo)
Return(_lRetVal)
