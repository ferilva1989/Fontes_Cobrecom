#include 'protheus.ch'
class cbcLogClass
    data oRestClient
    data oInfoLog
    data oUser
    data isLogged
    data bErro
    data lOk
    data cMsgErr
    method newcbcLogClass() constructor
    method doLogin()
    method setStatus()
    method isOk()
    method getErr()
    method getUsrInfo()
    method haveGroup()
    method free()
endclass

method newcbcLogClass() class cbcLogClass
    ::oRestClient := FWRest():New(GetNewPar("ZZ_APIURLG","http://192.168.1.220:7798/ws")) 
    ::isLogged := .F.
    ::setStatus()
    ::bErro := ErrorBlock({|oErr| HandleEr(oErr, @self)})
return self


method setStatus(lSts, cMsg) class cbcLogClass
  default lSts := .T.
  default cMsg := ''  
  ::lOk         := lSts
  ::cMsgErr     := cMsg
return self


method isOk() class cbcLogClass
return ::lOk

method getErr() class cbcLogClass
return ::cMsgErr

method free() class cbcLogClass
    ErrorBlock(::bErro)
return self


method getUsrInfo() class cbcLogClass
return ::oUser


method haveGroup(cIdGrp) class cbcLogClass
    local lRet := .F.
    lRet := ((Ascan(::oUser['Grupos'], {|aUsr| aUsr[1] == cIdGrp })) > 0)
return lRet


method doLogin(cUsr, cPass) class cbcLogClass
    local aAllusers := {}
    local aGroups   := {}
    local nPos      := 0
    local nX        := 0
  
    BEGIN SEQUENCE
        ::isLogged := .F.
        ::oRestClient:setPath("/api/oauth2/v1/token?grant_type=password&password=" + cPass + "&username=" + cUsr)
        if ::oRestClient:Post()
            ::oInfoLog := JsonObject():New()
            ::oInfoLog:FromJSON(::oRestClient:GetResult())
            if (::isLogged := valtype(::oInfoLog['access_token']) == 'C')
               ::oUser := JsonObject():New()
               aAllusers := FWSFALLUSERS()
               if (nPos := Ascan(aAllusers, {|aUsr| aUsr[3] == cUsr }) ) > 0 
                   ::oUser['Codigo'] := Alltrim(aAllusers[nPos][2])
                   ::oUser['Nome']  := Alltrim(aAllusers[nPos][4])
                   ::oUser['Email'] := Alltrim(aAllusers[nPos][5])
                   ::oUser['Depto'] := Alltrim(aAllusers[nPos][6])
                    aGroups := FWSFUsrGrps(aAllusers[nPos][2])
                    ::oUser['Grupos'] := {}
                    for nX := 1 to len(aGroups)
                        aadd(::oUser['Grupos'], { aGroups[nX], FWGrpEmp(aGroups[nX]) })
                    next nX
               endif
            endif
        endif
        RECOVER
    END SEQUENCE
return self

/*Funções  Statics*/
static function HandleEr(oErr, oSelf)
    if InTransact()
        DisarmTransaction()
    endif
    oSelf:setStatus(.F., oErr:Description)
    oSelf:isLogged := .F.
    BREAK
return(nil)


/* TEST ZONE */
user function zzLgApClss()
    local oLogin :=  cbcLogClass():newcbcLogClass()
    
    if oLogin:doLogin('USR', 'SENHA'):isOk()
        if oLogin:isLogged
            MsgInfo(oLogin:oInfoLog:toJson(), 'Token Info')
            /*
                {
                    "expires_in": 3600,
                    "token_type": "Bearer",
                    "scope": "default",
                    "access_token": "",
                    "refresh_token": ""
                }
            */
            
            MsgInfo(oLogin:getUsrInfo():toJSon(), 'User Info')
            /*
                {
                    //Grupo , Array[Empresa+Filial]
                    "Grupos": [
                        ["000000", ["@@@@"]],
                        ["000015", ["0101", "0102", "0103"]],
                        ["000091", ["0102"]]
                    ],
                    "Depto": "TI-ITU",
                    "Nome": "IFC Leonardo Bolognesi",
                    "Email": "leonardo@cobrecom.com.br"
                }
            */
            
            if oLogin:haveGroup('000015')
                MsgInfo('Ok', 'OK')
            else
                MsgInfo('Não', 'Não')
            endif
        else
            // Erro de Login
            MsgInfo('Não logado', 'ERRO')
        endif
    else
         // Error Log
         MsgInfo(oLogin:getErr(), 'OK')
    endif
    
    FreeObj(oLogin:free())
return nil
