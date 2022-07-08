#include "totvs.ch"
#include "rwmake.ch"
#include 'topconn.ch'
#include "tbiconn.ch"

#include "cbcIncludes.ch"

//TODO Algumas regras aqui estão no fonte pedindl.prw. deixar os dois iguais

/*/{Protheus.doc} CbcIndRules
@author bolognesi
@since 12/04/2016
@version 1.0
@example
Local oIndl := CbcIndRules():newCbcIndRules()
@description Classe para tratar as regras de triangulação e industrialização
/*/
class CbcIndRules from SigaArea

	data cEstFatTL
	data cEstFatITU
	data cBilBranch
	data cCliente
	data cLojaCli
	data cPedido
	data cCondPag
	data cTipoCli
	data cCliContr
	data lProspect
	data lCliDivide
	data lFunc
	data lImportado
	data lPFisica
	data lClientVld
	data lOk
	data cMsgErr
	data lConstruMS
	data lConsFinMS
	data lConstruItu
	data lConsFinItu
	data lConstrut
	data lConFinal
	data cEstIndTL
	data cEstIntTL
	data cUFCli
	data cCGC
	data cEstDiv
	data lEstFixTl
	data lIsFornec

	data aIndRules
	data cMotivo
	data cZZLCIND
	data cZZFRIND
	data lEstFixItu
	data lEstFixPal
	data cEmpFil
	data aEmaiMoti
	data lContinua
	data lCfPf
	data lDbgIndl

	data lVldCli

	method newCbcIndRules() constructor
	method IsVldBranch()
	method BillingBranch()
	method isPedFunc()
	method clientRules()
	method isAuto()
	method AddRule()
	method loadRules()
	method configOper()
	method defOper()
	method splitOrder()

	method setEstDiv()

	method msgRules()
	method preparaEmail()
	method enviaEmail()

	method autoPvDiv()
	method isReserve()

endclass

