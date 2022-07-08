#include 'protheus.ch'
#define CIDADE 1
#define UF	2
#define ENDERECO	3
#define CEP	4
#define COMPLEMENTO	5
#define MB_ICONHAND 16
static cLast := ''

class cbcCepElsSrc 
	data lGetCompl
	data oRestClient
	data oJsonRet
	data aResult
	data aRefResult
	data nLstResult
	data cLastGet
	data aEscolhido
	data lMsgErr
	method newcbcCepElsSrc() constructor 
	method initScreen()
	method search()
	method onesearch()
	method destroy()
	method customSearch()
endclass


method newcbcCepElsSrc(lComple, lMsgErr) class cbcCepElsSrc
	default lComple := .T.
	default lMsgErr	:= .T.
	::oRestClient := FWRest():New(GetNewPar('ZZ_ELSURL','http://192.168.15.3:9200'))
	::oRestClient:setPath(GetNewPar('ZZ_ELSPRO', '/cbcep/end_busca/_search'))
	::oJsonRet := JsonObject():new()
	::aResult		:= {}
	::aRefResult	:= {}
	::cLastGet		:= ''
	::nLstResult	:= 0
	::aEscolhido	:= {}
	::lGetCompl		:= lComple
	::lMsgErr		:= lMsgErr
return(self)


