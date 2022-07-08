#include 'protheus.ch'
#include 'parmtype.ch'
#include 'MATR590.CH' 

/*/{Protheus.doc} zMatr590
@author bolognesi
@since 19/06/2017
@version 1.0
@type function
@description Função inicial que defini por intermedio do parametro
XX_RELPAD se deve usar o relatorio padrão ou o personalizado com os filtros
/*/
user function zMatr590()
	if GetNewPar('XX_RELPAD', .T.)
		MATR590()
	else
		zMatr590()
	endif
return(nil)

static function zMatr590()
	local wnrel
	local titulo     := OemToAnsi(STR0001)  //"Faturamento por Cliente"
	local cDesc1     := OemToAnsi(STR0002)	//"Este relatorio emite a relacao de faturamento. Podera ser"
	local cDesc2     := OemToAnsi(STR0003)	//"emitido por ordem de Cliente ou por Valor (Ranking).     "
	local cString    := "SF2"
	local tamanho    := "M"
	local ocbFil	 := nil
	Local oStatic    := IfcXFun():newIfcXFun()

	private aReturn  := { OemToAnsi(STR0005), 1,OemToAnsi(STR0006), 1, 2, 1, "",1 }	//"Zebrado"###"Administracao"
	private aCodCli  := {}
	private aLinha   := {}
	private nomeprog := "MATR590"
	private cPerg    := "MTR590"
	private nLastKey := 0

	li       := 80
	m_pag    := 01

	oStatic:sP(1):callStatic('MTR590', 'AjustaSX1')
	pergunte("MTR590",.F.)
	
	wnrel  := "MATR590"
	wnrel  := SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,"",.F.,"",,tamanho,,.F.)

	If nLastKey==27
		dbClearFilter()
		Return
	Endif
	
	//Fixar o filtro
	ocbFil := cbcAclFil():newcbcAclFil("MTR590")
	aReturn[7] := ocbFil:getFilter() //"C5_CLIENTE == '015983'"
	
	SetDefault(aReturn,cString)

	If nLastKey==27
		dbClearFilter()
		FreeObj(ocbFil)
		Return
	Endif
	RptStatus({|lEnd| oStatic:sP(3):callStatic('MATR590', 'C590Imp',@lEnd,wnRel,cString)},Titulo)
	FreeObj(ocbFil)
return(nil)
