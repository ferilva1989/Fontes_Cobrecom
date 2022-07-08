#Include "Protheus.ch"
#Include 'FWMVCDef.ch'
#define CIDADE      1
#define UF	        2
#define ENDERECO	3
#define CEP	        4
#define COMPLEMENTO	5
  
class cbcMshCadastro
    method newcbcMshCadastro()
    method showScreen()
endClass

method newcbcMshCadastro() class cbcMshCadastro
return(self)


method showScreen() class cbcMshCadastro
    local aCoors 		    := FWGetDialogSize(oMainWnd)
    private oFWLayer        := nil
    private oMsmOri         := nil
    private oPanelClientes  := nil
    private oWebCDFE        := nil
    private oPanelBrw       := nil
    private oWebCSimp       := nil
    private oWebCMap        := nil
    private oWebFluig       := nil
    private oWebRecei       := nil
    private oBrowse         := nil
    private oDlgPrinc       := nil
    private aArrWeb         := {}
    private aObrig          := {}
    private Inclui		    := .T.
    private Altera		    := .F.
    private Exclui		    := .F.  
    private nOpcao          := 3
    private cCadastro       := 'Inclusão de Clientes'	
    private cCNPJ           := Space(44)
    private cProcFun        := ProcName(1)
    private lTemCod         := .F.

    DbSelectArea('SA1')
    SA1->(DbSetOrder(1))
    toMemory()
    define MsDialog oDlgPrinc Title 'Cadastro de Cliente' From aCoors[1], aCoors[2] To aCoors[3], aCoors[4] OF oMainWnd Pixel STYLE DS_MODALFRAME
 
    oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlgPrinc, .F., .T. )

    oFWLayer:AddCollumn('ESQUERDA', 35, .F.)
	oFWLayer:SetColSplit('ESQUERDA', CONTROL_ALIGN_LEFT)
    oFWLayer:AddWindow('ESQUERDA', 'CLIENTE',  'Clientes', 20, .T., .F.)
	oFWLayer:AddWindow('ESQUERDA', 'RECEITA',  'Receita Federal', 20, .T., .F.)
    oFWLayer:AddWindow('ESQUERDA', 'DFE',       'Dfe', 20, .T., .F.)
    oFWLayer:AddWindow('ESQUERDA', 'SIMPLES',  'Simples', 20, .T., .F.)
    oFWLayer:AddWindow('ESQUERDA', 'MAP',  'Mapa', 20, .T., .F.)
	
    oFWLayer:AddCollumn('DIREITA', 65, .F.)
    oFWLayer:SetColSplit('DIREITA', CONTROL_ALIGN_RIGHT)
    oFWLayer:AddWindow('DIREITA', 'MENU',       'CNPJ', 15, .T., .F.)
    oFWLayer:AddWindow('DIREITA', 'CLIENTES',   'Clientes Inclusão', 50, .T., .F.)
    oFWLayer:AddWindow('DIREITA', 'FLUIG',      'Fluig', 35, .T., .F.)

    oWebRecei := doWork((oPanelReceita  := oFWLayer:GetWinPanel('ESQUERDA', 'RECEITA')) , getUrlSrv('RECEITA') )
    oWebCDFE  := doWork((oPanelDFE      := oFWLayer:GetWinPanel('ESQUERDA', 'DFE')),      getUrlSrv('DFE'))
    oWebCSimp := doWork((oPanelSimples  := oFWLayer:GetWinPanel('ESQUERDA', 'SIMPLES')),  getUrlSrv('SIMPLES'))
    oWebCMap  := doWork((oPanelSimples  := oFWLayer:GetWinPanel('ESQUERDA', 'MAP')), '')
    oWebFluig := doWork((oPanelFluig    := oFWLayer:GetWinPanel('DIREITA', 'FLUIG'))    , getUrlSrv('FLUIG') )
    aArrWeb := {oWebRecei, oWebCDFE, oWebCSimp, oWebCMap, oWebFluig}
    U_LbMsgRun({|oSay| doBrowser((oPanelBrw   := oFWLayer:GetWinPanel('ESQUERDA', 'CLIENTE')))} ,'Iniciando', "Cadastro de Clientes!", 2, 0 )
    doMenu(oPanelMenu      := oFWLayer:GetWinPanel('DIREITA', 'MENU'))
    oPanelClientes := oFWLayer:GetWinPanel('DIREITA', 'CLIENTES')
    iniCad()

    oFWLayer:winChgState ('ESQUERDA','RECEITA')
    oFWLayer:winChgState ('ESQUERDA','DFE')
    oFWLayer:winChgState ('ESQUERDA','SIMPLES')
    oFWLayer:winChgState ('ESQUERDA','MAP')
    oFWLayer:winChgState ('DIREITA', 'FLUIG')
	// oFWLayer:clickColSplit('ESQUERDA')
	
    ACTIVATE MSDIALOG oDlgPrinc CENTERED
return(self)


