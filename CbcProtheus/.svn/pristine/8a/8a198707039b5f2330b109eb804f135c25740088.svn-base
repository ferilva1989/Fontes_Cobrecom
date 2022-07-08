#include 'protheus.ch'
#Include 'statusPedido.ch'
static  cSemNom	:= (FwFilial() + 'Empenho')
static lEmpenha	:= GetNewPar('ZZ_NEWEMP', .F. )

class cbcLibEmp from cbcMethUtils
	data lOk
	data cMsgErro
	data oGenMdl
	data oHashMrk
	data cId
	data cPedFilter
	data lHaveErr
	data aErro
	data nPercDes
	data lAuto
	data aPrioPed
	data cTxtTotal

	method newcbcLibEmp() constructor 
	method initLibView()

	method autoWay()
	method CancAutoWay()

	method isOk()
	method getMsgErr()
	method setStatus()
	method wipeMyButt()

	method doMark()
	method procMark()
	method undoMark()
	method setNotif()
	method showNot()

	method retSelf()
	method getId()
	method setInternal()

endclass


method newcbcLibEmp() class cbcLibEmp
	iniSetup(@self)
return (self)


method isOk() class cbcLibEmp
return(::lOk)


method getMsgErr() class cbcLibEmp
return(::cMsgErro)


method setStatus(lSts, cMsg, lEx) class cbcLibEmp
	private lException	:= .F.
	default lSts		:= .T.
	default cMsg 		:= ''
	default lEx			:= .F.
	::lOk				:= lSts
	if !lException
		if !lSts
			cMsg := ('[cbcLibEmp]-' + cMsg)
		endif
		::cMsgErro	:= cMsg
		if lEx
			lException := .T.
			UserException(cMsg)
		endif
	endif
return(self)


method wipeMyButt() class cbcLibEmp
	FreeObj(::oGenMdl )
return(nil)


method initLibView() class cbcLibEmp
	::lHaveErr 	:= .F.
	if ! MayIUseCode(cSemNom)
		::setNotif('Aviso','Rotina não permite multiplos acessos!!')
	else
		if !lEmpenha
			::setNotif('Aviso','Rotina em homologação não realiza empenhos!!')
		endif
		::setInternal('Rotina iniciada pelo usuario ' + UsrRetName(RetCodUsr()))
		U_cbcLibEmpDash(@self)
		Leave1Code(cSemNom)
	endif
return(self)


method CancAutoWay(aRecSC9,aOnlAcond) class cbcLibEmp
	local aMainArea		:= defArea({'SC5', 'SC6', 'SC9', 'SDC', 'SZE', 'ZZ9'})
	local nY			:= 0
	local aOnlyPed		:= {}
	local nPointer		:= 0
	local nTotItem		:= 0
	local aTmp			:= {}
	local aFinal		:= {}
	default aOnlAcond	:= .F.

	if !lEmpenha
		::setNotif('Aviso','Rotina em homologação não realiza empenhos nem cancelamentos!!')
		return(self)
	endif

	::lAuto	 := .T.	
	::setNotif('LogEmp','Processo de Cancelamento em lote iniciado!',{},.F.,,.T.)
	// Array aRecSDC vem ordenador pelo recno do SC5 .
	// aRecSDC[nX,1] = 'REC_SC5'
	// aRecSDC[nX,2] = 'REC_SC9'
	nTotItem := len(aRecSC9)
	for nY := 1 to nTotItem
		aadd(aOnlyPed, aRecSC9[nY])
		if ( nY < nTotItem )
			if (aRecSC9[(nY+1),1] ) <> aRecSC9[nY,1]
				markCanc(aOnlyPed, self, aOnlAcond)	
				aOnlyPed := {}
			endif
		else
			markCanc(aOnlyPed, self, aOnlAcond)		
		endif
	next nY

	::setNotif('LogEmp','Processo de Cancelamento em lote encerrado!',{},.F.,,.T.)
	::showNot(.T.)
	defArea(,.T.,aMainArea)
	::lAuto	 := .F.
return(self)