/*/{Protheus.doc} newCbcIndRules
Metodo construtor
@author bolognesi
@since 12/04/2016
@version 1.0
@param cCliente, 	String, Codigo do Cliente
@param cLojaCli, 	String, Loja do Cliente
@param lProspect, Boolean, Define se a busca será por prospect(SUS) ou Cliente(SA1)
@param lMsg,		Boolean Define se devera exibir mensagem confirmação quando Cliente for Consumidor Final
@description Classe construtora
/*/
method newCbcIndRules(cCliente, cLojaCli, cPedido, lProspect, lMsg) class CbcIndRules
	local ldivOk		:= .F.
	Default cCliente 	:= M->C5_CLIENTE
	Default cLojaCli 	:= M->C5_LOJACLI
	Default cPedido		:= ""
	Default lProspect	:= .F.
	Default lMsg		:= .F.

	::lOk				:= .T.
	::cMsgErr			:= ""
	::aEmaiMoti			:= {}
	::lCfPf				:= .F.
	::lDbgIndl			:= GetNewPar('MV_DBGINDL', .T.)
	::lVldCli			:= .F.
	::cCondPag 			:= IIf( Type('M->C5_CONDPAG') == 'U' ,"", M->C5_CONDPAG)
	::aIndRules			:= {}

	_Super:newSigaArea()
	_Super:saveArea( {'SC5', 'SC6', 'SA1'} )

	::cEmpFil 			:= FWCodEmp()+FWCodFil()
	::cCliente 			:= Padr(cCliente, TamSx3("C5_CLIENTE")[1] )
	::cLojaCli 			:= Padr(cLojaCli, TamSx3("C5_LOJACLI")[1] )

	If !Empty(cPedido)
		::cPedido		:= Padr(cPedido, TamSx3("C5_NUM")[1] )
	EndIf

	::lProspect			:= lProspect
	::cBilBranch		:= ""

	if GetNewPar('ZZ_NWDIVCR', .T.)
		::cEstFatTL			:= "AM//PA//AC//RO//RR//AP//TO//MA//PI//CE//RN//PB//PE//AL//SE//BA//MS//GO//DF//"
		::cEstFatITU		:= "ES//RJ//MG//SP//MT//PR//SC//RS//"
		ldivOk 				:= ::setEstDiv({'ES','RJ','PR','SC','RS'}):lOk
	else
	 	::cEstFatTL			:= "AM//PA//AC//RO//RR//AP//TO//MA//PI//CE//RN//PB//PE//AL//SE//BA//MS//GO//DF//PR//SC//RS//"
		::cEstFatITU		:= "ES//RJ//MG//SP//MT//"
		ldivOk 				:= ::setEstDiv({'ES','RJ'}):lOk
	endif

	If ldivOk
		::cEstIndTL			:= "MA//PI//CE//RN//PB//PE//AL//SE//BA//"
		::cEstIntTL			:= "AM//PA//AC//RO//RR//AP//TO//MS//GO//DF//"
		If !::lProspect
			DbSelectarea("SA1")
			SA1->(DbSetOrder(1)) //A1_FILIAL, A1_COD, A1_LOJA
			If ::clientRules()  
				If SA1->(DbSeek(xFilial("SA1") + ::cCliente + ::cLojaCli , .F.) )
					::cUFCli    		:= SA1->(A1_EST)
					::cCGC				:= SA1->(A1_CGC)
					::lConstrut  		:= SA1->(A1_CONTRUT)	== "S"
					::lConFinal			:= SA1->(A1_TIPO)	 	== "F"
					::lImportado		:= SA1->(A1_ZZIMPOR)	== "1"
					::lPFisica 			:= SA1->(A1_PESSOA) 	== "F"
					if GetNewPar('ZZ_NWDIVCR', .T.)
						::lConstruMS		:= SA1->(A1_CONTRUT)	== "S" .And. ::cUFCli $ ::cEstFatTL
						::lConsFinMS		:= SA1->(A1_TIPO)	 	== "F" .And. ::cUFCli $ ::cEstFatTL			
						::lConstruItu		:= SA1->(A1_CONTRUT)	== "S" .And. !(::cUFCli $ ::cEstFatTL)
						::lConsFinItu		:= SA1->(A1_TIPO)	 	== "F" .And. !(::cUFCli $ ::cEstFatTL)
					else
						::lConstruMS		:= SA1->(A1_CONTRUT)	== "S" .And. ::cUFCli $ 'MS'
						::lConsFinMS		:= SA1->(A1_TIPO)	 	== "F" .And. ::cUFCli $ 'MS'			
						::lConstruItu		:= SA1->(A1_CONTRUT)	== "S" .And. ::cUFCli # 'MS'
						::lConsFinItu		:= SA1->(A1_TIPO)	 	== "F" .And. ::cUFCli # 'MS'
					endif
					::cTipoCli			:= SA1->(A1_TIPO)
					::cCliContr			:= SA1->(A1_CONTRIB)	== "1" //1=Sim( .T. ) / 2=Não( .F. )
					::lCliDivide		:= SA1->(A1_ZZDIVCL)	== 'S'
					// 1 = ITU; 2 = TRES LAGOAS; 3 = POUSO ALEGRE; 4 = SEGUE REGRA;
					::lEstFixItu		:= SA1->(A1_ZZUNFAT)	== '1'
					::lEstFixTl			:= SA1->(A1_ZZUNFAT)	== '2' 
					::lEstFixPal		:= SA1->(A1_ZZUNFAT)	== '4' 
					
					::lOk				:= .T.
					::cMsgErr			:= ""
					::isPedFunc(lMsg)
				Else
					::lOk				:= .F.
					::cMsgErr			:= "CLIENTE " + ::cCliente + " LOJA: " + ::cLojaCli + " NÃO LOCALIZADO"
				EndIf
			Else
				::lOk					:= .F.
				::cMsgErr				:= "CLIENTE " + ::cCliente + " LOJA: " + ::cLojaCli + " NÃO APLICA REGRA"
				::lVldCli				:= .T.
			EndIf
		EndIf
	Endif
	_Super:backArea()
return self

