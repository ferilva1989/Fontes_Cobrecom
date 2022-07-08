#include 'protheus.ch'

#define NUM_DE 			1
#define NUM_ATE 		2
#define EMISSAO_DE 		3
#define EMISSAO_ATE		4
#define CLIENTE_DE		5
#define LOJA_DE			6
#define CLIENTE_ATE		7
#define LOJA_ATE		8
#define STATUS_PORTAL 	10


/*/{Protheus.doc} cbcOrcControl
@author bolognesi
@since 15/02/2017
@version 1.0
@type class
@description Classe responsavel por criar array de objetos da classe
cbcOrcModel, em resumo transforma qualquer tabela (ZP5/ZP5 SCJ/SCK SC5/SC6)
em um objeto(model) padronizado, podendo ser utilizados em relatorio e rotinas
/*/
class cbcOrcControl 

	data aParams
	data aObjDct
	data oModel
	data lPergOk
	data aTabHdrCmp
	data cFato 
	data cTabHdr
	data cTabDet
	data cPerg
	data cTabMultDet
	data aTabInner
	data aTabGen
	data aTabWhere
	data aTabDetCmp
	data aTabGenDet
	data aTabInnerDet
	data aCalcCmpHdr
	data aCalcCmpDet
	data cNroDcto
	data cCmpFilial
	data oArea

	method newcbcOrcControl() constructor 
	method setParams()
	method getParams()
	method getTabCmp()
	method setTabHdrCmp()
	method setTabDetCmp()
	method getCmpFromHdr()
	method getInnerHdr()
	method setWhere()
	method getWhere()
	method getCmpWhere()
	method setFato()
	method getFrom()
	method initModel()
	method addModel()
	method getDocument()
	method getHdrCount()
	method prepPortal()
	method getPerg()
	method setPerg()

endclass

/*/{Protheus.doc} newcbcOrcControl
@author bolognesi
@since 15/02/2017
@version 1.0
@param cFato, characters, aceita os valores (orcamento, portal, pedido) definindo
utilizado para selecionar as tabelas adequadas de acordo com o fato principal
@param cNum, characters, Ao inves de mostrar um pergunta para obter dados do fato
informa diretamente o documento a ser criado.
@type method
@description Construtora da classe
/*/
method newcbcOrcControl(cFato, cNum) class cbcOrcControl
	default cFato 	:= ""
	default cNum 	:= ""
	::lPergOk		:= .T.
	::cTabMultDet	:= ""
	::cNroDcto		:= cNum
	::aParams 		:= {}
	::aTabInner		:= {}
	::aTabInnerDet	:= {}
	::aTabGen		:= {}
	::aTabGenDet	:= {}
	::aTabWhere		:= {}
	::aObjDct		:= {}
	::aCalcCmpDet	:= {}
	::aCalcCmpHdr	:= {}
	::setFato(cFato)
	if ::setParams()
		::setTabHdrCmp()
		::setTabDetCmp()
		::setWhere()
		::setPerg()
		::cCmpFilial	:= ""
		::oArea 		:= SigaArea():newSigaArea()
	endif
return(self)

/*/{Protheus.doc} setTabHdrCmp
@author bolognesi
@since 15/02/2017
@version undefined
@type method
@description Configuração principal das informações do cabeçalho
nesta define-se as configurações de campos "de: para:" 
(tabelas(SC5 - ZP5 - SCJ) x propriedades padronizada model)
Configura tambem tipos de relacionamento e campos utilizados nos relacionamentos
/*/
method setTabHdrCmp() class cbcOrcControl
	::aTabHdrCmp := {}
	/*
	1-) S=Campo Select, I=Campo somente Inner, A=Campo inner e Select
	2-) Array com os campos "DE:" das tabelas (ZP5/ZP6, SCJ/SCK, SC5/SC6), 
	para campos que não tenham na tabela mas precisa da propriedade do objeto
	utilizar * para trazer a propriedade em branco para um posterior preenchimento
	3-) "PARA:" Equivalente unico, dos campos da tabela parametro 2 em propriedades
	4-) Quando parametro 1 for (A/I) informar neste os campos relacionamento com as tabelas
	*/
	aadd(::aTabHdrCmp,  {'S', {"CJ_NUM"	  	,"ZP5_NUM" 		},  "AS NUM"			, {}			} )	
	aadd(::aTabHdrCmp,  {'S', {"CJ_EMISSAO"	,"ZP5_DATA"		},  "AS EMISSAO"		, {}			} )
	aadd(::aTabHdrCmp,  {'A', {"CJ_CLIENTE"	,"ZP5_CLIENT"		},  "AS CLIENTE"		, {"A1_COD"} 	} )
	aadd(::aTabHdrCmp,  {'A', {"CJ_LOJA"	,"ZP5_LOJA" 		},  "AS CLI_LOJA"		, {"A1_LOJA"}	} )
	aadd(::aTabHdrCmp,  {'S', {"CJ_ENDENT1"	,"*" 			},  "AS ENTREGA_1"	, {}			} )
	aadd(::aTabHdrCmp,  {'S', {"CJ_ENDENT2"	,"*" 			},  "AS ENTREGA_2"	, {}			} )
	aadd(::aTabHdrCmp,  {'S', {"CJ_TPFRETE"	,"ZP5_FRETE" 		},  "AS TIPO_FRETE"	, {}			} )
	aadd(::aTabHdrCmp,  {'S', {"CJ_TABELA"	,"*" 			},  "AS TABELA_PRECO"	, {}			} )
	aadd(::aTabHdrCmp,  {'A', {"CJ_CONDPAG"	,"ZP5_CONDPG" 	},  "AS COD_COND_PGTO"	, {"E4_CODIGO"} })
	aadd(::aTabHdrCmp,  {'A', {"CJ_VEND1"	,"*" 			},  "AS COD_VEND"		, {"A3_COD"}	} )
	aadd(::aTabHdrCmp,  {'S', {"CJ_DESCPAD"	,"*" 			},  "AS FAIXA_DESC"	, {}			} )
	aadd(::aTabHdrCmp,  {'S', {"CJ_ENTREG"	,"*" 			},  "AS DATA_ENTREGA"	, {}			} )
	aadd(::aTabHdrCmp,  {'S', {"CJ_USERINC"	,"ZP5_RESPON" 	},  "AS USR_INCLUSAO"	, {}			} )
	aadd(::aTabHdrCmp,  {'S', {"CJ_USERALT"	,"*" 			},  "AS USR_ALTERACAO"	, {}			} )
	aadd(::aTabHdrCmp,  {'S', {"CJ_XFTCOBR"	,"*" 			},  "AS CUSTO_COBRE"	, {}			} )
	aadd(::aTabHdrCmp,  {'S', {"CJ_DTINC"	,"*" 			},  "AS DATA_INCLUSAO"	, {}			} )
	aadd(::aTabHdrCmp,  {'S', {"CJ_MOEDA"	,"*" 			},  "AS MOEDA"		, {}			} )
	aadd(::aTabHdrCmp,  {'S', {"CJ_TXMOEDA"	,"*" 			},  "AS TAXA_MOEDA"	, {}			} )
	aadd(::aTabHdrCmp,  {'S', {"CJ_DTALT"	,"*" 			},  "AS DATA_ALTERACAO", {}		} )
	aadd(::aTabHdrCmp,  {'S', {"CJ_PEDCLI"	,"*" 			},  "AS PEDIDO_CLIENTE", {}		} )
	aadd(::aTabHdrCmp,  {'S', {"CJ_OBS"	  	,"ZP5_OBS" 		},  "AS OBSERVACAO"	, {}			} )
	aadd(::aTabHdrCmp,  {'A', {"CJ_TRANSP"	,"*" 			},  "AS COD_TRANSP"	, {"A4_COD"}	} )
	aadd(::aTabHdrCmp,  {'S', {"*"			,"ZP5_STATUS" 	},  "AS STATUS_ORC"	, {}			} )
	aadd(::aTabHdrCmp,  {'S', {"CJ_ZTPVEND"	,"ZP5_VAREJO" 	},  "AS TIPO_VENDA"	, {}			} )
		
	/*
	Definir para cada tabela de relacionamento o tipo do relacionamento
	bem como os campos que devem ser retornados, e suas respectivas propriedades
	correspondentes.
	*/
	aadd(::aTabInner,{'SA1','INNER JOIN', 'A1_FILIAL' } )
	aadd(::aTabGen, " SA1.A1_NOME		AS NOME_CLIENTE" )
	aadd(::aTabGen, " SA1.A1_MUN		AS MUNICIPIO" )
	aadd(::aTabGen, " SA1.A1_EST		AS ESTADO" )
	aadd(::aTabGen, " SA1.A1_TIPO		AS TIPO_CLIENTE" )
	aadd(::aTabGen, " SA1.A1_CGC		AS CGC" )
	aadd(::aTabGen, " SA1.A1_TEL		AS TELEFONE" )

	if ::getFrom('fato') != 'portal'
		aadd(::aTabInner,{'SA3','INNER JOIN', 'A3_FILIAL'} )
		aadd(::aTabGen, " SA3.A3_NOME		AS NOME_VEND" )

		aadd(::aTabInner,{'SA4','LEFT JOIN', 'A4_FILIAL'} )
		aadd(::aTabGen, " SA4.A4_NOME		AS TRANSPORTADORA" )
	else
		aadd(::aCalcCmpHdr, "  ' '  	AS NOME_VEND  " )
		aadd(::aCalcCmpHdr, "  ' '  	AS TRANSPORTADORA  " )
	endif

	aadd(::aTabInner,{'SE4','LEFT JOIN', 'E4_FILIAL'} )
	aadd(::aTabGen, " SE4.E4_DESCRI 		AS COND_PAGTO" )
	aadd(::aTabGen, " SE4.E4_ZMEDPAG		AS MED_COND_PAGTO" )
	aadd(::aTabGen, " SE4.E4_AVISTA			AS COND_VISTA" )

