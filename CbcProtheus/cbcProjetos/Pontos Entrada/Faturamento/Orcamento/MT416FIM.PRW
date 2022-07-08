#include 'protheus.ch'

// Apos baixar o orcamento em pedido de vendas
user function MT416FIM

if !EMPTY(SCJ->CJ_XZZJID)
	dbselectarea("ZZJ")
	ZZJ->(dbsetorder(1))
	if( ZZJ->(dbseek(xFilial("ZZJ") + SCJ->CJ_XZZJID )) )
		ZZJ->(reclock("ZZJ",.f.))
		ZZJ->ZZJ_C5NUM := SC5->C5_NUM
		ZZJ->(msunlock())
	endif
endif

return