#include 'protheus.ch'

/*/{Protheus.doc} cbcProductValues
@author bolognesi
@since 15/09/2016
@version 1.0
@description Classe responsavel em fornecer informações relacionadas ao valores do orçamento no portal
(Preço de Tabela, % Comissão, Faixa de Descontos, RGs)
/*/
class cbcProductValues  

	data cPriceTable	//Tabela de preço
	data lVldPriceTab	//Sinaliza se uma tabela de preço esta valida(DA0_DATATE)
	data nPrice			//Preço de tabela
	data nCostProduct	//Custo do Produto
	data nMinPrice		//Valor Minimo
	data nStdRg			//RG Padrão considerando preço de tabela
	data nCalcRg		//RG Praticado considerando preço de venda solicitado
	data nMinRg			//RG Praticado considerando o preço minimo
	data oQuotRg		//Objeto contendo o RG do Total do Orçamento (Para Preço Sugerido/Minimo/Aprovado)
	data cStdDiscRange	//Faixa de desconto padrão (ZZY_DESCPAD) (considerando preço de tabela)
	data cCalcDiscRange //Faixa de desconto solicitada ( considerando preço de venda solicitado)
	data cActDiscRange	//Faixa de desconto aplicada (ZZY_DESCONT)
	data nCommission	//Porcentagem de comissão Sugerido
	data nAppCommis		//Porcentagem de comissão Preço Aprovado
	data nMinComm		//Porcentagem minima de comissão
	data cSalesMan		//Codigo do vendedor
	data nSoldAmount	//Quantidade total vendida
	data cPayTerm		//Condição de pagamento
	data nPrcSug		//Preço venda sugerido
	data nPrcApp		//Preço venda Aprovado
	data TpFreight		//Tipo do Frete
	data dDlvDate		//Data de entrega considerando todos os itens. 
	data nTotalWeight	//Peso Total (PVC+Cobre) considerando todos os itens
	data nAvgDiscApp	//Média Desconto considerando todos os itens e Preço aprovado 
	data nAvgDiscSug	//Média Desconto considerando todos os itens e Preço sugerido 
	data nAvgCommApp	//Média Comissão considerando todos os itens e Preço aprovado
	data nAvgCommSug	//Média Comissão considerando todos os itens e Preço sugerido
	data nImpApp		//Indice de materia prima, considerando valor aprovado
	data nImpSug		//Indice de materia prima, considerando valor sugerido
	data lRetail		//Define se venda é do tipo varejo

	data cCliShop		//Cliente e Loja
	data cUfCli			//Estao do cliente
	data cCodProd		//Codigo do produto
	data cPackaging		//acondicionamento no formato R00100

	data lOk			//Status sobre a execução
	data cMsg			//Mensagem de erro

	data oArea			//Classe utilitarios tratamento Area
	data oSql 			//Classe utilitarios tratamento Sql

	method newcbcProductValues() constructor
	method getDiscountRange()		//Obter a faixa de desconto Padrão
	method getClcDesc()				//Realiza a chamada para (U_ClcDesc)
	method getPriceTable()			//Obter o codigo da tabela de preço 
	method getPrice()				//Obter o preço de tabela de um produto x tabela (u_TabBruto)
	method getCostProduct()			//Obter o custo do produto (B1_CUSTD3l, B1_CUSTD)
	method getRG()					//Obter o RG de uma determinada condição
	method getPrcFrmRG()			//Obter um preço de venda para um RG dessejado
	method getRGFrmQuot()			//Obter um total de RG para um objeto Quotation (Total Geral do RG)
	method getDlvFrmQuot()			//Obter a data de entrega para um objeto Quotation
	method getCalcFrmQuot()			//Recebe um objeto Quotation e um intention(Ex. TOTAL_RG, MEDIA_COMISSAO etc..)
	method getOthersCalc()			//Recebe um objeto Quotation e calcular outros totais ( Peso Total, Desc. Médio, Média de Comissão )
	method getImpFrmQuot()			//Recebe um objeto Quotation e calcula o indice de materia prima de todos os itens

	method getPayTerm()				//Obter a condição de pagamento
	method setPayTerm()				//Definir consição de pagamento

	method initCalc()				//Inicias os calculos

	method dlvFromProd()			//Calcula a data de entraga com base em array de produtos

	method getCliShop()
	method setCliShop()

	method getCodProd()
	method setCodProd()

	method getPackaging()
	method setPackaging()

	method getSoldAmount()
	method setSoldAmount()

	method getPrcApp()
	method setPrcApp()

	method getPrcSug()
	method setPrcSug()

	method getTpFreight()
	method setTpFreight()

	method getDlvDate()
	method setDlvDate()

	method getTotalWeight()	
	method setTotalWeight()	

	method getAvgDiscApp()	
	method setAvgDiscApp()	 
	method getAvgCommApp()
	method setAvgCommApp() 

	method getAvgSugDisc()	
	method setAvgSugDisc()	
	method getAvgSugComm()
	method setAvgSugComm()

	method getSalesMan()
	method setSalesMan()

	method getImpApp()
	method setImpApp()
	method getImpSug()
	method setImpSug()

	method setCommis()
	method setAppComms()
	method getCadCommis()

	method getRetail()
	method setRetail()

	method isVldPriceTab()

endclass

/*/{Protheus.doc} newnewcbcProductValues
Metodo construtor
@author bolognesi
@since 15/09/2016 
@version 1.0
@description Classe construtora, recebe o codigo e loja do cliente, Codigo do produto e acondicionamento (Acond+Metragem)
/*/
method newcbcProductValues(cCodCli, cLojaCli, cCodProd, cAcond, nQtdVend, nPrcSug, cCondPag, cTpFrete) class cbcProductValues
	Default cCodCli 	:= ""
	Default cLojaCli	:= ""
	Default cCodProd	:= ""
	Default cAcond		:= ""
	Default nQtdVend	:= ""
	Default nPrcSug		:= ""
	Default cCondPag	:= ""
	Default cTpFrete	:= ""

	::oArea 		:= SigaArea():newSigaArea()
	::oSql 			:= SqlUtil():newSqlUtil()
	::dDlvDate		:= Date()

	If !Empty(cCodCli) .And. !Empty(cLojaCli)
		::setCliShop(cCodCli, cLojaCli)
	Else
		::cCliShop := ""
	EndIf
	If !Empty(cCodProd)
		::setCodProd(cCodProd)
	Else
		::cCodProd := ""
	EndIf
	If !Empty(cAcond)
		::setPackaging(cAcond)
	Else
		::cPackaging := ""
	EndIf
	If !Empty(cCondPag)
		::setPayTerm(cCondPag)
	Else
		::cPayTerm := ""
	EndIf

	::setSoldAmount(nQtdVend)
	::setPrcSug(nPrcSug)

	If !Empty(cTpFrete)
		::setTpFreight(cTpFrete)
	Else
		::setTpFreight()
	EndIF
	::setSalesMan()
	::setRetail()
return (self)

//Cliente Loja
method getCliShop() class cbcProductValues
return(::cCliShop)
method setCliShop(cCodCli, cLojaCli) class cbcProductValues
	Default cCodCli := ""
	Default cLojaCli := ""
	::lOk	:= .T.
	::cMsg	:= ''
	If ChkAnyEmpty({cCodCli,cLojaCli}) 
		::lOk	:= .F.
		::cMsg	:= '[ERRO] - CBC001A' // Todos os paramteros são obrigatorios!'
	Else
		::cCliShop 	:=( LenX3Comp(cCodCli,'A1_COD') + LenX3Comp(cLojaCli,'A1_LOJA'))
	EndIf
return(self)

//Cod Produto
method getCodProd() class cbcProductValues
return(::cCodProd)
method setCodProd(cCodProd) class cbcProductValues
	Default cCodProd := ""
	::lOk	:= .T.
	::cMsg	:= ''
	If ChkAnyEmpty({cCodProd}) 
		::lOk	:= .F.
		::cMsg	:= '[ERRO] - CBC001B' // Todos os paramteros são obrigatorios!'
		::cCodProd := ""
	Else
		::cCodProd 	:= LenX3Comp(cCodProd, 'B1_COD') 
	EndIf
return(self)

//Acondicionamento
method getPackaging() class cbcProductValues
return(::cPackaging)
method setPackaging(cAcond) class cbcProductValues
	Default cAcond := "" 
	If  Len(cAcond) <> 6 .Or. !SubStr(cAcond,1,1) $ 'RBCMTL'
		::lOk	:= .F.
		::cMsg	:= '[ERRO] CBC002A '
		consoleLog('[ERRO] CBC002A - Verifique o acondicionamento informado [ ' + cAcond + ' ], exemplo (R00100)!')
		::cPackaging := ""
	Else
		::cPackaging := cAcond
	EndIf
