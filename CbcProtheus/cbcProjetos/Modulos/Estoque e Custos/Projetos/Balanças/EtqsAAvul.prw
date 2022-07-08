#INCLUDE "PROTHEUS.CH"
//#INCLUDE "RWMAKE.CH"


/*/{Protheus.doc} EtqsAAvul
//TODO Descrição auto-gerada.
@author Roberto
@since 29/05/2017
@version undefined
@history 20/06/2017,juliana.leme,Alteração realizada para que a impressão seja realizada sem amarração. 
@type function
/*/
User Function EtqsAAvul()
	Local _cTitulo := "Etiqueta Sacaria "
	Private wnrel   := "ETIQUETA"
	Private cString := "ETIQUETA"
	Private aReturn := {"Zebrado",1,"Administracao",1,3,"COM2","",1}
	Private cPorta  := "" //"COM2:9600,E,8,1,P"
	
	_lResp := .F.
	aRet :={}
	aParamBox := {}
	aAdd(aParamBox,{3,"Porta de Impressão..:",2,{"COM1","COM2","LPT1","LPT2","LPT3"},50,"",.F.})
	_lResp := ParamBox(aParamBox, "Informe Porta para Impressão", @aRet)
	If !_lResp
		Return(.T.)
	EndIf
	
	cPorta  := Substr("COM1/COM2/LPT1/LPT2/LPT3/",((aRet[1]-1)*5)+1,4)
	
	If "COM" $ cPorta
		cPorta  := cPorta + ":9600,E,8,1,P"
	EndIf
	lServer := .F.
	
	aReturn := {"Zebrado",1,"Administracao",1,3,cPorta,"",1}
	
	Do While .T.
		aParamBox := {}
	                    
		aAdd(aParamBox,{2,"Forma.........: ","Nro.Carga",{"Nro.Carga","Avulsa"},45			,""		,.T.})
		aAdd(aParamBox,{1,"Nro.da Carga..: ","      "   ,                      ,             ,     ,"MV_PAR01=='Nro.Carga'",40      ,.F.})
		aAdd(aParamBox,{1,"Nro.Religas...: ","         ",                      ,             ,     ,"MV_PAR01=='Nro.Carga'",40      ,.F.})
		aAdd(aParamBox,{1,"Nro.da Nota...: ","         ","999999999"           ,"u_AcheCli()",     ,"MV_PAR01=='Avulsa'"   ,40      ,.F.})
		aAdd(aParamBox,{1,"Cliente.......: ",Space(Len(SA1->A1_COD)) ,""	   ,             ,     ,".F."                  ,40      ,.F.})
		aAdd(aParamBox,{1,"Loja:.........: ",Space(Len(SA1->A1_LOJA)),""	   ,             ,     ,".F."                  ,40      ,.F.})
		aAdd(aParamBox,{1,"Nome Cliente..: ",Space(Len(SA1->A1_NOME)),""	   ,             ,     ,".F."                  ,130     ,.F.})
		aAdd(aParamBox,{1,"Data..........: ",dDatabase  ,                      ,             ,     ,"MV_PAR01=='Avulsa'"   ,40      ,.F.})
		aAdd(aParamBox,{1,"Qtd.Etiquetas.: ",0          ,"@E 999"	           ,"MV_PAR09>=0",     ,"MV_PAR01=='Avulsa'"   ,40      ,.F.})
	
		If !ParamBox(aParamBox, _cTitulo, @aRet)
			Return(.T.)
		ElseIf aRet[1] == 'Nro.Carga'
			If Empty(aRet[2]) .And. Empty(aRet[3])
				Alert("Obrigatório Informar Nro. da Carga ou Nro. Religas")
				Loop
			EndIf
		Else
			If Empty(aRet[4]) .Or. Empty(aRet[8])
				Alert("Obrigatório Informar Nro. da O.S. e Sequência")
				Loop
			ElseIf aRet[9] <= 0
				Alert("Indique a Quantidade de Lances")
				Loop
			EndIf
		EndIf
	
		If aRet[1] == 'Nro.Carga'
			_cNumCar  := aRet[2]
			_cReligas := aRet[3]
			// Imprimir conforme o SZN
	
			DbSelectArea("SDB")
			DbSetOrder(6) // DB_FILIAL+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_SERVIC+DB_TAREFA
		
			DbSelectArea("SZN")
			//DbSetOrder(1) // ZN_FILIAL+ZN_CTRLE
			DbSetOrder(3) // ZN_FILIAL+ZN_ROMANEI+STRZERO(ZN_NUMVOL,3)+ZN_PRODUTO+ZN_ACONDIC
			
			_nVolTot := 0
			If !(DbSeek(xFilial("SZN")+_cNumCar,.F.))
				Alert("Nro. Carga não Encontrado")
				Loop
			EndIf
			
			DbSelectArea("SF2")
			DBOrderNickName("SF2CDCARGA") //F2_FILIAL+F2_CDROMA+F2_SERIE+F2_DOC
			DbSeek(xFilial("SF2")+SZN->ZN_ROMANEI,.F.)
			
			SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.))
			
			_cNF 	:= ""
			_cData	:= DtoC(dDataBase)
			Do While SF2->F2_FILIAL == xFilial("SF2") .And. SF2->F2_CDCARGA == SZN->ZN_ROMANEI .And. SF2->(!Eof())
				If SDB->(DbSeek(xFilial("SDB")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.))
					If !SF2->F2_DOC $ _cNF .And. SF2->F2_SERIE $ "UNI//1  "
						_cNF := _cNF + AllTrim(SF2->F2_DOC) + ", "
						_cData	:= DtoC(SF2->F2_EMISSAO)
					EndIf
				EndIf
				SF2->(DbSkip())
			EndDo
		
			_cControl := SZN->ZN_CTRLE
			_cCliente := SA1->A1_NOME
			_cCidade  := SA1->A1_MUN
			_cUF      := SA1->A1_EST
			_nVolTot  := SZN->ZN_NUMVOL
			_nQtBB    := SZN->ZN_BOBS
			_nQtCr 	  := SZN->ZN_CARR
		
			SZN->(DbSkip())
			Do While SZN->ZN_FILIAL == xFilial("SZN") .And. SZN->ZN_ROMANEI == _cNumCar .And. SZN->(!eof())
				_nVolTot := Max(_nVolTot,SZN->ZN_NUMVOL)// Pego o maior nro do volume
				SZN->(DbSkip())
			EndDo
			_cNotas := ""
			_nQt	:= _nVolTot / 2
			_nQt 	:= Int(_nQt)
			If (_nVolTot % 2) > 0.00
				_nQt++
			EndIf
			_cVolTot  := StrZero(_nVolTot,3)
			_cNotas   := _cNF
			If Empty(_cNotas)
				_cNotas := _cReligas
			Else
				_cNotas := Left(_cNotas,Len(_cNotas)-2)
			EndIf
			_nQtBob   := _nQtBB * 2 // 4 etiquetas por bobina   
			_nQtCar   := _nQtCr / 2 // 1 etiqueta por carretel
			If (_nQtCar - Int(_nQtCar)) > 0
				_nQtCar := Int(_nQtCar) + 1
			EndIf
			_lSacos := .T. // Imprimir etiquetas de sacos
			ImpEtiq()
		ElseIf aRet[1] == "Avulsa"
			// Imprimir conforme o ZZR
			_lSacos := .F.	// Não imprimir etiquetas de sacos
			_cNotas := StrZero(Val(aRet[4]),9)
			_cData  := Dtoc(aRet[8])
			_nQtCar := 0
			_nQtBob := (aRet[9] / 2) // O usuario informa diretamente a quantidade de lances que quer. Como sai duas por vez, divido por 2
			_nQtBob := If((_nQtBob-Int(_nQtBob)) > 0, Int(_nQtBob)+1, Int(_nQtBob))
	
			DbSelectArea("SA1")
			DbSeek(xFilial("SA1") + aRet[5] + aRet[6],.F.)
			_cCliente := SA1->A1_NOME
			_cCidade  := SA1->A1_MUN
			_cUF      := SA1->A1_EST
			_cControl := " "
			ImpEtiq()
		EndIf
	EndDo
