#include 'totvs.ch'

class cbcRedis
	
	data cRedisHost
	data nRedisPort
	data cListName
	data oRedis
	data lOk
	data cMsgErr
	data xRetList
	data lHaveMore
	data nNO_MSGS
	
	method newcbcRedis() CONSTRUCTOR
	method getRedisHost()
	method setRedisHost()
	method getRedisPort()
	method setRedisPort()
	method getListName()
	method setListName()
	method getRetList()
	method setRetList()
	
	method setStatus()
	method isOk()
	method getErrMsg()
	method HaveMore()
	
	method initList()
	method add()
	method getMsg()
	method remMsg()
	method readWaiting()
	
endclass


method newcbcRedis(cRedisHost,nRedisPort,cList) class cbcRedis
	default cRedisHost 	:= GetNewPar('ZZ_HOSTRED', '192.168.1.220')
	default nRedisPort 	:= GetNewPar('ZZ_PORTRED', 6379)
	default cList			:= 'Lista_TQLS'
	::setRedisHost(cRedisHost)
	::setRedisPort(nRedisPort)
	::setListName(cList)
	::setStatus()
	::lHaveMore			:= .T.
return(self)


method getRedisHost() class cbcRedis
return(::cRedisHost)

method setRedisHost(cHost) class cbcRedis
	::cRedisHost := cHost
return(self)

method getRedisPort() class cbcRedis
return(::nRedisPort)

method setRedisPort(nPort) class cbcRedis
	::nRedisPort := nPort
return(self)

method getListName() class cbcRedis
return(::cListName)

method setListName(cList) class cbcRedis
	::cListName := cList
return(self)

method getRetList() class cbcRedis
return(::xRetList)

method setRetList(aRet) class cbcRedis
	default aRet	:= {}
	::xRetList := aRet
return(self)

method setStatus(lSts, cMsg) class cbcRedis
	default lSts	:= .T.
	default cMsg	:= ''
	::lOk 		:= lSts
	::cMsgErr 	:= cMsg
return(self)


method isOk() class cbcRedis
return(::lOk)

method getErrMsg() class cbcRedis
return(::cMsgErr)


method HaveMore()class cbcRedis
return(::lHaveMore)


method initList() class cbcRedis
	
	::oRedis := TQueueSvc():New(::getListName())
	if(::oRedis == Nil)
		::setStatus(.F., 'Erro na criação da lista')
	else
		if (::oRedis:Setup(::getRedisHost(), ::getRedisPort())) != 0
			::setStatus(.F., 'Erro ao fazer Setup do redis')
		else
			::nNO_MSGS := ::oRedis:eNO_MSGS
		endif
	endif
return(self)


method add(cMsg) class cbcRedis
	local nErro		:= 0
	local cMsgId		:= ''
	default cMsg		:= ''
	if ::isOk() .and. ( ! empty(cMsg)  )
		if(::oRedis == Nil)
			::setStatus(.F., 'Antes adicionar inicializar a lista metodo initList()')
		else
			if (nErro := ::oRedis:PutMsg(@cMsgId,cMsg)) != 0
				::setStatus(.F., 'Não foi possivel adicionar mensagem erro:' + cValToChar(nErro))
			endif
		endif
	endif
return(self)


method getMsg() class cbcRedis
	local xMsgRet		:= ''
	local nErro		:= 0
	local nNO_MSGS	:= 0
	local cMsgId		:= ''
	
	if ::isOk()
		if(::oRedis == Nil)
			::setStatus(.F., 'Antes obter inicializar a lista metodo initList()')
		else
			::lHaveMore := .T.
			::setRetList()
			if (nErro := ::oRedis:WaitMsg(@cMsgId,@xMsgRet,,3)) != 0
				if(nErro == ::nNO_MSGS)
					::lHaveMore := .F.
				else
					::setStatus(.F., 'Não foi possivel obter mensagem erro:' + cValToChar(nErro))
				endif
			else
				::setRetList({cMsgId,xMsgRet})
			endif
		endif
	endif
return(self)


method remMsg(cMsgId) class cbcRedis
	default cMsgId 	:= ''
	if ::isOk() .and. ( ! empty(cMsgId)  )
		if(::oRedis == Nil)
			::setStatus(.F., 'Antes remover inicializar a lista metodo initList()')
		else
			if (nErro := ::oRedis:DelMsg(cMsgId) ) != 0
				::setStatus(.F., 'Não foi possivel remover mensagem erro:' + cValToChar(nErro))
			endif
		endif
	endif
return(self)


method readWaiting(cQ, cCallBack) class cbcRedis
	local aRet		:= ''
	default cQ		:= ''
	default cCallBack	:= ''
	private cCmd		:= ''
	
	if ! empty(cQ) .and. ! empty(cCallBack)
		::setListName(cQ)
		while ::HaveMore()
			if ::initList():isOk()
				if ::getMsg():isOk()
					if ! empty( aRet := ::getRetList() )
						if ::remMsg(aRet[1]):isok()
							cCmd := cCallBack +"('" + aRet[2] + "')"
							&cCmd
						endif
					endif
				endif
			endif
		enddo
	endif	
return(self)


/*TEST ZONE*/
// Adicionar elementos
user function ztstAddR()
	local oRedis 	:= nil
	local aMsg	:= {'Msh01','Msh02','Msg03','Info56','SHA256','IBM','ZZZ','Teste','Msh01'}
	local nX		:= 0
	
	oRedis := cbcRedis():newcbcRedis()
	oRedis:setListName('ADD_VARIOS')
	
	if oRedis:initList():isOk()
		for nX := 1 to len(aMsg)
			if ! oRedis:add(aMsg[nX]):isOk()
				MsgAlert('Msg não adicionada')
			endif
		next nX
	endif
	
	FreeObj(oRedis)
return(nil)


// Obter Elementos
user function ztstlisR()
	local oRedis 	:= nil
	local aRet	:= {}
	
	oRedis := cbcRedis():newcbcRedis()
	oRedis:setListName('ADD_VARIOS')
	
	if oRedis:initList():isOk()
		while oRedis:HaveMore()
			if ! oRedis:getMsg():isOk()
				MsgAlert(oRedis:getErrMsg())
			else
				if ! empty( aRet := oRedis:getRetList() )
					MsgInfo(aRet[2])
					// Remover elementos
					if ! oRedis:remMsg(aRet[1]):isok()
						MsgAlert(oRedis:getErrMsg())
					endif
				endif
			endif
		enddo
	endif
	
	FreeObj(oRedis)
return(nil)
