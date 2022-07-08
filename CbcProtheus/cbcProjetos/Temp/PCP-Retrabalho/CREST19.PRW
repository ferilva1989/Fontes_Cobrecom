#INCLUDE 'PROTHEUS.CH'

// SALDOS INICIAIS
// 08/11/2013 - Robert
*
**********************************************
user function CREST19(cProd, cLocal, lShowMsg)
	**********************************************
	*
	local lRet		:= .F.
	local nB1_COD	:= TamSX3("B1_COD")[1]
	local aSd9

	dbselectarea("SB9")
	SB9->(dbsetorder(1))
	if ! SB9->(dbseek(xFilial("SB9") + padr(cProd,nB1_COD) + cLocal ))	
		aSd9 := {}
		aadd( aSd9 ,{"B9_FILIAL"	,XFILIAL("SB9") 	,})
		aadd( aSd9 ,{"B9_COD"		,CPROD 				,})
		//	aadd( aSd9 ,{"B9_DATA"		,DDATABASE			,})  
		// By Roberto Oliveira - Se não tem SB9 tem que gravar com data branco
		aadd( aSd9 ,{"B9_LOCAL"		,CLOCAL				,})

		lMsErroAuto := .F.

		Begin Transaction
			MATA220(aSd9,3) // Inclusão de saldos iniciais (SB9)
			If !lMsErroAuto
			Else
				if lShowMsg
					MostraErro()
				endif
			EndIf
		End Transaction

		lRet := (lMsErroAuto == .F.) // OK!
	else
		lRet := .T.
	endif

RETURN lRet