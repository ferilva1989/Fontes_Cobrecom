#include 'TOTVS.ch'

class cbcCusMdl
    data cName  as character
    data aMovs  as array
    data aCompl as array
    method newcbcCusMdl() constructor 
    method addValue()

endClass

method newcbcCusMdl(cName, aTpProd, aTpIdMovs) class cbcCusMdl
    ::cName     := cName
    ::aMovs     := {}
    ::aCompl    := {}
    loadMovs(@self, aTpProd, aTpIdMovs)
return(self)


method addValue(MovId, cTpProd, nValor)class cbcCusMdl
     local nPos     as numeric
     local nProdPos as numeric
     if  (nPos := aScan( ::aMovs, {|x| lower(Alltrim(x:CMOVID)) == lower(Alltrim(MovId)) }) ) > 0
        if  (nProdPos := aScan( ::aMovs[nPos]:APROD, {|x| lower(Alltrim(x:CTIPO)) == lower(Alltrim(cTpProd)) }) ) > 0
            ::aMovs[nPos]:APROD[nProdPos]:setValor(nValor)
        endif
     endif 
return(self)


static function loadMovs(oSelf, aTpProd, aTpIdMovs)
    local nX    as numeric
    local oMov  as object
    
    for nX := 1 to len(aTpIdMovs)
        oMov := cbcCusMovs():newcbcCusMovs()
        oMov:setMovId(aTpIdMovs[nX])
        oMov:loadProd(aTpProd)
        aadd(oSelf:aMovs, oMov)
    next nX

return nil
