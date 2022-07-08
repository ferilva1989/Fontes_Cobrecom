#include 'protheus.ch'
#Define GRUPO_FATURAMENTO	'000015'
#Define GRUPO_GER_ADMIN		'000007'
#Define GRUPO_FISCAL		'000016'

/*/{Protheus.doc} cbcAclFil
@author bolognesi
@since 19/06/2017
@version 1.0
@type class
@description Classe que centraliza as regras para definição dos filtros personalizados
tela e relatorios
/*/
class cbcAclFil from cbcAcl
	data cWhoToFil
	data cFilter
	method newcbcAclFil() constructor 
	method getFilter()
	method setFilter()
	method WhoToFil()
	method setWhoToFil()
endclass

/*/{Protheus.doc} newcbcAclFil
@author bolognesi
@since 19/06/2017
@version 1.0
@param cWho, characters, Qual nome da rotina para obter obter o filtro (EX: MATR600)
@type method
@description Inicializados da classe
/*/
method newcbcAclFil(cWho) class cbcAclFil
	default cWho := ''	
	::newcbcAcl()
	//::usrIsGrp(aSchGrp)
	::setWhoToFil(cWho)
return(self)

/*/{Protheus.doc} WhoToFil
@author bolognesi
@since 19/06/2017
@version 1.0
@type method
@description Obtem o nome da rotina que deve ser filtrada
/*/
method WhoToFil() class cbcAclFil
return(::cWhoToFil)

/*/{Protheus.doc} setWhoToFil
@author bolognesi
@since 19/06/2017
@version undefined
@param cWho, characters, descricao
@type method
@description Define qual o nome da rotina que se deseja obter o filtro
/*/
method setWhoToFil(cWho) class cbcAclFil
	default cWho := ''
	::cWhoToFil := cWho 
	filter(self)
return(self)

/*/{Protheus.doc} setFilter
@author bolognesi
@since 19/06/2017
@version 1.0
@param cFil, characters, Valor a ser atribuido
@type method
@description Define o conteudo da propriedade ::cFilter
/*/
method setFilter(cFil) class cbcAclFil
	default cFil := ""
	::cFilter := cFil
return(self)

/*/{Protheus.doc} getFilter
@author bolognesi
@since 19/06/2017
@version 1.0
@type method
@description Obtem o conteudo da propriedade ::cFilter
/*/
method getFilter() class cbcAclFil
return(::cFilter)

/*/{Protheus.doc} filter
@author bolognesi
@since 19/06/2017
@version 1.0
@param oSelf, object, descricao
@type function
@description função que obtem o filtro desejado e aplica as regras
todas as regras estão centralizadas aqui 
/*/
static function filter(oSelf)
	local cWho := oSelf:WhoToFil()
	local cA1VisVend	:= ""
	local oSql 			:= nil
	if !FwIsAdmin()
		if !oSelf:usrIsGrp({GRUPO_FATURAMENTO,GRUPO_GER_ADMIN,GRUPO_FISCAL})
			if !Empty(cA1VisVend := A1VisVen())
				if "MTR600" == Alltrim(cWho)
					oSelf:setFilter( "!((C5_CLIENTE + C5_LOJACLI) $ '" + cA1VisVend    +    "')" )
				elseif "MTR590" == Alltrim(cWho)
					oSelf:setFilter("!((F2_CLIENTE + F2_LOJA) $ '" + cA1VisVend    +    "')")

				elseif "SIGAFAT" == Alltrim(cWho)
					DBSelectArea('SA1')
					SET FILTER TO &( "!((A1_COD + A1_LOJA) $ '" + cA1VisVend + "')" )
					DbGoTop()
					DBSelectArea('SC5')
					SET FILTER TO &("!((C5_CLIENTE + C5_LOJACLI) $ '" + cA1VisVend    +    "')")
					SC5->(DbGoTop())
				endIf
			endif
		endif
	endif
return(nil)

/*/{Protheus.doc} A1VisVen
@author bolognesi
@since 19/06/2017
@version 1.0
@type function
@description Obtem os registro da tabela SA1(Clientes) que não devem ser mostrados
em telas e relatorios de acordo com as regras sendo o campo que define esse comportamento
o campo A1_VISVEND (S/N)
/*/
static function A1VisVen()
	local cCond := ''
	local cQry	:= ''
	local nQtd	:= 0
	local nX	:= 0
	cQry += " SELECT (A1_COD + A1_LOJA) AS CHAVE "
	cQry += " FROM  %SA1.SQLNAME% "
	cQry += " WHERE %SA1.XFILIAL% AND A1_VISVEND = 'N' "
	cQry += " AND %SA1.NOTDEL% "

	oSql := LibSqlObj():newLibSqlObj()
	oSql:newAlias(cQry)
	if oSql:hasRecords()
		oSql:goTop()
		nQtd := oSql:count()
		while oSql:notIsEof()
			nX++
			cCond += oSql:getValue("AllTrim(CHAVE)")
			if nX < nQtd
				cCond += '\\'
			endif
			oSql:skip()
		endDo
		oSql:close() 
		FreeObj(oSql)
	endif
return(cCond)