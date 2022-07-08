#include "rwmake.ch" 
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"                                     

User Function Barcode3Col()
	Local lAdjustToLegacy	:= .F.
	//Se .T. não exibe a tela de setup cabe ao programado chamar
	Local lDisableSetup		:= .T.
	Local oPrinter
	Local cLocal			:= "\spool"
	Local nLin				:= 05 
	Local nCol				:= 0
	Local cAlias    		:= getNextAlias() //cria um alias temporário
	Local cTipoMaq			:= ""                
	Local cDescMaq			:= ""

	//Inicialização do objeto de impressão
	oPrinter := FWMSPrinter():New("Barcode.rel", IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup, , , , , , .F., )
	oPrinter:StartPage()
	//Defini o Tipo da folha
	oPrinter:setPaperSize(9)

	BeginSql Alias cAlias
	SELECT
	H1_CODPPI,
	H1_DESCRI,
	H1_LINHAPR
	FROM
	%table:SH1%
	WHERE
	H1_FILIAL = %xFilial:SH1%
	AND H1_CODPPI 	 <> '' 
	AND D_E_L_E_T_ = '' 
	AND H1_LINHAPR <> 'ER'
	ORDER BY
	H1_LINHAPR, H1_CODPPI
	EndSql	   

	(cAlias)->(dbGoTop())  

	//nLin = 05
	//nCol = 05/20/35

	//Defini o Tipo da folha	
	oFont1 := TFont():New( "Courier New", , -18, .T.)

	If (Alltrim((cAlias)->H1_LINHAPR)) = "ENC"
		cDescMaq := " ENCORDAMENTO"   
	EndIf
	If (Alltrim((cAlias)->H1_LINHAPR)) = "EXT"
		cDescMaq := " EXTRUSÂO"
	EndIf
	If (Alltrim((cAlias)->H1_LINHAPR)) = "FR"
		cDescMaq := " CORTE/FRACIONAMENTO"
	EndIf
	If (Alltrim((cAlias)->H1_LINHAPR)) = "SPA"
		cDescMaq := " SPAMA"      
	EndIf
	If (Alltrim((cAlias)->H1_LINHAPR)) = "TF"
		cDescMaq := " TREFILA FINA"
	EndIf
	If (Alltrim((cAlias)->H1_LINHAPR)) = "TG"
		cDescMaq := " TREFILA GROSSA" 
	EndIf
	If cDescMaq = ""
		cDescMaq := " ERRO"
	EndIf

	oPrinter:Say( 20, 10, "COBRECOM - Codigo Maquinas - " + cDescMaq, oFont1, 1400, CLR_HBLUE)
	cTipoMaq := (Alltrim((cAlias)->H1_LINHAPR))   

	While (nLin <= 60).and.!(cAlias)->(Eof()) 
		//Inicialização do objeto de impressão
		nCol := 05
		while (nCol <= 30).and.!(cAlias)->(Eof()) 
			//Define a impressão do codigo de barras 
			oPrinter:FWMSBAR("Code128" /*cTypeBar*/,nLin/*nRow*/ ,nCol/*nCol*/, alltrim((cAlias)->H1_CODPPI)/*cCode*/,oPrinter/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.02/*nWidth*/,0.8/*nHeigth*/,.T./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/) 
			nCol += 25  
			cTipoMaq := (Alltrim((cAlias)->H1_LINHAPR))     
			(cAlias)->(dbSkip())
			If (Alltrim((cAlias)->H1_LINHAPR) <> cTipoMaq).and.(!(cAlias)->(Eof()))
				oPrinter:EndPage() 
				oPrinter:StartPage()                                                                    
				If (Alltrim((cAlias)->H1_LINHAPR)) = "ENC"
					cDescMaq := " ENCORDAMENTO"   
				EndIf
				If (Alltrim((cAlias)->H1_LINHAPR)) = "EXT"
					cDescMaq := " EXTRUSÂO"
				EndIf
				If (Alltrim((cAlias)->H1_LINHAPR)) = "FR"
					cDescMaq := " CORTE/FRACIONAMENTO"
				EndIf
				If (Alltrim((cAlias)->H1_LINHAPR)) = "SPA"
					cDescMaq := " SPAMA"      
				EndIf
				If (Alltrim((cAlias)->H1_LINHAPR)) = "TF"
					cDescMaq := " TREFILA FINA"
				EndIf
				If (Alltrim((cAlias)->H1_LINHAPR)) = "TG"
					cDescMaq := " TREFILA GROSSA" 
				EndIf
				If cDescMaq = ""
					cDescMaq := " ERRO"
				EndIf
				oPrinter:Say( 20, 10, "COBRECOM - Codigo Maquinas - "+cDescMaq, oFont1, 1400, CLR_HBLUE)
				nLin := 05
				nCol := 05	
			EndIf
		Enddo

		nLin += 05 

		If (!(cAlias)->(Eof())).and.(nLin>=60) 		  
			oPrinter:EndPage() 
			oPrinter:StartPage()
			nLin := 05        
		EndIf
	enddo             

	oPrinter:EndPage()     
	(cAlias)->(dbCloseArea())

	oPrinter:Setup()

	if oPrinter:nModalResult == PD_OK
		oPrinter:Preview()
	EndIf 

Return (.T.) 

