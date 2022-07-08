#Include "Protheus.ch"
#Include "TbiConn.ch"
#Include "totvs.ch"
#Include 'FWMVCDef.ch'

#DEFINE OP_LIB	"001" // Liberado
#DEFINE OP_EST	"002" // Estornar
#DEFINE OP_SUP	"003" // Superior
#DEFINE OP_TRA	"004" // Transferir Superior
#DEFINE OP_REJ	"005" // Rejeitado
#DEFINE OP_BLQ	"006" // Bloqueio
#DEFINE OP_VIW	"007" // Visualizacao 
#DEFINE APR_MEMP34      "000001" // Grupo aprovadores produto ME ou MP03 MP04
#DEFINE APR_GERAL       "000001" // Aprovador geral
#DEFINE APR_LIMITADO    "000007" // Aprovador limitado

/* Adicionar opções no menu de liberação de documentos */
user function MTA094RO()
    local aRot := PARAMIXB[1]
    /*
        Aadd(aRot,{'cbcLib',"u_cbcLibPC()", 0, 4,0,NIL})
        Aadd(aRot,{'cbcRej',"u_cbcrejPC()", 0, 4,0,NIL})
    */
return(aRot)

/*
    
    u_cbcGetPC(cUsr)             -> Obter lista dp que tem que aprovar 
    u_cbcRejPC(nRecScr, cMotivo) -> Rejeitar
    u_cbcLibPC(nRecScr)          -> Aprovar
*/

/*OBTER DOCUMENTOS PARA APROVAÇÂO*/
user function cbcGetPC(cUsr, cSts)
    local oSql      := nil
    local oJsret    := nil
    local oJsiItm   := nil
    local aHead     := {}
    local nPos      := 0
    default cSts    := '02'
  
    oJsret := JsonObject():new()
    oSql    := LibSqlObj():newLibSqlObj()
    oSql:newAlias(qrySCR(cUsr, cSts))
    oSql:GoTop()
        if oSql:hasRecords()
            oJsret['body'] := {}
            while oSql:notIsEof()
                oJsiItm := JsonObject():new()
                oJsiItm['rec_scr']    := oSql:getValue('RECNO_SCR')
                oJsiItm['rec_sc7']    := oSql:getValue('RECNO_SC7')
                oJsiItm['filial']     := oSql:getValue('FILIAL_PC')
                oJsiItm['pedido']     := oSql:getValue('NUMERO_PC')
                oJsiItm['emissao']    := Dtoc(StoD(oSql:getValue('EMISSAO_PC')))
                oJsiItm['fornecedor'] := Alltrim(oSql:getValue('FORNECEDOR'))
                oJsiItm['produto']    := Alltrim(oSql:getValue('PRODUTO'))
                oJsiItm['qtd']        := Alltrim(Transform(oSql:getValue('QUANTIDADE'),PESQPICT("SC7","C7_QUANT")))
                oJsiItm['preco']      := Alltrim(Transform(oSql:getValue('PRECO'),PESQPICT("SC7","C7_PRECO")))
                oJsiItm['total']      := Alltrim(Transform(oSql:getValue('TOTAL'),PESQPICT("SC7","C7_TOTAL")))
                SC7->(DbGoTo(oSql:getValue('RECNO_SC7')))

                if (nPos := AScan(aHead,{ |a| a[1] == (oJsiItm['filial'] + oJsiItm['pedido']) })) > 0
                    aadd(aHead[nPos][4], oJsiItm['produto'])
                    aHead[nPos][5] += SC7->(C7_QUANT * C7_PRECO) 
                else
                    aadd(aHead, {(oJsiItm['filial'] + oJsiItm['pedido']),;
                                {oJsiItm['rec_scr']},;
                                oJsiItm['fornecedor'],;
                                {oJsiItm['produto']},;
                                SC7->(C7_QUANT * C7_PRECO),;
                                oJsiItm['emissao'],;
                                getSoliInf(SC7->(Recno()))})
                endif
                
                oJsiItm['obj_det']    := JsonObject():new()
                if empty(SC7->(C7_ZDET))
                     oJsiItm['obj_det']:fromJson("{}")
                else
                     oJsiItm['obj_det']:fromJson(SC7->(C7_ZDET))
                endif
                aadd(oJsret['body'],oJsiItm)
                oSql:skip()
            endDo
            oJsret['head'] := aHead
		endif
		oSql:close()
		FreeObj(oSql)
return(oJsret)


