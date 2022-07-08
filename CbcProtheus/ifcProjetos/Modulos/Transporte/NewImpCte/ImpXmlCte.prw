#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'


/*/{Protheus.doc} User Function ComColRt
    @author user
    @since 06/11/2020
    Adicionar rotina de importação do XML ao menu
/*/
User Function ComColRt()
    Local aRotina := ParamIxb[1]
    //COLAUTOREAD - Jogar do XML para CKO, SCHEDCOMCOL - Importar para SDS e SDT -> Criar função para executá-los
    AAdd( aRotina, { "Carga XML Sefaz", "FWMsgRun(, { |oSay| u_zExecCte({.F.},oSay) }, 'Importação XML SEFAZ', 'Importando XML do ambiente da SEFAZ ... Aguarde!')",0,3,0,NIL} )
    AAdd( aRotina, { "1-Importar XML Sistema", "FWMsgRun(, { |oSay| COLAUTOREAD() }, 'Importar XML Sistema', 'Importando XML da Pasta ... Aguarde!')",0,3,0,NIL} )
    AAdd( aRotina, { "2-Importar para Rotina", "FWMsgRun(, { |oSay| SCHEDCOMCOL() }, 'Importar para Rotina', 'Importando XML para a rotina ... Aguarde!')",0,3,0,NIL} )
    AAdd( aRotina, { "Relatorio COBRECOM", "FWMsgRun(, { |oSay| u_relImpCte() }, 'Relatorio Cobrecom', 'Gerando relatorio... Aguarde!')",0,4,0,NIL} )
Return aRotina


/*/{Protheus.doc} User Function MT116XMLCT
    @author user
    @since 06/11/2020
    Manipular dados da SDS/SDT na importação de um CTE
/*/
User function MT116XMLCT()
    Local oXML    := PARAMIXB[1]
    Local oModelF1  := FWLoadModel('cbcMdlSF1')
    Local oModelF2  := FWLoadModel('cbcMdlSF2')
    /*Local cNF     := PARAMIXB[2]
    Local cSerie  := PARAMIXB[3]
    Local cForn   := PARAMIXB[4]
    Local cLoja   := PARAMIXB[5]
    Local cTipo   := PARAMIXB[6]
    Local cOpc    := PARAMIXB[7] *///PF - Produto Frete, PN - Produto na NF original
    Local aTesOp  := {}
    Local aRetSf  := {}
    Local nX      := 0
    Local nRecSf  := 0
    Local cChvNf  := ''
    Local cChvCte := ''
    Local cTes    := SuperGetMV("MV_XMLTECT",.F.,"017")

    If SDS->DS_FORNEC == SDT->DT_FORNEC .And. SDS->DS_LOJA == SDT->DT_LOJA  
        aTesOp := getTesOp(oXML,cTes, { SDS->DS_FORNEC, SDS->DS_LOJA }, SDT->DT_COD, "1", "1")
        SDS->DS_ZZOPER := aTesOp[2]
        SDT->DT_TES := aTesOp[1]
    EndIf

    If !Empty(cChvCte := SubStr(oXML:_INFCTE:_ID:TEXT,4,44))
        If XmlChildEx(oXML:_INFCTE,"_COMPL") != Nil .And. XmlChildEx(oXML:_INFCTE:_COMPL,"_XOBS") != Nil
            SDS->DS_OBS := ValidaXML(oXML,{"_INFCTE","_COMPL"},"_XOBS")
        EndIf

        If ValidaXML(oXML,{"_INFCTE","_INFCTECOMP"},"TEXT",.T.) == "infCteComp"
            If ValType(oXML:_INFCTE:_INFCTECOMP) == "O"
                cChvNf := oXML:_INFCTE:_INFCTECOMP:_CHCTE:TEXT
                aRetSf := getRecSf(cChvNf)
                nRecSf := aRetSf[1]
                If Empty(cChvNf) .Or. nRecSf <= 0
                    Return Nil
                EndIf
                If aRetSf[2] == "SF1"
                    setSf(oModelF1,nRecSf,cChvCte,aRetSf[2])
                ElseIf aRetSf[2] == "SF2"
                    setSf(oModelF2,nRecSf,cChvCte,aRetSf[2])
                EndIf
            Else
                Help( ,, cChvCte ,, 'Erro no CT-e', 1,0)
            EndIf
        ElseIf ValidaXML(oXML,{"_INFCTE","_INFCTENORM"},"TEXT",.T.) == "infCTeNorm"
            If ValType(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE) == "A"
                For nX := 1 to LEN(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE)
                    cChvNf := ''
                    aRetSf := {}
                    nRecSf := 0
                    cChvNf := oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE[nX]:_CHAVE:TEXT
                    aRetSf := getRecSf(cChvNf)
                    nRecSf := aRetSf[1]
                    If Empty(cChvNf) .Or. nRecSf <= 0
                        Return Nil
                    EndIf
                    If aRetSf[2] == "SF1"
                        setSf(oModelF1,nRecSf,cChvCte,aRetSf[2])
                    ElseIf aRetSf[2] == "SF2"
                        setSf(oModelF2,nRecSf,cChvCte,aRetSf[2])
                    EndIf
                Next
            ElseIf ValType(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE) == "O"
                cChvNf := oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE:_CHAVE:TEXT
                aRetSf := getRecSf(cChvNf)
                nRecSf := aRetSf[1]
                If Empty(cChvNf) .Or. nRecSf <= 0
                    Return Nil
                EndIf
                If aRetSf[2] == "SF1"
                    setSf(oModelF1,nRecSf,cChvCte,aRetSf[2])
                ElseIf aRetSf[2] == "SF2"
                    setSf(oModelF2,nRecSf,cChvCte,aRetSf[2])
                EndIf
            ElseIf ValType(oXML:_INFCTE:_INFCTENORM:_INFDOC:_INFNFE) == "U"
                Help( ,, cChvCte ,, 'Erro no CT-e', 1,0)
            EndIf
        EndIf
    EndIf
    FreeObj(oModelF1)
    FreeObj(oModelF2)
