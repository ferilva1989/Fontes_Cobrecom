#INCLUDE "SIGACUSA.CH"
#INCLUDE "PROTHEUS.CH"
/*
	Leonardo 24/11/20
	Codigo deselegante extraido dos fontes originais sigacusa.prx e sigacusb.prx
	Precisamos fazer desta forma pois usamos a função interna Estrut2(), e ela apresentou
	uma mudança na versão 12.1.27, quebrando as personalizações, transoformando em user function
	resolvemos o sintoma, pois o problema é este exesso de personalização mal feita em uma processo
	mal definido pelas areas.
*/
user function cbcStrut2(cProduto,nQuant,cAliasEstru,oTempTable,lAsShow,lnew)
	private nEstru 		:= 0
	default cProduto    := ''
	default nQuant      := 0
	default cAliasEstru := "ESTRUT"
	default oTempTable  := nil
	default lAsShow     := .T.
	default lnew		:= GetNewPar('ZZ_CBESTR',.T.)
	
	if lnew
		cbcStrut(cProduto,nQuant,cAliasEstru,oTempTable,lAsShow)
	else
		Estrut2(cProduto,nQuant,cAliasEstru,,lAsShow)
	endif
return nil

static function cbcStrut(cProduto,nQuant,cAliasEstru,oTempTable,lAsShow,lPreEstru,lVldData,lVldRev)
	local nRegi		   :=0
	local nQuantItem   :=0
	local aCampos 	   :={}
	local aTamSX3	   :={}
	local lAdd		   :=.F.
	local nRecno	   := nil
	local cCodigo	   := nil
	local cComponente  := nil
	local cTrt		   := nil
	local cGrOpc	   := nil	
	local cOpc		   := nil
	default lPreEstru  := .F.
	default oTempTable := NIL
	default lVldData   := .T.
	default lVldRev    := .T.

	cAliasEstru	:= If(cAliasEstru == NIL,"ESTRUT",cAliasEstru)
	nQuant 		:= If(nQuant == NIL,1,nQuant)
	lAsShow	    := If(lAsShow==NIL,.F.,lAsShow)
	nEstru++
	if nEstru == 1
		aadd(aCampos,{"NIVEL","C",6,0})
		aTamSX3:=TamSX3(If(lPreEstru,"GG_COD","G1_COD"))
		aadd(aCampos,{"CODIGO","C",aTamSX3[1],0})
		aTamSX3:=TamSX3(If(lPreEstru,"GG_COMP","G1_COMP"))
		aadd(aCampos,{"COMP","C",aTamSX3[1],0})
		aTamSX3:=TamSX3(If(lPreEstru,"GG_QUANT","G1_QUANT"))
		aadd(aCampos,{"QUANT","N",Max(aTamSX3[1],18),aTamSX3[2]})
		aTamSX3:=TamSX3(If(lPreEstru,"GG_TRT","G1_TRT"))
		aadd(aCampos,{"TRT","C",aTamSX3[1],0})
		aTamSX3:=TamSX3(If(lPreEstru,"GG_GROPC","G1_GROPC"))
		aadd(aCampos,{"GROPC","C",aTamSX3[1],0})
		aTamSX3:=TamSX3(If(lPreEstru,"GG_OPC","G1_OPC"))
		aadd(aCampos,{"OPC","C",aTamSX3[1],0})
		AADD(aCampos,{"REGISTRO","N",14,0})

		oTempTable := FWTemporaryTable():New( cAliasEstru )
		oTempTable:SetFields( aCampos )
		oTempTable:AddIndex("INDICE1", {"NIVEL","CODIGO","COMP","TRT"} )
		oTempTable:Create()
	EndIf

	dbSelectArea(If(lPreEstru,"SGG","SG1"))
	dbSetOrder(1)
	dbSeek(xFilial()+cProduto)
	While !Eof() .And. If(lPreEstru,GG_FILIAL+GG_COD,G1_FILIAL+G1_COD) == xFilial()+cProduto
		nRegi:=Recno()
		cCodigo    :=If(lPreEstru,GG_COD,G1_COD)
		cComponente:=If(lPreEstru,GG_COMP,G1_COMP)
		cTrt       :=If(lPreEstru,GG_TRT,G1_TRT)
		cGrOpc     :=If(lPreEstru,GG_GROPC,G1_GROPC)
		cOpc       :=If(lPreEstru,GG_OPC,G1_OPC)
		If cCodigo != cComponente
			lAdd:=.F.
			If !(&(cAliasEstru)->(dbSeek(StrZero(nEstru,6)+cCodigo+cComponente+cTrt))) .Or. (lAsShow)
				nQuantItem:=xlEstr(nQuant,nil,nil,nil,nil,lPreEstru,,,,,,lVldData,,,lVldRev)
				IF nQuantItem != 0
					RecLock(cAliasEstru,.T.)
					Replace NIVEL    With StrZero(nEstru,6)
					Replace CODIGO   With cCodigo
					Replace COMP     With cComponente
					Replace QUANT    With nQuantItem
					Replace TRT      With cTrt
					Replace GROPC    With cGrOpc
					Replace OPC      With cOpc
					Replace REGISTRO With If(lPreEstru,SGG->(Recno()),SG1->(Recno()))
					MsUnlock()
					lAdd:=.T.
				EndIf
				dbSelectArea(If(lPreEstru,"SGG","SG1"))
			EndIf
			nRecno:=Recno()
			IF dbSeek(xFilial()+cComponente)
				cCodigo:=If(lPreEstru,GG_COD,G1_COD)
				If nQuantItem != 0
					cbcStrut(cCodigo,nQuantItem,cAliasEstru,@oTempTable,lAsShow,lPreEstru,lVldData,lVldRev)
					nEstru --
				EndIf
			Else
				MsGoto(nRecno)
				If !(&(cAliasEstru)->(dbSeek(StrZero(nEstru,6)+cCodigo+cComponente+cTrt))) .Or. (lAsShow.And.!lAdd)
					nQuantItem:=xlEstr(nQuant,nil,nil,nil,nil,lPreEstru,,,,,,lVldData,,,lVldRev)
					If nQuantItem
						RecLock(cAliasEstru,.T.)
						Replace NIVEL    With StrZero(nEstru,6)
						Replace CODIGO   With cCodigo
						Replace COMP     With cComponente
						Replace QUANT    With nQuantItem
						Replace TRT      With cTrt
						Replace GROPC    With cGrOpc
						Replace OPC      With cOpc
						Replace REGISTRO With If(lPreEstru,SGG->(Recno()),SG1->(Recno()))
						MsUnlock()
					EndIf
					dbSelectArea(If(lPreEstru,"SGG","SG1"))
				EndIf
			Endif
		EndIf
		MsGoto(nRegi)
		dbSkip()
	Enddo
