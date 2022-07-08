#include 'totvs.ch'
#define LINHA chr(13)

static LDEBUG_ORDERIT	:= GetNewPar('ZZ_DBORDIT',.F.)

/*/{Protheus.doc} cbcEmpEstPed
@type class
@author bolognesi
@since 26/04/2018
@description Classe que deve orquestrar a execução das liberações
de estoque para os pedidos, classe criada para assumir a longo prazo
as responsabilidades do fonte legado "CDEST01", que em 26/04/18 inicia
assumindo somente a liberação prioridade 5. As prioridades de,
liberação atrasado e liberado manual, continua sendo
executada pelo legado, apos as execuções do legado, esta classe assume liberando
todo o resto.
/*/
class cbcEmpEstPed
	data oSC9List
	data oSayProg
	data aPedido
	data aProdCurva
	data aProdNormal
	data nRunTime
	data nTotReg
	data cRunMsg
	data oHashC
	data oHashN
	
	method newcbcEmpEstPed() constructor
	method initEmpenho()
	method separaPedido()
	method separaCurva()
	method analisaSaldo()
	method doTheMagic()
	method getProd()
	method liberIt()
	method lastLiber()
	method getModel()
	method getWrgModel()
	method getListMdl()
	method limpaClasse()
	method setProgMsg()
	method showStatus()
endclass


/*/{Protheus.doc} newcbcEmpEstPed
@type method
@author bolognesi
@since 26/04/2018
@description metodo construtor da classe, recebe um objeto
oSay quando executado dentro de um FWMsgRun(), que deve receber
as alterações de status que ocorrem durante o processo.
/*/
method newcbcEmpEstPed(oSay) class cbcEmpEstPed
	default oSay := nil
	::oSayProg 	:= oSay
	::aProdCurva	:= {}
	::aProdNormal	:= {}
	::aPedido	:= {}
return(self)


/*/{Protheus.doc} initEmpenho
@type method
@author bolognesi
@since 26/04/2018
@description Metodo de entrada para inicio da execução
do processo, com tratativas de erros
/*/
method initEmpenho() class cbcEmpEstPed
	local bErro	:= nil
	local nTimer 	:= 0
	
	bErro		:= ErrorBlock({|oErr| HandleEr(oErr, self)})
	BEGIN SEQUENCE
		::nRunTime 	:= seconds()
		::cRunMsg	:= ''
		
		::setProgMsg('Iniciando rotina.. obtendo itens')
		::oSC9List := cbcC9ListModel():newcbcC9ListModel()
		::setProgMsg('Aplicando filtros iniciais')
		::oSC9List:filterModel()
		::setProgMsg('Criando estrutura de pedido/item')
		::separaPedido()
		::setProgMsg('Agrupando e separando produtos')
		::separaCurva()
		::setProgMsg('Obtendo saldos e necessidades')
		::analisaSaldo()
		::setProgMsg('Iniciando liberação')
		::doTheMagic()
		::setProgMsg('Finalizando rotina')
		
		::nRunTime 	:= seconds()- ::nRunTime
		::nTotReg	:= len(::getModel())
		
	RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
return(self)


/*/{Protheus.doc} separaPedido
@type method
@author bolognesi
@since 26/04/2018
@description Partindo de uma lista "cbcC9ListModel"
de objetos "cbcC9Model" e considerando que cada objeto representa um item a liberar
proveniente do SC9, realiza o agrupamento destes itens em um estrutura
de (pedido item) proporcionada pela classe modelo "cbcPedModel", gerando
um array "aPedido" de objetos "cbcPedModel"
/*/
method separaPedido() class cbcEmpEstPed
	local nX			:= 0
	local oMdlPed 	:= nil
	local nRecC5		:= 0
	local lNew		:= .T.
	local oHash 		:= HMNew()
	local xValue		:= nil
	for nX := 1  to len(::getModel())
		lNew		:= .T.
		nRecC5	:= ::getModel(nX):getRecno('SC5')
		if ! empty(::aPedido)
			if  HMGet( oHash , nRecC5 , @xValue )
				aadd( ::aPedido[xValue[1,2]]:aItem , ::getModel(nX) )
				lNew := .F.
			endif
		endif
		if lNew
			oMdlPed := cbcPedModel():newcbcPedModel()
			oMdlPed:addRecno({'SC5', nRecC5 })
			aadd( oMdlPed:aItem , ::getModel(nX) )
			oMdlPed:setSortOrder()
			aadd( ::aPedido, oMdlPed )
			HMAdd(oHash,{nRecC5, len(::aPedido)})
		endif
	next nX
	FreeObj(oHash)
