user function zcbNFSe()
    local oWS           as object
    local nVersaoSchema as numeric
    local cMensagemXML  as character
    Local oStatic       := IfcXFun():newIfcXFun()

    cqry := oStatic:sP(6):callStatic('MATR460', 'R460Select','20210430', '', 'ZZZZZZZZZ', '', 'ZZZZZZZZZ', .T.)
    // R460Select('20210430', '', 'ZZZZZZZZZ', {}, {}, .T.)
    
    oWS 	:= WSSaoPauloNFSE():New()
    
    nVersaoSchema   := 1
    cCnpj           := '02544042000119'
    cInscicao       := '387086243118'
    cDtInicio       := '2021-09-01'
    cDtFim          := '2021-09-16'
    nPagina         := 1
    

    cMensagemXML    := ''
	cMensagemXML 	+= '<CPFCNPJRemetente>' + cCnpj     + '</CPFCNPJRemetente>'
	cMensagemXML 	+= '<CPFCNPJ>'          + cCnpj     + '</CPFCNPJ>'
    cMensagemXML 	+= '<Inscricao>'        + cInscicao + '</Inscricao>'
    cMensagemXML 	+= '<dtInicio>'         + cDtInicio + '</dtInicio>'
    cMensagemXML 	+= '<dtFim>'            + cDtFim    + '</dtFim>'
    cMensagemXML 	+= '<NumeroPagina>'     + cValToChar(nPagina)   + '</NumeroPagina>'
     
    oWS:ConsultaNFeRecebidas(nVersaoSchema, cMensagemXML)
    
    alert(oWS:cRetornoXML)
    FreeObj(oWS)
return nil



/* ASSINATURA DO XML */
user function cbcSignXml(cXML)
    cPassword   := 'Cobre1020'
    cDigest     := GetDigest(cXML)
    aCertific   := GetCertificate("\Cert_NFE\NFS_E", "cert", cPassword)
    cSignInfo   := GetSignInfo(Space(0), cDigest)
    cSignature  := GetSignature(aCertific, cSignInfo, cPassword)
    cXML        := BuildXML(cXML, cSignature)
return cXML

Static Function GetDigest(cXML As Character)
    Local cDigest As Character
    cDigest := Space(0)
    cXML    := XMLSerialize(cXML)
    cDigest := Encode64(EVPDigest(cXML, 3))
Return (cDigest)

Static Function XMLSerialize(cXML)
    Local cError   As Character 
    Local cWarning As Character 

    cError   := Space(0)
    cWarning := Space(0)

    cXML := StrTran(cXML, Chr(10), Space(0))
    cXML := StrTran(cXML, Chr(13), Space(0))

    While (At("> ", cXML) > 0)
        cXML := StrTran(cXML, "> ", ">")
    End

    While (At(" <", cXML) > 0)
        cXML := StrTran(cXML, " <", "<")
    End

    While (At(" </", cXML) > 0)
        cXML := StrTran(cXML, " </", "</")
    End

   cXML := XMLC14N(cXML, Space(0), @cError, @cWarning)
Return (cXML)

Static Function GetCertificate(cCertPath As Character, cFileName As Character, cPassword As Character)
    Local aCertific As Array     // VETOR DE CERTIFICADOS
    Local cFullPath As Character // CAMINHO RELATIVO COMPLETO
    Local cError    As Character // ERROS DE GERAÇÃO DE CERTIFICADO
    Local lFind     As Logical   // VALIDADOR DE EXTRAÇÃO DE CERTIFICADO

    // INICIALIZAÇÃO DE VARIÁVEIS
    lFind     := .F.
    aCertific := {}
    cCertPath := cCertPath + "\"
    cFullPath := Space(0)
    cError    := Space(0)

    // PROPRIEDADES PARA ARQUIVO *.CA
    cError    := Space(0)
    cFullPath := cCertPath + cFileName + "_ca.pem"
    lFind     := File(cFullPath)

    // VERIFICA SE O ARQUIVO JÁ EXISTE,
    // CASO NÃO EFETUA A CRIAÇÃO
    If (!lFind)
        If (PFXCA2PEM(cCertPath + cFileName + ".pfx", cFullPath, @cError, cPassword))
            ConOut(Repl("-", 80))
            ConOut(MemoRead(cFullPath))
            ConOut(Repl("-", 80))
        Else
            ConOut(Repl("-", 80))
            ConOut(PadC("ERROR: Couldn't extract *_CA certificate", 80))
            ConOut(Repl("-", 80))
        EndIf
    EndIf

    // ADICIONA O CAMINHO NO RETORNO
    AAdd(aCertific, {"CA", cFullPath, lFind})

    // PROPRIEDADES PARA ARQUIVO *.KEY
    cError    := Space(0)
    cFullPath := cCertPath + cFileName + "_key.pem"
    lFind     := File(cFullPath)

    // VERIFICA SE O ARQUIVO JÁ EXISTE,
    // CASO NÃO EFETUA A CRIAÇÃO
    If (!lFind)
        If (PFXKey2PEM(cCertPath + cFileName + ".pfx", cFullPath, @cError, cPassword))
            ConOut(Repl("-", 80))
            ConOut(MemoRead(cFullPath))
            ConOut(Repl("-", 80))
        Else
            ConOut(Repl("-", 80))
            ConOut(PadC("ERROR: Couldn't extract *_KEY certificate", 80))
            ConOut(Repl("-", 80))
        EndIf
    EndIf

    // ADICIONA O CAMINHO NO RETORNO
    AAdd(aCertific, {"KEY", cFullPath, lFind})

    // PROPRIEDADES PARA ARQUIVO *.CERT
    cError    := Space(0)
    cFullPath := cCertPath + cFileName + "_cert.pem"
    lFind     := File(cFullPath)

    // VERIFICA SE O ARQUIVO *.CERT JÁ EXISTE,
    // CASO NÃO EFETUA A CRIAÇÃO
    If (!lFind)
        If (PFXCert2PEM(cCertPath + cFileName + ".pfx", cFullPath, @cError, cPassword))
            ConOut(Repl("-", 80))
            ConOut(MemoRead(cFullPath))
            ConOut(Repl("-", 80))
        Else
            ConOut(Repl("-", 80))
            ConOut(PadC("ERROR: Couldn't extract *_CERT certificate", 80))
            ConOut(Repl("-", 80))
        EndIf
    EndIf

    // ADICIONA O CAMINHO NO RETORNO
    AAdd(aCertific, {"CERT", cFullPath, lFind})

    // VERIFICA SE OS CERTIFICADOS BÁSICOS FORAM EXTRAÍDOS
    If (!aCertific[2][3] .And. !aCertific[3][3])
        Final("ERROR: Couldn't extract any certificate")
    EndIf
