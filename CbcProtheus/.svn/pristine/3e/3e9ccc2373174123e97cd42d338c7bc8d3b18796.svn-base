#include 'protheus.ch'

#define NOME			'COND_PAGTO'
#define STRING_PADRAO 	'[ * ] - PADRÃO'

#define BKP_DIR			'BKP'

static lVLD_LIGADA		:= GetNewPar('ZZ_ONVLDPG', .T.)
static aGRP_NAO_VLD		:= StrToKArr(GetNewPar('ZZ_GRVLDPG', ''),';')
static lAtivoCond		:= GetNewPar('ZZ_DIVPASU', .T.)

/*/{Protheus.doc} cbcCondPagto
@author bolognesi
@since 20/09/2017
@version 1.0
@type class
@description Classe para realizar os tratamento (Cadastro/Consultas) das amarrações de Médias de condição de pagamento
e clientes.
22/11/17-[LEO] Adicionado variavel statica lAtivoCond Que define se a regra de dividir condição de pagamento por serie(1/U)
esta ativa, Sendo ativa, busca conteudo nos campos ( A1_CONDPSU(SerieU) e A1_CONDI(Serie1) ) tendo conteudo nos dois deve-se 
obrigatoriamente utilizar como condição de pagamento a definida no campo A1_COND.
/*/
class cbcCondPagto 
	data oCrud
	data aItmJson
	data oDadosCondPagto

	method newcbcCondPagto() constructor

	method newCrud()
	method save() 
	method showDialog()
	method getPaymentTerms()
	method vldCliPayTerms()
endclass


method newcbcCondPagto(lOnlyView) class cbcCondPagto
	default lOnlyView := .T.
	::newCrud(lOnlyView)
return(self)


/*/{Protheus.doc} newCrud
@author bolognesi
@since 20/09/2017
@version 1.0
@param lOnlyView, logical, Inicializa o crud do JSON
@type method
/*/
method newCrud(lOnlyView) class cbcCondPagto
	default lOnlyView := .T.
	::oCrud := jsonCrud():newjsonCrud(NOME, lOnlyView )
	if !::oCrud:itsOk()
		Alert( ::oCrud:getMsgLog() )
	else
		::aItmJson :=  ::oCrud:getJson('AREGISTROS')
		jsonToObj(Self)
	endif
return(self)


/*/{Protheus.doc} save
@author bolognesi
@since 20/09/2017
@version 1.0
@type method
@description Salva o objeto JSON em disco
/*/
method save() class cbcCondPagto
	local cStrJson	:= ''
	remNome(self)
	cStrJson := FWJsonSerialize(::oDadosCondPagto, .F., .T. )

	// Realiza o BackUp somente quando hoouve alteração
	if !empty(::oCrud:oJson:AREGISTROS)
		if ::oCrud:oJson:AREGISTROS[1] <> cStrJson
			bkOld(self)
		endif
	else
		bkOld(self)
	endif

	if empty(::oCrud:oJson:AREGISTROS)
		aadd(::oCrud:oJson:AREGISTROS, cStrJson) 
	else
		::oCrud:oJson:AREGISTROS[1] := cStrJson
	endif
	::oCrud:saveJson()
return(self)


