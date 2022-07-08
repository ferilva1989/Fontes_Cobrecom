#include 'protheus.ch'
#include 'parmtype.ch'
user function gravarPes(aContent)
	Local nHandle
	Local cNomeArq := "\ACD_COBRECOM\" +  DtoS(Date()) + StrTran(Time(),':','')  + "_pesagem.txt"
	Local lOk	:= .T.
	Local cMsg	:= ""
	Default aContent  := {}
	If Empty(aContent)
		lOk := .F.
		cMsg := "[ERRO] - Nenhum conteudo para ser exibido"
	Else
		nHandle := FCREATE(cNomeArq)
		If nHandle = -1
			conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
			lOk := .F.
			cMsg := "[ERRO] - Criação de arquivo consulta (PESAGEM) " + Str(Ferror())
		Else
			For nX := 1 To Len(aContent)
				FWrite(nHandle, aContent[nX]:USR + ' - ' + aContent[nX]:COD + chr(13))
			Next nX
			FClose(nHandle)
			
			//Enviar arquivo para maquina SmartClient
			//CpyS2T("\consulta.html","c:\temp\",.T.)
			//SHELLEXECUTE("Open","C:\temp\consulta.html","","",3)
		EndIf
	EndIf	
return lOk