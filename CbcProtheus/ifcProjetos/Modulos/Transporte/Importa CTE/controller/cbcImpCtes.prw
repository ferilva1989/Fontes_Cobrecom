#INCLUDE 'protheus.ch'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "FILEIO.CH"
#include "tbiconn.ch"


class cbcImpCtes 
	method newcbcImpCtes() constructor 
	method makeBrowser()
endclass

method newcbcImpCtes() class cbcImpCtes
return (self)

method makeBrowser(oBrowse115) class cbcImpCtes
	oBrowse115 := FWMarkBrowse():New()
	oBrowse115:SetAlias("GXG")
	oBrowse115:SetMenuDef("cbcImpCtes")
	oBrowse115:SetFieldMark("GXG_MARKBR")
	oBrowse115:SetDescription( "Recebimento de Documento de Frete")
	oBrowse115:SetAllMark({|| GFEA118MARK()})
	oBrowse115:SetFilterDefault("GXG_ORIGEM <> '4'")
	oBrowse115:AddLegend("GXG_EDISIT == '1'", "BLUE"   	, "Importado" )
	oBrowse115:AddLegend("GXG_EDISIT == '2'", "YELLOW"  , "Importado Com Erro" )
	oBrowse115:AddLegend("GXG_EDISIT == '3'", "RED"    	, "Rejeitado" )
	oBrowse115:AddLegend("GXG_EDISIT == '4'", "GREEN"	, "Processado" )
	oBrowse115:AddLegend("GXG_EDISIT == '5'", "BLACK"	, "Erro Impeditivo" )
return (oBrowse115)

static function MenuDef()
	Local aRotina := {}
	ADD OPTION aRotina TITLE "Pesquisar"    	  	ACTION "AxPesqui"            	OPERATION 1 ACCESS 0 	// "Pesquisar"
	ADD OPTION aRotina TITLE "Visualizar" 			ACTION "VIEWDEF.GFEA118" 		OPERATION 2 ACCESS 0 	// "Visualizar"
	ADD OPTION aRotina TITLE "Carga XML Sefaz"		ACTION "FWMsgRun(, { |oSay| u_zExecCte({.F.},oSay) }, 'Importação XML SEFAZ', 'Importando XML do ambiente da SEFAZ ... Aguarde!')"		OPERATION 3 ACCESS 0 	// "Importar"
	ADD OPTION aRotina TITLE "Alterar" 				ACTION "VIEWDEF.GFEA118" 		OPERATION 4 ACCESS 0 	// "Alterar"
	ADD OPTION aRotina TITLE "Importa XML ERP"		ACTION "FWMsgRun(, { |oSay| u_ImpXmlGXG(oSay) }, 'Carga dos arquivos XML', 'Realizando a Carga XML ... Aguarde!')"			OPERATION 3 ACCESS 0 	// "Importar"
	ADD OPTION aRotina TITLE "Gerar Fiscal"			ACTION "FWMsgRun(, { |oSay| u_ProcessMkt(oSay) }, 'Importação Fiscal', 'Processando os Registros Selecionados ... Aguarde!')" OPERATION 4 ACCESS 0 	// "Processar"
	ADD OPTION aRotina TITLE "Excluir" 				ACTION "VIEWDEF.GFEA118" 		OPERATION 5 ACCESS 0 	// "Excluir"
	ADD OPTION aRotina TITLE "Exc. Selecionados"	ACTION "GFEA118EXC()"        	OPERATION 5 ACCESS 0 	// "Excluir Todos"
	ADD OPTION aRotina TITLE "Imprimir"				ACTION "VIEWDEF.GFEA118" 		OPERATION 8 ACCESS 0	// "Imprimir"
	ADD OPTION aRotina TITLE "Imprimir Cobrecom"	ACTION "u_cbcRelCte()"	 		OPERATION 8 ACCESS 0	// "Imprimir"
