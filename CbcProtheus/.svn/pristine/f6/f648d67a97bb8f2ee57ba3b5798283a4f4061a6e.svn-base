#include "rwmake.ch"

///////////////////////////////////////////////////////////////////////////////
//																						//
//   Programa ...: CDEST20                            Modulo : SIGAFAT		//
//																						//
//   Autor ......: Roberto Oliveira                   Data ..: 19/01/2010		//
//																						//
//   Objetivo ...: Criar pré digitação de notas de transferência da matriz	//
//                 para a filial e vice versa....								//
//																						//
//																						//
//   Uso ........: EspecIfico da Cobrecom											//
//																						//
///////////////////////////////////////////////////////////////////////////////
*
***********************
User Function CDEST20()
***********************
*
*
local cLinha		:= '<br>'
local cMsgLog		:= ''
local _lTemIndustr	:= .F.
local aMPs			:= {}
local nPos			:= 0
Public _aDadosPed	:= {}
Private _cTesRtMP1	:= "537//097" // TES de saida de Itu e entrada em 3L - MP por encomenda (com Triangulação)
Private _cTesRtPA1	:= "538//098" // TES de saida de Itu e entrada em 3L - PA (Serviço) por encomenda (com Triangulação)
Private _cTesRtMP2	:= "539//099" // TES de saida de Itu e entrada em 3L - MP ENVIADO DIRETO (NÃO encomenda) (sem Triangulação)
Private _cTesRtPA2	:= "540//100" // TES de saida de Itu e entrada em 3L - PA (Serviço) ENVIADO DIRETO (NÃO encomenda) (sem Triangulação)
Private _cTesRtMP3	:= "550//150" // TES de saida de Itu e entrada em 3L - MP por encomenda NÃO USADA
Private _cTesRtPA3	:= "551//100" // TES de saida de Itu e entrada em 3L - PA (Serviço) ENVIADO DIRETO (NÃO encomenda) (sem Triangulação)
Private _cTesTrPA	:= "849//038" // TES de saida de Itu e entrada em 3L - PA (Serviço) ENVIADO DIRETO (NÃO encomenda) (sem Triangulação)
//Public _lFisico	:= .F.

Private cPerg := "CDFT20"
ValidPerg("1")

/* MADEIRA - INICIO SEMÁFORO */
	if !u_cbcSemaCtr(.T.,,'CDEST20',5,10,3000,.F.)
		return(.T.)
	endif
/* MADEIRA - FIM SEMÁFORO */

DbSelectArea("SF1")
DbSetOrder(1) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO

DbSelectArea("SD1")
DbSetOrder(1) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM

DbSelectArea("SF2")
DbSetOrder(1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL

DbSelectArea("SD2")
DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM

Pergunte(cPerg,.F.)

//Do While .T.
	//	MV_PAR02 := Soma1(MV_PAR02)
	If !Pergunte(cPerg,.T.)
		Return(.F.)
	EndIf
	If Empty(MV_PAR01) .Or. Empty(MV_PAR02)
		Alert("Informar o Série e Número da Nota de Origem")
		Return(.F.)
	ElseIf " " $ MV_PAR03
		Alert("Use Dois Dígitos para Identificar o Armazém")
		Return(.F.)
	EndIf

	// Estou alterando as variáveis MV_XPAR01 e MV_XPAR02 pois em algum ponto dos EXECAUTO elas
	// são al teradas para tipo N.
	cMsgLog += 'MV_PAR01: ' + MV_PAR01	+ cLinha
	cMsgLog += 'MV_PAR02: ' + MV_PAR02 	+ cLinha
	
	MV_XPAR01 := MV_PAR01
	MV_XPAR02 := MV_PAR02
	
	If xFilial("SF1") == "01" // Estou na Matriz
		_cFilOrig := "02"
		_cCodSF2  := If(MV_XPAR01 == "1  ","00256001","01577602") //Codigos de clientes
		_cCodSF1  := If(MV_XPAR01 == "1  ","V0069301","01577601") //Codigos de fornecedores
		_cCodSBF  := "00004801//00891801" // Para Entrada Remessa Beneficiamento em Itu Codigo do cliente ITU
	ElseIf xFilial("SF1") == "02" // Estou na Filial 3 Lagoas
		_cFilOrig := "01"
		_cCodSF2  := If(MV_XPAR01 == "1  ".OR.MV_XPAR01 == "U  ","00891801","01577601") //Codigos de clientes
		_cCodSF1  := If(MV_XPAR01 == "1  ".OR.MV_XPAR01 == "U  ","00004801","01577602") //Codigos de fornecedores
		_cCodSBF  := "V0069301//00256001" // Para Entrada Remessa Beneficiamento em 3L Codigo do cliente 3L
	EndIf
	
	cMsgLog += '_cCodSF1: ' + _cCodSF1	+ cLinha
	cMsgLog += cLinha
	
	DbSelectArea("SF2")
	DbSetOrder(1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
	If !DbSeek(_cFilOrig+MV_XPAR02+MV_XPAR01,.F.)
		Alert("Nota de Transferência não Existe")
		Return(.F.)
	EndIf

	If !SF2->F2_TIPO $ "NB"
		Alert("Nota de Transferência não Existe")
		Return(.F.)
	EndIf
	
	cMsgLog += 'F2.R_E_C_N_O_ : ' + cValToChar(SF2->(Recno())) + cLinha
	cMsgLog += cLinha
	
	// Verifico qual o tipo da nota para dar entrada
	_lTpNfTrf := " "  // Tipo da nota de Transferência (NN-Normal / RI-Remessa p/Indl. / DI-Devolução Indl.)
	
	cMsgLog += '_lTpNfTrf (Inicio): ' + _lTpNfTrf + cLinha
	cMsgLog += cLinha
	
	If SF2->F2_TIPO == "N" .And. SF2->(F2_CLIENTE+F2_LOJA) == _cCodSF2
		// A Nota é uma simples transferência ou é retorno de beneficiamento
		// Verificar pelo SD2 - assumo que é uma Devolução da industrialização
		_lTpNfTrf := "DI" // Tipo da nota de Transferência (NN-Normal / RI-Remessa p/Indl. / DI-Devolução Indl.)

		DbSelectArea("SD2")
		DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		DbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA),.F.)
		Do While SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) .And. SD2->(!Eof())
			cMsgLog += 'D2 -> Item:' + SD2->D2_ITEM + ' TES: ' + SD2->D2_TES + ' REC: ' + cValToChar(SD2->(Recno())) + '_lTpNfTrf: ' + _lTpNfTrf + cLinha
			if SD2->D2_TES $ Left(_cTesRtMP1,3)+"//"+Left(_cTesRtMP2,3)+"//"+Left(_cTesRtMP3,3)
				nPos := aScan(aMPs,{|x| x[1] == SD2->D2_COD})
				if nPos > 0
					aMPs[nPos, 02] += SD2->D2_QUANT
				else
					aAdd(aMPs, {SD2->D2_COD, SD2->D2_QUANT})
				endif
			endif			
			If !SD2->D2_TES $ Left(_cTesRtMP1,3)+"//"+Left(_cTesRtPA1,3)+"//"+Left(_cTesRtMP2,3)+"//"+Left(_cTesRtPA2,3)+"//"+Left(_cTesRtMP3,3)+"//"+Left(_cTesRtPA3,3)
				/*/
					Private _cTesRtMP1:= "537//097" // TES de saida de Itu e entrada em 3L - MP por encomenda (com Triangulação)
					Private _cTesRtPA1:= "538//098" // TES de saida de Itu e entrada em 3L - PA (Serviço) por encomenda (com Triangulação)
					Private _cTesRtMP2:= "539//099" // TES de saida de Itu e entrada em 3L - MP ENVIADO DIRETO (NÃO encomenda) (sem Triangulação)
					Private _cTesRtPA2:= "540//100" // TES de saida de Itu e entrada em 3L - PA (Serviço) ENVIADO DIRETO (NÃO encomenda) (sem Triangulação)
					Private _cTesRtMP3:= "550//150" // TES de saida de Itu e entrada em 3L - MP por encomenda NÃO USADA
					Private _cTesRtPA3:= "551//100" // TES de saida de Itu e entrada em 3L - PA (Serviço) ENVIADO DIRETO (NÃO encomenda) (sem Triangulação)
				/*/
				// Se o TES não se refere a retorno de Indl.
				// Assumo normal
				_lTpNfTrf := "NN"  // Tipo da nota de Transferência (NN-Normal / RI-Remessa p/Indl. / DI-Devolução Indl.)				
				cMsgLog += ' [ALTEROU] D2 -> TES:' + SD2->D2_TES
				cMsgLog += ' $ STR_TES: ' + ;
							Left(_cTesRtMP1,3)+"//"+Left(_cTesRtPA1,3)+"//"+Left(_cTesRtMP2,3)+;
							"//"+Left(_cTesRtPA2,3)+"//"+Left(_cTesRtMP3,3)+"//"+Left(_cTesRtPA3,3)
				cMsgLog += cLinha
				if _lTemIndustr
					MsgAlert("NF Incorreta. Verifique os Itens. Entrada não permitida!")
					u_cbcSemaCtr(.F.,,'CDEST20',,,,.F.)
					Return(.F.)
				endif
				//Exit
			ElseIf SD2->D2_TES $ Left(_cTesRtMP3,3)+"//"+Left(_cTesRtPA3,3)
				_cTesRtPA2	:= "551//100"
				_lTemIndustr := .T.
			EndIf
			cMsgLog += cLinha
			SD2->(DbSkip())			
		EndDo                    
	ElseIf SF2->F2_TIPO == "B" .And. SF2->(F2_CLIENTE+F2_LOJA) == Left(_cCodSBF,8)
		// Nota de envio para beneficiamento
		_lTpNfTrf := "RI"  // Tipo da nota de Transferência (NN-Normal / RI-Remessa p/Indl. / DI-Devolução Indl.)
	EndIf

	If Empty(_lTpNfTrf) // Tipo da nota de Transferência (NN-Normal / RI-Remessa p/Indl. / DI-Devolução Indl.)
		Alert("Nota de Transferência não Existe")
		Return(.F.)
	EndIf

	// Verificar se a nota já não foi incluida no destino
	DbSelectArea("SF1")
	DbSetOrder(1) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
	_lEsta := DbSeek(xFilial("SF1")+MV_XPAR02+MV_XPAR01+If(_lTpNfTrf == "RI",Right(_cCodSBF,8),_cCodSF1),.F.)
	If _lEsta
		Alert("Nota de Transferência já Informada")
		Return(.F.)
	EndIf
	//Verifica se é NF de Industrilização e se a mesma foi emitida no mesmo dia ou esta liberada pelo parametro MV_ZZINDLB
	If _lTpNfTrf == "DI" .And. Date() <= SF2->F2_EMISSAO
		If !(SF2->F2_DOC $ (GetMV("MV_ZZINDLB")))
			// A nota de origem é retorno de industrialização Emitida hoje?
			Alert("Nota Não Pode Ser Incluída Nesta Data")
			Return(.F.)
		EndIf
	EndIf
	
	cMsgLog += cLinha
	cMsgLog += '_lTpNfTrf (FIM): ' + _lTpNfTrf	+ cLinha
	cMsgLog += cLinha
	
	if !empty(cMsgLog)
		u_SendMail("wfti@cobrecom.com.br","[LOG - Transferência Filial] - Processamento de NF Tranferência: " + SF2->F2_DOC + ".", cMsgLog)
	endif
	
	If MsgBox("Confirma o Processamento da Nota " +MV_XPAR01 + "  " + MV_XPAR02 + "?","Confirma?","YesNo")
		If _lTpNfTrf == "DI"	// A nota de origem é retorno de industrialização?
			// _lTpNfTrf ->Tipo da nota de Transferência (NN-Normal / RI-Remessa p/Indl. / DI-Devolução Indl.)
			if validMP(aMPs)
				Processa({|| RetIndl()})
			endif
		Else
			If MsgBox("Confirma Armazem de ENTRADA : " +MV_PAR03 + "?","Confirma?","YesNo")
				Processa({|| Importa()})
			Else
				Alert("Processo cancelado. Nota Não Incluida.")
				Return()
			EndIf
		EndIf
	EndIf
//EndDo
/* MADEIRA - INICIO SEMÁFORO */
	u_cbcSemaCtr(.F.,,'CDEST20',,,,.F.)
/* MADEIRA - FIM SEMÁFORO */
Return(.T.)


