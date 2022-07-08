#Include "Protheus.ch"
  

user Function zCbcAltPed(nRecPed)
    local aArea       := GetArea()
    local aAreaC5     := SC5->(GetArea())
    local aAreaC6     := SC6->(GetArea())
    local aCampos     := {}
    local aCampAlt    := {}
    local oFil		  := cbcFiliais():newcbcFiliais()
    local bErro		  := ErrorBlock({|oErr| HandleEr(oErr)})
    default nRecPed   := 0
     
    
    BEGIN SEQUENCE
        if nRecPed > 0
            DbSelectArea("SC5")
            ChkFile("SC5")
            SC5->(DbGoTo(nRecPed))
        endif
        if ! lVldAlt()
            MsgInfo('Pedido não pode ser alterado', 'Validação')
        else
            if ! oCrud(@aCampAlt)
                MsgInfo('Campos não carregados', 'Validação JSON')
            else
                // Somente Visualizar
                aCampos := aClone(aCampAlt)
                aAdd(aCampos, 'C5_NUM')
                aAdd(aCampos, 'C5_TIPO')
                aAdd(aCampos, 'C5_CLIENTE')
                aAdd(aCampos, 'C5_LOJACLI')
                aAdd(aCampos, 'C5_CONDPAG')
                aAdd(aCampos, 'C5_EMISSAO')
                aAdd(aCampos, 'NOUSER')

                // Tela para alteração de pedido de venda já liberado
                oFil:setFilial(SC5->(C5_FILIAL))
                    zdoAlt(aCampos, aCampAlt)
                oFil:backFil()
            Endif
        endif
        RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
    
    FreeObj(oFil)
    ChkFile("SC5")
    RestArea(aAreaC6)
    RestArea(aAreaC5)
    RestArea(aArea)
return(nil)
 

static function oCrud(aCampAlt)
    local oCrud       := nil
    local cPath       := GetNewPar('ZZ_ALTC5JS', 'C5ALTER')
    local aItm        := {}
    local isAdm       := FwIsAdmin()
    local nX          := 0
    local lRet        := .F.
    oCrud := jsonCrud():newjsonCrud(cPath, !isAdm)
    if !(lRet := oCrud:itsOk())
		Alert( oCrud:getMsgLog() )
    else
        if isAdm
            oCrud:showDialog()
        endif
        aItm :=  oCrud:getJson('AREGISTROS')
        for nX := 1 to len(aItm)
            fieldRule(@aCampAlt, upper(aItm[nX]))
        next nX
    endif
    FreeObj(oCrud)
return(lRet)


static function lVldAlt()
    local CondPode     as logical
    CondPode := .F.
    CondPode := SC5->(C5_FILIAL) $ GetNewPar('ZZ_FILALMG', '03') .And. (((Empty(SC5->(C5_LIBEROK));
    .And.Empty(SC5->(C5_NOTA)));
    .Or. (!Empty(SC5->(C5_LIBEROK)) .And.Empty(SC5->(C5_NOTA)))))
return(CondPode)


static function fieldRule(aCampAlt, cField)
    aAdd(aCampAlt, cField)
return(nil)


static function GrvLog(aLog)
    local nX      as numeric
    local aDadC5  as array
    Local oStatic := IfcXFun():newIfcXFun()
    private _aEventos := {"02-Alteracao de Pedidos MG"}
    default aLog := {}
    nX      := 1
    aDadC5 := {SC5->(C5_NUM),SC5->(C5_CLIENTE),SC5->(C5_LOJACLI),SC5->(C5_ENTREG),SC5->(C5_TIPO)}
    for nX :=1  to len(aLog)
        oStatic:sP(7):callStatic('CDGEN21','GrvEvent', .F., 1, ,aLog[nX][1],aLog[nX][2], aLog[nX][3],aDadC5 )
    next nX
return(nil)


