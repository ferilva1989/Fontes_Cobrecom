#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"

/*
OBJETIVO DE GRAVAR  OS CAMPOS:
E1(ZZBXDB,ZZOPER,ZZHISTBX,ZZDTREL) DOS TITULOS ANTIGOS
E TAMBEM DA FATURA NOVA POSSIBILITANDO A GERAÇÃO DO RELATORIO
*/
*************************
User Function FA280
	*************************
	//AQUI TEMOS O SE1 POSICIONADO NO TITULO QUE ESTA SENDO GERADO A FATURA
	//PONTO CHAMADO PARA TODAS AS PARCELAS DA FATURA
	Local aArea		:= Getarea()
	Local aE1Area	:= SE1->(Getarea())

	If GetGlbvalue("_cNumrel") != "NOTREL"
		SE1->(RecLock("SE1",.F.))
		SE1->E1_ZZBXDB	:= GetGlbvalue("_cNumrel")
		SE1->E1_ZZOPER	:= 'SUBSTITUIR'
		SE1->E1_ZZHISBX	:= SE1->(E1_HIST)
		SE1->E1_ZZDTREL := dDataBase
		SE1->(MsUnLock())
	EndIf

	RestArea(aArea)
	RestArea(aE1Area)
	Return Nil

	/*
	TRATAMENTOS NOS TITULOS QUE ORIGINARAM A FATURA
	EXECUTADO ANTES FA280
	ESTA POSICIONADO NO SE1 DO TITULO ANTIGO
	*/
	*************************************
User Function F280ORI
	*************************************
	Local aArea		:= Getarea()
	Local aE1Area	:= SE1->(Getarea())

	If GetGlbvalue("_cNumrel") != "NOTREL"
		SE1->(RecLock("SE1",.F.))
		SE1->E1_ZZBXDB	:= GetGlbvalue("_cNumrel")
		SE1->E1_ZZOPER	:= 'BAIXAR'
		SE1->E1_ZZHISBX	:= SE1->(E1_HIST)
		SE1->E1_ZZDTREL := dDataBase
		SE1->(MsUnLock())
	EndIf

	RestArea(aArea)
	RestArea(aE1Area)
	Return Nil


	/*
	USADO PARA CRIAR UMA VARIAVEL GLOBAL DISPONIVEL DURANTE TODO PROCESSO
	DO NUMERO DO RELATORIO OBTIDO POR MEIOS SXE/SXF
	*/
	***********************
User Function F280PRE
	***********************
	Local cRel
	Local aHead
	Local aContent

	If Empty(GetGlbvalue("_cNumrel"))

		If MsgYesNo(" <html><b>[!! ATENCAO !!] </b> DESEJA EMITIR O RELATORIO DE BAIXAR E SUBSTITUIR ? </html>")

			cRel := GetSXENum("SE1","E1_ZZBXDB","01SE1010")

			//DECLAREI UMA VARIAVEI GLOBAL DE FORMA A FICAR DISPONIVEL EM NIVEIS ACIMA
			//PARA QUANDO CHAMAR O PONTO FA280 ELA ESTEJA VISIVEL
			PutGlbValue('_cNumrel' , cRel )
			ConfirmSX8()

		Else

			PutGlbValue('_cNumrel' , "NOTREL" )                                       

		EndIf

	ElseIf GetGlbvalue("_cNumrel") != "NOTREL"  

		sqlTitulo()
		If NOVO->(!EOF())
			aHead 	 := montaHead()
			aContent := montaContent()
			//ENVIAR EMAIL PARA QUE POSSAM IMPRIMIR O RELATORIO
			u_envmail({"andrei@cobrecom.com.br","vania@cobrecom.com.br"}, "[Relatorio N." + GetGlbvalue("_cNumrel") + "]  (Baixar e Substituir)",aHead,aContent)
			ClearGlbValue("_cNumrel")
		Else
			Alert('Rotina cancelada, por favor reinicie o processo para gerar a fatura')
			ClearGlbValue("_cNumrel")
		EndIf

	Else

		ClearGlbValue("_cNumrel")

	EndIf

	If Select( "ANTIGO") > 0
		ANTIGO->(dbcloseArea())
		FErase( "ANTIGO" + GetDbExtension())
	EndIf

	If Select( "NOVO") > 0
		NOVO->(dbcloseArea())
		FErase( "NOVO" + GetDbExtension())
	End If

	Return Nil


	*********************************
