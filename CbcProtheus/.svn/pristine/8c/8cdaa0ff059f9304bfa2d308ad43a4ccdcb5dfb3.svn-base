#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#include 'XMLXFUN.ch'
#include 'fileio.ch'

#define CRLF Chr(13)+Chr(10)

/*/{Protheus.doc} ctrlInvColetas
(long_description)
@author    alexandre.madeira
@since     13/01/2020
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
class ctrlInvColetas
	
	data lStatus
	data oDb
	data cIdInv
	data cMsgErr
	
	method newctrlInvColetas() constructor
	
	method isOk()
	method getErroMsg()
	method getColetas()
	method importColetas()
	method toTxt()
	method gravaColetas()
	method delColetas()
	method setStatus()
	
endclass

/*/{Protheus.doc} new
Metodo construtor
@author    alexandre.madeira
@since     13/01/2020
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
method newctrlInvColetas(cIdInv) class ctrlInvColetas
	local cAddress	:= Alltrim(GetNewPar('ZZ_INVADDR','192.168.1.220'))
	local cPort		:= Alltrim(GetNewPar('ZZ_INVPORT','5984'))
	local cUsr		:= Alltrim(GetNewPar('ZZ_INVUSER','admin'))
	local cPass 	:= Alltrim(GetNewPar('ZZ_INVPASS','admin'))
	local cDb		:= Alltrim(GetNewPar('ZZ_INVDB','inventario'))
	
	default cIdInv	:= ''
	
	::oDb 		:= cbcApiCouch():newcbcApiCouch(cAddress, cPort, cUsr, cPass, cDb)
	::cIdInv 	:= cIdInv
	::setStatus()
return(self)

method isOk() class ctrlInvColetas
return(::lStatus)

method getErroMsg() class ctrlInvColetas
return(::cMsgErr)

method getColetas() class ctrlInvColetas
return(::oDb:aDbResul)

method importColetas(lDel) class ctrlInvColetas
	local oJson		:= nil
		
	default lDel	:= .F.
	
	if !empty(::cIdInv)
		oJson := JsonObject():new()
		oJson['idinv'] := AllTrim(::cIdInv)
		FWMsgRun(, 	{ || ::oDb:find(oJson)}, 		"Comunicando BD Couch", "Processando..."	)
	else
		FWMsgRun(, 	{ || ::oDb:readDb()}, 			"Comunicando BD Couch", "Processando..."	)
	endif
return(self)

method gravaColetas() class ctrlInvColetas
	local aDados 	:= {}
	local jTmpRes	:= nil
	local nX	 	:= 0
	local aCalotas	:= ::getColetas()
	local bErro		:= ErrorBlock({|oErr| errHandle(oErr, @self)})
	
	BEGIN SEQUENCE
		if confirmDataInv()
			for nX := 1 to Len(aCalotas)
				jTmpRes := JsonObject():new()
				jTmpRes:fromJson(aCalotas[nX])
				aAdd(aDados,	{cValtoChar(jTmpRes["ncontagem"]),;
				 				 cValtoChar(jTmpRes["area"]),;
				 				 cValtoChar(jTmpRes["unimov"]),;
				 				 cValtoChar(jTmpRes["qtd"]);
				 				})
				FreeObj(jTmpRes)
			next nX			
			if !empty(aDados)
				u_InvUnMov(aDados)
			else
				MsgAlert('Sem coletas para serem gravada','Sem Coletas')
			endif
		endif
	RECOVER
	END SEQUENCE
return(self)

