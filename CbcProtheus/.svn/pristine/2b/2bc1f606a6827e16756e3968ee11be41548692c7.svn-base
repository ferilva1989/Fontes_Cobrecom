#include "totvs.ch"
#include "rwmake.ch"
#include "portalcobrecom.ch" 

#define TOP_MARGIN			1
#define LEFT_MARGIN			30
#define RIGHT_MARGIN		2650
#define BOTTOM_MARGIN		3310

#define MAX_ITEMS_LINES		170

#define ITEM_COLUMN			(LEFT_MARGIN + 40)
#define CODPROD_COLUMN		(ITEM_COLUMN + 130)
#define DESCRIPTION_COLUMN	(CODPROD_COLUMN + 200)

#define QTDVEN_COLUMN		(DESCRIPTION_COLUMN + 1100)
#define PRC_COLUMN			(QTDVEN_COLUMN + 200)
#define LANCE_COLUMN		(PRC_COLUMN + 200)
#define METRAGE_COLUMN		(LANCE_COLUMN + 200)
#define TOTAL_COLUMN		(METRAGE_COLUMN + 200)

#define LEFT_ALIGN			0  
#define RIGHT_ALIGN			1  
#define CENTER_ALIGN		2

#define FATURAMENTO			1
#define ENTREGA				2
#define COBRANCA			3


/*/{Protheus.doc} CbcQuotationReport

Objeto responsável pela Impressão dos Orçamentos Cobrecom

@author victorhugo
@since 03/08/2016
/*/
class CbcQuotationReport from LibPdfObj

	data oQuotation
	data oParamBox
	data lItemsValues
	data lFullDescription
	data nLine
	data nPage
	data nTotalPages
	data aItems

	method newCbcQuotationReport() constructor

	method getQuotation()
	method setQuotation()
	method isItemsValues()
	method setItemsValues()
	method isFullDescription()
	method setFullDescription()

	method getParams()
	method run()

endClass


/*/{Protheus.doc} newCbcQuotationReport

Construtor

@author victorhugo
@since 03/08/2016

@param oQuotation, CbcQuotation, Orçamento Cobrecom
@param cFolder, String, Diretório para Geração do PDF
@param lShow, Logico, Indica se deve exibir o PDF após a Geração
/*/
method newCbcQuotationReport(oQuotation, cFolder, lShow) class CbcQuotationReport

	local cFileName := DtoS(dDataBase)+StrTran(Time(), ":", "")+"_orcamento_"+oQuotation:getId()
	default cFolder := "\portal_cobrecom\reports\"
	default lShow   := .F.

	::setQuotation(oQuotation)
	::setItemsValues( .T. )
	::setFullDescription( .F. )
	::newLibPdfObj(cFileName, cFolder, lShow)

	::setMargin(0, 0, 0, 0)

	::nLine  	  	:= 0
	::nPage  	  	:= 0
	::nTotalPages 	:= 0
	::aItems 	  	:= {}
	
	::nSleep			:= 1500

return self


/**
* Getters/Setters
*/
method getQuotation() class CbcQuotationReport
return ::oQuotation

method setQuotation(oQuotation) class CbcQuotationReport
	::oQuotation := oQuotation
return

method isItemsValues() class CbcQuotationReport
return ::lItemsValues

method setItemsValues(lItemsValues) class CbcQuotationReport
	::lItemsValues := lItemsValues
return

method isFullDescription() class CbcQuotationReport
return ::lFullDescription

method setFullDescription(lFullDescription) class CbcQuotationReport
	::lFullDescription := lFullDescription
return

method getParams() class CbcQuotationReport
	local cQuotationId	:= ""
	local oParam 		:= nil
	local oQuotation	:= ::getQuotation()
	local oUtils		:= LibUtilsObj():newLibUtilsObj()

	::oParamBox := LibParamBoxObj():newLibParamBoxObj("CbcQuotationReport")

	oParam := LibParamObj():newLibParamObj("itemsValues", "checkbox", "Exibir valores dos itens")    
	::oParamBox:addParam(oParam)

	oParam := LibParamObj():newLibParamObj("fullDescription", "checkbox", "Exibir descrição completa")    
	::oParamBox:addParam(oParam)

	if oUtils:isNotNull(oQuotation)
		cQuotationId := oQuotation:getId()
	endIf
return ::setup("PDF do Orçamento "+cQuotationId, ::oParamBox)



/*/{Protheus.doc} run

Execução Relatório

@author victorhugo
@since 03/08/2016

@return String Arquivo PDF gerado
/*/
method run() class CbcQuotationReport

	local cPdf	  			:= ""
	local oFont		 		:= TFont():new("Arial", 12, 12, nil, .T., nil, nil, nil, nil, .T.)
	local oUtils  			:= LibUtilsObj():newLibUtilsObj()
	local oQuotation		:= ::getQuotation()
	local oSrvCustomer		:= CbcCustomerService():newCbcCustomerService()
	private oCustomer		:= oSrvCustomer:findByCode(oQuotation:getCodeCustomer(), oQuotation:getUnitCustomer(), .F. )		

	if oUtils:isNotNull(::oParamBox)
		::setItemsValues(::oParamBox:getValue("itemsValues"))
		::setFullDescription(::oParamBox:getValue("fullDescription"))
	endIf

	readItems(@self)
	setTotalPages(@self)	
	printHeader(@self)
	printData(@self)
	printItems(@self)
	printConditions(@self)

	if ::create()
		cPdf := ::getPdfFile()	
	endIf

	/*
	::startPage()
	::say(10, 10, "Impressão do Orçamento "+oQuotation:getId(), oFont)
	::endPage()
	*/
