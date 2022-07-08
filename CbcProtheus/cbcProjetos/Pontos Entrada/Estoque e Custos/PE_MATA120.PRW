#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} MT120BRW
//Ponto de Entrada
@author bolognesi
@since 24/03/2016
@version 1.0
@description Ponto de entrada para adionar rotinas personalizadas ao pedido de compras
/*/
User Function MA120BUT()
	Local aButtons :={}

	Aadd(aButtons,{'Conhecimento',{|| U_CbcDocument(SC7->(Recno()), 'SC7', 2 )  },"Conhecimento","Conhecimento"})

Return aButtons

/*/{Protheus.doc} CbcDocument
//Ponto de Entrada
@author bolognesi
@since 28/04/2016
@version 1.0
@param nRec numeric Informa o recno do registro para abrir MsDocument
@param nTabela string Define a tabela a qual o recno pertence
@param nWiz numeric Informa se deve mostrar o Wizard de inclusão=1 ou somente visualizar=2
@description Função generica utilizada para abrir o MsDocument, em alguns casos dependendo
do local da chamada a função MsDocument altera o aRotina(Inutilizando os botões na volta),
muda o conteudo da variavel N, causando erros de arrays, por isso esta função realiza os
devidos backups antes da chamada restaurando na volta. 
/*/
User Function CbcDocument(nRec, nTabela, nWiz)
	Local aRotBack 	 	:= IIF(ValType(aRotina) == 'A', AClone( aRotina ), {})
	Local nBk			:= N
	MsDocument(nTabela,nRec , nWiz)
	aRotina := AClone( aRotBack )
	N:= nBk                                                         
return