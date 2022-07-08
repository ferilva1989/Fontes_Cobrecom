#include 'protheus.ch'
#include 'parmtype.ch'
#include 'fileio.ch'

User Function MetaDados()
	Local oBase
	/******************  Exemplos da CLASSE Metadados **************************/
	//TODOS OS METODOS RETORNAM LOGICO SOBRE SUA EXECUÇÃO
	//PORTANTO DEVEM SER TESTATODS COM IF

	//****** PODE-SE INICIAR UMA TABELA
	//INICIAR A CLASSE
	oBase := ManBaseDados():newManBaseDados()

	//VERIFICAR SE UM CAMPO EXISTE NO SX3
	Alert(IIF(oBase:ExistInTab('A1_COD'), 'A1_COD EXISTE',  'A1_COD NÃO EXISTE' ) )
	Alert(IIF(oBase:ExistInTab('C6_ERRO'), 'C6_ERRO EXISTE','C6_ERRO NÃO EXISTE' ) )

	//DEFINIR TABELA E ORDEM (TODA VEZ QUE ALTERA LIMPA OS CAMPOS)
	oBase:setOrd("SC6",1)

	//****** E NO DECORRER DO PROGRAMA ATUALIZA-LA QUANDO NECESSARIO
	//DEFINIR CHAVE DE BUSCA (TODA VEZ QUE ALTERA LIMPA OS CAMPOS)
	oBase:addKey({"024243" , "01" , "1540804401"})

	//DEFINIR OS CAMPOS E OS NOVOS VALORES
	oBase:addCpoVlr('C6_ZZNRRES','001234')
	oBase:addCpoVlr('C6_SEMANA','ROTAUTO')	

	//EXECUTAR A ATUALIZAÇÂO E CONFERIR POSSIVEIS ERROS
	oBase:updTable()

	//AO INFORMAR O PARAMETRO COM O NUMERO DO RECNO, DISPENSA (setOrd() e addKey()) vai direto no registro
	oBase:updTable(nRec)
	//****************************************************************/
	
Return (Nil)

/********************************************************************************************/
User Function SigaArea()
	Local oArea
	DbSelectArea('SC6')
	DbSelectArea('SC5')	
	DbSelectArea('SE2')
	DbSelectArea('SE1')

	/*EXEMPLOS DA CLASSE SigaArea*/
	/*************************/
	oArea := SigaArea():newSigaArea()
	/*SALVAR AS AREAS DE TRABALHOS DEFINIDAS NO ARRAY DE PARAMETRO*/
	oArea:saveArea( {'SC6', 'SC5', 'SE2'} )	

	/*EM CASO DE UMA NOVA CHAMADA ELE LIMPA O ARRAY DAS AREAS ANTERIORES
	PARA QUE ISSO NÂO ACONTEÇA UTILIZE 2 PARAMETRO COMO .F.*/

	//DESTA FORMA IRA APAGAR AS AREAS SC6 SC5 SE2, FICANDO APENAS COM SE1
	oArea:saveArea( {'SE1'} ) 

	//NESTE  ALEM DAS TRES AREAS (SC6, SC5, SE2) ACRESCENTA MAIS SE1
	oArea:saveArea( {'SC6', 'SC5', 'SE2'} )	
	oArea:saveArea( {'SE1'}, .F. ) 

	/*RESTAURA AS AREAS DE TRABALHO AO SEU ESTADO INICIAL*/
	oArea:backArea()
	/*RESTAURA UMA AREA ESPECIFICA PREVIAMENTE SALVA*/
	oArea:backArea({'SC5'})

Return(Nil)
/********************************************************************************************/

