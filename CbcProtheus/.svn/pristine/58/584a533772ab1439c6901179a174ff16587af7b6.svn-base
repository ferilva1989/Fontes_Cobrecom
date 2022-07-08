#include 'protheus.ch'

/*/{Protheus.doc} cbcSyncCouchInv
(long_description)
@author    clementino
@since     14/01/2020
@version   ${version}
@description Criar e Atualizar informações do inventario no CouchDB 
@see (links_or_references)
/*/
class cbcSyncCouchInv from cbcApiCouch
	data oCbcCouchDB

	method newcbcSyncCouchInv() constructor 
	method saveDataInv()
	method updDataInv()

endclass


method newcbcSyncCouchInv() class cbcSyncCouchInv
	local cAddress	:= Alltrim(GetNewPar('ZZ_INVADDR','192.168.1.220'))
	local cPort		:= Alltrim(GetNewPar('ZZ_INVPORT','5984'))
	local cUsr		:= Alltrim(GetNewPar('ZZ_INVUSER','admin'))
	local cPass 	:= Alltrim(GetNewPar('ZZ_INVPASS','admin'))
	local cDb		:= Alltrim(GetNewPar('ZZ_INVDATA','dadosinv'))

	::oCbcCouchDB := cbcApiCouch():newcbcApiCouch(cAddress, cPort, cUsr, cPass, cDb)
return (self)


method saveDataInv(oDoc) class cbcSyncCouchInv
	Default oDoc 	  := nil
	
	If !Empty(oDoc:toJson())
		::oCbcCouchDB:insertReg(oDoc)
	EndIf
	If !(::oCbcCouchDB:isOk())
		Alert("COUCHDB" + ::oCbcCouchDB:getErroMsg())
	EndIf
return (self)


method updDataInv(oDoc) class cbcSyncCouchInv
	Default oDoc 	  := nil
	
	If !Empty(oDoc:toJson())
		::oCbcCouchDB:updateReg(oDoc)
	EndIf
	If !(::oCbcCouchDB:isOk())
		Alert("COUCHDB" + ::oCbcCouchDB:getErroMsg())
	EndIf
return (self)