/*REJEITAR UM PEDIDO DE COMPRA*/
user function cbcRejPC(nRecScr, cMotivo, cUsr)
    local aRet      := {.T., ''}
    local bkUsr     := RetCodUsr()
    local bkUNm     := cUserName
    local aAllusers := {}
    default nRecScr := SCR->(Recno())
    default cMotivo := "Rejeicao padrão de documento"
    default cUsr    := ""
     if !empty(cUsr)
       if Empty(aAllusers  := FWSFALLUSERS({cUsr}))
            aRet[1] := .F.
            aRet[2] := 'Usuario invalido'
            return aRet
       else
            cUserName  :=  aAllusers[1][3]
            __cUserId  := cUsr
       endif
    endif
    SCR->(DbGoTo(nRecScr))
    if !(SCR->CR_TIPO $ 'SA|ST|SC|PC|IP|CT|IC|RV|IR|MD|IM')
        aRet[1] := .F.
        aRet[2] := I18N('A ação "Rejeitar" não está disponível para documentos do tipo #1',{SCR->CR_TIPO})
        // Help("",1,"A094TIPO",,I18N('A ação "Rejeitar" não está disponível para documentos do tipo #1',{SCR->CR_TIPO}),1,0)
    else
        aRet := U_CbExec094(nRecScr, OP_REJ, cMotivo)
    endif
     if !empty(cUsr)
        __cUserId  := bkUsr
         cUserName := bkUNm
    endif
return aRet


/*APROVAR UM PEDIDO DE COMPRA*/
user function cbcLibPC(nRecScr,cUsr)
    local cAliasSC7   := ''
    local bkUsr       := RetCodUsr()
    local bkUNm       := cUserName
    local aAllusers   := {}
    local aRet        := {.T., ''}
    default nRecScr   := SCR->(Recno())
    default cUsr        := ""
    if !empty(cUsr)
       if Empty(aAllusers  := FWSFALLUSERS({cUsr}))
            aRet[1] := .F.
            aRet[2] := 'Usuario invalido'
            return aRet
       else
            cUserName  :=  aAllusers[1][3]
            __cUserId  := cUsr
       endif
    endif
    SCR->(DbGoTo(nRecScr))
    PcoIniLan("000055")
	if SCR->CR_TIPO = 'PC' .and.  Empty(SCR->CR_GRUPO)
		cAliasSC7 := GetNextAlias()
		cQuery := "SELECT C7_APROV , C7_NUM , C7_FILIAL FROM  " +RetSqlname("SC7")+ "  WHERE C7_NUM ="+"'" + SCR->CR_NUM +"'" + "AND C7_FILIAL ="+"'"+SCR->CR_FILIAL+"'"+" AND D_E_L_E_T_ <> '*' "  	 
		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSC7,.T.,.T.)	
		dbSelectArea(cAliasSC7)	
		while ( !Eof() .And. C7_FILIAL == xFilial("SC7") .And. AllTrim(C7_NUM) == AllTrim(SCR->CR_NUM) )
			cQuery := "UPDATE "+RetSqlname("SCR")		
			cQuery += " SET CR_GRUPO = "+"'"+C7_APROV+"'"
			cQuery += " WHERE CR_FILIAL ='"+xFilial("SCR")+"' AND "
			cQuery += " CR_NUM ='"+C7_NUM+"' AND "
			cQuery += " D_E_L_E_T_ <> '*' "  	 
			TcSqlExec(cQuery)		
			Exit		
			(cAliasSC7)->(dbSkip())
		EndDo	
	endif
	aRet := U_CbExec094(nRecScr, OP_LIB)
	PcoFreeBlq("000055")
    if !empty(cUsr)
        __cUserId := bkUsr
        cUserName := bkUNm
    endif
return aRet

/*
    Ocorre ao clicar no botão "Análise da cotação" na rotina Analisa Cotações (MATA161).
*/
user function MT161PRO()
    local aArea         := getArea()
    local aAreaSC8      := SC8->(GetArea())
    local aPropostas    := PARAMIXB[1]
    local nP            := 0
    local nI            := 0
    local nH            := 0
    for nP := 1 To Len(aPropostas)
        for nI := 1 To Len(aPropostas[nP])
            for nH := 1 To Len(aPropostas[nP][nI][2])
                SC8->(DbGoTo(aPropostas[nP, nI, 2, nH, 9]))
                if aPropostas[nP, nI, 2, nH, 1]
                    reclock('SC8', .F.)
                    SC8->C8_MOTVENC := 'AUTOMATICO ' + Dtoc(date())
                    MsUnlock()
                endif
            next nH
        next nI
    next nP
    restArea(aAreaSC8)
    restArea(aArea)
return aPropostas

