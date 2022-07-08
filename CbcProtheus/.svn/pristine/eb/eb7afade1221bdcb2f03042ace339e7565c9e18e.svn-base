#include 'protheus.ch'
#include 'parmtype.ch'

class cbcDocPorCtrl
    data lOk
    data cMsgErr
    data lShowErr
    method newcbcDocPorCtrl()
    method setStatus()
    method isOk()
    method getErrMsg()
    method showErr()
    method load()
endclass

method newcbcDocPorCtrl(cCarga, lShowErr) class cbcDocPorCtrl
    default lShowErr := .T.
    ::lShowErr  := lShowErr
    ::setStatus()
return(self)

method setStatus(lOk, cMsgErr, lEx, lShow) class cbcDocPorCtrl
    default lOk     := .T.
    default cMsgErr := ''
    default lEx     := .F.
    default lShow   := ::showErr()
    ::lOk       := lOk
    if !(lOk)
        ::cMsgErr   := '[cbcCtrlSusp] - ' + cMsgErr
        if lEx
            UserException(::getErrMsg())
        else
            if (lShow)
                MsgAlert(::getErrMsg(),'Erro - cbcCtrlSusp')
            endif
        endif
    endif
return(self)

method isOk() class cbcDocPorCtrl
return(::lOk)

method getErrMsg() class cbcDocPorCtrl
return(::cMsgErr)

method showErr() class cbcDocPorCtrl
return(::lShowErr)

method load(jsData) class cbcDocPorCtrl
    local nX    := 0
    local oJs   := nil
    local oSql  := LibSqlObj():newLibSqlObj()
    local oJson := JsonObject():new()
    local oSA1  := JsonObject():new()
    local aItns := {}

	oJson:FromJSON(jsData)
    oJs := cliJson()
    oSql:newAlias(qryLoad(oJson['filial'], oJson['doc'], Capital(lower(oJson['from'])) ))
    if oSql:hasRecords()
        oSql:goTop()
        oJs['A1_NOME'] 		:= oSql:getValue("NOME")
        oJs['A1_PESSOA'] 	:= oSql:getValue("PESSOA")
        oJs['A1_TIPO'] 		:= oSql:getValue("TIPO")
        oJs['A1_EST'] 		:= oSql:getValue("EST")
        oJs['A1_CGC'] 		:= oSql:getValue("CNPJ")
        oJs['A1_INSCR'] 	:= oSql:getValue("INSCR")
        oJs['A1_VEND'] 		:= oSql:getValue("VEND")
        oJs['A1_GRPTRIB'] 	:= oSql:getValue("GRPTRIB")
        oJs['A1_CONTRIB'] 	:= oSql:getValue("CONTRIB")
        oJs['A1_SIMPNAC'] 	:= oSql:getValue("SIMPNAC")
        oJs['A1_CODSIAF'] 	:= oSql:getValue("CODSIAF")
        oJs['A1_CALCSUF'] 	:= oSql:getValue("CALCSUF")
        oJs['A1_XREIDI'] 	:= oSql:getValue("XREIDI")
        oJs['A1_SUFRAMA']   := oSql:getValue("SUFRAMA")
        oJs['A1_TABELA']    := oSql:getValue("TABELA")
    endif
    oSql:Close()
    oSA1["SA1"] := oJs:toJson()
    oSql:newAlias(qryItm(oJson['filial'],oJson['doc'], Capital(lower(oJson['from'])) ))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            nX++
            FreeObj(oJs)
            oJs                  := itmJson()
            oJs["codigo"]		:= oSql:getValue("Alltrim(CODIGO)")
            oJs["quantidade"]	:= oSql:getValue("QUANTIDADE")
            oJs["precounit"]	:= oSql:getValue("PRECO")
            oJs["total"]		:= oSql:getValue("TOTAL")
            aadd(aItns, oJs)
            oSql:skip()
        endDo
    endif
    oSql:Close()
    FreeObj(oSql)
    FreeObj(oJs)
    oJs := cfgJson(oSA1, aItns) 
return(oJs)

static function cfgJson(oCli, aItns)
    local oJson  := JsonObject():new()
    oJson["cliente"]            := oCli
    oJson["itens"]              := aItns
return(oJson)

static function cliJson()
    local oJs       := JsonObject():new()
    oJs['A1_NOME'] 		:= ''
	oJs['A1_PESSOA'] 	:= ''
    oJs['A1_TIPO'] 		:= ''
    oJs['A1_EST'] 		:= ''
    oJs['A1_CGC'] 		:= ''
    oJs['A1_INSCR'] 	:= ''
    oJs['A1_VEND'] 		:= ''
    oJs['A1_GRPTRIB'] 	:= ''
    oJs['A1_CONTRIB'] 	:= ''
    oJs['A1_SIMPNAC'] 	:= ''
    oJs['A1_CODSIAF'] 	:= ''
    oJs['A1_CALCSUF'] 	:= ''
    oJs['A1_XREIDI'] 	:= ''
	oJs['A1_SUFRAMA']   := ''
