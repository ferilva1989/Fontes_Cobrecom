#include 'protheus.ch'
#define CRLF Chr(13)+Chr(10)

/*/{Protheus.doc} ctrlProcTriangle
(long_description)
@author    alexandre.madeira
@since     15/01/2020
@version   ${version}
@example
(examples)
@see (links_or_references)
/*/
class ctrlTriangle 
	
	data lOk
	data lMsg
	data cMsgErr
	data aFilDiv
	data nRecPed
	data cIdVend
	data oLock
	
	method newctrlTriangle() constructor 
	
	method isOk()
	method isLock()
	method getErrMsg()
	method getFilDiv()
	method getPedVend()
	method getIdVend()
	method setLocks()
	method libLocks()
	method FilDivRule()
	method setDivPed()
	method genPedDiv()
	method createIDVenda()
	method eliminaResiduo()
	method setStatus()
	
endclass

method newctrlTriangle(nRecC5, lMsg) class ctrlTriangle
	local bErro		 := ErrorBlock({|oErr| errHandle(oErr, @self)})
	default nRecC5 	 := 0
	default lMsg	 := .F.
	
	BEGIN SEQUENCE
		::setStatus()
		::FilDivRule()
		::nRecPed	:= 0
		::cIdVend	:= ''
		::oLock		:= cbcLockCtrl():newcbcLockCtrl()
		::lMsg		:= lMsg
		if nRecC5 > 0
			::setStatus(::setDivPed(nRecC5):isOk(), ::getErrMsg(), .T.)
		endif
	RECOVER
	END SEQUENCE
    ErrorBlock(bErro)
return(self)

method isOk() class ctrlTriangle
return(::lOk)

method isLock() class ctrlTriangle
	local lLock := !empty(::oLock:aLocks)
return(lLock)

method getErrMsg() class ctrlTriangle
return(::cMsgErr)

method getFilDiv() class ctrlTriangle
return(::aFilDiv)

method getPedVend() class ctrlTriangle
return(::nRecPed)

method getIdVend() class ctrlTriangle
return(::cIdVend)

method setLocks() class ctrlTriangle	
	u_zTriangLocks(.T., ::getIdVend(), @::oLock)
return(self)

method libLocks() class ctrlTriangle
	u_zTriangLocks(.F.,,@::oLock)
return(self)

method FilDivRule() class ctrlTriangle
	local cFilDivPar := AllTrim(GetNewPar( 'ZZ_TFILDIV', '' ))
	local aFili		 := FWAllFilial()
	local nX		 := 0
	local bErro		 := ErrorBlock({|oErr| errHandle(oErr, @self)})
	
	BEGIN SEQUENCE
		if !empty(cFilDivPar)
			::aFilDiv := Separa(cFilDivPar,";",.F.)
			for nX := 1 to len(::aFilDiv)
				if AScan(aFili,::aFilDiv[nX]) == 0
					::setStatus(.F., 'Filial para Triangulação não encontrada(ZZ_TFILDIV)!',.T.)
					EXIT
				endif
			next nX
		endif
		RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
return(self)

method setDivPed(nRecC5) class ctrlTriangle
	local oSql 		:= LibSqlObj():newLibSqlObj()
	local lHas		:= .F.
	default nRecC5 	:= 0

	oSql:newTable("SC5", "C5_X_IDVEN IDVEN", "%SC5.XFILIAL% AND R_E_C_N_O_ = " + cValToChar(nRecC5)) 

	lHas := oSql:hasRecords()
	if(::setStatus(lHas, iif(lHas, '','Pedido não localizado!')):isOk())
		::nRecPed 	:= nRecC5
		::cIdVend	:= oSql:getValue("IDVEN")
	endif
	
	oSql:close()
	FreeObj(oSql)
return(self)

