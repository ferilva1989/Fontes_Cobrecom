#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} MA330TRB
//TODO Descrição auto-gerada.
@author alexandre.madeira
@since 07/12/2018
@version 1.0
@type function
@description O Ponto de entrada e executado após a gravação de todas as partes do arquivo de trabalho 
que serão utilizadas na rotina de recalculo do custo medio, este ponto tem como objetivo a manipulacao deste arquivo antes do processamento.
/*/
User Function MA330TRB()
	Local oFWMsExcel
    Local oExcel
    Local nTotRec		:= 0
    Local nAtuRec		:= 0
    Local cArquivo		:= GetTempPath()+'TRB_ORDEM_CM.xml'
	Local lExpTrb		:= GetNewPar('ZZ_EXCMTRB', .F.)
	Local aArea			:= GetArea()
	
	If lExpTrb
		oFWMsExcel := FWMSExcel():New()
     
		oFWMsExcel:AddworkSheet("TRB") //Não utilizar número junto com sinal de menos. Ex.: 1-
        //Criando a Tabela
        oFWMsExcel:AddTable("TRB","TRB Custo")
	        //Criando Colunas
	        oFWMsExcel:AddColumn("TRB","TRB Custo","FILTRA",1) //1 = Modo Texto
	        oFWMsExcel:AddColumn("TRB","TRB Custo","USATRA",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","Alias",1) //1 = Modo Texto
	        oFWMsExcel:AddColumn("TRB","TRB Custo","RECNO",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","ORDEM",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","CHAVE",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","NIVEL",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","NIVSD3",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","COD",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","DTBASE",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","OP",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","CF",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","SEQ",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","SEQPRO",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","DTORIG",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","RECSD1",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","TES",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","DOC",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","TIPO",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","LOCAL",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","RECSBD",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","RECTRB",1)
	        oFWMsExcel:AddColumn("TRB","TRB Custo","TIPONF",1)
	EndIf
	
	dbSelectArea("TRB")
	nTotRec:=LastRec()
	dbSelectArea("TRB")
	Procregua(nTotRec)
	TRB->(dbGoTop())
	Do While TRB->(!Eof())
		nAtuRec++		
		IncProc('Ajustando Sequencia: '+StrZero(nAtuRec,6)+' de '+StrZero(nTotRec,6))	
		//Exportar TRB
		If lExpTrb
			oFWMsExcel:AddRow("TRB","TRB Custo",{;	
													TRB->TRB_FILTRA,;
													TRB->TRB_USATRA,;
													TRB->TRB_ALIAS,;
													TRB->TRB_RECNO,;
													TRB->TRB_ORDEM,;
													TRB->TRB_CHAVE,;
													TRB->TRB_NIVEL,;
													TRB->TRB_NIVSD3,;
													TRB->TRB_COD,;
													TRB->TRB_DTBASE,;
													TRB->TRB_OP,;
													TRB->TRB_CF,;
													TRB->TRB_SEQ,;
													TRB->TRB_SEQPRO,;
													TRB->TRB_DTORIG,;
													TRB->TRB_RECSD1,;
													TRB->TRB_TES,;
													TRB->TRB_DOC,;
													TRB->TRB_TIPO,;
													TRB->TRB_LOCAL,;
													TRB->TRB_RECSBD,;
													TRB->TRB_RECTRB,;
													TRB->TRB_TIPONF;
													})
		EndIf				
		
		If AllTrim(TRB->TRB_ALIAS) == "SD2" .And. AllTrim(TRB->TRB_ORDEM) == "300"
			/*RecLock("TRB",.F.)
				TRB->TRB_NIVEL	:= "99w"
			MsUnlock()*/
		ElseIf AllTrim(TRB->TRB_ALIAS) == "SD3" .And. AllTrim(TRB->TRB_ORDEM) == "300" .And. AllTrim(TRB->TRB_NIVEL) == "w" .And. AllTrim(TRB->TRB_CF) == "RE4"
			RecLock("TRB",.F.)
				TRB->TRB_NIVEL	:= "99w"
			MsUnlock()
		Endif			
		//Pulando Registro
		TRB->(DbSkip())                             
	EndDo
	
	//Esportar TRB
	If lExpTrb
		//Ativando o arquivo e gerando o xml
	    oFWMsExcel:Activate()
	    oFWMsExcel:GetXMLFile(cArquivo)
	    
	     //Abrindo o excel e abrindo o arquivo xml
	    oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
	    oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
	    oExcel:SetVisible(.T.)                 //Visualiza a planilha
	    oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas
     EndIf
     	
	dbSelectArea("TRB")
	TRB->(dbGoTop())	
	RestArea(aArea)	
Return (Nil)





