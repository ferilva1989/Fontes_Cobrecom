#include 'protheus.ch'
#Include 'FWMVCDef.ch'


/*/{Protheus.doc} cbcLabelSrv
Classe para que seja relizadas Inserção/alteração/deleção da tabela ZZ2
@author    juliana.leme
@since     12/12/2018
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
class cbcLabelSrv 
	data lOk
	data cMsgErr
	data oRec
	data dDataBk
	data aArea
	data aZZ2
	data cOperation
	
	method newcbcLabelSrv() constructor 
	
	method setStatus()
	method isOk()
	method getMsgErr()
	method GrvZZ2()
	method ConsZZ2()
	method ConsSC6()

endclass

/*/{Protheus.doc} new
Metodo construtor
@author    juliana.leme
@since     12/12/2018
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
method newcbcLabelSrv() class cbcLabelSrv
	::setStatus(.T., '')
	::isOk()
	::getMsgErr()
return

/*/{Protheus.doc} setStatus
@type method
@author bolognesi
@since 23/05/2018
@description Define status da execução,'MVC_MODEL_ID'ID propriedades
lOk e cMsgErr para guardar o status e respectiva mensagem de erro
bem como criar exeptions para tratamento de erro personalizado.
/*/
method setStatus(lSts, cMsg, lEx) class cbcLabelSrv
	default lSts := .T.
	default cMsg	:= ''
	default lEx	:= .T.
	::lOk		:= lSts
	::cMsgErr 	:= cMsg
	
	if !lSts .and. lEx
		UserException(cMsg)
	endif
return(Self)


/*/{Protheus.doc} isOk
@type method
@author bolognesi
@since 23/05/2018
@description  Retorna a propriedade lOk, armazena
o status da execução.
TAG: SetStatus, ok
/*/
method isOk() class cbcLabelSrv
return(::lOk)

/*/{Protheus.doc} getMsgErr
@type method
@author bolognesi
@since 23/05/2018
@description  Retorna a propriedade cMsgErr, armazena
descrição sobre o status da execução.
TAG: SetStatus, Erro
/*/
method getMsgErr() class cbcLabelSrv
return(::cMsgErr)


/*/{Protheus.doc} ModelDef
//TODO Retorna a model da tabela ZZ2.
@author juliana.leme
@since 13/12/2018
@version 1.0
@type function
/*/
static function ModelDef()
return FWLoadModel('CbcZZ2Model')


/*/{Protheus.doc} ViewDef
//TODO Retorna a View da tabela ZZ2.
@author juliana.leme
@since 13/12/2018
@version 1.0
@type function
/*/
static function ViewDef()
return FWLoadView( 'CbcZZ2Model' )


/*/{Protheus.doc} ConfZZ2
//TODO Confirme a operação da inserção/alteração da tabela ZZ2.
@author juliana.leme
@since 13/12/2018
@version 1.0
@param aZ2, array, descricao
@type function
/*/
method GrvZZ2(aZZ2, cOperation) class cbcLabelSrv
	local oZZ2Model 	:= ModelDef()
	local cIDModel		:= 'ZZ2MASTER'
	local aArea			:= GetArea()
	local lRet			:= .F.
	local aErro			:= {}
	local bErro			:= nil
	local nCont 		:= 1
	
	DbSelectArea('ZZ2')
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, Self)})
	If Len(aZZ2) > 0
		BEGIN SEQUENCE
			::setStatus(.T., '')
			BEGIN TRANSACTION
				For nCont := 1 to Len(aZZ2)
					
					oZZ2Model:SetOperation(IIf(cOperation=="I",MODEL_OPERATION_INSERT,MODEL_OPERATION_UPDATE))
					oZZ2Model:Activate()
					
					oZZ2Model:LoadValue(cIDModel, 'ZZ2_FILIAL'	, 	aZZ2[1][1][2])
					oZZ2Model:LoadValue(cIDModel, 'ZZ2_TIPO'		,	aZZ2[1][2][2])
					oZZ2Model:LoadValue(cIDModel, 'ZZ2_RECDOC'	,	aZZ2[1][3][2])
					oZZ2Model:LoadValue(cIDModel, 'ZZ2_NOME'		,	aZZ2[1][4][2])
					oZZ2Model:LoadValue(cIDModel, 'ZZ2_LAYOUT'	,	aZZ2[1][5][2])
					
					if ! (lRet := oZZ2Model:VldData())
						aErro := oZZ2Model:GetErrorMessage()
						Self:setStatus(.F.,aErro[6])
					else
						FWFormCommit(oZZ2Model)
						oZZ2Model:DeActivate()
					endIf
				Next
			END TRANSACTION
			RECOVER
		END SEQUENCE
	EndIf
	ErrorBlock(bErro)
	RestArea(aArea)
