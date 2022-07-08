#include "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                           /
//   Programa ...: PE_MATA010.PRW                         Modulo : SIGAEST    /
//                                                                           /
//   Autor ......: Roberto Oliveira                   Data ..: 28/11/2014    /
//                                                                           /
//   Objetivo ...: Ponto de entrada na validação da rotina de inclusão e     /
//                 alteração do cadastro de produto para solicitar o         /
//                 preenchimento dos campos referente a pasta PCP-FAST.      /
//                                                                           /
//                                                                           /
//   Uso ........: Especifico da Cobrecom                                    /
//                                                                           /
//////////////////////////////////////////////////////////////////////////////

/* // Quando os pontos de entradas abaixo forem descontinuados
   // habilitar e user function e tratar como PE MVC
user Function ITEM()
local xRet := .T.
return(xRet)
*/

User Function A010TOK()
	Local _lVolta := .T.
	Local _cMsg1 := ""
	Local _cMsg2 := ""
	Local _cMsg3 := ""
	Local _cMsg  := ""
	Local _nMsg  := 1
	//Juliana Leme
	Local cData 	:= Substr(DtoS(Date()),7,2)+Substr(DtoS(Date()),5,2)+Substr(DtoS(Date()),3,2)
	Local cHora		:= Substr(Time(),1,2)+Substr(Time(),4,2)

	if !IsInCallStack("A010WizFac")
		If INCLUI .And. (M->B1_TIPO=="PA" .Or. M->B1_TIPO=="MP")
			//
			// Roberto 15/04/2016
			// Efetuar a validação da existência do código, pois nesse caso o código não é digitado
			// e sim montado com a concatenação das variáveis:
			// 			M->B1_NOME+M->B1_BITOLA+M->B1_COR+M->B1_CLASENC+M->B1_ESPECIA 		para PA
			// ou
			//  		M->B1_NOME+M->B1_COR+M->B1_FORNECE+0+M->B1_IDENTIF 					para MP
			//
			SB1->(DbSetOrder(1))
			If SB1->(DbSeek(xFilial("SB1")+M->B1_COD,.F.))
				MsgBox("Código de produto já existente","Erro!!","STOP")
				Return(.F.)
			EndIf
		EndIf
		
		If M->B1_TIPO=="PA" .and. Empty(Alltrim(M->B1_ZZFILFB)) 
			MsgBox("Produto do Tipo 'PA', informar qual Unidade de Fabricação." + Chr(13) +;
							"Campo não pode ser VAZIO","Atenção","STOP")
			Return(.F.)
		EndIf


		If (M->B1_TIPO == "PA" .And. !Empty(M->B1_NOME)) .Or. M->B1_TIPO == "PI"
			_cMsg1 := ""
			_cMsg2 := ""
			_cMsg3 := ""
			If M->B1_TIPO # "PA" .And. (Empty(M->B1_GPOREC) .Or. Empty(M->B1_QTDMAQS) .Or. Empty(M->B1_MTZALIM))
				//	Os PAs são tratados pela tabela ZZM.
				_cMsg1 := "Informar Obrigatoriamente os Campos: " + Chr(13) +;
				"   - Gpo.Recurso" + Chr(13) +;
				"   - Qtd.Recurso" + Chr(13) +;
				"   - Mtz.Aliment."
				_lVolta := .F.
			EndIf
			If Empty(M->B1_MTZCOR) .And. Empty(M->B1_MTZDIAM) .And. Empty(M->B1_MTZGRAV) .And. Empty(M->B1_MTZMATP)
				_cMsg2 := "Nenhuma Matriz foi Informada."
			EndIf
			If M->B1_UM # "MT" .And. M->B1_X_FATOR <= 0
				_cMsg3 := "Informar o Fator de Conversão: Quant.de Metros para 1"+M->B1_UM+"."
				_lVolta := .F.
			ElseIf M->B1_UM == "MT" .And. M->B1_X_FATOR > 0
				_cMsg3 := "Para Produtos em METROS não Informar o Fator de Conversão"
				_lVolta := .F.
			EndIf
			If !Empty(_cMsg1)
				_cMsg := Str(_nMsg++,1) + " - " + _cMsg1
			EndIf
			If !Empty(_cMsg2)
				_cMsg := _cMsg  + Chr(13)  + Chr(13) + Str(_nMsg++,1) + " - " + _cMsg2
			EndIf
			If !Empty(_cMsg3)
				_cMsg := _cMsg  + Chr(13)  + Chr(13) + Str(_nMsg++,1) + " - " + _cMsg3
			EndIf
			If !Empty(_cMsg)
				If _lVolta .And. !Empty(_cMsg2) // Só tem a Msg 2 -> DAR UM msgbox
					_lVolta := !(MsgBox(_cMsg,"Retorna para digitação?","YesNo"))
				Else
					Alert(_cMsg)
				EndIf
			EndIf
		ElseIf !Empty(M->B1_GPOREC+M->B1_MTZALIM+M->B1_MTZCOR+;
		M->B1_MTZDIAM+M->B1_MTZGRAV+M->B1_MTZMATP) .Or. M->B1_X_FATOR # 0 .Or. M->B1_QTDMAQS # 0
			Alert("Os dados da Guia Pcp-Fast somente devem ser preenchidos para itens que são fabricados na Cobrecom!")
			_lVolta := .F.
		EndIf

		//Envia Email com os dados do Usuario
		If _lVolta
			//Recebe Usuario que esta dando manutenção Produto  Juliana Leme
			M->B1_ZZUSERI := cData+cHora+cUserName
			//Envia email a cada produto Alterado ou incluido.
			//Se for Alteração
			If Altera
				Processa({||U_EmailProd("A", M->B1_COD, M->B1_TIPO)},"Enviando Email(s), Aguarde...")
			EndIf //Se Inclusão
			If Inclui
				Processa({||U_EmailProd("I", M->B1_COD, M->B1_TIPO)},"Enviando Email(s), Aguarde...")
			EndIf
		EndIf
	endif
Return(_lVolta)

//Função para Limpar campos especificos do cadastro de Produtos quando utilizada a função Copia
//Juliana Leme - 29/12/2014
User Function MTA010NC
	Local aCpos := {}
	aCpos := {"B1_TIPO","B1_NOME","B1_BITOLA","B1_COR","B1_CLASENC","B1_ESPECIA","B1_FORNECE","B1_IDENTIF","B1_GRUPO","B1_DATREF"}
Return aCpos
