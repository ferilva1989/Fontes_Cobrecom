#include 'Totvs.ch'

user function cbcTaxPortal(cJsData)
    local oJsData   := JsonObject():new()
    local oRetorno  := JsonObject():new()
    private cCli    := ""
    private cLoj    := ""
    private oChange := oChange := cbcChgAlias():newcbcChgAlias(.F.)  
    private oFil    := cbcFiliais():newcbcFiliais()  
    default cJsData := ""

    if !empty(cJsData)
        oJsData:FromJson(cJsData)
    endif

    if !empty(oJsData:GetNames())
        if ValType(oJsData:GetJsonObject('CLI')) <> 'U' .and. ValType(oJsData:GetJsonObject('ITEMS')) == 'A'
            if !empty(oJsData['ITEMS'])
                if defCliente(@oJsData['CLI'])
                    defFilial()
                    oRetorno := calcTax(oJsData)
                endif
            endif
        endif
    endif

    oChange:destroy()
    FreeObj(oChange)

    oFil:backFil()
    FreeObj(oFil)
return(oRetorno:ToJson())

static function defCliente(oJsSA1)
    local lSimula     := .F.
    local lRet        := .T.
    private cCodPdr   := AllTrim(GetNewPar('ZZ_CLIPADR', '00000000'))
    if ValType(oJsSA1:GetJsonObject('A1_COD')) <> 'U'
        cCli := AllTrim(oJsSA1['A1_COD'])
    endif
    if ValType(oJsSA1:GetJsonObject('A1_LOJA')) <> 'U'
        cLoj := AllTrim(oJsSA1['A1_LOJA'])
    endif
    lSimula :=  (empty(cCli) .or. empty(cLoj) .or. (cCli + cLoj == cCodPdr))
    if lSimula
        cCli := SubStr(cCodPdr, 1, TamSX3('A1_COD')[1])
        cLoj := SubStr(cCodPdr, TamSX3('A1_COD')[1] + 1)
        lRet := prepSA1(@oJsSA1)
    else
        DbSelectArea("SA1")
        SA1->(dbSetOrder(1))
        lRet := (SA1->(DbSeek(xFilial("SA1")+PadR(cCli,TamSX3('A1_COD')[1])+PadR(cLoj,TamSX3('A1_LOJA')[1]), .F.)))
    endif
return(lRet)

static function prepSA1(oJsSA1)
    local oDados := JsonObject():new()
    local lRet   := .F.
    if validSA1(@oJsSA1)
        oDados['SA1'] := oJsSA1:ToJson()
        lRet := oChange:work(oDados:ToJson()):isOk()
    endif
    FreeObj(oDados)
return(lRet)