return(lRet)

/*/{Protheus.doc} ConsZZ2
//TODOConforme parametros passado retorna o leiaute encontrado na tabela ZZ2.
@author juliana.leme
@since 07/01/2019
@version 1.0
@param nRecPed, numeric, descricao
@param cCliLoja, characters, descricao
@type function
/*/
method ConsZZ2(nRecPed, cCliLoja) class cbcLabelSrv
	local oSql		:= nil
	local cQuery	:= "", cJsonLay := ""
	
	//Consulta Etiqueta no pedido
	cQuery := " SELECT ZZ2.R_E_C_N_O_ RECNO "
	cQuery += " FROM %ZZ2.SQLNAME% "
	cQuery += " 		LEFT JOIN %SA1.SQLNAME% "
	cQuery += " 			ON SA1.A1_RECZZ2 = ZZ2.R_E_C_N_O_ " 
	cQuery += " 				AND SA1.A1_COD+SA1.A1_LOJA = '" + cCliLoja + "'"
	cQuery += " 				AND %SA1.NOTDEL%"
	cQuery += " WHERE %ZZ2.XFILIAL% "
	cQuery += " 	AND ((ZZ2_RECDOC = "+ Str(nRecPed) +")
	cQuery += " 		OR (ZZ2.R_E_C_N_O_ = SA1.A1_RECZZ2
	cQuery += " 		AND ZZ2_NOME <> ''))
	cQuery += " 	AND %ZZ2.NOTDEL%"
	cQuery += " ORDER BY ZZ2.ZZ2_FILIAL, ZZ2.ZZ2_NOME "
	
	oSql := LibSqlObj():newLibSqlObj()	
	oSql:newAlias( cQuery )

	if oSql:hasRecords()
		oSql:goTop()
		nRecn := oSql:getValue("RECNO")
		DbSelectArea("ZZ2")
		ZZ2->(DbGoTo(nRecn))
		cJsonLay := ZZ2->ZZ2_LAYOUT
		::setStatus( .T. , cJsonLay, .F. )
	else
		::setStatus( .F. , '', .F. )
	endif
	
	oSql:close() 
	FreeObj(oSql)
return(cJsonLay)

/*/{Protheus.doc} ConsSC6
//TODO Conforme pedido passado por parametro retorna se o pedido em questão 
possui bobinas nos itens para criação de leiaute.
@author juliana.leme
@since 07/01/2019
@version 1.0
@param nNumPed, numeric, descricao
@type function
/*/
method ConsSC6(nNumPed) class cbcLabelSrv
	local oSql		:= nil
	local cQuery	:= "", cJsonLay := ""
	
	//Consulta Etiqueta no pedido
	cQuery := " SELECT COUNT (SC6.C6_ACONDIC) QTDEBOB "
	cQuery += " FROM %SC6.SQLNAME% "
	cQuery += " WHERE %SC6.XFILIAL% "
	cQuery += " 	AND SC6.C6_NUM = '" + Alltrim(nNumPed) + "' "
	cQuery += " 	AND SC6.C6_ACONDIC = 'B' "
	cQuery += " 	AND %SC6.NOTDEL%"
	
	oSql := LibSqlObj():newLibSqlObj()	
	oSql:newAlias( cQuery )
	
	if oSql:hasRecords()
		oSql:goTop()
		If oSql:getValue("QTDEBOB") > 0
			lRet := .T.
		else
			lRet := .F.
		endif
	endif
	oSql:close() 
	FreeObj(oSql)
return(lRet)

/*/{Protheus.doc} HandleEr
//TODO Trata Erro da classe.
@author juliana.leme
@since 13/12/2018
@version 1.0
@param oErr, object, descricao
@param oSelf, object, descricao
@type function
/*/
static function HandleEr(oErr, oSelf)
	local lCompl	:= .F.
	
	if InTransact()
		DisarmTransaction()
	endif
	RestArea(oSelf:aArea)
	lCompl := ( Alltrim(oErr:Description) != Alltrim(oSelf:cMsgErr) )
	oSelf:oRec:libLock()
	dDatabase		:= Self:dDataBk
	oSelf:lOk			:= .F.
	
	oSelf:cMsgErr		:= "[cbcLabelSrv - "+DtoC(Date())+" - "+Time()+" ]"+;
		oErr:Description +;
		if ( FwIsAdmin() ,' [ORIGEM]' + ProcName(3), '')+;
		if(lCompl, '  ' + oSelf:cMsgErr, '')
	BREAK
return(nil)	
