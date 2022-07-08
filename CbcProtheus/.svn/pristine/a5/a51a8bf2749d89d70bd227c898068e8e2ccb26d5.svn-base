#include 'totvs.ch'
static ESCOLHE_PEDIDO	:= GetNewPar('ZZ_LIBESCP',.F.)

/*/{Protheus.doc} cbcC9ListModel
(long_description)
@type class
@author bolognesi
@since 26/04/2018
@description Classe que contem uma lista de objetos 
"cbcC9Model" bem como metodos para tratamento desta lista
/*/
class cbcC9ListModel
	data aC9Model
	data aC9Wrong
	data lOk
	data cMsgErr
	
	method newcbcC9ListModel() constructor
	method fromSQL()
	method filterModel()
	method getWrongC9()
endclass


/*/{Protheus.doc} newcbcC9ListModel
(long_description)
@type class
@author bolognesi
@since 26/04/2018
@description Construtor da classe
/*/
method newcbcC9ListModel(lSql) class cbcC9ListModel
	default lSql := .T.
	if lSql
		::fromSQL()
	endif
return(self)


/*/{Protheus.doc} fromSQL
(long_description)
@type class
@author bolognesi
@since 26/04/2018
@description Cria o array com objetos(cbcC9Model), partindo
de uma consulta SQL.
/*/
method fromSQL() class cbcC9ListModel
	local oSql 	:= nil
	local aSC9	:= nil
	
	::aC9Model	:= {}
	::aC9Wrong	:= {}
	::lOk		:= .T.
	::cMsgErr	:= ''
	
	oSql 		:= LibSqlObj():newLibSqlObj()
	oSql:newAlias(getQry())
	
	if !oSql:hasRecords()
		::lOk		:= .F.
		::cMsgErr	:= '[cbcC9Model] - Nenhum registro para liberação'
	else
		
		oSql:goTop()
		while oSql:notIsEof()
			
			oSC9 := cbcC9Model():newcbcC9Model()
			
			oSC9:addRecno({'SC5', oSql:getValue("C5REC")})
			oSC9:addRecno({'SC6', oSql:getValue("C6REC")})
			oSC9:addRecno({'SC9', oSql:getValue("C9REC")})
			oSC9:addRecno({'SBF', oSql:getValue("BFREC")})
			oSC9:addRecno({'SB2', oSql:getValue("B2REC")})
			oSC9:addRecno({'ZZZ', oSql:getValue("ZZREC")})
			
			aadd(::aC9Model, oSC9)
			oSql:Skip()
		end
	endif
	FreeObj(oSql)
return(self)


/*/{Protheus.doc} filterModel
(long_description)
@type class
@author bolognesi
@since 26/04/2018
@description Realiza os filtros na lista considerando a regra
Curva somente se DtFat <= Hoje e Normal Sempre assume a data de faturamento,
bem como identifica os itens que não tem SBF.
/*/
method filterModel() class cbcC9ListModel
	local nX 	:= 0
	local dHoje 	:= date()
	local aAux	:= {}
	local aWrgPed	:= {}
	
	for nX := 1 to len (::aC9Model)
		if vldSBF( ::aC9Model[nX], @aWrgPed, @::aC9Wrong) 
			if ::aC9Model[nX]:prodCurva()
				if ::aC9Model[nX]:getDtFat() <= dHoje
					aadd(aAux,::aC9Model[nX])
				endif
			else
				::aC9Model[nX]:setEntItem(::aC9Model[nX]:getDtFat())
				aadd(aAux,::aC9Model[nX])
			endif
		endif
	next nX
	::aC9Model := aAux
return(self)

/*/{Protheus.doc} getWrongC9
(long_description)
@type class
@author bolognesi
@since 26/04/2018
@description Retorna o array com itens que não estão validos
/*/
method getWrongC9() class cbcC9ListModel
return(::aC9Wrong)


/*/{Protheus.doc} vldSBF
(long_description)
@type class
@author bolognesi
@since 26/04/2018
@description Realiza as validações no SBF
/*/
static function vldSBF(oMdl, aWrgPed, aC9Wrong)
	local cNroPed 	:= oMdl:getNroPedido()
	local nRecSBF		:= oMdl:getRecno('SBF')
	local lRet		:= .T.
	local cErr		:= ''

	if empty(nRecSBF)
		cErr += "SBF NÂO ENCONTRADO PARA PRODUTO"
		aadd(aWrgPed, cNroPed)
		lRet := .F.
	endif
	
	if !lRet
		oMdl:setObsEmp(cErr)
		aadd(aC9Wrong,oMdl)	
	endif
return(lRet)


