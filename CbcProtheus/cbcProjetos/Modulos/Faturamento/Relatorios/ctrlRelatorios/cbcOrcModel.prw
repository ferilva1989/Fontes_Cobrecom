#include 'protheus.ch'
#define linha chr(13)


/*/{Protheus.doc} cbcOrcModel
@author bolognesi
@since 03/03/2017
@version 1.0
@type class
@description Classe que representa um item do modelo de
dados do orçamento, este model e construido pela classe cbcOrcControl
/*/
class cbcOrcModel 
	data cNum
	data aCabec
	data aItem
	data lOk
	data cMsg
	method newcbcOrcModel() constructor 
	method sumCmp()
	method sumMult()
	method totVend()
	method pesoCobre()
	method totPvc()
	method totComiss()
	method CalcRg()
	method CalcCmp()
	method tot2_5()
	method qtd2_5()
	method pesoTotal()
	method totalCusto()
	method CalcIndice()
	method getIMP()
	method getPercIndice()
	method getCmp()
	method getPesFator()
	method getHdr()
	method getTpCliente()
	method getEndEntr()
	method getTpFrete()
	method descVista()
	method calcTabBruto()
	method calcDescs()
	method getValTab()
	method getRgTotal()
	method getMedComis()
	method getKmTotal()
endclass

method newcbcOrcModel(cNum) class cbcOrcModel
	::aCabec 	:= {}
	::aItem	 	:= {}
	::cNum	 	:= cNum
	::lOk		:= .T.
	::cMsg		:= ""
return (self)

/*/{Protheus.doc} CalcCmp
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Os item ao serem obtidos pela consulta SQL
trazem alguns campos vazios, especialmente para que sejam realizados 
calculos para preenchelos, neste metodo calculamos estes valores para cada item.
/*/
method CalcCmp() class cbcOrcModel
	local nX	:= 0
	for nX := 1 to len(::aItem)
		::CalcRg(::aItem[nX])
		::CalcIndice(::aItem[nX])
		::calcTabBruto(::aItem[nX] )
		::calcDescs( ::aItem[nX] )
	next Nx		
return (self)

/*/{Protheus.doc} sumCmp
@author bolognesi
@since 03/03/2017
@version 1.0
@param cCmp, characters, Campo existente no 
modelo de dados referente aos itens que devera ser somado
@type method
@description Metodo que percorre todos os itens de um modelo
realizando a soma de um campo que foi passado por parametro
/*/
method sumCmp(cCmp) class cbcOrcModel
	local nX		:= 0
	local nPos		:= 0
	local nRet		:= 0
	local aProp		:= {}
	local cCmd		:= ""
	default cCmp 	:= ""
	if !empty(cCmp) .and. !empty(::aItem)
		for nX := 1 to len(::aItem)
			if AttIsMemberOf( ::aItem[nX], cCmp )
				aProp := ClassDataArr(::aItem[nX])
				nPos := AScan(aProp ,{|a| (Alltrim( a[1] ) == Alltrim(cCmp) )  })
				if nPos > 0
					if valtype( aProp[nPos][2] ) == 'N'
						nRet += aProp[nPos][2] 
					endif
				endif
			endif
		next nX
	endif
return(nRet)

/*/{Protheus.doc} sumMult
@author bolognesi
@since 03/03/2017
@version undefined
@param cCmp1, characters, Primeiro campo
@param cOper, characters, Operalçao Matematica
@param cCmp2, characters, Segundo campo
@type method
@description Metodo que recebe o nome de dois campos
percorre os itens e para cada item aplica a operação contida
no 2 parametro (cOper), utilizando os dois campos, esta soma é acumulada.
Exemplo(Percorre todos os itens multiplicando QTDVEND pelo PRCVEND), o resultado
de cada item é acumulado na variavel lRet que ao final é retornada.
/*/
method sumMult(cCmp1, cOper, cCmp2) class cbcOrcModel
	local nRet 	:= 0
	local nX	:= 0
	local aProp	:= {}
	local nPos1	:= 0
	local nPos2	:= 0
	default cOper := '*'

	if !empty(cCmp1) .and. !empty(cCmp2) .and. !empty(::aItem)
		for nX := 1 to len(::aItem)
			if AttIsMemberOf( ::aItem[nX], cCmp1 ) .and. AttIsMemberOf( ::aItem[nX], cCmp2 )
				aProp := ClassDataArr(::aItem[nX])
				nPos1 := AScan(aProp ,{|a| (Alltrim( a[1] ) == Alltrim(cCmp1) )  })
				nPos2 := AScan(aProp ,{|a| (Alltrim( a[1] ) == Alltrim(cCmp2) )  })
				if nPos1 > 0 .and. nPos2 > 0
					if valtype( aProp[nPos1][2] ) == 'N' .and. valtype( aProp[nPos2][2] ) == 'N'
						nRet += mathOper(aProp[nPos1][2], cOper,  aProp[nPos2][2]) 
					endif
				endif
			endif
		next nX
	endif

