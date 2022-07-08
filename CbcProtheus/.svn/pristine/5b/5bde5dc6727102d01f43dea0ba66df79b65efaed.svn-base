#include 'protheus.ch'
#include 'tbiconn.ch'

/*
Nome: Robert Santos
Data: 08 ago 2012
Desc: Enviar email para o representante do faturamento do pedido dele
*/
user function CWF12(aemail,_cModMail)

local ni := 0
local cassunto := "Faturamento. Documento: " + SF2->F2_DOC
local cpara := ALLTRIM(SA3->A3_EMAIL)
local citem := "00"

private op, ohtml, ccodprocesso, chtmlmodelo

ccodprocesso := "envio"             
If _cModMail == "V" // Venda
	chtmlmodelo	:= "\workflow\html\cwf12.htm"
Else
	chtmlmodelo	:= "\workflow\html\cwf12_3L.htm"
EndIf
op := twfprocess():new(ccodprocesso, cassunto)
op:newtask("CWF12", chtmlmodelo)   
	
ohtml := op:ohtml
ohtml:valbyname("F2_DOC", SF2->F2_DOC ) 
ohtml:valbyname("F2_SERIE", SF2->F2_SERIE )
ohtml:valbyname("F2_EMISSAO", DTOC(SF2->F2_EMISSAO) )

ohtml:valbyname("A3_NOME", SA3->A3_NOME )

ohtml:valbyname("A1_NOME", SA1->A1_NOME )
ohtml:valbyname("A1_COD", SA1->A1_COD )
ohtml:valbyname("A1_LOJA", SA1->A1_LOJA )
ohtml:valbyname("A1_EMAIL", LOWER(SA1->A1_EMAIL) )

for ni := 1 to len(aemail)	
	citem := soma1( citem )
	
	aadd(	ohtml:valbyname("t1.1") , aemail[ni][01] ) // item
	aadd(	ohtml:valbyname("t1.2") , aemail[ni][02] ) // codigo
	aadd(	ohtml:valbyname("t1.3") , aemail[ni][03] ) // desc
	aadd(	ohtml:valbyname("t1.4") , transform(aemail[ni][04],"@e 999,999.99")  ) // qtd
	aadd(	ohtml:valbyname("t1.5") ,  transform(aemail[ni][05],"@e 99,999.9999")   ) //prc
	aadd(	ohtml:valbyname("t1.6") ,  transform(aemail[ni][06],"@e 999,999.99")   ) //tot
	aadd(	ohtml:valbyname("t1.7") ,  dtoc( aemail[ni][07])   ) //emissao	
	aadd(	ohtml:valbyname("t1.8") ,  aemail[ni][08] ) //pedido
	// Inicio - By Roberto Oliveira - 22/09/16
	If _cModMail == "T" // Transferência
		aadd(	ohtml:valbyname("t1.9") , transform(aemail[ni][09], "@R XXXXXX-XX") ) // Pedido Destino
		aadd(	ohtml:valbyname("t1.10") , aemail[ni][10] ) // Cliente Destino
	EndIf
	// Fim - By Roberto Oliveira - 22/09/16
next

op:csubject := cassunto
if !empty( cpara )
	op:cto := RTRIM(cpara) + If(_cModMail == "T",";rene@cobrecom.com.br","") // Transferência
	op:CCC := "wfti@cobrecom.com.br"
else
	op:csubject := cassunto + " O e-mail do vendedor está sem preenchimento!!"
	op:cto := "wfti@cobrecom.com.br" + If(_cModMail=="T",";rene@cobrecom.com.br","") // Transferência
endif

op:start()
op:finish()

wfsendmail()

return