User Function SqlUtil()
	Local oSql 	:= SqlUtil():newSqlUtil()
	Local nX	:= 0

	/*EXEMPLO 01 Passando a query completa como parametro*/
	if oSql:QryToDb( "SELECT * FROM SZ3010" ):lOk
		MessageBox("Query enviada: " + oSql:qryForSend , "Aviso",48)
		MessageBox("Consulta Retornou: " + cValToChar(oSql:nRegCount) , "Aviso",48)
		For nX := 1 To oSql:nRegCount
			MessageBox(oSql:oRes[nX]:Z3_DESC , "Aviso",48)	
		Next nX
	Else
		MessageBox(oSql:cMsgErro)
	EndIf

	/*EXEMPLO 02*/
	/*Definir a tabela*/
	oSql:addFromTab('SZS')
	/*Os campos da tabela*/
	oSql:addCampos({'ZS_CODIGO','ZS_NOME'})
	/*As condições podem ser escritas numa mesma string, bem como adicionadas uma a uma*/
	oSql:addWhere("ZS_ATIVO = 'S'")
	/*Por default o segundo paramtero é AND, não precisa informar caso seja OR informar*/
	oSql:addWhere("ZS_CODIGO <> '' ",'AND')
	/*Definir a ordem recebe array com a ordem desejada e o segundo parametro recebe o tipo da
	ordem ASC ou DESC*/
	oSql:addOrder({'ZS_CODIGO'},'DESC')
	/*Executar o select*/
	if oSql:QrySelect():lOk	
		/*Mostra a query que foi enviada*/
		MessageBox("Query enviada: " + oSql:qryForSend , "Aviso",48)
		/*Mostra quantos registros retornaram*/
		MessageBox("Consulta Retornou: " + cValToChar(oSql:nRegCount) , "Aviso",48)

		/*Percorrer os registro*/
		For nX := 1 To oSql:nRegCount
			/*O Retorno sempre gera um objeto "oSql:oRes" onde cada registro fica em uma posição
			e o conteudo é acessado pelo mesmo nome dos campos, abaixo estamos exibindo o campo nome
			de todos os retornos da busca*/
			MessageBox(oSql:oRes[nX]:ZS_NOME , "Aviso",48)	
		Next nX
	Else
		/*Caso exista algum erro exibir a mensagem de erro*/
		MessageBox(oSql:cMsgErro, "Aviso",48)
	EndIf

	/*EXEMPLO 03 Todos os metodos retornam o self desta forma podemos encadiar os metodos conforme exemplo
	abaixo, repare que as condições where estão definidas em uma unica chamada ao addWhere */
	if oSql:addFromTab('SZS'):addCampos({'ZS_CODIGO','ZS_NOME'}):addWhere("ZS_ATIVO = 'S' AND ZS_CODIGO <> ''"):QrySelect():lOk

		MessageBox("Query enviada: " + oSql:qryForSend , "Aviso",48)
		MessageBox("Consulta Retornou: " + cValToChar(oSql:nRegCount) , "Aviso",48)
		For nX := 1 To oSql:nRegCount
			MessageBox(oSql:oRes[nX]:ZS_NOME , "Aviso",48)	
		Next nX
	Else
		MessageBox(oSql:cMsgErro, "Aviso",48)
	EndIf

	/* EXEMPLO IMPORTANTE PARA QUE SE RETORNE O R_E_C_N_O_
	::oSql:addCampos({'SC6.R_E_C_N_O_','C6_PRODUTO','C6_ITEM','C6_TES','C6_QTDVEN','C6_PRCVEN','C6_VALOR'})
	*/

Return (Nil)

/****************** Exemplos da CLASSE FileSystem **************************/
User Function fileSys()
	Local oFS	 := FileSystem():newFileSystem()

	//Comprimir arquivo
	oFS:compress('cPath' + 'cNameFile' + '.pdf')

	//Descomprimir arquivos
	oFS:uncompress()

return .T.

