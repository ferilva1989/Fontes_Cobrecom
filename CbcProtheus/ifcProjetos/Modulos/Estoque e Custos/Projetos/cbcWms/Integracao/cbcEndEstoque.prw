#include 'protheus.ch'

#define RECNO_SDA_DESTINO 1
#define LOCALIZ_ORIGEM_SDB 2
#define QUANT_ORIGEM_SDB 3
#define SALDO_ENDERECAR_DESTINO 4
#define RECNO_SDB_ORIGEM 5
#define ITEM_SDB_ORIGEM 6
#define ITEM_DESTINO 7
#define REC_SZE 8
#define QTD_SZE_ORIGEM 9
#define ACOND_SDB_ORIGEM 10
#define ID_VENDA 11
#define PEDIDO_VENDA 12
#define ITEM_VENDA 13
#define CRLF Chr(13)+Chr(10)

class cbcEndEstoque 

	data lOk
	data cErrMsg
	data aDoWork
	data cMsgDiv
	method newcbcEndEstoque() constructor
	method doEnder()
	method checkEnder() 

endclass


method newcbcEndEstoque() class cbcEndEstoque
	::aDoWork 	:= {}
	::lOk 		:= .T.
	::cErrMsg 	:= ''
	::cMsgDiv	:= ""
return(nil)


method doEnder(cChvNfe, lCanc) class cbcEndEstoque
	local lRet as boolean
	local oSql as object
	default lCanc := .F.
	default cChvNfe	:= ''
	if empty(cChvNfe)
		::lOk := .F.
		::cErrMsg := 'Chave NF não informada'
	else
		oSql 	:= LibSqlObj():newLibSqlObj()
		oSql:newAlias(u_zxQryEnd(cChvNfe, lCanc))
		if ! oSql:hasRecords()
			::lOk := .F.
			::cErrMsg := 'Nenhum registro foi retornado'
		else
			::aDoWork := {}
			oSql:goTop()
			while oSql:notIsEof()
				aadd(::aDoWork,{;
				oSql:getValue("RECNO_SDA_DESTINO"),;
				oSql:getValue("LOCALIZ_ORIGEM_SDB"),;
				oSql:getValue("QUANT_ORIGEM_SDB"),;
				oSql:getValue("SALDO_ENDERECAR_DESTINO"),;
				oSql:getValue("RECNO_SDB_ORIGEM"),;
				oSql:getValue("ITEM_SDB_ORIGEM"),;
				oSql:getValue("ITEM_DESTINO"),;
				oSql:getValue("REC_SZE"),;
				oSql:getValue("QTD_SZE_ORIGEM"),;
				oSql:getValue("ACOND_SDB_ORIGEM"),;
				oSql:getValue("ID_VENDA"),;
				oSql:getValue("PEDIDO_VENDA"),;
				oSql:getValue("ITEM_VENDA") })
				oSql:skip()   
			endDo
		endif	
		oSql:close()
		FreeObj(oSql)
		if !u_isAuto()
			if InTransact()
				FWMsgRun(, { |oSay| notTranEnd(self, oSay, lCanc) }, "Endereçamento", "Endereçando estoque...")
			else
				FWMsgRun(, { |oSay| inTranEnd(self, oSay, lCanc) }, "Endereçamento", "Endereçando estoque...")
			endif
		else
			if InTransact()
				notTranEnd(self, oSay, lCanc)
			else
				inTranEnd(self, oSay, lCanc)
			endif
		endif
	endif
return (self)

