#include 'protheus.ch'
#include 'parmtype.ch'
#include "TopConn.ch"

user function listZAA() //1150504401T00040     
	Local aPergs 	:= {}
	Local aRet		:= {}
	Local cQry		:= ''
	Local cLocal	:= ''
	Local cAlsZaa	:= GetNextAlias()
	Local bBlock 	:= ErrorBlock()
	
	ErrorBlock( {|e| ChecErro(e)})
	
	aAdd(aPergs, {9,"Preencha para Filtrar ou Deixe Vazio para Obter Toda a Lista",180,7,.T.})
	aAdd(aPergs, {1,"Codigo do Produto: ",Space(15),"","","",,0,.F.})
	aAdd(aPergs, {1,"Acondicionamento: ",Space(10),"","","","",0,.F.})
	If !ParamBox(aPergs, "Lista de Produtos",@aRet,,,,,,,,.F.,.F.)    
		Alert("Geracao do Excel Cancelado!")
		return(nil)
	Else
		BEGIN SEQUENCE
			cQry	:= ChangeQuery(qryZAA(ALLTRIM(aRet[2]) + ALLTRIM(aRet[3])))
			TCQuery cQry New Alias &cAlsZaa
			If !Empty((cAlsZaa)->CHAVE)		 
				cLocal := cGetFile(, "Selecione o Destino",, "C:/", .F., GETF_LOCALHARD, .F.)
				If Empty(cLocal)
					MsgAlert("Local para Salvar o Arquivo Invalido")
					Return	
				EndIf	
				Processa({|| printZAA((cAlsZaa), cLocal)}, "Gerando...")
			Else
				MsgAlert("Nenhum Registro Encontrado" + " Prod: " + aRet[2] + " Acond: " + aRet[3])
			EndIf
			(cAlsZaa)->(DbCloseArea())
			ErrorBlock(bBlock)
		RECOVER
			(cAlsZaa)->(DbCloseArea())
			ErrorBlock(bBlock)
		END SEQUENCE
	EndIf
return


static function qryZAA(cChave)
local cQuery	:= ""

	cQuery	:= " SELECT DISTINCT ZAA_CHAVE AS CHAVE, ZAA_CODPRO AS CODIGO, "
	cQuery 	+= " ZAA_NOME AS DESCRI, ZAA_SECAO AS SECAO, ZAA_BARINT AS CODBAR, ZAA_EAN AS CODEAN "
	cQuery	+= " FROM " + RetSqlName('ZAA')
	if !Empty(cChave)
		cQuery	+= " WHERE ZAA_CHAVE = '" + cChave + "' " 
		cQuery	+= " AND D_E_L_E_T_ = '' "
	else
		cQuery	+= " WHERE D_E_L_E_T_ = '' "
	endif
return cQuery


static function printZAA(cAls, cLocal)
Local cArq		:= 'ZZAPROD.xls'
Local cAba  	:= "Produtos"
Local cTabela	:= "Codigos"
Local nTotal	:= 0
Local nAtual	:= 0
Local oExcel	:= Nil
Local oExcelApp	:= Nil
Default cLocal	:= GetTempPath()

	oExcel  := FWMSExcel():New()
	oExcel:AddworkSheet(cAba)
	oExcel:AddTable(cAba,cTabela)
	oExcel:AddColumn(cAba,cTabela,"CHAVE",2,1,.F.) 
	oExcel:AddColumn(cAba,cTabela,"CODIGO",2,1,.F.) 
	oExcel:AddColumn(cAba,cTabela,"DESCRICAO",2,1,.F.) 
	oExcel:AddColumn(cAba,cTabela,"SECAO",2,1,.F.) 
	oExcel:AddColumn(cAba,cTabela,"CODBAR",2,4,.F.) 
	oExcel:AddColumn(cAba,cTabela,"CODEAN",2,4,.F.) 
	
	Count To nTotal
    ProcRegua(nTotal)
    
	(cAls)->(DBGOTOP())
	While !((cAls)->(Eof()))
	    oExcel:AddRow(cAba,cTabela,;
	    	{((cAls)->CHAVE),;
	        (cAls)->CODIGO,; 
	        (cAls)->DESCRI,; 
	        (cAls)->SECAO,; 
	        (cAls)->CODBAR,;
	        (cAls)->CODEAN})
	    (cAls)->(dbSkip())
	    nAtual++
	    IncProc("Gravando Registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
    End
    
    If !Empty(oExcel:aWorkSheet)
	    oExcel:Activate()
	    oExcel:GetXMLFile(cLocal+cArq)
	    If !ApOleClient("MSExcel")
	    	MsgAlert("Salvo em: " + cLocal+cArq, "MSExcel Nao Encontrado" )
	    	Return
	    Else
		    oExcelApp := MsExcel():New()
		    oExcelApp:WorkBooks:Open(cLocal+cArq)
		    oExcelApp:SetVisible(.T.)
	    EndIf
    EndIf

return 
