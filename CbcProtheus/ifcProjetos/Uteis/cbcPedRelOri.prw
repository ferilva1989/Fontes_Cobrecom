#include 'protheus.ch'
#include 'parmtype.ch'


user function cbcPvOri()
	private oPedBrw		:= nil
	private oHashFilItu := nil	
	private oHashFilTl	:= nil		
	oHashFilItu := HMNew()
	oHashFilTl 	:= HMNew()
	u_cbcQrPRel(@oHashFilItu,@oHashFilTl)
	
	oPedBrw 	:= FWMBrowse():New()
	oPedBrw:SetAlias("SC5")
	oPedBrw:SetMenuDef('')
	oPedBrw:SetProfileID('ZZpVoRI')
	oPedBrw:CleanFilter()
	oPedBrw:AddStatusColumns( {|| iif(mainFilter(), 'BR_AMARELO','BR_VERDE') }, {|| statusLegend()})
	oPedBrw:AddFilter('COM DIVISÃO'	,'staticcall(cbcPedRelOri, mainFilter)' ,.F.,.F.)
	oPedBrw:DisableReport()
	oPedBrw:AddButton('Detalhes', {|| openDet() },,7,)
	oPedBrw:Activate()

	hmClean(oHashFilItu)
	hmClean(oHashFilTl)
	FreeObj(oPedBrw)
	FreeObj(oHashFilItu)
	FreeObj(oHashFilTl)
return(nil)


static function statusLegend()
	local oLegenda  :=  FWLegend():New()
	oLegenda:Add( '', 'BR_AMARELO'  , 'Tem Divisão' )
	oLegenda:Add( '', 'BR_VERDE'   	, 'Não tem Divisão' )
	oLegenda:Activate()
	oLegenda:View()
	oLegenda:DeActivate()
	FreeObj(oLegenda)
return (nil)


static function mainFilter()
	local oValor 	:= nil
	local lRet		:= .F.
	if hmGet(oHashFilItu,SC5->(Recno()),@oValor)
		lRet := .T.
	elseif hmGet(oHashFilTl,SC5->(Recno()),@oValor)
		lRet := .T.
	endif
return(lRet)


static function openDet()
	local oValor 	:= {}
	local nRecFrm	:= SC5->(Recno())
	local nRecTo	:= 0
	local lRet		:= .F.
	if hmGet(oHashFilItu,SC5->(Recno()),@oValor)
		nRecTo :=  oValor
		lRet := .T.
	elseif hmGet(oHashFilTl,SC5->(Recno()),@oValor)
		nRecTo :=  oValor
		lRet := .T.
	endif
	if lRet
		SC5->(DbCloseArea())
		u_vLERelPed(,, .F.,nRecFrm,nRecTo)
		oPedBrw:Refresh()
	else
		msginfo('Pedido sem divisão')
	endif
return(nil)


user function cbcQrPRel(oHashItu,oHashTl)
	
	local cQry 			:= ''
	local oSql			:= nil

	cQry += " SELECT "
	cQry += " SC5ITU.R_E_C_N_O_ AS [REC_ITU], "
	cQry += " SC53L.R_E_C_N_O_ AS [REC_3L] "
	cQry += " FROM  "
	cQry += " ( "
	cQry += " SELECT " 
	cQry += " DISTINCT SC5.C5_NUM			AS [PEDIDO_ITU], "
	cQry += " ISNULL(SC5PV.C5_NUM	, '')	AS [PEDIDO_3L] "
	cQry += " 	FROM  "
	cQry += RetSqlName('SC6') + " SC6 " 
	cQry += " INNER JOIN " + RetSqlName('SC5') + " SC5 "
	cQry += " ON SC6.C6_FILIAL		= SC5.C5_FILIAL "
	cQry += " AND SC6.C6_NUM		= SC5.C5_NUM "
	cQry += " AND SC5.R_E_C_N_O_	= SC5.R_E_C_N_O_ "
	cQry += " AND SC6.D_E_L_E_T_	= SC5.D_E_L_E_T_ "
	cQry += " LEFT JOIN " + RetSqlName('SC6') + " SC6PV "
	cQry += " ON '02'				= SC6PV.C6_FILIAL "
	cQry += " AND SC6.C6_ZZPVORI	= (SC6PV.C6_NUM + SC6PV.C6_ITEM) "
	cQry += " AND SC6PV.R_E_C_N_O_= SC6PV.R_E_C_N_O_ "
	cQry += " AND SC6.D_E_L_E_T_	= SC6PV.D_E_L_E_T_ "
	cQry += " LEFT JOIN " +  RetSqlName('SC5') + " SC5PV "
	cQry += " ON '02'				= SC5PV.C5_FILIAL "
	cQry += " AND SC6PV.C6_NUM		= SC5PV.C5_NUM "
	cQry += " AND SC5PV.R_E_C_N_O_	= SC5PV.R_E_C_N_O_ "
	cQry += " AND SC6PV.D_E_L_E_T_	= SC5.D_E_L_E_T_ "
	cQry += " WHERE  "
	cQry += " SC6.C6_FILIAL IN ('01') "
	cQry += " AND SC6.C6_ZZPVORI NOT IN('') "
	cQry += " AND SC6.R_E_C_N_O_ = SC6.R_E_C_N_O_ "
	cQry += " AND SC6.D_E_L_E_T_ = '' "
	cQry += " ) AS MATRIZ "
	cQry += " INNER JOIN " +  RetSqlName('SC5') + " SC5ITU "
	cQry += " ON '01' = SC5ITU.C5_FILIAL "
	cQry += " AND MATRIZ.PEDIDO_ITU = SC5ITU.C5_NUM "
	cQry += " AND SC5ITU.R_E_C_N_O_ = SC5ITU.R_E_C_N_O_ "	
	cQry += " AND ''				= SC5ITU.D_E_L_E_T_ "
	cQry += " INNER JOIN " + RetSqlName('SC5') + " SC53L " 
	cQry += " ON '02' = SC53L.C5_FILIAL "
	cQry += " AND MATRIZ.PEDIDO_3L	= SC53L.C5_NUM "
	cQry += " AND SC5ITU.R_E_C_N_O_	= SC5ITU.R_E_C_N_O_ "	
	cQry += " AND ''				= SC5ITU.D_E_L_E_T_	 "

	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		hmClean(oHashFilItu)
		hmClean(oHashFilTl)
		oSql:goTop() 
		while oSql:notIsEof()
			HMSet(oHashItu, oSql:getValue("REC_ITU"), oSql:getValue("REC_3L") )
			HMSet(oHashTl, oSql:getValue("REC_3L"), oSql:getValue("REC_ITU") )
			oSql:skip()
		endDo
	endif	
	oSql:close()
	FreeObj(oSql)
return()