/*/{Protheus.doc} getQry
(long_description)
@type class
@author bolognesi
@since 26/04/2018
@description Query utilizado pelo processo.
/*/
static function getQry()
	local cQry 	:= ''
	local cMsg	:= 'Pedidos separados ";"'
	local cVar	:= ''
	
	cQry += " SELECT "
	cQry += " SC9.R_E_C_N_O_ AS [C9REC], "
	cQry += " SC6.R_E_C_N_O_ AS [C6REC], "
	cQry += " SC5.R_E_C_N_O_ AS [C5REC], "
	cQry += " ISNULL(SBF.R_E_C_N_O_,  0) AS [BFREC], "
	cQry += " SB2.R_E_C_N_O_ AS [B2REC], "
	cQry += " ISNULL(ZZZ.R_E_C_N_O_ , 0) AS [ZZREC] "
	
	cQry += " FROM  %SC9.SQLNAME% "
	
	cQry += " INNER JOIN  %SC6.SQLNAME%  "
	cQry += " ON  SC9.C9_FILIAL 	= SC6.C6_FILIAL "
	cQry += " AND SC9.C9_PEDIDO 	= SC6.C6_NUM "
	cQry += " AND SC9.C9_ITEM 		= SC6.C6_ITEM "
	cQry += " AND SC9.D_E_L_E_T_ 	= SC6.D_E_L_E_T_ "
	
	cQry += " INNER JOIN  %SC5.SQLNAME%  "
	cQry += " ON  SC6.C6_FILIAL 	= SC5.C5_FILIAL "
	cQry += " AND SC6.C6_NUM 		= SC5.C5_NUM "
	cQry += " AND SC5.C5_ZSTATUS NOT IN ('1', '2') "
	cQry += " AND SC6.D_E_L_E_T_ 	= SC5.D_E_L_E_T_ "
	
	cQry += " LEFT JOIN %SBF.SQLNAME% "
	cQry += " ON SC6.C6_FILIAL = SBF.BF_FILIAL "
	cQry += " AND SC6.C6_LOCAL = SBF.BF_LOCAL "
	cQry += " AND SC6.C6_ACONDIC +  right(replicate('0',5) + convert(VARCHAR,SC6.C6_METRAGE),5) = SBF.BF_LOCALIZ "
	cQry += " AND SC6.C6_PRODUTO = SBF.BF_PRODUTO "
	cQry += " AND SC6.D_E_L_E_T_ = SBF.D_E_L_E_T_ "
	
	cQry += " INNER JOIN %SB2.SQLNAME% "
	cQry += " ON SC6.C6_FILIAL = SB2.B2_FILIAL "
	cQry += " AND SC6.C6_LOCAL = SB2.B2_LOCAL "
	cQry += " AND SC6.C6_PRODUTO = SB2.B2_COD "
	cQry += " AND SC6.D_E_L_E_T_ = SB2.D_E_L_E_T_ "
	
	cQry += " LEFT JOIN %ZZZ.SQLNAME% "
	cQry += " ON %ZZZ.XFILIAL% "
	cQry += " AND 'CUR' 			= ZZZ.ZZZ_TIPO "
	cQry += " AND SC6.C6_PRODUTO 	= ZZZ.ZZZ_CODPRO "
	cQry += " AND SC6.D_E_L_E_T_ 	= ZZZ.D_E_L_E_T_ "
	
	cQry += " INNER JOIN  %SF4.SQLNAME%  "
	cQry += " ON '  ' 			= SF4.F4_FILIAL "
	cQry += " AND SC6.C6_TES 		= SF4.F4_CODIGO "
	cQry += " AND 'S' 			= SF4.F4_ESTOQUE "
	cQry += " AND SC6.D_E_L_E_T_ 	= SF4.D_E_L_E_T_ "
	
	cQry += " WHERE %SC9.XFILIAL% "
	
	if ESCOLHE_PEDIDO
		if !empty(cVar := FwInputBox(cMsg, cVar))
			cQry += " AND SC9.C9_PEDIDO IN " + FormatIn(cVar,';')  + " "
		endif
	endif
	
	cQry += " AND SC9.C9_BLCRED = '  ' "
	cQry += " AND SC9.C9_BLEST = '02' "
	
	if FwFilial() == "02"
		cQry += " AND SC9.C9_LOCAL <> '10' "
	endif
	
	cQry += " AND SC6.C6_ACONDIC NOT IN ('T', 'B') "
	cQry += " AND SC5.C5_TIPOLIB <> 'M' "
	cQry += " AND %SC9.NOTDEL%	"
	cQry += " ORDER BY SC9.C9_PEDIDO,SC9.C9_PRODUTO,SC9.C9_LOCAL,SC6.C6_ACONDIC,SC6.C6_METRAGE "
	
return(cQry)