Return Nil


/*/{Protheus.doc} A116PRDF
    @author user
    @since 06/11/2020
    Ponto de Entrada que retorna o codigo do serviço do CTE para o integrador xml
/*/
User Function A116PRDF()
    Local oXML      := Paramixb[1]
    Local cProd     := ""
    Local cPrdFrete := SUPERGETMV("MV_XMLPFCT", .F., "1")
    
    cProd     := getProd(oXML)
    cPrdFrete := IIF(!EMPTY(cProd),cProd,cPrdFrete)
Return cPrdFrete


/*/{Protheus.doc} A116TECT
    @author user
    @since 06/11/2020
    Retorna a TES e condição de pagamento
/*/
User function A116TECT()
    Local oXML    := Paramixb[1]
    Local aArea   := GetArea()
    Local aRet    := Array(2)
    Local aForn   := Array(2)
    Local cChvCte := ""
    Local cCodPro := ""

    aRet[1] := SuperGetMV("MV_XMLTECT",.F.,"017") // Código da TES
    aRet[2] := SuperGetMV("MV_XMLCPCT",.F.,"080") // Código da condição de pagamento

    If oXML <> Nil
        cChvCte := SubStr(oXML:_INFCTE:_ID:TEXT,4,44)
        cCodPro := getProd(oXML)
        If !EMPTY(SDS->DS_CHAVENF) .And. SDS->DS_CHAVENF <> cChvCte
            Dbselectarea("SDS")
            SDS->(DbSetOrder(2))
            SDS->(DbGoTop())
            If SDS->(DbSeek(FWxFilial("SDS") + cChvCte))
                AAdd(aForn, SDS->DS_FORNEC)
                AAdd(aForn, SDS->DS_LOJA)
            EndIf
        Else
	        aForn := getForn(oXML)
        EndIf
        aRet[1] := getTesOp(oXML, aRet[1], aForn, cCodPro, "1", "1")[1]

        If ValidaXML(oXML,{"_INFCTE","_EMIT","_CNPJ"},"TEXT",.T.) == 'CNPJ'
            aRet[2] := getCondPag(oXML:_INFCTE:_EMIT:_CNPJ:TEXT)
        Else
            aRet[2] := getCondPag(oXML:_INFCTE:_EMIT:_CPF:TEXT)
        EndIf
    ElseIf !Empty(SDS->DS_FORNEC) .And. !Empty(SDS->DS_LOJA)
        If !Empty(SDS->DS_ZZOPER)
            aRet[1] := IIF(!Empty(SDT->DT_TES), SDT->DT_TES, getTesOp(Nil, aRet[1], aForn, cCodPro, "1", "1", SDS->DS_ZZOPER)[1])
        EndIf
        aRet[2] := posicione("SA2",1,xFilial('SA2')+SDS->DS_FORNEC+SDS->DS_LOJA,'A2_COND')    
    EndIf
    RestArea(aArea)
