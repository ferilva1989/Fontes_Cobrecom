#include 'Totvs.ch'

user function cbcInvAlmox()
    local aRet      := {}
    local aPerg     := {}
    local aFilter   := {}
    local lOk       := .T.
    local lGeral    := .F.

    aadd(aPerg,{1,"Data Inventário: ", dDataBase,"",".T.","",".T.",50,.T.})
    aadd(aPerg,{1,"Data Cont. De: ",   dDataBase,"",".T.","",".T.",50,.T.})
    aadd(aPerg,{1,"Data Cont. Até: ",  dDataBase,"","MV_PAR02 <= MV_PAR03","",".T.",50,.T.})
    aadd(aPerg,{3,"Processamento: ",   1,        {"Geral", "Rotativo"},50,"",.T.})
    
    if (ParamBox(aPerg,"Inventário cbcWMS Almoxarifado",@aRet))
        if aRet[04] == 1
            lGeral := .T.
            //FWMsgRun(, { |oSay| lOk := loadCount(DtoS(aRet[01]), DtoS(aRet[02]), DtoS(aRet[03]), oSay)[1]}, 	"Importador CBCWMS", "Importando Contagens...")
        endif
        lOk := MsgYesNo('Prosseguir?','Processamento Inventário Almoxarifado')
        if lOk
            if !lGeral
                aFilter := filterAddress()
            endif
            if lGeral .or. !empty(aFilter)
                FWMsgRun(, { |oSay| procWms(DtoS(aRet[02]), DtoS(aRet[03]), aFilter, oSay)}, 	"Ajustes CBCWMSAlmox", "Processando Ajustes...")
            else
                MsgAlert('Inventário Rotativo necessita informar os endereços de processamento.','Informe Endereço')
            endif
        endif
    endif
return(nil)

static function filterAddress()
    local aFilter       := {}
    local aTemp         := {}
    local oModal        := nil
    local oGet          := nil
    local cFilter       := ''
    local nX            := 0
    local nAddHeight    := 200
    local nAddWidth     := 300

    oModal  := FWDialogModal():New()
    oModal:setSize(nAddHeight, nAddWidth) //Height, Width
    oModal:SetEscClose(.T.)
    oModal:setTitle('Inserir Endereços do WMSAlmox')
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    oGet := tMultiget():new( 01, 01, {| u | if( pCount() > 0, cFilter := u, cFilter ) }, oModal:getPanelMain(), (nAddWidth - 03), (nAddHeight - 70), , , , , , .T. )
    oModal:Activate()
    if MsgYesNo('Confirma endereços?','Confirmar')
        if !empty(cFilter)
            aTemp   := StrTokArr( AllTrim(cFilter),  Chr(13)+Chr(10) )
            for nX := 1 to len(aTemp)
                if (aScan(aFilter, aTemp[nX]) == 0) .and. !empty(aTemp[nX])
                    aAdd(aFilter, AllTrim(aTemp[nX]))
                endif
            next nX
        endif
    endif
    FreeObj(oGet)
    FreeObj(oModal)
return(aFilter)

static function procWms(cDe, cAte, aFilter, oSay)
    local oInt      := cbcAlmoxInteg():newcbcAlmoxInteg()
    local oAjustes  := JsonObject():new()
    local cConvDe   := Year2Str(StoD(cDe))  + '-' + Month2Str(StoD(cDe))   + '-' + Day2Str(StoD(cDe))
    local cConvAte  := Year2Str(StoD(cAte)) + '-' +  Month2Str(StoD(cAte)) + '-' + Day2Str(StoD(cAte))
    local lRet      := .T.
    default aFilter := {}

    if oSay <> nil
        oSay:SetText('Obtendo lista de Ajustes...')
        ProcessMessage()
    endif
    oAjustes := oInt:getInvAjuste(cConvDe, cConvAte, aFilter)
    if (len(oAjustes['mov']) > 0 .and. len(oAjustes['upd']) > 0)
        if oSay <> nil
            oSay:SetText('Realizando movimentações de Ajustes...')
            ProcessMessage()
        endif
        lRet := oInt:doMovimento(oAjustes):isOk()
        if lRet
            if oSay <> nil
                oSay:SetText('Gravando Arquivo de Log...')
                ProcessMessage()
            endif
            writeMyFile(cConvDe, cConvAte, oAjustes:ToJson())
        endif
    else
        MsgInfo('Sem ajustes a serem executados no WMS!', 'Ajustes WMS')
    endif
    if lRet
        if oSay <> nil
            oSay:SetText('Finalizando inventário no WMS...')
            ProcessMessage()
        endif
        lRet := oInt:chgStsInvent(cConvDe, cConvAte, 1)
    endif