method autoWay(aRecPed,lOnlyBob) class cbcLibEmp
	local aMainArea		:= defArea({'SC5', 'SC6', 'SC9', 'SDC', 'SZE'})
	local aAuxArea		:= {}
	local nX			:= 0
	local nY			:= 0
	local cStsPed		:= ''
	local lTemBobina	:= .F.
	local lTemOutros	:= .F.
	local aBobinaRec	:= {}
	local aOutrosRec	:= {}
	local cKey			:= ''
	local aValue		:= {}
	local nQtdLiber 	:= 0
	local oStatus		:= cbcCtrStatus():newcbcCtrStatus()
	local cChvPLC		:= ''
	local cTxtLog		:= ''
	local cTxtItmLog	:= ''
	Local oStatic    	:= IfcXFun():newIfcXFun()
	default lOnlyBob	:= .F.

	if !lEmpenha
		::setNotif('Aviso','Rotina em homologação não realiza empenhos nem cancelamentos!!')
		return(self)
	endif
	
	::lAuto	 := .T.
	for nX := 1 to len(aRecPed)
		Begin Transaction
			aAuxArea := defArea({'SC5', 'SC6', 'SC9', 'SDC', 'SZE'})
			SC5->(DbGoTo(aRecPed[nX]))
			cTxtLog := SC5->('Filial: ' + C5_FILIAL +  ' Pedido: ' + C5_NUM)
			::setNotif('LogEmp','Realizando marca',{{'INFO', cTxtLog}},.F.,,.T.)
			oStatus:setMaster('SC5', SC5->(Recno()), ::getId()) 
			if oStatus:lvlCompare(LIBERADO_SEPARACAO, '>=')
				::setNotif('LogEmp','Pedido com empenhos liberados para proximas etapas!!',{{'INFO',cTxtLog}},.F.,,.T.)
			else	
				cStsPed := u_vLERpeSld(SC5->(Recno()))
				if cStsPed == "BR_AMARELO"
					::setNotif('LogEmp','Nenhum item deste pedido esta bloqueado estoque',{{'INFO', cTxtLog}},.F.,,.T.)
				else
					if cStsPed == "BR_VERMELHO"
						::setNotif('LogEmp', 'Estoque não atende pedido( ' + cTxtLog + ' ), que será liberado parcialmente conforme estoque disponivel!', {},.F.,,.T.)
					endif
					// Verifica se faz somente bobina ou faz tudo
					if !lOnlyBob
						// Tudo que não é Bobina
						aOutrosRec := u_zLOutPed(SC5->(C5_NUM))
						for nY := 1 to len(aOutrosRec)
							dbselectArea('SC9')
							SC9->(DbGoTo(aOutrosRec[nY,1]))
							SC6->(DbGoTo(aOutrosRec[nY,2]))
							cTxtItmLog	:= SC9->(C9_PEDIDO + C9_ITEM + cValToChar(Recno()))
							::setNotif('LogEmp', 'Selecionando Itens SC9!', {{'INFO', cTxtItmLog }},.F.,,.T.)
							cKey 	:= 'SC9' + cValToChar(SC9->(Recno()))
							u_zLEmpEnv(self, SC9->(Recno()))
							cChvPLC := SC9->(C9_PRODUTO)+ SBF->(BF_LOCALIZ)
							if empty(nQtdLiber 	:= oStatic:sP(1):callStatic('cbcLibEmpSrv', 'sldItmPed', self))
								::setNotif('LogEmp', 'Sem saldo em estoque!', {{'INFO', cTxtItmLog}},.F.,,.T.)
								LOOP
							endif
							aValue		:= {'SC9', nQtdLiber, SC9->(Recno()),cChvPLC}
							if !::doMark({cKey , aValue} ):isOk()
								::setNotif('LogEmp', 'Erro ao marcar itens!',{{'INFO', cTxtItmLog}},.F.,,.T.)
							else
								lTemOutros := .T.
							endif
						next nY
						if lTemOutros
							::setNotif('LogEmp', 'Processar itens marcados que não são bobinas!', {{'INFO', cTxtLog}},.F.,,.T.)
							::procMark('LIB_LIBERAR')
						else
							::setNotif('LogEmp', 'Outros acondicinamento, nada disponivel para liberação!', {{'INFO', cTxtLog}},.F.,,.T.)
						endif
					endif
					// Bobinas, este sempre deve realizar, a questão é se é exclusivo ou não
					aBobinaRec 	:= u_zLBobPed(SC5->(C5_NUM),self)
					::setNotif('LogEmp', 'Encontrada ' + cValToChar(len(aBobinaRec)) + ' bobina(s)', {{'INFO', cTxtLog}},.F.,,.T.)
					for nY := 1 to len(aBobinaRec)
						dbselectArea('SZE')
						SZE->(DbGoTo(aBobinaRec[nY]))
						cTxtItmLog := SZE->('Filial: ' + ZE_FILIAL + ' Pedido: ' + ZE_PEDIDO +  ' Item: ' + ZE_ITEM + ' Bobina: ' +  ZE_NUMBOB + 'Recno: ' + cValToChar(Recno()))
						if oStatic:sP(1):callStatic('cbcLibEmpDash', 'vldBobina') == 1
							::setNotif('LogEmp', 'Selecionando Itens SZE!',{{'INFO', cTxtItmLog }},.F.,,.T.)	
							cKey 		:= 'SZE' + cValToChar(SZE->(Recno()))
							nQtdLiber 	:= 1
							cChvPLC 	:= SZE->(ZE_PEDIDO + ZE_ITEM)
							aValue		:= {'SZE', nQtdLiber, SZE->(Recno()), cChvPLC}
							if !::doMark({cKey , aValue} ):isOk()
								::setNotif('Bobina', 'Erro ao selecionar Bobina!',{{'ERR', cTxtItmLog}},.F.,,.T.)
							else
								lTemBobina := .T.
							endif
						endif
					next nY
					if lTemBobina
						::setNotif('LogEmp', 'Processando as bobinas marcadas!',{{'INFO', cTxtLog}},.F.,,.T.)
						::procMark('LIB_BOB')
					else
						::setNotif('LogEmp', 'Nenhuma bobina pesada para o pedido!',{{'INFO', cTxtLog}},.F.,,.T.)
					endif
				endif

				::setNotif('LogEmp','Final Empenho',{{'INFO', cTxtLog}},.F.,,.T.)
				defArea(,.T.,aAuxArea)
			endif
		End Transaction
	next nX
	defArea(,.T.,aMainArea)
	FreeObj(oStatus)
	::showNot(.T.)
	::lAuto	 := .F.
