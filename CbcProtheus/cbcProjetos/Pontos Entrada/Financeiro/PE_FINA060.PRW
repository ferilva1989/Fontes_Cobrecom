#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch" 

//Fina060
//Rotina de transferencia e bordero do contas a receber

//|--------------------------------------------------------------------------------------------------|
//|                                  BOTÃO  TRANSFERENCIA                                            |
//|--------------------------------------------------------------------------------------------------|
*
**********************
User Function F060OK()
	**********************
	*      
	//|-----------------------------------------------------------------------------------------|
	//| PE F060OK                                                                               |     
	//| Chamado pelo botão de confirmação da rotina de TRANSFERENCIAS                           |
	//|-----------------------------------------------------------------------------------------|

	Local _aArea := GetArea()
	Local aDados := aClone(ParamIxb)


	If !ParamIxb[1] $ "012F"
		MsgInfo("Situação ( " +Alltrim(ParamIxb[1])+ " ) bloqueada, selecione outra!!!","Ponto Entrada F060OK")
		Return(.F.)
		//ElseIf Alltrim(ParamIxb[2]) == "000" .And. ParamIxb[1] # "2"
		//	MsgInfo("Para Banco Jackson, somente pode ser cobrança descontada!!!","Ponto Entrada F060VBCO")
		//	Return(.F.)
	ElseIf Alltrim(ParamIxb[2]) == "000" .And. ParamIxb[1] # "1"
		MsgInfo("Para Banco Jackson, somente pode ser cobrança simples!!!","Ponto Entrada F060VBCO")
		Return(.F.)
	ElseIf Alltrim(ParamIxb[2]) == "RAF" .And. ParamIxb[1] # "1"
		MsgInfo("Para Banco RAF, somente pode ser cobrança simples!!!","Ponto Entrada F060OK")
		Return(.F.)
	EndIf
	//|--------------------------------------------------------------------------------------------|
	//| Toda confirmação de transferencia passa aqui.                                              |
	//| VALOR -> nValCred p/ transferencia de desconto                                             |
	//| VALOR -> nValDesc p/ transferencia de desconto p/ carteira                                 |
	//| Na IFC para o banco 000, o valor da transferencia tem que ser exatamente o valor do titulo |
	//|--------------------------------------------------------------------------------------------|
	_nSaldo  := SALDOTIT(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R")
	If (ParamIxb[1] == "2" .Or. (ParamIxb[1] == "0" .And. SE1->E1_SITUACA == "2")) .And. (VALOR # _nSaldo)//Descontada ou Descontada p/ branco
		MsgInfo("Valores não conferem, selecione a situação e verifique o valor.","Ponto Entrada F060OK")
		Return(.F.)
	EndIf


	RestArea(_aArea)
	Return(.T.) 

	*
	************************
User Function FA60SIT2()
	************************
	*// Chamado na transferencia de um titulo que está em bordero.
	// Permite manipulacao do SE5 neste momento 
	Local _aArea   := GetArea()
	Local _aAreaE5 := SE5->(GetArea())

	If !SE5->(Eof()) .And. !Empty(SE1->E1_NUMBOR) .And. SE1->E1_SITUACA == "2" 
		RecLock("SE5",.F.) 
		SE5->E5_DOCUMENT := SE1->E1_NUMBOR
		MsUnlock()
	EndIf
	RestArea(_aAreaE5)
	RestArea(_aArea)

	Return(.T.)


	//|--------------------------------------------------------------------------------------------------|
	//|                                  BOTÃO  BORDERO                                                  |
	//|--------------------------------------------------------------------------------------------------|
	*
	************************
User Function F060VBCO()
	************************
	*      
	//|-----------------------------------------------------------------------------------------|
	//| PE F060VBCO                                                  							|
	//| Utilizado para validacoes extras do usuario na                                          |
	//| confirmação da rotina de BORDERO antes da seleção dos tit.                              |
	//|-----------------------------------------------------------------------------------------|

	Local _aArea := GetArea()

	If !Left(ParamIxb[4],1) $ "012F"
		MsgInfo("Situação (" +Alltrim(ParamIxb[4])+ ") bloqueada, selecione outra!!!","Ponto Entrada F060VBCO")
		Return(.F.)
		//ElseIf Alltrim(ParamIxb[1]) == "000" .And. Left(ParamIxb[4],1) # "2"
		//	MsgInfo("Para Banco Jackson, somente pode ser cobrança descontada!!!","Ponto Entrada F060VBCO")
		//	Return(.F.)
	ElseIf Alltrim(ParamIxb[2]) == "000" .And. ParamIxb[1] # "1"
		MsgInfo("Para Banco Jackson, somente pode ser cobrança simples!!!","Ponto Entrada F060VBCO")
		Return(.F.)
	ElseIf Alltrim(ParamIxb[1]) == "RAF" .And. Left(ParamIxb[4],1) # "1"
		MsgInfo("Para Banco RAF, somente pode ser cobrança simples!!!","Ponto Entrada F060VBCO")
		Return(.F.)
	EndIf

	RestArea(_aArea)
	Return(.T.)

	*
	************************
User Function FA060SE5()
	************************
	*
	//|-----------------------------------------------------------------------------------------|
	//| PE após confirmação da rotina de BORDERO, após gravação do SE5, que está posicionado    |
	//| VALOR  = Valor digitado na tela de geração do SE5                                       |
	//| nValor = Valor total do bordero.                                                        |
	//| Após o PE tem o ATUSaldoBCO.                                                            |
	//|-----------------------------------------------------------------------------------------|
	Local _aArea   := GetArea()
	Local _aAreaE5 := SE5->(GetArea())

	If cPort060 == "000" .And. !SE5->(Eof()) .And. VALOR # nValor  //Só se for cobrança descontada e posicionado no SE5
		RecLock("SE5",.F.)
		SE5->E5_VALOR   := nValor
		SE5->E5_VLMOED2 := nValor
		MsUnlock()
	EndIf
	RestArea(_aAreaE5)
	RestArea(_aArea)
	Return 

	*
	***********************
User Function F060VLZ()
	***********************
	*
	// Tratamento caso um titulo esteja em bordero, e chamar a rotina de transferencia.

	Local _aArea   := GetArea()
	Public _lFirst := .T. // Utilizado no PE FA060Can1

	// Valor que será mostrado na tela de geração do SE5
	If Alltrim(procName(3)) == "FA060VERSIT"         //Transferindo titulo de bordero de cobranca descontada para simples
		nValDesc:= SALDOTIT(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_NATUREZ,"R")//SE1->E1_VALOR
	ElseIf Alltrim(procName(3)) == "FA060CANC"   	 //Cancelamento de Bordero 
		nValDesc := fSaldoBord()
	EndIf            

	RestArea(_aArea)

	Return(.T.)

	*
	************************
User Function FA60Can1() 
	************************
	*                                                                                            
	//|-----------------------------------------------------------------------------------------|
	//| Botão de Cancelamento Bordero ( após tela estorno E5 ) 								    |
	//| Esta em um loop, chama N vezes.                                                         |
	//| nValDesc = valor digitado pelo usuario na tela de estorno                               |
	//| Neste ponto tenho que garantir que o valor do estorno seja igual ao saldo do bordero    |
	//| Se .F. não tira de bordero mais gera E5, então tem que corrigir o valor neste momento.  |
	//|-----------------------------------------------------------------------------------------|
	Local _aArea := GetArea()
	Local cMsg	:= ""

	//LEONARDO 19/06/2015 - DESCOBRIR QUEM ESTA CANCELANDO OS BORDEROS
	cMsg += "Filial:  	"  + Alltrim(SE1->(E1_FILIAL)) 					+ Chr(13)+Chr(10)
	cMsg += "Cliente:  	"  + Alltrim(SE1->(E1_CLIENTE)) 				+ Chr(13)+Chr(10)
	cMsg += "Titulo:  	"  + Alltrim(SE1->(E1_NUM)) 					+ Chr(13)+Chr(10)
	cMsg += "Parcela: 	"  + Alltrim(SE1->(E1_PARCELA)) 				+ Chr(13)+Chr(10)
	cMSg += "ZZBOR1:	"  + Alltrim(SE1->(E1_ZZBOR1)) 					+ Chr(13)+Chr(10)
	cMsg += "ZZBC2:		"  + Alltrim(SE1->(E1_ZZBC2))					+ Chr(13)+Chr(10) 
	cMsg += "Usuario:	"  + cUserName									+ Chr(13)+Chr(10)
	cMsg += "Fonte PE_FINA060.PRW - Função FA60Can1()	"  				+ Chr(13)+Chr(10)

	U_ConsoleLog("Erro",cMsg, "CancBord")
	U_ArqPorEmail("CancBord","wfti@cobrecom.com.br","[Aviso] - Cancel. Bord. Ctas. Receber" )
	//FIM LEONARDO

	/*
	If SE1->E1_DATABOR < Date()
	Return(.F.)
	EndIf
	*/
	If SE1->E1_SITUACA == "2" .And. _lFirst
		_lFirst  := .F.
		nValDesc := fSaldoBord()
	EndIf           

	RestArea(_aArea)
	Return(.T.)            

	*
	****************************
Static Function fSaldoBord()
	****************************
	*             
	// Somatoria do saldo do bordero para fazer o movimento de estorno

	Local _aAreaEA := SEA->(GetArea())
	Local _aAreaE1 := SE1->(GetArea())

	_nSaldo  := 0
	_cNumBor := mv_par01
	SEA->(DbSeek(xFilial("SEA")+mv_par01,.F.))
	Do While !SEA->(Eof()) .And. SEA->EA_FILIAL == xFilial("SEA") .And. SEA->EA_NUMBOR == _cNumBor
		_nSaldo += Posicione("SE1",1,xFilial("SE1")+SEA->EA_PREFIXO+SEA->EA_NUM+SEA->EA_PARCELA+SEA->EA_TIPO,"E1_SALDO")
		SEA->(DbSkip())
	EndDo

	RestArea(_aAreaE1)
	RestArea(_aAreaEA)    

	Return(_nSaldo)
	*
	*****************************
User Function TRCFluxo(_cArq)
	*****************************
	*
	_Volta:=""
	If _cArq == "SE1"
		cQuery := ""
		cQuery := " UPDATE " + RetSqlName("SE1")
		cQuery += " SET E1_FLUXO = '" + M->A1_FLUXO + "'"
		cQuery += " WHERE D_E_L_E_T_ <> '*' AND E1_CLIENTE = '" + M->A1_COD + "' AND E1_LOJA = '" + M->A1_LOJA + "'"
		TCSqlExec(cQuery)
		_Volta:=M->A1_FLUXO
	ElseIf _cArq == "SE2"
		cQuery := ""
		cQuery := " UPDATE " + RetSqlName("SE2")
		cQuery += " SET E2_FLUXO = '" + M->A2_FLUXO + "'"
		cQuery += " WHERE D_E_L_E_T_ <> '*' AND E2_FORNECE = '" + M->A2_COD + "' AND E2_LOJA = '" + M->A2_LOJA + "'"
		TCSqlExec(cQuery)
		_Volta:=M->A2_FLUXO
	EndIf
	Return(_Volta) 


	*******************************
User Function F060BROW()
	******************************* 
	//|-----------------------------------------------------------------------------------------|
	//| Executado no momento da abertura do browser, utilizado para filtros 					|
	//| Leonardo Bolognesi data 10/12/2014					                                 	|
	//|                                															|
	//|     																					|
	//|   																|
	//|-----------------------------------------------------------------------------------------|
	//Local _aArea   	:= GetArea()
	Local cRet
	Static _cFiltro

	If U_vlsUsrSP()

		dbSelectArea("SE1")
		DbOrderNickName("BCOSP")

		_cFiltro := "Alltrim(SE1->E1_ZZBC2) $ '000/NNN'"
		dbSetFilter( {|| &(_cFiltro)}, _cFiltro )


	EndIf

	//RestArea(_aArea)
	Return Nil            




	*
	************************
User Function F590COK() 
	************************
	*                                                                                            
	//LEONARDO 19/06/15 - MONITORAR QUEM ESTA EXCLUINDO TITULOS DE BORDEROS
	//EXECUTADO NO MOMENTO DE VALIDAÇÂO DA EXCLUSÂO DE TITULO
	//DO BORDERO NA ROTINA MANUTENÇÂO DE BORDERO
	Local _aArea 	:= GetArea()
	Local cNumBor	:= PARAMIXB[2]
	Local cTipo		:= PARAMIXB[1]
	Local cMsg		:= ""

	If cTipo == 'R'

		//LEONARDO 19/06/2015 - DESCOBRIR QUEM ESTA CANCELANDO OS BORDEROS
		cMsg += "Filial:  	"  + Alltrim(SE1->(E1_FILIAL)) 					+ Chr(13)+Chr(10)
		cMsg += "Cliente:  	"  + Alltrim(SE1->(E1_CLIENTE)) 				+ Chr(13)+Chr(10)
		cMsg += "Titulo:  	"  + Alltrim(SE1->(E1_NUM)) 					+ Chr(13)+Chr(10)
		cMsg += "Parcela: 	"  + Alltrim(SE1->(E1_PARCELA)) 				+ Chr(13)+Chr(10)
		cMsg += "Bordero: 	"  + cNumBor									+ Chr(13)+Chr(10)
		cMSg += "ZZBOR1:	"  + Alltrim(SE1->(E1_ZZBOR1)) 					+ Chr(13)+Chr(10)
		cMsg += "ZZBC2:		"  + Alltrim(SE1->(E1_ZZBC2))					+ Chr(13)+Chr(10) 
		cMsg += "Usuario:	"  + cUserName									+ Chr(13)+Chr(10)
		cMsg += "Fonte PE_FINA060.PRW - Função F590COK()	"  				+ Chr(13)+Chr(10)

		U_ConsoleLog("Erro",cMsg, "CancBord")
		U_ArqPorEmail("CancBord","wfti@cobrecom.com.br","[Aviso] - Cancel. Bord. Ctas. Receber" )
		//FIM LEONARDO

	EndIf

	RestArea(_aArea)
Return(.T.)           
