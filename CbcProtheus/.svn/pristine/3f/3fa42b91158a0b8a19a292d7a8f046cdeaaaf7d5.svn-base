#Include 'Protheus.ch'
#include "TOPCONN.ch"

/*/{Protheus.doc} cbMta010
@author bolognesi
@since 02/04/2018
@version 1.0
@type function
@description Função que realiza o preenchimento do campo
B1_COD, de acordo com os preenchimentos dos campos:
(B1_NOME + B1_BITOLA + B1_COR + B1_CLASENC + B1_ESPECIA)
Função reescrita para MVC tendo como base o fonte legado CDGENG02
antes utilizado no gatilho, devido ao campo B1_COD não ser editavel
o MVC não valida o preenchimento por gatilho, desta forma migramos a função
para validação dos campos, reproduzindo o mesmo efeito do gatilho.
/*/
User Function cbMta010(cFrm)
	local lRet		:= .T.
	local cCod		:= ''
	local cId		:= 'SB1MASTER'
	local lIsPa		:= .F.
	local oModel 		:= FWModelActive()
	local oM			:= oModel:getModel(cId)
	default cFrm		:= ''

	if Empty(cFrm)

		lIsPa 	:= ( oM:GetValue('B1_TIPO' ) == 'PA')
		cCod 	:= oM:GetValue('B1_NOME' )
		cCod 	+= if(lIsPa, oM:GetValue( 'B1_BITOLA')	, oM:GetValue( 'B1_COR') )
		cCod 	+= if(lIsPa, oM:GetValue( 'B1_COR')		, oM:GetValue( 'B1_FORNECE') )
		cCod 	+= if(lIsPa, oM:GetValue( 'B1_CLASENC')	, "0")
		cCod 	+= if(lIsPa, oM:GetValue( 'B1_ESPECIA')	, oM:GetValue( 'B1_IDENTIF') )
	
	elseif cFrm == 'GRP' .and. !(oM:GetValue( 'B1_TIPO') $ "PA,MP,PI")
		cCod := NextCode(oM:GetValue( 'B1_GRUPO'))
	elseif cFrm == 'TMP' .and. oM:GetValue('B1_TIPO' ) == 'MP'
		oM:LoadValue('B1_FORNECE', "00" )
		oM:LoadValue('B1_IDENTIF', "00" )
	endif
	
	if ! empty(cCod)
		oM:LoadValue('B1_COD', cCod )
	endif
Return(lRet)


/*/{Protheus.doc} NextCode
(long_description)
@type function
@author bolognesi
@since 02/04/2018
@description Substitui a função legado CDGENG03 que atribui um numero sequencial
para Produtos que o Tipo for diferente de "MP/PI/PA" Juliana - 26/12/2014, antes chamado
pelo gatilho do campo B1_GRUPO, agora pela validação deste campo.  
/*/
static function NextCode(cGrupo)

	local _nNum     	:= ""
	local _cCod		:= ""
	local cQuery    	:= ""
	
	cGrupo := Alltrim(cGrupo)
	   
	cQuery := " SELECT MAX(B1_COD) CODIGO FROM " + RetSqlName("SB1") + "  WHERE B1_COD LIKE '" + cGrupo + "%' "
	cQuery += " AND D_E_L_E_T_ = '' "
	cQuery += " AND B1_GRUPO = '" + cGrupo + "' "

	TcQuery cQuery New Alias "TRB"

	dbSelectArea("TRB")
	TRB->(dbGoTop())

	if Alltrim(TRB->CODIGO) = ""
		_cCod :=  cGrupo + "000001"
	else
		_nNum := Val(SubStr(TRB->CODIGO,5,10)) + 1
		_cCod  := cGrupo + StrZero(_nNum,6)
	endIf

	TRB->(dbCloseArea())
	
return(_cCod)
