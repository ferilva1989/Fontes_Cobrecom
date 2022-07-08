#include 'Totvs.ch'
user function cbcProdMod()
    local lRewind := .T.
    local aRet      := {}
    local aPerg     := {}

    while lRewind
        aadd(aPerg,{1,"Data De: ",   dDataBase,"",".T.","",".T.",50,.T.})
        aadd(aPerg,{1,"Data Até: ",  dDataBase,"","MV_PAR01 <= MV_PAR02","",".T.",50,.T.})
        if (ParamBox(aPerg,"Processamento Manual de MODs",@aRet))
            if validDate(aRet[1], aRet[2])
                ProcMod(aRet[1], aRet[2])
            endif
        endif
        lRewind := MsgYesNo("Deseja realizar novo processamento?","Novo Processamento")
    endDo

return(nil)

static function validDate(dDtIni, dDtFim)
    local lRet      := .T.
    local dUlMes    := GetMv("MV_ULMES")
    local dDblQMov  := GetMv("MV_DBLQMOV")

    if dDtIni > dDtFim
        lRet := .F.
        MsgAlert('Data Inicial não pode ser maior que data Final!','Data Inválida')
    else
        if dDtIni <= dUlMes
            lRet := .F.
            MsgAlert('Data bloqueada. Período já processado pelo CM (MV_ULMES)!','Data Inválida')
        else
            if dDtIni <= dDblQMov
                lRet := .F.
                MsgAlert('Data bloqueada para movimentações (MV_DBLQMOV)!','Data Inválida')
            endif
        endif
    endif
return(lRet)

static function ProcMod(dDtIni, dDtFim)
    local aArea    	:= GetArea()
    local aAreaSC2	:= SC2->(getArea())
    local oSql      := LibSqlObj():newLibSqlObj()
    local dDatRf    := nil
    local cLog      := ""

    DbSelectArea("SC2")
	oSql:newAlias(qryExtract(DtoS(dDtIni), DtoS(dDtFim)))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
		    BEGIN TRANSACTION
                SC2->(DbGoTo(oSql:getValue("REC_SC2")))
                dDatRf := SC2->C2_DATRF
                if !empty(dDatRf)
                    SC2->(RecLock("SC2",.F.))
                        SC2->C2_DATRF := StoD(" ")
                    SC2->(MsUnLock())
                endif
                aRet := ReqMOD240( AllTrim(oSql:getValue("COD")),; 
                            oSql:getValue("QTD"),; 
                            AllTrim(oSql:getValue("DOC")),; 
                            oSql:getValue("UNMOV"),;  
                            AllTrim(oSql:getValue("OP")),; 
                            AllTrim(oSql:getValue("LOTE")),; 
                            StoD(oSql:getValue("EMIS")),; 
                            AllTrim(oSql:getValue("HIST")),;
                            AllTrim(oSql:getValue("RECURSO")),;
                            AllTrim(oSql:getValue("SETOR"));
                        )
                if !aRet[1]
                    cLog += AllTrim(oSql:getValue("DOC")) + " - " + AllTrim(oSql:getValue("COD")) + " - " + AllTrim(oSql:getValue("RECURSO")) + " - " + AllTrim(oSql:getValue("OP")) + " - " + AllTrim(aRet[02]) + Chr(13)+Chr(10)
                endif
                if !empty(dDatRf)
                    SC2->(DbGoTo(oSql:getValue("REC_SC2")))
                    SC2->(RecLock("SC2",.F.))
                        SC2->C2_DATRF := dDatRf
                    SC2->(MsUnLock())
                endif			    
            END TRANSACTION
            oSql:skip()
        endDo
        if !empty(cLog)
            writeMyFile(DtoS(dDtIni), DtoS(dDtFim), cLog)
        endif
    endif
    oSql:close()
    FreeObj(oSql)
    RestArea(aAreaSC2)
    RestArea(aArea)
return(nil)

