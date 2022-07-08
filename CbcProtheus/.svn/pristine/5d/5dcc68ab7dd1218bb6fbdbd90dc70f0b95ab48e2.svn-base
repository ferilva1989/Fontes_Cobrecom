#Include 'Protheus.ch'
#include "topconn.ch"


user function getCtrle()
	local cCtrle	:= ''
	
return(cCtrle)


user function VlOsAtZn(cFl,cNrPed)  // u_VlOsAtZn('01','203189')
	local aArea		:= getArea()
	local cQuery		:= ''
	local cSeqAtu		:= ''
	local cApelido	:= ''
	local aSeqAnt		:= {}
	local lRet		:= .F.
	default cFl 		:= FwFilial()
	default cNrPed	:= ''
	
	if ! empty(cNrPed)
		cSeqAtu := u_SqOsFrDc(cFl,cNrPed)
		cQuery += " SELECT "
		cQuery += "  ZN_SEQOS "
		cQuery += " FROM " +  RetSqlName('SZN')
		cQuery += " WHERE "
		cQuery += "  ZN_FILIAL = '" + cFl + "'"
		cQuery += "  AND ZN_PEDIDO = '" + cNrPed + "'"
		cQuery += "  AND D_E_L_E_T_ <> '*' "
		cQuery += " GROUP BY ZN_SEQOS "
		cQuery += " ORDER BY ZN_SEQOS ASC "
		
		cQuery 	:= ChangeQuery(cQuery)
		cApelido := GetNextAlias()
		MPSysOpenQuery(cQuery, cApelido)
		if Select(cApelido) > 0
			DbSelectArea(cApelido)
			(cApelido)->(DbGoTop())
			While !((cApelido)->(EOF()))
				aadd(aSeqAnt,(cApelido)->(ZN_SEQOS))
				(cApelido)->(DBSkip())
			endDo
			(cApelido)->(dbCloseArea())
			if empty(aSeqAnt)
				lRet := .T.
			else
				lRet := !( Ascan(aSeqAnt, {|x| Alltrim(x) == Alltrim(cSeqAtu)}) > 0 )
			endif
		endif
	endif
	RestArea(aArea)
return(lRet)


user function SqOsFrDc(cFl,cNrPed) // u_SqOsFrDc('01','203189')
	local aArea		:= getArea()
	local cQuery		:= ''
	local cApelido	:= ''
	local nRegs		:= 0
	local aRet		:= {}
	local cRet		:= ''
	local aTmp		:= {}
	default cFl 		:= FwFilial()
	default cNrPed	:= ''
	if !empty(cNrPed)
		cQuery += " SELECT "
		cQuery += "	SC9.C9_SEQOS "
		cQuery += " FROM " + RetSQLName("SDC")+ " SDC "
		cQuery += " INNER JOIN " + RetSQLName("SC9")  + " SC9 "
		cQuery += "	ON SDC.DC_FILIAL		= SC9.C9_FILIAL "
		cQuery += "	AND SDC.DC_PEDIDO		= SC9.C9_PEDIDO "
		cQuery += "	AND SDC.DC_ITEM		= SC9.C9_ITEM "
		cQuery += "	AND SDC.D_E_L_E_T_	= SC9.D_E_L_E_T_ "
		cQuery += " WHERE "
		cQuery += "	SDC.DC_FILIAL = '" + cFl + "' "
		cQuery += "	AND SDC.DC_LOCAL NOT IN ('10') "
		cQuery += "	AND SDC.DC_ORIGEM = 'SC6'"
		cQuery += "	AND SDC.DC_PEDIDO = '" + cNrPed + "' "
		cQuery += "	AND SDC.D_E_L_E_T_ <> '*' "
		cQuery += "	GROUP BY SC9.C9_PEDIDO, SC9.C9_SEQOS "
		cQuery += "	ORDER BY SC9.C9_PEDIDO, SC9.C9_SEQOS ASC "
		
		cQuery 	:= ChangeQuery(cQuery)
		cApelido := GetNextAlias()
		MPSysOpenQuery(cQuery, cApelido)
		if Select(cApelido) > 0
			DbSelectArea(cApelido)
			count to nRegs
			aadd(aRet, nRegs)
			(cApelido)->(DbGoTop())
			While !((cApelido)->(EOF()))
				aadd(aTmp,(cApelido)->(C9_SEQOS))
				cRet := (cApelido)->(C9_SEQOS)
				(cApelido)->(DBSkip())
			endDo
			(cApelido)->(dbCloseArea())
			aadd(aRet,aTmp)
		endif
	endif
	RestArea(aArea)
