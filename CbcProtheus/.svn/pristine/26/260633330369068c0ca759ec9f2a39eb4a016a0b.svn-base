#include 'protheus.ch'

/*/{Protheus.doc} cbcProductDetails
(long_description)
@author bolognesi
@since 09/09/2016
@version 1.0
@description Classe para auxiliar as rotinas do portal na validação e obtenção dos dados que compoem um item.
/*/
class cbcProductDetails 

	method newcbcProductDetails() constructor 
	data oCmbResp		//Objeto retornado ao portal
	data cCodCli		//Codigo do cliente
	data cLojaCli		//Loja do cliente  
	data lRetail		//Identifica se a venda é varejo
	data lUsrEsp		//Definicao se cliente é especial
	data nCliMenorBob	//Menor bobina cliente aceita 
	data nCliMaiorBob	//Maior bobina cliente aceita
	data lCoilRule		//Identifica se o cliente tem restrição de bobinas

	method getProducts()
	method getGauges()
	method getPackagings()
	method getColorsSpec()
	method getClsStrings()
	method getSpecialtys()

	method getCoilType()
	method cliCoilAccept()
	method defAcceptRangeCoils()

	method getCodCli()
	method setCodCli()
	method getLojaCli()
	method setLojaCli()
	method getRetail()
	method setRetail()
endclass

/*/{Protheus.doc} newcbcProductDetails
Metodo construtor
@author bolognesi
@since 09/09/2016 
@version 1.0
@example
Local oProdDet := cbcProductDetails:newcbcProductDetails(cCodCli, cLojaCli, lVarejo)
@description Classe construtora que recebe Codigo e Loja do Cliente, e inicia o tratamento
/*/
method newcbcProductDetails(cCodCli, cLojaCli, lVarejo, lUsrEsp) class cbcProductDetails
	default cCodCli 	:= ""
	default cLojaCli 	:= ""
	default lVarejo		:= .F.
	default lUsrEsp		:= .F.
	::setRetail(lVarejo)
	::oCmbResp := cbcComboResp():newcbcComboResp()
	::lUsrEsp  := lUsrEsp
	/*08/05/17 - Bobina Cliente */
	//::setCodCli(cCodCli)
	//::setLojaCli(cLojaCli)
	//if !empty(cCodCli) .and. !empty(cLojaCli)
	//	::defAcceptRangeCoils()
	// endif
	/*08/05/17 - Bobina Cliente */

return (self)

/******************  GET  *************************/
//Obter os possiveis produtos(Familia)
method getProducts() class cbcProductDetails 		
	local cQry 		:= ""
	local oVarejo	:= nil
	
	if ::getRetail()
		oVarejo := cbcVarejoProduto():newcbcVarejoProduto()
		cQry 	:= oVarejo:getFamQry()
		FreeObj(oVarejo)
	else
		cQry += " SELECT DISTINCT Z1_COD    AS 						 ID, "
		cQry += " Z1_NOME					AS						TEXT "
		cQry += " FROM " + RetSqlName('SB1') + " SB1 					 "
		cQry += " INNER JOIN " + RetSqlName('SZ1') +  " SZ1  			 "
		cQry += "	ON B1_FILIAL			= Z1_FILIAL 				 "
		cQry += "	AND B1_NOME				= Z1_COD 					 "
		cQry += "	AND SB1.D_E_L_E_T_		= SZ1.D_E_L_E_T_ 		 	 "
		cQry += " WHERE 												 "
		cQry += "	B1_FILIAL				= '" + xFilial("SB1") +"' 	 "
		// cQry += "	AND B1_XPORTAL			= 'S' 						 "
		cQry += "	AND B1_XPORTAL " + iif(::lUsrEsp,"IN ('S','E')","= 'S' ")
		cQry += "	AND B1_MSBLQL			<> '1' 						 "
		cQry += "	AND SB1.D_E_L_E_T_	= '' 						 "
		cQry += " 	ORDER BY Z1_COD	 					 				 "
	endif

	qry(cQry, self, 'PROD')
