#Include "PROTHEUS.CH"
#Include "RWMAKE.CH"
#Include "FONT.CH"
#Include "COLORS.CH"
#Include "TOPCONN.CH"
#Define linha chr(13)+chr(10)

//COMPLEMENTA AS FUNÇÔES DO FONTE PE_FINA060 - INCLUSIVE O FILTRO PARA TELA DE SÂO PAULO ESTA NESTE FONTE
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FA60FIL  º Autor ³ Leonardo Bolognesi º Data ³  10/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ P.E. executado no filtro de registros que serão processadosº±±
±±º          ³ para a elaboração do borderô.                              º±±
±±º          ³ O Objetivo é diferenciar os títulos exibidos para geração  º±±
±±º          ³ do borderô pelo Financeiro-Itu e Financeiro-SP(Jackson).   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ IFC - Indústria e Comércio de Condutores Elétricos Ltda.   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FA60FIL()
	Local cRet		:= ".T."
	Local aArea 	:= GetArea()
	Local aAreaSE1  := SE1->(GetArea())

	DbSelectArea("SE1")
	SE1->(DbOrderNickName("BCOSP")) //E1_FILIAL+E1_ZZBC2

	If U_vlsUsrSP()
		//SP
		cRet := "E1_FILIAL== '" + xFilial('SE1') +  "' .AND. EMPTY(E1_NUMBOR) .AND. ( E1_ZZBC2 == '000' .OR. E1_ZZBC2 == 'NNN' )"
	Endif

	RestArea(aArea)
	Restarea(aAreaSE1)

Return cRet

//Retorno logico se usuario pertence ao grupo de São Paulo

User Function vlsUsrSP()
	Local cMVBord1	:= Alltrim(GetMV("MV_ZZBORD1"))	//Grupo de usuários autorizados gerar Borderô títulos do "Banco Jackson"
	Local lSP := .F.


	//Verifica se o usuario faz parte do grupo de usuarios São Paulo
	PswOrder(2)
	lAchou := PSWSeek(cUserName)
	aUserFl := PswRet(1)

	//Percorre todos os grupos do usuario grupo são paulo
	For i := 1 To Len(aUserFl[1][10])
		If aUserFl[1][10][i] == cMVBord1
			lSP := .T.
		EndIf
	Next

	Return lSP

	********************************************
