#include 'protheus.ch'
/* Usado em conjunto com o servidor disponivel cbcNFE (gitlab)*/
user function cbcDanfor(cChave)
    local oRestClient   := nil 
    local oJson         := nil
    local cUf           := "sp"
    default cChave      := ""
    
    if empty(cChave)
        cChave := alltrim(FWInputBox("Informe Chave:",''))
    endif
    if !empty(cChave)
        cCnpj   := FWArrFilAtu()[18] 
        cUrlXml := GetNewPar('ZZ_XMLNFE', 'http://192.168.1.16:5070')
        oRestClient := FWRest():New(cUrlXml)  
        oRestClient:setPath("/cnpj/"+cCnpj+"/xml/"+cChave+"/uf/"+cUf)
        if oRestClient:Get() 
            oJson := JsonObject():New()
            oJson:FromJSON(oRestClient:GetResult())
            if oJson['sts']
                if oJson['msg'] =="XML-Resumido"
                    alert('XML-Resumido')
                    if MsgNoYes ('Deseja manifestar ciencia?', 'Manifestar XML' ) 
                        // TODO arrumar rota para manifestar (python api)
                        oRestClient:setPath("/cnpj/"+cCnpj+"/xml/"+cChave+"/uf/"+cUf+"/op/2/jus/")
                         if oRestClient:Get()
                            MsgInfo(oRestClient:GetResult(),'Retorno')
                         endif
                    endif
                else
                show(oJson['danfe'], oJson['xml'])
                endif
            else
                alert(oJson['msg'])
            endif
        else
            conout(oRestClient:GetLastError())
        endif
        FreeObj(oJson)
        FreeObj(oRestClient)
    endif
return nil


static function show(cChave, cXml)
     local cUrl     := ''
     local aButtons := {}
     if !empty(cChave)
        cUrlXml := GetNewPar('ZZ_XMLNFE', 'http://192.168.1.16:5070')
        cUrl := cUrlXml + "/danfe/" + cChave
        aadd(aButtons, {,'Imprimir',{||oWebEngine:PrintPDF()}, 'imprimir',,.T.,.F.})
        aadd(aButtons, {,'XML-View',{||shwXml(cChave,cXml)}, 'xml',,.T.,.F.})
        aadd(aButtons, {,'TIPI-IPI',{||u_zCbcTipiIob(,'Danfe', .F.,.T.)}, 'tipi',,.T.,.F.})
        oModal  := FWDialogModal():New()
        oModal:SetEscClose(.T.)
        oModal:setTitle("Visualização de Danfe")
        oModal:setSubTitle("CHAVE:" + cChave )
        oModal:setSize(340, 460)
        oModal:createDialog()
        oModal:addCloseButton(nil, "Fechar")
        oModal:addButtons(aButtons)
        oWebEngine := TWebEngine():New(oModal:getPanelMain(), 0, 0, 100, 100)
        oWebEngine:navigate(cUrl)
        oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT        
        oModal:Activate()
        FreeObj(oModal)
        FreeObj(oWebEngine)
    endif
return nil


static function shwXml(cChave,cContent)
    Local cTempPath := GetTempPath(.T.)
    Local cFile := cTempPath + cChave +'.xml'
    oDlg := TDialog():New(150,300,600,900,'',,,,,,,,,.T.)
    ofileXML := FCREATE(cFile)
    if ofileXML>0
        FWrite(ofileXML, cContent)
        FClose(ofileXML)
    endIf
    oXml := TXMLViewer():New(10, 10, oDlg , cFile, 280, 200, .T. )
    if oXml:setXML(cFile)
    alert("Arquivo não encontrado")
    endIf
    oDlg:Activate()
return nil
