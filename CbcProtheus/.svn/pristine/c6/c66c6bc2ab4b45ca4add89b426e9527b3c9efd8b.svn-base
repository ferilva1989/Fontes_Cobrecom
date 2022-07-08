//Bibliotecas
#Include "Protheus.ch"
#include "tbiconn.ch" 

//Constantes
#Define CLR_AZUL      	RGB(058,074,119)									//Cor Azul
#Define NOME_ROTINA			1
#Define PARAMETRO_ADM		2
#Define PARAMETRO_USR   	3
#Define BLOCO_CODIGO_VLD   	4
#Define ROTINA_SELECIONADA 	1
#Define VALIDACAO_USUARIO	4
#Define GRP_VENDAS_GESTAO	'000039'
#Define GRP_FISCAL			'000016'
#Define GRP_DBLQMO			'000111'
#Define GRP_PCP_PRZENTR		'000112'
#Define GRP_ENGENHARIA		'000017'
#Define GRP_MULTIFIL		'000121'

//Variaveis
Static COL_T1 	:= 001				//Primeira Coluna da tela
Static COL_T2 	:= 123				//Segunda Coluna da tela
Static COL_T3 	:= 245				//Terceira Coluna da tela
Static COL_T4 	:= 367				//Quarta Coluna da tela
Static ESP_CAMPO	:= 038				//Espaçamento do campo para coluna
Static TAM_FILIAL	:= FWSizeFilial()	//Tamanho do campo Filial

