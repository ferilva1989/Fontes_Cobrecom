#include 'protheus.ch'
#include 'fileio.ch'
#include 'topconn.ch'
#include "tbiconn.ch"

#define NOME_CAMPO				1
#define VALOR_CAMPO				2

/*
ZPH_FILIAL
ZPH_IDENV (C, 30)
ZPH_DTENV
ZPH_HRENV
ZPH_MODEL
ZPH_STATUS
ZPH_HTML
ZPH_DTULT
ZPH_HRULT
ZPH_ASSUNT
ZPH_DEST
ZPH_CCDEST
ZPH_BODY
ZPH_FIXO
NICKNAME IDENV  = ZPH_FILIAL+ZPH_IDENV+ZPH_STATUS
NICKNAME STATUS = ZPH_FILIAL+ZPH_STATUS
*/
class cbcSchCtrl from cbcSendEmail

	data lThisOk
	data cThisMsg
	data oJson
	
	data oModel
	data cHTML
	data cIDEnvio
	data cStatus
	data cFixo

	method newcbcSchCtrl() constructor

	method getIDEnvio()
	method setIDEnvio()
	method getHTML()
	method setHTML()
	method getFIXO()
	method setFIXO()

	method getFromId()
	method createEnv()
	method schedule()

	method initClass()

	method getEmailTo()
	method addEmailTo()
	method isSimple()
	method setSimple()
	method getAssunto()
	method setAssunto()

	method getEmailFrom()
	method setEmailFrom()
	method getEmailBcc()
	method addEmailBcc()
	method isConfirm()
	method setConfirm()
	method getBodyText()
	method setBodyText()
	
	method getHdr()
	method addHdr()
	method getLines()
	method addDados()
	method getEmailCc()
	method addEmailCc()
	method getBody()
	method setBody()
	method setHtmlFile()
	method getHtmlFile()

	method sendEmail()
	method clearReg()
endclass

method newcbcSchCtrl(cConta,cSenha) class cbcSchCtrl
	default cConta := nil
	default cSenha := nil
	::newcbcSendEmail(cConta,,cSenha)
	::initClass()
return(self)

/* INICIO GETTERS E SETTERS */
method getIDEnvio() class cbcSchCtrl
return(::cIDEnvio)

method setIDEnvio(cId) class cbcSchCtrl
	default cId	:= ""
	if ::lThisOk
		if empty(cId)
			::lThisOk 	:= .F.
			::cThisMsg	:= '[ERRO]- setIDEnvio(cId) paramtero obrigatorio.'
		else
			cId := Alltrim(cId)
			cId := StrTran(cId,' ','')
			cId := StrTran(cId,'_','')
			cId := StrTran(cId,'-','')
			cId := FwNoAccent(Escape(cId))
			::cIDEnvio := cId + '_' + cValToChar(Randomize(01,90000)) + StrTran(DtoC(Date()),'/','') + StrTran(Time(),':','')
		endif
	endif
return (self)

method getHTML() class cbcSchCtrl
return( ::cHTML )

method setHTML() class cbcSchCtrl
	local _cCampo	:= ""
	local _xValor	:= ""
	local bErro 	:= {|| }
	local aHdr 		:= ::getHdr()
	local aDados	:= ::getLines()
	local oHtml		:= nil
	local cFile		:= ::getHtmlFile()
	local nH		:= 0
	local nL		:= 0
	local nI		:= 0

	if ::lThisOk
		if !::isSimple()
			if empty(cFile)
				::lThisOk := .F.
				::cThisMsg := '[ERRO] - Selecionada a opção de envio com html layout, mas não informado o arquivo.'
			else
				if !File(cFile)
					::lThisOk := .F.
					::cThisMsg := '[ERRO] - Aquivo selecionado para layout (' + cFile + ') não existe em disco.'
				else
					bErro	:= ErrorBlock({|oErr| HandleEr(oErr, self)})
					BEGIN SEQUENCE
						oHtml :=  TWFHtml():new(cFile)
						//Header
						if !Empty(aHdr)
							for nH := 1 to Len(aHdr)
								oHtml:Valbyname(aHdr[nH][NOME_CAMPO],aHdr[nH][VALOR_CAMPO])
							next
						endif
						//Linhas
						if !Empty(aDados)
							for nL := 1 to Len(aDados)
								for nI :=  1 to Len(aDados[nL])
									_cCampo := aDados[nL][nI][NOME_CAMPO]
									_xValor := aDados[nL][nI][VALOR_CAMPO]
									If oHtml:Retbyname(_cCampo) != Nil
										aadd(oHtml:Valbyname(_cCampo) , _xValor )
									EndIf
								next
							next
						EndIF
						::cHTML := oHtml:HtmlCode()
						FreeObj(oHtml)
					RECOVER
					END SEQUENCE
					ErrorBlock(bErro)
				endif
			endif
		endif
	endif
