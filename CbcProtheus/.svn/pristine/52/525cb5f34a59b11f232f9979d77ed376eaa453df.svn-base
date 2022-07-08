#include 'protheus.ch'

class cbcCtrCalcImpost 
	data datacalc
	method newcbcCtrCalcImpost() constructor 
	method responseCalc()
endclass


method newcbcCtrCalcImpost() class cbcCtrCalcImpost
return(self)


method responseCalc(cTpData, cTipoOp) class cbcCtrCalcImpost
	local oJson 	as object
	local oTes 		as object
	local oChange   as object
	local aTemp		:= {}
	default cTipoOp	:= '01'
	
	oJson 		:= JsonObject():new()
	oTes 		:= ctrlTesIntel():newctrlTesIntel()
	oChange 	:= cbcChgAlias():newcbcChgAlias()
	oJson:FromJSON(cTpData)
	oChange:work(oJson["cliente"]:toJson())
	//MaFisSave()
	//MaFisEnd()
	iniFis(oJson["cliente"]["SA1"])
	doCalc(addItm(oJson["itens"], oTes, cTipoOp), self)
	MaFisEnd()
	//MaFisRestore()
	oChange:destroy()
	FreeObj(oJson)
	FreeObj(oTes)
	FreeObj(oChange)
return(nil)



static function doCalc(aItmOk, oSelf)
	local aArea   	 := getArea()
	local aAreaB1 	 := getArea('SB1')
	local aItmCalc   := {}
	local nX 		 := 0
	DbSelectArea('SB1')
	for nX := 1 to len(aItmOk)
		oItm 	   		   := JsonObject():new()
		oItm["nitem"]      := nX
		oItm["cProduto"]   := aItmOk[nX]["codigo"]
		oItm["cDesc"]      := Posicione("SB1",1,xFilial("SB1")+ Padr(aItmOk[nX]["codigo"],TamSx3('B1_COD')[01]),"B1_DESC")
		oItm["nQuant"]     := aItmOk[nX]["quantidade"]
		oItm["nVlrUnit"]   := aItmOk[nX]["precounit"]
		oItm["nVlrTotal"]  := aItmOk[nX]["total"]
		oItm["nBasICM"]    := MaFisRet(nX, "IT_BASEICM")
    	oItm["nValICM"]    := MaFisRet(nX, "IT_VALICM")
    	oItm["nValIPI"]    := MaFisRet(nX, "IT_VALIPI")
    	oItm["nAlqICM"]    := MaFisRet(nX, "IT_ALIQICM")
    	oItm["nAlqIPI"]    := MaFisRet(nX, "IT_ALIQIPI")
    	oItm["nValSol"]    := (MaFisRet(nX, "IT_VALSOL") / aItmOk[nX]["quantidade"]) 
    	oItm["nBasSol"]    := MaFisRet(nX, "IT_BASESOL")
    	oItm["nPrcUniSol"] := aItmOk[nX]["precounit"] + oItm["nValSol"]
    	oItm["nTotSol"]    := oItm["nPrcUniSol"] * aItmOk[nX]["quantidade"]
		aadd(aItmCalc, oItm)
	next nX
	oSelf:datacalc  				  := JsonObject():new()
	oSelf:datacalc["nTotVal"] 		  := MaFisRet(, "NF_TOTAL")
	oSelf:datacalc["nBaseIcm"]        := MaFisRet(, "NF_BASEICM")
	oSelf:datacalc["nValorIcm"]       := MaFisRet(, "NF_VALICM")
	oSelf:datacalc["nBaseST"]         := MaFisRet(, "NF_BASESOL")
	oSelf:datacalc["nValorST"]        := MaFisRet(, "NF_VALSOL")
	oSelf:datacalc["nTotMercadoria"]  := MaFisRet(, "NF_VALMERC")
	oSelf:datacalc["nTotZFranca"]     := MaFisRet(, "NF_DESCZF")
	oSelf:datacalc["aItm"]			  :=  aItmCalc
	restArea(aAreaB1)
	restArea(aArea)
return(nil)


