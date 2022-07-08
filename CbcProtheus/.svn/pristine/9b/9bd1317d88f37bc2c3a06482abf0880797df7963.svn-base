#include 'protheus.ch'
#define IPRECISION 53
#define ISCALE 5
#define  DESCONTO 1
#define  ADICIONAL 2

#define VALOR_DE		1 
#define VALOR_ATE		2
#define COND_PGTO1		3
#define COND_PGTO2		4 
#define ITEM_CARTA		5
#define DESCONTO		6
#define DESC_PADRAO		7
#define COMISSAO		8
#define COMISSAO_MINIMA 9
#define DESC_AVISTA		10
#define DESC_DIRETO		11 

#define FAM_PRODUTO		1
#define ADICIONAL		2

#define DESC_DIRETO		 1
#define FAIXAS_DESCONTO  2
#define FAIXA_DESCONTO	 1
#define FAIXA_DIRETA	 2

/*/{Protheus.doc} cbcDesc
@author bolognesi
@since 05/12/2016
@version 1.0
@description Clase utilizada para calcular os descontos em cascata
/*/
class cbcDesc 
	data nInitValue
	data nActValue
	data lOk
	data cMsg
	data cDescApl

	data cTabela
	data oVendedor
	data oCliente
	data oProduto

	data aDescontos
	data aAdicionais
	data aMatrizDesc

	method newcbcDesc() constructor 
	method getInitValue()
	method setInitValue()
	method getActValue()
	method setActValue()
	method addDesc()
	method getDirectDesc()
	method getDescApl()
	method calcFromStr()
	method getArrDesc()
	method getApplDesc()

	method getVendField()
	method setVendedor()
	method getCliField()
	method setCliente()
	method getTabela()
	method defTabela()
	method getDesconto()
	method getAdicional()
	method calcDesc()

	method addArr()

endclass


/*/{Protheus.doc} newcbcDesc
Metodo construtor
@author bolognesi
@since 05/12/2016 
@version 1.0
@description Metodo construtor 
/*/
method newcbcDesc(nInit) class cbcDesc
	Default nInit := 0
	::lOk 			:= .T.
	::cMsg 			:= ""
	::cDescApl		:= ""
	::aMatrizDesc		:= {}
	::setInitValue(nInit)
return (self)


method getVendField(cField) class cbcDesc
	local xRet 		:= ''
	default cField 	:= ''
	if !empty(cField)
		xRet := ::oVendedor:getField(cField) 
	endif
return(xRet)
method setVendedor(cCod) class cbcDesc
	default cCod := ''
	::oVendedor := cbcModVend():newcbcModVend(cCod)
return(self)


method getCliField(cField) class cbcDesc
	local xRet 		:= ''
	default cField 	:= ''
	if !empty(cField)
		xRet := ::oCliente:getField(cField) 
	endif
return(xRet)
method setCliente(cCod, cLoja) class cbcDesc
	default cCod 	:= ''
	default cLoja 	:= ''
	::oCliente 		:= cbcModClient():newcbcModClient(cCod, cLoja)
return(self)


method getTabela() class cbcDesc
return(::cTabela)

method defTabela() class cbcDesc
	local lCliConstru	:= Alltrim(::getCliField('A1_CONTRUT')) == 'S'
	local cTabCli		:= ::getCliField('A1_TABELA')
	local cTabVend		:= ::getVendField('A3_TABELA')
	::cTabela			:= ''

	if lCliConstru
		::cTabela := GetNewPar('XX_CONTAB', '8' )
	elseif empty(cTabCli)
		::cTabela := cTabVend
	else
		::cTabela := cTabCli
	endif 
	if !empty(::cTabela)
		::aDescontos 	:= {}
		::aAdicionais	:= {}
		::getDesconto()
		::getAdicional()
	endif

return(self)


