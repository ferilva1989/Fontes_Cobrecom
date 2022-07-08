#include 'totvs.ch'

/*
ROBERT SANTOS
08 DE AGOSTO DE 2012
RETORNAR FAIXA DE DESCONTOS PARA CALCULOS NO SITE, VINDOS DA CARTA DE DESCONTO
*/
user function STVLD03( ca1_cod, ca1_loja, ca3_cod )

local acarta := {} // faixas de desconto  
local aaux := {}
/*
// exemplo:
acarta[1] == "50+15+20"
acarta[2] == "50+15+30"
acarta[3] == "50+15+45"
*/
local cda0_codtab := ""

// Resgatar codigo da tabela de precos
dbselectarea("SA1")
SA1->( dbsetorder(1) )
if SA1->( dbseek(xfilial("SA1")+padr(ca1_cod+ca1_loja, 8)) )
	cda0_codtab := alltrim(SA1->A1_TABELA)
	if empty(cda0_codtab)
		dbselectarea("SA3")
		SA3->( dbsetorder(1))
		if SA3->( dbseek(xfilial("SA3")+padr(ca3_cod,6)) )
			cda0_codtab := alltrim( SA3->A3_TABELA )
		endif
	endif
endif
SA1->( dbclosearea() )
iif( select("SA3")>0 , SA3->( dbclosearea() ), )

// pegar o codigo da carta de desconto
dbselectarea("SZX")
SZX->( dbsetorder(2) )
if( SZX->( dbseek(xfilial("SZX")+padr(cda0_codtab,3)) ) )
	dbselectarea("SZY")
	SZY->(dbsetorder(1))
	if( SZY->(dbseek(xfilial("SZY")+ padr(SZX->ZX_CARTA,3))) )
		while( SZX->ZX_CARTA == SZY->ZY_CODIGO .and. !SZY->(eof()))
			//aadd( acarta, padl(SZY->ZY_DESCONT,2,'0') )
			aadd( aaux, { alltrim(SZY->ZY_DESCONT) , SZY->ZY_ITEM } )
			SZY->(dbskip())
		enddo
	endif  
	
	if len(aaux) > 0
		aaux := aSort( aaux , , , {|x,y| x[2] > y[2] })
		ni:= 0
		for ni:= 1 to len(aaux)
			aadd( acarta, aaux[ni][1] )
		next
	endif
endif

return acarta
