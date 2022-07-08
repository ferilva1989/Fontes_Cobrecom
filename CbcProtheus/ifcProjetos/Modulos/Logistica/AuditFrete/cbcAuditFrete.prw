#include 'TOTVS.ch'

class cbcAuditFrete
    data lSalvar
    method newcbcAuditFrete()
    method showJsCrud()
    method doCalc()
    method bestForDest()
    method calcTax()
    method simulFrete()
    method readXMl()
    method validCalc()
    method loteCalc()
endClass

method newcbcAuditFrete() class cbcAuditFrete
    ::lSalvar := .F.
return(self)

method showJsCrud(oJs, cTitulo) class cbcAuditFrete
    local  oModal       as object
    local oContainer    as object
    local nX            as numeric
    local oTFont        as object
    local aButtons      as array
    private aRegras     as array
    private oDespesBrw  as object
    private lAllOk      as logical
    default cTitulo     := 'Calculo de Frete'
    
    ::lSalvar := .F.
    oTFont := TFont():New('Courier new',,-16,.T.)
    oModal  := FWDialogModal():New()
    oDespesBrw := fwBrowse():New()
    lAllOk := .T.
    aButtons := {}
    aadd(aButtons, {,'EXPORTAR',{||export(oJs)}, 'exportar',,.T.,.F.})
    aadd(aButtons, {,'IMPORTAR',{||import(@oDespesBrw, @aRegras)}, 'importar',,.T.,.F.})
    aadd(aButtons, {,'SALVAR',{||salvar(@self, @oModal)}, 'salvar',,.T.,.F.})
    doRegra(oJs, @aRegras)
           
    oModal:SetEscClose(.T.)
    oModal:setTitle(cTitulo)
    oModal:setSubTitle("Componentes de Frete")
    oModal:setSize(300, 640)
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    oModal:addButtons(aButtons)
    oContainer := TPanel():New( ,,, oModal:getPanelMain() )
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT
    
    oDespesBrw:setDataArray()
    oDespesBrw:setArray(aRegras)
    oDespesBrw:disableConfig()
    oDespesBrw:disableReport()
    oDespesBrw:setOwner(oContainer) 
    oDespesBrw:lHeaderClick:=.F.

    oDespesBrw:addColumn({"Componente", {||aRegras[oDespesBrw:nAt,1]}, "C",;
    pesqPict("SC5","C5_NUM"), 1,20,,.T.,,.F.,,"xCOMPONENTE",,.F.,.T.,/*getList()*/,"xCOMPONENTE"})

    oDespesBrw:addColumn({"Calculo", {||aRegras[oDespesBrw:nAt,2]}, "C",,1,1,0,.T.,,.F.,,;
    "xCALCULO",,.F.,.T., {"1=Valor","2=Peso" },"xCALCULO"})

    oDespesBrw:addColumn({"Tipo", {||aRegras[oDespesBrw:nAt,3]}, "C",,1,1,0,.T.,,.F.,,;
    "xTPCALCULO",,.F.,.T., getTipo(),"xTPCALCULO"})

    oDespesBrw:addColumn({"Valor", {||aRegras[oDespesBrw:nAt,4]}, "N",;
    pesqPict("SC6","C6_PRCVEN"), 1,tamSx3("C6_PRCVEN")[1],tamSx3("C6_PRCVEN")[2],.T.,,.F.,,;
    "xVALOR",,.F.,.T.,,"xVALOR"})

    oDespesBrw:addColumn({"Minimo", {||aRegras[oDespesBrw:nAt,5]}, "N",;
    pesqPict("SC6","C6_PRCVEN"), 1,tamSx3("C6_PRCVEN")[1],tamSx3("C6_PRCVEN")[2],.T.,,.F.,,;
    "xMINVALOR",,.F.,.T.,,"xMINVALOR"})

    oDespesBrw:addColumn({"AuxNum", {||aRegras[oDespesBrw:nAt,6]}, "N",;
    pesqPict("SC6","C6_PRCVEN"), 1,tamSx3("C6_PRCVEN")[1],tamSx3("C6_PRCVEN")[2],.T.,,.F.,,;
    "xAUXVALOR",,.F.,.T.,,"xAUXVALOR"})

    oDespesBrw:addColumn({"Expressão", {||aRegras[oDespesBrw:nAt,7]}, "C",;
    pesqPict("SC5","C5_OBS"), 1,tamSx3("C5_OBS")[1],,.T.,,.F.,,;
    "xEXPRESSAO",,.F.,.T.,,"xEXPRESSAO"})

    oDespesBrw:addColumn({"Cond", {||aRegras[oDespesBrw:nAt,8]}, "C",;
    pesqPict("SC5","C5_OBS"), 1,tamSx3("C5_OBS")[1],,.T.,,.F.,{||editar(@oDespesBrw, @aRegras)},;
    "xCONDICAO",,.F.,.T.,,"xCONDICAO"})

    oDespesBrw:setEditCell(.T.,{|| vldDoc()})
    oDespesBrw:setInsert(.T.)
    oDespesBrw:setLineOk({|| chkLineOk()})
    oDespesBrw:setAfterAddLine({||posIncLine()})
    oDespesBrw:SetDelete(.T.,{|| delreg()})
    oDespesBrw:SetProfileID('BTAB')
    oDespesBrw:SetTypeMove(0) 
    oDespesBrw:SetDescription('Componetes da tabela de Frete')
    oDespesBrw:SetFontBrowse(oTFont) 
    for nX := 1 to 8
        oDespesBrw:acolumns[nX]:ledit     := .T.
        oDespesBrw:acolumns[nX]:cReadVar:= 'aRegras[oDespesBrw:nAt,'+ cValToChar(nX) +']'
    next nX
    
    oDespesBrw:activate()  
    oModal:Activate()
    chkLineOk(.F.)
    RegraJs(@oJs, aRegras, Self)
    FreeObj(oModal)
return(self)

method doCalc(nPeso, nValor, oJs, cOrig, cDest, cIcms) class cbcAuditFrete
    local nX            as numeric
    local aComponentes  as array
    local oJsAudit      as object
    local bErro         as object
    local lRet          as logical
    default cIcms := 'S'
    lRet                             := .T.
    nX                               := 0
    aComponentes                     := oJs:GetNames()
    oJsAudit                         := JsonObject():New()
    oJs['AUDIT_CALC']                := {}
    oJsAudit['PESO_NOTA']            := nPeso
    oJsAudit['VALOR_NOTA']           := nValor
    oJsAudit['FRETE_CALCULO']        := {}
    oJsAudit['TOTAL_FRETE']          := 0
    oJsAudit['UF_ORIGEM']            := cOrig
    oJsAudit['UF_DESTINO']           := cDest
    bErro  := ErrorBlock({|oErr| handlval(oErr, @lRet)})
    BEGIN SEQUENCE
        for nX := 1 to len(aComponentes)
        if aComponentes[nX] != 'AUDIT_CALC'
            if &(Alltrim(oJs[aComponentes[nX]][8]))
                if peAudit(nX, aComponentes, oJs, self )
                    aadd(oJsAudit['FRETE_CALCULO'], { aComponentes[nX], &(oJs[aComponentes[nX]][7])})
                    oJsAudit['TOTAL_FRETE']  += aTail(oJsAudit['FRETE_CALCULO'])[2]
                endif
            endif
        endif
        next nX
        ::calcTax(@oJsAudit, cIcms)
        aadd(oJs['AUDIT_CALC'] , oJsAudit)
    END SEQUENCE
    ErrorBlock(bErro)
return lRet


