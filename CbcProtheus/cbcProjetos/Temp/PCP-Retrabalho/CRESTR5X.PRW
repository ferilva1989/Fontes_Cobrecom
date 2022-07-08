#include 'protheus.ch'
#include 'topconn.ch'


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CRESTR5X   ºAutor  ³ Airton PROATIVA    º Data ³  06/07/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ imprimir ordem de separacao                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ COBRECOM                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CRESTR5X()

	/* Abrir tela para mostrar material para separar */
	local cqry, nqry
	local aDados := {}

	Private cTitulo		:= "ORDEM DE SEPARAÇÃO P/ RETRABALHO"
	private aDados      := {}
	private cVarSep
	private cPerg       := PADR("CRESTR5X",10)

	ValidPerg( cPerg )
	if pergunte( cPerg, .t.)
		cqry := "select ZZF.R_E_C_N_O_ ZZFRECNO from "+RetSQLName("ZZF")+" ZZF where ZZF.D_E_L_E_T_ = '' "
		cqry += "	and ZZF_TIPO   = 'R' " // TIPO DE SEPARAR PARA RETRABALHO
		cqry += "	and ZZF_STATUS NOT IN ('A','2') " // STATUS DE FALTA DE ORDEM DE SEPARACAO DE RETRABALHO
		cqry += "	and ZZF_FILIAL = '"+xFilial("ZZF")+"' "
		cqry += "	and ZZF_ID between '" + MV_PAR01 + "' and '" + MV_PAR02 + "' " // COM NRO SEPARACAO
		cqry += "   order by ZZF_ID "                     

		iif( select("ZZFX") > 0, ZZFX->(dbclosearea()),  )
		tcquery cqry new alias "ZZFX"

		count to nqry
		if nqry > 0             
			dbselectarea("ZZF")
			ZZFX->(DbGoTop()) // ZZFX - Arquivo temporário
			Imprime()
		else 
			MsgInfo("SEPARACAO NAO ENCOTRADA, OU FORA DO STATUS DE IMPRESSÃO!")
		endif
	endif

return


/*
BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime separação                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC
*/
Static Function Imprime()

	local i
	Local cDesc1         := "Relatorio de Separação para Retrabalho "
	Local cDesc2         := ""
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo       := "ORDEM DE SEPARAÇÃO P/ RETRABALHO"
	Local nLin         := 80
	local cACExt       := ""

	Local Cabec1       := "MATERIAL PARA SOLICITAR AO ESTOQUE"
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 80
	Private tamanho          := "P"
	Private nomeprog         := "CRESTR5X" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "CRESTR5" // Coloque aqui o nome do arquivo usado para impressao em disco

	Private cString := ""


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a interface padrao com o usuario...                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return


