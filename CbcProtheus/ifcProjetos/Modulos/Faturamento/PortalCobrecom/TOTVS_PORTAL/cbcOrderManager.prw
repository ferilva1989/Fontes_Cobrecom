#include 'protheus.ch'
#include "portalcobrecom.ch"

/*/{Protheus.doc} cbcOrderManager
@author bolognesi
@since 28/03/2017
@version 1.0
@type class
@description Classe para tratar os envios dos pedido
relacionados com o portal, que ainda não foram liberados vendas.
bem como responsabilidades ()pedido do portal)
/*/
class cbcOrderManager 

	method newcbcOrderManager() constructor 
	method sendWarn()
	method initProcToOrder()

endclass

method newcbcOrderManager() class cbcOrderManager
return(self)

/*/{Protheus.doc} sendWarn
@author bolognesi
@since 28/03/2017
@version 1.0
@type method
@description Metodo que obtem as pedidos em situação irregular
getQuery(), obtem as mensagens correspondentes getMsg(), e utilizando
a classe gerente de schedule cbcSchCtrl(), agenda o envio na tabela ZPH
que devera de fato ser enviado para o destinatario de acordo com o schedule
da função zSchMng() no fonte cbcSchCtrl.prw
/*/
method sendWarn() class cbcOrderManager
	local oSch 		:=  nil
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local aReg		:= {}
	local aMsg		:= {}
	local cWfMsg	:= ""
	local nX		:= 0
	local cVlr		:= ""

	oSql:newAlias( getQuery() )
	oSql:setField("EMISSAO_PEDIDO", "D")
	oSql:setField("VALOR_PEDIDO", "N", 8, 2)

	if oSql:hasRecords()
		oSch := cbcSchCtrl():newcbcSchCtrl()
		oSch:setSimple( .F. )
		oSch:setIDEnvio('PEDPORTAL')
		oSch:addEmailTo( Alltrim(GetNewPar('XX_EMVEND', '')) )
		oSch:addEmailCc( Alltrim(GetNewPar('MV_EMGRPTI', '')) )
		oSch:setAssunto('[PORTAL] - PEDIDOS AGUARDANDO LIBERACAO DE VENDAS ')
		oSch:setHtmlFile('\scheduleLayout\html\pedidos_portal.html')

		oSql:goTop()
		while oSql:notIsEof()
			aReg 		:= {}
			aMsg		:= {}
			cVlr 		:= AllTrim(Transform( oSql:getValue("VALOR_PEDIDO"), PesqPict('SC5', 'C5_TOTAL')))

			aadd(aReg, {'Wf.Atendente'	,oSql:getValue("AllTrim(NOME_ATENDENTE)") 		})
			aadd(aReg, {'Wf.Filial'		,oSql:getValue("FILIAL")						})
			aadd(aReg, {'Wf.OrcPortal'	,oSql:getValue("AllTrim(NRO_PORTAL)")			})
			aadd(aReg, {'Wf.OrcInterno'	,oSql:getValue("AllTrim(NRO_PEDIDO)")			})
			aadd(aReg, {'Wf.EmissPedido',oSql:getValue("EMISSAO_PEDIDO")				})
			aadd(aReg, {'Wf.Atraso'		,oSql:getValue("ATR_DIAS")						})
			aadd(aReg, {'Wf.NomeCli'	,oSql:getValue("AllTrim(NOME_CLIENTE)")			})
			aadd(aReg, {'Wf.Repres'		,oSql:getValue("AllTrim(NOME_REPRESENTANTE)")	})
			aadd(aReg, {'Wf.Valor'		,cVlr											})
			aadd(aReg, {'Wf.Obs'		,oSql:getValue("AllTrim(OBS_PEDIDO)")			})

			//Obter todas as mensagens
			aMsg 	:= getMsg(oSql:getValue("AllTrim(NRO_PORTAL)"))
			cWfMsg 	:= ""
			if !empty(aMsg)
				for nX := 1 to len(aMsg)
					cWfMsg += Alltrim(StrTran(aMsg[nX], chr(13), '< br/>'))
				next nX
			endif
			aadd(aReg, {'Wf.Msg',cWfMsg	})

			oSch:addDados(aReg)
			oSql:skip()
		enddo

		if !Empty(oSch:getLines())
			oSch:schedule()
		endif

		FreeObj(oSch)
	endif

	oSql:close() 
	FreeObj(oSql)
return(self)