/********************** Configuração dos Parametros ***************************/
/*/{Protheus.doc} callCSX6
//TODO Descrição auto-gerada.
@author bolognesi
@since 11/11/2016
@version 1.0
@type function
@description Função para associar parametros com rotinas e (Usuario x Administradores) bem como
chamar a função que edita os parametros
/*/
User Function callCSX6() //U_callCSX6()
	Local aRotina 	:= {}
	Local aCtrRot	:= {}
	Local aParams	:= {}
	Local aParamBox	:= {}
	Local nX		:= 0
	Local aRet 		:= {}
	Local lAdm		:= .F.
	
	//Aqui deve-se associar um nome de rotina ou grupo de parametros e definir
	//Quais destes parametro são visiveis aos administradores e quais aos Usuarios
	//{"NOME_ROTINA",{"ARRAY PARAMETROS ADM"}, {"ARRAY PARAMETRO USUARIO"}, Bloco Codigo Validar Usuario }
	AAdd(aCtrRot, { "Espelho do Pedido"		,{"MV_SNESPED","MV_CONTAES","MV_SENHAES","MV_ZMAILEN"},{"MV_SNESPED","MV_ZMAILEN"}, {|| vldGrp({GRP_VENDAS_GESTAO}) } } )
	AAdd(aCtrRot, { "Dados Email WF"		,{"MV_RELACNT","MV_RELPSW","MV_RELSERV","MV_EMCONTA","MV_EMSENHA", "MV_EMGRPTI","XX_ERRMAIL","MV_RELSSL","MV_RELTLS"},{} } )
	AAdd(aCtrRot, { "Industrialização"		,{"MV_VLRPED","MV_DBGINDL","MV_ZZLCIND","MV_PVDIVID","MV_MAILAPR","MV_ZZTRANS","MV_ZZFRIND","MV_ZZINDLB"},{}	})
	AAdd(aCtrRot, { "Class.Entrada MATA103"	,{"MV_ZZB1F4E"}	,{} })
	AAdd(aCtrRot, { "Bloco K"				,{"MV_BLKTP00","MV_BLKTP01","MV_BLKTP02","MV_BLKTP03","MV_BLKTP04","MV_BLKTP05","MV_BLKTP06","MV_BLKTP10"},{}})
	AAdd(aCtrRot, { "Fechamento Contábil"	,{"MV_DATAFIS","MV_DATAFIN"},{"MV_DATAFIS","MV_DATAFIN"},{ || vldGrp({GRP_DBLQMO}) }})
	AAdd(aCtrRot, { "Bloqueio Movimentação"	,{"MV_DBLQMOV"},{"MV_DBLQMOV"},{ || vldGrp({GRP_DBLQMO}) }})
	AAdd(aCtrRot, { "Diversos Fiscal"		,{"ZZ_ALIMPIS","ZZ_ALIMCOF","MV_A020FAC"},{"ZZ_ALIMPIS","ZZ_ALIMCOF","MV_A020FAC"},{ || vldGrp({GRP_FISCAL}) }})
	AAdd(aCtrRot, { "Desc.FOB Região"		,{"XX_NORTE","XX_NORDEST","XX_SUDESTE","XX_SUL","XX_COESTE"},{"XX_NORTE","XX_NORDEST","XX_SUDESTE","XX_SUL","XX_COESTE"},{|| vldGrp({GRP_VENDAS_GESTAO}) }})
	AAdd(aCtrRot, { "Validação Email"		,{"MV_EMLBNCE","MV_GPWRNNF","MV_EMLBNA1"},{}})
	AAdd(aCtrRot, { "Destinatarios WF"		,{"XX_EMVEND", "XX_STPEML","MV_ZZWFRTF","MV_ZZWFRF2","MV_ZZWFRTC","MV_ZZWFRC2","MV_IFCMLBF","MV_IFCMLPR","MV_IFCMLBV","MV_IFCMLFT","MV_IFCMLF2","ZZ_WFCTE","ZZ_WFDIVIT","ZZ_WFDIVTL"},{}})
	AAdd(aCtrRot, { "Portal"				,{"XX_DAYWRN","XX_DAYKIL","ZZ_RESEMP","ZZ_GRPNFU","ZZ_VLIMPOR","XX_COMVAR","XX_LIBPED","XX_DIASPED","XX_NEWREP","MV_ZLIBPOR","ZZ_FILESPT","ZZ_VLORCPT","ZZ_VLPADPT","ZZ_EMAPRTE","ZZ_BNDECON","ZZ_BNDEVLR","ZZ_URLPORT","ZZ_USAPRTE","ZZ_URLWS","ZZ_LOGNOT","MV_PRENRES","MV_RESDTEX","XX_CLORPAD","XX_BNDESVL","ZZ_MAXFLEX","ZZ_DIASFAT","ZZ_MINVARE","ZZ_MAXVARE","ZZ_TABISMI"},{} })
	AAdd(aCtrRot, { "Aviso de Parada"		,{"XX_SPRKURL","XX_SPRKAUT"}	,{} })
	AAdd(aCtrRot, { "Fator do Cobre"		,{"XX_VLRCOB"},{} })
	AAdd(aCtrRot, { "Debug Conout"			,{"XX_DBGCONN"},{} })
	AAdd(aCtrRot, { "Schedule Email"		,{"XX_SCHEXP"},{} })
	AAdd(aCtrRot, { "cbcAutomacao"			,{"XX_ETQAPI","XX_ETLSVR","XX_ETRAIZ","XX_ETLSTD","XX_ETLSPR","XX_ETPRLY","ZZ_PEMBC","ZZ_PEMBM","ZZ_KGPALLE","ZZ_KGFARDO","ZZ_PEROREF","ZZ_PEBOBRE","ZZ_HOMVOLM","ZZ_PESPALE","ZZ_COLTOUT","ZZ_FILAOS","ZZ_PESASEP","ZZ_PDSBL01","ZZ_FDCMAIL","ZZ_APISIGA","ZZ_AUTKEYJ","ZZ_DFZBRCO","ZZ_DFPRTCO","ZZ_URLCOUC", "ZZ_USRCOUC","ZZ_PSWCOUC","ZZ_COUDTMO","ZZ_NEWEMP"},{} })
	AAdd(aCtrRot, { "Relatorios Padrão"		,{"XX_RELPAD"},{} })
	AAdd(aCtrRot, { "varejo"				,{"ZZ_VRJEST","ZZ_VRJSEG","ZZ_ONVAREJ","ZZ_PRZEVAR","XX_VARTAB"},{} })
	AAdd(aCtrRot, { "Imp/Nac FCI"			,{"MV_ZZNOFCI","MV_ZZCLIMP","MV_ZZPVIMP"},{} })
	AAdd(aCtrRot, { "CBCERS"				,{"XX_ERSAPI", "XX_ERSINS", "XX_ERSLOG", "XX_ERSHDR", "XX_ERSUSR", "XX_ERSPAS","XX_ERSON"},{} })
	AAdd(aCtrRot, { "Empenhos"				,{"ZZ_SDCLKVZ", "ZZ_SDCNEW"},{} })
	AAdd(aCtrRot, { "Lib.Faturamento"		,{"ZZ_DBORDIT", "ZZ_LIBESCP","ZZ_LNEWLIB"},{} })
	AAdd(aCtrRot, { "Moedas RG"				,{"ZZ_LOOKM2", "ZZ_TXIMRGC"},{} })
	AAdd(aCtrRot, { "MultiFilial"			,{"ZZ_TFILDIV", "MV_ESTADO","ZZ_TARMZ","ZZ_TESNOCB","ZZ_TCLILOJ","ZZ_PVTROPE", "ZZ_PVTROP2", "ZZ_TRIAOPE", "MV_ZZINDLB", "ZZ_VIAXVEN", "ZZ_TESAR01", "ZZ_TARMZ01", "XX_ZTPOPER", "XX_TPOPENT", "ZZ_TESAR10"},{} })
	AAdd(aCtrRot, { "Engenharia"			,{"MV_PESMBOB", "ZZ_PBOBEST", "ZZ_PBOBCLI"},{"MV_PESMBOB", "ZZ_PBOBEST", "ZZ_PBOBCLI"}, { || vldGrp({GRP_ENGENHARIA}) } })
	AAdd(aCtrRot, { "Prazo Entrega Produtos",{"MV_IFCPRZ1","MV_IFCPRZ2","MV_IFCPRZ3","MV_IFCPRZ4","MV_IFCPRZ5","MV_IFCPRZ6","MV_IFCPRZ7","MV_IFCPRZ8","MV_IFCPRZ9","MV_IFCPRZA","MV_IFCPRZB","MV_IFCPRZD","MV_IFCPRZC","MV_IFCPRZE","MV_IFCPRZF","ZZ_PRZEVAR"},{"MV_IFCPRZ1","MV_IFCPRZ2","MV_IFCPRZ3","MV_IFCPRZ4","MV_IFCPRZ5","MV_IFCPRZ6","MV_IFCPRZ7","MV_IFCPRZ8","MV_IFCPRZ9","MV_IFCPRZA","MV_IFCPRZB","MV_IFCPRZD","MV_IFCPRZC","MV_IFCPRZE","MV_IFCPRZF","ZZ_PRZEVAR"},{ || vldGrp({GRP_PCP_PRZENTR}) }})
	AAdd(aCtrRot, { "Logistica"				,{"ZZ_MFILLIB"},{"ZZ_MFILLIB"}, { || vldGrp({GRP_MULTIFIL}) } })
	
	
	/*Não precisa alterar daqui para baixo*/
	lAdm := FwIsAdmin()
	//Exibir as opções de acordo com os privilegios do usuario
	For nX := 1 To Len(aCtrRot)
		If lAdm
			AAdd(aRotina, aCtrRot[nX,NOME_ROTINA])
		Else
			If Len(aCtrRot[nX]) == 4
				If Eval(aCtrRot[nX,VALIDACAO_USUARIO])
					AAdd(aRotina, aCtrRot[nX,NOME_ROTINA])
				EndIf
			Else
				If !Empty(aCtrRot[nX,PARAMETRO_USR])
					AAdd(aRotina, aCtrRot[nX,NOME_ROTINA])
				EndIf
			EndIf
		EndIf
	Next nX

	If Empty(aRotina)
		U_AutoAlert('Suas permissões de usuário não permitem editar nenhum parametro!')
	Else
		//Ordenar as rotinas
		ASort(aRotina,,,{|x,y| x < y})

		//Exibir tela obter os parametros
		AAdd(aParamBox,{2,"Informe qual a rotina","",aRotina,90,"",.T.})
		While ParamBox(aParamBox,"Edição de Parametros...",@aRet)
			For nX := 1 To Len(aCtrRot)
				If aCtrRot[nX,NOME_ROTINA] == aRet[ROTINA_SELECIONADA] 
					If lAdm
						aParams := aCtrRot[nX,PARAMETRO_ADM] 
					else
						aParams := aCtrRot[nX,PARAMETRO_USR]
					EndIf 
				EndIf
			Next nX
			If Empty(aParams)
				U_AutoAlert('Rotina selecionada não disponibiliza nenhum parametro para edição!')
			Else
				U_zCadSX6(aParams, .T.,lAdm,lAdm)
			EndIF
		EndDo 
	EndIf
