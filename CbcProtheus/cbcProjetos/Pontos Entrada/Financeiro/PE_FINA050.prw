#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch"

static lVldSED := GetNewPar('ZZ_VLDSED',.T.)

//Fina050
//Rotina de Contas a Pagar

/*/{Protheus.doc} FA050INC
(long_description)
@type function
@author bolognesi
@since 20/03/2018
@version 1.0
@description 
O ponto de entrada FA050INC - será executado na validação da Tudo Ok na inclusão do contas a pagar.
/*/
user function FA050INC()
	local lRet 		:= .T.
	local aArea		:= getArea()
	local aSE1Area	:= SE1->(GetArea())
	local aSEDArea	:= SED->(GetArea())
	local cClSED	:= ''
	local aSaldo	:= {}
	local oInt      := ctrlCbcBudget():newctrlCbcBudget()

	// TODO não funciona quando execauto FINA050
	if lVldSED
		DbSelectArea('SED')
		SED->(DbSetOrder(1))
		
		if  empty(M->(E2_CLVLDB) := Posicione( 'SED', 1, XFILIAL("SED")+M->E2_NATUREZ , 'ED_CLVLDB' ) )
			u_autoalert('[AVISO] - Verifique natureza diferente de classe de valor')
			lRet := .F.
		endif
	endif	
	if lRet .and. (!lF050Auto) .and. (u_cbcUseBudget())
		if AllTrim(M->E2_MULTNAT) <> '1'
			aSaldo := oInt:libMov(, AllTrim(M->E2_NATUREZ), M->E2_VALOR)
			if !(lRet := aSaldo[1])
				cMsg := 'Natureza: ' + AllTrim(M->E2_NATUREZ) + ' não possui saldo de budget!' + CHR(13)+CHR(10) + 'Disponível: ' + cValtochar(TRANSFORM(aSaldo[2], PesqPict('SD1', 'D1_TOTAL'))) + CHR(13)+CHR(10) + 'Requisitado: ' + cValToChar(TRANSFORM(M->E2_VALOR, PesqPict('SD1', 'D1_TOTAL')))
				// Mensagem de Help para esclarescer o motivo de interromper a inclusão
				Help( ,, 'Help',, cMsg, 1, 0 )
			endif
		endif
	endif
	FreeObj(oInt)
	Restarea(aSEDArea)
	RestArea(aSE1Area)
	RestArea(aArea)
return(lRet)

user function FA050ALT()
	local lRet 		:= .T.
	local nVal		:= 0
	local oInt      := ctrlCbcBudget():newctrlCbcBudget()

	if u_cbcUseBudget()		
		if AllTrim(M->E2_MULTNAT) <> '1'
			if SE2->E2_NATUREZ <> M->E2_NATUREZ
				nVal := M->E2_VALOR
			elseif M->E2_VALOR > SE2->E2_VALOR
				nVal := (M->E2_VALOR - SE2->E2_VALOR)
			endif
			if nVal > 0	
				aSaldo := oInt:libMov(, AllTrim(M->E2_NATUREZ), nVal)
				if !(lRet := aSaldo[1])
					cMsg := 'Natureza: ' + AllTrim(M->E2_NATUREZ) + ' não possui saldo de budget!' + CHR(13)+CHR(10) + 'Disponível: ' + cValtochar(TRANSFORM(aSaldo[2], PesqPict('SD1', 'D1_TOTAL'))) + CHR(13)+CHR(10) + 'Requisitado: ' + cValToChar(TRANSFORM(nVal, PesqPict('SD1', 'D1_TOTAL')))
					// Mensagem de Help para esclarescer o motivo de interromper a inclusão
					Help( ,, 'Help',, cMsg, 1, 0 )
					// Alterando lMsErroAuto para .T. (verdadeiro), devido aos casos de integrações ou ExecAuto
					lMsErroAuto := .T.
				endif
			endif
		endif
	endif
	FreeObj(oInt)
