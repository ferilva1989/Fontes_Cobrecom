#include 'protheus.ch'
#include 'parmtype.ch'

//Constantes
#Define STR_ENT		Chr(13)+Chr(10)

/*/{Protheus.doc} cbcSrvAltTriangle
//TODO Função para aleração de um pedido de venda com amarração em outras filiais.
@author juliana.leme
@since 22/01/2020
@version 1.0
@param nRecC5, numeric, Recno SC5 Pedido Original
@type function
/*/
user function cbcSrvAltTriangle(nRecC5)
	local oTriang 	:= ctrlTriangle():newctrlTriangle(nRecC5)
	local aRet		:= {}
	local bErro		:= ErrorBlock({|oErr| errHandle(oErr, @aRet)})
	
	BEGIN SEQUENCE
		if (oTriang:setLocks():isOk())
			begin transaction
				aRet := vldAltTriang(oTriang:cIdVend,nRecC5)//Valida antes se os pedidos estão dispostos a seren alterados/excluidos
				if aRet[1]
					If MsgYesNo("Confirma Alteração do pedido? Os Pedidos de Transferencia das filiais serão excluidos!")
						if deletePedFil(oTriang:cIdVend, nRecC5)[1] //Deleta Pedidos das filiais de transferecia que houverem
							if updPedOri(nRecC5)[1] //Atualiza Pedido da Filial
								if updItmOri(nRecC5)[1]
									aRet := {.T., "Pedido liberado para alteração"}
								else
									aRet := {.F.,"Erro na atualização dos Itens do Pedido. Processo Não realizado"}
									disarmTransaction()
								endif
							else
								aRet := {.F.,"Pedido Original não pode ser atualizado, Processo Não realizado"}
								disarmTransaction()
							endif
						else
							aRet := {.T., "Pedido NÃO liberado para alteração"}
							disarmTransaction()
						endif
					else
						aRet := {.F., "Operação Cancelada pelo Usuario. processo NAO realizado!"}
					endif
				else
					disarmTransaction()
				endif
			end transaction
		else //Não deu Lock
			aRet := {.F., "Operação não concluida. Registro em uso."}
		endif
		oTriang:libLocks()
	RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
	FreeObj(oTriang)
	if !empty(aRet[2])
		EecView(aRet[2],"Log dos impedimentos do Pedido de Venda")
	endif
return(aRet)

/*/{Protheus.doc} vldAltTriang
//TODO Valida em todos os pedidos amarrados pelo IDVen 
		se a alteração podera ser efetuada conforme regras.
@author juliana.leme
@since 22/01/2020
@version 1.0
@param cIdVen, characters, IDVEN Conforme C5_X_IDVEN
@param nRecC5, numeric, Recno C5 Pedido Original
@type function
/*/
static function vldAltTriang(cIdVen, nRecC5)
	local cbcaArea 	:= GetArea()
	local aRet		:= {} 
	local cMsg		:= ""
	local lRet		:= .T.
	local oSql		:= LibSqlObj():newLibSqlObj()
	default cIdVen	:= ""
	default nRecC5	:= 0 //recno pedido Original
	
	dbselectArea('SC5')
	dbselectArea('SC6')
	oSql:newAlias(u_qryAltertriang(cIdven)) 
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			SC5->(dbGoTo(oSql:getValue("RECSC5"))) //Posiciona nos Pedidos com cIdVen
			SC6->(dbGoTo(oSql:getValue("RECSC6")))
			SC9->(dbGoTo(oSql:getValue("RECSC9")))
			if (SC6->C6_QTDENT > 0)
				lRet	:= .F.
				cMsg 	+= "Pedido: " + SC6->C6_NUM + " Item: "  + SC6->C6_ITEM + " FATURADO, não pode ser ALTERADO!" + STR_ENT
			elseif (SC6->C6_QTDEMP > 0) 
				if (SC9->C9_BLEST== "02") .and. empty(SC9->C9_BLCRED)
					if ! estLiberC6(oSql:getValue("RECSC5"),nRecC5) //Tenta estornar liberações
						lRet := .F.
						cMsg += "Pedido: " + SC6->C6_NUM + " Item: "  + SC6->C6_ITEM + " EMPENHADO, não pode ser ALTERADO! Verifique junto a Expedição!" + STR_ENT
					endif
				else
					lRet := .F.
					cMsg += "Pedido: " + SC6->C6_NUM + " Item: "  + SC6->C6_ITEM + " EMPENHADO, não pode ser ALTERADO! Verifique junto a Expedição!" + STR_ENT
				endif
			endif
			if (!empty(SC6->C6_SEMANA) .and. (!SC6->C6_SEMANA $ ("TRIANG "))) .and. (SC5->C5_DTPCP <> dDataBase)
				lRet := .F.
				cMsg += "Pedido: " + SC6->C6_NUM + " Item: "  + SC6->C6_ITEM + " EM PRODUÇÃO, não pode ser ALTERADO! Verificar junto ao PCP!" + STR_ENT
			endif
			oSql:skip()
		enddo
	else
		lRet	:= .F.
		cMsg 	:= "Nenhum pedido encontrado com o ID Informado! Verifique a informação!" + CLR
	endif
	aRet := {lRet,iif(empty(cMsg),"Pedido liberado para alteração",cMsg)}
	oSql:close()
	FreeObj(oSql)
	RestArea(cbcaArea)
