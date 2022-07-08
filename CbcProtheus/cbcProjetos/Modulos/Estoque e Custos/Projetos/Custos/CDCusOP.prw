#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'TOPCONN.ch'

/*/{Protheus.doc} CDCusOP
//TODO Função que tem a finalidade de identificar todas as produções de 
		um periodo e analisar custo arbitrado para acerto das movimentações.
@author juliana.leme
@since 24/08/2017
@version 1.0

@type function
/*/
user function CDCusOP() //U_CDCusOP()
	Local _lSai 	:= .F.
	Local aParamBox := {}
	Private aRet    := {}

	aAdd(aParamBox,{1,"Da O.P.    ",Space(11)		,""	,""	,"SC2"	,""	,070,.F.})
	aAdd(aParamBox,{1,"Até a O.P. ",Space(11)		,""	,""	,"SC2"	,""	,070,.F.})
	aAdd(aParamBox,{1,"Data de    ",Ctod("  /  /  "),"@E","",""		,""	,045,.F.})
	aAdd(aParamBox,{1,"Data ate   ",Ctod("  /  /  "),"@E","",""		,""	,045,.F.})
	aAdd(aParamBox,{1,"Doc.Num.   ",Space(8)		,""	,""	,""		,""	,067,.F.})
		
	Do While .T.
		If !ParamBox(aParamBox, "Processamento", @aRet)
			_lSai := .T.
			Exit
		EndIf
		
		If Empty(aRet[3]) .or. Empty(aRet[4]) // Não pode ser de Vazio
			Alert("Informar Corretamente os Parâmetros 'DATA'")
		ElseIf GetMV("MV_DBLQMOV") >= aRet[4] .or. GetMV("MV_ULMES") >= aRet[4]
			Alert("Acertar Parametros de Estoques MV_ULMES/MV_DBLMOV")
		Else
			Exit
		EndIf
	EndDo
	
	If _lSai
		Return(.F.)
	Else
		Processa( {|| U_ProcCus()}, "Analisando Dados", "Aguarde...", .F.)
	EndIf
	
return

/*/{Protheus.doc} ProcCus
//TODO Main que inicia a analise de processo do custo.
@author juliana.leme
@since 24/08/2017
@version 1.0

@type function
/*/
User Function ProcCus()
	Local 	cQury	:= ""
	
	cDoc := IIf(Empty(Alltrim(aRet[3])),"CUS"+Substr(DtoS(aRet[3]),5,2)+Substr(DtoS(aRet[3]),3,2),aRet[3])
	
	cQury := "SELECT  D3_FILIAL, "+;
					" D3_DOC, "+;
					" D3_EMISSAO, "+;
					" D3_CF, "+;
					" D3_COD, "+;
					" D3_QUANT, "+;
					" D3_CUSTO1, "+;
					" D3_OP, "+;
					" D3_LOCAL, "+;
					" ROUND(D3_CUSTO1/D3_QUANT,4) AS MOV_CM1, "+;
					" ISNULL(DQ_CM1,D3_CUSTO1/D3_QUANT) AS ARB_CM1, "+;
					" D3_CUSTO1 - (ISNULL(DQ_CM1,D3_CUSTO1/D3_QUANT) * D3_QUANT) DIF_CUST "+; 
				" FROM SD3010 "+;
					" LEFT JOIN SDQ010  ON "+;
						" DQ_FILIAL = D3_FILIAL "+;
						" AND DQ_COD = D3_COD "+;
						" AND DQ_LOCAL = D3_LOCAL "+;
				" WHERE D3_FILIAL = '" + cFilAnt + "'" +;
					" AND D3_CF = 'PR0' "+;
					" AND D3_EMISSAO BETWEEN '" + DtoS(aRet[3]) + "' AND '" + DtoS(aRet[4]) + "' "+;
					" AND DQ_DATA BETWEEN '" + DtoS(aRet[3]) + "' AND '" + DtoS(aRet[4]) + "' "+;
					" AND D3_OP BETWEEN '" + aRet[1] + "' AND '" + aRet[2] + "' "+;
					" AND D3_CUSTO1/D3_QUANT <> ISNULL(DQ_CM1,D3_CUSTO1/D3_QUANT) "+;
					" AND D3_ESTORNO <> 'S' "+;
					" AND SD3010.D_E_L_E_T_ = '' "+;
					" AND SDQ010.D_E_L_E_T_ = '' "+;
				" ORDER BY D3_FILIAL, D3_EMISSAO, D3_DOC "
	
	IncProc("Aguarde, Carregando Dados ...")
	cQury := ChangeQuery(cQury)
	
	If Select("TRBCUSOP")>0
		DbSelectArea("TRBCUSOP")
		DbCloseArea()
	EndIf

	TCQUERY cQury NEW ALIAS "TRBCUSOP"

	DbSelectArea("TRBCUSOP")
	DbGotop()
	
	//ProcRegua()
	Do While TRBCUSOP->(!Eof())	
		IncProc("Processando dia : " + DtoC(StoD(TRBCUSOP->D3_EMISSAO)) + " ... Aguarde")
		
		If TRBCUSOP->DIF_CUST > 0
			//Devolver Custo (Subtrai)
			CBCMat240(3,"011",cDoc)
		ElseIf TRBCUSOP->DIF_CUST < 0
			//Requisita Custo (Soma)
			CBCMat240(3,"518",cDoc)
		EndIf
		
		TRBCUSOP->(DbSkip())
	EndDo
	