USER FUNCTION F060QRCP()
	********************************************
	//LEONARDO BOLOGNESI  18/12/2014
	//PROBLEMA: QUANDO SP ABRE A TELA DE BORDEROS PELO FILTRO SOMENTE APARECE OS TITULOS
	//QUE ITU TRANFERIU (E1_ZZBC2=='0'), MAS A TELA DE MARCAÇÃO DE TITULOS PARA BORDERO
	// APARECE TODOS OS TITULOS(ITU/SP) E NÃO SOMENTE OS ENVIADOS.
	// O MESMO PODE ACONTECER ITU TAMBEM PREVISTO
	//SOLUÇÃO: POR ESTE PONTO DE ENTRADA PODEMOS OBTER A QUERY ORIGINAL UTILIZADA PARA MONTAR
	//A TELA DE MARCAÇÃO DOS BORDEROS E ALTERAR ESTA QUERY ADICIONANDO A CONDIÇÃO (AND E1_ZZBC2 = '000'")
	//OBS: ESTE PONTO DE ENTRADA PODE SER UTILIZADO PARA INCLUIR CAMPOS DE OUTRAS TABELAS NA TELA DE
	//MARCAÇÃO DO BORDERO
	// AS FUNÇÔES F060QRCP(), F060Trb() e F060COL() (SÂO UTILIZADAS EM CONJUNTO PARA MOSTRAR NO MARKBROWSER CAMPOS DE OUTRAS TABELAS ALEM DA SE1)
	//NESTE CASO PRECISAMOS MOSTRAR A CIDADE DO CLIENTE (A1_MUN), POIS SÂO PAULO UTILIZA COMO CRITERIO A CIDADE PARA COLOCAR EM BANCO. 

	Local aArea		:= GetArea()
	Local aStru 	:= {}
	Local cQuery	:= ""
	Local nj		:= 0
	Local cQryOri	:= PARAMIXB[1] // QUERY PADRÃO SISTEMA
	Local aPBox		:={}
	Local aRet		:={}
	Local aBox		:={}
	Local aRetB		:={}
	Local cMunBco	:=""

	aStru := dbStruct()
	cQuery := "SELECT "


	//PEDE O NUMERO DO BORDERO DE ITU SOMENTE USUARIOS SÂO PAULO
	If U_vlsUsrSP()

		aAdd(aBox,{01,"Nro. Bordero ITU",space(6),"","","","",50,.T.} )
		If ParamBox(aBox,"Informe Nro. Bordero ITU...",@aRetB)

			dEmisDe	 	:= StoD("20120101")
			dVencFim 	:= StoD("20290101")
		EndIF

		If GetMv("MV_PRCBCO")
			//Validar a praça do banco
			If !Empty(aRetB)
				cMunBco := valMunBanco(aRetB[1])
			EndIF
		EndIF

	EndIf

	//BUSCA TODOS OS CAMPOS DA TABELA COMPLETANDO O SELECT ACIMA
	For nj:= 1 to Len(aStru)

		cQuery += aStru[nj,1]+", "

	Next

	//COMEÇA AS CONDIÇÕES DO SELECT
	//cQuery += "SE1.R_E_C_N_O_ RECNO , A1_EST" ORIGINAL PARA INCLUIR CAMPOS DE OUTRAS TABELAS
	cQuery 	+= "SE1.R_E_C_N_O_ RECNO, SA1.A1_MUN"
	cQuery 	+= "  FROM "+	RetSqlName("SE1") + " SE1 "

	//INCLUIR O CAMPO CIDADE(A1_MUN)
	cQuery 	+= "   INNER JOIN  " + RetSqlName('SA1') + " SA1 ON SA1.A1_COD+SA1.A1_LOJA = SE1.E1_CLIENTE+SE1.E1_LOJA"

	cQuery 	+= " WHERE E1_FILIAL Between '" + cFilDe + "' AND '"+ cFilAte + "'"
	cQuery 	+= "   AND E1_NUMBOR = '      '"

	cQuery 	+= "   AND E1_EMISSAO Between '" + DTOS(dEmisDe) + "' AND '" + DTOS(dEmisAte) + "'"
	cQuery 	+= "   AND E1_CLIENTE between '" + cCliDe        + "' AND '" + cCliAte        + "'"
	cQuery 	+= "   AND E1_VENCREA between '" + DTOS(dVencIni)+ "' AND '" + DTOS(dVencFim) + "'"

	cQuery 	+= "   AND E1_MOEDA = "+ str(nmoeda)

	//USUARIO SAO PAULO DESPREZA O FILTRO PREFIXO NUMERO DO TITULO

	cQuery 	+= "   AND E1_PREFIXO Between '" + cPrefDe + "' AND '" + cPrefAte + "'"
	cQuery 	+= "   AND E1_NUM between '"     + cNumDe  + "' AND '" + cNumAte  + "'"


	//cQuery += "   AND ( E1_SALDO > 0  OR E1_OCORREN = '02' ) "
	cQuery 	+= "   AND  E1_SALDO > 0"

	//Seleciona Tipos
	If mv_par12 == 1
		cQuery += "   AND E1_TIPO IN " + FormatIn(cTipos,"/")
	Endif

	If !Empty(MVPROVIS) .Or. !Empty(MVRECANT) .Or. !Empty(MV_CRNEG) .Or. !Empty(MVENVBCOR)
		cQuery += "   AND E1_TIPO NOT IN " + FormatIn(MVPROVIS+"/"+MVRECANT+"/"+MV_CRNEG+"/"+MVENVBCOR,"/")
	Endif

	cQuery += "   AND E1_SITUACA IN ('0','F','G') "

	//VERIFICA SÃO PAULO/ITU
	If U_vlsUsrSP()

		cQuery 	+= "   AND E1_ZZBC2 = '000'"

		If !Empty(aRetB)
			cQuery  += "   AND E1_ZZBOR1 = '" + aRetB[1] + "'"
		EndIf

		//Filtro municipio banco
		If !Empty(cMunBco)

			cQuery += "  AND SE1.R_E_C_N_O_  NOT IN " + FormatIn(cMunBco,"/")

		EndIf

	Else

		cQuery 	+= "   AND E1_ZZBC2 = ''"

	EndIf

	cQuery += "   AND SE1.D_E_L_E_T_ <> '*' "
	cQuery += "   AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY "+ SqlOrder(SE1->(IndexKey()))

	//PARA AVALIAÇÃO CASO NECESSARIO DESMARCAR AS LINHAS ABAIXO PARA VER AS DUAS QUERYS
	//aAdd(aPBox,{11,"ORIGINAL",cQryOri,".T.",".T.",.F.})
	//aAdd(aPBox,{11,"MODIFICADA",cQuery,".T.",".T.",.F.})
	//ParamBox(aPBox,"Comparar querys...",@aRet)

	RestArea(aArea)

	Return cQuery

	********************************************
