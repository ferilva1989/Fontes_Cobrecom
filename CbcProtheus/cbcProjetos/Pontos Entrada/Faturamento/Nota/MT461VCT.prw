#include 'protheus.ch'
#include 'parmtype.ch'

#define VALOR_TITULO  	1
#define VALOR_IRF  	  	2
#define VALOR_INSS  	3
#define VALOR_ISS  		4
#define VALOR_PIS  		5
#define VALOR_CSLL  	6
#define VALOR_COFINS  	7
#define VALOR_IPI  	  	8
#define VALOR_SOLIDARIO 9
#define LINHA	'< br />' 

static cEmailAviso	:= GetNewPar('ZZ_EMMT461', 'leonardo@cobrecom.com.br')
static lAtivo		:= GetNewPar('ZZ_DIVPASU', .T.)

/*/{Protheus.doc} MT461VCT
@author bolognesi
@since 20/11/2017
@version 1.0
@type function
@description Esta função avalia a condição de pagamento 
informada pelo usuário e calcula as datas de vencimento 
e os valores gerados a partir de um desdobramento.
/*/
user function MT461VCT()
	local aArea 	:= getArea()
	local aVencto 	:= PARAMIXB[1]
	local aTitulo 	:= PARAMIXB[2]
	local bErro		:= nil
	local lErro		:= .F.

	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, @lErro)})
	BEGIN SEQUENCE
	if lAtivo
		if SF2->(F2_SERIE) == 'U  ' 
			if SF4->(F4_DUPLIC) == 'S'
				aVencto := DivCondPag(aVencto,aTitulo)
			endif
		endif
	endif
	END SEQUENCE
	ErrorBlock(bErro)
	
	if lErro
		aVencto 	:= PARAMIXB[1]
	endif

	RestArea(aArea)
return(aVencto)


/*/{Protheus.doc} DivCondPag
@author bolognesi
@since 21/11/2017
@version undefined
@param aVencto, array, Parametros recebidos pelo MT461VCT(), com vencimentos e valores
@param aTitulo, array, Parametros recebidos pelo MT461VCT(), com informações sobre o titulo
@type function
@description Quando o cliente tem condição de pagamento especifica para serie U, realiza um novo
calculo para obter as novas informações considerando a condição de pagamento serie U, para que
a geração do titulo seja coerente com a condição de pagamento. 
/*/
static function DivCondPag(aVencto,aTitulo)
	local oSch 			:= Nil	
	local cNumPed		:= SC5->(C5_NUM)
	local dEmissF2		:= SF2->F2_EMISSAO
	local cNrNota		:= SF2->(F2_DOC) + SF2->(F2_SERIE) 
	local cFil			:= FwFilial()
	local nValor		:= aTitulo[VALOR_TITULO]
	local nVlrIPI		:= aTitulo[VALOR_IPI]
	local nVlrSoli		:= aTitulo[VALOR_SOLIDARIO]
	local cOrigCondPag	:= SC5->(C5_CONDPAG)
	local cCondPagU		:= getCond(SA1->(A1_COD),SA1->(A1_LOJA), cOrigCondPag)

	if ( Alltrim(cCondPagU) !=  Alltrim(SC5->(C5_CONDPAG)) )
		aVencto := Condicao(nValor, cCondPagU, nVlrIPI, dEmissF2, nVlrSoli)
		sendEmail( cFil, cNumPed, aVencto, cNrNota, cCondPagU, cOrigCondPag )
	endif
	
return(aVencto)


/*/{Protheus.doc} getCond
@author bolognesi
@since 21/11/2017
@version 1.0
@param cCliCod, characters, Codigo Cliente
@param cCliLoja, characters, Loja do Cliente
@param cCondPagOrig, characters, Condição de pagamento original (SC5)
@type function
@description Obtem com base no cliente qual a condição de
pagamento deve ser utilizada para serie U
/*/
static function getCond(cCliCod, cCliLoja, cCondPagOrig)
	local cCond 	:= cCondPagOrig
	local oCliente	:= nil 
	
	oCliente := cbcModClient():newcbcModClient(cCliCod, cCliLoja)
	
	if  empty(cCond := oCliente:getField('A1_CONDPSU') )
		cCond := cCondPagOrig
	endif
	
	FreeObj(oCliente)

