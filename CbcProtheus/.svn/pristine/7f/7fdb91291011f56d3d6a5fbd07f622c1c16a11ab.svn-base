#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDef.ch'

class cbcCtrlSusp
    data lOk
    data cMsgErr
    data lShowErr

    method newcbcCtrlSusp()
    
    method setStatus()
    method isOk()
    method getErrMsg()
    method showErr()
    method load()
    method save()
    method insert()
    method update() 
endclass

method newcbcCtrlSusp(cCarga, lShowErr) class cbcCtrlSusp
    default lShowErr := .T.
    ::lShowErr  := lShowErr
    ::setStatus()
return(self)

method setStatus(lOk, cMsgErr, lEx, lShow) class cbcCtrlSusp
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

method isOk() class cbcCtrlSusp
return(::lOk)

method getErrMsg() class cbcCtrlSusp
return(::cMsgErr)

method showErr() class cbcCtrlSusp
return(::lShowErr)

method load(cCnpj) class cbcCtrlSusp
    local oJs   := cfgJson(cCnpj) 
    local oSql  := LibSqlObj():newLibSqlObj()
    
    oSql:newAlias(qryLoad(cCnpj))
    if oSql:hasRecords()
        oSql:goTop()
        oJs['cod']      := oSql:getValue("COD")
        oJs['loja']     := oSql:getValue("LOJA")
        oJs['nome']     := oSql:getValue("NOME")
        oJs['tipo']     := oSql:getValue("TIPO")
        oJs['end']      := oSql:getValue("ENDER")
        oJs['mun']      := oSql:getValue("MUN")
        oJs['cep']      := oSql:getValue("CEP")
        oJs['est']      := oSql:getValue("EST")
        oJs['suframa']  := oSql:getValue("SUFRAMA")
        oJs['contrib']  := oSql:getValue("CONTRIB")
    endif
    oSql:Close()
    FreeObj(oSql)
return(oJs)

method save(cJs) class cbcCtrlSusp
    local nRec := 0
    local oJs  := JsonObject():new()
    default cJs:= ''

    if (::setStatus(!empty(cJs), 'Json sem informações'):isOk())
        oJs:FromJSON(cJs)
        nRec := isSusp(AllTrim(oJs['cgc']))
        if nRec > 0
            ::update(nRec, cJs)
        else
            ::insert(cJs)
        endif
    endif
    FreeObj(oJs)
return(self)

method insert(cJs) class cbcCtrlSusp
    local aFldValue := {}
    local aRet      := {}
    local oJs       := JsonObject():new()
    local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @self)})
    default cJs     := ''

    oJs:FromJSON(cJs)
    if (::setStatus(!empty(oJs:GetNames()), 'Json sem informações'):isOk())
        aAdd(aFldValue, {'US_CGC',      Padr(oJs['cgc'], TamSX3('US_CGC')[1])})
        aAdd(aFldValue, {'US_LOJA',     Padr('01', TamSX3('US_LOJA')[1])})
        aAdd(aFldValue, {'US_NOME',     Padr(oJs['nome'], TamSX3('US_NOME')[1])})
        aAdd(aFldValue, {'US_TIPO',     Padr(oJs['tipo'], TamSX3('US_TIPO')[1])})
        aAdd(aFldValue, {'US_END',      Padr(oJs['end'], TamSX3('US_END')[1])})
        aAdd(aFldValue, {'US_MUN',      Padr(oJs['mun'], TamSX3('US_MUN')[1])})
        aAdd(aFldValue, {'US_CEP',      Padr(oJs['cep'], TamSX3('US_CEP')[1])})
        aAdd(aFldValue, {'US_EST',      Padr(oJs['est'], TamSX3('US_EST')[1])})
        aAdd(aFldValue, {'US_SUFRAMA',  Padr(oJs['suframa'], TamSX3('US_SUFRAMA')[1])})
        aAdd(aFldValue, {'US_CONTRIB',  Padr(oJs['contrib'], TamSX3('US_CONTRIB')[1])})
        BEGIN SEQUENCE            
            BEGIN TRANSACTION
                aRet := updateSUS(MODEL_OPERATION_INSERT, aFldValue)
                ::setStatus(aRet[1],aRet[2],.T.)
            END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
    endif
    FreeObj(oJs)
return(self)

method update(nRec, cJs) class cbcCtrlSusp
    local aFldValue := {}
    local aRet      := {}
    local oJs       := JsonObject():new()
    local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @self)})
    default cJs     := ''

    oJs:FromJSON(cJs)
    if (::setStatus(!empty(oJs:GetNames()), 'Json sem informações'):isOk())
        aAdd(aFldValue, {'US_NOME',     Padr(oJs['nome'], TamSX3('US_NOME')[1])})
        aAdd(aFldValue, {'US_TIPO',     Padr(oJs['tipo'], TamSX3('US_TIPO')[1])})
        aAdd(aFldValue, {'US_END',      Padr(oJs['end'], TamSX3('US_END')[1])})
        aAdd(aFldValue, {'US_MUN',      Padr(oJs['mun'], TamSX3('US_MUN')[1])})
        aAdd(aFldValue, {'US_CEP',      Padr(oJs['cep'], TamSX3('US_CEP')[1])})
        aAdd(aFldValue, {'US_EST',      Padr(oJs['est'], TamSX3('US_EST')[1])})
        aAdd(aFldValue, {'US_SUFRAMA',  Padr(oJs['suframa'], TamSX3('US_SUFRAMA')[1])})
        aAdd(aFldValue, {'US_CONTRIB',  Padr(oJs['contrib'], TamSX3('US_CONTRIB')[1])})
        BEGIN SEQUENCE            
            BEGIN TRANSACTION
                aRet := updateSUS(MODEL_OPERATION_UPDATE, aFldValue, nRec)
                ::setStatus(aRet[1],aRet[2],.T.)
            END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
    endif
    FreeObj(oJs)