Return aRet


Static Function getProd(oXML)
    Local cProd := ""
    Local cTipoICMS := ''
    Local nPercIcms := NIL

    If "ICMS" $ (ClassDataArr(oXML:_INFCTE:_IMP:_ICMS, .T.)[1][2]:REALNAME)
        cTipoICMS := ClassDataArr(oXML:_INFCTE:_IMP:_ICMS, .T.)[1][2]:REALNAME
        If cTipoICMS == "ICMS60"
            nPercIcms := Val(ClassDataArr(oXML:_INFCTE:_IMP:_ICMS, .T.)[1][2]:_pICMSSTRet:TEXT)
        ElseIf cTipoICMS == "ICMSOutraUF"
            nPercIcms := Val(ClassDataArr(oXML:_INFCTE:_IMP:_ICMS, .T.)[1][2]:_PICMSOutraUF:TEXT)
        ElseIf cTipoICMS $ "ICMSSN-ICMS40-ICMS41-ICMS45"
            nPercIcms := 0
        Else
            nPercIcms := Val(ClassDataArr(oXML:_INFCTE:_IMP:_ICMS, .T.)[1][2]:_PICMS:TEXT) 
        EndIf
    Else
        MessageBox(oXML:_INFCTE:_ID:TEXT + ' ' + cTipoICMS, 'Erro no ICMS do CTE', 16)   
    EndIf

    If nPercIcms <= 7
        cProd := "SV05000020"
    Else
        cProd := "SV05000021"
    EndIf
Return cProd


/*/{Protheus.doc} getRecSf
    Obter recno das notas contidas no XML nas SF
/*/
Static Function getRecSf(cChvNf)
    Local oSql   := LibSqlObj():newLibSqlObj()
    Local cTab   := ''
    Local nRecno := 0
    Local cQryF1 := ''
    Local cQryF2 := ''

    cQryF1 := " SELECT R_E_C_N_O_ [RECNO]"
    cQryF1 += " FROM  %SF1.SQLNAME% "
    cQryF1 += " WHERE F1_CHVNFE = '" + cChvNf + "' "
    cQryF1 += " AND %SF1.NOTDEL% "

    cQryF2 := " SELECT R_E_C_N_O_ [RECNO]"
    cQryF2 += " FROM  %SF2.SQLNAME% "
    cQryF2 += " WHERE F2_CHVNFE = '" + cChvNf + "' "
    cQryF2 += " AND %SF2.NOTDEL% "

    oSql:newAlias(cQryF2)
    If oSql:hasRecords()
        cTab = "SF2"
        oSql:goTop()
        nRecno := oSql:getValue('RECNO')
    Else
        oSql:close()
        oSql:newAlias(cQryF1)
        If oSql:hasRecords()
            cTab = "SF1"
            oSql:goTop()
            nRecno := oSql:getValue('RECNO')
        EndIf
	EndIf
	oSql:close()
    FreeObj(oSql)
Return { nRecno, cTab }


Static Function setSf(oModel, nRec, cChaveCte, cTab)
    If nRec > 0
        DbSelectArea(cTab)
        (cTab)->(DbGoTo(nRec))
    Else
        Return Nil
    EndIf

    oModel:SetOperation(MODEL_OPERATION_UPDATE) 
    oModel:Activate() 
    If cTab == "SF1"
        oModel:SetValue('SF1MASTER', 'F1_CHVCTE', cChaveCte)
        FWFormCommit(oModel)
        oModel:DeActivate()
        Return Nil
    Else
        oModel:SetValue('SF2MASTER', 'F2_CHVCTE', cChaveCte)
    EndIf
        If !(oModel:VldData())
            aErro := oModel:GetErrorMessage()
            If !empty(aErro)
                cErro := aErro[2] + '-'
                cErro += aErro[4] + '-'
                cErro += aErro[5] + '-'
                cErro += aErro[6]
                Help( ,, cErro ,, 'Erro', 1,0)
            EndIf
            MessageBox('Não foi possivel identificar as NFs da carga referente ao CTE' + oXML:_INFCTE:_ID:TEXT, 'NFs da Carga', 16) 
            DisarmTransaction()
        Else
            FWFormCommit(oModel)
        EndIf
    oModel:DeActivate()
Return Nil


