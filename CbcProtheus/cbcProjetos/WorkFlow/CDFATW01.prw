#include "rwmake.ch"
#include "protheus.ch"
#include "TOPCONN.ch"
#include "tbiconn.ch"


//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDFATW01                           Modulo : SIGAFAT      //
//                                                                          //
//   Autor ......: Roberto Oliveira                   Data ..: 14/04/2014   //
//                                                                          //
//   Objetivo ...: WF dos pedidos de vendas para pedidos com status de BV,  //
//                 BF e não faturados para os respectivos responáveis.      //
//                 Este WF é emitido com o mesmo formato do relatório Car-  //
//                 teira de Pedidos CDFATR03, porém listando somente as di  //
//                 vergências.                                              //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

User Function CDFATW01(aParam) //  u_CDFATW01({.T.,.T.})
Local _lAuto := .T., _lVai := .T.
Private  cPerg  := "CDFTW01"
Private _dDtNow := Date()
Private _cTmNow := Left(Time(),5)
Private _cNomArq := "" // Arquivo Temporario
Private _aCampos := {}
Default aParam := {{.F.,.F.}}

_lAuto := aParam[1,1]
_lVai  := aParam[1,2]

If !_lAuto // Chamou pelo menu
	// Definir os parâmetros
	ValidPerg()
	If !Pergunte(cPerg,.T.)
		Return(.T.)
	EndIF
Else
	PREPARE ENVIRONMENT EMPRESA aParam[2] FILIAL aParam[3]
	MV_PAR01 := 9

	DbSelectArea("SX6")
	If !Dbseek(FWCodFil()+"MV_IFCATRZ",.F.)
		Dbseek("  MV_IFCATRZ",.F.)
	EndIf

	If SX6->(Eof())
		Reclock("SX6",.T.)
		SX6->X6_VAR     := "MV_IFCATRZ"
		SX6->X6_TIPO := "C"
		SX6->X6_CONTEUD := "01/01/80-00:00"
		SX6->(MsUnlock())

		Reclock("SX6",.F.)
		SX6->X6_DESCRIC := "Data e hora do próximo envio de e-mail"
		SX6->X6_DSCSPA  := "Data e hora do próximo envio de e-mail"
		SX6->X6_DSCENG  := "Data e hora do próximo envio de e-mail"
		SX6->X6_DESC1   := "."
		SX6->X6_DSCSPA1 := "."
		SX6->X6_DSCENG1 := "."
		SX6->X6_DESC2  	:= "."
		SX6->X6_DSCSPA2 := "."
		SX6->X6_DSCENG2 := "."
		SX6->X6_PROPRI  := "U"
		SX6->X6_PYME    := "N"
	ElseIf !Reclock("SX6",.F.)
		Return(.T.)
	EndIf
EndIf

If !_lAuto // Chamou pelo menu
	If MsgBox("Deseja Iniciar o Processamento?","Confirma?","YesNo")
		Processa({|| PrepTRB()})
	Else
		Return(.T.)
	EndIf
Else
	PrepTRB()
EndIf

If MV_PAR01 # 9
	Processa({|| SendDados(MV_PAR01)})
Else
	SendDados(MV_PAR01)
EndIf

DbSelectArea("TRB")
DbCloseArea()

Return(.T.)
*
*************************
Static Function PrepTRB()
*************************
*
_aCampos := {}
aAdd(_aCampos, {"FILIAL" , "C", TamSX3("C5_FILIAL")[1]	, 0})	// Filial do sistema
aAdd(_aCampos, {"PEDIDO" , "C", TamSX3("C5_NUM")[1]		, 0})	// Numero do Pedido de Venda
aAdd(_aCampos, {"CODCLI" , "C", TamSX3("C5_CLIENTE")[1]	, 0})	// Código do Cliente
aAdd(_aCampos, {"LOJA"   , "C", TamSX3("C5_LOJACLI")[1]	, 0})	// Loja do Cliente
aAdd(_aCampos, {"NOME"   , "C", 30						, 0})	// Nome do Cliente
aAdd(_aCampos, {"REPRES" , "C", 30						, 0})	// Nome do Cliente
aAdd(_aCampos, {"ATEND"  , "C", 30						, 0})	// Nome do Cliente
aAdd(_aCampos, {"EMISSA" , "C", 18						, 0})	// Data de Emissao do Pedido
aAdd(_aCampos, {"ENTREG" , "D", 08						, 0})	// Data de Entrega Prevista
aAdd(_aCampos, {"DTEPA2" , "D", 08						, 0})	// Data de Entrega Prevista no EPA
aAdd(_aCampos, {"VRVENDA", "N", 15						, 2})	// Total do pedido pelo valor de venda
aAdd(_aCampos, {"VRLIBER", "N", 15						, 2})	// Total do pedido liberado
aAdd(_aCampos, {"VRPADRA", "N", 15						, 2})	// Total do pedido padrao
aAdd(_aCampos, {"OCORR"  , "C", 01						, 0}) // Qual atraso 1-BV, 2-BV 3-Entrega
aAdd(_aCampos, {"PRAZO"  , "C", 18						, 0}) // Quando deveria estar liberado
aAdd(_aCampos, {"ATRASO" , "C", 10						, 0})	// Qual Atraso? 128 horas / 10 dias
aAdd(_aCampos, {"ATRAZO" , "C", 10						, 0})	// Este campo será chave de indice para eu poder ordenar do maior para o menor
aAdd(_aCampos, {"PEDPORT" , "C", TamSX3("C5_DOCPORT")[1], 0})// Numero do Documento no portal relacionado
aAdd(_aCampos, {"MOTRJ"   , "C", 100					, 0})// Motivo da Rejeição da analise de credito
// atraso -> Funciona como atraso inverso (nivinv, lembra?)

