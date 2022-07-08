#include 'protheus.ch'

/*/{Protheus.doc} cbcVarejoCliente
@author bolognesi
@since 03/07/2017
@version 1.0
@type class
@description Classe responsavel pelas regras do projeto Varejo
no que diz respeito aos clientes
/*/
class cbcVarejoCliente from cbcModClient
	data lOk
	data cMsg
	data isVarejo
	method newcbcVarejoCliente() constructor 
	method chkFromAlias()
	method chkFromQuery()
	method strVarejo()
	method isOk()
	method getErrMsg()
	method setResult()
endclass

/*/{Protheus.doc} newcbcVarejoCliente
@author bolognesi
@since 03/07/2017
@version 1.0
@type method
@description Construtor da classe
/*/
method newcbcVarejoCliente() class cbcVarejoCliente
	::setResult(.T., '')
	::newcbcModClient()
return(self)

/*/{Protheus.doc} strVarejo
@author bolognesi
@since 03/07/2017
@version 1.0
@type method
@description Obtem o conteudo da propriedade cVarejo atraves do metodo getVarejo()
herdado da classe cbcClientModel()
/*/
method strVarejo() class cbcVarejoCliente
	local cRet	:= " "	
	if empty(cRet := ::getVarejo())
		::setResult(.F., '[AVISO] - Não obteve informações do varejo')	
	endif
return(cRet)

/*/{Protheus.doc} isOk
@author bolognesi
@since 03/07/2017
@version 1.0
@type method
@description Obtem o conteudo da propriedade ::lOk
definindo sucesso ou não na operação da classe
/*/
method isOk() class cbcVarejoCliente
return(::lOk)

/*/{Protheus.doc} setResult
@author bolognesi
@since 03/07/2017
@version 1.0
@param lOk, logical, Logico que define o status
@param cMsg, characters, Texto com o descrição para o status
@type method
@description Define um status e uma mensagem de erro para o processamento
geral da classe
/*/
method setResult(lOk, cMsg) class cbcVarejoCliente
	::lOk 	:= lOk
	::cMsg 	:= cMsg
return(self)

/*/{Protheus.doc} getErrMsg
@author bolognesi
@since 03/07/2017
@version 1.0
@type method
@description Obter o conteudo da propriedade ::cMsg que contem
uma descrição sobre o status da propriedade lOk.
/*/
method getErrMsg() class cbcVarejoCliente
return(::cMsg)

/*/{Protheus.doc} chkFromAlias
@author bolognesi
@since 03/07/2017
@version 1.0
@type method
@description Metodo que utiliza as variaveis de memoria (M->A1_)
para definir  se cliente é varejo ou não, utilizado no PE (M030INC/MAltCli)
que é a validação da inclusão/Alteração do cliente.
/*/
method chkFromAlias() class cbcVarejoCliente
	if type("SA1->(A1_COD)") <> "U"
		::setEstado( SA1->(A1_EST) )
		if !::setSegmento(SA1->(A1_SEGMENT))
			::setResult(.F., "[ERRO] - Segmento não existe SZ5 Tabela ZK, ou não informado")
		endif
		::setVarejo()
		if RecLock('SA1', .F.)
			SA1->(A1_ZZVAREJ) := ::getVarejo()
			SA1->(MSUnlock())
		endif 
	endif 
return(self)

/*/{Protheus.doc} chkFromQuery
@author bolognesi
@since 07/07/2017
@version 1.0
@type method
@description Realiza atualização do campo (A1_ZZVAREJ), para toda a base de dados
/*/
method chkFromQuery(lProc) class cbcVarejoCliente
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local cQry		:= ""
	local nRegs		:= 0
	local nX		:= 0
	default lProc	:= .F.

	cQry += " SELECT " 
	cQry += " R_E_C_N_O_  AS ID "
	cQry += " FROM %SA1.SQLNAME% "
	cQry += " WHERE "
	cQry += " %SA1.XFILIAL% " 
	cQry += " AND %SA1.NOTDEL% "

	oSql:newAlias( cQry )
	if oSql:hasRecords()
		dbSelectArea("SA1")	

		nRegs := oSql:count()

		if lProc
			ProcRegua(nRegs)
		endif

		oSql:goTop()

		while oSql:notIsEof()
			if lProc
				nX++
				IncProc(cValToChar(nX) + '/' + cValToChar(nRegs) + ' Cliente: ' + Alltrim(SA1->(A1_NOME)))
			endif
			SA1->(dbGoto( oSql:getValue("ID") ))  
			if !EOF()
				::chkFromAlias()
			Endif
			oSql:skip()
		enddo
	endif
	oSql:close() 
	FreeObj(oSql)
return(self)

/* TRECHO PARA INTERFACE DE TELA */
/*/{Protheus.doc} updVarej
@author bolognesi
@since 07/07/2017
@version 1.0
@type function
@description Função que inicializa o processo para atualizar o SA1 inteiro
/*/
user function updVarej() //U_updVarej()
	if MsgNoYes( 'Esse processo irá atualizar a tabela SA1 inteira, pode demorar, deseja continuar?')
		Processa( {|| procVare() },"Atualizando SA1...")
	endif	
return(nil)

/*/{Protheus.doc} procVare
@author bolognesi
@since 07/07/2017
@version 1.0
@type function
@description Statica que chama a classe que atualiza.
/*/
static function procVare()
	local oVar	:= cbcVarejoCliente():newcbcVarejoCliente()
	oVar:chkFromQuery(.T.)
	FreeObj(oVar)
	MessageBox ( 'Atualiação Concluida!', 'Atualização campo A1_ZZVAREJ', 64 )
return(nil)