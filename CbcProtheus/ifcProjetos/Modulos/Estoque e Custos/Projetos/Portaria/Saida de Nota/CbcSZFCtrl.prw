#include 'protheus.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} CbcSZFCtrl
(Classe para realizar controle da inclusão dos registros recebidos. Herança de Model.)
@author    juliana.leme
@since     21/09/2018
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
class CbcSZFCtrl 
	data lOk
	data cMsgErr
	data cOper
	data oHashMrk
	data oSeqCtrl
	data oRec
	data dDataBk
	data aArea
	data cNomUsr
	data nRecnoF2
	data aZF
	data aF2
	data cFiliAtu

	method newCbcSZFCtrl() constructor 
	
	method setFiliAtu()
	method setStatus()
	method isOk()
	method getMsgErr()
	method ConfSZF()
	method validSF2()
	method SetRecnoF2()
	method AtualizSF2()
endclass

/*/{Protheus.doc} new
Metodo construtor
@author    juliana.leme
@since     21/09/2018
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
method newCbcSZFCtrl() class CbcSZFCtrl
	::setStatus(.T., '')
	::aF2 := {} 	
	::isOk()
	::setFiliAtu()
	::getMsgErr()
	::SetRecnoF2({""})
	::ConfSZF({})
	::AtualizSF2()	
return(Self)



method setFiliAtu(cFiliAtu) class CbcSZFCtrl
	Default cFiliAtu := FwFilial()
	::cFiliAtu := cFiliAtu
return(self)

/*/{Protheus.doc} setStatus
@type method
@author bolognesi
@since 23/05/2018
@description Define status da execução,'MVC_MODEL_ID'ID'ropriedades
lOk e cMsgErr para guardar o status e respectiva mensagem de erro
bem como criar exeptions para tratamento de erro personalizado.
/*/
method setStatus(lSts, cMsg, lEx) class CbcSZFCtrl
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
method isOk() class CbcSZFCtrl
return(::lOk)

/*/{Protheus.doc} getMsgErr
@type method
@author bolognesi
@since 23/05/2018
@description  Retorna a propriedade cMsgErr, armazena
descrição sobre o status da execução.
TAG: SetStatus, Erro
/*/
method getMsgErr() class CbcSZFCtrl
return(::cMsgErr)


/*/{Protheus.doc} ModelDef
//TODO Descrição auto-gerada.
@author juliana.leme
@since 21/09/2018
@version 1.0

@type function
/*/
static function ModelDef()
return FWLoadModel('CbcSZFModel')


/*/{Protheus.doc} ViewDef
//TODO Descrição auto-gerada.
@author juliana.leme
@since 21/09/2018
@version 1.0

@type function
/*/
static function ViewDef()
return FWLoadView( 'CbcSZFModel' )

method validSF2(cChvNFe) class CbcSZFCtrl
	local oSql		:= nil
	local cQuery	:= ""	
	
	cQuery := " SELECT F2.F2_FILIAL FILIAL, F2.F2_DOC DOC, F2.F2_SERIE SERIE "
	cQuery += " FROM SF2010 F2 "
	cQuery += " WHERE F2.F2_FILIAL IN ('01','02') "
	cQuery += " AND F2.F2_CHVNFE = '" + cChvNFe + "'"
	cQuery += " AND F2.D_E_L_E_T_ = '' "
	
	oSql := LibSqlObj():newLibSqlObj()	
	oSql:newAlias( cQuery )
	
	if !(oSql:hasRecords())
		::setStatus(.F., 'NFe informada não localizada!',.F.)		
	else
		::setFiliAtu(oSql:getValue("FILIAL"))
	endIf
		
	oSql:close() 
	FreeObj(oSql)
return(self)



/*/{Protheus.doc} SetRecnoF2
//TODO Descrição auto-gerada.
@author juliana.leme
@since 24/09/2018
@version 1.0

