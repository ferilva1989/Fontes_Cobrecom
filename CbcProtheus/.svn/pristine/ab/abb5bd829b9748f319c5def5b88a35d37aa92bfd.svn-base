#include 'protheus.ch'

user function GFEA1181()
	local oCTe 		:= PARAMIXB[1]
	local cbcaArea	:= GetArea()
	local cCodRem 	:= ''
	local cCodDest 	:= ''
	local cToma		:= ''
	local cCliDes	:= ''
	local cCliIdFed	:= ''
	local cCliDesFed:= ''
	local cMsgPreVal:= ''
	local cCFOPCte	:= ''
	local cFilCte	:= ''
	local lAltFil	:= .F.
	local cUFIni	:= ''
	local cUFFim	:= ''

	//Validação do Remetente e Destinatário
	if XmlValid(oCTe,{"_INFCTE","_REM","_CNPJ"},"TEXT",.T.) == 'CNPJ'
		cCodRem := POSICIONE("GU3",11,xFilial("GU3")+XmlValid(oCTe,{"_INFCTE","_REM"}, "_CNPJ") ,"GU3_CDEMIT")
		if empty(cCodRem)
			cMsgPreVal += "- " + "Remetente não encontrado com o CNPJ/CPF: " + XmlValid(oCTe,{"_INFCTE","_REM"}, "_CNPJ") + CRLF
		endIf
	elseif XmlValid(oCTe,{"_INFCTE","_REM","_CPF"},"TEXT",.T.) == 'CPF'
		cCodRem := POSICIONE("GU3",11,xFilial("GU3")+XmlValid(oCTe,{"_INFCTE","_REM"}, "_CPF") ,"GU3_CDEMIT")
		if empty(cCodRem)
			cMsgPreVal += "- " + "Remetente não encontrado com o CNPJ/CPF: " + XmlValid(oCTe,{"_INFCTE","_REM"}, "_CPF") + CRLF
		endif
	elseif !cTpServ $ "3;4"  //Redespacho Intermediario/Serv.Multimodal não precisa desta TAG
		cMsgPreVal += "- " + "A Tag _REM não foi encontrada." + CRLF
	endif

	if XmlValid(oCTe,{"_INFCTE","_DEST","_CNPJ"},"TEXT",.T.)== 'CNPJ'
		cCodDest := POSICIONE("GU3",11,xFilial("GU3")+XmlValid(oCTe,{"_INFCTE","_DEST"},"_CNPJ") ,"GU3_CDEMIT")
		if empty(cCodDest)
			cMsgPreVal += "- " + "Destinatário não encontrado com o CNPJ/CPF: " + XmlValid(oCTe,{"_INFCTE","_DEST"},"_CNPJ") + CRLF
		endif
	elseif XmlValid(oCTe,{"_INFCTE","_DEST","_CPF"},"TEXT",.T.)== 'CPF'
		cCodDest := POSICIONE("GU3",11,xFilial("GU3")+XmlValid(oCTe,{"_INFCTE","_DEST"},"_CPF") ,"GU3_CDEMIT")
		if empty(cCodDest)
			cMsgPreVal += "- " + "Destinatário não encontrado com o CNPJ/CPF: " + XmlValid(oCTe,{"_INFCTE","_DEST"},"_CPF") + CRLF
		endif
	elseif !cTpServ $ "3;4"   //Redespacho Intermediario/Serv.Multimodal não precisa desta TAG
		cMsgPreVal += "- " + "A Tag _DEST não foi encontrada." + CRLF
	endif

	//Analisa o Tomador
	If oCTe:_INFCTE:_VERSAO:TEXT < "3.00" .And. XmlValid(oCTe,{"_INFCTE","_IDE","_TOMA03"},"",.T.) == 'toma03'
		cToma := oCTe:_INFCTE:_IDE:_TOMA03:_TOMA:TEXT
	ElseIf oCTe:_INFCTE:_VERSAO:TEXT >= "3.00" .And. XmlValid(oCTe,{"_INFCTE","_IDE","_TOMA3"},"",.T.) == 'toma3'
		cToma := oCTe:_INFCTE:_IDE:_TOMA3:_TOMA:TEXT
	EndIf
	
	//Captura os Estados de Inicio e Fim conforme solicitação Juliano/Janaina
	cUFIni	:= oCTe:_INFCTE:_IDE:_UFINI:TEXT
	cUFFim	:= oCTe:_INFCTE:_IDE:_UFFIM:TEXT

	If !Empty(cToma)
		If cToma == '0'              // Remetente
			cCliDes := 'Remetente'
			If XmlValid(oCTe,{"_INFCTE","_REM","_CNPJ"},"TEXT",.T.) == 'CNPJ'
				cCliIdFed := oCTe:_INFCTE:_REM:_CNPJ:TEXT
				cCliDesFed := 'CNPJ'
			Else
				cCliIdFed := oCTe:_INFCTE:_REM:_CPF:TEXT
				cCliDesFed := 'CPF'
			EndIf
		ElseIf cToma == '1'          // Expedidor
			cCliDes := 'Expedidor'
			If XmlValid(oCTe,{"_INFCTE","_EXPED","_CNPJ"},"TEXT",.T.) == 'CNPJ'
				cCliIdFed := oCTe:_INFCTE:_EXPED:_CNPJ:TEXT
				cCliDesFed := 'CNPJ'
			Else
				cCliIdFed := oCTe:_INFCTE:_EXPED:_CPF:TEXT
				cCliDesFed := 'CPF'
			EndIf
		ElseIf cToma == '2'          // Recebedor
			cCliDes := 'Recebedor'
			If XmlValid(oCTe,{"_INFCTE","_RECEB","_CNPJ"},"TEXT",.T.) == 'CNPJ'
				cCliIdFed := oCTe:_INFCTE:_RECEB:_CNPJ:TEXT
				cCliDesFed := 'CNPJ'
			Else
				cCliIdFed := oCTe:_INFCTE:_RECEB:_CPF:TEXT
				cCliDesFed := 'CPF'
			EndIf
		ElseIf cToma == '3' 			// Destinatario
			cCliDes := 'Destinatário'
			If XmlValid(oCTe,{"_INFCTE","_DEST","_CNPJ"},"TEXT",.T.) == 'CNPJ'
				cCliIdFed := oCTe:_INFCTE:_DEST:_CNPJ:TEXT
				cCliDesFed := 'CNPJ'
			Else
				cCliIdFed := oCTe:_INFCTE:_DEST:_CPF:TEXT
				cCliDesFed := 'CPF'
			EndIf
		EndIf
	Else  //Outros
		cCliDes := 'Emitente outros'
		If XmlValid(oCTe,{"_INFCTE","_IDE","_TOMA4","_CNPJ"},"TEXT",.T.) == 'CNPJ'
			cCliIdFed := oCTe:_INFCTE:_IDE:_TOMA4:_CNPJ:TEXT
			cCliDesFed := 'CNPJ'
		Else
			cCliIdFed := oCTe:_INFCTE:_IDE:_TOMA4:_CPF:TEXT
			cCliDesFed := 'CPF'
		EndIf
	EndIf

	//Grava CFOP Relatorio
	cCFOPCte	:= oCTe:_INFCTE:_IDE:_CFOP:TEXT

	// Não foi possivel identificar o codigo do Remetente
	if empty(cCodRem)
		Msgbox('Erro ao importar CTE. Filial: ' + GXG->GXG_FILIAL + ' CTE: ' + GXG->GXG_CTE + ', tente importar novamente.', 'ERRO CTE',  'STOP')
		UserException('Erro ao importar CTE, tente novamente. ' + GXG->GXG_FILIAL + ' ' + GXG->GXG_CTE)
	endif

	//Verifica a filial de Gravação da GXG
	cFilCte	:= DefFilial(cCliIdFed)
	if RecLock("GXG",.F.)	
		lAltFil		:= .F.
		if (GXG->GXG_FILIAL <> cFilCte) .and. !empty(cFilCte)
			dbSelectArea("GXH")
			While (GXH->(dbSeek(GXG->GXG_FILIAL + GXG->GXG_NRIMP, .T.)))
				if RecLock("GXH", .F.)
					GXH->GXH_FILIAL := cFilCte
					GXH->(MsUnlock())
				endif
			endDo
			GXG->GXG_FILIAL		:= cFilCte
			lAltFil				:= .T.
		endif

		if !empty(cCFOPCte)
			GXG->GXG_CFOP := cCFOPCte
		endif

		if empty(GXG->GXG_EMISDF)
			GXG->GXG_EMISDF := oCTe:_INFCTE:_EMIT:_CNPJ:TEXT
		endif

		GXG->GXG_ZZUFIN		:= cUFIni
		GXG->GXG_ZZUFFI		:= cUFFim
		GXG->GXG_CDREM		:= cCodRem
		GXG->GXG_CDDEST		:= cCodDest
		GXG->GXG_ZZIDTOM	:= cCliIdFed
		GXG->GXG_ZZDTOM		:= cCliDes
		CalcVolum() //Refaz o padrão porque o Padrão em algum momento zera os valores indicados pelo XML
		GXG->(MsUnlock())
	endif	
	auditCte(oCTe)
	RestArea(cbcaArea)
