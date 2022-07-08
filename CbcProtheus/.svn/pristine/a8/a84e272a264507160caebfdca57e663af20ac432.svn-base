#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "rwmake.ch"
#define CRLF Chr(13)+Chr(10)

/*/{Protheus.doc} PrBalCol
//TODO Realiza o processamento de pesagens conforme array disponibilizado pelo ACD.
@author juliana.leme
@since 21/09/2016
@version 2.0
@param aColeta, array, Coletas com COD Pesagens e USR Usuario
@param cUsuario, characters, Usuario que logou no sistema
@type function
/*/
User Function PrBalCol(aColeta,cUsuario)
	Local aErros		:= {}
	Local _cLetra		:= "Z"
	Local _cColeta		:= ""
	Local cAcondDest	:= ""
	local nCont			:= 0
	Private _cEndOrigZZE	:= ""

	If Empty(aColeta) .or. Empty(cUsuario)
		Return(.F.)
	EndIf

	//Primeiro grava TXT
	CDArrTxt(aColeta)

	If dDataBase <= GetMV("MV_DBLQMOV") .or. dDataBase <= GetMV("MV_ULMES")
		Return(.F.)
	EndIf

	DbSelectArea("SZE")
	SZE->(DbSetOrder(1)) // ZE_FILIAL+ZE_NUMBOB

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	DbSelectArea("SC2")
	SC2->(DbSetOrder(1)) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD

	DbSelectArea("SZL")
	SZL->(DbSetOrder(1)) //ZL_FILIAL+ZL_NUM+ZL_ITEM

	//Organiza Array de Coletas
	aSort(aColeta)

	For nCont := 1 to Len(aColeta)
		If  Left(aColeta[nCont]:COD,4) $  "/9600/9601/9602" .Or. (Left(aColeta[nCont]:COD,4) == "8000" .And. Substr(aColeta[nCont]:COD,5,2) $ "09/10") // Bobina do EPA
			If _cColeta <> Substr(aColeta[nCont]:COD,05,07)
				_cColeta := Substr(Alltrim(aColeta[nCont]:COD),05,07)
				cUsuario := aColeta[nCont]:USR
				DbSelectArea("SZL")
				SZL->(DbGoTop())
				SZL->(DbSetOrder(4)) //ZL_FILIAL+ZL_NUMBOB
			Else
				Loop
			EndIf
		Else
			If _cColeta <> SubStr(Alltrim(aColeta[nCont]:COD),6,6)
				_cColeta := SubStr(Alltrim(aColeta[nCont]:COD),6,6)
				cUsuario := aColeta[nCont]:USR
				DbSelectArea("SZL")
				SZL->(DbGoTop())
				SZL->(DbSetOrder(1)) //ZL_FILIAL+ZL_NUM+ZL_ITEM
			Else
				Loop
			EndIf
		EndIf

		If SZL->(DbSeek(xFilial("SZL")+ _cColeta ,.F.))
			While SZL->ZL_NUM == _cColeta .or. SZL->ZL_NUMBOB == _cColeta
				//Altera Status das Bobinas recepcionadas
				If ! Empty(SZL->ZL_NUMBOB)
					U_AltStatBob(SZL->ZL_NUMBOB,cUsuario)
				EndIf

				If Alltrim(SZL->ZL_STATUS) <> "P"
					If Alltrim(SZL->ZL_TIPO) == "U"
						// Verificar se a produção já foi feita pela integração -> Retorna o D3_DOCSEQ do movimento
						_cDocSeq := If(!Empty(SZL->ZL_UNMOV),u_FlgSD3(SZL->ZL_UNMOV,.T.),"      ")
						If !Empty(_cDocSeq)
							// Verificar se foi distribuida a produção
							DbSelectArea("SDA")
							SDA->(DbSetOrder(1)) // DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
							DbSeek(xFilial("SDA")+SZL->ZL_PRODUTO+PadR("20",TamSX3("B2_LOCAL")[1])+_cDocSeq,.F.)
							If SDA->DA_SALDO > 0
								If u_DistSZBA("PROD_PCF")
									CBCAltStPes(SZL->ZL_NUM,"A","ERRO AO TRANSFERIR DO ARMAZEM 20/PROD_PCF")
									aAdd (aErros,{SZL->ZL_NUM,SZL->ZL_PRODUTO,SZL->ZL_DESC,Str(SZL->ZL_METROS),SZL->ZL_ACOND + StrZero(SZL->ZL_LANCE,5), "ERRO AO TRANSFERIR DO ARMAZEM 20/PROD_PCF"})
								EndIf
							EndIf
							lProcZL := .T.
						Else
							lProcZL := .F.
						EndIf
					Else
						lProcZL := Empty(SZL->ZL_NUMOP)
						If !lProcZL
							If SC2->(DbSeek(xFilial("SC2")+SZL->ZL_NUMOP+"001",.F.))
								lProcZL := (SZL->ZL_PRODUTO == SC2->C2_PRODUTO)
							EndIf
						EndIf
					EndIf

					If !lProcZL
						_cChaveZL := SZL->ZL_NUM
						Alert("Pesagem "+ SZL->ZL_NUM + "/" + SZL->ZL_ITEM + " não processada")
						DbSelectArea("SZL")
						SZL->(DbSetOrder(1)) //ZL_FILIAL+ZL_NUM+ZL_ITEM
						DbSeek(xFilial("SZL")+_cChaveZL,.F.)
						Do While SZL->ZL_FILIAL == xFilial("SZL") .And. SZL->ZL_NUM <= _cChaveZL .And. SZL->(!Eof())
							If SZL->ZL_STATUS == "A"
								CBCAltStPes(SZL->ZL_NUM,"A","UNMOV NAO INTEGRADA COM O PROTHEUS")
								aAdd (aErros,{SZL->ZL_NUM,SZL->ZL_PRODUTO,SZL->ZL_DESC,Str(SZL->ZL_METROS),SZL->ZL_ACOND + StrZero(SZL->ZL_LANCE,5),"UNMOV NAO INTEGRADA COM O PROTHEUS"})
								//Altera Status Bobina para recebida porém UnMov Não Integrada
								If ! Empty(SZL->ZL_NUMBOB)
									U_AltStatBob(SZL->ZL_NUMBOB,cUsuario)
								EndIf
								//Fim Alteração
							EndIf
							SZL->(DbSkip())
						EndDo
						SZL->(DbSkip())
						Loop
					EndIf
				Else
					//Baixa UnMov no PCF
					If ! Empty(SZL->ZL_UNMOV)
						U_PCFBxUnMov(xFilial("SZL"),SZL->ZL_UNMOV,SZL->ZL_NUM)
					EndIf
					//Pesagem ja processada, pula proximo registro
					SZL->(DbSkip())
					Loop
				EndIf

				//Realiza o processamento das pesagens
				If SZL->ZL_STATUS $ "AE" .And. !SZL->ZL_TIPO $ "TF"
					If SZL->ZL_TIPO == "U" //Caso a pesagem seja UnMov
						//Trata o acondicionamento de Destino
						cAcondDest := Alltrim(SZL->ZL_ACOND)+StrZero(SZL->ZL_LANCE,5)
						U_CBCSldSBE(cAcondDest,"01")
						//Analisa UnMov não foi estornada
						If ! U_CBProdUnMov(SZL->ZL_UNMOV,SZL->ZL_PRODUTO)
							If U_CBCTemTrf(SZL->ZL_NUM, SZL->ZL_PRODUTO, SZL->ZL_METROS)
								CBCAltStPes(SZL->ZL_NUM,"E","TRANSFERENCIA JA REALIZADA PARA ESTA PESAGEM")
								aAdd (aErros,{SZL->ZL_NUM,SZL->ZL_PRODUTO,SZL->ZL_DESC,Str(SZL->ZL_METROS),SZL->ZL_ACOND + StrZero(SZL->ZL_LANCE,5),"TRANSFERENCIA JA REALIZADA PARA ESTA PESAGEM"})
							//Realiza a Transferencia entre Armazens e Endereça	
							ElseIf ! U_CBCTraMata(SZL->ZL_PRODUTO,"20","01",SZL->ZL_METROS,"P"+SZL->ZL_NUM,"PROD_PCF",cAcondDest)
								//Transferencia realizada
								//Altera Status para Processada
								CBCAltStPes(SZL->ZL_NUM,"P","")
							Else //Caso Erro altera status da pesagem para erro
								CBCAltStPes(SZL->ZL_NUM,"E","TRANSFERENCIA NAO REALIZADA SALDO INDISPONIVEL")
								aAdd (aErros,{SZL->ZL_NUM,SZL->ZL_PRODUTO,SZL->ZL_DESC,Str(SZL->ZL_METROS),SZL->ZL_ACOND + StrZero(SZL->ZL_LANCE,5),"TRANSFERENCIA NAO REALIZADA SALDO INDISPONIVEL"})
							EndIf
						Else
							//UnMov Estornada
							CBCAltStPes(SZL->ZL_NUM,"E","UNMOV ESTORNADA. PESAGEM NAO PROCESSADA")
							aAdd (aErros,{SZL->ZL_NUM,SZL->ZL_PRODUTO,SZL->ZL_DESC,Str(SZL->ZL_METROS),SZL->ZL_ACOND + StrZero(SZL->ZL_LANCE,5),"UNMOV ESTORNADA. PESAGEM NAO PROCESSADA"})
						EndIf
					ElseIf SZL->ZL_TIPO == "R"
						//Posiciona no Retrabalho
						U_CBCSldSBE("","90")
						//Analisa se tem Saldo para devolução do Retrabalho
						If TemSaldo()//Alimenta variavel _cEndOrigZZE
							//Trata o acondicionamento de Destino
							cAcondDest := Alltrim(SZL->ZL_ACOND)+StrZero(SZL->ZL_LANCE,5)
							U_CBCSldSBE(cAcondDest,"01")
							If U_CBCTemTrf(SZL->ZL_NUM, SZL->ZL_PRODUTO, SZL->ZL_METROS)
								CBCAltStPes(SZL->ZL_NUM,"E","TRANSFERENCIA JA REALIZADA PARA ESTA PESAGEM DE RETRABALHO")
								aAdd (aErros,{SZL->ZL_NUM,SZL->ZL_PRODUTO,SZL->ZL_DESC,Str(SZL->ZL_METROS),SZL->ZL_ACOND + StrZero(SZL->ZL_LANCE,5),"TRANSFERENCIA JA REALIZADA PARA ESTA PESAGEM DE RETRABALHO"})
							//Realiza a Transferencia entre Armazens e Endereça
							ElseIf ! U_CBCTraMata(SZL->ZL_PRODUTO,"90","01",SZL->ZL_METROS,"P"+SZL->ZL_NUM,_cEndOrigZZE,cAcondDest)
								//Transferencia realizada
								//Altera Status para Processada
								CBCAltStPes(SZL->ZL_NUM,"P","")
							Else //Caso Erro altera status da pesagem para erro
								CBCAltStPes(SZL->ZL_NUM,"E","TRANSFERENCIA RETRABALHO NAO REALIZADA. SALDO INSUFICIENTE.")
								aAdd (aErros,{SZL->ZL_NUM,SZL->ZL_PRODUTO,SZL->ZL_DESC,Str(SZL->ZL_METROS),SZL->ZL_ACOND + StrZero(SZL->ZL_LANCE,5),"TRANSFERENCIA RETRABALHO NAO REALIZADA. SALDO INSUFICIENTE."})
							EndIf
						Else
							CBCAltStPes(SZL->ZL_NUM,"E","SALDO INSUFICIENTE PARA DEV RETRABALHO")
							aAdd (aErros,{SZL->ZL_NUM,SZL->ZL_PRODUTO,SZL->ZL_DESC,Str(SZL->ZL_METROS),SZL->ZL_ACOND + StrZero(SZL->ZL_LANCE,5),"SALDO INSUFICIENTE PARA DEV RETRABALHO"})
						EndIf
					ElseIf SZL->ZL_TIPO == "S"
						If U_CBCIncSuc()
							//SUCATA REALIZADA
							CBCAltStPes(SZL->ZL_NUM,"P","")
						Else
							//SUCATA COM ERRO
							CBCAltStPes(SZL->ZL_NUM,"E","SUCATA NAO PROCESSADA")
							aAdd (aErros,{SZL->ZL_NUM,SZL->ZL_PRODUTO,SZL->ZL_DESC,Str(SZL->ZL_METROS),SZL->ZL_ACOND + StrZero(SZL->ZL_LANCE,5),"SUCATA NAO PROCESSADA"})
						EndIf
					ElseIf SZL->ZL_STATUS == "AE" .And. SZL->ZL_TIPO $ "TF"
						CBCAltStPes(SZL->ZL_NUM,"P","")
					EndIf
				EndIf

				//Se Bloq por CQ ou Troca de Etiqueta ou Filial
				If SZL->ZL_TIPO $ "TF" .Or. SZL->ZL_STATUS == "Q"
					//Altera Status Bobina
					If ! Empty(SZL->ZL_NUMBOB)
						U_AltStatBob(SZL->ZL_NUMBOB,cUsuario)
					EndIf
				EndIf

				SZL->(DbSkip())
			EndDo
		EndIf
	Next

	If Len(aErros) > 0
		_aLado := {} // Informar a posição de cada item do acab
		Aadd(_aLado,"Right")
		Aadd(_aLado,"Left")
		Aadd(_aLado,"Left")
		Aadd(_aLado,"Right")
		Aadd(_aLado,"Left")
		Aadd(_aLado,"Left")

		_aCab   := {}
		Aadd(_aCab,"Num.Pes")
		Aadd(_aCab,"Produto")
		Aadd(_aCab,"Descrição")
		Aadd(_aCab,"Qtde")
		Aadd(_aCab,"Acondic")
		Aadd(_aCab,"Motivo")

		_aDet01 := aErros

		cPara := Iif(xFilial("SZL") == "01", "wfexpitu@cobrecom.com.br;", "wfexptl@cobrecom.com.br;")

		u_envMail({cPara},;
				   "Pesagens Com Erro no processamento",;
				_aCab,;
				_aDet01,,;
				_aLado)
	EndIf

	DbCloseArea("SZE")
	DbCloseArea("SB1")
	DbCloseArea("SC2")
	DbCloseArea("SZL")
	DbCloseArea("SD3")
