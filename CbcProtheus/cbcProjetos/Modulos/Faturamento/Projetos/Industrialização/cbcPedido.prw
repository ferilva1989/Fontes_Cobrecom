#include 'protheus.ch'
#include "cbcIncludes.ch"

#define CODIGO 		1
#define TES 		2
#define	QUANTIDADE 	3
#define	UNITARIO 	4
#define	TOTAL 		5
#define	POS 		6
#define CLASFIS		7
#define	TXICM 		1
#define	LOK			1
#define ERRO		2
#define DESCR		1
#define PILHA		2
#define NOME_CAMPO	1
#define VALOR_CAMPO	2


/*/{Protheus.doc} cbcPedido
@author bolognesi
@since 06/10/2016
@version 1.0
@description Classe que representa o pedido (em digitação aCols e aHeader) ou (existente SC6 SC6)
e aplica todas as regras de ajustes de pedidos entre as Filiais, no processo de industrialização
desenvolvido em 10/2016- estão envolvidos os seguintes fontes (CBCPEDIDO, CBCINDRULES, CDPARC, M410LIOK
AUTOALERT, PEDINDL, SQLUTIL), CDPARC realiza chamada para CBCPEDIDO que é uma herança do CBCINDRULES, os
fontes M410LIOK tratam as validações e Pontos de entradas, e PEDINDL existem os fontes auxilizares do
processo.
/*/
class cbcPedido from CbcIndRules

	Data cNroPed
	Data oSC5
	Data oSC6

	Data lselfOk
	Data cselfMsg

	Data lTemtab

	Data oArea
	Data oSql

	Data lfab3l
	Data lMix2
	Data lDiv
	Data aErrJob

	Data lDelPed
	Data cPvDest

	Data aTxItens

	method newcbcPedido() constructor
	method setClientInfo()

	method workWithScreen()
	method workWithTable()
	method syncOkMsg()

	method OrderArr()
	method HdrFromMem()
	method ColsFromHdr()

	method OrderNum()

	method JobAuto()
	method emailRet()

	method checkDiv()
	method actionAcols()

	method updScreen()
	method closeScreen()

	method delPedido()
	method getPedInfo()
	method libPed()

	method defPvDiv()
	method przEntrega()
	method vldFab()

	method bxOrc()
	method CalcTaxes()

	method sendMirror()
	method isEqual()
	method hasChanged()
endclass

method newcbcPedido(cNroPed) class cbcPedido
	Default cNroPed	:= ""
	::lselfOk 	:= .T.
	::cselfMsg	:= ""
	::oArea := SigaArea():newSigaArea()
	::oSql 	:= SqlUtil():newSqlUtil()
	::aErrJob	:= {}
	::cNroPed	:= ""
	::cPvDest	:= ""
	::lDelPed	:= .F.
	::aTxItens	:= {}
	::oSC5		:= Nil
	::oSC6		:= Nil
	::lTemtab 	:= .F.

	If Empty(cNroPed)
		If ValType(aHeader) != 'A' .Or. ValType(aCols) != 'A'
			::lselfOk 	:= .F.
			::cselfMsg	:= "[ERRO] - Informar o parametro com o numero do pedido - cbcPedido():newcbcPedido(cNroPed)"
		Else
			If Empty(aHeader) .Or. Empty(aCols)
				::lselfOk 	:= .F.
				::cselfMsg	:= "[ERRO] - Informar o parametro com o numero do pedido - cbcPedido():newcbcPedido(cNroPed)"
			Else
				//Define as taxas de ICMS
				::CalcTaxes()
				//Processar com as informações aHeader aCols
				::workWithScreen()
			EndIf
		EndIf
	Else
		//Processar com as informações do Pedido SC5/SC6
		::workWithTable(cNroPed)
	EndIf
return (self)

/*/{Protheus.doc} CalcTaxes
@author bolognesi
@since 27/10/2016
@version 1.0
@param cPed, characters, Numero do pedido cujos itens deveram ser atualizados com informações de impostos
default M->C5_NUM (Se existir)
@param lScreen, logical, Informa se deve obter informações ( .T. )Tela(aHeader,aCols)
( .F. )Tabela(SC5,SC6), o default é ( .T. )
@param cFil, characters, Filial do pedido, o default é a filial corrente
@type method
@description Metodo utilizado para atualizar o campo "C6_ZZPICM", sendo ele do acols
ou direto na tabela SC6, com as taxas de impostos. para detalhes verificar função U_tstTaxes()
/*/
method CalcTaxes(cPed,lScreen,cFil) class cbcPedido
	Local   aItm		:= {}
	Local 	nX			:= 0
	Local 	nItm		:= 0
	Local  oSC5			:= Nil
	Local  oSC6			:= Nil
	Local  nTx			:= 0
	Local  oBase 		:= ManBaseDados():newManBaseDados()
	Default lScreen 	:= .T.
	Default cFil		:= FwFilial()
	Default cPed		:= ""

	If Empty(cPed)
		If lScreen
			cPed		:= M->(C5_NUM)
		Else
			If !Empty(::cNroPed)
				cPed		:= ::cNroPed
			EndIF
		EndIf
	EndIf

	::lselfOk		:= .T.
	::cselfMsg		:= ""
	::aTxItens		:= {} //Array com os itens do pedido e outro array com as taxas calculadas
	//ATUALIZA IMPOSTOS NA TELA
	If lScreen
		If Empty(aHeader) .Or. Empty(aCols)
			::lselfOk		:= .F.
			::cselfMsg		:= "[ERRO] - cbcPedido:CalcTaxes() aHeader/aCols estão vazios"
		Else
			MaFisIni(M->(C5_CLIENTE),;			//1-Codigo Cliente/Fornecedor
			M->(C5_LOJACLI),;	    			//2-Loja do Cliente/Fornecedor
			IIf(M->(C5_TIPO) $ "DB","F","C"),;	//3-C:Cliente , F:Fornecedor
			M->(C5_TIPO),;						//4-Tipo da NF
			M->(C5_TIPOCLI),;					//5-Tipo do Cliente/Fornecedor
			Nil,;
				Nil,;
				Nil,;
				Nil,;
				"MATA461")
			For nX:= 1 to Len(aCols)
				aItm := {}
				If !GDDeleted(nX, aHeader, aCols)
					nItm ++
					AAdd(aItm, GDFieldGet("C6_PRODUTO"	,nX	, .F. , aHeader, aCols))
					AAdd(aItm, GDFieldGet("C6_TES"		,nX	, .F. , aHeader, aCols))
					AAdd(aItm, GDFieldGet("C6_QTDVEN"	,nX	, .F. , aHeader, aCols))
					AAdd(aItm, GDFieldGet("C6_PRCVEN"	,nX	, .F. , aHeader, aCols))
					AAdd(aItm, GDFieldGet("C6_VALOR"	,nX	, .F. , aHeader, aCols))
					AAdd(aItm, nItm)
					AAdd(aItm, GDFieldGet("C6_CLASFIS"	,nX	, .F. , aHeader, aCols))

					nTx := getTaxes(aItm)[TXICM]
					GdFieldPut("C6_ZZPICM", nTx , nX, aHeader, aCols, .F.)
				EndIf
				AAdd(::aTxItens, {GDFieldGet("C6_NUM"		,nX	, .F. , aHeader, aCols),;
					GDFieldGet("C6_ITEM"		,nX	, .F. , aHeader, aCols),;
					GDFieldGet("C6_VALOR"		,nX	, .F. , aHeader, aCols),;
					GDFieldGet("C6_ZZPICM"	,nX	, .F. , aHeader, aCols)	} )
			Next nX
			MaFisEnd()
		EndIf
		//ATUALIZA IMPOSTOS NA TABELA
	Else
		::oArea:saveArea( {'SC5', 'SC6'} )
		If Empty(cPed)
			::lselfOk		:= .F.
			::cselfMsg		:= "[ERRO] - cbcPedido:CalcTaxes() numero do pedido não informado"
		Else
			//CABEÇALHO
			::oSql:addFromTab('SC5')
			::oSql:addCampos({'SC5.R_E_C_N_O_','C5_CLIENTE','C5_LOJACLI','C5_TIPO','C5_TIPOCLI'})
			::oSql:addWhere("C5_FILIAL = '"+ cFil +"' ")
			::oSql:addWhere("C5_NUM = '" + cPed + "' ")
			//::oSql:addWhere("C6_CF NOT IN ('6151','6152','6901','6124','6902')")  //IGUAL A VIEW DO BI
			if ::oSql:QrySelect():lOk
				oSC5 := ::oSql:oRes
				MaFisIni(oSC5[1]:C5_CLIENTE,;			//1-Codigo Cliente/Fornecedor
				oSC5[1]:C5_LOJACLI,;	    			//2-Loja do Cliente/Fornecedor
				IIf(oSC5[1]:C5_TIPO $ "DB","F","C"),;	//3-C:Cliente , F:Fornecedor
				oSC5[1]:C5_TIPO,;						//4-Tipo da NF
				oSC5[1]:C5_TIPOCLI,;					//5-Tipo do Cliente/Fornecedor
				Nil,;
					Nil,;
					Nil,;
					Nil,;
					"MATA461")

				//ITENS
				::oSql:addFromTab('SC6')
				::oSql:addCampos({'SC6.R_E_C_N_O_','C6_PRODUTO','C6_ITEM','C6_TES','C6_QTDVEN','C6_PRCVEN','C6_VALOR','C6_CLASFIS'})
				::oSql:addWhere("C6_FILIAL = '"+ cFil +"' ")
				::oSql:addWhere("C6_NUM = '" + cPed + "' ")
				if ::oSql:QrySelect():lOk

					DbSelectArea('SC5')
					DbGoTo(oSC5[1]:R_E_C_N_O_)

					oSC6 := ::oSql:oRes
					For nX := 1 To ::oSql:nRegCount
						aItm := {}
						Begin Transaction
							If nX == 1
								RecLock('SC5')
							EndIf
							AAdd(aItm,	Padr(oSC6[nX]:C6_PRODUTO,TamSx3('C6_PRODUTO')[1])	)
							AAdd(aItm, 	Padr(oSC6[nX]:C6_TES	,TamSx3('C6_TES')[1])		)
							AAdd(aItm, 	oSC6[nX]:C6_QTDVEN )
							AAdd(aItm, 	oSC6[nX]:C6_PRCVEN )
							AAdd(aItm, 	oSC6[nX]:C6_VALOR  )
							AAdd(aItm, nX)
							AAdd(aItm, 	oSC6[nX]:C6_CLASFIS)

							nTx := getTaxes(aItm)[TXICM]
							oBase:addCpoVlr('C6_ZZPICM',nTx)
							oBase:updTable(oSC6[nX]:R_E_C_N_O_)

						End Transaction Lockin "SC5"

						AAdd(::aTxItens, {cPed,oSC6[nX]:C6_ITEM,oSC6[nX]:C6_VALOR,nTx} )
					Next nX

					Begin Transaction
						RecLock('SC5')
					End Transaction
				EndIf

				MaFisEnd()
			EndIf
		EndIf
		::oArea:backArea()
	EndIf
	FreeObj(oBase)
