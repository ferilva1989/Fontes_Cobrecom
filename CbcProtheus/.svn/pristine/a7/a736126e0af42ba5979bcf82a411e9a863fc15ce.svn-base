#include "TOTVS.CH"
#Include "PROTHEUS.CH"

/*
(Função enviar e-mail formatado tipo colunas(TR/TD)HTML)
1-Parametro = Array contento todos os destinatarios do e-mail
2-Parametro = Assunto do e-mail
3-Parametro = Array contendo os cabeçalhos das colunas
4-Parametro = Array multidimensional, onde cada array deve conter informações para preencher uma linha
u_envmail({'wfti@cobrecom.com.br'}, 'Teste', {'Nome','Idade'},{{'Meu Nome','29'},{'Outro nome','30'}},.F.,,,'ID')

*/
user function envMail(aTo,cSubject,aHead,aContent,lAuto,_aLado,cBCC, cId)
	
	local oSch		:= nil
	local nX			:= 0
	local cPara		:= ""
	local cBody		:= ""
	local lAuto		:= .F.
	local _lVolta		:= .F.
	local _aLado		:= {}
	
	default lAuto 	:= .F.
	default _aLado 	:= {}
	default cBCC 		:= ""
	default cId		:= Alltrim(StrTran( ProcName(1),'U_','') )
	
	if Empty(cSubject) .OR. Empty(aTo) .OR. Empty(aHead) .OR. Empty(aContent)
		U_autoalert("Todos os parametros são obrigatorios")
		return(.F.)
	elseIf ValType(aTo) <> "A"
		U_autoalert("Destino deve ser um array")
		return(.F.)
	elseIf ValType(aHead) <> "A"
		U_autoalert("Cabeçalho deve ser um array")
		return(.F.)
	elseIf ValType(_aLado) <> "A"
		U_autoalert("Definição de Posições dos Dados deve ser um array")
		return(.F.)
	elseIf Len(_aLado) > 0 .And. Len(_aLado) <> Len(aHead)
		U_autoalert("Quant.de Dados do Cabeçalho X Quant.Dados Posições")
		return(.F.)
	elseIF (ValType(aContent) <> "A")
		U_autoalert("Conteudo deve ser um array")
		return(.F.)
	elseIf ValType(cSubject) <> "C"
		U_autoalert("Assunto deve ser uma String")
		return(.F.)
	endIF

	//Obtem os destinatarios
	if Len(aTo) > 1
		for nX := 1 To Len(aTo)
			if !Empty(aTo[nX])
				cPara += aTo[nX]
				if nX != Len(aTo)
					cPara += ';'
				endIf
			endIF
		next nX
	else
		cPara := aTo[1]
	endIf

	cBody	+= "<table style='width:100%' border=4>"
	cBody += "	<tr>"

	for nB := 1 To Len(aHead)
		cBody += "		<td>"+ aHead[nB] +"</td>"
	next nB
	cBody += "	</tr>"

	//Conteudos
	for nD := 1 To Len(aContent)
		cBody += "	<tr>"
		for nC := 1 To Len(aContent[nD])
			if Empty(aContent[nD][nC])
				aContent[nD][nC] := "-"
			endIF
			if Len(_aLado) > 0
				cBody += "		<td align='"+_aLado[nC]+"'> " + aContent[nD][nC] +"</td>"
			else
				cBody += "		<td>"+ aContent[nD][nC] +"</td>"
			endIf
		next nC
		cBody += "	</tr>"
	next nD
	cBody += "</table>"

	oSch 	:= cbcSchCtrl():newcbcSchCtrl()
	oSch:setIDEnvio(cId)
	oSch:setEmailFrom('wf@cobrecom.com.br')
	oSch:addEmailTo(cPara)
	oSch:addEmailBcc(cBCC)
	oSch:setFIXO('S')
	oSch:setAssunto(cSubject)
	oSch:setSimple(.T.)
	oSch:setBody(cBody)
	oSch:setBodyText('text/html')
		
	if !oSch:schedule():lThisOk
		u_autoalert(oSch:cThisMsg)
		return(.F.)
	endIf
	
	FreeObj(oSch)

return(.T.)

	********************************************
