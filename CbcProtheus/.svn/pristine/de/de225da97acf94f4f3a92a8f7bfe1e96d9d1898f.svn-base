#include 'totvs.ch'
#include 'tbiconn.ch'

/*
Robert Santos
04 abr 2012
Envir email após incluir novo cliente
*/                                    
user function cwf01( ca1_cod, ca1_loja )

local cpara := trim(lower(alltrim(getmv( "MV_CLIAPRV" ))))
local op , ohtml
local chtml , cassunto  

// dados do cliente
dbselectarea("SA1")
SA1->( dbseek(xfilial("SA1")+ca1_cod+ca1_loja) )

// parametros de envio
chtml := "\workflow\html\cliente_incluir.htm"     
cassunto := "Novo cliente incluso pendente de alteração!"

op := twfprocess():new( "CWF01" , cassunto )      
op:newtask( "CWF01" , chtml )  
ohtml := op:ohtml

ohtml:valbyname("A1_COD" , SA1->A1_COD )
ohtml:valbyname("A1_LOJA" , SA1->A1_LOJA )
ohtml:valbyname("A1_NOME" , trim(SA1->A1_NOME) )
ohtml:valbyname("A1_CGC" , iif( len(SA1->A1_CGC)==14, transform(SA1->A1_CGC,"@R 99.999.999/9999-99") , transform(SA1->A1_CGC, "@R 999.999.999-99") ) )
ohtml:valbyname("A3_NOME" , trim(posicione("SA3", 1, xfilial("SA3")+SA1->A1_VEND, "A3_NOME" )) )
ohtml:valbyname("MSG" , cassunto )
ohtml:valbyname("A1_XPOTENC" , transform(SA1->A1_XPOTENC, "@E 99,999,999,999.99") )

SA1->( dbclosearea() )

op:csubject := cassunto
op:cto := cpara 

op:start()
op:finish()

wfsendmail()

return nil