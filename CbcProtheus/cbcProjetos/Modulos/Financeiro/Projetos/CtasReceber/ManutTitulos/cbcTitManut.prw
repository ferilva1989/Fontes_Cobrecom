#include 'totvs.ch'
#Include 'FWMVCDef.ch'
#include 'cbcManutTit.ch'

#define LINHA Chr(13)
#define TITULO_NF_RECNO 1
#define TITULO_NCC_RECNO 2
#define FLD_FK1_SEQ 1
#define FLD_FK1_DOC 2

/* Define se utiliza F3 para obter motivos de baixa, ou utilizar fixos. */
static lEscMotBx	:= GetNewPar('ZZ_ESCMTBX',.F.)


/*/{Protheus.doc} cbcTitManut
@type class
@author bolognesi
@since 23/05/2018
@description Classe do projeto de manutenção de titulos no financeiro
realiza as operações nos titulos(SE1), grvação (ZBA) e geração do conta-corrente
(CT2) tipo de saldo 6, suporta o funcionamento das telas (cbcMarkZBA, cbcClientTitManut,
cbcZBAModel).
/*/
class cbcTitManut
	data lOk
	data cMsgErr
	data cOper
	data oHashMrk
	data oSeqCtrl
	data oRec
	data dDataBk
	data aArea
	data cNomUsr
	
	method newcbcTitManut() constructor
	
	method setStatus()
	method saveInfo()
	method proxyOper()
	method defOperacao()
	method transferencia()
	method NCC()
	method baixar()
	method desconto()
	method prorrogar()
	method goRelat()
	method isOk()
	method getMsgErr()
	method doMark()
	method procMark()
	method nextNum()
	method commitNum()
	method getOperacao()
	method getTotalOp()
	method countOper()
	method delRelat()
endclass


/*/{Protheus.doc} newcbcTitManut
@type method
@author bolognesi
@since 23/05/2018
@description Construtor da classe, Inicializa as classes
auxiliares, 'cbcCtrlSeq=Controle de numeros sequenciais' e
cbcLockCtrl=Controle de Locks de registros
/*/
method newcbcTitManut() class cbcTitManut
	::setStatus(.T., '')
	::oHashMrk		:= HMNew()
	::oSeqCtrl		:= cbcCtrlSeq():newcbcCtrlSeq()
	::oRec			:= cbcLockCtrl():newcbcLockCtrl()
	::saveInfo()
return (self)


/*/{Protheus.doc} setStatus
@type method
@author bolognesi
@since 23/05/2018
@description Define status da execução, utiliza as propriedades
lOk e cMsgErr para guardar o status e respectiva mensagem de erro
bem como criar exeptions para tratamento de erro personalizado.
/*/
method setStatus(lSts, cMsg, lEx) class cbcTitManut
	default lSts := .T.
	default cMsg	:= ''
	default lEx	:= .T.
	::lOk		:= lSts
	::cMsgErr 	:= cMsg
	
	if !lSts .and. lEx
		UserException(cMsg)
	endif
return(self)


/*/{Protheus.doc} saveInfo
@type method
@author bolognesi
@since 23/05/2018
@description Realiza o back do status inicial de algumas
informações que podem mudar no decorrer da rotina, bem como
armazenar o nome do usuario para auditoria.
/*/
method saveInfo() class cbcTitManut
	::dDataBk 		:= dDatabase
	::aArea			:= getArea()
	::cNomUsr		:= UsrRetName(RetCodUsr())
return (self)


/*/{Protheus.doc} proxyOper
@type method
@author bolognesi
@since 23/05/2018
@description Centraliza as chamadas para as operações realizadas
(TRANS,NCC,baixar,desconto,prorrogar), realiza algumas validações genericas
e posicionamento nos registros SE1, encaminhando posteriormente ao devido metodo
da operação desejada (utilizada pela tela cbcClientTitManut).
/*/
method proxyOper(cOper, oView) class cbcTitManut
	local oMdl		:= nil
	local oMdlNCC		:= nil
	local bErro		:= nil
	local aArea		:= GetArea()
	local nRecSe1		:= 0
	local nRecNCC		:= 0
	default cOper	:= ''
	
	DbSelectArea('SE1')
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, Self)})
	BEGIN SEQUENCE
		if !empty(cOper)
			::defOperacao(cOper)
			::setStatus(.T., '')
			::saveInfo()
			BEGIN TRANSACTION
				if empty(oView)
					oView := FWViewActive()
				endif
				oMdl 	:= oView:GETMODEL('SE1_TITULOS_GRID')
				nRecSe1 	:= oMdl:GetDataId(oMdl:getLine())
				vldEmpty(oMdl,'TITULOS',Self)
				vldDelLock(oMdl,self)
				
				if (cOper == 'TRANS')
					SE1->(DbGoTo(nRecSe1))
					::transferencia(oMdl)
				elseif (cOper == 'NCC')
					oMdlNCC	:= oView:GETMODEL('SE1_NCC_GRID')
					vldEmpty(oMdlNCC,'NCC',Self)
					vldDelLock(oMdlNCC, self)
					lastNCCWrn(oMdl,oMdlNCC,Self)
					::NCC(oView,oMdl,oMdlNCC)
				else
					SE1->(DbGoTo(nRecSe1))
					if  ! SE1->(Eof())
						if cOPer == 'baixar'
							::baixar(oView, oMdl)
						elseif cOPer == 'desconto'
							::desconto(oView, oMdl)
						elseif cOper == 'prorrogar'
							::prorrogar(oView, oMdl)
						endif
					endif
				endif
			END TRANSACTION
		endif
	RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
	::oRec:libLock()
	RestArea(aArea)
return(self)


/*/{Protheus.doc} defOperacao
@type method
@author bolognesi
@since 23/05/2018
@description Atualiza a propriedade cOper com a operação
executa.
/*/
method defOperacao(cOper) class cbcTitManut
	default cOper	:= ''
	::cOper := cOper
return(self)


/*/{Protheus.doc} transferencia
@type method
@author bolognesi
@since 23/05/2018
@description Realiza a chamada para a tela de transferencia
utilizando a função f060Trans(). TAG: Transferencia
/*/
method transferencia(oMdl) class cbcTitManut
	local nRecSe1 	:= oMdl:GetDataId(oMdl:getLine())
	f060Trans(nRecSe1, Self)
return(nil)


/*/{Protheus.doc} NCC
@type method
@author bolognesi
@since 23/05/2018
@description Realiza a compensação de dois titulos
(NF/NCC) utilizando a função MaIntBxCR e depois
a criação do registro na tabela ZBA . TAG: Compensar NCC
/*/
method NCC(oView,oMdl,oMdlNCC) class cbcTitManut
	local cOper 			:= ''
	local cHist			:= 'COMP.NCC'
	local cTxtConfirm		:= ''
	local aParamBox		:= {}
	local aRecSE1			:= {}
	local aRecNCC			:= {}
	local nRecTIT			:= oMdl:GetDataId(oMdl:getLine())
	local nRecNCC			:= oMdlNCC:GetDataId(oMdlNCC:getLine())
	local nSldTIT			:= oMdl:GetValue('SALDO')
	local nSldNCC			:= oMdlNCC:GetValue('SALDO')
	local nVlrZBA			:= 0
	local aParamBox		:= {}
	local aRet			:= {}
	private lAglutina		:= .F.
	private lContabiliza	:= .T.
	private lDigita		:= .F.
	
	aAdd(aParamBox,{1,'Historico' 		,space(TamSx3('ZBA_HISTOP')[1]),PesqPict('ZBA','ZBA_HISTOP' ),'', '','',110,.T.})
	if  ParamBox(aParamBox,'Compensar NCC',@aRet)
		cHist := Alltrim(aRet[1])
	endif
	
	aRecSE1 := { nRecTIT }
	aRecNCC := { nRecNCC }
	if ! MaIntBxCR(3,aRecSE1,,aRecNCC,,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},,,,,dDatabase)
		::setStatus(.F., 'Não foi possível a compensação do titulo de NCC.')
	endif
	// Função padrão desposiciona SE1 importante
	SE1->(DbGoTo(nRecTIT))

	if xFilial("SE1") <> SE1->(E1_FILIAL)
		::setStatus(.F., 'Filial atual diferente do titulo')
	endIf
	
	if ! InTransact()
		::setStatus(.F., 'Erro na transferência, transação não realizada.')
	endif
	
	if nSldTIT <= nSldNCC
		nVlrZBA 	:= nSldTIT
		cOper 	:= 'BAIXAR E DEBITAR NCC'
	else
		nVlrZBA := min(nSldTIT,nSldNCC)
		cOper 	:= 'DESCONTO NCC'
	endif
	gravaZBA(,cOper,cHist,nVlrZBA,self,{nRecTIT,nRecNCC})
return (self)