static function addItm(aItm, oTes, cTpOper)
	local aArea   	 := getArea()
	local aAreaB1 	 := getArea('SB1')
	local nX  		 := 0
	local cCod 		 := ''
	local nItAtu	 := 0
	local aItmOk	 := {}
	local cTes		 := ''
	default cTpOper := '01'
	
	for nX := 1 to len(aItm)
		cCod := Padr(Alltrim(aItm[nX]["codigo"]) ,TamSx3('B1_COD')[1])
		if SB1->(DbSeek(FWxFilial("SB1") + cCod))
			cTes := oTes:findTes(2,,cTpOper)
			nItAtu++
			MaFisAdd(cCod,;           // 01 - Codigo do Produto                    ( Obrigatorio )
			cTes,;					  // 02 - Codigo do TES                        ( Opcional )
			aItm[nX]["quantidade"],;  // 03 - Quantidade                           ( Obrigatorio )
			aItm[nX]["precounit"],;   // 04 - Preco Unitario                       ( Obrigatorio )
			0,;                       // 05 - Desconto
			'',;             // 06 - Numero da NF Original                ( Devolucao/Benef )
			'',;                   // 07 - Serie da NF Original                 ( Devolucao/Benef )
			0,;                       // 08 - RecNo da NF Original no arq SD1/SD2
			0,;                       // 09 - Valor do Frete do Item               ( Opcional )
			0,;                       // 10 - Valor da Despesa do item             ( Opcional )
			0,;                       // 11 - Valor do Seguro do item              ( Opcional )
			0,;                       // 12 - Valor do Frete Autonomo              ( Opcional )
			aItm[nX]["total"],;       // 13 - Valor da Mercadoria                  ( Obrigatorio )
			0,;                       // 14 - Valor da Embalagem                   ( Opcional )
			SB1->(RecNo()),;          // 15 - RecNo do SB1
			0)                        // 16 - RecNo do SF4
			
			MaFisLoad("IT_VALMERC", aItm[nX]["total"], nItAtu)                
			MaFisAlt("IT_PESO",     SB1->(B1_PESO * aItm[nX]["quantidade"]), nItAtu)
			aadd(aItmOk, aItm[nX])
		endif
	next nX
	restArea(aAreaB1)
	restArea(aArea)
return(aItmOk)


static function iniFis(cJs)
	local oJs as object
	oJs := JsonObject():new()
	oJs:FromJSON(cJs)

	MaFisIni(oJs["A1_COD"],;                 // 01 - Codigo Cliente/Fornecedor
    oJs["A1_LOJA"],;                         // 02 - Loja do Cliente/Fornecedor
    "C",;                                    // 03 - C:Cliente , F:Fornecedor
    "N",;                                    // 04 - Tipo da NF
    oJs["A1_TIPO"],;                     	 // 05 - Tipo do Cliente/Fornecedor (F R S)
    MaFisRelImp("MT100", {"SF2", "SD2"}),;   // 06 - Relacao de Impostos que suportados no arquivo
    nil,;                                       // 07 - Tipo de complemento
    nil,;                                       // 08 - Permite Incluir Impostos no Rodape .T./.F.
    "SB1",;                                  // 09 - Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
    "MATA461",;                              // 10 - Nome da rotina que esta utilizando a funcao
    nil,;                                       // 11 - Tipo documento
    nil,)                                       // 12 - Especie	
	FreeObj(oJs)
return(nil)

static function validReq(oReq)
	local aRet := {.T.,''}

	if(empty(oReq:GetNames()))
		aRet := {.F.,'Dados não Informados!'}
	else
		if ValType(oReq:GetJsonObject('cliente')) == 'U'
			aRet := {.F.,'Dados do Cliente não Informados!'}
		else
			CompleCampos(@oReq)
		endif
		if ValType(oReq:GetJsonObject('itens')) == 'U'
			aRet := {.F.,'Dados dos produtos não Informados!'}
		endif
	endif
return(aRet)

