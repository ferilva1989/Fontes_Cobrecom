#Include 'Protheus.ch'
#Define 0210 1
#Define K001 2
#Define K100 3
#Define K200 4
#Define K210 5
#Define K215 6
#Define K220 7
#Define K230 8
#Define K235 9
#Define K250 10
#Define K255 11
#Define K260 12
#Define K265 13
#Define K270 14
#Define K275 15
#Define K280 16
#Define K990 17

//-------------------------------------------------------------------
/*/{Protheus.doc} CBCMT241
Relatório Analitico para o Bloco K do SPED Fiscal
@author bolognesi
@since 01/12/2016
@version 1.0
/*/
//-------------------------------------------------------------------
User Function CBCMT241()

Local oReport

#IFDEF TOP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajusta perguntas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AjustaSX1()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Interface de impressao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()
	oReport:PrintDialog()
#ELSE
	Aviso('MATR241', "Este relatório está disponível apenas em ambientes DBAccess.", {'Ok'})
#ENDIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
A funcao estatica ReportDef devera ser criada para todos os
relatorios que poderao ser agendados pelo usuario
@author bolognesi
@since 01/12/2016
@version 1.0
@return oReport, Objeto oReport
/*/
//-------------------------------------------------------------------
Static Function ReportDef()
Local oSecK001,oSecK100,oSecK200,oSecK210,oSecK215,oSecK220,oSecK230,oSecK235,oSecK250
Local oSecK255,oSecK260,oSecK265,oSecK270,oSecK275,oSecK280,oSecK990,oSec0210
Local oReport, oCell
Local nTipo		:= 0
Local nSpace	:= 15
Local cDesc		:= "Este relatório tem como objetivo apresentar os registros apurados do Bloco K do SPED Fiscal."
Local nTamProd	:= TamSX3("B1_COD")[1]
Local nTamNSeq	:= TamSX3("D3_NUMSEQ" )[1] + TamSX3("D3_DOC")[1]
// ------ Tamanhos conforme especificado no Guia EFD ------
Local nTamQtd	:= 16
Local cPicQtd	:= "@E 999,999,999,999.999"
Local cPicCmp	:= "@E 999,999,999.999999"
Local cPicPrd	:= "@E 99,999,999,999.9999" 
// --------------------------------------------------------
Local cAli0210	:= GetNextAlias()
Local cAliK001	:= GetNextAlias()
Local cAliK100	:= GetNextAlias()
Local cAliK200	:= GetNextAlias()
Local cAliK210	:= GetNextAlias()
Local cAliK215	:= GetNextAlias()
Local cAliK220	:= GetNextAlias()
Local cAliK230	:= GetNextAlias()
Local cAliK235	:= GetNextAlias()
Local cAliK250	:= GetNextAlias()
Local cAliK255	:= GetNextAlias()
Local cAliK260	:= GetNextAlias()
Local cAliK265	:= GetNextAlias()
Local cAliK270	:= GetNextAlias()
Local cAliK275	:= GetNextAlias()
Local cAliK280	:= GetNextAlias()
Local cAliK990	:= GetNextAlias()
Local cAli0200	:= GetNextAlias()

Local aAlias	:= 	{cAli0210,cAliK001,cAliK100,cAliK200,cAliK210,cAliK215,cAliK220,cAliK230,;
					cAliK235,cAliK250,cAliK255,cAliK260,cAliK265,cAliK270,cAliK275,cAliK280,cAliK990,cAli0200}


oReport := TReport():New("MATR241","","MTR241",{|oReport| ReportPrint(oReport,aAlias)},cDesc)
oReport:SetTitle("Relação Bloco K Analítico")
//oReport:SetPortrait()
oReport:SetLandScape()
oReport:DisableOrientation()
oReport:SetEdit(.F.)

Pergunte("MTR241",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K001                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK001 := TRSection():New(oReport,"Registro K001",{cAliK001})
oSecK001:SetReadOnly()
oSecK001:SetLineStyle()
oSecK001:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK001,"REG"     ,cAliK001,"Registro",,2*nSpace,,,,,,,,,,,)
TRCell():New(oSecK001,"IND_MOV" ,cAliK001,"Ind. Movimento",,3*nSpace,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K100                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK100 := TRSection():New(oReport,"Registro K100",{cAliK100})
oSecK100:SetReadOnly()
oSecK100:SetLineStyle()
oSecK100:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK100,"REG"     ,cAliK100,"Registro",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK100,"DT_INI"  ,cAliK100,"DT. Inicial",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK100,"DT_FIN"  ,cAliK100,"DT. Final",,nSpace,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K200                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK200 := TRSection():New(oReport,"Registro K200",{cAliK200})
oSecK200:SetReadOnly()
oSecK200:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK200,"REG"     ,cAliK200,"Registro",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK200,"DT_EST"  ,cAliK200,"DT. Estoque",,nSpace,,,,,,,,,,,)

TRCell():New(oSecK200,"TIPO_ITEM",cAliK200,"Tipo",,TamSx3('B1_TIPO')[1],,,,,,,,,,,)
TRCell():New(oSecK200,"GRUPO_ITEM",cAliK200,"Grupo",,TamSx3('B1_GRUPO')[1],,,,,,,,,,,)

TRCell():New(oSecK200,"COD_ITEM",cAliK200,"Código",,nTamProd+nSpace,,,,,,,,,,,)

TRCell():New(oSecK200,"DESC_ITEM",cAliK200,"Descrição",,TamSx3('B1_DESC')[1],,,,,,,,,,,)
TRCell():New(oSecK200,"UM_ITEM"  ,cAliK200,"U.M",,TamSx3('B1_UM')[1],,,,,,,,,,,)

TRCell():New(oSecK200,"QTD"     ,cAliK200,"Quantidade",cPicQtd,nTamQtd,,,,,,,,,,,)

TRCell():New(oSecK200,"KG_COBRE",cAliK200,"KG Cobre",cPicQtd,nTamQtd,,,,,,,,,,,)
TRCell():New(oSecK200,"KG_PVC",cAliK200,"KG PVC"	,cPicQtd,nTamQtd,,,,,,,,,,,)

TRCell():New(oSecK200,"IND_EST" ,cAliK200,"Indicador Est.",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK200,"COD_PART",cAliK200,"Participante.",,nSpace,,,,,,,,,,,)

TRCell():New(oSecK200,"NOME_PART",cAliK200,"Nome.",,TamSx3('A1_NOME')[1],,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K210                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK210 := TRSection():New(oReport,"Registro K210",{cAliK210})
oSecK210:SetReadOnly()
oSecK210:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK210,"REG"     	,cAliK210,"Registro",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK210,"DT_INI_OS"	,cAliK210,"DT.INI.",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK210,"DT_FIN_OS"	,cAliK210,"DT.FIN.",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK210,"COD_DOC_OS"	,cAliK210,"Doc/OS",,nTamNSeq,,,,,,,,,,,)
TRCell():New(oSecK210,"COD_ITEM_O"	,cAliK210,"Código",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK210,"QTD_ORI"     ,cAliK210,"Quantidade",cPicQtd,nTamQtd,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K215                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK215 := TRSection():New(oReport,"Registro K215",{cAliK215})
oSecK215:SetReadOnly()
oSecK215:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK215,"REG"     	,cAliK215,"Registro",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK215,"COD_DOC_OS"	,cAliK215,"Doc/OS",,nTamNSeq,,,,,,,,,,,)
TRCell():New(oSecK215,"COD_ITEM_D"	,cAliK215,"Código",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK215,"QTD_DES"     ,cAliK215,"Quantidade",cPicQtd,nTamQtd,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K220                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK220 := TRSection():New(oReport,"Registro K220",{cAliK220})
oSecK220:SetReadOnly()
oSecK220:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK220,"REG"       ,cAliK220,"Registro",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK220,"DT_MOV"    ,cAliK220,"DT. Estoque",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK220,"COD_ITEM_O",cAliK220,"Código Origem",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK220,"COD_ITEM_D",cAliK220,"Código Destino",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK220,"QTD"       ,cAliK220,"Quantidade",cPicQtd,nTamQtd,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K230                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK230 := TRSection():New(oReport,"Registro K230",{cAliK230})//
oSecK230:SetReadOnly()
oSecK230:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK230,"REG"       ,cAliK230,"Registro",,nSpace,,,,,,,,,,,)	
TRCell():New(oSecK230,"DT_INI_OP" ,cAliK230,"DT. Ini. OP",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK230,"DT_FIN_OP" ,cAliK230,"DT. Fin. OP",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK230,"COD_DOC_OP",cAliK230,"Número OP",,nSpace,,,,,,,,,,,)	
TRCell():New(oSecK230,"COD_ITEM"  ,cAliK230,"Código",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK230,"QTD_ENC"   ,cAliK230,"Quantidade",cPicQtd,nTamQtd,,,,,,,,,,,)
TRCell():New(oSecK230,"QTDORI"    ,cAliK230,"Qtd. OP",cPicQtd,nTamQtd,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K235                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK235 := TRSection():New(oReport,"Registro K235",{cAliK235})
oSecK235:SetReadOnly()
oSecK235:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK235,"REG"       ,cAliK235,"Registro",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK235,"DT_SAIDA"  ,cAliK235,"DT. Saída",,nSpace,,,,,,,,,,,)	
TRCell():New(oSecK235,"COD_DOC_OP",cAliK235,"Número OP",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK235,"COD_ITEM"  ,cAliK235,"Código",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK235,"COD_INS_SU",cAliK235,"Código Subs.",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK235,"QTD"       ,cAliK235,"Quantidade",cPicQtd,nTamQtd,,,,,,,,,,,)
TRCell():New(oSecK235,"EMPENHO"   ,cAliK235,"Empenho?",,,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K250                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK250 := TRSection():New(oReport,"Registro K250",{cAliK250})
oSecK250:SetReadOnly()
oSecK250:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK250,"REG"     ,cAliK250,"Registro",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK250,"DT_PROD" ,cAliK250,"DT. Produção",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK250,"CHAVE"   ,cAliK250,"Chave",,2*nSpace,,,,,,,,,,,)
TRCell():New(oSecK250,"COD_ITEM",cAliK250,"Código",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK250,"QTD"     ,cAliK250,"Quantidade",cPicQtd,nTamQtd,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K255                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK255 := TRSection():New(oReport,"Registro K255",{cAliK255})
oSecK255:SetReadOnly()
oSecK255:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK255,"REG"       ,cAliK255,"Registro",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK255,"DT_CONS"   ,cAliK255,"DT. Saída",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK255,"CHAVE"     ,cAliK255,"Chave",,2*nSpace,,,,,,,,,,,)
TRCell():New(oSecK255,"COD_ITEM"  ,cAliK255,"Código",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK255,"COD_INS_SU",cAliK255,"Código Subs.",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK255,"QTD"       ,cAliK255,"Quantidade",cPicQtd,nTamQtd,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K260                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK260 := TRSection():New(oReport,"Registro K260",{cAliK260}) //
oSecK260:SetReadOnly()
oSecK260:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK260,"REG"			,cAliK260,"Registro",,nSpace,,,,,,,,,,,)				
TRCell():New(oSecK260,"COD_OP_OS"	,cAliK260,"OP/OS",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK260,"COD_ITEM" 	,cAliK260,"Código",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK260,"DT_SAIDA"	,cAliK260,"Dt. Saída",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK260,"QTD_SAIDA"	,cAliK260,"Qtd. Saída",cPicQtd,nTamQtd,,,,,,,,,,,)
TRCell():New(oSecK260,"DT_RET"		,cAliK260,"Dt. Ret.",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK260,"QTD_RET"		,cAliK260,"Qtd. Ret.",cPicQtd,nTamQtd,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K265                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK265 := TRSection():New(oReport,"Registro K265",{cAliK265})
oSecK265:SetReadOnly()
oSecK265:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK265,"REG"			,cAliK265,"Registro",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK265,"COD_ITEM" 	,cAliK265,"Código",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK265,"QTD_CONS"	,cAliK265,"Qtd. Cons.",cPicQtd,nTamQtd,,,,,,,,,,,)
TRCell():New(oSecK265,"QTD_RET"		,cAliK265,"Qtd. Ret.",cPicQtd,nTamQtd,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K270                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK270 := TRSection():New(oReport,"Registro K270",{cAliK270})
oSecK270:SetReadOnly()
oSecK270:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK270,"REG"			,cAliK270,"Registro",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK270,"DT_INI_AP"	,cAliK270,"Dt. Ini. Ap.",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK270,"DT_FIN_AP"	,cAliK270,"Dt. Fin. Ap.",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK270,"COD_OP_OS"	,cAliK270,"OP/OS",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK270,"COD_ITEM" 	,cAliK270,"Código",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK270,"QTD_COR_P"	,cAliK270,"Qtd. Pos.",cPicQtd,nTamQtd,,,,,,,,,,,)
TRCell():New(oSecK270,"QTD_COR_N"	,cAliK270,"Qtd. Neg",cPicQtd,nTamQtd,,,,,,,,,,,)
TRCell():New(oSecK270,"ORIGEM"		,cAliK270,"Origem",,nSpace,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K275                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK275 := TRSection():New(oReport,"Registro K275",{cAliK275})
oSecK275:SetReadOnly()
oSecK275:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK275,"REG"			,cAliK275,"Registro",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK275,"COD_ITEM" 	,cAliK275,"Código",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK275,"QTD_COR_P"	,cAliK275,"Qtd. Pos.",cPicQtd,nTamQtd,,,,,,,,,,,)
TRCell():New(oSecK275,"QTD_COR_N"	,cAliK275,"Qtd. Neg",cPicQtd,nTamQtd,,,,,,,,,,,)
TRCell():New(oSecK275,"COD_INS_SU"	,cAliK275,"Código Subs.",,nTamProd+nSpace,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K280                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK280 := TRSection():New(oReport,"Registro K280",{cAliK280})
oSecK280:SetReadOnly()
oSecK280:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK280,"REG"			,cAliK280,"Registro",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK280,"DT_EST"  	,cAliK280,"DT. Estoque",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK280,"COD_ITEM" 	,cAliK280,"Código",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSecK280,"QTD_COR_P"	,cAliK280,"Qtd. Pos.",cPicQtd,nTamQtd,,,,,,,,,,,)
TRCell():New(oSecK280,"QTD_COR_N"	,cAliK280,"Qtd. Neg",cPicQtd,nTamQtd,,,,,,,,,,,)
TRCell():New(oSecK280,"IND_EST" 	,cAliK280,"Indicador Est.",,nSpace,,,,,,,,,,,)
TRCell():New(oSecK280,"COD_PART"	,cAliK280,"Participante.",,nSpace,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao K990                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSecK990 := TRSection():New(oReport,"Registro K990",{cAliK990})
oSecK990:SetReadOnly()
oSecK990:SetLineStyle()
oSecK990:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSecK990,"REG"      ,cAliK990,"Registro",,2*nSpace,,,,,,,,,,,)
TRCell():New(oSecK990,"QTD_LIN_K",cAliK990,"Quantidade Linhas",,2*nSpace,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 0210                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSec0210 := TRSection():New(oReport,"Registro 0210",{cAli0210})
oSec0210:SetReadOnly()
oSec0210:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSec0210,"REG"       ,cAli0210,"Registro",,nSpace,,,,,,,,,,,)	
TRCell():New(oSec0210,"COD_ITEM"  ,cAli0210,"Código",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSec0210,"COD_I_COMP",cAli0210,"Código Comp.",,nTamProd+nSpace,,,,,,,,,,,)
TRCell():New(oSec0210,"QTD_COMP"  ,cAli0210,"Quantidade",cPicCmp,nTamQtd,,,,,,,,,,,)
TRCell():New(oSec0210,"PERDA"     ,cAli0210,"Perda",cPicPrd,nTamQtd,,,,,,,,,,,)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Sessao 0200                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSec0200 := TRSection():New(oReport,"Registro 0200",{cAli0200})
oSec0200:SetReadOnly()
oSec0200:SetEditCell(.F.) //Bloqueia a edicao de celulas e filtros do relatorio

TRCell():New(oSec0200,"COD_ITEM"  ,cAli0200,"Código",,nTamProd+nSpace,,,,,,,,,,,)

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Impressao do relatorio
@author bolognesi
@since 13/12/2016
@version 1.5
@param oReport, objeto, Objeto oReport
@param cAliK200, character, Alias do Registro K200
/*/
//-------------------------------------------------------------------
Static Function ReportPrint(oReport,aAlias)