return (Nil)
/********************** Fim Configuração dos Parametros ***************************/


/**** NÂO MUDAR DAQUI PARA BAIXO POR FAVOR ****/
/*/{Protheus.doc} zCadSX6
Lista parâmetros ao usuário com as opções de incluir, alterar e excluir
@since 14/11/2014
@version 1.0
@param aParams, Array, Parâmetros que serão listados ao usuário para edição
@param lCombo, Lógico, Define se os parâmetros serão mostrados em combo quando houver inclusão
@param lDelet, Lógico, Define se será possível a exclusão de parâmetros
/*/
User Function zCadSX6(aParams, lCombo, lDelet, lAdm)
	Local aArea   := GetArea()
	Local aAreaX6 := SX6->(GetArea())
	Local nAtual  := 0
	Local nColuna := 6
	Default lCombo := .T.
	Default lDelet := .F.
	Default aParams := {}
	Default lAdm	:= .F.
	Private lComboPvt := lCombo
	Private aParamsPvt := {}
	Private cParamsPvt := ""
	//Tamanho da Janela
	Private aTamanho := MsAdvSize()
	Private nJanLarg := aTamanho[5]
	Private nJanAltu := aTamanho[6]
	Private nColMeio := (nJanLarg)/4
	Private nEspCols := ((nJanLarg/2)-12)/4
	Private lAdmin	 := lAdm
	COL_T1 	:= 003
	COL_T2 	:= COL_T1+nEspCols
	COL_T3 	:= COL_T2+nEspCols
	COL_T4 	:= COL_T3+nEspCOls
	//Objetos gráficos
	Private oDlgSX6
	//GetDados
	Private oMsGet
	Private aHeader 	:= {}
	Private aCols		:= {}
	//Botões
	Private aButtons	:= {}

	If lAdm
		aAdd(aButtons,{"Incluir",    "{|| fInclui()}", "oBtnInclui"})
	EndIF
	aAdd(aButtons,{"Alterar",    "{|| fAltera()}", "oBtnAltera"})
	aAdd(aButtons,{"Visualizar", "{|| fVisualiza()}", "oBtnVisual"})
	If lDelet
		aAdd(aButtons,{"Excluir",    "{|| fExclui()}", "oBtnExclui"})
	EndIf
	aAdd(aButtons,{"Sair", "{|| oDlgSX6:End()}", "oBtnSair"})

	//Se não tiver parâmetros
	If Len(aParams) <= 0
		MsgStop("Parâmetros devem ser informados!", "Atenção")
		Return
	Else
		aParamsPvt := aParams
		cParamsPvt := ""

		//Percorrendo os parâmetros e adicionando
		For nAtual := 1 To Len(aParamsPvt)
			cParamsPvt += aParamsPvt[nAtual]+";"
		Next
	EndIf

	//Adicionando cabeçalho
	aAdd(aHeader,{"Filial", 	"ZZ_FILIAL",	"@!",	TAM_FILIAL,		0,	".F.",	".F.",	"C",	"",	""	,})
	aAdd(aHeader,{"Parâmetro", 	"ZZ_PARAME",	"@!",	010,			0,	".F.",	".F.",	"C",	"",	""	,})
	aAdd(aHeader,{"Tipo",  		"ZZ_TIPO",		"@!",	001,			0,	".F.",	".F.",	"C",	"",	""	,})
	aAdd(aHeader,{"Descrição",  "ZZ_DESCRI",	"@!",	150,			0,	".F.",	".F.",	"C",	"",	""	,})
	aAdd(aHeader,{"Conteúdo",   "ZZ_CONTEU",	"@!",	250,			0,	".F.",	".F.",	"C",	"",	""	,})
	aAdd(aHeader,{"RecNo",      "ZZ_RECNUM",	"",		018,			0,	".F.",	".F.",	"N",	"",	""	,})

	//Atualizando o aCols
	fAtuaCols(.T.)

	//Criando a janela
	DEFINE MSDIALOG oDlgSX6 TITLE "Parâmetros:" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	oMsGet := MsNewGetDados():New(	3,;										//nTop
	3,;										//nLeft
	(nJanAltu/2)-33,;						//nBottom
	(nJanLarg/2)-3,;						//nRight
	GD_INSERT+GD_DELETE+GD_UPDATE,;		//nStyle
	"AllwaysTrue()",;						//cLinhaOk
	,;										//cTudoOk
	"",;									//cIniCpos
	,;										//aAlter
	,;										//nFreeze
	999999,;								//nMax
	,;										//cFieldOK
	,;										//cSuperDel
	,;										//cDelOk
	oDlgSX6,;								//oWnd
	aHeader,;								//aHeader
	aCols)									//aCols  
	oMsGet:lActive := .F.

	//Grupo Legenda
	@ (nJanAltu/2)-30, 003 	GROUP oGrpLeg TO (nJanAltu/2)-3, (nJanLarg/2)-3 	PROMPT "Ações: " 		OF oDlgSX6 COLOR 0, 16777215 PIXEL
	//Adicionando botões
	For nAtual := 1 To Len(aButtons)
		@ (nJanAltu/2)-20, nColuna  BUTTON &(aButtons[nAtual][3]) PROMPT aButtons[nAtual][1]   SIZE 60, 014 OF oDlgSX6  PIXEL
		(&(aButtons[nAtual][3]+":bAction := "+aButtons[nAtual][2]))
		nColuna += 63
	Next
	ACTIVATE MSDIALOG oDlgSX6 CENTERED

	RestArea(aAreaX6)
	RestArea(aArea)
