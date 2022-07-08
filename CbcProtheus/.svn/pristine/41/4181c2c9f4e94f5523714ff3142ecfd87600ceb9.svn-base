#INCLUDE 'PROTHEUS.CH'

USER FUNCTION MT415EFT

LOCAL	lRET := .T.
public	__lGetWeb := .F.

if !EMPTY(SCJ->CJ_XZZJID)
	ZZJ->(dbsetorder(1))
	if( ZZJ->(dbseek(xFilial("ZZJ") + SCJ->CJ_XZZJID )) )
		__lGetWeb := .T. // SERA ENVIADO DADOS NO MATA410 ATRAVES DO PONTO M410INIC
	endif
endif

RETURN lRET