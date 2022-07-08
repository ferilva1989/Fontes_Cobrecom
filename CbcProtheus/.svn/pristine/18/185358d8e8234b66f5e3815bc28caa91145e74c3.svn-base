#include 'protheus.ch'
#include 'parmtype.ch'
#include "Totvs.ch"

user function cbcTestTes()
    local aParamBox := {}
    local aRet      := {}
    local dDataDe   := dDataBase
    local dDataAte  := dDataBase
    local cTesDe    := Replicate('0', TamSx3('D2_TES')[1])
    local cTesAte   := Replicate('9', TamSx3('D2_TES')[1])

    aAdd(aParamBox,{1,'Data De: '   ,dDataDe,   PesqPict('SD2','D2_EMISSAO'),"","",".T.",50,.T.})
	aAdd(aParamBox,{1,'Data Até: '  ,dDataAte,  PesqPict('SD2','D2_EMISSAO'),"","",".T.",50,.T.})
    aAdd(aParamBox,{1,'TES De: '    ,cTesDe,    PesqPict('SD2','D2_TES'),    "","",".T.",50,.T.})
    aAdd(aParamBox,{1,'TES Até: '   ,cTesAte,   PesqPict('SD2','D2_TES'),    "","",".T.",50,.T.})
    if ParamBox(aParamBox,"Parâmetros - TESTE TES",@aRet)
        procTest(aRet[01], aRet[02], AllTrim(aRet[03]), AllTrim(aRet[04]))
    endif

return(nil)

static function procTest(dDataDe, dDataAte, cTesDe, cTesAte)
    local aArea    	:= GetArea()
    local aAreaSA1	:= SA1->(getArea())
    local aAreaSB1	:= SB1->(getArea())
    local aAreaSC5	:= SC5->(getArea())
    local aAreaSC6	:= SC6->(getArea())
    local cTes      := ''
    local oJson     := nil
    local aLog      := {}
    local oTes      := ctrlTesIntel():newctrlTesIntel()
    local oSql 	    := LibSqlObj():newLibSqlObj()

	oSql:newAlias(qryseek(dDataDe, dDataAte, cTesDe, cTesAte))
    If oSql:hasRecords()
        DbSelectArea('SA1')
		oSql:goTop()
		while oSql:notIsEof()
            SA1->(DbGoTo(oSql:getValue("SA1")))
            oJson := mntJson()
            cTes := oTes:simulate(2, '01', , , 'C', oSql:getValue("PRODUTO"), oJson:ToJson())
            if AllTrim(cTes) <> AllTrim(oSql:getValue("TES"))
                aAdd(aLog, {cTes,oSql:getValue("TES"), oSql:getValue("PRODUTO"), oSql:getValue("SA1")} )
            endif
            FreeObj(oJson)
            oSql:skip()
		endDo
    endif
    oSql:close()

    if !empty(aLog)
        MsgAlert('Total de Divergências: ' + cValToChar(Len(aLog)), 'Divergências')
        genLog(aLog)
    else
        MsgInfo('Não foram localizadas divergências!', 'Concluido')
    endif

    FreeObj(oSql)
    FreeObj(oTes)

    RestArea(aAreaSC6)
    RestArea(aAreaSC5)
    RestArea(aAreaSB1)
    RestArea(aAreaSA1)
    RestArea(aArea)
return(cTes)

static function genLog(aLog)
    local oFWMsExcel := nil
    local oExcel	 := nil
    local cNomArqv   := GetTempPath() + 'TesteTES_' + dToS(Date()) + "_" + StrTran(Time(), ':', '-')+ '.xml'
    local nX         := 0
    default aLog     := {}

    if !empty(aLog)
        oFWMsExcel := FWMSExcel():New()
        oFWMsExcel:AddworkSheet("Teste_TES")
        oFWMsExcel:AddTable("Teste_TES", 'Err')
        oFWMsExcel:AddColumn("Teste_TES",'Err',"TES RET",1)
        oFWMsExcel:AddColumn("Teste_TES",'Err',"TES ORIG",1)
        oFWMsExcel:AddColumn("Teste_TES",'Err',"PRODUTO",1)
        oFWMsExcel:AddColumn("Teste_TES",'Err',"REC SA1",1)
        for nX := 1 to len(aLog)
            oFWMsExcel:AddRow("Teste_TES",'Err',aLog[nX])
        next nX
        aLog := {}
        oFWMsExcel:Activate()
        oFWMsExcel:GetXMLFile(cNomArqv)
        oExcel := MsExcel():New()
        oExcel:WorkBooks:Open(cNomArqv)
        oExcel:SetVisible(.T.)
        oExcel:Destroy()   
        
        FreeObj(oFWMsExcel)
        FreeObj(oExcel)
    endif
