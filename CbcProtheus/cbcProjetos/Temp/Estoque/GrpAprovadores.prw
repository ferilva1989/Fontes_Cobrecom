#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch" 

/*/{Protheus.doc} groupApprovers
Obtem o grupo de aprovadores do pedido de compra
@author bolognesi
@since 24/03/2016
@version 1.0
@example
ogroup := groupApprovers():newgroupApprovers()
@description Utilizados pelos PE MT140APV e MT103APV, tem como objetivo
partindo da nota (Entrada ou Classificação), obtem-se os pedidos relacionados (SD1xSC7)
e nestes pedidos obtem-se o grupo de aprovadores (SC7->C7_APROV). e quando for grupo unico
para todos retorna este grupo.
/*/
class groupApprovers 

	data aPedAprov
	data cGrpAprov

	method newgroupApprovers() constructor 
	method setPedAprov()
	method getGrpAprov()
	method defGrpAprov()
	method haveGroup()

endclass

/*/{Protheus.doc} newnewgroupApprovers
Construtor da classe
@author bolognesi
@since 24/03/2016
@param nRec Number Numero do recno da tabela SF1 posicionada
@version 1.0
@description construtor da classe
quando não informado nRec, utiliza-se os arrays (aHeader,aCols)
em testes nos dois pontos de entrada não utiliza posicionamento direto
no SF1, tudo pelos arrays mencionados
/*/
method newgroupApprovers(nRec) class groupApprovers
	Local nI		:= 0
	Default nRec	:= ""
	::aPedAprov		:= {}

	DbSelectArea("SC7")
	SC7->(DbSetOrder(1)) //C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN

	If Empty(nRec)
		If !Empty(aCols)
			For nI:= 1 To Len(aCols)
				If !GDDeleted(nI)
					::setPedAprov(GDFieldGet("D1_PEDIDO",nI))	
				EndIf
			Next nI
			::defGrpAprov()
		EndIf

	Else
		DbSelectarea("SF1")
		SF1->(dbgoto(nRec))
	Endif

return

/*/{Protheus.doc} setPedAprov
@author bolognesi
@since 11/04/2016
@version 1.0
@param cPedido, characters, Numero do pedido
@type method
@description Metodo que adiciona na propriedade aPedAprov
o numero do pedido (paramtero) e o grupo de aprovação do mesmo
C7_APROV
/*/
method setPedAprov(cPedido)	class groupApprovers
	Local cAprov	:=""
	If SC7->(DbSeek(xFilial("SC7")+cPedido,.F.))
		cAprov :=  SC7->(C7_APROV)
		If !Empty(cAprov)
			AAdd(::aPedAprov, {cPedido, cAprov})
		EndIf
	EndIf
return

/*/{Protheus.doc} defGrpAprov
@author bolognesi
@since 11/04/2016
@version undefined
@type method
@description Metodo utilizado apos o preenchimento
da propriedade aPedAprov, que verifica se o aprovador é o mesmo
para todos os pedidos (Pois somente quando for o mesmo que o retornamos para
o ponto de entrada) do contrário permanece o tratamento padrão do sistema
/*/
method defGrpAprov()	class groupApprovers
	Local nX	:= 0
	::cGrpAprov := ""
	If !Empty(::aPedAprov)
		::cGrpAprov := ::aPedAprov[1,2]
		For nX := 1 To Len(::aPedAprov)
			If ::aPedAprov[nX,2] <> ::cGrpAprov
				::cGrpAprov := ""
				exit
			EndIf
		Next nX
	EndIf 
return

/*/{Protheus.doc} getGrpAprov
@author bolognesi
@since 11/04/2016
@version 1.0
@type method
@description Retorna o conteudo da Propriedade cGrpAprov
/*/
method getGrpAprov()	class groupApprovers
return ::cGrpAprov

/*/{Protheus.doc} haveGroup
@author bolognesi
@since 11/04/2016
@version 1.0
@type method
@description Retorna um valor logico a respeito de ter uma grupo
ou não, para ter um grupo é preciso que todos os aprovadores de 
todos os pedidos sejam o mesmo
/*/
method haveGroup() class groupApprovers
return !Empty(::cGrpAprov) 