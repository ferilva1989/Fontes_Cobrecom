#include 'protheus.ch'
#include 'parmtype.ch'

#define STR_PULA Chr(13)+Chr(10)

user function cbcWMSNFe(bProcess, cTable)
	local oPnl	 		:= nil
	local oFont			:= TFont():New("Arial",,30,,.T.)
	local bBlkVld		:= nil
	local bConfirm 		:= nil
	private oModal 		:= nil
	private cChv		:= Space(TamSX3("F2_CHVNFE")[1])
	private oGet		:= nil
	default cTable		:= "SF1"
	default bProcess 	:= { || FWMsgRun(, {|| procNFe()}, "Integra NFe de Entrada WMS", "Integrando NF no WMS...")}

	bBlkVld	:= { || validChave(cTable)}
	bConfirm := { || FWMsgRun(, {|| processBlc(bProcess)}, 	"Processar NFe", "Processando...")}
	
	oModal := FWDialogModal():New() 
	oModal:setSize(100,300)
	oModal:SetEscClose(.T.)
	oModal:setTitle('Informe a Chave da Nota Fiscal')
	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
	oModal:addOkButton(bConfirm, "Confirma", {||.T.} )
	oPnl := TPanel():New( ,,, oModal:getPanelMain() ) 
	oPnl:SetCss("")
	oPnl:Align := CONTROL_ALIGN_ALLCLIENT
    
    oGet := TGet():New(05,05, { | u | If( PCount() == 0, cChv,cChv:= u ) },oPnl,290,030,"@!", bBlkVld,0,,oFont,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cChv,,,, )
    
    setMsgCss(@oModal:oSayTitle)
   	setMsgCss(@oModal:oTop)
    
    oModal:Activate()
    
    FreeObj(oGet)
    FreeObj(oFont)
    FreeObj(oPnl)
    FreeObj(oModal)
return(nil)

static function validChave(cTable)
	local lOk       := .F.
	local oSql 		:= LibSqlObj():newLibSqlObj()

	if cTable == "SF2"
		oSql:newTable("SF2", "R_E_C_N_O_ REC", "F2_CHVNFE = '" + cChv + "'")
	else
    	oSql:newTable("SF1", "R_E_C_N_O_ REC", "F1_CHVNFE = '" + cChv + "'")
	endif

	if !(lOk := oSql:hasRecords())
        MsgAlert('Nota Fical não localizada!', 'No NF')
		resetScreen()
	endif

    FreeObj(oSql)
return(lOk)

static function resetScreen()
	cChv := Space(TamSX3("F2_CHVNFE")[1])
	oGet:Refresh()
return(nil)

static function newRound()
	if msgYesNo('Deseja integrar outra NF de Entrada?','Continuar')
		resetScreen()
	else
		oModal:DeActivate()
	endif
return(nil)

static function processBlc(bProcess)
	eVal(bProcess)
	newRound()
return(nil)

static function procNFe()
    local oInt      := cbcExpIntegra():newcbcExpIntegra()
	if msgYesNo('Confirma Integração da NF?','Confirma')
        if !(oInt:fromNFe(cChv):isOk())
            Alert('Erro ao inserir NF: ' + oInt:getErrMsg())
        endif
	endif
    FreeObj(oInt)
return(nil) 

static function setMsgCss(oObj, cOpc)
	local cCss 		:= ''
	local cTpObj 	:= GetClassName(oObj)
	default cOpc	:= ''
	
	if cTpObj == "TSAY"
		cCss +=	"QLabel { ";
					+"  font-size: 23px; /*Tamanho da fonte*/";
					+"  color: #006d93; /*Cor da fonte*/";
					+"  font-weight: bold; /*Negrito*/";
					+"  text-align: center; /*Alinhamento*/";
					+"  vertical-align: middle; /*Alinhamento*/";
					+"  border-radius: 6px; /*Arrerondamento da borda*/";
					+"}"
	endif	
	if !empty(cCss)
		oObj:SetCSS(cCss)
	endif
return(oObj)
