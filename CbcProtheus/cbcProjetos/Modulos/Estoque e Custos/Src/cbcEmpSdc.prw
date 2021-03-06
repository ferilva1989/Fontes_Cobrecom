#include 'totvs.ch'

#Define linha chr(13)+chr(10)
#define TABELA 		1
#define NRORECNO 		2
#define COMANDO 		3
#define FAZER   		3
#define MENSAGEM   	4


/*/{Protheus.doc} cbcEmpSdc
@type class
@author bolognesi
@since 02/03/2018
@version 1.0
@description Classe que realiza: 
*Os empenhos nas tabelas (SBF (BF_EMPENHO), SB2 (B2_RESERVA))
*Cria??o/Dele??o de registro na tabela SDC
*Atualiza??o de registro na tabela SZE de Bobinas
*Manuten??o nas tabelas (ZZF e ZZE) de Retrabalho
*Quando realiza o empenho, Soma o valor a ser empenhado nos campos (BF_EMPENHO/B2_RESERVA),
cria uma registro no SDC e se for bobina atualiza o SZE.
*Quando cancela um empenho Subtrai o valor a ser cancelado dos campos (BF_EMPENHO/B2_RESERVA),
exclui o registro no SDC, se for bobina atualiza o SZE e quando origem 'ZZF' realiza as altera??es
nas tabelas (ZZF/ZZE) do retrabalho..
/*/
class cbcEmpSdc from cbcLockCtrl

	data lOk
	data cMsgErro
	
	data nNroBobina
	data cArmazem
	data cAcond
	data cCodProduto
	data nQtdEmp
	data cOrigemEmp
	data cDoctoEmp
	data cItemDocto
	data lCancZZF
		
	method newcbcEmpSdc() constructor

	method getNroBob()
	method setNroBob()
	method getArmazem()
	method setArmazem()
	method getAcond()
	method setAcond()
	method getCodProd()
	method setCodProd()
	method getQtdEmp()
	method setQtdEmp()
	method getOrigEmp()
	method setOrigEmp()
	method getDoctoEmp()
	method setDoctoEmp()
	method getItemDocto()
	method setItemDocto()
	method isCancZZF()
	method setCancZZF()

	method isOk()
	method getMsgErr()
	method setStatus()
		
	method procEmpenho()
	
endclass


method newcbcEmpSdc() class cbcEmpSdc
	::newcbcLockCtrl()
	::setStatus()
	::setCancZZF()
	::aLocks := {}
return(self)

/* GETTERS E SETTERS */
method getNroBob() class cbcEmpSdc
return(::nNroBobina)
	
method setNroBob(nNro) class cbcEmpSdc
	default nNro := 0
	::nNroBobina := nNro
return(self)
	
method getArmazem() class cbcEmpSdc
return(::cArmazem)
	
method setArmazem(cArmz) class cbcEmpSdc
	default cArmz := ''
	::cArmazem := cArmz
return(self)
	
method getAcond() class cbcEmpSdc
return(::cAcond)
	
method setAcond(cAcond) class cbcEmpSdc
	default cAcond := ''
	::cAcond := cAcond
return(self)
	
method getCodProd() class cbcEmpSdc
return(::cCodProduto)
	
method setCodProd(cCod) class cbcEmpSdc
	default cCod := ''
	::cCodProduto := cCod
return(self)
	
method getQtdEmp() class cbcEmpSdc
return(::nQtdEmp)
	
method setQtdEmp(nQtd) class cbcEmpSdc
	default nQtd := 0
	::nQtdEmp := nQtd
return(self)
	
method getOrigEmp() class cbcEmpSdc
return(::cOrigemEmp)
	
method setOrigEmp(cOrigem) class cbcEmpSdc
	default cOrigem := ''
	::cOrigemEmp := cOrigem
return(self)
	
method getDoctoEmp() class cbcEmpSdc
return(::cDoctoEmp)
	
