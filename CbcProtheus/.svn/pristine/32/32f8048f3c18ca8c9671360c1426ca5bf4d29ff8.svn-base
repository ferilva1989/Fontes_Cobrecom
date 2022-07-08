#include 'protheus.ch'
#define LINHA	chr(13)


/*/{Protheus.doc} cbcVarejoProduto
@author bolognesi
@since 14/07/2017
@version 1.0
@type class
@description Classe que representa todas as funcionalidaes do projeto Varejo
relacionadas ao produto.
/*/
class cbcVarejoProduto 

	method newcbcVarejoProduto() constructor 
	method isRetail()
	method getInfo()
	method getFamQry()
	method getGauQry()
	method getPacQry() 
	method getColQry()

endclass


/*/{Protheus.doc} newcbcVarejoProduto
@author bolognesi
@since 14/07/2017
@version 1.0
@type method
@description Construtor da classe
/*/
method newcbcVarejoProduto() class cbcVarejoProduto
return(self)

/*/{Protheus.doc} isRetail
@author bolognesi
@since 14/07/2017
@version undefined
@param cProd, characters, Codigo do produto
@param cAcond, characters, Acondicionamento
@param cMtr, characters, Metragem/Lances
@type method
@description Verifica se é um produto de varejo utilizando os 
registros da tabela ZZZ, on o ZZ_TIPO for igual 'VAR'
/*/
method isRetail(cProd,cAcond,cMtr) class cbcVarejoProduto
	local oSql 		:= nil
	local cCor		:= ""
	local lRet		:= .F.

	default cProd 	:= ''
	default cAcond 	:= ''
	default cMtr 	:= ''

	if !empty(cProd) .and. !empty(cAcond) .and. !empty(cMtr)
		cCor := SubStr(cProd,6,2)
		oSql := LibSqlObj():newLibSqlObj()
		oSql:newAlias(getQuery(cProd))
		if oSql:hasRecords()
			oSql:goTop()
			while oSql:notIsEof()
				if Alltrim(cAcond) == oSql:getValue("Alltrim(ACOND)")

					if (AScan(StrToKArr(oSql:getValue("Alltrim(METRAGEM)"),';'),;
					{|a| Alltrim(a) == Alltrim(cValToChar(cMtr)) })) > 0

						if empty(oSql:getValue("CORES"))
							lRet := .T.
							exit
						else
							if (AScan(StrToKArr(oSql:getValue("CORES"),';'),;
							{|a| Alltrim(a) == Alltrim(cValToChar(cCor)) })) > 0
								lRet := .T.
								exit
							endif
						endif

					endif
				endif
				oSql:skip()
			enddo
		endif
		oSql:Close()
		FreeObj(oSql)
	endif
return(lRet)

/*/{Protheus.doc} getInfo
@author bolognesi
@since 14/07/2017
@version 1.0
@param cProd, characters, Codigo produto (B1_COD)')
@type method
@description Verificar para um codigo de produto quais as condições 
que ele ofere para a venda no varejo 
Ex: (codigo 1150505401 pode somente nas metragens 100, Acondicionamento B e COR = Vermelha)
apenas informativo. Busca estas informações da tabela ZZZ, on o ZZ_TIPO for igual 'VAR'
/*/
method getInfo(cProd) class cbcVarejoProduto
	local oSql 		:= nil
	local cTxt		:= ""
	local aInfo		:= {}
	local nX		:= 0
	local nY		:= 0
	local nZ		:= 0

	if !empty(cProd)
		oSql := LibSqlObj():newLibSqlObj()
		oSql:newAlias(getQuery(cProd))
		if oSql:hasRecords()
			oSql:goTop()
			while oSql:notIsEof()	
				aadd(aInfo,;
				{oSql:getValue("Alltrim(ACOND)"),;
				StrToKArr(oSql:getValue("Alltrim(METRAGEM)"),';'),;
				StrToKArr(oSql:getValue("CORES"),';')} )
				oSql:skip()
			enddo
		endif
		oSql:Close()
		FreeObj(oSql)
		if empty(aInfo)
			cTxt := '[AVISO] - Produto não comercializado no varejo.'
		else
			cTxt += 'PRODUTO: ' + Alltrim(cProd) + LINHA
			cTxt += 'No varejo é permitido nas seguintes condições: ' + LINHA + LINHA
			for nX := 1 to len(aInfo)
				cTxt += 'ACOND: ' + aInfo[nX,1] + LINHA

				for nY := 1 to len(aInfo[nX,2])
					if nY == 1
						cTxt += 'METRAGEM: '
					endif
					cTxt += aInfo[nX,2,nY] + ' - '
				next nY
				cTxt += LINHA
				for nZ := 1 to len(aInfo[nX,3])
					if nZ == 1
						cTxt += 'CORES: '
					endif
					cTxt += Alltrim(aInfo[nX,3,nZ]) + '-' + getNameCor(aInfo[nX,3,nZ]) + ' '
				next nZ
				cTxt += LINHA
			next nX
		endif
	endif
