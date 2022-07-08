#include "TOPCONN.ch"
#include "PROTHEUS.CH"
#include "RWMAKE.CH"

/*/{Protheus.doc} CdEst03
//TODO Montagem de Browse para efetuar o resumo da produção.
@author legado
@since 27/04/2006
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function CdEst03()
	Private _cNmArq1 	:= _cNmArq2 := "" // Arquivo Temporario
	Private _aCampos 	:= {}
	Private cPerg      	 := "CDET01"
	Private cMarca 		:= GetMark()
	Private lInverte		:= .T.
	Private ntamaCols 	:= 0
	Private aSolTrf		:= {} //Arra onde sera solicitada a transferencia do material

	My_MVPAR01 := " "
	My_MVPAR02 := " "
	My_MVPAR03 := " "
	My_MVPAR04 := " "
	My_MVPAR05 := " "
	My_MVPAR06 := " "
	My_MVPAR07 := " "
	My_MVPAR08 := " "
	My_MVPAR09 := " "
	My_MVPAR10 := " "
	My_MVPAR11 := " "
	My_MVPAR12 := " "

	aCampos := {}
	aAdd(_aCampos, {"OK"     , "C", 02, 0})       // Numero do Pedido de Venda
	aAdd(_aCampos, {"PEDIDO" , "C", TamSX3("C6_NUM")[1], 0})       // Numero do Pedido de Venda
	aAdd(_aCampos, {"VEND"   , "C", 10, 0})       // Nome do Vendedor
	aAdd(_aCampos, {"CLIENTE", "C", TamSX3("A1_COD")[1], 0})       // Numero do Pedido de Venda
	aAdd(_aCampos, {"LOJA"   , "C", TamSX3("A1_LOJA")[1], 0})       // Numero do Pedido de Venda
	aAdd(_aCampos, {"NOME"   , "C", 25, 0})       // Nome do Cliente
	aAdd(_aCampos, {"MUN"    , "C", 15, 0})       // Municipio do Cliente
	aAdd(_aCampos, {"EST"    , "C", 02, 0})       // Estado do Cliente
	aAdd(_aCampos, {"EMISSA" , "D", 08, 0})       // Data de Emissao do Pedido
	aAdd(_aCampos, {"DTLIB"  , "D", 08, 0})       // Data de Liberacao do Pedido
	aAdd(_aCampos, {"DIF"    , "N", 03, 0})       // Diferenca entre Liberacao e DataBase
	aAdd(_aCampos, {"ENTREG" , "D", 08, 0})       // Data de Entrega Prevista
	aAdd(_aCampos, {"TOTAL"  , "N", 15, 2})       // Valor Total do Pedido
	aAdd(_aCampos, {"LUCROB" , "N", 10, 2})       // % Lucro Bruto do Pedido
	aAdd(_aCampos, {"SEMANA" , "C", TamSX3("C6_SEMANA")[1], 2})       // % Lucro Bruto do Pedido
	aAdd(_aCampos, {"OBS"    , "C", 25, 0})       // Observacoes do Pedido
	aAdd(_aCampos, {"SETOR"  , "C", 01, 0})       // Setor (Revenda - Industria)

	If Select("TRB1") > 0
		DbSelectArea("TRB1")
		DbCloseArea()
	EndIf

	_cNmArq1 := CriaTrab(_aCampos, .T.)
	DbUseArea(.T.,, _cNmArq1, "TRB1", .F., .F.) // Abrir exclusivo

	Private _cInd1 := CriaTrab(Nil, .F.)
	IndRegua("TRB1", _cInd1, "SETOR+VEND+EST+MUN+NOME+PEDIDO",,, "Selecionando Registros...")
	Private _cInd2 := CriaTrab(Nil, .F.)
	IndRegua("TRB1", _cInd2, "PEDIDO",,, "Selecionando Registros...")
	DbClearIndex() // Fecha todos s arquivos de indices
	DbSetIndex(_cInd1 + OrdBagExt())
	DbSetIndex(_cInd2 + OrdBagExt())
	DbSetOrder(1)

	ValidPerg()
	_lRefre := .F.
	If !u_ParOP()
		DbSelectArea("TRB1")
		DbCloseArea("TRB1")
		Delete File (_cNmArq1 + ".DTC")
		Delete File (_cInd1 + OrdBagExt())
		Return(.T.)
	EndIf
	_lRefre := .T.

	aAdd(aCampos, {"OK"     ,, "Ok"})
	aAdd(aCampos, {"PEDIDO" ,, "Nro.Pedido"})           // Numero do Pedido de Venda
	aAdd(aCampos, {"VEND"   ,, "Vendedor"})             // Nome do Vendedor
	aAdd(aCampos, {"CLIENTE",, "Cliente"})              // Numero do Pedido de Venda
	aAdd(aCampos, {"LOJA"   ,, "Loja"})                 // Numero do Pedido de Venda
	aAdd(aCampos, {"NOME"   ,, "Nome Cliente"})         // Nome do Cliente
	aAdd(aCampos, {"MUN"    ,, "Cidade"})               // Municipio do Cliente
	aAdd(aCampos, {"EST"    ,, "UF"})                   // Estado do Cliente
	aAdd(aCampos, {"EMISSA" ,, "Dt.Emissao"})           // Data de Emissao do Pedido
	aAdd(aCampos, {"DTLIB"  ,, "Dt.Liber."})            // Data de Liberacao do Pedido
	aAdd(aCampos, {"DIF"    ,, "Dif.Liber."})           // Diferenca entre Liberacao e DataBase
	aAdd(aCampos, {"ENTREG" ,, "Dt.Entrega"})           // Data de Entrega Prevista
	aAdd(aCampos, {"TOTAL"  ,, "Total Pedido","@E 99,999,999.99"})       // Valor Total do Pedido
	aAdd(aCampos, {"LUCROB" ,, "LB","@E 999.999"})      // % Lucro Bruto do Pedido
	aAdd(aCampos, {"SEMANA" ,, "Semana Progr."})
	aAdd(aCampos, {"OBS"    ,, "Obs"})                  // Observacoes do Pedido
	aAdd(aCampos, {"SETOR"  ,, "Setor","@! X"})        // Setor - Industria ou Revenda

	l_Confirma := .F.

	cCadastro:="Resumo da Produção - Sem.: " + Transform(My_MVPAR11,"@R 9999/99-9")

	aRotina := {{ "Parâmetros"   ,"u_ParOP()"		, 0 , 2},;
		{ "Muda Ordem"   ,"u_Muda()"		, 0 , 2},;
		{ "Confirma"     ,"u_ConfMar()"	, 0 , 2}}

	DbSelectArea("TRB1")
	DbGoTop()
	MarkBrow("TRB1","OK","TRB1->SEMANA",aCampos,lInverte,cMarca,"u_MarkAll()",,,,)

	If l_Confirma
		l_Confirma := .F.
		nUsado := 0
		aHeader := {}
		aCols   := {} // Colunas da grid de dados para tratar as quantidades
		// Estou tirando pedido e item do array principal para poder avaliar as previsões de
		// entrada e de saída.
		aCols_2 := {} // Elementos que contem o detalhamento doa pedidos envolvidos - Para este array teremos:
		// Produto / Local / Localiz / pedido / item / /quantidade

		DbSelectArea("SX3")
		DbSetOrder(2) // X3_CAMPO

		DbSeek("C6_PRODUTO",.F.)
		AADD(aHeader,{TRIM(X3_TITULO),"_C6PRODUTO" /*/X3_CAMPO/*/,X3_PICTURE       ,10 /*/X3_TAMANHO/*/          ,X3_DECIMAL,;
		"If(ExistCpo('SB1',M->_C6PRODUTO) .And. n > ntamaCols,u_VejaDes(),.F.)",;
			X3_USADO,X3_TIPO,X3_ARQUIVO } )

		DbSeek("C6_DESCRI",.F.)
		AADD(aHeader,{TRIM(X3_TITULO),"_C6DESCRI" /*/X3_CAMPO/*/,X3_PICTURE        ,35 /*/X3_TAMANHO/*/          ,X3_DECIMAL,".F."       ,X3_USADO,X3_TIPO,X3_ARQUIVO } )

		DbSeek("C6_LOCALIZ",.F.)
		AADD(aHeader,{TRIM(X3_TITULO),"_C6LOCALIZ"/*/X3_CAMPO/*/,X3_PICTURE       ,6 /*/X3_TAMANHO/*/          ,X3_DECIMAL,"n > ntamaCols .And. u_VldLclz()"       ,X3_USADO,X3_TIPO,X3_ARQUIVO } )

		// Usado como quantidade disponivel em estoque
		DbSeek("C6_PRCVEN",.F.)
		AADD(aHeader,{"Estoque"           ,"_C6PRCVEN"/*/X3_CAMPO/*/,"@E 99,999,999",8 /*/X3_TAMANHO/*/          ,0 /*/X3_DECIMAL/*/,".F."       ,X3_USADO,X3_TIPO,X3_ARQUIVO } )

		// // Usado como quantidade prevista de entrada
		DbSeek("C6_SLDALIB",.F.)
		AADD(aHeader,{"Prev.Entrada"      ,"_C6SLDALIB"/*/X3_CAMPO/*/,"@E 99,999,999",8 /*/X3_TAMANHO/*/          ,0 /*/X3_DECIMAL/*/,".F."       ,X3_USADO,X3_TIPO,X3_ARQUIVO } )

		// // Usado como quantidade prevista de saída
		DbSeek("C6_QTDRESE",.F.)
		AADD(aHeader,{"Prev.Saída"      ,"_C6QTDRESE"/*/X3_CAMPO/*/,"@E 99,999,999",8 /*/X3_TAMANHO/*/         ,0 /*/X3_DECIMAL/*/,".F."       ,X3_USADO,X3_TIPO,X3_ARQUIVO } )

		// Usado como quantidade em bobinas
		DbSeek("C6_QTDLIB2",.F.)
		AADD(aHeader,{"Estq.Bobinas" ,"_C6QTDLIB2"/*/X3_CAMPO/*/,"@E 9,999,999"   ,7 /*/X3_TAMANHO/*/         ,0 /*/X3_DECIMAL/*/,".F."       ,X3_USADO,X3_TIPO,X3_ARQUIVO } )

		DbSeek("C6_QTDLIB",.F.)
		AADD(aHeader,{"Qtd.a Produzir" ,"_C6QTDLIB"/*/X3_CAMPO/*/,"@E 99,999,999",8 /*/X3_TAMANHO/*/          ,0 /*/X3_DECIMAL/*/,"u_ValidQtd()",X3_USADO,X3_TIPO,X3_ARQUIVO } )

		DbSeek("C6_LANCES",.F.)
		AADD(aHeader,{TRIM(X3_TITULO),"_C6LANCES"/*/X3_CAMPO/*/,"@E 999,999"      ,6 /*/X3_TAMANHO/*/          ,X3_DECIMAL,".F."        ,X3_USADO,X3_TIPO,X3_ARQUIVO } )

		DbSeek("C6_METRAGE",.F.)
		AADD(aHeader,{TRIM(X3_TITULO),"_C6METRAGE"/*/X3_CAMPO/*/,"@E 999,999"     ,6 /*/X3_TAMANHO/*/        ,X3_DECIMAL,".F."        ,X3_USADO,X3_TIPO,X3_ARQUIVO } )

		DbSeek("C6_QTDVEN",.F.)
		AADD(aHeader,{TRIM(X3_TITULO),"_C6QTDVEN"/*/X3_CAMPO/*/,"@E 99,999,999",8 /*/X3_TAMANHO/*/          ,X3_DECIMAL,".F."       ,X3_USADO,X3_TIPO,X3_ARQUIVO } )

		DbSeek("C6_QTDENT",.F.)
		AADD(aHeader,{TRIM(X3_TITULO),"_C6QTDENT"/*/X3_CAMPO/*/,"@E 99,999,999",8 /*/X3_TAMANHO/*/          ,X3_DECIMAL,".F."       ,X3_USADO,X3_TIPO,X3_ARQUIVO } )

		DbSeek("C6_LOCAL",.F.)
		//	xVld := "n > ntamaCols"
		AADD(aHeader,{TRIM(X3_TITULO),"_C6LOCAL"/*/X3_CAMPO/*/,X3_PICTURE       ,X3_TAMANHO          ,X3_DECIMAL,".F."        ,X3_USADO,X3_TIPO,X3_ARQUIVO } )

		DbSeek("C6_ACONDIC",.F.)
		AADD(aHeader,{TRIM(X3_TITULO),"_C6ACONDIC"/*/X3_CAMPO/*/,X3_PICTURE       ,X3_TAMANHO          ,X3_DECIMAL,".F."        ,X3_USADO,X3_TIPO,X3_ARQUIVO } )

		DbSeek("C6_ENTREG",.F.)
		AADD(aHeader,{TRIM(X3_TITULO),"_C6ENTREG"/*/X3_CAMPO/*/,X3_PICTURE       ,X3_TAMANHO          ,X3_DECIMAL,".F."        ,X3_USADO,X3_TIPO,X3_ARQUIVO } )

		nUsado := Len(aHeader)
		_Qtd   := 0

		_nPosCod := GDFieldPos("_C6PRODUTO")
		_nPosLcz := GDFieldPos("_C6LOCALIZ")
		_nPosLca := GDFieldPos("_C6LOCAL")
		_nPosAcd := GDFieldPos("_C6ACONDIC")
		_nPosMtr := GDFieldPos("_C6METRAGE")

		Processa({|| MontaMrk()},"Aglutinando Dados dos Itens Dos Pedidos...")

		If Len(Acols) == 0
			Alert("Não há Pedidos a Serem Produzidos")
		Else
			aSort(aCols  ,,,{ |x, y| x[_nPosCod]+x[_nPosLcz] < y[_nPosCod]+y[_nPosLcz] })
			aSort(aCols_2,,,{ |x, y| x[1]+x[2]+x[3]+x[4]+x[5] < y[1]+y[2]+y[3]+y[4]+y[5] })
			// 1-Produto / 2-Local / 3-Localiz / 4-pedido / 5-item / /6-quantidade

			Processa({|| MontaAcl()},"Verificando Saldos em Estoque...")

			DbSelectArea("TRB1")
			ntamaCols := Len(aCols)
			@ 150,001 TO 650,950 DIALOG oDlg2 TITLE "Resumo da Produção - Semana " + My_MVPAR11 + " - Produtos"
			@ 006,005 TO 220,470  MULTILINE MODIFY DELETE OBJECT oMultiline VALID u_Line3Ok(ntamaCols)
			@ 230,390 BMPBUTTON TYPE 01 ACTION Cria_oDlg2() // Ok
			@ 230,430 BMPBUTTON TYPE 02 ACTION Close(oDlg2) // Cancela
			omultiline:nmax:=999 ///ntamaCols
			ACTIVATE DIALOG oDlg2 CENTERED
			If l_Confirma
				Processa({|| GravaSem()},"Marcando Registros Selecionados...")
				Processa({|| CriaZ9()},"Gravando Tabela de Complemento de O.P. ...")
				Processa({|| CriaOP()},"Criando Ordens de Produção...")

				If 	Len(aSolTrf) > 0
					Processa({|| U_fAnTrFil(aSolTrf)},"Analisando Itens que não são produzidos na Filial ... ")
				EndIf
			EndIf
		EndIf
	EndIf
	DbSelectArea("TRB1")
	DbCloseArea("TRB1")
	Delete File (_cNmArq1 + ".DTC")
	Delete File (_cInd1 + OrdBagExt())
	Delete File (_cInd2 + OrdBagExt())
Return(.T.)


/*/{Protheus.doc} CriaZ9
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0

