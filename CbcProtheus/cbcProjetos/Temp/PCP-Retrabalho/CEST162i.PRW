#include "protheus.ch"
#include "topconn.ch"

// ROBERT SANTOS - 02/12/13
// IMPRESSAO DA NEGOCIACAO PARA ALTERAR O PEDIDO
user function CEST162i(cAlias, nReg, nOpc)

	local i
	Local cDesc1         := "Imprimir detalhe para alterar pedido "
	Local cDesc2         := ""
	Local cDesc3         := ""
	Local cPict          := ""
	Local titulo       := "Resumo de negociações"
	Local nLin         := 80
	local cACExt       := ""
	local cPerg			:= ""//PADR("CEST162i",10)
	Local imprime      := .T.
	Local aOrd := {}

	Private lEnd         := .F.
	Private lAbortPrint := .F.
	Private CbTxt		:= ""
	Private limite		:= 220
	Private tamanho		:= "G"
	Private nomeprog	:= PADR("CEST162i",10)
	Private nTipo		:= 18
	Private aReturn		:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey	:= 0
	Private cbtxt		:= Space(10)
	Private cbcont		:= 00
	Private CONTFL		:= 01
	Private m_pag		:= 01
	Private wnrel		:= PADR("CEST162i",10)
	Private cString		:= ""

	//ValidPerg(cPerg)
	//Pergunte(cPerg,.F.)
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	RptStatus({|| RunReport(Titulo,nLin) },Titulo)

Return Nil