return cPdf

/**
* Carrega os Itens do Orçamento, considerando o tamanho das descrições
*/
static function readItems(oRpt)

	local nI			:= 0		
	local aDescription	:= {}
	local oQuotation 	:= oRpt:getQuotation()
	local aItems	 	:= oQuotation:getItems()

	oRpt:aItems := {}

	for nI := 1 to Len(aItems)

		oItem 		 := aItems[nI]
		aDescription := getItemDescription(oRpt, oItem)

		aAdd(oRpt:aItems, {oItem, aDescription})

	next nI

return


/**
* Retorna um array com a Descrição de um Item
*/
static function getItemDescription(oRpt, oItem)

	local nMaxCol		:= 65	
	local cDescription	:= oItem:getDescription()
	local oUtils 		:= LibUtilsObj():newLibUtilsObj()	
	local oSrvProd		:= CbcProductService():newCbcProductService()

	if oRpt:isFullDescription()
		oProduct	 := oSrvProd:findByCode(oItem:getCode())
		cDescription := oProduct:getFullDescription()
		if !oRpt:isItemsValues()
			nMaxCol := 120
		endIf	
	endIf		

return oUtils:strToArray(cDescription, nMaxCol)


/**
* Define o Total de Páginas do Relatório
*/
static function setTotalPages(oRpt)

	local nI	 		:= 0	
	local nDescLines	:= 0
	local nItemsPages	:= 1
	local aDescription	:= {}
	local aItems 		:= oRpt:aItems

	for nI := 1 to Len(aItems)		
		aDescription := aItems[nI,2]
		nDescLines	 += (Len(aDescription) + 2)
		if (nDescLines > MAX_ITEMS_LINES)
			nDescLines := 0
			nItemsPages++
		endIf		
	next nI

	oRpt:nTotalPages := (nItemsPages + 1)

return


/**
* Imprime o Cabeçalho das Páginas
*/
static function printHeader(oRpt)

	local nBreak	 	:= 30
	local nBmpWidth	 	:= 360
	local nBmpHeight 	:= 60
	local nCol  	 	:= ((RIGHT_MARGIN / 2) - (nBmpWidth / 2))		
	local cBitmap  	 	:= "\web\ws\images\COBRECOM.bmp"
	local cMarca  	 	:= "\web\ws\images\marca.png"
	local oFont	 	 	:= TFont():new("arial", 9.5, 9.5, , .T., , , , , .F.)
	local oSmallFont 	:= TFont():new("arial", 8, 8, , .F., , , , , .F. )
	local oAlertFont 	:= TFont():new("arial", 8, 8, , .F., , , , , .F.  )
	local oQuotation  	:= oRpt:getQuotation()
	local cCodCustomer	:= oQuotation:getCodeCustomer() 
	local cUnitCustomer	:= oQuotation:getUnitCustomer()
	local oSql			:= LibSqlObj():newLibSqlObj()
	local cCodSeller	:= ""
	local lConfirm		:= .F.
	local cDocCli		:= ""
	
	oRpt:nPage++

	oRpt:nLine := TOP_MARGIN

	oRpt:startPage()
	
	//Marca d agua
	oRpt:bitmap( 1 ,1 , cMarca, 3000, 3410 )
	
	if showInvalidMessage(oRpt)
		oRpt:say(oRpt:nLine, (LEFT_MARGIN + 15), "Esse Orçamento não possui valor legal.", oAlertFont, nil, CLR_HRED)
		oRpt:say((oRpt:nLine + 25), (LEFT_MARGIN + 15), "Deve ser usado somente para fins de consulta.", oAlertFont, nil, CLR_HRED)
	endIf	
	
	//Obter as informações do vendedor
	oSql:newTable("SA1", "A1_VEND SELLER", "%SA1.XFILIAL% AND (A1_COD + A1_LOJA) = '"+ (cCodCustomer + cUnitCustomer) +"'")
	cCodSeller := oSql:getValue("SELLER")
	oSql:newTable("SA3", "A3_NOME NAME, A3_CGC CNPJ, A3_EMAIL EMAIL, A3_DDDTEL DDD, A3_TEL PHONE", "%SA3.XFILIAL% AND A3_COD = '"+ cCodSeller +"'")

	//oRpt:bitmap(oRpt:nLine, nCol, cBitmap, nBmpWidth, nBmpHeight)	
	//lConfirm := (oQuotation:getStatus() $ QUOTATION_STATUS_CONFIRMED)
	
	//Titulo do documento
	oRpt:say(oRpt:nLine, (nCol), "ORÇAMENTO " /*+ if(lConfirm,' - (APROVADO)', '')*/, oFont)
		
	//Numeração da pagina		
	oRpt:say(oRpt:nLine, (RIGHT_MARGIN - 130), "Página " + AllTrim(Str(oRpt:nPage)) + "/" + AllTrim(Str(oRpt:nTotalPages)), oSmallFont)

	//Nome do representante
	oRpt:nLine += (nBmpHeight + 10)
	oRpt:say(oRpt:nLine, (nCol - 80), oSql:getValue("AllTrim(Capital(NAME))") , oFont)
		
	//Documentos do representante
	oRpt:nLine += nBreak
	cDocCli := oSql:getValue("AllTrim(CNPJ)")
	if len(cDocCli) > 12
		 cDocCli 	:= AllTrim(Transform(cDocCli, "@R 99.999.999/9999-99"))
	else
		cDocCli 	:= AllTrim(Transform(cDocCli, "@R 999.999.999-99"))
	endif
	oRpt:say(oRpt:nLine, (nCol - 80), "CNPJ/CPF: " + cDocCli , oFont)

	//Telefone do representante
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, (nCol - 80), 'FONE: ' + oSql:getValue("if (Empty(DDD), PHONE, AllTrim(DDD) + ' ' + PHONE)"),oFont)	

	//Email do representante
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, (nCol - 80), oSql:getValue("EMAIL"), oFont)
	
	oSql:close()