/*/{Protheus.doc} baixar
@type method
@author bolognesi
@since 23/05/2018
@description Realiza a operação de baixa para os titulos
utilizando a função fBxTitulo(), realiza tambem a geração do ZBA
e quando for Protesto se estiver na situação correta (E1_SITUACA == 'F')
tambem gera ZBA. TAG: Baixar Titulo, Protesto
/*/
method baixar(oView, oMdl) class cbcTitManut
	local nVlrBaixa		:= 0
	local nAcresc			:= 0
	local cHistBx			:= ''
	local lGerCT2			:= .F.
	local nSaldo			:= oMdl:GetValue('SALDO')
	local cOper			:= ''
	if ! ConPad1(,,,'ZZ')
		::setStatus(.F., 'Operação não foi selecionada')
	else
		cOper := Alltrim(SX5->(X5_DESCRI))
		if 'PROTESTO' $ cOper
			if Alltrim(SE1->(E1_SITUACA)) != "F"
				::setStatus(.F., 'Titulo não tranferido para Situação de Protesto')
			elseIf (::countOper(cOper, SE1->(Recno())) > 0)
				::setStatus(.F., 'Já existe um relatorio de protesto para esta titulo')
			endif
			infProtesto(@cHistBx,@nVlrBaixa,self)
		else
			fBxTitulo(@nVlrBaixa, @nAcresc, @cHistBx, nSaldo, self)
		endif
		gravaZBA(nAcresc,cOper,cHistBx,nVlrBaixa,self)
	endif
return (self)


/*/{Protheus.doc} desconto
@type method
@author bolognesi
@since 23/05/2018
@description Realiza a operação de desconto para os titulos
utilizando a função fBxTitulo() pois conforme definição os descontos devem ser tratados
como baixas com tipo Desconto, realiza tambem a geração do ZBA
. TAG: Desconto
/*/
method desconto(oView, oMdl) class cbcTitManut
	local nVlrBaixa		:= 0
	local nAcresc			:= 0
	local cHistBx			:= ''
	local nSaldo			:= oMdl:GetValue('SALDO')
	local cOper			:= ''
	local aBox			:= {}
	local aRet			:= {}
	
	aadd(aBox,{3,"Desconto debitar em conta-corrente","SIM",{"SIM","NÃO"},50,"",.T.})
	
	if ! ParamBox(aBox,"DEFINIÇÔES DE CONTA-CORRENTE...", @aRet)
		::setStatus(.F., 'Desconto sem definição para Conta-Corrente')
	else
		fBxTitulo(@nVlrBaixa, @nAcresc, @cHistBx, nSaldo, self)
		if aRet[1] == 1
			cOper := 'DESCONTO'
		else
			cOper := 'DESC. NÃO DEBITAR'
		endif
		gravaZBA(nAcresc,cOper,cHistBx,nVlrBaixa,self)
	endif
	
return (self)


/*/{Protheus.doc} prorrogar
@type method
@author bolognesi
@since 23/05/2018
@description Realiza a operação de prorrogação para os titulos
utilizando a função exAuto040(), para alterar E1_VENCREA de acordo
com o informado, utiliza a função zGetDtVl para validar a data,
porem informa se errada e sugere alteração, mas não obriga.
TAG: Prorrogação
/*/
method prorrogar(oView, oMdl) class cbcTitManut
	local nSaldo			:= oMdl:GetValue('SALDO')
	local aParamBox		:= {}
	local aRet			:= {}
	local aVldDt			:= {}
	local cTxtConfirm		:= ''
	local dDataPro		:= Date()
	local aSendExe		:= {}
	local cHistProrrog	:= ''
	local cOper			:= 'PRORROGACAO'
	
	aAdd(aParamBox,{1,'Titulo' 		,SE1->(E1_NUM),PesqPict('SE1','E1_NUM' ),'', '','.F.',50,.T.})
	aAdd(aParamBox,{1,'Parcela' 		,SE1->(E1_PARCELA),PesqPict('SE1','E1_PARCELA' ),'', '','.F.',40,.F.})
	aAdd(aParamBox,{1,'Cliente' 		,SE1->(E1_NOMCLI),PesqPict('SE1','E1_NOMCLI' ),'', '','.F.',110,.T.})
	aAdd(aParamBox,{1,'Data Atual'  	,SE1->(E1_VENCREA),PesqPict('SK1','FK1_DATA'),"","",".F.",50,.T.})
	aAdd(aParamBox,{1,'Nova Data'  		,SE1->(E1_VENCREA),PesqPict('SK1','FK1_DATA'),"","",".T.",50,.T.})
	aAdd(aParamBox,{1,'Motivo' 		,space(TamSx3('ZBA_HISTOP')[1]),PesqPict('ZBA','ZBA_HISTOP' ),'', '','',110,.T.})
	
	if ! ParamBox(aParamBox,'Prorrogação de Titulo',@aRet)
		::setStatus(.F., 'Sem informações para realizar a prorrogação.')
	else
		if ! ( aVldDt := u_zGetDtVl(aRet[5]) )[1]
			cTxtConfirm := ' Data Selecionada [ ' + Dtoc(aRet[5])+' ] inválida ' + LINHA
			cTxtConfirm += ' Aceitar proxima data válida? [' + DtoC(aVldDt[2]) + ']'+ LINHA
			if lastWrn(nSaldo,cTxtConfirm,Self,.F.)
				aRet[5] := aVldDt[2]
			endif
		endif
		if aRet[5] <= SE1->(E1_VENCREA)
			::setStatus(.F., 'Data para prorrogação inválida.')
		endif
		
		dDataPro 	:= aRet[5]
		cHistProrrog	:= aRet[6]
		cTxtConfirm 	:= ' Prorrogação do titulo para: ' + Dtoc(dDataPro)
		aSendExe 	:= {}
		
		// Preservar E1_VENCREA apenas no primeiro relatorio
		if ::countOper(cOper, SE1->(Recno()) ) == 0
			aadd(aSendExe,{"E1_VENCORI" ,SE1->(E1_VENCREA),Nil })
		endif
		aadd(aSendExe,{"E1_VENCREA" ,dDataPro  	,Nil })
		
		lastWrn(nSaldo,cTxtConfirm,Self)
		exAuto040(self,aSendExe)
		gravaZBA(,cOper,cHistProrrog,,self)
	endif
return (self)


/*/{Protheus.doc} goRelat
@type method
@author bolognesi
@since 23/05/2018
@description  Realiza a chamada para tela de geração de relatorio,
onde o usurio podera destinar os registro ZBA sem numero de relatorio,
para um relatorio.
TAG: Gerar ZBA
/*/
method goRelat(oView) class cbcTitManut
	U_cbcMarkZBA(self)
return (self)


/*/{Protheus.doc} isOk
@type method
@author bolognesi
@since 23/05/2018
@description  Retorna a propriedade lOk, armazena
o status da execução.
TAG: SetStatus, ok
/*/
method isOk() class cbcTitManut
return(::lOk)


/*/{Protheus.doc} getMsgErr
@type method
@author bolognesi
@since 23/05/2018
@description  Retorna a propriedade cMsgErr, armazena
descrição sobre o status da execução.
TAG: SetStatus, Erro
/*/
method getMsgErr() class cbcTitManut
return(::cMsgErr)


/*/{Protheus.doc} doMark
@type method
@author bolognesi
@since 23/05/2018
@description  Mantem uma Lista Hash sincronizada com os registros
marcados/desmarcados pelo markBrowser (cbcMarkZBA)
TAG: Marcar registros
/*/
method doMark(aHM) class cbcTitManut
	local xValue	:= {}
	default aHM 	:= {}
	::setStatus()
	if len(aHM) <> 2
		::setStatus(.F., "[ERRO] - Metodo doMark() classe cbcTitManut, precisa de array com duas posições")
	else
		if  HMGet( ::oHashMrk , aHM[1] , @xValue )
			HMDel(::oHashMrk, aHM[1])
		else
			HMAdd(::oHashMrk,aHM)
		endif
	endif
return(self)


/*/{Protheus.doc} procMark
@type method
@author bolognesi
@since 23/05/2018
@description  Utilizando Lista Hash sincronizada (metodo: doMark())
com os registros marcados/desmarcados pelo markBrowser (cbcMarkZBA),
realiza um processamento em todos os elementos da lista, suporta dois processamento
definidos pela cOpc (NEW/DEL)
TAG: Processar Registros marcados
/*/
method procMark(cOpc) class cbcTitManut
	local aElem 	:= {}
	local nX		:= 0
	::setStatus()
	if ( HMList( ::oHashMrk, @aElem ) )
		if cOpc == 'NEW'
			Processa({|| initProc(self,aElem) }, "Aguarde...", "Processando...",.F.)
		elseif cOpc == 'DEL'
			Processa({|| delProc(self,aElem) }, "Aguarde...", "Deletando...",.F.)
		endif
	endif
return(self)


/*/{Protheus.doc} nextNum
@type method
@author bolognesi
@since 23/05/2018
@description  Obtem o proximo numero para o relatorio (ZBA_NROREL)
TAG: Proximo numero
/*/
method nextNum() class cbcTitManut
return (::oSeqCtrl:getNext("ZBA", "ZBA_NROREL", "ZBA_NROREL <> ''"))


/*/{Protheus.doc} commitNum
@type method
@author bolognesi
@since 23/05/2018
@description  Liberação do numero obtido.
TAG: Comitar proximo numero
/*/
method commitNum() class cbcTitManut
	::oSeqCtrl:commit()
