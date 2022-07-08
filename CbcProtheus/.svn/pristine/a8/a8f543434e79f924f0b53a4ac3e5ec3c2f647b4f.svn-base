#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'

// ENDERECAR PRODUTO
user function CREST18(cProd, cLocal, cLocaliz, lShowMsg, nQuant)

	local aRet		:= {.f.,"AGUARDANDO TRANSFERIR"}
	local nB1_COD	:= TamSX3("B1_COD")[1]
	local aSda, aSdb, aAux

	local cQry, nQry

	if select("MNDA") > 0
		MNDA->(dbclosearea())
	endif
	cQry := "SELECT R_E_C_N_O_ NDA FROM " + RETSQLNAME("SDA") + " WHERE D_E_L_E_T_ = ' ' " + CRLF
	cQry += "AND DA_PRODUTO = '" + CPROD + "' " + CRLF
	cQry += "AND DA_LOCAL = '" + CLOCAL + "' " + CRLF
	cQry += "AND DA_SALDO = " + ALLTRIM(STR(NQUANT)) + " " + CRLF
	cQry += "AND DA_FILIAL = '" + XFILIAL("SDA") + "' " + CRLF
	tcquery cqry new alias "MNDA"
	count to nqry
	if nqry > 0
		MNDA->(dbgotop())
		dbselectarea("SDA")
		SDA->(dbgoto(MNDA->NDA))
		aSda := {}
		aadd( aSda ,{"DA_FILIAL"	,SDA->DA_FILIAL 	,})
		aadd( aSda ,{"DA_PRODUTO"	,SDA->DA_PRODUTO	,})
		aadd( aSda ,{"DA_QTDORI"	,SDA->DA_QTDORI		,})
		aadd( aSda ,{"DA_SALDO"		,SDA->DA_SALDO		,})
		aadd( aSda ,{"DA_DATA"		,dDatabase 			,})
		aadd( aSda ,{"DA_LOCAL"		,SDA->DA_LOCAL		,})
		aadd( aSda ,{"DA_ORIGEM"	,SDA->DA_ORIGEM		,})
		aadd( aSda ,{"DA_NUMSEQ"	,SDA->DA_NUMSEQ		,})

		aAux := {}
		aSdb := {}
		aadd( aAux ,{"DB_FILIAL"	,xFilial("SDB")		,})
		aadd( aAux ,{"DB_ITEM" 		,"0001"		 		,})
		aadd( aAux ,{"DB_LOCAL"		,SDA->DA_LOCAL 		,})
		aadd( aAux ,{"DB_LOCALIZ"	,cLocaliz	 		,})
		aadd( aAux ,{"DB_DOC" 		,SDA->DA_DOC 		,})
		// aadd( aAux ,{"DB_TM" 		,"499"		 		,})
		aadd( aAux ,{"DB_ORIGEM"	,"SD3"		 		,})
		aadd( aAux ,{"DB_QUANT"		,SDA->DA_SALDO	 		,})
		aadd( aAux ,{"DB_DATA"		,dDatabase	 		,})
		// aadd( aAux ,{"DB_LOTECTL"	,SDA->DA_LOTECTL	,})
		// aadd( aAux ,{"DB_NUMLOTE"	,SDA->DA_NUMLOTE	,})
		// aadd( aAux ,{"DB_TIPO"		,"D" 		 		,})
		aAdd( aSdb , aAux )

		lMsErroAuto := .F.

		Begin Transaction
			MATA265(aSda,aSdb,3)
			If !lMsErroAuto
			Else
				if lShowMsg
					MostraErro()
				endif
			EndIf
		End Transaction

		aRet[1] := (lMsErroAuto == .f.)
		if aRet[1] == .F.
			aRet[2] := "NAO FOI POSSIVEL ENDERECAR"
		else
			aRet[2] := "OK"
		endif
	else
		aRet[1] := .F.                                     
		aRet[2] := "Produto não localizado para endereçar!!"
		if lShowMsg                                        
			Alert("Produto não localizado para endereçar!!")
		endif
	endif
RETURN aRet