/*/{Protheus.doc} Importa
//TODO importa Nfs que não são PAs de Industrialização.
@author ZZZZ
@since 12/04/2018
@version 1.0

@type function
/*/
Static Function Importa
	Local cObsTrf 	:= ""
	Local _cFilOrig	:= ""
	Local _cLocal	:= "01"
	
	DbSelectArea("SA2")
	DbSetOrder(1)
	DbSeek(xFilial("SA2") + _cCodSF1,.F.)
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SB2")
	DbSetOrder(1)
	
	DbSelectArea("SC6")
	DbSetOrder(1)
	
	DbSelectArea("SDB")
	DbSetOrder(1) // DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIfOR+DB_LOJA+DB_ITEM
	
	If _lTpNfTrf == "RI" // Tipo da nota de Transferência (NN-Normal / RI-Remessa p/Indl. / DI-Devolução Indl.)
		aCabec := {}
		aItens := {}
	
		aadd(aCabec,{"F1_DOC"				,SF2->F2_DOC      	, Nil})
		aadd(aCabec,{"F1_SERIE"				,SF2->F2_SERIE    	, Nil})
		aadd(aCabec,{"F1_FORNECE"		,Substr(_cCodSBF,11,6) , Nil})
		aadd(aCabec,{"F1_LOJA"				,Right(_cCodSBF,2)	, Nil})
		aadd(aCabec,{"F1_EMISSAO"		,SF2->F2_EMISSAO  , Nil})
		aadd(aCabec,{"F1_TIPO"				,"B"						, Nil})
		aadd(aCabec,{"F1_FORMUL"			,"N" 						, Nil})
		aadd(aCabec,{"F1_ESPECIE"		,"SPED"					, Nil})
		aAdd(aCabec,{"F1_DTDIGIT"			, ddatabase				, Nil})
		aAdd(aCabec,{"F1_CHVNFE"			, SF2->F2_CHVNFE  , Nil})
		aadd(aCabec,{"F1_COND"				,"001"						, Nil})
		aadd(aCabec,{"F1_DESPESA" 		,0.00						, Nil})
	
		DbSelectArea("SD2")
		DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		DbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA),.F.)
		Do While SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == ;
			SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) .And. SD2->(!Eof())
			
			aLinha := {}
			aAdd(aLinha,{"D1_ITEM"	, SD2->D2_ITEM		, Nil})
			aadd(aLinha,{"D1_COD"		, SD2->D2_COD		, Nil})
			aadd(aLinha,{"D1_QUANT" , SD2->D2_QUANT	, Nil})
			aadd(aLinha,{"D1_LOCAL"	, SD2->D2_LOCAL		, Nil})
			aadd(aLinha,{"D1_VUNIT"	, SD2->D2_PRCVEN	, Nil})
			aadd(aLinha,{"D1_TOTAL"	, SD2->D2_TOTAL		, Nil})
			aadd(aLinha,{"D1_TES"		, If(SD2->D2_TES=="536","096","119")	, Nil})
			aadd(aItens,aLinha)
	
			DbSelectArea("SD2")
			SD2->(DbSkip())
		EndDo
	
		Begin Transaction
		lMsErroAuto := .F.
		LjMsgRun("Gerando Documento de Entrada... "+SF2->F2_DOC,,{||MSExecAuto({|x, y, z| MATA103(x, y, z)}, aCabec, aItens, 3)})
		If lMsErroAuto
			DisarmTransaction()
			Alert("Erro na Inclusão da Nota!!!")
			MostraErro()
		Else
			Alert("Processo Concluído!!!")
		EndIf
		End Transaction
	Else
		aCabec := {}
		aItens := {}
		
		_cFilOrig := IIf (cFilAnt == "02", "01", "02")
			
		cObsTrf	:= SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
		
		aadd(aCabec,{"F1_DOC"			,SF2->F2_DOC      	, Nil})
		aadd(aCabec,{"F1_SERIE"			,SF2->F2_SERIE    	, Nil})
		aadd(aCabec,{"F1_FORNECE"	,Left(_cCodSF1,6)	, Nil})
		aadd(aCabec,{"F1_LOJA"			,Right(_cCodSF1,2)	, Nil})
		aadd(aCabec,{"F1_EMISSAO"	,SF2->F2_EMISSAO	, Nil})
		aadd(aCabec,{"F1_TIPO"			,"N"           				, Nil})
		aadd(aCabec,{"F1_FORMUL"		,"N"           				, Nil})
		aadd(aCabec,{"F1_ESPECIE"	,"SPED"           		, Nil})
		aAdd(aCabec,{"F1_DTDIGIT"		,ddatabase       		, Nil})
		aAdd(aCabec,{"F1_CHVNFE"		,SF2->F2_CHVNFE	, Nil})
		aadd(aCabec,{"F1_COND"    		,"263"						, Nil})
		aadd(aCabec,{"F1_DESPESA"	,0.00						, Nil})
		aAdd(aCabec,{"F1_OBSTRF"		,cObsTrf					, Nil})
		 
		DbSelectArea("SD2")
		DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
		DbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA),.F.)
		Do While SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == ;
			SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) .And. SD2->(!Eof())
			
			If SD2->D2_TP $ ("PA//")
				_cLocal	:= IIF(MV_PAR03=="10","10", SD2->D2_LOCAL)
			Else
				_cLocal	:= SD2->D2_LOCAL
			EndIf
			
			DBSelectArea("SB2")
			SB2->(DbSetOrder(1))
			If !SB2->(DbSeek(xFilial("SB2")+Padr(Alltrim(SD2->D2_COD),TamSX3("D3_COD")[1])+_cLocal,.F.))
				CriaSB2(Padr(Alltrim(SD2->D2_COD),TamSX3("D3_COD")[1]),_cLocal)
			EndIf
			
			_cTes := ""
			
			If SD2->D2_TP $ ("ME//PI//MP//SC")
				_cTes := "050"
			ElseIf SD2->D2_TP $ ("PA//")
				_cTes := "038"
			ElseIf SD2->D2_TP $ ("AI//")
				_cTes := "052"
			ElseIf SD2->D2_TP $ ("MC//")
				_cTes := "086"
			EndIf
			
			aLinha := {}
			
			aAdd(aLinha,{"D1_ITEM"		, SD2->D2_ITEM								, Nil})
			aadd(aLinha,{"D1_COD"		, SD2->D2_COD								, Nil})
			aadd(aLinha,{"D1_QUANT"		, SD2->D2_QUANT							, Nil})
			aadd(aLinha,{"D1_LOCAL"		, _cLocal										, Nil})
			aadd(aLinha,{"D1_VUNIT"		, SD2->D2_PRCVEN							, Nil})
			aadd(aLinha,{"D1_TOTAL"		, SD2->D2_TOTAL							, Nil})
			aadd(aLinha,{"D1_TES"			, _cTes 											, Nil})
			aadd(aLinha,{"D1_PICM"		, SD2->D2_PICM 								, Nil})
			aadd(aLinha,{"D1_VALICM"	, SD2->D2_VALICM							, Nil})
			aadd(aLinha,{"D1_VALICM"	, SD2->D2_VALICM							, Nil})
			aadd(aLinha,{"D1_CLASFIS"	, SD2->D2_CLASFIS							, Nil})
			aadd(aItens,aLinha)
	
			DbSelectArea("SD2")
			SD2->(DbSkip())
		EndDo
			
		Begin Transaction
			lMsErroAuto := .F.
			LjMsgRun("Gerando Documento de Entrada... "+SF2->F2_DOC,,{||MSExecAuto({|x, y, z| MATA103(x, y, z)}, aCabec, aItens, 3)})
			If lMsErroAuto
				DisarmTransaction()
				Alert("Erro na Inclusão da Nota!!!")
				MostraErro()
			Else
				AcheBob(_cFilOrig,SF2->F2_DOC,SF2->F2_SERIE)
				If SUPERGETMV("ZZ_EMPENT",, .F.)
					LibEst(_aDadosPed) //Libera os pedidos
				EndIf
				Alert("Processo Concluído!!!")
			EndIf
		End Transaction			
	EndIf
Return(.T.)

/*/{Protheus.doc} AcheBob
//TODO Procura a Bobina na filial de Origem e realiza a troca para a etiqueta gerando na filial corrente.
@author juliana.leme
@since 13/04/2018
@version 1.0
@param cFilialOrig, characters, descricao
@param cDocumen, characters, descricao
@param cSeri, characters, descricao
@type function
/*/
Static Function AcheBob(cFilialOrig,cDocumen,cSeri)
	Local _aAconds	:= {}
	Local _cQry		:= ""
	local nX		:= 0
	
	_cQry := " SELECT D2_FILIAL, ZE_NUMBOB, ZL_NUM+ZL_ITEM,C6_ZZPVORI,ZE_FILORIG, C6_NUM, C6_ITEM"
	_cQry += " FROM SD2010 D2 "
	_cQry += " INNER JOIN SDB010 DB ON DB_FILIAL = D2_FILIAL AND DB_NUMSEQ = D2_NUMSEQ AND DB_DOC = D2_DOC AND DB_SERIE = D2_SERIE AND DB.D_E_L_E_T_ = D2.D_E_L_E_T_ "
	_cQry += " INNER JOIN SZE010 ZE ON ZE_FILIAL = DB_FILIAL AND ZE_NUMSEQ = DB_NUMSEQ AND ZE_DOC = DB_DOC AND ZE_SERIE = DB_SERIE AND ZE.D_E_L_E_T_ = DB.D_E_L_E_T_ "
	_cQry += " INNER JOIN SZL010 ZL ON ZL_FILIAL = ZE_FILIAL AND ZE_NUMBOB = ZL_NUMBOB AND ZE_PEDIDO = ZL_PEDIDO AND ZE_ITEM = ZL_ITEMPV AND ZL.D_E_L_E_T_ = ZE.D_E_L_E_T_ "
	_cQry += " INNER JOIN SC6010 C6 ON C6_FILIAL = D2_FILIAL AND C6_NUM = D2_PEDIDO AND C6_ITEM = D2_ITEMPV AND C6.D_E_L_E_T_ = D2.D_E_L_E_T_ "
	_cQry += " WHERE D2_FILIAL = '"+ cFilialOrig + "' "
	_cQry += " AND D2_DOC = '" + cDocumen + "' "
	_cQry += " AND D2_SERIE = '" + cSeri + "' "
	_cQry += " AND LEFT(DB_LOCALIZ,1) = 'B' "//Somente Bobinas
	_cQry += " AND ZE_STATUS = 'F' " //Somente Faturadas
	_cQry += " AND DB.D_E_L_E_T_ = ' ' " 
		
	_aAconds := U_QryArr(_cQry)
	
	for nX := 1 to len(_aAconds)
		if empty(_aAconds[nX, 4])
			_aAconds[nX, 4] := U_CBRZZPV(cFilialOrig,_aAconds[nX, 6],_aAconds[nX, 7])
		endif
	next nX
	
	If Len (_aAconds) >= 1
		TrocaEtiq(_aAconds)
	EndIf
Return()

/*/{Protheus.doc} LibEst
//TODO Realiza a liberação dos pedidos.
@author juliana.leme
@since 18/04/2018
@version 1.0
@param aDadosPed, array, descricao
@type function
/*/
Static Function LibEst(aDadosPed)
	Local _nCtArr := 1
	Local _nQuant	:= 0
	Local _nQtAlib	:= 0
	
	For _nCtArr := 1 to Len(aDadosPed)
		If Empty(aDadosPed[_nCtArr,5])
			// Não tem pedido a ser liberado o estoque
			Loop
		EndIf

		DbSelectArea("SC9")
		DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
		DbSeek(xFilial("SC9")+aDadosPed[_nCtArr,5],.F.)
		_nQuant := (aDadosPed[_nCtArr,4]) // Quantidade a liberar

		Do While SC9->C9_FILIAL == xFilial("SC9") .And. _nQuant > 0 .And. ;
			SC9->(C9_PEDIDO+C9_ITEM) == aDadosPed[_nCtArr,5] .And. SC9->(!Eof())
			If (SC9->C9_BLCRED+SC9->C9_BLEST) == "  02"
				DbSelectArea("SBF")
				DbSetOrder(1) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
				DbSeek(xFilial("SBF")+SC9->C9_LOCAL+aDadosPed[_nCtArr,2]+SC9->C9_PRODUTO,.F.)
				If SBF->(!Eof()) .And. (SBF->BF_QUANT-SBF->BF_EMPENHO) > 0 .And. SBF->BF_EMPENHO >= 0
					_nQtAlib := Min(_nQuant,(SBF->BF_QUANT-SBF->BF_EMPENHO))
					_nQuant  -= _nQtAlib
					aDadosPed[_nCtArr,3] += _nQtAlib

							// Atenção: O 11ro parâmetro deve ser diferente em cada chamada da função CDLibEst para poder
							// identificar a origem da liberação. Esta informação será gravada no campo DC_TPLIB.
							// Incluir este comentário em todas as chamadas da função quando for LIBERAÇÃO.
					U_CDLibEst("L",SC9->C9_PRODUTO,_nQtAlib,SC9->C9_LOCAL,aDadosPed[_nCtArr,2],SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN, ,  ,"D",.F.)

					DbSeek(xFilial("SC9")+aDadosPed[_nCtArr,5],.F.)
				Else
					SC9->(DbSkip())
				EndIf
			Else
				SC9->(DbSkip())
			EndIf
		EndDo
	Next
Return


