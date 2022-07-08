user function cbcCustBal(cDtDe,cDtAte)
    
    local cDataDe       as character
    local dDataFim      as character
    local cContaIni     as character
    local cContaFim     as character
    local cMoeda        as character
    local cSaldos       as character
    local nQuebra       as numeric
    local oMeter        as object
    local oText         as object
    local oDlg          as object
    local lEnd          as logical
    local aSetOfBook    as array
    local lImpSint      as logical
    local dDtZeraRD     as character
    local aSelFil       as array
    local aCtaRef       as array
    local aAuxCta       as array
    local nPos          as numeric
    local nX            as numeric
    local nY            as numeric
    local cArqTmp       as character

    aCtaRef := {}
    /* 
        ME DE TERCEIROS
        PA DE TECEIROS
     */
    aAuxCta := {}
    aadd(aAuxCta, {'ME',{'113140000'}})
    aadd(aAuxCta, {'PA',{'113200000'}})

    aadd(aCtaRef, {'113060000','ME','',0,0,0,0,0})
    aadd(aCtaRef, {'113040000','MP','',0,0,0,0,0})
    aadd(aCtaRef, {'113100000','OI','',0,0,0,0,0})
    aadd(aCtaRef, {'113010000','PA','',0,0,0,0,0})
    aadd(aCtaRef, {'113050000','PI','',0,0,0,0,0})
    aadd(aCtaRef, {'113090000','SC','',0,0,0,0,0})
    aadd(aCtaRef, {'113080000','SV','',0,0,0,0,0})
    aadd(aCtaRef, {'113070000','MR','',0,0,0,0,0})

    oMeter      := nil
    oText       := nil
    oDlg        := nil
    lEnd        := .F.
    cArqTmp     := ''
    aSetOfBook  := CTBSetOf('')
    cDataDe     := StoD(cDtDe)
    dDataFim    := StoD(cDtAte)
    cContaIni   := ''
    cContaFim   := 'ZZZZZZZZZ'
    cMoeda      := '01'
    cSaldos     := '1'
    nQuebra     := 2
    lImpSint    := .T.
    dDtZeraRD   := StoD(GetNewPar('ZM_CUSRD', '20201231'))
    aSelFil     := {fwFilial()}

    CTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				cDataDe,dDataFim,"CT7","",cContaIni,cContaFim,,,,,,,cMoeda,;
				cSaldos,aSetOfBook,"","","","",;
				.F.,.F.,nQuebra,,.F.,"",1,.F.,,,,,,,,,,,,,,lImpSint,"",.F.,;
				"",dDtZeraRD,,,,,,,'01',,aSelFil)
    
    dbSelectArea("cArqTmp")
    cArqTmp->(dbGoTop())
    While !cArqTmp->(Eof())
         if  (nPos := aScan( aCtaRef, {|x| Alltrim(x[1]) == Alltrim(cArqTmp->(CONTA)) }) ) 
            aCtaRef[nPos][3] := cArqTmp->(Alltrim(DESCCTA))
            aCtaRef[nPos][4] := cArqTmp->(SALDOANT)
            aCtaRef[nPos][5] := cArqTmp->(SALDODEB)
            aCtaRef[nPos][6] := cArqTmp->(SALDOCRD)
            aCtaRef[nPos][7] := cArqTmp->(MOVIMENTO)
            aCtaRef[nPos][8] := cArqTmp->(SALDOATU)
         endif
        cArqTmp->(dbskip())
    enddo

    for nX := 1 to len(aAuxCta)
          if (nPos := aScan( aCtaRef, {|x| Alltrim(x[2]) == Alltrim(aAuxCta[nX][1]) }) ) 
            for nY := 1 to len(aAuxCta[nX][2])
                cArqTmp->(DbEval({||evlValue(aAuxCta[nX][2][nY], @aCtaRef[nPos] )}) )
            next nY
          endif
    next nX

    cArqTmp->(dbCloseArea())

return aCtaRef


static function evlValue(cSearch, aCtaRef)
    if Alltrim(CONTA) == Alltrim(cSearch)
        aCtaRef[4] += SALDOANT
        aCtaRef[5] += SALDODEB
        aCtaRef[6] += SALDOCRD
        aCtaRef[7] += MOVIMENTO
        aCtaRef[8] += SALDOATU
    endif
return nil
