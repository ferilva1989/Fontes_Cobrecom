#include "rwmake.ch"
#include "TOPCONN.ch"

/*/{Protheus.doc} ARQATUCCB
@author legado
@since 21/07/2017
@version 0.0
@type function
@description  Geração do Arquivo de Atualização CCB
Modificado em 20/06/2013 por Cristiano Campos                             
Verificar os titulos em aberto (e1_baixa em branco ) independente de      
haver titulos que foram baixados entre a data de geração do arquivo e o   
limite superior do periodo do arquivo. Pedido pelo Sr. Zacarias de        
com a empresa CCB ( este principio fere a logica do sistema PROTHEU )     
ATENÇÃO ao tentar analisar os valores deste arquivo contra as consultas   
existentes no PROTHEUS                                                    
VENCER - considerar se maior que a data de geração do arquivo             
VENCIDO - considerar se menor que a data de geração do arquivo
/*/
User Function ARQATUCCB()

	MV_PAR01 := Ctod("")
	MV_PAR02 := Space(40)
	dDataIni := Ctod("//")
	dDataFim := Ctod("//")

	@ 000,000 TO 270,420 DIALOG oGeraTxt TITLE OemToAnsi("Geração do Arquivo de Atualização CCB")
	@ 10,018 Say "Este programa ira gerar um arquivo texto, com informações"
	@ 18,018 Say "do Contas a Receber ao Arquivo de Atualização CCB."
	@ 34,018 Say "1ra. Remessa - MENSAL - Até 2º dia útil do mês:"
	@ 42,018 Say "         -> Dados do dia 01 até último dia do mês anterior;"
	@ 50,018 Say "2nda.Remessa - 1ª DEZENA - Até 2º dia útil, após dia 10 do mês:"
	@ 58,018 Say "         -> Dados de 01 a 10 do mês vigente;"
	@ 66,018 Say "3ra.Remessa - 2ª DEZENA - Até 2º dia útil, após dia 20 do mês:"
	@ 74,018 Say "         -> Dados de 01 a 20 do mês vigente."
	@ 122,108 BMPBUTTON TYPE 01 ACTION GeraCCB()
	@ 122,138 BMPBUTTON TYPE 02 ACTION Close(oGeratxt)
	Activate Dialog oGeraTxt Centered

Return(.T.)