Return

/*/{Protheus.doc} fInclui
@author bolognesi
@since 11/11/2016
@version 1.0
@type function
@description Função para inclusão de um parametro
/*/
Static Function fInclui()
	Local nAtual   := oMsGet:nAt
	Local aColsAux := oMsGet:aCols
	Local nPosRecNo:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })

	fMontaTela(3, 0)
Return

/*/{Protheus.doc} fAltera
@author bolognesi
@since 11/11/2016
@version 1.0
@type function
@description Função de alteração de parâmetro  
/*/
Static Function fAltera()
	Local nAtual   := oMsGet:nAt
	Local aColsAux := oMsGet:aCols
	Local nPosRecNo:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })

	//Se tiver recno válido
	If aColsAux[nAtual][nPosRecNo] != 0
		fMontaTela(4, aColsAux[nAtual][nPosRecNo])
	EndIf
Return

/*/{Protheus.doc} fExclui
@author bolognesi
@since 11/11/2016
@version 1.0
@type function
@description Função de exclusão de parâmetro
/*/
Static Function fExclui()
	Local nAtual   := oMsGet:nAt
	Local aColsAux := oMsGet:aCols
	Local nPosRecNo:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })

	//Se tiver recno válido
	If aColsAux[nAtual][nPosRecNo] != 0
		fMontaTela(5, aColsAux[nAtual][nPosRecNo])
	EndIf
