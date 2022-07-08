#include "rwmake.ch"
#include "TOPCONN.ch"
#include "fileio.ch"

/*/{Protheus.doc} CDFAT13
@author legado
@since 21/07/2017
@version 0.0
@type function
@description Função para Importação de Tabelas de Preços a partir de    
arquivo texto gerado por Planilha Excel
/*/
User Function CDFAT13()
	Private cPerg := "CDFAT13"
	ValidPerg()
	Do While .T.
		If !Pergunte(cPerg,.T.)
			Exit
		EndIf
		If Empty(MV_PAR01)
			Alert("Informar o Nome do Arquivo")
			Loop
		EndIf
		_cArq := "\CONDUSUL\"+AllTrim(MV_PAR01)
		If !File(_cArq)
			Alert("O Arquivo " + MV_PAR01 + " tem que estar na Pasta CONDUSUL")
			Loop
		EndIf
		If MsgBox("Confirma a configuração dos parâmetros?","Confirma?","YesNo")
			Processa({|| Importa()})
			MsgInfo("Tabelas de Preço Atualizadas","Concluido")
			Exit
		EndIf
		Exit
	EndDo	
Return(.T.)

Static Function Importa
	Local aTab		:= STRTOKARR(MV_PAR02,",")
	Local nTam		:= TamSx3("DA1_CODTAB")[1]
	local cArq		:= "", cOrigem := ""
	local aDados	:= {}
	local nCont 	:= 1
	local nColun 	:= 1
	Private _cItem	:= StrZero(0,Len(DA1->DA1_ITEM))
	
	DbSelectArea("DA0")
	DbSetOrder(1)  //DA0_FILIAL+DA0_CODTAB
	cArq 	:= AllTrim(MV_PAR01)
	cOrigem	:= "\CONDUSUL\"
	Processa( {|| aDados:= U_CargaXLS(cArq,cOrigem,,.F.)},"Aguarde, carregando planilha...Pode demorar")
	ProcRegua(Len(aTab))
	For nI:=1 to Len(aTab)
		IncProc()
		nColun 	:= 1
		nColTab := 0
		while nColun <= len (aDados[1])
			if aTab[nI] == aDados[1][nColun]
				nColTab := nColun
				nColun := len (aDados[1]) +1
			endif	
			nColun += 1
		enddo
		If Left(aTab[nI],1) $ "Nn" .And. Substr(aTab[nI],2,1) $ "0123456789"
			_cTabela := Left( Substr(aTab[nI],2) + Space(nTam) , nTam ) // "PR " // A tabela é só um numero   
		Else
			_cTabela := Left( aTab[nI] + Space(nTam) , nTam ) // "PR "
		EndIf
		_cItem    := StrZero(0,Len(DA1->DA1_ITEM))
		DbSelectArea("DA0")
		If !DA0->(DbSeek(xFilial("DA0")+_cTabela,.F.))
			RecLock("DA0",.T.)
			DA0->DA0_FILIAL := xFilial("DA0")
			DA0->DA0_CODTAB := _cTabela
			DA0->DA0_DESCRI := "TABELA "+_cTabela
			DA0->DA0_DATDE  := dDataBase
			DA0->DA0_HORADE := "00:00"
			DA0->DA0_HORATE := "23:59"
			DA0->DA0_TPHORA := "1"
			DA0->DA0_ATIVO  := "1"
			MsUnLock()
		EndIf
		//Procuro ultimo Item para continuar sequencia
		DbSelectArea("DA1")
		DbSetOrder(3)//DA1_FILIAL+DA1_CODTAB+DA1_ITEM
		DA1->(DbSeek(xFilial("DA1")+Soma1(_cTabela),.T.))
		DA1->(DbSkip(-1))
		If DA1->DA1_FILIAL == xFilial("DA1") .And. DA1->DA1_CODTAB == _cTabela
			_cItem := DA1->DA1_ITEM
		EndIf
		nCont := 2
		Do While nCont <= len(aDados)
			If Empty(aDados[nCont][1]) .Or. "BRASILEIRINHO" $ aDados[nCont][2]
				nCont += 1
				Loop
			EndIf
			_cProduto := aDados[nCont][1]
			DbSelectArea("SB1")
			DbSeek(xFilial("SB1")+Subst(_cProduto,1,5),.F.)
			Do While SB1->(!Eof()) .And. xFilial("SB1")+Subs(_cProduto,1,5) == SB1->B1_FILIAL+Subs(SB1->B1_COD,1,5)
				DbSelectArea("DA1")
				DbSetOrder(1)  //DA1_FILIAL+DA1_CODTAB+DA1_CODPRO+DA1_INDLOT+DA1_ITEM
				If !DA1->(DbSeek(xFilial("DA1")+_cTabela+SB1->B1_COD,.F.))
					_cItem := Soma1(_cItem)
					RecLock("DA1",.T.)
					DA1->DA1_FILIAL := xFilial("DA1")
					DA1->DA1_ITEM   := _cItem
					DA1->DA1_CODTAB := _cTabela
					DA1->DA1_CODPRO := SB1->B1_COD
					DA1->DA1_QTDLOT := 999999.99
					DA1->DA1_INDLOT := StrZero(DA1->DA1_QTDLOT,Len(DA1->DA1_INDLOT),2)
					DA1->DA1_MOEDA  := 1
					DA1->DA1_TPOPER := "4"
					DA1->DA1_ATIVO  := "1"
				Else
					RecLock("DA1",.F.)
				EndIf
				if nColTab <> 0
					If "50MTS" $ aDados[nCont][2]
						DA1->DA1_PRC50M := Val(StrTran(StrTran(aDados[nCont][nColTab],".",""),",","."))
					ElseIf "15MTS" $ aDados[nCont][2]
						DA1->DA1_PRC15M := Val(StrTran(StrTran(aDados[nCont][nColTab],".",""),",","."))
					Else
						DA1->DA1_PRCVEN := Val(StrTran(StrTran(aDados[nCont][nColTab],".",""),",","."))
					EndIf
				endif
				MsUnLock()
				SB1->(Dbskip())
			Enddo
			nCont += 1
		Enddo
	Next