static function CompleCampos(oReq)
	local nX 	  := 0
	local oJson	  := JsonObject():new()
	local aCampos := {;
						{'A1_COD', '000000'},;
						{'A1_LOJA','01'},;
						{'A1_TIPCLI','1'},;
						{'A1_INSCRUR',''},;
						{'A1_COD_MUN',''},;
						{'A1_ALIQIR',0},;
						{'A1_RECPIS','N'},;
						{'A1_RECCOFI','N'},;
						{'A1_RECCSLL','N'},;
						{'A1_RECISS',''},;
						{'A1_RECINSS',''},;
						{'A1_FRETISS',''},;
						{'A1_TES','999'},;
						{'A1_NREDUZ',''},;
						{'A1_RECFET',''};
	}
	oJson:FromJSON(oReq['cliente']['SA1'])
	for nX := 1 to len(aCampos)
		if ValType(oJson:GetJsonObject(aCampos[nX, 01])) == 'U'
			oJson[aCampos[nX, 01]] := aCampos[nX, 02]
		endif
	next nX
	oReq['cliente']['SA1'] := oJson:ToJson()
	FreeObj(oJson)
return(nil)

user function cbcCalcImpost(oReq)
    local oImp 		:= cbcCtrCalcImpost():newcbcCtrCalcImpost()
	local aRet		:= {.T., '{}'}
	default oReq 	:= JsonObject():new()
	aRet := validReq(@oReq)
	if aRet[01]
		oImp:responseCalc(oReq:toJson(), '01')
		aRet[02] := oImp:datacalc:toJson()
	endif
return(aRet)

/* TEST ZONE */
user function ztCtrImposto()
	local oCtrl 	 as object
	local oJsCliente as object
	local oJsItem    as object
	local oJs    	 as object
	local oSA1       as object
	local aItns		 as array
	
	oCtrl 			:= cbcCtrCalcImpost():newcbcCtrCalcImpost()
	oJs				:= JsonObject():new()
	oJsCliente 		:= JsonObject():new()
	oSA1			:= JsonObject():new()
	oJsCliente['A1_COD'] 		:= '008918'
    oJsCliente['A1_LOJA'] 		:= '01'
	oJsCliente['A1_NOME'] 		:= 'I.G. TRANSMISSAO E DISTRIBUICAO DE ENERGIA S/A'
	oJsCliente['A1_PESSOA'] 	:= 'J'
    oJsCliente['A1_TIPO'] 		:= 'F'
    oJsCliente['A1_EST'] 		:= 'PR'
    oJsCliente['A1_CGC'] 		:= '04636029000115'
    oJsCliente['A1_INSCR'] 		:= '9024293286'
    oJsCliente['A1_VEND'] 		:= '159279'
    oJsCliente['A1_GRPTRIB'] 	:= '001'
    oJsCliente['A1_TIPCLI'] 	:= '1'
    oJsCliente['A1_CONTRIB'] 	:= '1'
    oJsCliente['A1_SIMPNAC'] 	:= '2'
    oJsCliente['A1_CODSIAF'] 	:= '7691'
    oJsCliente['A1_CALCSUF'] 	:= ''
    oJsCliente['A1_TES'] 		:= '921'
    oJsCliente['A1_XREIDI'] 	:= 'S'
	oJsCliente['A1_SUFRAMA']    := ''

	// Default
	oJsCliente['A1_INSCRUR']	:= ''
	oJsCliente['A1_COD_MUN']    := ''
	oJsCliente['A1_ALIQIR']     := 0
	oJsCliente['A1_RECPIS']     := 'N'
	oJsCliente['A1_RECCOFI']    := 'N'
	oJsCliente['A1_RECCSLL']    := 'N'
	oJsCliente['A1_RECISS']     := ''
	oJsCliente['A1_RECINSS']    := ''
	oJsCliente['A1_FRETISS']    := ''
	oJsCliente['A1_NREDUZ']     := ''

	oSA1["SA1"] 				:= oJsCliente:toJson()
	oJs["cliente"]				:= oSA1
	aItns 					:= {}
	// Loop para mais itens
	oJsItem 				:= JsonObject():new()
	oJsItem["codigo"]		:= '1190504401'
	oJsItem["quantidade"]	:= 200
	oJsItem["precounit"]	:= 1.32
	oJsItem["total"]		:= 264
	aadd(aItns, oJsItem)
	
	// Depois do loop
	oJs["itens"]   := aItns
	
	oCtrl:responseCalc(oJs:toJson(), '01')
	msgInfo(oCtrl:datacalc:toJson())
	FreeObj(oCtrl)
	FreeObj(oJsCliente)
	FreeObj(oJsItem)
	FreeObj(oSA1)
	FreeObj(oJs)

return(nil)
