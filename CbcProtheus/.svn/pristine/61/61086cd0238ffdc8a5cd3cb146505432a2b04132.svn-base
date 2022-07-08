#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "rwmake.ch"
#define BR Chr(10)

user function cbcAltDcSai(nRec)
    local aArea  as array
    local oModel as object
    local aRet   as array
    local aLog   as array
    default nRec := 0

    aRet  := {.T., ''}
    aArea := GetArea()
    aLog  := {}
    BEGIN TRANSACTION
        if nRec > 0
            DbSelectArea('SF2')
            SF2->(DbGoTo(nRec))
        endif
        if ! validSf2()
            Help( ,, 'NF já transmitida!!' ,, 'Validação', 1,0)
        else
            oModel := FWLoadModel('cbcMdlSF2')
            oModel:SetOperation(MODEL_OPERATION_UPDATE)
            oModel:Activate()
            if (aLog := edit(@oModel))[1]
                if !(aRet := save(@oModel))[1]
                    DisarmTransaction()
                    Help( ,, aRet[2] ,, 'Erro', 1,0)
                else
                    sendEmail(aLog[2])
                endif
            endif
            oModel:DeActivate()
            FreeObj(oModel)
        endif
    END TRANSACTION
    RestArea(aArea)

return(aRet[1])


static function validSf2()
    local lRet as bool
    lRet := empty(SF2->(F2_CHVNFE)) .and. empty(SF2->(F2_FIMP))
return(lRet)


static function edit(oModel)
    local aParamBox as array
    local aConfig   as array
    local nX        as numeric
    local cField    as character
    local cDesc     as character
    local cPic      as character
    local cVld      as character
    local aLog      as array
    local nTam      as numeric
    local aRet      as array
    local lOk       as bool

    aParamBox   := {}
    aConfig     := {}
    aRet        := {}
    aLog        := {}
    lOk         := .T.
    aadd(aConfig, {'Peso Bruto: '   , 'F2_PBRUTO'   , '(mv_par01 >= 0)' })
    aadd(aConfig, {'Peso Liquido: ' , 'F2_PLIQUI'   , '(mv_par02 >= 0)' })
    aadd(aConfig, {'Tipo Frete: '   , 'F2_TPFRETE'  , '(mv_par03 $ "CFTRDS")' })
    aadd(aConfig, {'Valor Frete: '  , 'F2_FRETE'    , '(mv_par04 >= 0)' })
    aadd(aConfig, {'Volume 1: '     , 'F2_VOLUME1'  , '.T.' })
    aadd(aConfig, {'Especi 1: '     , 'F2_ESPECI1'  , '.T.' })
    for nX := 1 to len(aConfig)
        cDesc  := aConfig[nX, 1]
        cField := aConfig[nX, 2]
        cVld   := aConfig[nX, 3]
        cPic   := PesqPict('SF2',cField)
        nTam   := 80
        aadd(aParamBox,{1,cDesc,SF2->(&cField),cPic,cVld,"",".T." ,nTam,.F.})
    next nX
    if (lOk := ParamBox(aParamBox,"Documento de Saida...",@aRet))
        for nX := 1 to len(aRet)
            cField := aConfig[nX][2]
            aadd(aLog, {cField, SF2->(&cField), aRet[nX]})
            oModel:SetValue('SF2MASTER',aConfig[nX][2],aRet[nX])
        next nX
    endif
return({lOk, aLog})


static function save(oModel)
    local lRet  as logic
    local aErro as array
    local cErro as character

    if ! (lRet := oModel:VldData())
        aErro := oModel:GetErrorMessage()
        if !empty(aErro)
            cErro := aErro[2] + '-'
            cErro += aErro[4] + '-'
            cErro += aErro[5] + '-'
            cErro += aErro[6]
            Help( ,, cErro ,, 'Erro', 1,0)
        endif
    else
        FWFormCommit(oModel)
    endIf
return({lRet, cErro})


static function sendEmail(aLog)
    local nX       as numeric
    local cTxtHtml as character
    local cTo as character
    local cSubject as character

    if !empty(aLog)
        cTo      := 'wfti@cobrecom.com.br'
        cSubject := "[SF2-ALTER]-[" + Alltrim(SF2->(F2_FILIAL + F2_DOC)) + "] "
        cTxtHtml := ''
        cTxtHtml += '<p><h1>'+ Alltrim(SF2->(F2_FILIAL + F2_DOC))  +'</h1></p>'
        cTxtHtml += '<p><h2> [USUARIO: '+ UsrRetName(RetCodUsr())  +;
        ' DATA-HORA: ' +  DtoC(Date()) + '-' + Time() + ']</h2></p>'
        cTxtHtml += '<table border="1">'
        cTxtHtml += '<tr>'
        cTxtHtml += '<th>Campo</th>'
        cTxtHtml += '<th>Antigo</th>'
        cTxtHtml += '<th>Novo</th>'
        cTxtHtml += '</tr>'
        for nX := 1 to len(aLog)
            cTxtHtml += '<tr>'
            cTxtHtml += '<td>' + cValToChar(aLog[nX][1]) + '</td>'
            cTxtHtml += '<td>' + cValToChar(aLog[nX][2]) + '</td>'
            cTxtHtml += '<td>' + cValToChar(aLog[nX][3]) + '</td>'
            cTxtHtml += '</tr>'
        next nX
        cTxtHtml += '</table>'
        u_SendMail(cTo, cSubject, cTxtHtml)
    endif
return (nil)