return(nRet)

/*/{Protheus.doc} CalcRg
@author bolognesi
@since 03/03/2017
@version 1.0
@param aItem, array, Item para realizar o calculo
@type method
@description Este metodo é chamado pelo CalcCmp(), e é 
responsavel pelo calculo do RG individual de cada item.
/*/
method CalcRg(aItem) class cbcOrcModel
	local nX			:= 0
	local nRet 		:= 0
	local _nCustd		:= 0
	local nPrcVen		:= 0
	local nTxImposto	:= GetNewPar('ZZ_TXIMRGC', 27.50)
	local lLookM2		:= GetNewPar('ZZ_LOOKM2', .T.)

	If FWCodEmp()+FWCodFil() == "0102"
		_nCustd   := aItem:CUSTD3L
	Else
		_nCustd   := aItem:CUSTD
	EndIf
	
	if ::getHdr('MOEDA') <> 1 .and. lLookM2 .and. ::getHdr('TAXA_MOEDA') > 0
		nPrcVen 	:= (aItem:PRCVEN * ::getHdr('TAXA_MOEDA'))
		_nCustd 	:= (_nCustd - ((_nCustd/100) * nTxImposto) )
	else
		nPrcVen := aItem:PRCVEN
	endif
	 	
	aItem:TOTAL_RG_ITEM := Round(If(_nCustd==0,0,((( nPrcVen*100 )/_nCustd)-100)),2)
return(self)

/*/{Protheus.doc} CalcIndice
@author bolognesi
@since 03/03/2017
@version 1.0
@param aItem, array, Item para realizar o calculo
@type method
@description Metodo chamado pelo CalcCpm(), e é responsavel
pelo calculo do Indice em cada item.
/*/
method CalcIndice(aItem) class cbcOrcModel
	aItem:INDICE_ITEM 	:= aItem:QTDVEN * (aItem:VALCOB+aItem:VALPVC) 
	aItem:VARIACAO_ITEM	:= Round((( aItem:INDICE_ITEM / 75) * 100),2)

	If aItem:VARIACAO_ITEM > aItem:VALOR
		aItem:VARIACAO_ITEM := (aItem:VARIACAO_ITEM - aItem:VALOR)
		aItem:VARIACAO_ITEM := Round(((aItem:VARIACAO_ITEM / aItem:VALOR) * 100),2) 
	Else
		aItem:VARIACAO_ITEM  := 0.00
	EndIf

return(self)

/*/{Protheus.doc} totComiss
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Metodo que realiza o calculo do total de comissão
esta conta considera todos os itens.
/*/
method totComiss() class cbcOrcModel
	local nRet 		:= 0
	local nX		:= 0
	local nQtdVen	:= 0
	local nPeso		:= 0
	local nComis	:= 0
	if !empty(::aItem)
		for nX := 1 to len(::aItem)
			aProp 	:= ClassDataArr(::aItem[nX])
			nQtdVen := AScan(aProp ,{|a| (Alltrim( a[1] ) == Alltrim('QTDVEN') )  })
			nPeso	:= AScan(aProp ,{|a| (Alltrim( a[1] ) == Alltrim('PRCVEN') )  })
			nComis	:= AScan(aProp ,{|a| (Alltrim( a[1] ) == Alltrim('COMIS1') )  })
			
			if ( nQtdVen > 0) .and. ( nPeso > 0 ) .and. (nComis > 0) 
				if valtype( aProp[nQtdVen][2] ) == 'N' .and. valtype( aProp[nPeso][2] ) == 'N' .and.;
					valtype( aProp[nComis][2] ) == 'N'
					
					nRet += Round(((aProp[nQtdVen][2] * aProp[nPeso][2]) * aProp[nComis][2]) /100 ,2)   
				endif
			endif
		next nX
	endif
return(nRet)

/*/{Protheus.doc} totPvc
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Metodo que obtem o valor total
referente ao FATOR_PVC (Custo do PVC X Quantidade vendida)
utilizado para o calculo do IMP
/*/
method totPvc() class cbcOrcModel
	local nRet := 0
	nRet := ::sumMult('FATOR_PVC',"*", 'QTDVEN')
