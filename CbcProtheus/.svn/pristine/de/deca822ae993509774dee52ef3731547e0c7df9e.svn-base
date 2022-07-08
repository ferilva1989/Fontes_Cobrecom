#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWMVCDef.ch'
#include 'cbcOrdemCar.ch'

class cbcCtrlFatur
    data lOk
    data cMsgErr
    data lShowErr
    data aNFs

    method new()

    method setStatus()
    method isOk()
    method getErrMsg()
    method showErr()
    method getNFs()
    method addNF()
    method addRemess()
    method fatura()
endClass

method new(lShowErr) class cbcCtrlFatur
    default lShowErr := .T.
    ::lShowErr := lShowErr
    ::aNFs := {}
    ::setStatus()
return(self)

method setStatus(lOk, cMsgErr, lEx, lShow) class cbcCtrlFatur
    default lOk     := .T.
    default cMsgErr := ''
    default lEx     := .F.
    default lShow   := ::showErr()

    ::lOk       := lOk

    if !(lOk)
        ::aNFs      := {}
        ::cMsgErr   := '[cbcCtrlFatur] - ' + cMsgErr
        if lEx
            UserException(::getErrMsg())
        else
            if (lShow)
                MsgAlert(::getErrMsg(),'Erro - cbcCtrlFatur')
            endif
        endif
    endif
return(self)

method isOk() class cbcCtrlFatur
return(::lOk)

method getErrMsg() class cbcCtrlFatur
return(::cMsgErr)

method showErr() class cbcCtrlFatur
return(::lShowErr)

method getNFs() class cbcCtrlFatur
return(::aNFs)

method addNF(cNF, cSerie) class cbcCtrlFatur
    local aRemess := {}
    if !empty(cNF) .and. !empty(cSerie)
        aAdd(::aNFs, {AllTrim(cNF), AllTrim(cSerie), aRemess})
    endif
return(self)

method addRemess(nPosi, cRemess) class cbcCtrlFatur
    default nPosi   := 0
    default cRemess := ""
    if !empty(nPosi) .and. (len(::getNFs()) >= nPosi) .and. !empty(cRemess)
        aAdd(::aNFs[nPosi, 03], cRemess)
    endif
return(self)

method fatura(cParCarga, oSay) class cbcCtrlFatur
    local aArea    	:= GetArea()
    local aAreaZZR 	:= ZZR->(GetArea())
    local aAreaZZ9 	:= ZZ9->(GetArea())
    local oSql      := nil
    local aPeds     := {}
    local nAtu      := 0
    local nRegs     := 0
    local aErr      := {}
    local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @self)})
    local oStatic   := IfcXFun():newIfcXFun()
    private oCarga  := cbcCtrlCarga():newcbcCtrlCarga()
    private aRecs   := {}
    private cCarga  := AllTrim(cParCarga)
    private _cSerEsc:= ""
    private cFatCli := ""
    private cFatLoja:= ""
    
    ::aNFs := {}
    if ::setStatus(!empty(cCarga), 'CARGA não Definida!'):isOk()
        Pergunte("MT460A",.T.)
        if ::setStatus(NFNum(), 'Erro ao Definir Série da NF!'):isOk()
            BEGIN SEQUENCE
                oCarga:define(cCarga)
                if ::setStatus(oCarga:isOk(), 'Erro ao definir CARGA!'):isOk()
                    DbSelectArea("ZZ9")
                    oSql := LibSqlObj():newLibSqlObj()
                    if oSay <> nil
                        oSay:SetText('Carregando OSs...')
                        ProcessMessage()
                    endif
                    oSql:newAlias(oStatic:sP(1):callStatic('cbcQryCarga', 'getRegs', cCarga))
                    if oSql:hasRecords()
                        nRegs := oSql:Count()
                        oSql:goTop()
                        while oSql:notIsEof()
                            nAtu++
                            if oSay <> nil
                                oSay:SetText('Faturando: ' + cValToChar(nAtu) + ' de ' + cValToChar(nRegs))
                                ProcessMessage()
                            endif
                            BEGIN TRANSACTION
                                ZZ9->(DbGoTo(oSql:getValue("REC")))
                                verifica(AllTrim(ZZ9->ZZ9_ORDSEP), @aPeds, @self)
                                if ::isOk()
                                    chamaFatur(AllTrim(ZZ9->ZZ9_ORDSEP), aPeds, @self)
                                endif
                                if !(::isOk())
                                    aAdd(aErr,{AllTrim(ZZ9->ZZ9_ORDSEP), ::getErrMsg()})
                                    DisarmTransaction()
                                endif
                            END TRANSACTION
                            oSql:skip()
                        endDo
                    endif
                    oSql:close()
                    FreeObj(oSql)
                endif
                RECOVER
            END SEQUENCE
            ErrorBlock(bErro)
            FatFim(::getNFs(), aErr)
        endif
    endif

    FreeObj(oCarga)
    RestArea(aAreaZZ9)
    RestArea(aAreaZZR)
    RestArea(aArea)
