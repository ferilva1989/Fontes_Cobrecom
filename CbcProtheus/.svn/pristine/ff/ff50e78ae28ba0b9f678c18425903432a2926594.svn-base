#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch" 
#define CRLF Chr(13)+Chr(10)

*
*********************
User Function MT440AT()
	*********************
	*      
	//Este ponto de entrada é executado antes da visualização da liberação do pedido de venda 
	//e permite ao desenvolvedor impedir a utilização da rotina.
	Local cUserAtu := Alltrim(cUserName)+"|"
	Local cUserLib := GetMv("MV_USERLIB")
	Local cUserAdm := GetMv("MV_USERADM")
	Local lLibera

	lLibera := u_AvalCST(SC5->C5_NUM,.T.)
	If !(SC5->C5_TIPO $ "DB") .And. Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_MSBLQL") == '1' // Sim
		// Solicitação Vânia/Denise e mail de 14/04/2016 14:24h
		MsgInfo("Liberação não Efetuada. Cliente Bloqueado","Ponto Entrada MT440AT")
		lLibera := .F.
	EndIf

	If lLibera
		If M->C5_CLIENTE == "015658" .Or. M->C5_CLIENTE == "016227"	.Or. ;
		M->C5_CLIENTE == "017010" .Or. M->C5_CLIENTE == "017011"	
			// Look ou I.C.A.-> Venda de Vergalhão
			// Em 17/06/14 Vânia solicitou inclusão dos dois clientes abaixo
			// 017010 - DAFMETAL INDUSTRIA E COMERCIO DE METAIS - EIRELI
			// 017011 - LINGOMETAL INDUSTRIA E COM. DE METAIS LTDA        

			lLibera  := .T.
		ElseIf M->C5_TIPO == "N" .And. Left(SC5->C5_AUTORIZ,7)<>'Lib.por' .And. !Empty(SC5->C5_AUTORIZ) .And. !(cUserAtu $ cUserLib+cUserAdm)
			MsgInfo("Somente "+Right(cUserLib,13)+" podem liberar este P.V"+CRLF+"Motivo: "+SC5->C5_AUTORIZ+CRLF+;
			"Solicite ao responsavel que utilize a rotina de Renegociação de P.V" ,"Ponto Entrada MT440AT")
			lLibera := .F.
		ElseIf SC5->C5_CONDPAG == "000" 
			// Veriticar se o Pedido de venda tem a condição de pagamento BNDES - 000 e 
			// Dar um alert pro mané do Silva não esquecer de liberar no site do BNDES
			lLibera := MsgBox("Pedido já liberado no Site do BNDES?","Confirma?","YesNo")
		EndIf            
	EndIf            

	Return(lLibera)     
	*
	***************************************
User Function AvalCST(_cNumPed,_lMensg) // OK 09/10
	***************************************
	*
	Local lLibera  := .T.
	Local nItensN := ""
	Local nItensI := ""


	SC6->(DbSetOrder(1))
	SC6->(DbSeek(xFilial("SC6")+_cNumPed,.F.))
	Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->C6_NUM == _cNumPed .And. SC6->(!Eof())
		If SC6->C6_X_NACIM == "N" .And. Left(SC6->C6_CLASFIS,1) $ "38" //Errado
			nItensN += SC6->C6_ITEM + "/ "
		ElseIf SC6->C6_X_NACIM == "I" .And. Left(SC6->C6_CLASFIS,1) $ "05" //Errado
			nItensI += SC6->C6_ITEM + "/ "
		EndIf
		SC6->(DbSkip())
	EndDo

	If Len(nItensN) > 0                   
		If _lMensg
			MsgInfo("Classificação Fiscal errada para o Movimento"+CRLF+"Motivo: Para Nacionais usar 0 ou 5"+CRLF+;
			"Solicite auxilio ao Setor Fiscal" ,"Ponto Entrada MT440AT")
			MsgInfo("Itens: " + nItensN + "Nacionais com 0 ou 5" ,"Ponto Entrada MT440AT")
		EndIf
		lLibera  := .F.
	EndIf
	If Len(nItensI) > 0
		If _lMensg
			MsgInfo("Classificação Fiscal errada para o Movimento"+CRLF+"Motivo: Para Importados usar 3 ou 8"+CRLF+;
			"Solicite auxilio ao Setor Fiscal" ,"Ponto Entrada MT440AT")
			MsgInfo("Itens: " + nItensN + "Importados com 3 ou 8" ,"Ponto Entrada MT440AT")
		EndIf
		lLibera  := .F.
	EndIf                
	If !_lMensg   
		lLibera := nItensN + nItensI
	EndIf
	Return(lLibera)
	*
	***********************