/*/{Protheus.doc} IsVldBranch
@author bolognesi
@since 12/04/2016
@version 1.0
@type method
@description Metodo responsavel por validar a filial corrente
com a filial de faturamento do cliente retornando um logico
utilizado nas validações de telas, a filial de faturamento do cliente
é obtida atraves do metodo BillingBranch()
/*/
method IsVldBranch() class CbcIndRules
	Local lRet := .F.
	//[LEO] - 11/10/2016 - NÂO APLICAR VALIDAÇÔES PARA REGRA DE DIVISÂO DE PEDIDOS
	lRet := ::autoPvDiv()
	If !lRet
		If ::lFunc
			lRet := .T.
		Else
			::BillingBranch()
			lRet := FWCodFil() == ::cBilBranch
		EndIf
	EndIf
return lRet

/*/{Protheus.doc} BillingBranch
@author bolognesi
@since 12/04/2016
@version 1.5
@type method
@description Metodo utilizado para retoranr a filial de faturamento
de um determinado cliente
13/04/16 - Tratamento para prospect (Prospect sempre pode ver todo
o estoque disponivel no parametro "ZZ_FILESPT")
/*/
method BillingBranch() class CbcIndRules
	Local cBranch 			:= "01"
	Local cUFCli    		:= ""
	Local cAllowBranches	:= ""
	Local aAllowBranches	:= {}
	Local nX				:= 0

	::cBilBranch	:= ""
	::cMotivo		:= ""

	_Super:saveArea( {'SC5', 'SC6'} )

	If ::lProspect

		cAllowBranches	:= GetNewPar("ZZ_FILESPT", "01")
		aAllowBranches 	:= StrTokArr(cAllowBranches, ",")

		If Len(aAllowBranches) > 1
			cBranch := ''
		Else
			cBranch := cAllowBranches
		EndIf
	Else
		//Aplicar as regras
		If Empty(::aIndRules)
			::loadRules()
		EndIF
		
		For nX := 1 To Len(::aIndRules)

			If ::aIndRules[nX,2]
				cBranch := ::aIndRules[nX,3]
				::cMotivo	:= ::aIndRules[nX,4]
				Exit
			EndIf

		Next nX
	EndIf

	_Super:backArea()
	::cBilBranch := cBranch

return cBranch

/*/{Protheus.doc} isPedFunc
@author bolognesi
@since 02/05/2016
@version 1.5
@type method
@description Retorna se um pedido é para funcionario
/*/
method isPedFunc(lMsg) class CbcIndRules
	Local 	cPessoa	:= ""
	Default lMsg	:= .T.

	::lFunc		:= .F.

	If  ::lPFisica

		DbSelectArea("SRA")
		DbSetOrder(5) //RA_FILIAL+RA_CIC

		If SRA->(DbSeek("01" + ::cCGC , .T.) )
			::lFunc	:= .T.

		ElseIf SRA->(DbSeek("02" + ::cCGC , .T.) )
			::lFunc	:= .T.
		Else
			if lMsg .And. ::lConFinal
				::lCfPf		:= .T.
				::lContinua	:= u_autoAlert("[Pergunta]-Cliente é consumidor final e Pessoa Fisica!, continuar inclusão?",.T.,'MsgBox','Titulo',,'YesNo', .T. )
			Else
				::lFunc	:= .F.
			EndIf
		EndIf

	EndIf
Return(::lFunc)

/*/{Protheus.doc} clientRules
@author bolognesi
@since 03/05/2016
@version 1.5
@type method
@description Valida se deve ou não aplica as regras de faturamento
para o cliente, utiliza a user function (U_vPedReg)
/*/
method clientRules() class CbcIndRules
	Local aPar	:= {}

	::lClientVld := .F.
	Aadd(aPar, "valCliFil")
	Aadd(aPar, ::cCliente)
	Aadd(aPar, ::cLojaCli)
	::lClientVld := U_vPedReg(aPar) // (.T.)= APLICAR ROTINA  (.F.) = NÃO APLICAR ROTINA

return ::lClientVld

/*/{Protheus.doc} isAuto
@author bolognesi
@since 03/05/2016
@version 1.5
@type method
@description retorna se a execução´atual é uma rotina automatica
job
/*/
method isAuto() class CbcIndRules
return  _SetAutoMode() .Or. IsBlind()

//NÂO MEXER ACIMA
/***************************************************************************/

