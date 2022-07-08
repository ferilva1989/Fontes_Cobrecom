#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} cbcSrvPedFil
//TODO Descrição auto-gerada.
@author juliana.leme
@since 15/01/2020
@version 1.0
@param ccbcFil, characters, descricao
@param aSC5Cab, array, descricao
@param aSC6It, array, descricao
@param nOper, numeric, Operação que sera realizada 3 = Inclusão, 5 = Exclusão
@type function
/*/
user function cbcSrvPedFil(aCtrlPed, nOper)
	local aRet				:= {.T.,{}}
	local cFlAntes			:= cFilAnt
	local cErr				:= ""
	local nPedido			:= 0
	private oDadosPed		:= nil
	private cTesFis			:= ""
	private cNumPV			:= ""
	private	lMsErroAuto		:= .F.
	private lMsHelpAuto		:= .T.
	private lAutoErrNoFile	:= .T.
	private lIsJobAuto		:= .T.
	private cOperFis		:= ""
	default nOper			:= 3
	
	for nPedido := 1 to len (aCtrlPed)
		oDadosPed	:= JSonObject():New()
		cErr 		:= oDadosPed:fromJson(aCtrlPed[nPedido])
		if !empty(cErr)
		  MsgStop(cErr,"JSON PARSE ERROR")
		  return(aRet	:= {.F.,cErr})
		endif
		cFilAnt		:= oDadosPed:GetJSonObject('C5_FILIAL') //Define a Filial
		if nOper == 3 //Inclusão
			cNumPV	:= GetSxeNum("SC5","C5_NUM")//Pega Proximo Numero do SC5
			RollBAckSx8()
		else
			cNumPV := ""
		endif
		aCabec 	:= GeraCabec(cNumPV,oDadosPed)
		aItens	:= GeraItens(oDadosPed)
		lMsErroAuto := .F.
		MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabec,aItens,nOper)
		If lMsErroAuto
			RollBackSX8()
			aErro 	:= GetAutoGrLog()
			cErr	:= aErro[1]
			aRet	:= {.F.,cErr}
			EXIT
		else
			ConfirmSX8()
			aRet	:= {.T., cErr}
		endif
		FreeObj(oDadosPed)
	next
	cFilAnt	:= cFlAntes
return(aRet)

static function GeraCabec(cNumPV,oDadosPed)
	local aArea			:= GetArea()
	local aSC5			:= SC5->(GetArea())
	local aWork 		:= {}
	local cCliente		:= Padr(oDadosPed:GetJSonObject('C5_CLIENTE'),TamSX3("C5_CLIENTE")[1])
	local cLojaCli		:= Padr(oDadosPed:GetJSonObject('C5_LOJACLI'),TamSX3("C5_LOJACLI")[1])
	local cTabPrc		:= Posicione("SA1",1,xFilial("SA1")+cCliente+cLojaCli,"A1_TABELA")
	
	aWork := {	{"C5_NUM"		,cNumPV			,nil},;
				{"C5_TIPO"		,"N"			,nil},;
				{"C5_CLIENTE"	,cCliente		,nil},;
				{"C5_LOJACLI"	,cLojaCli		,nil},;
				{"C5_CLIENT"	,cCliente		,nil},;
				{"C5_LOJAENT"	,cLojaCli		,nil},;
				{"C5_ENTREG"	,dDataBase+10	,nil},;
				{"C5_TRANSP"	,""				,nil},;
				{"C5_TABELA"	,cTabPrc		,nil},;
				{"C5_TIPOCLI"	,"R"			,nil},;
				{"C5_CONDPAG"	,"263"			,nil},;
				{"C5_PEDCLI"	,""				,nil},;
				{"C5_OBS"		,"PEDIDO: " + oDadosPed:GetJSonObject('C5_X_IDVEN') + " POUSO ALEGRE",nil},;
				{"C5_DESCESP"	,0				,nil},;
				{"C5_DESCEQT"	,0				,nil},;
				{"C5_VEND1"		,"010"			,nil},;
				{"C5_EMISSAO"	,dDatabase		,nil},;
				{"C5_COTACAO"	,""				,nil},;
				{"C5_PARC1"		,0				,nil},;
				{"C5_MOEDA"		,1				,nil},;
				{"C5_TPFRETE"	,"C"			,nil},;
				{"C5_LIBEROK"	,"S"			,nil},;
				{"C5_TXMOEDA"	,1				,nil},;
				{"C5_TIPLIB"	,"2"			,nil},;
				{"C5_TPCARGA"	,"2"			,nil},;
				{"C5_USERINC"	,Left(cUserName,Len(SC5->C5_USERINC)),nil},;
				{"C5_DTINC"		,dDatabase		,nil},;
				{"C5_DTFAT"		,dDatabase		,nil},;
				{"C5_CLIOK"		,"S"			,nil},;
				{"C5_X_IDVEN"	,oDadosPed:GetJSonObject('C5_X_IDVEN'),nil},;
				{"C5_GERAWMS"	,"1"			,nil},;
				{"C5_PARCIAL"	, getFldPedOri('SC5', "R_E_C_N_O_ = " + cValToChar(oDadosPed:GetJSonObject('REC_PED_ORI')), "C5_PARCIAL", "PARCIAL")	,nil},;
				{"C5_ZZINSPE"	, getFldPedOri('SC5', "R_E_C_N_O_ = " + cValToChar(oDadosPed:GetJSonObject('REC_PED_ORI')), "C5_ZZINSPE", "ZZINSPE")	,nil}}

	RestArea(aSC5)
	RestArea(aArea)
return(aWork)

static function getFldPedOri(cAls, cWhere, cFld, cNick)
	local aArea		:= GetArea()
	local aAls		:= (cAls)->(GetArea())
	local xFld 		:= ''
	local oSql 		:= LibSqlObj():newLibSqlObj()
	default cNick	:= cFld
	default cWhere	:= ''

	oSql:newTable(cAls, cFld + " " + cNick, cWhere) 
	if oSql:hasRecords()
		xFld := oSql:getValue(cNick)
	endif
	oSql:close()
	FreeObj(oSql)
	RestArea(aAls)
	RestArea(aArea)
return(xFld)

static function GeraItens(oDadosPed)
	local aArea			:= GetArea()
	local aSB2			:= SB2->(GetArea())
	local aSB1			:= SB1->(GetArea())
	local nY			:= 1
	local cItemPv		:= StrZero(1,TamSX3("C6_ITEM")[1])
	local oItensPv		:= oDadosPed:GetJSonObject('ITENS')
	local aItensPv		:= {}
	local nCusto		:= 0
	local nPesCob		:= 0
	local nPerAbate		:= GetNewPar( 'ZZ_CMDIVP', 3 )
	
	dbSelectArea('SB2')
	dbSelectArea('SB1')
	
	for nY := 1 to len(oItensPv) 
		nPesCob 	:= Posicione("SB1",1,xFilial("SB1")+oItensPv[nY]:GetJSonObject('C6_PRODUTO'),"B1_PESCOB")
		if nPesCob > 0
			cOperFis	:= GetNewPar('ZZ_PVTROPE','11') //Com kilo cobre
		else
			cOperFis	:= GetNewPar('ZZ_PVTROP2','09') //Sem kilo cobre
		endif
		//nCusto 	:= Posicione("SB1",1,xFilial("SB1")+oItensPv[nY]:GetJSonObject('C6_PRODUTO'),"B1_CUSTD")
		//nCusto 	:= Max(0.01,nCusto)
		nCusto 		:= Max(0.01, ROUND((oItensPv[nY]:GetJSonObject('C6_PRCVEN') * ( 1 - (nPerAbate / 100))), 4))
		if !SB2->(DbSeek(cFilAnt+oItensPv[nY]:GetJSonObject('C6_PRODUTO')+oItensPv[nY]:GetJSonObject('C6_LOCAL'),.F.))
			CriaSB2(oItensPv[nY]:GetJSonObject('C6_PRODUTO'),oItensPv[nY]:GetJSonObject('C6_LOCAL'))
		endif
		aAdd(aItensPv,{{"C6_NUM"		,"      "									,Nil},;
						{"C6_ITEM"		,cItemPv									,Nil},;
						{"C6_PRODUTO"	,oItensPv[nY]:GetJSonObject('C6_PRODUTO')	,Nil},;
						{"C6_QTDVEN"	,oItensPv[nY]:GetJSonObject('C6_QTDVEN')	,Nil},;
						{"C6_PRCVEN"	,nCusto										,Nil},;
						{"C6_ACONDIC"	,oItensPv[nY]:GetJSonObject('C6_ACONDIC')	,Nil},;
						{"C6_QTDLIB"	,oItensPv[nY]:GetJSonObject('C6_QTDVEN')	,Nil},;
						{"C6_LOCAL"		,oItensPv[nY]:GetJSonObject('C6_LOCAL')		,Nil},;
						{"C6_ENTREG"	,dDataBase + 10 							,Nil},;
						{"C6_TES"		,oItensPv[nY]:GetJSonObject('C6_TES')		,Nil},; 
						{"C6_LANCES"	,oItensPv[nY]:GetJSonObject('C6_LANCES')	,Nil},;
						{"C6_METRAGE"	,oItensPv[nY]:GetJSonObject('C6_METRAGE')	,Nil},;
						{"C6_SEMANA"	,oItensPv[nY]:GetJSonObject('C6_SEMANA')	,Nil},;
						{"C6_NUMPCOM"	,oItensPv[nY]:GetJSonObject('C6_NUMPCOM')	,Nil},;
						{"C6_ITEMPC"	,oItensPv[nY]:GetJSonObject('C6_ITEMPC')	,Nil},;
						{"C6_XOPER"		,cOperFis									,Nil}})	
		cItemPv := soma1(cItemPv)	
	next
	Freeobj(oItensPv)
	RestArea(aSB2)
	RestArea(aSB1)
	RestArea(aArea)
return(aItensPv)

user function xxTstZnPed()
	local aCtrlPV		:= {}
	/*
//"{	"C5_LOJACLI":"01",
		"C5_FILIAL":"02",
		"ITENS":[
			{"C6_SEMANA":"",
			"C6_ACONDIC":"R",
			"C6_LANCES":200,
			"C6_PRODUTO":"1150504401       ",
			"C6_METRAGE":100,
			"C6_LOCAL":"01",
			"C6_QTDVEN":20000},
			{"C6_SEMANA":"TRIANG",
			"C6_ACONDIC":"B",
			"C6_LANCES":1,
			"C6_PRODUTO":"1141504401       ",
			"C6_METRAGE":100,
			"C6_LOCAL":"01",
			"C6_QTDVEN":100}],
		"C5_CLIENTE":"029238",
		"C5_X_IDVEN":"03000003MS"}"
	*/
	//aCtrlPV := {{"C5_LOJACLI":"01","C5_FILIAL":"02","ITENS":[{"C6_SEMANA":"","C6_ACONDIC":"R","C6_LANCES":200,"C6_PRODUTO":"1150504401       ","C6_METRAGE":100,"C6_LOCAL":"01","C6_QTDVEN":20000},{"C6_SEMANA":"TRIANG","C6_ACONDIC":"B","C6_LANCES":1,"C6_PRODUTO":"1141504401       ","C6_METRAGE":100,"C6_LOCAL":"01","C6_QTDVEN":100},{"C6_SEMANA":"","C6_ACONDIC":"R","C6_LANCES":15,"C6_PRODUTO":"1540604401       ","C6_METRAGE":100,"C6_LOCAL":"01","C6_QTDVEN":1500},{"C6_SEMANA":"TRIANG","C6_ACONDIC":"B","C6_LANCES":1,"C6_PRODUTO":"1141804401       ","C6_METRAGE":120,"C6_LOCAL":"01","C6_QTDVEN":120},{"C6_SEMANA":"TRIANG","C6_ACONDIC":"R","C6_LANCES":80,"C6_PRODUTO":"1320304401       ","C6_METRAGE":100,"C6_LOCAL":"01","C6_QTDVEN":8000}],"C5_CLIENTE":"029238","C5_X_IDVEN":"03000003MS"}}
	u_cbcSrvPedFil(aCtrlPV, 3)
return()
