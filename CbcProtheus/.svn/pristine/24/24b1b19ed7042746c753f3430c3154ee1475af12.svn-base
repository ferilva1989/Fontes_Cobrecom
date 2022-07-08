#include "TOTVS.CH"
#include "protheus.ch"
#include 'rwmake.ch'
#include 'topconn.ch'
#define BR Chr(10) 

/*/{Protheus.doc} cbcfEtiq
//TODO FunCAo Principal onde manipula a chamada da tela de leiaute de etiquetas, conofrme parametros.
Caso a funCAo venha sem parametros, entende-se que a chamada � para criaCAo de leiaute GENERICO.
@author juliana.leme
@since 04/01/2019
@version 1.0
@param cFilialat, characters, Filial do Pedido
@param cNumPed, characters, Numero do Pedido
@type function
/*/
user function cbcfEtiq(cFilialat,cNumPed) 
 	private aSizeAuto 	:= MsAdvSize()
	private aArea 		:= GetArea()
	private oDlg, _lSai 
	private cFilialSis := "",cNPedido	:= "",cCSS := "", 	cTpLayout 		:= "", cLayout 	:= Space(10), cCliente := ""
	private nObj := 0,nObj1 := 0,nObj2 := 0,nObj3 := 0,nObj4 := 0,nObj5 := 0, nObj6 := 0
	private cLinha := ""
	private aDadPed:= {}, aDadIt := {}, aDados := {}, aDadCxP := {}
	private cbObj := nil, cbObj1 := nil, cbObj2 := nil, cbObj3 := nil, cbObj4 := nil, cbObj5 := nil, cbObj6 := nil
	private cbObjCmp := nil, cbObjCmp1 := nil,cbObjCmp2 := nil,cbObjCmp3 := nil,cbObjCmp4 := nil,cbObjCmp5 := nil,cbObjCmp6 := nil
	private cbObjIt := nil, cbObjIt1 := nil,cbObjIt2 := nil,cbObjIt3 := nil,cbObjIt4 := nil,cbObjIt5 := nil,cbObjIt6 := nil
	private cbObjPxC := nil, cbObjPxC1 := nil,cbObjPxC2 := nil,cbObjPxC3 := nil,cbObjPxC4 := nil,cbObjPxC5 := nil,cbObjPxC6 := nil
	private pnLin := nil,pnLin1 := nil,pnLin2 := nil,pnLin3 := nil,pnLin4 := nil,pnLin5 := nil,pnLin6 := nil
	private oLinha1,oLinha2,oLinha3,oLinha4,oLinha5,oLinha6
	private oTxtLiv := "",oTxtLiv1 := "",oTxtLiv2 := "",oTxtLiv3 := "",oTxtLiv4 := "",oTxtLiv5 := "",oTxtLiv6 := ""
	private btApplyTxt := "",btApplyTxt1 := "",btApplyTxt2 := "",btApplyTxt3 := "",btApplyTxt4 := "",btApplyTxt5 := "",btApplyTxt6 := ""
	private aComps	:= {"Campo Pedido","Campo Item","Texto Livre Fixo","Texto Livre Var.", "Prod x Cliente"}
	private oCtrLabel, OBtnOk, oComplin
	private cOperation := "I"
	private lPnlIten := .T.
	private oConsSc6 := cbcLabelSrv():newcbcLabelSrv()
	
	cFilialSis := cFilialat
	cNPedido := cNumPed
	
	SC5->(dbGoTop())
	SC5->(dbSetOrder(1))

	dbSelectArea("SC6")
	SC6->(dbGoTop())
	SC6->(dbSetOrder(1))

	dbSelectArea("SA7")
	SA7->(dbGoTop())
	SA7->(dbSetOrder(1))
	
	dbSelectArea("ZZ2")
	ZZ2->(dbGoTop())
	ZZ2->(dbSetOrder(1))
	
	//Analise do layout
	If VerLay()
		aDadPed := U_MontaSx("SC5")
		aDadIt 	:= U_MontaSx("SC6")
		aDadCxP := U_MontaSx("SA7")
	
		//Instacia a classe que recebera os dados da etiqueta
		oCtrLabel := cbcLabelCtrl():newcbcLabelCtrl()
		oCtrLabel:initLayout(0, 'SC5',cLayout)
		
		//Monta a Tela
		MntTela()
	else
		RestArea(aArea)
	endIf
return

