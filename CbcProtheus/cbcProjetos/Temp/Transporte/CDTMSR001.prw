#include "rwmake.ch"
#include "AVPRINT.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CDTMSR01   �Autor  � rOBERTO oLIVEIRA  � Data �  22/06/12   ���
�������������������������������������������������������������������������͹��
���Desc.     � Relat�rio Termo de Responsabilidade                        ���
�������������������������������������������������������������������������͹��
���Uso       �                                                            ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/ 
*
*******************************
User Function CDTMSR01(lReimpr)
*******************************
*                               
DEFAULT lReimpr := .F.

DbSelectArea("ZZ4")
aArea   := GetArea()
Titulo := "Impress�o de Termo de Responsabilidade"
// Na p�gina ser�o impressos at� 3 termos nas linhas 0, 1168 e 2336 - intervalo de 1168 pixels entre eles
If lReimpr
	If Empty(ZZ4->ZZ4_NROTER)
		Alert("Para esse Termo Use a Op��o Imprimir")
		Return(.T.)
	EndIf
	MV_PAR01 := ZZ4->ZZ4_DOC
	MV_PAR02 := ZZ4->ZZ4_DOC
	u_CDTMSR1a(lReimpr)
Else
	// Verifica se tem itens a serem impressos
	DbSelectArea("ZZ4")
	DbSetOrder(3) // ZZ4_FILIAL+ZZ4_NROTER
	If !DbSeek(xFilial("ZZ4")+Space(Len(ZZ4->ZZ4_NROTER)),.F.)
		Alert("N�o h� Dados a Serem Impressos")
		RestArea(aArea)
		Return(.T.)
	EndIf
	DbSetOrder(1) // ZZ4_FILIAL+ZZ4_DOC+ZZ4_SERIE
	cPerg := "CDTM01"

	PutSX1(cPerg,"01","Da Nota Fiscal?","Da Nota Fiscal?","Da Nota Fiscal?","mv_ch1","C",06,0,0,"G","",""   ,"","",;
	             "mv_par01","","","","","","","","","","","","","","","","",{"Numero da Nota Inicial"},;
	             {"Numero da Nota Inicial"},{"Numero da Nota Inicial"})
	PutSX1(cPerg,"02","At� a Nota Fiscal?","At� a Nota Fiscal?","At� a Nota Fiscal?","mv_ch2","C",06,0,0,"G","",""   ,"","",;
	             "mv_par02","","","","","","","","","","","","","","","","",{"Numero da Nota Final"},;
	             {"Numero da Nota Final"},{"Numero da Nota Final"})
	Do While .T.
		If !Pergunte(cPerg, .T.)
			RestArea(aArea)
			Return(.T.)
		EndIf
		If MV_PAR01 <= MV_PAR02 // N�o tem erro nos par�metros
			Exit
		EndIf
	EndDo
	// Salva dados do browse anterior
	_NwcCadas := cCadastro
	_NwaCores := aCores
	_NwaRotin := aRotina
	
//	CloseBrowse() // Fecha o Browse anterior que deve ser reaberto na fun��o que chamou

	// Filtra os registros ainda n�o impressos
	DbSelectArea("ZZ4")
	DbSetOrder(2) // ZZ4_FILIAL+ZZ4_DOC+ZZ4_SERIE
	Set Filter to ZZ4_DOC >= MV_PAR01 .And. ZZ4_DOC <= MV_PAR02 .And. Empty(ZZ4_NROTER)
	
	DbSeek(xFilial("ZZ4"),.T.)
	
	cCadastro:="Impress�o de Termos de Responsabilidade"
	aRotina := {{ "Pesquisar" ,"AxPesqui"   ,0,1},;
				{ "Visualizar","U_CDTMSR1c('V')" ,0,2},;
				{ "Imprimir"  ,"U_CDTMSR1a(.F.)" ,0,3},;
				{ "Alterar"   ,"U_CDTMSR1c('A')" ,0,4}}
	lInverte:=.F.
	cMarca := GetMark(,"ZZ4","ZZ4_OK")
	MarkBrow("ZZ4","ZZ4_OK",,,@lInverte,@cMarca,,,,,)

	cCadastro := _NwcCadas
	aCores    := _NwaCores
	aRotina   := _NwaRotin
