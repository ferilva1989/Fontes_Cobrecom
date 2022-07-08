#include 'protheus.ch'
#include 'parmtype.ch'


user function cbcAdVuePl()
	local oModal			:= nil
    local oDlg				:= nil
    local oWebEngine		:= nil
    local aFiles			:= {}
    local cMainHTML			:= ''
    private oAdVuePl		:= nil
    
    aFiles 		:= {'cbcvue.css', 'cbcvue.js', 'favicon.ico', 'cbcvue.html', 'logo.63a7d78d.svg', 'twebchannel.js'}
    cMainHTML 	:= 'cbcvue.html'
    
    oModal  := FWDialogModal():New()
    oModal:SetEscClose(.T.)
    oModal:setTitle("FrameWork - AdVuePl")
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
        case key  == "<sayHello>"
           MsgInfo('Advpl diga Ola !!!', '')
    EndCase
return(nil)


// Envia evento JS
static function toJs(cEvent,cValue)
	oAdVuePl:toJsEvents(cEvent, cValue)
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
	aadd(aBtn, {'', 'ToJs', {|| toJs('<advplSay>', 'Ola')}, '',,.T.,.F.})
return (aBtn)
