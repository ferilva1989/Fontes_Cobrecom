#include 'totvs.ch'
#include 'topconn.ch'

/*
Robert Santos
23.07.13
EXECUTADO ANTES DE DELETAR SC5
*/
user function MA410DEL()

ATUVTEX()

return nil

static function ATUVTEX()

local cQry, nQry

// atualizar tabela orçamentos site
cqry := " update "+RetSqlName("ZZJ")+CRLF
cqry += " set ZZJ_C5NUM = '' "+CRLF
cqry += " where D_E_L_E_T_ = ' ' "+CRLF
cqry += " and ZZJ_C5NUM = '"+SC5->C5_NUM+"' "+CRLF
if tcSqlExec(cQry) < 0
	Alert("Erro ao atualizar tabela de integração do site")
endif

return