/*/{Protheus.doc} configOper
@author bolognesi
@since 04/05/2016
@version 1.5
@type method
@description Carrega as variavies e dados necessarios para definir
qual operação um determinado item do pedido deve ser submetido
/*/
method configOper() class CbcIndRules
	Local lBndes 		:= (::cCondPag == BNDES)
	Local lEstTriang	
	/*
	*Posicionado no SA1 do CLIENTE
	*Para variaveis disponiveis verificar construtor da classe
	*/
	::aIndRules 		:= {}
	if ::lOk
		_Super:saveArea( {'SC5', 'SC6', 'SA1'} )
		
		if GetNewPar('ZZ_NWDIVCR', .T.)
			lEstTriang	:= .F.
		else
			lEstTriang	:= (::cUFCli $ ("PR//SC//RS//")) //Cliente dos estados do SUL, somente como triangulação (Itu fisico, TL Fiscal)
		endif

		//(1)ORDEM,(2)VALIDAÇÂO,(3)C6_LOCAL,(4)C6_SEMANA (5)DIV_FABRI,(6)DIV_VALOR(7)DESCRIÇÃO
		::AddRule( {01,(::lEstFixTl)								,'01' , 'TAUTOM'	, .T. ,	.F.	,'01-[INDUSTRIALIZAÇÃO]CLIENTE FIXO MV_ZZLCIND, SAIDA INTEGRAL TL, DIVIDIR PELA FABRICAÇÂO'})
		::AddRule( {02,(::lEstFixItu)								,'01' , ''			, .T. ,	.F.	,'02-CLIENTE FIXO MV_ZZFRIND, SAIDA INTEGRAL ITU'})
		::AddRule( {03,(::cUFCli $ ::cEstIndTL) .And. lEstTriang 	,'10' , ''			, .F. , .F.	,'03-[TRIANGULAÇÂO]-TOTAL ITU, NÃO DIVIDE PRODUÇÂO NEM VALOR, TUDO LOCAL 10'})
		::AddRule( {04,(::cUFCli $ ::cEstIndTL) .And. lBndes 		,'01' , 'TAUTOM'	, .F. , .F.	,'04-[INDUSTRIALIZAÇÃO/BNDES]-TOTAL ITU, NÃO DIVIDE PRODUÇÂO NEM VALOR'})//ANTIGO ARMAZEM 10
		::AddRule( {05,(::autoPvDiv())								,'01' , ''			, .F. , .F.	,'05-REGRA PARA DIVIDIR PEDIDO'})
		::AddRule( {06,(::cUFCli $ ::cEstIndTL	)					,'01' , 'TAUTOM'	, .T. ,	.T.	,'06-[INDUSTRIALIZAÇÃO]-FATURAR ITU/TL, DIVIDIR FABRICAÇÃO, REGRA DE VALOR'})//ANTIGO ARMAZEM 10
		::AddRule( {07,(::cUFCli $ ::cEstIntTL	)					,'01' , 'TAUTOM'	, .T. ,	.F.	,'07-[INDUSTRIALIZAÇÃO]-FATURA TL INTEGRAL, DIVIDIR FABRICAÇÃO'})
		::AddRule( {08,(.T.)										,'01' , ''			, .F. , .F.	,'08-DEFAULT'})

		_Super:backArea()
	EndIf
return