/* Executado - logo apos gravação do PC */
user function AVALCOPC()
  local aArea       := getArea()
  local aAreaC7     := SC7->(getArea())
  local oJsQuot := nil
  local oJsHist := nil
  local oJs     := nil
  local oSql    := nil

  oSql     := LibSqlObj():newLibSqlObj()
  oSql:newAlias(qryRec7(SC7->(C7_FILIAL),SC7->(C7_NUM)))
  oSql:GoTop()
  while oSql:notIsEof()
    SC7->(DbGoTo(oSql:getValue('REC')))
    oJs     := JsonObject():new()
    oJsQuot := u_cbcQRYexec(qryQuot(SC7->(Recno())))
    oJsHist := u_cbcQRYexec(qryProd(SC7->(C7_PRODUTO), 'year', 1))
    oJs['data'] := {oJsQuot, oJsHist} 
    if RecLock("SC7",.F.)
        SC7->(C7_ZDET) := oJs:toJson()
        cbcTesInt()
        SC7->(MsUnlock()) 
    endif
    u_AtuNatPc(oSql:getValue('REC'))
    oSql:skip()
  enddo
  oSql:close()
  Freeobj(oSql)
  Freeobj(oJs)
  Freeobj(oJsQuot)
  Freeobj(oJsHist)
  RestArea(aAreaC7)
  RestArea(aArea)
return nil

/*Aplicar regra que define grupo aprovador, e obter detalhes da liberação*/
user function MT120APV()
    local aParam        := {}
    local cGrp          := "000001"
    local aArea         := GetArea()
    local aAreaSC8      := SC8->(GetArea())
    local aAreaSC1      := SC1->(GetArea())
    local aAreaSB1      := SB1->(GetArea())
    local aAreaSA2      := SA2->(GetArea())
    local aAreaSE4      := SE4->(GetArea())
    local aAreaSAK      := SAK->(GetArea())
    if FWIsInCallStack('MAAVALCOT')
        aParam := PARAMIXB
        defGrupo(@cGrp, aParam)
    endif
    RestArea(aAreaSAK)
    RestArea(aAreaSE4)
    RestArea(aAreaSA2)
    RestArea(aAreaSB1)
    RestArea(aAreaSC1)
    RestArea(aAreaSC8)
    RestArea(aArea)
return cGrp


/* EXECAUTO MANIPULAR APROVAÇÂO COMPRAS*/
user function CbExec094(nRecDoc, tpOp, cMotivo)
    local oModel094 := Nil
    local lOk       := .T.
    local cMsg      := ''
    local aErro     := {}
    local aArea     := getArea()
    local aAreaCR   := SCR->(getArea())
    local aAreaC7   := SC7->(getArea())
    default cMotivo := ''

    DbSelectArea("SCR")
    SCR->(DbSetOrder(3))
    SCR->(DbGoTo(nRecDoc))
    A094SetOp(tpOp)
    
    oModel094 := FWLoadModel('MATA094')
    oModel094:SetOperation( MODEL_OPERATION_UPDATE )
    oModel094:Activate()
    if !empty(cMotivo)
        oModel094:getModel('FieldSCR'):SetValue("CR_OBS", cMotivo)
    endif
    lOk := oModel094:VldData()
    if lOk
        lOk := oModel094:CommitData()
    endif
    if !lOk
        aErro := oModel094:GetErrorMessage()
        /*
            AutoGrLog("Id do formulário de origem:" + ' [' + AllToChar(aErro[01]) + ']')
            AutoGrLog("Id do campo de origem: "     + ' [' + AllToChar(aErro[02]) + ']')
            AutoGrLog("Id do formulário de erro: "  + ' [' + AllToChar(aErro[03]) + ']')
            AutoGrLog("Id do campo de erro: "       + ' [' + AllToChar(aErro[04]) + ']')
            AutoGrLog("Id do erro: "                + ' [' + AllToChar(aErro[05]) + ']')
            AutoGrLog("Mensagem do erro: "          + ' [' + AllToChar(aErro[06]) + ']')
            AutoGrLog("Mensagem da solução:"        + ' [' + AllToChar(aErro[07]) + ']')
            AutoGrLog("Valor atribuído: "           + ' [' + AllToChar(aErro[08]) + ']')
            AutoGrLog("Valor anterior: "            + ' [' + AllToChar(aErro[09]) + ']')
            MostraErro()
        */
        cMsg := FwNoAccent(' [' + AllToChar(aErro[06]) + ']')
    endif
    oModel094:DeActivate()     

    RestArea(aAreaC7)
    RestArea(aAreaCR)
    RestArea(aArea)
return {lOk, cMsg}

user function MT120COR()
    local aArea     := getArea()
    local aAreaCR   := SCR->(getArea())
    local aAreaC7   := SC7->(getArea())
    local aPCores   := aClone(PARAMIXB[1])
    local aNewCores := {}
    local nX        := 0

    aAdd(aNewCores,{'StaticCall(pontoEntrada, inClsNatu, AllTrim(C7_FILIAL),AllTrim(C7_NUM))','BR_MARRON_OCEAN'})
    for nX := 1 to len(aPCores)
        aAdd(aNewCores, aPCores[nX])
    next nX
    RestArea(aAreaC7)
    RestArea(aAreaCR)
    RestArea(aArea)
return(aNewCores)