/*/{Protheus.doc} initProcToOrder
@author bolognesi
@since 23/05/2017
@version 1.0
@type method
@description Inicia o processo de transformação do orçamento para pedido.
considerando os orçamento com o status QUOTATION_STATUS_WAITING_PROCESSING
/*/
method initProcToOrder(cNumOrc) class cbcOrderManager
	local cQuotationId 	:= ''	
	local oQuotSrv	 	:= CbcQuotationService():newCbcQuotationService()
	local oCbcQuot		:= nil
	local oSql 			:= LibSqlObj():newLibSqlObj()
	local oUtils	 	:= LibUtilsObj():newLibUtilsObj()
	local oCbcOrder		:= nil
	local nItem			:= 0
	local nTotItem		:= 0
	local cQuotId		:= ''
	local cExist		:= ''
	local aReg			:= {}
	local nLimit		:= GetNewPar('XX_QTDPROC', 8 )
	local cEmailTi		:= Alltrim(GetNewPar('MV_EMGRPTI', ''))
	local cEmlUsr		:= ''
	default cNumOrc		:= ''

	oSch := cbcSchCtrl():newcbcSchCtrl()
	oSch:setSimple( .F. )
	oSch:setIDEnvio('SCHTOORDER')
	oSch:addEmailTo(cEmailTi)
	if !empty(cNumOrc)
		cEmlUsr := UsrRetMail(RetCodUsr())
		oSch:addEmailCc( if(!empty(cEmlUsr),cEmlUsr,cEmailTi))
	endif
	oSch:setAssunto('[SHCPORT] - Processamento de Orçamentos do Portal')
	oSch:setHtmlFile('\scheduleLayout\html\schedule_portal.html')

	oSch:addHdr({'HDR01', DtoC(Date())+" - "+Time() })
	while !Empty(cQuotationId	:= getQuot(oSql,cNumOrc)) .and. (nItem < nLimit)
		BEGIN TRANSACTION
			if oQuotSrv:setProcessing(cQuotationId)
				oCbcQuot := oQuotSrv:getById(cQuotationId)
				if !oUtils:isNull(oCbcQuot)
					nTotItem 	:= countItem(oCbcQuot)
					aReg		:= {}
					FWMonitorMsg("[PORTAL][SCH-][ORCAMENTO " + cQuotationId + " ITENS: " + cValToChar(nTotItem) + "  LOOP: " + cValToChar(nItem) + "]" )
					nItem++
					aadd(aReg, {'Wf.Item'		, cValToChar(nItem)})
					aadd(aReg, {'Wf.Time'		, DtoC(Date())+" - "+Time() })
					aadd(aReg, {'Wf.Orcamento'	, Alltrim(cQuotationId) })
					aadd(aReg, {'Wf.ItensOrc'	, cValToChar(nTotItem) })

					cExist 	:= oSql:getFieldValue("SC5", "C5_NUM", "%SC5.XFILIAL% AND C5_DOCPORT = '" + cQuotationId + "'")
					oSql:close() 
					if !empty( cExist )	
						aadd(aReg, {'Wf.Mensagem','Já existe para este orçamento: ' +  cQuotationId + ' um pedido com o numero:  ' + cExist })
					else
						if !LockByName('CONFIRM'+ cQuotationId, .F. , .F. )
							aadd(aReg, {'Wf.Mensagem','Orçamento: ' + cQuotationId + ' já esta em processo para virar pedido, aguarde!' })
						else
							oCbcOrder	:= CbcBudgetToOrder():newCbcBudgetToOrder()
							oCbcOrder:setQuot(oCbcQuot)
							oCbcOrder:toOrder()

							if oCbcOrder:itsOk()
								if !oQuotSrv:setConfirmed(oCbcQuot, oCbcOrder:getDocuments())
									aadd(aReg, {'Wf.Mensagem','RollBack - ' + oQuotSrv:cErrorMessage +' Erro ao definir status de confirmado!' })
									DisarmTransaction()
								else
									aadd(aReg, {'Wf.Mensagem','OK!' })
								endif
							else
								if !oQuotSrv:setErrorProcessing(oCbcQuot, oCbcOrder:getMsgLog(.T.))
									aadd(aReg, {'Wf.Mensagem',' RollBack - ' + oQuotSrv:cErrorMessage + ' Erro ao definir status! ' + oCbcOrder:getMsgLog( ,.T.) })
									DisarmTransaction()
								else
									aadd(aReg, {'Wf.Mensagem', oCbcOrder:getMsgLog( ,.T. ) })
								endif

							endif
							UnLockByName('CONFIRM'+ cQuotationId, .F. , .F. )
							oSch:addDados(aReg)
							FreeObj(oCbcOrder)
						endif
					endif
				endIf 
			endif
		END TRANSACTION
		MsUnlockAll()

		if !empty(cNumOrc)
			exit
		endif
	enddo

	if empty(nItem)
		oSch:addHdr({'HDR02',"Schedule do portal, nada para processar "})
	elseif !empty(cNumOrc)
		oSch:addHdr({'HDR02',"Schedule do portal, execução manual pelo usuario: " + UsrRetName(RetCodUsr()) })
	else
		oSch:addHdr({'HDR02',"Iniciando o schedule para processamento de orçamentos portal "})
	endif

	if !Empty(oSch:getLines())
		oSch:addHdr({'HDR03', DtoC(Date())+" - "+Time() })
		oSch:schedule()
	endif

	FreeObj(oSch)
	FreeObj(oQuotSrv)
	FreeObj(oSql)
