#include "protheus.ch"
#include "topconn.ch"

// Robert Santos
// funcao principal da baixa e estorno do retrabalho
User Function BAL03ZZE(aRetrab,lBaixar,lCQ,lEnvioCQ)

	Local lRet			:= .F.
	Local cZZEID		:= aRetrab[1] // id retrabalho
	Local nZZELANCES	:= aRetrab[2] // lance saida
	Local nZZEMETRAS	:= aRetrab[3] // metragem saida
	Local cZZEACONDS	:= aRetrab[4] // acondicionamento saida
	Local cPedido 		:= aRetrab[5] // pedido
	Local cItemPv		:= aRetrab[6] // item pv

	Local nTotal		:= (nZZELANCES * nZZEMETRAS)
	Local cB1COD		:= padr(aRetrab[7],TamSx3("B1_COD")[1])

	ZZE->(dbsetorder(2)) // Filial + Id + Pedido + Item
	If !empty(cZZEID) // Retrabalho Informado
		If ZZE->(DBSEEK(XFILIAL("ZZE") + cZZEID))
			If ZZE->ZZE_STATUS $ "9/1/2" // VALIDAR STATUS CRITICO DE OPERACOES - CANCELADO, AGUARDANDO SEPARAR, AGUARDANDO ORDEM SERVICO
				Alert("Este retrabalho está bloqueado para uso. Status atual: '" + u__RtStat(ZZE->ZZE_STATUS) + "'")
				lRet := .F.
			Else
				If lCq // É CQ
					If lBaixar // É Baixa
						If lEnvioCq // É envio para cQ
							lRet := EnvCQ(cB1COD,cZZEID,cPedido,cItemPv,cZZEACONDS,nZZEMETRAS,nZZELANCES) // Envio CQ
						Else   
							lRet := BxCQ(cB1COD,cZZEID,cPedido,cItemPv,cZZEACONDS,nZZEMETRAS,nZZELANCES) // Baixar do CQ para o Estoque
						EndIf
					Else                 
						lRet := CancelCq(cZZEID,cPedido,cItemPv,cZZEACONDS,nZZEMETRAS,nZZELANCES) // Estorno do CQ
					EndIf
				Else 
					If lBaixar // É Baixa
						lRet := BxEstoque(cB1COD,cZZEID,cPedido,cItemPv,cZZEACONDS,nZZEMETRAS,nZZELANCES) // Baixar para Estoque
					Else                      
						lRet := EsEstoque(cZZEID,cPedido,cItemPv,cZZEACONDS,nZZEMETRAS,nZZELANCES) // Estorno de baixa para Estoque
					EndIf
				EndIf
			EndIf
		Else
			Alert("Retrabalho: '" + cZZEID + "' não encontrado!")
			lRet := .F.
		EndIf
		AtuStatus(cZZEID,lBaixar)
	Else
		Alert("Favor informar o retrabalho!")
		lRet := .F.
	EndIf

	u_AtuStZZF(cZZEID)

return lRet


Static Function BxEstoque(cB1_COD,cZZE_ID,cPedido,cItem,cZZE_ACONDS,nZZE_METRAS,nZZE_LANCES)

	Local lEstoque	:= (cPedido == "000001")  
	Local lPlajdo	:= .F. // Indicar retorno de retrabalho planejado
	Local lRet		:= .F. // sucesso == .T.

	If lEstoque // é devolucao para estoque
		lPlajdo	:= .F.
		If ZZE->(DBSEEK(XFILIAL("ZZE") + cZZE_ID + cPedido)) // planejado
			// If ZZE->ZZE_SALDO >= (nZZE_METRAS * nZZE_LANCES)
			Do While (XFILIAL("ZZE") + cZZE_ID + cPedido) == ZZE->(ZZE_FILIAL + ZZE_ID + ZZE_PEDIDO) .AND. !ZZE->(EOF())
				If ZZE->ZZE_ACONDS == cZZE_ACONDS .and. ZZE->ZZE_METRAS == nZZE_METRAS .and. ZZE->ZZE_LANCES == nZZE_LANCES .AND. ZZE->ZZE_PEDIDO == "000001"
					lPlajdo	:= .T.
					Exit
				EndIf
				ZZE->(dbskip())
			enddo
			// EndIf
		EndIf
		If lPlajdo // Retorno de estoque planejado
			lRet := EfetvEst(nZZE_METRAS * nZZE_LANCES, .F., cZZE_ID,nZZE_METRAS) // Baixar retrabalho para estoque
		Else        
			lRet := CriarEst(cZZE_ID,cZZE_ACONDS,nZZE_METRAS,nZZE_LANCES,.F.) // Gerar retorno de retrabalho nao planejado podendo baixar o estoque ou nao
		EndIf
	Else // baixa de item
		If ZZE->(DBSEEK(XFILIAL("ZZE") + cZZE_ID + cPedido + cItem))
			lRet := EfetvEst(nZZE_METRAS * nZZE_LANCES, .T., cZZE_ID,nZZE_METRAS) // Baixar retrabalho para estoque
		Else
			Alert("Retrabalho/ Pedido/ Item/ não localizado!")
			lret := .F.
		EndIf
	EndIf