Return(.T.)


/*/{Protheus.doc} CBCProcPes
//TODO Descrição auto-gerada.
@author juliana.leme
@since 22/12/2016
@version undefined

@type function
/*/
User Function CBCSldSBE(_Loclz,cArmz)
Default _Loclz := ""
Default cArmz := "01"

	If Empty(_Loclz)
		_cLocaliz := SZL->ZL_ACOND+StrZero(SZL->ZL_LANCE,5)
	Else
		_cLocaliz := _Loclz
	EndIf

	_cLocaliz := PadR(_cLocaliz,TamSX3("BE_LOCALIZ")[1])

	DbSelectArea("SBE")
	SBE->(DbSetOrder(1))
	If ! DbSeek(xFilial("SBE") + cArmz + _cLocaliz,.F.)
		If SZL->ZL_ACOND == "T"
			_cDesLo :=  "Retalho de "
		ElseIf SZL->ZL_ACOND == "B"
			_cDesLo :=  "Bobina de "
		ElseIf SZL->ZL_ACOND == "M"
			_cDesLo :=  "Carretel de Mad.de "
		ElseIf SZL->ZL_ACOND == "C"
			_cDesLo :=  "Carretel de "
		ElseIf SZL->ZL_ACOND == "R"
			_cDesLo :=  "Rolo de "
		ElseIf SZL->ZL_ACOND == "L"
			_cDesLo :=  "Blister de "
		EndIf

		//_cDesLo +=  Str(SZL->ZL_LANCE,5) + " metros"
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+SZL->ZL_PRODUTO,.F.))
		_cDesLo +=  Str(SZL->ZL_LANCE,5) + " " + Posicione("SAH",1,xFilial("SAH")+SB1->B1_UM,"AH_DESCPO")
		RecLock("SBE",.T.)
		SBE->BE_FILIAL   := xFilial("SBE")
		SBE->BE_LOCAL    := cArmz
		SBE->BE_LOCALIZ  := _cLocaliz
		SBE->BE_DESCRIC  := _cDesLo
		SBE->BE_PRIOR    := "ZZZ"
		SBE->BE_STATUS   := "1"
		SBE->(MsUnLock())
	EndIf
