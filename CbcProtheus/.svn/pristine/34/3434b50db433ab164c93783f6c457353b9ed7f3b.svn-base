#include 'Protheus.ch'

/* CONSULTA NCM/TIPI IOB */
user function zCbcTipiIob(cNCM, cProduto, lInput, lFree)
    local cUrl          := "https://www.iob.com.br/tipi_ior/par_tipi.asp?txt_ncm="
    private oWebEngine  := nil 
    private oModal      := nil
    default cNCM        := SB1->(B1_POSIPI)
    default cProduto    := Alltrim(SB1->(B1_DESC))
    default lInput      := .F.
    default lFree       := .F.
    
    if lInput
        cNCM        := alltrim(StrTran(FWInputBox("Informe NCM:",FWFldGet("B1_POSIPI")),'.',''))
        cProduto    := ""
    elseif lFree
        cNCM        := alltrim(StrTran(FWInputBox("Informe NCM:",''),'.',''))
    endif
    
    if !empty(cNCM)
        oModal  := FWDialogModal():New()
        oModal:SetEscClose(.T.)
        oModal:setTitle("Consulta TIPI - IOB")
        oModal:setSubTitle("NCM:" + cNCM + " - DESC.SISTEMA" + cProduto)
        oModal:setSize(240, 400)
        oModal:createDialog()
        oModal:addCloseButton(nil, "Fechar")
        oWebEngine := TWebEngine():New(oModal:getPanelMain(), 0, 0, 100, 100)
        oWebEngine:navigate(cUrl += cNCM)
        oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
        oModal:Activate()
        FreeObj(oModal)
        FreeObj(oWebEngine)
    endif
return nil
