#include 'protheus.ch'
#include "portalcobrecom.ch"

#define WARNING 1
#define KILL 2


/*/{Protheus.doc} cbcCheckOrder
@author bolognesi
@since 26/10/2017
@version 1.0
@type class
@description 
Considerando como data de entrada no status a maior data ZPE
Confrontando com a data atual, obtemos quantos dias um orçamento esta no status de aguardando.
Classificar estes dias aguardando em Oçamento que deve avisar e Orçamento que deve cancelar
sendo:
Avisar 	= Dias Status < dias para cancelar  e Dias Status >= dias para avisar
Cancelar = Dias Status >= dias para cancelar 
Considerando que dias para cancelar e dias para avisar são parametros. 
/*/
class cbcCheckOrder

	data aOrcResult

	method newcbcCheckOrder() constructor
	method getWarningCancel()
	method searchDestroy()
	method kill()

endclass


/*/{Protheus.doc} newcbcCheckOrder
@author bolognesi
@since 26/10/2017
@version 1.0
@type method
@description Construtor da classe, que verifica coerencia dos parametros utilizados
pela classe.
/*/
method newcbcCheckOrder() class cbcCheckOrder
return (self)


/*/{Protheus.doc} getWarningCancel
@author bolognesi
@since 26/10/2017
@version 1.0
@param cUserId, characters, descricao
@type method
@description Metodo para obter array de Ids dos orçamentos filtrando
os que estão em situação de aviso. (Dias Status < dias para cancelar  e Dias Status >= dias para avisar)
/*/
method getWarningCancel(cUserId) class cbcCheckOrder
	default cUserId := ''
	OrderWaiting(cUserId, self, WARNING)
return ( self:aOrcResult )


/*/{Protheus.doc} searchDestroy
@author bolognesi
@since 26/10/2017
@version 1.0
@param cUserId, characters, descricao
@type method
@description Metodo para obter array de Ids dos orçamentos filtrando
os que estão em situação de aviso. (Dias Status >= dias para cancelar )
/*/
method searchDestroy(cUserId) class cbcCheckOrder
	default cUserId := ''
	OrderWaiting(cUserId, self, KILL)
return (self)


/*/{Protheus.doc} kill
@author bolognesi
@since 26/10/2017
@version 1.0
@type method
@description Busca no metodo ::searchDestroy() os Ids que devem ser cancelados
enviandos esses Ids para função que de fato realiza o cancelamento
/*/
method kill() class cbcCheckOrder
	local aKill := {}
	if !empty(aKill := ::searchDestroy())
		killer(aKill)
	endif
return(self)


/*/{Protheus.doc} OrderWaiting
@author bolognesi
@since 01/11/2017
@version 1.0
@param cUserId, characters, descricao
@param oSelf, object, descricao
@param cWho, characters, descricao
@type function
@description Obtem um array com Ids  dos orçamentos
aguardando confirmação do vendedor, de acordo com criterio
AVISAR/CANCELAR) 
/*/
static function OrderWaiting(cUserId, oSelf, cWho)
	
	local cQuery  		:= ''
	local oUtils			:= LibUtilsObj():newLibUtilsObj()
	local oSql	  		:= LibSqlObj():newLibSqlObj()
	local oSrvUser		:= CbcUserService():newCbcUserService()
	local oUser	 		:= oSrvUser:findById(cUserId)
	local cIdDoc			:= ''
	local dHoje			:= DtoS(DataValida(Date(), .T.))

	oSelf:aOrcResult	:= {}
	
	if cWho == WARNING
		dHoje := DtoS(DataValida(Date(), .T.))
	elseif cWho == KILL
		dHoje := DtoS(Date())
	endif
	
	cQuery := " SELECT "
	cQuery += " ZP5.ZP5_NUM [ID],"
	cQuery += " ZP5.ZP5_DATA
	cQuery += " FROM %ZP5.SQLNAME% "

	If (oUtils:isNotNull(oUser) .and. oUser:isSeller())
		cQuery += " 	INNER JOIN %SA1.SQLNAME% ON "
		cQuery += " 		%SA1.XFILIAL% AND A1_COD = ZP5.ZP5_CLIENT AND A1_LOJA = ZP5.ZP5_LOJA AND %SA1.NOTDEL% "
	endIf

	cQuery += " WHERE %ZP5.XFILIAL% "
			
	cQuery += getFilterStatus('SQL')
	
	cQuery += " AND ZP5.ZP5_DTVAL <> '' "

	if cWho == WARNING
		cQuery += " AND   ('" + dHoje + "' = CONVERT(VARCHAR(11),DATEADD(day, -1, ZP5_DTVAL),112)) "
	elseif cWho == KILL
		cQuery += " AND   ('" + dHoje + "' > ZP5.ZP5_DTVAL) "
	endif

	if (oUtils:isNotNull(oUser) .and. oUser:isCustomer())
		cQuery += " AND ZP5_CLIENT = '"+oUser:getCustomer():getCode()+"' AND ZP5_LOJA = '"+oUser:getCustomer():getUnit()+"' "

	elseIf (oUtils:isNotNull(oUser) .and. oUser:isSeller())
		cQuery += " AND (ZP5_RESPON = '"+oUser:getId()+"' OR A1_VEND = '"+oUser:getSeller():getId()+"') "
	endIf

	cQuery += " AND %ZP5.NOTDEL% "
	cQuery += " ORDER BY ZP5_DATA, ZP5_NUM "

	oSql:newAlias(cQuery)

	while oSql:notIsEof()
		cIdDoc 	:= oSql:getValue("ID")
		aAdd(oSelf:aOrcResult,cIdDoc)
		oSql:skip()
	endDo

	oSql:close()

	FreeObj(oSql)
	FreeObj(oSrvUser)
	FreeObj(oUtils)