static function validSA1(oJsSA1)
    local aJsNames  := oJsSA1:GetNames()
    local nX        := 0
    local nPosi     := 0
    local lVld      := .T.
    local aCmpsObr  := {;
                        "A1_XREIDI","A1_CALCSUF","A1_SIMPNAC",;
                        "A1_INSCR","A1_EST", "A1_CGC",;
                        "A1_CONTRUT", "A1_TIPO", "A1_ZZIMPOR",; 
                        "A1_PESSOA", "A1_CONTRIB"}
    local aCmpsPdr  := {;
                        {"A1_FILIAL", xFilial('SA1')},;
                        {"A1_COD", SubStr(cCodPdr, 1, TamSX3('A1_COD')[1])},;
                        {"A1_LOJA", SubStr(cCodPdr, TamSX3('A1_COD')[1] + 1)},;
                        {"A1_TES",""},;
                        {"A1_GRPTRIB",""},;
                        {"A1_COD_MUN",""},;
                        {"A1_SUFRAMA",""},;
                        {"A1_INSCRUR",""},;
                        {"A1_RECINSS",""},;
                        {"A1_FRETISS",""},;
                        {"A1_RECIRRF",""},;
                        {"A1_TPJ",""},;
                        {"A1_PERFECP",0},;
                        {"A1_IDHIST",""},;
                        {"A1_TPESSOA",""},;
                        {"A1_REGESIM",""},;
                        {"A1_PERCATM",0},;
                        {"A1_CRDMA",""},;
                        {"A1_SIMPLES",""},;
                        {"A1_CDRDES",""},;
                        {"A1_ALIQIR",0},;
                        {"A1_RECPIS","N"},;
                        {"A1_RECCOFI","N"},;
                        {"A1_RECCSLL","N"},;
                        {"A1_ZZUNFAT", Padr("3",TamSX3('A1_ZZUNFAT')[1])},;
                        {"A1_ZZDIVCL", "S"},;
                        {"A1_NREDUZ", ""},;
                        {"A1_RECISS",""}}

    for nX := 1 to len(aJsNames)
        nPosi := AScan( aCmpsObr, {|x| x == AllTrim(aJsNames[nX])} )
        if nPosi > 0
            //if !empty(oJsSA1[aJsNames[nX]])
                aDel(aCmpsObr, nPosi)
                aSize(aCmpsObr,(len(aCmpsObr)-1))
            //endif
        endif
    next nX

    lVld := empty(aCmpsObr)

    if lVld
        for nX := 1 to len(aCmpsPdr)
            if ValType(oJsSA1:GetJsonObject(aCmpsPdr[nX, 01])) == 'U'
                oJsSA1[aCmpsPdr[nX, 01]] := aCmpsPdr[nX, 02]
            endif
        next nX
        if ValType(oJsSA1:GetJsonObject('INDEX')) == 'U'
            oJsSA1['INDEX'] := {'A1_FILIAL','A1_COD','A1_LOJA'}
        endif
    endif
return(lVld)

static function defFilial()
    Local oStatic   := IfcXFun():newIfcXFun()
    local cFili     := oStatic:sP(1):callStatic('cbcSrvPortal', 'defFilial')

	if !empty(cFili)
		oFil:setFilial(cFili)
    endif
return(nil)

static function calcTax(oJsData)
    local aArea    	 := GetArea()
    local aAreaSA1   := SA1->(GetArea())
    local cTes       := ""
    local aRet       := {}
    local oRet       := JsonObject():new()

    DbSelectArea("SA1")
    SA1->(dbSetOrder(1))
    SA1->(DbSeek(xFilial("SA1")+PadR(cCli,TamSX3('A1_COD')[1])+PadR(cLoj,TamSX3('A1_LOJA')[1])), .F.)
    cTes := u_CDTesInt()
    MaFisIni(SA1->A1_COD,;                      // 01 - Codigo Cliente/Fornecedor
    SA1->A1_LOJA,;                              // 02 - Loja do Cliente/Fornecedor
    "C",;                                       // 03 - C:Cliente , F:Fornecedor
    "N",;                                       // 04 - Tipo da NF
    SA1->A1_TIPO,;                     	        // 05 - Tipo do Cliente/Fornecedor (F R S)
    MaFisRelImp("MT100", {"SF2", "SD2"}),;      // 06 - Relacao de Impostos que suportados no arquivo
    nil,;                                       // 07 - Tipo de complemento
    nil,;                                       // 08 - Permite Incluir Impostos no Rodape .T./.F.
    "SB1",;                                     // 09 - Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
    "MATA461",;                                 // 10 - Nome da rotina que esta utilizando a funcao
    nil,;                                       // 11 - Tipo documento
    nil,)                                       // 12 - Especie 
    
    aRet := calcItems(oJsData['ITEMS'], cTes)
    
    if aRet[1]
        oRet := mntRetorno(oJsData['ITEMS'])
    endif    
    
    MaFisEnd()

    FreeObj(aAreaSA1)
    FreeObj(aArea)
return(oRet)