return (self)

/*/{Protheus.doc} setTabDetCmp
//TODO Descrição auto-gerada.
@author bolognesi
@since 16/02/2017
@version 1.0
@type method
@description Configuração principal das informações dos detalhes
nesta define-se as configurações de campos "de: para:" 
(tabelas(SC6 - ZP6 - SCk) x propriedades padronizada model)
Configura tambem tipos de relacionamento e campos utilizados nos relacionamentos
/*/
method setTabDetCmp() class cbcOrcControl
	local lMulti := !empty(::cTabMultDet)
	::aTabDetCmp := {}
	/*
	1-) S=Campo Select, I=Campo somente Inner, A=Campo inner e Select
	2-) Array com os campos "DE:" das tabelas (ZP5/ZP6, SCJ/SCK, SC5/SC6), 
	para campos que não tenham na tabela mas precisa da propriedade do objeto
	utilizar * para trazer a propriedade em branco para um posterior preenchimento
	3-) "PARA:" Equivalente unico, dos campos da tabela parametro 2 em propriedades
	4-) Quando parametro 1 for (A/I) informar neste os campos relacionamento com as tabelas
	*/
	aadd(::aTabDetCmp,  {if(lMulti,'A','S')	, {"CK_NUM"	  	,"ZP6_NUM" 		},  "AS NUM"		, if(lMulti,{"ZP9_NUM"},{}) 	} )	
	aadd(::aTabDetCmp,  {if(lMulti,'A','S') , {"CK_ITEM"	,"ZP6_ITEM" 	},  "AS ITEM"		, if(lMulti,{"ZP9_ITEM"},{})	} )	
	aadd(::aTabDetCmp,  {'S', {"CK_VALOR"	,"*" 			},  "AS VALOR"		, {}			} )
	aadd(::aTabDetCmp,  {'A', {"CK_PRODUTO"	,"ZP9_CODPRO" 	},  "AS COD_PRODUTO", {"B1_COD"	} 	} )
	aadd(::aTabDetCmp,  {'S', {"CK_LANCES"	,"ZP9_QUANT" 	},  "AS LANCES"		, {}			} )
	aadd(::aTabDetCmp,  {'S', {"CK_ACONDIC"	,"ZP6_ACOND" 	},  "AS ACONDIC"	, {}			} )
	aadd(::aTabDetCmp,  {'S', {"CK_METRAGE"	,"ZP6_QTACON" 	},  "AS METRAGE"	, {}			} )
	aadd(::aTabDetCmp,  {'S', {"CK_QTDVEN"	,"ZP9_TOTAL" 	},  "AS QTDVEN"		, {}			} )
	aadd(::aTabDetCmp,  {'S', {"CK_PRCVEN"	,"*" 			},  "AS PRCVEN"		, {}			} )
	aadd(::aTabDetCmp,  {'S', {"CK_XFTPVC"	,"*" 			},  "AS FATOR_PVC"	, {}			} )
	aadd(::aTabDetCmp,  {'S', {"CK_COMIS1"	,"*" 			},  "AS COMIS1"		, {}			} )
	aadd(::aTabDetCmp,  {'S', {"CK_INDICE"	,"*" 			},  "AS INDICE"		, {}			} )
	aadd(::aTabDetCmp,  {'S', {"CK_TES"		,"*" 			},  "AS TES"		, {}			} )
	aadd(::aTabDetCmp,  {'S', {"CK_PRUNIT"	,"*" 			},  "AS PRUNIT"		, {}			} )

	/*
	Definir para cada tabela de relacionamento o tipo do relacionamento
	bem como os campos que devem ser retornados, e suas respectivas propriedades
	correspondentes.
	*/
	if	lMulti
		aadd(::aTabInnerDet,{'ZP9','INNER JOIN', 'ZP9_FILIAL'} )
	endif

	aadd(::aTabInnerDet,{'SB1','INNER JOIN', 'B1_FILIAL'} )
	aadd(::aTabGenDet, " SB1.B1_DESC		AS DESCRICAO" )
	aadd(::aTabGenDet, " SB1.B1_CUSTD3L		AS CUSTD3L" )
	aadd(::aTabGenDet, " SB1.B1_CUSTD		AS CUSTD" )
	aadd(::aTabGenDet, " SB1.B1_PESCOB		AS PESCOB" )
	aadd(::aTabGenDet, " SB1.B1_VALCOB		AS VALCOB" )
	aadd(::aTabGenDet, " SB1.B1_VALPVC		AS VALPVC" )
	aadd(::aTabGenDet, " SB1.B1_PESO		AS PESO" )

	/* 
	Definir os campos que retornam vazios da query, e serão preenchidos
	por algumas das fuções de calculo da classe cbcOrcModel
	*/
	aadd(::aCalcCmpDet, "  ' '  	AS TOTAL_RG_ITEM  " )
	aadd(::aCalcCmpDet, "  ' '  	AS INDICE_ITEM  " )
	aadd(::aCalcCmpDet, "  ' '  	AS VARIACAO_ITEM  " )
	aadd(::aCalcCmpDet, "  ' '  	AS PRC_TAB_BRUTO  " )
	aadd(::aCalcCmpDet, "  ' '  	AS DESCONTOS  " )

