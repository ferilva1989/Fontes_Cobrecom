#include "RWMAKE.CH"
#include "topconn.ch"

/*/{Protheus.doc} CDFINA13
@author zzz
@since 07/06/2017
@version 1.0
@type function
@description Geração de movimentacao financeira para SERASA 
/*/
user function CDFINA13()

	Private cPerg   := "CDFIN13"
	Private cString := "SE1"
	Private oGeraTxt
	Private _lAltPar := .F.

	If FWCodEmp()+FWCodFil() # "0101" /// Cobrecom Matriz
		Alert("Selecione Empresa I.F.C. / Matriz")
		Return(.T.)
	EndIf

	aParamBox := {}
	aRet      := {}
	aAdd(aParamBox,{3,"Exportar Por             ",1,{"Novo Envio","Arquivo Retorno"},060,"",.F.})
	If !ParamBox(aParamBox, "Opção Arquivo Serasa", @aRet)
		Return(.T.)
	EndIf
	If aRet[1] == 1
		@ 200,1 TO 380,380 DIALOG oGeraTxt TITLE OemToAnsi("Geração de Arquivo SERASA")
		@ 002,2 TO 090,190
		@ 10,018 Say " Este programa ira gerar um arquivo texto, conforme as definições "
		@ 18,018 Say " dos parâmetros pelo usuário e a seleção de registros do Cadastro "
		@ 26,018 Say " de Clientes (SA1) e as Movimentações Financeiras SE1/SE5         "
		@ 38,018 Say " ATENÇÃO: Confirme a existência do diretório \Serasa\          "
		
		@ 70,098 BMPBUTTON TYPE 01 ACTION Continua()
		@ 70,128 BMPBUTTON TYPE 02 ACTION Close(oGeratxt)
		@ 70,158 BMPBUTTON TYPE 05 ACTION Parametr(.T.) //Chamar o pergunte de novo
		
		Activate Dialog oGeraTxt Centered
	Else
		_cArq := cGetFile("Arquivos do tipo |SER*.*",OemToAnsi("Salvar Arquivo Como..."),0,"C:\",.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE)
		If !Empty(_cArq)
			Processa({|| FinSerasa()})
		EndIf
	EndIf

return(.T.)

/*/{Protheus.doc} Continua
@author zzz
@since 07/06/2017
@version 1.0
@type function
@description Utilizada na criação do arquivo para o primeiro envio
Cria e executa o select e chama a função RunCont() atraves do processa
mv_par01 Data Inicio
mv_par02 Data Fim
mv_par03 Periodicidade
/*/
static function Continua()

	Local cQuery  := ""
	Private cArqTxt
	Private nHdl
	Private cEOL

	// Se os parâmetros estiverem vazios, recebem o conteúdo do SX1

	/*/
	_UltDtEnv := GetMv("MV_DTSERAS") // Data final da última remessa enviada
	If MV_PAR01 # _UltDtEnv+1
	Alert("Data Inicial Ajustada para " + Dtoc(_UltDtEnv+1))
	EndIf
	MV_PAR01 := _UltDtEnv+1
	/*/
	Do While Empty(MV_PAR02) .Or. MV_PAR02 < MV_PAR01
		Alert("Corrigir Parâmetros!!")
		Parametr(.T.)
		//	MV_PAR01 := _UltDtEnv+1
	EndDo

	// Fazer select no banco
	cQuery := ""
	cQuery += "SELECT COUNT(*) TOTAL "
	cQuery += "FROM " + RetSqlName("SE1")
	cQuery += " WHERE ((E1_EMISSAO >= '" + Dtos(MV_PAR01) + "' AND E1_EMISSAO <= '" + Dtos(MV_PAR02) + "') OR"
	cQuery += " (E1_BAIXA >= '" + Dtos(MV_PAR01) + "' AND E1_BAIXA <= '" + Dtos(MV_PAR02) + "' AND E1_SALDO = 0)) AND"
	cQuery += " (E1_PREFIXO = 'UNI' OR E1_PREFIXO = '1  ') AND E1_SERASA <> '9' AND E1_ORIGEM = 'MATA460 ' AND D_E_L_E_T_ <> '*'"
	cQuery := ChangeQuery(cQuery)

	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"

	DbSelectArea("TRB")
	DbGotop()

	_nQtReg := TRB->TOTAL

	cQuery := ""
	cQuery += "SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO" //,E1_VALOR,E1_EMISSAO,E1_VENCTO,E1_SALDO,E1_BAIXA "
	cQuery += " FROM " + RetSqlName("SE1")
	cQuery += " WHERE ((E1_EMISSAO >= '" + Dtos(MV_PAR01) + "' AND E1_EMISSAO <= '" + Dtos(MV_PAR02) + "') OR"
	cQuery += " (E1_BAIXA   >= '" + Dtos(MV_PAR01) + "' AND E1_BAIXA <= '" + Dtos(MV_PAR02) + "' AND E1_SALDO = 0)) AND"
	cQuery += " (E1_PREFIXO = 'UNI' OR E1_PREFIXO = '1  ') AND E1_SERASA <> '9' AND E1_ORIGEM = 'MATA460 ' AND D_E_L_E_T_ <> '*'"

	cQuery := ChangeQuery(cQuery)

	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"

	Processa({|| RunCont() },"Processando...","Selecionando Registros... ")

	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	/*/
	DbSelectArea("SX6")
	DbSetOrder(1) // X6_FIL+X6_VAR
	DbSeek("  MV_DTSERAS",.F.)
	RecLock("SX6",.F.)
	SX6->X6_CONTEUD := Dtoc(MV_PAR02)
	SX6->X6_CONTSPA := Dtoc(MV_PAR02)
	SX6->X6_CONTENG := Dtoc(MV_PAR02)
	MsUnLock()
	/*/
return(.T.)

/*/{Protheus.doc} Parametr
@author zzz
@since 07/06/2017
@version 1.0
@param lForma, logical, descricao
@type function
@description Função de digitação dos parâmetros
/*/
static function Parametr(lForma)
	Pergunte(cPerg,lForma)
return(.T.)

/*/{Protheus.doc} CDFIN13A
@author zzz
@since 07/06/2017
@version 1.0
@type function
@description Função chamada no menu (Utilizado no segundo envio)
ler o arquivo informado no parametro exibir confirmação e chamar FinSerasa() 
/*/
user function CDFIN13A()
	local cPerg 	:= "CDFI13A"
	static _cArq	:= ''
	 
	 while .T.
		If !Pergunte(cPerg,.T.)
			Exit
		EndIf
		If Empty(MV_PAR01)
			Alert("Informar o Nome do Arquivo")
			Loop
		EndIf
		MV_PAR01 := Upper(AllTrim(MV_PAR01))
		_cArq := "\Serasa\"+MV_PAR01
		If !File(_cArq)
			Alert("O Arquivo " + MV_PAR01 + " tem que estar na Pasta \Serasa")
			Loop
		EndIf
		If MsgBox("Arquivo " + _cArq + " Localizado!" + Chr(13) + "Confirma o Processamento?","Confirma?","YesNo")
			Processa({|| FinSerasa()})
			Exit
		EndIf
		Exit
	enddo
return(.T.)

/*/{Protheus.doc} FinSerasa
@author zzz
@since 07/06/2017
@version 1.0
@type function
@description Recebe arquivo via parametro, busca no SE1
a data da baixa e cria um novo arquivo na pasta enviados
/*/
static function FinSerasa()
	private _aCampos := {}
	
	aAdd(_aCampos, {"CONTROL"  ,"C",130,0 } )
	If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf

	_cNomArq := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,, _cNomArq, "TRB", .T., .F.)

	// Criar um DBF com 130 posições
	//_Nome := "\Serasa\SER00012.F00"
	//_Nome := "\Serasa\SER00012.A01"
	_Nome := _cArq
	_DtBase := Ctod("")
	Append from &_Nome. SDF
	DbgoTop()
	
	If Left(TRB->CONTROL,44) # "00RELATO COMP NEGOCIOS02544042000119CONCILIA"
		Alert("Arquivo Inválido!")
		Return(.T.)
	EndIf

	DbSelectArea("SE1")
	DbSetOrder(1)

	DbSelectArea("TRB")
	ProcRegua(LastRec())
	DbgoTop()
	_Bx1 := 0 // Não pagos
	_Bx2 := 0 // Pagos após dtbase
	_Bx3 := 0 // Pagos até data base
	
	//Loop para procurar a data de pagamento e somar situações de atrasos
	Do While TRB->(!Eof())
		IncProc()
		If Left(TRB->CONTROL,2) == "00"
			_DtBase := Substr(TRB->CONTROL,45,08) // Da posição 45 ate a posição 52
		ElseIf Left(TRB->CONTROL,2) == "01"
			_cPart1   := Left(TRB->CONTROL,57)
			_cDtaPgto := Space(8)
			_cPart2   := Substr(TRB->CONTROL,066,130)
			_cTitulo  := Substr(TRB->CONTROL,68,20)
			
			if SE1->(DbSeek(_cTitulo,.F.))
				if SE1->E1_SALDO == 0
					
					_dtBaixa := Dtos(SE1->E1_BAIXA)
					If SE1->E1_BAIXA <= SE1->E1_EMISSAO .And. !Empty(SE1->E1_BAIXA)
						_dtBaixa := Dtos(SE1->E1_EMISSAO)
					EndIf
					
					if _dtBaixa <= _DtBase
						_cDtaPgto := _dtBaixa
						_Bx3++ // Pagos até data base
					else
						_Bx2++ // Pagos após dtbase
					endIf
				else
					_Bx1++ // Não pagos
				endIf
			endIf
			RecLock("TRB",.F.)
			TRB->CONTROL := _cPart1+_cDtaPgto+_cPart2
			MsUnLock()
		EndIf
		TRB->(DbSkip())
	EndDo
	
	//Criar o arquivo na pasta enviados
	DbSelectArea("TRB")
	cArqTxt := "IFC"+Dtos(dDataBase)+"_C.TXT"
	Copy to &cArqTxt. SDF
	DbCloseArea()
	_nPsBar := 0
	For _nPss := 1 to Len(_cArq)
		If Substr(_cArq,_nPss,1) == "\"
			_nPsBar := _nPss
		EndIf
	Next
	_cPathDes:= DirSerasa()
	CPYS2T(cArqTxt,_cPathDes,.F.)
	Delete File &cArqTxt.

	MsgAlert("Arquivo  '" + _cPathDes+cArqTxt + "',  Gerado com Sucesso! ","Atenção")
