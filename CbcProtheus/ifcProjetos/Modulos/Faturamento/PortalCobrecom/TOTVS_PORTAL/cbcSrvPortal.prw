#include 'Totvs.ch'

user function cbcFiliFat(cJsSA1)
    local cFili     := ""
    local oJsSA1    := JsonObject():new()
    local lOk       := .T.
    private cCli    := ""
    private cLoj    := ""
    private cCodPdr := AllTrim(GetNewPar('ZZ_CLIPADR', '00000000'))
    private oChange := oChange := cbcChgAlias():newcbcChgAlias(.F.)    
    default cJsSA1  := ""

    if !empty(cJsSA1)
        oJsSA1:FromJson(cJsSA1)
        if !empty(oJsSA1:GetNames())
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
                lOk := prepSA1(oJsSA1)
            endif
            if lOk
                cFili := defFilial()
            endif
            oChange:destroy()
        endif
    endif
    FreeObj(oChange)
return(cFili)

static function prepSA1(oJsSA1)
    local oDados := JsonObject():new()
    local lRet   := .F.
    if validJson(@oJsSA1)
        oDados['SA1'] := oJsSA1:ToJson()
        lRet := oChange:work(oDados:ToJson()):isOk()
    endif
    FreeObj(oDados)
return(lRet)

static function validJson(oJsSA1)
    local aJsNames  := oJsSA1:GetNames()
    local nX        := 0
    local nPosi     := 0
    local aCmpsObr  := {"A1_EST", "A1_CGC", "A1_CONTRUT", "A1_TIPO", "A1_ZZIMPOR", "A1_PESSOA", "A1_CONTRIB"}

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
        if ValType(oJsSA1:GetJsonObject('A1_FILIAL')) == 'U'
            oJsSA1['A1_FILIAL'] := xFilial('SA1')
        endif
        if ValType(oJsSA1:GetJsonObject('A1_COD')) == 'U'
            oJsSA1['A1_COD'] := Padr(cCli, TamSx3('A1_COD')[1])
        endif
        if ValType(oJsSA1:GetJsonObject('A1_LOJA')) == 'U'
            oJsSA1['A1_LOJA'] := Padr(cLoj,TamSx3('A1_LOJA')[1])
        endif
        if ValType(oJsSA1:GetJsonObject('A1_ZZUNFAT')) == 'U'
            oJsSA1['A1_ZZUNFAT'] := Padr("3",TamSX3('A1_ZZUNFAT')[1])
        endif
        if ValType(oJsSA1:GetJsonObject('A1_ZZDIVCL')) == 'U'
            oJsSA1['A1_ZZDIVCL'] := Padr("S",TamSX3('A1_ZZDIVCL')[1])
        endif
        if ValType(oJsSA1:GetJsonObject('INDEX')) == 'U'
            oJsSA1['INDEX'] := {'A1_FILIAL','A1_COD','A1_LOJA'}
        endif
    endif
return(lVld)

static function defFilial()
	local oRule		:= Nil 
	local cFilFat	:= ""

    //ConsoleLog('Definindo filial de faturamento')
    cCli 	:= Padr(cCli, TamSx3('A1_COD')[1])
    cLoj	:= Padr(cLoj,TamSx3('A1_LOJA')[1])
    oRule 	:= CbcIndRules():newCbcIndRules(cCli, cLoj)

    if !oRule:lOk .And. !oRule:lVldCli
        ConsoleLog('Filial de Faturamento nao loclaizada - cbcFiliFat ' +  oRule:cMsgErr)
    else
        cFilFat := oRule:BillingBranch()
    endif
    FreeObj(oRule)
return(cFilFat)

user function ztstFiliFat()
    local oDados := JsonObject():new()
    local cFili  := ""

    //oDados["A1_COD"]        := "033934"
    //oDados["A1_LOJA"]       := "01"
    oDados["A1_EST"]        := "PB"
    oDados["A1_CGC"]        := "09046825000111"
    oDados["A1_CONTRUT"]    := "N"
    oDados["A1_TIPO"]       := "R"
    oDados["A1_ZZIMPOR"]    := "2"
    oDados["A1_PESSOA"]     := "J"
    oDados["A1_CONTRUT"]    := "N"
    oDados["A1_CONTRIB"]    := "1"
    cFili := u_cbcFiliFat(oDados:ToJson())
    if empty(cFili)
        alert('Filial não definida!')
    else
        MsgInfo('Filial: ' + cFili, 'Filial Definida')
    endif
    FreeObj(oDados)
return(nil)
