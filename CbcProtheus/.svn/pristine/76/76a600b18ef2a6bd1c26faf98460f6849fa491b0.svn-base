#include "totvs.ch"


user function cbcRptCarbone()
    local oWebEngine		:= nil
    local oModal			:= nil
    local oDlg				:= nil
    private aNiversLocal 	:= {}
    private oWebChannel		:= nil
    private oReport			:= nil
    	
    	
    	oModal  := FWDialogModal():New()
    	oModal:SetEscClose(.T.)
    	oModal:setTitle("cbcReport")
    	oModal:setSize(300, 600)
    	oModal:createDialog()
		oModal:addCloseButton(nil, "Fechar")
    	oDlg := oModal:getPanelMain()
        
        oWebChannel := TWebChannel():New()
        oWebChannel:bJsToAdvpl := {|self,key,value| jsToAdvpl(self,key,value) } 
        oWebChannel:connect()

        MsgInfo(cValToChar(oWebChannel:nPort), 'PORTA')
        	
        oWebEngine := TWebEngine():New(oDlg,0,0,100,100,/*cUrl*/,oWebChannel:nPort)
        oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

        oReport := cbcReport():newcbcReport()
        oWebEngine:navigate(iif(oReport:GetOS()=="UNIX", "file://", "") + oReport:mainHTML)
        oWebEngine:bLoadFinished := {|webengine, url| oReport:OnInit(webengine, url),myLoadFinish(webengine, url) }

   oModal:Activate()
return


static function myLoadFinish(oWebEngine, url)
    conout("myLoadFinish:")
    conout("Class: " + GetClassName(oWebEngine))
    conout("URL: " + url)
    conout("TempDir: " + oReport:tmp)
return


static function jsToAdvpl(self,key,value)
	local oObjCarteira	:= nil
    Do Case 
        case key  == "<submit>"
            oObjCarteira := cbcRelCartVendas():newcbcRelCartVendas()
            oObjCarteira:prepData()
            showCarteira(oObjCarteira)
    EndCase
Return


static function showCarteira(oObjCarteira)
   oJson := JsonObject():new()
   oJson['layout'] 			:= "carteira.ods"
   oJson['outputFormat'] 	:= "pdf"
   oJson['data'] 			:= oObjCarteira:oPedidos
   oWebChannel:advplToJS("<carteira-new>", oJson:toJSon())
   FreeObj(oObjCarteira)
return(nil)


class cbcReport 
    data mainHTML
    data mainData
    data tmp
    method newcbcReport() CONSTRUCTOR
    method OnInit() 
    method templateComp()
    method Script()
    method Style()
    method Get()
    method Set()
    method SaveFile(cContent)
    method GetOS()
endClass


method newcbcReport() class cbcReport
    local cMainHTML
    ::tmp := GetTempPath()
    ::mainHTML := ::tmp + lower(getClassName(self)) + ".html"
    ::mainData := {}
    
    h := fCreate(iif(::GetOS()=="UNIX", "l:", "") + ::tmp + "twebchannel.js")
    fWrite(h, GetApoRes("twebchannel.js"))
    fClose(h)
    cMainHTML := ::Style() + chr(10) + ::templateComp()
    if !::SaveFile(cMainHTML)
        msgAlert("Arquivo HTML principal nao pode ser criado")
    endif
return(self)


method OnInit(webengine, url) class cbcReport
    webengine:SetUpdatesEnable(.F.)


    ProcessMessages()
    sleep(300)
    webengine:SetUpdatesEnable(.T.)
return (self)


method templateComp() class cbcReport
return htmlTemplate()


method Style() class cbcReport
return styleTemplate()


method Get(cVarname) class cbcReport
    local nPosBase := AScan( ::mainData, {|x| x[1] == cVarname} )
    if nPosBase > 0
        return ::mainData[nPosBase, 2]
    endif
return ""


