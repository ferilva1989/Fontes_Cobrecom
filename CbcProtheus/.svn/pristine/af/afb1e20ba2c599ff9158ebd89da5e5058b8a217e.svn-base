#include 'protheus.ch'

#define NOME_CAMPO	1
#define VALOR_CAMPO	2
#define VALORTOTAL	1
#define PESOTOTAL		2

/*/{Protheus.doc} cbcDadosEspelho
(long_description)
@author bolognesi
@since 01/02/2018
@version 1.0
@description Classe Obtem as informações Relatorios (Orçamento/Pedido), prepara os dados 
e envia para classe cbcFwMsPrinter realizar os procedimentos.
/*/
class cbcDadosEspelho

	data lOk
	data cMsg
	data DtToPrt
	data cOper
	data lSndEmailOk

	method newcbcDadosEspelho() constructor
	method emailOrder()
	method OrderHeader()
	method OrderItens()
	method getOper()
	method setOper()
	method goToEmail()

endclass

method newcbcDadosEspelho() class cbcDadosEspelho
	::cOper 		:= "INCLUIR"
	::lSndEmailOk	:= .F.
return (self)

method getOper() class cbcDadosEspelho
return(::cOper)

method setOper(cOp) class cbcDadosEspelho
	::cOper := cOp
return (self)


/*/{Protheus.doc} emailOrder
@author bolognesi
@since 29/09/2016
@version 1.0
@type method
@description Envia para email
/*/
method emailOrder(cNumOrd) class cbcDadosEspelho
	local Printer 	:= ""
	default cNumOrd := ""
	::lSndEmailOk 	:= .F.
	if Empty(cNumOrd)
		::lOk 	:= .F.
		::cMsg	:= "[ERRO] - Parametro Obrigatorio cbcDadosEspelho:emailOrder(cNumOrd)"
	else
		::DtToPrt := cbcDataToPrint():newcbcDataToPrint()

		if ::OrderHeader(cNumOrd):lOk
			if ::OrderItens(cNumOrd):lOk
				if ::DtToPrt:setNroDoc(cNumOrd):lOk
					::goToEmail()
				endIf
			endIf
		endIf
	endIf
return (self)