return (self)

//Obter as possiveis bitolas
method getGauges(cCod) class cbcProductDetails		
	local cQry 		:= ""
	local oVarejo	:= nil
	Default cCod 	:= ""

	If Empty(cCod)
		::oCmbResp:lOk := .F.
		::oCmbResp:cMsg := "[ERRO] - CBC100" //"Para obter as bitolas, informe um codigo familia"
	Else
		if ::getRetail()
			oVarejo := cbcVarejoProduto():newcbcVarejoProduto()
			cQry 	:= oVarejo:getGauQry(cCod)
			FreeObj(oVarejo)
		else
			cQry += " SELECT DISTINCT Z2_COD  	AS ID,						" 
			cQry += " Z2_DESC					AS TEXT,					"
			cQry += "'"+ Alltrim(cCod) + "' 	AS PROD						"		 
			cQry += " FROM " +  RetSqlName('SB1') + " SB1 					"
			cQry += " INNER JOIN " + RetSqlName('SZ2') + " SZ2 				"
			cQry += " ON B1_FILIAL				= Z2_FILIAL 				"
			cQry += " AND B1_BITOLA				= Z2_COD 					"
			cQry += " AND SB1.D_E_L_E_T_		= SZ2.D_E_L_E_T_ 			"
			cQry += " WHERE 												"
			cQry += " B1_FILIAL					= '" + xFilial('SB1') + "' 	"
			cQry += " AND B1_COD				LIKE '" + cCod + "%'		"
			cQry += " AND B1_XPORTAL " + iif(::lUsrEsp,"IN ('S','E')","= 'S' ")
			cQry += " AND B1_MSBLQL				<> '1' 						"
			cQry += " AND SB1.D_E_L_E_T_		= '' 						"
			cQry += " 	ORDER BY Z2_COD	 					 				"
		endif	

		qry(cQry, self, 'GAUGE')
	endIf
return (self)

//Obter os possiveis acondicionamentos
method getPackagings(cCod, cBitola) class cbcProductDetails		
	local 	cQry 		:= ""
	local   oRet		:= {}
	local nX			:= 0
	local oCmb			:= nil
	local cKeyQry		:= ""
	local oVarejo		:= nil
	default cCod 		:= ""
	default cBitola		:= ""


	If Empty(cCod) .Or. Empty(cBitola)
		::oCmbResp:lOk := .F.
		::oCmbResp:cMsg := "[ERRO] - CBC101" //"Para obter as cores, informar Codigo Familia e Bitola"
	Else
		cKeyQry := (cCod + cBitola)

		if ::getRetail()
			oVarejo := cbcVarejoProduto():newcbcVarejoProduto()
			cQry 	:= oVarejo:getPacQry(cKeyQry)
			FreeObj(oVarejo)
		else
			//*********** ACONDICIONAMENTOS
			cQry += " 	SELECT	ZZZ_ACOND 	AS ACOND, 					" 
			cQry += " 	ZZZ_VLRMTR 			AS MTR, 					"
			cQry += " 	ZZZ_PROD 			AS FAM, 					"
			cQry += " 	ZZZ_BITOLA 			AS BIT 						"
			cQry += " FROM " +  RetSqlName('ZZZ')
			cQry += " 	WHERE  											"
			cQry += " ZZZ_FILIAL = '" + xFilial('ZZZ') + "' 			"
			cQry += " 	AND ZZZ_TIPO = 'MTR'	"
			cQry += " 	AND ZZZ_PROD + ZZZ_BITOLA = '" + cKeyQry +		"'"
			cQry += " 	AND ZZZ_ACOND IN (								"
			cQry += " 		SELECT ZZZ_ACOND FROM " + RetSqlName('ZZZ')
			cQry += " 		WHERE 										"
			cQry += " 		ZZZ_FILIAL = '" + xFilial('ZZZ') + 			"'"
			cQry += " 	    AND ZZZ_TIPO = 'MTR'	"
			cQry += " 		AND ZZZ_PROD + ZZZ_BITOLA = '" + cKeyQry + 	"'"
			cQry += " 		AND D_E_L_E_T_ <> '*'						"
			cQry += " 	)												"
			cQry += " 	AND D_E_L_E_T_ <> '*'							"
		endif
		qry(cQry, self, 'PACKFOOTAGE')

		If ! ::oCmbResp:lOk
			//::oCmbResp:cMsg
		Else
			/* 08/05/17 - Bobina Cliente */
			//::cliCoilAccept(cCod + cBitola)

			//*********** ESPECIALIDADES
			::getSpecialtys(cCod,cBitola)

			//********** COR ESPECIALIDADES
			::getColorsSpec(cCod, cBitola)
		EndIf
	EndIf