return

/**
* Indica se deve exibir a mensagem de Orçamento inválido
*/
static function showInvalidMessage(oRpt)


	local lShow			:= .F.
	local oQuotation 	:= oRpt:getQuotation()
	local oSql		 	:= LibSqlObj():newLibSqlObj()
	local cLastRevision := oSql:getFieldValue("ZP5", "ZP5_REVATU", "%ZP5.XFILIAL% AND ZP5_NUM = '"+oQuotation:getId()+"'")

	if (oQuotation:getLastRevision() != cLastRevision) .or. ;
	!(oQuotation:getStatus() $ QUOTATION_STATUS_WAITING_CONFIRM + "," + QUOTATION_STATUS_CONFIRMED)
		lShow := .T.
	endIf

return ( .T. ) //lShow

/**
* Imprime os Dados (Cabeçalho do Orçamento e Colunas dos Itens)
*/
static function printData(oRpt)

	local lCpf				:= .F.
	local cCnpj				:= ""
	local cPhone			:= ""
	//local cPartialBilling	:= "Aceita parcial"
	//local cListPrice		:= "Preço"
	local nBreak	 		:= 40
	local nCol1		 		:= (LEFT_MARGIN + 10)
	local nCol2		 		:= 900
	local nCol3		 		:= 1920
	local oQuotation 		:= oRpt:getQuotation()
	local oFont	 	 		:= TFont():new("arial", 10, 10, , .F., , , , , .F.)
	local oFontBold	 		:= TFont():new("arial", 10, 10, , .T., , , , , .F.)
	local oSql				:= LibSqlObj():newLibSqlObj()	
	local cFrete			:= oQuotation:getFreight()

	if Empty(oCustomer:getDdd())
		cPhone := oCustomer:getPhone()
	else 
		cPhone := AllTrim(oCustomer:getDdd()) + " " + oCustomer:getPhone()
	endIf	

	if cFrete == 'C'
		cFrete := 'CIF'
	elseif cFrete == 'F'
		cFrete := 'FOB'
	else
		cFrete := ""
	endif
	
	/*
	if (oCustomer:getPartialBilling() == "S")
	cPartialBilling := "Sim"
	elseIf (oCustomer:getPartialBilling() == "N")
	cPartialBilling := "Não"
	else
	cPartialBilling := "Não definido"
	endIf
	*/

	cCnpj := AllTrim(oCustomer:getCnpj())

	if !Empty(cCnpj) .and. (Len(cCnpj) < 14)
		lCpf := .T.
	endIf
	/*
	cListPrice := oSql:getFieldValue("DA0", "DA0_DESCRI", "%DA0.XFILIAL% AND DA0_CODTAB = '"+oQuotation:getCodeListPrice()+"'")
	cListPrice := AllTrim(Capital(cListPrice))
	*/
	oRpt:nLine += nBreak

	oRpt:line(oRpt:nLine, LEFT_MARGIN, oRpt:nLine, RIGHT_MARGIN)

	oRpt:nLine += nBreak

	oRpt:say(oRpt:nLine, nCol1, "Orçamento:", oFontBold)
	oRpt:say(oRpt:nLine, (nCol1 + 170), oQuotation:getId(), oFont)	
	oRpt:say(oRpt:nLine, nCol2, "Cliente:", oFontBold)
	oRpt:say(oRpt:nLine, (nCol2 + 115), oCustomer:getName(), oFont)
	
	oRpt:say(oRpt:nLine, nCol3, "Frete:   ", oFontBold)
	oRpt:say(oRpt:nLine, (nCol3 + 127), cFrete, oFont)

	oRpt:nLine += nBreak

	oRpt:say(oRpt:nLine, nCol1, "Revisão:", oFontBold)
	oRpt:say(oRpt:nLine, (nCol1 + 130), oQuotation:getLastRevision(), oFont)	
	
	oRpt:say(oRpt:nLine, nCol2, "Telefone:", oFontBold)
	oRpt:say(oRpt:nLine, (nCol2 + 135), cPhone, oFont)
	
	//oRpt:say(oRpt:nLine, nCol3, "Aceita Faturamento Parcial:", oFontBold)
	//oRpt:say(oRpt:nLine, (nCol3 + 390), cPartialBilling, oFont)

	oRpt:nLine += nBreak

	oRpt:say(oRpt:nLine, nCol1, "Data de Emissão:", oFontBold)
	oRpt:say(oRpt:nLine, (nCol1 + 250), DtoC(oQuotation:getDate()), oFont)

	if lCpf
		oRpt:say(oRpt:nLine, nCol2, "CPF:", oFontBold)
		oRpt:say(oRpt:nLine, (nCol2 + 75), AllTrim(Transform(cCnpj, "@R 999.999.999-99")), oFont)
	else
		oRpt:say(oRpt:nLine, nCol2, "CNPJ:", oFontBold)
		oRpt:say(oRpt:nLine, (nCol2 + 95), AllTrim(Transform(cCnpj, "@R 99.999.999/9999-99")), oFont)
	endIf	

	oRpt:nLine += nBreak

	//oRpt:say(oRpt:nLine, nCol1, "Modalidade:", oFontBold)
	//oRpt:say(oRpt:nLine, (nCol1 + 175), cListPrice, oFont)
	oRpt:say(oRpt:nLine, nCol2, "E-mail:", oFontBold)
	oRpt:say(oRpt:nLine, (nCol2 + 105), oCustomer:getEmail(), oFont)
