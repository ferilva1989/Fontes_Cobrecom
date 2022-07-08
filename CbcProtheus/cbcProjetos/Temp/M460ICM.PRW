#include "rwmake.ch"
#include "protheus.ch"
#include "portalcobrecom.ch"
#include 'cbcOrdemSep.ch'
#include 'cbcOrdemCar.ch'

User Function M460ICM()
	Public _MyBsICM		:= _BASEICM
	Public _MyVlICM		:= _VALICM
	Public _MyAlICM		:= _ALIQICM
	
	If (Left(SC6->C6_CLASFIS,1) == "5" .And. _ALIQICM  ==  4) .Or.;
		(Left(SC6->C6_CLASFIS,1) $ "38" .And. _ALIQICM  == 12)
		Alert("Possivel erro no ICMS")
	EndIf
Return(.T.)

/*
Função desabilitada. Adicionado em Xecessoes fiscais 
User Function M460SOLI(_SOIVA)
Return(_Volta)
*/

/*/{Protheus.doc} MSD2460
//TODO Descrição auto-gerada.
@author juliana.leme
@since 06/03/2017
@version undefined

@type function
/*/
User Function MSD2460()
	local oCarga := nil
	local aSvArea:= {}
	// Para faturamentos com o TES 809, não pode jogar o acumulado no SC6
	// Pois a quantidade foi usada como excedente...e deve manter no acumulado
	// somente o que movimenta estoque.

	//Public _MyPcICM

	_aArea := GetArea()
	_cNFCI := " "
	// 0 - 100% Nacional
	// 5 - Nacionalizado até 40%
	// 3 - Nacionalizado de 40 a 70 %
	// 8 - Nacionalizado acima de 70 %
	If Left(SD2->D2_CLASFIS,1) $ "358" ///.And. Left(SD2->D2_CF,1) == "6"
		ZZH->(DbSetOrder(1)) // ZZH_FILIAL+ZZH_COD+DTOS(ZZH_DTCAL)
		_dNFCI := Ctod("")
		ZZH->(DbSeek(xFilial("ZZH")+SD2->D2_COD,.F.))
		Do While ZZH->ZZH_FILIAL == xFilial("ZZH") .And. ZZH->ZZH_COD == SD2->D2_COD .And. ZZH->(!Eof())
			If !Empty(ZZH->ZZH_NFCI) .And. ZZH->ZZH_DTCAL > _dNFCI
				If Left(SD2->D2_CLASFIS,1) == "3" .And. ZZH->ZZH_FCIX > 40 .And. ZZH->ZZH_FCIX <= 70
					// 3 - Nacionalizado de 40 a 70 %
					_cNFCI := ZZH->ZZH_NFCI
					_dNFCI := ZZH->ZZH_DTCAL
				ElseIf Left(SD2->D2_CLASFIS,1) == "5" .And. ZZH->ZZH_FCIX <= 40
					// 5 - Nacionalizado até 40%
					_cNFCI := ZZH->ZZH_NFCI
					_dNFCI := ZZH->ZZH_DTCAL
				ElseIf Left(SD2->D2_CLASFIS,1) == "8" .And. ZZH->ZZH_FCIX > 70
					// 8 - Nacionalizado acima de 70 %
					_cNFCI := ZZH->ZZH_NFCI
					_dNFCI := ZZH->ZZH_DTCAL
				EndIf
			EndIf
			ZZH->(DBSkip())
		EndDo
	EndIf

	If SD2->D2_TES == "809"

		RecLock("SD2",.F.)
		SD2->D2_QTD809  := SD2->D2_QUANT
		SD2->D2_QTDEDEV := SD2->D2_QUANT * (-1)
		SD2->D2_QUANT   := 0.00
		MsUnLock()

		RecLock("SC6",.F.)
		SC6->C6_QTDENT := SC6->C6_QTDENT - SD2->D2_QTD809
		SC6->C6_QTDEMP := SC6->C6_QTDEMP + SD2->D2_QTD809
		MsUnLock()

	EndIf
	RecLock("SD2",.F.)
	SD2->D2_DESCRI := Posicione("SB1",1,xFilial("SB1")+SD2->D2_COD,"B1_DESC")
	If SD2->D2_SERIE == "1  " .And. Left(SD2->D2_CLASFIS,1) $ "358"
		SD2->D2_CNUMFCI := _cNFCI
		SD2->D2_FCICOD  := _cNFCI
	EndIf
	SD2->D2_CTRLE   := SC9->C9_CTRLE
	If Type("SD2->D2_SEQOS") == "C"  // Somente se existir o campo
		SD2->D2_SEQOS := SC9->C9_SEQOS
	EndIf
	SD2->D2_XOPER := SC6->C6_XOPER
	MsUnLock()
