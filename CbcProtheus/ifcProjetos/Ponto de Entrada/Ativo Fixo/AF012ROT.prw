#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'

/*/{Protheus.doc} AF012ROT
//TODO Inclusão da rotina de Importação dos Ativos através de planilha.
@author juliana.leme
@since 16/01/2019
@version 1.0
@type function
/*/
User Function AF012ROT()
	local aNewRotina := PARAMIXB[1]

	ADD OPTION aNewRotina TITLE "Importar Planilha" ACTION "U_CbImpATF()" OPERATION 7 ACCESS 0
Return aNewRotina