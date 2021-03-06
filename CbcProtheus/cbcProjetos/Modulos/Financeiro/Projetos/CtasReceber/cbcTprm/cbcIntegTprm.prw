#include "Totvs.ch"

class cbcIntegTprm
    data oTprmApi
    data oBody
    data lOk
    data cMsgErr
    data lShowErr
    data aHeader
    data aRet
    data cApiToken
    data lLog
    data aLogs
    data cGrtType
    data cPwd
    data cUsr

	method newcbcIntegTprm() constructor
    method setStatus()
    method getErrMsg()
    method showErr()
    method isOk()
    method HandleEr()
    method getHeader()
    method setHeader()
    method getBody()
    method setBody()
    method requestToken()
    method reqAvalScor()
    method consAvalScor()
    method consStatHom()
    method getCliFor()
    
endClass

method newcbcIntegTprm(lShowErr) class cbcIntegTprm
    Local aParametros := strtokarr(GetNewPar("ZZ_APITPRM","https://tprm.kpmg.com.br/Portal;cobrecom@sistema.com;wv5&1yPk;password"), ";")
    default lShowErr  := .T.

    ::lShowErr := lShowErr
    ::oTprmApi := FWRest():New(aParametros[1])
    ::cUsr     := aParametros[2]
    ::cPwd     := aParametros[3]
    ::cGrtType := aParametros[4]
    ::setStatus()
return(self)

method setStatus(lOk, cMsgErr, lEx, lShow) class cbcIntegTprm
    default lOk     := .T.
    default cMsgErr := ''
    default lEx     := .F.
    default lShow   := ::showErr()

    ::lOk := lOk

    if !(lOk)
        ::cMsgErr := '[cbcIntegTprm] - ' + cMsgErr +  ' - ' + iif(!Empty(::oTprmApi:GetResult()), ::oTprmApi:GetResult(), '')
        if lEx
            UserException(::getErrMsg())
        else
            if (lShow)
                MsgAlert(::getErrMsg(),'Erro - cbcIntegTprm')
            endif
        endif
    endif
return(self)

method getErrMsg() class cbcIntegTprm
return(::cMsgErr)

method showErr() class cbcIntegTprm
return(::lShowErr)

method isOk() class cbcIntegTprm
return(::lOk)

method HandleEr(oErr) class cbcIntegTprm
    if InTransact()
        DisarmTransaction()
    endif
    ::setStatus(.F., oErr:Description)
    BREAK
return(self)

method getHeader() class cbcIntegTprm
return(::aHeader)

method setHeader(lTkn, lJson) class cbcIntegTprm
    default lTkn  := .F.
    default lJson := .F.

    ::aHeader   := {}

    if lJson
        aadd(::aHeader, 'Content-Type: application/json')
    else
        aadd(::aHeader, 'Content-Type: application/x-www-form-urlencoded')
    endIf

    if lTkn
        aadd(::aHeader, 'Authorization: bearer ' + ::cApiToken)
    endIf
return(self)

method getBody() class cbcIntegTprm
return(::oBody)

method setBody(aTmpData, lConsulta) class cbcIntegTprm
    Local cUserId     := RetCodUsr()
    Local oContatos   := JsonObject():new()
    default aTmpData  := {}
    default lConsulta := .F.

    ::oBody := Nil
    ::oBody := JsonObject():new()

    if !Empty(aTmpData)
        if aTmpData[1] == 'J'
            ::oBody['AvaliacaoTipoId'] := '1' // '1' - Pessoa Juridica
            ::oBody['CNPJ'] := aTmpData[2]
        else
            ::oBody['AvaliacaoTipoId'] := '2' // '2' - Pessoa Fisica
            ::oBody['CPF']  := aTmpData[2]
            ::oBody['Nome'] := aTmpData[3]
        endIf

        if !(lConsulta)
            ::oBody['CriticidadeId'] := aTmpData[4] // '1' - Valor Default Cliente, 258 - Fornecedor
            ::oBody['ContatosSolicitantes'] := {}

            oContatos['Nome'] := iif(!Empty(UsrRetName(cUserID)),UsrRetName(cUserID),'COBRECOM')
            oContatos['Email'] := iif(!Empty(UsrRetMail(cUserID)),UsrRetMail(cUserID),'wfti@cobrecom.com.br')
            oContatos['RespondeFormulario'] := 'false'

            aadd(::oBody['ContatosSolicitantes'], oContatos)
        endif
    else
        ::setStatus(.T., 'CNPJ ou CPF n?o encontrado', .F., .T.)
    endif
