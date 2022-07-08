#include 'protheus.ch'
#include "rwmake.ch"

/*/{Protheus.doc} cbcFatRemesCtrle
Classe de controle para a geração das NFs de Remessa do tipo de operação 29 conforme operação de Remessa
@author    juliana.leme
@since     18/06/2019
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
class cbcFatRemesCtrle
	data cProxDoc
	data aCabecalho
	data aItems
	data aRetNFEspelho
	data cCliEspelho
	data cLojEspelho
	data cSerie
	data cNumNota

	method newcbcFatRemesCtrle() constructor
	method PosTabelas()
	method ProxNumDoc()
	method MontaCabec()
	method MontaItems()
	method RetCliLojRemes()
	method MontaNFEspelho()
	method AtuSX5NumNota()
endclass

/*/{Protheus.doc} new
Metodo construtor
@author    juliana.leme
@since     18/06/2019
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
method newcbcFatRemesCtrle() class cbcFatRemesCtrle
	::cProxDoc 		:= ""
	::aCabecalho	:= {}
	::aItems		:= {}
	::aRetNFEspelho	:= {}
	::cCliEspelho	:= ""
	::cLojEspelho	:= ""
	::cSerie		:= ""
	::cNumNota		:= ""
return(self)

/*/{Protheus.doc} ProxNumDoc
//TODO Seleciona o proximo numero disponivel de Nf para geração da NF espelho.
@author juliana.leme
@since 25/06/2019
@version 1.0
@type function
/*/
method ProxNumDoc(cSer) class cbcFatRemesCtrle
	local cQry		:= ""
	local oResult 	:= LibSqlObj():newLibSqlObj()
	local lSerie	:= .F.
	default cSer	:= ''
	
	if empty(cSer)
		//Captura a Serie
		MsgBox("Escolha o numero para a NF Espelho de Remessa ... ","INFO","INFO")
		do while empty(::cSerie) .And. !lSerie
			::cSerie  := ""
			lSerie := Sx5NumNota(@::cSerie,)
		enddo
	else
		::cSerie  := cSer
		lSerie 	  := .T.
	endif
	cQry += " 	SELECT MAX(F2_DOC) NUMDOC "
	cQry += " FROM %SF2.SQLNAME% WITH (NOLOCK)  "
	cQry += " WHERE %SF2.XFILIAL% "
	cQry += " 	AND SF2.F2_SERIE  = '" + ::cSerie + "'"
	cQry += " 	AND %SF2.NOTDEL% "
		
	oResult:newAlias(cQry)
	if oResult:hasRecords()
		::cProxDoc  := Soma1(oResult:getValue("NUMDOC"))
	endif
	oResult:close() 	
	FreeObj(oResult)
return(self)