static function calcItems(oJsItems, cTes)
	local aArea   	 := getArea()
	local aAreaSF4 	 := getArea('SF4')
    local aAreaSB1 	 := getArea('SB1')
    local nX         := 0

    DbSelectArea('SB1')
    SB1->(dbSetOrder(1))
    
    DbSelectArea('SF4')
    SF4->(dbSetOrder(1))
    if !(SF4->(DbSeek(xFilial("SF4")+PadR(cTes,TamSX3('F4_CODIGO')[1]), .F.)))
        return({.F., AllTrim(cTes) + ' - TES não localizado na Tabela SF4!'})
    endif
    for nX := 1 to len(oJsItems)
        if ValType(oJsItems[nX]:GetJsonObject('COD')) == 'U'
            return({.F., 'Código do Produto não localizado no JSON!'})
        endif
        if !(SB1->(DbSeek(xFilial("SB1")+oJsItems[nX]['COD'], .F.)))
            return({.F., AllTrim(oJsItems[nX]['COD']) + ' - Produto não localizado na Tabela SB1!'})
        endif
        MaFisAdd(PadR(oJsItems[nX]['COD'], TamSx3('B1_COD')[1]),;         // 01 - Codigo do Produto                    ( Obrigatorio )
        PadR(cTes,TamSX3('F4_CODIGO')[1]),;					// 02 - Codigo do TES                        ( Opcional )
        oJsItems[nX]['QTD'],;                // 03 - Quantidade                           ( Obrigatorio )
        oJsItems[nX]['PRCUNIT'],;              // 04 - Preco Unitario                       ( Obrigatorio )
        0,;                                     // 05 - Desconto
        '',;                                    // 06 - Numero da NF Original                ( Devolucao/Benef )
        '',;                                    // 07 - Serie da NF Original                 ( Devolucao/Benef )
        0,;                                     // 08 - RecNo da NF Original no arq SD1/SD2
        0,;                                     // 09 - Valor do Frete do Item               ( Opcional )
        0,;                                     // 10 - Valor da Despesa do item             ( Opcional )
        0,;                                     // 11 - Valor do Seguro do item              ( Opcional )
        0,;                                     // 12 - Valor do Frete Autonomo              ( Opcional )
        oJsItems[nX]['TOTAL'],;                // 13 - Valor da Mercadoria                  ( Obrigatorio )
        0,;                                     // 14 - Valor da Embalagem                   ( Opcional )
        SB1->(RecNo()),;                        // 15 - RecNo do SB1
        SF4->(RecNo()))                         // 16 - RecNo do SF4
        
        MaFisLoad("IT_VALMERC", oJsItems[nX]['TOTAL'], nX)
        // MaFisAlt("IT_PESO",     (oJsItems[nX]['QTD'] * SB1->B1_PESO), nX)
    next nX
    restArea(aAreaSB1)
    restArea(aAreaSF4)
	restArea(aArea)
return({.T.,''})

static function mntRetorno(oJsItems)
    local oRet   := JsonObject():new()
    local oItem  := nil
    local aItems := {}
    local nX     := 0

    for nX := 1 to len(oJsItems)
        oItem := JsonObject():new()
        oItem["Cod"]         := oJsItems[nX]:GetJsonObject('COD')
        oItem["Qtd"]         := MaFisRet(nX, "IT_QUANT")
        oItem["PrcUnit"]     := MaFisRet(nX,"IT_PRCUNI")
        oItem["AliqIcm"]     := MaFisRet(nX,"IT_ALIQICM")
        oItem["ValIcm"]      := MaFisRet(nX,"IT_VALICM" )
        oItem["BaseIcm"]     := MaFisRet(nX,"IT_BASEICM")
        oItem["ValSol"]      := MaFisRet(nX,"IT_VALSOL" )
        oItem["ValMerc"]     := MaFisRet(nX,"IT_VALMERC")
        oItem["ValComple"]   := MaFisRet(nX,"IT_VALCMP" )// Valor ICMS Complementar
        oItem["ValDifal"]    := MaFisRet(nX,"IT_DIFAL") // Valor ICMS Complementar da UF de Origem
        aAdd(aItems, oItem)
        FreeObj(oItem)
    next nX

    oRet["TotalMerc"]   := MaFisRet(,"NF_VALMERC") //Total de Mercadorias
    oRet["ValComple"]   := MaFisRet(,"NF_VALCMP") //Valor do Icms Complementar
    oRet["ValBaseIcm"]  := MaFisRet(,"NF_BASEICM") //Valor da Base de ICMS
    oRet["ValIcm"]      := MaFisRet(,"NF_VALICM") //Valor do ICMS Normal
    oRet["ValBaseSoli"] := MaFisRet(,"NF_BASESOL") //Base do ICMS Solidario
    oRet["ValSoli"]     := MaFisRet(,"NF_VALSOL") //Valor do ICMS Solidario
    oRet["Total"]       := MaFisRet(,"NF_TOTAL") //Valor Total da NF
    oRet["aImpostos"]   := MaFisRet(,"NF_IMPOSTOS2") //Array contendo todos os impostos calculados na funcao ?Fiscal com quebras por impostos
    oRet["Items"]       := aItems
    oRet["Filial"]      := FwFilial()
