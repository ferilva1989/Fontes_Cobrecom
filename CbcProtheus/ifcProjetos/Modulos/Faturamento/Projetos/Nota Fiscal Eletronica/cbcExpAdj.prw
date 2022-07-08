#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TBICONN.CH"

user function cbcExpAdj(aProd, aVol)
	local aArea    	    := GetArea()
	local aAreaSB1	    := SB1->(getArea())
	local nX			:= 0
	local aItems		:= {}
	local nPesLiqNF		:= 0
	local nPesLiqItem	:= 0
	local nPesDiverg	:= 0
	local nPesDist		:= 0
	local nPesAItems	:= 0
	local lAutoDist		:= GetNewPar('ZZ_PESDIST', .F.)

	DbSelectArea("SB1")
	for nX := 1 to len(aProd)
		if aProd[nX, 8] <> aProd[nX, 11]
			aAdd(aItems, aProd[nX])
		endif
		if aProd[nX, 11] == 'KG'
			nPesLiqItem += aProd[nX, 12]
			nPesAItems += aProd[nX, 12]
		else
			nPesLiqItem += Posicione("SB1",1,xFilial("SB1")+aProd[nX, 02],"B1_PESO")
		endif
	next nX

	if !empty(aItems)
		for nX := 1 to len(aVol)
			nPesLiqNF += aVol[nX][03]
		next nX
		nPesDiverg := Round((nPesLiqNF - nPesLiqItem),4)
		if !empty(nPesLiqNF) .and. (nPesDiverg <> 0)
			nPesDist := Round((nPesDiverg / len(aItems)), 4)
			for nX := 1 to len(aItems)
				aAdd(aItems[nX], Round((aProd[nX, 12] / nPesAItems),4))
			next nX
			if lAutoDist
				for nX := 1 to len(aItems)
					nPosi := len(aItems[nX])
					aItems[nX, 12] += Round((nPesDiverg * aItems[nX, nPosi]),4)
				next nX
				nPosi := 0
			else
				usrDivDist(@aItems, nPesDiverg)
			endif
			for nX := 1 to len(aItems)
				if (nPosi := aScan(aProd,{|x| x[01] == aItems[nX, 01] .and. x[02] == aItems[nX, 02]})) > 0
					aProd[nPosi, 12] := aItems[nX, 12]
				endif
			next nX
		endif
	endif
	RestArea(aAreaSB1)
	RestArea(aArea)
return(nil)


static function usrDivDist(aItems, nPesDiverg)
	local aArea    	:= GetArea()
	local aRet      := {}
    local aPerg     := {}
	local nX		:= 0
	local ndoneDiv	:= 0
	local lContinue	:= .T.

	while lContinue
		aRet      	:= {}
		aPerg     	:= {}
		ndoneDiv	:= 0
		for nX := 1 to len(aItems)    	
			aAdd(aPerg,{1,StrZero(aItems[nX,01], 2) + "-(" + AllTrim(cValToChar(aItems[nX, 02])) + ")-" + AllTrim(aItems[nX, 04]),; 
						aItems[nX, 12],PesqPict('SF2','F2_PLIQUI'), ".T.","",".T.",,.F., aItems[nX]})
		next nX
		if !(myParamBox(aPerg, nPesDiverg, @aRet))
			lContinue := !(MsgYesNo('Cancelar a distribuição da divergência de Peso de: ' + cValtoChar(nPesDiverg),; 
									'Distribuição Cancelada'))
		else
			for nX := 1 to len(aRet)
				ndoneDiv += (aRet[nX] - aItems[nX, 12])
			next nX
			if (Round(ndoneDiv,2) <> Round(nPesDiverg,2))
				lContinue := !(MsgYesNo('Confirma a distribuição parcial da divergência: ' + cValToChar(Round(ndoneDiv,2)) + ' de: ' + cValtoChar(Round(nPesDiverg,2)),;
										'Distribuição Incompleta'))
			else
				lContinue := .F.
			endif
			if !lContinue
				for nX := 1 to len(aItems) 
					aItems[nX, 12] := aRet[nX]
				next nX
			endif
		endif
	endDo
	
    RestArea(aArea)
return(nil)

