#include "rwmake.ch"
#include "protheus.ch"
#define END_MAIL 2
#define MUDOU 	 1
#define LINHA  CHR(13)

#DEFINE cEOL CHR(13) + CHR(10)

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: MyMta030                           Modulo : SIGAFAT      //
//                                                                          //
//                                                    Data ..:    //
//                                                                          //
//   Objetivo ...: Utilizados os pontos de entrada para gravar as inclu-    //
//                 sões, alterações ou exclusões no cadastro de clientes    //
//                 na tabela ZZ1.                                           //
//                                                                          //
//   Uso ........: Especifico da Cobrecom                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////



/*/{Protheus.doc} M030INC
//TODO Ponto de entrada na inclusão de cliente:
			Se clicar em OK, a variável PARAMIXB = 0 e INCLUI = .T. e os dados já estão gravados no SA1 e ainda esão em memória
			Se clicar em FECHAR (sair sem gravar), a variável PARAMIXB = 3 (abandona)
@author legado
@since 29/07/2014
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function M030INC()

	Local _aArea 		:= GetArea()
	Local aDados 		:= {}
	Local dData  		:= ctod("01/01/80")
	Local cItem 		:= ""
	local oVarejo		:= nil
	Local lMsErroAuto 	:= .F.
	Local lMsHelpAuto 	:= .T.

	If Inclui .And. PARAMIXB == 0
		GraveZZ1()
		oVarejo := cbcVarejoCliente():newcbcVarejoCliente()
		oVarejo:chkFromAlias()
		if !( lRet := oVarejo:isOk() )
			MessageBox( oVarejo:getErrMsg(), "M030INC - Varejo", 48)
		endif
		freeObj(oVarejo)
	EndIf


	/////////////////////////////////////////////////////////////////////////
	//                                                                     //
	//  Função.....: M030INC                          Módulo..: TODOS      //
	//                                                                     //
	//  Autor......: Zabotto 			              Data....: 12/04/2011 //
	//                                                                     //
	//  Descrição..: Ponto de Entrada na confirmação da inclusão do        //
	//               cliente para criar a Conta Contábil no Plano de Contas//
	//                                                                     //
	//  Alteração....:Leonardo Bolognesi Data:...19/08/2014                //
	//  Quando ocorrer o cadastro de cliente realiza a inclusão na         //
	//  tabela CTD(Item contabil) via rotina padrão, apos preenche o campo //
	//	SA1->A1_ZZITEM com Alltrim("C"+SA1->(A1_COD+A1_LOJA))              //
	//
	/////////////////////////////////////////////////////////////////////////

	cItem := Alltrim("C"+SA1->(A1_COD+A1_LOJA))

	aadd(aDados,{"CTD_ITEM"    ,cItem 			,Nil})
	aadd(aDados,{"CTD_DESC01"   ,SA1->A1_NOME ,Nil})
	aadd(aDados,{"CTD_CLASSE"   ,"2"			,Nil})
	aadd(aDados,{"CTD_NORMAL"   ,"1"			,Nil})
	aadd(aDados,{"CTD_DTEXIS"   ,dData 		,Nil})
	aadd(aDados,{"CTD_ITSUP"   ,"C"				,Nil})

	Begin Transaction
		MSExecAuto({|x,y| CTBA040(x,y)},aDados,3)

		If lMsErroAuto
			DisarmTransaction()
		EndIf

		If Reclock( "SA1" , .F.)
			SA1->A1_ZZITEM:= cItem
			MsUnlock()
		EndIf
	End Transaction

Return(.T.)


/*/{Protheus.doc} M030ALT
//TODO Ponto de entrada na alteração do Cliente.
			Chamado ao clicar em ALTERAR, antes de abrir a tela para digitação, que serve para guardar os dados do SA1
			que está sendo alterado para poder fazer a comparação do que foi alterado no PE M030PALT.
			A variável PARAMIXB = NIL e Altera == .T.
@author Legado
@since 10/09/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function M030ALT()
	Public _aCposSA1 := {}
	_aArea := GetArea()
	DbSelectArea("SA1")
	_nTamTab := FCount()
	For j := 1 To _nTamTab
		Aadd(_aCposSA1,FieldGet(j))
	Next
	RestArea(_aArea)
Return(.T.)


