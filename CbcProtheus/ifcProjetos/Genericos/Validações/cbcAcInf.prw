#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcAcInf(cProd, cLocaliz, nMetragem, nLances, nQtde, lCalcPV, lAlert, lIsProd)
	local aArea    	:= GetArea()
	local aAreaB1	:= SB1->(getArea())
	local aAconInf	:= {}
	local lValid	:= .F.
	local aPesos	:= {}
	local aVolumes	:= {}
	local cAcondic	:= Substr(cLocaliz,1,1)

	default lAlert 	:= .F.
	default lCalcPV := .F.
	default lIsProd	:= .F.

	// Definições Default para Metragem, Qtde e Lances
	if(nMetragem == nil)
		nMetragem := Val(Substr(cLocaliz,2,5))
	endif
	if(nQtde == nil)
		if (nLances == nil)
			nLances := 1
		endif
		nQtde	:= nMetragem * nLances
	endif
	if (nLances == nil)
		nLances := (nQtde / nMetragem)
	endif			
	lValid := getValida(cProd, cAcondic, nMetragem, nLances, nQtde, lAlert, lIsProd)
	if lCalcPV			
		aVolumes	:= getVolumes(cProd, cAcondic, nMetragem, nLances, nQtde)
		aPesos		:= getPeso(cProd, cAcondic, nMetragem, nLances, nQtde,aVolumes)
	endif
	aAdd(aAconInf,lValid)
	aAdd(aAconInf,aPesos)
	aAdd(aAconInf,aVolumes)	
	RestArea(aAreaB1)
	RestArea(aArea) 
return(aAconInf)

static function getValida(cProd, cAcondic, nMetragem, nLances, nQtde, lAlert, lIsProd)
	local lValid 		:= .F.
	local aBlister		:= {}
	
	dbselectArea('SB1')
	SB1->(DbSetOrder(1))
	if (SB1->(DbSeek(xFilial("SB1")+cProd,.F.)))
		if nMetragem <= u_getMaxMetrage(cProd, cAcondic)
			lValid 		:= .T.
			/* INICIO LEGADO (levente modificado)*/
			if cAcondic $ "B"
				if (nMetragem * SB1->B1_PESO) < GetMv("MV_PESMBOB")
					lValid 		:= .F.
					if lAlert
						u_AutoAlert("Materiais em Bobinas somente com peso acima de " + Transform(GetMv("MV_PESMBOB"),"@E 99,999") + " Quilos" + Chr(13) + Chr(13) + "Peso desse material " + Transform((nMetragem * SB1->B1_PESO),"@E 99,999.99") + " Quilos")
					endif						
				endif
			elseif cAcondic $ "L"
				aBlister := validBlister({AllTrim(cAcondic), nMetragem, cProd, nQtde}, lIsProd)
				//[1]-Logic Valid [2]-Err Msg [3]-Arr Info
				if !(aBlister[1])
					lValid := aBlister[1]
					if lAlert
						u_AutoAlert(aBlister[2])
					endIf
				endif								
			elseif cAcondic $ "M" .And. nMetragem # SB1->B1_CARMAD .And. !u_isInd()
				lValid 		:= .F.
				if lAlert
					u_AutoAlert("Esse Produto em Carretel de Madeira tem Metragem Máxima em " + Transform(SB1->B1_CARMAD,"@E 99,999") + " metros")
				endif
			elseif cAcondic $ "C" .And. nMetragem # SB1->B1_CARRETE
				lValid 		:= .F.
				if lAlert
					u_AutoAlert("Esse Produto em Carretel é Obrigatório Metragem Exata em " + Transform(SB1->B1_CARRETE,"@E 99,999") + " metros")
				endif
			endif
			/* FIM LEGADO */
		endif
	endif
return(lValid)