User Function Barcode2Col()
	Local lAdjustToLegacy	:= .F.
	//Se .T. não exibe a tela de setup cabe ao programado chamar
	Local lDisableSetup		:= .T.
	Local oPrinter
	Local cLocal    		:= "\spool"
	Local nLin				:= 05 
	Local nCol				:= 0
	Local cAlias    		:= getNextAlias() //cria um alias temporário

	//Inicialização do objeto de impressão
	oPrinter := FWMSPrinter():New("Barcode.rel", IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup, , , , , , .F., )
	oPrinter:StartPage()
	//Defini o Tipo da folha
	oPrinter:setPaperSize(9)

	BeginSql Alias cAlias
	SELECT
	H1_CODPPI,
	H1_DESCRI
	FROM
	%table:SH1%
	WHERE
	H1_FILIAL = %xFilial:SH1%
	AND H1_CODPPI 	 <> '' 
	AND D_E_L_E_T_ = ''
	ORDER BY
	H1_CODPPI
	EndSql	   

	(cAlias)->(dbGoTop())  

	//nLin = 05
	//nCol = 05/20/35

	//Defini o Tipo da folha	
	oFont1 := TFont():New( "Courier New", , -18, .T.)
	oPrinter:Say( 20, 10, "COBRECOM - Codigo Maquinas", oFont1, 1400, CLR_HBLUE)


	While (nLin <= 60).and.!(cAlias)->(Eof()) 
		//Inicialização do objeto de impressão
		nCol := 05
		while (nCol <= 35).and.!(cAlias)->(Eof()) 
			//Define a impressão do codigo de barras 
			oPrinter:FWMSBAR("Code128" /*cTypeBar*/,nLin/*nRow*/ ,nCol/*nCol*/, alltrim((cAlias)->H1_CODPPI)/*cCode*/,oPrinter/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.02/*nWidth*/,0.8/*nHeigth*/,.T./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/) 
			nCol += 15  
			(cAlias)->(dbSkip())
		enddo

		nLin += 5 

		If (!(cAlias)->(Eof())).and.(nLin>=60) 		  
			oPrinter:EndPage() 
			oPrinter:StartPage()
			nLin := 05        
		EndIf
	enddo             

	oPrinter:EndPage()     
	(cAlias)->(dbCloseArea())

	oPrinter:Setup()

	if oPrinter:nModalResult == PD_OK
		oPrinter:Preview()
	EndIf 

Return (.T.)             

User Function Barcode(Campo,Tabela)
	Local lAdjustToLegacy	:= .F.
	//Se .T. não exibe a tela de setup cabe ao programado chamar
	Local lDisableSetup  	:= .T.
	Local oPrinter
	Local cLocal    		:= "\spool"
	Local nLin				:= 05 
	Local nCol				:= 0    
	Local nLin2				:= 55
	Local nCol2				:= 30
	Local cAlias    		:= getNextAlias() //cria um alias temporário
	Local _oFont1           := TFont():New( 'Courier New', , 7, .T.)


	//Inicialização do objeto de impressão
	oPrinter := FWMSPrinter():New("Barcode.rel", IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup, , , , , , .F., )
	oPrinter:StartPage()
	//Defini o Tipo da folha
	oPrinter:setPaperSize(9)

	BeginSql Alias cAlias
	SELECT
	RA_MAT,
	RA_NOME
	FROM
	%table:SRA%
	WHERE
	RA_FILIAL = %xFilial:SH1%
	AND RA_DEMISSA = '' 
	AND D_E_L_E_T_ = ''
	ORDER BY
	RA_NOME      
	EndSql	   

	(cAlias)->(dbGoTop())  

	//nLin = 05
	//nCol = 05/20/35

	//Defini o Tipo da folha	
	oFont1 := TFont():New( "Courier New", , -18, .T.)
	oPrinter:Say(20, 10, "COBRECOM - Codigo Operador", oFont1, 1400, CLR_HBLUE)

	While (nLin <= 60).and.!(cAlias)->(Eof()) 
		//Inicialização do objeto de impressão
		nCol 	:= 05           
		nCol2	:= 40
		while (nCol <= 35).and.!(cAlias)->(Eof()) 
			//Define a impressão do codigo de barras 
			oPrinter:FWMSBAR("Code128" /*cTypeBar*/,nLin/*nRow*/ ,nCol/*nCol*/, alltrim((cAlias)->RA_MAT)/*cCode*/,oPrinter/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.02/*nWidth*/,0.4/*nHeigth*/,.T./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/) 
			//FWMsPrinter(): Say ( < nRow>, < nCol>, < cText>, [ oFont], [ nWidth], [ nClrText], [ nAngle] )
			//oPrinter:Say(nLin2,nCol2+10,Alltrim((cAlias)->RA_MAT)+ " - "+Substr(Alltrim((cAlias)->RA_NOME),1,25), _oFont1, 1400)
			nCol	+=	30  
			nCol2 	+=	300
			(cAlias)->(dbSkip())
		enddo

		nLin 	+=	3 
		nLin2 	+=	10                  

		If (!(cAlias)->(Eof())).and.(nLin>=60) 		  
			oPrinter:EndPage() 
			oPrinter:StartPage()
			nLin 	:= 03
			nLin2	:= 55        
		EndIf
	enddo             

	oPrinter:EndPage()     
	(cAlias)->(dbCloseArea())

	oPrinter:Setup()

	if oPrinter:nModalResult == PD_OK
		oPrinter:Preview()
	EndIf 

Return (.T.)     