/*
	SD2->D2_ALIQSOL := _MyPcICM
	MsUnLock()
	_MyPcICM := 0 // Zero para não correr o risco de ficar com valor errado.
*/
	//_cItemZE := If(!Empty(SC6->C6_ITEMIMP),SC6->C6_ITEMIMP,SD2->D2_ITEMPV)
	_cItemZE := SD2->D2_ITEMPV

	If !Empty(SC9->C9_SEQOS) // Tenho ZZR E ZZO
		DbSelectArea("ZZR")
		DbSetOrder(1) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_SEQOS+ZZR_LOCALI
		DbSeek(xFilial("ZZR") + SC9->C9_PEDIDO + SC9->C9_ITEM + SC9->C9_SEQUEN + SC9->C9_SEQOS,.F.)
		Do While ZZR->ZZR_FILIAL == xFilial("ZZR") .And. ZZR->(!Eof()) .And. ;
			     ZZR->(ZZR_PEDIDO+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_SEQOS) == SC9->(C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_SEQOS)
			If Empty(ZZR->ZZR_SERIE) .Or. SD2->D2_SERIE == "1  " // Se estiver vazio (romaneio) ou a série é 1
				RecLock("ZZR",.F.)
				ZZR->ZZR_DOC   := SD2->D2_DOC
				ZZR->ZZR_SERIE := SD2->D2_SERIE
				ZZR->ZZR_ITEM  := SD2->D2_ITEM
				//ZZR->ZZR_CDROMA:= SF2->F2_CDROMA
				//ZZR->ZZR_SITUAC := OS_FATURADA

				MsUnLock()

				//MUDAR STATUS CARGA
				//aSvArea := SD2->(GetArea())
				oCarga := cbcCtrlCarga():newcbcCtrlCarga(,.F.)
				oCarga:byOS(AllTrim(ZZR->ZZR_OS), .T.)
				if oCarga:isOk()
					if oCarga:getStatus(AllTrim(ZZR->ZZR_OS)) <> CARGA_FATURADA
						oCarga:update({{'ZZ9_STATUS', CARGA_FATURADA},; 
									{'ZZ9_DOC', SD2->D2_DOC},; 
									{'ZZ9_SERIE', SD2->D2_SERIE}},; 
									AllTrim(ZZR->ZZR_OS))
					endif
				endif
				FreeObj(oCarga)
				//RestArea(aSvArea)

				If !Empty(ZZR->ZZR_NROBOB)
					DbSelectArea("SZE")
					DbSetOrder(1) // ZE_FILIAL+ZE_NUMBOB
					If DbSeek(xFilial("SZE")+ ZZR->ZZR_NROBOB,.F.)
						RecLock("SZE",.F.)
						SZE->ZE_STATUS := "F"
						SZE->ZE_DOC    := SD2->D2_DOC
						SZE->ZE_SERIE  := SD2->D2_SERIE
						SZE->ZE_NUMSEQ := SD2->D2_NUMSEQ
						MsUnLock()
					EndIf
				EndIf
			EndIf
			ZZR->(DbSkip())
		EndDo

		DbSelectArea("ZZO")
		DbSetOrder(1) // ZZO_FILIAL+ZZO_PEDIDO+ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN+ZZO_LOCALI
		DbSeek(xFilial("ZZO") + SC9->C9_PEDIDO + SC9->C9_SEQOS + SC9->C9_ITEM + SC9->C9_SEQUEN,.F.)
		Do While ZZO->ZZO_FILIAL == xFilial("ZZO") .And. ZZO->(!Eof()) .And. ;
			     ZZO->(ZZO_PEDIDO+ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN) == SC9->(C9_PEDIDO+C9_SEQOS+C9_ITEM+C9_SEQUEN)
			If Empty(ZZO->ZZO_SERIE) .Or. SD2->D2_SERIE == "1  " // Se estiver vazio (romaneio) ou a série é 1
				RecLock("ZZO",.F.)
				ZZO->ZZO_SERIE := SD2->D2_SERIE
				ZZO->ZZO_DOC   := SD2->D2_DOC
				ZZO->ZZO_ITEM  := SD2->D2_ITEM
				MsUnLock()
			EndIf
			ZZO->(DbSkip())
		EndDo
	Else
		DbSelectArea("SDB")
		DbSetOrder(1) // DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIfOR+DB_LOJA+DB_ITEM
		DbSeek(xFilial("SDB")+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA,.F.)

		Do While SDB->DB_FILIAL == xFilial("SDB") .And. SDB->(!Eof()) .And.;
			SDB->(DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIfOR +DB_LOJA) == ;
			SD2->(D2_COD    +D2_LOCAL+D2_NUMSEQ+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA)
			_nQtdLces := Round(SDB->DB_QUANT / Val(Substr(SDB->DB_LOCALIZ,2,5)),0)

			DbSelectArea("SZE")
			DbSetOrder(2) // ZE_FILIAL+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
			DbSeek(xFilial("SZE")+SD2->D2_PEDIDO+_cItemZE,.F.)
			Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_PEDIDO == SD2->D2_PEDIDO .And. ;
				SZE->ZE_ITEM == _cItemZE .And. SZE->(!Eof()) .And. _nQtdLces > 0
				If SZE->ZE_STATUS == "E" .And. Empty(SZE->ZE_DOC)
					RecLock("SZE",.F.)
					SZE->ZE_STATUS := "F"
					SZE->ZE_DOC    := SD2->D2_DOC
					SZE->ZE_SERIE  := SD2->D2_SERIE
					SZE->ZE_NUMSEQ := SD2->D2_NUMSEQ
					MsUnLock()
					_nQtdLces--
				EndIf
				SZE->(DbSkip())
			EndDo
			SDB->(DbSkip())
		EndDo
	EndIf
	RestArea(_aArea)
	Return(.T.)
	*
	*****************************
	User Function CdAgreg(_Volta)
	*****************************
	*
	// Esta função é chamada pelo parâmetro MV_AGREG
	// e serve para gravar a data de liberação no pedido de venda
	// e é chamada da seguinte forma -> U_CdAgreg(SA1->A1_AGREG) // para poder dar o retorno correto.
	// Esta rotina é chamada somente quando cria um C9 novo.
	// Na liberação do credito chamou este PE ja com o BLCRED vazio
	Local  _DtCalc
	Public _cUltPDLb

	Default _cUltPDLb := "      "

	If Empty(SC9->C9_BLCRED)

		If SC5->C5_NUM # _cUltPDLb
			_cUltPDLb := SC5->C5_NUM // Pra não fazer mais de uma vez
			_aDadC5 := {SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_ENTREG,SC5->C5_TIPO}
			u_CDGEN21I(5,,,,_aDadC5) //5-Liberação Pedido (Crédito)
		EndIf
		If Empty(SC5->C5_DTLICRE)
			_aArea := GetArea()
			RecLock("SC5",.F.)
			SC5->C5_DTLICRE := Date() // dDataBase By Roberto Oliveira 14/12/16 - O Vitor trouxe um exemplo que a data da libdocredito está anterior a data de emissao.
			//	SC5->C5_HRLICRE := Time()
			MsUnLock()
			RestArea(_aArea)
			u_AvalPrz("SC5",,,SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI) // Corrige o prazo de entrega
		EndIf
	EndIf
	_Volta := &_Volta
	Return(_Volta)

	*
	***********************
	User Function CalcPis()
	***********************
	*
	DbSelectArea("SF4")
	DbSetOrder(1)

	DbSelectArea("SD2")
	DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

	DbSelectArea("SF2")
	//DbSetOrder(1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	DbSetOrder(4) // F2_FILIAL+F2_SERIE+DTOS(F2_EMISSAO)+F2_DOC+F2_CLIENTE+F2_LOJA
	DbSeek(xFilial("SF2")+"1  " + "20110701",.T.)

	Do While SF2->F2_FILIAL ==xFilial("SF2") .And. SF2->F2_SERIE == '1  ' .And. SF2->(!Eof())
		If SF2->F2_SERIE == "1  " .And. SF2->F2_EMISSAO > Ctod("31/12/10")
			_nF2BsCof := 0.00
			_nF2VlCof := 0.00
			_nF2BsPis := 0.00
			_nF2VlPis := 0.00

			SD2->(DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.))
			Do While SD2->D2_FILIAL  == xFilial("SD2") .And. SD2->(!Eof()) .And. ;
				SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == ;
				SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
				SF4->(DbSeek(xFilial("SF4")+SD2->D2_TES,.F.))
				_nD2BsCof := 0.00
				_nD2VlCof := 0.00
				_nD2BsPis := 0.00
				_nD2VlPis := 0.00

				If SF4->F4_PISCOF $ "23"
					_nD2BsCof := SD2->D2_TOTAL
					_nD2VlCof := (SD2->D2_TOTAL * 7.6) / 100
				EndIf
				If SF4->F4_PISCOF $ "13"
					_nD2BsPis := SD2->D2_TOTAL
					_nD2VlPis := (SD2->D2_TOTAL * 1.65) / 100
				EndIf
				RecLock("SD2",.F.)
				SD2->D2_BASIMP5 := _nD2BsCof
				SD2->D2_VALIMP5  := _nD2VlCof
				SD2->D2_ALQIMP5  := If(_nD2BsCof>0,7.6,0)
				SD2->D2_BASIMP6 := _nD2BsPis
				SD2->D2_VALIMP6  := _nD2VlPis
				SD2->D2_ALQIMP6  := If(_nD2BsPis>0,1.65,0)
				MsUnLock()


				_nF2BsCof += SD2->D2_BASIMP5
				_nF2VlCof += SD2->D2_VALIMP5
				_nF2BsPis += SD2->D2_BASIMP6
				_nF2VlPis += SD2->D2_VALIMP6

				SD2->(DbSkip())
			EndDo
			RecLock("SF2",.F.)
			SF2->F2_BASIMP5 := _nF2BsCof
			SF2->F2_VALIMP5 := _nF2VlCof
			SF2->F2_BASIMP6 := _nF2BsPis
			SF2->F2_VALIMP6 := _nF2VlPis
			MsUnLock()
		EndIf
		SF2->(DbSkip())
	EndDo
	Alert("Terminei")
	Return(.T.)


	User Function ARrunf()

	DbSelectArea("SC6")
	DbSetOrder(1)

	DbSelectArea("ZZH")
	ZZH->(DbSetOrder(1))
	DbSelectArea("SD2")
	DbSetOrder(3) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	lVai := .T.
	DbSeek(xFilial("SD2")+"000017900",.F.)
	Do While SD2->D2_FILIAL == xFilial("SD2") .And. SD2->D2_DOC <= "000017901" .And. lVai
		If Left(SD2->D2_CLASFIS,1) $ "05"
			_cNFCI := ""
			_dNFCI := Ctod("")
			ZZH->(DbSeek(xFilial("ZZH")+SD2->D2_COD,.F.))
			Do While ZZH->ZZH_FILIAL == xFilial("ZZH") .And. ZZH->ZZH_COD == SD2->D2_COD .And. ZZH->(!Eof())
				If !Empty(ZZH->ZZH_NFCI) .And. ZZH->ZZH_DTCAL > _dNFCI .And. ZZH->ZZH_FCIX <= 40
					_cNFCI := ZZH->ZZH_NFCI
					_dNFCI := ZZH->ZZH_DTCAL
				EndIf
				ZZH->(DBSkip())
			EndDo
			If !Empty(_cNFCI) .And. SD2->D2_CNUMFCI # Left(_cNFCI,36)
				If lVai
					RecLock("SD2",.F.)
					SD2->D2_CNUMFCI := _cNFCI
					SD2->D2_FCICOD  := _cNFCI
					MsUnLock()
				EndIf
			EndIf
			SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV,.F.))
			_cClas := "5" + Right(SC6->C6_CLASFIS,2)
			If SD2->D2_CLASFIS # _cClas .And. !Empty(SD2->D2_CNUMFCI)
				If lVai
					RecLock("SD2",.F.)
					SD2->D2_CLASFIS := _cClas
					MsUnLock()
				EndIf
			EndIf
		EndIf
		SD2->(DbSkip())
	EndDo
