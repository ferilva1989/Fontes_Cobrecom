#include 'protheus.ch'

/*/{Protheus.doc} ctrlTransFilial
(long_description)
@author    alexandre.madeira
@since     12/02/2020
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
class ctrlTransFilial 
	
	data lShowMsg
	data lOk
	data cMsgErr
	data cLocal
	data cTpNF
	data nRecSF2
	data oNFe	
	
	method newctrlTransFilial() constructor 
	
	method isOk()
	method getErrMsg()
	method getSourceNFe()
	method getTpNF()
	method getLocal()
	method getJsonNF()
	method setStatus()
	method setSourceNFe()
	method mountDestNFe()
	method getNFinfo()
	method makeNF()
	
endclass

/*/{Protheus.doc} newctrlTransFilial
Metodo construtor
@author    alexandre.madeira
@since     12/02/2020
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
method newctrlTransFilial(lShowMsg) class ctrlTransFilial	
	default lShowMsg := .F.
	
	::lShowMsg := lShowMsg
	::cLocal := ''
	::setStatus()
	::cTpNF	  := ''
	::nRecSF2 := 0
	::oNFe	  := JsonObject():new()
return(self)

method isOk() class ctrlTransFilial
return(::lOk)

method getErrMsg() class ctrlTransFilial
return(::cMsgErr)

method getSourceNFe() class ctrlTransFilial
return(::nRecSF2)

method getTpNF() class ctrlTransFilial
return(::cTpNF)

method getLocal() class ctrlTransFilial
return(::cLocal)

method getJsonNF() class ctrlTransFilial
return(::oNFe)

method setStatus(lOk, cMsg, lEx) class ctrlTransFilial
	private lException	:= .F.
	
	default lOk			:= .T.
	default cMsg 		:= ''
	default lEx			:= .F.
	
	::lOk				:= lOk
	
	if !lException
		if !lOk
			::cMsgErr	:= "[ctrlTransFilial - "+DtoC(Date())+" - "+Time()+" ] " + '[ERRO]' + cMsg
			if ::lShowMsg
				MsgAlert(::cMsgErr, 'Aviso')
			endif
			if lEx
				lException := .T.
				UserException(cMsg)
			endif
		endif
	endif
return(self)

method setSourceNFe(cChvNFe, cLocal) class ctrlTransFilial
	local oSql 		:= LibSqlObj():newLibSqlObj()
	
	default cLocal	:= ''
	default cChvNFe := ''
	
	oSql:newTable("SF2", "R_E_C_N_O_ REC, F2_TIPO TIPO ", "F2_CHVNFE = '" + cChvNFe + "'")
	
	if(::setStatus(oSql:hasRecords(), 'Nota Fical de Origem não localizada!'):isOk())
		::cTpNF	:= oSql:getValue("TIPO")		
		if (::setStatus((::cTpNF == 'N'), 'Apenas NFs Tipo: (N)ORMAL são processadas por essa rotina!'):isOk())
			if (::setStatus(u_srvVldFilTrf(oSql:getValue("REC")), 'CNPJ de Destino da NF não confere com filial da entrada!'):isOk())			
				ExtraValidations(oSql:getValue("REC"), @self)
				if ::isOk()
					::nRecSF2 	:= oSql:getValue("REC")
					::cLocal 	:= cLocal
				endif
			endif
		endif
	endif
	
	oSql:close()
	FreeObj(oSql)	
return(self)

method mountDestNFe() class ctrlTransFilial
	local oNFe 		:= JsonObject():new()
	local aJsonItens:= {}
	
	if (::setStatus((!empty( ::getSourceNFe() )), 'NFe de Transferência não determinada!'):isOk())
		mountNFHeader(::getSourceNFe(), @oNFe)
		if (::setStatus((!empty(oNFe:GetNames())), 'Erro na montagem do Header!'):isOk())		
			aJsonItens := mountNFItems(::getSourceNFe(), ::getTpNF(), ::getLocal(), @aJsonItens)
			if (::setStatus((!empty(aJsonItens)), 'Erro na montagem dos Itens!'):isOk())
				oNFe['ITENS']	:= aJsonItens
				::oNFe := oNFe
			endif
		endif
	endif