static function sugestDist(aItem, nPesDiverg)
	local nPesSug := 0
	local nPosi	  := 0

	nPosi 	:= len(aItem)
	nPesSug := Round(aItem[12] + Round((nPesDiverg * aItem[nPosi]),4),4)
return(nPesSug)

static function myParamBox(aPerg, nPesDiverg, aRet)
	local oModal 	:= nil
	local oPanel	:= nil
	local oCab1     := nil
	local oCab2     := nil
	local oCab3     := nil
	local oCab4     := nil
	local cTextSay	:= ''
	local cBlkGet	:= ''
	local nLinha	:= 8
	local nX 		:= 0
	local nWidth	:= 60
	local cBlKVld 	:= ''
	local cBlKWhen	:= ''
	local cTxtSayO	:= ''
	local cTxtSayD	:= ''
	local cF3		:= ''
	local lConfirm	:= .F.
	local oFont1	:= TFont():New("Arial",,20,,.T.)
	local oFont2	:= TFont():New("Arial",,15,,.T.)
	default aRet	:= {}

	oModal	:= FWDialogModal():New() 
	oModal:setSize(350,435)
	oModal:SetEscClose(.T.)
	oModal:setTitle('Divergência Peso Teórico x NF - Total a Distribuir: ' + cValToChar(nPesDiverg))
	oModal:nFontTitleSize := 25
	oModal:createDialog()
	oModal:addCloseButton(nil, "Cancelar")
	oModal:addOkButton({|| iif(lConfirm := .T., oModal:DeActivate(),oModal:DeActivate()) }, "Confirmar", {||.T.} )
	oPanel := TScrollBox():New( oModal:getPanelMain(), 8,10,104,203)
	oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	oCab1 := TSay():New( nLinha, 15 , {|| 'Item'} , oPanel , ,oFont1,,,,.T.,CLR_BLACK,,200,,,,,,)
	oCab2 := TSay():New( nLinha, (205) , {|| 'Quantidade '} , oPanel , ,oFont1,,,,.T.,CLR_BLACK,,nWidth,,,,,,)
	oCab3 := TSay():New( nLinha, (210 + nWidth) , {|| 'Qtd Atual NF'} , oPanel , ,oFont1,,,,.T.,CLR_BLACK,,nWidth,,,,,,)
	oCab4 := TSay():New( nLinha, (215 + (nWidth * 2)) , {|| 'Qtd Sugerida'} , oPanel , ,oFont1,,,,.T.,CLR_BLACK,,nWidth,,,,,,)
	nLinha += 17

	for nX := 1 to len(aPerg)
		SetPrvt("myMV_PAR" + StrZero(nX,2,0))
		SetPrvt("myoGet" + StrZero(nX,2,0))
		SetPrvt("myoSay" + StrZero(nX,2,0))		
		&("myMV_PAR"+StrZero(nX,2,0)) := aPerg[nX, 3]
		cTextSay:= "{||'"+StrTran(aPerg[nX,2],"'",'"')+": "+"'}"
		&("myoSay" + StrZero(nX,2,0)) := TSay():New( (nLinha+03), 15 , MontaBlock(cTextSay) , oPanel , ,oFont2,,,,.T.,CLR_BLACK,,200,,,,,,)
		cBlkGet := "{ | u | If( PCount() == 0, "+"myMV_PAR"+AllTrim(StrZero(nX,2,0))+","+"myMV_PAR"+StrZero(nX,2,0)+":= u ) }"
		cBlKVld := "{|| "+Iif(Empty(aPerg[nX,5]),".T.",aPerg[nX,5])+"}"
		cBlKWhen:= "{|| "+Iif(Empty(aPerg[nX,7]),".T.",aPerg[nX,7])+"}"
		cF3		:=Iif(Empty(aPerg[nX,6]),NIL,aPerg[nX,6])
		&("myoGet" + StrZero(nX,2,0)) := TGet():New( nLinha,205,&cBlKGet,oPanel,nWidth,,aPerg[nX,4], &(cBlkVld),,,oFont2, .T.,, .T.,, .T., &(cBlkWhen), .F., .F.,, .F., .F. ,cF3,"myMV_PAR"+StrZero(nX,2,0),,,,.T.,.F.)
		if aPerg[nX, 01] == 1
			SetPrvt("myoGetO" + StrZero(nX,2,0))
			SetPrvt("myoGetS" + StrZero(nX,2,0))
			cTxtSayO := "{||" + cValToChar(aPerg[nX, 3]) + "}"
			&("myoGetO" + StrZero(nX,2,0)) := TGet():New( nLinha,(210 + nWidth),&(cTxtSayO),oPanel,nWidth,,aPerg[nX,4], /*&(cBlkVld)*/,,,oFont2, .T.,, .T.,, .T., {||.F.}/*&(cBlkWhen)*/, .F., .F.,, .F./*ReadOnly*/, .F. ,,""/*cVariavel*/,,,,.F.,.T.)
			cTxtSayD := "{||" + cValToChar(sugestDist(aPerg[nX, len(aPerg[nX])], nPesDiverg)) + "}"
			&("myoGetO" + StrZero(nX,2,0)) := TGet():New( nLinha,(215 + (nWidth * 2)),&(cTxtSayD),oPanel,nWidth,,aPerg[nX,4], /*&(cBlkVld)*/,,,oFont2, .T.,, .T.,, .T.,{||.F.} /*&(cBlkWhen)*/, .F., .F.,, .F./*ReadOnly*/, .F. ,,""/*cVariavel*/,,,,.F.,.T.)
		endif
		nLinha += 17
	next nX

	applyCss(@oModal:oSayTitle)
   	applyCss(@oModal:oTop)
	   
	oModal:Activate()
	
    if lConfirm
        aRet := Array(Len(aPerg))
        for nX := 1 to Len(aPerg)
            aRet[nX] := &("myMV_PAR"+StrZero(nX,2,0))
        next nX
    endif

	FreeObj(oCab1)
	FreeObj(oCab2)
	FreeObj(oCab3)
	FreeObj(oCab4)
	FreeObj(oPanel)
	FreeObj(oModal)