return(self)


/*/{Protheus.doc} separaCurva
@type method
@author bolognesi
@since 26/04/2018
@description Metodo para criação dos arrays "aProdCurva"
e "aProdNormal", que contem objetos do modelo "cbcProdModel"
aqui os objetos são criados com a necessidade para liberação.
/*/
method separaCurva() class cbcEmpEstPed
	local nX 	:= 0
	local nY		:= 0 //
	local nTimer 	:= 0
	
	::oHashC	:= HMNew()
	::oHashN	:= HMNew()
	
	// TODO aqui pode lock nos registros (SC6/SC9/SC5)
	for nX := 1  to len(::getModel())
		if ::getModel(nX):prodCurva()
			addProdArr(::getModel(nX), @::aProdCurva, ::oHashC )
		else
			addProdArr(::getModel(nX), @::aProdNormal, ::oHashN )
		endif
	next nX
	
return(self)


/*/{Protheus.doc} analisaSaldo
@type method
@author bolognesi
@since 26/04/2018
@description Metodo para iniciar os valores de saldos
nos objetos "cbcProdModel" contidos nos arrays "aProdCurva"
e "aProdNormal", este busca os valores disponiveis na tabela
SBF, deixando o objeto "cbcProdModel" completo.
/*/
method analisaSaldo() class cbcEmpEstPed
	verifDispon( @::aProdCurva, self )
	verifDispon( @::aProdNormal, self )
return(self)


/*/{Protheus.doc} doTheMagic
@type method
@author bolognesi
@since 26/04/2018
@description Realiza a ordenação dos objetos do array "aPedido"
de acordo com prioridades definidas OrderIt(), simula o empenho
para saber se os não parciais foram atendidos inteiros FlagEmp(),
e por fim inicia o processo DoEmp().
/*/
method doTheMagic() class cbcEmpEstPed
	::setProgMsg('Ordenando prioridades')
	OrderIt(@::aPedido)
	zeroSSldPrd(@self)
	::setProgMsg('Simulação de empenho total')
	FlagEmp(@self)
	DoEmp(@self)
return(self)


/*/{Protheus.doc} getProd
@type method
@author bolognesi
@since 26/04/2018
@description Partindo de um objeto "cbcC9Model"
obtem o seu respectivo produto objeto "cbcProdModel"
realizando as buscas nos array "aProdNormal" e "aProdCurva"
/*/
method getProd(oItem) class cbcEmpEstPed
	local 	oProd 	:= nil
	local 	nPos		:= 0
	local 	nRecBF	:= 0
	local xValue		:= {}
	default 	oItem	:= nil
	
	if ! empty(oItem)
		nRecBF := oItem:getRecno('SBF')
		if  HMGet( ::oHashN , nRecBF , @xValue )
			oProd := ::aProdNormal[xValue[1,2]]
		elseif HMGet( ::oHashC , nRecBF , @xValue )
			oProd := ::aProdCurva[xValue[1,2]]
		endif
		/*
		if (nPos := Ascan(::aProdNormal, {|P| P:getRecBF() == nRecBF }) ) > 0
			oProd := ::aProdNormal[nPos]
		elseIf (nPos := Ascan(::aProdCurva, {|P| P:getRecBF() == nRecBF }) ) > 0
			oProd := ::aProdCurva[nPos]
		endif
		*/
	endif