return(self)

method getNFinfo() class ctrlTransFilial
	local oJson := JsonObject():new()
	local oSql	:= LibSqlObj():newLibSqlObj()
	
	if (::setStatus((!empty( ::getSourceNFe() )), 'NFe de Transferência não determinada!'):isOk())
		oSql:newTable("SF2",; 
					  "F2_FILIAL FILIAL, F2_DOC DOC, F2_SERIE SERIE, F2_CLIENTE CLI, F2_LOJA LOJA, F2_TIPO TIPO, F2_CHVNFE CHV, F2_EMISSAO EMISSAO",; 
					  "R_E_C_N_O_ = " + cValtoChar( ::getSourceNFe() ))
		if oSql:hasRecords()
			oJson['FILIAL'] 	:= oSql:getValue("FILIAL")
			oJson['FILIAL_NOME']:= (FWArrFilAtu(FWGrpCompany(), oSql:getValue("FILIAL") )[7])
			oJson['DOC'] 		:= oSql:getValue("DOC")
			oJson['SERIE']		:= oSql:getValue("SERIE")
			oJson['CHAVE']		:= oSql:getValue("CHV")
			oJson['EMISSAO']	:= oSql:getValue("EMISSAO")
			oJson['TIPO']		:= oSql:getValue("TIPO")
		endif
		oSql:close()
	endif
	FreeObj(oSql)
return(oJson)

method makeNF() class ctrlTransFilial
	local aRet		:= {}
	local bErro		:= ErrorBlock({|oErr| errHandle(oErr, @self)})
	
	BEGIN SEQUENCE
		BEGIN Transaction
			if (::setStatus((!empty(::getJsonNF():GetNames())), 'Json não atribuído!', .T.):isOk())		
				aRet := u_cbcInTrans(::getJsonNF())
				::setStatus(aRet[1], aRet[2], .T.)
			endif
		END Transaction
		RECOVER
	END SEQUENCE
return(self)

static function mountNFHeader(nRec, oNFe)
	local oSql		:=  LibSqlObj():newLibSqlObj()
	local aFornCli	:= {}
	
	default oNFe	  	:= JsonObject():new()
	
	oSql:newAlias(u_qryTransFil(nRec, 'H'))

	if oSql:hasRecords()
		oSql:goTop()	
		oNFe['F1_DOC'] 		:= oSql:getValue("DOC") 
		oNFe['F1_SERIE'] 	:= oSql:getValue("SERIE") 
		oNFe['F1_TIPO'] 	:= oSql:getValue("TIPO")
		aFornCli := u_srvTrfFornece(oSql:getValue("FILIAL"), oSql:getValue("TIPO"))		
		oNFe['F1_FORNECE']	:= aFornCli[1]
		oNFe['F1_LOJA'] 	:= aFornCli[2]
		oNFe['F1_EMISSAO']	:= oSql:getValue("EMISSAO")
		oNFe['F1_FORMUL'] 	:= 'N'
		oNFe['F1_ESPECIE']	:= oSql:getValue("ESPECIE")
		oNFe['F1_DTDIGIT']	:= dDataBase
		oNFe['F1_CHVNFE'] 	:= oSql:getValue("CHVNFE")
		oNFe['F1_COND']		:= u_srvTrfCondPag(oSql:getValue("TIPO"), aFornCli[1], aFornCli[2])
		oNFe['F1_DESPESA']	:= 0.00
		oNFe['F1_OBSTRF'] 	:= oSql:getValue("OBSTRF")
	endif	
	oSql:close()
	FreeObj(oSql)