return(self)

//Quantidade vendida
method getSoldAmount() class cbcProductValues
return(::nSoldAmount)
method setSoldAmount(nQtdVend) class cbcProductValues
	Default nQtdVend := "" 
	::nSoldAmount := nQtdVend
return(self)

//Preço venda sugerido
method getPrcSug() class cbcProductValues
return(::nPrcSug)
method setPrcSug(nPrcSug) class cbcProductValues
	Default nPrcSug := "" 
	::nPrcSug := nPrcSug
return(self)

//Preço venda Aprovado
method getPrcApp() class cbcProductValues
return(::nPrcApp)
method setPrcApp(nPrcApp) class cbcProductValues
	Default nPrcApp := "" 
	::nPrcApp := nPrcApp
return(self)

//Tipo do Frete
method getTpFreight() class cbcProductValues
return(::TpFreight)
method setTpFreight(cTpFrete) class cbcProductValues
	Default cTpFrete := "" 
	::TpFreight := cTpFrete
return(self)

//Data de Entrega
method getDlvDate() class cbcProductValues
return(::dDlvDate)
method setDlvDate(nPrz) 		class cbcProductValues
	Local nX		:= 0
	Local dDtEntr	:= Date()
	Default nPrz 	:= 0	
	If nPrz > 0
		For  nX := 1 to nPrz
			dDtEntr := DataValida(++ dDtEntr)
		Next
		//Verifica existência de feriados locais que não constam na tabela padrão do Protheus
		dDtEntr := U_DataIFC(Date(),dDtEntr)
		::dDlvDate := dDtEntr
	Else
		::dDlvDate := Date()
	EndIF
return(self)
//Peso Total
method getTotalWeight()			class cbcProductValues
return(::nTotalWeight)
method setTotalWeight(nWeight)	class cbcProductValues 
	Default nWeight := 0
	::nTotalWeight := nWeight
return(self)

//Desconto Medio Preço Aprovado
method getAvgDiscApp()		class cbcProductValues
return(::nAvgDiscApp)
method setAvgDiscApp(nDisc)	class cbcProductValues
	Default nDisc	:= 0
	::nAvgDiscApp := nDisc
return(self)

//Desconto Medio Preço Sugerido
method getAvgSugDisc()			class cbcProductValues
return(::nAvgDiscSug)
method setAvgSugDisc(nDisc)	class cbcProductValues
	Default nDisc	:= 0
	::nAvgDiscSug := nDisc
return(self)

//Media Comissão Preço Aprovado
method getAvgCommApp() 		class cbcProductValues
return(::nAvgCommApp)
method setAvgCommApp(nCommis)class cbcProductValues
	Default nCommis := 0
	::nAvgCommApp := nCommis
return(self)

//Media Comissão Preço Sugerido
method getAvgSugComm() 		class cbcProductValues
return(::nAvgCommSug)
method setAvgSugComm(nCommis)class cbcProductValues
	Default nCommis := 0
	::nAvgCommSug := nCommis
return(self)

//Codigo do representante
method getSalesMan() class cbcProductValues
return(::cSalesMan)
method setSalesMan(cCodA3) class cbcProductValues
	default cCodA3 := ""
	::cSalesMan := cCodA3
return(self)

//IMP Valor Aprovado
method getImpApp() class cbcProductValues
return(::nImpApp)
method setImpApp(nVlr) class cbcProductValues
	::nImpApp := nVlr
return(self)

//IMP Valor Sugerido
method getImpSug() class cbcProductValues
return(::nImpSug)
method setImpSug(nVlr) class cbcProductValues
	::nImpSug := nVlr
return(self)


//lVldPriceTab Retorna 
method isVldPriceTab(cTable) class cbcProductValues
	Default cTable  := 	::cPriceTable
	if !empty(cTable)
		::lVldPriceTab	:= MaVldTabPrc(cTable)
	else
		::lVldPriceTab	:= .F.
	endif
return(::lVldPriceTab)


//Obter comissão Fixa cadastro (Cliente ou Representante)
method getCadCommis() class cbcProductValues
	local oSql 			:= nil
	local nFixComm		:= 0
	if !empty(::cCliShop) .and. !empty(::cSalesMan)
		oSql := LibSqlObj():newLibSqlObj()
		//Verificar comissão fixa cadastro cliente(caso não seja o cliente padrão)
		if ::cCliShop  !=  GetNewPar('XX_CLORPAD', '00000000' )
			nFixComm := oSql:getFieldValue("SA1", "A1_COMIS", "%SA1.XFILIAL% AND A1_COD + A1_LOJA = '" + ::cCliShop + "'") 
		endif

		if empty(nFixComm)
			//Verificar comissão fixa cadastro representante
			nFixComm := oSql:getFieldValue("SA3", "A3_COMIS", "%SA3.XFILIAL% AND A3_COD = '" + ::cSalesMan + "'") 
		endif
		FreeObj(oSql)
	endif
return(nFixComm)

//Obter propriedade ::lRetail
method getRetail() class cbcProductValues
return(::lRetail)

//Definir propriedade ::lRetail
method setRetail(lRetail) class cbcProductValues
	default lRetail := .F.
	if !empty(lRetail) .and. ValType(lRetail) == 'L'
		::lRetail := lRetail 
	else
		::lRetail := .F.
	endif
return(self)

method initCalc() class cbcProductValues
	::lOk	:= .T.
	::cMsg	:= ''

	//Esta faltando parametros obrigatorio, configurar a classe!'
	If ChkAnyEmpty({::getCliShop(),::getCodProd(), ::getPackaging(), ::getSoldAmount() }) 
		::lOk	:= .F.
		::cMsg	:= '[ERRO] - CBC003'
	EndIf
	If ::getPriceTable():lOk
		If ::getPrice():lOk
			If ::getCostProduct():lOk
				If ::getDiscountRange():lOk
					If !Empty(::getPrcSug())
						//RG preço sugerido
						::nCalcRg := ::getRG(::getPrcSug())
					Else
						::nCalcRg := 0
					EndIf
					//RG tabela
					::nStdRg := ::getRG(::nPrice)
					//RG preço minimo
					::nMinRg := ::getRG(::nMinPrice)
				EndIf

			EndIf
		EndIf
	EndIf
	if !::lOk
		conout(::cMsg)
	endif
return (self)

/*/{Protheus.doc} getPayTerm
@author bolognesi
@since 06/12/2016
@version 1.0
@param cCampo, characters, Nome do campo na tabela Ex(E4_AVISTA, E4_DESCRI)
@type method
@description Obtem o conteudo do campo informado no paramtero cCampo, posicionando
no registro do SE4 com base na E4_CODIGO definido pelo metodo setPayTerm()
/*/
method getPayTerm(cCampo) class cbcProductValues
	Local xRet	:= ""
	Default cCampo := 'E4_AVISTA'
	::lOk	:= .T.
	::cMsg	:= ''
	::oArea:saveArea( {"SE4"} ) 
	cCond 	:= LenX3Comp(::cPayTerm, "E4_CODIGO")	
	xRet 	:= Posicione("SE4",1,xFilial("SE4") + ::cPayTerm,cCampo)
	::oArea:backArea() 
return xRet

/*/{Protheus.doc} setPayTerm
@author bolognesi
@since 06/12/2016
@version 1.0
@param cCond, characters, Codigo da condição de pagamento E4_CODIGO
@type method
@description Metodo para definir uma condição de pagamento para a estancia da classe
/*/
method setPayTerm(cCond) class cbcProductValues
	Local cCondCh	:= ""
	Default cCond 	:= ""
	::lOk	:= .T.
	::cMsg	:= ''
	::oArea:saveArea( {"SE4"} ) 
	If Empty(cCond)
		::lOk	:= .F.
		::cMsg	:= '[ERRO] CBC001C' // '- Parametro obrigatorio'
	Else
		cCondCh 	:= LenX3Comp(cCond, "E4_CODIGO")
		If Empty(Posicione("SE4",1,xFilial("SE4") + cCondCh,'E4_CODIGO'))
			::lOk	:= .F.
			::cMsg	:= '[ERRO] - CBC004' //'Condição de pagamento informada não existe!'
		Else
			::cPayTerm 	:= cCond
		EndIf
	EndIf
	::oArea:backArea() 
return(self)

