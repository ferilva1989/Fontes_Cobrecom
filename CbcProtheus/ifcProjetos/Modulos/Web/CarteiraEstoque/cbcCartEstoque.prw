#INCLUDE "totvs.ch"
#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcCartEstoque() 
	local aCoors 			:= FWGetDialogSize( oMainWnd )
	local aFiles			:= {}
	local cMainHTML			:= ''
	private oAdVuePl		:= nil
	private oWebEngine		:= nil
	private oDlg			:= nil

	aFiles 		:= {'cbcestoque.html', 'cbcestoque.css', 'cbcestoque.js', 'favicon.ico', 'twebchannel.js'}
	cMainHTML 	:= 'cbcestoque.html'
	
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
	local oObjCarteira	:= nil
	Do Case 
		case key  == "<getData>"
		responseData(value)
		case key == '<getDetalhe>'
		responseDet(value)
		case key == '<fechar>'
		oDlg:END()
	EndCase
return(nil)


// Envia evento JS
static function toJs(cEvent,cValue)
	oAdVuePl:toJsEvents(cEvent, cValue)
return(nil)


static function responseDet(cValue)
	local oJson 	:= JsonObject():new()
	local oRetJson 	:= JsonObject():new()
	oJson:fromJson(cValue)
	oObjCarteira 	:= cbcCtrCartEstoque():newcbcCtrCartEstoque()
	oObjCarteira:prepDetalhe(oJson)
	oRetJson['titulo']	:= oObjCarteira:cTitulo
	oRetJson['headers']	:= oObjCarteira:aRefHeader
	oRetJson['data']	:= oObjCarteira:oMainData
	toJs('<respDetalhe>', oRetJson:toJson())
return(nil)


static function responseData(cTpData)
	local oObjCarteira 	:= nil
	local oJson 		:= JsonObject():new()
	default cTpData		:= 'EPA'
	oObjCarteira := cbcCtrCartEstoque():newcbcCtrCartEstoque()
	oObjCarteira:prepData(cTpData)			
	oJson['headerdef']	:= oObjCarteira:aRefHeader // Array de como é escrito o Header
	oJson['columdef']	:= oObjCarteira:oColumnDef 
	oJson['totais']		:= oObjCarteira:oTotais
	oJson['data']   	:= oObjCarteira:oMainData
	toJs('<respData>', oJson:toJson() )
return(nil)


static function getButtons()
	local aBtn := {}
	/*
	[n]
	[n][1] cResource Nome do resource compilado no RPO que será a imagem do botao
	[n][2] cTitle Titulo do Botao
	[n][3] bBloco Bloco de codigo que será executado
	[n][4] cToolTip Comentário do botão
	[n][5] nShortCut Tecla para se criar o ShortCurt
	[n][6] lShowBar Indica que o botão estará visível na barra
	[n][7] lConfig Indica se botao estara visivel na configuracao
	*/
return (aBtn)