/*/{Protheus.doc} getPaymentTerms
@author bolognesi
@since 20/09/2017
@version 1.0
@param cCodCli, characters, Codigo do cliente
@param cLojaCli, characters, Loja do cliente
@param lOnlyPortal, logical, Filtra as condições de pagamento portal
@type function
@description Obter de acordo com as regras quais condições de pagamento o cliente pode utilizar..
22/11/17-[LEO] busca conteudo nos campos ( A1_CONDPSU(SerieU) e A1_CONDI(Serie1) ) tendo conteudo nos dois deve-se 
obrigatoriamente utilizar como condição de pagamento a definida no campo A1_COND e nenhuma outra mais.
/*/
method getPaymentTerms(cCodCli, cLojaCli, lOnlyPortal) class cbcCondPagto
	local aCond			:= {}
	local nPos			:= 0
	local cChave		:= ''
	local nMedia		:= 0
	local oWsObj		:= nil
	local oSql			:= LibSqlObj():newLibSqlObj()
	local cQuery		:= ''
	local cCliCond		:= ''
	local cCliSUCond	:= ''
	local nDefaultMedia	:= 0
	default cCodCli 	:= ''
	default cLojaCli	:= ''
	default lOnlyPortal	:= .T.

	if !empty(cCodCli) .and. !empty(cLojaCli)
		cCodCli 	:= Alltrim(cCodCli)
		cLojaCli 	:= Alltrim(cLojaCli)
		cChave		:= cCodCli + '-' + cLojaCli

		cCliCond 	:= getCliField(cChave, 'A1_COND')
		cCliSUCond 	:= getCliField(cChave, 'A1_CONDPSU')

		if lAtivoCond .and. ( ! empty(cCliCond) .and. ! empty(cCliSUCond) )
			if !lOnlyPortal
				oWsObj       := WsClassNew("WsCbcGenericObject")
				oWsObj:id    := Alltrim(cCliCond)
				oWsObj:value := oSql:getFieldValue("SE4", "E4_DESCRI", "%SE4.XFILIAL% AND E4_CODIGO = '"+ cCliCond +"'")
				aAdd(aCond, oWsObj) 
			endif
		else
			// Verificar se cliente tem média cadastrada
			if (nPos := buscaCli(cChave, ::oDadosCondPagto:AMEDIA)) > 0
				nMedia := ::oDadosCondPagto:AMEDIA[nPos,1]
			endif	

			cQuery := " SELECT E4_CODIGO [ID], E4_DESCRI [VALUE], E4_ZMEDPAG [MEDIA] "
			cQuery += " FROM %SE4.SQLNAME% "
			cQuery += " WHERE %SE4.XFILIAL% "

			if lOnlyPortal
				cQuery += " AND E4_XPORTAL = 'S' "
			endif

			cQuery += " AND E4_MSBLQL != '1' AND %SE4.NOTDEL% "

			cQuery += " ORDER BY 2 " 

			oSql:newAlias(cQuery)
			// Obter todas as condições de pagamento
			while oSql:notIsEof()
				// Cliente tem média cadastrada, das condições de pagamento permitir apenas as dentro da média.
				if nMedia > 0
					if NoRound(val(oSql:getValue("MEDIA"))) <= nMedia
						oWsObj       := WsClassNew("WsCbcGenericObject")
						oWsObj:id    := oSql:getValue("ID")
						oWsObj:value := oSql:getValue("AllTrim(VALUE)")
						aAdd(aCond, oWsObj) 
					endif
					// Cliente não tem cadastro de média, adiciona todas as condições de pagamento
				else

					// Obtem a média padrão
					if (nPos := buscaCli( '*', ::oDadosCondPagto:AMEDIA )) > 0
						nDefaultMedia := ::oDadosCondPagto:AMEDIA[nPos,1]
					endif
					// Aplica a média padrão
					if nDefaultMedia > 0
						if NoRound(val(oSql:getValue("MEDIA"))) <= nDefaultMedia
							oWsObj       := WsClassNew("WsCbcGenericObject")
							oWsObj:id    := oSql:getValue("ID")
							oWsObj:value := oSql:getValue("AllTrim(VALUE)")
							aAdd(aCond, oWsObj) 
						endif
						// Não tem média padrão usa todos
					else
						oWsObj       := WsClassNew("WsCbcGenericObject")
						oWsObj:id    := oSql:getValue("ID")
						oWsObj:value := oSql:getValue("AllTrim(VALUE)")
						aAdd(aCond, oWsObj)
					endif 

				endif

				oSql:skip()
			endDo

			// Cliente não tem cadastro de média, alem das condições padrão, verificar se tem condição fixa no cadastro.
			if nMedia == 0
				if !empty(cCliCond)
					oWsObj       := WsClassNew("WsCbcGenericObject")
					oWsObj:id    := Alltrim(cCliCond)
					oWsObj:value := oSql:getFieldValue("SE4", "E4_DESCRI", "%SE4.XFILIAL% AND E4_CODIGO = '"+ cCliCond +"'")
					aAdd(aCond, oWsObj) 
				endif
			endif
		endif
	endif
	oSql:close()
	FreeObj(oSql)
return(aCond)


/*/{Protheus.doc} vldCliPayTerms
@author bolognesi
@since 20/09/2017
@version 1.0
@param cCodCli, characters, Codigo do Cliente
@param cLojaCli, characters, Loja do Cliente
@param cCond, characters, Codigo Condição de pagamento
@type method
@description Verifica se uma condição de pagamento pertence ao cliente
/*/
method vldCliPayTerms(cCodCli, cLojaCli, cCond) class cbcCondPagto
	local lRet 			:= .F.
	local aConds		:= {}
	local nPos			:= 0
	local oAcl			:= cbcAcl():newcbcAcl()
	default cCodCli		:= ''
	default cLojaCli 	:= ''
	default cCond 		:= ''

	if oAcl:usrIsGrp(aGRP_NAO_VLD)
		lRet := .T.
	else
		if lVLD_LIGADA
			if !empty(cCodCli) .and. !empty(cLojaCli) .and. !empty(cCond)
				if !empty(aConds := ::getPaymentTerms(cCodCli, cLojaCli, .F.))
					lRet := ( AScan( aConds ,{|a|  Alltrim(a:id)  == Alltrim(cCond)}) > 0)
				endif
			endif
		else
			lRet := .T.
		endif
	endif
return(lRet)

/*/{Protheus.doc} showDialog
@author bolognesi
@since 20/09/2017
@version 1.0
@type method
@description Inicializa a interface gráfica 
/*/
method showDialog() class cbcCondPagto
	local oStepWiz 		:= nil
	local oCondPagto	:= nil 

	if ValType(::oDadosCondPagto) != 'O'
		Alert('Erro - Objeto ')
	else

		if !AttIsMemberOf(::oDadosCondPagto,'AMEDIA')
			Alert('Estrutura Objeto errada')
		else
			addNome(self)
			oCondPagto :=  ::oDadosCondPagto

			//Instancia a classe FWWizard
			oStepWiz:= FWWizardControl():New()
			oStepWiz:SetSize({700,960})
			oStepWiz:ActiveUISteps()

			//----------------------
			// Pagina 1
			//----------------------
			oNewPag := oStepWiz:AddStep("1")
			//Altera a descrição do step
			oNewPag:SetStepDescription('Cond.Pagto x Clientes')
			//Define o bloco de construção
			oNewPag:SetConstruction({|Panel|cria_pg1(Panel, @oCondPagto)})
			//Define o bloco ao clicar no botão Próximo
			oNewPag:SetNextAction({||finaliza(self, @oCondPagto, self)})
			//Define o bloco ao clicar no botão Cancelar
			oNewPag:SetCancelAction({||oStepWiz:Destroy(), .T.})

			oStepWiz:Activate()
		endIF
	endIf