return(lRet)

user Function FIXVALMNAT()
	local aArea		:= getArea()
	local aSE2Area	:= SE2->(GetArea())
	local aSEVArea	:= SEV->(GetArea())
	local lRet 		:= .T.
	local nX		:= 0
	local nPos		:= 0
	local nVal		:= 0
	local aNaturez	:= {}
	local oInt      := ctrlCbcBudget():newctrlCbcBudget()

	DbSelectArea("SEV")
	for nX := 1 to len(aCols)
		if (aCols[nX, len(aCols[nX])])
			nVal := 0
		else
			nVal := aCols[nX, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "EV_VALOR"})]
		endif
		nPos := aScan(aNaturez, {|x| AllTrim(x[1] == aCols[nX, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "EV_NATUREZ"})])})
		if nPos > 0	
			aNaturez[nPos, 2] += nVal
		else
			aAdd(aNaturez, {AllTrim(aCols[nX, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "EV_NATUREZ"})]),;
							nVal,;
							0;
							})
			nPos := Len(aNaturez)
		endif
		if len(aCols[nX]) >= 11
			if aCols[nX, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "EV_REC_WT"})] <> 0
				SEV->(DbGoTo(aCols[nX, aScan(aHeader, {|x| Upper(AllTrim(x[2])) == "EV_REC_WT"})]))
				aNaturez[nPos, 3] += SEV->EV_VALOR
			endif
		endif
	next nX
	for nX := 1 to len(aNaturez)
		nVal := aNaturez[nX, 2] - aNaturez[nX, 3]
		if nVal > 0	.and. u_cbcUseBudget()		
			aSaldo := oInt:libMov(, aNaturez[nX, 1], nVal)
			if !(lRet := aSaldo[1])
				cMsg := 'Natureza: ' + aNaturez[nX, 1] + ' não possui saldo de budget!' + CHR(13)+CHR(10) + 'Disponível: ' + cValtochar(TRANSFORM(aSaldo[2], PesqPict('SD1', 'D1_TOTAL'))) + CHR(13)+CHR(10) + 'Requisitado: ' + cValToChar(TRANSFORM(nVal, PesqPict('SD1', 'D1_TOTAL')))
				// Mensagem de Help para esclarescer o motivo de interromper a inclusão
				Help( ,, 'Help',, cMsg, 1, 0 )
				EXIT
			endif
		endif
	next nX
	FreeObj(oInt)
	Restarea(aSEVArea)
	RestArea(aSE2Area)
	RestArea(aArea)
return(lRet)


*
************************
User Function F050DESD()
	************************
	*    
	//PE Chamado na confirmação do Desdobramento
	//Alteração efetuada para o titulo pai não aparecer na rotina de caixa.

	Local aArea    := GetArea()
	Local aAreaSE2 := SE2->(GetArea())
	SE2->E2_NUMCX := "DESDOB"

	RestArea(aAreaSE2)
	RestArea(aArea)

Return({})

	//NAO COMPILAR
	*
	***********************
User Function F050ROT()
	***********************
	Local aRotina := ParamIxb

	AAdd( aRotina,{"Aprov.NF", "U_120Posic('NF')",0,8} )
	AAdd( aRotina,{"Aprov.PC", "U_120Posic('IP')",0,8} )
	AAdd( aRotina,{"Consulta.Docto", "U_120Posic('DC')",0,8} )

Return(aRotina)


	*
	***********************