Return NIL

static function xlEstr(nQuant,dDataStru,cOpcionais,cRevisao,nMotivo,lPreEstr,lTipoDec,cAliasSG1,cAliasSB1,lMRP,cProOpc,lVldData,lVlOpc,lProBlq,lVldRev)
	local nQuantItem:=0,cUnidMod,nG1Quant:=0,nQBase:=0,nDecimal:=0,nBack:=0
	local cAlias:=Alias(),nRecno:=Recno(),nOrder:=IndexOrd()
	local lOk:=.T.
	local nDecOrig:=Set(3,8)
	local cCodigo
	local cComponente
	local cOpcArq
	local dDataIni
	local dDataFim
	local nQtdCampo
	local nQtdPerda
	local cFixVar
	local cTRT
	local aVldEstr := {.T.,.T.,.T.} //na ordem, indica se valida datas, grupo de opc. e revisoes na estrutura
	local aUsrVlEstr := {}
	local aOpc := Nil
	local nI        := 0
	local nAltPer   := 0
	local nPos      := 0
	local lAchouB1  := .F.
	Local lTemQBP   := .T.
	Local lUsaMOpc	:= If(SuperGetMv('MV_REPGOPC',.F.,"N") == "S",.T.,.F.)
	Local lProdMod  := .T.
	Local lPCPREVATU	:= FindFunction('PCPREVATU')
	Local cRevAtu		:= ''

	static lUSRVLESTR
	static lMQTBASEST
	static lMQTDESTR
	static nDecSGG
	static nDecSG1
	static lEMPREVVAZ := Nil

	default nMotivo	    := 0
	default lPreEstr	:= .F.
	default lTipoDec	:= .T.
	default cAliasSG1	:= "SG1"
	default cAliasSB1	:= "SB1"
	default lMRP		:= .F.
	default cProOpc     := ""
	default lVldData := .T.
	default lVlOpc   := .T.
	default lProBlq  := .T. // Considera se o Produto está bloqueado.
	default lVldRev  := .T.

	cCodigo    :=If(lPreEstr,SGG->GG_COD,(cAliasSG1)->G1_COD)
	cComponente:=If(lPreEstr,SGG->GG_COMP,(cAliasSG1)->G1_COMP)
	cOpcArq    :=If(lPreEstr,SGG->GG_GROPC+SGG->GG_OPC,(cAliasSG1)->G1_GROPC+(cAliasSG1)->G1_OPC)
	cOpcArq    :=If(lUsaMOpc .And. !Empty(cProOpc) .And. !Empty(cOpcArq), cProOpc, cOpcArq)
	nG1Quant   :=If(lPreEstr,SGG->GG_QUANT,(cAliasSG1)->G1_QUANT)
	nQtdCampo  :=If(lPreEstr,SGG->GG_QUANT,(cAliasSG1)->G1_QUANT)
	nQtdPerda  :=If(lPreEstr,SGG->GG_PERDA,(cAliasSG1)->G1_PERDA)
	cFixVar    :=If(lPreEstr,SGG->GG_FIXVAR,(cAliasSG1)->G1_FIXVAR)
	cTRT       :=If(lPreEstr,SGG->GG_TRT,(cAliasSG1)->G1_TRT)
	lUSRVLESTR	 := IIF(lUSRVLESTR == Nil,ExistBlock('USRVLESTR'),lUSRVLESTR)
	lMQTBASEST	 := IIF(lMQTBASEST == Nil,ExistBlock('MQTBASEST'),lMQTBASEST)
	lMQTDESTR	 := IIF(lMQTDESTR  == Nil,ExistBlock('MQTDESTR'),lMQTDESTR)
	nDecSGG	 := IIF(nDecSGG    == Nil,TamSX3("GG_QUANT")[2],nDecSGG)
	nDecSG1	 := IIF(nDecSG1    == Nil,TamSX3("G1_QUANT")[2],nDecSG1)

	lEMPREVVAZ := IIF(lEMPREVVAZ == Nil, ExistBlock("EMPREVVAZ") .And. ExecBlock('EMPREVVAZ',.F.,.F.), lEMPREVVAZ)

	If lMRP
		dDataIni   :=If(lPreEstr,SGG->GG_INI,Stod((cAliasSG1)->G1_INI))
		dDataFim   :=If(lPreEstr,SGG->GG_FIM,Stod((cAliasSG1)->G1_FIM))
	Else
		dDataIni   :=If(lPreEstr,SGG->GG_INI,(cAliasSG1)->G1_INI)
		dDataFim   :=If(lPreEstr,SGG->GG_FIM,(cAliasSG1)->G1_FIM)
	EndIf

	If lPreEstr
		nDecimal:=nDecSGG
	Else
		nDecimal:=nDecSG1
	EndIf

	//Verifica os opcionais cadastrados na Estrutura
	cOpcionais:= If((cOpcionais == NIL),"",cOpcionais)

	If !Empty(cOpcionais)
		nPos := aScan(aOpcCache,{|x| x[1] == cOpcionais})
		If nPos > 0
			aOpc := aOpcCache[nPos][2]
		Else
			aOpc := Str2Array(cOpcionais,.F.)
			aAdd(aOpcCache,{cOpcionais,aOpc})
		EndIf

		If aOpc != Nil
			cOpcArq := cProOpc
		EndIf
	EndIf

	//Verifica a Revisao Atual do Componente
	cRevisao:= If((cRevisao == NIL),"",cRevisao)

	//Verifica a data de validade
	dDataStru := If((dDataStru == NIL),dDataBase,dDataStru)

	If lUSRVLESTR
		//Posiciona na SG1 para PE
		If lMRP
			dbSelectArea("SG1")
			MsSeek(xFilial("SG1")+cCodigo)
		EndIf

		aUsrVlEstr := ExecBlock("USRVLESTR",.F.,.F.,{cCodigo,cComponente,cTRT})

		For nI := 1 To 3
			If ValType(aUsrVlEstr[nI]) == "L"
				aVldEstr[nI] := aUsrVlEstr[nI]
			EndIf
		Next nI
	EndIf

	If lMRP
		lAchouB1 := .T.
	Else
		dbSelectArea("SB1")
		dbSetOrder(1)
		lAchouB1 := MsSeek(xFilial("SB1")+cCodigo)
	EndIf

	If lAchouB1
		If Empty(cOpcionais) .And. !Empty(RetFldProd((cAliasSB1)->B1_COD,"B1_OPC",cAliasSB1))
			cOpcionais:=RetFldProd((cAliasSB1)->B1_COD,"B1_OPC",cAliasSB1)
		EndIf
		//Alteração para considerar REV por filial
		cRevAtu :=  IIF(lPCPREVATU , PCPREVATU((cAliasSB1)->B1_COD), (cAliasSB1)->B1_REVATU)
		If Empty(cRevisao) .And. !Empty(cRevAtu)
			cRevisao:= cRevAtu
		EndIf
		If aVldEstr[1] .And. !(dDataStru >= dDataIni .And. dDataStru <= dDataFim) .And. lVldData
			nMotivo:=1 // Componente fora das datas inicio / fim
			lOk:=.F.
		EndIf
		If aVldEstr[2] .And. lOk .And. !empty(cOpcionais) .And. !Empty(cOpcArq) .And. !(cOpcArq $ cOpcionais) .And. lVlOpc
			nMotivo:=2  // Componente fora dos grupos de opcionais
			lOk:=.F.
		EndIf

		If Empty(cRevisao)
			cRevisao := Space(Len((cAliasSG1)->G1_REVINI))
		EndIf

		If aVldEstr[3] .And. lOk .And. !lPreEstr .And. ((cAliasSG1)->G1_REVINI > cRevisao .Or. (cAliasSG1)->G1_REVFIM < cRevisao) .And. lVldRev
			If ! (lEMPREVVAZ .And. Empty(cRevisao)) //PE para empenhar o componente quando a revisão está em branco.
				nMotivo:=3	// Componente fora das revisoes
				lOk:=.F.
			EndIf
		EndIf
	EndIf

	If !lMRP .And. cAlias <> ''
		dbSelectArea(cAlias)
		dbSetOrder(nOrder)
		MsGoto(nRecno)
	EndIf

	If lOk
		cUnidMod := SuperGetMv("MV_UNIDMOD")
		SB1->(MsSeek(xFilial("SB1")+cCodigo))
		nQBase:=RetFldProd(cCodigo,If(lPreEstr.And.lTemQBP,"B1_QBP","B1_QB"))
		If lMQTBASEST
			nAltPer:=ExecBlock('MQTBASEST', .F., .F., {nQBase})
			IF Valtype(nAltPer) == 'N'
				nQBase := nAltPer
			EndIf
		EndIf
		If !lMRP
			IF lProBlq
				SB1->(MsSeek(xFilial("SB1")+cComponente))
				IF ((RetFldProd(SB1->B1_COD,"B1_FANTASM") != 'S') .and. (SB1->B1_MSBLQL == '1'))
					nQuantItem := 0
					lOk := .F.
				EndIf

				IF SB1->B1_MSBLQL == '1'
					nQuantItem := 0
					lOk := .F.
				END IF

			EndIf
		EndIf
		If lOk
			lProdMod := IsProdMod(cComponente)
			If lProdMod
				cTpHr := SuperGetMv("MV_TPHR")
				If cTpHr == "N"
					nG1Quant := Int(nG1Quant)
					nG1Quant += ((nQtdCampo-nG1Quant)/60)*100
				EndIf
			EndIf

			If cFixVar $ " V"
				If lProdMod .And. cUnidMOD != "H"
					nQuantItem := ((nQuant / nG1Quant) / (100 - nQtdPerda)) * 100
				Else
					nQuantItem := ((nQuant * nG1Quant) / (100 - nQtdPerda)) * 100
				EndIf
				nQuantItem := nQuantItem / Iif(nQBase <= 0,1,nQBase)
			Else
				If lProdMod .And. cUnidMOD != "H"
					nQuantItem := (nG1Quant / (100 - nQtdPerda)) * 100
				Else
					nQuantItem := (nG1Quant / (100 - nQtdPerda)) * 100
				EndIf
			Endif

		EndIf
		nQuantItem:=Round(nQuantItem,nDecimal)
	EndIf
	If lMQTDESTR
		nAltPer:=ExecBlock('MQTDESTR', .F., .F., {nQuant,nQuantItem,lOk,nMotivo,cOpcArq,cOpcionais})
		If Valtype (nAltPer) == 'N'
			nQuantItem:= nAltPer
		EndIf
	EndIf
	If !lMRP
		Do Case
			Case (SB1->B1_TIPODEC == "A" .And. lTipoDec)
				nBack := Round( nQuantItem,0 )
			Case (SB1->B1_TIPODEC == "I" .And. lTipoDec)
				nBack := Int(nQuantItem)+If(((nQuantItem-Int(nQuantItem)) > 0),1,0)
			Case (SB1->B1_TIPODEC == "T" .And. lTipoDec)
				nBack := Int( nQuantItem )
			OtherWise
				nBack := nQuantItem
		EndCase
	Else
		nBack := nQuantItem
	EndIf
	Set(3,nDecOrig)
Return( nBack )


/* TEST ZONE */
user function xzEEstTst(lNew, cCod)
	local  oTempTable 	:= nil
	local linha			:= chr(13) + chr(10)
	local cMsg			:= ''
	default lNew        := .T.
	//u_cbcStrut2(cProduto,nQuant,cAliasEstru,oTempTable,lAsShow,lnew)
	_cNomeArq := u_cbcStrut2(Padr(cCod, TamSX3('B1_COD')[1]),6100,"ESTRUT",@oTempTable,.T.,lNew)
    DbSelectArea("ESTRUT")
    DbSetOrder(0)             
	DbGoTop()
	cMsg += 'Codigo' +' / ' + 'Componente' +' / ' + 'Nivel' + linha
	Do While ESTRUT->(!Eof())
	    cMsg += ESTRUT->(CODIGO) +' / ' + ESTRUT->(COMP) +' / ' + ESTRUT->(NIVEL) + linha
		ESTRUT->(DbSkip())	
	EndDo
	FIMESTRUT2(nil, oTempTable)
	DbCloseArea()
	if !empty(cMsg)
		msgInfo(cMsg, 'Resultado')
	else
		alert('Nenhuma estrutura encontrada')
	endif
return(nil)