/*/{Protheus.doc} getPriceTable
@author bolognesi
@since 15/09/2016
@version 1.0
@type method
@description Metodo que obtem o codigo da tabela de preço
inicando a busca no Cliente SA1 se não tem busca no Vendedor SA3
/*/
method getPriceTable() class cbcProductValues
	local lVarejo	:= if( empty(::getRetail()),.F.,::getRetail() ) 
	::lOk 			:= .T.
	::cMsg			:= ""
	::cPriceTable	:= ""
	::oArea:saveArea( {"SA1","SA3"} ) 

	if lVarejo
		::cUfCli 		:= ""
		::cPriceTable 	:= Padr( GetNewPar('XX_VARTAB', '12'), TamSx3('A1_TABELA')[1] )
	else
		//Cliente padrão não tem vendedor utilizar definido pelo portal
		if ::cCliShop ==  GetNewPar('XX_CLORPAD', '00000000' )
			::cUfCli := ""
			if empty(::getSalesMan())
				::lOk	:= .F.
				::cMsg	:= '[ERRO] CBC005' //'- Orçamento de cliente padrão, informar o codigo do vendedor!'
			else
				DbSelectArea("SA3")
				SA3->(DbSetOrder(1))//A3_FILIAL, A3_COD
				If SA3->(!DbSeek(xFilial("SA3") + padr(::getSalesMan(), TamSx3('A3_COD')[1] ), .F. ))
					::lOk	:= .F.
					::cMsg	:= '[ERRO] - CBC006'
					ConsoleLog('[ERRO] CBC006 - Vendedor [ ' + Alltrim(::getSalesMan()) + ' ], não cadastrado cadastrado!')
				Else
					::cPriceTable := SA3->(A3_TABELA)
				endif
			endif
		else
			//Obter vendedor a partir do cliente
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1)) //A1_FILIAL, A1_COD, A1_LOJA

			If SA1->( !DbSeek(xFilial("SA1") + ::cCliShop,.F. ) )
				::lOk	:= .F.
				::cMsg	:= '[ERRO] - CBC007'
				ConsoleLog('[ERRO] - CBC007 Cliente codigo loja[ ' + ::cCliShop + ' ], não encontrado!')
			Else
				::cSalesMan	 := SA1->(A1_VEND)
				::cUfCli	 := SA1->(A1_EST)

				if (Alltrim(SA1->(A1_CONTRUT)) == 'S')
					::cPriceTable := Padr(GetNewPar('XX_CONTAB', '8' ), TamSx3('A1_TABELA')[1])
					ConsoleLog('[AVISO] - Para Cliente codigo loja[ ' + ::cCliShop + ' ], definido utilizar tabela de construtora!')
				else
					if Empty(SA1->(A1_TABELA))
						if empty(SA1->(A1_VEND))
							::lOk	:= .F.
							::cMsg	:= '[ERRO] - CBC008'
							ConsoleLog('[ERRO] - CBC008 Cliente codigo loja[ ' + ::cCliShop + ' ], não possui vendedor cadastrado!')
						else
							DbSelectArea("SA3")
							SA3->(DbSetOrder(1))//A3_FILIAL, A3_COD
							if SA3->(!DbSeek(xFilial("SA3") + SA1->(A1_VEND), .F.))
								::lOk	:= .F.
								::cMsg	:= '[ERRO] - CBC009'
								ConsoleLog('[ERRO] - CBC009 Vendedor [ ' + SA1->(A1_VEND) + ' ], invalido para cliente cadastrado!')
							else
								::cPriceTable := SA3->(A3_TABELA)
							endif
						endif
					else
						::cPriceTable := SA1->(A1_TABELA)
					endif
				endif
			endIf
		endif
	endif
	if Empty(::cPriceTable) .And. ::lOk	
		::lOk	:= .F.
		::cMsg	:= '[ERRO] - CBC010'
		ConsoleLog('[ERRO] - CBC010 Vendedor [' + ::cSalesMan + '] Cliente [ ' + ::cCliShop + ' ], não possuem tabela de preco cadastrada!')
	endIf

	::oArea:backArea()           
return (self)

/*/{Protheus.doc} getPriceTable
@author bolognesi
@since 16/09/2016
@version 1.0
@type method
@description Metodo que obtem, os preços de um determinado produto, para uma determinada tabela de preços
utilizando a função interna u_TabBruto, pode receber os parametros ou utilizar os da construção da classe
/*/
method getPrice(cTab,cCodProd, cPack) class cbcProductValues
	Local bErro

	Default cTab 		:= 	::cPriceTable
	Default cCodProd	:=	::cCodProd
	Default cPack		:=	::cPackaging

	::lOk 		:= .T.
	::cMsg		:= ""
	::nPrice	:= ""

	If ChkAnyEmpty({cTab,cCodProd,cPack}) 
		::lOk	:= .F.
		::cMsg	:= '[ERRO] - CBC011' //'Classe:cbcProductValues Metodo:getPrice(), todos os paramteros são obrigatorios!'
	Else

		bErro	:= ErrorBlock({|oErr| HandleEr(oErr, self)})
		BEGIN SEQUENCE
			ConsoleLog("U_TabBruto('" + cTab + "','" + cCodProd + "','" + cPack + "')"  )
			::nPrice := U_TabBruto(cTab, cCodProd, cPack, .T. )	
			RECOVER
		END SEQUENCE
		ErrorBlock(bErro)

	EndIf

	If Empty(::nPrice)
		::lOk 	:= .F.
		::cMsg	:= "[ERRO] - CBC012"  //"cbcProductValues:getPrice() Produto sem preço de tabela U_TabBruto() "
	EndIf

return (self)

/*/{Protheus.doc} getCostProduct
@author bolognesi
@since 16/09/2016
@version 1.0
@type method
@description Metodo que deve obter o preço de custo do produto, com base B1_CUSTD3L ou B1_CUSTD
recebe codigo do produto como parametro ou pode utilizar codigo produto obtido no construtor
/*/
method getCostProduct(cCodProd) class cbcProductValues
	Default cCodProd	:=	::cCodProd
	::lOk 	:= .T.
	::cMsg	:= ""
	::nCostProduct		:= ""
	::oArea:saveArea( {"SB1"} ) 
	If FwCodEmp() + FwCodFil() == "0102" 
		::nCostProduct   := Posicione("SB1",1,xFilial("SB1")+ cCodProd,"B1_CUSTD3L")
	Else
		::nCostProduct   := Posicione("SB1",1,xFilial("SB1")+ cCodProd,"B1_CUSTD")
	EndIf
	::oArea:backArea() 
	If Empty(::nCostProduct)
		::lOk	:= .F.
		::cMsg	:= '[ERRO]  CBC013 ' //'Produto sem custo cadastrado!'
	EndIf
return (self)

/*/{Protheus.doc} setAppComms
@author bolognesi
@since 08/06/2017
@version 1.0
@param nCommis, numeric, Comissão calculada (U_CalcDesc)
@param nMinCommis, numeric, Comissão minima calculada (U_CalcDesc)
@param nPrcApp, numeric, Preço aprovado para a venda
@type method
@description Definir a propriedade ::nAppCommis com o valor da comissão
considerando casos onde a comissão esta fixa na tabela A1_COMIS ou A3_COMIS
semelhante a função U_VejaComis(), complementa os calculos da função
U_CalcDesc 
/*/
method setAppComms(nCommis, nMinCommis, nPrcApp,nMinPrc) class cbcProductValues
	local nFixComm		:= 0
	default nCommis		:= 0
	default nMinCommis	:= 0

	ConsoleLog( 'setAppComms ' + 'nCommis ' + CValToChar(nCommis)+ '_ ' +;
	'nMinCommis ' + CValToChar(nMinCommis) + '_ ' +;
	'nPrcApp ' + CValToChar(nPrcApp) + '_ ' +;
	'nMinPrc ' + CValToChar(nMinPrc) )

	::lOk 	:= .T.
	::cMsg	:= ""

	//'Calculo de comissão sem valores obtidas U_CalcDes(), metodo ::getClcDesc()!'
	if empty(nCommis) .or. empty(nMinCommis)
		::lOk	:= .F.
		::cMsg	:= '[ERRO]  CBC020 '
	else
		nFixComm := ::getCadCommis()

		//Tem comissão fixa
		if !empty(nFixComm)
			::nAppCommis := nFixComm 
			//Obter pelo calculo
		else
			if empty(nPrcApp)
				::nAppCommis := nCommis
			else
				ConsoleLog('setAppComms_Obter_comissão_preço_minimo ' +;
				'If(' + cValToChar(nPrcApp) + '<' + cValToChar(nMinPrc) + ',' +;
				cValToChar(nMinCommis) + ',' +  cValToChar(nCommis) + ')' )

				::nAppCommis := If( nPrcApp < nMinPrc ,nMinCommis, nCommis)
			endif
		endif
	endif 
	ConsoleLog('setAppComms02_comissão_atribuida ' + cValtoChar(::nAppCommis))