return(self)

/*/{Protheus.doc} getMsg
@author bolognesi
@since 28/03/2017
@version 1.0
@param cNumOrc, characters, Numero do orçamento no Portal (ZP5)
@type function
@description Obter para um numero de orçamento do portal (ZP5) todas
as menssagens (ZP3) relacionadas.
/*/
static function getMsg(cNumOrc)
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local aMsg 		:= {}
	local cTxt		:= ""
	local cQuery	:= ""
	local oMemo		 := nil

	cQuery += " SELECT ZP3.R_E_C_N_O_ AS RECNO, "
	cQuery += " ZP3.ZP3_DATA AS DATA, "
	cQuery += " ZP3.ZP3_HORA AS HORA, "
	cQuery += " ZP1.ZP1_NOME AS NOME "  
	cQuery += " FROM %ZP3.SQLNAME% "
	cQuery += " INNER JOIN %ZP1.SQLNAME% "
	cQuery += " ON %ZP1.XFILIAL% "
	cQuery += " AND ZP3.ZP3_USRORI = ZP1.ZP1_CODIGO " 
	cQuery += " AND ZP3.D_E_L_E_T_ = ZP1.D_E_L_E_T_ "
	cQuery += " WHERE %ZP3.XFILIAL% AND ZP3_NUMORC = '"+ cNumOrc +"' AND "
	cQuery += " %ZP3.NOTDEL% " 

	oSql:newAlias( cQuery )
	oSql:setField("DATA", "D")
	if oSql:hasRecords()
		oMemo 	:= ManBaseDados():newManBaseDados()
		oSql:goTop()
		while oSql:notIsEof()
			cTxt := "<p>"
			cTxt += '[' + oSql:getValue("Alltrim(NOME)") + ']-'	
			cTxt += '[' + oSql:getValue("DtoC(DATA)") + ' ' + oSql:getValue("Alltrim(HORA)") + ']-'
			cTxt += oMemo:getMemo('ZP3', 'ZP3_MSG', oSql:getValue("RECNO"), .T. )
			cTxt += "</p>"
			cTxt += "<br /><br />"
			Aadd(aMsg,cTxt )
			oSql:skip()
		enddo
		FreeObj(oMemo)
	endif

	oSql:close() 
	FreeObj(oSql)
return(aMsg)

