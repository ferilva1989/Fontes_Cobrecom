#include 'protheus.ch'
#include 'parmtype.ch'
#include 'AutomacaoColetas.ch'

class cbcProxyFinVol 
	data aOrdem
	data aResord
	data qtd
	data cInOs
	data cOs
	data cSeq
	data MsgErro
	data lOsOk
	data cOperador
	data cFil

	method newcbcProxyFinVol() constructor

	method vldInfo()
	method FinVolInit()
	method vldZZRSituac()
	method finVolume()

endclass

method newcbcProxyFinVol(cInOs, cOperador) class cbcProxyFinVol
	Local nTamOs 		:= TamSx3("ZZR_PEDIDO")[1]
	Local nTamSeq		:= TamSx3("ZZR_SEQOS")[1]
	Local nTamUsr		:= TamSx3("ZZO_OPER")[1]
	Default cInOs 		:= ""	
	Default cOperador	:= ""

	//Retirar a filial do codigo do Operador
	::cFil := Left(cOperador, 2)
	::cOperador := SubStr(cOperador,3,nTamUsr)

	If Len(cInOs) <> (nTamOs + nTamSeq)
		::lOsOk := .F.
		::cInOs := ""
	Else  
		::lOsOk 		:= .T.
		::cInOs 		:= Padr(cInOs, nTamOs + nTamSeq  )
		::cSeq 			:= StrZero(Val(Right(::cInOs,nTamSeq)),nTamSeq)
		::cOs 			:= StrZero(Val(Left(::cInOs,nTamOs)),nTamOs) 
		::aResord 		:= {}
		::aOrdem 		:= {}
	EndIf
return

method vldZZRSituac() class cbcProxyFinVol
	//TODO fazer função
return .T.

//TODO Validar os itens mudar nome da classe
method vldInfo(oHeader,oItens) class cbcProxyFinVol
	Local lRet		:= .T.
	Local oVldAtt	:= cbcExisteAtt():newcbcExisteAtt() //Validar Atributos da classe
	Local nX		:= 0
	::MsgErro 		:= ""

	If !Empty(oVldAtt:isAtt(oHeader,{'TPVOL','TARA','PESOBRUTO'}))
		::MsgErro := E606
		lRet := .F.

	ElseIf Empty(oHeader:TPVOL) .Or. Empty(oHeader:PESOBRUTO)
		::MsgErro := E607
		lRet := .F.

	ElseIf ValType(oHeader:TARA) <> 'N'
		::MsgErro := E610
		lRet := .F.
	ElseIf ValType(oHeader:PESOBRUTO) <> 'N'
		::MsgErro := E611
		lRet := .F.
	ElseIf ValType(oHeader:TPVOL) <> 'C'
		::MsgErro := E613
		lRet := .F.
	Else
		For nX := 1 To Len(oItens)	
			If !Empty(oVldAtt:isAtt(oItens[nX],{'USR','TP','ID','QTD'}))
				::MsgErro := E608
				lRet := .F.
				exit
			ElseIf Empty(oItens[nX]:TP) .Or. Empty(oItens[nX]:USR) .Or. Empty(oItens[nX]:ID) .Or. Empty(oItens[nX]:QTD)
				::MsgErro := E609
				lRet := .F.
				exit
			ElseIf ValType(oItens[nX]:QTD) <> 'N'
				::MsgErro := E612
				lRet := .F.
				exit
			ElseIf ValType(oItens[nX]:TP) <> 'C'
				::MsgErro := E614
				lRet := .F.
				exit
			ElseIf ValType(oItens[nX]:ID) <> 'C'
				::MsgErro := E615
				lRet := .F.
				exit
			ElseIf ValType(oItens[nX]:USR) <> 'C'
				::MsgErro := E616
				lRet := .F.
				exit
			Else
				//TODO se precisar fazer conversões nos tipos do Itens o lugar e aqui
				oItens[nX]:TP 	:= FwNoAccent(Escape(oItens[nX]:TP)) 
				oItens[nX]:USR	:= FwNoAccent(Escape(oItens[nX]:USR))
				oItens[nX]:ID	:= FwNoAccent(Escape(oItens[nX]:ID))
				oItens[nX]:ID	:= PadR(oItens[nX]:ID, TamSx3('ZZO_BARINT')[1])
				//oItens[nX]:USR	:= PadR(Substr(oItens[nX]:USR,2,6),TamSx3('ZZO_OPER')[1])
				oItens[nX]:USR	:= Substr(oItens[nX]:USR,3,6)

			EndIf
		Next nX
		If lRet
			//TODO se precisar fazer conversões nos tipos do Header o lugar e aqui
			oHeader:TPVOL 		:= FwNoAccent(Escape(oHeader:TPVOL)) 
		EndIf
	EndIf
return lRet

method FinVolInit(apiRes, oRes, oHeader, oItens) class cbcProxyFinVol
	Local nX	 	:=  0
	//OS Vazia
	If  Empty(::cInOs) 
		oRes:sucesso 	:= .F.
		oRes:msg		:= E600
		oRes:body		:= ""
	ElseIf Empty(oHeader)
		oRes:sucesso 	:= .F.
		oRes:msg		:= E600
		oRes:body		:= ""
		//Tamanho Numero OS + Sequencia inválidos
	ElseIf !::lOsOk 
		oRes:sucesso 	:= .F.
		oRes:msg		:= E604
		oRes:body		:= ""
		//Validar Ordem Separação/Status
	ElseIf !::vldZZRSituac()
		oRes:sucesso 	:= .F.
		oRes:msg		:= E601
		oRes:body		:= ""
		//Validar Informações header e itens
	ElseIf !::vldInfo(oHeader,oItens)
		oRes:sucesso 	:= .F.
		oRes:msg		:= ::MsgErro
		oRes:body		:= ""
		//Chamada para função Interna
	ElseIf !::finVolume(oHeader,oItens)
		oRes:sucesso 	:= .F.
		oRes:msg		:= ::MsgErro 
		oRes:body		:= ""
		//Sucesso
	Else
		oRes:sucesso 	:= .T.
		oRes:msg		:= E603
		oRes:body		:= ""	
	EndIf

	apiRes:SetResponse(oRes:toJson())
return

method finVolume(oHeader,oItens) class cbcProxyFinVol
	Local aRet 	:= {}
	::MsgErro	:= ''
	
	/*UTIL PARA DEBUGAR SALVA COLETAS EM DISCO*/
	U_gravarDisco(::cOperador,::cOs,::cSeq,oHeader,oItens)
	
	aRet := U_CDFimVol(::cOperador,::cOs,::cSeq,oHeader,oItens,::cFil) //{.T.,"OK"}
	
	If Valtype(aRet) != 'A' .Or. Empty(aRet)
		aRet := {.F., '[ERRO] - CDFimVol não retornou um Array, ou o Array retornou vazio!'}
	EndIf
	
	If !aRet[1]
		::MsgErro := aRet[2]
	EndIf
	
return aRet[1]
