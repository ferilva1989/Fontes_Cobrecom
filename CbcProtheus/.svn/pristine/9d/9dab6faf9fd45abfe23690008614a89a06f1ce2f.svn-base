#include 'protheus.ch'
#include 'parmtype.ch'
#include "Totvs.ch"
#include 'cbcOrdemSep.ch'
#include 'cbcOrdemCar.ch'

user function cbcPlanFatur(aCargas)//cbcPlanFatur({'00000007'})
    private oCarga      := cbcCtrlCarga():newcbcCtrlCarga()
    default cCarga      := ''

    PergCarga(@aCargas)
    if !empty(aCargas)
        Processa({|| fMontaPlan(aCargas)}, "Processando...")
    endif
    FreeObj(oCarga)
return(nil)

static function fMontaPlan(aCargas)
    local oFWMsExcel := nil
    local nX		 := 1
    local oExcel	 := nil
    local oSql       := nil
    local oVol       := cbcCtrlVolum():newcbcCtrlVolum()
    Local oStatic    := IfcXFun():newIfcXFun()
    local aVol       := {}
    local cNomArqv   := GetTempPath() + 'PlanFATUR_' + dToS(Date()) + "_" + StrTran(Time(), ':', '-')+ '.xml'

    oFWMsExcel := FWMSExcel():New()
    oFWMsExcel:AddworkSheet("Faturamento")
    oFWMsExcel:AddTable("Faturamento","CARGAS")
    oFWMsExcel:AddColumn("Faturamento","CARGAS","Carga",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","Transp.",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","OS",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","Cliente",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","FAR",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","CAR",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","BOB",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","PAL",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","CXS",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","ROLOS",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","PESO",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","Cidade Ent.",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","Cidade Cli.",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","Cond. Pag.",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","Repres.",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","Assist.",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","Agendar",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","Obs.",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","Obs.Financeiro",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","Peso Bruto",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","Peso Líquido",1)
    oFWMsExcel:AddColumn("Faturamento","CARGAS","Peso Tara",1)

    for nX := 1 to len(aCargas)
        oCarga:define(aCargas[nX])
        oSql := LibSqlObj():newLibSqlObj()
        oSql:newAlias(oStatic:sP(2):callStatic('cbcQryCarga', 'qryAddView', aCargas[nX], ''))
        if oSql:hasRecords()
            oSql:goTop()
            while oSql:notIsEof()
                aVol := {}
                oStatic:sP(5):callStatic('cbcManifesto', 'mntDados', 'DET', nil, @aVol, oVol:loadVolumes(aCargas[nX], AllTrim(oSql:getValue("OS"))), .T.)
                oFWMsExcel:AddRow("Faturamento","CARGAS",{ aCargas[nX],;
                    oCarga:getTransp()[2],;
                    AllTrim(oSql:getValue("OS")),;
                    oSql:getValue("CLI") + oSql:getValue("LOJA") + '-' + AllTrim(oSql:getValue("NOME")),;
                    aVol[01, 04],;
                    aVol[01, 05],;
                    aVol[01, 06],;
                    aVol[01, 07],;
                    aVol[01, 08],;
                    aVol[01, 09],;
                    aVol[01, 10],;
                    iif(empty(oSql:getValue("ENT")), AllTrim(oSql:getValue("MUN")) + ' - ' + oSql:getValue("UF"),AllTrim(oSql:getValue("ENT"))),;
                    AllTrim(oSql:getValue("MUN")) + ' - ' + oSql:getValue("UF"),;
                    oSql:getValue("PAG"),;
                    AllTrim(oSql:getValue("REP")),;
                    AllTrim(oSql:getValue("ATE")),;
                    AllTrim(oSql:getValue("AGE")),;
                    AllTrim(oSql:getValue("OBS")),;
                    oStatic:sP(2):callStatic('cbcMngFCarga', 'getObs', aCargas[nX], AllTrim(oSql:getValue("OS"))),;
                    aVol[01, 10],;
                    aVol[01, 11],;
                    aVol[01, 12];
                    })
                oSql:skip()
            endDo
        endif
        oSql:close()
        FreeObj(oSql)
    next nX
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cNomArqv)

    oExcel := MsExcel():New()
    oExcel:WorkBooks:Open(cNomArqv)
    oExcel:SetVisible(.T.)
    oExcel:Destroy()

    FreeObj(oFWMsExcel)
    FreeObj(oExcel)
return(nil)

static function PergCarga(aCargas)
    local aPergs	 := {}
    local aRet		 := {}
    default aCargas  := {}

    if empty(aCargas)
        aAdd( aPergs ,{1, "Carga: ", Space(TamSX3("ZZ9_ORDCAR")[1]), "", ".T.", "", "", 50, .T.})
        if !ParamBox(aPergs ,"Definir Carga",aRet)
            Alert("Impressão Cancelada")
        else
            aAdd(aCargas, aRet[01])
        endIf
    endif
return(aCargas)