return(oSelf)


/*/{Protheus.doc} killer
@author bolognesi
@since 26/10/2017
@version 1.0
@param aKill, array, descricao
@type function
@description Realiza de fato o cancelamento dos orçamento
que estão em condição de cancelamento, utilizando a classe/metodo
cbcQuotationService:Cancel()
/*/
static function killer(aKill, cDesc)
	local nX			:= 0
	local oQuotSrv	:= nil
	local cIdCancel	:= ' '
	local cStatus		:= ''
	local cCancDesc	:= ''
	default aKill		:= {}
	default cDesc		:= ''

	oQuotSrv := CbcQuotationService():newCbcQuotationService()
	for nX := 1 to len(aKill:aOrcResult)
		
		if empty(cDesc)
			cCancDesc := getFilterStatus('DESCRICAO', aKill:aOrcResult[nX])
		else
			cCancDesc := cDesc
		endif
		oQuotSrv:cancel('000001', aKill:aOrcResult[nX], '09', cCancDesc )
	next nX

	freeObj(oQuotSrv)

return(nil)


/*/{Protheus.doc} getFilterStatus
(long_description)
@type function
@author bolognesi
@since 07/02/2018
@version 1.0
@param cRet, string, tipo do retorno desejado (DESCRICAO ou SQL)
@description Centraliza as definições de status para filtro.
retorna a query utilizada no sql e tambem a descrição do status
para o cancelamento
/*/
static function getFilterStatus(cRet, cId)
	local xRet		:= ''
	local oSql		:= nil
	local cStatus		:= ''
	default cRet 		:= ''
	default cId		:= ''

	if ! empty(cRet)
		
		if cRet == 'SQL'
			xRet += " AND ZP5.ZP5_STATUS IN "
			xRet += "( "
			xRet += "'" + QUOTATION_STATUS_WAITING_CONFIRM + "' "
			xRet += ", "
			xRet += "'" + QUOTATION_STATUS_NOT_APPROVED + "' "
			xRet += ", "
			xRet += "'" + QUOTATION_STATUS_TECNICAL_REJECT + "' "
			xRet += ") "
		
		elseIf cRet == 'DESCRICAO'
			oSql	  	:= LibSqlObj():newLibSqlObj()
			cStatus := oSql:getFieldValue("ZP5", "ZP5_STATUS",;
				"%ZP5.XFILIAL% AND ZP5_NUM ='" + cId + "'")
	
			if Alltrim(cStatus) == QUOTATION_STATUS_WAITING_CONFIRM
				xRet := 'AGUARDANDO CONFIRMAÇÂO '
			elseIf Alltrim(cStatus) == QUOTATION_STATUS_NOT_APPROVED
				xRet :=  'NÃO APROVADO '
			elseIf Alltrim(cStatus) == QUOTATION_STATUS_TECNICAL_REJECT
				xRet :=  'REJEIÇÃO TÉCNICA '
			endif
			
			xRet := ( xRet + 'COM PRAZO VENCIDO ' )
			
			freeObj(oSql)
		endif

	endif
return(xRet)


/*/{Protheus.doc} showConsoleMsg
@author bolognesi
@since 26/10/2017
@version 1.0
@param cMsg, characters, descricao
@type function
@description Mostrar mensagens no console 
/*/
static function showConsoleMsg(cMsg)
	ConOut("[cbcCheckOrder - "+DtoC(Date())+" - "+Time()+" ] "+cMsg)
return


/*/{Protheus.doc} schChkOr
@author bolognesi
@since 26/10/2017
@version 1.0
@type function
@description Função que deve ser executada pelo schedule, para realizar
o cancelamento dos orçamentos em condição de cancelamento
/*/
user function schChkOr() // U_schChkOr()
	RPCClearEnv()
	RPCSetType(3)
	RPCSetEnv('01','01',,,'FAT',GetEnvServer(),{} )

	showConsoleMsg("Iniciando o schedule para cancelar orçamentos com status aguardando confirmação")
	oCkecker 	:= cbcCheckOrder():newcbcCheckOrder()
	oCkecker:kill()
	FreeObj(oCkecker)
	showConsoleMsg("Finalizado o schedule para cancelar orçamentos com status aguardando confirmação")

	RPCClearEnv()
return


/** TEST ZONE **/
user function  CheckOrder() // u_CheckOrder()
	local oCkecker 	:= cbcCheckOrder():newcbcCheckOrder()
	local aAviso		:= {}
	local aCancela	:= {}
	local aTodos		:= {}

	aAviso 		:= oCkecker:getWarningCancel()
	aCancela 	:= oCkecker:searchDestroy():aOrcResult
	
	oCkecker:kill()
	Alert('Terminou')

	FreeObj(oCkecker)
return(nil)