return (self)

/*/{Protheus.doc} setWhere
@author bolognesi
@since 15/02/2017
@version 1.0
@type method
@description Definir definir os campos utilizados no (where) da consulta
trabalha em conjunto com os parametros definidos pelo metodo setParams()
possibilita o mapeamento de campos das tabelas (ZP5/ZP6 - SC5/SC6 - SCJ/SCK )
para um nome de propriedade.
/*/
method setWhere() class cbcOrcControl	
	if !empty(::cNroDcto)
		aadd( ::aTabWhere,  { 'hdrTab', {"CJ_FILIAL" 	,"ZP5_FILIAL" }	,"FILIAL" 	} )
		aadd( ::aTabWhere,  { 'hdrTab', {"CJ_NUM" 		,"ZP5_NUM" }	,"NUM" 		} )
		aadd( ::aTabWhere,  { 'hdrTab', {"" 			,"ZP5_STATUS" }	,"STATUS_PORTAL" } )
	else
		aadd( ::aTabWhere,  { 'hdrTab', {"CJ_FILIAL" 	,"ZP5_FILIAL" }	,"FILIAL" 	} )
		aadd( ::aTabWhere,  { 'hdrTab', {"CJ_NUM" 		,"ZP5_NUM" }	,"NUM" 		} )
		aadd( ::aTabWhere,  { 'hdrTab', {"" 			,"ZP5_STATUS" }	,"STATUS_PORTAL" } )
		aadd( ::aTabWhere,  { 'hdrTab', {"CJ_EMISSAO" 	,"ZP5_DATA" }	,"EMISSAO" 	} )
		aadd( ::aTabWhere,  { 'hdrTab', {"CJ_CLIENTE" 	,"ZP5_CLIENT" }	,"CLIENTE" 	} )	
		aadd( ::aTabWhere,  { 'hdrTab', {"CJ_LOJA" 		,"ZP5_LOJA" }	,"LOJA" 	} )
	endif

	aadd( ::aTabWhere,  { 'detTab', {"CK_FILIAL" 		,"ZP6_FILIAL" }	,"FILIAL" 	} )
	aadd( ::aTabWhere,  { 'detTab', {"CK_NUM" 			,"ZP6_NUM" }	,"NUM_ITM" 	} )
return(self)

/*/{Protheus.doc} getCmpWreHdr
@author bolognesi
@since 16/02/2017
@version 1.0
@param cCmp, characters, nome generico para o campo
@param cWho, characters, Tipo do where para  (hdrTab = Tabela Master), (detTab= Tabela detais)
@type method
@description Procura um alias no array ::aTabWhere, retornando
o campo correto de acordo com o fato atual (Orçamento/Pedido/Portal)
/*/
method getCmpWhere(cCmp, cWho) class cbcOrcControl
	local cRet	:= ""
	local nPos	:= 0
	local nPos1	:= 0
	local cTab 	:= ""

	if cWho == 'hdrTab'
		cTab := ::cTabHdr
	elseif cWho == 'detTab'
		cTab := ::cTabDet
	endif

	nPos := AScan(::aTabWhere,{|a| (Alltrim( a[3] ) == Alltrim( cCmp ) .and. Alltrim( a[1] ) == Alltrim(cWho))  })
	if nPos > 0 
		nPos1 := AScan(::aTabWhere[nPos][2],{|a| FWTabPref(a) == cTab   })

		if nPos > 0
			cRet :=  ::aTabWhere[nPos][2][nPos1]
		endif
	endif	
return(cRet)

/*/{Protheus.doc} setParams
@author bolognesi
@since 15/02/2017
@version 1.0
@type method
@description Obter os parametro do usuario para realizar
as consultas
/*/
method setParams() class cbcOrcControl
	local nX			:= 0
	local cExec			:= ""
	local aPerg			:= {}
	local cFato			:= ::getFrom('fato')
	local lRet			:= .T.
	if empty(::cNroDcto)
		if cFato == 'orcamento' .or. cFato == 'portal'
			
			aPerg := ValidPerg( cFato )
			::setPerg(PadR(aPerg[2],Len(SX1->X1_GRUPO)))
			if Pergunte(::getPerg(), .T.)
				for nX := 1 to aPerg[1]
					cExec := 'Mv_Par' + StrZero(nX,2) 
					aadd(::aParams, &cExec )
				next
			else
				lRet := .F.
			endif		
		elseif cFato == 'pedido'
		endif
	endif
	::lPergOk := lRet
return(lRet)

/*/{Protheus.doc} getPerg
@author bolognesi
@since 26/06/2017
@version 1.0
@type method
@description Obter o conteudo da propriedade ::cPerg
/*/
method getPerg() class cbcOrcControl
return(::cPerg)

