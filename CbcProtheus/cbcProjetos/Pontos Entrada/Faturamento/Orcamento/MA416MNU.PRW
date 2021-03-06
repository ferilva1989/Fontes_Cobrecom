#include 'protheus.ch'

user function MA416MNU

aadd( aRotina, { "Desbloq.Web" ,"u_416MNUa" , 0 , 2 , 0 } )

return nil

user function 416MNUa()

local aButton := {}
local nxOpc := 0

if( !EMPTY(SCJ->CJ_XZZJID) )
	if(SCJ->CJ_STATUS=="G")
		dbselectarea("ZZJ")
		ZZJ->(dbsetorder(1))
		
		aadd( aButton ,  "Liberar" )
		aadd( aButton ,  "Rejeitar" )
		aadd( aButton ,  "Cancelar" )
		
		cMsg := "O or�amento foi aprovado pelo cliente, selecione sua decis�o!"
		
		nxOpc := Aviso("An�lise do Or�amento" , cMsg , aButton )
		do case
			case nxOpc == 1
				SCJ->(RECLOCK("SCJ"), .F.)
				SCJ->(CJ_STATUS) := "A"
				SCJ->(MSUNLOCK())
			case nxOpc == 2
				SCJ->(RECLOCK("SCJ"), .F.)
				SCJ->(CJ_STATUS) := "C"
				SCJ->(MSUNLOCK())
				
				if ZZJ->(DBSEEK(XFILIAL("ZZJ") + SCJ->CJ_XZZJID ))
					ZZJ->(RECLOCK("ZZJ"), .F.)
					ZZJ->(ZZJ_STATUS) := "R"
					ZZJ->(MSUNLOCK())
				endif
			case nxOpc == 3
		endcase
	else
		Alert("Or�amento precisa ser aprovado pelo cliente!")
	endif
else
	Alert("S� para or�amento WEB")
endif

return