return(nRet)

/*/{Protheus.doc} totVend
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Metodo que obtem o valor total
de todos os itens. (Total do pedido)
/*/
method totVend() class cbcOrcModel
	local nRet	:= 0
	nRet := ::sumMult('QTDVEN',"*", 'PRCVEN')
return(nRet)

/*/{Protheus.doc} pesocobre
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Obtem o total do peso cobre de todos os itens
/*/
method pesocobre() class cbcOrcModel
	local nRet := 0
	nRet := ::sumMult('PESCOB',"*", 'QTDVEN')
return(nRet)

/*/{Protheus.doc} tot2_5
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Obtem o valor total do itens cujo produto
for 2,5 considerando os codigos contidos em 10105//11505
/*/
method tot2_5() class cbcOrcModel
	local nX		:= 0
	local _nVal2_5	:= 0

	for nX := 1 to len(::aItem)
		if Left(  ::aItem[nX]:COD_PRODUTO ,5) $ "10105//11505"
			_nVal2_5  += ::aItem[nX]:VALOR
		EndIf
	next nX
return(_nVal2_5)

method qtd2_5() class cbcOrcModel
	local nX		:= 0
	local _nQtd2_5	:= 0

	for nX := 1 to len(::aItem)
		if Left(  ::aItem[nX]:COD_PRODUTO ,5) $ "10105//11505"
			_nQtd2_5  += ::aItem[nX]:QTDVEN
		EndIf
	next nX
return(_nQtd2_5)

/*/{Protheus.doc} pesoTotal
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Obtem o peso total
dos itens, e considera Cobre + PVC
/*/
method pesoTotal() class cbcOrcModel
	local nRet 		:= 0
	nRet := ::sumMult('QTDVEN',"*", 'PESO')
return(nRet)

/*/{Protheus.doc} totalCusto
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Obtem o total do custo, considerando
todos os itens
/*/
method totalCusto() class cbcOrcModel
	local nRet	:= 0
	if FWCodEmp()+FWCodFil() == "0102" // 3 lagoas
		_nCustd   := 'CUSTD3L'
	else
		_nCustd   := 'CUSTD'
	endif
	nRet := ::sumMult('QTDVEN',"*", _nCustd)
return(nRet)

/*/{Protheus.doc} getIMP
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Obtem o valor do IMP(Indice de materia prima)
considerando o custo-cobre e custo-pvc
/*/
method getIMP() class cbcOrcModel
	local nRet := 0
	if empty( ::getHdr('CUSTO_COBRE')  )
		nRet	:= 0
	else
		nRet := ((( ( ::pesocobre() * ::getHdr('CUSTO_COBRE') ) + ::totPvc()  ) / ::totVend() ) * 100)
	endif
return(nRet)

/*/{Protheus.doc} getPercIndice
@author bolognesi
@since 03/03/2017
@version 1.0
@param nPos, numeric, Posição do item que deseja obter o calculo
@type method
@description Obtem o indice em forma de percentual.
/*/
method getPercIndice(nPos) class cbcOrcModel
	local nRet := 0
	default nPos := 0
	if nPos > 0
		nRet := Round((::aItem[nPos]:INDICE_ITEM / ::aItem[nPos]:VALOR) * 100,2)
	endif
return(nRet)