return(self)

static function FatFim(aNFs, aErr)
	local nX		:= 0
    local nY        := 0
	local oSql      := nil
	local cHtml		:= ''
    local cHtml2	:= ''
    local cHtml3	:= ''
	local cLinha	:= '<br>'
	local cTo		:= GetNewPar('ZZ_FATMAIL', 'wfti@cobrecom.com.br')
    local oStatic   := IfcXFun():newIfcXFun()

    cHtml   := "<HTML><BODY><FONT FACE=VERDANA SIZE=2 COLOR=BLACK>"
    cHtml	+= 'cbcFatur - CARGA: ' + AllTrim(cCarga) + ' - NFs Faturadas:'
    cHtml   += cLinha
    if empty(aNFs)
        cHtml += "Nenhuma NF Faturada!"
        cHtml += cLinha
    else
        cHtml += '<table class="table" id="table">'
        cHtml += '<col style="width:15%">'
        cHtml += '<col style="width:15%">'
        cHtml += '<col style="width:15%">'
        cHtml += '<col style="width:20%">'
        cHtml += '<col style="width:10%">'
        cHtml += '<col style="width:10%">'
        cHtml += '<col style="width:15%">'
        cHtml += '<thead>'
        cHtml += '<tr>'
        cHtml += '<th>NF</th>'
        cHtml += '<th>OS</th>'
        cHtml += '<th>Vol</th>'
        cHtml += '<th>Especie</th>'
        cHtml += '<th>Pes.Liq.</th>'
        cHtml += '<th>Pes.Bruto</th>'
        cHtml += '<th>Remessa</th>'
        cHtml += '</tr>'
        cHtml += '</thead>'
        cHtml += '<tbody>'
        for nX := 1 to len(aNFs)
            oSql := LibSqlObj():newLibSqlObj()
            oSql:newAlias(oStatic:sP(2):callStatic('cbcQryFatur', 'getNFInfo', aNFs[nX, 01], aNFs[nX, 02]))
            cHtml2:= ''
            cHtml2 += '<tr>'
                cHtml2 += '<td>'
                    cHtml2 += AllTrim(aNFs[nX,01]) + '/' + AllTrim(aNFs[nX,02])
                cHtml2 += '</td>'
                if oSql:hasRecords()
                    oSql:goTop()
                    cHtml2 += '<td>'
                        cHtml2 += AllTrim(oSql:getValue("SEP"))
                    cHtml2 += '</td>'
                    cHtml2 += '<td>'
                        cHtml2 += cValToChar(oSql:getValue("VOL"))
                    cHtml2 += '</td>'
                    cHtml2 += '<td>'
                        cHtml2 += AllTrim(oSql:getValue("ESP"))
                    cHtml2 += '</td>'
                    cHtml2 += '<td>'
                        cHtml2 += cValToChar(oSql:getValue("LIQ"))
                    cHtml2 += '</td>'
                    cHtml2 += '<td>'
                        cHtml2 += cValToChar(oSql:getValue("BRUT"))
                    cHtml2 += '</td>'
                    if empty(aNFs[nX,03])
                        cHtml2 += '<td>'
                            cHtml2 += ''
                        cHtml2 += '</td>'
                    else
                        for nY := 1 to len(aNFs[nX,03])
                            if nY > 1
                                cHtml3 += cHtml2
                            endif
                            cHtml3 += '<td>'
                                cHtml3 += AllTrim(aNFs[nX,03,nY])
                            cHtml3 += '</td>'
                        next nY
                        cHtml2 += cHtml3
                    endif
                else
                    for nX := 1 to 6
                        cHtml2 += '<td>'
                            cHtml2 += 'NÃO LOCALIZADO'
                        cHtml2 += '</td>'
                    next nX
                endif
			cHtml2 += '</tr>'
            oSql:close()
            FreeObj(oSql)
            cHtml += cHtml2
        next nX
        cHtml += '</tbody>'
        cHtml += '</table>'
    endif
    if !empty(aErr)
        cHtml += cLinha
        cHtml += cLinha
        cHtml += 'OS(s) não Faturada(s):'
        cHtml += cLinha
        cHtml += '<table class="table" id="table_err">'
        cHtml += '<col style="width:20%">'
        cHtml += '<col style="width:80%">'
        cHtml += '<thead>'
        cHtml += '<tr>'
        cHtml += '<th>OS</th>'
        cHtml += '<th>Erro</th>'
        cHtml += '</tr>'
        cHtml += '</thead>'
        cHtml += '<tbody>'
        for nX := 1 to len(aErr)
            cHtml += '<tr>'
                cHtml += '<td>'
                    cHtml += AllTrim(aErr[nX, 01])
                cHtml += '</td>'
                cHtml += '<td>'
                    cHtml += AllTrim(aErr[nX, 02])
                cHtml += '</td>'
			cHtml += '</tr>'
        next nX
        cHtml += '</tbody>'
        cHtml += '</table>'
    endif
    if !empty(cHtml) .and. !empty(cTo)
        u_SendMail(cTo,'[cbcFatur] Carga: ' + cCarga , cHtml)
    endif
	initVw(cHtml)