Static Function ValidPerg(cOpcao)
	Local _aArea 	:= GetArea()
	Local aRegs		:={}
	Local cPerg		:= ""
	
	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))
	
	//Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3/GRPSXG
	If cOpcao == "1"
		aAdd(aRegs,{cPerg,"01","Sére da Nota Fiscal          ?","mv_ch1","C",03,0,0,"G","","MV_XPAR01","","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"02","Nro. da Nota Fiscal          ?","mv_ch2","C",09,0,0,"G","","MV_XPAR02","","","","","","","","","","","","","","","",""})
		aAdd(aRegs,{cPerg,"03","Armazém de Entrada           ?","mv_ch3","C",02,0,0,"G","","MV_XPAR03","","","","","","","","","","","","","","","","024"})
	Else
		aAdd(aRegs,{cPerg,"01","Qtde. de Replicas da Nota    ?","mv_ch1","N",03,0,0,"G","","MV_XPAR01","","","","","","","","","","","","","","","",""})
	EndIf
	For i := 1 To Len(aRegs) 
		If ! DbSeek(cPerg+aRegs[i,2])
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
			SX1->X1_GRPSXG  := aRegs[i,27]
			MsUnlock()
			DbCommit()
		EndIf
	Next
	RestArea(_aArea)
Return(.T.)


User Function SF1100I()
	// Ponto de Entrada executado após a Gravação de todos os dados da nota fiscal de entrada
	Local   aSize    := {}
	Local   aButtons := {}
	Local _cZZPVOri	:= ""
	Private cPerg    := "CDFT20_1"
	Private _aAreaAt := GetArea()
	Private _aAreaF1 := SF1->(GetArea())
	Private _aAreaD1 := SD1->(GetArea())
	
	//EDVAR - INICIO
	//->variaveis de browse para complemento de importacao
	Private aHeadDI 	:= {}		// aHeader Sped-Nfe e Sped-Fiscal - TAG DI
	Private aColsDI 	:= {} 		// aCols Sped-Nfe e Sped-Fiscal - TAG DI
	Private nDI			:= 0
	Private _oGetDI			    // NewGet Sped-Nfe e Sped-Fiscal - TAG DI
	Private aCols     	:= {}
	Private aHeader   := {}
	Private n		  		:= 1
	Private _cMens	  	:= space(200)
	//EDVAR - FIM
	
	//ATUALIZA BANCO/AGENCIA/CONTA DO SE2
	
	_aAreaE2 := SE2->(GetArea())
	_cSE2Tip := SE2->E2_TIPO
	
	// Loop para atualizar todas parcelas
	SE2->(DbSetOrder(1))
	SE2->(dbSeek(xFilial("SE2") + SF1->F1_PREFIXO + SF1->F1_DOC,.F.))
	Do While SE2->(!Eof()) .And. SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM  == ;
		xFilial("SE2") +SF1->F1_PREFIXO+ SF1->F1_DOC
	
		If Alltrim(SE2->E2_ORIGEM) == "MATA100" .And.;
			SE2->E2_TIPO + SE2->E2_FORNECE + SE2->E2_LOJA == _cSE2Tip + SF1->F1_FORNECE + SF1->F1_LOJA
	
			RecLock("SE2",.F.)
			If !Empty(SA2->A2_BANCO)
				SE2->E2_BANCO 	   := SA2->A2_BANCO
				SE2->E2_AGENCIA    := SA2->A2_AGENCIA
				SE2->E2_DVAGENC    := SA2->A2_DVAGENC
				SE2->E2_NUMCON     := SA2->A2_NUMCON
			EndIf
			SE2->E2_FLUXO := If(SA2->A2_FLUXO=="N","N","S")
			MsUnlock()
		EndIf
		SE2->(dbSkip())
	EndDo
	RestArea(_aAreaE2)
	
	If (SF1->F1_FORMUL == "S") .AND. (SF1->F1_EST = "EX") // Formulário próprio
		// Abrir tela para digitação das observações
		DbSelectArea("CD5")
		//DbSetOrder(1)	// CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_DOCIMP+CD5_NADIC
		DbSetOrder(4) 		// CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_ITEM
		_nTpImpor := 0 // Gets Normais
		nOpca := 0
		aButtons := {}
		aAdd(aButtons,{"CRITICA"   ,{|| _nTpImpor  := 0,oDlg:End() }, "Editar Observações"})
		aAdd(aButtons,{"EDITABLE"  ,{|| _nTpImpor  := 1,oDlg:End() }, "Importar Catodo NF Matriz"})
		aAdd(aButtons,{"EDIT_OCEAN",{|| _nTpImpor  := 2,oDlg:End() }, "Importar Catodo NF Transporte"})
		aAdd(aButtons,{"S4WB005N"  ,{|| _nTpImpor  := 3,oDlg:End() }, "Importar PVC"})
		aSize := MsAdvSize()
		_nTamObs := Len(CD5->CD5_OBS1)
		Do While .T.
	
			DEFINE MSDIALOG oDlg TITLE OemToAnsi("Mensagem Complementar da Nota Fiscal de Entrada") From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	
			@  030,31 SAY "Informações Complementares da Nota " + SF1->F1_DOC SIZE 163,10
			If nOpca == 0
				DbSelectArea("CD5")
				DbSetOrder(4) 		// CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_ITEM
	
				If DbSeek(xFilial("CD5")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.F.)
					_cObs1 := Space(_nTamObs)
					_cObs2 := Space(_nTamObs)
					_cObs3 := Space(_nTamObs)
					_cObs4 := Space(_nTamObs)
					_cObs5 := Space(_nTamObs)
					_cObs6 := Space(_nTamObs)
	
					// Carrega o CD5 PARA AS VATIÁVEIS
					//Do While CD5->CD5_FILIAL == xFilial("CD5") .And. CD5->CD5_DOC    == SF1->F1_DOC .And. CD5->CD5_SERIE  == SF1->F1_SERIE .And. CD5->(!Eof())
					If Empty(_cObs1)
						_cObs1 := CD5->CD5_OBS1
					ElseIf Empty(_cObs2)
						_cObs2 := CD5->CD5_OBS2
					ElseIf Empty(_cObs3)
						_cObs3 := CD5->CD5_OBS3
					ElseIf Empty(_cObs4)
						_cObs4 := CD5->CD5_OBS4
					ElseIf Empty(_cObs5)
						_cObs5 := CD5->CD5_OBS5
					ElseIf Empty(_cObs6)
						_cObs6 := CD5->CD5_OBS6
					EndIf
				Else
					If _nTpImpor == 0 // Gets Normais
						_cObs1 := Space(_nTamObs)
						_cObs2 := Space(_nTamObs)
						_cObs3 := Space(_nTamObs)
						_cObs4 := Space(_nTamObs)
						_cObs5 := Space(_nTamObs)
						_cObs6 := Space(_nTamObs)
					ElseIf _nTpImpor == 1 // Importação de Catodo NF Matriz + 1 Get normal
						_cObs1 := Left("SISCOMEX R$       // PIS/PASEP R$            // COFINS R$" + Space(_nTamObs),_nTamObs)
						_cObs2 := Left("// NOTA FISCAL MATRIZ - SEM VALIDADE PARA O TRANSITO //" + Space(_nTamObs),_nTamObs)
						_cObs3 := Left("// ICMS DIferido conf.lei compl. 093/2001 e autoriz. SAT/SEFAZ/MS" + Space(_nTamObs),_nTamObs)
						_cObs4 := Left("// D.I.                Conhecimento:" + Space(_nTamObs),_nTamObs)
						_cObs5 := Left("// Desembaraço: SANTOS-SP     RODRIMAR" + Space(_nTamObs),_nTamObs)
						_cObs6 := Left("// Fatura Comercial: " + Space(_nTamObs),_nTamObs)
					ElseIf _nTpImpor == 2 // Importação de Catodo NF Transporte + 1 Get normal
						_cObs1 := Left("     a. REMESSA PARCIAL DA NOTA MATRIZ NRO.           de   /  /    " + Space(_nTamObs),_nTamObs)
						_cObs2 := Left("// ICMS DIferido conf.lei compl. 093/2001 e autoriz. SAT/SEFAZ/MS" + Space(_nTamObs),_nTamObs)
						_cObs3 := Left("// D.I.                Conhecimento: " + Space(_nTamObs),_nTamObs)
						_cObs4 := Left("// Desembaraço: SANTOS-SP   // Conteiner " + Space(_nTamObs),_nTamObs)
						_cObs5 := Left("// Fatura Comercial: " + Space(_nTamObs),_nTamObs)
						_cObs6 := Space(_nTamObs)
					ElseIf _nTpImpor == 3 // Importação de PVC + 1 Get normal
						_cObs1 := Left("ICMS = 18% s/R$              -> Valor R$" + Space(_nTamObs),_nTamObs)
						_cObs2 := Left("// (Conf. EMENDA CONSTITUCIONAL N. 33)" + Space(_nTamObs),_nTamObs)
						_cObs3 := Left("// PIS= 2,10% R$               // Cofins 9,65 % R$" + Space(_nTamObs),_nTamObs)
						_cObs4 := Left("// D.I.                de" + Space(_nTamObs),_nTamObs)
						_cObs5 := Left("// Desemb. na EADI/DRF/UMA. // EMBRAQUE TOTAL // Cl.Fisc. 3904.22.00" + Space(_nTamObs),_nTamObs)
						_cObs6 := Space(_nTamObs)
					EndIf
				EndIf
			EndIf
	
			//EDVAR - INICIO
			//->exibe informacoes complementares para o Sped-Fiscal
			@ 20,10 To 80,485 Title OemToAnsi("SPED NFe - Complemento de nota de importacao (DI)")
	
			//->Informacoes da DI
			AtuDI(@aHeadDI, @aColsDI)
			_oGetDI := MsNewGetDados():New(30,15,130,480,3,,,,,,1,,,,oDlg,aHeadDI,aColsDI)
	
			@  200,010 Say "Obs1: "	Size  45,10
			@  200,031 GET _cObs1  	SIZE 200, 10 Object o_cObs1
	
			@  220,010 Say "Obs2: "	Size  45,10
			@  220,031 GET _cObs2 	SIZE 200, 10
	
			@  240,010 Say "Obs3: "	Size  45,10
			@  240,031 GET _cObs3  	SIZE 200, 10
	
			@  260,010 Say "Obs4: "	Size  45,10
			@  260,031 GET _cObs4  	SIZE 200, 10 Object o_cObs4
	
			@  280,010 Say "Obs5: "	Size  45,10
			@  280,031 GET _cObs5  	SIZE 200, 10 Object o_cObs5
	
			@  300,010 Say "Obs6: "	Size  45,10
			@  300,031 GET _cObs6  	SIZE 200, 10
	
			ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,oDlg:End()},{||nOpca:=0,oDlg:End()},,aButtons)
	
			If nOpca == 1
				//->Analisa as informacoes da DI
				_lGrava := .T.
				If Len(aColsDI) > 0
					aCols := _oGetDI:aCols
					aHeader := _oGetDI:aHeader
					cMens := ""
	
					for nX := 1 to Len(aCols)
						If !aCols[nX,Len(aHeader)+1]
							If empty(aCols[nX,03])
								cMens += "Nro. do Documento de Importacao, "
							endIf
							If empty(aCols[nX,04])
								cMens += "Data do Documento de Importacao, "
							endIf
							If empty(aCols[nX,11])
								cMens += "Local do Desembaraço, "
							endIf
							If empty(aCols[nX,12])
								cMens += "UF do Desembaraço, "
							endIf
							If empty(aCols[nX,13])
								cMens += "Data do Desembaraço, "
							endIf
							If empty(aCols[nX,14])
								cMens += "VTrans, "
							endIf
							If empty(aCols[nX,15])
								cMens += "INTERM, "
							endIf
							If empty(aCols[nX,16])
								cMens += "VAFRMM, "
							endIf
						endIf
					Next
					If !empty(cMens)
						cMens += "não foi(ram) informado(s)."+chr(13)
						cMens += "Se for nota 'mãe' as informacoes complementares são obrigatórias."
						_lGrava := MsgBox(cMens,"Confirma?","YesNo")
					endIf
				endIf
				If _lGrava //Dados da DI Ok ?
					If MsgBox("Informações Corretas ?","Confirma?","YesNo")
						Exit
					EndIf
				EndIf
			EndIf
		EndDo
		DbSelectArea("CD5")
		//DbSetOrder(1)	// CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_DOCIMP+CD5_NADIC
		DbSetOrder(4) 		// CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_ITEM
		Do While DbSeek(xFilial("CD5")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.F.)
			RecLock("CD5",.F.)
			CD5->CD5_FILIAL := "ZZ"
			MsUnLock()
			DBSkip()
		EndDo
	
		If nOpca == 1
			GravaComp(SF1->F1_DOC,.T.)
			If Inclui
				ValidPerg("2")
	
				Do While .T.
					If !Pergunte(cPerg,.T.)
						Exit
					EndIf
					If MV_PAR01 <= 0
						Exit
					EndIf
					If MsgBox("Informações Corretas ?","Confirma?","YesNo")
						Processa({|| GeraNota(MV_PAR01)})
						Exit
					EndIf
				EndDo
			EndIf
		EndIf
		RestArea(_aAreaF1)
		RestArea(_aAreaD1)
		RestArea(_aAreaAt)
	EndIf
	
	If !Empty(SF1->F1_OBSTRF)
		// F1_OBSTRF tem -> SF2->F2_FILIAL+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA
		// Ponto de Entrada para fazer a distribuição das quantidades das notas de entrada por transferência
	
		_aLiber := {} // Pedidos do armazém 10 a liberar {Pedido+Item,Aconcic.,Quantidade}
	
		If xFilial("SF1") == "01" // Estou na Matriz
			_cFilOrig := "02"
		ElseIf xFilial("SF1") == "02" // Estou na Filial 3 Lagoas
			_cFilOrig := "01"
		EndIf
	
		_Chave := AllTrim(SF1->F1_OBSTRF)
	
		DbSelectArea("SDA")
		DbSetOrder(1) //DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIfOR+DA_LOJA
	
		DbSelectArea("SDB")
		DbSetOrder(1) //DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIfOR+DB_LOJA+DB_ITEM
	
		DbSelectArea("SB1")
		DbSetOrder(1)
	
		DbSelectArea("SF2")
		DbSetOrder(1) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
	
		DbSelectArea("SD2")
		DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	
		DbSelectArea("SD1")
		DbSetOrder(1) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.F.)
		Do While SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == ;
			xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA .And. SD1->(!Eof())
	
			_aAreaSD1N := SD1->(GetArea())
			DbSelectArea("SDA") ////DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIfOR+DA_LOJA
			If DbSeek(xFilial("SDA")+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA,.F.)
	
				If SDA->DA_SALDO > 0.00 // Tem algo a distribuir
	
					// Procuro o item da saIda no SD2 na filial de origem
					DbSelectArea("SD2") // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	
					// Alteração de 24/01/14
					// Como o produto enviado da matriz para a filial ou vice-versa pode ter o "I" de importado,
					// os códigos do SD1 com SD2 podem ser dIferentes.
					// Então procuro somente a _Chave e no loop acho o item, comparando também o código do produto
					If !DbSeek(_Chave+SD1->D1_COD+SD1->D1_ITEM,.F.)
						DbSeek(_Chave,.F.)
						Do While SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == _Chave .And. SD2->(!Eof())
							If AllTrim(SD2->D2_ITEM) == AllTrim(SD1->D1_ITEM) .And. AllTrim(SD1->D1_COD) $ SD2->D2_COD .And.;
								Right(AllTrim(SD2->D2_COD),1) == "I"
								Exit
							EndIf
							DbSkip()
						EndDo
					EndIf
	
					If SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == _Chave .And.;
						AllTrim(SD2->D2_ITEM) == AllTrim(SD1->D1_ITEM) .And. SD2->(!Eof())
	
						// Procuro no SDB como saiu o item da origem
						DbSelectArea("SDB") //DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIfOR+DB_LOJA+DB_ITEM
						DbSetOrder(1) //DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIfOR+DB_LOJA+DB_ITEM
						If DbSeek(_cFilOrig+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA,.F.)
	
							_cLocaliz := SDB->DB_LOCALIZ
							
							//Adiciono em Array para fazer as liberações dos pedidos
							_cZZPVOri := U_CBRZZPV(_cFilOrig,SD2->D2_PEDIDO,SD2->D2_ITEMPV)
							If ! Empty(_cZZPVOri) 
								aAdd(_aDadosPed, {SDB->DB_PRODUTO,SDB->DB_LOCALIZ,SDB->DB_QUANT,SDB->DB_QUANT,_cZZPVOri,"00000000000"})
							EndIf
	
							// VerIficar se tem o cadastro da localização no SBE
							DbSelectArea("SBE")
							DbSetOrder(1)
							If !DbSeek(xFilial("SBE") + SD1->D1_LOCAL + _cLocaliz,.F.)
								_cAcon := Left(_cLocaliz,1)
								_cDesLo :=  ""
								If _cAcon == "T"
									_cDesLo :=  "Retalho de "
								ElseIf _cAcon == "B"
									_cDesLo :=  "Bobina de "
								ElseIf _cAcon == "M"
									_cDesLo :=  "Carretel de Mad.de "
								ElseIf _cAcon == "C"
									_cDesLo :=  "Carretel de "
								ElseIf _cAcon == "R"
									_cDesLo :=  "Rolo de "
								ElseIf _cAcon == "L"
									_cDesLo :=  "Blister de "
								EndIf
								_cLanc := Str(Val(Substr(_cLocaliz,2,5)),5)
								SB1->(DbSeek(xFilial("SB1")+SD2->D2_COD,.F.))
								//_cDesLo += _cLanc + " metros"
								_cDesLo += _cLanc + " " + Posicione("SAH",1,xFilial("SAH")+SB1->B1_UM,"AH_DESCPO")
	
								RecLock("SBE",.T.)
								SBE->BE_FILIAL   := xFilial("SBE")
								SBE->BE_LOCAL    := SD1->D1_LOCAL
								SBE->BE_LOCALIZ  := _cLocaliz
								SBE->BE_DESCRIC  := _cDesLo
								SBE->BE_PRIOR    := "ZZZ"
								SBE->BE_STATUS   := "1"
								MsUnLock()
							EndIf
	
							DbSelectArea("SDA")
							_RegSDA := Recno()
							aCAB  := {	{"DA_PRODUTO" ,SDA->DA_PRODUTO             , nil},;
										{"DA_QTDORI"  ,SDA->DA_QTDORI              , nil},;
										{"DA_SALDO"   ,SDA->DA_SALDO               , nil},;
										{"DA_DATA"    ,SDA->DA_DATA                , nil},;
										{"DA_LOCAL"   ,SDA->DA_LOCAL               , nil},;
										{"DA_DOC"     ,SDA->DA_DOC                 , nil},;
										{"DA_ORIGEM"  ,SDA->DA_ORIGEM              , nil},;
										{"DA_NUMSEQ"  ,SDA->DA_NUMSEQ              , nil},;
										{"DA_QTSEGUM" ,SDA->DA_QTSEGUM             , nil},;
										{"DA_QTDORI2" ,SDA->DA_QTDORI2             , nil}}
	
							aITENS:={{	{"DB_ITEM"    , "0001"                     , nil},;
										{"DB_LOCALIZ" , _cLocaliz                  , nil},;
										{"DB_QUANT"   , SDA->DA_SALDO              , nil},;
										{"DB_DATA"    , SDA->DA_DATA               , nil},;
										{"DB_ESTORNO" ," "                         , nil} }}
	
							msExecAuto({|x,y|mata265(x,y)},aCAB,aITENS)
						EndIf
					EndIf
					DbSelectArea("SD1")
				EndIf
			EndIf
			RestArea(_aAreaSD1N)
			// Verificar se entrou para código de importado e transferir para código normal
			_D1_COD := AllTrim(SD1->D1_COD)
			If Right(_D1_COD,1) == "I" .And. Alltrim(SD1->D1_COD) # "2000000006I"
				// Verificar se tem o código normal
				_D1_COD := Left(Left(_D1_COD,Len(_D1_COD)-1) + Space(Len(SD1->D1_COD)),Len(SD1->D1_COD))
				SB1->(DbSelectArea("SB1"))
				If SB1->(DbSeek(xFilial("SB1")+_D1_COD,.F.))
					// Fazer transferência para o código normal
					_cLocaliz := ""
					// Se o produto controla localização e for importado, transferir para o código normal
					
					DbSelectArea("SDB") //DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIfOR+DB_LOJA+DB_ITEM
					DbSetOrder(1) //DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIfOR+DB_LOJA+DB_ITEM
					If DbSeek(xFilial("SDB")+SD1->D1_COD+SD1->D1_LOCAL+SD1->D1_NUMSEQ+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA,.F.)
						_cLocaliz := SDB->DB_LOCALIZ
					EndIf
					// Faz a transferência da quantidade do importado para o normal
					
					aItens		:= 	{}
					aAdd(aItens,{SD1->D1_NUMSEQ,dDatabase})
					
					aAdd(aItens,{SD1->D1_COD,;	//cProduto,;
								 SB1->B1_DESC,;	//cDescProd,;
								 SB1->B1_UM,; 	//cUM Origem
								 SD1->D1_LOCAL,;//cArmOri Origem
								 _cLocaliz,;	//cEndOri Origem
								 _D1_COD,;		//cProduto,;
								 SB1->B1_DESC,;	//cDescProd,;
								 SB1->B1_UM,; 	//cUM Origem
								 SD1->D1_LOCAL,;//cArmDest Destino
								 _cLocaliz,;	//cEndDest Destino,;
								 "",;			//cNumSer Num Serie
								 "",;			//cLote
								 "",;			//SubLote
								 StoD(""),;		//cValidade
								 0,;			//nPoten
								 SD1->D1_QUANT,;//nQuant
								 0,;			//cQtSegUm
								 "",;			//Estornado
								 "",;			//cNumSeq
								 "",; 			//cLoteDest
								 StoD(""),;		//cValDest
								 "",;			//ItemGrade
								 ""})			//Observação
					lMsErroAuto := .F.
					MSExecAuto({|x,y| mata261(x,y)},aItens,3) // 3-Inclusão 5-Estorno
					If lMsErroAuto
						Alert("Erro na transferência do Item " + SD1->D1_ITEM + ", Transferir manualmente.")
					EndIf
				EndIf
			EndIf
	
			RestArea(_aAreaSD1N)
			DbSkip()
		EndDo
		RestArea(_aAreaF1)
		RestArea(_aAreaD1)
		RestArea(_aAreaAt)
EndIf


