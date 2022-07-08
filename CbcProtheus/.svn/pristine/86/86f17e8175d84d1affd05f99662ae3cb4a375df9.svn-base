#include 'protheus.ch'

user function MY415AUT()

local lRet := .T.

if !EMPTY(SCJ->CJ_XZZJID)
	dbselectarea("ZZJ")
	ZZJ->(dbsetorder(1))
	if ZZJ->(DBSEEK(XFILIAL("ZZJ") + SCJ->CJ_XZZJID ))
		if ZZJ->ZZJ_STATUS <> "G" // ACEITO PELO CLIENTE
			Alert("Você não pode baixar o orçamento enquanto o vendedor não confirmar o aceite do cliente no Portal!")
			lRet := .f.
		endif
	else
		Alert("Orçamento web nao encontrado!")
		lRet := .f.
	endif
endif

return lRet
