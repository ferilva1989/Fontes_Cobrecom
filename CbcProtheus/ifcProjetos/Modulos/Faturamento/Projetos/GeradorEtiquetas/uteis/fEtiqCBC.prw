#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} fEtiqCBC
//TODO Função principal que faz as devidas analises e mandar imprimir a etiqueta..
@author juliana.leme
@since 04/01/2019
@version 1.0
@param nRecPed, numeric, RECNO do pedido
@param cItemPed, characters, Item do Pedido
@param cCliLoja, characters, Cliente/Loja do pedido informado
@param cPorta, characters, Porta de impressão
@param nQtdeEtq, numeric, Numero de etiquetas a imprimir
@type function
/*/
user Function fEtiqCBC(nRecPed,cItemPed,cCliLoja,cPorta,nQtdeEtq) 
	private aLinImp := {}, aLinJson := {}
	private aArea := GetArea()
	private oCtrFrmJs := nil, oSrvZZ2 := nil
	private lRet := .T.
	private cJson := "" 
	private nPos := 0, n := 1
	default cPorta := "", nQtdeEtq := 1
	
	DbSelectArea("SC5")
	SC5->(DbGoTop())
	SC5->(DbGoTo(nRecPed))
	
	DbSelectArea("SC6")
	SC6->(DbGoTop())
	SC6->(DbSetOrder(1))
	if SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
	
		oSrvZZ2 := cbcLabelSrv():newcbcLabelSrv()
		cJson := oSrvZZ2:ConsZZ2(nRecPed,cCliLoja)
		if ! Empty (Alltrim(cJson))
			//Instancia a classe
			oCtrFrmJs := cbcLabelCtrl():newcbcLabelCtrl()
			oCtrFrmJs:initFrmJson(cJson)
					
			//Linhas do Json em Array
			aLinJson := oCtrFrmJs:getJsonaLin()
			
			for n:= 1 to Len (aLinJson)
				if aLinJson[n] <> nil
					do case 
						case aLinJson[n]:CTIPO == "F" //Campo Fixo SC5 e SC6
							Aadd(aLinImp,CarrCont("S" + SubsTr(aLinJson[n]:CCAMPO,1,2), aLinJson[n]:CCAMPO, 1 ,SC5->C5_NUM,;
																IIf ("S" + SubsTr(aLinJson[n]:CCAMPO,1,2) == "SC5","", cItemPed)))
						case aLinJson[n]:CTIPO == "M"	//Campo de informação Manual				
							if Len (aLinJson[n]:ACONTEUDO) > 0
								nPos := 0
								nPos := AScan(aLinJson[n]:ACONTEUDO,{|a| a[1] == Alltrim(cItemPed) })
								if nPos > 0
									Aadd(aLinImp,aLinJson[n]:ACONTEUDO[nPos][2]) 
								else
									Aadd(aLinImp,"")
								endIf
							else
								Aadd(aLinImp,aLinJson[n]:CCONTEUDO)
							endIf
					endCase
				endif
			next
			U_PrintPo(aLinImp, cPorta, nQtdeEtq)
		endif
	else
		Alert("Erro ao posicionar no pedido")
	endif
	RestArea(aArea)
	FreeObj(oCtrFrmJs)
	FreeObj(oSrvZZ2)
return(lRet)

/*/{Protheus.doc} CarrCont
//TODO Carrega conteudo dos campos (SX3) conforme opção escolhida (SC5/SC6).
@author juliana.leme
@since 04/01/2019
@version 1.0
@param _cTab, , Tabela (Alias)
@param _cCam, , Campo
@param nOrder, numeric, Ordem de pesquisa da tabela (alias) escolhido, default é 1
@param cPedido, characters, Numero do pedido
@param cItemPed, characters, Item do Pedido
@type function
/*/
static function CarrCont(_cTab, _cCam, nOrder, cPedido, cItemPed)
	local cConteudo 	:= ""
	local aPosTab 		:= {}

	aPosTab := U_fArrSx3(_cTab,_cCam)
	
	cConteudo := aPosTab[1] +": " 
	If aPosTab[3] == "N"
		cConteudo += Str(Posicione(_cTab,nOrder,xFilial(_cTab)+cPedido+cItemPed,aPosTab[2]))
	ElseIf aPosTab[3] == "D"
		cConteudo += cValToChar(DtoC(Posicione(_cTab,1,xFilial(_cTab)+cPedido+cItemPed,aPosTab[2])))
	Else
		If _cTab == 'SA7'
			cConteudo += Posicione(_cTab,nOrder,xFilial(_cTab)+SC5->(C5_CLIENTE)+SC5->(C5_LOJACLI)+SC6->(C6_PRODUTO),aPosTab[2])
		Else
			cConteudo += Posicione(_cTab,nOrder,xFilial(_cTab)+cPedido+cItemPed,aPosTab[2])
		EndIf
	EndIf
return(cConteudo)