If Select("TRB") > 0
	DbSelectArea("TRB")
	DbCloseArea()
EndIf

_cNomArq := CriaTrab(_aCampos, .T.)
DbUseArea(.T.,, _cNomArq, "TRB", .T., .F.)

Private _cInd := CriaTrab(Nil, .F.)
IndRegua("TRB", _cInd, "OCORR+FILIAL+ATRAZO+NOME",,, "Selecionando Registros...")

DbSelectArea("ZZI")
DbSetOrder(2)  //ZZI_FILIAL+ZZI_CODEVE+ZZI_PEDIDO+ZZI_ITEMPV

DbSelectArea("SA1")
DbSetOrder(1)  //A1_FILIAL+A1_COD+A1_LOJA

DbSelectArea("SA3")
DbSetOrder(1)  //A3_FILIAL+A3_COD

DbSelectArea("SC9")
DbSetOrder(1)  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

DbSelectArea("SC6")
DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

DbSelectArea("SC5")
DbSetOrder(1)  //C5_FILIAL+C5_NUM

If Select("RSC5") > 0
	DbSelectArea("RSC5")
	DbCloseArea("RSC5")
EndIf

cQUERY := "SELECT C5.C5_FILIAL,C5.C5_NUM,C6.C6_QTDVEN,C6.C6_QTDENT,C6.C6_PRCVEN "
cQUERY += "FROM " + RetSqlName("SC5") + " C5, " + RetSqlName("SC6") + " C6," + RetSqlName("SF4") + " F4 "
cQUERY += "WHERE "
cQUERY += "C6.C6_NUM = C5.C5_NUM AND C6.C6_FILIAL = C5.C5_FILIAL AND "
cQUERY += "C6.C6_TES = F4.F4_CODIGO AND F4.F4_FILIAL = '" + xFilial("SF4") + "' AND "
cQUERY += "(F4.F4_ESTOQUE = 'S' OR F4.F4_DUPLIC = 'S') AND "
cQUERY += "C6.C6_QTDVEN > C6.C6_QTDENT AND C6.C6_BLQ <> 'R ' AND "
cQUERY += "C5.C5_TIPO = 'N' AND C5.C5_LIBEROK <> 'E' AND C5.C5_NOTA = '         ' AND "
cQUERY += "C5.D_E_L_E_T_ <> '*' AND C6.D_E_L_E_T_ <> '*' AND F4.D_E_L_E_T_ <> '*' "
cQUERY += "ORDER BY C5.C5_FILIAL,C5.C5_NUM "
TCQUERY cQuery NEW ALIAS "RSC5"

If MV_PAR01 # 9
	Count to nQuery
	ProcRegua(nQuery)
EndIf

dbSelectArea("RSC5")
dbGoTop()

_nPrzBV := GetMv("MV_IFCHRBV") // Prazo em horas para liberação de vendas
_nPrzBF := GetMv("MV_IFCHRBF") // Prazo em horas para liberação de Crédito