method simulFrete() class cbcAuditFrete
    local aParamBox as array
    local aRet      as array
    local aBest     as array
    local cHtml     as char
    local nX        as numeric
    local cPic      as char
    local oEdit     as object
    local oDlg      as object
    aParamBox   := {}
    aRet        := {}
    aBest       := {}
    cPic        :=  X3Picture('C5_TOTAL')
    aadd(aParamBox,{1,"Cidade", Space(TamSx3('GU7_NRCID')[1]),"","","GU7GUA","",0,.T.})
    aadd(aParamBox,{1,"UF_Destino",Space(2),"","","12",".F.",0,.T.})
    aadd(aParamBox,{1,"Peso_KG",0,PesqPict('SC6','C6_PRCVEN'),"mv_par03>0","","",120,.T.})
    aadd(aParamBox,{1,"Valor_R$",0,PesqPict('SC6','C6_PRCVEN'),"mv_par04>0","","",120,.T.})
    if ParamBox(aParamBox,"Simulação Frete - Avulsa",@aRet)
        if !empty(aBest := ::bestForDest(aRet[02],aRet[01], aRet[03], aRet[04]))
            cHtml := "<h2> Destino " + '(' +  Alltrim(GU7->(GU7_NRCID)) + ' ) - ' + Alltrim(GU7->(GU7_NMCID)) + '/' +  Alltrim(GU7->(GU7_CDUF)) + " </h2>"
            cHtml += " < br /> "
            cHtml += "<h3> PesoKG " + Alltrim(TRANSFORM(aRet[03],cPic)) + " Valor " + Alltrim(TRANSFORM(aRet[04],cPic)) + "</h3>"
            cHtml += " < br /> "
            cHtml += ' <table border="1" style="width:100%"> '
            cHtml += " <tr> "
            cHtml += " <th>Transportadora</th> "
            cHtml += " <th>Rota</th> "
            cHtml += " <th>Frete</th> "
            cHtml += " <th>ICMS</th> "
            cHtml += " <th>Total</th> "
            cHtml += " </tr> "
            for nX := 1 to len(aBest)
               cHtml += " <tr>
               cHtml += " <td> " + Alltrim(aBest[nX]['TRANSP'])      + "</td>"
               cHtml += "<td> "  + Alltrim(aBest[nX]['ROTA'])        + "</td>"
               cHtml += "<td> "  + Alltrim(TRANSFORM(aBest[nX]['FRETE'], cPic) )    + "</td>"
               cHtml += "<td> "  + Alltrim(TRANSFORM(aBest[nX]['ICMS'], cPic) )    + "</td>"
               cHtml += "<td> "  + Alltrim(TRANSFORM(aBest[nX]['TOTAL'], cPic) )    + "</td>"
               cHtml += "</tr>
            next nX
            cHtml += "</table>
            cHtml += " < br /> "
            cHtml += " <h4> Data Simulação: " + DtoC(date()) + "</h4>"
            DEFINE DIALOG oDlg TITLE "Simulação de Frete" FROM 180, 180 TO 550, 700 PIXEL
            oEdit := tSimpleEditor():New(0, 0, oDlg, 360, 284)
            oEdit:Load(cHtml)
            ACTIVATE DIALOG oDlg CENTERED
            FreeObj(oEdit)
            FreeObj(oDlg)
        endif
    endif
return self


method bestForDest(cUfDest, cIbge, nPeso, nValor) class cbcAuditFrete
    local aEmpInfo   as array
    local aCfgUf     as array
    local nPos       as numeric
    local cUfOrigem  as char
    local aJsOpc     as array
    local nX         as numeric
    local bErro      as object

    aEmpInfo  := FWArrFilAtu(FWCodEmp(),FWCodFil())
    aCfgUf    := {}
    aJsOpc    := {}
    aadd(aCfgUf, {'01', 'SP'})
    aadd(aCfgUf, {'02', 'MS'})
    aadd(aCfgUf, {'03', 'MG'})
    if (nPos := aScan(aCfgUf, {|x| x[1] == aEmpInfo[5] }) ) > 0
        bErro  := ErrorBlock({|oErr| handlval(oErr)})
        BEGIN SEQUENCE
            cUfOrigem := aCfgUf[nPos][2]
            getjsOpc(cUfDest, cIbge, @aJsOpc)
            for nX := 1 to len(aJsOpc)
                if aJsOpc[nX]['CALCULAR'] == nil
                    aJsOpc := {}
                    MsgInfo('Calculo não formatado', 'Aviso')
                    exit
                else
                    aJsOpc[nX]['FRETE']  := 0
                    aJsOpc[nX]['ICMS']   := 0
                    aJsOpc[nX]['TOTAL']  := 0
                    ::doCalc(nPeso, nValor, @aJsOpc[nX]['CALCULAR'], cUfOrigem, cUfDest, aJsOpc[nX]['CALC_ICMS'])
                    aJsOpc[nX]['FRETE'] := aJsOpc[nX]['CALCULAR']['AUDIT_CALC'][1]['TOTAL_FRETE']
                    if aJsOpc[nX]['CALC_ICMS'] == 'S'
                        aJsOpc[nX]['ICMS']  := aJsOpc[nX]['CALCULAR']['AUDIT_CALC'][1]['ICMS'][1]['VLR']
                    endif
                    aJsOpc[nX]['TOTAL'] := (aJsOpc[nX]['FRETE'] + aJsOpc[nX]['ICMS'])
                endif
            next nX
            if empty(aJsOpc)
                MsgInfo('Nenhuma Transportadora para Destino', 'Aviso')
            else
                aSort(aJsOpc ,,, { |x,y| ( x['TOTAL'] < y['TOTAL'] ) } )
            endif
            RECOVER
                aJsOpc := {}
        END SEQUENCE
        ErrorBlock(bErro)
    else
        MsgInfo('Filial não encontrada', 'Aviso')
    endif
return aJsOpc

 
 method calcTax(oJs, cIcms) class cbcAuditFrete
    local oJsIcm  as object
    local nAliq   as numeric
    local oSql    as object
    default cIcms := 'S'
    // GFEA013 Aliquota x UF
    if cIcms == 'S'
        oJs['ICMS'] := {}
        oSql      := LibSqlObj():newLibSqlObj()
        oSql:newAlias(gtAliq(oJs['UF_ORIGEM'], oJs['UF_DESTINO']))
        oSql:GoTop()
        if oSql:hasRecords()
            nAliq := oSql:getValue("ALIQ_INTER") 
            oJsIcm   := JsonObject():New()
            oJsIcm['BASE']  := oJs['TOTAL_FRETE']
            oJsIcm['ALIQ']  := nAliq
            oJsIcm['TOTAL'] := ((oJs['TOTAL_FRETE'] / (100-nAliq)) * 100 )
            oJsIcm['VLR']   := ( oJsIcm['TOTAL'] - oJs['TOTAL_FRETE'])
            aadd(oJs['ICMS'], oJsIcm )
        endif
        oSql:close()
        FreeObj(oSql)
     endif
 return self


