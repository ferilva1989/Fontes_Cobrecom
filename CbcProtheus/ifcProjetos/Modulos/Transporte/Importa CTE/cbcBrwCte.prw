#include 'protheus.ch'
#include "FWMVCDEF.CH"
#include "XMLXFUN.CH"
#include "FILEIO.CH"

/*/{Protheus.doc} cbcBrwCte
//TODO Broser de Controle da CTe.
@author juliana.leme
@since 10/01/2020
@version 1.0
@type function
/*/
user function cbcBrwCte()
	private nCont		:= 0
	private aProc		:= {}
	private aErros		:= {}
	private oCtrle		:= cbcImpCtes():newcbcImpCtes()
	private GFEResult	:= GFEViewProc():New()
	//private lImportaCte	:= .F.
	private oBrowse115	:= nil
	
	lImportaCte	:= .F.

	oCtrle:makeBrowser(@oBrowse115)
	oBrowse115:Activate()
	FreeObj(oCtrle)
	FreeObj(GFEResult)
return(nil)