If Type("_aRtInDtr") == "A"
	//If Len(_aRtInDtr) > 0
		// A variável _aRtInDtr foi criada na Static Function RetIndl() que trata o retorno de industrialização
		// e define os produtos em seus acondicionamentos, bem como as OPs devem ser produzidas.
		// _aRtInDtr -> { Produto, Acondic, Quantidade, Quant.Original, Pedido+Item Origem, Elem. 09 do _aItensB}


		// PeRcorrer o SD1 e dar a produção das OPs
		DbSelectArea("SD1")
		DbSetOrder(1) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.F.)
		Do While SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == ;
			xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA .And. SD1->(!Eof())

			/*
			Atenção: o MATA265 desposiciona o SD1.
			Por isso tem que guardar a área do SD1 e restaurar antes do dbskip
			*/
			_aAreaSD1N := GetArea()

			If !Empty(SD1->D1_OP)
				DbSelectArea("SC2")
				DbSetOrder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
				DbSeek(xFilial("SC2") + SD1->D1_OP,.F.)
				If SC2->(!Eof()) .And. (SC2->C2_QUANT > SC2->C2_QUJE)
					DbSelectArea("SD3")
					_aVetor:={	{"D3_TM"      , "006"					,NIL},;
								{"D3_COD"     , SC2->C2_PRODUTO       ,NIL},;
								{"D3_UM"      , SC2->C2_UM            ,NIL},;
								{"D3_QUANT"   , (SC2->C2_QUANT-SC2->C2_QUJE),NIL},;
								{"D3_OP"      , SD1->D1_OP			,NIL},;
								{"D3_LOCAL"   , SC2->C2_LOCAL         ,NIL},;
								{"D3_EMISSAO" , dDataBase             ,NIL},;
								{"D3_PARCTOT" , "T"					,NIL},;
								{"D3_PERDA"   , 0                     ,NIL}}
					lMsErroAuto := .F.
					MSExecAuto({|x,y| Mata250(x,y)},_aVetor,3)
					// Efetuar a Distribuição dos materias produzidos
					If !lMsErroAuto
						DbSelectArea("SD3")
						DbSetOrder(1)
						DbSeek(xFilial("SD3")+PadR(SD1->D1_OP, TamSX3("D3_OP")[1])+SC2->C2_PRODUTO+SC2->C2_LOCAL,.F.)

						// Estou no SD3 criado para a produção
						// Localizo o SDA para efetuar as distribuições
						DbSelectArea("SDA")
						DbSetOrder(1) // DA_FILIAL+DA_PRODUTO+DA_LOCAL+DA_NUMSEQ+DA_DOC+DA_SERIE+DA_CLIFOR+DA_LOJA
						If DbSeek(xFilial("SDA") + SD3->D3_COD + SD3->D3_LOCAL + SD3->D3_NUMSEQ,.F.)
							aCAB  := {	{"DA_PRODUTO" ,SDA->DA_PRODUTO             , nil},;
										{"DA_QTDORI"  ,SDA->DA_QTDORI              , nil},;
										{"DA_SALDO"   ,SDA->DA_SALDO               , nil},;
										{"DA_DATA"    ,SDA->DA_DATA                , nil},;
										{"DA_LOCAL"   ,SDA->DA_LOCAL               , nil},;
										{"DA_DOC"     ,SDA->DA_DOC                 , nil},;
										{"DA_ORIGEM"  ,SDA->DA_ORIGEM              , nil},;
										{"DA_NUMSEQ"  ,SDA->DA_NUMSEQ              , nil},;
										{"DA_QTSEGUM" ,SDA->DA_QTSEGUM             , nil},;
										{"DA_QTDORI2" ,SDA->DA_QTDORI2             , nil}}
	
							_nADistr := SDA->DA_SALDO
							_cDbItem := Replicate("0",Len(SDB->DB_ITEM))
							aITENS:={}
							For _nCtArr := 1 to Len(_aRtInDtr)
								// _aRtInDtr -> { Produto, Acondic, Quantidade, Quant.Original, Pedido+Item Origem, Elem. 09 do _aItensB}
								If _aRtInDtr[_nCtArr,1] == SDA->DA_PRODUTO .And. _aRtInDtr[_nCtArr,3] > 0 .And. ;
									_nADistr > 0 .And. AllTrim(_aRtInDtr[_nCtArr,6]) == AllTrim(SD1->D1_OP)
									// _aRtInDtr -> { Produto, Acondic, Quantidade, Quant.Original, Pedido+Item Origem, Elem. 09 do _aItensB}
	
									DbSelectArea("SBE")
									DbSetOrder(1)
									If !DbSeek(xFilial("SBE") + SC2->C2_LOCAL + _aRtInDtr[_nCtArr,2],.F.)
										_cAcon := Left(_aRtInDtr[_nCtArr,2],1)
	
										If _cAcon == "T"
											_cDesLo :=  "Retalho de "
										ElseIf _cAcon == "B"
											_cDesLo :=  "Bobina de "
										ElseIf _cAcon == "M"
											_cDesLo :=  "Carretel de Mad.de "
										ElseIf _cAcon == "C"
											_cDesLo :=  "Carretel de "
										ElseIf _cAcon == "R"
											_cDesLo :=  "Rolo de "
										ElseIf _cAcon == "L"
											_cDesLo :=  "Blister de "
										EndIf
										//_cDesLo +=  Str(Val(Substr(_aRtInDtr[_nCtArr,2],2,5)),5) + " metros"
										SB1->(DbSetOrder(1))
										SB1->(DbSeek(xFilial("SB1")+SDA->DA_PRODUTO,.F.))
										_cDesLo +=  Str(Val(Substr(_aRtInDtr[_nCtArr,2],2,5)),5) + " metros"
	
										RecLock("SBE",.T.)
										SBE->BE_FILIAL   := xFilial("SBE")
										SBE->BE_LOCAL    := SC2->C2_LOCAL
										SBE->BE_LOCALIZ  := _aRtInDtr[_nCtArr,2]
										SBE->BE_DESCRIC  := _cDesLo
										SBE->BE_PRIOR    := "ZZZ"
										SBE->BE_STATUS   := "1"
										MsUnLock()
									EndIf
	
									_nQtDist := Min(_aRtInDtr[_nCtArr,3],_nADistr)
									_aRtInDtr[_nCtArr,3] -= _nQtDist
									_nADistr             -= _nQtDist
									_cDbItem := Soma1(_cDbItem)
									aITEM:={{"DB_ITEM"    , _cDbItem            , nil},;
											{"DB_LOCALIZ" , _aRtInDtr[_nCtArr,2], nil},;
											{"DB_QUANT"   , _nQtDist            , nil},;
											{"DB_DATA"    , dDataBase           , nil},;
											{"DB_ESTORNO" ," "                  , nil} }
									Aadd(aITENS,aITEM)
								EndIf
							Next
							If Len(aITENS) > 0
								lMsErroAuto:=.f.
								msExecAuto({|x,y|mata265(x,y)},aCAB,aITENS)  // Este comendo muda o posicionamento do SD1
								If lMsErroAuto
									// MostraErro()
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
			//
			// Efetuar a liberação dos pedidos de vendas envolvidos nesse retorno
			If SUPERGETMV("ZZ_EMPENT",, .F.)
				For _nCtArr := 1 to Len(_aRtInDtr)

					If Empty(_aRtInDtr[_nCtArr,5])
						// Não tem pedido a ser liberado o estoque
						Loop
					EndIf
					// _aRtInDtr -> { Produto, Acondic, Quantidade, Quant.Original, Pedido+Item Origem, Elem. 09 do _aItensB}
					DbSelectArea("SC9")
					DbSetOrder(1) // C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
					DbSeek(xFilial("SC9")+_aRtInDtr[_nCtArr,5],.F.)
					_nQuant := (_aRtInDtr[_nCtArr,4] - _aRtInDtr[_nCtArr,3]) // Quantidade a liberar

					Do While SC9->C9_FILIAL == xFilial("SC9") .And. _nQuant > 0 .And. ;
						SC9->(C9_PEDIDO+C9_ITEM) == _aRtInDtr[_nCtArr,5] .And. SC9->(!Eof())
						If (SC9->C9_BLCRED+SC9->C9_BLEST) == "  02"
							DbSelectArea("SBF")
							DbSetOrder(1) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
							DbSeek(xFilial("SBF")+SC9->C9_LOCAL+_aRtInDtr[_nCtArr,2]+SC9->C9_PRODUTO,.F.)
							If SBF->(!Eof()) .And. (SBF->BF_QUANT-SBF->BF_EMPENHO) > 0 .And. SBF->BF_EMPENHO >= 0
								_nQtAlib := Min(_nQuant,(SBF->BF_QUANT-SBF->BF_EMPENHO))
								_nQuant  -= _nQtAlib
								_aRtInDtr[_nCtArr,3] += _nQtAlib

								// Atenção: O 11ro parâmetro deve ser diferente em cada chamada da função CDLibEst para poder
								// identificar a origem da liberação. Esta informação será gravada no campo DC_TPLIB.
								// Incluir este comentário em todas as chamadas da função quando for LIBERAÇÃO.
								U_CDLibEst("L",SC9->C9_PRODUTO,_nQtAlib,SC9->C9_LOCAL,_aRtInDtr[_nCtArr,2],;
								SC9->C9_PEDIDO,SC9->C9_ITEM,SC9->C9_SEQUEN, ,  ,"D",.F.)
								DbSeek(xFilial("SC9")+_aRtInDtr[_nCtArr,5],.F.)
							Else
								SC9->(DbSkip())
							EndIf
						Else
							SC9->(DbSkip())
						EndIf
					EndDo
				Next
			EndIf

			/*
			Atenção: o MATA265 desposiciona o SD1.
			Por isso tem que guardar a área do SD1 e restaurar ante do dbskip
			*/
			RestArea(_aAreaSD1N)
			SD1->(DbSkip())
		EndDo
	//EndIf
	_aRtInDtr := {}
	// A variável _aRtInDtr foi criada na Static Function RetIndl() que trata o retorno de industrialização
	// e define os produtos em seus acondicionamentos, bem como as OPs devem ser produzidas.
	// _aRtInDtr -> { Produto, Acondic, Quantidade, Quant.Original, Pedido+Item Origem, Elem. 09 do _aItensB}
EndIf
RestArea(_aAreaF1)
RestArea(_aAreaD1)
RestArea(_aAreaAt)
Return(.T.)
*
********************************
Static Function GeraNota(nVezes)
********************************
*
Local _nI        	:= 1
Local _cSerie    	:= SF1->F1_SERIE
Local _cNumNota  	:= ""
Local _cForn     	:= SF1->F1_FORNECE
Local _cLja      	:= SF1->F1_LOJA
Local _cTip      	:= SF1->F1_TIPO
Local _dEmiss    	:= SF1->F1_EMISSAO
Local _cEst         := SF1->F1_EST
Local _cEspec       := SF1->F1_ESPECIE
Local _dDigit       := SF1->F1_DTDIGIT
Local _dReceb       := SF1->F1_RECBMTO
Local _cD1_ITEM	    := SD1->D1_ITEM
Local _cD1_COD 	    := SD1->D1_COD
//Local _cD1_POSIPI   := SD1->D1_POSIPI
Local _cD1_DESCRI	:= SD1->D1_DESCRI
Local _cD1_UM	    := SD1->D1_UM
Local _cD1_QUANT	:= SD1->D1_QUANT
Local _cD1_VUNIT	:= SD1->D1_VUNIT
Local _cD1_TOTAL	:= SD1->D1_TOTAL
Local _cD1_LOCAL	:= SD1->D1_LOCAL
Local _cD1_TP	    := SD1->D1_TP
Local _cD1_CLASS	:= SD1->D1_CLASFIS
Local _cD1_X_ADIC	:= SD1->D1_X_ADIC
Local _cD1_X_SQADI	:= SD1->D1_X_SQADI
Local _cD1_X_FABR	:= SD1->D1_X_FABR
Local _cD1_X_BSII	:= SD1->D1_X_BSII
Local _cD1_X_VLII	:= SD1->D1_X_VLII
Local _cD1_X_DPAD	:= SD1->D1_X_DPAD
Local _cD1_X_VIOF	:= SD1->D1_X_VIOF


SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL

DbSelectArea("SX5")
DbSetOrder(1)//	X5_FILIAL+X5_TABELA+X5_CHAVE

DbSelectArea("SD1")
DbSetOrder(1)  //D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM

_cObsPri := Left("a. REMESSA PARCIAL DA NOTA MATRIZ NRO. "+SF1->F1_DOC + "          de " + Dtoc(SF1->F1_EMISSAO) +"  " + Space(_nTamObs),_nTamObs)
_cObs2 := Left("// ICMS DIferido conf.lei compl. 093/2001 e autoriz. SAT/SEFAZ/MS" + Space(_nTamObs),_nTamObs)
_cObs3 := _cObs4
_cObs4 := Left(Left(_cObs5,30) + "// Conteiner " + Space(_nTamObs),_nTamObs)
_cObs5 := _cObs6
_cObs6 := Space(_nTamObs)

For _nI := 1 to nVezes
	_cNumNota  := ""
	_cObs1 := Left(AllTrim(Str(_nI)) + _cObsPri,_nTamObs)
	Do While Empty(_cNumNota)

		DbSelectArea("SX5")
		dbSeek(xFilial("SX5")+"01"+_cSerie)

		_cNumNota  := Alltrim(SX5->X5_DESCRI)
		RecLock("SX5",.F.)
		SX5->X5_DESCRI  := Soma1(Alltrim(_cNumNota))
		SX5->X5_DESCSPA := Soma1(Alltrim(_cNumNota))
		SX5->X5_DESCENG := Soma1(Alltrim(_cNumNota))
		MsUnlock()

		If SF2->(DbSeek(xFilial("SF2") + _cNumNota + _cSerie,.F.))
			_cNumNota  := ""
			Loop
		EndIf

		DbSelectArea("SF1")
		DbSetOrder(1) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO

		DbSeek(xFilial("SF1")+_cNumNota+_cSerie,.F.)
		Do While SF1->F1_FILIAL==xFilial("SF1") .And. SF1->F1_DOC+SF1->F1_SERIE == _cNumNota+_cSerie .And. SF1->(!Eof())
			If SF1->F1_FORMUL == "S"
				Exit
			EndIf
			SF1->(DbSkip())
		EndDo

		If SF1->F1_FILIAL==xFilial("SF1") .And. SF1->F1_DOC+SF1->F1_SERIE == _cNumNota+_cSerie .And. SF1->(!Eof()) .And. SF1->F1_FORMUL == "S"
			_cNumNota  := ""
			Loop
		EndIf
	EndDo

	RecLock("SF1",.T.)
	SF1->F1_FILIAL  := xFilial("SF1")
	SF1->F1_DOC     := _cNumNota
	SF1->F1_SERIE   := _cSerie
	SF1->F1_FORMUL  := "S"
	SF1->F1_FORNECE := _cForn
	SF1->F1_LOJA    := _cLja
	SF1->F1_EMISSAO := _dEmiss
	SF1->F1_TIPO    := _cTip
	SF1->F1_EST     := _cEst
	SF1->F1_ESPECIE := _cEspec
	SF1->F1_DTDIGIT := _dDigit
	SF1->F1_RECBMTO := _dReceb
	MsUnLock()

	DbSelectArea("SD1")
	RecLock("SD1",.T.)
	SD1->D1_FILIAL  := xFilial("SD1")
	SD1->D1_SERIE   := _cSerie
	SD1->D1_DOC     := _cNumNota
	SD1->D1_FORMUL  := "S"
	SD1->D1_TIPO    := _cTip
	SD1->D1_FORNECE := _cForn
	SD1->D1_LOJA    := _cLja
	SD1->D1_EMISSAO := _dEmiss
	SD1->D1_DTDIGIT := dDataBase
	SD1->D1_ITEM    := _cD1_ITEM
	SD1->D1_COD     := _cD1_COD
	SD1->D1_DESCRI  := _cD1_DESCRI
	SD1->D1_UM      := _cD1_UM
	//    SD1->D1_POSIPI  := _cD1_POSIPI
	SD1->D1_QUANT   := _cD1_QUANT
	SD1->D1_VUNIT   := _cD1_VUNIT
	SD1->D1_TOTAL   := _cD1_TOTAL
	SD1->D1_LOCAL   := _cD1_LOCAL
	SD1->D1_TP      := _cD1_TP
	SD1->D1_CLASFIS := _cD1_CLASS
	SD1->D1_X_ADIC  := _cD1_X_ADIC
	SD1->D1_X_SQADI := _cD1_X_SQADI
	SD1->D1_X_FABR  := _cD1_X_FABR
	SD1->D1_X_BSII  := _cD1_X_BSII
	SD1->D1_X_VLII  := _cD1_X_VLII
	SD1->D1_X_DPAD  := _cD1_X_DPAD
	SD1->D1_X_VIOF  := _cD1_X_VIOF
	MsUnLock()

	DbSelectArea("CD5")
	GravaComp(_cNumNota,.F.)
