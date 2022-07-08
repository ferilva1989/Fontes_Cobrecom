#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: CDTMS02                            Modulo : SIGAEST      //
//                                                                          //
//                                                    Data ..: 11/04/2012   //
//                                                                          //
//   Objetivo ...: Manutenção na tabela ZZ4 de cálculo de fretes.           //
//     Atenção.: Os registros da tabela ZZ4 só podem ser:                   //
//               Alterados ou Excluídos se o Número do Conhecimento estiver //
//               vazio;                                                     //
//               No caso de exclusão de notas fiscais de entrada ou saída   //
//               só podem ser concluídas se não tiver registro na ZZ4 ou o  //
//               campo Nro. do Termo estiver vazio. Nesse caso, excluir     //
//               também o ZZ4 correspondente;                               //
//                                                                          //
//               O campo ZZ5_STATUS tem os seguintes conteudos:             //
//                    0 - Cancelado                                         //
//                    1 - Inserido                                          //
//                    2 - Validado SEFAZ                                    //
//                    3 - Inserido Documento de Entrada                     //
//                    4 - Gerada a Fatura                                   //
//                    5 - Rejeitado SEFAZ                                   //
//                                                                          //
//   Uso ........: Especifico da Cobrecom                                   //
//                                                                          //
//////////////////////////////////////////////////////////////////////////////
*
***********************
User Function CDTMS02() // ok
***********************
*

cCadastro := "Controle de Fretes por Nota"

aCores    := {{"!Empty(ZZ4_CONHEC) .And. !Empty(ZZ4_NROTER)","DISABLE"   },;
			  {"!Empty(ZZ4_NROTER)","BR_AMARELO"},;
			  {"!Empty(ZZ4_CONHEC)","BR_PRETO"},;
			  {"Empty(ZZ4_CONHEC) .And. Empty(ZZ4_NROTER)","ENABLE"   }}

aRotina := {{ "Pesquisar"          , "AxPesqui"   ,0,1},;
		    { "Visualizar"         , "AxVisual"   ,0,2},;
		    { "Incluir"            , "AxInclui"   ,0,3},;
		    { "Alterar"            , "AxAltera"       ,0,4},; 
		    { "Excluir"            , "u_DelTerm"       ,0,5},;
		    { "Impr.Termo Resp."   , "u_CDTMSR01(.F.)",0,4},;
		    { "Reimpr.Termo Resp." , "u_CDTMSR01(.T.)",0,4},;
		    { "Cancela Termo Resp.", "u_CDTMSR02"     ,0,2},;
		    { "Import. EDI"        , "u_CDTMSEDI()"   ,0,4},;
		    { "Processamento"      , "u_CDTMPROC()"   ,0,4},;
		    { "Faturas	    "      , "u_CDTMFATU()"   ,0,4},;
		    { "Legenda"            , "U_CDTMSLEG"     , 0,2}}
		    //consulta Ocorrencias
		    
// O parâmetro indica se é reimpressão
DbSelectArea("ZZ4")
DbSetOrder(1) // ZZ4_FILIAL+ZZ4_TPMOV+ZZ4_TPDOC+ZZ4_SERIE+ZZ4_DOC+ZZ4_CLIFOR+ZZ4_LOJA
DbSeek(xFilial("ZZ4"),.F.)

mBrowse(001,040,200,390,"ZZ4",,,,,,aCores)

Return(.T.)
*
*************************
User Function CDTMSR02()
*************************
*
// Perguntar primeiro se o conhecimento já foi emitido
If !Empty(ZZ4->ZZ4_CONHEC)
	Alert("Conhecimento já emitido para essa nota")
	Return(.T.)
ElseIf Empty(ZZ4->ZZ4_NROTER)
	Alert("Termo de Responsabilidade não Emitido")
	Return(.T.)                                   
EndIf
nOpca := AxVisual("ZZ4",Recno(),2)     
If nOpca == 1 // Confirmou a Operação
	RecLock("ZZ4",.F.)   
	ZZ4->ZZ4_CONHEC := "    "
	ZZ4->(MsUnLock())
	Alert("Termo de Responsabilidade Cancelado")
EndIf
Return(.T.)
*
************************
User Function CDTMSLEG() // ok
************************
*

BrwLegenda(cCadastro,"Legenda",{{"DISABLE"    ,"Termo Resp. e Conhec. Emitidos"},;
{"BR_AMARELO" ,"Termo Resp. Emitido"},;
{"BR_PRETO"   ,"Conhec. Emitido"},;
{"ENABLE"     ,"Em Aberto"}})
Return(.T.)
*
***********************
User Function ClearFrt() //ok
***********************
*
// Como alterou a base da informação, zera tudo pra não ter erro de cálculo
M->ZZ4_DOC      := CriaVar("ZZ4_DOC")
M->ZZ4_SERIE    := CriaVar("ZZ4_SERIE")
M->ZZ4_CDROMA   := CriaVar("ZZ4_CDROMA")
M->ZZ4_DTNOTA   := CriaVar("ZZ4_DTNOTA")
M->ZZ4_CLIFOR   := CriaVar("ZZ4_CLIFOR")
M->ZZ4_LOJA     := CriaVar("ZZ4_LOJA")
M->ZZ4_NOME     := CriaVar("ZZ4_NOME")
M->ZZ4_VALMER   := CriaVar("ZZ4_VALMER")
M->ZZ4_VAL_ST   := CriaVar("ZZ4_VAL_ST")
M->ZZ4_VLRNF    := CriaVar("ZZ4_VLRNF")
M->ZZ4_PESO     := CriaVar("ZZ4_PESO")
M->ZZ4_NROTER   := CriaVar("ZZ4_NROTER")
M->ZZ4_TRANSP   := CriaVar("ZZ4_TRANSP")
M->ZZ4_CGC      := CriaVar("ZZ4_CGC")
M->ZZ4_NOMTR    := CriaVar("ZZ4_NOMTR")
M->ZZ4_EST      := CriaVar("ZZ4_EST")
M->ZZ4_COD_MU   := CriaVar("ZZ4_COD_MU")
M->ZZ4_MUNIC    := CriaVar("ZZ4_MUNIC")
M->ZZ4_VRNFBS   := CriaVar("ZZ4_VRNFBS")
M->ZZ4_PESOBS   := CriaVar("ZZ4_PESOBS")
*
******************************
User Function ValWhen(_cCampo) //ok
******************************
*
If _cCampo == "ZZ4_SERIE"
	Return((M->ZZ4_TPMOV+M->ZZ4_TPDOC == "ED") .Or.;
	(M->ZZ4_TPMOV+M->ZZ4_TPDOC == "SN"  .And. !Empty(M->ZZ4_DOC)) .And. INCLUI)
ElseIf _cCampo == "ZZ4_CDROMA"
	Return(M->ZZ4_TPMOV+M->ZZ4_TPDOC == "SN" .And. INCLUI .And. Empty(M->ZZ4_DOC))
ElseIf _cCampo == "ZZ4_CLIFOR"
	Return(M->ZZ4_TPMOV+M->ZZ4_TPDOC == "ED" .And. INCLUI)
ElseIf _cCampo == "ZZ4_LOJA"
	Return(M->ZZ4_TPMOV+M->ZZ4_TPDOC == "ED" .And. INCLUI)
