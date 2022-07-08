#INCLUDE "totvs.ch"
#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcCartPedido() 
	local oModal			:= nil
    local oDlg				:= nil
    local aFiles			:= {}
    local cMainHTML			:= ''
    private oAdVuePl		:= nil
    private oWebEngine		:= nil
    
    aFiles 		:= {'cbcreport.html', 'cbcreport.css', 'cbcreport.js', 'favicon.ico', 'twebchannel.js'}
    cMainHTML 	:= 'cbcreport.html'
    
    oModal  := FWDialogModal():New()
    oModal:SetEscClose(.T.)
    oModal:setSize(300, 600)
    oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
    oModal:addButtons(getButtons())
    oDlg := oModal:getPanelMain()
    
    oAdVuePl := AdVuePl():newAdVuePl({|self,key,value|, fromJs(key,value)})
	oAdVuePl:makeEnv(aFiles, cMainHTML)	
	oWebEngine 			:= TWebEngine():New(oDlg,0,0,100,100,/*cUrl*/, oAdVuePl:getPort() )
    oWebEngine:Align 	:= CONTROL_ALIGN_ALLCLIENT
	oAdVuePl:configEngine(oWebEngine)
	
	oModal:Activate()
	
	FreeObj(oAdVuePl)
	FreeObj(oModal)
	FreeObj(oWebEngine)
return(nil)


// Recebe Evento JS
static function fromJs(key, value)
	local oObjCarteira	:= nil
    Do Case 
        case key  == "<getData>"
           responseData()
        case key == "<toPrint>"
        	oWebEngine:printPdf()
        	toJs('printOk','')
    EndCase
return(nil)


// Envia evento JS
static function toJs(cEvent,cValue)
	oAdVuePl:toJsEvents(cEvent, cValue)
return(nil)


static function responseData()
	local oObjCarteira 	:= nil
	local oJson 		:= JsonObject():new()
	default lAdvpl		:= .F.
	
	oObjCarteira := cbcRelCartVendas():newcbcRelCartVendas()
	oObjCarteira:prepData()
	oJson['key']		:= 'Pedido'
	oJson['group']  	:= 'Representante'
	oJson['sortby']  	:= {'Filial','Segmento', 'Cliente', 'Pedido'}
	oJson['sortdesc']   := {.F., .F., .F., .F.}
	oJson['headerdef']	:= oObjCarteira:oRefHeader 
	oJson['data']   	:= oObjCarteira:oPedidos
	oJson['totRepre']   := oObjCarteira:totRepre
	toJs('<respData>', oJson:toJson() )
return(nil)

static function toPrint()
	oWebEngine:PrintPDF()
	oWebEngine:GoHome()
return()


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
	// aadd(aBtn, {'', 'Segmento', {|| responseData('Segmento', .T.)}, '',,.T.,.F.})
	// aadd(aBtn, {'', 'Representante', {|| responseData('Representante', .T.)}, '',,.T.,.F.})
	aadd(aBtn, {'', 'Imprimir', {|| toPrint() }, '',,.T.,.F.})
return (aBtn)

