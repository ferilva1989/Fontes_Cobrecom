#include 'protheus.ch'
#include 'rwmake.ch'
#include 'topconn.ch'
#include "tbiconn.ch"
#INCLUDE "TOTVS.CH"


/*/{Protheus.doc} CDEstUnmov
//TODO Realiza o estorno da UnMov no banco do PCFactory.
@author juliana.leme
@since 27/09/2016
@version undefined

@type function
/*/
User Function CDEstUnmov() // U_CDEstUnmov()
    Local aPergs   	:= {}
    Local aRet	   	:= {}
    Local lContin	:= .T.

    aAdd(aPergs,{1,"UnMov Estornar?",0,"@E 9999999999","mv_par01>0","","",40,.F.}) // Tipo numérico
    While lContin
    	If ParamBox(aPergs ,"Estorno de UnMov Protheus",aRet)
    		If aRet[1] > 0
    			EstUnMov(aRet[1])
    		Else
    			Aviso("Nenhuma UnMov Estornada!")
    		EndIf
    	Else
    		Alert("Processo cancelado")
    		Return(.F.)
    	EndIf
    	//Validar se operação continua
    	lContin := MsgBox("Deseja Estornar outra UnMov?","Confirma?","YesNo")
    EndDo
Return(.T.)

/*/{Protheus.doc} EstUnMov
//TODO Estorna UnMov indicada no Banco PCFactory.
@author juliana.leme
@since 27/09/2016
@version undefined
@param nUnMov, numeric, UnMov a ser estornada
@type function
/*/
Static Function EstUnMov(nUnMov)
	local lValidFil 	:= GetNewPar( 'ZZ_VLDUTRF', .T.)
	Private oApp_Ori
	Private nHndErp 	:= AdvConnection()
	Private cDB_PPI 	:= GetMV("ZZ_HNDPCF")//"MSSQL/PCFactory"	//Tipo e nome do banco de integração (PC-Factory) (OFICIAL)
	Private cSrvPPI 	:= GetMV("ZZ_SRVPPI")//"192.168.3.2"		//Servidor onde está o banco de integração (OFICIAL)
	Private nPrtPPI 	:= GetNewPar("ZZ_PORTADB", "7890")		// Porta
	Private nHndPPI		//Handler do banco de dados de integração
	Private _FilPPI		:= cFilAnt

	//Armazena a conexão de Origem
	oApp_Ori 	:= oApp
	// Cria uma conexão com um outro banco, outro DBAcces
	nHndPPI 	:= TcLink(cDb_PPI,cSrvPPI,nPrtPPI)

	//Conecta com PPI
	TcSetConn(nHndPPI)

	//Caso a conexão não seja realizada
	If nHndPPI < 0
		Alert("Falha ao conectar com " + cDB_PPI + " em " + cSrvPPI + ":" + Str(nPrtPPI,4))
		Return(.F.)
	Endif

	//Coloca os Registros de Integração em Processo
	_cQuery := " update TBLMovUn set  "
	_cQuery += " AuxField3 = '', "
	_cQuery += " IDAddress = " + IIf(_FilPPI = "01", "4","6")+ " " //6 Tres Lagoas -- 4 Itu
	_cQuery += " FROM TBLMovUn M
	_cQuery += " where M.IdMovUn = " + Alltrim(Str(nUnMov))
	if lValidFil
		_cQuery += " and M.IDResource = (                                                         "
		_cQuery += " 			select R.IDResource                                               "
		_cQuery += " 					from TBLResource R                                        "
		_cQuery += " 					inner join TBLCostCenter C                                "
		_cQuery += " 								ON R.IDCostCenter = C.IDCostCenter            "
		_cQuery += " 					where R.IDResource = M.IDResource                         "
		_cQuery += " 					and C.IDCostCenter = " +  IIf(_FilPPI = "01", "1","2")
		_cQuery += " )                                                                            "
	endif

	//Conecta com PPI
	TcSetConn(nHndPPI)
	//Executa Query
	TCSqlExec(_cQuery)
	//Verifica se a Query foi executada
	If (TCSqlExec(_cQuery) < 0) // Deu Erro
		//_lVolta := .T. // Significa que deu erro na função
		cMsg := TCSQLError() //+ linha
		MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
		Return(.F.)
	EndIf

	//Encerra conexão PPI
	TcUnLink(nHndPPI)
	//Conecta ERP
	TcSetConn(nHndERP)
	oApp 	:= oApp_Ori
