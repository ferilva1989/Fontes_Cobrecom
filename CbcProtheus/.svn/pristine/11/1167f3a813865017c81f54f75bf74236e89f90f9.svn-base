#include 'protheus.ch'


class cbcCtrInvent from cbcsyncdbinvent 

	data aParam 
	data cIdInvent
	method newcbcCtrInvent() constructor 
	
	method setInternal()

endclass


method newcbcCtrInvent() class cbcCtrInvent
	::newcbcsyncdbinvent()
	defParams( @::aParam )
return(self)


/*/{Protheus.doc} setInternal
@author bolognesi
@since 30/09/2018
@version 1.0
@type method
@description Realiza o controle de log passo a passo
bem como atualiza a linha no monitor
/*/
method setInternal(cConteudo) class cbcCtrInvent
	default cConteudo := ''
	if !empty(cConteudo)
		cConteudo := "[INVENTARIO]- " + cConteudo
		FWMonitorMsg(cConteudo)
		Conout(cConteudo)
		::logReg(cConteudo)
	endif
return(self)


// Configurar os parametros necessarios
static function defParams(aParam)
	aParam := {}
	aadd(aParam, {'MV_DBLQMOV','Bloqueia Movimentação',GetNewPar('MV_DBLQMOV','')})
	aadd(aParam, {'ZZ_DDTINVE','Data do Inventário',GetNewPar('ZZ_DDTINVE', '')})
	aadd(aParam, {'MV_BLQINVE','Bloqueia Pesagem',GetNewPar('MV_BLQINVE', '')})
return(nil)


/* TEST ZONE */
/*
	// Instancia da Classe de Conexao ao TOTVSDBAcess
	//New( , , )
	// cDBMSAlias - Tipo/Nome da conexao configurada no TOTVSDBAcess
	// cServer - Nome ou IP do Servidor onde esta o TOTVSDBAcess
	// nPort - Porta do Servidor onde esta o TOTVSDBAcess
	// Ex. oCnx := FWDBAccess():New( 'ORACLE/P10', '192.168.0.2' )
	// oCnx := FWDBAccess():New( 'MSSQL7/ENVTOP', 'SERVIDOR' )
	
	oConx := FWDBAccess():New( 'MSSQL7/ENVTOP', '172.162.0.5' )
	oConx:SetConsoleError( .T. )

	// Fechar Conexão
	oConx:CloseConnection()
	oConx:Finish() // <- Nao esquecer
	
	// Abrir conexão
	If !oConx:OpenConnection()
	    cMsg := "Falha Conexão com a base Externa - Erro: " + AllTrim( oConx:ErrorMessage() )
	    ConOut( cMsg )
	    Return .F.
    EndIf
	
	// Cria uma Alias de trabalho temporaria baseado em uma query na conexão do objeto. 
	// Caso seja informada um nome de Alias esta será usada, caso contrário será gerada uma Alias automaticamente. 
	// O retorno é a Alias aberta, ou vazio não consiga executar.
	FWDBAccess():NewAlias(< cQuery >, < cAlias >, < aSetField >)-> cRet

	// Executa uma query
	FWDBAccess():SQLExec(< cQuery >)-> lRet
	
	// Executa uma procedure
	FWDBAccess():SPExec(< cStoreProc >)-> lRet
	
	// Transação
	FWDBAccess():TransBegin()-> NIL
	FWDBAccess():TransDisarm()
	FWDBAccess():TransEnd()
	  
	// Verifica existe tabela
	FWDBAccess():FileExists(< cFile >)-> lRet
	
	// Verifica erro na operação
	FWDBAccess():HasError()-> lHasError
	// Erro retornado
	FWDBAccess():SqlError()-
	
	// Mensagem de erro
	FWDBAccess():ErrorMessage()-
	
	
	//Existe conexão
	FWDBAccess():HasConnection()-

*/