Return(.T.)
*
*************************
Static Function ImpEtiq()
*************************
*
Private wnrel   := "ETIQSACO"
Private cString := "SA1"
Private aReturn := {"Zebrado",1,"Administracao",1,3,cPorta,"",1}
SetDefault(aReturn,cString)

For _Vez := 1 to 3
	_lBob := _lCar := .F.
	If _Vez == 1 .And. !_lSacos
		Loop
	ElseIf _Vez == 2 
		If _nQtBob > 0
			_lBob := .T.
		Else
			Loop
		EndIf
	ElseIf _Vez == 3 
		If _nQtCar > 0
			_lCar := .T.
		Else
			Loop
		EndIf
	EndIf  

	@ 0,0 PSAY "^XA^LH1,16^PRC^FS"
	@ 0,0 PSAY "^FX ======================================================== ^FS"
	@ 0,0 PSAY "^FX =              *** ETIQUETA P/ SACARIAS ***            = ^FS"
	@ 0,0 PSAY "^FX =                                                      = ^FS"
	@ 0,0 PSAY "^FX =      Etiqueta desenvolvida por Valter Sanavio e      = ^FS"
	@ 0,0 PSAY "^FX =            Roberto Oliveira em 10/10/2008            = ^FS"
	@ 0,0 PSAY "^FX ======================================================== ^FS"

	@ 0,0 PSAY "^FX *** COBRECOM REVERSO *** ^FS"
	@ 0,0 PSAY "^FO016,012,^GB280,60,30^FS"
	@ 0,0 PSAY "^FO040,032^A0N,35,50^FR^FDCOBRECOM^FS"

	@ 0,0 PSAY "^FX *** NOTA FISCAL *** ^FS"

	@ 0,0 PSAY "^FO220,088^A0R,75,65^FDNF " + _cNotas + "^FS"

	@ 0,0 PSAY "^FX *** VOLUME *** ^FS"
	IF !_lBob .And. !_lCar 
		//@ 0,0 PSAY "^FO220,1030^A0R,75,65^SN001,2,Y^FS"
		//@ 0,0 PSAY "^FO220,1128^A0R,75,65^FD/" + _cVoltot + "^FS"
		//@ 0,0 PSAY "^FO208,1070^A0R,25,25^FDV O L U M E^FS"
		
		@ 0,0 PSAY "^FO220,830^A0R,75,65^SN001,2,Y^FS"
		@ 0,0 PSAY "^FO220,928^A0R,75,65^FD/" + _cVoltot + "^FS"
		@ 0,0 PSAY "^FO208,870^A0R,25,25^FDV O L U M E^FS"

	EndIf

	@ 0,0 PSAY "^FX *** CLIENTE *** ^FS"
	@ 0,0 PSAY "^FO162,088^A0R,40,35^FDCliente: " + _cCliente + "^FS"
	/*/
	@ 0,0 PSAY "^FX *** CIDADE *** ^FS"
	@ 0,0 PSAY "^FO102,088^A0R,40,35^FDCidade: " + _cCidade + "^FS"
	
	@ 0,0 PSAY "^FX *** ESTADO *** ^FS"
	@ 0,0 PSAY "^FO102,792^A0R,40,35^FDEstado: " + _cUF + "^FS"
	/*/
	@ 0,0 PSAY "^FX *** CONTROLE (ROMANEIO) *** ^FS"
	@ 0,0 PSAY "^FO042 ,088^A0R,40,35^FDControle:   " + _cControl + "^FS"

	@ 0,0 PSAY "^FX *** DATA *** ^FS"
	@ 0,0 PSAY "^FO042,408^A0R,40,35^FDData:  " + _cData + "^FS"
	
	/*/	         
	@ 0,0 PSAY "^FX *** CODIGO DE BARRAS *** ^FS"
	IF !_lBob .And. !_lCar     
		@ 0,0 PSAY "^FO064,0780^BY3,,70^BUR,110,Y,N,N^SN" + "9"+_cControl+"0001" + ",2,Y^FS"         
	EndIf
	/*/


	@ 0,0 PSAY "^FX ======================================================== ^FS"
	@ 0,0 PSAY "^FX =                 2a. Etiqueta                         = ^FS"
	@ 0,0 PSAY "^FX ======================================================== ^FS"
	
	@ 0,0 PSAY "^FX *** COBRECOM REVERSO *** ^FS"
	@ 0,0 PSAY "^FO344,012,^GB280,60,30^FS"
	@ 0,0 PSAY "^FO368,032^A0N,35,50^FR^FDCOBRECOM^FS"
	
	@ 0,0 PSAY "^FX *** NOTA FISCAL *** ^FS"
	@ 0,0 PSAY "^FO548,088^A0R,75,65^FDNF " + _cNotas + "^FS"
	
	@ 0,0 PSAY "^FX *** VOLUME *** ^FS"
	IF !_lBob .And. !_lCar
		@ 0,0 PSAY "^FO548,830^A0R,75,65^SN002,2,Y^FS"
		@ 0,0 PSAY "^FO548,928^A0R,75,65^FD/" + _cVoltot + "^FS"
		@ 0,0 PSAY "^FO538,870^A0R,25,25^FDV O L U M E^FS"
	EndIf

	@ 0,0 PSAY "^FX *** CLIENTE *** ^FS"
	@ 0,0 PSAY "^FO490,088^A0R,40,35^FDCliente: " + _cCliente + "^FS"
	/*/
	@ 0,0 PSAY "^FX *** CIDADE *** ^FS"
	@ 0,0 PSAY "^FO430,088^A0R,40,35^FDCidade: " + _cCidade + "^FS"
	
	@ 0,0 PSAY "^FX *** ESTADO *** ^FS"
	@ 0,0 PSAY "^FO430,792^A0R,40,35^FDEstado: " + _cUf + "^FS"
	/*/
	@ 0,0 PSAY "^FX *** CONTROLE (ROMANEIO) *** ^FS"
	@ 0,0 PSAY "^FO370 ,088^A0R,40,35^FDControle:   " + _cControl + "^FS"
	
	@ 0,0 PSAY "^FX *** DATA *** ^FS"
	@ 0,0 PSAY "^FO370,408^A0R,40,35^FDData:  " + _cData + "^FS"
	
	/*/
	@ 0,0 PSAY "^FX *** CODIGO DE BARRAS *** ^FS"
	IF !_lBob .And. !_lCar
		@ 0,0 PSAY "^FO392,0780^BY3,,70^BUR,110,Y,N,N^SN" + "9"+_cControl+"0002" + ",2,Y^FS"
	EndIf
	/*/

	@ 0,0 PSAY "^FX ======================================================== ^FS"
	@ 0,0 PSAY "^FX =                   Fim da Etiqueta                    = ^FS"
	@ 0,0 PSAY "^FX =   O comando PQ2 indica duas carreiras de etiquetas   = ^FS"
	@ 0,0 PSAY "^FX ======================================================== ^FS"
	@ 0,0 PSAY "^PQ" + AllTrim(Str(IF(_lBob,_nQtBob,If(_lCar,_nQtCar,_nQt)))) + "^FS"
	@ 0,0 PSAY "^MTT^FS"
	@ 0,0 PSAY "^MPE^FS"
	@ 0,0 PSAY "^JUS^FS"
	@ 0,0 PSAY "^XZ"
Next

SET DEVICE TO SCREEN
If aReturn[5]==1
	DbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
EndIf
MS_FLUSH()
Return(.T.)
*
***********************
User Function AcheCli()
***********************
*
MV_PAR04 := StrZero(Val(MV_PAR04),9)
SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
If !SF2->(DbSeek(xFilial("SF2")+MV_PAR04,.F.))
	Alert("Nota não Cadastrada")
	Return(.F.)
EndIf

MV_PAR05 := SF2->F2_CLIENTE
MV_PAR06 := SF2->F2_LOJA
MV_PAR08 := SF2->F2_EMISSAO

SA1->(DbSetOrder(1))
SA1->(DbSeek(xFilial("SA1")+MV_PAR05+AllTrim(MV_PAR06),.F.))
MV_PAR07 := SA1->A1_NOME
Return(.T.)