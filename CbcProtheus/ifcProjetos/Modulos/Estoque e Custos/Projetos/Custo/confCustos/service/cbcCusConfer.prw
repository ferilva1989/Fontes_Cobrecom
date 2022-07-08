#include 'TOTVS.ch'

class cbcCusConfer
    method newcbcCusConfer() constructor 
    method esXContab()
    method esXBalancete()
    method esXModelo7()
endClass

method newcbcCusConfer() class cbcCusConfer
return(self)


method esXContab(cFrm, cWho, aExclude, aMainMdl) class cbcCusConfer
    local nPosFrm    as numeric
    local nPosWho    as numeric
    local nPos       as numeric
    local nPosY      as numeric
    local nX         as numeric
    local nY         as numeric
    local nDif       as numeric
    local cMsg       as character
    local linha	     as character
    local aRet       as array
    default aExclude := {}
    
    aRet := {}
    linha := chr(13) + chr(10)
    if (nPosWho := aScan( aMainMdl, {|x| lower(Alltrim(x:CNAME)) == lower(Alltrim(cWho)) }) ) > 0
        if (nPosFrm := aScan( aMainMdl, {|x| lower(Alltrim(x:CNAME)) == lower(Alltrim(cFrm)) }) ) > 0
            
            for nX := 1 to len(aMainMdl[nPosFrm]:AMOVS)
                if empty(aScan( aExclude, {|x| lower(Alltrim(x)) == lower(Alltrim(aMainMdl[nPosFrm]:AMOVS[nX]:CMOVID)) }))
                    if (nPos := aScan( aMainMdl[nPosWho]:AMOVS, {|x| lower(Alltrim(x:CMOVID)) == lower(Alltrim(aMainMdl[nPosFrm]:AMOVS[nX]:CMOVID)) }) ) > 0
                        for nY := 1 to len(aMainMdl[nPosFrm]:AMOVS[nX]:APROD)
                            if (nPosY := aScan( aMainMdl[nPosWho]:AMOVS[nPos]:APROD, {|x| lower(Alltrim(x:CTIPO)) == lower(Alltrim(aMainMdl[nPosFrm]:AMOVS[nX]:APROD[nY]:CTIPO)) }) ) > 0                
                                nDif := ABS(aMainMdl[nPosFrm]:AMOVS[nX]:APROD[nY]:NVALOR) - ABS(aMainMdl[nPosWho]:AMOVS[nPos]:APROD[nPosY]:NVALOR)
                                if ABS(nDif) > 0                 
                                        cMsg := "MOVIMENTO: "    + aMainMdl[nPosFrm]:AMOVS[nX]:CMOVID + linha
                                        cMsg += "TIPO: "         + aMainMdl[nPosFrm]:AMOVS[nX]:APROD[nY]:CTIPO + linha
                                        cMsg +=  aMainMdl[nPosFrm]:CNAME + linha
                                        cMsg += "VALOR: "        + cValToChar(aMainMdl[nPosFrm]:AMOVS[nX]:APROD[nY]:NVALOR) + linha
                                        cMsg +=  aMainMdl[nPosWho]:CNAME + linha
                                        cMsg += "VALOR: "        + cValToChar(aMainMdl[nPosWho]:AMOVS[nPos]:APROD[nPosY]:NVALOR)
                                        cMsg += "Diferença: "    + cValToChar(nDif)
                                        aadd(aRet,cMsg)
                                endif
                            endif
                        next nY
                    endif
                endif
            next nX
        endif
    endif
return(aRet)