return(self)

/*Obter o Token para conseguir realizar as opera??es*/
method requestToken() class cbcIntegTprm
    Local oToken  := JsonObject():new()
    Local cRet    := ''
    Local cParams := "grant_type="+Escape(::cGrtType)+"&password="+Escape(::cPwd)+"&username="+Escape(::cUsr)
    
    ::setHeader(.F.)
    ::oTprmApi:setPath("/Token?")
    ::oTprmApi:SetPostParams(cParams)
    ::oTprmApi:cResult := ""

    if (::setStatus((::oTprmApi:Post(::getHeader())), ::oTprmApi:GetLastError()):isOk())
        cRet := ::oTprmApi:GetResult()
        oToken:FromJson(cRet)
        ::cApiToken := oToken['access_token']
    endif
return(self)

/*Enviar os dados para solicitar a avalia??o de score*/
method reqAvalScor(aData) class cbcIntegTprm
    Local oBody := JsonObject():new()
    Local oRet  := JsonObject():new()
    Local nX    := 0
    Local cBody := ''
    Local cRet  := ''
    default aData := {}

    ::aRet := {}
    ::oTprmApi:setPath("/api/Avaliacao/Avaliar")
    ::setHeader(.T., .T.)

    for nX := 1 to Len(aData)
        ::setBody(::getCliFor(aData[nX]))
        oBody := ::getBody()
        cBody := oBody:ToJson()
        ::oTprmApi:SetPostParams(cBody)
        ::oTprmApi:cResult := ""

        if (::setStatus((::oTprmApi:Post(::getHeader())), aData[nX] + ' - ' + ::oTprmApi:GetLastError(), .F., .F.):isOk())
            cRet := ::oTprmApi:GetResult()
            oRet:FromJson(cRet)
            aadd(::aRet,  { aData[nX], oRet })
         else
            ::requestToken()
            ::setHeader(.T., .F.)
            ::oTprmApi:setPath("/api/Avaliacao/Avaliar")
            ::setHeader(.T., .T.)
            ::setBody(::getCliFor(aData[nX]))
            oBody := ::getBody()
            cBody := oBody:ToJson()
            ::oTprmApi:SetPostParams(cBody)
            ::oTprmApi:cResult := ""
            if (::setStatus((::oTprmApi:Post(::getHeader())),  aData[nX] + ' - ' + ::oTprmApi:GetLastError(), .F., .F.):isOk())
                cRet := ::oTprmApi:GetResult()
                oRet:FromJson(cRet)
                aadd(::aRet,  { aData[nX], oRet })
            endif
        endIf
    next
return(::aRet)

/*Consulta o resultado da avalia??o - Retorna dados da avalia??o*/
method consAvalScor(aData) class cbcIntegTprm
    Local oRet  := JsonObject():new()
    Local oBody := JsonObject():new()
    Local cBody := ''
    Local nX    := 0
    default aData := {}

    ::aRet := {}
    ::oTprmApi:setPath("/api/Avaliacao/Consultar")
    ::setHeader(.T., .T.)
    
    for nX := 1 to Len(aData)
        ::setBody(::getCliFor(aData[nX]), .T.)
        oBody := ::getBody()
        cBody := oBody:ToJson()
        ::oTprmApi:SetPostParams(cBody)
        ::oTprmApi:cResult := ""

        if (::setStatus((::oTprmApi:Post(::getHeader())),  aData[nX] + ' - ' + ::oTprmApi:GetLastError(), .F., .F.):isOk())
            oRet := ::oTprmApi:GetResult()
            aadd(::aRet,  { aData[nX], oRet })
        else
            ::requestToken()
            ::setHeader(.T., .F.)
            if (::setStatus((::oTprmApi:Get(::getHeader())),  aData[nX] + ' - ' + ::oTprmApi:GetLastError(), .F., .F.):isOk())
                oRet := ::oTprmApi:GetResult()
                aadd(::aRet,  { aData[nX], oRet })
            endif
        endif
    next