method toTxt(lDel) class ctrlInvColetas
	local aParamBox := {}
	local aRet 		:= {}
	local cArquivo	:= "C:\" + Space(47)
	
	default lDel := .F.
	
	if empty(::getColetas())
		msgAlert('Não há dados de coletas importados!','Sem coletas')
	else
		aAdd(aParamBox,{6,"Pasta de Saída:  ",cArquivo ,"","",.F.,90,.T.,"Todos os arquivos (*.*) |*.*",'\',GETF_RETDIRECTORY + GETF_LOCALHARD})
	
		if !ParamBox(aParamBox, "Parametros", @aRet)
			msgAlert('Exportação foi cancelada!','Cancelada')
		else
			if Rat("\",AllTrim(MV_PAR01)) == 0
				MsgAlert("Pasta para Gravação do Arquivo Inválida! ","Atenção")
			else
				genArq(AlLTrim(MV_PAR01), @Self)
			endif
		endif
	endif	
return(self)

method delColetas() class ctrlInvColetas
	local aCalotas	:= ::getColetas()
	local nX		:= 0
	local jTmpRes	:= nil
	local bErro		:= ErrorBlock({|oErr| errHandle(oErr, @self)})
	
	BEGIN SEQUENCE
		for nX := 1 to Len(aCalotas)
			jTmpRes := JsonObject():new()
			jTmpRes:fromJson(aCalotas[nX])
			::setStatus(::oDb:delReg(jTmpRes["_id"],jTmpRes["_rev"]):isOk(), ::oDb:getErroMsg(), .T.):isOk()
			FreeObj(jTmpRes)
		next nX	
	RECOVER
	END SEQUENCE
return(self)

method setStatus(lOk, cMsg, lEx) class ctrlInvColetas
	private lException	:= .F.
	
	default lOk			:= .T.
	default cMsg 		:= ''
	default lEx			:= .F.
	
	::lStatus			:= lOk
	
	if !lException
		if !lOk
			::cMsgErr	:= "[ctrlInvColetas - "+DtoC(Date())+" - "+Time()+" ] " + '[ERRO]' + cMsg
			if ::lMsg
				MsgAlert(::cMsgErr, 'Aviso')
			endif
			if lEx
				lException := .T.
				UserException(cMsg)
			endif
		endif
	endif
return(self)

static function confirmDataInv()
	local lRet	:= .T.
	
	if (lRet := MsgYesNo('Confirma a Data do Inventário em ' + DTOC(dDataBase) + '?','Confirmar Data'))	
		if !(lRet := hasZAH(DTOS(dDataBase)))
			MsgAlert('Relação de Inventário não localizada na data!','Inventário não loclaizado')
		endif
	endif
return(lRet)

static function hasZAH(cDtInve)
	local lRet 		:= .T.
	local oSql 		:= LibSqlObj():newLibSqlObj()
	
	oSql:newTable("ZAH", "*", "%ZAH.XFILIAL% AND ZAH_DATA = '" + cDtInve + "'") 
	lRet := oSql:hasRecords()
	oSql:close()
	FreeObj(oSql)	
return(lRet)

static function genArq(cPath, oSelf)
	local lRet		:= .T.
	local nHandle 	:= 0
	local cArq		:= 'Coletas_' +  dToS(dDataBase) + "_" + StrTran(Time(), ':', '') + '.txt'
	local nLinha	:= 0
	local jTmpRes	:= nil
	local aColetas	:= {}
	
	default cPath 	:= 'C:\Temp\'
	
	nHandle := FCreate(cPath+cArq)
	
	if (lRet := nHandle > 0)
		aColetas := oSelf:getColetas()
		for nLinha := 1 to Len(aColetas)
			jTmpRes := JsonObject():new()
			jTmpRes:fromJson(aColetas[nLinha])
			FWrite(nHandle, cValtoChar(jTmpRes["ncontagem"]) + ";" +;
			 				cValtoChar(jTmpRes["area"]) + ";" +;
			 				cValtoChar(jTmpRes["unimov"]) + ";" +;
			 				cValtoChar(jTmpRes["qtd"]) + ";" +;			
			 				CRLF)
			FreeObj(jTmpRes)
		next nLinha
		MsgInfo('Arquivo gerado com sucesso!','Sucesso')
		FClose(nHandle)
	else		
		MsgAlert("Erro durante criação do arquivo.")
	endif	
return(lRet)


static function errHandle(oErr, oSelf)
	oSelf:setStatus(.F., oErr:Description, .T.) 
		
	if InTransact()
		DisarmTransaction()
	endif	
	
	BREAK
return(nil)

/* TESTE ZONE */
user function tstctrlInvCol()
	local oCole := ctrlInvColetas():newctrlInvColetas("64f57479019e6d137c9b03db6500708a")
	oCole:importColetas(.F.)
	alert(cValtoChar(len(oCole:getColetas())))
	oCole:toTxt()
return(nil)