method genPedDiv() class ctrlTriangle
	local lHasPed 	:= !(empty(::getPedVend()))
	local lProc		:= empty(::getIdVend())
	local aItens	:= {}
	local aPeds		:= {}
	local aJPeds	:= {}
	local aRet		:= {}
	local bErro		:= ErrorBlock({|oErr| errHandle(oErr, @self)})
	
	BEGIN SEQUENCE
		if ::setStatus(lHasPed,'Sem pedido definido!'):isOk()	
			if ::setStatus(lProc, 'Pedido já processado!'):isOk()
				aItens := loadNeeds(::getPedVend())
				if empty(aItens)
					::setStatus(.F., 'Não há itens para Triangulação!')
				else	
					::createIDVenda()
					/*
					makeDiv(FwFilial(), @aItens, ::getFilDiv(), @aPeds)
					makeSubPeds(@aPeds)
					*/
					ctrlDiv(FwFilial(), @aItens, ::getFilDiv(), @aPeds)
					mountPeds(::getIdVend(), aPeds, @aJPeds, ::getPedVend())
					if !empty(aJPeds)
						BEGIN TRANSACTION
							aRet := u_cbcSrvPedFil(aJPeds, 3)
							if ::setStatus(aRet[1], aRet[2], .T.):isOk()
								aRet := updatePedOri(::getPedVend(), ::getIdVend(), aItens)
								::setStatus(aRet[1], aRet[2], .T.)
							endif
						END TRANSACTION
					endif
				endif
			endif
		endif
	RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
return(self)

method createIDVenda() class ctrlTriangle
	local aArea    	:= GetArea()
	local aAreaSC5	:= SC5->(getArea())
	
	dbselectArea('SC5')
	
	SC5->(DbGoTo(::getPedVend()))
	
	if !empty(::getPedVend())
		::cIdVend := AllTrim(FwFilial()) + AllTrim(SC5->C5_NUM) + AllTrim(GetNewPar( 'MV_ESTADO', '',FwFilial()))
	endif
	
	RestArea(aAreaSC5)
	RestArea(aArea)
return(self)

method eliminaResiduo() class ctrlTriangle
	local lHasPed 	:= !(empty(::getPedVend()))
	local lProc		:= !(empty(::getIdVend()))
	local aRet		:= {}
	local lRet		:= .T.
	local bErro		:= ErrorBlock({|oErr| errHandle(oErr, @self)})
	
	BEGIN SEQUENCE
		if ::setStatus(lHasPed,'Sem pedido definido!'):isOk()
			if ::setStatus(lProc, 'Pedido não processado!'):isOk()
				aRet := validResiduo(::getIdVend())
				if (::setStatus(aRet[1], aRet[2]):isOk())
					::setLocks()
					if (::setStatus(::isLock(), iif(::isLock(),'','Não foi possível efetuar LOCKs dos Registros'), .T.):isOk())
						BEGIN Transaction
							lRet := MsgYesNo('Confirma eliminação de Resíduos dos Pedidos?','Eliminar Resíduos - IDVenda: ' + cValtoChar(::getIdVend()))
							if (::setStatus(lRet, iif(lRet, '','Eliminacao de Residuo Cancelada!'), .F.):isOk())
								lRet := eliminaResiduo(::getIdVend())
								if (::setStatus(lRet, iif(lRet, '','Erro ao Eliminar Resíduo!'), .T.):isOk())
									::libLocks()
								endif
							else
								::libLocks()
							endif
						END Transaction
					endif
				endif
			endif
		endif
	RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
return(self)

method setStatus(lOk, cMsg, lEx) class ctrlTriangle
	private lException	:= .F.
	
	default lOk			:= .T.
	default cMsg 		:= ''
	default lEx			:= .F.
	
	::lOk				:= lOk
	
	if !lException
		if !lOk
			::cMsgErr	:= "[ctrlProcTriangle - "+DtoC(Date())+" - "+Time()+" ] " + '[ERRO]' + cMsg
			if ::lMsg
				MsgAlert(::cMsgErr, 'Aviso')
			endif
			if lEx
				lException := .T.
				UserException(cMsg)
			endif
		endif
	endif
return(self)

static function loadNeeds(nRecC5)
	local aNeeds	:= {}
	local oSql 		:= LibSqlObj():newLibSqlObj()
		
	oSql:newAlias(u_qryProcTriangle(nRecC5))
	
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			if !(u_FilialFaz(FwFilial(), oSql:getValue("PRODUTO")))
				aAdd(aNeeds, {	oSql:getValue("PRODUTO"),; 
								oSql:getValue("ACONDIC"),;
								oSql:getValue("LANCES"),;
								oSql:getValue("METRAGE"),;
								oSql:getValue("QTD"),;
								'',;
								oSql:getValue("LOCAL"),;
								oSql:getValue("TES"),;
								oSql:getValue("PESCOB"),;
								AllTrim(oSql:getValue("PEDORI")),;
								AllTrim(oSql:getValue("ITEM")),;
								oSql:getValue("PRCVEN"),;
								oSql:getValue("SC6REC"),;
								'N';
							})
			endif
			oSql:skip()
		endDo
	endif	
	oSql:close()
	FreeObj(oSql)
return(aNeeds)

