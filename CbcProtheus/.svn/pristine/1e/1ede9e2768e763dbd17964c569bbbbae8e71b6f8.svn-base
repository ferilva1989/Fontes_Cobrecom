#include 'TOTVS.ch'

class cbcCusMovs
    data cMovId
    data aProd
    method newcbcCusMovs() constructor 
    method setMovId()
    method loadProd()
    
endClass


method newcbcCusMovs() class cbcCusMovs
    ::cMovId    := ''
    ::aProd     := {}
return(self)


method setMovId(cId) class cbcCusMovs
    ::cMovId := cId
return self


method loadProd(aProd) class cbcCusMovs
    local nX    as numeric
    local oProd as object
    ::aProd := {}
    for nX := 1 to len(aProd)
        oProd := cbcCusProd():newcbcCusProd()
        oProd:setTipo(aProd[nX])
        oProd:setValor(0)
        aadd(::aProd , oProd)
    next nX
return self