Return()


/*/{Protheus.doc} CBCAltStPes
//TODO Descrição auto-gerada.
@author juliana.leme
@since 23/12/2016
@version undefined
@param cNumPes, characters, descricao
@param cStatus, characters, descricao
@param cComment, characters, descricao
@type function
/*/
Static Function CBCAltStPes(cNumPes,cStatus,cComment)
Default cComment	:= ""
Default cStatus		:= "N"
		RecLock("SZL",.F.)
		SZL->ZL_STATUS	:= cStatus
		SZL->ZL_COMENTS	:= cComment
		SZL->ZL_DTRECEB	:= Date()
		SZL->ZL_HRRECEB	:= Left(TIME(),Len(SZL->ZL_HRRECEB))
		SZL->(MsUnLock())

		//Requisita Bobina contra OP

Return()

/*/{Protheus.doc} FlgSD3
//TODO Descrição auto-gerada.
@author juliana.leme
@since 07/10/2016
@version undefined
@param _UNMOV, , descricao
@param lFlag, logical, descricao
@type function
/*/
User Function FlgSD3(_UNMOV,lFlag)
	local cNmSeq 	:= "      "// Retornar o NumSeq do Movimento
	local nOrig		:= 0
	default _UNMOV  := 0// Nro da Unimov
	default lFlag   := .T.// Flegar o registro como com pesagem no SZL

	_aAreaAtu := GetArea()
	aTam := TamSX3("D3_ZZUNMOV")
	_D3_UNMOV := Str(_UNMOV,aTam[1]) //,aTam[2]
	DbSelectArea("SD3")
	_aAreaSD3 := GetArea()
	DbOrderNickName("D3_ZZPPI") // D3_FILIAL+D3_ZZUNMOV+D3_COD+D3_CF
	if!(SD3->(DbSeek(xFilial("SD3") + _D3_UNMOV,.F.)))
		nOrig := checkDM2(_UNMOV)
		if !empty(nOrig)
			_D3_UNMOV := Str(nOrig,aTam[1])
			SD3->(DbSeek(xFilial("SD3") + _D3_UNMOV,.F.))
		endif
	endif
	Do While SD3->D3_FILIAL == xFilial("SD3") .And. SD3->D3_ZZUNMOV == Val(_D3_UNMOV) .And. SD3->(!Eof())
		If SD3->D3_CF == "PR0" .And. SD3->D3_ESTORNO # "S" // É uma produção e não está estornada.
			If lFlag .And. SD3->D3_TEMPES # "S"
				RecLock("SD3",.F.)
				SD3->D3_TEMPES := "S"
				SD3->(MsUnLock())
			EndIf
			cNmSeq := SD3->D3_NUMSEQ
		EndIf
		SD3->(DbSkip())
	EndDo
	RestArea(_aAreaSD3)
	RestArea(_aAreaAtu)