return(oJs)

static function itmJson()
    local oJsItem 		    := JsonObject():new()
    oJsItem["codigo"]		:= ''
    oJsItem["quantidade"]	:= 0
    oJsItem["precounit"]	:= 0.00
    oJsItem["total"]		:= 0.00
return(oJsItem)

/* QUERY ZONE */
static function qryLoad(cFl, cDoc, cFrom)
    local cQry      := ''
    if cFrom == 'Pedido'
        cQry += " SELECT "
        cQry += " SA1.A1_COD                  AS [COD], "
        cQry += " SA1.A1_LOJA                 AS [LOJA], "
        cQry += " RTRIM(LTRIM(SA1.A1_NOME))   AS [NOME], "
        cQry += " SA1.A1_CGC				  AS [CNPJ], " 
        cQry += " SA1.A1_TIPO				  AS [TIPO], "
        cQry += " SA1.A1_PESSOA				  AS [PESSOA], "
        cQry += " SA1.A1_END				  AS [ENDER], "
        cQry += " SA1.A1_MUN				  AS [MUN], "
        cQry += " SA1.A1_BAIRRO				  AS [BAIRRO], "
        cQry += " SC5.C5_ENDENT1			  AS [CEP], "
        cQry += " SA1.A1_EST				  AS [EST], "        
        cQry += " SA1.A1_INSCR				  AS [INSCR], "
        cQry += " SA1.A1_CONTRIB			  AS [CONTRIB],"
        cQry += " SA1.A1_VEND			      AS [VEND],"
        cQry += " SA1.A1_GRPTRIB			  AS [GRPTRIB],"
        cQry += " SA1.A1_SIMPNAC			  AS [SIMPNAC]," 
        cQry += " SA1.A1_CODSIAF			  AS [CODSIAF],"
        cQry += " SA1.A1_CALCSUF			  AS [CALCSUF]," 
        cQry += " SA1.A1_XREIDI			  AS [XREIDI],"
        cQry += " SA1.A1_TABELA			  AS [TABELA],"
        cQry += " SA1.A1_SUFRAMA			  AS [SUFRAMA] "
        cQry += " FROM " + RetSqlName('SC5')       + " SC5 WITH(NOLOCK)"
        cQry += " INNER JOIN " + RetSqlName('SA1') +" SA1 WITH(NOLOCK)"
        cQry += " ON '"+ xFilial('SA1') +"' = SA1.A1_FILIAL "
        cQry += " AND SC5.C5_CLIENT         = SA1.A1_COD "
        cQry += " AND SC5.C5_LOJACLI        = SA1.A1_LOJA "
        cQry += " AND SC5.D_E_L_E_T_        = SA1.D_E_L_E_T_ "
        cQry += " WHERE "
        cQry += " SC5.C5_FILIAL             = '" + cFl + "' "
        cQry += " AND SC5.C5_NUM            = '" + cDoc + "' "
        cQry += " AND SC5.D_E_L_E_T_        = '' "
    elseif cFrom == 'Portal'
        cQry += " SELECT " 
        cQry += " SA1.A1_COD                  AS [COD], "
        cQry += " SA1.A1_LOJA                 AS [LOJA], "
        cQry += " RTRIM(LTRIM(SA1.A1_NOME))   AS [NOME], "
        cQry += " SA1.A1_PESSOA				  AS [PESSOA], "
        cQry += " CASE WHEN SA1.A1_COD + SA1.A1_LOJA  = '00000000'  "
        cQry += " THEN ZP5.ZP5_CNPJ  "
        cQry += " ELSE SA1.A1_CGC  "
        cQry += " END						 AS [CNPJ],  "
        cQry += " SA1.A1_TIPO				 AS [TIPO],  "
        cQry += " SA1.A1_END					 AS [ENDER], "
        cQry += " SA1.A1_MUN					 AS [MUN], "
        cQry += " SA1.A1_BAIRRO				 AS [BAIRRO], "
        cQry += " ZP5.ZP5_CEPENT				 AS [CEP], "
        cQry += " SA1.A1_EST					 AS [EST], "
        cQry += " SA1.A1_CONTRIB				 AS [CONTRIB], "
        cQry += " SA1.A1_INSCR				    AS [INSCR], "
        cQry += " SA1.A1_VEND			      AS [VEND],"
        cQry += " SA1.A1_GRPTRIB			  AS [GRPTRIB],"
        cQry += " SA1.A1_SIMPNAC			  AS [SIMPNAC],"
        cQry += " SA1.A1_CODSIAF			  AS [CODSIAF]," 
        cQry += " SA1.A1_CALCSUF			  AS [CALCSUF],"
        cQry += " SA1.A1_TABELA			  AS [TABELA],"    
        cQry += " SA1.A1_XREIDI			  AS [XREIDI]," 
        cQry += " SA1.A1_SUFRAMA				 AS [SUFRAMA] "
        cQry += " FROM " + RetSqlName('ZP5') + " ZP5 WITH(NOLOCK)"
        cQry += " INNER JOIN " + RetSqlName('SA1') +" SA1 WITH(NOLOCK)"
        cQry += " ON '"+xFilial('SA1')+"'= SA1.A1_FILIAL "
        cQry += " AND ZP5.ZP5_CLIENT		= SA1.A1_COD "
        cQry += " AND ZP5.ZP5_LOJA		= SA1.A1_LOJA "
        cQry += " AND ZP5.D_E_L_E_T_		= SA1.D_E_L_E_T_ "
        cQry += " WHERE "
        cQry += " ZP5.ZP5_FILIAL      = '"+xFilial('ZP5')+"' "
        cQry += " AND ZP5.ZP5_NUM     = '"+ cDoc + "' "
        cQry += " AND ZP5.D_E_L_E_T_ = '' "
    endif
