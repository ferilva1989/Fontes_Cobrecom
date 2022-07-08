#include 'protheus.ch'

/*/{Protheus.doc} cbcModClient
@author bolognesi
@since 07/07/2017
@version 1.0
@type class
@description Classe Generica que representa uma estancia da tabela SA1,
bem como alguns metodos uteis
/*/
class cbcModClient 
	data cCod		//A1_COD
	data cLoja		//A1_LOJA
	data cEstado 	//A1_EST
	data cSegmento	//A1_SEGMENT
	data cVarejo	//A1_ZZVAREJ
	method newcbcModClient() constructor 
	method getEstado()
	method setEstado()
	method getSegmento()
	method setSegmento()
	method getVarejo()
	method setVarejo()
	method getCodigo()
	method setCodigo()
	method getLoja()
	method setLoja()
	method getField()
	
endclass

/*/{Protheus.doc} newcbcModClient
@author bolognesi
@since 07/07/2017
@version 1.0
@param cCod, characters, Codigo do Cliente (Opcional)
@param cLoja, characters, Loja do Cliente (Opcional)
@type method
@description Construtor da classe
/*/
method newcbcModClient(cCod, cLoja) class cbcModClient
default cCod	:= ''
default cLoja	:= ''
::setCodigo(cCod)
::setLoja(cLoja)
return(self)

/*/{Protheus.doc} getCodigo
@author bolognesi
@since 07/07/2017
@version 1.0
@type method
@description Obter o conteudo da propriedade ::cCod
/*/
method getCodigo() class cbcModClient
return(::cCod)

/*/{Protheus.doc} setCodigo
@author bolognesi
@since 07/07/2017
@version 1.0
@param cCod, characters, descricao
@type method
@description Atribuir valor a propriedade ::cCod
/*/
method setCodigo(cCod) class cbcModClient
	::cCod := cCod 
return(self)

/*/{Protheus.doc} getLoja
@author bolognesi
@since 07/07/2017
@version 1.0
@type method
@description Obter o conteudo da propriedade ::cLoja
/*/
method getLoja() class cbcModClient
return(::cLoja)

/*/{Protheus.doc} setLoja
@author bolognesi
@since 07/07/2017
@version 1.0
@param cLoja, characters, Valor a ser atribuido
@type method
@description define conteudo para propriedade :;cLoja
/*/
method setLoja(cLoja) class cbcModClient
	::cLoja := cLoja 
return(self)

/*/{Protheus.doc} getEstado
@author bolognesi
@since 07/07/2017
@version 1.0
@type method
@description Obter o conteudo da propriedade ::cEstado 
/*/
method getEstado() class cbcModClient
return(::cEstado)

/*/{Protheus.doc} setEstado
@author bolognesi
@since 07/07/2017
@version undefined
@param cEstado, characters, conteudo a ser atribuido
@type method
@description Definir conteudo para propriedade ::cEstado
/*/
method setEstado(cEstado) class cbcModClient
	::cEstado := cEstado 
return(self)

/*/{Protheus.doc} getSegmento
@author bolognesi
@since 07/07/2017
@version 1.0
@type method
@description Obter o conteudo da propriedade ::cSegmento 
/*/
method getSegmento() class cbcModClient
return(::cSegmento)

/*/{Protheus.doc} setSegmento
@author bolognesi
@since 07/07/2017
@version undefined
@param cSegmento, characters, descricao
@type method
@description Definir conteudo para propriedade ::cSegmento
/*/
method setSegmento(cSegmento) class cbcModClient
	local lRet	:= .F.
	local oSql 	:= nil
	default cSegmento 	:= ''
	::cSegmento 		:= ''

	if !empty(cSegmento)
		oSql 		:= LibSqlObj():newLibSqlObj()

		if !empty(cSegmento 	:= oSql:getFieldValue("SX5", "X5_CHAVE",;
		"%SX5.XFILIAL% AND X5_TABELA = 'ZK' AND X5_CHAVE ='" + cSegmento + "'") )

			::cSegmento := cSegmento
			lRet := .T.
		endif
		freeObj(oSql)
	endif
return(lRet)

/*/{Protheus.doc} getVarejo
@author bolognesi
@since 07/07/2017
@version 1.0
@type method
@description Obter o conteudo da propriedade ::cVarejo 
/*/
method getVarejo() class cbcModClient
if empty(::cVarejo)
	::cVarejo := 'N'
endif
return(::cVarejo)

/*/{Protheus.doc} setSegmento
@author bolognesi
@since 07/07/2017
@version 1.0
@type method
@description Definir conteudo para propriedade ::cVarejo
/*/
method setVarejo() class cbcModClient
	local cVarejo	:= 'N'
	local cEstParam	:= GetNewPar('ZZ_VRJEST', 'SP') 
	local cSegParam	:= GetNewPar('ZZ_VRJSEG', '02;05;06')

	if U_isInStr(::cEstado, cEstParam) .and. U_isInStr(::cSegmento, cSegParam)
		cVarejo	:= 'S'
	endif
	::cVarejo := cVarejo 
return(self)

/*/{Protheus.doc} getField
@author bolognesi
@since 07/07/2017
@version 1.0
@param cCampo, characters, nome do campo Exmplo A1_CGC
@type method
@description Obter via SQL o conteudo do campo informado como parametro
desde que as propriedades cod e loja estejam preenchidas
/*/
method getField(cCampo) class cbcModClient
local xValor	:= ''
local oSql 		:= nil
local cCod		:= ::getCodigo()
local cCli		:= ::getLoja()
default cCampo 	:= ''

if !empty(cCampo) .and. !empty(cCod) .and. !empty(cCli)
	oSql := LibSqlObj():newLibSqlObj()
	xValor := oSql:getFieldValue("SA1", cCampo,;
		"%SA1.XFILIAL% AND A1_COD ='" + cCod +  "' AND  A1_LOJA ='" + cCli + "'")
	oSql:Close()
	FreeObj(oSql)
endif
return(xValor)


/*** TEST ZONE **/
user function zModCli(cCod, cLoja) //U_zModCli('004232','01')
local oCliente := cbcModClient():newcbcModClient(cCod, cLoja)

Alert('NOME '  		+  oCliente:getField('A1_NOME') )
Alert('CNPJ '  		+  oCliente:getField('A1_CGC') )
Alert('SEGMENTO '  	+  oCliente:getField('A1_SEGMENT') )

FreeObj(oCliente)
return(nil)