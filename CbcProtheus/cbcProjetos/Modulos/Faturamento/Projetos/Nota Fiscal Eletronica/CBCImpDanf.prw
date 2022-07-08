#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} CBCImpDanf
//TODO Realiza a impressão de Danfe e Exportação de XML fora da rotina do SpedNFe.
@author juliana.leme
@since 16/05/2016
@type function
/*/
user function CBCImpDanf()
	Private AFILBRW 		:= 	{}
	Private cCondicao 		:=	" "
	Private aParamBox  		:= 	{}
	Private aRet  			:= 	{}

	aAdd(aParamBox,{3,"Impressão :",1,{"Danfe"},50,"",.F.})

	While ParamBox(aParamBox, "Processamento", @aRet)
		cCondicao := "F2_FILIAL=='"+xFilial("SF2")+"'"
		AFILBRW	:= {'SF2',cCondicao}
		If aRet[1] == 1
			SpedDanfe()
		Else
			SpedExport()
		EndIf
	EndDo
return