#include 'totvs.ch'

#define IMPRIME_RESULTADO		1
#define PEDIDO_CONSOLIDADO		2
#define RESULTADO_LIBERACAO	3
#define RESUMO_PRODUTO			4
#define DETALHE_PEDIDO			5
#define AVISOS				6


class cbcRelatLib
	
	method newcbcRelatLib() constructor
	method simulExcel()
	method buscWrong()
	method buscPedInfo()
	method gerLinProd()
	
endclass


method newcbcRelatLib() class cbcRelatLib
return(self)

method simulExcel(oLiber) class cbcRelatLib
	local oExcel 		:= nil
	local oExcelApp	:= nil
	local cPlan		:= "Simulado-" + DtoS(Date()) + StrTran(Time(),':','')
	local cTab		:= "TabelaSimulado"
	local cProdSld	:= "SaldoXProduto"
	local cProdTab	:= "SaldoProduto"
	local cResumoSld	:= "Resumo"
	local cResumoTab	:= "Resumo"
	local cSheetPed	:= 'PedidoVenda'
	local cTabPed		:= 'PedidoVenda'
	local cPthPlan	:= "\ControleEstoque\"
	local cNomPlan	:= "LIB_FAT" + DtoS(Date()) + StrTran(Time(),':','') + ".xml"
	local cPath     	:= "C:\WINDOWS\TEMP\"
	local aLinha		:= {}
	local aLinPed		:= {}
	local aLinProd	:= {}
	local nX			:= 0
	local nY			:= 0
	local nZ			:= 0
	local oPed		:= nil
	local oItem		:= nil
	local lCurva		:= .F.
	local aConfig		:= {}
	
	aConfig := configPar()
	
	if aConfig[IMPRIME_RESULTADO]
		
		oExcel := FWMSEXCEL():New()
		
		if aConfig[PEDIDO_CONSOLIDADO]
			oExcel:AddworkSheet( cResumoSld )
			oExcel:AddTable (cResumoSld, cResumoTab)
			oExcel:AddColumn(cResumoSld, cResumoTab, "PedidoNro",1,1)
			oExcel:AddColumn(cResumoSld, cResumoTab, "Parcial",1,1)
			oExcel:AddColumn(cResumoSld, cResumoTab,"DataFaturamento",2,4)
			oExcel:AddColumn(cResumoSld, cResumoTab,"DataEntrega",2,4)
			oExcel:AddColumn(cResumoSld, cResumoTab, "TotalPedido",3,3)
			oExcel:AddColumn(cResumoSld, cResumoTab, "TotCurvaPedido",3,3)
			oExcel:AddColumn(cResumoSld, cResumoTab, "TotalLiberadoGeral",3,3)
			oExcel:AddColumn(cResumoSld, cResumoTab, "TotalLiberadoRotina",3,3)
			oExcel:AddColumn(cResumoSld, cResumoTab, "TotalCurvaLiberadoRotina",3,3)
		endif
		if aConfig[RESULTADO_LIBERACAO]
			oExcel:AddworkSheet( cPlan )
			oExcel:AddTable (cPlan, cTab)
			oExcel:AddColumn(cPlan, cTab,"PedidoNro",1,1)
			oExcel:AddColumn(cPlan, cTab,"Parcial",1,1)
			oExcel:AddColumn(cPlan, cTab,"DataFaturamento",2,4)
			oExcel:AddColumn(cPlan, cTab,"Item",3,1)
			oExcel:AddColumn(cPlan, cTab,"Produto",3,1)
			oExcel:AddColumn(cPlan, cTab,"Curva",3,1)
			oExcel:AddColumn(cPlan, cTab,"QtdParaEmpenho",3,2)
			oExcel:AddColumn(cPlan, cTab,"QtdLiberadaFat",3,2)
			oExcel:AddColumn(cPlan, cTab,"Observacao",1,1)
		endif
		if aConfig[DETALHE_PEDIDO]
			oExcel:AddworkSheet( cSheetPed )
			oExcel:AddTable (cSheetPed, cTabPed)
			oExcel:AddColumn(cSheetPed, cTabPed,"Parcial",1,1)
			oExcel:AddColumn(cSheetPed, cTabPed,"Curva",1,1)
			oExcel:AddColumn(cSheetPed, cTabPed,"EmissaoPedido",1,4)
			oExcel:AddColumn(cSheetPed, cTabPed,"Pedido",1,1)
			oExcel:AddColumn(cSheetPed, cTabPed,"Item",1,1)
			oExcel:AddColumn(cSheetPed, cTabPed,"FatAPartirDe",1,4)
			oExcel:AddColumn(cSheetPed, cTabPed,"DataEntrega",1,4)
			oExcel:AddColumn(cSheetPed, cTabPed,"Produto",1,1)
			oExcel:AddColumn(cSheetPed, cTabPed,"Descricao",1,1)
			oExcel:AddColumn(cSheetPed, cTabPed,"Acondic",1,1)
			oExcel:AddColumn(cSheetPed, cTabPed,"Lances",1,2)
			oExcel:AddColumn(cSheetPed, cTabPed,"Metragem",1,2)
			oExcel:AddColumn(cSheetPed, cTabPed,"TotalItem",1,3)
			oExcel:AddColumn(cSheetPed, cTabPed,"Qtd.Liberada",1,2)
			oExcel:AddColumn(cSheetPed, cTabPed,"Qtd.Entregue",1,2)
			oExcel:AddColumn(cSheetPed, cTabPed,"Nota",1,1)
			oExcel:AddColumn(cSheetPed, cTabPed,"Observ.Pedido",1,1)
		endif

		for nX := 1 to len(oLiber:aPedido)
			if aConfig[RESULTADO_LIBERACAO]
				aLinPed := {}
				oPed := oLiber:aPedido[nX]
				for nY := 1 to Len(oPed:AITEM)
					aLinha	:= {}
					oItem 	:= oPed:AITEM[nY]
					lCurva 	:= oItem:prodCurva()
					
					aadd(aLinha, oItem:getNroPedido() )
					aadd(aLinha, if(oItem:isParcial(), 'SIM', 'NAO'))
					aadd(aLinha, oItem:getDtFat())
					aadd(aLinha, oItem:getItemPedido())
					aadd(aLinha, Alltrim(oItem:getCodProd()) + Alltrim(oItem:getLocaliz()) )
					aadd(aLinha, if(lCurva , 'SIM', 'NAO'))
					aadd(aLinha, oItem:getQtdEmp() )
					aadd(aLinha, oItem:getQtdOk() )
					aadd(aLinha, oItem:getObsEmp() )
					oExcel:AddRow(cPlan, cTab,aLinha )
				next nY
			endif
			
			if aConfig[DETALHE_PEDIDO]
				::buscPedInfo(@oExcel, oPed, cSheetPed, cTabPed)
			endif
			
			if aConfig[PEDIDO_CONSOLIDADO]
				oPed:estatistica()
				aadd(aLinPed, oPed:getNroPedido())
				aadd(aLinPed, if(oPed:isParcial(), 'SIM', 'NAO'))
				aadd(aLinPed, oPed:getDtFat())
				aadd(aLinPed, oPed:getDtEntr())
				aadd(aLinPed, oPed:nTotGeral)
				aadd(aLinPed, oPed:nTotCurvaGeral)
				aadd(aLinPed, oPed:nTotLibC9)
				aadd(aLinPed, oPed:nLibTotRotina)
				aadd(aLinPed, oPed:nCurvaTotRotina)
				oExcel:AddRow(cResumoSld, cResumoTab,aLinPed )
			endif
			
		next nX
		
		if aConfig[RESUMO_PRODUTO]
			oExcel:AddworkSheet( cProdSld )
			oExcel:AddTable (cProdSld, cProdTab)
			oExcel:AddColumn(cProdSld, cProdTab,"Produto",1,1)
			oExcel:AddColumn(cProdSld, cProdTab,"Tipo",1,1)
			oExcel:AddColumn(cProdSld, cProdTab,"QtdParaLiberar",3,2)
			oExcel:AddColumn(cProdSld, cProdTab,"SaldoTotalProduto",3,2)
			oExcel:AddColumn(cProdSld, cProdTab,"SaldoEmpRotina",3,2)
			oExcel:AddColumn(cProdSld, cProdTab,"SaldoFinalRotina",3,2)
			::gerLinProd(oLiber:aProdNormal, 'Normal', @oExcel, cProdSld, cProdTab)
			::gerLinProd(oLiber:aProdCurva,'Curva', @oExcel, cProdSld, cProdTab)
		endif
		
		if aConfig[AVISOS]
			::buscWrong(@oExcel, oLiber)
		endif
		
		oExcel:Activate()
		oExcel:GetXMLFile(cPthPlan+cNomPlan)
		FreeObj(oExcel)
		
		CpyS2T(cPthPlan+cNomPlan, cPath)
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cPath+cNomPlan)
		oExcelApp:SetVisible(.T.)
		FreeObj(oExcelApp)
	endif
