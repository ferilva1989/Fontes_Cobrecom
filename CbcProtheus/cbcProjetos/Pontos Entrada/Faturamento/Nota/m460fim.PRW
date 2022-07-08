#include 'totvs.ch'
#Include "Protheus.ch"
#Include "TopConn.ch"
#include "portalcobrecom.ch"

/*
ROBERT SANTOS
09 DE AGOSTO DE 2012
ENVIAR EMAIL APOS GERAR NOTA FISCAL DE SAIDA
P.E.
*/
User Function M460FIM
Local aemail 		:= {}
Local AAUX 			:= {}
Local aarea 		:= getarea()
Local i, j
Local aareaA3 // By Roberto Oliveira 17/02/14                                                        
Local aareaC5 // By Roberto Oliveira 17/02/14
Local aareaC6 // By Roberto Oliveira 17/02/14
Local aareaD2 // By Roberto Oliveira 17/02/14
Local aareaA1 // By Roberto Oliveira 22/09/16
Local aAreaAtu 		:= GetArea()
Local aAreaSD2 		:= SD2->(GetArea())
Local aAreaSF4 		:= SF4->(GetArea())
Local fConfirma
local bErro			:= Nil
local lEnvMail 		:= GetNewPar( 'ZZ_ZFATMAI', .T.)
Private cLocalDesp  := "SP"
Private cNumDB      := Space(40)
Private oDlg1, oGrp1, oGet1, oGrp2, oGet2, oBtn1

	/*
		[PORTAL][CHAMADA] - Manutenção do relacionamento entre os documentos do portal e os documentos do sistema
		manter a partir de um documento no portal sua rastreabilidade interna no sistema(Chamada com tratamento de
		erro)
	*/
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr)})
	BEGIN SEQUENCE
		if ExistBlock("_CbcService")
			checkQuotationDocument()
		endIf	                           
    RECOVER
	END SEQUENCE
	ErrorBlock(bErro)    
	/*
		[PORTAL][FIM]
	*/

	If SF2->F2_SERIE == "1  " // By Roberto Oliveira 17/02/14
		DbSelectArea("SA1")  // By Roberto Oliveira 22/09/16
		aareaA1 := getarea() // By Roberto Oliveira 22/09/16
		SA1->(dbsetorder(1))

		DbSelectArea("SA3")  // By Roberto Oliveira 17/02/14
		aareaA3 := getarea() // By Roberto Oliveira 17/02/14
		SA3->(dbsetorder(1))
	
		DbSelectArea("SC5")  // By Roberto Oliveira 17/02/14
		aareaC5 := getarea() // By Roberto Oliveira 17/02/14
		SC5->(dbsetorder(1))
	
		DbSelectArea("SC6")  // By Roberto Oliveira 17/02/14
		aareaC6 := getarea() // By Roberto Oliveira 17/02/14
		SC6->(dbsetorder(1)) // C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
	
		DbSelectArea("SD2")  // By Roberto Oliveira 17/02/14
		aareaD2 := getarea() // By Roberto Oliveira 17/02/14
		SD2->(dbsetorder(3)) // D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM
	
		if SD2->(dbseek(SF2->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))
			if SC5->(dbseek(SF2->F2_FILIAL + SD2->D2_PEDIDO))   
				if( !empty(SC5->C5_VEND1) ) // validar preenchimento de representante
					_cModMail := "V" // Venda
					SA3->( dbseek(xfilial("SA3") + SC5->C5_VEND1) )
					while SD2->(D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA) == SF2->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA) .and. !SD2->(EOF())
						// Inicio By Roberto Oliveira 22/09/16 - Adicionar ao email o nro do pedido do cliente
						// quando for transferência para 3 Lagoas
						_cPedOri := " "
						_cCliOri := " "
						
						If SD2->D2_FILIAL == "01" .And. SD2->D2_CLIENTE == "008918"
							SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV,.F.))
							If !Empty(SC6->C6_ZZPVORI)
								_cPedOri := SC6->C6_ZZPVORI
								SC6->(DbSeek("02"+_cPedOri,.F.))
								SA1->(DbSeek(xFilial("SA1") + SC6->C6_CLI + SC6->C6_LOJA,.F.))
								_cCliOri := SA1->A1_NOME
								restarea(aareaA1) // By Roberto Oliveira 22/09/16
								_cModMail := "T" // Transferência
							EndIf
							restarea(aareaC6) // By Roberto Oliveira 22/09/16
						EndIf
						// Fim By Roberto Oliveira 22/09/16 - Adicionar ao email o nro do pedido do cliente

						aadd(aemail, { ;
						SD2->D2_ITEM,;
						trim(SD2->D2_COD),;
						trim(SD2->D2_DESCRI),;
						SD2->D2_QUANT,;
						SD2->D2_PRCVEN,;
						SD2->D2_TOTAL,;
						SD2->D2_EMISSAO,;
						SD2->D2_PEDIDO,;
						_cPedOri,;
						_cCliOri;
						})
						SD2->( dbskip() )
					enddo
					if lEnvMail
						u_cwf12(aemail,_cModMail)// enviar e-mail
					endif
				endif
			endif
		endif
		restarea(aareaA1) // By Roberto Oliveira 22/09/16
		restarea(aareaA3) // By Roberto Oliveira 17/02/14
		restarea(aareaC5) // By Roberto Oliveira 17/02/14
		restarea(aareaC6) // By Roberto Oliveira 17/02/14
		restarea(aareaD2) // By Roberto Oliveira 17/02/14
	
		restarea(aarea)
	EndIf 
	RestArea(aAreaSD2)
	RestArea(aAreaSF4)
	RestArea(aAreaAtu)
		
	/*
	* Funcao		:	M460FIM
	* Autor			:	João Zabotto
	* Data			: 	12/07/2013
	* Descricao		:	Ponto de entrada responsável por gravar os dados para NF De exportação.
	* Retorno		: 	Nil
	*/
	
	If Upper(Alltrim(SF2->F2_EST)) == "EX"
		oDlg1      := MSDialog():New( 197,483,326,1063,"Dados para Exportação:",,,.F.,,,,,,.T.,,,.T. )
		oGrp1      := TGroup():New( 008,012,032,084,"Local do Despacho:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
		oGet1      := TGet():New( 016,017,{|u| If(PCount()>0,cLocalDesp:=u,cLocalDesp)},oGrp1,060,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"12","cLocalDesp",,)
		oGrp2      := TGroup():New( 008,092,032,280,"Num do DrawBack:",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
		oGet2      := TGet():New( 016,097,{|u| If(PCount()>0,cNumDB:=u,cNumDB)},oGrp2,176,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cNumDB",,)
		oBtn1      := TButton():New( 036,240,"Confirma",oDlg1,{|x| fNFExport()},037,012,,,,.T.,,"",,,,.F. )
		oDlg1:Activate(,,,.T.)
		//fNFExport()		&& Exportacao
	Endif
		
Return Nil

/*
* Funcao		:	fNFExport
* Autor			:	João Zabotto
* Data			: 	12/07/2013
* Descricao		:	Ponto de entrada responsável por gravar os dados para NF De exportação.
* Retorno		: 	Nil
*/
Static Function fNFExport()
	Local aAreaSD2 := SD2->(GetArea())
    && Tratativa para NF Importação:
	If Upper(Alltrim(SF2->F2_EST)) == "EX"
		SD2->(dbSetOrder(3))		&& D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM
		If SD2->(dbSeek( xFilial("SD2") + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ))
			Do While SD2->(!Eof()) .and. SD2->D2_DOC == SF2->F2_DOC .and. SD2->D2_SERIE == SF2->F2_SERIE .and. SD2->D2_CLIENTE == SF2->F2_CLIENTE .and. SD2->D2_LOJA == SF2->F2_LOJA
			
				If RecLock("CDL",.T.)
					CDL_FILIAL	:= xFilial("CDL")		&& C	Filial do Sistema
					CDL_DOC		:= SF2->F2_DOC			&& C	Numero NF
					CDL_SERIE	:= SF2->F2_SERIE		&& C	Serie NF
					CDL_ESPEC	:= SF2->F2_ESPECI1		&& C	Especie do documento
					CDL_CLIENT	:= SF2->F2_CLIENTE		&& C	Cliente do documento
					CDL_LOJA	:= SF2->F2_LOJA 		&& C	Loja do Cliente
					CDL_UFEMB	:= SM0->M0_ESTENT	    && C	UF de Embarque
					CDL_LOCEMB	:= SM0->M0_CIDENT		&& C	Local de Embarque
					CDL_INDDOC	:= "1"					&& C	Tipo de documento - 0=Declaracao de Exportacao; 1=Declaracao simplificada de exportacao
					CDL_NUMDE	:= Alltrim(SD2->D2_ITEM)+Alltrim(SD2->D2_COD)	&& C	Numero da declaracao
					CDL_ITEMNF	:= Alltrim(SD2->D2_ITEM)&& C	Item do Produto na NF				        
					CDL_PRODNF	:= Alltrim(SD2->D2_COD)	&& C	Codigo do Produto na NF
					CDL_DTDE	:= Ctod("")				&& D	Data da declaracao
					CDL_NATEXP	:= "0"				 	&& C	Natureza da Exportacao - 0=Exportacao Direta; 1=Exportacao Indireta
					CDL_NRREG	:= ""					&& C	Numero Registro de Exp
					CDL_DTREG	:= Ctod("")				&& D	Data Registro Exp
					CDL_CHCEMB	:= ""					&& C	Conhecimento Embarque
					CDL_DTCHC	:= Ctod("")				&& D	Data do Conhecimento
					CDL_DTAVB	:= Ctod("")				&& D	Data da Averbacao
					CDL_TPCHC	:= ""					&& C	Tp Conhecimento SISCOMEX
					CDL_PAIS	:= ""					&& C	Cod Pais SISCOMEX
					CDL_NRMEMO	:= ""					&& C	Numero do memorando
					CDL_LOCDES	:= cLocalDesp			&& C	Local do Despacho 
					CDL_ACDRAW  := cNumDB				&& C	Numero do DrawBack       
			
					&& Número do documento fiscal de entrada das mercadorias, no caso de exportação indireta:
					CDL_DOCORI	:= ""					&& C	Documento Original
					CDL_SERORI	:= ""					&& C	SÚrie do Doc. Original
					CDL_FORNEC	:= ""					&& C	Codigo do Fornecedor
					CDL_LOJFOR	:= ""					&& C	Loja do Fornecedor
			
					&& Número da nota fiscal de exportação. Esse campo somente necessita ser informado para complementos de remessas com fim
					&& expecífico de exportação e deve conter a espécie da nota fiscal de exportação emitida pela empresa que efetivou o processo de exportação.
					CDL_NFEXP	:= ""					&& C	NF Exportacao
					CDL_SEREXP	:= ""					&& C	Serie NF Exportacao
					CDL_EMIEXP	:= Ctod("")			&& D	Emissao NF Exportacao
					CDL_ESPEXP	:= ""					&& C	Especie NF Exportacao
					CDL_CHVEXP	:= ""					&& C	Chave NF-e Exportacao
			
					CDL_QTDEXP	:= SD2->D2_QUANT		&& N	Qtde. Exportada
					CDL->(MsUnlock())
				EndIf 
				SD2->(dbSkip())
			Enddo
		Endif
	Endif
	RestArea(aAreaSD2)                                                       
	oDlg1:End()
Return Nil

/*
	[PORTAL][INICIO] - Manutenção do relacionamento entre os documentos do portal e os documentos do sistema
	manter a partir de um documento no portal sua rastreabilidade interna no sistema
*/
static function checkQuotationDocument()	
	local nI			:= 0
	local aQuotations	:= {}
	local cQuery  		:= ""
	local cBranchId 	:= SF2->F2_FILIAL
	local cDocumentId	:= SF2->F2_DOC
	local cSeries		:= SF2->F2_SERIE
	local oSql    		:= LibSqlObj():newLibSqlObj()
	local oService  	:= CbcQuotationService():newCbcQuotationService()
	local oDocument 	:= CbcQuotationDocument():newCbcQuotationDocument()
	                       
	cQuery := " SELECT DISTINCT C5_DOCPORT QUOTATION_ID "
	cQuery += " FROM %SD2.SQLNAME% "
	cQuery += " 	INNER JOIN %SC5.SQLNAME% ON "
	cQuery += " 		C5_FILIAL = D2_FILIAL AND C5_NUM = D2_PEDIDO AND C5_DOCPORT != ' ' AND %SC5.NOTDEL% "
	cQuery += " WHERE D2_FILIAL = '"+cBranchId+"' AND D2_DOC = '"+cDocumentId+"' AND D2_SERIE = '"+cSeries+"' AND %SD2.NOTDEL% "
	cQuery += " ORDER BY 1 "	
	oSql:newAlias(cQuery)
	
	while oSql:notIsEof()
		aAdd(aQuotations, oSql:getValue("QUOTATION_ID"))
		oSql:skip()
	endDo
	oSql:close()
	if Empty(aQuotations)
		return
	endIf
	oDocument:setBranchId(cBranchId)
	oDocument:setType(QUOTATION_DOC_INVOICE)
	oDocument:setId(cDocumentId)
	oDocument:setSeries(cSeries)
	oDocument:setComments(getInvoiceComments(cBranchId, cDocumentId, cSeries))
	for nI := 1 to Len(aQuotations)		
		oService:addDocument(aQuotations[nI], oDocument)	
	next nI
return

/*
 Monta os Comentários referente a uma NF do Orçamento
*/
static function getInvoiceComments(cBranchId, cDocumentId, cSeries)
	local nI			:= 0
	local aSalesOrders	:= {}
	local cQuery 		:= ""
	local cComments		:= ""
	local oSql	 		:= LibSqlObj():newLibSqlObj()
	
	cQuery := " SELECT DISTINCT D2_PEDIDO SALES_ORDER_ID "
	cQuery += " FROM %SD2.SQLNAME% "
	cQuery += " WHERE D2_FILIAL = '"+cBranchId+"' AND D2_DOC = '"+cDocumentId+"' AND "
	cQuery += "       D2_SERIE = '"+cSeries+"' AND D2_PEDIDO != ' ' AND %SD2.NOTDEL% "
	
	oSql:newAlias(cQuery)
	while oSql:notIsEof()
		aAdd(aSalesOrders, oSql:getValue("SALES_ORDER_ID"))
		oSql:skip()
	endDo
	oSql:close()
	
	cComments := "Nota Fiscal referente "
	
	if (Len(aSalesOrders) > 1)
		cComments += " aos Pedidos "
		for nI := 1 to Len(aSalesOrders)
			if (nI > 1)
				cComments += ", "
			endIf
			cComments += aSalesOrders[nI]			
		next nI
	else
		cComments += " ao Pedido " + aSalesOrders[1]
	endIf
return cComments                                                   
/*
	[PORTAL][FINAL] - Manutenção do relacionamento entre os documentos do portal e os documentos do sistema
	manter a partir de um documento no portal sua rastreabilidade interna no sistema
*/

/*/{Protheus.doc} HandleEr
@author bolognesi
@since 30/01/2017
@version undefined
@param oErr, object, Objeto contendo o erro
@type function
/*/
Static function HandleEr(oErr)
	local cMsg := ""
	cMsg := '[' + oErr:Description + ']-' + '-[' +  oErr:ERRORSTACK + ']'
	ConOut("[Faturamento-Portal - " + DtoC(Date()) + " - " + Time() + " ] " + cMsg)
	BREAK
return          