Static Function RunReport(Titulo,nLin)

	Local nOrdem
	local cCabec1
	local cCabec2
	local cQry, nQry, cChave, lFirst

	dbselectarea("ZZV")

	If lAbortPrint
		@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
		return
	Endif

	iif( select("MTMP1") > 0, MTMP1->(dbclosearea()), )
	cQry := ""
	cQry += "SELECT ZZV.R_E_C_N_O_ NZZV, B1_DESC " + CRLF
	cQry += "FROM " + RETSQLNAME("ZZV") + " ZZV " + CRLF
	cQry += "INNER JOIN " + RETSQLNAME("SB1") + " SB1 ON SB1.D_E_L_E_T_ = ' ' " + CRLF
	cQry += " AND B1_COD = ZZV_PROALT AND B1_FILIAL = '" + xFilial("SB1") + "' " + CRLF
	cQry += "WHERE ZZV.D_E_L_E_T_ = ' ' " + CRLF
	cQry += "AND ZZV_FILIAL = '" + ZZV->ZZV_FILIAL + "' " + CRLF
	cQry += "AND ZZV_FILPV = '" + XFILIAL("SC6") + "' " + CRLF 
	if __lAltPed // para alterar o pedido
		cQry += "AND (ZZV_DTENCE != '' AND ZZV_ACEITE = 'S' AND ZZV_USERA = '' AND ZZV_LIBEOK = 'S') " + CRLF 
	else // para aprovar para alterar o pedido
		cQry += "AND (ZZV_DTENCE != '' AND ZZV_ACEITE = 'S' AND ZZV_USERA = '' AND (ZZV_LIBEOK = 'N' OR ZZV_LIBEOK = '')) " + CRLF
	endif
	cQry += "ORDER BY ZZV_PEDIDO, ZZV_ITEM " + CRLF
	TcQuery cQry new alias "MTMP1"
	Count to nQry
	if nQry > 0 
		SC6->(DBSETORDER(1))
		MTMP1->(dbgotop())
		SetRegua(nQry)
		Titulo	:= "NEGOCIAÇÃO"
		cCabec1 := "IT PRODUTO                                            METRAGEM TOTAL      ACOND.                         PRODUTO (OFERECIDO P/ CLIENTE)                     METRAGEM TOTAL      ACOND.                         % VAR.PRECO"
		cCabec2 := ""
		cChave	:= ""
		lFirst := .T.
		while !MTMP1->(eof())
			ZZV->(DBGOTO(MTMP1->(NZZV)))

			if nLin > 49
				nLin := 9
				Cabec(Titulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo)
			endif         

			SC6->(DBSEEK(ZZV->(ZZV_FILPV + ZZV_PEDIDO + ZZV_ITEM)))

			/*
			0         1         2         3         4         5         6         7         8         9        10         11       12        13        14        15        16        17        18        19        20        21       220
			01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
			IT PRODUTO                                            METRAGEM TOTAL      ACOND.                         PRODUTO (OFERECIDO P/ CLIENTE)                     METRAGEM TOTAL      ACOND.                         % VAR.PRECO
			PEDIDO: XXXXXX/XX CLIENTE: XXXXXXXXXXXXXXXXXXXX
			XX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99999    9999999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 99999    9999999999 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX 9999.99                               
			*/                                                
			if cChave != ZZV->(ZZV_FILPV + ZZV_PEDIDO + ZZV_ITEM)  
				cChave := ZZV->(ZZV_FILPV + ZZV_PEDIDO + ZZV_ITEM) 
				if lFirst == .F.
					nLin ++
				else
					if __lAltPed
						@ nLin	, 00 pSay "  * * * *    A  T  E  N  Ç  Ã  O    * * * * "
						nLin ++

						nLin ++
						@ nLin	, 00 pSay "   INSTRUÇõES PARA ALTERAR O PEDIDO DE VENDA, LEIA COM ATENÇÃO"
						nLin ++
						@ nLin	, 00 pSay "   > PARA CADA ITEM NEGOCIADO QUE POSSUA STATUS 'EM RETRABALHO' E/ OU 'MAIS ITENS EM NEGOCIAÇÃO', ALTERE O ITEM ORIGINAL DA SEGUINTE FORMA:"
						nLin ++
						@ nLin	, 00 pSay "    - SUBSTRAIR A QUANTIDADE TOTAL DO ITEM QUE SERÁ SUBSTITUIDO, CASO A QUANTIA SEJA A MESMA OU SUPERIOR, DELETAR O ITEM"
						nLin ++
						@ nLin 	, 00 pSay "    - ADICIONAR UM NOVO ITEM NO PEDIDO, CONFORME O NEGOCIADO"                                      
						nLin ++
						@ nLin 	, 00 pSay "   > PARA OS ITENS QUE NÃO TEM A MENSAGEM 'EM RETRABALHO' E/ OU 'MAIS ITENS EM NEGOCIAÇÃO', PODE SER ALTERADO O PRÓPRIO ITEM"
						nLin ++
						@ nLin 	, 00 pSay "   > APÓS A ALTERAÇÃO NO 'PEDIDO DE VENDA', ACESSAR A TELA DE 'PENDENTE PEDIDO' E CLICAR EM 'CONCLUIDO'"
						nLin ++
						@ nLin	, 00 pSay Replicate('-',220)   
						nLin ++
						nLin ++
					endif
					lFirst := .F.
				endif

				nLin ++
				@ nLIn, 00 pSay "PEDIDO: " + SC6->C6_NUM + "/" + SC6->C6_ITEM + " CLIENTE: " + RTRIM(ZZV->ZZV_NOMEC) + " "

				nLin ++
				@ nLIn, 00 pSay "MSG: " + PADR(ZZV->ZZV_OBS01,220)
				if SC6->C6_XQTDRET > 0
					nLin ++
					@ nLIn, 00 pSay "STATUS: EM RETRABALHO"
				endif
				if SC6->C6_XQTDNEG > 1
					nLin ++
					@ nLIn, 00 pSay "STATUS: MAIS ITENS EM NEGOCIACAO"
				endif
			endif  

			nLin ++
			@ nLIn, 00 pSay PADR(ZZV->ZZV_ITEM,2)
			@ nLIn, 03 pSay PADR(SC6->C6_DESCRI,50)
			@ nLIn, 54 pSay StrZero(SC6->C6_METRAGE,5,0)
			@ nLIn, 63 pSay StrZero(SC6->(C6_METRAGE * C6_LANCES),5,0)
			@ nLIn, 74 pSay PADR(dAcond(SC6->C6_ACONDIC),30)

			@ nLIn, 105 pSay PADR(MTMP1->B1_DESC,50)
			@ nLIn, 156 pSay StrZero(ZZV->ZZV_METRAL,5,0)
			@ nLIn, 165 pSay StrZero(ZZV->(ZZV_LANCEA * ZZV_METRAL),10,0)
			@ nLIn, 176 pSay PADR(dAcond(ZZV->ZZV_ACONAL),30)
			@ nLIn, 207 pSay TRANSFORM(GtPreco(ZZV->ZZV_PROALT,SC6->C6_PRODUTO,ZZV->ZZV_FILPV,ZZV->ZZV_PEDIDO, ZZV->(ZZV_LANCEA * ZZV_METRAL), ZZV->ZZV_ITEM) ,"@E 9999.99")

			IncRegua()
			MTMP1->(dbskip())
		enddo

	endif

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
	aAdd(aRegs,{cPerg,"02","Data De","mv_ch2","D", 8 ,0,0,"G","","MV_PAR02",""   ,"","",""   ,"","","","","","","","","","",""} )
	aAdd(aRegs,{cPerg,"03","Data Ate","mv_ch3","D", 8 ,0,0,"G","","MV_PAR03",""   ,"","",""   ,"","","","","","","","","","",""} )

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


static function dAcond(cAcond)

	do case
		case cAcond == "R"
		return "R- Rolo"
		case cAcond == "T"
		return "T- Retalho"
		case cAcond == "B"
		return "B- Bobina"
		case cAcond == "M"
		return "M- Carretel"
		case cAcond == "C"
		return "C- Carretel"
		case cAcond == "S"
		return "S- Sucata"
	endcase

return UPPER(cAcond)

static function GtPreco(cAL_PRODU,cProd,cFILPV,cPEDIDO, nTotalO, cItemPv) // consultar diferenca de precos

	local nPrecoOri	:= 0
	local nPrecoAlt	:= 0
	local nDiff		:= 0

	DA1->(dbsetorder(1))
	SC5->(dbsetorder(1))
	SC5->(dbseek(cFilPv + cPedido))

	if DA1->(DBSEEK(XFILIAL("DA1") + SC5->C5_TABELA + cProd))
		nPrecoOri := DA1->DA1_PRCVEN
	endif
	if DA1->(DBSEEK(XFILIAL("DA1") + SC5->C5_TABELA + cAL_PRODU))
		nPrecoAlt := DA1->DA1_PRCVEN
	endif
	nDiff := Round(((((nPrecoOri * SC6->(C6_METRAGE * C6_LANCES)) / (nPrecoAlt * nTotalO)) * 100) - 100),2)
	if nDiff < 0
		nDiff *= -1
	endif

return nDiff