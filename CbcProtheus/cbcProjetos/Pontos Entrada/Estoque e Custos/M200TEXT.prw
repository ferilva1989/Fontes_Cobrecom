#include "rwmake.ch"
#include "TbiConn.ch"
#include "protheus.ch"

/*----------------------------------------------------------------*
--Exibe informações na árvore da estrutura
Os parâmetros enviados ao ponto de entrada estão no vetor PARAMIXB, sendo eles:
ParamIXB[1] -> Texto original, já com o TRT e a QTDE adicionados por padrão do sistema.
ParamIXB[2] -> Código do item pai.
ParamIXB[3] -> Sequencia TRT do item na estrutura.
ParamIXB[4] -> Código do componente que está sendo inserido na árvore.
ParamIXB[5] -> Quantidade do item na estrutura.
------------------------------------------------------------------*
Juliana Leme - 04/12/2015
------------------------------------------------------------------*/
User Function M200TEXT()
	Local aArea    := GetArea()
	Local aAreaSB1 := SB1->(GetArea())
	Local cQuant   := ""
	Local cTextOri := ParamIXB[1] // Texto original, já com o TRT e a QTDE adicionados por padrão do sistema
	Local cPai     := Padr(ParamIXB[2],TamSX3("G1_COD")[1])// Código do item pai
	Local cTRT     := Padr(ParamIXB[3],TamSX3("G1_TRT")[1]) // Sequencia TRT do item na estrutura
	Local cComp    := Padr(ParamIXB[4],TamSX3("G1_COMP")[1]) // Código do componente que está sendo inserido na árvore
	Local nQuant   := ParamIXB[5] // Quantidade do item na estrutura
	Local nTamCod  := TamSX3("B1_COD")
	Local nTamQtd  := TamSX3("G1_QUANT")
	Local cReturn  := ""          // retorno do PE

	If cComp <> cPai   
		If !(Empty(Posicione("SG1",1,xFilial("SG1")+cPai+cComp+cTRT,"G1_GROPC")))
			cReturn := Alltrim(cTextOri) + "  | Opc/Item: " + ;
			Posicione("SG1",1,xFilial("SG1")+cPai+cComp+cTRT,"G1_GROPC") +"/"+ ;
			Posicione("SG1",1,xFilial("SG1")+cPai+cComp+cTRT,"G1_OPC")
		Else
			cReturn := cTextOri
		EndIf
	Else    
		cReturn := cTextOri
	EndIf
	// Restaura as áreas originais
	RestArea(aAreaSB1)
	RestArea(aArea)
Return cReturn // novo texto a ser apresentado na árvore da estrutura
