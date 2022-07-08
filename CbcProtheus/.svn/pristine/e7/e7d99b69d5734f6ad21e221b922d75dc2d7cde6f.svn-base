#include "rwmake.ch"
//
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDRETPAG                             Modulo : SIGAFIN    //
//                                                                          //
//   Autor ......: ROBERTO OLIVEIRA                     Data ..: 23/12/09   //
//                                                                          //
//   Objetivo ...: Ler os arquivos de retorno do PAGFOR Bradesco e excluir  //
//                 os registros que não foram enviados pelo Microsiga       //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
//   Observacoes :                                                          //
//                                                                          //
//                                                                          //
//   Atualizacao :                                                          //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
//

////////////////////////
User Function CdRetPag()
	////////////////////////
	*
	*
	aFiles := ARRAY(ADIR("\BAIXASPG\PG*.RET"))
	ADIR("\BAIXASPG\PG*.RET",aFiles)
	If Len(aFiles) == 0
		Alert("Não encontrado arquivos de Retornos na Pasta \BAIXASPG\")
		Return(.T.)
	EndIf

	Processa( {|| LeConfig() },"Preparando Configurações...")
	Alert("Processamento Cocluído !!!")
	Return(.T.)
	*
	**************************
Static Function LeConfig()
	**************************
	*                                                 
	*                                                 
	DbSelectArea("SE2")
	DbSetOrder(13) // E2_IDCNAB

	aStruTrb := {}
	AADD(aStruTrb,{"CAMPO1","C",001,0} ) // Tipo do registro
	AADD(aStruTrb,{"CAMPO2","C",414,0} ) // Dados
	AADD(aStruTrb,{"CAMPO3","C",010,0} ) // IDCNAB
	AADD(aStruTrb,{"CAMPO4","C",003,0} ) // TIPO
	AADD(aStruTrb,{"CAMPO5","C",002,0} ) // FILIAL
	AADD(aStruTrb,{"CAMPO6","C",064,0} ) // Dados
	AADD(aStruTrb,{"CAMPO7","C",006,0} ) // Nro Registro

	cNomTrb0 := CriaTrab(aStruTrb)
	dbUseArea(.T.,,cNomTrb0,"TRB0",.F.,.F.) // Abre o arquivo de forma exclusiva

	cIndTRB0 := CriaTrab(NIL,.F.)
	IndRegua("TRB0",cIndTRB0,"CAMPO1+CAMPO7")
	ProcRegua(Len(aFiles))    
	For _nArqs := 1 to Len(aFiles)
		IncProc()
		_cArqT := "\BAIXASPG\"+aFiles[_nArqs]

		DbSelectArea("TRB0")  
		Set Filter to
		Zap
		Append from &_cArqT. SDF             
		_cFilTem := ""
		_lTemReg := .F.

		DbGoTop()
		Do While TRB0->(!Eof())
			If TRB0->CAMPO1 $ "09" .Or. !(" " $ TRB0->CAMPO3)
				_cFilial := "  "
				_cTpo    := "   "
				If !(" " $ TRB0->CAMPO3)
					If SE2->(DbSeek(TRB0->CAMPO3,.F.))
						_cFilial := SE2->E2_FILIAL
						_cTpo := SE2->E2_TIPO
					EndIf
					If !_cFilial $ _cFilTem
						_lTemReg := .T.
						_cFilTem := _cFilTem+_cFilial+"/"
					EndIf
				EndIf
				RecLock("TRB0",.F.)
				//			TRB0->CAMPO7 := "999999"
				If TRB0->CAMPO4 # _cTpo .And. Empty(TRB0->CAMPO4)
					TRB0->CAMPO4 := _cTpo
				EndIf
				TRB0->CAMPO5 := _cFilial
			Else
				RecLock("TRB0",.F.)
				DbDelete()
			EndIf
			MsUnLock()
			TRB0->(DbSkip())
		EndDo

		If _lTemReg // Tem Algum registro que é do Microsiga
			Pack      
			Do While Len(_cFilTem) > 0
				_FilAtu := Left(_cFilTem,2)
				_cFilTem := Substr(_cFilTem,4,Len(_cFilTem)-3)

				Set Filter to (CAMPO5 == _FilAtu .Or. CAMPO1 $ "09")
				_nPrxReg := 1
				DbGoTop()
				Do While TRB0->(!Eof())
					RecLock("TRB0",.F.)
					TRB0->CAMPO7 := StrZero(_nPrxReg++,6)
					MsUnLock()
					DbSkip()
				EndDo
				_cFile := AllTrim(Substr(aFiles[_nArqs],3))
				_cFile := Left(_cFile,Len(_cFile)-4)
				_cFile := "\BAIXASPG\MP"+_cFile+"_"+_FilAtu+".RET"
				If File(_cFile)
					Delete File &_cFile.
				EndIf
				Set Filter to 
				DbGoTop()
				Copy To &_cFile. For (TRB0->CAMPO5 == _FilAtu .Or. TRB0->CAMPO1 $ "09") SDF
			EndDo
		EndIf
	Next

	DbSelectArea("TRB0")
	DbCloseArea("TRB0")   
Return(.T.)