#include 'protheus.ch'
#Include 'FWMVCDef.ch'
#Define LINHA chr(13) + chr(10)


/*/{Protheus.doc} cbcgfepb
@type function
@author bolognesi
@since 12/07/2018
@description Função para tratamento da questão do peso bruto
na importação de (SF1/SF2) para modulo GFE (GW8), esta função
obtem a quantidade de itens(SD1/SD2) de um documento, e divide
o peso bruto do cabeçalho (PBRUTO) pela quantidade de itens (rateio)
gravando desta forma o campo GW8_PESOR com um rateio do peso bruto.
/*/
user function cbcgfepb(oM)
	local lDo		:= GetNewPar('ZZ_INTEGFE',.T.)
	local oModelGW1	:= nil
	local oModelGW8	:= nil
	local lRet		:= .T.
	local nPBruto		:= 0
	local nX			:= 0
	local aSaveLines	:= {}
	
	if lDo
		oModelGW1 := oM:getModel():getModel("GFEA044_GW1")
		if Alltrim(oModelGW1:GetValue('GW1_ORIGEM')) == "2"
			oModelGW8 := oM
			if ! ( lRet := rateioItem(oModelGW1, @nPBruto) )
				logOcorren('Problema ao obter itens ou peso bruto',oModelGW1,.F.)
			else
				aSaveLines  := FWSaveRows()
				for nX := 1 To oModelGW8:Length()
					oModelGW8:GoLine(nX)
					oModelGW8:LoadValue("GW8_PESOR", nPBruto)
				next nX
				FWRestRows(aSaveLines)
			endif
		endif
	endif
return(lRet)


static function rateioItem(oModelGW1, nPBruto)
	local cTipoDoc	:= ''
	local cFilGW1		:= ''
	local cNroDoc		:= ''
	local cSerDoc		:= ''
	local oSql 		:= nil
	local cQry		:= ''
	local nTotalItem	:= 0
	local nPesoBruto	:= 0
	local lRet		:= .F.
	default nPBruto	:= 0
	
	cFilGW1 			:= oModelGW1:GetValue('GW1_FILIAL')
	cNroDoc			:= oModelGW1:GetValue('GW1_NRDC')
	cSerDoc			:= oModelGW1:GetValue('GW1_SERDC')
	cTipoDoc 		:= oModelGW1:GetValue('GW1_CDTPDC')
	oSql 			:= LibSqlObj():newLibSqlObj()
	
	cQry += " SELECT COUNT(*) AS QTD_ITEM "
	cQry += " FROM "
	if alltrim(cTipoDoc) == 'NFS'
		cQry += " %SD2.SQLNAME% "
		cQry += " WHERE "
		cQry += " SD2.D2_FILIAL 	= '" + cFilGW1 + "' "
		cQry += " AND SD2.D2_DOC 	= '" + cNroDoc + "' "
		cQry += " AND SD2.D2_SERIE = '" + cSerDoc + "' "
		cQry += " AND %SD2.NOTDEL% "
		nPesoBruto	:= SF2->(F2_PBRUTO)
	elseif alltrim(cTipoDoc) == 'NFE'
		cQry += " %SD1.SQLNAME% "
		cQry += " WHERE "
		cQry += " SD1.D1_FILIAL 	= '" + cFilGW1 + "' "
		cQry += " AND SD1.D1_DOC 	= '" + cNroDoc + "' "
		cQry += " AND SD1.D1_SERIE = '" + cSerDoc + "' "
		cQry += " AND %SD1.NOTDEL% "
		nPesoBruto	:= SF1->(F1_PBRUTO)
	endif
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		nTotalItem := oSql:getValue("QTD_ITEM")
	endif
	if (nTotalItem > 0) .and. (nPesoBruto > 0)
		lRet	:= .T.
		nPBruto := (nPesoBruto / nTotalItem)
	endif
	oSql:close()
	FreeObj(oSql)
return(lRet)


static function logOcorren(cMsg, oModelGW1, lOnlyTxt)
	local oSch 		:= cbcSchCtrl():newcbcSchCtrl()
	local cSendTxt	:= ''
	default cMsg 		:= ''
	default oModelGW1	:= nil
	default lOnlyTxt	:= .T.
	
	oSch:setIDEnvio('GFE-INTEG')
	oSch:addEmailTo(GetNewPar('ZZ_GFEWREM','wfti@cobrecom.com.br'))
	oSch:addEmailCc(GetNewPar('ZZ_GFEWRCC','marcelo@cobrecom.com.br'))
	oSch:setAssunto(GetNewPar('ZZ_GFEWRAS','[GFE-INTEG]-Gravação GFEA044 GW8_PESOR'))
	oSch:setSimple( .T. )
	
	if lOnlyTxt
		cSendTxt := cMsg
	else
		cSendTxt += 'Filial:   ' 	+ Alltrim(oModelGW1:GetValue('GW1_FILIAL')) 	+ LINHA
		cSendTxt += 'Nota:     ' 	+ Alltrim(oModelGW1:GetValue('GW1_NRDC')) 	+ LINHA
		cSendTxt += 'TipoDoc:  ' 	+ Alltrim(oModelGW1:GetValue('GW1_CDTPDC')) 	+ LINHA
		cSendTxt += 'Mensagem: ' 	+ Alltrim(cMsg) 	+ LINHA	
	endif
	
	oSch:setBody(cSendTxt)
	oSch:schedule()
	FreeObj(oSch)
	Help( ,, 'GW8_PESOR','Rateio Peso Bruto', cSendTxt ,1,0,,,,,,{'Verificar itens e peso bruto'})
return(nil)
