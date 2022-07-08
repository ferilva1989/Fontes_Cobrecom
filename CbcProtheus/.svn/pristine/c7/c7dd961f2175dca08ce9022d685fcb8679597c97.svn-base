#include 'protheus.ch'
#include 'parmtype.ch'
#include "FWMVCDEF.CH"
#include 'cbcOrdemSep.ch'
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "rwmake.ch"

static function cbcPrtOS(cOS, lJoined)
    local aArea    	    := GetArea()
    local aAreaSA1	    := SA1->(getArea())  
    local aAreaSA2	    := SA2->(getArea())  
    local aAreaSC6	    := SC6->(getArea())  
	local aAreaSC5	    := SC5->(getArea())        
    default lJoined     := .F.
    
    initPrinter(cOS, lJoined)
    
    RestArea(aAreaSA1)
	RestArea(aAreaSA2)
    RestArea(aAreaSC6)
    RestArea(aAreaSC5)
	RestArea(aArea)
return(nil)

static function initPrinter(cOS, lJoined)
    local cFileName     := "CBCOrdSep_"+ AllTrim(cOS) + dToS(Date()) + "_" + StrTran(Time(), ':', '-')
    private oPrn        := nil
    private lValorFat	:= .F.
    private lImpCb		:= .F.
    private nLin 		:= 0
    private oFont10N	:= TFont():New( "Arial",,10,,.T.,,,,.T.,.F.)
	private oFont11N	:= TFont():New( "Arial",,11,,.T.,,,,.T.,.F.)
	private oFont12 	:= TFont():New( "Arial",,12,,.T.,,,,   ,.F.)
	private oFont12N	:= TFont():New( "Arial",,12,,.T.,,,,.T.,.F.)
	private oFont14N	:= TFont():New( "Arial",,14,,.T.,,,,.T.,.F.)
	private oFont16N	:= TFont():New( "Arial",,16,,.T.,,,,.T.,.F.)
	private oFont18N	:= TFont():New( "Arial",,18,,.T.,,,,.T.,.F.)	
	private Cabec1      := ""
	private Cabec2     	:= ""

    oPrn := FWMsPrinter():New(cFileName, IMP_PDF, .T., "\OrdSep\", .T.,,,, .T.)
    oPrn:SetLandscape()// Formato pagina Paisagem
    oPrn:SetPaperSize(9)//Papel A4
    oPrn:SetMargin(((05 / 25.4) * 300),((05 / 25.4) * 300),((05 / 25.4) * 300),((05 / 25.4) * 300))
    oPrn:SetViewPDF(.T.)
    if lJoined
        printJoined(cOS)
    else
        printLegacy(cOS)
    endif
    oPrn:EndPage()
    oPrn:Preview()
    FreeObj(oPrn)
return(nil)

static function printLegacy(cOS)
    local aArea    	    := GetArea()
	local aAreaSC5	    := SC5->(getArea())
    local aItems        := getOsItems(cOS, .F.)
    local nRecC5        := getRecC5(cOS, .F.)
    Local oStatic       := IfcXFun():newIfcXFun()

    if !empty(aItems) .and. !empty(nRecC5)
        dbSelectArea('SC5')
        SC5->(DbGoTo(nRecC5))
        oStatic:sP(1):callStatic('CBCOrSep', 'ImprAItens', aItems)
    endif    
    RestArea(aAreaSC5)
	RestArea(aArea)
return(nil)

static function printJoined(cOS)
    local aJoinCab  := {cOS, getJoinCab(cOS)}
    local aItems    := getOsItems(cOS, .T.)
    Local oStatic   := IfcXFun():newIfcXFun()

    if !empty(aJoinCab[2]) .and. !empty(aItems)
         oStatic:sP(2):callStatic('CBCOrSep', 'ImprAItens', aItems, aJoinCab)
    endif
return(nil)

static function getJoinCab(cOS)
    local aDados := {}
    local aPeds  := getRecC5(cOS, .T.)
    local nX     := 0
    local cCliFor:= ''
    local cFldC  := ''
    local cPedi  := 'OSs Aglutinadas: '

    if(AllTrim((cAls)->TP) $ 'DB')
        cCliFor := 'SA2'        
    else
        cCliFor := 'SA1'
    endif
    DbSelectArea(cCliFor)
    (cCliFor)->(DbSetOrder(1))
    if ((cCliFor)->(DbSeek(xFilial(cCliFor) + AllTrim((cAls)->CLI),.F.)))
        cFldC := SubStr(cCliFor, 2,2)
        aAdd(aDados, iif(cCliFor == 'SA1',  "CLIENTE : ", "FORNECEDOR: ") + '[' + AllTrim((cAls)->CLI) + '] - ' + AllTrim((cAls)->NOME))
        aAdd(aDados, "CNPJ/CPF: " + cValToChar((cCliFor)->&(cFldC + '_CGC')))
        aAdd(aDados, 'LOCAL FAT: ')
        aAdd(aDados, "CIDADE: " + (cCliFor)->&(cFldC + '_MUN'))
        aAdd(aDados, "UF: " + (cCliFor)->&(cFldC + '_EST'))
        for nX := 1 to len(aPeds)
            cPedi += aPeds[nX, 2] + '-' + aPeds[nX, 3]
            if nX < len(aPeds)
                cPedi += '||'
            endif
        next nX        
        aAdd(aDados, cPedi)
    endif
return(aDados)

static function getRecC5(cOS, lJoined)
    local xRet := nil
    local oSql := LibSqlObj():newLibSqlObj()
    
    if lJoined
        xRet := {}
    else
        xRet := 0
    endif

    oSql:newAlias(qryRecC5(cOS, lJoined))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            if lJoined
                aAdd(xRet, {oSql:getValue('REC'), oSql:getValue('PED'), oSql:getValue('SEQ')})
            else
                xRet := oSql:getValue('REC')
                exit
            endif
            oSql:skip()
        endDo
    endif
    oSql:Close()    
    FreeObj(oSql)
return(xRet)

static function getOsItems(cOS, lJoined)
    local aArea    	:= GetArea()
    local aOrdem    := ARR_ORDENA
    local cOrdem    := ''
    local nPosi     := 0
    local aItems    := {}
    local oSql      := LibSqlObj():newLibSqlObj()

    oSql:newAlias(qryPrintOs(AllTrim(cOS), lJoined))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
            cOrdem := ''
            if ((nPosi := AScan(aOrdem, {|x| AllTrim(oSql:getValue('ACOND')) == x[1]})) == 0)
                nPosi := AScan(aOrdem, {|x| Left(AllTrim(oSql:getValue('ACOND')), 1) == x[1]})
            endif       
            cOrdem := StrZero(iif(nPosi == 0, 6, aOrdem[nPosi, 2]), 2)
            if !empty(oSql:getValue('NROBOB'))
                cOrdem += AllTrim(oSql:getValue('TPBOB')) + Right(AllTrim(oSql:getValue('NROBOB')), 1) + AllTrim(oSql:getValue('NROBOB'))
            endif
            Aadd(aItems,{	AllTrim(oSql:getValue('PROD')),;
						    AllTrim(oSql:getValue('ACOND')),;
						    oSql:getValue('QTD'),;
						    oSql:getValue('PRC'),;
						    oSql:getValue('COBRE'),;
						    0.00,;
						    AllTrim(oSql:getValue('ITEMPV')),;
						    AllTrim(oSql:getValue('TPBOB')),;
						    AllTrim(oSql:getValue('NROBOB')),;
						    oSql:getValue('PESO'),;
						    oSql:getValue('CAIXAS'),;
						    cOrdem,;
						    AllTrim(oSql:getValue('LOCAL')),;
                            AllTrim(oSql:getValue('BARINT')),;
                            AllTrim(oSql:getValue('CLI')),;
                            AllTrim(oSql:getValue('DESCRI')),;
                            oSql:getValue('LANCES')})
            oSql:skip()
        endDo
    endif
    oSql:Close()
    
    FreeObj(oSql)
    RestArea(aArea)
return(aItems)

static function qryPrintOs(cOS, lJoined)
    local cQry      := ''
    default cOS     := ''
    default lJoined  := .F.

    cQry += " SELECT ZZR.ZZR_PRODUT AS [PROD], "
    cQry += " ZZR.ZZR_LOCALI AS [ACOND], "
    cQry += " SUM(ZZR.ZZR_QUAN) AS [QTD], "
    cQry += " AVG(SC6.C6_PRCVEN) AS [PRC], "
    cQry += " SUM(ZZR.ZZR_QUAN * SB1.B1_PESCOB) AS [COBRE], "
    if !lJoined
        cQry += " ZZR.ZZR_ITEMPV AS [ITEMPV], "
    else
        cQry += " 'XX' AS [ITEMPV], "
    endif
    cQry += " CASE  "
    cQry += " 	WHEN ZZR.ZZR_NROBOB <> '' "
    cQry += " 		THEN ISNULL(SZE.ZE_TPBOB, '') "
    cQry += " 	ELSE "
    cQry += " 		ZZR.ZZR_NROBOB "
    cQry += " END AS [TPBOB], "
    cQry += " ZZR.ZZR_NROBOB AS [NROBOB], "
    cQry += " SUM(ZZR.ZZR_EMBALA+ZZR.ZZR_PESPRO) AS [PESO], "
    cQry += " CASE "
    cQry += " 	WHEN ZZR.ZZR_QTCAIX > 1 "
    cQry += " 		THEN SUM(ZZR.ZZR_LANCES / ZZR.ZZR_QTCAIX) "
    cQry += " 	ELSE 0 "
    cQry += " END AS [CAIXAS], "
    cQry += " ZZR.ZZR_LOCAL AS [LOCAL], "    
    cQry += " ZZR.ZZR_BARINT AS [BARINT], "
    cQry += " '['+ SA1.A1_COD + SA1.A1_LOJA +']-' + RTRIM(LTRIM(SA1.A1_NOME)) AS [CLI], "
    cQry += " ZZR.ZZR_DESCRI AS [DESCRI], "
    cQry += " SUM(ZZR.ZZR_LANCES) AS [LANCES] "
    cQry += " FROM " + RetSqlName('ZZR') + " ZZR "
    cQry += " INNER JOIN " + RetSqlName('SC6') + " SC6 ON ZZR.ZZR_FILIAL = SC6.C6_FILIAL "
    cQry += " 								AND ZZR.ZZR_PEDIDO = SC6.C6_NUM "
    cQry += " 								AND ZZR.ZZR_ITEMPV = SC6.C6_ITEM "
    cQry += " 								AND ZZR.D_E_L_E_T_ = SC6.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SB1') + " SB1 ON ZZR.ZZR_PRODUT = SB1.B1_COD "
    cQry += " 						AND ZZR.D_E_L_E_T_ = SB1.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SA1') + " SA1 ON SC6.C6_CLI = SA1.A1_COD "
    cQry += " 						AND SC6.C6_LOJA = SA1.A1_LOJA "
    cQry += " 						AND SC6.D_E_L_E_T_ = SA1.D_E_L_E_T_ "
    cQry += " LEFT JOIN " + RetSqlName('SZE') + " SZE ON ZZR.ZZR_FILIAL = SZE.ZE_FILIAL "
    cQry += " 						AND ZZR.ZZR_NROBOB = SZE.ZE_NUMBOB "
    cQry += " 						AND ZZR.ZZR_PEDIDO = SZE.ZE_PEDIDO "
    cQry += " 						AND ZZR.ZZR_ITEMPV = SZE.ZE_ITEM "
    cQry += " 						AND ZZR.D_E_L_E_T_ = SZE.D_E_L_E_T_ "
    cQry += " WHERE ZZR.ZZR_FILIAL = '" + xFilial('ZZR') + "' "
    cQry += " AND ZZR.ZZR_OS = '" + cOS + "' "
    //cQry += " AND ZZR.ZZR_DATA >= '20180101' "
    cQry += " AND ZZR.D_E_L_E_T_ = ''    "
    cQry += " GROUP BY ZZR.ZZR_PRODUT, ZZR.ZZR_LOCALI, ZZR.ZZR_NROBOB, ISNULL(SZE.ZE_TPBOB, ''),ZZR.ZZR_QTCAIX, ZZR.ZZR_LOCAL, ZZR.ZZR_BARINT, "
    cQry += " SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, ZZR.ZZR_DESCRI "
    if !lJoined
        cQry += ", ZZR.ZZR_ITEMPV " 
    endif
return(cQry)

static function qryRecC5(cOS, lJoined)
    local cQry  := ''
    default cOS := ''

    cQry += " SELECT SC5.R_E_C_N_O_ AS [REC], "
    cQry += " SC5.C5_NUM AS [PED], "
    cQry += " ZZR.ZZR_SEQOS AS [SEQ] "
    cQry += " FROM " + RetSqlName('ZZR') + " ZZR "
    cQry += " INNER JOIN " + RetSqlName('SC5') + " SC5 ON ZZR.ZZR_FILIAL = SC5.C5_FILIAL "
    cQry += " 						AND ZZR.ZZR_PEDIDO = SC5.C5_NUM "
    cQry += " 						AND ZZR.D_E_L_E_T_ = SC5.D_E_L_E_T_ "
    cQry += " WHERE ZZR.ZZR_FILIAL = '" + xFilial('ZZR') + "' "
    cQry += " AND ZZR.ZZR_OS = '" + cOS + "' "
    cQry += " AND ZZR.D_E_L_E_T_ = '' "
    cQry += " GROUP BY SC5.R_E_C_N_O_, SC5.C5_NUM, ZZR.ZZR_SEQOS "
   
return(cQry)