return(cQry)


static function qryItm(cFl, cDoc, cFrom)
    local cQry      := ''
    if cFrom == 'Pedido'
        cQry += " SELECT " 
        cQry += " SC6.C6_ITEM     AS [ITEM], "
        cQry += " SC6.C6_TES      AS [TES], "
        cQry += " SC6.C6_PRODUTO  AS [CODIGO], "
        cQry += " SC6.C6_DESCRI   AS [DESCRICAO], "
        cQry += " SC6.C6_QTDVEN   AS [QUANTIDADE], "
        cQry += " SC6.C6_PRCVEN	AS [PRECO], "
        cQry += " (SC6.C6_QTDVEN * SC6.C6_PRCVEN) AS [TOTAL] "
        cQry += " FROM " + RetSqlName('SC6') + " SC6 WITH(NOLOCK)"
        cQry += " WHERE SC6.C6_FILIAL = '"+ cFl + "' "
        cQry += " AND SC6.C6_NUM = '" + cDoc + "' "
        cQry += " AND D_E_L_E_T_ = '' "
        cQry += " ORDER BY SC6.C6_ITEM ASC "
    elseif cFrom == 'Portal'
        cQry += " SELECT "
        cQry += " ''             AS [ITEM], "
        cQry += " ''             AS [TES], "
        cQry += " ZP9.ZP9_CODPRO AS [CODIGO], "
        cQry += " ZP9.ZP9_POSHPH AS [POSHIP], "
        cQry += " ZP6.ZP6_DESCRI AS [DESCRICAO], "
        cQry += " ZP9.ZP9_QUANT * ZP6.ZP6_QTACON  AS [QUANTIDADE], "
        cQry += " CASE "
        cQry += " WHEN ZP6.ZP6_PRCAPR > 0 "
        cQry += " THEN ZP6.ZP6_PRCAPR "
        cQry += " ELSE ZP6.ZP6_PRCSUG "
        cQry += " END					AS [PRECO], "
        cQry += " CASE "
        cQry += " WHEN ZP6.ZP6_PRCAPR > 0 "
        cQry += " THEN (ZP9.ZP9_QUANT * ZP6.ZP6_QTACON) * ZP6.ZP6_PRCAPR "
        cQry += " ELSE (ZP9.ZP9_QUANT * ZP6.ZP6_QTACON) * ZP6.ZP6_PRCSUG "
        cQry += " END					AS [TOTAL] "
        cQry += " FROM " + RetSqlName('ZP9') + " ZP9 WITH(NOLOCK)"
        CQry += " INNER JOIN " + RetSqlName('ZP6') +" ZP6 WITH(NOLOCK)"
        cQry += " ON ZP9.ZP9_FILIAL	    = ZP6.ZP6_FILIAL "
        cQry += " AND ZP9.ZP9_NUM		= ZP6.ZP6_NUM "
        cQry += " AND ZP9_ITEM		    = ZP6.ZP6_ITEM "
        cQry += " AND ZP9.D_E_L_E_T_   = ZP6.D_E_L_E_T_ "
        cQry += " WHERE  "
        cQry += " ZP9.ZP9_NUM = '" + cDoc + "' "
        cQry += " AND ZP9.D_E_L_E_T_ = '' "
        cQry += " ORDER BY ZP9_ITEM ASC "
    endif
return(cQry)
