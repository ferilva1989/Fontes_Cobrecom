#include 'protheus.ch'

/*/{Protheus.doc} cbcLabelCtrl
//TODO Definição da classe que controlora o objeto do leiaute.
@author bolognesi
@since 07/01/2019
@version 1.0
@type class
/*/
class cbcLabelCtrl 
	data oMainLayout
	data oLineContent
	data nEditLine
	data lEditCtrl
	method newcbcLabelCtrl() constructor 
	method initLayout()
	method initFrmJson()
	method editLine()
	method setTipo()
	method setCampo()
	method setHdrCont()
	method setItm()
	method delItm()
	method confirm()
	method canEdit()
	method getJsonaLin()
	
	method toJSON()
endclass


/*/{Protheus.doc} newcbcLabelCtrl
//TODO Metodo contrutor da classe.
@author bolognesi
@since 07/01/2019
@version 1.0
@type function
/*/
method newcbcLabelCtrl() class cbcLabelCtrl
	::nEditLine := 1
	::lEditCtrl	:= .F.
return(self)


/*/{Protheus.doc} initFrmJson
//TODO Metodo instacia o objeto(vazio) leiaute conforme modelo definifo na classe cbcMstLayout() .
@author juliana.leme
@since 07/01/2019
@version 1.0
@return ${return}, ${return_description}
@param cJson, characters, descricao
@type function
/*/
method initFrmJson(cJson) class cbcLabelCtrl
	local wrk	:= nil
	
	::oMainLayout := cbcMstLayout():newcbcMstLayout()
	wrk := JsonObject():new()
	wrk:fromJSON(cJson)
	::oMainLayout:nRec 		:= wrk['RECNO']
	::oMainLayout:cTabela 	:= wrk['TABELA'] 
	::oMainLayout:cLayout 	:= wrk['LAYOUT'] 
	FWJsonDeserialize(wrk['ALINHA'],@::oMainLayout:aLinha)
	
	FreeObj(wrk)
return(self) 


/*/{Protheus.doc} initLayout
//TODO Inicia Objeto leiaute a partir de um layout ja definido.
@author bolognesi
@since 07/01/2019
@version 1.0
@param nRec, numeric, descricao
@param cFrom, characters, descricao
@param cLayout, characters, descricao
@type function
/*/
method initLayout(nRec, cFrom, cLayout) class cbcLabelCtrl
	::oMainLayout := cbcMstLayout():newcbcMstLayout(nRec, cFrom, cLayout)
return(self) 


/*/{Protheus.doc} canEdit
//TODO Metodo que valida edição da linha do leiaute.
@author juliana.leme
@since 07/01/2019
@version 1.0
@type function
/*/
method canEdit() class cbcLabelCtrl
	if ! ::lEditCtrl
		MsgInfo('Utilize metodo editLine para informar a linha que deve ser editada!')
	endif
return(::lEditCtrl)


/*/{Protheus.doc} editLine
//TODO Edita a linha do leiaute.
@author bolognesi
@since 07/01/2019
@version 1.0
@param nLinha, numeric, descricao
@type function
/*/
method editLine(nLinha) class cbcLabelCtrl
	::oLineContent	:= nil
	::nEditLine 	:= nLinha
	::oLineContent 	:= cbcMdlLabel():newcbcMdlLabel()
	::lEditCtrl		:= .T.
return(self)

/*/{Protheus.doc} confirm
//TODO Confirma opação de edição da linha.
@author bolognesi
@since 07/01/2019
@version 1.0
@type function
/*/
method confirm() class cbcLabelCtrl
	if ::canEdit()
		::oMainLayout:editLine(::nEditLine, ::oLineContent)
		::nEditLine  := 0
		::lEditCtrl	:= .F.
	endif
return(self)


/*/{Protheus.doc} setTipo
//TODO Seta tipo de edição da linha se P o L.
@author bolognesi
@since 07/01/2019
@version 1.0
@param cTp, characters, descricao
@type function
/*/
method setTipo(cTp) class cbcLabelCtrl
	if ::canEdit()
		::oLineContent:cTipo := cTp
	endif
return(self)

/*/{Protheus.doc} setCampo
//TODO Seta Campo conforme leiaute definido.
@author bolognesi
@since 07/01/2019
@version 1.0
@param cCmp, characters, descricao
@type function
/*/
method setCampo(cCmp) class cbcLabelCtrl
	if ::canEdit()
		::oLineContent:cCampo := cCmp
	endif
return(self)


