#include 'protheus.ch'


class AdVuePl 
	data bmainEvent
	data fileHTML
    data mainData
    data tmp
	data oWebChannel
	
	method newAdVuePl() constructor 
	method fromJsEvents()
	method toJsEvents()
	method makeEnv()
	method OnInit()
	method myLoadFinish()
	method configEngine()
	method Get()
    method Set()
    method SaveFile(cContent)
    method GetOS()
    method getPort()
    method retSelf()
endclass


method newAdVuePl(bmainEvent) class AdVuePl
	static mySelf := nil 
	default bmainEvent := {|self,key,value|, MsgInfo('Chave: ' + key + ' Valor: ' + value, 'Default') }
	::bmainEvent :=  bmainEvent
	::retSelf(@mySelf)
	::oWebChannel := TWebChannel():New()
	::oWebChannel:bJsToAdvpl := { |self,key,value| mySelf:fromJsEvents(self,key,value) } 
	::oWebChannel:connect()
return(self)


method getPort() class AdVuePl
return(::oWebChannel:nPort)


method retSelf(cValue) class AdVuePl
	cValue := self
return(nil)


method configEngine(oWebEngine) class AdVuePl
	oWebEngine:bLoadFinished := {|webengine, url| ::OnInit(webengine, url), ::myLoadFinish(webengine, url) }
	oWebEngine:navigate(iif(::GetOS()=="UNIX", "file://", "") + ::fileHTML)
return(self)


method OnInit(webengine, url) class AdVuePl
    webengine:SetUpdatesEnable(.F.)

    ProcessMessages()
    sleep(300)
    webengine:SetUpdatesEnable(.T.)
return (self)


method myLoadFinish(oWebEngine, url) class AdVuePl
    conout("myLoadFinish:")
    conout("Class: " + GetClassName(oWebEngine))
    conout("URL: " + url)
    conout("TempDir: " + ::tmp)
return(self)


method makeEnv(aFiles, cMainHTML) class AdVuePl
 	local nX	:= 0
    ::tmp 		:= GetTempPath()
    ::fileHTML 	:= ::tmp + lower(cMainHTML)
    ::mainData 	:= {}
    for nX := 1 to len(aFiles)
	    if aFiles[nX] == cMainHTML
	    	 if !::SaveFile(GetApoRes(aFiles[nX]))
	    	 	msgAlert("Arquivo HTML principal nao pode ser criado")
        	endif
	    else
		    h := fCreate(iif(::GetOS()=="UNIX", "l:", "") + ::tmp + aFiles[nX])
		    fWrite(h, GetApoRes(aFiles[nX]))
		    fClose(h)
	    endif
    next nX
return(self)


// oWebChannel:bJsToAdvpl := {|self,key,value| ::fromJsEvents(self,key,value) } 
method fromJsEvents(self,key,value) class AdVuePl
	Eval(::bmainEvent, self, key, value) 
return(self)


method toJsEvents(cEvent, cValue) class AdVuePl
	 ::oWebChannel:advplToJS(cEvent, cValue)
return(self)


method SaveFile(cContent) class AdVuePl
    local nHdl := fCreate(iif(::GetOS()=="UNIX", "l:", "") + ::fileHTML)
    if nHdl > -1
        fWrite(nHdl, cContent)
        fClose(nHdl)
    else
        return .F.
    endif
return .T.


method Get(cVarname) class AdVuePl
    local nPosBase := AScan( ::mainData, {|x| x[1] == cVarname} )
    if nPosBase > 0
        return ::mainData[nPosBase, 2]
    endif
return ""


method Set(cVarname, xValue, bUpdate) class AdVuePl
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


method GetOS() class AdVuePl
    local stringOS := Upper(GetRmtInfo()[2])
    if GetRemoteType() == 0 .or. GetRemoteType() == 1
        return "WINDOWS"
    elseif GetRemoteType() == 2 
        return "UNIX"
    elseif GetRemoteType() == 5 
        return "HTML"		
    elseif ("ANDROID" $ stringOS)
        return "ANDROID" 
    elseif ("IPHONEOS" $ stringOS)
        return "IPHONEOS"
    endif    
return ("")


/*
	npm install @vue/cli -g
	vue create my-app
	cd my-app
	vue add vuetify
	
	#vue.config.js
	const nameApp = 'cbcvue' 
	module.exports = {
	  productionSourceMap: false,
	  transpileDependencies: ['vuetify'],
	  indexPath: `${nameApp}.html`,
	  publicPath: "./", 
	   chainWebpack: config => { 
	      config.module.rule('images').use('url-loader')
	          .loader('file-loader')
	          .tap(options => Object.assign(options, {
	            name:  `[name].${nameApp}.[ext]`
	          }))
	        config.module.rule('svg').use('file-loader')
	          .tap(options => Object.assign(options, {
	            name: `[name].${nameApp}.[ext]`
	          }))
	      },
	    css: {
	        extract: {
	          filename: `${nameApp}.css`,
	          chunkFilename: `${nameApp}.css`
	        }
	      },
	    configureWebpack: { 
	       output: {
	         filename: `${nameApp}.js`,
	         chunkFilename: `${nameApp}.js`,
	        },
	        optimization: {
	        splitChunks: false
	      }
	    }
	  }
*/