return(oProd)


/*/{Protheus.doc} liberIt
@type method
@author bolognesi
@since 26/04/2018
@description Realiza o processo de liberação, recebendo
objeto "cbcPedModel" devidamente ordenado percorrendo
os seus itens realizando as liberações.
/*/
method liberIt(oPed,aNext) class cbcEmpEstPed
	local lParcial	:= oPed:isParcial()
	local lAll		:= oPed:isAll()
	local cNroPed		:= oPed:getNroPedido()
	
	for nY := 1 to Len(oPed:AITEM)
		cMsg		:= ''
		oItem 	:= oPed:AITEM[nY]
		oProd 	:= ::getProd(oItem)
		
		if ! lParcial
			if lAll
				oProd:empSaldo(oPed, oItem)
			else
				if ! oItem:prodCurva()
					oProd:empSaldo(oPed,oItem)
				endif
				
				// Flegado para segunda liberação
				if empty(oItem:getQtdOk()) .and. ( oProd:nSimulSaldo > 0)
					aadd(aNext,{oPed, oItem })
				endif
			endif
		else
			oProd:empSaldo(oPed,oItem)
		endif
		
	next nY
return(self)


/*/{Protheus.doc} lastLiber
@type method
@author bolognesi
@since 26/04/2018
@description Realiza a segunda liberação, utilizado para pedidos
não parciais que não foram atendidos inteiros, mas os produtos devem ser empenhados
mesmo não atendendo integralmente.
/*/
method lastLiber(aNext) class cbcEmpEstPed
	local nY		:= 0
	local oProd	:= nil
	
	::setProgMsg('Analisando segunda liberação ')
	for nY := 1 to Len(aNext)
		oProd 	:= ::getProd(aNext[nY,2])
		oProd:empSaldo(aNext[nY,1], aNext[nY,2])
	next nY
	
return (self)


/*/{Protheus.doc} getModel
@type method
@author bolognesi
@since 26/04/2018
@description Metodo que retorna a lista "cbcC9ListModel"
inteira, ou quando recebe parametro numerico retorna
o objeto "cbcC9Model" correspondente a posição informada
/*/
method getModel(nX) class cbcEmpEstPed
	local oRet	:= nil
	default nX := 0
	if nX > 0
		oRet := ::oSC9List:aC9Model[nX]
	else
		oRet := ::oSC9List:aC9Model
	endif
return(oRet)


/*/{Protheus.doc} getWrgModel
@type method
@author bolognesi
@since 26/04/2018
@description Obtem array de objetos "cbcC9Model"
considerados errados pela rotina
cbcC9ListModel:filterModel(), inicialmente (26/04/2018)
apenas os itens que não possuem SBF.
/*/
method getWrgModel(nX) class cbcEmpEstPed
	local oRet	:= nil
	default nX := 0
	if nX > 0
		oRet := ::oSC9List:aC9Wrong[nX]
	else
		oRet := ::oSC9List:aC9Wrong
	endif
return(oRet)


/*/{Protheus.doc} getListMdl
@type method
@author bolognesi
@since 26/04/2018
@description Retorna a propriedade "::oSC9List"
que é uma lista "cbcC9ListModel"
/*/
method getListMdl() class cbcEmpEstPed
return(::oSC9List)


/*/{Protheus.doc} limpaClasse
@type method
@author bolognesi
@since 26/04/2018
@description Realiza a limpeza das propriedades da
classe.
/*/
method limpaClasse() class cbcEmpEstPed
	/*
	if ::oSC9Model != nil
		FreeObj(::oSC9Model)
	endif
	::aPedido		:= {}
	::aProdCurva		:= {}
	::aProdNormal		:= {}
	*/
	FreeObj(::oHashC)
	FreeObj(::oHashN)
return(self)