method readXMl(oXmlPar, lShwDlg) class cbcAuditFrete
local cError    := ''
    local cWarning  := ''
    local oXml      := nil
    local nX        := 0
    local oCTe      := nil
    local oInfQ     := nil
    local oDlg      := nil
    local oEdit     := nil
    default lShwDlg := .F.
    bErro  := ErrorBlock({|oErr| handlval(oErr)})
    BEGIN SEQUENCE
        if Valtype(oXmlPar) != 'O'
            oXml := XmlParser(oXmlPar,"_",@cError,@cWarning)
            oCTe := oXml:_CTEPROC:_CTE
        else
            oCTe := oXmlPar
        endif
        oJs  := JsonObject():New()
        
        // Informações do CTE
        oJs['CHV_CTE']   := SubStr(oCTe:_INFCTE:_ID:TEXT,4,44)
        oJs['TIPO_CTE']  := XmlValid(oCTe,{"_INFCTE","_IDE"},"_TPCTE")
		oJs['TIPO_SRV']  := XmlValid(oCTe,{"_INFCTE","_IDE"},"_TPSERV")
        
        // Redespacho Intermediário e Serviço Multimodal
        if oJs['TIPO_SRV'] $ "3;4"
			oJs['oDocAnt'] := XmlChildEx(oCTe:_INFCTE:_INFCTENORM, "_DOCANT")
			if (oDocAnt != nil)
			    oJs['oCTeAnt'] := oCTe:_INFCTE:_INFCTENORM:_DOCANT:_EMIDOCANT:_IDDOCANT
			else
                s['oCTeAnt'] := nil
            endif
		else
            oJs['oDocAnt'] := nil
        endif

        // CNPJ TRANSPORTADORA
         oJs['CNPJ_TRANSP'] := XmlValid(oCTe,{"_INFCTE","_EMIT"},"_CNPJ")
        
        // VALOR DO FRETE
        oJs['VALOR_FRETE'] := XmlValid(oCTe,{"_INFCTE","_VPREST"},"_VTPREST")

        // PESO CARGA
        oInfQ := XmlValid(oCTe,{"_INFCTE","_INFCTENORM","_INFCARGA"},"_INFQ") 
        if ValType(oInfQ) == "A"
            For nX := 1 To Len(oInfQ)
                if oInfQ[nX]:_CUNID:TEXT == '01' // KG
                    oJs['PESO_CARGA'] := Val(oInfQ[nX]:_QCARGA:TEXT)
                    exit
                elseif oInfQ[nX]:_CUNID:TEXT == '02' // TON
                    oJs['PESO_CARGA'] := Val(oInfQ[nX]:_QCARGA:TEXT) * 1000
                    exit
                endif
            next nX
        elseif ValType(oInfQ) == "O"
            if oInfQ:_CUNID:TEXT == '01' // KG
                oJs['PESO_CARGA'] := Val(oInfQ:_QCARGA:TEXT)
            elseif oInfQ:_CUNID:TEXT == '02' // TON
                oJs['PESO_CARGA'] := Val(oInfQ:_QCARGA:TEXT) * 1000
            endif
        else
            oJs['PESO_CARGA'] := 0
        endif
        
        // VALOR CARGA
        if XmlValid(oCTe,{'_INFCTE','_INFCTENORM','_INFCARGA','_VCARGA'},'_VCARGA',.T.) == "vCarga"
            oJs['VALOR_CARGA'] := Val(XmlValid(oCTe,{'_INFCTE','_INFCTENORM','_INFCARGA'},'_VCARGA'))
        elseif XmlValid(oCTe,{'_INFCTE','_INFCTENORM','_INFCARGA','_VMERC'},'_VMERC',.T.) == "vMerc"
            oJs['VALOR_CARGA'] := Val(XmlValid(oCTe,{'_INFCTE','_INFCTENORM','_INFCARGA'},'_VMERC'))
        else
            oJs['VALOR_CARGA'] := 0
        endif
        
        // CHAVE NOTA
        oJs['CHAVE_NFE'] := {}
        aNFe := XmlValid(oCTe,{"_INFCTE","_INFCTENORM","_INFDOC"},"_INFNFE",,.T.)
        if ValType(aNFe) == "A"
            for nX := 1 to len(aNFe)
                aadd(oJs['CHAVE_NFE'], aNFe[nX]:_CHAVE:TEXT)
            next nX
        elseif ValType(aNFe) == "O"
            aadd(oJs['CHAVE_NFE'], aNFe:_CHAVE:TEXT)
        endif
        
        // COMPONENTES CALCULO
        _aComp  := XmlValid(oCTe,{"_INFCTE","_VPREST"},"_COMP",,.T.) 
        oJs['COMP'] := {}
        if ValType(_aComp) == "A"
            for nX := 1 to len(_aComp)
                oJsComp := JsonObject():New()
                oJsComp['NOME']  := _aComp[nX]:_XNOME:TEXT
                oJsComp['VALOR'] := _aComp[nX]:_VCOMP:TEXT
                aadd(oJs['COMP'],oJsComp)
            next nX
        elseif ValType(_aComp) == "O"
            oJsComp := JsonObject():New()
            oJsComp['NOME']  := _aComp:_XNOME:TEXT
            oJsComp['VALOR'] := _aComp:_VCOMP:TEXT
            aadd(oJs['COMP'],oJsComp)
        endif
        if lShwDlg
            DEFINE DIALOG oDlg TITLE "JSON-Result" FROM 180, 180 TO 550, 700 PIXEL
            oEdit := tSimpleEditor():New(0, 0, oDlg, 260, 184)
            oEdit:Load(oJs:toJSon())
            ACTIVATE DIALOG oDlg CENTERED
        endif
    END SEQUENCE
    ErrorBlock(bErro)
return oJs


method validCalc(xXml) class cbcAuditFrete
    local nX        as numeric
    local oJsRet    as object
    local lLoopOk   as logical
    local lCnpjOk   as logical
    local cErrCnpj  as character
    local oDpl      as object
    local bErro     as object
    local nQtdChv   as numeric
    local aRetMult  as array
    
    nQtdChv                     := 0
    lLoopOk                     := .T.
    lCnpjOk                     := .T.
    cErrCnpj                    := ''
    aRetMult                    := {}
    oJsRet                      := JsonObject():New()
    oJsRet['STS']               := .T.
    oJsRet['MSG']               := ''
    oJsRet['EDISIT']            := ''
    oJsRet['INFO']              := JsonObject():New()
    oJsRet['TOTAL_MEM']         := 0
    oJsRet['TOTAL_CTE']         := 0
    oJsRet['PERC_DIF']          := 0
    oJsRet['DIF_PERM']          := GetNewPar('ZZ_FRTDESV', 0)
    oJsRet['DIF_ROUND']         := GetNewPar('ZZ_FRTROUN', 0.02)
    oJsRet['INFO']['CALC_MEM']  := {}
    
    bErro  := ErrorBlock({|oErr| handlDif(oErr, @oJsRet)})
    BEGIN SEQUENCE
        oJsRet['INFO']['CALC_CTE']  := ::readXMl(xXml, .F.)
        oJsRet['TOTAL_CTE']         := oJsRet['INFO']['CALC_CTE']['VALOR_FRETE']
        nQtdChv := len(oJsRet['INFO']['CALC_CTE']['CHAVE_NFE'])
        for nX := 1 to nQtdChv
            oDpl := vldDupl(Alltrim(oJsRet['INFO']['CALC_CTE']['CHAVE_NFE'][nX]), Alltrim(oJsRet['INFO']['CALC_CTE']['CHV_CTE']))
            if !oDpl['STS']
                oJsRet['STS']       := oDpl['STS']
                oJsRet['MSG']       := oDpl['MSG']
                oJsRet['EDISIT']    := 'Z'
                lLoopOk := .F.
                exit
            else
                aadd(oJsRet['INFO']['CALC_MEM'], calcMemo(oJsRet['INFO']['CALC_CTE']['CHAVE_NFE'][nX]))
                if aTail(oJsRet['INFO']['CALC_MEM']) == nil
                    oJsRet['STS']       := .F.
                    oJsRet['MSG']       := 'Nota Saida Chave:' + Alltrim(oJsRet['INFO']['CALC_CTE']['CHAVE_NFE'][nX]) + ' sem memoria de calculo'
                    oJsRet['EDISIT']    := 'Z'
                    lLoopOk := .F.
                    exit
                endif
            endif
        next nX
        if lLoopOk
            for nX := 1 to len(oJsRet['INFO']['CALC_MEM'] )
                // Validar CNPJ Transportadora CTE x Memoria Calculo
                if Alltrim(oJsRet['INFO']['CALC_MEM'][nX]['CNPJ_TRANSP']) != Alltrim(oJsRet['INFO']['CALC_CTE']['CNPJ_TRANSP'])
                    lCnpjOk             := .F.
                    cErrCnpj            += 'CNPJ_CTE:' + Alltrim(oJsRet['INFO']['CALC_CTE']['CNPJ_TRANSP']) +;
                    'CNPJ_CARGA:'+Alltrim(oJsRet['INFO']['CALC_MEM'][nX]['CNPJ_TRANSP']) + '-' 
                endif          
                if empty( oJsRet['INFO']['CALC_MEM'][nX]['CALCULAR']['AUDIT_CALC'][1]['ICMS'] )
                    oJsRet['TOTAL_MEM']  += oJsRet['INFO']['CALC_MEM'][nX]['CALCULAR']['AUDIT_CALC'][1]['TOTAL_FRETE']
                else
                    oJsRet['TOTAL_MEM']  += oJsRet['INFO']['CALC_MEM'][nX]['CALCULAR']['AUDIT_CALC'][1]['ICMS'][1]['TOTAL']
                endif
            next nX
        endif
        if lLoopOk
            if oJsRet['TOTAL_MEM'] == 0
                oJsRet['STS']        := .F.
                oJsRet['MSG']        := 'Memoria de Calculo não encontrada'
                oJsRet['EDISIT']     := 'Z'
            else
                if (nQtdChv > 1) .and. GetNewPar('ZX_MULTCHV', .T.)
                    aRetMult := ::loteCalc(oJsRet['INFO']['CALC_CTE']['CHAVE_NFE'])
                    oJsRet['TOTAL_MEM'] := aRetMult[1]
                endif
                
                oJsRet['VLR_DIF']  := (val(oJsRet['TOTAL_CTE']) - oJsRet['TOTAL_MEM'])
                oJsRet['PERC_DIF'] := ((oJsRet['VLR_DIF'] * 100) / oJsRet['TOTAL_MEM'] )
                if lCnpjOk
                    if Abs(oJsRet['VLR_DIF']) > oJsRet['DIF_ROUND'] 
                        if (Abs(oJsRet['PERC_DIF']) > Abs(oJsRet['DIF_PERM']))
                            oJsRet['STS']       := .F.
                            oJsRet['MSG']       := 'Divergência de cobrança'
                            oJsRet['EDISIT']    := 'Z'
                        endif
                    endif
                else
                    oJsRet['STS']       := .F.
                    oJsRet['MSG']       := 'Transportadora x CNPJ:' + cErrCnpj 
                    oJsRet['EDISIT']    := 'Z'
                endif
            endif
        endif
    END SEQUENCE
    ErrorBlock(bErro)