return(nil)


method buscPedInfo(oExcel, oPed, cSheetPed, cTabPed) class cbcRelatLib
	local cProduto	:= ''
	local cLocaliz	:= ''
	local aLinha		:= {}
	local oSql 		:= nil
	local oCurve 		:= nil
	
	oSql 		:= LibSqlObj():newLibSqlObj()
	oSql:newAlias(getQry(oPed:getNroPedido()))
	
	if oSql:hasRecords()
		oSql:goTop()
		oCurve 	:= cbcJsFld():newcbcJsFld()
		while oSql:notIsEof()
			aLinha	:= {}
			cProduto := Alltrim(oSql:getValue("PRODUTO"))
			cLocaliz	:= ''
			cLocaliz += oSql:getValue("ACONDIC")
			cLocaliz += StrZero( oSql:getValue("METRAGE"), 5 )
			
			aadd(aLinha, if(oSql:getValue("ACONDIC") == 'S', 'SIM', 'NAO'))
			aadd(aLinha,if(oCurve:isCurve( cProduto,cLocaliz ),'SIM', 'NAO'))
			aadd(aLinha, oSql:getValue("EMISSAO"))
			aadd(aLinha, oSql:getValue("NUM") )
			aadd(aLinha, oSql:getValue("ITEM"))
			aadd(aLinha, oSql:getValue("DTFAT"))
			aadd(aLinha, oSql:getValue("ENTREG"))
			aadd(aLinha, oSql:getValue("PRODUTO"))
			aadd(aLinha, oSql:getValue("DESCRI"))
			aadd(aLinha, oSql:getValue("ACONDIC"))
			aadd(aLinha, oSql:getValue("LANCES"))
			aadd(aLinha, oSql:getValue("METRAGE"))
			aadd(aLinha, oSql:getValue("VALOR"))
			aadd(aLinha, oSql:getValue("QTDLIB"))
			aadd(aLinha, oSql:getValue("QTDENT"))
			aadd(aLinha, oSql:getValue("NOTA"))
			aadd(aLinha, oSql:getValue("OBS"))
			oExcel:AddRow(cSheetPed, cTabPed, aLinha )
			oSql:Skip()
		enddo
		FreeObj(oCurve)
	endif
	FreeObj(oSql)