return(self)


/*/{Protheus.doc} getOperacao
@type method
@author bolognesi
@since 23/05/2018
@description  Retorna o conteudo da propriedade
cOper, contendo a operação realizada no momento.
TAG: Obter Operação
/*/
method getOperacao() class cbcTitManut
return(::cOper)


/*/{Protheus.doc} getTotalOp
@type method
@author bolognesi
@since 23/05/2018
@description  A partir de um registro recno
da tabela SE1 -> (Todo ZBA tem recno SE1 no campo ZBA_SE1REC)
Obter o total do campo ZBA_VLROPE para operação de DESCONTO e BAIXA
Ou seja o total de operação realizadas no ZBA que mudam o valor do titulo.
TAG: Obtem total de operações para um titulo.
/*/
method getTotalOp(nRec) class cbcTitManut
	local nSaldo	:= 0
	local oSql 	:= nil
	local cQry	:= ''
	default  nRec	:= 0
	if nRec > 0
		oSql 	:= LibSqlObj():newLibSqlObj()
		cQry += " SELECT "
		cQry += " SUM(ZBA_VLROPE) AS [TOTAL] "
		cQry += " FROM  %ZBA.SQLNAME% "
		cQry += " WHERE "
		cQry += " ZBA_SE1REC = '" + cValToChar(nRec) + "' "
		cQry += " AND (ZBA_OPER LIKE '%DESCONTO%' "
		cQry += " OR ZBA_OPER LIKE '%BAIXA%')"
		cQry += " AND %ZBA.NOTDEL% "
		cQry += " GROUP BY ZBA_SE1REC
		oSql:newAlias(cQry)
		if oSql:hasRecords()
			oSql:goTop()
			while oSql:notIsEof()
				nSaldo += oSql:getValue("TOTAL")
				oSql:skip()
			endDo
			oSql:close()
		endif
		FreeObj(oSql)
	endif
return(nSaldo)


/*/{Protheus.doc} countOper
@type method
@author bolognesi
@since 23/05/2018
@description  Realiza a contagem de relatorios de uma determinada
operação para um determinado titulos, responde a pergunta:
Para este titulo SE1(RECNO), quantos relatorios de 'DESCONTO' temos?.
TAG: Quantos relatorios.
/*/
method countOper(cOper, nRec) class cbcTitManut
	local nQtd	:= 0
	local oSql 	:= nil
	local cQry	:= ''
	default cOper	:= ''
	default nRec	:= 0
	if !empty(cOper) .and. ( nRec > 0 )
		oSql 	:= LibSqlObj():newLibSqlObj()
		cQry += " SELECT "
		cQry += " COUNT(*) AS [QTD_OP] "
		cQry += " FROM  %ZBA.SQLNAME% "
		cQry += " WHERE "
		cQry += " ZBA_SE1REC = '" + cValToChar(nRec) + "' "
		cQry += " AND ZBA_OPER LIKE '%" + cOper + "%' "
		cQry += " AND %ZBA.NOTDEL% "
		cQry += " GROUP BY ZBA_SE1REC
		oSql:newAlias(cQry)
		if oSql:hasRecords()
			oSql:goTop()
			while oSql:notIsEof()
				nQtd += oSql:getValue("QTD_OP")
				oSql:skip()
			endDo
			oSql:close()
		endif
		FreeObj(oSql)
	endif
return(nQtd)


/*/{Protheus.doc} delRelat
@type method
@author bolognesi
@since 23/05/2018
@description  Realiza os processos para cancelar um realatorio
utilizando função procCanc() e controle de status
TAG: Deletar relatorios criados.
/*/
method delRelat(cNro) class cbcTitManut
	FWMsgRun(, {|oSay| delRel(cNro, Self) }, "Aguarde...", "Deletando...")
	// Processa({|| delRel(cNro, Self) }, "Aguarde...", "Deletando...",.F.)
return(self)


/* FUNÇÔES ESTATICAS */

/*/{Protheus.doc} delRel
@type function
@author bolognesi
@since 24/05/2018
@description  Realiza o cancelamento de um relatorio
com base em seu numero.
TAG: Cancelar relatorio.
/*/
static function delRel(cNro, oSelf)
	local oSql 	:= nil
	local cQry	:= ''
	local aWrk	:= {}
	local cOp	:= ''
	default cNro := ''
	
	if MsgNoYes( 'Confirma deleção do relatorio?', 'Relatorio.' + cNro )
		bErro	:= ErrorBlock({|oErr| HandleEr(oErr, oSelf)})
		BEGIN SEQUENCE
			if !empty(cNro)
				BEGIN TRANSACTION
					oSql 	:= LibSqlObj():newLibSqlObj()
					cQry += " SELECT "
					cQry += " ZBA.R_E_C_N_O_ 	AS [REC_ZBA]	, "
					cQry += " ZBA_SE1REC 		AS [REC_SE1]	, "
					cQry += " ZBA_OPER 		AS [OPER] "
					cQry += " FROM  %ZBA.SQLNAME% "
					cQry += " WHERE "
					cQry += " %ZBA.XFILIAL% "
					cQry += " AND ZBA_NROREL = '" + cNro + "' "
					cQry += " AND %ZBA.NOTDEL% "
					oSql:newAlias(cQry)
					if oSql:hasRecords()
						DbSelectArea('ZBA')
						DbSelectArea('SE1')
						oSql:goTop()
						while oSql:notIsEof()
							if empty(oSql:getValue("REC_SE1"))
								oSelf:setStatus(.F., 'Não é possivel excluir relatorio, foi gerado com a rotina antiga!')
							endif
							cOp := oSql:getValue("OPER")
							ZBA->(DbGoTo(oSql:getValue("REC_ZBA")))
							SE1->(DbGoTo(Val(oSql:getValue("REC_SE1"))))
							procCanc(cOp,oSelf)
							oSql:skip()
						endDo
						oSql:close()
					endif
					cancCT2(cNro, oSelf)
					FreeObj(oSql)
				END TRANSACTION
			endif
		RECOVER
		END SEQUENCE
		ErrorBlock(bErro)
	endif
	oSelf:oRec:libLock()
return(nil)


/*/{Protheus.doc} cancCT2
@type function
@author bolognesi
@since 23/05/2018
@description  Cancela o conta-corrente (CT2)
com base em um numero de relatorio, utilizando
execauto CTBA102
TAG: Cancelar relatorio do conta-corrente.
/*/
static function cancCT2(cNro, oSelf)
	local cQry 	:= ''
	local aCab	:= {}
	local aItens	:= {}
	local aRet	:= {}
	local oExec	:= nil
	local oSql	:= nil
	
	oSql 	:= LibSqlObj():newLibSqlObj()
	cQry += " SELECT "
	cQry += " CT2.R_E_C_N_O_ 	AS [REC_CT2] "
	cQry += " FROM  %CT2.SQLNAME% "
	cQry += " WHERE "
	cQry += " %CT2.XFILIAL% "
	cQry += " AND CT2.CT2_LOTE 	= '028850' "
	cQry += " AND CT2.CT2_SBLOTE 	= '001' "
	cQry += " AND CT2.CT2_DOC 		='"+ cNro + "' "
	cQry += " AND CT2.CT2_TPSALD 	= '6' "
	cQry += " AND %CT2.NOTDEL% "
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		DbSelectArea('CT2')
		oSql:goTop()
		while oSql:notIsEof()
			aCab		:= {}
			aItens	:= {}
			CT2->(DbGoTo(oSql:getValue("REC_CT2")))
			if CT2->(Eof())
				oSelf:setStatus(.F., 'Registro CT2 Inválido')
			else
				aCab := {;
					{'DDATALANC' 		,Date()			,NIL},;
					{'CLOTE' 		,CT2->(CT2_LOTE) 	,NIL},;
					{'CSUBLOTE' 		,'002'			,NIL},;
					{'CDOC' 			,CT2->(CT2_DOC)	,NIL},;
					{'CPADRAO' 		,'' 				,NIL},;
					{'NTOTINF' 		,0 				,NIL},;
					{'NTOTINFLOT' 	,0 				,NIL} }
				aAdd(aItens,{;
					{'CT2_FILIAL' 	,CT2->(CT2_FILIAL), NIL},;
					{'CT2_LINHA'  	,CT2->(CT2_LINHA)	, NIL},;
					{'CT2_MOEDLC'  	,CT2->(CT2_MOEDLC), NIL},;
					{'CT2_DC'   		,CT2->(CT2_DC)	, NIL},;
					{'CT2_DEBITO'  	,CT2->(CT2_DEBITO), NIL},;
					{'CT2_CREDIT'  	,CT2->(CT2_CREDIT), NIL},;
					{'CT2_VALOR'  	,CT2->(CT2_VALOR)	, NIL},;
					{'CT2_ORIGEM' 	,'CANCEL.RELAT'	, NIL},;
					{'CT2_HP'   		,CT2->(CT2_HP)	, NIL},;
					{'CT2_EMPORI'   	,CT2->(CT2_EMPORI), NIL},;
					{'CT2_FILORI'   	,CT2->(CT2_FILORI), NIL},;
					{'CT2_TPSALD'   	,CT2->(CT2_TPSALD), NIL},;
					{'CT2_CLVLDB'   	,CT2->(CT2_CLVLCR), NIL},;
					{'CT2_CLVLCR'   	,CT2->(CT2_CLVLDB), NIL},;
					{'CT2_HIST'   	,'CANCELADO RELAT. NRO. ' + Alltrim(CT2->(CT2_DOC))	, NIL} } )
				
 				oExec := cbcExecAuto():newcbcExecAuto(aItens, aCab)
 				oExec:exAuto('CTBA102',3)
				aRet := oExec:getRet()
				if !aRet[1]
					oSelf:setStatus(.F., aRet[2])
				endif
				FreeObj(oExec)
			endif
			oSql:skip()
		endDo
		oSql:close()
		FreeObj(oSql)
	endif
