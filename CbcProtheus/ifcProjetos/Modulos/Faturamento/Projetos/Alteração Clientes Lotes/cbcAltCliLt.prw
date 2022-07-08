//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "rwmake.ch"
#define BR Chr(10) 

/*/{Protheus.doc} cbcAltCliLt
//TODO Descrição auto-gerada.
@author juliana.leme
@since 06/03/2019
@version 1.0
@type function
/*/
user function cbcAltCliLt()
	local lRet			:= .T.
	local aArea
	local aParamBox 	:= {}
	local aRet			:= ""
	
	aArea := SA1->(GetArea())
	aAdd(aParamBox,{2,"Qual Alteração","Alterar Clientes",{"1 - Alterar Clientes","2 - Bloquear Clientes"},70,"",.T.})
	if !ParamBox(aParamBox, "Parametros", @aRet)
		return(.F.)
	endif
	if ApMsgYesNo("Confirma a operação " + aRet[1] + " ?")
		if substr(aRet[1],1,1) = "1" // Alterar Clientes
			AltCli()
		else
			BlqCli()
		endif
	else
		return()
	endIf
return

/*/{Protheus.doc} AltCli
//TODO Descrição auto-gerada.
@author juliana.leme
@since 01/03/2019
@version 1.0
@type function
/*/
static function AltCli()
	local lRet			:= .T.
	local aParamBox 	:= {}, aCliAlt := {}, aRet	:= {}
	local cCampX3 		:= "", cCampo := ""
	local aDadSA1		:= U_MontaSx("SA1")
	local xInitValue	:= nil
	local cTpFld		:= ''

	aAdd(aParamBox,{2,"Campo de alteração"	,"",aDadSA1	,90,"",.T.})

	if !ParamBox(aParamBox, "Parametros", @aRet)
		return(.F.)
	endIf
	
	if ApMsgYesNo("Confirma a operação " + aRet[1] + " ?")
		cCampo		:= aRet[1]
		cCampX3 	:= U_fArrSx3("SA1",cCampo)[2]
		aParamBox 	:= {}
		aRet		:= {}
		cTpFld		:= GetSx3Cache(AllTrim(cCampX3), 'X3_TIPO')
		xInitValue 	:= setInitValue(cTpFld, TamSX3(cCampX3)[1])
		
		aAdd(aParamBox,{1,"Alteração " + cCampo + ": ", xInitValue, PesqPict('SA1', cCampX3),"","","",100,.T.})

		if !ParamBox(aParamBox, "Parametros", @aRet)
			return(.F.)
		endIf
		FWMsgRun(, {|oSay| U_mkA1Sel(cCampX3, aRet[1]) }, "Aguarde...", "Carregando os Clientes para seleção ...")  
	else
		return(.F.)
	endIf
return

static function setInitValue(cTpFld, nTam)
	local xVal := nil

	if cTpFld == "C" 
 		xVal := Space(nTam)
 	elseif cTpFld == "N" 
 		xVal := 0 
 	elseif cTpFld == "D"  
 		xVal := dDataBase 
 	elseif cTpFld == "M" 
 		xVal := ""
	else
 		xVal := .F.  
	endif  
return(xVal)

/*/{Protheus.doc} BlqCli
//TODO Descrição auto-gerada.
@author juliana.leme
@since 01/03/2019
@version 1.0
@type function
/*/
static function BlqCli()
	local lRet			:= .T.
	local aParamBox 	:= {}, aCliAlt := {}, aRet	:= {}
	local cCampX3 		:= "", cCampo := ""
	local aDadSA1		:= U_MontaSx("SA1")
	local dDataDe		:= Date()
	
	aAdd(aParamBox,{1,'Data Ult. Compra: '  	,dDataDe,PesqPict('SF2','F2_EMISSAO'),"","",".T.",50,.T.})
	if !ParamBox(aParamBox, "Data da Ultima compra para cancelamento ... ", @aRet)
		return(.F.)
	endIf
	
	if ApMsgYesNo("Confirma bloquear todos os clientes com a  " + BR +;
	 			"ultima compra no sistema anterior a "+ DtoC(aRet[1]) + " ?")
		dDataCanc :=  dToS(aRet[1])
		FWMsgRun(, {|oSay| U_BlqCliDt(dDataCanc) }, "Aguarde...", "Realizando bloqueios dos clientes conforme parametro ...")
	else
		return(.F.)
	endif
return
