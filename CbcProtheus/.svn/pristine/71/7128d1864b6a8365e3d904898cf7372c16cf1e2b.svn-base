#Include 'Protheus.ch'
#include "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//   Programa ...: A103BLOQ                                                 //
//   Autor ......: Jeferson Gardezani              Data ..: 29/01/2016      //
//                                                                          //
//   Ponto de Entrada na digitação/classificação do documento de entrada,   //
//   para realizar validações complementares e redefinir o bloqueio ou      //
//   liberação.                                                             //
//                                                                          //
//	 Parâmetros do Ponto de Entrada:                                        //
//   PARAMIXB[1] => .T. = Bloqueado por tolerência                          //
//                  .F. = Não tem bloqueio                                  //
//                                                                          //
//  *Validações de Quantidade e Preço são feitas pelo padrão, através do    //
//   controle de Tolerância na Entrada de Material.                         //
//  *As validações devem acontecer na Inclusão ou Classificação, quando não //
//    foi gerado registro para aprovação.                                   //
//////////////////////////////////////////////////////////////////////////////

User Function  A103BLOQ()

	Local aDiv, i
	Local lDiverg    := PARAMIXB[1]
	//Salva posição atual dos ponteiros
	Local aArea      := GetArea()
	Local aSCR       := SCR->(GetArea())
	Local cZZPCNFE   := SUPERGETMV("MV_ZZPCNFE",.F.,"")
	Default cZZPCNFE := ""

	//Só verifica divergências, se usuário está no parâmetro que controla amarração NFE x PC (*=TODOS os usuários)
	If "*" $ cZZPCNFE .Or. __cUserID $ cZZPCNFE

		//Só verifica divergências, se iniciou o Ponto de Entrada sem bloqueio por tolerância
		If !lDiverg

			//Pesquisa se gerou registro para aprovação
			DbSelectarea("SCR")
			SCR->(DbSetOrder(1))	//CR_FILIAL + CR_TIPO + CR_NUM + CR_NIVEL
			If  !SCR->(DbSeek(xFilial("SCR")+"NF"+CNFISCAL+CSERIE+CA100FOR+CLOJA,.F.))		//CNFISCAL, CSERIE, CA100FOR e CLOJA variáveis de memória

				//Obtem Array com divergências
				aDiv := U_DivergNFE(aCols,aHeader,CCONDICAO)

				//Percorre Array verificando se exitem divergências
				For i:=1 to Len(aDiv)
					If aDiv[i][1]
						MsgBox("O Documento de Entrada será bloqueado devido divergências com o Pedido de Compras e/ou ausência de Pedido de Compras.","A103BLOQ","ALERT")
						lDiverg := .T.
						Exit
					EndIf
				Next

			EndIf

		EndIf

	EndIf

	//Restaura posição dos ponteiros
	RestArea(aSCR)
	RestArea(aArea)

Return lDiverg

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//   Função .....: DivergNFE                                                                                    //
//   Objetivo ...: Verificar divergências entre NFE x PCs                                                       //
//                 (Condição de Pagamento e Itens NFE sem Pedido de Compras)                                    //
//   Autor ......: Jeferson Gardezani                                                                           //
//   Data .......: 23/02/2016                                                                                   //
//                                                                                                              //
//	 Parâmetros Recebidos:                                                                                      //
//   OBRIGATÓRIO: _aCols+_aHeader+_cCondPag OU _cDoc+_cSer+_cFor+_cLoja                                         //
//   _aCols     : aCols da NFE                                                                                  //
//   _aHeader   : aHeader da NFE                                                                                //
//   _cCondPag  : Condição de Pagamento da NFE                                                                  //
//   _cDoc      : Número da NFE                                                                                 //
//   _cSer      : Série da NFE                                                                                  //
//   _cFor      : Fornecedor da NFE                                                                             //
//   _cLoja     : Loja da NFE                                                                                   //
//                                                                                                              //
//   Retorno da Função:                                                                                         //
//   Array contendo: {Flag Divergência Item NFE (T=Com Diverg./F=Sem Diverg.), Item NFE, PC, Item PC, Mensagem} //
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////

