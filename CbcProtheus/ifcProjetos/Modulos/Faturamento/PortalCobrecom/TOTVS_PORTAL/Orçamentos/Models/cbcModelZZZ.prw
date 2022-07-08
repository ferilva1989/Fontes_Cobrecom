#include 'protheus.ch'

/*/{Protheus.doc} cbcModelZZZ
@author bolognesi
@since 05/01/2017
@version 1.0
@type class
@description Classe que representa a tabela ZZZ
(Produto x Acondicionamento x MeTragem )bem como alguns metodos uteis
/*/
class cbcModelZZZ from errLog

	data oSql
	method newcbcModelZZZ() constructor 
	method getZZZProd()
	method getZZZBito()

endclass

/*/{Protheus.doc} newcbcModelZZZ
@author bolognesi
@since 05/01/2017
@version 1.0
@type method
@description Construtor da classe
/*/
method newcbcModelZZZ() class cbcModelZZZ
	/* 
	//Herança classe errLog
	::getMsgLog() = Obter MsgErro  
	::setStatus(lSts, cCodMsg, cMsg) = Definir Status ( .T./ .F. ) , codErro e MsgErro 
	::itsOk() Verifica se esta tudo Ok
	::clearStatus() = Limpar status de erro
	*/
	::newerrLog('ModelZZZ')
	::oSql 		:= SqlUtil():newSqlUtil()
return

/*/{Protheus.doc} getZZZProd
@author bolognesi
@since 05/01/2017
@version 1.0
@type method
@description Get da propriedade aZZZProd
sempre busca informações no SQL 
/*/
method getZZZProd(cProd) class cbcModelZZZ
	local cQry		:= ""
	local lEmail	:= .F.
	Default cProd := ""
	::clearStatus()
	If Empty(cProd)
		::setStatus( .F.,'CBC300' ,'Classe getZZZProd, metodo getZZZProd parametro obriatorio')
	Else
		cQry += " SELECT "  
		cQry += " DISTINCT ZZZ_PROD "
		cQry += " FROM " +  RetSqlName('ZZZ')
		cQry += " WHERE ZZZ_FILIAL = '" + xFilial('ZZZ') + "' 		"
		cQry += " AND ZZZ_TIPO = 'MTR' 			"
		cQry += " AND ZZZ_PROD =  '" + cProd + "'" 
		cQry += " AND D_E_L_E_T_ <> '*' "
		cQry += " ORDER BY ZZZ_PROD ASC "
	
		If ! ::oSql:QryToDb(cQry):lOk	
			//TODO ver a necessidade em definir status
			::setStatus( .F.,'CBC301' ,'COD.PROD ' + cProd + ' ' + ::oSql:cMsgErro, lEmail )	
		EndIf
	EndIF
return(self)

/*/{Protheus.doc} getZZZBito
@author bolognesi
@since 05/01/2017
@version 1.0
@param cProd, characters, Familia de produto que deve buscar as bitolas
@type method
@description Obter para um Familia de produto, as bitolas existentes no cadastro
ZZZ
/*/
method getZZZBito(cProd, cBitola) class cbcModelZZZ
	local cQry		:= ""
	local lEmail	:= .F.
	Default cProd 	:= ""
	Default cBitola := ""
	::clearStatus()
	If Empty(cProd) .Or. Empty(cBitola) 
		::setStatus( .F.,'CBC302' ,'Classe cbcModelZZZ, metodo getZZZBito parametro obrigatorio')
	Else
		if GetNewPar('XX_DBGCONN', .T. )
			Conout('Familia+Bitola' + cProd + ' Bitola. ' + cBitola )
		endif
		cQry += " SELECT "  
		cQry += " DISTINCT ZZZ_PROD + ZZZ_BITOLA, "
		cQry += " ZZZ_BITOLA "
		cQry += " FROM " +  RetSqlName('ZZZ')
		cQry += " WHERE ZZZ_FILIAL = '" + xFilial('ZZZ') + "' 		"
		cQry += " AND ZZZ_TIPO = 'MTR' 			"
		cQry += " AND ZZZ_PROD = '"+ Alltrim(cProd) 	+ "'"
		cQry += " AND ZZZ_BITOLA = '"+ Alltrim(cBitola) 	+ "'"
		cQry += " AND D_E_L_E_T_ <> '*' "
		cQry += " ORDER BY ZZZ_BITOLA ASC "
	
		If ! ::oSql:QryToDb(cQry):lOk	
			::setStatus( .F.,'CBC303' ,'Familia' + cProd + ' Bitola. ' + cBitola + ::oSql:cMsgErro ,lEmail )	
		EndIf
	EndIf
return(self)

/* TESTE ZONE */
User Function ZZZModel(cProd, cBitola) //U_ZZZModel('115', '07')
Local euMesmo := nil

euMesmo := cbcModelZZZ():newcbcModelZZZ()
If !euMesmo:getZZZProd(cProd):itsOk()
	Alert('Não Existe Produto')
Else
	Alert('Produto Existe')
	
	If !euMesmo:getZZZBito(cProd, cBitola):itsOk()
		Alert('Não Existe Produto + Bitola')
	Else
		Alert('Existe Produto + Bitola')
	EndIF
EndIf

return(nil)