Return (aCertific)


Static Function GetSignInfo(cURI As Character, cDigest As Character)
    Local cSignInfo As Character // CORPO DO SIGNEDINFO

    // INICIALIZAÇÃO DE VARIÁVEIS
    cSignInfo := Space(0)

    // MONTAGEM DO SIGNEDINFO
    cSignInfo += '<SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">'
    cSignInfo += '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
    cSignInfo += '<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>'
    cSignInfo += '<Reference URI="' + cURI + '">'
    cSignInfo += '<Transforms>'
    cSignInfo += '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>'
    cSignInfo += '</Transforms>'
    cSignInfo += '<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"/>'
    cSignInfo += '<DigestValue>' + cDigest + '</DigestValue>
    cSignInfo += '</Reference>'
    cSignInfo += '</SignedInfo>'

    // NORMALIZA O XML DA ASSINATURA
    cSignInfo := XMLSerialize(cSignInfo)
Return(cSignInfo)

Static Function GetSignature(aCertific As Array, cSignInfo As Character, cPassword As Character)
    Local oFile      As Object    // OBJETO DE ACESSO AO CERTIFICADO
    Local cFile      As Character // CONTEÚDO DO CERTIFICADO
    Local cError     As Character // ERROS DURANTE A CONVERSÃO
    Local cXMLSign   As Character // CORPO .XML DA ASSINATURA
    Local cSignature As Character // ASSINATURA

    // INICIALIZAÇÃO DE VARIÁVEIS
    cFile      := Space(0)
    cError     := Space(0)
    cXMLSign   := Space(0)
    cSignature := Encode64(EVPPrivSign(aCertific[AScan(aCertific, {|aCert|aCert[1] == "KEY"})][2], cSignInfo, 3, cPassword, @cError))
    oFile      := FwFileReader():New(aCertific[AScan(aCertific, {|aCert|aCert[1] == "CERT"})][2])

    // SE FOR POSSÍVEL ABRIR O ARQUIVO, LEIA-O
    // SE NÃO, EXIBA O ERRO DE ABERTURA
    If (oFile:Open())
        cFile := oFile:FullRead() // EFETUA A LEITURA DO ARQUIVO
    Else
        Final("Couldn't find/open file: " + cCertPath)
    EndIf

    // REMOVE A LINHA "BEGIN CERTIFICATE" E "END CERTIFICATE"
    cFile := SubStr(cFile, At("BEGIN CERTIFICATE", cFile) + 22)
    cFile := SubStr(cFile, 1, At("END CERTIFICATE", cFile) - 6)

    // GERA A ESTRUTURA DE ASSINATURA DO .XML
    cXMLSign += '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">'
    cXMLSign += cSignInfo
    cXMLSign += '<SignatureValue>' + cSignature + '</SignatureValue>'
    cXMLSign += '<KeyInfo>'
    cXMLSign += '<X509Data>'
    cXMLSign += '<X509Certificate>' + cFile + '</X509Certificate>'
    cXMLSign += '</X509Data>'
    cXMLSign += '</KeyInfo>'
    cXMLSign += '</Signature>'

    // NORMALIZA O XML DA ASSINATURA
    cXMLSign := XMLSerialize(cXMLSign)
Return (cXMLSign)

Static Function BuildXML(cXML As Character, cSignature As Character)
    Local cTag     As Character // TAG DO CORPO
    Local cNode    As Character // TAG A SER REMOVIDA
    Local cFullXML As Character // XML COMPLETO

    cTag        := "MensagemXML"
    cNode       := Space(0)
    cFullXML    := Space(0)
    cNode       := SubStr(cXML, At("</" + cTag + ">", cXML) )
    cXML        := SubStr(cXML, 1, At("</" + cTag + ">", cXML)-1)
    cFullXML    := XMLSerialize(cXML + cSignature + cNode)
Return (cFullXML)
