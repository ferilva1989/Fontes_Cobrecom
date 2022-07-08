#include 'protheus.ch'
#include 'parmtype.ch'

user function impPlanSA3()
    local aParamBox := {}
    local aRetPar   := {}
    local aDados    := {}
    local nRec      := 0
    local cSeg      := ""
    local nX        := 0
    local nTam      := 0
    local cArq      := ''
    local cOrigem   := ''
    local bErro     := ErrorBlock({|oErr| HandleEr(oErr)})

    aAdd(aParamBox,{6,"Informe Planilha",Space(70),"","","" ,70,.T.,"Arquivo .XLS |*.XLS"})
    if ParamBox(aParamBox, "Parametros", @aRetPar)
        cArq 	:= Alltrim(Substr(aRetPar[1],rat("\",aRetPar[1])+1,len(aRetPar[1])))
        cOrigem	:= Alltrim(Substr(aRetPar[1],1,rat("\",aRetPar[1])))
        Processa( {|| aDados:= U_CargaXLS(cArq,cOrigem,,.F.)},"Aguarde, carregando planilha...Pode demorar")
		if !empty(aDados)
            DbSelectArea('SA3')
        	BEGIN SEQUENCE
                BEGIN TRANSACTION
                    nTam := len(aDados)
                    ProcRegua(nTam)
                    for nX := 1 to nTam
                        IncProc("Processando "+cValToChar(nX)+" de "+cValToChar(nTam))
                        nRec := getRecs(val(aDados[nX, 02]))
                        cSeg := getSegmento(aDados[nX, 03])
                        if !empty(nRec) .and. !empty(cSeg)
                            SA3->(DbGoTo(nRec))
                            SA3->(RecLock("SA3",.F.))
                                SA3->A3_ZWHTAPP := "55" + cValToChar(val(aDados[nX, 05]))
                                SA3->A3_ZSEGMEN := cSeg
                                SA3->A3_ZUSECOB := '2'
                            SA3->(MsUnLock())
                        endif
                    next nX	
                END TRANSACTION
                RECOVER
            END SEQUENCE
            ErrorBlock(bErro)
		else
            Alert('Falhou importação planilha!')
        endif
    endif
return(nil)

static function getRecs(nCod)
    local nRec := 0
    local oSql := LibSqlObj():newLibSqlObj()
    
    oSql:newAlias(qryfind(nCod))
    if oSql:hasRecords()
        oSql:goTop()
        nRec := oSql:getValue("REC")
    endif
    oSql:Close()
    FreeObj(oSql)
return(nRec)

static function qryfind(nCod)
    local cQry := ""
    cQry += " SELECT SA3.R_E_C_N_O_ AS [REC] "
    cQry += " FROM SA3010 SA3 "
    cQry += " WHERE CAST(SA3.A3_COD AS INT) = " + cValToChar(nCod)
    cQry += " AND SA3.D_E_L_E_T_ = '' "
return(cQry)

static function getSegmento(cTxt)
    local cSeg := ""

    if AllTrim(cTxt) == 'Engenharia'
        cSeg := 'E'
    elseif AllTrim(cTxt) == 'Revendedor / Engenharia'
        cSeg := 'A'
    elseif AllTrim(cTxt) == 'EXPORTA€ÇO' .or. AllTrim(cTxt) == 'EXPORTACAO'
        cSeg := 'X'
    else
        cSeg := 'R'
    endif
return(cSeg)


static function HandleEr(oErr)
    if InTransact()
        DisarmTransaction()
    endif
    MsgAlert(oErr:Description, 'Erro')
    BREAK
return(nil)
