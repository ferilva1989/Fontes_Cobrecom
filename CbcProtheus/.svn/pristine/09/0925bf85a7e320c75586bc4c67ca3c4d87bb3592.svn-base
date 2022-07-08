#include 'protheus.ch'


class cbcsyncdbinvent 

	method newcbcsyncdbinvent() constructor 
	method logReg()
	method clearStage()
	method getStage()
endclass


method newcbcsyncdbinvent() class cbcsyncdbinvent

return(self)


/*/{Protheus.doc} logReg
@author bolognesi
@since 30/09/2018
@version 1.0
@type method 
@Description Utilizado para realizar o log no banco
das operações realizadas, utiliza thread 
/*/
method logReg(cConteudo) class cbcsyncdbinvent
	local cGravar		:= ''
	default cConteudo 	:= ''
	if !empty(cConteudo)
		cGravar := DtoC(Date()) + Time() + ' - ' + cConteudo
	endif
return(self)


/*/{Protheus.doc} clearStage
@author bolognesi
@since 30/09/2018
@version 1.0
@description Atualiza no banco quando finalizada uma
etapa
/*/
method clearStage(cStage) class cbcsyncdbinvent
return(self)



/*/{Protheus.doc} getStage
@author bolognesi
@since 30/09/2018
@version 1.0
@description Obtem ultima etapa concluida
de uma idInevtario
/*/
method getStage(idInevtario) class cbcsyncdbinvent
return(self)