method addArr(aReg, nArr) class cbcDesc
	local nPos		:= 0
	default aReg 	:= {}
	if !empty(aReg)
		if nArr == DESCONTO
			// TODO Não trazer itens repetidos do SZY (Modelagem ruim..)
			if (Ascan(::aDescontos,{|a| a[ITEM_CARTA] == aReg[ITEM_CARTA] }) == 0)
				aadd(::aDescontos, aReg)
			endif
		elseif nArr  == ADICIONAL
			aadd(::aAdicionais, aReg)
		endif
	endif
return(self)


method getAdicional()class cbcDesc
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local cQry		:= getQryAdic(Self)
	local aReg		:= {}
	local cFam		:= ''
	local cAdic		:= ''
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			cFam	:= oSql:getValue("FAM_PRODUTO")
			cAdic	:= oSql:getValue("ADICIONAL")
			aReg 	:= {cFam , cAdic }
			::addArr(aReg, ADICIONAL)
			oSql:skip()
		enddo
	endif
	oSql:close()  
	FreeObj(oSql)
return(self)


method getDesconto() class cbcDesc
	local oSql 	:= LibSqlObj():newLibSqlObj()
	local cQry	:= getQryDesc(Self)
	local aReg	:= {}
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			aReg := {oSql:getValue("VALOR_DE")	, oSql:getValue("VALOR_ATE"),;
			oSql:getValue("COND_PGTO1")			, oSql:getValue("COND_PGTO2"),;
			oSql:getValue("ITEM_CARTA")			, oSql:getValue("DESCONTO"),;
			oSql:getValue("DESC_PADRAO")		, oSql:getValue("COMISSAO"),;
			oSql:getValue("COMISSAO_MINIMA")	, oSql:getValue("DESC_AVISTA"),;
			oSql:getValue("DESC_DIRETO")   } 
			
			::addArr(aReg, DESCONTO)
			oSql:skip()
		enddo
	endif
	oSql:close()  
	FreeObj(oSql)
return(self)


method calcDesc(cCodProd,cAcond,nMtr,nPrcVend ) class cbcDesc
	local oProduto 	:= cbcModProduto():newcbcModProduto(cCodProd)
	local lPortal	:= .T.
	local cTab		:= ::getTabela()
	local nPrcTab	:= 0
	local aMtrz		:= {}
	oProduto:setAcond(cAcond)
	oProduto:setMtr(nMtr)
	nPrcTab := oProduto:getTabPrice(cTab, lPortal)
	oProduto:getFamily()

	// 01-) Matriz para os calculos
	descMatriz(Self)
	// 02-) Desconto aplicado entre Tabela e PrcVenda
	Alert(descApply(::aMatrizDesc, nPrcTab, nPrcVend))


	// 03-) Comissão PrcTabela, Comissão Minimo
	// 04-) Menor Valor possivel

	FreeObj(oProduto)
return(self)


/*/{Protheus.doc} getApplDesc
@author bolognesi
@since 06/12/2016
@version 1.0
@param nVlOri, numeric, Valor original ou valor Inicial
@param nVlAtu, numeric, Valor final ou valor Atual
@param cDesc, characters, Tabela de desconto base (70+40+13)
@type method
@description Metodo para identificar em um desconto o quanto da
tabela base foi aplicada, caso o aplicado deverá acrescentar descontos
a tabela base até zerar o valor.
/*/
method getApplDesc(nVlOri, nVlAtu, cDesc) class cbcDesc
return(self)