/*/{Protheus.doc} VerLay
//TODO FunCAo estatica onde analisa o leiaute escolhido e carregado pela tela.
			Caso seja leiaute de pedidos realiza as trativas antes da chamada da funCAo.
@author juliana.leme
@since 04/01/2019
@version 1.0
@type function
/*/
static function VerLay()
	local aParamBox 	:= {} 
	local aRet		 	:= {}
	local lRet 			:= .T.
	 
	if !(MsgBox("Deseja gerar Leiaute de etiqueta SOMENTE para o pedido? ","Confirma","YesNo"))
		cNPedido := ""
		cTpLayout 	:= "L" //Layout
		if !(MsgBox("Deseja Informar um Leiaute Novo ? ","Confirma","YesNo"))	
			while .T.
				aParamBox 	:= {} 
				aRet		 	:= {}
				aAdd(aParamBox,{1,"Leiaute    ",Space(10)		,"","","ZZ2LEI","",080,.F.})
					
				if !ParamBox(aParamBox, "Parametros", @aRet)
					return(.F.)
				endIf		
				ZZ2->(dbSetOrder(3))
				if (empty(Alltrim(aRet[1]))) .or. ! (ZZ2->( DbSeek(xFilial("ZZ2")+cTpLayout+aRet[1])))
					MsgBox("Leiaute em branco ou n�o encontrado, favor verificar!","ATENCAO ERRO","STOP")
				else
					cLayout		:= aRet[1]
					lRet := .T.
					Exit			
				endif
			enddo
		endif
	else
		//Analisa Pedido para identificar se o mesmo possui bobinas nos itens
		If oConsSc6:ConsSC6(cNPedido)	
			cTpLayout 		:= "P" //Pedido
			lRet := .T.
		else
			MsgBox("Pedido sem bobinas cadastradas, Leiaute nao pode ser definido.","ATENCAO","STOP")
			FreeObj(oConsSc6)
			lRet := .F.
		endif
	endif
return(lRet)

/*/{Protheus.doc} MntTela
//TODO Monta a Tela onde sera definido o leiaute de impress�o da etiqueta.
@author juliana.leme
@since 04/01/2019
@version 1.0
@type function
/*/
static function MntTela()
	local nLarg := 0, nAlt := 0
	
	nLarg := aSizeAuto[5] - 190
	nAlt	:= aSizeAuto[6] - 200
	
	//Define Dialog
	oDlg 	:= MSDialog():New(aSizeAuto[7], 020, nAlt, nLarg,"Leiaute de etiquetas",,,.F.,,,,,,.T. ,,,.T. )
	
	// Sppliter ocupara toda tela
	spDiv := TSplitter():New( 01,01,oDlg,260,184, 0 )  // Orientacao Vertical
	spDiv:setCSS("QSplitter::handle:vertical{background-color: #0080FF; height: 4px;}")
	spDiv:align := CONTROL_ALIGN_ALLCLIENT
	
	// Painel Esquerda das linhas
	pnInf := TPanel():New(01,01,,spDiv,,.T.,,,,150,50)

	// Painel Direita Visualiza a etiqueta
	pnInf2 	:=  TPaintPanel():new(01,01,100,050,spDiv)
	pnlEti(pnInf2)

	//Monta Painel com as informaCAes do Pediod ou layout
	mntPnl()
	
	nBrwLarg	:= (oDlg:nClientWidth / 2) - 10
	nBrwAlt		:= (oDlg:nClientHeight / 2) -52 //* .20     
	oBtConf		:= TButton():New( nBrwAlt + 10 , nBrwLarg - 075,"Confirmar",oDlg,{|| fConfirma(cOperation)},037,012,,,,.T.,,'',,,,.F. )
	oBtCanc		:= TButton():New( nBrwAlt + 10 , nBrwLarg - 035,"Cancelar" ,oDlg,{|| oDlg:End()} ,037,012,,,,.T.,,'',,,,.F. )
	
	//Ativa Dialog
	oDlg:Activate() //RestArea(aArea)
return

/*/{Protheus.doc} Mntpnl
//TODO monta os paineis dentro da DIALOG.
@author juliana.leme
@since 04/01/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
static function Mntpnl()
	// Painel Esquerda das linhas
	pnLin := TPanel():New(0,0,,pnInf,,,,,,0,35) 
	
	//Componentes do Pedido
	oCSS 	:= TSay():New(08,10,{||'Num.Pedido:'},pnLin,,,,,,.T.,,,90,16) 
	oGetPed	:=  TGet():New( 06,50,{|u| If(PCount() == 0,cNPedido,cNPedido := u)},pnLin,;
									050, 010,"@!",, 0,,,.F.,,.T.,,.F.,,.F.,,,.F.,.F.,,,,,,,.T.)
	
	//Componoentes do Layout
	oCSS 	:= TSay():New(08,170,{||'Nome Leiaute:'},pnLin,,,,,,.T.,,,90,16)  
	oGetLay	:= TGet():New(06,210,{|u| If(PCount() == 0,cLayout,cLayout := u)},pnLin,;
									090, 010,"@!",,,,,,,.T.,,,,,,,.F.,.F.,,"cLayout")
	
	oBtnOk	:= TButton():New( 22 , 280,"Carregar",pnLin,{|| Confdad()},037,012,,,,.T.,,'',,,,.F. )
	
	pnLin:align := CONTROL_ALIGN_TOP

	If cTpLayout == "L"
		cNPedido		:= ""
		aComps			:= {"Campo Pedido","Campo Item","Texto Livre Fixo", "Prod x Cliente"}
		if Empty ( Alltrim(cLayout))
			oGetLay:Enable()
		else
			oGetLay:Disable()
		endIf
		oGetPed:Disable()
	Else 
		cLayout 			:= ""	
		If oConsSc6:ConsSC6(cNPedido)
			aComps			:= {"Campo Pedido","Campo Item","Texto Livre Fixo","Texto Livre Var.","Prod x Cliente"}
		else
			aComps			:= {"Campo Pedido","Campo Item","Texto Livre Fixo", "Prod x Cliente"}
		endif
		FreeObj(oConsSc6)
		
		If ! SC5->( DbSeek(xFilial("SC5")+cNPedido))
			MsgBox("Pedido n�o encontrado","ATENCAO","STOP")
		ElseIf ! SC6->(dbSeek(xFilial("SC6")+cNPedido))
			MsgBox("Itens do pedido nao encontrado","ATENCAO","STOP")
		Else
			oGetLay:Disable()
			oGetPed:Disable()
		EndIf	
	EndIf
return()

/*/{Protheus.doc} Confdad
//TODO Confere os dados caso o leiaute seja encontrado na ZZ2, realiza a chamada da classenewcbcLabelCtrl(),
			criando assim o objeto que responsavel pela tela.