return

/**
* Imprime os Itens
*/
static function printItems(oRpt)
	local nI		  	:= 0
	local nY		  	:= 0
	local nCountLines 	:= 0
	local nBreak	  	:= 30
	local cCode		  	:= ""		
	local oItem	      	:= nil
	local oProdFont	  	:= nil
	local oFont	 	  	:= TFont():new("arial", 9, 9, , .F., , , , , .F.)
	local oSmallFont  	:= TFont():new("arial", 7, 7, , .F., , , , , .F.)	
	local oSql		  	:= LibSqlObj():newLibSqlObj()
	local oQuotSrv 	  	:= Nil 
	local aColors 	  	:= {} 
	local oColor	  	:= Nil
	local cCodCust	  	:= ""
	local cUnitCust	  	:= ""
	local nMetrage	  	:= 0
	local nLance		:= 0
	local cAcond	  	:= ""
	local nTotal		:= 0
	local nQtdVen		:= 0
	local nPreco		:= 0
	local oQuotation	:= oRpt:getQuotation()

	printBoxItems(@oRpt)

	oRpt:nLine 	  += 50
	oQuotSrv 	  := CbcQuotationService():newCbcQuotationService()
	cCodCust	  := oCustomer:getCode()
	cUnitCust	  := oCustomer:getUnit()

	for nI := 1 to Len(oRpt:aItems)
		oItem 	  	 	:= oRpt:aItems[nI,1]
		aDescription 	:= oRpt:aItems[nI,2]
		cAcond			:= oItem:getIdPackage() 
		aColors 	 	:= oItem:getColors()

		for nY := 1 To Len(aColors)
			oColor 		:= aColors[nY]
			cCode   	:= oQuotSrv:getProductCode( cCodCust, cUnitCust, oItem, oColor:getColorId(), oQuotation:getId() )
			nMetrage	:= (oColor:getTotal() / oColor:getQuantity() )
			nLance		:= oColor:getQuantity()
			nQtdVen		:= oColor:getTotal() 
			nPreco		:= iif(Empty( oItem:getAppPrice()),oItem:getSugPrice(),oItem:getAppPrice() )
			
			nTotal		:= ( nQtdVen * nPreco ) 
			oProdFont 	:= if (Len(cCode) > 10, oSmallFont, oFont)		

			oRpt:say(oRpt:nLine, ITEM_COLUMN, oItem:getItem(), oFont)
			oRpt:say(oRpt:nLine, CODPROD_COLUMN, AllTrim(Transform(cCode, PesqPict("ZP9", "ZP9_CODPRO"))), oFont)
			
			if (oRpt:isItemsValues())
				oRpt:say(oRpt:nLine, QTDVEN_COLUMN, AllTrim(Transform(nQtdVen, PesqPict("ZP9", "ZP9_QUANT"))), oFont)
				oRpt:say(oRpt:nLine, PRC_COLUMN, AllTrim(Transform(nPreco, PesqPict("ZP6", "ZP6_PRCAPR"))), oFont)
				oRpt:say(oRpt:nLine, LANCE_COLUMN, AllTrim(Transform(nLance, PesqPict("ZP6", "ZP6_QTACON"))), oFont)
				oRpt:say(oRpt:nLine, METRAGE_COLUMN, AllTrim(Transform(nMetrage, PesqPict("ZP6", "ZP6_QTACON"))), oFont)
				oRpt:say(oRpt:nLine, TOTAL_COLUMN, AllTrim(Transform(nTotal, PesqPict("ZP6", "ZP6_PRCAPR"))), oFont)
				
			endIf
			printDescription(@oRpt, aDescription, oFont, nBreak, @nCountLines, oColor)
			oRpt:nLine += nBreak
			nCountLines += 2
		next nY
	next nI

	printTotalValue(@oRpt)
	oRpt:endPage()
return