return


Static Function CalcVolum()// Carrega os dois campos GXG_VOLUM e GXG_QTVOL com informações do XML
	Local oXml
	Local nX
	Local aPesos 	:= {0,0,0,0,0} //1-Bruto;2-Cubado;3-Aferido;4-Declarado;5-Aforado
	local cTpCte 	:= XmlValid(oCTE,{"_INFCTE","_IDE"},"_TPCTE")
	local nVolumes 	:= 0
	local nQtdVol	:= 0

	// Tag _INFCTENORM não existe em arquivos Ct-e de copmlemento de valores e anulação de valores
	If cTpCte $ "1;2"
		Return
	EndIf
	oXml := oCTe:_INFCTE:_INFCTENORM:_INFCARGA:_INFQ
	If ValType(oXml) == "A"
		For nX := 1 To Len(oXml)
			If oXml[nX]:_CUNID:TEXT == '00' // Volume em M³
				nVolumes += SetField(Val(oXml[nX]:_QCARGA:TEXT), "GXG_VOLUM")
			ElseIf oXml[nX]:_CUNID:TEXT == '01' // KG
				If  'BRUTO' $ oXml[nX]:_TPMED:TEXT
					GXG->GXG_PESOR := SetField(Val(oXml[nX]:_QCARGA:TEXT), "GXG_PESOR")
				EndIf

				If 'CUB' $ oXml[nX]:_TPMED:TEXT  
					GXG->GXG_PESOC := SetField(Val(oXml[nX]:_QCARGA:TEXT), "GXG_PESOC")
				Else
					aPesos[1] := SetField(Val(oXml[nX]:_QCARGA:TEXT) , "GXG_PESOR")
				Endif	
			ElseIf oXml[nX]:_CUNID:TEXT == '02' // TON				
				If  'BRUTO' $ oXml[nX]:_TPMED:TEXT  
					GXG->GXG_PESOR := SetField(Val(oXml[nX]:_QCARGA:TEXT) * 1000, "GXG_PESOR")
				EndIf

				If 'CUB' $ oXml[nX]:_TPMED:TEXT
					GXG->GXG_PESOC := SetField(Val(oXml[nX]:_QCARGA:TEXT) * 1000, "GXG_PESOC")
				Else
					aPesos[1] := Val(oXml[nX]:_QCARGA:TEXT) * 1000
				EndIf
			ElseIf oXml[nX]:_CUNID:TEXT == '03' // Unidades
				nQtdVol += SetField(NoRound(Val(oXml[nX]:_QCARGA:TEXT)), "GXG_VOLUM")
			EndIf
		Next nX	
		If Empty(GXG->GXG_PESOR)
			GXG->GXG_PESOR := SetField(aPesos[1], "GXG_PESOR")
		EndIf
		if nQtdVol > 0
			GXG->GXG_QTVOL := SetField(nQtdVol, "GXG_QTVOL")
		endif
		if nVolumes > 0
			GXG->GXG_VOLUM := SetField(nVolumes, "GXG_VOLUM")
		endif
	ElseIf ValType(oXml) == "O"
		If oXml:_CUNID:TEXT == '00' // Volume em M³
			GXG->GXG_VOLUM := Val(oXml:_QCARGA:TEXT)
		ElseIf oXml:_CUNID:TEXT == '01' //KG
			If 'CUB' $ oXml:_TPMED:TEXT
				GXG->GXG_PESOC := SetField(Val(oXml:_QCARGA:TEXT), "GXG_PESOC")
			EndIf
			GXG->GXG_PESOR := SetField(Val(oXml:_QCARGA:TEXT), "GXG_PESOR")
		ElseIf oXml:_CUNID:TEXT == '02' // TON
			If 'CUB' $ oXml:_TPMED:TEXT
				GXG->GXG_PESOC := SetField(Val(oXml:_QCARGA:TEXT) * 1000, "GXG_PESOC")
			EndIf
			GXG->GXG_PESOR := SetField(Val(oXml:_QCARGA:TEXT) * 1000,"GXG_PESOR")
		ElseIf oXml:_CUNID:TEXT == '03' // Unidades
			GXG->GXG_QTVOL := SetField(NoRound(Val(oXml:_QCARGA:TEXT)), "GXG_VOLUM")
		EndIf
	EndIf