return(self)


/* INICIO DAS OPÇÔES DE TELA */


/*/{Protheus.doc} cria_pg1
@author bolognesi
@since 20/09/2017
@version 1.0
@param oPanel, object, descricao
@param oCondPagto, object, descricao
@type function
@description Cria a tela de cadastro chamada pelo metodo showDialog()
/*/
static Function cria_pg1(oPanel, oCondPagto)
	local oFont1 		:= TFont():New("Arial Narrow",,020,,.F.,,,,,.F.,.F.)
	local oBtnIncluir		:= nil
	local oBtnExcluir		:= nil
	local oBtnItmIncl		:= nil
	local oBtnConsCond		:= nil
	local oBtnItmExcl		:= nil
	local oBtnEditH			:= nil
	local oBtnItmLote		:= nil
	local oBtnDefDefault	:= nil
	local oLstBox			:= nil
	local oLstItm			:= nil
	local nLstBox 			:= 1
	local nLstItm 			:= 1
	local nX 				:= 0
	local aCondPag			:= oCondPagto:AMEDIA
	local aHdr				:= {}
	local aItm				:= {}
	local aCliente			:= {}

	// oCondPagto
	ASort(aCondPag,,,{|x,y|  x[1] < y[1] })
	for nX := 1 to Len(aCondPag)
		aadd(aHdr, cValToChar(aCondPag[nX,1]) )
	next nX

	// Header (Médias de Pagamento) (Master)
	oLstBox 	 := TListBox():New(001,001,{|u|if(Pcount()>0,nLstBox:=u,nLstBox)},aHdr ,227,160,{||updItm(oLstBox,oLstItm,oCondPagto,aItm)},oPanel,,,,.T.,,,oFont1 )
	oBtnConsCond := TButton():New( 175, 36,  "Cond.Pagto",oPanel ,{||consCond(oLstBox)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnExcluir  := TButton():New( 175, 86,  "Del.Média",oPanel ,{||delVlr(aHdr, oLstBox, oPanel, oCondPagto)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnEditH	 := TButton():New( 175, 136, "Edit.Média",oPanel ,{||editVlr(aHdr, oLstBox, oPanel, oCondPagto)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnIncluir  := TButton():New( 175, 186, "Add.Média",oPanel ,{||addVlr(aHdr, oLstBox, oPanel, oCondPagto)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )   


	// Itens Para Cada Média(Header), pode existir varios clientes (Details)
	oLstItm 		:= TListBox():New(001,256,{|u|if(Pcount()>0,nLstItm:=u,nLstItm)},aItm ,227,160,{||},oPanel,,,,.T.,,,oFont1 )
	oBtnDefDefault 	:= TButton():New( 175, 291, "Def.Padrao",oPanel ,{||defPadr(aItm, oLstBox, oLstItm, oPanel, oCondPagto)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnItmLote 	:= TButton():New( 175, 341, "Add.Lote",oPanel ,{||loteCli(aItm, oLstItm, oPanel, oCondPagto, oLstBox )}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnItmExcl 	:= TButton():New( 175, 391, "Del.Cliente",oPanel ,{||delCli(aItm, oLstItm, oPanel, oCondPagto)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnItmIncl 	:= TButton():New( 175, 441, "Add.Cliente",oPanel ,{||addCli(aItm, oLstBox, oLstItm, oPanel, oCondPagto)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	oLstBox:GoTop()

return(Nil)


/*/{Protheus.doc} consCond
@author bolognesi
@since 20/09/2017
@version 1.0
@param oLstBox, object, Estancia do objeto lista exibido na tela
@type function
@description Selecionar para axibição as condições de pagamento de uma determinada média
/*/
static function consCond(oLstBox)
	local cMedia	:= if(empty(oLstBox:GetSelText()),'',oLstBox:GetSelText())
	local oSql		:= LibSqlObj():newLibSqlObj() 
	local cQuery	:= ""
	local cTxt		:= ""

	if !empty(cMedia)
		cQuery := " SELECT E4_DESCRI [VALUE], E4_XPORTAL [PORTAL], E4_ZMEDPAG [MEDIA]"
		cQuery += " FROM %SE4.SQLNAME% "
		cQuery += " WHERE %SE4.XFILIAL%  AND E4_MSBLQL != '1' AND %SE4.NOTDEL% "
		cQuery += " ORDER BY E4_FILIAL, E4_XPORTAL, E4_DESCRI  " 

		oSql:newAlias(cQuery) 

		while oSql:notIsEof()

			if NoRound(val(oSql:getValue("MEDIA"))) <= Val(cMedia)
				cTxt += '[' + oSql:getValue("AllTrim(VALUE)") + '] -' +;
				' (PORTAL: ' + if(oSql:getValue("AllTrim(PORTAL)") == 'S','SIM','NÃO' ) + ') ' +;
				' MÉDIA: ' +  oSql:getValue("AllTrim(MEDIA)") + ';'  
			endif
			oSql:skip()
		endDo
		oSql:close()
		FreeObj(oSql)
		showModal(cTxt, 'Cond.Pagto para a media: ' + cMedia)
	endif

return(nil)


/*/{Protheus.doc} showModal
@author bolognesi
@since 20/09/2017
@version 1.0
@param cTxt, characters, Texto para ser exibido
@param cTitle, characters, Titulo da Janela
@type function
@description Exibir uma janela modal, com as condições de pagamento
de uma determinada faixa
/*/
static function showModal(cTxt, cTitle)
	local oModal		:= FWDIALOGMODAL():new()
	local oFont1 		:= TFont():New("Arial Narrow",,020,,.F.,,,,,.F.,.F.)
	local oLstPagto		:= nil
	local aCond			:= {}

	aCond := StrToKArr(cTxt,';')

	oModal:SetTitle(cTitle)
	oModal:setBackground(.F.)
	oModal:setFreeArea(320, 200)

	oModal:createDialog()
	oModal:addCloseButton()
	if empty(aCond)
		aadd(aCond, 'Nenhuma condição encontrada')
	endif
	oLstPagto  := TListBox():New(001,001,{|u|if(Pcount()>0,oLstPagto:=u,oLstPagto)},aCond ,310,180,{||},oModal:getPanelMain(),,,,.T.,,,oFont1 )

	oModal:activate()
	FreeObj(oModal)
	FreeObj(oFont1)

return(nil)


/*/{Protheus.doc} addVlr
@author bolognesi
@since 20/09/2017
@version 1.0
@param aHdr, array, Array contendo todas as médias de pagamento
@param oLstBox, object, Estancia do objeto lista exibido na tela
@param oPanel, object, Objeto principal da tela
@param oCondPagto, object, Objeto com o JSON estanciado (Este é o objeto alvo deste cadastro)
@type function
@description [HEADER] - Adiciona Médias de pagamento(Header)
/*/
static function addVlr(aHdr, oLstBox, oPanel, oCondPagto)
	local aPergs 	:= {}
	local cCodRec	:= Space(6)
	local aRet		:= {}
	local nPos		:= 0
	local cNewValue	:= ''
	aadd( aPergs ,{1,"Média/Dias : ",cCodRec,"99.99",'.T.',,'.T.',6,.F.})
	if ParamBox(aPergs ,"Incluir ",@aRet)      
		if !Empty(aRet[1])
			nPos := AScan( aHdr ,{|a|  lower(Alltrim(a)) == lower(Alltrim(aRet[1]))  })
			if nPos == 0
				cNewValue := Lower(Alltrim(aRet[1]))
				aadd(aHdr,cNewValue  )
				ASort(aHdr,,,{|x,y|  x < y })
				oLstBox:SetItems(aHdr)
				aadd(oCondPagto:AMEDIA,{ Val(cNewValue),{} }  )
				ASort(oCondPagto:AMEDIA,,,{|x,y|  x[1] <  y[1] })
				oPanel:Refresh()
			endIf
		endIf
	endIf 
return(nil)


/*/{Protheus.doc} delVlr
@author bolognesi
@since 20/09/2017
@version 1.0
@param aHdr, array, Array contendo todas as médias de pagamento
@param oLstBox, object, Estancia do objeto lista exibido na tela
@param oPanel, object, Objeto principal da tela
@param oCondPagto, object, Objeto com o JSON estanciado (Este é o objeto alvo deste cadastro)
@type function
@description [HEADER] - Remove Médias de pagamento(Header), bem como todos os clientes
/*/
static function delVlr(aHdr, oLstBox, oPanel, oCondPagto)
	local nPos 		:= 0
	local nNovo		:= 0
	local cMedia	:= oLstBox:GetSelText()
	if MsgNoYes('Deseja excluir a média: ' + cMedia )
		nPos := AScan(aHdr,{|a| Alltrim(a) == Alltrim(cMedia) })
		if nPos > 0
			if (nNovo := (Len(aHdr) - 1)) == 0
				Alert('[ERRO]- Não é possivel excluir todos os itens, deve restar ao menos um')
				return
			else				
				Adel(aHdr,nPos )
				ASize(aHdr, nNovo)
				oLstBox:Select(nNovo)
				if (nPos := AScan( oCondPagto:AMEDIA ,{|a|  a[1] ==  Val(cMedia) }) ) > 0
					nNovo := (Len(oCondPagto:AMEDIA) - 1)
					Adel(oCondPagto:AMEDIA,nPos )
					ASize(oCondPagto:AMEDIA, nNovo)
				endif
				oLstBox:SetItems(aHdr)
				oPanel:Refresh()
				oLstBox:GoTop()
			endif

		endIf
	endIF
return(nil)


/*/{Protheus.doc} editVlr
@author bolognesi
@since 20/09/2017
@version 1.0
@param aHdr, array, Array contendo todas as médias de pagamento
@param oLstBox, object, Estancia do objeto lista exibido na tela
@param oPanel, object, Objeto principal da tela
@param oCondPagto, object, Objeto com o JSON estanciado (Este é o objeto alvo deste cadastro)
@type function
@description Editar uma média de pagamento
/*/
static function editVlr(aHdr, oLstBox, oPanel, oCondPagto)
	local aPergs 	:= {}
	local cCodRec	:= oLstBox:GetSelText()
	local aRet		:= {}
	local nPos		:= 0
	local cVlrAnt	:= cCodRec
	local nX		:= 0
	local lUnico	:= .T.
	aadd( aPergs ,{1,"Alterar Média/Dias : ",cCodRec,"99.99",'.T.',,'.T.',6,.F.})
	if ParamBox(aPergs ,"Alterar ",@aRet)      
		if !Empty(aRet[1])
			// Validar duplicidade
			for nX := 1 to len(aHdr)
				if Val(aHdr[nX]) == Val(aRet[1])
					lUnico := .F.
					exit
				endif
			next nX
			if !lUnico
				Alert('[ERRO] - Não é permitdo médias duplicadas ')
			else
				if (nPos := AScan( aHdr ,{|a|  lower(Alltrim(a)) == cVlrAnt  })) > 0	
					aHdr[nPos] := lower(Alltrim(aRet[1]))
					ASort(aHdr,,,{|x,y|  x < y })
					oLstBox:SetItems(aHdr)

					if (nPos := AScan( oCondPagto:AMEDIA ,{|a|  a[1] == Val(cVlrAnt)  })) > 0
						oCondPagto:AMEDIA[nPos,1] := Val(aRet[1])
						ASort(oCondPagto:AMEDIA,,,{|x,y|  x[1] <  y[1] })
						oPanel:Refresh()
					endif
				endIf
			endif
		endIf
	endIf 
return(nil)


/*/{Protheus.doc} loteCli
@author bolognesi
@since 20/09/2017
@version 1.0
@param aItm, array, descricao
@param oLstItm, object, descricao
@param oPanel, object, descricao
@param oCondPagto, object, descricao
@type function
@description Realiza a inclusão de clientes em lote para
uma determinada média de pagamento
/*/
static function loteCli(aItm, oLstItm, oPanel, oCondPagto, oLstBox)
	local oModal		:= FWDIALOGMODAL():new()
	local oFont1 		:= TFont():New("Arial Narrow",,020,,.F.,,,,,.F.,.F.)
	local oLstPagto		:= nil
	local cGetCNPJ 		:= Space(TamSx3('A1_CGC')[1] )
	local oGetCNPJ		:= nil
	local oLstCli		:= nil
	local oBtnOk		:= nil
	local oBtnSch		:= nil
	local nLstCli		:= 1
	local aItmCli		:= {}
	local aButons		:= {}

	if (AScan( oLstItm:aItems ,{|a|  Alltrim(a) ==  Alltrim(STRING_PADRAO) }) ) > 0
		Alert('[ERRO] -  Média definida como padrão, não recebe clientes')
	else
		oModal:SetTitle('Adicionar em Lote')
		oModal:setBackground(.F.)
		oModal:setFreeArea(320, 200)
		oModal:createDialog()
		oModal:addCloseButton()
		// Label
		oSayCNPJ:= TSay():New(01,01,{||'Raiz do CNPJ'},oModal:getPanelMain(),,oFont1,,,,.T.,CLR_RED,CLR_WHITE,200,20)

		// TextBox CNPJ
		oGetCNPJ 	:= TGet():New( 001, 050, { | u | If( PCount() == 0, cGetCNPJ, cGetCNPJ := u ) },oModal:getPanelMain(), ;
		060, 010, "!@",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,'SA1CGC','cGetCNPJ',,,,.T. )

		// Botão de busca
		oBtnSch 	:= TButton():New( 001, 110, "Pesquisar",oModal:getPanelMain() ,{||qryCli(aItmCli, oLstCli, oModal:getPanelMain(),cGetCNPJ)}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		// Lista exibir resultado
		oLstCli 	:= TListBox():New(020,005,{|u|if(Pcount()>0,nLstCli:=u,nLstCli)},aItmCli ,310,170,{||},oModal:getPanelMain(),,,,.T.,,,oFont1 )
		// Confirmação final
		oBtnOk 		:= TButton():New( 001, 270, "Confirmar", oModal:getPanelMain() ,{||confLtCli(aItmCli, oLstCli, oModal:getPanelMain(), oCondPagto, aItm, oLstItm, oPanel, oLstBox  )}, 40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

		oModal:activate()
		FreeObj(oModal)
		FreeObj(oFont1)
	endif
return(nil)


/*/{Protheus.doc} qryCli
@author bolognesi
@since 20/09/2017
@version 1.0
@param aItmCli, array, Array para exibição do resultado
@param oLstCli, object, Lista para exibição do resultado
@param oPanel, object, Painel principal
@param oCondPagto, object, Classe JSON principal do cadastro
@param cGetCNPJ, characters, Valor para realizar a busca
@type function
@description Executa a query no SA1 com base no CNPJ selecionado
/*/
static function qryCli(aItmCli, oLstCli, oPanel, cGetCNPJ)
	local oSql		:= LibSqlObj():newLibSqlObj() 
	local cQuery	:= ""
	local aTmp		:= {}

	if !empty(cGetCNPJ) .and. (len(cGetCNPJ) >= 8)
		cQuery := " SELECT A1_COD [COD], A1_LOJA [LOJA], A1_NOME [NOME] "
		cQuery += " FROM %SA1.SQLNAME% "
		cQuery += " WHERE %SA1.XFILIAL% "
		cQuery += " AND  A1_CGC LIKE '" + SubStr(Alltrim(cGetCNPJ),1,8)    + "%' "  
		cQuery += " AND A1_MSBLQL != '1' AND %SA1.NOTDEL% "
		cQuery += " ORDER BY 3  " 

		oSql:newAlias(cQuery) 

		while oSql:notIsEof()
			aadd(aTmp, '[' + oSql:getValue("AllTrim(COD)") + '-' +;
			oSql:getValue("AllTrim(LOJA)") + '] - ' +;
			oSql:getValue("AllTrim(NOME)")   )
			oSql:skip()
		endDo
		oSql:close()
		FreeObj(oSql)

		if !empty(aTmp)
			aItmCli := aTmp
			oLstCli:SetItems(aItmCli)
			oPanel:Refresh()
		endif
	endif
return(nil)


/*/{Protheus.doc} confLtCli
@author bolognesi
@since 20/09/2017
@version 1.0
@param aItmCli, array, Item com os clientes selecionados em lote
@param oLstCli, object, Lista dos clientes selecionados em lote
@param oPanel, object, Painel principal
@param oCondPagto, object, Classe JSON principal
@param aItm, array, Itens de clientes da primeira tela
@param oLstItm, object, Lista com os clientes da primeira tela
@param oPanel, object, Painel principal da aplicação
@param oLstBox, object, Lista com as Médias de condições
@type function
@description Adiciona todos os clientes do lote na lista de clientes.
/*/
static function confLtCli(aItmCli, oLstCli, oPanel, oCondPagto,aItm, oLstItm, oPanel, oLstBox)
	local nPos 		:= 0
	local nX 		:= 0
	local cMedia 	:= oLstBox:GetSelText()
	for nX := 1 to len(aItmCli)
		if  (nPos := buscaCli(aItmCli[nX], oCondPagto:AMEDIA)) == 0
			if (nPos := AScan( oCondPagto:AMEDIA ,{|a|  a[1] ==  Val(cMedia) }) ) > 0
				aadd(oCondPagto:AMEDIA[nPos,2], aItmCli[nX])
				ASort(oCondPagto:AMEDIA[nPos,2],,,{|x,y|  x < y })
				oLstItm:SetItems(oCondPagto:AMEDIA[nPos,2])
				oPanel:Refresh()
			endif
		else
			Alert('[Erro] - Cliente ' + Alltrim(aItmCli[nX]) + ' já cadastrado na média ' + cValToChar(oCondPagto:AMEDIA[nPos,1]))
		endif
	next nX
return(nil)


/*/{Protheus.doc} addCli
@author bolognesi
@since 20/09/2017
@version 1.0
@param aItm, array, Array com os clientes da  média selecionada
@param oLstBox, object, Lista das médias exibidas na tela
@param oLstItm, object, Lista dos clientes da média selecionada
@param oPanel, object, Objeto principal da tela
@param oCondPagto, object, Objeto com o JSON estanciado (Este é o objeto alvo deste cadastro)
@type function
@description  [ITEM] - Adiciona clientes para uma média de pagamento selecionada
/*/
static function addCli(aItm,oLstBox, oLstItm, oPanel, oCondPagto)
	local aPergs 	:= {}
	local cCodCli	:= Space( TamSX3('A1_COD')[1] )
	local cLojaCli	:= Space( TamSX3('A1_LOJA')[1] )
	local aRet		:= {}
	local nPos		:= 0
	local aCli		:= {}
	local cNewValue	:= ''
	local cMedia 	:= ''
	local cNome		:= ''

	if (AScan( oLstItm:aItems ,{|a|  Alltrim(a) ==  Alltrim(STRING_PADRAO) }) ) > 0
		Alert('[ERRO] -  Média definida como padrão, não recebe clientes')
	else
		aadd( aPergs ,{1,"Cliente : ",cCodCli, "@!",'.T.','SA1','.T.',TamSX3('A1_COD')[1], .T.} )
		aadd( aPergs ,{1,"Loja : "	 ,cLojaCli,"@!",'.T.',,'.T.',TamSX3('A1_LOJA')[1], .T.} )

		if ParamBox(aPergs ,"Clientes ",@aRet)      
			if !Empty(aRet[1]) .and. !Empty(aRet[2])

				cMedia 		:= oLstBox:GetSelText()
				cCodCli 	:= Alltrim(aRet[1])
				cLojaCli	:= Alltrim(aRet[2])
				cNome		:= getCliField(cCodCli + '-' + cLojaCli)
				cNewValue 	:= '[' + Alltrim(cCodCli + '-' + cLojaCli) + ']' + ' - ' + Alltrim(cNome)

				// Procurar ClienteLoja em todo array 
				if  (nPos := buscaCli(cNewValue, oCondPagto:AMEDIA)) == 0
					// Não Achou apenas incluir na média selecionada
					if (nPos := AScan( oCondPagto:AMEDIA ,{|a|  a[1] ==  Val(cMedia) }) ) > 0
						aadd(oCondPagto:AMEDIA[nPos,2], cNewValue)
						ASort(oCondPagto:AMEDIA[nPos,2],,,{|x,y|  x < y })
						oLstItm:SetItems(oCondPagto:AMEDIA[nPos,2])
						oPanel:Refresh()
					endif
				else
					Alert('[ERRO] - Cliente já esta cadastrado na média ' + cValToChar(oCondPagto:AMEDIA[nPos,1]) )
				endIf
			endIf
		endIf
	endif 
return(nil)


static function defPadr(aItm, oLstBox, oLstItm, oPanel, oCondPagto)
	local nPos			:= 0
	local cMedia 		:= oLstBox:GetSelText()
	if empty(oLstItm:aItems)
		if  (nPos := buscaCli(STRING_PADRAO, oCondPagto:AMEDIA)) == 0
			if (nPos := AScan( oCondPagto:AMEDIA ,{|a|  a[1] ==  Val(cMedia) }) ) > 0
				aadd(oCondPagto:AMEDIA[nPos,2], STRING_PADRAO)
				ASort(oCondPagto:AMEDIA[nPos,2],,,{|x,y|  x < y })
				oLstItm:SetItems(oCondPagto:AMEDIA[nPos,2])
				oPanel:Refresh()
			endif
		else
			Alert('[ERRO] - Média ' + cValToChar(oCondPagto:AMEDIA[nPos,1]) + ' já definida como padrão ' )
		endIf
	else
		Alert('[ERRO] - para definir uma média como padrão, não deve conter nenhum cliente.')
	endif
return(nil)

/*/{Protheus.doc} delCli
@author bolognesi
@since 20/09/2017
@version undefined
@param aItm, array, Array com os clientes da  média selecionada
@param oLstItm, object, Lista dos clientes da média selecionada
@param oPanel, object, Objeto principal da tela
@param oCondPagto, object, Objeto com o JSON estanciado (Este é o objeto alvo deste cadastro)
@type function
@description [ITEM] - Remove cliente selecionado de uma média de pagamento
/*/
static function delCli(aItm,oLstItm, oPanel, oCondPagto)
	local nPos 		:= 0
	local nNovo		:= 0
	local cCliente 	:= Alltrim(oLstItm:GetSelText())
	if empty(cCliente)
		Alert('[ERRO] - Selecione um cliente para deletar')
	else
		if MsgNoYes('[PERGUNTA] - Deseja excluir o cliente: ' +  cCliente )

			nPos := AScan(aItm,{|a| Alltrim(a) == cCliente })
			if nPos > 0
				nNovo := (Len(aItm) - 1)
				Adel(aItm,nPos )
				ASize(aItm, nNovo)
				oLstItm:SetItems(aItm)
				oPanel:Refresh()
			endIf
		endIf
	endif
return(nil)


/*/{Protheus.doc} updItm
@author bolognesi
@since 20/09/2017
@version undefined
@param oLstBox, object, Lista das médias exibidas na tela
@param oLstItm, object, Lista dos clientes da média selecionada
@param oCondPagto, object, Objeto com o JSON estanciado (Este é o objeto alvo deste cadastro)
@param aItm, array, Array com os clientes da  média selecionada
@type function
@description Disparada no eveento change da lista de médias, permite que ao selecionarmos uma média
os clientes desta média sejam carregados na lista de clientes
/*/
static function updItm(oLstBox,oLstItm,oCondPagto,aItm)
	local cMedia := oLstBox:GetSelText()
	local nPos		:= 0

	if (nPos := AScan( oCondPagto:AMEDIA ,{|a|  a[1] == Val(cMedia) })) > 0
		aItm := oCondPagto:AMEDIA[nPos,2]
		oLstItm:SetItems(aItm)
	endif

return(nil)


/*/{Protheus.doc} finaliza
@author bolognesi
@since 20/09/2017
@version 1.0
@param oSelf, object, descricao
@type function
@description Finaliza a manutenção a salva o JSON em disco
/*/
static function finaliza(oSelf)
	local lRet	 := .F.
	lRet := MsgNoYes('Deseja finalizar a manutenção?')
	if lRet
		if (lRet := fuckOk(oSelf))
			oSelf:save()
		endif
	endIf
return(lRet)


/*/{Protheus.doc} fuckOk
@author bolognesi
@since 20/09/2017
@version 1.0
@type function
@description Realiza a validação final
/*/
static function fuckOk(oSelf)
	local lRet 			:= .T.
	local aVld			:= oSelf:oDadosCondPagto:AMEDIA
	local nX			:= 0
	local lTemPadrao	:= .F.

	for nX := 1 to len(aVld)
		if !lTemPadrao
			lTemPadrao := (AScan( aVld[nX,2] ,{|a|  Alltrim(a) ==  Alltrim(STRING_PADRAO) }) ) > 0
		endif
		if empty( aVld[nX,2] )
			Alert( ' [ERRO] - A média de pagamento '  + cValToChar(aVld[nX,1]) + ' não possue clientes cadastrados!! '    )
			lRet := .F.
			exit
		endif
	next nX

	if !lTemPadrao .and. lRet 
		lRet := MsgNoYes('[PERGUNTA] - Nenhuma média definida como padrão, deseja continuar?')
	endif

return(lRet)


/* FIM OPÇÔES DE TELA */


/*/{Protheus.doc} jsonToObj
@author bolognesi
@since 20/09/2017
@version 1.0
@param oSelf, object, descricao
@type function
@description Desserializa a string para o objeto
/*/
static function jsonToObj(oSelf)
	local aDados 	:= oSelf:aItmJson
	local cJs		:= ''
	local oRet		:= nil

	if empty(aDados)
		cJs := '{"AMEDIA":[] }'
	else
		cJs := aDados[1]
	endif
	if !FWJsonDeserialize(cJs, @oRet )
		Alert('jsonToObj não funcionou') 
	endIf
	oSelf:oDadosCondPagto := oRet
return(nil)


/*/{Protheus.doc} buscaCli
@author bolognesi
@since 20/09/2017
@version 1.0
@param cChvCli, characters, Codigo Loja do cliente a ser procurado
@param aArr, array, array onde procurar (oCondPagto:AMEDIA) 
@type function
@description Realiza a busca do cliente no array principal e retorna a 
possição quando encontra
/*/
static function buscaCli(cChvCli, aArr)
	local nPos 	:= 0
	local nX 	:= 0
	local nY	:= 0
	for nX := 1 to Len(aArr)
		if nPos > 0
			exit
		else
			for nY := 1 to len(aArr[nX,2])
				if Alltrim(aArr[nX,2,nY]) == Alltrim(cChvCli) 
					nPos := nX
					exit
				endif
			next nY
		endif
	next nX
return(nPos)


/*/{Protheus.doc} getCliField
@author bolognesi
@since 22/09/2017
@version 1.0
@param cChave, characters, Cliente Loja Separado '-'
@param cCmp, characters, Campo que devemos buscar no A1 do cliente default(A1_NOME)
@type function
@description Obter dados do cliente na tabela SA1
/*/
static function getCliField(cChave, cCmp)
	local oCliente 	:= nil 
	local aCliLoj	:= StrToKArr(cChave, '-')
	local cNome		:= ''
	default cCmp	:= 'A1_NOME'
	oCliente := cbcModClient():newcbcModClient( aCliLoj[1], aCliLoj[2] )
	cNome := oCliente:getField(cCmp)
	FreeObj(oCliente)
return(cNome)


/*/{Protheus.doc} remNome
@author bolognesi
@since 20/09/2017
@version 1.0
@param oSelf, object, this desta classe
@type function
@description Remove o nome deixando apenas o codigo
para salvar o JSON sem os nomes
/*/
static function remNome(oSelf)
	local nX		:= 0
	local nY		:= 0
	local cNewValue	:= ''
	local aArrTmp	:= {}
	for nX := 1 to len(oSelf:oDadosCondPagto:AMEDIA)
		for nY := 1 to len(oSelf:oDadosCondPagto:AMEDIA[nX,2])
			aArrTmp := StrToKArr(oSelf:oDadosCondPagto:AMEDIA[nX,2,nY], ']' )
			cNewValue := StrTran(aArrTmp[1],'[','') 
			oSelf:oDadosCondPagto:AMEDIA[nX,2,nY] := cNewValue
		next nY
	next nX
return(nil)


/*/{Protheus.doc} addNome
@author bolognesi
@since 20/09/2017
@version 1.0
@param oSelf, object, this desta classe
@type function
@description Adicionar os nomes dos clientes
/*/
static function addNome(oSelf)
	local nX		:= 0
	local nY		:= 0
	local cNome		:= ''
	local cNewValue	:= ''

	for nX := 1 to len(oSelf:oDadosCondPagto:AMEDIA)
		for nY := 1 to len(oSelf:oDadosCondPagto:AMEDIA[nX,2])
			if '*' $ oSelf:oDadosCondPagto:AMEDIA[nX,2,nY]
				cNewValue := STRING_PADRAO
			else
				cNome := getCliField(oSelf:oDadosCondPagto:AMEDIA[nX,2,nY])
				cNewValue := '[' + oSelf:oDadosCondPagto:AMEDIA[nX,2,nY] + '] - ' + cNome 
			endif
			oSelf:oDadosCondPagto:AMEDIA[nX,2,nY] := Alltrim(cNewValue)
		next nY
	next nX
return(nil)


/*/{Protheus.doc} bkOld
@author bolognesi
@since 25/09/2017
@version 1.0
@type function
@description Realiza um backup do ultimo arquivo, antes de realizar a gravação do novo.
/*/
static function bkOld(oSelf)
	local aInfo		:= StrToKArr(oSelf:oCrud:getPath(), '\\')
	local cPath		:= ''
	local cNome 	:= '' 

	if !empty(aInfo[1])	
		cPath := '\' + Alltrim(aInfo[1]) + '\' + BKP_DIR + '\'
		if !ExistDir( cPath )
			MakeDir( cPath )
		endif
		cNome := StrTran(DtoC(Date()),'/','') + '_' + StrTran(Time(), ':','') + '_' + Alltrim( aInfo[2] ) 
		__CopyFile( oSelf:oCrud:getPath() , (cPath + cNome) )
	endif

	oSelf:oCrud:getPath()
return(nil)


/* CHAMADA DO MENU  */
/*/{Protheus.doc} zCbcCond
@author bolognesi
@since 21/09/2017
@version 1.0
@type function
@description Chamada utilizada no menu
/*/
user function zCbcCond()
	local aArea		:= GetArea()
	local oCond		:= nil
	local oAcl		:= cbcAcl():newcbcAcl()

	if !oAcl:aclValid('CadMedCondPagto')
		Alert(oAcl:getAlert() )
	else
		oCond := cbcCondPagto():newcbcCondPagto(.F.)
		oCond:showDialog()
		FreeObj(oCond)
	endif

	FreeObj(oAcl)
	RestArea(aArea)
return(nil)

/* TEST ZONE */
user function zTstConPag()
	local oCond		:= nil
	local aMedCond	:= {}
	local isOk		:= .F.

	// Para editar
	oCond := cbcCondPagto():newcbcCondPagto(.F.)
	oCond:showDialog()

	// Para consultar
	oCond 		:= cbcCondPagto():newcbcCondPagto(.T.)
	// Informar cliente e loja e obter array com condições de pagamento
	aMedCond 	:= oCond:getPaymentTerms('002439', '01',.F.) //Consulta não portal
	aMedCond 	:= oCond:getPaymentTerms('002439', '01',)	//Default é portal Sim
	aMedCond 	:= oCond:getPaymentTerms('020167', '01')
	aMedCond 	:= oCond:getPaymentTerms('011425', '01')
	// Validar uma condição de pagamento para um cliente
	isOk 		:= oCond:vldCliPayTerms('000001', '01', '084')

return(nil)