/*/{Protheus.doc} getQuery
@author bolognesi
@since 28/03/2017
@version 1.0
@type function
@description Retorna a query utilizada para obter os pedidos relacinados
com o portal e que ainda não foram liberados pelo departamento de vendas.
/*/
static function getQuery()
	local cQry := ""
	cQry += " SELECT " 
	cQry += " ATEND.A3_NOME					 AS NOME_ATENDENTE, "
	cQry += " SC5.C5_FILIAL					 AS FILIAL, "
	cQry += " SC5.C5_DOCPORT				 AS NRO_PORTAL, "
	cQry += " SC5.C5_NUM					 AS NRO_PEDIDO, "
	cQry += " SC5.C5_EMISSAO				 AS EMISSAO_PEDIDO, "
	cQry += " DATEDIFF(DAY,SC5.C5_EMISSAO, GETDATE() ) AS ATR_DIAS, "
	cQry += " SA1.A1_NOME					 AS NOME_CLIENTE, "
	cQry += " REPRE.A3_NOME					 AS NOME_REPRESENTANTE, "
	cQry += " SC5.C5_TOTAL					 AS VALOR_PEDIDO, "
	cQry += " SC5.C5_OBS					 AS OBS_PEDIDO "

	cQry += " FROM %SC5.SQLNAME%  "

	cQry += " INNER JOIN %SA1.SQLNAME% ON "
	cQry += " %SA1.XFILIAL% " 
	cQry += " AND SC5.C5_CLIENT 	= SA1.A1_COD "
	cQry += " AND SC5.C5_LOJACLI 	= SA1.A1_LOJA "
	cQry += " AND SC5.D_E_L_E_T_ 	= SA1.D_E_L_E_T_ "

	cQry += " INNER JOIN " + RETSQLNAME("SA3") + " REPRE " 
	cQry += " ON ''					= REPRE.A3_FILIAL "
	cQry += " AND SC5.C5_VEND1		= REPRE.A3_COD "
	cQry += " AND SC5.D_E_L_E_T_	= REPRE.D_E_L_E_T_ " 

	cQry += " INNER JOIN " + RETSQLNAME("SA3") + " ATEND "
	cQry += "  ON  ''				=  ATEND.A3_FILIAL "
	cQry += " AND REPRE.A3_SUPER	= ATEND.A3_COD "
	cQry += " AND REPRE.D_E_L_E_T_	= ATEND.D_E_L_E_T_ "

	cQry += " WHERE "
	cQry += " SC5.C5_FILIAL IN ('01', '02', '03') "
	cQry += " AND SC5.C5_DOCPORT <> '' "
	cQry += " AND SC5.C5_DATALIB = '' "
	cQry += " AND %SC5.NOTDEL% "
	cQry += " ORDER BY ATEND.A3_NOME, SC5.C5_FILIAL, DATEDIFF(DAY,SC5.C5_EMISSAO, GETDATE() ) DESC "

return(cQry)

/*/{Protheus.doc} getQuotList
@author bolognesi
@since 23/05/2017
@version undefined
@param oQuotSrv, object, Estancia da classe CbcQuotationService
@type function
@description Obtem uma lista de objetos oQuotation, com o status
QUOTATION_STATUS_WAITING_PROCESSING, neste momento já mudando o status
para em processamento.
/*/
static function getQuot(oSql, cNumOrc)
	local cQry 			:= ""
	local cQuotationId	:= ""
	default oSql 		:= LibSqlObj():newLibSqlObj()
	default cNumOrc		:= ''

	cQry += " SELECT TOP 1" 
	cQry += " ZP5.ZP5_NUM AS QUOT_ID "
	cQry += " FROM %ZP5.SQLNAME%  "
	cQry += " WHERE "
	cQry += " ZP5.ZP5_FILIAL IN ('01', '02', ' ') "
	if !empty(cNumOrc)
		cQry += " AND ZP5.ZP5_NUM = '" + cNumOrc + "' "
	endif
	cQry += " AND ZP5.ZP5_STATUS IN ( '" + QUOTATION_STATUS_WAITING_PROCESSING + "' ) "
	cQry += " AND %ZP5.NOTDEL% "
	cQry += " ORDER BY ZP5.ZP5_NUM "

	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			cQuotationId := oSql:getValue("QUOT_ID")
			oSql:skip()
		enddo
	endif
	oSql:close()
return(cQuotationId)

/*/{Protheus.doc} schPedPor
@author bolognesi
@since 28/03/2017
@version 1.0
@param lSch, logical, Indica se a execução e manual o pelo schedule default schedule( .T. )
@type function
@description Função principal que inicia o processo de aviso dos pedidos do portal que ainda
não fora, liberados venda (BV)
/*/
user function schPedPor()

	RPCClearEnv()
	RPCSetType(3)
	RPCSetEnv('01','01',,,'FAT',GetEnvServer(),{} )

	showConsoleMsg("Iniciando o schedule para envio dos pedidos portal, não liberados vendas")
	oSch := cbcOrderManager():newcbcOrderManager()
	oSch:sendWarn()
	showConsoleMsg("Finalizado o schedule para envio dos pedidos portal, não liberados vendas")

	RPCClearEnv()

return

