#INCLUDE "rwmake.ch"

//Função que envia email a cada inclusão ou Alteração no Produto
//Juliana Leme 06/01/2015
User Function EmailProd(cParam1,cProd,cTipo)
	local cAssunto  	:= ""
	local _cAcao		:= ''
	local cCopia    	:= ""
	local cFile     	:= ""
	local cMensagem 	:= ""
	local lEnviado  	:= .F.
	local _cHTML 		:= ""
	local cRecebe   	:= IIF(cTipo$"PA,PI",GetMV('MV_ZZSGQ'),GetMV('MV_ZZCOMPR'))
	local oSch 		:= nil
	local lEnviado	:= .F.

	If cParam1 = "A"
		cAssunto := "Alteração de Produto :" + M->B1_COD + " Descr.: " +	M->B1_DESC
		_cAcao := "Alteração "
	Else
		cAssunto := "Inclusão de Produto :" + M->B1_COD + " Descr.: " +	M->B1_DESC
		_cAcao   := "Inclusão "
	EndIf

	if ! Empty(cRecebe)
		oSch 	:= cbcSchCtrl():newcbcSchCtrl()
		oSch:setIDEnvio('CadastroProduto')
		oSch:setEmailFrom( GetNewPar('MV_WFREMET', 'wf@cobrecom.com.br') )
		oSch:addEmailTo(cRecebe)
		oSch:setFIXO('S')
		oSch:setAssunto(cAssunto)
		oSch:setSimple(.T.)
		
		oSch:setBody( getHtml(_cAcao) )
		oSch:setBodyText('text/html')
		
		if ! ( lEnviado := oSch:schedule():lThisOk )
			u_autoalert(oSch:cThisMsg)
		endIf
		FreeObj(oSch)
	
	endif

return(lEnviado)


