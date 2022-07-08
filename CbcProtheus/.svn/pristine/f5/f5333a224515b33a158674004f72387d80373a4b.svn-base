#include "totvs.ch"
#include "rwmake.ch"
#include "fwmvcdef.ch"
#include "portalcobrecom.ch"

#define MVC_MAIN_ID       "cbcOrcCancel"
#define MVC_TITLE         "Cancelamento em lote Orçamentos Portal"
#define SCREEN_FILTER		1
#define SQL_FILTER		2


/*/{Protheus.doc} cbcOrcCancel
(long_description)
@type function
@author bolognesi
@since 23/02/2018
@version 1.0
@description Browser de marcação que utiliza os mesmos model e view da rotina
principal de orçamentos no portal. Utilizada para realizar o cancelamento 
dos orçamentos
/*/
user function cbcOrcCancel(lMarkAll)
	local oAcl			:= cbcAcl():newcbcAcl()
	local oService     	:= CbcQuotationService():newCbcQuotationService()
	Local oStatic    	:= IfcXFun():newIfcXFun()
	private bCancel		:= {|| procCancel()}
	private oMarkBrowse 	:=  nil
	
	default lMarkAll		:= .F.
	
	if !oAcl:aclValid('CadOrcPort')
		MsgAlert( oAcl:getAlert(), 'Acesso' )
	else
		oMarkBrowse	:= FWMarkBrowse():New()
		oMarkBrowse:SetAlias("ZP5")
		oMarkBrowse:SetDescription(MVC_TITLE)
		oStatic:sP(1):callStatic('CadOrcPort','addBrowseLegends',@oMarkBrowse)
		oMarkBrowse:SetFieldMark('ZP5_MARK')
		oMarkBrowse:SetMenuDef('cbcOrcCancel')
		oMarkBrowse:SetFilterDefault(getConfFilter(SCREEN_FILTER))
		oMarkBrowse:SetOnlyFields({'ZP5_STATUS','ZP5_NUM', 'ZP5_DATA', 'ZP5_DTVAL', 'ZP5_NOMCLI'})
		oMarkBrowse:SetSemaphore(.F.)
		oMarkBrowse:SetAllMark({|| MsAguarde({|lFim| vldMark(@lFim)},"Selecionando","Aguarde...")})
		if lMarkAll
			oMarkBrowse:AllMark()
		endif
		oMarkBrowse:Activate()
	endif
	
	FreeObj(oAcl)
	FreeObj(oMarkBrowse)
	FreeObj(oService)
return


/*/{Protheus.doc} menuDef
(long_description)
@type function
@author bolognesi
@since 23/02/2018
@version 1.0
@description Opções de menu disponiveis
/*/
static function menuDef()
	local aOpcoes      := {}
	local cCancel	   := "Eval(bCancel)"
   
	ADD OPTION aOpcoes TITLE "Pesquisar" ACTION "PesqBrw" OPERATION 1 ACCESS 0
	ADD OPTION aOpcoes TITLE "Proc.Cancelamento" ACTION cCancel OPERATION 2 ACCESS 0
return aOpcoes


/*/{Protheus.doc} modelDef
(long_description)
@type function
@author bolognesi
@since 23/02/2018
@version 1.0
@desription Definições relacionadas ao modelo de dados
/*/
static function modelDef()
return  ( FWLoadModel('CadOrcPort'))


/*/{Protheus.doc} viewDef
(long_description)
@type function
@author bolognesi
@since 23/02/2018
@description Definições para Tela
/*/
static function viewDef()
return ( FWLoadView( 'CadOrcPort' ) )


/*/{Protheus.doc} vldMark
@type function
@author bolognesi
@since 23/02/2018
@version 1.0
@description Função que realiza a inversão da marca
/*/
static function vldMark()
	oMarkBrowse:SetInvert(.F.)
	oMarkBrowse:AllMark()
return(nil)