Static Function getCondPag(cCgc)
    Local cCond := ''
    Local cQry	:= ''
    Local oSql  := LibSqlObj():newLibSqlObj()

    cQry := " SELECT A2_COND [CondPag]"
    cQry += " FROM  %SA2.SQLNAME% "
    cQry += " WHERE %SA2.XFILIAL% "
    cQry += " AND A2_CGC = '" + cCgc + "' "
    cQry += " AND A2_COND <> '' "
    cQry += " AND A2_MSBLQL <> '1' "
    cQry += " AND %SA2.NOTDEL% "
    cQry += " ORDER BY A2_ULTCOM DESC "

    oSql:newAlias(cQry)
    If oSql:hasRecords()
        oSql:goTop()
        cCond := oSql:getValue('CondPag')
	EndIf
	oSql:close()
    FreeObj(oSql)
Return cCond

Static Function getForn(oXML)
    Local cCgc  := ''
    Local cIe   := ''
    Local aForn := {}
    Local cQry	:= ''
    Local cQry1	:= ''
    Local oSql  := LibSqlObj():newLibSqlObj()

    If ValType(XmlChildEx(oXML:_InfCte:_Emit,"_CNPJ")) <> "U"
        cCgc := AllTrim(oXML:_InfCte:_Emit:_CNPJ:Text)
    Else
        cCgc := AllTrim(oXML:_InfCte:_Emit:_CPF:Text)
    EndIf

    If ValType(XmlChildEx(oXML:_InfCte:_Emit,"_IE")) == "O"
        cIe		:= AllTrim(XmlChildEx(oXML:_InfCte:_Emit,"_IE"):Text)
    Else
        cIe		:= ""
    Endif

    cQry := " SELECT A2_COD [COD], A2_LOJA [LOJA]"
    cQry += " FROM  %SA2.SQLNAME% "
    cQry += " WHERE %SA2.XFILIAL% "
    cQry += " AND A2_CGC = '" + cCgc + "' "
    cQry += " AND A2_INSCR = '" + cIe + "' "
    cQry += " AND A2_MSBLQL <> '1' "
    cQry += " AND %SA2.NOTDEL% "

    cQry1 := " SELECT A2_COD [COD], A2_LOJA [LOJA]"
    cQry1 += " FROM  %SA2.SQLNAME% "
    cQry1 += " WHERE %SA2.XFILIAL% "
    cQry1 += " AND A2_CGC = '" + cCgc + "' "
    cQry1 += " AND A2_MSBLQL <> '1' "
    cQry1 += " AND %SA2.NOTDEL% "

    oSql:newAlias(cQry)
    If oSql:hasRecords()
        oSql:goTop()
        aAdd(aForn,oSql:getValue('COD'))
        aAdd(aForn,oSql:getValue('LOJA'))
    Else
        oSql:close()
        oSql:newAlias(cQry1)
        If oSql:hasRecords()
            oSql:goTop()
            aAdd(aForn,oSql:getValue('COD'))
            aAdd(aForn,oSql:getValue('LOJA'))
        Else
            MessageBox('Fornecedor do CT-e' + oXML:_INFCTE:_ID:TEXT + ' Não Encontrado', 'Fornecedor Não Encontrado', 16) 
        EndIf
	EndIf
	oSql:close()
    FreeObj(oSql)
Return aForn


Static Function getTesOp(oXML, cTes, aForLoj, cItemTes, cCrdIcm, cCrdPc, cTrbImp)
	Local cOper     := ""
    Local cTes1     := ""
    Local cTpImp    := Posicione("GVT", 1, xFilial("GVT") + SDS->DS_ESPECI, "GVT_TPIMP")
    Default cTrbImp := ""
    Default cCrdIcm := "1"
    Default cCrdPc  := "1"

    If oXML <> NIL
        cTrbImp := getTpTrib(oXML)
    EndIf

    cTpImp := IIF(!EMPTY(cTpImp),cTpImp,"1")

    Do Case
        Case cTpImp == "1" //"1=ICMS"
            Do Case		
                Case cTrbImp == "2" .And. cCrdPc == "1" //"2=ISENTO" .And. "1=Sim"
                    cOper := "T2" 
                Case cTrbImp == "2" .And. cCrdPc == "2" //"2=ISENTO" .And. "2=Não"
                    cOper := "T6"
                Case cTrbImp == "3" .And. cCrdIcm == "1"//"3=SUBS. TRIB. Credito ICMS = Sim"
                    cOper := "T3"
                Case cTrbImp == "3" .And. cCrdIcm == "2"//"3=SUBS. TRIB. Credito ICMS = Não"
                    cOper := "T5"
                Case cTrbImp == "1" .And. cCrdPc == "2"  //"1=TRIBUTADO" .And. "2=NAO"
                    cOper := "T7"
                Case cTrbImp == "1" .And. cCrdIcm == "2"  //"1=TRIBUTADO" .And. "2=NAO"
                    cOper := "T8"
                Case cTrbImp == "6" //"6=OUTROS"
                    cOper := "T8"
            EndCase
        Case cTpImp == "2" //"2=ISS"
            cOper := "T4"
        Case cTpImp == "3" //"3=PEDÁGIO"
            cOper := "TA"
    EndCase

    cOper := IIF(!EMPTY(cOper),cOper,"T1")
    cTes1 := IIF(!EMPTY(aForLoj[1]),MaTESInt(1,cOper,aForLoj[1],aForLoj[2],"F",cItemTes), "")
    cTes  := IIF(!EMPTY(cTes1),cTes1,cTes)