return (self)

//Obter as Cores de cada especialidade
method getColorsSpec(cCod, cBitola) class cbcProductDetails
	local 	cQry 		:= ""
	local 	oCmb		:= nil
	local oVarejo		:= nil
	Default cCod 		:= ""
	Default cBitola		:= ""

	If Empty(cCod) .Or. Empty(cBitola)
		::oCmbResp:lOk := .F.
		::oCmbResp:cMsg := "[ERRO] - CBC102" //"Para obter as cores, informar Codigo Familia, Bitola"
	Else
		cQry += " SELECT DISTINCT B1_ESPECIA	AS ESP, 	" 
		cQry += " 		Z3_COD  	 	AS ID , 			"										 
		cQry += " 		Z3_DESC		 	AS TEXT,			"										
		cQry += " 		B1_BLQVEN		AS APROVA			"
		cQry += " FROM " +  RetSqlName('SB1') + " SB1		"										
		cQry += " INNER JOIN " + RetSqlName('SZ3') + " SZ3	"								
		cQry += " ON B1_FILIAL			= Z3_FILIAL  		"
		cQry += " AND B1_COR			= Z3_COD  			"
		cQry += " AND SB1.D_E_L_E_T_	= SZ3.D_E_L_E_T_ "									
		cQry += " WHERE										"							
		cQry += " B1_FILIAL	= '" + xFilial('SB1') + "'		"					
		cQry += " AND B1_COD			LIKE '" + Alltrim(cCod) + Alltrim(cBitola) + "%'"
		cQry += " AND B1_XPORTAL " + iif(::lUsrEsp,"IN ('S','E')","= 'S' ")
		cQry += " AND Z3_XPORTAL " + iif(::lUsrEsp,"IN ('S','E')","= 'S' ")
		cQry += " AND B1_MSBLQL			<> '1'				"									
		cQry += " AND SB1.D_E_L_E_T_	= ''				"			
		cQry += " ORDER BY Z3_COD	  						"
		qry(cQry, self, 'COLORSPEC')
		
		if ::getRetail()
			oVarejo := cbcVarejoProduto():newcbcVarejoProduto()
			cQry 	:= oVarejo:getColQry(Alltrim(cCod) + Alltrim(cBitola))
			FreeObj(oVarejo)
			qry(cQry, self, 'COLORACOND')
		else
			AcondCor(self,cCod,cBitola)
		endif
	
	endif
return (self)