/*/{Protheus.doc} setPerg
@author bolognesi
@since 26/06/2017
@version 1.0
@param cParam, characters, valor a ser atribuido para propriedade ::cPerg
@type method
@description Atribuir um valor a propriedade ::cPerg
/*/
method setPerg(cParam) class cbcOrcControl
default cParam := ''
::cPerg := cParam
return(self)

/*/{Protheus.doc} getTabHdrCmp
@author bolognesi
@since 15/02/2017
@version 1.0
@type method
@description Obter de forma adequada ao entendimento do SQL, os campos
que deveram ser retornados na consulta ao banco referente ao Header/Tabela Master
/*/
method getTabCmp(cWho) class cbcOrcControl
	local nX		:= 0
	local cQry		:= ""
	local nPos		:= 0
	local cTab 		:= ""
	local aWork		:= {}
	local aGener	:= {}
	local aCalc		:= {}
	local cSqlCmp	:= ""
	local cTipoDad	:= ""

	/*Definir de Header/Detalhes para obter*/ 
	if cWho == 'hdrTab'
		aWork 		:= ::aTabHdrCmp
		aGener		:= ::aTabGen
		cTab		:= ::cTabHdr
		aCalc		:= ::aCalcCmpHdr
	elseif cWho == 'detTab'
		aWork 		:= ::aTabDetCmp
		aGener 		:= ::aTabGenDet
		cTab		:= if(empty(::cTabMultDet),::cTabDet, ::cTabMultDet +'//'+ ::cTabDet )
		aCalc		:= ::aCalcCmpDet
	endif

	cTab := StrTran(StrTran(cTab,'_',''),'.','')
	for nX := 1 to len(aWork)
		/* Adicionar somente os campos do tipo (S e A) evitando mostrar campo somente I=inner */
		if aWork[nX][1] == 'A' .or. aWork[nX][1] == 'S'
			nPos := 0
			nPos := AScan(aWork[nX][2],{|a| FWTabPref(Alltrim(a)) $ Alltrim(cTab)  })
			if nPos > 0
				cSqlCmp := FWTabPref(Alltrim(aWork[nX][2][nPos])) + '.' + Alltrim(aWork[nX][2][nPos])
				cTipoDad := tamSx3(Alltrim(aWork[nX][2][nPos]))[3] 
				if cTipoDad == 'D'
					cQry += ' case when '+ cSqlCmp + " = '' then '' else convert(varchar, cast(  " +  cSqlCmp  + "  AS DATE) ,103) end " +;
					Alltrim(aWork[nX][3]) + ','
				elseif cTipoDad == 'M'
					cQry += " ISNULL(CAST(CAST(" + cSqlCmp + " AS VARBINARY(1024)) AS VARCHAR(1024)),'') " + Alltrim(aWork[nX][3]) + ", " 
				else
					cQry += ' ' + cSqlCmp + ' ' + Alltrim(aWork[nX][3]) + ','
				endif

			else
				nPos := AScan(aWork[nX][2],{|a| Alltrim(a) == '*'  })
				if nPos > 0
					cQry += "' '    " + Alltrim(aWork[nX][3]) + ','
				endif
			endif
		endif
	next nX

	/* Acrescentar os campos genericos das tabelas relacionadas*/
	for nX := 1 to len(aGener)
		cQry += aGener[nX]
		if nX < len(aGener)
			cQry += ','
		endif
	next nX

	/* Acrescentar os campos de calculos quando necessario*/
	for nX := 1 to len(aCalc)
		if nX == 1 .and. (len(aGener) > 0)
			cQry += ' , '
		endif
		cQry += aCalc[nX]
		if nX < len(aCalc)
			cQry += ','
		endif
	next nX
return (cQry)

/*/{Protheus.doc} getWhereHdr
@author bolognesi
@since 15/02/2017
@version 1.0
@type method
@description Obter de forma adequada ao entendimento do SQL, os campos
que deveram ser filtrados na consulta ao banco referente ao Header/Tabela Master
/*/
method getWhere(cWho) class cbcOrcControl
	local cQry 		:= ""
	local cFil		:= ::getCmpWhere('FILIAL'		,cWho)
	local cNum		:= ::getCmpWhere('NUM'			,cWho)
	local cEmissao	:= ::getCmpWhere('EMISSAO'		,cWho)
	local cCliente	:= ::getCmpWhere('CLIENTE'		,cWho)
	local cLoja		:= ::getCmpWhere('LOJA'			,cWho)
	local cTab 		:= ""
	
	cQry += "  WHERE "
	if cWho == 'hdrTab'
		cTab	:= ::cTabHdr 
		cQry 	+=  cTab + "." + cFil +" = '" + xFilial(cTab)    +"' "

		if !empty(::cNroDcto)
			cQry += "	AND  " + cNum + "  = '" + ::cNroDcto + "'"
		else
			cQry += "	AND ("+ cNum  	+ makeRange(::getParams(NUM_DE),::getParams(NUM_ATE))
			cQry += "	AND " + cEmissao	+ makeRange(::getParams(EMISSAO_DE),::getParams(EMISSAO_ATE))
			cQry += "	AND " + cCliente	+ makeRange(::getParams(CLIENTE_DE),::getParams(CLIENTE_ATE))
			cQry += "	AND " + cLoja   	+ makeRange(::getParams(LOJA_DE),::getParams(LOJA_ATE)) + ") " 
		endif
		if Alltrim(::getFrom('fato')) == 'portal' .and. !empty(::getParams(STATUS_PORTAL))
			cQry += "	AND  " + ::getCmpWhere('STATUS_PORTAL',cWho)  + "  = '" + ::getParams(STATUS_PORTAL) + "' "
		endif
		cQry += "  AND " + cTab + ".D_E_L_E_T_	 = ''  "
		cQry += "  ORDER BY " + cTab + "." + Alltrim(cNum) + ' ASC '
	
	elseif cWho == 'detTab'
		cTab	:= ::cTabDet 
		cQry +=   cTab + "." + cFil + " = '" + xFilial(cTab)      +"' "
		cQry += "  AND "+ ::getCmpWhere("NUM_ITM" ,cWho) + "  =  '" + ::oModel:cNum + "'"
		cQry += "  AND " + cTab + ".D_E_L_E_T_	 = ''  "
	endif
return (cQry)

/*/{Protheus.doc} getDocument
@author bolognesi
@since 16/02/2017
@version 1.0
@param cDcto, characters, Informar documento em caso de 
returno unico, sem parametro retorna todos
@type method
@description Retorna o objeto ou array de objeto criado com base no fato
/*/
method getDocument(cDcto) class cbcOrcControl
	local xRet		:= ""
	local nPos		:= 0
	default cDcto 	:= ""
	if empty(cDcto)
		xRet := ::aObjDct
	else
		nPos := AScan(::aObjDct,{|a| Alltrim(a:CNUM) == Alltrim(cDcto)  })
		if nPos >0
			xRet := ::aObjDct[nPos]
		endif
	endif
