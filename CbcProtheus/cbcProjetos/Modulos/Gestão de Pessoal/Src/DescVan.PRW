#INCLUDE "RWMAKE.CH" 
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} DescVan
//TODO Desconto Van.
@author zzz
@since 12/07/2017
@version undefined

@type function
/*/
User Function DescVan()
	xHrsNorm := fBuscAPD( "102","V" )
	xHrsDSR  := fBuscAPD( "103","V" )
	xSomHor  := xHrsNorm + xHrsDSR 
	
	If SRA->RA_FILIAL == "01"
		If SRA->RA_VAN == "S"
			If     SRA->RA_CATFUNC = "H" 
				fGeraVerba("491", xSomHor * 0.06,,,,,,,,,.T.)
			ElseIf SRA->RA_CATFUNC = "M" 
				fGeraVerba("491", SRA->RA_SALARIO * 0.06,,,,,,,,,.T.)
			EndIf
		EndIf
	EndIf   
Return()     

