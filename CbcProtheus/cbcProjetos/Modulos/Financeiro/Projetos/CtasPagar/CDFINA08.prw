#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
#include "tbiconn.ch"
#include "Directry.ch"

/*/{Protheus.doc} CDFINA08
@author legado
@since 21/07/2017
@version 0.0
@type function
@description Rotina cria registros de pagamento de cada funcionario         
através de um arquivo de texto que contem dados e insere       
na tabela SZT, cria um unico registro com o valor total        
na tabela SE2, com a opção de pagfor, a rotina gera um         
arquivo de texto (.CPE) que será enviado ao banco bradesco   
/*/
User Function CDFINA08()
	local  oAcl as object
	oAcl	:= cbcAcl():newcbcAcl()
	if !oAcl:aclValid('ViewPgInfo')
		MsgInf(oAcl:getAlert(), 'Validação de Acesso')
	else
		aRotina := {{ "Pesquisar"    , "AxPesqui"     , 0 , 1	},;
					{ "Visualizar"   , "AxVisual"     , 0 , 3	},;
					{ "Incluir"      , "AxInclui"     , 0 , 3	},;
					{ "Alterar"      , "AxAltera"     , 0 , 4	},;
					{ "Excluir"      , "AxDeleta"     , 0 , 5	},;
					{ "Gerar Folha"  , "u_GeraSZT()"  , 0 , 3	},;
					{ "Gerar Pagfor" , "u_GeraArq()"  , 0 , 3   }}
		cCadastro := "Folha de Pagamentos Financeira"
		DbSelectArea("SZT")
		DbSetOrder(1) //ZT_FILIAL+ZT_MAT
		DbSeek(xFilial("SZT"),.F.)
		mBrowse(001,040,200,390,"SZT",,,,,,)
	endif
	FreeObj(oAcl)
Return(.T.)

User Function GeraSZT()
	local bErro	:= nil
	Private cPerg     := "CDFINA08"
	ValidPerg("1")
	Do While .T.
		If !Pergunte(cPerg,.T.)
			Exit
		EndIf
		If Empty(MV_PAR01) .Or. Empty(MV_PAR02) .Or. Empty(MV_PAR04) .Or. Empty(MV_PAR05) .Or.Empty(MV_PAR06)  .Or. ;
		Empty(MV_PAR07) .Or. MV_PAR08 < 1    .Or. MV_PAR08 > 12   .Or. MV_PAR09 < 2010 .Or. Empty(MV_PAR10) .Or. ;
		Empty(MV_PAR11) .Or. Empty(MV_PAR12) .Or. Empty(MV_PAR13)
			Alert("Todos dados do Titulo devem ser Informados")
			Loop
		EndIf

		DbSelectArea("SED")
		DbSetOrder(1) // ED_FILIAL+ED_CODIGO
		If !DbSeek(xFilial("SED") + MV_PAR05,.F.)
			Alert("Natureza Inválida")
			Loop
		EndIf

		DbSelectArea("SZT")
		DbSetOrder(3) // ZT_FILIAL+ZT_ANOCOMP+ZT_MESCOMP+ZT_TIPOPAG+ZT_FORMA
		If DbSeek(xFilial("SZT")+StrZero(MV_PAR09,4)+StrZero(MV_PAR08,2)+Str(MV_PAR10,1)+Str(MV_PAR11,1),.F.)
			Alert("Dados dessa folha já incluídos")
			Loop
		EndIf

		DbSelectArea("SA2")
		DbSetOrder(1)
		If !DbSeek(xFilial("SA2")+MV_PAR12+MV_PAR13,.F.)
			Alert("Aviso, Código do Fornecedor não cadastrado")
			Loop
		Endif

		DbSelectArea("SE2")
		DbSetOrder(1) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
		If DbSeek(xFilial("SE2") + MV_PAR01 + MV_PAR02 + MV_PAR03 + MV_PAR04 + MV_PAR12+MV_PAR13/*"V0071F01"*/,.F.)
			Alert("Aviso, Titulo Financeiro ja esta cadastrado, não é possivel continuar a operação")
			Loop
		Endif
		
		bErro	:= ErrorBlock({|oErr| HandleEr(oErr)})
		BEGIN SEQUENCE
			BEGIN TRANSACTION
				FWMsgRun(, { |oSay| lRet := FuncPerg()}, "Valores Folha Funcionario", "Processando a rotina... Aguarde ... ")
			END TRANSACTION
			RECOVER
		END SEQUENCE
		ErrorBlock(bErro)		
		Exit
		if ! lRet
			Exit
		endif
	EndDo