/*
BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄDh/Dh/¿
//³Funcao de Impressao³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC
*/
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	local lPrimVez := .t.
	Local nOrdem
	local cACExt := ""
	local i := 0
	local cQuebra := ""
	local cTpBob := ""
	local lTrocar
	local nSeq := 0

	//  vai imprimir para BOBINA
	while !ZZFX->(EOF())
		ZZF->(DBGOTO(ZZFX->(ZZFRECNO)))

		If nLin > 51 // Salto de Página. Neste caso o formulario tem 51 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 8
		Endif

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif    

		if( ZZF->ZZF_ID != cQuebra )     
			if( lPrimVez == .F. )
				nLin ++
				@ nlin , 000 psay "Data recebimento: _____/_____/_____         Hora: ____:____ " // assinatura da anterior
				nLin++
				nlin++
				@ nlin , 000 psay "Responsável: ______________________________________________ "      
				nLin ++
				@ nlin , 000 psay replicate("-",80)  

				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
			endif
			nLin ++
			@ nlin , 000 psay replicate("-",80)  // cabecalho da separacao

			nLin ++
			@ nLin , 000 PSAY "ID.SEPARAÇÃO: " + ZZF->ZZF_ID

			nLin ++
			@ nlin , 000 psay replicate("-",80)     
			cQuebra := ZZF->ZZF_ID
		endif

		nLin ++
		@ nLin , 022 psay "Data: "+ dtoc(ZZF->ZZF_DTINC)
		@ nLin , 042 psay "Respons.: "+ alltrim(ZZF->ZZF_RESPON)

		nlin++
		@ nLin , 000 psay "Prod: "+ ZZF->ZZF_PRODUT
		cDescPro := posicione("SB1", 1, xFilial("SB1")+ZZF->ZZF_PRODUT, "B1_DESC")
		@ nlin , 022 psay "Descr: "+ cDescPro

		nlin++
		cACExt := u_TRACEXT(ZZF->ZZF_ACONDS)
		@ nlin , 000 psay "Estoque-->  "+transform(ZZF->ZZF_LANCES,"@E 999,999")+cACExt+" X "+transform(ZZF->ZZF_METRAS,"@E 999,999")+" metros = "+;
		Transform(ZZF->(ZZF_LANCES * ZZF_METRAS),"@E 999,999")+" metros"

		if ZZF->ZZF_ACONDS == "B"
			nLin ++
			@ nlin , 000 psay "BOBINA  = " + ZZF->ZZF_NUMBOB
			cTpBob := posicione("SZE", 1, xFilial("SZE")+Left(ZZF->ZZF_NUMBOB,Len(SZE->ZE_NUMBOB)), "ZE_TPBOB")
			@ nLin , 035 PSAY "Tipo Bobina = "+ Substr("65x25; 65x45; 80x45;100x60;125x70;150x80;170x80",((Val(cTpBob)*7)-6)-1,6)
			nLin ++
			@ nlin , 000 psay "CLIENTE = " + posicione("SZE", 1, xFilial("SZE")+Left(ZZF->ZZF_NUMBOB,Len(SZE->ZE_NUMBOB)), "ZE_NOMCLI")
		endif

		nLin ++
		@ nlin , 000 psay replicate("-",80)  

		if ZZF->ZZF_STATUS == "3" // nao reimpressao
			// grava ZZU - entradas da ordem de separação
			dbselectarea("ZZU")
			dbsetorder(1)  // filial + zzfid+ sequencia
			nSeq++
			reclock("ZZU", .t.)

			ZZU->ZZU_FILIAL := xfilial("ZZU")
			ZZU->ZZU_SEQUEN := STRZERO(nSeq,6,0)
			ZZU->ZZU_PRODUT := ZZF->ZZF_PRODUT
			ZZU->ZZU_DESCRI := cDescPro
			ZZU->ZZU_LANCE  := ZZF->ZZF_LANCES
			ZZU->ZZU_METRA  := ZZF->ZZF_METRAS
			ZZU->ZZU_METRA  := ZZF->ZZF_METRAS
			ZZU->ZZU_TOTAL  := ZZF->( ZZF_LANCES * ZZF_METRAS )
			ZZU->ZZU_ACOND  := ZZF->ZZF_ACONDS
			ZZU->ZZU_ZZFID  := ZZF->ZZF_ID
			ZZU->ZZU_STATUS := "1" // NAO BAIXADO
			ZZU->ZZU_NUMBOB := ZZF->ZZF_NUMBOB
			ZZU->ZZU_ZZEID  := ZZF->ZZF_ZZEID

			ZZU->( MSUNLOCK() )		
		endif

		if ZZF->ZZF_STATUS == "3" // NAO IMPRESSO
			reclock("ZZF", .F.)
			ZZF->ZZF_STATUS := "4" // IMPRESSO
			ZZF->ZZF_DTIMPR := dDatabase	
			ZZF->( msunlock() )
		endif
		lPrimVez := .F.

		ZZFX->(dbskip())
	enddo

	If nLin > 51 // Salto de Página. Neste caso o formulario tem 51 linhas...
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
		nLin := 8
	Endif

	nLin++ // assinatura da anterior
	@ nlin , 000 psay "Data recebimento: _____/_____/_____         Hora: ____:____ "
	nLin++
	nlin++
	@ nlin , 000 psay "Responsável: ______________________________________________ "      
	nLin ++
	@ nlin , 000 psay replicate("-",80)  
	nLin ++

	// impressao final
	nlin++
	nlin++
	@ nlin, 000 psay replicate("-",80)
	nlin++
	@ nlin, 000 psay "| Observações:"+space(65)+"|"
	nlin++
	@ nlin, 000 psay "|"+space(78)+"|"
	nlin++
	@ nlin, 000 psay "|"+space(78)+"|"
	nlin++
	@ nlin, 000 psay "|"+space(78)+"|"
	nlin++
	@ nlin, 000 psay "|"+space(78)+"|"
	nlin++
	@ nlin, 000 psay replicate("-",80)


	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return


/*
BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄf¿
//³Traz UM por Extenso Airton 07/06/13³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄfÙ
ENDDOC
*/
User Function TRACEXT(cAC)
	local aArray := {}
	local cExt := ""
	local n := 0

	aadd( aArray, {"R", " Rolos "})
	aadd( aArray, {"M", " Carret.Madeira "})
	aadd( aArray, {"T", " Retalhos "})
	aadd( aArray, {"C", " Carreteis "})
	aadd( aArray, {"B", " Bobinas "})
	aadd( aArray, {"L", " Blisters "})
	aadd( aArray, {"S", " Sucata "})

	n := Ascan(aArray,{|x| x[1] == cAC})
	if n > 0
		cExt := aArray[n][2]
	else
		alert("Acondic. invalido = "+cAC)
	endif
return(cExt)


/*
BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄ¿
//³Validacao³
//ÀÄÄÄÄÄÄÄÄÄÙ
ENDDOC
*/
Static Function ValidPerg( cPerg )

	local _aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Separacao De","mv_ch1","C",TamSX3("ZZF_ID")[1] ,0,0,"G","","mv_par01",""   ,"","",""   ,"","","","","","","","","","","ZZF"})
	aAdd(aRegs,{cPerg,"02","Separaca Ate","mv_ch2","C",TamSX3("ZZF_ID")[1] ,0,0,"G","","mv_par02",""   ,"","",""   ,"","","","","","","","","","","ZZF"})


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