method initScreen() class cbcCepElsSrc
	local lHasButton 		:= .T.
	local aItems 			:= {}
	local  nMilissegundos 	:= 300
	local oTimer			:= nil
	local oTFont 			:= TFont():New('Times New Roman',,-14,.T.)
	private oModal			:= nil
	private oContainer		:= nil
	private cGet1 			:= Space(60)
	private oListProd		:= nil
	private oBusca			:= nil
	private oSayEnd			:= nil

	oModal  := FWDialogModal():New()        
	oModal:SetEscClose(.T.)
	oModal:setTitle("Busca Endereço")
	oModal:setSize(240, 440)
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
	oModal:addOkButton({ || escolhe(self, oModal) }, "Escolher",{||.T.} )
	oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
	oContainer:SetCss(defCSS())
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT

	oListProd := TListBox():New(040,005,{|u|if(Pcount()>0, ::nLstResult := u, ::nLstResult)},aItems,420,140,{||.T.},oContainer,,,,.T.,,,oTFont)
	oListProd:BLDBLCLICK := {|| selecionado(self, .T.)}
	oListProd:hide()

	oBusca := TGet():New( 005, 005, {|u| if(Pcount() == 0,cGet1, getText(u, self))},;
	oContainer,420, 020, "!@",, 0, 16777215,oTFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cGet1",,,,lHasButton  )
	oBusca:SetContentAlign(-1)

	oTimer := TTimer():New(nMilissegundos, {|| oModal:OOWNER:CommitControls() }, oModal:OOWNER )
	oTimer:Activate()

	oModal:Activate()

	FreeObj(oTimer)
	FreeObj(oBusca)
	FreeObj(oSayEnd)
	FreeObj(oListProd)
	FreeObj(oContainer)
	FreeObj(oModal)
return(self)


method destroy() class cbcCepElsSrc
	::aResult 		:= nil
	::aRefResult	:= nil
	::nLstResult	:= nil
	::cLastGet		:= nil
	FreeObj(::oRestClient)
	FreeObj(::oJsonRet)
return(self)


method search(cQ) class cbcCepElsSrc
	local aHeader 	:= {}
	local cBoby 	:= ''
	default cQ		:= ''

	if Empty(alltrim(cQ)) .and. !empty(::cLastGet)
		oListProd:SetArray({})
		oListProd:Refresh()
		oListProd:hide()
		ProcessMessage()
	endif
	if !empty(alltrim(cQ))
		if ::cLastGet <> cQ
			::cLastGet := cQ
			aadd(aHeader, 'Content-Type: application/json')
			cBoby 	:= '{"from":0,"size":30,"query":{"match":{"END_BUSCA":{"query": "'+ Alltrim(cQ) +'"}}}}'
			::oRestClient:SetPostParams(cBoby)
			if ::oRestClient:Post(aHeader)
				doJson(::oRestClient:GetResult(),self, .T.)
			else
				MsgInfo(::oRestClient:GetLastError(), "Post")
			endif
		endif
	endif
return(self)


method onesearch(cQ) class cbcCepElsSrc
	local aHeader 	:= {}
	local cBoby 	:= ''
	local lRet		:= .F.
	aadd(aHeader, 'Content-Type: application/json')
	cBoby 	:= '{"from":0,"size":1,"query":{"match":{"CEP":{"query": "'+ Alltrim(cQ) +'"}}}}'
	::oRestClient:SetPostParams(cBoby)
	if ::oRestClient:Post(aHeader)
		lRet := .T.
		doJson(::oRestClient:GetResult(),self, .F.)
		if !empty(::aRefResult)
			::aEscolhido := ::aRefResult
			::nLstResult := 1
			selecionado(self, .F.)
		endif
	else
		lRet := .F.
	endif
return(lRet)

method customSearch(cQry) class cbcCepElsSrc
	local aHeader 	:= {}
	local oJson		:= JsonObject():new()
	local nTam		:= 0

	if !empty(AllTrim(cQry))
		oJson:fromJSON(cQry)
		aadd(aHeader, 'Content-Type: application/json')
		::oRestClient:SetPostParams(oJson:toJSON())
		if ::oRestClient:Post(aHeader)
			nTam := querySize(::oRestClient:GetResult())
			if nTam > 0
				oJson['size'] := nTam
				::oRestClient:SetPostParams(oJson:toJSON())
				if ::oRestClient:Post(aHeader)
					doJson(::oRestClient:GetResult(),self, .F.)
				elseif ::lMsgErr
					MsgInfo(::oRestClient:GetLastError(), "Post - 2")
				endif
			else
				doJson(::oRestClient:GetResult(),self, .F.)
			endif			
		elseif ::lMsgErr
			MsgInfo(::oRestClient:GetLastError(), "Post - 1")
		endif
	endif
	FreeObj(oJson)
return(self)

static function querySize(cJson)
	local nSize		:= 0
	local oJson		:= JsonObject():new()
	if !empty(cJson)
		oJson:fromJSON(cJson)
		if ValType(oJson:GetJsonObject('hits')) <> 'U'
			if ValType(oJson['hits']:GetJsonObject('total')) <> 'U'
				nSize := oJson['hits']['total']
			endif
		endif
	endif
	FreeObj(oJson)
return(nSize)


static function selecionado(oSelf, lScreen)
	local cRetorno	:= ''
	local cComple	:= Space(16)
	default lScreen	:= .T.
	if !u_isPortal() .and. !u_isAuto()
		if oSelf:lGetCompl
			if lScreen
				oBusca:hide()
				oListProd:hide()
				oSayEnd:show()
			endif
			cRetorno := FWInputBox("Numero/Complemento/Observação", cComple)
			cRetorno := Left(StrTran(cRetorno,';',''), 16)
			oSelf:aRefResult[oSelf:nLstResult][5] := ' Compl.: ' + Alltrim(cRetorno)
		endif
	endif
return(nil)


static function doJson(cJson,oSelf, lScreen, lMult)
	local aJson 		:= {}
	local cInfo			:= ''
	local aInfo			:= {}
	default lScreen		:= .T.
	default lMult		:= .T.
	oSelf:aResult 		:= {}
	oSelf:aRefResult 	:= {}
	oSelf:oJsonRet:fromJSON(cJson)

	aJson := oSelf:oJsonRet:GetJsonObject('hits')['hits']
	for nX := 1 to Len(aJson)
		aInfo := {}
		aJson[nX]:GetJsonObject('_source')['END_BUSCA'] := DecodeUTF8(aJson[nX]:GetJsonObject('_source')['END_BUSCA'])
		cInfo :=  aJson[nX]:GetJsonObject('_source')['END_BUSCA']
		aadd(aInfo, DecodeUTF8(aJson[nX]:GetJsonObject('_source')['CIDADE'] )) 
		aadd(aInfo, DecodeUTF8(aJson[nX]:GetJsonObject('_source')['UF']))
		aadd(aInfo, DecodeUTF8(aJson[nX]:GetJsonObject('_source')['ENDERECO']))
		aadd(aInfo, aJson[nX]:GetJsonObject('_source')['CEP'])
		aadd(aInfo, '')
		aadd(oSelf:aResult, cInfo)
		aadd(oSelf:aRefResult, aInfo)
	next nX
	if !empty(oSelf:aResult) .and. lScreen
		oListProd:SetArray(oSelf:aResult)
		oListProd:Refresh()
		oListProd:show()
		ProcessMessage()
	endif
return(nil)


static function getText(u,oSelf)
	cGet1 := u
	oSelf:search(u)
return(nil)


static function defCSS()
	local cCss	:= ''
	cCss += ""
return(cCss)


static function escolhe(oSelf, oModal)
	if !empty(oSelf:nLstResult)
		oSelf:aEscolhido := oSelf:aRefResult[oSelf:nLstResult]
		eval(oModal:BCLOSE)	
	endif
return(nil)


/**TEST ZONE**/
user function zPElsSrc(_cCampo1, _cCampo2)
	local oEls		:= cbcCepElsSrc():newcbcCepElsSrc(.F.)
	local aRet		:= {}
	local xRet		:= ''
	local cCampo1 := _cCampo1
	local cCampo2 := _cCampo2
	oEls:initScreen()
	aRet 			:= oEls:aEscolhido 
	
	if !empty(aRet)
		&cCampo2 		:= (aRet[ENDERECO] + ';' + aRet[COMPLEMENTO] + ';' +  aRet[CIDADE] + ';' +  aRet[UF])
		oEls:destroy()
		FreeObj(oEls)
		xRet := aRet[CEP] 
	endif
return (xRet)


user function zPElsVld(_cCampo1, _cCampo2)
	local lRet		:= .F.
	local xRet		:= ''
	local cCampo1 	:= _cCampo1
	local cCampo2	:= _cCampo2
	local oEls		:= cbcCepElsSrc():newcbcCepElsSrc(.T.)
	local cRotina	:= AllTrim(FunName())
	local lAchei	:= .F.
	
	if oEls:onesearch(Alltrim(&cCampo1))
		if !empty(aRet := oEls:aEscolhido)
			lRet := .T.
			&cCampo2 := (aRet[1,ENDERECO] + ';' + aRet[1,COMPLEMENTO] + ';' +  aRet[1,CIDADE] + ';' +  aRet[1,UF])
		else
			lRet := .F.
		endif
	endif
	if !lRet
		if  !u_isPortal() .and. !u_isAuto()
			if MsgNoYes('Utilizar o mesmo endereço do Cliente de Faturamento?' )
				&cCampo1 := ''
				&cCampo2 := '' 
				DbSelectArea("SA1")
				DbSetOrder(1)
				If cRotina == "MATA410"
					lAchei =MsSeek(xFilial("SA1")+M->C5_CLIENT+M->C5_LOJAENT)
				ElseIf cRotina =="MATA415"
					lAchei = MsSeek(xFilial("SA1")+M->CJ_CLIENT+M->CJ_LOJAENT)
				EndIf
				If lAchei == .T.	
					&cCampo1 := '-'
					&cCampo2 := Alltrim(SA1->A1_CEP)
					&cCampo2 += " " + Alltrim(SA1->A1_END)
					&cCampo2 += "; " + Alltrim(SA1->A1_BAIRRO)
					&cCampo2 += ";" + Alltrim(SA1->A1_MUN)
					&cCampo2 += ";" + Upper(SA1->A1_EST)
				Else
					MessageBox("Não Foi Possível Obter o Endereço do Cliente","Endereço Cliente",MB_ICONHAND)
				EndIf
				lRet := .T.
			else
				Help("Cep",1,cCampo2,"Cep Entrega","Cep Inválido",,,,,,,,{"Verificar Cep Digitado"} )
			endif
		else
			Help("Cep",1,cCampo2,"Cep Entrega","Cep Inválido",,,,,,,,{"Verificar Cep Digitado"} )
		endif
	endif
	oEls:destroy()
	FreeObj(oEls)
return (lRet)