Next
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ AtuDI    ³ Autor ³                        ³ Data ³ 19.08.10 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava as informacoes de complemento de DI.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AtuDI(aHeadDI,aColsDI,_nOpc)
Local nUsado2	:= 0
Local nI		:= 0

//->Limpa os dados carregados no aCols
aColsDI	:= {}
aHeadDI := {}

//->Monta tela da DI
nUsado2 := 0

//Aadd(aHeader,
//           {1-Descr.Campo,	2-Campo     	,3-Picture          ,4-Tam	,5-Decim,6-Validação						,7-Usado,8-Tipo,9-Arquivo,10-Contexto}
Aadd(aHeadDI,{"Item"        	,"CD5_ITEM"  	,"9999"             ,04		,0		,".F."       						,		,"C"	,})
Aadd(aHeadDI,{"Tp.Doc.Imp."		,"CD5_TPIMP" 	,"@!"               ,01		,0		,            						,		,"C"	,})
Aadd(aHeadDI,{"Doc.Imp"    		,"CD5_DOCIMP"	,"@!"               ,10		,0		,"u_ValTxt()"						,		,"C"	,}) // valid
Aadd(aHeadDI,{"Dt.Imp"     		,"CD5_X_DTDI"	,"@!"               ,08		,0		,            						,		,"D"	,})
Aadd(aHeadDI,{"Base Pis"   		,"CD5_BSPIS" 	,"@E 999,999,999.99",14		,2		,            						,		,"N"	,})
Aadd(aHeadDI,{"Aliq.Pis"   		,"CD5_ALPIS" 	,"@E 99.99"         ,04		,2		,            						,		,"N"	,})
Aadd(aHeadDI,{"Vl.Pis"     		,"CD5_VLPIS" 	,"@E 999,999,999.99",14		,2		,"u_ValTxt()"						,		,"N"	,}) // valid
Aadd(aHeadDI,{"Base Cof."  		,"CD5_BSCOF" 	,"@E 999,999,999.99",14		,2		,            						,		,"N"	,})
Aadd(aHeadDI,{"Aliq.Cof."  		,"CD5_ALCOF" 	,"@E 99.99"         ,04		,2		,            						,		,"N"	,})
Aadd(aHeadDI,{"Vl.Cof"     		,"CD5_VLCOF" 	,"@E 999,999,999.99",14		,2		,"u_ValTxt()"						,		,"N"	,}) // valid
Aadd(aHeadDI,{"Loc.Desemb."		,"CD5_X_LOCD"	,"@!"               ,15		,0		,"u_ValTxt()"						,		,"C"	,}) // valid
Aadd(aHeadDI,{"Uf.Desemb." 		,"CD5_X_UFDE"	,"@!"               ,02		,0		,"u_ValTxt()"						,		,"C"	,})
Aadd(aHeadDI,{"Dt.Desemb." 		,"CD5_X_DTDE"	,"@!"               ,08		,0		,            						,		,"D"	,})
Aadd(aHeadDI,{"Via Trans.DI" 	,"CD5_VTRANS"	,"@!"               ,01		,0		,"Pertence('1/2/3/4/5/6/7/8/9/10')"	,		,"C"	,})
Aadd(aHeadDI,{"Forma Import."	,"CD5_INTERM"	,"@!"               ,01		,0		,"Pertence('1/2/3')"				,		,"C"	,})
Aadd(aHeadDI,{"Valor AFRMM"		,"CD5_VAFRMM"	,"@E 999,999,999.99",14		,2		,            						,		,"N"	,})

nUsado2 := Len(aHeadDI)
aColsDI := {}

DbSelectArea("SD1")
DbSetOrder(1) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.F.)
Do While SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == ;
	xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA .And. SD1->(!Eof())


	AADD(aColsDI,Array(Len(aHeadDI)+1))

	DbSelectArea("CD5")
	DbSetOrder(4) // CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_ITEM
	If DbSeek(xFilial("CD5")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA+SD1->D1_ITEM,.F.)
		aColsDI[Len(aColsDI),01] := SD1->D1_ITEM
		aColsDI[Len(aColsDI),02] := CD5->CD5_TPIMP
		aColsDI[Len(aColsDI),03] := CD5->CD5_DOCIMP
		aColsDI[Len(aColsDI),04] := CD5->CD5_X_DTDI
		aColsDI[Len(aColsDI),05] := CD5->CD5_BSPIS
		aColsDI[Len(aColsDI),06] := CD5->CD5_ALPIS
		aColsDI[Len(aColsDI),07] := CD5->CD5_VLPIS
		aColsDI[Len(aColsDI),08] := CD5->CD5_BSCOF
		aColsDI[Len(aColsDI),09] := CD5->CD5_ALCOF
		aColsDI[Len(aColsDI),10] := CD5->CD5_VLCOF
		aColsDI[Len(aColsDI),11] := CD5->CD5_X_LOCD
		aColsDI[Len(aColsDI),12] := CD5->CD5_X_UFDE
		aColsDI[Len(aColsDI),13] := CD5->CD5_X_DTDE
		aColsDI[Len(aColsDI),14] := CD5->CD5_VTRANS
		aColsDI[Len(aColsDI),15] := CD5->CD5_INTERM
		aColsDI[Len(aColsDI),16] := CD5->CD5_VAFRMM
		aColsDI[Len(aColsDI),nUsado2+1] := .F.
		_cObs1 := CD5->CD5_OBS1
		_cObs2 := CD5->CD5_OBS2
		_cObs3 := CD5->CD5_OBS3
		_cObs4 := CD5->CD5_OBS4
		_cObs5 := CD5->CD5_OBS5
		_cObs6 := CD5->CD5_OBS6
	Else
		For nI := 1 To nUsado2
			aColsDI[Len(aColsDI),nI] := CriaVar(aHeadDI[nI,2],.T.)
		Next
		aColsDI[Len(aColsDI),01] := SD1->D1_ITEM
		aColsDI[Len(aColsDI),nUsado2+1] := .F.
	EndIf
	SD1->(DbSkip())
EndDo
aSort(aColsDI,,,{|x,y| x[01]<y[01]})
Return()
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GravaComp ³ Grava complemento -tabela CD5 - Sped-Fiscal      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function GravaComp(_cNumNota,lAcols)
Local cMens := ""
Local cNrDI := ""
Local nX

//->Efetua a gravacao das Informacoes da DI.
If Len(aColsDI) > 0
	aCols := _oGetDI:aCols
	For nX := 1 to Len(aCols)
		lTemSD1 := .F.
		DbSelectArea("SD1")
		DbSetOrder(1) // D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA+D1_COD+D1_ITEM
		DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA,.F.)
		Do While SD1->(!Eof()) .And. SD1->D1_FILIAL == xFilial("SD1") .And.;
			SD1->(D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
			If SD1->D1_ITEM == aCols[nX,01]
				lTemSD1 := .T.
				Exit
			EndIf
			SD1->(DbSkip())
		EndDo
		If lTemSD1
			If Empty(aCols[nX,03]) // Campo padrão CD5_DOCIMP
				dbSelectArea("CD5")
				DbSetOrder(4)	// CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_ITEM
				If dbSeek(xFilial("CD5") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)+aCols[nX,01],.F.)
					RecLock("CD5",.F.)
					DbDelete()
					MsUnLock()
				EndIf
			Else
				RecLock("SD1",.F.)
				SD1->D1_II := SD1->D1_X_VLII
				MsUnLock()
				dbSelectArea("CD5")
				DbSetOrder(4)	// CD5_FILIAL+CD5_DOC+CD5_SERIE+CD5_FORNEC+CD5_LOJA+CD5_ITEM
				If dbSeek(xFilial("CD5") + SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)+aCols[nX,01],.F.)
					RecLock("CD5",.F.)
				ElseIf DbSeek("ZZ",.F.)
					RecLock("CD5",.F.)
				Else
					RecLock("CD5",.T.)
				EndIf
				CD5->CD5_FILIAL		:= xFilial("CD5")
				CD5->CD5_DOC			:= _cNumNota
				CD5->CD5_SERIE		:= SF1->F1_SERIE
				CD5->CD5_ESPEC		:= SF1->F1_ESPECIE
				CD5->CD5_FORNEC		:= SF1->F1_FORNECE
				CD5->CD5_LOJA		:= SF1->F1_LOJA
				CD5->CD5_ITEM		:= SD1->D1_ITEM
				CD5->CD5_VTRANS		:= IIF(!Empty(aCols[nX,14]),aCols[nX,14],"1")
				CD5->CD5_INTERM		:= IIF(!Empty(aCols[nX,15]),aCols[nX,15],"1")
				CD5->CD5_VAFRMM		:= IIF(!Empty(aCols[nX,16]),aCols[nX,16],0)
				CD5->CD5_TPIMP		:= aCols[nX,03]
				CD5->CD5_CODEXP		:= SF1->F1_FORNECE
				CD5->CD5_LOJEXP		:= SF1->F1_LOJA
				CD5->CD5_NADIC		:= SD1->D1_X_ADIC
				CD5->CD5_SQADIC		:= SD1->D1_X_SQADI
				CD5->CD5_CODFAB		:= SD1->D1_X_FABR
				CD5->CD5_BCIMP		:= SD1->D1_X_BSII
				CD5->CD5_DSPAD      := SD1->D1_X_DPAD
				CD5->CD5_BCIMP 		:= If(SD1->D1_X_BSII==0.01,0.00,SD1->D1_X_BSII)
				CD5->CD5_VLRIOF		:= SD1->D1_X_VIOF
				CD5->CD5_DOCIMP		:= aCols[nX,03] // Campo usuário
				CD5->CD5_NDI		:= aCols[nX,03] // Campo padrão
				CD5->CD5_X_DTDI		:= aCols[nX,04] // Campo usuário
				CD5->CD5_DTDI		:= aCols[nX,04] // Campo padrão
				CD5->CD5_BSPIS		:= If(lAcols,aCols[nX,05],0)
				CD5->CD5_ALPIS		:= If(lAcols,aCols[nX,06],0)
				CD5->CD5_VLPIS		:= If(lAcols,aCols[nX,07],0)
				CD5->CD5_BSCOF		:= If(lAcols,aCols[nX,08],0)
				CD5->CD5_ALCOF		:= If(lAcols,aCols[nX,09],0)
				CD5->CD5_VLCOF		:= If(lAcols,aCols[nX,10],0)
				CD5->CD5_X_LOCD		:= aCols[nX,11] // Campo usuário
				CD5->CD5_LOCDES		:= aCols[nX,11] // Campo padrão
				CD5->CD5_X_UFDE		:= aCols[nX,12] // Campo usuário
				CD5->CD5_UFDES		:= aCols[nX,12] // Campo padrão
				CD5->CD5_X_DTDE		:= aCols[nX,13] // Campo usuário
				CD5->CD5_DTDES		:= aCols[nX,13] // Campo padrão
				CD5->CD5_OBS1       := _cObs1
				CD5->CD5_OBS2       := _cObs2
				CD5->CD5_OBS3       := _cObs3
				CD5->CD5_OBS4       := _cObs4
				CD5->CD5_OBS5       := _cObs5
				CD5->CD5_OBS6       := _cObs6
				MsUnLock()
				//DbSkip()
			EndIf
		EndIf
	Next
EndIf
//Close(oDlg)
Return(.T.)
*
**********************
User Function ValTxt()
**********************
*
If _nTpImpor == 1 // Importação de Catodo NF Matriz + 1 Get normal
	If "CD5_DOCIMP" $ AllTrim(ReadVar())
		_cObs4 := "// D.I. " + Left(M->CD5_DOCIMP,10) + Substr(_cObs4,19,Len(_cObs4)-18)
	ElseIf "CD5_VLPIS"  $ AllTrim(ReadVar())
		_cObs1 := Left(_cObs1,34) + Transform(M->CD5_VLPIS,"@E 9999,999.99") + Substr(_cObs1,46,Len(_cObs1)-45)
	ElseIf "CD5_VLCOF" $ AllTrim(ReadVar())
		_cObs1 := Left(_cObs1,58) + Transform(M->CD5_VLCOF,"@E 9999,999.99") + Substr(_cObs1,70,Len(_cObs1)-69)
	ElseIf "CD5_X_LOCD" $  AllTrim(ReadVar())
		_cObs5 := Left("// Desembaraço: " + AllTrim(M->CD5_X_LOCD) + "-" + acols[1,12] + "  RODRIMAR" + Space(_nTamObs),_nTamObs)
	ElseIf "CD5_X_UFDE" $  AllTrim(ReadVar())
		_cObs5 := Left("// Desembaraço: " + aCols[1,11] + "-" + M->CD5_X_UFDE + "  RODRIMAR" + Space(_nTamObs),_nTamObs)
	EndIf
	o_cObs1:Refresh()
	o_cObs4:Refresh()
	o_cObs5:Refresh()
	oDlg:Refresh()
EndIf
Return(.T.)
*
*************************
Static Function RetIndl()
*************************
*
Public _aRtInDtr := {}	// _aRtInDtr -> { Produto, Acondic, Quantidade, Quant.Original, Pedido+Item Origem, Elem. 09 do _aItensB}
// Para poder controlar o ponto de entrada na inclusão da nota de entrada e fazer
// a produção e distribuição dos PAs recebidos.
Private _cCodServ := Posicione("SB1",1,xFilial("SB1")+"SV05000030","B1_COD") // Cód.entrada do serviço -Usado posicione para retornar com tamanho correto

_aItensA  := {} // Matérias primas (vide posição 9)
// _aItensA ->{1-Código,2-Quantidade,3-Valor Unitario,4-Valor Total,
//             5-Peso cobre,6-peso pvc,7-identSB6,8-Valor_do_SB6,9-Tipo(A-Usada/B-Não Usada,10-TES de Devolução,11-Doc./Item Origem}
_nQtdMpCb := 0  // Quant. usado de Cobre
_nQtdMpPv := 0  // Quant. usado de PVC

_aItensB  := {} //  B - Serviço (PAs) // Produtos que resultaram da industrialização... pode ser PA, PI ou outros
// _aItensB ->{1-Código,2-Quantidade,3-Valor Unitario,4-Valor Total,
//             5-Peso cobre,6-peso pvc,7-identSB6,8-Valor_do_SB6,9-Nro.OP,10-TES de Devolução,11-Local}

_aAconds := {} // Para bobinas, guardar os dados das bobinas transferidas
// _aAconds -> {1-Filial Origem, 2-Nro.Bobina, 3-Nro. + Item da Pesagem, 4-Nro.+ Item Pedido destino,5-Filial de origem da bobina}


_nTtPACb  := 0  // Quant.Cobre no PA devolvido
_nTtPAPv  := 0  // Quant.PVC   no PA devolvido

