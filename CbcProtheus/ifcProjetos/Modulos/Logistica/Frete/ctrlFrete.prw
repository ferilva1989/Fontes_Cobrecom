#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'Totvs.ch'
#include 'FWMVCDef.ch'

Class ctrlFrete
    Data lOk
    Data cMsgErr
    Data lShowErr

    Method newctrlFrete()
    Method setStatus()
    Method isOk()
    Method getErrMsg()
    Method showErr()
    Method add()
    Method delete()
    Method update()
EndClass

Method newctrlFrete(lShowErr) class ctrlFrete
    Default lShowErr := .T.
    ::lShowErr  := lShowErr
    ::setStatus()
Return (self)

Method setStatus(lOk, cMsgErr, lEx, lShow) class ctrlFrete
    Default lOk     := .T.
    Default cMsgErr := ''
    Default lEx     := .F.
    Default lShow   := ::showErr()

    ::lOk       := lOk
    If !(lOk)
        ::cMsgErr   := '[ctrlFrete] - ' + cMsgErr
        If lEx
            UserException(::getErrMsg())
        Else
            If (lShow)
                MsgAlert(::getErrMsg(),'Erro - ctrlFrete')
            EndIf
        EndIf
    EndIf
Return (self)

Method isOk() class ctrlFrete
Return (::lOk)

Method getErrMsg() class ctrlFrete
Return (::cMsgErr)

Method showErr() class ctrlFrete
Return (::lShowErr)

Method add(aDados) class ctrlFrete
    Local aArea     := GetArea()
    Local aRet      := {.F.,''}
    Local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @self)})
    Local aAreaZF1  := ZF1->(GetArea())
    Default aDados  := {}
    
    If ::setStatus(!empty(aDados), 'Dados Inválidos!'):isOk()
        BEGIN SEQUENCE
            BEGIN TRANSACTION
                If ::setStatus(validData(@self,aDados), 'Transportadora ou valores invalidos'):isOk()
                    aRet := crudZF1(formatData(aDados), MODEL_OPERATION_INSERT)
                    If !aRet[1]
                        ::SetStatus(aRet[1],aRet[2], .T.)
                    EndIf
                EndIf
            END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
    EndIf
    RestArea(aAreaZF1)
    RestArea(aArea)
Return (aRet[1])

Method update(aDados, nRec) class ctrlFrete
    Local aArea     := GetArea()
    Local aAreaZF1  := ZF1->(GetArea())
    Local aRet      := {.F.,''}
    Local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @self)})
    Local oSql 	    := LibSqlObj():newLibSqlObj()
    Default nRec    := 0
    Default aDados  := {}

    If ::setStatus(!empty(aDados), 'Dados Inválidos!'):isOk()
        BEGIN SEQUENCE
            BEGIN TRANSACTION
                If ::setStatus(validData(@self,aDados), 'Transportadora ou Regras invalidas'):isOk()
                    If nRec <= 0
                        oSql:newAlias(getRecZF1(aDados))
                        If oSql:hasRecords()
                            DbSelectArea('ZF1')
                            oSql:goTop()
                            nRec := oSql:getValue("REC")
                        Endif
                        oSql:close()
                        If nRec <= 0
                            ::setStatus(.F., 'Não foi possivel atualizar o registro', .F.)
                        EndIf
                    EndIf
                    aRet := crudZF1(formatData(aDados), MODEL_OPERATION_UPDATE, nRec)
                    If !aRet[1]
                        ::SetStatus(aRet[1],aRet[2], .T.)
                    EndIf
                EndIf
            END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
    EndIf
    RestArea(aAreaZF1)
    RestArea(aArea)
    FreeObj(oSql)
Return (aRet[1])

Method delete(aDados, lDelAll, nRec) class ctrlFrete
    Local aArea     := GetArea()
    Local aAreaZF1  := ZF1->(GetArea())
    Local aRet      := {.F.,''}
    Local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @self)})
    Local oSql 	    := LibSqlObj():newLibSqlObj()
    Default nRec    := 0
    Default aDados  := {}
    Default lDelAll := .F.

    If ::setStatus(!empty(aDados), 'Dados Inválidos!'):isOk()
        BEGIN SEQUENCE
            BEGIN TRANSACTION
                If ::setStatus(validData(@self,aDados, .T.), 'Transportadora ou Regras invalidas'):isOk()
                    If nRec <= 0 .Or. lDelAll
                        oSql:newAlias(getRecZF1(aDados, lDelAll))
                        oSql:goTop()
                        While oSql:notIsEof()
                            If oSql:hasRecords()
                                DbSelectArea('ZF1')
                                nRec := oSql:getValue("REC")
                            Endif
                            If nRec <= 0
                                ::setStatus(.F., 'Nao foi possivel atualizar o registro', .F.)
                            EndIf
                            aRet := crudZF1(formatData(aDados, .T.), MODEL_OPERATION_DELETE, nRec)
                            If !aRet[1]
                                ::SetStatus(aRet[1],aRet[2], .T.)
                                DisarmTransaction()
                                exit
                            EndIf
                            oSql:Skip()
                        EndDo
                    Else
                        aRet := crudZF1(formatData(aDados, .T.), MODEL_OPERATION_DELETE, nRec)
                        If !aRet[1]
                            ::SetStatus(aRet[1],aRet[2], .T.)
                            DisarmTransaction()
                        EndIf
                    EndIf
                EndIf
            END TRANSACTION
            RECOVER
        END SEQUENCE
        ErrorBlock(bErro)
    EndIf
    oSql:close()
    FreeObj(oSql)
    RestArea(aAreaZF1)
    RestArea(aArea)
Return (aRet[1])