_AliasC5 := "RSC5"
Do While RSC5->(!Eof())
	_cNumFl := RSC5->C5_FILIAL
	_cNumPd := RSC5->C5_NUM
	_nSldPed := 0
	// Como pode pegar vários registros do mesmo C5, guardo o nro e vou para o próximo
	// Abaixo a rotina trabalha somente com a variável _cNumPd
	Do While RSC5->(!Eof()) .And. RSC5->C5_FILIAL == RSC5->C5_FILIAL .And. 	RSC5->C5_NUM == _cNumPd
		If MV_PAR01 # 9
			IncProc()
		EndIf
		_nSldPed += (Max((RSC5->C6_QTDVEN-RSC5->C6_QTDENT),0)*RSC5->C6_PRCVEN)
		RSC5->(DbSkip())
	EndDo
	SC5->(DbSetOrder(1))  //C5_FILIAL+C5_NUM
	SC5->(DbSeek(_cNumFl+_cNumPd,.F.))
	SC9->(DbSetOrder(1))  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	// 1 -  Verifico se ainda não foi liberado por vendas
	If !SC9->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM,.F.)) // Não tem SC9 desse pedido, então não foi liberado
		/*/
		 Procuro no ZZI a data e hora da inclusão do pedido
		 Códigos do ZZI:
			Aadd(_aEventos,"01-Inclusao  de Pedidos")			// OK
		/*/
		ZZI->(DbSetOrder(2)) //ZZI_FILIAL+ZZI_CODEVE+ZZI_PEDIDO+ZZI_ITEMPV
		If ZZI->(DbSeek(SC5->C5_FILIAL+"01"+SC5->C5_NUM,.F.))
			// Localizar a última inclusão desse nro, pois pode cancelar e incluir um novo
			// com o mesmo nro.
			_dDtBase := Ctod("")
			_cHrBase := " "
			Do While ZZI->ZZI_FILIAL == SC5->C5_FILIAL .And. ZZI->ZZI_CODEVE == "01" .And.;
			         ZZI->ZZI_PEDIDO == SC5->C5_NUM    .And. ZZI->(!Eof())
				If ZZI->ZZI_DATA > _dDtBase
					_dDtBase := ZZI->ZZI_DATA
					_cHrBase := ZZI->ZZI_HORA
				ElseIf ZZI->ZZI_DATA == _dDtBase .And. ZZI->ZZI_HORA > _cHrBase
					_cHrBase := ZZI->ZZI_HORA
				EndIf
				ZZI->(DbSkip())
			EndDo
		Else
			_dDtBase := SC5->C5_EMISSAO
			_cHrBase := "17:00"
		EndIf
		_dEmm := _dDtBase
		_cHmm := _cHrBase

		// Adiciono à data e hora base a quantidade de horas "úteis" para saber se agora é maior.
		// Se for está atrasado
		_aDtHrLim := AdHrsUtil(_dDtBase,_cHrBase,_nPrzBV) // Retorna {dt,hr}

		// Verifico se está atrasado
		_cAgora := Dtos(_dDtNow) + Left(_cTmNow,5)
		_cPzLim := Dtos(_aDtHrLim[1]) + Left(_aDtHrLim[2],5)

		If _cAgora > _cPzLim // Está atrasado
			_cPrzVen := u_SubtHoras(_aDtHrLim[1],_aDtHrLim[2],_dDtNow,_cTmNow) // Atrasado Lib.Vendas em horas BV
			GraveTRB(1,_dEmm,_cHmm,_aDtHrLim[1],_aDtHrLim[2],_cPrzVen)
			Loop
		EndIf
	EndIf
	If Empty(SC5->C5_DTLICRE) // Liberação de crédito não realizada
		// 2 -  Verifico se ainda não foi liberado por crédito
		// 	Aadd(_aEventos,"05-Liberacao Pedido (Credito)")
    	// Primeiro verificar se o pedido não está com crédito REJEITADO

		_lVerCre := .T.
		_lRejeit := .F.
		_dDtRej  := Ctod("")
		If SC9->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM,.F.))
			Do While SC9->C9_FILIAL == SC5->C5_FILIAL .And. SC9->C9_PEDIDO == SC5->C5_NUM .And. SC9->(!Eof())
				If SC9->C9_BLCRED $ "  //10" .And. _lVerCre // Liberado / Já Faturado
					_lVerCre := .F. // Não considerar o pedido atrasado
				ElseIf SC9->C9_BLCRED == "09" // Rejeitado
					_lVerCre := .F. // Não considerar o pedido atrasado
					_lRejeit := .T. // Informo que está rejeitado para não considerar como atraso na produção
					_dDtRej  := SC9->C9_DATALIB
					Exit
				EndIf
				SC9->(DbSkip())
			EndDo
		EndIf

		If _lRejeit // Rejeitado
			If ZZI->(DbSeek(SC5->C5_FILIAL+"01"+SC5->C5_NUM,.F.))
				// Localizar a última inclusão desse nro, pois podecancelar e incluir um novo
				// com o mesmo nro.
				_dDtBase := Ctod("")
				_cHrBase := " "
				Do While ZZI->ZZI_FILIAL == SC5->C5_FILIAL .And. ZZI->ZZI_CODEVE == "01" .And.;
				         ZZI->ZZI_PEDIDO == SC5->C5_NUM    .And. ZZI->(!Eof())
					If ZZI->ZZI_DATA > _dDtBase
						_dDtBase := ZZI->ZZI_DATA
						_cHrBase := ZZI->ZZI_HORA
					ElseIf ZZI->ZZI_DATA == _dDtBase .And. ZZI->ZZI_HORA > _cHrBase
						_cHrBase := ZZI->ZZI_HORA
					EndIf
					ZZI->(DbSkip())
				EndDo
			Else
				_dDtBase := SC5->C5_EMISSAO
				_cHrBase := "12:00"
			EndIf
			_dEmm := _dDtBase
			_cHmm := _cHrBase

			ZZI->(DbSeek(SC5->C5_FILIAL+"10"+SC5->C5_NUM,.F.)) // 10-Analise Credito Rejeicao
			// Localizar a última rejeição desse pedido
			Do While ZZI->ZZI_FILIAL == SC5->C5_FILIAL .And. ZZI->ZZI_CODEVE == "10" .And.;
			         ZZI->ZZI_PEDIDO == SC5->C5_NUM    .And. ZZI->(!Eof())
				If ZZI->ZZI_DATA > _dDtRej
					_dDtRej := ZZI->ZZI_DATA
				EndIf
				ZZI->(DbSkip())
			EndDo
			cMotivo := Alltrim(RetMotRJ(SC5->C5_CLIENTE,SC5->C5_LOJACLI ,_dDtRej))
			GraveTRB(4,_dEmm,_cHmm,_dDtBase,_cHrBase,,cMotivo) // Grava que está rejeitado
			Loop
		ElseIf _lVerCre
			ZZI->(DbSetOrder(2)) //ZZI_FILIAL+ZZI_CODEVE+ZZI_PEDIDO+ZZI_ITEMPV
			// Verifico se está atrasado procurando um registro de liberação no ZZI
			// Se não achar, o pedido ainda não foi liberado em crédito
			If ZZI->(!DbSeek(SC5->C5_FILIAL+"05"+SC5->C5_NUM,.F.))

				// Procuro quando foi liberado vendas e se não achar pego a data de emissao do pedido
				_dEmm := SC5->C5_EMISSAO
				_cHmm := "00:00"
				_dDtBase := Ctod("")
				_cHrBase := " "

				// Procuro registro da emissão do pedido
				ZZI->(DbSeek(SC5->C5_FILIAL+"01"+SC5->C5_NUM,.F.))
				// Localizar a última inclusão desse nro, pois pode cancelar e incluir um novo
				// com o mesmo nro.
				Do While ZZI->ZZI_FILIAL == SC5->C5_FILIAL .And. ZZI->ZZI_CODEVE == "01" .And.;
				         ZZI->ZZI_PEDIDO == SC5->C5_NUM    .And. ZZI->(!Eof())
					If ZZI->ZZI_DATA > _dDtBase
						_dDtBase := ZZI->ZZI_DATA
						_cHrBase := ZZI->ZZI_HORA
					ElseIf ZZI->ZZI_DATA == _dDtBase .And. ZZI->ZZI_HORA > _cHrBase
						_cHrBase := ZZI->ZZI_HORA
					EndIf
					If ZZI->ZZI_DATA > _dEmm
						_dEmm := ZZI->ZZI_DATA
						_cHmm := ZZI->ZZI_HORA
					ElseIf ZZI->ZZI_DATA == _dEmm .And. ZZI->ZZI_HORA > _cHmm
						_cHmm := ZZI->ZZI_HORA
					EndIf
					ZZI->(DbSkip())
				EndDo

				If _cHmm == "00:00"
					_cHmm := "12:00"
				EndIf

				_lGrvOcc := .T.
				if !SC9->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM,.F.)) // Não tem SC9 desse pedido, então não foi liberado
					_lGrvOcc := .F.
				elseif ZZI->(DbSeek(SC5->C5_FILIAL+"04"+SC5->C5_NUM,.F.))
					// Se achei um registro de liberação, assumo ele
					_dDtBase := ZZI->ZZI_DATA
					_cHrBase := ZZI->ZZI_HORA
					ZZI->(DbSkip())

					// Localizar a última liberação de vendas
					Do While ZZI->ZZI_FILIAL == SC5->C5_FILIAL .And. ZZI->ZZI_CODEVE == "04" .And.;
					         ZZI->ZZI_PEDIDO == SC5->C5_NUM    .And. ZZI->(!Eof())
						If ZZI->ZZI_DATA > _dDtBase
							_dDtBase := ZZI->ZZI_DATA
							_cHrBase := ZZI->ZZI_HORA
						ElseIf ZZI->ZZI_DATA == _dDtBase .And. ZZI->ZZI_HORA > _cHrBase
							_cHrBase := ZZI->ZZI_HORA
						EndIf
						ZZI->(DbSkip())
					EndDo
				endIf
				If _lGrvOcc
					// Adiciono à data e hora base a quantidade de horas "úteis" para saber se agora é maior.
					// Se for está atrasado
					_aDtHrLim := AdHrsUtil(_dDtBase,_cHrBase,_nPrzBF) // Retorna {dt,hr}

					// Verifico se está atrasado
					_cAgora := Dtos(_dDtNow) + Left(_cTmNow,5)
					_cPzLim := Dtos(_aDtHrLim[1]) + Left(_aDtHrLim[2],5)

					If _cAgora > _cPzLim // Está atrasado
						_cPrzFim := u_SubtHoras(_aDtHrLim[1],_aDtHrLim[2],_dDtNow,_cTmNow) // Atrasado Lib.Financeiro em horas BF
						GraveTRB(2,_dEmm,_cHmm,_aDtHrLim[1],_aDtHrLim[2],_cPrzFim)
						Loop
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	// 3 - Verifico se ainda não faturado e a data de entrega
	// 	Aadd(_aEventos,"05-Liberacao Pedido (Credito)")
	If SC5->C5_ENTREG < _dDtNow .And. _nSldPed > 0
		ZZI->(DbSetOrder(2)) //ZZI_FILIAL+ZZI_CODEVE+ZZI_PEDIDO+ZZI_ITEMPV
		If ZZI->(DbSeek(SC5->C5_FILIAL+"01"+SC5->C5_NUM,.F.))
			_dDtBase := ZZI->ZZI_DATA
			_cHrBase := ZZI->ZZI_HORA
		Else
			_dDtBase := SC5->C5_EMISSAO
			_cHrBase := "17:00"
		EndIf

		If SC9->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM,.F.)) // Não tem SC9 desse pedido, então não foi liberado
			// Calcular pelo SC9 quanto está liberado e quanto não está liberado mas é produto padrão (curva)
			_nValLib := 0.00
			_nValPad := 0.00
			Do While SC9->C9_FILIAL == SC5->C5_FILIAL .And. SC9->C9_PEDIDO == SC5->C5_NUM .And. SC9->(!Eof())
				If Empty(SC9->C9_BLEST) // Está Liberado
					_nValLib += (SC9->C9_QTDLIB*SC9->C9_PRCVEN)
				ElseIf SC9->C9_BLEST == "02"
					SC6->(DbSetOrder(1))  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
					SC6->(DbSeek(SC5->C5_FILIAL+SC5->C5_NUM+SC9->C9_ITEM,.F.))
					If !SC6->(Eof()) .And. !Empty(SC6->C6_ACONDIC)
						_cAcond := Padr(SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5),TamSX3("BF_LOCALIZ")[1])
						If u_fCurvaA(SC9->C9_PRODUTO,_cAcond,.T.)// Critica se produto pertence a Curva A ( .T. = CURVA A )
							_nValPad += (SC9->C9_QTDLIB*SC9->C9_PRCVEN)
						EndIf
					EndIf
				EndIf
				SC9->(DbSkip())
			EndDo
			GraveTRB(3,_dDtBase,_cHrBase)
		EndIf
	EndIf
	DbSelectArea(_AliasC5)