/******************  Exemplos da CLASSE SendEmail **************************/
User Function vaiEmail()
	Local oEmail 	:= cbcSendEmail():newcbcSendEmail()
	Local lOk		:= .T.
	Local cMsg		:= ""
	Local aCmps 	:= {}
	Local aLoop 	:= {}
	
	oEmail:iniSrvMsg()
	If !oEmail:lOk
		lOk 	:= oEmail:lOk
		cMsg	:= oEmail:cMsg
		u_autoAlert(cMsg)
	Else

		oEmail:setFrom('remetente@dominio.com.br')
		oEmail:setTo("destinatario@dominio.com.br")
		oEmail:setcCc("copia@dominio.com")
		oEmail:setcBcc("")
		oEmail:setcSubject("[EMPRESA] - Assunto do Email. ")
		oEmail:setPriority(5) // 1 até 5
		oEmail:setConfReader(.T.) //Confirmação de leitura

		/*Definir o Body de forma simples (aceita tags Html)*/
		oEmail:setcBody("Texto Simples a exibir no corpo do email")			


		/***************************** BODY HTML *************************/
		/*Definir o Body, atraves de um arquivo modelo escrito em (html/css)*/
		/*
		//ATRIBUIÇÂO DE VALORES A CAMPOS, NO HTML UTILIZAR "!TAG!",  PARA
		//SUBSTITUIR VIA CODIGO (BIND DADOS)
		<Fieldset>
		<legend>Dados do Faturamento</legend>
		<b>Representante:</b> !A3_NOME!	<br />
		<b>Serie/ Documento:</b> !F2_SERIE!/!F2_DOC!<br />
		<b>Emissão:</b> !F2_EMISSAO!<br /><br />
		<fieldset>
		<legend>Dados do Cliente</legend>
		<b>Código/ Loja:</b> !A1_COD!/ !A1_LOJA! <br/>
		<b>Nome:</b> !A1_NOME!<br/>
		<b>E-mail:</b> !A1_EMAIL!<br/>
		</fieldset>
		</Fieldset>
		//Segue exemplo para atribuir valor ao modelo HTML acima
		*/
		Aadd(aCmps, {'A3_NOME','NOME TESTE'})
		Aadd(aCmps, {'F2_SERIE','SERIE TESTE'})
		Aadd(aCmps, {'F2_DOC','DOC TESTE'})

		/*
		//ATRIBUIR VALORES A LISTAS DE DADOS (NO HTML UTILIZAR TAG %t1.1%,%t1.2% PARA DEFINIR O CONTEUDO DE CADA LINHA)
		<table width="100%" border= 0>
		<tr>

		<th style="border:1px solid #EAEAEA; text-align: left" class="style1">Cod.</th>
		<th style="border:1px solid #EAEAEA; text-align: left" class="style1">Descri.</th>
		<th style="border:1px solid #EAEAEA; text-align: left" class="style1">Qtde.</th>
		</tr>
		<tr>
		<td style="border:1px solid #EAEAEA; text-align: left" class="style8">%t1.1%</td>
		<td style="border:1px solid #EAEAEA; text-align: left" class="style8">%t1.2%</td>
		<td style="border:1px solid #EAEAEA; text-align: left" class="style8">%t1.3%</td>
		</tr>
		</table>
		//EXEMPLO PARA ACRESCENTAR DUAS LINHAS AO MODELO HTML ACIMA
		*/
		Aadd(aLinha, { {'t1.1','Cod1'}, {'t1.2','Descr1'},{'t1.3','Qtde1'} })
		Aadd(aLinha, { {'t1.1','Cod2'}, {'t1.2','Descr2'},{'t1.3','Qtde3'} })
		Aadd(aLoop, aLinha)


		/*SETAR AS INFORMAÇÔES PARA O BODY*/
		oEmail:setHtmlBody('espelhoPedido\html\Espelho_pedido.htm', aCmps, aLoop)
		/***************************** FIM BODY HTML *************************/

		/*ADICIONAR ANEXOS AO EMAIL*/
		If ! oEmail:addAtach('\arquivo.txt'):lOk
			lOk 	:= oEmail:lOk
			cMsg	:= oEmail:cMsg
			u_autoAlert(cMsg)
		Else
			/*ENVIAR O EMAIL*/
			If !oEmail:goToEmail():lOk
				lOk 	:= oEmail:lOk
				cMsg	:= oEmail:cMsg
				u_autoAlert(cMsg)
			EndIf
		EndIf
	EndIf
return ({lOk,cMSg})