return (self)

/*/{Protheus.doc} orderNum
@author bolognesi
@since 10/10/2016
@version 1.0
@type method
@description Retorna o proximo numero valido para pedido
/*/
method orderNum() class cbcPedido
	Local cPV := ""
	::oArea:saveArea( {'SC5'}, .F. )
	cPV 	:= GetSx8Num("SC5","C5_NUM")
	ConfirmSX8()
	DbSelectArea("SC5")
	DbSetOrder(1) // C5_FILIAL+C5_NUM
	Do While SC5->(DbSeek(xFilial("SC5")+cPV,.F.))
		cPV := GetSx8Num("SC5","C5_NUM")
		ConfirmSX8()
	EndDo
	::oArea:backArea({'SC5'})
	::cPvDest := cPV
return (cPV)

/*/{Protheus.doc} bxOrc
@author bolognesi
@since 25/10/2016
@version 1.0
@type method
@description Quando um pedido tem todos os itens fabricados em 3l,
e a origem do pedido é Itu, todos os itens serão tranferidos para um
novo pedido em 3l, quando estamos transformando um Orçamento em um pedido (Itu) e este pedido
será tranferido integralmente para 3l, o Orçamento deve ser baixado e relacionado com o pedido
de 3l e não o de Itu, que não mais será incluido.
/*/
method bxOrc(cPv) class cbcPedido
	Local oFil		:= cbcFiliais():newcbcFiliais()
	Local cqry		:= ""
	Local cAliasSCK := GetNextAlias()
	Local aStruSCK	:= {}
	Local cQuery	:= ""
	Local nX		:= 0
	Local nResult	:= 0
	Default cPv		:= ::cPvDest

	If Select(cAliasSCK) > 0
		(cAliasSCK)->(dbcloseArea())
		FErase( cAliasSCK + GetDbExtension())
	EndIf

	If IsInCallStack('MATA416') .And. !Empty(cPv)

		cqry	+= " UPDATE "+ retsqlname("SCK") + " SET CK_NUMPV ='" + cPv + "'"
		cqry    += " WHERE CK_FILIAL='"+xFilial("SCK")+"' AND "
		cqry	+= " CK_NUM='" + SCJ->CJ_NUM + "' AND "
		cqry	+= "D_E_L_E_T_=' '"
		nResult := TCSQLexec(cqry)
		If (nResult >= 0)
			oFil:setFilial(FILDEST)
			RecLock("SCJ",.F.)
			MaAvalOrc("SCJ",13)
			SCJ->CJ_STATUS := "B"

			aStruSCK  := SCK->(dbStruct())
			cQuery += "SELECT * "
			cQuery += "FROM "+RetSqlName("SCK")+" "
			cQuery += "WHERE CK_FILIAL='"+xFilial("SCK")+"' AND "
			cQuery += "CK_NUM='"+SCJ->CJ_NUM+"' AND "
			cQuery += "D_E_L_E_T_=' '"
			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSCK,.T.,.T.)
			For nX := 1 To Len(aStruSCK)
				If aStruSCK[nX][2] <> "C"
					TcSetField(cAliasSCK,aStruSCK[nX][1],aStruSCK[nX][2],aStruSCK[nX][3],aStruSCK[nX][4])
				EndIf
			Next nX

			While ( !Eof() .And. (cAliasSCK)->CK_FILIAL==xFilial("SCK") .And. (cAliasSCK)->CK_NUM == SCJ->CJ_NUM )
				MaAvalOrc(cAliasSCK,4)
				dbSelectArea(cAliasSCK)
				dbSkip()
			EndDo
			MsUnlock()
			If Select(cAliasSCK) > 0
				(cAliasSCK)->(dbcloseArea())
				FErase( cAliasSCK + GetDbExtension())
			EndIf
			oFil:backFil()
		EndIf
	EndIf
return (self)

/*/{Protheus.doc} vldAltFab
@author bolognesi
@since 18/10/2016
@version 1.0
@type method
@description Metodo para validar a alteração de itens cuja fabricação não seje
na filial corrente Ex: Alterar um pedido de Tres Lagoas com o campo C5_ZZDIVPV
preenchido, neste caso se incluir um item que não fabrica U_tem3Lag(), não deixar
chamado pelo ponto de entrada M410LIOK
/*/
method vldFab(cCodProd,cCli,cLoja,cPed) class cbcPedido
	Local 	cFil		:= ""
	Local 	aCmpos		:= {}
	Local 	aProd		:= {}
	Local 	cProd		:= ""
	Local 	cPrdCor		:= ""
	Local 	lSoProd		:= .F.
	Default	cPed 		:= ::cNroPed
	Default cCli		:= ""
	Default cLoja		:= ""
	Default cCodProd 	:= ""
	::lselfOk			:= .T.
	::cselfMsg			:= ''
	::lfab3l			:= .T.
	::lMix2				:= .T.
	::lDiv				:= .F.

	If Empty(cCodProd)
		::lselfOk			:= .F.
		::cselfMsg			:= '[ERRO] - Parametro cCodProd obrigatorios cbcPedido():vldFab(cCodProd,cCli,cLoja,cPed) '
	ElseIf Empty(cCli) .And. Empty(cLoja)
		lSoProd := .T.
	Else
		If ::setClientInfo(cCli,cLoja,cPed):lselfOk
			If FwFilial() != DIVIDIR
				::lDiv := ::autoPvDiv()
			EndIf
		EndIf
	EndIf

	If ::lDiv .Or. lSoProd
		cCod 		:= cCodProd
		cFil		:= xFilial("SB1")
		aCmpos		:= {'B1_NOME','B1_BITOLA','B1_COR', 'B1_ZZMIXPR'}
		aProd 		:= GetAdvFVal("SB1", aCmpos ,cFil+cCod ,1, {} )
		cProd  		:= aProd[PROD_FAMILIA] + aProd[PROD_BITOLA]
		cPrdCor 	:= aProd[PROD_COR]
		::lfab3l 	:= u_Tem3Lag(cCod,cPrdCor)
		::lMix2     := (aProd[PROD_ZZMIXPR] == '1')
	EndIF
Return(Self)

/*/{Protheus.doc} przEntrega
@author bolognesi
@since 18/10/2016
@version 1.0
@type method
@description Utiliza a função legado para recalcular os prazos de entrega
/*/
method przEntrega() class cbcPedido
	//U_AvalPrz("SC6",.F.,.F.,M->(C5_NUM),M->(C5_CLIENTE))
	u_AvalPrz("SC6",.T.)
return (self)

