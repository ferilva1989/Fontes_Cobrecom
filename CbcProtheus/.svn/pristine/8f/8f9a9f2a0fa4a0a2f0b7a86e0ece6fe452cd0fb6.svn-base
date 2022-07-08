#INCLUDE 'Protheus.ch'
#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'rwmake.ch'
#INCLUDE 'TOPCONN.ch'
#INCLUDE 'tbiconn.ch'
#INCLUDE 'Fileio.ch'

#define CRLF Chr(13)+Chr(10)


/*/{Protheus.doc} MainPPI
//TODO Função que realiza a conexão entre Banco Protheus e Banco PPI.
@author juliana.leme
@since 01/03/2015
@version 1.0
@param aParam, Array, Parametro de duas posições contendo informações de Empresa e Filial
@type function
/*/
User Function MainPPI(aParam)
	Local 	_aArea 	   			:= GetArea()
	Local _nMod		   			:= "04"
	local bErro					:= nil
	Private cDataLog			:= DtoC(Date()) + " - " + Time()
	Private cIdSess				:= Alltrim(FWUUIDV4())
	Private oApp_Ori
	Private oApp_Ori2
	Private nHndErp			:= AdvConnection()
	Private nHndPPI			//Handler do banco de dados de integração
	Private cArqErr				:= "LogErro.TXT"
	Private cArqOk				:= "LogOk.TXT"
	Private cArqDiv			:= "LogDiv.TXT"
	Private cArqSaldo		:= "LogSaldo.TXT"
	Private lMenu					:= .F.
	Private _cEmpresa		:= "01"
	Private _cFilial			:= "01"
	Private aProdNeg		:= {}
	Private lProcessa		:= .T.
	Private cMsgVerg		:= ""
	Private cIntegVerg		:= ""
	Private nTamMsg		:= 0
	Default aParam			:= {{"01","01"}}


	If Select("SX2") <> 0
		lMenu := .T.
		oApp_Ori 	:= oApp
		oApp_Ori2 	:= oApp
		_cEmpresa	:= SUBSTR(cNumEmp,1,2)
		_cFilial	:= SUBSTR(cNumEmp,3,2)
	Endif

	If !lMenu
		ConOut (cDataLog + "-[IMPORTACAO PPI] INICIADA NA FILIAL:"+aParam[2] + "-"+ cIdSess)
		ConOut (cDataLog + "-[IMPORTACAO PPI] EMPRESA:"+aParam[3] + "-"+ cIdSess)
		_cEmpresa	:= aParam[3]
		_cFilial		:= aParam[2]
		PREPARE ENVIRONMENT EMPRESA aParam[3] FILIAL aParam[2]
		nHndErp			:= AdvConnection()
	EndIf

	Private cDB_PPI 		:= GetMV("ZZ_HNDPPI") //"MSSQL/PCF_Integ"	//Tipo e nome do banco de integração (PC-Factory) (OFICIAL)
	Private cSrvPPI 		:= GetMV("ZZ_SRVPPI") //"192.168.3.2"		//Servidor onde está o banco de integração (OFICIAL)
	Private nPrtPPI			:= GetNewPar("ZZ_PORTADB", "7890")	// Porta

	// Cria uma conexão com um outro banco, outro DBAcces
	nHndPPI := TcLink(cDb_PPI,cSrvPPI,nPrtPPI)
	//Conecta com PPI
	TcSetConn(nHndPPI)
	//Caso a conexão não seja realizada
	If nHndPPI < 0
		u_autoAlert(cDataLog + "-Falha ao conectar com " + cDB_PPI + " em " + cSrvPPI + ":" + Str(nPrtPPI,4))
		TcUnLink(nHndPPI)
	Else
		
		bErro	:= ErrorBlock({|oErr| HandleEr(oErr)})
		BEGIN SEQUENCE
			TcSetConn(nHndERP)
			U_ProcInteg()
		END SEQUENCE
		ErrorBlock(bErro)
		
		ConOut (cDataLog + "-[IMPORTACAO PPI] FINALIZADA NA FILIAL:"+_cFilial + "-" + cIdSess)
		ConOut (cDataLog + "-[IMPORTACAO PPI] EMPRESA:"+_cEmpresa + "-" + cIdSess )
		
		TcSetConn(nHndERP)
		DbCloseArea()

		TcSetConn(nHndPPI)
		DbCloseArea()
		TcUnLink(nHndPPI)

		//Finaliza as conexões
		If !lMenu
			Reset Environment
		Else
			//U_EnvEmPCF()//Envia email quando a chamada é pelo Menu
			oApp 	:= oApp_ori2
			RestArea(_aArea)
		Endif
	EndIf
Return()


/*/{Protheus.doc} ProcInteg
//TODO Descrição Processa a Integração.
@author juliana.leme
@since 13/06/2016

@version undefined
@type function
/*/
User Function ProcInteg()
	//Bloqueia Rotina em uso
	If !LockByName("CDRETPPI",.F.,.F.,.T.)
		MsgAlert("Rotina está sendo executada por outro usuário.")
		Return
	EndIf
	
	//Realiza os procedimentos
	cArqErr			:= "LogErro"+ _cFilial +".TXT"
	cArqOk			:= "LogOk"+ _cFilial +".TXT"
	cArqDiv			:= "LogDiv"+ _cFilial +".TXT"
	cArqSaldo	:= "LogSaldo"+ _cFilial +".TXT"

	TcSetConn(nHndPPI)

	//Função principal
	Processa({|| Mk_PPI()},"Movimentos Integração PPI")

	TcSetConn(nHndERP)
	
	//Libera Rotina em  Uso
	UnLockByName("CDRETPPI",.F.,.F.,.T.)
Return

/*/{Protheus.doc} AvalIntg
//TODO Descrição Retorna Integração Liberada.
@author juliana.leme
@since 13/06/2016
@version undefined
@type function
/*/
User Function AvalIntg()
Local _cQuery 	:= ""
Local _lLiberOk := .F.

	_cQuery :=" SELECT IDMovEv "+;
							" FROM TBLOutInteg "+;
		 					" WHERE Integrated IN (0,1,3) "+;
							" ORDER BY DtTimeStamp DESC "

	_cQuery := ChangeQuery(_cQuery)

	If Select("TRBPCFINTG")>0
		DbSelectArea("TRBPCFINTG")
		DbCloseArea()
	EndIf

	TCQUERY _cQuery NEW ALIAS "TRBPCFINTG"

	DbSelectArea("TRBPCFINTG")
	DbGotop()

	ProcRegua(3)
	IncProc("Aguarde, Verificando Liberação da Integração ...")
	If TRBPCFINTG->(!Eof())
		_IDTop := TRBPCFINTG->(IDMovEv)
		IncProc("Aguarde, Verificando Liberação da Integração. Irá demorar cerca de 1 minuto ...")
		Conout("Parametro .T., Aguardando 1 minuto para liberar a Integração")
		Sleep( 10000 ) //Aguardar 1 minuto
		If lMenu
			IncProc("Aguarde, Verificando Liberação da Integração. Irá demorar cerca de 1 minuto ...")
		EndIf
		_cQuery :=" SELECT IDMovEv "+;
									" FROM TBLOutInteg "+;
									" WHERE Integrated IN (0,1,3) "+;
									" ORDER BY DtTimeStamp DESC "

		_cQuery := ChangeQuery(_cQuery)

		If Select("TRBPCFINTG2")>0
			DbSelectArea("TRBPCFINTG2")
			DbCloseArea()
		EndIf

		TCQUERY _cQuery NEW ALIAS "TRBPCFINTG2"

		DbSelectArea("TRBPCFINTG2")
		DbGotop()

		IncProc("Aguarde, Validando a liberação da Integração!")
		If TRBPCFINTG2->(!Eof())
			Conout("IDNOVO :" + Str(TRBPCFINTG2->(IDMovEv)) + "ID ANT :" + Str(_IDTop))
			If TRBPCFINTG2->(IDMovEv) = _IDTop
				_lLiberOk := .T.
				Conout("Integração Liberada, Servidor travado e liberado!")
			Else
				_lLiberOk := .F.
				Conout("Integração Bloqueada, Processo em integração!")
			EndIf
		EndIf
	EndIf
	DbCloseArea("TRBPCFINTG")
	DbCloseArea("TRBPCFINTG2")
Return(_lLiberOk)


/*/{Protheus.doc} EnvEmPCF
//TODO Envia email formatado do PCF.
@author juliana.leme
@since 01/03/2016
@version 1.0
@param aParam, Array, Parametro de duas posições contendo informações de Empresa e Filial
@type function
/*/
User Function EnvEmPCF(aParam)
	Private cArqErr				:= "LogErro.TXT"
	Private cArqOk				:= "LogOk.TXT"
	Private cArqDiv			:= "LogDiv.TXT"
	Private cArqSaldo		:= "LogSaldo.TXT"
	Private lMenu				:= .F.
	Private _cEmpresa		:= "01"
	Private _cFilial				:= "01"
	Private aProdNeg		:= {}
	Default aParam 			:= {{"01","01"}}

	If Select("SX2") <> 0
		lMenu := .T.
		oApp_Ori 	:= oApp
		oApp_Ori2 	:= oApp
		_cEmpresa	:= SUBSTR(cNumEmp,1,2)
		_cFilial	:= SUBSTR(cNumEmp,3,2)
	Endif

	If !lMenu
		ConOut ("FILIAL:"+aParam[2])
		ConOut ("EMPRESA:"+aParam[3])
		_cEmpresa		:= aParam[3]
		_cFilial		:= aParam[2]
		PREPARE ENVIRONMENT EMPRESA aParam[3] FILIAL aParam[2]
		nHndErp		:= AdvConnection()
	EndIf

	cArqErr			:= "LogErro"+ _cFilial +".TXT"
	cArqOk			:= "LogOk"+ _cFilial +".TXT"
	cArqDiv			:= "LogDiv"+ _cFilial +".TXT"
	cArqSaldo	:= "LogSaldo"+ _cFilial +".TXT"

	//Envia Email ERROS
	Processa({|| U_ArqEmAnex(cArqErr,"pcpfast@cobrecom.com.br","Relatorio Integração PCF x Protheus ",cArqOk)},"Enviando Email...") //+ IIf(_cFilial == "01","[ITU]","[TL]"),cArqOk)},"Enviando Email...")
	//Erros MOD
	Processa({|| U_ArqEmAnDiv(cArqDiv,"pcpfast@cobrecom.com.br","ALERTA Integracoes PCF X Protheus ","")},"Enviando Email...") //+ IIf(_cFilial == "01","[ITU]","[TL]"),"")},"Enviando Email...")
Return


/*/{Protheus.doc} EncOPPCF
//TODO Descrição auto-gerada.
@author juliana.leme
@since 25/04/2017
@version undefined
@type function
/*/
User Function EncOPPCF(aParam)//U_EncOPPCF({{"01","01"}})
	Private cArqErr				:= "LogErro.TXT"
	Private cArqOk				:= "LogOk.TXT"
	Private cArqDiv			:= "LogDiv.TXT"
	Private cArqSaldo		:= "LogSaldo.TXT"
	Private lMenu				:= .F.
	Private _cEmpresa		:= "01"
	Private _cFilial				:= "01"
	Private aProdNeg			:= {}
	Default aParam 			:= {{"01","01"}}
	Private nHndErp 			:= AdvConnection()
	Private cDB_PPI 			:= GetMV("ZZ_HNDPPI")  //"MSSQL/PCF_Integ"	//Tipo e nome do banco de integração (PC-Factory) (OFICIAL)
	Private cSrvPPI 			:= GetMV("ZZ_SRVPPI") //"192.168.3.2"		//Servidor onde está o banco de integração (OFICIAL)
	Private nPrtPPI 			:= 7890	// Porta
	Private nHndPPI			//Handler do banco de dados de integração

	If Select("SX2") <> 0
		lMenu := .T.
		oApp_Ori 	:= oApp
		oApp_Ori2 	:= oApp
		_cEmpresa	:= SUBSTR(cNumEmp,1,2)
		_cFilial	:= SUBSTR(cNumEmp,3,2)
	Endif

	If !lMenu
		ConOut ("FILIAL:"+aParam[2])
		ConOut ("EMPRESA:"+aParam[3])
		_cEmpresa		:= aParam[3]
		_cFilial		:= aParam[2]
		PREPARE ENVIRONMENT EMPRESA aParam[3] FILIAL aParam[2]
		nHndErp		:= AdvConnection()
	EndIf

	//Realiza os procedimentos
	cArqErr			:= "LogErro"+ _cFilial +".TXT"
	cArqOk			:= "LogOk"+ _cFilial +".TXT"
	cArqDiv			:= "LogDiv"+ _cFilial +".TXT"
	cArqSaldo	:= "LogSaldo"+ _cFilial +".TXT"

	// Cria uma conexão com um outro banco, outro DBAcces
	nHndPPI := TcLink(cDb_PPI,cSrvPPI,nPrtPPI)
	//Conecta com PPI
	TcSetConn(nHndPPI)
	//Caso a conexão não seja realizada
	If nHndPPI < 0
		u_autoAlert("Falha ao conectar com " + cDB_PPI + " em " + cSrvPPI + ":" + Str(nPrtPPI,4))
		TcUnLink(nHndPPI)
	Else
		TcSetConn(nHndPPI)
		//Função principal
		Processa({|| EncerOP_PPI()},"Encerrando OPs PPI")
	EndIf
	TcSetConn(nHndERP)
Return()

/*/{Protheus.doc} MontaLog
//TODO Monta Log para envio email.
@author juliana.leme
@since 20/04/2016
@version 1.0
@param _cTipo, Caracter, Tipo do Log a ser incluido (N = Normal, D = Divergencia)
@type function
/*/
User Function MontaLog(_cTipo)
	Local cDtEvento 	:= ""
	Local cMov			:= ""
	Public cMsg 		:= ""

	If SubsTr(TRBPCF->REDE,1,2) = "RE"
		cMov := "REQUISICAO"
	ElseIf SubsTr(TRBPCF->REDE,1,2) = "PR"
		cMov := "PRODUCAO"
	ElseIf SubsTr(TRBPCF->REDE,1,2) = "DE"
		cMov := "DEVOLUCAO"
	ElseIf SubsTr(TRBPCF->REDE,1,2) = "EP"
		cMov := "EST.PROD."
	ElseIf SubsTr(TRBPCF->REDE,1,2) = "ER"
		cMov := "EST.REQUIS."
	ElseIf SubsTr(TRBPCF->REDE,1,2) = "ED"
		cMov := "EST.DEVOL."
	ElseIf SubsTr(TRBPCF->REDE,1,2) = "TR"
		cMov := "TRANSFER."
	Else
		cMov := TRBPCF->REDE
	EndIf

	If _cTipo = "N" //Normal
		cDtEvento 	:= Right(Alltrim(TRBPCF->DtEvento),2)+"/"+Substr(Alltrim(TRBPCF->DtEvento),5,2)+"/"+Substr(Alltrim(TRBPCF->DtEvento),1,4)
		cMsg 		+= Padr(Alltrim(Str(TRBPCF->IDTrans))	 		,10,' ')
		cMsg 		+= Padr(cDtEvento													,12,' ')
		cMsg 		+= Padr(cMov															,14,' ')
		cMsg 		+= Padr(TRBPCF->OP											,14,' ')
		cMsg 		+= Padr(TRBPCF->Produto									,18,' ')
		cMsg 		+= Padr(TRANSFORM(TRBPCF->Qtde, "@E 99999999.999"),14,' ')
		cMsg 		+= Padr(TRBPCF->(EndOrigem)							,16,' ')
		cMsg 		+= Padr(TRBPCF->(EndDestino)							,16,' ')
	ElseIf _cTipo = "D" //Divergencia
		cDtEvento 	:= Right(Alltrim(TRBPCF->DtEvento),2)+"/"+Substr(Alltrim(TRBPCF->DtEvento),5,2)+"/"+Substr(Alltrim(TRBPCF->DtEvento),1,4)
		cMsg 		+= Padr(Alltrim(Str(TRBPCF->IDTrans))	 		,10,' ')
		cMsg 		+= Padr(cDtEvento													,12,' ')
		cMsg 		+= Padr(cMov															,14,' ')
		cMsg 		+= Padr(TRBPCF->OP											,14,' ')
		cMsg 		+= Padr(TRBPCF->Produto									,18,' ')
		cMsg 		+= Padr(TRBPCF->Recurso									,13,' ')
	EndIf
Return(cMsg)


