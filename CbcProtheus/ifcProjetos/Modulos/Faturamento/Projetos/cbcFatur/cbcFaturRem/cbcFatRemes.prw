#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} cbcFatRemes
//TODO Monta NF de Espelho quando Cliente de Entrega diferente do Cliente Faturamento.
@author juliana.leme
@since 18/06/2019
@version 1.0
@param nRecSF2, numeric, descricao
@param aRecSD2, array, descricao
@type function
/*/
user function cbcFatRemes(nRecSF2, aRecSD2,cSerie)
	local cbcArea		:= GetArea()
	local cMsgLog		:= ""
	private oControle	:= cbcFatRemesCtrle():newcbcFatRemesCtrle()
	
	//Posiciona as tabelas
	DbSelectArea("SF2")
	SF2->(DbSetOrder(1))
	SF2->(DbGoTo(nRecSF2))
	DbSelectArea("SD2")
	SD2->(DbSetOrder(1))
	SD2->(DbGoTo(aRecSD2[1]))
	if oControle:RetCliLojRemes(SD2->D2_PEDIDO)
		while empty(oControle:cProxDoc)
			//oControle:cSerie := cSerie
			oControle:ProxNumDoc(cSerie)
		enddo
		oControle:MontaCabec(nRecSF2)
		oControle:MontaItems(aRecSD2)
		if len(oControle:aCabecalho) > 0 .and. len(oControle:aItems) > 0
			begin transaction
				oControle:MontaNFEspelho()
				if !oControle:aRetNFEspelho[2]
					cMsgLog := oControle:aRetNFEspelho[1]
					aRetorno := {.F.,oControle:aRetNFEspelho[3],cMsgLog}
					DisarmTransaction()
				else
					aRetorno := {.T.,oControle:aRetNFEspelho[3],cMsgLog}
				endif
			end Transaction
		else
			cMsgLog := "Não encontrado os itens dos Recnos Fornecidos. NF não concluida!"
			aRetorno := {.F.,"",cMsgLog}
		endif
	else
		cMsgLog	:= "ERRO!! Cliente de Remessa não encontrado ou bloqueado. Favor reanalisar o pedido!!"
		MsgInfo(cMsgLog)
		aRetorno := {.F.,cMsgLog}
		DisarmTransaction()
	endif
	FreeObj(oControle)
	RestArea(cbcArea)
return(aRetorno)

user function tstzonerem()
	local aRecD2 	:= {3755552,3755553,3755554,3755555,3755556,3755557,3755558,3755559,3755560,;
						3755561,3755562,3755563}
	local nRecF2	:= 377690	
	u_cbcFatRemes(nRecF2, aRecD2)
return()