method setDoctoEmp(cDcto) class cbcEmpSdc
	default cDcto := ''
	::cDoctoEmp := cDcto
return(self)
	
method getItemDocto() class cbcEmpSdc
return(::cItemDocto)
	
method setItemDocto(cItem) class cbcEmpSdc
	default cItem	:= ''
	if ValType(cItem) == 'N'
		cItem :=  StrZero(cItem, 2)
	endif
	::cItemDocto := cItem
return(self)

method isCancZZF() class cbcEmpSdc
return(::lCancZZF)

method setCancZZF(lCanc) class cbcEmpSdc
	default lCanc := .F.
	::lCancZZF := lCanc
return(self)

method isOk() class cbcEmpSdc
return(::lOk)

method getMsgErr() class cbcEmpSdc
return(::cMsgErro)

/* METODOS NEGOCIO*/

/*/{Protheus.doc} setStatus
@type method
@author bolognesi
@since 02/03/2018
@version 1.0
@param lSts, logico, Status para o processo (.T.)=Ok (.F.)=Erro Default(.T.)
@param cMsg, String, Descri??o para o status definido.
@param lEx, logico, Define se o status de erro deve causar uma UserExeption() Default (.F.).
@description Metodo que realiza o empenho ou cancela um empenho.
/*/
method setStatus(lSts, cMsg, lEx) class cbcEmpSdc
	private lException	:= .F.
	default lSts			:= .T.
	default cMsg 			:= ''
	default lEx			:= .F.
	::lOk				:= lSts
	if !lException
		if !lSts
			cMsg := ('[cbcEmpSdc]-' + cMsg)
			cMsg	 +=  linha+;
				"Armazem:" 		+ if(empty(::getArmazem()),'',::getArmazem()) 	+ linha+;
				"Localiza??o: " 	+ if(empty(::getAcond()),'',::getAcond()) 		+ linha+;
				"Bobina: " 		+ if(empty(::getNroBob()),'',::getNroBob()) 		+ linha+;
				"Produto: " 		+ if(empty(::getCodProd()),'',::getCodProd())
		endif
		::cMsgErro	:= cMsg
		if lEx
			lException := .T.
			UserException(cMsg)
		endif
	endif
return(self)