Local nMeter		:= 0
Local aIndices		:= {}
Local aAliProc[17]
Local dDataDe		:= MV_PAR01
Local dDataAte		:= MV_PAR02
Local lEstrMov		:= MV_PAR03 == 1
Local lSum			:= MV_PAR04 == 2
Local lProcAll		:= MV_PAR05 == 2
Local nTamCli		:= TamSX3("A1_COD" )[1]
Local nTamLjCli		:= TamSX3("A1_LOJA")[1]
Local nTamFor		:= TamSX3("A2_COD" )[1]
Local nTamLjFor		:= TamSX3("A2_LOJA")[1]
Local cSemReg		:= "*** Não há registros para o período selecionado."
Local oSecK001		:= oReport:Section(1)
Local oSecK100		:= oReport:Section(2)
Local oSecK200		:= oReport:Section(3)
Local oSecK210		:= oReport:Section(4)
Local oSecK215		:= oReport:Section(5)
Local oSecK220		:= oReport:Section(6)
Local oSecK230		:= oReport:Section(7)
Local oSecK235		:= oReport:Section(8)
Local oSecK250		:= oReport:Section(9)
Local oSecK255		:= oReport:Section(10)
Local oSecK260		:= oReport:Section(11)
Local oSecK265		:= oReport:Section(12)
Local oSecK270		:= oReport:Section(13)
Local oSecK275		:= oReport:Section(14)
Local oSecK280		:= oReport:Section(15)
Local oSecK990		:= oReport:Section(16)
Local oSec0210		:= oReport:Section(17)
Local oSec0200		:= oReport:Section(18)