method esXBalancete(cFrm, cWho, aExclude, aMainMdl) class cbcCusConfer
    local nPosFrm    as numeric
    local nPosWho    as numeric
    local nPos       as numeric
    local nX         as numeric
    local nY         as numeric
    local nDif       as numeric
    local cIdMov     as character
    local aRet       as array
    local aFrmSld    as array
    local aFrmInit   as array
    local cMsg       as character
    local linha      as character
    default aExclude := {}

    aFrmSld     := {}
    aFrmInit    := {}
    aRet        := {}
    linha       := chr(13) + chr(10)
    if (nPosWho := aScan( aMainMdl, {|x| lower(Alltrim(x:CNAME)) == lower(Alltrim(cWho)) }) ) > 0
        if (nPosFrm := aScan( aMainMdl, {|x| lower(Alltrim(x:CNAME)) == lower(Alltrim(cFrm)) }) ) > 0
            // Loop obter saldos Origem ES
            for nX := 1 to len(aMainMdl[nPosFrm]:AMOVS)
                 cIdMov := aMainMdl[nPosFrm]:AMOVS[nX]:CMOVID
                 for nY := 1 to len(aMainMdl[nPosFrm]:AMOVS[nX]:APROD)
                    if Alltrim(cIdMov) == 'saldo inicial'
                        if (nPos := aScan( aFrmInit, {|x| lower(Alltrim(x[1])) == lower(Alltrim(aMainMdl[nPosFrm]:AMOVS[nX]:APROD[nY]:CTIPO)) }) ) > 0
                            aFrmInit[nPos][2] += ajuNum(aMainMdl[nPosFrm]:AMOVS[nX]:APROD[nY]:NVALOR, cIdMov)
                        else
                            aadd(aFrmInit, {aMainMdl[nPosFrm]:AMOVS[nX]:APROD[nY]:CTIPO,;
                                        ajuNum(aMainMdl[nPosFrm]:AMOVS[nX]:APROD[nY]:NVALOR, cIdMov)})
                        endif
                    endif
                    if (nPos := aScan( aFrmSld, {|x| lower(Alltrim(x[1])) == lower(Alltrim(aMainMdl[nPosFrm]:AMOVS[nX]:APROD[nY]:CTIPO)) }) ) > 0
                        aFrmSld[nPos][2] += ajuNum(aMainMdl[nPosFrm]:AMOVS[nX]:APROD[nY]:NVALOR, cIdMov)
                    else
                        aadd(aFrmSld, {aMainMdl[nPosFrm]:AMOVS[nX]:APROD[nY]:CTIPO,;
                                        ajuNum(aMainMdl[nPosFrm]:AMOVS[nX]:APROD[nY]:NVALOR, cIdMov)})
                    endif
                 next nY
            next nX
            // Comparar saldo destino
            for nX := 1 to len(aMainMdl[nPosWho]:AMOVS)
                if aMainMdl[nPosWho]:AMOVS[nX]:CMOVID == 'saldo inicial' .Or. aMainMdl[nPosWho]:AMOVS[nX]:CMOVID == 'saldo final'
                   for nY := 1 to len(aMainMdl[nPosWho]:AMOVS[nX]:APROD)
                     if aMainMdl[nPosWho]:AMOVS[nX]:CMOVID == 'saldo inicial'
                        if (nPos := aScan( aFrmInit, {|x| lower(Alltrim(x[1])) == lower(Alltrim(aMainMdl[nPosWho]:AMOVS[nX]:APROD[nY]:CTIPO)) }) ) > 0
                            nDif := ABS(aFrmInit[nPos][2]) - ABS(aMainMdl[nPosWho]:AMOVS[nX]:APROD[nY]:NVALOR)
                            if ABS(nDif) > 0
                                cMsg := ""
                                cMsg += 'Diferença ES x Balancete:' + linha
                                cMsg += aMainMdl[nPosWho]:AMOVS[nX]:CMOVID + linha
                                cMsg += 'TIPO: '        + aMainMdl[nPosWho]:AMOVS[nX]:APROD[nY]:CTIPO + linha
                                cMsg += 'ES: '          + cValToChar(aFrmInit[nPos][2]) + linha
                                cMsg += 'Balancete: '   + cValToChar(aMainMdl[nPosWho]:AMOVS[nX]:APROD[nY]:NVALOR) + linha
                                cMsg += 'Diferença: '   + cValToChar(nDif) + linha
                                aadd(aRet, cMsg)
                            endif
                        endif
                     elseif aMainMdl[nPosWho]:AMOVS[nX]:CMOVID == 'saldo final'
                        if (nPos := aScan( aFrmSld, {|x| lower(Alltrim(x[1])) == lower(Alltrim(aMainMdl[nPosWho]:AMOVS[nX]:APROD[nY]:CTIPO)) }) ) > 0
                            nDif := ABS(aFrmSld[nPos][2]) - ABS(aMainMdl[nPosWho]:AMOVS[nX]:APROD[nY]:NVALOR)
                            if  ABS(nDif) > 0
                                cMsg := ""
                                cMsg += 'Diferença ES x Balancete:' + linha
                                cMsg += aMainMdl[nPosWho]:AMOVS[nX]:CMOVID + linha
                                cMsg += 'TIPO: '        + aMainMdl[nPosWho]:AMOVS[nX]:APROD[nY]:CTIPO + linha
                                cMsg += 'ES: '          + cValToChar(aFrmSld[nPos][2]) + linha
                                cMsg += 'Balancete: '   + cValToChar(aMainMdl[nPosWho]:AMOVS[nX]:APROD[nY]:NVALOR) + linha
                                cMsg += 'Diferença: '   + cValToChar(nDif) + linha
                                aadd(aRet, cMsg)
                            endif
                        endif
                     endif
                   next nY 
                endif
            next nX
        endif
    else
        aadd(aRet, 'Comparação não encontrada: ' + cWho)
    endif