EndIf        
DbSelectArea("ZZ4")                     
Set Filter to
RestArea(aArea)
Return(.T.)
*
*******************************
User Function CDTMSR1a(lReimpr)
*******************************
*
RptStatus({|| CDTMSR1b(lReimpr,MV_PAR01,MV_PAR02) },Titulo)
Return(.T.)
*
***************************************************
Static Function CDTMSR1b(lReimpr,MV_PAR01,MV_PAR02)
***************************************************
*
Local oFont1 := TFont():New( "Courier New"    ,,18,,.T.,,,,   ,.F. )
Local oFont2 := TFont():New( "Courier New"    ,,16,,.F.,,,,   ,.F. )
Local oFont3 := TFont():New( "Times New Roman",,16,,.T.,,,,.T.,.F. )
Local oFont4 := TFont():New( "Courier New"    ,,20,,.T.,,,,   ,.F. )
Local oFont5 := TFont():New( "Courier New"    ,,12,,.T.,,,,   ,.F. )
Local oFont6 := TFont():New( "Courier New"	  ,,08,,.T.,,,,   ,.F. )
Local oFont7 := TFont():New( "Arial"      	  ,,10,,.T.,,,,   ,.F. )
Local oFont8 := TFont():New( "Courier New"    ,,10,,.T.,,,,   ,.F. )
Local oFont9 := TFont():New( "Courier New" 	  ,,08,,.F.,,,,   ,.F. )
Local oFontA := TFont():New( "Arial"      	  ,,09,,.F.,,,,   ,.F. )
Private oPrn := TMSPrinter():New()
//Private oPen		:= TPen():New(,CLR_BLACK,12,oPrn)
cBmp := GetSrvProfString("Startpath","") + "LOGO_TRP.BMP"
oPrn:SetPortrait() // Formato pagina Retrato
 
DbSelectArea("SF2")
DbSetOrder(1) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