Return

/*/{Protheus.doc} CBCMat240
//TODO Descrição auto-gerada.
@author juliana.leme
@since 24/08/2017
@version 1.0
@param nMyOpcao, numeric, descricao
@param cMyTM, characters, descricao
@param cDoc, characters, descricao
@type function
/*/
Static Function CBCMat240( nMyOpcao,cMyTM,cDoc )
	Local	aItens		:= {}
	Local	cHist		:= ""
	Local	lMsErroAuto	:= .F.
	Local	dDataOP, _dDataOP := ""
	Local	oApp_Ori	:= oApp
	
	cHist := "ACERTO VALOR CONF. CUSTO SDQ"
	Alert(cDoc)
	
	//Libera OP Encerrada
	dDataOP := Posicione("SC2",1,xFilial("SC2")+TRBCUSOP->D3_OP,"C2_DATRF")
	If ! Empty(dDataOP)
		RecLock("SC2",.F.)
		SC2->C2_DATRF := StoD(" ")
		MsUnLock()
	EndIf
		
	aItens 	:= {{"D3_TM"		,Padr(cMyTM,TamSX3("D3_TM")[1])	 									,NIL},; //TP.MOVIM.
				{"D3_COD" 		,Padr("COMP_VALOR",TamSX3("D3_COD")[1])								,NIL},; //D3_COD
				{"D3_DOC"		,Padr(Alltrim(cDoc),TamSX3("D3_DOC")[1])							,NIL},; //TP.MOVIM.
				{"D3_UM" 		,Posicione("SB1",1,xFilial("SB1")+Alltrim("COMP_VALOR"),"B1_UM")	,NIL},;
				{"D3_LOCAL" 	,"99"																,NIL},;
				{"D3_QUANT" 	,0																	,NIL},;
				{"D3_HIST" 		,Padr(cHist,TamSX3("D3_HIST")[1])						  			,NIL},;
				{"D3_OP" 		,Alltrim(TRBCUSOP->D3_OP)							  				,NIL},;
				{"D3_EMISSAO" 	,StoD(TRBCUSOP->D3_EMISSAO)								  	  		,NIL},;	
				{"D3_CUSTO1" 	,Round(ABS(TRBCUSOP->DIF_CUST),4)					  	   			,NIL},;
				{"D3_PARCTOT" 	,Padr("P",TamSX3("D3_PARCTOT")[1])						   			,NIL}}

	lMsErroAuto	:= .F.
	
	RPCSetType(3)
	RPCSetEnv('01',xFilial("SD3"),,,'EST',GetEnvServer(),{} )
	MSExecAuto({|x,y| mata240(x,y)},aItens,nMyOpcao)
	
	If lMsErroAuto
		MostraErro()
	Else
		//Libera OP Encerrada
		_dDataOP := Posicione("SC2",1,xFilial("SC2")+TRBCUSOP->D3_OP,"C2_DATRF")
		RecLock("SC2",.F.)
		SC2->C2_DATRF := dDataOP
		MsUnLock()
	EndIf
	oApp 		:= oApp_Ori
Return