Return(.T.)

/*/{Protheus.doc} CDTrfUM
//TODO Transfere Unmovs que foram realizadas entradas em Tres Lagoas.
@author juliana.leme
@since 27/09/2016
@version undefined

@type function
/*/
User Function CDTrfUM(cAuth)
	Local aAuth 		:= {}
	Private oApp_Ori
	Private nHndErp 	:= AdvConnection()
	Private cDB_PPI 	:= GetMV("ZZ_HNDPCF")//"MSSQL/PCFactory"	//Tipo e nome do banco de integração (PC-Factory) (OFICIAL)
	Private cSrvPPI 	:= GetMV("ZZ_SRVPPI")//"192.168.3.2"		//Servidor onde está o banco de integração (OFICIAL)
	Private nPrtPPI 	:= GetNewPar("ZZ_PORTADB", "7890")		// Porta
	Private nHndPPI		//Handler do banco de dados de integração
	Private _FilPPI		:= '02'

	If !Empty(cAuth)
		aAuth 	:= StrTokArr(cAuth, ',')
		PREPARE ENVIRONMENT EMPRESA '01' FILIAL '02' USER aAuth[1] PASSWORD aAuth[2]  MODULO 'EST'
	EndIf

	If _FilPPI = "02"
		//Armazena a conexão de Origem
		oApp_Ori 	:= oApp
		// Cria uma conexão com um outro banco, outro DBAcces
		nHndPPI 	:= TcLink(cDb_PPI,cSrvPPI,nPrtPPI)

		//Conecta com PPI
		TcSetConn(nHndPPI)

		//Caso a conexão não seja realizada
		If nHndPPI < 0
			Alert("Falha ao conectar com " + cDB_PPI + " em " + cSrvPPI + ":" + Str(nPrtPPI,4))
			Return(.F.)
		Endif

		//Coloca os Registros de Integração em Processo
		_cQuery := " update TBLMovUn set  "
		_cQuery += " IDAddress = (Case b.IDAddress when 1 then 5 else 6 end ) "
		_cQuery += " from TBLMovUn a  "
		_cQuery += "  inner join TBLAddress b on a.IDAddress = b.IDAddress  "
		_cQuery += "  inner join TBLUser c on c.IDUser = a.IssueIDuser  "
		_cQuery += "  inner join tblproduct d on a.idproduct = d.idproduct  "
		_cQuery += " where a.MovUnQty > 0 "
		_cQuery += "  and b.Code like '01%' "
		_cQuery += "  and c.Code like '02%' "

		//Conecta com PPI
		TcSetConn(nHndPPI)
		//Executa Query
		TCSqlExec(_cQuery)
		//Verifica se a Query foi executada
		If (TCSqlExec(_cQuery) < 0) // Deu Erro
			//_lVolta := .T. // Significa que deu erro na função
			cMsg := TCSQLError() //+ linha
			MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
			Return(.F.)
		Else
			Alert("Transferencia Concluida!")
		EndIf

		//Encerra conexão PPI
		TcUnLink(nHndPPI)
		//Conecta ERP
		TcSetConn(nHndERP)
		oApp 	:= oApp_Ori
	Else
		Alert("Apenas Filial Tres Lagoas. Processo Cancelado!")
	EndIf

	If !Empty(cAuth)
		RESET ENVIRONMENT
	EndIf
Return