return(self)

method getFIXO()  class cbcSchCtrl
return(::cFixo)

method setFIXO(cVlr)  class cbcSchCtrl
	default cVlr := ""
	if empty(cVlr)
		::cFixo := 'N'
	else
		::cFixo :=cVlr
	endif
return(self)

/* FIM GETTERS E SETTERS */

/* METODOS DO MODEL */
method getEmailTo() class cbcSchCtrl
	local cRet 	:= ''
	local nX 	:= 0
	local nTam	:= len(::oModel:aEmailTo)

	for nX := 1 to nTam
		cRet += ::oModel:aEmailTo[nX]
		if nX != nTam
			cRet += ';'
		endif
	next nX
return (cRet)


method addEmailTo(cDest) class cbcSchCtrl
	local nPos := 0
	if !empty(cDest)
		nPos := AScan(::oModel:aEmailTo,{|a| Alltrim( a ) == Alltrim( cDest )   })
		if nPos = 0
			aadd(::oModel:aEmailTo, cDest)
		endif
	endif
return (self)

method isSimple() class cbcSchCtrl
return(::oModel:lSimple)

method setSimple(lsimple) class cbcSchCtrl
	::oModel:lSimple := lsimple
return(self)


method getAssunto() class cbcSchCtrl
return(::oModel:cAssunto)

method setAssunto(cAssunto) class cbcSchCtrl
	::oModel:cAssunto := cAssunto
return(self)

method getEmailFrom() class cbcSchCtrl
return(::oModel:cFrom)

method setEmailFrom(cFrom) class cbcSchCtrl
	default cFrom := ''
	::oModel:cFrom := cFrom
return(self)


method getEmailBcc() class cbcSchCtrl
	local cRet 	:= ''
	local nX 	:= 0
	local nTam	:= len(::oModel:aEmailBcc)

	for nX := 1 to nTam
		cRet += ::oModel:aEmailBcc[nX]
		if nX != nTam
			cRet += ';'
		endif
	next nX
return (cRet)


method addEmailBcc(cDest) class cbcSchCtrl
	local nPos := 0
	if !empty(cDest)
		nPos := AScan(::oModel:aEmailBcc,{|a| Alltrim( a ) == Alltrim( cDest )   })
		if nPos = 0
			aadd(::oModel:aEmailBcc, cDest)
		endif
	endif
return (self)


method isConfirm() class cbcSchCtrl
return(::oModel:lConfirm)

method setConfirm(lConfirm) class cbcSchCtrl
	default lConfirm := .F.
	::oModel:lConfirm := lConfirm
return(self)


method getBodyText() class cbcSchCtrl
return(::oModel:cBodyText)

method setBodyText(cText) class cbcSchCtrl
default cText := ''
	::oModel:cBodyText := cText
return(self)


method getHdr()   class cbcSchCtrl
return(::oModel:aHdr)

method addHdr(aCmpVlr)   class cbcSchCtrl
	aadd(::oModel:aHdr, aCmpVlr)
return(self)

method getLines() class cbcSchCtrl
return(::oModel:aDados)

method addDados(aCmpsVlrs) class cbcSchCtrl
	aadd(::oModel:aDados, aCmpsVlrs)
return(self)

