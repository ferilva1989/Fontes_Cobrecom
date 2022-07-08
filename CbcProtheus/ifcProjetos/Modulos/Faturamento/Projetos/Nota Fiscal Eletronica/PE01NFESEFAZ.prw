#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"


/*/{Protheus.doc} PE01NFESEFAZ
//TODO Ponto de entrada para tratar as informações a serem enviadas pelo NFESEFAZ.
@author legado
@since 10/02/2015
@version 1.0

@type function
/*/
User Function PE01NFESEFAZ()
	/*/
	o PARAMIXB é carregado assim:


	aParam := {	aProd,		cMensCli,	cMensFis,	aDest,		aNota,;
	aInfoItem,	aDupl,		aTransp,	aEntrega,	aRetirada,;
	aVeiculo,	aReboque,	aPedCom,	_aChave}


	aParam := {	01-aProd,
	aProd possui um elemento para cada item e 41 elementos para cada item e
	serão trocados os elementos:
	01 	Item	02	SD2->D2_COD		03	AllTrim(_cCodBar) 	04	_cDesPro
	07	cD2Cfop	09  Quantidade		10	Total				25	SD2->D2_CNUMFCI // Número da FCI

	02-cMensCli,
	03-cMensFis,

	04-aDest,
	Dados do destinatário, possui 21 elementos
	Alterar o 16 - email

	05-aNota,
	Dados da nota com 6 elementos sendo:
	01 - Serie	02 - numero		03 - dt emissao	04 - Tipo (1 Saída - 2 entrada)
	05 - Tipo da nota (normal / devol / etc		06 - Hora de emissao

	06-aInfoItem,
	Possui um elemento para cada item e cada elemento possui 4 elementos sendo:
	01 - SD2->D2_PEDIDO		02 - SD2->D2_ITEMPV
	03 - SD2->D2_TES		04 - SD2->D2_ITEM

	07-aDupl,
	Possui um elemento para cada título e cada elemento possui 3 elementos sendo:
	01 - Prefixo+Num+Parcela		02 - Vencimento		03 - Valor

	08-aTransp
	Possui 7 elementos com os dados da transportadora
	01 - CNPJ 		02 - Nome		03 - IE
	04 - End		05 - Cidade		06 - UF		07 - Email

	09-aEntrega,
	10-aRetirada,
	11-aVeiculo,
	12-aReboque

	13-aPedCom
	Possui um elemento para cada item e dois elementos para cara elemento, sendo:
	01 - Nro.Pedido de Compra do Cliente		2-Item do Pedido de compra

	14 _aChave
	Chave da nota fiscal e tipo da nota

	01 cNota
	02 cSerie
	03 cClieFor
	04 cLoja
	05 cTipo} // By Roberto Oliveira
	/*/

	// Carrega variáveis da chave
	cNota    := aParam[22,01]
	cSerie   := aParam[22,02]
	cClieFor := aParam[22,03]
	cLoja    := aParam[22,04]
	cTipo    := aParam[22,05]
	
	
	If cTipo == "1" //cTipo == "1" // Nota fiscal de Saída
		// Posicionamento de tabelas
		DbSelectArea("SF2")
		DbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

		DbSeek(xFilial("SF2")+cNota+cSerie+cClieFor+cLoja)

		DbSelectArea(If(!SF2->F2_TIPO$"DB","SA1","SA2"))

		DbSeek(xFilial(If(!SF2->F2_TIPO$"DB","SA1","SA2")) + SF2->F2_CLIENTE + SF2->F2_LOJA,.F.)

		_cCtaMail := "copiafat@cobrecom.com.br;"
		If !SF2->F2_TIPO$"DB"
			_cCtaMail  += Lower(AllTrim(SA1->A1_EMAIL))
			If !Empty(SA1->A1_EMAILFI)
				_cCtaMail +=  If(!Empty(_cCtaMail),";","") + Lower(AllTrim(SA1->A1_EMAILFI))
			EndIf
		Else
			_cCtaMail  += Lower(AllTrim(SA2->A2_EMAIL))
		EndIf

		// Altera a conta de e-mail
		ParamIxb[04,16] :=  zChkEmail(_cCtaMail)

		// Altera a conta de email da transportadora
		If Len(ParamIxb[08]) > 0 // Tenho dados da Transportadora
			ParamIxb[08,07] := SA4->A4_EMAIL
		EndIf

		// Verificar os dados dos itens]
		DbSelectArea("SC5")
		DbSetOrder(1) // C5_FILIAL+C5_NUM

		DbSelectArea("SC6")
		DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

		DbSelectArea("SB1")
		DbSetOrder(1) // B1_FILIAL+B1_COD

		DbSelectArea("SD2")
		DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

		cMensBahia := If(SF2->F2_EST=="BA",	"Declaramos que não vendemos através de internet, telemarketing"+;
		" ou show-room. Temos representante comercial local.","")
		_cMsgFCI := ""
		cMensPed := ""
		cMensPCl := ""
		cEndEnt  := ""
		cMenNota := ""
		cMenNF   := ""
		_cLocaliz := ""
		_aCfOper := {}
		For _nnItem := 1 to Len(ParamIxb[06]) // 06-aInfoItem
			// D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			SD2->(DbSeek(xFilial("SD2")+SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA),.F.))
			Do While SD2->D2_FILIAL == xFilial("SD2") .And. SD2->(!Eof()) .And. ;
			SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)

				If SD2->D2_ITEM == ParamIxb[06,_nnItem,04]
					Exit
				EndIf
				SD2->(DbSkip())
			EndDo

			SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD,.F.))
			SC5->(DbSeek(xFilial("SC5")+SD2->D2_PEDIDO,.F.))
			SC6->(DbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV,.F.))

			If Empty(cMenNF)
				cMenNF := AllTrim(SC5->C5_X_MENNF)
			EndIf

			if !empty(SD2->D2_IDENTB6)
				cMenNF += " //Dev.Serie/NF Orig.:" + Alltrim(SD2->D2_SERIORI) + "/" + Alltrim(SD2->D2_NFORI)+;
						" Valor parcial desta operacao: " + Alltrim(Transform(SD2->D2_TOTAL,"@e 99,999,999.99"))	
			endif

			If Empty(cEndEnt)
				cEndEnt := AllTrim(AllTrim(SC5->C5_ENDENT1)+ " " + AllTrim(SC5->C5_ENDENT2))
				If !Empty(cEndEnt)
					cEndEnt := "Local Entrega: " + cEndEnt
				EndIf
			EndIf

			nScan := aScan(_aCfOper,{|x| x[1] == SD2->D2_CF})
			If nScan == 0
				Aadd(_aCfOper,{SD2->D2_CF,0})
				nScan := Len(_aCfOper)
			EndIf

			_aCfOper[nScan,2] += SD2->D2_TOTAL

			If !AllTrim(SC5->C5_NUM) $ cMensPed .And. !Empty(SC5->C5_NUM)
				If Empty(cMensPed)
					cMensPed := "Pedido(s).: " + SC5->C5_NUM
				Else
					cMensPed += ", " + SC5->C5_NUM
				EndIf
			EndIf

			If !(AllTrim(SC6->C6_PEDCLI) $ cMensPCl) .And. !Empty(SC6->C6_PEDCLI)
				If Empty(cMensPCl)
					cMensPCl := " O.C.: " + AllTrim(SC6->C6_PEDCLI)
				Else
					cMensPCl := cMensPCl + "," +  AllTrim(SC6->C6_PEDCLI)
				EndIf
			ElseIf !(AllTrim(SC5->C5_PEDCLI) $ cMensPCl) .And. !Empty(SC5->C5_PEDCLI)
				If Empty(cMensPCl)
					cMensPCl := " // O.C.: " + AllTrim(SC5->C5_PEDCLI)
				Else
					cMensPCl := cMensPCl + "," +  AllTrim(SC5->C5_PEDCLI)
				EndIf
			EndIf

			If !Empty(SB1->B1_ESPECIF)
				_cDesPro := u_CortaDesc(SB1->B1_ESPECIF)
			Else
				_cDesPro := u_CortaDesc(If(Empty(SC6->C6_DESCRI),SB1->B1_DESC,SC6->C6_DESCRI))
			EndIf
			
			//Código padrão tratado como SEM GTIN pelo TSS
			_cCodBar := "000000000000000"
			
			If AllTrim(SB1->B1_TIPO) == "PA"
			//Caso seja PA tentar localizar EAN. Ean genérico e para R00100 usado o B1_CODBAR, para demais acondicionamentos tentar localizar na SZJ o Ean.
				If AllTrim(SB1->B1_CODBAR) # AllTrim(SB1->B1_COD)
					_cCodBar := AllTrim(SB1->B1_CODBAR)
				EndIf
	
				DbSelectArea("SDB")
				DbSetOrder(1) // sdb->(DB_FILIAL+sdb->(DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM)
				If DbSeek(xFilial("SDB")+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA,.F.)
					_cDesPro := _cDesPro + "(" + AllTrim(SDB->DB_LOCALIZ) + ")"
					_cLocaliz:= "(" + AllTrim(SDB->DB_LOCALIZ) + ")"
					_cPrdBar := Left(AllTrim(SDB->DB_PRODUTO),10)
					_cPrdBar := PADR(_cPrdBar,TAMSX3("B1_COD")[1])
	
					If Empty(_cCodBar)
						DbSelectArea("SB1")
						__aAreaSB1 := GetArea()
						DbSetOrder(1)
						DbSeek(xFilial("SB1") + _cPrdBar,.F.)
						If AllTrim(SB1->B1_CODBAR) # AllTrim(SB1->B1_COD)
							_cCodBar := AllTrim(SB1->B1_CODBAR)
						EndIf
						RestArea(__aAreaSB1)
					EndIf
	
					_cCnpjNow := Left(If(!SF2->F2_TIPO$"DB",SA1->A1_CGC,SA2->A2_CGC),8)
					DbSelectArea("SZJ")
					DbSetOrder(1) // ZJ_FILIAL+ZJ_PRODUTO+ZJ_LOCALIZ
					If Left(SDB->DB_LOCALIZ,1) == "B" .And. (_cCnpjNow $ GetMv("MV_XTRCCOD"))
						// Se for bobina e o cliente quer código específico
						_DbLcliz := PADR("B",TAMSX3("DB_LOCALIZ")[1])
						If DbSeek(xFilial("SZJ") + _cPrdBar + _DbLcliz,.F.) // Procuro um código genério de bobina
							_cCodBar := AllTrim(SZJ->ZJ_CODBAR)
						Else // Crio um genérico para bobina
							_cCodBar := u_NewSzj(_cPrdBar,_DbLcliz)
						EndIf
					Else // Se não for bobina ou o cliente não quer código específico - Procuro um código exato
						If DbSeek(xFilial("SZJ") + _cPrdBar + SDB->DB_LOCALIZ,.F.) // Procuro o código exato
							// Achei um cara exato - Ótimo!!!
							_cCodBar := AllTrim(SZJ->ZJ_CODBAR)
						ElseIf Left(SDB->DB_LOCALIZ,1) == "B"
							_DbLcliz := PADR("B",TAMSX3("DB_LOCALIZ")[1])
							If DbSeek(xFilial("SZJ") + _cPrdBar + _DbLcliz,.F.) // Procuro um código genério de bobina
								_cCodBar := AllTrim(SZJ->ZJ_CODBAR)
							Else
								// Crio um genérico para bobina
								_cCodBar := u_NewSzj(_cPrdBar,_DbLcliz)
							EndIf
						EndIf
					EndIf
				EndIf
				If Len(_cCodBar)==12
					_cCodBar := Trim(_cCodBar)+eandigito(Trim(_cCodBar))
				EndIf
			EndIf	
									
			ParamIxb[01,_nnItem,46] := _cCodBar
			//Para os produto com EANTrib (B5_2CODBAR)
			If !Empty(ParamIxb[01,_nnItem,45])
				ParamIxb[01,_nnItem,45] := _cCodBar
			EndIf
			// a TAG da descrição aceita até 120 posições
			_cDesPro := AllTrim(Left(_cDesPro + Space(120),120))

			// Alteração de 13/10/14 by Roberto Oliveira
			// No caso de NFe para a Huawei, a descrição do material tem que constar
			// PO line, PO Shipment e BOM Code dos produtos
			// PO line e PO Shipment vem de C6_ITPDCLI e C6_POSHPHU, respectivamente. Já o BOM Code
			// tem que ser procurado no SA7 o campo A7_CODCLI
			If "HUAWEI" $ Upper(Posicione("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME"))
				SA7->(DbSetOrder(1)) // A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_PRODUTO
				// Procurar no SA7 sempre os produtos cadastrados para o cliente 014642-04"
				_cPrdHwy := Left(Left(SD2->D2_COD,10) + Space(Len(SB1->B1_COD)),Len(SB1->B1_COD))
				If SA7->(DbSeek(xFilial("SA7")+SC5->C5_CLIENTE+SC5->C5_LOJACLI+_cPrdHwy,.F.))
					_cDesPro :=  AllTrim(SC6->C6_ITPDCLI) + "|" + AllTrim(SC6->C6_POSHPHU) + "|" +;
					AllTrim(SA7->A7_CODCLI) + "|" + _cDesPro
				Else
					Alert("O Item "+SD2->D2_ITEM + " não possui Codigo e Descrição complementar conforme solicitação do cliente.")
					Alert("A transmissão da NFe sera interrompida. Favor corrigir e retransmitir!")
					_ContTrans := .F.
				EndIf
			ElseIf SC5->C5_CLIENTE+SC5->C5_LOJACLI $ GetMV("MV_CLNFPRO")
				SA7->(DbSetOrder(1)) // A7_FILIAL+A7_CLIENTE+A7_LOJA+A7_PRODUTO
				If SA7->(DbSeek(xFilial("SA7")+SC5->C5_CLIENTE+SC5->C5_LOJACLI+Left(SD2->D2_COD,16),.F.))
					_cDesPro :=  Alltrim(SA7->A7_CODCLI) + " - " + Alltrim(SA7->A7_DESCCLI) + _cLocaliz
				ElseIf SA7->(DbSeek(xFilial("SA7")+SC5->C5_CLIENTE+SC5->C5_LOJACLI+Left(SD2->D2_COD,10),.F.))
					_cDesPro :=  Alltrim(SA7->A7_CODCLI) + " - " + Alltrim(SA7->A7_DESCCLI) + _cLocaliz
				Else
					Alert("O Item "+SD2->D2_ITEM + " não possui Codigo e Descrição complementar conforme solicitação do cliente.")
					Alert("A transmissão da NFe sera interrompida. Favor corrigir e retransmitir!")
					_ContTrans := .F.
				EndIf
			EndIf

			ParamIxb[01,_nnItem,04] := _cDesPro

			If !Empty(SC6->C6_PEDCLI) .Or. !Empty(SC5->C5_PEDCLI) // By Roberto 17/07/14
				If Len(ParamIxb[21,_nnItem]) == 0
					aadd(ParamIxb[21,_nnItem],"")
					aadd(ParamIxb[21,_nnItem],"0")
				EndIf
				If !Empty(SC6->C6_PEDCLI)
					ParamIxb[21,_nnItem,01] := SC6->C6_PEDCLI //aPedCom
				ElseIf !Empty(SC5->C5_PEDCLI) // By Roberto 17/07/14
					ParamIxb[21,_nnItem,01] := SC5->C5_PEDCLI //aPedCom
				EndIf
				If !Empty(SC6->C6_ITPDCLI)
					ParamIxb[21,_nnItem,02] := SC6->C6_ITPDCLI //aPedCom
				EndIf
			EndIf
		Next

		_cParam02 := ParamIxb[02] // Se houver alguma informação -> vai pro final
		ParamIxb[02] := ""

		If (cMenNota $ _cParam02) .And. !Empty(cMenNota)
			// Retiro
			_cParam02 := AllTrim(StrTran(_cParam02,cMenNota,""))
		EndIf

		If !Empty(ParamIxb[02]) .And. !Empty(cEndEnt) // 02-cMensCli
			ParamIxb[02] += " // " + cEndEnt
		ElseIf !Empty(cEndEnt)
			ParamIxb[02] := cEndEnt
		EndIf

		If !Empty(ParamIxb[02]) .And. !Empty(cMensPCl) // 02-cMensCli
			ParamIxb[02] += " // " + cMensPCl
		ElseIf !Empty(cMensPCl)
			ParamIxb[02] := cMensPCl
		EndIf
		If !Empty(ParamIxb[02]) .And. !Empty(cMensPed) // 02-cMensCli
			ParamIxb[02] += " // " + cMensPed
		ElseIf !Empty(cMensPed)
			ParamIxb[02] := cMensPed
		EndIf
		If !Empty(ParamIxb[02]) .And. !Empty(cMensBahia) // 02-cMensCli
			ParamIxb[02] += " // " + cMensBahia
		ElseIf !Empty(cMensBahia)
			ParamIxb[02] := cMensBahia
		EndIf
		If !Empty(ParamIxb[02]) .And. !Empty(SF2->F2_CDCARGA) // 02-cMensCli
			ParamIxb[02] += " // Nro.Carga: " + SF2->F2_CDCARGA
		ElseIf !Empty(cMensBahia)
			ParamIxb[02] := "Nro.Carga: " + SF2->F2_CDCARGA
		EndIf

		If !(cMenNota $ ParamIxb[02]) .And. !Empty(cMenNota) // 02-cMensCli
			If !Empty(ParamIxb[02])
				ParamIxb[02] += " // " + cMenNota
			Else
				ParamIxb[02] := cMenNota
			EndIf
		EndIf
		If !(cMenNF $ ParamIxb[02]) .And. !Empty(cMenNF) // 02-cMensCli
			If !Empty(ParamIxb[02])
				ParamIxb[02] += " // " + cMenNF
			Else
				ParamIxb[02] := cMenNF
			EndIf
		EndIf

		//Imprime informações de entrega na mensagem da NFe
		If !Empty(SC5->C5_XTELENT)
			If !Empty(ParamIxb[02])
				ParamIxb[02] += " // " + Alltrim(SC5->C5_XTELENT)
			Else
				ParamIxb[02] := Alltrim(SC5->C5_XTELENT)
			EndIf
		EndIf

		// Devolvo o que estava no ParamIxb[02]
		If !(_cParam02 $ ParamIxb[02]) .And. !Empty(_cParam02) // 02-cMensCli
			If !Empty(ParamIxb[02])
				ParamIxb[02] += " // " + _cParam02
			Else
				ParamIxb[02] := _cParam02
			EndIf
		EndIf

		If Len(_aCfOper) == 1 // Só tem um cara
			_cMaior := _aCfOper[1,1]
		Else
			_cMaior := ""
			_nMaior := 0
			For _nCf := 1 To Len(_aCfOper)
				If _aCfOper[_nCf,2] > _nMaior
					_nMaior := _aCfOper[_nCf,2]
					_cMaior := _aCfOper[_nCf,1]
				EndIf
			Next
		EndIf
		//Mensagem do SAC na NFe
		//Conforme solicitação do SAC (Andreia) em 01/09/2016
		//0800-7023163 do SAC em caso de reclamações/sugestões
		ParamIxb[02] += " \\ SAC: 0800-702-3163 ou e-mail: sac@cobrecom.com.br "
		//Ajusta Caracteres especiais
		ParamIxb[02] := cbcAcTexto(ParamIxb[02])
		if (ParamIxb[04, 11] <> '1058')
			u_cbcExpAdj(@ParamIxb[01], @ParamIxb[14])
		endif
	Else // Nota Fiscal de entrada
		dbSelectArea("SF1")
		dbSetOrder(1) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM

		If DbSeek(xFilial("SF1")+cNota+cSerie+cClieFor+cLoja)
			DbSelectArea("CD5")
			DbSetOrder(1) // CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_DOCIMP
			If DbSeek(xFilial("CD5")+cNota+cSerie+cClieFor+cLoja,.F.)
				If !Empty(CD5->CD5_OBS1)
					ParamIxb[02] += " " + AllTrim(CD5->CD5_OBS1)
				EndIf
				If !Empty(CD5->CD5_OBS2)
					ParamIxb[02] += " " + AllTrim(CD5->CD5_OBS2)
				EndIf
				If !Empty(CD5->CD5_OBS3)
					ParamIxb[02] += " " + AllTrim(CD5->CD5_OBS3)
				EndIf
				If !Empty(CD5->CD5_OBS4)
					ParamIxb[02] += " " + AllTrim(CD5->CD5_OBS4)
				EndIf
				If !Empty(CD5->CD5_OBS5)
					ParamIxb[02] += " " + AllTrim(CD5->CD5_OBS5)
				EndIf
				If !Empty(CD5->CD5_OBS6)
					ParamIxb[02] += " " + AllTrim(CD5->CD5_OBS6)
				EndIf
			EndIf
		EndIf
		//Ajusta Caracteres especiais
		ParamIxb[02] := cbcAcTexto(ParamIxb[02])
		
		For _nnItem := 1 to Len(ParamIxb[06]) // 06-aInfoItem

			DbSelectArea("SD1")
			DbSetOrder(1) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
			DbSeek(xFilial("SD1")+cNota+cSerie+cClieFor+cLoja)

			Do While SD1->D1_FILIAL == xFilial("SD1") .And. SD1->(!Eof()) .And. ;
			SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == cNota+cSerie+cClieFor+cLoja

				If SD1->D1_ITEM == ParamIxb[06,_nnItem,04]
					Exit
				EndIf
				SD1->(DbSkip())
			EndDo

			_cDesPro :=	IIf(!Empty(SD1->D1_DESCRI),SD1->D1_DESCRI,SB1->B1_DESC)
			_cDesPro := AllTrim(Left(_cDesPro + Space(120),120))
			ParamIxb[01,_nnItem,04] :=  _cDesPro
		Next
	EndIf	