return(xRet)

/*/{Protheus.doc} getHdrCount
@author bolognesi
@since 20/02/2017
@version 1.0
@type method
@description Obter a quantidade de orçamentos existentes no objeto
::aObjDct 
/*/
method getHdrCount() class cbcOrcControl
	local nRet	:= 0
	nRet := len(::aObjDct)
return (nRet)

/*/{Protheus.doc} getFrom
@author bolognesi
@since 15/02/2017
@version 1.0
@param cWhat, characters, Obter o from de quem (hdrTab = Tabela Master), (detTab= Tabela detais)
@type method
@description Obter string formatada do trecho FROM
enviado ao SQL
/*/
method getFrom(cWhat) class cbcOrcControl
	local cRet		:= ''
	default cWhat 	:= 'fato'	
	if cWhat == 'fato'
		cRet := ::cFato 
	elseif cWhat == 'hdrTab'
		cRet := " FROM " + ' ' +  RetSqlName(::cTabHdr) + ' ' +  ::cTabHdr
	elseif cWhat == 'detTab'
		cRet := " FROM " + ' ' +  RetSqlName(::cTabDet) + ' ' +  ::cTabDet
	endif
return(cRet)

/*/{Protheus.doc} getInnerHdr
@author bolognesi
@since 15/02/2017
@version 1.0
@type method
@description Obter de forma adequada ao entendimento do SQL, os relacionamento
que deveram ser considerados na consulta ao banco referente ao Header/Tabela Master
/*/
method getInnerHdr(cWho) class cbcOrcControl
	local cRet		:= ''
	local nX		:= 0
	local nY		:= 0
	local nZ		:= 0
	local nPos		:= 0
	local nPos1		:= 0
	local aRel		:= {}
	local cPref		:= ""
	local cPref1 	:= ""
	local cCmp1		:= ""
	local cCmp2		:= ""
	local cCmp		:= ""
	local cTab 		:= ""
	local cInne		:= ""
	local nInne		:= 0
	local aWork		:= {}
	local aInner	:= {}
	local cFil		:= ""

	/*Definir de Header/Detalhes para obter*/ 
	if cWho == 'hdrTab'
		aWork 	:= ::aTabHdrCmp
		aInner	:= ::aTabInner
		cTab	:= ::cTabHdr
	elseif cWho == 'detTab'
		aWork 	:= ::aTabDetCmp
		cTab	:= if(empty(::cTabMultDet),::cTabDet, ::cTabMultDet +'//'+ ::cTabDet )
		aInner 	:= ::aTabInnerDet
	endif

	for nX := 1 to len(aWork)
		if aWork[nX][1] == 'A' .or. aWork[nX][1] == 'I'
			if !empty(aWork[nX][4])
				for nY := 1 to len(aWork[nX][4])				
					cPref := FWTabPref( aWork[nX][4][nY] ) 
					nPos1 := AScan(aWork[nX][2],{|a| FWTabPref(Alltrim(a)) $ Alltrim(cTab)  })
					if nPos1 > 0
						cCmp := aWork[nX][2][nPos1] 
						nPos := AScan(aRel,{|a| Alltrim(a[1]) == Alltrim(cPref)  })
						if nPos > 0
							aadd(aRel[nPos][2], { cCmp, aWork[nX][4][nY] } )
						else
							aadd(aRel, {cPref, {{ 	cCmp, aWork[nX][4][nY] }} } )
						endif		
					endif
				next nY
			endif
		endif
	next nX

	for nX := 1 to len(aRel)	
		nInne 	:= AScan(aInner,{|a| Alltrim(a[1]) == Alltrim(aRel[nX][1])  })
		cInne 	:= aInner[nInne][2]
		cFil	:= aInner[nInne][3]
		cRet += " "+ cInne +  " " + RetSqlName(aRel[nX][1]) + ' ' +  aRel[nX][1] + "  "
		cRet += "	ON ' " + xFilial(aRel[nX][1]) +"' = " +  aRel[nX][1] + "." + cFil + "  " 	
		for nY := 1 to len(aRel[nX][2])

			cPref 	:= FWTabPref(aRel[nX][2][nY][1] ) + '.' 
			cPref1 	:= FWTabPref(aRel[nX][2][nY][2] )  + '.'
			cCmp1	:= aRel[nX][2][nY][1]
			cCmp2	:= aRel[nX][2][nY][2]

			cRet += "	AND " + (cPref + cCmp1) + "  = " + (cPref1 + cCmp2)  + " "
		next nY
		cRet += "	AND " + cPref + "D_E_L_E_T_	= " +  cPref1 + "D_E_L_E_T_  "
	next nX
return(cRet)

/*/{Protheus.doc} initModel
@author bolognesi
@since 15/02/2017
@version 1.0
@type method
@description Inicia todo o processo, realizando um select
da tabela master depois para cada resultado obtido realiza um 
select para obter a tabela detais.
/*/
method initModel(cWhat) class cbcOrcControl
	local cQry 	:= ""
	local bErro	:= nil
	default cWhat	:= 'hdrTab'

	BEGIN SEQUENCE
		bErro	:= ErrorBlock({|oErr| HandleEr(oErr, self)})
		cQry += dctCampos(self	,cWhat)	
		cQry += dctFrom(self	,cWhat)
		cQry += dctJoin(self	,cWhat)
		cQry += dctWhere(self	,cWhat)

		//Para cada cabeçalho obter os itens
		if cWhat	== 'hdrTab'
			area('salvar' , self)
			Processa( {||qry(cQry, self, cWhat)}, "Buscando Registros", "Aguarde...", .F.   )
		else
			qry(cQry, self, cWhat)
		endif 
		RECOVER
	END SEQUENCE
	ErrorBlock(bErro) 

	if cWhat	== 'hdrTab'
		area('voltar' , self)
	endif
return(self)

/*/{Protheus.doc} addModel
@author bolognesi
@since 16/02/2017
@version 1.0
@type method
@description Adiciona o Header e Itens de um objeto oModel
ao array de objetos cbcOrcModel
/*/
method addModel() class cbcOrcControl
	if !empty(::oModel:aCabec) .and. !empty(::oModel:aItem)

		//Quando portal, preencher os campos restantes
		if ::getFrom('fato') == 'portal'
			::prepPortal()
		endif

		//Preenchem os campos calculados
		::oModel:CalcCmp()
		aadd(::aObjDct, ::oModel )
	endif
return(self)