return lRet


static function EfetvEst(nTotal,lPedido,cZZE_ID,nZZE_METRAS) // Sempre enviar posicionado no ZZE

	Local lRet := .F.

	//If ZZE->ZZE_SALDO >= nTotal
	// Baixar do 90 para o 01	
	ZZE->(RecLock("ZZE",.F.))
	ZZE->ZZE_DEVTOT += nTotal
	If lPedido
		ZZE->ZZE_DEVPED += nTotal
	EndIf                       
	ZZE->ZZE_DEVLAN += Int(nTotal / nZZE_METRAS)
	ZZE->(msunlock())

	Ajustarsaldo(cZZE_ID,nTotal,.T.)
	lRet := .T.
	//Else 
	//	Alert("Sem saldo suficiente no retrabalho!")
	//	lRet := .F.
	//EndIf

return lRet             


static function CriarEst(cZZE_ID,cZZE_ACONDS,nZZE_METRAS,nZZE_LANCES,lEnvioCq) // Gerar um retorno nao planejado pondendo baixar do 90 para o 01 quando nao envia para CQ

	Local cZZEPRODUT, cZZEORDEM, cZZENUMBOB
	Local cZZEACONDE, nZZESALDO
	Local nZZEMETRAE
	Local nZZELANCEE
	Local nZZETOTEN
	Local lRet := .t. 

	If ZZE->(DbSeek(XFILIAL("ZZE") + cZZE_ID)) // REFAZER SALDO
		cZZEPRODUT	:= ZZE->ZZE_PRODUT
		cZZEACONDE	:= ZZE->ZZE_ACONDE
		nZZEMETRAE	:= ZZE->ZZE_METRAE
		nZZELANCEE	:= ZZE->ZZE_LANCEE
		nZZETOTEN	:= ZZE->ZZE_TOTEN
		cZZEORDEM	:= ZZE->ZZE_ORDEM
		cZZENUMBOB	:= ZZE->ZZE_NUMBOB
		nZZESALDO	:= ZZE->ZZE_SALDO
		dZZEDTINI   := ZZE->ZZE_DTINI

		If lEnvioCq == .F.
			// Baixar do 90 para o 01
		EndIf

		ZZE->(RECLOCK("ZZE",.T.))
		ZZE->ZZE_FILIAL	:= XFILIAL("ZZE")
		ZZE->ZZE_ID		:= cZZE_ID
		ZZE->ZZE_STATUS	:= "A" // STATUS NAO PLANEJADO PARA O ESTOQUE
		ZZE->ZZE_PRODUT	:= cZZEPRODUT
		ZZE->ZZE_ACONDE	:= cZZEACONDE
		ZZE->ZZE_METRAE	:= nZZEMETRAE
		ZZE->ZZE_LANCEE	:= nZZELANCEE
		ZZE->ZZE_TOTEN	:= nZZETOTEN
		ZZE->ZZE_ACONDS	:= cZZE_ACONDS
		ZZE->ZZE_METRAS	:= nZZE_METRAS
		ZZE->ZZE_LANCES	:= nZZE_LANCES
		ZZE->ZZE_TOTSA	:= nZZE_LANCES * nZZE_METRAS
		ZZE->ZZE_PEDIDO	:= "000001"
		ZZE->ZZE_ITEMPV	:= "99"
		ZZE->ZZE_DEVLAN	:= ZZE->ZZE_LANCES
		ZZE->ZZE_DEVTOT	:= ZZE->ZZE_TOTSA
		ZZE->ZZE_ORDEM	:= cZZEORDEM
		ZZE->ZZE_NUMBOB	:= cZZENUMBOB
		ZZE->ZZE_SALDO	:= nZZESALDO
		ZZE->ZZE_ETIQ	:= "S"
		ZZE->ZZE_SITUAC	:= '2'
		ZZE->ZZE_DTINI  := dZZEDTINI

		If lEnvioCq
			ZZE->ZZE_TOTCQ	:= ZZE->ZZE_TOTSA
		EndIf
		ZZE->(MSUNLOCK())
		Ajustarsaldo(cZZE_ID,ZZE->ZZE_TOTSA,.T.)
	EndIf