/*/{Protheus.doc} getArrDesc
@author bolognesi
@since 06/12/2016
@version 1.0
@param cStrDesc, characters, String no formato (Valor+Valor+Valor)
@type method
@description Metodo que recebe um string com os descontos Ex: (70+40+13)
realiza as validações e devolve um array numerico com os valores.{70,40,13}
/*/
method getArrDesc(cStrDesc) class cbcDesc
	Local aVlrDesc 		:= {}
	Local aRet			:= {}
	Local nQtdPlus	 	:= 0
	Local nX			:= 0
	Local lNotDig		:= .T.
	Default cStrDesc	:= ""
	::lOk := .T.
	::cMsg := ""

	If Empty(cStrDesc)
		::lOk := .F.
		::cMsg := "[ERRO]- Parametro obrigatorio!"
	Else
		nQtdPlus := U_contaChar(cStrDesc, '+')
		If nQtdPlus > 0
			//Existe varios valores para calcular desconto
			aVlrDesc := StrToKArr(cStrDesc,'+')
			//Verificar o preenchimento evitando  ( 70+20+15+, +70++70)
			If  nQtdPlus !=  (Len(aVlrDesc) - 1)
				::lOk := .F.
				::cMsg := "[ERRO] - String de desconto não esta no formato correto!"
			Else
				//Verificar se todos são numericos
				For nX := 1 To Len(aVlrDesc)
					If !IsDigit(aVlrDesc[nX])
						lNotDig := .F.
					EndIf
				Next nX
				If !lNotDig
					::lOk := .F.
					::cMsg := "[ERRO] - Existe valores que não são numericos!"
				Else
					//Aplicar os descontos
					For nX := 1 To Len(aVlrDesc)
						AAdd(aRet,Val(aVlrDesc[nX]))
					Next nX
				EndIf
			EndIf
		Else
			//Existe apenas um valor para calcular desconto
			If !IsDigit(cStrDesc)
				::lOk := .F.
				::cMsg := "[ERRO] - Valor informado não é numerico!"
			Else
				AAdd(aRet, cStrDesc)
			EndIf
		EndIf
	EndiF
return aRet

/*/{Protheus.doc} calcFromStr
@author bolognesi
@since 06/12/2016
@version 1.0
@param cStrDesc, characters, String no formato (Valor+Valor+Valor)
@type method
@description Classe que aplica o desconto contido no parametro cStrDesc
ao valor inicial
/*/
method calcFromStr(cStrDesc) class cbcDesc
	Local aVlrDesc	:= {}
	Local nX		:= 0
	Default cStrDesc := ""
	::lOk := .T.
	::cMsg := ""
	If ::getActValue() <= 0
		::lOk := .F.
		::cMsg := "[ERRO] - Valor atual não possibilita aplicação de descontos!"
	ElseIf Empty(cStrDesc)
		::lOk := .F.
		::cMsg := "[ERRO] - Informar o desconto é obrigatorio, para calula-lo!"
	Else
		aVlrDesc := ::getArrDesc(cStrDesc) 
		For nX := 1 To Len(aVlrDesc)
			::addDesc(aVlrDesc[nX])
		Next nX
	EndIf
return (self)

/*/{Protheus.doc} getDescApl
@author bolognesi
@since 06/12/2016
@version 1.0
@type method
@description Classe que retorna uma string com o desconto aplicado.
/*/
method getDescApl() class cbcDesc
return(::cDescApl)

/*/{Protheus.doc} getDirectDesc
@author bolognesi
@since 06/12/2016
@version 1.0
@type method
@description retorna o valor do desconto total aplicado
desconto direto
/*/
method getDirectDesc() class cbcDesc
	Local nDif		:= 0
	Local nVlCem	:= 0
	Local nVlMulCem	:= 0
	Local nVlDivCem	:= 0
	nDif 		:= (::getInitValue() - ::getActValue())
	nVlMulCem	:= (nDif *  100)
	nVlDivCem 	:= ( nVlMulCem / ::getInitValue() )
return (nVlDivCem)

/*/{Protheus.doc} addDesc
@author bolognesi
@since 06/12/2016
@version 1.0
@param nPerDesc, numeric, Valor do desconto a ser aplicado
@type method
@description Classe que aplica um determinado desconto (nPerDesc), ao valor 
inicial modificando o valor atual.
/*/
method addDesc(nPerDesc) class cbcDesc
	Local nVlDesc 	:= 0
	Local nVlDivCem	:= 0
	Local nVlMulCem	:= 0	

	Default nPerDesc := ""

	If ValType(nPerDesc) != 'N'
		::lOk := .F.
		::cMsg := "[ERRO] Para desconto, utilize apenas numeros!"
	ElseIf nPerDesc <= 0 
		::lOk := .F.
		::cMsg := "[ERRO] Favor informar a porcentagem para o desconto!"
	Else
		If ::getActValue() <= 0
			::lOk := .F.
			::cMsg := ""
		Else
			nVlDivCem 	:= (::getActValue() / 100)
			nVlMulCem	:= (nVlDivCem * nPerDesc)
			nVlDesc		:= (::getActValue() - nVlMulCem)
			::setActValue(nVlDesc)
			If Empty(::cDescApl)
				::cDescApl += cValToChar(nPerDesc)
			Else
				::cDescApl += '+' + cValToChar(nPerDesc) 
			EndIf
		EndIf
	EndIf