return(self)

/*SERVICES ZONE*/
static function HandleEr(oErr, oSelf)
    if InTransact()
		DisarmTransaction()
	endif
    oSelf:setStatus(.F., oErr:Description)
	BREAK
return(nil)

static function updateSUS(nOper, aFldValue, nRec)
	local aArea    	:= GetArea()
	local aAreaSUS	:= SUS->(getArea())
	local lRet 		:= .T.
	local nX		:= 0
	local oModel	:= nil
	local aErro		:= {}
	local cErro		:= ''
	default nRec    := 0

	dbselectArea('SUS')
	
	oModel := FWLoadModel('cbcSUSModel')
    oModel:SetOperation(nOper)
	if !empty(nRec)
        SUS->(DbGoTo(nRec))
    endif	
	oModel:Activate()
    for nX := 1 to len(aFldValue)		
	    oModel:LoadValue('SUSMASTER',aFldValue[nX, 1], aFldValue[nX, 2])
    next nX   
	if !(lRet := FWFormCommit(oModel))
		aErro := oModel:GetErrorMessage()
		if !empty(aErro)
			cErro += aErro[2] + '-'
			cErro += aErro[4] + '-'
			cErro += aErro[5] + '-'
			cErro += aErro[6] 
		endif
	endif
	oModel:DeActivate()
	FreeObj(oModel)

	RestArea(aAreaSUS)
	RestArea(aArea)
return({lRet,cErro})

static function cfgJson(cCnpj)
    local oJs       := JsonObject():new()
    default cCnpj   := ''

    oJs['cgc']      := cCnpj
    oJs['cod']      := ''
    oJs['loja']     := ''
    oJs['nome']     := ''
    oJs['tipo']     := ''
    oJs['end']      := ''
    oJs['mun']      := ''
    oJs['cep']      := ''
    oJs['est']      := ''
    oJs['suframa']  := ''
    oJs['contrib']  := ''
return(oJs)

static function isSusp(cCnpj)
    local nRec      := 0
    local oSql      := LibSqlObj():newLibSqlObj()
    default cCnpj   := ''

    oSql:newAlias(qryLoad(cCnpj))
    if oSql:hasRecords()
        nRec := oSql:getValue("REC")
    endif
    oSql:Close()
    FreeObj(oSql)
return(nRec)


/* QUERY ZONE */
static function qryLoad(cCnpj)
    local cQry      := ''
    default cCnpj   := ''

    cQry += " SELECT SUS.US_COD AS [COD], "
    cQry += " SUS.US_LOJA AS [LOJA], "
    cQry += " SUS.US_NOME AS [NOME], "
    cQry += " SUS.US_CGC AS [CNPJ], "
    cQry += " SUS.US_TIPO AS [TIPO], "
    cQry += " SUS.US_END AS [ENDER], "
    cQry += " SUS.US_MUN AS [MUN], "
    cQry += " SUS.US_BAIRRO AS [BAIRRO], "
    cQry += " SUS.US_CEP AS [CEP], "
    cQry += " SUS.US_EST AS [EST], "
    cQry += " SUS.US_DDD AS [DDD], "
    cQry += " SUS.US_TEL AS [TEL], "
    cQry += " SUS.US_EMAIL AS [MAIL], "
    cQry += " SUS.US_CONTRIB AS [CONTRIB], "
    cQry += " SUS.US_SUFRAMA AS [SUFRAMA], "
    cQry += " SUS.US_CNAE AS [CNAE], "
    cQry += " SUS.R_E_C_N_O_ AS [REC] "
    cQry += " FROM " + RetSqlName('SUS') + " SUS "
    cQry += " WHERE SUS.US_FILIAL = '" + xFilial('SUS') + "' "
    cQry += " AND SUS.US_CGC = '" + AllTrim(cCnpj) + "' "
    cQry += " AND SUS.D_E_L_E_T_ = ''     "
return(cQry)

/* TEST ZONE */
user function tstloadSusp(cCnpj) //'02544042000208'
    local oCtrl := cbcCtrlSusp():newcbcCtrlSusp()
    local oJson := nil

    oJson := oCtrl:load(cCnpj)
    msgInfo(oJson:ToJson(), 'Json')
return(nil)

user function tstupdSusp(cJson)
    local oCtrl := cbcCtrlSusp():newcbcCtrlSusp()
    local oJson := JsonObject():new()

    default cJson := '{	"cep": "79601900",	"loja": "01",	"suframa": "456",	"end": "AV. DOIS ESQINA COM AV. CINCO",	"est": "MS",	"tipo": "R",	"contrib": 1,	"cgc": "02544042000208",	"nome": "I.F.C. IND. E COM. DE CONDUTORES ELETRICOS LTDA",	"mun": "TRES LAGOAS"    }'
    
    oCtrl:save(cJson)
    oJson:FromJSON(cJson)
    msgInfo(oJson:ToJson(), 'Json')
return(nil)