static function zdoAlt(aCampos, aCampAlt)
    local aArea      := GetArea()
    local aAreaC5    := SC5->(GetArea())
    local oDlgPed
    local oGrpAco
    local oBtnConf
    local oBtnCanc
    local cAliasE     := 'SC5'
    local lConfirm    := .F.
    local nTamBtn     := 50
    local aTamanho    := MsAdvSize()
    local nJanLarg    := aTamanho[5]
    local nJanAltu    := aTamanho[6]
    local nReg        := SC5->(RecNo())
    local aPos        := {001, 001, (nJanAltu/2)-30, (nJanLarg/2)}
    local nModelo     := 1
    local lF3         := .T.
    local lMemoria    := .T.
    local lColumn     := .F.
    local caTela      := ""
    local lNoFolder   := .F.
    local lProperty   := .F.
    local nCampAtu    := 0
    local bCampo      := {|nField| Field(nField)}
    local aLog        := {}
    local xVlrTela    := ''
    local xVlrAtual   := ''
    private aGets     := Array(0)
    private aHeader   := Array(0)
    private aCols     := Array(0)
    private Altera    := .T.
    private Inclui    := .F.
    private n         := 0

    Begin Transaction
        DEFINE MsDialog oDlgPed TITLE "Alteração de Pedido de Venda" FROM 000,000 TO nJanAltu,nJanLarg PIXEL
            RegToMemory(cAliasE, .F., .F.)
            Enchoice(    cAliasE,;
                        nReg,;
                        4,;
                        /*aCRA*/,;
                        /*cLetra*/,;
                        /*cTexto*/,;
                        aCampos,;
                        aPos,;
                        aCampAlt,;
                        nModelo,;
                        /*nColMens*/,;
                        /*cMensagem*/,;
                        /*cTudoOk*/,;
                        oDlgPed,;
                        lF3,;
                        lMemoria,;
                        lColumn,;
                        caTela,;
                        lNoFolder,;
                        lProperty)
             
            //Grupo de Ações
            @ (nJanAltu/2)-27, 001 GROUP oGrpAco TO (nJanAltu/2)-3, (nJanLarg/2) PROMPT "Alteração de Pedido de Venda Liberado / Faturado: "    OF oDlgPed COLOR 0, 16777215 PIXEL
                @ (nJanAltu/2)-20, (nJanLarg/2)-((nTamBtn*1)+03) BUTTON oBtnConf PROMPT "Confirmar" SIZE nTamBtn, 013 OF oDlgPed PIXEL ACTION (lConfirm := .T., oDlgPed:End())
                @ (nJanAltu/2)-20, (nJanLarg/2)-((nTamBtn*2)+06) BUTTON oBtnCanc PROMPT "Cancelar"  SIZE nTamBtn, 013 OF oDlgPed PIXEL ACTION (lConfirm := .F., oDlgPed:End())
             
        ACTIVATE MsDialog oDlgPed CENTERED
         
        if lConfirm
            DbSelectArea(cAliasE)
            if(RecLock(cAliasE, .F.))
                for nCampAtu := 1 To FCount()
                    if "FILIAL" $ FieldName(nCampAtu)
                        FieldPut(nCampAtu, FWxFilial(cAliasE))
                    else
                        xVlrAtual := (cAliasE)->&(eVal(bCampo, nCampAtu))
                        xVlrTela  :=  M->&(eVal(bCampo, nCampAtu))
                        if xVlrAtual != xVlrTela
                            aadd(aLog,{FieldName(nCampAtu),xVlrAtual ,xVlrTela})
                            FieldPut(nCampAtu, xVlrTela)
                        endif
                    endif
                next
                (cAliasE)->(DbCommit())
                (cAliasE)->(MsUnlock())
                GrvLog(aLog)
            endif
        else
            DisarmTransaction()
        endif
         
    End Transaction
     
    RestArea(aAreaC5)
    RestArea(aArea)
return


static function HandleEr(oErr)
	if InTransact()
        DisarmTransaction()
    endif
    MsgInfo(oErr:Description,'erro')
    BREAK
return (nil)