return(aRet)

/*/{Protheus.doc} deletePedFil
//TODO Deleta Pedidos de Amarração para liberar Pedido Original de alteração.
@author juliana.leme
@since 22/01/2020
@version 1.0
@param cIdVen, characters, ID Ven para buscar pedidos amarrados
@param nRecC5, numeric, RECNO C5 do pedido original
@type function
/*/
static function deletePedFil(cIdVen, nRecC5)
	local cbcaArea 	:= GetArea()
	local cFilCbc 	:= cFilAnt
	local aCabec 	:= {}
	local oSql				:= LibSqlObj():newLibSqlObj()
	private	lMsErroAuto		:= .F.
	private lMsHelpAuto		:= .T.
	private lAutoErrNoFile	:= .T.
	private lIsJobAuto		:= .T.
	default cIdVen			:= ""
	default nRecC5			:= 0

	dbselectArea('SC5')
	oSql:newAlias(u_qryRetSC5Triang(cIdVen))	
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			if nRecC5 <> oSql:getValue("RECSC5") // Não é o pedido Original
				SC5->(DbGoTo(oSql:getValue("RECSC5")))
				cFilAnt := SC5->C5_FILIAL
				aAdd( aCabec, {"C5_NUM"			, SC5->C5_NUM		, Nil} )
				aAdd( aCabec, {"C5_TIPO"     	, SC5->C5_TIPO		, Nil} )
				aAdd( aCabec, {"C5_CLIENTE"     , SC5->C5_CLIENTE	, Nil} )
				aAdd( aCabec, {"C5_LOJACLI"     , SC5->C5_LOJACLI	, Nil} )
				aAdd( aCabec, {"C5_LOJAENT"     , SC5->C5_LOJAENT	, Nil} )
				aAdd( aCabec, {"C5_CONDPAG"     , SC5->C5_CONDPAG	, Nil} )
				lMsErroAuto := .F.
				MATA410(aCabec, {} , 5)
				if lMsErroAuto
					aErro 	:= GetAutoGrLog()					
					aRet := {.F.,aErro}
					Exit
				else
					aRet := {.T.,{"Concluido com sucesso!"}}
				endif
			endif
			aCabec := {}
			oSql:Skip()
		enddo
	endif
	oSql:Close()
	FreeObj(oSql)
	cFilAnt	:= cFilCbc
	RestArea(cbcaArea)
return(aRet)

/*/{Protheus.doc} estLiberC6
//TODO Estorna os pedidos amarrados para possibilitar a exclusão.
@author juliana.leme
@since 22/01/2020
@version 1.0
@param nRecAtualC5, numeric, Recno SC5 de liberação
@param nRecOriC5, numeric, Recno C5 Pedido Orginal
@type function
/*/
static function estLiberC6(nRecAtualC5,nRecOriC5)
	local cbcaArea		:= GetArea()
	local lRet			:= .T.
	local ccbcFil		:= cFilAnt
	default nRecAtualC5	:= 0
	default nRecOriC5	:= 0

	if nRecAtualC5 <> nRecOriC5
		cFilAnt := SC6->C6_FILIAL
		dbSelectArea("SC9")
		SC9->(dbSetOrder(1))
		If MsSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM)
			lRet := SC9->(a460Estorna())
		else 	
			lRet := .F.
		endif
		cFilAnt := ccbcFil
	endif
	RestArea(cbcaArea)