EndDo
If Select("RSC5") > 0
	DbSelectArea("RSC5")
	DbCloseArea("RSC5")
EndIf
Return(.T.)
*
***********************************************************
Static Function GraveTRB(_nOcc,_dEmm,_cHmm,_dDt,_dHr,_cPrz,_cMotv)
***********************************************************
Default _cMotv := ""
// _nOcc - Ocorrência
// _dEmm - Dt Emissao
// _cHmm - Hr Emissao
// _dDt  - Dt.Limite para liberação
// _dHr  - Hr.Limite para liberação
// _cPrz - Atraso em horas:minutos
_cHmm := Left(_cHmm,2) + "h" + Right(_cHmm,2)
_cNAtraso := "9999999999"
If _nOcc == 3 // 3=Atraso de Entrega
	If (_dDtNow-SC5->C5_ENTREG) > 0
		_cAtraso := AllTrim(Transform((_dDtNow-SC5->C5_ENTREG),"@E 99,999") + If(Abs(_dDtNow-SC5->C5_ENTREG)<=1," Dia "," Dias"))
		_cNAtraso := StrZero(9999999999 - (_dDtNow-SC5->C5_ENTREG),10)
	Else
		_cAtraso := " "
	EndIf
	_cPrazo  := Dtoc(SC5->C5_ENTREG)