Return

/*/{Protheus.doc} fVisualiza
@author bolognesi
@since 11/11/2016
@version 1.0
@type function
@description Função de visualização de parâmetro 
/*/
Static Function fVisualiza()
	Local nAtual   := oMsGet:nAt
	Local aColsAux := oMsGet:aCols
	Local nPosRecNo:= aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })

	//Se tiver recno válido
	If aColsAux[nAtual][nPosRecNo] != 0
		fMontaTela(2, aColsAux[nAtual][nPosRecNo])
	EndIf
Return

/*/{Protheus.doc} fAtuaCols
@author bolognesi
@since 11/11/2016
@version 1.0
@param lFirst, logical, descricao
@type function
@description  Função que atualiza o aCols com os parâmetros
Obs.:  Como a intenção é ter poucos parâmetros, sempre ele irá
percorrer a SX6 e adicionar no aCols   
/*/
Static Function fAtuaCols(lFirst)
	Local aAreaSX6 	:= SX6->(GetArea())
	Local aPar		:= StrToKArr(cParamsPvt,";")
	Local nX		:= 0
	aCols := {}
	If !Empty(aPar)
		//Selecionando a tabela de parâmetros e indo ao topo
		DbSelectArea("SX6")
		SX6->(DbGoTop())

		//Percorrendo os parâmetros, e adicionando somente os que estão na filtragem
		While !SX6->(EoF())

			For nX := 1 To Len(aPar)
				If Alltrim(SX6->X6_VAR) == aPar[nX]
					aAdd( aCols, {	SX6->X6_FIL,;					//Filial
					SX6->X6_VAR,;									//Parâmetro
					SX6->X6_TIPO,;									//Tipo
					SX6->X6_DESCRIC+SX6->X6_DESC1+SX6->X6_DESC2,;	//Descrição
					SX6->X6_CONTEUD,;								//Conteúdo
					SX6->(RecNo()),;								//RecNo
					.F.})											//Excluído?
				EndIf
			Next nX

			SX6->(DbSkip())
		EndDo
	EndIf
	//Se tiver zerada, adiciona conteúdo em branco
	If Len(aCols) == 0
		aAdd( aCols, {	"",;		//Filial
		"",;		//Parâmetro
		"",;		//Tipo
		"",;		//Descrição
		"",;		//Conteúdo
		0,;			//RecNo
		.F.})		//Excluído?
	EndIf

	//Senão for a primeira vez, atualiza grid
	If !lFirst
		oMsGet:setArray(aCols)
	EndIf

	RestArea(aAreaSX6)