/*/{Protheus.doc} defPvDiv
@author bolognesi
@since 18/10/2016
@version 1.0
@param cFil, characters, Recebe a filial, default é a filial corrente
@param cPed, characters, Numero do pedido o default é ::cNroPed
@type method
@description Quando um pedido é excluido para uma divisão, arrumar os pedidos
na outra ponta que estão relacionados atraves do campo ZZPVDIV, fazendo com
que os pedidos na outra ponto ao invés de apontar para pedido origime apontem para
eles mesmos.
/*/
method defPvDiv(cFil,cPed) class cbcPedido
	Local	cqry	:= ""
	Local   lRet 	:= .T.
	Local   cMsg	:= ""
	Default cFil	:= FwFilial()
	Default cPed 	:= ::cNroPed

	cqry	+= " UPDATE "+ retsqlname("SC5") + " SET C5_ZZPVDIV = C5_NUM "
	cqry    += " WHERE C5_ZZPVDIV = '" + cPed +"' "
	cqry	+= " AND D_E_L_E_T_ = '' "

	If (TCSQLexec(cqry) < 0)
		lRet 	:= .F.
		cMsg	:= "LOG SQL: " + TCSQLError()
	EndIf
return ({lRet,cMsg})

/*/{Protheus.doc} isEqual
@author bolognesi
@since 10/11/2016
@version 1.0
@param cCampo, characters, Recebe o campo (SC5), a ser procurado
@param cCompar, characters, Se encontrar o campo Ver se esta igual a este valor
@type method
/*/
method isEqual(cCampo,cCompar) class cbcPedido
	Local aCmpCls	:= {}
	Local nX		:= 0
	Local lRet		:= .F.
	If ::getPedInfo():lTemtab
		aCmpCls := ClassDataArr(::oSC5[POS_OBJ],.F.)
		For nX := 1 To Len(aCmpCls)
			If Upper(Alltrim(aCmpCls[nX,NOME_CAMPO])) $  Upper(Alltrim(cCampo))
				If ValType(cCompar) == ValType(aCmpCls[nX,VALOR_CAMPO])
					If aCmpCls[nX,VALOR_CAMPO] == cCompar
						lRet := .T.
						exit
					EndIf
				EndIf
			EndIf
		Next nX
	EndIf
return (lRet)

/*/{Protheus.doc} getPedInfo
@author bolognesi
@since 18/10/2016
@version 1.0
@param cFil, characters, Recebe a filial, por default utiliza filial corrente FwFilial()
@param cPed, characters, Numero pedido, se não informado utiliza ::cNroPed
@type method
@description Metodo utilizado para carregar as informações de um pedido (SC5/SC6)
/*/
method getPedInfo(cFil,cPed) class cbcPedido
	Default cPed 	:= ::cNroPed
	Default cFil	:= FwFilial()
	lOk				:= .F.
	::lTemtab		:= .F.
	::oSC5			:= Nil
	::oSC6			:= Nil
	::lselfOk		:= .T.
	::cselfMsg		:= ''
	::oSql:addFromTab('SC5')
	::oSql:addCampos({'SC5.R_E_C_N_O_','C5_FILIAL','C5_NUM','C5_TIPO','C5_CLIENTE','C5_LOJACLI','C5_CONDPAG','C5_ZZSMAIL','C5_TPFRETE'})
	::oSql:addWhere("C5_FILIAL = '"+ cFil + "'",'AND')
	::oSql:addWhere("C5_NUM = '"+ cPed + "'")

	if ::oSql:QrySelect():lOk
		If ::oSql:nRegCount > 0
			::oSC5 := ::oSql:oRes
			lOk := .T.
		EndIf
	EndIf

	if lOk
		::oSql:addFromTab('SC6')
		::oSql:addCampos({'C6_NUM','C6_ITEM','C6_PRODUTO','C6_QTDVEN','C6_ACONDIC','C6_LANCES','C6_METRAGE','C6_PRCVEN'})
		::oSql:addWhere("C6_FILIAL = '"+ cFil + "'",'AND')
		::oSql:addWhere("C6_NUM = '"+ cPed + "'")
		::oSql:addOrder({"C6_ITEM"}, "ASC")
		if ::oSql:QrySelect():lOk
			If ::oSql:nRegCount > 0
				::oSC6 := ::oSql:oRes
				::lTemtab := .T.
			EndIf
		EndIf
	EndIf
return (self)

/*/{Protheus.doc} libPed
@author bolognesi
@since 18/10/2016
@version 1.0
@param cPed, characters, Numero pedido, se não informado utiliza ::cNroPed
@type method
@description Realiza liberações no pedido SC9, atualiza campo C5_LIBEROK
zera os campos SC6->(C6_QTDLIB), SC6->(C6_QTDEMP)
/*/
method libPed(cPed) class cbcPedido
	Default cPed := ::cNroPed

	DbSelectArea("SC9")
	SC9->(DbSeek(FWCodFil() + cPed))

	While SC9->(!Eof()) .AND. SC9->C9_FILIAL == FWCodFil() .AND. SC9->C9_PEDIDO == cPed
		SC9->(A460Estorna())
		SC9->(DbSkip())
	EndDo

	DbSelectArea("SC5")
	SC5->(DbSeek(FWCodFil() + cPed,.F.))
	reclock("SC5", .F.)
	SC5->(C5_LIBEROK) := ""
	SC5->(Msunlock())

	SC6->(DbSeek(FWCodFil()+SC5->(C5_NUM),.F.))
	While SC6->C6_FILIAL == FWCodFil() .And. SC6->C6_NUM == SC5->C5_NUM .And. SC6->(!Eof())
		reclock("SC6", .F.)
		SC6->(C6_QTDLIB) := 0
		SC6->(C6_QTDEMP) := 0
		SC6->(Msunlock())
		SC6->(DbSkip())
	EndDo
return (self)

/*/{Protheus.doc} delPedido
@author bolognesi
@since 18/10/2016
@version 1.0
@param cFil, characters, Filial utilizada, padrão é filial corrente
@param cPed, characters, Numero do Pedido a ser excluido
@type method
@description Deletar um pedido de venda via rotina automática.
/*/
method delPedido(cFil,cPed) class cbcPedido
	Local aItns		:= {}
	Local aCabec	:= {}
	Local cItem		:= ""
	Local nX		:= 0
	Local MsgRun	:= ""
	Local MsgTxt	:= ""
	Local cMSg		:= ""
	Default cFil	:= FwFilial()
	Default cPed 	:= ""
	::lselfOk		:= .T.
	::cselfMsg		:= ''

	If Empty(cPed)
		::lselfOk		:= .F.
		::cselfMsg		:= '[ERRO] - Parametros obrigatorios, cbcPedido():delPedido(cFil,cPed)'
	Else
		If ::getPedInfo(cFil,cPed):lTemtab

			aCabec := {	{"C5_FILIAL", ::oSC5[POS_OBJ]:C5_FILIAL	,Nil},;
				{"C5_NUM"	,::oSC5[POS_OBJ]:C5_NUM 				,Nil},;
				{"C5_TIPO"	,::oSC5[POS_OBJ]:C5_TIPO 				,Nil} }

			For nX := 1 To Len(::oSC6)
				aAdd(aItns, {{"LINPOS","C6_ITEM",::oSC6[nX]:C6_ITEM ,Nil},;
					{"AUTDELETA","S",Nil} } )
			Next nX

			::libPed(::oSC5[POS_OBJ]:C5_NUM)
			If ::isAuto()
				::JobAuto(cFil,aCabec,aItns,5)
			Else
				MsgRun := 'AGUARDE...'
				MsgTxt := "[AVISO] - EXCLUINDO O PEDIDO " + Alltrim(::oSC5[POS_OBJ]:C5_NUM)
				LjMsgRun( MsgTxt,MsgRun,{||::JobAuto(cFil,aCabec,aItns,5)})
			EndIf

			If !::lselfOk
				cMSg := '[ERRO] - Pedido não foi excluido'
				If !::isAuto()
					MessageBox(cMSg,'AVISO', 48)
				EndIf
				::emailRet(cMSg,Alltrim(::oSC5[POS_OBJ]:C5_NUM),"")
			Else
				//Propriedade para identificar um pedido deletado
				::lDelPed := .T.
				::defPvDiv(cFil,::oSC5[POS_OBJ]:C5_NUM)
			EndIf

		EndIf
	EndIf
return (self)

/*/{Protheus.doc} ExecAuto
@author bolognesi
@since 11/10/2016
@version 1.0
@type method
@description Realiza a chamada do StartJob para inclusão de um novo Pedido
/*/
method JobAuto(cDestFil,aCabPv,aItensPv,nOper) class cbcPedido
	Local aRet 		:= {}
	Default nOper 	:= 3 //Inclusão
	::lselfOk		:= .T.
	::cselfMsg		:= ''

	Sleep(500)
	aRet := startJob('U_execAuto', getenvserver(),.T.,cDestFil,aCabPv, aItensPv,nOper,FWIsAdmin())

	If ValType(aRet) == 'A'
		If !aRet[1]
			::lselfOk	:= .F.
			::aErrJob := aRet[2]
		EndIf
	Else
		::lselfOk	:= .F.
		::aErrJob 	:= {"[ERRO] - JobAuto() / U_execAuto()"}
	EndIf
return (self)