/*/{Protheus.doc} Mk_PPI
//TODO Função que Realiza diversos movimentos de produção do PCF pela tabela TBLOutInteg.
@author juliana.leme
@since 08/04/2015
@version 1.0
@type function
/*/
Static Function Mk_PPI()
	Local cQuery	:= ""
	Public cTipoB1 	:= ""

	//Conecta com PPI
	TcSetConn(nHndPPI)
	ProcRegua(10)
	IncProc("Aguarde, Atualizando Status PPI")

	cQuery := "SELECT  "
	cQuery += "	IDMovEv as IDTrans,  "
	cQuery += "	ProductCode as Produto,  "
	cQuery += "	CONVERT(VARCHAR(12),DtTimeStamp, 112) as DtEvento, "
	cQuery += "	CONVERT(NVARCHAR(5),DtTimeStamp,108) as HrEvento, "
	cQuery += "	TransacType as Transac,  "
	cQuery += "	MovTypeCode as REDE,  "
	cQuery += "	Address1Code as EndOrigem, "
	cQuery += "	Address2Code as EndDestino,  "
	cQuery += "	IDMovUn as UnMov, "
	cQuery += "	LotCode as Lote,  "
	cQuery += "	Qty as Qtde, "
	cQuery += "	SUBSTRING(WoCode,3,11) as OP,  "
	cQuery += "	SUBSTRING(LotAuxCode2,3,11) as OP2,  "
	cQuery += "	SUBSTRING(WareHouseCode,1,2)  as Filial,  "
	cQuery += "	SUBSTRING(WoCode,1,2)  as FilialOP,  "
	cQuery += "	WoDetCode as Operacao,  "
	cQuery += "	AuxField1 as StatCQ,  "
	cQuery += "	ResourceCode as Recurso, "
	cQuery += "	WareHouseCode as EndLocal, "
	cQuery += "	UserCode as Usuario,  "
	cQuery += "	SectorCode as Setor,  "
	cQuery += "	UndoIdMovEv as IdEstorn,  "
	cQuery += "	Comments as Comentario,  "
	cQuery += "	CompanyCode as Fornecedor,  "
	cQuery += "	DtCreation as DateInc  "
	cQuery += " FROM TBLOutInteg "
	cQuery += " WHERE Integrated in  ('0','3') "
	cQuery += " AND SUBSTRING(UserCode,1,2) = '"+IIF(!Empty(xFilial("SD3")),xFilial("SD3"),_cFilial)+"' "
	cQuery += " ORDER BY DtTimeStamp "

	IncProc("Aguarde, Carregando Dados PPI")

	cQuery := ChangeQuery(cQuery)

	If Select("TRBPCF")>0
		DbSelectArea("TRBPCF")
		DbCloseArea()
	EndIf

	TCQUERY cQuery NEW ALIAS "TRBPCF"

	DbSelectArea("TRBPCF")
	DbGotop()
	
	//Altera Status de 0 para 1 Processando
	AlterStatPPI("0","1")
	AlterStatPPI("3","1")
	
	ProcRegua(RecCount())
	Do While TRBPCF->(!Eof())
		//Incremental Regua
		IncProc("Prod: "+Alltrim(TRBPCF->Produto)+" OP: "+TRBPCF->OP+" Trans: "+TRBPCF->REDE)
		tcSetConn(nHndErp)
		cTipoB1 := Posicione("SB1",1,xFilial("SB1")+Alltrim(TRBPCF->Produto),"B1_TIPO")
		cGrupoB1:= Posicione("SB1",1,xFilial("SB1")+Alltrim(TRBPCF->Produto),"B1_GRUPO")

		If (Alltrim(TRBPCF->REDE) == "DE0").or.(Alltrim(TRBPCF->REDE) == "DEI").or.(Alltrim(TRBPCF->REDE) == "ED0") //Entrada por Documento Fiscal
			AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans)))//Atualiza MP e não integra
			TRBPCF->(DbSkip())
			Loop
		EndIf

		If (Alltrim(TRBPCF->REDE)$("PR0,PR1")) //Produção Padrão/Avulso
			//Requisição de MOD para produtos
			lProdVerg := .T.
			//Analisa se Produção teve consumo de MP Copper
			If Substr(Alltrim(TRBPCF->Produto),1,3) == 'PF1' .and. (Alltrim(TRBPCF->REDE)$("PR0"))
				lProdVerg := ProdVergPCF("PR0")
			Else
				lProdVerg := .T.
			Endif

			If lProdVerg
				If TRBPCF->Qtde > 199999
					U_MontaLog("D")
					cMsg 		+= "  QUANTIDADE REPORTADA EXCEDEU LIMITE DEFINIDO" + CRLF
					U_ConsLogPCF("D",cMsg,cArqDiv)
					AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)))//Atualiza MP e não integra
				Else
					U_ReqMOD240(3)
					U_ProMata250(3)
				EndIf
			Else
				U_MontaLog("D")
				cMsg 		+= cMsgVerg + CRLF
				U_ConsLogPCF("D",cMsg,cArqDiv)
				AlterStatPPI("",cIntegVerg,Alltrim(Str(TRBPCF->IDTrans)),cMsgVerg) //Atualiza MP e não integra
			EndIf
		ElseIf (Alltrim(TRBPCF->REDE)$("EP0,EP1")) //Estorno de Produção Padrão/Avulso
			U_EstMata250(5)
		ElseIf (Alltrim(TRBPCF->REDE)$("DE4,DE3")) .and. SubStr(Alltrim(cGrupoB1),1,2) <> 'MP'//Ajuste de Inclusão (Entrada)
			If cTipoB1 <> 'PA' .and. cTipoB1 <> 'PI'
				U_ReqMata240(3,"002")
			Else
				U_MontaLog("N")
				cMsg 		+=  " MOVIMENTO DE3 PRODUTO ACABADO/INTERMEDIARIO, NÃO PERMITIDO!" + CRLF
				U_ConsLogPCF("N",cMsg,cArqErr)
				AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans)),"MOVIMENTO DE3 PRODUTO ACABADO, NÃO PERMITIDO!") //Altera de 1 para 3 ERRO
			EndIf
		ElseIf (Alltrim(TRBPCF->REDE)$("ED3,ED4")) .and. SubStr(Alltrim(cGrupoB1),1,2) <> 'MP'//Estorno Ajuste de Inclusão (Entrada)
			If cTipoB1 <> 'PA' .and. cTipoB1 <> 'PI'
				U_EstMat240(5,"002")
			Else
				U_MontaLog("N")
				cMsg 		+=  " MOVIMENTO DE3 PRODUTO ACABADO/INTERMEDIARIO, NÃO PERMITIDO!" + CRLF
				U_ConsLogPCF("N",cMsg,cArqErr)
				AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans)),"MOVIMENTO DE3 PRODUTO ACABADO/INTERMEDIARIO, NÃO PERMITIDO!") //Altera de 1 para 3 ERRO
			EndIf
		//Devolução de Materia Prima Recuperada
		ElseIf (Alltrim(TRBPCF->REDE)$("DE3")) .and. SubStr(Alltrim(cGrupoB1),1,2) = 'MP' //Ajuste de Inclusão (Entrada) PVC REcuperado
			If ! U_CBRatMPRec()
				U_ReqMata240(3,"007")
			EndIf
		ElseIf (Alltrim(TRBPCF->REDE)$("ED3")) .and. SubStr(Alltrim(cGrupoB1),1,2) <> 'MP'//Estorno Ajuste de Inclusão (Entrada)
			U_EstMat240(5,"007")
		ElseIf (Alltrim(TRBPCF->REDE)$("RE0,RE6"))//Ajuste Exclusão (Saida)
			//Vergalhão da Coper Não Consome
			If Substr(Alltrim(TRBPCF->Produto),1,10) == '2010000000'
				lProdVerg := ProdVergPCF("RE0")
			Else
				lProdVerg := .T.
			Endif 
			
			If ! lProdVerg
			//(Alltrim(TRBPCF->Produto) == '2010000000').and. (Alltrim(TRBPCF->Fornecedor) == 'V00A6601')
				U_MontaLog("D")
				cMsg 		+= cMsgVerg + CRLF
				U_ConsLogPCF("D",cMsg,cArqDiv)
				AlterStatPPI("",cIntegVerg,Alltrim(Str(TRBPCF->IDTrans)),cMsgVerg)//Atualiza MP e não integra
			Else
				U_ReqMata240(3,"504")
			EndIf
		ElseIf (Alltrim(TRBPCF->REDE)$("RE1"))//Ajuste Exclusão (Saida)
			//Vergalhão da Coper Não Consome
			If Substr(Alltrim(TRBPCF->Produto),1,10) == '20100000000'
				lProdVerg := ProdVergPCF("RE0")
			Else
				lProdVerg := .T.
			Endif 
			If Empty((Alltrim(TRBPCF->OP))) 
				U_MontaLog("D")
				cMsg 		+= "  MOVIMENTO SEM OP. VERIFICAR!" + CRLF
				U_ConsLogPCF("D",cMsg,cArqDiv)
				AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),"MOVIMENTO SEM OP. VERIFICAR!")//Atualiza MP e não integra			
			ElseIf ! lProdVerg
				//(Alltrim(TRBPCF->Produto) == '2010000000').and. (Alltrim(TRBPCF->Fornecedor) == 'V00A6601')
				U_MontaLog("D")
				cMsg 		+= cMsgVerg + CRLF
				U_ConsLogPCF("D",cMsg,cArqDiv)
				AlterStatPPI("",cIntegVerg,Alltrim(Str(TRBPCF->IDTrans)),cMsgVerg)//Atualiza MP e não integra			 
			Else
				U_ReqMata240(3,"504")
			EndIf
		ElseIf (Alltrim(TRBPCF->REDE)$("ER0,ER6,ER1")) //Estorno Ajuste Exclusão (Saida)
			U_EstMat240(5,"504")
		ElseIf (Alltrim(TRBPCF->REDE) = "RE5") //Baixa por Sucata
			U_CBDesmSuc()
		ElseIf (Alltrim(TRBPCF->REDE) = "ER5")//Estorno Baixa por Sucata
			//U_EstMat240(5,"503")
		ElseIf (Alltrim(TRBPCF->REDE) = "RE3") //Baixa por Exclusão
			AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 2 Integrado
		ElseIf (Alltrim(TRBPCF->REDE) = "ER3")//Estorno Baixa por Exclusão
			AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 2 Integrado
		ElseIf ((Left(Alltrim(TRBPCF->REDE),2) = "TR").or.(Left(Alltrim(TRBPCF->REDE),2) = "ET")) //Transferencias Diversas
			//Caso Seja Transferencias diferentes do deposito, não fazer.
			If ((Right(Alltrim(TRBPCF->(EndOrigem)),3) $ "WIP,EST").and.(Right(Alltrim(TRBPCF->(EndDestino)),3) $ "WIP,EST")).and.;
			(Alltrim(TRBPCF->(EndOrigem)) <> Alltrim(TRBPCF->(EndDestino))) .and. (cTipoB1 <> "PA") .and.;
			 Right(Alltrim(TRBPCF->(EndDestino)),3) <> Right(Alltrim(TRBPCF->(EndOrigem)),3)
				U_TraMata260(3)
			Else
				AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 2 Integrado
			EndIf
		ElseIf (Alltrim(TRBPCF->REDE)$("DM1,DM2"))
			AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans)))
		ElseIf (Alltrim(TRBPCF->REDE)$("EM1,EM2"))
			AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans)))
		EndIf
		TRBPCF->(DbSkip())
	Enddo
	
	//Conecta com PPI
	TcSetConn(nHndPPI)
	//Altera Status de 0 para 1 Processando
	AlterStatPPI("1","0")
	
	tcSetConn(nHndErp)
	DbCloseArea()
Return()

/*/{Protheus.doc} AlterStatPPI
//TODO Altera Status de Integração na tabela do PCF.
@author juliana.leme
@since 26/02/2015
@version 1.0
@param cIniStat, Caracter, Status inicial de integração
@param cFimStat, Caracter, Status a ser atualizado de Integração
@param cIdTrans, Caracter, Id Unico para identificar registro
@param cMotErr, Caracter, Motivo do Erro a ser gravado no campo Comments
@type function
/*/
Static Function AlterStatPPI(cIniStat,cFimStat,cIdTrans,cMotErr)
	Local _cQuery := ""

	//Conecta com PPI
	TcSetConn(nHndPPI)
	//Coloca os Registros de Integração em Processo
	_cQuery := " UPDATE TBLOutInteg SET  "
	_cQuery += " Integrated = " + cFimStat +", "
	_cQuery += " DtIntegration = GETDATE() "

	If !Empty(cMotErr) //Caso seja ERRO grava motivo ERRO
		_cQuery := _cQuery + ", Comments = '" + Alltrim(cMotErr)+"'"
	EndIf

	If !Empty(cIniStat)
		_cQuery := _cQuery + " WHERE Integrated = " + cIniStat
		If !Empty(cIdTrans) //Atualiza pelo ID gravado na TBLOUTINTEG
			_cQuery := _cQuery + " AND IdMovEv = " + cIdTrans
		EndIf
	Else
		If !Empty(cIdTrans) //Atualiza pelo ID gravado na TBLOUTINTEG
			_cQuery := _cQuery + " WHERE IdMovEv = " + cIdTrans
		EndIf
	EndIf

	TCSqlExec(_cQuery)
	If (TCSqlExec(_cQuery) < 0) // Deu Erro
		cMsg := TCSQLError() //+ linha
		MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
	EndIf
Return


/*/{Protheus.doc} ProMata250
//TODO Função que executa automatica o MATA250 (PRODUÇÃO). Obs.:nMyOpcao = 3-Inclusão 5-Estorno
@author juliana.leme
@since 25/02/2015
@version 1.0
@param nMyOpcao, Numerico, Opção a ser processada (3-Inclusão 5-Estorno)
@type function
/*/
User Function ProMata250(nMyOpcao)
	Local	aItens			:= 	{}
	Local	cHist			:= 	""

	cHist 	:= "PCF;"+SUBSTRING((TRBPCF->REDE)+Space(3),1,3)+";"
	cHist 	+= SUBSTRING(TRBPCF->Recurso+Space(15),1,15)+";"
	cHist 	+= Alltrim(TRBPCF->Usuario)+";"
	cHist 	+= Substring(Alltrim(TRBPCF->HrEvento),1,2)+Substring(Alltrim(TRBPCF->HrEvento),4,2)+";"
	tcSetConn(nHndErp)

	If Alltrim(cTipoB1) <> "PA"
		cLocal := Padr("99",TamSX3("D3_LOCAL")[1])
	Else
		cLocal	:= Padr("20",TamSX3("D3_LOCAL")[1])
	EndIf

	DBSelectArea("SB2")
	SB2->(DbSetOrder(1))
	If !SB2->(DbSeek(xFilial("SB2")+Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1])+cLocal,.F.))
		CriaSB2(Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1]),cLocal)
	EndIf
/* MADEIRA - INICIO SEMÁFORO */
	if !u_cbcSemaCtr(.T.,,'CDEST20',10,10,1000,.T.)
		U_MontaLog("N")
		cErro		:= 'ERRO NO ACESSO EXCLUSIVO'
		cMsg 		+= SubsTr(cErro,1,180)+ CRLF
		U_ConsLogPCF("N",cMsg,cArqErr)
		AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),SubsTr(cErro,1,180)) //Altera de 1 para 3 ERRO
		if lMenu
			oApp 		:= oApp_ori
		endif
		return()
	endif
