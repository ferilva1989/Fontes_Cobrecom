#include 'protheus.ch'
#define LINHA chr(13)


/*/{Protheus.doc} cbcExecAuto
@author bolognesi
@since 02/06/2017
@version 1.0
@type class
@description Classe para centralizar os ExecAutoss
/*/
class cbcExecAuto
	data aItens
	data aHeader
	data lJob
	data aRet
	
	method newcbcExecAuto() constructor
	method setFilial()
	method exAuto()
	
	method getItens()
	method setItens()
	method addItens()
	method getHeader()
	method setHeader()
	method setJob()
	method inJob()
	method getRet()
	method setRet()
	method fromJson()
endclass

/*/{Protheus.doc} new
Metodo construtor
@author leonardo
@since 31/05/2017
@version 1.0
/*/
method newcbcExecAuto(aItens,aHeader,lJob) class cbcExecAuto
	default aItens 	:= {}
	default aHeader := {}
	default lJob	:= .F.
	
	::setItens(aItens)
	::setHeader(aHeader)
	::setJob(lJob)
return(self)

/*Metodos Gets e Sets Referentes a propriedades criadas.*/
method getItens() class cbcExecAuto
return(::aItens)

method setItens(aItm) class cbcExecAuto
	default aItm := {}
	if !empty(aItm)
		::aItens := aItm
	endif
return(self)

method addItens(xConteudo)	class cbcExecAuto
	default xConteudo := ''
	if empty(xConteudo)
		::aItens := {}
	else
		aadd(::aItens,xConteudo)
	endif
return(self)

method getHeader() class cbcExecAuto
return(::aHeader)

method setHeader(aHdr) class cbcExecAuto
	default aHdr := {}
	if !empty(aHdr)
		::aHeader := aHdr
	endif
return(self)

method setJob(lJob) class cbcExecAuto
	default lJob := .F.
	::lJob := lJob
return(self)

method inJob() class cbcExecAuto
return(::lJob)

method getRet() class cbcExecAuto
return(::aRet)

method setRet(aParRet) class cbcExecAuto
	default aParRet := {}
	if empty(aParRet)
		::aRet := {.F., 'ERRO, retorno vazio'}
	else
		::aRet := aParRet
	endif
return(self)

method fromJson(oJson) class cbcExecAuto
	local nX 		:= 0
	local nY		:= 0
	local aNames	:= {}
	local aArr		:= {}
	local aItems	:= {}
	default lHeader	:= .F.
	default oJson 	:= JsonObject():new()
	
	if ValType(oJson:GetJsonObject( 'HEADER' )) <> 'U'	
		aNames := oJson['HEADER']:GetNames()
		for nX := 1 to len(aNames)
			aAdd(aArr, {aNames[nX], oJson['HEADER'][aNames[nX]], NIL})
		next nX
		::setHeader(aArr)
	endif
	
	aArr := {}
	
	if ValType(oJson:GetJsonObject( 'ITEMS' )) <> 'U'
		for nY := 1 to len(oJson['ITEMS'])
			aNames := oJson['ITEMS'][nY]:GetNames()
			for nX := 1 to len(aNames)
				aAdd(aArr, {aNames[nX], oJson['ITEMS'][nY][aNames[nX]], NIL})
			next nX
			if !empty(aArr)
				aAdd(aItems, aClone(aArr))
			endif
			aArr := {}
		next nY
		::setItens(aItems)
	elseif ValType(oJson:GetJsonObject( 'ITEM' )) <> 'U'
		aNames := oJson['ITEM']:GetNames()
		for nX := 1 to len(aNames)
			aAdd(aArr, {aNames[nX], oJson['ITEM'][aNames[nX]], NIL})
		next nX
		::setItens(aArr)
	endif
	
	FreeObj(oJson)
return(self)


/*/{Protheus.doc} exAuto
@author bolognesi
@since 02/06/2017
@version 1.0
@param cRotina, characters, Rotina de execauto a ser utilizada
@param nOpc, numeric, Opção da Rotina Exemplo 1=Inclusão 2=Alteração
@type method
@description Metodo que realiza as definições e executa a rotina de execauto, em Job ou Na mesma thread.
/*/
method exAuto(cRotina,nOpc,nSeqBx,cModulo) class cbcExecAuto
	local aRet := {}
	default nSeqBx	:= 0
	default cModulo := 'FAT'
	
	if ::inJob()
		aRet := startJob('U_cbcExAuto', getenvserver(), .T., FwFilial(), cRotina, ::getHeader(), ::getItens(), nOpc, .T.,nSeqBx, cModulo )
	else
		aRet := U_cbcExAuto(FwFilial(), cRotina, ::getHeader(), ::getItens(), nOpc, .F.,nSeqBx, cModulo )
	endif
	::setRet(aRet)