@author juliana.leme
@since 04/01/2019
@version 1.0
@type function
/*/
static function Confdad()
	If cTpLayout == "L" .and. Empty(Alltrim(cLayout)) 
		MsgBox("Leiaute em branco ou n�o encontrado, favor verificar!","ATENCAO","STOP")
	ElseIf cTpLayout == "P" .and. Empty(Alltrim(cNPedido)) 
		MsgBox("Pedido n�o encontrado, favor verificar!","ATENCAO","STOP")
	Else
		//Instacia a classe que recebera os dados da etiqueta
		If cTpLayout == "L"
			ZZ2->(dbSetOrder(3))
			If(ZZ2->( DbSeek(xFilial("ZZ2")+cTpLayout+cLayout)))
				cOperation := "A"
				oCtrLabel:initLayout(0, 'SC5',cLayout)
				cStrGrava := ZZ2->ZZ2_LAYOUT
				oCtrLabel := cbcLabelCtrl():newcbcLabelCtrl()
				oCtrLabel:initFrmJson(cStrGrava)
			else	
				oCtrLabel:initLayout(0, 'SC5',cLayout)
				cOperation := "I"
			EndIf
		Else
			ZZ2->(dbSetOrder(2))
			If ZZ2->( DbSeek(xFilial("ZZ2")+cTpLayout+Alltrim(Str(SC5->(Recno())))))
				cOperation := "A"
				oCtrLabel:initLayout(SC5->(Recno()), 'SC5',cLayout)
				cStrGrava := ZZ2->ZZ2_LAYOUT
				oCtrLabel := cbcLabelCtrl():newcbcLabelCtrl()
				oCtrLabel:initFrmJson(cStrGrava)
			else
				cOperation := "I"
				SC5->( DbSeek(xFilial("SC5")+cNPedido))
				oCtrLabel:initLayout(SC5->(Recno()), 'SC5',cLayout)
			endIf
		EndIf
		
		//Atualiza Etiqueta
		pnlEti(pnInf2)
		criapnlLn(pnInf) //Aciona painel de Linhas
	endIf
return

/*/{Protheus.doc} pnlEti
//TODO Painel que alimenta o deseno da etiqueta conforme o objeto e carga de dados..
@author juliana.leme
@since 04/01/2019
@version 1.0
@param oPanel, object, Painel que recebera as informaCAes
@type function
/*/
static function pnlEti(oPanel)
	local cTextEtq := "TEXTO VARIAVEL DIVERSOS ITENS"
	local cStrGrava := ""
	local nTop := 180
	//Limpa tudo e recria
	oPanel:ClearAll()
	
	aDados := oCtrLabel:getJsonaLin()
	
	//Cria retangulo
	oPanel:addShape("id=0;type=1;left=0;top=140;width=450;height=300;"+;
	 						"gradient=1,0,0,0,0,0.0,#FFFFFF;pen-width=2;"+;
	 						"pen-color=#000000;can-move=0;can-mark=0;is-container=1;")
	//Cria Logo
	oPanel:addShape("id=11;type=8;left=290;top=150;width=133;height=31;"+; 
							"image-file=E:\logo-cobrecom_1.png;tooltip=Logo CBC;can-move=0;is-blinker=1;")
							
	//Cria Linhas		
	For n:= 1 to 6
		If aDados[n] == nil
			cTextEtq := "Nenhuma Linha Informada"
		ElseIf ! Empty(AllTrim(aDados[n]:CCONTEUDO)) 
			cTextEtq := aDados[n]:CCONTEUDO
		ElseIf aDados[n]:CTIPO == "F" 
			cTextEtq := aDados[n]:CCAMPO
		Else
			cTextEtq := "TEXTO VARIAVEL CONFORME ITENS"
		EndIf
		oPanel:addShape("id=10;type=7;pen-width=1;font=arial,14,0,0,1;left=20;top=" + Str(nTop) + ";width=400;"+; 
								"height=420;text=" + cTextEtq + " ;gradient=0,0,0,0,0,0,#000000;")
		nTop += 40
	Next
return()

/*/{Protheus.doc} criapnlLn
//TODO Cria Painel de linhas conforme objeto ja passado.
@author juliana.leme
@since 04/01/2019
@version 1.0
@param oPanel, object, painel que recebera as informaCAes dos objetos passados.
@type function
/*/
static function criapnlLn(oPanel)
	local aPnlLin := {}

	aAdd(aPnlLin,{"pnLin1","pnLin2","pnLin3","pnLin4","pnLin5","pnLin6"})
	aAdd(aPnlLin,{"cbObj1","cbObj2","cbObj3","cbObj4","cbObj5","cbObj6"})
	aAdd(aPnlLin,{"nObj1","nObj2","nObj3","nObj4","nObj5","nObj6"})
	aAdd(aPnlLin,{"cbObjCmp1","cbObjCmp2","cbObjCmp3","cbObjCmp4","cbObjCmp5","cbObjCmp6"})
	aAdd(aPnlLin,{"cbObjIt1","cbObjIt2","cbObjIt3","cbObjIt4","cbObjIt5","cbObjIt6"})
	aAdd(aPnlLin,{"oTxtLiv1","oTxtLiv2","oTxtLiv3","oTxtLiv4","oTxtLiv5","oTxtLiv6"})
	aAdd(aPnlLin,{"btApplyTxt1","btApplyTxt2","btApplyTxt3","btApplyTxt4","btApplyTxt5","btApplyTxt6"})
	aAdd(aPnlLin,{"cbObjPxC1","cbObjPxC2","cbObjPxC3","cbObjPxC4","cbObjPxC5","cbObjPxC6"})
	
	oBtnOk:hide()
	for num:= 1 to len(aPnlLin[1])
		aPnlLin[1][num] := TPanel():New(0,0,,oPanel,,,,,IIf(Mod(num, 2)== 0,,CLR_HGRAY),0,40) 
		criaLin(aPnlLin[1][num],aPnlLin[2][num],aPnlLin[3][num],aPnlLin[4][num],aPnlLin[5][num],aPnlLin[6][num],aPnlLin[7][num],aPnlLin[8][num],Alltrim(Str(num)))
	Next
return

/*/{Protheus.doc} criaLin
//TODO Cria os objetos definidos pelo painel de linhas conforme os objetos passados.
@author juliana.leme
@since 04/01/2019
@version 1.0
@param oPanel, object, Painel que recebera os objetos
@param cbObj, characters, ComboBox com as informaCAes dos itens de customizaCAo da etiqueta
@param nObj, numeric, Numero armazenado par componentizaCAo do objeto
@param cbObjCmp, characters, ComboBox com as informaCAes dos campos do Pedido
@param cbObjIt, characters, ComboBox com as informaCAes dos campos dos itens do Pedido
@param oTxtLiv, object, Objeto do Get onde sera editado o texto fico livre
@param btApplyTxt, block, Bot�o de aplicaCAo do Texto Livre Fixo
@param cLinha, characters, Linha do qual esta sendo editada.
@type function
/*/
static function criaLin(oPanel,cbObj,nObj,cbObjCmp,cbObjIt,oTxtLiv,btApplyTxt,cbObjPxC,cLinha)
	Local cTextField := Space(34)
	Local lItPxC := .F.
	local aDadX3 := {}
	
	aDados := oCtrLabel:getJsonaLin()
	
	oCSS 	:= TSay():New(08,10,{||'Linha 0' + cLinha +' da etiqueta'},oPanel,,,,,,.T.,,,90,16)
	oCSS 	:= TSay():New(25,10,{||'Escolha o objeto:'},oPanel,,,,,,.T.,,,90,16) 
	cbObj 	:= TComboBox():New(22,50,{|u|If(PCount()==0,nObj,nObj:=u)},aComps,;
	          		100, 010, oPanel,,{|o| changeOpc(o,cbObjCmp,cbObjIt,oTxtLiv,btApplyTxt,cbObjPxC,cLinha)},, 0, 16777215,.T.,,,.F.,,.F.,,, ,"nObj" )
	cbObj:setCSS("QComboBox{font-size: 12px;}")
	
	//Combo com os campos dos Pedidos
	cbObjCmp := TComboBox():New(22,180,{|u|If(PCount()==0,nObj,nObj:=u)},aDadPed,;
	          		100, 010, oPanel,,{|o| chgOpcPe(o,cLinha)},, 0, 16777215,.T.,,,.F.,,.F.,,, ,"nObj" )
	cbObjCmp:setCSS("QComboBox{font-size: 12px;}")
	
	//Combo com os campos dos Itens dos Pedidos
	cbObjIt := TComboBox():New(22,180,{|u|If(PCount()==0,nObj,nObj:=u)},aDadIt,;
	          		100, 010, oPanel,,{|o| chgOpcIt(o,cLinha)},, 0, 16777215,.T.,,,.F.,,.F.,,, ,"nObj" )
	cbObjIt:setCSS("QComboBox{font-size: 12px;}")
	
	//Editor de Texto Livre Fixo
	oTxtLiv := TGet():New( 22,180,{|u| If(PCount() == 0,cTextField,cTextField := u)},oPanel,;
									100, 010,"@!",, 0, 16777215,,.F.,,.T.,,.F.,,.F.,,,.F.,.F.,,,,,,,.T.)
	btApplyTxt 	:= TBtnBmp2():New( 40,570,26,26,'ok',,,, {||fAtuTxt(cTextField,cLinha)},oPanel,,,.T. ) 

	//Combo com os campos dos Produtos x Cliente
	cbObjPxC := TComboBox():New(22,180,{|u|If(PCount()==0,nObj,nObj:=u)},aDadCxP,;
	          		100, 010, oPanel,,{|o| chgOpcPxF(o,cLinha)},, 0, 16777215,.T.,,,.F.,,.F.,,, ,"nObj" )
	cbObjPxC:setCSS("QComboBox{font-size: 12px;}")
	
	oPanel:align := CONTROL_ALIGN_TOP
	
	If aDados[val(cLinha)] <> nil
		lPnlIten := .F.
		If empty (Alltrim ( aDados[val(cLinha)]:CTIPO ) )
			cbObj:Select(1)
			cbObjCmp:hide()
			cbObjIt:hide()
			cbObjPxC:hide()
		elseIf aDados[val(cLinha)]:CTIPO == "F" 	
			aDadX3 := U_fArrSx3("S"+Substr(aDados[val(cLinha)]:CCAMPO,1,2),aDados[val(cLinha)]:CCAMPO)
			cTitul := aDadX3[1]
			lItPed := "S"+Substr(aDados[val(cLinha)]:CCAMPO,1,2) == "SC5"
			lItPxC := "S"+Substr(aDados[val(cLinha)]:CCAMPO,1,2) == "SA7"
			nPosicao := aScan(IIf(lItPed,aDadPed,IIf(lItPxC,aDadCxP,aDadIt)),cTitul)
			cbObj:Select(IIf(lItPed,1,2))
			if lItPed
				cbObjCmp:Select (nPosicao)
				cbObjIt:hide()
				cbObjPxC:hide()
			elseif lItPxC
				cbObjPxC:Select (nPosicao)
				cbObjIt:hide()
				cbObjCmp:hide()
			else
				cbObjIt:Select (nPosicao)
				cbObjCmp:hide()
				cbObjPxC:hide()
			endIf
			oTxtLiv:hide()
			btApplyTxt:hide()
		elseIf aDados[val(cLinha)]:CTIPO == "M" .and.  len(aDados[val(cLinha)]:ACONTEUDO) <= 0
			cTextField := aDados[val(cLinha)]:CCONTEUDO
			cbObj:Select(3)
			oTxtLiv:Show()
			btApplyTxt:Show()
			cbObjIt:hide()
			cbObjPxC:hide()
		Else
			cbObj:Select(4)
			cbObjCmp:hide()
			cbObjIt:hide()
			cbObjPxC:hide()
			oTxtLiv:hide()
			btApplyTxt:hide()
			lPnlIten := .F.
		EndIf
	Else
		cbObj:Select(1)
		cbObjCmp:show()
		cbObjIt:hide()
		cbObjPxC:hide()
		oTxtLiv:hide()
		btApplyTxt:hide()
	endIf
	lPnlIten := .T.
return()

/*/{Protheus.doc} changeOpc
//TODO ACAo a ser tomada ap�s ser acionado por algum componente onde o mesmo foi informado.
@author juliana.leme
@since 04/01/2019
@version 1.0
@param o, object, Objeto que recebera informaCAes do componente
@param cbObjCmp, characters, Objeto com o componente contendo informaCAes dos campos do cabe�alho do Pedido (SC5)
@param cbObjIt, characters, Objeto com o componente contendo informaCAes dos campos dos itens do Pedido (SC6)
@param oTxtLiv, object, Objeto que contem o texto livre fixo.
@param btApplyTxt, block, Bot�o que aplica o texto apos a digitaCAo
@param cLinha, characters, Linha que esta sendo editada
@type function
/*/
static function changeOpc(o, cbObjCmp,cbObjIt, oTxtLiv,btApplyTxt,cbObjPxC,cLinha)
	local comp 	 := aComps[o:nAt] 

	do case
		case comp == "Campo Pedido"
			cbObjCmp:show()
			cbObjIt:hide()
			oTxtLiv:hide()
			cbObjPxC:hide()
			btApplyTxt:hide()
		case comp == "Campo Item"
			cbObjIt:Show()
			cbObjCmp:hide()
			oTxtLiv:hide()
			cbObjPxC:hide()
			btApplyTxt:hide()
		case comp == "Texto Livre Fixo"
			cbObjCmp:hide()
			cbObjIt:hide()
			oTxtLiv:show()
			cbObjPxC:hide()
			btApplyTxt:show()
		case comp == "Texto Livre Var."
			cbObjCmp:hide()
			cbObjIt:hide()
			oTxtLiv:hide()
			cbObjPxC:hide()
			btApplyTxt:hide()
			If lPnlIten
				fTxtIt(cLinha,aDados)
			EndIf
		case comp == "Prod x Cliente"
			cbObjCmp:hide()
			cbObjIt:hide()
			oTxtLiv:hide()
			cbObjPxC:show()
			btApplyTxt:hide()
	endCase
return

/*/{Protheus.doc} chgOpcPe
//TODO Efetua a aCAo de atualizaCAo dos campos relatico a escolha do item que alimentara a etiqueta,
nesse caso itens do cabe�alho do pedido na etiqueta SC5.
@author juliana.leme
@since 04/01/2019
@version 1.0
@param o, object, descricao
@param cLinha, characters, Linha do qual esta sendo editada
@type function
/*/
static function chgOpcPe(o, cLinha)
	local comp 	 := aDadPed[o:nAt] 
	local nLinha := val(cLinha)
	local cCampoC5 := ""
	local aPosTab := {}
	
	aPosTab := U_fArrSx3("SC5",comp)
	cCampoC5:= aPosTab[1] +": " 
	
	If aPosTab[3] == "N"
		cCampoC5 += Str(Posicione("SC5",1,xFilial("SC5")+cNPedido,aPosTab[2]))
	ElseIf aPosTab[3] == "D"
		cCampoC5 += DtoC(Posicione("SC5",1,xFilial("SC5")+cNPedido,aPosTab[2]))
	Else
		cCampoC5 += Posicione("SC5",1,xFilial("SC5")+cNPedido,aPosTab[2])
	EndIf

	oCtrLabel:editLine(nLinha)
	oCtrLabel:setTipo('F')
	oCtrLabel:setCampo(aPosTab[2])
	oCtrLabel:setHdrCont(cCampoC5)
	oCtrLabel:confirm()
	
	pnlEti(pnInf2)
return

/*/{Protheus.doc} chgOpcIt
//TODO Efetua a aCAo de atualizaCAo dos campos relatico a escolha do item que alimentara a etiqueta,
nesse caso itens do pedido na etiqueta SC6.
@author juliana.leme
@since 04/01/2019
@version 1.0
@param o, object, descricao
@param cLinha, characters, linha que esta sendo editada
@type function
/*/
static function chgOpcIt(o, cLinha)
	local comp 	 := aDadIt[o:nAt] 
	local nLinha := val(cLinha)
	local cCampoC6 := ""
	local aPosTab := {}
	
	aPosTab := U_fArrSx3("SC6",comp)
	
	cCampoC6:= aPosTab[1] +": " 
	If aPosTab[3] == "N"
		cCampoC6 += Str(Posicione("SC6",1,xFilial("SC6")+cNPedido,aPosTab[2]))
	ElseIf aPosTab[3] == "D"
		cCampoC6 += cValToChar(DtoC(Posicione("SC6",1,xFilial("SC6")+cNPedido,aPosTab[2])))
	Else
		cCampoC6 += Posicione("SC6",1,xFilial("SC6")+cNPedido,aPosTab[2])
	EndIf

	oCtrLabel:editLine(nLinha)
	oCtrLabel:setTipo('F')
	oCtrLabel:setCampo(aPosTab[2])
	oCtrLabel:setHdrCont(cCampoC6)
	oCtrLabel:confirm()

	pnlEti(pnInf2)
return

/*/{Protheus.doc} chgOpcPxF
//TODO Efetua a aCAo de atualizaCAo dos campos relatico a escolha do item que alimentara a etiqueta,
nesse caso itens do pedido na etiqueta SC6.
@author juliana.leme
@since 04/01/2019
@version 1.0
@param o, object, descricao
@param cLinha, characters, linha que esta sendo editada
@type function
/*/
static function chgOpcPxF(o, cLinha)
	local comp 	 := aDadCxP[o:nAt] 
	local nLinha := val(cLinha)
	local cCampoA7 := ""
	local aPosTab := {}
	
	aPosTab := U_fArrSx3("SA7",comp)
	
	cCampoA7:= aPosTab[1] +": " 
	If aPosTab[3] == "N"
		cCampoA7 += Str(Posicione("SA7",1,xFilial("SA7")+SC5->(C5_CLIENTE)+SC5->(C5_LOJACLI)+SC6->C6_PRODUTO,aPosTab[2]))
	ElseIf aPosTab[3] == "D"
		cCampoA7 += cValToChar(DtoC(Posicione("SA7",1,xFilial("SA7")+SC5->(C5_CLIENTE)+SC5->(C5_LOJACLI)+SC6->C6_PRODUTO,aPosTab[2])))
	Else
		cCampoA7 += Posicione("SA7",1,xFilial("SA7")+SC5->(C5_CLIENTE)+SC5->(C5_LOJACLI)+SC6->(C6_PRODUTO),aPosTab[2])
	EndIf

	oCtrLabel:editLine(nLinha)
	oCtrLabel:setTipo('F')
	oCtrLabel:setCampo(aPosTab[2])
	oCtrLabel:setHdrCont(cCampoA7)
	oCtrLabel:confirm()

	pnlEti(pnInf2)
return

/*/{Protheus.doc} fAtuTxt
//TODO ACAo do bt�o ap�s digitaCAo de texto fixo.
@author juliana.leme
@since 04/01/2019
@version 1.0
@param cTextField, characters, Componente contendo o texto digitado
@param cLinha, characters, Linha que esta sendo editada
@type function
/*/
static function fAtuTxt(cTextField, cLinha)
	local nLinha := val(cLinha)
	
	oCtrLabel:editLine(nLinha)
	oCtrLabel:setTipo('M')
	oCtrLabel:setHdrCont(cTextField)
	oCtrLabel:confirm()
	
	pnlEti(pnInf2)
return ( .F. )

/*/{Protheus.doc} fTxtIt
//TODO Monta a tela que sera exibida com os itens do pedido de venda na geraCAo da etiqueta.
@author juliana.leme
@since 04/01/2019
@version 1.0
@param cLinha, characters, linha que esta sendo editada
@param aDItem, array, Array com as informaCAes dos itens do pedido
@type function
/*/
static function fTxtIt(cLinha,aDItem)
	Local aHead1 			:= {}
	Private aCols1		:= {}
	Private bValTexto	:= {|| fValid('PRODUTO')}
	Private bLinOk 		:= {|| fValid('LINHA')}
	Private nPosTexto
	Private nColDel	
	Default aDItem := {}
	
	aHead1 := fHeader()
	nPosTexto	:= aScan(aHead1, {|x| AllTrim(x[2]) == 'TEXTO'})
	
	aCols1 := fCols(val(cLinha),aDItem)
	
	nOpc := GD_UPDATE
	nLarg := aSizeAuto[5]-520
	nAlt := aSizeAuto[6]-350
	
	oDlgItens 	:= MSDialog():New(aSizeAuto[7], 020,nAlt ,nLarg ,"Itens do Pedido " + SC5->C5_NUM  + " - COBRECOM",,,.F.,,,oDlg,,,.T.,,,.T. )												
	nBrwLarg	:= (oDlgItens:nClientWidth / 2) -10
	nBrwAlt		:= (oDlgItens:nClientHeight / 2) -40 //* .20     
	oBrw1		:= MsNewGetDados():New( 0 , 0, nBrwAlt, nBrwLarg,nOpc,'Eval(bLinOk)','AllwaysTrue()','',{"TEXTO"},0,,'AllwaysTrue()',,'',oDlgItens,aHead1,aCols1)
	oBtConf		:= TButton():New( nBrwAlt + 10 , nBrwLarg - 075,"Confirmar",oDlgItens,{|| If(fValid("TODOS"),fGrava(cLinha),)},037,012,,,,.T.,,'',,,,.F. )
	oBtCanc		:= TButton():New( nBrwAlt + 10 , nBrwLarg - 035,"Cancelar" ,oDlgItens,{|| oDlgItens:End()} ,037,012,,,,.T.,,'',,,,.F. )
	If Len( aCols1) > 0
		oDlgItens:Activate(,,,.T.)
	else
		MsgBox("Pedido N�o possui itens para ediCAo de texto. Escolha outra opCAo.","ATENCAO","STOP")
	endif
return 

/*/{Protheus.doc} fHeader
//TODO Header com as informa�oes do Grid que sera apresentado na exibiCAo de itens a serem editados.
@author juliana.leme
@since 04/01/2019
@version 1.0
@type function
/*/
Static Function fHeader()
	Local aAux := {}
	
	aAdd(aAux,{"Item"		,"ITEM"		,"@!"		,TamSX3("C6_ITEM")[1]			,0									,''		,''	,"C"	,'','' })
	aAdd(aAux,{"Produto"	,"PRODUTO"	,"@!"		,TamSX3("C6_PRODUTO")[1]	,0									,''		,''	,"C"	,'','' })
	aAdd(aAux,{"DescriCAo","DESC"		,"@!"		,TamSX3("C6_DESCRI")[1]		,0									,'' 		,'' 	,"C" 	,'','' })
	aAdd(aAux,{"UM"			,"UNIDADE"	,"@!"		,TamSX3("C6_UM")[1]			,0									,'' 		,''	,"C"	,'','' })
	aAdd(aAux,{"Quant"		,"QUANT"	,"@!"		,TamSX3("C6_QTDVEN")[1]		,TamSX3("C6_QTDVEN")[2] ,''		,''	,"N"	,'','' })
	aAdd(aAux,{"Texto"		,"TEXTO"	,"@!"		,34									,0 									,'Eval(bValTexto)'		,''	,"C"	,'','' })	
Return(aAux)

/*/{Protheus.doc} fCols
//TODO Alimenta o aCols do Gri da tela com os itens do pedido de venda.
@author juliana.leme
@since 04/01/2019
@version 1.0
@param nLinha, numeric, descricao
@param aDItem, array, descricao
@type function
/*/
Static Function fCols(nLinha,aDItem)
	Local aAux := {}
	local nAux := 0
	local cTextItem := Space(34)
	
	SC6->(dbGoTop())
	If SC6->(DbSeek(xFilial("SC5") + SC5->C5_NUM))
		While SC6->C6_NUM == SC5->C5_NUM
			If SC6->C6_ACONDIC == "B"
				cTextItem := Space(34)
				if ValType(aDItem[nLinha]) <> 'U'
					If cOperation <> "I"  .and. Len(aDItem[nLinha]:ACONTEUDO) > 0
						nAux := aScan(aDItem[nLinha]:ACONTEUDO,{|x|x[1] == SC6->C6_ITEM})
						if nAux > 0
							cTextItem :=  aDItem[nLinha]:ACONTEUDO[nAux][2]
						endif
					EndIf
				endif
				aAdd(aAux,{ 	SC6->C6_ITEM,;
									SC6->C6_PRODUTO,;
									SC6->C6_DESCRI,;
									SC6->C6_UM,;
									SC6->C6_QTDVEN,;
									cTextItem,;
									.F.})
			endIf
			SC6->(DbSkip())
		EndDo
	Else
		MsgBox("Erro ao posicionar nos Itens, Verificar!","ATENCAO","STOP")
	EndIf	
Return(aAux)

/*/{Protheus.doc} fValid
//TODO DescriCAo auto-gerada.
@author juliana.leme
@since 10/12/2018
@version 1.0
@return ${return}, ${return_description}
@param cCampo, characters, descricao
@type function
/*/
Static Function fValid(cCampo)
	Local lRet := .T.
	Local lVazio := .T.
	Local nY
	
	// Revalida todas as linhas
	If cCampo == "TODOS"
		For nY := 1 to Len(oBrw1:aCols)
			If ! Empty(oBrw1:aCols[nY][nPosTexto])
				lVazio := .F.
			EndIf
		Next nY
		
		If lVazio
			Aviso("Atencao!","Nenhum TEXTO Preenchido, Verificar!",{"OK"})
			Return(.F.)
		EndIf
	EndIf
Return (lRet)

/*/{Protheus.doc} fGrava
//TODO Grava itens que foram preenchidos no grid.
@author juliana.leme
@since 04/01/2019
@version 1.0
@param cLinha, characters, descricao
@type function
/*/
Static Function fGrava(cLinha)
	local aDadIt		:= oBrw1:aCols
	local aCont			:= {}
	local nLinha 		:= val(cLinha)
	
	For n1= 1 to len(aDadIt)
		If ! Empty(Alltrim(aDadIt[n1][6]))
			oCtrLabel:editLine(nLinha)
			oCtrLabel:setTipo('M')
			aadd(aCont, {aDadIt[n1][1],aDadIt[n1][6]})
			oCtrLabel:setItm(aCont)
			oCtrLabel:confirm()
		Endif
	Next

	pnlEti(pnInf2)
	oDlgItens:End()
Return

/*/{Protheus.doc} fConfirma
//TODO Confirma o leiaute definido na tela e realiza a gravaCAo/alteraCAo da tabela ZZ2.
@author juliana.leme
@since 04/01/2019
@version 1.0
@param cOperation, characters, OperaCAo I= Inclusao/A=AlteraCAo
@type function
/*/
static function fConfirma(cOperation)
	local cStrGrava 	:= "" 
	local oInstZZ2		:= cbcLabelSrv():NewcbcLabelSrv()
	local aDadosZZ2	:= {}
	local nCount		:= 0
	local lRet			:= .T.
	Default cOperation 	:= "I"

	// Obtem o JSON em forma de string
	cStrGrava := oCtrLabel:toJSON()

	oCtrFrmJs := cbcLabelCtrl():newcbcLabelCtrl()
	oCtrFrmJs:initFrmJson(cStrGrava)
	
	if ! Empty( oCtrFrmJs:oMainlayout )
		aAdd(aDadosZZ2,{;
				{"FILIAL"		,xFilial("ZZ2")},;
				{"TIPO"		,cTpLayout},;
				{"RECNO"	,oCtrLabel:oMainlayout:NREC},;
				{"NOME"		,cLayout},;
				{"LAYOUT"	,cStrGrava}})
	endif					
	if len(aDadosZZ2) == 0
		MsgBox("Informe as linhas da etiqueta corretamente","ATENCAO","STOP")
		lRet := .F.
	else		
		lRet := oInstZZ2:GrvZZ2(aDadosZZ2,cOperation)
		if lRet
			MsgBox("Etiqueta incluida e salva com sucesso!","CONCLUIDO","INFO")	
			RestArea(aArea)
			FreeObj(oInstZZ2)
			FreeObj(oCtrLabel)
			oDlg:End()
		else
			MsgBox("Erro na inclus�o da etiqueta","ATENCAO","STOP")
		endif
	endif		
return()

/*/{Protheus.doc} HandleEr
@type function
@author bolognesi
@since 26/04/2018
@description Realiza os tratamentos de erros da classe
/*/
static function HandleEr(oErr, oSelf)
	local cMsg	:= "[cbcfEtiq - "+DtoC(Date())+" - "+Time()+" ] "+ '[ERRO]' + oErr:Description + ' [FROM] ' + ProcName(3)
	
	ConOut(cMsg)
	oSelf:setProgMsg(cMsg)
	oSelf:cRunMsg := cMsg
	BREAK
return(nil)
