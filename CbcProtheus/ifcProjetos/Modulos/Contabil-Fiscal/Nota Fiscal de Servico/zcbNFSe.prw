user function zcbNFSe()
    local oWS           as object
    local nVersaoSchema as numeric
    local cMensagemXML  as character
    local msgAssig      as character

    
    oWS 	:= WSSaoPauloNFSE():New()
  
    nVersaoSchema   := 1
    cCnpj           := '02544042000119'
    //cInscicao       := '387086243118'
    cDtInicio       := '2022-07-01'
    cDtFim          := '2022-07-07'
    nPagina         := 1
    

    cMensagemXML := '<Cabecalho Versao="1">'
    cMensagemXML += '<CPFCNPJRemetente>'
    cMensagemXML += '<CNPJ>' + cCnpj + '</CNPJ>'
    cMensagemXML += '</CPFCNPJRemetente>'
    cMensagemXML += '<CPFCNPJ>'
    cMensagemXML += '<CNPJ>' + cCnpj + '</CNPJ>'
    cMensagemXML += '</CPFCNPJ>'
    //cMensagemXML += '<Inscricao>31000000</Inscricao>'
    cMensagemXML += '<dtInicio>'+ cDtInicio +'</dtInicio>'
    cMensagemXML += '<dtFim>' + cDtFim + '</dtFim>'
    cMensagemXML += '<NumeroPagina>'+ cValToChar(1) +'</NumeroPagina>'
    cMensagemXML += '</Cabecalho>'
   
    msgAssig := strtran(strtran(u_cbcSignXml('<MensagemXML>'+cMensagemXML+'</MensagemXML>'), '<MensagemXML>', ''),'</MensagemXML>','') 
    
    //cMensagemXML := '<PedidoConsultaNFePeriodo>'
    oWS:ConsultaNFeRecebidas(nVersaoSchema, msgAssig)
    
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
    Local cError    As Character // ERROS DE GERA??????O DE CERTIFICADO
    Local lFind     As Logical   // VALIDADOR DE EXTRA??????O DE CERTIFICADO

    // INICIALIZA??????O DE VARI???VEIS
    lFind     := .F.
    aCertific := {}
    cCertPath := cCertPath + "\"
    cFullPath := Space(0)
    cError    := Space(0)

    // PROPRIEDADES PARA ARQUIVO *.CA
    cError    := Space(0)
    cFullPath := cCertPath + cFileName + "_ca.pem"
    lFind     := File(cFullPath)

    // VERIFICA SE O ARQUIVO J??? EXISTE,
    // CASO N???O EFETUA A CRIA??????O
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

    // VERIFICA SE O ARQUIVO J??? EXISTE,
    // CASO N???O EFETUA A CRIA??????O
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

    // VERIFICA SE O ARQUIVO *.CERT J??? EXISTE,
    // CASO N???O EFETUA A CRIA??????O
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

    // VERIFICA SE OS CERTIFICADOS B???SICOS FORAM EXTRA???DOS
    If (!aCertific[2][3] .And. !aCertific[3][3])
        Final("ERROR: Couldn't extract any certificate")
    EndIf
Return (aCertific)


Static Function GetSignInfo(cURI As Character, cDigest As Character)
    Local cSignInfo As Character // CORPO DO SIGNEDINFO

    // INICIALIZA??????O DE VARI???VEIS
    cSignInfo := Space(0)

    // MONTAGEM DO SIGNEDINFO
    cSignInfo += '<SignedInfo>'
    cSignInfo += '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"/>'
    cSignInfo += '<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"/>'
    cSignInfo += '<Reference URI="' + cURI + '">'
    cSignInfo += '<Transforms>'
    cSignInfo += '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>'
    cSignInfo += '<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315" />'
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
    Local cFile      As Character // CONTE???DO DO CERTIFICADO
    Local cError     As Character // ERROS DURANTE A CONVERS???O
    Local cXMLSign   As Character // CORPO .XML DA ASSINATURA
    Local cSignature As Character // ASSINATURA

    // INICIALIZA??????O DE VARI???VEIS
    cFile      := Space(0)
    cError     := Space(0)
    cXMLSign   := Space(0)
    cSignature := EVPPrivSign(aCertific[AScan(aCertific, {|aCert|aCert[1] == "KEY"})][2], cSignInfo, 3, cPassword, @cError)
    oFile      := FwFileReader():New(aCertific[AScan(aCertific, {|aCert|aCert[1] == "CERT"})][2])

    // SE FOR POSS???VEL ABRIR O ARQUIVO, LEIA-O
    // SE N???O, EXIBA O ERRO DE ABERTURA
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
    cXMLSign += '<SignatureValue>' + Encode64(cSignature) + '</SignatureValue>'
    cXMLSign += '<KeyInfo>'
    cXMLSign += '<X509Data>'
    cXMLSign += '<X509Certificate>' + Encode64(cFile) + '</X509Certificate>'
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