/*/{Protheus.doc} prepPortal
@author bolognesi
@since 21/02/2017
@version 1.0
@type method
@description Como a logica do portal(ZP5/ZP6) diferem 
bastante da estrutura (SCK/SCJ), os campos comuns obtivemos
da consulta sql, porem para completar o preenchimento do objeto
precisamos obter o restante dos dados via os metodos do portal
/*/
method prepPortal() class cbcOrcControl
	local oSrvUser		:= nil
	local oUser	 		:= nil	
	local oBudget		:= nil
	local oSeller		:= nil
	local oQuotation	:= nil
	local oSql			:= LibSqlObj():newLibSqlObj()
	local cCli			:= ""
	local cLoja			:= ""
	local cId			:= ""
	local oService		:= CbcQuotationService():newCbcQuotationService()		
	local cLastRev		:= ""
	local aRev			:= {}
	local cDtHrAlt		:= ""
	local cUsrAlt		:= ""
	local cCodVend		:= ""

	if !empty(::oModel:aCabec) .and. !empty(::oModel:aItem)
		/* Obter o objeto quotation */
		cId := ::oModel:aCabec:NUM 
		oQuotation 	:= oService:getById(cId)

		/* Classe cbcBudgetToOrder - metodos uteis*/
		oBudget := cbcBudgetToOrder():newcbcBudgetToOrder()
		/* ENDERECOS DE ENTREGA */
		oBudget:setEndEntrega(oQuotation)
		::oModel:aCabec:ENTREGA_1 := oBudget:getEndEntrega(1)
		::oModel:aCabec:ENTREGA_2 :=oBudget:getEndEntrega(2)
		FreeObj(oBudget)

		/* Obter a data / usuario da ultima alteração, Ultima revisão*/
		aRev := oQuotation:getRevisions() 
		if len(aRev) > 0
			::oModel:aCabec:DATA_ALTERACAO 	:= DtoC(aRev[len(aRev)]:DDATE) + ' - ' + aRev[len(aRev)]:CTIME 
			::oModel:aCabec:USR_ALTERACAO 	:= aRev[len(aRev)]:CNAMEUSER
		endif

		/*  CAMPOS ( USR_INCLUSAO / COD_VEND / NOME_VEND )  */
		oSrvUser	:= CbcUserService():newCbcUserService() 
		oUser	 	:= oSrvUser:findById(::oModel:aCabec:USR_INCLUSAO)
		if oUser:isSeller()
			oSeller :=  oUser:getSeller()
			::oModel:aCabec:COD_VEND 	:= oSeller:CID 
			::oModel:aCabec:NOME_VEND 	:= oSeller:CNAME
			oSql:newTable("SA3", "A3_TABELA TAB_PRC", "%SA3.XFILIAL% AND A3_COD = '"+ oSeller:CID +"'")
			::oModel:aCabec:TABELA_PRECO	:= oSql:getValue("AllTrim(TAB_PRC)")
			FreeObj(oSeller)
		else
			cCli 	:= ::oModel:aCabec:CLIENTE
			cLoja 	:= ::oModel:aCabec:CLI_LOJA
			oSql:newTable("SA1", "A1_VEND SELLER", "%SA1.XFILIAL% AND (A1_COD + A1_LOJA) = '"+ (cCli + cLoja) +"'")
			cCodVend := oSql:getValue("SELLER")
			::oModel:aCabec:COD_VEND := cCodVend 
			oSql:newTable("SA3", "A3_NOME NAME, A3_TABELA TAB_PRC", "%SA3.XFILIAL% AND A3_COD = '"+ cCodVend +"'")
			::oModel:aCabec:NOME_VEND 		:= oSql:getValue("AllTrim(Capital(NAME))")
			::oModel:aCabec:TABELA_PRECO	:= oSql:getValue("AllTrim(TAB_PRC)")
		endif
		::oModel:aCabec:USR_INCLUSAO := oUser:getFullName()

		FreeObj(oSql)
		FreeObj(oSrvUser)
		FreeObj(oUser)

		/* CUSTO_COBRE */
		//TODO originalmente tabbela ZP5 não segue mesma logica das tabelas internas
		::oModel:aCabec:CUSTO_COBRE := GetNewPar('XX_VLRCOB', 21.70)

		/* DATA_ENTREGA*/
		//TODO Pelo portal é obtida somente momentos antes de virar pedido, não diponivel para relatorio

		/* DATA_INCLUSÂO  */
		::oModel:aCabec:DATA_INCLUSAO 	:= ::oModel:aCabec:EMISSAO

		/* FAIXA_DESC */
		//TODO nas tabelas do portal não salva a tabela de preço padrão do momento como SCJ faz
		//Desta forma o relatorio do portal utiliza sempre o desconto padrão da tabela atual
		::oModel:aCabec:FAIXA_DESC := U_DescPad( ::oModel:aCabec:TABELA_PRECO )

		
		/* TRATAMENTO OUTRAS MOEDAS */
		::oModel:aCabec:MOEDA		:= 1
		::oModel:aCabec:TAXA_MOEDA := 1
		
		/* PEDIDO DO CLIENTE */
		//TODO Mesmo motivo data entrega, informação somente na ultima tela.

		/* ACERTAR OS ITENS */
		prepItens(Self, ::oModel:aItem, oQuotation)	

		FreeObj(oQuotation)
	endif
return(self)

/*/{Protheus.doc} setFato
@author bolognesi
@since 15/02/2017
@version 1.0
@param cConteudo, characters, Aceita(orcamento, portal, pedido)
@type method
@description utilizado para definir qual o fato e suas tabelas
/*/
method setFato(cConteudo) class cbcOrcControl
	default cConteudo := ""
	::cFato := cConteudo
	if ::cFato == 'orcamento'
		::cTabHdr 		:= 'SCJ' 
		::cTabDet 		:= 'SCK'
	elseif ::cFato == 'portal'
		::cTabHdr 		:= 'ZP5' 
		::cTabDet 		:= 'ZP6'
		::cTabMultDet 	:= 'ZP9'
	elseif ::cFato == 'pedido'
		::cTabHdr 		:= 'SC5' 
		::cTabDet 		:= 'SC6'
	endif 
return(self)

/*/{Protheus.doc} getParams
@author bolognesi
@since 15/02/2017
@version 1.0
@param nPos, numeric, numero do parametro a ser obtido.
@type method
@description Obter os parametro de acordo com o que foi definido
/*/
method getParams(nPos) class cbcOrcControl
	local cExec 	:= ""
	private xVal	:= ""
	default nPos 	:= 0

	if !empty(nPos)
		xVal := ::aParams[nPos]
		if ValType(xVal) == 'D'
			xVal := DtoS(xVal)
		elseif ValType(xVal) == 'N'
			xVal := cValToChar(xVal)
		endif
	endif

