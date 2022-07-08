#include 'protheus.ch'
#include 'parmtype.ch'

user function rptDivergence()
	local cDtInventory	:= ''
	local lExp			:= nil
	local aData			:= {}
	
	if (askParam(@cDtInventory, @lExp))
		aData := fillData(cDtInventory, lExp)
		if !empty(aData)
			makePlan(@aData, cDtInventory, lExp)
		else
			MsgAlert('Não há divergências para serem exibidas! Data do Inventário: ' + DTOC(STOD(cDtInventory)),'Sem dados')
		endif
	endif
return(nil)

static function askParam(cDtInventory, lExp)
	local aPergs	:= {}
	local aRet		:= {}
	local dDateInve	:= dDataBase
	local lRet		:= .T.
	local aOps		:= {'Expedição','Fábrica'}
	
	aAdd( aPergs ,{1,"Data do Inventário: ", dDateInve, PesqPict("SB7","B7_DATA"),'.T.',,'.T.',TamSX3("B7_DATA")[1],.F.})
	aAdd( aPergs ,{3,"Opção:",1,aOps,80,"",.T.})
	if !ParamBox(aPergs, "Parâmetros do Relatório", aRet)      
		Alert("Relatório Cancelado!")
		lRet := .F.
	else
	     cDtInventory := DTOS(MV_PAR01)
	     lExp := (MV_PAR02 == 1)
	endif
return(lRet)

static function fillData(cDtInventory, lExp)
	local oSql 		:= LibSqlObj():newLibSqlObj()
	Local oStatic   := IfcXFun():newIfcXFun()
	local aData		:= {}
	
	oSql:newAlias(oStatic:sP(2):callStatic('qryInventory', 'qryDivergence', cDtInventory, lExp))
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			aAdd(aData, { 	oSql:getValue('FILIAL'),;
							oSql:getValue('PRODUTO'),;
							oSql:getValue('DESCRICAO'),;
							oSql:getValue('ARMAZ'),;
							oSql:getValue('ACONDIC'),;
							(oSql:getValue('QUANT') + oSql:getValue('DEBITA')),;
							oSql:getValue('DEBITA'),;
							oSql:getValue('QUANT'),;
							oSql:getValue('SALDANT'),;
							oSql:getValue('DIFER'),;
							oSql:getValue('KG_COBRE'),;
							if(oSql:getValue('DIFER') > 0, (oSql:getValue('DIFER') * oSql:getValue('KG_COBRE')), 0),; //SOBRA SISTEMA
							if(oSql:getValue('DIFER') < 0, ((oSql:getValue('DIFER') * -1) * oSql:getValue('KG_COBRE')), 0);	//SOBRA FÍSICO							
						})
			oSql:skip()
		endDo
		ASORT(aData, , , { | x,y | (x[08] * x[09]) > (y[08] * y[09])} )
	endif
	oSql:close()
	FreeObj(oSql)
return(aData)

static function makePlan(aData, cDtInventory, lExp)
	local oFWMsExcel := nil
	local nX		 := 1
	local oExcel	 := nil
	local cNomArqv   := GetTempPath() + 'Divergence_' + cDtInventory + "_" + if(lExp, 'PA','FABRICA') + "_" + StrTran(Time(), ':', '-')+ '.xml'
	local cSheet	 := if(FwFilial()== '01','ITU',if(FwFilial()== '02', 'TL','X'))
	local cTable	 := 'Divergência - ' + if(lExp, 'PA','FABRICA') + ' - ' + DTOC(STOD(cDtInventory))
	
	oFWMsExcel := FWMSExcel():New()
	oFWMsExcel:AddworkSheet(cSheet)
    oFWMsExcel:AddTable(cSheet,cTable)
    oFWMsExcel:AddColumn(cSheet,cTable,"Filial",1)
    oFWMsExcel:AddColumn(cSheet,cTable,"Cod.Produto",1)
    oFWMsExcel:AddColumn(cSheet,cTable,"Descrição",1)
    oFWMsExcel:AddColumn(cSheet,cTable,"Armazém",1)
    oFWMsExcel:AddColumn(cSheet,cTable,"Acondic.",1)
    oFWMsExcel:AddColumn(cSheet,cTable,"Contado Original",1)
    oFWMsExcel:AddColumn(cSheet,cTable,"Debitado",1)
    oFWMsExcel:AddColumn(cSheet,cTable,"Contado Debitado",1)
    oFWMsExcel:AddColumn(cSheet,cTable,"Saldo",1)
    oFWMsExcel:AddColumn(cSheet,cTable,"Divergência",1)
    oFWMsExcel:AddColumn(cSheet,cTable,"Fat.Cobre",1)
    oFWMsExcel:AddColumn(cSheet,cTable,"Sobra Saldo",1)
    oFWMsExcel:AddColumn(cSheet,cTable,"Sobra Físico",1)
    
    for nX := 1 to len(aData)
    	oFWMsExcel:AddRow(cSheet,cTable,{;
    										aData[nX, 01],;
    										aData[nX, 02],;
    										aData[nX, 03],;
    										aData[nX, 04],;
    										aData[nX, 05],;
    										aData[nX, 06],;
    										aData[nX, 07],;
    										aData[nX, 08],;
    										aData[nX, 09],;
    										aData[nX, 10],;
    										aData[nX, 11],;
    										aData[nX, 12],;
    										aData[nX, 13];
    									})
    next nX
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cNomArqv)
         
    oExcel := MsExcel():New()
    oExcel:WorkBooks:Open(cNomArqv)
    oExcel:SetVisible(.T.)
    oExcel:Destroy()   
	
	FreeObj(oFWMsExcel)
	FreeObj(oExcel)    
return(nil)