/**
* Imprime o box com as colunas dos itens
*/
static function printBoxItems(oRpt)

	local nDescCol  := (DESCRIPTION_COLUMN + 350)
	local oFontBold	:= TFont():new("arial", 10, 10, , .T., , , , , .F.)

	if oRpt:isFullDescription() .and. !oRpt:isItemsValues()
		nDescCol += 300
	endIf

	oRpt:nLine += 40

	oRpt:box(oRpt:nLine, LEFT_MARGIN, (oRpt:nLine + 60), RIGHT_MARGIN)

	oRpt:nLine += 40

	oRpt:say(oRpt:nLine, (ITEM_COLUMN - 10), "Item", oFontBold)
	oRpt:say(oRpt:nLine, (CODPROD_COLUMN - 20), "CodProd.", oFontBold)
	oRpt:say(oRpt:nLine, nDescCol, "Descrição", oFontBold)
	
	if (oRpt:isItemsValues())
		oRpt:say(oRpt:nLine, (QTDVEN_COLUMN - 15), "Qtd.", oFontBold)
		oRpt:say(oRpt:nLine, (PRC_COLUMN - 15), "Prc.Unit.", oFontBold)
		oRpt:say(oRpt:nLine, (LANCE_COLUMN - 15), "Lance", oFontBold)
		oRpt:say(oRpt:nLine, (METRAGE_COLUMN - 15), "Metragem", oFontBold)
		oRpt:say(oRpt:nLine, (TOTAL_COLUMN - 15), "Total", oFontBold)
	endIf

return


/**
* Imprime a Descrição dos Itens
*/
static function printDescription(oRpt, aDescription, oFont, nBreak, nCountLines, oColor)

	local nI 			:= 0	
	local oFontBold		:= TFont():new("arial", 9, 9, , .T., , , , , .F.)
	local cColorName	:= ""

	for nI := 1 to Len(aDescription)

		if (nI > 1)
			oRpt:nLine += nBreak
		endIf

		nCountLines++
		
		if !Empty( aDescription[nI] )
			if nI == 1
				cColorName := ' - ' + oColor:GetColorName()
			endif
			oRpt:say(oRpt:nLine, DESCRIPTION_COLUMN, Alltrim(aDescription[nI]) + Alltrim(cColorName) , oFont)
		endif
		
		if (nCountLines > MAX_ITEMS_LINES)			
			oRpt:nLine += (nBreak * 2)
			oRpt:say(oRpt:nLine, DESCRIPTION_COLUMN, "Continua ...", oFontBold)
			nCountLines := 0
			printTotalValue(@oRpt)
			oRpt:endPage()
			printHeader(@oRpt)
			printData(@oRpt)
			printBoxItems(@oRpt)
			oRpt:nLine += 25	
		endIf

	next nI

	if oRpt:isFullDescription()
		oRpt:nLine += nBreak
	endIf

return

/**
* Imprime o Valor do Orçamento por Extenso
*/
static function printTotalValue(oRpt)

	local nI		  := 0
	local nTotalValue := 0
	local nBoxLine    := (oRpt:nLine + 60)
	local cStrTotal	  := ""
	local oQuotation  := oRpt:getQuotation()
	local oFontBold	  := TFont():new("arial", 9, 9, , .T., , , , , .F.)
	local aItems	  := oQuotation:getItems()
	local cCurrency   := "R$"	

	for nI := 1 to Len(aItems)
		nTotalValue += iif(Empty(aItems[nI]:getAppTotal()),aItems[nI]:getSugTotal(),aItems[nI]:getAppTotal() )
	next nI

	oRpt:box(nBoxLine, LEFT_MARGIN, (nBoxLine + 60), RIGHT_MARGIN)

	nBoxLine += 40

	cStrTotal := "Valor do Orçamento: " + cCurrency + " "
	cStrTotal += AllTrim(Transform(nTotalValue, PesqPict("ZP6", "ZP6_PRCAPR")))
	cStrTotal += " - ( " + Upper(Extenso(nTotalValue)) + " )" 

	oRpt:say(nBoxLine, (ITEM_COLUMN - 10), cStrTotal, oFontBold)

return