return oJsRet


method loteCalc(aChNf) class cbcAuditFrete
    local nX        as numeric
    local nY        as numeric
    local nValor    as numeric
    local nPeso     as numeric
    local nTotMst   as numeric
    local lIcms     as logical
    local oMem      as object
    local nTot      as numeric
    local aNames    as array
    local aChvCalc  as array
    local aGerCalc  as array
    nValor    := 0
    nPeso     := 0
    nTotMst   := 0
    lIcms     := .F.
    oMem      := nil
    nTot      := 0
    aNames    := {}
    aChvCalc  := {}
    aGerCalc  := {}
    
    for nX := 1 to len(aChNf)
         oMem := calcMemo(aChNf[nX])
         if (oMem != nil)
            aNames  := oMem['CALCULAR']:GetNames()
            aChvCalc := {aChNf[nX],{},0,0,0}
            if(lIcms   := (oMem['CALC_ICMS'] == "S"))
                aChvCalc[4] := oMem['CALCULAR']['AUDIT_CALC'][1]['ICMS'][1]['ALIQ']
            endif
            for nY := 1 to len(aNames)
                if aNames[nY] != "AUDIT_CALC"
                    if len(oMem['CALCULAR'][aNames[nY]]) > 6
                        if &(oMem['CALCULAR'][aNames[nY]][8])
                            aadd(aChvCalc[2],{;
                            oMem['CALCULAR'][aNames[nY]][1],;
                            oMem['CALCULAR'][aNames[nY]][7],0})
                        endif   
                    endif
                endif
            next nY
            aadd(aGerCalc,aChvCalc)
            nTot    += oMem['TOTAL']
            oMem    := oMem['CALCULAR']['AUDIT_CALC'][1]
            nValor  += oMem['VALOR_NOTA']
            nPeso   += oMem['PESO_NOTA']
         endif
    next nX
    for nX := 1 to len(aGerCalc)
        for nY := 1 to len(aGerCalc[nX][2])
            aGerCalc[nX][2][nY][3]  += &(aGerCalc[nX][2][nY][2])
            aGerCalc[nX][3]         += aGerCalc[nX][2][nY][3]
        next nY
        if aGerCalc[nX][4] > 0            
            aGerCalc[nX][5] := ((aGerCalc[nX][3] / (100-aGerCalc[nX][4])) * 100 )
            nTotMst += aGerCalc[nX][5]
        else
            nTotMst += aGerCalc[nX][3]
        endif
    next nX
    if len(aGerCalc) > 0
        nTotMst := (nTotMst / len(aGerCalc))
    endif
return {nTotMst,aGerCalc} 


/* FUNÇÔES STATICAS */
static function editar(oBrw, aRegra)
    local aReg := {}
    local cRegra := ''
    Local oStatic    := IfcXFun():newIfcXFun()
    if !empty(cRegra := oStatic:sP(1):callStatic('cbcBldExp', 'ExpTranslate', u_cbcBldExp(aReg)))
        aRegras[oDespesBrw:nAt,8] := Alltrim(cRegra)
        //oBrw:Refresh()
    endif
return cRegra


static function salvar(oSelf, oModal)
    if (oSelf:lSalvar := MsgYesNo('Salvar', 'Componentes de Calculo'))
        Eval(oModal:BCLOSE)
    endif
return nil

static function import(oDespesBrw, aRegras) 
    local oFile     := nil
    local cJs       := ''
    local oJs       := nil
    local cTargetDir := ''
    local cMascara  := "*.json|*.json"
    local cTitulo   := "Escolha o arquivo"
    local nMascpad  := 0
    local cDirini   := "\"
    local lSalvar   := .F. /*.T. = Salva || .F. = Abre*/
    local nOpcoes   := GETF_LOCALHARD
    local lArvore   := .F. 
    cTargetDir := cGetFile(cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)
    if !Empty(cTargetDir)
        oFile := FWFileReader():New(cTargetDir)
        if (oFile:Open())
            while (oFile:hasLine())
                cJs += oFile:GetLine()
            end
            oFile:Close()
            oJs := JsonObject():new()
            if (oJs:fromJson(cJs)) == nil
                aRegras := {}
                doRegra(oJs, @aRegras)
                oDespesBrw:setArray(aRegras)
                oDespesBrw:Refresh()
            else
                MsgAlert('Estrutura arquivo inválida', 'Importar configuração')
            endif
            FreeObj(oJs)
        else
            MsgAlert('Falha ao abrir o arquivo', 'Importar configuração')
        endif
    endif
return nil


static function export(oJs)
    Local oFile      := nil
    local cTargetDir := ''
    local cMascara  := "*.json|*.json"
    local cTitulo   := "Escolha o arquivo"
    local nMascpad  := 0
    local cDirini   := "\"
    local lSalvar   := .T. /*.T. = Salva || .F. = Abre*/
    local nOpcoes   := GETF_LOCALHARD
    local lArvore   := .F. 
    cTargetDir := cGetFile(cMascara, cTitulo, nMascpad, cDirIni, lSalvar, nOpcoes, lArvore)
    if !Empty(cTargetDir)
        oFile := FWFILEWRITER():new(cTargetDir, .F.)
        if oFile:Exists()
            oFile:Erase()
        endif
        if (oFile:Create())
            if oFile:Write(oJs:toJSon())
                MsgInfo('Exportado com sucesso para ' + Alltrim(cTargetDir), 'Exportar configuração')
            else
                MsgAlert('Falha ao gravar o arquivo', 'Exportar configuração')
            endif
            oFile:Close()
        else
            MsgAlert('Falha ao criar o arquivo', 'Exportar configuração')
        endif
        FreeObj(oFile)
    else
        MsgAlert('Nenhum arquivo selecionado', 'Exportar configuração')
    endif
return nil


static function vldDupl(cChave, cChvCte)
    local oSql     as object
    local jsRet    as object
    local nX       as numeric
    
    jsRet               := JsonObject():New()
    jsRet['STS']        := .T.
    jsRet['CVH_CTE']    := {}
    jsRet['CVH_NOTA']   := cChave
    jsRet['MSG']        := ''
    oSql      := LibSqlObj():newLibSqlObj()
    oSql:newAlias(cteFromNfe(cChave,Alltrim(cChvCte)))
    oSql:GoTop()
    while oSql:notIsEof()
        aadd(jsRet['CVH_CTE'], oSql:getValue("CHV_CTE"))
        oSql:skip()
    enddo
    if len(jsRet['CVH_CTE']) > 0
        jsRet['STS'] := .F.
        jsRet['MSG'] := 'Nota Chave: ' + Alltrim(cChave) + ' ja relacionada com os seguintes CTEs Chave: ' + chr(13) + chr(10)
        for nX := 1 to len(jsRet['CVH_CTE'])
            jsRet['MSG'] += jsRet['CVH_CTE'][nX] + chr(13) + chr(10)
        next nX
    endif
    oSql:close()
    FreeObj(oSql)
return jsRet