return(aRet)


method esXModelo7(cFrm, cWho, aExclude, aMainMdl) class cbcCusConfer
    local nPosFrm    as numeric
    local nPosWho    as numeric
    local nPos       as numeric
    local nX         as numeric
    local nY         as numeric
    local nDif       as numeric
    local aRet       as array
    local aFrmSld    as array
    local cMsg       as character
    local linha      as character
    default aExclude := {}
    
    aFrmSld := {}
    aRet    := {}
    linha   := chr(13) + chr(10)
    if (nPosWho := aScan( aMainMdl, {|x| lower(Alltrim(x:CNAME)) == lower(Alltrim(cWho)) }) ) > 0
        if (nPosFrm := aScan( aMainMdl, {|x| lower(Alltrim(x:CNAME)) == lower(Alltrim(cFrm)) }) ) > 0
            // Loop obter saldoFinal Origem ES
            for nX := 1 to len(aMainMdl[nPosFrm]:AMOVS)
                 cIdMov := aMainMdl[nPosFrm]:AMOVS[nX]:CMOVID
                 for nY := 1 to len(aMainMdl[nPosFrm]:AMOVS[nX]:APROD)
                    if (nPos := aScan( aFrmSld, {|x| lower(Alltrim(x[1])) == lower(Alltrim(aMainMdl[nPosFrm]:AMOVS[nX]:APROD[nY]:CTIPO)) }) ) > 0
                        aFrmSld[nPos][2] += ajuNum(aMainMdl[nPosFrm]:AMOVS[nX]:APROD[nY]:NVALOR, cIdMov)
                    else
                        aadd(aFrmSld, {aMainMdl[nPosFrm]:AMOVS[nX]:APROD[nY]:CTIPO,;
                                      ajuNum(aMainMdl[nPosFrm]:AMOVS[nX]:APROD[nY]:NVALOR, cIdMov)})
                    endif
                 next nY
            next nX
            for nX := 1 to len(aMainMdl[nPosWho]:AMOVS)
                if aMainMdl[nPosWho]:AMOVS[nX]:CMOVID == 'est'
                   for nY := 1 to len(aMainMdl[nPosWho]:AMOVS[nX]:APROD)
                     if (nPos := aScan( aFrmSld, {|x| lower(Alltrim(x[1])) == lower(Alltrim(aMainMdl[nPosWho]:AMOVS[nX]:APROD[nY]:CTIPO)) }) ) > 0
                        nDif := ABS(aFrmSld[nPos][2]) - ABS(aMainMdl[nPosWho]:AMOVS[nX]:APROD[nY]:NVALOR)
                        if ABS(nDif)> 0
                            cMsg := ""
                            cMsg += 'Diferença ES x Modelo7:' + linha
                            cMsg += 'TIPO: '        + aMainMdl[nPosWho]:AMOVS[nX]:APROD[nY]:CTIPO + linha
                            cMsg += 'ES: '          + cValToChar(aFrmSld[nPos][2]) + linha
                            cMsg += 'Modelo7: '     + cValToChar(aMainMdl[nPosWho]:AMOVS[nX]:APROD[nY]:NVALOR) + linha
                            cMsg += 'Diferença: '   + cValToChar(nDif) + linha
                            aadd(aRet, cMsg)
                        endif
                     endif
                   next nY 
                endif
            next nX
        endif
    endif

return(aRet)


static function ajuNum(nNum, cMov)
    local nPos          as numeric
    local aRef          as array
    aRef := {}
    aadd(aRef, {'saldo inicial'     ,'+'})
    aadd(aRef, {'compras'           ,'+'})
    //aadd(aRef, {'mov.interna'       ,'-'})
    aadd(aRef, {'req.p/prod.'       ,'-'})
    aadd(aRef, {'producao'          ,'+'})
    aadd(aRef, {'vendas'            ,'-'})
    aadd(aRef, {'dev.venda'         ,'+'})
    aadd(aRef, {'dev.compras'       ,'-'})
    aadd(aRef, {'entr.poder terc'   ,'+'})
    aadd(aRef, {'saida poder terc'  ,'-'})
    if (nPos := aScan( aRef, {|x| lower(Alltrim(x[1])) == lower(Alltrim(cMov)) }) ) > 0
        nNum := ABS(nNum)
        if aRef[nPos][2] == '-'
            nNum := (nNum * -1)
        endif
    endif
return nNum
