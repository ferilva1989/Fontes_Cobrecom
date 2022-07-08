#include 'parmtype.ch'
#include "rwmake.ch"
#include "protheus.ch"
#include "TOPCONN.ch"
#include "tbiconn.ch"


/*/{Protheus.doc} CDFATW02
//TODO Workflow para envio da carteira de NFs que não foram despachadas pela Expedição.
@author juliana.leme
@since 30/05/2016
@version undefined
@param aParam, array, descricao
@type function
/*/
User function CDFATW02()//  u_CDFATW02()
Local lMenu		:= .T.
Local _aArea 	:= GetArea()
Local oWf
Private _dDtNow := Date()
Public _cTipo 	:= "F" //F ou C

	If Select("SX2") == 0
		lMenu := .F. // Chamou pelo schedule

		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"
	Else
		lMenu := .T. // Chamou pelo schedule
	EndIf

	If lMenu // Chamou pelo menu
		If MsgBox("Deseja Iniciar o Processamento?","Confirma?","YesNo")
			Processa({|| PrepTRBWF("C")})
			Processa({|| PrepTRBWF("F")})
		Else
			Return(.T.)
		EndIf
	Else
		PrepTRBWF("C")
		PrepTRBWF("F")
	EndIf

	If !lMenu
		Reset Environment
	Else
	 	RestArea(_aArea)
	Endif
Return(.T.)


