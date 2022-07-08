#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} AltAlPed
//TODO Criado para que o usuario liberado possa realizar alteração de aliquota do pedido inofrmado.
			Conforme autorização da Sra. Denise em 06/04/2017.
@author juliana.leme
@since 06/04/2018
@version 1.0

@type function
/*/
user function AltAlPed()
	Local aParamBox 	:= {}
	Local aRet			:= ""
	
	aAdd(aParamBox,{1,"Num.Pedido:    ",Space(6)		,""	,""	,""	,""	,040,.F.})
	aAdd(aParamBox,{3,"Tratativa Fiscal: ",1,{"Nacional","Importado"},035,"",.F.})
	
	If !ParamBox(aParamBox, "Parametros", @aRet)
		Return(.F.)
	EndIf

	cPedido 		:= Alltrim(aRet[1])
	nTratFisc		:= aRet[2] //1=Nacional e 2=Importado
	
	If !Empty (cPedido)
		If ApMsgYesNo("Deseja Alterar a Aliquota do pedido " + cPedido + " para "+ Iif(nTratFisc==1,"Nacional "," Importado ") +" ?")
			Processa( {|| AlLiPed(cPedido,nTratFisc) },"Ajustando o Pedido ... Aguarde")
			MsgInfo("Pedido Liberado.","Concluido")
		Else
			MsgBox("Operação cancelada. Processo não realizado.","Atenção","STOP")
			Return()
		EndIf
	Else
		MsgBox("Pedido Não Digitado. Processo não realizado.","Atenção","STOP")
		Return()	
	EndIf	
Return


Static Function AlLiPed(cNumPed,nFiscal)
	If nFiscal==1
		If Len(GetMV("MV_ZZNOFCI")) >= 242
			PutMV("MV_ZZNOFCI",Substr(GetMV("MV_ZZNOFCI"),9,250) +"/"+cNumPed+"/")
		Else
			PutMv("MV_ZZNOFCI",GetMV("MV_ZZNOFCI") +"/"+cNumPed+"/")
		EndIf
	Else
		If Len(GetMV("MV_ZZPVIMP")) >= 242
			PutMV("MV_ZZPVIMP",Substr(GetMV("MV_ZZPVIMP"),9,250) +"/"+cNumPed+"/")
		Else
			PutMv("MV_ZZPVIMP",GetMV("MV_ZZPVIMP") + "/"+cNumPed+"/")
		EndIf
	EndIf
Return