static function iniCad(lObrig)
    default lObrig := .T.
    if lObrig
        oMsmOri := MsmGet():New('SA1',0,3,,,,aObrig,{15,5,80,440},aObrig,,,,,oPanelClientes,.F.,.T.,.F.,,.F.,,,,,.T.)
    else
        oMsmOri := MsmGet():New('SA1',0,3,,,,,{15,5,80,440},,,,,,oPanelClientes,.F.,.T.,.F.,,.F.,,,,,.T.)
    endif
    oMsmOri:Hide() 
    oMsmOri:oBox:Align := CONTROL_ALIGN_ALLCLIENT
    oMsmOri:Refresh()
    oMsmOri:Show() 
return


static function addCli()
    if vldCnpj(cCNPJ)
        oMsmOri:Hide()
        toMemory()
        buscaInfo()
        oMsmOri:Refresh()
        oMsmOri:Show()
    endif 
return nil


static function doMenu(oPnl)
    Local oStatic    := IfcXFun():newIfcXFun()
    oGet1 := TGet():New( 005, 019, { | u | If( PCount() == 0, cCNPJ, cCNPJ := u ) },oPnl, ;
    120, 010, "!@",{||.T.}, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCNPJ",,,,.F.  )
    oTButton1 := TButton():New( 000, 140, "Buscar",oPnl,{||U_LbMsgRun({|oSay|oStatic:sP(1):callStatic('cbcMshCadastro', 'addCli')} ,"Buscando Info", "Cadastro de Clientes!", 2, 0 )},   35,20,,,.F.,.T.,.F.,,.F.,,,.F. ) 
    oTButton1 := TButton():New( 000, 180, "Salvar",oPnl,{||oStatic:sP(1):callStatic('cbcMshCadastro', 'salvaCli')}, 35,20,,,.F.,.T.,.F.,,.F.,,,.F. ) 
    oTButton1 := TButton():New( 000, 230, "Abrir" ,oPnl,{||oStatic:sP(1):callStatic('cbcMshCadastro', 'openWeb')}, 35,20,,,.F.,.T.,.F.,,.F.,,,.F. ) 
    oTButton1 := TButton():New( 000, 270, "CEP"   ,oPnl,{||oStatic:sP(1):callStatic('cbcMshCadastro', 'doCep')}, 35,20,,,.F.,.T.,.F.,,.F.,,,.F. ) 
    oTButton1 := TButton():New( 000, 320, "WebF5" ,oPnl,{||oStatic:sP(1):callStatic('cbcMshCadastro', 'webRefresh')}, 35,20,,,.F.,.T.,.F.,,.F.,,,.F. ) 
    oTButton1 := TButton():New( 000, 380, "Fechar",oPnl,{||oStatic:sP(1):callStatic('cbcMshCadastro', 'close')}, 35,20,,,.F.,.T.,.F.,,.F.,,,.F. ) 
return nil


static function doCep()
   local oEls	 := nil
   local cBusca  := ''
   local cBairro := ''
   local aRet    := {}
   local bErro   := nil

   bErro  := ErrorBlock({|oErr| handlerr(oErr)})
   BEGIN SEQUENCE
    if empty(Alltrim( M->(A1_CGC)))
        MsgInfo('Selecione um CNPJ primeiro', 'Aviso')
    else
        if empty(cBusca := Alltrim(FWInputBox("CEP de Cobrança", "")))
            MsgInfo('Nenhum CEP informado', 'Aviso')
        else
            oEls := cbcCepElsSrc():newcbcCepElsSrc(.T.)
            if oEls:onesearch(Alltrim(cBusca))
                if empty(aRet := oEls:aEscolhido)
                    MsgInfo('Nenhum CEP encontrado', 'Aviso')
                else
                    cBairro := StrTran(oEls:aResult[1],aRet[1,ENDERECO],"" )
                    cBairro := StrTran(cBairro,aRet[1,UF],"" )
                    cBairro := StrTran(cBairro,aRet[1,CIDADE],"" )
                    cBairro := StrTran(cBairro,cBusca,"" )
                    cBairro := StrTran(cBairro,"-","" )
                    cBairro := Alltrim(cBairro)
                    M->(A1_ENDCOB)       := chngFld(Alltrim(aRet[1,ENDERECO]),'A1_ENDCOB')
                    M->(A1_COMPLC)       := chngFld(Alltrim(aRet[1,COMPLEMENTO]),'A1_COMPLC')
                    M->(A1_BAIRROC)      := chngFld(Alltrim(cBairro),'A1_BAIRROC')
                    M->(A1_ESTC)         := chngFld(Alltrim(aRet[1,UF]),'A1_ESTC')
                    M->(A1_CODMUNC)      := chngFld(Alltrim(getCodMun(aRet[1,CIDADE],aRet[1,UF])),'A1_CODMUNC')
                    M->(A1_CEPC)         := chngFld(Alltrim(cBusca),'A1_CEPC')
                    runTrg({'A1_CODMUNC'})
                    MsgInfo('Endereço de cobrança preenchido', 'Aviso')
                endif
            endif 
            FreeObj(oEls)
        endif
    endif
   END SEQUENCE
   ErrorBlock(bErro)
return


static function getCodMun(cCid, cEst)
    local oSql    := nil
    local cCodMun := ''
    oSql := LibSqlObj():newLibSqlObj()
    cCodMun := oSql:getFieldValue("CC2", "CC2_CODMUN",;
    "%CC2.XFILIAL%  AND CC2_EST  = '" + Alltrim(cEst) + "' " + " AND CC2_MUN  = '" + Alltrim(Upper(cCid)) + "' ")
    FreeObj(oSql)
return (cCodMun)


static function openWeb()
    local aRet      := {}
    local aParamBox := {}
    local cUrl      := ''
    local aCombo    := {"Sintegra","Simples",'Receita','DFE', 'Fluig'}
    
    aadd(aParamBox,{2,"Informe a Consulta","Sintegra",aCombo,50,"",.T.})
    if ParamBox(aParamBox,"Abrinfo...",@aRet)
        if aRet[1] == "Sintegra"
            if !empty((cUrl:= getSintUtl(M->(A1_EST))) )
               ShellExecute( "open", cUrl, "", "", 1 )
            else
                 ShellExecute( "open", getUrlSrv('SINTEGRA'), "", "", 1 )
            endif
        elseif aRet[1] == "Simples"
            ShellExecute( "open", getUrlSrv('SIMPLES'), "", "", 1 )
        elseif aRet[1] == "Receita"
            ShellExecute( "open", getUrlSrv('RECEITA'), "", "", 1 )
        elseif aRet[1] == "DFE"
         ShellExecute( "open", getUrlSrv('DFE'), "", "", 1 )
        elseif aRet[1] == "Fluig"
             ShellExecute( "open", getUrlSrv('FLUIG'), "", "", 1 )
        endif
    endif
return nil


static function close()
    local nX := 0
    for nX := 1 to len(aArrWeb)
        FreeObj(aArrWeb[nX])
    next nX
    aArrWeb := nil
    oDlgPrinc:End()
return nil


static function webRefresh()
    local nX := 0
    for nX := 1 to len(aArrWeb)
        aArrWeb[nX]:navigate(aArrWeb[nX]:CURL)
        aArrWeb[nX]:Refresh()
    next nX
return nil


static function doBrowser(oPanel)
    private oFont 	:= TFont():New( "Arial", , -12, .T.)
    DbSelectArea("SA1")
    DbSetOrder(1)
    oBrowse := FWMBrowse():New()
    oBrowse:SetOwner(oPanel)
    oBrowse:SetDataTable(.T.)
    oBrowse:SetAlias("SA1")
    oBrowse:SetMenuDef("cbcMshCadastro")
    oBrowse:SetFontBrowse(oFont)
    oBrowse:Activate()
return nil


static function MenuDef()
	local aRotina := {}
	aadd(aRotina, { "Pesquisar" , "StaticCall(cbcMshCadastro, doOpc, 1)", 0, 1 })
    aadd(aRotina, { "Visualizar", "StaticCall(cbcMshCadastro, doOpc, 2)"  , 0, 2 })
    aadd(aRotina, { "Alterar"   , "StaticCall(cbcMshCadastro, doOpc, 4)"  , 0, 4 })
    aadd(aRotina, { "Excluir"   , "StaticCall(cbcMshCadastro, doOpc, 5)" , 0, 5 })
return(aRotina)


static function doOpc(nOpc)
    local bErro         := nil
    Private aRotAuto	:= Nil
     
    bErro  := ErrorBlock({|oErr| handlerr(oErr)})
    BEGIN SEQUENCE
        oMsmOri:Hide()
        if nOpc == 1
            PesqBrw()
        elseif nOpc == 2
            cngPrv({.F.,.F.,.F.,2,'Visualizar Cliente'})
            U_LbMsgRun({|oSay|A030Visual('SA1',SA1->(Recno()),2)} ,cCadastro, "Cadastro de Clientes!", 2, 0 )
        elseif nOpc == 4
            cngPrv({.F.,.T.,.F.,4,'Alterar Cliente'})
            U_LbMsgRun({|oSay|A030Altera('SA1',SA1->(Recno()),4)} ,cCadastro, "Cadastro de Clientes!", 2, 0 )
        elseif nOpc == 5
            cngPrv({.F.,.F.,.T.,5,'Deletar Cliente'})
            U_LbMsgRun({|oSay|A030Deleta('SA1',SA1->(Recno()),5)} ,cCadastro, "Cadastro de Clientes!", 2, 0 )
            oBrowse:Refresh(.T.)
        endif 
        cngPrv({.T.,.F.,.F.,3, 'Inclusão de Clientes'})
    END SEQUENCE
    ErrorBlock(bErro)
return nil


static function cngPrv(aSet)
     Inclui		    := aSet[1]
     Altera		    := aSet[2]
     Exclui		    := aSet[3]  
     nOpcao         := aSet[4]
     cCadastro      := aSet[5]
return


static function toMemory()
    local nX    := 0
    local cFld  := ''
    aObrig := {}
    DbSelectArea('SA1')
    RegToMemory('SA1', .T.,.T.)
    for nX := 1 to SA1->(FCount())
	    cFld := SA1->(FieldName(nX))
        if ( (SA1->(X3Obrigat(cFld)) .Or. isEdit(cFld)) .And.(vldFld(cFld)) )
            aAdd(aObrig, cFld)
        endif
        _SetNamedPrvt( "M->" + cFld, &("M->" + cFld) , cProcFun)
        _SetNamedPrvt( cFld, &("M->" + cFld) , cProcFun)
	next nX
    SA1->(RollBackSx8())
return nil


static function salvaCli()
    local nX                := 0
    local cFld              := ''
    local bErro             := nil
    local aVetor            := {}
    local aErro             := {}
    local cErro             := ''
    local lOk               := .T.
    private lMsErroAuto		:= .F.
	private lMsHelpAuto		:= .T.
	private lAutoErrNoFile	:= .T.

    if MsgNoYes ('Confirma gravação do cliente','Confirmação') 
        DbSelectArea("SA1")
        DbSetOrder(1)
        bErro  := ErrorBlock({|oErr| handlcli(oErr, @lOk, @cErro)})
        BEGIN SEQUENCE
            for nX := 1 to SA1->(FCount())
                cFld := SA1->(FieldName(nX))
                if vldFld(cFld)
                    aAdd(aVetor, {cFld, &("M->" + cFld) , Nil})
                elseif (lTemCod) .And. (cFld == 'A1_COD')
                    aAdd(aVetor, {cFld, &("M->" + cFld) , Nil})
                endif
            next nX
            BEGIN TRANSACTION
                U_LbMsgRun({|oSay|MSExecAuto({|x,y| Mata030(x,y)},aVetor,3)} ,"Salvando cliente", "Cadastro de Clientes!", 2, 0 )
                if lMsErroAuto
                    aErro := GetAutoGrLog()
                    for nX := 1 to len(aErro)
                        cErro += aErro[nX] + chr(13)+chr(10)
                    next nX
                    lOk := .F.
                    DisarmTransaction()
                else
                    SA1->(MsUnlockAll())
                endif
            END TRANSACTION
            if !lOk
                MsgInfo(cErro ,'Erro')
            else
                oBrowse:GoTo(SA1->(Recno()), .T.)
                oMsmOri:Hide()
                toMemory()
                cCNPJ := Space(44) 
                oMsmOri:Refresh()
                webRefresh()
                MsgInfo('Confirmação', 'Cliente: ' + SA1->(A1_COD) + ' Loja:' + SA1->(A1_LOJA) + ' salvo') 
            endif 
        END SEQUENCE
        ErrorBlock(bErro)
    endif
return {lOk , cErro}


static function vldFld(cFld)
    local lOk    := .F.
    local aNoFld := {}
    aadd(aNoFld, 'A1_COD')
    aadd(aNoFld, 'A1_SUBCOD')
    
    lOk := ((AScan(aNoFld, {|x| upper(alltrim(x)) == upper(alltrim(cFld))} )) == 0)
return lOk


static function isEdit(cFld)
    local lOk    := .F.
    local aDoFld := {}
    aadd(aDoFld, 'A1_CGC')
    aadd(aDoFld, 'A1_CNAE')
    aadd(aDoFld, 'A1_DDD')
    aadd(aDoFld, 'A1_MSBLQL')
    aadd(aDoFld, 'A1_PESSOA')
    aadd(aDoFld, 'A1_MENPAD')
    aadd(aDoFld, 'A1_TES')
    aadd(aDoFld, 'A1_CALCSUF')
    aadd(aDoFld, 'A1_SUFRAMA')
    aadd(aDoFld, 'A1_TPJ')
    aadd(aDoFld, 'A1_GRPTRIB')
    aadd(aDoFld, 'A1_ZZPRFAT')
    aadd(aDoFld, 'A1_ENDCOB')
    aadd(aDoFld, 'A1_XREIDI')
    aadd(aDoFld, 'A1_OBSER')
    aadd(aDoFld, 'A1_COMPLC')
    aadd(aDoFld, 'A1_BAIRROC')
    aadd(aDoFld, 'A1_ESTC')
    aadd(aDoFld, 'A1_CODMUNC')
    aadd(aDoFld, 'A1_MUNC')
    aadd(aDoFld, 'A1_CEPC')
    lOk := ((AScan(aDoFld, {|x| upper(alltrim(x)) == upper(alltrim(cFld))} )) > 0)
return lOk


static function buscaInfo()
    local oRestClient := nil
    local oJsret      := nil
    local aHeader     := {}
    local bErro       := nil
    local lRet        := .T.
    
    bErro  := ErrorBlock({|oErr| handlreceita(oErr, @lRet)})
    BEGIN SEQUENCE 
        aadd(aHeader, 'Content-Type: application/json')
        oRestClient := FWRest():New("http://192.168.15.3:5000")
        oRestClient:setPath("/cadinfo/" + Alltrim(cCNPJ) + "/02")
        if oRestClient:Get(aHeader)
            oJsret := JsonObject():new()
            oJsret:fromJson('{"data": ' + oRestClient:GetResult() + '}')
            if empty(oJsret['data'])
                Help(NIL, NIL, "API-Receita", NIL, "Consulta sem retorno da API", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verificar CNPJ, já existente ou empresa inativa"}) 
            else
                lTemCod := CodLjBusca(cCNPJ)
                M->(A1_MSBLQL)      := '2'
                M->(A1_PESSOA)      := 'J'
                M->(A1_CGC)         := chngFld(Alltrim(cCNPJ),'A1_CGC')
                M->(A1_PAIS)        := '105'
                M->(A1_CODPAIS)     := '01058'
                M->(A1_NOME)        := chngFld(Alltrim(oJsret['data'][1]['razao_social']),'A1_NOME')
                M->(A1_NREDUZ)      := chngFld(oJsret['data'][1]['nome_fantasia'], 'A1_NREDUZ')
                M->(A1_END)         := chngFld(Alltrim(oJsret['data'][1]['tipo_logradouro']) + ' ' +;
                                    Alltrim(oJsret['data'][1]['logradouro']) + ' ' +;
                                    Alltrim(oJsret['data'][1]['numero']),'A1_END')
                M->(A1_COMPLEM)     :=  chngFld(Alltrim(oJsret['data'][1]['complemento']),'A1_COMPLEM')
                M->(A1_BAIRRO)      :=  chngFld(Alltrim(oJsret['data'][1]['bairro']),'A1_BAIRRO')
                M->(A1_EST)         :=  Alltrim(oJsret['data'][1]['uf'])
                M->(A1_COD_MUN)     :=  Substr(oJsret['data'][1]['ibge_mun'],3,5)              
                M->(A1_CEP)         :=  Alltrim(oJsret['data'][1]['cep'])               
                M->(A1_EMAILCT)     :=  chngFld(oJsret['data'][1]['email'], 'A1_EMAILCT') 
                M->(A1_EMAIL)       :=  chngFld(oJsret['data'][1]['email'], 'A1_EMAIL') 
                M->(A1_EMAILFI)     :=  chngFld(oJsret['data'][1]['email'], 'A1_EMAILFI') 
                M->(A1_SETOR)       :=  'R'
                M->(A1_CALCSUF)     :=  'N'
                M->(A1_XREIDI)      :=  'N'   
                M->(A1_ZZDIVCL)     :=  'N'  
                M->(A1_DDD)         :=  chngFld(Substr(oJsret['data'][1]['telefone_1'],1,2),'A1_DDD')
                M->(A1_TEL)         :=  chngFld(Substr(oJsret['data'][1]['telefone_1'],4,len(oJsret['data'][1]['telefone_1'])-3),'A1_TEL')
                M->(A1_CNAE)        :=  defCnae(oJsret['data'][1]['atividades_secundarias'],(oJsret['data'][1]['cnae_fiscal'] + '-' + oJsret['data'][1]['cnae_desc']) )
                buscEmp(Alltrim(M->(A1_NREDUZ)))
                buscaVend()
                U_LbMsgRun({|oSay| wsConsCad()} ,'IE', "Buscando IE no estado de " + M->(A1_EST) + "!", 2, 0 )
                runTrg({'A1_COD', 'A1_LOJA', 'A1_CGC','A1_INSCR', 'A1_COD_MUN', 'A1_PAIS', 'A1_CNAE', 'A1_VEND'})
                CopytoClipboard(Alltrim(cCNPJ))
            endif
        endif
        END SEQUENCE
        ErrorBlock(bErro)
        FreeObj(oRestClient)
        FreeObj(oJsret)
return lRet


static function chngFld(cFld, cRef)
return Padr(Alltrim(Alltrim(cFld)),TamSX3(cRef)[1])

static function vldCnpj(cCnp)
    local lRet      := .F.
    local oSql 	    := nil
    local nA1Rec    := 0
    if (lRet := cgc(cCnp,,.T.))
        oSql := LibSqlObj():newLibSqlObj()
        if !empty(nA1Rec := oSql:getFieldValue("SA1", "R_E_C_N_O_",;
                    "%SA1.XFILIAL%  AND A1_CGC  = '" + Alltrim(cCnp) + "' ") )
            SA1->(DbGoTo(nA1Rec))
            oBrowse:GoTo(nA1Rec, .T.)
            if MsgYesNo('Desejar editar o registro?','Cliente já cadastrado ou inativo')
                doOpc(4)
            endif
            lRet := .F.
        else
            lRet := .T.
        endif
        FreeObj(oSql)
    endif
return lRet


static function defCnae(aAsec, cPrincal)
    local nX        := 0
    local cRet      := ''
    local aCombo    := {}
    aadd(aCombo,cPrincal)
    for nX := 1 to len(aAsec)
        aadd(aCombo, aAsec[nX]['cnae'] + '-' + aAsec[nX]['cnae_desc'])
    next nX
     if f_Opcoes(@cRet,"CNAE Principal Cadastro",@aCombo ,,Nil,Nil,.T.,50,50,.F.,.F.,Nil,.F.,.F.,.F.,Nil)
        cRet   := StrToKArr(cRet,'-')[1]
        cRet   := substr(cRet,1,4) + '-' + substr(cRet,5,1) + '/' + substr(cRet,6,2) 
     endif
return cRet


static function buscEmp(cBusca)
    oWebCMap:navigate('https://www.google.com.br/maps/place/'+ Alltrim(cBusca))
return nil


static function runTrg(aFld,aNotDo)
  local nX       := 0
  local cFld     := ''
  default aFld   := {}
  default aNotDo := {}
  DbSelectArea('SA1')
  SA1->(DbSetOrder(1))
  if empty(aFld)
    for nX := 1 to SA1->(FCount())
        cFld := SA1->(FieldName(nX))
        if (AScan( aNotDo, {|x| upper(alltrim(x)) == upper(alltrim(cFld))} )) == 0
            if ExistTrigger(cFld)
                RunTrigger(1,nil,nil,,cFld)
            endif
        endif
    next nX
  else
    for nX := 1 to len(aFld)
        if ExistTrigger(aFld[nX])
            RunTrigger(1,nil,nil,,aFld[nX])
        endif
    next
  endif
return 


static function wsConsCad()
    local oCadCons      := nil
    local cIDEmp        := '000001'
    local cMsg          := ''
    local cIE           := ''
    local bErro         := ErrorBlock({|oErr| handltss(oErr)})
    
    BEGIN SEQUENCE
        oCadCons		    := cbcCadWs():New()
        oCadCons:_URL       := getUrlSrv('TSS')
        oCadCons:cIDEmp     := cIDEmp
        oCadCons:cUf        := M->(Alltrim(A1_EST))
        oCadCons:cCNPJ      := M->(Alltrim(A1_CGC))
        oCadCons:consulta()
        if(AttIsMemberOf(oCadCons, 'oWs'))
            if(ValType(oCadCons:oWs) == 'O')
                if(AttIsMemberOf(oCadCons:oWs, '_IEATUAL'))
                    cIE := oCadCons:oWs:_IEATUAL:TEXT
                elseif (AttIsMemberOf(oCadCons:oWs, '_IE'))
                    cIE := oCadCons:oWs:_IE:TEXT
                endif
                cMsg += 'CNPJ : '             + oCadCons:cCNPJ                        + chr(13)+chr(10)
                cMsg += 'I.E : '              + cIE                                   + chr(13)+chr(10)
                cMsg += 'Estado : '           + oCadCons:cUf                          + chr(13)+chr(10)
                cMsg += 'Situação : '         + oCadCons:oWs:_SITUACAO:TEXT           + chr(13)+chr(10)
                cMsg += 'Regime Apuração : '  + oCadCons:oWs:_REGIMEAPURACAO:TEXT     + chr(13)+chr(10)
                if (oCadCons:oWs:_SITUACAO:TEXT == '1')
                    M->(A1_INSCR) := cIE
                endif
                MsgInfo(cMsg, 'Contribuinte')
            else
                MsgInfo('Consulta contribuinte', 'Sem informação do contribuinte')
            endif
        endif
        FreeObj(oCadCons)
    END SEQUENCE
    ErrorBlock(bErro)
return nil


static function CodLjBusca(cRaiz)
    local oSql := LibSqlObj():newLibSqlObj()
    local cSql := ''
    local lTem := .F.
    cSql += " SELECT " 
	cSql += " LEFT(A1_CGC,8)   AS RAIZ, "
	cSql += " MAX(A1_COD)      AS COD, "
	cSql += " MAX(A1_LOJA)     AS LOJA "
    cSql += " FROM  " + RetSqlName('SA1') + "  "
    cSql += " WHERE LEFT(A1_CGC,8) = '" + Left(cRaiz,8) + "'  "
    cSql += " AND D_E_L_E_T_ = '' "
    cSql += " GROUP BY LEFT(A1_CGC,8) "
    oSql:newAlias(cSql)
	if oSql:hasRecords()
        oSql:GoTop()
        cCodEx := oSql:getValue('COD')
        cPrLj  := Soma1(oSql:getValue('LOJA'))
        MsgInfo('Incrementar Loja para: ' + cPrLj, 'Raiz CNPJ já existente com Cod:' + cCodEx)
        M->(A1_COD)   := cCodEx
        M->(A1_LOJA)  := cPrLj
        lTem          := .T.
    else
        M->(A1_LOJA)  := '01
        lTem          := .F.'
    endif
	oSql:close()
    FreeObj(oSql)
return lTem


static function buscaVend()
    local oSql := LibSqlObj():newLibSqlObj()
    local cSql := ''
    cSql += " SELECT " 
	cSql += " DISTINCT SA3.A3_COD
    cSql += " FROM " + RetSqlName('ZP5') + " ZP5 "
    cSql += " INNER JOIN " + RetSqlName('ZP1') + " ZP1  " 
    cSql += " ON ZP5.ZP5_FILIAL    = ZP1.ZP1_FILIAL "
    cSql += " AND ZP5.ZP5_RESPON   = ZP1.ZP1_CODIGO "
    cSql += " AND ZP5.D_E_L_E_T_   = ZP1.D_E_L_E_T_ "
    cSql += " INNER JOIN " + RetSqlName('SA3') + " SA3 "
    cSql += " ON  SA3.A3_FILIAL    = '' "
    cSql += " AND SA3.A3_COD       = ZP1.ZP1_CODVEN "
    cSql += " AND SA3.D_E_L_E_T_   = ZP1.D_E_L_E_T_ "
    cSql += " WHERE "
    cSql += " ZP5.ZP5_CNPJ		    = '"+ M->(Alltrim(A1_CGC)) + "' "
    cSql += " AND ZP5.ZP5_CLIENT	= '000000' "
    cSql += " AND ZP5.ZP5_LOJA	    = '00' "
    cSql += " AND ZP5.ZP5_DATA >= convert(varchar,DATEADD(MONTH,-1, GetDate()-DAY(GetDate())+1), 112)"
    cSql += " AND ZP5.D_E_L_E_T_    = '' "
    oSql:newAlias(cSql)
	if oSql:hasRecords()
        if oSql:count() == 1
             oSql:GoTop()
             M->(A1_VEND) := oSql:getValue('A3_COD')
        else
            MsgInfo('Selecione Manual', 'Varios Representantes')
        endif
    endif
	oSql:close()
    FreeObj(oSql)
return nil


static function handlerr(oErr)
    Help(NIL, NIL, "API-Receita", NIL, oErr:Description, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Erro"}) 
    BREAK
return 

static function handlreceita(oErr, lRet)
    lRet := .F.
    Help(NIL, NIL, "API-Receita", NIL, oErr:Description, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verificar servidor Receita"}) 
    BREAK
return 

static function handlCli(oErr,lOk, cErro)
    cErro   := oErr:Description
    lOk     := .F.
    Help(NIL, NIL, "Gravação do cliente", NIL, oErr:Description, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verificar mensagem de erro"}) 
    BREAK
return 

static function handltss(oErr)
    Help(NIL, NIL, "TSS-Contribuinte", NIL, oErr:Description, 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verificar mensagem de erro"}) 
    BREAK
return

static function openUrl(cUrl, cTitulo)
    oModal  := FWDialogModal():New()       
    oModal:SetEscClose(.T.)
    oModal:setTitle(cTitulo)
    oModal:setSize(200, 640)
    oModal:createDialog()
    oModal:addCloseButton(nil, "Fechar")
    oContainer       := TPanel():New( ,,, oModal:getPanelMain() )
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT
    oWebChannel      := TWebChannel():New()
    oWebEngine       := TWebEngine():New(oContainer, 0, 0, 100, 100,,)
    oWebEngine:navigate(cUrl)
    oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
    oModal:Activate()
return nil


static function doWork(oPnl, cUrl)
    oWebEngine  := TWebEngine():New(oPnl, 0, 0, 100, 100,,)
    oWebEngine:navigate(cUrl)
    oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
    oWebEngine:ClearCache()
return oWebEngine


static function getUrlSrv(cWho)
    local cUrl := ''
    local aUrl := {}
    local nPos := 0
    aadd(aUrl, {'RECEITA',  GetNewPar('ZZ_URLREC', 'https://servicos.receita.fazenda.gov.br/servicos/cnpjreva/Cnpjreva_Solicitacao_CS.asp')})
    aadd(aUrl, {'SINTEGRA', GetNewPar('ZZ_URLSIN', 'http://www.sintegra.gov.br/')})
    aadd(aUrl, {'SIMPLES',  GetNewPar('ZZ_URLSIM', 'http://www8.receita.fazenda.gov.br/simplesnacional/aplicacoes.aspx?id=21')})
    aadd(aUrl, {'DFE',      GetNewPar('ZZ_URLDFE', 'https://dfe-portal.svrs.rs.gov.br/NFE/CCC')})
    aadd(aUrl, {'FLUIG',    GetNewPar('ZZ_URLFLG', 'http://192.168.1.217:6080/portal/')})
    aadd(aUrl, {'TSS',      GetNewPar('ZZ_URLTSS', 'http://192.168.1.220:8033/NFESBRA.apw')})

    if(nPos := AScan( aUrl, {|x| upper(alltrim(x[1])) == upper(alltrim(cWho))} )) > 0
        cUrl := aUrl[nPos][2]
    endif
return cUrl


static function getSintUtl(cEst)
    local aEst := {}
    local cUrl := ''
    aadd(aEst, {'AC', GetNewPar('ZZ_URLXAC', 'http://sefaznet.ac.gov.br/sefazonline/servlet/hpfsincon')})
    aadd(aEst, {'AL', GetNewPar('ZZ_URLXAL', 'http://www.sefaz.al.gov.br/asp/sintegra/sintegra.asp?estado=AL')})
    aadd(aEst, {'AP', GetNewPar('ZZ_URLXAP', 'http://www.sefaz.ap.gov.br/sate/seg/SEGf_AcessarFuncao.jsp?cdFuncao=CAD_011')})
    aadd(aEst, {'AM', GetNewPar('ZZ_URLXAM', 'http://www.sefaz.am.gov.br/sintegra/sintegra0.asp')})
    aadd(aEst, {'BA', GetNewPar('ZZ_URLXBA', 'http://www.sefaz.ba.gov.br/Sintegra/sintegra.asp?estado=BA')})
    aadd(aEst, {'CE', GetNewPar('ZZ_URLXCE', 'https://servicos.sefaz.ce.gov.br/internet/Sintegra/Sintegra.Asp?estado=CE')})
    aadd(aEst, {'DF', GetNewPar('ZZ_URLXDF', 'http://www.fazenda.df.gov.br/area.cfm?id_area=110')})
    aadd(aEst, {'ES', GetNewPar('ZZ_URLXES', 'http://www.sintegra.es.gov.br/')})
    aadd(aEst, {'GO', GetNewPar('ZZ_URLXGO', 'http://appasp.sefaz.go.gov.br/Sintegra/Consulta/default.asp?')})
    aadd(aEst, {'MA', GetNewPar('ZZ_URLXMA', 'http://aplicacoes.ma.gov.br/sintegra/jsp/consultaSintegra/consultaSintegraFiltro.jsf')})
    aadd(aEst, {'MT', GetNewPar('ZZ_URLXMT', 'https://www.sefaz.mt.gov.br/cadastro/emissaocartao/emissaocartaocontribuinteacessodireto')})
    aadd(aEst, {'MS', GetNewPar('ZZ_URLXMS', 'http://www1.sefaz.ms.gov.br/Cadastro/sintegra/cadastromsCCI.asp')})
    aadd(aEst, {'MG', GetNewPar('ZZ_URLXMG', 'http://consultasintegra.fazenda.mg.gov.br/')})
    aadd(aEst, {'PA', GetNewPar('ZZ_URLXPA', 'http://app.sefa.pa.gov.br/Sintegra/')})
    aadd(aEst, {'PB', GetNewPar('ZZ_URLXPB', 'https://www4.sefaz.pb.gov.br/sintegra')})
    aadd(aEst, {'PR', GetNewPar('ZZ_URLXPR', 'http://www.sintegra.fazenda.pr.gov.br/sintegra/')})
    aadd(aEst, {'PE', GetNewPar('ZZ_URLXPE', 'http://www.sintegra.sefaz.pe.gov.br/')})
    aadd(aEst, {'PI', GetNewPar('ZZ_URLXPI', 'http://web.sintegra.sefaz.pi.gov.br/')})
    aadd(aEst, {'RJ', GetNewPar('ZZ_URLXRJ', 'http://www4.fazenda.rj.gov.br/sincad-web/index.jsf')})
    aadd(aEst, {'RN', GetNewPar('ZZ_URLXRN', 'http://www.set.rn.gov.br/uvt/consultacontribuinte.aspx')})
    aadd(aEst, {'RS', GetNewPar('ZZ_URLXRS', 'https://www.sefaz.rs.gov.br/consultas/contribuinte')})
    aadd(aEst, {'RO', GetNewPar('ZZ_URLXRO', 'http://www.sefin.ro.gov.br/sint_consul.asp')})
    aadd(aEst, {'RR', GetNewPar('ZZ_URLXRR', 'https://portalapp.sefaz.rr.gov.br/siate/servlet/wp_siate_consultasintegra')})
    aadd(aEst, {'SC', GetNewPar('ZZ_URLXSC', 'http://sistemas3.sef.sc.gov.br/sintegra/consulta_empresa_pesquisa.aspx')})
    aadd(aEst, {'SP', GetNewPar('ZZ_URLXSP', 'https://www.cadesp.fazenda.sp.gov.br/Pages/Cadastro/Consultas/ConsultaPublica/ConsultaPublica.aspx')})
    aadd(aEst, {'SE', GetNewPar('ZZ_URLXSE', 'http://www.sefaz.se.gov.br/sintegra')})
    aadd(aEst, {'TO', GetNewPar('ZZ_URLXTO', 'http://sintegra.sefaz.to.gov.br/')})
    if(nPos := AScan( aEst, {|x| upper(alltrim(x[1])) == upper(alltrim(cEst))} )) > 0
        cUrl := aEst[nPos][2]
    endif
return cUrl


/* TEST ZONE */
user function zxMshCad()
    local oMsh  as object
    local bErro as object
    local oAcl  as object

    if !getNewPar('ZX_LIGACAD', .T.)
        MsgAlert('Rotina Desativada', 'Aviso')
    else
        bErro  := ErrorBlock({|oErr| handlerr(oErr)})
        BEGIN SEQUENCE
            oAcl := cbcAcl():newcbcAcl() 
            if !oAcl:aclValid('newCadCliente')
                MsgAlert(oAcl:getAlert(), 'Acesso')
            else
                oMsh := cbcMshCadastro():newcbcMshCadastro()
                oMsh:showScreen()
                FreeObj(oMsh)
            endif
            FreeObj(oAcl)
        END SEQUENCE
        ErrorBlock(bErro)
    endif
return(nil)
