#include "totvs.ch"
#include "rwmake.ch"
#include 'topconn.ch'
#include "tbiconn.ch"

class CbcOrderItem  

	data cSemana
	data cReserva
	data cProduto
	data cAcondic
	data nLances
	data nMetragem
	data nQtdVen
	data aNroBob
	data cNumero
	data cItem
	data cFil
	data cEnd
	data nQtdEmp
	data oUpdTab
	data nRecno
	data cC9Seq
	data cLocal
	data lIsReserve

	method newCbcOrderItem() constructor 
	method getC9Seq()
	method setC9Seq()
	method getRecno()
	method setRecno()
	method getLocal()
	method setLocal()
	method getSemana()
	method setSemana()
	method getReserva()
	method setReserva()
	method getProduto()
	method setProduto()
	method getAcondic()
	method setAcondic()
	method getLances()
	method setLances()
	method getMetragem()
	method setMetragem()
	method getQtdVen()
	method setQtdVen()
	method getNroBob()
	method setNroBob()
	method getNumero()
	method setNumero()
	method getItem()
	method setItem()
	method getFil()
	method setFil()
	method getEnd()
	method setEnd()
	method getQtdEmp()
	method setQtdEmp()
	method isReserve()
	method isFirstTime()
	method getUpdTab()

endclass


method newCbcOrderItem(nRecno,nC9Rec) class CbcOrderItem
	Local cTmpEnd	:= ""
	Default nRecno 	:= ''	
	::lIsReserve 	:= .T.
	::oUpdTab := ManBaseDados():newManBaseDados()
	
	If !Empty(nRecno)

		DbSelectarea("SC9")
		SC9->(dbgoto(nC9Rec))
		
		::setC9Seq(SC9->(C9_SEQUEN))
		
		DbSelectarea("SC6")
		SC6->(dbgoto(nRecno))
		
		If SC6->(!Eof())
			If Empty(SC6->(C6_ZZNRRES))
				
				::lIsReserve := .F.
			Else
				::setSemana(SC6->(C6_SEMANA))
				::setReserva(	SC6->(C6_ZZNRRES)							)
				::setProduto(	SC6->(C6_PRODUTO)							)
				::setAcondic(	SC6->(C6_ACONDIC)							)
				::setLances(	SC6->(C6_LANCES)							)
				::setMetragem(	SC6->(C6_METRAGE)							)
				::setQtdVen(	SC6->(C6_QTDVEN)							)
				::setNumero(	SC6->(C6_NUM)								)
				::setItem(		SC6->(C6_ITEM)								)
				::setFil(		SC6->(C6_FILIAL)							)
				::setLocal(		SC6->(C6_LOCAL)								)
		
				cTmpEnd	:= ( SC6->C6_ACONDIC + StrZero(SC6->C6_METRAGE,5) ) 
		
				::setEnd( Padr(cTmpEnd, TamSx3("BF_LOCALIZ")[1] ) ) 			
				::setRecno(nRecno)
		
				If SC6->(C6_ACONDIC) == 'B' .And. !Empty(SC6->(C6_ZZNRRES))
					::setNroBob(getNmbCoil(Self))
					::setQtdEmp(::getMetragem())
				Else
					::setQtdEmp( ::getMetragem()  * ::getLances() )
				EndIf
			Endif
		Else
			::lIsReserve := .F.
		EndIf
	
	Else
		::lIsReserve := .F.
	Endif

return self


method getC9Seq() class CbcOrderItem
return ::cC9Seq

method setC9Seq(cC9NumSeq) class CbcOrderItem
	::cC9Seq := cC9NumSeq 
return

method getRecno() class CbcOrderItem
return ::nRecno

method setRecno(nRec) class CbcOrderItem
	::nRecno := nRec
return

method getLocal() class CbcOrderItem
return ::cLocal

method setLocal(cInLocal) class CbcOrderItem
	::cLocal := cInLocal
return

method getSemana() class CbcOrderItem
return ::cSemana

