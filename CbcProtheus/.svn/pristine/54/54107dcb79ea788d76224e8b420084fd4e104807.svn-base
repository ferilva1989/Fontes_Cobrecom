#include 'Totvs.ch'
#define GRP_SYSADM '000000'
#define GRP_MANIFESTA '000134'

user function MANIOPCEVT()
    local aItensCb  := PARAMIXB[1]
    local aRetItens := {}
    local oAcl		:= cbcAcl():newcbcAcl()
    local cLibera   := GetNewPar('ZZ_LIBMANI', "210210")
    local aLibera   := {}
    local nX        := 0
    local nPosi     := 0

    if FwIsAdmin() .or. oAcl:usrIsGrp({GRP_SYSADM, GRP_MANIFESTA})
        aRetItens := aClone(aItensCb)
    else
        aLibera := StrTokArr(cLibera,";" )
        for nX := 1 to len(aItensCb)
            //"210210 - Ciência da Operação"
            nPosi := AScan(aLibera, Left(aItensCb[nX], 6))
            if nPosi > 0
                aAdd(aRetItens, aItensCb[nX])
            endif
        next nX
    endif
    FreeObj(oAcl)
return(aRetItens)