return(.T.)

/*/{Protheus.doc} RunCont
@author zzz
@since 07/06/2017
@version 1.0
@type function
@description Realiza o processamento do arquivo para o primeiro envio
/*/
static function RunCont()

	Local nTamLin, cLin
	Private _nQtd_A1 := 0
	Private _nQtd_SE := 0

	cArqTxt := "\Serasa\IFC"+Dtos(dDataBase)+".TXT"
	nHdl    := fCreate(cArqTxt)
	cEOL    := CHR(13)+CHR(10)
	Do While nHdl <= 0
		Alert("Criar a Pasta \Serasa")
		nHdl    := fCreate(cArqTxt)
	EndDo

	// Cria o Header
	nTamLin := 130
	cLin := Space(nTamLin)+cEOL
	cLin := Stuff(cLin,001,002,"00") // Fixo 00
	cLin := Stuff(cLin,003,020,"RELATO COMP NEGOCIOS") // Fixo RELATO COMP NEGOCIOS
	cLin := Stuff(cLin,023,014,"02544042000119") // CNPJ
	cLin := Stuff(cLin,037,008,DTOS(MV_PAR01)) // Data Inicial
	cLin := Stuff(cLin,045,008,DTOS(MV_PAR02)) // Data Final
	cLin := Stuff(cLin,053,001,Substr("DSQM",MV_PAR03,1))

	// Periodicidade Diario/Mensal/Semanal/Quinzenal
	cLin := Stuff(cLin,054,015,Space(15)) // Reservado SERASA
	cLin := Stuff(cLin,069,003,Space(03)) // Ident. Grupo SERASA ou Brancos
	cLin := Stuff(cLin,072,029,Space(29)) // Brancos
	cLin := Stuff(cLin,101,002,"V.") // Ident. da Versão do Layout Fixo V.
	cLin := Stuff(cLin,103,002,"01") // Número da versão do Layout Fixo 01
	cLin := Stuff(cLin,105,026,Space(26)) // Brancos

	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin) //Gravacao do arquivo
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo !!","Atencao!")
			Quit
		Endif
	Endif

	DbSelectArea("SA1")
	DbSetOrder(1)

	DbSelectArea("SE1")
	DbSetOrder(1) // E1_FILIAL+DTOS(E1_EMISSAO)+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_PARCELA

	DbSelectArea("TRB")
	DbGotop()
	ProcRegua(_nQtReg)

	Do While TRB->(!Eof())
		IncProc()
		SE1->(DbSetOrder(1))
		If SE1->(DbSeek(TRB->E1_FILIAL+TRB->E1_PREFIXO+TRB->E1_NUM+TRB->E1_PARCELA+TRB->E1_TIPO,.F.))
			If SE1->E1_PREFIXO $ "UNI/1  " .And. SE1->E1_SERASA # "9" .And. "MATA460" $ Upper(SE1->E1_ORIGEM)
				If SE1->E1_SERASA $ " 0" .Or. (SE1->E1_SERASA == "1" .And. SE1->E1_SALDO == 0)
					If EXPSA1() // Exporta Cliente
						ExpSE1() // Exporta CR
						RecLock("SE1",.F.)
						SE1->E1_SERASA := If(SE1->E1_SALDO == 0 .And. SE1->E1_BAIXA <= MV_PAR02,"9","1")
						MsUnLock()
					EndIf
				EndIf
			EndIf
		EndIf
		DbSelectArea("TRB")
		DbSkip()
	Enddo

	// Cria o Footer
	nTamLin := 130
	cLin := Space(nTamLin)+cEOL
	cLin := Stuff(cLin,001,002,"99")                 // Fixo 99
	cLin := Stuff(cLin,003,011,StrZero(_nQtd_A1,11)) // Quant. de Registro de Tempo de Relacionamento
	cLin := Stuff(cLin,014,044,Space(44))            // Brancos
	cLin := Stuff(cLin,058,011,StrZero(_nQtd_SE,11)) // Quant. de Registro de Tempo de Títulos

	cLin := Stuff(cLin,069,011,Space(11)) // Reservado SERASA
	cLin := Stuff(cLin,080,011,Space(11)) // Reservado SERASA
	cLin := Stuff(cLin,091,010,Space(10)) // Reservado SERASA
	cLin := Stuff(cLin,101,030,Space(30)) // Brancos
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin) //Gravacao do arquivo
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo !!","Atencao!")
			Quit
		Endif
	Endif
	fClose(nHdl)
	MsgAlert("Arquivo  '" + cArqTxt + "'  Gerado com Sucesso! ","Atenção")
	Close(oGeraTxt)