return lRet

static function Ajustarsaldo(cZZE_ID,nTotal,lAbater)
	If ZZE->(DBSEEK(XFILIAL("ZZE") + cZZE_ID)) // REFAZER SALDO
		Do While ZZE->(ZZE_FILIAL + ZZE_ID) == xFilial("ZZE") + cZZE_ID .AND. !ZZE->(EOF())
			ZZE->(RECLOCK("ZZE",.F.))
			If lAbater
				ZZE->ZZE_SALDO -= nTotal
			Else
				ZZE->ZZE_SALDO += nTotal
			EndIf                 
			ZZE->(msunlock())
			ZZE->(dbskip())
		enddo
	EndIf
return

Static function EnvCq(cB1_COD,cZZE_ID,cPedido,cItem,cZZE_ACONDS,nZZE_METRAS,nZZE_LANCES)

	Local lEstoque	:= (cPedido == "000001")
	Local lPlajdo	:= .F. // Indicar retorno de retrabalho planejado
	Local lRet		:= .F. // sucesso == .T.
	Local lMarkZZE	:= .F.

	If lEstoque // é devolucao para estoque
		lPlajdo	:= .F.
		If ZZE->(DBSEEK(XFILIAL("ZZE") + cZZE_ID + cPedido)) // planejado
			If ZZE->ZZE_SALDO >= (nZZE_METRAS * nZZE_LANCES)
				Do While (XFILIAL("ZZE") + cZZE_ID + cPedido) == ZZE->(ZZE_FILIAL + ZZE_ID + ZZE_PEDIDO) .AND. !ZZE->(EOF())
					If ZZE->ZZE_ACONDS == cZZE_ACONDS .and. ZZE->ZZE_METRAS == nZZE_METRAS .and. ZZE->ZZE_LANCES == nZZE_LANCES
						lPlajdo	:= .T.
						Exit
					EndIf
					ZZE->(dbskip())
				enddo
			EndIf
		EndIf
		If lPlajdo // Retorno de estoque planejado
			lMarkZZE := .T.
		Else        
			lRet := CriarEst(cZZE_ID,cZZE_ACONDS,nZZE_METRAS,nZZE_LANCES,.T.) // Gerar retorno de retrabalho nao planejado podendo baixar o estoque ou nao
		EndIf
	Else // baixa de item
		If ZZE->(DBSEEK(XFILIAL("ZZE") + cZZE_ID + cPedido + cItem))
			If ZZE->ZZE_SALDO >= (nZZE_METRAS * nZZE_LANCES)
				lMarkZZE := .T.
			Else       
				Alert("Retrabalho sem saldo suficiente para baixar!")
				lRet := .F.
			EndIf
		Else
			Alert("Retrabalho/ Pedido/ Item/ Não localizado!")
			lRet := .F.
		EndIf
	EndIf
	If lMarkZZE // marcar item para envio ao CQ ?
		ZZE->(RecLock("ZZE",.F.))
		ZZE->ZZE_DEVTOT	+= (nZZE_METRAS * nZZE_LANCES)
		ZZE->ZZE_TOTCQ	+= (nZZE_METRAS * nZZE_LANCES)
		ZZE->ZZE_DEVLAN += Int(nZZE_METRAS * nZZE_LANCES / nZZE_METRAS)
		ZZE->(msunlock())
		Ajustarsaldo(cZZE_ID,nZZE_METRAS * nZZE_LANCES,.T.)
		lRet := .T.
	EndIf