Static Function montaContent()
	*********************************

	Local aRet 		:= {}
	Local nTotAnt	:= 0
	Local nTotNov	:= 0

	//ADICIONA TITULOS ANTIGOS
	While ANTIGO->(!Eof())

		Aadd( aRet, { 	Alltrim(ANTIGO->(E1_NOMCLI))			,;
		Alltrim(Dtoc(StoD(ANTIGO->(E1_EMISSAO))))				,;
		Alltrim(ANTIGO->(E1_NUM))								,;
		Alltrim(ANTIGO->(E1_PARCELA))							,;
		"R$ "+Transform(ANTIGO->(E1_VALOR), "@E 99,999,999.99")	,;
		Alltrim(DtoC(StoD(ANTIGO->(E1_VENCTO))))				,;
		Alltrim(ANTIGO->(E1_ZZOPER))							,;
		Alltrim(ANTIGO->(E1_ZZHISBX)) 							} )

		nTotAnt += ANTIGO->(E1_VALOR) 
		ANTIGO->(DbSkip())

	EndDo

	//LANÇA CONTA CORRENTE
	lctoCt2(nTotAnt)

	//ADICIONA LINHA DO TOTAL
	Aadd( aRet, { "","","","TOTAL","R$ "+Transform(nTotAnt, "@E 99,999,999.99"),"","","" } )
	//ADICIONA LINHA EM BRANCO
	Aadd( aRet, { "","","","","","","",""} )

	//ADICIONA TITULOS NOVOS

	While NOVO->(!Eof())

		Aadd( aRet, { 	Alltrim(NOVO->(E1_NOMCLI))		,;
		Alltrim(Dtoc(Stod(NOVO->(E1_EMISSAO))))			,;
		Alltrim(NOVO->(E1_NUM))							,;
		Alltrim(NOVO->(E1_PARCELA))						,;
		"R$ "+Transform(NOVO->(E1_VALOR), "@E 99,999,999.99")	,;
		Alltrim(DtoC(Stod(NOVO->(E1_VENCTO))))			,;
		Alltrim(NOVO->(E1_ZZOPER))						,;
		Alltrim(NOVO->(E1_ZZHISBX)) 					} )

		nTotNov += NOVO->(E1_VALOR) 

		NOVO->(DbSkip())
	EndDo

	//ADICIONA LINHA DO TOTAL
	Aadd( aRet, { "","","","TOTAL","R$ "+Transform(nTotNov, "@E 99,999,999.99"),"","","" } )


	Return aRet

	******************************
Static Function lctoCt2(nTotAnt)
	******************************
	Local aItens 		:= {}
	Local aCab			:= {}
	Local nBord			:= GetGlbvalue("_cNumrel")
	
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.
	
	Begin Transaction

		//Adiciona os itens no array para lançamento
		aAdd(aItens,{  	{'CT2_FILIAL'  	,XFilial("SE1")   						, NIL},;
		{'CT2_LINHA'	, StrZero(1,3) 									, NIL},;
		{'CT2_MOEDLC'  	,'01'   										, NIL},;
		{'CT2_DC'   	,'3'   											, NIL},;
		{'CT2_DEBITO'  	,'DEB' 										, NIL},;
		{'CT2_CREDIT'  	,'CRE' 										, NIL},;
		{'CT2_VALOR'  	, nTotAnt  									, NIL},;
		{'CT2_ORIGEM' 	,'CTBBXDEBITA'								, NIL},;
		{'CT2_HP'   	,''   												, NIL},;
		{'CT2_EMPORI'   ,'01'   											, NIL},;
		{'CT2_FILORI'   ,XFilial("SE1")   								, NIL},;
		{'CT2_TPSALD'   ,'6'   											, NIL},;
		{'CT2_CLVLCR'   ,'1101'   										, NIL},;
		{'CT2_HIST'   	,'ESTORNO BAIXA/SUBST REF. REL. NRO. ' + nBord			, NIL} } )


		//Cria o cabeçalho para o lançamento
		aCab := { 	{'DDATALANC' 	,dDataBase 	,NIL},;
		{'CLOTE' 		,"028850" 	,NIL},;
		{'CSUBLOTE' 	,'001' 		,NIL},;
		{'CDOC' 		, nBord 	,NIL},;
		{'CPADRAO' 		,'' 		,NIL},;
		{'NTOTINF' 		,0 			,NIL},;
		{'NTOTINFLOT' 	,0 			,NIL} }


		//TERCEIRO PARAMETRO DO CTBAL102
		//1=PESQUISA
		//2=VISUALIZAÇÃO
		//3=INCLUSÃO
		//4=ALTERAÇÃO
		//5=EXCLUSÃO

		MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)

		If lMsErroAuto 
			DisarmTransaction()
			MOSTRAERRO()    
		EndIF

	End Transaction

	Return Nil

	*******************************