ElseIf _nOcc == 4 // 4=Rejeitado
    If (_dDtNow-_dDtRej) > 0
		_cAtraso := AllTrim(Transform((_dDtNow-_dDtRej),"@E 99,999") + If(Abs(_dDtNow-_dDtRej)<=1," Dia "," Dias"))
		_cNAtraso := StrZero(9999999999 - (_dDtNow-_dDtRej),10)
	Else
		_cAtraso := " "
	EndIf
	_cPrazo  := Dtoc(_dDtRej)
Else
	_cAtraso := " "
	If _cPrz # "0:00"
		_cAtraso := AllTrim(Str(Val(_cPrz))) + "h" + Right(_cPrz,2)

		_cNAtraso := Val(AllTrim(Str(Val(_cPrz))) + Right(_cPrz,2))
		_cNAtraso := StrZero(9999999999 - _cNAtraso,10)
	EndIf
	_cPrazo  := Dtoc(_dDt) + " - " + Left(_dHr,2) + "h" + Right(_dHr,2)
EndIf
SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.)) // Vejo xFilial pois a tabela é compartilhada

_cNmRep := ""
_cNmAtd := ""
If !Empty(SC5->C5_VEND1)
	SA3->(DbSetOrder(1))  // A3_FILIAL+A3_COD
	If SA3->(DbSeek(xFilial("SA3")+SC5->C5_VEND1,.F.))
		_cNmRep := SA3->A3_NOME
		If !Empty(SA3->A3_SUPER)
			_cSuper := SA3->A3_SUPER
			If SA3->(DbSeek(xFilial("SA3")+_cSuper,.F.))
				_cNmAtd := SA3->A3_NOME
			EndIf
		EndIf
	EndIf
EndIf

RecLock("TRB",.T.)
TRB->FILIAL 	:= SC5->C5_FILIAL		// Filial do sistema
TRB->PEDIDO 	:= SC5->C5_NUM			// Numero do Pedido de Venda
TRB->PEDPORT 	:= SC5->C5_DOCPORT		// Numero do documento relacionado no portal
TRB->CODCLI 	:= SC5->C5_CLIENTE		// Código do Cliente
TRB->LOJA   	:= SC5->C5_LOJACLI		// Loja do Cliente
TRB->NOME   	:= SA1->A1_NOME			// Nome do Cliente
TRB->REPRES 	:= _cNmRep				// Nome do Representante
TRB->ATEND  	:= _cNmAtd          	// Nome do Atendente

//TRB->EMISSA := Dtoc(SC5->C5_EMISSAO) + " - " + 	// Data de Emissao do Pedido
// TRB->EMISSA := Dtoc(_dDt) + " - " + Left(_dHr,5) // Data de Emissao do Pedido
TRB->EMISSA := Dtoc(_dEmm) + " - " + Left(_cHmm,5) // Data de Emissao do Pedido
TRB->ENTREG	:= SC5->C5_ENTREG	// Data de Entrega Prevista
TRB->DTEPA2	:= SC5->C5_DTEPA2	// Data de Entrega Prevista no EPA

TRB->VRVENDA:= _nSldPed			// Saldo do pedido
TRB->MOTRJ	:= _cMotv		//Motivo da Rejeição

/*/
_nOcc == 1 - "Pedidos em atraso - Vendas - "
_nOcc == 2 - "Pedidos em atraso - Financeiro - "
_nOcc == 3 - "Pedidos em atraso - Produção - "
_nOcc == 4 - "Pedidos REJEITADOS PELO FINANCEIRO - "
_nOcc == 5 - "Pedidos em atraso - Faturamento - "
/*/
TRB->OCORR  := Str(_nOcc,1)		// Qual atraso 1-BV, 2-BF 3-Entrega
If _nOcc == 3
	TRB->VRLIBER:= _nValLib
	TRB->VRPADRA:= _nValPad
	If (TRB->VRLIBER+TRB->VRPADRA) >= TRB->VRVENDA
		TRB->OCORR  := "5"
	EndIf
EndIf
TRB->PRAZO  := _cPrazo			// Quando deveria estar liberado
TRB->ATRASO := _cAtraso			// Qual Atraso? 128 horas / 10 dias
TRB->ATRAZO := _cNAtraso        // Atraso Inverso

MsUnLock()
Return(.T.)
*
***********************************
Static Function SendDados(MV_PAR01)
***********************************
*
Local oWF
DbSelectArea("TRB")
If MV_PAR01 # 9
	ProcRegua(LastRec())