return lRet

static function BxCq(cB1_COD,cZZE_ID,cPedido,cItemPv,cZZE_ACONDS,nZZE_METRAS,nZZE_LANCES)
	Local lRet := .F.
	ZZE->(DBSEEK(XFILIAL("ZZE") + cZZE_ID + cPedido + cItemPv))
	Do While (XFILIAL("ZZE") + cZZE_ID + cPedido + cItemPv) == ZZE->(ZZE_FILIAL + ZZE_ID + ZZE_PEDIDO + ZZE_ITEMPV) .AND. !ZZE->(EOF())
		If ZZE->ZZE_TOTCQ >= (nZZE_METRAS * nZZE_LANCES) // Tem no CQ ?
			// Baixar do 90 para 01
			ZZE->(RecLock("ZZE",.F.))
			ZZE->ZZE_TOTCQ	-= (nZZE_METRAS * nZZE_LANCES)
			If ZZE->ZZE_PEDIDO != "000001"
				ZZE->ZZE_DEVPED += (nZZE_METRAS * nZZE_LANCES)
			EndIf
			ZZE->(msunlock())
			lRet := .T.
			Exit
		EndIf
		ZZE->(dbskip())
	enddo      
	If lRet == .F.
		Alert("Produto x metragem x Lance com saldo não localizado em retrabalho!")
	EndIf
return lRet

static function EsEstoque(cZZEID,cPedido,cItemPv,cZZEACONDS,nZZEMETRAS,nZZELANCES)
	Local lEstoque	:= (cPedido == "000001")  
	Local lNPlajdo	:= .F. // Indicar retorno de retrabalho planejado
	Local lRet		:= .F. // sucesso == .T.

	If lEstoque // é devolucao para estoque
		lNPlajdo	:= .F.
		If ZZE->(DBSEEK(XFILIAL("ZZE") + cZZEID + cPedido)) // planejado
			//If ZZE->ZZE_SALDO >= (nZZEMETRAS * nZZELANCES)
			Do While (XFILIAL("ZZE") + cZZEID + cPedido) == ZZE->(ZZE_FILIAL + ZZE_ID + ZZE_PEDIDO) .AND. !ZZE->(EOF())
				If ZZE->ZZE_ACONDS == cZZEACONDS .and. ZZE->ZZE_METRAS == nZZEMETRAS .and. ZZE->ZZE_LANCES == nZZELANCES .and.ZZE->ZZE_PEDIDO == "000001"
					lNPlajdo	:= (ZZE->ZZE_STATUS == "A")
					lret := .T.
					Exit
				EndIf
				ZZE->(dbskip())
			enddo
			//EndIf
		EndIf  
		If lRet
			If lNPlajdo == .T. // Retorno de estoque planejado
				ZZE->(RECLOCK("ZZE",.F.))
				ZZE->(DBDELETE())
				ZZE->(MSUNLOCK())
			Else                    
				If ZZE->ZZE_DEVTOT >= (nZZEMETRAS * nZZELANCES)
					ZZE->(RECLOCK("ZZE",.F.))
					ZZE->ZZE_DEVTOT -= (nZZEMETRAS * nZZELANCES)
					ZZE->ZZE_DEVLAN -= Int((nZZEMETRAS * nZZELANCES) / nZZEMETRAS)
					ZZE->ZZE_DEVPED -= (nZZEMETRAS * nZZELANCES)
					ZZE->(MSUNLOCK()) 
				Else
					Alert("Atenção este retrabalho não pode ser estornado, pois o saldo de baixa é inferior ao requisitado em devolução!")
					lRet := .F.
				EndIf
			EndIf
		Else
			Alert("Retrabalho/ Pedido/ Item/ não localizado!")
			lret := .F.
		EndIf
	Else // baixa de item
		If ZZE->(DBSEEK(XFILIAL("ZZE") + cZZEID + cPedido + cItemPv))    
			If ZZE->ZZE_DEVTOT >= (nZZEMETRAS * nZZELANCES)
				ZZE->(RECLOCK("ZZE",.F.))
				ZZE->ZZE_DEVTOT -= (nZZEMETRAS * nZZELANCES)
				ZZE->ZZE_DEVLAN -= Int((nZZEMETRAS * nZZELANCES) / nZZEMETRAS)
				ZZE->ZZE_DEVPED -= (nZZEMETRAS * nZZELANCES)
				ZZE->(MSUNLOCK())
				lret := .T.   
			Else
				Alert("Atenção este retrabalho não pode ser estornado, pois o saldo de baixa é inferior ao requisitado em devolução!")
				lRet := .F.
			EndIf
		Else
			Alert("Retrabalho/ Pedido/ Item/ não localizado!")
			lret := .F.
		EndIf
	EndIf
	If lRet
		AjustarSaldo(cZZEID,(nZZEMETRAS * nZZELANCES),.F.)
		// Mover do 01 Para 90
	EndIf
