#include "rwmake.ch"
#Include 'Protheus.ch'


/*Ponto de Entrada para tratar Fuso Horario de Tres Lagoas para a transmissãoo da NFe
Juliana Leme - 29/01/2015
Se filial de 3Lagoas e emitido com Formulario Proprio
NFe ENTRADA*/

User Function MT103FIM()
	Local nOpcao     := PARAMIXB[1]   // Opção Escolhida pelo usuario no aRotina
	Local nConfirma  := PARAMIXB[2]   // Se o usuario confirmou a operação de gravação da NFE
	Local nHradd     := 1
	Local nDays      := 1
	Local nHoraSF1   := HoraToInt(Time())

	/*
	Local aRotBack 	 := AClone( aRotina )
	Local nBack    	 := N
	Private aRotina := {}

	//LEONARDO 25/02/16 - (24/03/16)- JEF não deve mais abrir automaticio agora e pela opção Ações Relacionadas.
	If nConfirma == 1 .And. nOpcao == 3
	N := 1
	Aadd(aRotina,{"Conhecimento","MsDocument", 0 , 1, 0 ,NIL})
	MsDocument( "SF1", SF1->(Recno()),1 )
	aRotina := AClone( aRotBack )
	N := nBack                                                           í
	EndIF
	//FIM LEONARDO
	*/
	If (SF1->F1_FILIAL = "02").And.nOpcao = 3.And.nConfirma = 1;
	.And.(SF1->F1_FORMUL = "S") //Filial Tres Lagoas e Opção Inclui e Confirma a Operação
		RecLock("SF1",.F.)
		SF1->F1_HORA := IntToHora(nHoraSF1-nHradd)
		MsUnLock()
	EndIf
Return

	/*Ponto de Entrada para tratar Fuso Horario de Tres Lagoas para a transmissãoo da NFe
	Roberto Oliveira 09/02/15
	Se filial de 3Lagoas e emitido com Formulario Proprio e a Hora for 0 não permite incluir o documento
	NFe ENTRADA*/
User Function MT140TOK() // Validar somente na inclusão de pre-nota
	Local lRet := .T.
Return(lRet)

/*/{Protheus.doc} MT100TOK
(Validações na entrada da NFe - NFe ENTRADA)
@type function
@author juliana.leme
@since 29/01/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/User Function MT100TOK()
	Local lRet := .T.
	lRet := VldProdEst()
	if lRet
		lRet := u_NFBudget()
	endif
Return(lRet)

/*
* Funcao		:	SX5NOTA
* Autor			:	João Zabotto
* Data			: 	11/02/2015
* Descricao		:
* Retorno		:
*/
User Function SX5NOTA()
	&& Variáveis do programa.
	Local aArea   := GetArea()
	Local lOk    := .T.
	Local cNiv    := ''

	//Valida Especie = ROM com Serie=ROM
	If Alltrim(FunName()) $ "MATA103|MATA140"
		If Alltrim(cEspecie) == 'ROM'
			If  Alltrim(SX5->X5_CHAVE)=="ROM"
				lOk    := .T.
			Else
				lOk    := .F.
			EndIf
		EndIf
		If Alltrim(cEspecie) == 'SPED'
			If  Alltrim(SX5->X5_CHAVE)=="1"
				lOk    := .T.
			Else
				lOk    := .F.
			EndIf
		EndIf
	EndIf
	RestArea(aArea)
Return (lOk)

Static Function VldProdEst()
	Local lRet := .T.
	Local lTesEst	:= .F.
	Local cTpNotEst	:= ""
	Local oArea		:= Nil
	Local cB1Tipo	:= ""
	
	//[LEO]-[DUMBFUCK-MATA103]-[18/11/16]-Não permitir classificar documento se campo F4_ESTOQUE == S e o B1_TIPO do item contido 
	//no parametro MV_ZZB1F4E
	cTpNotEst 	:= GetNewPar("MV_ZZB1F4E", '')
	If !Empty(cTpNotEst)
		oArea 		:= SigaArea():newSigaArea()	
		oArea:saveArea( {'SB1', 'SD1', 'SF4'} )
		For nX := 1 To Len(aCols)
			If !GDDeleted(nX) .And. !Empty(GDFieldGet("D1_TES",nX))	
				//Verificar se o TES movimenta estoque
				lTesEst := (Posicione("SF4",1, xFilial("SF4") + GDFieldGet("D1_TES",nX), 'F4_ESTOQUE') == 'S')
				If lTesEst
					//Obter o tipo do produto
					cB1Tipo := Posicione("SB1",1, xFilial("SB1") + GDFieldGet("D1_COD",nX), 'B1_TIPO')
					//Verificar se esta contido no parametro.
					If Alltrim(cB1Tipo) $ Alltrim(cTpNotEst)
						//Retornar o erro
						u_autoAlert('Não é permitido classificar/incluir documento, onde o TES movimenta estoque e o tipo do produto está contido em (MV_ZZB1F4E). '+;
						cTpNotEst,,'Box','MT103FIN()')
						lRet := .F.
					EndIf
				EndIF								
			EndIf
		Next nX
		oArea:backArea()
		FreeObj(oArea)
	EndIf
	//[LEO]-[DUMBFUCK-MATA103]-[18/11/16]-[FIM]