EndIf
For _nAtu := 1 To 5
	If MV_PAR01 # 9
		IncProc()
	EndIf
	If _nAtu # MV_PAR01 .And. MV_PAR01 # 9
		Loop
	EndIf

	// Montar o Cabeçalho do e-mail

	If _nAtu == 1
		cPara := AllTrim(GetMv("MV_IFCMLBV")) // contas de e-mail para envio dos atrasos vendas
		cAssunto := "Pedidos em atraso - Vendas - " + Dtoc(_dDtNow) + "-" +_cTmNow
		cHtmlMod := "\workflow\ProjCobrecom\fatw02_v.html"
		_cNadaTem := "NÃO HÁ PEDIDOS EM ATRASO - VENDAS"
	ElseIf _nAtu == 2
		cPara := AllTrim(GetMv("MV_IFCMLBF")) // contas de e-mail para envio dos atrasos credito
		cAssunto := "Pedidos em atraso - Financeiro - " + Dtoc(_dDtNow) + "-" +_cTmNow
		cHtmlMod := "\workflow\ProjCobrecom\fatw01_f.html"
		_cNadaTem := "NÃO HÁ PEDIDOS EM ATRASO - FINANCEIRO"
	ElseIf _nAtu == 3
		cPara := AllTrim(GetMv("MV_IFCMLPR")) // contas de e-mail para envio dos atrasos de produção
		cAssunto := "Pedidos em atraso - Produção - " + Dtoc(_dDtNow) + "-" +_cTmNow
//		cHtmlMod := "\workflow\ProjCobrecom\fatw01_p.html"
		cHtmlMod := "\workflow\ProjCobrecom\fatw01_ft.html"
		_cNadaTem := "NÃO HÁ PEDIDOS EM ATRASO - PRODUÇÃO"
	ElseIf _nAtu == 4 // 4=Rejeitados
		cPara := AllTrim(GetMv("MV_IFCMLBV")) // contas de e-mail para envio dos pedidos rejeitados
		cAssunto := "Pedidos REJEITADOS PELO FINANCEIRO - " + Dtoc(_dDtNow) + "-" +_cTmNow
		cHtmlMod := "\workflow\ProjCobrecom\fatw02_r.html" // e-mail igual ao da produção
		_cNadaTem := "NÃO HÁ PEDIDOS REJEITADOS NO FINANCEIRO"
	ElseIf _nAtu == 5 // 5=Atrasos Faturamento
		cPara := AllTrim(GetMv("MV_IFCMLFT"))// contas de e-mail para envio dos atrasos faturamento
		cAssunto := "Pedidos em atraso - Faturamento - " + Dtoc(_dDtNow) + "-" +_cTmNow
		cHtmlMod := "\workflow\ProjCobrecom\fatw01_ft.html"
		_cNadaTem := "NÃO HÁ PEDIDOS EM ATRASO - FATURAMENTO"
	EndIf

	/*
	ElseIf _nAtu == 5 // 5=Atrasos Faturamento
		cPara := AllTrim(GetMv("MV_IFCMLFT")) + AllTrim(GetMv("MV_IFCMLF2")) // contas de e-mail para envio dos atrasos faturamento
		cAssunto := "Pedidos Faturados - Cliente não retirou " + Dtoc(_dDtNow) + "-" +_cTmNow
		cHtmlMod := "\workflow\ProjCobrecom\fatw01_ft.html"
		_cNadaTem := "NÃO HÁ PEDIDOS EM ATRASO - FATURAMENTO"
	EndIf
	*/

	If "JULIANA.LEME" $ Upper(cUserName)
		cPara := "juliana.leme@cobrecom.com.br"
	EndIf

	// Montar e-mail do _nAtu
	DbSelectArea("TRB")
	If DbSeek(Str(_nAtu,1),.F.)
		oWF := twfprocess():new("ATRASO",cAssunto)
		oWF:newtask("CDFAT01", cHtmlMod)
	Else
		// Perguntar se não tiver dados se envia e-mail dizendo que não tem.
		_lManda := GetMv("MV_IFCENAT")
		If _lManda
			// Não há dados a serem enviados
			oWF := twfprocess():new("ATRASO",cAssunto)
			oWF:newtask("CDFAT01", cHtmlMod)
			Aadd( oWF:ohtml:valbyname("Wf.Fil") ," ")
			Aadd( oWF:ohtml:valbyname("Wf.Ped") ,"  ")
			Aadd( oWF:ohtml:valbyname("Wf.Cli") ,_cNadaTem)
			If _nAtu >= 3 // 3=Produção, 4=Rejeitados ou 5=Atrasos Faturamento
				Aadd( oWF:ohtml:valbyname("Wf.Emi") ,"  ")
				If _nAtu # 4 // 4=Rejeitados - Não tem coluna atraso nos rejeitados
					Aadd( oWF:ohtml:valbyname("Wf.dten"),"  ")
					Aadd( oWF:ohtml:valbyname("Wf.Atr") ,"  ")
				Else
					Aadd( oWF:ohtml:valbyname("Wf.Dtrj"),"  ")
					Aadd( oWF:ohtml:valbyname("Wf.Drej") ,"  ")
				EndIf
			Else
				Aadd( oWF:ohtml:valbyname("Wf.Emi") ,"  ")
				Aadd( oWF:ohtml:valbyname("Wf.Prz") ,"  ")
				Aadd( oWF:ohtml:valbyname("Wf.Atr") ,"  ")
				Aadd( oWF:ohtml:valbyname("Wf.dten"),"  ")
			EndIf
			Aadd( oWF:ohtml:valbyname("Wf.Tot") ,"  ")
		Else
			Loop
		EndIf
	EndIf

	Do While TRB->OCORR == Str(_nAtu,1) .And. TRB->(!Eof())

		Aadd( oWF:ohtml:valbyname("Wf.Fil") 	,If(TRB->FILIAL=="01","Itu","3 Lagoas"))
		Aadd( oWF:ohtml:valbyname("Wf.Ped") 	,Alltrim(TRB->PEDIDO))
		aadd( oWf:ohtml:valbyname("Wf.Port") 	,Alltrim(TRB->PEDPORT))
		Aadd( oWF:ohtml:valbyname("Wf.Cli") 	,AllTrim(TRB->NOME))

		If _nAtu >= 3 // 3=Produção, 4=Rejeitados ou 5=Atrasos Faturamento
			_nPosCut := Max(8,At(" - ",TRB->EMISSA)-1)
			Aadd( oWF:ohtml:valbyname("Wf.Emi") ,Left(TRB->EMISSA,_nPosCut))
			If _nAtu # 4 // 4=Rejeitados - Não tem coluna atraso nos rejeitados
				Aadd( oWF:ohtml:valbyname("Wf.dten"),Dtoc(TRB->ENTREG))
				Aadd( oWF:ohtml:valbyname("Wf.Atr") ,TRB->ATRASO)
				Aadd( oWF:ohtml:valbyname("Wf.Fat") ,Transform(TRB->VRLIBER,"@E 9,999,999.99"))
				Aadd( oWF:ohtml:valbyname("Wf.Pad") ,Transform(TRB->VRPADRA,"@E 9,999,999.99"))

