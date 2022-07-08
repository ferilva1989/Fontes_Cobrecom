#include 'protheus.ch'
#include 'parmtype.ch'
#Include 'Totvs.ch'
#include 'FWMVCDef.ch'
#include "rwmake.ch"

User Function cbcViewFrete()
    Processa( { || tela() }, 'Filtrando...', 'Aguarde...')
Return Nil

Static Function tela()
    Local oBrowse  := Nil
    Local oColumn  := Nil

    DbSelectArea("ZF1")
    DbSetOrder(1)
    
    oBrowse := FWMBrowse():New()
    oBrowse:SetDataTable(.T.)
    oBrowse:SetAlias("ZF1")
    oBrowse:SetFilterDefault( "@R_E_C_N_O_ IN ("  + Filter() +")")
    oBrowse:SetDescription('Calculo de Fretes') 
    
    oBrowse:AddLegend('ZF1->ZF1_DTFIM < ddatabase',"RED","Tabela Vencida")
    oBrowse:AddLegend('ZF1->ZF1_DTFIM >= ddatabase',"GREEN","Tabela em Vigencia")
    oBrowse:SetMenuDef("viewFrete")
    oBrowse:SetSeek(.T.,busca())
    oBrowse:SetProfileID('BFRE')
    oBrowse:SetTypeMove(0)

    oColumn := FWBrwColumn():New()
    oColumn:SetData({||ZF1_FILIAL})
    oColumn:SetTitle("Filial")
    oColumn:SetSize(10)
    oBrowse:SetColumns({oColumn})
    
    oColumn := FWBrwColumn():New()
    oColumn:SetData({||ZF1_TRANSP})
    oColumn:SetTitle("Transportadora")
    oColumn:SetSize(10)
    oBrowse:SetColumns({oColumn})

    oColumn := FWBrwColumn():New()
    oColumn:SetData({||POSICIONE("SA4", 1, xFilial("SA4")+ZF1->ZF1_TRANSP, "A4_NOME")})
    oColumn:SetTitle("Nome Transp.")
    oColumn:SetSize(10)
    oBrowse:SetColumns({oColumn})
    
    oColumn := FWBrwColumn():New()
    oColumn:SetData({||ZF1_DTINC})
    oColumn:SetTitle("Inicio Vigencia")
    oColumn:SetSize(1)
    oBrowse:SetColumns({oColumn})

    oColumn := FWBrwColumn():New()
    oColumn:SetData({||ZF1_DTFIM})
    oColumn:SetTitle("Fim Vigencia")
    oColumn:SetSize(1)
    oBrowse:SetColumns({oColumn})
    
    oBrowse:Activate()
Return oBrowse

Static Function ViewDef()
Return FWLoadView( 'cbcMVCZF1' )

Static Function MenuDef()
    Local aRotina := {}
    ADD OPTION aRotina TITLE 'Incluir' ACTION 'VIEWDEF.cbcMVCZF1' OPERATION MODEL_OPERATION_INSERT ACCESS 0
    ADD OPTION aRotina TITLE 'Editar' ACTION 'VIEWDEF.cbcMVCZF1' OPERATION MODEL_OPERATION_UPDATE ACCESS 0
    ADD OPTION aRotina TITLE 'Excluir Tudo' ACTION 'StaticCall(viewFrete, delAllRoute)' OPERATION MODEL_OPERATION_DELETE ACCESS 0
Return aRotina

Static Function busca()
    Local aSeek := {}
    Aadd(aSeek, { "Filial+Transportadora", {{"","C", TamSx3("ZF1_FILIAL")[1], TamSx3("ZF1_FILIAL")[1], 1, "ZF1_FILIAL"},;
        {"","C", TamSx3("ZF1_TRANSP")[1], TamSx3("ZF1_TRANSP")[1] , 2, "ZF1_TRANSP"}} } )
Return aSeek

Static Function Filter()
    Local cQry  := ''

    cQry += " SELECT MAX(R_E_C_N_O_) AS R_E_C_N_O_ "
    cQry += " FROM " + RetSQLName("ZF1")
    cQry += " WHERE D_E_L_E_T_ = '' "
    cQry += " GROUP BY ZF1_FILIAL, ZF1_TRANSP "
Return cQry


Static Function delAllRoute()
    Local oCbcCtrl  := ctrlFrete():newctrlFrete()
    Local aDados    := {}

    aAdd(aDados, { ZF1->ZF1_FILIAL, 'ZF1_FILIAL' })
    aAdd(aDados, { ZF1->ZF1_TRANSP, 'ZF1_TRANSP' })
    aAdd(aDados, { ZF1->ZF1_NRREG, 'ZF1_NRREG' })
    aAdd(aDados, { ZF1->ZF1_ROTA, 'ZF1_ROTA' })
    oCbcCtrl:delete(aDados, .T.)
Return Nil