return(self)


method retSelf(cValue) class cbcLibEmp
	cValue := self
return(nil)


method undoMark(cAls, cFldMrk, cKey) class cbcLibEmp
	if !lEmpenha
		::setNotif('Aviso','Rotina em homologação não realiza empenhos nem cancelamentos!!')
		return(self)
	endif
	if RecLock(cAls)
		(cAls)->(&cFldMrk) := ''
		(cAls)->(MsUnlock())
	endif
	::doMark({cKey})
return(self)


method doMark(aHM) class cbcLibEmp
	local xValue	:= {}
	default aHM 	:= {}
	if !lEmpenha
		::setNotif('Aviso','Rotina em homologação não realiza empenhos nem cancelamentos!!')
		return(self)
	endif
	::setStatus()
	if  HMGet( ::oHashMrk , aHM[1] , @xValue )
		HMDel(::oHashMrk, aHM[1])
	else
		HMAdd(::oHashMrk,aHM)
	endif
return(self)


method showNot(lClear) class cbcLibEmp
	local oEditor	:= nil
	local oNotDlg	:= nil
	local cTitle	:= 'Notificações da Rotina'
	local lOkB		:= .T.
	local lCancB	:= .T.
	local nFormat	:= 2 // 1=html, 2=text
	local lROnly	:=  .F. // !FwIsAdmin()
	local aCoors	:= {}
	local nX		:= 0
	local nY		:= 0
	local cText		:= ''
	local cLInha		:= (Chr(13) + Chr(10))
	default lClear 	:= .T.
	if !empty(::aErro)
		DEFINE MSDIALOG oNotDlg PIXEL FROM 10,0 TO 500,660
		aCoors := FWGetDialogSize(oNotDlg)
		oEditor := FWSimpEdit():New(aCoors[1], aCoors[2],(aCoors[3]/8), (aCoors[4]/8) , cTitle, '', nFormat , lOkB, lCancB, oNotDlg , lROnly) 
		cText += 'Sessão: ' + ::getId()  +   ' ' + cLinha
		for nX	:= 1 to len(::aErro)
			cText += ::aErro[nX, 1] + '  '
			if !empty(::aErro[nX, 2])
				for nY := 1 to len(::aErro[nX, 2])
					cText += ::aErro[nX, 2, nY, 1]  + ' - ' + ::aErro[nX, 2, nY, 2] + cLinha + '  '
				next nY 
			endif
		next nX
		oEditor:SetText(cText)
		// SaveToPdf()
		ACTIVATE MSDIALOG oNotDlg CENTERED
		if lClear
			::aErro := {}
		endif
		FreeObj(oEditor)
	endif
