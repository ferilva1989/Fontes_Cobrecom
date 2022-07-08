#include 'protheus.ch'
#include 'topconn.ch'

/*	Robert Santos
28 jun 2012
Verificar se possui clientes/ orcamentos bloqueados e enviar WF especifico
*/
user function CWF99( apar )

local cqry, nqry
local acliente := {}
local aorca := {}
local cnomusr

rpcsetenv( apar[1] , apar[2] )

// selecionar todos clientes bloquados
cqry := " select A1.R_E_C_N_O_ AS [ID] from "+retsqlname("SA1")+" A1 where A1.D_E_L_E_T_ = '' and A1_MSBLQL = '1' "
if select("QRY")>0
	QRY->(dbcloserarea())
endif
tcquery cqry new alias "QRY"
count to nqry
if nqry>0
	dbselectarea("SA1")
	
	dbselectarea("SA3")
	SA3->( dbsetorder() )
	
	QRY->( dbgotop() )
	while !( QRY->(eof()) )
		SA1->(dbgoto(QRY->(ID)))
		
		aadd( acliente, {;
		trim(SA1->A1_COD),;
		trim(SA1->A1_LOJA),;
		trim(SA1->A1_NREDUZ),;
		trim(SA1->A1_EMAIL),;
		trim(SA1->A1_TEL),;
		trim(SA1->A1_CONTATO),;
		trim(SA1->A1_CGC);
		;
		} )
		
		QRY->( dbskip() )
	enddo
	SA1->( dbclosearea() )
endif
QRY->( dbclosearea() )

// selecionar orcamentos bloqueados
cqry := " select CJ.R_E_C_N_O_ AS [ID] from "+retsqlname("SCJ")+" CJ where CJ.D_E_L_E_T_ = '' and CJ_STSITE = '5' "
tcquery cqry new alias "QRY"
count to nqry
if nqry>0
	
	dbselectarea("SCJ")
	
	dbselectarea("SA3")
	SA3->(dbsetorder(1))
	
	QRY->( dbgotop() )
	while !(QRY->(eof()))
		
		SCJ->( dbgoto(QRY->ID) )
		
		if SA3->( dbseek(xfilial("SA3")+SCJ->CJ_VEND1) )
			cnomusr := SA3->A3_NOME
		else
			cnomusr := ""
		endif
		
		aadd( aorca, {;
		(SCJ->CJ_NUM),;
		(SCJ->CJ_CLIENTE),;
		(SCJ->CJ_LOJA),;
		(SCJ->CJ_NOMCLI),;
		dtoc(SCJ->CJ_EMISSAO),;
		trim(cnomusr);
		})
		
		QRY->( dbskip() )
	enddo
	SCJ->(dbclosearea())
endif

QRY->(dbclosearea())

if len(acliente)>0
	u_cwf06( acliente )
endif

if len(aorca)>0
	u_cwf07( aorca )
endif

return nil
