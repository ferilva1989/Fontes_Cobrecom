#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} MyAtfa012
//TODO Importação de planilha formatada com os dados a inlcuir no Ativo FIXO.
@author juliana.leme
@since 16/01/2019
@version 1.0
@type function
/*/
user function CbImpATF()
	local aArea		:= GetArea() 
	local aRet		:= "", cArq := "", cOrigem := ""
	local oSay		:= nil
	private aParam 	:= {}, aDadAtf := {}, aCab := {}
	private aItens 	:= {}, aParamBox := {}
	private lMsErroAuto := .F.
	private lMsHelpAuto := .T.
	
	aadd(aParamBox,{6,"Qual Arquivo","C:\","","","" ,70,.T.,"Arquivo .XLS |*.XLS"})
	if !ParamBox(aParamBox, "Parametros", @aRet)
		return(.F.)
	endif
	cArq 	:= Alltrim(substr(aRet[1],rat("\",aRet[1])+1,len(aRet[1])))
	cOrigem	:= Alltrim(substr(aRet[1],1,rat("\",aRet[1])))
	FWMsgRun(, { |oSay| aDadAtf:= U_CargaXLS(cArq,cOrigem,,.F.)}, "Inclusão dos Ativos", "Aguarde, Carregando Planilha...")
	FWMsgRun(, { |oSay| IncAtivo(oSay) }, "Inclusão dos Ativos", "Aguarde, Incluindo Registros!")	
	ApMsgInfo("Importação Concluida")
	RestArea(aArea)
return ()

static function IncAtivo(oSay)
	private lMsErroAuto 	:= .F.
	private lMsHelpAuto		:= .T.
	private lAutoErrNoFile	:= .T.
	private lIsJobAuto		:= .F.
	default oSay	:= nil
	
	for n1:= 2 to len (aDadAtf)
		oSay:SetText("Inclusão e processamento do registro " + Alltrim(Str(n1)) + " de " + Alltrim(Str(len(aDadAtf))))
		oSay:CtrlRefresh()
		aCab := {}
		aadd(aCab,{"N1_FILIAL" 	, aDadAtf[n1][1] 		,NIL})
		aadd(aCab,{"N1_CBASE" 	, aDadAtf[n1][2] 		,NIL})
		aadd(aCab,{"N1_ITEM" 	, aDadAtf[n1][3] 		,NIL})
		aadd(aCab,{"N1_AQUISIC"	, CtoD(aDadAtf[n1][4]) 	,NIL})
		aadd(aCab,{"N1_DESCRIC"	, aDadAtf[n1][5] 		,NIL})
		aadd(aCab,{"N1_QUANTD"	, val(aDadAtf[n1][6]) 	,NIL})
		aadd(aCab,{"N1_CHAPA"	, aDadAtf[n1][7] 		,NIL})
		aadd(aCab,{"N1_PATRIM"	, aDadAtf[n1][8] 		,NIL})
		aadd(aCab,{"N1_GRUPO"	, aDadAtf[n1][9] 		,NIL})
		
		aItens := {}
		aadd(aItens,{; 
					{"N3_FILIAL"	, aDadAtf[n1][1] 		,NIL},;
					{"N3_CBASE"		, aDadAtf[n1][2] 		,NIL},;
					{"N3_ITEM" 		, aDadAtf[n1][3] 		,NIL},;
					{"N3_TIPO"		, aDadAtf[n1][10] 		,NIL},;
					{"N3_BAIXA" 	, "0" 					,NIL},;
					{"N3_HISTOR"	, aDadAtf[n1][11] 		,NIL},;
					{"N3_CCONTAB"	, aDadAtf[n1][12] 		,NIL},;
					{"N3_CUSTBEM"	, aDadAtf[n1][13] 		,NIL},;
					{"N3_CDEPREC"	, aDadAtf[n1][14] 		,NIL},;
					{"N3_CDESP"		, aDadAtf[n1][15] 		,NIL},;
					{"N3_CCORREC" 	, aDadAtf[n1][16] 		,NIL},;
					{"N3_CCUSTO" 	, aDadAtf[n1][17] 		,NIL},;
					{"N3_DINDEPR" 	, CtoD(aDadAtf[n1][18]) ,NIL},;
					{"N3_VORIG1" 	, val(aDadAtf[n1][19]) 	,NIL},;
					{"N3_TXDEPR1" 	, val(aDadAtf[n1][20]) 	,NIL},;
					{"N3_VORIG2" 	, 0 					,NIL},;
					{"N3_TXDEPR2" 	, 0 					,NIL},;
					{"N3_VORIG3" 	, 0 					,NIL},;
					{"N3_TXDEPR3" 	, 0 					,NIL},;
					{"N3_VORIG4" 	, 0 					,NIL},;
					{"N3_TXDEPR4" 	, 0 					,NIL},;
					{"N3_VORIG5" 	, 0 					,NIL},;
					{"N3_TXDEPR5" 	, 0 					,NIL};
		})
		begin Transaction
			bErro	:= ErrorBlock({|oErr| HandleEr(oErr, @aRet)})
			MSExecAuto({|x,y,z| Atfa012(x,y,z)},aCab,aItens,3,aParam)
			if lMsErroAuto 
				aErro 	:= GetAutoGrLog()
				aRet	:= {.F.,aErro}
				DisarmTransaction()
			else
				aRet	:= {.T.,}
			endif
			ErrorBlock(bErro)	
		end Transaction
	next
return

/*/{Protheus.doc} HandleEr
@author bolognesi
@since 17/10/2016
@version 1.0
@param oErr, object, Objeto retornado pelo sistema, com informações sobre o erro
@param aRet, array,  Parametro por referencia com a variavel que contem a descrição do erro.
@type function
@description Controle de erro personalizado para obter e tratar os erros na rotina startJob()
/*/
Static function HandleEr(oErr, aRet)
	aRet := {.F.,{'[' + oErr:Description + ']',oErr:ERRORSTACK}}
	ConsoleLog('[' + oErr:Description + ']' + oErr:ERRORSTACK)
	if !(_SetAutoMode() .Or. IsBlind())
		errorDlg(oErr, '[IFC-COBRECOM]- Ocorreu um erro, por favor avisar o Departamento de T.I.')
	endif
	break
return