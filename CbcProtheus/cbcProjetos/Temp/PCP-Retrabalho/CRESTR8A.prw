#include 'protheus.ch'
#include 'topconn.ch'

/*
BEGINDOC
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³IMPRIME ORDEM DE SERVICO DE RETRABALHO  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ENDDOC
*/

User Function CRESTR8A()

	local i
	Local cDesc1         := "Imprime Ordem de Retrabalhos"
	Local cDesc2         := ""
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo       := "ORDEM DE RETRABALHO"
	Local nLin         := 80
	local cACExt       := ""    
	local cPerg			:= PADR("CRESTR8A",10)

	Local Cabec1       := ""
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint := .F.
	Private CbTxt		:= ""
	Private limite		:= 80
	Private tamanho		:= "P"
	Private nomeprog	:= PADR("CRESTR8A",10) // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo 		:= 18
	Private aReturn		:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey	:= 0
	Private cbtxt		:= Space(10)
	Private cbcont		:= 00
	Private CONTFL		:= 01
	Private m_pag		:= 01
	Private wnrel		:= PADR("CRESTR8A",10) // Coloque aqui o nome do arquivo usado para impressao em disco e o nome do grupo de perguntas

	Private cString		:= ""    
	private _nMin 		:= 7
	private _nMax		:= 55

	ValidPerg(cPerg)
	Pergunte(cPerg,.F.)
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return Nil


Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	local lPrimVez := .t.
	local lCabec   := .f.
	Local nOrdem
	local cACExt := ""
	local i := 0
	local cQuebra := ""
	local cTpBob := ""
	local cACExt := ""
	local nquery := 0
	local cTpBob := ""
	local nMetEnt := 0
	local nMetSai := 0
	local nMetSob := 0
	local cChave := ""

	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		return
	Endif

	cQuery :=  " SELECT R_E_C_N_O_ NZZE "+;
	" FROM "+RetSqlName("ZZE")+" ZZE " +;
	" WHERE "+;
	" ZZE_FILIAL =  '"+xFilial("ZZE")+"'  AND "+;
	" ZZE_ORDEM BETWEEN '"+ MV_PAR01  +"' AND '" + MV_PAR02 + "' "+;
	" AND ZZE_ORDEM <> '   ' "+; // By Roberto Oliveira 14/02/14 - Para não imprimir ordens não geradas.
	" AND D_E_L_E_T_ = ' ' "+;
	" ORDER BY ZZE_FILIAL, ZZE_ID, ZZE_ORDEM "
	if select("ZZEX") > 0
		dbselectarea("ZZEX")
		ZZEX->(dbclosearea())
	endif                

	dbselectarea("ZZE")

	dbUseArea( .T., "TOPCONN", TCGENQRY(,, cQuery ), "ZZEX", .F., .T. )
	dbSelectArea( "ZZEX" )
	procregua(ZZEX->(recno()))
	dbGotop()
	count to nquery

	/*/
	// By Roberto Oliveira 14/02/14
	// Sair somente após o loop pois se for pra disco o arquivo destino fica travado
	if nquery == 0
	alert("Nao selecionou nada....encerra")
	return
	endif  
	/*/

	nLin := 99 // By Roberto Oliveira 14/02/14 -> Deixo nLin com 99 para poder testar ao final da rotina

	dbGotop()
	While ZZEX->(!Eof())

		ZZE->(DBGOTO(ZZEX->NZZE))

		if lPrimVez .Or. (lPrimVez == .F. .and. cChave != ZZE->ZZE_ORDEM)
			cChave := ZZE->ZZE_ORDEM
			lPrimVez := .f.

			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := _nMin
			ImpIdSep(@nLin)    // imprime Id ORDEM SERVICO

			cQuebra := ""
		Endif

		if cQuebra # ZZE->ZZE_ID

			If nLin > _nMax // Salto de Página. Neste caso o formulario tem 51 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := _nMin
				ImpIdSep(@nLin)    // imprime Id separacao
			Endif

			nlin++
			@ nlin , 000 psay replicate("-",80)
			nlin++
			@ nlin , 000 psay "ID. RETRABALHO: " + ZZE->ZZE_ID
			nlin++
			@ nlin , 000 psay replicate("-",80)

			nLin ++
			@ nlin , 000 psay "PRODUTO: " + RTRIM(ZZE->ZZE_PRODUT) + " " + ALLTRIM(POSICIONE("SB1",1,XFILIAL("SB1") + ZZE->ZZE_PRODUT, "B1_DESC"))
			nLin++
			@ nlin , 000 psay "Data término: _____/_____/_____         Hora: ____:____ "
			nLin++
			nlin++
			@ nlin , 000 psay "Responsável: ______________________________________________ "
			nlin++
			@ nlin , 000 psay replicate("-",80)
			nlin++

			cACExt := u_TRACEXT(ZZE->ZZE_ACONDE)
			@ nlin , 000 psay "Entrada-->  "+transform(ZZE->ZZE_LANCEE,"@E 999,999.99")+cACExt+" X "+transform(ZZE->ZZE_METRAE,"@E 999,999.99")+" metros = "+;
			transform(ZZE->ZZE_TOTEN,"@E 999,999.99")+" metros"

			if ZZE->ZZE_ACONDE == "B"
				nLin ++
				@ nlin , 000 psay "BOBINA = " + ZZE->ZZE_NUMBOB
				cTpBob := posicione("SZE", 1, xFilial("SZE")+ZZE->ZZE_NUMBOB, "ZE_TPBOB")
				@ nLin , 034 PSAY "Tipo Bobina = "+ Substr("65x25; 65x45; 80x45;100x60;125x70;150x80;170x80",((Val(cTpBob)*7)-6)-1,6)
			endif
			nlin++
			@ nlin , 000 psay replicate("-",80)

			nMetEnt += ZZE->ZZE_TOTEN // iif(ZZE->ZZE_STATUS != "9",ZZE->ZZE_TOTEN,0)

			cQuebra := ZZE->ZZE_ID
		endif


		if ZZE->ZZE_PEDIDO == "000001" //  SOBRA		
			If nLin > _nMax // Salto de Página. Neste caso o formulario tem 51 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := _nMin
				ImpIdSep(@nLin)    // imprime Id separacao
				lCabec :=.t.
			Endif

			if lCabec
				lCabec := .f.

				nlin++ // aqui
				@ nlin , 000 psay replicate("-",80)
			endif
			// @ nlin , 000 psay "ID. RETRABALHO: " + ZZE->ZZE_ID
			// nlin++

			nLin ++
			cACExt := u_TRACEXT(ZZE->ZZE_ACONDS)
			@ nlin , 000 psay "Sobra-->  "+transform(ZZE->ZZE_LANCES,"@E 999,999.99")+cACExt+" X "+transform(ZZE->ZZE_METRAS,"@E 99999")+" metros = "+;
			transform(ZZE->ZZE_TOTSA,"@E 999,999.99")+" metros"
			ImpStatus(@nLin)

			nMetSob += ZZE->ZZE_TOTSA

			nlin++
			@ nlin , 000 psay replicate("-",80)
			nlin++
		else			
			If nLin > _nMax // Salto de Página. Neste caso o formulario tem 51 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := _nMin
				ImpIdSep(@nLin)    // imprime Id separacao
			Endif

			nLin ++
			@ nlin , 000 psay replicate("-",80)

			nlin++
			@ nlin , 000 psay "Cliente: " + ZZE->ZZE_CODCLI
			@ nlin , 017 psay "Lj: " + ZZE->ZZE_LOJA
			@ nlin , 025 psay "Nome: " + ZZE->ZZE_NOMCLI
			nlin++
			@ nlin , 000 psay "Pedido: " + ZZE->ZZE_PEDIDO
			@ nlin , 015 psay "Item: " + ZZE->ZZE_ITEMPV
			@ nlin , 030 psay "Dt.Entrega: " + dtoc((ZZE->ZZE_PVENTR))
			@ nlin , 058 psay "Dt.Inicio: " + dtoc((ZZE->ZZE_DTINI))
			nlin++                             

			If ZZE->ZZE_ACONDS == "B" .And. ;
			(u_xIsInspe(ZZE->ZZE_PEDIDO)[1] .Or.;
			Posicione("SB1",1,xFilial("SB1")+ZZE->ZZE_PRODUT,"B1_ZZINSPE") == "S")


				// Verificar se a bobina tem que ser inspecionada
				@ nlin , 000 psay "Observ: MATERIAL SERA INSPECIONADO -> PONTA PARA FORA"// + ZZEX->ZZE_OBSERV              // campo memo ver se usa depois o memoline
			Else
				@ nlin , 000 psay "Observ: "// + ZZEX->ZZE_OBSERV              // campo memo ver se usa depois o memoline
			EndIf

			nlin++
			cACExt := u_TRACEXT(ZZE->ZZE_ACONDS)
			@ nlin , 000 psay "Saída--->  "+transform(ZZE->ZZE_LANCES,"@E 999,999.99")+cACExt+" X "+transform(ZZE->ZZE_METRAS,"@E 999,999.99")+" metros = "+;
			transform(ZZE->ZZE_TOTSA,"@E 999,999.99")+" metros"
			ImpStatus(@nLin)

			nMetSai += iif(ZZE->ZZE_STATUS != "9",ZZE->ZZE_TOTSA,0)
		endif

		ZZEX->( dbskip() )
	enddo

	If nLin # 99 // By Roberto Oliveira 14/02/14 -> Se nLin for 99 não imprimiu nada

		nlin++
		nlin++

		// imprime totais
		nLin := _nMin
		Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)

		nLin++
		@ nlin , 000 psay replicate("-",80)
		nlin++
		@ nlin , 000 psay "Total Metrag Entrada-->  "+transform(nMetEnt,"@E 999,999.99")
		nlin++
		@ nlin , 000 psay "Total Metrag Saída---->  "+transform(nMetSai,"@E 999,999.99")
		nlin++
		@ nlin , 000 psay "Total Metrag Sobra---->  "+transform(nMetSob,"@E 999,999.99")
		@ nlin , 050 psay "Diferença---->  "+transform(  nMetEnt - (nMetSob + nMetSai) ,"@E 999,999.99")
		nLin++
		@ nlin , 000 psay replicate("-",80)

		/*
		if cZZF_STAT == "6"
		cQuery :=  " UPDATE " +RetSqlName("ZZF")+ " SET ZZF_STATUS = '7' WHERE ZZF_ID = '"+cZZF_ID+"'"

		TcSqlExec( cQuery )
		else
		alert("Status será deixado como está para refletir situação das Baixas da Separação")
		endif
		*/
	EndIf

	// By Roberto Oliveira 14/02/14
	// Fechar a tabela provisória
	dbselectarea("ZZEX")
	ZZEX->(dbclosearea())


	SET DEVICE TO SCREEN

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return