user function getMaxMetrage(cProd, cAcondic)
	local aArea    	  := GetArea()
	local aAreaSB1	  := SB1->(getArea())
	local nMaxMetrage := 0.00
	default cProd 	  := ''	
	
	if !empty(cProd)
		dbselectArea('SB1')
		SB1->(DbSetOrder(1))
		if (SB1->(DbSeek(xFilial("SB1")+cProd,.F.)))
			/* INICIO LEGADO */
			if cAcondic == "R"
				nMaxMetrage := SB1->B1_ROLO
			elseif cAcondic == "B"
				nMaxMetrage := SB1->B1_BOBINA
			elseif cAcondic == "C"
				nMaxMetrage := SB1->B1_CARRETE
			elseif cAcondic == "M"
				nMaxMetrage := SB1->B1_CARMAD
			endif
			/* FIM LEGADO */
		endif
	endif
	if cAcondic == "L"
		nMaxMetrage := getMaxBlister()
	elseif cAcondic == "T"
		nMaxMetrage := 99
	endif
	
	RestArea(aAreaSB1)
	RestArea(aArea)
return(nMaxMetrage)

static function getMaxBlister()
	local aArea    	  := GetArea()
	local aAreaSB1	  := SB1->(getArea())
	local nMaxMetrage := 0
	local aInit		  := BlisterIni()
	local nX		  := 0
	
	for nX := 1 to len(aInit)
		if Val(aInit[nX, 1]) > nMaxMetrage
			nMaxMetrage := Val(aInit[nX, 1])
		endif
	next nX
	RestArea(aAreaSB1)
	RestArea(aArea)
return(nMaxMetrage)

static function getVolumes(cProd, cAcondic, nMetragem, nLances, nQtde)
	local aVolumes 	:= {}
	local aEmb  	:= {0, 0}
	local nAcondxCx	:= 1
	local nQtdVol  	:= 0
	local aBlister  := {}

	if AllTrim(cAcondic) == "L"
		nAcondxCx 	:= 0
		aBlister	:= validBlister({AllTrim(cAcondic), nMetragem, cProd, (nMetragem * nLances)})
		//[1]-Logic Valid [2]-Err Msg [3]-Arr Info
		if aBlister[1]
			nAcondxCx 	:= aBlister[3,5] 
			aEmb 		:= {aBlister[3,6], aBlister[3,7]} //[01]-embalagem blister [02]-caixa unitizadora
			nQtdVol 	:= Int((nLances/nAcondxCx))
		endif
	else
		nQtdVol := nLances
	endif
	aAdd(aVolumes,nQtdVol)
	aAdd(aVolumes,nAcondxCx)
	aAdd(aVolumes,aEmb)
return(aVolumes)


static function getVolTipo(cProd, cAcondic, nMetragem, nLances)
	local cTipoVol 	:= ''
	local aBlister	:= {}
	if AllTrim(cAcondic) == 'L'
		//[1]-Acondic [2]-Metragem [3]-Produto [4]-Quantidade
		aBlister := validBlister({AllTrim(cAcondic), nMetragem, cProd, (nMetragem * nLances)})
		//[1]-Logic Valid [2]-Err Msg [3]-Arr Info
		if aBlister[1]
			cTipoVol := aBlister[3,6]
		endif
	elseif  AllTrim(cAcondic) == 'C'
		cTipoVol := 'CarPlast1'
	elseif  AllTrim(cAcondic) == 'M'
		cTipoVol := 'CarMade1'
	endif
return(cTipoVol)

static function getPeso(cProd, cAcondic, nMetragem, nLances, nQtde, aVolumes)
	local aArea    	  := GetArea()
	local aAreaSB1	  := SB1->(getArea())
	local aPesos	  := {}
	local nPeso 	  := 0.00
	local nPesProd	  := 0.00
	local nPesoTotVol := getVolPeso(cProd, cAcondic, nLances,aVolumes)

	DbSelectArea('SB1')
	nPesProd := Posicione("SB1",1,xFilial("SB1")+ cProd,"B1_PESO")
	nPeso := (nPesProd *  nQtde)
	aAdd(aPesos, nPeso)
	aAdd(aPesos,nPesoTotVol)
	
	RestArea(aAreaSB1)
	RestArea(aArea)
return(aPesos)


static function getVolPeso(cProd, cAcondic, nLances, aVolumes)
	local nPesVol := 0.00

	if !empty(aVolumes)
		nPesVol := (nLances * aVolumes[3,1])+(aVolumes[1] * aVolumes[3,2])
	endif
return(nPesVol)