return (self)

/*/{Protheus.doc} setInitValue
@author bolognesi
@since 06/12/2016
@version 1.0
@param nVlr, numeric, Valor a ser definido como conteudo propriedade ::nInitValue
@type method
@description Definir o valor inicial para o inicio dos calculos, sempre que define-se
um valor inicial muda-se tambem o valor da propriedade ::nActValue, pois deve iniciar-se
um novo ciclo de calculos
/*/
method setInitValue(nVlr) class cbcDesc
	If ValType(nVlr) == 'N'   
		::nInitValue := nVlr
		::setActValue(nVlr)
		::cDescApl := ""
	Else
		::lOk := .F.
		::cMsg := "[ERRO] - Valor inicial tem que um numero!"
		::nInitValue := 0
	EndIf
return (self)

/*/{Protheus.doc} getInitValue
@author bolognesi
@since 06/12/2016
@version 1.0
@type method
@description metodo que retorna o conteudo da propriedade ::nInitValue
/*/
method getInitValue() class cbcDesc
return(::nInitValue)

/*/{Protheus.doc} setActValue
@author bolognesi
@since 06/12/2016
@version 1.0
@param nVlr, numeric, Valor a ser definido como conteudo propriedade ::nActValue
@type method
@description Metodo que define o valor da propriedade ::nActValue, e é esta propriedade
que recebe as atualizações de descontos aplicados pelo metodo ::addDesc()
/*/
method setActValue(nVlr) class cbcDesc
	If ValType(nVlr) == 'N'
		::nActValue := nVlr
	Else
		::lOk := .F.
		::cMsg := "[ERRO] - Valor inicial tem que um numero!"
		::nActValue := 0
	EndIf
return (self)

/*/{Protheus.doc} getActValue
@author bolognesi
@since 06/12/2016
@version 1.0
@type method
@description metodo que retorna o conteudo da propriedade ::nActValue
/*/
method getActValue() class cbcDesc
return( noRound(::nActValue,4) )


static function descMatriz(oSelf)
	local cFaixaDesc 	:= ''
	local nVlrBase		:= 1000.0000
	local nVlrAnt		:= 0
	local nVlrFixoBase	:= 1000.0000
	local aMtrz			:= {}
	local cFaixaDesc	:= '45+25+18+8+4'
	local aFaixaDesc	:= StrTokArr(cFaixaDesc, '+')
	local nProporcao	:= 0
	local nDescDireto	:= 0
	local nX			:= 0

	// TODO Definir qual faixa de desconto utilizar
	// oSelf:aAdicionais
	// oSelf:aDescontos

	for nX := 1 to Len(aFaixaDesc)
		nVlrAnt	:= nVlrBase 
		nVlrBase := (nVlrBase -(( nVlrBase/100) * Val(aFaixaDesc[nX])) )
		nProporcao	:= ((nVlrAnt - nVlrBase )*100) / nVlrFixoBase
		nDescDireto += nProporcao 
		Aadd(aMtrz, {aFaixaDesc[nX], nProporcao })
	next nX
	oSelf:aMatrizDesc := {nDescDireto,aMtrz} 
return(nil)

/*
	VALOR_DE		1 
	VALOR_ATE		2
	COND_PGTO1		3
	COND_PGTO2		4 
	ITEM_CARTA		5
	DESCONTO		6
	DESC_PADRAO		7
	COMISSAO		8
	COMISSAO_MINIMA 9
	DESC_AVISTA		10
	DESC_DIRETO		11 

	FAM_PRODUTO		1
	ADICIONAL		2
	*/