return (self)

/*/{Protheus.doc} setFilial
@author leonardo
@since 31/05/2017
@version 1.0
@param cParFilial, characters, Recebe a filial a ser definida, obrigatorio
@type method
/*/
method setFilial(cParFilial) class cbcExecAuto
	local oFil 			:= nil
	default cParFilial	:= ''
	if !empty(cParFilial)
		oFil := cbcFiliais():newcbcFiliais()
		if !oFil:setFilial(cParFilial)
			//Erro ao definir filial
		endif
		FreeObj(oFil)
	endif
return(self)

/*/{Protheus.doc} cbcExAuto
//TODO Descrição auto-gerada.
@author bolognesi
@since 02/06/2017
@version undefined
@param cParFil, characters, descricao
@param cRotina, characters, descricao
@param aHdr, array, descricao
@param aItens, array, descricao
@param nOpc, numeric, descricao
@param lJob, logical, descricao
@type function
/*/
user function cbcExAuto(cParFil, cRotina, aHdr, aItens, nOpc, lJob, nSeqBx, cModulo)
	local aErro				:= {}
	local lOk				:= .T.
	local cErro				:= ""
	local nX				:= 0
	local cMcExec			:= ""
	local bErro				:= nil
	private	lMsErroAuto		:= .F.
	private lMsHelpAuto		:= .T.
	private lAutoErrNoFile	:= .T.
	
	private _aHdr			:= {}
	private _aItens			:= {}
	private _nOpc			:= 0
	private _nSeqBx			:= 0
	
	default aItens			:= {}
	default nOpc			:= ''
	default lJob			:= .F.
	default cRotina			:= ''
	default nSeqBx			:= 1
	default cModulo			:= 'FAT'
	
	if empty(cRotina)
		lOk 	:= .F.
		cErro	:= 'Informar a rotina para MSExecAuto'
	else
		if lJob
			RPCClearEnv()
			RPCSetType(3)
			RPCSetEnv('01',cParFil,,,cModulo,GetEnvServer(),{})
		endif
		
		bErro	:= ErrorBlock({|oErr| HandleEr(oErr, @lOk, @cErro)})
		BEGIN SEQUENCE
			cMcExec := getMacroex(cRotina)
			if empty(cMcExec)
				lOk 	:= .F.
				cErro	:= 'Rotina informada ' + cRotina + ' sem tratativa definida.'
			else
				_aHdr			:= aHdr
				_aItens			:= aItens
				_nOpc			:= nOpc
				_nSeqBx			:= nSeqBx	
				BEGIN TRANSACTION
					&cMcExec
					if lMsErroAuto
						aErro := GetAutoGrLog()
						for nX := 1 to len(aErro)
							cErro += aErro[nX] + LINHA
						next nX
						lOk := .F.
						DisarmTransaction()
					endif
					MsUnlockAll()
				END TRANSACTION
				
			endif
		RECOVER
		END SEQUENCE
		ErrorBlock(bErro)
		
		if lJob
			RPCClearEnv()
		endif
	endif
return({lOk, cErro})

