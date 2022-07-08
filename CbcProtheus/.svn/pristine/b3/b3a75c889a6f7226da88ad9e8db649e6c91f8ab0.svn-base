#include 'protheus.ch'
#include 'parmtype.ch'

user function MA512MNU()
    local oAcl as object
    oAcl	:= cbcAcl():newcbcAcl()
    if oAcl:aclValid('EditDocSaida')
        aadd(aRotina,{'Alt.Info','u_cbcAltDcSai()' , 0 , 3, 0, NIL})
    endif
    FreeObj(oAcl)
return(nil)