#include "protheus.ch"
#include "rwmake.ch"
#include "TOPCONN.ch"
#INCLUDE 'tbiconn.ch'

/*
/////////////////////////////////////////////////////////////////////////////////
//                                                                             //
//   Programa ...: CDPCP04                            Modulo : SIGAEST/PCP     //
//                                                                             //
//   Autor ......: Roberto Oliveira                   Data ..: 16/06/2016      //
//                                                                             //
//   Objetivo ...: Enviar e-mail das produções de PAs no PCFactory que não te  //
//                 nham sido recebidos (pesados) na expedição.                 //
//                                                                             //
//   Uso ........: Especifico da Cobrecom                                      //
//                                                                             //
/////////////////////////////////////////////////////////////////////////////////
*/
***********************
User Function CDPCP04()
***********************
*
// Abre somente uma mensagem para confirmar se envia ou não o e-mail.
DbSelectArea("SD3")
If MsgBox("Deseja Enviar E-mail das Produções Não Transferidas para o EPA?","Confirma?","YesNo")
	Processa({|| u_CDPCP04SCH(xFilial("SD3"))})
	Alert("Email Enviado!")
EndIf
Return(.T.)
*
**********************************
User Function CDPCP04SCH(_cFilSD3)
**********************************
*
Local _dDtIni,_cFilSD3
local cDestItu := ""
local cDestTL := ""

If Select("SX2") == 0
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"
EndIf

cDestItu := GetNewPar("ZZ_WFDIVIT","divergenciasitu@cobrecom.com.br")
cDestTL := GetNewPar("ZZ_WFDIVTL","divergenciastl@cobrecom.com.br")

_dDtIni := DaySum(GetMV("MV_DBLQMOV"),1)
//DaySum( dDate , nDays ) //Soma Dias em Uma Data
//Ctod('01/10/2016')

DbSelectArea("SD3")
DbSetOrder(1)

DbSelectArea("SZL")
DbSetOrder(1)

DbSelectArea("SB1")
DbSetOrder(1)

cQuery := " SELECT D3.D3_FILIAL, D3.D3_TM, D3.D3_COD, B1_DESC, D3.D3_DOC, D3.D3_ZZUNMOV, D3.D3_HIST, D3.D3_OP, D3.D3_EMISSAO, D3.D3_QUANT, "
cQuery += " 	(SELECT ISNULL(SUM(ZL_1.ZL_METROS),0) "
cQuery += "	FROM "+RetSqlName("SZL") + " ZL_1 "
cQuery += "	WHERE ZL_1.ZL_FILIAL = D3.D3_FILIAL "
cQuery += "	AND ZL_1.ZL_UNMOV = D3.D3_ZZUNMOV "
cQuery += "	AND ZL_1.ZL_STATUS = 'A' "
cQuery += "	AND ZL_1.D_E_L_E_T_ = D3.D_E_L_E_T_) STATUS_A, "
cQuery += "	(SELECT ISNULL(SUM(ZL_2.ZL_METROS),0) "
cQuery += "	FROM "+RetSqlName("SZL") + " ZL_2 "
cQuery += "	WHERE ZL_2.ZL_FILIAL = D3.D3_FILIAL "
cQuery += "	AND ZL_2.ZL_UNMOV = D3.D3_ZZUNMOV "
cQuery += "	AND ZL_2.ZL_STATUS = 'P' "
cQuery += "	AND ZL_2.D_E_L_E_T_ = D3.D_E_L_E_T_) STATUS_P , "
cQuery += "	D3.D3_ZZLOTE, D3_2.D3_ZZLOTE, D3_2.D3_CF "
cQuery += "FROM "+RetSqlName("SD3") + "  D3 "
cQuery += "	INNER JOIN "+RetSqlName("SB1") + " B1 "
cQuery += "	ON '  ' = B1_FILIAL "
cQuery += "	AND D3.D3_COD = B1_COD "
cQuery += "	AND D3.D_E_L_E_T_ = B1.D_E_L_E_T_ "
cQuery += "LEFT JOIN SD3010 D3_2 "
cQuery += "ON D3.D3_FILIAL = D3_2.D3_FILIAL "
cQuery += "AND D3.D3_ZZLOTE = D3_2.D3_ZZLOTE "
cQuery += "AND '503' = D3_2.D3_TM "
cQuery += "AND D3.D_E_L_E_T_ = D3_2.D_E_L_E_T_ "
If !Empty(Alltrim(_cFilSD3))
	cQuery +=  "WHERE D3.D3_FILIAL IN ('" + _cFilSD3 + "') "
Else
	cQuery += " WHERE D3.D3_FILIAL IN ('01','02') "