DbSelectArea("ZZ4")
//DbSetOrder(1) //ZZ4_FILIAL+ZZ4_TPMOV+ZZ4_TPDOC+ZZ4_SERIE+ZZ4_DOC+ZZ4_CLIFOR+ZZ4_LOJA
DbSetOrder(2) //ZZ4_FILIAL+ZZ4_DOC+ZZ4_SERIE
//DbSetOrder(3) //ZZ4_FILIAL+ZZ4_NROTER   
DbSeek(xFilial("ZZ4")+MV_PAR01,.T.)
_nPixel := 0
Do While ZZ4->ZZ4_FILIAL == xFilial("ZZ4") .And. ZZ4->ZZ4_DOC <= MV_PAR02 .And. ZZ4->(!Eof())

	If !lReimpr // Escolheu imprimir
		If !Empty(ZZ4->ZZ4_NROTER) .Or. !Marked("ZZ4_OK") //  O termo j� foi impresso ou n�o foi selecionado
			ZZ4->(DbSkip())
			Loop
		EndIf
	EndIf

	If Empty(ZZ4->ZZ4_ESPECI) .And. Empty(ZZ4->ZZ4_VOLUME)
		SF2->(DbSeek(xFilial("SF2")+ZZ4->ZZ4_DOC+ZZ4->ZZ4_SERIE,.F.))
		If !Empty(SF2->F2_ESPECI1) .Or. !Empty(SF2->F2_VOLUME1)
			RecLock("ZZ4",.F.)
			ZZ4->ZZ4_ESPECI := SF2->F2_ESPECI1
			ZZ4->ZZ4_VOLUME := SF2->F2_VOLUME1
			MsUnLock()
		EndIf
	EndIf

	If Empty(ZZ4->ZZ4_NROTER)
		DbSelectArea("ZZ4")
		aAreaTMP := GetArea()
		DbSetOrder(3) //ZZ4_FILIAL+ZZ4_NROTER
		
		Do While .T.
			_cNumTrm := Soma1(GETMV("MV_CDTERMO"))
			DbSelectArea("SX6")
			If !Dbseek(FWCodFil()+"MV_CDTERMO",.F.)
				Dbseek("  MV_CDTERMO",.F.)
			EndIf
			If !SX6->(Eof())
				Reclock("SX6",.F.)
				SX6->X6_CONTEUD := _cNumTrm
				SX6->(MsUnlock())
			Endif
			// Se j� existir esse nro. procurar outro
			If !DbSeek(xFilial("ZZ4")+_cNumTrm,.F.)
				// N�o Tem -> usar ele
				Exit
			EndIf
		EndDo
		RestArea(aAreaTMP)
		RecLock("ZZ4",.F.)   
		ZZ4->ZZ4_NROTER := _cNumTrm
		ZZ4->ZZ4_DTATER := dDataBase
		MsUnLock()
	EndIf

	If _nPixel == 0 // Abri nova p�gina
		oPrn:StartPage() //inicializa pagina por problemas duplica��o registro - Renato/Michel
	EndIf
	
	// Montagem do Formul�rio
	oPrn:SayBitmap(_nPixel+015,0115,cBmp,505,095) //095,096)
	oPrn:Box(_nPixel+0000,0100,_nPixel+1048,2320) // Box maior
	oPrn:Box(_nPixel+0000,0100,_nPixel+0120,2320) // Box cabe�alho
	oPrn:Box(_nPixel+0000,0640,_nPixel+0120,1816) // Box Termo de Responsabilidade
	oPrn:Box(_nPixel+0000,1816,_nPixel+0120,2068) // Box Data
	oPrn:Say(_nPixel+0010,1826,"Data:"  ,oFont7)
	oPrn:Say(_nPixel+0010,2078,"N�mero:",oFont7)
	oPrn:Say(_nPixel+0040,0784,"Termo de Responsabilidade",oFont3)
	oPrn:Say(_nPixel+0160,0110,"Transportadora:",oFont5)
	oPrn:Box(_nPixel+0216,0100,_nPixel+0300,2320) // Box Titulos
	oPrn:Box(_nPixel+0216,0774,_nPixel+0300,1244) // Box destino
	oPrn:Box(_nPixel+0216,1446,_nPixel+0300,1916) // Box volume
	oPrn:Box(_nPixel+0216,2118,_nPixel+0300,2320) // Box Peso
	oPrn:Say(_nPixel+0244,0110,"Cliente",oFont5)
	oPrn:Say(_nPixel+0244,0784,"Destino",oFont5)
	oPrn:Say(_nPixel+0244,1254,"Nr. NF.",oFont5)
	oPrn:Say(_nPixel+0244,1456,"Volume(s)",oFont5)
	oPrn:Say(_nPixel+0244,1926,"Quant.",oFont5)
	oPrn:Say(_nPixel+0244,2128,"Peso",oFont5)
	
	// Montagem das linhas na grid de dados
	oPrn:Box(_nPixel+0360,0100,_nPixel+0420,2320)
	oPrn:Box(_nPixel+0480,0100,_nPixel+0540,2320)
	//oPrn:Box(_nPixel+0600,0100,0660,2320)
	                                       
	// Montagem das colunas na grid de dados
	oPrn:Box(_nPixel+0300,0774,_nPixel+0540,1244) // Box destino
	oPrn:Box(_nPixel+0300,1446,_nPixel+0540,1916) // Box volume
	oPrn:Box(_nPixel+0300,2118,_nPixel+0540,2320) // Box Peso
	
	oPrn:Say(_nPixel+0540,0110,"Observa��o:",oFont5)
	
	If ZZ4->ZZ4_TPFRET=="F" // Tipo do frete � FOB
		dd := 0
	 	oPrn:Say(_nPixel+0570,0420,"Frete Tipo:",oFont5)
	 	oPrn:Say(_nPixel+0550,0740,"FOB",oFont3)
	EndIf                               

	oPrn:Box(_nPixel+0660,0100,_nPixel+1048,1446) // Box da declara��o do motorista
	
	oPrn:Say(_nPixel+0720,0110,"Declaro estar de acordo com o(s) documento(s) e as quantidades de",oFont6)
	oPrn:Say(_nPixel+0750,0110,"volumes acima descritos, conferidos por mim no momento do carregamento.",oFont6)
	
	oPrn:Say(_nPixel+0850,0110,"Motorista:",oFont7)
	oPrn:Say(_nPixel+0922,0110,"______________________________",oFont7)
	oPrn:Say(_nPixel+0922,0826,"______________________________",oFont7)
	oPrn:Say(_nPixel+0958,0110,"Nome",oFont7)
	oPrn:Say(_nPixel+0958,0826,"Assinatura",oFont7)
	
	oPrn:Box(_nPixel+0660,1446,_nPixel+1048,1883) // Box Solicita��o de Coleta
	oPrn:Box(_nPixel+0660,1883,_nPixel+1048,2320) // Box Visto Expedi��o
	oPrn:Box(_nPixel+0660,1446,_nPixel+0720,2320) // Box dos titulos  da Solicita��o de Coleta e Visto Expedi��o
	
	oPrn:Say(_nPixel+0680,1456,"SOLICITA��O COLETA",oFont8)
	oPrn:Say(_nPixel+0680,1893,"VISTO EXPEDI��O",oFont8)
	
	//Preenchimento dos dados
	oPrn:Say(_nPixel+0058,1890,Dtoc(ZZ4->ZZ4_DTATER),oFontA) // Data
	oPrn:Say(_nPixel+0058,2170,ZZ4->ZZ4_NROTER,oFontA) // Nro. do Termo
	oPrn:Say(_nPixel+0160,0520,ZZ4->ZZ4_TRANSP + " - " + ZZ4->ZZ4_NOMTR,oFontA) // C�digo e nome da transportadora
	                
	//Preenchimento da linha 1 da grid de dados
	oPrn:Say(_nPixel+0310,0110,Left(ZZ4->ZZ4_NOME,39),oFont9)  // Nome do Cliente -> M�ximo de 39 caracteres
	oPrn:Say(_nPixel+0310,0784,AllTrim(ZZ4->ZZ4_MUNIC)+"-"+ZZ4->ZZ4_EST,oFont9) // Destino da Mercadoria -> M�ximo de 27 caracteres
	oPrn:Say(_nPixel+0310,1254,ZZ4->ZZ4_DOC,oFont9)   // Nro. da Nota Fiscal
	oPrn:Say(_nPixel+0310,1456,ZZ4->ZZ4_ESPECI,oFont9)// "volumes apresentados na nota -> M�ximo de 27 caracteres
	If ZZ4->ZZ4_VOLUME > 0
		_nVol1 := Transform(ZZ4->ZZ4_VOLUME,"@E 999,999")
		oPrn:Say(_nPixel+0310,1976,_nVol1,oFont9) // Quantidade de Volumes
	EndIf
	_nPes1 := Transform(ZZ4->ZZ4_PESOBS,"@E 999,999.99")
	oPrn:Say(_nPixel+0310,2125,_nPes1,oFont9)
			
	//Preenchimento da linha 2 da grid de dados