return(self)


method setNotif(cNoti, cTit,aDiver, lScreen, lErro, lAutoWay) class cbcLibEmp
	default lScreen 	:= .T.
	default lErro		:= .T.
	default lAutoWay	:= .F.
	default aDiver		:= {}
	aadd(::aErro,{cTit, aDiver } )
	if lScreen
		if !::lAuto
			if lErro
				Help( ,, cNoti ,, cTit, 1,0)
			else
				MsgInfo(cNoti, cTit )
			endif
		endif
	else
		// Apenas realiza o Log
	endif
return(self)


method getId() class cbcLibEmp
return(::cId)


method setInternal(cConteudo) class cbcLibEmp
	default cConteudo := ''
	if !empty(cConteudo)
		cConteudo := "[empenho]- " + cConteudo
		FWMonitorMsg(cConteudo )
		Conout(cConteudo)
	endif
return(self)


// TODO 02 definir as ações para todas as opções
method procMark(cOpc, xParam) class cbcLibEmp
	local aElmMark 	:= {}
	local nX		:= 0
	local aAreas	:= defArea({'SZE', 'SDC', 'SC5', 'SC6', 'SC9'})
	default xParam	:= nil
	::setStatus()
	// Opções que não precisam de registros marcados
	if cOpc == 'PED_CALC'
		FWMsgRun(,{|oSay|resumoPed(self)},	"Calculando","Obtendo resumo do pedido...")
	elseif cOpc == 'LIB_BOBINAS'
		FWMsgRun(,{|oSay|checkBobina(self,xParam)},"Aguarde...", "Inicio Liberação bobinas...")
	elseif cOpc == 'EST_SIT'
		FWMsgRun(,{|oSay|resumoEst(self)},	"Aguarde...", "Resumo Estoque...")
		// Opções onde é necessario registros marcados
	elseif ( HMList( ::oHashMrk, @aElmMark ) )
		if empty(aElmMark)
			::setNotif('LogEmp', 'Processamento de marcação sem registro marcado!',{},.F.,,.T.)
		else
			if cOpc == 'SC9_CANC'
				FWMsgRun(, { |oSay| cancLib(@aElmMark,self,oSay) }, 	"Aguarde...", "Cancelando liberação...")
			elseif cOpc == 'EMP_CANC'
				FWMsgRun(, { |oSay| cancLibEmp(@aElmMark,self,oSay) }, 	"Aguarde...", "Cancelando empenho...")
			elseif cOpc == 'LIB_LIBERAR'
				FWMsgRun(, { |oSay| initLibEmp(@aElmMark,self, oSay) }, "Aguarde...", "Liberando...")
			elseif cOpc == 'PED_SIMUL'
				FWMsgRun(, { |oSay| Alert('oi') }, 						"Simulação", "Simulando empenhos e liberações...")
			elseif cOpc == 'PED_AUTOM'
				FWMsgRun(, { |oSay| msgInfo('Libera Automatico') }, 	"Aguarde...", "Liberando automatico...")
			elseif cOpc == 'LIB_BOB'
				FWMsgRun(,{|oSay|initBobEmp(@aElmMark,self,oSay)},		"Aguarde...", "Liberando bobinas...")
			elseif cOpc == 'CLR_BOB'
				FWMsgRun(,{|oSay|msgInfo('Cancelar marcados bobina')},	"Aguarde...", "Limpando marcações...")
			endif
		endif
	else
		::setNotif('LogEmp', 'Problemas  obter hash de marcação!',{},.F.,,.T.)
	endif
	defArea(,.T.,aAreas)
return(self)