Return(ParamIxb)


/*/{Protheus.doc} zChkEmail
@author bolognesi
@since 22/12/2016
@version 1.0
@param _cCtaMail, String , Email(s) a ser validado
@type function
@description Regra de validação Versão 01-(22/12/16)
1-> Emails dominio @cobrecom.com.br sempre retornam positivo( .T. )
2-> Todos os endereços devem ser analisados, e caso invalido retirado
da string de retorno.
3-> Emails validados com sucesso permanecem na string de retorno.
4-> Emails não validados além de excluidos da string de retorno deve
ser enviado um e-mail de aviso para (vania/ti) informando a situação
negativa do endereço de email.
5-> A string de retorno nunca deve retornar vazio.
6-> Caso apos a validação não restar nenhum e-mail válido o retorno
devera ser o e-mail default nfeavisos@cobrecom.com.br.
7-> Esta função recebe auxilio dos metodos da classe emailBounce
que valida a escrita do endereço de email e tambem se o endereço existe.
/*/
static function zChkEmail(_cCtaMail)
	Local cRet 			:= ""
	Local oVldEmail 	:= Nil
	Local _cVolta 		:= ""
	Local cVldEmail		:= ""
	Local lOn			:= GetNewPar('MV_EMLBNCE', .T.)
	Default _cCtaMail	:= ""

	/*Quando a validação estiver desligada pelo parametro apenas retorna a string recebida*/
	If !lOn
		cRet := _cCtaMail
	Else
		/*Endereço de email fixo, enviar os erros e o proprio documento fiscal*/
		_cVolta 	:= GetNewPar('MV_GPWRNNF', 'nfeavisos@cobrecom.com.br')

		/*Caso o email estiver vazio retorna o endereço fixo e avisa sobre estar vazio*/
		If Empty(_cCtaMail)
			cRet := _cVolta
			envAviso(_cVolta, 'Cadastro', "[NFE-EMAIL] - Email não preenchido no cadastro" )
		Else
			/*Iniciar as classes necessarias*/
			oVldEmail 	:= emailBounce():newemailBounce()
			/*Preparar a string de email*/
			cVldEmail 	:= Alltrim(lower(_cCtaMail))
			/*Realiza a validação do Email*/
			If ! oVldEmail:allValid(cVldEmail):lOk
				/*Avisar sobre os erros*/
				envAviso(_cVolta, oVldEmail:cMsg, "[NFE-EMAIL] - STATUS DE ENVIO" )
			EndIf
			/*Verifica quais email validos a classe retornou*/
			If !Empty(oVldEmail:cEmailOk)
				cRet := oVldEmail:cEmailOk
			Else
				/*A Classe não retornou nenhum email valido utiliza o fixo*/
				cRet := _cVolta
			EndIF
		EndIf
	EndIf