Static Function montaHead()
	*******************************
	Local aRet := {}

	Aadd(aRet,"NOME")
	Aadd(aRet,"EMISSAO")
	Aadd(aRet,"NUM")
	Aadd(aRet,"PARCELA")
	Aadd(aRet,"VALOR")
	Aadd(aRet,"VENCTO")
	Aadd(aRet,"OPERACAO")
	Aadd(aRet,"HISTORICO")

	Return aRet

	********************************
Static Function sqlTitulo()
	********************************
	Local cSQL 	:= ""
	Local cSQL1 := ""

	//FECHAR CASO EXISTA
	If Select( "ANTIGO") > 0
		ANTIGO->(dbcloseArea())
		FErase( "ANTIGO" + GetDbExtension())
	End If

	//FECHAR CASO EXISTA
	If Select( "NOVO") > 0
		NOVO->(dbcloseArea())
		FErase( "NOVO" + GetDbExtension())
	End If

	//WHERE DOS TITULOS ANTIGOS
	cSQL += "AND SE1.E1_ZZOPER = 'BAIXAR' AND  SE1.E1_ZZBXDB ='" + AllTrim(GetGlbvalue("_cNumrel")) + "'"
	cSQL += "AND SE1.E1_BAIXA <> '' "
	cSQL := "%"+cSQL+"%"


	//WHERE DOS TITULOS NOVOS
	cSQL1 += "AND SE1.E1_ZZOPER = 'SUBSTITUIR' AND  SE1.E1_ZZBXDB ='" + AllTrim(GetGlbvalue("_cNumrel")) + "'"
	cSQL1 += "AND SE1.E1_BAIXA = '' "
	cSQL1 := "%"+cSQL1+"%"


	//CONSULTA
	BeginSQL Alias "ANTIGO"

	SELECT	SE1.E1_NOMCLI,SE1.E1_EMISSAO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_VALOR,
	SE1.E1_VENCTO, SE1.E1_ZZOPER ,SE1.E1_ZZHISBX

	FROM %table:SE1% SE1

	WHERE SE1.%NotDel%  %Exp:cSQL%
	ORDER BY SE1.E1_VENCTO

	EndSql


	BeginSQL Alias "NOVO"

	SELECT	SE1.E1_NOMCLI,SE1.E1_EMISSAO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_VALOR,
	SE1.E1_VENCTO, SE1.E1_ZZOPER ,SE1.E1_ZZHISBX

	FROM %table:SE1% SE1

	WHERE SE1.%NotDel%  %Exp:cSQL1%
	ORDER BY SE1.E1_VENCTO

	EndSql

	DbSelectArea("ANTIGO")
	ANTIGO->(DbGotop())
	DbSelectArea("NOVO")
	NOVO->(DbGotop())

Return Nil    
/*
User Function FA470CTA
local aRet := {} 
local aVem := PARAMIXB[1]   

aadd(aRet,"237")
aadd(aRet,"0328")
aadd(aRet,"59808-9")       

Alert("Eu")

return aRet
*/