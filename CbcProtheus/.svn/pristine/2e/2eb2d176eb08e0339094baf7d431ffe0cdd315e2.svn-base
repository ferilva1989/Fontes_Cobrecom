#INCLUDE "RWMAKE.CH"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CDFINA13  º Autor ³ Roberto Oliveira    º Data ³  30/08/11 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±ºMotivo    ³ Ajustes no Layout do arquivo de exportação                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
************************
User Function CDFCITxt()
************************
*
@ 200,1 TO 380,380 DIALOG oGeraTxt TITLE OemToAnsi("Geração de Arquivo FCI")
@ 002,2 TO 090,190
@ 10,018 Say " Este programa ira gerar um arquivo texto, conforme as definições "
@ 18,018 Say " dos parâmetros pelo usuário e a seleção de registros do Cadastro "
@ 38,018 Say " ATENÇÃO: Arquivo será criado na pasta \FCI\ENVIADOS na rede      "
@ 70,098 BMPBUTTON TYPE 01 ACTION GereFCI()
@ 70,128 BMPBUTTON TYPE 02 ACTION Close(oGeratxt)
Activate Dialog oGeraTxt Centered

Return(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros		        ³
//³ mv_par01				// Data Inicio               ³
//³ mv_par02				// Data Fim                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*
*************************
Static Function GereFCI()
*************************
*                                             
Private nHdl
Private cEOL
            
DbSelectArea("SB1")
DbSetOrder(1)

DbSelectArea("SD2")
DbSetOrder(1)

DbSelectArea("ZZH")
DbSetOrder(4) // ZZH_FILIAL+ZZH_STATUS+ZZH_COD
If !DbSeek(xFilial("ZZH")+"S",.F.)
	Alert("Não há Dados a Serem Transmitidos")
Else
	Processa({|| RunCont() },"Processando...","Selecionando Registros... ")
EndIf
If Select("TRB")>0
	DbSelectArea("TRB")
	DbCloseArea()
EndIf
Return(.T.)
*
*************************
Static Function RunCont()
*************************
*
Local nQtdLin, cLin

DbSelectArea("ZZH")
DbSetOrder(4) // ZZH_FILIAL+ZZH_STATUS+ZZH_COD

// Verifico os dados a serem enfiados
DbSeek(xFilial("ZZH")+"S",.F.)
_nQtdZZH := 0
_aPrds := {}
_lTudoOK := .T.
Do While ZZH->ZZH_FILIAL == xFilial("ZZH") .And. ZZH->ZZH_STATUS == "S" .And.ZZH->(!Eof()) .And. _lTudoOK
	For _nPr := 1 to Len(_aPrds)
		If _aPrds[_nPr] == ZZH->ZZH_COD
			// FCI em duplicidade
			_lTudoOK := .F.
			Exit
		EndIf
	Next
	Aadd(_aPrds,ZZH->ZZH_COD)
	_nQtdZZH++
	DbSkip()
EndDo
                                     
If _lTudoOK
	// Verifico os dados já enviados e aguardando retorno
	DbSeek(xFilial("ZZH")+"E",.F.)
	Do While ZZH->ZZH_FILIAL == xFilial("ZZH") .And. ZZH->ZZH_STATUS == "E" .And.ZZH->(!Eof()) .And. _lTudoOK
		For _nPr := 1 to Len(_aPrds)
			If _aPrds[_nPr] == ZZH->ZZH_COD
				// FCI em duplicidade
				_lTudoOK := .F.
				Exit
			EndIf
		Next
		Aadd(_aPrds,ZZH->ZZH_COD)
		DbSkip()
	EndDo
EndIf

If !_lTudoOK
	Alert("Produto " + AllTrim(ZZH->ZZH_COD) + " com FCI em Duplicidade")
	Return(.T.)
EndIf
                                                     
_cHora := Time()
_cHora := StrTran(_cHora,":","")
cArqTxt := "\FCI\ENVIADOS\FCI"+xFilial("ZZH")+Dtos(dDataBase)+_cHora+".TXT"
nHdl    := fCreate(cArqTxt)
cEOL    := CHR(13)+CHR(10)
Do While nHdl <= 0
	Alert("Criar a Pasta \FCI\ENVIADOS")
	nHdl    := fCreate(cArqTxt)
EndDo

// Cria o Header                  

cLin := "0000|"+SM0->M0_CGC +"|"+Left(SM0->M0_NOMECOM+Space(60),60)+"|1.0" + cEOL
fWrite(nHdl,cLin,Len(cLin))

cLin := "0001|Texto em caracteres UTF-8: (dígrafo BR)'ção',(dígrafo espanhol-enhe)'ñ',(trema)'Ü',(ordinais)'ªº',(ligamento s+z alemão)'ß'."
cLin := EnCodeUtf8(cLin) + cEOL

fWrite(nHdl,cLin,Len(cLin))

cLin := "0010|"+SM0->M0_CGC+"|"+Left(SM0->M0_NOMECOM+Space(60),60)+"|"+SM0->M0_INSC+"|"+Left(SM0->M0_ENDENT+Space(60),60)+"|"+;
        SM0->M0_CEPENT+"|"+AllTrim(SM0->M0_CIDENT)+"|"+SM0->M0_ESTENT
        
cLin := NoAcento(cLin)
cLin := EnCodeUtf8(cLin)
cLin := cLin + cEOL
fWrite(nHdl,cLin,Len(cLin))

cLin := "0990|4" + cEOL
fWrite(nHdl,cLin,Len(cLin))

cLin := "5001" + cEOL
fWrite(nHdl,cLin,Len(cLin))

nQtdLin := 0

ProcRegua(_nQtdZZH)
Do While ZZH->(DbSeek(xFilial("ZZH")+"S",.F.))
	IncProc()

	SB1->(DbSeek(xFilial("SB1")+ZZH->ZZH_COD,.F.))
	If ZZH->ZZH_FCIX <= 0 .Or. !Empty(ZZH->ZZH_NFCI) .Or. SB1->(Eof())
		RecLock("ZZH",.F.)
		ZZH->ZZH_STATUS := "X"
		If SB1->(Eof())
			ZZH->ZZH_DESC := "PRODUTO NAO CADASTRADO"
		EndIf

		MsUnLock()           
		Loop
	EndIf
	
	nQtdLin++
	_cBar := AllTrim(If(Left(SB1->B1_CODBAR,3) == "789",SB1->B1_CODBAR,""))
	_PerFCI := Round((NoRound(ZZH->ZZH_VCUS,2) / NoRound(ZZH->ZZH_CUSTO,2)) * 100,2)
		
	RecLock("ZZH",.F.)
	ZZH->ZZH_FCIX   := _PerFCI
	ZZH->ZZH_DESC   := SB1->B1_DESC
	ZZH->ZZH_STATUS := "E"
	MsUnLock()

	_cUM := SB1->B1_UM
	If Upper(SB1->B1_UM) == "MT"
		_cUM := "m"
	ElseIf Upper(SB1->B1_UM) == "KG"
		_cUM := "kg"                
	EndIf
		     
	cLin := "5020|"+AllTrim(ZZH->ZZH_DESC)+"|"+AllTrim(SB1->B1_POSIPI)+"|"+AllTrim(ZZH->ZZH_COD)+"|"+_cBar+;
	        "|"+AllTrim(_cUM)+"|"+AllTrim(Transform(NoRound(ZZH->ZZH_CUSTO,2),"@E 999999999999999.99"))+;
	        "|"+AllTrim(Transform(NoRound(ZZH->ZZH_VCUS,2),"@E 999999999999999.99"))+;
	        "|"+AllTrim(Transform(_PerFCI,"@E 999.99"))
		        
	        // "|"+AllTrim(Transform(ZZH->ZZH_FCI,"@E 999.99"))
	cLin := NoAcento(cLin)
	cLin := EnCodeUtf8(cLin)
	cLin := AllTrim(cLin) + cEOL
	        
	fWrite(nHdl,cLin,Len(cLin))
EndDo
cLin := "5990|"+AllTrim(Str(nQtdLin+2)) + cEOL
cLin := EnCodeUtf8(cLin)
fWrite(nHdl,cLin,Len(cLin))

cLin := "9001" + cEOL
fWrite(nHdl,cLin,Len(cLin))

cLin := "9900|0000|1" + cEOL
fWrite(nHdl,cLin,Len(cLin))

cLin := "9900|0010|1" + cEOL
fWrite(nHdl,cLin,Len(cLin))

cLin := "9900|5020|"+AllTrim(Str(nQtdLin)) + cEOL
fWrite(nHdl,cLin,Len(cLin))

cLin := "9990|5" + cEOL
fWrite(nHdl,cLin,Len(cLin))

cLin := "9999|"+AllTrim(Str(nQtdLin+12)) + cEOL
fWrite(nHdl,cLin,Len(cLin))

fClose(nHdl)

MsgAlert("Arquivo  '" + cArqTxt + "'  Gerado com Sucesso! ","Atenção")
Close(oGeraTxt)
Return(.T.)
*
*********************************
Static FUNCTION NoAcento(cString)
*********************************
*
Local cChar  := ""
Local nX     := 0
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
Local cTrema := "äëïöü"+"ÄËÏÖÜ"
Local cCrase := "àèìòù"+"ÀÈÌÒÙ"
Local cTio   := "ãõ"+"ÃÕ"
Local cCecid := "çÇ"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("ao",nY,1))
		EndIf
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next
Return cString
*
************************
User Function CDFCIRET()
************************
*
cPerg := "CDFI13A" // Uso a mesma pergunta do CDFINA013 200623.txt