//Obter as classes de encordoamento
method getClsStrings(cCod,cBitola,cCor,cEsp) class cbcProductDetails
	Local 	cQry 		:= ""
	default cCod 		:= ""
	default cBitola		:= ""
	default cCor		:= ""
	default cEsp		:= ""

	if empty(cEsp)
		cEsp := '01'
	endif

	If Empty(cCod) .Or. Empty(cBitola) .Or. Empty(cCor)
		::oCmbResp:lOk := .F.
		::oCmbResp:cMsg := "[ERRO] - CBC103" //"Para obter a classe encordoamento, informar Codigo Familia , Bitola, especialidade"
	Else

		/*
		09/01/17 - Obter a classe do codigo do produto, pois em alguns casos
		os campos B1_CLASENC estão diferente do conteudo do codigo do produto
		query para verificar:
		SELECT * FROM SB1010 WHERE B1_FILIAL = ''AND B1_TIPO = 'PA' AND B1_CLASENC <> SUBSTRING(B1_COD,8,1) AND D_E_L_E_T_	= ''

		cQry += "	SELECT  B1_CLASENC AS CLASSE		" 
		*/

		cQry += " 	SELECT SUBSTRING(B1_COD,8,1) AS CLASSE"	
		cQry += "	FROM " + RetSqlName('SB1') + " SB1	"
		cQry += "	WHERE				"
		cQry += "	B1_FILIAL	= '" + xFilial('SB1') + "'	"
		cQry += " 	AND B1_COD	LIKE '" + Alltrim(cCod) + Alltrim(cBitola) + Alltrim(cCor) + "%'"
		cQry += "	AND B1_ESPECIA	= '" + cEsp + "'"
		//cQry += "	AND B1_CLASENC = SUBSTRING(B1_COD,8,1) "	
		cQry += "	AND B1_XPORTAL IN ('S','E')"
		cQry += " 	AND B1_MSBLQL			<> '1'	"
		// cQry += "   AND B1_BLQVEN			<> 'S'	"
		cQry += "	AND SB1.D_E_L_E_T_	= ''	"
		cQry += "	ORDER BY B1_CLASENC DESC "
		//conout('[DBG-VLR-PRD]-03-query obter produto ' + cQry )
		qry(cQry, self, 'CLASENC')

	EndIf 
return (self)

//Obter as especialidades
method getSpecialtys(cCod,cBitola) class cbcProductDetails		
	Local 	cQry 		:= ""
	Default cCod 		:= ""
	Default cBitola		:= ""

	If Empty(cCod) .Or. Empty(cBitola)
		::oCmbResp:lOk := .F.
		::oCmbResp:cMsg := "[ERRO] - CBC104" //"Para obter as especialidades, informar Codigo Familia e Bitola"
	Else
		if ::getRetail()
			oCmb := cbcComboItem():newcbcComboItem()
			oCmb:setID('01')
			oCmb:setText('PRODUTO NORMAL DE LINHA')
			::oCmbResp:addSpecialtys(oCmb)
		else		
			cQry += "	SELECT DISTINCT Z4_COD    AS 	ID, 		"
			cQry += "	Z4_DETALHE				  AS	TEXT 		" 
			cQry += "	FROM " + RetSqlName('SB1') + " SB1 			"		
			cQry += "	INNER JOIN " + RetSqlName('SZ4') + " SZ4 	"			 
			cQry += "	ON B1_FILIAL			= Z4_FILIAL 		"			 
			cQry += "	AND B1_ESPECIA			= Z4_COD 			"			 
			cQry += "	AND SB1.D_E_L_E_T_	= SZ4.D_E_L_E_T_ 		"		 
			cQry += "	INNER JOIN " +  RetSqlName('SZ3') + " SZ3	" 										 
			cQry += "	ON B1_FILIAL			= Z3_FILIAL  		" 
			cQry += "	AND B1_COR				= Z3_COD  			"
			cQry += "	AND SB1.D_E_L_E_T_	= SZ3.D_E_L_E_T_ "	
			cQry += "	WHERE 										"		 
			cQry += "	B1_FILIAL				= '" + xFilial('SB1') + "' 		"		 
			cQry += " 	AND B1_COD	LIKE '" + Alltrim(cCod) + Alltrim(cBitola)  + "%'"
			cQry += "	AND B1_XPORTAL IN ('S','E') "
			cQry += "	AND Z3_XPORTAL IN ('S','E') "
			cQry += "	AND B1_MSBLQL			<> '1' 				"		  
			cQry += "	AND SB1.D_E_L_E_T_	= '' 				"		 
			cQry += "	ORDER BY Z4_COD 							"
			qry(cQry, self, 'SPECIALTYS')
		endif	
	EndIf
return (self)

// GET/SET Propriedade cCodCli 
method getCodCli() class cbcProductDetails	
return(::cCodCli)