Return

/*/{Protheus.doc} fMontaTela
@author bolognesi
@since 11/11/2016
@version undefined
@param nOpcP, numeric, descricao
@param nRecP, numeric, descricao
@type function
@description Função que atualiza o aCols com os parâmetros
/*/
Static Function fMontaTela(nOpcP, nRecP)
	Local nColuna := 6
	Local nEsp := 15
	Private nOpcPvt := nOpcP
	Private nRecPvt := nRecP
	Private aOpcTip := {" ", "C - Caracter", "N - Numérico", "L - Lógico", "D - Data", "M - Memo"}
	Private oFontNeg := TFont():New("Tahoma")
	Private oDlgEdit
	//Campos
	Private oGetFil, cGetFil
	Private oGetPar, cGetPar
	Private oGetTip, cGetTip
	Private oGetDes, cGetDes
	Private oGetCon, cGetCon
	Private oGetRec, nGetRec
	//Botões
	Private aBtnPar	:= {}
	aAdd(aBtnPar,{"Confirmar",   "{|| fBtnEdit(1)}", "oBtnConf"})
	aAdd(aBtnPar,{"Cancelar",    "{|| fBtnEdit(2)}", "oBtnCanc"})

	//Se não for inclusão, pega os campos conforme array
	If nOpcP != 3
		aColsAux := oMsGet:aCols
		nLinAtu  := oMsGet:nAt
		nPosFil  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_FILIAL" })
		nPosPar  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_PARAME" })
		nPosTip  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_TIPO" })
		nPosDes  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_DESCRI" })
		nPosCon  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_CONTEU" })
		nPosRec  := aScan(aHeader,{|x| AllTrim(x[2]) == "ZZ_RECNUM" })

		//Atualizando gets
		cGetFil := aColsAux[nLinAtu][nPosFil]
		cGetPar := aColsAux[nLinAtu][nPosPar]
		cGetTip := aColsAux[nLinAtu][nPosTip]
		cGetDes := aColsAux[nLinAtu][nPosDes]
		cGetCon := aColsAux[nLinAtu][nPosCon]
		nGetRec := aColsAux[nLinAtu][nPosRec]

		//Caracter
		If cGetTip == "C"
			cGetTip := aOpcTip[2]
			//Numérico
		ElseIf cGetTip == "N"
			cGetTip := aOpcTip[3]
			//Lógico
		ElseIf cGetTip == "L"
			cGetTip := aOpcTip[4]
			//Data
		ElseIf cGetTip == "D"
			cGetTip := aOpcTip[5]
			//Memo
		ElseIf cGetTip == "M"
			cGetTip := aOpcTip[6]
		EndIf

		//Senão, deixa os campos zerados
	Else

		//Atualizando gets
		cGetFil := Space(TAM_FILIAL)
		cGetPar := Space(010)
		cGetTip := aOpcTip[1]
		cGetDes := Space(150)
		cGetCon := Space(250)
		nGetRec := 0
	EndIf

	oFontNeg:Bold := .T.

	//Criando a janela
	DEFINE MSDIALOG oDlgEdit TITLE "Dados:" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	nLinAux := 6
	//Filial
	@ nLinAux    , COL_T1						SAY				oSayFil PROMPT	"Filial:"						SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL							PIXEL
	@ nLinAux-003, COL_T1+ESP_CAMPO				MSGET			oGetFil VAR		cGetFil						SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215						PIXEL
	//Parâmetro
	@ nLinAux    , COL_T2						SAY				oSayPar PROMPT	"Parâmetro:"					SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL		FONT oFontNeg		PIXEL
	If lComboPvt
		@ nLinAux-003, COL_T2+ESP_CAMPO			MSCOMBOBOX		oGetPar VAR		cGetPar ITEMS aParamsPvt		SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215						PIXEL
	Else
		@ nLinAux-003, COL_T2+ESP_CAMPO			MSGET			oGetPar VAR		cGetPar						SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215	VALID (cGetPar $ cParamsPvt)	PIXEL
	EndIf
	//Tipo
	@ nLinAux    , COL_T3						SAY				oSayTip PROMPT	"Tipo:"						SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL		FONT oFontNeg		PIXEL
	@ nLinAux-003, COL_T3+ESP_CAMPO				MSCOMBOBOX		oGetTip VAR		cGetTip ITEMS aOpcTip		SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215						PIXEL
	//RecNo
	@ nLinAux    , COL_T4						SAY				oSayRec PROMPT	"RecNo:"						SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL							PIXEL
	@ nLinAux-003, COL_T4+ESP_CAMPO				MSGET			oGetRec VAR		nGetRec						SIZE 060, 010 OF oDlgEdit COLORS 0, 16777215						PIXEL
	nLinAux += nEsp
	//Descrição
	@ nLinAux    , COL_T1						SAY				oSayDes PROMPT	"Descrição:"					SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL		FONT oFontNeg		PIXEL
	@ nLinAux-003, COL_T1+ESP_CAMPO				MSGET			oGetDes VAR		cGetDes						SIZE 300, 010 OF oDlgEdit COLORS 0, 16777215						PIXEL
	nLinAux += nEsp
	//Conteúdo
	@ nLinAux    , COL_T1						SAY				oSayCon PROMPT	"Conteúdo:"					SIZE 040, 007 OF oDlgEdit COLORS CLR_AZUL		FONT oFontNeg		PIXEL
	@ nLinAux-003, COL_T1+ESP_CAMPO				MSGET			oGetCon VAR		cGetCon						SIZE 300, 010 OF oDlgEdit COLORS 0, 16777215						PIXEL

	//Grupo Legenda
	@ (nJanAltu/2)-30, 003 	GROUP oGrpLegEdit TO (nJanAltu/2)-3, (nJanLarg/2)-3 	PROMPT "Ações (Confirmação): " 		OF oDlgEdit COLOR 0, 16777215 PIXEL
	//Adicionando botões
	For nAtual := 1 To Len(aBtnPar)
		@ (nJanAltu/2)-20, nColuna  BUTTON &(aBtnPar[nAtual][3]) PROMPT aBtnPar[nAtual][1]   SIZE 60, 014 OF oDlgEdit  PIXEL
		(&(aBtnPar[nAtual][3]+":bAction := "+aBtnPar[nAtual][2]))
		nColuna += 63
	Next

	//Se for visualização ou exclusão, todos os gets serão desabilitados
	If nOpcP == 2 .Or. nOpcP == 5
		oGetFil:lActive := .F.
		oGetPar:lActive := .F.
		oGetTip:lActive := .F.
		oGetDes:lActive := .F.
		oGetCon:lActive := .F.
	Else
		//Se for alteração, desabilita a Filial, Parâmetro e Tipo
		If nOpcP == 4
			oGetFil:lActive := .F.
			oGetPar:lActive := .F.
			oGetTip:lActive := .F.
			//Se for alteração e não for administrador, não edita descrição.
			If !lAdmin
				oGetDes:lActive := .F.
			EndIF

		EndIf
	EndIf

	//Campo de RecNo sempre será desabilitado
	oGetRec:lActive := .F.
	ACTIVATE MSDIALOG oDlgEdit CENTERED
