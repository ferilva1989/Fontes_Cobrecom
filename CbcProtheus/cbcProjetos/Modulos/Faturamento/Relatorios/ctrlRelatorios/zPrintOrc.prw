#include "rwmake.ch"
#include 'protheus.ch'

User Function zPrtOrc(cFact)	//U_zPrtOrc('orcamento')
	local cDesc1        := "Este programa tem como objetivo imprimir relatório "
	local cDesc2        := "de Orçamento de Vendas de acordo "
	local cDesc3        := "com os parâmetros informados pelo usuário."
	local cPict         := ""
	local titulo        := "Orçamento de Vendas"
	local nLin          := 80
	local Cabec1        := ""
	local Cabec2        := ""
	local imprime       := .T.
	local aOrd          := {}
	local aPergs 		:= {}
	local aRet 			:= {}
	local oAcl			:= cbcAcl():newcbcAcl()
	private lEnd        := .F.
	private lAbortPrint := .F.
	private CbTxt       := ""
	private limite      := 132
	private tamanho     := "M"
	private nomeprog    := "ZPRTORC"
	private nTipo       := 15
	private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	private nLastKey    := 0
	private cbtxt       := Space(10)
	private cbcont      := 00
	private CONTFL      := 01
	private m_pag       := 01
	private lImpCb      := .F.
	private cString     := "SCJ"
	private oOrc		:= nil
	private cFato		:= ""
	default cFact		:= 'portal'
	
	if !oAcl:aclValid('RelOrcPort')
		Alert(oAcl:getAlert())
	else
		oOrc 	:= cbcOrcControl():newcbcOrcControl(cFact)
		if oOrc:lPergOk
			oOrc:initModel()
			cFato 	:= oOrc:getFrom('fato')
			wnrel 	:= SetPrint(cString,NomeProg,oOrc:getPerg(),@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

			If nLastKey == 27
				Return
			Endif

			limite      := 220 
			tamanho     := "G" 
			aReturn[4]  := 2

			SetDefault(aReturn,cString)
			If nLastKey == 27
				Return
			Endif
			nTipo := If(aReturn[4]==1,15,18)
			RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
		endif
	endif
	freeObj(oAcl)
return( .T. )

////////////////////////////////////////////////////
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	////////////////////////////////////////////////////
	local	nTotPvc	:= 0
	local 	aDct	:= {}
	local	nH		:= 0
	local	nI		:= 0
	local 	oItm	:= nil
	local   oDct	:= nil
	local cStatus	:= ''
	local oSql 		:= nil
	Private _nLi 	:= 80
	
	Private _cProduto 	:= Space(15)
	Private _nTotMt 	:= 0
	Private _nValTot  	:= 0
	Private _nValTab  	:= 0
	private lQtd		:= (MV_PAR09 == 2)

	m_pag    := 01
	_nLi     := 80
	_nTotMt  := 0
	_nValTot := 0
	_nValTab := 0

	//Iniciar barra progresso
	SetRegua( oOrc:getHdrCount() )

	//Obter os documentos definidos no parametro
	aDct := oOrc:getDocument()

	//Primeiro loop nos documentos
	for nH := 1 to len( aDct )

		//Objeto que representa o orçamento
		oDct := aDct[nH]

		IncRegua()

		if lAbortPrint
			@ _nLi,00 PSay "*** CANCELADO PELO OPERADOR ***"
			exit
		endif

		// Somente custo do Cobre + PVC
		_nIndCsMp := 0.00 
		_nTotMet := 0
		_nTotVen := 0.00
		_nTotCus := 0.00
		_nTotPes := 0.00
		_nTotCom := 0.00
		nTotPvc  := 0.00
		_nValTot  := 0
		_nValTab  := 0
		_nPesoTot := 0
		_nVal2_5  := 0
		_nQtd2_5  := 0
		_nTotPV   := 0
		_nComis   := 0

		oSql 	  := LibSqlObj():newLibSqlObj()
		if !empty(cStatus	:= oDct:getHdr('STATUS_ORC'))
			cStatus := oSql:getFieldValue('SX5', 'X5_DESCRI', "%SX5.XFILIAL%  AND X5_TABELA = '_0'  AND X5_CHAVE ='" + cStatus + "'")
		endif
		if !empty(cStatus)
			cStatus := Alltrim(cStatus)
		endif
		FreeObj(oSql)

		//Obter o cabeçalho
		If _nLi > 60
			Titulo := if(oDct:getHdr('TIPO_VENDA') $ 'V//S' ,'[VAREJO] - ','' )+ ;
			if(cFato == 'portal','[PORTAL] - ','') + "O R Ç A M E N T O  -  N. " + oDct:getHdr('NUM') +;
			If(empty(cStatus),""," [" + cStatus + "] ") +;
			If(oDct:getHdr('COD_COND_PGTO') == "000","  - B N D E S","") 

			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			_nLi := 7
			ImprCabec(oDct)
		Endif

		//Loop nos itens, ocorre para cada SCJ
		for nI := 1 to Len( aDct[nH]:aItem )
			//Objeto que representa cada item do documento
			oItm := aDct[nH]:aItem[nI]

			If !Empty(_cProduto) .And. Left(_cProduto,5) # Left(oDct:getCmp(nI, "COD_PRODUTO"),5)
				If !lImpCb
					@ _nLi,000 PSay Replicate("-",limite)
					_nLi++
				EndIf
				_cProduto := oDct:getCmp(nI, "COD_PRODUTO")
			Else
				_cProduto := oDct:getCmp(nI, "COD_PRODUTO")
			EndIf

			If lImpCb
				lImpCb := .F.
			EndIf

			@ _nLi,000 PSay oDct:getCmp(nI, "COD_PRODUTO") 		Picture "@R XXX.XX.XX.X.XX"
			@ _nLi,015 PSay Left(u_CortaDesc( oDct:getCmp(nI, "DESCRICAO")  ),42)
			@ _nLi,058 PSay oDct:getCmp(nI, "QTDVEN")  		Picture "@E 9,999,999"
			@ _nLi,068 PSay oDct:getCmp(nI, "PRCVEN")  		Picture "@E 9999.9999"

			_nLUCROBR 	:= oDct:getCmp(nI, "TOTAL_RG_ITEM")
			_nIndice 	:= oDct:getCmp(nI, "INDICE_ITEM") 
			_nVaric  	:= oDct:getCmp(nI, "VARIACAO_ITEM")
			_nIndice 	:= oDct:getPercIndice(nI)

			//Relatorio realiza atualização na tabela
			/*
			If SCK->CK_INDICE # _nIndice
			RecLock("SCK",.F.)
			SCK->CK_INDICE := _nIndice
			MsUnLock()
			EndIf
			*/

			_cAcondic := Transform(oDct:getCmp(nI, "LANCES"),"@E 9,999") + " x " +oDct:getCmp(nI, "ACONDIC")+;
			StrZero(oDct:getCmp(nI, "METRAGE"),5)
			
			@ _nLi,078 PSay _nLUCROBR	Picture "@E 9999.99"
			@ _nLi,086 PSay oDct:getCmp(nI, "VALOR")  Picture  PesqPict("SC5","C5_TOTAL")
			@ _nLi,099 PSay _cAcondic
			
			
			@ _nli,114 PSay oDct:getCmp(nI, "COMIS1") Picture "@E 999.99"
			@ _nLi,121 PSay oDct:getCmp(nI, "TES")

			_nPrcUnit  := oDct:getCmp(nI, "PRC_TAB_BRUTO")

			If _nPrcUnit == 0
				@ _nLi,126 PSay "??.??"
			Else
				_cDescVis := oDct:descVista()
				_cDescs := oDct:getCmp(nI, "DESCONTOS")

				@ _nLi,125 PSay _cDescs
			EndIf

			@ _nLi,155 PSay If(oDct:getCmp(nI, "PRCVEN") < u_DescCasc(_nPrcUnit,StrTokArr( AllTrim(oDct:getHdr('FAIXA_DESC')) ,"+", .F. ),TamSX3("CK_PRCVEN" )[2]),;
			"Desc.Maior","")

			@ _nLi,169 PSay _nVaric  Picture "@E 9999.99"

			_nLi++

			If _nLi > 60
				Titulo := "O R Ç A M E N T O  -  N. " + oDct:getHdr('NUM') +;
				IIf(oDct:getHdr('COD_COND_PGTO') == "000","  - B N D E S","") 
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				_nLi := 7
				ImprCabec(oDct)
			Endif
			//Finaliza a porra dos itens
		next nI
		/* Obtenção dos totalizadores*/
		_nIndCsMp += oDct:sumCmp('INDICE_ITEM')	
		_nTotCus  := oDct:totalCusto()
		nTotPvc  := oDct:totPvc() 
		_nTotVen  := oDct:totVend() 
		_nTotCom  := oDct:totComiss()
		_nTotPes  := oDct:pesocobre()
		_nTotMet  := oDct:sumCmp('QTDVEN')
		_nPesoTot := oDct:pesoTotal()
		_nVal2_5  := oDct:tot2_5()
		_nQtd2_5  := oDct:qtd2_5()
		_nValTot  := oDct:sumCmp('VALOR')
		_nValTab  := oDct:getValTab()

		_cProduto := Space(15)

		@ _nLi,000 PSay Replicate("-",limite)
		_nLi++    

		_nIndice := Round(((_nIndCsMp / _nValTot) * 100),2)

		/* Alterar a tabela em relatorio é porco.
		If SCJ->CJ_INDICE # _nIndice
		RecLock("SCJ",.F.)
		SCJ->CJ_INDICE := _nIndice
		MsUnLock()
		EndIf
		*/

		_nVaric  := Round(((_nIndCsMp / 75) * 100),2)
		If _nVaric > _nValTot
			_nVaric  := (_nVaric - _nValTot)
			_nVaric  := Round(((_nVaric / _nValTot) * 100),2)
		Else
			_nVaric  := 0.00
		EndIf

		@ _nLi,000 PSay "Fios/Flex 2,5: "
		if !lQtd
			@ _nLi,015 PSay Round((_nVal2_5/_nValTot) * 100,2) Picture "@E 999.99"
		else
			@ _nLi,015 PSay Round((_nQtd2_5/_nTotMet) * 100,2) Picture "@E 999.99"		
		endif
		@ _nLi,021 PSay "%"
		@ _nLi,026 PSay "Peso Total(PVC+Cob):"
		@ _nLi,047 PSay Transform(Int(_nPesoTot),"@E 999,999") + " kg"
		@ _nLi,072 PSay "Valor Total"	
		@ _nLi,085 PSay _nValTot  		Picture PesqPict("SC5","C5_TOTAL")
		@ _nLi,100 PSay "Desc.Medio:"
		@ _nLi,114 PSay Round((((_nValTab - _nValTot) / _nValTab) * 100),2) Picture "@E 999.99"

		_nLi++
		_nKgKm := oDct:getKmTotal()

		_nLi++
		@ _nLi,00 PSay "Cadastro Original: "+ SubStr(oDct:getHdr('USR_INCLUSAO'),1,10)
		@ _nLi,35 PSay "Cadastro Alterado: "+ SubStr(oDct:getHdr('USR_ALTERACAO'),1,10)

		_nLUCROBR := oDct:getRgTotal()

		@ _nLi,76 PSay "  RG:  "+Transform(_nLUCROBR,"@E 9999.99")

		_nFator :=  oDct:getIMP()
		@ _nLi,095 PSay "IMP: " + Transform(_nFator,"@E 999.99") 

		_nPerCom := oDct:getMedComis()
		@ _nLi,113 PSay "%Med.Com: " + Transform(_nPerCom,"@E 999.99") 

		@ _nLi,140 PSay "Fator: " + Transform(oDct:getPesFator(),"@E 999.99")

		_nLi++

		@ _nLi,00 PSay oDct:getHdr('DATA_INCLUSAO') 
		@ _nLi,35 PSay oDct:getHdr('DATA_ALTERACAO')
		_nLi+=2
		@ _nLi,00 PSay "Conferido: __________________________________"
		@ _nLi,50 PSay "Data: ______/______/________"
		_nLi+=60

		//Final dos documentos
	next nHdr

	Set Device To Screen
	If aReturn[5]==1
		DbCommitAll()
		Set Printer To
		OurSpool(wnrel)
	Endif
	MS_FLUSH()
Return( .T. )

Static Function ImprCabec(oDct)

	@ _nLi,00 PSay "DATA DO ORÇAMENTO: " + oDct:getHdr('EMISSAO')
	@ _nLi,70 PSay "CIDADE: "+ Left( oDct:getHdr('MUNICIPIO'),25)
	@ _nLi,105 PSay "UF: "+ oDct:getHdr('ESTADO')
	@ _nLi,150 PSay "***********************   A T E N Ç Ã O   ************************"

	_nLi++
	@ _nLi,00 PSay "CLIENTE: "+ oDct:getHdr('CLIENTE') +"/"+oDct:getHdr('CLI_LOJA')+;
	" - " + oDct:getHdr('NOME_CLIENTE') 

	@ _nLi,105 PSay "TP.CLI.: " + oDct:getTpCliente()
	@ _nLi,150 PSay "*   1) DESCONTO PADRÃO = " +  oDct:getHdr('FAIXA_DESC')
	@ _nLi,215 PSay "*"

	_nLi++

	@ _nLi,00 PSay "CNPJ/CPF: "+If(Len(AllTrim( oDct:getHdr('CGC')))==11,;
	Transform(oDct:getHdr('CGC'),"@R 999.999.999-99"),;
	Transform(oDct:getHdr('CGC'),"@R 99.999.999/9999-99"))

	@ _nLi,70 PSay "FONE: "+ oDct:getHdr('TELEFONE')	
	@ _nLi,105 PSay "Tabela : "+ oDct:getHdr('TABELA_PRECO')

	@ _nLi,150 PSay "*   2) MEDIA MINIMA TARGET = 40"
	@ _nLi,215 PSay "*"

	_nLi++                    

	@ _nLi,00 PSay "VENDEDOR: "+ oDct:getHdr('COD_VEND') +" - "+ oDct:getHdr('NOME_VEND') 
	@ _nLi,150 PSay "*   3) FIOS/FLEX 2,5 NÃO PODE PASSAR DE 30% DO PEDIDO            *"

	_nLi++

	@ _nLi,00 PSay "DATA DE ENTREGA: "+ oDct:getHdr('DATA_ENTREGA') 
	@ _nLi,70 PSay "Ordem Compra:"
	@ _nLi,84 PSay  oDct:getHdr('PEDIDO_CLIENTE')
	@ _nLi,105 PSay "Loc.Entrega: " + oDct:getEndEntr()
	@ _nLi,150 PSay "******************************************************************"
	_nLi++

	@ _nLi,00 PSay "COND. DE PGTO.: "+ AllTrim( oDct:getHdr('COD_COND_PGTO') ) +;
	"  -  " + oDct:getHdr('COND_PAGTO')

	@ _nLi,70 PSay "PRZ. MEDIO:"
	@ _nLi,83 PSay Int(Val( oDct:getHdr('MED_COND_PAGTO') )) Picture "@E 999"
	_nLi++

	@ _nLi,00 PSay "OBSERVACOES: "+ oDct:getHdr('OBSERVACAO')
	_nLi++

	@ _nLi,00 PSay "TRANSP.: " + oDct:getHdr('COD_TRANSP') + " " + oDct:getHdr('TRANSPORTADORA')

	@ _nLi,70 PSay "TIPO FRETE : " + oDct:getTpFrete()
	_nLi++

	@ _nLi,00 PSay Replicate("-",limite)
	_nLi++

	@ _nLi,00 PSay "Produto        Descricao                                    Qtd.(m) Vr. Unit.     RG       Total       Lances      %Com. TES   Desc.Aplicado                      Indice  Variac."        
	_nLi++

	@ _nLi,00 PSay Replicate("-",limite)
	_nLi++
	lImpCb := .T.

Return( .T. )

/////////////////////////
Static Function ValidPerg 
	/////////////////////////

	Private cPerg       := "CDFT17"

	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	aAdd(aRegs,{cPerg,"01","Do Orçamento                 ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até o Orçamento              ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Da Data de Emissão           ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Até a Data de Emissão        ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Do Cliente                   ?","mv_ch5","C",06,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"06","Da Loja                      ?","mv_ch6","C",02,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Até o Cliente                ?","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","SA1"})
	aAdd(aRegs,{cPerg,"08","Até a Loja                   ?","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","% Felx 2.5             		 ?","mv_ch9","N",01,0,0,"C","","mv_par09","Valor","","","Quantidade","","","","","","","","","","",""})
	
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

Return( .T. )