/**
* Imprime as Condições Comerciais
*/
static function printConditions(oRpt)

	local nI				:= 0
	local nSignLeft	  		:= 0
	local nSignRight  		:= 0
	local nStampLine  		:= 0
	local nStampLeft  		:= 0
	local nStampWidth 		:= 0
	local nStampHeight		:= 0 
	local nBreak	  		:= 32
	local nTopicBreak 		:= 50
	local nCol		  		:= (LEFT_MARGIN + 15)	
	local oFont	  	  		:= TFont():new("arial", 10, 10, , .F., , , , , .F.)
	local oFontBold	  		:= TFont():new("arial", 10, 10, , .T., , , , , .F.)
	local oBigFont    		:= TFont():new("arial", 14, 14, , .F., , , , , .F.)
	local oSql				:= LibSqlObj():newLibSqlObj()
	local oQuotation  		:= oRpt:getQuotation()
	local dValidDate		:= oQuotation:getValidDate()
	local cPartialBilling	:= ""/*oCustomer:getPartialBilling()*/
	local aComments			:= getComments(oQuotation)
	local aAddres			:= {}

	printHeader(@oRpt)

	oRpt:nLine += 40

	oRpt:box(oRpt:nLine, LEFT_MARGIN, (oRpt:nLine + 60), RIGHT_MARGIN)

	oRpt:nLine += 40

	oRpt:say(oRpt:nLine, 940, "INFORMAÇÕES GERAIS DA PROPOSTA COMERCIAL", oFontBold)

	oRpt:nLine += 80

	oRpt:say(oRpt:nLine, nCol, "CONDIÇÕES DA PROPOSTA:", oFontBold)

	oRpt:nLine += 50

	//Validade do Orçamento
	if empty(dValidDate)
		oRpt:say(oRpt:nLine, nCol,"- Este orçamento tem validade de 3(TRÊS) dias a partir da data de emissão.", oFontBold)	
	else
		oRpt:say(oRpt:nLine, nCol, "- Validade da Proposta: " + pdfVldDate(oQuotation) + ". Após esta data está sujeito a alterações.", oFontBold)	
	endif
	
	//Crédito
	oRpt:nLine += nTopicBreak
	oRpt:say(oRpt:nLine, nCol, "- Crédito:", oFontBold)
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, "* Liberação de crédito sujeita a aprovação do Setor Financeiro", oFont)

	//Impostos
	oRpt:nLine += nTopicBreak
	oRpt:say(oRpt:nLine, nCol, "- Impostos:", oFontBold)
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, "* Substituição Tributária, DIFA e DIFAL á incluir.", oFont)
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, "* Diferença de ICMS já considerado.", oFont)
	
	//Entrega Prazo
	oRpt:nLine += nTopicBreak	
	oRpt:say(oRpt:nLine, nCol, "- Prazo de Entrega:  mediante disponibilidade de estoque.", oFontBold)
	
	//Entrega Sobre
	oRpt:nLine += nTopicBreak	
	oRpt:say(oRpt:nLine, nCol, "- Entrega:", oFontBold)
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, "* O frete CIF é considerado como transporte normal, não envolvendo a contratação de maquinas e equipamentos especiais.", oFont)
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, "* Sendo que se for necessário, tais serviços deverão ser contratados diretamente pelo comprador ou deverá ser negociado tal procedimento", oFont)
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, " antes do cadastro do pedido para o mesmo ser analisado pelo Comercial.", oFont)
	
	//Acondicionamento
	oRpt:nLine += nTopicBreak	
	oRpt:say(oRpt:nLine, nCol, "- Acondicionamento:", oFontBold)
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, "* Os cabos são fornecidos em rolos de 100mts ou bobinas com lance a critério do cliente mediante prévia autorização.", oFont)
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, "* Nos cabos de bitolas acimo do 70.00mm² e nos multiplos acima do 25,00mm², poderá haver uma tolerancia de +/- 3% na metragem solicitada", oFont)
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, " conforme o que prescrevem as Normas Técnicas Brasileiras (ABNT) aplicavéis.", oFont)
	
	//Condições comerciais
	oRpt:nLine += nTopicBreak	
	oRpt:say(oRpt:nLine, nCol, "- Condições Comerciais:", oFontBold)	
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, "* Cond. Pagamento: " + AllTrim(oQuotation:getDescPayment()) + ".", oFont)
	oRpt:nLine += nBreak
	//oRpt:say(oRpt:nLine, nCol, "* À Vista Antecipado Desconto de 1%", oFont)
	//oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, "* BNDES - Pedido Mínimo: R$ 10.000,00 acrescentar taxa financeira no valor da venda ", oFont)
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, "* Pedido mínimo – Revenda R$ 20.000,00 + ST / Construtora R$ 50.000,00", oFont)
	
	/*
	if !Empty(cPartialBilling)
		oRpt:nLine += nTopicBreak	
		oRpt:say(oRpt:nLine, nCol, "- Aceita Pedido Parcial: " + if (cPartialBilling == "S", "Sim.", "Não."), oFont)
	endIf
	*/
	//Endereços
	aAddres := getAddres(oQuotation)
	oRpt:nLine += nTopicBreak
	oRpt:say(oRpt:nLine, nCol, "- Endereços: ", oFontBold)
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, "- Faturamento: ", oFontBold)
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, aAddres[FATURAMENTO]	, oFont)
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, "- Entrega: ", oFontBold)
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, aAddres[ENTREGA]		, oFont)
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, "- Cobrança: ", oFontBold)
	oRpt:nLine += nBreak
	oRpt:say(oRpt:nLine, nCol, aAddres[COBRANCA]	, oFont)
	
	oRpt:nLine += nTopicBreak
	if (Len(aComments) > 0)

		oRpt:nLine += 60

		oRpt:say(oRpt:nLine, nCol, "OBSERVAÇÕES:", oFontBold)

		oRpt:nLine += 60

		for nI := 1 to Len(aComments)

			if (nI > 1)
				oRpt:nLine += 40
			endIf

			oRpt:say(oRpt:nLine, (nCol + 50), aComments[nI], oFont)

		next nI

	endIf	

	oRpt:nLine += nTopicBreak	

	oRpt:nLine += 40
	/*
	oRpt:say(oRpt:nLine, nCol, "A presente documentação é de propriedade da IFC Industria e comercio de condutores eletricos LTDA., tem caráter confidencial e, portanto, não poderá ser objeto de reprodução total ou parcial, bem", oFontBold)
	oRpt:nLine += nBreak 
	oRpt:say(oRpt:nLine, nCol, "como não poderá ser objeto de empréstimo, locação ou qualquer outra forma de cessão de uso sem a permissão prévia e por escrito da COBRECOM. A violação da confidencialidade", oFontBold)
	oRpt:nLine += nBreak 
	oRpt:say(oRpt:nLine, nCol, "aqui ajustada ensejará a aplicação das sanções penais e cíveis cabíveis.", oFontBold)

	oRpt:nLine += nTopicBreak	

	oRpt:nLine += 40

	oRpt:say(oRpt:nLine, nCol, "Estamos à sua inteira disposição para qualquer informação que se faça necessária.", oFont)
	*/
	
	oRpt:nLine += 70
	
	//oSql:newTable("SA3", "A3_NOME NAME, A3_EMAIL EMAIL, A3_DDDTEL DDD, A3_TEL PHONE", "%SA3.XFILIAL% AND A3_COD = '"+oSeller:getId()+"'")

	//oRpt:say(oRpt:nLine, (nCol + 10), "Vendedor: ", oFontBold)
	//oRpt:say(oRpt:nLine, (nCol + 165), "Nome"/*oSql:getValue("AllTrim(Capital(NAME))")*/, oFont)	
	//oRpt:nLine += 40	
	//oRpt:say(oRpt:nLine, (nCol + 10), "Telefone: ", oFontBold)
	//oRpt:say(oRpt:nLine, (nCol + 150), "Fone"/*oSql:getValue("if (Empty(DDD), PHONE, AllTrim(DDD) + ' ' + PHONE)")*/, oFont)
	//oRpt:nLine += 40	
	//oRpt:say(oRpt:nLine, (nCol + 10), "E-mail: ", oFontBold)
	//oRpt:say(oRpt:nLine, (nCol + 125), "End"/*oSql:getValue("EMAIL")*/, oFont)

	//oSql:close()

	//oRpt:nLine += 60

	//oRpt:say(oRpt:nLine, 1100, "IFC Industria e Comercio de Condutores eletricos Ltda.", oFontBold)

	oRpt:nLine += 15

	oRpt:line(oRpt:nLine, LEFT_MARGIN, oRpt:nLine, RIGHT_MARGIN)

	oRpt:nLine += 75

	nCol += 50

	nSignLeft  := (nCol + 250)
	nSignRight := (nSignLeft + 750)
	nBreak	   := 70

	nStampLine  := (oRpt:nLine - 30)
	nStampLeft  := (nSignRight + 250)
	nStampWidth := 1250
	nStampHeight:= 350

	oRpt:box(nStampLine, nStampLeft, (nStampLine + nStampHeight), (nStampLeft + nStampWidth))
	oRpt:say((nStampLine + (nStampHeight / 2) + 15), (nStampLeft + 400), "CARIMBO DA EMPRESA", oBigFont)

	oRpt:say(oRpt:nLine, nCol, "Declaro que li todas as condições acima e estou de acordo com as mesmas.", oFont)

	oRpt:nLine += 90

	oRpt:say(oRpt:nLine, nCol, "Nome Completo:", oFontBold)
	oRpt:line(oRpt:nLine, nSignLeft, oRpt:nLine, nSignRight)

	oRpt:nLine += nBreak

	oRpt:say(oRpt:nLine, nCol, "Cargo:", oFontBold)
	oRpt:line(oRpt:nLine, nSignLeft, oRpt:nLine, nSignRight)

	oRpt:nLine += nBreak

	oRpt:say(oRpt:nLine, nCol, "Assinatura:", oFontBold)
	oRpt:line(oRpt:nLine, nSignLeft, oRpt:nLine, nSignRight)

	oRpt:nLine += nBreak

	oRpt:say(oRpt:nLine, nCol, "Data:", oFontBold)
	oRpt:line(oRpt:nLine, nSignLeft, oRpt:nLine, nSignRight)

	oRpt:endPage()

