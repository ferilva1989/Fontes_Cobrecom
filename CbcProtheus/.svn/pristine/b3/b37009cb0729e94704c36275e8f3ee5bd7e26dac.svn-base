#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AutomacaoColetas.ch"
#INCLUDE "CBCREST.ch"
#define CODCLI				1
#define LOJACLI				2
#define CLIENTELOJA 		1
#define	PRODUTO 			2
#define	ACONDICIONAMENTO 	3
#define	TAMANHOLANCE 		4
#define	REPRESENTANTE 		5
#define	COND_PAGAMENTO 		6
#define C5TABELA			7
#define QTDVEN				8
#define TPFRETE				9
#define TPVENDA				10

WSRESTFUL BICALCDESC DESCRIPTION "Cobrecom - BI - Integração - Disponbilizar para qlikview funções internas siga"
WSDATA count		AS INTEGER
WSDATA startIndex	AS INTEGER

WSMETHOD GET DESCRIPTION "Recebe um parametro e devolve o seu valor" WSSYNTAX "/BICALCDESC/{MV_PARAM}"

END WSRESTFUL

WSMETHOD GET WSSERVICE BICALCDESC
	local lGet			:= .T.
	local cHeader		:= ""
	local cFil			:= ""
	local oRes			:= cbcResponse():newcbcResponse()
	local oFil			:= cbcFiliais():newcbcFiliais()
	local aUsr			:= {}
	local cNomeParam	:= ""
	local cVlrParam		:= ""
	local aReqParm 		:= {}
	local cTpParam		:= ""
	local lSucesso		:= .F.
	local cA1CODCLI		:= ''
	local cA1LOJACLI	:= '' 
	local cC6PRODUTO	:= ''
	local cC6ACONDIC	:= ''
	local cC6METRAGE	:= ''
	local cC5VEND1		:= ''
	local nC6QTDVEN		:= 0
	local cC5CONDPAG	:= ''
	local c5TPFRETE		:= ''
	local cTPVENDA		:= ''
	local oCbcProdVal	:= nil
	local nPrcMin		:= 0
	local aCli			:= {}

	//Tipo do conteudo para retorno
	::SetContentType("application/json")

	//Obter conteudo da requisição
	cHeader := ::GetHeader('Authorization')
	cFil	:= ::GetHeader('Filial')

	//Iniciar o processo
	If Len(::aURLParms) == 0
		SetRestFault(406,E406)
		lGet := .F.
	Else
		//Validar os dados do header
		If Empty(cHeader) .Or. Empty(cFil)
			SetRestFault(400,E400)
			lGet := .F.
		Else
			//Validar a acesso do usuario
			if cHeader != 'IFCqlikView'
				SetRestFault(405,'Token Inválido')
				lGet := .F.
			else
				//Preparar a Filial
				if !oFil:setFilial(cFil)
					SetRestFault(403,E403)
					lGet := .F.
				else
					cNomeParam 		:=  ::aURLParms[PARAM1]
					aReqParm		:= StrToKArr(cNomeParam, ";")

					if len(aReqParm) != 10
						cVlrParam := 'ERR'
					else

						aCli 		:= StrToKArr(aReqParm[CLIENTELOJA], '-')
						cA1CODCLI 	:= defTam(aCli[CODCLI]					, 'A1_COD')
						cA1LOJACLI	:= defTam(aCli[LOJACLI]					, 'A1_LOJA')
						cC6PRODUTO 	:= defTam(aReqParm[PRODUTO]				, 'C6_PRODUTO')
						cC6ACONDIC	:= defTam(aReqParm[ACONDICIONAMENTO]	, 'C6_ACONDIC')
						cC6METRAGE	:= defTam(aReqParm[TAMANHOLANCE]		, 'C6_METRAGE')
						cC5VEND1	:= defTam(aReqParm[REPRESENTANTE]		, 'C5_VEND1')
						cC5CONDPAG	:= defTam(aReqParm[COND_PAGAMENTO]		, 'E4_CODIGO')
						cC5TABELA	:= defTam(aReqParm[C5TABELA]			, 'C5_CONDPAG')
						nC6QTDVEN	:= val(aReqParm[QTDVEN])
						c5TPFRETE	:= defTam(left(aReqParm[TPFRETE],1 )	, 'C5_TPFRETE')
						cTPVENDA	:= defTam(aReqParm[TPVENDA]				, 'C5_ZTPVEND')
   
						//conout( 'u_TabBruto(' + cC5TABELA +"," + cC6PRODUTO + "," + (cC6ACONDIC + StrZero( val(cC6METRAGE),5)) + ")"  )
						nPrecoUnitario := u_TabBruto(cC5TABELA, cC6PRODUTO, (cC6ACONDIC + StrZero( val(cC6METRAGE),5)))
						//conout('nPrecoUnitario ' + cValToChar(nPrecoUnitario) ) 

						//conout('newCbcProductValues(' + cA1CODCLI + ','+ cA1LOJACLI + ',' + cC6PRODUTO + ',' + (cC6ACONDIC + StrZero( val(cC6METRAGE),5)) + ',' + cValToChar(nC6QTDVEN) + ',' + cValToChar(nPrecoUnitario) + ')' )
						oCbcProdVal	 := CbcProductValues():newcbcProductValues(cA1CODCLI, cA1LOJACLI, cC6PRODUTO, (cC6ACONDIC + StrZero( val(cC6METRAGE),5)), nC6QTDVEN, nPrecoUnitario)
						
						//conout('Condição Pagamento ' 	+ cC5CONDPAG )
						//conout('Tipo Frete ' 			+ c5TPFRETE )
						//conout('Vendedor ' 			+ cC5VEND1 )
						oCbcProdVal:setPayTerm(cC5CONDPAG)
						oCbcProdVal:setTpFreight(c5TPFRETE)
						oCbcProdVal:setSalesMan(cC5VEND1)
						oCbcProdVal:setRetail(cTPVENDA)

						oCbcProdVal:initCalc()
						if !oCbcProdVal:lOk
							nPrcMin := if (Empty(nPrecoUnitario),0, nPrecoUnitario) 
						else
							nPrcMin := if(Empty(oCbcProdVal:nMinPrice), 0, oCbcProdVal:nMinPrice)
						endif

						cVlrParam	:= cValToChar(nPrcMin)
						//conout('PreçoMinimo ' + cVlrParam)
						FreeObj(oCbcProdVal)
					endif

					if !Empty(cVlrParam)
						lSucesso 	:= .T.
						cTpParam	:= ValType(cVlrParam)	
					endif

					oRes:sucesso 			:= lSucesso
					oRes:msg				:= cNomeParam
					oRes:mvParam:Conteudo	:= cVlrParam		
					oRes:mvParam:Tipo		:= cTpParam

					::SetResponse(oRes:toJson())
				endIf
			endif
		endIf
	endIf

	FreeObj(oRes)
	FreeObj(oFil)

Return lGet

static function defTam(xVlr, cTab)
	local cRet	:= ''
	cRet := Padr(xVlr, TamSx3(cTab)[1])
return(cRet)