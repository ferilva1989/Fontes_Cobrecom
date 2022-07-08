#INCLUDE "PROTHEUS.CH"
#INCLUDE "msobject.ch"
#INCLUDE "topconn.ch"
//#INCLUDE "protheus8.ch"
#INCLUDE "rwmake.ch"
#Define linha chr(13)+chr(10)
static cDrive := if(U_zIs12(),'CTREECDX','')

/////////////////////////////////////////////////////////////////////////////
//
// Conjunto de Programas/Funções/Objetos de uso genérico da
// IFC - Cobrecom
//
/////////////////////////////////////////////////////////////////////////////

/*/{Protheus.doc} QryArr
//TODO Funcao para rodar uma Query e retornar como Array   .
@author Silvio Cazela
@since 21/06/2001
@version undefined
@param cQuery, Query SQL a ser executado
@return aTrb, Array com o conteudo da Query   
@type function
/*/
User Function QryArr(cQuery)

	//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	//º Gravacao do Ambiente Atual e Variaveis para Utilizacao                   º
	//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍSilvio CazelaÍ¼
	Local aRet    := {}
	Local aRet1   := {}
	Local nRegAtu := 0
	Local x       := 0

	//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	//º Ajustes e Execucao da Query                                              º
	//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍSilvio CazelaÍ¼
	cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "_TRBTEMP"

	//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	//º Montagem do Array para Retorno                                           º
	//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍSilvio CazelaÍ¼
	DbSelectArea("_TRBTEMP")
	aRet1   := Array(fcount())
	nRegAtu := 1

	While !eof()
		For x:=1 to fcount()
			aRet1[x] := FieldGet(x)
		Next
		AADD(aRet,aclone(aRet1))
		DbSkip()
		nRegAtu += 1
		//--------------------------------------------------------------------------------------------
		// Testa se vetor excede 98.000 linhas
		// Limites conhecidos do ADVPL/CLIPPER:
		// Limite de elementos para Array = 100.000 elementos (independente da quantidade de colunas)
		// Limite de variável caracter = aprox. 1.000.000 caracteres (1MB)
		//--------------------------------------------------------------------------------------------
		if nRegAtu > 99999
			msgbox("Comunique IMEDIATAMENTE o Departamento de TI.","ATENÇÃO!! Limite de array excedido.","STOP")
			exit
		endif
	Enddo

	//ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»
	//º Encerra Query e Retorna Ambiente                                         º
	//ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍSilvio CazelaÍ¼
	DbSelectArea("_TRBTEMP")
	_TRBTEMP->(DbCloseArea())

Return(aRet)

/*/{Protheus.doc} MmToPix
//TODO Retorna a Largura da Pagina em Pixel.	.
@author Waldir Baldin
@since 27/10/06
@version undefined
@param oPrint, object, descricao
@param nMm, numeric, descricao
@type function
/*/
User Function MmToPix(oPrint, nMm)

	/*Retirado metodo oPrint:nLogPixelX(), pois estava ocorrendo casos em clientes
	em que a linha impressa que utliza a funcao MM2PIX saia desconfigurada*/
	//Local nValor := (nMm * oPrint:nLogPixelX()) / 25.4

	Local nValor := (nMm * 300) / 25.4

Return nValor

