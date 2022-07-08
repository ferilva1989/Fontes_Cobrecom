#include "totvs.ch"
#include "rwmake.ch"
#include "fwmvcdef.ch"

#define MVC_MAIN_ID       "cbcCadSch"
#define MVC_MODEL_ID      "mCadSch"
#define MVC_VIEW_ID       "vCadSch"
#define MVC_TITLE         "Controle de Envio de Emails"
#define MVC_MODEL_STRUCT  1
#define MVC_VIEW_STRUCT   2


user function cbcCadSch()
	local oBrowse  		:= FwMbrowse():new()
	local oAcl			:= cbcAcl():newcbcAcl()
	private bSendEmail	:= {|| sendEmail() }
	private bClearEmail	:= {|| U_clrRegSc() }

	if !oAcl:aclValid('cbcCadSch')
		alert( oAcl:getAlert() )
	else
		oBrowse:setAlias("ZPH") 
		oBrowse:setDescription(MVC_TITLE)
		oBrowse:addLegend("ZPH_STATUS == 'E' ", "RED"	, "Erro no envio")
		oBrowse:addLegend("ZPH_STATUS == 'O' ", "GREEN"	, "Enviada por E-mail")
		oBrowse:addLegend("ZPH_STATUS == 'A' ", "YELLOW", "Aguardando envio")
		oBrowse:addLegend("ZPH_STATUS == 'P' ", "ORANGE", "Em processamento")
		oBrowse:activate()
	endif
	FreeObj(oAcl)
return

/**
* Opções do browse
*/
static function menuDef()
	local aOpcoes 	  := {}
	local cViewId 	  := "viewDef."+MVC_MAIN_ID
	local cSendEmail  := "Eval(bSendEmail)"
	local cClearEmail := "Eval(bClearEmail)"
	ADD OPTION aOpcoes TITLE 'Alterar'    		ACTION cViewId 		OPERATION 4 ACCESS 0
	ADD OPTION aOpcoes TITLE "Pesquisar"   		ACTION "PesqBrw" 	OPERATION 1 ACCESS 0
	ADD OPTION aOpcoes TITLE "Visualizar"  		ACTION cViewId   	OPERATION 2 ACCESS 0
	ADD OPTION aOpcoes TITLE "Imprimir"   		ACTION cViewId   	OPERATION 8 ACCESS 0
	ADD OPTION aOpcoes TITLE "Enviar E-mail"  	ACTION cSendEmail   OPERATION 2 ACCESS 0
	ADD OPTION aOpcoes TITLE "Limpar"  			ACTION cClearEmail  OPERATION 2 ACCESS 0
return aOpcoes

/**
* Modelagem
*/
static function modelDef()
	local bValidModel 	:= {|oModel| validModel(oModel)}    
	local oModel 		:= MpFormModel():new(MVC_MODEL_ID, nil, bValidModel)
	local oZPH   		:= FwFormStruct(MVC_MODEL_STRUCT, "ZPH")   
	oModel:setDescription(MVC_TITLE)
	oModel:addFields("ZPH", nil, oZPH)
	oModel:getModel("ZPH"):setDescription(MVC_TITLE)     
	oModel:setPrimaryKey({"ZPH_FILIAL","ZPH_IDENV"})
return oModel

/**
* Validação do Model
*/
static function validModel(oActiveModel)
	local lOk 	:= .T.
	local nOper := oActiveModel:getOperation()    
return lOk

/**
* Interface Visual
*/
static function viewDef()
	local oView  := FwFormView():new()
	local oModel := FwLoadModel(MVC_MAIN_ID)
	local oZPH   := FwFormStruct(MVC_VIEW_STRUCT, "ZPH")
	oView:setModel(oModel)
	oView:addField("ZPH", oZPH, "ZPH")    
	oView:AddUserButton('VER EMAIL', 'CLIPS', {|oView| verEmail(oView)})
return oView

static function verEmail(oView)
	local oModel 	:= FWModelActive()
	local oModelAt 	:= oModel:GetModel('ZPH')
	local cHtml		:= ""
	local cMdl		:= ""
	local cBody		:= ""
	cHtml 	:= oModelAt:GetValue('ZPH_HTML')
	cMdl 	:= oModelAt:GetValue('ZPH_MODEL')
	cBody 	:= U_IniSchCm('CBODY', cMdl)
	mostraMsg(cHtml,cBody)
return(nil)