method getEmailCc() class cbcSchCtrl
	local cRet 	:= ''
	local nX 	:= 0
	local nTam	:= len(::oModel:aEmailCc)
	for nX := 1 to nTam
		cRet += ::oModel:aEmailCc[nX]
		if nX != nTam
			cRet += ';'
		endif
	next nX
return(cRet)

method addEmailCc(cDest) class cbcSchCtrl
	local nPos := 0
	if !empty(cDest)
		nPos := AScan(::oModel:aEmailCc,{|a| Alltrim( a ) == Alltrim( cDest )   })
		if nPos = 0
			aadd(::oModel:aEmailCc, cDest)
		endif
	endif
return(self)

method getBody() class cbcSchCtrl
return(::oModel:cBody)

method setBody(cText) class cbcSchCtrl
	::oModel:cBody := cText
return(self)

method setHtmlFile(cFile) class cbcSchCtrl

	::oModel:cHtmlFile := cFile

return(self)

method getHtmlFile() class cbcSchCtrl
return(::oModel:cHtmlFile)

/* FIM METODOS DO MODEL */

/*/{Protheus.doc} sendEmail
@author bolognesi
@since 08/03/2017
@version 1.0
@type method
@description Realizar o envio do email considerando as propriedades
atuais do objeto
/*/
method sendEmail() class cbcSchCtrl
	local oSql   	:= nil
	::iniSrvMsg()
	::setFrom(::getEmailFrom())
	::setPriority(5)
	::setTo(::getEmailTo()  )
	::setcCc(::getEmailCc() )
	::setcBcc(::getEmailBcc() )
	::setcSubject(::getAssunto() )
	::setConfReader(::isConfirm())

	if !empty(::getBodyText())
		::setBodyType(::getBodyText())
	endif

	if ::isSimple()
		::setcBody(::getBody() )
	else
		::oMessage:cBody := ::getHTML()
	endif

	BEGIN TRANSACTION
	
		oSql := LibSqlObj():newLibSqlObj()
		if !::goToEmail():lOk
			::lThisOk 	:= ::lOk
			::cThisMsg	:= ::cMsg
			oSql:update("ZPH", "ZPH_STATUS = 'E' ", "%ZPH.XFILIAL% AND ZPH_IDENV = '"+ ::getIDEnvio() +"'")
		else
			oSql:update("ZPH", "ZPH_STATUS = 'O' ", "%ZPH.XFILIAL% AND ZPH_IDENV = '"+ ::getIDEnvio() +"'")
		endIf
	
		oSql:update("ZPH", "ZPH_DTULT = '" +  DtoS(Date())   + "' ", "%ZPH.XFILIAL% AND ZPH_IDENV = '"+ ::getIDEnvio() +"'")
		oSql:update("ZPH", "ZPH_HRULT = '" +  Left(Time(), 5) +"' ", "%ZPH.XFILIAL% AND ZPH_IDENV = '"+ ::getIDEnvio() +"'")
		oSql:close()
		FreeObj(oSql)
	
	END TRANSACTION

return(self)

/*/{Protheus.doc} clearReg
@author bolognesi
@since 30/03/2017
@version 1.0
@param lSch, logical, Indica se executado pelo schedule ou manualmente
@param aParam, array, Quando executado manualmente obter os parametros
@type method
@description Realiza a limpeza dos registros na tabela ZPH
/*/
method clearReg(lSch, aParam) class cbcSchCtrl
	local oSql   	:= LibSqlObj():newLibSqlObj()
	local cWhere	:=  "%ZPH.XFILIAL%"
	local nDias		:= GetNewPar('XX_SCHEXP', 2)
	default lSch 	:= .F.
	default aParam  := {}

	::lOk 	:= .T.
	::cMsg	:= ""
	cWhere += " AND ZPH_STATUS = 'O' "

	// Execução pelo schedule
	if lSch
		cWhere += " AND ZPH_FIXO = 'N' "
		cWhere += " AND DATEDIFF(DAY, ZPH_DTENV, GETDATE()) >= " + cValToChar(nDias)

	//Execução manual
	else
		if !empty(aParam)

			if aParam[3] == 2
				cWhere += " AND ZPH_FIXO = 'N' "
			endif
			cWhere += " AND ZPH_DTENV BETWEEN '" + dToS(aParam[1]) + "' AND '" + dToS(aParam[2]) + "'"
		endif

	endif

	if oSql:exists("ZPH", cWhere)
		oSql:delete("ZPH", cWhere, .T. )
	else
		::lThisOk 	:= .F.
		::cThisMsg	:= "[ERRO] - Nenhum registro deletado!"
	endIf
	oSql:close()
	FreeObj(oSql)