return(self)

/*/{Protheus.doc} setCommis
@author bolognesi
@since 20/03/2017
@version 1.0
@param nCommis, numeric, Comissão calculada (U_CalcDesc)
@param nMinCommis, numeric, Comissão minima calculada (U_CalcDesc)
@param nPrcSug, numeric, Preço sugerido para a venda
@type method
@description Definir a propriedade ::nCommission com o valor da comissão
considerando casos onde a comissão esta fixa na tabela A1_COMIS ou A3_COMIS
semelhante a função U_VejaComis(), complementa os calculos da função
U_CalcDesc 
/*/
method setCommis(nCommis, nMinCommis, nPrcSug, nMinPrc) class cbcProductValues
	local nFixComm		:= 0
	default nCommis		:= 0
	default nMinCommis	:= 0

	ConsoleLog( 'setCommis ' + 'nCommis ' + CValToChar(nCommis)+ '_ ' +;
	'nMinCommis ' + CValToChar(nMinCommis) + '_ ' +;
	'nPrcSug ' + CValToChar(nPrcSug) + '_ ' +;
	'nMinPrc ' + CValToChar(nMinPrc) )

	::lOk 	:= .T.
	::cMsg	:= ""

	//'Calculo de comissão sem valores obtidas U_CalcDes(), metodo ::getClcDesc()!'
	if empty(nCommis) .or. empty(nMinCommis)
		::lOk	:= .F.
		::cMsg	:= '[ERRO]  CBC021'
	else
		nFixComm := ::getCadCommis()

		//Tem comissão fixa
		if !empty(nFixComm)
			::nCommission := nFixComm 
			//Obter pelo calculo
		else
			if empty(nPrcSug)
				::nCommission := nCommis
			else

				ConsoleLog('setCommis_Obter_comissão_preço_minimo ' +;
				'If(' + cValToChar(nPrcSug) + '<' + cValToChar(nMinPrc) + ',' +;
				cValToChar(nMinCommis) + ',' +  cValToChar(nCommis) + ')' )

				::nCommission := If( nPrcSug < nMinPrc ,nMinCommis, nCommis)
			endif
		endif
	endif 
	ConsoleLog('setCommis02_comissão_atribuida ' + cValtoChar(::nCommission))

	::nMinComm := nMinCommis
return(self)

/*/{Protheus.doc} getClcDesc
@author bolognesi
@since 08/06/2017
@version undefined
@param nPrice, numeric, descricao
@type method
@description Metodo responsavel por obter (1-Desc.Efetivo, 2-Desc.Padrão, 3-% Comissão, 4-% Min. Comissão, 5-Valor Minimo)
utiliza classe interna U_ClcDesc(), recebe como entrada um preço de venda.
/*/
method getClcDesc(nPrice) class cbcProductValues
	local aInfoDesc		:= {}
	default nPrice		:= 0
	::lOk 	:= .T.
	::cMsg	:= ''
	//'Classe:cbcProductValues Metodo:getClcDesc(), parametros para U_ClcDesc() invalidos!'
	if ChkAnyEmpty({::cPriceTable,::cSalesMan,::cCodProd,::nPrice}) 
		::lOk	:= .F.
		::cMsg	:= '[ERRO] - CBC014'
	else
		bErro	:= ErrorBlock({|oErr| HandleEr(oErr, self)})
		BEGIN SEQUENCE
			aInfoDesc := U_ClcDesc(::cPriceTable, ::cSalesMan, ::cCodProd, nPrice, ::nPrice, ::getPayTerm('E4_AVISTA')  )	
			RECOVER
		END SEQUENCE
		ErrorBlock(bErro)
		if ::lOk
			//'Classe:cbcProductValues Metodo:getClcDesc(), retorno invalido da funcao U_ClcDesc()!'
			if Empty(aInfoDesc) .Or. ValType(aInfoDesc) != 'A' .Or. Len(aInfoDesc) != 6
				::lOk	:= .F.
				::cMsg	:= '[ERRO] - CBC015'
			else
				//'1-Desc.Efetivo'
				if Valtype(aInfoDesc[1]) != 'C'
					::lOk	:= .F.
					::cMsg	:= '[ERRO] - CBC015A'
					//'2-Desc.Padrão
				elseIf Empty(aInfoDesc[2]) .Or. Valtype(aInfoDesc[2]) != 'C'
					::lOk	:= .F.
					::cMsg	:= '[ERRO] - CBC015B'
					//'3-% Comissão'
				elseIf Empty(aInfoDesc[3]) .Or. Valtype(aInfoDesc[3]) != 'N'
					::lOk	:= .F.
					::cMsg	:= '[ERRO] - CBC015C'
					//4-% Min. Comissão
				elseIf Empty(aInfoDesc[4]) .Or. Valtype(aInfoDesc[4]) != 'N'
					::lOk	:= .F.
					::cMsg	:= '[ERRO] - CBC015D'
					//5-Valor Minimo
				elseIf Empty(aInfoDesc[5]) .Or. Valtype(aInfoDesc[5]) != 'N'
					::lOk	:= .F.
					::cMsg	:= '[ERRO] - CBC015E'
					//Não tem carta de desconto
				else
					if Alltrim(aInfoDesc[2]) == "???"
						::lOk		:= .F.
						::cMsg		:= '[ERRO] - CBC015F'
					endif
				endif
			endif
		endif		
	endif
return(aInfoDesc)

/*/{Protheus.doc} getDiscountRange
@author bolognesi
@since 16/09/2016
@version 1.0
@type method
@description Obtem os valores (1-Desc.Efetivo, 2-Desc.Padrão, 3-% Comissão, 4-% Min. Comissão, 5-Valor Minimo)
utilizado para calcular os totais
/*/
method getDiscountRange(nSugPrice, nAppPrice) class cbcProductValues
	local aInfSugDesc	:= {}
	local aInfAppDesc	:= {}
	local nPercFob		:= 0
	local nAppMinPrice	:= 0
	local cAppDiscRange	:= ''
	local oDesc			:= Nil
	local nBndes		:= 0
	local cTpFrete		:= ::getTpFreight()
	local nPercFob 		:=  getRegPar(::cUfCli) 
	Default nSugPrice 	:= if(empty(::getPrcSug()),0,::getPrcSug())
	Default nAppPrice	:= ::getPrcApp() 

	//Preço Sugerido
	aInfSugDesc := ::getClcDesc(nSugPrice)
	if ::lOk
		::cCalcDiscRange 	:= Alltrim(aInfSugDesc[1]) 
		::cStdDiscRange		:= Alltrim(aInfSugDesc[2])
		::cActDiscRange		:= aInfSugDesc[6][Len(aInfSugDesc[6])][2]
		::nMinPrice			:= iif(GetNewPar('ZZ_TABISMI', .F. ), ::nPrice, aInfSugDesc[5])
		//Adicional de desconto para FOB
		//Não tem quando cliente padrão
		if cTpFrete =='F' .And.  ::cCliShop  !=  GetNewPar('XX_CLORPAD', '00000000' )	
			::cActDiscRange += '+' + cValToChar(nPercFob)
			oDesc := cbcDesc():newcbcDesc(::nMinPrice)
			oDesc:addDesc(nPercFob)
			::nMinPrice := oDesc:getActValue()
			FreeObj(oDesc)
		endif

		::setCommis(aInfSugDesc[3], aInfSugDesc[4], nSugPrice, ::nMinPrice)
	endif

	//Preço Aprovado
	if !empty(nAppPrice)
		aInfAppDesc := ::getClcDesc(nAppPrice)
		if ::lOk
			nAppMinPrice			:= iif(GetNewPar('ZZ_TABISMI', .F. ), ::nPrice, aInfAppDesc[5])
			cAppDiscRange		:= aInfAppDesc[6][Len(aInfAppDesc[6])][2]
			if cTpFrete =='F' .And.  ::cCliShop  !=  GetNewPar('XX_CLORPAD', '00000000' )
				cAppDiscRange += '+' + cValToChar(nPercFob)
				oDesc := cbcDesc():newcbcDesc(nAppMinPrice)
				oDesc:addDesc(nPercFob)
				nAppMinPrice := oDesc:getActValue()
				FreeObj(oDesc)
			endif
			::setAppComms(aInfAppDesc[3], aInfAppDesc[4], nAppPrice, nAppMinPrice)
		endif
	endif					
