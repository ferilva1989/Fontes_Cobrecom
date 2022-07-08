#include 'protheus.ch'
#define NOME_CAMPO 	1
#define CONTEUDO    2
#define NULO		3
#define VLD			2
#define VLD_USR		3

/*/{Protheus.doc} cbcSC5
@author bolognesi
@since 20/12/2016
@version 1.0
@type class
@description Classe com responsabilidade dobre cabeçalho
do SC5 para execauto
/*/
class cbcSC5   
	data aHeader
	data aSC6Itens
	data aCmpVlr
	data aCmpObr
	data aCmpVld
	data cPvNro
	data cIdNro
	data oArea
	data cNextItem
	method newcbcSC5() constructor 
	method addHdr()
	method makeHeader()
	method getHeader()
	method getItens()
	method vldObr()
	method getIdPort()
	method setIdPort()
	method getPvNro()
	method setPvNro()
	method initItem()
	method addItem()
	method nextItem()
endclass

/*/{Protheus.doc} newcbcSC5
@author bolognesi
@since 20/12/2016
@version 1.0
@type method
@description Construtor da classe
/*/
method newcbcSC5() class cbcSC5
	::aCmpVlr 	:= {}
	::aCmpObr 	:= {}
	::aHeader 	:= {}
	::aSC6Itens := {}
	::aCmpVld	:= {}
	::oArea 	:= SigaArea():newSigaArea()
	::setIdPort("")
	::initItem()
return (self)

/*/{Protheus.doc} getIdPort
@author bolognesi
@since 02/01/2017
@version 1.0
@type method
@description Retorna o conteudo da propriedade
cIdNro que no contexto representa o numero do
documento no Portal
/*/
method getIdPort() class cbcSC5
return (::cIdNro)

/*/{Protheus.doc} setIdPort
@author bolognesi
@since 02/01/2017
@version 1.0
@param cNum, characters, Valor a ser atribuido na propriedade cIdNro 
@type method
@description Definir o valor da propriedade cIdNro
/*/
method setIdPort(cNum) class cbcSC5
::cIdNro := cNum
return (self)

/*/{Protheus.doc} getPvNro
@author bolognesi
@since 02/01/2017
@version 1.0
@type method
@description Retorna o conteudo da propriedade
cPvNro que no contexto representa o numero do
pedido de venda gerado no sistema pelo execauto
/*/
method getPvNro() class cbcSC5
return(::cPvNro)

/*/{Protheus.doc} setPvNro
@author bolognesi
@since 02/01/2017
@version 1.0
@param cNum, characters, Valor a ser atribuido na propriedade cPvNro 
@type method
@description Definir o valor da propriedade cPvNro
/*/ 
method setPvNro(cNum) class cbcSC5
::cPvNro := cNum
return(self)

/*/{Protheus.doc} initItem
@author bolognesi
@since 10/04/2017
@version 1.0
@type method
@description Metodo para zerar a propriedade
cNextItem, Utilizado para iniciar a contagem sequencial
dos valores retornados pelo metodo nextItem() que nada mais
é que soma1() nesta propriedade.
/*/
method initItem() class cbcSC5
	::cNextItem	:= StrZero(0,TamSx3('C6_ITEM')[1])
return(self)

/*/{Protheus.doc} addItem
@author bolognesi
@since 20/12/2016
@version undefined
@param oSC6Item, object, Estancia da classe cbcSC6Itens
@type method
@description Metodo que adiciona um objeto da classe cbcSC6Itens
no array de itens
/*/
method addItem(oSC6Itm) class cbcSC5
	//TODO obter nome da classe para validar
	If !Empty(oSC6Itm) 
		AAdd(::aSC6Itens,oSC6Itm:getCampo() )
	EndIF
return (self)

/*/{Protheus.doc} getItens
@author bolognesi
@since 20/12/2016
@version 1.0
@type method
@description retorna os itens no formato do array para execauto
/*/
method getItens() class cbcSC5
return(::aSC6Itens)

/*/{Protheus.doc} nextItem
@author bolognesi
@since 21/12/2016
@version 1.0
@type method
@description Obter o proximo numero de item
/*/
method nextItem() class cbcSC5
	::cNextItem := soma1(::cNextItem)
return (::cNextItem)

/*/{Protheus.doc} addHdr
@author bolognesi
@since 20/12/2016
@version undefined
@param aCmp, array, Contem um campo do SC5 e um valor para este campo
Ex:{"C5_FILIAL",cDestFil}
@type method
/*/
method addHdr(aCmp) class cbcSC5
	If !Empty(aCmp)
		AAdd(::aCmpVlr, aCmp )
	EndIF
