#include 'protheus.ch'
#include 'parmtype.ch'
#include "totvs.ch"
#include "rwmake.ch"
#include 'topconn.ch'
#include "tbiconn.ch"

/*/{Protheus.doc} zManEsp
@author bolognesi
@since 21/11/2016
@version 1.0
@param cPed, characters, Numero do pedido que deve ser enviado espelho
@type function
@description Função utilizada no ponto de entrada MT410BRW(), que define funções adicionais
ao menu, esta função esta no menu com o nome: "Email Espelho.", e serve para enviar manualmente
o e-mail com o espelho do pedido.
/*/
User Function zManEsp(cPed) //U_zManEsp('156023') 
	local dataPrt := cbcDadosEspelho():newcbcDadosEspelho()
	default cPed := ""
	if !Empty(cPed)
		if MsgNoYes("Deseja realmente enviar o espelho do pedido para o cliente? ")
			if !dataPrt:emailOrder(cPed):lOk
				Alert('[ERRO] ' + dataPrt:cMsg)
			else
				MsgInfo('[OK] - Envio agendado com sucesso! ')
			endif
		endIF
	endIf
	FreeObj(dataPrt)
return (Nil)

/*/{Protheus.doc} ziniJob
@author bolognesi
@since 21/11/2016
@version 1.0
@param cPed, characters, Numero do pedido
@param nX, numeric, Numero do item atual de envio
@param nCount, numeric, Numero total a ser enviado
@param cFil, characters, Filial
@type function
@description Função utilizada pelo Schedule, chamado pela função
U_zSchMOrd(), esta função inicia um ambiente para enviar o email de um pedido
/*/
User Function ziniJob(cPed,nX,nCount, cFil)
	Local pedMirr	:= Nil	
	Default cFil 	:= FwFilial()
	RPCSetType(3)
	RPCSetEnv('01',cFil,,,'FAT',GetEnvServer(),{} )	
	sleep(200)
	pedMirr := cbcPedido():newcbcPedido(cPed)
	pedMirr:sendMirror(.F.,.T.)
	FreeObj(pedMirr)
	showConsoleMsg("[Matriz] - Envado email Espelho do Pedido " + cPed + " Sendo: " + cValToChar(nX) + " / " + cValToChar(nCount) )	
	RPCClearEnv()
return

/*/{Protheus.doc} zSchMOrd
@author bolognesi
@since 21/11/2016
@version 1.0
@param lEnv, logical, Define se deve ou não iniciar um ambiente, default é não iniciar
@type function
@description Função que obtem atravez de uma query osa dados dos pedido que devem ser enviados
email do espelho, lembrando que este schedule é contingencia, na rotina normal em todas as etapas ocorre
o envio do email, em caso de erro o campo C5_ZZSMAIL é definido como E, que serve de flag para query desta 
função,  desta forma o Schedule somente envia os emails que deram erros no envio normal.
/*/
User Function zSchMOrd(lEnv) // U_zSchMOrd(), U_zSchMOrd( .T. )
	Local 		oSql 		:= SqlUtil():newSqlUtil()
	Local  		nCount		:= 0
	Default 	lEnv 		:= .F.

	If lEnv
		RPCSetType(3)
		RPCSetEnv('01','01',,,'FAT',GetEnvServer(),{} )	
	EndIF
	showConsoleMsg("[Aviso] - Iniciando o schedule Email Espelho do Pedido")
	oSql:addFromTab('SC5')
	oSql:addCampos({'C5_FILIAL','C5_NUM'})
	oSql:addWhere("C5_FILIAL IN ('01','02')"	,'AND')
	oSql:addWhere("C5_EMISSAO >= '20160920'"	,'AND')
	oSql:addWhere("C5_NUM != ''"				,'AND')
	oSql:addWhere("C5_CLIENT != '008918'"		,'AND')
	oSql:addWhere("C5_TIPO <> 'B'"				,'AND')
	oSql:addWhere("C5_ZZSMAIL = 'E'")

	oSql:addOrder({'C5_NUM'},'ASC')

	if oSql:QrySelect():lOk	
		nCount 	:= oSql:nRegCount
		showConsoleMsg("[Aviso] - Encontrado " + cValToChar(nCount) + " pedido(s) que devem ser enviados.")
		For nX := 1 To nCount 
			startJob('U_ziniJob', getenvserver(),.F.,oSql:oRes[nX]:C5_NUM,nX,nCount,oSql:oRes[nX]:C5_FILIAL)
		Next nX
	Else
		showConsoleMsg(oSql:cMsgErro)
	EndIf

	showConsoleMsg("[Aviso] - Finalizado o schedule Email Espelho do Pedido")	

	If lEnv
		RPCClearEnv()
	EndIf
Return

static function showConsoleMsg(cMsg)
	ConOut("[schExpRes - "+DtoC(Date())+" - "+Time()+" ] "+cMsg)
return