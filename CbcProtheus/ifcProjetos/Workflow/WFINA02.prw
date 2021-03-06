#INCLUDE "rwmake.ch"
#INCLUDE "set.ch"
#INCLUDE "ap5mail.ch"
#include "TOPCONN.ch"
#INCLUDE "TBICONN.CH "
#define CRLF Chr(13)+Chr(10)


/*/{Protheus.doc} WFINA02
//TODO Descri??o auto-gerada.
Envio de email para alerta de vencimento
Enviar somente titulos do tipo NF
Prazo para envio = 2 dias UTEIS antes do vencimento real 
@author Original: Roberto Oliveira || Alterado: alexandre.madeira
@since 21/01/2019
@version 1.0
@return .T.
@type function
/*/
User Function WFINA02()
	private nQuant     := 0
	private nTitul     := 0
	private _dVencAte  := Date()
	private cLojaCli
	
	
	dbSelectArea("SE1")
	dbSetOrder(1)//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	
	//PREPARE ENVIRONMENT EMPRESA ( "01" ) FILIAL ( "01" ) MODULO "FIN"
	
	If MsgBox("Esta rotina envia email aos Clientes informado os T?tulos a Vencer"+CRLF+;
		"Deseja Enviar os emails ?","Confirma?","YesNo")
	
		If DOW(Date()) == 4 // Quarta-Feira
			_dVencAte  := Date() + 3
		ElseIf DOW(Date()) == 5 // Quinta-Feira
			_dVencAte  := Date() + 4
		ElseIf DOW(Date()) == 6 // Sexta-Feira
			_dVencAte  := Date() + 4
		Else
			_dVencAte  := Date() + 2
		EndIf
	
		_cParte1 := ""
		_cParte1 += "<html>"
		_cParte1 += "<head>"
		_cParte1 += "<title>Untitled Document</title>"
		_cParte1 += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
		_cParte1 += '<style type="text/css">'
		_cParte1 += "<!--"
		_cParte1 += ".style8 {font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; }"
		_cParte1 += ".style13 {color: #0033FF; font-family: Verdana, Arial, Helvetica, sans-serif; font-size: 10px; }"
		_cParte1 += "-->"
		_cParte1 += "</style>"
		_cParte1 += "</head>"
		_cParte1 += "<body>"
		_cParte1 += '<table width="500" border="0">'
		_cParte1 += "<tr>"
		_cParte1 += '<th width="69" height="47" bgcolor="#EEE9E9" scope="col"><img src='+"'http://www.cobrecom.com.br/Workflow/logo-cobrecom.png' width='100' height='45'></th>"
		_cParte1 += '<th width="400" bgcolor="#EEE9E9" scope="col">I.F.C. - Cobrecom - T?tulos a Vencer</th>'
		_cParte1 += "</tr>"
		_cParte1 += "</table>"
		_cParte1 += '<hr align="left" width="500">'
		_cParte1 += '<table width="500" border="5">'
		_cParte1 += "<tr>"
	
		_cParte3 := "</tr>"
		_cParte3 += "</table>"
		_cParte3 += '<table width="500" height="98" border="0">'
		_cParte3 += '<th width="500" height="94" scope="col"><blockquote>&nbsp;</blockquote>'
		_cParte3 += '<div align="center">'
		_cParte3 += '<table width="495" border="1" align="left" bordercolor="#333333">'
		_cParte3 += "<tr>"
		_cParte3 += '<th scope="col"><span class="style8">Duplicata</span></th>'
		_cParte3 += '<th scope="col"><span class="style8">Parcela</span></th>'
		_cParte3 += '<th scope="col"><span class="style8">S&eacute;rie</span></th>'
		_cParte3 += '<th scope="col"><span class="style8">Emiss&atilde;o</span></th>'
		_cParte3 += '<th scope="col"><span class="style8">Vencto</span></th>'
		_cParte3 += '<th scope="col"><span class="style8">Valor</span></th>'
		_cParte3 += "</tr>"
	
		_cparte4 := "</table>"
		_cparte4 += "</div>"
		_cparte4 += "</th>"
		_cparte4 += "</table>"
	
		_cparte4 += '<table width="500" border="0">'
		_cparte4 += "<tr>"
		_cparte4 += '<th width="500"><div align="center">Acima vencimento(s) da(s) pr?xima(s) duplicata(s)</th>'
		_cparte4 += "</tr>"
		_cparte4 += "<tr>"
		_cparte4 += '<th width="500"><div align="center"> </th>'
		_cparte4 += "</tr>"
		_cparte4 += "</table>"
	
		_cparte4 += '<table width="500" height="25" border="0">'
		_cparte4 += "<tr>"
		_cparte4 += '<th scope="col"><div align="center">Qualquer d?vida ligar para Fone (11)-2118-3200</div></th>'
		_cparte4 += "</tr>"
		_cparte4 += "<tr>"
		_cparte4 += '<th width="500"><div align="center"> </th>'
		_cparte4 += "</tr>"
		_cparte4 += "</table>"
	
		_cparte4 += '<table width="500" height="25" border="0">'
		_cparte4 += "<tr>"
		_cparte4 += '<th scope="col"><div align="center">E-mail autom?tico - Favor n?o responder</div></th>'
		_cparte4 += "</tr>"
		_cparte4 += "</table>"
	
		_cparte4 += "<p>&nbsp;</p>"
		_cparte4 += "<p>&nbsp;</p>"
		_cparte4 += "</body>"
		_cparte4 += "</html>"
	
		Processa({|| EnvMails(_dVencAte)},"Enviando e-Mails")
	EndIf