/*/{Protheus.doc} M030PALT
//TODO Ponto de entrada chamado na saída da rotina de alteração de cliente, tanto confirmando ou cancelando
			Se for confirmado, a variável PARAMIXB[1] = 1 e Altera = .T. - os DADOS ALTERADOS já estão gravados no SA1 e
			as variáves liberadas (M->A1_NOME, etc...).
			Se cancelou, a variável PARAMIXB[1] = 3.
@author Legado
@since 10/09/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function M030PALT()

	If Altera .And. PARAMIXB[1] == 1 // Confirmou a alteração
		// Fazer a comparação do que for alterado e gravar no ZZ1
		_aArea := GetArea()
		DbSelectArea("SA1")
		_nTamTab := FCount()
		For j := 1 To _nTamTab
			If _aCposSA1[j] # FieldGet(j)
				_cCpo := AllTrim(FieldName(j))
				_cVal1 := _aCposSA1[j]
				_cVal2 := FieldGet(j)
				DbSelectArea("SX3")
				DbSetOrder(2)
				DbSeek(_cCpo,.F.)
				_cCpo := AllTrim(SX3->X3_TITULO) + "(" + _cCpo + ")"
				If SX3->X3_TIPO == "N"
					_cVal1 := AllTrim(Str(_cVal1,SX3->X3_TAMANHO,SX3->X3_DECIMAL))
					_cVal2 := AllTrim(Str(_cVal2,SX3->X3_TAMANHO,SX3->X3_DECIMAL))
				ElseIf SX3->X3_TIPO == "C"
					_cVal1 := AllTrim(_cVal1)
					_cVal2 := AllTrim(_cVal2)
				ElseIf SX3->X3_TIPO == "D"
					_cVal1 := Dtoc(_cVal1)
					_cVal2 := Dtoc(_cVal2)
				ElseIf SX3->X3_TIPO == "L"
					_cVal1 := If(_cVal1,"Verdadeiro","Falso")
					_cVal2 := If(_cVal2,"Verdadeiro","Falso")
				EndIf
				GraveZZ1(_cCpo,_cVal1,_cVal2)
				DbSelectArea("SA1")
			EndIf
		Next
		RestArea(_aArea)
	EndIf
Return(.T.)


/*/{Protheus.doc} M030EXC
//TODO Ponto de entrada chamado na CONFIRMAÇÃO DA EXCLUSãO do cadastro do cliente..
@author Legado
@since 10/09/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function M030EXC()
	Local _aArea := GetArea()
	Local aDados := {}
	Local dData  := ctod("01/01/80")
	Local cItem := ""
	Local lMsErroAuto := .F.
	Local lMsHelpAuto := .T.


	// 

	GraveZZ1() //// APOS CONFIRMAR A EXCLUSÃO ... USAR ESTE

	cItem := Alltrim("C"+SA1->(A1_COD+A1_LOJA))
	aadd(aDados,{"CTD_ITEM"    ,cItem 			,Nil})
	aadd(aDados,{"CTD_DESC01"   ,SA1->A1_NOME ,Nil})
	aadd(aDados,{"CTD_CLASSE"   ,"2"			,Nil})
	aadd(aDados,{"CTD_NORMAL"   ,"1"			,Nil})
	aadd(aDados,{"CTD_DTEXIS"   ,dData 		,Nil})
	aadd(aDados,{"CTD_ITSUP"   ,"C"				,Nil})

	Begin Transaction
		MSExecAuto({|x,y| CTBA040(x,y)},aDados,5)
		If lMsErroAuto
			DisarmTransaction()
		EndIf
	End Transaction

Return(.T.)


