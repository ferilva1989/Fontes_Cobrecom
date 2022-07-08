
/*/{Protheus.doc} MATUCOMP
//TODO Quando se referir aos complementos para geracao dos registros C110, C111, C112, C113, C114 e C115
	a tabela CDT também deve ser alimentada, pois ela que efetua o relacionamentos com as outras 
	conforme registro. C110 = Tab. CDT, C111 = Tab. CDG, , C112 = Tab. CDC, C113 = Tab. CDD, 
	C114 = Tab. CDE e C115 = Tab. CDF.
@author juliana.leme
@since 25/07/2017
@version 1.0

@type function
/*/
User Function MATUCOMP()
	Local lExiste 		:= .F.
	Local _aArea 		:= GetArea()
	Local cDocRefer		:= ""
	Local cSerRefer		:= ""
	Local cCliForRef	:= ""
	Local cLojCliForRef	:= ""
	Local cChaveNfe 	:= ""
	
	cEntSai := ParamIXB[1]
	cDoc	:= ParamIXB[3]
	cSerie	:= ParamIXB[2]
	cCliefor:= ParamIXB[4]
	cLoja 	:= ParamIXB[5]
	
	lExiste := CDT->(dbSeek(xFilial("CDT")+cEntSai+cDoc+cSerie+cClieFor+cLoja))

	If lExiste
		RecLock("CDT",.F.)
		CDT->CDT_IFCOMP := "000001"
	Else
		RecLock("CDT",.T.)
		CDT->CDT_FILIAL	:= xFilial("CDT")
		CDT->CDT_IFCOMP := "000001"
		CDT->CDT_TPMOV	:= cEntSai
		CDT->CDT_DOC	:= cDoc
		CDT->CDT_SERIE	:= cSerie
		CDT->CDT_CLIFOR	:= cClieFor
		CDT->CDT_LOJA	:= cLoja
	EndIf

	MsUnLock()
	FkCommit()

	lExiste := CDF->(dbSeek(xFilial("CDF")+cEntSai+cDoc+cSerie+cClieFor+cLoja))

	If lExiste
		RecLock("CDF",.F.)
		CDF->CDF_IFCOMP := "000001"
	Else
		RecLock("CDF",.T.)
		CDF->CDF_FILIAL	:= xFilial("CDF")
		CDF->CDF_TPMOV	:= cEntSai
		CDF->CDF_DOC	:= cDoc
		CDF->CDF_SERIE	:= cSerie
		CDF->CDF_CLIFOR	:= cClieFor
		CDF->CDF_LOJA	:= cLoja
		CDF->CDF_IFCOMP := "000001"
	EndIf

	MsUnLock()
	FkCommit()
	
	lExiste := CDD->(dbSeek(xFilial("CDD")+cEntSai+cDoc+cSerie+cClieFor+cLoja))

	If ! lExiste
		RecLock("CDD",.T.)
		CDD->CDD_FILIAL	:= xFilial("CDD")
		CDD->CDD_TPMOV	:= cEntSai
		CDD->CDD_DOC	:= cDoc
		CDD->CDD_SERIE	:= cSerie
		CDD->CDD_CLIFOR	:= cClieFor
		CDD->CDD_LOJA	:= cLoja
		CDD->CDD_IFCOMP := "000001"
	Else
		RecLock("CDD",.F.)
		CDD->CDD_IFCOMP := "000001"	
	EndIf

	MsUnLock()
	FkCommit()
	
Return