return(xVal)

/* 
Utilizados como proxy para obter os dados hora Tabela master hora tabela detail
*/
static function dctCampos(oSelf, cWho)
	local cCmp := ""
	cCmp += " SELECT "
	cCmp += oSelf:getTabCmp(cWho)
return(cCmp)

static function dctFrom(oSelf, cWho)
	local cFrom := ""
	cFrom += oSelf:getFrom(cWho)
return(cFrom)

static function dctJoin(oSelf, cWho)
	local cJoin := ""
	cJoin := oSelf:getInnerHdr(cWho)
return(cJoin)

static function dctWhere(oSelf, cWho)
	local cWhere	:= ""	
	cWhere := oSelf:getWhere(cWho)
return(cWhere)

/*
Preparar os itens - pois quando vem portal precisa obter
dados via metodos e classe não vem do sql 
*/
static function prepItens(oSelf, aItem, oQuot)
	local nX 		:= 0
	local oSql		:= LibSqlObj():newLibSqlObj()
	local oItm		:= nil
	local cQuery	:= ""
	local cCod		:= ""
	local nPos		:= 0
	local nVlrPvc	:= 0
	oItm 			:= oQuot:getItems() 

	for nX := 1 to len(aItem)
		nPos := AScan(oItm,{|a| (Alltrim( a:getItem() ) == Alltrim( aItem[nX]:ITEM ) )  })
		if nPos > 0 
			aItem[nX]:PRCVEN 	:= if( empty(oItm[nPos]:getAppPrice()),oItm[nPos]:getSugPrice(),oItm[nPos]:getAppPrice())
			aItem[nX]:VALOR 	:= (aItem[nX]:QTDVEN * aItem[nX]:PRCVEN) 
			aItem[nX]:COMIS1	:= if( empty(oItm[nPos]:getSugCommission()),oItm[nPos]:getAppCommission(),oItm[nPos]:getSugCommission())

			if empty(aItem[nX]:FATOR_PVC)
				nVlrPvc	:= Posicione("SB1", 1 ,xFilial("SB1") +;
				Padr(aItem[nX]:COD_PRODUTO, TamSx3('B1_COD')[1] ),"B1_VALPVC")
				if empty(nVlrPvc)
					nVlrPvc := 0
				endif
				aItem[nX]:FATOR_PVC := nVlrPvc      
			endif
		endif
	next nX
	FreeObj(oSql)
return(nil)

/*/{Protheus.doc} area
@author bolognesi
@since 03/03/2017
@version 1.0
@param cOp, characters, O que fazer, salvar ou voltar(restaurar)
@param oSelf,object , Estancia da classe principal
@type function
@description Função para salvar a area de todas as tebelas envolvidas
sempre que adicionar uma tabela em algum lugar neste fonte, adicionar aqui tambem
para preservar a area da tabela
/*/
static function area(cOp, oSelf)
	local cFato 	:= oSelf:getFrom('fato')	
	local aSalvar	:= {}
	local nX		:= 1

	if cOp == 'salvar'
		if !empty( oSelf:cTabHdr )
			aadd(aSalvar, oSelf:cTabHdr )
		endif
		if !empty( oSelf:cTabDet )
			aadd(aSalvar, oSelf:cTabDet )
		endif
		if !empty( oSelf:cTabMultDet )
			aadd(aSalvar, oSelf:cTabMultDet )
		endif
		aadd(aSalvar, 'SB1' )
		aadd(aSalvar, 'SA1' )
		aadd(aSalvar, 'SA3' )
		aadd(aSalvar, 'SA4' )
		aadd(aSalvar, 'SE4' )

		oSelf:oArea:saveArea( aSalvar )	
	elseif cOp == 'voltar
		oSelf:oArea:backArea()
	endif
return(nil)

/*/{Protheus.doc} makeRange
@author bolognesi
@since 26/06/2017
@version 1.0
@param cVal1, characters, Primeiro valor do intervalo
@param cVal2, characters, Segundo valor do intervalo
@type function
@description Função que realiza a formatação e retorno de uma expressão between em sql
/*/
static function makeRange(cVal1,cVal2)
local cRet		:= ''
if empty(cVal1) .and. empty(cVal2)
	cRet := " BETWEEN ' ' AND 'ZZZZZZ' "

elseif !empty(cVal1) .and. empty(cVal2)
	cRet := " BETWEEN '" + cVal1  	 + "'" + " AND " + "'ZZZZZZ' "
else
	cRet := " BETWEEN '" + cVal1  	 + "'" + " AND " + "'" + cVal2 + "' "
endif
return(cRet)

/*/{Protheus.doc} qry
@author bolognesi
@since 15/02/2017
@version 1.0
@param cQry, characters, descricao
@param oSelf, object, descricao
@type function
@description Função que de fato executa a qery no banco
a partir do retorno da query do header, obter as querys dos itens
populando o objeto cbcOrcModel
/*/
static function qry(cQry, oSelf, cTipo)
	local oSql 		:= SqlUtil():newSqlUtil()
	local nX		:= 0
	local nY		:= 0
	local cFato		:= oSelf:getFrom('fato')
	local oRet		:= nil

	//oSelf:oCmbResp:lOk := .T.
	//oSelf:oCmbResp:cMsg := "[OK]"

	if oSql:QryToDb(cQry):lOk
		if oSql:nRegCount > 0	
			oRet	:= oSql:oRes
			if cTipo == 'hdrTab'
				ProcRegua( Len(oRet) )
				for nX := 1 To Len(oRet)
					oSelf:oModel:= cbcOrcModel():newcbcOrcModel(oRet[nX]:NUM)
					oSelf:oModel:aCabec := oRet[nX]
					oSelf:initModel('detTab')
					oSelf:addModel()
					IncProc()
				next nX
			elseif cTipo == 'detTab'
				/*
				for nX := 1 To Len(oRet)
				oRet[nX]:ESP
				next nX
				*/
				oSelf:oModel:aItem := oRet
			endif
		else
			//oSelf:oCmbResp:lOk := .F.
			//oSelf:oCmbResp:cMsg := "[ERRO] - CBC106" //"Consulta não retornou nada"
		endif
	else
		//oSelf:oCmbResp:lOk := .F.
		//oSelf:oCmbResp:cMsg := "[ERRO] - " +  oSql:cMsgErro
	endif
	FreeObj(oSql)
return (nil)