return lRet      

static function CancelCq(cZZEID,cPedido,cItemPv,cZZEACONDS,nZZEMETRAS,nZZELANCES)
	Local lRet := .F.
	ZZE->(DBSEEK(XFILIAL("ZZE") + cZZEID + cPedido + cItemPv))
	Do While (XFILIAL("ZZE") + cZZEID + cPedido + cItemPv) == ZZE->(ZZE_FILIAL + ZZE_ID + ZZE_PEDIDO + ZZE_ITEMPV) .AND. !ZZE->(EOF())
		If ZZE->ZZE_TOTCQ >= (nZZEMETRAS * nZZELANCES) // Tem no CQ ?
			// Baixar do 90 para 01
			ZZE->(RecLock("ZZE",.F.))
			If ZZE->ZZE_STATUS == "A" // CANCELAMENTO DE RETORNO NAO PLANEJADO
				ZZE->(dbdelete())
			Else
				ZZE->ZZE_TOTCQ	-= (nZZEMETRAS * nZZELANCES)
				ZZE->ZZE_DEVTOT -= (nZZEMETRAS * nZZELANCES)
				ZZE->ZZE_DEVLAN -= Int((nZZEMETRAS * nZZELANCES) / nZZEMETRAS)
				ZZE->ZZE_SITUAC	:= '2'
			EndIf
			ZZE->(msunlock())
			Ajustarsaldo(cZZEID,nZZEMETRAS * nZZELANCES,.F.)
			lRet := .T.
			Exit
		EndIf
		ZZE->(dbskip())
	enddo      
	If lRet == .F.
		Alert("Produto x metragem x Lance com saldo não localizado em retrabalho!")
	EndIf
return lRet

static function AtuStatus(cZZE_ID, lBaixa)
	ZZE->(DBSEEK(XFILIAL("ZZE") + cZZE_ID))
	Do While (XFILIAL("ZZE") + cZZE_ID) == ZZE->(ZZE_FILIAL + ZZE_ID) .AND. !ZZE->(EOF())
		If !(ZZE->ZZE_STATUS $ "1/2/9/A") // NAO ESTA EM AGUARDANDO (1,2) CANCELADO(9) E RETORNO NAO PLANEJADO
			ZZE->(RecLock("ZZE",.F.))
			If ZZE->ZZE_TOTSA == ZZE->ZZE_DEVPED .AND. ZZE->ZZE_TOTCQ <= 0
				ZZE->ZZE_STATUS := "4" // REALIZADO (FINALIZADO) COM TODOS ITENS ATENDIDOS
			ElseIf ZZE->ZZE_TOTSA > 0 .and. ZZE->ZZE_STATUS == "4" .and. lBaixa == .F.
				ZZE->ZZE_STATUS := "3" // EM RETRABALHO
			EndIf
			ZZE->(msunlock())
		EndIf
		ZZE->(dbskip())
	enddo      
return