/*/{Protheus.doc} MY030TOK
//TODO Ponto de Entrada na confirmação da inclusão e
			alteração do cliente para criar, logica de preenchimento entre os
			campos (A1_CONSTRUT e A1_SEGMENT), Obs: Existe um gatilho no campo 
			A1_SEGMENT com esta mesma funcionalidade, utilizado este PE para   
			garantir  	   													   
			Descrição(28/12/16)..: Validar o preenchimento e a existencia dos  
			endereços de e-mail preenchidos nos campos: (A1_EMAIL, A1_EMAILCT, 
			A1_EMAILFI) utilizando a função estatica vldEmail()  que usa a 	   
			classe emailBounce.					   							   
			Observação..: A função MA030TOK, que é o ponto de entrada otiginal  
			esta em outro projeto (Cobrecom_Portal), lá deixei como estava e    
			realiza uma chamada para a função neste fonte
@author Leonardo
@since 28/12/2016 
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function MY030TOK()
	local aArea		:= GetArea()
	local cContrut	:= ""
	local lRet 		:= .T.
	local cMsg		:= ""
	local cUser		:= ""
	local cSegAnt	:= ""
	local cSegAtu	:= ""
	local cConsAnt	:= ""
	local dDt
	local dHora

	//Primeiro verifica validação do email depois o restante
	If !vldEmail()
		lRet 		:= .F.
	else
		if Empty(M->A1_SEGMENT)
			lRet := .F.
		elseIf M->A1_SEGMENT == '03' .And. M->A1_CONTRUT <> 'S'
			lRet := .F.
		elseIf M->A1_CONTRUT $ 'S' 	 .And. M->A1_SEGMENT <> '03'
			lRet := .F.
		endIf

		if !lRet

			MessageBox("[ALERTA]-Verifique divergência nos campos Construtora e Segmento, ou Segmento vazio!", "MY030TOK", 48)

		else
			if inclui
				cMsg:= 'Inclusão'
			elseIf altera
				cSegAnt		:= 	Alltrim(Posicione("SX5",1,xFilial("SX5")+ "ZK" + SA1->A1_SEGMENT	,"X5_DESCRI" ))
				cConsAnt	:=	SA1->A1_CONTRUT
				cMsg		:= 'Alteração'
			else
				cMsg:= 'Outros'
			endif

			cSegAtu		:= Alltrim(Posicione("SX5",1,xFilial("SX5")+ "ZK" + M->A1_SEGMENT	,"X5_DESCRI" ))
			cUser 		:= Alltrim( UsrRetName(__CUSERID))
			dDt			:= Alltrim(cValToChar(Date()))
			dHora		:= Alltrim(cValToChar(Time()))

			u_envmail({"wfti@cobrecom.com.br"}, "[MANUT.]-Cad.Clientes", {"Nome","Cod_Loja","Operação","Construtora", "Segmento", "Usuario","Data", "Hora"};
			,{{Alltrim(M->(A1_NOME)), M->(A1_COD+"-"+A1_LOJA),cMsg, "De: " + cConsAnt + " Para: " + M->A1_CONTRUT,;
			"De: " + cSegAnt + "  Para: " + cSegAtu ,cUser,dDt,dHora}} )

		endIf
	endIf
	restarea(aArea)
return(lRet)

/*/{Protheus.doc} vldEmail
@author bolognesi
@since 28/12/2016
@version 1.0
@type function
@description Função utilizada para validar os campos
(A1_EMAIL, A1_EMAILCT,A1_EMAILFI), utilizando a classe
emailBounce()
/*/
Static Function vldEmail()
	Local lRet		:= .T.
	Local cMsgErr	:= ""
	Local oVldEmail := Nil
	Local aEmail	:= ""
	Local lEmail	:= .T.
	Local aContato	:= ""
	Local lContato	:= .T.
	Local aFin		:= ""
	Local lFin		:= .T.
	local lOn		:= GetNewPar('MV_EMLBNA1', .T.)

	/*Somente validar quando parametro estiver ativo, trabalha em conjunto com MV_EMLBNCE
	chave liga/desliga da classe de validação geral emailBounce() */
	If lOn
		aEmail 		:= hasChange(M->(A1_EMAIL) 	, 'A1_EMAIL'	)
		aContato 	:= hasChange(M->(A1_EMAILCT), 'A1_EMAILCT'	)
		aFin		:= hasChange(M->(A1_EMAILFI), 'A1_EMAILFI'	)

		/*Iniciar as classes necessarias*/
		oVldEmail 	:= emailBounce():newemailBounce()

		/*Validar o email da NFe*/
		If aEmail[1,MUDOU]
			If ! oVldEmail:allValid(aEmail[1,END_MAIL]):lOk
				cMsgErr +='Email Nota Fiscal inválido' + LINHA	
				lEmail := .F.
			EndIf
		EndIf

		/*Validar o email de contato*/
		If aContato[1,MUDOU]
			/*Email de contato igual o email Nfe que já foi validado*/
			If aContato[1,END_MAIL] == aEmail[1,END_MAIL]
				lContato := lEmail
				If !lContato
					cMsgErr +='Email Contato inválido' + LINHA
				EndiF 
			Else
				If ! oVldEmail:allValid(aContato[1,END_MAIL]):lOk
					cMsgErr +='Email Contato inválido'	+ LINHA
					lContato := .F.
				EndIf
			EndIf
		EndIf

		/*Validar o email do financeiro*/
		If aFin[1,MUDOU]
			/*Email do financeiro igual ao email nfe já validado*/
			If aFin[1,END_MAIL] == aEmail[1,END_MAIL]
				lFin := lEmail
				If !lFin
					cMsgErr +='Email Financeiro inválido' + LINHA
				EndiF 
				/*Email do financeiro igual ao email contato já validado*/
			ElseIf aFin[1,END_MAIL] == aContato[1,END_MAIL]
				lFin := lContato
				If !lFin
					cMsgErr +='Email Financeiro inválido' + LINHA
				EndiF
				/*Não é igual utiliza a classe para validar*/
			Else
				If ! oVldEmail:allValid(aFin[1,END_MAIL]):lOk
					cMsgErr +='Email Financeiro inválido'	+ LINHA
					lFin := .F.
				EndIf
			EndIf
		EndIf
		/*Verificação final */
		If !lEmail .OR. !lContato .Or. !lFin  
			lRet := .F.
			u_autoAlert(cMsgErr,.F.,'Msg')
			//TODO Perguntar ao usuario se quer continuar??
		EndIf
		/*Liberar o objeto da memoria*/
		FreeObj(oVldEmail)
	EndIf
