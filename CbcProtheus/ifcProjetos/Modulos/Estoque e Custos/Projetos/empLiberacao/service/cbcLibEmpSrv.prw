#include 'protheus.ch'
#include 'parmtype.ch'
#include "fwmvcdef.ch"
#Include 'statusPedido.ch'

#define TAMANHO	1
#define DECIMAL 2
#define TIPO 3

/*/{Protheus.doc} zLEmpEnv
@author bolognesi
@since 06/12/2018
@version 1.0
@param oCtrl, object, Objeto Controller cbcLibEmp()
@param nRecSC9, numeric, Recno do SC9, ponto de partida
para realizar o posicionamento das tabelas SC9- >(SC5,SC6,(SA1/SA2),SB1, SB2, SBF)
@type function
@description Realiza o posicionamento das tabelas
/*/
user function zLEmpEnv(oCtrl, nRecSC9, lAll, lCanc)
	local cFl := FwFilial()
	local cLocaliz	:= ''
	local cTabEnt	:= ''
	default lAll	:= .T.
	default lCanc	:= .F.

	dbSelectArea("SC9")
	SC9->(dbGoto(nRecSC9))
	if SC9->(Recno()) != nRecSC9
		// Utiliza-se assim para disparar user exception
		oCtrl:setStatus(.F., 'Registro SC9 não encontrado', .T.)
	else
		if lAll
			existTab('SC5', 1, SC9->C9_PEDIDO, @oCtrl)
			existTab('SC6', 1, SC9->(C9_PEDIDO + C9_ITEM + C9_PRODUTO), @oCtrl)
			existTab('SB1', 1, SC9->(C9_PRODUTO),@oCtrl)

			if SC9->(C9_PEDIDO + C9_ITEM + C9_SEQUEN) == SDC->(DC_PEDIDO + DC_ITEM + DC_SEQ)
				cLocaliz := SDC->(DC_LOCALIZ)
			else
				cLocaliz := Padr(SC6->(C6_ACONDIC + StrZero(SC6->C6_METRAGE,5)), TamSx3('BF_LOCALIZ')[1])
			endif

			if  SC6->(Alltrim(C6_ACONDIC)) == 'B' .and. lCanc
				if SC9->(C9_BLEST) == Space(TamSx3('C9_BLEST')[1])
					existTab('SZE',, SC9->(C9_PEDIDO + C9_ITEM + C9_SEQUEN), @oCtrl, 'SEQLIB', .F.)
				endif
			endif

			if SC5->C5_TIPO $ "DB"
				cTabEnt := 'SA2'
			else
				cTabEnt := 'SA1'
			endIf
			existTab(cTabEnt, 1, SC5->(C5_CLIENTE + C5_LOJACLI), @oCtrl)
			existTab('SB2', 1, SC6->(C6_PRODUTO + C6_LOCAL), @oCtrl)
			existTab('SBF', 1, SC6->(C6_LOCAL + cLocaliz + C6_PRODUTO), @oCtrl,,.F.)
		endif
	endif 

return(nil)


user function zLEmShDl(nQtdLiber,cMarca, oMainCtrl)
	local aSaldos 	:= {}
	local cMaterial := SC6->(cValToChar(C6_LANCES) + ' X ' + C6_ACONDIC + cValToChar(C6_METRAGE) )
	private oDlg 	:= nil
	private nSldSBF	:= 0
	nQtdLiber 		:= sldItmPed(oMainCtrl)

	if  SC6->(Alltrim(C6_ACONDIC)) == 'B'
		if MsgNoYes("Item foi vendido acondicionado em Bobina, utilizar liberação especifica de bobina! "," Liberação Bobinas ")
			FWMsgRun(, { |oSay| U_vLELibBob(SC5->(Recno()), oMainCtrl) }, 	"Aguarde...", "Procurando Bobinas...")
		endif
		nOpcDlg := 2
	elseif Empty(nQtdLiber)
		oMainCtrl:setNotif('Validação', 'Não existe quantidade em estoque disponviel para liberação!!')
		nOpcDlg := 2
	else
		DEFINE MSDIALOG oDlg FROM  177,001 TO 400,607 TITLE OemToAnsi('Liberação de Estoque') PIXEL
		@ 005,011 TO 51, 291 LABEL "" OF oDlg  PIXEL
		@ 053,144 TO 90, 289 LABEL "" OF oDlg  PIXEL
		@ 053,011 TO 90, 138 LABEL "" OF oDlg  PIXEL
		DEFINE SBUTTON FROM 096,220 TYPE 1 ACTION  (nOpcDlg := 1,oDlg:End()) ENABLE OF oDlg
		DEFINE SBUTTON FROM 096,256 TYPE 2 ACTION  (nOpcDlg := 2,oDlg:End()) ENABLE OF oDlg 
		@ 010,015 SAY OemToAnsi('Pedido')                SIZE 23, 7 OF oDlg PIXEL
		@ 010,042 SAY SC9->C9_PEDIDO                     SIZE 26, 7 OF oDlg PIXEL
		@ 011,108 SAY OemToAnsi('Cond.Pagto.')           SIZE 38, 7 OF oDlg PIXEL
		@ 011,145 SAY SC5->C5_CONDPAG                    SIZE 17, 7 OF oDlg PIXEL
		@ 011,170 SAY OemToAnsi('Bloqueio')              SIZE 27, 7 OF oDlg PIXEL
		@ 011,199 SAY SC9->C9_BLEST  					 SIZE 87, 7 OF oDlg PIXEL
		@ 021,015 SAY OemToAnsi('Cliente')               SIZE 23, 7 OF oDlg PIXEL
		@ 021,044 SAY IIf(SC5->C5_TIPO$"BD",Substr(SA2->A2_NOME,1,35),Substr(SA1->A1_NOME,1,35))	SIZE 114,7 OF oDlg PIXEL
		@ 021,171 SAY OemToAnsi('Risco')                 SIZE 21, 7 OF oDlg PIXEL
		@ 021,199 SAY IIF(SC5->C5_TIPO$"BD",SA2->A2_RISCO,SA1->A1_RISCO) SIZE 7, 7 OF oDlg PIXEL
		@ 031,015 SAY OemToAnsi('Produto')               SIZE 25, 7 OF oDlg PIXEL
		@ 031,043 SAY Substr(SB1->B1_DESC,1,30)          SIZE 98, 7 OF oDlg PIXEL
		@ 041,015 SAY OemToAnsi('Codigo')                SIZE 25, 7 OF oDlg PIXEL
		@ 041,043 SAY Alltrim(SB1->B1_COD)          	 SIZE 98, 7 OF oDlg PIXEL
		@ 041,171 SAY OemToAnsi('Saldo')                 SIZE 18, 7 OF oDlg PIXEL
		@ 031,199 SAY SC6->C6_Local                      SIZE 20, 7 OF oDlg PIXEL
		@ 031,171 SAY OemToAnsi('Local')                 SIZE 27, 7 OF oDlg PIXEL
		@ 041,199 SAY nQtdLiber 	Picture PesqPict("SBF","BF_QUANT",14) SIZE 43, 7 OF oDlg PIXEL
		@ 056,151 SAY OemToAnsi('Localização')           SIZE 38, 7 OF oDlg PIXEL
		@ 056,203 SAY  SBF->BF_LOCALIZ                   SIZE 45, 7 OF oDlg PIXEL	
		@ 067,016 SAY OemToAnsi('Qtd.Total Pedido')      SIZE 53, 7 OF oDlg PIXEL
		@ 067,072 SAY SC6->(C6_QTDVEN) Picture PesqPictQt("C6_QTDVEN",10) SIZE 42, 7 OF oDlg PIXEL
		@ 067,151 SAY OemToAnsi('Data Ult.Saida')        SIZE 46, 7 OF oDlg PIXEL
		@ 067,202 SAY RetFldProd(SB1->B1_COD,"B1_UCOM")  SIZE 33, 7 OF oDlg PIXEL
		@ 078,016 SAY OemToAnsi('Material')              SIZE 50, 7 OF oDlg PIXEL
		@ 078,072 SAY cMaterial   						 SIZE 42, 7 OF oDlg PIXEL
		@ 078,151 SAY OemToAnsi('QTD. LIBERAÇÂO')     SIZE 46, 7 OF oDlg PIXEL
		@ 078,199 MSGET nQtdLiber Picture PesqPictQt("C9_QTDLIB",20) Valid vldQtd(nQtdLiber,oMainCtrl) SIZE 53, 7 OF oDlg PIXEL

		ACTIVATE MSDIALOG oDlg CENTERED
	endif
return(nOpcDlg)


user function zLEmEst(oCtrl, nQtdLiber,oStatus)
	local aLocaliz	:= {}
	local lEstoque	:= .T.
	local lCredito	:= .T.
	local lLiber	:= .T.
	local lTransf	:= .F.
	local nVlrCred	:= 0
	local nDifLib	:= 0
	local aAreaC5	:= {}
	local aAreaC6	:= {}
	local aAreaC9	:= {}
	local aAreaBF	:= {}
	local aAreaB2	:= {}
	local aAreaZE	:= {}
	local nQtdAnt	:= 0
	local nQtdLib	:= 0
	local aRecLib	:= {}
	local lAtuEmp	:= .T.
	local nTitLib	:= 0
	local nX		:= 0
	local nRealLib	:= 0
	local cPed		:= ''
	local cItm		:= ''
	local aBobinas	:= {}

	if nQtdLiber > 0
		if validEmEst(@nQtdLiber, @oCtrl, @nDifLib)
			DbSelectArea('SC5')
			SC5->(DbSetOrder(1))
			SC5->(MsSeek(xFilial("SC5")+ SC9->(C9_PEDIDO)))
			aAreaC5 := SC5->(GetArea())
			aAreaC6 := SC6->(GetArea())
			aAreaC9 := SC9->(GetArea())
			aAreaBF := SBF->(GetArea())
			aAreaB2	:= SB2->(GetArea())
			aAreaZE	:= SZE->(GetArea())
			cPed 	:= SC9->(C9_PEDIDO)
			cItm 	:= SC9->(C9_ITEM)
			// Preservar quantidade fica bloqueada
			nQtdAnt  	:= SC9->C9_QTDLIB - nQtdLiber
			// Obter o total que já esta liberado
			nQtdLib	 	:= getTotLib(cPed,cItm)
			// Obter todos os SDC ja empenhados deste item
			aLocaliz 	:= aEmpPed(cPed,cItm,oStatus, .F.)
			// Obter as bobinas ja liberadas para o pedido
			if  SC6->(Alltrim(C6_ACONDIC)) == 'B'
				aBobinas 	:= aEmpBob(cPed, cItm, 'E')
			endif
			// Obter Recno de todos os SC9 Liberados deste item
			aRecLib 	:= getTotLib(cPed,cItm, .T.)
			// Estorna todos os SC9 Liberados, cancelando os status ZZ9
			for nX := 1 to len(aRecLib)
				SC9->(DbGoTo(aRecLib[nX]))
				// Realiza os posicionamentos
				u_zLEmpEnv(oCtrl, SC9->(Recno()),,.T.)
				oStatus:clrStatus('SC9', SC9->(Recno()))
				SC9->(A460Estorna(/*lMata410*/,lAtuEmp,@nVlrCred))
			next nX
			RestArea(aAreaZE)
			RestArea(aAreaB2)
			Restarea(aAreaBF)
			RestArea(aAreaC9)
			RestArea(aAreaC6)
			RestArea(aAreaC5)
			// Adiciona a bobina status P que sera empenhada, as demais já empenhadas
			if  SC6->(Alltrim(C6_ACONDIC)) == 'B'
				aadd(aBobinas, {SZE->(Recno()), SZE->(ZE_QUANT)} )
			endif
			oStatus:clrStatus('SC9', SC9->(Recno()))
			SC9->(A460Estorna(/*lMata410*/,lAtuEmp,@nVlrCred))

			RestArea(aAreaZE)
			RestArea(aAreaB2)
			Restarea(aAreaBF)
			RestArea(aAreaC9)
			RestArea(aAreaC6)
			RestArea(aAreaC5)

			// Cria novo somando o que já estava liberado mais a liberação atual incluindo os empenhos
			// Tratamento legado
			if empty(SB1->(B1_FAMILIA))
				aadd(aLocaliz ,{"","",SBF->(BF_LOCALIZ),"",nQtdLiber,nQtdLiber,Ctod(""),"","","",SC9->C9_LOCAL,0})
				nRealLib := ( nQtdLiber + nQtdLib )
				nTitLib += MaLibDoFat(SC6->(RecNo()),nRealLib,@lCredito,@lEstoque,.F.,.F.,lLiber,lTransf,NIL,NIL,aLocaliz,NIL,NIL,NIL,nRealLib)
				// Tratamento novo
			else
				nRealLib := ( nQtdLiber + nQtdLib )
				nTitLib += MaLibDoFat(SC6->(RecNo()),nRealLib,@lCredito,@lEstoque,.F.,.F.,lLiber,lTransf,NIL,NIL,NIL,NIL,NIL,nRealLib)
			endif

			// Atualiza Status e faz procedimentos finais
			prcFimEmEst(@oCtrl,oStatus,aBobinas)
			// Atualizar ZZ9 com os novos SDC criados
			aLocaliz := aEmpPed(cPed, cItm, oStatus, .T.)
			// Cria caso tenha valor residual, um SC9 bloqueado
			if nQtdAnt > 0
				nQtdAnt += nDifLib 
				nTitLib += MaLibDoFat(SC6->(RecNo()),@nQtdAnt,.T.,.F.,.F.,.F.,.F.,.F.,,,,,,@nVlrCred,nQtdAnt)
			endif
			RestArea(aAreaC6)
			RestArea(aAreaC5)			
			SC5->(MaLiberOk({C5_NUM},.F.))
			RestArea(aAreaC6)
			RestArea(aAreaC5)
		endif
	endif