Return { cTes, cOper}

/*/{Protheus.doc} getTpTrib
    Retorna o tipo de tributação com base no XML 
    do CT-e para gerar buscar TES.
    1=Tributado;2=Isento/Não-tributado;3=Subs Tributária;
    4=Diferido;5=Reduzido;6=Outros;7=Presumido
    @since 25/11/2020
/*/
Static Function getTpTrib(oCTe, lApuIcm)
    Local cTpTrib   := ""
    Local cValImp   := ""
    Default lApuIcm := .F. //Para ser .T. GU3->GU3_APUICM == "4"

    If ValidaXML(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS00"},'',.T.) == 'ICMS00' ;
        .Or. ValidaXML(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS20"},'',.T.) == 'ICMS20' //Tributado
        cTpTrib := '1'
    ElseIf ValidaXML(oCTe , {"_INFCTE","_IMP","_ICMS","_ICMS40"} , '' , .T. ) == 'ICMS40' ;//Isento/Não Tributado
        .Or. ValidaXML(oCTe , {"_INFCTE","_IMP","_ICMS","_ICMS41"} , '' , .T. ) == 'ICMS41' ;
        .Or. ValidaXML(oCTe , {"_INFCTE","_IMP","_ICMS","_ICMS45"} , '' , .T. ) == 'ICMS45'
        If ValidaXML(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS45"},"_CST") == '51'    //Diferido
            cTpTrib := '4' 
        Else
            cTpTrib := '2'
        EndIf
    ElseIf  ValidaXML(oCTe , {"_INFCTE","_IMP","_ICMS","_ICMSSN"} , '' , .T. ) == 'ICMSSN' ;  //Simples Nacional
        .Or. ValidaXML(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS90"},'',.T.) == 'ICMS90' //Outros
        cTpTrib := '6'
    ElseIf  ValidaXML(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS60"},'',.T.) == 'ICMS60' .And. lApuIcm   //Subst. Tributaria e apuração do ICMS por parte do emitente do documento de frete igual a presumido
        cTpTrib := '7'
    ElseIf  ValidaXML(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMS60"},'',.T.) == 'ICMS60'   //Subst. Tributaria
        cTpTrib := '3'
    ElseIf ValidaXML(oCTe,{"_INFCTE","_IMP","_ICMS","_ICMSOUTRAUF"},'',.T.) == 'ICMSOutraUF'
        cTpTrib := '1'
        cValImp := ValidaXML(oCte,{"_INFCTE","_IMP","_ICMS","_ICMSOUTRAUF"},"_vICMSOutraUF",.F.) //GXG->GXG_VLIMP - Valor do Imposto
        If cValImp == '0.00'
            cTpTrib := '6'  //Quando o valor do imposto for zerado, não pode ser Tributado
        EndIf
    EndIf
Return cTpTrib


Static Function ValidaXML(oTEMP,aNode,cTag,lREALNAME)
    Local nCont
    Private oXML := oTEMP
    Default lREALNAME := .F.
	//Navega dentro do objeto XML usando a variavel aNode como base, retornando o conteudo do TEXT ou o
	For nCont := 1 to Len(aNode)
		If ValType( XmlChildEx( oXML,aNode[nCont]  ) ) == 'O'
			oXML :=  XmlChildEx( oXML,aNode[nCont]  )
		Else
			Return ''
		Endif
		If nCont == Len(aNode)
			If !lREALNAME
				cReturn := &("oXML:"+cTag+':TEXT')
				Return cReturn
			Else
				cReturn := &("oXML:REALNAME")
				Return cReturn
			Endif
		EndIf
	Next nCont
	FreeObj(oXML)
Return ''