return(lRet)

/*/{Protheus.doc} updPedOri
//TODO Altera o campo C5_X_IDVEn para que possa ser realizada 
		a alteração pelo departamento comercial.
@author juliana.leme
@since 22/01/2020
@version 1.0
@param nRecSC5, numeric, Recno SC5 Pedido Original
@type function
/*/
static function updPedOri(nRecSC5)
	local aArea    	:= GetArea()
	local aRet 		:= {.T.,{}}
	local oModel	:= nil
	local aErro		:= {}
	local cErro		:= ''
	
	dbselectArea('SC5')
	
	oModel := FWLoadModel('cbcSC5Model')
	oModel:SetOperation(4)				
	SC5->(DbGoTo(nRecSC5))
	oModel:Activate()		
	oModel:LoadValue('SC5MASTER','C5_X_IDVEN', "")
	if !(lRet := FWFormCommit(oModel))
		aErro := oModel:GetErrorMessage()
		if !empty(aErro)
			cErro += aErro[2] + '-'
			cErro += aErro[4] + '-'
			cErro += aErro[5] + '-'
			cErro += aErro[6] 
			Help( ,, cErro ,, 'Erro', 1,0)
		endif
		aRet	:= {.F.,aErro}
	endif
	oModel:DeActivate()
	FreeObj(oModel)
	RestArea(aArea)
return(aRet)

static function updItmOri(nRecSC5)
	local aArea    	:= GetArea()
	local aAreaSC6 	:= SC6->(GetArea())
	local aRet 		:= {.T.,{}}
	local oSql		:= LibSqlObj():newLibSqlObj()
	Local oStatic   := IfcXFun():newIfcXFun()
	local oModel	:= nil
	local aErro		:= {}
	local cErro		:= ''
		
	oSql:newAlias(oStatic:sP(1):callStatic('qryTriangle', 'qryItmRec', nRecSC5))	
	if oSql:hasRecords()
		oSql:goTop()
		while oSql:notIsEof()
			dbselectArea('SC6')			
			oModel := FWLoadModel('cbcSC6Model')
			oModel:SetOperation(4)				
			SC6->(DbGoTo(oSql:getValue('RECSC6')))
			oModel:Activate()
			oModel:LoadValue('SC6MASTER','C6_SEMANA', "")
			if !(lRet := FWFormCommit(oModel))
				aErro := oModel:GetErrorMessage()
				if !empty(aErro)
					cErro += aErro[2] + '-'
					cErro += aErro[4] + '-'
					cErro += aErro[5] + '-'
					cErro += aErro[6] 
					Help( ,, cErro ,, 'Erro', 1,0)
				endif
				aRet	:= {.F.,aErro}
				EXIT
			endif
			oModel:DeActivate()
			FreeObj(oModel)
			oSql:Skip()
		endDo
	endif
	oSql:Close()
	FreeObj(oSql)
	RestArea(aAreaSC6)
	RestArea(aArea)
return(aRet)


/*/{Protheus.doc} errHandle
//TODO Static para trativa de erros.
@author juliana.leme
@since 22/01/2020
@version 1.0
@param oErr, object, descricao
@param oSelf, object, descricao
@type function
/*/
static function errHandle(oErr, oSelf)
	oSelf:setStatus(.F., oErr:Description, .T.) 		
	if InTransact()
		DisarmTransaction()
	endif		
	if(oSelf:isLock())
		oSelf:libLocks()
	endif
	
	BREAK
return(nil)

/*/{Protheus.doc} xxTstAltPedTriang
//TODO Test Zone.
@author juliana.leme
@since 22/01/2020
@version 1.0
@param nRecC5, numeric, descricao
@type function
/*/
user function xxTstAltPedTriang(nRecC5) //u_xxTstAltPedTriang(278469)
	ccbcFil	:= cFilAnt
	cFilAnt := "03"
	u_cbcSrvAltTriangle(nRecC5)
	cFilAnt := ccbcFil
return