static function ctrlDiv(cFilOri, aItens, aFils, aPeds)
	local nX		:= 0
	default aPeds	:= {}

	makeDiv(cFilOri, @aItens, cFilOri, @aPeds)
	for nX := 1 to len(aFils)
		makeDiv(cFilOri, @aItens, aFils[nX], @aPeds)
	next nX

	for nX := 1 to len(aFils)
		makeSubPeds(aFils[nX], @aItens, @aPeds, cFilOri)
	next nX
	//doSemana(@aItens, @aPeds, cFilOri)
return(aPeds)

static function makeDiv(cFilOri, aItens, cFilProc, aPeds)
	local nX 		:= 0
	local aItensPed	:= {}
	local cLocal	:= ''
	local cTes		:= ''
	default lSub	:= .F.
	default aPeds 	:= {}
	default cFilOri := FwFilial()

	aItensPed	:= {}
	for nX := 1 to len(aItens)
		if aItens[nX,14] == 'N'
			//AVALIA SE FILIAL DE PROCESSAMENTO FABRICA ITEM
			if (u_FilialFaz(cFilProc, aItens[nX,1]))
				//ALTERA STATUS DO ITEM PARA ATENDIDO
				aItens[nX,14] 	:= 'S'
				//TRATAMENTO PARA ITENS SOLICITADOS EM FILIAL DIFERENTE
				if (cFilOri <> cFilProc)
					cLocal			:= aItens[nX,7]
					cTes			:= ''
					//DEFINE TES
					if aItens[nX,9] <= 0
						cTes := AllTrim(GetNewPar( 'ZZ_TESNOCB', '849' , cFilProc))
					else
						cTes := AllTrim(GetNewPar( 'ZZ_TES'+ cFilOri + cLocal, '551' , cFilProc))
					endif
					//ADICIONA ITEM
					aAdd(aItensPed, {	aItens[nX,1],; 
										aItens[nX,2],; 
										aItens[nX,3],; 
										aItens[nX,4],; 
										aItens[nX,5],; 
										'',; 
										cLocal,; 
										cTes,; 
										aItens[nX,9],; 
										aItens[nX,10],; 
										aItens[nX,11],; 
										aItens[nX,12],;
										aItens[nX,13]})
				endif
			endif
		endif
	next nX
	if !empty(aItensPed)
		aAdd(aPeds, {cFilProc, aClone(aItensPed), cFilOri})
	endif
return(aPeds)

static function makeSubPeds(cFilProc, aItens, aPeds, cFilOri)
	local nX		:= 0
	local aFilis	:= {}
	local lContinue	:= .T.
	local aTmpPeds	:= {}
	default cFilProc:= FwFilial()
	default cFilOri	:= FwFilial()

	default aPeds 	:= {}
	
	while lContinue
		aFilis := Separa(AllTrim(GetNewPar( 'ZZ_TFILDIV', '' , cFilProc)),";",.F.)
		if !empty(aFilis)
			for nX := 1 to len(aFilis)
				aTmpPeds	:= {}
				aTmpPeds 	:= makeDiv(cFilProc, @aItens, aFilis[nX])
				addSubPeds(aTmpPeds, @aPeds, cFilOri)
				makeSubPeds(aFilis[nX], @aItens, @aPeds, cFilProc)
			next nX
			lContinue := .F.
		else
			lContinue := .F.
		endif
	EndDo
return(aPeds)

static function addSubPeds(aTmpPeds, aPeds, cFilOri)
	local nX 		:= 0
	local nY		:= 0
	local nPos 		:= 0
	local cFilPed 	:= ""
	local cFilFab 	:= ""
	local cTes 		:= ""

	if !empty(aTmpPeds)
		for nX := 1 to len(aTmpPeds)
			cFilPed	:= aTmpPeds[nX,03]
			cFilFab := aTmpPeds[nX,01]
			//ADICIONAR O SUBPEDIDO
			if (nPos := Ascan(aPeds,{|x| x[01]  == cFilFab .and. x[03]  == cFilPed }) ) > 0
				for nY := 1 to len(aTmpPeds[nX, 02])
					aAdd(aPeds[nPos, 02], AClone(aTmpPeds[nX, 02, nY]))
				next nY
			else
				aAdd(aPeds, AClone(aTmpPeds[nX]))
			endif
			aTmpPeds[nX,03] := cFilOri
			aTmpPeds[nX,01]	:= cFilPed
			for nY := 1 to len(aTmpPeds[nX, 02])
				aTmpPeds[nX, 02, nY, 06] := 'TRIANG'
				aTmpPeds[nX, 02, nY, 07] := AllTrim(GetNewPar( 'ZZ_TARMZ' + cFilPed, aTmpPeds[nX, 02, nY, 07], cFilOri))
				//DEFINE TES
				if aTmpPeds[nX, 02, nY, 09] <= 0
					cTes := AllTrim(GetNewPar( 'ZZ_TESNOCB', '849' , cFilPed))
				else
					cTes := AllTrim(GetNewPar( 'ZZ_TES'+ cFilOri + aTmpPeds[nX, 02, nY, 07], '551' , cFilPed))
				endif
				aTmpPeds[nX, 02, nY, 08] := cTes
			next nY
			if (nPos := Ascan(aPeds,{|x| x[01]  == cFilPed .and. x[03]  == cFilOri }) ) > 0
				for nY := 1 to len(aTmpPeds[nX, 02])
					aAdd(aPeds[nPos, 02], AClone(aTmpPeds[nX, 02, nY]))
				next nY
			else
				aAdd(aPeds, AClone(aTmpPeds[nX]))
			endif
		next nX
	endif