Return(cNmSeq)

/*/{Protheus.doc} TemSaldo
//TODO Descrição auto-gerada.
@author juliana.leme
@since 07/10/2016
@version undefined

@type function
/*/
Static Function TemSaldo()
	_lTemTudo := .T.

	_cLocOrig := Left(GetMv("MV_LOCRET")+"  ",2)
	_cEndOrigZZE := Left(GetMv("MV_ENDRET") + Space(6),6)

	DbSelectArea("ZZE")
	ZZE->(DbSetOrder(1)) // ZZE_FILIAL+ZZE_ID
	ZZE->(DbSeek(xFilial("ZZE")+SZL->ZL_ZZEID,.F.))
	_cEndOrigZZE := Left(ZZE->ZZE_ACONDE+StrZero(ZZE->ZZE_METRAE,5)+Space(6),6)
	_cEndOrigZZE := PadR(_cEndOrigZZE,TamSX3("BF_LOCALIZ")[1])

	_nSldZZE := (ZZE->ZZE_TOTEN - ZZE->ZZE_QTDPRO)

	_nQtdTira := Min(_nSldZZE,SZL->ZL_METROS)
	// Isto ocorre quando a quantidade total devolvida é maior que a quantidade enviada para retrabalho

	RecLock("ZZE",.F.)
	ZZE->ZZE_QTDPRO := ZZE->ZZE_QTDPRO + _nQtdTira
	ZZE->(MsUnLock())

	If _nQtdTira > _nSldZZE
		_nQtdTira := Max(_nSldZZE,0)
	EndIf

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+SZL->ZL_PRODUTO,.F.))
	If SB1->B1_LOCALIZ =="S"
		DbSelectArea("SBF")
		SBF->(DbSetOrder(1))  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		If DbSeek(xFilial("SBF")+_cLocOrig+_cEndOrigZZE+SZL->ZL_PRODUTO,.F.)
			//RecLock("SBF",.F.) // Primeiro dou o RecLock pra ninguem mexer no registro
			If _nQtdTira  <= (SBF->BF_QUANT - SBF->BF_EMPENHO) .And. SBF->BF_EMPENHO >= 0
				//SBF->BF_EMPENHO += _nQtdTira
			Else  // Se não tenho quantidade disponivel...
				_lTemTudo := .F.
			EndIf
			//SBF->(MsUnLock())
		Else
			_lTemTudo := .F.
		EndIf
	Else
		// Veririfar no SB2
		DbSelectArea("SB2")
		SB2->(DbSetOrder(1))//B2_FILIAL+B2_COD+B2_LOCAL
		If DbSeek(xFilial("SB2")+SZL->ZL_PRODUTO+_cLocOrig,.F.)
			//RecLock("SB2",.F.)
			If SZL->ZL_METROS  <= (SB2->B2_QATU - SB2->B2_RESERVA) // Ainda tenho a quantidade disponível
				//SB2->B2_RESERVA += SZL->ZL_METROS
				//MsUnLock()
			Else  // Se não tenho quantidade disponivel...
				//MsUnLock()
				_lTemTudo := .F.
			EndIf
		Else
			_lTemTudo := .F.
		EndIf
	EndIf