return(lConfirm)

static function applyCss(oObj)
	local cCss 		:= ''
	local cTpObj 	:= GetClassName(oObj)
	
	if cTpObj == "TBUTTON"
			cCSS :=	"QPushButton {";
								+"  color: #FFFFFF; /*Cor da fonte*/";
								+"  border: 2px solid #a3adb5; /*Cor da borda*/";
								+"  border-radius: 6px; /*Arrerondamento da borda*/";
								+"  font-size: 24px; /*Tamanho da fonte*/";
								+"  color: #FFFFFF; /*Cor da fonte*/";
								+"  font-weight: bold; /*Negrito*/";
								+"  text-align: center; /*Alinhamento*/";
								+"  vertical-align: middle; /*Alinhamento*/";
								+"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
								+"                                    stop: 0 #a3adb5, stop: 1 #f5f6f7); /*Cor de fundo*/";
								+"  min-width: 80px; /*Largura minima*/";
								+"}";
								+"/* Acoes quando pressionado botao, aqui mudo a cor de fundo */";
								+"QPushButton:pressed {";
								+"  background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1,";
								+"                                    stop: 0 #f5f6f7 stop: 1 #a3adb5);";
								+"}"		
	elseif cTpObj == "TSAY"
			cCss +=	"QLabel { ";
						+"  font-size: 24px; /*Tamanho da fonte*/";
						+"  color: #FFFFFF; /*Cor da fonte*/";
						+"  font-weight: bold; /*Negrito*/";
						+"  text-align: center; /*Alinhamento*/";
						+"  vertical-align: middle; /*Alinhamento*/";
						+"  border-radius: 6px; /*Arrerondamento da borda*/";
						+"}"
	elseif cTpObj == "TPANEL"
			cCss +=	 "QFrame {";
								+" color: #FFFFFF; /*Cor da fonte*/ ";
								+" background-color: #00297c;";	
								+" border: 2px solid #00297c; /*Cor da borda*/";	  						
		  						+" border-radius: 6px; /*Arrerondamento da borda*/ ";
		                      +" } "
	endif	
	if !empty(cCss)
		oObj:SetCSS(cCss)
	endif
return(oObj)