Return(.t.)

User Function GeraArq()
	cPerg       := "CDFINA08_2"
	ValidPerg("2")

	Do While .T.
		If !Pergunte(cPerg,.T.)
			Exit
		EndIf
		If MV_PAR01 < 1 .Or. MV_PAR01 > 12 .Or. MV_PAR02 < 2010 .Or. Empty(MV_PAR03)
			Alert("Todos dados do Titulo devem ser Informados")
			Loop
		EndIf
		DbSelectArea("SZT")
		DbSetOrder(3) // ZT_FILIAL+ZT_ANOCOMP+ZT_MESCOMP+ZT_TIPOPAG+ZT_FORMA
		If !DbSeek(xFilial("SZT")+StrZero(MV_PAR02,4)+StrZero(MV_PAR01,2)+Str(MV_PAR03,1)+"1",.F.) //  Só pode ser de Pagamento por ITU
			Alert("Dados dessa folha não incluídos")
			Loop
		ElseIf SZT->ZT_OK == "1"
			If !MsgBox("Já foi criado PagFor para estes registros, deseja reprocessar ?","Confirma?","YesNo")
				Loop
			EndIf
		EndIf
		FWMsgRun(, { |oSay| FuncPagto() }, "Valores Folha Funcionario", "Processando a rotina... Aguarde ... ")
		Exit
	EndDo
Return(.t.)