method setSemana(Semana) class CbcOrderItem
	::cSemana = Semana
return

method getReserva() class CbcOrderItem
return ::cReserva

method setReserva(Reserva) class CbcOrderItem
	::cReserva = Reserva
return

method getProduto() class CbcOrderItem
return ::cProduto

method setProduto(Produto) class CbcOrderItem
	::cProduto = Produto
return

method getAcondic() class CbcOrderItem
return ::cAcondic

method setAcondic(Acondic) class CbcOrderItem
	::cAcondic = Acondic
return

method getLances() class CbcOrderItem
return ::nLances

method setLances(Lances) class CbcOrderItem
	::nLances = Lances
return

method getMetragem() class CbcOrderItem
return ::nMetragem

method setMetragem(Metragem) class CbcOrderItem
	::nMetragem = Metragem
return

method getQtdVen() class CbcOrderItem
return ::nQtdVen

method setQtdVen(QtdVen) class CbcOrderItem
	::nQtdVen = QtdVen
return

method getNroBob() class CbcOrderItem
return ::aNroBob

method setNroBob(aNroBob) class CbcOrderItem
	::aNroBob = aNroBob
return

method getNumero() class CbcOrderItem
return ::cNumero

method setNumero(Numero) class CbcOrderItem
	::cNumero = Numero
return

method getItem()	class CbcOrderItem
return ::cItem

method setItem(cItem)	class CbcOrderItem
	::cItem := cItem
return

method getFil() class CbcOrderItem
return ::cFil

method setFil(cFil) class CbcOrderItem
	::cFil := cFil
return

method getEnd() class CbcOrderItem
return ::cEnd

method setEnd(cEnd) class CbcOrderItem
	::cEnd := cEnd 
return

method getQtdEmp() class CbcOrderItem
return ::nQtdEmp

method setQtdEmp(QtdEmp) class CbcOrderItem
	::nQtdEmp := QtdEmp
return

method isReserve() class CbcOrderItem
return ::lIsReserve

method isFirstTime() class CbcOrderItem
return ( Empty(::getSemana()) .And. !Empty(::getReserva()) ) 

method getUpdTab()	class CbcOrderItem
return ::oUpdTab

static function getNmbCoil(oSelf)
	Local aNmbrCoil	:= {}
	Local cQuery	:= ""

	If Select( "Coil") > 0
		Coil->(dbcloseArea())
		FErase( "Coil" + GetDbExtension())
	End If

	cQuery := " SELECT ZE_NUMBOB AS NRO_BOBINA "
	cQuery += " FROM " + RETSQLNAME("SZE") + " SZE"
	cQuery += " WHERE ZE_FILIAL	IN	( '" + oSelf:getFil() + "' ) "
	
	If oSelf:isFirstTime()
	
		cQuery += " AND ZE_CTRLE =  '" + oSelf:getReserva() + "' "
	
	Else
	
		cQuery += " AND ZE_PEDIDO + ZE_ITEM =  ( '" + oSelf:getNumero() + oSelf:getItem()    + "' ) "     
		cQuery += " AND ZE_STATUS <> 'T' "
	
	EndIf
		
	cQuery += " AND ZE_PRODUTO	=  '" + oSelf:getProduto() + "' "   	
	cQuery += " AND 'B'+RIGHT(REPLICATE('0',5)+ CONVERT(VARCHAR(5),ZE_QUANT),5) = '" + oSelf:getEnd() + "' "
	cQuery += " AND SZE.D_E_L_E_T_	<>	'*' "

	cQuery := ChangeQuery(cQuery)

	TCQUERY cQuery NEW ALIAS "Coil"

	DbSelectArea("Coil")
	Coil->(DbGotop())

	While !Coil->(Eof())
		AAdd(aNmbrCoil, Coil->(NRO_BOBINA) )
		Coil->(DbSkip())
	EndDo

	If Select( "Coil") > 0
		Coil->(dbcloseArea())
		FErase( "Coil" + GetDbExtension())
	End If

return aNmbrCoil