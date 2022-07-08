#include 'protheus.ch'
#include 'parmtype.ch'

/*RETORNA FAMILIA*/
user function zProdDet()
	Local oProd := cbcProductDetails():newcbcProductDetails('CodCliente','LojaCliente',.F.)
	If oProd:getProducts():oCmbResp:lOk
		oProd:oCmbResp:aObjProduct
	Else
		oProd:oCmbResp:cMsg
	EndIf
return

/*RETORNA BITOLA*/
user function zBitoDet(cCod)//u_zBitoDet('115')
	Local oProd := cbcProductDetails():newcbcProductDetails('CodCliente','LojaCliente',.F.)
	If oProd:getGauges(cCod):oCmbResp:lOk
		oProd:oCmbResp:aObjGauge
	Else
		oProd:oCmbResp:cMsg
	EndIf
return

/* RETORNA  ACONDICIONAMENTO / METRAGEM POR ACONDICIONAMENTO / ESPECIALIDADES  / CORES DAS ESPECIALIDADES */
user function zAcMtEsp(cCod, cBitola) //u_zAcMtEsp('115','02')
	Local oProd := cbcProductDetails():newcbcProductDetails('CodCliente','LojaCliente', .F.)
	If oProd:getPackagings(cCod, cBitola):oCmbResp:lOk
		oProd:oCmbResp:aObjPackages
		oProd:oCmbResp:aObjPkFtage
		oProd:oCmbResp:aSpecialtys
		oProd:oCmbResp:aObjColorSpec
	Else
		oProd:oCmbResp:cMsg
	EndIf

return

/*RETORNA CLASSE ENCORDOAMENTO */
user function zRetCls(cCod, cBitola, cCor, cEsp) //u_zRetCls('115','02','03', 'especialidade')
	Local oProd := cbcProductDetails():newcbcProductDetails('CodCliente','LojaCliente', .F.)
	If oProd:getClsStrings(cCod,cBitola,cCor,cEsp):oCmbResp:lOk
		oProd:oCmbResp:cClasse
	Else
		oProd:oCmbResp:cMsg
	EndIf
return


/*TESTAR DE FORMA GRAFICA */
//u_testeOrc()     