return (self)

/*/{Protheus.doc} getRG
@author bolognesi
@since 16/09/2016
@version 1.0
@type method
@description Metodo para obter RG de uma determinada condição, receber o valor de venda desejado
ou valor de tabela quando utiliza dados do construtor
/*/
method getRG(nPrice, nQtdVen) class cbcProductValues
	Local nItemCost		:= 0 	//Total do custo
	Local nItemPrice	:= 0	//Total venda
	Local nResult		:= 0	//Resultado do RG
	Default nPrice 		:=  ::nPrice
	Default nQtdVen		:=	::nSoldAmount 
	::lOk 	:= .T.
	::cMsg	:= ""
	If ChkAnyEmpty({nPrice,nQtdVen}) 
		::lOk	:= .F.
		::cMsg	:= '[ERRO] - CBC016'  //'Classe:cbcProductValues Metodo:getRG(), parametros invalidos!'
	Else
		nItemCost 	:= (::nCostProduct * nQtdVen )
		nItemPrice	:= (nPrice * nQtdVen ) 
		nResult := (((nItemPrice * 100) / nItemCost ) - 100)
	EndIf
return ( Round(nResult,2) )

/*/{Protheus.doc} getRGFrmQuot
@author bolognesi
@since 08/12/2016
@version 1.0
@param oQuotation, object, Recebe uma instancia da classe CbcQuotation
@type method
@description Metodo para realizar o calculo do RG total, considerando todos
os itens do orçamento ora representado pelo objeto oQuotation
/*/
method getRGFrmQuot(oQuotation) class cbcProductValues
	Local cCodCust 		:= oQuotation:getCodeCustomer()
	Local cUnitCust 	:= oQuotation:getUnitCustomer() 
	Local oQuotSrv 		:= CbcQuotationService():newCbcQuotationService()
	Local nX			:= 0
	Local nQtdVen		:= 0
	Local nMinTotal		:= 0
	Local nSugTotal		:= 0
	Local nAppTotal		:= 0
	Local nCostTotal	:= 0
	Local nMinRg		:= 0
	Local nSugRg		:= 0
	Local nAppRg		:= 0
	Local cProdCod		:= ""
	Default oQuotation := Nil
	::oQuotRg := cbcRGValues():newcbcRGValues()
	::lOk 	:= .T.
	::cMsg	:= ""

	cId := IIF(Empty(oQuotation:getId()),"",oQuotation:getId())

	ConsoleLog('ID ' + cId + ' Meth:getRGFrmQuot()  Inicio ')
	aItms := oQuotation:getItems()
	For nX := 1 To Len(aItms)
		cProdCod := oQuotSrv:getProductCode(cCodCust, cUnitCust, aItms[nX], ,cId)
		ConsoleLog('ID ' + cId + ' Meth:getRGFrmQuot()  Var: cProdCod ' + cProdCod)
		If ! ::getCostProduct(cProdCod):lOk
			ConsoleLog('ID ' + cId + ' Meth:getRGFrmQuot() Erro custo ' + ::cMsg)
			exit
		Else
			nQtdVen 	:= aItms[nX]:getQuantity()
			ConsoleLog('ID ' + cId + ' Meth:getRGFrmQuot()  Var: QtdVendida ' + cValToChar(aItms[nX]:getQuantity()))
			nMinTotal 	+= aItms[nX]:getMinTotal()
			ConsoleLog('ID ' + cId + ' Meth:getRGFrmQuot()  Var: nMinTotal ' + cValToChar(aItms[nX]:getMinTotal()))
			nSugTotal 	+= aItms[nX]:getSugTotal()
			ConsoleLog('ID ' + cId + ' Meth:getRGFrmQuot()  Var: nSugTotal ' + cValToChar(aItms[nX]:getSugTotal()))
			nAppTotal 	+= aItms[nX]:getAppTotal()
			ConsoleLog('ID ' + cId + ' Meth:getRGFrmQuot()  Var: nAppTotal ' + cValToChar(aItms[nX]:getAppTotal()))
			nCostTotal 	+= (::nCostProduct * nQtdVen )
			ConsoleLog('ID ' + cId + ' Meth:getRGFrmQuot()  Var: nCostTotal ' + cValToChar((::nCostProduct * nQtdVen )) )
		EndIf
	Next nX

	If ::lOk
		ConsoleLog('ID ' + cId + 'Meth:getRGFrmQuot()  Obtendo os totais ')
		If nMinTotal > 0
			nMinRg 	:= (((nMinTotal * 100) / nCostTotal ) - 100)
			ConsoleLog('ID ' + cId + 'Meth:getRGFrmQuot()  Var: nMinRg ' + cValToChar(nMinRg) )
		EndIf
		If nSugTotal > 0
			nSugRg	:= (((nSugTotal * 100) / nCostTotal ) - 100)
			ConsoleLog('ID ' + cId + 'Meth:getRGFrmQuot()  Var: nSugRg ' + cValToChar(nSugRg) )
		EndIf
		If nAppTotal > 0
			nAppRg	:= (((nAppTotal * 100) / nCostTotal ) - 100)
			ConsoleLog('ID ' + cId + 'Meth:getRGFrmQuot()  Var: nAppRg ' + cValToChar(nAppRg) )
		EndIf
		ConsoleLog('ID ' + cId + ' Meth:getRGFrmQuot()  Finalizando ')
	EndIF

	ConsoleLog('ID ' + cId + ' Meth:getRGFrmQuot()  Obter valores do oQuotRg ')
	::oQuotRg:setFromAppTotal(Round(nAppRg,2))
	ConsoleLog('ID ' + cId + ' Meth:getRGFrmQuot()  Var: oQuotRg:nAppRg ' + cValToChar(::oQuotRg:getFromAppTotal()))
	::oQuotRg:setFromSugTotal(Round(nSugRg,2))
	ConsoleLog('ID ' + cId + ' Meth:getRGFrmQuot()  Var: oQuotRg:nSugRg ' + cValToChar(::oQuotRg:getFromSugTotal()))
	::oQuotRg:setFromMinTotal(Round(nMinRg,2))
	ConsoleLog('ID ' + cId + ' Meth:getRGFrmQuot()  Var: oQuotRg:nMinRg ' + cValToChar(::oQuotRg:getFromMinTotal()))

return (self)

/*/{Protheus.doc} getDlvFrmQuot
@author bolognesi
@since 09/01/2017
@version 1.0
@param oQuotation, object, Recebe uma instancia da classe CbcQuotation
@type method
@description Metodo que cria um array com os codigos de todos os produtos
de uma quotation, e envia ao metodo(dlvFromProd) que calcula data de entrega com base nestes produtos
/*/
method getDlvFrmQuot(oQuotation) class cbcProductValues
	local cCodCust 		:= Nil
	local cUnitCust 	:= Nil 
	local oQuotSrv 		:= Nil
	local nX			:= 0
	local cProdCod		:= ""
	local aProd			:= {}
	local nPrzCli		:= 0
	local nPrzVar		:= 0

	default oQuotation 	:= Nil

	cCodCust 			:= oQuotation:getCodeCustomer()
	cUnitCust 			:= oQuotation:getUnitCustomer() 
	oQuotSrv 			:= CbcQuotationService():newCbcQuotationService()
	::lOk 				:= .T.
	::cMsg				:= ""

	cId := IIF(Empty(oQuotation:getId()),"",oQuotation:getId())
	ConsoleLog('ID ' + cId + 'Meth:getDlvFrmQuot()  Inicio ')

	//Se o cliente tiver prazo de entrega considerar este
	::oArea:saveArea( {"SA1"} ) 
	nPrzCli := Posicione("SA1",1, xFilial("SA1") + LenX3Comp(cCodCust, 'A1_COD') +;
	LenX3Comp(cUnitCust, 'A1_LOJA'),"A1_PRZENTR")
	::oArea:backArea() 

	if nPrzCli > 0
		::setDlvDate(nPrzCli)
	else
		// REF: PRAZO DO VAREJO
		if ::getRetail()
			if ( nPrzVar := U_dtEntrVar() ) > 0
				::setDlvDate(nPrzVar)
			endif
		endif
		if nPrzVar == 0
			//Calcular o prazo de entrega com base nos produtos
			aItms := oQuotation:getItems()
			for nX := 1 To Len(aItms)
				cProdCod := oQuotSrv:getProductCode(cCodCust, cUnitCust, aItms[nX], ,oQuotation:getId())
				ConsoleLog('ID ' + cId + 'Meth:getDlvFrmQuot()  Var: cProdCod ' + cProdCod)
				AAdd(aProd,cProdCod )
			next nX
			if Empty(aProd)
				::lOk 	:= .F.
				// "Nenhum produto encontrado no objeto quotation cbcProductValues:getDlvFrmQuot()" 
				::cMsg 	:= "[ERRO] - CBC017"
				ConsoleLog(::cMsg)
			else
				::dlvFromProd(aProd)
				if !::lOk
					ConsoleLog('Para Quotation ID: ' + cId + ' identificado problemas ' + Alltrim(::cMsg) )
				else
					ConsoleLog('Para Quotation ID: ' + cId + ' a data de entrega calculada foi ' + AllToChar(::getDlvDate()))
				endIf
			endIF
		endif
	endIf
	FreeObj(oQuotSrv)
