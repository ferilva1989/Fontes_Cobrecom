#include 'protheus.ch'
#include 'parmtype.ch'

#define CRLF Chr(13)+Chr(10)

/*/{Protheus.doc} cbcInTransCtrl
(long_description)
@author    juliana.leme
@since     12/02/2020
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
class cbcInTransCtrl
	data oDados
	data oItens
	data aCabec
	data aItens
	data lOk
	data cMsgErr
	
	method newcbcInTransCtrl() constructor
	method isOk()
	method criaCabec() 
	method criaItens()
	method IncNotas()
	method setStatus()
endclass

/*/{Protheus.doc} newcbcInTransCtrl
Metodo construtor
@author    juliana.leme
@since     12/02/2020
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
method newcbcInTransCtrl(aDadosNF) class cbcInTransCtrl
	begin sequence
		::cMsgErr	:= ""
		::aCabec	:= {}
		::aItens	:= {}
		::oDados	:= aDadosNF
		::oItens 	:= ::oDados:GetJSonObject('ITENS')
		::setStatus()
		recover
	end sequence
return(self)

method isOk() class cbcInTransCtrl
return(::lOk)

method criaCabec() class cbcInTransCtrl
	aadd(::aCabec,{"F1_DOC"		,::oDados:GetJSonObject('F1_DOC')		, nil})
	aadd(::aCabec,{"F1_SERIE"	,::oDados:GetJSonObject('F1_SERIE')  	, nil})
	aadd(::aCabec,{"F1_FORNECE"	,::oDados:GetJSonObject('F1_FORNECE')	, nil})
	aadd(::aCabec,{"F1_LOJA"	,::oDados:GetJSonObject('F1_LOJA')		, nil})
	aadd(::aCabec,{"F1_EMISSAO"	,StoD(::oDados:GetJSonObject('F1_EMISSAO'))	, nil})
	aadd(::aCabec,{"F1_TIPO"	,::oDados:GetJSonObject('F1_TIPO')		, nil})
	aadd(::aCabec,{"F1_FORMUL"	,::oDados:GetJSonObject('F1_FORMUL')	, nil})
	aadd(::aCabec,{"F1_ESPECIE"	,::oDados:GetJSonObject('F1_ESPECIE')	, nil})
	aAdd(::aCabec,{"F1_DTDIGIT"	,::oDados:GetJSonObject('F1_DTDIGIT')	, nil})
	aAdd(::aCabec,{"F1_CHVNFE"	,::oDados:GetJSonObject('F1_CHVNFE')	, nil})
	aadd(::aCabec,{"F1_COND"	,::oDados:GetJSonObject('F1_COND')		, nil})
	aadd(::aCabec,{"F1_DESPESA"	,::oDados:GetJSonObject('F1_DESPESA')	, nil})
	aadd(::aCabec,{"F1_ORIGEM"	,"cbcInTrC"								, nil } )
return(self)

method criaItens() class cbcInTransCtrl
	local aItemDoc 	:= {}
	local cOperacao	:= GetNewPar('ZZ_TRIAOPE','52') 
	DbSelectArea("SB1")
	DbSelectArea("SA2")
	//Itens do Documento de Entrada
	for nCont := 1 to Len(::oItens)	
		aItemDoc := {}
		aAdd(aItemDoc,{"D1_ITEM"	, ::oItens[nCont]:GetJSonObject('D1_ITEM')	, nil})
		aadd(aItemDoc,{"D1_COD"		, ::oItens[nCont]:GetJSonObject('D1_COD')	, nil})
		aadd(aItemDoc,{"D1_QUANT" 	, ::oItens[nCont]:GetJSonObject('D1_QUANT')	, nil})
		aadd(aItemDoc,{"D1_LOCAL"	, ::oItens[nCont]:GetJSonObject('D1_LOCAL')	, nil})
		aadd(aItemDoc,{"D1_VUNIT"	, ::oItens[nCont]:GetJSonObject('D1_VUNIT')	, nil})
		aadd(aItemDoc,{"D1_TOTAL"	, ::oItens[nCont]:GetJSonObject('D1_TOTAL')	, nil})
		aadd(aItemDoc,{"D1_VALICM"	, ::oItens[nCont]:GetJSonObject('D1_VALICM'), nil})
		aadd(aItemDoc,{"D1_CLASFIS"	, ::oItens[nCont]:GetJSonObject('D1_CLASFIS'), nil})
		aadd(aItemDoc,{"D1_PICM"	, ::oItens[nCont]:GetJSonObject('D1_PICM')	, nil})
		aadd(aItemDoc,{"D1_OPER"	, cOperacao									, nil})
		aadd(::aItens, aItemDoc)
	next
	SB1->(DbCloseArea())
	SA2->(DbCloseArea())
