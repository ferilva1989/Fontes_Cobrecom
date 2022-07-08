#include 'protheus.ch'
#include 'tbiconn.ch'

/*	Nome: Robert Santos
Data: 03 juL 2012
Desc: CLIENTES BLOQUEADOS	*/
user function CWF06( adata )

local i := 0       
local cassunto := "Clientes bloqueados"
local cpara := lower( trim(getmv("MV_CLIAPRV")) )

private op, ohtml, ccodprocesso, chtmlmodelo

//codigo do processo
ccodprocesso	:= "envio"

//caminho do template para gerar o relatorio
chtmlmodelo	:= "\workflow\html\clientes_bloqueados.htm"

//inicializa o processo
op := twfprocess():new(ccodprocesso, cassunto)

//cria uma nova tarefa
op:newtask("CWF06", chtmlmodelo)

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
	aadd(	ohtml:valbyname("t1.7") , adata[i][7] ) // 
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