Return(_lTemTudo)

/*/{Protheus.doc} AltStatBob
//TODO Descrição auto-gerada.
@author juliana.leme
@since 21/09/2016
@version undefined
@param cNumBob, characters, descricao
@param cUser, characters, descricao
@type function
/*/
User Function AltStatBob(cNumBob,cUser)
	//Altera Status da Bobina
	DbSelectArea("SZE")
	SZE->(DbSetOrder(1)) // ZE_FILIAL+ZE_NUMBOB
	If DbSeek(xFilial("SZE")+cNumBob,.F.)
		If SZE->ZE_STATUS == "R" .OR. SZE->ZE_STATUS == "I"
			RecLock("SZE",.F.)
			If SZE->ZE_PEDIDO == "000001"
				SZE->ZE_STATUS  := "T"
				SZE->ZE_DTREC   := Date()
				SZE->ZE_HRREC   := Left(TIME(),Len(SZE->ZE_HRREC))
				If Empty(SZE->ZE_FUNCEXP)
					SZE->ZE_FUNCEXP := SubStr(cUser,3,6)
				EndIf
			Else
				SZE->ZE_STATUS  := "P"
				SZE->ZE_DTREC   := Date()
				SZE->ZE_HRREC   := Left(TIME(),Len(SZE->ZE_HRREC))
				If Empty(SZE->ZE_FUNCEXP)
					SZE->ZE_FUNCEXP := SubStr(cUser,3,6)
				EndIf
			EndIf
			SZE->(MsUnLock())
		EndIf
	EndIf
	//Fim Status Bobina
Return

/*/{Protheus.doc} TesteCol
//TODO Descrição auto-gerada.
@author juliana.leme
@since 31/08/2016
@version undefined

@type function
/*/
User Function TesteCol()
Local aArray 		:= '{"COLETAS": [{"COD": "96001659496","USR": "01000248"},'+;
									'{"COD": "96001659495","USR": "01000248"},'+;
									'{"COD": "96001659497","USR": "01000248"},'+;
									'{"COD": "96001659422","USR": "01000248"},'+;
									'{"COD": "96001659423","USR": "01000248"},'+;
									'{"COD": "96001659430","USR": "01000248"}]}'
