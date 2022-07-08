#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'
#INCLUDE 'FWMVCDEF.CH'


wsRestful cbcWsNcm DESCRIPTION "API Rest para manutencao de NCM na tabela SYD"	
	wsMethod POST description "Rotas POST: /insert"
    wsMethod DELETE description "Rotas DELETE: /remove"
end wsRestful


wsMethod POST wsService cbcWsNcm
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	If (cRoute == "insert")
		lOk := doProcess(self, "insert")			
	Else	
		oResponse:notFound("Rota invalida")		
	EndIf
Return lOk

wsMethod DELETE wsService cbcWsNcm
	local lOk		:= .F.
	local cRoute	:= ""
	local oRequest  := LibWsRestRequestObj():newLibWsRestRequestObj(self)
	local oResponse	:= LibWsRestResponseObj():newLibWsRestResponseObj(self)
	
	cRoute := oRequest:getRoute()
	
	If (cRoute == "remove")
		lOk := doProcess(self, "remove")			
	Else	
		oResponse:notFound("Rota invalida")		
	EndIf
Return lOk

Static Function doProcess(oWs, cProcess)
	Local lOk		:= .F.
    Local nX        := 0
    Local aRet      := {}
    Local aDados    := {}
    Local oBody     := JsonObject():new()
	Local oResponse := LibWsRestResponseObj():newLibWsRestResponseObj(oWs)
	
	oBody:fromJson(oWs:getContent())
    Aadd(aDados, {'NCM', 'DESC', 'IPI'})

    For nX := 1 to Len(oBody)
        Aadd(aDados, { oBody[nX][aDados[1][1]], oBody[nX][aDados[1][2]], oBody[nX][aDados[1][3]] })
    Next

    If cProcess == "remove"
        aRet := delNcm(aDados)
    Else
        aRet := impNCM(aDados)
    EndIf

	If aRet[1]
		lOk    := .T.
		oResponse:send('{ "code": "200", "Status": "Sucesso" }')
	Else
        lOk    := .F.
		oResponse:badRequest('{ "Erro": "' + aRet[2] + '" }') 		  		
	EndIf
Return lOk


Static Function impNCM(aDados)
    Local oModel    := FWLoadModel('cbcMdlSYD')
    Local aArea     := GetArea()
    Local aRet      := { .F., ""}
    Local nX        := 0
    Local nPosNcm   := 0
    Local nPosAliq  := 0
    Local nPosDesc  := 0
    Local dData     := dDataBase
    Local cNcmPont  := ""
    Local cAliqIpi  := ""
    Local cNcm      := "NCM"
    Local cAliq     := "IPI"
    Local cDesc     := "DESC"
    local cIDModel	:= "SYDMASTER"
    Local cTime     := Time()
    Local bErro     := ErrorBlock({|e| ConOut("Mensagem de Erro: " +chr(10)+ e:Description)})
    Default aDados  := {}

    BEGIN SEQUENCE 
    nPosNcm  := AScan(aDados[1],{ |x| Alltrim(UPPER(x)) == cNcm })
    nPosAliq := AScan(aDados[1],{ |x| Alltrim(UPPER(x)) == cAliq })
    nPosDesc := AScan(aDados[1],{ |x| Alltrim(UPPER(x)) == cDesc })

    If nPosNcm > 0 .And. nPosAliq > 0
        DBSelectArea("SYD")
        DbGotop()
        BEGIN TRANSACTION
            For nX := 2 to Len(aDados)
                cNcmPont := STRTRAN(aDados[nX][nPosNcm], ".", "")
                If Len(cNcmPont) == 8
                    If Alltrim(aDados[nX][nPosAliq]) == "NT" .Or. EMPTY(aDados[nX][nPosAliq])
                        cAliqIpi := "0"
                    Else
                        cAliqIpi := Alltrim(aDados[nX][nPosAliq])
                    EndIf
                    If DbSeek(xFilial("SYD")+cNcmPont)
                        If Alltrim(STR(SYD->YD_PER_IPI)) == cAliqIpi
                            aRet[1] := .T.
                            Loop
                        EndIf
                        oModel:SetOperation(MODEL_OPERATION_UPDATE)
                        oModel:Activate()
                        oModel:SetValue(cIDModel,'YD_PER_IPI', Val(cAliqIpi))
                        oModel:SetValue(cIDModel,'YD_DESC_P', DecodeUTF8(LTrim(aDados[nX][nPosDesc]), "cp1252"))
                        oModel:SetValue(cIDModel,'YD_GRVUSER', IIF(Empty(RetCodUsr()), 'WSREST', UsrRetName(RetCodUsr())))
                        oModel:SetValue(cIDModel,'YD_GRVDATA', dData)
                        oModel:SetValue(cIDModel,'YD_GRVHORA', cTime)
                        If !(aRet := updB2Ncm(cNcmPont,cAliqIpi))[1]
                            DisarmTransaction()
                            ConOut("Erro Update SB2 NCM: " + cNcmPont + "  " + aRet[2])
                            Return aRet
                        EndIf
                    Else
                        oModel:SetOperation(MODEL_OPERATION_INSERT)
                        oModel:Activate()
                        oModel:SetValue(cIDModel,'YD_FILIAL', xFilial("SYD"))
                        oModel:SetValue(cIDModel,'YD_TEC', cNcmPont)
                        oModel:SetValue(cIDModel,'YD_DESC_P', DecodeUTF8(LTrim(aDados[nX][nPosDesc]), "cp1252"))
                        oModel:SetValue(cIDModel,'YD_PER_IPI', Val(cAliqIpi))
                        oModel:SetValue(cIDModel,'YD_GRVUSER', IIF(Empty(RetCodUsr()), 'WSREST', UsrRetName(RetCodUsr())))
                        oModel:SetValue(cIDModel,'YD_GRVDATA', dData)
                        oModel:SetValue(cIDModel,'YD_GRVHORA', cTime)
                        oModel:SetValue(cIDModel,'YD_UNID', 'UN')
                    EndIf
                    If !(aRet := save(@oModel, cNcmPont))[1]
                        DisarmTransaction()
                        ConOut("NCM: " + cNcmPont + "  " + aRet[2])
                        Return aRet
                    EndIf
                    oModel:DeActivate()
                EndIf
            Next
        END TRANSACTION
    EndIf

    RECOVER
    END SEQUENCE
    ErrorBlock(bErro)

	DbCloseArea()
    RestArea(aArea)    
    FreeObj(oModel)