return(oNFe)

static function mountNFItems(nRec, cTpNF, cLocal, aItens)
	local aArea			:= GetArea()
	local aSB1			:= SB1->(GetArea())
	local oSql			:=  LibSqlObj():newLibSqlObj()
	local oJsonItens	:= nil
	
	default aItens	:= {}
	default cLocal	:= ''
	default cTpNF	:= 'N'
	
	dbSelectArea('SB1')
	
	oSql:newAlias(u_qryTransFil(nRec, 'I'))

	if oSql:hasRecords()
		oSql:goTop()	
		while oSql:notIsEof()
			oJsonItens	:= JsonObject():new()
			oJsonItens['D1_ITEM'] 	:= oSql:getValue("ITEM") 
			oJsonItens['D1_COD'] 	:= oSql:getValue("COD")
			oJsonItens['D1_QUANT'] 	:= oSql:getValue("QUANT")
			oJsonItens['D1_LOCAL'] 	:= iif((!empty(cLocal)), cLocal,;
										iif(Posicione("SB1",1,xFilial("SB1")+oSql:getValue("COD"),"B1_TIPO") == 'PA','01','99'))
			oJsonItens['D1_VUNIT'] 	:= oSql:getValue("PRCVEN")
			oJsonItens['D1_TOTAL'] 	:= oSql:getValue("TOTAL")
			oJsonItens['D1_PICM'] 	:= oSql:getValue("PICM")
			oJsonItens['D1_VALICM'] := oSql:getValue("VALICM")
			oJsonItens['D1_CLASFIS']:= oSql:getValue("CLASFIS")
			if cTpNF == 'B'
				
			endif
			aAdd(aItens, oJsonItens)
			FreeObj(oJsonItens)
			oSql:skip()
		endDo
	endif
	oSql:close()
	FreeObj(oSql)
	RestArea(aSB1)
	RestArea(aArea)
return(aItens)

static function ExtraValidations(nRec, oSelf)
	local lLib		:= .F.
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local cChv		:= ''
	local cDoc		:= ''
	local dEmissao	:= Date()
		
	oSql:newTable("SF2"," F2_DOC DOC, F2_EMISSAO EMISSAO, F2_CHVNFE CHV ", "R_E_C_N_O_ = " + cValtoChar( nRec ))
	if (lLib := oSql:hasRecords())
		dEmissao := StoD(oSql:getValue("EMISSAO"))
		cDoc	 := AllTrim(oSql:getValue("DOC"))
		cChv	 := oSql:getValue("CHV")		
		if (lLib := (oSelf:setStatus((Date() > dEmissao .OR. (cDoc $ (GetMV("ZZ_MFILLIB")))),; 
							'Nota Não Pode Ser Incluída Nesta Data!'):isOk()))
			oSql:close()
			FreeObj(oSql)				
			oSql := LibSqlObj():newLibSqlObj()
			oSql:newTable("SF1"," F1_CHVNFE CHV ", " F1_CHVNFE = '" + cChv + "'")
			lLib := (oSelf:setStatus((!oSql:hasRecords()),'Nota de Transferência já Informada!'):isOk())
		endif
	endif
	oSql:close()
	FreeObj(oSql)
return(lLib)

static function errHandle(oErr, oSelf)
	oSelf:setStatus(.F., oErr:Description, .T.) 
		
	if InTransact()
		DisarmTransaction()
	endif
	
	BREAK
return(nil)

user function ztstCtrlTransFilial(cChv) //u_ztstCtrlTransFilial('50200202544042000208550010000650811100005698')
	local oTransf := ctrlTransFilial():newctrlTransFilial(.T.)
	local oJson   := JsonObject():new()
	if (oTransf:setSourceNFe(cChv):isOk())
		if (oTransf:mountDestNFe():isOk())
			oJson := oTransf:getJsonNF()
		endif
	endif	
return(oJson)