return

/**
* Retorna a Data de Entrega do Orçamento
*/
static function getDeliveryDate(oQuotation)

	local nI 			:= 0
	local cRet			:= ""
	local dDeliveryDate := CtoD("")
	local aItems		:= oQuotation:getItems()

	for nI := 1 to Len(aItems)

		if Empty(aItems[nI]:getDeliveryDate())
			loop
		endIf

		if Empty(dDeliveryDate) .or. (aItems[nI]:getDeliveryDate() > dDeliveryDate) 
			dDeliveryDate := aItems[nI]:getDeliveryDate()
		endIf

	next nI

	if !Empty(dDeliveryDate)
		cRet := DtoC(dDeliveryDate)
	endIf

return cRet

/**
* Retorna um array com as Observações, considerando as quebras de linhas e o tamanho máximo de caracteres por linhas
*/
static function getComments(oQuotation)

	local nI		:= 0
	local nY		:= 0
	local nMaxChrs	:= 180
	local nMaxLines := 40
	local aRet		:= {}
	local aLines	:= {}
	local aComments := StrTokArr(oQuotation:getComments(), CRLF)
	local oUtils	:= LibUtilsObj():newLibUtilsObj()		

	if Empty(oQuotation:getComments())
		return {}
	endIf

	for nI := 1 to Len(aComments)		

		aLines := oUtils:strToArray(aComments[nI], nMaxChrs)

		for nY := 1 to Len(aLines)
			if (Len(aRet) <= nMaxLines)
				aAdd(aRet, aLines[nY])
			endIf	
		next nY		

	next nI	