/*/{Protheus.doc} MontaCabec
//TODO Monta Cabecalho de geração da NF.
@author juliana.leme
@since 25/06/2019
@version 1.0
@param nRecSF2, numeric, Numero do Recno de geração do F2 da NF Espelho
@type function
/*/
method MontaCabec(nRecSF2) class cbcFatRemesCtrle
	local cMsgNota	:= ""
	
	SF2->(DbGoTo(nRecSF2))
	cMsgNota	:= Alltrim(SF2->F2_MENNOTA) + " NOTA FISCAL: " + ::cSerie + "/" + ::cProxDoc + " DE REMESSA DE ENTREGA REFERENTE NOSSA " +;
	 					"NOTA FISCAL: " + SF2->F2_SERIE + "/" + SF2->F2_DOC + " SIMPLES FATURAMENTO DOS PRODUTOS"
	::aCabecalho := {}
	aadd(::aCabecalho,{"F2_TIPO"		,SF2->F2_TIPO})
	aadd(::aCabecalho,{"F2_FORMUL"		,SF2->F2_FORMUL})
	aadd(::aCabecalho,{"F2_DOC"			,::cProxDoc })
	aadd(::aCabecalho,{"F2_SERIE"		,::cSerie})
	aadd(::aCabecalho,{"F2_EMISSAO"		,SF2->F2_EMISSAO})
	aadd(::aCabecalho,{"F2_CLIENTE"		,::cCliEspelho})
	aadd(::aCabecalho,{"F2_LOJA"		,::cLojEspelho})
	aadd(::aCabecalho,{"F2_ESPECIE"		,SF2->F2_ESPECIE})
	aadd(::aCabecalho,{"F2_VALBRUT"		,SF2->F2_VALMERC})
	aadd(::aCabecalho,{"F2_VALMERC"		,SF2->F2_VALMERC})
	aadd(::aCabecalho,{"F2_NFORI"		,SF2->F2_NFORI})
	aadd(::aCabecalho,{"F2_SERIORI"		,SF2->F2_SERIORI})
	aadd(::aCabecalho,{"F2_ESPECI1"		,SF2->F2_ESPECI1})
	aadd(::aCabecalho,{"F2_VOLUME1"		,SF2->F2_VOLUME1})
	aadd(::aCabecalho,{"F2_ICMSRET"		,SF2->F2_ICMSRET})
	aadd(::aCabecalho,{"F2_PLIQUI"		,SF2->F2_PLIQUI})
	aadd(::aCabecalho,{"F2_PBRUTO"		,SF2->F2_PBRUTO})
	aadd(::aCabecalho,{"F2_TRANSP"		,SF2->F2_TRANSP})
	aadd(::aCabecalho,{"F2_BRICMS"		,SF2->F2_BRICMS})
	aadd(::aCabecalho,{"F2_HORA"		,SF2->F2_HORA})
	aadd(::aCabecalho,{"F2_MOEDA"		,SF2->F2_MOEDA})
	aadd(::aCabecalho,{"F2_EMISORI"		,SF2->F2_EMISORI})
	aadd(::aCabecalho,{"F2_CDROMA"		,SF2->F2_CDROMA})
	aadd(::aCabecalho,{"F2_CLIENT"		,::cCliEspelho})
	aadd(::aCabecalho,{"F2_LOJAENT"		,::cLojEspelho})
	aadd(::aCabecalho,{"F2_CDCARGA"		,SF2->F2_CDCARGA})
	aadd(::aCabecalho,{"F2_TPFRETE"		,SF2->F2_TPFRETE})
	aadd(::aCabecalho,{"F2_COND"		,SF2->F2_COND})
	aadd(::aCabecalho,{"F2_DESCONT"		,SF2->F2_DESCONT})
	aadd(::aCabecalho,{"F2_FRETE"		,SF2->F2_FRETE})
	aadd(::aCabecalho,{"F2_SEGURO"		,SF2->F2_SEGURO})
	aadd(::aCabecalho,{"F2_MENNOTA"		,cMsgNota})
	aadd(::aCabecalho,{"F2_DESPESA"		,0})
return(self)

/*/{Protheus.doc} MontaItems
//TODO Monta Header de geração das NFs Espelho.
@author juliana.leme
@since 25/06/2019
@version 1.0
@param aRecD2, array, Array de Recno do SD2 a serem gerados como espelho
@type function
/*/
method MontaItems(aRecD2) class cbcFatRemesCtrle
	local cItem		:= StrZero(0,Len(SD2->D2_ITEM))
	local nCont 	:= 1
	local aItSD2 	:= {}
	local cTipoOper	:= SuperGetMv("MV_ZZOPREM",,"29")
	local cTes		:= ""
	
	for nCont := 1 to len(aRecD2)
		aItSD2 	:= {}
		SD2->(DbGoTo(aRecD2[nCont]))
		cItem :=  soma1(cItem)
		cTes := u_CDTesInt(cTipoOper,SA1->A1_TIPO,.F.)
		aadd(aItSD2,{"D2_ITEM"		,cItem				,Nil})
		aadd(aItSD2,{"D2_COD"		,SD2->D2_COD		,Nil})
		aadd(aItSD2,{"D2_DESCRI"	,SD2->D2_DESCRI		,Nil})
		aadd(aItSD2,{"D2_UM"		,SD2->D2_UM			,Nil})
		aadd(aItSD2,{"D2_QUANT"		,SD2->D2_QUANT		,Nil})
		aadd(aItSD2,{"D2_PRCVEN"	,SD2->D2_PRCVEN		,Nil})
		aadd(aItSD2,{"D2_TOTAL"		,SD2->D2_TOTAL		,Nil})
		aadd(aItSD2,{"D2_TES"		,cTes				,Nil})
		aadd(aItSD2,{"D2_PESO"		,SD2->D2_PESO		,Nil})
		aadd(aItSD2,{"D2_CONTA"		,SD2->D2_CONTA		,Nil})
		aadd(aItSD2,{"D2_CLIENTE"	,::cCliEspelho		,Nil})
		aadd(aItSD2,{"D2_LOJA"		,::cLojEspelho		,Nil})
		aadd(aItSD2,{"D2_EMISSAO"	,SD2->D2_EMISSAO	,Nil})
		aadd(aItSD2,{"D2_TP"		,SD2->D2_TP			,Nil})
		aadd(aItSD2,{"D2_EMISSAO"	,SD2->D2_EMISSAO	,Nil})
		aadd(aItSD2,{"D2_GRUPO"		,SD2->D2_GRUPO		,Nil})
		aadd(aItSD2,{"D2_CUSTO1"	,SD2->D2_CUSTO1		,Nil})
		aadd(aItSD2,{"D2_PRUNIT"	,SD2->D2_PRUNIT		,Nil})
		aadd(::aItems,aItSD2)
	next