/*/{Protheus.doc} zTxtOrcCtrl
@author bolognesi
@since 15/02/2017
@version 1.0
@type function
@description Função que para testar a classe
/*/
user function zTxtOrcCtrl(cQual) //u_zTxtOrcCtrl('portal')
	local oOrc 			:= nil
	local aDct			:= {}
	local oDct			:= nil
	local nX			:= 0
	local nY			:= 0
	local nSoma			:= 0
	local nComiss 		:= 0
	local nTotPvc		:= 0
	local nPesoCobre 	:= 0
	local nRgItem		:= 0
	local nTot2_5		:= 0
	local nPesTotal		:= 0
	local nTotalCusto	:= 0
	local nIMP			:= 0
	local xVolta		:= ""
	local xCabec		:= ""
	default cQual		:= 'orcamento'

	/*Exemplo de inicialização selecionado os documentos por parametros*/
	oOrc := cbcOrcControl():newcbcOrcControl(cQual) //(orcamento, portal, pedido)
	oOrc:initModel()
	aDct := oOrc:getDocument()
	//Percorrer os documentos
	for nX := 1 to len(aDct)
		aDct[nX]:CNUM

		//Metodos para obter valores e totalizadores
		nSoma 		:= aDct[nX]:sumCmp('QTDVEN')
		nComiss 	:= aDct[nX]:totComiss()
		nTotPvc 	:= aDct[nX]:totPvc()
		nTotVend 	:= aDct[nX]:totVend()
		nPesoCobre	:= aDct[nX]:pesocobre()
		nTot2_5		:= aDct[nX]:tot2_5()
		nPesTotal	:= aDct[nX]:pesoTotal()
		nTotalCusto	:= aDct[nX]:totalCusto()
		nIMP		:= aDct[nX]:getIMP()

		//Obter dados do cabeçalho
		xCabec := aDct[nX]:getHdr('CLIENTE')

		//Percorrer os itens do documento
		//Obtendo os valores dos campos.
		for nY := 1 to len(aDct[nX]:aItem)	
			xVolta := aDct[nX]:getCmp(nY, "DESCRICAO")
		next nY

	next nX

	oDct := oOrc:getDocument('104417')	
	/*Exemplo de inicialização com documento especifico*/
	oOrc := cbcOrcControl():newcbcOrcControl('orcamento', '104417')
	oOrc:initModel()
	aDct := oOrc:getDocument()
	for nX := 1 to len(aDct)
		aDct[nX]:CNUM
		//Exemplo para somar quantidade vendida
		nSoma 		:= aDct[nX]:sumCmp('QTDVEN')
		nComiss 	:= aDct[nX]:totComiss()
		nTotPvc 	:= aDct[nX]:totPvc()
		nTotVend 	:= aDct[nX]:totVend()
		nPesoCobre	:= aDct[nX]:pesocobre()
		nTot2_5		:= aDct[nX]:tot2_5()
		nPesTotal	:= aDct[nX]:pesoTotal()
		nTotalCusto	:= aDct[nX]:totalCusto()
		nIMP		:= aDct[nX]:getIMP()
	next nX
return()


/*/{Protheus.doc} HandleEr
@author bolognesi
@since 19/12/2016
@version 1.0
@param oErr, object, Objeto contendo o erro
@param oSelf, object, Estancia da classe atual
@type function
/*/
Static function HandleEr(oErr, self)
	alert(( .F.,'[ERRO]' ,'[' + oErr:Description + ']', oErr:ERRORSTACK))
	self:oArea:backArea()
	BREAK
return

Static Function ValidPerg(cWho) 
	local aRet			:= {0,""}
	local aRegs			:= {}
	local cPergName     := ''
	
	default cWho 		:= '' 
	cWho := Alltrim(cWho)	
	if !empty(cWho)
		if cWho == "orcamento" 
			cPergName     := "CDFT17"
		elseif cWho == "portal"
			cPergName     := "PORTALORC"
		endif

		_aArea := GetArea()

		DbSelectArea("SX1")
		DbSetOrder(1)
		cPergName := PadR(cPergName,Len(SX1->X1_GRUPO))

		aRegs:={}
		//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
		aAdd(aRegs,{cPergName,"01","Do Orçamento                 ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPergName,"02","Até o Orçamento              ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPergName,"03","Da Data de Emissão           ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPergName,"04","Até a Data de Emissão        ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPergName,"05","Do Cliente                   ?","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SA1"})
		aAdd(aRegs,{cPergName,"06","Da Loja                      ?","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPergName,"07","Até o Cliente                ?","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","SA1"})
		aAdd(aRegs,{cPergName,"08","Até a Loja                   ?","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})		
		aAdd(aRegs,{cPergName,"09","% Felx 2.5             		 ?","mv_ch9","N",01,0,0,"C","","mv_par09","Valor","","","Quantidade","","","","","","","","","","",""})
		if cWho == 'portal'
			aAdd(aRegs,{cPergName,"10","Status Portal            ?","mv_ch10","C",02,0,0,"G","","mv_par10","","","","","","","","","","","","","","","STSPOR"})
		endif

		For i := 1 To Len(aRegs)
			If !DbSeek(cPergName+aRegs[i,2])
				RecLock("SX1",.T.)
				SX1->X1_GRUPO   := aRegs[i,01]
				SX1->X1_ORDEM   := aRegs[i,02]
				SX1->X1_PERGUNT := aRegs[i,03]
				SX1->X1_VARIAVL := aRegs[i,04]
				SX1->X1_TIPO    := aRegs[i,05]
				SX1->X1_TAMANHO := aRegs[i,06]
				SX1->X1_DECIMAL := aRegs[i,07]
				SX1->X1_PRESEL  := aRegs[i,08]
				SX1->X1_GSC     := aRegs[i,09]
				SX1->X1_VALID   := aRegs[i,10]
				SX1->X1_VAR01   := aRegs[i,11]
				SX1->X1_DEF01   := aRegs[i,12]
				SX1->X1_CNT01   := aRegs[i,13]
				SX1->X1_VAR02   := aRegs[i,14]
				SX1->X1_DEF02   := aRegs[i,15]
				SX1->X1_CNT02   := aRegs[i,16]
				SX1->X1_VAR03   := aRegs[i,17]
				SX1->X1_DEF03   := aRegs[i,18]
				SX1->X1_CNT03   := aRegs[i,19]
				SX1->X1_VAR04   := aRegs[i,20]
				SX1->X1_DEF04   := aRegs[i,21]
				SX1->X1_CNT04   := aRegs[i,22]
				SX1->X1_VAR05   := aRegs[i,23]
				SX1->X1_DEF05   := aRegs[i,24]
				SX1->X1_CNT05   := aRegs[i,25]
				SX1->X1_F3      := aRegs[i,26]
				MsUnlock()
				DbCommit()
			Endif
		Next
		RestArea(_aArea)
	endif
	aRet := { Len(aRegs), cPergName }
Return( aRet )