User Function F060Trb()
	********************************************
	//COMPLEMENTA A QUERY ADICIONANDO CAMPOS DE OUTRAS TABELAS DIFERENTE SE1
	//CONJUNTO COM FUNÇÂO F060QRCP() ACIMA
	Local aArea		:= GetArea()

	Local aStru := PARAMIXB[1]

	//ADICIONAR ESTRUTURA PARA SA1.A1_MUN
	AADD(aStru,{"A1_MUN","C",TAMSX3("A1_MUN")[1],0 })

	RestArea(aArea)

	Return aStru

	********************************************
User Function F060COL()
	********************************************
	//COMPLEMENTA A QUERY ADICIONANDO CAMPOS DE OUTRAS TABELAS DIFERENTE SE1
	//CONJUNTO COM FUNÇÂO F060QRCP() ACIMA
	Local aArea		:= GetArea()
	Local aCpo		:= ParamIxb[1]
	Local aRet		:= {}

	//"E1_FILIAL/E1_CHAVE/E1_PREFIXO/E1_NUM/E1_PARCELA/E1_TIPO/E1_NATUREZ/E1_CLIENTE/E1_LOJA/E1_NOMCLI/A1_MUN/E1_EMISSAO/E1_VENCTO/E1_VENCREA/E1_VALOR"

	Aadd(aRet,  aCpo[  aScan(aCpo,{|x| Alltrim(x[1]) == "E1_OK" } )   ]   ) 
	Aadd(aRet,  aCpo[  aScan(aCpo,{|x| Alltrim(x[1]) == "E1_FILIAL" } )   ]   )
	Aadd(aRet,  aCpo[  aScan(aCpo,{|x| Alltrim(x[1]) == "E1_CHAVE" } )   ]   )
	Aadd(aRet,  aCpo[  aScan(aCpo,{|x| Alltrim(x[1]) == "E1_PREFIXO" } )   ]   )
	Aadd(aRet,  aCpo[  aScan(aCpo,{|x| Alltrim(x[1]) == "E1_NUM" } )   ]   )
	Aadd(aRet,  aCpo[  aScan(aCpo,{|x| Alltrim(x[1]) == "E1_PARCELA" } )   ]   )
	Aadd(aRet,  aCpo[  aScan(aCpo,{|x| Alltrim(x[1]) == "E1_TIPO" } )   ]   )
	Aadd(aRet,  aCpo[  aScan(aCpo,{|x| Alltrim(x[1]) == "E1_NATUREZ" } )   ]   )
	Aadd(aRet,  aCpo[  aScan(aCpo,{|x| Alltrim(x[1]) == "E1_CLIENTE" } )   ]   )
	Aadd(aRet,  aCpo[  aScan(aCpo,{|x| Alltrim(x[1]) == "E1_LOJA" } )   ]   )
	Aadd(aRet,  aCpo[  aScan(aCpo,{|x| Alltrim(x[1]) == "E1_NOMCLI" } )   ]   )
	Aadd(aRet,  {"A1_MUN"," " ,"Cidade", " " } ) ////INCLUIR O CAMPO CIDADE(A1_MUN)
	Aadd(aRet,  aCpo[  aScan(aCpo,{|x| Alltrim(x[1]) == "E1_EMISSAO" } )   ]   )
	Aadd(aRet,  aCpo[  aScan(aCpo,{|x| Alltrim(x[1]) == "E1_VENCTO" } )   ]   )
	Aadd(aRet,  aCpo[  aScan(aCpo,{|x| Alltrim(x[1]) == "E1_VENCREA" } )   ]   )
	Aadd(aRet,  aCpo[  aScan(aCpo,{|x| Alltrim(x[1]) == "E1_VALOR" } )   ]   )

	RestArea(aArea)