/*
'{"COD": "9600","USR": "01000248"},'+;
*/
Local oReq			:= Nil
Local cUser			:= "01000248"
	If FWJsonDeserialize(aArray, @oReq)
		If U_PrBalCol(oReq:COLETAS,cUser)
			Alert("Deu Certo")
		Else
			Alert("Deu Errado")
		EndIf
	EndIf
Return


/*/{Protheus.doc} CDArrTxt
//TODO Coloca o Array de pesagens em arquivo TXT.
@author juliana.leme
@since 31/08/2016
@version 1.0
@param ArrComp, Array , Array com as pesagens
@param cUser, characters, Usuario que ira processar a pesagem
@type function
/*/
Static Function CDArrTxt(ArrComp)
Local cDir    := "\Coletores\PESAGENS\"
Local cArq    := "COLETA_"+DtoS(Date())+"_"+StrTran(Left(Time(),5),":","")+".txt"
Local nHandle := FCreate(cDir+cArq)
local nLinha  := 0

	If nHandle < 0
		//MsgAlert("Erro durante criação do arquivo.")
	Else
		For nLinha := 1 to Len(ArrComp)
			FWrite(nHandle, "USUARIO RESPONSAVEL: " + ArrComp[nLinha]:USR + " - ")
			FWrite(nHandle, "COLETA NUMERO: " + Substr(ArrComp[nLinha]:COD,05,07) + CRLF)
		Next nLinha

		FClose(nHandle)
	EndIf
Return

/*/{Protheus.doc} PCFBxUnMov
//TODO Baixa UnMov no PCF sem Movimentação.
@author juliana.leme
@since 27/10/2016
@version undefined
@param cFil, characters, descricao
@param nUnMov, numeric, descricao
@param cD3Seq, characters, descricao
@type function
/*/
User Function PCFBxUnMov(cFil,nUnMov,cD3Seq)
	Private oApp_Ori
	Private nHndErp 	:= AdvConnection()
	Private cDB_PPI 	:= GetMV("ZZ_HNDPCF") //"MSSQL/PCFactory"	//Tipo e nome do banco de integração (PC-Factory) (OFICIAL)
	Private cSrvPPI 	:= GetMV("ZZ_SRVPPI")//"192.168.3.2"		//Servidor onde está o banco de integração (OFICIAL)
	Private nPrtPPI 	:= 7890	// Porta
	Private nHndPPI		//Handler do banco de dados de integração

	//Armazena a conexão de Origem
	oApp_Ori 	:= oApp
	// Cria uma conexão com um outro banco, outro DBAcces
	nHndPPI 	:= TcLink(cDb_PPI,cSrvPPI,nPrtPPI)

	//Conecta com PPI
	TcSetConn(nHndPPI)

	//Caso a conexão não seja realizada
	If nHndPPI < 0
		Conout("Falha ao conectar com " + cDB_PPI + " em " + cSrvPPI + ":" + Str(nPrtPPI,4))
		Return(.F.)
	Endif

	//Coloca os Registros de Integração em Processo
	_cQuery := " update TBLMovUn set  "
	_cQuery += " IDAddress = " + Alltrim(Str(IIf(cFil == "01", 1, 5))) + ", "
	_cQuery += " DtOut = GETDATE(), "
	_cQuery += " OutDocNumber = '" + cD3Seq +"' , "
	_cQuery += " MovUnOutDest = 6, "
	_cQuery += " MovUnQty = 0 "
	_cQuery += " WHERE IDMovUn = "+ Alltrim(Str(nUnMov))

	//Conecta com PPI
	TcSetConn(nHndPPI)
	//Executa Query
	TCSqlExec(_cQuery)
	//Verifica se a Query foi executada
	If (TCSqlExec(_cQuery) < 0) // Deu Erro
		//_lVolta := .T. // Significa que deu erro na função
		cMsg := TCSQLError() //+ linha
		Conout("ATENÇÃO ERRO NA BAIXA DA UNMOV " + Alltrim(Str(nUnMov)))
		Return(.F.)
	EndIf

	//Encerra conexão PPI
	TcUnLink(nHndPPI)
	//Conecta ERP
	TcSetConn(nHndERP)
	oApp 	:= oApp_Ori
Return()