/* MADEIRA - FIM SEMÁFORO */
	If (Alltrim(TRBPCF->REDE)$("DM2,EM1"))
		_cLocal := Posicione("SC2",1,xFilial("SC2")+Padr(Alltrim(TRBPCF->OP2),TamSX3("D3_OP")[1]),"C2_LOCAL")
	Else
		_cLocal := Posicione("SC2",1,xFilial("SC2")+Padr(Alltrim(TRBPCF->OP),TamSX3("D3_OP")[1]),"C2_LOCAL")
	EndIf
	
	If SC2->C2_LOCAL # cLocal
		SC2->(RecLock("SC2",.F.,,.T.,.T.))
		SC2->C2_LOCAL := cLocal
		MsUnLock()
	EndIf

	aItens 	:= {{"D3_TM"		,Padr("006",TamSX3("D3_TM")[1])	  				 													,NIL},; //TP.MOVIM.
				{"D3_COD" 		,Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1])													,NIL},; //D3_COD
				{"D3_DOC"		,Padr(Alltrim(Str(TRBPCF->IDTrans)),TamSX3("D3_DOC")[1])											,NIL},; //TP.MOVIM.
				{"D3_UM" 		,Posicione("SB1",1,xFilial("SB1")+Alltrim(TRBPCF->Produto),"B1_UM")									,NIL},;
				{"D3_LOCAL" 	,cLocal																								,NIL},;
				{"D3_QUANT" 	,Round(ABS(TRBPCF->Qtde),4)																		   	,NIL},;
				{"D3_HIST"		,Padr(cHist,TamSX3("D3_HIST")[1])																	,NIL},;
				{"D3_OP" 		,IIF(Alltrim(TRBPCF->REDE)$("DM2,EM1"),Padr(Alltrim(TRBPCF->OP2),TamSX3("D3_OP")[1]),Padr(Alltrim(TRBPCF->OP),TamSX3("D3_OP")[1])),NIL},;
				{"D3_EMISSAO"	,StoD(TRBPCF->DtEvento)								   												,NIL},;
				{"D3_PARCTOT"	,Padr("P",TamSX3("D3_PARCTOT")[1])																	,NIL},;
				{"D3_ZZLOTE"	,Padr(Alltrim(TRBPCF->Lote),TamSX3("D3_ZZLOTE")[1])													,NIL},;
				{"D3_ZZUNMOV"	,TRBPCF->UnMov																						,NIL}}

	/*
	lMsErroAuto 	:= .F.

	RPCSetType(3)
	RPCSetEnv('01',xFilial("SD3"),,,'EST',GetEnvServer(),{} )

	MSExecAuto({|x,y| mata250(x,y)},aItens,nMyOpcao)

	If lMsErroAuto
	*/
	oExec := cbcExecAuto():newcbcExecAuto(aItens,/*aAutoCab*/,.F.)
	oExec:setFilial(FwFilial())
	oExec:exAuto('MATA250',nMyOpcao,,"EST")
	aRet := oExec:getRet()
	FreeObj(oExec)
	
	if !aRet[1]		
		U_MontaLog("N")
		cErro		:= aRet[2]	
		cMsg 		+= SubsTr(cErro,1,180)+ CRLF
		U_ConsLogPCF("N",cMsg,cArqErr)
		AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),SubsTr(cErro,1,180)) //Altera de 1 para 3 ERRO
		If lMenu
			oApp 		:= oApp_ori
		EndIf
	Else
		If Alltrim(cTipoB1) == "PA" .and. (Substr(SD3->D3_COD,1,3) <> "MOD")
			//Posiciona o SD3
			DbSelectArea("SD3")
			DbOrderNickName("D3_ZZPPI") // D3_FILIAL+D3_ZZUNMOV+D3_COD+D3_CF
			DbSeek(xFilial("SD3") +Padr(TRBPCF->UnMov,TamSX3("D3_ZZUNMOV")[1])+Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1])+"PR0",.F.)

			//Realiza a Distribuição
			DbSelectArea("SDA")
			DbSetOrder(1) // DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ
			DbSeek(xFilial("SDA")+SD3->D3_COD+SD3->D3_LOCAL+SD3->D3_NUMSEQ,.F.)

			aCAB  := {	{"DA_PRODUTO" ,SDA->DA_PRODUTO             , nil},;
										{"DA_QTDORI"  ,SDA->DA_QTDORI              , nil},;
										{"DA_SALDO"   ,SDA->DA_SALDO               , nil},;
										{"DA_DATA"    ,SDA->DA_DATA                , nil},;
										{"DA_LOCAL"   ,SDA->DA_LOCAL               , nil},;
										{"DA_DOC"     ,SDA->DA_DOC                 , nil},;
										{"DA_ORIGEM"  ,SDA->DA_ORIGEM              , nil},;
										{"DA_NUMSEQ"  ,SDA->DA_NUMSEQ              , nil},;
										{"DA_QTSEGUM" ,SDA->DA_QTSEGUM             , nil},;
										{"DA_QTDORI2" ,SDA->DA_QTDORI2             , nil}}
							aITENS:={ { {"DB_ITEM"	, "0001"										, nil},;
															{"DB_LOCALIZ" , "PROD_PCF"					, nil},;
															{"DB_QUANT"   , SDA->DA_SALDO			, nil},;
															{"DB_DATA"    , SDA->DA_DATA				, nil},;
															{"DB_ESTORNO" ," "										, nil} }}
			/*
			lMsErroAuto := .F.
			MsExecAuto({|x,y|mata265(x,y)},aCAB,aITENS)
			If lMsErroAuto
			*/
			oExec := cbcExecAuto():newcbcExecAuto(aITENS,aCAB,.F.)
			oExec:setFilial(FwFilial())
			oExec:exAuto('MATA265',,,"EST")
			aRet := oExec:getRet()
			FreeObj(oExec)
	
			if !aRet[1]	
				U_MontaLog("N")
				cErro		:= aRet[2]	
				cMsg 		+= SubsTr(cErro,1,180)+ CRLF
				U_ConsLogPCF("N",cMsg,cArqErr)
			EndIf
		EndIf
		U_MontaLog("N")
		cMsg 		+= " " + CRLF
		U_ConsLogPCF("N",cMsg,cArqOk)
		AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 2 Integrado
		If lMenu
			oApp 		:= oApp_ori
		EndIf
	EndIf
/* MADEIRA - INICIO SEMÁFORO */
	u_cbcSemaCtr(.F.,,'CDEST20',10,10,1000,.T.)
/* MADEIRA - FIM SEMÁFORO */
Return()


/*/{Protheus.doc} ReqMOD240
//TODO Requisição de Mão de Obra Direta na Produção.
@author juliana.leme
@since 23/09/2015
@version 1.0
@param nMyOpcao, Numerico, Opção a ser processada (3-Inclusão 5-Estorno)
@type function
/*/
User Function ReqMOD240(nMyOpcao)
	Local	aItens		:= 	{}
	Local	cHist		:= 	""
	Local	cProd		:= ""
	Local nQtdHrs		:= 0
	Local cMyTm		:= "504"

	cHist 		:= "PCF;"+SUBSTRING((TRBPCF->REDE)+Space(3),1,3)+";"
	cHist 		+= SUBSTRING(TRBPCF->Recurso+Space(15),1,15)+";"
	cHist 		+= Alltrim(TRBPCF->Usuario)+";"
	cHist 		+= Substr(Alltrim(TRBPCF->HrEvento),1,2)+Substr(Alltrim(TRBPCF->HrEvento),4,2)+";"
	
	tcSetConn(nHndErp)
	
	DbSelectArea("ZAG")
	nQtdHrs	:= Posicione("ZAG",1,xFilial("ZAG")+Padr(Alltrim(TRBPCF->Produto),TamSX3("ZAG_PRODUT")[1])+Padr(Alltrim(TRBPCF->Recurso),TamSX3("ZAG_RECPPI")[1]),"ZAG_SETUP")
	If nQtdHrs <= 0
		//nQtdHrs := 0.017 //1 minuto centesimal
		//Tempo não encontrado
		U_MontaLog("D")
		cMsg 		+=  "  TEMPO DE PRODUCAO NAO CADASTRADO" + CRLF
		U_ConsLogPCF("D",cMsg,cArqDiv)
	Else
		nQtdHrs :=	((TRBPCF->Qtde*nQtdHrs)*24)
		/*
		O Valor encontrado na Matriz ZAG correponde ao valor absoluto de 1 DIA
		Para encontrar o valor em Horas conforme a UM do produto, foi realizada a multiplicação por 24
		Numero absoluto de uma hora
		*/
		Do Case
			Case Alltrim(TRBPCF->Setor) == "EXT"
			cProd := "MOD300110"
			Case Alltrim(TRBPCF->Setor) == "FR"
			cProd := "MOD300111"
			Case Alltrim(TRBPCF->Setor) == "TF"
			cProd := "MOD300112"
			Case Alltrim(TRBPCF->Setor) == "TG"
			cProd := "MOD300113"
			Case Alltrim(TRBPCF->Setor) == "ENC"
			cProd := "MOD300114"
			Case Alltrim(TRBPCF->Setor) == "LAM"
			cProd := "MOD300115"
			OtherWise
			cProd := "MOD999999"
		End Case
		tcSetConn(nHndErp)
		aItens 	:= {{"D3_TM"	,Padr(cMyTM,TamSX3("D3_TM")[1]) 	 						,NIL},; //TP.MOVIM.
										{"D3_COD"		,cProd 																						,NIL},; //D3_COD
										{"D3_DOC"		,Padr(Alltrim(Str(TRBPCF->IDTrans)),TamSX3("D3_DOC")[1]),NIL},; //TP.MOVIM.
										{"D3_UM"		,Posicione("SB1",1,xFilial("SB1")+Alltrim(cProd),"B1_UM"),NIL},;
										{"D3_LOCAL"		,Padr("99",TamSX3("D3_LOCAL")[1])			,NIL},;
										{"D3_QUANT"		,Round(nQtdHrs,TamSX3("D3_QUANT")[2])	,NIL},;
										{"D3_HIST"		,Padr(cHist,TamSX3("D3_HIST")[1])				,NIL},;
										{"D3_OP"		,Padr(Alltrim(TRBPCF->OP),TamSX3("D3_OP")[1]),NIL},;
										{"D3_EMISSAO"	,StoD(TRBPCF->DtEvento)							   	,NIL},;
										{"D3_PARCTOT" 	,Padr("P",TamSX3("D3_PARCTOT")[1])		,NIL},;
										{"D3_ZZLOTE" 	,Padr(Alltrim(TRBPCF->Lote),TamSX3("D3_ZZLOTE")[1])		,NIL},;
										{"D3_ZZUNMOV" 	,TRBPCF->UnMov										   			,NIL}}
/*
		lMsErroAuto 	:= .F.

		RPCSetType(3)
		RPCSetEnv('01',xFilial("SD3"),,,'EST',GetEnvServer(),{} )

		MSExecAuto({|x,y| mata240(x,y)},aItens,nMyOpcao)
		
		If lMsErroAuto
		*/
	oExec := cbcExecAuto():newcbcExecAuto(aItens,/*aAutoCab*/,.F.)
	oExec:setFilial(FwFilial())
	oExec:exAuto('MATA240',nMyOpcao,,"EST")
	aRet := oExec:getRet()
	FreeObj(oExec)
	
	if !aRet[1]	
			U_MontaLog("N")
			cErro		:= aRet[2]
			cMsg 		+= SubsTr(cErro,1,180)+ CRLF
			U_ConsLogPCF("N",cMsg,cArqErr)
			AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),SubsTr(cErro,1,180)) //Altera de 1 para 3 ERRO
			If lMenu
				oApp 		:= oApp_ori
			EndIf
		Else
			U_MontaLog("N")
			cMsg 		+= " "+ CRLF
			U_ConsLogPCF("N",cMsg,cArqOk)
			AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 2 Integrado
			If lMenu
				oApp 		:= oApp_ori
			EndIf
		EndIf
	EndIf
Return

/*/{Protheus.doc} EstMata250
//TODO Estorna Produção realizada indevidamente.
@author juliana.leme
@since 27/04/2016
@version 1.0
@param nMyOpcao, Numerico, Operacao a ser processada (3-Inclusão 5-Estorno)
@type function
/*/
User Function EstMata250(nMyOpcao)
	Local	aItens		:= 	{}
	Local	cD3Seq		:= ""
	tcSetConn(nHndErp)

	cD3Seq	:= Posicione("SD3",2,xFilial("SD3")+ Padr(Alltrim(Str(TRBPCF->IdEstorn)),TamSX3("D3_DOC")[1]) +;
	Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1]),"D3_NUMSEQ")
	If SD3->D3_TEMPES <> "F"//S

		//Estorna SDA antes do estorno de produção
		If Alltrim(cTipoB1) == "PA" .and. (Substr(SD3->D3_COD,1,3) <> "MOD")
			//Posiciona o SD3
			DbSelectArea("SD3")
			DbSetOrder(8)
			DbSeek(xFilial("SD3") + Padr(Alltrim(Str(TRBPCF->IdEstorn)),TamSX3("D3_DOC")[1]) + cD3Seq)

			//Realiza o Estorno da Distribuição
			DbSelectArea("SDA")
			DbSetOrder(5) // DA_FILIAL+DA_DOC
			DbSeek(xFilial("SDA")+Padr(Alltrim(Str(TRBPCF->IdEstorn)),TamSX3("D3_DOC")[1]),.F.)

			aCab  := {{"DA_PRODUTO"		,SDA->DA_PRODUTO			, nil},;
										{"DA_NUMSEQ"	,SDA->DA_NUMSEQ				, nil}}

			aItens:={ { {"DB_ITEM"	  	, "0001"									, nil},;
											{"DB_ESTORNO" 	, "S "										, nil},;
											{"DB_LOCALIZ" 	, "PROD_PCF"					, nil},;
											{"DB_DATA"    	, SDA->DA_DATA				, nil},;
											{"DB_QUANT"   	, SDA->DA_QTDORI			, nil}}}
			
			/*
			oExec := cbcExecAuto():newcbcExecAuto(aItens,aCab,.F.)
			oExec:setFilial(FwFilial())
			oExec:exAuto('MATA265',4)
			aRet := oExec:getRet()
			FreeObj(oExec)
			*/
			lMsErroAuto := .F.
			//Executa o endereçamento do item
			MATA265( aCab, aItens, 4)
			If lMsErroAuto			
			//If !aRet[1]
				U_MontaLog("N")
				//cErro		:= aRet[2]	
				//cMsg 		+= SubsTr(cErro,1,180)+ CRLF
				cErro		:= StrTran(StrTran(Alltrim(SubsTr(MemoRead(NomeAutoLog()),nTamMsg)),chr(13) + chr(10)," "),chr(10),"")
				cMsg 		+= SubsTr(cErro,1,180)+ CRLF
				nTamMsg	:= Len(MemoRead(NomeAutoLog()))
				U_ConsLogPCF("N",cMsg,cArqErr)
				AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),SubsTr(cErro,1,180)) //Altera de 1 para 3 ERRO
				If lMenu
					oApp 		:= oApp_ori
				EndIf
				Return()
			EndIf
		EndIf
		//Fim
		aItens 	:= {{"D3_NUMSEQ"	,cD3Seq			,NIL},; //TP.MOVIM.
							{"INDEX"	   			, 4					,NIL}}
		/*
		lMsErroAuto := .F.

		RPCSetType(3)
		RPCSetEnv('01',xFilial("SD3"),,,'EST',GetEnvServer(),{} )

		MSExecAuto({|x,y| mata250(x,y)},aItens,nMyOpcao)
		//RpcClearEnv()
		If lMsErroAuto
		*/
		oExec := cbcExecAuto():newcbcExecAuto(aItens,/*aAutoCab*/,.F.)
		oExec:setFilial(FwFilial())
		oExec:exAuto('MATA250',nMyOpcao,,"EST")
		aRet := oExec:getRet()
		FreeObj(oExec)
	
		if ! aRet[1]	
			U_MontaLog("N")
			cErro		:= aRet[2]	
			cMsg 		+= SubsTr(cErro,1,180)+ CRLF
			U_ConsLogPCF("N",cMsg,cArqErr)
			AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),SubsTr(cErro,1,180)) //Altera de 1 para 3 ERRO
			If lMenu
				oApp 		:= oApp_ori
			EndIf
		Else
			U_MontaLog("N")
			cMsg 		+= " " + CRLF
			U_ConsLogPCF("N",cMsg,cArqOk)
			AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 2 Integrado
			If lMenu
				oApp 		:= oApp_ori
			EndIf
		EndIf
	Else
		U_MontaLog("N")
		cMsg 		+= "Erro Pesagem Ja Processada! Não pode ser estornado!" + CRLF
		U_ConsLogPCF("N",cMsg,cArqErr)
		AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),"ERRO PESAGEM JA PROCESSADA, NÃO PODE SER ESTORNADO!") //Altera de 1 para 3 ERRO
		If lMenu
			oApp 		:= oApp_ori
		EndIf
	EndIf
Return()