user function MT120LEG()
    local aArea     := getArea()
    local aAreaCR   := SCR->(getArea())
    local aAreaC7   := SC7->(getArea())
    local aLeg      := aClone(PARAMIXB[1])
    local aNewLeg   := {}
    local nX        := 0

    aAdd(aNewLeg,{'BR_MARRON_OCEAN', 'Class. Natureza'})
    for nX := 1 to len(aLeg)
        aAdd(aNewLeg, aLeg[nX])
    next nX

    RestArea(aAreaC7)
    RestArea(aAreaCR)
    RestArea(aArea)
return(aNewLeg)

static function inClsNatu(cFili, cPed)
    local aArea     := getArea()
    local aAreaCR   := SCR->(getArea())
    local aAreaC7   := SC7->(getArea())
    local lBlq      := .F.
    local oSql      := nil

    oSql := LibSqlObj():newLibSqlObj()
    oSql:newAlias(qryinClassi(cFili, cPed))
    if oSql:hasRecords()
        oSql:GoTop()
        if AllTrim(oSql:getValue('ACLASS')) == 'S'
            lBlq := .T.
        endif
    endif
    oSql:close()
    FreeObj(oSql)
    RestArea(aAreaC7)
    RestArea(aAreaCR)
    RestArea(aArea)
return(lBlq)

/*
    Funções estaticas uteis
*/

static function cbcTesInt()
    local cTpOp := ""
    cTpOp := "51"
    SC7->(C7_TES)  := U_cbcGetTes(cTpOp, '1',SC7->(C7_FORNECE),SC7->(C7_LOJA),SC7->(C7_PRODUTO))
return nil


static function defGrupo(cGrp,aParam)
    local aGrpPerf  := {}
    if Alltrim(SC7->(C7_PRODUTO)) == '2010000000'
        cGrp := APR_GERAL
    elseif isFilProd("((B1_TIPO='ME') OR (B1_GRUPO IN ('MP03','MP04')))")
        cGrp := APR_MEMP34
    elseif (aGrpPerf := perfilAprov('000003', aParam))[1]
        cGrp := aGrpPerf[2]
    else
        cGrp := APR_GERAL
    endif
return nil



/* Definições da regra para direcionar ao grupo aprovadores limitados*/
static function perfilAprov(cPerfAprov, aParam)
    local dData     := Date()
    local aRet      := { .F., '' }
    local oSql      := nil
    local nTot      := 0
    local aRetSld   := {}
    if (nTot := totalPedido(aParam) ) > 0
        oSql    := LibSqlObj():newLibSqlObj()
        oSql:newAlias(qryPerfil(cPerfAprov))
        oSql:GoTop()
            if oSql:hasRecords()
                while oSql:notIsEof()    
                    SAK->(DbGoTo(oSql:getValue("REC_APROVADOR")))
                    aRetSld := MaSalAlc(SAK->(AK_COD),dData,.T.)
                    if len(aRetSld) > 0
                        if  aRetSld[1] >=  nTot
                            if Max(oSql:getValue("MAX_PERFIL"), oSql:getValue("MAX_APROV")) >=  nTot
                                aRet := {.T., oSql:getValue("GRP_APROV")}
                                exit
                            endif
                        endif
                    endif
                    oSql:skip()
                enddo
            endif
        oSql:close()
        FreeObj(oSql)
    endif
return aRet


/* Definição da regra para filtrar produtos (para definir grupos de aprovação) */
static function isFilProd(cFilSql)
    local lRet  := .F.
    local cQry  := ''
    local oSql  := nil
    local bErro := ErrorBlock({|oErr| handlerr(oErr)})
    default cFilSql := "((B1_TIPO='ME') OR (B1_GRUPO IN ('MP03','MP04')))"
        BEGIN SEQUENCE
            cQry := " SELECT " 
            cQry += " R_E_C_N_O_ AS REC "
            cQry += " FROM " + RetSqlName('SB1') + " WITH(NOLOCK) "
            cQry += " WHERE "
            cQry += " B1_FILIAL      = '" + xFilial('SB1')    + "' "
            cQry += " AND B1_COD     = '" + SC7->(C7_PRODUTO) + "' "
            cQry += " AND " + Alltrim(cFilSql)
            cQry += " AND B1_MSBLQL  <> 1 "
            cQry += " AND D_E_L_E_T_ = '' "
            oSql  := LibSqlObj():newLibSqlObj()
            oSql:newAlias(cQry)
            oSql:GoTop()
            lRet := oSql:hasRecords()
            oSql:close()
            FreeObj(oSql)
        END SEQUENCE
        ErrorBlock(bErro)
return lRet