static function descApply(aMatrizDesc, nPrcTab, nPrcVend)
	local cFaixa		:= ''
	local aFaixa		:= {}
	local nDescCalcDir	:= 0
	local nAuxCalc		:= 0
	local nDescFaixaDir	:= 0
	local nFaixParc		:= 0
	local aMtrzFaixa	:= {}
	local nX			:= 0
	default aMatrizDesc	:= {}
	default nPrcTab 	:= 0
	default nPrcVend 	:= 0

	if (nPrcTab > 0) .And. (nPrcVend > 0) .And. !Empty(aMatrizDesc) 
		nDescCalcDir  	:= (((nPrcTab - nPrcVend )*100) / nPrcTab) 
		nDescFaixaDir 	:= aMatrizDesc[DESC_DIRETO]
		aMtrzFaixa		:= aMatrizDesc[FAIXAS_DESCONTO]

		// Desconto calculado é maior que desconto direto da faixa
		if nDescCalcDir >= nDescFaixaDir 
			// Utilizado a faixa inteira
			for nX := 1 to Len(aMtrzFaixa)
				Aadd(aFaixa, aMtrzFaixa[nX,FAIXA_DESCONTO] )
			next nX
			// Mais a diferença entre os descontos diretos
			Aadd(aFaixa, cValToChar(nDescCalcDir - nDescFaixaDir) )
		else
			// Desconto claculado é menor que a primeira faixa de desconto
			if nDescCalcDir < aMtrzFaixa[1,FAIXA_DIRETA]
				// Não chega a usar a faixa usa apenas o direto
				Aadd(aFaixa, cValToChar(nDescCalcDir) )		
			else
				// Identificar o quanto da faixa foi utilizado
				for nX := 1 to Len(aMtrzFaixa)
					nAuxCalc := nDescCalcDir 
					
					// Utilizou faixa completa
					if (nDescCalcDir := ( nDescCalcDir - aMtrzFaixa[nX,FAIXA_DIRETA] )) >= 0
						Aadd(aFaixa, aMtrzFaixa[nX,FAIXA_DESCONTO])
					else
						// Utilizou parte da faixa (identificar o quanto da faixa utilizou)
						nFaixParc := ( nAuxCalc * Val(aMtrzFaixa[nX,FAIXA_DESCONTO]) ) / aMtrzFaixa[nX,FAIXA_DIRETA] 
						Aadd(aFaixa, cValToChar(nFaixParc) )
						exit
					endif
				next nX
			endif
		endif
		// Monta a string retorno
		for nX := 1 to len(aFaixa)
			cFaixa += aFaixa[nX]
			if nX != len(aFaixa)
				cFaixa += '+'
			endif
		next nX
	endif
return(cFaixa)


/*/{Protheus.doc} getQryAdic
@author bolognesi
@since 05/09/2017
@version undefined
@param oSelf, object, Objeto da classe cbcDesc
@type function
@description Query que obtem os adicionais de desconto para um tabela de preço
/*/
static function getQryAdic(oSelf)
	local cQry 		:= ''
	local cTabela 	:= oSelf:getTabela()
	local cRegVend	:= Alltrim(oSelf:getVendField('A3_REGIAO'))

	if !empty(cTabela)
		cQry += " SELECT  
		cQry += " SZW.ZW_FAMILIA AS FAM_PRODUTO,  "
		cQry += " SZW.ZW_ADICION AS ADICIONAL  "
		cQry += " FROM %SZW.SQLNAME%  "
		cQry += " WHERE  "
		cQry += " %SZW.XFILIAL% "
		cQry += " AND SZW.ZW_TABELA = '" + 	cTabela + "'"
		cQry += " AND (SZW.ZW_REGIAO = '" + cRegVend + "' OR SZW.ZW_REGIAO = '' )"
		cQry += " AND %SZW.NOTDEL%"
		cQry += " ORDER BY SZW.ZW_REGIAO, SZW.ZW_FAMILIA "
	endif