return(::aRet)

/*Consulta o status da avalia??o - se j? foi avaliado e disponivel para consulta*/
method consStatHom(aData) class cbcIntegTprm
    Local oRet    := JsonObject():new()
    Local cParams := ''
    Local nX      := 0
    default aData := {}

    ::aRet := {}
    ::oTprmApi:setPath("/api/Pessoa/ConsultarHomologacaoTerceiro")
    ::setHeader(.T., .F.)

    for nX := 1 to Len(aData)
        cParams := "documento=" + Escape(aData[nX])
        ::oTprmApi:SetGetParams(cParams)
        ::oTprmApi:cResult := ""

        if (::setStatus((::oTprmApi:Get(::getHeader())),  aData[nX] + ' - ' + ::oTprmApi:GetLastError(), .F., .F.):isOk())
            oRet := ::oTprmApi:GetResult()
            aadd(::aRet,  { aData[nX], oRet })
        else
            ::requestToken()
            ::setHeader(.T., .F.)
            if (::setStatus((::oTprmApi:Get(::getHeader())),  aData[nX] + ' - ' + ::oTprmApi:GetLastError(), .F., .F.):isOk())
                oRet := ::oTprmApi:GetResult()
                aadd(::aRet,  { aData[nX], oRet })
            endif
        endif
    next
return(::aRet)

method getCliFor(cCGC) class cbcIntegTprm
    Local oSql     := LibSqlObj():newLibSqlObj()
    Local aTmpData := {}
    Local cQryCli  := ''
    Local cQryFor  := ''

    cQryCli := "SELECT A1_PESSOA [TIPO], A1_CGC [CGC], A1_NOME [NOME], 1 [CRITICIDADE] FROM SA1010 WITH(NOLOCK) " // Criar um Campo ZZIDAVAL para receber o id da avalia??o e consulta-l?
    cQryCli += "WHERE A1_CGC = '" + cCGC + "' "
    cQryCli += "AND A1_MSBLQL <> '1' "
    cQryCli += "AND D_E_L_E_T_ = '' "

    cQryFor := "SELECT A2_TIPO [TIPO], A2_CGC [CGC], A2_NOME [NOME], 258 [CRITICIDADE]  FROM SA2010 WITH(NOLOCK) " // Criar um Campo ZZIDAVAL 
    cQryFor += "WHERE A2_CGC = '" + cCGC + "' "
    cQryFor += "AND A2_MSBLQL <> '1' "
    cQryFor += "AND D_E_L_E_T_ = '' "

    oSql:newAlias(cQryCli)

    if oSql:hasRecords()
        aadd(aTmpData, oSql:getValue('TIPO'))
        aadd(aTmpData, oSql:getValue('CGC'))
        aadd(aTmpData, oSql:getValue('NOME'))
        aadd(aTmpData, oSql:getValue('CRITICIDADE'))
    else
        oSql:Close()
        oSql:newAlias(cQryFor)
        if oSql:hasRecords()
            aadd(aTmpData, oSql:getValue('TIPO'))
            aadd(aTmpData, oSql:getValue('CGC'))
            aadd(aTmpData, oSql:getValue('NOME'))
            aadd(aTmpData, oSql:getValue('CRITICIDADE'))
        endIf
    endIf
    oSql:Close()
    FreeObj(oSql)
Return (aTmpData)

user function zSchIntTrpm(lAll)
    Local oCbcIntegTprm := CbcIntegTprm():newCbcIntegTprm()
    Local bErro         := ErrorBlock({|oErr| Conout(oErr:Description)})
    Default lAll := .F.

    Begin Sequence
        ConsoleLog('Inicio processo schedule KPMG')
		RPCClearEnv()
		RPCSetType(3)
		RPCSetEnv('01','01',,,'FAT',GetEnvServer(),{} )
        if (oCbcIntegTprm:requestToken():isOk())
            oCbcIntegTprm:reqAvalScor(getCliFor(lAll))
        endif
        ConsoleLog('Finalizou processo schedule')
		RPCClearEnv()
    RECOVER
    End Sequence
    ErrorBlock(bErro)
    FreeObj(oCbcIntegTprm)