/*/{Protheus.doc} ReqMata240
//TODO Função que executa automatica o MATA240 (Req.Mod.1).
@author juliana.leme
@since 25/02/2015
@version 1.0
@param nMyOpcao, Numerico, Opção a ser realizada (3-Inclusão 5-Estorno)
@param cMyTM, Caracter, Tipo de Movimento a ser realizado
@type function
/*/
User Function ReqMata240(nMyOpcao,cMyTM)
	Local	aItens		:= {}
	Local   aSaldos		:= {}
	Local	cHist		:= ""
	Local 	nQtdePCF	:= 0
	Local	nQtde		:= 0
	Local	nPercSuct	:= 0
	Local nQuantProt	:= 0
	Local cOP			:= ""

	cHist 	:= "PCF;"+SUBSTRING((TRBPCF->REDE)+Space(3),1,3)+";"
	cHist 	+= SUBSTRING(TRBPCF->Recurso+Space(15),1,15)+";"
	cHist 	+= Alltrim(TRBPCF->Usuario)+";"
	cHist 	+= Substr(Alltrim(TRBPCF->HrEvento),1,2)+Substr(Alltrim(TRBPCF->HrEvento),4,2)+";"
	tcSetConn(nHndErp)

	If Alltrim(cTipoB1) == "PA" .and. (Substr(SD3->D3_COD,1,3) <> "MOD")
		_cLocal := "20"
		_cEnder	:= "PROD_PCF"
	Else
		_cLocal := IIF(Right(Alltrim(TRBPCF->(EndLocal)),3)=="WIP","99","01")
		_cEnder	:= ""
	EndIf

	//Conforme reunião dia 11/11/2015 sera realizada a requisição de Vergalhão para Sucata afim de almientar estoque
	//Parametro para definição da percentagem que sera transferida a sucata
	nPercSuct := GetMV("MV_ZZPSUCA")
	If (Alltrim(TRBPCF->Produto) == '2010000000').and. nPercSuct <> 0
		//Considderando 80% Vergalhão e 20% Sucata
		nQtde 		:= Round(ABS(TRBPCF->Qtde * ((100-nPercSuct)/100)),4)
		nQtdeSuc	:= Round(ABS(TRBPCF->Qtde * (nPercSuct/100)),4)
		//Transfere a Sucata
		TraMataSuc(nQtdeSuc)
	Else
		DbSelectArea("SB2")
		nQuantProt	:= Posicione("SB2",1,xFilial("SB2") + Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1]) + _cLocal,"B2_QATU")
		nQtdePCF 	:= Round(ABS(TRBPCF->Qtde),4)
		If nQuantProt < nQtdePCF
			If ABS(nQuantProt - nQtdePCF) <= 1
				nQtde := nQuantProt
			Else
				U_CBCTraMata(Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1]),"01",_cLocal,nQtdePCF,Padr(Alltrim(Str(TRBPCF->IDTrans)),TamSX3("D3_DOC")[1]),"","")
				nQtde := nQtdePCF
			EndIf
		Else
			nQtde := nQtdePCF
		EndIf
	
	Endif

	cOP := Alltrim(TRBPCF->OP)

	If nQtde > 0
		aItens 	:= {{"D3_TM",Padr(cMyTM,TamSX3("D3_TM")[1])	 								,NIL},; //TP.MOVIM.
		{"D3_COD" 		,Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1])					,NIL},; //D3_COD
		{"D3_DOC"		,Padr(Alltrim(Str(TRBPCF->IDTrans)),TamSX3("D3_DOC")[1])			,NIL},; //TP.MOVIM.
		{"D3_UM" 		,Posicione("SB1",1,xFilial("SB1")+Alltrim(TRBPCF->Produto),"B1_UM")	,NIL},;
		{"D3_LOCAL" 	,Padr(_cLocal,TamSX3("D3_LOCAL")[1])								,NIL},;
		{"D3_LOCALIZ" 	,Padr(_cEnder,TamSX3("D3_LOCALIZ")[1])								,NIL},;
		{"D3_QUANT" 	,Round(ABS(nQtde),4)												,NIL},;
		{"D3_HIST" 		,Padr(cHist,TamSX3("D3_HIST")[1])						  			,NIL},;
		{"D3_OP" 		,Padr(Alltrim(cOP),TamSX3("D3_OP")[1])				  				,NIL},;
		{"D3_EMISSAO" 	,StoD(TRBPCF->DtEvento)								  	   			,NIL},;
		{"D3_PARCTOT" 	,Padr("P",TamSX3("D3_PARCTOT")[1])						   			,NIL},;
		{"D3_ZZLOTE" 	,Padr(Alltrim(TRBPCF->Lote),TamSX3("D3_ZZLOTE")[1])			   		,NIL},;
		{"D3_ZZUNMOV" 	,TRBPCF->UnMov														,NIL}}

		/*
		lMsErroAuto 	:= .F.

		RPCSetType(3)
		RPCSetEnv('01',xFilial("SD3"),,,'EST',GetEnvServer(),{} )

		//Processar
		MSExecAuto({|x,y| mata240(x,y)},aItens,nMyOpcao)
		If lMsErroAuto
		*/
		oExec := cbcExecAuto():newcbcExecAuto(aItens,/*aAutoCab*/,.F.)
		oExec:setFilial(FwFilial())
		oExec:exAuto('MATA240',nMyOpcao,,"EST")
		aRet := oExec:getRet()
		FreeObj(oExec)
	
		if ! aRet[1]	
			U_MontaLog("N")
			cErro		:= aRet[2]
			cMsg 		+= SubsTr(cErro,1,180)+ CRLF
			U_ConsLogPCF("N",cMsg,cArqErr)
			AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),SubsTr(cErro,1,180)) //Altera de 1 para 3 ERRO
			If lMenu
				oApp 		:= oApp_ori
			EndIf
		Else
			U_MontaLog("N")
			cMsg 		+= " " + CRLF
			U_ConsLogPCF("N",cMsg,cArqOk)
			AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 2 Integrado

			If lMenu
				oApp 		:= oApp_ori
			EndIf
		EndIf
	Else
		U_MontaLog("N")
		cMsg 		+= "MOVIMENTACAO NAO EFETUADA, SUCATA EM 100%" + CRLF
		U_ConsLogPCF("N",cMsg,cArqErr)
		AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 2 Integrado
	EndIf
Return()

/*/{Protheus.doc} EstMat240
//TODO Função que executa automatica o MATA240 (Req.Mod.1).
@author juliana.leme
@since 25/02/2015
@version 1.0
@param nMyOpcao, Numerico, Opção a ser realizada (3-Inclusão 5-Estorno)
@param cMyTM, Caracter, Tipo de Movimento a ser realizado
@type function
/*/
User Function EstMat240(nMyOpcao,cMyTM)
	Local	aItens		:= 	{}

	tcSetConn(nHndErp)
	cD3Seq	:=	Posicione("SD3",2,xFilial("SD3")+ Padr(Alltrim(Str(TRBPCF->IdEstorn)),TamSX3("D3_DOC")[1]) +;
	Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1]),"D3_NUMSEQ")
	aItens 	:= {{"D3_NUMSEQ"	,cD3Seq			,NIL},; //TP.MOVIM.
						{"INDEX"  	   			, 4					,NIL}}
	/*
	lMsErroAuto := .F.

	RPCSetType(3)
	RPCSetEnv('01',xFilial("SD3"),,,'EST',GetEnvServer(),{} )

	MSExecAuto({|x,y| mata240(x,y)},aItens,nMyOpcao)
	If lMsErroAuto
	*/
	oExec := cbcExecAuto():newcbcExecAuto(aItens,/*aAutoCab*/,.F.)
	oExec:setFilial(FwFilial())
	oExec:exAuto('MATA240',nMyOpcao,,"EST")
	aRet := oExec:getRet()
	FreeObj(oExec)
	
	if ! aRet[1]	
		U_MontaLog("N")
		cErro		:= aRet[2]	
		cMsg 		+= SubsTr(cErro,1,180)+ CRLF
		U_ConsLogPCF("N",cMsg,cArqErr)
		AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),SubsTr(cErro,1,180)) //Altera de 1 para 3 ERRO
		If lMenu
			oApp 		:= oApp_ori
		EndIf
		_cFileLog 	:= ""
	Else
		U_MontaLog("N")
		cMsg 		+= " " + CRLF
		U_ConsLogPCF("N",cMsg,cArqOk)
		AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 2 Integrado

		If lMenu
			oApp 		:= oApp_ori
		EndIf
	EndIf
Return()

/*/{Protheus.doc} TraMata260
//TODO Função que executa automatica o MATA261 (Req.Mod.1).
@author juliana.leme
@since 25/02/2015
@version 1.0
@param nMyOpcao, Numerico, Opção a ser escolhida ()3-Inclusão 5-Estorno)
@type function
/*/
User Function TraMata260(nMyOpcao)
	Local	aItens		:= 	{}
	Local cLocOri	:= ""
	Local cLocDes:= ""

	tcSetConn(nHndErp)
	
	cLocOri := IIF(Right(Alltrim(TRBPCF->(EndOrigem)),3)=="WIP","99","01")
	cLocDes := IIF(Right(Alltrim(TRBPCF->(EndDestino)),3)=="WIP","99","01")
	
	//Analisa se existe SB2
	DBSelectArea("SB2")
	SB2->(DbSetOrder(1))
	If !SB2->(DbSeek(xFilial("SB2")+Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1])+cLocOri,.F.))
		CriaSB2(Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1]),cLocOri)
	EndIf
	If !SB2->(DbSeek(xFilial("SB2")+Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1])+cLocDes,.F.))
		CriaSB2(Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1]),cLocDes)
	EndIf
	
	aAdd(aItens,{Padr(Alltrim(Str(TRBPCF->IDTrans)),TamSX3("D3_DOC")[1]),StoD(TRBPCF->DtEvento)})

	aAdd(aItens,{Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1]),; 							//cProduto,;
	Posicione("SB1",1,xFilial("SB1")+Alltrim(TRBPCF->Produto),"B1_DESC"),;						//cDescProd,;
	Posicione("SB1",1,xFilial("SB1")+Alltrim(TRBPCF->Produto),"B1_UM"),; 							//cUM Origem
	Padr(cLocOri,TamSX3("D3_LOCAL")[1]),; 																					//cArmOri Origem
	"",;																																						//cEndOri Origem
	Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1]),; 													//cProduto,;
	Posicione("SB1",1,xFilial("SB1")+Alltrim(TRBPCF->Produto),"B1_DESC"),;						//cDescProd,;
	Posicione("SB1",1,xFilial("SB1")+Alltrim(TRBPCF->Produto),"B1_UM"),; 							//cUM Origem
	Padr(cLocDes,TamSX3("D3_LOCAL")[1]),; 																				//cArmDest Destino
	"",;																																						//cEndDest Destino,;
	"",;																																						//cNumSer Num Serie
	"",;																																						//cLote
	"",;																																						//SubLote
	StoD(""),;																																			//cValidade
	0,;																																						//nPoten
	Round(ABS(TRBPCF->Qtde),4),;																									//nQuant
	0,;																																						//cQtSegUm
	"",;																																						//Estornado
	"",;												   																										//cNumSeq
	"",; 																																						//cLoteDest
	StoD(""),;																																			//cValDest
	"",;                                                                          																				//ItemGrade
	""})                                                                          																				//D3_OBSERVA

/*
	lMsErroAuto 	:= .F.

	RPCSetType(3)
	RPCSetEnv('01',xFilial("SD3"),,,'EST',GetEnvServer(),{} )

	MSExecAuto({|x,y| mata261(x,y)},aItens,nMyOpcao)

	If lMsErroAuto
	*/

/*
	oExec := cbcExecAuto():newcbcExecAuto(aItens,,.F.)
	oExec:setFilial(FwFilial())
	oExec:exAuto('MATA261',nMyOpcao)
	aRet := oExec:getRet()
	FreeObj(oExec)
	
	if !aRet[1]	
		U_MontaLog("N")
		cErro		:= aRet[2]	
		cMsg 		+= SubsTr(cErro,1,180)+ CRLF
		U_ConsLogPCF("N",cMsg,cArqErr)
		AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),SubsTr(cErro,1,180)) //Altera de 1 para 3 ERRO
		If lMenu
			oApp 		:= oApp_ori
		EndIf
	Else
		U_MontaLog("N")
		cMsg 		+= " " + CRLF
		U_ConsLogPCF("N",cMsg,cArqOk)
		AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 2 Integrado
		If lMenu
			oApp 		:= oApp_ori
		EndIf
	EndIf
	*/
	lMsErroAuto 	:= .F.

	RPCSetType(3)
	RPCSetEnv('01',xFilial("SD3"),,,'EST',GetEnvServer(),{} )

	MSExecAuto({|x,y| mata261(x,y)},aItens,nMyOpcao)

	If lMsErroAuto
		If Empty(Alltrim(TRBPCF->Comentario))
			U_MontaLog("N")
			cErro		:= StrTran(StrTran(Alltrim(SubsTr(MemoRead(NomeAutoLog()),nTamMsg)),chr(13) + chr(10)," "),chr(10),"")
			cMsg 		+= SubsTr(cErro,1,180)+ CRLF
			nTamMsg	:= Len(MemoRead(NomeAutoLog()))
			U_ConsLogPCF("N",cMsg,cArqErr)
			AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),SubsTr(cErro,1,180)) //Altera de 1 para 3 ERRO
		Else
			nTamMsg	:= Len(MemoRead(NomeAutoLog()))
			AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 3 ERRO
		EndIf
		If lMenu
			oApp 		:= oApp_ori
		EndIf
	Else
		U_MontaLog("N")
		cMsg 		+= " " + CRLF
		U_ConsLogPCF("N",cMsg,cArqOk)
		AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 2 Integrado
		If lMenu
			oApp 		:= oApp_ori
		EndIf
	EndIf
Return()

/*/{Protheus.doc} TraMataSuc
//TODO Função que executa automatica o MATA261 (Req.Mod.1) Obs.: nMyOpcao = 3-Inclusão 5-Estorno.
@author juliana.leme
@since 25/02/2015
@version 1.0
@param nQtdSuc, Numerico, Quantidade de Sucata a ser convertida
@type function
/*/
User Function TraMataSuc(nQtdSuc) // Transfere Vergalhão para sucata
	Local	aItens		:= 	{}
	Default cProdSuc	:= "2010000001"

	cProdSuc := Iif(Empty(GetMV("MV_ZZSUCAT")), "2010000001",GetMV("MV_ZZSUCAT"))

	tcSetConn(nHndErp)
	aAdd(aItens,{Padr(Alltrim(Str(TRBPCF->IDTrans)),TamSX3("D3_DOC")[1]),StoD(TRBPCF->DtEvento)})

	aAdd(aItens,{Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1]),; 							//cProduto,;
	Posicione("SB1",1,xFilial("SB1")+Alltrim(TRBPCF->Produto),"B1_DESC"),;						//cDescProd,;
	Posicione("SB1",1,xFilial("SB1")+Alltrim(TRBPCF->Produto),"B1_UM"),; 						//cUM Origem
	"99",; 																						//cArmOri Origem
	"",;																						//cEndOri Origem
	Padr(cProdSuc,TamSX3("D3_COD")[1]),;			 											//cProduto,;
	Posicione("SB1",1,xFilial("SB1")+cProdSuc,"B1_DESC"),;										//cDescProd,;
	Posicione("SB1",1,xFilial("SB1")+cProdSuc,"B1_UM"),; 										//cUM Destino
	"01",;	 																					//cArmDest Destino
	"",;																						//cEndDest Destino,;
	"",;																						//cNumSer Num Serie
	"",;																						//cLote
	"",;																						//SubLote
	StoD(""),;																					//cValidade
	0,;																							//nPoten
	Round(ABS(nQtdSuc),4),;																		//nQuant
	0,;																							//cQtSegUm
	"",;																						//Estornado
	"",;												   										//cNumSeq
	"",; 																						//cLoteDest
	StoD(""),;																					//cValDest
	"",;                                                                          				//ItemGrade
	""})                                                                          				//D3_OBSERVA

	/*
	lMsErroAuto 	:= .F.

	RPCSetType(3)
	RPCSetEnv('01',xFilial("SD3"),,,'EST',GetEnvServer(),{} )

	MSExecAuto({|x,y| mata261(x,y)},aItens,3)
	If lMsErroAuto
	*/
	
	oExec := cbcExecAuto():newcbcExecAuto(aItens,/*aAutoCab*/,.F.)
	oExec:setFilial(FwFilial())
	oExec:exAuto('MATA261',3,,"EST")
	aRet := oExec:getRet()
	FreeObj(oExec)
	
	if !aRet[1]	
		U_MontaLog("N")
		cErro		:= aRet[2]	
		cMsg 		+= SubsTr(cErro,1,180)+ CRLF
		U_ConsLogPCF("N",cMsg,cArqErr)
		AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),SubsTr(cErro,1,180)) //Altera de 1 para 3 ERRO
		If lMenu
			oApp 		:= oApp_ori
		EndIf
	Else
		U_MontaLog("N")
		cMsg 		+= " " + CRLF
		U_ConsLogPCF("N",cMsg,cArqOk)
		AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 2 Integrado
		If lMenu
			oApp 		:= oApp_ori
		EndIf
	EndIf
Return()