/*/{Protheus.doc} setProgMsg
@type method
@author bolognesi
@since 26/04/2018
@description Atualiza o oSay exibido pela
função FWMsgRun(), de acordo com as etapas
realizadas.
/*/
method setProgMsg(cMsg) class cbcEmpEstPed
	default cMsg := ''
	// ::cRunMsg += (cMsg + LINHA)
	if !empty(::oSayProg)
		::oSayProg:SetText(cMsg)
		::oSayProg:CtrlRefresh()
	endif
return(self)


method showStatus() class cbcEmpEstPed
	local cMsg	:= ''
	cMsg += 'Usuario: ' +  UsrRetName(RetCodUsr()) + LINHA
	cMsg += ' Liberação de Pedidos ' 	+ LINHA
	
	if empty(::cRunMsg)
		cMsg += ' data ' +  Dtoc(date())  	+ LINHA
		cMsg += ' Duração: ' + cValToChar(::nRunTime) + ' s.' + LINHA
		cMsg += ' Processado(s): ' + cValToChar(::nTotReg) + ' registro(s) ' + LINHA
		if ( ::nRunTime > 0 ) .and. ( ::nTotReg > 0 )
			cMsg += ' Média: ' + 	cValToChar(::nRunTime/::nTotReg) + ' s. por registro' + LINHA
		endif
	else
		cMsg += ::cRunMsg
	endif
		
	MsgInfo(cMsg, 'cbcEmpEstPed')
return(self)


/*/{Protheus.doc} HandleEr
@type function
@author bolognesi
@since 26/04/2018
@description Realiza os tratamentos de erros da classe
/*/
static function HandleEr(oErr, oSelf)
	local cMsg	:= "[cbcEmpEstPed - "+DtoC(Date())+" - "+Time()+" ] "+ '[ERRO]' + oErr:Description + ' [FROM] ' + ProcName(3)
	// oSelf:libLock()
	ConOut(cMsg)
	oSelf:setProgMsg(cMsg)
	oSelf:cRunMsg := cMsg
	BREAK
return(nil)


/*/{Protheus.doc} addProdArr
@type function
@author bolognesi
@since 26/04/2018
@description Recebe  objeto modelo "cbcC9Model"
cria ou atualiza um objeto "cbcProdModel" no array "aProd"
Objetivo e realizar um agrupamento de produtos realizando
as somas de sua quantidade necessarias para empenho.
/*/
static function addProdArr(modelo, aProd, oHash)
	local lNew		:= .T.
	local nBF 		:= modelo:getRecno('SBF')
	local oProdMod	:= nil
	local xValue		:= nil
	
	if ! empty(aProd)
		if  HMGet( oHash , nBF , @xValue )
			aProd[xValue[1,2]]:nNecessario 		+= modelo:getQtdEmp()
			aProd[xValue[1,2]]:nQtdVend		+= modelo:getQtdVend()
			lNew := .F.
		endif
	endif
	if lNew
		oProdMod := cbcProdModel():newcbcProdModel()
		oProdMod:nRecBF 		:= nBF
		oProdMod:cCodProd		:= Alltrim(modelo:getCodProd()) + '-' + Alltrim(modelo:getLocaliz())
		oProdMod:nNecessario 	:= modelo:getQtdEmp()
		oProdMod:nQtdVend		:= modelo:getQtdVend()
		Aadd(aProd, oProdMod)
		HMAdd(oHash,{nBF, len(aProd)})
	endif
return(nil)


/*/{Protheus.doc} verifDispon
@type function
@author bolognesi
@since 26/04/2018
@description Realiza as tratativas no produto para obter
o saldo do SBF, empenhar o necessario para rotina, e iniciar
os saldos do objeto "cbcProdModel"
/*/
static function verifDispon(aProd, oSelf)
	local nX 	:= 0
	for nX := 1 to len(aProd)
		aProd[nX]:checkAtend()
	next nX
return(nil)