return(cTxt)

/*/{Protheus.doc} getFamQry
@author bolognesi
@since 17/07/2017
@version 1.0
@type method
@description Obter a query que retorna as familias de produtos, referente ao varejo para o portal
/*/
method getFamQry() class cbcVarejoProduto
	local cQry	:= ''
	cQry += " SELECT DISTINCT Z1_COD   	AS ID, "  
	cQry += " Z1_NOME	 				AS	TEXT "  
	cQry += " FROM " 		+ RetSqlName('ZZZ') + " ZZZ  "
	cQry += " INNER JOIN " 	+ RetSqlName('SZ1') +  " SZ1  "
	cQry += " ON ZZZ_FILIAL			= Z1_FILIAL " 				  
	cQry += " AND ZZZ_PROD			= Z1_COD 	"				  
	cQry += " AND ZZZ.D_E_L_E_T_	= SZ1.D_E_L_E_T_ " 		 	  
	cQry += " WHERE " 												  
	cQry += " ZZZ_FILIAL			= '" + xFilial("ZZZ") +"' 	"
	cQry += " AND ZZZ_TIPO			= 'VAR' " 						  
	cQry += " AND ZZZ.D_E_L_E_T_	= '' " 						  
	cQry += " ORDER BY Z1_COD "	
return(cQry)

/*/{Protheus.doc} getGauQry
@author bolognesi
@since 17/07/2017
@version undefined
@param cCod, characters, codigo produto obter as bitolas
@type method
@description Obter a query que retorna as bitoças de produtos, referente ao varejo para o portal
/*/
method getGauQry(cCod) class cbcVarejoProduto
	local cQry	:= ''
	default cCod := ''
	if !empty(cCod)
		cQry += " SELECT DISTINCT " 
		cQry += " Z2_COD  		AS ID, "						  
		cQry += " Z2_DESC		AS TEXT, "					 
		cQry += " '" + cCod + "' AS PROD "						 		   
		cQry += " FROM " 		+ RetSqlName('ZZZ') + " ZZZ  "
		cQry += " INNER JOIN " 	+ RetSqlName('SZ2') +  " SZ2  "  
		cQry += " ON ZZZ_FILIAL	 	 = Z2_FILIAL " 				 
		cQry += " AND ZZZ_BITOLA 	 = Z2_COD " 					 
		cQry += " AND ZZZ.D_E_L_E_T_ = SZ2.D_E_L_E_T_ " 			 
		cQry += " WHERE " 												 
		cQry += " ZZZ_FILIAL		 = '" + xFilial("ZZZ") +"' 	" 	 
		cQry += " AND ZZZ_TIPO		 = 'VAR' "
		cQry += " AND ZZZ_PROD	LIKE '" + cCod + "%' " 		 
		cQry += " AND ZZZ.D_E_L_E_T_ = '' " 						 
		cQry += " ORDER BY Z2_COD "	
	endif
return(cQry)