@type function
/*/
method SetRecnoF2(cFilialat,cChvNFe) class CbcSZFCtrl
	Default cFilialat	:= ::cFiliAtu
	Default cChvNFe		:= " "
	
	If !Empty(Alltrim(cFilialat)) 
		DbSelectArea('SF2')
		SF2->(DbGoTop())
		DBOrderNickName("ZZCHVNFE")
		If SF2->(DBSeek(cFilialat+cChvNFe ,.F.))
			::nRecnoF2 := SF2->(Recno())
			::aF2 := {SF2->F2_FILIAL,SF2->F2_CDROMA,SF2->F2_DOC,SF2->F2_SERIE,SF2->F2_EMISSAO,;
						SF2->F2_HORA,SF2->F2_TIPO,SF2->F2_CLIENTE,SF2->F2_LOJA}
		Else
			Self:setStatus(.F., 'Não foram encontrados informações com a NFe informada')
		EndIf
	EndIf
return()

method AtualizSF2(aDads, nConta) class CbcSZFCtrl
	Default aDads := {}
	Default nConta := 0
	
    //Atualiza o SF2
	If Len(::aF2) > 0 .and.  Len (aDads) > 0
		DbSelectArea('SF2')
		SF2->(DbGoTop())
		SF2->(DBSetOrder(1))
		
		If SF2->(DbSeek(::aF2[1]+::aF2[3]+::aF2[4], .F.))
		
			If SF2->(F2_FILIAL+F2_DOC+F2_SERIE) == ::aF2[1]+::aF2[3]+::aF2[4]
				if SF2->(RecLock(('SF2'), .F.))
					SF2->F2_DTENTR 	:= StoD(aDads[nConta][2][2])
					SF2->F2_HRENTR 	:= StrTran(aDads[nConta][3][2],":","")
					SF2->F2_TRANSP 	:= aDads[nConta][4][2]
					SF2->F2_MOTOR  	:= aDads[nConta][6][2]
					SF2->F2_CARREG 	:= aDads[nConta][5][2]
					SF2->F2_DTRETCA 	:= Date() 
					MsUnLock()
				Else
					lOk := .F.
				Endif
			Else
				lOk := .F.
			EndIf
		Else
			lOk := .F.
		EndIf
	EndIf
return(Self)

/*/{Protheus.doc} ConfSZF
//TODO Descrição auto-gerada.
@author juliana.leme
@since 24/09/2018
@version 1.0
@param aZF, array, descricao
@type function
/*/
Method ConfSZF(aZF) class CbcSZFCtrl
	local oSZFModel 	:= ModelDef()
	local cIDModel		:= 'SZFMASTER'
	local aArea			:= GetArea()
	local lRet			:= .F.
	local aErro			:= {}
	local bErro			:= nil
	local nCont 		:= 1
	local oFil			:= cbcFiliais():newcbcFiliais()
	local cFilSai		:= FwFilial() 
	
	DbSelectArea('SZF')
	DbSelectArea('SF2')
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, Self)})
	If Len(aZF) > 0
		BEGIN SEQUENCE
			::setStatus(.T., '')
			BEGIN TRANSACTION
				For nCont := 1 to Len(aZF)
					oFil:setFilial(aZF[nCont][1][2])
					::SetRecnoF2(aZF[nCont][1][2]+aZF[nCont][7][2])
										
					oSZFModel:SetOperation(MODEL_OPERATION_INSERT)
					oSZFModel:Activate()
					
					oSZFModel:LoadValue(cIDModel, 'ZF_FILSAI'	, 	cFilSai)
					oSZFModel:LoadValue(cIDModel, 'ZF_CDROMA'	,	::aF2[2])
					oSZFModel:LoadValue(cIDModel, 'ZF_NOTA'		,	::aF2[3])
					oSZFModel:LoadValue(cIDModel, 'ZF_SERIE'	,	::aF2[4])
					oSZFModel:LoadValue(cIDModel, 'ZF_DATA'		,	StoD(aZF[nCont][2][2]))
					oSZFModel:LoadValue(cIDModel, 'ZF_HORA'		,	StrTran(aZF[nCont][3][2],":",""))
					oSZFModel:LoadValue(cIDModel, 'ZF_TRANS'	,	aZF[nCont][4][2])
					oSZFModel:LoadValue(cIDModel, 'ZF_MOTOR'	,	left(aZF[nCont][6][2], TamSx3('ZF_MOTOR')[1]))
					oSZFModel:LoadValue(cIDModel, 'ZF_CARREG'	,	left(aZF[nCont][5][2], TamSx3('ZF_CARREG')[1]))
					oSZFModel:LoadValue(cIDModel, 'ZF_PEDIDOS'	,	"")
					oSZFModel:LoadValue(cIDModel, 'ZF_PESO'		,	0)
					oSZFModel:LoadValue(cIDModel, 'ZF_TOTAL'	,	0)
					oSZFModel:LoadValue(cIDModel, 'ZF_DTRETCA'	,	Date()  )
					oSZFModel:LoadValue(cIDModel, 'ZF_DTVOLTA'	,	Date() )
					oSZFModel:LoadValue(cIDModel, 'ZF_DTCLIEN'	,	Date() )
					oSZFModel:LoadValue(cIDModel, 'ZF_ATRASO'	,	"0") //0 = ENTREGA NO PRAZO
					oSZFModel:LoadValue(cIDModel, 'ZF_OBSERVA'	,	"")
					oSZFModel:LoadValue(cIDModel, 'ZF_DTEMISS'	,	::aF2[5])
					oSZFModel:LoadValue(cIDModel, 'ZF_HREMISS'	,	StrTran(::aF2[6],":",""))
					oSZFModel:LoadValue(cIDModel, 'ZF_PESONF'	,	0)
					oSZFModel:LoadValue(cIDModel, 'ZF_DESVIO'	,	0)
					oSZFModel:LoadValue(cIDModel, 'ZF_TIPONF'	,	::aF2[7])
					oSZFModel:LoadValue(cIDModel, 'ZF_CLIENTE'	,	::aF2[8])
					oSZFModel:LoadValue(cIDModel, 'ZF_LOJA'		, 	::aF2[9])
					
					if ! (lRet := oSZFModel:VldData())
						aErro := oSZFModel:GetErrorMessage()
						Self:setStatus(.F.,aErro[6])
					else
						::AtualizSF2(aZF,nCont)
						FWFormCommit(oSZFModel)
						oSZFModel:DeActivate()
					endIf
					oFil:backFil()
				Next
			END TRANSACTION
			RECOVER
		END SEQUENCE
	EndIf
	ErrorBlock(bErro)
	FreeObj(oFil)
	RestArea(aArea)
Return(self)

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
	dDatabase		:= Self:dDataBk
	oSelf:lOk			:= .F.
	
	oSelf:cMsgErr		:= "[CbcSZFCtrl - "+DtoC(Date())+" - "+Time()+" ]"+;
		oErr:Description +;
		if ( FwIsAdmin() ,' [ORIGEM]' + ProcName(3), '')+;
		if(lCompl, '  ' + oSelf:cMsgErr, '')
	BREAK
return(nil)	


User Function TesteZF()
	Local oInstSZF  := CbcSZFCtrl():NewCbcSZFCtrl()
	Local aDadosZF := {}
	
	aAdd(aDadosZF,{;
					{"FILIAL","01"},;
					{"DATA","20180924"},;
					{"HORA","08:00"},;
					{"TRANS","000010"},;
					{"CARREG","TESTE"},;
					{"MOTOR","TESTE1"},;
					{"CHAVE","35180902544042000119550010001816311007128700"}})
	aAdd(aDadosZF,{;
					{"FILIAL","01"},;
					{"DATA","20180924"},;
					{"HORA","08:00"},;
					{"TRANS","000010"},;
					{"CARREG","TESTE2"},;
					{"MOTOR","TESTE3"},;
					{"CHAVE","35180902544042000119550010001816321004013837"}})
	aAdd(aDadosZF,{;
					{"FILIAL","01"},;
					{"DATA","20180924"},;
					{"HORA","08:00"},;
					{"TRANS","000010"},;
					{"CARREG","TESTE4"},;
					{"MOTOR","TESTE5"},;
					{"CHAVE","35180902544042000119550010001816341002303859"}})	
	oInstSZF:ConfSZF(aDadosZF)
Return()