/*/{Protheus.doc} EncerOP_PPI
//TODO Função que encerra/exclui OP.
@author juliana.leme
@since 08/04/2015
@version 1.0
@type function
/*/
Static Function EncerOP_PPI()
	Local 	cQuery		:=	""
	Local	aItens		:= 	{}
	Local	cD3Seq		:=	""
	Local	cTmD3		:=	""

	//Conecta com PPI
	TcSetConn(nHndPPI)
	ProcRegua(10)
	IncProc("Aguarde, Atualizando Status OPs PPI")
	AlterStatWo("0","1")

	IncProc("Aguarde, Consultando OPs PPI")
	cQuery := "SELECT  "
	cQuery += "IDOutWoStatus as IDTrans,  "
	cQuery += "ProductCode as Produto,  "
	cQuery += "CONVERT(VARCHAR(12),DtCreation, 112) as DataEmis, "
	cQuery += "SUBSTRING(WoCode,3,11) as OP, "
	cQuery += "Status as StatWo, "
	cQuery += "WoDetCode as Operac "
	cQuery += "FROM TBLOutWOStatus "
	cQuery += "WHERE Integrated in  ('1','3') "
	cQuery += "AND SUBSTRING(WoCode,1,2) LIKE '"+_cFilial+"%' "
	cQuery += "AND Convert(nvarchar,DtCreation,112) < '" + Alltrim(DtoS(dDataBase-1)) + "' "
	cQuery += "ORDER BY DtCreation"

	IncProc("Aguarde, Carregando Dados PPI")
	cQuery := ChangeQuery(cQuery)
	If Select("TRB2")>0
		DbSelectArea("TRB2")
		DbCloseArea()
	EndIf

	TCQUERY cQuery NEW ALIAS "TRB2"

	DbSelectArea("TRB2")
	DbGotop()
	//Apura tamanho da regua
	Do While TRB2->(!Eof())
		//Incremental Regua
		IncProc("Prod: "+Alltrim(TRB2->Produto)+" OP: "+TRB2->OP)
		tcSetConn(nHndErp)
		If (TRB2->StatWo <> 50 .and. TRB2->StatWo <> 60 .and. TRB2->StatWo <> 70)
			AlterStatWo("","2",Alltrim(Str(TRB2->IDTrans)))//Atualiza outros Status e não Integra
		Else
			If (Alltrim(TRB2->Operac)="10")
				tcSetConn(nHndErp)
				cTmD3	:= "001"
				cD3Seq	:= Posicione("SD3",15,xFilial("SD3")+Padr(Alltrim(TRB2->Produto),TamSX3("D3_COD")[1])+Padr(Alltrim(TRB2->OP),TamSX3("D3_OP")[1])+"001","D3_NUMSEQ")
				If Alltrim(cD3Seq) = ""
					cD3Seq	:= Posicione("SD3",15,xFilial("SD3")+Padr(Alltrim(TRB2->Produto),TamSX3("D3_COD")[1])+Padr(Alltrim(TRB2->OP),TamSX3("D3_OP")[1])+"006","D3_NUMSEQ")
				EndIf
				If Alltrim(cD3Seq) = ""
					nOpc := 5
					//Tenta excluir OP
					//{'C2_PRODUTO'  ,Padr(Alltrim(TRB2->Produto),TamSX3("D3_COD")[1])  ,NIL},;
					aItens  := {  {'C2_FILIAL'   ,xFilial("SD3")	             				  ,NIL},;
										{'C2_NUM'      ,Substr(Alltrim(TRB2->OP),1,6) ,NIL},;
										{'C2_ITEM'     ,Substr(Alltrim(TRB2->OP),7,2) ,NIL},;
										{'C2_SEQUEN'   ,Substr(Alltrim(TRB2->OP),9,3) ,NIL}}

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se alteracao ou exclusao, deve-se posicionar no registro     ³
					//³ da SC2 antes de executar a rotina automatica                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If nOpc == 4 .Or. nOpc == 5
						SC2->(DbSetOrder(1)) // FILIAL + NUM + ITEM + SEQUEN + ITEMGRD
						SC2->(DbSeek(xFilial("SC2")+Alltrim(TRB2->OP)))
						cMsg := SC2->C2_PRODUTO
					EndIf
					/*
					lMsErroAuto 	:= .F.

					RPCSetType(3)
					RPCSetEnv('01',xFilial("SD3"),,,'EST',GetEnvServer(),{} )

					MSExecAuto({|x,Y| Mata650(x,Y)},aItens,nOpc)
					//RpcClearEnv()
					If !lMsErroAuto
					*/
					oExec := cbcExecAuto():newcbcExecAuto(aItens,/*aAutoCab*/,.F.)
					oExec:setFilial(FwFilial())
					oExec:exAuto('MATA650',nOpc,,"EST")
					aRet := oExec:getRet()
					FreeObj(oExec)
	
					if aRet[1]	
						//ID         DATA       MOVIMENTO      OP           PRODUTO                 QTDE     ORIGEM          DESTINO         MOTIVO
						cMsg 		:= Padr(Alltrim(Str(TRB2->IDTrans))		,10,' ')
						cMsg 		+= Padr(""								,12,' ')
						cMsg 		+= Padr("ENCER.OP"						,14,' ')
						cMsg 		+= Padr(TRB2->OP						,14,' ')
						cMsg 		+= Padr(TRB2->Produto					,18,' ')
						cMsg 		+= Padr(TRANSFORM(0, "@E 99999999.999")	,14,' ')
						cMsg 		+= Padr(""								,16,' ')
						cMsg 		+= Padr(""								,16,' ')

						cMsg 		+= " " + CRLF
						U_ConsLogPCF("N",cMsg,cArqOk)
						If lMenu
							oApp 		:= oApp_ori
						EndIf
						AlterStatWo("","2",Alltrim(Str(TRB2->IDTrans))) //Altera de 1 para 2 Integrado
					Else
						If Empty(Alltrim(TRBPCF->Comentario))
							//ID         DATA       MOVIMENTO      OP           PRODUTO                 QTDE     ORIGEM          DESTINO         MOTIVO
							cMsg 		:= Padr(Alltrim(Str(TRB2->IDTrans))		,10,' ')
							cMsg 		+= Padr(""								,12,' ')
							cMsg 		+= Padr("ENCER.OP"						,14,' ')
							cMsg 		+= Padr(TRB2->OP						,14,' ')
							cMsg 		+= Padr(TRB2->Produto					,18,' ')
							cMsg 		+= Padr(TRANSFORM(0, "@E 99999999.999")	,14,' ')
							cMsg 		+= Padr(""								,16,' ')
							cMsg 		+= Padr(""								,16,' ')

							cErro		:= aRet[2]	
							cMsg 		+= SubsTr(cErro,1,180)+ CRLF
							U_ConsLogPCF("N",cMsg,cArqErr)
						EndIf
						If lMenu
							oApp 		:= oApp_ori
						EndIf
						AlterStatWo("","3",Alltrim(Str(TRB2->IDTrans)),"Não achou apontamento no Protheus") //Altera de 1 para 3 ERRO
						_cFileLog 	:= ""
					EndIf
				Else
					aItens := {{"D3_OP"		, Padr(Alltrim(TRB2->OP),TamSX3("D3_OP")[1])		, Nil}, ;
										{"D3_TM"		, cTmD3		   										, Nil}, ;
										{"D3_COD"		, Padr(Alltrim(TRB2->Produto),TamSX3("D3_COD")[1])	, Nil}, ;
										{"D3_EMISSAO"	, Padr(Alltrim(TRB2->DataEmis),TamSX3("D3_EMISSAO")[1]), Nil}, ;
										{"D3_DOC"		, TRB2->IDTrans	, Nil}, ;
										{"D3_NUMSEQ"	, cD3Seq		, Nil}}
					/*
					lMsErroAuto 	:= .F.

					RPCSetType(3)
					RPCSetEnv('01',xFilial("SD3"),,,'EST',GetEnvServer(),{} )

					MSExecAuto({|x, y| mata250(x, y)}, aItens, 6) // Encerrar OP
					//RpcClearEnv()
					If lMsErroAuto
					*/
					oExec := cbcExecAuto():newcbcExecAuto(aItens,/*aAutoCab*/,.F.)
					oExec:setFilial(FwFilial())
					oExec:exAuto('MATA250',6,,"EST")
					aRet := oExec:getRet()
					FreeObj(oExec)
	
					if !aRet[1]	
						//ID         DATA       MOVIMENTO      OP           PRODUTO                 QTDE     ORIGEM          DESTINO         MOTIVO
						cMsg 		:= Padr(Alltrim(Str(TRB2->IDTrans))		,10,' ')
						cMsg 		+= Padr(""								,12,' ')
						cMsg 		+= Padr("ENCER.OP"						,14,' ')
						cMsg 		+= Padr(TRB2->OP						,14,' ')
						cMsg 		+= Padr(TRB2->Produto					,18,' ')
						cMsg 		+= Padr(TRANSFORM(0, "@E 99999999.999")	,14,' ')
						cMsg 		+= Padr(""								,16,' ')
						cMsg 		+= Padr(""								,16,' ')

						cErro		:= aRet[2]	
						cMsg 		+= SubsTr(cErro,1,180)+ CRLF
						U_ConsLogPCF("N",cMsg,cArqErr)
						If lMenu
							oApp 		:= oApp_ori
						EndIf
						AlterStatWo("","3",Alltrim(Str(TRB2->IDTrans)),Left(MemoRead(NomeAutoLog()),350)) //Altera de 1 para 3 ERRO
						_cFileLog 	:= ""
					Else
							//ID         DATA       MOVIMENTO      OP           PRODUTO                 QTDE     ORIGEM          DESTINO         MOTIVO
							cMsg 		:= Padr(Alltrim(Str(TRB2->IDTrans))		,10,' ')
							cMsg 		+= Padr(""								,12,' ')
							cMsg 		+= Padr("ENCER.OP"						,14,' ')
							cMsg 		+= Padr(TRB2->OP						,14,' ')
							cMsg 		+= Padr(TRB2->Produto					,18,' ')
							cMsg 		+= Padr(TRANSFORM(0, "@E 99999999.999")	,14,' ')
							cMsg 		+= Padr(""								,16,' ')
							cMsg 		+= Padr(""								,16,' ')

						cMsg 		+= " " + CRLF
						U_ConsLogPCF("N",cMsg,cArqOk)
						If lMenu
							oApp 		:= oApp_ori
						EndIf
						AlterStatWo("","2",Alltrim(Str(TRB2->IDTrans))) //Altera de 1 para 2 Integrado
					EndIf
				EndIf
			Else
				AlterStatWo("","2",Alltrim(Str(TRB2->IDTrans))) //Altera de 1 para 2 Integrado
			EndIf
		Endif
		TRB2->(DbSkip())
	Enddo
	DbCloseArea()
	tcSetConn(nHndErp)
Return

/*/{Protheus.doc} AlterStatWo
//TODO Altera Status da Tabela de OP PCF.
@author juliana.leme
@since 09/04/2015
@version 1.0
@param cIniStat, Caracter, Campo a ser comparado
@param cFimStat, undefined, Campo a ser alterado
@param cIdTrans, undefined, Id unico do registro a ser alterado
@type function
/*/
Static Function AlterStatWo(cIniStat,cFimStat,cIdTrans)
	Local _cQuery := ""

	TcSetConn(nHndPPI)
	ProcRegua(10)
	IncProc("Aguarde, Atualizando Status OPs PPI")

	//Altera Status de 0 para 1 Processando
	//Coloca os Registros de Integração em Processo
	_cQuery := " Update TBLOutWOStatus Set  "
	_cQuery += " Integrated = "+cFimStat+", "
	_cQuery += " DtIntegration = GETDATE() "

	If !Empty(Alltrim(cIniStat))
		_cQuery += " Where Integrated = "+cIniStat
		If !Empty(Alltrim(cIdTrans))
			_cQuery += " And IdOutWoStatus = "+cIdTrans
		EndIf
	Else
		If !Empty(Alltrim(cIdTrans))
			_cQuery += " Where IdOutWoStatus = "+cIdTrans
		EndIf
	EndIf

	TCSqlExec(_cQuery)
	If (TCSqlExec(_cQuery) < 0) // Deu Erro
		//_lVolta := .T. // Significa que deu erro na função
		cMsg := TCSQLError() //+ linha
		MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
	EndIf

	IncProc("Aguarde, Consultando OPs PPI")
Return

/*/{Protheus.doc} ArqPorEmail
//TODO Le arquivo de Log TXT e envia email.
@author juliana.leme
@since 01/04/2015
@version 1.0
@param cNomArq, Caracter, Nome do Arquivo
@param cRecebe, Caracter, Destinatario do email
@param cAssunto, Caracter, Assunto do email
@type function
/*/
User Function ArqPorEmail(cNomArq,cRecebe,cAssunto)
	Private cArqTxt 	:= "\cProva\"+cNomArq //Log.TXT
	Private nHdl 		:= 0
	Private cMsg1		:= ""
	Private nTamLinha	:= 0
	Private nTamArq		:= 0
	Private cserver   	:= GetMV('MV_RELSERV')	//GetMV('MV_RELSERV')// Servidor SMTP
	Private cAccount  	:= GetMV('MV_EMCONTA')	//"wf@cobrecom.com.br"	GetMV('MV_WFMAIL')// Ex. gesse@microsiga.com.br
	Private cEnvia    	:= GetMV('MV_RELFROM')	//"wf@cobrecom.com.br"//GetMV('MV_WFMAIL')// Ex. gesse@microsiga.com.br
	Private cPassword 	:= GetMV('MV_EMSENHA')	//"wf5749wf" // Senha
	Private cCopia    	:= ""                 	// Email p/ copia
	Private cFile     	:= ""                   // Arquivo a ser anexado
	Private cMensagem 	:= ""
	Private lConectou 	:= .F.
	Private lEnviado  	:= .F.
	Private cError    	:= ""
	Private _cAcao		:= ""
	Private _cHTML 		:= ""

	//Verifica se o arquivo existe
	if !file(cArqTxt)
		MsgStop('Arquivo não existe, Email não enviado!','Erro')
	else
		//+---------------------------------------------------------------------+
		//| Abertura do arquivo texto                                           |
		//+---------------------------------------------------------------------+
		nHdl := fOpen(cArqTxt)

		If nHdl == -1
			IF FERROR()== 516
				u_autoAlert("Feche a planilha que gerou o arquivo.")
			EndIF
		EndIf

		// Testa a abertura do Arquivo
		If nHdl == -1
			MsgStop('Erro ao abrir origem. Ferror = '+str(ferror(),4),'Erro')
			Return .F.
		Endif

		//+---------------------------------------------------------------------+
		//| Verifica se foi possível abrir o arquivo                            |
		//+---------------------------------------------------------------------+
		If nHdl == -1
			cMsg1 := "O arquivo de nome "+cArqTxt+" nao pode ser aberto! Verifique os parametros."
			MsgAlert(cMsg1,"Atencao!")
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
		FT_FUse(cArqTxt)  //abre o arquivo
		FT_FGOTOP()         //posiciona na primeira linha do arquivo
		nTamLinha := Len(FT_FREADLN()) //Ve o tamanho da linha
		FT_FGOTOP()

		//+---------------------------------------------------------------------+
		//| Verifica quantas linhas tem o arquivo                               |
		//+---------------------------------------------------------------------+
		nLinhas := nTamArq/nTamLinha

		ProcRegua(nLinhas)
		//+---------------------------------------------------------------------+
		//| Envia Email com a variavel Texto                                    |
		//+---------------------------------------------------------------------+
		_cHTML:='<HTML><HEAD><TITLE></TITLE>'
		_cHTML+='<META http-equiv=Content-Type content="text/html; charset=windows-1252">'
		_cHTML+='<META content="MSHTML 6.00.6000.16735" name=GENERATOR></HEAD>'
		_cHTML+='<BODY>'
		_cHTML+='<H1><FONT size="2">'+'Favor analisar os dados abaixo' + ' </FONT></H1>'

		While !FT_FEOF() //Ler todo o arquivo enquanto não for o final dele
			IncProc()
			_cHTML+='<br><FONT size="2">'+FT_FREADLN()+'</FONT></br>'
			FT_FSKIP()
		EndDo
		FT_FUse()

		_cHTML+='<P></P>
		_cHTML+='<P><FONT size="2"><U> CobreCom - Tecnologia da Informação </U></FONT></P>'
		_cHTML+='</BODY></HTML>'


		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword SSL Result lConectou

		If !lConectou
			GET MAIL ERROR cError
			u_autoAlert(cError)
			Return
		Endif

		lAutent := MailAuth(cAccount,cPassword)

		ConfirmMailRead( .F. )
		SEND MAIL FROM cEnvia;
		TO cRecebe;
		SUBJECT cAssunto ;
		BODY  _cHTML;
		RESULT lEnviado

		If !lEnviado
			GET MAIL ERROR cError
			u_autoAlert(cError)
		Else
			Conout("Mensagem Enviada e Arquivos apagados")
			fClose(nHdl)
			fErase(cArqTxt)
		Endif

		DISCONNECT SMTP SERVER Result lConectou
		ConfirmMailRead(.F.)

		Return(lEnviado)
	EndIf