static function ReqMOD240(cProduto, nQtde, cDoc, nUnMov, cOP, cLote, dDtEvento, cHist, cRecurso, cSetor)	
	local aArea    	    := GetArea()
    local aAreaSC2	    := SC2->(getArea())
    local cMyTm		    := "504"
    local cProd		    := ""
	local nQtdHrs		:= 0
    local aItens		:= {}
    local aRet          := {.F., ""}
    local oExec         := nil
	
    if !empty(cRecurso)        
        nQtdHrs	:= TempoProd(cProduto, cRecurso)
        if nQtdHrs > 0            
            cProd := CodProdMod(AllTrim(cSetor))
            aItens 	:= {{"D3_TM"	    ,Padr(cMyTM,TamSX3("D3_TM")[1]),                NIL},; //TP.MOVIM.
                        {"D3_COD"		,cProd,                                         NIL},; //D3_COD
                        {"D3_DOC"		,Padr(Alltrim(cDoc),TamSX3("D3_DOC")[1]),       NIL},; //TP.MOVIM.
                        {"D3_UM"		,Posicione("SB1",1,xFilial("SB1")+Alltrim(cProd),"B1_UM"),NIL},;
                        {"D3_LOCAL"		,Padr("99",TamSX3("D3_LOCAL")[1]),              NIL},;
                        {"D3_QUANT"		,Round(nQtdHrs,TamSX3("D3_QUANT")[2]),          NIL},;
                        {"D3_HIST"		,Padr(cHist,TamSX3("D3_HIST")[1]),              NIL},;
                        {"D3_OP"		,Padr(Alltrim(cOP),TamSX3("D3_OP")[1]),         NIL},;
                        {"D3_EMISSAO"	,dDtEvento,                                     NIL},;
                        {"D3_PARCTOT" 	,Padr("P",TamSX3("D3_PARCTOT")[1]),             NIL},;
                        {"D3_ZZLOTE" 	,Padr(Alltrim(cLote),TamSX3("D3_ZZLOTE")[1]),   NIL},;
                        {"D3_OBS" 	    ,Padr("PROC_MOD",TamSX3("D3_OBS")[1]),          NIL},;
                        {"D3_ZZUNMOV" 	,nUnMov,                                        NIL}}

            oExec := cbcExecAuto():newcbcExecAuto(aItens,/*aAutoCab*/,.F.)
            oExec:setFilial(FwFilial())
            oExec:exAuto('MATA240',3,,"EST")
            aRet := oExec:getRet()
            FreeObj(oExec)
        else
            aRet := {.F., "Tempo de Produção não localizado!"}
        endif
    else
        aRet := {.F., "Recurso não localizado!"}
    endif
    RestArea(aAreaSC2)
    RestArea(aArea)
return(aRet)

static function TempoProd(cProduto, cRecurso)
    local aArea    	:= GetArea()
    local aAreaZAG 	:= ZAG->(GetArea())
    local nQtdHrs   := 0

    DbSelectArea("ZAG")
    nQtdHrs	:= Posicione("ZAG",1,xFilial("ZAG")+Padr(Alltrim(cProduto),TamSX3("ZAG_PRODUT")[1])+Padr(Alltrim(cRecurso),TamSX3("ZAG_RECPPI")[1]),"ZAG_SETUP")
    if nQtdHrs > 0
        nQtdHrs :=	((nQtde*nQtdHrs)*24)
    endif
    RestArea(aAreaZAG)
    RestArea(aArea)
return(nQtdHrs)

static function CodProdMod(cSetor)
    local cProd     := ""
    default cSetor  := ""
    Do Case
        Case Alltrim(cSetor) == "EXT"
        cProd := "MOD300110"
        Case Alltrim(cSetor) == "FR"
        cProd := "MOD300111"
        Case Alltrim(cSetor) == "TF"
        cProd := "MOD300112"
        Case Alltrim(cSetor) == "TG"
        cProd := "MOD300113"
        Case Alltrim(cSetor) == "ENC"
        cProd := "MOD300114"
        Case Alltrim(cSetor) == "LAM"
        cProd := "MOD300115"
        OtherWise
        cProd := "MOD999999"
    End Case
