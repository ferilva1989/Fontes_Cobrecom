#INCLUDE "XMLXFUN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH" 
#include 'parmtype.ch'
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "rwmake.ch"

#define REC				1
#define ID_ENT			2
#define DOC_CHV			3
#define EMAIL			4
#define NFE_ID			5
#define CNPJ			6
#define NFE_PROT	    7
#define XML             8 
#define DANFE	        9

user function cbcSendTSSMail(cIdEnt, lOnlyTest, aParam)
    local oSql            := nil
    local cDanfe          := ""
    local cXml            := ""
    local aArq            := {}
    
    private nHndERP       := AdvConnection()
	private cDBOra        := GetNewPar('ZZ_TSSNAME',"MSSQL/IFC_NFE_P12")
	private cSrvOra       := GetNewPar('ZZ_TSSEND',"192.168.25.2")
	private nHndOra       := -1
    private lTssConnect   := .F.
    private aToSend       := {}
    private aNoUsrPerg    := {}
    private nTotalMail    := 0
    private nEnviados     := 0
    private lTesteMode    := .F.
    
    default cIdEnt        := RetIdEnti(.F.)
    default lOnlyTest     := .F.
    default aParam        := PergSendTssMail()

    lTesteMode := lOnlyTest

    if !empty(aParam)
        chgDataBase()
        if lTssConnect
            oSql := LibSqlObj():newLibSqlObj()
            oSql:newAlias(qrySendTssMail(cIdEnt, aParam))
            if !oSql:hasRecords()
                u_autoAlert('Nenhuma NF encontrada com os filtros selcionados!',,'Info','Nenhuma NF')
            else
                oSql:goTop()
                nTotalMail := (oSql:count())
                while oSql:notIsEof()                    
                    FWMsgRun(, {|| aArq := createXml(oSql:getValue("ID_ENT"),; 
                                        oSql:getValue("NFE_ID"),; 
                                        STOD(oSql:getValue("EMISSAO")),;
                                        oSql:getValue("CNPJ"),;
                                        aParam[10])},;
                        "Aguarde...", "Gerando XMLs...")
                    if aArq[1]
                        cXml    := aArq[2]  
                        aAdd(aToSend, { oSql:getValue("REC"),;
                                        oSql:getValue("ID_ENT"),;
                                        oSql:getValue("DOC_CHV"),;
                                        oSql:getValue("EMAIL"),;
                                        oSql:getValue("NFE_ID"),;
                                        oSql:getValue("CNPJ"),;
                                        oSql:getValue("NFE_PROT"),;
                                        cXml;
                                    })                                              
                    endif                        
                    oSql:skip()
                endDo
            endif
            oSql:close()
            FreeObj(oSql)
            chgDataBase()
            for nX := 1 to len(aToSend)
                cDanfe  := createDANFe(aToSend[nX, ID_ENT],aToSend[nX, DOC_CHV],aParam[10])
                aAdd(aToSend[nX], cDanfe)
            next nX
            chgDataBase()
            FWMsgRun(, {|| sendNFMail(aToSend,aParam[8], aParam[10])}, "Aguarde...", "Enviando Emails...")
        endif
    endif
    if lTssConnect
        chgDataBase()
    endif
    if nHndOra < 0
        // Fecha a conexão com o Oracle
        TcUnlink( nHndOra )
    endif
    
    u_autoAlert('Enviados com Sucesso:' + cValToChar(nEnviados) + 'de ' + cValToChar(nTotalMail),,'Info','Total de Emails Enviados')

return(nil)