return (self)

/*/{Protheus.doc} getOthersCalc
@author bolognesi
@since 10/01/2017
@version 1.0
@param oQuotation, object, descricao
@param cWhat, characters, descricao
@type method
@description Metodo que obtem do objeto oQuotation
os totais: Peso Total, Desc. Medio, Media comissão
todos os calculos utilizados vieram do fonte CDFATR01
/*/
method getOthersCalc(oQuotation, cWhat) class cbcProductValues
	local oQuotSrv 		:= Nil
	local nX			:= 0
	local cProdCod		:= ""
	local nQtdVend		:= 0
	local nPrcApp		:= 0
	local nPrcSug		:= 0
	local nCommis		:= 0
	local nFxCommis		:= 0
	local nFxItmAprComm	:= 0
	local lIsFxAppComm	:= .F.
	local nAppCommis	:= 0
	local cCodCust		:= ""
	local cUnitCust		:= ""
	local cPayCond		:= ""
	local cFreight		:= ""
	local cAcond		:= ""
	local cId			:= ""
	local aItms			:= {}
	local _nPesoTot		:= 0
	local _nValAppTot	:= 0
	local _nTotAppCom	:= 0
	local _nTotAppVen	:= 0
	local _nValSugTot	:= 0
	local _nTotSugCom	:= 0
	local _nTotSugVen	:= 0
	local _nValTab		:= 0

	Default oQuotation 	:= Nil
	Default cWhat 		:= ""

	::lOk 				:= .T.
	::cMsg				:= ""
	::setTotalWeight()

	oQuotSrv 			:= CbcQuotationService():newCbcQuotationService()
	cCodCust 			:= oQuotation:getCodeCustomer()
	cUnitCust 			:= oQuotation:getUnitCustomer() 
	cPayCond			:= oQuotation:getPaymentCondition()
	cFreight			:= oQuotation:getFreight()
	nFxCommis			:= oQuotation:getFixedCommission()

	::setCliShop(cCodCust, cUnitCust)
	::setPayTerm(cPayCond)
	::setTpFreight(cFreight)

	cId := IIF(Empty(oQuotation:getId()),"",oQuotation:getId())
	ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Inicio ')
	::oArea:saveArea( {'SB1'} )

	aItms := oQuotation:getItems()

	for nX := 1 to len(aItms)
		cProdCod 		:= oQuotSrv:getProductCode(cCodCust, cUnitCust, aItms[nX], ,oQuotation:getId())
		nQtdVend		:= aItms[nX]:getQuantity()
		nPrcApp			:= if(empty(aItms[nX]:getAppPrice()),0,aItms[nX]:getAppPrice())
		nPrcSug			:= aItms[nX]:getSugPrice()

		//Obtem a questão de comissões fixas
		nFxItmAprComm 	:= if(empty(aItms[nX]:getAppCommission()),0,aItms[nX]:getAppCommission())
		lIsFxAppComm	:= aItms[nX]:isFixedCommission()

		ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Calculo Produto ' 	 + cProdCod)
		ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Preço Sugerido ' 	 + cValToChar(nPrcSug) )
		ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Preço Aprovado ' 	 + cValToChar(nPrcApp) )
		ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Quantidade Vendida ' + cValToChar(nQtdVend) )
		ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Comm Fixa no Item '  + cValToChar(nFxItmAprComm) )
		ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Flag Fixo '  + if(lIsFxAppComm, ' FIXO ', ' BRANCO ' ) )

		::setCodProd(cProdCod)
		::setPackaging( aItms[nX]:getIdPackage() + StrZero(aItms[nX]:getAmountPackage(), 5) )
		::setSoldAmount(nQtdVend) 

		//Somente calcula valores para preço aprovado quando não tiver situação fixa comissão
		if !lIsFxAppComm
			::setPrcApp(nPrcApp)
		endif
		::setPrcSug(nPrcSug)

		if ! ::initCalc():lOk
			ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Problemas ' + cProdCod + ' erro ' + ::cMsg)
			exit
		else	
			//Comissão Valor Aprovado
			//Fixa no Item
			if	lIsFxAppComm
				//Usa fixa
				nAppCommis := nFxItmAprComm
				//Fixa Header
			elseif !empty(nFxCommis)
				//Usa do Header
				nAppCommis := nFxCommis
				//Não esta fixa calcula
			else
				nAppCommis	:= if(empty(::nAppCommis),0,::nAppCommis)
			endif

			//Comissão valor Sugerido, quando não fixa header sempre obtem do calculo
			if !empty(nFxCommis)
				nCommis		:= nFxCommis
			else
				nCommis		:= ::nCommission
			endif

			ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Commissao Sugerida produto ' + cProdCod + " " + cValToChar(nCommis))
			ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Commissao Aprovado produto ' + cProdCod + " " + cValToChar(nAppCommis))

			_nPesoTot 	+= nQtdVend * Posicione("SB1",1,xFilial("SB1")+cProdCod,"B1_PESCOB")
			//Calculo do preço sugerido
			_nValSugTot 	+= aItms[nX]:getSugTotal()
			_nTotSugCom 	+= Round(((nQtdVend * nPrcSug) * nCommis) /100,2)
			ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Comissão Total Sugerido produto ' + cProdCod + " " +;
			'Round(((' + cValToChar(nQtdVend) + '*' +  cValToChar(nPrcSug) +') *' +  cValToChar(nCommis) + ') /100,2)' )
			_nTotSugVen  	+= (nQtdVend * nPrcSug)

			//Calculo do preço aprovado
			_nValAppTot 	+= aItms[nX]:getAppTotal()
			_nTotAppCom 	+= Round(((nQtdVend * nPrcApp) * nAppCommis) /100,2)
			ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Comissão Total Aprovado produto ' + cProdCod + " " +;
			'Round(((' + cValToChar(nQtdVend) + '*' +  cValToChar(nPrcApp) +') *' +  cValToChar(nAppCommis) + ') /100,2)' )

			_nTotAppVen  	+= (nQtdVend * nPrcApp)

			//Valor de tabela
			_nValTab += (nQtdVend * ::nPrice)

		endIf
	next nx

	if ::lOk
		ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  CALCULO MEDIA COMISSÂO TOTAL ' +;
		'Round((' + cValToChar(_nTotAppCom) + '/' + cValToChar(_nTotAppVen) + ') * 100,2)' )

		::setTotalWeight(_nPesoTot)
		ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Calculo Final  PESO_TOTAL ' + cValToChar(_nPesoTot))	

		//Medias do preço sugerido
		::setAvgSugDisc(Round((((_nValTab - _nValSugTot) / _nValTab) * 100),2))	
		ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Calculo Final  MÉDIA_DESCONTO Prc.Sug. ' +;
		cValToChar(Round((((_nValTab - _nValSugTot) / _nValTab) * 100),2)))

		::setAvgSugComm(Round((_nTotSugCom/_nTotSugVen) * 100,2))
		ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Calculo Final  MÉDIA_COMISSÂO Prc.Sug. ' +;
		cValToChar(Round((_nTotSugCom/_nTotSugVen) * 100,2)))

		//Medias do preço aprovado
		if _nValAppTot > 0
			::setAvgDiscApp(Round((((_nValTab - _nValAppTot) / _nValTab) * 100),2))	
			ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Calculo Final  MÉDIA_DESCONTO Prc.App. ' +;
			cValToChar(Round((((_nValTab - _nValAppTot) / _nValTab) * 100),2)))
		else
			::setAvgDiscApp()
		endif
		::setAvgCommApp(Round((_nTotAppCom/_nTotAppVen) * 100,2))
		ConsoleLog('ID ' + cId + 'Meth:getOthersCalc()  Calculo Final  MÉDIA_COMISSÂO Prc.App. ' +;
		cValToChar(Round((_nTotAppCom/_nTotAppVen) * 100,2)))
	endIf
	::oArea:backArea()
	FreeObj(oQuotSrv)
return(self)