/*/{Protheus.doc} procCancel
@type function
@author bolognesi
@since 23/02/2018
@version 1.0
@description Função para executar cancelBudget(), em uma barra de progresso
/*/
static function procCancel()
	Processa({|| cancelBudget() }, "Aguarde...", "Processando...",.F.)
return(nil)


/*/{Protheus.doc} cancelBudget
@type function
@author bolognesi
@since 23/02/2018
@version 1.0
@description Função que verifica os registros marcados no browse
e os submete para cancelamento na função doCancel()
/*/
static function cancelBudget(oProcess)
	local cMark 		:= oMarkBrowse:Mark()
	local aArea		:= ZP5->(GetArea())
	local bErro		:= nil
	local aRetQuot	:= {}
	local cFiltro		:= ''
	
	if MsgYesNo('[AVISO]- Orçamentos em manutenção serão excluidos de forma definitiva!,','CONTINUAR?')  
		cFiltro := getConfFilter(SCREEN_FILTER)
		SET FILTER TO &cFiltro
		ZP5->(DBGoTop())
		ProcRegua(RecCount())
		oMarkBrowse:SaveArea()
		While ! ZP5->(Eof())
			if oMarkBrowse:IsMark(cMark) .And. &cFiltro	
				incProc('Orçamento: ' + ZP5->(ZP5_NUM) )
				bErro	:= ErrorBlock({|oErr| HandleEr(oErr,ZP5->(ZP5_NUM))})
				BEGIN SEQUENCE
					if ! ( aRetQuot := doCancel(ZP5->(ZP5_RESPON), ZP5->(ZP5_NUM)))[1]
						MsgAlert( aRetQuot[2], 'Erro Orçamento: ' + Alltrim(ZP5->(ZP5_NUM)) )
					else
						oMarkBrowse:MarkRec()
					endif
				RECOVER
				END SEQUENCE
				ErrorBlock(bErro)
			endif
			ZP5->(DbSkip())
		endDo
	
		MsgInfo( 'Finalizado ', 'OK' )
	endif
	
	oMarkBrowse:RestoreArea()
	RestArea(aArea)
	
return(nil)


/*/{Protheus.doc} doCancel
(long_description)
@type function
@author bolognesi
@since 26/02/2018
@version 1.0
@param cRespon, character, Usuario responsavel
@param cId, character, Numero do Orçamento
@description Função que realiza o cancelamento, verificando o status
de manutenção pois neste status devemos finalizar manutenção e depois cancelar
utiliza a classe CbcQuotationService() do portal
/*/
static function doCancel(cRespon, cId)
	
	local cDescr		:= 'Cancelado por: ' + UsrRetName(retcodusr()) + ' data: ' + DtoC(Date())
	local oQuotSrv	:= nil
	local lRet		:= .T.
	local cMsg		:= ''
	
	oQuotSrv := CbcQuotationService():newCbcQuotationService()
	
	if ZP5->(ZP5_STATUS) == QUOTATION_STATUS_UNDER_MAINTENANCE
		lRet := oQuotSrv:delete(ZP5->(ZP5_RESPON), ZP5->(ZP5_NUM))
	else
		lRet := oQuotSrv:cancel(ZP5->(ZP5_RESPON) , ZP5->(ZP5_NUM), '09', cDescr )
	endif
	
	if !lRet
		cMsg := oQuotSrv:cErrorMessage
	endif
	
	freeObj(oQuotSrv)
return({lRet,cMsg})


