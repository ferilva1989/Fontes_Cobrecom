#include 'protheus.ch'
#include 'parmtype.ch'

user function cbcXIdEtq(nRecC5, nRecZE, cPorta, lPrint, nVias)
	local aArea			as array
	local aAreaC5		as array
	local aAreaZE		as array
	local aPrintInfo	as array
	local oMultFil		as object
	local oSql			as object
	local cTamNom		as string
	local cTamDes		as string

	default cPorta  := "LPT1"
	default lPrint	:= .T.
	default nVias	:= GetNewPar('ZZ_VIAXVEN', 4)

	DbSelectArea('SC5')
	DbSelectArea('SZE')
	SC5->(DbGoTo(nRecC5))
	SZE->(DbGoTo(nRecZE))

	if !empty(SC5->(C5_X_IDVEN))
		aArea 		:= Getarea()
		aAreaC5		:= SC5->(GetArea()) 
		aAreaZE 	:= SZE->(GetArea())
		aPrintInfo 	:= {}
		oMultFil 	:= ctrlMultiPedidos():newctrlMultiPedidos()
		if oMultFil:setPedido(nRecC5):isOk()
			oSql := LibSqlObj():newLibSqlObj()
			SC5->(DbGoTo(oMultFil:getMain()))
			cPedido := SC5->(Alltrim(C5_FILIAL) + '/' + Alltrim(C5_NUM))
			oSql:newTable("SA1", "A1_NOME NOME, A1_MUN MUN, A1_EST EST ",;
			"A1_FILIAL = '"  + xFilial('SA1')    + "'" +;
			"AND A1_COD = '" + SC5->(C5_CLIENTE) + "' " +;
			"AND A1_LOJA = '"+ SC5->(C5_LOJACLI) + "' ") 
			if oSql:hasRecords()
				cNomCli := Alltrim(oSql:getValue('NOME'))
				cDest 	:= AllTrim(oSql:getValue('MUN')) + " - " + oSql:getValue('EST') 
				if len(cNomCli) > 30
					cTamNom := "30,20"
				else
					cTamNom := "70,60"
				endif
				if len(cDest) > 19
					cTamDes := "30,20"
				else
					cTamDes := "75,80"
				endif
				aadd(aPrintInfo, {cPedido, "190,200",25,.F.})
				aadd(aPrintInfo, {cNomCli, cTamNom ,12,.F.})
				aadd(aPrintInfo, {cDest, cTamDes,20,.F.})
				aadd(aPrintInfo, {'B' + Alltrim(SZE->(ZE_NUMBOB)),"195,200",0,.F.})
			endif
			oSql:close()
			FreeObj(oSql)
		endif
		FreeObj(oMultFil)
		if lPrint
			u_cbcPrintEti(aPrintInfo,cPorta, nVias)
		endif
		RestArea(aAreaZE)
		RestArea(aAreaC5)
		RestArea(aArea)
	endif
return(aPrintInfo)

user function cbcEtqPVDiv(nRecC6, nRecZE, cPorta, lPrint, nVias)
	local aArea 		:= Getarea()
	local aAreaC5		:= SC5->(GetArea())
	local aAreaC6		:= SC6->(GetArea()) 
	local aAreaZE 		:= SZE->(GetArea())
	local aPrintInfo	:= {}
	local oSql			:= nil
	local cTamNom		:= ""
	local cTamDes		:= ""
	local nRecOri		:= 0

	default cPorta  := "LPT1"
	default lPrint	:= .T.
	default nVias	:= GetNewPar('ZZ_VIAXVEN', 4)

	DbSelectArea('SC6')
	DbSelectArea('SZE')
	SC6->(DbGoTo(nRecC6))
	SZE->(DbGoTo(nRecZE))

	if !empty(SC6->(C6_ZZPVORI))
		aPrintInfo 	:= {}
		nRecOri 	:= getPVOriRec('02', SubStr(AllTrim(SC6->(C6_ZZPVORI)),1,6))
		if !empty(nRecOri)
			oSql := LibSqlObj():newLibSqlObj()
			SC5->(DbGoTo(nRecOri))
			cPedido := SC5->(Alltrim(C5_FILIAL) + '/' + Alltrim(C5_NUM))
			oSql:newTable("SA1", "A1_NOME NOME, A1_MUN MUN, A1_EST EST ",;
			"A1_FILIAL = '"  + xFilial('SA1')    + "'" +;
			"AND A1_COD = '" + SC5->(C5_CLIENTE) + "' " +;
			"AND A1_LOJA = '"+ SC5->(C5_LOJACLI) + "' ") 
			if oSql:hasRecords()
				cNomCli := Alltrim(oSql:getValue('NOME'))
				cDest 	:= AllTrim(oSql:getValue('MUN')) + " - " + oSql:getValue('EST') 
				if len(cNomCli) > 30
					cTamNom := "30,20"
				else
					cTamNom := "70,60"
				endif
				if len(cDest) > 19
					cTamDes := "30,20"
				else
					cTamDes := "75,80"
				endif
				aadd(aPrintInfo, {cPedido, "190,200",25,.F.})
				aadd(aPrintInfo, {cNomCli, cTamNom ,12,.F.})
				aadd(aPrintInfo, {cDest, cTamDes,20,.F.})
				aadd(aPrintInfo, {'B' + Alltrim(SZE->(ZE_NUMBOB)),"195,200",0,.F.})
			endif
			oSql:close()
			FreeObj(oSql)
		endif
		if lPrint
			u_cbcPrintEti(aPrintInfo,cPorta, nVias)
		endif
	endif
	RestArea(aAreaZE)
	RestArea(aAreaC6)
	RestArea(aAreaC5)
	RestArea(aArea)
return(aPrintInfo)

static function getPVOriRec(cFili, cPedido)
	local nRec := 0
	local oSql := LibSqlObj():newLibSqlObj()

	oSql:newTable("SC5", "R_E_C_N_O_ REC",;
			"C5_FILIAL = '"  + cFili    + "' " +;
			"AND C5_NUM = '" + cPedido + "'") 
	if oSql:hasRecords()
		nRec := oSql:getValue('REC')
	endif
	oSql:close()
	FreeObj(oSql)
return(nRec)