/*/{Protheus.doc} OrderHeader
@author bolognesi
@since 29/09/2016
@version 1.0
@param cNumOrd, characters, Numero do Pedido
@type method
@description Obtem informações do cabeçalho e dos emais envolvidos
/*/
method OrderItens(cNumOrd) class cbcDadosEspelho
	local cQry 		:= ""
	local oRet		:= Nil
	local nPeso		:= 0
	local nVlrTotal	:= 0
	local nIpi		:= 0
	local nTotIpi		:= 0
	local aItens 		:= {}

	default cNumOrd := ""
	::lOk 	:= .T.
	::cMsg 	:= ""

	if Empty(cNumOrd)
		::lOk 	:= .F.
		::cMsg	:= "[ERRO] - Parametro Obrigatorio cbcDadosEspelho:OrderItens(cNumOrd)"
	else
		cQry += " SELECT								 	"
		cQry += " SC6.C6_PRODUTO AS CODIGO,             	"
		cQry += " CASE                                      "
		cQry += " WHEN SC6.C6_POSHPHU = ''					"
		cQry += " THEN SC6.C6_PEDCLI						"
		cQry += " ELSE SC6.C6_POSHPHU 						"
		cQry += " END  			 AS PEDCLI,					"
		cQry += " SC6.C6_ITEM	 AS ITEM,					"
		cQry += " SC6.C6_TES	 AS TES,					"
		cQry += " SC6.C6_CF		 AS CFOP,					"
		cQry += " SC6.C6_DESCRI	 AS DESCRICAO,              "
		cQry += " SC6.C6_LANCES  AS LANCES,               	"
		cQry += " SC6.C6_METRAGE AS METRAGEM,           	"
		cQry += " SC6.C6_QTDVEN	 AS QUANTIDADE,             "
		cQry += " SC6.C6_ZZPICM	 AS ICMS,             		"
		cQry += " CASE                                      "
		cQry += " WHEN SC6.C6_ACONDIC = 'R'                 "
		cQry += " THEN 'ROLO'                               "
		cQry += " WHEN SC6.C6_ACONDIC = 'B'                 "
		cQry += " THEN 'BOBINA'                             "
		cQry += " WHEN SC6.C6_ACONDIC = 'C'                 "
		cQry += " THEN 'CARRETEL PLASTICO'                  "
		cQry += " WHEN SC6.C6_ACONDIC = 'M'                 "
		cQry += " THEN 'CARRETEL MADEIRA'                   "
		cQry += " WHEN SC6.C6_ACONDIC = 'T'                 "
		cQry += " THEN 'RETALHO'                            "
		cQry += " WHEN SC6.C6_ACONDIC = 'L'                 "
		cQry += " THEN 'BLISTER'                            "
		cQry += " ELSE 'N/I'                                "
		cQry += " END				AS ACONDICIONAMENTO,    "
		cQry += " SC6.C6_PRCVEN	AS UNITARIO,                "
		cQry += " SC6.C6_VALOR	AS TOTAL,                   "
		cQry += " CASE										"
		cQry += " 	WHEN SB1.B1_PESCOB > 0					"
		cQry += " 		THEN SC6.C6_QTDVEN * SB1.B1_PESCOB	"
		cQry += " 	ELSE 0									"
		cQry += " END							AS PESOCOB,	"
		cQry += " CASE										"
		cQry += " 	WHEN SB1.B1_PESPVC > 0					"
		cQry += " 		THEN SC6.C6_QTDVEN * SB1.B1_PESPVC	"
		cQry += " 	ELSE 0									"
		cQry += " END							AS PESOPVC	"

		cQry += " FROM " + RetSqlName('SC6') + "  SC6		"

		cQry += " INNER JOIN " + RetSqlName('SB1') +  " SB1	ON '' = SB1.B1_FILIAL 	"
		cQry += " AND SC6.C6_PRODUTO = SB1.B1_COD									"
		cQry += " AND SC6.D_E_L_E_T_ = SB1.D_E_L_E_T_								"

		cQry += " WHERE SC6.C6_FILIAL = '"+ xFilial("SC6") +"'"
		cQry += " AND SC6.C6_NUM = '" + Alltrim(cNumOrd)   +"'"
		cQry += " AND SC6.D_E_L_E_T_ <> '*'                 "
		cQry += " ORDER BY SC6.C6_ITEM						"

		oRet := qry(cQry, self)
		If ::lOk
			::DtToPrt:setItens(oRet)
			aItens := ::DtToPrt:getItens()
			For nX := 1 To Len(aItens)
				nVlrTotal 		+= aItens[nX]:TOTAL
				nPeso 			+= (aItens[nX]:PESOCOB + aItens[nX]:PESOPVC)
				aItens[nX]:ICMS	:= cValToChar(aItens[nX]:ICMS)

				dataTransf( @aItens[nX]:CODIGO		,'SC6','C6_PRODUTO')
				dataTransf( @aItens[nX]:UNITARIO	,'SC6','C6_PRCVEN')
				dataTransf( @aItens[nX]:TOTAL		,'SC6','C6_VALOR')
				dataTransf( @aItens[nX]:QUANTIDADE	,'SC6','C6_QTDVEN')
				dataTransf( @aItens[nX]:CFOP		,'SC6','C6_CF')
			Next nX

			::DtToPrt:setItens(aItens)
			
			dataTransf( @nVlrTotal 	,'SC6','C6_VALOR')
			dataTransf( @nPeso 		,'SC6','C6_VALOR')
			
			::DtToPrt:setTotals({nVlrTotal,nPeso})

		EndIf

	endIf
return (self)