return(self)

/*/{Protheus.doc} getFromId
@author bolognesi
@since 07/03/2017
@version 1.0
@param cIdEnv, characters, ZPH_IDENV - id unico do registro
@type method
@description Obter os dados (ZPH_MODEL / ZPH_HTML), transcritos para
as propriedades adequedas deste objeto
/*/
method getFromId(cIdEnv) class cbcSchCtrl
	local oSql		:=  nil
	local cQuery	:= ""
	local oMdl		:= nil
	local oMemo		:= nil
	local cModel	:= ""
	local cHtml		:= ""
	default cIdEnv	:= ""

	if ::lThisOk
		oSql := LibSqlObj():newLibSqlObj()

		cQuery += " SELECT  R_E_C_N_O_ AS RECNO,"
		cQuery += " ZPH_IDENV AS IDENV, "
		cQuery += " ZPH_STATUS AS STATUS "
		cQuery += " FROM %ZPH.SQLNAME% "

		if empty(cIdEnv)
			cQuery += " WHERE %ZPH.XFILIAL% AND ZPH_STATUS IN('A','E') AND  %ZPH.NOTDEL% "
		else
			cQuery += " WHERE %ZPH.XFILIAL% AND ZPH_IDENV = '"+ cIdEnv +"' AND  %ZPH.NOTDEL% "
		endif

		oSql:newAlias(cQuery)
		if oSql:hasRecords()
			oMemo 	:= ManBaseDados():newManBaseDados()
			oSql:goTop()
			while oSql:notIsEof()
				BEGIN TRANSACTION
					::initClass()
					cModel								:= oMemo:getMemo('ZPH', 'ZPH_MODEL'	, oSql:getValue("RECNO"), .T. )
					cHtml									:= oMemo:getMemo('ZPH', 'ZPH_HTML'	, oSql:getValue("RECNO"), .T. )
					oMdl									:= ::oJson:fromJson(cModel)
					::cHTML	 							:= cHtml
					::oModel:AEMAILCC		:= oMdl:AEMAILCC
					::oModel:AEMAILTO			:= oMdl:AEMAILTO
					::oModel:AEMAILBCC		:= oMdl:AEMAILBCC
					::oModel:CASSUNTO		:= oMdl:CASSUNTO
					::oModel:CBODY				:= oMdl:CBODY
					::oModel:LSIMPLE			:= oMdl:LSIMPLE
					::cIDEnvio							:= oSql:getValue("IDENV")
					::cStatus								:= oSql:getValue("STATUS")
	
					oSql:update("ZPH", "ZPH_STATUS = 'P' ", "%ZPH.XFILIAL% AND ZPH_IDENV = '"+ ::getIDEnvio() +"'")
					::sendEmail()
					oSql:skip()
				END TRANSACTION
			enddo
			FreeObj(oMemo)
		endif
		oSql:close()
		FreeObj(oSql)
	endif
return(self)

/*/{Protheus.doc} createEnv
@author bolognesi
@since 07/03/2017
@version 1.0
@type method
@description Salvar um registro na tabela ZPH, 
/*/
method createEnv() class cbcSchCtrl
	local oSql   	 	:= LibSqlObj():newLibSqlObj()
	local aData			:= {}
	//local cNextRevision	:= oSql:getNextTableCode("ZPE", "ZPE_REVISA", "%ZPE.XFILIAL% AND ZPE_NUM = '"+oQuotation:getId()+"'")
	if !empty(::oModel)

		aAdd(aData, {"ZPH_FILIAL", xFilial("ZPH")})
		aAdd(aData, {"ZPH_IDENV", ::getIDEnvio() })
		aAdd(aData, {"ZPH_DTENV", Date()})
		aAdd(aData, {"ZPH_HRENV", Left(Time(), 5)})
		aAdd(aData, {"ZPH_MODEL", ::oJson:toJson(::oModel) })
		aAdd(aData, {"ZPH_STATUS", 'A' })
		aAdd(aData, {"ZPH_HTML", ::getHTML() })
		aAdd(aData, {"ZPH_FIXO", ::getFIXO() })
		oSql:insert("ZPH", aData)
		oSql:close()
		FreeObj(oSql)

		//Zerar os dados da classe
		::initClass()
	endif
