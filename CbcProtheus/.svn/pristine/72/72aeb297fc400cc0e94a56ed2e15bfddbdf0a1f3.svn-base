#include "rwmake.ch"


/*/{Protheus.doc} MTA410
//TODO Validação do Pedido de Venda//INCLUSÃO CHAMOU ANTES DOS OBRIGATÓRIOS//chamou no ok de alterar.
@author juliana.leme
@since 01/06/2017
@version undefined

@type function
/*/
User Function MTA410()
	Local aArea		:= getArea()
	Local aSC6		:= SC6->(GetArea())
	Local ocbcPed	:= nil					//LEO-07/10/16
	Public _aCols2      //não usar este
	Public _lTdPed     // Tudo da outra filial?
	Public _cMyNmEmp

	If (Inclui) .and. (!isInCallStack('U_ZCBVIEWPED')) // Botões incluir ou Cópia
		// Verificar se é inclusao por cópia e se os campos
		// C5_SEMANA, C6_SEMANA, C6_DTRESUMO, C6_DTPROGR e C6_DTEPA  estão preenchidos... não podem estar pois ai não entram em resumo
		If M->C5_DRC == 0 .Or. M->C5_DRCPROD == "S" // Tem uma devolução mas vai produzir
			M->C5_SEMANA  := CriaVar("C5_SEMANA")
		EndIf
		//[LEO] - 27/10/16 - Na divisão não estava gravando as informações abaixo
		If !U_isDivid() 
			M->C5_USERINC := CriaVar("C5_USERINC")
			M->C5_DTINC   := CriaVar("C5_DTINC")
			M->C5_USERALT := CriaVar("C5_USERALT")
			M->C5_DTALT   := CriaVar("C5_DTALT")
			M->C5_DTLICRE := CriaVar("C5_DTLICRE")
			M->C5_DATALIB := CriaVar("C5_DATALIB")
			M->C5_DTPCP   := CriaVar("C5_DTPCP")
			M->C5_DTVEN   := CriaVar("C5_DTVEN")
		EndIF
		For _nN := 1 To Len(aCols)
			If GDFieldPos("C6_RES_SZZ") # 0 .And. (M->C5_DRC == 0 .Or. M->C5_DRCPROD == "S") // Tem uma devolução mas vai produzir
				_cNrRes := GDFieldGet("C6_RES_SZZ",_nN)
				_cPvori := GDFieldGet("C6_ZZPVORI",_nN)
				If Empty(_cNrRes) .And. GDFieldPos("C6_SEMANA") # 0 .And. Empty(_cPvori) .And. Alltrim(GDFieldGet("C6_SEMANA",_nN)) # 'TAUTOM'
					GDFieldPut("C6_SEMANA",Space(Len(SC6->C6_SEMANA)),_nN)
				EndIf
			ElseIf GDFieldPos("C6_RES_SZZ") # 0 .And. M->C5_DRCPROD == "N" // Tem uma devolução e não vai produzir
				_cNrRes := GDFieldGet("C6_RES_SZZ",_nN)
				If Empty(_cNrRes) .And. GDFieldPos("C6_SEMANA") # 0
					GDFieldPut("C6_SEMANA","DRC-NPd",_nN)
				EndIf
			EndIf
			If GDFieldPos("C6_DTRESUMO") # 0
				GDFieldPut("C6_DTRESUMO",Ctod(""),_nN)
			EndIf
			If GDFieldPos("C6_DTPROGR") # 0
				GDFieldPut("C6_DTPROGR",Ctod(""),_nN)
			EndIf
			//		If GDFieldPos("C6_DTEPA") # 0
			//			GDFieldPut("C6_DTEPA",Ctod(""),_nN)
			//		EndIf
		Next
	EndIf

	// Verificar se tem algum campo obrigatório não preenchido... Usar AGETS
	For nI := 1 to Len(aGets)
		If Substr(aGets[nI],25,1) == "T" //Campo obrigatorio = T
			_cVarObr := "M->"+AllTrim(Substr(aGets[nI],09,10))
			If Empty(&_cVarObr)
				Return(.T.)
			EndIf
		EndIf
	Next



	_aCols2 := {}
	_lTdPed := .T.   // Tudo da outra filial?

	If Type("_cMyNmEmp") == "U"
		_cMyNmEmp := cNumEmp
	EndIf

	If Type("lPvAuto") == "U"
		lPvAuto := .F.
	EndIf

	_Volta := .T.
	If !lPvAuto
		If Altera
			M->C5_USERALT := cUserName
			M->C5_DTALT   := MsDate()
			If !Empty(SC5->C5_DTPCP) .Or. !Empty(SC5->C5_DTVEN)
				If MsgBox("Libera Pedido Produção/Expedição?","Confirma?","YesNo")
					M->C5_DTPCP   := Ctod("//")
					M->C5_DTVEN   := Ctod("//")
				EndIf
			EndIf
		EndIf
	EndIf
	M->C5_TOTAL := 0
	For _nN := 1 To Len(aCols)
		If !GDDeleted(_nN)
			M->C5_TOTAL += GDFieldGet("C6_VALOR",_nN)
		EndIf
	Next

	_CNPJCli := Left(Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_CGC"),8)
	_UFCli   := Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_EST")
	_lConstr := (Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_CONTRUT") == "S")
	_lTotal  := ((M->C5_DESCESP+M->C5_DESCEQT) == 0) // Incluido em 20/09/10 não pode ter descontos


	/*
	Email de Denise de 19/08/13 10:57h

	Daniela:

	Conversei com Rafael e o mesmo confirmou a mudança do faturamento com destino para o estado de Mato Grosso:

	Até hoje era:  Faturado por Três Lagoas com ICMS de 12%
	Mudou para : Materiais fabricados em Três Lagoas serão faturados de lá para Mato Grosso com ICMS de 4%
	Materiais não fabricados em Três Lagoas serão faturados e despachados por Itú para Mato
	Grosso com ICMS de 7%.

	ROBERTO:
	Favor alterar o sistema para o atendimento desta mudança, observando que : além de serem faturados pelas
	2 unidades um mesmo pedido, a parte que sair de Três Lagoas será do importado.

	Claudecir/Marcelo:
	Favor já estudando a logística e negociação de preços dos fretes.

	Obrigada,
	/*/


	/*/
	Email de Denise  de 01/09/14 18:07h enviado	também para Jeferson, Juliano, Vania, Claudecir, Daniela e marcelo
	- As mensagens separadas por -**- são os respectivos encaminhamentos.

	Boa tarde, Roberto/Jeferson:

	Após reunião do Rafael com o departamento comercial ficaram definidas algumas mudanças para faturamento,
	segue abaixo o email da Daniela (quem participou e passa as informações ).
	OBS: Favor providenciar então as travas no sistema, pois as exceções serão trabalhadas através de C.I.(s)
	assinadas pela diretoria, travar faturamento para Norte- Nordeste- Centro Oeste só pela filial;
	Travar faturamento para Sul- Sudeste só pela matriz.
	Travar as alíquotas de ICMS-  Mato Grosso     ( alíquota de importado)
	Demais estados (alíquota nacional).

	Desde já, obrigada.

	-**-

	De: Daniela (Cobrecom) [mailto:daniela.p@cobrecom.com.br]
	Enviada em: segunda-feira, 1 de setembro de 2014 14:33
	Para: denise@cobrecom.com.br
	Cc: rafael@cobrecom.com.br; 'Cobrecom Mauro'; claudecir@cobrecom.com.br; marcelo@cobrecom.com.br;
	crispilho@cobrecom.com.br
	Assunto: RES: Faturamento Filial

	Para o estado do Mato Grosso (MT) será c/ ICMS de 4%.
	Para os demais estados serão c/ ICMS de 12% mas podendo ter alguns clientes que serão negociados com
	ICMS de 4% mediante C.I. assinada pela diretoria.

	Construtoras c/ ICMS de 17%.

	Os materiais não fabricados lá saíram daqui com NF de remessa p/ industrialização devolvido com nossa carreta conforme acertado entre diretoria e Claudecir.

	Att,

	-**-

	De: Denise Ap Pereira Bonanni [mailto:denise@cobrecom.com.br]
	Enviada em: segunda-feira, 1 de setembro de 2014 14:23
	Para: daniela.p@cobrecom.com.br
	Cc: rafael@cobrecom.com.br; 'Cobrecom Mauro'; claudecir@cobrecom.com.br; marcelo@cobrecom.com.br;
	crispilho@cobrecom.com.br

	Assunto: RES: Faturamento Filial

	Boa tarde, Daniela:

	Você sabe me informar qual a alíquota de ICMS que será destacada, a diretora estipulou? Será alíquota de
	importado ou de nacional?

	No aguardo, obrigada.

	-**-

	De: Daniela (Cobrecom) [mailto:daniela.p@cobrecom.com.br]
	Enviada em: segunda-feira, 1 de setembro de 2014 13:41
	Para: denise@cobrecom.com.br
	Cc: rafael@cobrecom.com.br; 'Cobrecom Mauro'; claudecir@cobrecom.com.br; marcelo@cobrecom.com.br; crispilho@cobrecom.com.br
	Assunto: Faturamento Filial

	Denise, boa tarde.

	Em reunião ficou estipulado pela diretoria que todos os pedidos do Nordeste / Norte / Centro-Oeste devem ser cadastrados pela filial inclusive Construtoras. Em caso de alguma exceção haverá a emissão de uma C.I. assinada pela diretoria.

	Também não haverá mais separação dos pedidos do Mato Grosso, os mesmos somente serão cadastrados pela filial.

	Favor informar a T.I. para as devidas providencias.

	Fico no aguardo.

	Att,


	/*/

	/*/
	Em cumprimento ao e-mail acima, estou alterando o conteúdo de _lTotal para .F. para não mais executar a
	rotina abaixo, uma vez que os pedidos não mais serão "quebrados" automaticamente, ou seja quando um pedido
	é digitado que qualquer uma das filiais o sistema avalia quais produtos são fabricados em outra filial e
	inclui um pedido com tais itens na outra filial.

	Caso esta funcionalidade volte a ser executada, corrigir a User Function MT410INC() e retirar a variável
	lQuebraPV e o If lQuebraPV / EndIf

	/*/

	/********* LEONARDO 13/10/2016 DIV PEDIDOS (SOMENTE PEDIDOS NORMAIS)*****/
	_lTotal := .F. 
	IF M->(C5_TIPO) == 'N'
		ocbcPed := cbcPedido():newcbcPedido() //Este metodo tambem define Aliq ICMS (C6_ZZPICM)
		if !ocbcPed:lselfOk
		   If !ocbcPed:lVldCli
				FreeObj(ocbcPed)
				return(.F.)
			EndIF
		EndIf
	EndIf
	/***************************************************************************/

	If _Volta .And. _UFCli == "MT" .And. M->C5_TIPO == "N" .And. !_lConstr .And. ;
	_CNPJCli # "03840986" .And. Inclui .And. _lTotal
		// Construmega tem que faturar por ITU... Welington 13/07/10 // Inclui->Roberto 16/09/10

		nTotMS := 0
		nTotSP := 0

		For nCount := 1 to Len(aCols )
			If !GDDeleted(nCount) // Não esta deletado
				cProd  := GDFieldGet("C6_PRODUTO")  //pega o conteudo do campo no acols
				cPrdCor := Substr(GDFieldGet("C6_PRODUTO",nCount),6,2)

				// Condição para incluir pedido de venda na filial 02 ( 3 lagoas )
				If u_Tem3Lag(cProd,cPrdCor)
					nTotMS := nTotMS + GDFieldGet("C6_VALOR",nCount)
				Else
					nTotSP := nTotSP + GDFieldGet("C6_VALOR",nCount)
				EndIf
			EndIf
		Next

		If nTotSP >= 3000 .And. nTotMS >= 4000
			_lTdPed  := .F. // Não é tudo para outra filial - Repartir o Pedido
		ElseIf nTotSP > nTotMS
			// Vai tudo pra SP
			nTotSP := nTotSP + nTotMS
			nTotMS := 0
			If cFilAnt == "02" // Se estou ewm 3L
				_lTdPed  := .T. // Tudo para outra filial
			EndIf
		ElseIf nTotSP <= nTotMS
			// Vai tudo pra MS
			nTotMS := nTotMS + nTotSP
			nTotSP := 0
			If cFilAnt == "01" // Se estou em Itu
				_lTdPed  := .T. // Tudo para outra filial
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Regra                                                                    ³
		//³ Não faz nada se não passar das condições SP = 0 ou >= 2000 e MS >= 3000  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (cFilAnt == "01" .And. nTotMS > 0) .Or. (cFilAnt == "02" .And. nTotSP > 0)

			// Tem alfo para outra filial

			If _lTdPed .And. cFilAnt == "01"
				MsgInfo("Pedido será faturado totalmente por 3 Lagoas." +Chr(13)+Chr(10),"Ponto Entrada MTA410")
			ElseIf _lTdPed .And. cFilAnt == "02"
				MsgInfo("Pedido será faturado totalmente Itu." +Chr(13)+Chr(10),"Ponto Entrada MTA410")
			ElseIf !(_lTdPed)
				MsgInfo("Pedido será faturado por Itu e 3 Lagoas." +Chr(13)+Chr(10),"Ponto Entrada MTA410")
			EndIf

			// Somente preciso separar se tiver itens na matriz e na filial
			If !_lTdPed // Aqui

				//Fazer outro pedido de venda em outra filial
				_aCols2 := {}
				M->C5_TOTAL := 0
				For nCount := 1 to Len(aCols)

					If !GDDeleted(nCount) // Não esta deletado

						cProd := Left(GDFieldGet("C6_PRODUTO",nCount),5)  //Linha do produto
						cPrdCor := Substr(GDFieldGet("C6_PRODUTO",nCount),6,2)

						// Condição para incluir pedido de venda na outra filial

						_lTem3L := u_Tem3Lag(cProd,cPrdCor)
						If (cFilAnt == "01" .And.  _lTem3L) .Or. ;
						(cFilAnt == "02" .And. !_lTem3L)
							// Se estou em Itu e tem em 3L     OU
							// Estou em 3L e não tem em 3L
							aAdd(_aCols2,array(Len(aCols[1]))) //Monta a linha de _aCols2 identico ao aCols

							For nCols := 1 to Len(aCols[nCount])
								_aCols2[Len(_aCols2),nCols] := aCols[nCount,nCols]
							Next
							aCols[nCount,Len(aCols[nCount])] := .T. // Informa que linha esta deletada do acols.
						Else
							M->C5_TOTAL += GDFieldGet("C6_VALOR",nCount)
						EndIf
					EndIf
				Next

				U_M410LIOK() // Corrige o custo do pedido de venda

			Else // SÓ Por outra filial
				_cMyNmEmp := cNumEmp
				If cFilAnt == "01"
					// Criar pedido em 3L
					cNumEmp := Left("0102"+Space(30),Len(cNumEmp))  // crio o pedido na outra filial
					cFilAnt := "02"
				ElseIf cFilAnt == "02"
					// Criar pedido em Itu
					cNumEmp := Left("0101"+Space(30),Len(cNumEmp))  // crio o pedido na outra filial
					cFilAnt := "01"
				EndIf

				SM0->(DbSeek(Left(cNumEmp,4),.F.))

				//Pego numero do pedido de venda da filial
				// E gravo no acols caso exista este campo
				cPV02 := Space(6)
				Do While .T.
					cPV02 := GetSx8Num("SC5","C5_NUM")
					ConfirmSX8()
					If !SC5->(DbSeek(xFilial("SC5")+cPV02,.F.))
						Exit
					EndIf
				EndDo
				M->C5_NUM := cPV02
				If cFilAnt == "01"
					MsgInfo("Pedido Itu = " +cPV02,"Ponto Entrada MTA410")
				ElseIf cFilAnt == "02"
					MsgInfo("Pedido 3 Lagoas = " +cPV02,"Ponto Entrada MTA410")
				EndIf

				//Gravo numero do PV (C5_NUM) caso exista no SC6
				nLinNum := 0
				For nElem := 1 to Len(aHeader)
					If Alltrim(aHeader[nElem,2]) == "C6_NUM"
						nLinNum := nElem
						Exit
					EndIf
				Next
				If nLinNum > 0
					For nElem := 1 to Len(aCols)
						aCols[nElem,nLinNum] := M->C5_NUM
					Next
				EndIf
				u_M410LIOK() // Corrige o custo do pedido de venda
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
	RestArea(aSC6)

	Return(_Volta)
	*
	*********************
User Function AtuC5()
	*********************
	*
	DbSelectArea("SC5")
	DbSetOrder(1)

	DbSelectArea("SC6")
	DbSetOrder(1)
	DbSeek(xFilial("SC6"),.F.)
	Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->(!Eof())
		_NumPed := SC6->C6_NUM
		_TotPed := 0
		Do While SC6->C6_FILIAL == xFilial("SC6") .And. SC6->(!Eof()) .And. SC6->C6_NUM == _NumPed
			_TotPed += SC6->C6_VALOR
			SC6->(DbSkip())
		EndDo
		DbSelectArea("SC5")
		If DbSeek(xFilial("SC5") + _NumPed,.F.)
			If _TotPed # SC5->C5_TOTAL
				RecLock("SC5",.F.)
				SC5->C5_TOTAL :=  _TotPed
				MsUnLock()
			EndIf
		EndIf
	EndDo
	Alert("Terminei")
Return(.T.)


/*/{Protheus.doc} Tem3Lag
//TODO 	Produtos que são fabricados em 3 Lagoas
@author legado
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cProd, characters, descricao
@param cPrdCor, characters, descricao
@type function
/*/
User Function Tem3Lag(cProd,cPrdCor)
	Local lRet := .F.
	
	lRet := U_fWhereMn(cProd)<>"1"
Return(lRet)


/*/{Protheus.doc} NTemItu
//TODO Produtos que NÃO são fabricados em Itu.
@author Legado
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}
@param cProd, characters, descricao
@type function
/*/
User Function NTemItu(cProd)
	Local lRet := .F.
	
	lRet := U_fWhereMn(cProd)=="2"
Return(lRet)