user function AtuStZZF(cZZEID) // Atualiza status da separacao de acordo com o Retrabalho
	Local cqry, nqry, cStZF
	Local cSt := ""
	ZZE->(dbsetorder(1)) 
	ZZF->(dbsetorder(2))
	If ZZE->(dbseek(XFILIAL("ZZE") + cZZEID))
		If !(ZZE->ZZE_STATUS $ "1/2") // ENTROU NO RETRABALHO ??
			If ZZF->(dbseek(XFILIAL("ZZE") + cZZEID))
				cqry := " SELECT DISTINCT (CASE WHEN ZZE_DEVTOT > 0 AND ZZE_STATUS = '3' THEN '4' Else ZZE_STATUS END) AS ZZE_STATUS " + CRLF // TRATAR APONTAMENTO PARCIAL COMO FECHADO
				cqry += " FROM " + RetSqlName("ZZE") + " ZZE " + CRLF
				cqry += " WHERE " + CRLF
				cqry += " ZZE_FILIAL =  '" + ZZE->ZZE_FILIAL + "'  AND " + CRLF
				cqry += " ZZE_ID = '" + ZZE->ZZE_ID + "' AND " + CRLF
				cqry += " D_E_L_E_T_ = ' ' "

				iif( select("ZZEX") > 0, ZZEX->(dbclosearea()),  )
				tcquery cqry new alias "ZZEX"
				count to nqry
				If nqry > 0
					ZZEX->(dbgotop())
					Do While !ZZEX->(EOF())
						cSt += ZZEX->ZZE_STATUS
						ZZEX->(dbskip())
					enddo
				EndIf
				ZZEX->(dbclosearea())

				do case
					case "3" == cSt .or. "39" == cSt // todos em aberto
					cStZf := "4" // falta baixar separacao
					case "4" == cSt .OR. "49" == cST // todos finalizados
					cStZf := "9" // todos apontados corretamente
					case "3" $ cSt .and. ("4" $ cSt .or. "A" $ cSt .or. "B" $ cSt) // parcialmente atendido
					cStZf := "8" // retrabalho parcialmente fechado
					case "9" == cST // TODOS CANCELADOS
					cStZf := "Y" // TODOS CANCELADOS
					case "4" $ cSt .or. "A" $ cSt .or. "B" $ cSt 
					cStZf := "9" // retrabalho todo apontado
				endcase 
				/*
				"ZZF_STATUS == '2'", "BR_AMARELO"	}) // AGUARDANDO SEPARAR
				"ZZF_STATUS == 'A'", "BR_MARROM"	}) // DIRETO FATURAMENTO
				"ZZF_STATUS == '3'", "BR_AZUL"	}) // ORDEM NAO IMPRESSA
				"ZZF_STATUS == '4'", "BR_PINK"	}) // ORDEM IMPRESSA
				"ZZF_STATUS == '5'", "BR_LARANJA"	}) // ORDEM PARCIAL
				"ZZF_STATUS == '6'", "BR_VIOLETA"}) // ORDEM SEPARADA TOTAL BAIXADA
				"ZZF_STATUS == '7'", "BR_BRANCO"	}) // ORDEM RETRABALHO IMPRESSO
				"ZZF_STATUS == '8'", "BR_CINZA"	}) // ORDEM RETRABALHO PARCIAL
				"ZZF_STATUS == '9'", "BR_PRETO"	}) // ORDEM RETRABALHO TOTAL
				"ZZF_STATUS == 'X'", "BR_VERMELHO"	}) // CANCELADO  
				"ZZF_STATUS == 'Y'", "BR_VERDE"	}) // RETRABALHO CANCELADO - FALTA CANCELAR SEPARACAO
				*/
				/*
				,{"ZZE_STATUS == '1'","BR_VERMELHO"}) // AGUARD. SEPARAR
				,{"ZZE_STATUS == '2'","BR_AZUL"}) // AGUARD. ORDEM DE SERVICO
				,{"ZZE_STATUS == '3'","BR_AMARELO"}) // EM RETRABALHO ..
				,{"ZZE_STATUS == '4'","BR_VERDE"}) // FINALIZADO
				,{"ZZE_STATUS == '9'","BR_MARRON"}) // CANCELADO
				,{"ZZE_STATUS == 'A'","BR_VIOLETA"}) // RETORNO NÃO PLANEJADO PARA ESTOQUE
				,{"ZZE_STATUS == 'B'","BR_CINZA"}) // FINALIZADO SEM ATENDER TODO O PEDIDO
				*/        
				If !empty(cStZf)
					ZZF->(RECLOCK("ZZF",.F.))
					ZZF->ZZF_STATUS := cStZF
					ZZF->(MSUNLOCK())
				EndIf
			EndIf
		EndIf
	EndIf
return