#INCLUDE "PROTHEUS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "tbiconn.ch"

/*/{Protheus.doc} CBCSuc
//TODO Através da informação de um pedido, 
		o sistema realiza o sucateamento dos itens liberados na SC9.
@author juliana.leme
@since 12/12/2017
@version 1.0

@type function
/*/
User Function CBCSuc()
	Local lRet			:= .T.
	Local aArea 		:= SC9->(GetArea())
	Local aParamBox 	:= {}
	Local aRet			:= ""
	Private oBrowse
	Private cChaveAux,cPedido := ""
	Private lMyPedCan		:= .T.
	
	aAdd(aParamBox,{1,"Num.Pedido:    ",Space(6)		,""	,""	,""	,""	,040,.F.})

	If !ParamBox(aParamBox, "Parametros", @aRet)
		Return(.F.)
	EndIf

	cPedido := Alltrim(aRet[1])
	
	If ApMsgYesNo("Deseja CANCELAR o pedido "+cPedido+" ?")
		Processa( {|| U_EstLiPed(cPedido) },"Preparando o Pedido ... Aguarde")
	EndIf
Return

/*/{Protheus.doc} EstLibPed
//TODO Descrição auto-gerada.
@author juliana.leme
@since 13/12/2017
@version 1.0
@param cNumPed, characters, descricao
@type function
/*/
User Function EstLiPed(cNumPed)
	local aRetERS		:= {}
	local lTExcAr		:= .T.
	local cMsgErr		:= ''
	Local lRet 		:= .T.
	Local aDadCon	:= {}
	Local aDadFin	:= {}
	Local aTablePed	:= {}
	Local aWstPed	:= {}
	Local aDadFim	:= {}
	Local aDadCon2	:= {}
	Local aParc 	:= {}
	Local cLocaliz	:= ""
	Local cPedRel	:= ""
	Local _Msg		:= ""
	Local cNomCli	:= ""
	Local lDCerto	:= .T.
	Local nValTot	:= 0
	Local nQTKgCob	:= 0
	Local nValTotal	:= 0
	Local nVTotPed	:= 0
	Local _nLances	:= 0
	Local nQtdKgPVC	:= 0
	Local n			:= 1
	Local aColun	:= {{"Filial","Data Emissão","Nome Cli","Numero","Item","Qtd.Pedido",;
						"Cod.Origem","Descrição","Acondic.","Qtd.Consumo","Vl.Unit","Vl.Total",;
						"UM","Cod.Destino","Descrição","Qtd.Sucata","UM","Qtd.Kg PVC","Cond.Pag.","Desc.Cond.Pag.","Represent."},;
						{"Filial","Data Emissão","Nome Cli","Numero","Valor","Vencto"},;
						{"Filial","Data Emissão","Nome Cli","Numero","Item",;
						"Cod.Produto","Descrição","Acondic.","Qtd.","Vl.Unit.","Vl.Total","Represent."}}
	Default cNumPed := ""
	
	Begin Transaction
	
	//Bloqueia Rotina em uso
	If !LockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
		MsgAlert("Rotina está sendo executada por outro usuário.")
		DisarmTransaction()
		Return(.F.)
	EndIf
	
	If !Empty(Alltrim(cNumPed))
		SC9->(DbSetOrder(1))
		SC9->(DbSeek(xFilial("SC9")+cNumPed))
		//Busca pedido Relacional
		cPedRel	:= Posicione("SC5",1,xFilial("SC5")+cNumPed,"C5_ZZPVORI")
		If Empty(Alltrim(cPedRel))
			_Msg := "Pedido relacionado não encontrado." + Chr(13) + Chr(13)
			_Msg += "Verificar junto ao Comercial" + Chr(13) + Chr(13)
			_Msg += "Operação Não Realizada!" + Chr(13) + Chr(13)
			MsgAlert(_Msg)
			If MsgBox("Confirma cancelamento de pedido sem amarração?","Confirma?","YesNo")
				cPedRel := cNumPed
			Else
				UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)	
				DisarmTransaction()
				Return(.F.)
			EndIf
		EndIf
 		SC5->(DbSeek(xFilial("SC5")+cPedRel))
		SA1->(DbSeek(xFilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
		cNomCli := SA1->A1_NOME
		SC5->(DbSeek(xFilial("SC5")+cNumPed))
		SA3->(DbSeek(xFilial("SA3")+SC5->(C5_VEND1)))
		
		If SC5->C5_ZSTATUS <> '2'
			Alert("Pedido NÃO liberado para Faturamento, Operação Não Realizada!")
			//Libera Conexões
			UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)			
			DisarmTransaction()
			Return(.F.)
		EndIf
		
		While SC9->(! Eof() .and. C9_FILIAL+C9_PEDIDO==xFilial("SC9")+cNumPed)
			If !Empty(SC9->C9_NFISCAL) .or. SC9->(C9_BLEST == '02') 
				SC9->(DbSkip())
				Loop
			EndIf
			
			SDC->(DbSetOrder(4))
			SDC->(DBSeek(xFilial("SDC")+SC9->(C9_PEDIDO+C9_ITEM)))
			cLocaliz	:= SDC->DC_LOCALIZ
			
			SDC->(DbSetOrder(1))
			SC6->(DbSeek(xFilial("SC6")+SC9->(C9_PEDIDO+C9_ITEM)))
			
			//Estorna SC9 e SDC
			SC9->(a460Estorna())
			
			//Desmonta Sucata
			lDCerto := U_CBDSuPed(SC9->C9_PRODUTO,cLocaliz,SC9->C9_LOCAL,SC9->C9_QTDLIB,"PV"+SC9->C9_PEDIDO) 
			If lDCerto
				//Cria Plan
				SB1->(DbSetOrder(1))
				SB1->(DBSeek(xFilial("SB1")+SC9->(C9_PRODUTO)))
				
				SE4->(DBSetOrder())
				SE4->(DBSeek(xFilial("SE4")+SC5->C5_CONDPAG))
				
				If SC6->C6_ACONDIC == "B"
					DbSelectArea("SZE")
					DbSetOrder(2) // ZE_FILIAL+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
					_nLances := SC6->C6_LANCES
					DbSeek(xFilial("SZE") + SC6->C6_NUM + SC6->C6_ITEM ,.F.)
					Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_PEDIDO == SC6->C6_NUM .And. ;
						SZE->ZE_ITEM == SC6->C6_ITEM .And. _nLances > 0 .And. SZE->(!Eof())
						If SZE->ZE_STATUS == "E" // Bobina empenhada
							_nLances--
							RecLock("SZE",.F.)
							SZE->ZE_STATUS := "F"
							SZE->ZE_DOC    := "PV"+cNumPed
							SZE->ZE_SERIE  := "1"							
							MsUnLock()
						EndIf
						SZE->(DbSkip())
					EndDo
				EndIF
				
				nQTKgCob 	:= SC9->C9_QTDLIB * SB1->B1_PESCOB
				nQtdKgPVC	:= SC9->C9_QTDLIB * SB1->B1_PESPVC
				nValTotal 	:= SC6->C6_PRCVEN * SC9->C9_QTDLIB
				nVTotPed	+= nValTotal
				Aadd(aDadCon,{SC9->C9_FILIAL,"["+DtoC(dDataBase)+"]",cNomCli,;
									SC9->C9_PEDIDO,SC9->C9_ITEM,SC6->C6_QTDVEN,SC9->C9_PRODUTO,;
									SB1->B1_DESC,cLocaliz,SC9->C9_QTDLIB,SC6->C6_PRCVEN,nValTotal,;
									SB1->B1_UM,"SC01000001","SUCATA DE COBRE NU",nQTKgCob,"KG",nQtdKgPVC,;
									SC5->C5_CONDPAG,SE4->E4_DESCRI,SA3->A3_NOME})
				Aadd(aDadCon2,{SC9->C9_FILIAL,"["+DtoC(dDataBase)+"]",cNomCli,SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_PRODUTO,;
									SB1->B1_DESC,cLocaliz,SC9->C9_QTDLIB,SC6->C6_PRCVEN,nValTotal,SA3->A3_NOME})
				lRet := .T.
			Else 
				lRet := .F.
			EndIf
			SC9->(DbSkip())
		Enddo
		
		
		//Cria Plan Financeiro
		aParc := Condicao(nVTotPed,SC5->C5_CONDPAG,,dDataBase)
		While n <= Len(aParc)
			aAdd(aDadFin,{SC5->C5_FILIAL,"["+DtoC(dDataBase)+"]",cNomCli,SC5->C5_NUM,aParc[n][2],aParc[n][1]})
			n += 1
		EndDo
		
		Aadd(aDadCon,{"","","","","","","","","","","",nVTotPed,"","","","","","","","",""})
		Aadd(aDadCon2,{"","","","","","","","","","",nVTotPed,""})
		aAdd(aDadFin,{"","","","",nVTotPed,""})
		
		aDadFim := {aDadCon,aDadFin,aDadCon2}
		
		//Exclui PV
		IncProc("Excluindo Pedido de Vendas ... Aguarde")
		U_ExPVDados(cNumPed)
		
		//Gera Plan Pedido
		IncProc("Gerando Planilhas Pedido ... Aguarde")
		Aadd(aTablePed,{"Consumo","Financeiro","Orçamento"})
		Aadd(aWstPed,{"Consumo","Financeiro","Orçamento"})
		
		// Envia API e Gera a planilha
		if ( (aRetERS := U_zCbcErs(aDadFim))[1] )
			lTExcAr := U_TExcArr(aDadFim,aColun,aWstPed,aTablePed)
		endif
		if !aRetERS[1] .or. !lTExcAr
			if !aRetERS[1]
				cMsgErr	:= aRetERS[2]
			elseif !lTExcAr
				cMsgErr := "Processo NÃO CONCLUIDO, Planilha não gerada corretamente."
			endif
			MessageBox ( cMsgErr, 'ERRO', 16 )	
			UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
			DisarmTransaction()
			return(.F.)
		endif
		
	Else
		//Libera Conexões
		UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
		DisarmTransaction()
		Return(.F.)
	EndIf
	//Libera Conexões
	UnLockByName("CDEST01_"+cFilAnt,.F.,.F.,.T.)
	//DisarmTransaction()
	//Return(.F.)
	
	End Transaction
Return(lRet)

/*/{Protheus.doc} CBDSuPed
//TODO Descrição auto-gerada.
@author juliana.leme
@since 13/12/2017
@version 1.0
@param cProduto, characters, descricao
@param cAcond, characters, descricao
@param cLocal, characters, descricao
@param nQtde, numeric, descricao
@param cDoc, characters, descricao
@type function
/*/
User Function CBDSuPed(cProduto,cAcond,cLocal,nQtde,cDoc)
Local cEnder		:= ""
Local _cPrdSct		:= ""
Local nSaldBF,_nQtdSuc	:= 0
Local lSai			:= .T.
Local lMsErroAuto	:= .F.
Local aAutoCab,aAutoItens	:= {}
Default cAcond		:= ""
Default cLocal		:= ""
Default cProduto	:= ""
Default cLocal		:= ""
Default cDoc 		:= ""
Default nQtde 		:= 0

	cProduto	:= Padr(cProduto,TamSX3("BF_PRODUTO")[1])
	cAcond		:= Padr(cAcond,TamSX3("BF_LOCALIZ")[1])
	cLocal		:= Padr(cLocal,TamSX3("BF_LOCAL")[1])
	cDoc		:= Padr(cDoc,TamSX3("D3_DOC")[1])
	    	
	DbSelectArea("SBF")	
	DbSetOrder(1)
	//Posiciona
	If SBF->(DbSeek(xFilial("SBF") + cLocal + cAcond + cProduto)) .or. Empty(cAcond)
	//Encontrou o endereço ?
	//Procura o Saldo
	nSaldBF := SBFSaldo()
	
		If  (nSaldBF > 0 .and. nSaldBF >= nQtde) .or. Empty(cAcond)
			DBSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1") + cProduto,.F.))//SD1->D1_ITEM

			_nQtdSuc	:= 0

			lMsErroAuto := .F.
			aAutoCab := {{"cProduto" , cProduto		, Nil},;
						{"cLocOrig"  , cLocal		, Nil},;
						{"cLocaliza" , cAcond		, Nil},;
						{"nQtdOrig"  , nQtde		, Nil},;
						{"cDocumento", cDoc			, Nil}}
			_nQtdSuc := Max((nQtde * (SB1->B1_PESCOB)),1)

			_cPrdSct := "SC01000001" // Cobre Nú

			SB2->(DbSetOrder(1))
			If !SB2->(DbSeek(xFilial("SB2")+Padr(Alltrim(_cPrdSct),TamSX3("D3_COD")[1])+"91",.F.))
				CriaSB2(Padr(Alltrim(_cPrdSct),TamSX3("D3_COD")[1]),"91")
			EndIf

			aAutoItens := {{	{"D3_COD"    , Pad(_cPrdSct, Len(SD3->D3_COD))	, Nil}, ;
								{"D3_LOCAL"  , "04"								, Nil}, ;
								{"D3_QUANT"  , _nQtdSuc							, Nil}, ;
								{"D3_USUARIO", cUserName						, Nil}, ;
								{"D3_RATEIO" , 100								, Nil}}}
			MSExecAuto({|v,x,y,z| Mata242(v,x,y,z)},aAutoCab,aAutoItens,3,.T.)

			If lMsErroAuto
				MostraErro()
				lSai := .F.
			Endif
				lSai := .T.
		Else
			lSai := .F.
		EndIf
	Else
		Alert("Produto + Localização NÃO encontrado")
		lSai := .F.
	EndIf
Return(lSai)

/*/{Protheus.doc} TExcelArr
//TODO Transforma Array em planilha de Excel.
@author juliana.leme
@since 26/04/2016
@version 1.0
@param _aDados, Array, Dados para ser transformados em XLS
@type function
/*/
User Function TExcArr(aDados,aColuna,aWSheet,aTable)
	Local _oExcel1		:= FWMSEXCEL():New()
	Local dDataInv 		:= dDataBase
	Local aParamBox 	:= {}
	Local aRet 			:= ""
	Local cDir			:= ""
	Local nSaldProt		:= 0
	Local n				:= 1
	Local n1			:= 1
	Local lRet			:= .T.
	Default aDados		:= {}
	Default aColuna		:= {}
	Default aWSheet		:= {}
	Default	aTable		:= {}

	aAdd(aParamBox,{6,"Pasta de Saída:","C:\","","","" ,70,.T.,"Arquivo .XLS |*.XLS"})

	If !ParamBox(aParamBox, "Parametros", @aRet)
		Return(.F.)
	EndIf

	//cDir		:= Alltrim(Substr(aRet[1],1,rat("\",aRet[1])))
	cDir		:= Alltrim(aRet[1])
	ProcRegua(0)
	
	n1:= 1
	While n1 <= Len(aTable[1])
	 	_oExcel1:AddworkSheet(aWSheet[1][n1])
		_oExcel1:AddTable(aWSheet[1][n1],aTable[1][n1])
		
		n:= 1
		While n <= len(aColuna[n1])
			_oExcel1:AddColumn(aWSheet[1][n1],aTable[1][n1],aColuna[n1][n],1,1)//1
			n += 1
		EndDo
		
		n:= 1
		While n <= len(aDados[n1])
			_oExcel1:AddRow(aWSheet[1][n1],aTable[1][n1],aDados[n1][n])
			n += 1
		EndDo
		n1 += 1
	EndDo
	
	_oExcel1:Activate()
	_oExcel1:GetXMLFile(cDir+".xml")

	Alert("A planilha foi exportada com sucesso em "+cDir+".xml")
Return(lRet)