Static Function ValidPerg( cPerg )

	local _aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Ordem Servico De","mv_ch1","C",TamSX3("ZZE_ORDEM")[1] ,0,0,"G","","MV_PAR01",""   ,"","",""   ,"","","","","","","","","","","ZZE1"} )
	aAdd(aRegs,{cPerg,"02","Ordem Servico Ate","mv_ch2","C",TamSX3("ZZE_ORDEM")[1] ,0,0,"G","","MV_PAR02",""   ,"","",""   ,"","","","","","","","","","","ZZE1"} )


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


Static Function ImpIdSep( nLin)

	local cDescPro := ""

	@ nLin , 000 PSAY "ID. ORDEM DE SERVICO : " + ZZE->ZZE_ORDEM
	@ nLin , 030 psay "Data: "+ dtoc(dDatabase)

return


user function _RtStat(cZZE_STATUS)
	local cRet := ""
	do case
		case cZZE_STATUS == "1"
		cRet := "AGUARD. SEPARAR"
		case cZZE_STATUS == "2"
		cRet := "AGUARD. ORDEM SERVICO"
		case cZZE_STATUS == "3"
		cRet := "EM RETRABALHO"
		case cZZE_STATUS == "4"
		cRet := "REALIZADO" // "FINALIZADO"   REALIZADO -> Alterei o Status 4 de FINALIZADO para REALIZADO pq a finalização será por outro campo
		case cZZE_STATUS == "9"
		cRet := "CANCELADO"
		case cZZE_STATUS == "A"
		cRet := "RETORNO NAO PLANEJADO PARA ESTOQUE"
		case cZZE_STATUS == "B"
		cRet := "REALIZADO SEM ATENDER TODO O PEDIDO" // "FINALIZADO SEM ATENDER TODO O PEDIDO"
	endcase
return cRet


static function ImpStatus(nLin)                          
	nLin ++
	@ nLin , 000 pSay "STATUS: " + u__RtStat(ZZE->ZZE_STATUS)
return