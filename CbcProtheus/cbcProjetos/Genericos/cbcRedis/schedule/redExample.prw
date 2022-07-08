#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} redCte
@type function
@author bolognesi
@since 04/07/2018
@version 1.0
@param xParam, variável, (Descrição do parâmetro)
@description Função padrão para obter itens de uma lista redis.
para utilizar em outra fila, deve manter a estrutura contendo:
1-) User function que será executada pelo schedule (ex: redExample())
2-) Utilizar nessa user function estrutura do exemplo, mudando apenas as variaveis
3-) Criar uma static que sera chamada pela classe cbcRedis a cada item obtido da lista
/*/
user function redExample(xParam)
	local oRedis		:= nil
	local aRet		:= {}
	local cFnCb		:= 'U_redExample' 	//Função de CallBack
	local cQueue		:= 'CTE_XML'			// Nome Para Identificar Fila
	local cLockId		:= 'REDIS-U_REDCTE'	// ID do Lock do registro
	local cFnExec		:= 'exRedEx'			// Estatica chamada para cada item Fila
	local cCmd		:= ''
	default xParam	:= ''
	
	if empty(xParam)
		// RPCClearEnv()
		// RPCSetType(3)
		// RPCSetEnv('01','01',,,'FAT',GetEnvServer(),{} )
		if LockByName(cLockId, .F. , .F. )
			oRedis := cbcRedis():newcbcRedis()
			oRedis:readWaiting(cQueue,cFnCb)
			FreeObj(oRedis)
			UnLockByName(cLockId, .F. , .F. )
		endif
		// RPCClearEnv()
	else
		cCmd := cFnExec + "('" + xParam + "')"
		&cCmd
	endif
return(nil)


/*/{Protheus.doc} exRedCte
@type function
@author bolognesi
@since 04/07/2018
@version 1.0
@description Tratamento para cada item obtido
da fila
/*/
static function exRedEx(xReq)
	
return(nil)