@type function
/*/
Static Function CriaZ9()
	//	aCols_2 := {} // Elementos que contem o detalhamento doa pedidos envolvidos - Para este array teremos:
	// Produto / local / Localiz / pedido / item / /quantidade

	DbSelectArea("SZ9")
	DbSetOrder(1) // Z9_FILIAL+Z9_SEMANA+Z9_PRODUTO+Z9_LOCAL+Z9_LOCALIZ+Z9_PEDIDO+Z9_ITEMPV
	ProcRegua(Len(aCols))
	For _i := 1 To Len(aCols)
		IncProc()
		If !aCols[_i,Len(aCols[_i])] // .And. GDFieldGet("_C6QTDLIB",_i) > 0
			// Verifico se tem essa linha no aCols_2
			//	aCols_2 := {} // Elementos que contem o detalhamento doa pedidos envolvidos - Para este array teremos:
			// Produto / Local / Localiz / pedido / item / /quantidade
			_Pos2 := aScan(aCols_2,{|x| x[1]+x[2]+x[3] == ;
				GDFieldGet("_C6PRODUTO",_i)+GDFieldGet("_C6LOCAL",_i)+GDFieldGet("_C6LOCALIZ",_i)})

			If _Pos2 == 0 // Não tem o cara no aCols_2
				If GDFieldGet("_C6QTDLIB",_i) > 0 // Tenho algo a produzir /

					// Como não tem elemento no aCols_2, essa produção é considerada para estoque, onde não tenho
					// numero de pedido nem item, então dou o DbSeek sem esses elementos
					// If !DbSeek(xFilial("SZ9")+My_MVPAR11+GDFieldGet("_C6PRODUTO",_i)+GDFieldGet("_C6LOCAL",_i)+;
						//     GDFieldGet("_C6LOCALIZ",_i)+GDFieldGet("_C6NUM",_i)+GDFieldGet("_C6ITEM",_i),.F.)

					// 03/05/16 -- Corrigir o DbSeek considerando PEDIDO e ITEM vazios, senão ele acha coisa errada
					//If !DbSeek(xFilial("SZ9")+My_MVPAR11+GDFieldGet("_C6PRODUTO",_i)+GDFieldGet("_C6LOCAL",_i)+GDFieldGet("_C6LOCALIZ",_i),.F.)
					If !DbSeek(xFilial("SZ9")+My_MVPAR11+GDFieldGet("_C6PRODUTO",_i)+GDFieldGet("_C6LOCAL",_i)+;
							GDFieldGet("_C6LOCALIZ",_i)+PadR(" ",TamSX3("C6_NUM")[1])+PadR(" ",TamSX3("C6_ITEM")[1]),.F.)
						RecLock("SZ9",.T.)
						SZ9->Z9_FILIAL	:= xFilial("SZ9")
						SZ9->Z9_SEMANA	:= My_MVPAR11
						SZ9->Z9_PRODUTO := GDFieldGet("_C6PRODUTO",_i)
						SZ9->Z9_DESCRI	:= Posicione("SB1",1,xFilial("SB1")+GDFieldGet("_C6PRODUTO",_i),"B1_DESC")
						SZ9->Z9_LOCAL	:= GDFieldGet("_C6LOCAL",_i)
						SZ9->Z9_LOCALIZ	:= GDFieldGet("_C6LOCALIZ",_i)
						SZ9->Z9_ACONDIC	:= GDFieldGet("_C6ACONDIC",_i)
						SZ9->Z9_METRAGE := GDFieldGet("_C6METRAGE",_i)
						//SZ9->Z9_PEDIDO  := GDFieldGet("_C6NUM",_i)
						//SZ9->Z9_ITEMPV  := GDFieldGet("_C6ITEM",_i)
						SZ9->Z9_CODINV  := 	Left(SZ9->Z9_PRODUTO,5)+Substr(SZ9->Z9_PRODUTO,8,3)+Substr(SZ9->Z9_PRODUTO,6,2)
						_Qtd++
					Else
						RecLock("SZ9",.F.)
					EndIf
					SZ9->Z9_LANCES	:= SZ9->Z9_LANCES + GDFieldGet("_C6LANCES",_i)
					SZ9->Z9_QUANT	:= SZ9->Z9_QUANT  + GDFieldGet("_C6QTDLIB",_i)
					SZ9->Z9_SALDO	:= SZ9->Z9_SALDO  + GDFieldGet("_C6QTDLIB",_i)
					SZ9->Z9_ENCERR  := 0
					MsUnLock()
				EndIf
			Else // Tem no aCols_2
				_QtdPrd := GDFieldGet("_C6QTDLIB",_i)
				For _nCl2 := 1 to Len(aCols_2)
					//	aCols_2 := {} // Elementos que contem o detalhamento dos pedidos envolvidos
					// Para este array teremos:
					// Produto / local / Localiz / pedido / item / /quantidade
					If aCols_2[_nCl2,1]+aCols_2[_nCl2,2]+aCols_2[_nCl2,3] == ;
							GDFieldGet("_C6PRODUTO",_i)+GDFieldGet("_C6LOCAL",_i)+GDFieldGet("_C6LOCALIZ",_i)

						_nPrdNow := Min(aCols_2[_nCl2,6],_QtdPrd)
						_nLcs := (_nPrdNow / GDFieldGet("_C6METRAGE",_i))
						If _nLcs > Int(_nLcs)
							_nLcs++
							_nPrdNow := (_nLcs * GDFieldGet("_C6METRAGE",_i))
						EndIf
						_QtdPrd := Max((_QtdPrd-_nPrdNow),0)

						//DbSelectArea("SZ9")
						//DbSetOrder(1) // Z9_FILIAL+Z9_SEMANA+Z9_PRODUTO+Z9_LOCAL+Z9_LOCALIZ+Z9_PEDIDO+Z9_ITEMPV
						If !DbSeek(xFilial("SZ9")+My_MVPAR11+aCols_2[_nCl2,1]+aCols_2[_nCl2,2]+aCols_2[_nCl2,3]+aCols_2[_nCl2,4]+aCols_2[_nCl2,5],.F.)
							RecLock("SZ9",.T.)
							SZ9->Z9_FILIAL	:= xFilial("SZ9")
							SZ9->Z9_SEMANA	:= My_MVPAR11
							SZ9->Z9_PRODUTO := GDFieldGet("_C6PRODUTO",_i)
							SZ9->Z9_DESCRI	:= Posicione("SB1",1,xFilial("SB1")+GDFieldGet("_C6PRODUTO",_i),"B1_DESC")
							SZ9->Z9_LOCAL	:= GDFieldGet("_C6LOCAL",_i)
							SZ9->Z9_LOCALIZ	:= GDFieldGet("_C6LOCALIZ",_i)
							SZ9->Z9_ACONDIC	:= GDFieldGet("_C6ACONDIC",_i)
							SZ9->Z9_METRAGE := GDFieldGet("_C6METRAGE",_i)
							SZ9->Z9_PEDIDO  := aCols_2[_nCl2,4]
							SZ9->Z9_ITEMPV  := aCols_2[_nCl2,5]
							SZ9->Z9_CODINV  := Left(SZ9->Z9_PRODUTO,5)+Substr(SZ9->Z9_PRODUTO,8,3)+Substr(SZ9->Z9_PRODUTO,6,2)
							_dDtEntr := Posicione("SC6",1,xFilial("SC6")+SZ9->Z9_PEDIDO+SZ9->Z9_ITEMPV,"C6_ENTREG") - 1 // Informar 1 dia útil antes da data de entrega
							Do While DataValida(_dDtEntr) > _dDtEntr
								_dDtEntr--
							EndDo
							SZ9->Z9_DTENTR	:= _dDtEntr
							_Qtd++
						Else
							RecLock("SZ9",.F.)
						EndIf
						SZ9->Z9_LANCES	:= SZ9->Z9_LANCES + _nLcs
						SZ9->Z9_QUANT	:= SZ9->Z9_QUANT  + _nPrdNow
						SZ9->Z9_SALDO	:= SZ9->Z9_QUANT
						SZ9->Z9_ENCERR  := 0
						MsUnLock()
					EndIf
				Next
			EndIf
		EndIf
	Next
Return(.T.)


/*/{Protheus.doc} CriaOP
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function CriaOP()
	Local aVetor
	//Public _cSemOP := My_MVPAR11
	Private _cSemOP := My_MVPAR11

	DbSelectArea("SC2")
	DbSetOrder(1)// C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
	_cSemana := My_MVPAR11 // A variavel My_MVPAR?? muda o conteúdo pela MSExecAuto()
	_NumOP := Left(_cSemana,6)
	_Item := "00"
	DbSelectArea("SZ9")
	DbSetOrder(1) // Z9_FILIAL+Z9_SEMANA+Z9_PRODUTO+Z9_LOCAL+Z9_LOCALIZ+Z9_PEDIDO+Z9_ITEMPV
	ProcRegua(_Qtd)


	// Conforme reuniões, para implantação do corte no Protheus/PcFactory/PreActor, as OPs de PA's serão quebradas
	// por: Rolos de 100 metros, Bobinas e os demais acondicionamentos.

	DbSeek(xFilial("SZ9")+_cSemana,.F.)
	Do While SZ9->Z9_FILIAL == xFilial("SZ9") .And. SZ9->Z9_SEMANA == _cSemana .And. SZ9->(!Eof())
		If !Empty(SZ9->Z9_NUM+SZ9->Z9_ITEM)
			SC2->(DbSetOrder(1))
			If !SC2->(DbSeek(xFilial("SC2")+SZ9->Z9_NUM+SZ9->Z9_ITEM+SZ9->Z9_SEQUEN,.F.))
				RecLock("SZ9",.F.)
				SZ9->Z9_NUM		:= "      "
				SZ9->Z9_ITEM	:= "  "
				SZ9->Z9_SEQUEN	:= "   "
				SZ9->Z9_EMISSAO	:= Ctod("")
				MsUnLock()
			EndIf
		EndIf
		SZ9->(DbSkip())
	EndDo

	DbSeek(xFilial("SZ9")+_cSemana,.F.)
	Do While SZ9->Z9_FILIAL == xFilial("SZ9") .And. SZ9->Z9_SEMANA == _cSemana .And. SZ9->(!Eof())
		_Chave    := SZ9->Z9_FILIAL+SZ9->Z9_SEMANA
		_cProd    := SZ9->Z9_PRODUTO
		_cAlmo    := SZ9->Z9_LOCAL

		_aQtdOP   := {} // Define o Item,Quantidade, Menor data de entrega -
		Aadd(_aQtdOP,{"  ",0.00,CtoD("31/12/2049"),"Rolos 100 metros"}) // 1-Rolos de 100 metros
		Aadd(_aQtdOP,{"  ",0.00,CtoD("31/12/2049"),"Bobinas Diversas"}) // 2-Bobinas
		Aadd(_aQtdOP,{"  ",0.00,CtoD("31/12/2049"),"Carreteis"})		// 3-Carretéis
		Aadd(_aQtdOP,{"  ",0.00,CtoD("31/12/2049"),"Demais Acondics."}) // 4-Demais Acondicionamentos
		// Atenção: As expressões do elemento 4 do _aQtdOP não podem ser alteradas pois são interpretadas na
		// User Function PPI_OP()

		_nSomaSZ9 := 0
		_cItemArr := "  " // Controla os ítens
		Do While SZ9->Z9_FILIAL+SZ9->Z9_SEMANA == _Chave .And. SZ9->Z9_PRODUTO == _cProd .And.;
				SZ9->Z9_LOCAL == _cAlmo .And. SZ9->(!Eof())

			If Empty(SZ9->Z9_NUM)
				If Left(SZ9->Z9_LOCALIZ,6)=="R00100"	// Rolos de 100 metros
					_nArray := 1
				ElseIf Left(SZ9->Z9_LOCALIZ,1) == "B"	// Bobinas
					_nArray := 2
				ElseIf Left(SZ9->Z9_LOCALIZ,1) $ "CM"	// Carretéis
					_nArray := 3
				Else 									// Demais Acondicionamentos
					_nArray := 4
				EndIf

				If Empty(_aQtdOP[_nArray,1]) .And. SZ9->Z9_QUANT > 0.00
					// Não tem Item p/OP de Rolos de 100 ou p/OP de Bobinas ou p/OP dos demais acondicionamentos
					If !Empty(_cItemArr)
						_Item := Soma1(_cItemArr,,.F.) // .F. Indica que não serão inclusas as minusculas.
					EndIf
					Do While SC2->(DbSeek(xFilial("SC2")+_NumOP+_Item,.F.)) .Or. "OS" $ Upper(_Item) // Conforme Juliana quando tem OS no item da op
						// o sistema entende que se trata de manutenção de ativo.
						_Item := Soma1(_Item,,.F.) // .F. Indica que não serão inclusas as minusculas.
					EndDo
					_aQtdOP[_nArray,1] 	:= _Item
					_cItemArr 			:= _Item
				EndIf

				RecLock("SZ9",.F.)
				SZ9->Z9_NUM		:= If(SZ9->Z9_QUANT > 0.00,_NumOP,"000000")
				SZ9->Z9_ITEM	:= If(SZ9->Z9_QUANT > 0.00,_aQtdOP[_nArray,1],"00")
				SZ9->Z9_SEQUEN	:= "001"
				SZ9->Z9_EMISSAO	:= dDataBase
				MsUnLock()
				If SZ9->Z9_QUANT > 0.00
					_aQtdOP[_nArray,2] += SZ9->Z9_QUANT
					_aQtdOP[_nArray,3] := Min(_aQtdOP[_nArray,3],If(!Empty(SZ9->Z9_DTENTR),SZ9->Z9_DTENTR,Date()+3))
				EndIf
			EndIf
			SZ9->(DbSkip())
		EndDo

		For _nArray := 1 to Len(_aQtdOP)
			If Empty(_aQtdOP[_nArray,1]) .Or. _aQtdOP[_nArray,2] == 0
				Loop
			Endif
			_Item  := _aQtdOP[_nArray,1]
			_nQtd  := _aQtdOP[_nArray,2]
			_dDtOp := ddatabase
			_Obs := "  "
			SG1->(DbSetOrder(1))
			If SG1->(DbSeek(xFilial("SG1")+_cProd,.F.))

				// Para adequação ao novo formato definido hj 26/10/10, as OPs intermediárias não serão
				// criadas neste momento mas sim na montagem da PROGRAMAÇÃO DA PRODUÇÃO, por isso o segundo
				// parâmetro da u_função NOVAOP  está .F.

				_cSeq   := "001"
				u_NovaOP("I",.F.,_aQtdOP[_nArray,3]," ")  // Parâmetros: I=Incluir OP / E Excluir OP // .T.= Criar /.F. = Não criar OPs intermediárias / Data de entrega
				SC2->(DbSetOrder(1))
				If SC2->(DbSeek(xFilial("SC2")+_NumOP+_Item+"001",.F.))
					RecLock("SC2",.F.)
					SC2->C2_OBS := _aQtdOP[_nArray,4]
					MsUnLock()
				EndIf
			EndIf
		Next
		DbSelectArea("SZ9")
	EndDo

	My_MVPAR11 := _cSemOP
	//Release _cSemOP // Não sei se este comando funciona