/*/{Protheus.doc} OrderHeader
@author bolognesi
@since 29/09/2016
@version 1.0
@param cNumOrd, characters, Numero do Pedido
@type method
@description Obtem informações do cabeçalho e dos emais envolvidos
/*/
method OrderHeader(cNumOrd) class cbcDadosEspelho
	local cQry 		:= ""
	local oRet		:= Nil
	local nX		:= 0

	default cNumOrd := ""
	::lOk 	:= .T.
	::cMsg 	:= ""

	if Empty(cNumOrd)
		::lOk 	:= .F.
		::cMsg	:= "[ERRO] - Parametro Obrigatorio cbcDadosEspelho:OrderHeader(cNumOrd)"
	else

		cQry += " SELECT																											"
		cQry += " CASE WHEN SC5.C5_PALLET = 'S' THEN 'SIM'	ELSE 'NÃO' END	AS	PALETTE,											"
		cQry += " SC5.C5_NUM		AS NUMERO,																						"
		cQry += " SC5.C5_EMISSAO	AS EMISSAO,																						"
		cQry += " SC5.C5_CLIENTE	AS CODCLI,																						"
		cQry += " SC5.C5_LOJACLI	AS LOJACLI,																						"
		cQry += " RTRIM(LTRIM(SC5.C5_PEDCLI))	AS ORDEMCOMPRA,																		"
		cQry += " SC5.C5_TIPO		AS TIPO,																						"
		cQry += " SC5.C5_TIPOCLI	AS TIPOCLI,																						"
		cQry += " LTRIM(RTRIM(SE4.E4_DESCRI))	AS COND_PAGTO, 																					"
		cQry += " SA3.A3_EMAIL		AS EMAIL_REPRES,                                                                    			"
		cQry += " 'SOB CONSULTA' 	AS PRZFAT,																						"
		cQry += " 'SOB CONSULTA' 	AS PRZLOG,																						"
		cQry += " SA1.A1_EMAILCT  	AS EMAIL_CLI,                                                                       			"
		cQry += " ATEND.A3_EMAIL	AS EMAIL_ATENDENTE,                                                                 			"
		cQry += " SA1.A1_NOME		AS CLIENTE,                                                                         			"
		cQry += " SA1.A1_TEL		AS TELEFONE,                                                                        			"
		cQry += " SA1.A1_CGC		AS CNPJ,                                                                            			"
		cQry += " SA1.A1_INSCR		AS INCRESTADUAL,                                                                    			"
		cQry += " SA1.A1_END		AS ENDERECO_FAT,                                                                    			"
		cQry += " SA1.A1_BAIRRO		AS BAIRRO_FAT,                                                                      			"
		cQry += " SA1.A1_CEP		AS CEP_FAT,                                                                         			"
		cQry += " LTRIM(RTRIM(SA1.A1_MUN)) + '-' + SA1.A1_EST	 AS CIDADE_FAT,                                         			"

		cQry += " CASE																												"
		cQry += " 	WHEN SC5.C5_TPFRETE = 'C'																						"
		cQry += " 		THEN 'CIF'																									"
		cQry += " 	WHEN SC5.C5_TPFRETE = 'F'																						"
		cQry += " 		THEN 'FOB'																									"
		cQry += " 	WHEN SC5.C5_TPFRETE = 'T'																						"
		cQry += " 		THEN 'TERCEIROS'																							"
		cQry += " 	WHEN SC5.C5_TPFRETE = 'S'																						"
		cQry += " 		THEN 'SEM'																									"
		cQry += " 	ELSE 'N/I'																										"
		cQry += " END	AS FRETE,																									"

		cQry += " CASE WHEN SA1.A1_ENDCOB	= '' THEN	'-'	ELSE SA1.A1_ENDCOB	END	AS ENDERECO_COB,								"
		cQry += " CASE WHEN SA1.A1_BAIRROC	= '' THEN	'-'	ELSE SA1.A1_BAIRROC END	AS BAIRRO_COB,          						"
		cQry += " CASE WHEN SA1.A1_CEPC		= '' THEN	'-'	ELSE SA1.A1_CEPC	END AS CEP_COB,             						"
		cQry += " CASE WHEN SA1.A1_MUNC		= '' THEN	'-'	ELSE LTRIM(RTRIM(SA1.A1_MUNC)) + '-' + SA1.A1_ESTC END AS CIDADE_COB, 	"

		cQry += " CASE WHEN SC5.C5_ENDENT1	= ''  "
		cQry += " THEN '-'  "
		cQry += " ELSE  "
		cQry += " CASE WHEN SC5.C5_ENDENT2 = '' "
		cQry += " THEN RTRIM(LTRIM(SC5.C5_ENDENT1)) "
		cQry += " ELSE(RTRIM(LTRIM(SC5.C5_ENDENT1)) + RTRIM(LTRIM(SC5.C5_ENDENT2)) ) "
		cQry += " END "
		cQry += " END "
		cQry += " AS ENDERECO_ENT,"
		
		cQry += " CASE WHEN SA4.A4_NOME IS NULL	 THEN '-'	ELSE RTRIM(LTRIM(SA4.A4_NOME)) 			END	AS TRANSPORTADORA			"

		cQry += " FROM " + RetSqlName('SC5') + "  SC5																				"

		/* COND. PAGAMENTO*/
		cQry += " INNER JOIN " +  RetSqlName('SE4') + " SE4 ON '' = SE4.E4_FILIAL													"
		cQry += " AND SC5.C5_CONDPAG = SE4.E4_CODIGO
		cQry += " AND SC5.D_E_L_E_T_ = SE4.D_E_L_E_T_

		/*CLIENTE */
		cQry += " INNER JOIN " +  RetSqlName('SA1') + " SA1 ON  '' = SA1.A1_FILIAL													"
		cQry += " AND SC5.C5_CLIENT 	= SA1.A1_COD                                                                    			"
		cQry += " AND SC5.C5_LOJACLI 	= SA1.A1_LOJA                                                                   			"
		cQry += " AND SC5.D_E_L_E_T_ 	= SA1.D_E_L_E_T_                                                          					"

		/*REPRESENTANTE A3_FILIAL, A3_CODUSR*/
		cQry += " LEFT JOIN " + RetSqlName('SA3') +" SA3   	ON  '' =  SA3.A3_FILIAL													"
		cQry += " AND SC5.C5_VEND1 		= SA3.A3_COD                                                                    			"
		cQry += " AND SC5.D_E_L_E_T_ 	= SA3.D_E_L_E_T_                                                                			"

		/*REPRESENTANTE ATENDENTE   A3_FILIAL, A3_CODUSR*/
		cQry += " LEFT JOIN " + RetSqlName('SA3') + " ATEND  ON  '' =  ATEND.A3_FILIAL												"
		cQry += " AND SA3.A3_SUPER = ATEND.A3_COD                                                                       			"
		cQry += " AND SC5.D_E_L_E_T_ = ATEND.D_E_L_E_T_                                                                 			"

		/* NOME TRANSPORTADORAS */
		cQry += " LEFT JOIN " + RetSqlName('SA4') + " SA4 ON '' = SA4.A4_FILIAL														"
		cQry += " AND SC5.C5_TRANSP = SA4.A4_COD																					"
		cQry += " AND SC5.D_E_L_E_T_ = SA4.D_E_L_E_T_																				"

		cQry += " WHERE SC5.C5_FILIAL = '" + xFilial("SC5") + "'																	"
		cQry += " AND SC5.C5_NUM = '" + Alltrim(cNumOrd) +"'                                                            			"
		cQry += " AND SC5.D_E_L_E_T_ <> '*'     																					"

		oRet := qry(cQry, self)
		if ::lOk
			for nX := 1 To Len(oRet)
				dataTransf( @oRet[nX]:TELEFONE		,'SA1','A1_TEL')
				dataTransf( @oRet[nX]:CNPJ			,'SA1','A1_CGC')
				dataTransf( @oRet[nX]:INCRESTADUAL	,'SA1','A1_INSCR')
				dataTransf( @oRet[nX]:CEP_FAT		,'SA1','A1_CEP')
				dataTransf( @oRet[nX]:CEP_COB		,'SA1','A1_CEP')
				oRet[nX]:EMISSAO	:= cValToChar(StoD(oRet[nX]:EMISSAO))
				oRet[nX]:PALETTE	:= Alltrim(oRet[nX]:PALETTE)
				oRet[nX]:COND_PAGTO	:= Alltrim(oRet[nX]:COND_PAGTO)
			next nX

			::DtToPrt:setHead(oRet)
		endIf
	endIf
