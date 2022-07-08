#include 'protheus.ch'

/*/{Protheus.doc} cbcComboResp
@author bolognesi
@since 12/09/2016
@version 1.0
/*/
class cbcComboResp 
	data lOk
	data cMsg
	data aObjProduct		//Familia do produto
	data aObjGauge			//Bitola
	data aObjPackages		//Acondicionamentos
	data aObjPkFtage 		//Acondicionamento Metragens
	data aObjColors		 	//Cores
	data aObjColorSpec		//Cores x Especialidades
	data cClasse			//Classe de Encordoamento
	data aSpecialtys		//Especialidades
	
	method newcbcComboResp() constructor 
	
	method addProd()
	method addGauge()
	method addColor()
	method addPackAges()
	method addPkFtage()
	method setClasse()
	method addSpecialtys()
	method addColorSpec()
	method findPackAges()

endclass

/*/{Protheus.doc} newcbcComboResp
@author bolognesi
@since 12/09/2016 
@version 1.0
@description Metodo construtor
/*/
method newcbcComboResp() class cbcComboResp
	::aObjProduct	:= {} //Familia do produto
	::aObjGauge		:= {} //Bitola
	::aObjPackages	:= {} //Acondicionamentos
	::aObjPkFtage	:= {} //Acondicionamento Metragens
	::aObjColors	:= {} //Cores
	::aObjColorSpec	:= {} //Cores Especialidades
	::aSpecialtys	:= {} //Especialidades
	::cClasse		:= ""
	::lOk			:= .F.
	::cMsg			:= ""
return

/*/{Protheus.doc} addItem
@author bolognesi
@since 12/09/2016 
@version 1.0
@description Metodo adicionar itens da classe cbcComboItem, utilizado para Familia do produto 
/*/
method addProd(oAdd) class cbcComboResp
	AAdd(::aObjProduct,oAdd) 
	ASort(::aObjProduct,,,{|x,y| x:CTEXT < y:CTEXT})
return (self)

/*/{Protheus.doc} addGauge
@author bolognesi
@since 12/09/2016 
@version 1.0
@description Metodo adicionar itens da classe cbcComboItem, utilizado para Bitola de uma familia 
/*/
method addGauge(oAdd) class cbcComboResp
	AAdd(::aObjGauge,oAdd) 
return (self)

/*/{Protheus.doc} addGauge
@author bolognesi
@since 12/09/2016 
@version 1.0
@description Metodo adicionar itens da classe cbcComboItem, utilizado para Aconsicionamentos 
/*/
method addPackAges(oAdd) class cbcComboResp 
	AAdd(::aObjPackages, oAdd)
return (self)


/*/{Protheus.doc} addItem
@author bolognesi
@since 12/09/2016 
@version 1.0
@description Metodo adicionar itens da classe cbcPackFootage, utilizado para Metragem de cada Acondicionamento 
/*/
method addPkFtage(oAdd) class cbcComboResp
	AAdd(::aObjPkFtage,oAdd) 
return (self)


/*/{Protheus.doc} addColor
@author bolognesi
@since 12/09/2016 
@version 1.0
@description Metodo adicionar itens da classe cbcComboItem, utilizado para Cores
/*/
method addColor(oAdd) class cbcComboResp
	AAdd(::aObjColors,oAdd) 
return (self)

/*/{Protheus.doc} addColor
@author bolognesi
@since 12/09/2016 
@version 1.0
@description Metodo para definir qual a classe de encordoamento do produto
/*/
method setClasse(cCls) class cbcComboResp
	::cClasse := cCls
return (self)

/*/{Protheus.doc} addColor
@author bolognesi
@since 12/09/2016 
@version 1.0
@description Metodo adicionar itens da classe cbcComboItem, utilizado para Especialialidades
/*/
method addSpecialtys(oAdd)class cbcComboResp
	AAdd(::aSpecialtys,oAdd) 
return (self)


/*/{Protheus.doc} addColor
@author bolognesi
@since 12/09/2016 
@version 1.0
@description Metodo adicionar itens da classe cbcComboItem, utilizado para cor de cada especialidade
/*/
method addColorSpec(oAdd) class cbcComboResp
	Local nPos	:= 0
	Default oAdd := ""
	If !Empty(oAdd)
		nPos :=  aScan(::aObjColorSpec,{|x| x:cSpec == oAdd:getSpec()})
		//Adiciona um array de cor em um especialidade existente
		If nPos > 0
			AAdd(::aObjColorSpec[nPos]:aColor,oAdd:getColor() )
		//Adiciona um novo array com especialidade e cor
		Else
			AAdd(::aObjColorSpec,oAdd)
		Endif
	EndIf
return (self)

/*/{Protheus.doc} findPackAges
@author bolognesi
@since 20/01/2017
@version 1.0
@param cSearch, characters, String que deve ser procurada 
no array aObjPackAges
@type method
@description Recebe o ID do acondicionamento (R/B/M/T) ou o NOME (ROLO/BOBINA)
e verifica se existe no array AOBJPACKAGES retornando um logico.
/*/
method findPackAges(cSearch) class cbcComboResp
local lRet		:= .F.
local nPos		:= 0
default cSearch := ""

//Somente pesquisa se parametro informado
if !empty(cSearch)
	//Somente procura do tipo string
	if ValType(cSearch) == 'C'
		
		//Procurar o nome completo
		if len(cSearch) > 1
			nPos := AScan(::AOBJPACKAGES,{|a| lower(Alltrim(a:CTEXT) ) == lower(Alltrim(cSearch)) }) 
		//Procurar pelo ID	
		else
			nPos := AScan(::AOBJPACKAGES,{|a| lower(Alltrim(a:CID)) == lower(Alltrim(cSearch)) })
		endif
		//Teste para o retorno
		lRet := (nPos > 0)
	endif
endif
return (lRet)