Return(.T.)


User Function SF2520E()
local bErro	:= Nil
	/*
		[PORTAL][CHAMADA] - Manutenção do relacionamento entre os documentos do portal e os documentos do sistema
		manter a partir de um documento no portal sua rastreabilidade interna no sistema(Chamada com tratamento de
		erro)
	*/
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr)})
	BEGIN SEQUENCE
		if ExistBlock("_CbcService")
			checkQuotationDocument()
		endIf
    RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
	/*
		[PORTAL][FIM]
	*/
Return(.T.)


/*
	[PORTAL][INICIO] - Manutenção do relacionamento entre os documentos do portal e os documentos do sistema
	manter a partir de um documento no portal sua rastreabilidade interna no sistema
*/
static function checkQuotationDocument()

	local nI			:= 0
	local aQuotations	:= {}
	local cQuery  		:= ""
	local cComments 	:= ""
	local cBranchId 	:= SF2->F2_FILIAL
	local cDocumentId	:= SF2->F2_DOC
	local cSeries		:= SF2->F2_SERIE
	local oUtils		:= LibUtilsObj():newLibUtilsObj()
	local oSql    		:= LibSqlObj():newLibSqlObj()
	local oService  	:= CbcQuotationService():newCbcQuotationService()

	cQuery := " SELECT DISTINCT C5_DOCPORT QUOTATION_ID "
	cQuery += " FROM %SD2.SQLNAME% "
	cQuery += " 	INNER JOIN %SC5.SQLNAME% ON "
	cQuery += " 		C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO AND C5_DOCPORT != ' ' AND %SC5.NOTDEL% "
	cQuery += " WHERE D2_FILIAL = '"+cBranchId+"' AND D2_DOC = '"+cDocumentId+"' AND D2_SERIE = '"+cSeries+"' AND %SD2.NOTDEL% "
	cQuery += " ORDER BY 1 "

	oSql:newAlias(cQuery)
	while oSql:notIsEof()
		aAdd(aQuotations, oSql:getValue("QUOTATION_ID"))
		oSql:skip()
	endDo
	oSql:close()

	if Empty(aQuotations)
		return
	endIf

	cComments := "Documento excluído por " + oUtils:getUserName() + " em "+DtoC(Date())+" às "+Left(Time(), 5)
	for nI := 1 to Len(aQuotations)
		oService:setDocumentDeleted(aQuotations[nI], QUOTATION_DOC_INVOICE, cBranchId, cDocumentId, cSeries, cComments)
	next nI
return
/*
	[PORTAL][FINAL] - Manutenção do relacionamento entre os documentos do portal e os documentos do sistema
	manter a partir de um documento no portal sua rastreabilidade interna no sistema
*/


/*/{Protheus.doc} HandleEr
@author bolognesi
@since 30/01/2017
@version undefined
@param oErr, object, Objeto contendo o erro
@type function
/*/
Static function HandleEr(oErr)
	local cMsg := ""
	cMsg := '[' + oErr:Description + ']-' + '-[' +  oErr:ERRORSTACK + ']'
	ConOut("[Fatur.Excl-Portal - " + DtoC(Date()) + " - " + Time() + " ] " + cMsg)
	BREAK
return
