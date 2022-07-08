#include 'totvs.ch'
#include 'tbiconn.ch'

/*
Robert Santos
15 jun 2012
Enviar mensagem com informações do Orçamento
*/                                    
user function cwf03( ccj_num, cmsg, caction, cpara, ca1_cod, ca1_loja )

local op , ohtml
local chtml , cassunto  

// informacoes do cliente
dbselectarea("SA1")
SA1->( dbsetorder(1) )
SA1->( dbseek(xfilial("SA1")+ca1_cod+ca1_loja) )

// parametros de envio
chtml := "\workflow\html\orcamento_msg_action.htm"     
cassunto := cmsg

op := twfprocess():new( "CWF03" , cassunto )      
op:newtask( "CWF03" , chtml )  
ohtml := op:ohtml

ohtml:valbyname("A1_COD" , SA1->A1_COD )
ohtml:valbyname("A1_LOJA" , SA1->A1_LOJA )
ohtml:valbyname("A1_NREDUZ" , trim(SA1->A1_NREDUZ) )
ohtml:valbyname("A3_NOME" , trim(posicione("SA3", 1, xfilial("SA3")+SA1->A1_VEND, "A3_NOME" )) )
ohtml:valbyname("MSG" , cmsg )  
ohtml:valbyname("ACTION" , caction )
ohtml:valbyname("cj_num" , ccj_num )
ohtml:valbyname("a3_cod" , posicione("SA3", 1, xfilial("SA3")+SA1->A1_VEND, "A3_COD" ) )

SA1->( dbclosearea() )

op:csubject := cassunto
op:cto := cpara 

op:start()
op:finish()

wfsendmail()

return nil