Return aRet


Static Function delNcm(aDados)
    Local oModel    := FWLoadModel('cbcMdlSYD')
    Local aArea     := GetArea()
    Local aRet      := { .F., ""}
    Local nX        := 0
    Local nPosNcm   := 0
    Local cNcmPont  := ""
    Local cNcm      := "NCM"
    Local bErro     := ErrorBlock({|oErr| HandleEr(oErr, @self)})
    Default aDados  := {}

    BEGIN SEQUENCE
    nPosNcm  := AScan(aDados[1],{ |x| Alltrim(UPPER(x)) == cNcm })

    If nPosNcm > 0
        DBSelectArea("SYD")
        DbGotop()
        BEGIN TRANSACTION
            For nX := 2 to Len(aDados)
                cNcmPont := STRTRAN(aDados[nX][nPosNcm], ".", "")
                If Len(cNcmPont) == 8
                    If DbSeek(xFilial("SYD")+cNcmPont)
                        oModel:SetOperation(MODEL_OPERATION_DELETE)
                        oModel:Activate()
                    EndIf
                    If !(aRet := save(@oModel, cNcmPont))[1]
                        DisarmTransaction()
                        ConOut("NCM: " + cNcmPont)
                        Return aRet
                    EndIf
                    oModel:DeActivate()
                EndIf
            Next
        END TRANSACTION
    EndIf
    RECOVER
    END SEQUENCE
    ErrorBlock(bErro)
	DbCloseArea()
    RestArea(aArea)    
    FreeObj(oModel)
Return aRet


static function save(oModel, cNCM)
    local lRet  as logical
    local aErro as array
    local cErro as character
    Default cNCM := ""

    if !(lRet := oModel:VldData())
        aErro := oModel:GetErrorMessage()
        if !empty(aErro)
            cErro := aErro[2] + '-'
            cErro += aErro[4] + '-'
            cErro += aErro[5] + '-'
            cErro += aErro[6]
        else
            cErro := ""
        endif
        If !lRet
            u_envmail({"lucas.clementino@cobrecom.com.br"}, "[ERRO - cbcWsNcm] - Salvar NCM na Tabela", { "NCM","Erro" }, {{ cNCM, cErro }})
        EndIf
    else
        FWFormCommit(oModel)
    endIf
return({lRet, cErro})


Static Function updB2Ncm(cNCM, cIPI)
    Local lRet   := .F.
    Local cErro  := ""
    Local oSql	 := LibSqlObj():newLibSqlObj()
    Default cNCM := ""

    If !Empty(cNcm) .And. !Empty(cIPI)
        lRet := oSql:update("SB1", "B1_IPI = '" + cIPI + "'", ;
        "B1_FILIAL = '' AND B1_TIPO NOT IN ('PA', 'PI') AND B1_POSIPI = '" + cNCM + "' AND B1_MSBLQL <> 1 ")
    EndIf  
    If !lRet
        u_envmail({"lucas.clementino@cobrecom.com.br"}, "[ERRO - cbcWSNCM] - Atualizar IPI SB2 - NCM", { "NCM","IPI Novo" }, {{ cNCM, cIPI }})
    EndIf
Return ({lRet, cErro})