method setCodCli(cCod) class cbcProductDetails	
	default cCod := ''
	::cCodCli := Padr(cCod,TamSx3("A1_COD")[1] )
return(self)

// GET/SET Propriedade cLojaCli
method getLojaCli() class cbcProductDetails	
return(::cLojaCli)

method setLojaCli(cLoja) class cbcProductDetails	
	default cLoja := ''
	::cLojaCli := Padr(cLoja,TamSx3("A1_LOJA")[1] )
return(self)

/*/{Protheus.doc} getCoilType
@author bolognesi
@since 08/05/2017
@version 1.0
@type method
@description Função que obtem para um produto e cliente o tipo de 
bobina que deve ser utilizada. Realiza a chamada interna para função
legado:CalcBob do fonte: CDESTR03.prw, a função legado:CalcBob, foi
ajustada para realizar a busca com Familia+Bitola, e não o codigo inteiro
alteração realizada por Roberto(05/05/17)
/*/
method getCoilType(cFamBit, cMtr) class cbcProductDetails
	local bErro
	local nType		:= 0
	local cCodCli	:= ::getCodCli()
	local cLojaCli 	:= ::getLojaCli()
	local lTpRet	:= .F.
	default cFamBit	:= "" 
	default cMtr	:= ""
	cFamBit := Padr(cFamBit, TamSx3('B1_COD')[1] )
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, self)})
	// Validações campos vazios

	BEGIN SEQUENCE
		ConsoleLog("U_CalcBob('" + cFamBit + "','" + cMtr + "','" + if(lTpRet,'.T.','.F.' ) + "','" + cCodCli + "','" + cLojaCli + "')"  )
		nType := U_CalcBob(cFamBit, cMtr, lTpRet, cCodCli, cLojaCli )	
		RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
return(nType)
/******************  GET  *************************/

/*/{Protheus.doc} defAcceptRangeCoils
@author bolognesi
@since 08/05/2017
@version 1.0
@type method
@description Definir se o cliente possuem alguma restrição 
de tipo de bobina.
/*/
method defAcceptRangeCoils() class cbcProductDetails
	local cCli 		:= ::getCodCli()
	local cLoja 	:= ::getLojaCli()
	local oSql   	:= nil
	::lCoilRule		:= .F.
	::nCliMenorBob	:= "" 
	::nCliMaiorBob	:= ""

	oSql := LibSqlObj():newLibSqlObj()
	cQuery := " SELECT A1_MENORBB MENOR, A1_MAIORBB MAIOR "
	cQuery += " FROM %SA1.SQLNAME% "
	cQuery += " WHERE %SA1.XFILIAL% "
	cQuery += " AND A1_COD = '" +  cCli + "'"
	cQuery += " AND A1_LOJA = '" + cLoja + "'" 
	cQuery += " AND (A1_MENORBB > 0 AND A1_MAIORBB > 0) "
	cQuery += " AND A1_MSBLQL = 2 "  
	cQuery += " AND %SA1.NOTDEL% " 
	oSql:newAlias( cQuery )
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()		
			::lCoilRule 	:= .T.
			::nCliMenorBob	:= oSql:getValue("MENOR") 
			::nCliMaiorBob	:= oSql:getValue("MAIOR")
			oSql:skip()
		enddo
	else	
	endif
	oSql:close()  
	FreeObj(oSql)
return(self)