return (self)

/*/{Protheus.doc} getHeader
@author bolognesi
@since 20/12/2016
@version undefined
@type method
@description Obter conteudo da propriedade ::aHeader
/*/
method getHeader() class cbcSC5
return (::aHeader)

/*/{Protheus.doc} makeHeader
@author bolognesi
@since 20/12/2016
@version 1.0
@type method
@description Cria o cabeçalho para o execauto, iniciando as variaveis 
do SC5
/*/
method makeHeader() class cbcSC5
	Local _cConteudo	:= ""
	Local nPos			:= 0
	Local aVld			:= {}
	Local aVldUsr		:= {}

	DbSelectArea("SX3")
	DbSetOrder(1)
	SX3->(DbSeek("SC5", .F.))
	While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SC5"
		aVld 	:= {}
		aVldUsr := {}
		If X3Obrigat(SX3->(X3_CAMPO))
			AAdd(::aCmpObr, SX3->(X3_CAMPO))
		Endif
		//Obter as validações dos campos
		If !Empty( SX3->(X3_VALID) )
			AAdd(aVld,Alltrim(SX3->(X3_VALID)))
		EndIf
		If !Empty( SX3->(X3_VLDUSER) )
			AAdd(aVldUsr,Alltrim(SX3->(X3_VLDUSER)))
		EndIf
		If !Empty(aVld) .Or. !Empty(aVldUsr)
			AAdd(::aCmpVld,{ Alltrim(SX3->X3_CAMPO), aVld, aVldUsr})
		EndIf	
		//Obtem os valores dos campos
		nPos := AScan(::aCmpVlr,{|a| a[NOME_CAMPO] == Alltrim(SX3->X3_CAMPO) })
		If nPos > 0
			aAdd(::aHeader,array(3))
			::aHeader[Len(::aHeader),NOME_CAMPO] 	:= Alltrim(SX3->X3_CAMPO)
			::aHeader[Len(::aHeader),CONTEUDO] 		:= ::aCmpVlr[nPos,CONTEUDO]
			::aHeader[Len(::aHeader),NULO] 			:= nil
		EndIf
		SX3->(dbSkip())
	End
return (self)

/*/{Protheus.doc} vldObr
@author bolognesi
@since 19/12/2016
@version 1.0
@type method
@description Validar se todos os campos obrigatorios foram preenchidos
no array do execauto
/*/
method vldObr() class cbcSC5
	Local lOk	:= .T.
	Local aErr	:= {}
	Local nX	:= 0
	Local nPos	:= 0

	If !Empty(::aHeader) .And. !Empty(::aCmpObr)
		For nX := 1 To Len(::aHeader)
			nPos := AScan(::aCmpObr,{|a| Alltrim(a) == Alltrim(::aHeader[nX][NOME_CAMPO])})
			If nPos > 0
				If Empty(::aHeader[nX][CONTEUDO])
					AAdd(aErr,::aHeader[nX][NOME_CAMPO])
				EndIF
			EndIf
		Next nX

		If !Empty(aErr)
			lOk := .F.
		EndiF
	EndIf
return ({lOk, aErr})

/* TEST ZONE */
User Function zCbcSC5() // U_zCbcSC5()
	Local oC5 := cbcSC5():newcbcSC5()
	Local aRet	:={}
	Local aVld	:= {}
	Local nX	:= 0
	Local cTxt	:= ""

	oC5:addHdr({"C5_FILIAL"	,FwFilial()})
	oC5:addHdr({"C5_TIPO"	,"N"})
	oC5:addHdr({"C5_CLIENTE","N"})
	oC5:addHdr({"C5_LOJACLI","N"})
	oC5:addHdr({"C5_TIPOCLI","N"})
	oC5:addHdr({"C5_CONDPAG","N"})
	oC5:addHdr({"C5_LAUDO"	,"N"})
	oC5:addHdr({"C5_TPFRETE","N"})
	oC5:addHdr({"C5_CLIOK"	,"N"})
	oC5:makeHeader()

	aRet := oC5:vldObr()
	If !aRet[1]
		cTxt += '[ERRO]-Campos obrigatorios não preenchidos' + chr(13)
		For nX := 1 To Len(aRet[2])
			cTxt += aRet[2][nX] + chr(13) 
		Next nX
		Alert(cTxt)
	Else
		Alert('TUDO OK!')
		//oC5:getHeader()
	EndIf

return (Nil)