return aRet

Static function getAddres(oQuotation)
local aAddres 	:= Array(3)
local cEndEnt 	:= ""
local cEndFat	:= ""
local cEndCob	:= ""
local cRetEnt	:= "-"
local cRetFat	:= "-"
local cRetCob	:= "-"
local cCodCli	:= oCustomer:getCode() 
local cLojaCli	:= oCustomer:getUnit()
local oSql 		:= SqlUtil():newSqlUtil()
local oRet		:= nil

oSql:addFromTab('SA1')
oSql:addCampos({'A1_END','A1_BAIRRO', 'A1_CEP', 'A1_MUN', 'A1_EST', 'A1_ENDCOB', 'A1_BAIRROC','A1_CEPC','A1_MUNC', 'A1_ESTC'})
oSql:addWhere("A1_FILIAL = '" + xFilial('SA1')  + "'")
oSql:addWhere("A1_COD = '" 	+ cCodCli  + "'")
oSql:addWhere("A1_LOJA = '" + cLojaCli  + "'")

//TODO iniciar aqui
if oSql:QrySelect():lOk		
	oRet := oSql:oRes[1] 
	
	cEndFat += Alltrim(oRet:A1_END) 	+ ' '
	cEndFat += Alltrim(oRet:A1_BAIRRO) 	+ ' ' 
	cEndFat += Alltrim(oRet:A1_CEP) 	+ ' '
	cEndFat += Alltrim(oRet:A1_MUN) 	+ '/'
	cEndFat += Alltrim(oRet:A1_EST)
	
	cEndCob += Alltrim(oRet:A1_ENDCOB)	+ ' '
	cEndCob += Alltrim(oRet:A1_BAIRROC)	+ ' '
	cEndCob += Alltrim(oRet:A1_CEPC)	+ ' '
	cEndCob += Alltrim(oRet:A1_MUNC) 	+ '/'
	cEndCob += Alltrim(oRet:A1_ESTC)
	
	cEndEnt += Alltrim(oQuotation:getDelAddress()) +;
	 		' ' + Alltrim(oQuotation:getDelCity()) +;
	 		'/' +  Alltrim(oQuotation:getDelState()) 
endif

//Faturamento
if !empty( Alltrim(StrTran(cEndFat,'/','')) )
	cRetFat	+= cEndFat 
	
	//Cobrança
	if !empty( Alltrim(StrTran(cEndCob,'/','')) )
		 cRetCob += cEndCob 
	else
		cRetCob += cEndFat 
	endif
	
	//Entrega
	if !empty( Alltrim(StrTran(cEndEnt,'/','')) )
		 cRetEnt += cEndEnt 
	else
		cRetEnt += cEndFat 
	endif
endif

aAddres[FATURAMENTO] 	:= Upper(Alltrim(cRetFat)) 	
aAddres[ENTREGA] 		:= Upper(Alltrim(cRetEnt))
aAddres[COBRANCA] 		:= Upper(Alltrim(cRetCob))

freeObj(oSql)

return (aAddres)

static function pdfVldDate(oQuotation)
	local dAproDate			:= Date()
	local oSql 		 		:= LibSqlObj():newLibSqlObj()
	local nDiaPar	 		:= GetNewPar("ZZ_VLORCPT", 7)
	local dValidDate 		:= oQuotation:getValidDate()
	local cQuotationId 		:= oQuotation:getId()
	local cPDFDate			:= DtoC(Date())

	if !empty(dValidDate)
		oSql:newTable("ZP5", "ZP5_CLIENT, ZP5_LOJA", "%ZP5.XFILIAL% AND ZP5_NUM = '"+cQuotationId+"'")		
		if (oSql:getValue("ZP5_CLIENT") == DEFAULT_CUSTOMER_CODE .and. oSql:getValue("ZP5_LOJA") == DEFAULT_CUSTOMER_UNIT)
			nDiaPar	 := GetNewPar("ZZ_VLPADPT", 7)
		endIf
		oSql:close()

		dAproDate := u_cbcDataDiff(dValidDate, nDiaPar, .F.)
		cPDFDate  := DtoC(dAproDate)
	endif
	FreeObj(oSql)
return(cPDFDate)

/*ZONE TEST*/
User function zcbcPdf(cQuotationId,cUserId,cRevision) //U_zcbcPdf('023866')
	local oService	 		:= CbcQuotationService():newCbcQuotationService()	
	local oUtils	 		:= LibUtilsObj():newLibUtilsObj()
	local cPdf		 		:= ""
	local oQuotation		:= nil	
	local oReport	 		:= nil
	local cFolder			:= "\web\ws\reports\quotation\"

	default cQuotationId 	:= "000001" 
	default cUserId			:= "000001"
	default cRevision		:= "01"

	oQuotation := oService:getById(cQuotationId, cUserId)
	if oUtils:isNotNull(oQuotation)
		oReport	:= CbcQuotationReport():newCbcQuotationReport(oQuotation,cFolder)
		cPdf    := oReport:run()
		oReport:clear()
	EndIF
return(nil)
