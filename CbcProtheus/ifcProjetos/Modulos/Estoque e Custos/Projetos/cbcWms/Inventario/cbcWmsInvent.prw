#INCLUDE "TOTVS.CH"
#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'FWMVCDef.ch'

user function cbcWmsInvent()
    local aRet      := {}
    local aPerg     := {}
    local aFilter   := {}
    local lOk       := .T.
    local lGeral    := .F.

    aadd(aPerg,{1,"Data Inventário: ", dDataBase,"",".T.","",".T.",50,.T.})
    aadd(aPerg,{1,"Data Cont. De: ",   dDataBase,"",".T.","",".T.",50,.T.})
    aadd(aPerg,{1,"Data Cont. Até: ",  dDataBase,"","MV_PAR02 <= MV_PAR03","",".T.",50,.T.})
    if FwIsAdmin()
        aadd(aPerg,{3,"Processamento: ",   1,        {"Geral", "Rotativo"},50,"",.T.})
    endif

    if (ParamBox(aPerg,"Inventário " + iif(FwIsAdmin(), '', 'Rotativo ') +  "cbcWMS",@aRet))
        if len(aRet) == 04
            if aRet[04] == 1
                lGeral := .T.
                FWMsgRun(, { |oSay| lOk := loadCount(DtoS(aRet[01]), DtoS(aRet[02]), DtoS(aRet[03]), oSay)[1]}, 	"Importador CBCWMS", "Importando Contagens...")
            else
                lOk := MsgYesNo('Processar Rotativo não gera importação do resultado para o Protheus. Prosseguir?','Processamento Rotativo')
            endif
        endif
        if lOk
            if !lGeral
                aFilter := filterAddress()
            endif
            if lGeral .or. !empty(aFilter)
                FWMsgRun(, { |oSay| procWms(DtoS(aRet[02]), DtoS(aRet[03]), aFilter, oSay)}, 	"Ajustes CBCWMS", "Processando Ajustes...")
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
    oModal:setTitle('Inserir Endereços do WMS')
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

static function loadCount(cDtInv, cDataDe, cDataAte, oSay)
    local aArea    	:= GetArea()
    local aAreaSZG	:= SZG->(getArea())
    local oInt      := cbcExpIntegra():newcbcExpIntegra()
    local oJson     := JsonObject():new()
    local aOK       := {.T., ''}
    local aRet      := {.T., ''}
    local aLog      := {}
    local cConvDe   := Year2Str(StoD(cDataDe))  + '-' + Month2Str(StoD(cDataDe))   + '-' + Day2Str(StoD(cDataDe))
    local cConvAte  := Year2Str(StoD(cDataAte)) + '-' +  Month2Str(StoD(cDataAte)) + '-' + Day2Str(StoD(cDataAte))
    local nX        := 0
    local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @aRet)})

    oJson:fromJSON(oInt:GetInvent(cConvDe, cConvAte))
    if empty(oJson[01])
        MsgInfo('Não foram encontradas contagens para importação', 'Sem Contagens')
    else
        BEGIN SEQUENCE
            BEGIN TRANSACTION
            if oSay <> nil
                oSay:SetText('Limpando importações anteriores...')
                ProcessMessage()
            endif
            clearCounts(cDtInv)
            dbselectArea('SZG')
            for nX := 1 to len(oJson[01])
                if oSay <> nil
                    oSay:SetText('Importando Coletas: ' + cValtoChar(nX)  + ' de ' + cValToChar(len(oJson[01])))
                    ProcessMessage()
                endif
                if oJson[01,nX]['final'] > 0
                    if SubStr(oJson[01,nX]['acond'],1,1) == 'B'
                        if oSay <> nil
                            oSay:SetText('Atualizando Status da Bobina: ' + Right(AllTrim(oJson[01,nX]['barint']),TamSx3('ZE_NUMBOB')[1]))
                            ProcessMessage()
                        endif
                        aOK := atuDtBob(cDtInv, SubStr(oJson[01,nX]['barint'],3,2), Right(AllTrim(oJson[01,nX]['barint']),TamSx3('ZE_NUMBOB')[1]))
                    else
                        aOK := {.T.,''}
                    endif
                    if aOK[01]
                        RecLock("SZG",.T.)
                            SZG->ZG_FILIAL		:= xFilial('SZG')
                            SZG->ZG_PRODUTO		:= Padr(oJson[01,nX]['produto'], TamSx3('ZG_PRODUTO')[1])
                            SZG->ZG_ACOND		:= SubStr(oJson[01,nX]['acond'],1,1)
                            SZG->ZG_LANCE		:= Val(SubStr(oJson[01,nX]['acond'],2,5))
                            SZG->ZG_METROS		:= Val(SubStr(oJson[01,nX]['acond'],2,5)) * oJson[01,nX]['final']
                            SZG->ZG_LOTE		:= "cbcWMS"
                            SZG->ZG_QUANT		:= oJson[01,nX]['final']
                            SZG->ZG_DATA		:= StoD(cDtInv)
                            SZG->ZG_CONTAG		:= "3"
                            SZG->ZG_LOCAL		:= "01"
                            SZG->ZG_DESC		:= Posicione("SB1",1,xFilial("SB1")+ Padr(oJson[01,nX]['produto'], TamSx3('B1_COD')[1]),"B1_DESC")
                            SZG->ZG_QTDEINV		:= Val(SubStr(oJson[01,nX]['acond'],2,5)) * oJson[01,nX]['final']
                            SZG->ZG_PESCOB		:= (Val(SubStr(oJson[01,nX]['acond'],2,5)) * oJson[01,nX]['final'])* Posicione("SB1",1,xFilial("SB1")+ Padr(oJson[01,nX]['produto'], TamSx3('B1_COD')[1]),"B1_PESCOB")
                            SZG->ZG_PESPVC		:= (Val(SubStr(oJson[01,nX]['acond'],2,5)) * oJson[01,nX]['final'])* Posicione("SB1",1,xFilial("SB1")+ Padr(oJson[01,nX]['produto'], TamSx3('B1_COD')[1]),"B1_PESPVC")
                            SZG->ZG_UM			:= Posicione("SB1",1,xFilial("SB1")+ Padr(oJson[01,nX]['produto'], TamSx3('B1_COD')[1]),"B1_UM")
                            SZG->ZG_FORMA		:= "I"
                        SZG->(MsUnLock())
                    else
                        aAdd(aLog, {oJson[01,nX]['produto'], oJson[01,nX]['acond'], AllTrim(oJson[01,nX]['barint']), oJson[01,nX]['final'], AllTrim(aOK[02])})
                    endif
                endif
            next nX
            END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
    endif
    if !empty(aLog) .and. aRet[01]
        if oSay <> nil
            oSay:SetText('Gerando Arquivo de Logs...')
            ProcessMessage()
        endif
        oInt:genLog(FwFilial() + 'Invent', aLog)
    endif
    FreeObj(oInt)
    FreeObj(oJson)
    RestArea(aAreaSZG)
    RestArea(aArea)