/*services*/
Static Function crudZF1(aValues, cOper, nRec)
    Local lRet 		    := .F.
    Local nX		    := 0
    Local oModel	    := Nil
    Local aErro		    := {}
    Local cErro		    := ''
    Default nRec        := 0
    Default aValues     := {}

    dbselectArea('ZF1')
    oModel := FWLoadModel('cbcMdlZF1')
    oModel:SetOperation(cOper)
    If !empty(nRec)
        ZF1->(DbGoTo(nRec))
    EndIf
    oModel:Activate()
    If cOper <> MODEL_OPERATION_DELETE
        For nX := 1 To len(aValues)
            oModel:LoadValue('ZF1MASTER',aValues[nX,1], aValues[nX,2])
        Next nX
    EndIf
    If !(lRet := FWFormCommit(oModel))
        aErro := oModel:GetErrorMessage()
        If !empty(aErro)
            cErro += aErro[2] + '-'
            cErro += aErro[4] + '-'
            cErro += aErro[5] + '-'
            cErro += aErro[6]
        EndIf
    EndIf
    oModel:DeActivate()
    FreeObj(oModel) 
Return ({lRet,cErro})

Static Function validData(oSelf, aData, lDel)
    Local aArea     := GetArea()
    Local aAreaSA4  := SA4->(GetArea())
    Local lRet      := .T.
    Local oSql 	    := LibSqlObj():newLibSqlObj()
    Local nPosTra   := 0
    Local nPosJs    := 0
    Default aData   := {}
    Default lDel    := .F.

    nPosTra   := aScan(aData, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_TRANSP")})
    nPosJs    := aScan(aData, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_JSCALC")})

    oSql:newAlias(qryTransp(aData[nPosTra][1]))
    If !oSql:hasRecords()              
        lRet := .F.
        oSelf:setStatus(.F., 'Transportadora Não Encontrada!', .T.)
    Endif
    oSql:close()

    If !lDel
        If VALTYPE(aData[nPosJs][1]) != 'C' //Json Regras, SE FOR JSON É 'O'->OBJETO
            lRet := .F.
            oSelf:setStatus(.F., 'Regras Invalidas!', .T.)
        EndIf 
    EndIf 

    RestArea(aAreaSA4)
    RestArea(aArea)
    FreeObj(oSql)
Return (lRet)

Static Function formatData(aDados, lDel)
    Local aRetData  := {}
    Local aCampos   := {'ZF1_FILIAL','ZF1_TRANSP', 'ZF1_NRREG', 'ZF1_ROTA', 'ZF1_JSCALC', 'ZF1_DTINC', 'ZF1_DTFIM', 'ZF1_ICMS'}
    Local nPosFil   := aScan(aDados, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_FILIAL")})
    Local nPosTra   := aScan(aDados, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_TRANSP")})
    Local nPosUf    := aScan(aDados, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_NRREG")})
    Local nPosRota  := aScan(aDados, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_ROTA")})
    Local nPosJs    := aScan(aDados, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_JSCALC")})
    Local nPosInc   := aScan(aDados, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_DTINC")})
    Local nPosFim   := aScan(aDados, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_DTFIM")})
    Local nPosIcms  := aScan(aDados, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_ICMS")})
    Default lDel    := .F.

    Aadd(aRetData, { aCampos[1], aDados[nPosFil][1] })
    Aadd(aRetData, { aCampos[2], aDados[nPosTra][1] })
    Aadd(aRetData, { aCampos[3], aDados[nPosUf][1] })
    Aadd(aRetData, { aCampos[4], aDados[nPosRota][1] })
    If !lDel
        Aadd(aRetData, { aCampos[5], aDados[nPosJs][1] })
        Aadd(aRetData, { aCampos[6], aDados[nPosInc][1] })
        Aadd(aRetData, { aCampos[7], aDados[nPosFim][1] })
        Aadd(aRetData, { aCampos[8], aDados[nPosIcms][1] })
    EndIf
Return aRetData

Static Function getRecZF1(aDados, lDelTransp)
    Local cQry  := ''
    Local nPosFil   := aScan(aDados, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_FILIAL")})
    Local nPosTra   := aScan(aDados, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_TRANSP")})
    Local nPosUf    := aScan(aDados, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_NRREG")})
    Local nPosRota  := aScan(aDados, {|x| AllTrim(Upper(x[2])) == AllTrim("ZF1_ROTA")})
    Default lDelTransp := .F.

    cQry+= " SELECT R_E_C_N_O_ AS [REC] "
    cQry+= " FROM " + retSqlName('ZF1')
    cQry+= " WHERE ZF1_FILIAL = '" + aDados[nPosFil][1] + "' "
    cQry+= " AND ZF1_TRANSP = '" + aDados[nPosTra][1] + "' "
    If !lDelTransp
        cQry+= " AND ZF1_NRREG = '" + aDados[nPosUf][1] + "' "
        cQry+= " AND ZF1_ROTA = '" + aDados[nPosRota][1] + "' "
    EndIf
    cQry+= " AND D_E_L_E_T_ = '' "
Return cQry

Static Function qryTransp(cTransp)
    Local cQry  := ''

    cQry+= " SELECT A4_COD AS [CODIGO] "
    cQry+= " FROM " + retSqlName('SA4')
    cQry+= " WHERE A4_FILIAL = '" + xFilial('SA4') + "' "
    cQry+= " AND A4_COD = '" + cTransp + "' "
    cQry+= " AND A4_MSBLQL <> '1' "
    cQry+= " AND D_E_L_E_T_ = '' "
Return cQry

Static Function HandleEr(oErr, oSelf)
    If InTransact()
        DisarmTransaction()
    EndIf
    oSelf:setStatus(.F., oErr:Description)
    BREAK
Return (Nil)