Return aRet

User Function F150EXC
	//PONTO ENTRADA PARA TESTAR, OCORRE NA CRIAÇÃO DO ARQUIVO CNAB , E PERMITE VALIDAR QUAIS TITULOS DO BORDERO SELECIONADO
	//DEVERA FAZER PARTE DO ARQUIVO REM, MAIS UMA VEZ SOMENTE OS TITULOS COM CAMPO (E1_ZZBC2 = '000')
	//EVITANDO QUE SÃO PAULO ESCOLHA UM NUMERO DE BORDERO DE ITU E GERE O CNAB ERRADO
	//UTILIZAR TAMBEM PARA EVITAR QUE ITU UTILIZE NUMERO BORDERO SP PARA GERAR CNABS COM TITULOS TRANFERIDOS SP
	//CHAMA ESTE PONTO DE ENTRADA PARA CADA TITULO DO BORDERO VALIDAÇÂO INDIVIDUAL, DESTA FORMA EM CADA CHAMADA
	//ESTA POSICIONADO NO TITULO QUE DEVEMOS VALIDAR

	Local aArea	:= GetArea()
	Local lRet 	:= .T.

	//VERIFICA USUARIO SÂO PAULO
	If U_vlsUsrSP()


		//SÃO PAULO NÃO PODE GERAR CNAB COM TITULOS NÃO TRANFERIDOS SP
		If Alltrim(SE1->(E1_ZZBC2)) != '000'

			lRet := .F.

		EndIf

	Else

		//ITU NÃO PODE GERAR CNAB COM TITULO TRANFERIDOS SP
		If Alltrim(SE1->(E1_ZZBC2)) == '000'

			lRet := .F.

		EndIf

	EndIF

	RestArea(aArea)
	Return lRet

	********************************************