Static Function FuncPerg()
	local oExec 	:= nil 
	local aRet		:= {}
	local aParamBox := {}
	local aRet1    	:= {}
	If !MsgBox("Confirma a configuração dos parâmetros?","Confirma?","YesNo")
		Return(.T.)
	EndIf
	//Variaveis dos parametros
	Private cPrefixo    := mv_par01
	Private cNum        := mv_par02
	Private cParcela    := mv_par03
	Private cTipo       := mv_par04
	Private cNatureza   := mv_par05
	Private dDataPagto  := mv_par06
	Private cArqTxt1    := mv_par07
	Private cMesComp    := StrZero(mv_par08,2)
	Private cAnoComp    := Str(mv_par09,4)
	Private cTipoPag    := Str(mv_par10,1)
	Private cForma      := Str(mv_par11,1)
	Private cFornece    := mv_par12
	Private cLoja       := MV_PAR13
	Private nTotal      := 0.00
	Private nTotal2     := 0.00
	Private nTotal3     := 0.00
	Private nTamParc    := TamSX3("E2_PARCELA")[1]
	Private cHistor     := ""
	private oDadSRA		:= LibSqlObj():newLibSqlObj()

	DbSelectArea("SZT")
	DbSetOrder(1) //ZT_FILIAL+ZT_MAT
	
	RetDadSRA()
	//RetDa1SRA() Folha aberta
	if oDadSRA == nil
		Alert("Erro ao carregar dados do funcionario, Folha ainda não liberada. Entrar em contato com o RH!")
		FreeObj(oDadSRA)
		return(.F.)
	endif	
	aAdd(aParamBox,{1,'Confirme a Data do Pagamento: '	,dDataPagto,PesqPict('SZT','ZT_DTPAG'),"","",".T.",50,.T.})
	if ParamBox(aParamBox,"Data do Pagamento",@aRet1)
		dDataPagto := aRet1[1]
	endif
	oDadSRA:goTop()
	FWMsgRun(, { |oSay| }, "Valores Folha Funcionario", "Processando a rotina... Aguarde ... ")
	do while oDadSRA:notIsEof()
		nValor := 0
		if cForma=="1"
			nValor := oDadSRA:getValue("VALOR")
			if !empty(oDadSRA:getValue("CTADIG"))
				nTotal   := nTotal + nValor
				cParcP   := "1"+Space(nTamParc-1) //Alterado por Juliana, para acerto de inconsistencia na geração do PagFor 02/01/2015
			else
				nTotal2  := nTotal2 + nValor
				cParcP   := ";"+Space(nTamParc-1)
				cHistor  += Left(Alltrim(oDadSRA:getValue("NOME")),7)+"- "
			endif
		else
			nTotal3 := nTotal3 + nValor
			cParcP := "/"+Space(nTamParc-1)
		endif
		RecLock("SZT",.T.)
		SZT->ZT_FILIAL	:= FwFilial()
		SZT->ZT_PREFIXO	:= cPrefixo
		SZT->ZT_NUMSE2	:= cNum
		SZT->ZT_PARCELA	:= cParcP
		SZT->ZT_TIPO	:= cTipo
		SZT->ZT_DTPAG	:= dDataPagto
		SZT->ZT_MAT		:= oDadSRA:getValue("MATRIC")
		SZT->ZT_NOME	:= oDadSRA:getValue("NOME")
		SZT->ZT_VALOR	:= nValor
		SZT->ZT_ANOCOMP	:= cAnoComp
		SZT->ZT_MESCOMP	:= cMesComp
		SZT->ZT_TIPOPAG	:= cTipoPag
		SZT->ZT_FORMA	:= cForma
		SZT->ZT_CPF		:= oDadSRA:getValue("CPF")
		SZT->ZT_BCDEPSA	:= oDadSRA:getValue("BCDEPSA")
		SZT->ZT_CTDEPSA	:= oDadSRA:getValue("CTDEPSA")
		SZT->ZT_CTADIG	:= oDadSRA:getValue("CTADIG")
		SZT->ZT_TPCONTA	:= oDadSRA:getValue("TPCONTA")
		SZT->ZT_OK		:= "0"
		MsUnLock()
		oDadSRA:skip()
	enddo
	oDadSRA:close()
	FreeObj(oDadSRA)

	DbSelectArea("SE2")
	If nTotal+nTotal2+nTotal3 > 0
		For _nVez := 1 To 3
			If _nVez == 1
				_nValE1 := nTotal
				cParcP := "."+Space(nTamParc-1)
			ElseIf _nVez == 2
				_nValE1 := nTotal2
				cParcP := ";"+Space(nTamParc-1)
			Else
				_nValE1 := nTotal3
				cParcP := "/"+Space(nTamParc-1)
			EndIf

			If _nValE1 <= 0
				Loop
			EndIf

			DbSelectArea("SE2")
			DbSetOrder(1) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
			DbSeek(xFilial("SE2") + cPrefixo + cNum + cParcela + cTipo + cFornece+cLoja/*"V0071F01"*/,.F.)
			Do While xFilial("SE2") + cPrefixo + cNum + cParcela + cTipo + cFornece+cLoja/*"V0071F01"*/==;
			SE2->(E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)
				cParcela := Soma1(cParcela)
			EndDo
			aTitulo  := {{"E2_PREFIXO"	, cPrefixo 				   						,	Nil},;
			{"E2_NUM"			, cNum			  					   					,	Nil},;
			{"E2_PARCELA"		, cParcela							   					,	Nil},;
			{"E2_TIPO"			, cTipo					    	        				,	Nil},;
			{"E2_NATUREZ"		, cNatureza												,	Nil},;
			{"E2_FORNECE"		, cFornece  											,	Nil},;
			{"E2_LOJA"			, cLoja						      						,	Nil},;
			{"E2_NOMFOR"		, "FOLHA ADIANTAMENTO"	    							,	Nil},;
			{"E2_EMISSAO"		, dDataBase					        	  				,	Nil},;
			{"E2_VENCTO"		, dDataPagto							 				,	Nil},;
			{"E2_VENCREA"		, DataValida(dDataPagto)					 			,	Nil},;
			{"E2_MOEDA"			, 1											 			,	Nil},;
			{"E2_CLVLDB"		, cNatureza												,	Nil},;
			{"E2_CONVERT"		, 'N'										  			,	Nil},;
			{"E2_HIST"			, Iif(_nVez<>2,"PAGAMENTO FUNCIONARIOS","Pgto:"+cHistor),	Nil},;
			{"E2_UNPAG"			, If(_nVez==2,"1",cForma)								,	Nil},;
			{"E2_FORMA"			, If(_nVez==1,If(cForma=="1","1","2"),"2")				,	Nil},;
			{"E2_VLCRUZ"		, Abs(_nValE1)           								,	Nil},;
			{"E2_VALOR"			, Abs(_nValE1)	           								,	Nil}}

			oExec := cbcExecAuto():newcbcExecAuto(aTitulo,,.F.)
			oExec:setFilial(FwFilial())
			oExec:exAuto('FINA050',3)
			aRet := oExec:getRet()
			if !aRet[1]
				help(,,'Pagamentos',,aRet[2],1,0,,,,,,{'Nenhum dado sera salvo,procurar Administrador do sistema!'})
				UserException(aRet[2])
			Else
				DbSelectArea("SZT")
				DbSetOrder(2)//ZT_FILIAL+ZT_PREFIXO+ZT_NUMSE2+ZT_PARCELA+ZT_TIPO
				Do While DbSeek(xFilial("SZT")+SE2->E2_PREFIXO+SE2->E2_NUM+cParcP+SE2->E2_TIPO,.F.)
					RecLock("SZT",.F.)
					SZT->ZT_PARCELA := SE2->E2_PARCELA
					MsUnLock()
				EndDo
				MsgInfo("Titulo a Pagar Nro:" +SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+ " gerado com Sucesso!!!")
				MsgInfo("Valor total gerado: R$ " + transform(_nValE1,"@E 999.999.999,99") + " Favor conferir com a folha.") 
			EndIf
			FreeObj(oExec)
		Next
	EndIf