User Function 120Posic(cTpDocto)
	***********************
	Local aArea			:= GetArea()
	Local aSF1			:= SF1->(GetArea())
	Local aSD1			:= SD1->(GetArea())
	Local aSC7			:= SC7->(GetArea())
	Local aSE2			:= SE2->(GetArea())
	Local aPergs 		:= {}
	Local aRet 			:= {}
	Local aPed			:= {}
	Local aPedRcno		:= {}
	Local aRotBack 	 	:= {}
	Local nBack    	 	:= 0
	Local aRotBkp		:= aClone(aRotina)
	Local lPCvazio		:= .F.

	If cTpDocto $ 'IP'

		DbSelectarea("SD1")
		SD1->(DbSetOrder(1)) //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM

		If SD1->(DbSeek(xFilial("SD1")+SE2->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA),.F.))

			While SD1->(!Eof()) .And. SD1->(D1_FILIAL + D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA) == xFilial("SD1") + SE2->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA)

				If !Empty(SD1->(D1_PEDIDO))

					DbSelectArea("SC7")
					SC7->(DbSetOrder(1)) //C7_FILIAL, C7_NUM, C7_ITEM, C7_SEQUEN

					If SC7->(DbSeek(xFilial("SC7")+SD1->(D1_PEDIDO),.F.))
						aAdd( aPedRcno, SC7->(RECNO()) )
						aAdd( aPed, Alltrim(C7_NUM)  )
					Else
						MessageBox("[Erro]- Não localizou o Pedido: [" + Alltrim(xFilial("SC7")+SD1->(D1_PEDIDO)) + "]. Comunique o TI.", "120Posic()",16)
					EndIf

				Else
					//Avisar que existe Item do Documento de Entrada sem PC
					lPCvazio := .T.
				EndIf

				SD1->(DbSkip())

			EndDo

			If !Empty(aPed)

				If lPCvazio
					MessageBox("[Aviso]- Documento de Entrada: [" + Alltrim(SE2->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA)) + "] possui item sem Pedido associado.", "120Posic()",64)
				EndIf

				aAdd(aPergs ,{3	,"Pedido(s):",1,aPed,80,"",.T.})			//aRet[1] RADIOBOX - OBRIGATORIO
				While ParamBox(aPergs ,"Consultar aprovadores dos Pedidos de Compra",@aRet)
					SC7->(DbGoto(aPedRcno[aRet[1]]))
					a120Posic("SC7",SC7->(RECNO()),2,'PC',.F.)
				EndDo

			Else
				MessageBox("[Alerta]- Documento de Entrada: [" + Alltrim(SD1->(D1_DOC + D1_SERIE + D1_FORNECE + D1_LOJA)) + "] não tem Pedido associado.", "120Posic()",48)
			EndIf

		Else
			MessageBox("[Alerta]- Título não teve origem em um Documento de Entrada.","120Posic()",48)
		EndIf

	ElseIf cTpDocto $ 'NF'

		DbSelectarea("SF1")
		SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_COD+F1_ITEM

		If  SF1->(DbSeek(xFilial("SF1")+SE2->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA), .F.))
			a120Posic("SF1",SF1->(RECNO()),2,'NF',.F.)
		Else
			MessageBox("[Alerta]- Título não teve origem em um Documento de Entrada.","120Posic()",48)
		EndIf

	ElseIf cTpDocto $ 'DC'

		DbSelectarea("SF1")
		SF1->(DbSetOrder(1)) //F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_COD+F1_ITEM
		If  SF1->(DbSeek(xFilial("SF1")+SE2->(E2_NUM + E2_PREFIXO + E2_FORNECE + E2_LOJA), .F.))

			aRotBack	:= IIF(ValType(aRotina) == 'A', AClone( aRotina ), {})
			aRotina		:= {}

			Aadd(aRotina,{"Conhecimento","MsDocument", 0 , 2, 0 ,NIL})
			MsDocument( "SF1", SF1->(Recno()),1 )

			aRotina := AClone( aRotBack )

		Else
			MessageBox("[Alerta]- Título não teve origem em um Documento de Entrada.","120Posic()",48)
		EndIf

	EndIf

	aRotina	:= aClone(aRotBkp)
	RestArea(aSE2)
	RestArea(aSC7)
	RestArea(aSD1)
	RestArea(aSF1)
	RestArea(aArea)

Return(Nil)