User Function MT440GR()
	***********************
	*      
	Local aAreaL 	:= getArea()
	Local myaSC6	:= SC6->(Getarea())
	Local myaSC5	:= SC5->(Getarea()) 

	//P.E APÓS A CONFIRMAÇÃO DA LIBERAÇÃO PV. Ao confirmar a Liberação Manual.
	If ParamIXB[1] == 1 // Confirmou a Liberação
		_aDadC5 := {SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_ENTREG,SC5->C5_TIPO}
		u_CDGEN21I(4,,,,_aDadC5) //4-Liberação Pedido (Vendas)

		//Leonardo
		If   !_SetAutoMode() .And. FWCodFil() == "02" .And. SC5->C5_TIPO $ 'N'
			If Posicione("SA1",1,xFilial("SA1")+SC5->(C5_CLIENTE)+SC5->(C5_LOJACLI),"A1_RISCO") == 'A'
				u_pedIndl()
				/*pedindl Realiza as alterações com base na tabela(inclusive alterando o campo ZZPVORI na tabela SC6 )
				problema é que neste momento temos uma tela (acols e aHeader) que depois deste PE serão efetivados na tabela
				invalidando a alteração realizada na pedindl feita.*/
				For nNi := 1 To Len(aCols)

					SC6->( dbgoto( GDFieldGet("C6_REC_WT",nNi)  ) )
					GDFieldPut("C6_ZZPVORI"	, SC6->(C6_ZZPVORI) ,nNi)
					GDFieldPut("C6_SEMANA"		, SC6->(C6_SEMANA) 	,nNi)

				Next nNi

			EndIf
		EndIf
		//Fim
	EndIf

	RestArea(myaSC5)
	RestArea(myaSC6)
	RestArea(aAreaL)
Return(.T.)


User Function MTA410T
	Local pedMirr	:= Nil	
/*
[LEO]-[ESPELHO_PEDIDO]-11/11/2016 - 
1-)Este ponto de entrada (MTA410T), ocorre depois da liberações do pedido (Manual/Automatica).
2-)Melhor momento para enviar o primeiro e unico e-mail de inclusão para o cliente.
3-)Este ponto de entrada tambem é chamado em alguns pontos na inclusão/alteração do pedido
por isso as condições que definem Liberação Manual ou Liberação Automatica e exister na pilha de chamadas
algumas destas funções (a440proces/a440libera).
4-) O inicializador padrão do campo C5_ZZSMAIL é 'N', nenhuma outra rotina define o status para 'N'
o que deve ocorrer somente na inclusão, uma vez enviado o email os status podem variar para S/C/E
o que garante que o email seja enviado somente na primeira liberação, outros emails somente em alterações
de pedidos já liberados.
*/
	If FwIsInCall('a440proces') .Or. FwIsInCall('a440libera')
		If  SC5->(C5_ZZSMAIL) == 'N'  
			pedMirr := cbcPedido():newcbcPedido(SC5->(C5_NUM))
			pedMirr:sendMirror(.F.,.T.)
			FreeObj(pedMirr)
		EndIF
	EndIF
	
/*[LEO]-[ESPELHO_PEDIDO]-11/11/2016 - FIM*/

Return (Nil)