/*/{Protheus.doc} getPacQry
@author bolognesi
@since 17/07/2017
@version 1,0
@param cChave, characters, Familia + Bitola
@type method
@description Obter a query que retorna os acondicionamentos, para uma Familia + Bitola
/*/
method getPacQry(cChave) class cbcVarejoProduto
	local cQry	:= ''
	default cChave := ''
	if !empty(cChave)
		cQry += " 	SELECT	ZZZ_ACOND 	AS ACOND, 					" 
		cQry += " 	ZZZ_VLRMTR 			AS MTR, 					"
		cQry += " 	ZZZ_PROD 			AS FAM, 					"
		cQry += " 	ZZZ_BITOLA 			AS BIT 						"
		cQry += " FROM " +  RetSqlName('ZZZ')
		cQry += " 	WHERE  											"
		cQry += " ZZZ_FILIAL = '" + xFilial('ZZZ') + "' 			"
		cQry += " 	AND ZZZ_TIPO = 'VAR'	"
		cQry += " 	AND ZZZ_PROD + ZZZ_BITOLA = '" + cChave +		"'"
		cQry += " 	AND ZZZ_ACOND IN (								"
		cQry += " 		SELECT ZZZ_ACOND FROM " + RetSqlName('ZZZ')
		cQry += " 		WHERE 										"
		cQry += " 		ZZZ_FILIAL = '" + xFilial('ZZZ') + 			"'"
		cQry += " 		AND ZZZ_TIPO = 'VAR'	"
		cQry += " 		AND ZZZ_PROD + ZZZ_BITOLA = '" + cChave + 	"'"
		cQry += " 		AND D_E_L_E_T_ <> '*'						"
		cQry += " 	)												"
		cQry += " 	AND D_E_L_E_T_ <> '*'							"
	endif
return(cQry)

/*/{Protheus.doc} getColQry
@author bolognesi
@since 17/07/2017
@version 1.0
@param cChave, characters, Familia + Bitola
@type method
@description Obter a query que retorna os acondicionamentos, para uma Familia + Bitola
/*/
method getColQry(cChave) class cbcVarejoProduto
	local cQry	:= ''
	default cChave := ''
	if !empty(cChave)
		cQry += " SELECT ZZZ.ZZZ_CODCOR AS COR, 				" 
		cQry += " ZZZ.ZZZ_PROD + ZZZ.ZZZ_BITOLA AS PROD_BIT,	"			
		cQry += " ZZZ.ZZZ_ACOND AS ACOND						"
		cQry += " FROM " +  RetSqlName('ZZZ') + " ZZZ			"		
		cQry += " WHERE "
		cQry += " ZZZ_FILIAL = '" + xFilial('ZZZ') + "' 		"
		cQry += " AND ZZZ.ZZZ_TIPO = 'VAR' "
		cQry += " AND (ZZZ.ZZZ_PROD + ZZZ.ZZZ_BITOLA) = '" + Alltrim(cChave) + 	"'"
		cQry += " AND ZZZ.ZZZ_CODCOR <> ''						"
		cQry += " AND ZZZ.D_E_L_E_T_ <> '*'						"
	endif
return(cQry)

/*/{Protheus.doc} getNameCor
@author bolognesi
@since 14/07/2017
@version 1.0
@param cCod, characters, Codigo da cor
@type function
@description Realiza consulta na tabela SZ3(Cores Produtos)
obtendo a partir do codigo a descrição da cor.
/*/
static function getNameCor(cCod)
	local 	cCor	:= ''
	local	oSql	:= nil 
	default cCod 	:= ''
	if !empty(cCod)
		oSql := LibSqlObj():newLibSqlObj()
		cCor := oSql:getFieldValue("SZ3", "Z3_DESC","%SZ3.XFILIAL% AND Z3_COD = '" + Alltrim(cCod) + "'")
		oSql:Close()
		FreeObj(oSql)
	endif
return(Alltrim(cCor))

/*/{Protheus.doc} getQuery
@author bolognesi
@since 14/07/2017
@version 1.0
@param cCod, characters, Codigo do produto
@type function
@description A partir de um codigo do produto, obtem as informações
da tabela ZZZ (Metragens e Varejo)
/*/
static function getQuery(cCod)
	local cQry		:= ""
	default cCod	:= ""
	if !empty(cCod)
		if len(cCod) > 5
			cCod := left(cCod,5)
		endif
		cQry += " SELECT " 
		cQry += " ZZZ_VLRMTR		AS METRAGEM, "
		cQry += " ZZZ_CODCOR		AS CORES, "
		cQry += " ZZZ_ACOND			AS ACOND "
		cQry += " FROM %ZZZ.SQLNAME%  "
		cQry += " WHERE "
		cQry += "%ZZZ.XFILIAL% AND ZZZ_TIPO = 'VAR'" +  " AND  (ZZZ_PROD + ZZZ_BITOLA ) = '" + cCod + "'"
		cQry += " AND %ZZZ.NOTDEL% "
	endif
return(cQry)