return(nil)


user function zCEmEst(oCtrl, oStatus)
	local nVlrCred	:= 0
	local nQtdCanc	:= 0
	local nNewValue	:= 0
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local aAreaC5	:= {}
	local aAreaC6	:= {}
	local aAreaC9	:= {}
	local aAreaBF	:= {}
	local aAreaB2	:= {}
	local aAreaZE	:= {}
	local lAtuEmp	:= .T.
	local nTotBlq	:= 0
	local nPermLib	:= 0
	local nAnteBlq	:= 0
	local aLocaliz	:= {}
	local cPed		:= ''
	local cItm		:= ''
	local nPos		:= 0
	local cLocaliz	:= ''
	local nNovo		:= 0
	local aRecBlq	:= {}
	local nX		:= 0
	local nTitLib	:= 0
	local lCredito	:= .T.
	local lEstoque	:= .T.
	local lLiber	:= .T.
	local lTransf	:= .F.
	local aBobinas	:= {}
	local cQuant	:= 0
	local lRet		:= .T.

	if validCEmEst(@nQtdCanc, @oCtrl)

		DbSelectArea('SC5')
		SC5->(DbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5")+ SC9->(C9_PEDIDO)))
		// SC9 vem posicionado no registro que esta liberado
		aAreaC5 	:= SC5->(GetArea())
		aAreaC6	 	:= SC6->(GetArea())
		aAreaC9		:= SC9->(GetArea())
		aAreaBF 	:= SBF->(GetArea())
		aAreaB2		:= SB2->(GetArea())
		aAreaZE		:= SZE->(GetArea())
		cPed 		:= SC9->(C9_PEDIDO)
		cItm 		:= SC9->(C9_ITEM)
		cLocaliz	:= SDC->(DC_LOCALIZ)

		// Obter o valor que deve permanecer liberado SC9, apos cancelamento do SDC
		nPermLib  	:= (SC9->C9_QTDLIB - SDC->(DC_QUANT))
		// Obter o valor que atualmente esta bloqueado, pois o cancelado deve gerar um novo
		// Obter do estado atual o total bloqueado (que devera ser acrescido da quantidad cancelado em um novo registro bloqueado)
		nAnteBlq	:= getTotBlq(cPed,cItm) 
		// Obter os empenhos SDC realizados, já estornando o status na ZZ9
		aLocaliz 	:= aEmpPed(cPed,cItm,oStatus, .F.)
		// Obter as bobinas liberadas deste item
		if  SC6->(Alltrim(C6_ACONDIC)) == 'B'
			aBobinas 	:= aEmpBob(cPed, cItm, 'E')
		endif
		// Remover destes empenhos o empenho a ser cancelado, pois o restante deverá ser
		// utilizado na criação de uma SC9 que deve permanecer liberado (Soma do SDC deve ser igual a nPermLib)
		// {"","",cLocaliz,"",nQuant,nQuant,Ctod(""),"","","",cLocal,0}
		nNovo	:= (len(aLocaliz) - 1)
		if (nPos := AScan(aLocaliz,{|aDc| aDc[3] == cLocaliz  })) > 0
			Adel(aLocaliz,nPos )
			ASize(aLocaliz, nNovo)
		endIf
		// Obter os registros SC9 bloqueados
		aRecBlq 	:= getTotBlq(cPed,cItm, .T.)
		// Inicia-se os estornos, primeiro os SC9 obtidos bloqueados
		for nX := 1 to len(aRecBlq)
			SC9->(DbGoTo(aRecBlq[nX]))
			// Posicionamentos
			u_zLEmpEnv(oCtrl, SC9->(Recno()),,.T.)
			oStatus:clrStatus('SC9', SC9->(Recno()))
			SC9->(A460Estorna(/*lMata410*/,lAtuEmp,@nVlrCred))
		next nX
		RestArea(aAreaZE)
		RestArea(aAreaB2)
		Restarea(aAreaBF)
		RestArea(aAreaC9)
		RestArea(aAreaC6)
		RestArea(aAreaC5)

		// Voltando a area original (posicionado no SC9 Liberado), vamos estorna-lo
		oStatus:clrStatus('SC9', SC9->(Recno()))
		SC9->(A460Estorna(/*lMata410*/,lAtuEmp,@nVlrCred))

		// Remover caso necessario a bobina na quantidade a ser cancelada
		if  SC6->(Alltrim(C6_ACONDIC)) == 'B'
			nNovo	:= (len(aBobinas) - 1)
			if (nPos := AScan(aBobinas,{|aZe| aZe[1] == SZE->(Recno())  })) > 0
				Adel(aBobinas,nPos )
				ASize(aBobinas, nNovo)
			endIf
		endif
		// Tratativas cancelamento SZE/Status
		prcFimCEmEst(@oCtrl, @oStatus)

		RestArea(aAreaZE)
		RestArea(aAreaB2)
		Restarea(aAreaBF)
		RestArea(aAreaC9)
		RestArea(aAreaC6)
		RestArea(aAreaC5)
		// Inicia-se a liberação do novo cenario, primeiro incluindo o registro SC9 liberado, e array de Empenhos SDC
		if nPermLib > 0
			nTitLib += MaLibDoFat(SC6->(RecNo()),nPermLib,@lCredito,@lEstoque,.F.,.F.,lLiber,lTransf,NIL,NIL,aLocaliz,NIL,NIL,NIL,nPermLib)
			// Atualiza os registro ZZ9 com os novos empenhos (SDC) realizados
			if (nTitLib <> nPermLib)
				lRet := .F.
			else
				prcFimEmEst(@oCtrl,oStatus,aBobinas)
				aLocaliz := aEmpPed(cPed, cItm, oStatus, .T.)
			endif
		endif

		// Depois o registro que deve ficar bloqueado, sendo o que já estava bloqueado mais o que esta sendo cancelado
		if (nNewValue := (nQtdCanc + nAnteBlq) ) > 0
			nTotBlq := MaLibDoFat(SC6->(RecNo()),@nNewValue,.T.,.F.,.F.,.F.,.F.,.F.,,,,,,@nVlrCred,nNewValue)
			if (nTotBlq <> nNewValue)
				lRet := .F.
			endif
		endif
		RestArea(aAreaC6)
		RestArea(aAreaC5)
		SC5->(MaLiberOk({C5_NUM},.F.))
		RestArea(aAreaC6)
		RestArea(aAreaC5)

		oSql:close() 
		FreeObj(oSql)
	endif
return(lRet)


user function zCEmSC9(oCtrl, oStatus)
	local nVlrCred	:= 0
	local nQtdCanc	:= 0
	local nNewValue	:= 0
	local aAreaC5	:= {}
	local aAreaC6	:= {}
	local aAreaC9	:= {}
	local aAreaBF	:= {}
	local aAreaB2	:= {}
	local aAreaZE	:= {}
	local lAtuEmp	:= .T.
	local nTotBlq	:= 0
	local nAnteBlq	:= 0
	local aLocaliz	:= {}
	local cPed		:= ''
	local cItm		:= ''
	local aRecBlq	:= {}
	local nX		:= 0
	local lCredito	:= .T.
	local lEstoque	:= .T.
	local lLiber	:= .T.
	local lTransf	:= .F.
	local aBobinas	:= {}
	local lRet		:= .T.

	if validCEmEst(@nQtdCanc, @oCtrl)

		DbSelectArea('SC5')
		SC5->(DbSetOrder(1))
		SC5->(MsSeek(xFilial("SC5")+ SC9->(C9_PEDIDO)))
		// SC9 vem posicionado no registro que esta liberado
		aAreaC5 	:= SC5->(GetArea())
		aAreaC6	 	:= SC6->(GetArea())
		aAreaC9		:= SC9->(GetArea())
		aAreaBF 	:= SBF->(GetArea())
		aAreaB2		:= SB2->(GetArea())
		aAreaZE		:= SZE->(GetArea())
		cPed 		:= SC9->(C9_PEDIDO)
		cItm 		:= SC9->(C9_ITEM)

		// Obtem total do SC9 que esta bloqueado (que devera ser acrescentado o valor que estamos cancelando)
		nAnteBlq	:= getTotBlq(cPed,cItm) 
		// Obter os empenhos SDC realizados, já estornando o status na ZZ9
		aLocaliz 	:= aEmpPed(cPed,cItm,oStatus, .F.)
		// Obter as bobinas liberadas deste item
		if  SC6->(Alltrim(C6_ACONDIC)) == 'B'
			aBobinas 	:= aEmpBob(cPed, cItm, 'E')
		endif
		// Obter os registros SC9 bloqueados
		aRecBlq 	:= getTotBlq(cPed,cItm, .T.)
		// Inicia-se os estornos, primeiro os SC9 obtidos bloqueados
		for nX := 1 to len(aRecBlq)
			SC9->(DbGoTo(aRecBlq[nX]))
			u_zLEmpEnv(oCtrl, SC9->(Recno()),,.T.)
			oStatus:clrStatus('SC9', SC9->(Recno()))
			SC9->(A460Estorna(/*lMata410*/,lAtuEmp,@nVlrCred))
		next nX
		RestArea(aAreaZE)
		RestArea(aAreaB2)
		Restarea(aAreaBF)
		RestArea(aAreaC9)
		RestArea(aAreaC6)
		RestArea(aAreaC5)

		// Voltando a area original (posicionado no SC9 Liberado), vamos estorna-lo
		oStatus:clrStatus('SC9', SC9->(Recno()))
		SC9->(A460Estorna(/*lMata410*/,lAtuEmp,@nVlrCred))

		// Remover caso necessario todas as bobinas bobina, atualizando status no ZZ9
		if  SC6->(Alltrim(C6_ACONDIC)) == 'B'	
			for nX := 1 to len(aBobinas)
				SZE->(DbGoTo(aBobinas[nX,1]))
				prcFimCEmEst(@oCtrl, @oStatus)
			next nX
		endif

		RestArea(aAreaZE)
		RestArea(aAreaB2)
		Restarea(aAreaBF)
		RestArea(aAreaC9)
		RestArea(aAreaC6)
		RestArea(aAreaC5)

		// Depois o registro que deve ficar bloqueado, sendo o que já estava bloqueado mais o que esta sendo cancelado
		if (nNewValue := (nQtdCanc + nAnteBlq) ) > 0
			nTotBlq := MaLibDoFat(SC6->(RecNo()),@nNewValue,.T.,.F.,.F.,.F.,.F.,.F.,,,,,,@nVlrCred,nNewValue)
			if (nTotBlq <> nNewValue )
				lRet := .F.
			endif
		endif

		RestArea(aAreaC6)
		RestArea(aAreaC5)
		SC5->(MaLiberOk({C5_NUM},.F.))
		RestArea(aAreaC6)
		RestArea(aAreaC5)
	endif
return(lRet)


user function vLERpeSld(nRecSC5)
	local oSql 		:= nil
	local aArea		:= getArea()
	local aAreaC5	:= SC5->(getArea()) 
	local cQry		:= ''
	local cCor		:= ''
	local nSumDisp	:= 0
	local nSumNece	:= 0
	default nRecSC5	:= 0

	nTotal := seconds()
	if nRecSC5 > 0
		SC5->(DbGoTo(nRecSC5))
		// Verifica se tem Registro SC9 com bloqueio de estoque
		if nBlEsTotal(SC5->(C5_NUM)) == 0
			cCor := 'BR_AMARELO'
		else
			cQry := getResQry(SC5->(C5_NUM), '',.T.)
			oSql := LibSqlObj():newLibSqlObj()
			oSql:newAlias(cQry)
			// Query volta registros que não atende (tendo registro não atende)
			// Não tendo registro atende
			if oSql:hasRecords()
				cCor := 'BR_VERMELHO'
			else
				cCor := 'BR_VERDE'
			endif
			oSql:close()
			FreeObj(oSql)
		endif
	endif
	RestArea(aAreaC5)
	RestArea(aArea) 
return(cCor)


user function vLEResEst(oCbcLibEmp)
	local oGrid			:= nil
	local oModal		:= nil
	local oContainer	:= nil
	local aTFolder		:= {}
	local oTFolder		:= nil

	oModal  := FWDialogModal():New()        
	oModal:SetEscClose(.T.)
	oModal:setTitle("Visão de Estoque")
	oModal:setSize(270, 640)
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
	oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
	oContainer:SetCss("")
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT

	aTFolder := {'Quantidades', 'Valores' }
	oTFolder := TFolder():New( 0,0,aTFolder,,oContainer,,,,.T.,,, )
	oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
	shwGrid(oTFolder:aDialogs[1],  @oGrid, .T., @oCbcLibEmp)
	shwGraph(oTFolder:aDialogs[2],.T.)
	oModal:Activate()

	oCbcLibEmp:delTab()
	FreeObj(oModal)
	FreeObj(oContainer)
	FreeObj(oGrid)
	FreeObj(oTFolder)
return(nil)


user function vLEResPed(nRecC5, oCbcLibEmp)
	local oTFolder		:= nil
	local aTFolder		:= {}
	local oGrid			:= nil
	local oModal		:= nil
	local oContainer	:= nil

	default oCbcLibEmp	:= cbcLibEmp():newcbcLibEmp()
	DbSelectArea('SC5')
	SC5->(DbGoTo(nRecC5))

	oModal  := FWDialogModal():New() 
	oModal:SetEscClose(.T.)
	oModal:setTitle("Resumos")
	oModal:setSize(270, 640)
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
	oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
	oContainer:SetCss("")
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT
	aTFolder := {'Quantidades', 'Valores', 'Valor Disp.' }
	oTFolder := TFolder():New( 0,0,aTFolder,,oContainer,,,,.T.,,, )
	oTFolder:Align := CONTROL_ALIGN_ALLCLIENT
	shwGrid(oTFolder:aDialogs[1],  @oGrid, .F., oCbcLibEmp)
	shwGraph(oTFolder:aDialogs[2],.F.)
	shwGphDis(oTFolder:aDialogs[3]) 
	oModal:Activate()

	oCbcLibEmp:delTab()
	FreeObj(oTFolder)
	FreeObj(oGrid)
	FreeObj(oContainer)
	FreeObj(oModal)
return(nil)


user function zLECtrLk(cAls)
	local lRet	:= .T.	
	if cAls == 'SDC'
		lRet := ( MultLock("SDC",{ SDC->(DC_FILIAL + DC_PEDIDO)},1) .and.; 
		MultLock("SC5",{ SDC->(DC_FILIAL + DC_PEDIDO)},1) .and.;
		MultLock("SC6",{SDC->(DC_FILIAL + DC_PEDIDO + DC_ITEM + DC_PRODUTO)},1) .and.;
		MultLock("SC9",{SDC->(DC_FILIAL + DC_PEDIDO + DC_ITEM + DC_SEQ + DC_PRODUTO)},1) .and.;
		MultLock("SB1",{xFilial('SB1') + SDC->(DC_PRODUTO)},1) .and.;
		MultLock("SB2",{xFilial('SB2') + SDC->(DC_PRODUTO + DC_LOCAL)},1) .and.;
		MultLock("SBF",{xFilial('SBF') + SDC->(DC_LOCAL + DC_LOCALIZ + DC_PRODUTO)},1) .and.;
		MultLock("ZZ9",{'SC5' + cValToChar(SC5->(Recno())) },1)  .and.;
		MultLock("SZE",{SDC->(DC_FILIAL + DC_PEDIDO)},1) )

	elseif cAls == 'SC9'
		lRet := ( MultLock("SC9",{ SC9->(C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_SEQUEN)},1) .and.; 
		MultLock("SC5",{SC9->(C9_FILIAL + C9_PEDIDO)},1) .and.;
		MultLock("SC6",{SC9->(C9_FILIAL + C9_PEDIDO + C9_ITEM + C9_PRODUTO)},1) .and.;
		MultLock("SDC",{SC9->(C9_FILIAL + C9_PEDIDO)},1) .and.;
		MultLock("SB1",{xFilial('SB1') + SC9->(C9_PRODUTO)},1) .and.;
		MultLock("SB2",{xFilial('SB2') + SC9->(C9_PRODUTO + C9_LOCAL)},1) .and.;
		MultLock("SBF",{xFilial('SBF') + SC9->(C9_PRODUTO + C9_LOCAL)},2) .and.;
		MultLock("ZZ9",{'SC5' + cValToChar(SC5->(Recno())) },1)  .and.;
		MultLock("SZE",{SC9->(C9_FILIAL + C9_PEDIDO)},1) )
	endif 
return(lRet)


user function zLEmBEnv(oCtrl, nRecSZE)
	local cFl := FwFilial()
	local cLocaliz	:= ''
	local cTabEnt	:= ''
	local cPadEst	:= TamSx3('C9_BLEST')[1]

	dbSelectArea("SZE")
	SZE->(dbGoto(nRecSZE))
	if SZE->(Recno()) != nRecSZE
		// Utilizo para disparar user exception
		oCtrl:setStatus(.F., 'Registro SZE não encontrado', .T.)
	else
		existTab('SC5', 1, SZE->(ZE_PEDIDO), @oCtrl)
		existTab('SC6', 1, SZE->(ZE_PEDIDO + ZE_ITEM + ZE_PRODUTO), @oCtrl)
		existTab('SC9', 14, Space(TamSx3('C9_BLCRED')[1]) + PadR('02',cPadEst) + SZE->(ZE_PEDIDO + ZE_ITEM), @oCtrl)

		cLocaliz := Padr(SZE->('B' + StrZero(SZE->(ZE_QUANT),5)), TamSx3('BF_LOCALIZ')[1])
		if SC5->(C5_TIPO) $ "DB"
			cTabEnt := 'SA2'
		else
			cTabEnt := 'SA1'
		endIf
		existTab(cTabEnt, 1, SC5->(C5_CLIENTE + C5_LOJACLI), @oCtrl)
		existTab('SB1', 1, SZE->(ZE_PRODUTO),@oCtrl)
		existTab('SB2', 1, SC6->(C6_PRODUTO + C6_LOCAL), @oCtrl)
		existTab('SBF', 1, SC6->(C6_LOCAL) + cLocaliz + SZE->(ZE_PRODUTO), @oCtrl,,.F.)	
	endif 
return(nil)


user function vVlLibBob()
	local lRet	:= .T. 
	if ZE_CONDIC ==  "A"
		// "Bobina Adiantada"
		lRet := .F.
	endif
return(cValToChar(lRet))


user function zLVldPed(cAls, lOnlyPed, cAltAls, cOpc)
	local cFilter		:= ''	
	default lOnlyPed	:= .F. 
	default cOpc		:= '01'
	if cAls == 'SC5'
		cFilter := getFltrPe(cOpc)
	elseif cAls == 'SC9LIB'
		cFilter += "@"
		if empty((cAltAls)->(C9_PEDIDO))
			cFilter += "C9_FILIAL = '" + SC5->(C5_FILIAL) + "' "
			cFilter += "AND C9_BLCRED	= '" + Space(TamSx3('C9_BLCRED')[1]) + "' " 
			cFilter += "AND C9_BLEST 	= '" + Space(TamSx3('C9_BLEST')[1])  + "' "
			cFilter += "AND C9_PEDIDO = '" + SC5->(C5_NUM) + "' "
			cFilter += "AND C9_ITEM   	NOT IN ('" + Space(TamSx3('C9_ITEM')[1]) + "') "
		else
			cFilter += "C9_FILIAL = '" + (cAltAls)->(C9_FILIAL) + "' "
			cFilter += "AND C9_BLCRED	= '" + (cAltAls)->(C9_BLCRED) + "' " 
			cFilter += "AND C9_BLEST 	= '" + Space(TamSx3('C9_BLEST')[1])  + "' "
			cFilter += "AND C9_PEDIDO = '" + (cAltAls)->(C9_PEDIDO) + "' "
			cFilter += "AND C9_ITEM   	NOT IN ('" + Space(TamSx3('C9_ITEM')[1]) + "') "
		endif  
	elseif cAls == 'SC6SZE'
		if lOnlyPed
			cFilter := "SZE->(ZE_FILIAL == '" + xFilial("SZE") + "' .And. ZE_STATUS == 'P' "  + " .And. ZE_PEDIDO == '" + SC5->(C5_NUM) + "' )"
		endif
	endif
	/*
	// TODO Realizar as validações de pedidos 
	// Liberação usada para pedidos tipo B = Beneficiamento (JU)
	// SC5->C5_DTPCP == Date() .Or. SC5->C5_DTVEN == Date() .F.
	// SC5->C5_ZSTATUS $ "29" .F.
	*/
return(cFilter)


user function zLTotBlq(cPed, lOnlyRec)
	local aRet			:= {}
	default lOnlyRec	:= .T.
	aRet := getTotBlq(cPed, ,lOnlyRec)
return(aRet)


user function zLBobPed(cPed, oSelf)
	local aRet := getBobPed(cPed, oSelf) 
return(aRet)


user function zLOutPed(cPed)
	local aRet := getOutPed(cPed) 
return(aRet)


user function zLBobCnt(cPed, cItm)
	local nTotal := cntBobPed(cPed, cItm)
return(nTotal)


user function zLBornOs(aRecC9, lNew)
	local aWhreDC	:= {}
	local aWhreZE	:= {}
	local aRelac	:= {}
	local oStatus 	:= cbcCtrStatus():newcbcCtrStatus()
	local cNumOs	:= '' 
	local aArea		:= GetArea()
	local aAreaC9	:= SC9->(GetArea())
	local aAreaZ9	:= ZZ9->(GetArea())
	local lRet		:= .T.
	local nX		:= 0
	local aFldVlr	:= {}
	default lNew	:= .T.

	if lNew
		DbSelectArea('ZZ9')
		//ZZ9->(DbSetOrder(10))
		ZZ9->(DBOrderNickName('ZZ9OS'))
		cNumOs	:= GetSXENum("ZZ9","ZZ9_NROS")
		While ZZ9->(DbSeek(xFilial("ZZ9")+ cNumOs ,.F.))
			cNumOs := GetSXENum("ZZ9","ZZ9_NROS")
		EndDo
		aadd(aFldVlr, {'ZZ9_NROS'	, cNumOs})
		aadd(aFldVlr, {'ZZ9_STATUS'	, SEPARANDO})
	else
		aadd(aFldVlr, {'ZZ9_NROS'	, ''})
		aadd(aFldVlr, {'ZZ9_STATUS'	, LIBERADO_SEPARACAO})
	endif

	for nX := 1 to len(aRecC9)
		aWhreDC	:= {}
		aWhreZE	:= {}
		aRelac  := {}
		DbSelectArea('SC9')
		SC9->(DbGoTo(aRecC9[nX]))

		aadd(aWhreDC,	{'DC_FILIAL' 	, 'C9_FILIAL'} )
		aadd(aWhreDC,	{'DC_PEDIDO' 	, 'C9_PEDIDO'} )
		aadd(aWhreDC, 	{'DC_ITEM' 		, 'C9_ITEM'})
		aadd(aWhreDC, 	{'DC_SEQ' 		, 'C9_SEQUEN'})
		aadd(aWhreDC, 	{'DC_PRODUTO' 	, 'C9_PRODUTO'})
		aadd(aRelac,{'DETAIL', 'SDC', aWhreDC})

		aadd(aWhreZE,	{'ZE_FILIAL' 	, 'C9_FILIAL'} )
		aadd(aWhreZE,	{'ZE_PEDIDO' 	, 'C9_PEDIDO'} )
		aadd(aWhreZE, 	{'ZE_ITEM' 		, 'C9_ITEM'})
		aadd(aWhreZE, 	{'ZE_SEQUEN' 	, 'C9_SEQUEN'})
		aadd(aRelac,{'DETAIL', 'SZE', aWhreZE})

		lRet := oStatus:groupRec(aFldVlr, 'DETAIL', 'SC9', SC9->(Recno()), aRelac)
	next nX

	FreeObj(oStatus)
	RestArea(aAreaZ9)
	RestArea(aAreaC9)
	RestArea(aArea)
return({lRet, cNumOs})


user function zLUpdSay(oSay, cText)
	default oSay	:= nil
	if !empty(oSay)
		oSay:settext(cText)
		oSay:ctrlrefresh()
	endif
return(nil)


user function zLVirEst(oHash)
	local oSql		:= nil
	local cProd		:= ''
	local nSaldo	:= 0 
	local xValue	:= nil
	default oHash	:= nil
	if !empty(oHash)
		HMClean(oHash)
		oSql := LibSqlObj():newLibSqlObj()
		oSql:newAlias(u_cbcQRYBFEst())// getResQry() Criar HASH de SB2 ##JEITO NOVO
		if oSql:hasRecords()
			oSql:goTop()
			while oSql:notIsEof()
				cProd 	:= ( oSql:getValue("Alltrim(Produto)") + oSql:getValue("Alltrim(Acond)") )
				nSaldo 	:= oSql:getValue("Disponivel")
				if  ! HMGet( oHash , cProd , @xValue )
					HMAdd(oHash,{cProd,nSaldo})
				endif
				oSql:skip()
			endDo
		endif	
		oSql:close()
		FreeObj(oSql)
	endif
return(nil)


user function zLVirEmp(oHash, cProd, nQtd)
	local aSld		:= {}
	local nSld		:= 0
	local nQtdAtend := 0
	default oHash	:= nil
	if !empty(oHash)
		if HMGet( oHash, cProd, @aSld )
			if empty(aSld)
				nQtdAtend := 0
			else
				if empty(aSld[1,2])
					nQtdAtend := 0
				else
					if ( (nSld := (aSld[1,2] - nQtd)) >= 0 )
						if( HMSet(oHash, cProd, {{cProd, nSld}} ) )
							nQtdAtend := nQtd
						endif
					else
						if (HMSet(oHash, cProd, {{cProd, 0}} ))
							nQtdAtend := aSld[1,2]
						endif
					endif
				endif
			endif
		else
			nQtdAtend := 0
		endif
	endif
return(nQtdAtend)


user function zLVirSld(oHash, cProd)
	local aSld	:= {0}
	default oHash	:= nil
	if !empty(oHash)
		HMGet( oHash, cProd, @aSld )
	endif
return(aSld[1])


static function getFltrPe(cOpc)
	local cFiltro	:= ''
	default cOpc	:= '01'

	if cOpc == '01'
		cFiltro += "@"
		cFiltro += "C5_FILIAL = '" + xFilial('SC5') + "' "
		cFiltro += " AND C5_LIBEROK = 'S' " 
		cFiltro += " AND C5_NOTA = '' " 
		cFiltro += " AND C5_TIPO = 'N' "
	elseif cOpc == '02'
		cFiltro += " SELECT "
		cFiltro += " SC5.R_E_C_N_O_  AS [RECNO]"
		cFiltro += " FROM "+ retSqlName('SC5') + " SC5 "
		/*
		cFiltro += " INNER JOIN " +  retSqlName('SA1') + " SA1 WITH (NOLOCK) "
		cFiltro += " ON ''				= SA1.A1_FILIAL "
		cFiltro += " AND SC5.C5_CLIENTE	= SA1.A1_COD "
		cFiltro += " AND SC5.C5_LOJACLI	= SA1.A1_LOJA "
		cFiltro += " AND SC5.D_E_L_E_T_	= SA1.D_E_L_E_T_ "
		*/
		cFiltro += " WHERE "
		cFiltro += " SC5.C5_FILIAL + SC5.C5_NUM  IN ( "
		cFiltro += "  SELECT " 
		cFiltro += " 	DISTINCT SC5.C5_FILIAL + SC9.C9_PEDIDO AS [CHAVE] "
		cFiltro += " FROM " + RetSqlName('SC9') + " SC9 "
		cFiltro += " INNER JOIN " +  RetSqlName('SC6') + " SC6  WITH (NOLOCK) " 
		cFiltro += " ON SC9.C9_FILIAL	= SC6.C6_FILIAL "
		cFiltro += " AND SC9.C9_PEDIDO	= SC6.C6_NUM "
		cFiltro += " AND SC9.C9_ITEM		= SC6.C6_ITEM " 
		cFiltro += " AND SC9.C9_PRODUTO	= SC6.C6_PRODUTO  "
		cFiltro += " AND SC6.R_E_C_N_O_	= SC6.R_E_C_N_O_  "
		cFiltro += " AND SC9.D_E_L_E_T_	= SC6.D_E_L_E_T_  "
		cFiltro += " INNER JOIN " + RetSqlName('SC5') + " SC5 WITH (NOLOCK) " 
		cFiltro += " ON  SC6.C6_FILIAL	= SC5.C5_FILIAL " 
		cFiltro += " AND SC6.C6_NUM		= SC5.C5_NUM " 
		cFiltro += " AND SC5.R_E_C_N_O_	= SC5.R_E_C_N_O_ " 
		cFiltro += " AND SC6.D_E_L_E_T_	= SC5.D_E_L_E_T_ " 
		cFiltro += " INNER JOIN " + RetSqlName('SB1') + " SB1 WITH (NOLOCK) " 
		cFiltro += " ON ''				= SB1.B1_FILIAL "
		cFiltro += " AND SC9.C9_PRODUTO	= SB1.B1_COD "
		cFiltro += " AND SC9.D_E_L_E_T_	= SB1.D_E_L_E_T_ "
		cFiltro += " INNER JOIN " + RetSqlName('SF4') + " SF4 WITH (NOLOCK) "
		cFiltro += " ON ''				= SF4.F4_FILIAL "
		cFiltro += " AND SC6.C6_TES		= SF4.F4_CODIGO "
		cFiltro += " AND SC6.D_E_L_E_T_	= SF4.D_E_L_E_T_ "
		cFiltro += " WHERE " 
		cFiltro += " SC9.C9_FILIAL IN ('" + xFilial('SC9') + "') " 
		cFiltro += " AND SC9.C9_PEDIDO NOT IN(' ') " 
		cFiltro += " AND SC9.C9_BLCRED IN (' ') " 
		cFiltro += " AND SC9.C9_BLEST  IN ('02') " 
		cFiltro += " AND SC9.C9_SERIENF NOT IN ('U') " 
		cFiltro += " AND SC5.C5_LIBEROK = 'S' "
		cFiltro += " AND C5_NOTA = '' "
		cFiltro += " AND C5_TIPO = 'N' "
		cFiltro += " AND SC6.C6_BLQ <> 'R' "
		cFiltro += " AND SF4.F4_ESTOQUE = 'S' "
		cFiltro += " AND SB1.B1_TIPO = 'PA' "
		cFiltro += " AND SC9.D_E_L_E_T_ = '' "
		cFiltro += " ) " 
		// cFiltro += " ORDER BY SC5.C5_FILIAL, SA1.A1_NOME, SC5.C5_CLIENTE, SC5.C5_LOJACLI "
	endif
return(cFiltro)


static function secureSBF()
	local lRet	:= .T.
	local lLocaliz	:= (SB1->(B1_LOCALIZ) == 'S')
	local cSBFLoc	:= ''

	if lLocaliz
		if !empty(cSBFLoc	:= alltrim(SBF->(BF_LOCALIZ)))
			lRet := ( Mod( SBF->(BF_QUANT - BF_EMPENHO), val(Right(cSBFLoc,Len(cSBFLoc)-1))) == 0 )
		else
			lRet := .F.
		endif
	endif
return(lRet)


static function validEmEst(nQtdLib, oCtrl, nDifLib)
	local lRet		:= .T.
	local aInfo		:= {}
	local nDifer	:= 0
	local nPerDes	:= 0
	local nMetrag	:= 0

	if !secureSBF()
		oCtrl:setNotif('Validação', 'Saldo SBF não pode ser distribuido na metragem ')
		oCtrl:setNotif('LibBobinas', 'Saldo SBF não pode ser distribuido na metragem ',;
		{{'Pedido+Item+Recno', SC6->(C6_NUM + C6_ITEM) + cValToChar(SBF->(Recno()))}}, .F. )
		lRet	:= .F.
	else
		if SC6->(Alltrim(C6_ACONDIC)) == 'B'
			nMetrag := SC6->(C6_METRAGE)
			if nMetrag <> nQtdLib 
				if oCtrl:nPercDes <> 0
					nDifer 	:= (nQtdLib - nMetrag)
					nPerDes := ( (nDifer/nMetrag) * 100 ) 
					if (nPerDes >= oCtrl:nPercDes)
						oCtrl:setNotif('Validação', 'Percentual de desvio ' + cValToChar(nPerDes) +;
						' diferente do percentual tolerado de desvio! ' +  cValToChar(oCtrl:nPercDes))
						oCtrl:setNotif('LibBobinas','Liberação diferente percentual tolerado de desvio!',;
						{{'Pedido+Item+QuantidadeBobina+Perc.Tolerado+MetragemPedido',;
						SC5->(C5_NUM) + ' - ' + SC6->(C6_ITEM) + ' - ' +;
						cValToChar(nQtdLib) + ' - ' + cValToChar(oCtrl:nPercDes) + ' - ' +;
						cValToChar(nMetrag)}},.F.,,.T.)
						lRet := .F.
					else
						oCtrl:setNotif('LibBobinas','Liberação realizada percentual tolerado de desvio!',;
						{{'Pedido+Item+QuantidadeBobina+Perc.Tolerado+MetragemPedido',;
						SC5->(C5_NUM) + ' - ' + SC6->(C6_ITEM) + ' - ' +;
						cValToChar(nQtdLib) + ' - ' + cValToChar(oCtrl:nPercDes) + ' - ' +;
						cValToChar(nMetrag)}},.F.,,.T.)
						nDifLib :=  (nQtdLib - nMetrag)
						lRet := .T.
					endif
				else
					aadd(aInfo, {'FILIAL', 			SC5->(C5_FILIAL)} )
					aadd(aInfo, {'PEDIDO', 			SC5->(C5_NUM)} )
					aadd(aInfo, {'ITEM', 			SC6->(C6_NUM)} )
					aadd(aInfo, {'PRODUTO', 		SC6->(C6_PRODUTO)} )
					aadd(aInfo, {'METRAGEM.VEND', 	cValToChar(nMetrag)} )
					aadd(aInfo, {'METRAGEM.LIB',  	cValToChar(nQtdLib)} )
					aadd(aInfo, {'USUARIO',  		Alltrim(RetCodUsr()) } )
					aadd(aInfo, {'IDSECAO',  		oCtrl:getId()})
					aadd(aInfo, {'DATA',  			Dtos(Date())})
					aadd(aInfo, {'HORA',  			StrTran(time(), ":", "")})
					if MsgNoYes('Pedido ' + SC6->(C6_NUM) +;
					' Item ' + SC6->(C6_ITEM) +;
					' Produto ' + SC6->(C6_PRODUTO) +;
					' Metragem de lance vendido ' + cValToChar(nMetrag) +;
					' Metragem de lance a ser liberado ' + cValToChar(nQtdLib) ,;
					'Confirmar liberação Lances Irregulares?')
						oCtrl:setNotif('LibBobinas', 'Liberado Lance Irregular', aInfo, .F. )
						nDifLib :=  (nQtdLib - nMetrag)
						lRet := .T.
					else
						oCtrl:setNotif('LibBobinas', 'Cancelado liberação Lance Irregular', aInfo, .F. )
						lRet := .F.
					endif
				endif
			endif
		endif
	endif
return(lRet)


static function prcFimEmEst(oCtrl, oStatus, aBobinas)
	local lRet			:= .F.
	local aErro			:= {}
	local aUpd			:= {}
	local nX			:= 0
	default aBobinas	:= {}

	oStatus:setStatus('SC9', SC9->(Recno()), EMPENHADO)

	if !empty(aBobinas)
		for nX := 1 to len(aBobinas)
			aUpd := {}
			SZE->(DbGoTo(aBobinas[nX,1]))
			oStatus:setStatus('SZE', SZE->(Recno()), EMPENHADO)
			aadd( aUpd, {'ZE_STATUS', 	EMPENHADO} )
			aadd( aUpd, {'ZE_MOTIVO',	''} )
			aadd( aUpd, {'ZE_SEQUEN',	SC9->(C9_SEQUEN)} )
			aadd( aUpd, {'ZE_DTLIB',	Date()} )
			aadd( aUpd, {'ZE_HRLIB', 	Left(Time(),Len(SZE->(ZE_HRLIB)))} )
			if !(lRet := updSZE(aUpd, @aErro))
				oCtrl:setNotif('Falha atualização Bobina', 'Empenho SZE', aErro, .F. )
			endif
		next nX
	else
		if  SC6->(Alltrim(C6_ACONDIC)) == 'B'
			oStatus:setStatus('SZE', SZE->(Recno()), EMPENHADO)
			aadd( aUpd, {'ZE_STATUS', 	EMPENHADO} )
			aadd( aUpd, {'ZE_MOTIVO',	''} )
			aadd( aUpd, {'ZE_SEQUEN',	SC9->(C9_SEQUEN)} )
			aadd( aUpd, {'ZE_DTLIB',	Date()} )
			aadd( aUpd, {'ZE_HRLIB', 	Left(Time(),Len(SZE->(ZE_HRLIB)))} )
			if !(lRet := updSZE(aUpd, @aErro))
				oCtrl:setNotif('Falha atualização Bobina', 'Empenho SZE', aErro, .F. )
			endif
		endif
	endif

return(lRet)


static function  prcFimCEmEst(oCtrl, oStatus)
	local lRet		:= .F.
	local aUpd		:= {}
	local aErro		:= {}
	if  SC6->(Alltrim(C6_ACONDIC)) == 'B'
		oStatus:clrStatus('SZE', SZE->(Recno()))
		aadd( aUpd, {'ZE_STATUS', 	'P'} )
		aadd( aUpd, {'ZE_MOTIVO',	'CANCELADO EMPENHO'} )
		aadd( aUpd, {'ZE_SEQUEN',	''} )
		aadd( aUpd, {'ZE_DTLIB',	Date()} )
		aadd( aUpd, {'ZE_HRLIB', 	Left(Time(),Len(SZE->(ZE_HRLIB)))} )
		if !(lRet := updSZE(aUpd, @aErro))
			oCtrl:setNotif('Falha atualização Bobina', 'Cancelamento de Empenho SZE', aErro, .F. )
		endif	
	endif
return(lRet)


static function updSZE(aFldVlr, aErro)
	local oSZEModel := nil
	local cIDModel	:= 'SZEMASTER'
	local lRet		:= .T.
	local nX		:= 0
	default aFldVlr	:= {}

	if !empty(aFldVlr)
		oSZEModel := FWLoadModel('cbcSZEModel')
		oSZEModel:SetOperation(MODEL_OPERATION_UPDATE)
		oSZEModel:Activate()
		for nX := 1 to len(aFldVlr)
			oSZEModel:SetValue(cIDModel,aFldVlr[nX,1],aFldVlr[nX,2])
		next nX
		if ! (lRet := oSZEModel:VldData())
			aErro := oSZEModel:GetErrorMessage()
		else
			FWFormCommit(oSZEModel)
		endIf	
		oSZEModel:DeActivate()
		FreeObj(oSZEModel)
	endif
return(lRet)


static function validCEmEst(nQtdLib, oCtrl)
	local lRet	:= .T.
	if  SC6->(Alltrim(C6_ACONDIC)) == 'B'
		if SC6->(C6_METRAGE) <> SC9->(C9_QTDLIB)
			nQtdLib := SC6->(C6_METRAGE) 
		else
			nQtdLib := SC9->(C9_QTDLIB)
		endif
	else
		nQtdLib := SC9->(C9_QTDLIB)
	endif
return(lRet)


static function shwGphDis(oDlg)
	local aRand			:= {}
	local oChart		:= nil
	local cPed			:= ''
	local nVlrTem		:= 0
	local nVlrFalta		:= 0
	local cPic			:= "@E 999,999,999,999.99"

	oChart := FWChartBar():New()
	oChart:init( oDlg, .T. )
	cPed := SC5->(C5_NUM)

	getHvNoHv(cPed, @nVlrTem,@nVlrFalta )

	oChart:setTitle("Vendido " + Transform(getTotPed(cPed),PesqPict('SC5', 'C5_TOTAL')) +;
	" Valor Disp. Estoque: " + Transform(nVlrTem,PesqPict('SC5', 'C5_TOTAL')) , CONTROL_ALIGN_LEFT)

	oChart:addSerie( "Disponivel", 	nVlrTem ) 
	oChart:addSerie( "Falta Est. ",	nVlrFalta )

	oChart:setLegend( CONTROL_ALIGN_LEFT ) 

	aAdd(aRand, {"171,225,108", "017,019,010"})
	aAdd(aRand, {"207,136,077", "020,020,006"})

	oChart:oFWChartColor:aRandom := aRand
	oChart:oFWChartColor:SetColor("Random")

	oChart:setMask("R$ *@*")
	oChart:setPicture(cPic) 
	oChart:Build()
return(nil)



static function shwGraph(oDlg, lAll)
	local aRand			:= {}
	local oChart		:= nil
	local cPed			:= ''
	local nBlCr			:= 0
	local nBlEs			:= 0
	local nEmpTo		:= 0
	local cPic			:= "@E 999,999,999,999.99"
	default lAll		:= .F.

	oChart := FWChartBar():New()
	oChart:init( oDlg, .T. )

	if lAll
		cPed := ''
	else
		oChart:setTitle("Vendido " + Transform(getTotPed(SC5->(C5_NUM)),PesqPict('SC5', 'C5_TOTAL')), CONTROL_ALIGN_LEFT)
		cPed := SC5->(C5_NUM)
	endif

	oChart:addSerie( "Credito", 		(nBlCr := nBlCrTotal(cPed)) ) 
	oChart:addSerie( "Blq Estoque ",	(nBlEs := nBlEsTotal(cPed)) )
	oChart:addSerie( "Empenhado", 		(nEmpTo := nEmpTotal(cPed)) ) 

	if lAll
		oChart:setTitle(;
		'Crédito: '    + Alltrim(Transform(nBlCr,cPic)) +;
		' Blq.Est: '   + Alltrim(Transform(nBlEs,cPic)) +;
		' Empenhado: ' + Alltrim(Transform(nEmpTo,cPic)), CONTROL_ALIGN_LEFT)
	else	
		oChart:addSerie( "Faturado",		nFatTotal(cPed)) 
	endif

	oChart:setLegend( CONTROL_ALIGN_LEFT ) 

	aAdd(aRand, {"171,225,108", "017,019,010"})
	aAdd(aRand, {"207,136,077", "020,020,006"})
	aAdd(aRand, {"166,085,082", "017,007,007"})
	if !lAll
		aAdd(aRand, {"130,130,130", "008,008,008"})
	endif
	oChart:oFWChartColor:aRandom := aRand
	oChart:oFWChartColor:SetColor("Random")

	oChart:setMask("R$ *@*")
	oChart:setPicture(cPic) 
	oChart:Build()
return(nil)


static function shwGrid(oDlg, oGrid, lAll, oCbcLibEmp)
	local aSqlFlds		:= {}
	local aBrwFlds		:= {}
	local aEmpFlds		:= {}
	local aIndex		:= {}
	local aSeek			:= {}
	local cQry			:= ''
	local aC9Prod		:= TamSX3('C9_PRODUTO')
	local aC6Lance		:= TamSX3('C6_LANCES')
	local aNumber		:= TamSX3('BF_QUANT')
	local cPicNumber	:= PesqPict('SBF', 'BF_QUANT')
	local cPicProduto	:= PesqPict('SC9', 'C9_PRODUTO')
	local cTmp			:= ''
	local oPnlEst		:= nil
	local oBrwEst		:= nil
	local oBrwEmp		:= nil
	local oBrwBlq		:= nil
	local oFWLayer		:= nil
	local oPanelLU		:= nil
	local oPanelLD		:= nil
	local oRelBrw		:= nil
	local nTamLocali	:= TamSx3('DC_LOCALIZ')[1]

	default oGrid		:= nil
	default lAll		:= .F.	
	// aadd(aFields,{"DESCR","C",30,0})
	aIndex := {'Produto', 'Acond'}
	aAdd(aSeek,{"Produto+Acond" ,{;
	{"",aC9Prod[TIPO],aC6Lance[TAMANHO],aC9Prod[DECIMAL],"Produto",,cPicProduto},;
	{"",'C',nTamLocali,0,"Acond",,''}},1})

	aadd(aSqlFlds,{'Produto', 		aC9Prod[TIPO], aC9Prod[TAMANHO], aC9Prod[DECIMAL]} )
	aadd(aSqlFlds,{'Acond', 		'C', nTamLocali, 0})
	aadd(aSqlFlds,{'Lances',		aC6Lance[TIPO], aC6Lance[TAMANHO], 	aC6Lance[DECIMAL]})
	aadd(aSqlFlds,{'Vendido',		aNumber[TIPO], aNumber[TAMANHO], 	aNumber[DECIMAL] })
	aadd(aSqlFlds,{'Entregue',		aNumber[TIPO], aNumber[TAMANHO], 	aNumber[DECIMAL]})
	aadd(aSqlFlds,{'Necess',		aNumber[TIPO], aNumber[TAMANHO], 	aNumber[DECIMAL]})
	aadd(aSqlFlds,{'Disponivel',	aNumber[TIPO], aNumber[TAMANHO], 	aNumber[DECIMAL]})
	if lAll
		cQry := getResQry()
	else
		cQry :=  getResQry(SC5->(C5_NUM), '', .F.)
	endif
	oCbcLibEmp:prepEmp (aIndex, aSqlFlds, cQry)
	cTmp := oCbcLibEmp:getTmpAls()

	aadd(aBrwFlds, {'Produto', 		'Produto', 		aC9Prod[TIPO], aC9Prod[TAMANHO], aC9Prod[DECIMAL], cPicProduto} )
	aadd(aBrwFlds, {'Acond',   		'Acond', 		'C', nTamLocali, 0, ''} )
	aadd(aBrwFlds, {'Lances', 		'Lances', 		aC6Lance[TIPO], aC6Lance[TAMANHO], aC6Lance[DECIMAL], PesqPict('SC6', 'C6_LANCES')} )
	aadd(aBrwFlds, {'Vendido', 		'Vendido', 		aNumber[TIPO], 	aNumber[TAMANHO], aNumber[DECIMAL], cPicNumber} )
	aadd(aBrwFlds, {'Entregue', 	'Entregue', 	aNumber[TIPO], 	aNumber[TAMANHO], aNumber[DECIMAL], cPicNumber} )
	aadd(aBrwFlds, {'Necessidade', 	'Necess', 		aNumber[TIPO], 	aNumber[TAMANHO], aNumber[DECIMAL], cPicNumber} )
	aadd(aBrwFlds, {'Disponivel', 	'Disponivel', 	aNumber[TIPO], 	aNumber[TAMANHO], aNumber[DECIMAL], cPicNumber} )

	oFWLayer := FWLayer():New()
	oFWLayer:Init( oDlg, .F., .T. )

	// Painel principal com informações de produtos
	oFWLayer:AddCollumn('COL_RIGHT', 50, .F.)
	oFWLayer:AddWindow('COL_RIGHT', 'WND_BROWSEUP', '', 100, .T., .F.)
	oPnlEst := oFWLayer:GetWinPanel('COL_RIGHT', 'WND_BROWSEUP')
	oBrwEst:= FWMBrowse():New()
	oBrwEst:SetOwner(oPnlEst)
	oBrwEst:SetDescription('Resumo Estoque')
	oBrwEst:SetSeek(.T.,aSeek)
	oBrwEst:DisableDetails()
	oBrwEst:SetMenuDef('')
	oBrwEst:SetAlias(cTmp)
	oBrwEst:SetFields(aBrwFlds)
	oBrwEst:SetTemporary(.T.)
	oBrwEst:SetProfileID('idBrwRes')
	oBrwEst:ForceQuitButton(.T.)
	oBrwEst:SetUseFilter(.T.)
	oBrwEst:Activate()

	// Painel com os dados dos produtos empenhado
	oFWLayer:AddCollumn('COL_LEFT', 50, .F.)
	oFWLayer:SetColSplit('COL_LEFT', CONTROL_ALIGN_LEFT)
	oFWLayer:AddWindow('COL_LEFT', 'WND_OPCSUP', 'Pedidos', 100, .T., .F.)
	oPanelLU := oFWLayer:GetWinPanel('COL_LEFT', 'WND_OPCSUP')
	oBrwEmp:= FWMBrowse():New()
	oBrwEmp:SetOwner(oPanelLU)
	oBrwEmp:SetDescription('Empenho')
	oBrwEmp:SetMenuDef('')
	oBrwEmp:DisableDetails()
	oBrwEmp:SetAlias('SDC')	
	oBrwEmp:SetFields(aEmpFlds)
	oBrwEmp:SetTemporary(.F.)
	oBrwEmp:SetProfileID('idBrwEmp')
	oBrwEmp:ForceQuitButton(.T.)
	oBrwEmp:Activate()
	oRelBrw := FWBrwRelation():New()
	oRelBrw:AddRelation(oBrwEst , oBrwEmp, {;
	{'SDC->(DC_PRODUTO)', cTmp + '->(Produto)' },;
	{'SDC->(DC_LOCALIZ)', cTmp + '->(Acond)' } } )
	oRelBrw:Activate()

return(nil)


static function sldItmPed(oMainCtrl)
	local nSaldo 	:= 0
	local nSldEST	:= 0
	local nQtdLib 	:= 0
	local nQtdMrk	:= 0
	local lLocaliz	:= ( SB1->(B1_LOCALIZ) == 'S' )
	default oMainCtrl := nil

	nQtdLib			:= getTotLib(SC9->(C9_PEDIDO), SC9->(C9_ITEM))
	if !Empty(oMainCtrl)
		nQtdMrk		:= getTotMark(oMainCtrl)
	endif

	if lLocaliz
		nSldEST := SBF->(BF_QUANT - BF_EMPENHO) - nQtdMrk
	else
		nSldEST := SB2->(B2_QATU - B2_QEMP ) - nQtdMrk
	endif

	nSaldo 				:= SC6->(C6_QTDVEN - nQtdLib ) 
	if nSaldo > nSldEST
		oMainCtrl:setNotif('LogEmp','Saldo pedido maior que estoque, liberando somente estoque',{{'Filial+Pedido+Item+Venda+Estoque',;
		Alltrim(SC6->(C6_FILIAL + '-' + C6_NUM + '-' + C6_ITEM + '-' + cValtoChar(nSaldo)) + '-' + cValToChar(nSldEST))}},.F.,,.T.)
		nSaldo := nSldEST
	endif
	if ! vldQtd(nSaldo, oMainCtrl, nQtdLib)
		nSaldo := 0
	endif
	oMainCtrl:setNotif('LogEmp','Para pedido item foi atribuido quantidade de liberação de ',{{'Filial+Pedido+Item+Liber',;
	Alltrim(SC6->(C6_FILIAL + '-' + C6_NUM + '-' + C6_ITEM + '-' + cValtoChar(nSaldo)))}},.F.,,.T.)
return(nSaldo)


static function vldQtd(nQtdLiber, oMainCtrl, nQtdLib)
	local lRet		:=  .T. 
	local lLocaliz	:= ( SB1->(B1_LOCALIZ) == 'S' )
	default nQtdLib	:= 0

	if empty(nQtdLib)
		nQtdLib		:= getTotLib(SC9->(C9_PEDIDO), SC9->(C9_ITEM))
	endif

	if lLocaliz
		if SC6->(Alltrim(C6_ACONDIC)) <> 'B'
			if Mod(nQtdLiber, SC6->(C6_METRAGE)) <> 0
				lRet := .F.
			elseif nQtdLiber > SC6->(C6_QTDVEN - nQtdLib )
				lRet := .F.
			endif
		endif
	endif

	if !lRet
		oMainCtrl:setNotif('LogEmp','Quantidade não compativel com lance vendido',{{'Filial+Pedido+Item+Metragem+QtdLib',;
		Alltrim(SC6->(C6_FILIAL + '-' + C6_NUM + '-' + C6_ITEM + '-' + cValtoChar(C6_METRAGE)) + '-' + cValToChar(nQtdLiber))}},.F.,,.T.)	
		oMainCtrl:setNotif('Validação', 'Quantidade não compativel com lance vendido!!')
	endif
return(lRet)


static function nFatTotal(cPedido) 
	local oSql 		:= nil 
	local cQry		:= ''
	local nTot		:= 0
	default cPedido	:= ''
	cQry += " SELECT  "
	cQry += " ISNULL(SUM(SC9.C9_QTDLIB * SC6.C6_PRCVEN), 0) AS [TOTAL] "
	cQry += " FROM  %SC9.SQLNAME%  WITH (NOLOCK) "
	cQry += " INNER JOIN  %SC6.SQLNAME%   WITH (NOLOCK) "
	cQry += " ON SC9.C9_FILIAL 	= SC6.C6_FILIAL "
	cQry += " AND SC9.C9_PEDIDO = SC6.C6_NUM "
	cQry += " AND SC9.C9_ITEM 	= SC6.C6_ITEM "
	cQry += " WHERE %SC9.XFILIAL% "

	if empty(cPedido)
		cQry += " AND SC9.C9_PEDIDO NOT IN (' ')"
	else
		cQry += " AND SC9.C9_PEDIDO = '" + cPedido + "' "
	endif

	cQry += " AND SC9.C9_BLEST = '10' "
	cQry += " AND SC9.C9_SERIENF <> 'U' "
	cQry += " AND %SC9.NOTDEL% "
	cQry += " AND %SC6.NOTDEL% "
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		nTot := oSql:getValue("TOTAL")
	endif	
	oSql:close()
	FreeObj(oSql)
return(nTot)


static function nBlCrTotal(cPedido) 
	local oSql 		:= nil 
	local cQry		:= ''
	local nTotLib	:= 0
	default cPedido	:= ''

	cQry += " SELECT  "
	cQry += " ISNULL(SUM(SC9.C9_QTDLIB * SC6.C6_PRCVEN), 0) AS [TOTAL] "
	cQry += " FROM  %SC9.SQLNAME%  WITH (NOLOCK) "
	cQry += " INNER JOIN  %SC6.SQLNAME%  WITH (NOLOCK) "
	cQry += " ON SC9.C9_FILIAL 	= SC6.C6_FILIAL "
	cQry += " AND SC9.C9_PEDIDO = SC6.C6_NUM "
	cQry += " AND SC9.C9_ITEM 	= SC6.C6_ITEM "
	cQry += " WHERE %SC9.XFILIAL% "

	if empty(cPedido)
		cQry += " AND SC9.C9_PEDIDO NOT IN (' ')"
	else
		cQry += " AND SC9.C9_PEDIDO = '" + cPedido + "' "
	endif

	cQry += " AND SC9.C9_BLCRED NOT IN (' ', '10' ) "
	cQry += " AND SC9.C9_SERIENF <> 'U' "
	cQry += " AND %SC9.NOTDEL% "
	cQry += " AND %SC6.NOTDEL% "
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		nTotLib := oSql:getValue("TOTAL")
	endif	
	oSql:close()
	FreeObj(oSql)
return(nTotLib)


static function getTotPed(cPed) 
	local oSql 		:= nil 
	local cQry		:= ''
	local nTotLib	:= 0
	cQry += " SELECT  "
	cQry += " ISNULL(SUM(C6_QTDVEN * C6_PRCVEN), 0) AS [TOTAL] "
	cQry += " FROM  %SC6.SQLNAME%  WITH (NOLOCK) "
	cQry += " WHERE %SC6.XFILIAL% "
	cQry += " AND C6_NUM = '" + cPed + "' "
	cQry += " AND %SC6.NOTDEL% "
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		nTotLib := oSql:getValue("TOTAL")
	endif	
	oSql:close()
	FreeObj(oSql)
return(nTotLib)


static function getBobPed(cPed, oSelf) 
	local oSql 		:= nil 
	local cQry		:= ''
	local aRec		:= {}
	cQry += " SELECT  "
	cQry += " SZE.R_E_C_N_O_ AS [REC], "
	cQry += " SC6.C6_ACONDIC AS [ACONDIC] "
	cQry += " FROM  %SZE.SQLNAME%  WITH (NOLOCK) "
	cQry += " INNER JOIN  %SC6.SQLNAME%   WITH (NOLOCK) "
	cQry += " 	ON SZE.ZE_FILIAL 	= SC6.C6_FILIAL "
	cQry += " 	AND SZE.ZE_PEDIDO  	= SC6.C6_NUM "
	cQry += " 	AND SZE.ZE_ITEM 	= SC6.C6_ITEM "
	cQry += " 	AND SC6.R_E_C_N_O_ 	= SC6.R_E_C_N_O_ "
	cQry += " 	AND SZE.D_E_L_E_T_ 	= SC6.D_E_L_E_T_ "
	cQry += " 	INNER JOIN  %SC9.SQLNAME%   WITH (NOLOCK) "
	cQry += " ON SZE.ZE_FILIAL 		= SC9.C9_FILIAL "
	cQry += " 	AND '  '  			= SC9.C9_BLCRED "
	cQry += " 	AND '02'  			= SC9.C9_BLEST "
	cQry += " 	AND SZE.ZE_PEDIDO  	= SC9.C9_PEDIDO "
	cQry += " 	AND SZE.ZE_ITEM 	= SC9.C9_ITEM "
	cQry += " 	AND SC9.R_E_C_N_O_ 	= SC9.R_E_C_N_O_ "
	cQry += " 	AND SZE.D_E_L_E_T_ 	= SC9.D_E_L_E_T_ "
	cQry += " WHERE %SZE.XFILIAL% "
	cQry += " 	AND ZE_STATUS = 'P' "
	cQry += " 	AND ZE_PEDIDO = '" + cPed + "' "
	cQry += " 	AND %SZE.NOTDEL% "
	cQry += " 	AND %SC6.NOTDEL% "
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			if oSql:getValue("ACONDIC") == 'B'
				aadd(aRec, oSql:getValue("REC"))
			else
				oSelf:setNotif('Bobina', 'Bobina pesada para item que é rolo!',;
				{{'Pedido+Item+Recno', SZE->(ZE_PEDIDO + ZE_ITEM+ cValToChar(Recno()))}},.F.,,.T.)
			endif
			oSql:skip()
		endDo
	endif	
	oSql:close()
	FreeObj(oSql)
return(aRec)


static function cntBobPed(cPed, cItm) 
	local oSql 		:= nil 
	local cQry		:= ''
	local nTotal	:= 0
	cQry += " SELECT  "
	cQry += " COUNT(*) AS [TOTAL] "
	cQry += " FROM  %SZE.SQLNAME%  WITH (NOLOCK) "
	cQry += " WHERE %SZE.XFILIAL% "
	cQry += " AND ZE_STATUS = 'E' "
	cQry += " AND ZE_PEDIDO = '" + cPed + "' "
	cQry += " AND ZE_ITEM = '" + cItm + "' "
	cQry += " AND %SZE.NOTDEL% "
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		nTotal := oSql:getValue("TOTAL")
	endif	
	oSql:close()
	FreeObj(oSql)
return(nTotal)


static function getOutPed(cPed) 
	local oSql 		:= nil 
	local cQry		:= ''
	local aRec		:= {}
	cQry += " SELECT  "
	cQry += " SC9.R_E_C_N_O_ AS [RECC9], "
	cQry += " SC6.R_E_C_N_O_ AS [RECC6] "
	cQry += " FROM  %SC9.SQLNAME%  WITH (NOLOCK) "
	cQry += " INNER JOIN  %SC6.SQLNAME%   WITH (NOLOCK) "
	cQry += " ON SC9.C9_FILIAL 	= SC6.C6_FILIAL "
	cQry += " AND SC9.C9_PEDIDO = SC6.C6_NUM "
	cQry += " AND SC9.C9_ITEM 	= SC6.C6_ITEM "
	cQry += " WHERE %SC9.XFILIAL% "
	cQry += " AND C9_PEDIDO = '" + cPed + "' "
	cQry += " AND SC9.C9_BLCRED IN (' ') "
	cQry += " AND SC9.C9_BLEST  IN ('02') "
	cQry += " AND SC9.C9_SERIENF <> 'U' "
	cQry += " AND SC6.C6_ACONDIC <> 'B' "
	cQry += " AND %SC9.NOTDEL% "
	cQry += " AND %SC6.NOTDEL% "
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			aadd(aRec, {oSql:getValue("RECC9"), oSql:getValue("RECC6")})
			oSql:skip()
		endDo
	endif	
	oSql:close()
	FreeObj(oSql)
return(aRec)


static function aEmpBob(cPedido, cItem, cStatus)
	local oSql 		:= nil 
	local cQry		:= ''
	local aRet		:= {}
	local nQuant	:= 0
	local nRec		:= 0

	cQry += " SELECT  "
	cQry += " SZE.R_E_C_N_O_ 	AS [REC], "
	cQry += " SZE.ZE_QUANT 		AS [QUANT] "
	cQry += " FROM  %SZE.SQLNAME%  WITH (NOLOCK) "
	cQry += " WHERE %SZE.XFILIAL% "
	cQry += " AND SZE.ZE_STATUS = '" + cStatus + "' "
	cQry += " AND SZE.ZE_PEDIDO = '" + cPedido + "' "
	cQry += " AND SZE.ZE_ITEM = '" + cItem + "' "
	cQry += " AND %SZE.NOTDEL% "
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			nQuant		:= oSql:getValue("QUANT")
			nRec		:= oSql:getValue("REC")
			aadd(aRet, {nRec,nQuant} )
			oSql:skip()
		endDo
	endif	
	oSql:close()
	FreeObj(oSql)
return(aRet)


static function aEmpPed(cPedido, cItem, oStatus, lAddNew)
	local oSql 		:= nil 
	local cQry		:= ''
	local aRet		:= {}
	local cLocal	:= ''
	local cLocaliz	:= ''
	local nQuant	:= 0
	local nRec		:= 0
	default oStatus	:= nil
	default lAddNew	:= .F.

	cQry += " SELECT  "
	cQry += " SDC.R_E_C_N_O_ 	AS [REC], "
	cQry += " SDC.DC_LOCAL 		AS [LOCAL], "
	cQry += " SDC.DC_LOCALIZ 	AS [LOCALIZ], "
	cQry += " SDC.DC_QUANT 		AS [QUANT] "
	cQry += " FROM  %SDC.SQLNAME%  WITH (NOLOCK) "
	cQry += " INNER JOIN  %SC6.SQLNAME%   WITH (NOLOCK) "
	cQry += " ON SDC.DC_FILIAL 	= SC6.C6_FILIAL "
	cQry += " AND SDC.DC_PEDIDO = SC6.C6_NUM "
	cQry += " AND SDC.DC_ITEM 	= SC6.C6_ITEM "
	cQry += " WHERE %SDC.XFILIAL% "
	cQry += " AND SDC.DC_PEDIDO = '" + cPedido + "' "
	cQry += " AND SDC.DC_ITEM = '" + cItem + "' "
	cQry += " AND %SDC.NOTDEL% "
	cQry += " AND %SC6.NOTDEL% "
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			cLocal 		:= oSql:getValue("LOCAL")
			cLocaliz	:= oSql:getValue("LOCALIZ")
			nQuant		:= oSql:getValue("QUANT")
			nRec		:= oSql:getValue("REC")
			aadd(aRet, {"","",cLocaliz,"",nQuant,nQuant,Ctod(""),"","","",cLocal,0})
			if !empty(oStatus)
				if lAddNew
					oStatus:setStatus('SDC', nRec, EMPENHADO)
				else
					oStatus:clrStatus('SDC', nRec)
				endif
			endif
			oSql:skip()
		endDo
	endif	
	oSql:close()
	FreeObj(oSql)
return(aRet)


static function nEmpTotal(cPedido)
	local oSql 		:= nil 
	local cQry		:= ''
	local nTot		:= 0
	default cPedido	:= ''
	cQry += " SELECT  "
	cQry += " ISNULL(SUM(SDC.DC_QUANT * SC6.C6_PRCVEN), 0) AS [TOTAL] "
	cQry += " FROM  %SDC.SQLNAME%  WITH (NOLOCK) "
	cQry += " INNER JOIN  %SC6.SQLNAME%  WITH (NOLOCK) "
	cQry += " ON SDC.DC_FILIAL 	= SC6.C6_FILIAL "
	cQry += " AND SDC.DC_PEDIDO = SC6.C6_NUM "
	cQry += " AND SDC.DC_ITEM 	= SC6.C6_ITEM "
	cQry += " WHERE %SDC.XFILIAL% "

	if empty(cPedido)
		cQry += " AND SDC.DC_PEDIDO NOT IN (' ') "
	else
		cQry += " AND SDC.DC_PEDIDO = '" + cPedido + "' "
	endif

	cQry += " AND %SDC.NOTDEL% "
	cQry += " AND %SC6.NOTDEL% "
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		nTot := oSql:getValue("TOTAL")
	endif	
	oSql:close()
	FreeObj(oSql)
return(nTot)


static function nBlEsTotal(cPedido) 
	local oSql 		:= nil 
	local cQry		:= ''
	local nTotLib	:= 0
	default cPedido	:= ''

	cQry += " SELECT  "
	cQry += " ISNULL(SUM(SC9.C9_QTDLIB * SC6.C6_PRCVEN), 0) AS [TOTAL] "
	cQry += " FROM  %SC9.SQLNAME%  WITH (NOLOCK) "
	cQry += " INNER JOIN  %SC6.SQLNAME%  WITH (NOLOCK) "
	cQry += " ON SC9.C9_FILIAL 	= SC6.C6_FILIAL "
	cQry += " AND SC9.C9_PEDIDO = SC6.C6_NUM "
	cQry += " AND SC9.C9_ITEM 	 = SC6.C6_ITEM "
	cQry += " AND SC9.C9_PRODUTO = SC6.C6_PRODUTO "
	cQry += " AND SC6.R_E_C_N_O_ = SC6.R_E_C_N_O_ "
	cQry += " AND SC9.D_E_L_E_T_ = SC6.D_E_L_E_T_  "
	cQry += " WHERE %SC9.XFILIAL% "

	if empty(cPedido)
		cQry += " AND SC9.C9_PEDIDO NOT IN(' ')"
	else
		cQry += " AND SC9.C9_PEDIDO = '" + cPedido + "' "
	endif

	cQry += " AND SC9.C9_BLCRED IN (' ') "
	cQry += " AND SC9.C9_BLEST  IN ('02') "
	cQry += " AND SC9.C9_SERIENF NOT IN ('U') "
	cQry += " AND %SC9.NOTDEL% "
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		nTotLib := oSql:getValue("TOTAL")
	endif	
	oSql:close()
	FreeObj(oSql)
return(nTotLib)


static function getTotMark(oMainCtrl)
	local aElmMark 	:= {}
	local nTotal 		:= 0
	local nx 				:= 0
	if HMList( oMainCtrl:oHashMrk, @aElmMark )
		for nX := 1 to len(aElmMark)
			if aElmMark[nX,2,1,2,1] == 'SC9'
				if aElmMark[nX,2,1,2,4] ==  SC9->(C9_PRODUTO) + SBF->(BF_LOCALIZ) 
					nTotal += aElmMark[nX,2,1,2,2]
				endif
			endif
		Next nx
	endif
return(nTotal)


static function getTotBobMk(oMainCtrl)
	local aElmMark 	:= {}
	local nTotal 		:= 0
	local nx 				:= 0
	if HMList( oMainCtrl:oHashMrk, @aElmMark )
		for nX := 1 to len(aElmMark)
			if aElmMark[nX,2,1,2,1] == 'SZE'
				if aElmMark[nX,2,1,2,4] ==  SZE->(ZE_PEDIDO + ZE_ITEM) 
					nTotal += aElmMark[nX,2,1,2,2]
				endif
			endif
		Next nx
	endif
return(nTotal)


static function getTotLib(cPed,cItem, lOnlRec) 
	local oSql 			:= nil 
	local cQry			:= ''
	local xRet			:= 0
	default lOnlRec		:= .F.
	if lOnlRec
		xRet := {}
	else
		xRet := 0 
	endif
	cQry += " SELECT  "
	if lOnlRec
		cQry += " R_E_C_N_O_ AS [REC] "
	else
		cQry += " ISNULL(SUM(C9_QTDLIB), 0) AS [LIBERADO] "
	endif
	cQry += " FROM  %SC9.SQLNAME%  WITH (NOLOCK) "
	cQry += " WHERE %SC9.XFILIAL% "
	cQry += " AND C9_PEDIDO = '" + cPed + "' "
	cQry += " AND C9_ITEM = '" + cItem + "' "
	cQry += " AND C9_BLCRED IN (' ','10' ) "
	cQry += " AND C9_BLEST IN (' ', '10' ) "
	cQry += " AND SC9.C9_SERIENF <> 'U' "
	cQry += " AND %SC9.NOTDEL% "
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		if lOnlRec
			xRet := {}
			while oSql:notIsEof()
				aadd(xRet,oSql:getValue("REC"))
				oSql:skip()
			endDo
		else
			xRet := oSql:getValue("LIBERADO")
		endif	
	endif
	oSql:close()
	FreeObj(oSql)
return(xRet)


static function getTotBlq(cPed,cItem, lOnlRec) 
	local oSql 			:= nil 
	local cQry			:= ''
	local xRet			:= 0
	default lOnlRec		:= .F.
	default cItem		:= ''
	if lOnlRec
		xRet := {}
	else
		xRet := 0 
	endif
	cQry += " SELECT  "
	if lOnlRec
		cQry += " SC9.R_E_C_N_O_ AS [RECC9], "
		cQry += " SC6.R_E_C_N_O_ AS [RECC6], "
		cQry += " SB1.R_E_C_N_O_ AS [RECB1] "
	else
		cQry += " ISNULL(SUM(SC9.C9_QTDLIB), 0) AS [BLOQUEADO] "
	endif
	cQry += " FROM  %SC9.SQLNAME%  WITH (NOLOCK) "
	cQry	+= "  INNER JOIN " +  RetSqlName('SC6')  + " SC6  WITH (NOLOCK) "
	cQry	+= "  	ON SC9.C9_FILIAL 	= SC6.C6_FILIAL  " 
	cQry	+= "  	AND SC9.C9_PEDIDO	= SC6.C6_NUM  "
	cQry	+= "  	AND SC9.C9_ITEM 	= SC6.C6_ITEM  " 
	cQry	+= "  	AND SC9.C9_PRODUTO 	= SC6.C6_PRODUTO "
	cQry	+= "  	AND SC6.R_E_C_N_O_  = SC6.R_E_C_N_O_ "  
	cQry	+= "  	AND SC9.D_E_L_E_T_  = SC6.D_E_L_E_T_
	cQry	+= "  INNER JOIN " +  RetSqlName('SF4')  + " SF4  WITH (NOLOCK) "
	cQry	+= "  	ON '' 				= SF4.F4_FILIAL  " 
	cQry	+= "  	AND SC6.C6_TES		= SF4.F4_CODIGO  "
	cQry	+= "  	AND SF4.R_E_C_N_O_  = SF4.R_E_C_N_O_ "  
	cQry	+= "  	AND SC6.D_E_L_E_T_  = SF4.D_E_L_E_T_
	cQry	+= "  INNER JOIN " +  RetSqlName('SB1')  + " SB1  WITH (NOLOCK) "
	cQry	+= "  	ON '" + xFilial('SB1') + "'	= SB1.B1_FILIAL  " 
	cQry	+= "	AND 'PA'			= SB1.B1_TIPO "
	cQry	+= "  	AND SC9.C9_PRODUTO	= SB1.B1_COD  " 
	cQry	+= "  	AND SB1.R_E_C_N_O_  = SB1.R_E_C_N_O_ "  
	cQry	+= "  	AND SC9.D_E_L_E_T_  = SB1.D_E_L_E_T_
	cQry += " WHERE %SC9.XFILIAL% "
	cQry += " AND C9_PEDIDO = '" + cPed + "' "
	if !empty(cItem)
		cQry += " AND C9_ITEM = '" + cItem + "' "
	endif
	cQry += " AND C9_BLCRED IN (' ' ) "
	cQry += " AND C9_BLEST IN ('02' ) "
	cQry += " AND SC9.C9_SERIENF <> 'U' "
	cQry += " AND SF4.F4_ESTOQUE = 'S' "
	cQry += " AND %SC9.NOTDEL% "
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		if lOnlRec
			xRet := {}
			while oSql:notIsEof()
				aadd(xRet,{oSql:getValue("RECC9"),oSql:getValue("RECC6"),oSql:getValue("RECB1") })
				oSql:skip()
			endDo
		else
			xRet := oSql:getValue("BLOQUEADO")
		endif	
	endif
	oSql:close()
	FreeObj(oSql)
return(xRet)


static function getFilQry()	
	local cQry		:= ''
	cQry 	+= " SELECT  "
	cQry 	+= " SC5.R_E_C_N_O_ AS [REC],"
	cQry 	+= " SUM(SC9.C9_QTDLIB) AS [Necess], "
	cQry	+= "  CASE
	cQry	+= "  	WHEN B1_LOCALIZ = 'S'
	cQry	+= "  		THEN SUM(ISNULL((SBF.BF_QUANT - SBF.BF_EMPENHO), 0))
	cQry	+= "  	ELSE SUM(ISNULL((SB2.B2_QATU - SB2.B2_QEMP), 0))
	cQry	+= "  END	AS [Disp]
	cQry	+= "  FROM   "
	cQry 	+= 	RetSqlName('SC9') + " SC9  WITH (NOLOCK) "
	cQry	+= "  INNER JOIN " +  RetSqlName('SC5')  + " SC5  WITH (NOLOCK) "
	cQry	+= "  	ON '" + xFilial('SC5') + "'	= SC5.C5_FILIAL  " 
	cQry	+= "	AND SC9.C9_PEDIDO	= SC5.C5_NUM "
	cQry	+= "  	AND SC5.R_E_C_N_O_  = SC5.R_E_C_N_O_ "  
	cQry	+= "  	AND SC9.D_E_L_E_T_  = SC5.D_E_L_E_T_
	cQry	+= "  INNER JOIN " +  RetSqlName('SB1')  + " SB1  WITH (NOLOCK) "
	cQry	+= "  	ON '" + xFilial('SB1') + "'	= SB1.B1_FILIAL  " 
	cQry	+= "	AND 'PA'			= SB1.B1_TIPO "
	cQry	+= "  	AND SC9.C9_PRODUTO	= SB1.B1_COD  " 
	cQry	+= "  	AND SB1.R_E_C_N_O_  = SB1.R_E_C_N_O_ "  
	cQry	+= "  	AND SC9.D_E_L_E_T_  = SB1.D_E_L_E_T_
	cQry	+= "  INNER JOIN " +  RetSqlName('SB2')  + " SB2  WITH (NOLOCK) "
	cQry	+= "  	ON '" + xFilial('SB2') + "'	= SB2.B2_FILIAL  " 
	cQry	+= "  	AND SC9.C9_PRODUTO	= SB2.B2_COD   " 
	cQry	+= "  	AND SC9.C9_LOCAL	= SB2.B2_LOCAL   "
	cQry	+= "  	AND SB2.R_E_C_N_O_  = SB2.R_E_C_N_O_  "  
	cQry	+= "  	AND SC9.D_E_L_E_T_  = SB2.D_E_L_E_T_  "
	cQry	+= "  INNER JOIN " +  RetSqlName('SC6')  + " SC6  WITH (NOLOCK) "
	cQry	+= "  	ON SC9.C9_FILIAL 	= SC6.C6_FILIAL  " 
	cQry	+= "  	AND SC9.C9_PEDIDO	= SC6.C6_NUM  "
	cQry	+= "  	AND SC9.C9_ITEM 	= SC6.C6_ITEM  " 
	cQry	+= "  	AND SC9.C9_PRODUTO 	= SC6.C6_PRODUTO "
	cQry	+= "  	AND SC6.R_E_C_N_O_  = SC6.R_E_C_N_O_ "  
	cQry	+= "  	AND SC9.D_E_L_E_T_  = SC6.D_E_L_E_T_
	cQry	+= "  LEFT JOIN " +  RetSqlName('SBF')  + " SBF  WITH (NOLOCK) "
	cQry	+= "  	ON SC9.C9_FILIAL 		= SBF.BF_FILIAL  " 
	cQry	+= "  	AND SC9.C9_LOCAL		= SBF.BF_LOCAL  "
	cQry	+= "  	AND SC6.C6_ACONDIC 	+ right(replicate('0',5) + cast(C6_METRAGE as VARCHAR),5) = SBF.BF_LOCALIZ  "
	cQry	+= "  	AND SC9.C9_PRODUTO		= SBF.BF_PRODUTO  "
	cQry	+= "  	AND SBF.R_E_C_N_O_  	= SBF.R_E_C_N_O_ "  
	cQry	+= "  	AND SC9.D_E_L_E_T_ 		= SBF.D_E_L_E_T_ "
	cQry	+= "  WHERE  "
	cQry 	+= " SC9.C9_FILIAL = '" + xFilial('SC9') + "' "
	cQry	+= "  	AND SC9.C9_BLCRED IN (' ')   "
	cQry	+= "  	AND SC9.C9_BLEST  IN ('02')  "
	cQry	+= "  	AND SC9.C9_SERIENF NOT IN ('U')  	 "
	cQry	+= "  	AND SC9.D_E_L_E_T_ IN (' ')  "
	cQry	+= " GROUP BY   "
	cQry	+= " 	SC5.R_E_C_N_O_ , SB1.B1_LOCALIZ "
	cQry	+= " ORDER BY  "
	cQry	+= "  SC5.R_E_C_N_O_  "
return(cQry)


static function getResQry(cPed, cProd, lOnlyFault)	
	local cQry		:= ''
	default cPed 	:= ''
	default cProd 	:= ''
	default lOnlyFault	:= .F.
	cQry 	+= " SELECT  "
	if lOnlyFault
		cQry += " DISTINCT SC5.R_E_C_N_O_ AS [ITEM]"
	else
		cQry 	+= "  	RTRIM(LTRIM(SC9.C9_PRODUTO)) AS [Produto], "
		cQry 	+= "  	SC6.C6_ACONDIC + right(replicate('0',5) + cast(C6_METRAGE as VARCHAR),5) AS [Acond], "
		cQry	+= "  	SUM(SC6.C6_LANCES) AS [Lances], "
		cQry	+= "  	SUM(SC6.C6_QTDVEN) AS [Vendido], "
		cQry	+= "  	SUM(SC6.C6_QTDENT) AS [Entregue], "
		cQry	+= "  	SUM(SC9.C9_QTDLIB) AS [Necess], "

		cQry	+= "  	CASE "
		cQry	+= "  		WHEN SB1.B1_LOCALIZ = 'S' "  
		cQry	+= "  			THEN ISNULL((SBF.BF_QUANT - SBF.BF_EMPENHO), 0) "
		cQry	+= "  		ELSE ISNULL((SB2.B2_QATU - SB2.B2_QEMP), 0) "
		cQry	+= "  	END AS [Disponivel] "		
	endif
	cQry	+= "  FROM   "
	cQry 	+= 	RetSqlName('SC9') + " SC9  WITH (NOLOCK) "
	cQry	+= "  INNER JOIN " +  RetSqlName('SC5')  + " SC5  WITH (NOLOCK) "
	cQry	+= "  	ON '" + xFilial('SC5') + "'	= SC5.C5_FILIAL  " 
	cQry	+= "	AND SC9.C9_PEDIDO	= SC5.C5_NUM "
	cQry	+= "  	AND SC5.R_E_C_N_O_  = SC5.R_E_C_N_O_ "  
	cQry	+= "  	AND SC9.D_E_L_E_T_  = SC5.D_E_L_E_T_
	cQry	+= "  INNER JOIN " +  RetSqlName('SB1')  + " SB1  WITH (NOLOCK) "
	cQry	+= "  	ON '" + xFilial('SB1') + "'	= SB1.B1_FILIAL  " 
	cQry	+= "	AND 'PA'			= SB1.B1_TIPO "
	cQry	+= "  	AND SC9.C9_PRODUTO	= SB1.B1_COD  " 
	cQry	+= "  	AND SB1.R_E_C_N_O_  = SB1.R_E_C_N_O_ "  
	cQry	+= "  	AND SC9.D_E_L_E_T_  = SB1.D_E_L_E_T_
	cQry	+= "  INNER JOIN " +  RetSqlName('SB2')  + " SB2  WITH (NOLOCK) "   	
	cQry	+= "  	ON '" + xFilial('SB2') + "'	= SB2.B2_FILIAL  "  	
	cQry	+= "  	AND SC9.C9_PRODUTO	= SB2.B2_COD "    	
	cQry	+= "  	AND SC9.C9_LOCAL	= SB2.B2_LOCAL "
	cQry	+= "  	AND SB2.R_E_C_N_O_  = SB2.R_E_C_N_O_   	
	cQry	+= "  	AND SC9.D_E_L_E_T_  = SB2.D_E_L_E_T_ "  
	cQry	+= "  INNER JOIN " +  RetSqlName('SC6')  + " SC6  WITH (NOLOCK) "
	cQry	+= "  	ON SC9.C9_FILIAL 	= SC6.C6_FILIAL  " 
	cQry	+= "  	AND SC9.C9_PEDIDO	= SC6.C6_NUM  "
	cQry	+= "  	AND SC9.C9_ITEM 	= SC6.C6_ITEM  " 
	cQry	+= "  	AND SC9.C9_PRODUTO 	= SC6.C6_PRODUTO "
	cQry	+= "  	AND SC6.R_E_C_N_O_  = SC6.R_E_C_N_O_ "  
	cQry	+= "  	AND SC9.D_E_L_E_T_  = SC6.D_E_L_E_T_
	cQry	+= "  LEFT JOIN " +  RetSqlName('SBF')  + " SBF  WITH (NOLOCK) "
	cQry	+= "  	ON SC9.C9_FILIAL 		= SBF.BF_FILIAL  " 
	cQry	+= "  	AND SC9.C9_LOCAL		= SBF.BF_LOCAL  "
	cQry	+= "  	AND SC6.C6_ACONDIC 	+ right(replicate('0',5) + cast(C6_METRAGE as VARCHAR),5) = SBF.BF_LOCALIZ  "
	cQry	+= "  	AND SC9.C9_PRODUTO		= SBF.BF_PRODUTO  "
	cQry	+= "  	AND SBF.R_E_C_N_O_  	= SBF.R_E_C_N_O_ "  
	cQry	+= "  	AND SC9.D_E_L_E_T_ 		= SBF.D_E_L_E_T_ "
	cQry	+= "  WHERE  "
	cQry 	+= " SC9.C9_FILIAL = '" + xFilial('SC9') + "' "
	if !empty(cPed)
		cQry	+= "  	AND SC9.C9_PEDIDO = '" + cPed + "'  "
	endif
	if !empty(cProd)
		cQry	+= "  	AND SC9.C9_PRODUTO = '" + cProd + "'  "
	endif
	cQry	+= "  	AND SC9.C9_BLCRED IN (' ')   "
	cQry	+= "  	AND SC9.C9_BLEST  IN ('02')  "
	cQry	+= "  	AND SC9.C9_SERIENF NOT IN ('U')  	 "
	// Busca somente os itens que estoque não atende
	if lOnlyFault
		cQry	+= "  AND ISNULL((SBF.BF_QUANT - SBF.BF_EMPENHO), 0) < SC9.C9_QTDLIB "
	endif
	cQry	+= "  	AND SC9.D_E_L_E_T_ IN (' ')  "
	if !lOnlyFault
		cQry	+= " GROUP BY   "
		cQry	+= " 	SB1.B1_LOCALIZ, "
		cQry	+= " 	SC9.C9_PRODUTO , SC6.C6_ACONDIC + right(replicate('0',5) + cast(C6_METRAGE as VARCHAR),5), C6_METRAGE,   "
		cQry	+= " 	ISNULL((SBF.BF_QUANT - SBF.BF_EMPENHO), 0), "
		cQry	+= " 	ISNULL((SB2.B2_QATU - SB2.B2_QEMP), 0) "
		cQry	+= " ORDER BY  "
		cQry	+= "  SC9.C9_PRODUTO, Acond  "
	endif
return(cQry)


static function getHvNoHv(cPed, nVlrTem,nVlrFalta )
	local cQry		:= ''
	local oSql		:= nil
	default cPed 	:= ''
	nVlrTem		:= 0
	nVlrFalta 	:= 0
	if !empty(cPed)
		cQry 	+= " SELECT  "
		cQry	+= "  	SUM(SC6.C6_PRCVEN) AS [Preco], "
		cQry	+= "  	SUM(SC9.C9_QTDLIB) AS [Necess], "
		cQry	+= "  	CASE "
		cQry	+= "  		WHEN SB1.B1_LOCALIZ = 'S' "  
		cQry	+= "  			THEN SUM(ISNULL((SBF.BF_QUANT - SBF.BF_EMPENHO), 0))  "
		cQry	+= "  		ELSE "
		cQry	+= "  			SUM(ISNULL((SB2.B2_QATU - SB2.B2_QEMP), 0)) "
		cQry	+= "  	END AS [Disponivel] "
		cQry	+= "  FROM   "
		cQry 	+= 	RetSqlName('SC9') + " SC9  WITH (NOLOCK) "
		cQry	+= "  INNER JOIN " +  RetSqlName('SC5')  + " SC5  WITH (NOLOCK) "
		cQry	+= "  	ON '" + xFilial('SC5') + "'	= SC5.C5_FILIAL  " 
		cQry	+= "	AND SC9.C9_PEDIDO	= SC5.C5_NUM "
		cQry	+= "  	AND SC5.R_E_C_N_O_  = SC5.R_E_C_N_O_ "  
		cQry	+= "  	AND SC9.D_E_L_E_T_  = SC5.D_E_L_E_T_
		cQry	+= "  INNER JOIN " +  RetSqlName('SB1')  + " SB1  WITH (NOLOCK) "
		cQry	+= "  	ON '" + xFilial('SB1') + "'	= SB1.B1_FILIAL  " 
		cQry	+= "	AND 'PA'			= SB1.B1_TIPO "
		cQry	+= "  	AND SC9.C9_PRODUTO	= SB1.B1_COD  " 
		cQry	+= "  	AND SB1.R_E_C_N_O_  = SB1.R_E_C_N_O_ "  
		cQry	+= "  	AND SC9.D_E_L_E_T_  = SB1.D_E_L_E_T_
		cQry	+= "  INNER JOIN " +  RetSqlName('SB2')  + " SB2  WITH (NOLOCK) "   	
		cQry	+= "  	ON '" + xFilial('SB2') + "'	= SB2.B2_FILIAL  "  	
		cQry	+= "  	AND SC9.C9_PRODUTO	= SB2.B2_COD "    	
		cQry	+= "  	AND SC9.C9_LOCAL	= SB2.B2_LOCAL "
		cQry	+= "  	AND SB2.R_E_C_N_O_  = SB2.R_E_C_N_O_   	
		cQry	+= "  	AND SC9.D_E_L_E_T_  = SB2.D_E_L_E_T_ "  
		cQry	+= "  INNER JOIN " +  RetSqlName('SC6')  + " SC6  WITH (NOLOCK) "
		cQry	+= "  	ON SC9.C9_FILIAL 	= SC6.C6_FILIAL  " 
		cQry	+= "  	AND SC9.C9_PEDIDO	= SC6.C6_NUM  "
		cQry	+= "  	AND SC9.C9_ITEM 	= SC6.C6_ITEM  " 
		cQry	+= "  	AND SC9.C9_PRODUTO 	= SC6.C6_PRODUTO "
		cQry	+= "  	AND SC6.R_E_C_N_O_  = SC6.R_E_C_N_O_ "  
		cQry	+= "  	AND SC9.D_E_L_E_T_  = SC6.D_E_L_E_T_
		cQry	+= "  LEFT JOIN " +  RetSqlName('SBF')  + " SBF  WITH (NOLOCK) "
		cQry	+= "  	ON SC9.C9_FILIAL 		= SBF.BF_FILIAL  " 
		cQry	+= "  	AND SC9.C9_LOCAL		= SBF.BF_LOCAL  "
		cQry	+= "  	AND SC6.C6_ACONDIC 	+ right(replicate('0',5) + cast(C6_METRAGE as VARCHAR),5) = SBF.BF_LOCALIZ  "
		cQry	+= "  	AND SC9.C9_PRODUTO		= SBF.BF_PRODUTO  "
		cQry	+= "  	AND SBF.R_E_C_N_O_  	= SBF.R_E_C_N_O_ "  
		cQry	+= "  	AND SC9.D_E_L_E_T_ 		= SBF.D_E_L_E_T_ "
		cQry	+= "  WHERE  "
		cQry 	+= " SC9.C9_FILIAL = '" + xFilial('SC9') + "' "
		cQry	+= "  	AND SC9.C9_PEDIDO = '" + cPed + "'  "
		cQry	+= "  	AND SC9.C9_PRODUTO NOT IN ('')  "
		cQry	+= "  	AND SC9.C9_BLCRED IN (' ')   "
		cQry	+= "  	AND SC9.C9_BLEST  IN ('02')  "
		cQry	+= "  	AND SC9.C9_SERIENF NOT IN ('U')  	 "
		cQry	+= "  	AND SC9.D_E_L_E_T_ IN (' ')  "
		cQry	+= " GROUP BY  "
		cQry	+= "  SB1.B1_LOCALIZ, "
		cQry	+= "  SC9.C9_PRODUTO, "
		cQry	+= "  SC6.C6_ACONDIC + right(replicate('0',5) + cast(C6_METRAGE as VARCHAR),5) "

		oSql := LibSqlObj():newLibSqlObj()
		oSql:newAlias(cQry)
		if oSql:hasRecords()
			oSql:goTop()
			while oSql:notIsEof()
				if ( oSql:getValue("Disponivel") >= oSql:getValue("Necess") )
					nVlrTem 	+=  (oSql:getValue("Necess") * oSql:getValue("Preco"))
				else
					nVlrTem 	+=  (oSql:getValue("Disponivel") * oSql:getValue("Preco")) 
					nVlrFalta 	+= (oSql:getValue("Necess") - oSql:getValue("Disponivel")) * oSql:getValue("Preco") 
				endif
				oSql:skip()
			endDo
		endif	
		oSql:close()
		FreeObj(oSql)
	endif
return(cQry)



static function existTab(cTab, nOrd, cChv, oCtrl, cNick, lObr)
	local nRecPos	:= 0
	local lRet 		:= .F.
	default nOrd	:= 0
	default cNick	:= ''
	default lObr	:= .T.
	dbSelectArea(cTab)
	if empty(cNick)
		(cTab)->(dbSetOrder(nOrd))
	else
		(cTab)->(dbOrderNickName(cNick))
	endif
	if !(lRet := (cTab)->(DbSeek(xFilial(cTab) + cChv)))
		if lObr
			// Utiliza-se assim para disparar user execption.
			oCtrl:setStatus(.F., 'Registro ' + cTab + ' não encontrado ' + ' Chave ' + cChv , .T.)
		else
			lRet := .T.
		endif
	endif
return(lRet)


static function filSZE()
return(.T.)