Return

Static Function SetField(nValor, cCampo, lValid)
	Local cValor
	Local nRet
	Local aTamSX3 := TamSX3(cCampo)

	Default nValor := 0
	Default lValid := .T.

	cValor := cValToChar(Round(nValor, 0))
	cValor := StrTran(cValor, ".", "")
	cValor := StrTran(cValor, ",", "")

	If aTamSX3[2] > 0
		cValor := AllTrim(Transform(nValor, Replicate("9", aTamSX3[1]) + "." + Replicate("9", aTamSX3[2])))
	Else
		cValor := AllTrim(Transform(nValor, Replicate("9", aTamSX3[1])))
	EndIf

	If Len(cValor) > aTamSX3[1]
		If lValid
			cMsgPreVal += "- " + "Erro no campo: " + cCampo + ". Valor '" + cValToChar(nValor) + "' com formato inválido ou não suportado." + CRLF
		EndIf
		Return(0)
	EndIf
	nRet   := Val(cValor)
Return(nRet)

/*/{Protheus.doc} XmlValid
Função responsavel por validar se o caminho informado corresponde a um objeto valido no xml
Caso seja, ele grava a informação TEXT do XML no campos informado
@param cXMLDir caminho do arquivo que esta sendo importado
@param oXML     Objeto   - XML
@param cChild   Caracter - Caminho para validação
@version 1.0
/*/
static function XmlValid(oTEMP,aNode,cTag,lREALNAME)
	local nCont
	private oXML := oTEMP
	default lREALNAME := .F.
	
	//Navega dentro do objeto XML usando a variavel aNode como base, retornando o conteudo do TEXT ou o
	for nCont := 1 to Len(aNode)
		if valtype( XmlChildEx( oXML,aNode[nCont]  ) ) == 'O'
			oXML :=  XmlChildEx( oXML,aNode[nCont]  )
		else
			return
		endif
		if nCont == Len(aNode)
			if !lREALNAME
				cReturn := &("oXML:"+cTag+':TEXT')
				return cReturn
			else
				cReturn := &("oXML:REALNAME")
				return cReturn
			endif
		endif
	next nCont

	FreeObj(oXML)
	FreeObj(xRet)
	FreeObj(xRet1)
