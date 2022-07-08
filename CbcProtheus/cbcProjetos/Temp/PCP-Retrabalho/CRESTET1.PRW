#include 'protheus.ch'
#include "rwmake.ch"
#include 'topconn.ch'


// ETIQUETA DA SEPARACAO
user function CRESTET1()
	local cEtiq := ""
	local cQry, nQry
	local nHdl := 0
	private cPerg := PADR("CRESTET1A",10)

	SB1->(dbsetorder(1))

	ValidPerg( cPerg )
	if pergunte( cPerg, .t.)

		ZZE->(DbSetOrder(1))

		cQry :=  " SELECT * "+;
		" FROM "+RetSqlName("ZZU")+" ZZU " +;
		" WHERE "+;
		" ZZU.ZZU_FILIAL =  '" + xFilial("ZZU") + "'  AND "
		If ! Empty(Alltrim(mv_par01))
			cQry += " ZZU.ZZU_ZZFID = '" + mv_par01 + "'  AND "
		Else
			cQry += " ZZU.ZZU_ZZEID = '" + mv_par03 + "'  AND "
		EndIf
		cQry += " D_E_L_E_T_ <> '*' "+;
		" ORDER BY ZZU.ZZU_ZZFID, ZZU.ZZU_ZZEID"

		cQry := ChangeQuery(cQry)

		if select("ZZUX") > 0
			dbselectarea("ZZUX")
			ZZUX->(dbclosearea())
		endif
		dbUseArea( .T., "TOPCONN", TCGENQRY(,, cQry ), "ZZUX", .F., .T. )
		count to nqry

		if nqry > 0
			dbSelectArea( "ZZUX" )
			dbGotop()
			while !ZZUX->( eof() )
				SB1->(dbseek(xFilial("SB1") + ZZUX->ZZU_PRODUT))
				ZZE->(dbseek(ZZUX->(ZZU_FILIAL + ZZU_ZZEID)))
				SZE->(dbseek(xFilial("SZE") + ZZUX->ZZU_NUMBOB))//"ZE_TPBOB"

			cEtiq := "" // LINGUAGEM ZPL
				cEtiq += 'CT~~CD,~CC^~CT~' + CRLF
				cEtiq += '^XA~TA000~JSN^LT0^MNW^MTD^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ' + CRLF
				cEtiq += '^XA' + CRLF
				cEtiq += '^MMT' + CRLF
				cEtiq += '^PW831' + CRLF
				cEtiq += '^LL0663' + CRLF
				cEtiq += '^LS0' + CRLF
				cEtiq += '^FT024,381^A0N,135,134^FH\^FDZZE_ID^FS' + CRLF

				cEtiq += '^FT223,462^A0N,28,28^FH\^FDZZU_NUMBOB^FS' + CRLF
				cEtiq += '^FT223,492^A0N,28,28^FH\^FDZZE_METRAE^FS' + CRLF
				cEtiq += '^FT223,522^A0N,28,28^FH\^FDZZE_LANCEE^FS' + CRLF
				cEtiq += '^FT223,552^A0N,28,28^FH\^FDZZE_ACONDE^FS' + CRLF
				cEtiq += '^FT223,592^A0N,28,28^FH\^FDZE_TPBOB^FS' + CRLF

				cEtiq += '^FT030,462^A0N,28,28^FH\^FDNO. BOBINA:^FS' + CRLF
				cEtiq += '^FT030,492^A0N,28,28^FH\^FDTAM.LANCE ENTR.:^FS' + CRLF
				cEtiq += '^FT030,522^A0N,28,28^FH\^FDQTD.LANCES ENTR.:^FS' + CRLF
				cEtiq += '^FT030,552^A0N,28,28^FH\^FDACOND ENTR.:^FS' + CRLF
				cEtiq += '^FT030,592^A0N,28,28^FH\^FDTIPO BOB:^FS' + CRLF

				cEtiq += '^FT025,234^A0N,28,28^FH\^FDNUMERO DO RETRABALHO:^FS' + CRLF
				cEtiq += '^FT024,137^A0N,28,28^FH\^FDDESCRICAO: B1_DESC^FS' + CRLF
				cEtiq += '^FT025,109^A0N,28,28^FH\^FDPRODUTO: B1_COD^FS' + CRLF

				cEtiq += "^FO660,186^BY3,,60^BCB,110,N,N^FD" + ALLTRIM(ZZE->ZZE_ID) + "^FS"

				cEtiq += '^PQ1,0,1,Y^XZ' + CRLF

				cEtiq := replace(cEtiq, "B1_COD", ALLTRIM(SB1->B1_COD) )
				cEtiq := replace(cEtiq, "B1_DESC", ALLTRIM(SB1->B1_DESC) )
				cEtiq := replace(cEtiq, "ZZE_ID", ALLTRIM(ZZUX->ZZU_ZZEID) )
				if ZZE->ZZE_ACONDE == "B"
					cEtiq := replace(cEtiq, "ZZU_NUMBOB", ALLTRIM(ZZUX->ZZU_NUMBOB) )
				else
					cEtiq := replace(cEtiq, "ZZU_NUMBOB", "")
				endif
				cEtiq := replace(cEtiq, "ZZE_METRAE", Transform(ZZE->ZZE_METRAE,"@E 999,999") ) // Roberto Oliveira 11/02/14
				cEtiq := replace(cEtiq, "ZZE_LANCEE", Transform(ZZE->ZZE_LANCEE,"@E 999,999") ) // Roberto Oliveira 11/02/14

				Do Case
					Case ZZE->ZZE_ACONDE = "B"
						cEtiq := replace(cEtiq, "ZZE_ACONDE"  ,"BOBINA")
					Case ZZE->ZZE_ACONDE = "C"
						cEtiq := replace(cEtiq, "ZZE_ACONDE"  ,"CARR.PLAST.")
					Case ZZE->ZZE_ACONDE = "L"
						cEtiq := replace(cEtiq, "ZZE_ACONDE"  ,"BLISTER")
					Case ZZE->ZZE_ACONDE = "R"
						cEtiq := replace(cEtiq, "ZZE_ACONDE"  ,"ROLO")
					Case ZZE->ZZE_ACONDE = "M"
						cEtiq := replace(cEtiq, "ZZE_ACONDE"  ,"CARR.MAD.")
				EndCase

				cEtiq := replace(cEtiq, "ZE_TPBOB"  , Substr("65x25; 65x45; 80x45;100x60;125x70;150x80;170x80",((Val(SZE->ZE_TPBOB)*7)-6)-1,6))

				nHdl := fCreate(MV_PAR02)
				if nHdl < 0
					// Alert("Erro de comunicação com a porta: '" + MV_PAR02 + "' ")
					Do While .T.
						If MsgBox("Erro de comunicação com a porta: '" + MV_PAR02 + "' " + Chr(13) + ;
						"Aguarde o término da impressão e escolha Sim para Continuar ou Não para Parar","Confirma?","YesNo")

							nHdl := fCreate(MV_PAR02)
							if nHdl > 0
								Exit
							EndIf
						Else
							Exit
						EndIf
					EndDo
				EndIf
				if nHdl > 0
					fWrite(nHdl,cEtiq)
					fClose(nHdl)
				Else
					Exit
				endif
				ZZUX->(dbskip())
			enddo
		else
			alert("Não encontrado a Ordem de Separação selecionada..." + mv_par01 + "   Pode ser que não foi ainda impressa a Ordem de Separação")
		endif
	endif