return(cCond)


/*/{Protheus.doc} sendEmail
@author bolognesi
@since 21/11/2017
@version 1.0
@param cFil, characters, Filial
@param cPedido, characters, Numero do pedido
@param aVcto, array, Array vencimentos e valores gerados pela função Condicao()
@param aTituloU, array, Titulo em questão da serie U com origem nos parametros recebidos pelo
ponto de entrada MT461VCT()
@type function
@description Realiza o agendamento para envio do email iformativo sobre a situação
da divisão de Series(1 e U) e as respectivas condições de pagamento atribuida a cada um  
/*/
static function sendEmail(cFil, cPedido, aVcto, cNrNota, cCondPagU, cCondPed)
	local oSch 	:= cbcSchCtrl():newcbcSchCtrl()
	oSch:setIDEnvio( 'MT461VCT' )
	oSch:addEmailTo( cEmailAviso )
	oSch:setAssunto('[COND.PAGTO] - Filial ' + cFil + ' Pedido Nro.' + cPedido + ' Nota Nro. ' + cNrNota)
	oSch:setBody( bodyEmail(cFil, cPedido, aVcto, cCondPagU, cCondPed) )
	oSch:schedule()
	FreeObj(oSch)
return (nil)


/*/{Protheus.doc} bodyEmail
@author bolognesi
@since 21/11/2017
@version 1.0
@param cFil, characters, Filial
@param cPedido, characters, Pedido em questão
@param aVcto, array, Vencimentos e valores da nota atual
@param aTituloU, array, Titulo em questão da serie U com origem nos parametros recebidos pelo
ponto de entrada MT461VCT()
@type function
@description Com base nos dados de pedido obtem as informações dos titulos gerados
tanto da nota serie 1 quanto da nota serie U, e com estes dados cria a string que será
o corpo do email enviado.
/*/
static function bodyEmail(cFil, cPedido, aVcto, cCondPagU, cCondPed)
	local cTxtBody	:= ''
	local nX		:= 0
	local oSql := LibSqlObj():newLibSqlObj()
	
	local cDescCond1 	:= oSql:getFieldValue("SE4", 'E4_DESCRI', "%SE4.XFILIAL% AND E4_CODIGO ='" + cCondPed + "' " )
	local cDescCondU	:= oSql:getFieldValue("SE4", 'E4_DESCRI', "%SE4.XFILIAL% AND E4_CODIGO ='" + cCondPagU + "' " )
		
	cTxtBody += 'Condição de pagamento Pedido:  ( ' 	+  Alltrim(cDescCond1) + ' ) '  +  LINHA
	cTxtBody += 'Condição de pagamento serie U: ( ' 	+  Alltrim(cDescCondU) + ' ) '  +  LINHA
	
	cTxtBody += ' Parcelas: ' + LINHA
	
	for nX := 1 to len(aVcto)
		cTxtBody += 'Vencimento: ' + DtoC(aVcto[nX,1]) + ' Valor: ' + cValToChar(aVcto[nX,2]) + LINHA
	next nX

	oSql:Close()
	FreeObj(oSql)

return(cTxtBody)


/*/{Protheus.doc} HandleEr
@author bolognesi
@since 22/11/2017
@version 1.0
@param oErr, object, Objeto contendo erro
@type function
@description Tratamento de erro
/*/
static function HandleEr(oErr, lErro)
	lErro := .T.
	ConsoleLog('[' + oErr:Description + ']' + oErr:ERRORSTACK)
	u_autoAlert('MT461VCT ' + oErr:Description )
	BREAK
return


/*/{Protheus.doc} ConsoleLog
@author bolognesi
@since 22/11/2017
@version 1.0
@param cMsg, characters, Mensagem de erro
@type function
@description Exibir mensagem padronizada no console.
/*/
static function ConsoleLog(cMsg)
	ConOut("[MT461VCT - "+DtoC(Date())+" - "+Time()+" ] "+cMsg)
return