return(nil)

static function mntJson()
    local oJson:= JsonObject():new()
    local oTemp:= JsonObject():new()
    
    oTemp['A1_COD']     := '000000'
    oTemp['A1_LOJA']    := '00'
    oTemp['A1_NOME']    := AllTrim(SA1->A1_NOME)
    oTemp['A1_PESSOA']  := AllTrim(SA1->A1_PESSOA)
    oTemp['A1_TIPO']    := AllTrim(SA1->A1_TIPO)
    oTemp['A1_EST']     := AllTrim(SA1->A1_EST)
    oTemp['A1_CGC']     := AllTrim(SA1->A1_CGC)
    oTemp['A1_INSCR']   := AllTrim(SA1->A1_INSCR)
    oTemp['A1_VEND']    := AllTrim(SA1->A1_VEND)
    oTemp['A1_GRPTRIB'] := AllTrim(SA1->A1_GRPTRIB)
    oTemp['A1_TIPCLI']  := AllTrim(SA1->A1_TIPCLI)
    oTemp['A1_CONTRIB'] := AllTrim(SA1->A1_CONTRIB)
    oTemp['A1_SIMPNAC'] := AllTrim(SA1->A1_SIMPNAC)
    oTemp['A1_CODSIAF'] := AllTrim(SA1->A1_CODSIAF)
    oTemp['A1_CALCSUF'] := AllTrim(SA1->A1_CALCSUF)
    oTemp['A1_TES']     := AllTrim(SA1->A1_TES)
    oTemp['A1_RECPIS']  := AllTrim(SA1->A1_RECPIS)
    oTemp['A1_XREIDI']  := AllTrim(SA1->A1_XREIDI)
    oJson['SA1'] := oTemp:ToJson()
return(oJson)

static function qryseek(dDataDe, dDataAte, cTesDe, cTesAte)
    local cQry := ''

    cQry+= " SELECT "
    cQry+= " SA1.R_E_C_N_O_ AS [SA1], "
    cQry+= " SB1.B1_COD AS [PRODUTO], "
    cQry+= " SC6.C6_TES AS [TES] "
    cQry+= " FROM " + retSqlName('SC5') + " SC5 "
    cQry+= " INNER JOIN " + retSqlName('SA1') + " SA1 ON '' = SA1.A1_FILIAL "
    cQry+= " 					AND SC5.C5_CLIENTE = SA1.A1_COD "
    cQry+= " 					AND SC5.C5_LOJACLI = SA1.A1_LOJA "
    cQry+= " 					AND SC5.D_E_L_E_T_ = SA1.D_E_L_E_T_ "
    cQry+= " INNER JOIN " + retSqlName('SC6') + " SC6 ON SC5.C5_FILIAL = SC6.C6_FILIAL "
    cQry+= " 					AND SC5.C5_NUM =  SC6.C6_NUM "
    cQry+= " 					AND SC5.D_E_L_E_T_ = SC6.D_E_L_E_T_ "
    cQry+= " INNER JOIN " + retSqlName('SB1') + " SB1 ON '' = SB1.B1_FILIAL "
    cQry+= " 					AND SC6.C6_PRODUTO = SB1.B1_COD "
    cQry+= " 					AND SC6.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
    cQry+= " WHERE SC5.C5_FILIAL = '" + xFilial('SC5') + "' "
    cQry+= " AND SC5.C5_EMISSAO >= '" + DtoS(dDataDe) + "' "
    cQry+= " AND SC5.C5_EMISSAO <= '" + DtoS(dDataAte) + "' "
    cQry+= " AND SC6.C6_TES >= '" + cTesDe + "' "
    cQry+= " AND SC6.C6_TES <= '" + cTesAte + "' "
    cQry+= " AND SC5.D_E_L_E_T_ = '' "
    cQry+= " AND (SC6.C6_XOPER = '01' OR SC6.C6_XOPER = '03') "

return(cQry)