return(nil)

static function initVw(cHtml)
	local oModalBrw 	:= nil
	local oFwBrw		:= nil
	local oFwBrwL		:= nil
	local oFwBrwR		:= nil
	local lCloseButt 	:= !(oAPP:lMdi)
	local oWebEngine 	:= nil
	local oBtnClose		:= nil
	local oBtnPrint		:= nil
	private oWebChannel := TWebChannel():New()
	private nPort 		:= oWebChannel:connect()
	
	oModalBrw	:= FWDialogModal():New() 
	//Seta a largura e altura da janela em pixel
	oModalBrw:setSize(350,600)
	oModalBrw:SetEscClose(.F.)
	oModalBrw:setTitle('Visualizar Detalhes')
	oModalBrw:createDialog()
	
	oFwBrw := FWLayer():New()
	oFwBrw:Init(oModalBrw:getPanelMain(), lCloseButt)
	
	//"Controles"
    oFwBrw:AddCollumn('COL_LEFT', 12, .F.)
	oFwBrw:AddWindow('COL_LEFT', 'WND_CTRL', 'Controles', 100, .T., .F.)
	oFwBrwL := oFwBrw:GetWinPanel('COL_LEFT', 'WND_CTRL')
	
	oFwBrw:SetColSplit('COL_LEFT', CONTROL_ALIGN_RIGHT)
	
	//"Detalhes"
	oFwBrw:AddCollumn('COL_RIGHT', 85, .F.)	
    oFwBrw:AddWindow('COL_RIGHT', 'WND_OS', 'Ordens de Separação', 100, .T., .F.)
    oFwBrwR := oFwBrw:GetWinPanel('COL_RIGHT', 'WND_OS')
    
    oWebEngine 	:= TWebEngine():New(oFwBrwR, 05, 05, 350, 600,, nPort)
    oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
    oWebEngine:setHtml(cHtml)
    
    oBtnClose := TButton():New( 05, 05, 'Fechar', 		oFwBrwL ,{|| oModalBrw:DeActivate()}, 50,20,,,.F.,.T.,.F.,,.F.,,,.F. )    
    oBtnPrint := TButton():New( 30, 5, 	'Impressão',	oFwBrwL ,{|| oWebEngine:PrintPDF()},  50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
     
    
    oModalBrw:Activate()
    
	FreeObj(oBtnClose)
	FreeObj(oBtnPrint)
	FreeObj(oWebEngine)
	FreeObj(oFwBrwR)
	FreeObj(oFwBrwL)
	FreeObj(oFwBrw)
	FreeObj(oModalBrw)
return(nil)

static function NFNum()
    local cSerie  := ""
    local lRet    := .T.
    
    lRet   := Sx5NumNota(@cSerie,)
    
    if lRet
        if !cSerie $ "UNI/1  /UM "
            if MsgYesNo("Utiliza a Série '" + cSerie + "' para o Processamento Dessas Notas?")
                _cSerEsc := cSerie
            else
                lRet := .F.
            endif
        else
            _cSerEsc := cSerie
        endif
    endif
return(lRet)

static function verifica(cOS, aPeds, oSelf)
    local aArea    	:= GetArea()
    local aAreaSC9 	:= SC9->(GetArea())
    local oSql      := nil
    local oStatic   := IfcXFun():newIfcXFun()

    cFatCli     := ""
    cFatLoja    := ""
    aPeds       := {}
    aRecs       := {}

    if oSelf:setStatus((oCarga:getStatus(cOS) == CARGA_LIB_FATUR), "OS: " + cOS + " não está liberada para faturamento!"):isOk()
        oSql := LibSqlObj():newLibSqlObj()
        oSql:newAlias(oStatic:sP(1):callStatic('cbcQryFatur', 'confLib', cOS))
        if oSelf:setStatus(oSql:hasRecords(), "OS: " + cOS + ". Liberações não localizadas!"):isOk()
            oSql:goTop()
            while oSql:notIsEof()
                if (oSql:getValue("QTD") <> oSql:getValue("QTD_SC9"))
                    aPeds := {}
                    aRecs := {}
                    oSelf:setStatus(.F., "OS: " + cOS + ". Divergência entre liberações do ZZR x SC9!")
                    Exit
                endif
                oSql:skip()
            endDo
        endif
        oSql:close()
        FreeObj(oSql)
        if oSelf:isOk()
            oSql := LibSqlObj():newLibSqlObj()
            oSql:newAlias(oStatic:sP(1):callStatic('cbcQryFatur', 'qryPedSeq', cOS))
            if oSelf:setStatus(oSql:hasRecords(), "OS: " + cOS + " não localizada!"):isOk()
                oSql:goTop()
                while oSql:notIsEof()                    
                    if empty(cFatCli) .and. empty(cFatLoja)
                        cFatCli     := AllTrim(oSql:getValue("CLI"))
                        cFatLoja    := AllTrim(oSql:getValue("LOJA"))
                    else
                        if AllTrim(oSql:getValue("CLI")) <> cFatCli .and. AllTrim(oSql:getValue("LOJA")) <> cFatLoja
                            aPeds := {}
                            aRecs := {}
                            oSelf:setStatus(.F., "OS: " + cOS + ". Multiplos clientes na mesma OS!")
                            Exit
                        endif
                    endif
                    if AScan(aPeds, AllTrim(oSql:getValue("PEDIDO"))) == 0
                        aAdd(aPeds, AllTrim(oSql:getValue("PEDIDO")))
                    endif
                    aAdd(aRecs, oSql:getValue("SC9_REC"))
                    oSql:skip()
                endDo
            endif
            oSql:close()
            FreeObj(oSql)
        endif
    endif
    RestArea(aAreaSC9)
    RestArea(aArea)
return(nil)

static function chamaFatur(cParOS, aPeds, oSelf)
    local cNFAtu        := ""
    local cBckModu      := cModulo
    private _cFiltro    := " C9_FILIAL == '" + xFilial("SC9") + "' " 
    private cNomTrb     := ""
    private cNomTrb1    := ""
    private cNomTrb2    := ""
    private cNomTrb0    := ""
    private cNomTrb01   := ""
    private dUlMes      := GetMv("MV_ULMES")
    private MV_xPAR01   := 0
    private MV_xPAR02   := ' '
    private MV_xPAR03   := ' '
    private MV_xPAR04   := ' '
    private MV_xPAR05   := ' '
    private MV_xPAR06   := ' '
    private MV_xPAR07   := ' '
    private MV_xPAR08   := 0
    private MV_xPAR09   := 0
    private cMarca      := GetMark()
    private _lNewBrow   := .T.
    private nQuantR     := 0
    private cOS         := AllTrim(cParOS)
    private NfDe        := ""
    private NfAte       := ""

    cModulo :=  "FAT"
    validFatur(@oSelf, aPeds)
    
    if oSelf:isOk()
        DbSelectArea("SA4")
        SA4->(DbSetOrder(1))

        DbSelectArea("SA2")
        SA2->(DbSetOrder(1))

        DbSelectArea("SA1")
        SA1->(DbSetOrder(1))

        DbSelectArea("SC5")
        SC5->(DbSetOrder(1))

        DbSelectArea("SC6")
        SC6->(DbSetOrder(1))
        
        DbSelectArea("SC9")
        SC9->(DbSetOrder(1))

        /*
        cPerg := "CDFT04"

        StaticCall(CSFatur, ValidPerg)

        MV_xPAR01 := 2
        MV_xPAR02 := aPeds[01]
        MV_xPAR03 := aPeds[Len(aPeds)]
        MV_xPAR04 := cFatCli
        MV_xPAR05 := cFatLoja
        MV_xPAR06 := cFatCli
        MV_xPAR07 := cFatLoja
        MV_xPAR08 := 2
        MV_xPAR09 := 2
        */
        cMarca := Left(cMarca+Space(Len(SC9->C9_OK)),Len(SC9->C9_OK))
        
        marcaSC9(cMarca)

        _cFiltro += " .AND. C9_OK = '" + cMarca + "'"
        _cFiltro += " .AND. C9_CLIENTE = '" + AllTrim(cFatCli) + "'"
        _cFiltro += " .AND. C9_LOJA = '" + AllTrim(cFatLoja) + "'"
        _cFiltro += " .AND. C9_PEDIDO $ (" + getStrPeds(aPeds) + ")"
        
        SC9->(DbSetFilter( { ||  &(_cFiltro)}, _cFiltro ) )
        SC9->(DbGoTop())
        
        FWMsgRun(, { || u_FecharFt(.T.) }, 	"Faturamento", "Iniciando...")
        if oSelf:setStatus(!empty(NfDe),"NF não Faturada!"):isOk()
            cNFAtu := AllTrim(NfDe)
            while !empty(cNFAtu)
                oSelf:addNF(cNFAtu, AllTrim(_cSerEsc))
                doRemessa(@oSelf, cNFAtu, AllTrim(_cSerEsc))
                if cNFAtu <> NfAte
                    cNFAtu := Soma1(AllTrim(cNFAtu))
                else
                    cNFAtu := ""
                endif
            endDo
        endif
    endif
    cModulo := cBckModu
return(oSelf)

static function validFatur(oSelf, aPeds)
    local aArea    	    := GetArea()
    local aAreaSC5 	    := SC5->(GetArea())
    local aAreaSA1 	    := SA1->(GetArea())
    local nX            := 0
    local nFatRet       := GetMv("ZZ_RETFAT")
    local nFatAva       := GetMv("ZZ_AVAFAT")
    local nDias         := Date()-dDataBase
    local cDiaFat 	    := StrZero(Day(dDataBase),2)
    local cPerFat       := ""
    local lBlqCli       := .T.

    if oSelf:setStatus((dDataBase > dUlMes), "Data Anterior ao Último Fechamento do Estoque"):isOk()
        if oSelf:setStatus((nDias <= nFatRet .Or. nDias >= nFatAva), "Não é possível Processar Notas fiscais com a data de " + DtoC(dDataBase)):isOk()
            DbSelectArea("SA1")
            SA1->(DbSetOrder(1))
            
            DbSelectArea("SC5")
            SC5->(DbSetOrder(1))
            for nX := 1 to len(aPeds)
                if !(oSelf:setStatus( SC5->(DbSeek(xFilial("SC5")+Padr(AllTrim(aPeds[nX]),TamSx3("C5_NUM")[1]))),"Pedido: " + AllTrim(aPeds[nX]) + " não localizado!"):isOk())
                    EXIT
                endif
                if !(oSelf:setStatus(AllTrim(SC5->C5_ZZBLVEN) <> "S","Pedido: " + AllTrim(aPeds[nX]) + " Bloqueado pelo comercial!"):isOk())
                    EXIT
                endif
                cPerFat	:= Alltrim(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_ZZPRFAT"))
                if !empty(cPerFat)
                    if !(oSelf:setStatus((cDiaFat $ cPerFat),"Pedido: " + AllTrim(aPeds[nX]) + " faturado fora da regra do cadastro do cliente!"):isOk())
                        EXIT
                    endif
                endif
                if !(oSelf:setStatus((dDataBase >= SC5->C5_DTFAT),"Pedido: " + AllTrim(aPeds[nX]) + " bloqueado por data de faturamento!"):isOk())
                    EXIT
                endif
                lBlqCli := (Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_MSBLQL") == '2')
                if !(oSelf:setStatus(lBlqCli,"Pedido: " + AllTrim(aPeds[nX]) + " - Cliente Bloqueado - Não Será Faturado!"):isOk())
                    EXIT
                endif
            next nX
        endif
    endif
    RestArea(aAreaSA1)
    RestArea(aAreaSC5)
    RestArea(aArea)
return(nil)

static function getStrPeds(aPeds)
    local cStr := ""
    local nX   := 0

    for nX := 1 to len(aPeds)
        if !empty(cStr)
            cStr += ", "
        endif
            cStr += "'" + aPeds[nX] + "'"
    next nX
return(cStr)

static function marcaSC9(cMarca)
    local aArea    	:= GetArea()
    local aAreaSC9 	:= SC9->(GetArea())
    local nX        := 0
	
    DbSelectArea("SC9")
    
    for nX := 1 to len(aRecs)
		SC9->(DbGoTo(aRecs[nX]))
        RecLock("SC9",.F.)	
            SC9->C9_OK := cMarca
            SC9->C9_RISCO := " "
		MsUnLock()
        nQuantR++
		SC9->(DbSkip())
	next nX
    RestArea(aAreaSC9)
    RestArea(aArea)
return(nil)

static function ajustaVol()
    local aArea    	 := GetArea()
    local aAreaSC5 	 := SC5->(GetArea())
    local oVol       := cbcCtrlVolum():newcbcCtrlVolum()
    local cTranpProp := AllTrim(GetNewPar('ZZ_TRPPROP', ""))
    local oStatic    := IfcXFun():newIfcXFun()
    local aVol       := {}
    local aEsp       := {}
    local nX         := 0
    local nY         := 0
    local nVol       := 0
    local cEspc      := ""
    local aTransp    := {}
    local nPesBruto  := 0
    local nPesLiq    := 0
    local nTara      := 0

    if (Type("cOS") <> "U") .and. (Type("cCarga") <> "U")
        if oCarga:isOk()
            aTransp := oCarga:getTransp()
        endif
        oStatic:sP(5):callStatic('cbcManifesto', 'mntDados', 'DET', nil, @aVol, oVol:loadVolumes(cCarga, cOS), .T.)
        for nY := 1 to len(aVol)
            aEsp := {}
            oStatic:sP(2):callStatic('cbcCtrlVolum', 'makeStrVol', aVol[nY], @aEsp)
            for nX := 1 to len(aEsp)
                nVol += aEsp[nX, 02]
                if !empty(cEspc)
                    cEspc += "/"
                endif
                cEspc += (cValTochar(aEsp[nX, 02]) + aEsp[nX, 01])
            next nX
            nPesBruto += aVol[nY, 10]
            nPesLiq += aVol[nY, 11]
            nTara += aVol[nY, 12]
        next nY
        SC5->(RecLock("SC5",.F.))
            SC5->C5_PESOBOB := nTara
            SC5->C5_PBRUTO  := nPesBruto
            SC5->C5_PESOL   := nPesLiq
            SC5->C5_TRANSP  := aTransp[1]
            SC5->C5_VEICULO := aTransp[3]
            if (AllTrim(aTransp[1]) $ cTranpProp)
                if AllTrim(SC5->C5_TPFRETE) == 'C'
                    SC5->C5_TPFRETE := 'R'
                elseif AllTrim(SC5->C5_TPFRETE) == 'F'
                    SC5->C5_TPFRETE := 'D'
                endif
            endif
            SC5->C5_VOLUME1 := nVol
            SC5->C5_ESPECI1 := cEspc
		SC5->(MsUnLock())
    endif

    FreeObj(oVol)
    RestArea(aAreaSC5)
    RestArea(aArea)
return(nil)

static function doRemessa(oSelf, cNF, cSerie)
    local aArea    	:= GetArea()
    local aAreaSC5 	:= SC5->(GetArea())
    local lDoRem    := GetNewPar('ZZ_FATREME', .F.)
    local oStatic   := IfcXFun():newIfcXFun()
    local nX        := 0
    local oSql      := nil
    local aRecsF2   := {}
    local aRecsD2   := {}
    local aRemess   := {}
    local aTemp     := {}

    if lDoRem
        if !empty(cNF)
            oSql := LibSqlObj():newLibSqlObj()
            oSql:newAlias(oStatic:sP(1):callStatic('cbcQryFatur', 'getF2Rem', {cNF, cSerie}))
            if oSql:hasRecords()
                oSql:goTop()
                while oSql:notIsEof()
                    aAdd(aRecsF2, {oSql:getValue('REC'), len(oSelf:getNFs())})
                    oSql:skip()
                endDo
            endif
            oSql:close()
            FreeObj(oSql)
        endif
        for nX := 1 to len(aRecsF2)
            aRecsD2 := {}
            oSql := LibSqlObj():newLibSqlObj()
            oSql:newAlias(oStatic:sP(1):callStatic('cbcQryFatur', 'getD2Rem', cValToChar(aRecsF2[nX, 01])))
            if oSql:hasRecords()
                oSql:goTop()
                while oSql:notIsEof()
                    aAdd(aRecsD2, oSql:getValue('REC'))
                    oSql:skip()
                endDo
            endif
            oSql:close()
            FreeObj(oSql)
            aAdd(aRemess, {aRecsF2[nX,01], aRecsD2, aRecsF2[nX,02]})
        next nX
        for nX := 1 to len(aRemess)
            aTemp := u_cbcFatRemes(aRemess[nX,01], aRemess[nX,02], cSerie)
            if !(oSelf:setStatus(aTemp[1], aTemp[3]):isOk())
                EXIT
            else
                oSelf:addRemess(aRemess[nX,03], aTemp[2])
            endif
        next nX
    endif
    RestArea(aAreaSC5)
    RestArea(aArea)
return(oSelf)

static function HandleEr(oErr, oSelf)
    if InTransact()
        DisarmTransaction()
    endif
    oSelf:setStatus(.F., oErr:Description)
    BREAK
return(nil)