Return (lRet)

/*Ponto de Entrada para tratar Fuso Horario de Tres Lagoas para a transmissãoo da NFe
Juliana Leme - 29/01/2015
Se filial de 3Lagoas e emitido com Formulario Proprio e a Hora for 0 não permite incluir o documento
NFe SAIDA*/

User Function M410PVNF()
	Local lRet := .T.
	If ( cFilAnt = "02").And.(HoraToInt(Time())<1)
		lRet := .F.
		MsgBox("Horario não permitido para emissão de NFe nesta filial", "Atencao !!!", "INFO")
		MsgBox("Faturamento Cancelado!", "Atencao !!!", "INFO")
	EndIf
Return(lRet)



/*Ponto de Entrada para tratar Fuso Horario de Tres Lagoas para a transmissãoo da NFe
Juliana Leme - 29/01/2015
Se filial de 3Lagoas e emitido com Formulario Proprio e a Hora for 0 não permite incluir o documento
NFe SAIDA*/
User Function M460MARK()
	Local lRet := .T.
	If (cFilAnt = "02").And.(HoraToInt(Time())<1)
		lRet := .F.
		MsgBox("Horario não permitido para emissão de NFe nesta filial", "Atencao !!!", "INFO")
		MsgBox("Faturamento Cancelado!", "Atencao !!!", "INFO")
	EndIf
Return(lRet)

/*/{Protheus.doc} MTA920C
(APOS A GRAVACAO DO CABECALHO DA NOTA da NFe Saida pelo Livros Fiscais MATA920
Utilizado para gravar dados no SF2 apos a gravacao de todo o cabecalho e antes de destravar o arquivo)
@type function
@author juliana.leme
@since 30/01/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function MTA920C()
	Local aParamBox 	:= {} 
	Local aRet				 	:= {} 
	//Gravar Mensagem para a Nota
	If u_autoAlert("Deseja Informar Mensagem para a NF ?",.T.,'MsgBox','Confirma?',,'YesNo',.T.)
		aAdd(aParamBox,{1,"Msg NFe:",Space(100),"","","","",180,.F.})
		aAdd(aParamBox,{1,"Cont Msg:",Space(100),"","","","",180,.F.})
		aAdd(aParamBox,{1,"Cont(2)Msg:",Space(54),"","","","",100,.F.})
		If !ParamBox(aParamBox,"Mensagem NFe", @aRet)
			Return()
		EndIf
		SF2->F2_MENNOTA := aRet[1]+aRet[2]+aRet[3]
	EndIf
Return

/*/{Protheus.doc} MTA910I
(Utilizado apos gravacao de todos os dados da NF de Entrada digitada no modulo fiscal)
@type function
@author juliana.leme
@since 30/01/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function MTA910I()
	Local aParamBox 	:= {} 
	Local aRet				 	:= {} 
	//Gravar Mensagem para a Nota
	If u_autoAlert("Deseja Informar Mensagem para a NF ?",.T.,'MsgBox','Confirma?',,'YesNo',.T.)
		aAdd(aParamBox,{1,"Msg NFe:",Space(100),"","","","",180,.F.})
		aAdd(aParamBox,{1,"Cont Msg:",Space(100),"","","","",180,.F.})
		aAdd(aParamBox,{1,"Cont(2)Msg:",Space(54),"","","","",100,.F.})
		If !ParamBox(aParamBox,"Mensagem NFe", @aRet)
			Return()
		EndIf
		RecLock("SF1",.F.)
		SF1->F1_MENNOTA := aRet[1]+aRet[2]+aRet[3]
		MsUnLock()
	EndIf
Return
