#include 'Totvs.ch'

class cbcTrkSrv
    data response   as object
    data cChave     as character
    data oApi       as object
    method newcbcTrkSrv() constructor
    method consultar()

endClass

method newcbcTrkSrv() class cbcTrkSrv
    ::response := nil
return(self)


method consultar(cChave) class cbcTrkSrv
     ::cChave := cChave
     createresp(@self)
     gateway(@self)
     doWrk(@self)
     FreeObj(::oApi)
return self


/* Realiza a consulta com a api selecionada */
static function doWrk(oSelf)
    local resp  as object
    local oDoc  as object 
    /* Obter o retorno */
    resp := oSelf:oApi:consulta(oSelf:cChave)
    
    /* Preparar o retorno */
    oDoc := cbcTrkDoc():newcbcTrkDoc()
    oDoc:chave := oSelf:cChave
    
    /* Retornar */
    oSelf:response['CONTEUDO'] := oDoc
return nil


// TODO
/* Define Classe API da transportadora */
static function gateway(oSelf)
    // oSelf:cChave
    // oSelf:oApi := cbcTrkSSW():newcbcTrkSSW()
    
     /*
        "trdtransportes"
        "rissotransportes"
        "rocell"
    */
    oSelf:oApi := cbcTrkSenior():newcbcTrkSenior("rocell")
return nil


/* Cria o objeto para retorno*/
static function createresp(oSelf)
    oSelf:response := JsonObject():new()
    oSelf:response['STATUS']    := .T.
    oSelf:response['CONTEUDO']  := nil
    oSelf:response['MSG']       := ''
return 