static function calcMemo(cChave )
    local oMemCalc as object
    local oSql     as object
    local nRec     as numeric
    oMemCalc        := nil
    oSql      := LibSqlObj():newLibSqlObj()
    oSql:newAlias(memCalc(cChave))
    oSql:GoTop()
    DbSelectArea('ZZ9')
      while oSql:notIsEof()
        if (nRec := oSql:getValue("RECZ9") ) > 0
            oMemCalc  := JsonObject():New()
            ZZ9->(Dbgoto(nRec))
            oMemCalc:fromJson(ZZ9->(ZZ9_JSCTE))
        endif
        oSql:skip()
    enddo
    oSql:close()
    FreeObj(oSql)
return oMemCalc


static function getjsOpc(cUfDest, cIbge, aJsOpc)
    local oSql    as object
    local oJsInfo as object
    local oCalc   as object
    local nRec    as numeric
    aJsOpc    := {}
    oSql      := LibSqlObj():newLibSqlObj()
    oSql:newAlias(transRoute(cUfDest,cIbge))
    oSql:GoTop()
    DbSelectArea('ZF1')
    while oSql:notIsEof()
        if (nRec := oSql:getValue("REC") ) > 0
            oJsInfo   := JsonObject():New()
            oCalc     := JsonObject():New()
            ZF1->(Dbgoto(nRec))
            oCalc:fromJson(ZF1->(ZF1_JSCALC))
            oJsInfo['TRANSP']       := Alltrim(ZF1->(ZF1_TRANSP)) + '-' + Alltrim(oSql:getValue("TRANSP"))
            oJsInfo['ROTA']         := Alltrim(ZF1->(ZF1_ROTA))
            oJsInfo['CALC_ICMS']    := Alltrim(ZF1->(ZF1_ICMS))
            oJsInfo['CNPJ_TRANSP']  := Alltrim(oSql:getValue("CNPJ_TRANSP"))
            oJsInfo['CALCULAR']     := oCalc
            aadd(aJsOpc, oJsInfo)
        endif
        oSql:skip()
    enddo
    oSql:close()
    FreeObj(oSql)
return nil


static function peAudit(nX, aComponentes, oJs, oSelf )
    local lRet as logical
    lRet := .T.
    // MsgInfo( aComponentes[nX] + ' - ' +  oJs[aComponentes[nX]][7], 'PE')
return lRet


static function getTipo()
    local aList as array
    aList := {}
    /* Fixo o Valor Informado é o valor considerado */
    aadd(aList, "1=Fixo")
    /* 
        Aplica o Percentual ao Calculo (peso/valor), considera valor minimo
        Max(((Calculo*Valor)/100), Minimo)
    */
    aadd(aList, "2=%"   )
    /* 
        Aplica Multiplicação ao Calculo selecionado 
        (Calculo*Valor)
    */
    aadd(aList, "3=*"   )
    /*
        Divide Calculo(peso/valor), por 100 arredondando a maior e multiplica ao Valor
        (Ceiling(Calculo/100)* Valor)
    */
    aadd(aList, "4=/100")
    /*
        Multiplica Calculo selecionado pelo Valor, multiplicado pelo AuxNum, obtendo
        um maximo entre valor minimo e resultado do calculo
        Max((((Calculo * Valor)*AuxNum)/100), Minimo)
    */
    aadd(aList, "5=*%"  )
    /*
        Considera a expressão Advpl escrita 
    */
    aadd(aList, "6=Formula")
    /*
        Aplica ao peso o valor cobrado, somente até valor max
        (if(nPeso > PesoMax, PesoMax,  nPeso ) * AuxNum)
    */
    aadd(aList, "7=PesoMax")
   
    /*
        Aplica ao peso exedente o valor cobrado.
        ( if(nPeso > 100, nPeso - 100,  0 ) * 0.35722)
    */
    aadd(aList, "8=PesoExce")
    /*
        Multiplica considerando um valor minimo.
        Max((Calculo * Valor ), Minimo)
    */
    aadd(aList, "9=*Min")
return aList

/*
static function getList()
    local aList as array
    aList := {}
    aadd(aList, "FRETE_VALOR")
    aadd(aList, "GRIS")
    aadd(aList, "TAS")
    aadd(aList, "TDE")
    aadd(aList, "PEDAGIO")
    aadd(aList, "FRETE_PESO")
return aList
*/

static function RegraJs(oJs, aReg, oSelf)
    local nX  as numeric
    if lAllOk
        oJs   := JsonObject():New()
        for nX := 1 to len(aReg)
            aReg[nX][1]      := Upper(Alltrim(aReg[nX][1]))
            oJs[aReg[nX][1]] := aReg[nX]
        next nX
    else
        MsgInfo('Registro não será salvo', 'Erro')
    endif
return nil

static function doRegra(oJs, aReg)
    local aComponentes  as array
    local nX            as numeric
    aReg    := {}
    aComponentes          := oJs:GetNames()
    for nX := 1 to len(aComponentes)
      if aComponentes[nX] != 'AUDIT_CALC'
        aadd(aReg, oJs[aComponentes[nX]])
      endif
    next nX
    if empty(aReg)
        aReg := {{space(20),space(1),space(1),0,0,0,space(tamSx3("C5_OBS")[1]), ".T."}}
    endif
return nil

static function delreg()
    local lRet as logical
    lRet := .T.
    aDel(aRegras,oDespesBrw:nAt)
	aSize(aRegras, Len(aRegras)-1)
    oDespesBrw:Refresh(.F.)
return lRet

static function vldDoc()
    local lRet as logical
    lRet := .T.
return lRet