/******************  Exemplos da CLASSE errLog **************************/
User Function zErrLog()
	Local oErr := errLog():newerrLog()
	/* 
	::getMsgLog() = Obter MsgErro  
	::setStatus(lSts, cMSG) = Definir Status ( .T./ .F. ) e MsgErro 
	::itsOk() Verifica se esta tudo Ok
	::clearStatus() = Limpar status de erro
	*/
	/*
	errLog-->[{|X,LRESVALID,O| O := SELF:AENTRYCTRLS[3],(LRESVALID := IF(O:LMODIFIED .OR. (O:CARGO <> NIL .AND. O:CARGO <> M->M4_FORMULA),(A370VERFOR()),.T.)),(IF(TYPE('LREFRESH') == 'L' .AND. LREFRESH,SELF:ENCHREFRESHALL(),)),LRESVALID}<->A370VERFOR<->U_ZERRLOG<---->09/12/16 - 10:42:17 ] ERRO-01
	errLog-->[{|X,LRESVALID,O| O := SELF:AENTRYCTRLS[3],(LRESVALID := IF(O:LMODIFIED .OR. (O:CARGO <> NIL .AND. O:CARGO <> M->M4_FORMULA),(A370VERFOR()),.T.)),(IF(TYPE('LREFRESH') == 'L' .AND. LREFRESH,SELF:ENCHREFRESHALL(),)),LRESVALID}<->A370VERFOR<->U_ZERRLOG<---->09/12/16 - 10:42:17 ] ERRO-02
	errLog-->[{|X,LRESVALID,O| O := SELF:AENTRYCTRLS[3],(LRESVALID := IF(O:LMODIFIED .OR. (O:CARGO <> NIL .AND. O:CARGO <> M->M4_FORMULA),(A370VERFOR()),.T.)),(IF(TYPE('LREFRESH') == 'L' .AND. LREFRESH,SELF:ENCHREFRESHALL(),)),LRESVALID}<->A370VERFOR<->U_ZERRLOG<---->09/12/16 - 10:42:17 ] ERRO-03
	*/
	//Definir um Status e uma mensagem de erro
	oErr:setStatus(.F., 'ERRO-01')

	//Verificar se esta ok
	If oErr:itsOk()
		//TUDO OK
	Else
		//Obter a mensagem de erro
		oErr:getMsgLog()
	EndIf
	//Definir mais erros
	oErr:setStatus(.F., 'ERRO-02')
	oErr:setStatus(.F., 'ERRO-03')

	//Mensagem mostrando (ERRO-01 ERRO-02 ERRO-03)
	oErr:getMsgLog()

	//Limpar os status para um novo processamento
	oErr:clearStatus()

return(Nil)




/*****************EXEMPLOS ITEIS********************/
/*
//EXEMPLO UTILIZANDO as classes SqlUtil() para obter RECNO de um registro e o ManBaseDados()
//para atualizar algum campo deste registro

Local cRetorno := ""
Local oSql 	:= SqlUtil():newSqlUtil()
Local oBase := ManBaseDados():newManBaseDados()
Local oRet	:= Nil

oSql:addFromTab('SB1')
oSql:addCampos({'SB1.R_E_C_N_O_','B1_DESC'})
oSql:addWhere("B1_FILIAL = '' ")
oSql:addWhere("B1_COD = '" + cChave  +"' ")

If !oSql:QrySelect():lOk	
cRetorno := "Erro - Produto " + cChave + " Descrição: " + Alltrim(oRet[1]:B1_DESC) + " Não encontrado!"
Else
oRet := oSql:oRes
oBase:addCpoVlr('B1_XOPORT',cNovo)
If !oBase:updTable(oRet[1]:R_E_C_N_O_):lOk
cRetorno := "Erro - Produto " + cChave + " Descrição: " + Alltrim(oRet[1]:B1_DESC) + " Não foi atualizado!"
Else
cRetorno := "OK - Produto " + cChave + " Descrição: " + Alltrim(oRet[1]:B1_DESC) + " B1_XOPORT = " + cNovo
EndIF   
EndIf

FreeObj(oSql)
FreeObj(oBase)
*/