return(.T.)

/*/{Protheus.doc} EXPSA1
@author zzz
@since 07/06/2017
@version 1.0
@type function
@description decobrir
/*/
static function EXPSA1()

	SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
	SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.F.))
	If " " $ SA1->A1_CGC .Or. "02544042" == Left(SA1->A1_CGC,8) // Não é pessoa Jurídica ou é a própria IFC
		Return(.F.)
	EndIf                               
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

	If Left(SA1->A1_CGC,8) $ "62603733//04749817//00351219//14488556//50695352//03123156//20121669//15077333//20754234"
		Return(.F.)
	EndIf

	If SA1->A1_SERASA $  " 0" // Cliente nunca enviado para o SERASA
		// Criar Registro de  Tempo de Relacionamento
		nTamLin := 130
		cLin := Space(nTamLin)+cEOL
		cLin := Stuff(cLin,001,002,"01") // Fixo 01
		cLin := Stuff(cLin,003,014,SA1->A1_CGC) // CNPJ do Cliente
		cLin := Stuff(cLin,017,002,"01") // Tipo do registro para TEMPO DE RELACIONAMENTO" fixo 01
		cLin := Stuff(cLin,019,008,DTOS(SA1->A1_PRICOM)) // Cliente desde? -> Dta da primeira compra
		If (dDatabase - SA1->A1_PRICOM) > 365 .And. !Empty(SA1->A1_PRICOM) // mais de 1 ano
			cLin := Stuff(cLin,027,001,"1") // Cliente Antigo
		Else
			cLin := Stuff(cLin,027,001,"2") // Cliente menos de 1 ano
		EndIf
		cLin := Stuff(cLin,028,038,Space(38)) // Brancos
		cLin := Stuff(cLin,066,034,Space(34)) // Brancos
		cLin := Stuff(cLin,100,001,Space(01)) // Brancos
		cLin := Stuff(cLin,101,030,Space(30)) // Brancos

		If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin) //Gravacao do arquivo
			If !MsgAlert("Ocorreu um erro na gravacao do arquivo !!","Atencao!")
				Quit
			Endif
		Endif
		_nQtd_A1++
		RecLock("SA1",.F.)
		SA1->A1_SERASA := "9"
		MsUnLock()

		// Não deveria, mas tem CNPJ repetido no SA1, por isso
		// verifico todos
		_cCgc := SA1->A1_CGC
		SA1->(DbSetOrder(3)) // A1_FILIAL+A1_CGC
		SA1->(DbSeek(xFilial("SA1") + _cCgc,.F.))
		Do While SA1->A1_FILIAL == xFilial("SA1") .And. SA1->A1_CGC == _cCgc .And. SA1->(!Eof())
			RecLock("SA1",.F.)
			SA1->A1_SERASA := "9"
			MsUnLock()
			SA1->(DbSkip())
		EndDo

		// Volta para o registro correto do SA1
		SA1->(DbSetOrder(1)) // A1_FILIAL+A1_COD+A1_LOJA
		SA1->(DbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA,.F.))

	EndIf