static function BlisterIni()
	local aIni 		:= {}
	local aRet		:= {}
	local oFormulas := ctrlIniFormul():newctrlIniFormul()
	local cKey  	:= AllTrim(GetNewPar('ZZ_VLDBLIS', 'VALID_BLISTER'))
	local nX		:= 0

	oFormulas:setKeyForm(cKey)
	aRet := oFormulas:getFormulas()
	for nX := 1 to len(aRet)
		aAdd(aIni, &(aRet[nX,3]))
	next nX
	FreeObj(oFormulas)
return(aIni)

static function validBlister(aVld, lIsProd) //[1]-Acondic [2]-Metragem [3]-Produto [4]-Quantidade
	local aRet 			:= {.F.,''}
	local aInit			:= BlisterIni()
	local nPosi			:= 0
	local lVldLances 	:= .T. 
	default nRet 		:= 0
	default lIsProd		:= .F.
	
	//Qdo está na produção não valida os lances. Ex.: Reporte Parcial ou repor estoque
	lVldLances := !lIsProd

	if !(aRet[1] := (len(aVld) == 4))
		aRet[2] := 'Sem Informações para validação!'
	else
		if !(aRet[1] := (Left(aVld[1],1) == "L"))
			aRet[2] := 'Acondicionamento não é Blister - (L)!'
		else
			nPosi := aScan(aInit, {|x| x[1] == cValToChar(aVld[2]);
												.and. x[2] == Left(aVld[3],3); 
												.and. Substr(aVld[3],4,2) $ x[3]; 
												.and. Substr(aVld[3],6,2) $ x[4]})
			if (aRet[1] := !(nPosi  == 0))
				if lVldLances
					if !(aRet[1] := ( Mod((aVld[4] / aVld[2]), aInit[nPosi, 5]) == 0))
						aRet[2] := 'Quantidade Inválida! Lances devem ser múltiplos de: ' + cValToChar(aInit[nPosi, 5]) + '.'
					endif
				endif
				if aRet[1]		
					aAdd(aRet, aInit[nPosi])
				endif
			else
				aRet[1] := .F.
				if (aScan(aInit, {|x| x[1] == cValToChar(aVld[2])}) == 0)
					aRet[2] := 'Metragem Inválida para acondicionamento Blister - (L)!'
				else				
					if (aScan(aInit, {|x| x[1] == cValToChar(aVld[2]); 
											.and. x[2] == Left(aVld[3],3)}) == 0)
						aRet[2] := 'Família Inválida para acondicionamento Blister - (L)!'
					else
						if (aScan(aInit, {|x| x[1] == cValToChar(aVld[2]);
											.and. x[2] == Left(aVld[3],3); 
											.and. Substr(aVld[3],4,2) $ x[3]}) == 0)
							aRet[2] := 'Família + Bitola Inválida para acondicionamento Blister - (L)!'
						else
							aRet[2] := 'Família + Bitola + Cor Inválida para acondicionamento Blister - (L)!'
						endif
					endif
				endif
			endif
		endif
	endif
return(aRet)


/*TEST ZONE*/
user function tstAcInf(cProd, cLocaliz, nMetragem, nLances, nQtde)
	local aRet 			:= {}
	local linha			:= chr(13) + chr(10)
	default nMetragem 	:= Val(Substr(cLocaliz,2,5))
	default nLances	  	:= 1
	default nQtde	  	:= (nMetragem * nLances)

	aRet := u_cbcAcInf(cProd, cLocaliz, nMetragem, nLances, nQtde, .T., .T.)
	
	if !empty(aRet)
		MsgInfo('Valido: ' + cValToChar(aRet[1]) + linha +;
		'Peso Liq. Produto: ' + cValTochar(aRet[2,1]) + ' Peso com Embalagem: ' + cValTochar(aRet[2,2]) + linha +;
		'Qtd.Vol: ' + cValTochar(aRet[3,1]) + ' Qtd. Cx: ' + cValTochar(aRet[3,2]) + ' Peso Emb.: ' + cValTochar(aRet[3,3,1]) + ' Peso Unit.: ' + cValTochar(aRet[3,3,2]);
		,'Resultado')
	endif
return(nil)
