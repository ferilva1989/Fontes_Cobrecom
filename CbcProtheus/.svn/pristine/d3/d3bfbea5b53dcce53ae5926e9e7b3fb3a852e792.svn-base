#include 'protheus.ch'
#include 'parmtype.ch'

user function gravarDisco(cOperador, cOs, cSeq, oHeader, oItens)

	Local nHandle
	Local cNomeArq := "\ACD_COBRECOM\" +  DtoS(Date()) + StrTran(Time(),':','')  + "_OS_" + cOs + "_SEQ_" + cSeq + ".txt"
	Local lOk	:= .T.
	Local cMsg	:= ""
	Default oHeader  := {}

	If Empty(oHeader)
		lOk := .F.
		cMsg := "[ERRO] - Nenhum conteudo para ser exibido"
	Else
		nHandle := FCREATE(cNomeArq)
		If nHandle = -1
			conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
			lOk := .F.
			cMsg := "[ERRO] - Criação de arquivo consulta  " + Str(Ferror())
		Else
		
			FWrite(nHandle, "OPERADOR LOGADO: " + cOperador + chr(13))
			FWrite(nHandle, "OS NUMERO: " 		+ cOs + chr(13))	
			FWrite(nHandle, "OS SEQ: " 			+ cSeq + chr(13))
			FWrite(nHandle, chr(13))
			
			FWrite(nHandle, "HEADER" + chr(13))	
			FWrite(nHandle, "TIPO_VOLUME:" 	+ oHeader:TPVOL + chr(13))
			FWrite(nHandle, "TARA:" 		+ cValToChar(oHeader:TARA) + chr(13))
			FWrite(nHandle, "PESO_BRUTO:" 	+ cValToChar(oHeader:PESOBRUTO) + chr(13))
			FWrite(nHandle, chr(13))
			FWrite(nHandle, chr(13))
			
			FWrite(nHandle, "ITENS" + chr(13))
			For nX := 1 To Len(oItens)
				FWrite(nHandle, "TIPO:" 	+  oItens[nX]:TP + chr(13))
				FWrite(nHandle, "COD_USR:" 	+  oItens[nX]:USR + chr(13))
				FWrite(nHandle, "COD_ID:" 	+  oItens[nX]:ID + chr(13))
				FWrite(nHandle, "QTD_PROD:"	+  cValToChar(oItens[nX]:QTD) + chr(13))
				FWrite(nHandle, "......................." + chr(13))
			Next nX
		
			FClose(nHandle)
			
			//Enviar arquivo para maquina SmartClient
			//CpyS2T("\consulta.html","c:\temp\",.T.)
			//SHELLEXECUTE("Open","C:\temp\consulta.html","","",3)
		EndIf

	EndIf	
return lOk