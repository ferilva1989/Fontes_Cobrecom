#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} CDTesInt
//TODO Captura TES correta para pedido/orçamento de vendas.
@author juliana.leme
@since 10/11/2016
@version undefined
@param cTpOper	, characters, descricao
@param ctpCliFor, characters, descricao
@param lTabZ	, logico	, descricao
@type function
/*/
User Function CDTesInt(cTpOper,cTpCliFor,lTabZ)
	Local cTes 				:= ""
	Local cMVSUBTRIB		:= ""
	Local lProtoc			:= .F.
	local lNewTesInt		:= GetNewPar("ZZ_NSAITES", .F.)
	local cTipo				:= "N"
	Default cTpOper 		:= "01"
	Default cTpCliFor 		:= SA1->A1_TIPO

	//PARA FORÇAR O TESTE
	//lNewTesInt := .T.
	if lNewTesInt
		if cTpOper == '03'
			cTpOper := '01'
		endif
		if FunName() == "MATA410" .or. FunName() == "MATA416"
			cTipo := M->C5_TIPO
		endif
		cTes := newSaiTes(cTpOper, cTipo, AllTrim(SA1->A1_COD), AllTrim(SA1->A1_LOJA), Alltrim(SB1->B1_COD))
		if empty(cTes)
			u_autoalert('NEWTES -> TES não Localizado!')
		endif
	endif
	
	if empty(cTes)
		//Verifica a filial de faturamento tem convenio para faturamento com ST
		If FindFunction("GETSUBTRIB")
			cMVSUBTRIB := GetSubTrib()
		Endif

		DbSelectArea("CLO")
		DbSetOrder(1)
		//Possui procotolo ?
		If CLO->(DbSeek(cFilAnt+SA1->A1_EST,.F.))
			lProtoc := .T.
		Else
			lProtoc := .F.
		EndIf

		If cTpOper $  "01//03//"
			//VENDA COM ICMS DIFERIDO
			If SA1->A1_TES = "506"
				cTes	:= "506"
				//VENDA INSENTA
			ElseIf SA1->A1_TES = "543"
				cTes	:= "543"
				//EMPRESA PUBLICA
			ElseIf SA1->A1_TES = "943"
				cTes	:= "943"
				//ESPECÍFICO P/ ITAIPÚ
			ElseIf SA1->A1_TES = "547"
				cTes	:= "547"
				//VENDA DE ATIVO IMOBILIZADO
			ElseIf SB1->B1_TIPO = "AI"
				cTes	:= "836"
				//VENDA DE EXPORTACAO
			ElseIf cTpCliFor = "X"
				cTes	:= "970"
				// VENDA DE SUCATA COM PIS/COFINS
			ElseIf (SA1->A1_RECPIS == "S") .and. SB1->B1_TIPO == "SC"
				cTes := "874"
				//VENDA DE SUCATA SEM PIS/COFINS
			ElseIf (SA1->A1_RECPIS == "N") .and. SB1->B1_TIPO == "SC"
				cTes := "841"
			ElseIf  (Alltrim(SB1->B1_COD) $ "MC20000023")
				cTes := "632"
				// VENDA DE SUCATA DE FERRO, PLASTICO E PAPELÃO COM PIS/COFINS POR Itu
			ElseIf (SA1->A1_RECPIS == "S") .and. (Alltrim(SB1->B1_COD) $ "MC20000018//MC20000019//MC20000020//MC20000021//MC20000024") .and. xFilial("SC6") == "01"
				cTes := "944"
				// VENDA DE SUCATA DE FERRO, PLASTICO E PAPELÃO COM PIS/COFINS POR TL
			ElseIf (SA1->A1_RECPIS == "S") .and. (Alltrim(SB1->B1_COD) $ "MC20000018//MC20000019//MC20000020//MC20000021//MC20000024") .and. xFilial("SC6") == "02"
				cTes := "900"
				//VENDA NORMAL COM ST
			ElseIf cTpCliFor = "S" .and. !(SA1->A1_CALCSUF $ "SI") .and. ( At (SA1->A1_EST, cMVSUBTRIB)>0 .or. lProtoc)
				if Empty(cTes := is12Cobre('SOL_COM_ST'))
					cTes	:= "521"
				endif
			ElseIf cTpCliFor = "S" .and. !(SA1->A1_CALCSUF $ "SI") .and. At (SA1->A1_EST, cMVSUBTRIB)<=0
				if Empty(cTes := is12Cobre('SOL_SEM_ST'))
					cTes	:= "501"
				endif
				//VENDA CONSUM. FINAL CONTRIBUINTE PARA ESTADO PB, BASE DUPLA CALCULA DIFERENÇA ENTRE ALIQUOTA ST e ICMS INTERESTADUAL
			ElseIf cTpCliFor = "F" .and. SA1->A1_CONTRIB = "1" .and. !(SA1->A1_CALCSUF $ "SI") .and. SA1->A1_EST $ GetNewPar("MV_UFSTALQ", "")
				cTes :=  IIf(SA1->A1_TES == "501", "501", "945")
				//VENDA CONSUM. FINAL CONTRIBUINTE
			ElseIf cTpCliFor = "F" .and. SA1->A1_CONTRIB = "1" .and. !(SA1->A1_CALCSUF $ "SI")
				cTes :=  IIf(SA1->A1_TES == "501", "501", "921")
				//VENDA NORMAL
			ElseIf cTpCliFor = "R" .and. !(SA1->A1_CALCSUF $ "SI")
				if Empty(cTes := is12Cobre('VENDA_NORMAL'))
					cTes	:= "501"
				endif
				//VENDA NORMAL CONSUM FINAL NAO CONTRIB
			ElseIf cTpCliFor = "F" .and. SA1->A1_CONTRIB = "2" .and. !(SA1->A1_CALCSUF $ "SI")
				cTes	:= "560"
				//VENDA ZONA FRANCA CONS. FINAL
			ElseIf cTpCliFor = "F" .and. SA1->A1_CONTRIB = "1" .and. SA1->A1_CALCSUF $ "SI" .and. SA1->A1_SIMPNAC = "1"
				cTes	:= "616"
				//VENDA ZONA FRANCA SOLIDÁRIO
			ElseIf cTpCliFor = "S" .and. SA1->A1_CONTRIB = "1" .and. SA1->A1_CALCSUF $ "SI" .and. SA1->A1_SIMPNAC = "1"
				cTes	:= "600"
			ElseIf cTpCliFor = "R" .and. SA1->A1_CONTRIB = "1" .and. SA1->A1_CALCSUF $ "SI"
				cTes	:= "612"
			ElseIf cTpCliFor = "F" .and. SA1->A1_CONTRIB = "1" .and. SA1->A1_CALCSUF $ "SI"
				cTes	:= "613"
				//VENDA ZONA FRANCA DESC ICMS PIS E COFINS
			ElseIf SA1->A1_CONTRIB = "1" .and. SA1->A1_CALCSUF $ "SI" .and. SA1->A1_SIMPNAC = "2"
				cTes	:= "527"
			EndIf
		EndIf
		//FIM VENDA

		//OPERACAO = SIMPLES FATUR PARA ENTREGA FUTURA
		If cTpOper = "02"
			cTes	:= "846"
		EndIf
		//FIM SIMPLES FATUR PARA ENTREGA FUTURA

		//BONIFICAÇÃO/BRINDE
		If cTpOper = "04"
			if SA1->A1_CALCSUF $ "SI" .and. SA1->A1_XREIDI = "N"
				cTes := "614"
			ElseIf SB1->B1_NOME == "191"
				cTes := "603"
			ElseIf cTpCliFor = "F" .and. SA1->A1_CONTRIB = "2"
				cTes := "982"
			Else
				If FunName() == "MATA410" .or. FunName() == "MATA416"
					If (M->C5_DESCESP == 100 .Or. M->C5_DESCEQT == 100)
						cTes := "617"
					Else
						cTes := "517"
					EndIf
				Else
					cTes := "517"
				EndIf
			EndIf
		EndIf

		//VENDA ENTREGA FUTURA
		If cTpOper = "06"
			//COM DIFA OU ST
			If cTpCliFor = "S" .and. SA1->A1_CONTRIB = "1"
				cTes	:= "905"
				//NÃO CONTRIBUINTE
			ElseIf (SA1->A1_CONTRIB <> "1")
				cTes	:= "561"
				//REVENDEDOR
			ElseIf cTpCliFor = "R"
				cTes	:= "904"
				//REVENDEDOR
			ElseIf cTpCliFor = "F" .and. SA1->A1_CONTRIB = "1"
				cTes	:= "940"
			EndIf
		EndIf
		//FIM VENDA ENTREGA FUTURA

		//CASO ESPECIFICO ANUL. FRETE VALOR AQUISITIVO
		If cTpOper == "07"
			cTes := "610"
		EndIf

		//TIPO COMPLEMENTO DE PRECOS
		If cTpOper = "08"
			cTes	:= "871"
		EndIf
		//FIM COMPLEMENTO DE PRECOS

		//TRANSFERENCIAS
		If cTpOper = "09"
			If SB1->B1_TIPO $ ("MP//PA//PI//SC") .and. (At(SA1->(A1_EST), 'MG')>0)
				cTes := "949"
				//TRANSF MATERIA PRIMA
			ElseIf (SB1->B1_TIPO == "MP" .OR. SB1->B1_TIPO == "ME") .AND. (SB1->B1_PESCOB > 0)
				cTes := "842"
				//Transferencia de Vergalhão em Itu
			ElseIf Alltrim(SB1->B1_COD) == "2010000000" .and. cFilAnt = "01"
				cTes := "842"
				//TRANSF DE PROD ACABADO E INTERMED
			ElseIf SB1->B1_TIPO $ ("PA//PI//SC")
				cTes := "849"
				//TRANSF DE ATIVO FIXO
			ElseIf SB1->B1_TIPO == "AI"
				if (AllTrim(GetNewPar( 'MV_ESTADO', '',FwFilial())) == 'MS')
					cTes := "906"
				else
					cTes := SB1->B1_TS
					If Empty(cTes)
						cTes := "627"
					EndIf
				endif
				//TRANSF DE MATERIAL DE CONSUMO --OK
			ElseIf SB1->B1_TIPO $ ("MC//MS")
				cTes := "908"
			ElseIf (SB1->B1_TIPO == "MP" .OR. SB1->B1_TIPO == "ME") .AND. (SB1->B1_PESCOB <= 0) // FALTA ESSE
				cTes := "629"
				//OUTROS INSUMOS = MATERIAL DE EMBALAGEM
			ElseIf SB1->B1_TIPO == "OI"
				cTes := "629"
			EndIf
		EndIf
		//FIM TRANSFERENCIA

		If cTpOper = "10"
			//DEVOL MATERIA PRIMA
			If SB1->B1_TIPO $ "MP//SC//ME//PA//OI"
				If SA2->A2_EST == 'MG'
					cTes := "710"
				elseIf SA2->A2_EST == SM0->M0_ESTENT
					cTes := "700"
				endif
			ElseIf SB1->B1_TIPO == "MC"
				//M.CONSUMO
				cTes := "946"
			Else
				cTes := "549"
			EndIf
		EndIf

		//INDUSTRIALIZAÇÃO MATERIA PRIMA
		If cTpOper = "11"
			If SB1->B1_TIPO $ "MP"
				//M.PRIMA
				cTes := "539"
			Else
				//P.ACABADO
				cTes := "551"
			EndIf
		EndIf

		//VENDA POR CONTA E ORDEM
		If cTpOper = "12"
			If cTpCliFor = "S"
				cTes	:= "521"
			Else
				cTes	:= "876"
			EndIf
		EndIf
		//FIM VENDA POR CONTA E ORDEM

		//TIPO COMPLEMENTO DE ICMS
		If cTpOper = "13"
			If Alltrim(SB1->B1_COD) == "IM01000001"
				//ICMS
				cTes	:= "918"
			ElseIf Alltrim(SB1->B1_COD) == "IM01000002"
				//ST
				cTes	:= "856"
			ElseIf Alltrim(SB1->B1_COD) == "IM01000005"
				//DIFAL
				cTes	:= "562"
			EndIf
		EndIf
		//FIM COMPLEMENTO DE ICMS

		//VENDA POR CONTA E ORDEM PARA INDSUTRIALZ
		If cTpOper = "14"
			If (cTpCliFor == "F" .and. SA1->A1_CONTRIB == "2" .and. !(SA1->A1_CALCSUF $ "SI") .and. xFilial("SC6") == "03")
				cTes	:= "552"
			Else
				cTes	:= "838"
			EndIf
		EndIf
		//FIM VENDA POR CONTA E ORDEM PARA INDSUTRIALZ

		//REMESSA PARA TESTE
		If cTpOper = "15"
			If SB1->B1_TIPO $ "MC//MS"
				cTes := SB1->B1_TS
			Else
				cTes := "922"
			EndIf
		EndIf

		//REVENDA
		If cTpOper = "16"
			//REVENDA DE PALLET
			If SB1->(Alltrim(B1_POSIPI)) == '44152000' .and. SB1->B1_TIPO == "MC"
				cTes :="843"
			ElseIf cTpCliFor = "S" .and. !(SA1->A1_CALCSUF $ "SI") .and. ( At (SA1->A1_EST, cMVSUBTRIB)>0 .or. lProtoc)
				cTes := '930'
				//VENDA NORMAL CONSUM FINAL NAO CONTRIB
			ElseIf cTpCliFor = "F" .and. SA1->A1_CONTRIB = "2" .and. !(SA1->A1_CALCSUF $ "SI")
				cTes := "552"
			ElseIf SB1->B1_TIPO $ "MP" .and. SB1->B1_IPI > 0
				cTes := "999"
			Else
				cTes := "502"
			EndIf
		EndIf

		//INDUSTRIALIZAÇÃO MATERIA PRIMA //Retorno fisico
		If cTpOper = "17"
			If SB1->B1_TIPO $ "MP//PI"
				//M.PRIMA
				cTes := "539"
			Else
				//P.ACABADO
				cTes := "540"
			EndIf
		EndIf

		//REMESSA GRATIS EXPORTACAO
		If cTpOper = "18"
			cTes := "898"
		EndIf

		//DEVOLUÇÔES DE COMPRAS
		If cTpOper = "19"
			//DEVOL MATERIA PRIMA
			If SB1->B1_TIPO $ "ME//PI//MP//OI"
				If SB1->B1_IPI > 0
					cTes := "601"
				Else
					cTes := "950"
				EndIf
			Else
				cTes := SB1->B1_TS
			EndIf
		EndIf
		//FIM DEVOLUÇÔES DE COMPRAS

		//RETORNO DE COMODATO
		If cTpOper = "20"
			cTes := "713"
		EndIf

		//PARA DEMONSTRACAO
		If cTpOper = "21"
			If SB1->B1_TIPO $ ("PA//PI//SC//ME//OI")
				cTes := "705"
			Else
				cTes := "546"
			Endif
		EndIf

		//PARA FEIRAS/EXPOSICAO
		If cTpOper = "22"
			If SB1->B1_TIPO $ ("PA//PI//SC//ME//OI")
				cTes := "702"
			Else
				cTes := "714"
			EndIf
		EndIf

		//PARA CONSERTO
		If cTpOper = "23"
			If cTpCliFor = "X"
				cTes := "801"
			Else
				cTes := "703"
			EndIf
		EndIf

		//VASILHAME/SACARIA
		If cTpOper = "24"
			If SB1->B1_TIPO = "ME"
				cTes := "704"
			Else
				cTes := "507"
			EndIf
		EndIf

		//RETORNO DE MATERIAL APLICADO NA INDUSTRIALIZACAO
		If cTpOper = AllTrim(GetNewPar('ZZ_OPERDRI','25'))
			If SB1->B1_TIPO # "PA"
				cTes := "539"
			EndIf
		EndIf

		//VASILHAME E SACARIA
		If cTpOper = "27"
			If SB1->B1_TIPO $ ("MC//AI")
				cTes := "623"
			Else
				cTes := "706"
			EndIf
		EndIf

		If cTpOper = "28"
			//PARA AMOSTRA GRATIS
			cTes := "519"
		EndIf

		If cTpOper = "29"
			//POR CONTA E ORDEM DE TERCEIRO
			cTes := "829"
		EndIf

		If cTpOper = "30"
			//POR CONTA E ORDEM ESTABELECIMENTO
			cTes := "635"
		EndIf

		//DEMONSTRAÇÃO
		If cTpOper = "31"
			cTes := "870"
		EndIf

		//RETORNO DE LOCAÇÃO
		If cTpOper = "32"
			cTes := "865"
		EndIf

		//RETORNO DE EMPRESTIMO
		If cTpOper = "33"
			cTes := "625"
		EndIf

		//USO E CONSUMO INTERNO
		If cTpOper = "34"
			If xFilial("SC6") == "01"
				cTes := "750"
			Else
				cTes := "542"
			EndIf
		EndIf

		//REMESSA ARMAZENAGEM FORA ESTABELECIMENTO
		If cTpOper = "35"
			cTes := "580"
		EndIf

		//COMPRA PARA INDUSTRIALIZAÇÃO POR CONTA E ORDEM DE TERCEIROS
		If cTpOper = "36"
			If SA1->A1_EST == SM0->M0_ESTENT
				cTes := "581"
			Else
				cTes := "583"
			EndIf
		EndIf

		If cTpOper = "37" .and. AllTrim(SB1->B1_TIPO) $ ("MP//PA//PI")
			cTes := "629"
		EndIf

		//REMESSA PARA EXPORTACAO
		If cTpOper = "38"
			if cTpCliFor = "X"
				cTes := "977"
			endif
		EndIf

		//DEVOLUÇÃO DE TRASNFERENCIA/ORIGEM
		If cTpOper = "39"
			If SB1->B1_TIPO $ ("MP//PA//PI")
				cTes := "937"
			endif
		EndIf

		//TROCA
		If cTpOper = "40"
			cTes := "545"
		EndIf

		//VENDA REIDI/REB
		If cTpOper = "41"
			If cTpCliFor = "F" .and. SA1->A1_CONTRIB = "1" .and. !(SA1->A1_CALCSUF $ "SI") .and. SA1->A1_XREIDI = "S"
				cTes := "947"
			ElseIf SA1->A1_XREIDI = "S"
				iif(cTpCliFor = "F" .and. SA1->A1_CONTRIB = "2" , cTes := "868", cTes := "530")
			endif
		endif

		//Retorno de Material Recebido para teste
		If cTpOper = "42"
			cTes := "891"
		EndIf

		If cTpOper = "98"
			cTes := SB1->B1_TS
		EndIf

		If cTpOper = "97"
			If Alltrim(SB1->B1_TIPO) == "SC"
				cTes := "973"
			ElseIf Alltrim(SB1->B1_COD) $ ("MC20000023")
				cTes := "978"
			ElseIf Alltrim(SB1->B1_GRUPO) $ ("MC20") .and. xFilial("SC6") == "02"
				cTes := "975"
			ElseIf Alltrim(SB1->B1_GRUPO) $ ("MC20") .and. xFilial("SC6") == "01"
				cTes := "979"
			EndIf
		EndIf

		//Caso não encontre verificar...
		If Alltrim(cTes) == ""
			Alert("Nenhuma TES localizada para essa operação, acione o Fiscal!")
		EndIf
	endif
Return(cTes)


static function is12Cobre(cOper)
	local cTes as character
	cTes := ''
	if GetNewPar('ZZ_IS12COB', .T.)
		if (SB1->(Alltrim(B1_POSIPI)) == '74130000') .And. (SB1->(B1_TIPO) $ 'PA') .And. (At(SA1->(A1_EST), 'SP')>0) .And. SA1->A1_SIMPNAC = "2"
			if cOper == 'SOL_COM_ST'
				cTes := GetNewPar('ZZ_TESST70', '976')
			elseif cOper == 'SOL_SEM_ST'
				cTes := GetNewPar('ZZ_TESST20', '925')
			elseif cOper == 'VENDA_NORMAL'
				cTes := GetNewPar('ZZ_TESST20', '925')
			endif
		endif
	endif
return(cTes)

user function zUfTemProtocol(cEst)
	local aArea    	  := GetArea()
	local aAreaCLO	  := CLO->(getArea())
	local lProtoc	  := .F.
	DbSelectArea("CLO")
	CLO->(DbSetOrder(1))
	if CLO->(DbSeek(cFilAnt+Padr(cEst,TamSx3('A1_EST')[1]),.F.))
		lProtoc := .T.
	else
		lProtoc := .F.
	endIf
	RestArea(aAreaCLO)
	RestArea(aArea)
return(lProtoc)

static function newSaiTes(cTpOper, cTipo, cCliFor, cLoja, cProd)
	local aArea     := getArea()
    local cTes      := ""
    local cTpCliFor := ""
    local oTes      := ctrlTesIntel():newctrlTesIntel()
    local nOpr    	:= 2
    local cFilter 	:= "3"
	default cTpOper := "01"
    default cTipo   := "N"
    default cCliFor := ""
    default cLoja   := ""
    default cProd   := ""
    

    cTpCliFor := If(cTipo$"DB","F","C")
    cTes := oTes:findTes(nOpr, cFilter,cTpOper, cCliFor, cLoja, cTpCliFor, AllTrim(cProd))
    FreeObj(oTes)
   
    RestArea(aArea)
return(cTes)