Do While .T.
	If !Pergunte(cPerg,.T.)
		Exit
	EndIf
	If Empty(MV_PAR01)
		Alert("Informar o Nome do Arquivo")   
		Loop
	EndIf
	MV_PAR01 := Upper(AllTrim(MV_PAR01))
	_cArq := "\FCI\RECEBIDOS\"+MV_PAR01       
	If !File(_cArq)
		Alert("O Arquivo " + MV_PAR01 + " tem que estar na Pasta \FCI\RECEBIDOS\ no servidor")
		Loop
	EndIf
	If MsgBox("Arquivo " + _cArq + " Localizado!" + Chr(13) + "Confirma o Processamento?","Confirma?","YesNo")
		Processa({|| RetFCI()})
		Exit
	EndIf
	Exit
EndDo
Return(.T.)
*
************************
Static Function RetFCI()
************************
*
Private _aCampos := {}

DbSelectArea("ZZH")
DbSetOrder(1)

_cCGC := ""

_cArqT   := _cArq
_cArqNew := Left(_cArqT,Len(_cArqT)-3) + "PRC"
nHdl := FT_FUSE(_cArqT)
If nHdl <= 0 // Deu erro na abertura do arquivo
	Alert("Erro ao abrir o arquivo " + _cArqT)
	Return(.T.)
