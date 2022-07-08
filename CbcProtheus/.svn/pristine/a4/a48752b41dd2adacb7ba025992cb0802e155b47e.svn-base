#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"
#INCLUDE "CBCREST.ch"

#define INDICE 1
#define FILIAL 2
#define PARCIAL 3
#define ENTREGA 4
#define PRODUTO 5
#define ACONDICIONAMENTO 6
#define ACOND_PRODUTO 7
#define QTD_LIB 8
#define ATEND_FALTA 9
#define PEDIDO 10

/*
GET:
http://192.168.1.220:7798/ws/DISPEDEMP/?cOrdem=Entrega
*/
WSRESTFUL DISPEDEMP DESCRIPTION "Cobrecom - BI - Integração - Distribuição Pedido EPA"
WSDATA cOrdem		AS STRING

WSMETHOD GET DESCRIPTION "Distribuição Pedido EPA " WSSYNTAX "/DISPEDEMP/{cOrdem}"
END WSRESTFUL


WSMETHOD GET WSRECEIVE cOrdem   WSSERVICE DISPEDEMP
	local lGet			:= .T.
	local cHeader		:= ""
	local cFil			:= ""
	local oRes			:= cbcBIResp():newcbcBIResp()
	local cJson			:= ''
	default ::cOrdem 	:= ''

	//Tipo do conteudo para retorno
	::SetContentType("application/json")

	//Obter conteudo da requisição
	cHeader := ::GetHeader('Authorization')
	cFil	:= ::GetHeader('Filial')

	oRes:sucesso 			:= .T.
	oRes:msg				:= 'Carteira / EPA'
	oRes:xRet				:= u_cbcDsEmP()	
	::SetStatus(200)
	::SetResponse(oRes:toJson())
	FreeObj(oRes)
return(lGet)


user function cbcDsEmP()
	local oFil			:= cbcFiliais():newcbcFiliais()
	local oJsItuRes		:= nil
	local oJs3LRes		:= nil
	local oHashItu		:= HMNew()
	local oHash3L		:= HMNew()
	local aCarteira		:= {}

	oFil:setFilial('01')
	// Obtem carteira
	aCarteira := getACarteira()
	// Obtem Estoque
	zLVirEst(@oHashItu)
	// Definir Prioridades (Parcial)
	defPriori(@aCarteira)
	// Ordenar Carteira
	ASort(aCarteira,,,{|x,y| ( (x[1] + x[4]+ x[10]) < (y[1] + y[4] + y[10]) ) })
	// Empenha carteira ordenada e priorizada
	empCarteira(@aCarteira, oHashItu)
	
	oJsItuRes := prepJson(@aCarteira)

	oFil:setFilial('02')
	// Obtem carteira
	aCarteira := getACarteira()
	// Obtem Estoque
	zLVirEst(@oHash3L)
	// Definir Prioridades (Parcial)
	defPriori(@aCarteira)
	// Ordenar Carteira
	ASort(aCarteira,,,{|x,y| ( (x[1] + x[4]+ x[10]) < (y[1] + y[4] + y[10]) ) })
	
	// Empenha carteira ordenada e priorizada
	empCarteira(@aCarteira, oHash3L)
	oJs3LRes := prepJson(@aCarteira)

return({oJsItuRes, oJs3LRes})


static function getACarteira()
	local aRet	:= {}
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias( u_cbcQRYCarteira() )
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			aadd(aRet, {;
			'',;
			oSql:getValue("FILIAL"),;
			oSql:getValue("PARCIAL"),;
			oSql:getValue("ENTREGA"),;
			oSql:getValue("PRODUTO"),;
			oSql:getValue("ACONDICIONAMENTO"),;
			oSql:getValue("Alltrim(PRODUTO)") + oSql:getValue("Alltrim(ACONDICIONAMENTO)"),; 
			oSql:getValue("QTD_LIB"),;
			0,;
			oSql:getValue("PEDIDO")})
			oSql:skip()
		endDo
	endif	
	oSql:close()
	FreeObj(oSql)
return(aRet)


static function zLVirEst(oHash)
	local oSql		:= nil
	local cProd		:= ''
	local nSaldo	:= 0 
	local xValue	:= nil
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(u_cbcQRYBFEst())
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			cProd 	:= ( oSql:getValue("Alltrim(Produto)") + oSql:getValue("Alltrim(Acond)") )
			nSaldo 	:= oSql:getValue("Disponivel")
			if  ! HMGet( oHash , cProd , @xValue )
				HMAdd(oHash,{cProd,nSaldo})
			endif
			oSql:skip()
		endDo
	endif	
	oSql:close()
	FreeObj(oSql)
return(nil)


static function defPriori(aPed)
	local nX := 0
	for nX := 1 to len(aPed)
		aPed[nX,1] = if(aPed[nX,PARCIAL] == 'N','1','2')
	next nX
return(nil)


static function empCarteira(aCarteira, oHash)
	loca nX			:= 0
	local aRetEmp	:= {}
	for nX := 1 to len(aCarteira)
		aRetEmp := zLVirEmp(@oHash, aCarteira[nX,7], aCarteira[nX,8])
		if aRetEmp[1]
			aCarteira[nX,9] = aCarteira[nX,8]
		else
			aCarteira[nX,9] = aRetEmp[2] 
		endif
	next(nX)
return(nil)


static function zLVirEmp(oHash, cProd, nQtd)
	local aSld		:= {}
	local nSld		:= 0
	local lRet		:= .T.
	default oHash	:= nil
	if !empty(oHash)
		if HMGet( oHash, cProd, @aSld )
			if empty(aSld)
				lRet := .F.
			else
				if ( (nSld := ( aSld[1,2] - nQtd)) > 0 ) 
					lRet := HMSet(oHash, cProd, {{cProd, nSld}} )
				else
					lRet := .F.
				endif
			endif
		else
			lRet := .F.
		endif
	endif
return({lRet, nSld})


static function prepJson(aCarteira)
	local oJsnMain 	:= nil
	local oJsnItm	:= nil
	local aJson		:= {}
	local nX		:= 0
	oJsnMain 	:= JsonObject():new()
	for nX := 1 to len(aCarteira)
		oJsnItm 	:= JsonObject():new()
		oJsnItm['FILIAL'] 			:= aCarteira[nX,FILIAL]
		oJsnItm['PARCIAL'] 			:= aCarteira[nX,PARCIAL]
		oJsnItm['ENTREGA'] 			:= aCarteira[nX,ENTREGA]
		oJsnItm['PRODUTO'] 			:= Alltrim(aCarteira[nX,PRODUTO])
		oJsnItm['ACOND'] 			:= aCarteira[nX,ACONDICIONAMENTO]
		oJsnItm['ACOND_PRODUTO'] 	:= aCarteira[nX,ACOND_PRODUTO]
		oJsnItm['QTD_LIB'] 			:= aCarteira[nX,QTD_LIB]
		oJsnItm['ATEND_FALTA'] 		:= aCarteira[nX,ATEND_FALTA]
		oJsnItm['PEDIDO'] 			:= aCarteira[nX,PEDIDO]
		aadd(aJson, oJsnItm) 
	next nX
	oJsnMain['data' ] := aJson
return(oJsnMain)


static function throwErr(oRes, oSelf, cMsg, nErr)
	oRes:sucesso  	:= .F.
	oRes:msg		:= cMsg
	oRes:xRet		:= ''
	oSelf:SetStatus(nErr)
	oSelf:SetResponse(oRes:toJson())
return(nil)