static function getHtml(_cAcao)

	_cHTML :='<HTML><HEAD><TITLE></TITLE>'
	_cHTML +='<META http-equiv=Content-Type content="text/html; charset=windows-1252">'
	_cHTML +='<META content="MSHTML 6.00.6000.16735" name=GENERATOR></HEAD>'
	_cHTML +='<BODY>'
	_cHTML +='<H1><FONT size="3">'+_cAcao + 'de Produto </FONT></H1>'

	//Dados Cadastrais
	_cHTML +='<H1><FONT size="2"> Dados Cadastrais </FONT></H1>'
	_cHTML +='<FONT size="1">'
	_cHTML +='<TABLE cellSpacing=3 cellPadding=2 bgColor="" background=""'
	_cHTML +='border=1>'
	_cHTML +='  <TBODY>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Codigo</TD>'
	_cHTML +='	 <TD width=450>'+Alltrim(M->B1_COD)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Descrição</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_DESC)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Tipo</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_TIPO)+' - '+Tabela("02",M->B1_TIPO,.F.)+'</TD></TR>'

	if M->B1_TIPO $ "PA,MP"
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Nome</TD>'
		_cHTML +='    <TD width=450>'+Alltrim(M->B1_NOME)+'</TD></TR>'
	endif

	if M->B1_TIPO = "PA"
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Bitola</TD>'
		_cHTML +='    <TD width=450>'+Alltrim(M->B1_BITOLA)+'</TD></TR>'
	endif

	if M->B1_TIPO $ "PA,MP"
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Cor</TD>'
		_cHTML +='    <TD width=450>'+Alltrim(M->B1_COR)+'</TD></TR>'
	endif

	if M->B1_TIPO = "PA"
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Classe Enc.</TD>'
		_cHTML +='    <TD width=450>'+Alltrim(M->B1_CLASENC)+'</TD></TR>'

		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Especialidad</TD>'
		_cHTML +='    <TD width=450>'+Alltrim(M->B1_ESPECIA)+'</TD></TR>'
	endif

	if M->B1_TIPO = "MP"
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Fornecedor</TD>'
		_cHTML +='    <TD width=450>'+Alltrim(M->B1_FORNECE)+'</TD></TR>'

		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Identificaçã</TD>'
		_cHTML +='    <TD width=450>'+Alltrim(M->B1_IDENTIF)+'</TD></TR>'
	endif

	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Grupo</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_GRUPO)+' - '+Posicione("SBM",1,XFILIAL("SBM")+M->B1_GRUPO,"BM_DESC")+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Unidade</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_UM)+' - '+Posicione("SAH",1,XFILIAL("SAH")+M->B1_UM,"AH_UMRES")+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Armazem Pad</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_LOCPAD)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Peso Liquido</TD>'
	_cHTML +='    <TD width=450>'+cValToChar(M->B1_PESO)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Peso Bruto</TD>'
	_cHTML +='    <TD width=450>'+cValToChar(M->B1_PESBRU)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Cta Contabil</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_CONTA)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Centro Custo</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_CC)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>C.Contab.3L</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_ZZCTATL)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>C.Custo 3L</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_ZZCCTL)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Apropriacao</TD>'
	
	if Alltrim(M->B1_APROPRI) = "D"
		_cHTML +='    <TD width=450>DIRETO</TD></TR>'
	endif
	
	if Alltrim(M->B1_APROPRI) = "I"
		_cHTML +='    <TD width=450>INDIRETO</TD></TR>'
	endif

	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Cod.Barras</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_CODBAR)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Rastro</TD>'
	_cHTML +='    <TD width=450>'+IIF(Alltrim(M->B1_RASTRO)="S",'SIM','NÃO')+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Contr.Loclz.</TD>'
	_cHTML +='    <TD width=450>'+IIF(Alltrim(M->B1_LOCALIZ)=="S",'SIM','NÃO')+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Bloqueado</TD>'
	_cHTML +='    <TD width=450>'+IIF(Alltrim(M->B1_MSBLQL)=="1",'SIM','NÃO')+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Blq.p/Venda?</TD>'
	_cHTML +='    <TD width=450>'+IIF(Alltrim(M->B1_BLQVEN)=="S",'SIM','NÃO')+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Ult.Usuário</TD>'
	_cHTML +='    <TD width=450>'+Substr(M->B1_ZZUSERI,1,2)+;
		'/'+Substr(M->B1_ZZUSERI,3,2)+;
		'/'+Substr(M->B1_ZZUSERI,5,2)+;
		' '+Substr(M->B1_ZZUSERI,7,2)+;
		':'+Substr(M->B1_ZZUSERI,9,2)+;
		' - '+Alltrim(Substr(Alltrim(M->B1_ZZUSERI),11,15))+'</TD></TR>'
	_cHTML+='   </TBODY></TABLE>'

	//Dados Fiscais
	_cHTML +='<H1><FONT size="2"> Dados Fiscais </FONT></H1>'
	_cHTML +='<TABLE cellSpacing=3 cellPadding=2 bgColor="" background="" '
	_cHTML +='border=1>'
	_cHTML +='  <TBODY>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Pos.IPI/NCM</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_POSIPI)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Origem</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_ORIGEM)+' - '+Tabela("S0",M->B1_ORIGEM,.F.)+'</TD></TR>'
	_cHTML +='   </TBODY></TABLE>'

	//Dados MRP/Suprimentos
	_cHTML +='<H1><FONT size="2"> Dados MRP/Suprimentos </FONT></H1>'
	_cHTML +='<TABLE cellSpacing=3 cellPadding=2 bgColor="" background="" '
	_cHTML +='border=1>'
	_cHTML +='  <TBODY>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Lote Econom.</TD>'
	_cHTML +='    <TD width=450>'+cValToChar(M->B1_LE)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Lote Minimo</TD>'
	_cHTML +='    <TD width=450>'+cValToChar(M->B1_LM)+'</TD></TR>'
	_cHTML +='   </TBODY></TABLE>'

	//Dados PCPFAST
	_cHTML +='<H1><FONT size="2"> Dados PCPFAST </FONT></H1>'
	_cHTML +='<TABLE cellSpacing=3 cellPadding=2 bgColor="" background="" '
	_cHTML +='border=1>'
	_cHTML +='  <TBODY>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Gpo. Recurso</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_GPOREC)+'  '+Tabela("ZU",M->B1_GPOREC,.F.)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Qt. Recursos</TD>'
	_cHTML +='    <TD width=450>'+cValToChar(M->B1_QTDMAQS)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Mtz Aliment.</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_MTZALIM)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Mtz Cor</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_MTZCOR)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Mtz Diametro</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_MTZDIAM)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Mtz Gravação</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_MTZGRAV)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>Mtz Mat.Prim</TD>'
	_cHTML +='    <TD width=450>'+Alltrim(M->B1_MTZMATP)+'</TD></TR>'
	_cHTML +='  <TR>'
	_cHTML +='    <TD width=150>PPI-Ft.Conv.</TD>'
	_cHTML +='    <TD width=450>'+cValToChar(M->B1_X_FATOR)+'</TD></TR>'
	_cHTML +='   </TBODY></TABLE>'

	//Dados CobreCom:
		_cHTML +='<H1><FONT size="2"> Dados CobreCom: </FONT></H1>'
		_cHTML +='<TABLE cellSpacing=3 cellPadding=2 bgColor="" background="" '
		_cHTML +='border=1>'
		_cHTML +='  <TBODY>'
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Norma ISO</TD>'
		_cHTML +='    <TD width=450>'+Alltrim(M->B1_NORMA)+'</TD></TR>'
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Max.Rolo</TD>'
		_cHTML +='    <TD width=450>'+cValToChar(M->B1_ROLO)+'</TD></TR>'
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Max.Bobina</TD>'
		_cHTML +='    <TD width=450>'+cValToChar(M->B1_BOBINA)+'</TD></TR>'
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Max.Carr.N8</TD>'
		_cHTML +='    <TD width=450>'+cValToChar(M->B1_CARRETE)+'</TD></TR>'
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Max.Carr.Mad</TD>'
		_cHTML +='    <TD width=450>'+cValToChar(M->B1_CARMAD)+'</TD></TR>'
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Diametro</TD>'
		_cHTML +='    <TD width=450>'+cValToChar(M->B1_DIAMETR)+'</TD></TR>'
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Ft.Raio Curv</TD>'
		_cHTML +='    <TD width=450>'+cValToChar(M->B1_RAIO)+'</TD></TR>'
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Eixo Menor</TD>'
		_cHTML +='    <TD width=450>'+cValToChar(M->B1_EIXOME)+'</TD></TR>'
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Eixo Maior</TD>'
		_cHTML +='    <TD width=450>'+cValToChar(M->B1_EIXOMA)+'</TD></TR>'
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Peso Cobre</TD>'
		_cHTML +='    <TD width=450>'+cValToChar(M->B1_PESCOB)+'</TD></TR>'
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Peso PVC</TD>'
		_cHTML +='    <TD width=450>'+cValToChar(M->B1_PESPVC)+'</TD></TR>'
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Linha Prod.</TD>'
		_cHTML +='    <TD width=450>'+Alltrim(M->B1_LINHA)+'</TD></TR>'
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Uso Portal</TD>'
		_cHTML +='    <TD width=450>'+IIF(Alltrim(M->B1_XPORTAL)=="N",'NÃO','SIM')+'</TD></TR>'
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Rg.INMETRO 1</TD>'
		_cHTML +='    <TD width=450>'+Alltrim(M->B1_XREGINM)+'</TD></TR>'
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Rg.INMETRO 2</TD>'
		_cHTML +='    <TD width=450>'+Alltrim(M->B1_XREGIN3)+'</TD></TR>'
		_cHTML +='  <TR>'
		_cHTML +='    <TD width=150>Designação</TD>'
		_cHTML +='    <TD width=450>'+Alltrim(M->B1_XDESIG)+'</TD></TR>'
		_cHTML +='   </TBODY></TABLE></FONT>'
		_cHTML +='<P></P><P><FONT size="3"> Favor conferir os dados acima.</FONT></P>'
		_cHTML +='<P></P>
		_cHTML +='<P><FONT size="2"><U> CobreCom - Tecnologia da Informação </U></FONT></P>'
		_cHTML +='</BODY></HTML>'

return(_cHTML)
