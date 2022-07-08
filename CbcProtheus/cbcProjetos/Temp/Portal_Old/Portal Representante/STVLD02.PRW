#include 'protheus.ch'

/*
Validacao do site para retornar comissão por item
Robert Santos
13 jun 2012

Retorno padrao
nret = valor da comissão
*/
user function StVld02( ca1_cod, ca1_loja, ca3_cod, cda0_codtab, cb1_cod, nprcvenda, cf4_cod, cacondic, ce4cod )

local nret			:= 0
local aDadCli		:= {}
local cDuplic		:= ""
local nB1_COD		:= 0
local nA3_Cod		:= 0
local nda0_codtab	:= 0  
Local cE4Cod := "" //LEONARDO Alteração do dia 07/05/2014

//INICIO LEONARDO 09/04/2014 Arredondamento das casas decimais para calculo de comissão
nprcvenda := Round(nprcvenda,4)
//FIM 

//INICIO LEONARDO 07/05/2014 - Utilizado para o calculo de comissão
//Solicitado Roberto dia 07/05/2014 VejaComiss()
DbSelectArea("SE4")
SE4->(DbSetOrder(1)) // E4_FILIAL + E4_CODIGO
If SE4->(DbSeek(xFilial("SE4")+ce4cod ))
	cE4Cod := SE4->E4_AVISTA	
EndIf
SE4->(DbCloseArea())
//FIM LEONARDO

if select("SX2")==0
	RpcSetEnv("01","01")
endif

nB1_COD		:= tamsx3("B1_COD")[1]
nA3_Cod		:= tamsx3("A3_COD")[1]
nda0_codtab	:= tamsx3("DA0_CODTAB")[1]

cb1_cod		:= padr(cb1_cod,nB1_Cod)
ca3_cod		:= padr(ca3_cod,nA3_cod)
cda0_codtab	:= Padr(cda0_codtab,nDa0_Codtab)

aDadCli	:= {ca1_cod,ca1_loja,ca3_cod,cda0_codtab}
cDuplic	:= If(Empty(cf4_cod),"S",Posicione("SF4",1,xFilial("SF4")+cf4_cod,"F4_DUPLIC")) 

//INICIO LEONARDO 07/05/2014 adicionei parametro cE4Cod
nret := u_VejaComis(cb1_cod,nprcvenda,cDuplic,cacondic,aDadCli,cE4Cod) //, cda0_codtab, ca3_cod) // deve trazer comissao
//FIM LEONARDO

return nret

/*
CONNOUT("**** INICIOU RETORNO DA COMISSAO ****")
CONNOUT("**** PARAMETROS ****")
CONNOUT(" cb1_cod: '" + cB1_COD + "' ")
CONNOUT(" nprcvenda: '" + alltrim(str(nprcvenda)) + "' ")
CONNOUT(" cDuplic: '" + cDuplic + "' ")
CONNOUT(" cacondic: '" + cacondic + "' ")
CONNOUT(" aDadCli[1]: '" + aDadCli[1] + "' ")
CONNOUT(" aDadCli[2]: '" + aDadCli[2] + "' ")
CONNOUT(" aDadCli[3]: '" + aDadCli[3] + "' ")
CONNOUT(" aDadCli[4]: '" + aDadCli[4] + "' ")
CONNOUT(" cda0_codtab: '" + cda0_codtab + "' ")
CONNOUT(" ca3_cod: '" + ca3_cod + "' ")    
CONNOUT("**** FINAL RETORNO DA COMISSAO ****")
*/
/*
CONNOUT("**** INICIOU RETORNO DA COMISSAO ****")
CONNOUT("**** PARAMETROS ****")
CONNOUT(" cb1_cod: '" + cB1_COD + "' ")
CONNOUT(" nprcvenda: '" + alltrim(str(nprcvenda)) + "' ")
CONNOUT(" cDuplic: '" + cDuplic + "' ")
CONNOUT(" cacondic: '" + cacondic + "' ")
CONNOUT(" aDadCli[1]: '" + aDadCli[1] + "' ")
CONNOUT(" aDadCli[2]: '" + aDadCli[2] + "' ")
CONNOUT(" aDadCli[3]: '" + aDadCli[3] + "' ")
CONNOUT(" aDadCli[4]: '" + aDadCli[4] + "' ")
CONNOUT(" cda0_codtab: '" + cda0_codtab + "' ")
CONNOUT(" ca3_cod: '" + ca3_cod + "' ")    
*/