/*/{Protheus.doc} getConfFilter
@type function
@author bolognesi
@since 23/02/2018
@version 1.0
@param nTipo, numérico, Tipo de formatação de retorno (1=Filtro Tela, 2=Filtro SQL)
@description Função para centralizar os filtros utilizados neste fonte
/*/
static function getConfFilter(nTipo)
	local xFiltro 	:= ''
	default  nTipo	:= SCREEN_FILTER
	if nTipo == SCREEN_FILTER
		xFiltro += "ZP5_STATUS == '" + QUOTATION_STATUS_UNDER_MAINTENANCE 	+ "' .OR. "
		xFiltro += "ZP5_STATUS == '" + QUOTATION_STATUS_WAITING_CONFIRM 	+ "' .OR. "
		xFiltro += "ZP5_STATUS == '" + QUOTATION_STATUS_ERROR_PROCESSING 	+ "' .OR. "
		xFiltro += "ZP5_STATUS == '" + QUOTATION_STATUS_WAITING_PROCESSING 	+ "' .OR. "
		xFiltro += "ZP5_STATUS == '" + QUOTATION_STATUS_TECNICAL_REJECT 	+ "' .OR. "
		xFiltro += "ZP5_STATUS == '" + QUOTATION_STATUS_NOT_APPROVED + "'"
	elseIf nTipo == SQL_FILTER
		xFiltro += "( "
		xFiltro += "'" + QUOTATION_STATUS_UNDER_MAINTENANCE 	+ "' "
		xFiltro += ", "
		xFiltro += "'" + QUOTATION_STATUS_WAITING_CONFIRM 	+ "' "
		xFiltro += ", "
		xFiltro += "'" + QUOTATION_STATUS_ERROR_PROCESSING 	+ "' "
		xFiltro += ", "
		xFiltro += "'" + QUOTATION_STATUS_WAITING_PROCESSING 	+ "' "
		xFiltro += ", "
		xFiltro += "'" + QUOTATION_STATUS_NOT_APPROVED 		+ "' "
		xFiltro += ", "
		xFiltro += "'" + QUOTATION_STATUS_TECNICAL_REJECT 		+ "' "
		xFiltro += ") "
	endif
return(xFiltro)


/*/{Protheus.doc} HandleEr
(long_description)
@type function
@author bolognesi
@since 23/02/2018
@version 1.0
@param oErr, objeto, (Descrição do parâmetro)
@param cNum, character, (Descrição do parâmetro)
@description Função para tratamento de erros
/*/
Static function HandleEr(oErr, cNum )
	MsgAlert( oErr:Description, 'Erro Orçamento: ' + Alltrim(cNum) )
	BREAK
return


/*/{Protheus.doc} zVlTrTab
@type function
@author bolognesi
@since 23/02/2018
@version 1.0
@param lCusto, logico, Define se a alteração de tabela é para preço de custo neste caso não validar
@description Função que verifica a existencia de orçamentos ZP5, filtrando os status 
definidos na função getConfFilter(), e caso encontre, oferece a tela (cbcOrcCancel) de 
que possibilita a exclusão dos registros, somente retorna .T. caso não encontre mais
registros na ZP5. (Uso futuro)
/*/
user function zVlTrTab(lCusto)
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local cQry		:= ''
	local lShow		:= .F.
	private lAlert	:= .T.
	default  lCusto	:= .F.
	
	if  lCusto
		lShow := .T.
	else
		cQry += " SELECT TOP 1  "
		cQry += " ZP5_NUM AS NUMERO  "
		cQry += " FROM %ZP5.SQLNAME%  "
		cQry += " WHERE  "
		cQry += " %ZP5.XFILIAL% "
		cQry += " AND ZP5.ZP5_STATUS IN "
		cQry += getConfFilter(SQL_FILTER)
		cQry += " AND %ZP5.NOTDEL% "
	
		oSql:newAlias(cQry)
		lShow := oSql:hasRecords()
		oSql:close()
		FreeObj(oSql)

		if lShow
			if MsgYesNo('Existem orçamentos que devem ser analisados/cancelados antes de realizarmos atualizações nas tabelas de preço.','CONTINUAR?')
				U_cbcOrcCancel(.T.)
				if  ProcName(3) == upper('U_zVlTrTab')
					if lAlert
						MsgAlert('Fechando a rotina', 'AVISO')
						lAlert := .F.
					endif
					lShow := .F.
				else
					lShow := U_zVlTrTab()
				endif
			
			else
				lShow := .F.
			endif
		endif
	endif
return(lShow)