return(oRet)

user function ztstTaxPortal()
    local oDados := JsonObject():new()

    oDados:FromJson(getTstJson())
    u_cbcTaxPortal(oDados:ToJson())
    FreeObj(oDados)
return(nil)

static function getTstJson()
    local cJson := '{'
    //000090143 - TL
    cJson += '	"CLI": {'
    cJson += '		"A1_XREIDI" : "",'
    cJson += '		"A1_CALCSUF" : "",'
    cJson += '		"A1_SIMPNAC" : "2",'
    cJson += '		"A1_INSCR" : "77080260",'
    //cJson += '		"A1_COD": "000000",'
    //cJson += '		"A1_LOJA": "00",'
    cJson += '		"A1_COD": "003277",'
    cJson += '		"A1_LOJA": "01",'
    cJson += '		"A1_EST": "RJ",'
    cJson += '		"A1_CGC": "04062944000144",'
    cJson += '		"A1_CONTRUT": "N",'
    cJson += '		"A1_TIPO": "R",'
    cJson += '		"A1_ZZIMPOR": "2",'
    cJson += '		"A1_PESSOA": "J",'
    cJson += '		"A1_CONTRIB": "1"'
    cJson += '	},'
    cJson += '	"ITEMS": [{"COD":"1320104401", "QTD":5000, "PRCUNIT":1.27, "TOTAL": 6350},'
    cJson += ' {"COD":"1530404401", "QTD":1000, "PRCUNIT":3.49, "TOTAL": 3490},'
    cJson += ' {"COD":"1530404401", "QTD":5000, "PRCUNIT":3.49, "TOTAL": 17450}]'
    cJson += '}'
    
    /*
    //000278908 - ITU
    cJson += '	"CLI": {'
    cJson += '		"A1_XREIDI" : "",'
    cJson += '		"A1_CALCSUF" : "",'
    cJson += '		"A1_SIMPNAC" : "2",'
    cJson += '		"A1_INSCR" : "165319207110",'
    cJson += '		"A1_COD": "000000",'
    cJson += '		"A1_LOJA": "00",'
    //cJson += '		"A1_COD": "004746",'
    //cJson += '		"A1_LOJA": "01",'
    cJson += '		"A1_EST": "SP",'
    cJson += '		"A1_CGC": "05582114000100",'
    cJson += '		"A1_CONTRUT": "N",'
    cJson += '		"A1_TIPO": "S",'
    cJson += '		"A1_ZZIMPOR": "2",'
    cJson += '		"A1_PESSOA": "J",'
    cJson += '		"A1_CONTRIB": "1"'
    cJson += '	},'
    cJson += '	"ITEMS": [{"COD":"1530504401", "QTD":2000, "PRCUNIT":5.7, "TOTAL": 11400},'
    cJson += ' {"COD":"1530704401", "QTD":1000, "PRCUNIT":12.6, "TOTAL": 12600}]'
    cJson += '}'
    */
return(cJson)