return(nil)

static function writeMyFile(cDe, cAte, cLog)
    local oJwt      := cbcJwtAuth():newcbcJwtAuth()
    local cToken    := ''
    local oJson     := JsonObject():new()
    local cArqGera	:= "\ExpIntegra\"+'Inv_De_'+ cDe + '_Ate_' + cAte + '_' + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + '.txt'

    oJson['de'] := cDe
    oJson['ate']:= cAte
        
    cToken  := oJwt:gerToken(oJson:ToJson(), 30)
    
    MemoWrite(cArqGera,  cToken + Chr(13)+Chr(10) + cDe + Chr(13)+Chr(10) + cAte + Chr(13)+Chr(10) + cLog)
    
    FreeObj(oJwt)
    FreeObj(oJson)
return(nil)

user function zWMSaUndo()
    local aRet      := {}
    local aPerg     := {}
    local cArquivo	:= "C:\" + Space(100)
    local aLog      := {}

    aAdd(aPerg,{6,"Caminho:  ",cArquivo ,"","",.F.,90,.T.,"Arquivos TXT (*.txt) |*.txt",'\'})
	
    if ParamBox(aPerg, "Parametros", @aRet)
        aLog := readMyArq(aRet[01])
        if !empty(aLog)
           FWMsgRun(, { |oSay| unDoProcess(aLog, oSay)}, 	"Estorno Inventário CBCWMS", "Processando Estornos...")
        endif
    endif
return(nil)

static function readMyArq(cFile)
    local oFile := FWFileReader():New(cFile)
    local aRet  := {}

    if (oFile:Open())
        if (oFile:hasLine())
            aRet := oFile:getAllLines()
        endif
        oFile:Close()
    endif
    FreeObj(oFile)
return(aRet)

static function unDoProcess(aLog, oSay)
    local oInt      := cbcAlmoxInteg():newcbcAlmoxInteg()
    local oAjustes  := JsonObject():new()
    local cDe       := ''
    local cAte      := ''
    local lRet      := .T.
    local nX        := 0
    local nEndOri   := 0
    local nEndDest  := 0
    local cArqGera	:= "\ExpIntegra\"+'UNDO_Inv_' + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + '.txt'
    local oJwt      := cbcJwtAuth():newcbcJwtAuth()

    oJwt:vldToken(aLog[1])
    if(oJwt:aResult[1])
        cDe := aLog[2]
        cAte:= aLog[3]
        if oSay <> nil
            oSay:SetText('Obtendo lista de Ajustes Originais...')
            ProcessMessage()
        endif
        oAjustes:FromJson(aLog[4])
        if (len(oAjustes['mov']) > 0 .and. len(oAjustes['upd']) > 0)
            if oSay <> nil
                oSay:SetText('Verificando movimentações de Estornos...')
                ProcessMessage()
            endif        
            for nX := 1 to len(oAjustes['mov'])
                nEndOri     := oAjustes['mov'][nX]['enderecoId']
                nEndDest    := oAjustes['mov'][nX]['endMovId']
                if nEndDest == 0
                    oAjustes['mov'][nX]['tipo'] := "ENTRADA"
                else
                    oAjustes['mov'][nX]['enderecoId'] := nEndDest
                    oAjustes['mov'][nX]['endMovId']   := nEndOri
                endif
            next nX
            if oSay <> nil
                oSay:SetText('Realizando movimentações de Ajustes...')
                ProcessMessage()
            endif
            lRet := oInt:doMovimento(oAjustes):isOk()
            if lRet
                if oSay <> nil
                    oSay:SetText('Gravando Arquivo de Log...')
                    ProcessMessage()
                endif
                MemoWrite(cArqGera, oAjustes:ToJson())
            endif
        else
            MsgInfo('Sem ajustes a serem estornados no WMS!', 'Estornos WMS')
        endif
        /*
        if lRet
            if oSay <> nil
                oSay:SetText('Reabrindo inventário no WMS...')
                ProcessMessage()
            endif
            lRet := oInt:chgStsInvent(cConvDe, cConvAte, 0)
        endif
        */
    else  
        alert(oJwt:aResult[2])
    endif 
    FreeObj(oJwt)
    FreeObj(oInt)
return(nil)

static function HandleEr(oErr, aRet)
    default aRet := {}
    aRet := {.F., oErr:Description}
    if InTransact()
        DisarmTransaction()
    endif
    Alert(oErr:Description, 'Error')
    BREAK
return(nil)
