#include "rwmake.ch"
#include "TOPCONN.ch"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CDESTR32 º Autor ³ EDVAR VASSAITIS    º Data ³  18/04/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de NF em excel para Transporte                   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function CDESTR32()
	Local cQuery      := ""
	Local cPedido     := ""
	Local nTotal      := 0
	Local nValorNF    := 0
	Local nPeso       := 0
	Local nVolum      := 0 
	Local aCampos     := {"A1_NOME","A1_MUN","A1_EST","F2_DOC","F2_EMISSAO","F2_VOLUME1","F2_ESPECI1","F2_PBRUTO","F2_VALBRUT","C6_NUM","F2_VALBRUT","A4_NOME","F2_CDROMA"," " }
	Local aDadosCab   := {}
	Local aDadosItens := {}
	Local lNF         := .T.
	Private  cPerg       := "CDESTR32"
	cBranch	:= FwFilial()
	
	ValidPerg()
	If !Pergunte(cPerg, .T.)
		Return(.T.)
	EndIf
	
	
	cQuery += " SELECT" 
	cQuery += " CASE"
	cQuery += " 	WHEN F2_TIPO IN ('B','D')"	//B=BENEFICIAMENTO, D=DEVOLUÇÃO
	cQuery += " 		THEN A2_NOME"
	cQuery += " 	ELSE A1_NOME"
	cQuery += " END AS CLI_FOR,"
	cQuery += " CASE"
	cQuery += " 	WHEN F2_TIPO IN ('B','D')"	
	cQuery += " 		THEN A2_MUN"
	cQuery += " 	ELSE A1_MUN"
	cQuery += " END AS CIDADE,"
	cQuery += " CASE"
	cQuery += " 	WHEN F2_TIPO IN ('B','D')"
	cQuery += " 		THEN A2_EST"
	cQuery += " 	ELSE A1_EST"
	cQuery += " END AS ESTADO,"	
	cQuery += " F2_DOC,"
	cQuery += " F2_SERIE,"
	cQuery += " F2_EMISSAO,"
	cQuery += " F2_ESPECI1,"
	cQuery += " F2_VOLUME1,"
	cQuery += " F2_PBRUTO," 
	cQuery += " F2_VALBRUT," 
	cQuery += " A4_NOME,"
	cQuery += " F2_CDROMA"
	cQuery += " FROM "+RetSqlName("SF2")+ " SF2"
	cQuery += " LEFT JOIN " + RetSqlName("SA1")+" SA1"
	cQuery += "		ON '' = SA1.A1_FILIAL"
	cQuery += " 	AND SF2.F2_CLIENTE = SA1.A1_COD" 
	cQuery += " 	AND SF2.F2_LOJA=SA1.A1_LOJA"
	cQuery += "		AND SF2.D_E_L_E_T_ = SA1.D_E_L_E_T_"
	cQuery += " LEFT JOIN " + RetSqlName("SA2") +" SA2"
	cQuery += " 	ON '' = SA2.A2_FILIAL"
	cQuery += " 	AND SF2.F2_CLIENTE	= SA2.A2_COD"
	cQuery += " 	AND SF2.F2_LOJA		= SA2.A2_LOJA"
	cQuery += " 	AND SF2.D_E_L_E_T_	= SA2.D_E_L_E_T_"
	cQuery += " INNER JOIN "+RetSqlName("SA4") + " SA4"
	cQuery += " 	ON '' = SA4.A4_FILIAL"
	cQuery += "		AND SF2.F2_TRANSP = SA4.A4_COD" 
	cQuery += "     AND SF2.D_E_L_E_T_ = SA4.D_E_L_E_T_"
	cQuery += " WHERE "
	cQuery += " F2_FILIAL = " + "'" + cBranch + "'"
	cQuery += " AND F2_EMISSAO BETWEEN '"+DtoS(mv_par01)+"' AND '"+DtoS(mv_par02)+"'"
	cQuery += " AND F2_SERIE = '1  '"
	cQuery += " AND SF2.D_E_L_E_T_	= ''"	
	cQuery += " AND SA4.A4_COD NOT IN ('000000','000001','000123')"
	cQuery += " ORDER BY F2_EMISSAO,F2_CDROMA"
	cQuery := ChangeQuery(cQuery)

	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"

	DbSelectArea("SX3")
	dbSetOrder(2)
	//Estrutura do aHeader
	For nI:= 1 to Len(aCampos)
		SX3->(dbSeek(aCampos[nI]))
		If Alltrim(SX3->X3_CAMPO) == "F2_VALBRUT" .And. lNF
			aAdd(aDadosCab, { "ValorNF", SX3->X3_TIPO, SX3->X3_TAMANHO , SX3->X3_DECIMAL})
			lNF := .F.
		ElseIf Alltrim(SX3->X3_CAMPO) == "F2_VALBRUT" .And. !lNF
			aAdd(aDadosCab, { "Total", SX3->X3_TIPO, SX3->X3_TAMANHO , SX3->X3_DECIMAL})
		Else
			aAdd(aDadosCab, { SX3->X3_TITULO, SX3->X3_TIPO, SX3->X3_TAMANHO , SX3->X3_DECIMAL})
		EndIf
	Next
	aAdd(aDadosCab, {" "," ","C",1,0})

	//Preenchendo aCols com resultado da Query
	DbSelectArea("TRB")
	DbGotop()
	Do While !TRB->(Eof())

		cPedido := Posicione("SD2",3,xFilial("SD2")+F2_DOC,"D2_PEDIDO")
		nPeso   := 0
		nTotal  := 0
		nValorNF:= 0
		nVolum  := 0
		cCDRoma := TRB->F2_CDROMA
		Do While !TRB->(Eof()) .And. TRB->F2_CDROMA == cCDRoma

			If Alltrim(TRB->F2_SERIE) == "1"
				nValorNF += TRB->F2_VALBRUT
			EndIf
			
			cCliente := TRB->CLI_FOR
			cMun     := TRB->CIDADE
			cEst     := TRB->ESTADO
			cDoc     :=	TRB->F2_DOC
			cEmissao := TRB->F2_EMISSAO
			cEspecie := TRB->F2_ESPECI1
			nTotal   += TRB->F2_VALBRUT
			nPeso    := TRB->F2_PBRUTO
			nVolum   := TRB->F2_VOLUME1
			cTransp  := TRB->A4_NOME

			TRB->(DbSkip())
		EndDo

		aAdd(aDadosItens, { cCliente	  ,;
		cMun  		  ,; 
		cEst          ,; 
		cDoc          ,;
		StoD(cEmissao),; 
		nVolum   	  ,;
		cEspecie      ,;
		nPeso         ,;
		nValorNF      ,;
		cPedido 	  ,;
		nTotal        ,;
		cTransp       ,;
		cCDRoma       ,;
		" "})

		//TRB->(DbSkip())
	EndDo
	DlgToExcel({{"GETDADOS", "NF p/ Transportes", aDadosCab, aDadosItens}})// Abrir Excel

	Return(.T.)

	*
	***************************
Static Function ValidPerg()
	***************************
	*

	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	aRegs:={}

	//Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Emissão de  ...?","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Emissão ate ...?","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})

	For i := 1 To Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2] , .F.)
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