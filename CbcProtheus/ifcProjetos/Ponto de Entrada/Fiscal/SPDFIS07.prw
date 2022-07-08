#include 'totvs.ch'

user function SPDFIS07()
    local aArea		    := GetArea()
    local aAreaSB1	    := SB1->(GetArea())
    local cCod          := PARAMIXB[1] //Codigo do Produto
    local cTipo         := PARAMIXB[2] // Tipo
    local cConta        := ""
    
    /*nTipo	
    0 - Saldo em Estoque (1)
    1 - Saldo em Terceiros (5)
    2 - Saldo de Terceiros (4)
    */
    
    DbSelectArea("SB1")
    SB1->(DbSetOrder(1))
    SB1->(DbSeek(xFilial("SB1") + Padr(cCod, TamSX3('B1_COD')[1]) ,.F.))

    if cTipo == '1'
        cConta := AllTrim(GetNewPar('ZZ_HETER' + AllTrim(SB1->B1_TIPO), SB1->B1_CONTA))
        /*
        if SB1->B1_TIPO == 'MP'
            cConta := '113170001'
        elseif SB1->B1_TIPO == 'PI'
            cConta := '113190001'
        elseif SB1->B1_TIPO == 'SC'
            cConta := '113160001'
        elseif SB1->B1_TIPO == 'OI'
            cConta := '113130001'
        elseif SB1->B1_TIPO == 'ME'
            cConta := '113150001'
        else
            cConta := SB1->B1_CONTA
        endif 
        */
    elseif cTipo == '2'
        cConta := AllTrim(GetNewPar('ZZ_HDTER' + AllTrim(SB1->B1_TIPO), SB1->B1_CONTA))
        /*
        if SB1->B1_TIPO == 'ME'
            cConta := '113140001'
        else
            cConta := SB1->B1_CONTA
        endif 
        */
    else
        cConta := AllTrim(GetNewPar('ZZ_HPROP' + AllTrim(SB1->B1_TIPO), SB1->B1_CONTA))
        /*
        if Alltrim(SB1->B1_CONTA) == '113040005'
            cConta := '113040001'
        else
            cConta := SB1->B1_CONTA
        endif
        */
    endif

    RestArea(aAreaSB1)
    RestArea(aArea)
return(cConta)
