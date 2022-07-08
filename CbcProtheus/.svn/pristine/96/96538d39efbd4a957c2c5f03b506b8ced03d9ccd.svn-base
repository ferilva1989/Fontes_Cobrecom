#include "rwmake.ch"
static cDrive := if(U_zIs12(),'CTREECDX','')
/*/{Protheus.doc} CDGEN19
//TODO Rotima para transferência do custo do inventário para o SB7 do mes. .
@author Roberto Oliveira 
@since 26/08/2013 
@version undefined

@type function
/*/
User Function CDGEN19()

	If !AllTrim(cUserName)+"|" $ GetMV("MV_USERADM") .And. !"VANIA" $ Upper(cUserName)
		Alert("Somente Vania pode Executar")
		Return(.T.)
	EndIf
	If !u_IncInv()
		Return(.T.)
	EndIf
	_UltFech := GetMv("MV_ULMES")

	If MV_PAR01 <= _UltFech
		Alert("Data Inválida: Data Inventário Anterior ao Último Fechamento de Estoque")
		Return(.T.)
	EndIf

	DbSelectArea("SB7")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE

	If !DbSeek(xFilial("SB7")+Dtos(MV_PAR01),.F.)
		Alert("Data Inválida: Não há Inventário em " + Dtoc(MV_PAR01))
		Return(.T.)
	EndIf

	Processa( {|| ZereCst()},"Zerando Custo da Tabela SB7...")
	Processa( {|| TrfCst0() },"Atualizando Custos do Inventário...")
Return(.T.)

/*/{Protheus.doc} ZereCst
//TODO Descrição auto-gerada.
@author ZZZ
@since 06/06/2017
@version undefined

@type function
/*/
Static Function ZereCst()

	DbSelectArea("SB7")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	ProcRegua(LastRec())
	SB7->(DbSeek(xFilial("SB7")+Dtos(MV_PAR01),.T.))
	Do While SB7->B7_FILIAL == xFilial("SB7") .And. SB7->B7_DATA == MV_PAR01 .And. SB7->(!Eof())
		IncProc()
		If SB7->B7_CSTINV # 0.00
			RecLock("SB7",.F.)
			SB7->B7_CSTINV := 0.00
			MsUnLock()
		EndIf
		SB7->(DbSkip())
	EndDo
Return(.T.)

/*/{Protheus.doc} TrfCst0
//TODO Descrição auto-gerada.
@author ZZZ
@since 06/06/2017
@version undefined

@type function
/*/
Static Function TrfCst0()

	DbSelectArea("SB1")
	DbSetOrder(1) //B1_FILIAL+B1_COD

	DbSelectArea("SB7")
	DbSetOrder(1) // B7_FILIAL+ DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE
	ProcRegua(LastRec())
	DbSeek(xFilial("SB7")+Dtos(MV_PAR01),.T.)
	Do While SB7->B7_FILIAL == xFilial("SB7") .And. SB7->B7_DATA == MV_PAR01 .And. SB7->(!Eof())
		IncProc()
		SB1->(DbSeek(xFilial("SB1")+SB7->B7_COD,.F.))
		RecLock("SB7",.F.)
		If cFilAnt == "01"   // Itu
			SB7->B7_CSTINV := SB1->B1_CSTINVI // Itu
		Else
			SB7->B7_CSTINV := SB1->B1_CSTINV3 // 3 Lagoas
		EndIf
		MsUnLock()
		SB7->(DbSkip())
	EndDo
Return(.T.)