return ''

static function DefFilial(cCnpjFil)
	local ccbcFilial 	:= ''
	local acbcEmpr		:= {}
	local nCont 		:= 1
	default cCnpjFil 	:= '02544042000138'

	acbcEmpr	:= FWLoadSM0()
	for nCont := 1 to len(acbcEmpr)
		if alltrim(acbcEmpr[nCont][18]) == alltrim(cCnpjFil)
			ccbcFilial := acbcEmpr[nCont][2]
			exit
		endif
	next
return(ccbcFilial)


static  function auditCte(_oCte)
   local oFrete     := nil 
   local vldFrete   := nil
   local aTrans     := {}
   local cCnTran	:= ''
   if GetNewPar('ZZ_GFEA118', .F.)
    cCnTran := GetNewPar('ZZ_AUDITTR', '')
	aTrans  := StrToKArr(cCnTran, ';')
	if(((AScan(aTrans, {|x| alltrim(x) == alltrim(GXG->(GXG_EMISDF))})) > 0) .Or. cCnTran == '*')
		oFrete := cbcAuditFrete():newcbcAuditFrete()
		vldFrete := oFrete:validCalc(_oCte)
		if !vldFrete['STS'] 
			if RecLock("GXG",.F.)
				if vldFrete['EDISIT'] == 'Z'
					GXG->GXG_EDISIT := '5'
					GXG->GXG_AUDITS := 'Z'
					GXG->GXG_ORIGEM := 'W'
				else
					GXG->GXG_EDISIT := vldFrete['EDISIT']
					GXG->GXG_AUDITS := vldFrete['EDISIT']
				endif
				GXG->GXG_JSMSG  := vldFrete:toJson()
				GXG->(MsUnlock())
				if vldFrete['EDISIT'] == 'Z'
					Help(NIL, NIL, "Auditoria de Frete",;
					NIL, "CTE chave: " + Alltrim(vldFrete['INFO']['CALC_CTE']['CHV_CTE']) +;
					"com divergência de " + cValToChar(vldFrete['PERC_DIF']), 1, 0, NIL, NIL, NIL, NIL, NIL, {"Aguardade liberação da Logistica"})
				endif
			endif
		endif
     	FreeObj(oFrete)
	 endif
	endif
return nil