return(cRet)


user function MngSc9Ctr(cNroPedido,cItem,cSeq)
	local aArea	:= getArea()
	local lRet	:= .F.
	local cCtrle	:= ''
	
	DbSelectArea("SZN")
	SZN->(DbOrderNickName('PEDSEQ')) //ZN_FILIAL+ZN_PEDIDO+ZN_ITEM+ZN_SEQOS
	DbSelectArea('SC9')
	SC9->(DbSetOrder(1))
	
	cCtrle 		:= SZN->(ZN_CTRLE)
	cNroPedido 	:= Padr(cNroPedido,TamSx3('ZN_PEDIDO')[1])
	cItem 		:= Padr(cItem,TamSx3('ZN_ITEM')[1])
	cSeq 		:= Padr(cSeq,TamSx3('ZN_SEQOS')[1])
	
	if SZN->(DbSeek(xFilial("SZN") + cNroPedido + cItem + cSeq,.F.))
		
		cNroPedido 	:= Padr(cNroPedido,TamSx3('C9_PEDIDO')[1])
		cItem 		:= Padr(cItem,TamSx3('C9_ITEM')[1])
		cSeq 		:= Padr(cSeq,TamSx3('C9_SEQOS')[1])
		if SC9->(DbSeek(xFilial('SC9') + cNroPedido + cItem , .F.))
			while xFilial('SC9') == SC9->(C9_FILIAL) .and. SC9->(C9_PEDIDO) == cNroPedido .and. SC9->(C9_ITEM) == cItem .and. SC9->(!Eof())
				if SC9->(C9_SEQOS) == cSeq
					if SC9->( RecLock('SC9',.F.) )
						SC9->(C9_CTRLE) := SZN->(ZN_CTRLE)
						SC9->(MsUnlock())
					endif
				endif
				SC9->(DbSkip())
			enddo
		endif
	endif
	RestArea(aArea)
return(lRet)


user function delFrmPed(cPed)
	local aArea 		:= getArea()
	local aCtrList	:= {}
	local nX			:= 0
	local cCtr		:= ''
	local cSeq		:= ''
	DbSelectArea("SZN")
	SZN->(DbSetOrder(6)) // ZN_FILIAL, ZN_CTRLE, ZN_SEQOS, ZN_PEDIDO, ZN_ITEM
	DbSelectArea('SC9')
	SC9->(DbSetOrder(1))
	DbSelectArea('SF2')
	SF2->(DbSetOrder(10)) // F2_FILIAL, F2_CDCARGA, F2_SERIE, F2_DOC
	BEGIN TRANSACTION
		cPed 	:= Padr(cPed,TamSx3('C9_PEDIDO')[1])
		if SC9->(DbSeek(xFilial('SC9') + cPed, .F.))
			while ( xFilial("SC9") == SC9->(C9_FILIAL) ) .and. ( SC9->(C9_PEDIDO) == cPed )  .and. SC9->(!eof())
				if empty( SC9->(C9_NFISCAL) )
					if SC9->( RecLock('SC9',.F.) )
						if Empty(Ascan(aCtrList,{|aLst|  aLst[1] == SC9->(C9_CTRLE) .and. aLst[2] == SC9->(C9_SEQOS)}))
							if ! empty(SC9->(C9_CTRLE))
								aadd(aCtrList,{SC9->(C9_CTRLE), SC9->(C9_SEQOS)})
							endif
						endif
						SC9->(C9_CTRLE)	:= ''
					endif
				endif
				SC9->(DbSkip())
			enddo
		endif
		
		for nX := 1 to len(aCtrList)
			cCtr 	:= Padr(aCtrList[nX,1],TamSx3('ZN_CTRLE')[1])
			cSeq		:= Padr(aCtrList[nX,2],TamSx3('ZN_SEQOS')[1])
			if SZN->(DbSeek(xFilial("SZN") + cCtr ,.F.))
				while ( xFilial("SZN") == SZN->(ZN_FILIAL) ) .and. ( SZN->(ZN_CTRLE) == cCtr )  .and. SZN->(!eof())
					if SZN->(ZN_SEQOS) == cSeq
						if SZN->(RecLock("SZN",.F.))
							SZN->(DbDelete())
							SZN->(MsUnLock())
						endif
					endif
					SZN->(DbSkip())
				enddo
			endif
		next nX
	END TRANSACTION
	RestArea(aArea)
return(nil)



/* TEST ZONE */
