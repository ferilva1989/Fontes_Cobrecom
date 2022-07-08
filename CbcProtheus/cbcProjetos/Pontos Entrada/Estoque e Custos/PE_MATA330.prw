#include 'protheus.ch'
#include 'parmtype.ch'

/*
User Function MA330TRF()
	Local aRet       := PARAMIXB[1] // Vetor original com os custos apurados
	Local cFilAtu    := PARAMIXB[2] // Filial que esta sendo processada
	Local cFilTrf    := PARAMIXB[3] // Filial de transferencia
	Local cProduto   := PARAMIXB[4] // Código do produto
	Local nRecno     := PARAMIXB[5] // RECNO do alias (SD1)
	Local lUsaFifo   := PARAMIXB[6] // Indica se esta processando custo FIFO
	// -- Dimensoes do vetor aRet (PARAMIXB[1])
	// -- aRet { {aCM}, {aFifo}, {aParte} } onde:
	// -- aCM    = vetor com os custos medios
	// -- aFifo  = vetor com os custos FIFO (se parâmetro lUsaFifo == .T.)
	// -- aParte = vetor com os custos em partes
	// Rotina criada pelo usuario para manipular o vetor contendo os custos
	// Exemplo: Localizar notas de saída (remito) de transferencias que ocorreram 
	// em periodos já fechados
	//aRet := RemitoOri(aRet, cFilAtu, cFilTrf, cProduto, nRecno, lUsaFifo)
Return (aRet)
*/

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
			RecLock("TRB",.F.)
				TRB->TRB_NIVEL	:= "99w"
			MsUnlock()
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