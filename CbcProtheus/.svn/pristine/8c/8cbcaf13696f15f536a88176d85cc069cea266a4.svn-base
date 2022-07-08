#INCLUDE "totvs.ch"
#include 'protheus.ch'
#include 'parmtype.ch'

user function wcbcCalcImpos() 
	local aCoors 			:= FWGetDialogSize( oMainWnd )
	local aFiles			:= {}
	local cMainHTML			:= ''
	private oAdVuePl		:= nil
	private oWebEngine		:= nil
	private oDlg			:= nil

	aFiles 		:= {'cbcimposto.html', 'cbcimposto.css', 'cbcimposto.js', 'favicon.ico', 'twebchannel.js'}
	cMainHTML 	:= 'cbcimposto.html'
	
	oDlg := TDialog():New(aCoors[1],aCoors[2],aCoors[3],aCoors[4],,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T.,,,,,,.F.)
	oDlg:lMaximized 	:= .T.
	oAdVuePl 			:= AdVuePl():newAdVuePl({|self,key,value|, fromJs(key,value)})
	oAdVuePl:makeEnv(aFiles, cMainHTML)	
	oWebEngine 			:= TWebEngine():New(oDlg,0,0,100,100,/*cUrl*/, oAdVuePl:getPort() )
	oWebEngine:Align 	:= CONTROL_ALIGN_ALLCLIENT
	oAdVuePl:configEngine(oWebEngine)
	oDlg:Activate()
	FreeObj(oAdVuePl)
	FreeObj(oWebEngine)
	FreeObj(oDlg)
return(nil)


// Recebe Evento JS
static function fromJs(key, value)
	Do Case 
		case key  == "<getData>"
			responseCalc(value)
		case key  == "<getCnpj>"
			responseCnpj(value)
		case key  == "<getProd>"
			responseProd(value)
		case key  == "<getCalc>"
			responseCalc(value)
		case key  == "<updSuspect>"
			updSuspect(value)
		case key  == "<buscaProduto>"
			buscaProd(value)
		case key  == "<getFrmDoc>"
			buscaDoc(value)		
		case key == '<fechar>'
		oDlg:END()
	EndCase
return(nil)


// Envia evento JS
static function toJs(cEvent,cValue)
	oAdVuePl:toJsEvents(cEvent, cValue)
return(nil)


static function buscaDoc(jsData)
	local oInfo 		:= cbcDocPorCtrl():newcbcDocPorCtrl()
	oJson 				:= oInfo:load(jsData)
	toJs('<respFrmDoc>', oJson:toJson() )
	FreeObj(oInfo)
return(nil)


static function responseCnpj(cCnpj)
	local oCtrl 		:= cbcCtrlSusp():newcbcCtrlSusp()
	oJson 				:= oCtrl:load(cCnpj)
	toJs('<respCnpj>'   , oJson:toJson() )
	FreeObj(oCtrl)
return(nil)


static function buscaProd(cBusca)
	local oJson 		:= JsonObject():new()
	oJson['codigo']		:= cBusca
	oJson['descricao']	:= 'Produto retornado'
	toJs('<respProd>', oJson:toJson() )
return(nil)


static function updSuspect(jsSuspect)
	local oJson 		:= JsonObject():new()
	local oCtrl 		:= cbcCtrlSusp():newcbcCtrlSusp()
	oCtrl:save(jsSuspect)
	oJson['status']		:= .T.
	toJs('<updSusStatus>', oJson:toJson() )
	FreeObj(oCtrl)
return(nil)


static function responseProd(cCodigo)
	local oJson 		:= JsonObject():new()
	oJson['produto']	:= 'devolver'
	
	toJs('<respProd>'   , oJson:toJson() )
return(nil)


static function responseCalc(cTpData)
	local oJson 		:= JsonObject():new()
	oObjImposto 		:= cbcCtrCalcImpost():newcbcCtrCalcImpost()
	oObjImposto:calcImposto(cTpData)			
	oJson['datacalc']	:= oObjImposto:datacalc
	toJs('<respCalc>'   , oJson:toJson() )
	FreeObj(oObjImposto)
return(nil)