return(cQry)


/*/{Protheus.doc} getQryDesc
@author bolognesi
@since 05/09/2017
@version undefined
@param oSelf, object, Objeto da classe cbcDesc
@type function
@description Query que obtem os descontos para uma tabela de preço
/*/
static function getQryDesc(oSelf)
	local cQry := ''
	local cTabela := oSelf:getTabela()
	if !empty(cTabela)
		cQry += " SELECT "
		cQry += " SZX.ZX_VLRINI		AS VALOR_DE, "
		cQry += " SZX.ZX_VLRFIM		AS VALOR_ATE, "
		cQry += " SZX.ZX_CONDPG1	AS COND_PGTO1, "
		cQry += " SZX.ZX_CONDPG2	AS COND_PGTO2, "
		cQry += " SZY.ZY_ITEM		AS ITEM_CARTA, "
		cQry += " SZY.ZY_DESCONT	AS DESCONTO, "
		cQry += " SZY.ZY_DESCPAD	AS DESC_PADRAO, "
		cQry += " SZY.ZY_COMIS		AS COMISSAO, "
		cQry += " SZY.ZY_CMMIN		AS COMISSAO_MINIMA, "
		cQry += " SZY.ZY_DESCVIS	AS DESC_AVISTA, "
		cQry += " SZY.ZY_DESCDIR	AS DESC_DIRETO "	 
		cQry += " FROM %SZX.SQLNAME%  "
		cQry += " INNER JOIN %SZY.SQLNAME% ON "
		cQry += " SZX.ZX_FILIAL	= SZY.ZY_FILIAL "
		cQry += " AND SZX.ZX_CARTA	 = SZY.ZY_CODIGO " 
		cQry += " AND SZX.D_E_L_E_T_ = SZY.D_E_L_E_T_ "
		cQry += " WHERE
		cQry += " %SZX.XFILIAL% "
		cQry += " AND SZX.ZX_CODTAB	= '" + cTabela + "' " 
		cQry += " AND %SZX.NOTDEL% "
	endif
return(cQry)


/* TESTE UTILIZAÇÂO 01*/
user function zcbcDsc()
	local oDesc 	:= cbcDesc():newcbcDesc()
	local _cDescs  	:= u_ClcDesc('11 ','010   ','1150504401     ',0.8522, 2.2666, 'N')

	oDesc:setVendedor('010')
	oDesc:setCliente('000001', '01')
	oDesc:defTabela()
	oDesc:calcDesc('1150504401','R',100, 3.8522)


return(nil)

/* TESTE UTILIZAÇÂO 02*/
user function zcbcDesc()
	local cMsg	:= ''
	local oDesc := cbcDesc():newcbcDesc(43.428)
	oDesc:addDesc(70)
	oDesc:addDesc(40)
	oDesc:addDesc(15)
	oDesc:addDesc(11)

	cMsg += 'Valor Incicial.........' + cValToChar(oDesc:getInitValue()) + chr(13)
	cMsg += 'Valor apos desconto:...'+ cValToChar(oDesc:getActValue()) + chr(13)   
	cMsg +='Desconto direto.......' + cValToChar(oDesc:getDirectDesc()) + '% ' + chr(13) 
	cMsg +='Desconto aplicado.....' + cValToChar(oDesc:getDescApl())
	Alert(cMsg)

	cMsg	:= ''
	oDesc:setInitValue(43.428)
	if ! oDesc:calcFromStr('70+40+15+11'):lOk
		cMsg := oDesc:cMsg 
	else
		cMsg += 'Valor Incicial.........' + cValToChar(oDesc:getInitValue()) + chr(13)
		cMsg += 'Valor apos desconto:...'+ cValToChar(oDesc:getActValue()) + chr(13)   
		cMsg +='Desconto direto.......' + cValToChar(oDesc:getDirectDesc()) + '% ' + chr(13) 
		cMsg +='Desconto aplicado.....' + cValToChar(oDesc:getDescApl())
	endIf

	Alert(cMsg)

return(nil)