static function qrySendTssMail(cIdEnt, aParam)
    local cQry      := ''
    local cModelo   := '55'
    local cSerie    := iif(empty(aParam[1]), '1  ', aParam[1])
    
    cQry += " SELECT SPED.R_E_C_N_O_ AS [REC],                                                           "
    cQry += " SPED.ID_ENT AS [ID_ENT], "
    cQry += " SPED.NFE_ID AS [NFE_ID], "
    cQry += " SPED.DATE_NFE AS [EMISSAO], "
    cQry += " SPED.CNPJDEST AS [CNPJ], "
    cQry += " SPED.DOC_CHV AS [DOC_CHV], "
    cQry += " SPED54.NFE_PROT AS [NFE_PROT], "
    cQry += " SPED.EMAIL AS [EMAIL] "
    cQry += " FROM SPED050 SPED WITH(NOLOCK)"
    cQry += " INNER JOIN SPED054 SPED54 WITH(NOLOCK) ON SPED.ID_ENT     = SPED54.ID_ENT "
    cQry += "                                       AND SPED.NFE_ID     = SPED54.NFE_ID "
    cQry += "                                       AND SPED.D_E_L_E_T_ = SPED54.D_E_L_E_T_ "
    cQry += " WHERE SPED.ID_ENT = '" + cIdEnt + "' "
    if !empty(aParam[2])
        cQry += " AND SPED.NFE_ID >= '" + AllTrim(cSerie + aParam[2]) + "'"
    endif
    if !empty(aParam[3])
        cQry += " AND SPED.NFE_ID <= '" + AllTrim(cSerie + aParam[3]) + "'"
    endif
    if !empty(aParam[4])
        cQry += " AND SPED.DATE_NFE >= '" + DtoS(aParam[4]) + "'"
    endif
    if !empty(aParam[5])
        cQry += " AND SPED.DATE_NFE <= '" + DtoS(aParam[5]) + "'"
    endif
    if !empty(aParam[6])
        cQry += " AND SPED.CNPJDEST >= '" + AllTrim(cValToChar(aParam[6])) + "'"
    endif
    if !empty(aParam[7])
        cQry += " AND SPED.CNPJDEST <= '" + AllTrim(cValToChar(aParam[7])) + "'"
    endif    
    if !empty(aParam[9])
        cQry += " AND SPED.STATUSMAIL = " + AllTrim(cValToChar(aParam[9]))
    endif    
    cQry += " AND SPED.STATUS = 6 "
    cQry += " AND SPED.STATUSCANC = 0  "
    cQry += " AND SPED.MODELO = '" + cModelo + "' "
    cQry += " AND SPED54.CSTAT_SEFR = '100' "
    cQry += " AND SPED.D_E_L_E_T_ = '' "
return(cQry)

static function createXml(cIdEnt, cSerieNota, dDataEmiss, cCnpj, cDestino)
    local oWS       := WSNFeSBRA():New()
    local oRetorno  := nil
    local oXml      := nil
    local oXmlExp   := nil
    local lRet      := .F.
    local nX        := 0
    local nHandle   := 0
    local cVerNfe   := ""
    local cCab1     := ""
    local cRodap    := ""
    local cXML      := ""
    local cArq      := ""
    local cChvNFe   := ""
    local cMsgErr   := ""
    local cPrefixo  := "NFe"
    Local cURL	    := PadR(GetNewPar("MV_SPEDURL","http://"),250)

    oWS:cUSERTOKEN        := "TOTVS"
    oWS:cID_ENT           := cIdEnt
    oWS:_URL              := AllTrim(cURL)+"/NFeSBRA.apw"
    oWS:cIdInicial        := cSerieNota
    oWS:cIdFinal          := cSerieNota
    oWS:dDataDe           := dDataEmiss
    oWS:dDataAte          := dDataEmiss
    oWS:cCNPJDESTInicial  := cCnpj
    oWS:cCNPJDESTFinal    := cCnpj
    oWS:nDiasparaExclusao := 0
    lRet:= oWS:RETORNAFX()
    oRetorno := oWS:oWsRetornaFxResult
    lRet := iif( valtype(lRet) == "U", .F., lRet )
    if !lRet
        cMsgErr := '001 - Erro ao obter dados do TOTVs TSS!'
    else		
        for nX := 1 to Len(oRetorno:OWSNOTAS:OWSNFES3)
            oXml    := oRetorno:OWSNOTAS:OWSNFES3[nX]
            oXmlExp := XmlParser(oRetorno:OWSNOTAS:OWSNFES3[nX]:OWSNFE:CXML,"","","")
            cXML	:= ""
            cVerNfe := IIf(Type("oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT") <> "U", oXmlExp:_NFE:_INFNFE:_VERSAO:TEXT, '')
            cCab1   := '<?xml version="1.0" encoding="UTF-8"?>'
            cCab1   += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="' + cVerNfe + '">'
            cRodap  := '</nfeProc>'
            cChvNFe := NfeIdSPED(oXml:oWSNFe:cXML,"Id")
            cXML    := AllTrim(cCab1)
            cXML    += AllTrim(oXml:oWSNFe:cXML)
            cXML    += AllTrim(oXml:oWSNFe:cXMLPROT)
            cXML    += AllTrim(cRodap)
            if !(lRet := !(Empty(cXML)))
                cMsgErr := '002 - Erro ao gerar conteúdo do .XML!'
                EXIT
            else
                if !(lRet := (ExistDir( cDestino )))
                    if !(lRet := (MakeDir( cDestino ) == 0))
                        cMsgErr := '003 - Erro ao Acessar Diretório!'
                        EXIT
                    endif
                endif
                if lRet
                    cArq := cChvNFe+"-"+cPrefixo+".xml"
                    nHandle := FCreate(cDestino+cArq)
                    if !(lRet := (nHandle > 0))
                        cMsgErr := '004 - Erro ao gerar arquivo .XML!'
                        EXIT
                    else
                        FWrite(nHandle,AllTrim(cCab1))
                        FWrite(nHandle,AllTrim(oXml:oWSNFe:cXML))
                        FWrite(nHandle,AllTrim(oXml:oWSNFe:cXMLPROT))
                        FWrite(nHandle,AllTrim(cRodap))
                        FClose(nHandle)
                    endif
                endif
            endif            
        next nX
    endif
    if !lRet .and. !empty(cMsgErr)
        u_autoAlert(cMsgErr)
    endif
    FreeObj(oWS)
    FreeObj(oRetorno)
    FreeObj(oXml)
    FreeObj(oXmlExp)