/*/{Protheus.doc} HdrFromMem
@author bolognesi
@since 21/10/2016
@version 1.0
@param aCmpVlr, array, Array com Arrays contendo campo descrição ex: { {"M->C5_NUM", "2344"}, {"M->C5_FILIAL", "01"} }
@type function
@description Função que retorna o array cabeçalho para inclusão de pedidos vis MsExecAuto
esta função carrega o array com todos os campos do SX3 relacionados ao SC5, e obtem seus valores
dos campos de Memoria (M->), quando o paramtero aCmpVlr e passado, estes campos tem seu valor definido
no array de retorno conforme passado no parametro (Em uma copia de pedido este parametro contem os campos
que devem ter seus valores alterados )
/*/
method HdrFromMem(aCmpVlr) class cbcPedido
	Local aHdr 				:= {}
	Local _cCmp			:= ""
	Local _cConteudo	:= ""
	Local nPos				:= 0
	Default aCmpVlr		:= {}

	DbSelectArea("SX3")
	DbSetOrder(1)
	SX3->(DbSeek("SC5", .F.))

	Do While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "SC5"
		_cCmp := "M->"+Alltrim(SX3->X3_CAMPO)
		If Type(_cCmp) <> "U"
			aAdd(aHdr,array(3))

			aHdr[Len(aHdr),1] := Alltrim(SX3->X3_CAMPO)

			nPos := AScan(aCmpVlr,{|a| a[NOME_CAMPO] == Alltrim(SX3->X3_CAMPO) })
			If nPos > 0
				_cConteudo := aCmpVlr[nPos,VALOR_CAMPO]
			Else
				_cConteudo := &_cCmp
			EndIf

			aHdr[Len(aHdr),2] := _cConteudo
			aHdr[Len(aHdr),3] := nil
		EndIf
		SX3->(dbSkip())
	EndDo
return(aHdr)

/*/{Protheus.doc} OrderArr
@author bolognesi
@since 10/10/2016
@version 1.0
@param aHdr, array, aHeader
@param aCls, array, aCols
@type method
@description Prepara o Cabeçalho e Itens, para enviar ao MSExecAuto
/*/
method OrderArr(aHdr, aCls,nVlrITU, nVlrMS, lDiv) class cbcPedido
	Local 	oFil			:= cbcFiliais():newcbcFiliais()
	Local  	cPV				:= ""
	Local 	nX				:= 0
	Local 	nPosCls			:= 0
	Local   nPosCab			:= 0
	Local   nPosIt			:= 0
	Local 	cDestFil		:= ""
	Local 	aCabPv			:= {}
	Local  	aItensPv		:= {}
	local   cItemPv 		:= StrZero(0,TamSx3('C6_ITEM')[1])
	Local 	aErro			:= {}
	Local  	cMSg			:= ""
	Local 	MsgRun			:= ""
	Local   MsgTxt			:= ""
	Local   lenItens		:= 0
	Local 	ZZPVDIV			:= ""
	Local	cTpCliPed		:= ""
	Local 	aCmpVlr			:= {}

	Local aSayMsg			:= {}
	Local aButMsg			:= {}

	Default aHdr		:= {}
	Default aCls		:= {}
	Default nVlrITU		:= 0
	Default nVlrMS		:= 0
	Default lDiv		:= .F.

	::lselfOk	:= .T.
	::cselfMsg	:= ''

	If Empty(aHdr) .Or. Empty(aCls)
		::lselfOk 	:= .F.
		::cselfMsg	:= "[ERRO] - Para incluir um pedido todos parametros obrigatorios - cbcPedido():orderAdd(aHdr, aCls)"
	Else
		oFil:setFilial(FILDEST)
		cPV 		:= ::orderNum()
		cDestFil	:= xFilial('SC5')
		//cDestFil	:= '01' //EXEMPLO TESTAR INTEGRIDADE
		oFil:backFil()

		If lDiv
			ZZPVDIV := M->(C5_NUM)
		Else
			ZZPVDIV := cPV
		EndIf

		//Regra para mudar TIPO CLIENTE, na divisão
		If cDestFil == 3LAGOAS
			If ::cUFCli $ 'MT//MG//'
				If M->(C5_TIPOCLI) == 'S'
					cTpCliPed := 'R'
				Else
					cTpCliPed := M->(C5_TIPOCLI)
				EndIf
			Else
				cTpCliPed := M->(C5_TIPOCLI)
			EndIf
		EndIF

		//Campos Cabeçalho de devem mudar na copia, o restante vem (SX3 x M->)
		AAdd(aCmpVlr, {"C5_FILIAL"	,cDestFil})
		AAdd(aCmpVlr, {"C5_NUM"		,cPV})
		AAdd(aCmpVlr, {"C5_TIPOCLI"	,cTpCliPed})
		AAdd(aCmpVlr, {"C5_ZZPVDIV"	,ZZPVDIV})
		AAdd(aCmpVlr, {"C5_USERINC"	,SubStr(cUsuario,7,15)})
		//Obter o Array do Cabeçalho
		aCabPv := ::HdrFromMem(aCmpVlr)

		//TODO mudar para um metodo
		For nPosCls := 1 to Len(aCls)
			If !GDDeleted(nPosCls, aHdr, aCls)

				//Controle do item
				cItemPv := soma1(cItemPv)

				//Regra para mudar o TES, na divisão
				If cDestFil == 3LAGOAS
					If ::cUFCli $ 'MT//MG//'
						If cTpCliPed == 'R'
							GdFieldPut("C6_TES"	,"501", nPosCls, aHdr, aCls, .F.)
						ElseIf cTpCliPed == 'F' .And. ::cCliContr //1=Sim( .T. ) / 2=Não( .F. )
							If GDFieldGet("C6_TES"	,nPosCls, .F. , aHdr, aCls) == '921'
								GdFieldPut("C6_TES"	,'501', nPosCls, aHdr, aCls, .F.)
							EndIf
						EndIf
					EndIf
				EndIf
				//Campos que mudam apos a divisão
				GdFieldPut("C6_FILIAL"	,cDestFil			, nPosCls, aHdr, aCls, .F.)
				GdFieldPut("C6_NUM"		,cPV	 			, nPosCls, aHdr, aCls, .F.)
				GdFieldPut("C6_ITEM"	,cItemPv 			, nPosCls, aHdr, aCls, .F.)
				GdFieldPut("C6_CLI"		,M->(C5_CLIENTE) 	, nPosCls, aHdr, aCls, .F.)
				GdFieldPut("C6_LOJA"	,M->(C5_LOJACLI) 	, nPosCls, aHdr, aCls, .F.)

				aAdd(aItensPv,{})

				For nPosCab := 1 to Len(aHdr)
					If Empty(GDFieldGet(aHdr[nPosCab,2],nPosCls, .F., aHdr, aCls ))
						Loop
					EndIf
					aAdd(aItensPv[nPosCls],Array(3))
					nPosItem := Len(aItensPv[nPosCls])

					aItensPv[nPosCls,nPosItem,1] := aHdr[nPosCab,2]
					aItensPv[nPosCls,nPosItem,2] := GDFieldGet(aItensPv[nPosCls,nPosItem,1],nPosCls, .F., aHdr, aCls)
					aItensPv[nPosCls,nPosItem,3] := Nil
				Next

			EndIf
		Next nX
		//Envia para o JOB MsExecAuto
		If ::isAuto()
			::JobAuto(cDestFil,aCabPv,aItensPv)
		Else
			MsgRun += 'AGUARDE...'
			If lDiv
				MsgTxt += "[AVISO] - DIVIDINDO OS PEDIDOS "
			Else
				MsgTxt += "[AVISO] - CRIANDO PEDIDO NA OUTRA FILIAL "
			EndIf
			LjMsgRun( MsgTxt,MsgRun,{||::JobAuto(cDestFil,aCabPv,aItensPv)})
		EndIf

		If ::lselfOk
			If !::isAuto()

				lenItens := Len(aCls)
				cMSg += '<html>'
				cMSg += '<h1>'
				cMSg += 'ESTE PEDIDO NRO. ' 	+ AllTrim(M->(C5_NUM))

				If ::lDelPed
					cMSg += ' FOI EXCLUIDO,'
				Else
					If lDiv
						cMSg += ' FOI DIVIDIDO,'
					Else
						cMSg += ' NÃO SERÁ INCLUIDO!,'
					EndIf
				EndIf

				cMSg += '</h1>'
				cMSg +=  '<br />'
				If lenItens > 1
					cMSg += ' SENDO QUE OS ITENS: '
				Else
					cMSg += ' SENDO QUE O ITEM: '
				EndIf
				cMSg += '<br />' + '<br />'

				cMSg += '<table border="1">'
				cMSg += '<tr>'
				cMSg += '<td><b>ITEM</b></td>'
				cMSg += '<td><b>CODIGO</b></td>'
				cMSg += '<td><b>DESCRI</b></td>'
				cMSg += '<td><b>QTDVEND</b></td>'
				cMSg += '<td><b>VALOR</b></td>'
				cMSg += '</tr>'
				For nX := 1 to lenItens
					If !GDDeleted(nX, aHdr, aCls)
						cMSg += '<tr>'
						cMSg += '<td>' + GDFieldGet("C6_ITEM"	,nX	, .F. 	, aHdr, aCls) + '</td>'
						cMSg += '<td>' + GDFieldGet("C6_PRODUTO",nX	, .F. 	, aHdr, aCls) + '</td>'
						cMSg += '<td>' + GDFieldGet("C6_DESCRI"	,nX	, .F. 	, aHdr, aCls) + '</td>'
						cMSg += '<td>' + cValToChar(GDFieldGet("C6_QTDVEN"	,nX	, .F. 	, aHdr, aCls)) + '</td>'
						cMSg += '<td>' + Transform(GDFieldGet("C6_VALOR"	,nX	, .F. 	, aHdr, aCls),PesqPict('SC6','C6_VALOR')) + '</td>
						cMSg += '</tr>'
					EndIf
				Next nX
				cMSg += '</table>'
				cMSg += '<br />'
				cMSg += '<h2>'

				If lenItens > 1
					cMSg += 'FORAM MOVIDOS PARA O PEDIDO NRO. ' + AllTrim(cPV)
				Else
					cMSg += 'FOI MOVIDO PARA O PEDIDO NRO. ' + AllTrim(cPV)
				EndIf

				cMSg += ' CRIADO NA FILIAL ' + FWFilialName('01',cDestFil)
				cMSg += '</h2>'
				cMSg += '<br />'

				If nVlrITU > 0 .And. nVlrMS > 0
					cMSg += '<h3>'
					cMSg += '<b> Valor Total ITU: ' +  Transform(nVlrITU,PesqPict('SC6','C6_VALOR')) + '</b>'
					cMSg += '<br />'
					cMSg += '<b> Valor Total TL: ' +   Transform(nVlrMS,PesqPict('SC6','C6_VALOR')) + '</b>'
					cMSg += '</h3>'
				EndIf
				cMSg += '</html>'
				mostraMsg(cMSg)
			EndIf
			M->C5_ZZPVDIV := cPV
		Else
			If Empty(::aErrJob)
				cMSg := '[ERRO] - Rotina não foi processada'
			Else
				cMSg := '[ERRO] - '
				cMSg += ::aErrJob[1] + linha
				If Len(::aErrJob) > 1
					For nX := 2 To Len(::aErrJob)
						If  'Invalido' $ self:aErrJob[nX]
							cMSg += ::aErrJob[nX] + linha
						EndIf
					Next nX
				EndIf
			EndIF
			If !::isAuto()
				MessageBox(cMSg,'AVISO', 48)
			EndIf
			RollBackSx8()
		EndIf

		//Enviar email para TI sobre status da operação
		::emailRet(cMSg,AllTrim(M->(C5_NUM)), AllTrim(cPV))
	EndIf