Static Function GeraCCB()
	Local cDia 	:= ""
	Local cMes	:= ""
	Local cAno	:= ""
	Local cArquivo := "C:\" + Space(47)

	aParamBox := {}
	aRet := ""
	aAdd(aParamBox,{2,"Tipo de  Dados:","01 Mes Anterior",{ "01 Mes Anterior", "10 1ºDezena", "20 2ºDezena" }, 60,'.T.',.T.})
	aAdd(aParamBox,{6,"Pasta de Saída:  ",cArquivo ,"","",.F.,90,.T.,"","C:\",GETF_LOCALHARD+GETF_LOCALFLOPPY+GETF_NETWORKDRIVE})

	If !ParamBox(aParamBox, "Parametros", @aRet)
		Return(.F.)
	EndIf

	If Rat("\",MV_PAR02) == 0
		MsgAlert("Pasta para Gravação do Arquivo Inválida! ","Atenção")
		Return(.F.)
	EndIf

	cDia		:= Substr(aRet[1],1,2)
	cMes		:= StrZero(Month(dDatabase),2)
	cAno		:= StrZero(Year(dDataBase) ,4)
	MV_PAR01 	:= CtoD(cDia+"/"+cMes+"/"+cAno)
	MV_PAR02 	:= aRet[2]

	If Day(MV_PAR01) >= 1 .and. Day(MV_PAR01) <= 5
		// Ate o 2º dia util do mes vigente - Dados do Mes anterior
		// Acho o último dia do mês anterior
		dMesAnt  := MV_PAR01 - Day(MV_PAR01)
		// Acho o primeiro dia do mês anterior
		dDataIni := dMesAnt - Day(dMesAnt) + 1
		// Último dia do mês anterior
		dDataFim := dMesAnt
	ElseIf Day(MV_PAR01) >= 10 .and. Day(MV_PAR01) <= 25
		//Até o 2º dia util após dia 10 - Dados da primeira dezena
		// Acho o primeiro dia do mês vigente
		dDataIni := MV_PAR01 - Day(MV_PAR01) + 1
		// Último dia do período - dia 10 ou 20
		dDataFim := MV_PAR01
	EndIf

	If dDataIni > Date() .Or. dDataFim > Date()
		MsgAlert("Arquivo não pode ser gerado para este periodo ! ","Atenção")
		Return (.F.)
	Endif
	MV_PAR02 := Upper(MV_PAR02)
	If Empty(MV_PAR02)
		MV_PAR02 := "C:\"
	Else
		MV_PAR02 := Left(mv_par02,Rat("\",MV_PAR02))
	EndIf

	aFiles := ARRAY(ADIR(MV_PAR02+"*.*"))
	ADIR(MV_PAR02+"*.*",aFiles)
	If Len(aFiles) == 0
		MsgAlert("Pasta para Gravação do Arquivo " + mv_par02 + " Inválida! ","Atenção")
		Return(.F.)
	EndIf

	_cPeriodo := "Período: de " + Dtoc(dDataIni) + " até " + Dtoc(dDataFim) + "."

	MsgAlert("Arquivo Será Gravado em " + MV_PAR02 + Chr(13) + Chr(13) + _cPeriodo,"Atenção")

	GereCCB()

	Close(oGeratxt)
Return(.T.)

Static Function GereCCB()
	cNumconv := GetMV("CBC_NUMCCB")
	cNumConv := IIf(Empty(cNumConv),"37",cNumConv)

	// Arquivo de Controle
	aCampos := {}
	_cNomArq := ""
	aAdd(aCampos, {"MESREF "   	, "C", 11, 0}) // MÊS DE REFERÊNCIA - DATA DE GERAÇÃO DO ARQUIVO
	aAdd(aCampos, {"CODIFC"   	, "C", 02, 0}) // NÚMERO DO CONVENIADO - COBRECOM É 37
	aAdd(aCampos, {"CNPJCLI"   	, "C", 08, 0}) // CNPJ DO CLIENTE - 8 PRIMEIROS DÍGITOS
	aAdd(aCampos, {"NOMECLI"  	, "C", 50, 0}) // NOME DO CLIENTE
	aAdd(aCampos, {"PRICOM"   	, "C", 11, 0}) // DT DA PRIMEIRA VENDA AO CLIENTE
	aAdd(aCampos, {"CIDCLI"   	, "C", 30, 0}) // CIDADE DO CLIENTE
	aAdd(aCampos, {"UFCLI"    	, "C", 02, 0}) // UF DO CLIENTE
	aAdd(aCampos, {"CEPCLI"   	, "C", 02, 0}) // CEP - SOMENTE 2 PRIMEIRO DIGITOS
	aAdd(aCampos, {"DTMAIFT"	, "C", 11, 0}) // DATA DA MAIOR FATURA - MAIOR NOTA EMITIDA AO CLIENTE NO PERÍODO
	aAdd(aCampos, {"VLMAIFT"	, "C", 11, 0}) // VALOR DA MAIOR FATURA - MAIOR NOTA EMITIDA AO CLIENTE NO PERÍODO
	aAdd(aCampos, {"VLRVENC"	, "C", 11, 0}) // TOTAL A VENCER NA DATA DE REFERÊNCIA
	aAdd(aCampos, {"PRMEDVEN" 	, "C", 06, 0}) // PRAZO MÉDIO DE VENDAS
	aAdd(aCampos, {"VLRVCDO"  	, "C", 11, 0}) // VALOR VENCIDO NA DATA DE REFERENCIA
	aAdd(aCampos, {"QTDVCDO"  	, "C", 06, 0}) // QUANT.TÍTULOS VENCIDOS
	aAdd(aCampos, {"DTVENCA"  	, "C", 11, 0}) // VENCIMENTO MAIS ANTIDO
	aAdd(aCampos, {"DTVENCB"  	, "C", 11, 0}) // ÚLTIMO VENCIMENTO DE TITULO (MAIS LONGE)
	aAdd(aCampos, {"MEDIAVEN" 	, "C", 06, 0}) // MÉDIA DE DIAS DOS TITULOS VENCIDOS
	aAdd(aCampos, {"TABCCB"   	, "C", 02, 0}) // TABELA CCB
	aAdd(aCampos, {"MEDPGAT"  	, "C", 06, 0}) // MÉDIA DE DIAS DE PAGAMENTOS FEITOS EM ATRAZO

	If Select("TRB1") > 0
		DbSelectArea("TRB1")
		DbCloseArea("TRB1")
	EndIf

	_cNomArq1 	:= AllTrim(CriaTrab(aCampos, .T.))
	
	if U_zIs12()
		_cNomArq 	:= AllTrim(_cNomArq1) + ".DTC"
	else
		_cNomArq 	:= AllTrim(_cNomArq1) + ".DBF"
	endif
	
	_cNomInd 	:= AllTrim(_cNomArq1)
	DbUseArea(.T.,, _cNomArq, "TRB1", .F., .F.)

	DbSelectArea("TRB1")
	IndRegua("TRB1",_cNomInd,"CNPJCLI",,,"Selecionando Registros...")
	DbSetIndex(_cNomInd+OrdBagExt())

	DbSelectArea("SA1")
	DbSetOrder(1)

	DbSelectArea("SE1")
	DbSetOrder(1)

	DbSelectArea("SF2")
	DbSetOrder(1)

	DbSelectArea("SM0")
	DbSetOrder(1)

	cMyEmp   := cEmpAnt
	cMyFil   := cFilAnt
	_cFils   := ""
	SM0->(DbSeek(cMyEmp,.F.))
	Do While SM0->M0_CODIGO == cEmpAnt .And. !SM0->(Eof())
		_cFils   += "'" + FWCodFil() + "',"
		SM0->(DbSkip())
	EndDo 
	_cFils := Left(_cFils,Len(_cFils)-1) // Tira a ultima ","
	SM0->(DbSeek(cEmpAnt+cFilAnt,.F.))
	Processa({|| RunSF2(_cFils) },"Analisando Faturamento ")
	Processa({|| RunSE1(_cFils) },"Analisando Contas a Receber ")

	cEmpAnt := cMyEmp
	cFilAnt := cMyFil
	SM0->(DbSeek(cEmpAnt+cFilAnt,.F.))

	//Exporta o arquivo para Texto
	DbSelectArea("TRB1")

	Processa({|| FiltraTRB1() },"Filtrando Dados")

	_cNomTxt := "CCB"+Dtos(dDataBase)+StrTran(Time(),":","") + ".TXT"
	Copy to &_cNomTxt. SDF

	If Select("TRB1")>0
		DbSelectArea("TRB1")
		DbCloseArea()
	EndIf

	CPYS2T(_cNomTxt,MV_PAR02,.F.)
	Alert("Criado Arquivo " + MV_PAR02 + _cNomTxt)
Return(.T.)

Static Function RunSF2(_cFils)
	local cQry  := ''
	local cQry1 := ''
	local nI	:= 0

	cQry1  := "FROM " + RetSqlName("SF2") + " as F2, " + RetSqlName("SA1") + " as A1 "
	cQry1  += "WHERE F2.D_E_L_E_T_ = ' ' AND A1.D_E_L_E_T_ = ' ' AND F2_FILIAL in (" + _cFils + ") "
	cQry1  += "AND F2_SERIE = '1  ' AND F2_TIPO = 'N' AND A1_COD = F2_CLIENTE AND A1_LOJA = F2_LOJA "
	cQry1  += "AND A1_FILIAL = '" + xFilial("SA1") + "' AND A1_PESSOA = 'J' AND A1_CGC <> '  ' AND F2_VALFAT > 0 "
	cQry1  += "AND F2_EMISSAO between '" + Dtos(dDataIni) + "' AND '" + Dtos(dDataFim) + "' "

	cQry  := "SELECT COUNT(*) AS F2QTD " + cQry1

	If Select("TRBSEL") > 0
		TRBSEL->(dbclosearea())
	EndIf
	TcQuery cQry new alias "TRBSEL"

	DbSelectArea("TRBSEL")
	DbGoTop()
	_nF2QTD := TRBSEL->F2QTD

	cQry  := "SELECT A1_CGC,F2_COND,F2_VALFAT,F2_EMISSAO " + cQry1 + " ORDER BY A1_CGC "

	If Select("TRBSEL") > 0
		TRBSEL->(dbclosearea())
	EndIf
	TcQuery cQry new alias "TRBSEL"

	DbSelectArea("TRBSEL")
	DbGoTop()

	ProcRegua(_nF2QTD)

	Do While TRBSEL->(!Eof())

		_cCnpj := Left(TRBSEL->A1_CGC,8)
		SA1->(DbSetOrder(3)) // A1_FILIAL+A1_CGC
		SA1->(DbSeek(xFilial("SA1")+_cCnpj,.F.)) // pega o primeiro cara com esse CNPJ
		_dDtDesde := SA1->A1_PRICOM
		Do While SA1->A1_FILIAL == xFilial("SA1") .And. Left(SA1->A1_CGC,8) == _cCnpj .And. SA1->(!Eof())
			If (!Empty(SA1->A1_PRICOM) .And. SA1->A1_PRICOM < _dDtDesde) .Or. Empty(_dDtDesde)
				_dDtDesde := SA1->A1_PRICOM
			EndIf
			SA1->(DbSkip())
		EndDo

		/*/
		E-mail do Bruno solicitando que dos clientes abaixo não sejam enviadas informaçõs ao SERASA ou CCB
		PANORAMA FUNDICAO DE METAIS LTDA                  62.603.733/0001-78
		I.C.A LIGAS DE ALUMINIO LTDA                      04.749.817/0001-18
		EXTRA LIGAS IND.E COM. DE METAIS EIRELI           00.351.219/0001-35
		SIMETAL INDUSTRIA E COMERCIO DE METAIS EIRELI	  14.488.556/0001-83
		DAFMETAL INDUSTRIA E COMERCIO DE METAIS - EIRELI  50.695.352/0001-87
		SEVEN METAIS COM. DE METAIS E TUBOS EIRELI        03.123.156/0001-58
		OPEN COMERCIO DE METAIS EIRELI EPP                20.121.669/0001-49
		LINGOMETAL INDUSTRIA E COM. DE METAIS LTDA        15.077.333/0001-96
		ROYAL CROW DO BRASIL EIRELI - EPP                 20.754.234/0001-31
		/*/
		If Left(_cCnpj,8) $ "62603733//04749817//00351219//14488556//50695352//03123156//20121669//15077333//20754234"
			TRBSEL->(DbSkip())
			Loop
		EndIf

		SA1->(DbSeek(xFilial("SA1")+_cCnpj,.F.))
		// Valor da Maior Fatura
		_nMaiVen := 0
		// Data da Maior Fatura
		_cDatVen := ""
		_nDias   := 0
		_nQtDias := 0

		Do While Left(TRBSEL->A1_CGC,8) == _cCnpj .And. TRBSEL->(!Eof())
			IncProc()
			If TRBSEL->F2_VALFAT > _nMaiVen
				_nMaiVen := TRBSEL->F2_VALFAT   // Maior Venda
				_cDatVen := Right(TRBSEL->F2_EMISSAO,2)+"/"+Substr(TRBSEL->F2_EMISSAO,5,2)+"/"+Left(TRBSEL->F2_EMISSAO,4) // Data da Maior Venda
			EndIf

			_dDatVen := Ctod(Right(TRBSEL->F2_EMISSAO,2)+"/"+Substr(TRBSEL->F2_EMISSAO,5,2)+"/"+Left(TRBSEL->F2_EMISSAO,4)) // Data da Maior Venda

			aCond   := Condicao(TRBSEL->F2_VALFAT,TRBSEL->F2_COND,,_dDatVen)
			_nQtDias += Len(aCond)
			For nI := 1 to Len(aCond)
				_nDias += (aCond[nI,1] - _dDatVen)
			Next
			TRBSEL->(DbSkip())
		EndDo

		DbSelectArea("TRB1")
		RecLock("TRB1",.T.)
		TRB1->MESREF  := DtoCCB(MV_PAR01)
		TRB1->CODIFC  := cNumConv
		TRB1->NOMECLI := SA1->A1_NOME
		TRB1->PRICOM  := DtoCCB(SA1->A1_PRICOM)
		TRB1->CIDCLI  := SA1->A1_MUN
		TRB1->UFCLI   := SA1->A1_EST
		TRB1->CEPCLI  := Left(SA1->A1_CEP,2)
		TRB1->CNPJCLI := _cCnpj
		TRB1->DTMAIFT := _cDatVen
		TRB1->VLMAIFT := Str(Int(_nMaiVen),11)
		TRB1->PRMEDVEN:= Str(Int(_nDias/_nQtDias),6)
		MsUnLock()
	EndDo
	If Select("TRBSEL") > 0
		TRBSEL->(dbclosearea())
	EndIf
Return(.T.)

Static Function RunSE1()
	// Selecionar:
	//	Todos os E1 que são do MATA460 E PREFIXO = 1
	//		Foram criados no periodo do parâmetro ou
	//		Foram baixados no periodo do parâmetro ou
	//      Foram criados antes do período e baixados após o periodo ou
	//      Foram criados antes do período e estão em aberto

	Local cQry  := ''
	LOcal cQry1 := ''

	cQry1  := "FROM "+ RetSqlName("SE1") + " as E1, "+ RetSqlName("SA1") + " as A1 "
	cQry1  += "WHERE E1.D_E_L_E_T_ <> '*' AND E1.E1_FILIAL in ("+_cFils+") "
	cQry1  += "AND A1.D_E_L_E_T_ <> '*' AND A1.A1_FILIAL = '"+xFilial("SA1")+"' "
	cQry1  += "AND A1.A1_COD = E1.E1_CLIENTE AND A1.A1_LOJA = E1.E1_LOJA "
	cQry1  += "AND E1.E1_ORIGEM = 'MATA460' AND E1.E1_PREFIXO = '1  ' AND E1_TIPO = 'NF ' AND "
	cQry1  += "((E1.E1_EMISSAO between '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"') "
	cQry1  += "OR "
	cQry1  += "(E1.E1_BAIXA between '"+Dtos(dDataIni)+"' AND '"+Dtos(dDataFim)+"') "
	cQry1  += "OR "
	cQry1  += "(E1.E1_EMISSAO < '"+Dtos(dDataIni)+"' AND E1.E1_BAIXA > '"+Dtos(dDataFim)+"') "
	cQry1  += "OR "
	cQry1  += "(E1.E1_EMISSAO < '"+Dtos(dDataIni)+"' AND E1.E1_BAIXA = '        ')) "

	cQry  := "SELECT COUNT(*) AS E1QTD " + cQry1

	If Select("TRBSEL") > 0
		TRBSEL->(dbclosearea())
	EndIf
	TcQuery cQry new alias "TRBSEL"

	DbSelectArea("TRBSEL")
	DbGoTop()
	_nE1QTD := TRBSEL->E1QTD

	cQry  := "SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,A1.A1_CGC " + cQry1 + " ORDER BY A1_CGC, E1_FILIAL"

	If Select("TRBSEL") > 0
		TRBSEL->(dbclosearea())
	EndIf
	TcQuery cQry new alias "TRBSEL"

	DbSelectArea("SE1")
	DbSetOrder(1)

	DbSelectArea("TRBSEL")
	DbGoTop()

	ProcRegua(_nE1QTD)

	Do While TRBSEL->(!Eof())
		_cCnpj := Left(TRBSEL->A1_CGC,8)

		/*/
		E-mail do Bruno solicitando que dos clientes abaixo não sejam enviadas informaçõs ao SERASA ou CCB
		PANORAMA FUNDICAO DE METAIS LTDA                  62.603.733/0001-78
		I.C.A LIGAS DE ALUMINIO LTDA                      04.749.817/0001-18
		EXTRA LIGAS IND.E COM. DE METAIS EIRELI           00.351.219/0001-35
		SIMETAL INDUSTRIA E COMERCIO DE METAIS EIRELI	  14.488.556/0001-83
		DAFMETAL INDUSTRIA E COMERCIO DE METAIS - EIRELI  50.695.352/0001-87
		SEVEN METAIS COM. DE METAIS E TUBOS EIRELI        03.123.156/0001-58
		OPEN COMERCIO DE METAIS EIRELI EPP                20.121.669/0001-49
		LINGOMETAL INDUSTRIA E COM. DE METAIS LTDA        15.077.333/0001-96
		ROYAL CROW DO BRASIL EIRELI - EPP                 20.754.234/0001-31
		/*/
		If Left(_cCnpj,8) $ "62603733//04749817//00351219//14488556//50695352//03123156//20121669//15077333//20754234"
			TRBSEL->(DbSkip())
			Loop
		EndIf

		SA1->(DbSetOrder(3)) // A1_FILIAL+SA1->A1_CGC
		SA1->(DbSeek(xFilial("SA1")+_cCnpj,.F.))

		_nTtaRec := 0.00 // VALOR A VENCER
		_nToVenc := 0.00 // VALOR total VENCIDO E NÃO PAGO
		_nQtVenc := 0    // QTD TITULOS VENCIDOS
		_dDtVcVl := Ctod("//") // DT VENCIDO MAIS VELHO
		_dDtVcLg := Ctod("//") // DT A VENCER MAIS LONGE
		_aPzNPag := {0,0} // {QtdDiasVencido,QtdTitVencidos) - PRAZO MEDIO DOS VENCIDOS E NãO PAGOS
		_aPzAtrs := {0,0} // {QtdDiasAtrasado,QtdPagtosAtrasados} - PRAZO MÉDIO DOS TITULOS PAGOS EM ATRAZO
		_lGrvCGC := .F.

		Do While Left(TRBSEL->A1_CGC,8) == _cCnpj .And. TRBSEL->(!Eof())
			IncProc()

			// Altera a filial por causa da função SalTit
			cFilAnt := TRBSEL->E1_FILIAL
			SM0->(DbSeek(cEmpAnt+cFilAnt,.F.))

			SE1->(DbSetOrder(1))
			SE1->(DbSeek(xFilial("SE1") + TRBSEL->E1_PREFIXO+TRBSEL->E1_NUM+TRBSEL->E1_PARCELA+TRBSEL->E1_TIPO,.F.))

			_nSaldo  := SaldoTit(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,;
			SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE,SE1->E1_MOEDA,dDataBase,;
			dDataFim,SE1->E1_LOJA,SE1->E1_FILIAL)
			// Titulo em Aberto em dDataFim
			If _nSaldo > 0
				// Titulo em atraso
				If SE1->E1_VENCREA < dDataFim
					If Empty(_dDtVcVl)
						// DT VENCIDO MAIS VELHO
						_dDtVcVl := SE1->E1_VENCTO
					Else
						// DT VENCIDO MAIS VELHO
						_dDtVcVl := Min(_dDtVcVl,SE1->E1_VENCTO)
					EndIf
					// DT VENCIDO MAIS NOVO
					_dDtVcLg := Max(_dDtVcLg,SE1->E1_VENCTO)
					// VALOR total VENCIDO E NÃO PAGO
					_nToVenc += _nSaldo
					// QTD TITULOS VENCIDOS
					_nQtVenc++ 
					// {QtdDiasVencido,QtdTitVencidos) - PRAZO MEDIO DOS VENCIDOS E NãO PAGOS
					_aPzNPag[1] += (dDataFim-SE1->E1_VENCTO)
					// {QtdDiasVencido,QtdTitVencidos) - PRAZO MEDIO DOS VENCIDOS E NãO PAGOS
					_aPzNPag[2] += 1
				Else
					// VALOR A VENCER
					_nTtaRec += _nSaldo
				EndIf
				_lGrvCGC := .T.
			EndIf
			// Saldo diferente do valor... aconteceu alguma baixa... verificar se foi em atraso
			If SE1->E1_SALDO # SE1->E1_VALOR
				SE5->(DbSetOrder(7)) //E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ
				SE5->(DbSeek(xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA,.F.))

				Do While SE5->E5_FILIAL+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO+SE5->E5_CLIFOR +SE5->E5_LOJA == ;
				xFilial("SE5")+SE1->E1_PREFIXO+SE1->E1_NUM   +SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA .And. ;
				SE5->(!Eof())
					If SE5->E5_RECPAG == "R" .And. SE5->E5_DATA >= dDataIni .And. SE5->E5_DATA <= dDataFim .And. ;
					SE5->E5_MOTBX == "NOR" .And. SE5->E5_TIPODOC $ "BA//VL" .And. SE5->E5_DATA > SE1->E1_VENCREA
						// {QtdDiasAtrasado,QtdPagtosAtrasados} - PRAZO MÉDIO DOS TITULOS PAGOS EM ATRAZO
						_aPzAtrs[1] += (SE5->E5_DATA-SE1->E1_VENCTO)
						// {QtdDiasAtrasado,QtdPagtosAtrasados} - PRAZO MÉDIO DOS TITULOS PAGOS EM ATRAZO
						_aPzAtrs[2] += 1
						_lGrvCGC := .T.
					EndIf
					SE5->(DbSkip())
				EndDo
			Endif
			TRBSEL->(DbSkip())
		EndDo

		If _lGrvCGC
			DbSelectArea("TRB1")
			If DbSeek(_cCnpj,.F.)
				RecLock("TRB1",.F.)
			Else
				RecLock("TRB1",.T.)
				TRB1->CNPJCLI := _cCnpj
				TRB1->MESREF  := DtoCCB(MV_PAR01)
				TRB1->CODIFC  := cNumConv
				TRB1->NOMECLI := SA1->A1_NOME
				TRB1->PRICOM  := DtoCCB(SA1->A1_PRICOM)
				TRB1->CIDCLI  := SA1->A1_MUN
				TRB1->UFCLI   := SA1->A1_EST
				TRB1->CEPCLI  := Left(SA1->A1_CEP,2)
			EndIf

			If Substr(SA1->A1_CGC,9,4) == "0001" // Matriz
				TRB1->NOMECLI := SA1->A1_NOME
				TRB1->CIDCLI  := SA1->A1_MUN
				TRB1->UFCLI   := SA1->A1_EST
				TRB1->CEPCLI  := Left(SA1->A1_CEP,2)
			EndIf

			If !Empty(SA1->A1_PRICOM)
				_dPriCm := Ctod(TRB1->PRICOM)
				If SA1->A1_PRICOM < _dPriCm
					TRB1->PRICOM  := DtoCCB(SA1->A1_PRICOM)
				EndIf
			EndIf

			TRB1->VLRVENC  := Str(Int(_nTtaRec),11) // VALOR A VENCER                  // TOTAL A VENCER NA DATA DE REFERÊNCIA
			TRB1->VLRVCDO  := Str(Int(_nToVenc),11) // VALOR total VENCIDO E NÃO PAGO  // VALOR VENCIDO NA DATA DE REFERENCIA
			TRB1->QTDVCDO  := Str(Int(_nQtVenc),6)  // QTD TITULOS VENCIDOS            // QUANT.TÍTULOS VENCIDOS
			TRB1->DTVENCA  := DtoCCB(_dDtVcVl)      // DT VENCIDO MAIS VELHO           // VENCIMENTO MAIS ANTIDO
			TRB1->DTVENCB  := DtoCCB(_dDtVcLg)      // DT A VENCER MAIS LONGE          // ÚLTIMO VENCIMENTO DE TITULO (MAIS LONGE)
			If _aPzNPag[1] > 0
				// {QtdDiasVencido,QtdTitVencidos) - PRAZO MEDIO DOS VENCIDOS E NãO PAGOS
				// MÉDIA DE DIAS DOS TITULOS VENCIDOS
				TRB1->MEDIAVEN := Str(Int(_aPzNPag[1]/_aPzNPag[2]),6)
			EndIf
			If _aPzAtrs[1] > 0
				// {QtdDiasAtrasado,QtdPagtosAtrasados} - PRAZO MÉDIO DOS TITULOS PAGOS EM ATRAZO
				// MÉDIA DE DIAS DE PAGAMENTOS FEITOS EM ATRAZO
				TRB1->MEDPGAT := Str(Int(_aPzAtrs[1]/_aPzAtrs[2]),6)
			EndIf
			MsUnLock()
		EndIf
	EndDo
	If Select("TRBSEL") > 0
		TRBSEL->(dbclosearea())
	EndIf
Return(.T.)

Static function FiltraTRB1()
	DbSelectArea("TRB1")
	ProcRegua(LastRec())
	DbGoTop()
	Do While TRB1->(!Eof())
		IncProc()
		If Val(TRB1->VLMAIFT) == 0 .And. Val(TRB1->VLRVENC) == 0 .And. Val(TRB1->VLRVCDO) == 0
			RecLock("TRB1",.F.)
			DbDelete()
			MsUnLock()
		EndIf
		TRB1->(DbSkip())
	EndDo
	DbSelectArea("TRB1")
	Pack
Return(.T.)

Static Function DtoCCB(ccbDt)
	// Transforma para AAAAMMDD
	ccbDt := Dtos(ccbDt)
	ccbDt := Right(ccbDt,2) + "/" + Substr(ccbDt,5,2) + "/" + Left(ccbDt,4)
Return(ccbDt)