static function cancLib(aElmMark,oSelf, oSay)
	local nX 			:= 0
	local cRecC9		:= 0
	local cSpace 		:= ''
	local cSpaceCR		:= ''
	local cAliasRecn	:= ''
	local cFilter		:= ''
	local oSql 			:= nil
	local oStatus 		:= cbcCtrStatus():newcbcCtrStatus()
	local aValor		:= {}
	local cTxtLogok		:= ''
	default oSay		:= nil
	
	if !lEmpenha
		oSelf:setNotif('Aviso','Rotina em homologação não realiza empenhos nem cancelamentos!!')
		return(nil)
	endif
	
	Begin Transaction
		for nX := 1 to len(aElmMark)
			if aElmMark[nX,2,1,2,1] == 'SC9'
				SC9->( DbGoTo(aElmMark[nX,2,1,2,3]) )
				cTxtLogok := SC9->('Filial: ' + C9_FILIAL + ' Pedido: ' + C9_PEDIDO + ' Item: ' + C9_ITEM)
				cAliasRecn := 'SC9' + cValToChar(SC9->(Recno()))
				// Partindo do SC9 posiciona em todas as tabelas envolvidas
				u_zLEmpEnv(oSelf, SC9->(Recno()),,.T.)
				u_zLUpdSay(oSay, 'Obtendo lock dos arquivos: ' + cTxtLogok )
				if !u_zLECtrLk('SC9')
					oSelf:setNotif('LogEmp','Não obtido exclusividade nos arquivos',{{'ERR',cTxtLogok}},.F.,,.T.)		
					u_zLUpdSay(oSay, 'Não obtido exclusividade nos arquivos: ' + cTxtLogok )
					DisarmTransaction()
					Break
				else
					u_zLUpdSay(oSay, 'Cancelando Pedido: ' + cTxtLogok)
					oStatus:setMaster('SC5', SC5->(Recno()), oSelf:getId()) 
					cRecC9 := SC9->(Recno())
					// Realiza o cancelamento
					if ! u_zCEmSC9(oSelf, @oStatus)
						oSelf:setNotif('LogEmp','Item não cancelado, disarmando transação, verificar!',{{'ERR',cTxtLogok}},.F.,,.T.)
						DisarmTransaction()
						Break
					endif
					// Desfaz as marcas existentes
					oSelf:undoMark('SC9', 'C9_OK', cAliasRecn)
					u_zLUpdSay(oSay, 'Concluido cancelamento Pedido: ' + cTxtLogok)
					oSelf:setNotif('LogEmp','Concluido cancelamento do item',{{'INFO',Alltrim(cTxtLogok)}},.F.,,.T.)
				endif
			endif
		next nX
	End Transaction

	FreeObj(oStatus)
return(nil)


