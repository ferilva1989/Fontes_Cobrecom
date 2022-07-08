#include 'protheus.ch'
#include 'parmtype.ch'
#include "totvs.ch"
#include "restful.ch"

wsRestful apiProdRg DESCRIPTION "API Rest Cadastro Produtos RG"
	wsMethod GET description "Rotas GET: /produtos "
end wsRestful

wsMethod GET wsService apiProdRg
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local cRoute	:= ""
	local oRes		:= JsonObject():new()

	cRoute := oRequest:getRoute()

	if (cRoute == "produtos")
		listProds(@self, @oRes)
	else
		oRes["status"] 			:= .F.
		oRes["msg"]				:= 'Rota Invalida'
	endif

	::SetStatus(200)
	::SetResponse(oRes:toJson())
	FreeObj(oRes)
return(.T.)

static function listProds(oWs, oRes)
	local lRet			:= .T.
	local cMsgErr		:= ''
    local cData         := getProds()

	oRes["status"] 		:= lRet
	oRes["msg"]			:= cMsgErr
    oRes["data"]        := cData
return(nil)

static function getProds()
    local oSql      := LibSqlObj():newLibSqlObj()
    local nPos      := 0
    local aData     := {}
    local oData     := JsonObject():new()
    local oJson     := nil
    local oLBProd   := getLBProds()

    oSql:newAlias(qrylistProds())
    if(oSql:hasRecords())
        oSql:goTop()
        while oSql:notIsEof()
            if (len(oLBProd) > 0)
                nPos := MyScan( oLBProd, 'codigo', AllTrim(oSql:getValue("CODIGO")))
            else
                nPos := 0
            endif
            if nPos == 0
                oJson               := JsonObject():new()
                oJson["codigo"]     := AllTrim(oSql:getValue("CODIGO"))
                oJson["nome"]       := AllTrim(oSql:getValue("NOME"))
                oJson["descricao"]  := AllTrim(oSql:getValue("DESCRICAO"))
                oJson["bitola"]     := AllTrim(oSql:getValue("BITOLA"))
                oJson["custo"]      := oSql:getValue("CUSTO")
                oJson["margem"]     := oSql:getValue("MARGEM")
                oJson["preco"]      := oSql:getValue("PRECO")
                aAdd(aData, oJson)
                FreeObj(oJson)
            endIf
            oSql:skip()
        endDo
    endif
    oSql:Close()
    FreeObj(oSql)
    if !empty(aData)
        oData["data"] := aData
    endif
return(oData:ToJson())

static function MyScan(oJson, cProp,xValue)
    local nPos  := 0
    local nX    := 0

    for nX := 1 to len(oJson)
        if oJson[nX][cProp] == xValue
            nPos := nX
            EXIT
        endif
    next nX
return(nPos)

static function getLBProds()
    local oRest		    := nil
    local oJson         := JsonObject():new()
    local cUrlApi       := AllTrim(GetNewPar("ZZ_APICUST", "http://192.168.1.207:3000"))
    local aHeader       := {}
    aadd(aHeader, 'Content-Type: application/json')
    oRest := FWRest():New(cUrlApi)
    oRest:SetPath("/produtos")
    if (oRest:Get(aHeader))
        oJson:FromJson(oRest:GetResult())
    endif
    FreeObj(oRest)
return(oJson)

static function qrylistProds()
    local cQry := ""
    cQry += " SELECT  "
    cQry += " 	DISTINCT(SUBSTRING(B1.B1_COD,1,5) + 'XX' + SUBSTRING(B1.B1_COD,8,3)) AS [CODIGO], "
    cQry += " 	Z1.Z1_DESC AS [NOME], "
    cQry += " 	Z1.Z1_DESC1 AS [DESCRICAO], "
    cQry += " 	Z2.Z2_DESC AS [BITOLA], "
    cQry += " 	0        AS [CUSTO], "
    cQry += "   0        AS [MARGEM], "
    cQry += "   0        AS [PRECO] "
    cQry += " FROM " + RetSqlName('SB1') + " B1  "
    cQry += " INNER JOIN " + RetSqlName('SZ1') + " Z1 on '" + xFilial('SZ1') + "' = Z1.Z1_FILIAL AND B1.B1_NOME = Z1.Z1_COD AND B1.D_E_L_E_T_ = Z1.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SZ2') + " Z2 on '" + xFilial('SZ2') + "' = Z2.Z2_FILIAL AND B1.B1_BITOLA = Z2.Z2_COD AND B1.D_E_L_E_T_ = Z2.D_E_L_E_T_ "
    cQry += " WHERE  B1.B1_FILIAL = '" + xFilial('SB1') + "' "
    cQry += " 	AND B1.B1_TIPO = 'PA' "
    cQry += " 	AND B1.B1_MSBLQL <> 1 "
    cQry += " 	AND LEN(B1.B1_COD) = 10 "
    cQry += " 	AND B1.D_E_L_E_T_ = ''  "
    cQry += " ORDER BY SUBSTRING(B1.B1_COD,1,5) + 'XX' + SUBSTRING(B1.B1_COD,8,3)     "
return(cQry)

user function tstApiProdRG()
    local cData         := getProds()
    msgInfo(cValToChar(Len(cData)), 'Info')
return(nil)
