#include "rwmake.ch"
#include 'protheus.ch'

/*
Juliana Leme 08/07/2015
Ponto de Entrada criado para adequar a legislação:  
http://tdn.totvs.com/pages/releaseview.action?pageId=191465111
Novas Regras de Retenção PIS-COFINS-CSLL - Lei 13.137/2015, publicado no DOU em 22/06/2015
Com relação ao vencimento do título de retenção recomendamos a utilização do seguinte ponto de entrada:
Esse ponto de entrada é utilizado somente no Contas a Pagar para títulos com o modo de retenção Baixa ou Emissão.

F050MDVC
http://tdn.totvs.com/pages/releaseview.action?pageId=6070892

No segundo exemplo deste ponto de entrada, o mesmo foi criado com o intuito de facilitar a implementação pelo cliente.

Desabilitar conforme liberação da pacth do chamado aberto: TSVB11
*/
User function F050MDVC()
	Local dNextDay := ParamIxb[1] //data calculada pelo sistema
	Local cIMposto := ParamIxb[2]
	Local dEmissao := ParamIxb[3]
	Local dEmis1   := ParamIxb[4]
	Local dVencRea := ParamIxb[5]
	Local nNextMes := Month(dVencRea)+1

	If At(cImposto,"PIS,CSLL,COFINS") > 0
		dNextDay := STOD(StrZero(Iif(nNextMes==13,Year(dVencRea)+1,Year(dVencRea)),4)+Iif(nNextMes==13,"01",StrZero(nNextMes,2))+"20")//Acho o ultimo dia util do periodo desejado
		dNextday := DataValida(dNextday,.F.)
	Endif

Return dNextDay