_aItensC  := {} //  C - Outros Materiais
// _aItensc ->{1-Código,2-Quantidade,3-Valor Unitario,4-Valor Total,
//             5-Peso cobre,6-peso pvc,7-identSB6,8-Valor_do_SB6,}
_aTotSF2 := SF2->F2_VALMERC
_cStrnSeq := ""
DbSelectArea("SD2")
DbSetOrder(3) // D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
DbSeek(_cFilOrig+MV_XPAR02+MV_XPAR01+_cCodSF2,.F.)
Do While SD2->D2_FILIAL == _cFilOrig .And. SD2->(!Eof()) .And. ;
	     SD2->(D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) == MV_XPAR02+MV_XPAR01+_cCodSF2

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+SD2->D2_COD,.F.)

	If SD2->D2_TES $ (Left(_cTesRtMP1,3)+Left(_cTesRtMP2,3)) // TES de Devolução da MP usada
		// Este item também tem que ser separado por vlr unitario
		_cTesDev := If((SD2->D2_TES $ _cTesRtMP1),Right(_cTesRtMP1,3),Right(_cTesRtMP2,3))
		_nPsArr := aScan(_aItensA,;
							{|x|x[01]==SD2->D2_COD.And.x[11]==SD2->D2_NFORI+SD2->D2_SERIORI.And.x[09]=="A".And.x[10]==_cTesDev})
		If _nPsArr == 0
			aAdd(_aItensA,{SD2->D2_COD,0,SD2->D2_PRCVEN,0,SB1->B1_PESCOB,;
							SB1->B1_PESPVC,Padr("   ",TamSX3("B6_IDENT")[1]),0,"A",_cTesDev,SD2->D2_NFORI+SD2->D2_SERIORI})
			_nPsArr := Len(_aItensA)
		EndIf
		_aItensA[_nPsArr,2]+=SD2->D2_QUANT
		_aItensA[_nPsArr,4]+=SD2->D2_TOTAL

		If SB1->B1_GRUPO == "MP03"  .Or. SB1->B1_GRUPO == "MP04" // PVC ou MASTER
			_nQtdMpPv += SD2->D2_QUANT  // Quanto retornado de MP PVC
		Else // If SB1->B1_GRUPO == "MP02" // COBRE  02/09/15
			// Se não for PVC ou Master, suponho que é cobre
			_nQtdMpCb += SD2->D2_QUANT  // Quanto retornado de MP Cobre
		EndIf
	ElseIf SD2->D2_TES $ (Left(_cTesRtPA1,3)+Left(_cTesRtPA2,3)) // TES da "cobrança" do serviço (PAs ou PIs)

		_cLocPad := SB1->B1_LOCPAD

        If SB1->B1_TIPO # "PA" 
        	_cLocPad := SB1->B1_LOCPAD
		ElseIf SD2->D2_TES == "551"
			_cLocPad := "01"
		ElseIf SD2->D2_TES == "540"
			_cLocPad := "10"
		EndIf
		
		_cTesDev := If((SD2->D2_TES $ _cTesRtPA1),Right(_cTesRtPA1,3),Right(_cTesRtPA2,3))
		_nPsArr := aScan(_aItensB,{|x|x[01]==SD2->D2_COD.And.x[03]==SD2->D2_PRCVEN.And.;
									x[10]==_cTesDev   .And.x[11]==_cLocPad})
		If _nPsArr == 0
			aAdd(_aItensB,{SD2->D2_COD,0,SD2->D2_PRCVEN,0,SB1->B1_PESCOB,SB1->B1_PESPVC,;
							Padr("   ",TamSX3("B6_IDENT")[1]),0,"xx",_cTesDev,_cLocPad})
			_nPsArr := Len(_aItensB)
			_aItensB[_nPsArr,9] := StrZero(_nPsArr,11)
		EndIf
		_aItensB[_nPsArr,2]+=SD2->D2_QUANT
		_aItensB[_nPsArr,4]+=SD2->D2_TOTAL

		_nTtPACb := _nTtPACb + (SD2->D2_QUANT * SB1->B1_PESCOB) //Quantidade de COBRE no PA devolvido
		_nTtPAPv := _nTtPAPv + (SD2->D2_QUANT * SB1->B1_PESPVC) //Quantidade de PCV   no PA devolvido

		// Procuro o no Pedido/Item faturado o Pedido/Item Solicitante/Origem
		DbSelectArea("SC6")
		DbSetOrder(1) // C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
		DbSeek(_cFilOrig + SD2->D2_PEDIDO + SD2->D2_ITEMPV,.F.)

		DbSelectArea("SDB")
		DbSetOrder(1) // DB_FILIAL+DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR+DB_LOJA+DB_ITEM
		DbSeek(_cFilOrig+SD2->D2_COD+SD2->D2_LOCAL+SD2->D2_NUMSEQ+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA,.F.)

		Do While SDB->(DB_FILIAL+  DB_PRODUTO+DB_LOCAL+DB_NUMSEQ+DB_DOC+DB_SERIE+DB_CLIFOR +DB_LOJA) == ;
			_cFilOrig+SD2->(D2_COD+D2_LOCAL+D2_NUMSEQ+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) .And.;
			SDB->(!Eof())

			Aadd(_aRtInDtr,{SDB->DB_PRODUTO,SDB->DB_LOCALIZ,SDB->DB_QUANT,SDB->DB_QUANT, U_CBRZZPV(_cFilOrig,SC6->C6_NUM,SC6->C6_ITEM),StrZero(_nPsArr,11)})
			// _aRtInDtr -> { Produto, Acondic, Quantidade, Quant.Original, Pedido+Item Origem, Elem. 09 do _aItensB}

			If Left(SDB->DB_LOCALIZ,1) == "B" .And. !(SD2->D2_NUMSEQ$_cStrnSeq) // Bobina
				// Como posso ter mais de um SDB para cada SD2, só vejo uma vez o NUMSEQ
				_cStrnSeq := _cStrnSeq + "//" + SD2->D2_NUMSEQ
				// Localizar a bobina e a pesagem dessa bobina
				DbSelectArea("SZE")
				DbSetOrder(3) // ZE_FILIAL+ZE_STATUS+ZE_PEDIDO+ZE_ITEM+ZE_NUMBOB
				DbSeek(_cFilOrig + "F" + SD2->D2_PEDIDO + SD2->D2_ITEMPV,.F.)
				Do While SZE->(ZE_FILIAL+ZE_STATUS+ZE_PEDIDO+ZE_ITEM) == ;
					_cFilOrig + "F" + SD2->D2_PEDIDO + SD2->D2_ITEMPV .And. SZE->(!Eof())

					If SZE->ZE_DOC+SZE->ZE_SERIE+SZE->ZE_NUMSEQ == SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_NUMSEQ
						// Procurar a pesagem correspondente
						DbSelectArea("SZL")
						DbSetOrder(4) // ZL_FILIAL+ZL_NUMBOB
						If DbSeek(_cFilOrig+SZE->ZE_NUMBOB,.F.)
							aAdd(_aAconds,{SZE->ZE_FILIAL, SZE->ZE_NUMBOB, SZL->ZL_NUM+SZL->ZL_ITEM, U_CBRZZPV(_cFilOrig,SC6->C6_NUM,SC6->C6_ITEM), SZE->ZE_FILORIG})
							// _aAconds -> {1-Filial Origem, 2-Nro.Bobina, 3-Nro. + Item da Pesagem, 4-Nro.+ Item Pedido destino,5-Filial de origem da bobina}

						EndIf
					EndIf
					SZE->(DbSkip())
				EndDo
			EndIf
			SDB->(DbSkip())
		EndDo
	ElseIf SD2->D2_TES == Left(_cTesRtMP3,3) // TES de Devolução da MP não usada
		_cTesDev := Right(_cTesRtMP3,3)
		_nPsArr := aScan(_aItensA, {|x|x[01]==SD2->D2_COD.And.x[03]==SD2->D2_PRCVEN.And.x[09]=="B".And.x[10]==_cTesDev})
		If _nPsArr == 0
			aAdd(_aItensA,{SD2->D2_COD,0,SD2->D2_PRCVEN,0,SB1->B1_PESCOB,;
			SB1->B1_PESPVC,Padr("   ",TamSX3("B6_IDENT")[1]),0,"B",_cTesDev,SD2->D2_NFORI+SD2->D2_SERIORI})
			_nPsArr := Len(_aItensA)
		EndIf
		_aItensA[_nPsArr,2]+=SD2->D2_QUANT
		_aItensA[_nPsArr,4]+=SD2->D2_TOTAL
	Else
		_nPsArr := aScan(_aItensC, {|x|x[1]==SD2->D2_COD .And. x[3]==SD2->D2_PRCVEN})
		If _nPsArr == 0
			aAdd(_aItensC,{SD2->D2_COD,0,SD2->D2_PRCVEN,0,SB1->B1_PESCOB,SB1->B1_PESPVC,Padr("   ",TamSX3("B6_IDENT")[1]),0})
			_nPsArr := Len(_aItensC)
		EndIf
		_aItensC[_nPsArr,2]+=SD2->D2_QUANT
		_aItensC[_nPsArr,4]+=SD2->D2_TOTAL
	EndIf
	SD2->(DbSkip())
EndDo

//Localizar os produtos que estão EM PODER DE 3ros em 3L com a matriz
DbSelectArea("SB6")
DbSetOrder(2) //B6_FILIAL+B6_PRODUTO+B6_CLIFOR+B6_LOJA+B6_PODER3

// Verificar primeiro os códigos Nacional/Importado

For _nCt := 1 to Len(_aItensA)
	// _aItensA ->{1-Código,2-Quantidade,3-Valor Unitario,4-Valor Total,
	//             5-Peso cobre,6-peso pvc,7-identSB6,8-Valor_do_SB6,9-Tipo(A-Usada/B-Não Usada}
	_cPrdFor := _aItensA[_nCt,1]
	_cDocOri := _aItensA[_nCt,11]
	_lAchei  := .F.
	DbSelectArea("SB6")
	DbSetOrder(2) //B6_FILIAL+B6_PRODUTO+B6_CLIFOR+B6_LOJA+B6_PODER3

	// Procurar como nacional ou como importado
	For _nVezNI := 1 To 2
		If _nVezNI == 2
			// Comutar nacional/iportado
			_cPrdFor := AllTrim(_cPrdFor)
			If RIGHT(_cPrdFor,1) == "I"
				_cPrdFor := Left(_cPrdFor, Len(_cPrdFor)-1)
			Else
				_cPrdFor := _cPrdFor + "I"
			EndIf
			_cPrdFor := Padr(_cPrdFor,TamSX3("B1_COD")[1])
		EndIf
		DbSeek(xFilial("SB6")+_cPrdFor+_cCodSF1+"R",.F.) // R-> Controle na remessa
		Do While SB6->B6_FILIAL == xFilial("SB6") .And. SB6->B6_PRODUTO == _cPrdFor  .And. ;
			SB6->(B6_CLIFOR+B6_LOJA) == _cCodSF1 .And. SB6->B6_PODER3 == "R"    .And. SB6->(!Eof())
			If SB6->B6_TIPO == "E" .And. SB6->B6_DOC+SB6->B6_SERIE == _cDocOri
				_lAchei  := .T.
				Exit
			EndIf
			SB6->(DbSkip())
		Enddo
		If _lAchei
			If _aItensA[_nCt,1] # _cPrdFor
				_aItensA[_nCt,1] := _cPrdFor
			EndIf
			Exit
		EndIf
	Next
Next

aSort(_aItensA,,,{|x,y| x[01]<y[01].And.x[11]<y[11].And.x[09]<y[09]}) // código+Docto.Origem+AB
aSort(_aItensB,,,{|x,y| x[01]<y[01]}) // código
aSort(_aItensC,,,{|x,y| x[01]<y[01]}) // código

_aB6Usado := {} //{1-Produto, 2-IDb6, 3-Qtd.Saldo, 4-Vlr.Unit.SB6, 5-B1_GRUPO, 6-Qtd.Devolv.,7-Recno(SB6),8-TES Devolução}
_nQB6UsCu := 0  // Quantidade Total de B6 disponível - Cobre
_nQB6UsPv := 0  // Quantidade Total de B6 disponível - PVC
_cPrdFor  := "  "	// Produto
_nVlrFor  := 0		// Vlr. Unitário
_cDocOri := " "
For _nCt := 1 to Len(_aItensA)
	// _aItensA ->{1-Código,2-Quantidade,3-Valor Unitario,4-Valor Total,
	//             5-Peso cobre,6-peso pvc,7-identSB6,8-Valor_do_SB6,9-Tipo(A-Usada/B-Não Usada}
	If _aItensA[_nCt,1]  == _cPrdFor .And. _aItensA[_nCt,11] == _cDocOri
		Loop
	EndIf

	_cPrdFor := _aItensA[_nCt,1]
	_nVlrFor := _aItensA[_nCt,3]
	_cDocOri := _aItensA[_nCt,11]

	_nQtUtCTrg := 0 // Quantidade da MP Usada COM triangulação
	_nQtUtSTrg := 0 // Quantidade da MP Usada SEM triangulação
	_nQtdDev  := 0 // Quantidade da MP Devolvida Não Usada
	For _nCtx := _nCt to Len(_aItensA)
		If _aItensA[_nCtx,1] == _cPrdFor .And. _aItensA[_nCtx,11] == _cDocOri
			// Faz separadamente as MPs usadas e MPs não usadas
			If _aItensA[_nCtx,09] == "A" .And. _aItensA[_nCtx,10] == Right(_cTesRtMP1,3)
				_nQtUtCTrg += _aItensA[_nCtx,2] // Quantidade da MP devolvida naquele item com triangulação
			ElseIf _aItensA[_nCtx,09] == "A" .And. _aItensA[_nCtx,10] == Right(_cTesRtMP2,3)
				_nQtUtSTrg += _aItensA[_nCtx,2] // Quantidade da MP devolvida naquele item sem triangulação
			Else
				_nQtdDev  += _aItensA[_nCtx,2]// Quantidade da MP Devolvida Não Usada
			EndIf
		Else // Como o array está ordenado por código + vlr.unitário posso sair do For Next
			Exit
		EndIf
	Next

	DbSelectArea("SB6")
	DbSetOrder(2) //B6_FILIAL+B6_PRODUTO+B6_CLIFOR+B6_LOJA+B6_PODER3
	DbSeek(xFilial("SB6")+_cPrdFor+_cCodSF1+"R",.F.) // R-> Controle na remessa
	Do While SB6->B6_FILIAL == xFilial("SB6") .And. SB6->B6_PRODUTO == _cPrdFor  .And. ;
		SB6->(B6_CLIFOR+B6_LOJA) == _cCodSF1 .And. SB6->B6_PODER3 == "R"    .And. ;
		(_nQtUtCTrg+_nQtUtSTrg+_nQtdDev) > 0 .And. SB6->(!Eof())

		//_nPsArray := 0
		If SB6->B6_TIPO == "E" .And. SB6->B6_SALDO > 0 .And. SB6->B6_DOC+SB6->B6_SERIE == _cDocOri
			_B6_SALDO := SB6->B6_SALDO
			_B6_Grupo := Posicione("SB1",1,xFilial("SB1")+SB6->B6_PRODUTO,"B1_GRUPO")

			If _nQtUtCTrg > 0 .And. SB6->B6_TES == "536" // 536 Saída de 3L COM triangulação
				_nQtdUs    := Min(_nQtUtCTrg,_B6_SALDO)
				_nQtUtCTrg := _nQtUtCTrg - _nQtdUs
				_B6_SALDO  := _B6_SALDO - _nQtdUs

				If _B6_Grupo == "MP03" .Or. _B6_Grupo == "MP04" //// O B6 é do grupo PVC ?
					_nQB6UsPv += _nQtdUs  // Quantidade Total de B6 disponível
				Else  // Se não for PVC ou Master, suponho que é Cobre
					_nQB6UsCu += _nQtdUs  // Quantidade Total de B6 disponível - Cobre
				EndIf

				//{1-Produto, 2-IDb6, 3-Qtd.Saldo, 4-Vlr.Unit.SB6, 5-B1_GRUPO, 6-Qtd.Devolv.,7-Recno(SB6),8-TES Devolução}
				Aadd(_aB6Usado,{_cPrdFor,SB6->B6_IDENT,_nQtdUs,SB6->B6_PRUNIT,;
				Posicione("SB1",1,xFilial("SB1")+_cPrdFor,"B1_GRUPO"),0,SB6->(Recno()),Right(_cTesRtMP1,3)})
				//_nPsArray := Len(_aB6Usado)
			EndIf
			If _nQtUtSTrg > 0 .And. SB6->B6_TES == "549" .And. _B6_SALDO > 0 // 536 Saída de 3L SEM triangulação
				_nQtdUs    := Min(_nQtUtSTrg,_B6_SALDO)
				_nQtUtSTrg := _nQtUtSTrg - _nQtdUs
				_B6_SALDO  := _B6_SALDO - _nQtdUs

				If _B6_Grupo == "MP03" .Or. _B6_Grupo == "MP04" //// O B6 é do grupo PVC ?
					_nQB6UsPv += _nQtdUs  // Quantidade Total de B6 disponível
				Else  // Se não for PVC ou Master, suponho que é Cobre
					_nQB6UsCu += _nQtdUs  // Quantidade Total de B6 disponível - Cobre
				EndIf

				//{1-Produto, 2-IDb6, 3-Qtd.Saldo, 4-Vlr.Unit.SB6, 5-B1_GRUPO, 6-Qtd.Devolv.,7-Recno(SB6),8-TES Devolução}
				Aadd(_aB6Usado,{_cPrdFor,SB6->B6_IDENT,_nQtdUs,SB6->B6_PRUNIT,;
				Posicione("SB1",1,xFilial("SB1")+_cPrdFor,"B1_GRUPO"),0,SB6->(Recno()),Right(_cTesRtMP2,3)})
				//_nPsArray := Len(_aB6Usado)
			EndIf
			If _nQtdDev > 0 .And. _B6_SALDO > 0
				_nQtdUs   := Min(_nQtdDev,_B6_SALDO)
				_nQtdDev  := _nQtdDev  - _nQtdUs
				_B6_SALDO := _B6_SALDO - _nQtdUs
				//If _nPsArray == 0
				//{1-Produto, 2-IDb6, 3-Qtd.Saldo, 4-Vlr.Unit.SB6, 5-B1_GRUPO, 6-Qtd.Devolv.,7-Recno(SB6),8-TES Devolução}
				Aadd(_aB6Usado,{_cPrdFor,SB6->B6_IDENT,0,SB6->B6_PRUNIT,;
				Posicione("SB1",1,xFilial("SB1")+_cPrdFor,"B1_GRUPO"),_nQtdUs,SB6->(Recno()),Right(_cTesRtMP3,3)})
				/*/
			Else
				_aB6Usado[_nPsArray,6] := _aB6Usado[_nPsArray,6] + _nQtdUs
				/*/
			EndIf
		EndIf
		SB6->(DbSkip())
	EndDo
	If (_nQtUtCTrg+_nQtUtSTrg+_nQtdDev) > 0 // Quantidade da MP Usada + Não usada
		//{1-Produto, 2-IDb6, 3-Qtd.Saldo, 4-Vlr.Unit.SB6, 5-B1_GRUPO, 6-Qtd.Devolv.,7-Recno(SB6),8-TES Devolução}
		/*/
		Aadd(_aB6Usado,{_cPrdFor,"NAO LOC",(_nQtUtCTrg+_nQtUtSTrg+_nQtdDev),_nVlrFor,;
		Posicione("SB1",1,xFilial("SB1")+_cPrdFor,"B1_GRUPO"),_nQtdDev,0,"   "})
		/*/
		ZZZ := 1
	EndIf