return(nil)


/*/{Protheus.doc} prorRec
@type function
@author bolognesi
@since 23/05/2018
@description Auxilia o cancelamento de um relatorio de
prorrogação, obtendo os recnos de outros relatorios de prorrogação
para decidor como fica o titulo SE1 apos a deleção do relatorio.
TAG: Cancelar relatorio de prorrogação.
/*/
static function prorRec(cSinal, nRecZBA, nRecSE1)
	local oSql 		:= nil
	local cQry		:= ''
	oSql 			:= LibSqlObj():newLibSqlObj()
	cQry += " SELECT "
	cQry += " MAX(R_E_C_N_O_) 	AS [REC] "
	cQry += " FROM  %ZBA.SQLNAME% "
	cQry += " WHERE "
	cQry += " %ZBA.XFILIAL% "
	cQry += " AND ZBA_SE1REC = " + cValToChar(nRecSE1)
	cQry += " AND ZBA_OPER LIKE '%PRORROGACAO%'
	cQry += " AND ZBA.R_E_C_N_O_ " +  cSinal + " " + cValToChar(nRecZBA)
	cQry += " AND %ZBA.NOTDEL% "
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			nRec := oSql:getValue("REC")
			oSql:skip()
		enddo
	endif
	oSql:close()
	FreeObj(oSql)
return(nRec)


/*/{Protheus.doc} dtRestor
@type function
@author bolognesi
@since 23/05/2018
@description Auxilia o cancelamento de um relatorio de
prorrogação, definindo qual data de vencimento real deve ser
considerada para o titulo apos a exclusão do relatorio.
TAG: Cancelar relatorio de prorrogação.
/*/
static function dtRestor(nRecSe1, nRecZba, oSelf)
	local nRecMaior	:= 0
	local nRecMenor	:= 0
	local dRestData	:= CtoD(' / / ')
	// Não tem maior
	if empty( nRecMaior := prorRec('>', nRecZba,nRecSe1))
		// Não tem menor
		if empty( nRecMenor := prorRec('<', nRecZba,nRecSe1) )
			dRestData := SE1->(E1_VENCORI)
			// Tem menor
		else
			ZBA->(DbGoTo(nRecMenor))
			dRestData := ZBA->(ZBA_VENCRE)
			ZBA->(DbGoTo(nRecZba))
		endif
	endif
return(dRestData)


/*/{Protheus.doc} estComp
@type function
@author bolognesi
@since 23/05/2018
@description Realiza o estorno de uma compensação, utilizado
ao cancelar o relatorio de NCC.
TAG: Cancelar relatorio de NCC.
/*/
static function estComp(oSelf)
	local aSE1		:= {}
	local aEstorno	:= {}
	local aFk		:= {}
	local lRet		:= .F.
	aFk := StrToKArr(ZBA->(ZBA_FKFAMI), ';')
	if len(aFk) == 2
		aSE1 := { SE1->(Recno()) }
		aEstorno := {}
		aAdd(aEstorno, {{aFk[FLD_FK1_DOC]},aFk[FLD_FK1_SEQ]})
		if !(lRet := MaIntBxCR( 3 , aSE1,,,, {.T.,.F.,.F.,.F.,.F.,.F.},, aEstorno ))
			oSelf:setStatus(.F., 'Erro ao estornar compensação')
		endif
		// Função padrão desposiciona SE1 importante
		SE1->(DbGoTo(aSE1[1]))
	endif
return(lRet)


/*/{Protheus.doc} procCanc
@type function
@author bolognesi
@since 23/05/2018
@description Excluir a operção, desfazendo as alterações
em titulos, deletando conta-corrente(CT2) e excluindo registro ZBA
TAG: Proxy para cancelar relatorio.
/*/
static function procCanc(cOp,oSelf)
	local aBaixa		:= {}
	local aRetEx		:= {}
	local aSendExe	:= {}
	local oFil		:= nil
	local oExec		:= nil
	local dDataPro	:= CtoD(' / / ')
	local nSeqBx		:= 0
	
	if ! oSelf:oRec:prepLock({{'SE1', SE1->(Recno()), .T.},;
			{'ZBA', ZBA->(Recno()), .T.} }):okLock()
		oSelf:setStatus(.F., 'Processo precisa de acesso exclusivo')
	endif
	
	if 'NCC' $ cOp
		estComp(oSelf)
	elseif 'PROTESTO' $ cOp
		if SE1->(E1_SITUACA) $ 'F'
			MsgInfo('Retirar titulo da carteira de protesto(F)','Transferência')
			f060Trans(SE1->(Recno()), oSelf)
			if SE1->(E1_SITUACA) $ 'F'
				oSelf:setStatus(.F., "Para cancelar o relatorio Nro. " +;
					Alltrim(ZBA->(ZBA_NROREL)) + " é necessario transferir os titulos da carteira F(Protesto) para outra ")
			endif
		endif
	elseif 'PRORROGACAO' $ cOp
		if !empty(dDataPro := dtRestor(SE1->(Recno()), ZBA->(Recno()), oSelf))
			aSendExe := {}
			aadd(aSendExe,{"E1_VENCREA" ,dDataPro ,Nil })
			exAuto040(oSelf,aSendExe)
		endif
	elseif ('BAIXAR' $ cOp) .or. ('DESCONTO' $ cOp)
		if ! empty(nSeqBx := StrToKArr(ZBA->(ZBA_FKFAMI), ';')[1])
			nSeqBx := val(nSeqBx)
		endif
		aBaixa := {;
			{"E1_FILIAL"  	,SE1->(E1_FILIAL)      	,Nil    	},;
			{"E1_PREFIXO"  	,SE1->(E1_PREFIXO)      	,Nil    	},;
			{"E1_NUM"      	,SE1->(E1_NUM)            	,Nil    	},;
			{"E1_PARCELA"  	,SE1->(E1_PARCELA)		,Nil    	},;
			{"E1_TIPO"     	,SE1->(E1_TIPO)           	,Nil    	},;
			{"E1_CLIENTE"   	,SE1->(E1_CLIENTE)         ,Nil    	},;
			{"E1_LOJA"   		,SE1->(E1_LOJA)          	,Nil    	}}
		oFil := cbcFiliais():newcbcFiliais()
		oFil:setFilial(SE1->(E1_FILIAL))
		oExec := cbcExecAuto():newcbcExecAuto(aBaixa)
		oExec:exAuto('Fina070',5,nSeqBx)
		aRetEx := oExec:getRet()
		if !aRetEx[1]
			oSelf:setStatus(.F., aRetEx[2])
		endif
		oFil:backFil()
		FreeObj(oFil)
		FreeObj(oExec)
	endif
	
	DbSelectArea('ZBA')
	if ZBA->(RecLock(('ZBA'), .F.))
		ZBA->(DbDelete())
	endif
return(nil)


/*/{Protheus.doc} vldEmpty
@type function
@author bolognesi
@since 23/05/2018
@description Validação para modelo de dados Vazio, provenientes
das rotinas de telas.
TAG: Validação de modelo.
/*/
static function vldEmpty(oMdl,cName,oSelf)
	if oMdl:isEmpty()
		oSelf:setStatus(.F., 'Registro ' + cName + ' Vazio ')
	endif
return(nil)


/*/{Protheus.doc} vldDelLock
@type function
@author bolognesi
@since 23/05/2018
@description Validação para modelo de dados, verificando
linhas deletadas e exclusividade em registros para processar,
provenientes das rotinas de telas.
TAG: Validação de modelo.
/*/
static function vldDelLock(oMdl,oSelf)
	local nRec			:= oMdl:GetDataId(oMdl:getLine())
	if oMdl:ISDELETED()
		oSelf:setStatus(.F., 'Linha do registro está deletada')
	endif
	if ! oSelf:oRec:prepLock({{'SE1', nRec, .T.}}):okLock()
		oSelf:setStatus(.F., 'Processo precisa de acesso exclusivo')
	endif
return(nil)