return (self)


method goToEmail() class cbcDadosEspelho
	
	local aHeader 		:= ::DtToPrt:getHead()
	local aItns			:= ::DtToPrt:getItens()
	local aTotal  		:= ::DtToPrt:getTotals()
	local cOper			:= ::getOper()	
	local aCmpCls			:= {}
	local aLoopCls		:= {}
	local aLinha			:= {}
	local nX				:= 0
	local nI				:= 0
	local cEmlRepres		:= ::DtToPrt:getOtherMails('REPRESENTANTE')
	local cEmlAssistente	:= ::DtToPrt:getOtherMails('ASSISTENTE')
	local cEmlGestao		:= GetNewPar('MV_ZMAILEN', '')
	local bErro			:= Nil
	local oSch 			:= Nil
	
	::lOk 			:= .T.
	::lSndEmailOk		:= .T.
	::cMsg			:= ""
	
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, self)})
	BEGIN SEQUENCE
		cConta 	:= GetNewPar('MV_CONTAES', '')
		cSenha	:= GetNewPar('MV_SENHAES', '')
		
		oSch 	:= cbcSchCtrl():newcbcSchCtrl(cConta,cSenha)
		oSch:setIDEnvio('ESPELHOPEDIDO')
		oSch:setEmailFrom(cEmlGestao)
		oSch:addEmailTo(::DtToPrt:getEmailTo() )
		oSch:addEmailCc(cEmlGestao + ";" + cEmlRepres)
		//oSch:addEmailBcc()
		oSch:setConfirm(.T.)
		oSch:setFIXO('S')
			
		if	::DtToPrt:getEmailTo() == 'wfti@cobrecom.com.br'
			cCompSub := "-[ERRO-CLIENTE SEM EMAIL]"
		elseIf cOper == 'INCLUIR'
			cCompSub := "-[INCLUIDO]"
		elseIf cOper == 'ALTERAR'
			cCompSub := "-[ALTERADO]"
		elseIf cOper == 'DELETAR'
			cCompSub := "-[DELETADO]"
		endIf
				
		oSch:setAssunto("[IFC-COBRECOM]" + cCompSub + "- Espelho do Pedido Nro. " + ::DtToPrt:getNroDoc())
		
		oSch:setSimple(.F.)
		oSch:setHtmlFile('\espelhoPedido\html\Espelho_pedido.htm')
	
		// Campos de Cabeçalho
		aCmpCls := ClassDataArr(aHeader,.F.)
		for nX := 1 To Len(aCmpCls)
			//Não incluir os campos que vem da Query mas não tem tag HTML
			if !(aCmpCls[nX,NOME_CAMPO] $ 'TIPO//TIPOCLI//EMAIL_CLI//EMAIL_REPRES')
				oSch:addHdr({aCmpCls[nX,NOME_CAMPO],aCmpCls[nX,VALOR_CAMPO]})
			endIf
		next nX
	
		// Adicionar campos fora do Loop (casos pontuais)
		oSch:addHdr({'VALOR_TOTAL'		,aTotal[VALORTOTAL]	})
		oSch:addHdr({'PESO_TOTAL'		,aTotal[PESOTOTAL]	})
		oSch:addHdr({'EMAIL_R'			,cEmlRepres 			})
		oSch:addHdr({'EMAIL_ATENDENTE'	,cEmlAssistente		})
		
		// Campos de itens	
		for nX := 1 To Len(aItns)
			aLoopCls := ClassDataArr(aItns[nX],.F.)
			for nI := 1 To Len(aLoopCls)
				//Não incluir os campos que vem da Query mas não tem tag HTML
				if !('t1.' + aLoopCls[nI,NOME_CAMPO] $ 't1.PESOCOB//t1.PESOPVC//t1.TES')
					AAdd(aLinha,{ 't1.' + aLoopCls[nI,NOME_CAMPO], aLoopCls[nI,VALOR_CAMPO] })
				EndIf
			next nI
			oSch:addDados(aLinha)
			aLinha := {}
		next nX
	
		if !oSch:schedule():lThisOk
			::lSndEmailOk 	:= .F.
			::lOk 			:= .F.
			::cMsg			:= oSch:cThisMsg
		endif
		RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
	
	FreeObj(oSch)