return(self)

method schedule() class cbcSchCtrl

	if empty(::getEmailTo())
		::lThisOk 	:= .F.
		::cThisMsg 	:= '[ERRO] - Para agendar envio informar Destinatario, metodo addEmailTo() '

	elseif empty(::getAssunto())
		::lThisOk 	:= .F.
		::cThisMsg 	:= '[ERRO] - Para agendar envio informar Assunto, metodo setAssunto() '

	elseif empty( ::getIDEnvio() )
		::lThisOk 	:= .F.
		::cThisMsg 	:= '[ERRO] - Para agendar envio informar um identificador , metodo setIDEnvio() '
	else

		if ::isSimple()
			if empty(::getBody())
				::lThisOk 	:= .F.
				::cThisMsg 	:= '[ERRO] - Para agendar envio informar Conteudo do email, metodo setBody() '
			endif
		else
			//Prepara o html para envio
			::setHTML()
		endif

	endif
	//Verifica se esta tudo ok
	if ::lThisOk
		::createEnv()
	endif

return(self)

method initClass() class cbcSchCtrl
	::lThisOk 	:= .T.
	::cThisMsg	:= ''
	::cHTML 	:= ''
	::oModel	:= cbcSchModel():newcbcSchModel()
	::oJson		:= jsonTypes():newjsonTypes()
	::cIDEnvio	:= ""
	::cStatus	:= ""
	::setFIXO()
return(self)

Static function HandleEr(oErr, oSelf)
	ConsoleLog('[' + oErr:Description + ']' + oErr:ERRORSTACK)
	u_autoAlert('[' + oErr:Description + ']' + oErr:ERRORSTACK,,'Box',,48)
	oSelf:lThisOk 	:= .F.
	oSelf:cThisMsg	:= oErr:Description
	BREAK
return

static function ConsoleLog(cMsg)
	ConOut("[Schedule-Envio-Email - "+DtoC(Date())+" - "+Time()+" ] "+cMsg)
return

/*/{Protheus.doc} IniSchCm
@author bolognesi
@since 08/03/2017
@version undefined
@param cCmp, characters, descricao
@param cJson, characters, descricao
@type function
/*/
user function IniSchCm(cCmp, cJson)
	local xVal 		:= ''
	local oModel	:= nil
	local oJson		:= nil
	local aDad		:= {}
	local nX		:= 0
	local nY		:= 0
	default cCmp 	:= ''
	default cJson 	:= ''

	if !empty(cCmp) .and. !empty(cJson)
		oJson	:= jsonTypes():newjsonTypes()
		oModel 	:= oJson:fromJson( cJson )
		if AttIsMemberOff(oModel, cCmp)
			aDad := ClassDataArr(oModel)
			for nX := 1 to len(aDad)
				if upper(aDad[nX][1]) == upper(cCmp)
					if ValType(aDad[nX][2]) == 'A'
						for nY := 1 to len(aDad[nX][2])
							xVal += aDad[nX][2][nY]
							if nY !=  len(aDad[nX][2])
								xVal += ' '
							endif
						next nY
					else
						xVal := aDad[nX][2]
					endif
					exit
				endif
			next nX
		endif
		FreeObj(oJson)
		FreeObj(oModel)
	endif
return(xVal)