/*/{Protheus.doc} procEmpenho
@type method
@author bolognesi
@since 02/03/2018
@version 1.0
@param lCancel, logico, Identificar se ? uma query de cancelamento
@description Metodo que realiza o empenho ou cancela um empenho.
/*/
method procEmpenho(lCancel) class cbcEmpSdc
	local aArea	:= getArea()
	local oSql 	:= nil
	local bErro	:= nil
	local nSBFRec	:= 0
	local nSZERec	:= 0
	local nSB2Rec	:= 0
	local nSDCRec	:= 0
	local aUpd	:= {}
	local aVld	:= {}
	local cQtd	:= cValToChar(::getQtdEmp())
	local lBob	:= Left(::getAcond(),1) == "B"

	default lCancel := .F.
	
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias( getQry(self, lCancel) )
	if !oSql:hasRecords()
		::setStatus(.F., "Registro SBF inv?lido ou n?o encontrado:", .T. )
	else
		oSql:goTop()
		if oSql:notIsEof()
			bErro	:= ErrorBlock({|oErr| HandleEr(oErr, self)})
			BEGIN SEQUENCE
				nSBFRec 	:= oSql:getValue("PK_SBF")
				nSZERec	:= oSql:getValue("PK_BOB")
				nSB2Rec	:= oSql:getValue("PK_SB2")
				nSDCRec	:= 0
				
				BEGIN TRANSACTION
				
					if ! ::prepLock({ {'SBF',nSBFRec, .T.}, {'SB2', nSB2Rec, .T.}, {'SZE', nSZERec, lBob } }):okLock()
						::setStatus(.F., ::getErr(), .T.)
					endif
					
					if lCancel
						nSDCRec  := oSql:getValue("PK_SDC")
						
						if ! ::prepLock({ {'SDC',nSDCRec, .T.}}):okLock()
							::setStatus(.F., ::getErr(), .T.)
						endif
						
						aadd(aVld,{'SBF', nSBFRec, 'SBF->( BF_EMPENHO ) < ' + cQtd, 'Empenho menor quantidade' })
						vldTok(aVld, self )
						aadd(aUpd, {'SBF', nSBFRec, {'SBF->( BF_EMPENHO ) -= ' + cQtd} })
						aadd(aUpd, {'SB2', nSB2Rec, {'SB2->( B2_RESERVA ) := SB2->(B2_RESERVA - ' + cQtd + ' )'} })
						fckRetrab(@self)
					else
						aadd(aVld, {'SBF', nSBFRec, 'SBF->( BF_EMPENHO ) <  0', 'Empenho zerado' })
						aadd(aVld, {'SBF', nSBFRec, 'SBF->(BF_QUANT - BF_EMPENHO) < ' + cQtd, 'Empenho inv?lido' })
						vldTok(aVld, self )
						aadd(aUpd, {'SBF', nSBFRec, {'SBF->( BF_EMPENHO ) += ' + cQtd} })
						aadd(aUpd, {'SB2', nSB2Rec, {'SB2->( B2_RESERVA ) := SB2->(B2_RESERVA + ' + cQtd + ' )'} })
					endif
				
					trataBob(nSZERec, @self, lCancel)
					updTable(aUpd)
					makeSDC(@self, nSDCRec)
				END TRANSACTION

			RECOVER
			END SEQUENCE
			ErrorBlock(bErro)
		endif
	endif
	
	::libLock()
	oSql:close()
	FreeObj(oSql)
	restArea(aArea)
return(self)


/*/{Protheus.doc} vldTok
@type function
@author bolognesi
@since 02/03/2018
@version 1.0
@param aFldVlr, array, Array contendo (Tabela Recno e Comando, Mensagem) 
@param oSelf,objeto,Objeto atual
@description Recebe array aFldVlr definindo:
Tabela Que dever? ser posicionada DbSelectArea() 
Recno  Recno para o posicionamento DbGoTo()
Comando a ser macro executado (sempre com retorno logivo) apos posicionamento com DbGoTo() 
Mensagem Caso o comando retorne .T., neste caso considerado um erro.
o Comando a ser verifica deve ser feito pensando em teste de erro pois o retorno .T. representa
um erro.
/*/
static function vldTok(aFldVlr, oSelf)
	local nX 		:= 0
	local cExec		:= ''
	local aArea		:= getArea()
	default aFldVlr 	:= {}
	if !empty(aFldVlr)
		for nX := 1 to len(aFldVlr)
			DbSelectArea(aFldVlr[nX,TABELA])
			( aFldVlr[nX,TABELA] )->( DbGoTo(aFldVlr[nX,NRORECNO]) )
			cExec := aFldVlr[nX,COMANDO]
			if (&cExec)
				oSelf:setStatus(.F.,  aFldVlr[nX,MENSAGEM], .T.)
			endif
		next nX
	endif
	restArea(aArea)
return(nil)