return


Static Function ValidPerg(cPerg)
	local _aArea := GetArea()
	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","ID.Separação","mv_ch1","C",TamSX3("ZZF_ID")[1] ,0,0,"G","","mv_par01",""   ,"","",""   ,"","","","","","","","","","","ZZU"})
	aAdd(aRegs,{cPerg,"02","Porta","mv_ch2","C",8,0,0,"G","","mv_par02",""   ,"","",""   ,"","","","","","","","","","",""})
	For i := 1 To Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			SX1->X1_GRUPO   := aRegs[i,01]
			SX1->X1_ORDEM   := aRegs[i,02]
			SX1->X1_PERGUNT := aRegs[i,03]
			SX1->X1_VARIAVL := aRegs[i,04]
			SX1->X1_TIPO    := aRegs[i,05]
			SX1->X1_TAMANHO := aRegs[i,06]
			SX1->X1_DECIMAL := aRegs[i,07]
			SX1->X1_PRESEL  := aRegs[i,08]
			SX1->X1_GSC     := aRegs[i,09]
			SX1->X1_VALID   := aRegs[i,10]
			SX1->X1_VAR01   := aRegs[i,11]
			SX1->X1_DEF01   := aRegs[i,12]
			SX1->X1_CNT01   := aRegs[i,13]
			SX1->X1_VAR02   := aRegs[i,14]
			SX1->X1_DEF02   := aRegs[i,15]
			SX1->X1_CNT02   := aRegs[i,16]
			SX1->X1_VAR03   := aRegs[i,17]
			SX1->X1_DEF03   := aRegs[i,18]
			SX1->X1_CNT03   := aRegs[i,19]
			SX1->X1_VAR04   := aRegs[i,20]
			SX1->X1_DEF04   := aRegs[i,21]
			SX1->X1_CNT04   := aRegs[i,22]
			SX1->X1_VAR05   := aRegs[i,23]
			SX1->X1_DEF05   := aRegs[i,24]
			SX1->X1_CNT05   := aRegs[i,25]
			SX1->X1_F3      := aRegs[i,26]
			MsUnlock()
			DbCommit()
		Endif
	Next
	RestArea(_aArea)
Return