Next
/*/
Verificar os PAs(_aItensB) contra os _aB6Usado e ver onde cada um cabe

_nQtdMpCb --> Quanto retornado de MP Usada Cobre
_nQtdMpPv --> Quanto retornado de MP Usada PVC

_nTtPACb --> Quanto de COBRE nos PAs enviados como serviços
_nTtPAPv --> Quanto de PVC   nos PAs enviados como serviços
/*/
_nDecD1 := 2 //TamSX3("D1_QUANT")[2]
_aItensNF := {} //{1-Numero OP, 2-Produto, 3-Quantidade, 4-Valor Unit.,5-ID_B6,6-Recno(SB6),7-TES Devolução}
//_nNumSeek := "55000000" // Nro da OP-item a ser criada
_aItens499 := {} // {Produto}  -> Itens com tes 499 somente para o pcfactory poder incluir etiqueta

// _aItensB ->{1-Código,2-Quantidade,3-Valor Unitario,4-Valor Total,
//             5-Peso cobre,6-peso pvc,7-identSB6,8-Valor_do_SB6,9-Nro.OP,10-TES de Devolução}
_lPararAqui := .t.
For _nCt := 1 to Len(_aItensB) // B - Serviço (PAs)

	// _aItensB[_nCt,9] := CrieOP() //- Não criar as OPs agora pois pode ser que aborte a rotina
	// _aItensB[_nCt,9] := StrZero(_nCt,9)

	//   _aItensNF {1-Num            ,2-Produto , 3-Qtd, 4-Total        ,5-ID_B6,6-Recno(SB6),7-TES Devolução}
	Aadd(_aItensNF,{_aItensB[_nCt,09],_cCodServ , 1    ,_aItensB[_nCt,04]," ",0,_aItensB[_nCt,10]})
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+_aItensB[_nCt,1],.F.)
	If SB1->B1_TIPO # "PA"
		If aScan(_aItens499,_aItensB[_nCt,1]) == 0
			Aadd(_aItens499,{_aItensB[_nCt,1],_aItensB[_nCt,2]}) // Produto //Qtde
		EndIf
	EndIf
	// pego direto o valor total como unitário -> Quant 1

	// Quanto de Cobre do Item
	_nSbPACb := (_aItensB[_nCt,2] * _aItensB[_nCt,5])
	// Quanto de PVC do Item
	_nSbPAPv := (_aItensB[_nCt,2] * _aItensB[_nCt,6])

	// Qual a quantidade será usada do B6?
	_nNecCob := Round((_nSbPACb / _nTtPACb) * _nQB6UsCu,_nDecD1) // Necessidade de cobre
	_nNecPvc := Round((_nSbPACb / _nTtPAPv) * _nQB6UsPv,_nDecD1) // Necessidade de PVC

	For _nCtB6 := 1 To Len(_aB6Usado)
		If _aB6Usado[_nCtB6,3] > 0 // Tem Quantidade?
			If _aB6Usado[_nCtB6,5] == "MP03" .Or. _aB6Usado[_nCtB6,5] == "MP04" //// O B6 é do grupo PVC e preciso de PVC?
				_nQtdOP := Min(_aB6Usado[_nCtB6,3],_nNecPvc)
				_nNecPvc -= _nQtdOP
			Else  // Se não for PVC ou Master, suponho que é Cobre
				_nQtdOP := Min(_aB6Usado[_nCtB6,3],_nNecCob) //Round((_aB6Usado[_nCtB6,3]/_nTtPACb)*_nSbPACb,_nDecD1)
				_nNecCob -= _nQtdOP
			EndIf

			If _nQtdOP > 0
				// _aItensNF-> {1-Numero        , 2-Produto         , 3-Quantidade, 4-Valor Unit.     ,5-ID_B6            ,6-Recno(SB6),7-TES Devolução}
				Aadd(_aItensNF,{_aItensB[_nCt,9],_aB6Usado[_nCtB6,1],_nQtdOP      ,_aB6Usado[_nCtB6,4],;
				_aB6Usado[_nCtB6,2],_aB6Usado[_nCtB6,7],_aB6Usado[_nCtB6,8]})
				_aB6Usado[_nCtB6,3] -= _nQtdOP
			EndIf
		EndIf
		If _nNecCob == 0 .And. _nNecPvc == 0 // Já atendeu a necessidade do item
			Exit
		EndIf
	Next
Next

_nCt := 1
// Corrigir a quantidade que sobrou em _aB6Usado
For _nCtB6 := 1 To Len(_aB6Usado)
	If _aB6Usado[_nCtB6,3] > 0 // Tem Quantidade?
		For _nCt := _nCt To Len(_aItensNF)
			If _aItensNF[_nCt,2] == _aB6Usado[_nCtB6,1] .And. _aItensNF[_nCt,5] == _aB6Usado[_nCtB6,2]
				// Mesmo produto e mesmo ID do B6
				_aItensNF[_nCt,3] += _aB6Usado[_nCtB6,3]
				_aB6Usado[_nCtB6,3] := 0
				_nCt++ // Adiciona 1 para se houver mais diferença incluir no próximo
				Exit
			EndIf
		Next
	EndIf
	If _nCt > Len(_aItensNF)
		_nCt := 1
	EndIf
Next
IncluirNta()
Return(.T.)
*
************************
Static Function CrieOP()
************************
//
//1 - Criar as OPs dos PAs enviados
// {1-Código,2-Quantidade,3-Valor Unitario,4-Valor Total,5-Peso cobre,6-peso pvc,7-identSB6,8-Valor_do_SB6,9-OP}

DbSelectArea("SC2")
DbSetOrder(1) // C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
Do While DbSeek(xFilial("SC2")+_nNumSeek,.F.)
	_nNumSeek := Soma1(_nNumSeek,,.F.)
EndDo
_NumOP   := Left (_nNumSeek,6)
_Item    := Right(_nNumSeek,2)
_cSeq    := "001"
_cAlmo   := _aItensB[_nCt,11]
_cProd   := _aItensB[_nCt,01]
_nQtd    := _aItensB[_nCt,02]
_cStInt  := "N"  // Não enviar dados para integração com o PPI
_Obs     := " "
lCriaOPI := .F.
_CriouOP := u_NovaOP("I",lCriaOPI,dDatabase," ",_cStInt, .F.)
// Parâmetros: I=Incluir / E Excluir OP // .T.= Criar /.F. = Não criar OPs intermediárias
If _CriouOP
	// Matar os empenhos criados para essa OP
	DbSelectArea("SB2")
	DbSetOrder(1) // B2_FILIAL+B2_COD+B2_LOCAL

	DbSelectArea("SD4")
	DbSetOrder(2) // D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
	Do While SD4->(DbSeek(xFilial("SD4") + _NumOP + _Item + _cSeq,.F.))
		If SB2->(DbSeek(xFilial("SB2") + SD4->D4_COD + SD4->D4_LOCAL,.F.))
			RecLock("SB2",.F.)
			SB2->B2_QEMP := SB2->B2_QEMP - SD4->D4_QUANT
			MsUnLock()
		EndIf
		RecLock("SD4",.F.)
		DbDelete()
		MsUnLock()
	EndDo
EndIf
Return(_NumOP+_Item+_cSeq)
*
****************************
Static Function IncluirNta()
****************************
*

// Criar Cabeçalho da nota de entrada

DbSelectArea("SA2")
DbSetOrder(1)
DbSeek(xFilial("SA2") + _cCodSF1,.F.)

DbSelectArea("SF2") // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL
DbSeek(_cFilOrig+MV_XPAR02+MV_XPAR01+_cCodSF2,.F.)

aCabs  := {}
aAdd(aCabs, {'F1_DOC    ', SF2->F2_DOC 		, Nil})
aAdd(aCabs, {'F1_SERIE  ', SF2->F2_SERIE	, Nil})
aAdd(aCabs, {'F1_FORNECE', SA2->A2_COD		, Nil})
aAdd(aCabs, {'F1_LOJA   ', SA2->A2_LOJA	    , Nil})
aAdd(aCabs, {'F1_EMISSAO', SF2->F2_EMISSAO	, Nil})
aAdd(aCabs, {'F1_TIPO   ', "N"      		, Nil})
aAdd(aCabs, {'F1_FORMUL ', "N"		    	, Nil})
aAdd(aCabs, {'F1_DESPESA', 0.00				, Nil})
aAdd(aCabs, {'F1_CHVNFE' , SF2->F2_CHVNFE   , Nil})
aAdd(aCabs, {'F1_DTDIGIT', ddatabase    	, Nil})
aAdd(aCabs, {'F1_ESPECIE', "SPED"        	, Nil})

_nSomaItns := 0.00
// Criar os itens da nota para cada tipo de dado:
aItens	:= {}
_nTtPrd := 0
_cItens := StrZero(0,TamSX3("D1_ITEM")[1])
For _nCt := 1 to Len(_aItensNF) // {1-Numero OP, 2-Produto, 3-Quantidade, 4-Valor Unit.,5-ID_B6,6-Recno(SB6),7-TES Devolução}
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+_aItensNF[_nCt,2],.F.))

	_cLocal := "01"
	If _aItensNF[_nCt,6] > 0 // é um item do SB6
		DbSelectArea("SB6")
		DbSetOrder(1)
		SB6->(DbGoTo(_aItensNF[_nCt,6]))
		_cLocal := SB6->B6_LOCAL
	EndIf

	_cTES   := _aItensNF[_nCt,7]
	_tVALOR := Round(_aItensNF[_nCt,3] * _aItensNF[_nCt,4],2)

	aItem := {}
	_cItens := SOMA1(_cItens)
	aAdd(aItem, {'D1_ITEM   ', _cItens			, Nil})
	aAdd(aItem, {'D1_COD    ', SB1->B1_COD		, Nil})
	aAdd(aItem, {'D1_DESCRI ', SB1->B1_DESC		, Nil})
	aAdd(aItem, {'D1_UM     ', SB1->B1_UM		, Nil})
	aAdd(aItem, {'D1_QUANT  ', _aItensNF[_nCt,3], Nil})
	aAdd(aItem, {'D1_VUNIT  ', _aItensNF[_nCt,4], Nil})
	aAdd(aItem, {'D1_TOTAL  ', _tVALOR			, Nil})
	aAdd(aItem, {'D1_TES    ', _cTES 			, Nil})
	aAdd(aItem, {'D1_LOCAL  ', _cLocal          , Nil})
	If !Empty(_aItensNF[_nCt,1]) // Tenho um nro de OP
		aAdd(aItem, {'D1_OP     ', _aItensNF[_nCt,1], Nil})
	EndIf
	If _aItensNF[_nCt,6] > 0 // é um item do SB6
		aAdd(aItem, {'D1_NFORI  ', SB6->B6_DOC  , Nil})
		//aAdd(aItem, {'D1_ITEMORI', "X := ???????????"  , Nil})
		aAdd(aItem, {'D1_SERIORI', SB6->B6_SERIE, Nil})
		aAdd(aItem, {'D1_IDENTB6', SB6->B6_IDENT, Nil})
	EndIf
	aAdd(aItens,aItem)
	_nSomaItns := _nSomaItns + _tVALOR

	If !"SV05000030" $ SB1->B1_COD
		_nTtPrd += _aItensNF[_nCt,3]
	EndIf
Next

If _nSomaItns # _aTotSF2
	// Tem diferença -> Mostrar para usuário corrigir
	//
	If !MostreIte()
		Return(.F.)
	EndIf
EndIf

Begin Transaction

/// Criar as OPs
_nNumSeek := "55000000" // Nro da OP-item a ser criada

// _aItensB ->{1-Código,2-Quantidade,3-Valor Unitario,4-Valor Total,
//             5-Peso cobre,6-peso pvc,7-identSB6,8-Valor_do_SB6,9-Nro.OP,10-TES de Devolução}

For _nCt := 1 to Len(_aItensB) // B - Serviço (PAs)
	_cChvb := _aItensB[_nCt,9]
	_aItensB[_nCt,9] := CrieOP() //- Não criar as OPs agora pois pode ser que aborte a rotina

	For _nCt2 := 1 to Len(aItens)
		For _nCt3 := 1 to Len(aItens[_nCt2])
			If AllTrim(aItens[_nCt2,_nCt3,1]) == "D1_OP"
				If aItens[_nCt2,_nCt3,2] == _cChvb
					aItens[_nCt2,_nCt3,2] := _aItensB[_nCt,9]
					Exit // Já achei o que queria
				EndIf
			EndIf
		Next
	Next

	For _nCt2 := 1 to Len(_aRtInDtr)
		If _aRtInDtr[_nCt2,6] == _cChvb
			_aRtInDtr[_nCt2,6] := _aItensB[_nCt,9]
			// _aRtInDtr -> { Produto, Acondic, Quantidade, Quant.Original, Pedido+Item Origem, Elem. 09 do _aItensB}
		EndIf
	Next
Next

// Incluir no D1 os itens de _aItens499

For _nCt := 1 to Len(_aItens499)

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+_aItens499[_nCt][1],.F.))

	aItem := {}
	aAdd(aItem, {'D1_ITEM   ', StrZero(Len(aItens)+1,TamSX3("D1_ITEM")[1]), Nil})
	aAdd(aItem, {'D1_COD    ', SB1->B1_COD	, Nil})
	aAdd(aItem, {'D1_DESCRI ', SB1->B1_DESC	, Nil})
	aAdd(aItem, {'D1_UM     ', SB1->B1_UM	, Nil})
	aAdd(aItem, {'D1_QUANT  ', _aItens499[_nCt][2], Nil})
	aAdd(aItem, {'D1_VUNIT  ', 1			, Nil})
	aAdd(aItem, {'D1_TOTAL  ', _aItens499[_nCt][2], Nil})
	aAdd(aItem, {'D1_TES    ', "499"		, Nil})
	aAdd(aItem, {'D1_LOCAL  ', "99"			, Nil})
	aAdd(aItens,aItem)