/*/{Protheus.doc} makeSDC
@type function
@author bolognesi
@since 02/03/2018
@version 1.0
@param oSelf,objeto,Objeto atual
@param nRec,numerico,Recno que devera ser utilizado na exclus?o caso
diferente de zero.
@description Realiza os tratamentos na tabela SDC, criando um novo ou 
excluindo quando informado o recno da tabela.
/*/
static function makeSDC(oSelf, nRec)
	default nRec := 0
	
	if nRec > 0
		dbSelectArea('SDC')
		SDC->(DbGoTo(nRec))
		SDC->(DbDelete())
	else
		if !SDC->(RecLock("SDC",.T.))
			oSelf:setStatus(.F., "N?o foi posivel criar registro SDC: ", .T.)
		else
			SDC->(DC_FILIAL)  := xFilial("SDC")
			SDC->(DC_ORIGEM)  := oSelf:getOrigEmp()
			SDC->(DC_PRODUTO) := oSelf:getCodProd()
			SDC->(DC_LOCAL)   := oSelf:getArmazem()
			SDC->(DC_LOCALIZ) := oSelf:getAcond()
			SDC->(DC_QUANT)   := oSelf:getQtdEmp()
			SDC->(DC_PEDIDO)  := oSelf:getDoctoEmp()
			SDC->(DC_ITEM)    := oSelf:getItemDocto()
			SDC->(DC_QTDORIG) := oSelf:getQtdEmp()
			SDC->(DC_DTLIB)   := dDataBase
			SDC->(DC_HRLIB)   := Left(Time(),Len(SDC->DC_HRLIB))
		endif
	endif

return(nil)


/*/{Protheus.doc} updTable
@type function
@author bolognesi
@since 02/03/2018
@version 1.0
@param aComand, array, comando
@description Recebe array com arrays definindo:
Tabela Que dever? ser posicionada DbSelectArea() 
Recno  Recno para o posicionamento DbGoTo()
Comando a ser macro executado apos posicionamento com DbGoTo()
/*/
static function updTable(aComand)
	local nX 		:= 0
	local nY			:= 0
	local cExec		:= ''
	local aArea		:= getArea()
	default aComand 	:= {}
	if !empty(aComand)
		for nX := 1 to len(aComand)
			DbSelectArea(aComand[nX,TABELA])
			( aComand[nX,TABELA] )->( DbGoTo(aComand[nX,NRORECNO]) )
			for nY := 1 to Len( aComand[nX,COMANDO] )
				cExec := aComand[nX,COMANDO, nY]
				&cExec
			next nY
		next nX
	endif
	restarea(aArea)
return(nil)


/*/{Protheus.doc} trataBob
@type function
@author bolognesi
@since 02/03/2018
@version 1.0
@param nRecno, numerico, recno da tabela SZE
@param oSelf,objeto,Objeto atual
@param lCancel, logico, Identificar se ? uma query de cancelamento
@description Realiza os tratamentos na tabela de bobina SZE onde:
Para empenhar o campo ZE_STATUS == 'T'.
Para cancelar o campo ZE_STATUS == 'N'.
O Campo ZE_RESERVA recebe a identifica??o de origem do empenho.
O campo ZE_CTRLE recebe o numero do documento da reserva, utilizado pelo portal.
/*/
static function trataBob(nRecno, oSelf, lCancel)
	local cAcond 		:= oSelf:getAcond()
	local cOrigem		:= oSelf:getOrigEmp()
	local cDocto		:= oSelf:getDoctoEmp()
	default nRecno 	:= 0
	default lCancel	:= .F.
	
	if left(cAcond,1) == "B"
		if (nRecno == 0)
			oSelf:setStatus(.F., "Bobina n?o encontrada:", .T.)
		else
			DbSelectArea("SZE")
			SZE->( DbGoTo(nRecno) )
			if lCancel
				if SZE->(ZE_STATUS) # "N"
					oSelf:setStatus(.F., "Bobina n?o est? mais com status N:", .T.)
				else
					SZE->(ZE_STATUS) := "T"
					SZE->(ZE_RESERVA) := "      "
					SZE->(ZE_CTRLE)	:= "      "
				endIf
			else
				if SZE->(ZE_STATUS) # "T"
					oSelf:setStatus(.F., "Bobina n?o est? mais dispon?vel:", .T.)
				else
					SZE->(ZE_STATUS) 	:= "N"
					SZE->(ZE_RESERVA) := cOrigem
					SZE->(ZE_CTRLE)	:= cDocto
				endIf
			endif
		endif
	endif
