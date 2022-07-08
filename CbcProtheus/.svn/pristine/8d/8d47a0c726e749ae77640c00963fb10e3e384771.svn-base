#include "rwmake.ch"
#include 'FWMVCDEF.CH'

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDGENG02                           Modulo : SIGAEST      //
//                                                                          //
//   Autor ......: RODRIGO O. T. CAETANO              Data ..: 10/08/2004   //
//                                                                          //
//   Objetivo ...: Gatilho acionado nos campos B1_NOME, B1_BITOLA, B1_COR,  //
//                 B1_CLASENC, B1_ESPECIA, B1_FORNECE e B1_IDENTIF para      //
//                 montar o Código do Produto                               //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////

user Function CDGENG02
local cCod		:= ''
local cId		:= 'SB1MASTER'
local lIsPa		:= .F.
local oModel 		:= FWModelActive()
local oM			:= oModel:getModel(cId)

	lIsPa 	:= ( oM:GetValue('B1_TIPO' ) == 'PA') 
	cCod 	:= oM:GetValue('B1_NOME' )
	cCod 	+= if(lIsPa, oM:GetValue( 'B1_BITOLA')	, oM:GetValue( 'B1_COR') )
	cCod 	+= if(lIsPa, oM:GetValue( 'B1_COR')		, oM:GetValue( 'B1_FORNECE') )
	cCod 	+= if(lIsPa, oM:GetValue( 'B1_CLASENC')	, "0")
	cCod 	+= if(lIsPa, oM:GetValue( 'B1_ESPECIA')	, oM:GetValue( 'B1_IDENTIF') )  
	oM:LoadValue('B1_COD', cCod )

return(cCod)