return(.T.)

/*/{Protheus.doc} ExpSE1
@author zzz
@since 07/06/2017
@version 1.0
@type function
@description descobrir
/*/
static function ExpSE1()

	nTamLin := 130
	cLin := Space(nTamLin)+cEOL

	cLin := Stuff(cLin,001,002,"01")                               // Fixo 01
	cLin := Stuff(cLin,003,014,SA1->A1_CGC)                        // CNPJ do Cliente
	cLin := Stuff(cLin,017,002,"05")                               // Tipo do registro para TITULOS PARA SACADO PESSOA JURÍDICA
	cLin := Stuff(cLin,019,010,Space(10))                          // Nro do título com + de 10 posições vai em outro campo
	cLin := Stuff(cLin,029,008,Dtos(SE1->E1_EMISSAO))              // Data de emissão do título
	cLin := Stuff(cLin,037,013,StrZero(Int(SE1->E1_VALOR*100),13)) // Valor do título
	cLin := Stuff(cLin,050,008,Dtos(Max(SE1->E1_VENCTO,SE1->E1_VENCREA)))               // Data de vencimento
	If SE1->E1_SALDO == 0 .And. SE1->E1_BAIXA <= MV_PAR02          // Titulo pago
		cLin := Stuff(cLin,058,008,Dtos(SE1->E1_BAIXA))            // Data de pagamento
	Else
		cLin := Stuff(cLin,058,008,Space(08))                      // Se não pago... envia brancos
	EndIf
	_cNum := Left(SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO + Space(32),32)
	cLin := Stuff(cLin,066,002,"#D")      // Cliente Antigo
	cLin := Stuff(cLin,068,032,_cNum)     // Número do título
	cLin := Stuff(cLin,100,001,Space(01)) // Brancos
	cLin := Stuff(cLin,101,024,Space(24)) // Brancos
	cLin := Stuff(cLin,125,002,Space(02)) // Brancos
	cLin := Stuff(cLin,127,001,Space(01)) // Brancos
	cLin := Stuff(cLin,128,001,Space(01)) // Brancos
	cLin := Stuff(cLin,129,002,Space(02)) // Brancos
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin) //Gravacao do arquivo
		If !MsgAlert("Ocorreu um erro na gravacao do arquivo !!","Atencao!")
			Quit
		Endif
	Endif
	_nQtd_SE++