Next
    
If Len(_aItens499) > 0 // Tenho algo com TES 499
	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xFilial("SF4")+'499',.F.)
	_cF4Blq := SF4->F4_MSBLQL
	RecLock("SF4",.F.)
	SF4->F4_MSBLQL := "2" // Liberado
	MsUnLock()
EndIf
lMsErroAuto := .F.
LjMsgRun("Gerando Documento de Entrada... " + SF2->F2_DOC,,{||MSExecAuto({|x, y, z| MATA103(x, y, z)}, aCabs, aItens, 3)})
If lMsErroAuto
	DisarmTransaction()
	MostraErro()
ElseIf Len(_aAconds) > 0
	// Se houver bobinas, criar SZL e SZE na filial de destino
	TrocaEtiq(_aAconds)
EndIf

If Len(_aItens499) > 0 // Tenho algo com TES 499
	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek(xFilial("SF4")+'499',.F.)
	RecLock("SF4",.F.)
	SF4->F4_MSBLQL := _cF4Blq // Deixa como estava
	MsUnLock()
EndIf


MsUnLockall()
End Transaction
Return(!lMsErroAuto)
*
/*/
Os PE abaixo tem a finalidade de inibir a apresentação da mensagem nas respectivas rotinas
referente aos empenhos da OP.
No caso de OP criada automaticamanete para o item da nota fiscal, não efetuar as validações
/*/
*
************************
User Function A103VSG1()
************************
*
Local _lVolta := .T.
If Type("_aRtInDtr") == "A"
	If Len(_aRtInDtr) > 0
		_lVolta := .F. // Não efetua a validação
	EndIf
EndIf
Return(_lVolta)

*
****************************
Static Function MostreIte()
****************************
*
Local _aCPS := {"D1_ITEM   ","D1_COD    ","D1_DESCRI ","D1_QUANT  ","D1_VUNIT  ","D1_TOTAL  ","D1_VALICM ","D1_LOCAL  "}
Private _nDifAcols := _nSomaItns - _aTotSF2
Private _lSaida := .F.

dbSelectArea("SX3")
dbSetOrder(2)

aHeader:={}
For _nCp :=1 to Len(_aCPS)
	DbSeek(_aCPS[_nCp])
	If SX3->X3_CAMPO == "D1_TOTAL  "
		// Unico campo que aceita alteração
		Aadd(aHeader,{ 	AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
		SX3->X3_TAMANHO, SX3->X3_DECIMAL,"u_ValTot()",;
		SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )
	ElseIf SX3->X3_CAMPO == "D1_VALICM "
		// Unico campo que aceita alteração
		Aadd(aHeader,{ 	    "Valor Aceito",SX3->X3_CAMPO,SX3->X3_PICTURE,;
		SX3->X3_TAMANHO, SX3->X3_DECIMAL,".F.",;
		SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )
	Else
		Aadd(aHeader,{ 	AllTrim(SX3->X3_TITULO),SX3->X3_CAMPO,SX3->X3_PICTURE,;
		SX3->X3_TAMANHO, SX3->X3_DECIMAL,".F.",;
		SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT } )
	EndIf
Next
_nTtDevol := 0
_nTtServs := 0
_nDif := (_aTotSF2 - _nSomaItns)

aCols:={}
For _nCp :=1 to Len(aItens)
	AADD(aCols,Array(Len(aHeader)+1))
	aCols[Len(aCols),01] := aItens[_nCp,1,2]
	aCols[Len(aCols),02] := aItens[_nCp,2,2]
	aCols[Len(aCols),03] := aItens[_nCp,3,2]
	aCols[Len(aCols),04] := aItens[_nCp,5,2]
	aCols[Len(aCols),05] := aItens[_nCp,6,2]
	aCols[Len(aCols),06] := aItens[_nCp,7,2]
	aCols[Len(aCols),07] := NoRound((aItens[_nCp,5,2]*aItens[_nCp,6,2]),TamSX3("D1_TOTAL")[2])
	aCols[Len(aCols),08] := aItens[_nCp,9,2]
	aCols[Len(aCols),09] := .F.

	If AllTrim(aItens[_nCp,2,2]) == "SV05000030"
		_nTtServs += aItens[_nCp,7,2]
	Else
		If _nDif > 0 // SF2 > soma
			// Adicionar 0.01 no item
			aItens[_nCp,7,2] += 0.01
			_nDif -= 0.01
		ElseIf _nDif < 0 // SF2 < soma
			// Subtratir 0.01 no item
			aItens[_nCp,7,2] -= 0.01
			_nDif += 0.01
		EndIf
		_nSomaItns := (_nSomaItns - aCols[Len(aCols),06] + aItens[_nCp,7,2])
		aCols[Len(aCols),06] := aItens[_nCp,7,2]
		_nTtDevol += aItens[_nCp,7,2]
	EndIf
Next

ntamaCols := Len(aCols)

//Do While .T.
lsai := .F.
L01 := 000
L02 := 450
L03 := 004
L04 := 190
L05 := 195
L06 := 210
C01 := 000
C02 := 850
C03 := 005
C04 := 420
C05 := 020
C06 := 074
C07 := 370

_nDifAcols := _nSomaItns - _aTotSF2
_lSaida := .F.
cCadastro := OemToAnsi("Composição da Nota " + SF2->F2_DOC)
@ L01,C01 TO L02,C02 DIALOG oDlg1 TITLE cCadastro
@ L03,C03 TO L04,C04 MULTILINE MODIFY DELETE  OBJECT oMultiline //VALID u_SomePar()

@ L05,C05 Say "Total Nota  R$."
@ L05,C06 Get _aTotSF2 Object oGet1 SIZE 50,7 Picture "@E 9,999,999.99" When .F.

@ L05,136 Say "Total Devol. M.P. R$."
@ L05,190 Get _nTtDevol  Object oGet2 SIZE 50,7 Picture "@E 9,999,999.99" When .F.

@ L05,C07 BMPBUTTON TYPE 01 ACTION If(ValSoma(),Close(oDlg1),.F.) //oOk()

@ L06,C05 Say "Valor Alterado    R$."
@ L06,C06 Get _nSomaItns Object oGet3 SIZE 50,7 Picture "@E 9,999,999.99" When .F.

@ L06,136 Say "Total Serviços    R$."
@ L06,190 Get _nTtServs Object oGet4 SIZE 50,7 Picture "@E 9,999,999.99" When .F.

@ L06,252 Say "Diferença         R$."
@ L06,306 Get _nDifAcols Object oGet5 SIZE 50,7 Picture "@E 9,999,999.99" When .F.

@ L06,C07 BMPBUTTON TYPE 02 ACTION If(CancSma(),Close(oDlg1),.F.)

omultiline:nmax:=ntamaCols

ACTIVATE DIALOG oDlg1 CENTERED


Return(_lSaida)
*
*************************
Static Function ValSoma()
*************************
*
_nSomaItns := 0.00
For _nCt := 1 to Len(aCols)
	_nSomaItns += GdFieldGet("D1_TOTAL",_nCt)
Next
_nDifAcols := (_aTotSF2 - _nSomaItns)
If _nDifAcols # 0
	Alert("Diferença de R$ " + Transform(_nDifAcols,"@E 999,999.99"))
	Return(.F.)
EndIf
// Assume os valores no aItens
For _nCp :=1 to Len(aItens)
	aItens[_nCp,7,2] := aCols[_nCp,6]
Next
_lSaida := .T.
Return(.T.)
*
**********************
User Function ValTot()
**********************
*
Local _nTot1 :=   Round((GdFieldGet("D1_QUANT",n) * GdFieldGet("D1_VUNIT",n)),TamSX3("D1_TOTAL")[2])
Local _nTot2 := NoRound((GdFieldGet("D1_QUANT",n) * GdFieldGet("D1_VUNIT",n)),TamSX3("D1_TOTAL")[2])
Local lVolta := .F.
If M->D1_TOTAL # _nTot1 .And. M->D1_TOTAL # _nTot2 .And. (M->D1_TOTAL-_nTot1) # 0.01
	Alert("Total Inválido")
	_lSaida := .F.
Else
	_nSomaItns := M->D1_TOTAL // Total digitado na linha
	For _nCt := 1 to Len(aCols)
		If _nCt # n
			_nSomaItns += GdFieldGet("D1_TOTAL",_nCt)
		EndIf
	Next
	_nDifAcols := (_nSomaItns - _aTotSF2)

	If AllTrim(GdFieldGet("D1_COD",n)) == "SV05000030"
		_nTtServs := _nTtServs + M->D1_TOTAL - _nTot1
	Else
		_nTtDevol := _nTtDevol + M->D1_TOTAL - _nTot1
	EndIf
	oGet1:Refresh()
	oGet2:Refresh()
	oGet3:Refresh()
	oGet4:Refresh()
	oGet5:Refresh()
	lVolta := .T.
	_lSaida := .T.
EndIf
Return(lVolta)


/*/{Protheus.doc} CancSma
//TODO Descrição auto-gerada.
@author Legado
@since 13/04/2018
@version 1.0

@type function
/*/
Static Function CancSma()
	_lSaida := .F.
Return(MsgBox("Cancela o Processamento da Nota?","Confirma?","YesNo"))


/*/{Protheus.doc} TrocaEtiq
//TODO Descrição auto-gerada.
@author Legado
@since 13/04/2018
@version 1.0
@param aAcondic, array, descricao
@type function
/*/
Static Function TrocaEtiq(aAcondic)

	For _nAconds := 1 To Len(aAcondic)
		//aAdd(aAcondic,{SZE->ZE_FILIAL, SZE->ZE_NUMBOB, SZL->ZL_NUM+SZL->ZL_ITEM, SC6->C6_ZZPVORI,SZE->ZE_FILORIG})
		// aAcondic -> {1-Filial Origem, 2-Nro.Bobina, 3-Nro. + Item da Pesagem, 4-Nro.+ Item Pedido destino,5-Filial de origem da bobina}
	
		//Posicionar a bobina original
		DbSelectArea("SZE")
		DbSetOrder(1) // ZE_FILIAL+ZE_NUMBOB
		DbSeek(aAcondic[_nAconds,1] + aAcondic[_nAconds,2],.F.)
		_nRegSZE := SZE->(Recno())
	
		//posicionar o SZL original
		// Atenção: Tem ocorrido que nas pesagens de bobinas o sistema está repetindo o número da pesagem. Estamos
		// verificando o por que isso ocorre. Para que não haja erro na montagem da nova bobina, estou montando um
		// loop para pegar a pesagem certa, validando também o número da bobina.
		DbSelectArea("SZL")
		DbSetOrder(1) //ZL_FILIAL+ZL_NUM+ZL_ITEM
		DbSeek(aAcondic[_nAconds,1] + aAcondic[_nAconds,3],.F.)
		Do While SZL->ZL_FILIAL == aAcondic[_nAconds,1] .And. SZL->ZL_NUM+SZL->ZL_ITEM == aAcondic[_nAconds,3] .And. SZL->(!Eof())
			If SZL->ZL_NUMBOB == aAcondic[_nAconds,2]
				Exit
			EndIf
			SZL->(DbSkip())
		EndDo
	
		_cBobAnt := " "
		If !Empty(SZL->ZL_NUMBOB).And. SZL->ZL_FILIAL == aAcondic[_nAconds,1] .And. SZL->ZL_NUM+SZL->ZL_ITEM == aAcondic[_nAconds,3] .And. SZL->(!Eof())
			_cBobAnt := SZL->ZL_FILIAL+SZL->ZL_NUMBOB
		EndIf
		_nRegSZL := SZL->(Recno())
	
		//RegToMemory("SZL",.T.,.T.,.T.)
		RegToMemory("SZL",.T.,.T.,.F.)
	
		/*/
		Lógico 1	Indica se a inicialização será baseada numa operações de inclusão ( .T. ) ou manutenção ( .F. ).
		A diferença entre elas é que na operação de inclusão os valores são inicializados vazios e na
		manutenção com os dados do registro posicionado.
		Lógico 2	Indica se a inicialização das variaveis será baseada no dicionário de dados ou apenas nos dados
		da WorkArea aberta. A diferença entre elas são os campos virtuais que somente são inicializadados
		com a opção .T. - Dicionário de dados.
		Lógico 3 	Indica se o inicializador padrão do dicionário de dados será executado. Este parametro somente
		será acionado se o parametro ExpL3 for configurado como .T.
		/*/
	
		M->ZL_OPER := "000"
		M->ZL_NOMOPER := Posicione("SZS",1,xFilial("SZS")+M->ZL_OPER,"ZS_NOME")
		M->ZL_TIPO    := "F"
		M->ZL_ITEM    := "001"
		M->ZL_LOTE    := SZL->ZL_LOTE
		M->ZL_TPBOB   := SZL->ZL_TPBOB
		M->ZL_PRODUTO := SZL->ZL_PRODUTO
		M->ZL_DESC    := Posicione("SB1",1,xFilial("SB1")+SZL->ZL_PRODUTO,"B1_DESC")
		M->ZL_METROS  := SZL->ZL_METROS
		M->ZL_TARA    := SZL->ZL_EMB
		M->ZL_PBRUT   := SZL->ZL_PBRUT
		M->ZL_ACOND   := "B"
		M->ZL_QTLANCE := 1
		M->ZL_MOTIVO  := "00"
		U_CalcPeso(.F.)
		M->ZL_PEDIDO  := Left(aAcondic[_nAconds,4],6)
		M->ZL_ITEMPV  := Right(aAcondic[_nAconds,4],2)
	
		DbSelectArea("SZL")
		RecLock("SZL",.T.)
	
		// Gravar os dados no SZL
		_nQtdCpos := FCount()
		For _j := 1 to _nQtdCpos
			_cNameCpo := "M->" + AllTrim(FieldName(_j))
			If "ZL_FILIAL" $ _cNameCpo
				SZL->ZL_FILIAL := xFilial("SZL")
			Else
				FieldPut(_j,&(_cNameCpo))
			EndIf
		Next
		u_GrvDadSZL(.F.,.F.,aAcondic[_nAconds,5])  // Imprime etiqueta?, Dá novo número?, Filial de origem da bobina
	Next
Return(.T.)

static function validMP(aMPs)
	local aArea 	:= GetArea()
    local aAreaSB2 	:= SB2->(GetArea())
	local aProblems := {}
	local lRet 		:= .F.
	local nX		:= 0
	local nSaldo	:= 0
	local cMsg		:= ''
	local Skipline	:= chr(13)+chr(10)
	local cLocInd	:= AllTrim(GetNewPar('ZZ_VLDMPDI', '99'))
	
	DBSelectArea("SB2")
	SB2->(DbSetOrder(1))

	if empty(aMPs)
		aAdd(aProblems, {'Sem produtos', 'NF de Industrialização sem consumo para realizar!'})
	endif
	for nX := 1 to len(aMPs)	
		if(SB2->(DbSeek(xFilial("SB2")+Padr(Alltrim(aMPs[nX, 01]),TamSX3("B2_COD")[1])+cLocInd,.F.)))
			nSaldo := 0
			nSaldo := (SB2->B2_QATU + aMPs[nX, 02])
			if aMPs[nX, 02] > nSaldo
				aAdd(aProblems, {'Saldo insuficiente [' + Alltrim(aMPs[nX, 01]) + ']', '[Saldo: ' + cValToChar(nSaldo) + '] x [NF: ' + cValToChar(aMPs[nX, 02]) + ']'})
			endif
		else
			aAdd(aProblems, {'Produto não localizado [' + Alltrim(aMPs[nX, 01]) + ']', '[NF: ' + cValToChar(aMPs[nX, 02]) + ']'})
		endif	
	next nX	
	if !(lRet := (empty(aProblems)))
		for nX := 1 to len(aProblems)
			cMsg += aProblems[nX, 01] + ' - ' + aProblems[nX, 02]
			if nX < len(aProblems)
				cMsg += Skipline
			endif
		next nX
		Alert(cMsg)
	endif
	RestArea(aAreaSB2)
    RestArea(aArea)
return(lRet)