return(cProd)

static function writeMyFile(cDe, cAte, cLog)
    local cArqGera	:= GetTempPath() +'MOD_ERROR_De_'+ cDe + '_Ate_' + cAte + '_' + dToS(Date()) + "_" + StrTran(Time(), ':', '-') + '.txt'
    
    MemoWrite(cArqGera, cDe + Chr(13)+Chr(10) + cAte + Chr(13)+Chr(10) + cLog)
return(nil)


user function cbcUpdMOD()
    local aParamBox := {}
    local aRetPar   := {}
    local aDados    := {}
    local nX        := 0
    local nXDe      := 1
    local nTam      := 0
    local cArq      := ''
    local cOrigem   := ''

    aAdd(aParamBox,{6,"Informe caminho",Space(70),"","","" ,70,.T.,"Arquivo .XLS |*.XLS"})
    if ParamBox(aParamBox, "Parametros", @aRetPar)
        cArq 		:= Alltrim(Substr(aRetPar[1],rat("\",aRetPar[1])+1,len(aRetPar[1])))
        cOrigem	:= Alltrim(Substr(aRetPar[1],1,rat("\",aRetPar[1])))
        Processa( {|| aDados:= U_CargaXLS(cArq,cOrigem,,.F.)},"Aguarde, carregando planilha...Pode demorar")
		if !empty(aDados)
            nTam := len(aDados)
            if MsgYesNo("Planilha possui linha de cabeçalho/título?","Cabeçalho")
                nXDe := 2
            endif
            ProcRegua(nTam)
            DbSelectArea("ZAG")
            for nX := nXDe to nTam
                IncProc("Processando "+cValToChar(nX)+" de "+cValToChar(nTam))
                nRec := findZAG(AllTrim(aDados[nX, 01]), AllTrim(aDados[nX, 02]))
                if nRec > 0
                    ZAG->(DbGoTo(nRec))
                    ZAG->(RecLock("ZAG",.F.))
                        ZAG->ZAG_SETUP  := Val(StrTran(aDados[nX, 03], ",", "."))
                        ZAG->ZAG_SETUP2 := Val(StrTran(aDados[nX, 04], ",", "."))
                    ZAG->(MsUnLock())
                else
                    RecLock("ZAG",.T.)
                        ZAG->ZAG_FILIAL := xFilial("ZAG")
                        ZAG->ZAG_PRODUT := AllTrim(aDados[nX, 01])
                        ZAG->ZAG_RECPPI := AllTrim(aDados[nX, 02])
                        ZAG->ZAG_SETUP  := Val(StrTran(aDados[nX, 03], ",", "."))
                        ZAG->ZAG_SETUP2 := Val(StrTran(aDados[nX, 04], ",", "."))
                    ZAG->(MsUnLock())
                endif
            next nX
		endif
    endif
return(nil)

static function findZAG(cProd, cRecurso)
    local aArea    	:= GetArea()
    local aAreaZAG 	:= ZAG->(GetArea())
    local nRec      := 0
	local oSql 		:= LibSqlObj():newLibSqlObj()

    oSql:newTable("ZAG", "R_E_C_N_O_ REC", "ZAG_FILIAL = '" + xFilial("ZAG") + "' AND ZAG_PRODUT = '" + cProd + "' AND ZAG_RECPPI = '" + cRecurso + "'")

	if oSql:hasRecords()
        oSql:goTop()
        nRec := oSql:getValue("REC")
	endif

    oSql:Close()
    FreeObj(oSql)
    RestArea(aAreaZAG)
    RestArea(aArea)
return(nRec)

static function qryExtract(cDtIni, cDtFim)
    local cQry := ""

    cQry += " SELECT SD3.D3_COD AS [COD], "
    cQry += " SD3.D3_DOC AS [DOC], "
    cQry += " SD3.D3_QUANT AS [QTD], "
    cQry += " SD3.D3_HIST AS [HIST], "
    cQry += " SD3.D3_OP AS [OP], "
    cQry += " SD3.D3_EMISSAO AS [EMIS], "
    cQry += " SD3.D3_ZZLOTE AS [LOTE], "
    cQry += " SD3.D3_ZZUNMOV AS [UNMOV], "
    cQry += " ( "
    cQry += " select rec.Code as Recurso "
    cQry += " from [PCF_PROD].PCFactory.dbo.TBLMovEv as ev "
    cQry += " inner join [PCF_PROD].PCFactory.dbo.TBLResource as rec on ev.IDResource = rec.IDResource "
    cQry += " where ev.IDMovEv = CAST(SD3.D3_DOC AS INT) "
    cQry += " ) AS [RECURSO], "
    cQry += " ( "
    cQry += " select sec.Code as Setor "
    cQry += " from [PCF_PROD].PCFactory.dbo.TBLMovEv as ev "
    cQry += " inner join [PCF_PROD].PCFactory.dbo.TBLResource as rec on ev.IDResource = rec.IDResource "
    cQry += " inner join [PCF_PROD].PCFactory.dbo.TBLManagerGrp as mng on rec.IDManagerGrp = mng.IDManagerGrp "
    cQry += " inner join [PCF_PROD].PCFactory.dbo.TBLSector as sec on mng.IDSector = sec.IDSector "
    cQry += " where ev.IDMovEv = CAST(SD3.D3_DOC AS INT) "
    cQry += " ) AS [SETOR], "
    cQry += " SC2.R_E_C_N_O_ AS [REC_SC2] "
    cQry += " FROM " + RetSqlName('SD3') + " SD3 WITH(NOLOCK) "
    cQry += " INNER JOIN " + RetSqlName('SC2') + " SC2 WITH(NOLOCK) ON SD3.D3_FILIAL		= SC2.C2_FILIAL "
    cQry += " 						AND SD3.D3_OP		= SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN "
    cQry += " 						AND SD3.D_E_L_E_T_	= SC2.D_E_L_E_T_ "
    cQry += " WHERE SD3.D3_FILIAL = '" + xFilial("SD3") + "' "
    cQry += " AND SD3.D3_EMISSAO >= '" + cDtIni + "' "
    cQry += " AND SD3.D3_EMISSAO <= '" + cDtFim + "' "
    cQry += " AND SD3.D3_DOC NOT IN (					 "
    cQry += " 	    SELECT SSD3.D3_DOC "
    cQry += " 	    FROM " + RetSqlName('SD3') + " SSD3 WITH(NOLOCK) "
    cQry += " 	    WHERE SSD3.D3_FILIAL = SD3.D3_FILIAL "
    cQry += " 	    AND SSD3.D3_EMISSAO >= '" + cDtIni + "' "
    cQry += " 	    AND SSD3.D3_EMISSAO <= '" + cDtFim + "' "
    cQry += " 	    AND SSD3.D3_DOC = SD3.D3_DOC "
    cQry += " 	    AND SSD3.D3_CF = 'RE0' "
    cQry += " 	    AND SSD3.D3_TIPO = 'MO' "
    cQry += " 	    AND SSD3.D_E_L_E_T_ = SD3.D_E_L_E_T_ "
    cQry += " ) "
    cQry += " AND SD3.D3_CF = 'PR0' "
    cQry += " AND SD3.D3_HIST <> '' "
    cQry += " AND SD3.D3_ESTORNO <> 'S' "
    cQry += " AND SD3.D_E_L_E_T_ = '' "
    cQry += " AND ISNUMERIC(SD3.D3_DOC) = 1 "
    cQry += " ORDER BY SD3.D3_EMISSAO, SD3.D3_DOC "
return(cQry)

user function cbcRptNoMod()
    local aRet      := {}
    local aPerg     := {}
    aadd(aPerg,{1,"Data De: ",   dDataBase,"",".T.","",".T.",50,.T.})
    aadd(aPerg,{1,"Data Até: ",  dDataBase,"","MV_PAR01 <= MV_PAR02","",".T.",50,.T.})
    if (ParamBox(aPerg,"Relatório de MODs não Requisitadas",@aRet))
        ProcReport(aRet[1], aRet[2])
    endif
return(nil)

static function ProcReport(dDtIni, dDtFim)
    local aArea    	 := GetArea()
    local aAreaSB1   := SB1->(GetArea())
    local oSql       := LibSqlObj():newLibSqlObj()
    local nQtdHrs    := 0
    local cMod       := ""
    local cObs       := ""
    local oFWMsExcel := nil
    local oExcel	 := nil
    local cNomArqv   := GetTempPath() + 'NoMOD_De_'+ DtoS(dDtIni) + '_Ate_' + DtoS(dDtFim) + '_' + dToS(Date()) + "_" + StrTran(Time(), ':', '-')+ '.xml'

    DbSelectArea("SB1")

    oFWMsExcel := FWMSExcel():New()
    oFWMsExcel:AddworkSheet("NoMOD")
    oFWMsExcel:AddTable("NoMOD","Movimentos")
    oFWMsExcel:AddColumn("NoMOD","Movimentos","OP",1)
    oFWMsExcel:AddColumn("NoMOD","Movimentos","Doc",1)
    oFWMsExcel:AddColumn("NoMOD","Movimentos","Emissão",1)
    oFWMsExcel:AddColumn("NoMOD","Movimentos","Produto",1)
    oFWMsExcel:AddColumn("NoMOD","Movimentos","Quantidade",1)
    oFWMsExcel:AddColumn("NoMOD","Movimentos","Recurso",1)
    oFWMsExcel:AddColumn("NoMOD","Movimentos","Setor",1)
    oFWMsExcel:AddColumn("NoMOD","Movimentos","MOD",1)
    oFWMsExcel:AddColumn("NoMOD","Movimentos","Qtd.MOD",1)
    oFWMsExcel:AddColumn("NoMOD","Movimentos","Obs.",1)
    
	oSql:newAlias(qryExtract(DtoS(dDtIni), DtoS(dDtFim)))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            nQtdHrs := TempoProd(AllTrim(oSql:getValue("COD")), AllTrim(oSql:getValue("RECURSO")))
            cMod    := CodProdMod(AllTrim(oSql:getValue("SETOR")))
            cMod    += (" - " + Posicione("SB1",1,xFilial("SB1")+ AllTrim(cMod),"B1_DESC"))
            cObs    := iif(empty(nQtdHrs), "Tempo de Produção não localizado!","")
            oFWMsExcel:AddRow("NoMOD","Movimentos",{;
                                                    AllTrim(oSql:getValue("OP")),;
                                                    AllTrim(oSql:getValue("DOC")),;
                                                    StoD(oSql:getValue("EMIS")),;
                                                    AllTrim(oSql:getValue("COD")),;
                                                    oSql:getValue("QTD"),;
                                                    AllTrim(oSql:getValue("RECURSO")),;
                                                    AllTrim(oSql:getValue("SETOR")),;
                                                    cMod,;
                                                    nQtdHrs,;
                                                    cObs;
            })
            oSql:skip()
        endDo

    endif
    oSql:close()
    FreeObj(oSql)

    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cNomArqv)

    oExcel := MsExcel():New()
    oExcel:WorkBooks:Open(cNomArqv)
    oExcel:SetVisible(.T.)
    oExcel:Destroy()

    FreeObj(oFWMsExcel)
    FreeObj(oExcel)
    RestArea(aAreaSB1)
    RestArea(aArea)
return(nil)