/*/{Protheus.doc} f060Trans
@type function
@author bolognesi
@since 23/05/2018
@description Padrão para realizar as tranferencias de carteiras.
TAG: Transferencia.
/*/
static function f060Trans(nRecSE1, oSelf)
	local aAreaX5			:= {}
	local aAreaE1			:= {}
	local lRet				:= .T.
	private nPrazoMed		:= 0
	private nTaxaDesc		:= 0
	private nVlrDesc		:= 0
	private nTxMoeda 		:= 0
	private dDataMov		:= dDataBase
	private nValdesc 		:= 0
	private nMoedaBco		:= 1
	private E1_SALDO
	aAreaX5 := SX5->(GetArea())
	aAreaE1 := SE1->(GetArea())
	FA060Trans("SE1",nRecSE1,2)
	RestArea(aAreaE1)
	RestArea(aAreaX5)
return(lRet)


/*/{Protheus.doc} lastNCCWrn
@type function
@author bolognesi
@since 23/05/2018
@description Ultimos avisos e confirmações para gerar relatorio NCC
TAG: Avisos e confirmações.
/*/
static function lastNCCWrn(oMdl,oMdlNCC,oSelf)
	local lRet			:= .T.
	local cTxtConfirm	:= ''
	local nRecNCC 		:= oMdlNCC:GetDataId(oMdlNCC:getLine())
	local nRecTIT		:= oMdl:GetDataId(oMdl:getLine())
	local nSldTIT		:= oMdl:GetValue('SALDO')
	local nSldNCC		:= oMdlNCC:GetValue('SALDO')
	local lPar			:= (mod(Randomize( 1, 100 ),2) == 0)
	
	SE1->(DbGoTo(nRecNCC))
	cTxtConfirm	+= '<b>Titulo NCC</b>' + LINHA
	cTxtConfirm	+= ' Nro. ' + SE1->(E1_NUM) + ' Parcela: ' + SE1->(E1_PARCELA) + LINHA
	cTxtConfirm	+= ' Saldo ' + cValToChar(nSldNCC) + LINHA
	SE1->(DbGoTo(nRecTIT))
	cTxtConfirm	+= '<b>Titulo</b>' + LINHA
	cTxtConfirm	+= ' Nro. ' + SE1->(E1_NUM) + ' Parcela: ' + SE1->(E1_PARCELA) + LINHA
	cTxtConfirm	+= ' Saldo ' + cValToChar(nSldTIT) + LINHA
	cTxtConfirm	+= ' <b> usuario: ' + oSelf:cNomUsr + '</b>'
	
	if lPar
		lRet := MsgNoYes( cTxtConfirm, 'Confirma Operação' )
	else
		lRet := MsgYesNo( cTxtConfirm, 'Confirma Operação' )
	endif
	if !lRet
		oSelf:setStatus(.F., 'Operação cancelada pelo usuario.')
	endif
return(lRet)


/*/{Protheus.doc} gravaZBA
@type function
@author bolognesi
@since 23/05/2018
@description Realiza a gravação inicial do registro no ZBA,
gravação ocorre sem o numero do relatorio, e já preparado todos os
valores necessarios para as proxima operação (Gerar CT2, Cancelar e ETC..)
TAG: Criar registro ZBA.
/*/
static function gravaZBA(nAcresc,cOper,cHistMov,nVlrBaixa,oSelf,aFk)
	local oZBAModel 	:= FWLoadModel('cbcZBAModel')
	local cIDModel	:= 'ZBAMASTER'
	local lRet		:= .F.
	local nVlrOp		:= 0
	local aErro		:= {}
	default aFk		:= {SE1->(Recno())}
	default nAcresc	:= 0
	default nVlrBaixa	:= SE1->(E1_VALOR)
	default cHistMov	:= 'Hist.Padrão Manut. Titulos'
	
	nVlrOp	:= (nVlrBaixa + nAcresc)
	oZBAModel:SetOperation(MODEL_OPERATION_INSERT)
	oZBAModel:Activate()
	oZBAModel:SetValue( cIDModel,'ZBA_FILIAL', 	SE1->(E1_FILIAL))
	oZBAModel:SetValue(cIDModel, 'ZBA_PREFIX',	SE1->(E1_PREFIXO))
	oZBAModel:SetValue(cIDModel, 'ZBA_NUM'	,	SE1->(E1_NUM))
	oZBAModel:SetValue(cIDModel, 'ZBA_PARC'	,	SE1->(E1_PARCELA))
	oZBAModel:SetValue(cIDModel, 'ZBA_TIPO'	,	SE1->(E1_TIPO))
	oZBAModel:SetValue(cIDModel, 'ZBA_CLI'	,	SE1->(E1_CLIENTE))
	oZBAModel:SetValue(cIDModel, 'ZBA_LOJA'	,	SE1->(E1_LOJA))
	oZBAModel:SetValue(cIDModel, 'ZBA_NOMCLI',	SE1->(E1_NOMCLI))
	oZBAModel:SetValue(cIDModel, 'ZBA_NROREL',	'')
	oZBAModel:SetValue(cIDModel, 'ZBA_OPER'	,	cOper)
	oZBAModel:SetValue(cIDModel, 'ZBA_HISTOP',	cHistMov)
	oZBAModel:SetValue(cIDModel, 'ZBA_DTREL'	,	Date())
	oZBAModel:SetValue(cIDModel, 'ZBA_HISTF'	,	SE1->(E1_PORTADO + E1_NUMBCO) )
	oZBAModel:SetValue(cIDModel, 'ZBA_VALOR'	,	SE1->(E1_VALOR))
	oZBAModel:SetValue(cIDModel, 'ZBA_VLROPE',	nVlrOp)
	oZBAModel:SetValue(cIDModel, 'ZBA_SALDO'	,	SE1->(E1_SALDO))
	oZBAModel:SetValue(cIDModel, 'ZBA_EMISS'	,	SE1->(E1_EMISSAO))
	oZBAModel:SetValue(cIDModel, 'ZBA_VENORI',	SE1->(E1_VENCORI))
	oZBAModel:SetValue(cIDModel, 'ZBA_VENCTO',	SE1->(E1_VENCTO))
	oZBAModel:SetValue(cIDModel, 'ZBA_BAIXA'	,	SE1->(E1_BAIXA))
	oZBAModel:SetValue(cIDModel, 'ZBA_VENCRE',	SE1->(E1_VENCREA))
	oZBAModel:SetValue(cIDModel, 'ZBA_SDACRE',	0)
	oZBAModel:SetValue(cIDModel, 'ZBA_DESCON', 	if (('DESCONTO' $ cOper) .Or. ('DESC.' $ cOper),nVlrOp,0))
	oZBAModel:SetValue(cIDModel, 'ZBA_SLDESC',	0)
	oZBAModel:SetValue(cIDModel, 'ZBA_SE1REC'	,cValToChar(SE1->(Recno())) )
	oZBAModel:SetValue(cIDModel, 'ZBA_FKFAMI'	,relacFK(aFk)  )
	oZBAModel:SetValue(cIDModel, 'ZBA_VLRCC',	valueForDbt(cOper,nVlrOp,SE1->(E1_SALDO),nAcresc))
	oZBAModel:SetValue(cIDModel, 'ZBA_OPECC'		,operForDbt(cOper, nAcresc)  )
	
	if ! (lRet := oZBAModel:VldData())
		aErro := oZBAModel:GetErrorMessage()
		oSelf:setStatus(.F.,aErro[6])
	else
		FWFormCommit(oZBAModel)
	endIf
	
return(lRet)


/*/{Protheus.doc} relacFK
@type function
@author bolognesi
@since 23/05/2018
@description Obtem chave para relacionar o registro ZBA
com registros FK1/Fk7, evitando posteriores buscas.
TAG: Relacionamento Familia FK.
/*/
static function relacFK(aFk)
	local cVlr 		:= ''
	local nOp		:= 0
	local oSql 		:= nil
	local cQry		:= ''
	local cChave		:= ''
	local nTmFK		:= 0
	default aFk		:= {}
	
	if ! empty(aFk)
		nTmFK := len(aFk)
		SE1->(DbGoTo(aFk[TITULO_NF_RECNO]))
		cChave := SE1->(E1_FILIAL+'|'+E1_PREFIXO+'|'+E1_NUM+'|'+E1_PARCELA+'|'+E1_TIPO+'|'+E1_CLIENTE+'|'+E1_LOJA)
		cQry += " SELECT "
		cQry += " MAX(FK1_SEQ) AS [SEQ] "
		cQry += " FROM %FK7.SQLNAME% "
		cQry += " INNER JOIN %FK1.SQLNAME%
		cQry += " ON FK7.FK7_IDDOC = FK1.FK1_IDDOC
		cQry += " AND FK7.D_E_L_E_T_ = FK1.D_E_L_E_T_
		cQry += " WHERE
		cQry += " FK7.FK7_CHAVE  = '" + cChave + "' "
		if nTmFK == 2
			cQry += " AND FK1.FK1_TPDOC = 'CP'
		else
			cQry += " AND FK1.FK1_TPDOC IN ('BA','VL')
		endif
		cQry += " AND %FK7.NOTDEL%
		
		oSql 	:= LibSqlObj():newLibSqlObj()
		oSql:newAlias(cQry)
		if oSql:hasRecords()
			oSql:goTop()
			while oSql:notIsEof()
				cVlr := oSql:getValue("SEQ")
				oSql:skip()
			endDo
			oSql:close()
		endif
		FreeObj(oSql)
		
		if ! empty(cVlr)
			if (nOp := len(aFk)) == 2
				SE1->(DbGoTo(aFk[TITULO_NCC_RECNO]))
				cVlr +=  ";" + SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_LOJA )
			endif
		endif
	endif
	
	// Posicionamento para retorno importante
	SE1->(DbGoTo(aFk[TITULO_NF_RECNO]))