/*/{Protheus.doc} PrepTRB
//TODO Carrega dados WorkFlow.
@author juliana.leme
@since 30/05/2016
@version undefined
@type function
/*/
*
********************************
Static Function PrepTRBWF(cTipo)
********************************
*
Default cTipo := "F"
	DbSelectArea("SA3")
	DbSetOrder(1)  //A3_FILIAL+A3_COD

	If Select("RSC5") > 0
		DbSelectArea("RSC5")
		DbCloseArea("RSC5")
	EndIf

	cQUERY := " SELECT C5.C5_FILIAL FILIAL,  "+;
	        		" F2.F2_SERIE+'/'+F2.F2_DOC NOTA, "+;
	        		" C5.C5_NUM PEDIDO, "+;
	        		" A1.A1_NOME CLIENTE, "+;
	        		" F2.F2_EMISSAO EMISSAO, "+;
	        		" CONVERT(VARCHAR, DATEDIFF(DAY, GETDATE(), CONVERT(DATE,F2.F2_EMISSAO))*-1) as DIASPARADO, "+;
	        		" C5.C5_VEND1 VENDEDOR "+;
	        	" FROM SF2010 F2 "+;
	        		" INNER JOIN SC5010 C5 ON C5.C5_NOTA = F2.F2_DOC AND C5.C5_FILIAL = F2.F2_FILIAL AND C5.C5_SERIE = F2.F2_SERIE "+;
	        			" AND C5.C5_FILIAL = F2.F2_FILIAL "+;
	        		" INNER JOIN SA1010 A1 ON C5.C5_CLIENTE = A1.A1_COD AND C5.C5_LOJACLI = A1.A1_LOJA AND  A1.A1_FILIAL = '" + xFilial("SA3") + "' "+;
	        		" INNER JOIN SD2010 D2 ON D2.D2_DOC = F2.F2_DOC AND D2.D2_FILIAL = F2.F2_FILIAL "+;
	        		" INNER JOIN SF4010 F4 ON F4.F4_CODIGO = D2.D2_TES "+;
	         " WHERE   F2.F2_DTENTR = '        ' "

	cQUERY +=	" AND F2.F2_TPFRETE = '" + cTipo + "' "

	cQUERY +=	" AND C5.D_E_L_E_T_ <> '*'"+;
	        	" AND F2.D_E_L_E_T_ <> '*'"+; 				//" AND F2.F2_SERIE = '1' "+;
	        	" AND F2.F2_EMISSAO >= '" + AllTrim(GetNewPar('ZZ_DTNODES', '20160301')) + "' "+;
	        	" AND F4.F4_ESTOQUE = 'S' "+;   //   	" AND F4.F4_DUPLIC = 'S' "+;
	        	" AND ((F4.F4_CF BETWEEN '51' AND '58') OR (F4.F4_CF BETWEEN '61' AND '68')) "+;
	        	" AND A1.A1_COD NOT IN ('008918','002560','010188','016227','011248') "+; //* 010188, 016227, 011248 incluídos em 08/02/17 by Roberto Oliveira - Solic. por email. */
			"  GROUP BY C5.C5_FILIAL,   F2.F2_SERIE,F2.F2_DOC ,  C5.C5_NUM ,  A1.A1_NOME ,  F2.F2_EMISSAO , C5.C5_VEND1, F4_CF "+;
	        " ORDER BY C5.C5_FILIAL,F2.F2_EMISSAO,F2.F2_SERIE,F2.F2_DOC "

	TCQUERY cQuery NEW ALIAS "RSC5"

	dbSelectArea("RSC5")
	dbGoTop()

	If cTipo = "F"
		cPara := AllTrim(GetMv("MV_ZZWFRTF"))+";"+AllTrim(GetMv("MV_ZZWFRF2"))  // contas de e-mail para envio dos atrasos vendas
		cAssunto := "Notas Fiscais não coletadas/despachadas(Frete FOB)"
		cHtmlMod := "\workflow\ProjCobrecom\fatw02_FOB.html"
		oWF := twfprocess():new("Notas Fiscais não coletadas/despachadas(Frete FOB)",cAssunto)
	Else
		cPara := AllTrim(GetMv("MV_ZZWFRTC"))+";"+AllTrim(GetMv("MV_ZZWFRC2")) // contas de e-mail para envio dos atrasos vendas
		cAssunto := "Notas Fiscais não coletadas/despachadas(Frete CIF)"
		cHtmlMod := "\workflow\ProjCobrecom\fatw02_FOB.html"
		oWF := twfprocess():new("Notas Fiscais não coletadas/despachadas(Frete CIF)",cAssunto)
	EndIf

	oWF:newtask("CDFATW02", cHtmlMod)

	If RSC5->(! Eof() )
		Do While RSC5->(!Eof())
			Aadd( oWF:ohtml:valbyname("Wf.Fil") ,If(RSC5->FILIAL=="01","Itu","3 Lagoas"))
			Aadd( oWF:ohtml:valbyname("Wf.Not") ,RSC5->NOTA)
			Aadd( oWF:ohtml:valbyname("Wf.Ped") ,RSC5->PEDIDO)
			Aadd( oWF:ohtml:valbyname("Wf.Cli") ,Alltrim(RSC5->CLIENTE))
			Aadd( oWF:ohtml:valbyname("Wf.Emi") ,DtoC(StoD(RSC5->EMISSAO)))
			Aadd( oWF:ohtml:valbyname("Wf.Atr") ,RSC5->DIASPARADO)

			If !Empty(RSC5->VENDEDOR)
				SA3->(DbSetOrder(1))  // A3_FILIAL+A3_COD
				If SA3->(DbSeek(xFilial("SA3")+RSC5->VENDEDOR,.F.))
					Aadd( oWF:ohtml:valbyname("Wf.Rep"),SA3->A3_NOME)
					If !Empty(SA3->A3_SUPER)
						If SA3->(DbSeek(xFilial("SA3")+SA3->A3_SUPER,.F.))
							Aadd( oWF:ohtml:valbyname("Wf.Atd"),SA3->A3_NOME)
						Else
							Aadd( oWF:ohtml:valbyname("Wf.Atd"),"N/A")
						EndIf
					EndIf
				Else
					Aadd( oWF:ohtml:valbyname("Wf.Rep"),"N/A")
					Aadd( oWF:ohtml:valbyname("Wf.Atd"),"N/A")
				EndIf
			Else
				Aadd( oWF:ohtml:valbyname("Wf.Rep"),"N/A")
				Aadd( oWF:ohtml:valbyname("Wf.Atd"),"N/A")
			EndIf
			RSC5->(DbSkip())
		EndDo
	Else
		If cTipo = "F"
			_cNadaTem := "NÃO HA PEDIDOS Frete (FOB) Conta CLIENTE"
		Else
			_cNadaTem := "NÃO HA PEDIDOS Frete (CIF) Conta COBRECOM"
		EndIf

		Aadd( oWF:ohtml:valbyname("Wf.Fil") ," ")
		Aadd( oWF:ohtml:valbyname("Wf.Ped") ,"  ")
		Aadd( oWF:ohtml:valbyname("Wf.Cli") ,_cNadaTem)
		Aadd( oWF:ohtml:valbyname("Wf.Emi") ," ")
		Aadd( oWF:ohtml:valbyname("Wf.Prz") ," ")
		Aadd( oWF:ohtml:valbyname("Wf.Atr") ," ")
		Aadd( oWF:ohtml:valbyname("Wf.Rep") ," ")
		Aadd( oWF:ohtml:valbyname("Wf.Atd") ," ")
	EndIf

	//Envia o Email
	oWF:csubject := cAssunto

	If "JULIANA" $ Upper(cUserName)
		cPara := "juliana.leme@cobrecom.com.br"
	ElseIf "ROBERTO" $ Upper(cUserName)
		cPara := "roberto@cobrecom.com.br"
	EndIf

	If !Empty(cPara)
		oWF:cto := AllTrim(cPara)
		oWF:CCC := "wfti@cobrecom.com.br"
	Else
		oWF:csubject 	:= cAssunto + " - FALTA DEFINIÇÃO DE E-MAIL NO PARÂMETRO"
		oWF:cto 		:= "wfti@cobrecom.com.br"
	EndIf

	oWF:start()
	oWF:finish()
	wfsendmail()

	If Select("RSC5") > 0
		DbSelectArea("RSC5")
		DbCloseArea("RSC5")
	EndIf
Return(.T.)
