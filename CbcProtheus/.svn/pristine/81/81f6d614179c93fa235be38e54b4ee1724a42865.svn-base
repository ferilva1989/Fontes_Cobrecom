#include 'totvs.ch'
#include 'tbiconn.ch'

/*
Robert Santos
05 abr 2012
Enviar email para o vendedor após ser liberado o cadastro do cliente
Deve estar posicionado na SA1
*/                                    
user function cwf02()

local cpara := lower(trim(posicione("SA3", 1, xfilial("SA3")+M->A1_VEND, "A3_EMAIL" )))
local op , ohtml
local chtml , cassunto  

// parametros de envio
chtml := "\workflow\html\cliente_incluir.htm"     
cassunto := "Cliente liberado!"

op := twfprocess():new( "CWF02" , cassunto )      
op:newtask( "CWF02" , chtml )  
ohtml := op:ohtml

ohtml:valbyname("A1_COD" ,  SA1->A1_COD )
ohtml:valbyname("A1_LOJA" , SA1->A1_LOJA )
ohtml:valbyname("A1_NOME" , trim(SA1->A1_NOME) )
ohtml:valbyname("A1_CGC" , iif( len(SA1->A1_CGC)==14, transform(SA1->A1_CGC, "@R 99.999.999/9999-99") , transform(SA1->A1_CGC, "@R 999.999.999-99") ) )
ohtml:valbyname("A3_NOME" , trim(posicione("SA3", 1, xfilial("SA3")+M->A1_VEND, "A3_NOME" )) )
ohtml:valbyname("MSG" , cassunto )  
ohtml:valbyname("A1_XPOTENC" , transform(SA1->A1_XPOTENC, "@E 99,999,999,999.99") )

// SA1->( dbclosearea() )

op:csubject := cassunto
op:cto := cpara 

op:start()
op:finish()

wfsendmail()

return nil