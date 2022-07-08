#INCLUDE "PROTHEUS.CH"

User Function AGRUPDTB(_cTab)

    If (ChkFile(_cTab))
        __SetX31Mode(.F.)

        If Select(_cTab) > 0
            dbSelectArea(_cTab)
            dbCloseArea()
        EndIf

        X31UpdTable(_cTab)

        If __GetX31Error()
            Alert("Erro ao executar o X31UPDTABLE('" + _cTab + "'): " + CRLF + __GetX31Trace())
        Else
            MsgInfo("Execucao do X31UPDTABLE('" + _cTab + "') executada com sucesso!")
        EndIf

        __SetX31Mode(.T.)
    Else
        Alert("Tabela [" + _cTab + "] não encontrada!")
    EndIf

Return(.T.)