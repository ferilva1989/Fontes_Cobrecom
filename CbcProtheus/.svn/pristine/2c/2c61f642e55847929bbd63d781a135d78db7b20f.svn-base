#Include "PROTHEUS.CH"
//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: 	cdest05                           Modulo : SIGAEST      //
//                                                                          //
//                                                    Data ..: 27/04/2006   //
//                                                                          //
//   Objetivo ...: As funções deste fonte são complementos do programa      //
//   CDEST05 e estão separados porque esta função necessita o uso da include//
//   PROTHEUS.CH que não pode ser usado no CDEST05.                         //
//                                                                          //
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//                                                                          //
////////////////////////////////////////////'//////////////////////////////////
//
*
********************************
User Function Tipos(cTab,cCad)
	********************************
	*
	LOCAL cCapital
	LOCAL nX
	LOCAL cCad,cTab
	LOCAL _aArea := GetArea()
	LOCAL oOk := LoadBitmap( GetResources(), "LBOK" )
	LOCAL oNo := LoadBitmap( GetResources(), "LBNO" )
	LOCAL oQual
	LOCAL cVar := "  "
	LOCAL nOpca
	LOCAL oDlg
	LOCAL aTipoBack:={}
	LOCAL aTipos:={}
	LOCAL lRunDblClick := .T.
	LOCAL _cTabFil
	LOCAL _cNotEof
	LOCAL _cCpo01
	LOCAL _cCpo02
	LOCAL _nTamCd := 0

	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek(cTab,.F.)
	_cTabFil := cTab + "->" + AllTrim(SX3->X3_CAMPO)
	_cNotEof := "!"  + cTab + "->(Eof())"
	_cCpo01 := " "
	_cCpo02 := " "
	Do While SX3->X3_ARQUIVO == cTab .And. !SX3->(Eof())
		If "_COD" $ SX3->X3_CAMPO
			_cCpo01 := cTab + "->" + AllTrim(SX3->X3_CAMPO)
			_nTamCd := SX3->X3_TAMANHO
		EndIf
		If "_DESC" $ SX3->X3_CAMPO
			_cCpo02 := cTab + "->" + AllTrim(SX3->X3_CAMPO)
		EndIf
		If !Empty(_cCpo01) .And. !Empty(_cCpo02)
			Exit
		EndIf
		DbSkip()
	EndDo

	DbSelectArea(cTab)
	DbSetOrder(1)
	DbSeek(xFilial(cTab),.F.)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a tabela 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do While &_cTabFil. == xFilial(cTab) .And. &_cNotEof.
		_cCpoG01 := &_cCpo01.
		_cCpoG02 := &_cCpo02. // Left(Capital(&_cCpo02.) + Space(30),30)
		Aadd(aTipos,{.T.,_cCpoG01 + " - " + _cCpoG02})
		dbSkip( )
	EndDo
	aTipoBack := aClone(aTipos)
	nOpca := 0
	DEFINE MSDIALOG oDlg TITLE cCad From 9,0 To 35,50 OF oMainWnd

	@ 0.5,  0.3 TO 13.6, 20.0 LABEL cCad OF oDlg
	@ 2.3,3 Say OemToAnsi("  ")
	@ 1.0,.7 LISTBOX oQual VAR cVar Fields HEADER "",OemToAnsi(cCad)  SIZE 150,170 ON DBLCLICK (aTipoBack:=FA060Troca(oQual:nAt,aTipoBack),oQual:Refresh()) NOSCROLL

	oQual:SetArray(aTipoBack)
	oQual:bLine := { || {if(aTipoBack[oQual:nAt,1],oOk,oNo),aTipoBack[oQual:nAt,2]}}
	oQual:bHeaderClick := {|oObj,nCol| If(lRunDblClick .And. nCol==1, aEval(aTipoBack, {|e| e[1] := !e[1]}),Nil), lRunDblClick := !lRunDblClick, oQual:Refresh()}

	DEFINE SBUTTON FROM 10  ,166  TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 22.5,166  TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

	ACTIVATE MSDIALOG oDlg CENTERED

	cTipos :=""
	_lTudo := .T. // Controle se escolheu todos para não deixar uma string muito longa
	IF nOpca == 1
		aTipos := Aclone(aTipoBack)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta a string de tipos para filtrar o arquivo               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nX := 1 To Len(aTipos)
			If aTipos[nX,1]
				cTipos += Left(aTipos[nX,2],_nTamCd)+"/"
			ElseIf _lTudo
				_lTudo := .F.
			EndIf
		Next nX      

		If Empty(cTipos) .Or. _lTudo // Controle se escolheu todos para não deixar uma string muito longa
			cTipos := "*"
		EndIf
	Else
		cTipos := "" // Escolheu cancelar
	EndIF

	DeleteObject(oOk)
	DeleteObject(oNo)
	RestArea(_aArea)
Return(cTipos)