User Function DivergNFE(_aCols,_aHeader,_cCondPag,_cDoc,_cSer,_cFor,_cLoja)

	Local i, x, lDivItem, cCondNFE, cCondPC, nPosIt, nPosPC, nPosItPC, nPosTES
	Local lDivGer := .F.
	Local aRet    := {}
	Local cMsg    := ""
	Local cTES    := SUPERGETMV("MV_TESPCNF",.F.,"")
	//Salva posição atual dos ponteiros
	Local aArea   := GetArea()
	Local aSE4    := SE4->(GetArea())
	Local aSC7    := SC7->(GetArea())
	Local aSF1    := SF1->(GetArea())
	Local aSD1    := SD1->(GetArea())

	Default _aCols     := {}
	Default _aHeader   := {}
	Default _cCondPag  := ""
	Default _cDoc      := ""
	Default _cSer      := ""
	Default _cFor      := ""
	Default _cLoja     := ""

	If !Empty(_aCols)

		//Obtem descrição da condição de pagamento da NFE
		cCondNFE:= _cCondPag + "-" + Alltrim(Posicione("SE4",1,xFilial("SE4")+_cCondPag,"E4_DESCRI"))

		//Obtem posição dos campos em _aCols
		nPosIt   := aScan(_aHeader,{|x| AllTrim(x[2])=="D1_ITEM"})
		nPosPC   := aScan(_aHeader,{|x| AllTrim(x[2])=="D1_PEDIDO"})
		nPosItPC := aScan(_aHeader,{|x| AllTrim(x[2])=="D1_ITEMPC"})
		nPosTES  := aScan(_aHeader,{|x| AllTrim(x[2])=="D1_TES"})

		//Percorre itens da NFE verificando divergências
		For i:=1 to Len(_aCols)

			//Inicializa variáveis do Loop
			lDivItem := .F.
			cMsg := ""

			//Verifica Item NFE sem PC
			If Empty(_aCols[i][nPosPC])

				//Os TES cadastrados no parâmetro MV_TESPCNF podem ser incluídos sem PC
				If !_aCols[i][nPosTES] $ cTES
					cMsg     := "Sem Pedido"
					lDivItem := .T.
					lDivGer  := .T.
				EndIf

			Else
				//Verifica condição de pagamento
				If  U_Posic_SC7(xFilial("SC7"),_aCols[i][nPosPC])

					If SC7->C7_COND <> _cCondPag
						//Obtem descrição da condição de pagamento do PC
						cCondPC  := SC7->C7_COND + "-" + Alltrim(Posicione("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_DESCRI"))
						cMsg     := "Cond.Pgto.NFE: [" + cCondNFE + "] - Cond.Pgto.PC: [" + cCondPC + "]"
						lDivItem := .T.
						lDivGer  := .T.
					EndIf

				EndIf

			EndIf

			//Adiciona array de retorno
			//{Flag Divergência Item NFE, Item NFE, PC, Item PC, Mensagem}
			Aadd(aRet,{lDivItem,_aCols[i][nPosIt],_aCols[i][nPosPC],_aCols[i][nPosItPC],cMsg})

		Next

		//Chamada pela tela de aprovação Função:(MT097SCR())
	ElseIf !Empty(_cDoc)

		//Obtem a condição de pagamento da NFE
		_cCondPag := Posicione("SF1",1,xFilial("SF1")+_cDoc+_cSer+_cFor+_cLoja,"F1_COND")
		//Obtem descrição da condição de pagamento da NFE
		cCondNFE:= _cCondPag + "-" + Alltrim(Posicione("SE4",1,xFilial("SE4")+_cCondPag,"E4_DESCRI"))

		U_Posic_SD1(xFilial("SD1"),_cSer,_cDoc,_cFor,_cLoja)
		While !Eof() .And. SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == xFilial("SD1")+_cDoc+_cSer+_cFor+_cLoja

			//Inicializa variáveis do Loop
			lDivItem := .F.
			cMsg := ""

			//Verifica Item NFE sem PC
			If Empty(SD1->D1_PEDIDO)

				//Os TES cadastrados no parâmetro MV_TESPCNF podem ser incluídos sem PC
				If !SD1->D1_TES $ cTES
					cMsg     := "Sem Pedido"
					lDivItem := .T.
					lDivGer  := .T.
				EndIf

			Else
				//Verifica condição de pagamento
				If  U_Posic_SC7(xFilial("SC7"),SD1->D1_PEDIDO)

					If SC7->C7_COND <> _cCondPag
						//Obtem descrição da condição de pagamento do PC
						cCondPC  := SC7->C7_COND + "-" + Alltrim(Posicione("SE4",1,xFilial("SE4")+SC7->C7_COND,"E4_DESCRI"))
						cMsg     := "Cond.Pgto.NFE: [" + cCondNFE + "] - Cond.Pgto.PC: [" + cCondPC + "]"
						lDivItem := .T.
						lDivGer  := .T.
					EndIf

				EndIf

			EndIf

			//Adiciona array de retorno
			//{Flag Divergência Item NFE, Item NFE, PC, Item PC, Mensagem}
			Aadd(aRet,{lDivItem,SD1->D1_ITEM,SD1->D1_PEDIDO,SD1->D1_ITEMPC,cMsg})

			SD1->(DBSkip())

		EndDo

	EndIf

	//Restaura posição dos ponteiros
	RestArea(aSD1)
	RestArea(aSF1)
	RestArea(aSC7)
	RestArea(aSE4)
	RestArea(aArea)

