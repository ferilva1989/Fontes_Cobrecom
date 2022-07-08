#INCLUDE "totvs.ch"
#INCLUDE "restful.ch"
#INCLUDE "CBCREST.ch"

/*
POST: http://192.168.1.220:7798/ws/CBCCALCTAX
BODY: 
{
	"CLI": {
		"A1_COD": "004746",
		"A1_LOJA": "01"
	},
	"ITEMS": [
        {
			"COD": "1530504401",
			"QTD": 2000,
			"PRCUNIT": 5.7,
			"TOTAL": 11400
		}
    ]
}
*/
WSRESTFUL CBCCALCTAX DESCRIPTION "Cobrecom - TAX - Calculo de Impostos"
WSMETHOD POST DESCRIPTION "Calcular impostos" WSSYNTAX "/CBCCALCTAX"
END WSRESTFUL

WSMETHOD POST WSSERVICE CBCCALCTAX
	local lPost		:= .T.
	local oRes		:= cbcBIResp():newcbcBIResp()
	local oJsonRes	:= nil

	::SetContentType("application/json")
    oJsonRes 				:= u_cbcTaxPortal(::GetContent())
	oRes:sucesso 			:= .T.
	oRes:msg				:= 'Consulta Realizada'
	oRes:xRet				:= oJsonRes	
	::SetStatus(200)
	::SetResponse(oRes:toJson())
return lPost