Return

/*/{Protheus.doc} fBtnEdit
@author bolognesi
@since 11/11/2016
@version 1.0
@param nConf, numeric, descricao
@type function
@description Função que confirma a tela 
/*/
Static Function fBtnEdit(nConf)
	Local aAreaAux 	:= GetArea()
	Local cTipoD	:= ""

	//Se for o Cancelar
	If nConf == 2
		oDlgEdit:End()
		//Se for o Confirmar
	ElseIf nConf == 1
		//Se for visualizar
		If nOpcPvt == 2
			oDlgEdit:End()

			//Senão for visualizar
		Else
			//Se for exclusão
			If nOpcPvT == 5
				SX6->(DbGoTo(nRecPvt))
				RecLock("SX6", .F.)
				DbDelete()
				SX6->(MsUnlock())
				oDlgEdit:End()
			Else

				//Validar a descrição com o Tipo do parametro
				cTipoD := Alltrim(Left(cGetTip,1))

				//Caracter
				If cTipoD == "C"
					//TODO Validar Caractere
					//Numérico
				ElseIf cTipoD == "N"
					If  !IsDigit(cGetCon)//!(Alltrim(cGetCon) $ '0123456789')
						MsgInfo("O campo <b>Conteúdo</b> quando tipo de dado definido como numérico <br>apenas aceita numeros", "Atenção")
						Return
					EndIF
					//Lógico
				ElseIf cTipoD == "L"
					If !(Alltrim(cGetCon) $ '.T.//.F.')
						MsgInfo("O campo <b>Conteúdo</b> quando tipo de dado definido como logico <br>apenas aceita ( .T. ) ou ( .F. )", "Atenção")
						Return
					EndIf
					//Data
				ElseIf cTipoD == "D"
					If Empty(Ctod(Alltrim(cGetCon)))
						MsgInfo("O campo <b>Conteúdo</b> quando tipo de dado definido como data <br>apenas aceita uma data valida", "Atenção")
						Return
					EndIF
					//Memo
				ElseIf cTipoD == "M"
					//TODO Validar Memo
				EndIf

				//Descrição ou conteúdo em branco?
				If Empty(cGetDes) .Or. Empty(cGetCon)
					If !MsgYesNo("O campo <b>Descrição</b> e/ou <b>Conteúdo</b> estão com conteúdo em branco!<br>Deseja continuar?", "Atenção")
						Return
					EndIf
				EndIf

				//Se for inclusão
				If nOpcPvt == 3
					//Tipo e parâmetro em branco?
					If Empty(cGetTip) .Or. Empty(cGetPar)
						MsgAlert("O campo <b>Parâmetro</b> e/ou <b>Tipo</b> estão com conteúdo em branco!", "Atenção")
						Return
					EndIf

					//Já existe registro?
					SX6->(DbGoTop())
					If (SX6->(DbSeek(cGetFil+cGetPar)))
						MsgAlert("Filial e Parâmetro já existem!", "Atenção")
						Return
					EndIf

					//Travando tabela para inclusão
					RecLock("SX6", .T.)
					X6_FIL			:= cGetFil
					X6_VAR			:= cGetPar
					X6_TIPO		:= cGetTip
					//Se for alteração, trava tabela para alteração
				ElseIf nOpcPvt == 4
					SX6->(DbGoTo(nRecPvt))
					RecLock("SX6", .F.)
				EndIf

				//Gravando informações
				X6_DESCRIC		:= SubStr(cGetDes,001,50)
				X6_DESC1		:= SubStr(cGetDes,051,50)
				X6_DESC2		:= SubStr(cGetDes,101,50)
				X6_CONTEUD		:= cGetCon
				SX6->(MsUnlock())

				oDlgEdit:End()
			EndIf
		EndIf

		//Atualizando a grid
		fAtuaCols(.F.)
	EndIf

	RestArea(aAreaAux)
Return


/******************* STATICS PARA VALIDAÇÂO ESCREVER AQUI ****************************/
/*TODAS devem retornar um valor logico*/

/*/{Protheus.doc} vldGrp
@author bolognesi
@since 02/05/2017
@version undefined
@param aGrp, array, Array com os grupos que permitem acesso
@type function
@description Realizar a validação do acesso no nivel de grupo
/*/
Static Function vldGrp(aGrp) //vldGrp({'000016'})
	Local lRet		:= .T.
	local oAcl		:= nil
	default aGrp 	:= {}
	if empty(aGrp)
		lRet := .F.
	else
		oAcl := cbcAcl():newcbcAcl()
		if !oAcl:usrIsGrp(aGrp)
			lRet := .F.
    	endif
	FreeObj(oAcl)
	endif
	//__cUserId $ GetMv("ZZ_USAPRTE"))
return(lRet)

/*************************************************************************************/
