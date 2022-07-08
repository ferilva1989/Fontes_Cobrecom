#include 'protheus.ch'
#include 'parmtype.ch'

#define STR_PULA Chr(13)+Chr(10)

user function vwTransFilial()
	local oPnl	 		:= nil
	local oFont			:= TFont():New("Arial",,30,,.T.)
	local bConfirm 		:= { || FWMsgRun(, {|| procNFe()}, 	"NF de Transferência", "Processando Entrada da NF de Transferência...")}
	local bBlkVld		:= { || validChave()}
	private oModal 		:= nil
	private cChv		:= Space(TamSX3("F2_CHVNFE")[1])
	private oGet		:= nil
	private oTransFil 	:= ctrlTransFilial():newctrlTransFilial(.T.)
	
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
    
    FreeObj(oTransFil)
    FreeObj(oGet)
    FreeObj(oFont)
    FreeObj(oPnl)
    FreeObj(oModal)
return(nil)

static function validChave()
	local lOk := .F.
	
	lOk := (oTransFil:setSourceNFe(cChv):isOk())
	
	if !lOk
		resetScreen()
	endif
return(lOk)

static function resetScreen()
	cChv := Space(TamSX3("F2_CHVNFE")[1])
	oGet:Refresh()
	FreeObj(oTransFil)
	oTransFil 	:= ctrlTransFilial():newctrlTransFilial(.T.)
return(nil)

static function newRound()
	if msgYesNo('Deseja processar outra NF de Transferência?','Continuar Transferências de NF')
		resetScreen()
	else
		oModal:DeActivate()
	endif
return(nil)

static function procNFe()
	if confirmInfo()	
		oTransFil:mountDestNFe()
		if (oTransFil:isOk())
			if (oTransFil:makeNF():isOk())
				msgInfo('Transferência Concluída com Sucesso!', 'Concluída')
			endif
			newRound()
		endif
	else
		newRound()
	endif
return(nil) 

static function confirmInfo()
	local oJson := oTransFil:getNFinfo()
	local cMsg	:= ''
	local lOk	:= .F.
	
	if (lOk := (!empty(oJson:GetNames())))
		cMsg += 'Origem Transfência: '
		cMsg += oJson['FILIAL'] + '-' + oJson['FILIAL_NOME'] + STR_PULA
		cMsg += 'Documento: '
		cMsg += oJson['DOC'] + '-' + oJson['SERIE'] + STR_PULA
		cMsg += 'Tipo: '
		cMsg += oJson['TIPO']+ STR_PULA
		cMsg += 'Emissão: '
		cMsg += DToC(SToD(oJson['EMISSAO']))+ STR_PULA
		cMsg += 'Chave: '
		cMsg += oJson['CHAVE'] + STR_PULA
		lOk := (MsgYesNo( cMsg, 'Confirma Processamento' ))
	endif
	
return(lOk)

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