return(self)

/*/{Protheus.doc} MontaNFEspelho
//TODO Realiza a geração da NF espelho.
@author juliana.leme
@since 25/06/2019
@version 1.0
@type function
/*/
method MontaNFEspelho() class cbcFatRemesCtrle
	local nX				:= 1
	local aErro				:= {}
	local cErro				:= ""
	local cNumDOC 			:= ""
	private	lMsErroAuto		:= .F.
	private lMsHelpAuto		:= .T.
	private lAutoErrNoFile	:= .T.

	FWMsgRun(, { || cNumDOC := MATA920(::aCabecalho,::aItems) }, "Gerando NF de Remessa", "Processando a geração da NF de Remessa, Aguarde ... ")
	if lMsErroAuto
		aErro := GetAutoGrLog()
		for nX := 1 to len(aErro)
			cErro += aErro[nX] + LINHA
		next nX
		::aRetNFEspelho	:= {cErro,.F.,::cSerie+"/"+::cProxDoc}
		MsgInfo(cErro)
		MsgInfo("ERRO!! Nota Fiscal Numero: "+::cSerie+"/"+::cProxDoc)
		DisarmTransaction()
	else
		::aRetNFEspelho	:= {"",.T.,::cSerie+"/"+::cProxDoc}
		::AtuSX5NumNota()
		MsgInfo("Nota Fiscal Numero: "+::cSerie+"/"+::cProxDoc+" criada com sucesso!")
	endif
return(self)

/*/{Protheus.doc} RetCliLojRemes
//TODO Retorna o codigo do cliente do qual sera gerada a Remessa de faturamento.
@author juliana.leme
@since 25/06/2019
@version 1.0
@param cNumPedOri, characters, Numero do Pedido de Origem
@type function
/*/
method RetCliLojRemes(cNumPedOri) class cbcFatRemesCtrle
	local cQry		:= ""
	local oResult 	:= LibSqlObj():newLibSqlObj()
	local lRet		:= .T.
	
	cQry += " SELECT "
	cQry += " 	C5_ZZCLIEN CLIENTE_ENTREGA, "
	cQry += " 	C5_ZZLOJEN LOJA_ENTREGA "
	cQry += " FROM %SC5.SQLNAME% WITH (NOLOCK)  "
	cQry += " WHERE %SC5.XFILIAL% "
	cQry += " 	AND SC5.C5_NUM  = '" + cNumPedOri + "'"
	cQry += " 	AND %SC5.NOTDEL% "
		
	oResult:newAlias(cQry)
	if oResult:hasRecords()
		::cCliEspelho := oResult:getValue("CLIENTE_ENTREGA")
		::cLojEspelho := oResult:getValue("LOJA_ENTREGA")
		DbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		SA1->(DbSeek(xFilial("SA1")+::cCliEspelho+::cLojEspelho,.F.))
		lRet := .T.
	else
		::cCliEspelho := ""
		::cLojEspelho := ""
		lRet := .F.
	endif
	oResult:close() 	
	FreeObj(oResult)
return(lRet)

/*/{Protheus.doc} AtuSX5NumNota
//TODO Atualiza a proxima numeração do X5Nota.
@author juliana.leme
@since 25/06/2019
@version 1.0
@type function
/*/
method AtuSX5NumNota() class cbcFatRemesCtrle
	local cbcArea2 := GetArea()
	
	DbSelectArea("SX5")
	SX5->(DbSetOrder(1))
	if DbSeek(xFilial("SX5")+"01"+::cSerie)
		RecLock("SX5",.F.)
		SX5->X5_DESCRI  := Soma1(Alltrim(::cProxDoc))
		SX5->X5_DESCSPA := Soma1(Alltrim(::cProxDoc))
		SX5->X5_DESCENG := Soma1(Alltrim(::cProxDoc))
		MsUnlock()
	endif
	RestArea(cbcArea2)
return(self)