/*/{Protheus.doc} zSchMng
@author bolognesi
@since 08/03/2017
@version 1.0
@type function
@description Função utilizada pelo schedule para enviar
os emails pendentes.
/*/
user function zSchMng()
	RPCClearEnv()
	RPCSetType(3)
	RPCSetEnv('01','01',,,'FAT',GetEnvServer(),{} )

	ConsoleLog('Iniciando o envio dos emails pelo schedule')
	oSch 		:= cbcSchCtrl():newcbcSchCtrl()
	oSch:getFromId()
	FreeObj(oSch)
	ConsoleLog('Finalizando o envio dos emails pelo schedule')

	RPCClearEnv()
return(nil)

/* TEST ZONE  COMO ENVIAR EMAIL */
user function zSchCtrl(lSimple, lNovo) //U_zSchCtrl()  U_zSchCtrl( .T. , .T. )
	local oSch 		:= cbcSchCtrl():newcbcSchCtrl()
	default lSimple	:= .F.
	default lNovo	:= .F.

	if !lNovo
		//Envia email de todos os pendentes
		oSch:getFromId()
		//Envia de uma especifico ignorando status
		//oSch:getFromId(cId)
	else

		oSch:setIDEnvio('TESTE')
		oSch:addEmailTo('leonardo@cobrecom.com.br')
		oSch:addEmailCc('leonardonhesi@gmail.com')
		oSch:setAssunto('Este é o assunto')
		
		// Existe uma logica e limpeza da tabela por schedule, definir esta
		//propriedade como 'S', impedira que esta registro seja deletado pelo schedule
		// porem manualmente ainda é possivel deletar, o padrão e 'N' ou seja o schedule
		//ira deletar os mais antigos de acordo com o parametro de dias 'XX_SCHEXP'
		//oSch:setFIXO('S')

		//Definir se é simples ou não por default é sempre simples ( .T. =Simples / .F. =Html )
		oSch:setSimple( lSimple )

		//Verifica se simples vai apenas texto no body
		if oSch:isSimple()
			oSch:setBody('Apenas o texto será enviado no body do email')

			//Não é simples precisa de um arquivo externo html (layout)
		else
			//Definir o arquivo de layout (ver arquivo modelo no diretorio)
			oSch:setHtmlFile('\scheduleLayout\html\exemplo.htm')

			//Preencher o header de acordo com o layout do arquivo carregado
			oSch:addHdr({'HDR01'		,'HEADER_01'	})
			oSch:addHdr({'HDR02'		,'HEADER_02'	})
			oSch:addHdr({'HDR03'		,'HEADER_03'	})
			oSch:addHdr({'HDR04'		,'HEADER_04'	})
			oSch:addHdr({'HDR05'		,'HEADER_05'	})
			oSch:addHdr({'HDR06'		,'HEADER_06'	})
			oSch:addHdr({'HDR07'		,'HEADER_07'	})
			oSch:addHdr({'HDR08'		,'HEADER_08'	})

			//Preencher as linhas de acordo com o layout do arquivo carregado
			oSch:addDados( { {'t1.A','A-PRIMEIRA'}	, {'t1.B','B-PRIMEIRA'}	,{'t1.C','C-PRIMEIRA'}	,{'t1.D','D-PRIMEIRA'} })
			oSch:addDados( { {'t1.A','A-SEGUNDA'}	, {'t1.B','B-SEGUNDA'}	,{'t1.C','C-SEGUNDA'}	,{'t1.D','D-SEGUNDA'} })
			oSch:addDados( { {'t1.A','A-TERCEIRA'}	, {'t1.B','B-TERCEIRA'}	,{'t1.C','C-TERCEIRA'}	,{'t1.D','D-TERCEIRA'} })
			oSch:addDados( { {'t1.A','A-QUARTA'}	, {'t1.B','B-QUARTA'}	,{'t1.C','C-QUARTA'}	,{'t1.D','D-QUARTA'} })

			//Preencher as linhas de acordo com o layout do arquivo carregado
			oSch:addDados( { {'t2.A','A-T2-PRIMEIRA'}	, {'t2.B','B-T2-PRIMEIRA'}})
			oSch:addDados( { {'t2.A','A-T2-SEGUNDA'}	, {'t2.B','B-T2-SEGUNDA'}})

		endif
		//Grava o agendamento
		oSch:schedule()
	endif

	//Limpa o objeto da memoria
	FreeObj(oSch)
return()