return (Nil)

static function ConsoleLog(cMsg)
	ConOut("[ TPRM-KPMG-SCH -" + DtoC(Date())+" - "+Time()+" ] "+ cMsg)
return(nil )

static function getCliFor(lAll)
    Local oSql     := LibSqlObj():newLibSqlObj()
    Local aTmpData := {}
    Local cQryCli  := ''
    Local cQryFor  := ''
    default lAll   := .F.

    cQryCli := "SELECT A1_CGC [CGC] FROM SA1010 " // Criar um Campo ZZIDAVAL para receber o id da avalia??o e consulta-l?
    cQryCli += "WHERE A1_CGC <> ''"
    cQryCli += "AND A1_MSBLQL <> '1' "
    cQryCli += "AND A1_CGC NOT LIKE '00000000%' "
    if !(lAll)
        cQryCli += "AND dbo.datalgi_normal(A1_USERLGI) >= '" + Dtos(Date()) + "' "
    endIf
    cQryCli += "AND D_E_L_E_T_ = '' "
    cQryCli += "GROUP BY A1_CGC "
    cQryCli += "ORDER BY A1_CGC "

    cQryFor := "SELECT A2_CGC [CGC] FROM SA2010 " // Criar um Campo ZZIDAVAL 
    cQryFor += "WHERE A2_CGC <> '' "
    cQryFor += "AND A2_MSBLQL <> '1' "
    cQryFor += "AND A2_CGC NOT LIKE '00000000%' "  
    if !(lAll)
        cQryFor += "AND dbo.datalgi_normal(A2_USERLGI) >= '" + Dtos(Date()) + "' "
    endIf
    cQryFor += "AND D_E_L_E_T_ = '' "
    cQryFor += "GROUP BY A2_CGC "
    cQryFor += "ORDER BY A2_CGC "

    oSql:newAlias(cQryCli)

    if oSql:hasRecords()
        while oSql:notIsEof()
            aadd(aTmpData, oSql:getValue('CGC'))
            oSql:skip() 
        end  
    endif
    oSql:Close()

    oSql:newAlias(cQryFor)
    if oSql:hasRecords()
        while oSql:notIsEof()
            aadd(aTmpData, oSql:getValue('CGC'))
            oSql:skip() 
        end 
    endIf
    oSql:Close()
    FreeObj(oSql)
Return (aTmpData)


/*Zona de Teste e Utilizado para carga inicial */
user function zzTstIntTrpm()
    Local oCbcIntegTprm := CbcIntegTprm():newCbcIntegTprm()
    Local bErro         := ErrorBlock({|oErr| oCbcIntegTprm:HandleEr(oErr)})
    Local aRet          := {}
    Local nX            := 0

    Begin Sequence
        // Obtem Token
        if (oCbcIntegTprm:requestToken():isOk())
            
            //Solicita avalia??o de score dos CPFs/CNPJs
            // aRet := oCbcIntegTprm:reqAvalScor(getCliFor(.T.)) // Deixar s? essa linha dentro do "If" para Carga Inicial
            aRet := oCbcIntegTprm:reqAvalScor({'02544042000119', '02544042000208','28877101000164'})
            for nX := 1 to Len(aRet)
                MsgInfo(aRet[nX][1] + ' - ' + aRet[nX][2]:ToJson(), 'oCbcIntegTprm:reqAvalScor')
            next

            //Consulta avalia??o de score dos CPFs/CNPJs
            aRet := {}
            aRet := oCbcIntegTprm:consAvalScor({'02544042000119', '02544042000208', '28877101000164'})
            for nX := 1 to Len(aRet)
                MsgInfo(aRet[nX][1] + ' - ' + aRet[nX][2], 'oCbcIntegTprm:consAvalScor')
            next

            //Consulta Status da avalia??o de score dos CPFs/CNPJs
            aRet := {}
            aRet := oCbcIntegTprm:consStatHom({'02544042000119', '02544042000208', '28877101000164'})
            for nX := 1 to Len(aRet)
                MsgInfo(aRet[nX][1] + ' - ' + aRet[nX][2], 'oCbcIntegTprm:consStatHom')
            next
        endif
    RECOVER
    End Sequence
    ErrorBlock(bErro)
return (Nil)