/*/{Protheus.doc} MA330TRF
//TODO Descrição auto-gerada.
@author alexandre.madeira
@since 07/12/2018
@version 1.0
@type function
@description O ponto de entrada será executado somente quando a função A330RecTrf() 
não encontrar a NF/Remito de origem no vetor aListaTrf.
/*/
User Function MA330TRF()
	Local aCust      := PARAMIXB[1] // Vetor original com os custos apurados
	Local cFilAtu    := PARAMIXB[2] // Filial que esta sendo processada
	Local cFilTrf    := PARAMIXB[3] // Filial de transferencia
	Local cProduto   := PARAMIXB[4] // Código do produto
	Local nRecno     := PARAMIXB[5] // RECNO do alias (SD1)
	Local lUsaFifo   := PARAMIXB[6] // Indica se esta processando custo FIFO
	Local aAreaAnt 	 := GETAREA()
	local lFixTrCm	 := GetNewPar('ZZ_FIXTRCM', .T.) //.T. - Corrigir Custo de Transferência
	
	
	// -- Dimensoes do vetor aRet (PARAMIXB[1])
	// -- aCust { {aCM}, {aFifo}, {aParte} } onde:
	// -- aCM    = vetor com os custos medios
	// -- aFifo  = vetor com os custos FIFO (se parâmetro lUsaFifo == .T.)
	// -- aParte = vetor com os custos em partes
	// Rotina criada pelo usuario para manipular o vetor contendo os custos
	// Exemplo: Localizar notas de saída (remito) de transferencias que ocorreram 
	// em periodos já fechados
	//aRet := RemitoOri(aRet, cFilAtu, cFilTrf, cProduto, nRecno, lUsaFifo)
	if lFixTrCm .and. !empty(aCust)
		fixTrCm(@aCust, cFilAtu, cFilTrf, cProduto, nRecno, lUsaFifo)
	endif
	RESTAREA(aAreaAnt)
Return (aCust)




/*/{Protheus.doc} fixTrCm
//TODO Descrição auto-gerada.
@author alexandre.madeira
@since 07/12/2018
@version 1.0
@param aCust, array, descricao
@param cFilAtu, characters, descricao
@param cFilTrf, characters, descricao
@param cProduto, characters, descricao
@param nRecno, numeric, descricao
@param lUsaFifo, logical, descricao
@type function
@description Localiza o custo da NF de saída na Filial de Origem 
e assume o CM na Entrada da Filial de Destino.
/*/
static function fixTrCm(aCust, cFilAtu, cFilTrf, cProduto, nRecno, lUsaFifo)
	local cQuery	:= ""
	local oSql		:= nil

	cQuery := " SELECT SD2.D2_CUSTO1 CUSTO1, SD2.D2_CUSTO2 CUSTO2, SD2.D2_CUSTO3 CUSTO3, 				"
	cQuery += " SD2.D2_CUSTO4 CUSTO4, SD2.D2_CUSTO5 CUSTO5             									"
	cQuery += " FROM SD1010 SD1                                                                         " 
	cQuery += " INNER JOIN SD2010 SD2 ON D2_FILIAL = '" + cFilTrf + "'                             		"
	cQuery += " 						AND D2_DOC = D1_DOC                                             "
	cQuery += " 						AND D2_SERIE = D1_SERIE                                         "
	cQuery += " 						AND D2_ITEM = D1_ITEM                                           "
	cQuery += " 						AND SD2.D_E_L_E_T_ = ''                                         "
	cQuery += " INNER JOIN SF4010 F4 ON '' = F4_FILIAL AND D1_TES = F4_CODIGO AND F4.D_E_L_E_T_ = ''    "
	cQuery += " WHERE SD1.D1_FILIAL = '" + cFilAtu + "'                                                 "
	cQuery += " AND F4.F4_TRANFIL = '1'	                                                                "
	cQuery += "	AND SD1.R_E_C_N_O_ = '" + cValToChar(nRecno) + "'										"
	cQuery += " AND SD1.D_E_L_E_T_ = ''                                                                 "
	cQuery += " AND SUBSTRING(SD2.D2_EMISSAO,1,6) = SUBSTRING(SD1.D1_DTDIGIT,1,6)						"
		
	oSql := LibSqlObj():newLibSqlObj()	
	oSql:newAlias( cQuery )
	if oSql:hasRecords()
		oSql:goTop()
		if oSql:getValue("CUSTO1") > 0
			// -- aCust { {aCM}, {aFifo}, {aParte} } onde:
			// -- aCM    = vetor com os custos medios
			// -- aFifo  = vetor com os custos FIFO (se parâmetro lUsaFifo == .T.)
			// -- aParte = vetor com os custos em partes
			aCust[01,01] := oSql:getValue("CUSTO1")
			aCust[01,02] := oSql:getValue("CUSTO2")
			aCust[01,03] := oSql:getValue("CUSTO3")
			aCust[01,04] := oSql:getValue("CUSTO4")
			aCust[01,05] := oSql:getValue("CUSTO5") 
		endif
	endif

	oSql:close() 
	FreeObj(oSql)
	
return(aCust)