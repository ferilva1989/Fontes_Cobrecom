#include 'protheus.ch'

/*/{Protheus.doc} cbcControllerERS
Classe controller dos models CBCERS
@type class
@author bolognesi
@since 15/01/2018
@version 1.0
@description Classe responsavel por criar
um registro, utilizando os models (cbcRegERS, cbcFinanceiroERS, cbcConsumoERS)
/*/
class cbcControllerERS

	data oRegister

	method newcbcControllerERS() constructor
	method createFromArr()

endclass


/*/{Protheus.doc} newcbcControllerERS
Construtor
@type method
@author bolognesi
@since 15/01/2018
@version 1.0
/*/
method newcbcControllerERS() class cbcControllerERS
return ( self )


/*/{Protheus.doc} createFromArr
Cria uma estancia do modelo com base em um array
@type method
@author bolognesi
@since 15/01/2018
@version 1.0
@description Utilizando o array da função CBCSuc()
do fonte CBCSucPed.prw, cria um objeto da classe modelo
cbcRegERS
/*/
method createFromArr(aDadFim, lJson) class cbcControllerERS

	local oRegistro 		:= nil
	local cStrJson		:= ''
	local oRestClient 	:= nil
	local aHeadStr		:= {}
	local xRet			:= nil
	default lJson			:= .F.
	default aDadFim		:= {}

	if empty(aDadFim)
		// TODO tratar erro
	else
		if len(aDadFim) <> 3
			// TODO tratar erro
		else
			oRegistro 	:= cbcRegERS():newcbcRegERS()
			consumo(oRegistro,limpaArr(@aDadFim[1], 4) )
			financeiro(oRegistro,limpaArr(@aDadFim[2], 4))
			registro(oRegistro,limpaArr(@aDadFim[3], 4))
			if  lJson
				xRet := oRegistro:toJson( "" ,.F., .T.)
			else
				xRet := oRegistro
			endif
			::oRegister := oRegistro
		endif
	endif
return ( xRet )


/*/{Protheus.doc} Consumo
Cria um objeto da classe modelo cbcConsumoERS
@type function
@author bolognesi
@since 15/01/2018
@version 1.0
@description Cria um objeto da classe cbcConsumoERS
com base no array do metodo createFromArr
/*/
static function Consumo( oRegistro, aDados )
	local oConsumo		:= nil
	local nX			:= 0

	for nX := 1 to len( aDados )
		oConsumo	:= cbcConsumoERS():newcbcConsumoERS()
		oConsumo:setItem(aDados[nX,5])
		oConsumo:setQuantidade(aDados[nX,6])
		oConsumo:setCodigoOrigem(Alltrim(aDados[nX,7]))
		oConsumo:setDescOrigem(Alltrim(aDados[nX,8]))
		oConsumo:setAcondicionamento(Alltrim(aDados[nX,9]))
		oConsumo:setQtdConsumo(aDados[nX,10])
		oConsumo:setValorUnitario(aDados[nX,11])
		oConsumo:setValorTotal(aDados[nX,12])
		oConsumo:setUMOrigem(Alltrim(aDados[nX,13]))
		oConsumo:setCodigoDestino(Alltrim(aDados[nX,14]))
		oConsumo:setDescDestino(aDados[nX,15])
		oConsumo:setQtdSucata(aDados[nX,16])
		oConsumo:setUMDestino(Alltrim(aDados[nX,17]))
		oConsumo:setQtdKGPvc(aDados[nX,18])
		oConsumo:setCondPagamento(Alltrim(aDados[nX,19]))
		oConsumo:setDescCondPagamento(Alltrim(aDados[nX,20]))
		oRegistro:addConsumo(oConsumo)
	next nX
return ( nil )


/*/{Protheus.doc} Financeiro
Cria um objeto da classe modelo cbcFinanceiroERS
@type function
@author bolognesi
@since 15/01/2018
@version 1.0
@description Cria um objeto da classe cbcFinanceiroERS
com base no array do metodo createFromArr
/*/
static function Financeiro( oRegistro, aDados )
	local oFinanceiro	:= nil
	local nX			:= 0
	local nPos			:= 0
	local cParcela		:= 'A'

	ASort(aDados,,,{|x,y| x[6] < y[6]})

	for nX := 1 to len(aDados)
		oFinanceiro	:= cbcFinanceiroERS():newcbcFinanceiroERS()
		oFinanceiro:setParcela(cParcela)
		oFinanceiro:setValor( aDados[nX,5])
		oFinanceiro:setVencimento( aDados[nX,6] )
		oFinanceiro:setDatabaixa()
		oRegistro:addParcela(oFinanceiro)
		cParcela := soma1(cParcela)
	next nX
return ( nil )


/*/{Protheus.doc} Registro
Atualiza as propriedades da classe cbcRegERS
@type function
@author bolognesi
@since 15/01/2018
@version 1.0
@description Define as propriedades do objeto cbcRegERS,
Definindo o saldo, valor total, chave unica.
/*/
static function Registro( oRegistro, aDados )
	local nX 		:= 0
	local nTotal 	:= 0
	
	for nX := 1 to Len(aDados)
		if nX == 1
			oRegistro:setChaveUnq(Alltrim(aDados[nX,1]) + Alltrim(aDados[nX,4]))
			oRegistro:setCodFil(Alltrim(aDados[nX,1]))
			oRegistro:setDtEmissao( CtoD(StrTran(StrTran(aDados[nX,2],'[',''), ']','')))
			oRegistro:setNomeCliente( Alltrim(aDados[nX,3]) )
			oRegistro:setNumero(Alltrim(aDados[nX,4]))
			oRegistro:setRepresentante(Alltrim(aDados[nX,12]))
		endif
		nTotal += aDados[nX,11]
	next nX

	oRegistro:setSaldo(nTotal)
	oRegistro:setValorTotal(nTotal)
	oRegistro:setChaveUnq()
return ( nil )


/*/{Protheus.doc} limpaArr
@type function
@author bolognesi
@since 15/01/2018
@version 1.0
@description Verifica para um array se a posição (nReg) está vazia, caso esteja elimina a posição
no array
/*/
static function limpaArr(aDados, nRef)
	private nVlrRef := nRef

	while ( (nPos := AScan(aDados,{|a| empty(a[nVlrRef]) })) != 0 )
		ADel(aDados, nPos)
		ASize(aDados, (Len(aDados) - 1)  )
	enddo

return(aDados)