return(self)

/*/{Protheus.doc} emailRet
@author bolognesi
@since 11/10/2016
@version 1.0
@param aRet, array, Array Retornado pelo MsExecAuto Inclusão via Job do Pedido
@type method
/*/
method emailRet(cMsg,cPedOri, cPedDest) class cbcPedido
	Local nX			:= 0
	Local cMsgFinal		:= ""
	Local cAviso		:= ""
	Local aMsgFinal		:= {}
	Local lAchou
	Local aUserFi		:= {}
	Local cUserMail		:= ""
	Local aTo			:= {}
	Default cPedDest	:= ""

	PswOrder(2)
	lAchou	:= PSWSeek(cUserName)
	aUserFi	:= PswRet(1)
	cUserMail := Alltrim(aUserFi[POS_USR][USR_EMAIL])

	If Empty(cUserMail)
		aTo := {EMAIL_FIXO}
	Else
		aTo := {EMAIL_FIXO, cUserMail }
	EndIf

	If	!::lselfOk
		If !Empty(::aErrJob)
			For nX := 1 To Len(::aErrJob)
				Aadd(aMsgFinal,{::aErrJob[nX]})
			Next nX
		Else
			aMsgFinal := {{cMsg}}
		EndIf
		cAviso		:= ' Não foi processado '
	Else
		cMsg := StrTran(StrTran(cMsg, '<html>',''), '</html>','')
		aMsgFinal := {{cMsg}}
		cAviso		:= ' Foi processado com sucesso '
	EndIf
	//TODO Enviar email para quem inclui o pedido tambem
	u_envmail(aTo, ASSUNTO_FIXO_DIV + cPedOri + cAviso,{"Mensagem"},aMsgFinal)
return (self)

/*/{Protheus.doc} syncOkMsg
@author bolognesi
@since 13/10/2016
@version 1.0
@type method
@description Por herança a classe cbcIndRules possui as propriedades para tratamento de erro (logico e Mensagem)
Esta classe Filha tambem, tem estas propriedades este metodo serve para sincronizar os dois
/*/
method syncOkMsg() class cbcPedido
	::lselfOk 	:= ::lOk
	::cselfMsg	:= ::cMsgErr
return (self)

/*/{Protheus.doc} setClientInfo
@author bolognesi
@since 13/10/2016
@version 1.0
@param cCli, characters, Codigo do Cliente
@param cLoja, characters, Loja do Cliente
@param cNrPed, characters, Numero do Pedido
@type method
@description Este metodo que executa o construtor da classe herdada CbcIndRules
herdando todos os metodos da classe que aplica as regras de industrialização
/*/
method setClientInfo(cCli,cLoja,cNrPed ) class cbcPedido
	Default cCli 	:= ""
	Default cLoja  	:= ""
	Default cNrPed	:= ""
	::lselfOk		:= .T.
	::cselfMsg		:= ""

	If Empty(cCli) .Or. Empty(cLoja) .Or. Empty(cNrPed)
		::lselfOk		:= .F.
		::cselfMsg		:= "[ERRO] - Definir Propriedades cCliente, cLojaCli e cNrPed"
	Else
		::newCbcIndRules(cCli, cLoja, cNrPed, .F., .T.)
		::syncOkMsg()
	EndIf

return (self)

/*/{Protheus.doc} updScreen
@author bolognesi
@since 17/10/2016
@version 11.0
@type method
@description Analisando o Fonte MATA410, existem duas variaveis privates (oGetPV,oGetDad)
que representam o MsGetDados() do Cabeçalho e dos Itens do Pedido, logo estes objetos possuem
o metodo Refresh(), nesta classe será utilizado para sempre que realizarmos alterações no Acols
dos itens para dividir o pedido, poder atualizar as informações na tela
/*/
method updScreen() class cbcPedido
	If !::isAuto()
		If ValType(oGetPV) == 'O'
			oGetPV:Refresh()
		EndIf
		If ValType(oGetDad) == 'O'
			oGetDad:Refresh()
		EndIf
	EndIf
return (self)

/*/{Protheus.doc} closeScreen
@author bolognesi
@since 17/10/2016
@version 1.0
@type method
@description Analisando o fonte MATA410 constatei que as variaveis MsGetDados (oGetPV, oGetDad)
possuem uma propriedade (OWND) que representa a MSDIALOG da qual eles fazem parte, desta forma
utilizando o Metodo End() do Objeto MSDIALOG(OWND), consigo fechar a tela de inclusão do pedido.
Este artificio é utilizado quando estamos incluindo um pedido em ITU, e todos os itens devem ser em treas lagoas
neste caso o aCols de Itu ficara vazio, neste caso aviso o usuario que o pedido foi inserido na outra filial e fecho a tela
/*/
method closeScreen() class cbcPedido
	If !::isAuto()
		If ValType(oGetDad) == 'O'
			oGetDad:OWND:End()
		EndIf
		////DIV
	Else
		If Type('__cPedDiv') <> 'U'
			If !Empty(::cPvDest)
				__cPedDiv := FILDEST + '-' +::cPvDest
			EndIf
		EndIf
	EndIf
return (Self)

