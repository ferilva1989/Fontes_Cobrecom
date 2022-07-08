#include 'protheus.ch'
#include 'rwmake.ch'
#include 'topconn.ch'

/*/{Protheus.doc} JanUnMov
//TODO Função cria a janela com as informações e opções do Inventario.
@author juliana.leme
@since 29/07/2015
@version 1.0

@type function
/*/
User Function JanUnMov()

	#IFNDEF WINDOWS
	ScreenDraw("SMT050", 3, 0, 0, 0)
	#ENDIF

	Local cCadastro := "Regras Inventario"
	Local aCampBrow:= {}
	Local aCores   := {}

	aRotina := {{ "Pesquisar"				,"AxPesqui" 			, 0, 1},;
	{ "Plan.PCF(P1)"			,'U_ProcMsg(2)' 		, 0, 2},;
	{ "Col.TXT(P2)"				,'U_ProcMsg(3)' 		, 0, 3},;
	{ "Exp.Dados PCF(P3)"		,'U_ProcMsg(4)' 		, 0, 4},;
	{ "Final.Contag(P4)"		,'U_ProcMsg(5)' 		, 0, 5},;
	{ "Tela XLS"				,'U_ProcMsg(6)'			, 0, 6},;
	{ "Atual.Cont(P5)"			,'U_ProcMsg(7)'			, 0, 7},;
	{ "Grv.Inv.ZL(P6)"			,'U_ProcMsg(8)'			, 0, 8},;
	{ "Alterar"					,'ExecBlock("CDAltera",.F.,.F.)', 0, 9},;
	{ "Incluir"					,'ExecBlock("CDInclui",.F.,.F.)', 0, 10},;
	{ "Inv.Retrabal."			,'U_ProcMsg(9)'			, 0, 11}}

	AADD(aCores,{"ZAH_DATA = dDataBase "								,"BR_VERDE" })
	AADD(aCores,{"ZAH_DATA < dDataBase .OR. ZAH_DATA > dDataBase"	,"BR_VERMELHO" })

	dbSelectArea("ZAH")
	dbSetOrder(1)

	AADD(aCampBrow,{'Filial'   		,'ZAH_FILIAL'	,'C', 5,0,"@!"						})
	AADD(aCampBrow,{'Dt Invent'		,'ZAH_DATA'		,'D', 8,0,x3Picture("ZAH_DATA"		)})
	AADD(aCampBrow,{'UnMov' 		,'ZAH_MOVUN'	,'N',10,0,x3Picture("ZAH_MOVUN"		)})
	AADD(aCampBrow,{'Produto' 		,'ZAH_PRODUT' 	,'C',20,0,x3Picture("ZAH_PRODUT"	)})
	AADD(aCampBrow,{'Endereço'		,'ZAH_ADDRES'	,'C',15,0,x3Picture("ZAH_ADDRES"	)})
	AADD(aCampBrow,{'Qtde'   	  	,'ZAH_QTDE'		,'N',15,5,x3Picture("ZAH_QTDE"		)})
	AADD(aCampBrow,{'UM'			,'ZAH_UM'		,'N',15,5,x3Picture("ZAH_UM"		)})
	AADD(aCampBrow,{'Local'		 	,'ZAH_LOCAL'	,'N',15,5,x3Picture("ZAH_LOCAL"		)})
	AADD(aCampBrow,{'End.Inv.C1'	,'ZAH_ADDR1'	,'C',15,0,x3Picture("ZAH_ADDRES"	)})
	AADD(aCampBrow,{'Qtde Inv.C1' 	,'ZAH_QTDE1'	,'N',15,5,x3Picture("ZAH_QTDE1"		)})
	AADD(aCampBrow,{'End.Inv.C2'	,'ZAH_ADDR2'	,'C',15,0,x3Picture("ZAH_ADDRES"	)})
	AADD(aCampBrow,{'Qtde Inv.C2' 	,'ZAH_QTDE2'	,'N',15,5,x3Picture("ZAH_QTDE2"		)})
	AADD(aCampBrow,{'End.Inv.C3'	,'ZAH_ADDR3'	,'C',15,0,x3Picture("ZAH_ADDRES"	)})
	AADD(aCampBrow,{'Qtde Inv.C3' 	,'ZAH_QTDE3'	,'N',15,5,x3Picture("ZAH_QTDE3"		)})

	If !(MsgBox("Confirma a DATABASE do processamento: "+DtoC(dDataBase)+"  ?","Confirma","YesNo"))
		Return
	EndIf
	mBrowse(6,1,22,75,"ZAH",aCampBrow,,,,,aCores)
Return


/*/{Protheus.doc} ProcMsg
//TODO Carrega "Processa" das funções.
@author juliana.leme
@since 26/04/2016
@version 1.0
@param nOpc, Numerico, opcao a ser considerada nas condições
@type function
/*/
User Function ProcMsg(nOpc)
	Do Case
		Case nOpc == 2
			Processa( {|| U_CarregXLS()}, "Carregando Planilha XLS", "Aguarde...", .F.)
		Case nOpc == 3
			Processa( {|| U_InvUnMov()}, "Importando Coleta", "Aguarde...", .F.)
		Case nOpc == 4
			Processa( {|| U_GravInvPPI()}, "Gravando Contagens no PCF ...", "Aguarde...", .F.)
		Case nOpc == 5
			Processa( {|| U_UpdFinPPI()}, "Finalizando Contagem no PCF ... ", "Aguarde...", .F.)
		Case nOpc == 6
			Processa( {|| U_ExpToExc()}, "Exportando Relatório em Excel", "Aguarde...", .F.)
		Case nOpc == 7
			Processa( {|| U_UpdBestCont()}, "Atualiza Melhor Contagem", "Aguarde...", .F.)
		Case nOpc == 8
			Processa( {|| U_SldPCF()}, "Carga SZG Inventario X Protheus", "Aguarde...", .F.)
		Case nOpc == 9
			Processa( {|| U_CBCInvRetr()}, "Gerando Inventario de Retrabalhos", "Aguarde...", .F.)
	EndCase
Return()


/*/{Protheus.doc} CDAltera
//TODO Função para alterar o registro posicionado CDALTERA.
@author juliana.leme
@since 29/07/2015
@version 1.0

@type function
/*/
User Function CDAltera()
	Local 	nOpca 			:= 0
	Private cCadastro 	:= "Cadastro dados Inventario" // título da tela

	If ! AllTrim(cUserName)+"|" $ GetMV("MV_INVPPI")
		Alert("Sem permissão para alterar")
		Return(.T.)
	EndIf

	dbSelectArea("ZAH")
	DBSetOrder(1)
	ZAH->(Recno())
	ZAH->ZAH_ADDR1		:= ZAH->ZAH_ADDRES
	ZAH->ZAH_LOT1		:= ZAH->ZAH_LOTE
	ZAH->ZAH_CLAS1		:= ZAH->ZAH_CLASSI
	ZAH->ZAH_ORIG1		:= ZAH->ZAH_ORIGIN
	ZAH->ZAH_OP1		:= ""
	ZAH->ZAH_OPER1		:= "10"
	ZAH->ZAH_QTDE1		:= ZAH->ZAH_QTDE

	ZAH->ZAH_ADDR2		:= ZAH->ZAH_ADDRES
	ZAH->ZAH_LOT2		:= ZAH->ZAH_LOTE
	ZAH->ZAH_CLAS2		:= ZAH->ZAH_CLASSI
	ZAH->ZAH_ORIG2		:= ZAH->ZAH_ORIGIN
	ZAH->ZAH_OP2		:= ""
	ZAH->ZAH_OPER2		:= "10"
	ZAH->ZAH_QTDE2		:= ZAH->ZAH_QTDE

	ZAH->ZAH_ADDR3		:= ZAH->ZAH_ADDRES
	ZAH->ZAH_LOT3			:= ZAH->ZAH_LOTE
	ZAH->ZAH_CLAS3		:= ZAH->ZAH_CLASSI
	ZAH->ZAH_ORIG3		:= ZAH->ZAH_ORIGIN
	ZAH->ZAH_OP3		:= ""
	ZAH->ZAH_OPER3		:= "10"
	ZAH->ZAH_QTDE3		:= ZAH->ZAH_QTDE

	nOpca := AxAltera("ZAH" ,ZAH->(Recno()),3 , , , , , , , , , , , ,.T. , , , , , )
Return


/*/{Protheus.doc} CDInclui
//TODO Função para incluir o registro.
@author juliana.leme
@since 29/07/2015
@version 1.0

@type function
/*/
User Function CDInclui()
	Private cCadastro 	:= "Cadastro dados Inventario" // título da tela

	If !AllTrim(cUserName)+"|" $ GetMV("MV_INVPPI")
		Alert("Sem permissão para alterar")
		Return(.T.)
	EndIf
	AxInclui("ZAH",ZAH->(Recno()),3,,,,,.T.,,,,,.T.,.T.,,,,,)
Return