User Function importXLSX(cChave,cCampo,cNovo, lUnico) //U_importXLSX('1010101101I' ,'B1_XPORTAL', 'S')
	********************************************
	//INTEGRAÇÃO EXCEL
	//NO EXCEL UTILIZAR " =Siga("U_importXLSX";ARRUMAR(A2);ARRUMAR(B2);ARRUMAR(C2)) "
	Local cRetorno 	:= ""
	Local oSql 		:= Nil
	Local oBase 	:= Nil
	Local oRet		:= Nil
	Local nX		:= 0
	// ZZZ_FILIAL, ZZZ_TIPO, ZZZ_PROD, ZZZ_BITOLA, ZZZ_ACOND,
	Default cChave 	:= ""
	Default cCampo 	:= ""
	Default cNovo 	:= ""
	Default lUnico	:= .T.

	If ValType(cChave) == 'N'
		cChave := cValToChar(cChave)
	EndIF

	If Empty(cChave) .OR. Empty(cCampo) .OR. Empty(cNovo)
		cRetorno := "Erro - Todos os parametros são obrigatorios"
	Else
		oSql 	:= SqlUtil():newSqlUtil()
		oBase 	:= ManBaseDados():newManBaseDados()

		oSql:addFromTab('SB1')
		oSql:addCampos({'SB1.R_E_C_N_O_','B1_DESC', 'B1_COD'})
		oSql:addWhere("B1_FILIAL = '' ")
		//Tratar apenas o codigo principal 1150504401
		If lUnico
			oSql:addWhere("B1_COD = '" + cChave  +"' ")
		//Tratar derivados do codigo principal 1150504401I / 1150504401B00000 etc...
		Else
			oSql:addWhere("B1_COD LIKE '" + cChave  +"%' ")
		EndIf
		//Realiza a consulra
		If !oSql:QrySelect():lOk
			cRetorno := "Erro - Produto " + cChave + " Descrição: " + Alltrim(oRet[1]:B1_DESC) + " Não encontrado!"
		Else
			oRet := oSql:oRes

			//Tratar apenas o codigo principal 1150504401
			If lUnico
				oBase:addCpoVlr(cCampo,cNovo)
				If !oBase:updTable(oRet[1]:R_E_C_N_O_)
					cRetorno += "Erro - Produto " + Alltrim(oRet[1]:B1_COD) + " Descrição: " + Alltrim(oRet[1]:B1_DESC) + " Não foi atualizado!"
				Else
					cRetorno += "OK - Produto " + Alltrim(oRet[1]:B1_COD) + " Descrição: " + Alltrim(oRet[1]:B1_DESC) +  cCampo + " = " + cNovo + chr(13)
				EndIF
			//Tratar derivados do codigo principal 1150504401I / 1150504401B00000 etc...
			Else
				For nX := 1 To Len(oRet)
					oBase:addCpoVlr(cCampo,cNovo)
					If !oBase:updTable(oRet[nX]:R_E_C_N_O_)
						cRetorno += "Erro - Produto " + Alltrim(oRet[nX]:B1_COD) + " Descrição: " + Alltrim(oRet[nX]:B1_DESC) + " Não foi atualizado!"
						exit
					Else
						cRetorno += "OK - Produto " + Alltrim(oRet[nX]:B1_COD) + " Descrição: " + Alltrim(oRet[nX]:B1_DESC) +  cCampo + " = " + cNovo + chr(13)
					EndIF
				Next
			EndIF
		EndIf

		FreeObj(oSql)
		FreeObj(oBase)
	EndIF

	Return cRetorno

	****************************************
User Function readCSV(cArq)
	****************************************
	/*Função para ler um arquivo (LER CSV) e retornar seu conteudo em um array*/
	Local cLinha  	:= ""
	Local lPrim   	:= .T.
	Local aCampos 	:= {}
	Local aDados 	:= {}
	Default cArq    := "C:\PAGFOR_SEB.csv"

	Private aErro := {}

	If !File(cArq)
		MsgStop("O arquivo " +cArq + " não foi encontrado. A importação será abortada!","[AEST901] - ATENCAO")
		Return
	EndIf

	FT_FUSE(cArq)
	ProcRegua(FT_FLASTREC())
	FT_FGOTOP()
	While !FT_FEOF()

		IncProc("Lendo arquivo ...")

		cLinha := FT_FREADLN()

		If lPrim
			aCampos := Separa(cLinha,";",.T.)
			lPrim := .F.
		Else
			AADD(aDados,Separa(cLinha,";",.T.))
		EndIf

		FT_FSKIP()
	EndDo

	FT_FUSE()
	/*
	DbSelectArea('SEB')
	SEB->(DbSetOrder(1)) //EB_FILIAL,EB_BANCO,EB_REFBAN,EB_TIPO,EB_MOTBAN,

	For nX := 1 To Len(aDados)

	If DbSeek( Space(2) + '237' + Alltrim(aDados[nX][1]) + Space(1) + 'P', .F. )
	RecLock('SEB', .F.)
	SEB->(EB_DESCRI) 	:= Alltrim(Upper(aDados[nX][2]))
	SEB->(MsUnlock())
	Else
	RecLock('SEB', .T.)
	SEB->(EB_BANCO) 	:= '237'
	SEB->(EB_REFBAN)	:= Alltrim(aDados[nX][1])
	SEB->(EB_TIPO)		:= 'P'
	SEB->(EB_OCORR)		:= '03'
	SEB->(EB_DESCRI) 	:= Alltrim(Upper(aDados[nX][2]))
	SEB->(MsUnlock())
	EndIf
	Next nX
	*/

Return aDados
