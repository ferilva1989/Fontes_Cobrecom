#include 'protheus.ch'
#include 'parmtype.ch'

user function GFEA1183()
    local cbcaArea		:= GetArea()
    local _oCte 		:= PARAMIXB[1]
    local aDadosTransp	:= {}
    local _cTransp		:= If(_oCte != nil ,xmlvalid(_oCte,{"_INFCTE","_EMIT"},"_CNPJ"), "")
    local lRet 			:= .T.

    if empty(_cTransp)
    	lRet := .F. //Aborta
    else
    	DbSelectArea("SA4")
    	if Alltrim(Posicione("SA4",3,XFILIAL("SA4")+Alltrim(_cTransp),"A4_CGC")) <> _cTransp
    		aadd(aDadosTransp, {"CNPJ"	, _cTransp					, nil } )
    		aadd(aDadosTransp, {"IE"	, If(_oCte != nil ,xmlvalid(_oCte,{"_INFCTE","_EMIT"},"_IE"), ""), nil } )
    		aadd(aDadosTransp, {"NOME"	, If(_oCte != nil ,xmlvalid(_oCte,{"_INFCTE","_EMIT"},"_XNOME"), ""), nil } )
    		aadd(aDadosTransp, {"ENDER"	, If(_oCte != nil ,xmlvalid(_oCte,{"_INFCTE","_EMIT","_ENDEREMIT"},"_XLGR"), ""), nil } )
    		aadd(aDadosTransp, {"NRO"	, If(_oCte != nil ,xmlvalid(_oCte,{"_INFCTE","_EMIT","_ENDEREMIT"},"_NRO"), ""), nil } )
    		aadd(aDadosTransp, {"BAIRRO", If(_oCte != nil ,xmlvalid(_oCte,{"_INFCTE","_EMIT","_ENDEREMIT"},"_XBAIRRO"), ""), nil } )
    		aadd(aDadosTransp, {"NMUN"	, If(_oCte != nil ,xmlvalid(_oCte,{"_INFCTE","_EMIT","_ENDEREMIT"},"_XMUN"), ""), nil } )
    		aadd(aDadosTransp, {"MUNIC"	, If(_oCte != nil ,xmlvalid(_oCte,{"_INFCTE","_EMIT","_ENDEREMIT"},"_CMUN"), ""), nil } )
            aadd(aDadosTransp, {"UF"	, If(_oCte != nil ,xmlvalid(_oCte,{"_INFCTE","_EMIT","_ENDEREMIT"},"_UF"), ""), nil } )
    		aadd(aDadosTransp, {"CEP"	, If(_oCte != nil ,xmlvalid(_oCte,{"_INFCTE","_EMIT","_ENDEREMIT"},"_CEP"), ""), nil } )
    		aadd(aDadosTransp, {"OBS"	, "CRIADO PELA ROTINA AUTOMATICA IMPCTE"	, nil } )
            aadd(aDadosTransp, {"TEL"	, If(_oCte != nil ,xmlvalid(_oCte,{"_INFCTE","_EMIT","_ENDEREMIT"},"_FONE"), ""), nil } )
    		lRet := u_cbcNewTransp(aDadosTransp)
    	endif
    endif
    RestArea(cbcaArea)
return lRet

static function xmlvalid(oTEMP,aNode,cTag,lREALNAME)
    local nCont
    private oXML := oTEMP
    default lREALNAME := .F.
    //Navega dentro do objeto XML usando a variavel aNode como base, retornando o conteudo do TEXT ou o
    for nCont := 1 to Len(aNode)
        if valtype( XmlChildEx( oXML,aNode[nCont]  ) ) == 'O'
            oXML :=  XmlChildEx( oXML,aNode[nCont]  )
        else
            return ""
        endif
        if nCont == Len(aNode)
            if !lREALNAME
                if XmlChildEx(oXML,cTag) <> nil
                    cReturn := &("oXML:"+cTag+':TEXT')
                    return cReturn
                else
                    return ''
                endif
            else
                cReturn := &("oXML:REALNAME")
                return cReturn
            endif
        endIf
    next nCont
    FreeObj(oXML)
    FreeObj(xRet)
    FreeObj(xRet1)
Return ''