method Set(cVarname, xValue, bUpdate) class cbcReport
    local nPosBase := AScan( ::mainData, {|x| x[1] == cVarname} )
    if nPosBase > 0
        if valType(xValue) == "A"
            ::mainData[nPosBase, 2] := aClone(xValue)
        else
            ::mainData[nPosBase, 2] := xValue
        endif
    else
        Aadd(::mainData, {cVarname, xValue})
    endif
    if valtype(bUpdate) == "B"
        eval(bUpdate)
    endif
return (self)


method SaveFile(cContent) class cbcReport
    local nHdl := fCreate(iif(::GetOS()=="UNIX", "l:", "") + ::mainHTML)
    if nHdl > -1
        fWrite(nHdl, cContent)
        fClose(nHdl)
    else
        return .F.
    endif
return .T.


method GetOS() class cbcReport
    local stringOS := Upper(GetRmtInfo()[2])
    if GetRemoteType() == 0 .or. GetRemoteType() == 1
        return "WINDOWS"
    elseif GetRemoteType() == 2 
        return "UNIX" // Linux ou MacOS		
    elseif GetRemoteType() == 5 
        return "HTML" // Smartclient HTML		
    elseif ("ANDROID" $ stringOS)
        return "ANDROID" 
    elseif ("IPHONEOS" $ stringOS)
        return "IPHONEOS"
    endif    
return ("")


static function htmlTemplate()
	BeginContent var cHTML
	<html>

<head>
    <link href="https://fonts.googleapis.com/css?family=Roboto:100,300,400,500,700,900" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css?family=Material+Icons" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/@mdi/font@3.x/css/materialdesignicons.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify.min.css" rel="stylesheet">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no, minimal-ui">
</head>
<script src="https://unpkg.com/axios/dist/axios.min.js"></script>
<script src="twebchannel.js"></script>

<body>
    <div id="app">
        <v-app>
            <v-content>
                <v-overlay :value="overlay">
                    <v-progress-circular indeterminate size="64"></v-progress-circular>
                </v-overlay>
                <v-data-table :headers="headers" :items="items" :items-per-page="20" class="elevation-2">
                </v-data-table>
                <v-btn v-on:click="requestUpd()" fixed dark fab top right color="blue">
                    <v-icon>info</v-icon>
                </v-btn>
            </v-content>
        </v-app>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/vue@2.x/dist/vue.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify.js"></script>
    <script>
        new Vue({
            el: '#app',
            vuetify: new Vuetify(),
            mounted: function ()  {
                twebchannel.connect(() => { console.log('Websocket Connected!') })
                twebchannel.advplToJs = (key, value) => {
                    if (key === "<carteira-new>") {
                        this.updData(value)
                    }
                }
            },
            data: {
                overlay: false,
                headers: [],
                items: [],
                originData: []
            },
            methods: {
                requestUpd() {
                    this.overlay = true
                    twebchannel.jsToAdvpl("<submit>", '')
                },
                updData(value) {
                    // value.layout
                    // value.outputFormat
                    let mainObj = JSON.parse(value)
                    this.headers = []
                    this.items = []
                     for (let prop of Object.keys(mainObj.data[0])) {
                        let objHeader = {}
                        objHeader['text']  = prop
                        objHeader['value'] = prop
                        this.headers.push(objHeader)   
                    }
                    this.items = mainObj.data
                    this.overlay = false
                    
                    /*
                    axios.post('http://127.0.0.1:6044/report', value.data)
                    .then( (response) => {
                      console.log(response)
                    })
                    .catch( (error) => {
                      console.log(error)
                    });
                    */
                }
            }
        })
    </script>
</body>

</html>
    EndContent
return (cHTML)


static function styleTemplate()
 BeginContent var cStyle
        <style>
            /* [*CustomButton] */
            .button {
                padding: 10px; 
                border-radius: 5px;
                border: none;
                color: #fff;
                background-color: #007bff;
                font-size: 14px;
                width: 100px;
                height: 40px; 
            }
            .button:hover{
                background-color: #0069d9;
            }

            /* [*StyleSheet]*/
            .divLine{
                margin: 0;
                margin-bottom: 2;
                border-bottom-color: #ff0000;
                border-bottom-style: dotted;
                border-bottom-width: 1;
            }
        </style>
    EndContent

return(cStyle)