Static function mostraMsg(cHtml,cBody)
	local oFont 	:= TFont():New('Courier new',,-10,.F.)
	local oSay		:= Nil
	local oPanel	:= Nil
	local lHtml 	:= .T.
	local oScroll 	:= Nil
	local aButtons 	:= {}
	local cMostrar	:= ""
	Static oDlg		:= Nil

	if empty(cHtml)
		cMostrar := cBody
	else
		cMostrar := cHtml
	endif

	DEFINE DIALOG oDlg TITLE "Conteudo email" FROM 180,180 TO 650,960 PIXEL

	oScroll := TScrollArea():New(oDlg,01,01,100,100)
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT
	@ 000,000 MSPANEL oPanel OF oScroll SIZE 500,3000 COLOR CLR_HRED
	oScroll:SetFrame(oPanel)
	oSay:= TSay():New(01,01,{||},oPanel,,oFont,,,,.T.,,,500,3000,,,,,,lHtml)
	oSay:SetText(cMostrar)
	EnchoiceBar(oDlg, {||oDlg:End()}, {||oDlg:End()},,aButtons)

	ACTIVATE DIALOG oDlg CENTERED

return(nil)


/**
* Enviar manualmente os emails pendentes ( Status A/E )
*/
static function sendEmail()	
	local cMsg 	    := ""
	local lOk		:= .F.
	local lProcBar  := .T. 
	local oSch 		:= cbcSchCtrl():newcbcSchCtrl()
	local bErro	:= nil

	if !MsgBox("Confirma envio das mensagens pendentes por e-mail ?", "Atenção", "YESNO")
		return
	endIf

	bErro	:= ErrorBlock({|oErr| HandleEr(oErr)})
	BEGIN SEQUENCE
		Processa({|| lOk := oSch:getFromId():lOk }, "Aguarde", "Processando ...")
	RECOVER
	END SEQUENCE
	ErrorBlock(bErro)

	if lOk
		MsgBox("Processado", "Concluído", "INFO")
	else
		MsgBox( oSch:cMsg, "Atenção", "ALERT")
	endIf

return

/**
* Limpa os registros antigos, 
usado pelo schedule (limpa conforme parametro) 
sendo excluidos os registros que ( (Hoje - Dt.Envio) >= parametro ) E ZPH_FIXO == N e ZPH_STATUS = O (OK)
*/
user function clrScReg() //U_clrScReg()
	RPCClearEnv()
	RPCSetType(3)
	RPCSetEnv('01','01',,,'FAT',GetEnvServer(),{} )
	ConsoleLog('Iniciando limpeza da tabela ZPH')
	oSch := cbcSchCtrl():newcbcSchCtrl()
	oSch:clearReg( .T. )
	FreeObj(oSch)
	ConsoleLog('Finalizando limpeza da tabela ZPH')
	RPCClearEnv()
return(nil)

/**
* Limpa os registros antigos, 
Rotina de manu manual (limpa conforme parametro) 
sendo excluidos os registros que ( (Hoje - Dt.Envio) >= parametro ) E ZPH_FIXO == N e ZPH_STATUS = O (OK)
exibir range e perguntar se considera ZPH_FIXO 
*/
user function clrRegSc() //U_clrRegSc() 
	local oSch 			:= nil
	local aParamBox 	:= {}
	local aRet 			:= {}
	local cWrn			:= ""
	local lShure		:= .T.

	oSch := cbcSchCtrl():newcbcSchCtrl()
	aAdd(aParamBox,{1,"Data De:"  		,Ctod(Space(8)),"","","","",50,.T.})
	aAdd(aParamBox,{1,"Data Até:"  		,Ctod(Space(8)),"","","","",50,.T.})
	aAdd(aParamBox,{3,"Excluir Fixos"	,1, {"Sim", "Nao"}, 50,'.T.',.T.})  

	if ParamBox(aParamBox,"Limpar Registros",@aRet)

		cWrn += 'Deseja excluir os registro conforme filtro? - DataDe:' + DToC(aRet[1]) + ' DataAte: ' + DToC(aRet[2]) + chr(13) 
		if aRet[3] == 1
			cWrn += 'Alem do filtro de data, ira excluir tambem os registros definidos como fixos'
		endif

		if MsgNoYes( cWrn )
			if FwIsAdmin()
				lShure :=	MsgNoYes( 'CERTEZA QUE  ' + cWrn )
			endif
			if lShure
				oSch:clearReg( .F., aRet )
			endif
		endif
	endif 
	FreeObj(oSch)
return( nil )

static function ConsoleLog(cMsg)
	ConOut("[Schedule-Limpeza ZPH - "+DtoC(Date())+" - "+Time()+" ] "+cMsg)
return


static function HandleEr(oErr)
	MsgAlert("[cbcCadSch - " + DtoC(Date()) + " - "+Time()+" ] " + oErr:Description ,'ERRO')
	BREAK
return (nil)