//				If _nAtu == 5 // 5=Atrasos Faturamento
					// Verifica se não há registro de atualização de status de WF no ZZI
					ZZI->(DbSetOrder(2)) // ZZI_FILIAL'+ZZI_CODEVE+ZZI_PEDIDO+ZZI_ITEMPV
					ZZI->(DbSeek(TRB->FILIAL+"90"+TRB->PEDIDO,.F.))
					_cObs := " "
					Do While ZZI->ZZI_FILIAL+ZZI->ZZI_CODEVE+ZZI->ZZI_PEDIDO == ;
							 TRB->FILIAL+"90"+TRB->PEDIDO .And. ZZI->(!Eof())
						_cObs := AllTrim(ZZI->ZZI_OBS)
						ZZI->(DbSkip())
					EndDo
					If !Empty(TRB->DTEPA2) // Data de Entrega Prevista no EPA
						If Empty(_cObs)
							_cObs := "Data PCP: " + Dtoc(TRB->DTEPA2) // Data de Entrega Prevista no EPA
						Else
							_cObs := AllTrim(_cObs) + " - Data PCP: " + Dtoc(TRB->DTEPA2) // Data de Entrega Prevista no EPA
						EndIf
					EndIf

					Aadd( oWF:ohtml:valbyname("Wf.Obs") ,_cObs)
//				EndIf
			Else
				Aadd( oWF:ohtml:valbyname("Wf.Dtrj"),TRB->PRAZO)
				Aadd( oWF:ohtml:valbyname("Wf.Drej"),TRB->ATRASO)

				Aadd( oWF:ohtml:valbyname("Wf.Rep"),TRB->REPRES)
				Aadd( oWF:ohtml:valbyname("Wf.Atd"),TRB->ATEND)

			EndIf

		Else
			Aadd( oWF:ohtml:valbyname("Wf.Emi") ,TRB->EMISSA)
			Aadd( oWF:ohtml:valbyname("Wf.Prz") ,TRB->PRAZO)
			Aadd( oWF:ohtml:valbyname("Wf.Atr") ,TRB->ATRASO)
			Aadd( oWF:ohtml:valbyname("Wf.dten"),Dtoc(TRB->ENTREG))
			If _nAtu == 1 // 1=Atrasos Vendas

				Aadd( oWF:ohtml:valbyname("Wf.Rep"),TRB->REPRES)
				Aadd( oWF:ohtml:valbyname("Wf.Atd"),TRB->ATEND)

			EndIf

		EndIf
		Aadd( oWF:ohtml:valbyname("Wf.Tot") ,Transform(TRB->VRVENDA,"@E 99,999,999.99"))
		If _nAtu = 4
			aadd( oWf:ohtml:valbyname("Wf.Motrj") 	,Alltrim(TRB->MOTRJ))
		endif
		TRB->(DbSkip())
	EndDo

	oWF:csubject := cAssunto

	If !Empty(cPara)
		oWF:cto := AllTrim(cPara)
	Else
		oWF:csubject := cAssunto + " - FALTA DEFINIÇÃO DE E-MAIL NO PARÂMETRO"
	EndIf
	oWF:start()
	oWF:finish()
	wfsendmail()
Next
Return(.T.)
*
***************************
Static Function ValidPerg()
***************************
*
*
_aArea := GetArea()

DbSelectArea("SX1")
DbSetOrder(1)
cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

aRegs:={}
//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
aAdd(aRegs,{cPerg,"01","Enviar E-Mail Referente a ?","mv_ch1","N",01,0,0,"C","","MV_PAR01","Atrasos BV","","","Atrasos BF","","","Atrasos Produção","","","","","","","",""})
aAdd(aRegs,{cPerg,"02","Enviar E-Mail Para        ?","mv_ch2","C",30,0,0,"C","","MV_PAR02","","","","","","","","","","","","","","",""})

