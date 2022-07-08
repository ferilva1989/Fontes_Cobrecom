#include 'protheus.ch'


/*/{Protheus.doc} cbcMstLayout
//TODO declaração da classe que monta o objeto leiaute definido.
@author bolognesi
@since 07/01/2019
@version 1.0
@type class
/*/
class cbcMstLayout 
	data nRec
	data cTabela
	data cLayout
	data aLinha
	method newcbcMstLayout() constructor 
	method editLine()
endclass

/*/{Protheus.doc} newcbcMstLayout
//TODO etodo contrutor da classe.
@author bolognesi
@since 07/01/2019
@version 1.0
@param nRec, numeric, descricao
@param cTabela, characters, descricao
@param cLayout, characters, descricao
@type function
/*/
method newcbcMstLayout(nRec, cTabela, cLayout) class cbcMstLayout
	default nRec 	:= 0
	default cTabela	:= 'INI'
	::aLinha	:= Array(GetNewPar('ZZ_LINETQ', 6))
	::nRec 		:= nRec
	::cTabela	:= cTabela
	::cLayout	:= cLayout
return(self)


/*/{Protheus.doc} editLine
//TODO Metodo que permite a edição da linha parametrizada.
@author bolognesi
@since 07/01/2019
@version 1.0
@param nLinha, numeric, descricao
@param oMdlLbl, object, descricao
@type function
/*/
method editLine(nLinha, oMdlLbl) class cbcMstLayout
	::aLinha[nLinha] := oMdlLbl
return(self)