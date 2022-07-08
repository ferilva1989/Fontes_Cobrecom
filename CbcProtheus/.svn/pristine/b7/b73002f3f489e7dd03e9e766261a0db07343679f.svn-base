#include "totvs.ch"
#include "tbiconn.ch"
#include 'topconn.ch'

/*
ROBERT SANTOS
PROATIVA TECNOLOGIA SP
13 DE AGOSTO DE 2012

ATIVADO POR JOB PARA MONITORAR CARTEIRA DE TITULOS EM ATRASO
GRAVAR POR REPRESENTANTE A CARTEIRA EM ARQUIVO ESPECIFICO:
\PROTHEUS_DATA\SITE\ [ARQUIVO.ARQTXT]

O ARQUIVO É NOMEADO COMO SENDO :
0011222222.TXT, ONDE:
0->EMPRESA
1->FILIAL
2->CODIGO DO VENDEDOR

*/

user function xjob0001( apar )

local cquery := ""
local nquery := 0
local cchaveA1 := ""
local agravarVend := {}
local nhdl
local ni
local cpath := "\site\"

If Select("SX2") == 0	
	RpcSetType(3)
	RpcSetEnv( apar[01],apar[02],,,"FIN",GetEnvServer(),{"SA1","SE1"}) 	
	//PREPARE ENVIRONMENT EMPRESA cemp FILIAL cfil MODULO "FIN"
EndIf

// limpar consultas atuais
afile := {}
makedir(cpath)
afile :=  Directory(cpath+"*.arqtxt")
for ni := 1 to len( afile )
	FERASE ( cpath+afile[ni][1] )
next

cquery := " select E1_CLIENTE, E1_LOJA, E1_VEND1 "
cquery += " from "+retsqlname("SE1")+" E1 "
cquery += " where E1.D_E_L_E_T_ = '' "
cquery += " and E1_VENCREA < '"+dtos(ddatabase)+"' "
cquery += " and E1_BAIXA = '' "
cquery += " and E1_TIPO not in ('PR') "
cquery += " and E1_VEND1 <> '' "
cquery += " group by E1_CLIENTE, E1_LOJA, E1_VEND1 "

tcquery cquery new alias "QRY"
count to nquery
if nquery>0
	
	// tabela de clientes
	dbselectarea("SA1")
	SA1->( dbsetorder(1) )
	
	// gravar por arquivo por representante
	QRY->( dbgotop() )
	while !QRY->(eof())
		
		cnomarq := cempant+cfilant+trim(QRY->E1_VEND1)+".arqtxt"
		
		// escrever em arquivo
		nhdl := fcreate( cpath+cnomarq )
		
		if nhdl > 0
			
			SA1->(dbseek( xfilial("SA1")+QRY->(E1_CLIENTE+E1_LOJA)))
			
			fwrite( nhdl,;
			rtrim( QRY->E1_CLIENTE )+";"+;
			rtrim( QRY->E1_LOJA )+";"+;
			rtrim( SA1->A1_NOME )+CRLF;
			)
			fclose(nhdl)
		endif
		
		QRY->( dbskip() )
	enddo
endif

return nil