/*/{Protheus.doc} budtoOrd
@author bolognesi
@since 23/05/2017
@version 1.0
@type function
@description Função para processar os orçamentos do portal, transformando-os
em pedido, utilizado pelo agendamento schedule
/*/
user function budtoOrd() //U_budtoOrd()
	local aInfo		:= {}
	local nX		:= 0
	local nQtdJob	:= 0
	local cTempo	:= ''
	local nLimit 	:= 4

	RPCClearEnv()
	RPCSetType(3)
	RPCSetEnv('01','01',,,'FAT',GetEnvServer(),{} )

	FWMonitorMsg("[INICIO][SCH - U_budtoOrd ]")
	nLimit 	:= GetNewPar('XX_LIMIPOR', 4)

	//TODO Como pega o conteudo do monitor coloca variavel
	//seria como pegar uma foto do monitor
	//Apos a foto, o monitor sofre atualizações.
	//existe gap pode colocar uma thread a mais na fila.
	aInfo := GetUserInfoArray()
	for nX := 1 to len(aInfo)
		if '[PORTAL]' $ aInfo[nX][11]
			nQtdJob++
		endif
	next nX

	if nQtdJob > nLimit
		showConsoleMsg('Nenhuma thread disponivel, verificar!')
	else
		oOrderMngr	 := cbcOrderManager():newcbcOrderManager()
		oOrderMngr:initProcToOrder()
		FreeObj(oOrderMngr)
	endif
	RPCClearEnv()
return (nil)

/*/{Protheus.doc} manBtoOr
@author bolognesi
@since 29/05/2017
@version 1.0
@param cNumOrc, characters, Numero do orçamento no portal
que deve ser processado para virar pedido.
@type function
@description Função que realiza o processamento manual de 
um orçamento do portal con statius de aguardando
processamento transformando-o em um pedido.
/*/
user function manBtoOr(cNumOrc) //U_manBtoOr('001390')
	default cNumOrc := ''
	if !empty(cNumOrc)
		oOrderMngr	 := cbcOrderManager():newcbcOrderManager()
		oOrderMngr:initProcToOrder(cNumOrc)
		FreeObj(oOrderMngr)
	endif
return(nil)

/*/{Protheus.doc} callInJo
@author bolognesi
@since 25/05/2017
@version 1.0
@type function
@description Função que inicia o processo de transformação de orçamentos em pedidos
chamada pelo schedule, ou manualmente.
/*/
user function callInJo() //U_callInJo()
	local nX		:= 0

	RPCClearEnv()
	RPCSetType(3)
	RPCSetEnv('01','01',,,'FAT',GetEnvServer(),{} )

	for nX := 1 to GetNewPar('XX_THRNPOR', 2)
		sleep(3000)
		startJob('U_budtoOrd', getenvserver(), .F. )
	next nX

	RPCClearEnv()
return (nil)

/*/{Protheus.doc} showConsoleMsg
@author bolognesi
@since 28/03/2017
@version 1.0
@param cMsg, characters, descricao
@type function
@description Função para padronizar os logs que esta classe
precisa realizar no arquivo de log
/*/
static function showConsoleMsg(cMsg)
	ConOut("[schExpRes - "+DtoC(Date())+" - "+Time()+" ] "+cMsg)
return

/*/{Protheus.doc} countItem
@author bolognesi
@since 26/05/2017
@version 1.0
@param oQuot, object, Objeto oQuotation
@type function
@description Função para contar os itens de um objeto quotation
a contagem é realizada no nivel da cor, sendo o resultado a quantidade
de itens do Protheus(SC5/SC6) e não do Portal(ZP5/ZP6/ZP9)
/*/
static function countItem(oQuot)
	local nQtd 		:= 0
	local aItens	:= {}
	local nX		:= 0

	aItens := oQuot:getItems()
	for nX := 1 To Len(aItens)
		nQtd += Len(aItens[nX]:getColors())
	next nX

return(nQtd)

/*/{Protheus.doc} vldPedPor
@author bolognesi
@since 18/05/2017
@version 1.0
@type function
@description Realizar o mesmo processo do schedule ou manual
/*/
user function vldPedPor()
	oSch := cbcOrderManager():newcbcOrderManager()
	oSch:sendWarn()
	FreeObj(oSch)
return nil

/*/{Protheus.doc} simSched
@author bolognesi
@since 26/05/2017
@version 1.0
@type function
@description testar a chamada manual da mesma forma de do schedule.
/*/
user function simSched() //u_simSched()
	while !killapp()
		if MsgYesNo('Simula inicio do schedule???')
			U_callInJo()
		endif
		sleep(240000) //4 em 4 minutos
	enddo
return(nil)
