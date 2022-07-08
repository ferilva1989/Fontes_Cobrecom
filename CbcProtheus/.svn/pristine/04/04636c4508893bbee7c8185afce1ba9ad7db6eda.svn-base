#include 'protheus.ch'
#include 'tbiconn.ch'

/*	Nome: Robert Santos
Data: 03 juL 2012
Desc: RELATORIO DE WORKFLOW PARA CLIENTES DEVE ESTAR POSICIONADO NO ORCAMENTO SCJ	*/
user function CWF10( lmodo )

local i := 0
local cassunto := "Orçamento "+SCJ->CJ_NUM
local cpara := ""
local lok := .t. // ok

private op, ohtml, ccodprocesso, chtmlmodelo

// validar e-mail do representante
dbselectarea("SA1")
SA1->(dbsetorder(1))
if SA1->(dbseek(xfilial("SA1")+SCJ->(CJ_CLIENTE+CJ_LOJA)))
	cpara := lower(trim(SA1->A1_EMAIL))
endif

if !(empty(cpara))
	
	//codigo do processo
	ccodprocesso	:= "envio"
	
	//caminho do template para gerar o relatorio
	chtmlmodelo	:= "\workflow\html\orcamento_mod3.htm"
	
	//inicializa o processo
	op := twfprocess():new(ccodprocesso, cassunto)
	
	//cria uma nova tarefa
	op:newtask("CWF10", chtmlmodelo)
	
	//utilizar template html
	ohtml := op:ohtml
	
	// preencher cabecalho
	ohtml:valbyname("CJ_NUM", SCJ->CJ_NUM)
	ohtml:valbyname("CJ_EMISSAO", DTOC(SCJ->CJ_EMISSAO) )
	ohtml:valbyname("CJ_ENDENT1", trim(SCJ->CJ_ENDENT1) )
	ohtml:valbyname("CJ_OBS", trim(SCJ->CJ_OBS) )
	ohtml:valbyname("CJ_TPFRETE", tpfrete(SCJ->CJ_TPFRETE) ) // funcao
	ohtml:valbyname("CJ_ENTREG", dtoc(SCJ->CJ_ENTREG) )  
	
	if lmodo
		ohtml:valbyname("DISPLAY", "none" )
	else
		ohtml:valbyname("DISPLAY", "block" )
	endif
	
	dbselectarea("SA1")
	SA1->( dbsetorder(1) )
	if( SA1->(dbseek(xfilial("SA1")+SCJ->(CJ_CLIENTE+CJ_LOJA))) )
		ohtml:valbyname("A1_EST", SA1->A1_EST )
		ohtml:valbyname("A1_TEL", trim(SA1->A1_TEL) )
		ohtml:valbyname("A1_CGC", iif( len(alltrim(SA1->A1_CGC))>11, transform( alltrim(SA1->A1_CGC), "@r 99.999.999/9999-99") , transform(SA1->A1_CGC, "@r 999.999.999-99") ))
		ohtml:valbyname("A1_MUN", trim(SA1->A1_MUN) )
		ohtml:valbyname("A1_COD", trim(SA1->A1_COD) )
		ohtml:valbyname("A1_LOJA", trim(SA1->A1_LOJA) )
		ohtml:valbyname("A1_NOME", trim(SA1->A1_NOME) )
		ohtml:valbyname("A1_TIPO", tipocli(SA1->A1_TIPO) ) //funcao
		ohtml:valbyname("A1_EMAIL", cpara ) //funcao
	endif
	SA1->( dbclosearea() )
	
	dbselectarea("SA3")
	SA3->(dbsetorder(1))
	if SA3->(dbseek(xfilial("SA3")+SCJ->CJ_VEND1))
		ohtml:valbyname("A3_COD", trim(SA3->A3_COD) )
		ohtml:valbyname("A3_NOME", trim(SA3->A3_NOME) )
		ohtml:valbyname("A1_TEL", (SA3->A3_TEL) ) //funcao
		ohtml:valbyname("A3_EMAIL", lower(trim(SA3->A3_EMAIL)) ) //
	endif
	
	ohtml:valbyname("DA0_CODTAB", SCJ->CJ_TABELA+" "+trim(posicione("DA0",1,xfilial("DA0")+SCJ->CJ_TABELA, "DA0_DESCRI")) )
	ohtml:valbyname("E4_COD", SCJ->CJ_CONDPAG )
	ohtml:valbyname("E4_DESCRI", trim(posicione("SE4",1,xfilial("SE4")+SCJ->CJ_CONDPAG, "E4_DESCRI")) )
	ohtml:valbyname("A4_COD", SCJ->CJ_TRANSP )
	ohtml:valbyname("A4_NOME", trim(posicione("SA4",1,xfilial("SE4")+SCJ->CJ_TRANSP, "A4_NOME")) )
	
	// resultados finais
	ohtml:valbyname("TOTAL", transform( SCJ->CJ_XTOTAL ,"@E 999,999,999.99") )
	ohtml:valbyname("PESOTOTAL", transform( SCJ->CJ_XPESOT ,"@E 999,999,999.99") )
	
	// itens
	dbselectarea("SCK")
	SCK->( dbsetorder(1) )
	SCK->( dbseek(xfilial("SCK")+SCJ->CJ_NUM) )
	while !(SCK->(EOF())) .and. SCK->CK_NUM == SCJ->CJ_NUM
		
		aadd(	ohtml:valbyname("t1.1") , SCK->CK_PRODUTO ) //
		aadd(	ohtml:valbyname("t1.2") , SCK->CK_DESCRI ) //
		aadd(	ohtml:valbyname("t1.3") , transform(SCK->CK_QTDVEN,"@e 99999999.99") ) //
		aadd(	ohtml:valbyname("t1.4") , transform(SCK->CK_PRCVEN,"@e 999,999,999.9999") ) //
		aadd(	ohtml:valbyname("t1.5") , transform(SCK->CK_VALOR ,"@e 999,999,999.99") ) //
		aadd(	ohtml:valbyname("t1.6") , alltrim(transform(SCK->CK_LANCES ,"@e 999,999,999.99"))+" X "+alltrim(transform(SCK->CK_METRAGE ,"@e 999,999,999.99")) ) //
		
		SCK->( dbskip() )
	enddo
	
	//informa assunto
	op:csubject := cassunto
	
	// endereco eletronico de envio
	if !empty( cpara )
		op:cto := cpara
	else
		op:csubject := cassunto+" o e-mail esta sem cadastro!!"
		op:cto := "wfti@cobrecom.com.br"	//"santos.rbt@gmail.com"
	endif
	
	//gera o processo
	op:start()
	op:finish()
	
	wfsendmail()
else
	lok := .f. // retornar que nao tem e-mail valido
endif

return lok

static function tipocli( ctipo )

do case
	case ctipo == "S"
		ctipo := "Solidário"
	case ctipo == "F"
		ctipo := "Cons.Final"
	case ctipo == "L"
		ctipo := "Produtor Rural"
	case ctipo == "R"
		ctipo := "Revendedor"
	case ctipo == "X"
		ctipo := "Exportação"
endcase

return ctipo

static function tpfrete( ctipo )

do case
	case ctipo == "F"
		ctipo := "FOB"
	case ctipo == "C"
		ctipo := "CIF"
	case ctipo == "T"
		ctipo := "Por conta de terceiro"
	case ctipo == "S"
		ctipo := "Sem frete"
endcase


return ctipo