Endif

_nQtLin := FT_FLASTREC()

If _nQtLin <= 0 // Não tem dados neste arquivo
	FT_FUSE() //Fecha arquivo
	fRename(_cArqT,_cArqNew)
	Alert("Não há dados no arquivo " + _cArqT)
	Return(.T.)
EndIf

ProcRegua(_nQtLin)
For _nVistas := 1 to _nQtLin
	IncProc()
	_cLinha := FT_FREADLN()
	FT_FSKIP()       
	// Só analiso os registros tipo "5020"
	If Left(_cLinha,4) == "0000" // Pego o CNPJ para saber se é matriz ou filial
		_cCGC := Substr(_cLinha,6,14)
		_nOcc := 0             
		_cProt := ""
		For _nPosi := 1 to Len(_cLinha)
			If Substr(_cLinha,_nPosi,1) == "|"
				_nOcc++
				If _nOcc == 5 
					_dDtTxt := Ctod(Substr(_cLinha,_nPosi+1,10))
				ElseIf _nOcc == 6
					_cProt := Substr(_cLinha,_nPosi+1,7)
					Exit
				EndIf
			EndIf
		Next
		Loop
	ElseIf Left(_cLinha,4) # "5020"
		Loop
	EndIf

	// Vejo as Posições dos Pipes
	_aPipes := {}
	For _nPosi := 1 to Len(_cLinha)
		If Substr(_cLinha,_nPosi,1) == "|"
			AAdd(_aPipes,_nPosi)
		EndIf
	Next
	If Len(_aPipes) < 9 // Não tem nro da FCI
		Loop
	EndIf

	// O código está apos o 3ro pipe
	_cProd := Left(AllTrim(Substr(_cLinha,_aPipes[03]+1,(_aPipes[04]-_aPipes[03]-1))) + Space(Len(SB1->B1_COD)),Len(SB1->B1_COD))
	//                                                                                   
	_cCodFil := If(_cCGC=="02544042000119","01","02")
	// O nro. FCI está apos o 9o pipe
	_cNFci :=     AllTrim(Substr(_cLinha,_aPipes[09]+1,(_aPipes[10]-_aPipes[09]-1)))

	//       
	_cDesc :=     AllTrim(Substr(_cLinha,_aPipes[01]+1,(_aPipes[02]-_aPipes[01]-1)))
	//
	_nCusto:=     Val(StrTran((AllTrim(Substr(_cLinha,_aPipes[06]+1,(_aPipes[07]-_aPipes[06]-1)))),",","."))
	//
	_nVcus :=     Val(StrTran(AllTrim(Substr(_cLinha,_aPipes[07]+1,(_aPipes[08]-_aPipes[07]-1))),",","."))
	//                                                                                   
	_PerFCI:=     Val(StrTran(AllTrim(Substr(_cLinha,_aPipes[08]+1,(_aPipes[09]-_aPipes[08]-1))),",","."))