/*/{Protheus.doc} getCmp
@author bolognesi
@since 03/03/2017
@version undefined
@param nPos, numeric, Posição do item
@param cCmp, characters, Campo a ser obtido
@type method
@description Semalhante ao fieldGet(), este metodo
recebe uma posição de item, e retorna o valor correpondente 
ao nome do campo informado, idealizado para obter os valores
considerando um loop. (sendo nX do loop o nPos do Item)
/*/
method getCmp(nPos,cCmp) class cbcOrcModel
	local xRet		:= ""
	local aProp		:= {}
	local nBusca	:= 0
	local nX		:= 0
	default cCmp	:= ""
	::lOk		:= .T.
	::cMsg		:= ""
	if empty(::aItem)
		::lOk		:= .F.
		::cMsg		:= "[ERRO]- Nenhum item carregado na propriedade, aItem. " 
	else
		if Empty(cCmp) 
			::lOk		:= .F.
			::cMsg		:= "[ERRO]- Não informado o nome do campo para busca. " 
		else
			if nPos <= 0
				::lOk		:= .F.
				::cMsg		:= "[ERRO]- Informar a posição do item para obter o conteudo do campo. " 
			else
				if (  nPos > len(::aItem) ) 
					::lOk		:= .F.
					::cMsg		:= "[ERRO]- Posição informada" + cValToChar(nPos) +" não existe nos itens. " 
				else
					if ! AttIsMemberOf( ::aItem[nPos], cCmp )
						::lOk		:= .F.
						::cMsg		:= "[ERRO]- Campo " + Alltrim(cCmp) + " não existe nos itens." + linha 
						::cMsg		+= "Sendo os valores possiveis os seguintes: " + linha
						aProp := ClassDataArr(::aItem[nPos])
						for nX := 1 to len(aProp)
							::cMsg		+= aProp[nX][1] + linha
						next nX
					else
						aProp := ClassDataArr(::aItem[nPos])
						nBusca := AScan(aProp ,{|a| (Alltrim( a[1] ) == Alltrim(cCmp) )  })
						if nBusca > 0
							xRet := aProp[nBusca][2] 
						endif
					endif
				endif
			endif
		endif
	endif
return (xRet)

/*/{Protheus.doc} getHdr
@author bolognesi
@since 15/01/2021
@version 1.0
@description Obter o fator Total Vendido / Peso
/*/
method getPesFator() class cbcOrcModel
	local xRet := (::totVend() / ::pesocobre()) 
return xRet


/*/{Protheus.doc} getHdr
@author bolognesi
@since 03/03/2017
@version 1.0
@param cCmp, characters, Nome do campo para obter valor
@type method
@description Obtem o conteudo de um campo do header, recebido
por parametro
/*/
method getHdr(cCmp) class cbcOrcModel
	local xRet		:= ""
	local aProp		:= {}
	local nBusca	:= 0

	if ! AttIsMemberOf( ::aCabec, cCmp )
		::lOk		:= .F.
		::cMsg		:= "[ERRO]- Campo " + Alltrim(cCmp) + " não existe no Cabeçalho." + linha 
		::cMsg		+= "Sendo os valores possiveis os seguintes: " + linha
		aProp := ClassDataArr( ::aCabec )
		for nX := 1 to len(aProp)
			::cMsg		+= aProp[nX][1] + linha
		next nX
	else
		aProp := ClassDataArr(::aCabec)
		nBusca := AScan(aProp ,{|a| (Alltrim( a[1] ) == Alltrim(cCmp) )  })
		if nBusca > 0
			xRet := aProp[nBusca][2] 
		endif
	endif
return(xRet)

/*/{Protheus.doc} getTpCliente
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Obtem o tipo do cliente
idealizado para obter a descrição
/*/
method getTpCliente() class cbcOrcModel
	local xRet 	:= "?????"
	local cTipo	:= ::getHdr('TIPO_CLIENTE') 	
	if ::lOk
		if  cTipo == "S"
			xRet := "Solidario"
		ElseIf cTipo == "F"
			xRet := "Cons.Final"
		ElseIf cTipo == "R"
			xRet := "Revend."
		EndIf
	endif
return(xRet)

/*/{Protheus.doc} getEndEntr
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Metodo para obter o endereço de entrega quando preenchido
/*/
method getEndEntr() class cbcOrcModel
	local xRet	:= ""
	xRet := AllTrim(AllTrim(::getHdr('ENTREGA_1')) + " " + AllTrim(::getHdr('ENTREGA_2')))
return (xRet)

/*/{Protheus.doc} getTpFrete
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Metodo para obter a descrição
amigavel referente ao tipo do frete.
/*/
method getTpFrete() class cbcOrcModel
	local xRet	:= "????"
	local cTp	:= ::getHdr('TIPO_FRETE') 
	If cTp == "C"
		xRet := "CIF"
	ElseIf cTp == "F"
		xRet := "FOB"
	EndIf
return(xRet)

/*/{Protheus.doc} descVista
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Obtem o retorno logico para a questão
da condição de pagamento ser a vista ou não
/*/
method descVista() class cbcOrcModel
	local xRet	:= ""
	xRet := If(Empty(::getHdr('COD_COND_PGTO')),"N", ::getHdr('COND_VISTA') )
return(xRet)

