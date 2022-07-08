#include 'protheus.ch'
#include 'tbiconn.ch'

/*	
Nome: Robert Santos
Data: 08 ago 2012
Desc: Enviar email para o representante do faturamento do pedido dele
*/
user function CWF11(  )

local i := 0
local cassunto := "Orçamento "+SCJ->CJ_NUM
local cpara := ""
local lok := .t. // ok
local citem := "00"
local ntotipi := 0
local cprod := "" //nome generico do prodto
local cacond := ""

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
	chtmlmodelo	:= "\workflow\html\orcamento_mod4.htm"
	
	//inicializa o processo
	op := twfprocess():new(ccodprocesso, cassunto)
	
	//cria uma nova tarefa
	op:newtask("CWF11", chtmlmodelo)
	
	//utilizar template html
	ohtml := op:ohtml
	
	// preencher cabecalho
	ohtml:valbyname("CJ_OBS", trim(SCJ->CJ_OBS) )
	ohtml:valbyname("CJ_TPFRETE", tpfrete(SCJ->CJ_TPFRETE) ) // funcao
	ohtml:valbyname("E4_DESCRI", posicione("SE4",1,xfilial("SE4")+SCJ->CJ_CONDPAG, "E4_DESCRI") ) // funcao
	
	dbselectarea("SA3")
	SA3->(dbsetorder(1))
	if SA3->(dbseek(xfilial("SA3")+SCJ->CJ_VEND1))
		ohtml:valbyname("A3_NOME", trim(SA3->A3_NOME) )
		ohtml:valbyname("A1_TEL", (SA3->A3_TEL) ) //funcao
		ohtml:valbyname("A3_EMAIL", lower(trim(SA3->A3_EMAIL)) ) //
	endif
	
	// resultados finais
	ohtml:valbyname("TOTALORC", transform( SCJ->CJ_XTOTAL ,"@E 999,999,999.99") )
	
	// itens
	dbselectarea("SB1")
	SB1->( dbsetorder(1) )
	
	dbselectarea("SZ1")
	SZ1->( dbsetorder(1) )
	
	dbselectarea("SCK")
	SCK->( dbsetorder(1) )
	SCK->( dbseek(xfilial("SCK")+SCJ->CJ_NUM) )
	while !(SCK->(EOF())) .and. SCK->CK_NUM == SCJ->CJ_NUM
		
		if SZ1->( dbseek(xfilial("SZ1")+SB1->B1_NOME) )
			cprod := trim(SZ1->Z1_APELIDO)
		else
			cprod := ""
		endif    
		
		cacond := alltrim(SCK->CK_ACONDIC)
		if len(cacond) > 0
			cacond := substr( cacond, 1, 1)
		endif
		
		citem := soma1( citem )
		
		SB1->( dbseek(xfilial("SB1")+SCK->CK_PRODUTO) )
		ntotipi += SB1->B1_IPI
		
		aadd(	ohtml:valbyname("t1.1") , citem ) //
		aadd(	ohtml:valbyname("t1.2") , transform(SCK->CK_QTDVEN,"@e 99999999.99")  ) //
		aadd(	ohtml:valbyname("t1.3") , cprod  ) //
		aadd(	ohtml:valbyname("t1.4") ,  transform(SCK->CK_PRCVEN,"@e 999,999,999.9999")   ) //
		aadd(	ohtml:valbyname("t1.5") , transform(SB1->B1_IPI,"@e 999.99") ) //
		aadd(	ohtml:valbyname("t1.6") , "10/15 D.UT" ) //
		aadd(	ohtml:valbyname("t1.7") , u_xdeacond( cacond, .t. ) ) //
		aadd(	ohtml:valbyname("t1.8") , "" ) // observ
		aadd(	ohtml:valbyname("t1.9") , U_ckstsite( SCK->CK_STSITE ) ) // disponib.
		SCK->( dbskip() )
	enddo
	ohtml:valbyname("IPI", transform( ntotipi, "@e 999,999,999.99") )
	ohtml:valbyname("TOTAL", transform( ntotipi+SCJ->CJ_XTOTAL , "@e 999,999,999.99") )
	
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