/*/{Protheus.doc} CriaPln
//TODO Descrição auto-gerada.
@author ZZZ
@since 06/06/2017
@version undefined

@type function
/*/
User Function CriaPln()
	local cNomArqv   := GetTempPath()+'PlanInvent_' + dToS(Date()) + "_" + StrTran(Time(), ':', '-')+ '.xml'
	local oFWMsExcel := nil
	local oExcel     := nil
	local cSheet	 := ''
	
	cPerg := "CDGN09"
	_lPerg := Pergunte(cPerg, .T.)
	If !_lPerg
		Return(.T.)
	EndIf

	//_cTipo := "A"  // Analítico ou Sintético
	_cTipo := "S"  // Analítico ou Sintético

	SB1->(DbSetOrder(1))
	SZ1->(DbSetOrder(1))
	SZ2->(DbSetOrder(1))

	aStruTrb := {}
	AADD(aStruTrb,{"FILIAL","C",02,0} )
	AADD(aStruTrb,{"DTINV" ,"D",08,0} )
	AADD(aStruTrb,{"LOCAL" ,"C",TamSX3("B1_LOCPAD")[1],0} )
	AADD(aStruTrb,{"CODIGO","C",TamSX3("B1_COD")[1],0} )
	AADD(aStruTrb,{"DESC"  ,"C",TamSX3("B1_DESC")[1],0} )
	AADD(aStruTrb,{"TIPO"  ,"C",TamSX3("B1_TIPO")[1],0} )
	AADD(aStruTrb,{"UNID"  ,"C",TamSX3("B1_UM")[1],0} )
	AADD(aStruTrb,{"QUANT" ,"N",12,4} )
	AADD(aStruTrb,{"CSTUNI","N",12,4} )
	AADD(aStruTrb,{"PESCOB","N",12,4} )

	if U_zIs12()
		cNomTrb0 := AllTrim(CriaTrab(,.F.))
		FWDBCreate( cNomTrb0 , aStruTrb , "CTREECDX")
	else
		cNomTrb0 := CriaTrab(aStruTrb)
	endif
	
	dbUseArea(.T., cDrive ,cNomTrb0,"TRB",.F.,.F.) // Abre o arquivo de forma exclusiva
		
	DbSelectArea("TRB")
	cInd := CriaTrab(NIL,.F.)
	IndRegua("TRB",cInd,"FILIAL+DTOS(DTINV)+LOCAL+CODIGO",,,"Selecionando Registros...")

	_cGrupos := ""
	_dDtInv := MV_PAR01

	For _nFil := 1 to 3
		_cFil := StrZero(_nFil,2)

		DbSelectArea("SB7")
		DbSetOrder(1) // B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE+B7_CONTAGE
		DbSeek(_cFil+DTOS(MV_PAR01),.F.)

		Do While SB7->B7_FILIAL == _cFil .And. SB7->B7_DATA == MV_PAR01 .And. ! SB7->(Eof())

			If  (SB7->B7_LOCAL $ "04//95//") // Não enviar 95
				SB7->(DbSkip())
				Loop
			ElseIf  (SB7->B7_LOCAL $ "90//98//" .And. SB7->B7_SLDANT <= 0)
				SB7->(DbSkip())
				Loop
			ElseIf !(SB7->B7_LOCAL $ "90//98//") .And. SB7->B7_QUANT  <= 0
				SB7->(DbSkip())
				Loop
			EndIf

			If !SB1->(DbSeek(xFilial("SB1")+SB7->B7_COD,.F.))
				_xxx:= 1
				SB7->(DbSkip())
				Loop
			EndIf

			_cLoc := SB1->B1_POSINV

			If _cLoc $  "01/02" // Retalhos ou Produtos acabados
				If Left(SB7->B7_LOCALIZ,1) == "T" // Retalhos
					_cLoc := "01"
				Else
					_cLoc := "02" // PA
				EndIf
			ElseIf Empty(_cLoc)
				If Left(SB7->B7_COD,1) == "Q" .And. SB1->B1_TIPO == "PI"
					If SB7->B7_LOCAL == "99"
						_cLoc := "03" // Processo
					ElseIf SB7->B7_LOCAL == "95"
						_cLoc := "04" // ESA
					ELSE
						_cLoc := "03" // Processo
					EndIf
				Else
					_cLoc := "99"
				EndIf
			EndIf

			If !SB7->B7_FILIAL+_cLoc $ _cGrupos
				DbSelectArea("SX5")
				DbSeek(xFilial("SX5")+"ZO"+_cLoc,.F.)
				RecLock("TRB",.T.)
				TRB->FILIAL := SB7->B7_FILIAL
				TRB->DTINV  := _dDtInv // SB7->B7_DATA
				TRB->CODIGO := "0" // para poder classificar corretamente na planilha
				TRB->DESC   := SX5->X5_DESCRI
				TRB->LOCAL  := _cLoc
				MsUnLock()
				_cGrupos :=  _cGrupos + "//" + SB7->B7_FILIAL + _cLoc
			EndIf 

			_cCod   := SB7->B7_COD
			_cDESCR := SB1->B1_DESC

			If _cTipo == "S"  // Sintético
				If (Left(SB7->B7_COD,1) == "Q" .And. SB1->B1_TIPO == "PI") .Or. SB1->B1_TIPO == "PA"
					_cCod := AllTrim(SB7->B7_COD)
					If Left(SB7->B7_COD,1) == "Q"
						_cNom := Substr(SB1->B1_COD,2,3)
						_cBit := Substr(SB1->B1_COD,5,2)
						_cCod := Left(SB7->B7_COD,6) //+ "XX" + Right(_cCod,3)
					Else
						_cNom := Substr(SB1->B1_COD,1,3)
						_cBit := Substr(SB1->B1_COD,4,2)
						_cCod := Left(SB7->B7_COD,5) //+ "XX" + Right(_cCod,3)
					EndIf

					SZ1->(DbSeek(xFilial("SZ1")+_cNom,.F.))
					SZ2->(DbSeek(xFilial("SZ2")+_cBit,.F.))
					If SZ1->(!Eof()) .And. SZ2->(!Eof())
						_cDESCR   :=  AllTrim(SZ1->Z1_DESC) + " " + SZ2->Z2_DESC
					EndIf
				EndIf
				_cCod := Left(_cCod + Space(40),Len(SB7->B7_COD)) // Completa o tamnaho da variável
			EndIf

			DbSelectArea("TRB")

			//If !DbSeek(SB7->B7_FILIAL+Dtos(SB7->B7_DATA)+_cLoc+_cCod,.F.)
			If !DbSeek(SB7->B7_FILIAL+Dtos(_dDtInv)+_cLoc+_cCod,.F.)
				RecLock("TRB",.T.)
				TRB->FILIAL := SB7->B7_FILIAL
				TRB->DTINV  := _dDtInv//SB7->B7_DATA
				TRB->CODIGO := _cCod
				TRB->DESC   := _cDESCR
				TRB->LOCAL  := _cLoc
				TRB->TIPO   := SB1->B1_TIPO
				TRB->UNID   := SB1->B1_UM
			Else
				RecLock("TRB",.F.)
			EndIf

			// Alteração referente as novas definições (bl-k)
			If SB7->B7_LOCAL $ "90//98" // Armazéns que os saldos não são atualizados
				TRB->QUANT  := TRB->QUANT + SB7->B7_SLDANT
			ElseIf !SB7->B7_LOCAL $ "04//95"
				TRB->QUANT  := TRB->QUANT + SB7->B7_QUANT
			EndIf

			If TRB->CSTUNI == 0
				TRB->CSTUNI := If(SB7->B7_FILIAL=="01",SB1->B1_CSTINVI,SB1->B1_CSTINV3)
			EndIf

			TRB->PESCOB := TRB->QUANT * SB1->B1_PESCOB
			MsUnLock()
			DbSelectArea("SB7")
			DbSkip()
		EndDo
	Next
	
	DbSelectArea("TRB")
	TRB->(DbGoTop())
	
	oFWMsExcel := FWMSExcel():New()
	
    oFWMsExcel:AddworkSheet("Itu")
    oFWMsExcel:AddTable("Itu","Contagens")
    oFWMsExcel:AddColumn("Itu","Contagens","FILIAL",1)
    oFWMsExcel:AddColumn("Itu","Contagens","DTINV",1)
    oFWMsExcel:AddColumn("Itu","Contagens","LOCAL",1)
    oFWMsExcel:AddColumn("Itu","Contagens","CODIGO",1)
    oFWMsExcel:AddColumn("Itu","Contagens","DESC",1)
    oFWMsExcel:AddColumn("Itu","Contagens","TIPO",1)        
    oFWMsExcel:AddColumn("Itu","Contagens","UNID",1)
    oFWMsExcel:AddColumn("Itu","Contagens","QUANT",1)
    oFWMsExcel:AddColumn("Itu","Contagens","CSTUNI",1)
    oFWMsExcel:AddColumn("Itu","Contagens","PESCOB",1)
    
    oFWMsExcel:AddworkSheet("TL")
    oFWMsExcel:AddTable("TL","Contagens")
    oFWMsExcel:AddColumn("TL","Contagens","FILIAL",1)
    oFWMsExcel:AddColumn("TL","Contagens","DTINV",1)
    oFWMsExcel:AddColumn("TL","Contagens","LOCAL",1)
    oFWMsExcel:AddColumn("TL","Contagens","CODIGO",1)
    oFWMsExcel:AddColumn("TL","Contagens","DESC",1)
    oFWMsExcel:AddColumn("TL","Contagens","TIPO",1)        
    oFWMsExcel:AddColumn("TL","Contagens","UNID",1)
    oFWMsExcel:AddColumn("TL","Contagens","QUANT",1)
    oFWMsExcel:AddColumn("TL","Contagens","CSTUNI",1)
    oFWMsExcel:AddColumn("TL","Contagens","PESCOB",1)

	oFWMsExcel:AddworkSheet("MG")
    oFWMsExcel:AddTable("MG","Contagens")
    oFWMsExcel:AddColumn("MG","Contagens","FILIAL",1)
    oFWMsExcel:AddColumn("MG","Contagens","DTINV",1)
    oFWMsExcel:AddColumn("MG","Contagens","LOCAL",1)
    oFWMsExcel:AddColumn("MG","Contagens","CODIGO",1)
    oFWMsExcel:AddColumn("MG","Contagens","DESC",1)
    oFWMsExcel:AddColumn("MG","Contagens","TIPO",1)        
    oFWMsExcel:AddColumn("MG","Contagens","UNID",1)
    oFWMsExcel:AddColumn("MG","Contagens","QUANT",1)
    oFWMsExcel:AddColumn("MG","Contagens","CSTUNI",1)
    oFWMsExcel:AddColumn("MG","Contagens","PESCOB",1)
    
    While !(TRB->(EoF()))
        if TRB->FILIAL == '01'
        	cSheet := 'Itu'
        elseif TRB->FILIAL == '02'
        	cSheet := 'TL'
		else
			cSheet := 'MG'
        endif
        oFWMsExcel:AddRow(cSheet,"Contagens",{;
											    TRB->FILIAL,;
											    TRB->DTINV,;
											    TRB->LOCAL,;
											    TRB->CODIGO,;
											    TRB->DESC,;
											    TRB->TIPO,;       
											    TRB->UNID,;
											    TRB->QUANT,;
											    TRB->CSTUNI,;
											    TRB->PESCOB;
											  })
     
        //Pulando Registro
        TRB->(DbSkip())
    EndDo
     
    oFWMsExcel:Activate()
    oFWMsExcel:GetXMLFile(cNomArqv)
         
    oExcel := MsExcel():New()
    oExcel:WorkBooks:Open(cNomArqv)
    oExcel:SetVisible(.T.)
    oExcel:Destroy()   
	
	FreeObj(oFWMsExcel)
	FreeObj(oExcel)
	
	DbSelectArea("TRB")
	TRB->(DbGoTop())	
	DbCloseArea("TRB")
	_cArqNew := "E:\"
	CPYS2T(cNomTrb0+".DTC",_cArqNew,.F.)	
	Alert(Dtos(MV_PAR01) + "   " + cNomTrb0+".DTC")