static function cancLibEmp(aElmMark,oSelf, oSay)
	local nX 			:= 0
	local cRecC9		:= 0
	local nRecDC		:= 0
	local cSpace 		:= ''
	local cSpaceCR		:= ''
	local cAliasRecn	:= ''
	local cFilter		:= ''
	local oSql 			:= nil
	local oStatus 		:= cbcCtrStatus():newcbcCtrStatus()
	local aValor		:= {}
	local cTxtLogok		:= ''
	default oSay		:= nil
	if !lEmpenha
		oSelf:setNotif('Aviso','Rotina em homologação não realiza empenhos nem cancelamentos!!')
		return(nil)
	endif
	
	Begin Transaction
		for nX := 1 to len(aElmMark)
			if aElmMark[nX,2,1,2,1] == 'SDC'
				SDC->( DbGoTo(aElmMark[nX,2,1,2,3]) )
				cTxtLogok := SDC->('Filial: ' + DC_FILIAL + ' Pedido: ' +  DC_PEDIDO + ' Item: ' +  DC_ITEM)
				cAliasRecn := 'SDC' + cValToChar(SDC->(Recno()))
				oSql := LibSqlObj():newLibSqlObj()
				cSpace 	 := Space(TamSx3('C9_BLEST')[1])
				cSpaceCR := Space(TamSx3('C9_BLCRED')[1])
				cRecC9 	:= oSql:getFieldValue("SC9", "R_E_C_N_O_",;
				"%SC9.XFILIAL% " +;
				" AND C9_PEDIDO    = '" + SDC->(DC_PEDIDO) 	+ "' " 	+;
				" AND C9_ITEM      = '" + SDC->(DC_ITEM) 	+ "' "  +;
				" AND C9_SEQUEN    = '" + SDC->(DC_SEQ) 	+ "' "  +;
				" AND C9_PRODUTO   = '" + SDC->(DC_PRODUTO) + "' " 	+; 
				" AND C9_BLEST     = '" + cSpace + "' "  	+ ;
				" AND C9_BLCRED    = '" + cSpaceCR + "' " 	+;
				" AND SC9.R_E_C_N_O_ = SC9.R_E_C_N_O_" ) 
				oSql:Close()
				FreeObj(oSql)
				if !empty(cRecC9)
					// Partindo do SC9 posiciona em todas as tabelas envolvidas
					u_zLEmpEnv(oSelf, cRecC9,,.T.)
					u_zLUpdSay(oSay, 'Obtendo lock dos arquivos: ' + cTxtLogok)
					if !u_zLECtrLk('SDC')
						oSelf:setNotif('LogEmp','Não obtido exclusividade nos arquivos',{{'ERR', cTxtLogok}},.F.,,.T.)		
						u_zLUpdSay(oSay, 'Não obtido exclusividade nos arquivos: ' + cTxtLogok )
						DisarmTransaction()
						Break
					else
						u_zLUpdSay(oSay, 'Cancelando Pedido: ' + cTxtLogok)
						oStatus:setMaster('SC5', SC5->(Recno()), oSelf:getId()) 
						nRecDC := SDC->(Recno())
						// Realiza o cancelamento obtendo recno do C9 permaneceu liberado para proximo rodada
						if !u_zCEmEst(oSelf, @oStatus)
							oSelf:setNotif('LogEmp','Erro na liberação SC9 divergencia de valores!',{{'ERR', cTxtLogok}},.F.,,.T.)
							DisarmTransaction()
							Break
						endif
						// Desfaz as marcas existentes
						oSelf:undoMark('SDC', 'DC_OK', cAliasRecn)
						u_zLUpdSay(oSay, 'Concluido cancelamento Pedido: ' + cTxtLogok)
						oSelf:setNotif('LogEmp','Concluido cancelamento do item',{{'INFO',Alltrim(cTxtLogok)}},.F.,,.T.)
					endif
				else
					oSelf:setNotif('LogEmp','Registro SC9 não encontrado.',{{'INFO',cTxtLogok}},.F.,,.T.)
					u_zLUpdSay(oSay, 'Erro ao cancelar: ' + cTxtLogok)
					DisarmTransaction()
					Break
				endif
			endif
		next nX
	End Transaction

	FreeObj(oStatus)
return(nil)


static function initBobEmp(aElmMark,oSelf, oSay)
	local nX 			:= 0
	local nAliasRecn	:= ''
	local oStatus 		:= cbcCtrStatus():newcbcCtrStatus()
	local cTxtLogok		:= ''
	default oSay		:= nil
	if !lEmpenha
		oSelf:setNotif('Aviso','Rotina em homologação não realiza empenhos nem cancelamentos!!')
		return(nil)
	endif
	Begin Transaction
		for nX := 1 to len(aElmMark)
			if aElmMark[nX,2,1,2,1] == 'SZE'   
				SZE->( DbGoTo(aElmMark[nX,2,1,2,3]) )
				cTxtLogok := SZE->('Filial: ' + ZE_FILIAL +  ' Pedido: ' + ZE_PEDIDO +  ' Item: ' + ZE_ITEM + ' Bobina: ' + ZE_NUMBOB +  ' Recno: ' + cValToChar(Recno()))
				u_zLEmBEnv(oSelf,aElmMark[nX,2,1,2,3])
				if !u_zLECtrLk('SC9')
					oSelf:setNotif('LogEmp','Não obtido exclusividade nos arquivos',{{'INFO',cTxtLogok}},.F.,,.T.)
					u_zLUpdSay(oSay, 'Não obtido exclusividade nos arquivos: ' + cTxtLogok)
					DisarmTransaction()
					Break
				else
					u_zLUpdSay(oSay, 'Inicio da liberação do Pedido: ' + cTxtLogok)
					oStatus:setMaster('SC5', SC5->(Recno()), oSelf:getId()) 
					cAliasRecn := 'SZE' + cValToChar(SZE->(Recno()))
					u_zLEmEst(oSelf, SZE->(ZE_QUANT),@oStatus)
					oSelf:undoMark('SZE', 'ZE_OK', cAliasRecn)
					u_zLUpdSay(oSay, 'Fim da  liberação do Pedido: ' + cTxtLogok)
					oSelf:setNotif('LogEmp','Concluido liberação SZE',{{'INFO',Alltrim(cTxtLogok)}},.F.,,.T.)
				endif
			endif
		next nX
	End Transaction

	FreeObj(oStatus)