return(aPeds)

static function doSemana(aItens, aPeds, cFilOri)
	local nX 	:= 0
	local nY	:= 0
	local nPos	:= 0

	//ACERTAR SEMANA DO AITENS
	for nX := 1 to len(aItens)
		for nY := 1 to len(aPeds)
			if aPeds[nY, 03] == cFilOri
				if (nPos := Ascan(aPeds[nY, 02],{|x| x[13]  == aItens[nX, 13] }) ) > 0
					aItens[nX,6] := 'TRIANG'
					aItens[nX,7] := AllTrim(GetNewPar( 'ZZ_TARMZ' + aPeds[nY, 01], aItens[nX,7] , cFilOri))
				endif
			endif
		next nY
	next nX
return(aPeds)

static function mountPeds(cIdVend, aPeds, aJPeds, nRecPedOri)
	local nX		:= 0
	local nY		:= 0
	local oJson		:= nil
	local oJsonItens:= nil
	local aJsonItens:= {}
	local cCliLoja	:= ''
	
	default aPeds	:= {}
	default aJPeds	:= {}
	
	for nX	:= 1 to len(aPeds)
		oJson		:= JsonObject():new()
		aJsonItens	:= {}
		cCliLoja	:= AllTrim(GetNewPar( 'ZZ_TCLILOJ', '' , aPeds[nX,3]))
		oJson['C5_FILIAL'] 	:= aPeds[nX,1]
		oJson['C5_CLIENTE']	:= SubStr(cCliLoja,1,TamSX3("A1_COD")[1])
		oJson['C5_LOJACLI']	:= SubStr(cCliLoja,(TamSX3("A1_COD")[1]+1),(TamSX3("A1_COD")[1] + TamSX3("A1_LOJA")[1]))
		oJson['C5_X_IDVEN']	:= cIdVend
		oJson['REC_PED_ORI']:= nRecPedOri

		for nY := 1 to len(aPeds[nX, 2])
			oJsonItens	:= JsonObject():new()
			oJsonItens['C6_PRODUTO'] 	:= aPeds[nX, 2, nY, 01]
			oJsonItens['C6_ACONDIC'] 	:= aPeds[nX, 2, nY, 02]
			oJsonItens['C6_LANCES'] 	:= aPeds[nX, 2, nY, 03]
			oJsonItens['C6_METRAGE'] 	:= aPeds[nX, 2, nY, 04]
			oJsonItens['C6_QTDVEN'] 	:= aPeds[nX, 2, nY, 05]
			oJsonItens['C6_SEMANA']		:= aPeds[nX, 2, nY, 06]
			oJsonItens['C6_LOCAL']		:= aPeds[nX, 2, nY, 07]
			oJsonItens['C6_TES']		:= aPeds[nX, 2, nY, 08]
			oJsonItens['C6_NUMPCOM']	:= aPeds[nX, 2, nY, 10]
			oJsonItens['C6_ITEMPC']		:= aPeds[nX, 2, nY, 11]
			oJsonItens['C6_PRCVEN']		:= aPeds[nX, 2, nY, 12]
			aAdd(aJsonItens, oJsonItens)
			FreeObj(oJsonItens)
		next nY
		
		if !empty(aJsonItens)
			oJson['ITENS']	:= aJsonItens
		endif
		
		aAdd(aJPeds, oJson:toJson())
		FreeObj(oJson)
	next nX	
return(aJPeds)