return(nil)


/*/{Protheus.doc} fckRetrab
@type function
@author bolognesi
@since 02/03/2018
@version 1.0
@param oSelf,objeto,Objeto atual
@description Quando necessario realiza os tratamento sobre retrabalho nas 
tabelas ZZF e ZZE
/*/
static function fckRetrab(oSelf)
	
	local lCancRetrab := oSelf:isCancZZF()
	local _cOrigem	:= oSelf:getOrigEmp()
	local _cDocto		:= oSelf:getDoctoEmp()
	
	if _cOrigem == "ZZF" .And. lCancRetrab
		
		dbSelectArea("ZZF")
		
		// FILIAL + ID_RETRABALHO
		ZZF->(DbSetOrder(2))
		ZZF->(DbSeek(xFilial("ZZF")+_cDocto,.F.))
	
		while ZZF->ZZF_FILIAL == xFilial("ZZF") .And. ZZF->ZZF_ZZEID == _cDocto .And. ZZF->(!Eof())
			if ! oSelf:prepLock({ {'ZZF',ZZF->(Recno()), .T.}}):okLock()
				oSelf:setStatus(.F., oSelf:getErr(), .T.)
			endif
			ZZF->ZZF_STATUS := 'X'
			ZZF->(DbSkip())
		enddo
		
		DbSelectArea("ZZE")
		// ZZE_FILIAL+ZZE_ID
		DbSetOrder(1)
		DbSeek(xFilial("ZZE") + _cDocto,.F.)
		while ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE->ZZE_ID == _cDocto .And. ZZE->(!Eof())
			if ! oSelf:prepLock({ {'ZZE',ZZE->(Recno()), .T.}}):okLock()
				oSelf:setStatus(.F., oSelf:getErr(), .T.)
			endif
			ZZE->ZZE_STATUS := '9'
			ZZE->(DbSkip())
		enddo

	endIf
return(nil)


/*/{Protheus.doc} getQry
@type function
@author bolognesi
@since 02/03/2018
@version 1.0
@param oSelf,objeto,Objeto atual
@param lCancel, logico, Identificar se ? uma query de cancelamento
@description Prepara a query que ser? utilizada no processo
/*/
static function getQry(oSelf, lCancel)
	local cQry		:= ''
	local _nBob		:= oSelf:getNroBob()
	local _cArmz		:= oSelf:getArmazem()
	local _cAcond		:= oSelf:getAcond()
	local _cPrd		:= oSelf:getCodProd()
	local _cOrigem	:= oSelf:getOrigEmp()
	local _cDocto		:= oSelf:getDoctoEmp()
	local _cItem		:= oSelf:getItemDocto()
	
	default lCancel	:= .F.
	
	cQry += " SELECT "
	
	if lCancel
		cQry += " ISNULL(SDC.R_E_C_N_O_, 0)  	AS [PK_SDC], "
	endif
	
	cQry += " SBF.R_E_C_N_O_  				AS [PK_SBF], "
	cQry += " SB2.R_E_C_N_O_  				AS [PK_SB2], "
	cQry += " ISNULL(SZE.R_E_C_N_O_ , 0) 	AS [PK_BOB], "
	cQry += " ISNULL(SZE.ZE_NUMBOB, 0) 		AS [NUM_BOB]
	
	cQry += " FROM  %SBF.SQLNAME% "
	
	if lCancel
		cQry += " INNER JOIN  %SDC.SQLNAME% ON  "
		cQry += " %SDC.XFILIAL%"
		cQry += " AND SDC.DC_PRODUTO = '" 	+ _cPrd 	 	+ "' "
		cQry += " AND SDC.DC_LOCAL = '" 	+ _cArmz  	+ "' "
		cQry += " AND SDC.DC_ORIGEM = '" 	+ _cOrigem  	+ "' "
		cQry += " AND SDC.DC_PEDIDO = '" 	+ _cDocto  	+ "' "
		cQry += " AND SDC.DC_ITEM = '" 		+ _cItem  	+ "' "
		cQry += " AND SBF.D_E_L_E_T_	= SDC.D_E_L_E_T_ "
	endif
	
	cQry += " LEFT JOIN  %SZE.SQLNAME% ON  "
	cQry += " %SZE.XFILIAL%"
	cQry += " AND '"+ cValToChar(_nBob) + "' = SZE.ZE_NUMBOB "
	cQry += " AND SZE.ZE_STATUS NOT IN ('F','C') "
	cQry += " AND SBF.D_E_L_E_T_	= SZE.D_E_L_E_T_ "
	
	cQry += " INNER JOIN  %SB2.SQLNAME% ON  "
	cQry += " %SB2.XFILIAL%"
	cQry += " AND SBF.BF_PRODUTO	= SB2.B2_COD "
	cQry += " AND SBF.BF_LOCAL		= SB2.B2_LOCAL "
	cQry += " AND SBF.D_E_L_E_T_	= SB2.D_E_L_E_T_ "
	
	cQry += " WHERE %SBF.XFILIAL%"
	cQry += " AND SBF.BF_LOCAL = '" 	+ _cArmz  	+ "' "
	cQry += " AND SBF.BF_LOCALIZ = '" 	+ _cAcond 	+ "' "
	cQry += " AND SBF.BF_PRODUTO = '" 	+ _cPrd 	 	+ "' "
	
	cQry += " AND %SBF.NOTDEL% "