/*/{Protheus.doc} DistSZBA
//TODO Descrição auto-gerada.
@author juliana.leme
@since 07/10/2016
@version undefined
@param _Loclz, , descricao
@type function
/*/
User Function DistSZBA(_Loclz)
	Local _lErro	:= .F.
	Default _Loclz 	:= "  "

	// Tem que vir com o SDA posicionado
	If SDA->DA_SALDO = 0 // Não tem nada a distribuir
		Return(.T.)
	EndIf

	DbSelectArea("SDB")
	SDB->(DbSetOrder(1)) // DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM
	DbSeek(xFilial("SDB")+SDA->DA_PRODUTO+SDA->DA_LOCAL+SDA->DA_NUMSEQ,.F.)
	_cItemDb := StrZero(0,Len(SDB->DB_ITEM))
	Do While SDB->DB_FILIAL==xFilial("SDB") .And. SDB->(!Eof()) .And. ;
		SDB->DB_PRODUTO+SDB->DB_LOCAL+SDB->DB_NUMSEQ == SDA->DA_PRODUTO+SDA->DA_LOCAL+SDA->DA_NUMSEQ

		If SDB->DB_ITEM > _cItemDb
			_cItemDb := SDB->DB_ITEM
		EndIf
		SDB->(DbSkip())
	EndDo

	_cItemDb := Soma1(_cItemDb)

	If Empty(_Loclz)
		_cLocaliz := SZL->ZL_ACOND+StrZero(SZL->ZL_LANCE,5)
	Else
		_cLocaliz := _Loclz
	EndIf

	_cLocaliz := PadR(_cLocaliz,TamSX3("BE_LOCALIZ")[1])

	aCAB  := {	{"DA_PRODUTO" ,SDA->DA_PRODUTO             , nil},;
				{"DA_QTDORI"  ,SDA->DA_QTDORI              , nil},;
				{"DA_SALDO"   ,SDA->DA_SALDO               , nil},;
				{"DA_DATA"    ,SDA->DA_DATA                , nil},;
				{"DA_LOCAL"   ,SDA->DA_LOCAL               , nil},;
				{"DA_DOC"     ,SDA->DA_DOC                 , nil},;
				{"DA_ORIGEM"  ,SDA->DA_ORIGEM              , nil},;
				{"DA_NUMSEQ"  ,SDA->DA_NUMSEQ              , nil},;
				{"DA_QTSEGUM" ,SDA->DA_QTSEGUM             , nil},;
				{"DA_QTDORI2" ,SDA->DA_QTDORI2             , nil}}


	aITENS:={{	{"DB_ITEM"    , _cItemDb                   , nil},;
				{"DB_LOCALIZ" , _cLocaliz                  , nil},;
				{"DB_QUANT"   , If(Empty(_Loclz),_QtDistr,SDA->DA_SALDO), nil},;
				{"DB_DATA"    , dDataBase                  , nil},;
				{"DB_ESTORNO" ," "                         , nil} }}

	lMsErroAuto := .F.
	MsExecAuto({|x,y|mata265(x,y)},aCAB,aITENS)

	MsUnLockAll()

	If lMsErroAuto
		_lErro := .T.
	Else
		_lErro := .F.
	EndIf
Return(_lErro)

/*/{Protheus.doc} CBCIncSuc
//TODO Descrição auto-gerada.
@author juliana.leme
@since 23/12/2016
@version undefined

@type function
/*/
User Function CBCIncSuc()
Local lTransSuc := .T.
	/*/
	Definição:
	Realizar a pesagem de sucata.
	Avaliar saldo de sucata do armazem 91.
	Caso não exista apenas realizar uma devolução do saldo residual para o armazem 01
	/*/
	nQuantSuc := 0
	If SZL->ZL_PESOEFE <= U_CBRetSldB2(SZL->ZL_PRODUTO,"91") //U_RetSaldoB2(cProduto,cLocal)
		//Utiliza Saldo do Armzem principal de Sucata "91"
		If ! U_CBCTraMata(SZL->ZL_PRODUTO,"91","01",SZL->ZL_PESOEFE,"P"+SZL->ZL_NUM, "", "")
			lTransSuc := .T.
		Else
			lTransSuc := .F.
		EndIf
	Else
		nQuantSuc := U_CBRetSldB2(SZL->ZL_PRODUTO,"91")
		Alert ("PESAGEM NÃO PROCESSADA."+;
				"Saldo Insuficiente." + CRLF  +;
			 	"Favor comunicar ao PCP! " + CRLF +;
			 	"Quantidade disponivel para pesagem: " + Transform(nQuantSuc,"@E 999,999.9999"))
		lTransSuc := .T.
		/*/
		nQuantSuc := U_CBRetSldB2(SZL->ZL_PRODUTO,"91")
		If nQuantSuc > 0
			//Utiliza Saldo do Armzem principal de Sucata "91"
			If ! U_CBCTraMata(SZL->ZL_PRODUTO,"91","01",nQuantSuc,SZL->ZL_NUM, "", "")
				lTransSuc := .T.
			Else
				lTransSuc := .F.
			EndIf
		EndIf

		nQuantSuc := SZL->ZL_PESOEFE - nQuantSuc
		//Devolve apenas o que não encontrar no armazém "91"
		//TODO 91 Armazem
		U_CBCDevSuc("009",SZL->ZL_PRODUTO,nQuantSuc,"P"+SZL->ZL_NUM,"01")
		/*/
	EndIf