return (self)


Static Function dataTransf(cDado,cTabela,cCampo)
	cDado := AllTrim(Transform( cDado, PesqPict(cTabela, cCampo)))
return nil

Static Function qry(cQry, oSelf)
	Local oSql 		:= SqlUtil():newSqlUtil()
	Local oRet		:= Nil
	oSelf:lOk 		:= .T.
	oSelf:cMsg 		:= ""
	if oSql:QryToDb(cQry):lOk
		if oSql:nRegCount > 0
			oRet := oSql:oRes
		Else
			oSelf:lOk 	:= .F.
			oSelf:cMsg 	:= "[AVISO] - Consulta não retornou nada!"
		EndIf
	Else
		oSelf:lOk 	:= .F.
		oSelf:cMsg 	:= "[ERRO] -" +  oSql:cMsgErro
	EndIf
	FreeObj(oSql)
Return (oRet)


Static function HandleEr(oErr, oSelf)
	ConsoleLog('[' + oErr:Description + ']' + oErr:ERRORSTACK)
	u_autoAlert('[' + oErr:Description + ']' + oErr:ERRORSTACK,,'Box',,48)
	oSelf:lOk 	:= .F.
	oSelf:cMsg	:= oErr:Description
	BREAK
return


static function ConsoleLog(cMsg)
	ConOut("[Espelho do pedido - "+DtoC(Date())+" - "+Time()+" ] "+cMsg)
return