return(aRet)

static function atuDtBob(cDtInv, cFiliOri, cNumBob)
    local aArea    	:= GetArea()
    local aAreaSZE	:= SZE->(getArea())
    local aRet      := {.F., 'Bobina não localizada'}
    local oSql      := LibSqlObj():newLibSqlObj()

	oSql:newAlias(qryGetBob(cDtInv, cFiliOri, cNumBob))
	if oSql:hasRecords()
		oSql:goTop()
        DbSelectArea('SZE')
        if StoD(oSql:getValue("FAT")) > StoD(cDtInv)
            SZE->(DbGoTo(oSql:getValue("REC")))
            SZE->(RecLock("SZE",.F.))
                if(AllTrim(oSql:getValue("STATUS")) == 'C')
			        SZE->ZE_STATUS := 'T'
                endif
                SZE->ZE_DTINV := StoD(cDtInv)
			SZE->(MsUnLock())
            aRet := {.T.,''}
        else
            aRet := {.F., 'Bobina Faturada'}
        endif
	endif
	oSql:close()
	FreeObj(oSql)
    RestArea(aAreaSZE)
    RestArea(aArea)
return(aRet)

static function clearCounts(cDtInv)
    local aArea    	:= GetArea()
    local aAreaSZG	:= SZG->(getArea())
    local aRet := {.T., ''}
    local oSql := LibSqlObj():newLibSqlObj()
    oSql:newAlias(qryClear(cDtInv))
    if oSql:hasRecords()
        oSql:goTop()
        DbSelectArea('SZG')
        while oSql:notIsEof()
            SZG->(DbGoTo(oSql:getValue("REC")))
            SZG->(RecLock("SZG",.F.))
			    SZG->(DbDelete())
			SZG->(MsUnLock())
            oSql:Skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)
    RestArea(aAreaSZG)
    RestArea(aArea)
return(aRet)

static function procWms(cDe, cAte, aFilter, oSay)
    local oInt      := cbcExpIntegra():newcbcExpIntegra()
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

user function zWMSIundo()
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
    local oInt      := cbcExpIntegra():newcbcExpIntegra()
    local oAjustes  := JsonObject():new()
    local cDe       := ''
    local cAte      := ''
    local lRet      := .T.
    local nX        := 0
    local nEndOri   := 0
    local nEndDest  := 0
    local cArqGera	:= "\ExpIntegra\"+'UNDO_Inv_' + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + '.txt'
    local oJwt  := cbcJwtAuth():newcbcJwtAuth()

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

/*QUERY ZONE*/
static function qryClear(cDtInv)
    local cQry := ''

    cQry += " SELECT SZG.R_E_C_N_O_ AS [REC]"
    cQry += " FROM " + retSqlName('SZG') + " SZG "
    cQry += " WHERE SZG.ZG_FILIAL = '" + xFilial('SZG') + "' "
    cQry += " AND SZG.ZG_DATA = '" + cDtInv + "' "
    cQry += " AND SZG.ZG_LOTE = 'cbcWMS' "
    cQry += " AND SZG.D_E_L_E_T_ = '' "
return(cQry)

static function qryGetBob(cDtInv, cFiliOri, cNumBob)
    local cQry := ''

    cQry += " SELECT SZE.R_E_C_N_O_ AS [REC], "
    cQry += " SZE.ZE_STATUS AS [STATUS], "
    cQry += " ISNULL(SF2.F2_EMISSAO, '" + DtoS(DaySum(StoD(cDtInv), 1)) + "') AS [FAT] "
    cQry += " FROM " + retSqlName('SZE') + " SZE "
    cQry += " LEFT JOIN " + retSqlName('SF2') + " SF2 "
    cQry += " ON SZE.ZE_FILIAL = SF2.F2_FILIAL "
    cQry += " AND SZE.ZE_DOC = SF2.F2_DOC "
    cQry += " AND SZE.ZE_SERIE = SF2.F2_SERIE "
    cQry += " AND SZE.D_E_L_E_T_ = SF2.D_E_L_E_T_ "
    cQry += " WHERE SZE.ZE_FILIAL = '" + xFilial('SZE') + "' "
    cQry += " AND SZE.ZE_FILORIG = '" + AllTrim(cFiliOri) + "' "
    cQry += " AND SZE.ZE_NUMBOB = '" + AllTrim(cNumBob) + "' "
    cQry += " AND SZE.D_E_L_E_T_ = ''     "
return(cQry)
