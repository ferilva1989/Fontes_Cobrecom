#include 'parmtype.ch'
#include "rwmake.ch"
#include "protheus.ch"
#include "TOPCONN.ch"
#include "tbiconn.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDFATW03                           Modulo : SIGAEST      //
//                                                                          //
//   Autor ......: Roberto Oliveira                   Data ..: 16/11/16     //
//                                                                          //
//   Objetivo ...: WF dos retrabalhos em aberto.                            //
//                                                                          //
//   Uso ........: Especifico da Cobrecom                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
*
************************
User Function CDFATW03()
************************
*  
Local oWF
Local _aArea

If Select("SX2") == 0
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"
	_lAuto := .T.
Else                 
	_lAuto := .F.
EndIf

If !_lAuto // Chamou pelo menu
	If MsgBox("Deseja Enviar e-mails?","Confirma?","YesNo")
		_aArea := GetArea()
		SendDados()
	 	RestArea(_aArea)
		Alert("E-mails Enviados!")
	EndIf
Else
	SendDados()
	Reset Environment
Endif
Return(.T.)
*
***************************
Static Function SendDados()
***************************
*
*
cQuery := "SELECT DISTINCT ZZE_FILIAL, ZZE_ID"
cQuery += " FROM "+RetSqlName("ZZE")
cQuery += " WHERE"
If !_lAuto .And. !("ROBERTO" $ Upper(cUserName)) // Só a filial atual
	cQuery += " ZZE_FILIAL = '" + xFilial("ZZE") + "' AND"
EndIf
cQuery += " ZZE_STATUS = '3'"
cQuery += " AND ZZE_SITUAC <> '1'"
cQuery += " AND ZZE_DTINI >= '20161231'"
cQuery += " AND ZZE_DTINI < '"+Dtos(Date())+"'"
cQuery += " AND D_E_L_E_T_ = ''"
cQuery += " ORDER BY ZZE_FILIAL, ZZE_ID"

cQuery := ChangeQuery(cQuery)

If Select("TRB")>0
	DbSelectArea("TRB")
	DbCloseArea()
EndIf
TCQUERY cQuery NEW ALIAS "TRB"