return(nil)


method buscWrong(oExcel, oLiber) class cbcRelatLib
	local cSheet		:= 'Avisos'
	local cTabela		:= 'Avisos'
	local nX			:= 0
	local oItem		:= nil
	local aLinha		:= {}
	
	oExcel:AddworkSheet( cSheet )
	oExcel:AddTable (cSheet, cTabela)
	
	oExcel:AddColumn(cSheet, cTabela,'Curva',1,1)
	oExcel:AddColumn(cSheet, cTabela,'Pedido',1,1)
	oExcel:AddColumn(cSheet, cTabela,'Item',1,1)
	oExcel:AddColumn(cSheet, cTabela,'Produto',1,1)
	oExcel:AddColumn(cSheet, cTabela,'Observação',1,1)
	
	for nX := 1  to len( oLiber:getWrgModel() )
		oItem 	:= oLiber:getWrgModel(nX)
		aLinha	:= {}
		aadd(aLinha, if(oItem:prodCurva(),'SIM','NAO'))
		aadd(aLinha, oItem:getNroPedido())
		aadd(aLinha, oItem:getItemPedido())
		aadd(aLinha, Alltrim(oItem:getCodProd()) + Alltrim(oItem:getLocaliz()) )
		aadd(aLinha, oItem:getObsEmp() )
		oExcel:AddRow(cSheet, cTabela, aLinha )
	next nX
	