static function chkLineOk(lScren)
    local lRet as logical
    local cCmd  as string
    local bErro as object
    private nValor as numeric
    private nPeso  as numeric
    default lScren := .T.
    
    lRet := .T.
    cCmd := ''
    bErro  := ErrorBlock({|oErr| handlerr(oErr, @lRet)})
    BEGIN SEQUENCE
        if empty(Alltrim(aRegras[oDespesBrw:nAt,1]))
            lRet := .F.
            MsgInfo('Componente obrigatorio','Erro')
        elseif empty(Alltrim(aRegras[oDespesBrw:nAt,2]))
            lRet := .F.
            MsgInfo('Calculo obrigatorio','Erro')
        elseif empty(Alltrim(aRegras[oDespesBrw:nAt,3]))
            lRet := .F.
            MsgInfo('Tipo obrigatorio','Erro')
        elseif aRegras[oDespesBrw:nAt,4] <= 0 .and. aRegras[oDespesBrw:nAt,3] != "6"
            lRet := .F.
            MsgInfo('Valor obrigatorio','Erro')
        elseif aRegras[oDespesBrw:nAt,3] == "6"
            cCmd := aRegras[oDespesBrw:nAt,7]
            if empty(cCmd)
                MsgInfo('Expressao Obrigatoria','Erro')
            endIf
            /*aRegras[oDespesBrw:nAt,1]  := space(20)
            aRegras[oDespesBrw:nAt,2]  := space(1)
            aRegras[oDespesBrw:nAt,3]  := space(1)
            aRegras[oDespesBrw:nAt,4]  := 0
            aRegras[oDespesBrw:nAt,5]  := 0
            aRegras[oDespesBrw:nAt,6]  := 0*/
        elseif aRegras[oDespesBrw:nAt,3] == "1"
            cCmd +=  cValToChar(aRegras[oDespesBrw:nAt,4])
        elseif aRegras[oDespesBrw:nAt,3] == "2"
            cCmd +=  "Max((("
            cCmd +=  if(aRegras[oDespesBrw:nAt,2] == "1" ,'nValor','nPeso')
            cCmd +=  "*"
            cCmd +=  cValToChar(aRegras[oDespesBrw:nAt,4])
            cCmd +=  ")/100), "
            cCmd +=  cValToChar(aRegras[oDespesBrw:nAt,5])"
            cCmd +=  ")"
        elseif aRegras[oDespesBrw:nAt,3] == "3"
            cCmd +=  "Max(("
            cCmd +=  if(aRegras[oDespesBrw:nAt,2] == "1" ,'nValor','nPeso')
            cCmd +=  "*"
            cCmd +=  cValToChar(aRegras[oDespesBrw:nAt,4]) + "),"
            cCmd +=  cValToChar(aRegras[oDespesBrw:nAt,5])
            cCmd +=  ")"
        elseif aRegras[oDespesBrw:nAt,3] == "4"
            cCmd += "("
            cCmd += "Ceiling("
            cCmd +=  if(aRegras[oDespesBrw:nAt,2] == "1" ,'nValor','nPeso')
            cCmd += "/100) * "
            cCmd += cValToChar(aRegras[oDespesBrw:nAt,4])
            cCmd += ")"
        elseif aRegras[oDespesBrw:nAt,3] == "5"
            cCmd += "Max(((("
            cCmd +=  if(aRegras[oDespesBrw:nAt,2] == "1" ,'nValor','nPeso')
            cCmd += " * "
            cCmd += cValToChar(aRegras[oDespesBrw:nAt,4])
            cCmd += ")"
            cCmd += " * "
            cCmd += cValToChar(aRegras[oDespesBrw:nAt,6])
            cCmd += ")/100),"
            cCmd += cValToChar(aRegras[oDespesBrw:nAt,5])
            cCmd += ")"
        elseif aRegras[oDespesBrw:nAt,3] == "7"
             aRegras[oDespesBrw:nAt,2] := "2"
             if aRegras[oDespesBrw:nAt,6] > 0
                cCmd += "("
                cCmd += " if(nPeso > "
                cCmd +=  cValToChar(aRegras[oDespesBrw:nAt,4])
                cCmd += ", "
                cCmd +=  cValToChar(aRegras[oDespesBrw:nAt,4])
                cCmd += ", "
                cCmd += " nPeso "
                cCmd += ")"
                cCmd +=  " * " 
                cCmd +=  cValToChar(aRegras[oDespesBrw:nAt,6])
                cCmd += ")"
             else
                lRet := .F.
                MsgInfo('Valor Auxiliar obrigatorio','Erro')
             endif
             
        elseif aRegras[oDespesBrw:nAt,3] == "8"
            aRegras[oDespesBrw:nAt,2] := "2"
             if aRegras[oDespesBrw:nAt,6] > 0
                cCmd += "("
                cCmd += " if(nPeso > "
                cCmd +=  cValToChar(aRegras[oDespesBrw:nAt,4])
                cCmd += ", "
                cCmd +=  "nPeso - " + cValToChar(aRegras[oDespesBrw:nAt,4])
                cCmd += ", "
                cCmd += " 0 "
                cCmd += ")"
                cCmd +=  " * " 
                cCmd +=  cValToChar(aRegras[oDespesBrw:nAt,6])
                cCmd += ")"
             else
                lRet := .F.
                MsgInfo('Valor Auxiliar obrigatorio','Erro')
             endif
        
        elseif aRegras[oDespesBrw:nAt,3] == "9"     
                cCmd += "Max(("
                cCmd +=  if(aRegras[oDespesBrw:nAt,2] == "1" ,'nValor','nPeso')
                cCmd +=  " * " 
                cCmd += cValToChar(aRegras[oDespesBrw:nAt,4])
                cCmd +=  ") ,"
                cCmd += cValToChar(aRegras[oDespesBrw:nAt,5])
                cCmd +=  ")"
        endif
    END SEQUENCE
    ErrorBlock(bErro)

    if(lRet)
        aRegras[oDespesBrw:nAt,7] := cCmd
        bErro  := ErrorBlock({|oErr| handlerr(oErr, @lRet)})
        BEGIN SEQUENCE
            nValor  := 500.00
            nPeso   := 2500.00
            &(cCmd)
        END SEQUENCE
        ErrorBlock(bErro)
   endif
  if lScren
    oDespesBrw:LineRefresh(oDespesBrw:nAt-1)
  endif
  lAllOk := lRet
return lRet

static function posIncLine()
    aRegras[oDespesBrw:at(), oDespesBrw:GetColByID("xCOMPONENTE"):nOrder]   := space(20)
    aRegras[oDespesBrw:at(), oDespesBrw:GetColByID("xCALCULO"):nOrder]      := space(1)
    aRegras[oDespesBrw:at(), oDespesBrw:GetColByID("xTPCALCULO"):nOrder]    := space(1)
    aRegras[oDespesBrw:at(), oDespesBrw:GetColByID("xEXPRESSAO"):nOrder]    := space(tamSx3("C5_OBS")[1])
    aRegras[oDespesBrw:at(), oDespesBrw:GetColByID("xVALOR"):nOrder]        := 0
    aRegras[oDespesBrw:at(), oDespesBrw:GetColByID("xMINVALOR"):nOrder]     := 0
    aRegras[oDespesBrw:at(), oDespesBrw:GetColByID("xAUXVALOR"):nOrder]     := 0
    aRegras[oDespesBrw:at(), oDespesBrw:GetColByID("xCONDICAO"):nOrder]     := Padr(".T.",tamSx3("C5_OBS")[1])
    oDespesBrw:LineRefresh(oDespesBrw:nAt)
return nil


static function handlerr(oErr, lRet)
    MsgInfo(oErr:Description, 'Erro')
    aRegras[oDespesBrw:nAt,7] := ''
    lRet := .F.
    BREAK
return 


static function handlval(oErr, lRet)
    default lRet := .F.
    MsgInfo(oErr:Description, 'Erro')
    lRet := .F.
    BREAK
return 


static function handlDif(oErr, oJsRet)
    oJsRet['STS']       := .F.
    oJsRet['MSG']       := oErr:Description
    oJsRet['EDISIT']    := '3' // Rejeitado
    BREAK
return

static function XmlValid(oTEMP,aNode,cTag,lREALNAME, lRetObj)
    local lContinua := .T.
    local cReturn   := ""
    local nCont     := 0
    local nFCont    := 0
    local oXML      := oTEMP
    default lREALNAME   := .F.
    default lRetObj     := .F.
	nFCont := len(aNode)
	for nCont := 1 to nFCont
		if ValType( XmlChildEx(oXML,aNode[nCont])) == 'O'
			oXML := XmlChildEx(oXML, aNode[nCont])
		else
            lContinua := .F.
		endif
		if lContinua
			if nCont == nFCont
				if !lREALNAME
					if &("ValType(oXML:"+cTag+")") == "A"
                        cReturn := &("oXML:"+cTag)
                    elseIf &("ValType(oXML:"+cTag+")") == "O"
                        if lRetObj
                            cReturn := &("oXML:"+cTag)
                        else
                            cReturn := &("oXML:"+cTag+':TEXT')
                        endif
                    endif
				else
					cReturn := &("oXML:REALNAME")
				endif
			endif
		else
			Exit
		endif
	next nCont
return cReturn


/* QUERYES */
static function cteFromNfe(cChvNf, cChvCte)
    local cQry as char
    cQry := " SELECT "
	cQry += " GXG.GXG_CTE   AS CHV_CTE  "
    cQry += " FROM " + RetSqlName('GXG') + " GXG  "
    cQry += " INNER JOIN " + RetSqlName('GXH') + " GXH "
    cQry += " ON GXG.GXG_FILIAL  = GXH.GXH_FILIAL "
    cQry += " AND GXG.GXG_NRIMP  = GXH.GXH_NRIMP "
    cQry += " AND GXH.D_E_L_E_T_ = GXH.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SF2') + " SF2 WITH(NOLOCK)"
    cQry += " ON SF2.F2_CHVNFE   = GXH.GXH_DANFE "
    cQry += " AND SF2.D_E_L_E_T_ = GXH.D_E_L_E_T_ "
    cQry += " WHERE  "
    cQry += " GXG.GXG_CTE != '"+ Alltrim(cChvCte) + "' "
    cQry += " AND SF2.F2_CHVNFE = '" + cChvNf + "' "
    cQry += " AND GXG.D_E_L_E_T_ = '' "
return cQry

static function memCalc(cChvNf)
    local cQry as char
    cQry := " SELECT "
	cQry += " ISNULL(ZZ9.R_E_C_N_O_,0) AS RECZ9, "
	cQry += " SF2.R_E_C_N_O_ AS RECSF2 "
    cQry += " FROM "+ RetSqlName('SF2') + " SF2 with(nolock) "
    cQry += " LEFT JOIN " + RetSqlName('ZZ9') + " ZZ9 with(nolock) " 
    cQry += " ON SF2.F2_FILIAL   = ZZ9.ZZ9_FILIAL "
    cQry += " AND SF2.F2_DOC     = ZZ9.ZZ9_DOC "
    cQry += " AND SF2.F2_SERIE   = ZZ9.ZZ9_SERIE "
    cQry += " AND SF2.D_E_L_E_T_ = ZZ9.D_E_L_E_T_ "
    cQry += " WHERE  "
    cQry += " SF2.F2_CHVNFE = '"+cChvNf+ "' "
    cQry += " AND SF2.D_E_L_E_T_ = '' "