For i := 1 To Len(aRegs)
	If !DbSeek(cPerg+aRegs[i,2],.F.)
		RecLock("SX1",.T.)
		SX1->X1_GRUPO   := aRegs[i,01]
		SX1->X1_ORDEM   := aRegs[i,02]
		SX1->X1_PERGUNT := aRegs[i,03]
		SX1->X1_VARIAVL := aRegs[i,04]
		SX1->X1_TIPO    := aRegs[i,05]
		SX1->X1_TAMANHO := aRegs[i,06]
		SX1->X1_DECIMAL := aRegs[i,07]
		SX1->X1_PRESEL  := aRegs[i,08]
		SX1->X1_GSC     := aRegs[i,09]
		SX1->X1_VALID   := aRegs[i,10]
		SX1->X1_VAR01   := aRegs[i,11]
		SX1->X1_DEF01   := aRegs[i,12]
		SX1->X1_CNT01   := aRegs[i,13]
		SX1->X1_VAR02   := aRegs[i,14]
		SX1->X1_DEF02   := aRegs[i,15]
		SX1->X1_CNT02   := aRegs[i,16]
		SX1->X1_VAR03   := aRegs[i,17]
		SX1->X1_DEF03   := aRegs[i,18]
		SX1->X1_CNT03   := aRegs[i,19]
		SX1->X1_VAR04   := aRegs[i,20]
		SX1->X1_DEF04   := aRegs[i,21]
		SX1->X1_CNT04   := aRegs[i,22]
		SX1->X1_VAR05   := aRegs[i,23]
		SX1->X1_DEF05   := aRegs[i,24]
		SX1->X1_CNT05   := aRegs[i,25]
		SX1->X1_F3      := aRegs[i,26]
		MsUnlock()
		DbCommit()
	Endif
Next
RestArea(_aArea)
Return(.T.)
*
*****************************************************
Static Function AdHrsUtil(_dDtBase,_cHrBase,_nPrzDay)
*****************************************************
*
// Verificar se a própria data base é dia útil
_nHoras := Val(Left(_cHrBase,2))
If _dDtBase # DataValida(_dDtBase,.T.) // Não é dia útil
	_dDtBase := DataValida(_dDtBase,.T.)
	_nHoras  := 8
EndIf
// Somo hora a hora para chegar a data/hora final
For _nQtHrs := 1 to _nPrzDay
	_nHoras++
	If _nHoras > 17 // Deixar como > 18 pois pode ser que o pedido seja cadastrado após isso.
		_dDtBase := DataValida(++_dDtBase,.T.)
		_nHoras  := 8
	EndIf
Next
If _nHoras == 18 .And. Val(Substr(_cHrBase,4,2)) > 0
	_dDtBase := DataValida(++_dDtBase,.T.)
	_nHoras  := 8
EndIf
_cHrs := StrZero(_nHoras,2) + ":" + Substr(_cHrBase,4,2)
Return({_dDtBase,_cHrs})
*
************************************************
User Function SubtHoras(_dDt0,_cHr0,_dDt1,_cHr1)
************************************************
*
Local _nHrs,_nHr1,_nMn1,_nHr0,_nMn0,_HrFull,_MiFull,_cHoras
*
_nHrs := (_dDt1-_dDt0) * 24

_nHr1 := Val(Left(_cHr1,2))
_nMn1 := NoRound(Val(Substr(_cHr1,4,2)) / 60) // Achei minutos em decinal
_nHr0 := Val(Left(_cHr0,2))
_nMn0 := NoRound(Val(Substr(_cHr0,4,2)) / 60) // Achei minutos em decinal

_nHrs := _nHrs + _nHr1 + _nMn1 - _nHr0 - _nMn0
_HrFull := Int(_nHrs)
_MiFull := (_nHrs - _HrFull)
If _MiFull == 0
	_cHoras := AllTrim(Str(_HrFull)) + ":00"
Else
	_MiFull := StrZero(_MiFull * 60,2)
	_cHoras := AllTrim(Str(_HrFull)) + ":" + _MiFull
EndIf
Return(_cHoras)


/*/{Protheus.doc} RetMotRJ
//TODO Descrição auto-gerada.
@author juliana.leme
@since 27/02/2019
@version 1.0
@type function
/*/
Static Function RetMotRJ(cCodCli,cLojaCli,dDataRj)
	local oSql 		:= nil 
	local cQry		:= ""
	local cMotivo	:= ""
	default dDataRj	:= dDataBase
	default cCodCli := "", cLojaCli := ""
	
	cQry += " SELECT  "
	cQry += " ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZZ1_HIST)),'') ZZ1HIST"
	cQry += " FROM  %ZZ1.SQLNAME%  WITH (NOLOCK) "
	cQry += " WHERE %ZZ1.XFILIAL% "
	cQry += " AND ZZ1_FILIAL = ''"
	cQry += " AND ZZ1_CLIENT = '" + cCodCli + "' "
	cQry += " AND ZZ1_LOJA = '" + cLojaCli + "' " 
	cQry += " AND ZZ1_TPINVE = '01'  " //Rejeição
	cQry += " AND ZZ1_DATA = '" + DtoS(dDataRj) + "' "
	cQry += " AND %ZZ1.NOTDEL% "
	cQry += " ORDER BY ZZ1_DATA+ZZ1_HORA DESC "
	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		cMotivo := oSql:getValue("ZZ1HIST")
	endif	
	oSql:close()
	FreeObj(oSql)
Return(cMotivo)