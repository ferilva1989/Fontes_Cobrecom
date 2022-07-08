#include 'protheus.ch'
#include 'parmtype.ch'

user function EstPCFUn()
	Local cArq		:= ""
	Local cOrigem	:= ""
	Local aDados	:= {}
	Private nPrtPPI	:= GetNewPar("ZZ_PORTADB", "7890")		// Porta
	Private nHndPPI			//Handler do banco de dados de integração
	Private nHndErp	:= AdvConnection()
	Private cDB_PPI := GetMV("ZZ_HNDPCF")//"MSSQL/PCFactory" //"MSSQL/PCF_Integ"	//Tipo e nome do banco de integração (PC-Factory) (OFICIAL)
	Private cSrvPPI := GetMV("ZZ_SRVPPI") //"192.168.3.2"		//Servidor onde está o banco de integração (OFICIAL)

	// Cria uma conexão com um outro banco, outro DBAcces
	nHndPPI := TcLink(cDb_PPI,cSrvPPI,nPrtPPI)
	//Conecta com PPI
	TcSetConn(nHndPPI)
	//Caso a conexão não seja realizada
	If nHndPPI < 0
		Alert("Falha ao conectar com " + cDB_PPI + " em " + cSrvPPI + ":" + Str(nPrtPPI,4))
		TcUnLink(nHndPPI)
		TcSetConn(nHndERP)
		Return()
	EndIf

	cArq 		:= "ItMatriz.xls"
	cOrigem		:= "E:\Item"

	Processa( {|| aDados:= U_CargaXLS(cArq,cOrigem,,.F.)},"Aguarde, carregando planilha...Pode demorar")
	
	If Len(aDados) > 0
		Processa( {|| Importa(aDados) },"Importando Dados Contabeis")
	EndIf	
return

Static Function Importa(aArrInf)
	local _cQuery	:= ""
	Local cMsg		:= ""
	local nCont		:= 2

	While nCont <= Len (aArrInf)
		If !Empty(aArrInf[nCont,1])
			_cQuery := " Update TBLMovUn set  "
			_cQuery += " OutDocNumber = NULL ,"
			_cQuery += " DtOut = NULL ,
			_cQuery += " MovUnQty =  " + Str(Val(StrTran(StrTran(aArrInf[nCont,2],".",""),",",".")))   
			_cQuery += " WHERE IDMovUn =  " + aArrInf[nCont,1]
			
			TCSqlExec(_cQuery)
			
			If (TCSqlExec(_cQuery) < 0) // Deu Erro
				cMsg := TCSQLError() //+ linha
				MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
			EndIf
		EndIf
		nCont += 1
	EndDo
Return