Local nX, nY
Local cChaveA1		:= ""
Local cChaveA2		:= ""
oReport:SetTitle("Relação do Bloco K do SPED Fiscal - Analítico")

// Imprime tudo ou K200/K280
If lProcAll
	AFill(aAliProc,.T.)
Else
	AFill(aAliProc,.F.)
	aAliProc[K200] := .T.
	aAliProc[K280] := .T.
EndIf 


If !oReport:Cancel()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Geracao do Bloco K               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//aIndices := SPDBlocoK(dDataDe,dDataAte,@aAlias,lEstrMov,lSum)
	aIndices := SPDBlocoK(dDataDe,dDataAte,@aAlias,aAliProc,lEstrMov,lSum)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicio da Impressao do Relatorio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	For nX := 1 To Len(aAlias)

		nMeter += (aAlias[nX])->(LastRec())
	Next nX
	oReport:SetMeter(nMeter)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K001                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:PrintText("REGISTRO K001 - Abertura do Bloco K")
	oReport:ThinLine()
	oReport:PrintText(" ")
	If (aAlias[K001])->(Eof())
		oReport:PrintText(cSemReg)
	Else
		While !(aAlias[K001])->(Eof()) .And. !oReport:Cancel()
			oReport:IncMeter()
			If oReport:Cancel()
				Exit
			EndIf
			oSecK001:Init()
			oSecK001:Cell("REG"		):setValue((aAlias[K001])->REG)
			If (aAlias[K001])->IND_MOV == "0"
				oSecK001:Cell("IND_MOV"):setValue("0 - Existem informações no Bloco K")
			ElseIf (aAlias[K001])->IND_MOV == "1"
				oSecK001:Cell("IND_MOV"):setValue("1 - Não existem informacoes no Bloco K")
			EndIf
			oSecK001:PrintLine()
			(aAlias[K001])->(dbSkip())
		EndDo
	EndIf
	oSecK001:Finish()
	oReport:PrintText(" ")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K100                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:PrintText("REGISTRO K100 - Período de Apuração do ICMS/IPI")
	oReport:ThinLine()
	oReport:PrintText(" ")
	If (aAlias[K100])->(Eof())
		oReport:PrintText(cSemReg)
	Else
		While !(aAlias[K100])->(Eof()) .And. !oReport:Cancel()
			oReport:IncMeter()
			If oReport:Cancel()
				Exit
			EndIf
			oSecK100:Init()
			oSecK100:Cell("REG"		):setValue((aAlias[K100])->REG)
			oSecK100:Cell("DT_INI"	):setValue((aAlias[K100])->DT_INI)
			oSecK100:Cell("DT_FIN"	):setValue((aAlias[K100])->DT_FIN)
			oSecK100:PrintLine()
			(aAlias[K100])->(dbSkip())
		EndDo
	EndIf
	oSecK100:Finish()
	oReport:PrintText(" ")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K200                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aAliProc[K200]
		oReport:PrintText("REGISTRO K200 - Estoque Escriturado")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K200])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[K200])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				
				If (aAlias[K200])->QTD <> 0 
					DbSelectArea('SB1')
					SB1->(DbSetOrder(1))
					DbSeek(xFilial("SB1") + Padr ((aAlias[K200])->COD_ITEM, TamSx3('B1_COD')[1]), .F. )
					
					oSecK200:Init()
					oSecK200:Cell("REG"			):setValue((aAlias[K200])->REG)
					oSecK200:Cell("DT_EST"		):setValue((aAlias[K200])->DT_EST)
					
					oSecK200:Cell("TIPO_ITEM"	):setValue( SB1->(B1_TIPO) )
					oSecK200:Cell("GRUPO_ITEM"	):setValue( SB1->(B1_GRUPO) )
					
					oSecK200:Cell("COD_ITEM"	):setValue((aAlias[K200])->COD_ITEM)
					oSecK200:Cell("DESC_ITEM"	):setValue( Alltrim(SB1->(B1_DESC)) )
					oSecK200:Cell("UM_ITEM"		):setValue( SB1->(B1_UM) )
	
					oSecK200:Cell("QTD"			):setValue((aAlias[K200])->QTD)
					
					oSecK200:Cell("KG_COBRE"	):setValue(  (aAlias[K200])->QTD * SB1->(B1_PESCOB)  )
					oSecK200:Cell("KG_PVC"		):setValue(  (aAlias[K200])->QTD * SB1->(B1_PESPVC)  )
					
					
					If (aAlias[K200])->IND_EST == "0"
						oSecK200:Cell("IND_EST"):setValue("Próprio")
					ElseIf (aAlias[K200])->IND_EST == "1"
						oSecK200:Cell("IND_EST"):setValue("Em Terceiros")
					ElseIf (aAlias[K200])->IND_EST == "2"
						oSecK200:Cell("IND_EST"):setValue("De Terceiros")
					EndIf
					If SubStr((aAlias[K200])->COD_PART,1,3) == "SA2"
						oSecK200:Cell("COD_PART"):setValue("F: "+SubStr((aAlias[K200])->COD_PART,4,nTamFor)+"-"+SubStr((aAlias[K200])->COD_PART,4+nTamFor,nTamLjFor))
				
						cChaveA2 := PadR( SubStr((aAlias[K200])->COD_PART,4,nTamFor + nTamLjFor) , TamSx3('A2_COD')[1] + TamSx3('A2_LOJA')[1] )
						oSecK200:Cell("NOME_PART"):setValue(Posicione("SA2",1,xFilial("SA2") + cChaveA2 ,"A2_NOME" ))
					
					ElseIf SubStr((aAlias[K200])->COD_PART,1,3) == "SA1"
						oSecK200:Cell("COD_PART"):setValue("C: "+SubStr((aAlias[K200])->COD_PART,4,nTamCli)+"-"+SubStr((aAlias[K200])->COD_PART,4+nTamCli,nTamLjCli))
						
						cChaveA1 := PadR( SubStr((aAlias[K200])->COD_PART,4,nTamCli + nTamLjCli) , TamSx3('A1_COD')[1] + TamSx3('A1_LOJA')[1] )
						oSecK200:Cell("NOME_PART"):setValue(Posicione("SA1",1,xFilial("SA1") + cChaveA1 ,"A1_NOME" ))
	
					Else
						oSecK200:Cell("COD_PART"):setValue("")
						oSecK200:Cell("NOME_PART"):setValue("")
					EndIf
					oSecK200:PrintLine()
				EndIf
				
				(aAlias[K200])->(dbSkip())
			EndDo
		EndIf
		oSecK200:Finish()
		oReport:PrintText(" ")
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K210                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aAliProc[K210]
		oReport:PrintText("REGISTRO K210 - Desmontagem de Produtos: Origem")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K210])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[K210])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK210:Init()
				oSecK210:Cell("REG"			):setValue((aAlias[K210])->REG)
				oSecK210:Cell("DT_INI_OS"	):setValue((aAlias[K210])->DT_INI_OS)
				oSecK210:Cell("DT_FIN_OS"	):setValue((aAlias[K210])->DT_FIN_OS)
				oSecK210:Cell("COD_DOC_OS"	):setValue((aAlias[K210])->COD_DOC_OS)
				oSecK210:Cell("COD_ITEM_O"	):setValue((aAlias[K210])->COD_ITEM_O)
				oSecK210:Cell("QTD_ORI"		):setValue((aAlias[K210])->QTD_ORI)
				oSecK210:PrintLine()
				(aAlias[K210])->(dbSkip())
			EndDo
		oSecK210:Finish()
		oReport:PrintText(" ")
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K215                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText("REGISTRO K215 - Desmontagem de Produtos: Destino")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K215])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[K215])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK215:Init()
				oSecK215:Cell("REG"			):setValue((aAlias[K215])->REG)
				oSecK215:Cell("COD_DOC_OS"	):setValue((aAlias[K215])->COD_DOC_OS)
				oSecK215:Cell("COD_ITEM_D"	):setValue((aAlias[K215])->COD_ITEM_D)
				oSecK215:Cell("QTD_DES"		):setValue((aAlias[K215])->QTD_DES)
				oSecK215:PrintLine()
				(aAlias[K215])->(dbSkip())
			EndDo
		EndIf
		oSecK215:Finish()
		oReport:PrintText(" ")
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K220                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aAliProc[K220]
		oReport:PrintText("REGISTRO K220 - Outras Movimentações Internas entre Mercadorias")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K220])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[K220])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK220:Init()
				oSecK220:Cell("REG"			):setValue((aAlias[K220])->REG)
				oSecK220:Cell("DT_MOV"		):setValue((aAlias[K220])->DT_MOV)
				oSecK220:Cell("COD_ITEM_O"	):setValue((aAlias[K220])->COD_ITEM_O)
				oSecK220:Cell("COD_ITEM_D"	):setValue((aAlias[K220])->COD_ITEM_D)
				oSecK220:Cell("QTD"			):setValue((aAlias[K220])->QTD)
				oSecK220:PrintLine()
				(aAlias[K220])->(dbSkip())
			EndDo
		EndIf
		oSecK220:Finish()
		oReport:PrintText(" ")
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K230                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aAliProc[K230]
		oReport:PrintText("REGISTRO K230 - Itens Produzidos")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K230])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			If !lEstrMov
				oSecK230:Cell("QTDORI"):Disable()
			EndIf
			While !(aAlias[K230])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK230:Init()
				oSecK230:Cell("REG"			):setValue((aAlias[K230])->REG)
				oSecK230:Cell("DT_INI_OP"	):setValue((aAlias[K230])->DT_INI_OP)
				oSecK230:Cell("DT_FIN_OP"	):setValue((aAlias[K230])->DT_FIN_OP)
				oSecK230:Cell("COD_DOC_OP"	):setValue((aAlias[K230])->COD_DOC_OP)
				oSecK230:Cell("COD_ITEM"	):setValue((aAlias[K230])->COD_ITEM)
				oSecK230:Cell("QTD_ENC"		):setValue((aAlias[K230])->QTD_ENC)
				oSecK230:Cell("QTDORI"		):setValue((aAlias[K230])->QTDORI)
				oSecK230:PrintLine()
				(aAlias[K230])->(dbSkip())
			EndDo
		EndIf
		oSecK230:Finish()
		oReport:PrintText(" ")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K235                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText("REGISTRO K235 - Insumos Consumidos")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K235])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			If !lEstrMov
				oSecK235:Cell("EMPENHO"):Disable()
			EndIf
			While !(aAlias[K235])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK235:Init()
				oSecK235:Cell("REG"			):setValue((aAlias[K235])->REG)
				oSecK235:Cell("DT_SAIDA"	):setValue((aAlias[K235])->DT_SAIDA)
				oSecK235:Cell("COD_ITEM"	):setValue((aAlias[K235])->COD_ITEM)
				oSecK235:Cell("QTD"			):setValue((aAlias[K235])->QTD)
				oSecK235:Cell("COD_INS_SU"	):setValue((aAlias[K235])->COD_INS_SU)
				oSecK235:Cell("COD_DOC_OP"	):setValue((aAlias[K235])->COD_DOC_OP)
				oSecK235:Cell("EMPENHO"		):setValue(If((aAlias[K235])->EMPENHO == "S","Sim","Não"))
				oSecK235:PrintLine()
				(aAlias[K235])->(dbSkip())
			EndDo
		EndIf
		oSecK235:Finish()
		oReport:PrintText(" ")
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K250                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aAliProc[K250]
		oReport:PrintText("REGISTRO K250 - Industrialização Efetuada por Terceiros (Itens Produzidos)")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K250])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[K250])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK250:Init()
				oSecK250:Cell("REG"			):setValue((aAlias[K250])->REG)
				oSecK250:Cell("DT_PROD"		):setValue((aAlias[K250])->DT_PROD)
				oSecK250:Cell("COD_ITEM"	):setValue((aAlias[K250])->COD_ITEM)
				oSecK250:Cell("QTD"			):setValue((aAlias[K250])->QTD)
				oSecK250:Cell("CHAVE"		):setValue((aAlias[K250])->CHAVE)
				oSecK250:PrintLine()
				(aAlias[K250])->(dbSkip())
			EndDo
		EndIf
		oSecK250:Finish()
		oReport:PrintText(" ")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K255                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText("REGISTRO K255 - Industrialização Efetuada por Terceiros (Insumos Consumidos)")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K255])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[K255])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK255:Init()
				oSecK255:Cell("REG"			):setValue((aAlias[K255])->REG)
				oSecK255:Cell("DT_CONS"		):setValue((aAlias[K255])->DT_CONS)
				oSecK255:Cell("COD_ITEM"	):setValue((aAlias[K255])->COD_ITEM)
				oSecK255:Cell("COD_INS_SU"	):setValue((aAlias[K255])->COD_INS_SU)
				oSecK255:Cell("QTD"			):setValue((aAlias[K255])->QTD)
				oSecK255:Cell("CHAVE"		):setValue((aAlias[K255])->CHAVE)
				oSecK255:PrintLine()
				(aAlias[K255])->(dbSkip())
			EndDo
		EndIf
		oSecK255:Finish()
		oReport:PrintText(" ")
	EndIf
	If Existblock("REGK26X") .And. aAliProc[K260]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K260                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText("REGISTRO K260 - Reprocessamento/Reparo de Produto/Insumo")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K260])->(Eof())
			oReport:PrintText(cSemReg)
			If !Existblock("REGK26X")
				oReport:PrintText("Ponto de entrada REGK26X não compilado.")
			EndIf
		Else
			While !(aAlias[K260])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK260:Init()
				oSecK260:Cell("REG"			):setValue((aAlias[K260])->REG)
				oSecK260:Cell("COD_OP_OS"	):setValue((aAlias[K260])->COD_OP_OS)
				oSecK260:Cell("COD_ITEM"	):setValue((aAlias[K260])->COD_ITEM)
				oSecK260:Cell("DT_SAIDA"	):setValue((aAlias[K260])->DT_SAIDA)
				oSecK260:Cell("QTD_SAIDA"	):setValue((aAlias[K260])->QTD_SAIDA)
				oSecK260:Cell("DT_RET"		):setValue((aAlias[K260])->DT_RET)
				oSecK260:Cell("QTD_RET"		):setValue((aAlias[K260])->QTD_RET)
				oSecK260:PrintLine()
				(aAlias[K260])->(dbSkip())
			EndDo
		EndIf
		oSecK260:Finish()
		oReport:PrintText(" ")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K265                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText("REGISTRO K265 - Reprocessamento/Reparo - Mercadorias Consumidas e/ou Retornadas")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K265])->(Eof())
			oReport:PrintText(cSemReg)
			If !Existblock("REGK26X")
				oReport:PrintText("Ponto de entrada REGK26X não compilado.")
			EndIf
		Else
			While !(aAlias[K265])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK265:Init()
				oSecK265:Cell("REG"			):setValue((aAlias[K265])->REG)
				oSecK265:Cell("COD_ITEM"	):setValue((aAlias[K265])->COD_ITEM)
				oSecK265:Cell("QTD_CONS"	):setValue((aAlias[K265])->QTD_CONS)
				oSecK265:Cell("QTD_RET"		):setValue((aAlias[K265])->QTD_RET)
				oSecK265:PrintLine()
				(aAlias[K265])->(dbSkip())
			EndDo
		EndIf
		oSecK265:Finish()
		oReport:PrintText(" ")
	EndIf

	If Existblock("REGK27X") .And. aAliProc[K270]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K270                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText("REGISTRO K270 - Correção de Apontamento: K210, K220, K230, K250 e K260")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K270])->(Eof())
			oReport:PrintText(cSemReg)
			If !Existblock("REGK27X")
				oReport:PrintText("Ponto de entrada REGK27X não compilado.")
			EndIf
		Else
			While !(aAlias[K270])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK270:Init()
				oSecK270:Cell("REG"			):setValue((aAlias[K270])->REG)
				oSecK270:Cell("DT_INI_AP"	):setValue((aAlias[K270])->DT_INI_AP)
				oSecK270:Cell("DT_FIN_AP"	):setValue((aAlias[K270])->DT_FIN_AP)
				oSecK270:Cell("COD_OP_OS"	):setValue((aAlias[K270])->COD_OP_OS)
				oSecK270:Cell("COD_ITEM"	):setValue((aAlias[K270])->COD_ITEM)
				oSecK270:Cell("QTD_COR_P"	):setValue((aAlias[K270])->QTD_COR_P)
				oSecK270:Cell("QTD_COR_N"	):setValue((aAlias[K270])->QTD_COR_N)
				oSecK270:Cell("ORIGEM"		):setValue((aAlias[K270])->ORIGEM)
				oSecK270:PrintLine()
				(aAlias[K270])->(dbSkip())
			EndDo
		EndIf
		oSecK270:Finish()
		oReport:PrintText(" ")
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K275                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText("REGISTRO K275 - Correção de Apontamento: K215, K220, K235, K255 e K265")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K275])->(Eof())
			oReport:PrintText(cSemReg)
			If !Existblock("REGK27X")
				oReport:PrintText("Ponto de entrada REGK27X não compilado.")
			EndIf
		Else
			While !(aAlias[K275])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK275:Init()
				oSecK275:Cell("REG"			):setValue((aAlias[K275])->REG)
				oSecK275:Cell("COD_ITEM"	):setValue((aAlias[K275])->COD_ITEM)
				oSecK275:Cell("QTD_COR_P"	):setValue((aAlias[K275])->QTD_COR_P)
				oSecK275:Cell("QTD_COR_N"	):setValue((aAlias[K275])->QTD_COR_N)
				oSecK275:Cell("COD_INS_SU"	):setValue((aAlias[K275])->COD_INS_SU)
				oSecK275:PrintLine()
				(aAlias[K275])->(dbSkip())
			EndDo
		EndIf
		oSecK275:Finish()
		oReport:PrintText(" ")
	EndIf
	
	If Existblock("REGK280") .And. aAliProc[K280]
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro K280                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText("REGISTRO K280 - Correção de Apontamento - Estoque Escriturado")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[K280])->(Eof())
			oReport:PrintText(cSemReg)
			If !Existblock("REGK280")
				oReport:PrintText("Ponto de entrada REGK280 não compilado.")
			EndIf
		Else
			While !(aAlias[K280])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSecK280:Init()
				oSecK280:Cell("REG"			):setValue((aAlias[K280])->REG)
				oSecK280:Cell("DT_EST"		):setValue((aAlias[K280])->DT_EST)
				oSecK280:Cell("COD_ITEM"	):setValue((aAlias[K280])->COD_ITEM)
				oSecK280:Cell("QTD_COR_P"	):setValue((aAlias[K280])->QTD_COR_P)
				oSecK280:Cell("QTD_COR_N"	):setValue((aAlias[K280])->QTD_COR_N)
				oSecK280:Cell("IND_EST"		):setValue((aAlias[K280])->IND_EST)
				oSecK280:Cell("COD_PART"	):setValue((aAlias[K280])->COD_PART)
				oSecK280:PrintLine()
				(aAlias[K280])->(dbSkip())
			EndDo
		EndIf
		oSecK280:Finish()
		oReport:PrintText(" ")
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro K990                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:PrintText("REGISTRO K990 - Encerramento do Bloco K")
	oReport:ThinLine()
	oReport:PrintText(" ")
	If (aAlias[K990])->(Eof())
		oReport:PrintText(cSemReg)
	Else
		While !(aAlias[K990])->(Eof()) .And. !oReport:Cancel()
			oReport:IncMeter()
			If oReport:Cancel()
				Exit
			EndIf
			oSecK990:Init()
			oSecK990:Cell("REG"			):setValue((aAlias[K990])->REG)
			oSecK990:Cell("QTD_LIN_K"	):setValue((aAlias[K990])->QTD_LIN_K)
			oSecK990:PrintLine()
			(aAlias[K990])->(dbSkip())
		EndDo
	EndIf
	oSecK990:Finish()
	oReport:PrintText(" ")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Registro 0210                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If aAliProc[0210]
		oReport:PrintText("REGISTRO 0210 - Consumo Específico Padronizado")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[0210])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[0210])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSec0210:Init()
				oSec0210:Cell("REG"			):setValue((aAlias[0210])->REG)
				oSec0210:Cell("COD_ITEM"	):setValue((aAlias[0210])->COD_ITEM)
				oSec0210:Cell("COD_I_COMP"	):setValue((aAlias[0210])->COD_I_COMP)
				oSec0210:Cell("QTD_COMP"  	):setValue((aAlias[0210])->QTD_COMP)
				oSec0210:Cell("PERDA"     	):setValue((aAlias[0210])->PERDA)
				oSec0210:PrintLine()
				(aAlias[0210])->(dbSkip())
			EndDo
		EndIf
		oSec0210:Finish()
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Registro 0200                    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oReport:PrintText("0200 Temporario - Produtos utilizados no Bloco K")
		oReport:ThinLine()
		oReport:PrintText(" ")
		If (aAlias[0200])->(Eof())
			oReport:PrintText(cSemReg)
		Else
			While !(aAlias[0200])->(Eof()) .And. !oReport:Cancel()
				oReport:IncMeter()
				If oReport:Cancel()
					Exit
				EndIf
				oSec0200:Init()
				oSec0200:Cell("COD_ITEM"	):setValue((aAlias[0200])->COD_ITEM)
				oSec0200:PrintLine()
				(aAlias[0200])->(dbSkip())
			EndDo
		EndIf
		oSec0200:Finish()
		oReport:PrintText(" ")
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha os Arquivos Temporarios    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aAlias)
	DbSelectArea(aAlias[nX])
	(aAlias[nX])->(DbCloseArea())
	Ferase(aAlias[nX]+GetDBExtension())