return(nil)


static function initLibEmp(aElmMark,oSelf, oSay)
	local nX 			:= 0
	local cAliasRecn	:= ''
	local oStatus 		:= cbcCtrStatus():newcbcCtrStatus()
	local cTxtLogok		:= ''
	default oSay		:= nil
	if !lEmpenha
		oSelf:setNotif('Aviso','Rotina em homologação não realiza empenhos nem cancelamentos!!')
		return(nil)
	endif
	Begin Transaction
		for nX := 1 to len(aElmMark)
			if aElmMark[nX,2,1,2,1] == 'SC9'
				SC9->( DbGoTo(aElmMark[nX,2,1,2,3]) )
				cTxtLogok := SC9->('Filial: ' + C9_FILIAL + ' Pedido: ' + C9_PEDIDO + ' Item: ' +  C9_ITEM)
				// Realiza todos os posicionamento partindo Recno SC9
				u_zLEmpEnv(oSelf, aElmMark[nX,2,1,2,3])
				u_zLUpdSay(oSay, 'Obtendo lock dos arquivos: ' + cTxtLogok)
				if !u_zLECtrLk('SC9')
					::setNotif('LogEmp','Não obtido exclusividade nos arquivos',{{'INFO',cTxtLogok}},.F.,,.T.)
					u_zLUpdSay(oSay, 'Não obtido exclusividade nos arquivos: ' + cTxtLogok)
					DisarmTransaction()
					Break
				else
					u_zLUpdSay(oSay, 'Inicio da liberação do Pedido: ' + cTxtLogok)
					oStatus:setMaster('SC5', SC5->(Recno()), oSelf:getId()) 
					cAliasRecn := 'SC9' + cValToChar(SC9->(Recno()))
					// Realiza a liberação
					u_zLEmEst(oSelf, aElmMark[nX,2,1,2,2],@oStatus)
					// Desmarca o Registro
					oSelf:undoMark('SC9', 'C9_OK', cAliasRecn)
					u_zLUpdSay(oSay, 'Fim da liberação do Pedido: ' + cTxtLogok)
					oSelf:setNotif('LogEmp','Concluido liberação SC9',{{'INFO',Alltrim(cTxtLogok)}},.F.,,.T.)
				endif
			endif
		next nX
	End Transaction
	FreeObj(oStatus)
return(nil)


static function checkBobina(oSelf, xParam)
	local aParamBox	:= {}
	local aRet		:= {}
	SC5->(DbGoTo(xParam))
	aadd(aParamBox,{3,"Bobinas para:",1,{"Pedido " + SC5->(C5_NUM),"Todos os Pedidos"},90,"",.F.} )
	if ParamBox(aParamBox,"Filtro de bobinas...",@aRet)
		if aRet[1] == 1
			U_vLELibBob(SC5->(Recno()), oSelf)
		else
			U_vLELibBob(,oSelf)
		endif
	endif
return(nil)


static function resumoEst(oself)
	u_vLEResEst(oself)
return(nil)


static function resumoPed(oSelf)
	u_vLEResPed(SC5->(Recno()),oSelf)
return(nil)