static function getSoliInf(nRecSC7)
    local oSql := nil
    local aSoli := {}
    oSql    := LibSqlObj():newLibSqlObj()
    oSql:newAlias(qrySoli(nRecSC7))
    oSql:GoTop()
        if oSql:hasRecords()
            while oSql:notIsEof()    
                aadd(aSoli,{;
                oSql:getValue("FILIAL"),;
                Alltrim(oSql:getValue("SOLICITANTE")),;
                Dtoc(StoD(oSql:getValue('EMISS_SC'))),;
                oSql:getValue("NUM_SC") })
                oSql:skip()
            enddo
        endif
    oSql:close()
	FreeObj(oSql)

return aSoli

static function totalPedido(aP)
    local nTot          := 0
    local nProd         := 0
    local nForn         := 0
    local nVenc         := 0
    local cFornEscol    := ''
    local cLoja         := ''
    local cCond         := ''
    local cFil         := ''
    // Codigo Loja Vencedor
    for nVenc := 1 to len(aP[1])
        cFornEscol  := aP[1][nVenc][1]
        cLoja       := aP[1][nVenc][2]
        cCond       := aP[1][nVenc][3]
        cFil       := aP[1][nVenc][4]
        // Loop nos produtos
        for nProd := 1 to len(aP[2])
            // Loop nos fornecedores
            for nForn := 1 to len(aP[2][nProd])
                // Somar apenas total fornecedor vencedor
                if cFornEscol == gF(aP[2][nProd][nForn], "C8_FORNECE") .And. cLoja == gF(aP[2][nProd][nForn], "C8_LOJA");
                        .And. cCond == gF(aP[2][nProd][nForn], "C8_COND") .And. cFil == gF(aP[2][nProd][nForn], "C8_FILENT")
                    SC8->(DbGoTo(gF(aP[2][nProd][nForn], "SC8RECNO")) )
                    If !Empty(SC8->(C8_MOTVENC))
                        nTot += SC8->(C8_TOTAL - C8_VLDESC)
                    EndIf
                endif
            next nForn
        next nProd
    next nVenc
return nTot


static function gF(aSrc, cName)
    local cValue := ''
    local nPos  := 0
    if (nPos := Ascan(aSrc, {|oI| oI[1]  == cName })) > 0
        cValue := aSrc[nPos][2]
    endif
return cValue