/*/{Protheus.doc} calcTabBruto
@author bolognesi
@since 03/03/2017
@version 1.0
@param aItem, array, Item do qual obter a informação
@type method
@description Obtem para o item o preço bruto de tabela
/*/
method calcTabBruto(aItem) class cbcOrcModel 
	aItem:PRC_TAB_BRUTO := u_TabBruto( descagar(::getHdr('TABELA_PRECO'), 'CJ_TABELA'),;
	descagar(aItem:COD_PRODUTO, 'B1_COD') , aItem:ACONDIC +StrZero(aItem:METRAGE,5))
return(nil)

/*/{Protheus.doc} calcDescs
@author bolognesi
@since 03/03/2017
@version 1.0
@param aItem, array, Item que devera ser atualizado
@type method
@description Metodo chamado pelo CalcCmp(), e obtem a 
faixa de desconto aplicada para o item.
/*/
method calcDescs(aItem)  class cbcOrcModel
	local cDescs := ""
	cDescs := u_ClcDesc(descagar(::getHdr('TABELA_PRECO'), 'CJ_TABELA'),;
	descagar(::getHdr('COD_VEND'), 'CJ_VEND1'),;
	descagar(aItem:COD_PRODUTO, 'B1_COD'),;
	aItem:PRCVEN,aItem:PRC_TAB_BRUTO,::getHdr('COND_VISTA'))

	cDescs := cDescs[1]
	If Len(cDescs) > 33
		cDescs := Left(cDescs,30) + "..."
	EndIf
	aItem:DESCONTOS := cDescs
return(nil)

/*/{Protheus.doc} getValTab
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Obtem o valor total considerando o preço unitario
/*/
method getValTab() class cbcOrcModel
	local xRet		:= 0
	local nX		:= 0
	local nPrcUnit	:= 0 
	for nX := 1 to len(::aItem)
		nPrcUnit := ::getCmp(nX, "PRC_TAB_BRUTO") 
		If nPrcUnit == 0
			xRet += (::getCmp(nX, "QTDVEN")  * ::getCmp(nX, "PRUNIT"))
		Else
			xRet += (::getCmp(nX, "QTDVEN") * nPrcUnit)
		EndIf
	next nX
return(xRet)

/*/{Protheus.doc} getRgTotal
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Obtem o RG total considerando todos os itens
/*/
method getRgTotal() class cbcOrcModel
	local xRet := 0
	local nTxImposto	:= GetNewPar('ZZ_TXIMRGC', 27.50)
	local lLookM2		:= GetNewPar('ZZ_LOOKM2', .T.)
	local nTotVend	:= ::totVend()
	local nTotCust	:= ::totalCusto()

	if ::getHdr('MOEDA') <> 1 .and. lLookM2 .and. ::getHdr('TAXA_MOEDA') > 0
		nTotVend := (nTotVend * ::getHdr('TAXA_MOEDA'))
		nTotCust := (nTotCust - ((nTotCust/100) * nTxImposto) )
	endif
	
	xRet := Round((((nTotVend / nTotCust ) * 100)-100),2)
return(xRet)

/*/{Protheus.doc} getMedComis
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Obtem a media total de comissão
/*/
method getMedComis() class cbcOrcModel
	local xRet := 0
	xRet := Round((::totComiss() / ::totVend()) * 100,2)
return(xRet)

/*/{Protheus.doc} getKmTotal
@author bolognesi
@since 03/03/2017
@version 1.0
@type method
@description Obtem o total do peso
por quilometro
/*/
method getKmTotal() class cbcOrcModel
	local xRet := 0
	xRet := Round(((::pesoTotal() / ::sumCmp('QTDVEN'))*1000),2)
return(xRet)

/*/{Protheus.doc} mathOper
@author bolognesi
@since 03/03/2017
@version 1.0
@param nN1, numeric, Primeiro numero da operação
@param nN2, numeric, Segundo numero da operação
@param cOp, characters, Sinal da Operação
@type function
/*/
static function mathOper(nN1, cOp, nN2)
	local nRet		:= 0
	private cExec	:=	""
	cExec	:=  Alltrim(Str(nN1)) + ' ' + cOp + ' ' +  Alltrim(Str(nN2)) 
	nRet := &cExec
return(nRet)

/*/{Protheus.doc} descagar
@author bolognesi
@since 20/02/2017
@version 1.0
@param xVlr, , Valor a ser submetido ao padr
@param cTab, characters, campo para obter o tamanho TamSx3()[1]
@type function
@description Metodo para descagar o legado, que deveria
tratar padr os parametros recebidos, e não quem chama tratar estes
parametros
/*/
static function descagar(xVlr, cTab)
	local cValor := ""
	cValor := Padr(xVlr, TamSx3(cTab)[1])
return(cValor)