return aRotina

/*/{Protheus.doc} ImpXmlGXG
//TODO Importa todos os XMLS para a GXG do GFE para importação Fiscal.
@author juliana.leme
@since 10/01/2020
@version 1.0
@type function
/*/
user function ImpXmlGXG()
	private cDir20		:= AllTrim(GetNewPar("ZZ_CTESAVE","\config_cte_xml\xml\inn\"))
	private cDirLido20	:= AllTrim(GetNewPar("ZZ_CTELIDO","\config_cte_xml\xml\lidos\"))
	private cDirErr		:= AllTrim(GetNewPar("ZZ_CTEERR","\config_cte_xml\xml\err\"))	
	ImportCol(.F.)
return

user function schImpXmlGXG(aSch)
	private cDir20		as string 
	private cDirLido20	as string 
	private cDirErr		as string 	
	default aSch = {"01", "01"}
	
	PREPARE ENVIRONMENT EMPRESA aSch[1] FILIAL aSch[2]
	cDir20		:= AllTrim(GetNewPar("ZZ_CTESAVE","\config_cte_xml\xml\inn\"))
	cDirLido20	:= AllTrim(GetNewPar("ZZ_CTELIDO","\config_cte_xml\xml\lidos\"))
	cDirErr		:= AllTrim(GetNewPar("ZZ_CTEERR","\config_cte_xml\xml\err\"))
	ImportCol(.T.)
	RESET ENVIRONMENT
return

static function ImportCol(lSch)
	local aAreaGXG	:= getArea()
	local aProc		as array
	local aErros	as array
	local nCont     as numeric
	local bErro   	as object
	Local oStatic   := IfcXFun():newIfcXFun()
	nCont := 0
	bErro := ErrorBlock({|oErr| HandleEr(oErr)})
	If !lSch
		If !MsgYesNo("Importar Todos os XMLs Pendentes ?")
			return nil
		EndIf
	EndIf
	// aDirImpor := DIRECTORY(AllTrim(cDir20) + "214*.XML" )
	aDirImpor := DIRECTORY(AllTrim(cDir20) + "*.XML" )
	aDirCanc  := DIRECTORY(AllTrim(cDir20) + "384*.XML" )
	for nCont := 1 to Len(aDirCanc)
		aadd(aDirImpor, aDirCanc[nCont])
	next aDirImpor

	if len(aDirImpor) < 1
		If !lSch
			Help( ,, 'HELP',, "Não foram encontrados arquivos XML válidos no diretório " + cDir20 + ".", 1, 0,)
		EndIf
		return
	endIf
	for nCont := 1 to Len(aDirImpor)
		BEGIN SEQUENCE
			cXMLArq := cDir20 + aDirImpor[nCont][1]
			if FwFilial() ==  Substr(aDirImpor[nCont][1],1,2)
				if !GFEA118CHA(cXMLArq,@aProc,@aErros,cDirLido20,cDirErr) .Or. lSch
					oStatic:sP(2):callStatic('GFEA118', 'GA118MoveFile', cXMLArq, cDirLido20 + aDirImpor[nCont][1])
				endif
			endif
		END SEQUENCE
		ErrorBlock(bErro)
	next nCont
	
	if !IsBlind() .And. !Empty(aErros)
		for nCont := 1 To Len(aErros)
			GFEResult:AddErro("Arquivo: " + aErros[nCont][1] + CRLF + aErros[nCont][2])
			GFEResult:AddErro(Replicate("-",50) + CRLF)
		next nCont
		GFEResult:AddErro("Ocorreram erros na importação de um ou mais arquivos. Possíveis motivos:" + CRLF + "- Erros nos arquivos XML;" + CRLF + "- Arquivos incompatíveis com o formato XML;" + CRLF + "- Chave de CTE já importada/processada." + CRLF)
		//GFEResult:Show("Importação de arquivos Ct-e", "Arquivos", "Erros", "Clique no botão 'Erros' para mais detalhes.")
	endIf
	If !lSch
		desmarkMark()
		RestArea(aAreaGXG)
		oBrowse115:GoTop()
		oBrowse115:Refresh()
	EndIf
return

static function desmarkMark()
	local aAreaGXG := GetArea()

	dbSelectArea("GXG")
	GXG->(dbGoTop())
	while GXG->(!Eof())
		if (GXG_MARKBR == oBrowse115:Mark())
			RecLock("GXG", .F.)
				GXG->GXG_MARKBR := "  "
			GXG->(MsUnlock())
		endif
		GXG->(dbSkip())
	enddo

	RestArea(aAreaGXG)
	oBrowse115:Refresh()
	oBrowse115:GoTop()
return

/*/{Protheus.doc} ProcessMkt
//TODO Processa todos os registros Marcados no browse.
@author juliana.leme
@since 10/01/2020
@version 1.0
@param oSay, object, descricao
@type function
/*/
user function ProcessMkt(oSay)
	local lRet 	:= .T.
	local nCont	:= 1
	If !MsgYesNo("Gerar Documento Fiscal de todos os registros selecionados?")
		return nil
	EndIf
	dbSelectArea("GXG")
	dbGoTop()
	While !GXG->(EOF())
		If oBrowse115:IsMark(oBrowse115:Mark())
			if (GXG->(GXG_AUDITS) == 'W' .Or.  GXG->(GXG_AUDITS) == 'Z')
				Help(NIL, NIL, "Auditoria de Frete",;
				NIL, "Doc: " + Alltrim(GXG->(GXG_NRDF)) + " Chv: " + Alltrim(GXG->(GXG_CTE)) ,;
				1, 0, NIL, NIL, NIL, NIL, NIL, {"Verificar liberação Logistica"})
			elseif GXG->GXG_EDISIT <> '4' 
				oSay:SetText("Processando Registro: " + Alltrim(Str(nCont)) + " ... Aguarde ...")
				oSay:CtrlRefresh()
				lRet := AtuDocFret()
				nCont += 1
			endif
		EndIf
		GXG->( dbSkip() )
	EndDo
return(lRet)

/*/{Protheus.doc} AtuDocFret
//TODO Cria o Documento de Frete no fiscal.
@author juliana.leme
@since 10/01/2020
@version 1.0
@type function
/*/
static function AtuDocFret()
	local aDocFrete		:= {}, aItensDoc 	:= {}
	local lErro 		:= .F.
	local aForLoj 		:= GFEA055GFL(GXG->GXG_EMISDF)
	local cF1_DOC 		:= GXG->GXG_NRDF
	local aErro 		:= {}
	local nX 			:= 0
	local cCpdGFE		:= Posicione("SA2", 1, xFilial("SA2") + aForLoj[1] + aForLoj[2] , "A2_COND")
	local cTpCte 		:= "", cMsg 			:= "", cOpcInteg 	:= "", cFilAtu := ""
	local aCidades	    := {}, aCidadesUF    := {}
	default nInt		:= "1" //nInt = "1"(Integração de Documentos de Frete como Documento de Entrada)
	private lMsHelpAuto 	:= .T.
	private lAutoErrNoFile 	:= .T.
	private lMsErroAuto 	:= .F.
	private aHeader 		:= {}
	private cOperPE			:= ""
	private ctpNfMat		:= ""

	if empty(aForLoj[1])
		cMsg := "Fornecedor não cadastrado no Protheus."
		lErro := .T.
	endif
	cOpcInteg := "0"
	begin transaction
		if !lErro
			if !hasDocEntre(GXG->GXG_FILIAL, GXG->GXG_CTE, aForLoj[1], aForLoj[2])
				if empty(aForLoj[2])
					aForLoj[2] := "01"
				endif
				cF1_DOC := StrZero(val(SubStr(cF1_DOC,1,TamSx3("F1_DOC")[1])),TamSx3("F1_DOC")[1])
				aCidades   := (cbcGfeWsCity(GXG->GXG_EMISDF, GXG->GXG_CDREM, GXG->GXG_CDDEST))
				aAdd(aCidadesUF,{Substr(aCidades[1][1], 3,7), Posicione("GU7", 1, xFilial("GU7") + aCidades[1][1], "GU7_CDUF"), Substr(aCidades[1][2], 3,7), Posicione("GU7", 1, xFilial("GU7") + aCidades[1][2], "GU7_CDUF") })
				//Cabeçalho do Documento de Entrada
				aadd(aDocFrete, {"F1_DOC"		, cF1_DOC					, nil } )
				aadd(aDocFrete, {"F1_SERIE"		, GXG->GXG_SERDF			, nil } )
				aadd(aDocFrete, {"F1_FORNECE"	, aForLoj[1]				, nil } )
				aadd(aDocFrete, {"F1_LOJA"		, aForLoj[2]				, nil } )
				aadd(aDocFrete, {"F1_EMISSAO"	, GXG->GXG_DTEMIS			, nil } )
				aadd(aDocFrete, {"F1_COND"		, cCpdGFE					, nil } )
				aadd(aDocFrete, {"F1_RECBMTO"	, GXG->GXG_DTENT			, nil } )
				aadd(aDocFrete, {"F1_CHVNFE"	, GXG->GXG_CTE				, nil } )
				aadd(aDocFrete, {"F1_TIPO"		, "N"						, nil } )
				aadd(aDocFrete, {"F1_FORMUL"	, "N"						, nil } )
				aadd(aDocFrete, {"F1_ESPECIE"	, GXG->GXG_CDESP			, nil } )
				aadd(aDocFrete, {"F1_ORIGEM"	, "AtuDocFret"				, nil } )
				aadd(aDocFrete, {"F1_VALPEDG"	, GXG->GXG_PEDAG			, nil } ) 
				if GXG->GXG_TPCTE == "0"
					cTpCte = "N"
				elseiF GXG->GXG_TPCTE == "1"
					cTpCte = "C"
				elseiF GXG->GXG_TPCTE == "2"
					cTpCte = "A"
				elseif GXG->GXG_TPCTE == "3"
					cTpCte = "S"
				endif
				if empty(cCpdGFE)
					cCpdGFE		:= SuperGetMv("MV_CPDGFE",,"1")
				endif
				aadd(aDocFrete, {"F1_TPCTE" 	,cTpCte 					, nil}) //Tipo CTE
				aadd(aDocFrete, {"F1_TPFRETE" 	, "C"						, nil } ) //Tipo Frete integração realizada pelo MATA103/MATA140, enviar a informação como CIF		
				/* Origem x Destino do transporte - Ato Cotepe 48 */
				aadd(aDocFrete, {"F1_EST"     	, aCidadesUF[1][2]			, nil } )
				aadd(aDocFrete, {"F1_ESTDES"  	, aCidadesUF[1][4]			, nil } )				
				aadd(aDocFrete, {"F1_MUORITR" 	, aCidadesUF[1][1]			, nil } )
				aadd(aDocFrete, {"F1_UFORITR" 	, aCidadesUF[1][2]			, nil } )
				aadd(aDocFrete, {"F1_MUDESTR" 	, aCidadesUF[1][3]			, nil } )
				aadd(aDocFrete, {"F1_UFDESTR" 	, aCidadesUF[1][4]			, nil } )
				aadd(aDocFrete, {"F1_HISTRET" 	, GXG->GXG_OBS				, nil } )
				//Itens do Documento de Entrada
				GetItCte(@aItensDoc,aForLoj,cF1_DOC,3, cOpcInteg)
				//Utilizado para que não seja atribuida a filial do usuário logado dentro do módulo de compras
				cFilAtu := cFilAnt
				cFilAnt := GXG->GXG_FILIAL
				MSExecAuto( { |x,y,z| MATA103(x,y,z) }, aDocFrete,aItensDoc,3 )
				cFilAnt := cFilAtu
				if lMsErroAuto
					aErro 	:= GetAutoGrLog()
					cMsg 	:= ""
					for nX := 1 to len(aErro)
						if nX <= 3
							cMsg += aErro[nX] + CRLF
						else
							exit
						endif
					next nX
					lErro := .T.
					DisarmTransaction()
				endif	
			endif
			if lErro
				addToObs(cMsg)
				atustsGXG("5")
			else
				addToObs("Documento fiscal numero: " + GXG->GXG_SERDF+ "/" + cF1_DOC + " gerado com Êxito!")
				atustsGXG("4")
			endif			
		endif
	end transaction
return !lErro

/*/{Protheus.doc} GetItCte
//TODO Monta array de Itens do Fiscal.
@author juliana.leme
@since 10/01/2020
@version 1.0
@param aItensDoc, array, descricao
@param aForLoj, array, descricao
@param cF1_DOC, characters, descricao
@param nOp, numeric, descricao
@param cOpcInt, characters, descricao
@type function
/*/
static function GetItCte(aItensDoc,aForLoj,cF1_DOC,nOp,cOpcInt)
	local aItemDoc 	:= {}
	local cTes     	:= "017", cPrdFrete	:= ""
	Local cTesTemp  := ""
	local cCenCus	:= "", cContaProd 	:= "", cItemCta		:= ""
	local cTpImp   	:= Posicione("GVT", 1, xFilial("GVT") + GXG->GXG_CDESP, "GVT_TPIMP")
	local cD1_Quant	:= 1
	local lCpoTES  	:= GFEA065INP()
	local nVlDoc   	:= GXG->GXG_VLDF
	local cFGER 	:= ""
	default cOpcInt	:= "0"

	//Itens do Documento de Entrada
	aadd(aItemDoc, {"D1_DOC"    , cF1_DOC           , Nil} )
	aadd(aItemDoc, {"D1_SERIE"  , GXG->GXG_SERDF    , Nil} )
	aadd(aItemDoc, {"D1_FORNECE", aForLoj[1]        , Nil} )
	aadd(aItemDoc, {"D1_LOJA"   , aForLoj[2]        , Nil} )
	aadd(aItemDoc, {"D1_EMISSAO", GXG->GXG_DTEMIS   , Nil} )
	if empty(cPrdFrete)
		if lCpoTES 
			if GXG->GXG_PCIMP <= 7
				cPrdFrete := "SV05000020"
			else
				cPrdFrete := "SV05000021"
			endif
		else
			cPrdFrete := SuperGetMv("MV_PRITDF",.F.,"")
		endif
	endif
	Aadd(aItemDoc, {"D1_COD"    , cPrdFrete         , Nil} )
	Aadd(aItemDoc, {"D1_UM"     , "UN"              , Nil} )
	Aadd(aItemDoc, {"D1_QUANT"  , cD1_Quant			, Nil} ) // se opcint = 4 entao envia 0 senao mantem 1
	Aadd(aItemDoc, {"D1_VUNIT"  , nVlDoc        	, Nil} )
	Aadd(aItemDoc, {"D1_TOTAL"  , nVlDoc        	, Nil} )
	if lCpoTES
		cCenCus  	:= Posicione("SB1", 1, xFilial("SB1") + cPrdFrete , "B1_CC")
		cContaProd	:= Posicione("SB1", 1, xFilial("SB1") + cPrdFrete , "B1_CONTA")
		cItemCta	:= Posicione("SA2", 1, xFilial("SB1") + aForLoj[1] + aForLoj[2] , "A2_ZZITEM")
		aadd(aItemDoc, {"D1_CONTA"  , cContaProd	, Nil})//Verificar
		aadd(aItemDoc, {"D1_ITEMCTA", cItemCta		, Nil})//Verificar
		aadd(aItemDoc, {"D1_CC"     , cCenCus		, Nil})//verificar
	endif
	if SuperGetMv("MV_TESGFE", .F., "1") == "1" // Atribuído sistema
		if GFXCP12123("GXG_USO")
			cFGer	 := GFEA065FGER(GXG->GXG_NATFRE, GXG->GXG_USO)
		endif
		cTesTemp := GFE065TES(cTes, cTpImp, GXG->GXG_TRBIMP, "1", "1", aForLoj, cFGer, GXG->GXG_TPCTE, cPrdFrete, "")			
		cTes := IIF(EMPTY(cTesTemp), cTes, cTesTemp)
	endif	
	Aadd(aItemDoc, {"D1_TES"	, cTes				, Nil })
	Aadd(aItemDoc, {"D1_VALICM"	, GXG->GXG_VLIMP	, Nil } )
	Aadd(aItemDoc, {"D1_PICM"	, GXG->GXG_PCIMP	, Nil } )
	Aadd(aItemDoc, {"D1_BASEICM", GXG->GXG_BASIMP	, Nil } )
	Aadd(aItemDoc, {"D1_ICMSRET", GXG->GXG_IMPRET	, Nil } )
	Aadd(aItensDoc, aItemDoc)
return

/*/{Protheus.doc} addToObs
//TODO Adiciona Mensagem de execução em campo da GXG.
@author juliana.leme
@since 10/01/2020
@version 1.0
@param cMsg, characters, descricao
@type function
/*/
static function addToObs(cMsg)
	default nRecGXG 	:= 0
	default cMsg 		:= ""
	if !empty(cMsg)
		if RecLock("GXG",.F.)
			If GFEVerCmpo({"GXG_ZZMSG"})
				GXG->GXG_ZZMSG := cMsg
			EndIf
			MsUnlock()
		endif
	endif 
return

/*/{Protheus.doc} atustsGXG
//TODO Atualiza Status da GXG.
@author juliana.leme
@since 10/01/2020
@version 1.0
@param cStatus, characters, descricao
@type function
/*/
static function atustsGXG(cStatus)
	default nRecGXG 	:= 0
	default cStatus 	:= ""
	if !empty(cStatus)
		if RecLock("GXG",.F.)
			GXG->GXG_EDISIT :=	cStatus
			GXG->GXG_MARKBR := "  "
			MsUnlock()
		endif
	endif 
return

/*/{Protheus.doc} cbcGfeWsCity
//TODO Carrega as cidades conforme passado.
@author juliana.leme
@since 27/02/2020
@version 1.0
@param cEMISDF, characters, descricao
@param cREMEDF, characters, descricao
@param cCDDEST, characters, descricao
@type function
/*/
static function cbcGfeWsCity(cEMISDF, cREMEDF, cCDDEST)
	local cbcArea		:= GetArea()
	local cOrigem 		:= ""
	local cCidDest 		:= ""
	local aCity			:= {}

	DbSelectArea("GU3")
	cOrigem 	:= Posicione("GU3",1,XFILIAL("GU3")+cEMISDF,"GU3_NRCID")
	cCidDest	:= Posicione("GU3",1,XFILIAL("GU3")+cCDDEST,"GU3_NRCID")		
	aAdd(aCity,{cOrigem,cCidDest})
	restArea(cbcArea)
return aCity

user function cbcNewTransp(aDadosTransp)
	local lRet				:= .T.
	local aDados			:= {}
	local nX				:= 0
	private	lMsErroAuto		:= .F.
	private lMsHelpAuto		:= .T.
	private lAutoErrNoFile	:= .T.
	private lIsJobAuto		:= .T.
	default aDadosTransp 	:= {}
	
	if len(aDadosTransp) > 0
		aAdd(aDados, {"A4_NOME"		, aDadosTransp[3][2]	, nil})
		aAdd(aDados, {"A4_COD", GetSXENum("SA4","A4_COD")	, nil})
		aAdd(aDados, {"A4_NREDUZ"	, ""					, nil})
		aAdd(aDados, {"A4_VIA"		, "RODOVIARIO"			, nil})
		aAdd(aDados, {"A4_END"		, aDadosTransp[4][2] + " , " + aDadosTransp[5][2], nil})
		aAdd(aDados, {"A4_BAIRRO"	, aDadosTransp[6][2]	, nil})
		aAdd(aDados, {"A4_MUN"		, aDadosTransp[7][2]	, nil})
		aAdd(aDados, {"A4_EST"		, aDadosTransp[9][2]	, nil})
		aAdd(aDados, {"A4_COD_MUN"	, substr(aDadosTransp[8][2],3,5)	, nil})
		aAdd(aDados, {"A4_CEP"		, aDadosTransp[10][2]	, nil})
		aAdd(aDados, {"A4_CGC"		, aDadosTransp[1][2]	, nil})
		aAdd(aDados, {"A4_INSEST"	, aDadosTransp[2][2]	, nil})
		aAdd(aDados, {"A4_OBS"		, aDadosTransp[11][2]	, nil})
		aAdd(aDados, {"A4_DDD"		, substr(aDadosTransp[12][2],1,2)	, nil})
		aAdd(aDados, {"A4_TEL"		, substr(aDadosTransp[12][2],3,9)	, nil})
		aAdd(aDados, {"A4_XPORTAL"	, "N"					, nil})
		aAdd(aDados, {"A4_CODPAIS"	, "01058"				, nil})
		aAdd(aDados, {"A4_TPTRANS"	, "1"					, nil})
		
		MSExecAuto( { |x,y,z| mata050(x,y) },aDados,3 )	
		if lMsErroAuto
			aErro 	:= GetAutoGrLog()
			cMsg 	:= ""
			for nX := 1 to len(aErro)
				cMsg += aErro[nX] + CRLF
			next nX
			lRet := .F.
		Else
			lRet := .T.
		endif
	else
		lRet := .F.
	endif
return lRet

static function hasDocEntre(cFilCte, cChv, cForne, cLoja)
	local aArea    	:= GetArea()
	local aAreaGXG	:= GXG->(getArea())
	local aAreaGXH	:= GXH->(getArea())
	local aAreaSF1	:= SF1->(getArea())
	local lHas 		:= .F.
	local oSql 		:= LibSqlObj():newLibSqlObj()

	oSql:newAlias(qryHasDocEntre(cFilCte, cChv, cForne, cLoja))
	
	lHas := oSql:hasRecords()
	
	oSql:close()
	FreeObj(oSql)
	
	RestArea(aAreaGXG)
	RestArea(aAreaGXH)
	RestArea(aAreaSF1)
	RestArea(aArea)
return(lHas)

static function qryHasDocEntre(cFilCte, cChv, cForne, cLoja)
	local cQry := ''
	cQry += " SELECT SF1.R_E_C_N_O_ AS [REC] "
	cQry += " FROM SF1010 SF1 "
	cQry += " WHERE SF1.F1_FILIAL = '" + cFilCte + "' "
	cQry += " AND SF1.F1_CHVNFE = '" + cChv + "' "
	cQry += " AND SF1.F1_FORNECE = '" + cForne + "' "
	cQry += " AND SF1.F1_LOJA = '" + cLoja + "' "
	cQry += " AND SF1.D_E_L_E_T_ = '' "
return(cQry)

static function HandleEr(oErr)
	Conout("[CTE - "+DtoC(Date())+" - "+Time()+" ] "+ '[ERRO]' + oErr:Description + ' [FROM] ' + ProcName(3))
return(nil)