return(.T.)


/*/{Protheus.doc} DirSerasa
//TODO Descrição auto-gerada.
@author alexandre.madeira
@since 21/03/2018
@version 1.0
@return cPath - Diretório destino para salvar o arquivo
@type function
/*/
static function DirSerasa()
	Local cPath := ""
	local oParam := nil
	Local  oParamBox 	:= nil
	local aParams	:= nil
	local oUtils 		:= nil
	
	oUtils 		:= LibUtilsObj():newLibUtilsObj() 
	oParamBox 	:= LibParamBoxObj():newLibParamBoxObj("ParamObjSerasa")
	oParamBox:setTitle("Diretório Arquivo Serasa")
	oParamBox:setValidation({|| ApMsgYesNo("Confirma parâmetros ?")})
	
	oParam := LibParamObj():newLibParamObj("diretorio", "file", "Diretorio", "C", 80)
	oParam:setFileStartDirectory("C:\")
	oParam:setFileTypes("Arquivos Texto |*.*")
	oParam:setFileParams(GETF_LOCALHARD+GETF_NETWORKDRIVE+ GETF_RETDIRECTORY )      
	
	oParamBox:addParam(oParam)
	
	if oParamBox:show()
		aParams:=oParamBox:getParams()
		for nI := 1 to Len(aParams) 
			oParam	:= aParams[nI]
			cPath	:= AllTrim(oParamBox:getValue(oParam:getId()))
		next nI	
	endIf
		
	freeobj(oParam)
	freeobj(oParamBox)
	
Return (cPath)