/*/{Protheus.doc} OrderIt
@type function
@author bolognesi
@since 16/04/2018
@version 1.0
@description Ordena o array de pedidos para inicio da simulação
de empenho, esta ordenação deve contemplar todas as prioridades,
Prioridade Inicial:
Ordenar Parcial de Não Parcial
Para os que forem Parcial Sim Ordenar por data de faturamento e numero pedido
Para o Não parcial Ordenar Por Curva e Não curva
/*/
static function OrderIt(aPed)
	local aTmp			:= {{},{}}
	local aItmTmp			:= {{},{}}
	
	if LDEBUG_ORDERIT
		tmpConf(aPed, @aTmp, 1, @aItmTmp )
	endif
	
	ASort(aPed, , , {|x,y| SortApply(x,y) } )
	
	if LDEBUG_ORDERIT
		tmpConf(aPed, @aTmp, 2, @aItmTmp )
	endif
	
return(nil)


/*/{Protheus.doc} SortApply
@type function
@author bolognesi
@since 30/04/2018
@version 1.0
@description Utilizado o Asort da função OrderIt, aplicar
aqui as ordenações/prioridades
/*/
static function SortApply(x,y)
	local lRet		:= .F.
	lRet := ( x:getSortOrder() < y:getSortOrder() )
	if !(x:lSortedItem)
		x:sortItem()
	endif
return(lRet)


/*/{Protheus.doc} zeroSSldPrd
@type function
@author bolognesi
@since 16/04/2018
@version 1.0
@description Reseta o saldo de simulação dos objetos "cbcProdModel"
deixando igual ao saldo, utilizado para iniciar o processo de empenho.
/*/
static function zeroSSldPrd(oSelf)
	local nX := 0
	for nX := 1 to len(oSelf:aProdCurva)
		oSelf:aProdCurva[nX]:resetSaldo()
	next nX
	for nX := 1 to len(oSelf:aProdNormal)
		oSelf:aProdNormal[nX]:resetSaldo()
	next nX
return(nil)


/*/{Protheus.doc} FlagEmp
@type function
@author bolognesi
@since 16/04/2018
@version 1.0
@description Realiza uma simulação de empenho para os pedidos
que não são parciais , identificando se atenderia todos os itens caso
atenda todos recebe o flag de .T.,os parciais sempre recebe o flag de .T.
/*/
static function FlagEmp(oSelf)
	local nX 	:= 0
	
	for nX := 1 to len(oSelf:aPedido)
		if !oSelf:aPedido[nX]:isParcial()
			oSelf:aPedido[nX]:setAll(todosAtend(oSelf:aPedido[nX], oSelf))
		else
			oSelf:aPedido[nX]:setAll(.T.)
		endif
	next nX
	
return(nil)


/*/{Protheus.doc} todosAtend
@type function
@author bolognesi
@since 16/04/2018
@version 1.0
@description Simula liberação e caso um item não seja liberado
retorna falso. Utilizado para flegar pedidos atendidos integralmente.
/*/
static function todosAtend(oPed, oSelf)
	local nY		:= 0
	local oProd	:= nil
	local lAll	:= .T.
	for nY := 1 to Len(oPed:aItem)
		oProd := oSelf:getProd(oPed:aItem[nY])
		if ! oProd:lAtendido
			if !oProd:empSaldo( oPed, oPed:aItem[nY], .T. )
				return(.F.)
			endif
		endif
	next nY
return(lAll)


/*/{Protheus.doc} DoEmp
@type function
@author bolognesi
@since 16/04/2018
@version 1.0
@description Realiza as duas rodadas de liberação, uma para
as prioridades e a outra para o que sobrar da primeira.
/*/
static function DoEmp(oSelf)
	local nX 	:= 0
	local aNext 	:= {}
	zeroSSldPrd(oSelf)
	
	for nX := 1 to len(oSelf:aPedido)
		oPed := oSelf:aPedido[nX]
		oSelf:liberIt(oPed, @aNext)
	next nX
	
	if !empty(aNext)
		oSelf:lastLiber(aNext)
	endif
	
	oSelf:setProgMsg('Liberações realizadas ')
	geraExcel(oSelf)