EndIf
Return(.T.)
*
*******************************
User Function ValDocto(_cCampo) //ok
*******************************
*
_lVolta := .T.
If M->ZZ4_TPMOV+M->ZZ4_TPDOC=="SN" // Saída Normal
	
	_lVolta := .F.
	
	If _cCampo $ "ZZ4_DOC//ZZ4_SERIE"
		SF2->(DbSetOrder(1)) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		_lVolta := SF2->(DbSeek(xFilial("SF2")+M->ZZ4_DOC+AllTrim(M->ZZ4_SERIE),.F.))
		If _lVolta
			M->ZZ4_CDROMA := Space(Len(M->ZZ4_CDROMA))
		EndIf
	ElseIf _cCampo == "ZZ4_CDROMA"
		SF2->(DBOrderNickName("SF2CDROMA")) // F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO
		_lVolta := SF2->(DbSeek(xFilial("SF2")+M->ZZ4_CDROMA,.F.))
		If _lVolta
			M->ZZ4_DOC   := Space(Len(M->ZZ4_DOC))
			M->ZZ4_SERIE := Space(Len(M->ZZ4_SERIE))
		EndIf
	EndIf
	
	// Qual o % de ICM ?
	// Conforme Rosangela:
	// 	Para clientes não contribuintes -> 12%
	//	Para Clientes contribuintes:
	//		Se for das regiões Norte/Nordeste/Centro-Oeste + Estado do Espírito Santo -> 7%
	//		Demais regiões -> 12%
	M->ZZ4_ICM := 0
	If _lVolta
		If SF2->F2_SERIE == '1  ' .And. SF2->F2_TIPO == "N"
			If SF2->F2_TIPOCLI == "R" .And. SF2->F2_EST $ SUPERGETMV("MV_NORTE")
				M->ZZ4_ICM := 7
			Else
				M->ZZ4_ICM := 12
			EndIf
		EndIf
		// Por enquanto pego somente as informações da nota/romaneio corrente
		M->ZZ4_DTNOTA := SF2->F2_EMISSAO
		M->ZZ4_CLIFOR := SF2->F2_CLIENTE
		M->ZZ4_LOJA   := SF2->F2_LOJA
		If SF2->F2_TIPO $ "DB" // Devolução de compras ou envio para beneficiamento -> usa fornacedor
			SA2->(DbSetOrder(1))
			SA2->(DbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.))
			M->ZZ4_NOME   := SA2->A2_NOME
			M->ZZ4_EST    := SA2->A2_EST
			M->ZZ4_COD_MU := SA2->A2_COD_MUN
			M->ZZ4_MUNIC  := SA2->A2_MUN
		Else
			SA1->(DbSetOrder(1))
			SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.))
			M->ZZ4_NOME   := SA1->A1_NOME
			M->ZZ4_EST    := SA1->A1_EST
			M->ZZ4_COD_MU := SA1->A1_COD_MUN
			M->ZZ4_MUNIC  := SA1->A1_MUN
		EndIf
		M->ZZ4_VALMER := SF2->F2_VALMERC
		M->ZZ4_VAL_ST := SF2->F2_ICMSRET
		M->ZZ4_VLRNF  := SF2->F2_VALBRUT
		M->ZZ4_PESO   := SF2->F2_PBRUTO
		M->ZZ4_TRANSP := SF2->F2_TRANSP
		M->ZZ4_CGC    := POSICIONE("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"A4_CGC")
		M->ZZ4_NOMTR  := POSICIONE("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"A4_NOME")
		M->ZZ4_VRNFBS := SF2->F2_VALBRUT
		M->ZZ4_PESOBS := SF2->F2_PBRUTO
		M->ZZ4_ESPECI := SF2->F2_ESPECI1
		M->ZZ4_VOLUME := SF2->F2_VOLUME1
	Else
		M->ZZ4_DTNOTA := CriaVar("ZZ4_DTNOTA")
		M->ZZ4_CLIFOR := CriaVar("ZZ4_CLIFOR")
		M->ZZ4_LOJA   := CriaVar("ZZ4_LOJA")
		M->ZZ4_NOME   := CriaVar("ZZ4_NOME")
		M->ZZ4_VALMER := CriaVar("ZZ4_VALMER")
		M->ZZ4_VAL_ST := CriaVar("ZZ4_VAL_ST")
		M->ZZ4_VLRNF  := CriaVar("ZZ4_VLRNF")
		M->ZZ4_PESO   := CriaVar("ZZ4_PESO")
		M->ZZ4_TRANSP := CriaVar("ZZ4_TRANSP")
		M->ZZ4_CGC    := CriaVar("ZZ4_CGC")
		M->ZZ4_EST    := CriaVar("A1_EST")
		M->ZZ4_COD_MU := CriaVar("A1_COD_MUN")
		M->ZZ4_MUNIC  := CriaVar("A1_MUN")
	EndIf
//	u_CalcFrt() // Recalcula o valor do frete
EndIf
Return(_lVolta)
*
***********************
User Function CalcFrt()  //ok
***********************
*
// Recalcula o valor do frete
// Calcular o frete somente se os campos Cód.Transp., Estado, Cód.Munic., Nro.Docto ou Nro./Serie Romaneio estiverem preenchidos.
// zERA TODOS OS VALORES DO CÁLCULO

M->ZZ4_FRTPS  := 0.00
M->ZZ4_ADVL   := 0.00
M->ZZ4_GRIS   := 0.00
M->ZZ4_PED    := 0.00
M->ZZ4_TAXA   := 0.00
M->ZZ4_VLICM  := 0.00
If M->ZZ4_VR_NEG == M->ZZ4_TOT // Somente zera o Vlr. Negociado se for igual ao total calculado
	M->ZZ4_VR_NEG := 0.00
EndIf
M->ZZ4_TOT    := 0.00
//
// Buscar o CNPJ da transportadora na SE4, pois apesas de ter o gatilho para atualização desse campo,
// quando houve troca da transportadora esta função é chamada no X3_VLDUSER e ainda não chamou o gatilho
// que consequentemente o CNPJ pode estar errado.
//
M->ZZ4_CGC    := POSICIONE("SA4",1,xFilial("SA4")+M->ZZ4_TRANSP,"A4_CGC")
//
// Busca no ZZ3 uma tabela da transportadora para iniciar o cálculo
// ZZ3->(DbSetOrder(2)) // ZZ3_FILIAL+ZZ3_CGC+ZZ3_EST+ZZ3_COD_MU

// Pimeiro procuro a chave exata
_lAcheiTab := .T. // ZZ3->(DbSeek(xFilial("ZZ3")+M->ZZ4_CGC+M->ZZ4_EST+M->ZZ4_COD_MU,.F.))

If !_lAcheiTab
	// Se não achar, procuro com a raiz do CGC mais UF + cod.mun.
	ZZ3->(DbSeek(xFilial("ZZ3")+Left(M->ZZ4_CGC,8),.F.))
	Do While ZZ3->ZZ3_FILIAL == xFilial("ZZ3") .And. Left(ZZ3->ZZ3_CGC,8) == Left(M->ZZ4_CGC,8) .And. !ZZ3->(Eof())
		If ZZ3->ZZ3_EST == M->ZZ4_EST .And. ZZ3->ZZ3_COD_MU == M->ZZ4_COD_MU
			_lAcheiTab := .T.
			Exit
		EndIf
		ZZ3->(DbSkip())
	EndDo
	
	If !_lAcheiTab
		// Se não achar procuro um código de município genérico "*"
		_lAcheiTab := ZZ3->(DbSeek(xFilial("ZZ3")+M->ZZ4_CGC+M->ZZ4_EST+"*"+Space(Len(ZZ3->ZZ3_COD_MU)-1),.F.))
		If !_lAcheiTab
			ZZ3->(DbSeek(xFilial("ZZ3")+Left(M->ZZ4_CGC,8),.F.))
			Do While ZZ3->ZZ3_FILIAL == xFilial("ZZ3") .And. Left(ZZ3->ZZ3_CGC,8) == Left(M->ZZ4_CGC,8) .And. !ZZ3->(Eof())
				If ZZ3->ZZ3_EST == M->ZZ4_EST .And. AllTrim(ZZ3->ZZ3_COD_MU) == "*"
					_lAcheiTab := .T.
					Exit
				EndIf
				ZZ3->(DbSkip())
			EndDo
		EndIf
	EndIf
EndIf
If _lAcheiTab .Or. ZZ4->ZZ4_TPFRET=="F" // Não Achou Tabela ou Tipo do frete é FOB não recalcula mais nada
	Return(.T.)
EndIf

// Início do cálculo
// Cálculo do Frete Peso
// Se o FRETE PESO for Normal simplesmente multiplica // se for Excedente, o valor é para os primeiros 100 Quilos
// e calcular o excedente a 100 quilos à parte
If ZZ3->ZZ3_TIPO == "N"
	M->ZZ4_FRTPS  := Round((M->ZZ4_PESOBS * ZZ3->ZZ3_PESON),2)
Else
	M->ZZ4_FRTPS  := Round(ZZ3->ZZ3_PESON + (Max(0,(M->ZZ4_PESOBS-100)) * ZZ3->ZZ3_PESOE),2)
EndIf
M->ZZ4_FRTPS := Max(M->ZZ4_FRTPS,ZZ3->ZZ3_MINFRT)

// Cálculo do Ad-valorem
M->ZZ4_ADVL  := Round((M->ZZ4_VRNFBS * ZZ3->ZZ3_ADVPER) / 100,2)

// Calcula o minimo de ad-valorem
M->ZZ4_ADVL := Max(M->ZZ4_ADVL,ZZ3->ZZ3_ADVMIN)

// Cálculo do GRIS
M->ZZ4_GRIS := Round((M->ZZ4_VRNFBS * ZZ3->ZZ3_GRISPE) / 100,2)

// Calcula o minimo do GRIS
M->ZZ4_GRIS := Max(M->ZZ4_GRIS,ZZ3->ZZ3_GRISMI)

// Cálculo do valor do pedágio -> o Valor na tabela ZZ3_PEDAGI é para cada 100 kilos ou fração
M->ZZ4_PED := Int(M->ZZ4_PESOBS / 100)
If (M->ZZ4_PESOBS%100) > 0
	M->ZZ4_PED := M->ZZ4_PED + 1
EndIf
M->ZZ4_PED := (M->ZZ4_PED * ZZ3->ZZ3_PEDAGI)

// Cálculo de taxas
M->ZZ4_TAXA := ZZ3->ZZ3_TAXAS

// Se % ICM > 0 -> Adicionar o valor do ICM em cada verba
If M->ZZ4_ICM > 0
	_nMkUp := (100-M->ZZ4_ICM)
	M->ZZ4_FRTPS := Round((M->ZZ4_FRTPS / _nMkUp) * 100,2)
	M->ZZ4_ADVL  := Round((M->ZZ4_ADVL  / _nMkUp) * 100,2)
	M->ZZ4_GRIS  := Round((M->ZZ4_GRIS  / _nMkUp) * 100,2)
	M->ZZ4_TAXA  := Round((M->ZZ4_TAXA  / _nMkUp) * 100,2)
	If ZZ3->ZZ3_ICMPED == "S"
		M->ZZ4_PED   := Round((M->ZZ4_PED   / _nMkUp) * 100,2)
	EndIf
EndIf
M->ZZ4_TOT   := (M->ZZ4_FRTPS+M->ZZ4_ADVL+M->ZZ4_GRIS+M->ZZ4_TAXA+M->ZZ4_PED)
M->ZZ4_VLICM := Round((M->ZZ4_TOT * M->ZZ4_ICM) / 100,2)
If M->ZZ4_VR_NEG == 0
	M->ZZ4_VR_NEG := M->ZZ4_TOT
Endif
Return(.T.)
*
*************************
User Function CrieFrete() //ok
*************************
*
// Esta função é chamada pela CSFATUR, que no término de cada nota cria registro na tabela
// ZZ4 - Controle de fretes quando:
// SF2->F2_SERIE == "1  " .And. !Empty(SF2->F2_TRANSP) .And. SF2->F2_TIPO == "N" e tem tabela
// de frete cadastrado na ZZ3.
//
// Em 11/09/12 o Wellington informou que tem que criar registro do frete para poder imprimir o termo
// de responsabilidade, independente se haverá ou não valor de frete.
// Com isso, os campos de valor base de frete, valor de frete e valor de frete negociano não poderão
// ser campos obrigatórios.
// Ainda informa que a condição para criar o registro do frete é a existência de uma transportadora na
// nota fiscal.

                       
// Buscar o código da cidade no SA1 ou SA2
If SF2->F2_TIPO $ "DB" // Devolução de compras ou envio para beneficiamento -> usa fornacedor
	_cCodMun := Posicione("SA2",1,xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A2_COD_MUN")
Else
	_cCodMun := Posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_COD_MUN")
EndIf

// Buscar o CNPJ da Transportadora
_cCGCTrp := Posicione("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"A4_CGC")

// Verificar se tem tabela de fretes para essa transportadora
// ZZ3->(DbSetOrder(2)) // ZZ3_FILIAL+ZZ3_CGC+ZZ3_EST+ZZ3_COD_MU
// Pimeiro procuro a chave exata
_lAcheiTab  := .T. // ZZ3->(DbSeek(xFilial("ZZ3")+_cCGCTrp+SF2->F2_EST+_cCodMun,.F.))
If !_lAcheiTab
	// Se não achar, procuro com a raiz do CGC mais UF + cod.mun.
	ZZ3->(DbSeek(xFilial("ZZ3")+Left(_cCGCTrp,8),.F.))
	Do While ZZ3->ZZ3_FILIAL == xFilial("ZZ3") .And. Left(ZZ3->ZZ3_CGC,8) == Left(_cCGCTrp,8) .And. !ZZ3->(Eof())
		If ZZ3->ZZ3_EST == SF2->F2_EST .And. ZZ3->ZZ3_COD_MU == _cCodMun
			_lAcheiTab := .T.
			Exit
		EndIf
		ZZ3->(DbSkip())
	EndDo
	
	If !_lAcheiTab
		// Se não achar procuro um código de município genérico "*"
		_lAcheiTab := ZZ3->(DbSeek(xFilial("ZZ3")+_cCGCTrp+SF2->F2_EST+"*"+Space(Len(ZZ3->ZZ3_COD_MU)-1),.F.))
		If !_lAcheiTab
			ZZ3->(DbSeek(xFilial("ZZ3")+Left(_cCGCTrp,8),.F.))
			Do While ZZ3->ZZ3_FILIAL == xFilial("ZZ3") .And. Left(ZZ3->ZZ3_CGC,8) == Left(_cCGCTrp,8) .And. !ZZ3->(Eof())
				If ZZ3->ZZ3_EST == SF2->F2_EST .And. AllTrim(ZZ3->ZZ3_COD_MU) == "*"
					_lAcheiTab := .T.
					Exit
				EndIf
				ZZ3->(DbSkip())
			EndDo
		EndIf
	EndIf
EndIf

/*/
If !_lAcheiTab // Não Achou Tabela
	Return(.T.)
EndIf
/*/

_aTMSArea := GetArea()

RegToMemory("ZZ4",.T.)

M->ZZ4_FILIAL := xFilial("ZZ4")
M->ZZ4_TPMOV  := "S" // Saída
M->ZZ4_TPDOC  := SF2->F2_TIPO  // "N" - Normal
M->ZZ4_DOC    := SF2->F2_DOC
M->ZZ4_SERIE  := SF2->F2_SERIE
//M->ZZ4_CDROMA
M->ZZ4_DTNOTA := SF2->F2_EMISSAO
M->ZZ4_CLIFOR := SF2->F2_CLIENTE
M->ZZ4_LOJA   := SF2->F2_LOJA
If SF2->F2_TIPO $ "DB" // Devolução de compras ou envio para beneficiamento -> usa fornacedor
	SA2->(DbSetOrder(1))
	SA2->(DbSeek(xFilial("SA2")+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.))
	M->ZZ4_NOME   := SA2->A2_NOME
	M->ZZ4_EST    := SA2->A2_EST
	M->ZZ4_COD_MU := SA2->A2_COD_MUN
	M->ZZ4_MUNIC  := SA2->A2_MUN
Else
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,.F.))
	M->ZZ4_NOME   := SA1->A1_NOME
	M->ZZ4_EST    := SA1->A1_EST
	M->ZZ4_COD_MU := SA1->A1_COD_MUN
	M->ZZ4_MUNIC  := SA1->A1_MUN
EndIf
M->ZZ4_VALMER  := SF2->F2_VALMERC
M->ZZ4_VAL_ST  := SF2->F2_ICMSRET
M->ZZ4_VLRNF   := SF2->F2_VALBRUT
M->ZZ4_PESO    := SF2->F2_PBRUTO
//M->ZZ4_NROTER // Numero do termo de responsabilidade
M->ZZ4_TRANSP  := SF2->F2_TRANSP
M->ZZ4_CGC     := POSICIONE("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"A4_CGC")
M->ZZ4_NOMTR   := POSICIONE("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"A4_NOME")
M->ZZ4_TPFRET := SF2->F2_TPFRETE
M->ZZ4_ESPECI  := SF2->F2_ESPECI1
M->ZZ4_VOLUME  := SF2->F2_VOLUME1

// ZZ4_ICM
If SF2->F2_SERIE == '1  ' .And. SF2->F2_TIPO == "N"
	If SF2->F2_TIPOCLI == "R" .And. SF2->F2_EST $ SUPERGETMV("MV_NORTE")
		M->ZZ4_ICM := 7
	Else
		M->ZZ4_ICM := 12
	EndIf
EndIf
M->ZZ4_VRNFBS := SF2->F2_VALBRUT
M->ZZ4_PESOBS := SF2->F2_PBRUTO

/*/
As Variáveis abaixo serão preenchidas no cálculo do frete
ZZ4_FRTPS	N	11
ZZ4_ADVL	N	11
ZZ4_GRIS	N	11
ZZ4_PED		N	11
ZZ4_TAXA	N	11
ZZ4_VLICM	N	11
ZZ4_TOT		N	11
ZZ4_VR_NEG	N	11
ZZ4_SERCON	C	3
ZZ4_CONHEC	C	9
ZZ4_TOTCON	N	11
/*/


//u_CalcFrt() // Recalcula o valor do frete
//
// Como o campo ZZ4_VR_NEG é obrigatório, assumo o mesmo do valor total
M->ZZ4_VR_NEG := M->ZZ4_TOT

DbSelectArea("SX3")
_aTMSSx3 := GetArea()

DbSelectArea("ZZ4")
DbSetOrder(1) // ZZ4_FILIAL+ZZ4_TPMOV+ZZ4_TPDOC+ZZ4_SERIE+ZZ4_DOC+ZZ4_CLIFOR+ZZ4_LOJA
If DbSeek(xFilial("ZZ4")+"S"+M->ZZ4_TPDOC+M->ZZ4_SERIE+M->ZZ4_DOC+M->ZZ4_CLIFOR+M->ZZ4_LOJA,.F.)
	RecLock("ZZ4",.F.)
Else
	RecLock("ZZ4",.T.)
EndIf

SX3->(DbSetOrder(1))
SX3->(DbSeek("ZZ4"))
Do While SX3->(!Eof()) .And. (SX3->X3_ARQUIVO=="ZZ4")
	If SX3->X3_CONTEXT # "V"
		_cCpo0 := AllTrim(SX3->X3_CAMPO)
		_cCpo1 := "M->"+AllTrim(SX3->X3_CAMPO)
		FieldPut(FieldPos(_cCpo0),&_cCpo1.)
	EndIf
	SX3->(DbSkip())
EndDo
ZZ4->(MsUnLock())

RestArea(_aTMSSx3)
RestArea(_aTMSArea)
Return(.T.)
*
************************
User Function CDTMSEDI() //ok
************************
*
// Tratamento dos arquivos enviados pelas transportadoras para
// criação do conhecimento de transporte e fatura
// Primeiro processar os arquivos .REM e depois os .TXT
Private oProcess := NIL

If !"ADMINISTRADOR" $ Upper(cUserName) .And. !"ZACARIAS" $ Upper(cUserName) .And. !"ROBERTO" $ Upper(cUserName)
	Alert("Rotina em desenvolvimento - Somente Administrador")
	Return(.T.)
EndIf

// Guarda dados da área, empresa/Filial atual
_MyArea := GetArea()
_MyFil  := cFilAnt
_MyEmp  := cNumEmp

If FWCodEmp()+FWCodFil() # "0101" /// Cobrecom Itu
	Alert("Rotina disponível somente para usuários da matriz")
	Return(.T.)
EndIf
If MsgBox("Esta rotina tem o objetivo de ler os arquivos EDI - Proceda"+Chr(13)+;
	"enviados pelas transportadoras e atualizar a base de dados"+Chr(13)+;
	"nas tabelas ZZ4, ZZ5, lançar os conhecimentos de transportes"+Chr(13)+;
	"criando o contas a pagar e as faturas a pagar, permitindo ao"+Chr(13)+;
	"usuáro a emissão de relatórios de divergências dos conhecimentos"+Chr(13)+;
	"com os fretes contratados e as faturas ainda não recebidas."+Chr(13)+Chr(13)+;
	"Os Arquivos deverão estar na pasta \EDI com extensão .TXT"+Chr(13)+;
	"que após o processamento serão renomeados para .PRC - processado.","Confirma O Processamento?","YesNo")
	
	//Verifica se tem arquivos para processar
	
	aFiles := ARRAY(ADIR("\EDI\*.TXT"))
	ADIR("\EDI\*.TXT",aFiles)
	If Len(aFiles) == 0
		Alert("Não há arquivos a processar")
		Return(.T.)
	EndIf
	oProcess := MsNewProcess():New({|lEnd| RunProc(lEnd,oProcess)},"Processando","Lendo...",.T.)
	oProcess:Activate()
	Alert("Processamento Concluído")
EndIf
cFilAnt := _MyFil
cNumEmp := _MyEmp
SM0->(DbSetOrder(1))
SM0->(DbSeek(cNumEmp,.F.))
RestArea(_MyArea)
Return(.T.)
*
**********************************
Static Function RunProc(lEnd,oObj)  //ok
**********************************
*
// A ordem de processamento deve ser:
// 1 - Conhecimentos
// 2 - Faturas
// 3 - Ocorrências
_cTipoNow := "CON" // Primeiro processar os conhecimentos depois as faturas e depois as ocorrências
_cNome := "Conhecimentos de Transporte"
_nArqNow := 0
_nQtLoop := Len(aFiles)*3
oObj:SetRegua1()
For _nArqs := 1 to _nQtLoop
	If ++_nArqNow > Len(aFiles) // Na primeira vez ele não entra pois _nArqNow tem valor 0;
		// e a variável _cTipoNow já está definida com "CON"
		_nArqNow := 1
		If _cTipoNow == "CON"
			_cTipoNow := "COB" // Primeiro processar os conhecimentos depois as faturas e depois as ocorrências
			_cNome := "Faturas"
		Else
			_cTipoNow := "OCO" // Primeiro processar os conhecimentos depois as faturas e depois as ocorrências
			_cNome := "Ocorrências"
		EndIf
	EndIf
	
	oObj:IncRegua1("Lendo Arquivo: " + aFiles[_nArqNow])
	
	// Abre o arquivo
	_cArqT   := "\EDI\"+aFiles[_nArqNow]
	_cArqNew := Left(_cArqT,Len(_cArqT)-3) + "PRC"
	nHdl := FT_FUSE(_cArqT)
	If nHdl <= 0 // Deu erro na abertura do arquivo
		Loop
	Endif
	
	_nQtLin := FT_FLASTREC()
	If _nQtLin <= 0 // Não tem dados neste arquivo
		FT_FUSE() //Fecha arquivo
		If _cTipoNow == "OCO" // Última passagem do ForNext
			fRename(_cArqT,_cArqNew)
		EndIf
		Loop
	Endif
	
	// Le a primeira linha e verifica o tipo
	_cLinha := FT_FREADLN()
	_cTpArq := Substr(_cLinha,84,3)
	_cTpReg := Substr(_cLinha,01,3)
	If _cTpArq # _cTipoNow .Or. _cTpReg # "000"  // Primeiro processar os conhecimentos depois as faturas e depois as ocorrências
		FT_FUSE() //Fecha arquivo
		If _cTipoNow == "OCO" // Última passagem do ForNext
			fRename(_cArqT,_cArqNew)
		EndIf
		Loop
	Endif
	
	_cCnpj := ""
	_cUltDoc := " "
	
	oObj:SetRegua2(_nQtLin) //_nRegs)
	oObj:IncRegua2(_cNome) // Já acrescenta 1
	FT_FSKIP() // Pula para a próxima linha
	
	For _nLinAtu := 2 to _nQtLin
		_cLinha := FT_FREADLN()
		If Left(_cLinha,3) $ "//320//340//350" //
			// Aqui nada interessa
		ElseIf Left(_cLinha,3) $ "321//341//351" //  cnpj do emitente
			_cCnpj := Substr(_cLinha,04,014)
		ElseIf Left(_cLinha,3) == "322" // Dados do conhecimento
			_SERIE   :=        Left(Substr(_cLinha,014,005),3)
			_DOC     := StrZero(Val(Substr(_cLinha,019,012)),9)
			_CNPJTra :=             Substr(_cLinha,205,014)
			_CNPJIFC :=             Substr(_cLinha,219,014)
			_AcaoCon :=             Substr(_cLinha,673,001) // Incluir / Complementar // Excluir
			_TpFrete :=             Substr(_cLinha,039,001) // Cif ou Fob
			If Left(_CNPJIFC,8) == "02544042" /// .And. _TpFrete == "C" // É da ifc e é Fob
				If Substr(_CNPJIFC,9,4) == "0001" // É Itu
					cNumEmp := Left("0101"+Space(Len(cNumEmp)),Len(cNumEmp))  // crio o pedido na filial
					cFilAnt := "01"
				ElseIf Substr(_CNPJIFC,9,4) == "0002" // É 3 Lagoas
					cNumEmp := Left("0102"+Space(Len(cNumEmp)),Len(cNumEmp))  // crio o pedido na filial
					cFilAnt := "02"
				EndIf
				SM0->(DbSetOrder(1))
				SM0->(DbSeek(Left(cNumEmp,4),.F.))
				If _AcaoCon == "I" // Incluir
					_TipoCon := Substr(_cLinha,674,01) //Normal,Complementar,conh.Devolução,normal Entrada,conh.Reentrega,normal Saida
					//normal Trans.interna,compl.entrada-X,compl.saida-Y,compl.transf.interna-Z
					If _TipoCon $ "NDR" // Só trato os  Normal,conh.Devolução,conh.Reentrega,normal Saida
						//normal Trans.interna,compl.entrada-X,compl.saida-Y,compl.transf.interna-Z
						If _cUltDoc # _SERIE+_DOC
							//
							_cUltDoc := _SERIE+_DOC
							_EMISSAO := Substr(_cLinha,031,08)
							_EMISSAO := Ctod(Left(_EMISSAO,2) + "/" + Substr(_EMISSAO,3,2) + "/" + Right(_EMISSAO,4))
							_TotFret := Substr(_cLinha,047,15)
							_TotFret := Val(Left(_TotFret,13) + "." + Right(_TotFret,2))
							_BasICMS := Substr(_cLinha,062,15)
							_BasICMS := Val(Left(_BasICMS,13) + "." + Right(_BasICMS,2))
							_PerICMS := Substr(_cLinha,077,04)
							_PerICMS := Val(Left(_PerICMS,2) + "." + Right(_PerICMS,2))
							_ValICMS := Substr(_cLinha,081,15)
							_ValICMS := Val(Left(_ValICMS,13) + "." + Right(_ValICMS,2))
							_ValPeda := Substr(_cLinha,171,15)
							_ValPeda := Val(Left(_ValPeda,13) + "." + Right(_ValPeda,2))
							_ChvCTe  := Substr(_cLinha,681,44)
							_DtAutor := Substr(_cLinha,725,08) //
							_DtAutor := Ctod(Left(_DtAutor,2) + "/" + Substr(_DtAutor,3,2) + "/" + Right(_DtAutor,4))
							_HrAutor := Substr(_cLinha,733,04)
							_Protoco := Substr(_cLinha,737,15)
							
							//
							//Gravo o ZZ5 - Conhecimento
							DbSelectArea("ZZ5")
							DbSetOrder(1) // ZZ5_FILIAL+ZZ5_CNPJ+ZZ5_DOC+ZZ5_SERIE
							If !DbSeek(xFilial("ZZ5") + _CNPJTra + _DOC + _SERIE,.F.) // Se não tem... criar um para dizer que está cancelado
								DbSelectArea("SA2")
								DbSetOrder(3) // A2_FILIAL+A2_CGC
								DbSeek(xFilial("SA2") + _CNPJTra,.F.)
								
								DbSelectArea("ZZ5")
								RecLock("ZZ5",.T.)
								ZZ5->ZZ5_FILIAL := xFilial("ZZ5")
								ZZ5->ZZ5_FORNEC := SA2->A2_COD
								ZZ5->ZZ5_LOJA   := SA2->A2_LOJA
								ZZ5->ZZ5_NOME   := SA2->A2_NOME
								ZZ5->ZZ5_CNPJ   := _CNPJTra
								ZZ5->ZZ5_SERIE  := _SERIE
								ZZ5->ZZ5_DOC    := _DOC
								ZZ5->ZZ5_EMISSA := _EMISSAO
								ZZ5->ZZ5_TOTFRE := _TotFret
								ZZ5->ZZ5_BSICMS := _BasICMS
								ZZ5->ZZ5_ICM    := _PerICMS
								ZZ5->ZZ5_VALICM := _ValICMS
								ZZ5->ZZ5_PEDAGI :=_ValPeda
								ZZ5->ZZ5_STATUS := "1" //0=Cancelado;1=Inserido;2=Validado SEFAZ;3=Inserido Doc.Entrada;4=Gerada a Fatura;5=Rejeitado SEFAZ
								ZZ5->ZZ5_CHVCTE := _ChvCTe
								ZZ5->ZZ5_PROTOC := _Protoco
								ZZ5->ZZ5_DTAUT  := _DtAutor
								ZZ5->ZZ5_HORA   := _HrAutor
								ZZ5->(MsUnLock())
							EndIf
						EndIf
						//
						If _TipoCon == "N" // Só trato o Normal nas tabelas ZZ4
							//
							DbSelectArea("ZZ5")
							DbSetOrder(1) // ZZ5_FILIAL+ZZ5_CNPJ+ZZ5_DOC+ZZ5_SERIE
							DbSeek(xFilial("ZZ5") + _CNPJTra + _DOC + _SERIE,.F.) // Se não tem... criar um para dizer que está cancelado
							//
							DbSelectArea("ZZ4")
							DbSetOrder(2) // ZZ4_FILIAL+ZZ4_DOC+ZZ4_SERIE
							For _nNotas := 233 to 672 Step 11 //
								If Val(Substr(_cLinha,_nNotas+3,8)) > 0
									_cSerie := Substr(_cLinha,_nNotas,3)
									_cNota  := StrZero(Val(Substr(_cLinha,_nNotas+3,8)),9)
									If !DbSeek(xFilial("ZZ4")+_cNota+_cSerie,.F.)
										// Se não achei o ZZ4
										RecLock("ZZ4",.T.)
										ZZ4->ZZ4_FILIAL := xFilial("ZZ4")
										ZZ4->ZZ4_DOC    := _cNota
										ZZ4->ZZ4_SERIE  := _cSerie
										ZZ4->ZZ4_SERCON := _SERIE
										ZZ4->ZZ4_CONHEC := _DOC
										ZZ4->ZZ4_CNPJTR := _CNPJTra
										ZZ4->ZZ4_TOTCON := _TotFret
										ZZ4->(MsUnLock())
									Else
										/*/
										
										aqui...
										
										If _TipoCon == "N" // Só trato os  Normal,conh.Devolução,conh.Reentrega,normal Saida
											serie1
										ElseIf _TipoCon == "D" // Só trato os  Normal,conh.Devolução,conh.Reentrega,normal Saida
											serie2
										ElseIf _TipoCon == "R" // Só trato os  Normal,conh.Devolução,conh.Reentrega,normal Saida
											serie3
										EndIf
										/*/
										If Empty(ZZ4->ZZ4_SERCON) .And. Empty(ZZ4->ZZ4_CONHEC)
											// Grava serie, nro e valor
											RecLock("ZZ4",.F.)
											ZZ4->ZZ4_SERCON := _SERIE
											ZZ4->ZZ4_CONHEC := _DOC
											ZZ4->ZZ4_CNPJTR := _CNPJTra
											ZZ4->ZZ4_TOTCON := _TotFret
											ZZ4->(MsUnLock())
										ElseIf ZZ4->ZZ4_SERCON+ZZ4->ZZ4_CONHEC # _SERIE+_DOC
											// Esta nota está atrelada a outro conhecimento
											// Verificar se o conhecimento
											If _SERIE+_DOC < ZZ4->ZZ4_SERCON+ZZ4->ZZ4_CONHEC
												// Se este conhecimento é anterior
												// provavelmente (_SERIE+_DOC) esteja cancelado
											Else
												// Se este conhecimento for posterior
												// Provavelmente o anterior (ZZ4->ZZ4_SERCON+ZZ4->ZZ4_CONHEC) esteja cancelado
											EndIf
										EndIf
									EndIf
								EndIf
							Next
						EndIf
					ElseIf _AcaoCon == "C" // Complementar
					ElseIf _AcaoCon == "E" // EXCLUIR
						DbSelectArea("ZZ5")
						DbSetOrder(1) // ZZ5_FILIAL+ZZ5_CNPJ+ZZ5_DOC+ZZ5_SERIE
						If !DbSeek(xFilial("ZZ5") + _CNPJTra + _DOC + _SERIE,.F.) // Se não tem... criar um para dizer que está cancelado
							DbSelectArea("SA2")
							DbSetOrder(3) // A2_FILIAL+A2_CGC
							DbSeek(xFilial("SA2") + _CNPJTra,.F.)
							
							DbSelectArea("ZZ5")
							RecLock("ZZ5",.T.)
							ZZ5->ZZ5_FILIAL := xFilial("ZZ5")
							ZZ5->ZZ5_CNPJ   := _CNPJTra
							ZZ5->ZZ5_FORNEC := SA2->A2_COD
							ZZ5->ZZ5_LOJA   := SA2->A2_LOJA
							ZZ5->ZZ5_NOME   := SA2->A2_NOME
							ZZ5->ZZ5_SERIE  := _SERIE
							ZZ5->ZZ5_DOC    := _DOC
						Else
							RecLock("ZZ5",.F.)
						EndIf
						ZZ5->ZZ5_STATUS := "0" //0=Cancelado;1=Inserido;2=Validado SEFAZ;3=Inserido Documento de Entrada;4=Gerada a Fatura;5=Rejeitado SEFAZ
						ZZ5->(MsUnLock())
						DbSelectArea("ZZ4")
						DbSetOrder(4) // ZZ4_FILIAL+ZZ4_CNPJTR+ZZ4_CONHEC+ZZ4_SERIE
						Do While DbSeek(xFilial("ZZ4") + _CNPJTra + _DOC + _SERIE,.F.)
							RecLock("ZZ4",.F.)
							ZZ4->ZZ4_CNPJTR := " "
							ZZ4->ZZ4_CONHEC := " "
							ZZ4->ZZ4_SERIE  := " "
							ZZ4->ZZ4_TOTCON := 0.00
							ZZ4->(MsUnLock())
						EndDo
					EndIf
				EndIf
			EndIf
		ElseIf Left(_cLinha,3) == "342" // Ocorrências de entrega
			_cCnpjIFC := Substr(_cLinha,04,014) // CNPJ do Emitente da Nota Fiscal
			_Serie   := Substr(_cLinha,018,003)// Série da Nota Fiscal
			_NumNf   := StrZero(Val(Substr(_cLinha,021,014)),9) //Número da Nota Fiscal
			_cCodEnt := Substr(_cLinha,029,002) // Código de Ocorrência na Entrega   
			_dDataOco:= Substr(_cLinha,031,008) // Data da Ocorrência  
			_dDataOco:= Ctod(Left(_dDataOco,2)+"/"+Substr(_dDataOco,3,2)+"/"+Right(_dDataOco,4))
			_cHoraOco:= Substr(_cLinha,039,004) // Hora da Ocorrência
			_cCodObs := Substr(_cLinha,043,002) // Código de Observação de Ocorrência na Entrada
			_cObs    := Substr(_cLinha,045,070) // Texto Livre para Observação
				
			DbSelectArea("ZZ9")
			DbSetOrder(1) // ZZ9_FILIAL+ZZ9_CNPJTR+ZZ9_NUMNF+ZZ9_SERIE
			If _cCnpjIFC  == "02544042000119" 
				_cFil := "01"
			ElseIf _cCnpjIFC == "02544042000208" 
				_cFil := "02"
			EndIf                    
			// _cCnpj é alimentada quando lido o registro 341 - CNPJ da transportadora
			If !DbSeek(_cFil + _cCnpj + _Serie + _NumNf + _cCodEnt + Dtos(_dDataOco) + _cHoraOco,.F.)
				RecLock("ZZ9",.T.)
				ZZ9->ZZ9_FILIAL := _cFil
				ZZ9->ZZ9_CNPJTR := _cCnpj
				ZZ9->ZZ9_SERIE  := _Serie
				ZZ9->ZZ9_NUMNF  := _NumNf
				ZZ9->ZZ9_CODENT := _cCodEnt
				ZZ9->ZZ9_DATAOC := _dDataOco
				ZZ9->ZZ9_HORAOC := _cHoraOco
				ZZ9->ZZ9_OBSOC  := _cCodObs
				ZZ9->ZZ9_OBS    := _cObs
				ZZ9->(MsUnLock())
			EndIf
		ElseIf Left(_cLinha,3) == "352" // Dados da Cobrança
			_cAcao  := Substr(_cLinha,167,01) // Incluir ou Excluir/cancelar
			_nFatur := Substr(_cLinha,019,09) //
			_Vencto := Substr(_cLinha,036,08)
			_Vencto := Ctod(Left(_Vencto,2) + "/" + Substr(_Vencto,3,2) + "/" + Right(_Vencto,4))
			_ValFat := Substr(_cLinha,044,15)
			_ValFat := Val(Left(_ValFat,13) + "." + Right(_ValFat,2))
			_CnpjCb := Substr(_cLinha,169,014) //CNPJ de quem vai pagar a fatura - Itu ou 3 Lagoas
		ElseIf Left(_cLinha,3) == "353" // Conhecimentos desta fatura
			If _cAcao == "I" // Trato somente as inclusões
				_SERIE   := Left(Substr(_cLinha,014,005),3)
				_DOC     := StrZero(Val(Substr(_cLinha,019,012)),9)
				_cCnpjCTe:= Substr(_cLinha,31,014) // CNPJ do Emitente do CTE // 
				_cCnpjCon:=  Substr(_cLinha,45,014) // CNPJ contra quem foi emitido o CTE
				_cCnpjCon:= "02544042000208" 
				_cCnpjCTe:= "76080738003355" 

				DbSelectArea("ZZ5")
				DbSetOrder(1) // ZZ5_FILIAL+ZZ5_CNPJ+ZZ5_DOC+ZZ5_SERIE
				If _cCnpjCon == "02544042000119" 
					_cFil := "01"
				ElseIf _cCnpjCon == "02544042000208" 
					_cFil := "02"
				EndIf
				If !DbSeek(_cFil+_cCnpjCTe+_DOC+_SERIE,.F.)
					DbSelectArea("SA2")
					DbSetOrder(3) // A2_FILIAL+A2_CGC
					DbSeek(xFilial("SA2") + _cCnpjCTe,.F.)
					
					DbSelectArea("ZZ5")
					RecLock("ZZ5",.T.)
					ZZ5->ZZ5_FILIAL := _cFil
					ZZ5->ZZ5_CNPJ   := _cCnpjCTe
					ZZ5->ZZ5_FORNEC := SA2->A2_COD
					ZZ5->ZZ5_LOJA   := SA2->A2_LOJA
					ZZ5->ZZ5_NOME   := SA2->A2_NOME
					ZZ5->ZZ5_DOC    := _DOC
					ZZ5->ZZ5_SERIE  := _SERIE
				Else
					RecLock("ZZ5",.F.)
				EndIf
				
				SA2->(DbSetOrder(3)) // A2_FILIAL+A2_CGC
				SA2->(DbSeek(xFilial("SA2") + _cCnpj,.F.))
				
				ZZ5->ZZ5_FORNFT := SA2->A2_COD
				ZZ5->ZZ5_LOJAFT := SA2->A2_LOJA
				ZZ5->ZZ5_CNPJFT := _cCnpj
				ZZ5->ZZ5_FATURA := _nFatur
				ZZ5->ZZ5_VALFAT := _ValFat
				ZZ5->ZZ5_VENCFA := _Vencto
				ZZ5->(MsUnLock())
			EndIf
		EndIf
		FT_FSKIP()
	Next
	FT_FUSE() //Fecha arquivo
	If _cTipoNow == "OCO" // Última passagem do ForNext
		fRename(_cArqT,_cArqNew)
	EndIf
//	Rename &(_cArqT) to &(_cArqNew)
Next
Return(.T.)
//_Cli1 := "1234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890"
//_Cli2 := "0        1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22        23        24        25        26        27        28        29        30        31        32        33        34        35        36        37        38        39        40        41        42        43        44        45        46        47        58        59        50        51        52        53        54        55        56        57        58        59        60        61        62        63        64        65        66        67        68        69        70"

*
************************
User Function CDTMPROC() //ok
************************
*
If MsgBox("Deseja Iniciar o Processamento?","Confirma?","YesNo")
	Processa({|| CDTMPRC()},"Em Execução")
	Alert("Processamento Concluído")
EndIf
Return(.T.)
*
*************************
Static Function CDTMPRC() // Revendo 01
*************************
*

//Obtem o codigo da entidade
cIdEnt := u_GetIDU()

DbSelectArea("ZZ5")
DbSetOrder(2) //ZZ5_FILIAL+ZZ5_STATUS+ZZ5_CNPJ+ZZ5_SERIE+ZZ5_DOC
ZZ5->(Dbseek(xFilial("ZZ5")+"1",.T.)) //0=Cancelado;1=Inserido;2=Validado SEFAZ;3=Inserido Documento de Entrada;4=Gerada a Fatura;5=Rejeitado SEFAZ
ProcRegua(LastRec())
Do While ZZ5->ZZ5_FILIAL == xFilial("ZZ5") .And. ZZ5->ZZ5_STATUS $ "12" .And. ZZ5->(!Eof())
	
	IncProc()
	
	_cChave := (ZZ5->ZZ5_FILIAL+ZZ5->ZZ5_STATUS+ZZ5->ZZ5_CNPJ+ZZ5->ZZ5_SERIE+ZZ5->ZZ5_DOC)
	If ZZ5->ZZ5_STATUS == "1" //0=Cancelado;1=Inserido;2=Validado SEFAZ;3=Inserido Documento de Entrada;4=Gerada a Fatura;5=Rejeitado SEFAZ
		FRSEFAZ(cIdEnt) //Consulta SEFAZ
	ElseIf ZZ5->ZZ5_STATUS == "2" //0=Cancelado;1=Inserido;2=Validado SEFAZ;3=Inserido Documento de Entrada;4=Gerada a Fatura;5=Rejeitado SEFAZ
		If Empty(ZZ5->ZZ5_FORNEC)
			SA2->(DbSetOrder(3))// A2_FILIAL+A2_CGC
			If SA2->(DbSeek(xFilial("SA2") + _CNPJTra,.F.))
				RecLock("ZZ5",.F.)
				ZZ5->ZZ5_FORNEC := SA2->A2_COD
				ZZ5->ZZ5_LOJA   := SA2->A2_LOJA
				ZZ5->ZZ5_NOME   := SA2->A2_NOME
				ZZ5->(MsUnLock())
			EndIf
		EndIf
		If !Empty(ZZ5->ZZ5_FORNEC)
			FRINCL() //Inclui o CTE via EXECAUTO
		EndIf
	Endif
	
	DbSelectArea("ZZ5")
	DbSetOrder(2) //ZZ5_FILIAL+ZZ5_STATUS+ZZ5_CNPJ+ZZ5_SERIE+ZZ5_DOC
	ZZ5->(Dbseek(_cChave,.T.))
	If ZZ5->(!Eof()) .And. (ZZ5->ZZ5_FILIAL+ZZ5->ZZ5_STATUS+ZZ5->ZZ5_CNPJ+ZZ5->ZZ5_SERIE+ZZ5->ZZ5_DOC) == _cChave
		ZZ5->(DbSkip())
	EndIf
Enddo
Return(.T.)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
*
************************
Static Function FRINCL()
************************

Local aCabec := {}
Local aItens := {}
Local _cTes  := ""

aadd(aCabec,{"F1_DOC"     ,ZZ5->ZZ5_DOC     , Nil})
aadd(aCabec,{"F1_SERIE"   ,ZZ5->ZZ5_SERIE   , Nil})
aadd(aCabec,{"F1_FORNECE" ,ZZ5->ZZ5_FORNEC , Nil})
aadd(aCabec,{"F1_LOJA"    ,ZZ5->ZZ5_LOJA    , Nil})
aadd(aCabec,{"F1_EMISSAO" ,ZZ5->ZZ5_EMISSA  , Nil})
aadd(aCabec,{"F1_TIPO"    ,"N"              , Nil})
aadd(aCabec,{"F1_FORMUL"  ,"N"              , Nil})
aadd(aCabec,{"F1_ESPECIE" ,"CTE"            , Nil})
aAdd(aCabec,{"F1_DTDIGIT" , ddatabase       , Nil})
aadd(aCabec,{"F1_COND"    ,"001"            , Nil})
aadd(aCabec,{"F1_DESPESA" ,0.00             , Nil})
aadd(aCabec,{"F1_CHVNFE"  ,ZZ5->ZZ5_CHVCTE  , Nil})

If ZZ5->ZZ5_EMISSA < dDataBase
	_cTES := If(ZZ5->ZZ5_ICM == 0,"072","071")
Else
	_cTES := If(ZZ5->ZZ5_ICM == 0,"034","017")
EndIf

// Foram alterados os códigos dos serviços de frete.
// E-mail do Juliano de 22/01/2015
/*/
Bom dia Betão,

Devido ao novo cadastro de produtos que estamos criando, houve a necessidade de também criar os produtos de Ctrs.
Como a planilha é importada creio que haja alguma configuração para atrelar o produto lançado em cada Ctr.
Anexo segue novos produtos que irão substituir os antigos:

0000001683 - Frete com Icms de 0% ou 7%  ' SV05000020 - Servico de Frete com 0% ou 7% de Icms.
0000002515 - Frete com Icms de 12%  ' SV05000021 - Servico de Frete com 12% de Icms.

Qualquer coisa me dá um toque!
/*/
SB1->(DbSetOrder(1))
cD1Cod1 := If(SB1->(DbSeek(xFilial("SB1")+"SV05000020     ",.F.)),"SV05000020     ","0000001683     ")
cD1Cod2 := If(SB1->(DbSeek(xFilial("SB1")+"SV05000021     ",.F.)),"SV05000021     ","0000002515     ")

cD1Cod := iIf(ZZ5->ZZ5_ICM < 12,cD1Cod1,cD1Cod2)

aLinha := {}
aAdd(aLinha,{"D1_ITEM"	,Padr("01",TamSX3("D1_ITEM")[1]), Nil})
aadd(aLinha,{"D1_COD"	, cD1Cod					, Nil})
aadd(aLinha,{"D1_QUANT"	, 1								, Nil})
aadd(aLinha,{"D1_LOCAL"	, "01"							, Nil})
aadd(aLinha,{"D1_VUNIT"	, ZZ5->ZZ5_TOTFRE		, Nil})
aadd(aLinha,{"D1_TOTAL"	, ZZ5->ZZ5_TOTFRE		, Nil})
aadd(aLinha,{"D1_TES"		, _cTes						, Nil})
aadd(aItens,aLinha)

Begin Transaction
lMsErroAuto := .F.
LjMsgRun("Gerando Documento de Entrada... "+ZZ5->ZZ5_DOC,,{||MSExecAuto({|x, y, z| MATA103(x, y, z)}, aCabec, aItens, 3)})
//MATA103(aCabec, aItens, 3)
If lMsErroAuto
	DisarmTransaction()
Else
	Reclock("ZZ5",.F.)
	ZZ5->ZZ5_STATUS := "3"
	ZZ5->(MsUnLock())
EndIf
End Transaction
Return

*************************
Static Function FRSEFAZ(cIdEnt) // ok
*************************
*
_nDias := (Date() - ZZ5->ZZ5_DTAUT)
_cTime := Left(Time(),5)
_cTime := Left(_cTime,2) + Right(_cTime,2)
If _nDias > 1 .Or. (Date() > ZZ5->ZZ5_DTAUT .And. _cTime > ZZ5->ZZ5_HORA)
	_RetCons := u_ConsChv(ZZ5->ZZ5_CHVCTE,cIdEnt)
	/*/ A função ConsChv() retorna um array com 3 elementos sendo:
	se a consulta teve sucesso
	{.T.,protocolo consultado,cod.retorno conf.abaixo}
	se a consulta não teve sucesso
	{.F.,Texto do erro da consulta,null}
	
	oWS:OWSCONSULTACHAVENFERESULT:CCODRETNFE 	pode ser:
	100 Autorizado o uso da NF-e
	101 Cancelamento de NF-e homologado
	102 Inutilização de número homologado
	103 Lote recebido com sucesso
	104 Lote processado
	105 Lote em processamento
	106 Lote não localizado
	107 Serviço em Operação
	108 Serviço Paralisado Momentaneamente (curto prazo)
	109 Serviço Paralisado sem Previsão
	110 Uso Denegado
	111 Consulta cadastro com uma ocorrência
	112 Consulta cadastro com mais de uma
	/*/
	If _RetCons[1] // Consulta com sucesso
		If _RetCons[2] == ZZ5->ZZ5_PROTOC // Mesmo Protocolo
			Reclock("ZZ5",.F.)
			If _RetCons[3] == "100" // Autorizado o uso da NF-e ou CT-e
				ZZ5->ZZ5_STATUS := "2"
				ZZ5->ZZ5_MOTIVO := "Uso Autorizado"
			ElseIf _RetCons[3] $ "101//102//110" // 101 Cancelamento de NF-e homologado//102 Inutilização de número homologado/110 Uso Denegado
				ZZ5->ZZ5_STATUS := "5"
				If     _RetCons[3] == "101"
					ZZ5->ZZ5_MOTIVO := "NF-e/CT-e Cancelado" // 101 Cancelamento de NF-e homologado
				ElseIf _RetCons[3] == "102"
					ZZ5->ZZ5_MOTIVO := "Número Inutilizado" //102 Inutilização de número homologado
				ElseIf _RetCons[3] == "110"
					ZZ5->ZZ5_MOTIVO := "Uso Denegado" //110 Uso Denegado
				EndIf
			Else
				ZZ5->ZZ5_MOTIVO := "Outros -> " + _RetCons[3]
			EndIf
			ZZ5->(MsUnLock())
		EndIf
	Else
		_nQtErr := Val(Left(ZZ5->ZZ5_MOTIVO,3))
		Reclock("ZZ5",.F.)
		ZZ5->ZZ5_MOTIVO := StrZero(_nQtErr,3) + " -> Erro(s) na Consulta"
		ZZ5->(MsUnLock())
		//		alert('Erro de Execução : '+_RetCons[2])
	EndIf
Endif
Return(.T.)

/*
=======================================================================================
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||+--------------------+-----------------------------------------+------------------+||
||| Programa: CDTMFATU | Autor: Celso Ferrone Martins            | Data: 15/01/2013 |||
||+------------+-------+-----------------------------------------+------------------+||
||| Descricao: | Processa Faturas quando todos os documento de uma determinada      |||
|||            | estiver com ZZ5_STATUS = 5, ZZ5_FORNFT nao estiver vazio e a soma  |||
|||            | do campo ZZ5_TOTFRE for igaul ao campo ZZ5_VALFAT                  |||
||+------------+--------------------------------------------------------------------+||
||| Alteracao: |                                                                    |||
||+------------+--------------------------------------------------------------------+||
||| Uso:       |                                                                    |||
||+------------+--------------------------------------------------------------------+||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
=======================================================================================
*/

User Function CDTMFATU()

Local aTit      := {}
Local cCodPgto  := "002"   // Condicao de pagamento
Local cCodNatu  := "FAT" // Natureza Financeira
Local lDoisForn := .F.

//Busca todas as faturas ainda não geradas

cQuery := " SELECT * FROM "
cQuery += " ( "
cQuery += " SELECT "
cQuery += "    ZZ5_FILIAL, "
cQuery += "    ZZ5_FATURA, "
cQuery += "    ZZ5_FORNFT, "
cQuery += "    ZZ5_LOJAFT, "
cQuery += "    ZZ5_VENCFA, "
cQuery += "    ROUND(ZZ5_VALFAT,2) AS 'ZZ5_VALFAT', "
cQuery += "    ROUND(SUM(ZZ5_TOTFRE),2) AS 'ZZ5_TOTFRE' "
cQuery += " FROM "+RetSqlName("ZZ5")+" ZZ5 "
cQuery += " WHERE "
cQuery += "    ZZ5.D_E_L_E_T_  <> '*' "
cQuery += "    AND ZZ5_FILIAL  = '"+xFilial("ZZ5")+"' "
cQuery += "    AND ZZ5_STATUS  = '3'"
cQuery += "    AND ZZ5_FORNFT <> '' "
cQuery += "    AND ZZ5_FATURA <> '' "
cQuery += "    AND ZZ5_FATURA NOT IN "
cQuery += "       (  "
cQuery += "       SELECT DISTINCT "
cQuery += "          ZZ5_FATURA  "
cQuery += "       FROM "+RetSqlName("ZZ5")+" ZZ5SEL "
cQuery += "       WHERE "
cQuery += "          ZZ5SEL.D_E_L_E_T_ <> '*' "
cQuery += "          AND ZZ5_FILIAL = ZZ5.ZZ5_FILIAL "
cQuery += "          AND ZZ5_STATUS IN ('1','2') "
cQuery += "       ) "
cQuery += " GROUP BY ZZ5_FILIAL, ZZ5_FATURA, ZZ5_FORNFT, ZZ5_LOJAFT, ZZ5_VALFAT, ZZ5_VENCFA "
cQuery += " ) QRY "
cQuery += " WHERE "
cQuery += "    QRY.ZZ5_VALFAT = QRY.ZZ5_TOTFRE "

If Select("TRA") > 0
	TRA->(DbCloseArea())
EndIf

TcQuery cQuery NEW ALIAS "TRA"

DbSelectArea("TRA")
Dbgotop()
While !TRA->(Eof())
	
	cQuery := " SELECT "
	cQuery += "    E2_FILIAL, "
	cQuery += "    E2_PREFIXO, "
	cQuery += "    E2_NUM, "
	cQuery += "    E2_PARCELA, "
	cQuery += "    E2_TIPO, "
	cQuery += "    ZZ5_FATURA, "
	cQuery += "    E2_NATUREZ, "
	cQuery += "    E2_FORNECE, "
	cQuery += "    E2_LOJA, "
	cQuery += "    E2_MOEDA, "
	cQuery += "    E2_EMISSAO, "
	cQuery += "    E2_FATURA, "
	cQuery += "    ZZ5_CNPJ "
	cQuery += " FROM "+RetSQLName("ZZ5")+" ZZ5 "
	cQuery += "    LEFT JOIN "+RetSQLName("SE2")+" SE2 ON "
	cQuery += "       SE2.D_E_L_E_T_ <> '*' "
	cQuery += "       AND ZZ5_FILIAL = E2_FILIAL "
	cQuery += "       AND ZZ5_DOC    = E2_NUM "
	cQuery += "       AND ZZ5_SERIE  = E2_PREFIXO "
	cQuery += "       AND ZZ5_FORNEC = E2_FORNECE "
	cQuery += "       AND ZZ5_LOJA   = E2_LOJA "
	cQuery += " WHERE "
	cQuery += "    ZZ5.D_E_L_E_T_ = '' "
	cQuery += "    AND ZZ5_FILIAL = '"+xFilial("ZZ5")+"' "
	cQuery += "    AND E2_FATURA  = '' "
	cQuery += "    AND ZZ5_FATURA = '"+TRA->ZZ5_FATURA+"' "
	cQuery += "    AND ZZ5_FORNFT = '"+TRA->ZZ5_FORNFT+"' "
	cQuery += "    AND ZZ5_LOJAFT = '"+TRA->ZZ5_LOJAFT+"' "
	cQuery += " ORDER BY E2_FILIAL, E2_FORNECE, E2_LOJA, E2_PREFIXO, E2_NUM, E2_TIPO "
	
	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf
	
	TcQuery cQuery NEW ALIAS "TRB"
	cCodForn := TRB->E2_FORNECE
	DbSelectArea("TRB") ; TRB->(DbgoTop())
	While !TRB->(Eof())
		
		If cCodForn != TRB->E2_FORNECE
			lDoisForn := .T.
		EndIf
		
		TRB->(Dbskip())
	Enddo
	
	If lDoisForn
		cNumFatura := ""
	Else
		cNumFatura := TRA->ZZ5_FATURA
	EndIf
	
	DbSelectArea("TRB") ; TRB->(DbgoTop())
	cCodForn := TRB->E2_FORNECE
	dDataMin := TRB->E2_EMISSAO
	dDataMax := TRB->E2_EMISSAO
	cCnpjCte := TRB->ZZ5_CNPJ
	aTit     := {}
	aArray   := {}
	While !TRB->(Eof())
		
		If dDataMin > TRB->E2_EMISSAO
			dDataMin := TRB->E2_EMISSAO
		EndIf
		If dDataMax < TRB->E2_EMISSAO
			dDataMax := TRB->E2_EMISSAO
		EndIf
		
		If cCodForn == TRB->E2_FORNECE
			AADD(aTit,{TRB->E2_PREFIXO,TRB->E2_NUM,TRB->E2_PARCELA,TRB->E2_TIPO,.F.})
		Else
			aArray := { "FAT", "FT", cNumFatura, cCodNatu, sTod(dDataMin), sTod(dDataMax), cCodForn, "", TRA->ZZ5_FORNFT, TRA->ZZ5_LOJAFT, cCodPgto, 1, aTit , 0, 0}
			FatAuto(aArray,aTit,cCnpjCte)
			
			cCodForn := TRB->E2_FORNECE
			dDataMin := TRB->E2_EMISSAO
			dDataMax := TRB->E2_EMISSAO
			cCnpjCte := TRB->ZZ5_CNPJ
			aTit     := {}
			aArray   := {}
			
			AADD(aTit,{TRB->E2_PREFIXO,TRB->E2_NUM,TRB->E2_PARCELA,TRB->E2_TIPO,.F.})
		EndIf
		TRB->(Dbskip())
	Enddo
	
	aArray := { "FAT", "FT", cNumFatura, cCodNatu, sTod(dDataMin), sTod(dDataMax), cCodForn, "", TRA->ZZ5_FORNFT, TRA->ZZ5_LOJAFT, cCodPgto, 1, aTit , 0, 0}
	FatAuto(aArray,aTit,cCnpjCte)
	
	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf
	
	If lDoisForn // Trata quando tiver 2 fornecedores diferente para a fatura
		
		cNumFatura := TRA->ZZ5_FATURA
		cCodForn := ""
		dDataMin := cTod("  /  /  ")
		dDataMax := cTod("  /  /  ")
		aTit     := {}
		aArray   := {}
		aFatDel  := {}
		
		cQuery := " SELECT DISTINCT"
		cQuery += "    E2_FILIAL, "
		cQuery += "    E2_FATURA "
		cQuery += " FROM "+RetSQLName("ZZ5")+" ZZ5 "
		cQuery += "    LEFT JOIN "+RetSQLName("SE2")+" SE2 ON "
		cQuery += "       SE2.D_E_L_E_T_ <> '*' "
		cQuery += "       AND ZZ5_FILIAL = E2_FILIAL "
		cQuery += "       AND ZZ5_DOC    = E2_NUM "
		cQuery += "       AND ZZ5_SERIE  = E2_PREFIXO "
		cQuery += "       AND ZZ5_FORNEC = E2_FORNECE "
		cQuery += "       AND ZZ5_LOJA   = E2_LOJA "
		cQuery += " WHERE "
		cQuery += "    ZZ5.D_E_L_E_T_ = '' "
		cQuery += "    AND ZZ5_FILIAL = '"+xFilial("ZZ5")+"' "
		cQuery += "    AND E2_FATURA <> '' "
		cQuery += "    AND ZZ5_FATURA = '"+TRA->ZZ5_FATURA+"' "
		cQuery += "    AND ZZ5_FORNFT = '"+TRA->ZZ5_FORNFT+"' "
		cQuery += "    AND ZZ5_LOJAFT = '"+TRA->ZZ5_LOJAFT+"' "
		cQuery += " ORDER BY E2_FILIAL, E2_FATURA "
		
		If Select("TRC") > 0
			TRC->(DbCloseArea())
		EndIf
		
		TcQuery cQuery New Alias "TRC"
		
		DbSelectArea("TRC") ; DbGoTop()
		DbSelectArea("SE2") ; DbSetOrder(6) //E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO
		While !TRC->(Eof())
			SE2->(DbSeek(xFilial("SE2")+TRA->(ZZ5_FORNFT+ZZ5_LOJAFT)+"FAT"+TRC->E2_FATURA))
			dDataMin := SE2->E2_EMISSAO
			dDataMax := SE2->E2_EMISSAO
			While !SE2->(Eof()) .And. SE2->(E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM) == (xFilial("SE2")+TRA->(ZZ5_FORNFT+ZZ5_LOJAFT)+"FAT"+TRC->E2_FATURA)
				If AllTrim(SE2->E2_TIPO) == "FT"
					
					cCodForn := SE2->E2_FORNECE
					
					If dDataMin > SE2->E2_EMISSAO
						dDataMin := SE2->E2_EMISSAO
					EndIf
					If dDataMax < SE2->E2_EMISSAO
						dDataMax := SE2->E2_EMISSAO
					EndIf
					
					RecLock("SE2",.F.)
					SE2->E2_FATURA = ""
					SE2->(MsUnLock())
					AADD(aTit   ,{SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,.F.})
					aAdd(aFatDel,{SE2->E2_FILIAL,SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,SE2->E2_TIPO,SE2->E2_FORNECE,SE2->E2_LOJA})
				EndIf
				SE2->(DbSkip())
			EndDo
			
			TRC->(DbSkip())
		EndDo
		If Len(aTit) > 0
			aArray := { "FAT", "FT", cNumFatura, cCodNatu, dDataMin, dDataMax, cCodForn, "", TRA->ZZ5_FORNFT, TRA->ZZ5_LOJAFT, cCodPgto, 1, aTit , 0, 0}
			FatAuto(aArray,aTit,"",aFatDel)
		EndIf
		
		If Select("TRC") > 0
			TRC->(DbCloseArea())
		EndIf
		
	EndIf
	
	TRA->(Dbskip())
Enddo

If Select("TRA") > 0
	TRA->(DbCloseArea())
EndIf

Return()

/*
=======================================================================================
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||+--------------------+-----------------------------------------+------------------+||
||| Programa: FatAuto  | Autor: Celso Ferrone Martins            | Data: 15/01/2013 |||
||+------------+-------+-----------------------------------------+------------------+||
||| Descricao: | ExecAuto da rotina de fatura para os itens da tabela ZZ5           |||
||+------------+--------------------------------------------------------------------+||
||| Alteracao: |                                                                    |||
||+------------+--------------------------------------------------------------------+||
||| Uso:       |                                                                    |||
||+------------+--------------------------------------------------------------------+||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
=======================================================================================
*/

Static Function FatAuto(aArray,aTit,cCnpjCte,aFatDel)

Begin Transaction

If Empty(aArray[3])
	cTitAuto := "..."
Else
	cTitAuto := "No. " + aArray[3]
EndIf

lMsErroAuto := .F.
LjMsgRun("Gerando Fatura "+cTitAuto,,{||MsExecAuto( { |x,y| FINA290(x,y)},3,aArray,)})

If lMsErroAuto
	DisarmTransaction()
	//MostraErro()
Else
	If !Empty(cCnpjCte) // Altera o Status da ZZ5
		For nx := 1 to Len(aTit)
			DbSelectArea("ZZ5") ; DbSetOrder(1)
			If ZZ5->(DbSeek(xFilial("ZZ5") + cCnpjCte + aTit[nx][2] + aTit[nx][1] ))
				RecLock("ZZ5",.F.)
				ZZ5->ZZ5_STATUS = "4"
				ZZ5->(MsUnLock())
			EndIf
		Next nx
	Else // Ajustando Refaturas
		If Len(aFatDel) > 0 // Deleta Fatura Intermediaria
			DbSelectArea("SE2") ; DbSetOrder(1)
			DbSelectArea("SE5") ; DbSetOrder(7)
			For Nx := 1 To Len(aFatDel)
				If SE2->(DbSeek(aFatDel[nx][1]+aFatDel[nx][2]+aFatDel[nx][3]+aFatDel[nx][4]+aFatDel[nx][5]+aFatDel[nx][6]+aFatDel[nx][7]))
					RecLock("SE2",.F.)
					DbDelete()
					SE2->(MsUnLock())
					If SE5->(DbSeek(aFatDel[nx][1]+aFatDel[nx][2]+aFatDel[nx][3]+aFatDel[nx][4]+aFatDel[nx][5]+aFatDel[nx][6]+aFatDel[nx][7]))
						While !SE5->(Eof()) .and. SE5->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA) == aFatDel[nx][1]+aFatDel[nx][2]+aFatDel[nx][3]+aFatDel[nx][4]+aFatDel[nx][5]+aFatDel[nx][6]+aFatDel[nx][7]
							RecLock("SE5",.F.)
							DbDelete()
							SE5->(MsUnLock())
							SE5->(DbSkip())
						EndDo
					EndIf
				EndIf
			Next Nx
			//Atualiza titulos com o numero da fartura correta
			cQuery := " UPDATE " + RetSqlName("SE2")
			cQuery += "    SET E2_FATURA = '" +aArray[3]+ "' "
			cQuery += " FROM "+RetSQLName("ZZ5")+" ZZ5 "
			cQuery += "    LEFT JOIN "+RetSQLName("SE2")+" SE2 ON "
			cQuery += "       SE2.D_E_L_E_T_ <> '*' "
			cQuery += "       AND ZZ5_FILIAL = E2_FILIAL "
			cQuery += "       AND ZZ5_DOC    = E2_NUM "
			cQuery += "       AND ZZ5_SERIE  = E2_PREFIXO "
			cQuery += "       AND ZZ5_FORNEC = E2_FORNECE "
			cQuery += "       AND ZZ5_LOJA   = E2_LOJA "
			cQuery += " WHERE "
			cQuery += "    ZZ5.D_E_L_E_T_ = '' "
			cQuery += "    AND ZZ5_FILIAL = '"+xFilial("ZZ5")+"' "
			cQuery += "    AND E2_FATURA <> '' "
			cQuery += "    AND ZZ5_FATURA = '"+TRA->ZZ5_FATURA+"' "
			cQuery += "    AND ZZ5_FORNFT = '"+TRA->ZZ5_FORNFT+"' "
			cQuery += "    AND ZZ5_LOJAFT = '"+TRA->ZZ5_LOJAFT+"' "
			MsAguarde({ | | TcSqlExec(cQuery) },"Por favor aguarde","Ajustando Fatura")
		EndIf
	EndIf
EndIf
End Transaction

Return()

*
***********************
User Function DelTerm()
***********************
*
nOpca   := AxDeleta("ZZ4",Recno(),5,,,)

If !Empty(ZZ4->ZZ4_CONHEC)
	Alert("Conhecimento já emitido para essa nota")
	Return(.T.)
EndIf
Retur(.T.)