return(self)

method IncNotas() class cbcInTransCtrl
	local cMsg	:= ""
	
	MSExecAuto( { |x,y,z| MATA103(x,y,z) },::aCabec,::aItens,3 )
	if lMsErroAuto
			aErro 	:= GetAutoGrLog()
		cMsg 	:= ""
		for nX := 1 to 3
			cMsg += aErro[nX] + CRLF
		next nX
		::setStatus( .F. , cMsg, .T. )
	else
		::setStatus( .T. , "NF Incluida com Sucesso!!", .T. )
	endif)
return(self)

method setStatus(lOk, cMsg, lEx) class cbcInTransCtrl
	private lException	:= .F.	
	default lOk			:= .T.
	default cMsg 		:= ''
	default lEx			:= .F.	
	
	::lOk				:= lOk	
	if !lException
		if !lOk
			::cMsgErr	:= "[cbcInTransCtrl - "+DtoC(Date())+" - "+Time()+" ] " + '[ERRO]' + cMsg
			MsgAlert(::cMsgErr, 'Aviso')
			if lEx
				lException := .T.
			endif
		endif
	endif
return(self)

static function procNfEntrada(oDadosNF,oSay)
	local oCtrlNota 		:= cbcInTransCtrl():newcbcInTransCtrl(oDadosNF)
	local aRet				:= {.F.,""}
	local oEndereco			as object
	
	oCtrlNota:criaCabec()
	oCtrlNota:criaItens()
	if !empty (oCtrlNota:aCabec) .and. !empty (oCtrlNota:aItens)
		if oCtrlNota:IncNotas():isOk()
			aRet := {.T.,"Nota Incluida com sucesso"}
		else
			aRet := {.F.,"Processo não concluido"}
			MsgAlert("Processo CANCELADO! "+ CRLF +;
						"NF Não Incluida! Favor Verificar!")
		endif
	else
		aRet := {.F.,"Nenhum item informado!"}
		MsgAlert("Nenhuma NF encontrada! Processo CANCELADO!")
	endif
	if aRet[1] //Nota Incluida, cria os endereços
		oEndereco := cbcEndEstoque():newcbcEndEstoque()
		oEndereco:doEnder(oCtrlNota:oDados:GetJSonObject('F1_CHVNFE'), .F.)
		if oEndereco:lOk
			MsgInfo("Todos os produtos foram corretamente endereçados")
			aRet := {.T.,"Nenhum item informado!"}
		else
			EecView(oEndereco:cErrMsg,"Log dos impedimentos do Pedido de Venda")
			MsgAlert("Processo Cancelado!!" + CRLF +;
					"Favor realizar o endereçamento Manualmente!!")
			aRet := {.F.,"Nenhum item informado!"}
		endif
		//Check se todos os itens estão OK
		oEndereco:checkEnder(oCtrlNota:oDados:GetJSonObject('F1_CHVNFE'))
		iif(!empty(oEndereco:cMsgDiv),EecView(oEndereco:cMsgDiv,"Log das Divergencias do Processo de Endereço e Bobinas"),"")
		FreeObj(oEndereco)
	endif
	FreeObj(oCtrlNota)
return(aRet)

user function cbcInTrans(oDadosNF,oSay)
	local cbcaarea			:= GetArea()
	local aRet				:= {}
	private	lMsErroAuto		:= .F.
	private lMsHelpAuto		:= .T.
	private lAutoErrNoFile	:= .T.
	private lIsJobAuto		:= .T.
	default oDadosNF 		:= nil
	default oSay			:= nil
	
	FWMsgRun(, { |oSay| aRet := procNfEntrada(oDadosNF,oSay) }, "Documento de Entrada", "Aguarde, Realizando processamento do Doc. Entrada ...")
	
	RestArea(cbcaarea)
return(aRet)

user function xxxzztstzncbcInTrans()
	local oEndereco			as object
	
	oEndereco := cbcEndEstoque():newcbcEndEstoque()
	oEndereco:checkEnder("50200202544042000208550010000650801100261190")
	iif(!empty(oEndereco:cMsgDiv),EecView(oEndereco:cMsgDiv,"Log das Divergencias do Processo de Endereço e Bobinas"),"")
return