Return(.T.)

/*/{Protheus.doc} ArqEmAnDiv
//TODO Le arquivo de Log TXT e envia email.
@author juliana.leme
@since 01/04/2015
@version 1.0
@param cNomArq, Caracter, Arquivo a ser enviado
@param cRecebe, Caracter, Email do destinatario
@param cAssunto, Caracter, Assunto do corpo do email
@type function
/*/
User Function ArqEmAnDiv(cNomArq,cRecebe,cAssunto)
	Private cArqTxt 	:= "\cProva\"+cNomArq //Log.TXT
	Private nHdl 		:= 0
	Private cMsg1		:= ""
	Private nTamLinha	:= 0
	Private nTamArq		:= 0
	Private cserver   	:= GetMV('MV_RELSERV')	//GetMV('MV_RELSERV')// Servidor SMTP
	Private cAccount  	:= GetMV('MV_EMCONTA')	//"wf@cobrecom.com.br"	GetMV('MV_WFMAIL')// Ex. gesse@microsiga.com.br
	Private cEnvia    	:= GetMV('MV_RELFROM')	//"wf@cobrecom.com.br"//GetMV('MV_WFMAIL')// Ex. gesse@microsiga.com.br
	Private cPassword 	:= GetMV('MV_EMSENHA')	//"wf5749wf" // Senha
	Private cCopia    	:= ""                 	// Email p/ copia
	Private cFile     	:= ""                   // Arquivo a ser anexado
	Private cMensagem 	:= ""
	Private lConectou 	:= .F.
	Private lEnviado  	:= .F.
	Private cError    	:= ""
	Private _cAcao		:= ""
	Private _cHTML 		:= ""

	//Verifica se o arquivo existe
	If !file(cArqTxt)
		MsgStop('Arquivo não existe, Email não enviado!','Erro')
	Else
		//+---------------------------------------------------------------------+
		//| Envia Email com a variavel Texto                                    |
		//+---------------------------------------------------------------------+
		_cHTML:='<HTML><HEAD><TITLE></TITLE>'
		_cHTML+='<META http-equiv=Content-Type content="text/html; charset=windows-1252">'
		_cHTML+='<META content="MSHTML 6.00.6000.16735" name=GENERATOR></HEAD>'
		_cHTML+='<BODY>'
		_cHTML+='<H1><FONT size="3">'+'Corrigir Divergencia anexo' + ' </FONT></H1>'
		_cHTML+='<P></P>
		_cHTML+='<P><FONT size="2"><U> Cobrecom - Tecnologia da Informação </U></FONT></P>'
		_cHTML+='</BODY></HTML>'


		CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword SSL Result lConectou

		If !lConectou
			GET MAIL ERROR cError
			u_autoAlert(cError)
			Return
		Endif

		lAutent := MailAuth(cAccount,cPassword)

		ConfirmMailRead( .F. )
		SEND MAIL FROM cEnvia;
		TO cRecebe;
		SUBJECT cAssunto ;
		BODY  _cHTML;
		ATTACHMENT cArqTxt;
		RESULT lEnviado

		If !lEnviado
			GET MAIL ERROR cError
			u_autoAlert(cError)
		Else
			Conout("Mensagem Enviada e Arquivos apagados")
			fErase(cArqTxt)
		Endif

		DISCONNECT SMTP SERVER Result lConectou
		ConfirmMailRead(.F.)

		Return(lEnviado)
	EndIf
Return(.T.)

/*/{Protheus.doc} ArqEmAnex
//TODO Le arquivo de Log TXT e envia email
@author juliana.leme
@since 01/04/2015
@version 1.0
@param cNomArq, Caracter, Nome Arquivo a ser enviado anexo
@param cRecebe, Caracter, Destinatario da mensagem (Email)
@param cAssunto, Caracter, Assunto do Email
@param cAnexo, Caracter, Anexo a ser enviado para o destinatario
@type function
/*/
User Function ArqEmAnex(cNomArq,cRecebe,cAssunto,cAnexo)
	Private cArqTxt 		:= "\cProva\"+cNomArq //Log.TXT
	Private cArqTxtOk		:= "\cProva\"+cAnexo //Log.TXT
	Private cMsg1			:= ""
	Private cserver   	:= GetMV('MV_RELSERV')	//GetMV('MV_RELSERV')// Servidor SMTP
	Private cAccount  	:= GetMV('MV_EMCONTA')	//"wf@cobrecom.com.br"	GetMV('MV_WFMAIL')// Ex. gesse@microsiga.com.br
	Private cEnvia    	:= GetMV('MV_RELFROM')	//"wf@cobrecom.com.br"//GetMV('MV_WFMAIL')// Ex. gesse@microsiga.com.br
	Private cPassword 	:= GetMV('MV_EMSENHA')	//"wf5749wf" // Senha
	Private cCopia    	:= ""                 	// Email p/ copia
	Private cFile     	:= ""                   // Arquivo a ser anexado
	Private cMensagem 	:= ""
	Private lConectou 	:= .F.
	Private lEnviado  	:= .F.
	Private cError    	:= ""
	Private _cAcao		:= ""
	Private _cHTML 		:= ""

	//+---------------------------------------------------------------------+
	//| Envia Email com a variavel Texto                                    |
	//+---------------------------------------------------------------------+
	_cHTML:='<HTML><HEAD><TITLE></TITLE>'
	_cHTML+='<META http-equiv=Content-Type content="text/html; charset=windows-1252">'
	_cHTML+='<META content="MSHTML 6.00.6000.16735" name=GENERATOR></HEAD>'
	_cHTML+='<BODY>'
	_cHTML+='<H1><FONT size="2">'+'Relatórios Integração [PCF x Protheus]' + ' </FONT></H1>'
	_cHTML+='<P></P>
	_cHTML+='<P><FONT size="2"><U> Cobrecom - Tecnologia da Informação </U></FONT></P>'
	_cHTML+='</BODY></HTML>'


	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword SSL Result lConectou

	If !lConectou
		GET MAIL ERROR cError
		u_autoAlert(cError)
		ConsoleLog(" Não Conectei no Servidor SMTP")
		ConsoleLog("Server : "+ cServer + " Conta; "+ cAccount + " Senha; "+ cPassword )
		Return
	Endif

	ConsoleLog("Conectei no Servidor SMTP")

	lAutent := MailAuth(cAccount,cPassword)

	ConfirmMailRead( .F. )
	SEND MAIL FROM cEnvia;
	TO cRecebe;
	SUBJECT cAssunto ;
	BODY  _cHTML;
	ATTACHMENT cArqTxtOk,cArqTxt;
	RESULT lEnviado

	If !lEnviado
		ConsoleLog("Email Não Enviado")
		GET MAIL ERROR cError
		u_autoAlert(cError)
	Else
		ConsoleLog("Mensagem Enviada e Arquivos apagados")
		fErase(cArqTxt)
		fErase(cArqTxtOk)
	Endif

	DISCONNECT SMTP SERVER Result lConectou
	ConfirmMailRead(.F.)

	Return(lEnviado)
	U_LibErros()
Return(.T.)


/*/{Protheus.doc} LibErros
//TODO Limpa campo Comentarios para reanalisar os erros novamente.
@author juliana.leme
@since 26/04/2016
@version 1.0
@type function
/*/
User Function LibErros()
	Local _cQuery := ""
	TcSetConn(nHndPPI)
	IncProc("Aguarde, Liberando Movimentos com erros")

	//Altera Status de 0 para 1 Processando
	//Coloca os Registros de Integração em Processo
	_cQuery := " Update TBLOutInteg Set  "
	_cQuery += " Comments = Null "
	_cQuery += " Where Integrated = 3 "

	TCSqlExec(_cQuery)
	If (TCSqlExec(_cQuery) < 0) // Deu Erro
		//_lVolta := .T. // Significa que deu erro na função
		cMsg := TCSQLError() //+ linha
		MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
	EndIf
Return


/*/{Protheus.doc} ConsoleLog
//TODO Gera um log de eventos.
@author juliana.leme
@since 26/04/2016
@version 1.0
@param cTipo, Caracter, Tipo da Mensagem
@param cMsg, Caracter, Mensagem a ser identificada
@param cNomArq, Caracter, Nome do Arquivo a ser incluida a mensagem
@type function
/*/
User Function ConsoleLog(cTipo,cMsg,cNomArq)
	Private cArqTxt 	:= "\cProva\"+cNomArq //Log.TXT
	Private nHdl 		:= 0
	//Verifica se o arquivo existe
	if !file(cArqTxt)
		nHdl := fCreate(cArqTxt)
		if nHdl == -1
			MsgAlert("O arquivo de nome "+cArqtxt+" nao pode ser executado ! Verifique os parametros.","Atenção !")
			Return
		Endif
		if nHdl <> -1
			//cLin := "" + CRLF
			cLin := "----------------------------Log Eventos "+ dtoc(date()) + " as " + time() + "-------------------------------" + CRLF
			cLin += " Tipo: " + cTipo + CRLF
			cLin += " Msg: " + cMsg + CRLF
			cLin += "----------------------------Finalizado "+ dtoc(date()) + " as " + time() + "--------------------------------" + CRLF
			//cLin += "" + CRLF
			//Grava no arquivo texto
			if fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				if !MsgAlert("Ocorreu um erro na gravacao do arquivo." + "Continua !","Atencao !")
					Return(.F.)
				endif
			endif
		endif
	else
		// Abre o arquivo de Origem
		nHdl := fOpen(cArqTxt,1)
		// Testa a abertura do Arquivo
		If nHdl == -1
			MsgStop('Erro ao abrir origem. Ferror = '+str(ferror(),4),'Erro')
			Return .F.
		Endif
		fSeek(nHdl,0,2)
		//cLin := "" + CRLF
		cLin := "----------------------------Inicio Log Eventos "+ dtoc(date()) + " as " + time() + "-------------------------------" + CRLF
		cLin += " Tipo: " + cTipo + CRLF
		cLin += " Msg: " + cMsg + CRLF
		cLin += "----------------------------Finalizado "+ dtoc(date()) + " as " + time() + "--------------------------------" + CRLF
		//cLin += "" + CRLF
		//Grava no arquivo texto
		if fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
			if !MsgAlert("Ocorreu um erro na gravacao do arquivo." + "Continua !","Atencao !")
				Return(.F.)
			endif
		endif
	endif
	//Fecha o arquivo texto
	If !fClose(nHdl)
		Conout( "Erro ao fechar arquivo, erro numero: ", FERROR() )
	EndIf
Return(.T.)


/*/{Protheus.doc} ConsLogPCF
//TODO Função de Log do PCF para envio de log formatado em colunas.
@author juliana.leme
@since 20/04/2016
@version 1.0
@param cTipo, Caracter, Tipo do Log a ser gerado
@param cMsg, Caracter, Mensagem a ser incluida
@param cNomArq, Caracter, Nome do arquivo que sera incluida a mensagem
@type function
/*/
User Function ConsLogPCF(cTipo,cMsg,cNomArq)
	Private cArqTxt 	:= "\cProva\"+cNomArq //Log.TXT
	Private nHdl 		:= 0
	if GetNewPar('ZZ_ELOGPCF', .F.)
		//Verifica se o arquivo existe
		if !File(cArqTxt)
			nHdl := fCreate(cArqTxt)

			if nHdl == -1
				MsgAlert("O arquivo de nome "+cArqtxt+" nao pode ser executado ! Verifique os parametros.","Atenção !")
				Return
			Endif
			if nHdl <> -1
				//Cria primeiras Linhas do Relatorio Fixas
				cLin :=  ""
				iF cTipo <> "D"
					cLin += "ID         DATA       MOVIMENTO      OP           PRODUTO                 QTDE     ORIGEM          DESTINO         MOTIVO "
				Else
					cLin += "ID         DATA       MOVIMENTO     OP            PRODUTO          RECURSO          MOTIVO "
				EndIf

				cLin += "" + CRLF
				cLin += ""
				cLin += cMsg

				//Grava no arquivo texto
				if fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
					if !MsgAlert("Ocorreu um erro na gravacao do arquivo." + "Continua !","Atencao !")
						Return(.F.)
					endif
				endif
			endif
		else
			// Abre o arquivo de Origem
			nHdl := fOpen(cArqTxt,1)
			// Testa a abertura do Arquivo
			If nHdl == -1
				MsgStop('Erro ao abrir origem. Ferror = '+str(ferror(),4),'Erro')
				Return .F.
			Endif
			fSeek(nHdl,0,2)
			cLin := ""
			cLin += cMsg
			//Grava no arquivo texto
			if fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
				if !MsgAlert("Ocorreu um erro na gravacao do arquivo." + "Continua !","Atencao !")
					Return(.F.)
				endif
			endif
		EndIf
		//Fecha o arquivo texto
		If !fClose(nHdl)
			Conout( "Erro ao fechar arquivo, erro numero: ", FERROR() )
		EndIf
	endif
Return(.T.)


/*/{Protheus.doc} RetSaldoB2
//TODO Função que retorna o Saldo Atual do SB2.
@author juliana.leme
@since 04/11/2015
@version 1.0
@param cProduto, Caracter, Codigo de Produto a ser consultado
@param cLocal, Caracter, Codigo do Aramzem (Local) a ser consultado
@type function
/*/
User Function RetSaldoB2(cProduto,cLocal)
	Private aSaldos 	:= {}
	Private nQuant 	:= 0
	Private cMsgSld	:= ""
	Private _nPosPd	:= 0

	If ! Empty(cProduto) .and. ! Empty(cLocal)
		aSaldos	:= CalcEst(cProduto,cLocal, dDataBase+1)
		nQuant		:= aSaldos[1]
		If nQuant < 0
			_nPosPd := aScan(aProdNeg, {|x|x[1]== cProduto})
			If _nPosPd == 0
				cMsgSld	:= "Saldo do produto: "+ cProduto +" é :"+ Str(nQuant) +" no Local: "+ cLocal +" e esta NEGATIVO!"
				aAdd(aProdNeg,{cProduto,nQuant})
			Else
				aProdNeg[_nPosPd,2] := nQuant
			EndIf
		EndIf
	EndIf
Return(cMsgSld)

/*/{Protheus.doc} CBCEst240
//TODO Função que executa automatica o MATA240 (Req.Mod.1).
@author juliana.leme
@since 25/02/2015
@version 1.1
@type function
/*/
User Function CBCEst240() //U_CBCEst240()
	Local	aItens			:= 	{}
	Local 	cProduto		:=  ""
	Local 	IdEstorn		:=  ""

	If Select("RSD3_D") > 0
		DbSelectArea("RSD3_D")
		DbCloseArea("RSD3_D")
	EndIf

	cQUERY := " SELECT D3_FILIAL+D3_DOC FILDOC,"+;
				" D3_COD 				COD, "+;
				" D3_DOC 				DOC, "+;
				" D3_FILIAL 			FILIAL, "+;
				" D3_ZZUNMOV			UNMOV, "+;
				" D3_EMISSAO			EMISSAO, "+;
				" D3_TEMPES				TPES, "+;
				" D3_TM					TM, "+;
				" D3_OP					OP, "+;
				" count(*) 				NUM"+;
			" FROM SD3010 "+;
		" WHERE D_E_L_E_T_ = '' "+;
		 	" AND D3_HIST LIKE '%PCF%' "+;
		 	" AND D3_ESTORNO <> 'S' "+;
		 	" AND D3_EMISSAO > '20170131' "+;
		 	" AND D3_FILIAL = '"+FWCodFil()+"'"+;
		 " GROUP BY D3_DOC, D3_FILIAL, D3_ZZUNMOV, D3_EMISSAO, D3_COD, D3_TEMPES, D3_TM, D3_OP  "+;
		 " HAVING COUNT(*) >= 2  "+;
		 " Order By D3_DOC desc "
		 	//" and D3_TM <> '007' "+;
	If Select("RSD3_D")>0
		DbSelectArea("RSD3_D")
		DbCloseArea()
	EndIf

	TCQUERY cQuery NEW ALIAS "RSD3_D"

	dbSelectArea("RSD3_D")
	dbGoTop()

	Do While RSD3_D->(!Eof())
		DbSelectArea("SD3")
		DbSetOrder(2)
		DbSeek(xFilial("SD3")+ RSD3_D->DOC + RSD3_D->COD,.F.)
		nVez := 1
		While SD3->D3_DOC == RSD3_D->DOC .AND. SD3->D3_COD == RSD3_D->COD
		 	If nVez = 1
		 		nVez += 1
			Else
				If SD3->D3_ESTORNO	<> "S"
					aItens 	:= {{"D3_NUMSEQ",SD3->D3_NUMSEQ	,NIL},;
								{"INDEX"  	, 4				,NIL}}
					lMsErroAuto := .F.

					If Val(RSD3_D->TM) < 500 .AND. RSD3_D->TM == "007"
						MSExecAuto({|x,y| mata250(x,y)},aItens,5)
					Else
						MSExecAuto({|x,y| mata240(x,y)},aItens,5)
					EndIf
				EndIf
			EndIf
			SD3->(DBSkip())
		EndDo
		RSD3_D->(DBSkip())
	EndDo
	Alert("Terminou")