Return(.T.)


/*/{Protheus.doc} GravaSem
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function GravaSem()
	DbSelectArea("SC5")
	DbSetOrder(1)  //C5_FILIAL+C5_NUM

	DbSelectArea("SC6")
	DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO

	DbSelectArea("TRB1")
	ProcRegua(RecCount())
	TRB1->(DbGoTop())
	Do While TRB1->(!Eof())
		IncProc()
		If TRB1->OK == "XX" // Foi selecionado
			DbSelectArea("SC5")
			If DbSeek(xFilial("SC5")+TRB1->PEDIDO,.F.)
				If Empty(SC5->C5_SEMANA) .Or. SC5->C5_SEMANA == Replicate("X",Len(SC5->C5_SEMANA))
					RecLock("SC5",.F.)
					SC5->C5_SEMANA := My_MVPAR11
					MsUnLock()
				EndIf
			EndIf
			DbSelectArea("SC6")
			DbSeek(xFilial("SC6")+TRB1->PEDIDO,.F.)
			Do While SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+TRB1->PEDIDO .And. SC6->(!Eof())
				If Empty(SC6->C6_SEMANA) .Or. AllTrim(SC6->C6_SEMANA) $ "RESERVA//ZP4//r"
					RecLock("SC6",.F.)
					If SC6->C6_ACONDIC == "T" // Não produz retalhos
						SC6->C6_SEMANA := "00"
					ElseIf Left(SC6->C6_SEMANA,1) == "r"
						SC6->C6_SEMANA := Upper(SC6->C6_SEMANA)
						SC6->C6_DTRESUM := dDataBase
					Else
						SC6->C6_SEMANA := My_MVPAR11
						SC6->C6_DTRESUM := dDataBase
					EndIf
					MsUnLock()
				EndIf
				SC6->(DbSkip())
			EndDo
		Else
			DbSelectArea("SC5")
			If DbSeek(xFilial("SC5")+TRB1->PEDIDO,.F.)
				If SC5->C5_SEMANA == Replicate("X",Len(SC5->C5_SEMANA))
					RecLock("SC5",.F.)
					SC5->C5_SEMANA := Space(Len(SC5->C5_SEMANA))
					MsUnLock()
				EndIf
			EndIf
		EndIf
		TRB1->(DbSkip())
	EndDo
Return(.T.)


/*/{Protheus.doc} Cria_oDlg2
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function Cria_oDlg2()
	l_Confirma := .T.
	Close(oDlg2)
Return(.T.)