method checkEnder(cChvNfe) class cbcEndEstoque
	local oSql		:= nil
	Local oStatic   := IfcXFun():newIfcXFun()
	
	oSql 	:= LibSqlObj():newLibSqlObj()
	oSql:newAlias(oStatic:sP(1):callStatic('qryTransFil','qryVldEnd',cChvNfe)) //Avalia os endereços 
	if oSql:hasRecords()
		oSql:goTop()
		::cMsgDiv += "***DIVERGENCIAS DE ENDEREÇAMENTO***" + CRLF
		while oSql:notIsEof()
			::cMsgDiv += "NF/Serie NUM :" + Alltrim(oSql:getValue("NF"))
			::cMsgDiv += "/" + Alltrim(oSql:getValue("SERIE_NF")) + " - "
			::cMsgDiv += "Dt.Emissao: " + DtoC(StoD(oSql:getValue("EMISSAO_NF"))) +  " - "
			::cMsgDiv += "Item: " + Alltrim(oSql:getValue("ITEM_NF")) + " - "
			::cMsgDiv += "Produto: " + Alltrim(oSql:getValue("PRODUTO")) + " - "
			::cMsgDiv += "Qtde NF.: " + Alltrim(Transform(oSql:getValue("QTDE_NF"), '@E 99999999.99')) + " - "
			::cMsgDiv += "Qtde. N/Ender.: " + Alltrim(Transform(oSql:getValue("SALDO_AENDER"), '@E 99999999.99')) + CRLF
			oSql:skip()
		enddo
		::cMsgDiv += "***********************************" + CRLF
	endif
	oSql:Close()
	FreeObj(oSql)
	oSql 	:= LibSqlObj():newLibSqlObj()
	oSql:newAlias(oStatic:sP(1):callStatic('qryTransFil','qryDivBob',cChvNfe))//Avalia as bobinas
	if oSql:hasRecords()
		oSql:goTop()
		::cMsgDiv += "***DIVERGENCIAS DE BOBINAS***" + CRLF
		while oSql:notIsEof()
			::cMsgDiv += "Produto: " + Alltrim(oSql:getValue("NOTA_PRODUTO")) + " - "
			::cMsgDiv += "Acondic.:" + Alltrim(oSql:getValue("NOTA_ACOND")) + " - "
			::cMsgDiv += "Qtd. NF.: " + Alltrim(Transform(oSql:getValue("NOTA_QTD"), '@E 99999999.99')) + " - "
			::cMsgDiv += "Qtd. Bob.:" + Alltrim(Transform(oSql:getValue("QTD_SZE"), '@E 99999999.99')) + CRLF
			oSql:skip()	
		enddo
		::cMsgDiv += "***********************************" + CRLF
	endif
	oSql:Close()
	FreeObj(oSql)
return(self)


static function inTranEnd(oSelf, oSay, lCanc)
	BEGIN TRANSACTION
		doEnd(oSelf, oSay, lCanc)
		if !oSelf:lOk
			DisarmTransaction()
		endif
	END TRANSACTION
return(nil)


static function notTranEnd(oSelf, oSay, lCanc)
	doEnd(oSelf, oSay, lCanc)
return (nil)


static function doEnd(oSelf, oSay, lCanc)
	local nX 		as numeric
	local aCabSDA 	as array
	local aItSDB	as array
	local aConfig	as array
	local nQtd		as numeric
	local aDaItm	as array
	local cItm		as string
	default oSay 	:= nil
	default lCanc	:= .F.
	updSay(oSay, 'Iniciando Endereçamento')
	DbSelectArea('SDA')
	aDaItm := {}
	for nX := 1 to len(oSelf:aDoWork)
		aCabSDA := {}
		aItSDB 	:= {}
		if oSelf:aDoWork[nX][SALDO_ENDERECAR_DESTINO] > 0 .Or. lCanc
			if oSelf:aDoWork[nX][SALDO_ENDERECAR_DESTINO] >= oSelf:aDoWork[nX][QUANT_ORIGEM_SDB] .Or. lCanc
				if lCanc
					aConfig :={"S ", 4}
				else
					aConfig :={" ", 3}
				endif
				SDA->(DbGoTo(oSelf:aDoWork[nX][RECNO_SDA_DESTINO]))

				if(oSelf:aDoWork[nX][ACOND_SDB_ORIGEM] == 'B' )
					if oSelf:aDoWork[nX][REC_SZE] == 0
						loop
					else
						nQtd := oSelf:aDoWork[nX][QTD_SZE_ORIGEM]
					endif
				else
					nQtd := oSelf:aDoWork[nX][QUANT_ORIGEM_SDB]
				endif

				aCabSDA  := {{"DA_PRODUTO" ,SDA->DA_PRODUTO , nil},;
				{"DA_QTDORI"  ,SDA->DA_QTDORI              , nil},;
				{"DA_SALDO"   ,SDA->DA_SALDO               , nil},;
				{"DA_DATA"    ,SDA->DA_DATA                , nil},;
				{"DA_LOCAL"   ,SDA->DA_LOCAL               , nil},;
				{"DA_DOC"     ,SDA->DA_DOC                 , nil},;
				{"DA_ORIGEM"  ,SDA->DA_ORIGEM              , nil},;
				{"DA_NUMSEQ"  ,SDA->DA_NUMSEQ              , nil},;
				{"DA_QTSEGUM" ,SDA->DA_QTSEGUM             , nil},;
				{"DA_QTDORI2" ,SDA->DA_QTDORI2             , nil}}

				if lCanc
					cItm := oSelf:aDoWork[nX]['ITEM_SDB_ORIGEM']
				else
					cItm := getItm(@aDaItm, SDA->(recno()))
				endif
				
				aItSDB := {{{"DB_ITEM"	  , cItm								,Nil},;
				{"DB_ESTORNO"  	,aConfig[1]	      	  							,Nil},;
				{"DB_LOCALIZ"  	,oSelf:aDoWork[nX][LOCALIZ_ORIGEM_SDB]  		,Nil},;
				{"DB_DATA"	  	,dDataBase    	  								,Nil},;
				{"DB_QUANT"  	,nQtd  											,Nil}}}

				updSay(oSay, 'Preparando Item ' + cValToChar(oSelf:aDoWork[nX][ITEM_DESTINO]))
				makeExec(aCabSDA, aItSDB, oSelf, aConfig[2])
				if ! oSelf:lOk
					updSay(oSay, 'Erro no endereçamento! ')
					exit
				else
					if(oSelf:aDoWork[nX][ACOND_SDB_ORIGEM] == 'B' )
						if lCanc
							updSay(oSay, 'Excluindo Bobinas ' + cValToChar(oSelf:aDoWork[nX][ITEM_DESTINO]))
							delBob(oSelf:aDoWork[nX][REC_SZE], oSelf)
							if !oSelf:lOk 	  		 
								exit
							endif
						else
							updSay(oSay, 'Preparando Bobinas ' + cValToChar(oSelf:aDoWork[nX][ITEM_DESTINO]))
							makeBob(oSelf,;
							oSelf:aDoWork[nX][REC_SZE],; 
							FwFilial(),;
							oSelf:aDoWork[nX][ID_VENDA],;
							oSelf:aDoWork[nX][PEDIDO_VENDA],;
							oSelf:aDoWork[nX][ITEM_VENDA],;
							SDA->(DA_NUMSEQ))
						endif
					endif
				endif
			else
				oSelf:lOk 	  := .F.
				oSelf:cErrMsg := 'Saldo a endereçar SDA -> ' + cValToChar(SDA->(Recno())) + ' insulficiente para SDB -> '+;
				cValToChar(oSelf:aDoWork[nX][RECNO_SDB_ORIGEM])
				exit
			endif
		else
			oSelf:lOk 	  := .F.
			oSelf:cErrMsg := 'Sem Saldo para endereçar SDA -> ' + cValToChar(SDA->(Recno())) 
			exit
		endif
	next nX