return(cVlr)


/*/{Protheus.doc} infProtesto
@type function
@author bolognesi
@since 23/05/2018
@description Obter historico para operações de protestos.
TAG: Protesto.
/*/
static function infProtesto(cHistBx,nVlrBaixa,self)
	local aParamBox		:= {}
	local aRet			:= {}
	aAdd(aParamBox,{1,'Historico' 		,space(TamSx3('ZBA_HISTOP')[1]),PesqPict('ZBA','ZBA_HISTOP' ),'', '','',110,.T.})
	if ! ParamBox(aParamBox,'Protesto',@aRet)
		oSelf:setStatus(.F., 'Sem informações para movimento de protesto.')
	else
		cHistBx := aRet[1]
		nVlrBaixa := SE1->(E1_SALDO)
	endif
return(nil)


/*/{Protheus.doc} fBxTitulo
@type function
@author bolognesi
@since 23/05/2018
@description Realiza a baixa(baixa/desconto), para um titulo
utilizando a MsExecAuto Fina070.
TAG: Baixa o titulo.
/*/
static function fBxTitulo(nVlrBaixado, nAcresc, cHistBx, nSaldo, oSelf)
	local aSE1Area		:= SE1->(GetArea())
	local aBaixa 			:= {}
	local lErro 			:= .F.
	local oExec 			:= nil
	local aRet			:= {}
	local cPerg			:= ''
	local aParamBox		:= {}
	local aRetEx			:= {}
	local dBkData			:= dDataBase
	local cOper			:= oSelf:getOperacao()
	local cMotBx			:= ''
	local cTitParam		:= ''
	local cTxtConfirm		:= ''
	local cTxtAcresc		:= ''
	local cDescBx			:= ''
	local cLabelPar		:= ''
	local AltData			:= ''
	local lEsMtBx			:= '.F.'
	local oFil			:= nil
	
	default nVlrBaixado	:= 0
	default nAcresc		:= 0
	default cHistBx		:= ''
	
	getTexts(cOper,@cMotBx,@cTitParam,@cTxtConfirm,@cDescBx,@cLabelPar,@AltData)
	
	if lEscMotBx
		zMotBx(oSelf)
		lEsMtBx := '.T.'
	endif
	
	aAdd(aParamBox,{1,'Motivo da Baixa' ,Padr(cMotBx, TamSx3('FK1_MOTBX')[1]),PesqPict('FK1','FK1_MOTBX' ),'', 'ZY',lEsMtBx,50,.T.})
	aAdd(aParamBox,{1,"Banco"    		,SE1->(E1_PORTADO),PesqPict('SE1','E1_PORTADO'),'', 'A64','.F.',50,.T.})
	aAdd(aParamBox,{1,"Agencia" 		,SE1->(E1_AGEDEP),PesqPict('SE1','E1_AGEDEP'),'', '','.F.',50,.T.})
	aAdd(aParamBox,{1,"Conta"    		,SE1->(E1_CONTA),PesqPict('SE1','E1_CONTA'),'', '','.F.',50,.T.})
	aAdd(aParamBox,{1,cLabelPar  		,dDataBase,PesqPict('SK1','FK1_DATA'),"","", AltData ,50,.T.})
	aAdd(aParamBox,{1,"Valor"  		,nSaldo,PesqPict('SE1','E1_VALOR'),"","","",100,.T.})
	aAdd(aParamBox,{1,'Historico' 		,space(TamSx3('ZBA_HISTOP')[1]),PesqPict('ZBA','ZBA_HISTOP' ),'', '','',110,.T.})
	
	if ! ParamBox(aParamBox,cTitParam,@aRet)
		oSelf:setStatus(.F., 'Sem informações para realizar a baixa.')
	else
		if (aRet[5] <= GetNewPar('MV_DATAFIN', date()))
			oSelf:setStatus(.F., 'Data da baixa não pode ser menor que MV_DATAFIN.')
		endif
		
		dDataBase	:= aRet[5]
		nVlrBaixado 	:= aRet[6]
		cHistBx		:= aRet[7]
		
		if  cOper == 'baixar'
			if ( nVlrBaixado > nSaldo )
				nAcresc		:= (nVlrBaixado - nSaldo)
				nVlrBaixado	:= nSaldo
				cTxtAcresc	+= ' com acrescimo de ' + cValToChar(nAcresc)
			endif
		elseif cOper == 'desconto'
			if nVlrBaixado > nSaldo
				oSelf:setStatus(.F., ' Desconto não pode ser maior que o saldo a receber do titulo. ')
			endif
		endif
		lastWrn(nSaldo,(cTxtConfirm + cValToChar(nVlrBaixado) + cTxtAcresc),oSelf,,nAcresc)
		aBaixa := {;
			{"E1_FILIAL"  	,SE1->(E1_FILIAL)      	,Nil    	},;
			{"E1_PREFIXO"  	,SE1->(E1_PREFIXO)      	,Nil    	},;
			{"E1_NUM"      	,SE1->(E1_NUM)            	,Nil    	},;
			{"E1_PARCELA"  	,SE1->(E1_PARCELA)		,Nil    	},;
			{"E1_TIPO"     	,SE1->(E1_TIPO)           	,Nil    	},;
			{"E1_CLIENTE"   	,SE1->(E1_CLIENTE)         ,Nil    	},;
			{"E1_LOJA"   		,SE1->(E1_LOJA)          	,Nil    	},;
			{"E1_NOMCLI"    	,SE1->(E1_NOMCLI)         	,Nil    	},;
			{"E1_NATUREZ"   	,SE1->(E1_NATUREZ)         ,Nil    	},;
			{"AUTMOTBX"    	,aRet[1]       			,Nil    	},;
			{"AUTBANCO"    	,aRet[2]           		,Nil    	},;
			{"AUTAGENCIA"  	,aRet[3]         			,Nil    	},;
			{"AUTCONTA"    	,aRet[4]     				,Nil    	},;
			{"AUTDTBAIXA"  	,dDataBase         		,Nil    	},;
			{"AUTDTCREDITO"	,dDataBase         		,Nil    	},;
			{"AUTHIST"     	,cDescBx					,Nil    	},;
			{"AUTACRESC"    	,0						,Nil	, 	.T.},;
			{"AUTJUROS"    	,nAcresc                	,Nil	,	.T.},;
			{"AUTVALREC"   	,(nVlrBaixado + nAcresc)  	,Nil    	}}
		
		oFil := cbcFiliais():newcbcFiliais()
		oFil:setFilial(SE1->(E1_FILIAL))
		
		oExec := cbcExecAuto():newcbcExecAuto(aBaixa)
		oExec:exAuto('Fina070',3)
		
		aRetEx := oExec:getRet()
		if !( lErro := aRetEx[1] )
			oSelf:setStatus(.F., aRetEx[2])
		endif
		
		oFil:backFil()
		FreeObj(oFil)
		FreeObj(oExec)
		dDataBase := dBkData
	endif
	RestArea(aSE1Area)
return (lErro)


/*/{Protheus.doc} lastWrn
@type function
@author bolognesi
@since 23/05/2018
@description Ultimas confirmações para gerar os relatorios de baixas.
TAG: Confirmações.
/*/
static function lastWrn(nSaldo,cTxtConfirm,oSelf,lEx)
	local lRet	:= .T.
	local cPerg	:= ''
	local lPar	:= (mod(Randomize( 1, 100 ),2) == 0)
	default lEx	:= .T.
	
	cPerg := Alltrim(oSelf:cNomUsr) + ', confirma a operação no titulo ' + LINHA
	cPerg += ' Nro. ' + SE1->(E1_NUM) + ' Parcela.' + SE1->(E1_PARCELA) + LINHA
	cPerg += ' Saldo ' + cValToChar(nSaldo) + LINHA
	cPerg += cTxtConfirm
	
	if lPar
		lRet := MsgNoYes ( cPerg, 'Confirma Operação' )
	else
		lRet := MsgYesNo ( cPerg, 'Confirma Operação' )
	endif
	
	if !lRet .and. lEx
		oSelf:setStatus(.F., 'Operação cancelada pelo usuario.')
	endif
return(lRet)