Static Function valMunBanco(cZZBOR1)
	********************************************
	Local cSQL 	:= ""                                  
	Local lTemAviso	:= .F.
	Local aPBox		:={}
	Local aRet		:={}
	Local cTit		:=""
	Local cVolta	:=""
	Local lPrim		:= .F.
	Local cNomeBco	:=""

	DbSelectArea("ZAC")
	ZAC->(DbOrderNickName("CODMUN"))

	//Fechar e excluir arquivo de trabalho
	If Select( "TRBMUN") > 0
		TRBMUN->(dbcloseArea())
		FErase( "TRBMUN" + GetDbExtension())
	End If

	cSQL += " AND E1_ZZBOR1 = '" + cZZbor1 + "'"
	cSQL += "   AND E1_NUMBOR = '      '"
	cSQL := "%"+cSQL+"%"

	//Consulta no banco
	BeginSQL Alias "TRBMUN"

	SELECT 	SE1.R_E_C_N_O_,
	(SE1.E1_PREFIXO + SE1.E1_NUM) AS NUM, 
	SE1.E1_NOMCLI,
	SE1.E1_VALOR, 
	SE1.E1_PORTADO, 
	SA1.A1_MUN,
	SA1.A1_EST
	FROM %Table:SE1% SE1
	INNER JOIN %Table:SA1% SA1 ON SA1.A1_COD+SA1.A1_LOJA = SE1.E1_CLIENTE+SE1.E1_LOJA

	WHERE 	SE1.E1_FILIAL = %xFilial:SE1% 
	AND SE1.%NotDel% 
	AND SA1.%NotDel% %exp:cSQL%

	ORDER BY %Order:SE1,1%

	EndSql

	DbSelectArea("TRBMUN")
	TRBMUN->(DbGotop())

	While TRBMUN->(!Eof())

		If lPrim
			cVolta += "/"
		EndIf

		//Procura ZAC Portador no Municipio do cliente
		If ZAC->(!DbSeek(xFilial("ZAC")+PADR(Alltrim(cPort060),TamSX3("ZAC_COD")[1] ) + PADR(TRBMUN->(A1_MUN),TamSX3("ZAC_MUN")[1] ) ,.F.) )

			cTit += "Titulo: " + Alltrim(TRBMUN->(NUM)) + " Cliente:" +Alltrim(TRBMUN->(E1_NOMCLI)) + " Valor: " +;
			Alltrim(cValToChar(TRBMUN->(E1_VALOR))) +" Cidade: "+Alltrim(TRBMUN->(A1_MUN)) + " UF: " +Alltrim(TRBMUN->(A1_EST)) +  linha + linha

			//Adiciona os recnos dos titulos que não tem banco
			cVolta += cValToChar(TRBMUN->(R_E_C_N_O_))  

			lTemAviso 	:= .T.
			lPrim		:= .T.
		EndIf

		TRBMUN->(DbSkip())

	EndDo

	If lTemAviso

		cNomeBco	:= Alltrim( Posicione( "ZAD",1,xFilial("ZAD")+PADR(Alltrim(cPort060),TamSX3("ZAD_COD")[1] ) ,"ZAD_NOME" ) )

		MessageBox("[AVISO]-NESTE BORDERO, EXISTE(M) TITULO(S) PARA CLIENTES CUJA CIDADE"+ linha +;
		" NÃO DISPOE DE AGENCIA BANCARIA PARA " + cNomeBco + linha +;
		" FAVOR CONSULTAR A ROTINA DE PRAÇAS BANCARIAS","Aviso",48)

		aAdd(aPBox,{11,"TITULOS",cTit,".T.",".T.",.F.})
		ParamBox(aPBox,"NÂO EXISTE BANCO NA CIDADE DO CLIENTE...",@aRet)

		If MsgNoYes("[AVISO]-MANTER OS TITULOS PARA SELEÇÂO, MESMO SEM BANCO NA CIDADE?  ","Pergunta")

			cVolta :=""

		EndIf

	EndIf

	If Select( "TRBMUN") > 0
		TRBMUN->(dbcloseArea())
		FErase( "TRBMUN" + GetDbExtension())
	End If


Return cVolta    


/*
ROTINA PARA GERAR RELATORIO BX_SUBSTITUIR, NESTE PONTO DE ENTRADA AO REALIZARMOS
A TRANFERENCIA DE UM TITULO PARA CARTEIRA DEVEMOS PRESERVAR A INFORMAÇÕES DO PORTADO
POIS ESSA INFORMAÇÃO DEVE APARECER NO RELATORIO
*/
User Function F060ACT()
	Local aArea		:= Getarea()
	Local aE1Area	:= SE1->(Getarea())
	Local aDados 	:= PARAMIXB[1]

	//aDados[6] 	= Cliente 	+ Loja 		+ Nome
	//aDados[7] 	= Prefixo 	+ Num 		+ Loja  
	//aDados[10] 	= Banco 	+ Agencia	+ Conta	+ Nome Banco  
	// SE1 VEM POSICIONADO NO TITULOS	 

	SE1->(RecLock("SE1",.F.))
	SE1->E1_HIST := aDados[10] 
	SE1->(MsUnLock())

	RestArea(aArea)
	RestArea(aE1Area)

Return Nil