return(cRet)

/*/{Protheus.doc} envAviso
@author bolognesi
@since 23/12/2016
@version 1.0
@param _cVolta, , Endereço de email do destino
@param cMSg, characters, Mensagem de erro a ser enviada
@param cSubject, characters, Assunto do email
@type function
@description Enviar o email de acordo com as necessidades
/*/
Static Function envAviso(_cVolta, cMSg, cSubject )
	Local oEmail 		:= Nil
	Local cTxtHtml		:= ""

	oEmail 	:= cbcSendEmail():newcbcSendEmail()
	oEmail:iniSrvMsg()
	oEmail:setFrom(_cVolta)
	oEmail:setTo(_cVolta)
	oEmail:setcSubject(cSubject)
	oEmail:setPriority(5)
	cTxtHtml := obterTexto( cMSg, .T.)
	oEmail:setcBody(cTxtHtml)
	/*De fato realiza o envio do email*/
	If !oEmail:goToEmail():lOk
		/*Em caso de erro ao enviar o email logar o erro no console*/
		cTxtSimp := obterTexto(cMSg, .F.)
		ConOut( 'ERRO [' + oEmail:cMsg + '] '  + cSubject + DtoC(Date())+" - "+Time()+" - "+ cTxtSimp)
	EndIf
return (Nil)