return cQry


static function transRoute(cUfDest, cIbge)
    local cQry as char
    cQry := " SELECT "
    cQry += " ZF1.R_E_C_N_O_ AS REC, "
    cQry += " SA4.A4_NOME    AS TRANSP, "
    cQry += " SA4.A4_CGC     AS CNPJ_TRANSP  "
    cQry += " FROM "+ RetSqlName('ZF1') +" ZF1 WITH(NOLOCK) "
    cQry += " INNER JOIN "+ RetSqlName('SA4') +" SA4 WITH(NOLOCK)   "
    cQry += " ON  '" + xFilial('SA4') + "' = SA4.A4_FILIAL "
    cQry += " AND ZF1.ZF1_TRANSP = SA4.A4_COD  "
    cQry += " AND ZF1.D_E_L_E_T_ = SA4.D_E_L_E_T_  "
    cQry += " INNER JOIN "+ RetSqlName('GU9') +" GU9 WITH(NOLOCK) "
    cQry += " ON '" + xFilial('GU9') + "' = GU9.GU9_FILIAL  "
    cQry += " AND ZF1.ZF1_NRREG  = GU9.GU9_NRREG "
    cQry += " AND ZF1.D_E_L_E_T_ = GU9.D_E_L_E_T_ "
    cQry += " INNER JOIN "+ RetSqlName('GUA') +" GUA  WITH(NOLOCK) "
    cQry += " ON GU9.GU9_FILIAL  = GUA.GUA_FILIAL "
    cQry += " AND GU9.GU9_NRREG  = GUA.GUA_NRREG "
    cQry += " AND GU9.D_E_L_E_T_ = GUA.D_E_L_E_T_ "
    cQry += " INNER JOIN "+ RetSqlName('GU7') +" GU7 WITH(NOLOCK) "
    cQry += " ON GUA.GUA_FILIAL  = GU7.GU7_FILIAL "
    cQry += " AND GUA.GUA_NRCID  = GU7.GU7_NRCID "
    cQry += " AND GUA.D_E_L_E_T_ = GU7.D_E_L_E_T_ "
    cQry += " WHERE "
    cQry += " ZF1.ZF1_FILIAL    = '" + xFilial('ZF1') + "' "
    cQry += " AND GU9.GU9_CDUF  = '" + Alltrim(cUfDest) + "' "
    cQry += " AND GU7.GU7_NRCID = '" + Alltrim(cIbge) + "' "
    cQry += " AND SA4.A4_MSBLQL <> 1 "
    cQry += " AND ZF1.D_E_L_E_T_ = '' "
return cQry


static function gtAliq(cOrigem, cDest)
    local cQry as char
    cQry := " SELECT "
	cQry += " GUT.GUT_UF	AS ORIGEM, "
	cQry += " GUT.GUT_PCEC   AS ALIQ_ORIGEM, "
	cQry += " GUR.GUR_UFDEST AS DESTINO, "
	cQry += " GUR.GUR_PCICMS AS ALIQ_INTER "
    cQry += " FROM "+ RetSqlName("GUT") + " GUT  "
    cQry += " INNER JOIN "+ RetSqlName("GUR") + " GUR  "
    cQry += " ON GUT.GUT_FILIAL	  = GUR.GUR_FILIAL "
    cQry += " AND GUT.GUT_UF	  = GUR.GUR_UF   "
    cQry += " AND GUT.D_E_L_E_T_  = GUR.D_E_L_E_T_ "
    cQry += " WHERE  "
    cQry += " GUR.GUR_FILIAL ='" + XFilial('GUT') + "' "
    cQry += " AND GUR.GUR_TPTRIB = 1 "
    cQry += " AND GUT.GUT_UF = '" + cOrigem + "' "
    cQry += " AND GUR.GUR_UFDEST = '"+ cDest + "' "
    cQry += " AND GUT.D_E_L_E_T_ = '' "
    cQry += " ORDER BY GUT.GUT_UF,GUR.GUR_UFDEST "
return cQry


user function cbcSimuFrete()
    local oFrete as object
    oFrete := cbcAuditFrete():newcbcAuditFrete()
    oFrete:simulFrete()
    FreeObj(oFrete)
return nil


/*TEST ZONE*/
user function zxAuditFrete()
    local oFrete := cbcAuditFrete():newcbcAuditFrete()

    // Json persistido no banco com as regras
    oJson := JsonObject():New()
    oJson['FRETE_PESO']   := {'FRETE_PESO','2','3',0.35722, 0.00, 0.00, '(nPeso * 0.35722)', ".T."}
    oJson['FRETE_VALOR']  := {'FRETE_VALOR','1','2',0.25,7.29, 0.00, 'Max(((nValor*0.25)/100), 7.29)', ".T."}
    oJson['GRIS']         := {'GRIS','1','2',0.23,7.29,0.00, 'Max(((nValor*0.23)/100), 7.29)', ".T."}
    oJson['TAS']          := {'TAS','1','1',4.14, 0.00, 0.00, '4.14', ".T."}
    oJson['PEDAGIO']      := {'PEDAGIO','2','4',5.23,0.00, 0.00, '(Ceiling(nPeso/100)* 5.23)', ".T."}
    oJson['TDE']          := {'TDE','2','5',0.35722,136.02, 30, 'Max((((nPeso * 0.35722)*30)/100), 136.02)',".T."}
    
    // Exibir tela de edição do JSON
    oFrete:showJsCrud(@oJson)
    
    // Realiza os calculos
    oFrete:doCalc(402.00, 20480.89, @oJson, 'MT', 'ES')
    
    // Editar um json vazio
    oJsVazio := JsonObject():New()
    oFrete:showJsCrud(@oJsVazio)

    // Realiza os calculos depois alteração
    oFrete:doCalc(1276.00, 65401.03, @oJsVazio, 'SP', 'PR')

    // Realiza simulação avulsa de frete
    oFrete:simulFrete()
    // Realizar a leitura XML seja string ou Objeto oCte
    oFrete:readXMl(GeraXML(), .T.)
    // Validar o Calculo
    oFrete:validCalc(GeraXML())


    FreeObj(oFrete)
    FreeObj(oJson)
return nil


