#Include 'Protheus.ch'
#define CAMPO 1
#define FUNCAO 2


/*/{Protheus.doc} cbcMt020
(long_description)
@type function
@author bolognesi
@since 05/04/2018
@version 1.0
@description Função para validação de campos pertinentes ao cadastro
de fornecedores, recebe como parametro o nome do campo que disparou
a validação, e submete a devida função estatica de validação
/*/
user function cbcMt020(cField)
	local cId		:= 'SA2MASTER'
	local oModel 		:= FWModelActive()
	local aRot		:= {}
	local nPos		:= 0
	private lRet		:= .T.
	private oM		:= oModel:getModel(cId)
	
	default cField	:= ''

	if ! empty(cField)
		// Adcionar campos e funções neste array e tratar validação na função
		aadd(aRot, {'COD_MUN'	, 'vldCodMun(oM,@lRet)'} )
		aadd(aRot, {'TIPO'	, 'vldTipo(oM,@lRet)'} )
		if (nPos :=	ascan(aRot, {|rotina| rotina[CAMPO] == cField  })) > 0
			&(aRot[nPos, FUNCAO])
		endif
	endif
return(lRet)


/*/{Protheus.doc} vldCodMun
(long_description)
@type function
@author bolognesi
@since 05/04/2018
@version 1.0
@description Realiza a validação do campo A2_MUN
/*/
static function vldCodMun(oM, lRet)
	local oSql 	:= nil
	local cMun	:= ''
	local aErro	:= {}
	local nTamA2	:= TamSx3('A2_MUN')[1]

	/* 
		#1 Procura codigo municipio na tabela de municipios CC2, a 
		desrição do municipio atribuindo valor ao campo A2_MUN.
	*/
	oSql 		:= LibSqlObj():newLibSqlObj()
	if empty( cMun := oSql:getFieldValue("CC2", "CC2_MUN",;
			"%CC2.XFILIAL% AND CC2_EST = '" + oM:GetValue( 'A2_EST') + "' AND CC2_CODMUN ='" + oM:GetValue( 'A2_COD_MUN') + "'") )
		help( ,, 'Cadastro Fornecedores',, 'Codigo Municipio inválido.', 1, 0,,,,,,{'Verifique o codigo do municipio.'})
		lRet := .F.
	else
		oM:LoadValue('A2_MUN', left(cMun,nTamA2) ) 
	endif
	FreeObj(oSql)

return(nil)


/*/{Protheus.doc} vldTipo
(long_description)
@type function
@author bolognesi
@since 05/04/2018
@version 1.0
@description Realiza a validaçao com campo A2_TIPO
/*/
static function vldTipo(oM, lRet)
	local cTipo 	:= oM:GetValue('A2_TIPO')
	local cEst	:= oM:GetValue('A2_EST')
	local cDefEst	:= ''
	
	/* 
		#1 Preenche o campo A2_EST de acordo com regra legado.
	*/
	if cTipo == 'X'
		cDefEst := 'EX'
	else
		if cEst == "EX"
			cDefEst := Space(Len(cEst))
		else
			cDefEst := cEst
		endif
	endif
	oM:LoadValue('A2_EST', cDefEst )

return(lRet)