static function updatePedOri(nRecC5, cIdVen, aItens)
	local aArea    	:= GetArea()
	local aAreaSC5	:= SC5->(getArea())
	local aAreaSC6	:= SC6->(getArea())
	local lRet 		:= .T.
	local nX		:= 0
	local oModel	:= nil
	local aErro		:= {}
	local cErro		:= ''
	
	dbselectArea('SC5')
	dbselectArea('SC6')
	
	oModel := FWLoadModel('cbcSC5Model')
	oModel:SetOperation(4)				
	SC5->(DbGoTo(nRecC5))
	oModel:Activate()		
	oModel:LoadValue('SC5MASTER','C5_X_IDVEN', cIdVen)
	if !(lRet := FWFormCommit(oModel))
		aErro := oModel:GetErrorMessage()
		if !empty(aErro)
			cErro += aErro[2] + '-'
			cErro += aErro[4] + '-'
			cErro += aErro[5] + '-'
			cErro += aErro[6] 
			Help( ,, cErro ,, 'Erro', 1,0)
		endif
	endif
	oModel:DeActivate()
	FreeObj(oModel)
	if lRet
		for nX := 1 to len(aItens)
			oModel := FWLoadModel('cbcSC6Model')
			oModel:SetOperation(4)				
			SC6->(DbGoTo(aItens[nX, 13]))
			oModel:Activate()		
			oModel:LoadValue('SC6MASTER','C6_SEMANA', 'TRIANG')
			if !(lRet := FWFormCommit(oModel))
				aErro := oModel:GetErrorMessage()
				if !empty(aErro)
					cErro += aErro[2] + '-'
					cErro += aErro[4] + '-'
					cErro += aErro[5] + '-'
					cErro += aErro[6] 
					Help( ,, cErro ,, 'Erro', 1,0)
				endif
			endif
			oModel:DeActivate()
			FreeObj(oModel)
			if !lRet
				EXIT
			endif
		next nX
	endif
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aArea)
return({lRet,cErro})

static function validResiduo(cIdVen)
	local lOk		:= .T.
	local cMsgErr	:= ''
	local oSql 		:= LibSqlObj():newLibSqlObj()
		
	oSql:newAlias(u_qryVldResiTriang(cIdVen))
	
	if oSql:hasRecords()
		lOk := .F.
		cMsgErr += "Pedidos com liberações." + CRLF +; 
					"Comunicar Expedição para estornar as Liberações nos pedidos:" + CRLF
		oSql:goTop()
		while oSql:notIsEof()
			cMsgErr += oSql:getValue("PEDIDO") + " - " + oSql:getValue("ITEM") + CRLF
			oSql:skip()
		endDo
	endif	
	oSql:close()
	FreeObj(oSql)
return({lOk, cMsgErr})

static function eliminaResiduo(cIdVen)
	local aArea    	:= GetArea()
	local aAreaSC5	:= SC5->(getArea())
	local aAreaSC6	:= SC6->(getArea())	
	local lOk		:= .T.
	local oFil		:= cbcFiliais():newcbcFiliais()
	local oSql 		:= LibSqlObj():newLibSqlObj()
	
	dbselectArea('SC5')
	dbselectArea('SC6')
	
	oSql:newAlias(u_qryResiTriang(cIdVen))
	
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			SC5->(dbGoTo(oSql:getValue("RECSC5")))
			SC6->(dbGoTo(oSql:getValue("RECSC6")))
			oFil:setFilial(SC5->(C5_FILIAL))
			if !(lOk := MaResDoFat())
				EXIT
			endif
			MaLiberOk({ SC5->C5_NUM }, .T.)
			oFil:backFil()
			oSql:skip()
		endDo
	endif
	
	oSql:close()
	FreeObj(oSql)
	FreeObj(oFil)
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aArea)
return(lOk)

static function errHandle(oErr, oSelf)
	oSelf:lMsg := .T.
	oSelf:setStatus(.F., oErr:Description, .F.) 
	oSelf:lMsg := .F.	
	if InTransact()
		DisarmTransaction()
	endif	
	
	if(oSelf:isLock())
		oSelf:libLocks()
	endif
	
	BREAK
return(nil)

/* TESTE ZONE */
user function tstTriangle(nRecC5) //tstTriangle(278548)
	local oTriang := ctrlTriangle():newctrlTriangle(nRecC5)
	oTriang:genPedDiv()
	//FWMsgRun(, 	{|| oTriang:eliminaResiduo()}, 'Triangulação', 'Processando...')
return(nil)