/*/{Protheus.doc} exAuto040
@type function
@author bolognesi
@since 23/05/2018
@description Realiza alterações no titulo utilizando exec auto FINA040.
TAG: Alterações em titulos SE1.
/*/
static function exAuto040(oSelf, aUpd)
	local aTit	:= {}
	local lErro	:= .T.
	local aRetEx	:= {}
	local oExec	:= nil
	local oFil	:= nil
	local aChvFix	:= {}
	local nX		:= 0
	default aUpd	:= {}
	
	if !empty(aUpd)
		oFil := cbcFiliais():newcbcFiliais()
		aadd( aChvFix, {"E1_FILIAL"  	,SE1->(E1_FILIAL) ,Nil } )
		aadd( aChvFix, {"E1_PREFIXO" 	,SE1->(E1_PREFIXO),Nil } )
		aadd( aChvFix, {"E1_NUM"  		,SE1->(E1_NUM)  	,Nil } )
		aadd( aChvFix, {"E1_PARCELA"  	,SE1->(E1_PARCELA),Nil } )
		aadd( aChvFix, {"E1_TIPO"  	,SE1->(E1_TIPO)  	,Nil } )
		aadd( aChvFix, {"E1_CLIENTE"  	,SE1->(E1_CLIENTE),Nil } )
		aadd( aChvFix, {"E1_LOJA"  	,SE1->(E1_LOJA)  	,Nil } )
		
		for nX := 1 to len(aChvFix)
			aadd( aTit,aChvFix[nX] )
		next nX
		for nX := 1 to len(aUpd)
			aadd( aTit,aUpd[nX] )
		next nX
		
		oFil:setFilial(SE1->(E1_FILIAL))
		oExec := cbcExecAuto():newcbcExecAuto(aTit)
		oExec:exAuto('FINA040',4)
		aRetEx := oExec:getRet()
		if !( lErro := aRetEx[1] )
			oSelf:setStatus(.F., aRetEx[2])
		endif
		oFil:backFil()
		FreeObj(oFil)
		FreeObj(oExec)
	endif
return(lErro)


/*/{Protheus.doc} getTexts
@type function
@author bolognesi
@since 23/05/2018
@description Obtem textos e definições utilizados em operações de baixa/desconto
TAG: Alertas e confirmações.
/*/
static function getTexts(cOper,cMotBx,cTitParam,cTxtConfirm,cDescBx,cLabelPar,AltData)
	if  cOper == 'baixar'
		cMotBx			:= 'NOR'
		cTitParam		:= 'Baixar titulo...'
		cTxtConfirm		:= ' Operação de Baixa no valor de '
		cDescBx			:= 'baixa rotina cbcTitManut'
		cLabelPar		:= 'Data da Baixa'
		AltData			:= '.T.'
	elseif cOper == 'desconto'
		cMotBx			:= 'DES'
		cTitParam		:= 'Baixa para desconto...'
		cTxtConfirm		:= ' Operação de Desconto no valor de '
		cDescBx			:= 'desconto rotina cbcTitManut'
		cLabelPar		:= 'Data do Desconto'
		AltData			:= '.F.'
	endif
return(nil)


/*/{Protheus.doc} zMotBx
@type function
@author bolognesi
@since 23/05/2018
@description Atualiza os motivos de baixa na SX5 tabela ZY.
TAG: Uteis.
/*/
static function zMotBx(oSelf)
	local lUpd		:= .F.
	local nX			:= 0
	
	DbSelectArea("SX5")
	SX5->(DbSetOrder(1))
	if Len((aMotBx := lerMotBx())) < 1
		oSelf:setStatus(.F., "Motivos de baixa não carregados!")
	endIf
	for nX := 1 to len(aMotBx)
		lUpd := ! SX5->(DbSeek(xFilial("SX5") + "ZY" + aMotBx[nX,1] ,.F.))
		//FwPutSX5(, "ZY",aMotBx[nX,1], aMotBx[nX,2], aMotBx[nX,2],aMotBx[nX,2], aMotBx[nX,2])
		SX5->(RecLock("SX5",lUpd))
		SX5->(X5_FILIAL)	:= xFilial("SX5")
		SX5->(X5_TABELA)	:= "ZY"
		SX5->(X5_CHAVE)   := aMotBx[nX,1]
		SX5->(X5_DESCRI)	:= aMotBx[nX,2]
		SX5->(X5_DESCSPA)	:= aMotBx[nX,2]
		SX5->(X5_DESCENG)	:= aMotBx[nX,2]
		SX5->(MsUnLock())
	next nX
return(nil)


/*/{Protheus.doc} lerMotBx
@type function
@author bolognesi
@since 23/05/2018
@description Le o arquivo com os motivos de baixas
utilizando função ReadMotBx().
TAG: Uteis.
/*/
static function lerMotBx()
	local aMotBx		:= {}
	local aBaixaAtu	:= {}
	local aTmpBx		:= {}
	local nX			:= 0
	aMotBx 			:= ReadMotBx()
	for nX := 1 to len(aMotBx)
		aTmpBx	:= StrTokArr(aMotBx[nX], '³')
		aadd(aBaixaAtu,{aTmpBx[1],aTmpBx[2]}  )
	next nX
return(aBaixaAtu)


/*/{Protheus.doc} delProc
@type function
@author bolognesi
@since 23/05/2018
@description Realiza o processo de cancelamento de registros
ZBA sem numero de relatorio porem com a operação no titulo realizada.
TAG: Excluir registros ZBA sem relatorio.
/*/
static function delProc(oSelf,aElem)
	local lRet		:= .T.
	local nX			:= 0
	local nRecTmp		:= 0
	local cAlsTmp		:= ''
	local bErro		:= nil
	
	cPerg := Alltrim(oSelf:cNomUsr) + ', deseja deletar todos os marcados? '
	if (lRet := MsgNoYes( cPerg, 'Manut.Titulos' ))
		bErro	:= ErrorBlock({|oErr| HandleEr(oErr, oSelf)})
		BEGIN SEQUENCE
			for nX := 1 to len(aElem)
				BEGIN TRANSACTION
					DbSelectArea('SE1')
					DbSelectArea('ZBA')
					ZBA->(DbGoTo(aElem[nX,1]))
					SE1->( DbGoTo(Val(ZBA->(ZBA_SE1REC))) )
					procCanc(ZBA->(ZBA_OPER),oSelf)
					cAlsTmp := aElem[nX][2][1][2][2]
					nRecTmp := aElem[nX][2][1][2][3]
					if ! remTmp(cAlsTmp,nRecTmp)
						lRet := .F.
						oSelf:setStatus(.F., 'Erro ao excluir temporario')
					endif
				END TRANSACTION
			next nX
		RECOVER
		END SEQUENCE
		ErrorBlock(bErro)
	endif
return(lRet)


/*/{Protheus.doc} initProc
@type function
@author bolognesi
@since 23/05/2018
@description Inicia o processo de operação para gerar o relatorio em
registros ZBA sem numero de relatorio, atualiza o ZBA updZBA() com o numero
de relatorio, cria o CT2 conta corrente quando necessario e realiza as impressões
do relatorio
TAG: Iniciar geração relatorio.
/*/
static function initProc(oSelf,aElem)
	local nX 		:= 0
	local cPerg		:= ''
	local cNrRel		:= ''
	local cOp		:= ''
	local cAlsTmp		:= ''
	local nRecTmp		:= 0
	local aRelGer		:= {}
	local cMsgOk		:= ''
	local lPrint		:= .F.
	local cRelaOp		:= ''
	local bErro		:= nil
	
	cPerg := Alltrim(oSelf:cNomUsr) + ', confirma a geração dos relatorios? '
	if (lRet := MsgNoYes( cPerg, 'Manut.Titulos' ))
		bErro	:= ErrorBlock({|oErr| HandleEr(oErr, oSelf)})
		BEGIN SEQUENCE
			ASort(aElem, , , {|x,y| Alltrim(x[2,1,2,1]) > Alltrim(y[2,1,2,1]) } )
			BEGIN TRANSACTION
				for nX := 1 to len(aElem)
					if cOp <> Alltrim(aElem[nX,2,1,2,1])
						cOp := Alltrim(aElem[nX,2,1,2,1])
						if !empty(cNrRel)
							oSelf:commitNum()
						endif
						cNrRel := oSelf:nextNum()
						aadd(aRelGer,{cNrRel,cOp})
						MsgInfo('Operação: ' + cOp ,' Gerando Relatorio ' + cValToChar(cNrRel) )
					endif
					updZBA(aElem[nX,1], cNrRel)
					cAlsTmp := aElem[nX][2][1][2][2]
					nRecTmp := aElem[nX][2][1][2][3]
					if ! remTmp(cAlsTmp,nRecTmp)
						oSelf:setStatus(.F.,'Erro ao deletar o temporario')
					endif
				next nX
				criaCT2(aRelGer,oSelf)
			END TRANSACTION
			
			oSelf:commitNum()
			oSelf:oHashMrk	:= HMNew()
			lPrint :=  MsgNoYes( 'Imprimir os relatorios?', 'Manut.Titulos' )
			for nX := 1 to len(aRelGer)
				cMsgOk += 'Relatorio Nro. ' + aRelGer[nX,1] +  ' Operação: ' + aRelGer[nX,2] + LINHA
				if lPrint
					printIt(aRelGer[nX,1],aRelGer[nX,2])
				endif
			next nX
			if !empty(cMsgOk)
				MsgInfo(cMsgOk,'Sucesso')
			endif
		RECOVER
		END SEQUENCE
		ErrorBlock(bErro)
	endif
return(nil)


