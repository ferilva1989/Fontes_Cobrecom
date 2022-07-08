#include "protheus.ch"
#include "rwmake.ch"
#include "TOPCONN.ch"
#INCLUDE 'tbiconn.ch'

/*/{Protheus.doc} CDFIS01
//TODO WorkFlow com envio de email automatico com NFs para ser classificadas no Protheus.
@author juliana.leme
@since 30/09/2016
@version undefined

@type function
/*/
User Function CDFIS01()
	// Abre somente uma mensagem para confirmar se envia ou não o e-mail.
	If MsgBox("Deseja Enviar E-mail das Pre-Notas não Classificadas","Confirma?","YesNo")
		Processa({|| u_CDFIS01SCH()})
		Alert("Email Enviado!")
	EndIf
Return(.T.)

/*/{Protheus.doc} CDFIS01SCH
//TODO Descrição auto-gerada.
@author juliana.leme
@since 30/09/2016
@version undefined

@type function
/*/
User Function CDFIS01SCH()
 	Local ZZ_TIPONFSC := GetMV('ZZ_TIPONF')
 	
	If Select("SX2") == 0
		PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"
	EndIf

	cQuery := " SELECT DISTINCT F1_FILIAL FILIAL, "
	cQuery += " 				F1_SERIE SERIE, "
	cQuery += " 				F1_DOC DOC, "
	cQuery += " 				F1_FORNECE CODFOR, "
	cQuery += " 				A2.A2_NREDUZ NOMEFOR, "
	cQuery += " 				F1_EMISSAO EMISSAO, "
	cQuery += " 				F1.F1_DTDIGIT DIGITA "
	cQuery += " FROM SD1010 D1  "
	cQuery += " 	INNER JOIN SF1010 F1 ON F1.F1_FILIAL = D1.D1_FILIAL AND F1.F1_DOC = D1.D1_DOC AND F1.F1_SERIE = D1.D1_SERIE AND D1.D1_FORNECE = F1.F1_FORNECE "
	cQuery += " 	INNER JOIN SA2010  A2 ON A2.A2_COD = D1.D1_FORNECE AND '' = A2.A2_FILIAL "
	cQuery += " 	INNER JOIN SB1010 B1 ON B1.B1_COD = D1.D1_COD AND '' = B1.B1_FILIAL "
	cQuery += " WHERE D1_CF = ''"
	cQuery += " 	AND F1_EMISSAO >= '20160801' "
	cQuery += " 	AND F1_DTDIGIT <> '" + DtoS(dDataBase)+ "' "
	cQuery += " 	AND B1.B1_TIPO IN " + "(" + ZZ_TIPONFSC +")"  //('MP','PI') "
	cQuery += " 	AND F1_SERIE <> 'ROM' "
	cQuery += " 	AND D1.D_E_L_E_T_ = '' "
	cQuery += " 	AND F1.D_E_L_E_T_ = '' "
	cQuery += " ORDER BY F1_FILIAL, F1_EMISSAO ,F1_FORNECE "

	cQuery := ChangeQuery(cQuery)

	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"

	DbSelectArea("TRB")
	DbGotop()

	//D1_FILIAL, D1_SERIE, D1_DOC, D1_FORNECE, A2.A2_NREDUZ, D1_EMISSAO "
	//E       	 E         E       E           E        	 E

	//Center Left Right
	_aLado := {} // Informar a posição de cada item do acab
	Aadd(_aLado,"Left")
	Aadd(_aLado,"Left")
	Aadd(_aLado,"Left")
	Aadd(_aLado,"Left")
	Aadd(_aLado,"Left")
	Aadd(_aLado,"Left")
	Aadd(_aLado,"Right")
	_aCab   := {}
	Aadd(_aCab,"Filial")
	Aadd(_aCab,"Serie/Documento")
	Aadd(_aCab,"Fornecedor")
	Aadd(_aCab,"Nome Fornecedor")
	Aadd(_aCab,"Data Emissao")
	Aadd(_aCab,"Data Digitacão")
	Aadd(_aCab,"Atraso Lançamento")
	_aDet01 := {}

	Do While !TRB->(Eof())
		Aadd(_aDet01,{IIF(TRB->FILIAL = "01","ITU","TRES LAGOAS"), TRB->SERIE +"/"+ TRB->DOC, TRB->CODFOR ,;
				TRB->NOMEFOR, Dtoc(Stod(TRB->EMISSAO)), DtoC(StoD(TRB->DIGITA)), Str(DateDiffDay(StoD(TRB->DIGITA),dDataBase)) })
		TRB->(DbSkip()) //DateDiffDay
	EndDo

	DbSelectArea("TRB")
	DbCloseArea()

	// Volta para a filial correta
	If Len(_aDet01) > 0
		u_envMail({"wf_nf_class@cobrecom.com.br"},"Pré-Nota Sem Classificação, Verificar!", _aCab, _aDet01,_aLado)
	EndIf
Return(.T.)