/*/{Protheus.doc} cliCoilAccept
@author bolognesi
@since 08/05/2017
@version 1.0
@type method
@description Quando o cliente tem restrição de bobina 
(lCoilRule = .T. ) verifica se o cliente aceita o tipo de
bobina definido pela função legado:U_CalcBob 
chamada pelo metodo:getCoilType()
Como?: Verificando se o valor retornado getCoilType() esta
contido entre os campos A1_MENORBB e A1_MAIORBB
/*/
method cliCoilAccept(cFamBit) class cbcProductDetails
	local lRet 	:= .T.
	local nCoil := 0
	local nX	:= 0
	local nY	:= 0
	local cMtr	:= ""

	if ::lCoilRule	

		for nX := 1 to len(::oCmbResp:AOBJPKFTAGE)
			if ::oCmbResp:AOBJPKFTAGE[nX]:CPACKAGE == 'B'
				for nY := 1 to len(::oCmbResp:AOBJPKFTAGE[nX]:AFOOTAGE)
					cMtr :=  ::oCmbResp:AOBJPKFTAGE[nX]:AFOOTAGE[nY]
					//TODO Aqui obtemos a bobina da função legado
					nCoil := ::getCoilType(cFamBit, cMtr)
				next nY
			endif
		next nX	
		//TODO realizar a comparação
		//::nCliMenorBob
		//::nCliMaiorBob
	endif

return(lRet)

/*/{Protheus.doc} getRetail
@author bolognesi
@since 17/07/2017
@version 1.0
@type method
@description obter o conteudo da propriedade ::lVarejo
/*/
method getRetail() class cbcProductDetails
return(::lRetail)

/*/{Protheus.doc} setRetail
@author bolognesi
@since 17/07/2017
@version 1.0
@param lRetail, logical, Valor a ser atribuido para propriedade ::lRetail
@type method
@description Atribuir conteudo para propriedade ::lRetail
/*/
method setRetail(lRetail) class cbcProductDetails
	default lRetail := .F.

	if !empty(lRetail) .and. ValType(lRetail) == 'L'
		::lRetail := lRetail 
	else
		::lRetail := .F.
	endif
return(self)