return(nil)


/*/{Protheus.doc} geraExcel
@type function
@author bolognesi
@since 16/04/2018
@version 1.0
@description Providencia a geração do relatorio em excel.
/*/
static function geraExcel(oSelf)
	local oRelat	:= nil
	oSelf:setProgMsg('Gerando relatorio ')
	oRelat := cbcRelatLib():newcbcRelatLib()
	oRelat:simulExcel(oSelf)
	FreeObj(oRelat)
return(nil)


/*/{Protheus.doc} tmpConf
@type function
@author bolognesi
@since 30/04/2018
@description Utilizada para conferir os arrays apos a ordenação
utilizado em tempo de desenvolvimento. Chamar na função
OrderIt(), antes e depois do Asort, caso mude o criterio
de ordenação na função SortApply(), refatorar aqui para que
os campos ordenados sejam visiveis.
/*/
static function tmpConf(aPed, aTmp, nPos, aItmTmp)
	local nX			:= 0
	local nY			:= 0
	local cLinha		:= ''
	local aLocalTmp	:= {}
	if LDEBUG_ORDERIT
		for nX := 1 to Len(aPed)
			aLocalTmp	:= {}
			cLinha		:= ''
			cLinha 		+= 'Parcial: ' + if(aPed[nX]:isParcial(), 'SIM ','NAO ')
			cLinha 		+= ' Chave: ' + Dtos(aPed[nX]:getDtFat()) + '-' + cValToChar(aPed[nX]:getRecno('SC5'))
			cLinha		+= ' ITEM ORDENADO: ' + if (aPed[nX]:lSortedItem, 'SIM', 'NAO')
			
			aadd(aTmp[nPos], cLinha)
			for nY := 1 to len(aPed[nX]:AITEM)
				cLinha		:= ''
				cLinha		+= 'PEDIDO: ' 	+ aPed[nX]:AITEM[nY]:getNroPedido()
				cLinha		+= ' ITEM: ' 		+ aPed[nX]:AITEM[nY]:getItemPedido()
				cLinha		+= ' CURVA: ' 	+ if(aPed[nX]:AITEM[nY]:prodCurva(), 'SIM', 'NAO')
				aadd(aLocalTmp, cLinha)
			next nY
			aadd(aItmTmp[nPos], aLocalTmp)
		next nX
	endif
return(nil)


/*/{Protheus.doc} zBeginLib
@type function
@author bolognesi
@since 26/04/2018
@description Função principal para execução da classe.LEO
/*/
user function zBeginLib(lMsgRun)
	default lMsgRun	:= .T.
	if lMsgRun
		FWMsgRun(, { |oSay| zxEstPed(oSay) }, "Liberação de Pedidos", "Processando a rotina...")
	else
		zxEstPed()
	endif
return(nil)


/*/{Protheus.doc} zxEstPed
(long_description)
@type function
@author bolognesi
@since 26/04/2018
@version 1.0
@description Inicia e execuçção da classe.
/*/
static function zxEstPed(oSay)
	local oEmpenho 	:= nil
	local nX			:= 0
	local oModel		:= nil
	default oSay		:= nil
	
	// StaticCall(CDEST01,fEstorno)
	oEmpenho := cbcEmpEstPed():newcbcEmpEstPed(oSay)
	oEmpenho:initEmpenho()
	oEmpenho:limpaClasse()
	oEmpenho:showStatus()
	
	/*
	if ! oModel:lockAll()
		MsgAlert(oModel:getErr(), 'ERRO')
	else
		// Todas os registros (SC5-SC6-SC9-SBF-SB2)
		oModel:libLock()
	endif
	if ! oModel:lockOne('SBF')
		MsgAlert(oModel:getErr(), 'ERRO')
	else
		oModel:libLock()
	endif
	*/
	FreeObj(oEmpenho)
return(nil)
