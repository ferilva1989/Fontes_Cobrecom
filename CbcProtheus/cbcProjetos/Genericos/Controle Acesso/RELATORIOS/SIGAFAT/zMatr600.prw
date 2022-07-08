#include 'protheus.ch'
#include 'parmtype.ch'
#include "MATR600.CH" 

/*/{Protheus.doc} zMatr600
@author bolognesi
@since 19/06/2017
@version 1.0
@type function
@description Função inicial que defini por intermedio do parametro
XX_RELPAD se deve usar o relatorio padrão ou o personalizado com os filtros
/*/
user function zMatr600()
	if GetNewPar('XX_RELPAD', .T.)
		MATR600()
	else
		zMatr600()
	endif
return(nil)

/*/{Protheus.doc} zMatr600
@author bolognesi
@since 19/06/2017
@version 1.0
@type function
@description função intermediario ao MATR600 original, criada para filtrar
os registros que deverão ser exibidos neste relatorio, toda a logica é obtida
do fonte padrão MATR600 atraves de chamadas as funções statics do mesmo.
/*/
static function zMatr600()
	local titulo 		:= OemToAnsi(STR0001)	//"Pedidos Por Vendedor/Cliente"
	local cDesc1 		:= OemToAnsi(STR0002)	//"Este relatorio ira emitir a relacao de Pedidos por"
	local cDesc2 		:= OemToAnsi(STR0003)	//"ordem de Vendedor/Cliente."
	local cDesc3 		:= ""
	local wnrel
	local tamanho		:="P"
	local cString		:="SC5"
	local ocbFil		:= nil
	Local oStatic   	:= IfcXFun():newIfcXFun()

	private aReturn 	:= { STR0004, 1,STR0005, 1, 2, 1, "",1 }//"Zebrado"###"Administracao"
	private nomeprog	:="MATR600"
	private aLinha  	:= { },nLastKey := 0
	private cPerg   	:="MTR600"
	private m_pag    	:= 01

	oStatic:sP(1):callStatic('MATR600', 'AjustaSX1')
	pergunte("MTR600",.F.)

	wnrel:="MATR600"
	wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,tamanho,,.F.)

	If  nLastKey==27
		dbClearFilter()
		Return
	Endif

	//Fixar o filtro
	ocbFil := cbcAclFil():newcbcAclFil("MTR600")
	aReturn[7] := ocbFil:getFilter()
	SetDefault(aReturn,cString)
	
	If nLastKey==27
		dbClearFilter()
		FreeObj(ocbFil)
		Return
	Endif
	
	RptStatus({|lEnd| oStatic:sP(3):callStatic('MATR600', 'C600Imp',@lEnd,wnRel,cString)},titulo)
	FreeObj(ocbFil)
	
return(nil)