/*/{Protheus.doc} obterTexto
@author bolognesi
@since 23/12/2016
@version 1.0
@param cDetalhes, characters, Detalhes retornados pela classe email
@param lHtml, logical, Formatar o retorno em html
@type function
@description Realiza a formatação da mensagem para mandar email(html)
ou exibir no error do console (conout)
/*/
Static function obterTexto(cDetalhes, lHtml)
	Local cTxt 		:= ""
	Local cCod		:= ""
	Local cLoja		:= ""
	Local cNome		:= ""
	Local cTexto	:= ""
	Local cDcto		:= ""
	cDcto := SF2->('Filial: ' + F2_FILIAL + ' Documento: ' + F2_DOC +' Serie: ' + F2_SERIE )

	If !SF2->(F2_TIPO)$"DB"
		cTexto	:= 'CLIENTE'
		cCod	:= Alltrim(SA1->(A1_COD))
		cLoja	:= Alltrim(SA1->(A1_LOJA))
		cNome 	:= Alltrim(SA1->(A1_NOME))
	Else
		cTexto	:= 'FORNECEDOR'
		cCod	:= Alltrim(SA2->(A2_COD))
		cLoja	:= Alltrim(SA2->(A2_LOJA))
		cNome 	:= Alltrim(SA2->(A2_NOME))
		//TODO tratar transportadora e outras entidades ???
	EndIF

	If lHtml
		cTxt += '<p><h1>'+ cTexto  +'</h1></p>'
		cTxt += '<p><h2> [CODIGO: '+ cCod  + ' LOJA: ' +  cLoja + ']</h2></p>'
		cTxt += '<p><h3> ['+ cNome  +  '] </h3></p>'
		cTxt += '<p><h3> ['+ cDcto  +  '] </h3></p>'
		cTxt += '<p>' + cDetalhes + '</p>'
	Else
		cTxt += cTexto
		cTxt += '[CODIGO: '+ cCod  + ' LOJA: ' +  cLoja + ']' + chr(13)
		cTxt += '[NOME: '+ cNome  +  ']' + chr(13)
		cTxt += '['+ cDcto  +  ']' + chr(13)
		cTxt += cDetalhes
	EndIf
return (cTxt)

static function cbcAcTexto(cTexto)
	local nX	 := 0
	default cTexto := ""
	
	if !empty( cTexto )
		for nX := 127 to 255
			cTexto := StrTran( cTexto, Chr( nX ), " " )
		next
	endif
return(cTexto)