/*/{Protheus.doc} printIt
@type function
@author bolognesi
@since 23/05/2018
@description Realiza a impressão dos relatorios de acordo com a operação
logo apos a geração, utiliza a função cbcZBARelat()
TAG: Iniciar geração relatorio.
/*/
static function printIt(cNro,cOp)
	local cRelaOp	:= ''
	
	if 'PROTESTO' $ cOp
		cRelaOp := "PROT"
	elseif 'BAIXAR' $ cOp
		cRelaOp := "BXDB"
	elseif 'DESCONTO' $ cOp
		cRelaOp :=  "DESC"
	elseif 'PRORROGACAO' $ cOp
		cRelaOp := "PRO"
	endif
	if !empty(cRelaOp)
		U_cbcZBARelat(.F.,cNro,cRelaOp)
	endif
return(nil)

/*/{Protheus.doc} operForDbt
@type function
@author bolognesi
@since 23/05/2018
@description Define a nivel de conta corrente se deve ser
um lançamento credito(CT2_CLVLCR) ou debito(CT2_CLVLDB).
TAG: Debito ou credito para conta-corrente.
/*/
static function operForDbt(cOper, nAcresc)
	local cOp	:= 'C'
	if ! ('PRORROGAÇÂO' $ cOper)
		if (nAcresc > 0 )
			cOp := 'D'
		endif
	endif
return(cOp)


/*/{Protheus.doc} valueForDbt
@type function
@author bolognesi
@since 23/05/2018
@description No registro ZBA deve conter o valor pronto que devera constar
no conta-corrente(CT2) esta função aplicas as regras de conta-corrente definido
este valor, no caso de não gerar conta-corrente apenas manter o retorno como zero(0).
TAG: Valor para conta-corrente.
/*/
static function valueForDbt(cOper,nVlrBaixa,nVlrSaldo,nAcresc)
	local nVlr 		:= 0
	default nAcresc 	:= 0
	default nVlrSaldo	:= 0
	if 'NÃO' $ cOper
		nVlr := 0
	elseif 'DEBITAR' $ cOper
		if nVlrSaldo == 0 .and. nAcresc > 0
			nVlr := nAcresc
		else
			nVlr := nVlrBaixa
		endif
	elseif 'DESCONTO' $ cOper
		nVlr := nVlrBaixa
	elseif ! ('PRORROGAÇÂO' $ cOper)
		if (nAcresc > 0 )
			nVlr := nAcresc
		endif
	endif
return(nVlr)


/*/{Protheus.doc} prepExec
@type function
@author bolognesi
@since 23/05/2018
@description Prepara cabeçalho e item para execauto de criação
do conta-corrente (CT2).
TAG: ExecAuto conta-corrente.
/*/
static function prepExec(cNro,cOper,aCab,aItm)
	local oSql 	:= LibSqlObj():newLibSqlObj()
	local cQry	:= ''
	local aOpVlr	:= {}
	local lOk	:= .F.
	local nX		:= 0
	local nVlr	:= 0
	local cOp	:= ''
	
	aCab 	:= {}
	aItm		:= {}
	cQry += " SELECT "
	cQry += " ZBA_OPECC		AS [OPER], "
	cQry += " SUM(ZBA_VLRCC) 	AS [VALOR] "
	cQry += " FROM  %ZBA.SQLNAME% "
	cQry += " WHERE %ZBA.XFILIAL% "
	cQry += " AND ZBA_NROREL = '" + cNro + "' "
	cQry += " AND ZBA_OPER = '" + cOper + "' "
	cQry += " AND ZBA_VLRCC > 0 "
	cQry += " AND %ZBA.NOTDEL% "
	cQry += " GROUP BY ZBA_OPECC
	
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			cOp	:= if (oSql:getValue("OPER")=='C','CT2_CLVLCR','CT2_CLVLDB')
			nVlr := oSql:getValue("VALOR")
			aadd(aOpVlr, {cOp,nVlr} )
			oSql:skip()
			lOk := .T.
		endDo
		oSql:close()
	endif
	if lOk
		aCab := {;
			{'DDATALANC' 	,Date() 			,NIL},;
			{'CLOTE' 	,"028850" 		,NIL},;
			{'CSUBLOTE' 	,'001' 			,NIL},;
			{'CDOC' 		,cNro 			,NIL},;
			{'CPADRAO' 	,'' 				,NIL},;
			{'NTOTINF' 	,0 				,NIL},;
			{'NTOTINFLOT' ,0 				,NIL} }
		for nX := 1 to Len(aOpVlr)
			aadd(aItm,{ {'CT2_FILIAL'	,FwFilial()   								,NIL},;
				{'CT2_LINHA'  		,StrZero(nX,3)								, NIL},;
				{'CT2_MOEDLC'  		,'01'   										, NIL},;
				{'CT2_DC'   			,'3'   										, NIL},;
				{'CT2_DEBITO'  		,'DEB' 										, NIL},;
				{'CT2_CREDIT'  		,'CRE' 										, NIL},;
				{'CT2_VALOR'  		, aOpVlr[nX,2]  								, NIL},;
				{'CT2_ORIGEM' 		,'RELDPL'									, NIL},;
				{'CT2_HP'   			,''   										, NIL},;
				{'CT2_EMPORI'   		,'01'   										, NIL},;
				{'CT2_FILORI'   		,FwFilial()   								, NIL},;
				{'CT2_TPSALD'   		,'6'   										, NIL},;
				{aOpVlr[nX,1]   		,'1101'   									, NIL},;
				{'CT2_HIST'   		,'RELAT.DUPLICATAS. NRO. ' + cValToChar(cNro), NIL} } )
		next nX
	endif
	FreeObj(oSql)
return(lOk)


/*/{Protheus.doc} criaCT2
@type function
@author bolognesi
@since 23/05/2018
@description Utiliza o ExecAuto para gerar o CT2.
TAG: ExecAuto conta-corrente.
/*/
static function criaCT2(aRelGer,oSelf)
	local aCab	:= {}
	local aItm	:= {}
	local aRetEx	:= {}
	local lOk	:= .T.
	local nX		:= 0
	for nX := 1 to len(aRelGer)
		if prepExec(aRelGer[nX,1],aRelGer[nX,2],@aCab,@aItm)
			oExec := cbcExecAuto():newcbcExecAuto(aItm,aCab)
			oExec:exAuto('CTBA102',3)
			aRetEx := oExec:getRet()
			if !( lOk := aRetEx[1] )
				oSelf:setStatus(.F.,aRetEx[2])
			endif
			FreeObj(oExec)
		endif
	next nX
return(lOk)


/*/{Protheus.doc} remTmp
@type function
@author bolognesi
@since 23/05/2018
@description Remove o registro das tabelas temporarias
criadas na tela do fonte cbcMarkZBA.
TAG: Temporaria cbcMarkZBA.
/*/
static function remTmp(cAlsTmp,nRecTmp)
	local lRet := .T.
	DbSelectArea(cAlsTmp)
	(cAlsTmp)->(DbGoTo(nRecTmp))
	if ( lRet:= (cAlsTmp)->(RecLock((cAlsTmp), .F.)) )
		(cAlsTmp)->(DbDelete())
	endif
return(lRet)


/*/{Protheus.doc} updZBA
@type function
@author bolognesi
@since 23/05/2018
@description Realiza atualização no registro ZBA, para gravar
numero do relatorio e data de sua geração.
TAG: Atualizar ZBA.
/*/
static function updZBA(nRec,cNroRel)
	local oZBAModel 	:= FWLoadModel('cbcZBAModel')
	local cIDModel	:= 'ZBAMASTER'
	local aErro		:= {}
	local lRet		:= .F.
	
	ZBA->(DbSelectArea('ZBA'))
	ZBA->(DbGoTo(nRec))
	oZBAModel:SetOperation(MODEL_OPERATION_UPDATE)
	oZBAModel:Activate()
	oZBAModel:SetValue(cIDModel,'ZBA_NROREL',cNroRel)
	oZBAModel:SetValue(cIDModel,'ZBA_DTREL',Date())
	
	if ! (lRet := oZBAModel:VldData())
		aErro := oZBAModel:GetErrorMessage()
		oSelf:setStatus(.F.,aErro[6])
	else
		FWFormCommit(oZBAModel)
	endIf
	oZBAModel:DeActivate()
	FreeObj(oZBAModel)
return(lRet)


/*/{Protheus.doc} HandleEr
@type function
@author bolognesi
@since 23/05/2018
@description Centraliza as tratativas de erros da classe.
TAG: Tratativa de erros.
/*/
static function HandleEr(oErr, oSelf)
	local lCompl	:= .F.
	
	if InTransact()
		DisarmTransaction()
	endif
	RestArea(oSelf:aArea)
	lCompl := ( Alltrim(oErr:Description) != Alltrim(oSelf:cMsgErr) )
	oSelf:oRec:libLock()
	dDatabase		:= oSelf:dDataBk
	oSelf:lOk		:= .F.
	
	oSelf:cMsgErr		:= "[cbcTitManut - "+DtoC(Date())+" - "+Time()+" ]"+;
		oErr:Description +;
		if ( FwIsAdmin() ,' [ORIGEM]' + ProcName(3), '')+;
		if(lCompl, '  ' + oSelf:cMsgErr, '')
	BREAK
return(nil)