Return(.T.)


/*/{Protheus.doc} B1LOC
//TODO Descrição auto-gerada.
@author ZZZ
@since 06/06/2017
@version undefined

@type function
/*/
USER FUNCTION B1LOC()
	DbSelectArea("SB1")
	DbSetOrder(1)

	cInd := CriaTrab(Nil, .F.)
	DbUseArea(.T.,cDrive,"\CONDUSUL\INVENT07\JULHO.DTC","TRB",.T.,.F.)
	IndRegua("TRB",cInd,"FILIAL+DATA+LOCAL+CODIGO",,,"Selecionando Registros...")

	DbGoTop()
	Do While TRB->(!Eof())

		If SB1->(DbSeek(xFilial("SB1")+TRB->CODIGO,.F.))
			If RecLock("SB1",.F.)
				SB1->B1_POSINV := TRB->LOCAL
				If TRB->FILIAL == "01"
					SB1->B1_CSTINVI := TRB->CUSTO
				Else
					SB1->B1_CSTINV3 := TRB->CUSTO
				EndIf
				MsUnLock()
			Else
				Alert("não Travou")
			EndIf
		Else
			Alert("eoF")
		EndIf
		TRB->(DbSkip())
	EndDo
	DbSelectArea("TRB")
	DbCloseArea()
Return(.T.)