/*/{Protheus.doc} setItm
//TODO Seta Item .
@author bolognesi
@since 07/01/2019
@version 1.0
@return ${return}, ${return_description}
@param aCont, array, descricao
@type function
/*/
method setItm(aCont) class cbcLabelCtrl
	local nPos 	:= 0
	local nX	:= 0
	if ::canEdit()
		for nX := 1 to len(aCont)
			if (nPos := ASCan(::oLineContent:aConteudo,{|a| Alltrim(a[1] == aCont[nX,1] )})) > 0
				::oLineContent:aConteudo[nPos] := aCont[nX]
			else
				aadd(::oLineContent:aConteudo , aCont[nX])
			endif
		next nX
	endif
return(self)

/*/{Protheus.doc} delItm
//TODO deleta item do objeto.
@author bolognesi
@since 07/01/2019
@version 1.0
@param cItm, characters, descricao
@type function
/*/
method delItm(cItm) class cbcLabelCtrl
	local nPos 	:= 0
	local nTam	:= 0
	if ::canEdit()
		if (nPos := ASCan(::oLineContent:aConteudo,{|a| Alltrim(a[1] == cItm)})) > 0
			nTam := len(::oLineContent:aConteudo) - 1
			Adel(::oLineContent:aConteudo,nPos )
			ASize(::oLineContent:aConteudo, nTam)
		endif
	endif
return(self)


/*/{Protheus.doc} setHdrCont
//TODO seta Header.
@author bolognesi
@since 07/01/2019
@version 1.0
@param cCont, characters, descricao
@type function
/*/
method setHdrCont(cCont) class cbcLabelCtrl
	if ::canEdit()
		::oLineContent:cConteudo := Alltrim(cCont)
	endif
return(self)


/*/{Protheus.doc} toJSON
//TODO Tranforma o objeto em uma variavel Json Caracter.
@author bolognesi
@since 07/01/2019
@version 1.0
@type function
/*/
method toJSON() class cbcLabelCtrl
	local wrk		:= nil
	local wrkArr	:= nil
	local cJson	:= ''
	wrk := JsonObject():new()
	wrk['RECNO']  	:= ::oMainLayout:nRec
	wrk['TABELA']  	:= ::oMainLayout:cTabela
	wrk['LAYOUT']  	:= ::oMainLayout:cLayout
	wrk['ALINHA'] 		:= FWJsonSerialize(::oMainLayout:aLinha,.F.,.F.)
	cJson := wrk:toJSON( )
	FreeObj(wrk)
return(cJson)


/*/{Protheus.doc} getJsonaLin
//TODO Metodo que retorna um objeto em array.
@author juliana.leme
@since 07/01/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
method getJsonaLin() class cbcLabelCtrl
	Local aTemp		:= {} 

	aTemp := ::oMainLayout:aLinha
return(aTemp)


/*/{Protheus.doc} zxTstLbl
//TODO Testa a classe.
@author bolognesi
@since 07/01/2019
@version 1.0
@type function
/*/
user function zxTstLbl()
	local oCtrLabel	:= nil
	local oCtrFrmJs	:= nil
	local aCont		:= {}
	local cStrGrava	:= ''

	oCtrLabel := cbcLabelCtrl():newcbcLabelCtrl()
	oCtrLabel:initLayout(238027, 'SC5') 

	oCtrLabel:editLine(1)
	oCtrLabel:setTipo('F')
	oCtrLabel:setCampo('C5_NUM')
	oCtrLabel:confirm()

	oCtrLabel:editLine(2)
	oCtrLabel:setTipo('F')
	oCtrLabel:setCampo('C6_PEDIDO')
	oCtrLabel:confirm()

	oCtrLabel:editLine(3)
	oCtrLabel:setTipo('M')
	oCtrLabel:setHdrCont('Conteudo Fixo Header')
	oCtrLabel:confirm()

	oCtrLabel:editLine(4)
	oCtrLabel:setTipo('M')
	aadd(aCont, {'01', 'Conteudo Item 01'})
	aadd(aCont, {'03', 'Conteudo Item 03'})
	oCtrLabel:setItm(aCont)

	aCont := {}
	aadd(aCont, {'01', 'Sobrescrito Item 01'})
	aadd(aCont, {'03', 'Sobrescrito Item 03'})
	aadd(aCont, {'02', 'Novo Item 02'})
	aadd(aCont, {'02', 'Sobrescrito Item 02'})
	oCtrLabel:setItm(aCont)
	oCtrLabel:delItm('02')
	oCtrLabel:confirm()

	// Obtem o JSON em forma de string
	cStrGrava := oCtrLabel:toJSON()

	// Gera um novo Objeto (a partir de um JSON)
	oCtrFrmJs := cbcLabelCtrl():newcbcLabelCtrl()
	oCtrFrmJs:initFrmJson(cStrGrava)

	FreeObj(oCtrLabel)
return(nil)