Return aRet

////////////////////////////////////////////////////////////////////
//   Função  : Posic_SC7 - Pesquisar/Pocionar o Pedido de Compras //
//   Retorno : .T.=Achou/Posicionou / .F.=Não Achou/Posicionou    //
////////////////////////////////////////////////////////////////////
User Function Posic_SC7(_cFil,_cPC,_cItPC)

	Local lRet

	Default _cFil	:= ""
	Default _cPC	:= ""
	Default _cItPC	:= ""

	DbSelectarea("SC7")
	SC7->(DbSetOrder(1))	//C7_FILIAL + C7_NUM + C7_ITEM + C7_SEQUEN
	lRet :=  SC7->(DbSeek(Padr(_cFil,	TamSx3("C7_FILIAL")[1])	+;
	Padr(_cPC, 	TamSx3("C7_NUM")[1])	,.F.))
Return lRet

////////////////////////////////////////////////////////////////////
//   Função  : Posic_SD1 - Pesquisar/Pocionar Itens da NFE        //
//   Retorno : .T.=Achou/Posicionou / .F.=Não Achou/Posicionou    //
////////////////////////////////////////////////////////////////////
User Function Posic_SD1(_cFil, _cSerie, _cDoc, _cForn, _cLoja )

	Local lRet

	Default _cFil	:= ""
	Default _cSerie	:= ""
	Default _cForn	:= ""
	Default _cLoja	:= ""
	Default _cDoc	:= ""

	DbSelectarea("SD1")
	SD1->(DbSetOrder(1))	//D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
	lRet :=  SD1->(DbSeek(Padr(_cFil	, TamSx3("D1_FILIAL")[1]) 	+ Padr(_cDoc	, TamSx3("D1_DOC")[1]) 		+;
	Padr(_cSerie	, TamSx3("D1_SERIE")[1]) 	+ Padr(_cForn	, TamSx3("D1_FORNECE")[1]) 	+;
	Padr(_cLoja	, TamSx3("D1_LOJA")[1]) ,.F.))

Return lRet