static function handlerr(oErr)
    Help(NIL, NIL, "Grupo de Aprovadores", NIL, oErr:Description, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Erro"}) 
    BREAK
return nil


/* Consultas SQL */
static function qryPerfil(cPerfilAprov)
    local cQry := ''
    cQry += " SELECT "
    cQry += " SAL.AL_COD		AS GRP_APROV, "
    cQry += " DHL.DHL_LIMMAX	AS MAX_PERFIL, "
    cQry += " SAK.AK_LIMMAX	    AS MAX_APROV, "
    cQry += " SAK.R_E_C_N_O_    AS REC_APROVADOR "
    cQry += " FROM " + RetSqlName('SAL') + " SAL WITH(NOLOCK) "
    cQry += " INNER JOIN " + RetSqlName('SAK') + " SAK WITH (NOLOCK) "
    cQry += " ON SAL.AL_FILIAL = SAK.AK_FILIAL "
    cQry += " AND SAL.AL_APROV = SAK.AK_COD "
    cQry += " AND SAL.D_E_L_E_T_ = SAK.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('DHL') + " DHL WITH(NOLOCK) "
    cQry += " ON SAL.AL_FILIAL = DHL.DHL_FILIAL "
    cQry += " AND SAL.AL_PERFIL = DHL.DHL_COD "
    cQry += " AND SAL.D_E_L_E_T_ = DHL.D_E_L_E_T_ "
    cQry += " WHERE  "
    cQry += " SAL.AL_FILIAL = '" + FwFilial() + "'  "
    cQry += " AND SAL.AL_PERFIL = '"+ cPerfilAprov +"' "
    cQry += " ORDER BY AL_NIVEL "
return cQry


static function qrySoli(nRecSC7)
    local cQry := ''
    cQry += " SELECT " 
	cQry += " SC1.C1_FILIAL  AS FILIAL, "
    cQry += " SC1.C1_NUM     AS NUM_SC, "
	cQry += " SC1.C1_EMISSAO AS EMISS_SC, "
	cQry += " SC1.C1_SOLICIT AS SOLICITANTE " 
    cQry += " FROM " + RetSqlName('SC7')  + " SC7  "
    cQry += " INNER JOIN " + RetSqlName('SC1')  + " SC1 "
    cQry += " ON SC7.C7_FILIAL = SC1.C1_FILIAL "
    cQry += " AND SC7.C7_NUM   = SC1.C1_PEDIDO "
    cQry += " AND SC7.D_E_L_E_T_ = SC1.D_E_L_E_T_ "
    cQry += " WHERE SC7.R_E_C_N_O_ = " + cValToChar(nRecSC7) + "  "
    cQry += " AND SC7.D_E_L_E_T_ = '' "
    cQry += " ORDER BY SC1.C1_EMISSAO DESC "
return(cQry)


static function qryProd(cCodB1, cPeriodo, nQtdPer)
    local cQry       := ''
    default cPeriodo := 'year'
    default nQtdPer  := 1
    cQry += " SELECT " 
	cQry += " SD1.D1_FILIAL AS FILIAL, "
	cQry += " SD1.D1_COD AS PRODUTO, "
	cQry += " SB1.B1_DESC AS DESCR, "
	cQry += " DATEPART(YEAR,  CONVERT(DATE,SF1.F1_EMISSAO)) AS ANO, "
	cQry += " DATEPART(MONTH, CONVERT(DATE,SF1.F1_EMISSAO)) AS MES, "
	cQry += " SA2.A2_NOME           AS FORNECEDOR, "
	cQry += " COUNT(SF1.F1_DOC)     AS NRO_COMP, "
	cQry += " MIN(SD1.D1_VUNIT)     AS MEN_PRECO, "
	cQry += " AVG(SD1.D1_VUNIT)     AS MED_PRECO, "
	cQry += " MAX(SD1.D1_VUNIT)     AS MAX_PRECO, "
	cQry += " SUM(SD1.D1_QUANT)     AS QTD_COMPRA, "
	cQry += " SB1.B1_UM AS UM, "
	cQry += " SUM(SD1.D1_TOTAL)     AS TOTAL "
    cQry += " FROM " + RetSqlName('SD1') + " SD1 WITH(NOLOCK) "
    cQry += " INNER JOIN " + RetSqlName('SF1') + " SF1 WITH(NOLOCK) "
	cQry += " ON SD1.D1_FILIAL   = SF1.F1_FILIAL "
	cQry += " AND SD1.D1_DOC     = SF1.F1_DOC "
	cQry += " AND SD1.D1_SERIE   = SF1.F1_SERIE "
	cQry += " AND SD1.D1_FORNECE = SF1.F1_FORNECE "
	cQry += " AND SD1.D1_LOJA    = SF1.F1_LOJA "
	cQry += " AND SD1.D_E_L_E_T_ = SF1.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SF4') + " SF4 WITH(NOLOCK) "
	cQry += " ON ''              = SF4.F4_FILIAL "
	cQry += " AND SD1.D1_TES     = SF4.F4_CODIGO "
	cQry += " AND SD1.D_E_L_E_T_ = SF4.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SB1') + " SB1 WITH(NOLOCK) "
	cQry += " ON ''              = SB1.B1_FILIAL "
	cQry += " AND SD1.D1_COD     = SB1.B1_COD "
	cQry += " AND SD1.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SA2') + " SA2 WITH(NOLOCK) "
	cQry += " ON ''              = SA2.A2_FILIAL "
	cQry += " AND SF1.F1_FORNECE = SA2.A2_COD "
	cQry += " AND SF1.F1_LOJA    = SA2.A2_LOJA "
	cQry += " AND SF1.D_E_L_E_T_ = SA2.D_E_L_E_T_ "
    cQry += " WHERE "
	cQry += " SD1.D1_FILIAL IN ('01','02','03') "
	cQry += " AND SD1.D1_COD     = '" + cCodB1 + "' " 
	cQry += " AND SF1.F1_EMISSAO >= CONVERT(VARCHAR(11),DATEADD("+ cPeriodo +", -" +;
    cValToChar(nQtdPer) + ", GETDATE()), 112) "
	cQry += " AND SF1.F1_TIPO    = 'N' "
	cQry += " AND SF4.F4_DUPLIC  = 'S' "
	cQry += " AND SD1.D_E_L_E_T_ = '' "
    cQry += " GROUP BY  "
	cQry += " SD1.D1_FILIAL, "
	cQry += " DATEPART(YEAR,  CONVERT(DATE,SF1.F1_EMISSAO)), "
	cQry += " DATEPART(MONTH, CONVERT(DATE,SF1.F1_EMISSAO)), "
	cQry += " SA2.A2_NOME, "
	cQry += " SD1.D1_COD, "
	cQry += " SB1.B1_DESC, "
	cQry += " SB1.B1_UM "
    cQry += " ORDER BY "
	cQry += " SD1.D1_FILIAL, "
	cQry += " DATEPART(YEAR,  CONVERT(DATE,SF1.F1_EMISSAO)) DESC, "
	cQry += " DATEPART(MONTH, CONVERT(DATE,SF1.F1_EMISSAO)) DESC, "
	cQry += " SA2.A2_NOME "
return cQry


static function qryRec7(cFl,cNum)
    local cQry := ''
    cQry += " SELECT R_E_C_N_O_ AS REC " 
    cQry += " FROM "+ RetSqlName('SC7')
    cQry += " WHERE C7_FILIAL = '"+ cFl +"' " 
    cQry += " AND C7_NUM = '"+ cNum +"' AND D_E_L_E_T_ = ''
return cQry


static function qryQuot(nrecSC7)
    local cQry := ''
    cQry += " SELECT " 
	cQry += " SC8.R_E_C_N_O_   AS RECSC8,  "
	cQry += " SC1.R_E_C_N_O_   AS RECSC1,  "
	cQry += " SC7.R_E_C_N_O_   AS RECSC7,  "
	cQry += " SC7.C7_FILIAL    AS FIL_PC,  "
	cQry += " SA2.A2_NOME	   AS FORCENEDOR, "
 	cQry += " SB1.B1_DESC	   AS PRODUTO, "
	cQry += " SC1.C1_SOLICIT   AS USR_SC, "
	cQry += " SC1.C1_EMISSAO   AS DT_SC, "
	cQry += " SC1.C1_NUM       AS NR_SC, "
	cQry += " SC1.C1_QUANT     AS QTD_SC, "
	cQry += " SC8.C8_NUM       AS NR_QT, "
	cQry += " SC8.C8_EMISSAO   AS DT_QT, "
	cQry += " SC8.C8_QUANT     AS QTD_QT, "
	cQry += " SC8.C8_PRECO     AS PRC_QT, "
	cQry += " (SC8.C8_PRECO * SC8.C8_QUANT) AS TOT_QT, "
	cQry += " SE4.E4_DESCRI	 AS COND_PAGTO, "
	cQry += " SE4.E4_ZMEDPAG	 AS MED_DIA, "
	cQry += " SC7.C7_EMISSAO   AS DT_PC, "
	cQry += " CASE SC8.C8_NUMPED WHEN SC7.C7_NUM THEN 'X' ELSE '' END AS QT_VENC  "
    cQry += " FROM " + RetSqlNAme('SC7')  + " SC7 WITH(NOLOCK)  "
    cQry += " INNER JOIN " + RetSqlNAme('SC1')  + " SC1 WITH(NOLOCK)  " 
    cQry += " ON SC7.C7_FILIAL   = SC1.C1_FILIAL  "
    cQry += " AND SC7.C7_NUMSC   = SC1.C1_NUM  "
    cQry += " AND SC7.C7_ITEMSC  = SC1.C1_ITEM  "
    cQry += " AND SC7.D_E_L_E_T_ = SC1.D_E_L_E_T_  "
    cQry += " INNER JOIN " + RetSqlNAme('SC8')  + " SC8 WITH(NOLOCK)  "
    cQry += " ON SC1.C1_FILIAL   = SC8.C8_FILIAL  "
    cQry += " AND SC1.C1_NUM     = SC8.C8_NUMSC  "
    cQry += " AND SC1.C1_ITEM    = SC8.C8_ITEMSC  "
    cQry += " AND SC1.D_E_L_E_T_ = SC8.D_E_L_E_T_  "
    cQry += " INNER JOIN " + RetSqlNAme('SB1')  + " SB1 WITH(NOLOCK)  "
    cQry += " ON '' = SB1.B1_FILIAL  "
    cQry += " AND SC7.C7_PRODUTO = SB1.B1_COD  "
    cQry += " AND SC7.D_E_L_E_T_ = SB1.D_E_L_E_T_  "
    cQry += " INNER JOIN " + RetSqlNAme('SA2')  + " SA2 WITH(NOLOCK)  "
    cQry += " ON ''				  = SA2.A2_FILIAL  "
    cQry += " AND SC8.C8_FORNECE  = SA2.A2_COD  "
    cQry += " AND SC8.C8_LOJA     = SA2.A2_LOJA  "
    cQry += " AND SC8.D_E_L_E_T_  = SA2.D_E_L_E_T_  "
    cQry += " INNER JOIN " + RetSqlNAme('SE4')  + " SE4 WITH(NOLOCK)  "
    cQry += " ON ''				  = SE4.E4_FILIAL  "
    cQry += " AND SC8.C8_COND     = SE4.E4_CODIGO  "
    cQry += " AND SC8.D_E_L_E_T_  = SE4.D_E_L_E_T_  "
    cQry += " WHERE  "
    cQry += " SC7.R_E_C_N_O_  = " + cValToChar(nrecSC7) + "  "
    cQry += " AND SC7.D_E_L_E_T_  = ''  "
    cQry += " ORDER BY SC8.C8_EMISSAO DESC"
return cQry


static function qrySCR(cCodUsr, cSts)
    local cQry   := ''
    default cSts := '02'
    cQry += " SELECT " 
    cQry += " SCR.R_E_C_N_O_ AS RECNO_SCR, "
    cQry += " SC7.R_E_C_N_O_ AS RECNO_SC7, "
    cQry += " SC7.C7_FILIAL  AS FILIAL_PC, "
    cQry += " SC7.C7_NUM     AS NUMERO_PC, "
    cQry += " SC7.C7_EMISSAO AS EMISSAO_PC, "
    cQry += " SA2.A2_NOME    AS FORNECEDOR, "
    cQry += " SB1.B1_DESC    AS PRODUTO, "
    cQry += " SC7.C7_QUANT   AS QUANTIDADE, "
    cQry += " SC7.C7_PRECO   AS PRECO, "
    cQry += " SC7.C7_TOTAL   AS TOTAL "
    cQry += " FROM " + RetSqlName('SCR') + " SCR WITH(NOLOCK) "
    cQry += " INNER JOIN " + RetSqlName('SC7') + " SC7 WITH(NOLOCK) "
    cQry += " ON SCR.CR_FILIAL 	    = SC7.C7_FILIAL "
    cQry += " AND SCR.CR_NUM	    = SC7.C7_NUM "
    cQry += " AND SCR.D_E_L_E_T_	= SC7.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SB1') + " SB1 WITH(NOLOCK) "
    cQry += " ON '' = SB1.B1_FILIAL "
    cQry += " AND SC7.C7_PRODUTO = SB1.B1_COD "
    cQry += " AND SC7.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SA2') + " SA2 WITH(NOLOCK) "
    cQry += " ON ''				  = SA2.A2_FILIAL "
    cQry += " AND SC7.C7_FORNECE  = SA2.A2_COD "
    cQry += " AND SC7.C7_LOJA     = SA2.A2_LOJA "
    cQry += " AND SC7.D_E_L_E_T_  = SA2.D_E_L_E_T_ "
    cQry += " WHERE SCR.CR_FILIAL IN ('01','02','03') "
    cQry += " AND SCR.CR_USER = '" + cCodUsr + "' "
    cQry += " AND SCR.CR_STATUS = '" + cSts + "' "
    cQry += " AND SCR.D_E_L_E_T_ = '' "
    if u_cbcUseBudget()
        cQry += " AND SCR.CR_ACLASSI <> 'S' "
    endif
    cQry += " ORDER BY SC7.C7_EMISSAO DESC "
return cQry


static function qryUltCom(cProduto)
    local cQry   := ''
    cQry += " SELECT " 
	cQry += " SD1.D1_EMISSAO AS EMISSAO, "
	cQry += " SD1.D1_QUANT   AS QTD, "
	cQry += " SD1.D1_VUNIT   AS VALOR, "
	cQry += " (SD1.D1_QUANT * SD1.D1_VUNIT) AS TOTAL, "
	cQry += " SA2.A2_NOME    AS FORNECEDOR "
	cQry += " FROM " + RetSqlName('SD1') + " SD1 "
	cQry += " INNER JOIN " + RetSqlName('SA2') + " SA2  "
	cQry += " ON '" + xFilial('SA2') + "' = SA2.A2_FILIAL  "
	cQry += " AND SD1.D1_FORNECE	      = SA2.A2_COD  "
	cQry += " AND SD1.D1_LOJA		      = SA2.A2_LOJA   "
	cQry += " AND SD1.D_E_L_E_T_          = SA2.D_E_L_E_T_ "
    cQry += "  WHERE "
    cQry += " SD1.D1_FILIAL = '"+ xFilial('SD1') +"'  "
    cQry += " AND SD1.D1_COD = '"+ cProduto +"'  "
    cQry += " AND SD1.D1_EMISSAO = ( "
    cQry += " SELECT MAX(D1_EMISSAO)  "
    cQry += " FROM SD1010 SD1S  "
    cQry += " WHERE SD1S.D1_FILIAL = '"+ xFilial('SD1') +"'  "
    cQry += " AND SD1S.D1_COD = SD1.D1_COD "
    cQry += " AND SD1S.D_E_L_E_T_ <> '*'  "
    cQry += " ) "
    cQry += " AND SD1.D_E_L_E_T_ <> '*' "
return cQry

static function qryinClassi(cFili, cPed)
    local cQry := ""
    cQry += " SELECT DISTINCT(SCR.CR_ACLASSI) AS [ACLASS] "
    cQry += " FROM SCR010 SCR "
    cQry += " WHERE SCR.CR_FILIAL = '" + cFili + "' "
    cQry += " AND SCR.CR_NUM = ('" + cPed + "') "
    cQry += " AND SCR.D_E_L_E_T_ = '' "
return(cQry)


/* Funções utilizadas para os filtros de browser do usuario*/
user function xColSC1()
    local cNome := ''
    if FwIsInCallStack("MATA121")
        if Type("C7_FORNECE") <> 'U'
            cNome := POSICIONE("SA2",1,xFilial("SA2") + C7_FORNECE + C7_LOJA, "A2_NOME")
        endif
    else
        if Type("C1_FORNECE") <> 'U'
            cNome := POSICIONE("SA2",1,xFilial("SA2") + C1_FORNECE + C1_LOJA, "A2_NOME")
        endif
    endif
return cNome
