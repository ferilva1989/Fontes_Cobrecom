#include "TOPCONN.ch"
#include "protheus.ch"
#Define linha chr(13)+chr(10)


*
****************************
User Function FA430OCO()    
	****************************
	*
	Local aArea		:= GetArea()
	Local aSE2Area	:= SE2->(GetArea())	
	Local cEmail	:= 'ctaspagar@cobrecom.com.br'
	Local cMsg		:= ""
	/*Leonardo Bolognesi - 23/11/2015 - Ponto de entrada para tratar a condição existente no retorno do Cnab Contas a Pagar onde em um dia
	o banco retorno o status BW-Pagamento Efetuado (O sistema normalmente realiza a baixa) dois dias depois o banco retorna para o mesmo titulo 
	o status JB-DOC/TED Estornado (Neste caso o correto seria o sistema canelar a baixa), mas este processo tem que ser feito por este ponto
	de entrada. (Verificar a possibilidade de mandar um e-mail avisando o estorno)*/

	//Controle sobre a funcionalidade
	If GetMV("MV_FINBWJB")
		aVlr	:= PARAMIXB[1]

		//Ocorrencia banco (JB=Estorno DOC/TED devolvido)
		If Alltrim(aVlr[12]) $ 'JB' .And. !Empty(aVlr[1]) 

			DbSelectArea("SE2")
			SE2->(dbSetOrder(11)) // Filial+IdCnab	

			If  SE2->(DbSeek( xFilial("SE2") + Substr(aVlr[1],1,10), .T.))                       

				cMsg	+= " O Titulo numero: " 	+ Alltrim(SE2->(E2_NUM)) 					+ linha
				cMsg	+= " Parcela: "			+ Alltrim(SE2->(E2_PARCELA)) 					+ linha 
				cMsg	+= " Cliente: "			+ Alltrim(SE2->(E2_NOMFOR))						+ linha
				cMsg	+= " Vencimento: "		+ dToC(SE2->(E2_VENCREA))						+ linha

				//Verificar se o titulo a ser estornado já esta baixado (Em testes avisar, depois desenvolver cancelar baixa execauto)
				If !Empty(SE2->(E2_BAIXA))
					//Esta baixado (Cancelar Baixa)
					cMsg	+= "Baixado em: "		+ dToC(SE2->(E2_BAIXA))	+ linha
					cMsg	+= "Foi estornado pelo banco, providenciar o cancelamento da baixa! "  		
					u_envmail({cEmail}, "[Estorno Titulo Ctas. Pagar] - Titulo foi estornado no retorno CNAB  Fin-Pagar", {"Rotina","Linha","Função","Fonte","Obs"},{{"FINA430",cValToChar(ProcLine(0)),"FA430OCO()","PE_FINA430.PRW",cMsg}} )

					/*Rotina de Estornar a Baixa */

					MessageBox(cMSg,'[Aviso]',48)		
				Else
					//Não esta baixado
					cMsg	+= "Foi estornado pelo banco, mas não esta baixado no sistema, verificar! "  		
					MessageBox(cMSg,'[Aviso]',48)

				EndIf		

			EndIf

		EndIf

	EndIf
	RestArea(aSE2Area)
	RestArea(aArea)

Return Nil                       