Return(.T.)

Static Function ValidPerg
	_aArea := GetArea()
	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	aRegs:={}
	aAdd(aRegs,{cPerg,"01","Nome do arquivo    ?","mv_ch1","C",40,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Tabelas a importar ?","mv_ch2","C",60,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	For i := 1 To Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			SX1->X1_GRUPO   := aRegs[i,01]
			SX1->X1_ORDEM   := aRegs[i,02]
			SX1->X1_PERGUNT := aRegs[i,03]
			SX1->X1_VARIAVL := aRegs[i,04]
			SX1->X1_TIPO    := aRegs[i,05]
			SX1->X1_TAMANHO := aRegs[i,06]
			SX1->X1_DECIMAL := aRegs[i,07]
			SX1->X1_PRESEL  := aRegs[i,08]
			SX1->X1_GSC     := aRegs[i,09]
			SX1->X1_VALID   := aRegs[i,10]
			SX1->X1_VAR01   := aRegs[i,11]
			SX1->X1_DEF01   := aRegs[i,12]
			SX1->X1_CNT01   := aRegs[i,13]
			SX1->X1_VAR02   := aRegs[i,14]
			SX1->X1_DEF02   := aRegs[i,15]
			SX1->X1_CNT02   := aRegs[i,16]
			SX1->X1_VAR03   := aRegs[i,17]
			SX1->X1_DEF03   := aRegs[i,18]
			SX1->X1_CNT03   := aRegs[i,19]
			SX1->X1_VAR04   := aRegs[i,20]
			SX1->X1_DEF04   := aRegs[i,21]
			SX1->X1_CNT04   := aRegs[i,22]
			SX1->X1_VAR05   := aRegs[i,23]
			SX1->X1_DEF05   := aRegs[i,24]
			SX1->X1_CNT05   := aRegs[i,25]
			SX1->X1_F3      := aRegs[i,26]
			MsUnlock()
			DbCommit()
		Endif
	Next
	RestArea(_aArea)
Return(.T.)
