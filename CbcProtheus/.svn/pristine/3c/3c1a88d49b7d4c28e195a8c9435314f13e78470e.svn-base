#INCLUDE 'Protheus.ch'
#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'rwmake.ch'
#INCLUDE 'TOPCONN.ch'
#INCLUDE 'tbiconn.ch'
#INCLUDE 'Fileio.ch'

/*
Função que Captura Array do coletor com os dados da coleta para gravação do inventario
Juliana Leme  - 28/07/2015
*/

User Function CDColPPI()
Local	aParamBox := {}                            
Local	aRet 	:= ""             
Local	lOk  	:= .T. 	
Local cArqErr := "InvErr.txt"
Local cMsg 	:= ""
Local _aDados := {}
Private cDir 	:= "" 
Private nCont := 1 	                                    

	aParamBox := {}                            
	aRet 		:= "" 
	aAdd(aParamBox,{6,"Arquivo de Coleta TXT",Space(70),"","","" ,70,.T.,"Arquivo .TXT|*.TXT"})	
	aAdd(aParamBox,{6,"Local de Saída Planilha",Space(70),"","","" ,70,.T.,"Arquivo .TXT|*.TXT"})	
	
	If !ParamBox(aParamBox, "Parametros", @aRet)
		Return(.F.)
	EndIf           
		
	cOrigem	:= aRet[1]
	cDir		:= Alltrim(Substr(aRet[2],1,rat("\",aRet[2])))		
	Processa( {|| _aDados:= ImporTXT(cOrigem,,.F.)},"Aguarde, carregando Coleta ... Pode demorar ...")
	If len(_aDados) > 0
		U_ExpColPPI(_aDados)
	Else
		Aviso("Atenção","Arquivo Vazio",{"Ok"},1)
	EndIf
	//Envia Email 
	If cMsg <> ""
		U_ConsoleLog("INTEGRACAO N REALIZADA - UNMOV NAO ENCONTRADA ",cMsg,cArqErr) //cTipo = (ERRO,CONCLUIDO,EXCESSAO) cMsg = (Mensagem destinada a informação)                            
		Processa({|| U_ArqPorEmail(cArqErr,"juliana.leme@cobrecom.com.br","[ERROS]Inventario Protheus X PCF")},"Enviando Email Erros...")
	EndIf
	Aviso("Atenção","Importação com exito!",{"Ok"},1)
Return ()

Static Function ImporTXT(cArqImpor)
Local cLinha := ""  
Local nLinha := 0
Local aDados := {}
Local nTamLinha := 0
Local nTamArq:= 0
Local nCont  := 1
	//Valida arquivo
	If !file(cArqImpor)
		Aviso("Arquivo","Arquivo não selecionado ou invalido.",{"Sair"},1)
		Return
	Else     
		//+---------------------------------------------------------------------+
		//| Abertura do arquivo texto                                           |
		//+---------------------------------------------------------------------+
		nHdl := fOpen(cArqImpor)
    
		If nHdl == -1 
			If FERROR()== 516 
				Alert("Feche a planilha que gerou o arquivo.")
			EndIF
		EndIf
        
		//+---------------------------------------------------------------------+
		//| Verifica se foi possível abrir o arquivo                            |
		//+---------------------------------------------------------------------+
		If nHdl == -1
			cMsg := "O arquivo de nome "+cArqImpor+" nao pode ser aberto! Verifique os parametros."
			MsgAlert(cMsg,"Atencao!")
			Return
		Endif

		//+---------------------------------------------------------------------+
		//| Posiciona no Inicio do Arquivo                                      |
		//+---------------------------------------------------------------------+
		FSEEK(nHdl,0,0)
       
		//+---------------------------------------------------------------------+
		//| Traz o Tamanho do Arquivo TXT                                       |
		//+---------------------------------------------------------------------+
		nTamArq:=FSEEK(nHdl,0,2)
       
		//+---------------------------------------------------------------------+
		//| Posicona novamemte no Inicio                                        |
		//+---------------------------------------------------------------------+
		FSEEK(nHdl,0,0)

       //+---------------------------------------------------------------------+
       //| Fecha o Arquivo                                                     |
       //+---------------------------------------------------------------------+
		fClose(nHdl)
		FT_FUse(cArqImpor)  //abre o arquivo 
		FT_FGOTOP()         //posiciona na primeira linha do arquivo      
		nTamLinha := Len(FT_FREADLN()) //Ve o tamanho da linha
		FT_FGOTOP()
        
       //+---------------------------------------------------------------------+
       //| Verifica quantas linhas tem o arquivo                               |
       //+---------------------------------------------------------------------+
		nLinhas := nTamArq/nTamLinha
		ProcRegua(nLinhas)
		aDados:={}  
		nCont := 1
		While !FT_FEOF() //Ler todo o arquivo enquanto não for o final dele
			IncProc('Importando Linha: ' + Alltrim(Str(nCont)))
			clinha := FT_FREADLN() 
			aadd(aDados,Separa(cLinha,";",.T.))
			nCont	:= nCont +1
			FT_FSKIP()
		EndDo

		FT_FUse()
		fClose(nHdl)
	EndIf
    
	Aviso("Atenção","Importação com exito!",{"Ok"},1)
Return (aDados)    


/*
Função que Exporta no formato da PPI a planilha com os dados do inventario
Juliana Leme - 29/07/2015
*/
User Function ExpColPPI(aColeta)
Local oExcel		:= FWMSEXCEL():New()
Local aCabec		:= {}
Local dDataInv 	:= dDataBase
Local aParamBox 	:= {}
Local aColPPI		:= {}                            
Local cQuery	:= ""
Local nCount	:= 1
Private oApp_Ori
Private nHndErp 	:= AdvConnection()
Private cDB_PPI 	:= GetMV("ZZ_HNDPCF") //"MSSQL/PCFactory"	//Tipo e nome do banco de integração (PC-Factory) (OFICIAL)
Private cSrvPPI 	:= GetMV("ZZ_SRVPPI") //"192.168.3.2"		//Servidor onde está o banco de integração (OFICIAL)
Private nPrtPPI 	:= GetNewPar("ZZ_PORTADB", "7890")	// Porta
Private nHndPPI	//Handler do banco de dados de integração  

	oApp_Ori 	:= oApp
   
	// Cria uma conexão com um outro banco, outro DBAcces
	nHndPPI := TcLink(cDb_PPI,cSrvPPI,nPrtPPI)
	//Conecta com PPI	
	TcSetConn(nHndPPI)
	
    //Caso a conexão não seja realizada    
	If nHndPPI < 0
    	Alert("Falha ao conectar com " + cDB_PPI + " em " + cSrvPPI + ":" + Str(nPrtPPI,4))
    	Return(.T.)
	Endif
	
	//Conecta com ERP
	TcSetConn(nHndERP)

	ProcRegua(0)                                                  
	
	oExcel:AddworkSheet("ColMovUn")
	oExcel:AddTable("ColMovUn","PCFactory")
	
	oExcel:AddColumn("ColMovUn","PCFactory","",1,1)//1
	oExcel:AddColumn("ColMovUn","PCFactory","",1,1)//2
	oExcel:AddColumn("ColMovUn","PCFactory","",1,1)//3
	oExcel:AddColumn("ColMovUn","PCFactory","",1,1)//4
	oExcel:AddColumn("ColMovUn","PCFactory","",1,1)//5
	
	//Montando Cabeçalho
	aAdd(aCabec,{"Data",;//1
					"MovUn",;//2
					"Produto",;//3
					"Descrição",;//4
					"Qtde"})//37
	//Carrega Cabecalho
	ProcRegua(len(aCabec))		
	For n1:= 1 to len(aCabec)			
		oExcel:AddRow("ColMovUn","PCFactory",aCabec[n1])
		IncProc('Importando Cabeçalho')
	Next
	
	ProcRegua(len(aColeta))
	For n1:=1 to len (aColeta)

		//Coloca os Registros de Integração em Processo
		_cQuery := " SELECT  Convert(nvarchar,GetDate(),103) DatNow,
		_cQuery += " 			A.IDMOVUN MovUn, "
		_cQuery += " 			B.CODE Produto, "
		_cQuery += " 			B.NAME Descric,"
		_cQuery += " 			"+iIF(Val(aColeta[n1][3]) = 0," A.MOVUNQTY ",aColeta[n1][3])+" Qtde "
		_cQuery += " FROM TBLMovUn A "
		_cQuery += "   Inner Join TBLProduct B ON A.IDProduct = B.IDProduct "
		_cQuery += " WHERE A.IdMovun = " + aColeta[n1][2]
		
		//Conecta com PPI	
		TcSetConn(nHndPPI) 
		
		cQuery := ChangeQuery(_cQuery)
	
		If Select("TRB1")>0
			DbSelectArea("TRB1")
			DbCloseArea()
		EndIf                                                                                                                            
			
		TCQUERY _cQuery NEW ALIAS "TRB1"
			
		DbSelectArea("TRB1")               
		DbGotop()              
		
		//Verifica se a Query foi executada
		If (TCSqlExec(_cQuery) < 0) // Deu Erro
			//_lVolta := .T. // Significa que deu erro na função
			cMsg := TCSQLError() //+ linha
		    MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
		EndIf  
		//Retorna conexão Protheus	                         
		TcSetConn(nHndERP)
		
		If TRB1->(!Eof())
			aAdd(aColPPI,{TRB1->DatNow,;
							TRB1->MovUn,;
							TRB1->Produto,;
							TRB1->Descric,;
							TRB1->Qtde})
		EndIf
		
		oExcel:AddRow("ColMovUn","PCFactory",aColPPI[n1])
		IncProc('Importando Item '+Alltrim(Str(n1))+ ' de '+Alltrim(Str(Len(aColPPI))))
	Next
	
	oExcel:Activate()
	oExcel:GetXMLFile(cDir+"\Invent"+DtoS(Date())+".xls")
	Alert("A planilha foi exportada com sucesso em "+cDir+"Invent"+DtoS(Date())+".xls")
	
	//Encerra conexão PPI	
	TcUnLink(nHndPPI)   
	//Conecta ERP
 	TcSetConn(nHndERP)  
 	oApp 	:= oApp_Ori     	
Return