/*/{Protheus.doc} MontaAcl
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MontaAcl() // OK
	DbSelectArea("ZAI")
	DbSetOrder(1)

	DbSelectArea("SZE")
	DbSetOrder(5) // ZE_FILIAL+ZE_PRODUTO+STR(ZE_QUANT,5)

	SB1->(DbSetOrder(1))// B1_FILIAL+B1_COD
	SB2->(DbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL

	DbSelectArea("SBF")
	DbSetOrder(1)  //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	ProcRegua(Len(aCols))
	For _i := 1 to Len(aCols)
		IncProc()

		_cB1_COD := GDFieldGet("_C6PRODUTO",_i)
		SB1->(DbSeek(xFilial("SB1")+_cB1_COD,.F.))
		_nSd := 0.00
		_nPrvEnt := 0
		_nPrvSai := 0

		// A Variável _cLocaliz tem que ser definida independente se o produto controla ou não localização
		// senão dá pau na gravação do SZ9.
		_cLocaliz := Left(GDFieldGet("_C6ACONDIC",_i)+StrZero(GDFieldGet("_C6METRAGE",_i),5)+Space(Len(SBF->BF_LOCALIZ)),Len(SBF->BF_LOCALIZ))

		If SB1->B1_LOCALIZ == "S"
			// OBS PCPFAST AQUI SE FOR CURVA VER A QUANTIDADE QUE DEVE FICAR EM ESTOQUE

			If (GDFieldGet("_C6ACONDIC",_i) == "L" .Or. AllTrim(_cLocaliz) $ "R00100//R00050//R00015" .Or. ;
					(Left(_cB1_COD,5) == "11601" .And. "R00500" $ _cLocaliz) .Or.;
					AllTrim(_cLocaliz) $ ("C" + StrZero(SB1->B1_CARRETE,5) + "//M" + StrZero(SB1->B1_CARMAD,5))) .Or.;
					ZAI->(DbSeek(xFilial("ZAI")+_cB1_COD+_cLocaliz,.F.))

				// Estes são acondicionamentos padrão, então vejo o seus saldos no SBF
				If	SBF->(DbSeek(xFilial("SBF")+GDFieldGet("_C6LOCAL" ,_i)+_cLocaliz+_cB1_COD,.F.))
					_nSd := If(SBF->BF_EMPENHO>=0,(SBF->BF_QUANT - SBF->BF_EMPENHO),0)
				EndIf

				// Verificar as previsões de entrada
				//
				_cQuery := "SELECT Sum(Z9_SALDO) SLDZ9 "
				_cQuery += "FROM "+RetSqlName("SZ9")+" "
				_cQuery += "WHERE Z9_FILIAL  = '" + xFilial("SZ9") + "'AND D_E_L_E_T_<>'*' AND "
				_cQuery += "Z9_PRODUTO = '" + _cB1_COD + "'AND Z9_LOCALIZ = '" + _cLocaliz + "' AND "
				_cQuery += "Z9_PROGR <> '      ' AND Z9_ENCERR = 0 AND Z9_SALDO > 0"

				_cQuery := ChangeQuery(_cQuery)

				If Select("TRBQry") > 0
					DbSelectArea("TRBQry")
					DbCloseArea("TRBQry")
				EndIf

				TCQUERY _cQuery NEW ALIAS "TRBQry"

				DbSelectArea("TRBQry")
				TRBQry->(DbGoTop())
				If TRBQry->(!Eof())
					_nPrvEnt := TRBQry->SLDZ9
				Else
					_nPrvEnt := 0
				EndIf
				If Select("TRBQry") > 0
					DbSelectArea("TRBQry")
					DbCloseArea("TRBQry")
				EndIf

				// Verificar as previsões de saídas
				// Pedidos com movimentação de estoque ainda bloqueado estoque e que
				// já estejam programados

				_cQuery := "SELECT Sum(C9.C9_QTDLIB) SLDC9 "
				_cQuery += " FROM " + RetSqlName("SC9") + " C9 "
				_cQuery += "INNER JOIN " + RetSqlName("SC6") + " AS C6 ON C9.C9_FILIAL = C6.C6_FILIAL AND C9.C9_PEDIDO = C6.C6_NUM AND C9.C9_ITEM = C6.C6_ITEM "
				_cQuery += "INNER JOIN " + RetSqlName("SC2") + " AS C2 ON C9.C9_FILIAL = C2.C2_FILIAL AND C9.C9_PRODUTO = C2.C2_PRODUTO AND C6.C6_SEMANA = C2.C2_SEMANA "
				_cQuery += "INNER JOIN " + RetSqlName("SF4") + " AS F4 ON '" + xFilial("SF4") + "' = F4.F4_FILIAL AND F4.F4_CODIGO = C6.C6_TES "
				_cQuery += "WHERE "
				_cQuery += "C9.C9_BLCRED = '  ' AND C9.C9_BLEST = '02' AND C9.D_E_L_E_T_ <> '*' AND "
				_cQuery += "C6.C6_SEMANA <> '       '  AND C6.D_E_L_E_T_ <> '*' AND "
				_cQuery += "C6.C6_PRODUTO = '" + GDFieldGet("_C6PRODUTO",_i) + "' AND "
				_cQuery += "C6.C6_ACONDIC = '" + GDFieldGet("_C6ACONDIC",_i) + "' AND "
				_cQuery += "C6.C6_METRAGE = " + AllTrim(Str(GDFieldGet("_C6METRAGE",_i))) + " AND "
				_cQuery += "C2.C2_PROGR <> '      ' AND C2.D_E_L_E_T_ <> '*' AND "
				_cQuery += "F4.F4_ESTOQUE = 'S' AND F4.D_E_L_E_T_ <> '*'"

				_cQuery := ChangeQuery(_cQuery)

				If Select("TRBQry") > 0
					DbSelectArea("TRBQry")
					DbCloseArea("TRBQry")
				EndIf

				TCQUERY _cQuery NEW ALIAS "TRBQry"

				DbSelectArea("TRBQry")
				TRBQry->(DbGoTop())
				If TRBQry->(!Eof())
					_nPrvSai := TRBQry->SLDC9
				Else
					_nPrvSai := 0
				EndIf
				If Select("TRBQry") > 0
					DbSelectArea("TRBQry")
					DbCloseArea("TRBQry")
				EndIf
			EndIf
		Else
			If SB2->(DbSeek(xFilial("SB2")+_cB1_COD+GDFieldGet("_C6LOCAL" ,_i),.F.))
				_nSd := (SB2->B2_QATU + SB2->B2_SALPEDI) - SB2->B2_QEMP
			EndIf

			// Verificar as previsões de entrada
			//
			_nPrvEnt := 0 //???


			// Verificar as previsões de saídas
			// Pedidos com movimentação de estoque ainda bloqueado estoque e que
			// já estejam programados
			_nPrvSai := 0 //???
		EndIf

		// Busca se tem bobina em estoque com lance maior ou igual ao do pedido de venda
		cQUERY := "SELECT SUM(ZE_QUANT) AS QTD_ZE "
		cQUERY += " FROM "+RetSqlName("SZE")
		cQUERY += " WHERE  ZE_FILIAL = '"+xFilial("SZE")+"' AND ZE_PRODUTO = '" + _cB1_COD + "'"
		cQUERY += " AND ZE_QUANT >= " + Str(GDFieldGet("_C6METRAGE",_i),12,2) + " AND ZE_STATUS = 'T' AND D_E_L_E_T_ <> '*'"
		cQUERY += " GROUP BY ZE_PRODUTO	"

		TCQUERY cQuery NEW ALIAS "RSZE"

		dbSelectArea("RSZE")
		dbGoTop()
		_QtdBob := RSZE->QTD_ZE
		DbCloseArea("RSZE")
		GDFieldPut("_C6QTDLIB2",_QtdBob,_i)

		// Verificar as previsões de entrada
		//
		GDFieldPut("_C6SLDALIB",_nPrvEnt,_i)


		// Verificar as previsões de saídas
		// Pedidos com movimentação de estoque ainda bloqueado estoque e que
		// já estejam programados
		GDFieldPut("_C6QTDRESE",_nPrvSai,_i)

		//              Formula: Qtd.Vendida      - Qtd.Entregue               - Qtd.Estoque - Prev.Entrada + Prev.Saída
		_nAProd := Max((GDFieldGet("_C6QTDVEN",_i)- GDFieldGet("_C6QTDENT",_i) - _nSd        - _nPrvEnt     + _nPrvSai),0)

		DbSelectArea("ZAI")
		DbSetOrder(1)
		If DbSeek(xFilial("ZAI")+Alltrim(_cB1_COD)+_cLocaliz,.F.)
			nB1_LM 			:= ZAI->ZAI_LTMINI	// (Lote Mínimo)
			nB1_ESTSEG		:= ZAI->ZAI_ESTSEG 	// (Estoque Segurança)
			nB1_LE 			:= ZAI->ZAI_LTECON	// (Lote Econômico)
			nB1_PPedid		:= ZAI->ZAI_PPEDID	// (Ponto Pedido)
			_nMLE			:= 0
			_nMLM			:= 0

			If (_nAProd <= nB1_ESTSEG) .and. (_nSd < nB1_ESTSEG)
				_nAProd := nB1_ESTSEG - _nSd
			EndIf

			If _nAProd <> 0
				_nMLE		:= nB1_LE * (Round(_nAProd / nB1_LE,0))
				If  _nAProd > _nMLE
					_nMLM	:= Round(((_nAProd - _nMLE) / nB1_LM),0)
					_nMLM  := IIf(_nMLM <= 0, 1, _nMLM)
					_nMLM	:= nB1_LM * _nMLM
				EndIf
				_nAProd := _nMLE + _nMLM
			EndIf
		EndIf

		_nLaces := _nAProd / GDFieldGet("_C6METRAGE",_i)
		_nLaces := If(_nLaces > Int(_nLaces),Int(_nLaces)+1,Int(_nLaces))
		_nAProd := _nLaces * GDFieldGet("_C6METRAGE",_i)

		GDFieldPut("_C6PRCVEN",_nSd,_i)
		GDFieldPut("_C6LANCES",_nLaces,_i)
		GDFieldPut("_C6QTDLIB",_nAProd,_i)
	Next
Return(.T.)


/*/{Protheus.doc} MontaMrk
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MontaMrk() // OK
	Local _lnFabr		:= .F. //Assumo que o produto é fabricado na filial corrente
	Local _cDescB1		:= ""
	Local _cUMB1		:= ""
	local cTpOper		:= ""
	local nQtdTrf		:= 0

	DbSelectArea("SG1")
	DbSetOrder(1)

	DbSelectArea("SF4")
	DbSetOrder(1)

	DbSelectArea("TRB1")
	ProcRegua(RecCount())
	TRB1->(DbGoTop())
	Do While TRB1->(!Eof())
		IncProc()
		If TRB1->OK == "XX" // Foi selecionado
			DbSelectArea("SC6")
			DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
			DbSeek(xFilial("SC6")+TRB1->PEDIDO,.F.)
			Do While SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+TRB1->PEDIDO .And. SC6->(!Eof())
				// Verifica se o produto não é fabricado na filial corrente.
				// Se não for, não inclui no resumo

				_lInclui := .T.
				If SC6->C6_ACONDIC == "T"			// Não se produz retalhos nem o que já tem bobina empenhada
					_lInclui := .F.
				ElseIf ( AllTrim(SC6->C6_SEMANA) == "RESERVA//ZP4//r" ) .And. ;
						SC6->C6_QTDRES >= SC6->C6_QTDVEN
					_lInclui := .F.
				ElseIf !Empty(SC6->C6_SEMANA) .And. !(AllTrim(SC6->C6_SEMANA) $ "RESERVA//ZP4//r")
					_lInclui := .F.
				Else
					DbSelectArea("SF4")
					DbSeek(xFilial("SF4")+SC6->C6_TES,.F.)
					_lInclui := (SF4->F4_ESTOQUE == "S")
					DbSelectArea("SC6")
					//Transferencia de itens
					If SC6->C6_TES == "842"
						_lInclui := .F.
					Endif
				EndIf

				If !_lInclui
					SC6->(DbSkip())
					Loop
				EndIf

				// Inicio da montagem do array contendo itens a solicitar transferencia para a filial
				If FWCodEmp()+FWCodFil() == "0101" /// Cobrecom Matriz
					_lnFabr := u_NTemItu(SC6->C6_PRODUTO) // Esta função retorna se o produto NÃO é fabricado
					cTpOper := '09' //Itu pede 09-Tranferência para TL
				ElseIf FWCodEmp()+FWCodFil() == "0102" /// Cobrecom 3 Lagoas
					_lnFabr := !u_Tem3Lag(SC6->C6_PRODUTO) // Esta função retorna se o produto É fabricado em 3L
					cTpOper := '11'//TL pede 11-Industrialização para Itú
				EndIf

				If _lnFabr // Produto não fabricado na unidade corrente
					nQtdTrf := checkLiber(SC6->C6_NUM, SC6->C6_ITEM)
					if nQtdTrf > 0
						_cDescB1 := Posicione("SB1",1,xFilial("SB1")+Alltrim(SC6->C6_PRODUTO),"B1_DESC")
						_cUMB1 := Posicione("SB1",1,xFilial("SB1")+Alltrim(SC6->C6_PRODUTO),"B1_UM")
						aAdd(aSolTrf,{SC6->C6_PRODUTO,;
							_cDescB1,;
							_cUMB1,;
							nQtdTrf,;
							SC6->C6_LOCAL,;
							SC6->(C6_ACONDIC+StrZero(C6_METRAGE,5)),;
							cTpOper,;
							SC6->C6_NUM,;
							SC6->C6_ITEM})
					endif
					SC6->(DbSkip())
					Loop
				EndIf


				DbSelectArea("SC9")
				SC9->(DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM,.F.))
				_nQtdEnt := 0.00
				Do While SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM == xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM .And. SC9->(!Eof())
					If SC9->C9_BLEST $ "  /10"
						_cTES := SC6->C6_TES
						If SC9->C9_BLEST == "10" // Faturado, usar o TES da nota fiscal
							DbSelectArea("SD2")
							DbSetOrder(3) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
							DbSeek(xFilial("SD2")+SC9->C9_NFISCAL+SC9->C9_SERIENF+SC9->C9_CLIENTE+SC9->C9_LOJA,.F.)
							Do While SD2->D2_FILIAL == xFilial("SD2")  .And. SD2->D2_DOC    == SC9->C9_NFISCAL  .And.;
									SD2->D2_SERIE  == SC9->C9_SERIENF .And. SD2->D2_CLIENTE == SC9->C9_CLIENTE .And.;
									SD2->D2_LOJA   == SC9->C9_LOJA    .And. SD2->(!Eof())
								IF SD2->D2_PEDIDO == SC9->C9_PEDIDO .And. SD2->D2_ITEMPV == SC9->C9_ITEM
									_cTES := SD2->D2_TES
									Exit
								EndIf
								SD2->(DbSkip())
							EndDo
						EndIf
						If Posicione("SF4",1,xFilial("SF4")+_cTES,"F4_ESTOQUE") == "S"
							_nQtdEnt += SC9->C9_QTDLIB
						EndIf
					EndIf
					SC9->(DbSkip())
				EndDo

				_Pos := aScan(aCols,{|x| x[_nPosCod]+x[_nPosLca]+x[_nPosAcd] == ;
					SC6->C6_PRODUTO+SC6->C6_LOCAL+SC6->C6_ACONDIC .And.;
					x[_nPosMtr] == SC6->C6_METRAGE})


				If _nQtdEnt == 0 // Se eu não tenho nada liberado, então a reserva é válida
					_nQtdEnt += SC6->C6_QTDRES
				EndIf

				If _Pos == 0
					// Verifica se existe estrutura para o produto
					SG1->(DbSetOrder(1))
					If !SG1->(DbSeek(xFilial("SG1")+SC6->C6_PRODUTO,.F.))
						MsgBox("O Produto " + AllTrim(SC6->C6_PRODUTO) + "do Pedido " + AllTrim(SC6->C6_NUM) + ;
							"não tem Estrutura - O.F. não será criada!!!", "Atenção !!!", "INFO")
					EndIf
					aAdd(aCols,Array(nUsado+1))

					_Pos := Len(aCols)

					GDFieldPut("_C6PRODUTO",SC6->C6_PRODUTO            ,_Pos)
					GDFieldPut("_C6DESCRI" ,SC6->C6_DESCRI             ,_Pos)
					GDFieldPut("_C6LOCAL"  ,SC6->C6_LOCAL              ,_Pos)
					GDFieldPut("_C6ACONDIC",SC6->C6_ACONDIC            ,_Pos)
					GDFieldPut("_C6METRAGE",SC6->C6_METRAGE            ,_Pos)
					GDFieldPut("_C6QTDVEN" ,SC6->C6_QTDVEN             ,_Pos)
					GDFieldPut("_C6QTDENT" ,_nQtdEnt                   ,_Pos)

					_cLocaliz := Left(GDFieldGet("_C6ACONDIC",_Pos)+StrZero(GDFieldGet("_C6METRAGE",_Pos),5)+Space(Len(SBF->BF_LOCALIZ)),Len(SBF->BF_LOCALIZ))
					GDFieldPut("_C6LOCALIZ",_cLocaliz,_Pos)
					// GDFieldPut("_C6LOCALIZ",Space(Len(SBF->BF_LOCALIZ)),_Pos)
					GDFieldPut("_C6PRCVEN" ,0.00                       ,_Pos) // Quantidade em estoque

					GDFieldPut("_C6QTDLIB2",0.00                       ,_Pos)
					GDFieldPut("_C6PRCVEN" ,0.00                       ,_Pos) // Quantidade em estoque
					GDFieldPut("_C6SLDALIB",0.00                       ,_Pos) // previsão de entrada
					GDFieldPut("_C6QTDRESE",0.00                       ,_Pos) // previsão de saída
					GDFieldPut("_C6ENTREG" ,Max(SC6->C6_ENTREG,Date()) ,_Pos) // Data de Entrega
					aCols[_Pos,Len(aCols[_Pos])] := .F.
				Else
					If (Empty(GDFieldGet("_C6ENTREG",_Pos)) .And. !Empty(SC6->C6_ENTREG)) .Or.;
							(!Empty(SC6->C6_ENTREG) .And. SC6->C6_ENTREG < GDFieldGet("_C6ENTREG",_Pos))
						GDFieldPut("_C6ENTREG" ,Max(SC6->C6_ENTREG,Date()),_Pos) // Data de Entrega
					EndIf
					GDFieldPut("_C6QTDVEN",GDFieldGet("_C6QTDVEN",_Pos)+SC6->C6_QTDVEN ,_Pos)
					GDFieldPut("_C6QTDENT",GDFieldGet("_C6QTDENT",_Pos)+_nQtdEnt  ,_Pos)
					_cLocaliz := Left(GDFieldGet("_C6LOCALIZ",_Pos)+Space(Len(SBF->BF_LOCALIZ)),Len(SBF->BF_LOCALIZ))
				EndIf

				_nLaces := (GDFieldGet("_C6QTDVEN",_Pos)-GDFieldGet("_C6QTDENT",_Pos)) / GDFieldGet("_C6METRAGE",_Pos)
				_nLaces := If(_nLaces > Int(_nLaces),Int(_nLaces)+1,Int(_nLaces))
				// Calcula a necessidade pelos pedidos de vendas

				GDFieldPut("_C6LANCES",_nLaces,_Pos)
				GDFieldPut("_C6QTDLIB",(GDFieldGet("_C6LANCES",_Pos)*GDFieldGet("_C6METRAGE",_Pos)),_Pos)

				If SC6->C6_ACONDIC # "R" .Or. SC6->C6_METRAGE # 100 .And. ;
						(SC6->C6_QTDVEN-_nQtdEnt) > 0 // Somente grava o nro do PV senão for rolo de 100 metros
					// By Roberto Oliveira - Parte nova -> Adiciona no aCols_2 se for lance específico

					//	aSort(aCols_2,,,{ |x, y| x[1]+x[2]+x[3] < y[1]+y[2]+y[3] })
					// 1-Produto / 2-Local / 3-Localiz / 4-pedido / 5-item / /6-quantidade

					_Pos2 := aScan(aCols_2,{|x| x[1]+x[2]+x[3]+x[4]+x[5] == ;
						SC6->C6_PRODUTO+SC6->C6_LOCAL+_cLocaliz+SC6->C6_NUM+SC6->C6_ITEM})
					If _Pos2 == 0
						Aadd(aCols_2,{SC6->C6_PRODUTO,SC6->C6_LOCAL,_cLocaliz,SC6->C6_NUM,SC6->C6_ITEM,0})
						_Pos2 := Len(aCols_2)
					EndIf
					aCols_2[_Pos2,6] += (SC6->C6_QTDVEN-_nQtdEnt)
				EndIf
				SC6->(DbSkip())
			EndDo
		EndIf
		TRB1->(DbSkip())
	EndDo
