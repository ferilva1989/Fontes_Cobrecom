#include 'totvs.ch'
#include 'tbiconn.ch'

/*
Robert Santos
15 jun 2012
Enviar mensagem com Orçamento incluido para abrir OP
*/
user function cwf04( la1_opened, la3_opened )

local op , ohtml
local chtml , cassunto
local cpara := alltrim(lower(getmv("MV_XFATURA"))) // alltrim(lower(getmv("MV_XPRODUC")))
local valor := 0

// parametros de envio
chtml := "\workflow\html\gerar_op.htm"
cassunto := "Orçamento gerado, através do Portal do Representante."

op := twfprocess():new( "CWF04" , cassunto )
op:newtask( "CWF04" , chtml )
ohtml := op:ohtml

ohtml:valbyname("CJ_NUM" , trim( SCJ->CJ_NUM) )

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
		ohtml:valbyname("A3_NOME" , trim(posicione("SA3", 1, xfilial("SA3") + SA1->A1_VEND, "A3_NOME" )) )
	endif
endif


while !SCK->(EOF()) .and. SCJ->CJ_NUM == SCK->CK_NUM
	aadd(	ohtml:valbyname("t1.1") , trim(SCK->CK_ITEM) ) // item
	aadd(	ohtml:valbyname("t1.2") , trim(SCK->CK_PRODUTO) ) // prod
	aadd(	ohtml:valbyname("t1.3") , trim(SCK->CK_DESCRI) ) // descri
	aadd(	ohtml:valbyname("t1.4") , transform((SCK->CK_QTDVEN),"@E 999999999.99") ) // QTDE
	aadd(	ohtml:valbyname("t1.5") , transform(SCK->CK_PRCVEN,"@E 999,999,999.99") ) // TOTAL
	aadd(	ohtml:valbyname("t1.6") , transform(SCK->CK_PRCVEN*SCK->CK_QTDVEN,"@E 999,999,999.99") ) //
	aadd(	ohtml:valbyname("t1.7") , u_XdeAcond( trim(SCK->CK_ACONDIC) ) ) //
	aadd(	ohtml:valbyname("t1.8") , transform((SCK->CK_LANCES),"@E 999999999.99") ) //
	aadd(	ohtml:valbyname("t1.9") , transform((SCK->CK_METRAGE),"@E 999999999.99") ) //
	
	valor += (SCK->CK_PRCVEN*SCK->CK_QTDVEN)
	
	SCK->( dbskip() )
enddo

ohtml:valbyname("VALOR" , transform( valor, "@E 999,999,999.99" ) )

op:csubject := cassunto
op:cto := cpara

op:start()
op:finish()

wfsendmail()

return nil