/*/{Protheus.doc} InfTrian
//TODO A partir da informação da filial e número do pedido, identi- º±±
fica se o mesmo foi originado de uma operação de triangula-  
ção (industrialização), e retorna informações do pedido de   
venda ao cliente.                                            
A operação de triangulação foi projetada em agosto/2015, so- 
mente para industrializar em Itu produtos que serão vendidos 
por 3 Lagoas.                                                
CASO ESTA REGRA SEJA REDEFINIDA, OS PROGRAMAS DEVEM SER RE-  
VISADOS/ALTERADOS. .
@author Jeferson Gardezani 
@since 21/08/15
@version undefined
@param _cFil, , Filial do Pedido que deseja pesquisar
@param _cPed, , Número do Pedido que deseja pesquisar
@param cOrigem, characters, Campo que deseja retornar o conteúdo
@return aRet3L, array, Informações do pedido de Triangulação
@type function
/*/
User Function InfTrian(_cFil,_cPed, cOrigem)
	Local cMSG 				:= ""
	Local cQuery, cRet 		:= ""
	Local aRetITU, aRet3L 	:= {}

	Default cOrigem := " Parâmetro 4 não informado: cOrigem "

	If _cFil == '01'	//Só pesquisa se a filial é Itu (somente Itu faz industrialização)

		//QUERYS PLANEJADAS PARA USAR OS ÍNDICES:
		// C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
		// A1_FILIAL, A1_COD, A1_LOJA, R_E_C_N_O_, D_E_L_E_T_

		//Pesquisa Pedido em Itu (verificar se o pedido é de industrialização)
		cQuery := " SELECT DISTINCT "
		cQuery += "    SUBSTRING(C6_1.C6_ZZPVORI,1,6) "
		cQuery += " FROM SC6010 C6_1"
		cQuery += " WHERE "
		cQuery += "    C6_1.C6_FILIAL		= '" + _cFil + "' "
		cQuery += "    AND C6_1.C6_NUM		= '" + _cPed + "' "     
		cQuery += "    AND SUBSTRING(C6_1.C6_ZZPVORI,1,6) 	"
		cQuery += "    		IN ( "
		cQuery += "    				SELECT C6_2.C6_NUM "
		cQuery += "    					FROM SC6010 C6_2 "
		cQuery += "    				WHERE C6_2.C6_FILIAL = '02' "
		cQuery += "    					AND C6_2.C6_NUM = SUBSTRING(C6_1.C6_ZZPVORI,1,6) "
		cQuery += "    					AND C6_2.C6_LOCAL = '10' "
		cQuery += "    					AND C6_2.D_E_L_E_T_	= '' "
		cQuery += "    			) "
		cQuery += "    AND C6_1.D_E_L_E_T_	= '' "


		//Obtem Array com resultado da Query
		aRetITU	:= u_qryarr(cQuery)

		If Empty(aRetITU)
			aAdd(aRetItu,{""})
		EndIf

		//Verifica se encontrou o pedido de Itu
		If (Len(aRetITU) # 1)
			cMSG += " Usuario: " + cUserName 	+ " / "
			cMSG += " Pedido: " 	+ _cPed		+ " / "
			cMSG += " Origem: " 	+ cOrigem

			//Não encontrou ou encontrou mais do que um pedido de venda no pedido de industrialização
			msgbox("Erro na Pesquisa do Pedido Industrialização: [" + _cPed + "]. Comunique o Departamento de TI.","ATENÇÃO, ERRO!","STOP")
			//Além de avisar o usuário, envia e-mail para o TI verificar possível falha de base de dados.
			//u_SendMail(_cTo,_cAssunto,_cCorpo,_cAnexo)
			u_SendMail("wfti@cobrecom.com.br","[TOTVS-PROTHEUS] Comunicação de Erro ao TI","Erro na Pesquisa do Pedido Industrialização: [" + cMSG + "]. Verificar erro na base de dados.")
		Else

			//Verifica se é industrialização para pesquisar pedido em 3 Lagoas
			If !Empty(aRetITU[1,1])

				//Pesquisa Pedido em 3 Lagoas (obter dados o pedido de venda ao cliente)
				cQuery := " SELECT 	'"+aRetITU[1,1]+"'	PEDIDO, "		//1
				cQuery += "			'[IFC]'+A1_NOME		NOME, "			//2
				cQuery += "			'[IFC]'+A1_NREDUZ	NREDUZ, "		//3
				cQuery += "			A1_MUN				MUNICIPIO, "	//4
				cQuery += "			A1_EST				ESTADO, "		//5
				cQuery += "			A1_CGC				CGC, "			//6
				cQuery += "			'('+A1_DDD+')'+A1_TEL A1_TEL, "		//7
				cQuery += "			C5_TIPOCLI			TPCLI, "		//8
				cQuery += "			C5_CONDPAG			CONDPAG, "		//9
				cQuery += "			C5_OBS				OBS, "			//10
				cQuery += "			C5_TABELA			TABELA, "		//11
				cQuery += "			C5_ENTREG			ENTREG, "		//12
				cQuery += "			C5_EMISSAO			EMISSAO, "		//13
				cQuery += "			C5_MENNOTA			MENNOTA1, "		//14
				cQuery += "			C5_PEDCLI			PEDCLI, "		//15
				cQuery += "			C5_ENDENT1+' '+C5_ENDENT2 ENDENTR, "//16
				cQuery += "			C5_CLIENTE			CLIENTE, "		//17
				cQuery += "			C5_LOJACLI			LOJACLI, "		//18
				cQuery += "			C5_TRANSP			TRANSPOR, "		//19
				cQuery += "			C5_TIPOLIB			TPLIB, "		//20
				cQuery += "			ISNULL(A1_ROTA3L,'999') ROTA, "		//21
				cQuery += "			C5_VEND1			VENDED, "		//22
				cQuery += "			C5_CLIENT+C5_LOJAENT CLIENTR, "		//23
				cQuery += "			C5_PALLET			PALLET, "		//24
				cQuery += "			C5_XTELENT			XTELENT, "		//25
				cQuery += "			C5_LAUDO			LAUDO, "		//26
				cQuery += "			C5_MENNOTA			MENNOTA2, "		//27
				cQuery += "			A1_XAGENTR			AGENTREG, "		//28
				cQuery += "			A1_ZZPRFAT 			PERFATUR,"		//29
				cQuery += "			C5_DTFAT			DTFAT"			//30 // By Roberto Oliveira 23/02/2017
				cQuery += " FROM SC5010 "
				cQuery += " INNER JOIN SA1010 "
				cQuery += "    ON ''                   = A1_FILIAL "
				cQuery += "    AND C5_CLIENTE			= A1_COD "
				cQuery += "    AND C5_LOJACLI			= A1_LOJA "
				cQuery += "    AND SC5010.D_E_L_E_T_	= SA1010.D_E_L_E_T_ "
				cQuery += " WHERE C5_FILIAL				= '02' "
				cQuery += "    AND C5_NUM				= '" + aRetITU[1,1] + "' "
				cQuery += "    AND SC5010.D_E_L_E_T_	= '' "

				//Obtem Array com resultado da Query
				aRet3L := u_qryarr(cQuery)
				/*
				Posição Vetor : aRet3L
				[1]PEDIDO
				[2]A1_NOME
				[3]A1_NREDUZ
				[4]A1_MUN
				[5]A1_EST
				[6]A1_CGC
				[7]A1_TEL
				[8]C5_TIPOCLI
				[9]C5_CONDPAG
				[10]C5_OBS
				[11]C5_TABELA
				[12]C5_ENTREG
				[13]C5_EMISSAO
				[14]C5_MENNOTA
				[15]C5_PEDCLI
				[16]C5_ENDENT1+' '+C5_ENDENT2
				[17]C5_CLIENTE
				[18]C5_LOJACLI
				[19]C5_TRANSP
				[20]C5_TIPOLIB
				[21]ISNULL(A1_ROTA3L,'999')
				[22]C5_VEND1
				*/

				//Verifica se encontrou o Pedido de 3 Lagoas
				If Len(aRet3L) # 1
					cMSG += " Usuario:" 	+ cUserName 	   + " / "
					cMSG += " Pedido: " 	+ aRetITU[1,1]	+ " / "
					cMSG += " Origem: " 	+ cOrigem

					//Não encontrou ou encontrou mais do que um pedido de venda
					msgbox("Erro na Pesquisa do Pedido de Venda: [" + aRetITU[1,1] + "]. Comunique o Departamento de TI.","ATENÇÃO, ERRO!","STOP")
					//Além de avisar o usuário, envia e-mail para o TI verificar possível falha de base de dados.
					//u_SendMail(_cTo,_cAssunto,_cCorpo,_cAnexo)
					u_SendMail("wfti@cobrecom.com.br","[TOTVS-PROTHEUS] Comunicação de Erro ao TI","Erro na Pesquisa do Pedido de Venda: [" + cMSG + "]. Verificar erro na base de dados.")
				Else
					Return(aRet3L)
				EndIf
			EndIf
		EndIf
	EndIf
Return (aRet3L)

/*/{Protheus.doc} CdRetSC5Ind
//TODO Descrição auto-gerada.
@author juliana.leme
@since 23/06/2017
@version undefined

@type function
/*/
User Function CdRetSC5Ind()
	Local aDadSC5 := {}
	Local cQuery 	:= ""

	cQuery := " SELECT C5_"										+ linha
	cQuery += "    SUBSTRING(C6_ZZPVORI,1,6)"					+ linha
	cQuery += " FROM SC6010"									+ linha
	cQuery += " WHERE"											+ linha
	cQuery += "    C6_FILIAL				= '01'"				+ linha
	cQuery += "    AND C6_NUM				= '" + _cPed + "'"	+ linha
	cQuery += "    AND SC6010.D_E_L_E_T_	= ''"				+ linha

	//Obtem Array com resultado da Query
	aRetITU	:= u_qryarr(cQuery)
Return(aDadSC5)


/*/{Protheus.doc} CdRetSC5Ind
//TODO Descrição auto-gerada.
@author juliana.leme
@since 18/04/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function CBRZZPV(_cFilial,_cPedi,_cItPV)
	Local cQuery 	:= ""
	Local aRetITU	:= {}
	Local _NumPedOri:= ""
	local aPedVenMG	:= ""
	
	aPedVenMG := u_pedTriangMG(_cFilial,_cPedi,_cItPV)
	if ! (aPedVenMG[1])
		cQuery := " SELECT C6_ZZPVORI"									+ linha
		cQuery += " FROM SC6010 SC6"									+ linha
		cQuery += " WHERE"												+ linha
		cQuery += "    C6_FILIAL			= '" + _cFilial  + "' "		+ linha
		cQuery += "    AND C6_NUM			= '" + _cPedi    + "' "		+ linha
		cQuery += "    AND C6_ITEM			= '" + _cItPV    + "' "		+ linha
		cQuery += "    AND C6_ZZPVORI		<> '' " 					+ linha
		cQuery += "    AND SC6.D_E_L_E_T_	= '' "						+ linha

		aRetITU	:= u_qryarr(cQuery) //Obtem Array com resultado da Query
		if empty(aRetITU)
			aadd(aRetItu,{" "})
		endif
	
		_NumPedOri := IIf(empty(aRetITU[1,1]),"",aRetITU[1,1])
	else
		_NumPedOri := aPedVenMG[2]
	endif
Return(_NumPedOri)

/*/{Protheus.doc} RetZZPvOri
//TODO Descrição auto-gerada.
@author juliana.leme
@since 23/06/2017
@version undefined
@param _cFilial, , descricao
@param _cPedi, , descricao
@type function
/*/
User Function RetZZPvOri(_cFilial,_cPedi)
	Local cQuery		:= ""
	Local _NumPedOri	:= ""
	Local aRetITU		:= {}

	If _cFilial = "01"
		cQuery := " SELECT DISTINCT "
		cQuery += "    SUBSTRING(C6_ZZPVORI,1,6) "
		cQuery += " FROM SC6010 "
		cQuery += " WHERE "
		cQuery += "    C6_FILIAL					= '01' "
		cQuery += "    AND C6_NUM				= '" + _cPedi + "' "
		cQuery += "    AND C6_ZZPVORI			<> '' "
		cQuery += "    AND C6_TES				<> '842' " //Transferencia de Materiais
		cQuery += "    AND (C6_TES				<> '849' AND  C6_ZZPVORI  <>  '') " //Transferencia de Materiais
		cQuery += "    AND C6_TES				<> '551' " //Industrialização Fisica
		cQuery += "    AND C6_TES				<> '701' " //Industrialização Metodo Antigo (vania)
		cQuery += "    AND SC6010.D_E_L_E_T_	= '' "

		//Obtem Array com resultado da Query
		aRetITU	:= u_qryarr(cQuery)

		If Empty(aRetITU)
			aAdd(aRetItu,{" "})
		EndIf

		_NumPedOri := IIf(Empty(aRetITU[1,1]),""," (Ped.:" + aRetITU[1,1]+")")
	Else
		_NumPedOri := ""
	EndIf
Return (_NumPedOri)

/*/{Protheus.doc} RetPedOri551
//TODO Descrição auto-gerada.
@author juliana.leme
@since 23/06/2017
@version undefined
@param _cFilial, , descricao
@param _cPedi, , descricao
@type function
/*/
User Function RetPedOri551(_cFilial,_cPedi)
	Local cQuery		:= ""
	Local _NumPedOri	:= ""
	Local aRetITU		:= {}

	If _cFilial = "01"
		cQuery := " SELECT DISTINCT "
		cQuery += "    SUBSTRING(C6_ZZPVORI,1,6) "
		cQuery += " FROM SC6010 "
		cQuery += " WHERE "
		cQuery += "    C6_FILIAL				= '01' "
		cQuery += "    AND C6_NUM				= '" + _cPedi + "' "
		cQuery += "    AND C6_ZZPVORI			<> '' "
		cQuery += "    AND C6_TES				= '551' " //Industrialização Fisica
		cQuery += "    AND SC6010.D_E_L_E_T_	= '' "

		//Obtem Array com resultado da Query
		aRetITU	:= u_qryarr(cQuery)

		If Empty(aRetITU)
			aAdd(aRetItu,{" "})
		EndIf

		_NumPedOri := " (Ped.:" + aRetITU[1,1]+")"
	Else
		_NumPedOri := ""
	EndIf
Return(_NumPedOri)

/*/{Protheus.doc} fGetEmp
//TODO Descrição auto-gerada.
@author zzz
@since 23/06/2017
@version undefined

@type function
/*/
User Function fGetEmp
	Local aAreaEmp := {}
	aAdd(aAreaEmp, SM0->(Recno()))
	aAdd(aAreaEmp, cFilAnt)
	aAdd(aAreaEmp, cNumEmp)
Return aAreaEmp


/*/{Protheus.doc} fRestEmp
//TODO Descrição auto-gerada.
@author zzz
@since 23/06/2017
@version undefined
@param aAreaEmp, array, descricao
@type function
/*/
User Function fRestEmp(aAreaEmp)
	Local aArea := GetArea()
	SM0->(dbGoTo(aAreaEmp[1]))
	cFilAnt := aAreaEmp[2]
	cNumEmp := aAreaEmp[3]

	RestArea(aArea)
Return


/*/{Protheus.doc} fGoEmp
//TODO Descrição auto-gerada.
@author zzz
@since 23/06/2017
@version undefined
@param cCodEmp, characters, descricao
@param cCodFil, characters, descricao
@type function
/*/
User Function fGoEmp(cCodEmp, cCodFil)
	Local aArea := GetArea()
	cCodFil := Padr(cCodFil, FWSizeFilial())
	cFilAnt := cCodFil
	If !SM0->(dbSeek(cCodEmp+cFilAnt))
		Final("Problema função U_fGoEmp(). Empresa: " + cCodEmp + " Filial: " + cCodFil)
	EndIf
	cNumEmp := FWCodEmp()+FWCodFil()

	RestArea(aArea)
Return


/*/{Protheus.doc} GetUmail
//TODO Encapsular a chamada para a função nativa(UsrRetMail)  
para tratar a condição onde o usuario não tiver e-mail cadastrado
neste caso deve devolver o e-mail padrão (wfti@cobrecom.com.br) .
@author Jef/Daniel/Leo
@since 03/09/16 
@version undefined
@param cUser, characters, descricao
@type function
/*/
User Function GetUmail(cUser)
	Local cEmail := ""

	cEmail := UsrRetMail(cUser)

	If Empty(cEmail)
		cEmail := "wfti@cobrecom.com.br"
	EndIf

Return (Alltrim(cEmail))

/*/{Protheus.doc} ZEmpD4
//TODO Utiliza EXECAuto para zerar empenhos em aberto com OP Encerrada.
@author juliana.leme
@since 29/09/2016
@version undefined

@type function
/*/
User Function ZEmpD4()
	Local cQuery := ""

	DbSelectArea("SD4")
	DbSetOrder(1)

	cQuery := "  SELECT D4_COD, " +;
	" D4_OP, " +;
	" D4_TRT, " +;
	" D4_LOCAL, " +;
	" D4_QTDEORI, " +;
	" D4_DATA, " +;
	" D4_QUANT " +;
	" FROM " + RetSqlName("SD4") +;
	" WHERE D4_QUANT <> 0 " +;
	" AND D4_QUANT > 10000 " +;
	" AND D_E_L_E_T_ = '' " +;
	" AND D4_FILIAL = '" + xFilial("SD4")+"' " +;
	" ORDER BY D4_DATA "

	If Select("TRBD4")>0
		DbSelectArea("TRBD4")
		DbCloseArea()
	EndIf

	cQuery := ChangeQuery(cQuery)
	TCQUERY cQuery NEW ALIAS "TRBD4"

	DbSelectArea("TRBD4")
	DbGotop()

	ProcRegua(LastRec())

	While !(Eof("TRBD4"))
		If (TRBD4->D4_QUANT > 0) .and. (TRBD4->D4_DATA <= '20191231')
			//Utilize o seguinte comando:
			aVetor:={{"D4_COD"		,TRBD4->D4_COD		,NIL},;
			{"D4_OP"		,TRBD4->D4_OP		,NIL},;
			{"D4_TRT"		,TRBD4->D4_TRT		,NIL},;
			{"D4_LOCAL"		,TRBD4->D4_LOCAL	,NIL},;
			{"D4_QTDEORI"	,TRBD4->D4_QTDEORI	,NIL},;
			{"D4_QUANT"		,TRBD4->D4_QUANT	,NIL},;
			{"ZERAEMP"		,"S"				,NIL}} //Zera empenho do processo de assistencia

			lMSHelpAuto := .T.
			lMSErroAuto := .F.
			MSExecAuto({|x,y| MATA380(x,y)},aVetor,4)
			If lMSErroAuto
				//MostraErro()
			EndIf
		EndIf
		IncProc()
		TRBD4->(DBSkip())
	EndDo
Return


/*/{Protheus.doc} DiffDay
@author bolognesi
@since 10/03/2017
@version undefined
@param dData1, date, Primeira data do calculo
@param dData2, date, Segunda data do calculo
@param lUteis, logical, Indica se considera somente dias uteis( .T. ) ou dias corridos( .f. ) default( .T. )
@type function
@description Retorna a diferença de dias entre duas datas.
Considera a tabela 63(SX5) e ZV(SX5), os sabados caso MV_SABFERI = 'S' 
e os domingos como sendo feriados.
03/05/17-Alterado para não considerar o dia atual na conta
/*/
user function DiffDay(dData1, dData2, lUteis ) 
	/*TEST_ZONE
	//u_DiffDay( StoD('20170303'),StoD('20170310') ) 		OK = 5
	//u_DiffDay( StoD('20170310'),StoD('20170303') ) 		OK = 5
	//u_DiffDay( StoD('20170303'),StoD('20170310'), .F. ) 	OK = 7
	//u_DiffDay( StoD('20171120'),StoD('20171122'), .F. ) 	OK = 2
	//u_DiffDay( StoD('20171120'),StoD('20171122') ) 		OK = 2
	//u_DiffDay( StoD('20171120'),StoD('20171120') )		OK = 0
	//u_DiffDay( StoD('20170503'),StoD('20170510') )		OK = 5
	//u_DiffDay( StoD('20170503'),StoD('20170510'), .F. )	OK = 7
	//u_DiffDay( StoD('20170614'),StoD('20170616') )		OK = 1
	//u_DiffDay( StoD('20171011'),StoD('20171011') )		OK = 0
	//u_DiffDay( StoD('20170505'),StoD('20170509') )		OK = 2
	//u_DiffDay( StoD('20170428'),StoD('20170501') )		OK = 0
	*/
	local nResult 	:= 0
	local dDe		:= ""
	local dAt		:= ""
	local dNx		:= ""
	local oSql 		:= nil
	local cZV		:= ""

	default dData1 	:= ""
	default dData2	:= ""
	default lUteis	:= .T.

	if !empty(dData1) .and. !empty(dData2)
		if valtype(dData1) == 'D' .and. valtype(dData2) == 'D'

			if dData1 > dData2
				dDe := if(lUteis ,DaySum(dData2, 1), dData2) 
				dAt	:= dData1
			else
				dDe := if (lUteis ,DaySum(dData1, 1), dData1)
				dAt	:= dData2
			endif

			if lUteis
				oSql := LibSqlObj():newLibSqlObj()
				while dDe <= dAt 
					if Datavalida(dDe, .T. ) == dDe
						cZV := oSql:getFieldValue("SX5", "X5_CHAVE",;
						"%SX5.XFILIAL% AND X5_TABELA = 'ZV' AND SUBSTRING(X5_DESCRI,1,8) ='" + DtoS(dDe) + "'")

						if empty(cZV)
							nResult ++
						endif			
					endif 
					dDe := DaySum(dDe, 1)
				enddo
				FreeObj(oSql)
			else
				nResult := DateDiffDay(dDe,dAt)
			endif
		endif
	endif 
return(nResult)

/*/{Protheus.doc} exSendMa
@author bolognesi
@since 13/03/2017
@version 1.0
@param aTo, characters, Array com os endereços destino email
@param cAssunto, characters, Assunto email
@param cBody, characters, Corpo do email
@type function
@description Função de exemplo para utilizar a classe cbcSchCtrl
para enviar os emails, exemplo simples de utilização, para exemplo
que utilize layouts html externos, consultar fonte cbcSchCtrl.prw 
function zSchMng() (FUNÇÂO ENVIAR EMAIL)
/*/
user function exSendMa(aTo, aCC, cAssunto, cBody)
	//U_exSendMa('leonardo@cobrecom.com.br',,'Assunto Email','Corpo Email')
	//U_exSendMa({leonardo@cobrecom.com.br, leonardonhesi@gmail.com},,'Assunto Email Outro','Corpo Email Outro')
	local oSch 			:= cbcSchCtrl():newcbcSchCtrl()
	local nX			:= 0
	default aTo			:= {'wfti@cobrecom.com.br'}
	default aCC			:= {}
	default cAssunto	:= 'Assunto de teste'
	default cBody		:= 'Corpo teste'

	oSch:setIDEnvio('TESTE')

	if Valtype(aTo) == 'A'
		for nX := 1 to len(aTo)
			oSch:addEmailTo( aTo[nX] )
		next nX 
	elseif Valtype(aTo) == 'C' 
		oSch:addEmailTo( aTo )
	endif

	if Valtype(aCC) == 'A'
		for nX := 1 to len(aCC)
			oSch:addEmailCc( aCC[nX] )
		next nX 
	elseif Valtype(aCC) == 'C' 
		oSch:addEmailCc( aCC )
	endif

	oSch:setAssunto(cAssunto)
	oSch:setBody(cBody)
	oSch:schedule()

	FreeObj(oSch)

return(nil)

/*/{Protheus.doc} ValidEst
//TODO Validação do Estoque.
@author juliana.leme
@since 30/05/2017
@version undefined

@type function
/*/
User Function ValidEst()    
	Local cMens		:= ""
	Local lRet		:= .T.
	Local nEstoq	:= 0
	Local nReserv	:= 0
	Local nPedVen	:= 0
	Local nPedAtu	:= 0
	Local cTipoProd	:= "PA"

	If AllTrim(FunName()) == "MATA410"
		lRet      	:= .T.
		cMens		:= "" 
		nEstoq		:= POSICIONE("SB2",1,XFILIAL("SB2")+BUSCACOLS("C6_PRODUTO")+BUSCACOLS("C6_LOCAL"),"SB2->B2_QATU")
		nReserv 	:= POSICIONE("SB2",1,XFILIAL("SB2")+BUSCACOLS("C6_PRODUTO")+BUSCACOLS("C6_LOCAL"),"SB2->B2_RESERVA")
		nPedVen 	:= POSICIONE("SB2",1,XFILIAL("SB2")+BUSCACOLS("C6_PRODUTO")+BUSCACOLS("C6_LOCAL"),"SB2->B2_QPEDVEN")
		nPedAtu 	:= BUSCACOLS("C6_QTDVEN")
		cTipoProd	:= POSICIONE("SB1",1,XFILIAL("SB1")+BUSCACOLS("C6_PRODUTO"),"SB1->B1_TIPO")

		If GetMv("MV_ESTNEG") == "N" .AND. !(cTipoProd == "PA") 
			If SF4->F4_ESTOQUE == "S"
				If (nEstoq - nReserv - nPedVen) < nPedAtu
					lRet := .F.
					cMens := "Quantidade em estoque insuficiente para Pedido de Vendas: " +CHR(13)+CHR(13)+CHR(13)
					cMens += "Quantidade do Pedido "+ TRANSFORM(nPedAtu,"@E 99,999,999.99")+CHR(13)+CHR(13)
					cMens += "___________________________________________"+CHR(13)+CHR(13)
					cMens += "Quantidade Estoque            "+ TRANSFORM(nEstoq,"@E 99,999,999.99")+CHR(13)+CHR(13)
					cMens += "(-) Pedidos Lançados (Bloq.) "+ TRANSFORM(nPedVen,"@E 99,999,999.99")+CHR(13)+CHR(13)
					cMens += "(-) Pedidos Lançados (Liber.) "+ TRANSFORM(nReserv,"@E 99,999,999.99")+CHR(13)+CHR(13)
					cMens += "___________________________________________"+CHR(13)+CHR(13)
					cMens += "(=) Quantidade Disponível     "+ TRANSFORM(nEstoq - nReserv - nPedVen,"@E 99,999,999.99")
					U_autoAlert(cMens)
				EndIf
			EndIf
		EndIf
	EndIf
Return (lRet)		

/*/{Protheus.doc} TraMata
//TODO Função que executa automatica o MATA261 (Req.Mod.1) Obs.: nMyOpcao = 3-Inclusão 5-Estorno.
@author juliana.leme
@since 28/07/2016
@version 1.0
@param cProduto,	Caracter, Produto da transferencia
@param cLocalOri,	Caracter, Local Origem do produto
@param cLocalDest,	Caracter, Local Destino do produto
@param nQtde,		Numerico, Quantidade a ser transferida
@param cDoc,		Caracter, Numero do Doc a ser gravado no D3_DOC
@param cAcondOri,	Caracter, Acondicionamento Origem para endereçamento
@param cAcondDest,	Caracter, Acondicionamento Destino para endereçamento
@type function
/*/
User Function CBCTraMata(cProduto,cLocalOri,cLocalDest,nQtde,cDoc,cAcondOri,cAcondDest)
	Local	aItens		:= 	{}
	Local	_ErroTransf	:= .F.
	Local 	oExec 		:= nil 
	Local	aRet		:= {}
	
	
	aAdd(aItens,{Padr(Alltrim(cDoc),TamSX3("D3_DOC")[1]),dDataBase})

	aAdd(aItens,{Padr(Alltrim(cProduto),TamSX3("D3_COD")[1]),; 		//cProduto,;
	Posicione("SB1",1,xFilial("SB1")+Alltrim(cProduto),"B1_DESC"),;	//cDescProd,;
	Posicione("SB1",1,xFilial("SB1")+Alltrim(cProduto),"B1_UM"),; 	//cUM Origem
	cLocalOri,;														//cArmOri Origem
	cAcondOri,;														//cEndOri Origem
	Padr(cProduto,TamSX3("D3_COD")[1]),;							//cProduto,;
	Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_DESC"),;			//cDescProd,;
	Posicione("SB1",1,xFilial("SB1")+cProduto,"B1_UM"),; 			//cUM Origem
	cLocalDest,;													//cArmDest Destino
	cAcondDest,;													//cEndDest Destino,;
	"",;															//cNumSer Num Serie
	"",;															//cLote
	"",;															//SubLote
	StoD(""),;														//cValidade
	0,;																//nPoten
	Round(ABS(nQtde),4),;											//nQuant
	0,;																//cQtSegUm
	"",;															//Estornado
	"",;						   									//cNumSeq
	"",; 															//cLoteDest
	StoD(""),;														//cValDest
	"",;															//ItemGrade
	""})                                                            	//OBSERVA (D3_OBSERVA)
	
	/* 
	//SUBSTITUICAO DO EXECAUTO PADRAO POR EXECAUTO DA CLASSE
	lMsErroAuto 	:= .F.

	MSExecAuto({|x,y| mata261(x,y)},aItens,3)
	*/
	
	oExec := cbcExecAuto():newcbcExecAuto(aItens,/*aHdr*/,.T.)
	oExec:exAuto('MATA261',3)
	aRet := oExec:getRet()
	
	
	
	//If lMsErroAuto //MostraErro()
	if !aRet[1]
		_ErroTransf := .T.
	Else
		_ErroTransf := .F.
	EndIf

Return(_ErroTransf)

/*/{Protheus.doc} isInStr
@author bolognesi
@since 05/07/2017
@version 1.0
@param cStrNor, characters, String simples que deverá ser procurada
@param cStrEsp, characters, String com elementos separados
@param cSepar, characters, Separador utilizado na cStrEsp (default: ;)
@type function
@description Função utilizada para retornar logico, a respeito da existencias
de uma string normal em uma string com elementos separados.
@example U_isInStr('05', '01;04;03;05;02', ';') retorno .T.
/*/
user function isInStr(cStrNor, cStrEsp, cSepar)
	local lRet 		:= .F.
	local aStrEsp	:= {}
	local nPos		:= 0
	default cSepar	:= ';'
	if !empty(cStrNor) .and. !empty(cStrEsp)
		aStrEsp := StrTokArr(cStrEsp, cSepar)
		if (AScan(aStrEsp,{|a| Alltrim(a) == Alltrim(cStrNor) })) > 0
			lRet := .T.
		endif
	endif
return(lRet)

/*/{Protheus.doc} zIs12
@author bolognesi
@since 24/07/2017
@version 1.0
@type function
@description Verifica se a versão atual é a 12
/*/
user function zIs12()
return(Alltrim(cVersao) == '12')

/*/{Protheus.doc} zGetTpBob
@author bolognesi
@since 22/08/2017
@version 1.0
@param cTipoBob, characters, String contendo especificação bobina
@type function
@description Retorna o numero da bobina a partir de uma especificação de bobina
como 65/45
/*/
user function zGetTpBob(cTipoBob)
	local cRetBob := ''
	default cTipoBob = ''
	if !empty(cTipoBob)
		cTipoBob := Alltrim(cTipoBob)
		if Alltrim(cTipoBob) = "65/25"
			cRetBob := "1"
		elseIf Alltrim(cTipoBob) = "65/45"
			cRetBob := "2"
		elseIf Alltrim(cTipoBob) = "80/45"
			cRetBob := "3"
		elseIf Alltrim(cTipoBob) = "100/60"
			cRetBob := "4"
		elseIf Alltrim(cTipoBob) = "125/70"
			cRetBob := "5"
		elseIf Alltrim(cTipoBob) = "150/80"
			cRetBob := "6"
		elseIf Alltrim(cTipoBob) = "170/80"
			cRetBob := "7"
		endIf
	endif
return(cRetBob)

user Function getNamePack(cCod)
	Local cNome := ""
	Local aMtr	:= {}
	Local nPos	:= 0
	Local cVld	:= 'B//R//C//M//L//'
	Default cCod	:= ""
	If !Empty(cCod) 
		If cCod $ cVld 
			Aadd(aMtr,{'B','BOBINA'})
			Aadd(aMtr,{'R','ROLO'})
			Aadd(aMtr,{'C','CARRETEL PLASTICO'})
			Aadd(aMtr,{'M','CARRETEL MADEIRA'})
			Aadd(aMtr,{'L','BLISTER'})
			nPos := AScan(aMtr,{|a| a[1] == cCod })
			If nPos > 0
				cNome := aMtr[nPos][2]
			EndIf
		EndIf
	EndIf
Return(cNome)


User function GrvZZ1(aCliLoja,cCpoName, aOldNew, cOper, cUsrObs )
	
	local aArea 	:= GetArea()	
	local aAreaSA1	:= SA1->(GetArea())
	local cObs		:= ''
	local lAltera	:= .F.
	local lInclui	:= .F.
	default cUsrObs := ''
	
	if cOper == 'Alterar'
		lAltera := .T.
	elseif cOper == 'Incluir'
		lInclui := .T.
	endif
	
	DbSelectArea("ZZ1")
	if RecLock("ZZ1",.T.)
		ZZ1->ZZ1_FILIAL := xFilial("ZZ1")
		ZZ1->ZZ1_UNID   := CriaVar("ZZ1_UNID")
		ZZ1->ZZ1_DATA   := Date()
		ZZ1->ZZ1_HORA   := Left(Time(),Len(ZZ1->ZZ1_HORA))
		ZZ1->ZZ1_USUARI := CriaVar("ZZ1_USUARI")
		ZZ1->ZZ1_CLIENT := aCliLoja[1]
		ZZ1->ZZ1_LOJA   := aCliLoja[2]
		ZZ1->ZZ1_NOME   := Posicione("SA1",1,xFilial("SA1")+aCliLoja[1]+aCliLoja[2],"A1_NOME")
		ZZ1->ZZ1_TPINVE := If(lInclui,"04",If(lAltera,"05","06"))
		ZZ1->ZZ1_DESCIN := Posicione("SX5",1,xFilial("SX5")+"ZL"+ZZ1->ZZ1_TPINVE,"X5_DESCRI")
		if lAltera
			cObs := "Alterado campo " + cCpoName + " de " + aOldNew[1] + " para " + aOldNew[2]
			ZZ1->ZZ1_HIST := cObs + ' - ' + cUsrObs
		endif
		MsUnLock()
	endif
	
	RestArea(aAreaSA1)
	RestArea(aArea)

return(nil)


/*/{Protheus.doc} TraMata
//TODO Função que executa automatica o MATA261 (Req.Mod.1) Obs.: nMyOpcao = 3-Inclusão 5-Estorno.
@author juliana.leme
@since 28/07/2016
@version 1.0
@param cProduto,	Caracter, Produto da transferencia
@param cLocalOri,	Caracter, Local Origem do produto
@param cLocalDest,	Caracter, Local Destino do produto
@param nQtde,		Numerico, Quantidade a ser transferida
@param cDoc,		Caracter, Numero do Doc a ser gravado no D3_DOC
@param cAcondOri,	Caracter, Acondicionamento Origem para endereçamento
@param cAcondDest,	Caracter, Acondicionamento Destino para endereçamento
@type function
/*/
User Function CBCTraProdI(cProdOri,cProdDes,cLocalOri,cLocalDest,nQtde,cDoc,cAcondOri,cAcondDest)
	Local	aItens		:= 	{}
	Local	_ErroTransf	:= .F.
	Local 	oExec 		:= nil 
	Local	aRet		:= {}

	
	Begin Transaction
		//Analise se Produto existe no Armaazem de Destino
		DBSelectArea("SB2")
		SB2->(DbSetOrder(1))
		If !SB2->(DbSeek(xFilial("SB2")+Padr(cProdDes,TamSX3("D3_COD")[1])+cLocalDest,.F.))
			CriaSB2(Padr(cProdDes,TamSX3("D3_COD")[1]),cLocalDest)
		EndIf
	
		//Libera Qtde a Transferir SBF
		DbSelectArea("SBF")
		SBF->(DbSetOrder(1)) //BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
		If SBF->(DbSeek(xFilial("SBF")+"01"+cAcondOri+cProdOri,.F.)) //BF_FILIAL+SBF->(BF_LOCAL+BF_LOCALIZ+BF_PRODUTO)+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
			If SBF->BF_EMPENHO >= 0 // Dá pra fazer alguma liberação?
				Reclock("SBF",.F.)
				SBF->BF_EMPENHO := If((SBF->BF_EMPENHO - nQtde) >=0 ,(SBF->BF_EMPENHO - nQtde),0) 
				MsUnLock()
			EndIf
		EndIf
		
		//Libera Qtde a Transferir SBF
		DbSelectArea("SB2")
		SB2->(DbSetOrder(1))//B2_FILIAL+B2_COD+B2_LOCAL
		If DbSeek(xFilial("SB2")+cProdOri+cLocalOri,.F.)
			RecLock("SB2",.F.)
			SB2->B2_RESERVA := If((SB2->B2_RESERVA - nQtde) >=0 ,(SB2->B2_RESERVA - nQtde),0) 
			MsUnLock()
		EndIf
	
		aAdd(aItens,{Padr(Alltrim(cDoc),TamSX3("D3_DOC")[1]),dDataBase})
	
		aAdd(aItens,{Padr(Alltrim(cProdOri),TamSX3("D3_COD")[1]),; 		//cProduto,;
		Posicione("SB1",1,xFilial("SB1")+Alltrim(cProdOri),"B1_DESC"),;	//cDescProd,;
		Posicione("SB1",1,xFilial("SB1")+Alltrim(cProdOri),"B1_UM"),; 	//cUM Origem
		cLocalOri,;														//cArmOri Origem
		cAcondOri,;														//cEndOri Origem
		Padr(cProdDes,TamSX3("D3_COD")[1]),;							//cProduto,;
		Posicione("SB1",1,xFilial("SB1")+cProdDes,"B1_DESC"),;			//cDescProd,;
		Posicione("SB1",1,xFilial("SB1")+cProdDes,"B1_UM"),; 			//cUM Origem
		cLocalDest,;													//cArmDest Destino
		cAcondDest,;													//cEndDest Destino,;
		"",;															//cNumSer Num Serie
		"",;															//cLote
		"",;															//SubLote
		StoD(""),;														//cValidade
		0,;																//nPoten
		Round(ABS(nQtde),4),;											//nQuant
		0,;																//cQtSegUm
		"",;															//Estornado
		"",;						   									//cNumSeq
		"",; 															//cLoteDest
		StoD(""),;														//cValDest
		"",;															//ItemGrade
		""})                                                            //Observação
	
		
		oExec := cbcExecAuto():newcbcExecAuto(aItens)
		oExec:exAuto('MATA261',3)
		// MSExecAuto({|x,y| mata261(x,y)},aItens,3)
		aRet := oExec:getRet()
		
		if !aRet[1]
			_ErroTransf := .T.
			Alert('ERRO: ' + aRet[2] )
		else
			_ErroTransf := .F.
		endif
		FreeObj(oExec)
	
	End Transaction
Return(_ErroTransf)


/*/{Protheus.doc} zGetDtVl
@author bolognesi
@since 02/02/2018
@version 1.5
@param dDataIn, date, data a ser verificada
@param lNext, logico, Se .T. posterga a data recebida para o próximo dia últil -
Se .F. retrocede a data recebida para o dia últil anterior, Default .T.
@type function
@description Função que verifica se uma data é valida de acordo com os feriados
do sistema e tabela personalizada(cobrecom) SX5(ZV).
* Inicia a comparação com a dDataIn, e a partir dela retorna uma data valida
caso ela seja valida o retorno será a propria data.
* O retorno consiste em um array com um logico e uma data valida
/*/
user function zGetDtVl(dDataIn, lNext)
/*
	u_zGetDtVl(StoD('20171225') ) = { .F., 26/12/17, {} }
	u_zGetDtVl(StoD('20180210') ) = { .F., 14/02/18, {12/02/18=DATA NAO PRODUTIVA COMPENSACAO CARNAVAL, 13/02/18=DATA NAO PRODUTIVA CARNAVAL}}
	u_zGetDtVl(StoD('20180212') ) = { .F., 14/02/18, {12/02/18=DATA NAO PRODUTIVA COMPENSACAO CARNAVAL, 13/02/18=DATA NAO PRODUTIVA CARNAVAL} }
	u_zGetDtVl(StoD('20180213') ) = { .F., 14/02/18, {13/02/18=DATA NAO PRODUTIVA CARNAVAL} }
	u_zGetDtVl(StoD('20180214') ) = { .T., 14/02/18, {} }
	u_zGetDtVl(StoD('20180215') ) = { .T., 15/02/18, {} }
	u_zGetDtVl(StoD('20181224') ) = { .F., 26/12/18, {24/12/18=DATA NAO PRODUTIVA} }
	u_zGetDtVl(StoD('20181231') ) = { .F., 02/01/19, {31/12/18=DATA NAO PRODUTIVA} }
	u_zGetDtVl(StoD('20181120') ) = { .F., 02/01/19, {20/11/18=DIA DA CONSCIENCIA NEGRA} }
	u_zGetDtVl(StoD('20180213'), .F. ) = { .F., 09/02/18, {13/02/18=DATA NAO PRODUTIVA CARNAVAL, 12/02/18=DATA NAO PRODUTIVA COMPENSACAO CARNAVAL} }
*/
	local lVld		:= .F.
	local aDescFer	:= {}
	local aTmpDesc	:= {}
	local oSql   		:= nil
	local cFeriado	:= ''
	local cDtAux		:= Date()
	local nX			:= 0
	default dDataIn	:= Date()
	default lNext		:= .T.
	
	cDtAux 	:= dDataIn
	oSql 	:= LibSqlObj():newLibSqlObj()	
	dDataIn 	:= DataValida(dDataIn, lNext)
	while ! empty(cFeriado := oSql:getFieldValue('SX5', 'X5_DESCRI',;
			"%SX5.XFILIAL%  AND X5_TABELA = 'ZV'  AND SUBSTRING(X5_DESCRI,1,8) ='" +;
			DtoS(dDataIn) + "'"))
		
		aTmpDesc := StrTokArr(cFeriado, '-')
		aadd(aDescFer,{ StoD(aTmpDesc[1]), '' }  )
		for nX := 2 to Len(aTmpDesc)
			aDescFer[len(aDescFer),2] += Alltrim(aTmpDesc[nX]) + ' '
		next nX
		
		if lNext
			dDataIn := DataValida(DaySum(dDataIn, 1), lNext)
		else
			dDataIn := DataValida(DaySub(dDataIn, 1), lNext)
		endif
	enddo
	FreeObj(oSql)
	lVld := (dDataIn == cDtAux )
return( {lVld,dDataIn, aDescFer} )
 
 /*/{Protheus.doc} CarSRARH
//TODO Monta Tabela temporaria do SRA do banco RH.
@author juliana.leme
@since 27/07/2018
@version 1.0

@type function
/*/
User Function CarSRARH()
 	Local _aArea 	   			:= GetArea()
	Local _nMod		   			:= "07"
	Local _cQuery				:= ""
	Local lRet					:= .T.
	Local TRBSRA
	Private oApp_Ori
	Private oApp_Ori2
	Private nHndErp				:= AdvConnection()
	Private nPrtConn			:= GetNewPar("ZZ_PORTADB", "7890")	// Porta
	Private nHndConn				//Handler do banco de dados de integração
	
	Private cDB_RH 		:= GetMV("ZZ_HNDRH") //"MSSQL/PCF_Integ"	//Tipo e nome do banco de integração (PC-Factory) (OFICIAL)
	Private cSrvRH 		:= GetMV("ZZ_SRVRH") //"192.168.3.2"		//Servidor onde está o banco de integração (OFICIAL)

	// Cria uma conexão com um outro banco, outro DBAcces
	nHndConn := TcLink(cDB_RH,cSrvRH,nPrtConn)
	//Conecta com PPI
	TcSetConn(nHndConn)
	//Caso a conexão não seja realizada
	If nHndConn < 0
		Alert("Falha ao conectar com " + cDB_RH + " em " + cSrvRH + ":" + Str(nPrtConn,4))
		TcUnLink(nHndConn)
	Else
		TcSetConn(nHndERP)
		DbCloseArea()

		TcSetConn(nHndConn)
		DbCloseArea()
		TcUnLink(nHndConn)
		
		_cQuery :=" SELECT * "+;
						" FROM SRA010 "+;
						" WHERE D_E_L_E_T = '' "+;
						" ORDER BY RA_FILIAL, RA_MAT"

		_cQuery := ChangeQuery(_cQuery)

		If Select("TRBSRA")>0
			DbSelectArea("TRBSRA")
			DbCloseArea()
		EndIf

		TCQUERY _cQuery NEW ALIAS "TRBSRA"

		DbSelectArea("TRBSRA")
		DbGotop()

		If TRBSRA->(!Eof())
			lRet := .T.
		Else
			lRet := .F. //Não possui registros
		EndIf
	EndIf
 Return(lRet,TRBSRA)
 
 
 /*/{Protheus.doc} zGetRate
@type function
@author bolognesi
@since 23/07/2018
@version 1.0
@description Obtem para uma moeda a taxa da maior data disponivel.
/*/
user function zGetRate(nMoeda)
	local aArea		:= {}
	local aArM2		:= {}
	local oSql 		:= nil
	local nRate		:= 1
	local cQry		:= ''
	local nPos		:= 0
	local aCond		:= {} 
	default nMoeda 	:= 1
	
	aArea		:= GetArea()
	aArM2		:= SM2->(GetArea())
	aadd(aCond,{2,' M2_MOEDA2 > 0 ','M2_MOEDA2'})
	aadd(aCond,{3,' M2_MOEDA3 > 0 ','M2_MOEDA3'})
	
	oSql := LibSqlObj():newLibSqlObj()
	
	cQry += " SELECT "
	cQry += " MAX(R_E_C_N_O_) AS ID "
	cQry += " FROM  %SM2.SQLNAME% "
	cQry += " WHERE "
	
	if (nPos := aScan(aCond,{|a| a[1] == nMoeda})) > 0
		cQry += aCond[nPos,2]
		cQry += " AND %SM2.NOTDEL% "
		oSql:newAlias(cQry)
		if oSql:hasRecords()
			oSql:goTop()
			DbSelectArea('SM2')
			SM2->(DbGoTo(oSql:getValue("ID")))
			nRate := SM2->(&(aCond[nPos,3]))
		endif
	endif
	
	oSql:Close()
	FreeObj(oSql)
	RestArea(aArea)
	RestArea(aArM2)	
return(nRate)

/*/{Protheus.doc} CBCRetInd
//TODO Retorna Pedido de Amarração entre filiais caso exista.
@author juliana.leme
@since 27/07/2018
@version 1.0
@return ${return}, ${return_description}
@param _cFilialCB, , descricao
@param _cPedi, , descricao
@type function
/*/
User Function CBCRetInd(_cFilialCB,_cPedi)
	Local cQuery		:= ""
	Local _NumPedOri	:= ""

	cQuery := " SELECT DISTINCT "
	cQuery += "    SUBSTRING(C6_ZZPVORI,1,6) PVORIG "
	cQuery += " FROM SC6010 "
	cQuery += " WHERE "
	cQuery += "    C6_FILIAL			= '"+ _cFilialCB + "' "
	cQuery += "    AND C6_NUM		= '" + _cPedi + "' "
	cQuery += "    AND C6_ZZPVORI	<> '' "
	cQuery += "    AND SC6010.D_E_L_E_T_	= '' "
	
	cQuery := ChangeQuery(cQuery)
					
	If Select("TRBCBCIND")>0
		DbSelectArea("TRBCBCIND")
		DbCloseArea()
	EndIf
					
	TCQUERY cQuery NEW ALIAS "TRBCBCIND"
					
	DbSelectArea("TRBCBCIND")
	DbGotop()
					
	If !Empty(Alltrim(TRBCBCIND->PVORIG))
		_NumPedOri := " (Ped.Ind.: " + TRBCBCIND->PVORIG+")"
	Else
		_NumPedOri := ""
	EndIf
Return (_NumPedOri)

/*/{Protheus.doc} fWhereMn
//TODO Retorna Qual Unidade Fabril o Produto relacionado é fabricado.
@author juliana.leme
@since 06/08/2018
@version 1.0

@type function
/*/
User Function fWhereMn(cProd)
	Local cUndFab := ""
	
	If !Empty(Alltrim(cProd))
		cUndFab := Posicione("SB1",1,xFilial("SB1")+Alltrim(cProd),"B1_ZZFILFB")
	Else
		cUndFab := ""
	EndIf
Return(cUndFab)

user function RetTRBCol(aArqTrab)
	local aColunas 	:= {}
	local nX		:= 1
	local nFld		:= 1
	
	RestArea(aArqTrab)
	dbSelectArea("TRB")
	TRB->(DbGoTop())
	nFld := TRB->(FCount())
	for nX := 1 to nFld
		aadd(aColunas,TRB->(FieldName(nX)))
	next nX
	aColunas := {aColunas}
return(aColunas)

user function RetTRBReg(aArqTrab)
	local aRegistros 	:= {}
	local aRet1   		:= Array(fcount())
	local nRegAtu 		:= 1
	
	RestArea(aArqTrab)
	dbSelectArea("TRB")
	TRB->(DbGoTop())
	While !eof()
		For x:=1 to fcount()
			aRet1[x] := FieldGet(x)
		Next
		aadd(aRegistros,aclone(aRet1))
		DbSkip()
		nRegAtu += 1
	enddo
	aRegistros := {aRegistros}
return(aRegistros)

user function pedTriangMG(cCbcfil, cPediOri, cItemOri)
	local aDadosPedMG 	:= {}, aRetorno := {}
	local cQuery		:= ""
	
	cQuery := " SELECT SC601.C6_NUM + SC601.C6_ITEM " 				+ linha
	cQuery += " FROM SC6010 SC601 " 								+ linha
	cQuery += " WHERE  SC601.C6_FILIAL = '" + FwFilial() + "' "		+ linha
	cQuery += " AND C6_NUMPCOM + C6_ITEMPC = ( " 					+ linha
	cQuery += " 	SELECT SC602.C6_NUMPCOM + SC602. C6_ITEMPC " 	+ linha
	cQuery += " 		FROM SC6010 SC602 "							+ linha
	cQuery += " 		INNER JOIN SC5010 SC5 "						+ linha
	cQuery += " 			ON SC5.C5_FILIAL = SC602.C6_FILIAL "	+ linha
	cQuery += " 			AND SC5.C5_NUM = SC602.C6_NUM "			+ linha
	cQuery += " 			AND SC5.D_E_L_E_T_ = SC602.D_E_L_E_T_ "	+ linha
	cQuery += " 		WHERE  C6_FILIAL	= '" + cCbcfil  + "' "	+ linha
	cQuery += " 		AND C6_NUM			= '" + cPediOri	+ "' "	+ linha
	cQuery += " 		AND C6_ITEM			= '" + cItemOri	+ "' "	+ linha
	cQuery += " 		AND C5_X_IDVEN		<> '' "					+ linha
	cQuery += " 		AND C6_ZZPVORI		= ''  "					+ linha
	cQuery += " 		AND SC602.D_E_L_E_T_= '' ) "				+ linha
	cQuery += " 		AND SC601.D_E_L_E_T_ = '' "					+ linha

	aDadosPedMG	:= u_qryarr(cQuery) //Obtem Array com resultado da Query
	if empty(aDadosPedMG)
		aRetorno	:= {.F.,""}
	else
		aRetorno := {.T.,Alltrim(aDadosPedMG[1,1])}
	endif
return(aRetorno)


user function xIsInspe(cPed)
	local oSql 		as object
	local xRet      as logical
	local cCampo    as character
	local cQry		as character
	local aArea		:= {}
	local aArZL		:= {}
	local aArZE		:= {}
	default cPed 	:= ''

	aArea	:= GetArea()
	aArZL	:= SZL->(GetArea())
	aArZE	:= SZE->(GetArea())
	xRet    := .F.
	cCampo  := ''
	cQry    := ''
	if !empty(cPed)
	  oSql := LibSqlObj():newLibSqlObj()
	  cQry += " SELECT "
	  cQry += " SC5.C5_ZZINSPE AS PED_INSPE , "
	  cQry += " SA1.A1_ZZINSPE AS CLI_INSPE " 
	  cQry += " FROM SC5010 SC5 "
	  cQry += " INNER JOIN SA1010 SA1 " 
	  cQry += " ON ''               = SA1.A1_FILIAL "
	  cQry += " AND SC5.C5_CLIENTE  = SA1.A1_COD "
	  cQry += " AND SC5.C5_LOJACLI  = SA1.A1_LOJA "
	  cQry += " AND SC5.D_E_L_E_T_  = SA1.D_E_L_E_T_ "
	  cQry += " WHERE C5_FILIAL     = '" + FwFilial() + "'"
	  cQry += " AND C5_NUM          = '" + cPed + "'"
	  cQry += " AND SC5.D_E_L_E_T_  = '' "
	  oSql:newAlias(cQry)
	  if oSql:hasRecords()
		oSql:goTop()
		cCampo := oSql:getValue("Alltrim(PED_INSPE)")
		xRet := ("S" $ cCampo)
	  endif
	  oSql:Close()
	  FreeObj(oSql)	
	endif
	RestArea(aArZL)	
	RestArea(aArZE)
	RestArea(aArea)
return({xRet,cCampo})