Return(.T.)


/*/{Protheus.doc} ConfMar
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function ConfMar() //OK
	// A função Marked não funciona se fechar a janela (oDLG1)
	// por isso vou marcar com "XX" par que possa ser "vista" depois.
	DbSelectArea("TRB1")
	DbSetOrder(1)
	ProcRegua(RecCount())
	TRB1->(DbGoTop())
	Do While TRB1->(!Eof())
		IncProc()
		_Mck := If(Marked("OK").And.Empty(SEMANA),"XX","  ")
		RecLock("TRB1",.F.)
		TRB1->OK := _Mck
		MsUnLock()
		TRB1->(DbSkip())
	EndDo
	l_Confirma := .T.
	CloseBrowse()
	//Close(oDlg1)
Return(.T.)


/*/{Protheus.doc} ValidPerg
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function ValidPerg   //ok
	_aArea := GetArea()

	DbSelectArea("SX1")
	DbSetOrder(1)
	cPerg := PadR(cPerg,Len(SX1->X1_GRUPO))

	aRegs:={}
	//          Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05/F3/Picture
	aAdd(aRegs,{cPerg,"01","Do Pedido                 ?","mv_ch1","C",06,0,0,"G","","mv_par01","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Até o Pedido              ?","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Da Data de Entrega        ?","mv_ch3","D",08,0,0,"G","","mv_par03","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Até a Data de Entrega     ?","mv_ch4","D",08,0,0,"G","","mv_par04","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Da Emissao                ?","mv_ch5","D",08,0,0,"G","","mv_par05","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"06","Até a Emissao             ?","mv_ch6","D",08,0,0,"G","","mv_par06","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"07","Do Cliente                ?","mv_ch7","C",06,0,0,"G","","mv_par07","","","","","","","","","","","","","","","SA1",""})
	aAdd(aRegs,{cPerg,"08","Da Loja                   ?","mv_ch8","C",02,0,0,"G","","mv_par08","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"09","Até o Cliente             ?","mv_ch9","C",06,0,0,"G","","mv_par09","","","","","","","","","","","","","","","SA1",""})
	aAdd(aRegs,{cPerg,"10","Até a Loja                ?","mv_cha","C",02,0,0,"G","","mv_par10","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"11","Semana -AAAA/SS-I         ?","mv_chb","C",07,0,0,"G","u_VldSem()","mv_par11","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"12","Lista os Já Programados   ?","mv_chc","N",01,0,0,"C","","mv_par12","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"13","Lista Libedados Até (Data)?","mv_chd","D",08,0,0,"G","","mv_par13","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"14","Lista Liberados Até (Hora)?","mv_che","C",04,0,0,"G","","mv_par14","","","","","","","","","","","","","","","","@R 99:99"})

	For i := 1 To Len(aRegs)
		If !DbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			SX1->X1_GRUPO   := aRegs[i,01]
			SX1->X1_ORDEM   := aRegs[i,02]
			SX1->X1_PERGUNT := aRegs[i,03]
			SX1->X1_PERSPA  := aRegs[i,03]
			SX1->X1_PERENG  := aRegs[i,03]
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
			SX1->X1_PICTURE := aRegs[i,27]
			MsUnlock()
		Endif
		DbCommit()
	Next
	RestArea(_aArea)
Return(.T.)


/*/{Protheus.doc} ParOP
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function ParOP()//Ok
	/*/
	01 - Do Pedido
	02 - Até o Pedido
	03 - Da Data de Entrega
	04 - Até a Data de Entrega
	05 - Da Emissao
	06 - Até a Emissao
	07 - Do Cliente
	08 - Da Loja
	09 - Até o Cliente
	10 - Até a Loja
	11 - Nro.da Semana da Programacao
	/*/
	_Volta := .T.
	Do While .T. // A saída deste While será pelo comanto EXIT, obrigatoriamente.
		_Volta := Pergunte(cPerg,.T.)
		If _Volta
			My_MVPAR01 := MV_PAR01
			My_MVPAR02 := MV_PAR02
			My_MVPAR03 := MV_PAR03
			My_MVPAR04 := MV_PAR04
			My_MVPAR05 := MV_PAR05
			My_MVPAR06 := MV_PAR06
			My_MVPAR07 := MV_PAR07
			My_MVPAR08 := MV_PAR08
			My_MVPAR09 := MV_PAR09
			My_MVPAR10 := MV_PAR10
			My_MVPAR11 := MV_PAR11
			My_MVPAR12 := MV_PAR12
			My_MVPAR13 := MV_PAR13
			My_MVPAR14 := StrZero(Val(Left(MV_PAR14,2)),2) + ":" + StrZero(Val(Right(MV_PAR14,2)),2)
			If (My_MVPAR01 > My_MVPAR02 .Or. My_MVPAR03 > My_MVPAR04 .Or. My_MVPAR05 > My_MVPAR06 .Or. My_MVPAR07 > My_MVPAR09)
				Alert("Corrigir Abrangência(s)")
				Loop
			ElseIf Empty(My_MVPAR13) .Or. My_MVPAR13 > Date()
				Alert("Corrigir Lista Libedados Até (Data)")
				Loop
			ElseIf Val(Left (My_MVPAR14,2)) < 0 .Or. Val(Left (My_MVPAR14,2)) > 24 .Or. ;
					Val(Right(My_MVPAR14,2)) < 0 .Or. Val(Right(My_MVPAR14,2)) > 59
				Alert("Corrigir Lista Liberados Até (Hora)")
				Loop
			ElseIf !u_VldSem()
				Loop
			EndIf
		EndIf
		Exit
	EndDo
	If _Volta
		Pergunte("MTA650",.F.)
		DbSelectArea("TRB1")
		Processa({|| MontaTrab()},"Montando Arquivo de Trabalho...")
		DbSelectArea("TRB1")
		DbGoTop()
	EndIf
Return(_Volta)


/*/{Protheus.doc} MontaTrab
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function MontaTrab() //Ok
	//_cPedDRC := ""
	DbSelectArea("TRB1")
	Zap

	DbSelectArea("SA1")
	DbSetOrder(1)  //A1_FILIAL+A1_COD+A1_LOJA

	DbSelectArea("SC6")
	DbSetOrder(1)  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO

	DbSelectArea("SC9")
	DbSetOrder(1)  //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO


	DbSelectArea("SA3")
	DbSetOrder(1)  //A3_FILIAL+A3_COD

	Dbselectarea("SF4")
	DbsetOrder(1)

	/*/
	01 - Do Pedido
	02 - Até o Pedido
	03 - Da Data de Entrega
	04 - Até a Data de Entrega
	05 - Da Emissao
	06 - Até a Emissao
	07 - Do Cliente
	08 - Da Loja
	09 - Até o Cliente
	10 - Até a Loja
	11 - Nro.da Semana da Programacao
	12 - Mostra os Já Programados? 1Sim 2Não
	/*/
	#IFDEF TOP
		DbSelectArea("SC5")
		DbSetOrder(1)  //C5_FILIAL+C5_NUM

		cQUER := " FROM "+RetSqlName("SC5")+" C5, "+RetSqlName("SC6")+" C6,"+RetSqlName("SF4")+" F4"
		cQUER += " WHERE C6.C6_NUM = C5.C5_NUM"
		cQUER += " AND C6.C6_TES  = F4.F4_CODIGO"
		cQUER += " AND F4.F4_FILIAL = '" + xFilial("SF4") + "'"
		cQUER += " AND F4.F4_ESTOQUE = 'S'"
		cQUER += " AND C6.C6_FILIAL = '" + xFilial("SC6") + "'"
		cQUER += " AND C6.C6_QTDVEN > C6.C6_QTDENT"
		cQUER += " AND C6.C6_BLQ <> 'R '"
		cQUER += " AND C5.C5_FILIAL = '" + xFilial("SC5") + "'"
		cQUER += " AND C5.C5_EMISSAO >= '" + DToS(My_MVPAR05) + "'"
		cQUER += " AND C5.C5_EMISSAO <= '" + DToS(My_MVPAR06) + "'"
		cQUER += " AND C5.C5_NUM     >= '" + My_MVPAR01 + "'"
		cQUER += " AND C5.C5_NUM     <= '" + My_MVPAR02 + "'"
		cQUER += " AND C5.C5_CLIENTE+C5.C5_LOJACLI >= '" + My_MVPAR07+My_MVPAR08 + "'"
		cQUER += " AND C5.C5_CLIENTE+C5.C5_LOJACLI <= '" + My_MVPAR09+My_MVPAR10 + "'"
		cQUER += " AND C5.C5_ENTREG >= '" + DToS(My_MVPAR03) + "'"
		cQUER += " AND C5.C5_ENTREG <= '" + DToS(My_MVPAR04) + "'"
		cQUER += " AND C5.C5_TIPO = 'N'"
		cQUER += " AND C5.C5_NOTA = '"+Space(Len(SC5->C5_NOTA))+"'"
		If My_MVPAR12 == 2
			//cQUER += " AND (C5.C5_SEMANA = '"+Space(Len(SC5->C5_SEMANA))+"' Or C5.C5_SEMANA = '"+Replicate("X",Len(SC5->C5_SEMANA))+"')"
			// Antes

			cQUER += " AND (C6.C6_SEMANA = '"+Space(Len(SC6->C6_SEMANA))+"' Or C5.C5_SEMANA = '"+Replicate("X",Len(SC5->C5_SEMANA))+"')"
			// Agora - Tem que ser C6_SEMANA, pois pode haver itens de pedidos que estavam em negociação
			// que não entraram no resumo anterior, original do SC5
		EndIf
		cQUER += " AND C5.D_E_L_E_T_ <> '*'"
		cQUER += " AND C6.D_E_L_E_T_ <> '*'"
		cQUER += " AND F4.D_E_L_E_T_ <> '*'"

		cQUERY := "SELECT Count(C5.C5_NUM) as QtdReg " + cQUER
		TCQUERY cQuery NEW ALIAS "RSC5"
		dbSelectArea("RSC5")
		dbGoTop()
		_Total := RSC5->QtdReg
		DbCloseArea("RSC5")

		cQUERY := "SELECT C5.C5_NUM " + cQUER + " ORDER BY C5.C5_NUM"
		TCQUERY cQuery NEW ALIAS "RSC5"
		dbSelectArea("RSC5")
		dbGoTop()

		ProcRegua(_Total)
		_AliasC5 := "RSC5"
		Do While RSC5->(!Eof())
			_cNumPd := RSC5->C5_NUM
			Do While RSC5->(!Eof()) .And. RSC5->C5_NUM ==  _cNumPd
				IncProc()
				RSC5->(DbSkip())
			EndDo
			SC5->(DbSeek(xFilial("SC5")+_cNumPd,.F.))
		#ELSE
			DbSelectArea("SC5")
			DbSetOrder(2)  //C5_FILIAL+DTOS(C5_EMISSAO)+C5_NUM

			ProcRegua(RecCount())

			DbSeek(xFilial("SC5")+DToS(My_MVPAR05),.T.)
			Do While SC5->C5_EMISSAO <= My_MVPAR06 .And. SC5->C5_FILIAL == xFilial("SC5") .And. SC5->(!Eof())
				IncProc()
			#ENDIF

			// se tiver eliminado residuo??
			If 	SC5->C5_NUM     < My_MVPAR01 .Or. SC5->C5_NUM     > My_MVPAR02 .Or. ;
					SC5->C5_CLIENTE+SC5->C5_LOJACLI < My_MVPAR07+My_MVPAR08 .Or.;
					SC5->C5_CLIENTE+SC5->C5_LOJACLI > My_MVPAR09+My_MVPAR10 .Or.;
					SC5->C5_ENTREG < My_MVPAR03 .Or. SC5->C5_ENTREG > My_MVPAR04 .Or.;
					(SC5->C5_DRC > 0 .And. SC5->C5_DRCPROD == "N") // Tem uma devolução e não é para produzir

				// (My_MVPAR12 == 2 .And. !Empty(SC5->C5_SEMANA) .And. SC5->C5_SEMANA # Replicate("X",Len(SC5->C5_SEMANA))) .Or.;

				DbSelectArea("SC5")
				SC5->(DbSkip())
				Loop
			EndIf

			// Somente será incluido na programação os pedidos que estejam com
			// TODOS os itens liberados e também liberado no credito
			DbSelectArea("SC6")
			_lTdOk := DbSeek(xFilial("SC6")+SC5->C5_NUM,.F.)
			//	_lTdOk := .T.
			_dDtLib := CtoD("")
			_cDuplic := "S"
			_lNegoc := .F.
			Do While SC6->C6_FILIAL+SC6->C6_NUM == xFilial("SC6")+SC5->C5_NUM .And. SC6->(!Eof()) .And. _lTdOk
				If _cDuplic == "S"
					_cDuplic := Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_DUPLIC")
				EndIf

				If !Empty(SC5->C5_SEMANA) // Já entrou em um resumo
					// O item não entrou em resumo ou entrou em negociação e foi rejeitado.
					If !_lNegoc .And. Empty(SC6->C6_SEMANA) .And. (Empty(SC6->C6_XNEGOC) .Or. SC6->C6_XNEGOC == "6")
						_lNegoc := .T.
					EndIf
				EndIf
				
				if AllTrim(SC6->C6_BLQ) <> 'R'
					DbSelectArea("SC9")
					_lTdOk := SC9->(DbSeek(xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM,.F.)) .Or. SC6->C6_QTDENT >= SC6->C6_QTDVEN // Achei no SC9 ou Já foi td faturado
					If !_lTdOk .And. Empty(SC5->C5_NOTA) .And. SC5->C5_TIPO == "N"
						Alert("Atenção: Pedido: " + SC6->C6_NUM + " Item: " + SC6->C6_ITEM + " Não Liberado")
					EndIf
					Do While SC9->C9_FILIAL+SC9->C9_PEDIDO+SC9->C9_ITEM == xFilial("SC9")+SC6->C6_NUM+SC6->C6_ITEM .And.;
							SC9->(!Eof()) .And. _lTdOk
						_lTdOk := Empty(SC9->C9_BLCRED) .Or. SC9->C9_BLCRED == "10"
						_dDtLib := SC9->C9_DATALIB
						SC9->(DbSkip())
					EndDo				
					DbSelectArea("SC6")
				endif
				SC6->(DbSkip())
			EndDo
			If !_lTdOk
				DbSelectArea("SC5")
				SC5->(DbSkip())
				Loop
			EndIf

			// Conforme solicitação do Renê, somente serão incluídos neste resumo os pedidos que estejam
			// liberados por crédito até a data e hora conforme os parâmetros My_MVPAR13 e My_MVPAR14
			DbSelectArea("ZZI") // Ocorrência nos pedidos
			DbSetOrder(3) // ZZI_FILIAL+ZZI_PEDIDO+DTOS(ZZI_DATA)+ZZI_HORA
			DbSeek(xFilial("ZZI")+SC5->C5_NUM,.F.)
			_dDtLib := Ctod("//")
			_cHrLib := "     "
			Do While ZZI->ZZI_FILIAL == xFilial("ZZI") .And. ZZI->ZZI_PEDIDO == SC5->C5_NUM .And. ZZI->(!Eof())
				//If ZZI->ZZI_CODEVE == If(_cDuplic=="S","05","04") // Liberação de Crédito ou Liberação do Pedido
				// Com Natanael - Não estão incluindo pedidos de transferência para 3 Lagoas
				If ZZI->ZZI_CODEVE $ "05//04" // Liberação de Crédito ou Liberação do Pedido
					If ZZI->ZZI_DATA > _dDtLib
						_dDtLib := ZZI->ZZI_DATA
						_cHrLib := Left(ZZI->ZZI_HORA,5)
					ElseIf ZZI->ZZI_DATA == _dDtLib
						_cHrLib := If(Left(ZZI->ZZI_HORA,5)>_cHrLib,Left(ZZI->ZZI_HORA,5),_cHrLib)
					EndIf
				EndIf
				ZZI->(DbSkip())
			EndDo
			If Empty(_dDtLib) .Or. _dDtLib > My_MVPAR13 .Or. (_dDtLib == My_MVPAR13 .And. _cHrLib > My_MVPAR14)
				DbSelectArea("SC5")
				SC5->(DbSkip())
				Loop
			EndIf

			_nValTot := u_SomaPed(SC5->C5_NUM,.F.,"S"," ") //(Nro.PV,Tudo ou só saldo,TES Estoque, TES Financeiro)
			// SomaPed retorna o Valor de Venda e o Valor de Custo

			If _nValTot[3] > 0 .Or. _nValTot[6] > 0 // Verifico se tem quantidades de cobre a movimentar estoque
				SA1->(DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,.F.))
				SA3->(DbSeek(xFilial("SA3")+SC5->C5_VEND1,.F.))

				RecLock("TRB1",.T.)
				//	TRB1->OK      := cMarca
				TRB1->PEDIDO  := SC5->C5_NUM
				//		TRB1->NRODRC  := SC5->C5_DRC
				TRB1->CLIENTE := SC5->C5_CLIENTE
				TRB1->LOJA    := SC5->C5_LOJACLI
				TRB1->NOME    := Left(SA1->A1_NOME,20)
				TRB1->MUN     := Left(SA1->A1_MUN,15)
				TRB1->EST     := SA1->A1_EST
				TRB1->EMISSA  := SC5->C5_EMISSAO
				TRB1->DTLIB   := _dDtLib
				TRB1->ENTREG  := SC5->C5_ENTREG

				If Type("SA3->A3_CONTAT") == "C"
					TRB1->VEND    := Left(SA3->A3_NREDUZ,10)
				Else
					TRB1->VEND    := Left(SA3->A3_NREDUZ,10)
				EndIf
				//		TRB1->TOTAL   := _nValTot[1] Alterado em 02/03/09 pq mudei a rotina somaped()
				TRB1->TOTAL   := _nValTot[1]+_nValTot[5]
				TRB1->LUCROB  := SC5->C5_LUCROBR

				If !(SC5->C5_TIPO $ "DB") .And. SA1->A1_MSBLQL == '1' // Cliente Bloqueado
					TRB1->SEMANA  := "BLQ."
					TRB1->NOME    := AllTrim(Left(SA1->A1_NOME,20)) + "-BLQ"
				Else
					TRB1->SEMANA  := If(SC5->C5_SEMANA == Replicate("X",Len(SC5->C5_SEMANA)).Or._lNegoc,Space(Len(SC5->C5_SEMANA)),SC5->C5_SEMANA)
				EndIf
				TRB1->OBS     := Left(SC5->C5_OBS,25)
				_nDIF         := dDataBase-_dDtLib
				TRB1->DIF     := If(_nDIF>999,999,_nDIF)
				TRB1->SETOR   := If(SA1->A1_SETOR=="I","i","R")

				MsUnLock()
			EndIf
			DbSelectArea("SC5")
			SC5->(DbSkip())
		EndDo
		#IFDEF TOP
			DbSelectArea("RSC5")
			DbCloseArea("RSC5")
		#ENDIF
		DbSelectArea("SC5")
		Return(.T.)


/*/{Protheus.doc} ValidQtd
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0
@type function
/*/
User Function ValidQtd()// OK
	_Volta := .T.
	//If GDFieldGet("_C6QTDLIB",n) < 0.00
	If M->_C6QTDLIB < 0.00
		Alert("Quantidade Inválida")
		_Volta := .F.
	ElseIf (M->_C6QTDLIB%GDFieldGet("_C6METRAGE",n)) # 0
		Alert("Quantidade Inválida")
		_Volta := .F.
	Else
		GDFieldPut("_C6LANCES",(M->_C6QTDLIB/GDFieldGet("_C6METRAGE",n)),n)
	EndIf
Return(_Volta)


/*/{Protheus.doc} VldSem
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0

@type function
/*/
User Function VldSem()
	SZ9->(DbSetOrder(1))
	_Volta := SZ9->(!DbSeek(xFilial("SZ9")+MV_PAR11,.F.))
	If !_Volta
		Alert("Número do Resumo já Existe - Informe Novamente!")
	EndIf
Return(_Volta)


/*/{Protheus.doc} MarkAll
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0

@type function
/*/
User Function MarkAll()
	DbSelectArea("TRB1")
	_RegAtu := Recno()
	DbGoTop()
	Do While !Eof()
		RecLock("TRB1",.F.)
		If !Empty(TRB1->SEMANA) .Or. TRB1->OK == cMarca
			TRB1->OK := " "
		Else
			TRB1->OK := cMarca
		EndIf
		MsUnLock()
		DbSkip()
	EndDo
	DbGoTo(_RegAtu)
Return(.t.)


/*/{Protheus.doc} NovaOP
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}
@param _cModo, , descricao
@param lCriaOPI, logical, descricao
@param dDtOpPar, date, descricao
@param _cOpc, , descricao
@param _cStInt, , descricao
@param _lExplod, , descricao
@type function
/*/
User Function NovaOP(_cModo,lCriaOPI,dDtOpPar,_cOpc,_cStInt,_lExplod)// _cModo == Inclusão/Exclusão --- lCriaOPI == .T. = GeraOP Intermediárias ou não .F.
	Public  lGeraOPI
	Private lMsErroAuto

	Default _cStInt		:= " "
	Default _lExplod	:= .T.

	If Empty(dDtOpPar)
		dDtOpPar := Ctod("31/12/2049")
	EndIf

	If dDtOpPar == Ctod("31/12/2049") .Or. Empty(dDtOpPar)
		dDtOpPar := Date()+SB1->B1_PE // Date de entrega da produção
	EndIf

	// Esta programação parece estranha, mas foi a forma que encontrei para
	// que os dados de lCriaOPI não interfiram na variável pública lGeraOPI
	If lCriaOPI
		lGeraOPI := .T.
	Else
		lGeraOPI := .F.
	EndIf

	If Select("BAT") > 0
		DbSelectArea("BAT")
		DbCloseArea("BAT")
	EndIf
	lMsErroAuto := .F.
	DbSelectArea("SC2")
	DbSelectArea("SB1")
	If _cModo == "I" // Inclusao
		SB1->(DbSetOrder(1))
		SB1->(DbSeek(xFilial("SB1")+_cProd,.F.))
		//{"AUTEXPLODE",IIF(_lExplod,"S","N"),Nil},;
			_nModo := 3
		aVetor:={ 	{"C2_ITEM"   ,_Item            ,NIL},;
			{"C2_NUM"    ,_NumOP           ,NIL},;
			{"C2_SEQUEN" ,_cSeq            ,NIL},;
			{"C2_PRODUTO",_cProd           ,NIL},;
			{"AUTEXPLODE",IIF(_lExplod,"S","N"),Nil},;
			{"C2_DESCRI" ,SB1->B1_DESC     ,NIL},;
			{"C2_LOCAL"  ,_cAlmo           ,NIL},;
			{"C2_QUANT"  ,_nQtd            ,NIL},;
			{"C2_DATPRI" ,dDtOpPar         ,NIL},; // Dt.Previsão de inicio de produção
		{"C2_DESTINA","E"              ,NIL},;
			{"C2_PRIOR"  ,"500"            ,NIL},;
			{"C2_DATPRF" ,dDtOpPar         ,NIL},; // Dt. de entrega
		{"C2_OBS"    ,_Obs             ,NIL},;
			{"C2_EMISSAO",dDataBase        ,NIL},;
			{"C2_STATINT",_cStInt          ,NIL},;
			{"C2_STATOP" ,"L"              ,NIL},;
			{"C2_SEMANA" ,If(Type("_cSemOP") # "U",_cSemOP,"")  ,NIL},;
			{"C2_OPC"    ,_cOpc            ,NIL}}
	Else // Exclusao
		_Item  := SC2->C2_ITEM
		_NumOP := SC2->C2_NUM
		_nModo := 5
		_cProd := SC2->C2_PRODUTO
		aVetor:={ 	{"C2_ITEM"   ,SC2->C2_ITEM   ,NIL},;
			{"C2_NUM"    ,SC2->C2_NUM    ,NIL},;
			{"C2_SEQUEN" ,SC2->C2_SEQUEN ,NIL},;
			{"C2_PRODUTO",SC2->C2_PRODUTO,NIL},;
			{"C2_LOCAL"  ,SC2->C2_LOCAL  ,NIL},;
			{"C2_QUANT"  ,SC2->C2_QUANT  ,NIL},;
			{"C2_DATPRI" ,SC2->C2_DATPRI ,NIL},;
			{"C2_DESTINA",SC2->C2_DESTINA,NIL},;
			{"C2_PRIOR"  ,SC2->C2_PRIOR  ,NIL},;
			{"C2_DATPRF" ,SC2->C2_DATPRF ,NIL},;
			{"C2_OBS"    ,SC2->C2_OBS    ,NIL},;
			{"C2_EMISSAO",SC2->C2_EMISSAO,NIL}}
	EndIf

	lMsErroAuto := .F.

	MSExecAuto({|x,y| mata650(x,y)},aVetor,_nModo) //_nModo=3-Inclusao // _nModo=5-Exclusao
	If !lMsErroAuto .and. !_lExplod
		Reclock("SC2",.F.)
		SC2->C2_BATCH := "S"
		MsUnLock()
	EndIf

	lGeraOPI := GetMv("MV_GERAOPI")  // Retorna com o padrão do Sistema

	If Select("TB_CB") > 0 // Abriu o arquivo
		// O execauto destrava todos os registros de todos os arquivos dá MsUnLockAll
		// e eu preciso desse cara sempre travado
		DbSelectArea("TB_CB")
		RecLock("TB_CB",.F.)
	EndIf

Return(!lMsErroAuto)


/*/{Protheus.doc} Muda
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}
@param nFazer, numeric, descricao
@type function
/*/
User Function Muda(nFazer)
	//Local _xPedDRC
	//If nFazer == 1 // Mudar Ordem
	If IndexOrd() == 1
		DbSetOrder(2)
	Else
		DbSetOrder(1)
	EndIf
Return(.T.)


/*/{Protheus.doc} Line3Ok
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}
@param ntamaCols, numeric, descricao
@type function
/*/
User Function Line3Ok(ntamaCols)
	_Volta := .T.
	If n > ntamaCols .And. !aCols[n,Len(aCols[n])]
		If GDFieldGet("_C6ACONDIC",n) == "T" // Retalho
			Alert("Tipo de Acondicionamento Inválido")
			_Volta := .F.
		ElseIf (GDFieldGet("_C6QTDLIB",n) / GDFieldGet("_C6LANCES",n) # GDFieldGet("_C6METRAGE",n)) .Or. ;
				GDFieldGet("_C6QTDLIB",n) == 0 .Or. GDFieldGet("_C6LANCES",n) == 0
			Alert("Informe Corretamente Quantidade, Lances e Metragem")
			_Volta := .F.
		ElseIf Empty(GDFieldGet("_C6LOCAL",n))
			Alert("Informe o Almoxarifado")
			_Volta := .F.
		Else
			_cLocaliz := Left(GDFieldGet("_C6ACONDIC",n)+StrZero(GDFieldGet("_C6METRAGE",n),5)+Space(Len(SBF->BF_LOCALIZ)),Len(SBF->BF_LOCALIZ))
			GDFieldPut("_C6LOCALIZ",_cLocaliz,n)
		EndIf
	EndIf
Return(_Volta)


/*/{Protheus.doc} A650OPI
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function A650OPI()
	// Ponto de entrada que determina se deve ou não ser criadas as OPs intermediárias
	Public _MyStatIn,_MyStatOp
	If SC2->C2_SEQUEN == "001"
		_MyStatIn := SC2->C2_STATINT
		_MyStatOp := SC2->C2_STATOP
	Else
		If Empty(SC2->C2_STATINT) .And. !Empty(_MyStatIn)
			SC2->C2_STATINT := _MyStatIn
		EndIf
		If Empty(SC2->C2_STATOP) .And. !Empty(_MyStatOp)
			SC2->C2_STATOP  := _MyStatOp
		EndIf
	EndIf
	If Upper(Type("lGeraOPI")) # "L"
		lGeraOPI := GETMV("MV_GERAOPI")
	EndIf
Return(lGeraOPI)


/*/{Protheus.doc} VejaDes
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function VejaDes()
	GDFieldPut("_C6DESCRI" ,Posicione("SB1",1,xFilial("SB1")+M->_C6PRODUTO,"B1_DESC"),n)
	GDFieldPut("_C6LOCALIZ",Space(Len(SBE->BE_LOCALIZ)),n) // Força a digitação do acondicionamento
Return(.T.)


/*/{Protheus.doc} VldLclz
//TODO Descrição auto-gerada.
@author LEGADO
@since 02/08/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function VldLclz()
	// Validar primeiro o acondicionamento
	If Empty(M->_C6LOCALIZ)
		Return(.T.)
	ElseIf Empty(GDFieldGet("_C6PRODUTO",n))
		Alert("Informar Primeiro o código do Produto")
		Return(.F.)
	EndIf

	If !Left(M->_C6LOCALIZ,1) $ "RBCMLT"
		Alert("Acondicionamento Inválido")
		Return(.F.)
	EndIf

	_nnMtrs := Val(Substr(M->_C6LOCALIZ,2,5))

	If _nnMtrs <= 0
		Alert("Acondicionamento Inválido")
		Return(.F.)
	EndIf

	If GDFieldGet("_C6QTDLIB",n) > 0
		If (GDFieldGet("_C6QTDLIB",n) %  _nnMtrs) > 0
			Alert("Acondicionamento Inválido")
			Return(.F.)
		EndIf
		M->_C6LOCALIZ := Left(M->_C6LOCALIZ,1) + StrZero(_nnMtrs,5)
		M->_C6LOCALIZ := Padr(M->_C6LOCALIZ,Len(SBE->BE_LOCALIZ))
		GDFieldPut("_C6LANCES",(GDFieldGet("_C6QTDLIB",n) / _nnMtrs),n)
	EndIf

	// Verifica se tem outra linha com o mesmo produto e acondicionamento
	For _nLn := 1 to Len(aCols)
		If _nLn # n .And. 	AllTrim(GDFieldGet("_C6PRODUTO",_nLn)) == AllTrim(GDFieldGet("_C6PRODUTO",n)) .And.;
				AllTrim(GDFieldGet("_C6LOCALIZ",_nLn)) == AllTrim(M->_C6LOCALIZ)
			Alert("Alterar a Linha " + Str(_nLn,3))
			Return(.F.)
		EndIf
	Next

	GDFieldPut("_C6METRAGE",_nnMtrs,n)
	GDFieldPut("_C6LOCAL","01",n)
	GDFieldPut("_C6ACONDIC",Left(M->_C6LOCALIZ,1),n)
Return(.T.)


/*/{Protheus.doc} fAnTrfFil
//TODO Valida o Array de itens e aplica a transfrencia de itens conforme listagem do B1.
@author juliana.leme
@since 07/08/2018
@version 1.0

@type function
/*/
User Function fAnTrFil(aItensFil)
	Local cSvFilAnt := cFilAnt
	Local cPvTrans 	:= ""
	Local lRetor		:= .T.
	Local aParamts	:= {}
	Local oApp_Ori 	:= oApp
	Local aArea		:= getArea()
	Local _cFilialAt	:= ""
	Local nCont		:= 1
	Default aItensFil := {}

	If Len (aItensFil) > 0
		Begin Transaction
			//Cria PV de Transferencia conforme solicitação
			If FWCodFil() == "01"
				_cFilialAt := "02"
			Else
				_cFilialAt := "01"
			EndIf

			cFilAnt 	:= _cFilialAt // Mudando para a filial 02
			aParamts	:= U_fCbTrFil(aItensFil)
			If aParamts[1]
				cPvTrans := aParamts[2]
				cFilAnt  := cSvFilAnt

				MsgBox("Pedido de Transferencia incluido com sucesso, Numero do PV: "+cPvTrans, "Realizado", "INFO")

				For nCont := 1 to Len (aItensFil)
					DbSelectArea("SC6")
					DbSetOrder(1)  //C6_FILIAL+C6_NUM+C6_ITEM+C6_PRODUTO
					//Grava o Semana do C6 para que os mesmo não entrem mais em resumo após a transferencia ter sido solicitada
					If DbSeek(xFilial("SC6")+aItensFil[nCont][8]+aItensFil[nCont][9],.F.)
						RecLock("SC6",.F.)
						SC6->C6_SEMANA	:= "T" + cPvTrans
						MsUnLock()
					EndIf
				Next
			Else
				MsgBox("Pedido NÃO Concluido, favor verificar!", "Atenção !!!", "INFO")
				MsgBox("Resumo NÃO Concluido, Erro!", "Atenção !!!", "INFO")
				DisarmTransaction()
			EndIf
		End Transaction
	Else
		Alert("Sem Itens para gerar Pedido de Transferencia")
	EndIf
Return()

static function checkLiber(cNumPed, cItemPed)
	local aArea    	:= GetArea()
    local aAreaSC6	:= SC6->(getArea())
    local aAreaSC9	:= SC9->(getArea())
	local nQtdTrf 	:= 0
    local oSql 		:= LibSqlObj():newLibSqlObj()

    oSql:newAlias(qrycheckLiber(cNumPed, cItemPed))
    if oSql:hasRecords()
        oSql:goTop()
        while oSql:notIsEof()
			nQtdTrf += oSql:getValue("QTDE")
            oSql:Skip()
        endDo
    endif
    oSql:close()
    FreeObj(oSql)

    RestArea(aAreaSC9)
    RestArea(aAreaSC6)
    RestArea(aArea)
return(nQtdTrf)

static function qrycheckLiber(cNumPed, cItemPed)
	local cQry := ""

	cQry += " SELECT ISNULL(SUM(SC9.C9_QTDLIB),0) AS [QTDE] "
	cQry += " FROM " + RetSqlName("SC9") + " SC9 "
	cQry += " WHERE SC9.C9_FILIAL = '" + xFilial("SC9") + "' "
	cQry += " AND SC9.C9_PEDIDO = '" + AllTrim(cNumPed) + "' "
	cQry += " AND SC9.C9_ITEM = '" + AllTrim(cItemPed) + "' "
	cQry += " AND SC9.C9_BLEST = '02' "
	cQry += " AND SC9.C9_BLCRED = '' "
	cQry += " AND SC9.D_E_L_E_T_ = '' "
return(cQry)