static function GeraXML()
   local cXml := '<cteProc versao="3.00" xmlns="http://www.portalfiscal.inf.br/cte">'
   cXml += '<CTe xmlns="http://www.portalfiscal.inf.br/cte"><infCte versao="3.00" Id="CTe35201120900554000152570010000100221000100224"><ide><cUF>35</cUF><cCT>00010022</cCT><CFOP>6932</CFOP><natOp>PRESTACAO DE SERVICO DE TRANSPORTE INICIADA UF DIFERENTE</natOp><mod>57</mod><serie>1</serie><nCT>10022</nCT><dhEmi>2020-11-30T11:20:12-02:00</dhEmi><tpImp>1'
   cXml += '</tpImp><tpEmis>1</tpEmis><cDV>4</cDV><tpAmb>1</tpAmb><tpCTe>0</tpCTe><procEmi>0</procEmi><verProc>1.0</verProc><cMunEnv>3523909</cMunEnv><xMunEnv>ITU</xMunEnv><UFEnv>SP</UFEnv><modal>01</modal><tpServ>0</tpServ><cMunIni>5008305</cMunIni><xMunIni>TRES LAGOAS</xMunIni><UFIni>MS</UFIni><cMunFim>3523909</cMunFim><xMunFim>ITU</xMunFim><UFFim>SP'
   cXml += '</UFFim><retira>1</retira><indIEToma>1</indIEToma><toma3><toma>3</toma></toma3></ide><compl><xEmi>FERNANDO</xEmi><Entrega><semData><tpPer>0</tpPer></semData><semHora><tpHor>0</tpHor></semHora></Entrega><origCalc>TRES LAGOAS</origCalc><destCalc>ITU</destCalc><xObs>VALOR DO SEGURO DA MERCADORIA R$ 688,30 | PAGAMENTO DO ICMS FRETE EFETUADO POR RODOMAF ITU TRANSPORTES LTDA ME CNPJ 20.900.554/0001-52 CONFORME ARTS | 258-D E 258-E PARTE GERAL DO RICMS MS E CREDITO FISCAL DE '
   cXml += '20% CONFORME ART 78 4 ANEXO I DO RICMS MS | ;| Motorista: LUIZ RICARDO OLIVEIRA DOS SANTOS . CPF: 332.823.128-57;| Veiculo: EQU-0687 - '
   cXml += 'RNTRC: 48001135 - RENAVAM: 00589530496. Carreta(s): DBM-1770 - RNTRC: 48001135 - RENAVAM: 00165300205</xObs><ObsCont xCampo="Lei da Transparencia"><xTexto>Trib. Aprox: R$ 571,63 Federal, R$ 104,13 Municipal, Fonte: IBPT 5DC0AE</xTexto></ObsCont><ObsCont xCampo="PLACA"><xTexto>DBM1770</xTexto></ObsCont><ObsCont xCampo="CPFMOTORISTA"><xTexto>33282312857</xTexto></ObsCont><ObsCont xCampo="TRANSPPROPRIO"><xTexto>S</xTexto></ObsCont></compl><emit><CNPJ>20900554000152</CNPJ><IE>387147776115</IE><xNome>RODOMAF ITU TRANSPORTES LTDA ME</xNome><xFant>RODOMAF '
   cXml += 'ITU TRANSPORTES LTDA ME</xFant><enderEmit><xLgr>RUA ANTHIGIO CAVECCHINI</xLgr><nro>310</nro><xBairro>PQ RES PRESIDENTE MEDICI</xBairro><cMun>3523909</cMun><xMun>ITU</xMun><CEP>13310140</CEP><UF>SP</UF><fone>1140133848</fone></enderEmit></emit><rem><CNPJ>02544042000208</CNPJ><IE>283453354</IE><xNome>I.F.C.INDUSTRIA E COMERCIO DE CONDUTORES ELETRICOS LTDA.</xNome><xFant>I.F.C.INDUSTRIA E COMERCIO DE CONDUTORES ELETRICOS LTDA.</xFant><enderReme><xLgr>AV 02</xLgr><nro>S/N</nro><xBairro>DISTRITO INDUSTRIAL</xBairro><cMun>5008305</cMun><xMun>TRES LAGOAS</xMun><CEP>79601970</CEP><UF>MS</UF><cPais>1058</cPais><xPais>BRASIL</xPais></enderReme></rem><dest><CNPJ>02544042000119</CNPJ><IE>387086243118</IE><xNome>I.F.C. IND. COM. CONDUTORES ELETRICOS LTDA</xNome><enderDest><xLgr>Avenida Primo Schincariol</xLgr><nro>670</nro><xBairro>JD OLIVEIRA</xBairro><cMun>3523909</cMun><xMun>ITU</xMun><CEP>13312250</CEP><UF>SP</UF><cPais>1058</cPais><xPais>BRASIL</xPais></enderDest></dest><vPrest><vTPrest>4250.00</vTPrest><vRec>4250.00</vRec><Comp><xNome>'
   cXml += 'Frete Valor</xNome><vComp>4250.00</vComp></Comp></vPrest><imp><ICMS><ICMS60><CST>60</CST><vBCSTRet>0.00</vBCSTRet><vICMSSTRet>0.00</vICMSSTRet><pICMSSTRet>0.00</pICMSSTRet></ICMS60></ICMS><vTotTrib>675.76</vTotTrib></imp><infCTeNorm><infCarga><vCarga>1256835.86</vCarga><proPred>VERGALHAO</proPred><xOutCat>VERG/PAL</xOutCat><infQ><cUnid>01</cUnid><tpMed>Peso Bruto</tpMed><qCarga>28895.0000</qCarga></infQ><infQ><cUnid>01</cUnid><tpMed>Peso Aferido</tpMed><qCarga>28602.0000</qCarga></infQ><infQ><cUnid>03</cUnid><tpMed>Qtde</tpMed><qCarga>7.0000</qCarga></infQ><vCargaAverb>1256835.86</vCargaAverb></infCarga><infDoc><infNFe><chave>50201102544042000208550010000794171100068470</chave></infNFe><infNFe><chave>50201102544042000208550010000794181100205777</chave></infNFe></infDoc><infModal versaoModal="3.00"><rodo><RNTRC>48001135</RNTRC></rodo></infModal></infCTeNorm></infCte><infCTeSupl><qrCodCTe><![CDATA[https://nfe.fazenda.sp.gov.br/CTeConsulta/qrCode?chCTe=35201120900554000152570010000100221000100224&tpAmb=1]]></qrCodCTe></infCTeSupl><Signature xmlns="http://www.w3.org/2000/09/xmldsig#"><SignedInfo><CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" /><SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1" /><Reference URI="#CTe35201120900554000152570010000100221000100224"><Transforms><Transform Algorithm='
   cXml += '"http://www.w3.org/2000/09/xmldsig#enveloped-signature" /><Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" /></Transforms><DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1" /><DigestValue>o7nPrx5nMXvHahBKyWAXw5PlIQ4=</DigestValue></Reference></SignedInfo><SignatureValue>Rbk3odZfB2RYccQmiK0/srPbmNQ8/GwfLbGNqD0MpdSL2DW0WgjEU9kg597ycFt86pKLdhEgMkXOg9U3sZvMP6HIzKSsdew+wa8eiQgpJaLeNPxkTxHlm9jNkMBlSJuT5tdDZRYDAaEC0ZSHuLgH7Vxj+CDjKyFcKEbwRfh4cP1zIYFPqM9ASfNqSW8Z+JxJuFuMpgSNojXRlb8LtUL2wB/cgTFD6/sA84MLyV/e/7i0hgvSB365Zjw5ZGRY/YhRZknrC0iUYFpGkLDTSkTuqrcKT23HRq0NEJL/fDLVkxwxrJ4qXwQY2lSzzWvk0wxjGsoINeQH7TztbxEkstHrRQ==</SignatureValue><KeyInfo><X509Data><X509Certificate>MIIH/zCCBeegAwIBAgIQCnn4Ey5bJyz+H3OjVR4t2TANBgkqhkiG9w0BAQsFADB1MQswCQYDVQQGEwJCUjETMBEGA1UEChMKSUNQLUJyYXNpbDE2MDQGA1UECxMtU2VjcmV0YXJpYSBkYSBSZWNlaXRhIEZlZGVyYWwgZG8gQnJhc2lsIC0gUkZCMRkwFwYDVQQDExBBQyBTSU5DT1IgUkZCIEc1MB4XDTIwMDkxMTE0MjE0MFoXDTIxMDkxMTE0MjE0MFowgfExCzAJBgNVBAYTAkJSMRMwEQYDVQQKDApJQ1AtQnJhc2lsMQswCQYDVQQIDAJTUDEMMAoGA1UEBwwDSXR1MRMwEQYDVQQLDApQcmVzZW5jaWFsMRcwFQYDVQQLDA4xMDIzNDc1MjAwMDE3MDE2MDQGA1UECwwtU2VjcmV0YXJpYSBkYSBSZWNlaXRhIEZlZGVyYWwgZG8gQnJhc2lsIC0gUkZCMRYwFAYDVQQLDA1SRkIgZS1DTlBKIEExMTQwMgYDVQQDDCtST0RPTUFGIElUVS'
   cXml += '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</X509Certificate></X509Data></KeyInfo></Signature></CTe><protCTe versao="3.00">'
   cXml += '<infProt><tpAmb>1</tpAmb><verAplic>SP-CTe-2020-07-30-1</verAplic><chCTe>35201120900554000152570010000100221000100224</chCTe><dhRecbto>2020-11-30T11:28:43-03:00</dhRecbto><nProt>135202937470356</nProt><digVal>o7nPrx5nMXvHahBKyWAXw5PlIQ4=</digVal><cStat>100</cStat><xMotivo>Autorizado o uso do CT-e</xMotivo></infProt></protCTe></cteProc>'
return cXml