/*********************************** Funções Estaticas *********************************/
/*/{Protheus.doc} qry
@author bolognesi
@since 12/09/2016
@version 1.0
@param cQry, characters, query em sql
@type function
@description Obter os dados da query, utilizando classe utils, e direcionala a propriedade correspondente
/*/
Static Function qry(cQry, oSelf, cTo)
	local oSql 		:= SqlUtil():newSqlUtil()
	local nX		:= 0
	local nY		:= 0
	local oPckFto	:= Nil
	local oZZZ		:= Nil
	local aMtr		:= {}
	local cFam		:= ""
	local cBit		:= ""
	local cAcond	:= ""
	local cMtr		:= ""
	local cCor		:= ""
	local cNomCor	:= ""
	local cProdBit	:= ""
	local aCor		:= ""

	oSelf:oCmbResp:lOk := .T.
	oSelf:oCmbResp:cMsg := "[OK]"

	if oSql:QryToDb(cQry):lOk
		if oSql:nRegCount > 0	
			oRet	:= oSql:oRes

			If cTo == 'COLOR'
				For nX := 1 To Len(oRet)
					oCmb := cbcComboItem():newcbcComboItem()
					oCmb:setID(oRet[nX]:ID)
					oCmb:setText(oRet[nX]:TEXT)
					oSelf:oCmbResp:addColor(oCmb) 
				Next nX
			ElseIf cTo == 'COLORSPEC'
				For nX := 1 To Len(oRet)
					oCmb := cbcColorSpecialtys():newcbcColorSpecialtys()
					oCmb:setSpec(oRet[nX]:ESP)
					oCmb:addColor( {oRet[nX]:ID, oRet[nX]:TEXT, oRet[nX]:APROVA} )
					oSelf:oCmbResp:addColorSpec(oCmb)
				Next nX
			ElseIf cTo == 'PROD'
				oZZZ  := cbcModelZZZ():newcbcModelZZZ()
				For nX := 1 To Len(oRet)
					//Mostrar somente as familias que tenham registro tabela ZZZ
					If oZZZ:getZZZProd(oRet[nX]:ID):itsOk()
						oCmb := cbcComboItem():newcbcComboItem()
						oCmb:setID(oRet[nX]:ID)
						oCmb:setText(oRet[nX]:TEXT)
						oSelf:oCmbResp:addProd(oCmb)
					EndIf
				Next nX
				FreeObj(oZZZ)
			ElseIf cTo == 'GAUGE'
				oZZZ  := cbcModelZZZ():newcbcModelZZZ()
				For nX := 1 To Len(oRet)
					//Mostrar somente as familias + bitolas que tenham registro tabela ZZZ
					If oZZZ:getZZZBito( oRet[nX]:PROD, oRet[nX]:ID ):itsOk()
						oCmb := cbcComboItem():newcbcComboItem()
						oCmb:setID(oRet[nX]:ID)
						oCmb:setText(oRet[nX]:TEXT)
						oSelf:oCmbResp:addGauge(oCmb)
					EndIf
				Next nX
				FreeObj(oZZZ)
			ElseIf cTo == 'CLASENC'
				For nX := 1 To Len(oRet)
					oSelf:oCmbResp:setClasse(oRet[nX]:CLASSE)
				Next nX

			ElseIf cTo == 'SPECIALTYS'

				For nX := 1 To Len(oRet)
					oCmb := cbcComboItem():newcbcComboItem()
					oCmb:setID(oRet[nX]:ID)
					oCmb:setText(oRet[nX]:TEXT)
					oSelf:oCmbResp:addSpecialtys(oCmb)
				Next nX

			ElseIf cTo == 'PACKFOOTAGE'

				For nX := 1 To Len(oRet)
					cFam 	:= Alltrim(oRet[nX]:FAM)
					cBit 	:= Alltrim(oRet[nX]:BIT)
					cAcond 	:= Alltrim(oRet[nX]:ACOND)
					cMtr	:= Alltrim(oRet[nX]:MTR)
					oCmb 	:= cbcComboItem():newcbcComboItem()
					oPckFto := cbcPackFootage():newcbcPackFootage()
					//*********** COMBO DE ACONDICIONAMENTO
					oCmb:setID(cAcond)
					oCmb:setText(U_getNamePack(cAcond))
					oSelf:oCmbResp:addPackAges(oCmb)

					//*********** METRAGEM PARA TODOS ACONDICIONAMENTO
					oPckFto:setPackAge(cAcond)
					if cMtr == '0'
						oSelf:oCmbResp:addPkFtage(oPckFto)
					else
						if ! U_okDotSlh(cMtr)[1]
							oSelf:oCmbResp:lOk := .F.
							oSelf:oCmbResp:cMsg := "[ERRO] - Verifique a metragem (" + cMtr + ") da Familia: " + cFam + " Bitola: " + cBit + ;
							" para o acondicionamento " + cAcond 
						else
							aMtr := StrToKArr(cMtr,';')
							for nY := 1 To Len(aMtr)
								oPckFto:addFootAge(aMtr[nY])
							next nY
							oSelf:oCmbResp:addPkFtage(oPckFto)
						endIf
					endif	
				Next nX
			ElseIf cTo == 'COLORACOND'
				for nX := 1 To Len(oRet)
					cCor 	 := Alltrim(oRet[nX]:COR)
					cProdBit := Alltrim(oRet[nX]:PROD_BIT)
					cAcond	 := Alltrim(oRet[nX]:ACOND)
					aCor 	 := StrTokArr(cCor, ';')
					if !empty(aCor)
						oCmb := cbcColorSpecialtys():newcbcColorSpecialtys()
						oCmb:setSpec(cProdBit+cAcond)

						for nY := 1 to len(aCor)
							cNomCor	 := Alltrim( Posicione("SZ3",1,xFilial("SZ3") + padr(aCor[nY], TamSx3("Z3_DESC")[1]) ,"Z3_DESC") )
							oCmb:addColor( {Alltrim(aCor[nY]), cNomCor, 'N'} )
						next nY

						oSelf:oCmbResp:addColorSpec(oCmb)
					endif
				next nX
			EndIf
		Else
			//Quando a operação 'COLORACOND' é esperado retorno vazio
			//somente considerar erro em outras operações.
			if cTo != 'COLORACOND'
				oSelf:oCmbResp:lOk := .F.
				oSelf:oCmbResp:cMsg := "[ERRO] - CBC106" //"Consulta não retornou nada"
			endif
		EndIf
	Else
		//TODO arrumar mylib
		if cTo != 'COLORACOND'
			oSelf:oCmbResp:lOk := .F.
			oSelf:oCmbResp:cMsg := "[ERRO] - " +  oSql:cMsgErro
		endif
	EndIf
	FreeObj(oSql)