/*/{Protheus.doc} workWithScreen
@author bolognesi
@since 13/10/2016
@version 1.0
@type method
@description Este metodo realiza o processo de divisão do pedido
partindo do principio de que os dados estão em tela (aHeader, aCols e variaveis M->)
/*/
method workWithScreen() class cbcPedido
	Local nX 		:= 0
	Local nVlrMS	:= 0
	Local nVlrITU	:= 0
	Local cPrdCor	:= ""
	Local nVlrPed	:= GetMV("MV_VLRPED")
	Local aColsItu	:= {}
	Local aColsTl	:= {}
	Local aBkAcol	:= {}

	::oArea:saveArea( {'SB1','SA1'} )

	If ::setClientInfo(M->C5_CLIENTE, M->C5_LOJACLI,M->C5_NUM):lselfOk
		if GetNewPar('ZZ_NWDIVCR', .T.) .and. ::cCondPag ==  BNDES
		 	return(self)
		Endif
			if ::splitOrder()
				aColsItu := aClone(aCols)
				For nX := 1 to Len(aCols)
					If !GDDeleted(nX)
						if GetNewPar('ZZ_NWDIVCR', .T.)
							cCodProduto     :=  GDFieldGet("C6_PRODUTO", nX)
							if SB1->(DbSeek(xFilial("SB1") + cCodProduto,.F.))
								nValorItem  :=  GDFieldGet("C6_VALOR", nX)
								if ( (SB1->(Alltrim(B1_ZZFILFB)) == '3') .and. (SB1->(B1_ZZMIXPR) == '1') )
									nVlrMS  += nValorItem
									aColsItu[nX,Len(aColsItu[nX])] := .T.
									AAdd(aColsTl,aCols[nX])
								else
									nVlrITU += nValorItem
								endIf
							endIf
						else
							//Obter Informações do produto, preparando chamada Tem3Lag()
							If  ::vldFab(GDFieldGet("C6_PRODUTO",nX)):lfab3l
								nVlrMS  += GDFieldGet("C6_VALOR",nX)
								aColsItu[nX,Len(aColsItu[nX])] := .T.
								AAdd(aColsTl,aCols[nX])
							Else
								nVlrITU += GDFieldGet("C6_VALOR",nX)
							EndIf
						endif
					EndIf
				Next nX

				//Regra Itu == 0 e TL > 0 Excuir pedido de Itu e colocar tudo em 3 lagoas
				If nVlrITU == 0 .And. nVlrMS > 0
					If !::isAuto()
						MsgInfo('<html><h2><b>Todos os itens deste pedido, </ br> serão transferidos para um pedido na outra Filial!</b></h2></html>', 'Aviso')
					EndIf
					aBkAcol := aCols
					aCols 	:= aColsItu
					::przEntrega()
					::updScreen()

					//Deletar o pedido em Itu caso exista SC5/SC6
					If !::delPedido(FwFilial(),M->(C5_NUM)):lselfOk
						//Restaurar aCols original em caso de erros
						aCols := aBkAcol
						M->C5_TOTAL := (nVlrITU + nVlrMS )
						U_M410LIOK()
						::przEntrega()
						::updScreen()
					Else
						//Realizar a iclusão de um novo pedido na outra filial
						If !::OrderArr(aHeader, aColsTl,nVlrITU, nVlrMS, .F.):lselfOk
							//Restaurar aCols original em caso de erros
							aCols := aBkAcol
							M->C5_TOTAL := (nVlrITU + nVlrMS )
							::przEntrega()
							U_M410LIOK()
							::updScreen()
						Else
							::lselfOk	:= .F.
							::cselfMsg 	:= 'Divisão Pedidos'
							::closeScreen()
							::bxOrc() //Baixar o orçamento caso exista
						EndIf
					EndIf
					//Apos divisão, a soma dos itens nas duas filiais é maior ou igual ao valor estipulado
					//Neste caso divide o pedido.
				ElseIf nVlrITU >= nVlrPed .And. nVlrMS >= nVlrPed
					//BackUp do Acols original para restaurar em caso de erros no ExecAuto
					aBkAcol := aCols
					//Definir o array que será gravado na filial de origem
					aCols := aColsItu
					M->C5_TOTAL := nVlrITU
					U_M410LIOK()
					::przEntrega()
					::updScreen()
					//Realizar a iclusão de um novo pedido na outra filial
					If !::OrderArr(aHeader, aColsTl,nVlrITU, nVlrMS, .T.):lselfOk
						//Restaurar aCols original em caso de erros
						aCols := aBkAcol
						M->C5_TOTAL := (nVlrITU + nVlrMS )
						U_M410LIOK()
						::updScreen()
					EndIf
				Endif
		EndIf
	EndIf
	::oArea:backArea()
return (self)

/*/{Protheus.doc} workWithTable
@author bolognesi
@since 13/10/2016
@version 1.0
@type method
@description Este metodo realiza o processo de divisão do pedido
partindo do principio de que os dados estão em tabela (SC5, SC6)
/*/
method workWithTable(cNroPed) class cbcPedido
	Default cNroPed := ""
	::cNroPed := cNroPed
return (self)

/*/{Protheus.doc} actionAcols
@author bolognesi
@since 13/10/2016
@version undefined
@param aHeader, array, descricao
@param aCols, array, descricao
@type method
@description Metodo generico qe percorre um acols
e realiza algum procesaamento nele
/*/
method actionAcols(aHdr,aCls) class cbcPedido
	Local nI 	 := 0
	Local cMsg	:= ""
	Default aHdr := {}
	Default aCls := {}

	::lselfOk	:= .T.
	::cselfMsg	:= ''
	If Empty(aHdr) .Or. Empty(aCls)
		::lselfOk	:= .F.
		::cselfMsg	:= '[ERRO] - Parametros obrigatorios cbcPedido:checkDiv(aHdr,aCls)'
	Else
		For nI:= 1 to Len(aCls)
			If !GDDeleted(nX, aHdr, aCls)
				//Acao a ser executada
				//GDFieldGet("C6_ITEM"	,nX	, .F. , aHdr, aCls)
				//GdFieldPut("C6_ITEM"	,VALOR, nI, aHdr, aCls, .F.)
			EndIf
		Next nI

		If !::isAuto()
			//EXIBIR MENSAGEM
		EndIf
	EndIf
return(self)

/*/{Protheus.doc} checkDiv
@author bolognesi
@since 13/10/2016
@version undefined
@param cNroPed, characters, Numero do Pedido
@type method
@description verifica se um pedido foi dividido
e informa o numero do pedido na outra ponta
/*/
method checkDiv(cNroPed) class cbcPedido
	Local nX 		:= 0
	Local cQry		:= ""
	::lselfOk		:= .F.
	::cselfMsg		:= ''
	::oSql:addFromTab('SC5')

	If FwFilial('SC5') == '01'
		::oSql:addCampos({'C5_NUM','C5_ZZPVDIV'})
		::oSql:addWhere("C5_ZZPVDIV = '"+ cNroPed + "'")
		If ::oSql:QrySelect():lOk
			If ::oSql:nRegCount > 0
				::lselfOk := .T.
				For nX := 1 To ::oSql:nRegCount
					If Empty(::oSql:oRes[nX]:C5_NUM)
						::cselfMsg += ::oSql:oRes[nX]:C5_ZZPVDIV + ' ; '
					Else
						::cselfMsg += ::oSql:oRes[nX]:C5_NUM + ' ; '
					EndIf
				Next nX
			EndIf
		EndIf
	Else
		cQry += " SELECT C5_NUM, C5_ZZPVDIV "
		cQry += " FROM " + RetSqlName('SC5')
		cQry += " WHERE C5_FILIAL = '02' "
		cQry += " AND C5_ZZPVDIV IN("
		cQry += " 	SELECT  C5_ZZPVDIV "
		cQry += " 	FROM " + RetSqlName('SC5')
		cQry += " 	WHERE
		cQry += " 	C5_FILIAL = '02'
		cQry += " 	AND C5_NUM = '" + cNroPed +"'"
		cQry += " 		AND  D_E_L_E_T_ <> '*' "
		cQry += " 		) "
		cQry += " AND D_E_L_E_T_ <> '*' "
		cQry += " AND C5_ZZPVDIV <> ''	"

		If ::oSql:QryToDb(cQry):lOk
			If ::oSql:nRegCount > 0
				::lselfOk := .T.
				If ! Empty(::oSql:oRes[1]:C5_ZZPVDIV)
					If cNroPed != ::oSql:oRes[1]:C5_ZZPVDIV
						::cselfMsg += 'Itu..........:' + ::oSql:oRes[1]:C5_ZZPVDIV + ' ; '
					EndIf
				EndIf
				For nX := 1 To ::oSql:nRegCount
					If ! Empty(::oSql:oRes[nX]:C5_NUM)
						//Não repetir numero do pedido
						If cNroPed != ::oSql:oRes[nX]:C5_NUM
							::cselfMsg += 'TrêsLagoas...:' + ::oSql:oRes[nX]:C5_NUM + ' ; '
						EndIf
					EndIf
				Next nX
			EndIf
		EndIf
	EndIf
return (self)