//	oPrn:Say(_nPixel+0370,0110,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",oFont9) // M�ximo de 39 caracteres
//	oPrn:Say(_nPixel+0370,0784,"XXXXXXXXXXXXXXXXXXXXXXXXXXX",oFont9)             // M�ximo de 27 caracteres
//	oPrn:Say(_nPixel+0370,1254,"999999999",oFont9)                               // Nro. da Nota Fiscal
//	oPrn:Say(_nPixel+0370,1456,"XXXXXXXXXXXXXXXXXXXXXXXXXXX",oFont9)             // M�ximo de 27 caracteres
//	oPrn:Say(_nPixel+0370,2000,"99.999",oFont9)
//	oPrn:Say(_nPixel+0370,2200,"99.999",oFont9)
		
	//Preenchimento da linha 3 da grid de dados
//	oPrn:Say(_nPixel+0430,0110,"Nome do Cliente 1234567890 1234567890xx",oFont9) // M�ximo de 39 caracteres
//	oPrn:Say(_nPixel+0430,0784,"Destino da Mercadoria 12345",oFont9)             // M�ximo de 27 caracteres
//	oPrn:Say(_nPixel+0430,1254,"999999999",oFont9)                               // Nro. da Nota Fiscal
//	oPrn:Say(_nPixel+0430,1456,"volumes apresentados na not",oFont9)             // M�ximo de 27 caracteres
//	oPrn:Say(_nPixel+0430,2000,"99.999",oFont9)
//	oPrn:Say(_nPixel+0430,2200,"99.999",oFont9)
			
	//Preenchimento da linha 4 da grid de dados