return(nil)


static function delBob(nRecBob, oSelf)
	DbSelectArea('SZE')
	SZE->(DbGoTo(nRecBob))
	if (SZE->(RecLock("SZE", .F.)))
		SZE->(dbDelete())
		SZE->(MsUnLock())
	else
		oSelf:lOk 	  	:= .F.
		oSelf:cErrMsg	:= "Bobina " + SZE->(ZE_NUMBOB) + " não estornada"
	endif
return(nil)


static function getItm(aDaItm, nRec)
	local citm 	:= '0001'
	local nPos	:= 0
	if (nPos := AScan(aDaItm,{|a| a[1] == nRec })) > 0
		aDaItm[nPos][2] := Soma1(aDaItm[nPos][2])
		cItm := aDaItm[nPos][2]
	else
		aadd(aDaItm, {nRec, citm})
	endif
return(cItm)


static function makeBob(oSelf, nRecSZE, cFl, cIdVen, cPedDes, cItmDest, cSeqOrig)
	local lOk		:= .T.
	local aCfgFld	:= {}
	local cCli		:= ''
	local cLoj		:= ''
	local cNomCli	:= ''
	local cDest		:= ''
	local oSql 		:= nil
	local nNewRec	:= 0
	default oSelf	:= nil
	default cFl		:= FwFilial()
	default cIdVen	:= ''
	default cPedDes	:= '000001'
	default cItmDest:= '99'
	default cSeqOrig:= ''

	dbSelectArea('SZE')
	dbSelectArea('SC5')
	dbSelectArea('SA1')

	SZE->(DbGoTo(nRecSZE))
	if !empty(cIdVen)
		oSql 		:= LibSqlObj():newLibSqlObj()
		oSql:newTable("SC5", "R_E_C_N_O_ REC ", "C5_FILIAL = '" + cFl +"' AND  C5_X_IDVEN = '" + cIdVen + "'")
		if oSql:hasRecords()
			SC5->(DbGoTo(oSql:getValue("REC")))
			cCli := SC5->(C5_CLIENTE)
			cLoj := SC5->(C5_LOJACLI)
			oSql:close()
			oSql:newTable("SA1", "A1_NOME NOME, A1_MUN MUN, A1_EST EST ",;
			"A1_FILIAL = '" + xFilial('SA1') + "'" +;
			"AND A1_COD = '"+ cCli + "' " +;
			"AND A1_LOJA = '"+ cLoj + "' ") 
			if oSql:hasRecords()
				cNomCli := oSql:getValue('NOME')
				cDest 	:= AllTrim(oSql:getValue('MUN')) + " - " + oSql:getValue('EST') 
			endif
		endif
		oSql:close()
		FreeObj(oSql)
	endif

	aadd(aCfgFld, {'ZE_PEDIDO', iif(empty(cIdVen),'000001', cPedDes)})
	aadd(aCfgFld, {'ZE_ITEM',   iif(empty(cIdVen),'99', cItmDest)})
	aadd(aCfgFld, {'ZE_CLIENTE',cCli})
	aadd(aCfgFld, {'ZE_LOJA',   cLoj})
	aadd(aCfgFld, {'ZE_NOMCLI',cNomCli})
	aadd(aCfgFld, {'ZE_DESTINO',cDest})
	aadd(aCfgFld, {'ZE_NOME',   'AUTOTRAN'})
	aadd(aCfgFld, {'ZE_FUNC',   '000000'})
	aadd(aCfgFld, {'ZE_BOBORIG',SZE->(ZE_FILIAL) + SZE->(ZE_NUMBOB)})
	aadd(aCfgFld, {'ZE_DOC',    ''})
	aadd(aCfgFld, {'ZE_SERIE',  ''})
	aadd(aCfgFld, {'ZE_NUMSEQ',  ''})
	aadd(aCfgFld, {'ZE_SEQOS',  ''})
	aadd(aCfgFld, {'ZE_DATA',   dDataBase})
	aadd(aCfgFld, {'ZE_DTPES',  dDataBase})
	aadd(aCfgFld, {'ZE_HRPES', Left(TIME(),Len(SZE->ZE_HRPES))})
	aadd(aCfgFld, {'ZE_STATUS', iif(empty(cIdVen),'T', 'P')})
	aadd(aCfgFld, {'ZE_FILORIG', SZE->(ZE_FILIAL)}) 
	aadd(aCfgFld, {'ZE_SEQORIG', cSeqOrig})
	nNewRec := u_cbcChngFil('SZE', nRecSZE, cFl,aCfgFld, 1)
	if !empty(nNewRec)
		ExpedIntegra(nNewRec)
	endif
