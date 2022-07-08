#INCLUDE "rwmake.ch"


/*/{Protheus.doc} TrocaCM
@author zzz
@since 23/06/2017
@version 1.0
@type function
@description Função que realiza a troca da comissão em um determinado documento(Nota/Romaneio)
alterando o campo (SD2->D2-COMIS1)
/*/
User Function TrocaCM()
	local oAcl		:= cbcAcl():newcbcAcl()
	Private aParamBox  		:= {}
	Private aRet  				:= {}

	if !oAcl:aclValid('Comissao')
		Alert(oAcl:getAlert() )
	else
		dbSelectArea("SD2")                                      
		DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

		DbSelectArea("SF2")
		DBOrderNickName("SF2CDROMA")

		_TpDoc := "R"
		_NmDoc0 := "     "
		_Perc := 0.00
		_Vai := .T.     
		_Troquei := .F.
		Do While _Vai     
		    aParamBox := {}
		    
			aAdd(aParamBox,{1,"Serie                 ",Space(03),"","","","",035,.F.})
			aAdd(aParamBox,{1,"Nro. Nota Fiscal ",Space(09),"","","","",035,.F.})
			aAdd(aParamBox,{1,"Nro.Romaneio    ",Space(06),"","","","",035,.F.})
			aAdd(aParamBox,{1,"% Comissäo      ",0.00  ,"@E 999.99","","","",0,.F.})
			
			If !ParamBox(aParamBox, "Troca Comissão", @aRet)
				Return()
			Else
				If Empty(aRet[1]) .Or. Empty(aRet[2])
					Alert("Obrigatório Informar Nro. da Carga ou Nro. Religas")
					Loop
				Else
					MV_PAR01 := aRet[01] 
					MV_PAR02 := aRet[02] 
					MV_PAR03 := aRet[03] 
					MV_PAR04 := aRet[04] 
				EndIf
			EndIf

			If !Empty(MV_PAR03)  
				_TpDoc := "R"
				_NmDoc0 := MV_PAR03 // + "/"
			Else
				_TpDoc := "N"
				_NmDoc0 := MV_PAR02 // + "/"
				_Seri := MV_PAR01
			EndIf

			DbSelectArea("SF2")
			If _TpDoc == "R"
				DBOrderNickName("SF2CDROMA")
				_Chv := "SF2->F2_CDROMA"
			Else
				DbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
				_Chv := "SF2->F2_DOC"
			EndIf                   		

			_NmDoc1 := _NmDoc0

			If !(DbSeek(xFilial("SF2")+_NmDoc1,.F.))
				Alert("Documento " + _NmDoc1 + "não Encontrado!")
			EndIf
			Do While SF2->F2_FILIAL == xFilial("SF2") .And. &(_Chv) == _NmDoc1 .And. SF2->(!Eof())
				If !Empty(MV_PAR02) .And. SF2->F2_SERIE # _Seri
					DbSelectArea("SF2")
					SF2->(DbSkip())
				EndIf

				DbSelectArea("SD2")
				DbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE,.F.)
				Do While SD2->D2_FILIAL == xFilial("SD2") .And. SD2->D2_DOC == SF2->F2_DOC .And. SD2->D2_SERIE == SF2->F2_SERIE .And. SD2->(!Eof())
					RecLock("SD2",.F.)
					SD2->D2_COMIS1 := MV_PAR04
					MsUnLock()
					SD2->(DbSkip())
					If !_Troquei
						_Troquei := .T.
					EndIf
				EndDo
				DbSelectArea("SF2")
				SF2->(DbSkip())
			EndDo
		EndDo
		If _Troquei
			Alert("Você Precisa Rodar a Rotina de Reprocessamento das Comissões")
		EndIf
	endif
	freeObj(oAcl)
Return(.T.)
                                                                                      