return(nil)


method gerLinProd(aProd, cTipo, oExcel, cProdSld, cProdTab) class cbcRelatLib
	local aLin 	:= {}
	local nX		:= 0
	for nX := 1 to len(aProd)
		aLin := {}
		aadd(aLin, aProd[nX]:cCodProd )
		aadd(aLin, cTipo )
		aadd(aLin, aProd[nX]:nNecessario )
		aadd(aLin, aProd[nX]:nSldOrig )
		aadd(aLin, aProd[nX]:nSaldo )
		aadd(aLin, aProd[nX]:nSimulSaldo )
		oExcel:AddRow(cProdSld, cProdTab, aLin )
	next nX
return(nil)


static function configPar()
	local aParamBox			:= {}
	local aRet				:= {.F.,.F.,.F.,.F.,.F.,.F.}
	aadd(aParamBox,{4,"Imprimir Relatorio",.T.,"Gerar o relatorio da rotina?",80,'.T.',.F.})
	aadd(aParamBox,{4,"Pedidos Consolidados",.F.,"Totais agrupado por pedidos",80,'.T.',.F.})
	aadd(aParamBox,{4,"Resumo de Liberação",.F.,"Detalhes da liberação",80,'.T.',.F.})
	aadd(aParamBox,{4,"Resumo de Produto/Saldo",.F.,"Saldos dos produtos",80,'.T.',.F.})
	aadd(aParamBox,{4,"Detalhes de Pedidos ",.F.,"Itens dos pedidos",80,'.T.',.F.})
	aadd(aParamBox,{4,"Avisos ",.F.,"Avisos da rotina",80,'.T.',.F.})
	ParamBox(aParamBox,"Relatorio de Liberações",@aRet)
return(aRet)


static function getQry(cNroPed)
	local cQry 		:= ''
	default cNroPed	:= ''
	
	if !empty(cNroPed)
		cQry += " SELECT "
		cQry += " SC5.C5_DTFAT 	AS [DTFAT], "
		cQry += " SC5.C5_EMISSAO 	AS [EMISSAO], "
		cQry += " SC5.C5_OBS 		AS [OBS], "
		cQry += " SC5.C5_PARCIAL 	AS [PARCIAL], "
		cQry += " SC6.C6_NUM		AS [NUM], "
		cQry += " SC6.C6_ITEM      AS [ITEM], "
		cQry += " SC6.C6_ENTREG    AS [ENTREG], "
		cQry += " SC6.C6_PRODUTO   AS [PRODUTO], "
		cQry += " SC6.C6_DESCRI	AS [DESCRI], "
		cQry += " SC6.C6_ACONDIC   AS [ACONDIC], "
		cQry += " SC6.C6_LANCES	AS [LANCES], "
		cQry += " SC6.C6_METRAGE   AS [METRAGE], "
		cQry += " SC6.C6_VALOR	    	AS [VALOR], "
		cQry += " SC6.C6_QTDLIB	AS [QTDLIB], "
		cQry += " SC6.C6_QTDENT	AS [QTDENT], "
		cQry += " SC6.C6_NOTA	    	AS [NOTA] "
		cQry += " FROM  %SC6.SQLNAME% "
		cQry += " INNER JOIN  %SC5.SQLNAME%  "
		cQry += " ON  SC6.C6_FILIAL 	= SC5.C5_FILIAL "
		cQry += " AND SC6.C6_NUM 		= SC5.C5_NUM "
		cQry += " AND SC6.D_E_L_E_T_ 	= SC5.D_E_L_E_T_ "
		cQry += " WHERE %SC6.XFILIAL% "
		cQry += " AND SC6.C6_NUM  = '" + cNroPed + "' "
		cQry += " AND %SC6.NOTDEL%	"
		cQry += " ORDER BY SC6.C6_ITEM ASC "
	endif
return(cQry)