return (lRet)


/*/{Protheus.doc} hasChange
@author bolognesi
@since 28/12/2016
@version 1.0
@param cVlr, characters, Valor do campo para verificar igualdade
@param cCampo, characters, Campo a ser verificado na tabela SA1
@type function
@description Verificar se o campo sofreu algum tipo de alteração
evitando de validar em situação que o campo não foi alterado.
/*/
Static Function hasChange(cVlr, cCampo)
	Local aRet	:= {}
	Local lRet	:= .T.
	Local cTmp	:= ""
	cTmp := Posicione("SA1",1,xFilial("SA1")+ M->(A1_COD + A1_LOJA), cCampo)
	If Empty(cTmp)
		lRet := .T.
	Else
		If cVlr == cTmp
			lRet := .F.
		Else
			lRet := .T.
		EndIf   
	EndIf
	AAdd(aRet, {lRet, Alltrim(lower(cVlr))} )
	return (aRet)


Static Function GraveZZ1(_cCpo,_cVal1,_cVal2)
	// Os parâmetros _cCpo,_cVal1,_cVal2 somente são utilizados em caso de alteração.
	_MyaArea := GetArea()
	DbSelectArea("ZZ1")
	RecLock("ZZ1",.T.)
	ZZ1->ZZ1_FILIAL := xFilial("ZZ1")
	ZZ1->ZZ1_UNID   := CriaVar("ZZ1_UNID")
	ZZ1->ZZ1_DATA   := Date()
	ZZ1->ZZ1_HORA   := Left(Time(),Len(ZZ1->ZZ1_HORA))
	ZZ1->ZZ1_USUARI := CriaVar("ZZ1_USUARI")
	ZZ1->ZZ1_CLIENT := SA1->A1_COD
	ZZ1->ZZ1_LOJA   := SA1->A1_LOJA
	ZZ1->ZZ1_NOME   := SA1->A1_NOME
	ZZ1->ZZ1_TPINVE := If(Inclui,"04",If(Altera,"05","06"))
	ZZ1->ZZ1_DESCIN := Posicione("SX5",1,xFilial("SX5")+"ZL"+ZZ1->ZZ1_TPINVE,"X5_DESCRI")
	If Altera
		_Obs := "Alterado campo " + _cCpo + " de " + _cVal1 + " para " + _cVal2
		ZZ1->ZZ1_HIST := _Obs
	Endif
	MsUnLock()
	RestArea(_MyaArea)
Return(.T.)   


/*/{Protheus.doc} MAltCli

PE após a Alteração de Clientes

@author victorhugo
@since 16/03/2016
/*/
user function MAltCli()
	CbcCustomerService():updateProspectStatus(SA1->A1_CGC)
	
	oVarejo := cbcVarejoCliente():newcbcVarejoCliente()
	oVarejo:chkFromAlias()
	if !( lRet := oVarejo:isOk() )
		MessageBox( oVarejo:getErrMsg(), "MAltCli - Varejo", 48)
	endif
	freeObj(oVarejo)
return