/*/{Protheus.doc} defOper
@author bolognesi
@since 04/05/2016
@version 1.5
@type method
@param cCodProd, String, Codigo do produto a ser analisado pela regra
@param nAcols, Number, recebe a linha do acols para alterarar C6_SEMANA, caso não receba devolve conteudo para C6_SEMANA
@param cDrcProd, String, recebe conteudo do campo  "M->C5_DRCPROD"
@return Devolve o numero do armazem, e caso necessario define C6_SEMANA, quando parametro nAcols recebido
@description Aplica as regras definidas para gerar a operação
adequada ao item do pedido analisado, Defini (Local 10 = Triangulação)
Semana TAUTOM = Industrialização, sempre devolendo o valor que deverá
ser atribuido ao armazem, outras definições como Devidir pedido pela
filial que fabrica o item e divisão com base nas regras de valores tambem
são definidas neste metodo
/*/
method defOper(cCodProd,nAcols, cDrcProd) class CbcIndRules
	Local cArmazem 		:= "01"
	Local nX			:= 0
	Local cGrpProd		:= ""
	Default nAcols		:= 0
	Default cDrcProd	:= 'S'

	::lOk				:= .T.
	::cMsgErr			:= ""
	::cMotivo			:= ""

	_Super:saveArea( {'SC5', 'SC6', 'SA1', 'SB1'} )

	cGrpProd	:= Posicione("SB1",1,xFilial("SB1")+cCodProd,"B1_GRUPO")
	//cCodProd	:= Left(cCodProd,5)


	If  ::cEmpFil == "0102" .And. !::lFunc

		If ( (cGrpProd $ 'PA01') .OR. (cGrpProd $ 'PI01') ) .AND. cDrcProd # 'N'

			If (Alltrim(GDFieldGet("C6_SEMANAL",nAcols)) == 'TAUTOM')
				GDFieldPut("C6_SEMANA", ''  ,nAcols)
			EndIf

			/* INICIO PARA APLICAÇÂO DE REGRA */
			//::aIndRules = (1)ORDEM,(2)VALIDAÇÂO,(3)C6_LOCAL,(4)C6_SEMANA,(5)DIV_FABRI,(6)DIV_VALOR,(7)DESCRIÇÃO
			For nX := 1 To Len(::aIndRules)
				//IDENTIFICAR QUAL REGRA ESTA .T.
				If ::aIndRules[nX,2]
					//DIVIDIR PEDIDO PELA FABRICAÇÂO
					If ::aIndRules[nX,5]
						//VERIFICA SE FABRICA
						If !u_Tem3Lag(cCodProd)
							//NÃO FABRICA, DEFINI SEMANA
							If !Empty(::aIndRules[nX,4])
								GDFieldPut("C6_SEMANA", ::aIndRules[nX,4]  ,nAcols)
							EndIf
							//ATRIBUI O ARMAZEM
							cArmazem 	:= ::aIndRules[nX,3]
						EndIf
						//NÂO DIVIDIR PELA FABRICAÇÂO
					Else
						//DEFINE SEMANA / ARMAZEM CONFORME REGRA
						If !Empty(::aIndRules[nX,4])
							GDFieldPut("C6_SEMANA", ::aIndRules[nX,4]  ,nAcols)
						EndIf
						cArmazem 	:= ::aIndRules[nX,3]
					EndIf
					//DESCRIÇÂO DA REGRA APLICADA
					::cMotivo 	:= ::aIndRules[nX,7]
					//variavel private vem do fonte MT410TOK, usada para identificar se teve divisão no pedido
					//para chamar função que aplica regra de valor somente quando teve divisão
					lTeveDiv := ::aIndRules[nX,6]
					Exit
				EndIf
			Next nX
		Else
			::lOk 		:= .F.
			::cMsgErr	:= "NÃO APLICOU REGRA DE DIVISÂO"
		Endif
	EndIf
	_Super:backArea()

	//Somente mandar email para outras regras, na de divisão já vai um email detalhado.
	If !Empty(::cMotivo)
		If ::cMotivo != '02-REGRA PARA DIVIDIR PEDIDO'
			If (nAcols > 0 ) .And. ::lDbgIndl
				::preparaEmail(nAcols)
			EndIf
		EndIf

	EndIf
return(cArmazem)