/*/{Protheus.doc} ExpToExc
//TODO Função que exporta tela MBrowse para Excel.
@author juliana.leme
@since 30/07/2015
@version 1.0

@type function
/*/
User Function ExpToExc()
	Local oExcel1		:= FWMSEXCEL():New()
	Local aDados		:= {}
	Local dDataInv 		:= dDataBase
	Local aParamBox 	:= {}
	Local aRet 			:= ""
	Local cDir			:= ""
	Local nSaldProt		:= 0

	aAdd(aParamBox,{6,"Pasta de Saída:","C:\Inventario\","","","" ,70,.T.,"Arquivo .XLS |*.XLS"})

	If !ParamBox(aParamBox, "Parametros", @aRet)
		Return(.F.)
	EndIf

	cDir		:= Alltrim(Substr(aRet[1],1,rat("\",aRet[1])))
	ProcRegua(0)

	oExcel1:AddworkSheet("Comp_Invent")
	oExcel1:AddTable("Comp_Invent","PCF X Protheus")

	oExcel1:AddColumn("Comp_Invent","PCF X Protheus","UnMov",1,1)//1
	oExcel1:AddColumn("Comp_Invent","PCF X Protheus","Ender.Orig.",1,1)//2
	oExcel1:AddColumn("Comp_Invent","PCF X Protheus","Produto",1,1)//3
	oExcel1:AddColumn("Comp_Invent","PCF X Protheus","Descrição.",1,1)//4
	oExcel1:AddColumn("Comp_Invent","PCF X Protheus","Qtde Orig.",1,1)//5
	oExcel1:AddColumn("Comp_Invent","PCF X Protheus","UM",1,1)//6
	oExcel1:AddColumn("Comp_Invent","PCF X Protheus","Qtde KG/Cobre",1,1)//7
	oExcel1:AddColumn("Comp_Invent","PCF X Protheus","Qtde KG/PVC",1,1)//8
	oExcel1:AddColumn("Comp_Invent","PCF X Protheus","Local Cont",1,1)//9
	//Contagem 1
	oExcel1:AddColumn("Comp_Invent","PCF X Protheus","Qtde Inv.(Cont1)",1,1)//10
	//Contagem 2
	oExcel1:AddColumn("Comp_Invent","PCF X Protheus","Qtde Inv.(Cont2)",1,1)//11
	oExcel1:AddColumn("Comp_Invent","PCF X Protheus","Dif Cont1 X Cont2",1,1)//12
	//Contagem 3
	oExcel1:AddColumn("Comp_Invent","PCF X Protheus","Qtde Inv.(Cont3)",1,1)//13
	//Contagem 3 em Kilo Cobre
	oExcel1:AddColumn("Comp_Invent","PCF X Protheus","Qtde Inv.KG/Cobre",1,1)//14
	oExcel1:AddColumn("Comp_Invent","PCF X Protheus","Qtde Inv.KG/PVC",1,1)//15

	//Carrega dados da tabela ZAH
	DbSelectArea("ZAH")
	DbGotop()
	DbSetFilter({ || ZAH->ZAH_DATA == dDataBase},"")
	DbSeek(xFilial("ZAH")+DtoS(dDataBase),.F.)
	ProcRegua(RecCount())
	Do While ZAH->(!Eof())
		aAdd(aDados,{ZAH->ZAH_MOVUN,;//1
		ZAH->ZAH_ADDRES,;//2
		ZAH->ZAH_PRODUT,;//3
		Posicione("SB1",1,xFilial("SB1")+Padr(ZAH->ZAH_PRODUT,TamSX3("B1_COD")[1]),"B1_DESC"),;//4
		ZAH->ZAH_QTDE,;//5
		ZAH->ZAH_UM,;//6
		Posicione("SB1",1,xFilial("SB1")+Padr(ZAH->ZAH_PRODUT,TamSX3("B1_COD")[1]),"B1_PESCOB") * ZAH->ZAH_QTDE ,;//7
		Posicione("SB1",1,xFilial("SB1")+Padr(ZAH->ZAH_PRODUT,TamSX3("B1_COD")[1]),"B1_PESPVC") * ZAH->ZAH_QTDE ,;//8
		ZAH->ZAH_LOCAL,;//9
		ZAH->ZAH_QTDE1,;//10
		ZAH->ZAH_QTDE2,;//11
		ZAH->ZAH_QTDE1 - ZAH->ZAH_QTDE2,;//12
		ZAH->ZAH_QTDE3,;//13
		Posicione("SB1",1,xFilial("SB1")+Padr(ZAH->ZAH_PRODUT,TamSX3("B1_COD")[1]),"B1_PESCOB") * ZAH_QTDE3,; //14
		Posicione("SB1",1,xFilial("SB1")+Padr(ZAH->ZAH_PRODUT,TamSX3("B1_COD")[1]),"B1_PESPVC") * ZAH_QTDE3 })//15
		ZAH->(DbSkip())
		IncProc()
	Enddo

	ProcRegua(len(aDados))
	For n1:=1 to len (aDados)
		oExcel1:AddRow("Comp_Invent","PCF X Protheus",aDados[n1])
		IncProc()
	Next

	oExcel1:Activate()
	oExcel1:GetXMLFile(cDir+"\AnalisInvent.xml")
	Alert("A planilha foi exportada com sucesso em "+cDir+"AnalisInvent.xls")
	DbCloseArea("ZAH")
Return

/*/{Protheus.doc} UpdFinPPI
//TODO Grava inventario na base de dados da PPI.
@author juliana.leme
@since 13/08/2015
@version 1.0

@type function
/*/
User function UpdFinPPI()
	Local cQuery		:= ""
	Local nCount		:= 1
	Local aParamBox	:= {}
	Local cContag 	:= 1
	Private oApp_Ori
	Private nHndErp 	:= AdvConnection()
	Private cDB_PPI 	:= GetMV("ZZ_HNDPCF")//"MSSQL/PCFactory"	//Tipo e nome do banco de integração (PC-Factory) (OFICIAL)
	Private cSrvPPI 	:= GetMV("ZZ_SRVPPI")//"192.168.3.2"		//Servidor onde está o banco de integração (OFICIAL)
	Private nPrtPPI 	:= 7890	// Porta
	Private nHndPPI	//Handler do banco de dados de integração

	aParamBox := {}
	aRet 		:= ""
	aAdd(aParamBox,{3,"Melhor Contagem",1,{"Contagem 1","Contagem 2","Contagem 3"},50,"",.F.})
	If !ParamBox(aParamBox, "Parametros", @aRet)
		Return(.F.)
	EndIf

	cContag	:= aRet[1]

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

	//Conecta com PPI
	TcSetConn(nHndPPI)
	//Coloca os Registros de Integração em Processo
	_cQuery := " Update TBLInvCountMovUn Set  "
	_cQuery += " BESTCOUNT = " + Str(cContag) +", "
	_cQuery += " DTBESTCOUNT = GETDATE(), "
	_cQuery += " IDUSERBESTCOUNT =  1 "

	//Conecta com PPI
	TcSetConn(nHndPPI)
	//Executa Query
	TCSqlExec(_cQuery)
	//Verifica se a Query foi executada
	If (TCSqlExec(_cQuery) < 0) // Deu Erro
		//_lVolta := .T. // Significa que deu erro na função
		cMsg := TCSQLError() //+ linha
		MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
	EndIf

	//Encerra conexão PPI
	TcUnLink(nHndPPI)
	//Conecta ERP
	TcSetConn(nHndERP)
	oApp 	:= oApp_Ori
	MsgInfo("Contagem Final atualizada com sucesso!","Info")
Return()


/*/{Protheus.doc} UpdBestCont
//TODO Atualiza a Terceira contagem.
@author juliana.leme
@since 13/08/2015
@version 1.0
@type function
/*/
User Function UpdBestCont()
	Local cQuery		:= ""
	Local nCount		:= 1
	Local aParamBox	:= {}
	Local cContag 	:= 1

	aParamBox := {}
	aRet 		:= ""

	aAdd(aParamBox,{3,"Melhor Contagem",1,{"Contagem 1","Contagem 2"},50,"",.F.})

	If !ParamBox(aParamBox, "Parametros", @aRet)
		Return(.F.)
	EndIf

	cContag	:= aRet[1]

	For n1:= 1 to len (_aDados)
		DbGotop()
		If DbSeek(xFilial("ZAH")+DtoS(dDataInv)+Alltrim(Str(Val(_aDados[n1][2]))))
			If ZAH->ZAH_QTDE3 = 0
				RecLock("ZAH",.F.)
				ZAH->ZAH_LOCAL			:= Substr(Alltrim(_aDados[n1][1]),7,Len(Alltrim(_aDados[n1][1])))
				If nContag == 1
					ZAH->ZAH_ADDR3		:= ZAH->ZAH_ADDR1
					ZAH->ZAH_LOT3		:= ZAH->ZAH_LOT1
					ZAH->ZAH_CLAS3		:= ZAH->ZAH_CLAS1
					ZAH->ZAH_ORIG3		:= ZAH->ZAH_ORIG1
					ZAH->ZAH_OP3		:= ""
					ZAH->ZAH_OPER3		:= "10"
					ZAH->ZAH_QTDE3		:= ZAH->ZAH_QTDE1
				ElseIf nContag == 2
					ZAH->ZAH_ADDR3		:= ZAH->ZAH_ADDR2
					ZAH->ZAH_LOT3		:= ZAH->ZAH_LOT2
					ZAH->ZAH_CLAS3		:= ZAH->ZAH_CLAS2
					ZAH->ZAH_ORIG3		:= ZAH->ZAH_ORIG2
					ZAH->ZAH_OP3		:= ""
					ZAH->ZAH_OPER3		:= "10"
					ZAH->ZAH_QTDE3		:= ZAH->ZAH_QTDE2
				EndIf
				MsUnlock()
				DbCommit()
			EndIf
		Else
			cMsg	+=  "CONTAGEM "+ Str(nContag)+ " Deposito: "+_aDados[n1][1]+" UnMov: "+_aDados[n1][2]+" Qtde: "+StrTran(_aDados[n1][3],",",".")+CRLF
		EndIf
	Next
	//Envia Email
	If cMsg <> ""
		U_ConsoleLog("INTEGRACAO N REALIZADA - UNMOV NAO ENCONTRADA ",cMsg,cArqErr) //cTipo = (ERRO,CONCLUIDO,EXCESSAO) cMsg = (Mensagem destinada a informação)
		Processa({|| U_ArqPorEmail(cArqErr,"juliana.leme@cobrecom.com.br","[ERROS]Inventario Protheus X PCF")},"Enviando Email Erros...")
	EndIf
	Aviso("Atenção","Importação com exito!",{"Ok"},1)
Return

/*

Juliana Leme  -
*/
/*/{Protheus.doc} InvUnMov
//TODO Função que Captura Array do coletor com os dados da coleta para gravação do inventario.
@author juliana.leme
@since 28/07/2015
@version
@param aColeta, Array, Array Multidimensional com informações das Unmovs coletadas
@type function
/*/
User Function InvUnMov(aColeta)
	Local aParamBox	:= {}
	Local aRet 		:= ""
	Local lOk  		:= .T.
	Local cArqErr 	:= "InvErr.txt"
	Local cMsg 		:= ""
	Local dDataInv	:= dDataBase
	Local _aDados 	:= {}
	Local nContag 	:= 1
	Private nCont 	:= 1

	While lOk
		aParamBox := {}
		aRet 		:= ""

		aAdd(aParamBox,{6,"Qual Arquivo","\SERVIDOR\Coletores\UNIMOV\","","","" ,70,.T.,"Arquivo .TXT|*.TXT"})
		//aAdd(aParamBox,{3,"Contagem:",1,{"Contagem 1","Contagem 2","Contagem 3"},50,"",.F.})

		If !ParamBox(aParamBox, "Parametros", @aRet)
			Return(.F.)
		EndIf

		cOrigem	:= aRet[1]
		//nContag	:= aRet[2]
		Processa( {|| _aDados:= ImpVarios(cOrigem,,.F.)},"Aguarde, carregando Coleta ... Pode demorar ...")

		If len(_aDados) > 0
			DBSelectArea("ZAH")
			//DbGotop()
			ProcRegua(len(_aDados))
			For n1:= 1 to len (_aDados)
				DbGotop()
				If DbSeek(xFilial("ZAH")+DtoS(dDataInv)+Alltrim(Str(Val(_aDados[n1][3]))))
					RecLock("ZAH",.F.)
					ZAH->ZAH_LOCAL			:= Substr(Alltrim(_aDados[n1][2]),7,Len(Alltrim(_aDados[n1][2])))
					If Alltrim(_aDados[n1][1]) == "1"
						If ZAH->ZAH_QTDE1 == 0
							ZAH->ZAH_ADDR1		:= Substr(Alltrim(_aDados[n1][2]),1,5)
							ZAH->ZAH_LOT1		:= ZAH->ZAH_LOTE
							ZAH->ZAH_CLAS1		:= ZAH->ZAH_CLASSI
							ZAH->ZAH_ORIG1		:= ZAH->ZAH_ORIGIN
							ZAH->ZAH_OP1		:= ""
							ZAH->ZAH_OPER1		:= "10"
							ZAH->ZAH_QTDE1		:= IIF(Val(StrTran(_aDados[n1][4],",","."))=0,ZAH->ZAH_QTDE,Val(StrTran(_aDados[n1][4],",",".")))
						Else
							aProd_	:= U_RetProdUnMov(Alltrim(Str(Val(_aDados[n1][3]))))
							cProd	:= aProd_[1][1]
							cDesc	:= aProd_[1][2]
							cMsg	:= "DUPLICADA;"+ Alltrim(_aDados[n1][1])+";"+_aDados[n1][2]+";"+_aDados[n1][3]+";"+cProd+";"+cDesc+";"+StrTran(_aDados[n1][4],",",".")+CRLF
							U_cArqTxt(cMsg,cArqErr)
						EndIf
					ElseIf Alltrim(_aDados[n1][1]) == "2"
						If ZAH->ZAH_QTDE2 == 0
							ZAH->ZAH_ADDR2		:= Substr(Alltrim(_aDados[n1][2]),1,5)
							ZAH->ZAH_LOT2		:= ZAH->ZAH_LOTE
							ZAH->ZAH_CLAS2		:= ZAH->ZAH_CLASSI
							ZAH->ZAH_ORIG2		:= ZAH->ZAH_ORIGIN
							ZAH->ZAH_OP2		:= ""
							ZAH->ZAH_OPER2		:= "10"
							ZAH->ZAH_QTDE2		:= IIF(Val(StrTran(_aDados[n1][4],",","."))=0,ZAH->ZAH_QTDE,Val(StrTran(_aDados[n1][4],",",".")))
						Else
							aProd_	:= U_RetProdUnMov(Alltrim(Str(Val(_aDados[n1][3]))))
							cProd	:= aProd_[1][1]
							cDesc	:= aProd_[1][2]
							cMsg	:=  "DUPLICADA;"+ Alltrim(_aDados[n1][1])+";"+_aDados[n1][2]+";"+_aDados[n1][3]+";"+cProd+";"+cDesc+";"+StrTran(_aDados[n1][4],",",".")+CRLF
							U_cArqTxt(cMsg,cArqErr)
						EndIf
					ElseIf Alltrim(_aDados[n1][1]) == "3"
						If ZAH->ZAH_QTDE3 == 0
							ZAH->ZAH_ADDR3		:= Substr(Alltrim(_aDados[n1][2]),1,5)
							ZAH->ZAH_LOT3		:= ZAH->ZAH_LOTE
							ZAH->ZAH_CLAS3		:= ZAH->ZAH_CLASSI
							ZAH->ZAH_ORIG3		:= ZAH->ZAH_ORIGIN
							ZAH->ZAH_OP3		:= ""
							ZAH->ZAH_OPER3		:= "10"
							ZAH->ZAH_QTDE3		:= IIF(Val(StrTran(_aDados[n1][4],",","."))=0,ZAH->ZAH_QTDE,Val(StrTran(_aDados[n1][4],",",".")))
						Else
							aProd_	:= U_RetProdUnMov(Alltrim(Str(Val(_aDados[n1][3]))))
							cProd	:= aProd_[1][1]
							cDesc	:= aProd_[1][2]
							cMsg	:=  "DUPLICADA;"+ Alltrim(_aDados[n1][1])+";"+_aDados[n1][2]+";"+_aDados[n1][3]+";"+cProd+";"+cDesc+";"+StrTran(_aDados[n1][4],",",".")+CRLF
							//1				//2				//3					//4				  //5		//6			//7
							U_cArqTxt(cMsg,cArqErr)
						EndIf
					Endif
					MsUnlock()
					DbCommit()
				Else
					aProd_	:= U_RetProdUnMov(Alltrim(Str(Val(_aDados[n1][3]))))
					cProd	:= aProd_[1][1]
					cDesc	:= aProd_[1][2]
					cMsg	:=  "NÃO ENCONTRADA;"+ Alltrim(_aDados[n1][1])+";"+_aDados[n1][2]+";"+_aDados[n1][3]+";"+cProd+";"+cDesc+";"+StrTran(_aDados[n1][4],",",".")+CRLF
					//1				//2				//3					//4					//5		//6			//7
					U_cArqTxt(cMsg,cArqErr)
				EndIf
				nCont	:= nCont +1
				IncProc('Importando Registros ' + Alltrim(_aDados[n1][1]))
			Next
		Else
			Aviso("Atenção","Arquivo Vazio",{"Ok"},1)
		EndIf
		//Consulta caso tenha mais arquivos a importar
		lOk := MsgBox("Deseja Importar outro arquivo ?","Confirma","YesNo")
	EndDo
	If cMsg <> ""
		_aResult := Importar("\cProva\"+cArqErr,,.F.)
		U_TExcelArr(_aResult)
	EndIf
	Aviso("Atenção","Importação com exito!",{"Ok"},1)
Return (aColeta)


/*/{Protheus.doc} RetProdUnMov
//TODO Retorna Produto da UnMov.
@author juliana.leme
@since 26/07/2015
@version 1.0
@param cUnMov, Caracter, UnMov a ser consultada
@type function
/*/
User Function RetProdUnMov(cUnMov)
	Local aParamBox 	:= {}
	Local aColPPI		:= {}
	Local cQuery		:= ""
	Local nCount		:= 1
	Local aProd			:= {}
	Private oApp_Ori
	Private nHndErp 	:= AdvConnection()
	Private cDB_PPI 	:= GetMV("ZZ_HNDPCF")//"MSSQL/PCFactory"	//Tipo e nome do banco de integração (PC-Factory) (OFICIAL)
	Private cSrvPPI 	:= GetMV("ZZ_SRVPPI")//"192.168.3.2"		//Servidor onde está o banco de integração (OFICIAL)
	Private nPrtPPI 	:= 7890	// Porta
	Private nHndPPI	//Handler do banco de dados de integração
	Private _aArea := GetArea()

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
	//Coloca os Registros de Integração em Processo
	_cQuery := " SELECT  	B.CODE Produto, "
	_cQuery += " 			B.NAME Descric "
	_cQuery += " FROM TBLMovUn A "
	_cQuery += "   Inner Join TBLProduct B ON A.IDProduct = B.IDProduct "
	_cQuery += " WHERE A.IdMovun = " + cUnMov

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
		aAdd(aProd,{TRB1->Produto, TRB1->Descric})
	Else
		aAdd(aProd,{"NÃO ENCONTRADO", "NÃO ENCONTRADO"})
	EndIf

	//Encerra conexão PPI
	TcUnLink(nHndPPI)
	oApp 	:= oApp_Ori
	RestArea(_aArea)
Return(aProd)


/*/{Protheus.doc} cArqTxt
//TODO Grava em Arquivo Txt informações.
@author juliana.leme
@since 26/04/2016
@version
@param cMsg, Caracter, Mensagem a ser gravada em arquivo
@param cNomArq, Caracter, Nome do Arquivo a ser gravado
@type function
/*/
User Function cArqTxt(cMsg,cNomArq)
	Public _cArqTxt 	:= "\cProva\"+cNomArq //Log.TXT
	Public _nHdl 		:= 0

	If  ! File(_cArqTxt)
		_nHdl := fCreate(_cArqTxt)
		if _nHdl == -1
			MsgAlert("O arquivo de nome "+_cArqTxt+" nao pode ser executado ! Verifique os parametros.","Atenção !")
			Return
		Else
			cLin := cMsg
			//Grava no arquivo texto
			if fWrite(_nHdl,cLin,Len(cLin)) != Len(cLin)
				if !MsgAlert("Ocorreu um erro na gravacao do arquivo." + "Continua !","Atencao !")
					Return(.F.)
				endif
			endif
		endif
	Else
		// Abre o arquivo de Origem
		_nHdl := fOpen(_cArqTxt,1)
		// Testa a abertura do Arquivo
		If _nHdl == -1
			MsgStop('Erro ao abrir origem. Ferror = '+str(ferror(),4),'Erro')
			Return .F.
		Else
			fSeek(_nHdl,0,2)
			cLin := cMsg
			//Grava no arquivo texto
			if fWrite(_nHdl,cLin,Len(cLin)) != Len(cLin)
				if !MsgAlert("Ocorreu um erro na gravacao do arquivo." + "Continua !","Atencao !")
					Return(.F.)
				endif
			endif
		endif
	EndIf
	/*else
		// Abre o arquivo de Origem
		_nHdl := fOpen(_cArqTxt,1)
		// Testa a abertura do Arquivo
		If _nHdl == -1
			MsgStop('Erro ao abrir origem. Ferror = '+str(ferror(),4),'Erro')
			Return .F.
		Endif
		fSeek(_nHdl,0,2)
		cLin := cMsg
		//Grava no arquivo texto
		if fWrite(_nHdl,cLin,Len(cLin)) != Len(cLin)
			if !MsgAlert("Ocorreu um erro na gravacao do arquivo." + "Continua !","Atencao !")
				Return(.F.)
			endif
		endif
	EndIf*/
	//Fecha o arquivo texto
	If !fClose(_nHdl)
		Conout( "Erro ao fechar arquivo, erro numero: ", FERROR() )
	EndIf
Return(.T.)

/*/{Protheus.doc} TExcelArr
//TODO Transforma Array em planilha de Excel.
@author juliana.leme
@since 26/04/2016
@version
@param _aDados, Array, Dados para ser transformados em XLS
@type function
/*/
User Function TExcelArr(_aDados)
	Local _oExcel1		:= FWMSEXCEL():New()
	Local dDataInv 		:= dDataBase
	Local aParamBox 	:= {}
	Local aRet 			:= ""
	Local cDir			:= ""
	Local nSaldProt		:= 0

	aAdd(aParamBox,{6,"Pasta de Saída:","C:\Inventario\","","","" ,70,.T.,"Arquivo .XLS |*.XLS"})

	If !ParamBox(aParamBox, "Parametros", @aRet)
		Return(.F.)
	EndIf

	cDir		:= Alltrim(Substr(aRet[1],1,rat("\",aRet[1])))
	ProcRegua(0)

	_oExcel1:AddworkSheet("Err_Invent")
	_oExcel1:AddTable("Err_Invent","PCF X Protheus")

	_oExcel1:AddColumn("Err_Invent","PCF X Protheus","Ocorrencia",1,1)//1
	_oExcel1:AddColumn("Err_Invent","PCF X Protheus","Contagem",1,1)//2
	_oExcel1:AddColumn("Err_Invent","PCF X Protheus","Endereço",1,1)//3
	_oExcel1:AddColumn("Err_Invent","PCF X Protheus","UnMov",1,1)//4
	_oExcel1:AddColumn("Err_Invent","PCF X Protheus","Produto",1,1)//5
	_oExcel1:AddColumn("Err_Invent","PCF X Protheus","Descrição",1,1)//6
	_oExcel1:AddColumn("Err_Invent","PCF X Protheus","Qtde Invent",1,1)//7

	For n1:=1 to len (_aDados)
		_oExcel1:AddRow("Err_Invent","PCF X Protheus",_aDados[n1])
	Next

	_oExcel1:Activate()
	_oExcel1:GetXMLFile(cDir+"\DivergInvent.xml")

	fClose(_nHdl)
	fErase(_cArqTxt)

	Alert("A planilha foi exportada com sucesso em "+cDir+"DivergInvent.xls")
Return


/*/{Protheus.doc} Importar
//TODO Função que captura arquivo texto e exporta array.
@author juliana.leme
@since 26/04/2016
@version 1.0
@param cArqImpor, Caracter, Arquivo a ser importado
@type function
/*/
Static Function Importar(cArqImpor)
	Local cLinha 	:= ""
	Local nLinha 	:= 0
	Local aDados 	:= {}
	Local nTamLinha := 0
	Local nTamArq	:= 0
	Local nCont  	:= 1

	//Valida arquivo
	If !file(cArqImpor)
		Aviso("Arquivo","Arquivo não selecionado ou invalido.",{"Sair"},1)
		Return (.F.)
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

	/*For i := 1 to len(aDados)
	//Considerando que no arquivo txt contenha 2 colunas, mostre na tela linha a linha
	Alert(aDados[i,1] + " " + aDados[i,2])
	Next */

	Aviso("Atenção","Importação com exito!",{"Ok"},1)
Return (aDados)


/*/{Protheus.doc} Importar
//TODO Função que captura arquivo texto e exporta array.
@author juliana.leme
@since 26/04/2016
@version 1.0
@param cArqImpor, Caracter, Arquivo a ser importado
@type function
/*/
Static Function ImpVarios(cArqImpor)
	Local cLinha 	:= ""
	Local nLinha 	:= 0
	Local aDados 	:= {}
	Local nTamLinha := 0
	Local nTamArq	:= 0
	Local nCont  	:= 1
	Local cDir		:= Alltrim(Substr(cArqImpor,1,rat("\",cArqImpor)))
	Local cDirDest	:= Alltrim(Substr(cArqImpor,1,rat("\",cArqImpor))) + "Lidos\"

	Private aArqs     := {}
	Private aArqOri   := {}

	aArqOri := directory(cDir + "*.TXT")
	for nXi := 1 to Len(aArqOri)
		aadd(aArqs, aArqOri[nXi, 1])
	next nXi

	aArqs := asort(aArqs) //Ordena Arquivos !!!

	/*
	aDir  := Directory(cDirDest ,"D")
	If Len(aDir) = 0
		If MakeDir(cDirDest) <> 0
			Help(" ",1,"NOMAKEDIR")
			Return(.F.)
		EndIf
	EndIf
	*/
	For n1 := 1 to Len(aArqs)
		//Valida arquivo
		If !file(cDir + aArqs[n1])
			Aviso("Arquivo","Arquivo não selecionado ou invalido.",{"Sair"},1)
			Return (.F.)
		Else
			//+---------------------------------------------------------------------+
			//| Abertura do arquivo texto                                           |
			//+---------------------------------------------------------------------+
			nHdl := fOpen(cDir + aArqs[n1])

			If nHdl == -1
				If FERROR()== 516
					Alert("Feche a planilha que gerou o arquivo.")
				EndIF
			EndIf

			//+---------------------------------------------------------------------+
			//| Verifica se foi possível abrir o arquivo                            |
			//+---------------------------------------------------------------------+
			If nHdl == -1
				cMsg := "O arquivo de nome " + cDir + aArqs[n1] +" nao pode ser aberto! Verifique os parametros."
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
			FT_FUse(cDir + aArqs[n1])  //abre o arquivo
			FT_FGOTOP()         //posiciona na primeira linha do arquivo
			nTamLinha := Len(FT_FREADLN()) //Ve o tamanho da linha
			FT_FGOTOP()

			//+---------------------------------------------------------------------+
			//| Verifica quantas linhas tem o arquivo                               |
			//+---------------------------------------------------------------------+
			nLinhas := nTamArq/nTamLinha
			ProcRegua(nLinhas)
			nCont := 1
			While !FT_FEOF() //Ler todo o arquivo enquanto não for o final dele
				IncProc('Importando Linha: ' + Alltrim(Str(nCont)))
				clinha := FT_FREADLN()
				If ! Empty(Alltrim(clinha))
					aadd(aDados,Separa(cLinha,";",.T.))
				Endif
				nCont	:= nCont +1
				FT_FSKIP()
			EndDo

			FT_FUse()
			fClose(nHdl)

			fRename(Alltrim(cDir + aArqs[n1]) , Alltrim(cDirDest + aArqs[n1]))
			//__CopyFile(Alltrim(cDir + aArqs[n1]),Alltrim(cDirDest + aArqs[n1]))
		EndIf
	Next
	Aviso("Atenção","Importação com exito!",{"Ok"},1)
Return (aDados)


/*/{Protheus.doc} CarregXLS
//TODO Função que coleta a planilha principal e grava em tabela ZAH.
@author juliana.leme
@since 29/07/2015
@version 1.0
@type function
/*/
User Function CarregXLS()
	Local aDados
	Local n1   		:= 4
	Local n2		:= 0
	Local dDataInv	:= dDataBase
	local cSql 		:= ""
	Local nCont 	:= 1

	aParamBox := {}
	aRet := ""

	aAdd(aParamBox,{6,"Qual Arquivo","C:\","","","" ,70,.T.,"Arquivo .XLS |*.XLS"})

	If !ParamBox(aParamBox, "Parametros", @aRet)
		Return(.F.)
	EndIf
	ProcRegua(0)
	cArq 		:= Alltrim(Substr(aRet[1],rat("\",aRet[1])+1,len(aRet[1])))
	cOrigem	:= Alltrim(Substr(aRet[1],1,rat("\",aRet[1])))

	Processa( {|| aDados:= U_CargaXLS(cArq,cOrigem,,.F.)},"Aguarde, carregando planilha...Pode demorar")
	DBSelectArea("ZAH")
	DbGotop()
	ProcRegua(RecCount())
	If DbSeek(xFilial("ZAH")+DtoS(dDataInv))
		If MsgBox("Ja existe carregamento de Inventario nesta data, deseja substituir ?","Confirma","YesNo")
			cSql :=  " DELETE FROM "+RetSqlName("ZAH")+" WHERE ZAH_DATA = "+DtoS(dDataInv)
			TcSqlExec(cSql)
			Conout("Tabela Excluida ZAH por opção do usuario")
			DbGotop()
		Else
			Return
		EndIf
	EndIf
	If !(DbSeek(xFilial("ZAH")+DtoS(dDataInv)))
		ProcRegua(len(aDados)-4)
		For n1:= 4 to len (aDados)
			RecLock("ZAH",.T.)
			ZAH->ZAH_FILIAL		:= xFilial("ZAH")
			ZAH->ZAH_DATA			:= dDataInv
			ZAH->ZAH_MOVUN		:= Val(aDados[n1][1]) //l,c
			ZAH->ZAH_DEPOSI		:= aDados[n1][2]
			ZAH->ZAH_ADDRES 		:= aDados[n1][3]
			ZAH->ZAH_PRODUT		:= aDados[n1][4]
			ZAH->ZAH_LOTE			:= aDados[n1][5]
			ZAH->ZAH_CLASSI		:= aDados[n1][6]
			ZAH->ZAH_ORIGIN		:= aDados[n1][7]
			ZAH->ZAH_OP			:= aDados[n1][8]
			ZAH->ZAH_OPERAT		:= aDados[n1][9]
			ZAH->ZAH_QTDE			:= Val(StrTran(StrTran(aDados[n1][10],".",""),",","."))
			ZAH->ZAH_UM			:= aDados[n1][11]
			ZAH->ZAH_AUX1			:= aDados[n1][12]
			ZAH->ZAH_AUX2			:= aDados[n1][13]
			ZAH->ZAH_AUX3			:= aDados[n1][14]
			ZAH->ZAH_AUX4			:= aDados[n1][15]
			//Contagem 1
			ZAH->ZAH_ADDR1		:= aDados[n1][16]
			ZAH->ZAH_LOT1			:= aDados[n1][17]
			ZAH->ZAH_CLAS1		:= aDados[n1][18]
			ZAH->ZAH_ORIG1		:= aDados[n1][19]
			ZAH->ZAH_OP1			:= aDados[n1][20]
			ZAH->ZAH_OPER1		:= aDados[n1][21]
			ZAH->ZAH_QTDE1		:= Val(StrTran(StrTran(aDados[n1][22],".",""),",","."))
			//Contagem 2
			ZAH->ZAH_ADDR2		:= aDados[n1][22]
			ZAH->ZAH_LOT2			:= aDados[n1][23]
			ZAH->ZAH_CLAS2		:= aDados[n1][24]
			ZAH->ZAH_ORIG2		:= aDados[n1][25]
			ZAH->ZAH_OP2			:= aDados[n1][26]
			ZAH->ZAH_OPER2		:= aDados[n1][27]
			ZAH->ZAH_QTDE2		:= Val(StrTran(StrTran(aDados[n1][28],".",""),",","."))
			//Contagem 3
			ZAH->ZAH_ADDR3		:= aDados[n1][29]
			ZAH->ZAH_LOT3			:= aDados[n1][30]
			ZAH->ZAH_CLAS3		:= aDados[n1][31]
			ZAH->ZAH_ORIG3		:= aDados[n1][32]
			ZAH->ZAH_OP3			:= aDados[n1][33]
			ZAH->ZAH_OPER3		:= aDados[n1][34]
			ZAH->ZAH_QTDE3		:= Val(StrTran(StrTran(aDados[n1][35],".",""),",","."))

			MsUnlock()
			DbCommit()
			cCont:= nCont +1
			IncProc('Importando Registro ' + Alltrim(Str(nCont)))
		Next
	EndIf
	DbCloseArea("ZAH")
	Alert("Processo Finalizado! Planilha importada com êxito!")
Return


/*/{Protheus.doc} GravInvPPI
//TODO Grava inventario na base de dados da PPI.
@author juliana.leme
@since 13/08/2015
@version 1.0

@type function
/*/
User function GravInvPPI()
	Local cQuery	:= ""
	Local nCount	:= 1
	Private oApp_Ori
	Private nHndErp 	:= AdvConnection()	
	Private cDB_PPI 	:= GetMV("ZZ_HNDPCF")//"MSSQL/PCFactory"	//Tipo e nome do banco de integração (PC-Factory) (OFICIAL)
	Private cSrvPPI 	:= GetMV("ZZ_SRVPPI")//"192.168.3.2"		//Servidor onde está o banco de integração (OFICIAL)
	Private nPrtPPI 	:= 7890	// Porta
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

	TcSetConn(nHndERP)
	ProcRegua(0)
	IncProc("Aguarde, Atualizando Inventario ...")
	//Atualiza todas as contagens 1 e 2 quando iguais
	_cQuery := " UPDATE ZAH010 SET "
	_cQuery := " 			ZAH_ADDR3 = ZAH_ADDR1, "
	_cQuery := "			ZAH_CLAS3 = ZAH_CLAS1, "
	_cQuery := " 			ZAH_LOT3 = ZAH_LOT1, "
	_cQuery := " 			ZAH_OP3 = ZAH_OP1, "
	_cQuery := " 			ZAH_OPER3 = ZAH_OPER1, "
	_cQuery := " 			ZAH_ORIG3 = ZAH_ORIG1, "
	_cQuery := " 			ZAH_QTDE3 = ZAH_QTDE1 "
	_cQuery := " 	WHERE ZAH_QTDE1 = ZAH_QTDE2 "
	_cQuery := " 		AND ZAH_QTDE3 = 0 "
	_cQuery := "		AND ZAH_DATA  = '" + DtoS(dDataBase) + "'  "
	
	//Executa Query
	TCSqlExec(_cQuery)
	//Verifica se a Query foi executada
	If (TCSqlExec(_cQuery) < 0) // Deu Erro
		//_lVolta := .T. // Significa que deu erro na função
		cMsg := TCSQLError() //+ linha
		MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
	EndIf
	
	//Carrega dados da tabela ZAH
	DbSelectArea("ZAH")
	DbGotop()
	DbSetFilter({ || ZAH->ZAH_DATA == dDataBase},"")
	DbSeek(xFilial("ZAH")+DtoS(dDataBase),.F.)
	ProcRegua(RecCount())
	
	Do While ZAH->ZAH_FILIAL == xFilial("ZAH") .And. ZAH->(!Eof()) .And. ZAH->ZAH_DATA == dDataBase

		//Coloca os Registros de Integração em Processo
		_cQuery := " Update MovUn Set  "
		_cQuery += " MovUn.QtyCount1 = ISNULL(" + IIf(!Empty(Alltrim(Str(ZAH->ZAH_QTDE1))),Alltrim(Str(ZAH->ZAH_QTDE1)),0) +",0), "
		_cQuery += " MovUn.IDAddressCount1 = Addr.IdAddress, "
		_cQuery += " MovUn.IDLotCount1 =  MovUn.IDlot, "
		_cQuery += " MovUn.DtCount1 = getdate (), "
		_cQuery += " MovUn.IDUserCount1 = 1, "
		_cQuery += " MovUn.QtyCount2 = ISNULL(" + IIf(!Empty(Alltrim(Str(ZAH->ZAH_QTDE2))),Alltrim(Str(ZAH->ZAH_QTDE2)),0) +",0), "
		_cQuery += " MovUn.IDAddressCount2 = Addr.IdAddress, "
		_cQuery += " MovUn.IDLotCount2 =  MovUn.IDlot, "
		_cQuery += " MovUn.DtCount2 = getdate (), "
		_cQuery += " MovUn.IDUserCount2 = 1, "
		_cQuery += " MovUn.QtyCount3 = ISNULL(" + IIf(!Empty(Alltrim(Str(ZAH->ZAH_QTDE3))),Alltrim(Str(ZAH->ZAH_QTDE3)),0) +",0), "
		_cQuery += " MovUn.IDAddressCount3 = Addr.IdAddress, "
		_cQuery += " MovUn.IDLotCount3 =  MovUn.IDlot, "
		_cQuery += " MovUn.DtCount3 = getdate (), "
		_cQuery += " MovUn.IDUserCount3 = 1 "
		_cQuery += " from TBLInvCountMovUn MovUn,
		_cQuery += "      TBLAddress Addr "
		_cQuery += " where MovUn.IdMovun = " + Str(ZAH->ZAH_MOVUN)
		_cQuery += " and Addr.Code = '" +Alltrim(ZAH->ZAH_ADDR3) +"'"

		//Conecta com PPI
		TcSetConn(nHndPPI)
		//Executa Query
		TCSqlExec(_cQuery)
		//Verifica se a Query foi executada
		If (TCSqlExec(_cQuery) < 0) // Deu Erro
			//_lVolta := .T. // Significa que deu erro na função
			cMsg := TCSQLError() //+ linha
			MsgBox(cMsg,"ATENÇÃO ERRO","STOP")
		EndIf
		//Retorna conexão Protheus
		TcSetConn(nHndERP)
		nCount := nCount +1
		IncProc('Gravando Registro no PCF '+Alltrim(Str(nCount))+' de '+Alltrim(Str(RecCount())))
		ZAH->(DbSkip())
	EndDo

	//Encerra conexão PPI
	TcUnLink(nHndPPI)
	//Conecta ERP
	TcSetConn(nHndERP)
	oApp 	:= oApp_Ori
Return()


/*/{Protheus.doc} ExportXLS
//TODO Função que Exporta no formato da PPI a planilha com os dados do inventario.
@author juliana.leme
@since 29/07/2015
@version 1.0

@type function
/*/
User Function ExportXLS()
	Local oExcel		:= FWMSEXCEL():New()
	Local aCabec		:= {}
	Local aDados		:= {}
	Local dDataInv 	:= dDataBase
	Local aParamBox 	:= {}
	Local aRet 		:= ""
	Local cDir			:= ""

	aAdd(aParamBox,{6,"Pasta de Saída:",Space(70),"","","" ,70,.T.,"Arquivo .XLS |*.XLS"})

	If !ParamBox(aParamBox, "Parametros", @aRet)
		Return(.F.)
	EndIf
	ProcRegua(0)
	//dDataInv 	:= aRet[1]
	cDir		:= Alltrim(Substr(aRet[1],1,rat("\",aRet[1])))

	oExcel:AddworkSheet("MovUn Inventory")
	oExcel:AddTable("MovUn Inventory","PC-Factory")

	oExcel:AddColumn("MovUn Inventory","PC-Factory","PC-Factory",1,1)//1
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//2
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//3
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//4
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//5
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//6
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//7
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//8
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//8
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//9
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//10
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//11
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//12
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//13
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//14
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//15
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//16
	oExcel:AddColumn("MovUn Inventory","PC-Factory","Count.1",1,1)//17
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//18
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//19
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//20
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//21
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//22
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//23
	oExcel:AddColumn("MovUn Inventory","PC-Factory","Count.2",1,1)//24
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//25
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//26
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//27
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//28
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//29
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//30
	oExcel:AddColumn("MovUn Inventory","PC-Factory","Count.3",1,1)//31
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//32
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//33
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//34
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//35
	oExcel:AddColumn("MovUn Inventory","PC-Factory","",1,1)//36
	oExcel:AddColumn("MovUn Inventory","PC-Factory","Select the",1,1)//37

	//Montando Cabeçalho
	aAdd(aCabec,{"IDMovUn",;//1
	"Warehouse",;//2
	"Address",;//3
	"Product",;//4
	"Lot",;//5
	"Classification",;//6
	"Origin",;//7
	"Work Order",;//8
	"Operation",;//9
	"Quantity",;//10
	"Unit",;//11
	"Local",;//11
	"AuxField1",;//12
	"AuxField2",;//13
	"AuxField3",;//14
	"AuxField4",;//15
	"Address",;//1 contagem //16
	"Lot",;//17
	"Classification",;//18
	"Origin",;//19
	"Work Order",;//20
	"Operation",;//21
	"Quantity",;//22
	"Address",;//2 contagem //23
	"Lot",;//24
	"Classification",;//25
	"Origin",;//26
	"Work Order",;//27
	"Operation",;//28
	"Quantity",;//29
	"Address",;//3 contagem //30
	"Lot",;//31
	"Classification",; //32
	"Origin",;//33
	"Work Order",;//34
	"Operation",;//35
	"Quantity",;//36
	"Best Count."})//37

	//Carrega dados da tabela ZAH
	DbSelectArea("ZAH")
	DbGotop()
	DbSeek(xFilial("ZAH")+DtoS(dDataInv),.F.)
	ProcRegua(RecCount())
	Do While ZAH->ZAH_FILIAL == xFilial("ZAH") .And. ZAH->(!Eof())
		//Teste
		aAdd(aDados,{ZAH->ZAH_MOVUN,;
		ZAH->ZAH_DEPOSI,;
		ZAH->ZAH_ADDRES,;
		ZAH->ZAH_PRODUT,;
		ZAH->ZAH_LOTE,;
		ZAH->ZAH_CLASSI,;
		ZAH->ZAH_ORIGIN,;
		ZAH->ZAH_OP,;
		ZAH->ZAH_OPERAT,;
		ZAH->ZAH_QTDE,;
		ZAH->ZAH_UM,;
		ZAH->ZAH_LOCAL,;
		ZAH->ZAH_AUX1,;
		ZAH->ZAH_AUX2,;
		ZAH->ZAH_AUX3,;
		ZAH->ZAH_AUX4,;
		ZAH->ZAH_ADDR1,; //1 contagem
		ZAH->ZAH_LOT1,;
		ZAH->ZAH_CLAS1,;
		ZAH->ZAH_ORIG1,;
		ZAH->ZAH_OP1,;
		ZAH->ZAH_OPER1,;
		ZAH->ZAH_QTDE1,;
		ZAH->ZAH_ADDR2,; //1 contagem
		ZAH->ZAH_LOT2,;
		ZAH->ZAH_CLAS2,;
		ZAH->ZAH_ORIG2,;
		ZAH->ZAH_OP2,;
		ZAH->ZAH_OPER2,;
		ZAH->ZAH_QTDE2,;
		ZAH->ZAH_ADDR3,; //1 contagem
		ZAH->ZAH_LOT3,;
		ZAH->ZAH_CLAS3,;
		ZAH->ZAH_ORIG3,;
		ZAH->ZAH_OP3,;
		ZAH->ZAH_OPER3,;
		ZAH->ZAH_QTDE3,;
		"Count. 3"	})
		ZAH->(DbSkip())
		IncProc()
	Enddo

	//Carrega Cabecalho
	ProcRegua(len(aCabec))
	For n1:= 1 to len(aCabec)
		oExcel:AddRow("MovUn Inventory","PC-Factory",aCabec[n1])
		IncProc('Importando Cabeçalho')
	Next

	ProcRegua(len(aDados))
	For n1:=1 to len (aDados)
		oExcel:AddRow("MovUn Inventory","PC-Factory",aDados[n1])
		IncProc('Importando Item '+Alltrim(Str(n1))+ ' de '+Alltrim(Str(Len(aDados))))
	Next

	//oExcel:AddRow("MovUn Inventory","PC-Factory",aDados)
	oExcel:Activate()
	oExcel:GetXMLFile(cDir+"\Invent"+DtoS(Date())+".xls")
	Alert("A planilha foi exportada com sucesso em "+cDir+"Invent"+DtoS(Date())+".xls")
	DbCloseArea("ZAH")
Return


/*/{Protheus.doc} SldPCF
//TODO Alimenta inventario do PCF para o Protheus.
@author juliana.leme
@since 13/11/2015
@version 1.0

@type function
/*/
User Function SldPCF()
	Local	aParamBox	:= {}
	Local	aRet 		:= ""
	Local	cQuery 	:= ""
	Local 	dDataInv	:= dDataBase


	//Contagem sempre sera 3 - Juliana 16/06/2016
	aAdd(aParamBox,{3,"Contagem:",1,{"Contagem 1","Contagem 2","Contagem 3"},50,"",.F.})

	If !ParamBox(aParamBox, "Parametros", @aRet)
		Return(.F.)
	EndIf

	nContag	:= aRet[1]

	nContag	:= 3

	cQuery := "SELECT ZAH_PRODUT PRODUTO, "
	cQuery += "     SUM(ZAH_QTDE"+Alltrim(Str(nContag))+") QTDE, "
	cQuery += "     ZAH_DATA DATAIN, "
	cQuery += "     ZAH_ADDR"+Alltrim(Str(nContag))+" LOCALI "
	cQuery += " FROM ZAH010 "
	cQuery += " WHERE ZAH_DATA = '" + DtoS(dDataInv) + "' "
	cQuery += "   AND SUBSTRING(ZAH_ADDR"+Alltrim(Str(nContag))+",1,2)  =  '" + cFilAnt +"'"
	cQuery += "   AND ZAH_QTDE3 > 0 "
	cQuery += "   AND D_E_L_E_T_ = '' "
	cQuery += " GROUP BY ZAH_PRODUT, ZAH_DATA, ZAH_ADDR" + Alltrim(Str(nContag))

	IncProc("Aguarde, Carregando Dados Inventário")

	cQuery := ChangeQuery(cQuery)

	If Select("TRB1")>0
		DbSelectArea("TRB1")
		DbCloseArea()
	EndIf

	TCQUERY cQuery NEW ALIAS "TRB1"

	DbSelectArea("SB1")
	DbSetorder(1)

	DbSelectArea("SZG")
	DBOrderNickName("ZGPPILOTE")

	DbSelectArea("TRB1")
	DbGotop()

	Do While !TRB1->(Eof())
		If TRB1->QTDE > 0
			//DBOrderNickName("ZGPPILOTE")
			//DBSetOrder(3)
			//If !DbSeek(xFilial("SZG") + DtoC(StoD(TRB1->DATAIN)) + Padr("PCFactory",TamSX3("ZG_LOTE")[1]) + TRB1->PRODUTO,.F.)
				RecLock("SZG",.T.)
				cProduto := Alltrim(TRB1->PRODUTO)

				If Posicione("SB1",1,xFilial("SB1") + Alltrim(TRB1->PRODUTO),"B1_TIPO") == "PA"
					cLocal := "20"
					cAcond := "PROD_PCF"
				Else
					cLocal := IIf(Substr(TRB1->LOCALI,3,3) = "WIP", "99", "01")
					cAcond := ""
				EndIf

				SZG->ZG_FILIAL		:= Substr(Alltrim(TRB1->LOCALI),1,2)
				SZG->ZG_PRODUTO		:= cProduto
				SZG->ZG_DATA		:= StoD(TRB1->DATAIN)
				SZG->ZG_CONTAG		:= "3"
				SZG->ZG_LOCAL		:= cLocal
				SZG->ZG_DESC		:= Posicione("SB1",1,xFilial("SB1") + Alltrim(TRB1->PRODUTO),"B1_DESC")
				SZG->ZG_ACOND		:= ""
				SZG->ZG_QUANT		:= 1
				SZG->ZG_LANCE		:= 1
				//SZG->ZG_LOCALIZ		:= cAcond
				SZG->ZG_METROS		:= TRB1->QTDE
				SZG->ZG_QTDEINV		:= TRB1->QTDE
				SZG->ZG_PESCOB		:= TRB1->QTDE * Posicione("SB1",1,xFilial("SB1") + Alltrim(TRB1->PRODUTO),"B1_PESCOB")
				SZG->ZG_PESPVC		:= TRB1->QTDE * Posicione("SB1",1,xFilial("SB1") + Alltrim(TRB1->PRODUTO),"B1_PESPVC")
				SZG->ZG_LOTE		:= "PCFactory"
				SZG->ZG_FORMA		:= "I"
				SZG->ZG_UM			:= Posicione("SB1",1,xFilial("SB1") + Alltrim(TRB1->PRODUTO),"B1_UM")
				SZG->(MsUnLock())
		EndIf
		TRB1->(DbSkip())
	EndDo
Return(.T.)

/*/{Protheus.doc} CBCInvRetr
//TODO Descrição auto-gerada.
@author juliana.leme
@since 02/12/2016
@version undefined

@type function
/*/
User Function CBCInvRetr()
Local _aDad 	:= {}
Local aParamBox := {}
Local aRet 		:= ""
Local oExcel	:= FWMSEXCEL():New()
Local aCabec	:= {}
Local aColPPI	:= {}
Local _cIDNInv	:= ""

	aAdd(aParamBox,{6,"Qual Arquivo Retrab.","\SERVIDOR\Coletores\UNIMOV\","","","" ,70,.T.,"Arquivo .TXT|*.TXT"})

	If !ParamBox(aParamBox, "Parametros", @aRet)
		Return(.F.)
	EndIf

	cOrigem	:= aRet[1]
	Processa( {|| _aDad := ImpVarios(cOrigem,,.F.)},"Aguarde, Carregando Coleta Retrabalhos ... Pode demorar ...")

	//Gera Divergencias
	cQuery := " UPDATE ZZE010 SET "
	cQuery += "		ZZE_QTDINV = 0 "
	cQuery += "	FROM ZZE010 ZE "
	cQuery += "	WHERE ZZE_QTDINV <> 0 "
	cQuery += "		AND ZZE_QTDINV <> '' "
	cQuery += "		AND ZE.D_E_L_E_T_ = '' "

	IncProc("Aguarde, Limpando Tabelas ... ")

	cQuery := ChangeQuery(cQuery)

	If len(_aDad) > 0
		For nCont := 1 to len(_aDad)

			DbSelectArea("SZG")
			DBSetOrder(1)

			DbSelectArea("SB1")
			DBSetOrder(1)

			//Carrega dados da tabela ZAH
			DbSelectArea("ZZE")
			DbGotop()
			DbSetOrder(1)
			DbSeek(xFilial("ZZE")+_aDad[nCont][2],.F.)

			/*/
			1-Aguard. Separacao
			2-Aguard. Ord. Servico
			3-Em Retrabalho
			4-Baixado
			5-Encerrado
			6-Em CQ
			7-Parcial
			8-Encerr.CQ
			9-Cancelado
			/*/

			If ZZE->ZZE_SITUAC == "1"
				_cIDNInv += _aDad[nCont][2]+";"
			Endif

			While ZZE->ZZE_FILIAL == xFilial("ZZE") .and. ZZE->ZZE_ID == _aDad[nCont][2]
				RecLock("ZZE",.F.)
				ZZE->ZZE_DTINVE := dDataBase
				ZZE->ZZE_QTDINV	:= Val(StrTran(_aDad[nCont][3],",","."))
				ZZE->(Msunlock())
				ZZE->(DbCommit())
				ZZE->(DbSkip())
			Enddo
		Next
	Else
		Alert("Arquivo Vazio")
	EndIf

	Alert("Os retrabalhos : " + _cIDNInv + " ... Não foram Inventariados, Verifique!")

	//Gera Divergencias
	cQuery := " SELECT "
	cQuery += "	ZZE_ID 		AS [IDZZE], "
	cQuery += "	ZZE_PRODUT 	AS [PRODUTO], "
	cQuery += "	B1_DESC 	AS [DESCRICAO], "
	cQuery += "	ZZE_DTINI	AS [DATA_INICIAL], "
	cQuery += "	ZZE_ACONDE	AS [ACOND_ENTR], "
	cQuery += "	ZZE_LANCEE	AS [LANCE_ENTR], "
	cQuery += "	ZZE_METRAE	AS [METRAG_ENTR], "
	cQuery += "	ZZE_TOTEN	AS [TOTAL_ENTR],  "
	cQuery += "	ZZE_SALDO   AS [SALDO], "
	cQuery += "	SUM(ZZE_SALDO * B1_PESCOB) AS [PES_COB] "
	cQuery += "	FROM ZZE010 ZE  "
	cQuery += "	INNER JOIN SB1010 B1 ON B1_FILIAL = '  '  "
	cQuery += "							AND B1_COD = ZZE_PRODUT  "
	cQuery += "							AND ZE.D_E_L_E_T_ = B1.D_E_L_E_T_ "
	cQuery += "	WHERE ZZE_FILIAL = '" + FwFilial() + "'  "
	cQuery += "	AND ZZE_SITUAC = '2'  "
	cQuery += "	AND (ZZE_DTINVE <> '" + DtoS(dDataBase) + "')  "
	cQuery += "	AND ZZE_STATUS <> 'A' "
	cQuery += "	AND ZE.D_E_L_E_T_ = '' "
	cQuery += "	AND ZZE_DTINI >= '20170101' "
	cQuery += "	GROUP BY  ZZE_ID, ZZE_PRODUT, B1_DESC,  "
	cQuery += "	ZZE_DTINI,ZZE_ACONDE	, ZZE_LANCEE "
	cQuery += "	,ZZE_METRAE,ZZE_TOTEN, ZZE_SALDO "

	IncProc("Aguarde, Carregando Dados Inventário")

	cQuery := ChangeQuery(cQuery)

	If Select("TRBRETRAB")>0
		DbSelectArea("TRBRETRAB")
		DbCloseArea()
	EndIf

	TCQUERY cQuery NEW ALIAS "TRBRETRAB"

	DbSelectArea("TRBRETRAB")
	DbGotop()

	If ! TRBRETRAB->(Eof())

		aParamBox	:= {}
		aRet		:= ""

		aAdd(aParamBox,{6,"Pasta de Saída:","E:\RELSIGA\","","","" ,70,.T.,""})

		If !ParamBox(aParamBox, "Parametros", @aRet)
			Return(.F.)
		EndIf

		If "\" $ aRet[1]
			_cPasta		:= Alltrim(Substr(aRet[1],1,rat("\",aRet[1])-1))
		Else
			_cPasta		:= Alltrim(aRet[1])
		EndIf

		_cPasta		:= IIf (Empty(Alltrim(_cPasta)),"C:\TEMP\",_cPasta)
		_lCorreto 	:= .T.

		oExcel:AddworkSheet("InvRetrab")
		oExcel:AddTable("InvRetrab","Retrabalho")

		oExcel:AddColumn("InvRetrab","Retrabalho","",1,1)//1
		oExcel:AddColumn("InvRetrab","Retrabalho","",1,1)//2
		oExcel:AddColumn("InvRetrab","Retrabalho","",1,1)//3
		oExcel:AddColumn("InvRetrab","Retrabalho","",1,1)//4
		oExcel:AddColumn("InvRetrab","Retrabalho","",1,1)//5
		oExcel:AddColumn("InvRetrab","Retrabalho","",1,1)//6
		oExcel:AddColumn("InvRetrab","Retrabalho","",1,1)//7
		oExcel:AddColumn("InvRetrab","Retrabalho","",1,1)//8
		oExcel:AddColumn("InvRetrab","Retrabalho","",1,1)//9
		oExcel:AddColumn("InvRetrab","Retrabalho","",1,1)//10

		//Montando Cabeçalho
		aAdd(aCabec,{"ID.Retrab",;//1
					"Produto",;//2
					"Descrição",;//3
					"Dt.Inicial",;//4
					"Acond.Entr",;//5
					"Lance Entr",;//6
					"Metrag Entr",;//7
					"Total Entr",;//8
					"Saldo",;//09
					"Pes.Cobre"})//10

		For n1:= 1 to len(aCabec)
			oExcel:AddRow("InvRetrab","Retrabalho",aCabec[n1])
			IncProc('Importando Cabeçalho')
		Next

		While ! TRBRETRAB->(Eof())
			aColunas := {}

			aAdd(aColunas,{TRBRETRAB->IDZZE,;
			 			TRBRETRAB->PRODUTO,;
						TRBRETRAB->DESCRICAO,;
						TRBRETRAB->DATA_INICIAL,;
						TRBRETRAB->ACOND_ENTR,;
						TRBRETRAB->LANCE_ENTR,;
						TRBRETRAB->METRAG_ENTR,;
						TRBRETRAB->TOTAL_ENTR,;
						TRBRETRAB->SALDO,;
						TRBRETRAB->PES_COB})
			oExcel:AddRow("InvRetrab","Retrabalho",aColunas[1])
			TRBRETRAB->(dbSkip())
		EndDo

		oExcel:Activate()
		oExcel:GetXMLFile(_cPasta+"\Retrabalho_"+DtoS(Date())+".xls")
		Alert("A planilha foi exportada com sucesso em "+_cPasta+"Retrabalho_"+DtoS(Date())+".xls")
	EndIf
Return(.T.)


/*/{Protheus.doc} ImpSB9xls
//TODO Descrição auto-gerada.
@author julian.leme
@since 04/03/2017
@version undefined

@type function
/*/
User Function ImpSB9xls()
	local aDados
	local dDataInv	:= dDataBase
	local nCont 	:= 1

	aParamBox := {}
	aRet := ""

	aAdd(aParamBox,{6,"Informe Planilha ",Space(70),"","","" ,70,.T.,"Arquivo .XLS |*.XLS"})

	If !ParamBox(aParamBox, "Parametros", @aRet)
		Return(.F.)
	EndIf

	ProcRegua(0)
	cArq 		:= Alltrim(Substr(aRet[1],rat("\",aRet[1])+1,len(aRet[1])))
	cOrigem		:= Alltrim(Substr(aRet[1],1,rat("\",aRet[1])))

	Processa( {|| aDados:= U_CargaXLS(cArq,cOrigem,,.F.)},"Aguarde, carregando planilha...Pode demorar")

	If Len(aDados) > 0
		dData := "20161231"
		DbSelectArea("SB9")
		DbSetOrder(1) //B9_FILIAL, B9_COD, B9_LOCAL, B9_DATA, R_E_C_N_O_, D_E_L_E_T_
		For n:= 1 to Len(aDados)
			If DbSeek(xFilial("SB9")+Padr(aDados[n][1],17) + "20" + dData)
				If SB9->B9_FILIAL = xFilial("SB9") .and. Alltrim(SB9->B9_COD) == aDados[n][1] .and. DtoS(SB9->B9_DATA) == dData
					RecLock("SB9",.F.)
					SB9->B9_VINI1 := Round(SB9->B9_QINI * Val(StrTran(StrTran(aDados[n][2],".",""),",",".")),4)
					MsUnLock()
				EndIf
			EndIf
			DbSkip()
		Next
	EndIf
Return




/*/{Protheus.doc} ImpSB9xls
//TODO Descrição auto-gerada.
@author julian.leme
@since 04/03/2017
@version undefined

@type function
/*/
User Function ConsXLSMata240() //U_ConsXLSMata240()
	local aDados
	local dDataInv	:= dDataBase
	local nCont 	:= 1

	aParamBox := {}
	aRet := ""

	aAdd(aParamBox,{6,"Informe Planilha ",Space(70),"","","" ,70,.T.,"Arquivo .XLS |*.XLS"})

	If !ParamBox(aParamBox, "Parametros", @aRet)
		Return(.F.)
	EndIf

	ProcRegua(0)
	cArq 		:= Alltrim(Substr(aRet[1],rat("\",aRet[1])+1,len(aRet[1])))
	cOrigem		:= Alltrim(Substr(aRet[1],1,rat("\",aRet[1])))

	Processa( {|| aDados:= U_CargaXLS(cArq,cOrigem,,.F.)},"Aguarde, carregando planilha...Pode demorar")

	If Len(aDados) > 0
		For n:= 1 to Len(aDados)
			Begin Transaction
				nQtde	:= Round(Val(StrTran(StrTran(aDados[n][3],".",""),",",".")),4)

				aItens 	:= {{"D3_TM",Padr("504",TamSX3("D3_TM")[1])	 								,NIL},; //TP.MOVIM.
						{"D3_COD" 		,Padr(Alltrim(aDados[n][1]),TamSX3("D3_COD")[1])			,NIL},; //D3_COD
						{"D3_DOC"		,Padr(Alltrim("ACARMZ03"),TamSX3("D3_DOC")[1])				,NIL},; //TP.MOVIM.
						{"D3_UM" 		,Posicione("SB1",1,xFilial("SB1")+Alltrim(aDados[n][1]),"B1_UM"),NIL},;
						{"D3_LOCAL" 	,Padr("99",TamSX3("D3_LOCAL")[1])							,NIL},;
						{"D3_LOCALIZ" 	,Padr("",TamSX3("D3_LOCALIZ")[1])							,NIL},;
						{"D3_QUANT" 	,Round(ABS(nQtde),4)										,NIL},;
						{"D3_HIST" 		,Padr("ARMZ 03 CONSUMO CONTRA OP",TamSX3("D3_HIST")[1])		,NIL},;
						{"D3_OP" 		,Padr(Alltrim(aDados[n][4]),TamSX3("D3_OP")[1])				,NIL},;
						{"D3_EMISSAO" 	,aDados[n][5]							  	   				,NIL},;
						{"D3_PARCTOT" 	,Padr("P",TamSX3("D3_PARCTOT")[1])						   	,NIL},;
						{"D3_ZZLOTE" 	,""		   													,NIL},;
						{"D3_ZZUNMOV" 	,0															,NIL}}

				lMsErroAuto 	:= .F.
				//Processar
				MSExecAuto({|x,y| mata240(x,y)},aItens,3)

				If lMsErroAuto
					DisarmTransaction()
					_aErro := GetAutoGRLog()
					MostraErro()
				EndIf
			End Transaction
		Next

	/*
		dData := "20161231"
		DbSelectArea("SB9")
		DbSetOrder(1) //B9_FILIAL, B9_COD, B9_LOCAL, B9_DATA, R_E_C_N_O_, D_E_L_E_T_
		For n:= 1 to Len(aDados)
			If DbSeek(xFilial("SB9")+Padr(aDados[n][1],17) + "20" + dData)
				If SB9->B9_FILIAL = xFilial("SB9") .and. Alltrim(SB9->B9_COD) == aDados[n][1] .and. DtoS(SB9->B9_DATA) == dData
					RecLock("SB9",.F.)
					SB9->B9_VINI1 := Round(SB9->B9_QINI * Val(StrTran(StrTran(aDados[n][2],".",""),",",".")),4)
					MsUnLock()
				EndIf
			EndIf
			DbSkip()
		Next
		*/
	EndIf
Return
