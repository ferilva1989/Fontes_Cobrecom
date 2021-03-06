#include "protheus.ch" 

/*{Protheus.doc} MA960GREC
Ponto de Entrada para preenchimento dos campos F6_TIPOGNU, F6_DOCORIG, 
F6_DETRECE e F6_CODPROD de acordo com o c?digo de receita e UF.
*/
user function MA960GREC() 
    local aParam    := {}//Par?metros com valores para o estado SX6
    local aRet      := {0, '', '', 0, ''}//Par?metros de retorno default
    local cReceita  := PARAMIXB[1]//C?digo de Receita da guia atual
    local cUF       := PARAMIXB[2]//Sigla da UF da guia atual
    local cParam    := ''
    local nPos      := 0

    cParam := SUPERGETMV ("ZZ_GNRE2" + AllTrim(cUF),.T.,"")

    if !empty(cParam)
        aParam := &cParam
        if len(aParam) > 0
            if ValType(aParam[1]) <> "A"
                //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o c?digo de receita e sigla da UF da guia atual.
                aRet := {aParam[01], AllTrim(Str(aParam[02])), DetReceita("MV_DETGNR",cUF,cReceita), VAL(ProdGnre(cUF)), ''}
            else
                nPos := AScan(aParam,{|x| cValToChar(x[1]) == AllTrim(cReceita)})
                if nPos > 0
                    //Retorna os campos F6_TIPOGNU, F6_DOCORIG, F6_DETRECE, F6_CODPROD e F6_CODAREA de acordo com o c?digo de receita e sigla da UF da guia atual.
                    aRet := {aParam[nPos, 02], AllTrim(Str(aParam[nPos, 03])), DetReceita("MV_DETGNR",cUF,cReceita), VAL(ProdGnre(cUF)), ''}
                endif
            endif
        endif
    endif
return(aRet)

user function zGNREParCfg()
    local aToDo := {;
                    {'ZZ_GNRE2AC', '{10,1}'},;
                    {'ZZ_GNRE2AL', '{10,1}'},;
                    {'ZZ_GNRE2AP', '{10,1}'},;
                    {'ZZ_GNRE2BA', '{10,1}'},;
                    {'ZZ_GNRE2CE', '{10,1}'},;
                    {'ZZ_GNRE2DF', '{10,1}'},;
                    {'ZZ_GNRE2GO', '{10,1}'},;
                    {'ZZ_GNRE2MA', '{10,1}'},;
                    {'ZZ_GNRE2MG', '{10,1}'},;
                    {'ZZ_GNRE2MS', '{10,1}'},;
                    {'ZZ_GNRE2MT', '{10,1}'},;
                    {'ZZ_GNRE2PA', '{10,1}'},;
                    {'ZZ_GNRE2PB', '{10,1}'},;
                    {'ZZ_GNRE2PI', '{10,1}'},;
                    {'ZZ_GNRE2PR', '{10,1}'},;
                    {'ZZ_GNRE2RN', '{10,1}'},;
                    {'ZZ_GNRE2RO', '{10,1}'},;
                    {'ZZ_GNRE2RR', '{10,1}'},;
                    {'ZZ_GNRE2SE', '{10,1}'},;
                    {'ZZ_GNRE2TO', '{10,1}'},;
                    {'ZZ_GNRE2AM', '{22,2}'},;
                    {'ZZ_GNRE2PE', '{22,2}'},;
                    {'ZZ_GNRE2RS', '{22,2}'};
                    }
    local nX := 0

    DbSelectArea("SX6") //Abre a tabela SX6
    SX6->(DbSetOrder(1)) //Se posiciona no primeiro indice
    for nX := 1 to len(aToDo)
        If !DbSeek('  '+aToDo[nX, 01]) //Verifique se o parametro existe
            RecLock("SX6",.T.) //Se nao existe, criar o registro
                SX6->X6_FIL     := '  '
                SX6->X6_VAR     := aToDo[nX, 01]
                SX6->X6_TIPO    := "C"
                SX6->X6_DESCRIC := "Valores a serem preenchidos"
                SX6->X6_DESC1   := " via PE MA960GREC aos campos"
                SX6->X6_DESC2   := " F6_TIPOGNU e F6_DOCORIG para GNRE 2"
                SX6->X6_CONTEUD := aToDo[nX, 02]
                SX6->X6_CONTSPA := aToDo[nX, 02]
                SX6->X6_CONTENG := aToDo[nX, 02]
            MsUnLock() //salva o registro com as informa??es passada
        Else
            RecLock("SX6",.F.) //Abre o registro para edi??o
                SX6->X6_CONTEUD := aToDo[nX, 02]
                SX6->X6_CONTSPA := aToDo[nX, 02]
                SX6->X6_CONTENG := aToDo[nX, 02]
            MsUnLock() //salva o registro
        EndIf
    next nX
return(nil)