Return (nil)


/*/{Protheus.doc} AcondCor
@author bolognesi
@since 20/01/2017
@version 1.0
@param self, , Estancia da classe (objeto)
@type function
@description Preparar as cores de acordo acondicionamentos
/*/
static function AcondCor(self,cCod,cBitola)
	local cChave	:= Alltrim(cCod) + Alltrim(cBitola)
	local cQry 		:= ""

	//TODO Cadastrar cores ZZZ(Se tiver cadastro usar)
	//Portal primeiro buscar o Familia+Bitola+Acond na especialidade
	//se achar usar aCores se não busca usando o da especialidade. 

	//Procurar regra de cores para acondicionamentos especificos
	cQry += " SELECT ZZZ.ZZZ_CODCOR AS COR, 				" 
	cQry += " ZZZ.ZZZ_PROD + ZZZ.ZZZ_BITOLA AS PROD_BIT,	"			
	cQry += " ZZZ.ZZZ_ACOND AS ACOND						"
	cQry += " FROM " +  RetSqlName('ZZZ') + " ZZZ			"		
	cQry += " WHERE "
	cQry += " ZZZ_FILIAL = '" + xFilial('ZZZ') + "' 		"
	cQry += " AND ZZZ.ZZZ_TIPO = 'MTR' "
	cQry += " AND ZZZ.ZZZ_PROD = '" + Alltrim(cCod) + 	"'"
	cQry += " AND ZZZ.ZZZ_BITOLA = '" + Alltrim(cBitola) + 	"'"
	cQry += " AND ZZZ.ZZZ_CODCOR <> ''						"
	cQry += " AND ZZZ.D_E_L_E_T_ <> '*'						"

	qry(cQry, self, 'COLORACOND')

return(nil)

/*
Como funciona a exibição de produtos no portal?
1-) Criamos uma tabela ZZZ, responsavel pelos cadastros de (Familia + Bitola) X (Acondicionamento + Mettragem)
2-) A rotina de manutenção da tabela ZZZ chama-se zMVCMd3().
3-) A exibição dos registro na rotina zMVCMd3() esta associado ao filtro do campo B1_MSBLQL, exibindo
para edição somente os não bloqueados.
4-) Para exibir os registros no portal os seguintes filtros são observados:
(B1_XPORTAL + B1_MSBlQL + B1_BLQVEN) bem como existir na tabela ZZZ, pois um produto sem cadastro de acondicionamento
e metragem não pode ser vendido
5-)03/07/17 - Alterado rotina zMVCMd3() para cadastrar produtos referentes ao varejo.
Em resumo:
Para exibir um produto no portal o cadastro deve estar dessa forma:
B1_XPORTAL			= 'S' ou 'E' somente para usuarios especiais (Negocios Estrategicos)
B1_MSBLQL			<> '1'
B1_BLQVEN			<> 'S'

E possuir um registro na tabela ZZZ (Familia  +  Bitola ) 

*/

Static function HandleEr(oErr, oSelf)
	oSelf:oCmbResp:lOk := .F.
	oSelf:oCmbResp:cMsg := '[' +oErr:Description + ']' + chr(10) + chr(13) + oErr:ERRORSTACK
	BREAK
return

/*/{Protheus.doc} ConsoleLog
@author bolognesi
@since 08/05/17
@version 1.0
@param cMsg, characters, Mensagem de erro
@type function
@description Utilizado para logar as mensagens de erro no console
/*/
static function ConsoleLog(cMsg)
	if GetNewPar('XX_DBGCONN', .T. )
		ConOut("[cbcProductDetails - "+DtoC(Date())+" - "+Time()+" ] "+cMsg)
	EnDIf
return
