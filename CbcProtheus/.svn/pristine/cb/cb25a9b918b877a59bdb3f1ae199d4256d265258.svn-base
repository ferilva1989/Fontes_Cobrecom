#include 'protheus.ch'
#include 'parmtype.ch'
#include "Totvs.ch"
#include 'cbcOrdemSep.ch'
#include 'cbcOrdemCar.ch'

user function cbcPlanAgenda(aCargas)//cbcPlanAgenda({'00000007'})
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
    local aVol       := {}
    local cNomArqv   := GetTempPath() + 'PlanAGENDA_' + dToS(Date()) + "_" + StrTran(Time(), ':', '-')+ '.xml'
    Local oStatic    := IfcXFun():newIfcXFun()

    oFWMsExcel := FWMSExcel():New()
    oFWMsExcel:AddworkSheet("Agendamento")
    oFWMsExcel:AddTable("Agendamento","CARGAS")
    oFWMsExcel:AddColumn("Agendamento","CARGAS","Nota Fiscal",1)
    oFWMsExcel:AddColumn("Agendamento","CARGAS","Carga",1)
    oFWMsExcel:AddColumn("Agendamento","CARGAS","Transp.",1)
    oFWMsExcel:AddColumn("Agendamento","CARGAS","OS",1)
    oFWMsExcel:AddColumn("Agendamento","CARGAS","Cliente",1)
    oFWMsExcel:AddColumn("Agendamento","CARGAS","FAR",1)
    oFWMsExcel:AddColumn("Agendamento","CARGAS","CAR",1)
    oFWMsExcel:AddColumn("Agendamento","CARGAS","BOB",1)
    oFWMsExcel:AddColumn("Agendamento","CARGAS","PAL",1)
    oFWMsExcel:AddColumn("Agendamento","CARGAS","CXS",1)
    oFWMsExcel:AddColumn("Agendamento","CARGAS","ROLOS",1)
    oFWMsExcel:AddColumn("Agendamento","CARGAS","PESO",1)
    oFWMsExcel:AddColumn("Agendamento","CARGAS","Repres.",1)
    oFWMsExcel:AddColumn("Agendamento","CARGAS","Assist.",1)
    oFWMsExcel:AddColumn("Agendamento","CARGAS","Agendar",1)

    for nX := 1 to len(aCargas)
        oCarga:define(aCargas[nX])
        oSql := LibSqlObj():newLibSqlObj()
        oSql:newAlias(oStatic:sP(2):callStatic('cbcQryCarga', 'qryAddView', aCargas[nX], ''))
        if oSql:hasRecords()
            oSql:goTop()
            while oSql:notIsEof()
                if AllTrim(oSql:getValue("AGE")) == 'S'
                    aVol := {}
                    oStatic:sP(5):callStatic('cbcManifesto', 'mntDados', 'DET', nil, @aVol, oVol:loadVolumes(aCargas[nX], AllTrim(oSql:getValue("OS"))), .T.)
                    oFWMsExcel:AddRow("Agendamento","CARGAS",;
                        {AllTrim(oSql:getValue("DOC")) + '/' + AllTrim(oSql:getValue("SERIE")),;
                        aCargas[nX],;
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
                        AllTrim(oSql:getValue("REP")),;
                        AllTrim(oSql:getValue("ATE")),;
                        AllTrim(oSql:getValue("AGE"));
                        })
                endif
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

    FreeObj(oVol)
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
