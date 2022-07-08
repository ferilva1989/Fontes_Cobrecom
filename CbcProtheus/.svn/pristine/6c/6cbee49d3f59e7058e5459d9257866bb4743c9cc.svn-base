#include 'protheus.ch'

/* TEST ZONE */
user function zxBolPort(nRecCli, nRecTit) // u_zxBolPort(29277, 1360937)
	local aTit			:= {}
	local aInst			:= {}
	local oJsBol 		:= JsonObject():new()
	local lRet			:= .T.
	local cSubConta		:= '000'
	private oBol 		:= nil
	private cAliasConf 	:= ''
	private cAliasInstr	:= ''

	SE1->(DbGoTo(nRecTit))
	SA1->(DbGoTo(nRecCli))
	// BOLETOS A RECEBER BRADESCO ITU
	if SE1->(left(Alltrim(E1_CONTA),5)) == '59808'
		cSubConta := '002'
	endif
	aTit 	:= { {SE1->(E1_PREFIXO), SE1->(E1_NUM), SE1->(E1_PARCELA), SE1->(E1_TIPO)} }
	oBol := BOLETOSPROTHEUS():new()
	oBol:SetConfiguracao(SE1->(E1_PORTADO), SE1->(E1_AGEDEP), SE1->(E1_CONTA), cSubConta)
	oBol:SetTitulos(@aTit)
	oBol:PosicionaTabelas(SE1->(E1_PREFIXO), SE1->(E1_NUM), SE1->(E1_PARCELA), SE1->(E1_TIPO))

	//if oBol:IsBoletoOk(SE1->(E1_PREFIXO), SE1->(E1_NUM), SE1->(E1_PARCELA), SE1->(E1_TIPO), .T. )
	SE1->(DbGoTo(nRecTit))
	SA1->(DbGoTo(nRecCli))
	cAliasConf  := oBol:GetAliasConf()
	cAliasInstr := oBol:GetAliasInstr() 

	oJsBol['NumBco'] 	 	:= oBol:GetValue('ZB1_BANCO', cAliasConf) 	+ '-' + oBol:GetValue('ZB1_DIGBCO', cAliasConf) 
	oJsBol['LogoBanco'] 	:= defBancoLogo(oBol:GetValue('ZB1_BANCO', cAliasConf))
	oJsBol['LocalPag'] 	 	:= getValue(cAliasConf,'ZB1_LOCPAG', oBol )
	oJsBol['Vencimento'] 	:= getValue(cAliasConf,'ZB1_VENCTO', oBol )
	oJsBol['Beneficiario'] 	:= getValue(cAliasConf,'ZB1_CEDENT', oBol )
	oJsBol['EndBenef'] 		:= getValue(cAliasConf,'ZB1_ENDCED', oBol )
	oJsBol['AgenCodBenef'] 	:= getValue(cAliasConf,'ZB1_AGEIMP', oBol ) + '/' + getValue(cAliasConf,'ZB1_CODCED', oBol )
	oJsBol['DataDoc'] 		:= getValue(cAliasConf,'ZB1_DTDOC' , oBol )
	oJsBol['NumDoc'] 		:= getValue(cAliasConf,'ZB1_NUMDOC', oBol )
	oJsBol['EspecDoc'] 		:= getValue(cAliasConf,'ZB1_ESPDOC', oBol )
	oJsBol['Aceite'] 		:= getValue(cAliasConf,'ZB1_ACEITE', oBol )
	oJsBol['DtProc']		:= getValue(cAliasConf,'ZB1_DTPROC', oBol )
	oJsBol['NossoNumero']	:= StrTran(getValue(cAliasConf,'ZB1_NOSSON', oBol ), '/','')
	oJsBol['NossoNumeroDv']	:= getValue(cAliasConf,'ZB1_DVNNUM', oBol )
	oJsBol['UsoBanco']		:= getValue(cAliasConf,'ZB1_USOBCO', oBol )
	oJsBol['Carteira']		:= getValue(cAliasConf,'ZB1_CARTEI', oBol )
	oJsBol['Especie']		:= getValue(cAliasConf,'ZB1_ESPECI', oBol )
	oJsBol['Quantidade']	:= getValue(cAliasConf,'ZB1_QUANTI', oBol )
	oJsBol['Valor']			:= getValue(cAliasConf,'ZB1_VALOR' , oBol )
	oJsBol['DocValor']		:= getValue(cAliasConf,'ZB1_VLDOC' , oBol )
	oJsBol['aInst'] 		:= oBol:GetInstrucoes()
	oJsBol['DescAbat']		:= getValue(cAliasConf,'ZB1_DESABA', oBol )
	oJsBol['PagadorLn01']	:= getValue(cAliasConf,'ZB1_SACAD1', oBol )
	oJsBol['PagadorLn02']	:= getValue(cAliasConf,'ZB1_SACAD2', oBol )
	oJsBol['PagadorLn03']	:= getValue(cAliasConf,'ZB1_SACAD3', oBol )
	oJsBol['TextoRecibo']	:= oBol:GetTxtRecibo()
	oJsBol['LinhaDigitavel']:= oBol:GetStrLinDig(oBol:GetStrCodBarras())
	oJsBol['CodBarInt25']	:= oBol:GetStrCodBarras()
	//else
	//lRet := .F.
	//endif
	FreeObj(oBol)
return({lRet, oJsBol})


static function getValue(cAls,cField, oBoleto )
	local cValue	:= ''
	cValue := oBoleto:RunAdvplExpression(oBoleto:GetValue(cField, cAls), 'C')
return(cValue)


static function defBancoLogo(cBanco)
	local cLogo := ''
	if cBanco == '001'
		cLogo := 'logo_brasil'
	elseif cBanco == '341'
		cLogo := 'logo_itau'
	elseif cBanco == '422'
		cLogo := 'logo_safra'
	elseif cBanco == '237'
		cLogo := 'logo_bradesco'
	elseif cBanco == '033'
		cLogo := 'logo_santander'
	endif
return (cLogo)