Return(.T.)

Static Function FuncPagto

	/*funcao para criacao do layout (txt) para pagamento*/
	cNumRemessa := "00000"
	cNumSeq     := "000001" // Para desconsiderar registro Header
	nTotValor   := 0

	//Variaveis dos parametros
	cMesComp   := StrZero(mv_par01,2)
	cAnoComp   := Str(mv_par02,4)
	cTipoPag   := Alltrim(Str(mv_par03))

	DbSelectArea("SEE")
	DbSetOrder(1) // FILIAL + BANCO + AGENCIA + CONTA
	If SEE->(DbSeek(xFilial("SEE") + "237" + "0328 " + "59808-9   " + "001" , .F.))
		cNumRemessa := CnabRH("1")
	EndIf

	_cArqTxt2 := cGetFile("Arquivos Texto de Importacao | *.TXT ",OemToAnsi("Salvar Arquivo Como..."),0,"C:\",.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE)
	nHdl2 	 := fCreate(_cArqTxt2)
	If nHdl2 == -1
		MsgAlert("O arquivo de nome " + _cArqTxt2 + " nao pode ser executado! Verifique os parametros.","Atencao!")
		Return(.T.)
	Endif

	DbSelectArea("SE2")
	DbSetOrder(1) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
	DbSeek(xFilial("SE2") + SZT->ZT_PREFIXO + SZT->ZT_NUMSE2 + SZT->ZT_PARCELA + SZT->ZT_TIPO +mv_par04+mv_par05,.F.)// +"V0071F01",.F.)

	If SZT->ZT_FORMA == "1" .AND. Empty(SE2->E2_IDCNAB)
		//³Tratativa para pegar o codigo IDCNAB ³
		DbSelectArea("SE2")
		aAreaSE2 := SE2->(GetArea())
		// Gera identificador do registro CNAB no titulo enviado
		cIdCnab := GetSxENum("SE2", "E2_IDCNAB", "E2_IDCNAB"+cEmpAnt,13)
		ConfirmSX8()
		SE2->(DbSetOrder(13)) // IDCNAB
		Do While SE2->(DbSeek(cIdCnab,.F.))
			cIdCnab := GetSxENum("SE2", "E2_IDCNAB","E2_IDCNAB"+cEmpAnt,13)
			ConfirmSX8()
			SE2->(DbSetOrder(13)) // IDCNAB
		EndDo
		SE2->(RestArea(aAreaSE2))
		RecLock("SE2",.F.)
		SE2->E2_IDCNAB := cIdCnab
		MsUnlock()
	EndIf

	//Header
	cBanco := ""
	cBanco := "0000229642002544042000119I.F.C.IND.COM.CONDUTORES ELETRICOS LTDA.201"+cNumRemessa+;
	"00000"+DtoS(Date())+Substr(Time(),1,2)+Substr(Time(),4,2)+Substr(Time(),7,2);
	+Space(13)+"0"+Space(388)+"000001"+Chr(13)+Chr(10)
	fWrite(nHdl2,cBanco,Len(cBanco))

	DbSelectArea("SZT")
	Do While SZT->(!Eof()) .And. SZT->ZT_FILIAL == xFilial("SZT") .And. ;
	SZT->ZT_ANOCOMP + SZT->ZT_MESCOMP + SZT->ZT_TIPOPAG + SZT->ZT_FORMA == ;
	cAnoComp + cMesComp + cTipoPag + "1"
		// Desconsidero pagamentos Extra Oficiais
		If SZT->ZT_FORMA == "2"
			DbSelectArea("SZT")
			DbSkip()
			Loop
		EndIf
		//Desconsidero caso não possua o titulo
		DbSelectArea("SE2")
		If !DbSeek(xFilial("SE2") + SZT->ZT_PREFIXO + SZT->ZT_NUMSE2 + SZT->ZT_PARCELA + SZT->ZT_TIPO + mv_par04 + mv_par05/*+ "V0071F01"*/,.F.)
			DbSelectArea("SZT")
			DbSkip()
			Loop
		EndIf

		/* Registro Detalhe */
		cNumPag := CnabRH("2") //Numeração automatica, atualiza campo( SEE->EE_FAXATU )
		cCpf    := Left(Alltrim(SZT->ZT_CPF),9) + "0000" +  Right(Alltrim(SZT->ZT_CPF),2)   // POSICAO 003 - 017
		cNome   := Left(SZT->ZT_NOME,30)													// POSICAO 018 - 047
		cBanco  := Left(SZT->ZT_BCDEPSA,3)                                                  // POSICAO 096 - 098
		cAgenc  := "0"+Substr(SZT->ZT_BCDEPSA,4,4)           								// POSICAO 099 - 103
		cDigAg	:= Right(SZT->ZT_BCDEPSA,1)                                                 // POSICAO 104 - 104
		cConta  := Strzero(Val(StrTran(StrTran(StrTran(SZT->ZT_CTDEPSA,".",""),"-","")," ","")),13)// POSICAO 105 - 117
		cDigCC  := SZT->ZT_CTADIG		                               						// POSICAO 118 - 119
		cDtPag  := Dtos(SZT->ZT_DTPAG)							 							// POSICAO 166 - 173
		cValor  := StrTran(STRZERO(SZT->ZT_VALOR,16,2),".","")     					        // POSICAO 205 - 219
		cIdCnab := Right(Alltrim(SE2->E2_IDCNAB),10)        						    	// POSICAO 416 - 425
		cNumSeq := Soma1(cNumSeq)															// POSICAO 495 - 500

		// Caso seja DOC ou TED, faco tratamento para as posicoes 374 a 382 do PAGFOR
		If cBanco == "237" //Bradesco
			cCompl1 := "01"
			cCompl2 := Space(9)
			cCompl3 := "  "
			cCompl4 := Iif(SZT->ZT_TPCONTA == "1" , "1" , "2")// 1 = C.Corrente  2 = C. Poupança
		ElseIf SZT->ZT_VALOR >= 5000  // TED
			cCompl1 := "03"
			cCompl2 := "D00000001"
			cCompl3 := Iif(SZT->ZT_TPCONTA == "1" , "01" , "02")// 1 = C.Corrente  2 = C. Poupança
			cCompl4 := " "
		Else
			cCompl1 := "03"
			cCompl2 := "C00000001"
			cCompl3 := Iif(SZT->ZT_TPCONTA == "1" , "01" , "02")// 1 = C.Corrente  2 = C. Poupança
			cCompl4 := " "
		Endif

		/* Registro Trailer */
		nTotValor += SZT->ZT_VALOR

		cBanco := "11"+cCpf+cNome+Space(40)+"00000000"+cBanco+cAgenc+cDigAg+cConta+cDigCC+cNumPag+;
		Replicate("0",15)+Space(15)+cDtPag+Replicate("0",31)+cValor+Replicate("0",30)+;
		"01"+Replicate("0",10)+"  "+cCompl1+cDtPag+"   01          000"+Space(82)+cCompl2+cCompl3+;
		Space(31)+cIdCnab+SPACE(47)+"00000 "+cCompl4+"0059808        "+cNumSeq+Chr(13)+Chr(10)

		fWrite(nHdl2,cBanco,Len(cBanco))

		DbSelectArea("SZT")
		RecLock( "SZT" , .F.)
		SZT->ZT_OK := "1"
		MsUnlock()
		DbSkip()
	EndDo

	cNumSeq := Soma1(cNumSeq)											// POSICAO 495 - 500-TRAILER
	cTotValor := StrTran(StrZero(nTotValor,18,2),".","")

	//Trailer
	cBanco := "9"+cNumSeq+cTotValor+SPACE(470)+cNumSeq+Chr(13)+Chr(10)
	fWrite(nHdl2,cBanco,Len(cBanco))

	fClose(nHdl2)//Fecha o Arquivo
Return(.T.)

Static Function CnabRH(_cOpcao)
	Local _aArea    := GetArea()
	Local RET       := ""

	// Rotina que acrescenta um numero sequencial na posição 120 a 135 BRADESCO PAGFOR e BRADESCO FOLHA
	DbSelectArea("SEE")
	SEE->(DbSetOrder(1)) // FILIAL + BANCO + AGENCIA + CONTA
	// BRADESCO FOLHA ( nao existem parametros do sistema, por isto deixo fixo o banco correto)
	If SEE->(DbSeek(xFilial("SEE") + "237" + "0328 " + "59808-9   " + "001" , .F.))
		RecLock( "SEE" , .F.)

		If _cOpcao == "1"
			SEE->EE_ULTDSK := Soma1(SEE->EE_ULTDSK)	// Somo 1 no contador
			RET := Right(SEE->EE_ULTDSK,5)
		Else

			SEE->EE_FAXATU := Soma1(SEE->EE_FAXATU) 	// Somo 1 no contador
			RET := "CD" + STRZERO( VAL(SEE->EE_FAXATU), 14 )
		EndIf
		MsUnlock()
	EndIf
	RestArea(_aArea)
Return (RET)

Static Function ValidPerg(cOpcao)
	_aArea := GetArea()
	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	aRegs:={}

	//Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3
	If cOpcao == "1"
		aAdd(aRegs,{cPerg,"01","Prefixo Titulo  ?","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"02","Numero Titulo   ?","mv_ch2","C",09,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"03","Parcela         ?","mv_ch3","C",03,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"04","Tipo            ?","mv_ch4","C",03,0,0,"G","","mv_par04","","","","","","","","","","","","","","","05"})
		aAdd(aRegs,{cPerg,"05","Natureza        ?","mv_ch5","C",10,0,0,"G","","mv_par05","","","","","","","","","","","","","","","SED"})
		aAdd(aRegs,{cPerg,"06","Data Pagamento  ?","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"07","Arquivo a ser importado ?","mv_ch7","C",20,0,0,"G","","mv_par07","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"08","Mês Competencia ?","mv_ch8","N",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"09","Ano Competencia ?","mv_ch9","N",04,0,0,"G","","mv_par09","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"10","Tipo  Pagamento ?","mv_cha","N",01,0,0,"C","","mv_par10","Adiant. Mês","","","Folha Mês","","","Adiant. 13º","","","Pagto 13º Sal","","","PLR","",""})
		aAdd(aRegs,{cPerg,"11","Forma Pagamento ?","mv_chb","N",01,0,0,"C","","mv_par11","Banco","","","Caixa","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"12","Fornecedor      ?","mv_chc","C",06,0,0,"G","","mv_par12","","","","","","","","","","","","","","","SA2"})
		aAdd(aRegs,{cPerg,"13","Loja            ?","mv_chd","C",02,0,0,"G","","mv_par13","","","","","","","","","","","","","","",""})
	Else
		aAdd(aRegs,{cPerg,"01","Mês Competencia ?","mv_ch1","N",02,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"02","Ano Competencia ?","mv_ch2","N",04,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"03","Tipo Pagamento  ?","mv_ch3","N",01,0,0,"C","","mv_par03","Adiant. Mês","","","Folha Mês","","","Adiant. 13º","","","Pagto 13º Sal","","","Ferias/PLR","",""})
		aAdd(aRegs,{cPerg,"04","Fornecedor      ?","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","SA2"})
		aAdd(aRegs,{cPerg,"05","Loja            ?","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","",""})
	EndIf

	For i := 1 To Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2] , .F.)
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

Return(.T.)

static function HandleEr(oErr)
	DisarmTransaction()
	ConOut("[CDFINA08 - "+DtoC(Date())+" - "+Time()+" ] "+ '[ERRO]' + oErr:Description + ' [FROM] ' + ProcName(3) )
	BREAK
return (nil)

static function RetDadSRA()
	local cQry		:= ""
	local aTpPagto	:= ValidPgt()
	
	cQry := " SELECT "
	cQry += " 	SRA.RA_FILIAL	FILIAL, "
	cQry += " 	SRA.RA_MAT		MATRIC, "
	cQry += " 	SRA.RA_CIC		CPF, "
	cQry += " 	SRA.RA_NOME		NOME, "
	cQry += " 	SRA.RA_DEMISSA	DEMISSA, "
	cQry += " 	SRA.RA_CTDEPSA	CTDEPSA, "
	cQry += " 	SRA.RA_BCDEPSA	BCDEPSA, "
	cQry += " 	SRA.RA_CTADIG	CTADIG, "
	cQry += " 	SRA.RA_TPCONTA	TPCONTA, "
	cQry += " 	SRD.RD_VALOR	VALOR, "
	cQry += " 	SRD.RD_DATARQ	CDATA, "
	cQry += " 	SRD.RD_ROTEIR	ROTEIRO "
	cQry += " FROM %SRA.SQLNAME% WITH (NOLOCK)"
	cQry += " 	INNER JOIN %SRD.SQLNAME% WITH (NOLOCK) "
	cQry += " 		ON SRD.RD_FILIAL = SRA.RA_FILIAL "
	cQry += " 		AND SRD.RD_MAT = SRA.RA_MAT "
	cQry += " 		AND SRD.D_E_L_E_T_ = SRA.D_E_L_E_T_ "
	cQry += " WHERE %SRA.XFILIAL% "
	cQry += " 	AND SRD.RD_DATARQ = '" + StrZero(MV_PAR09,4) + StrZero(MV_PAR08,2) + "'"
	cQry += " 	AND SRD.RD_PD = '" + aTpPagto[2] + "' "
	cQry += " 	AND SRD.RD_ROTEIR = '" + aTpPagto[1] + "' "
	cQry += " 	AND SRA.RA_DEMISSA = '' "
	cQry += " 	AND SRD.RD_VALOR > 0 "
	cQry += " 	AND %SRA.NOTDEL% "
	if oDadSRA:setExternalConnection("MSSQL","IFC_P12_RH","192.168.3.9",7890)
		oDadSRA:newAlias(cQry)
		if !(oDadSRA:hasRecords())
			oDadSRA:close()
			oDadSRA:setErpConnection()
			FreeObj(oDadSRA)
			oDadSRA := nil
		endif
	else
		oDadSRA := nil
	endif
return()

static function ValidPgt()
	local aTpPagto := {}
	if cTipoPag == "1"
		aTpPagto:= {"ADI","164"}
	elseif cTipoPag == "2"
		aTpPagto:= {"FOL","999"}
	elseif cTipoPag == "3"
		aTpPagto:= {"131","163"}
	elseif cTipoPag == "4"
		aTpPagto:= {"132","995"}
	elseif cTipoPag == "5"
		aTpPagto:= {"PLR","166"}
	else
		aTpPagto:= {"",""}
	endif
return(aTpPagto)

static function RetDa1SRA()
	local cQry		:= ""
	local aTpPagto	:= ValidPgt()
	
	cQry := " SELECT "
	cQry += " 	SRA.RA_FILIAL	FILIAL, "
	cQry += " 	SRA.RA_MAT		MATRIC, "
	cQry += " 	SRA.RA_CIC		CPF, "
	cQry += " 	SRA.RA_NOME		NOME, "
	cQry += " 	SRA.RA_DEMISSA	DEMISSA, "
	cQry += " 	SRA.RA_CTDEPSA	CTDEPSA, "
	cQry += " 	SRA.RA_BCDEPSA	BCDEPSA, "
	cQry += " 	SRA.RA_CTADIG	CTADIG, "
	cQry += " 	SRA.RA_TPCONTA	TPCONTA, "
	cQry += " 	SRC.RC_VALOR	VALOR, "
	cQry += " 	SRC.RC_DATA		CDATA, "
	cQry += " 	SRC.RC_ROTEIR	ROTEIRO "
	cQry += " FROM %SRA.SQLNAME% WITH (NOLOCK)"
	cQry += " 	INNER JOIN %SRC.SQLNAME% WITH (NOLOCK) "
	cQry += " 		ON SRC.RC_FILIAL = SRA.RA_FILIAL "
	cQry += " 		AND SRC.RC_MAT = SRA.RA_MAT "
	cQry += " 		AND SRC.D_E_L_E_T_ = SRA.D_E_L_E_T_ "
	cQry += " WHERE %SRA.XFILIAL% "
	cQry += " 	AND SRC.RC_DATA = '" + DtoS(mv_par06) +  "'"
	cQry += " 	AND SRC.RC_PD = '" + aTpPagto[2] + "' "
	cQry += " 	AND SRC.RC_ROTEIR = '" + aTpPagto[1] + "' "
	cQry += " 	AND SRA.RA_DEMISSA = '' "
	cQry += " 	AND SRC.RC_VALOR > 0 "
	cQry += " 	AND %SRA.NOTDEL% "
	if oDadSRA:setExternalConnection("MSSQL","IFC_P12_RH","192.168.3.9",7890)
		oDadSRA:newAlias(cQry)
		if !(oDadSRA:hasRecords())
			oDadSRA:close()
			oDadSRA:setErpConnection()
			FreeObj(oDadSRA)
			oDadSRA := nil
		endif
	else
		oDadSRA := nil
	endif
return()