Return(.T.)



/*/{Protheus.doc} EnvMails
//TODO Descri??o auto-gerada.
Envio de email para alerta de vencimento
Enviar somente titulos do tipo NF
Prazo para envio = 2 dias UTEIS antes do vencimento real 
@author Original: Roberto Oliveira || Alterado: alexandre.madeira
@since 21/01/2019
@version 1.0
@return .T.
@type function
/*/
Static Function EnvMails(_dVencAte)
	local _cAssunto := "Aviso de Vencimento"
	local cQuery1	:= ""
	local cQuery2	:= ""
	local cQuery	:= ""
	local xQuery	:= ""
	local cMailFin	:= ""
	local oSql		:= nil
	
	nTitul	:= 0
	
	cQuery1 := "SELECT E1_FILIAL FILIAL,E1_CLIENTE CLIENTE,E1_LOJA LOJA,E1_NOMCLI NOMCLI,E1_PREFIXO PREFIXO,E1_NUM NUM,"
	cQuery1 += " E1_PARCELA PARCELA,E1_TIPO TIPO,E1_EMISSAO EMISSAO,E1_VENCTO VENCTO,E1_VENCREA VENCREA,E1_VALOR VALOR, E1_SALDO SALDO, "
	cQuery1 += " E1_DTMAIL DTMAIL, E1_ORIGEM ORIGEM"
	
	cQuery := " FROM "+RetSqlName("SE1")
	cQuery += " WHERE E1_DTMAIL = '        '"
	cQuery += " AND E1_SALDO <> '0'"
	cQuery += " AND (E1_PREFIXO = '1  ' OR E1_PREFIXO = 'UNI') AND E1_ORIGEM = 'MATA460 '"
	cQuery += " AND E1_VENCTO >=  '" + DtoS(DATE()) + "' AND E1_VENCTO <= '" + DtoS(_dVencAte) + "'"
	//cQuery += " AND E1_PORTADO = '000' "
	cQuery += " AND E1_NUMBCO <> '' "
	cQuery += " AND D_E_L_E_T_ <> '*' "
	
	cQuery2 := " ORDER BY E1_CLIENTE,E1_LOJA,E1_VENCREA,E1_PREFIXO,E1_NUM,E1_PARCELA "
	
	xQuery := cQuery1 + cQuery + cQuery2
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(xQuery)
	if oSql:hasRecords()
		_nQtd := oSql:count()
		DbSelectArea("SA1")
		ProcRegua(_nQtd)
		oSql:goTop()
		while oSql:notIsEof()
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1")+oSql:getValue('CLIENTE')+oSql:getValue('LOJA'),.F.))
		
			cMailFin := SA1->A1_EMAILFI
			If Empty(cMailFin)
				IncProc()
				oSql:skip()
				Loop
			EndIf
		
			_cParte2 := '<th width="95" scope="col">Cliente:</th>'
			_cParte2 += '<th width="400" scope="col"><div align="left">'+AllTrim(SA1->A1_COD)+"/"+AllTrim(SA1->A1_LOJA)+" - " + AllTrim(SA1->A1_NOME)+'</div></th>'
		
			cLojaCli := oSql:getValue('CLIENTE')+oSql:getValue('LOJA') //armazena os codigos iniciais
			_cCorpo := ""
		
				//Enquanto for o mesmo cliente adiciona os dados
			Do While oSql:notIsEof() .And. oSql:getValue('CLIENTE')+oSql:getValue('LOJA') == cLojaCli
				IncProc()
				_cCorpo += '<tr>'
				_cCorpo += '<td><span class="style8">'+oSql:getValue('NUM')+'</span></td>'
				_cCorpo += '<td><span class="style8">'+oSql:getValue('PARCELA')+'</span></td>'
				_cCorpo += '<td><span class="style8">'+oSql:getValue('PREFIXO')+'</span></td>'
				_cCorpo += '<td><span class="style8"><div align="right">'+Dtoc(Stod(oSql:getValue('EMISSAO')))+'</div></span></td>'
				_cCorpo += '<td><span class="style8"><div align="right">'+Dtoc(Stod(oSql:getValue('VENCTO')))+'</div></span></td>'
				_cCorpo += '<td><span class="style8"><div align="right">'+Transform(oSql:getValue('SALDO'),'@E 9999,999.99')+'</div></span></td>'
				_cCorpo += '</tr>
		
				DbSelectArea("SE1")
				DbSetOrder(1)
				If DbSeek(oSql:getValue('FILIAL')+oSql:getValue('PREFIXO')+oSql:getValue('NUM')+oSql:getValue('PARCELA')+oSql:getValue('TIPO'),.F.)
					RecLock("SE1",.F.)
						SE1->E1_DTMAIL := Date()
					MsUnlock()
			    EndIf
	
				oSql:skip()
				nTitul += 1
			EndDo
			_cTo      := Lower(AllTrim(cMailFin))
			_cBody    := _cParte1 + _cParte2 + _cParte3 + _cCorpo+_cparte4
			if (u_SendMail(_cTo,_cAssunto,_cBody))
				nQuant += 1
			endif
		EndDo
	endif
	oSql:close()
	FreeObj(oSql)
	MsgInfo("Foram enviados "+Alltrim(Str(nQuant))+" e-mails de t?tulos","Aviso")
Return(.T.)