/*/{Protheus.doc} getMacroex
@author bolognesi
@since 02/06/2017
@version undefined
@param cRotina, characters, Rotina para obter a linha do msexecauto
@type function
@description Recebe o nome da rotina e devolve string que deve ser macroexecutada.
/*/
static function getMacroex(cRotina)
	local cExec 	:= ''
	local aRotinas	:= {}
	local nPos		:= 0
	default cRotina	:= ''
	//Adicionar novas rotinas aqui
	aadd(aRotinas,  {'CTBA040', 'MSExecAuto({|x,y| CTBA040(x,y)},_aItens,_nOpc)'})
	aadd(aRotinas,  {'CTBA060', 'MSExecAuto({|x,y| CTBA060(x,y)},_aItens,_nOpc)'})
	aadd(aRotinas,  {'CTBA102', 'MSExecAuto({|X,Y,Z| CTBA102(X,Y,Z)},_aHdr,_aItens,_nOpc)'})
	aadd(aRotinas,  {'FINA040', 'MSExecAuto({|x,y| FINA040(x,y)},_aItens,_nOpc)'})
	aadd(aRotinas,  {'FINA050', 'MSExecAuto({|x,y,z| FINA050(x,y,z)},_aItens,,_nOpc)'})
	aadd(aRotinas,  {'FINA070', 'MSExecAuto({|a,b,c,d| FINA070(a,b,c,d)},_aItens,_nOpc,,_nSeqBx)'})
	aadd(aRotinas,  {'MATA015', 'MSExecAuto({|x,y| MATA015(x,y)},_aItens,_nOpc)'})
	aadd(aRotinas,  {'MATA103', 'MSExecAuto({|x,y,z| MATA103(x,y,z)},_aHdr,_aItens,_nOpc)'})
	aadd(aRotinas,  {'MATA240', 'MSExecAuto({|x,y| MATA240(x,y)},_aItens,_nOpc)'})
	aadd(aRotinas,  {'MATA250', 'MSExecAuto({|x,y| MATA250(x,y)},_aItens,_nOpc)'})
	aadd(aRotinas,  {'MATA261', 'MSExecAuto({|x,y| MATA261(x,y)},_aItens,_nOpc)'})
	aadd(aRotinas,  {'MATA265', 'MSExecAuto({|x,y| MATA265(x,y)},_aHdr,_aItens)'})
	aadd(aRotinas,  {'MATA380', 'MSExecAuto({|x,y| MATA380(x,y)},_aItens,_nOpc)'})
	aadd(aRotinas,  {'MATA410', 'MsExecAuto({|x,y,z| MATA410(x,y,z)},_aHdr,_aItens,_nOpc)'})
	aadd(aRotinas,  {'MATA650', 'MSExecAuto({|x,y| MATA650(x,y)},_aItens,_nOpc)'})
	aadd(aRotinas,  {'MATA680', 'MSExecAuto({|x,y| MATA680(x,y)},_aItens,_nOpc)'})
	aadd(aRotinas,  {'MATA681', 'MSExecAuto({|x,y| MATA681(x,y)},_aItens,_nOpc)'})
	aadd(aRotinas,  {'MATA682', 'MSExecAuto({|x,y| MATA682(x,y)},_aItens,_nOpc)'})
	aadd(aRotinas,  {'MATA120', 'MsExecAuto({|x,y,z,u| MATA120(x,y,z,u)},1,_aHdr,_aItens,_nOpc)'})
	/*
	//TODO Resolver estes com mais parametros
	aadd(aRotina,  {'FINA100', 'MSExecAuto({|x,y,z| FINA100(x,y,z)},0,_aItens,7)
	aadd(aRotina,  {'MATA242', 'MSExecAuto({|v,x,y,z| Mata242(v,x,y,z)},_aHdr,_aItens,_nOpc,.T.)
	*/
	if !empty(cRotina)
		nPos := AScan(aRotinas,{|a| Upper(Alltrim(a[1])) == Upper(Alltrim(cRotina)) })
		if nPos > 0
			cExec := aRotinas[nPos,2]
		endif
	endif
	
return(cExec)

/*/{Protheus.doc} ErrorBlock
@author bolognesi
@since 02/06/2017
@version undefined
@param oErr, object, Objeto principal de erro
@param lOk, logical, Referencia logico de erro
@param cErro, characters, Referencia Mensagem de erro
@type function
@description Função para tratamento de erros
/*/
static function HandleEr(oErr, lOk, cErro)
	lOk		:= .F.
	cErro	:= '[' + oErr:Description + ']' + chr(10) + chr(13) + oErr:ERRORSTACK
	BREAK
return(nil)


/*/{Protheus.doc} tstCbcEx
@author bolognesi
@since 02/06/2017
@version 1.0
@type function
@description Função para teste atenção ela criar um registro na tabela CTH
/*/
user function tstCbcEx()
	local oExec := nil
	local aItm	:= {}
	local aRet	:= {}
	//01-) DEFINIÇÔES DOS DADOS NECESSARIOS AO EXECAUTO (Cabeçalho/Itens todo necessario)
	aItm	:= { 	{'CTH_CLVL' 	 	, 'TSTEXEC     ' 		, Nil},;
		{'CTH_CLASSE' 		, '2' 					, Nil},;
		{'CTH_DESC01' 		, 'DESCRIÇÃO TESTE'		, Nil},;
		{'CTH_CLSUP'  		, 'C07       ' 			, Nil}}
	
	//02-) INICIALIZAÇÂO DA CLASSE
	oExec := cbcExecAuto():newcbcExecAuto(aItm,/*aHdr*/,.T.)
	//02.A) DEFINIR FILIAL CASO NECESSARIO
	oExec:setFilial(FwFilial())
	
	//03-) METODO DO EXECAUTO
	oExec:exAuto('CTBA060',3)
	
	//04-) OBTER RETORNO
	aRet := oExec:getRet()
	
	//05-) TRATAR RETORNO
	if !aRet[1]
		Alert('ERRO: ' + aRet[2] )
	else
		Alert('OK' )
	endif
	
return(nil)