/*/{Protheus.doc} getImpFrmQuot
@author bolognesi
@since 03/02/2017
@version 1.0
@param oQuotation, object, descricao
@type method
@description Metodo que recebe o objeto oquotation e realiza
o calculo para obter o IMP (Indice de Materia Prima), sendo o calculo
( ((peso cobre * XX_VLRCOB) / Total Vendido) * 100   )
/*/
method getImpFrmQuot(oQuotation) class cbcProductValues
	local oQuotSrv 		:= Nil
	local aItms			:= {}
	local cCodCust 		:= ""
	local cUnitCust 	:= "" 
	local nX			:= 0
	local cProdCod		:= ""
	local nQtdVend		:= 0
	local nPrcApp		:= 0
	local nPrcSug		:= 0
	local nPesCob		:= 0
	local nVlrPvc		:= 0
	local nTotVendApp	:= 0
	local nTotVendSug	:= 0
	local ImpApp		:= 0
	local ImpSug		:= 0
	local nVlrCob		:= GetNewPar('XX_VLRCOB', 21.70)

	oQuotSrv 			:= CbcQuotationService():newCbcQuotationService()
	cCodCust 			:= oQuotation:getCodeCustomer()
	cUnitCust 			:= oQuotation:getUnitCustomer() 

	cId := if(Empty(oQuotation:getId()),"",oQuotation:getId())
	ConsoleLog('ID ' + cId + 'Meth:getImpFrmQuot()  Inicio IMP ')
	aItms := oQuotation:getItems()

	for nX := 1 To Len(aItms)
		nQtdVend	:= aItms[nX]:getQuantity()
		nPrcApp		:= aItms[nX]:getAppPrice()
		nPrcSug		:= aItms[nX]:getSugPrice()
		cProdCod 	:= oQuotSrv:getProductCode(cCodCust, cUnitCust, aItms[nX],,cId)

		ConsoleLog('IMP - PROD_' + cValToChar(nX) + '.01 CodProduto: ' + cProdCod)
		ConsoleLog('IMP - PROD_' + cValToChar(nX) + '.02 TotVendApp: ' + cValToChar((nQtdVend * nPrcApp)))
		ConsoleLog('IMP - PROD_' + cValToChar(nX) + '.03 TotVendSug: ' + cValToChar((nQtdVend * nPrcSug)))

		nTotVendApp += (nQtdVend * nPrcApp)  
		nTotVendSug	+= (nQtdVend * nPrcSug)

		::oArea:saveArea( {'SB1'} )
		ConsoleLog('IMP - PROD_' + cValToChar(nX) + '.04 PesCob: ' + cValToChar((Posicione("SB1",1,xFilial("SB1")+ Padr( cProdCod, TamSx3('B1_COD')[1] ),"B1_PESCOB")* nQtdVend)))
		ConsoleLog('IMP - PROD_' + cValToChar(nX) + '.05 VlrPVC: ' + cValToChar((Posicione("SB1",1,xFilial("SB1")+ Padr( cProdCod, TamSx3('B1_COD')[1] ),"B1_VALPVC")* nQtdVend)))

		nPesCob 	+= (Posicione("SB1",1,xFilial("SB1")+ Padr( cProdCod, TamSx3('B1_COD')[1] ),"B1_PESCOB") * nQtdVend)
		nVlrPvc		+= (Posicione("SB1",1,xFilial("SB1")+ Padr( cProdCod, TamSx3('B1_COD')[1] ),"B1_VALPVC") * nQtdVend)
		::oArea:backArea()

	next nX
	ConsoleLog('TOTAIS_ IMP ID ' + cId)
	ConsoleLog('TOTAIS_ IMP ParamCobre ' + cValToChar(nVlrCob))

	if empty( nVlrCob )
		ImpApp		:= 0
		ImpSug		:= 0
	else
		ConsoleLog('TOTAIS_ IMP FORMULA CALCULO APROVADO =  ((( ( nPesCob * Indice ) + nVlrPvc  ) / nTotVendApp ) * 100)')
		ConsoleLog('TOTAIS_ IMP CALCULO APROVADO ' + "((( (" + cValToChar(nPesCob) + "*" + cValToChar(nVlrCob) +" ) + " + cValToChar(nVlrPvc) + ") /" + cValToChar(nTotVendApp) + " ) * 100)" )
		ConsoleLog('TOTAIS_ IMP FORMULA CALCULO SUGERIDO = ((( ( nPesCob * Indice ) + nVlrPvc  ) / nTotVendSug ) * 100)')
		ConsoleLog('TOTAIS_ IMP CALCULO SUGERIDO ' + "((( (" + cValToChar(nPesCob) + "*" + cValToChar(nVlrCob) +" ) + " + cValToChar(nVlrPvc) + ") /" + cValToChar(nTotVendSug) + " ) * 100)" )

		ImpApp		:= ((( ( nPesCob * nVlrCob ) + nVlrPvc  ) / nTotVendApp ) * 100)
		ImpSug		:= ((( ( nPesCob * nVlrCob ) + nVlrPvc  ) / nTotVendSug ) * 100) 
	endif

	ConsoleLog('TOTAIS_ IMP APROVADO ' + cValToChar(ImpApp))		
	ConsoleLog('TOTAIS_ IMP SUGERIDO ' + cValToChar(ImpSug))	

	::setImpApp(NoRound(ImpApp,2))
	::setImpSug(NoRound(ImpSug,2))

return(self)

/*/{Protheus.doc} dlvFromProd
@author bolognesi
@since 09/01/2017
@version 1.0
@param aProd, array, array contendo os codigos dos produtos
@type method
@description Recebe um array de produtos e devolve a data de entrega 
orientado pelos parametros
/*/
method dlvFromProd(aProd) class cbcProductValues
	Local nX 		:= 0
	Local _nPrz 	:= 0
	Local _nPrz2	:= 0
	local lNewPrz	:= GetNewPar('ZZ_NEWPRZ', .F.)
	
	::lOk 			:= .T.
	::cMsg			:= ""

	If !Empty(aProd)
		::oArea:saveArea( {"SB1"} ) 
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))

		For nX := 1 To Len(aProd)
			SB1->(DbSeek(xFilial("SB1") + LenX3Comp(aProd[nX], 'B1_COD') ,.F.))
			_nPrz2	:= 0
			if lNewPrz
				u_cbcAvalPrz(cFili, AllTrim(SB1->B1_COD), , , , @_nPrz2)
			else
				/*
				OBS: Trecho abaixo extraido do fonte M410LIOK em (09/01/17)
				não sou o autor deste trecho, caso necessario mudar aqui igualar 
				o M410LIOK:AvalPrz()
				*/
				If Left(SB1->B1_NOME,1) == "3"
					// Cabos controle - Alteração efetuada em 14/03/16 - Roberto, conforme solicitação via fone
					// do Crispilho. Enviado e-mail para ele para confirmar a regra utilizada, ou seja, todos os
					// Cabos controle independentemente da bitola tem o mesmo prazo de entrega.
					_nPrz2 := GetMv("MV_IFCPRZE")
				ElseIf SB1->B1_NOME == "199"
					// Se cabos coaxial
					_nPrz2 := GetMv("MV_IFCPRZ8")
				ElseIf SB1->B1_ESPECIA # "01" .Or. SB1->B1_NOME $ "117/118"
					// Se cabos especiais
					_nPrz2 := GetMv("MV_IFCPRZ2")
				ElseIf SB1->B1_NOME $ "120/121/122"
					// Se cabos PARALELOS/PARALELO POLARIZADO/TORCIDO
					_nPrz2 := GetMv("MV_IFCPRZ4")
				ElseIf SB1->B1_CLASENC == "1" .Or. SB1->B1_CLASENC == "2"
					// Se fios Sólidos ou cabos RIGIDOS
					_nPrz2 := GetMv("MV_IFCPRZ5")
				ElseIf SB1->B1_BITOLA $ "01/02/03/20"
					// Se bitola for <= a 1,00mm
					_nPrz2 := GetMv("MV_IFCPRZ1")
				ElseIf SB1->B1_NOME $ "103/111/119/182/183/184"
					// Atox 750v/ Superatox 750v/ Múltiplos Superatox 2,3,4 c 1Kv
					If SB1->B1_BITOLA <= "18" // Até 240 mm2
						_nPrz2 := GetMv("MV_IFCPRZC")
					Else // Demais bitolas 300 ao 500
						_nPrz2 := GetMv("MV_IFCPRZD")
					EndIf
				ElseIf Left(SB1->B1_NOME,2) $ "13/14/15/18"
					// Se cabos multiplos
					If SB1->B1_BITOLA >= "04" .And. SB1->B1_BITOLA <= "07" // DO 1,5 AO 6,0 MM2
						_nPrz2 := GetMv("MV_IFCPRZ3")
					ElseIf SB1->B1_BITOLA >= "08" .And. SB1->B1_BITOLA <= "15" // DO 10 ao 120 mm2
						_nPrz2 := GetMv("MV_IFCPRZA")
					Else
						// Este Else é somente para o caso de haver um erro
						_nPrz2 := Max(GetMv("MV_IFCPRZ3"),GetMv("MV_IFCPRZA"))
					EndIf
				ElseIf SB1->B1_CLASENC == "4" .Or. SB1->B1_CLASENC == "5"
					// Se cabos Flexiveis
					If SB1->B1_BITOLA >= "04" .And. SB1->B1_BITOLA <= "09" // 1,5 AO 16
						_nPrz2 := GetMv("MV_IFCPRZB")
					ElseIf SB1->B1_BITOLA >= "10" .And. SB1->B1_BITOLA <= "18" // 25 ao 240
						_nPrz2 := GetMv("MV_IFCPRZ7")
					Else // Demais bitolas 300 ao 500
						_nPrz2 := GetMv("MV_IFCPRZ6")
					EndIf
				EndIf
			endif
			If _nPrz2 == 0
				::lOk 			:= .F.
				::cMsg			:= "[ERRO]- Produto " + aProd[nX]  + " não possui regra para cálculo de data de entrega - Verifique" 
				ConsoleLog(::cMsg)
				exit
			Else
				_nPrz := Max(_nPrz2,_nPrz)
			EndIF
		Next nX
		If ::lOk
			::setDlvDate(_nPrz)
		EndIF

		::oArea:backArea() 
	EndIF