/*/{Protheus.doc} sendMirror
@author bolognesi
@since 07/11/2016
@version 1.0
@type method
@description Metodo utilizado para enviar (Email/Relatorio) do Espelho do pedido
utiliza a classe cbcDadosEspelho() para obter as informações e cbcDataToPrint()
para realizar o envio/impressão. Utiza o parametro MV_SNESPED (Para definir de envia espelho ou não)
@example Local ped := cbcPedido():newcbcPedido(cNroPed):sendMirror()
/*/
method sendMirror(lAlt, lInc, lDel ) class cbcPedido
	Local pedPrt 	:= cbcDadosEspelho():newcbcDadosEspelho()
	Local oBase 	:= ManBaseDados():newManBaseDados()
	Local bErro
	Local aRet		:= {.T.,{''}}
	Default lAlt 	:= .F. 	//Alterando
	Default lInc	:= .T.	//Incluindo
	Default lDel	:= .F.  //Deletando

	::lselfOk 	:= .T.
	::cselfMsg	:= ""

	If GetNewPar('MV_SNESPED', .T.)
		If Empty(::cNroPed)
			::lselfOk 	:= .F.
			::cselfMsg	:= "[ERRO] Na classe cbcPedido():sendMirror(), é obrigatorio o numero do pedido "
		Else
			If vlMirPed(::cNroPed, Self)
				bErro	:= ErrorBlock({|oErr| HandleEr(oErr, @aRet)})
				BEGIN SEQUENCE
					If lAlt
						pedPrt:setOper('ALTERAR')

					ElseIf lInc
						pedPrt:setOper('INCLUIR')

					ElseIf lDel
						pedPrt:setOper('DELETAR')
					EndIf

					//Atualizar o campo de envio de e-mail
					If pedPrt:emailOrder(::cNroPed):lSndEmailOk
						oBase:addCpoVlr('C5_ZZSMAIL','S')
						oBase:updTable(::oSC5[POS_OBJ]:R_E_C_N_O_)
					Else
						oBase:addCpoVlr('C5_ZZSMAIL','E') //TODO email com erro
						oBase:updTable(::oSC5[POS_OBJ]:R_E_C_N_O_)
					EndIf

				END SEQUENCE
				ErrorBlock(bErro)
				//aRet := {.F.,{'[' + oErr:Description + ']',oErr:ERRORSTACK}}
				If !aRet[LOK]
					::lselfOk 	:= .F.
					::cselfMsg	:= "[ERRO] " + ' Descr:..' + aRet[ERRO][DESCR] + ' Pilha:..' +  aRet[ERRO][PILHA]
					U_autoalert(::cselfMsg)
				EndIf
			EndIF
		EndIf
	EndIf
return (Self)

/*/{Protheus.doc} hasChanged
@author bolognesi
@since 11/11/2016
@version 1.0
@type method
@description Realiza um comparação entre campos de tela e campos da tabela para
identificar alterações nos campos obtidos pelo metodo getPedInfo() responsavel
por definir as propriedades ::oSC5  ::oSC6, acessadas como no exemplo:
::oSC5[POS_OBJ]:C5_CLIENTE
/*/
method hasChanged() class cbcPedido
	Local lRet		:= .F.
	Local nI  		:= 0
	Local nX 		:= 0
	Local nY		:= 0
	Local nToTela	:= 0
	Local lNewItem	:= .F.
	Local lExit		:= .F.

	If !::lTemtab
		::getPedInfo()
	EndIf
	If ::oSC5 != Nil .And. ::oSC6 != Nil

		//Diferenças no CABEÇALHO
		If 	(::oSC5[POS_OBJ]:C5_CONDPAG != Alltrim(M->(C5_CONDPAG))) .Or. ;
				(::oSC5[POS_OBJ]:C5_TPFRETE != Alltrim(M->(C5_TPFRETE)))

			lRet := .T.

			//Diferenças nos ITENS
		Else
			//Total de itens não deletados no acols
			For nI := 1 To Len(aCols)
				lNewItem := .T.
				For nX:= 1 to Len(::oSC6)
					If GDFieldGet("C6_ITEM" ,nI	, .F. , aHeader, aCols) == ::oSC6[nX]:C6_ITEM
						//Não é novo item
						lNewItem := .F.
						//Item Existia e foi Deletado
						If GDDeleted(nI, aHeader, aCols)
							lRet := .T.
							exit
							//Item Existia e foi modificado
						Else
							If 	(::oSC6[nX]:C6_PRODUTO  != Alltrim(GDFieldGet("C6_PRODUTO" 	,nI	, .F. , aHeader, aCols))) 	.Or.;
									(::oSC6[nX]:C6_QTDVEN   != GDFieldGet("C6_QTDVEN" 			,nI	, .F. , aHeader, aCols)) 		.Or.;
									(::oSC6[nX]:C6_ACONDIC  != Alltrim(GDFieldGet("C6_ACONDIC" 	,nI	, .F. , aHeader, aCols))) 		.Or.;
									(::oSC6[nX]:C6_LANCES   != GDFieldGet("C6_LANCES" 			,nI	, .F. , aHeader, aCols)) 		.Or.;
									(::oSC6[nX]:C6_METRAGE  != GDFieldGet("C6_METRAGE" 			,nI	, .F. , aHeader, aCols)) 		.Or.;
									(::oSC6[nX]:C6_PRCVEN   != GDFieldGet("C6_PRCVEN" 			,nI	, .F. , aHeader, aCols))
								lRet := .T.
								exit
							EndIf
						EndIf
					EndIf
				Next nX

				If lRet
					exit
					//É um novo item
				ElseIf lNewItem
					lRet := .T.
					exit
				EndIf
			Next nI
		EndIF
	EndIF
return (lRet)

/*/{Protheus.doc} execAuto
@author bolognesi
@since 11/10/2016
@version 1.0
@param cFil, characters, Filial para para o MsExecAuto
@param aCabPv, array, Array contendo o Cabeçalho para o MsExecAuto
@param aItensPv, array, Itens do MSExecAuto
@type function
@description Função que deve ser chamada pela função StartJob e
inicia uma nova Thread sem consumir licenças para executar a inclusão
de um pedido via MsExecAuto
/*/
User Function execAuto(cFil,aCabPv,aItensPv,nOper,lIsAdm )
	Local aRet				:= {.T.,{}}
	Local bErro
	Private	lMsErroAuto		:= .F.
	Private lMsHelpAuto		:= .T.
	Private lAutoErrNoFile	:= .T.
	Private lIsJobAuto		:= .T.
	Private lAdm			:= lIsAdm
	Default nOper 			:= 3

	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, @aRet)})
	BEGIN SEQUENCE
		//Preparar o ambiente de forma a não consumir licença
		ConsoleLog('Iniciando ambiente para dividir pedido')
		RPCSetType(3)
		RPCSetEnv('01',cFil,,,'FAT',GetEnvServer(),{} )
		//Processar
		ConsoleLog('Executando o MSExecAuto Mata410')
		BEGIN TRANSACTION
			MSExecAuto({|x,y,z|Mata410(x,y,z)},aCabPv,aItensPv,nOper)
			If lMsErroAuto
				//TODO Criar metodo tratar erro, que envia o email
				ConsoleLog('MsExecAuto com erro')
				aErro := GetAutoGrLog()
				aRet	:= {.F.,aErro}
				DisarmTransaction()
			Else
				ConsoleLog('MsExecAuto executado com sucesso')
			EndIf
		END TRANSACTION
		//Limpar o Ambiente
		RPCClearEnv()
		ConsoleLog('Finalizando o ambiente')
		RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
return(aRet)

/*/{Protheus.doc} checkDiv
@author bolognesi
@since 13/10/2016
@version 1.0
@param cNrPed, characters, Numero do pedido
@type function
@description Encapsular o metodo checkDiv, para poder ser chamado
em forma de user function
/*/
User Function checkDiv(cNrPed,cTxtSolu)
	Local ocbcPed		:= Nil
	Local cMsg			:= ""
	Local aRet			:= {.T.,{''}}
	Default cNrPed		:= ""
	Default cTxtSolu	:= ''

	If !Empty(cNrPed)
		ocbcPed := cbcPedido():newcbcPedido(cNrPed)

		bErro	:= ErrorBlock({|oErr| HandleEr(oErr, @aRet)})
		BEGIN SEQUENCE
			If ocbcPed:checkDiv(cNrPed):lselfOk
				If !ocbcPed:isAuto()
					If !Empty(ocbcPed:cselfMsg)
						cMsg := 'O Pedido Nro.' + Alltrim(cNrPed) + ' esta associado com este(s) pedido(s): ' + linha +;
							Alltrim(StrTran(ocbcPed:cselfMsg,';',linha))
						If Empty(cTxtSolu)
							cTxtSolu	:= 'Caso necessario, excluir tambem estes pedidos.'
						EndIF
						xMagHelpFis('Divisão de Pedido',cMsg, cTxtSolu)
					EndIf
				EndIf
			EndIf
		END SEQUENCE
		ErrorBlock(bErro)
		//aRet := {.F.,{'[' + oErr:Description + ']',oErr:ERRORSTACK}}
		If !aRet[LOK]
			//Tratar possiveis erros caso necessario.
		EndIf
		FreeObj(ocbcPed)
	EndIf
return Nil