Return()

/*/{Protheus.doc} CBRatMPRec
//TODO Descrição auto-gerada.
@author juliana.leme
@since 05/12/2016
@version undefined

@type function
/*/
User Function CBRatMPRec()
Local aOpsRat 	:= {}
Local dDataAnt 	:= dDatabase
Local cQuery	:= ""
Local aItens	:= 	{}
Local cHist		:= 	""
Local nQtde		:= 0
Local nQtdePCF	:= 0
Local nPercSuct	:= 0
Local lRet 		:= .T.

	cHist 	:= "PCF;"+SUBSTRING((TRBPCF->REDE)+Space(3),1,3)+";"
	cHist 	+= SUBSTRING(TRBPCF->Recurso+Space(15),1,15)+";"
	cHist 	+= Alltrim(TRBPCF->Usuario)+";"
	cHist 	+= Substr(Alltrim(TRBPCF->HrEvento),1,2)+Substr(Alltrim(TRBPCF->HrEvento),4,2)+";"
	tcSetConn(nHndErp)

	nQtdePCF	:= Round(ABS(TRBPCF->Qtde),4)
	_cLocal := IIF(Right(Alltrim(TRBPCF->(EndOrigem)),3)=="WIP","99","01")
	_cEnder		:= ""
	
	/*
	Primeiro analisa Saldo Armaz "03"
	Caso tenha saldo disponivel, transferir, 
	Caso não tenha Devolver contra OP
	Juliana - 26/05/2017
	*/
	BEGIN TRANSACTION
		DbSelectArea("SB2")
		nQuantProt := 0
		nQuantProt := Posicione("SB2",1,xFilial("SB2") + Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1]) + "03","B2_QATU")
		If nQuantProt >= nQtdePCF
			//Tem tudo? Transfere Tudo!
			U_CBCTraMata(Alltrim(TRBPCF->Produto),"03",_cLocal,nQtdePCF,Alltrim(Str(TRBPCF->IDTrans)),+;
							"","")
			AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 2 Integrado
			nQtdePCF := 0
			lRet := .T.
		Else
			//Não Tem Tudo e é Maior que 0 ? Transfere o que e devolve o restante!
			If nQuantProt > 0 
				nQtdePCF := nQtdePCF - nQuantProt
				U_CBCTraMata(Alltrim(TRBPCF->Produto),"03",_cLocal,nQtdePCF,Alltrim(Str(TRBPCF->IDTrans)),+;
							"","")
			EndIf
		EndIf
		
		If nQtdePCF > 0 
			cQuery := " SELECT SUM(D3_QUANT) QTDE, "
			cQuery +=			" D3_OP OP, "
			cQuery +=			" MAX(D3_EMISSAO) DTEMISS "
			cQuery +=			" FROM SD3010 D3 "
			cQuery +=		  " WHERE D3_FILIAL = '" + xFilial("SB2") +  "' "
			cQuery +=		  	" AND D3_GRUPO = 'MP04' "
			cQuery +=		  	" AND D3_EMISSAO >= '" + DtoS(DaySub(StoD(TRBPCF->DtEvento),20)) + "' "
			cQuery +=		  	" AND D3_EMISSAO > '" + DtoS(GetNewPar('ZZ_ULTBLK', GetMV("MV_DBLQMOV"))) + "' "
			cQuery +=		  	" AND D3_ESTORNO <> 'S' "
			cQuery +=		  	" AND D3.D_E_L_E_T_ = '' "
			cQuery +=		  	" AND D3_TM = '504' "
			cQuery +=		  	" AND D3.D3_COD = '" + Alltrim(TRBPCF->Produto) + "' "
			cQuery +=		  " GROUP BY  D3_COD, "
			cQuery +=		  			" D3_UM, "
			cQuery +=		  			" D3_OP "
		
			If Select("RSD3_RAT")>0
				DbSelectArea("RSD3_RAT")
				DbCloseArea()
			EndIf
		
			TCQUERY cQuery NEW ALIAS "RSD3_RAT"
		
			dbSelectArea("RSD3_RAT")
			dbGoTop()
		
			nQtdeRat := 0
			//Somar As Quantidades para Rateio
			Do While RSD3_RAT->(!Eof())
				nQtdeRat	+= RSD3_RAT->QTDE
				RSD3_RAT->(DbSkip())
			EndDo
		
			dbGoTop()
		
			If nQtdeRat > 0
				lRet := .T.
				//Varre as Ops para realizar o rateio
				Do While RSD3_RAT->(!Eof())
					// nQtdePCF - Qtde Apontada
					// nQtdeRat - Qtde em OPs
					// RSD3_RAT->QTDE - Qtde da OP
					nQtde := (nQtdePCF * RSD3_RAT->QTDE) / nQtdeRat
		
					If nQtde > 0
						aItens 	:= {{"D3_TM"				,Padr("007",TamSX3("D3_TM")[1])	 													,NIL},; //TP.MOVIM.
											{"D3_COD" 			,Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1])				,NIL},; //D3_COD
											{"D3_DOC"			,Padr(Alltrim(Str(TRBPCF->IDTrans)),TamSX3("D3_DOC")[1])		,NIL},; //TP.MOVIM.
											{"D3_UM" 				,Posicione("SB1",1,xFilial("SB1")+Alltrim(TRBPCF->Produto),"B1_UM")	,NIL},;
											{"D3_LOCAL" 		,Padr(_cLocal,TamSX3("D3_LOCAL")[1])											,NIL},;
											{"D3_LOCALIZ" 	,Padr(_cEnder,TamSX3("D3_LOCALIZ")[1])										,NIL},;
											{"D3_QUANT" 		,Round(ABS(nQtde),4)																			,NIL},;
											{"D3_HIST" 			,Padr(cHist,TamSX3("D3_HIST")[1])						  							,NIL},;
											{"D3_OP" 				,Padr(Alltrim(RSD3_RAT->OP),TamSX3("D3_OP")[1])				  		,NIL},;
											{"D3_EMISSAO" 	,StoD(Alltrim(RSD3_RAT->DTEMISS))/*TRBPCF->DtEvento)*/	,NIL},;
											{"D3_PARCTOT" 	,Padr("P",TamSX3("D3_PARCTOT")[1])						   						,NIL},;
											{"D3_ZZLOTE" 		,Padr(Alltrim(TRBPCF->Lote),TamSX3("D3_ZZLOTE")[1])		  		,NIL},;
											{"D3_ZZUNMOV" 	,TRBPCF->UnMov																					,NIL}}

						tcSetConn(nHndErp)
						/*
						lMsErroAuto 	:= .F.
						RPCSetType(3)
						RPCSetEnv('01',xFilial("SD3"),,,'EST',GetEnvServer(),{} )
		
						MSExecAuto({|x,y| mata240(x,y)},aItens,3)
		
						If !lMsErroAuto
						*/
						oExec := cbcExecAuto():newcbcExecAuto(aItens,/*aAutoCab*/,.F.)
						oExec:setFilial(FwFilial())
						oExec:exAuto('MATA240',3,,"EST")
						aRet := oExec:getRet()
						FreeObj(oExec)
	
						if aRet[1]	
							U_MontaLog("N")
							cMsg 		+= " " + CRLF
							U_ConsLogPCF("N",cMsg,cArqOk)
							AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 2 Integrado
							If lMenu
								oApp 		:= oApp_ori
							EndIf
						Else
							U_MontaLog("N")
							cErro		:= aRet[2]
							cMsg 		+= SubsTr(cErro,1,180)+ CRLF
							U_ConsLogPCF("N",cMsg,cArqErr)
							AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),SubsTr(cErro,1,180)) //Altera de 1 para 3 ERRO
							
							If lMenu
								oApp 		:= oApp_ori
							EndIf
							DISARMTRANSACTION()
							Return( .F. )
						EndIf
					Else
						DISARMTRANSACTION()
						AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),"NÃO ENCONTRADA OP PARA RATEIO") //Altera de 1 para 3 ERRO
					EndIf
					//Pula Registro
					RSD3_RAT->(DbSkip())
				EndDo
			Else
				DISARMTRANSACTION()
				lRet := .F.
			EndIf
		EndIf
	END TRANSACTION
	tcSetConn(nHndErp)
Return(lRet)

/*/{Protheus.doc} U_CBDesmSuc
//TODO Desmonta o Produto para a Sucata para Armazem 91.
@author juliana.leme
@since 12/12/2016
@version undefined

@type function
/*/
User Function CBDesmSuc()
Local cLocal 	:= ""
Local cEnder	:= ""

	cHist 	:= "PCF;"+SUBSTRING((TRBPCF->REDE)+Space(3),1,3)+";"
	cHist 	+= SUBSTRING(TRBPCF->Recurso+Space(15),1,15)+";"
	cHist 	+= Alltrim(TRBPCF->Usuario)+";"
	cHist 	+= Substr(Alltrim(TRBPCF->HrEvento),1,2)+Substr(Alltrim(TRBPCF->HrEvento),4,2)+";"
	tcSetConn(nHndErp)

	nQtdePCF	:= Round(ABS(TRBPCF->Qtde),4)
	If Alltrim(cTipoB1) <> "PA"
		cLocal 	:= Padr("99",TamSX3("D3_LOCAL")[1])
		cEnder	:= ""
	Else
		cLocal	:= Padr("20",TamSX3("D3_LOCAL")[1])
		cEnder	:= "PROD_PCF"
	EndIf

	//Analise se Produto existe no Armaazem de Destino
	DBSelectArea("SB2")
	SB2->(DbSetOrder(1))
	If !SB2->(DbSeek(xFilial("SB2")+Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1])+cLocal,.F.))
		CriaSB2(Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1]),cLocal)
	EndIf

	_nQtdSuc	:= 0

	If nQtdePCF > 0
		// Fazer transferência da quantidade para sucata
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1]),.F.)

		lMsErroAuto := .F.

		aAutoCab := {   {"cProduto" , Padr(Alltrim(TRBPCF->Produto),TamSX3("D3_COD")[1]), 	Nil},;
						{"cLocOrig" , cLocal, 												Nil},;
						{"cLocaliza" , cEnder, 												Nil},;
						{"nQtdOrig" , Round(nQtdePCF,4), 									Nil},;
						{"cDocumento" , Alltrim(Str(TRBPCF->IDTrans)), 						Nil}}

		_nQtdSuc := Max((nQtdePCF * (SB1->B1_PESCOB+SB1->B1_PESPVC)),1)

		If SB1->B1_PESPVC == 0
			_cPrdSct := "SC01000001" // Cobre Nú
		Else
			_cPrdSct := "SC01000002" // Cobre Isolado
		EndIf

		SB2->(DbSetOrder(1))
		If !SB2->(DbSeek(xFilial("SB2")+Padr(Alltrim(_cPrdSct),TamSX3("D3_COD")[1])+"91",.F.))
			CriaSB2(Padr(Alltrim(_cPrdSct),TamSX3("D3_COD")[1]),"91")
		EndIf

		aAutoItens := {{    {"D3_COD", 	 Pad(_cPrdSct, Len(SD3->D3_COD)), 	Nil},;
							{"D3_LOCAL", "91", 								Nil},;
							{"D3_QUANT", Round(_nQtdSuc, 4), 				Nil},;
							{"D3_RATEIO",100, 								Nil}}}
		RPCSetType(3)
		RPCSetEnv('01',xFilial("SD3"),,,'EST',GetEnvServer(),{} )

		MSExecAuto({|v,x,y,z| Mata242(v,x,y,z)},aAutoCab,aAutoItens,3,.T.)

		If lMsErroAuto
			U_MontaLog("N")
			cErro		:= StrTran(StrTran(Alltrim(MemoRead(NomeAutoLog())),chr(13) + chr(10)," "),chr(10),"")
			cMsg 		+= SubsTr(cErro,1,180)+ CRLF
			U_ConsLogPCF("N",cMsg,cArqErr)
			AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),SubsTr(cErro,1,180)) //Altera de 1 para 3 ERRO
			If lMenu
				oApp 		:= oApp_ori
			EndIf
		Else
			U_MontaLog("N")
			cMsg 		+= " " + CRLF
			U_ConsLogPCF("N",cMsg,cArqOk)
			AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 2 Integrado
			If lMenu
				oApp 		:= oApp_ori
			EndIf
		EndIf
	Endif
	tcSetConn(nHndErp)
Return


/*/{Protheus.doc} CBRetSldB2
//TODO Retorna Saldo do SB2
@author juliana.leme
@since 14/12/2016
@version undefined
@param cProduto, characters, descricao
@param cLocal, characters, descricao
@type function
/*/
User Function CBRetSldB2(cProduto,cLocal)
	Private aSaldos 	:= {}
	Private nQuant 	:= 0
	Private cMsgSld	:= ""
	Private _nPosPd	:= 0

	If ! Empty(cProduto) .and. ! Empty(cLocal)
		aSaldos	:= CalcEst(cProduto,cLocal, dDataBase+1)
		nQuant		:= aSaldos[1]
	EndIf
Return(nQuant)

User Function CBDesmDoc()
Local cLocal 	:= ""
Local cEnder	:= ""
Local cNumDoc,cSerieDoc := ""
Local aPergs   	:= {}
Local aRet	   	:= {}
Local oApp_ori	:= oApp

    aAdd(aPergs,{1,"Serie Doc Sucata ?","1  ","@!","","","",5,.T.}) // Tipo Texto
    aAdd(aPergs,{1,"Num Doc Sucata ?","         ","@!","","","",30,.T.}) // Tipo Texto

    If ParamBox(aPergs ,"Serie/Num Documento Sucata",aRet)
    	cNumDoc := aRet[2]
    	cSerieDoc := aRet[1]
    EndIf

	DbSelectArea("SD1")
	DbSetOrder(1)
	If SD1->(DbSeek(xFilial("SD1") + cNumDoc + cSerieDoc,.F.))
		While cNumDoc == SD1->D1_DOC .and. cSerieDoc == SD1->D1_Serie .and.  SD1->(! Eof())
			//Analise se Produto existe no Armaazem de Destino
			DBSelectArea("SDB")
			SDB->(DbSetOrder(1))
			cAcondi := Posicione("SDB",1,xFilial("SDB")+SD1->D1_COD + SD1->D1_LOCAL + SD1->D1_NUMSEQ,"DB_LOCALIZ")

			DBSelectArea("SB1")
			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1") + SD1->D1_COD,.F.))//SD1->D1_ITEM

			_nQtdSuc	:= 0

			aAutoCab := {{"cProduto" , SD1->D1_COD			, Nil},;
						{"cLocOrig"  , SD1->D1_LOCAL		, Nil},;
						{"cLocaliza" , cAcondi				, Nil},;
						{"nQtdOrig"  , SD1->D1_QUANT		, Nil},;
						{"cDocumento", SD1->D1_DOC			, Nil}}

			_nQtdSuc := Max((SD1->D1_QUANT * (SB1->B1_PESCOB+SB1->B1_PESPVC)),1)

			If SB1->B1_PESPVC == 0
				_cPrdSct := "SC01000001" // Cobre Nú
			Else
				_cPrdSct := "SC01000002" // Cobre Isolado
			EndIf

			SB2->(DbSetOrder(1))
			If !SB2->(DbSeek(xFilial("SB2")+Padr(Alltrim(_cPrdSct),TamSX3("D3_COD")[1])+"91",.F.))
				CriaSB2(Padr(Alltrim(_cPrdSct),TamSX3("D3_COD")[1]),"91")
			EndIf

			aAutoItens := {{	{"D3_COD"    , Pad(_cPrdSct, Len(SD3->D3_COD))	, Nil}, ;
										{"D3_LOCAL"  , "01"																	, Nil}, ;
										{"D3_QUANT"  , _nQtdSuc															, Nil}, ;
										{"D3_USUARIO", cUserName													, Nil}, ;
										{"D3_RATEIO" , 100																		, Nil}}}

			MSExecAuto({|v,x,y,z| Mata242(v,x,y,z)},aAutoCab,aAutoItens,3,.T.)

			If lMsErroAuto

				Alert("Erro na Desmontagem do Produto :" + SD1->D1_COD + " e da NF :" + SD1->D1_DOC )
			Endif
			//Próx Registro
			SD1->(DbSkip())
		EndDo
		Alert("Processo Finalizado")
	Else
		Alert("NF Não encontrada!")
	EndIf
	oApp 		:= oApp_ori
