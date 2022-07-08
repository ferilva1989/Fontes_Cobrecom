#include 'totvs.ch'
#include 'tbiconn.ch'

/*
Robert Santos
15 jun 2012
Enviar mensagem com Pedido Venda incluido
*/
user function cwf05( la1_opened, la3_opened )

local op , ohtml
local chtml , cassunto
local cpara := alltrim(lower(getmv("MV_XFATURA")))
local cCC := ""
local valor := 0

// parametros de envio
chtml := "\workflow\html\faturar.htm"
cassunto := "Pedido de venda incluido via Site."

op := twfprocess():new( "CWF05" , cassunto )
op:newtask( "CWF05" , chtml )
ohtml := op:ohtml

ohtml:valbyname("C5_NUM" , SC5->C5_NUM )
if la1_opened
	ohtml:valbyname("A1_COD" , SA1->A1_COD )
	ohtml:valbyname("A1_LOJA" , SA1->A1_LOJA )
	ohtml:valbyname("A1_NREDUZ" , trim(SA1->A1_NREDUZ) )
	ohtml:valbyname("A1_EMAIL" , trim(SA1->A1_EMAIL) )
	ohtml:valbyname("A1_TEL" , trim(SA1->A1_TEL) )
endif

if la3_opened
	ohtml:valbyname("A3_COD" , trim( SA3->A3_COD) )
	ohtml:valbyname("A3_EMAIL" , trim( SA3->A3_EMAIL) )
	ohtml:valbyname("A3_TEL" , trim( SA3->A3_TEL) )
	if la1_opened
		ohtml:valbyname("A3_NOME" , trim(posicione("SA3", 1, xfilial("SA3")+SA1->A1_VEND, "A3_NOME" )) )
	endif 
	
	cCC := lower(alltrim(SA3->A3_EMAIL))
endif


while !SC6->(EOF()) .and. SC5->C5_NUM == SC6->C6_NUM
	aadd(	ohtml:valbyname("t1.1") , trim(SC6->C6_ITEM) ) // item
	aadd(	ohtml:valbyname("t1.2") , trim(SC6->C6_PRODUTO) ) // prod
	aadd(	ohtml:valbyname("t1.3") , trim(SC6->C6_DESCRI) ) // descri
	aadd(	ohtml:valbyname("t1.4") , transform((SC6->C6_QTDVEN),"@E 999999999.99") ) // QTDE
	aadd(	ohtml:valbyname("t1.5") , transform(SC6->C6_PRCVEN,"@E 999,999,999.99") ) // TOTAL
	aadd(	ohtml:valbyname("t1.6") , transform(SC6->C6_VALOR,"@E 999,999,999.99") ) //
	aadd(	ohtml:valbyname("t1.7") , decAcond( trim(SC6->C6_ACONDIC) ) ) //
	aadd(	ohtml:valbyname("t1.8") , transform((SC6->C6_LANCES),"@E 999999999.99") ) //
	aadd(	ohtml:valbyname("t1.9") , transform((SC6->C6_METRAGE),"@E 999999999.99") ) //
	
	valor += SC6->C6_VALOR
	
	SC6->( dbskip() )
enddo

ohtml:valbyname("VALOR" , transform( valor, "@E 999,999,999.99" ) )

op:csubject := cassunto
op:cto := cpara
op:cCC := cCC

op:start()
op:finish()

wfsendmail()

return nil

static function decAcond( cacondic )

do case
	case cacondic == "B"
		cacondic := "Bobina"
	case cacondic == "R"
		cacondic := "Rolo"
	case cacondic == "C"
		cacondic := "Carretel"
	case cacondic == "T"
		cacondic := "Retalho"
	case cacondic == "M"
		cacondic := "Carretel Madeira"
endcase

return cacondic