return (self)

/*/{Protheus.doc} getCalcFrmQuot
@author bolognesi
@since 09/12/2016
@version 1.0
@param oQuotation, object, Recebe uma instancia da classe CbcQuotation
@param cIntent, characters, O que fazer com objeto oQuotation? Ex(TOTAL_RG, MEDIA_COMISS)
@type function
/*/
method getCalcFrmQuot(oQuotation, aIntent) class cbcProductValues
	local nX		:= 0
	local nPos		:= 0
	local aMtr		:= {}
	local oSql		:= nil
	local cSeller	:= ""
	default aIntent := {}
	//O que esta classe sabe calcular com o Quotation?
	Aadd(aMtr,{'TOTAL_RG'		, {|self, oQuotation| self:getRGFrmQuot(oQuotation)  } })
	Aadd(aMtr,{'DATA_ENTREGA'	, {|self, oQuotation| self:getDlvFrmQuot(oQuotation) } })
	Aadd(aMtr,{'TOTAIS'			, {|self, oQuotation| self:getOthersCalc(oQuotation) } })
	Aadd(aMtr,{'IMP'			, {|self, oQuotation| self:getImpFrmQuot(oQuotation) } })

	::setRetail(if(oQuotation:isRetail(), .T., .F.))
	ConsoleLog('Meth:getCalcFrmQuot()  Inicio dos calculos ')

	if empty(::getSalesMan())
		ConsoleLog('Meth:getCalcFrmQuot()  Obtendo os dados do representante ')
		oSql := LibSqlObj():newLibSqlObj()
		cSeller := oSql:getFieldValue("ZP1", "ZP1_CODVEN", "%ZP1.XFILIAL% AND ZP1_CODIGO = '" + oQuotation:getIdUser() + "'") 
		::setSalesMan(cSeller)
		ConsoleLog('Meth:getCalcFrmQuot()  Codigo do representante ' + cSeller )
	endif

	for nX := 1 To Len(aIntent)
		nPos := AScan(aMtr,{|a| a[1] == aIntent[nX] })
		If nPos > 0
			ConsoleLog('Meth:getCalcFrmQuot()  Calculando ' + aMtr[nPos][1])
			Eval(aMtr[nPos][2], self,oQuotation )
		Else
			::lOk := .F.
			::cMsg += '[ERRO] - CBC018'
			ConsoleLog('CBC018 Meth:getCalcFrmQuot()  Erro ' + 'Comando :' + aIntent[nX] + 'não reconhecido' + chr(13))		
		EndIf
	next nX
return(self)

/*/{Protheus.doc} getPrcFrmRG
@author bolognesi
@since 07/12/2016
@version 1.0
@param nRg, numeric, RG desejado
@param nQtdVen, numeric, Quantidade vendida
@type method
@description Obter a partir de um RG qual o preço de venda adequado
para conseguir este RG
/*/
method getPrcFrmRG(nRg, nQtdVen, cCodPro) class cbcProductValues
	Local nItemCost		:= 0
	Local nItemPrice	:= 0
	Local nPrice		:= 0
	Default nRg			:= ""
	Default nQtdVen		:= ::nSoldAmount
	Default cCodPro		:= ::cCodProd 
	::lOk 	:= .T.
	::cMsg	:= "" 
	//'Classe:cbcProductValues Metodo:getPrcFrmRG(), parametros invalidos!'
	If ChkAnyEmpty({nRg, nQtdVen, cCodPro})
		::lOk	:= .F.
		::cMsg	:= '[ERRO] - CBC019' 
	Else
		If ::getCostProduct(cCodPro):lOk
			nPrice := (((nRg + 100) * ::nCostProduct) / 100)
		EndIf
	Endif
return	( Round(nPrice,4) )


/***************** STATICS ******************/
//TODO mover para classe de utils, expecifica tratar erro 
Static function HandleEr(oErr, oSelf)
	oSelf:lOk	:= .F.
	oSelf:cMsg	:= '[' +oErr:Description + ']' + chr(10) + chr(13) + oErr:ERRORSTACK
	BREAK
return

//TODO mover para classe de utils
//Verifica se existe elemento vazio em um array
Static function ChkAnyEmpty(aCheck)
	Local lRet	:= .F.
	Local nX	:= 0
	If !Empty(aCheck)
		For nX := 1 To Len(aCheck)
			If ValType(aCheck[nX]) != 'F'
				If Empty(aCheck[nX])
					lRet := .T.
					ConsoleLog('ChkAnyEmpty - Parametro obrigatorio faltando -> Chamada ' + ProcName(1) + ' Item ' + cValToChar(nX) + ' vazio')
					exit
				EndIf
			EndIf
		Next nX
	Else
		lRet := .T. 
	EndIf
return lRet

//TODO mover para classe de utils
//Adaptar um conteudo(xVlr) ao tamanho do campo (cCampo), preparando para dbseek 
Static function LenX3Comp(xVlr, cCampo)
	//TODO validar xVlr vazio e cCampo bem como cCampo exite no SX3
	Local xRet := ''
	Local aCmp	:= TamSx3(cCampo) 
	xRet := Padr(xVlr,aCmp[1] )
return xRet

/*/{Protheus.doc} getRegPar
@author bolognesi
@since 09/12/2016
@version undefined
@param cUf, characters, Estado do cliente
@type function
@description Função que recebe o estado do cliente e devolve
qual o percentual de desconto desta região para frete FOB.
/*/
static Function getRegPar(cUf)
	Local cNorte 	:= 'RO//AC//AM//RR//PA//AP//TO'
	Local cNordeste := 'MA//PI//CE//RN//PB//PE//AL//SE//BA'
	Local cSudeste	:= 'MG//ES//RJ//SP'                                                                                                        
	Local cSul		:= 'PR//SC//RS'
	Local cCOeste	:= 'MS//MT//GO//DF'
	Local nRet		:= 0
	If cUf $ cNorte
		nRet := GetNewPar('XX_NORTE'	, 0)
	ElseIf cUf $ cNordeste
		nRet := GetNewPar('XX_NORDEST'	, 0)
	ElseIf cUf $ cSudeste
		nRet := GetNewPar('XX_SUDESTE'	, 0)
	ElseIf cUf $ cSul
		nRet := GetNewPar('XX_SUL' 		, 0)
	ElseIf cUf $ cCOeste
		nRet := GetNewPar('XX_COESTE' 	, 0)
	EndIf  
return(nRet)

/*/{Protheus.doc} ConsoleLog
@author bolognesi
@since 29/11/2016
@version 1.0
@param cMsg, characters, Mensagem de erro
@type function
@description Utilizado para logar as mensagens de erro no console
/*/
static function ConsoleLog(cMsg)
	if GetNewPar('XX_DBGCONN', .T. )
		ConOut("[cbcProductValues - "+DtoC(Date())+" - "+Time()+" ] "+cMsg)
	EnDIf
return