/*/{Protheus.doc} loadRules
@author bolognesi
@since 03/05/2016
@version 1.5
@type method
@description Carrega as regras de faturamento x Filial para o array de regras
sempre formato {N-ORDEM , C-EXPRESSAO_ADVPL, C-FILIAL }
/*/
method loadRules() class CbcIndRules
	::aIndRules := {}
	/*
	*Posicionado no SA1 do CLIENTE
	*Para variaveis disponiveis verificar construtor da classe
	*/
	if ::lOk
		_Super:saveArea( {'SC5', 'SC6', 'SA1'} )
		::AddRule( {01, ::lEstFixTl 			,3LAGOAS		,'CLIENTES FIXOS EM TRES LAGOAS' }  )
		::AddRule( {02, ::lEstFixItu 			,ITU			,'CLIENTES FIXOS EM TRES LAGOAS' }  )
		::AddRule( {03, ::lEstFixPal			,P_ALEGRE		,'CLIENTES FIXOS EM POUSO ALEGRE' }  )
		::AddRule( {04, ::lImportado 			,ITU			,'FATURAMENTO IMPORTADO POR ITU' }  )
		::AddRule( {05, ::cUFCli $ 'EX' 		,ITU			,'EXPORTAÇÂO SOMENTE POR ITU' }  )
		::AddRule( {06, ::lConstruItu 			,ITU			,'CONSTRUTORA EXETO MS' }  )
		::AddRule( {07, ::lConsFinItu 			,ITU			,'CONSUMIDOR FINAL EXETO MS' }  )
		::AddRule( {08, ::lConstruMS 			,3LAGOAS		,'CONSTRUTORA ESTADO MS' }  )
		::AddRule( {09, ::lConsFinMS 			,3LAGOAS		,'CONSUMIDOR FINAL ESTADO MS' }  )
		::AddRule( {10, ::cUFCli $ ::cEstFatTL 	,3LAGOAS		,'REGIÃO DE TRES LAGOAS' }  )
		::AddRule( {11, ::cUFCli $ ::cEstFatITU ,ITU			,'REGIÃO DE ITU' }  )
		::AddRule( {12,	.T.						, FWCodFil()	,'REGRA DEFAULT' }) //Este sempre ultimo
		_Super:backArea()
	endIf
return (self)
/*******************************************************************************/
//NÂO MEXER ABAIXO

/*/{Protheus.doc} splitOrder
@author bolognesi
@since 07/10/2016
@version 1.0
@type method
@description Regra que define se um pedido deverá ser divido
/*/
method splitOrder() class CbcIndRules
	local nX		:= 0
	Local lRet		:= .F.
	Local lRegAdm	:= .F.
	Local lNrRes	:= .F.

	//Somente dividir pedidos cuja data de emissão for maior que a data de entrega do sistema
	If DToS(M->(C5_EMISSAO)) >= ENTREGA_SISTEMA .And. !::lConFinal .And. !::lConstrut .And. ::lCliDivide .And. (M->(C5_ZTPVEND) <> 'V')
		//Não dividir pedido quando !Empty(M->C5_ZZAPR), pois tem regra definida 
		If ValType(M->C5_ZZAPR) != 'U'
			If !Empty(M->C5_ZZAPR)
				lRegAdm := .T.
			EndIf
		EndIf
	
		//Não dividir pedido de Reserva do Portal Se algum item tiver (C6_ZZNRRES) preenchido
		If !lRegAdm
			lNrRes := ::isReserve(aHeader,aCols)
		EndIf
	
		//Somente verificar se divide o pedido quando Não tiver Regra do Administrativo, e não for
		//um orçamento de reserva.
		If !lRegAdm .And. !lNrRes
			If FWCodFil() == DIVIDIR  
				//Aqui definir qual a regra que inicia o processo de divisão do pedido
				If  (::cUFCli $ ::cEstDiv) .Or. ::lImportado  
					lRet := .T.
				EndIf
			EndIf
		EndIf
	EndIf
return (lRet)

/*/{Protheus.doc} setEstDiv
@author bolognesi
@since 07/10/2016
@version 1.0
@param aDivEst, array, Estados que devem divir
@type method
@description Define os estados que por regra devem aplicar logica de dividir o pedido
estes estados devem estar contidos nas regiões da filial entrada para pedidos que divide
/*/
method setEstDiv(aDivEst) class cbcIndRules
	Local cCompar	:= ""
	Local cReg		:= ""
	Local cEstDiv	:= ""
	Default aDivEst	:= {}

	If Empty(aDivEst)
		::lOk			:= .F.
		::cMsgErr		:= "[ERRO] - Parametro obrigatorio cbcIndRules:setEstDiv(aDivEst)" + cReg 
	Else
		If DIVIDIR == ITU
			cCompar := ::cEstFatITU
			cReg := 'ITU' 
		ElseIf DIVIDIR == 3LAGOAS
			cCompar := ::cEstFatTL
			cReg := '3LAGOAS'
		EndIf

		For nX := 1 To Len(aDivEst)
			If !(aDivEst[nX] $ cCompar)
				::lOk			:= .F.
				::cMsgErr		:= "[ERRO] - Os estados para dividir o pedido devem fazer parte da Região " + cReg 
				exit
			Else
				cEstDiv += aDivEst[nX] + '//' 
			EndIf
		Next nX	
	EndIf

	If ::lOk
		::cEstDiv := cEstDiv
	Else
		::cEstDiv := cEstDiv
	EndIf