return({lRet, cArq, cMsgErr})

static function createDANFe(cIdEnt, cChv, cDestino)
    local aArea    	        := GetArea()
	local aAreaSF2	        := SF2->(getArea())
    local oSetup            := nil
    local nLocal       	    := 2
    local nOrientation 	    := 2
    local nPrintType        := 6 //PDF
    local cFilePrint        := "DANFE_"+cIdEnt+Dtos(MSDate())+StrTran(Time(),":","")
    local lAdjustToLegacy   := .F. // Inibe legado de resolução com a TMSPrinter
    local cMsgErr           := ""
    local nFlags            := PD_ISTOTVSPRINTER + PD_DISABLEPAPERSIZE + PD_DISABLEPREVIEW + PD_DISABLEMARGIN
    local nRec              := 0
    local cArq              := ""

    nRec := posicNF(cChv)
    if nRec <= 0        
        cMsgErr := "005 - NF não localizada!"
    else
        DbSelectArea("SF2")
        SF2->(DbGoTo(nRec))
        aNoUsrPerg := {SF2->F2_DOC, SF2->F2_DOC, SF2->F2_SERIE, 2, 2, 2, CToD(""), CToD("")}
        oDanfe := FWMSPrinter():New(cFilePrint, IMP_PDF, lAdjustToLegacy, /*cPathInServer*/, .T.)
        oSetup := FWPrintSetup():New(nFlags, "DANFE")
        oSetup:SetPropert(PD_PRINTTYPE   , nPrintType)
        oSetup:SetPropert(PD_ORIENTATION , nOrientation)
        oSetup:SetPropert(PD_DESTINATION , nLocal)
        oSetup:SetPropert(PD_MARGIN      , {60,60,60,60})
        oSetup:SetPropert(PD_PAPERSIZE   , 2)
        oSetup:aOptions[PD_VALUETYPE] := cDestino
        oDanfe:setCopies(1)
        oDanfe:SetViewPDF(.F.)
        if !(findfunction("u_DANFE_P1"))
            cMsgErr := "006 - Fonte de impressão de DANFE não compilado!"
        else    
            u_DANFE_P1(cIdEnt ,/*cVal1*/ ,/*cVal2*/ ,oDanfe ,oSetup ,/*lIsLoja*/)
            cArq := cFilePrint + ".pdf"
        endif
        aNoUsrPerg := {}
        FreeObj(oDanfe)
        FreeObj(oSetup)
    endif
    if !empty(cMsgErr)
        u_autoAlert(cMsgErr)
    endif
    RestArea(aAreaSF2)
	RestArea(aArea)