return(lOk)


static function makeExec(aHead, aItm, oSelf, nOpc)
	local oExec	as object
	local aRet as array
	default nOpc := 3
	oExec := cbcExecAuto():newcbcExecAuto(aItm,aHead,.F.)
	oExec:exAuto('MATA265',nOpc)
	aRet := oExec:getRet()
	if !aRet[1]
		oSelf:lOk  		:= .F.
		oSelf:cErrMsg 	:= aRet[2]
	else
		oSelf:lOk  		:= .T.
		oSelf:cErrMsg 	:= ''
	endif
	FreeObj(oExec)
return(nil)


static function updSay(oSay, cText)
	if oSay != nil
		oSay:settext(cText)
		oSay:ctrlrefresh()
		ProcessMessage()
	endif
return(nil)


static function ExpedIntegra(nNewRec)
	local aArea    	:= GetArea()
	local aAreaSZE	:= SZE->(GetArea())
	local oInt 		:= cbcExpIntegra():newcbcExpIntegra(.F.)
	default nNewRec	:= 0
	if !empty(nNewRec)
		oInt:addProd('SZE', nNewRec, .T.)
	endif
	FreeObj(oInt)
	RestArea(aAreaSZE)
	RestArea(aArea)
return(nil)

/* TEST ZONE */
user function zzEndEst(cChv) // u_zzEndEst('50191002544042000208550010000638051100056787')
	local oEnd as object
	default cChv := ''
	if !empty(cChv)
		oEnd := cbcEndEstoque():newcbcEndEstoque()
		// Endereçar
		oEnd:doEnder('50191002544042000208550010000638051100056787', .F.)
		if oEnd:lOk
			msgInfo('OK', 'OK')
		else
			alert(oEnd:cErrMsg)
		endif
		// Estornar
		oEnd:doEnder('50191002544042000208550010000638051100056787', .T.)
		if oEnd:lOk
			msgInfo('OK', 'OK')
		else
			alert(oEnd:cErrMsg)
		endif
		FreeObj(oEnd)
	endif
return(nil)