Next nX

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fecha os Indices Temporarios     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nX := 1 To Len(aIndices)
	For nY := 1 To Len(aIndices[nX])
		Ferase(aIndices[nX][nY]+OrdBagExt())
	Next nY
Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
Cria o pergunte do relatório
@author bolognesi
@since 13/12/2015
@version 1.5
/*/
//-------------------------------------------------------------------
Static Function AjustaSX1()

Local aAreaSX1 := SX1->(GetArea())
Local aEstrut   := {}
Local aSX1      := {}
Local aStruDic  := SX1->( dbStruct() )
Local cAlias    := ""
Local nI        := 0
Local nJ        := 0
Local nTam1     := Len( SX1->X1_GRUPO )
Local nTam2     := Len( SX1->X1_ORDEM )

aEstrut := { "X1_GRUPO"  , "X1_ORDEM"  , "X1_PERGUNT", "X1_PERSPA" , "X1_PERENG" , "X1_VARIAVL", "X1_TIPO"   , ;
             "X1_TAMANHO", "X1_DECIMAL", "X1_PRESEL" , "X1_GSC"    , "X1_VALID"  , "X1_VAR01"  , "X1_DEF01"  , ;
             "X1_DEFSPA1", "X1_DEFENG1", "X1_CNT01"  , "X1_VAR02"  , "X1_DEF02"  , "X1_DEFSPA2", "X1_DEFENG2", ;
             "X1_CNT02"  , "X1_VAR03"  , "X1_DEF03"  , "X1_DEFSPA3", "X1_DEFENG3", "X1_CNT03"  , "X1_VAR04"  , ;
             "X1_DEF04"  , "X1_DEFSPA4", "X1_DEFENG4", "X1_CNT04"  , "X1_VAR05"  , "X1_DEF05"  , "X1_DEFSPA5", ;
             "X1_DEFENG5", "X1_CNT05"  , "X1_F3"     , "X1_PYME"   , "X1_GRPSXG" , "X1_HELP"   , "X1_PICTURE", ;
             "X1_IDFIL"  }

aAdd( aSX1, {'MTR241','01','Do Periodo ?','','','mv_cha','D',8,0,0,'G','','mv_par01','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aSX1, {'MTR241','02','Ate o Periodo ?','','','mv_chb','D',8,0,0,'G','','mv_par02','','','','','','','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aSX1, {'MTR241','03','Reg. 0210 por Mov.?','','','mv_chc','N',1,0,2,'C','','mv_par03','Sim','','','','','Não','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aSX1, {'MTR241','04','Detalhar K250/K255?','','','mv_chd','N',1,0,2,'C','','mv_par04','Sim','','','','','Não','','','','','','','','','','','','','','','','','','','','','','','',''} )
aAdd( aSX1, {'MTR241','05','Gerar apenas K200/K280?','','','mv_che','N',1,0,2,'C','','mv_par05','Sim','','','','','Não','','','','','','','','','','','','','','','','','','','','','','','',''} )

//
// Atualizando dicionário
//

nPosPerg:= aScan( aEstrut, "X1_GRUPO"   )
nPosOrd := aScan( aEstrut, "X1_ORDEM"   )
nPosTam := aScan( aEstrut, "X1_TAMANHO" )
nPosSXG := aScan( aEstrut, "X1_GRPSXG"  )

dbSelectArea( "SX1" )
SX1->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSX1 )
    If !SX1->( dbSeek( PadR( aSX1[nI][nPosPerg], nTam1 ) + PadR( aSX1[nI][nPosOrd], nTam2 ) ) )
		RecLock( "SX1", .T. )
		For nJ := 1 To Len( aSX1[nI] )
	 		If aScan( aStruDic, { |aX| PadR( aX[1], 10 ) == PadR( aEstrut[nJ], 10 ) } ) > 0
				SX1->( FieldPut( FieldPos( aEstrut[nJ] ), aSX1[nI][nJ] ) )
			EndIf
		Next nJ
		MsUnLock()
	EndIf
Next nI

RestArea(aAreaSX1)
return