static function markCanc(aOnlyPed, oSelf, aOnlAcond)
	local aAuxArea		:= {}
	local lRet			:= .F.
	local nX			:= 0
	local cRecC9		:= 0
	local cChvPLC		:= ''
	local cKey			:= ''
	local aValue		:= {}
	local nQtdLiber 	:= 0
	local oStatus		:= cbcCtrStatus():newcbcCtrStatus()
	default aOnlyPed	:= {}
	default aOnlAcond	:= {}
	if !lEmpenha
		oSelf:setNotif('Aviso','Rotina em homologação não realiza empenhos nem cancelamentos!!')
		return(nil)
	endif
	if empty(aOnlAcond)
		oSelf:setNotif('LogEmp','Nenhum acondicionamento selecionado para cancelamento!!',;
		{{'INFO'}},.F.,,.T.)
	else
		for nX := 1 to len(aOnlyPed)
			aAuxArea 	:= defArea({'SC5', 'SC6', 'SC9', 'SDC', 'SZE', 'ZZ9'})
			SC5->(DbGoTo(aOnlyPed[nX, 1]))
			cRecC9		:= aOnlyPed[nX,2]
			u_zLEmpEnv(oSelf, cRecC9,,.T.)
			oSelf:setNotif('LogEmp',SC5->('Filial: ' + C5_FILIAL + ' Pedido: ' + Alltrim(C5_NUM)) +  'Item: ' + SC9->(C9_ITEM),{},.F.,,.T.)
			oStatus:setMaster('SC5', SC5->(Recno()), oSelf:getId()) 
			if oStatus:lvlCompare(LIBERADO_SEPARACAO, '>=')
				oSelf:setNotif('LogEmp','Pedido com empenhos liberados para proximas etapas!!',;
				{{'INFO', Alltrim(SC5->('Filial: ' + C5_FILIAL + ' Pedido: ' + C5_NUM))}},.F.,,.T.)
			elseif Ascan(aOnlAcond, {|acond| acond == SC6->(C6_ACONDIC) } ) == 0
				oSelf:setNotif('LogEmp','Acondicionamento não selecionado!!',;
				{{'INFO', Alltrim(SC9->('Filial: ' + C9_FILIAL + ' Pedido: ' + C9_PEDIDO + ' Item: ' + C9_ITEM))}},.F.,,.T.)
			else
				cKey 	:= 'SC9' + cValToChar(SC9->(Recno()))
				aValue	:= {'SC9', nQtdLiber, SC9->(Recno()),cChvPLC}
				if !oSelf:doMark({cKey , aValue} ):isOk()
					oSelf:setNotif('LogEmp', 'Erro ao marcar registro de empenho!',;
					{{'INFO', SC9->('Filial: ' + C9_FILIAL + ' Pedido: ' + C9_PEDIDO +  ' Recno SC9: ' + cValToChar(Recno()))}},.F.,,.T.)
				else
					lRet := .T.
				endif
			endif

			defArea(,.T.,aAuxArea)	
		next nX
		if lRet
			oSelf:setNotif('LogEmp','Inicio processamento dos registros marcados ',{{'INFO',Alltrim(SC5->('Filial: ' + C5_FILIAL + ' Pedido: ' + C5_NUM))}},.F.,,.T.)
			oSelf:procMark('SC9_CANC')
			oSelf:setNotif('LogEmp','Fim processamento dos registros marcados',{{'INFO',Alltrim(SC5->('Filial ' + C5_FILIAL + ' Pedido: ' + C5_NUM))}},.F.,,.T.)
		endif
	endif
	FreeObj(oStatus)
return(lRet)


static function defArea(aAlias, lRestArea, aAreas)
	local nX 			:= 0
	local aRet			:= {}
	default lRestArea	:= .F.
	default aAreas		:= {}	
	if lRestArea
		for nX := Len(aAreas) to 1 step -1 
			RestArea(aAreas[nX])
		next nX	
	else
		aadd(aRet, getArea())
		for nX := 1 to Len(aAlias)
			aadd(aRet,(aAlias[nX])->(getArea()))
		next nX
	endif
return(aRet)


static function iniSetup(oSelf)
	oSelf:oHashMrk		:= HMNew()
	oSelf:setStatus()
	oSelf:oGenMdl 		:= cbcGenModel():newcbcGenModel()
	oSelf:newcbcMethUtils()
	oSelf:cId			:= ( Alltrim(RetCodUsr()) + Dtos(Date()) + StrTran(time(), ":", "") )
	oSelf:cPedFilter	:= ''
	oSelf:lHaveErr 		:= .F.
	oSelf:aErro			:= {}
	oSelf:nPercDes		:= 0
	oSelf:lAuto			:= .F.
	oSelf:aPrioPed		:= {}
	oSelf:cTxtTotal		:= ''
return(nil)


static function HandleEr(oErr, oSelf)
	local cErro	:=  "[LogEmp-ErrHnd - "+DtoC(Date())+" - "+Time()+" ] "+ '[ERRO]' + oErr:Description + ' [FROM] ' + ProcName(3)
	DisarmTransaction()
	ConOut(cErro)
	oSelf:setNotif('', cErro,{},.F.,,.T.)
	oSelf:lHaveErr := .T.
	oSelf:showNot(.T.)
	BREAK
return (nil)