_lNewEmail := .T.
cHtmlMod := "\workflow\ProjCobrecom\fatw03_rt.html"
DbSelectArea("ZZE")
DbSetOrder(1) //ZZE_FILIAL+ZZE_ID
For _nVez := 1 to 2
	DbSelectArea("TRB")
	DbGotop()
	cAssunto := "Retrabalhos em Aberto até " + Dtoc(Date()-1) + If(_nVez==1," - Geral"," - Somente para Pedidos")
	Do While TRB->(!Eof())
		_cTRBFil := TRB->ZZE_FILIAL
		_nCasos := 0 // Quantidade de retrabalhos em aberto
		Do While TRB->ZZE_FILIAL == _cTRBFil .And. TRB->(!Eof())
			_lFirst := .T.
			ZZE->(DbSeek(TRB->ZZE_FILIAL + TRB->ZZE_ID,.F.))
			Do While ZZE->ZZE_FILIAL == TRB->ZZE_FILIAL .And. ZZE->ZZE_ID == TRB->ZZE_ID .And. ZZE->(!Eof())
				If _nVez == 2 .And. ZZE->ZZE_PEDIDO == "000001"
					ZZE->(DbSkip())
					Loop
				EndIf
				If _lNewEmail
					oWF := twfprocess():new("Controle do Retrabalho",cAssunto)
					oWF:newtask("CDFATW03", cHtmlMod)
					_lNewEmail := .F.
				EndIf

				If _lFirst
					_lFirst := .F.
					_nCasos++ // Quantidade de ratrabalhos em aberto
					// Preencher com os dados  
					_ZZE_ID     := ZZE->ZZE_ID
					_ZZE_DTINI  := Dtoc(ZZE->ZZE_DTINI)
					_ZZE_PRODUT := ZZE->ZZE_PRODUT + "-" + AllTrim(Posicione("SB1",1,xFilial("SB1")+ZZE->ZZE_PRODUT,"B1_DESC"))
					_ZZE_TOTEN  := Transform(ZZE->ZZE_TOTEN,"@E 999,999")
					_ZZE_SALDO  := Transform(ZZE->ZZE_SALDO,"@E 999,999")
					_ZZE_ACONDE := ZZE->ZZE_ACONDE+StrZero(ZZE->ZZE_METRAE,5)
	
					Aadd( oWF:ohtml:valbyname("Wf.Id") ,_ZZE_ID)
					Aadd( oWF:ohtml:valbyname("Wf.Dat"),_ZZE_DTINI)
					Aadd( oWF:ohtml:valbyname("Wf.Pro"),_ZZE_PRODUT)
					Aadd( oWF:ohtml:valbyname("Wf.QtE"),_ZZE_TOTEN)
					Aadd( oWF:ohtml:valbyname("Wf.Sld"),_ZZE_SALDO)
					Aadd( oWF:ohtml:valbyname("Wf.Acd"),_ZZE_ACONDE)
				Else                                                                          
				
					// Preencher com os espaços
					Aadd( oWF:ohtml:valbyname("Wf.Id") ,Space(Len(_ZZE_ID)))
					Aadd( oWF:ohtml:valbyname("Wf.Dat"),Space(10))
					Aadd( oWF:ohtml:valbyname("Wf.Pro"),Space(Len(_ZZE_PRODUT)))
					Aadd( oWF:ohtml:valbyname("Wf.QtE"),Space(07))
					Aadd( oWF:ohtml:valbyname("Wf.Sld"),Space(07))
					Aadd( oWF:ohtml:valbyname("Wf.Acd"),Space(06))
				EndIf
				
				If ZZE->ZZE_ACONDS == "S" // Sucata
					_ZZE_CODCLI := "Sucatear"
				ElseIf ZZE->ZZE_PEDIDO == "000001"
					_ZZE_CODCLI := "Estoque"
				Else
					_ZZE_CODCLI := AllTrim(ZZE->ZZE_CODCLI+"-"+ZZE->ZZE_LOJA+" "+ZZE->ZZE_NOMCLI)
				EndIf                                
				
				_ZZE_STATUS := ZZE->ZZE_STATUS
				If ZZE->ZZE_STATUS == "3"
					_ZZE_STATUS := "3-Em Aberto"
				ElseIf ZZE->ZZE_STATUS == "A"
					_ZZE_STATUS := "A-Realz. Sem Prev."
				ElseIf ZZE->ZZE_STATUS == "4"
					_ZZE_STATUS := "4-Realizado"
				EndIf
	                                             
				Aadd( oWF:ohtml:valbyname("Wf.Ped"),ZZE->ZZE_PEDIDO+"-"+ZZE->ZZE_ITEMPV)
				Aadd( oWF:ohtml:valbyname("Wf.Cli"),_ZZE_CODCLI)
				Aadd( oWF:ohtml:valbyname("Wf.Acds"),ZZE->ZZE_ACONDS+StrZero(ZZE->ZZE_METRAS,5))
				Aadd( oWF:ohtml:valbyname("Wf.Lan"),Transform(ZZE->ZZE_LANCES,"@E 999,999"))
				Aadd( oWF:ohtml:valbyname("Wf.QtS"),Transform(ZZE->ZZE_TOTSA,"@E 999,999"))
				Aadd( oWF:ohtml:valbyname("Wf.Sta"),_ZZE_STATUS)
				Aadd( oWF:ohtml:valbyname("Wf.Qtd"),Transform(ZZE->ZZE_DEVTOT,"@E 999,999"))
				ZZE->(DbSkip())
			EndDo
			TRB->(DbSkip())
		EndDo
		oWF:csubject := cAssunto + " - " + If(_cTRBFil=='01',"Itu","3 Lagoas") + " - " + AllTrim(Transform(_nCasos,"@E 999,999")) + " Itens em Aberto"
		If _cTRBFil=='01'                                               
			oWF:cto := "wf_retrabalho_itu@cobrecom.com.br"
		Else
			oWF:cto := "wf_retrabalho_tl@cobrecom.com.br"
		EndIf                          
		//oWF:cto := "roberto@cobrecom.com.br"
		oWF:CCC := "wfti@cobrecom.com.br"
		oWF:start()
		oWF:finish()
		wfsendmail()
		_lNewEmail := .T.
	EndDo
Next
DbSelectArea("TRB")
DbCloseArea()
Return(.T.)