return(cQry)


/*/{Protheus.doc} HandleEr
@type function
@author bolognesi
@since 02/03/2018
@version 1.0
@param oErr, objeto, Objeto com as informa??es de erro
@param oSelf,objeto,Objeto atual
@description Realiza o tratamento de erros da classe
/*/
static function HandleEr(oErr, oSelf)
	DisarmTransaction()
	oSelf:libLock()
	if type('lException') == 'U'
		oSelf:setStatus(.F., oErr:Description)
	endif
	ConOut("[cbcEmpSdc - "+DtoC(Date())+" - "+Time()+" ] "+ '[ERRO]' + oErr:Description + ' [FROM] ' + ProcName(3) )
	BREAK
return (nil)


/* TEST ZONE */
user function ztsEmp()
	local oEmp		:= cbcEmpSdc():newcbcEmpSdc()
	local nX			:= 0

	for nX := 2 to 2
		if nX == 1
			oEmp:setOrigEmp('ZP4')
			oEmp:setCodProd('1150908401')
			oEmp:setArmazem('01')
			oEmp:setAcond('B00333')
			oEmp:setQtdEmp(333)
			oEmp:setDoctoEmp('000920')
			oEmp:setItemDocto('01')
			oEmp:setNroBob('1731123')
		elseIf nX ==2
			oEmp:setOrigEmp('ZP4')
			oEmp:setCodProd('1150904401')
			oEmp:setArmazem('01')
			oEmp:setAcond('R00100')
			oEmp:setQtdEmp(42500)
			oEmp:setDoctoEmp('000949')
			oEmp:setItemDocto('01')
			oEmp:setNroBob('')
		endif
		// oEmp:setCancZZF(.T.)
		
		if !oEmp:procEmpenho(.F.):isOk()
			MsgAlert( '[TSTEMPSDC]-' + oEmp:getMsgErr() ,'[ERRO]')
		else	
			MsgInfo('[TSTEMPSDC] - Empenho Realizado' , '[SUCESSO]')
			if !oEmp:procEmpenho(.T.):isOk()
				MsgAlert( '[TSTEMPSDC]-' + oEmp:getMsgErr() ,'[ERRO]')
			else
				MsgInfo('[TSTEMPSDC] - Empenho Cancelado' , '[SUCESSO]')
			endif
		endif
		
	next nX
	FreeObj(oEmp)
return(nil)

