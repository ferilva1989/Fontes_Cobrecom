#Include 'Protheus.ch'
#include 'FWMVCDEF.CH'


/*/{Protheus.doc} CUSTOMERVENDOR
(long_description)
@type function
@author bolognesi
@since 23/03/2018
@description Ponto entrada MVC MATA020 - Cadastro de Fornecedores
/*/
user Function CUSTOMERVENDOR()
	local lRet 	:= .T.
	local aParam 	:= PARAMIXB
	local cId	:= 'SA2MASTER'
	local nOper	:= 0
	Local nOpcao := 0
		

	if aParam[2] == 'MODELVLDACTIVE'
		if ! ctrlAcesso( aParam[1] )
			lRet := .F.
		else
			seqA2Cod(@aParam, cId)
		endif
	elseif aParam[2] == 'MODELCOMMITNTTS'
		ConfirmSx8()
	ElseIf aParam[2] == 'FORMCOMMITTTSPRE'	
		If aParam[1]:GetOperation() == MODEL_OPERATION_INSERT
			nOpcao := 3 //inclusão
			ItemCTB(@aParam, nOpcao)			
		ElseIf aParam[1]:GetOperation() == MODEL_OPERATION_DELETE
			nOpcao := 5 //exclusão
			ItemCTB(@aParam, nOpcao)				
		EndIf
	endif
return(lRet)


/*/{Protheus.doc} seqA2Cod
(long_description)
@type function
@author bolognesi
@since 23/03/2018
@version 1.0
@description Definições para controle de
numero sequencial do campo A2_COD
/*/
static function seqA2Cod(aParam, cId)
	local cSeq		:= ''
	local oM			:= nil
	cSeq 			:= GETSXENUM('SA2', 'A2_COD')
	oM 	 			:= aParam[1]:GetModel(cId)
	oM:oFormModelStruct:SetProperty('A2_COD', MODEL_FIELD_INIT, {||cSeq}  )
	aParam[1]:bcancel := {|oModel| U_rollB020(oModel)}
return(nil)


/*/{Protheus.doc} ctrlAcesso
(long_description)
@type function
@author bolognesi
@since 27/03/2018
@description Permitir Acesso completo as opções do cadastro quando
usuario estiver no grupo 000089 -(Grupo que edita fornecedores), os outros
permitido apenas visualizar.
/*/
static function ctrlAcesso(oModel)
	local lRet	:= .T.
	local nOper	:= oModel:nOperation
	local oAcl	:= cbcAcl():newcbcAcl()
	local lBckAutoMode := _SetAutoMode()

	if IsInCallStack('MATA984')
		_SetAutoMode(.F.)
	endif
	if nOper <> 1
		if !oAcl:aclValid('Mata020')
			FwClearHLP()
			help( ,, 'Controle de Acesso',, 'Acesso não permitido.', 1, 0,,,,,,{'Permitido apenas visualização.'})
			lRet := .F.
		endif
	endif
	if lBckAutoMode <> _SetAutoMode()
		_SetAutoMode(lBckAutoMode)
	endif
	FreeObj(oAcl)
return(lRet)


/*/{Protheus.doc} rollB020
(long_description)
@type function
@author bolognesi
@since 23/03/2018
@version 1.0
@description Rotinas MVC não executam RollBackSX8
quando tratamento sequencial é por SXE/SXF (nosso caso)
desta forma interferimos no fechamento da tela para realizar o rollback
/*/
user function rollB020(oModel)
	Local oStatic   := IfcXFun():newIfcXFun()
	RollBackSx8()
	oStatic:sP(1):callStatic('MATA020','A020cancel', oModel)
return(.T.)



/*/{Protheus.doc} ItemCTB
@author alexandre.madeira
@since 11/04/2018
@version 1.0
@param aParam, array, descricao
@param nOpcao, numeric, descricao
@description Cria ou exclui o item contabíl ligado ao Fornecedor, por meio do execauto CTBA040
/*/
static function ItemCTB(aParam, nOpcao)
	Local oObjForm
	Local aDados 		:= {}
	Local dData  		:= ctod("01/01/80")
	Local cItem 		:= ""
	Local oExec 		:= Nil 
	Local aRet			:= {}
	
	oObjForm := aParam[1]
	
		
	cItem := Alltrim("F"+oObjForm:GetValue('A2_COD')+oObjForm:GetValue('A2_LOJA'))
		
			aadd(aDados,{"CTD_ITEM"    	,cItem 		,Nil})
			aadd(aDados,{"CTD_DESC01"   ,oObjForm:GetValue('A2_NOME'),Nil})
			aadd(aDados,{"CTD_CLASSE"   ,"2"			,Nil})
			aadd(aDados,{"CTD_NORMAL"   ,"1"			,Nil})
			aadd(aDados,{"CTD_DTEXIS"   ,dData 		,Nil})
			aadd(aDados,{"CTD_ITSUP"   	,"F"			,Nil})
			
			Begin Transaction
			oExec := cbcExecAuto():newcbcExecAuto(aDados,/*aHdr*/,.T.)
			oExec:exAuto('CTBA040',nOpcao)
			//MSExecAuto({|x,y| CTBA040(x,y)},aDados,3)
			aRet := oExec:getRet()			
			If !aRet[1]
				If nOpcao == 3
					cMsg := " inclusão "
				Else
					cMsg := " exclusão "
				EndIf
				Alert("Erro na" + cMsg + "do Item Contabil")
				DisarmTransaction()
			ElseIF nOpcao == 3				
				oObjForm:SetValue("A2_ZZITEM", Padr(cItem,TamSX3("A2_ZZITEM")[1]))
			EndIf
			End Transaction	
return Nil
