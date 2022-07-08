#include 'protheus.ch'
#include 'tbiconn.ch'

/*	Nome: Robert Santos
Data: 03 juL 2012
Desc: ORCAMENTOS BLOQUEADOS	*/
user function CWF07( adata )

local i := 0       
local cassunto := "Orçamentos bloqueados"
local cpara := lower(trim(getmv("MV_XORCBLQ")))

private op, ohtml, ccodprocesso, chtmlmodelo

//codigo do processo
ccodprocesso	:= "envio"

//caminho do template para gerar o relatorio
chtmlmodelo	:= "\workflow\html\orcamentos_bloqueados.htm"

//inicializa o processo
op := twfprocess():new(ccodprocesso, cassunto)

//cria uma nova tarefa
op:newtask("CWF07", chtmlmodelo)

//utilizar template html
ohtml := op:ohtml

// itens
for i := 1 to len(adata)
	aadd(	ohtml:valbyname("t1.1") , adata[i][1] ) // 
	aadd(	ohtml:valbyname("t1.2") , adata[i][2] ) // 
	aadd(	ohtml:valbyname("t1.3") , adata[i][3] ) // 
	aadd(	ohtml:valbyname("t1.4") , adata[i][4] ) // 
	aadd(	ohtml:valbyname("t1.5") , adata[i][5] ) // 
	aadd(	ohtml:valbyname("t1.6") , adata[i][6] ) // 
next

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

return
