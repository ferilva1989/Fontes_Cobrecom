#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch" 
#define CRLF Chr(13)+Chr(10)


/*ANTES DA EXCLUSÃO DO ORÇAMENTO DE VENDAS, SENDO SEU RETORNO (.T.)=PODE EXCLUIR  (.F.) NÃO PODE */
User Function MT415EXC()
Local aArea := GetArea()
Local aSCJ	:= SCJ->(GetArea())
Local aSCK	:= SCK->(GetArea())
Local aRet	:= .T.

/*LEONARDO 05/04/16 CANCELAR RESERVAS DO PORTAL*/
u_BudgetMngr('KILL')

RestArea(aSCJ)
RestArea(aSCK)
RestArea(aArea)
Return aRet 

/*ROTINA A415CANCEL() DEFINIR SE PODE OU NÃO CANCELAR ORÇAMENTO (1)=PODE EXCLUIR  (outro numero) NÃO PODE */
User Function M415CANC()
Local aArea := GetArea()
Local aSCJ	:= SCJ->(GetArea())
Local aSCK	:= SCK->(GetArea())
Local nRet	:= 1

/*LEONARDO 05/04/16 CANCELAR RESERVAS DO PORTAL*/
u_BudgetMngr('KILL')

RestArea(aSCJ)
RestArea(aSCK)
RestArea(aArea)
Return nRet