Return

User Function CBDesPl()
Local cLocal 	:= ""
Local cEnder	:= ""
Local cProduto,cAcond,cLocal,cDoc := ""
Local nQtde,nSaldBF		:= 0
Local lSai		:= .T.
Local aPergs   	:= {}
Local aRet	   	:= {}
Local lMsErroAuto := .F.
Local oApp_ori	:= oApp

    aAdd(aPergs,{1,"Produto: ",Space(17),"@!","","","",40,.T.}) // Tipo Texto
    aAdd(aPergs,{1,"Acondicionamento: ",Space(10),"@!","","","",30,.F.}) // Tipo Texto
    aAdd(aPergs,{1,"Armazem: ","01","@!","","","",5,.T.}) // Tipo Texto
    aAdd(aPergs,{1,"Quantd: ",0,"@E 999,999.9999","mv_par04>0","","",60,.T.}) // Tipo Texto
    aAdd(aPergs,{1,"Num Docto: ",Space(8),"@!","","","",30,.T.}) // Tipo Texto

    While lSai
	    If ParamBox(aPergs ,"Produto/Acond para Sucata",aRet)
	    	cProduto	:= Padr(aRet[1],TamSX3("BF_PRODUTO")[1])
	    	cAcond		:= Padr(aRet[2],TamSX3("BF_LOCALIZ")[1])
	    	cLocal		:= Padr(aRet[3],TamSX3("BF_LOCAL")[1])
	    	nQtde		:= aRet[4]
	    	cDoc		:= Padr(aRet[5],TamSX3("D3_DOC")[1])
	    Else
	    	lSai := .F.
	    	Return(.T.)
	    EndIf

		DbSelectArea("SBF")
		DbSetOrder(1)
		//Posiciona
		If SBF->(DbSeek(xFilial("SBF") + cLocal + cAcond + cProduto)) .or. Empty(cAcond)
			//Encontrou o endereço ?
			//Procura o Saldo
			nSaldBF := SBFSaldo()
			If  (nSaldBF > 0 .and. nSaldBF >= nQtde) .or. Empty(cAcond)

				DBSelectArea("SB1")
				SB1->(DbSetOrder(1))
				SB1->(DbSeek(xFilial("SB1") + cProduto,.F.))//SD1->D1_ITEM

				_nQtdSuc	:= 0

				//lMsErroAuto := .F.
				aAutoCab := {{"cProduto" , cProduto		, Nil},;
							{"cLocOrig"  , cLocal		, Nil},;
							{"cLocaliza" , cAcond		, Nil},;
							{"nQtdOrig"  , nQtde		, Nil},;
							{"cDocumento", cDoc			, Nil}}

				_nQtdSuc := Max((nQtde * (SB1->B1_PESCOB+SB1->B1_PESPVC)),1)

				If SB1->B1_PESPVC == 0
					_cPrdSct := "SC01000001" // Cobre Nú
				Else
					_cPrdSct := "SC01000002" // Cobre Isolado
				EndIf

				SB2->(DbSetOrder(1))
				If !SB2->(DbSeek(xFilial("SB2")+Padr(Alltrim(_cPrdSct),TamSX3("D3_COD")[1])+"91",.F.))
					CriaSB2(Padr(Alltrim(_cPrdSct),TamSX3("D3_COD")[1]),"91")
				EndIf

				aAutoItens := {{	{"D3_COD"    , Pad(_cPrdSct, Len(SD3->D3_COD))	, Nil}, ;
									{"D3_LOCAL"  , "91"								, Nil}, ;
									{"D3_QUANT"  , _nQtdSuc							, Nil}, ;
									{"D3_USUARIO", cUserName						, Nil}, ;
									{"D3_RATEIO" , 100								, Nil}}}

				MSExecAuto({|v,x,y,z| Mata242(v,x,y,z)},aAutoCab,aAutoItens,3,.T.)

				If lMsErroAuto
					Alert("Erro na Desmontagem do Produto :" + cProduto + " Acondicionamento " + cAcond )
					Alert("Processo não realizado!")
					MostraErro()
				Endif
				Alert("Processo Concluido, Sucata Finalizada!")
			Else
				Alert("Produto SEM SALDO no Armazem informado, Saldo Disponivel :"+Str(nSaldBF))
				Alert("Processo não realizado!")
			EndIf
		Else
			Alert("Produto + Localização NÃO encontrado")
		EndIf
	EndDo
	oApp 		:= oApp_ori
Return


/*/{Protheus.doc} ConsoleLog
@author bolognesi
@since 28/12/2016
@version 1.0
@param cMsg, characters, Mensagem a ser exibida
@type function
/*/
static function ConsoleLog(cMsg)
	ConOut("[CDRETPPI - "+DtoC(Date())+" - "+Time()+" ] "+cMsg)
return

/*/{Protheus.doc} ProdVergPCF
//TODO Descrição auto-gerada.
@author juliana.leme
@since 03/01/2017
@version undefined
@type function
/*/
Static Function ProdVergPCF(cOper)
Local lRet			:= .T.
Local _cQry			:= ""
Local cNumNota		:= ""
Local cNumSerie 	:= ""
Local cLote			:= ""
Default	cOper		:= ""

	TcSetConn(nHndPPI)
	If !Empty(cOper)
		If cOper $ "PR0"
			_cQry := "SELECT LotCode LOTE_RE"
			_cQry += " FROM TBLOutInteg "
			_cQry += " WHERE TraceLotCode = '" + TRBPCF->Lote + "'"
			_cQry += " AND SUBSTRING(MovTypeCode,1,2) = 'RE' "
					
			_cQry := ChangeQuery(_cQry)
		
			If Select("TRBPCF_1")>0
				DbSelectArea("TRBPCF_1")
				DbCloseArea()
			EndIf
		
			TCQUERY _cQry NEW ALIAS "TRBPCF_1"
		
			DbSelectArea("TRBPCF_1")
			DbGotop()
				
			cLote := TRBPCF_1->LOTE_RE
		Else
			cLote := TRBPCF->Lote
		EndIf
			
		If !Empty(cLote)				
			_cQry := "SELECT  DocNumber NUM_NF, CompanyCode FORNEC_NF, ProductCode PRODUTO"
			_cQry += " FROM TBLOutInteg "
			_cQry += " WHERE LotCode = '" + cLote + "'"
			_cQry += " AND SUBSTRING(MovTypeCode,1,2) = 'DE' "
					
			_cQry := ChangeQuery(_cQry)
					
			If Select("TRBPCF_2")>0
				DbSelectArea("TRBPCF_2")
				DbCloseArea()
			EndIf
					
			TCQUERY _cQry NEW ALIAS "TRBPCF_2"
					
			DbSelectArea("TRBPCF_2")
			DbGotop()
					
			If !Empty(TRBPCF_2->NUM_NF)
				tcSetConn(nHndErp)
						
				cNumNota := Left( TRBPCF_2->NUM_NF,At("/",TRBPCF_2->NUM_NF)-1) 
				cNumSerie := Alltrim(Substr( TRBPCF_2->NUM_NF,At("/",TRBPCF_2->NUM_NF)+1,Len(TRBPCF_2->NUM_NF))) 
					
				_cQry := "SELECT  D1_COD , D1_TES TES, F4_ESTOQUE ESTOQUE "
				_cQry += " FROM SD1010 D1 "
				_cQry += " LEFT JOIN SF4010 F4  ON F4_FILIAL = '  '  AND F4_CODIGO = D1_TES AND F4.D_E_L_E_T_ = D1.D_E_L_E_T_ "
				_cQry += " WHERE D1_FILIAL = '" +  xFilial("SD1") + "'"
				_cQry += "  AND D1_DOC = '" + cNumNota + "'"
				_cQry += "  AND D1_SERIE LIKE  '%" + cNumSerie +"%' "
				_cQry += "  AND D1_FORNECE+D1_LOJA = '" +TRBPCF_2-> FORNEC_NF +"'"
				_cQry += "  AND D1.D_E_L_E_T_ = '' "
					
				_cQry := ChangeQuery(_cQry)
						
				If Select("TRBNFCL")>0
					DbSelectArea("TRBNFCL")
					DbCloseArea()
				EndIf
					
				TCQUERY _cQry NEW ALIAS "TRBNFCL"
					
				DbSelectArea("TRBNFCL")
				DbGotop()
				cMsgVerg	:= ""
				
				while TRBNFCL->(!Eof())
					If Alltrim(TRBNFCL->D1_COD) == Alltrim(TRBPCF_2->PRODUTO)
						If !Empty(TRBNFCL-> TES)	
							If Alltrim(TRBNFCL-> ESTOQUE) == "S" .or. (TRBNFCL-> TES $ "499")
								cMsgVerg := ""
								cIntegVerg	:= "2"
								lRet := .T.
								EXIT
							Else
								cMsgVerg	:= "PRODUTO CLASSIFICADO NA NF " + TRBPCF_2->NUM_NF + " NÃO ATUALIZA ESTOQUE, INTEGRAÇÃO NÃO REALIZADA!"
								cIntegVerg	:= "3"
								lRet := .F.
								//EXIT
							EndIf
						Else
							cMsgVerg := "NOTA FISCAL " + TRBPCF_2->NUM_NF + " NÃO CLASSIFICADA, VERIFICAR PROTHEUS!"
							cIntegVerg	:= "3"
							lRet := .F.
							//EXIT
						EndIf
					Else
						cMsgVerg := "PRODUTO NÂO CORRESPONDE AO CLASSIFICADO NA NF "+ TRBPCF_2->NUM_NF +", INTEGRAÇÂO NÂO REALIZADA!"
						cIntegVerg := "5"
						lRet := .F.
						//EXIT
					EndIf
					TRBNFCL->(DbSkip())
				endDo
			Else
				cMsgVerg := "NOTA FISCAL NÃO INFORMADA, VERIFICAR!"
				cIntegVerg := "2"
				lRet := .T.
			EndIf
		Else
			cMsgVerg := "LOTE NÃO ENCONTRADO DO PCFACTORY, VERIFICAR!"
			cIntegVerg := "3"
			lRet := .F.
		EndIf
	EndIf
	TcSetConn(nHndERP)
Return(lRet)


User Function CbcDesme(_cUnmov, nMyOpcao)
	Local	aItens			:= 	{}
	Local	cD3Seq			:= ""
	Local 	oSql			:= nil
	Local 	oMemo		 	:= nil
	Local 	cQuery	  		:= ""
	Local 	aRet			:= {}	
	
	tcSetConn(nHndErp) 
	
	_cUnmov := Padr(_cUnmov,TamSX3("D3_ZZUNMOV")[1])
	
	cQuery += " SELECT D3.D3_ZZUNMOV UNMOV, D3.D3_DOC DOC, D3.D3_TEMPES TEMPES, D3.D3_NUMSEQ NUMSEQ "
	cQuery += " FROM SD3010 D3
	cQuery += " WHERE %SD3.XFILIAL% "
	cQuery += " AND D3_ZZUNMOV = '" + _cUnmov + "'"
	cQuery += " AND D3_CF = 'PR0' "
	cQuery += " AND D3.D_E_L_E_T_ = '' "
	cQuery += " AND D3_ESTORNO <> 'S' "
	
	
	oSql := LibSqlObj():newLibSqlObj()	
	oSql:newAlias( cQuery )
	
	If !oSql:hasRecords()
		U_MontaLog("N")
		cErro		:= "UNIMOV NÃO LOCALIZADA PARA DESMEMBRAMENTO"
		cMsg 		+= SubsTr(cErro,1,180)+ CRLF
		U_ConsLogPCF("N",cMsg,cArqErr)
		AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),SubsTr(cErro,1,180)) //Altera de 1 para 3 ERRO
		If lMenu
			oApp 		:= oApp_ori
		EndIf
	Else
		oMemo 	:= ManBaseDados():newManBaseDados()
		oSql:goTop()
		If oSql:getValue("TEMPES") <> "F"//S	
			//Estorna SDA antes do estorno de produção			
			//Realiza o Estorno da Distribuição
			DbSelectArea("SDA")
			DbSetOrder(5) // DA_FILIAL+DA_DOC
			DbSeek(xFilial("SDA") + Padr(oSql:getValue("DOC"),TamSX3("D3_DOC")[1]),.F.)
			
			aCab  := {{"DA_PRODUTO"		,SDA->DA_PRODUTO			, nil},;
					  {"DA_NUMSEQ"   	,SDA->DA_NUMSEQ				, nil}}
	
			aItens:={ { {"DB_ITEM"	  	, "0001"									, nil},;
						{"DB_ESTORNO" 	, "S "										, nil},;
						{"DB_LOCALIZ" 	, "PROD_PCF"								, nil},;
						{"DB_DATA"    	, SDA->DA_DATA								, nil},;
						{"DB_QUANT"   	, SDA->DA_QTDORI							, nil}}}
				
			lMsErroAuto := .F.
			//Executa o endereçamento do item
			MATA265( aCab, aItens, 4)
			If lMsErroAuto			
				U_MontaLog("N")
				cErro		:= StrTran(StrTran(Alltrim(SubsTr(MemoRead(NomeAutoLog()),nTamMsg)),chr(13) + chr(10)," "),chr(10),"")
				cMsg 		+= SubsTr(cErro,1,180)+ CRLF
				nTamMsg	:= Len(MemoRead(NomeAutoLog()))
				U_ConsLogPCF("N",cMsg,cArqErr)
				AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),SubsTr(cErro,1,180)) //Altera de 1 para 3 ERRO
				If lMenu
					oApp 		:= oApp_ori
				EndIf
				Return()
			EndIf
			aItens 	:= {{"D3_NUMSEQ"	,Padr(oSql:getValue("NUMSEQ"),TamSX3("D3_NUMSEQ")[1])	,NIL},; //TP.MOVIM.
						{"D3_CF"		,"PR0"													,NIL},;
						{"INDEX"		, 4			    										,NIL}}
		
			oExec := cbcExecAuto():newcbcExecAuto(aItens,/*aAutoCab*/,.F.)
			oExec:exAuto('MATA250',nMyOpcao,,"EST")
			aRet := oExec:getRet()
			FreeObj(oExec)
		
			If !aRet[1]	
				U_MontaLog("N")
				cErro		:= aRet[2]	
				cMsg 		+= SubsTr(cErro,1,180)+ CRLF
				U_ConsLogPCF("N",cMsg,cArqErr)
				AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),SubsTr(cErro,1,180)) //Altera de 1 para 3 ERRO
				If lMenu
					oApp 		:= oApp_ori
				EndIf
			Else
				U_MontaLog("N")
				cMsg 		+= " " + CRLF
				U_ConsLogPCF("N",cMsg,cArqOk)
				AlterStatPPI("","2",Alltrim(Str(TRBPCF->IDTrans))) //Altera de 1 para 2 Integrado
				If lMenu
					oApp 		:= oApp_ori
				EndIf
			EndIf
		Else
			U_MontaLog("N")
			cMsg 		+= "Erro Pesagem Ja Processada! Não pode ser DESMEMBRADO!" + CRLF
			U_ConsLogPCF("N",cMsg,cArqErr)
			AlterStatPPI("","3",Alltrim(Str(TRBPCF->IDTrans)),"ERRO PESAGEM JA PROCESSADA, NÃO PODE SER DESMEMBRADO") //Altera de 1 para 3 ERRO
			If lMenu
				oApp 		:= oApp_ori		
			EndIf
		EndIf
	FreeObj(oMemo)	
	EndIf
	
	oSql:close() 
	FreeObj(oSql)
Return


Static function HandleEr(oErr)
	local cLogData := DtoC(Date()) + " - " + Time()
	if InTransact()
		DisarmTransaction()
	endif
	conout(cLogData + 'HndErr-'+ '[' + Alltrim(oErr:Description) + ']')
	TcSetConn(nHndERP)
	UnLockByName("CDRETPPI",.F.,.F.,.T.)
	BREAK
return(nil)