/*/
	DbSelectArea("ZZH")
	DbSetOrder(2) // ZZH_FILIAL+ZZH_NFCI
	If !DbSeek(_cCodFil+_cNFci,.F.)
		RecLock("ZZH",.T.)
		ZZH->ZZH_DTCAL := _dDtTxt
		ZZH->ZZH_FILIAL := _cCodFil
		ZZH->ZZH_NFCI   := _cNFci
		ZZH->ZZH_DESC   := _cDesc
		ZZH->ZZH_COD    := _cProd
		ZZH->ZZH_CUSTO  := _nCusto
		ZZH->ZZH_VCUS   := _nVcus
		ZZH->ZZH_FCIX   := _PerFCI
	Else
		RecLock("ZZH",.F.)
	EndIf
	ZZH->ZZH_NPRO   := _cProt
	ZZH->ZZH_STATUS := "R"
	MsUnLock()

/*/
	DbSetOrder(4) // ZZH_FILIAL+ZZH_STATUS+ZZH_COD 
	DbSeek(_cCodFil+"E"+_cProd,.F.)
	Do While ZZH->ZZH_FILIAL == _cCodFil .And. ZZH->ZZH_STATUS == "E" .And. ;
	         ZZH->ZZH_COD == _cProd .And. ZZH->(!Eof())
		If Empty(ZZH->ZZH_NFCI)
			RecLock("ZZH",.F.)
			ZZH->ZZH_NFCI   := _cNFci
			ZZH->ZZH_NPRO   := _cProt
			ZZH->ZZH_STATUS := "R"
			MsUnLock()
			Exit
		EndIf
		DbSkip()
	EndDo
Next

FT_FUSE() //Fecha arquivo
fRename(_cArqT,_cArqNew)

MsgAlert("Arquivo  '" + _cArqT + "'  Processado! ","Atenção")
Return(.T.)