return (self)

/*/{Protheus.doc} AddRule
@author bolognesi
@since 03/05/2016
@version 1.5
@type method
@description adiciona uma regra ao array de regras
/*/
method AddRule(aRule) class CbcIndRules
	::lOk			:= .T.
	::cMsgErr		:= ""

	If ValType(aRule) == 'A'
		AAdd(::aIndRules , aRule)
	Else
		lOk 	:= .F.
		cMsgErr	:= "Array Regra Invalido{ORDER REGRA, EXPRESSAO(.T./.F.), FILIAL QUANDO .T., DESCRIÇÂO}"
	EndIf

return nil

/*/{Protheus.doc} tstRules
@author bolognesi
@since 02/05/2016
@version 1.5
@type function
@description Utilizada para testar a classe
/*/
method msgRules() class CbcIndRules
	Local cMsg		:= ""

	if ::lDbgIndl
		cMsg	+="ESTADO " + ::cUFCli + linha
		cMsg 	+="Construtora?: " 					+  IIF(::lConstrut,   'S', 'N') + linha
		cMsg 	+="Consumidor Final?: " 			+  IIF(::lConFinal,   'S', 'N') + linha
		cMsg	+="Faturamento Importado?: "		+  IIF(::lImportado,  'S', 'N') + linha
		cMsg 	+="Construtora fatura 3L?: " 		+  IIF(::lConstruMS,  'S', 'N') + linha
		cMsg 	+="Consumidor Final fatura 3L?: " 	+  IIF(::lConsFinMS,  'S', 'N') + linha
		cMsg 	+="Construtora fatura ITU?: " 		+  IIF(::lConstruItu, 'S', 'N') + linha
		cMsg 	+="Consumidor Final fatura ITU?: " 	+  IIF(::lConsFinItu, 'S', 'N') + linha
		cMsg 	+="Pessoa Fisica?: " 				+  IIF(::lPFisica,    'S', 'N') + linha
		cMsg 	+= "CGC: " + ::cCGC + linha
		cMsg 	+= linha
		cMsg 	+= linha
		cMSg 	+= "REGIÃO" + linha
		cMsg 	+= "TL = " 	+ StrTran(::cEstFatTL, '//', '-')  + linha
		cMsg	+= "ITU = " + StrTran(::cEstFatITU, '//', '-') + linha
		cMsg 	+= linha
		cMsg 	+= linha
		cMsg 	+= "RESULTADO FINAL " + linha
		cMsg 	+= "FILIAL DE FATURAMENTO: " +  ::cBilBranch + linha
		cMsg 	+= linha
		cMsg += "VALIDAÇÂO " + linha
		If ::IsVldBranch()
			cMsg += "FILIAL OK" + linha
		Else
			cMsg += "UTILIZAR OUTRA FILIAL" + linha
		Endif
		cMsg += linha
	Endif
	cMsg += "MOTIVO " + linha
	cMsg += ::cMotivo

	if ::isAuto() 
		//TODO tratar a mensagem para rotinas automaticas
	Else
		MessageBox(cMsg, 'AVISO', 48)
	EndIf
return