EndIf
cQuery += "AND (D3.D3_TM = '006' OR D3.D3_TM = '002') "
cQuery += "AND D3.D3_GRUPO = 'PA01' "
cQuery += "AND D3.D3_ESTORNO <> 'S' "
cQuery += "AND D3.D3_EMISSAO >= '" + Dtos(_dDtIni) + "' "
cQuery += "AND D3.D3_EMISSAO < '"+Dtos(Date())+"' "
cQuery += "AND D3.D3_ZZUNMOV <> '' "
cQuery += "AND "
cQuery += "	(SELECT ISNULL(SUM(ZL_3.ZL_METROS),0) "
cQuery += "	FROM "+RetSqlName("SZL") + " ZL_3 "
cQuery += "	WHERE ZL_3.ZL_FILIAL = D3.D3_FILIAL "
cQuery += "	AND ZL_3.ZL_UNMOV = D3.D3_ZZUNMOV "
cQuery += "	AND ZL_3.ZL_STATUS IN ('P','A') "
cQuery += "	AND ZL_3.D_E_L_E_T_ = D3.D_E_L_E_T_) <> D3.D3_QUANT "
cQuery += " AND D3.D_E_L_E_T_ = '' "
cQuery += " AND ISNULL(D3_2.D3_ZZLOTE,'') = '' "
cQuery += " ORDER BY  D3.D3_FILIAL, D3.D3_EMISSAO, D3.D3_TM, D3.D3_COD, D3.D3_ZZUNMOV "

cQuery := ChangeQuery(cQuery)

If Select("TRB")>0
	DbSelectArea("TRB")
	DbCloseArea()
EndIf
TCQUERY cQuery NEW ALIAS "TRB"

DbSelectArea("TRB")
DbGotop()

//D3_FILIAL, D3_TM,
//D3_COD, B1_DESC, D3_DOC, D3_ZZUNMOV, D3_HIST, D3_OP, D3_EMISSAO, D3_QUANT,  STATUS_A, STATUS_P
//E       E        E       D           E        E      D           D          D         D

//Center Left Right
_aLado := {} // Informar a posição de cada item do acab
Aadd(_aLado,"Left",)
Aadd(_aLado,"Left",)
Aadd(_aLado,"Left",)
Aadd(_aLado,"Right")
Aadd(_aLado,"Left",)
Aadd(_aLado,"Left",)
Aadd(_aLado,"Right")
Aadd(_aLado,"Right")
Aadd(_aLado,"Right")
Aadd(_aLado,"Right")
Aadd(_aLado,"Right")

_aCab   := {}
Aadd(_aCab,"Cód.Produto",)
Aadd(_aCab,"Descrição")
Aadd(_aCab,"Nro.Docto.")
Aadd(_aCab,"Nro.Unimov")
Aadd(_aCab,"Histórico")
Aadd(_aCab,"Nro.OP.")
Aadd(_aCab,"Data")
Aadd(_aCab,"Qtd.Produz.")
Aadd(_aCab,"Qtd.Pes.Proc.")
Aadd(_aCab,"Qtd.Pes.A Proc.")
Aadd(_aCab,"Diferença")
_aDet01 := {}
_aDet02 := {}

//D3_FILIAL, D3_TM,
//D3_COD, B1_DESC, D3_DOC, D3_ZZUNMOV, D3_HIST, D3_OP, D3_EMISSAO, D3_QUANT,  STATUS_A, STATUS_P
//E       E        E       D           E        E      D           D          D         D

Do While !TRB->(Eof())
	If TRB->D3_FILIAL == "01"
		Aadd(_aDet01,{TRB->D3_COD, TRB->B1_DESC, TRB->D3_DOC, Str(TRB->D3_ZZUNMOV,10),;
		              TRB->D3_HIST, TRB->D3_OP, Dtoc(Stod(TRB->D3_EMISSAO)), Transform(TRB->D3_QUANT,"@E 999,999.99"),;
		              Transform(STATUS_A,"@E 999,999.99"), Transform(STATUS_P,"@E 999,999.99"),;
		              Transform((TRB->D3_QUANT-STATUS_A-STATUS_P),"@E 999,999.99") })
	ElseIf TRB->D3_FILIAL == "02"
		Aadd(_aDet02,{TRB->D3_COD, TRB->B1_DESC, TRB->D3_DOC, Str(TRB->D3_ZZUNMOV,10),;
		              TRB->D3_HIST, TRB->D3_OP, Dtoc(Stod(TRB->D3_EMISSAO)), Transform(TRB->D3_QUANT,"@E 999,999.99"),;
		              Transform(STATUS_A,"@E 999,999.99"), Transform(STATUS_P,"@E 999,999.99"),;
		              Transform((TRB->D3_QUANT-STATUS_A-STATUS_P),"@E 999,999.99") })
	EndIf
	TRB->(DbSkip())
EndDo

DbSelectArea("TRB")
DbCloseArea()

// Volta para a filial correta
If Len(_aDet01) > 0

	//envMail(aTo,cSubject,aHead,aContent,lAuto,_aLado)
	u_envMail({cDestItu},;
			   "Itu - Divergência Produção x Pesagens - Data Base " + Dtoc(Date()-1) + " - Reportes a partir de " + Dtoc(_dDtIni) + " - " + Transform(Len(_aDet01),"@E 99,999") + " Itens",;
			_aCab,;
			_aDet01,,;
			_aLado)
EndIf
If Len(_aDet02) > 0

	u_envMail({cDestTL},;
			   "3 Lagoas - Divergência Produção x Pesagens - Data Base " + Dtoc(Date()-1) + " - Reportes a partir de " + Dtoc(_dDtIni) + " - " + Transform(Len(_aDet02),"@E 99,999") + " Itens",;
			_aCab,;
			_aDet02,,;
			_aLado)
EndIf
Return(.T.)