/*/{Protheus.doc} mostraMsg
@author bolognesi
@since 17/10/2016
@version 1.0
@param cMSg, characters, Mensagem em marcação HTML, sem a Tag <html></html>
@type function
@description exibir a mensagem com as informações sobre a divisão do pedido (Utilizando ScrollArea)
/*/
Static Function mostraMsg(cMSg)
	Local oFont 	:= TFont():New('Courier new',,-10,.F.)
	Local oSay		:= Nil
	Local oPanel	:= Nil
	Local lHtml 	:= .T.
	Local oScroll 	:= Nil
	Local aButtons 	:= {}
	Static oDlg		:= Nil

	DEFINE DIALOG oDlg TITLE "Resultado Divisão do Pedido" FROM 180,180 TO 650,960 PIXEL

	oScroll := TScrollArea():New(oDlg,01,01,100,100)
	oScroll:Align := CONTROL_ALIGN_ALLCLIENT
	@ 000,000 MSPANEL oPanel OF oScroll SIZE 500,3000 COLOR CLR_HRED
	oScroll:SetFrame(oPanel)
	oSay:= TSay():New(01,01,{||cMSg},oPanel,,oFont,,,,.T.,,,500,3000,,,,,,lHtml)
	EnchoiceBar(oDlg, {||oDlg:End()}, {||oDlg:End()},,aButtons)

	ACTIVATE DIALOG oDlg CENTERED

Return (Nil)

/*/{Protheus.doc} HandleEr
@author bolognesi
@since 17/10/2016
@version 1.0
@param oErr, object, Objeto retornado pelo sistema, com informações sobre o erro
@param aRet, array,  Parametro por referencia com a variavel que contem a descrição do erro.
@type function
@description Controle de erro personalizado para obter e tratar os erros na rotina startJob()
/*/
Static function HandleEr(oErr, aRet)
	aRet := {.F.,{'[' + oErr:Description + ']',oErr:ERRORSTACK}}
	ConsoleLog('[' + oErr:Description + ']' + oErr:ERRORSTACK)
	If !(_SetAutoMode() .Or. IsBlind())
		errorDlg(oErr, '[IFC-COBRECOM]- Ocorreu um erro, por favor avisar o Departamento de T.I.')
	EndIF
	BREAK
return

/*/{Protheus.doc} ConsoleLog
@author bolognesi
@since 17/10/2016
@version 1.0
@param cMsg, characters, descricao
@type function
@description Exibir mensagens padronizadas no arquivo de logo (Console)
/*/
static function ConsoleLog(cMsg)
	ConOut("[Dividir pedido - "+DtoC(Date())+" - "+Time()+" ] "+cMsg)
return

/*/{Protheus.doc} vlMirPed
@author bolognesi
@since 07/11/2016
@version undefined
@param cPed, characters, Numero do Pedido
@type function
@description Função que determina se o pedido deve ou não
ser enviado para o cliente como espelho.
/*/
Static Function vlMirPed(cPed, oSelf)
	Local lRet 		:= .T.
	Local lAutoAdm	:= .F.
	Local _Cliente	:= ""
	Local _Loja		:= ""
	Local _NumPed	:= ""
	Local _cCgc		:= ""
	Local _cTipo	:= ""
	Local _lFilial	:= .F.
	Local _lAntigo	:= .F.
	Default cPed 	:= ""

	If !Empty(cPed)

		If oSelf:getPedInfo(FwFilial(),cPed):lTemtab

			oSelf:oArea:saveArea( {'SC5', 'SC6', 'SA1'} )
			//Variavel privada definida na função execAuto(), quando divisão do pedido
			If Type('lAdm') <> 'U'
				lAutoAdm := lAdm
			EndIf

			_Cliente 	:= oSelf:oSC5[POS_OBJ]:C5_CLIENTE
			_Loja		:= oSelf:oSC5[POS_OBJ]:C5_LOJACLI
			_NumPed		:= oSelf:oSC5[POS_OBJ]:C5_NUM
			_cTipo		:= oSelf:oSC5[POS_OBJ]:C5_TIPO
			_cCgc		:= SubStr(Posicione("SA1",1,xFilial("SA1")+_Cliente+_Loja,"A1_CGC"),1,8)
			_lAntigo	:= (oSelf:oSC5[POS_OBJ]:C5_ZZSMAIL == 'V')
			lFilial 	:=  _cCgc == "02544042"

			//NÃO ENVIAR EMAIL QUANDO:
			//Pedido entre Filiais
			If lFilial
				lRet := .F.
				//Pedido não seja normal, retorno, ou para Fornecedores
			ElseIf _cTipo != 'N'
				lRet := .F.
				//Pedidos antigos que na sua inclusão não enviou email
				//todos os pedidos antes da implementação estes não devem ser enviado emails
				//estes pedidos são identificados pelo campo C5_ZZSMAIL ==  'V'
			ElseIf _lAntigo
				lRet := .F.
				//Quando usuario for grupo Administradores Perguntar se deseja enviar o e-mail,
				//quando divisão(provavelmente estará em rotina automatica) e for do Grupo Administradores
				//não enviar e-mail.
			ElseIf FWIsAdmin() .Or. lAutoAdm
				lRet := u_autoAlert('Deseja enviar email para o cliente com o espelho do pedido?',.T.,'MsgBox','Titulo',,'YesNo',.F.)
			EndIf

			oSelf:oArea:backArea()
		EndIf
	EndIf

return(lRet)

/*/{Protheus.doc} getTaxes
@author bolognesi
@since 27/10/2016
@version 1.0
@param aItm, array, descricao Array com 7 posições (Obrigatorias) contendo
os parametros para chamar MaFisAdd() e MaFisRet
@type function
@Description Função de proxy para chamar a função interna MaFisAdd(), chamada por item
/*/
Static Function getTaxes(aItm)
	Local aRetTx		:= {}
	Local cClasFis		:= ""

	DbSelectArea("SF4")
	DbSetOrder(1)  // F4_FILIAL+F4_CODIGO

	If Len(aItm) == 7

		SF4->(DbSeek(xFilial("SF4") + aItm[TES], .F. ))
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1") + aItm[CODIGO], .F. )
		If SB1->(B1_ORIGEM) # Left(aItm[CLASFIS],1)
			cClasFis := aItm[CLASFIS]
		EndIf

		MaFisAdd(aItm[CODIGO],;	// 1-Codigo do Produto ( Obrigatorio )
		aItm[TES],;	   			// 2-Codigo do TES ( Opcional )
		aItm[QUANTIDADE],;		// 3-Quantidade ( Obrigatorio )
		aItm[UNITARIO],;   		// 4-Preco Unitario ( Obrigatorio )
		0,;                     // 5-Valor do Desconto ( Opcional )
		"",;	   				// 6-Numero da NF Original ( Devolucao/Benef )
		"",;					// 7-Serie da NF Original ( Devolucao/Benef )
		0,;     				// 8-RecNo da NF Original no arq SD1/SD2
		0,;					 	// 9-Valor do Frete do Item ( Opcional )
		0,;					   	// 10-Valor da Despesa do item ( Opcional )
		0,;					 	// 11-Valor do Seguro do item ( Opcional )
		0,;					    // 12-Valor do Frete Autonomo ( Opcional )
		aItm[TOTAL],;  			// 13-Valor da Mercadoria ( Obrigatorio )
		0,;						// 14-Valor da Embalagem ( Opiconal )
		,;                      // 15
		,;                      // 16
		,;                      // 17
		,;					  	// 18
		,;                      // 19
		,;                      // 20
		,;                      // 21
		,;                      // 22
		,;                      // 23
		,;                      // 24
		,;                      // 25
		,;                      // 26
		,;                      // 27
		cClasFis,)				// 28

		AAdd(aRetTx,MaFisRet(aItm[POS],"IT_ALIQICM"))
	Else
		AAdd(aRetTx,0)
	EndIf
return(aRetTx)

/*/{Protheus.doc} tstTaxes
@author bolognesi
@since 27/10/2016
@version 1.0
@param cPed, characters, Pedido onde o campo C6_ZZPICM deverá ser alterado
@type function
@description Função para testar methodo CalcTaxes()
/*/
User Function tstTaxes(cPed,cDtParam) //U_tstTaxes('163902') = Unico Pedido U_tstTaxes() U_tstTaxes('','20160810') = Todos
	Local oPed 		:= Nil
	Local oSql 		:= SqlUtil():newSqlUtil()
	Local oResult	:= Nil
	Default cPed	:= ""
	Default cDtParam	:= '20160101'
	If Empty(cPed)
		oSql:addFromTab('SC5')
		oSql:addCampos({'C5_NUM'})
		oSql:addWhere("C5_FILIAL = '"+ FwFilial() +"' ")
		oSql:addWhere("C5_TIPO =  'N'")
		oSql:addWhere("C5_EMISSAO >= '" + cDtParam + "'")

		if oSql:QrySelect():lOk
			MessageBox('Inicio do processo para ' + cValToChar(oSql:nRegCount) + ' pedidos!!', 'Aviso', 48)
			oResult := oSql:oRes
			For nX := 1 To oSql:nRegCount
				oPed := cbcPedido():newcbcPedido(oResult[nX]:C5_NUM)
				oPed:CalcTaxes("",.F.)
			Next nX
		Else
			MessageBox(oSql:cMsgErro, "Aviso",48)
		EndIF
	Else
		oPed := cbcPedido():newcbcPedido(cPed)
		oPed:CalcTaxes(cPed,.F.)
	EndIf
	MessageBox('Terminado', "Aviso",48)
Return (Nil)