/*/{Protheus.doc} preparaEmail
@author bolognesi
@since 09/05/2016
@version 1.5
@type method
@param nAcols, Numeric, Recebe o numero do Acols em questão. deve-se verificar se esta deletado antes de enviar
@description Prepara as linhas para enviar o e-mail, normalmente em loop dos itens do pedido
/*/
method preparaEmail(nAcols) class CbcIndRules
	Local dDt			:= Alltrim(cValToChar(Date()))
	Local dHora		:= Alltrim(cValToChar(Time()))
	Local cFab3L		:= ""
	Local cCodProd	:= Alltrim(GDFieldGet("C6_PRODUTO",nAcols))
	Local cItem		:= Alltrim(GDFieldGet("C6_ITEM",nAcols))

	If u_Tem3Lag(cCodProd)
		cFab3L := 'S'
	Else
		cFab3L := 'N'
	EndIf

	AAdd(::aEmaiMoti , {Alltrim(::cPedido), cItem, cCodProd,;
	::cMotivo, cFab3L, Alltrim( UsrRetName(__CUSERID)), dDt, dHora})
return

/*/{Protheus.doc} enviaEmail
@author bolognesi
@since 09/05/2016
@version 1.5
@type method
@description Metodo que realza o envio do e-mail, adicionando as informações do cliente
somente envia se o parametro MV_DBGINDL estiver como .T.
/*/
method enviaEmail() class CbcIndRules

	If !Empty(::aEmaiMoti) .And. ::lDbgIndl

		AAdd(::aEmaiMoti, {"","","","","", "", "", "" })
		AAdd(::aEmaiMoti, {"","","","","", "","","" })
		AAdd(::aEmaiMoti, {"ESTADO","CONSTRU","CONS.FINAL","P.FISICA","", "" })
		AAdd(::aEmaiMoti, {::cUFCli,IIF(::lConstrut, 'S', 'N'),IIF(::lConFinal, 'S', 'N'),;
		IIF(::lPFisica,  'S', 'N') ,"", ""})

		u_envmail({EMAIL_FIXO}, ASSUNTO_FIXO_INDL + Alltrim(SA1->(A1_NOME)) + "] COD: [" + ::cCliente  + '] LOJA: [' + ::cLojaCli +']',;
		{"PEDIDO", "ITEM","PRODUTO","MOTIVO","FAB.TL","USR", "DATA", "HORA"}, ::aEmaiMoti)
	Endif

return (self)

/*/{Protheus.doc} autoPvDiv
@author bolognesi
@since 14/10/2016
@version 1.0
@type method
@param cCmp, Character, Opcional recebe um campos para procurar no array aAutoCab
@description Por default identificar se uma inclusão de pedido
tem origem um MATA410 (quando vem do mata410 existe variavel aAutoCab), 
atraves desta variavel é possivel verificar se o campo C5_ZZPVDIC esta preenchido
o que caracteriza que a Inclusão é proveniente de uma divisão, porem podem receber
como parametro o nome de outro campo para procurar.
/*/
method autoPvDiv(cCmp) class CbcIndRules
	Local lRet		:= .F.
	Default cCmp	:= 'C5_ZZPVDIV'
	//Verificar para rotina automatica
	If ValType(aAutoCab) == "A"
		If !Empty(aAutoCab)
			For nX := 1 To Len(aAutoCab)
				If aAutoCab[nX,1] == cCmp
					If !Empty(aAutoCab[nX,2])
						lRet := .T.
						exit 
					EndIf
				EndIf
			Next nX
			//Verificar para alteração (deixar quando campo C5_ZZPVDIV preenchido)
		ElseIf Altera
			If !Empty(M->(C5_ZZPVDIV))
				lRet := .T.
			EndIf
		EndIf
	EndIf
return (lRet)

/*/{Protheus.doc} isReserve
@author bolognesi
@since 17/10/2016
@version 1.0
@type method
@description Metodo utilizado para verificar se o pedido é um pedido
proveniente de uma reserva do portal, ou seja tem o campo C6_ZZNRRES preenchido
/*/
method isReserve(aHdr,aCls) class CbcIndRules
	Local lRet		:= .F.
	Local nI		:= 0
	Default aHdr	:= {}
	Default aCls 	:= {}
	If !Empty(aHdr) .And. !Empty(aCls)
		For nI:= 1 to Len(aCls)
			If !GDDeleted(nI, aHdr, aCls)
				If !Empty(GDFieldGet("C6_ZZNRRES"	,nI	, .F. , aHdr, aCls) )
					lRet := .T.
					exit
				EndIf
			EndIf
		Next nI
	EndIF
return (lRet)