return(cArq)

static function posicNF(cChv)
    local oSql  := LibSqlObj():newLibSqlObj()
    local nRec  := 0
    oSql:newTable("SF2", "R_E_C_N_O_ REC", "F2_CHVNFE = '" + cChv + "'")
    if oSql:hasRecords()
        nRec := oSql:getValue("REC")
    endif
    oSql:close()
	FreeObj(oSql)
return(nRec)

static function PergSendTssMail()
    local aParam  	:= {'1'+ Space(TamSx3("F2_SERIE")[1]-1),;
                         Space(TamSx3("F2_DOC")[1]),;
                         Replicate('Z', TamSx3("F2_DOC")[1]),;
                         Space(60),;
                         CToD(""),;
                         CToD(""),;
                         Space(TamSx3("A1_CGC")[1]),;
                         Replicate('Z',TamSx3("A1_CGC")[1]),;
                         '1'}
    local aRet      := {}
    local aPerg     := {}

    aadd(aPerg,{1,"Serie da NF",  aParam[01],"",".T.","",".T.",30,.F.})
    aadd(aPerg,{1,"NF Inicial",   aParam[02],"",".T.","",".T.",30,.F.})
    aadd(aPerg,{1,"NF Final",     aParam[03],"",".T.","",".T.",30,.F.})
    aadd(aPerg,{1,"Data Inicial", aParam[05],"",".T.","",".T.",50,.T.})
    aadd(aPerg,{1,"Data Final",   aParam[06],"",".T.","",".T.",50,.T.})
    aadd(aPerg,{1,"CNPJ Inicial", aParam[07],"",".T.","",".T.",50,.F.})
	aadd(aPerg,{1,"CNPJ Final",   aParam[08],"",".T.","",".T.",50,.F.})
    aadd(aPerg,{1,"Cc",           aParam[04],"",".T.","",".T.",50,.F.})
    aadd(aPerg,{3,"Status Email", aParam[09],{"Pendente","Transmitido","Erro"},50,"",.F.})
    //aadd(aPerg,{6,"Diretório de destino",   aParam[04],"",".T.","!Empty(mv_par04)",80,.T.,"Arquivos XML |*.XML","",GETF_RETDIRECTORY+GETF_LOCALHARD,.T.})

    if !(ParamBox(aPerg,"NFe - Reenviar E-mail",@aRet))
        aRet := {}
    else
        aAdd(aRet, GetTempPath()+ 'send_xml\')
    endif
return(aRet)

static function sendNFMail(aToSend, cCc, cDestino)
	local oEmail 	:= nil
    local lSend     := .F.
	local cAssunto  := "NFe Nacional"
    local nX        := 0
    local cSrvPath  := "\send_nfe\"
    local aCmps     := {}
    local aLoop     := {}
    local bErro		:= ErrorBlock({|oErr| HandleEr(oErr)})
	    
    oEmail := cbcSendEmail():newcbcSendEmail()
    BEGIN SEQUENCE
        for nX := 1 to len(aToSend)
            oEmail:iniSrvMsg()
            oEmail:setFrom('wf@cobrecom.com.br')
            oEmail:setcCc(Lower(AllTrim(cCc)))
            oEmail:setcBcc()
            oEmail:setcSubject(cAssunto)
            oEmail:setPriority(5)
            oEmail:setConfReader( .T. )
            aCmps     := {}
            aadd(aCmps, {'NFE_ID',  aToSend[nX, NFE_ID]})
            aadd(aCmps, {'CNPJ',    aToSend[nX, CNPJ]})
            aadd(aCmps, {'DOC_CHV', aToSend[nX, DOC_CHV]})
            aadd(aCmps, {'NFE_PROT',aToSend[nX, NFE_PROT]})        
            oEmail:setHtmlBody(cSrvPath + 'html\sendnfe.htm', aCmps, aLoop)
            if !oEmail:lOk	
                u_autoAlert(oEmail:cMsg)
            else
                if lTesteMode
                    cMail:= 'wfti@cobrecom.com.br'
                else
                    cMail:= Lower(AllTrim(aToSend[nX, 4]))
                endif            
                //XML
                if !empty(aToSend[nX, XML])
                    CpyT2S(cDestino + aToSend[nX, XML], cSrvPath, .F. )
                    oEmail:addAtach(cSrvPath, aToSend[nX, XML])
                endif
                //DANFe
                if !empty(aToSend[nX, DANFE])
                    CpyT2S(cDestino + aToSend[nX, DANFE], cSrvPath, .F. )
                    oEmail:addAtach(cSrvPath, aToSend[nX, DANFE])
                endif
                oEmail:setTo(cMail)
                if !(lSend := oEmail:goToEmail():lOk)
                    u_autoAlert(oEmail:cMsg)
                else
                    nEnviados++
                    chgStatus(aToSend[nX, 1])
                endIf
            endif
        next nX
        RECOVER
    END SEQUENCE
	ErrorBlock(bErro)
    eraseFiles(aToSend, cDestino, cSrvPath)
    FreeObj(oEmail)
return(lSend)

static function eraseFiles(aFiles, cDestino, cSrvPath)
    local nX := 0
    for nX := 1 to len(aFiles)
        if !empty(aFiles[nX])
            FErase(cDestino + aFiles[nX, XML])
            FErase(cSrvPath + aFiles[nX, XML])
            FErase(cDestino + aFiles[nX, DANFE])
            FErase(cSrvPath + aFiles[nX, DANFE])
        endif
    next nX
return(nil)

static function chgStatus(nRec)
    local cQry  := "UPDATE SPED050 SET STATUSMAIL = 2 FROM SPED050 WHERE R_E_C_N_O_ = " + cValToChar(nRec)
    if TcSqlExec(cQry) < 0
        u_autoAlert('008 - Email enviado, mas nao foi possivel atualizar o status para enviado!')
    endif
return(nil)

static function chgDataBase()
    local lRet      := .F.
    local lDo       := !lTssConnect

    if lDo
        if nHndOra < 0
            // Cria uma conexão com um outro banco, outro DBAcces
            nHndOra := TcLink( cDbOra, cSrvOra, 7890 )
            if nHndOra < 0
                UserException( "999 - Falha ao conectar com " + cDbOra + " em " + cSrvOra )
            else
                lTssConnect := .T.
            endif
        else
            // Volta para conexão TSS
            tcSetConn( nHndOra )
            lTssConnect := .T.
        endif
    else
        // Volta para conexão ERP
        tcSetConn( nHndERP )
        lTssConnect := .F.
    endif
return(lRet)

user function schTssMail()
    local aFil		:= FWAllFilial()
    local cEmpOrig	:= cEmpAnt
    local cFilOrig	:= cFilAnt
    local nX        := 0
    local aParam    := loadSchParam()

    for nX := 1 to len(aFil)
        altFilial(cEmpOrig, aFil[nX])
        if FwFilial() == aFil[nX]
            u_cbcSendTSSMail(,.T.,aParam)
        endif
    next nX
    altFilial(cEmpOrig, cFilOrig)
return(nil)

static function loadSchParam()
    local cPath     := GetTempPath()+ 'send_xml\'
    local aParam  	:= {'1'+ Space(TamSx3("F2_SERIE")[1]-1),;
                        Space(TamSx3("F2_DOC")[1]),;
                        Replicate('Z', TamSx3("F2_DOC")[1]),;
                        CToD("15/07/20"),;
                        dDataBase,;
                        Space(TamSx3("A1_CGC")[1]),;
                        Replicate('Z',TamSx3("A1_CGC")[1]),;
                        'alexandre.madeira@cobrecom.com.br',;
                        '3',;
                        cPath}
return(aParam)

static function altFilial(cEmp, cFil)	
	dbCloseAll()
	cEmpAnt := cEmp
	cFilAnt := cFil
	cNumEmp := cEmp+cFil
	OpenSm0(cNumEmp)
 	OpenFile(cNumEmp)
	lRefresh :=.T.
return(nil)

static function HandleEr(oErr)
    u_autoAlert('[SendTSSMail] - Erro: ' + AllTrim(oErr:Description))
    BREAK
return (nil)