Return (lTransSuc)

/*/{Protheus.doc} ConfUnMov
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/12/2016
@version undefined
@param nUnMov, numeric, descricao
@type function
/*/
User Function CBProdUnMov(nUnMov,cProduto)
Local lRet  := .T.
Local nOrig := 0
	DbSelectArea("SD3")
	DbOrderNickName("D3_ZZPPI")

	If DBSeek(xFilial("SD3") + Str(nUnMov,10,0) + cProduto + "PR0",.F.)
		If SD3->D3_ESTORNO = "S"
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	Else
		nOrig := checkDM2(nUnMov)
		If DBSeek(xFilial("SD3") + Str(nOrig,10,0) + cProduto + "PR0",.F.)
			If SD3->D3_ESTORNO = "S"
				lRet := .T.
			Else
				lRet := .F.
			EndIf
		EndIf
	EndIf
Return(lRet)

/*/{Protheus.doc} CBCTemTrf
//TODO Descrição auto-gerada.
@author alexandre.madeira
@since 24/04/2018
@version 1.0
@return lRet - .T. - Tem / .F. - Não Tem
@param cNumPes, characters, Número da pesagem
@param cProduto, characters, Código do produto
@param nQtd, numeric, Qtde da pesagem
Função para retornar se há transferência para a pesagem
/*/
User Function CBCTemTrf(cNumPes, cProd, nQtd)
Local lRet := .F.

	DbSelectArea("SD3")
	SD3->(DbSetOrder(2))//D3_FILIAL+D3_DOC+D3_COD                                                                                                                                  
	If DBSeek(xFilial("SD3") + PadR("P" + cNumPes, TamSX3("D3_DOC")[1]) + cProd)
		If SD3->D3_ESTORNO # "S" .And. (SD3->D3_CF == "RE4" .OR. SD3->D3_CF == "DE4") .And. SD3->D3_COD == cProd .And. SD3->D3_QUANT == nQtd
			lRet := .T.
		Else
			lRet := .F.
		EndIf
	EndIf
	
Return(lRet)

static function checkDM2(nUnMov)
	local aArea		:= GetArea()
	local aAreaSD3  := SD3->(GetArea())
	local aAreaSZL  := SZL->(GetArea())
	local oSql      := LibSqlObj():newLibSqlObj()
	local nOrig		:= 0
	local nHndERP   := AdvConnection()
	
	if chgDataBase()
		oSql:newAlias(qryCheckDm2(nUnMov))
		if oSql:hasRecords()
			oSql:goTop()
			nOrig := oSql:getValue("IDMOVUN")
		endif
		oSql:Close()		
	endif
    FreeObj(oSql)
	chgDataBase(nHndERP)
	RestArea(aAreaSZL)
	RestArea(aAreaSD3)
	RestArea(aArea)
return(nOrig)

static function qryCheckDm2(nUnMov)
	local cQry := ''

	cQry += " select movev.IDMovUn as [IDMOVUN] "
	cQry += " from TBLMovEv movev "
	cQry += " inner join TBLMovType movtype on movev.IDMovType = movtype.IDMovType "
	cQry += " where movev.IDLot = ( "
	cQry += " 				select submovev.IDLot as [idlote] "
	cQry += " 				from TBLMovEv submovev "
	cQry += " 				inner join TBLMovType submovtype on submovev.IDMovType = submovtype.IDMovType "
	cQry += " 				where submovev.IDMovUn = " + cValToChar(nUnMov)
	cQry += " 				and submovtype.Code = 'DM2' "
	cQry += " ) "
	cQry += " and movev.IDMovUn =	( "
	cQry += " 						select ssubmovev.IDMovUn as [idlote] "
	cQry += " 						from TBLMovEv ssubmovev "
	cQry += " 						inner join TBLMovType ssubmovtype on ssubmovev.IDMovType = ssubmovtype.IDMovType "
	cQry += " 						where ssubmovev.IDMovUn = movev.IDMovUn "
	cQry += " 						and ssubmovtype.Code in ('PR0','PR1') "
	cQry += " 					)	 "
	cQry += " and movtype.Code = 'DM1' "
return(cQry)

static function chgDataBase(nHnd)
    local lRet      	  := .T.
	local cDbPPI 	  	  := GetMV("ZZ_HNDPCF")
	local cSrvPPI 	  	  := GetMV("ZZ_SRVPPI")
	local nPrtPPI		  := GetNewPar("ZZ_PORTADB", "7890")
	default nHnd          := -1

	if nHnd < 0
		// Cria uma conexão com um outro banco, outro DBAcces
		nHnd := TcLink( cDbPPI, cSrvPPI, nPrtPPI )
		lRet := (nHnd >= 0)
		if !lRet
			UserException( "999 - Falha ao conectar com " + cDbPPI + " em " + cSrvPPI )
		endif
	else
		// Volta para conexão TSS
		tcSetConn( nHnd )
	endif   
return(lRet)