//	oPrn:Say(_nPixel+0490,0110,"XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",oFont9) // M�ximo de 39 caracteres
//	oPrn:Say(_nPixel+0490,0784,"XXXXXXXXXXXXXXXXXXXXXXXXXXX",oFont9)             // M�ximo de 27 caracteres
//	oPrn:Say(_nPixel+0490,1254,"999999999",oFont9)
//	oPrn:Say(_nPixel+0490,1456,"XXXXXXXXXXXXXXXXXXXXXXXXXXX",oFont9)             // M�ximo de 27 caracteres
//	oPrn:Say(_nPixel+0490,2000,"99.999",oFont9)
//	oPrn:Say(_nPixel+0490,2200,"99.999",oFont9)
	
		
	// Campo observa��es
//	oPrn:Say(_nPixel+0546,0402,"01234567890 ABCDEFGHIJKLMNOPQRSTUVXYWZ 01234567890 ABCDEFGHIJKLMNOPQRSTUVXYWZ 01234567890 ABCDEFGHIJKLMNOPQRSTUV",oFont9)
//	oPrn:Say(_nPixel+0574,0402,"XXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXX",oFont9)
//	oPrn:Say(_nPixel+0602,0402,"01234567890 ABCDEFGHIJKLMNOPQRSTUVXYWZ 01234567890 ABCDEFGHIJKLMNOPQRSTUVXYWZ 01234567890 ABCDEFGHIJKLMNOPQRSTUV",oFont9)
//	oPrn:Say(_nPixel+0630,0402,"01234567890 ABCDEFGHIJKLMNOPQRSTUVXYWZ 01234567890 ABCDEFGHIJKLMNOPQRSTUVXYWZ 01234567890 ABCDEFGHIJKLMNOPQRSTUV",oFont9)

	If _nPixel == 2336 // J� imprimi o 3ro quadro
		_nPixel := 0
		oPrn:EndPage() // Encerra a p�gina atual
	Else
		_nPixel += 1168
	EndIf
	ZZ4->(DbSkip())
EndDo   

If _nPixel > 0
	oPrn:EndPage() // Encerra a p�gina atual
EndIf
oPrn:Preview()
MS_FLUSH()
Return(.T.)
*
*****************************
User Function CDTMSR1c(_ToDo)
*****************************
*
DbSelectArea("ZZ4")
If _ToDo == "A" // Alterar             
	nOpca := AxAltera("ZZ4",Recno(),4,,,,)
ElseIf _ToDo == "V" // Visualizar
	nOpca := AxVisual("ZZ4",Recno(),2) 
EndIf
Return(.T.)