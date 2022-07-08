#INCLUDE 'Protheus.ch'
#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDEF.CH'  
#define CRLF Chr(13)+Chr(10)   
//envolvidas: SB1, SZ1, SZ2, SZ3, SZJ, ZAA


/*/{Protheus.doc} calcBarInt
@author bolognesi
@since 25/07/2017
@version 1.0
@param cCodProd, characters, Codigo produto
@param cEan, characters, Codigo EAN
@param cLocali, characters, Localização/Acondicionamento
@type function
@description CALCULAR O CODIGO DE BARRAS INTERNO 
/*/
Static Function calcBarInt(cCodProd, cEan, cLocali)
	Local cRetorno := ''
	Local cTamLance := Substr(cLocali,2,Len(cLocali)-1)
	Local nEtqAcond := At(Substr(cLocali,1,1), 'RCMBTL')

	If Left(cEan,9)=="789825925"
		cRetorno := "9"+Right( AllTrim(cEan),3) + Substr(cCodProd,09,2)+ cValToChar(nEtqAcond) +strzero(val(cTamLance),4) 
	Else
		cRetorno := Right(AllTrim(cEan),4) + Substr(cCodProd,09,2)+ cValToChar(nEtqAcond) +strzero(val(cTamLance),4)

	EndIf

Return cRetorno

/*/{Protheus.doc} criaTrbSb1
@author bolognesi
@since 25/07/2017
@version 1.0
@param cCod, characters, descricao
@type function
@description Cria arquivo trabalho com base select SB1 
/*/
Static Function criaTrbSb1(cCod)

	//Variaveis para query SB1
	//ETIQUETA
	Local cClasse 	:= 'CLASSE '
	Local cSessao 	:= 'SECAO:  '
	Local cX		:= 'X'
	Local cMm		:= '  mm²   '
	//Utlizar para concatenar desc3 SB1.B1_XDESIG	AS DESC3,
	Local cDesign   := 'DESIGNAÇÂO: '
	//WHERE
	Local cVazio	:= '' 
	Local cTpProd	:= 'PA' 
	Local nTam		:= '10' 
	Local cMSBLQL 	:= '1'
	Local cBLQVEN 	:= 'S'
	Default cCod	:= ""

	//Verifica se não existe antes de criar
	If Select("TRBSB1") > 0
		DbSelectArea("TRBSB1")

		//Fechar e excluir arquivo de trabalho
		TRBSB1->(dbclosearea())
		FErase( "TRBSB1" + GetDbExtension())	
	EndIf

	If Empty(cCod)

		//OBTER SB1 QUANDO CARGA INICIAL
		BeginSQL Alias "TRBSB1" 

		SELECT	%exp:cVazio% AS CHAVE,
		SB1.B1_COD AS CODPRO,
		SB1.B1_NORMA AS NORMA,	
		%exp:cVazio% AS EAN,
		Left(SB1.B1_CODBAR,12) AS BARB1, 
		%exp:cClasse% + SB1.B1_CLASENC AS CLASEN,
		SZ1.Z1_NOME AS NOME,
		%exp:cSessao%+ Convert(varchar(2),SZ1.Z1_VIAS)+%exp:cX%+SZ2.Z2_BITOLA+%exp:cMm%+ 

		CASE WHEN Len(SZ3.Z3_DESC)> 10 
		THEN 
		SZ3.Z3_APELIDO 
	ELSE 
		SZ3.Z3_DESC 
	END as SECAO,

	SZ1.Z1_DESC1 					AS DESC1, 
	SZ1.Z1_DESC2 					AS DESC2,
	SZ1.Z1_DESC2A					AS DESC2A,
	SB1.B1_BITOLA					AS BITOLA,

	%exp:cDesign% + SB1.B1_XDESIG	AS DESC3,
	%exp:cVazio% 					AS LOCALI,
	%exp:cVazio% 					AS BARINT,
	%exp:cVazio% 					AS MTR,
	SB1.B1_XREGINM 					AS CODINM,
	%exp:cVazio% 					AS LAYOUT,
	SB1.B1_XREGIN3 					AS CODIN3,
	SB1.B1_PESO						AS PESO,
	SB1.B1_UM						AS UMED

	FROM %Table:SB1% SB1

	INNER JOIN %Table:SZ1% SZ1 	ON SZ1.Z1_COD = SB1.B1_NOME
	INNER JOIN %Table:SZ2% SZ2 	ON SZ2.Z2_COD = SB1.B1_BITOLA
	INNER JOIN %Table:SZ3% SZ3	ON SZ3.Z3_COD = SB1.B1_COR                            

	WHERE SB1.B1_COD <> 	%exp:cVazio% 
	AND SB1.B1_TIPO = 		%exp:cTpProd% 
	AND SB1.B1_CODBAR <> 	%exp:cVazio% 
	AND Len(SB1.B1_COD) = 	%exp:nTam% 
	AND SB1.%NotDel%

	ORDER BY %Order:SB1,1%

	EndSql

	Else

		//OBTER SB1 QUANDO ATUALIZAÇÂO PELO PEDIDO
		BeginSQL Alias "TRBSB1" 

		SELECT	%exp:cVazio% AS CHAVE,
		SB1.B1_COD AS CODPRO,
		SB1.B1_NORMA AS NORMA,	
		%exp:cVazio% AS EAN,
		Left(SB1.B1_CODBAR,12) AS BARB1, 
		%exp:cClasse% + SB1.B1_CLASENC AS CLASEN,
		SZ1.Z1_NOME AS NOME,
		%exp:cSessao%+ Convert(varchar(2),SZ1.Z1_VIAS)+%exp:cX%+SZ2.Z2_BITOLA+%exp:cMm%+ 

		CASE WHEN Len(SZ3.Z3_DESC)> 10 
		THEN 
		SZ3.Z3_APELIDO 
	ELSE 
		SZ3.Z3_DESC 
	END as SECAO,

	SZ1.Z1_DESC1 					AS DESC1, 
	SZ1.Z1_DESC2 					AS DESC2,	
	SZ1.Z1_DESC2A					AS DESC2A,
	SB1.B1_BITOLA					AS BITOLA,

	%exp:cDesign% + SB1.B1_XDESIG	AS DESC3,
	%exp:cVazio% 					AS LOCALI,
	%exp:cVazio% 					AS BARINT,
	%exp:cVazio% 					AS MTR,
	SB1.B1_XREGINM 					AS CODINM,
	%exp:cVazio% 					AS LAYOUT,
	SB1.B1_XREGIN3 					AS CODIN3,
	SB1.B1_PESO						AS PESO,
	SB1.B1_UM						AS UMED

	FROM %Table:SB1% SB1

	INNER JOIN %Table:SZ1% SZ1 	ON SZ1.Z1_COD = SB1.B1_NOME                            
	INNER JOIN %Table:SZ2% SZ2 	ON SZ2.Z2_COD = SB1.B1_BITOLA
	INNER JOIN %Table:SZ3% SZ3	ON SZ3.Z3_COD = SB1.B1_COR                            

	WHERE SB1.B1_COD = 		%exp:cCod% 
	AND SB1.B1_TIPO = 		%exp:cTpProd% 
	AND SB1.B1_CODBAR 	<> 	%exp:cVazio% 
	AND len(SB1.B1_COD) = 	%exp:nTam% 
	AND SB1.%NotDel%                                   

	ORDER BY %Order:SB1,1%                       

	EndSql		

	EndIf

	TRBSB1->(msunlock())
Return NIL

/*/{Protheus.doc} criaTrbSdb
//TODO Descrição auto-gerada.
@author bolognesi
@since 25/07/2017
@version undefined
@param cCod, characters, descricao
@type function
@description Cria arquivo de trabalho com base select SDB (Usado somente carga inicial)
/*/
Static Function criaTrbSdb(cCod)
	//WHERE
	Local cVazio	:= ''  
	Local cInter	:= 'I' 
	Local cSC6 		:= 'SC6'
	Local cSD3		:= 'SD3'
	Local cBob 		:= 'B'  
	Local cR		:= 'R'
	Local cM        := 'M'
	Local cT        := 'T'

	//Verifica se não existe antes de criar
	If Select("TRBSDB") > 0
		DbSelectArea("TRBSDB")

		//Fechar e excluir arquivo de trabalho
		TRBSDB->(dbclosearea())
		FErase( "TRBSDB" + GetDbExtension())	
	EndIf

	//Obter informações do SDB
	BeginSQL Alias "TRBSDB"
	//column C5_ENTREG as Date 

	SELECT DISTINCT DB_PRODUTO AS CODPROD ,SDB.DB_LOCALIZ AS LOCALI

	FROM %Table:SDB% SDB

	WHERE SDB.DB_ESTORNO = %exp:cVazio%  
	AND SDB.DB_ORIGEM   IN (%exp:cSC6%,%exp:cSD3%)  
	AND SUBSTRING(SDB.DB_PRODUTO,11,1) <> %exp:cInter%
	AND SUBSTRING(SDB.DB_LOCALIZ,1,1) <> %exp:cBob%
	AND SUBSTRING(SDB.DB_LOCALIZ,1,1) IN (%exp:cR%,%exp:cM%,%exp:cT%)
	AND SDB.DB_PRODUTO = %exp:cCod%
	AND SDB.%NotDel%

	ORDER BY SDB.DB_PRODUTO, SDB.DB_LOCALIZ

	EndSql

Return NIL    

/*/{Protheus.doc} updZAA
@author bolognesi
@since 25/07/2017
@version undefined
@param cChave, characters, descricao
@param cCod, characters, descricao
@param cAcond, characters, descricao
@type function
@example u_updZAA("1010518165M01000","1010518165","M01000")
@description Atualizar ZAA, pelo pedido de venda MT410TOK
/*/
User Function updZAA(cChave,cCod,cAcond)
	Local _cBar100
	Local lUpd
	local oInt := cbcExpIntegra():newcbcExpIntegra(.F.)

	dbselectarea("ZAA") 		//TABELA DESTINO
	ZAA->(dbSetOrder(1))		//ZAA_FILIAL+ZAA_CHAVE
	dbselectarea("SZJ")			//EXCESSÔES
	SZJ->(dbsetorder(1)) 		//ZJ_FILIAL+ZJ_PRODUTO+ZJ_LOCALIZ

	//VERIFICA SE JÁ EXISTE NO ZAA, (EXISTE = ATUALIZAÇÂO, NÃO EXISTE = INCLUSÂO)
	If ZAA->(DbSeek(xFilial("ZAA")+cChave,.F.) )

		lUpd 	:= .F. //EXISTE FAZER UPDATE ( reclock("ZAA", .F.)) 
	Else

		lUpd	:= .T. //NÂO EXISTE INCLUIR ( reclock("ZAA", .T.))

	EndIf

	//CHAMA FUNÇAO OBTER SB1 DO PRODUTO
	criaTrbSb1(cCod)
	dbselectarea("TRBSB1")

	//TRATAR FIM ARQUIVO
	If TRBSB1->(eof() )
		Return nil
	EndIF

	If SZJ->(DbSeek(xFilial("SZJ")+Padr(TRBSB1->(CODPRO),TamSX3("B1_COD")[1])+"R00100",.F.))
		_cBar100 := Left(SZJ->ZJ_CODBAR,12)
	Else
		_cBar100 := Left(TRBSB1->BARB1,12)
	EndIf

	TRBSB1->(DbGoTop())
	SZJ->(DbGoTop())

	While !TRBSB1->(EOF())//DEVE TER SOMENTE UM REGISTRO

		//PROCURA POR INFORMAÇÔES DE EXESSÔES
		If SZJ->(DbSeek(xFilial("SB1")+TRBSB1->(CODPRO)+cAcond,.F.))

			//EXISTEM VARIAS OCORRENCIAS DO MESMO CODIGO PRODUTO SZJ(BUSCA TODAS)
			While SZJ->(ZJ_PRODUTO) == TRBSB1->(CODPRO) .AND. Alltrim(SZJ->(ZJ_LOCALIZ)) == Alltrim(cAcond)

				//GRAVA COM INFORMAÇÔES SZJ
				reclock("ZAA", lUpd)

				ZAA->(ZAA_CHAVE)		:= Alltrim(TRBSB1->CODPRO) + Alltrim(SZJ->ZJ_LOCALIZ)
				ZAA->(ZAA_CODPRO)		:= Transform(Alltrim(TRBSB1->(CODPRO)),"@R 999.99.99.9.99")
				ZAA->(ZAA_NORMA)		:= TRBSB1->(NORMA)

				//CALCULO MASSA BRUTA(ZAA_DMASSA) e MASSA LIQUIDA P/100m(ZAA_MASSA)
				ZAA->(ZAA_DMASSA)	:= Str(TRBSB1->(PESO) * Val(Substr(Alltrim(SZJ->ZJ_LOCALIZ),2,5)) * 0.94 ,6,2) + 'Kg'
				ZAA->(ZAA_MASSA)	:= Str(TRBSB1->(PESO) * 100 * 0.94 ,6,2) + 'Kg'

				ZAA->(ZAA_EAN)			:= Left(SZJ->ZJ_CODBAR,12)
				ZAA->(ZAA_CLASEN)		:= TRBSB1->(CLASEN)
				ZAA->(ZAA_NOME)			:= TRBSB1->(NOME)
				ZAA->(ZAA_SECAO)		:= TRBSB1->(SECAO)
				ZAA->(ZAA_DESC1)		:= TRBSB1->(DESC1)

				/*LEO - 09/09/16 - Atender Regra para descrição diferenciada para produtos até 1mm*/
				If Val(TRBSB1->(BITOLA)) > 03 
					ZAA->(ZAA_DESC2)	:= TRBSB1->(DESC2)
				Else
					If Empty(TRBSB1->(DESC2A))
						ZAA->(ZAA_DESC2)		:= TRBSB1->(DESC2)
					Else
						ZAA->(ZAA_DESC2)		:= TRBSB1->(DESC2A)
					EndIf
				EndIf
				/*FIM */

				ZAA->(ZAA_DESC3)		:= TRBSB1->(DESC3)
				ZAA->(ZAA_LOCALI)		:= Alltrim(SZJ->ZJ_LOCALIZ)
				ZAA->(ZAA_BARINT)		:= calcBarInt(TRBSB1->CODPRO,_cBar100, Alltrim(SZJ->ZJ_LOCALIZ))
				ZAA->(ZAA_MTR)			:= cValtoChar(val(Substring(Alltrim(SZJ->(ZJ_LOCALIZ)),2,Len(Alltrim(SZJ->(ZJ_LOCALIZ))) -1 ))) + ;
				If(Upper(TRBSB1->UMED)=="MT","m",If(Upper(TRBSB1->UMED)=="KG","kg",Lower(TRBSB1->UMED)))
				ZAA->(ZAA_CODINM)		:= TRBSB1->(CODINM)
				ZAA->(ZAA_CODIN3)		:= TRBSB1->(CODIN3)
				ZAA->(ZAA_VALID)		:= "VALIDADE: INDETERMINADA"
				ZAA->ZAA_LAYOUT			:= ""
				ZAA->ZAA_LZEBRA			:= ""

				//VERIFICA SE A NORMA DO PRODUTO PRECISA TEXTO RESISTENTE CHAMA
				If   "247-3" $ Right(Alltrim(TRBSB1->(NORMA)),5)

					ZAA->(ZAA_RCHAMA)	:= "RESISTENTE A PROPAGAÇÂO DE CHAMA"

				Else
					ZAA->(ZAA_RCHAMA)	:= ""

				EndIf

				ZAA->(msunlock())

				SZJ->(DbSkip())
			EndDo

		Else
			//GRAVA SOMENTE INFORMAÇÔES SB1
			reclock("ZAA", lUpd)

			ZAA->(ZAA_CHAVE)	:= Alltrim(TRBSB1->CODPRO) + cAcond
			ZAA->(ZAA_CODPRO)	:= Transform(Alltrim(TRBSB1->(CODPRO)),"@R 999.99.99.9.99")
			ZAA->(ZAA_NORMA)	:= TRBSB1->(NORMA)

			//CALCULO MASSA BRUTA(ZAA_DMASSA) e MASSA LIQUIDA P/100m(ZAA_MASSA)
			ZAA->(ZAA_DMASSA)	:= Str(TRBSB1->(PESO) * Val(Substr(Alltrim(cAcond),2,5)) * 0.94 ,6,2) + 'Kg'
			ZAA->(ZAA_MASSA)	:= Str(TRBSB1->(PESO) * 100 * 0.94 ,6,2) + 'Kg'

			ZAA->(ZAA_EAN)		:= Left(TRBSB1->BARB1,12)
			ZAA->(ZAA_CLASEN)	:= TRBSB1->(CLASEN)
			ZAA->(ZAA_NOME)		:= TRBSB1->(NOME)
			ZAA->(ZAA_SECAO)	:= TRBSB1->(SECAO)
			ZAA->(ZAA_DESC1)	:= TRBSB1->(DESC1)

			/*LEO - 09/09/16 - Atender Regra para descrição diferenciada para produtos até 1mm*/
			If Val(TRBSB1->(BITOLA)) > 03 
				ZAA->(ZAA_DESC2)	:= TRBSB1->(DESC2)
			Else
				If Empty(TRBSB1->(DESC2A))
					ZAA->(ZAA_DESC2)		:= TRBSB1->(DESC2)
				Else
					ZAA->(ZAA_DESC2)		:= TRBSB1->(DESC2A)
				EndIf
			EndIf
			/*FIM */

			ZAA->(ZAA_DESC3)	:= TRBSB1->(DESC3)
			ZAA->(ZAA_LOCALI)	:= cAcond
			ZAA->(ZAA_BARINT)	:= calcBarInt(TRBSB1->CODPRO,_cBar100,cAcond)
			ZAA->(ZAA_MTR)		:= cValtochar( val(Substr(cAcond,2,Len(cAcond) -1))) + ;
			If(Upper(TRBSB1->UMED)=="MT","m",If(Upper(TRBSB1->UMED)=="KG","kg",Lower(TRBSB1->UMED)))
			ZAA->(ZAA_CODINM)	:= TRBSB1->(CODINM)
			ZAA->(ZAA_CODIN3)	:= TRBSB1->(CODIN3)
			ZAA->(ZAA_VALID)	:= "VALIDADE: INDETERMINADA"
			ZAA->ZAA_LAYOUT			:= ""
			ZAA->ZAA_LZEBRA			:= ""

			//VERIFICA SE A NORMA DO PRODUTO PRECISA TEXTO RESISTENTE CHAMA
			If  "247-3" $ Right(Alltrim(TRBSB1->(NORMA)),5)

				ZAA->(ZAA_RCHAMA)	:= "RESISTENTE A PROPAGAÇÂO DE CHAMA"
			Else
				ZAA->(ZAA_RCHAMA)	:= ""
			EndIf
			ZAA->(msunlock())
		EndIF		
    	oInt:addProd('ZAA', ZAA->(Recno()), .T.)
		TRBSB1->(dbskip())
	EndDo
	FreeObj(oInt)
	//FECHA OS ARQUIVOS
	TRBSB1->(dbCloseArea())

	//APAGA O ARQUIVOS
	FErase( "TRBSB1" + GetDbExtension())

Return Nil 

/*/{Protheus.doc} tempZAA
@author bolognesi
@since 25/07/2017
@version 1.0
@type function
@description 
utilizado somente para acertar zaa que pelo pedido estava gravando
bobinas o que neste momento nâo precisamos
exemplo para percorrer tabela
/*/
User Function tempZAA()

	dbselectarea("ZAA") 		//TABELA DESTINO
	ZAA->(dbSetOrder(1))		//ZAA_FILIAL+ZAA_CHAVE

	ZAA->(DbGoTop())

	While !ZAA->(EOF())	

		If  Substr(Alltrim(ZAA->(ZAA_CHAVE)),11,1) == 'B' .OR. Substr(Alltrim(ZAA->(ZAA_CHAVE)),11,1) == '0'

			reclock("ZAA", .F.)

			ZAA->(DbDelete())

			ZAA->(MsUnlock())    

		EndIF

		ZAA->(DbSkip())

	EndDo	

Return Nil      

/*/{Protheus.doc} fCadEtq
@author bolognesi
@since 25/07/2017
@version 1.0
@type function
@description 
Rotina para cadastramento manual de etiquetas ZAA
Imprimir utilizando software Colos na Zebra
/*/
User Function fCadEtq()

	Local aButtons 	:= {}
	Local oCmbAcond
	Local oGet1          
	Local oGetProd
	Local oSay2
	Local oSay3
	Static oDlg   

	//UTILIZADAS EM OUTRA FUNÇÂO PARA LIMPAR A TELA
	Private nGetProd 	:= space(10)
	Private nCmbAcond 	:= 1
	Private nGet1 		:= space(5)
	Private oSay1

	DEFINE MSDIALOG   oDlg TITLE "Cadastro Etiquetas" FROM 000, 000  TO 500, 500 COLORS 0, 16777215 PIXEL

	@ 030, 050 SAY oSay1 PROMPT "Codigo do Produto:" SIZE 067, 008 OF oDlg COLORS 0, 16777215 PIXEL
	@ 028, 114 MSGET oGetProd VAR nGetProd SIZE 097, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 045, 050 SAY oSay2 PROMPT "Acondicionamento" SIZE 048, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 064, 050 SAY oSay3 PROMPT "Metragem" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 042, 114 MSCOMBOBOX oCmbAcond VAR nCmbAcond ITEMS {"R","C","M","T","L"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 060, 114 MSGET oGet1 VAR nGet1 SIZE 057, 010 OF oDlg COLORS 0, 16777215 PIXEL

	EnchoiceBar(oDlg, {||fChamaRot(nGetProd,nCmbAcond,nGet1)}, {||oDlg:End()},,aButtons)

	ACTIVATE MSDIALOG oDlg CENTERED

Return

/*/{Protheus.doc} fChamaRot
@author bolognesi
@since 25/07/2017
@version 1.0
@param _nGetProd, , descricao
@param _nCmbAcond, , descricao
@param nMetragem, numeric, descricao
@type function
/*/
Static Function fChamaRot(_nGetProd,_nCmbAcond,nMetragem)                                           
	Local cCodProd 	:= Left(cValtoChar(Alltrim(_nGetProd)),10)
	//Verifico pois o combobox quando seleciona primeiro elemento retorna numero
	Private cAcond	:=  IIF (valtype(_nCmbAcond)=='N','R' + strzero(val(nMetragem),5), _nCmbAcond + strzero(val(nMetragem),5) )
	Private cChave	:= cCodProd + cAcond

	dbselectarea("SB1")			//PRODUTOS
	SB1->(dbsetorder(1)) 		//B1_FILIAL+B1_COD

	//Validar campos preenchidos
	If  empty(nGetProd) .OR. empty(nCmbAcond) .OR. empty(nMetragem)
		alert("Preencha todos os campos")
	Else
		//Validar o produto
		If SB1->(DbSeek(xFilial("SB1") + cCodProd + space(Len(SB1->B1_COD) - Len(cCodProd) ),.F.)) 

			//ATUALIZA O ZZA
			u_updZAA(cChave,cCodProd,cAcond )

			//AVISAR ATUALIZAÇÂO
			MessageBox("Procedimento completo","Aviso",0)

			//LIMPAR A TELA
			nGetProd 	:= space(10)
			nCmbAcond 	:= 1
			nGet1 		:= space(5)

			//FOCO NO PRIMEIRO GET oSay1    
			//oDlg:oSay1:SetFocus()
			oSay1:SetFocus()

		Else
			alert("Produto não encontrado")
		EndIf

	EndIf

return(.T.)

/*/{Protheus.doc} valAcond
@author bolognesi
@since 25/07/2017
@version undefined
@param nMetrage, numeric, descricao
@type function
@description 
validar o acondicionamento x metragem
(ver logica em cdfatv02)
/*/
Static Function valAcond(nMetrage)

	Local nMax 		:= 0
	Local lret 	

	If Left(cAcond,1,1) == "R"
		nMax := SB1->(B1_ROLO)
	ElseIf Left(cAcond,1,1) == "C"
		nMax := SB1->(B1_CARRETE)
	ElseIf Left(cAcond,1,1) == "M"
		nMax := SB1->(B1_CARMAD)
	ElseIf Left(cAcond,1,1) == "T" // Retalho
		nMax := 99
	ElseIf Left(cAcond,1,1) == "L" // BLISTER
		nMax := u_getMaxMetrage( /*Prod*/, Left(cAcond,1,1))
	EndIf                                  

	lret := (nMax >= nMetrage)
	
	lret := u_cbcAcInf(Alltrim(SB1->B1_COD), (Left(cAcond,1,1)+StrZero(nMetrage,5)), nMetrage, 1, nMetrage, .F., .T.)[1]
	
Return(lret)

/*/{Protheus.doc} manutZAA
@author bolognesi
@since 25/07/2017
@version 1.0
@param cProd, characters, descricao
@type function
/*/
User Function manutZAA(cProd)
	Local cSQL		:= ""
	Default cProd 	:= ""

	//CONDIÇÃO PARA EXIBIR AJUDA
	If cProd == "HELP"            
		MessageBox(  "NESTA FUNÇÂO PODEMOS PASSAR CODIGO DO PRODUTO VIA PARAMETRO         			" 		+ CRLF;			
		+ "LEMBRANDO QUE O CODIGO DO PRODUTO NA ZAA TEM PONTOS EX NNN.NNN.NNN.NN      	"		+ CRLF;
		+ "EXEMPLOS DE CHAMADA:                                                       	" 		+ CRLF;
		+ " U_manutZAA('101.04.01.1.01')												"		+ CRLF;
		+ " ATUALIZA SOMENTE PRODUTOS DESTE CODIGO										"       + CRLF;
		+ "SENDO O PADRÃO DESTA FUNÇÃO, ATUALIZAR TODA A TEBELA ZAA						"		+ CRLF,;
		"AJUDA PROGRAMA", 01 )
		Return Nil
	EndIf

	//FECHAR CASO EXISTA
	If Select( "ETQZAA") > 0
		ETQZAA->(dbcloseArea())
		FErase( "ETQZAA" + GetDbExtension())
	End If

	//OBTEM WHERE DO PARAMETRO
	If !Empty(cProd)
		cSQL += "AND ZAA_CODPRO = '" +  Alltrim(cProd) + "'"
		cSQL := "%"+cSQL+"%"

		//CONSULTA WHERE QUE VEM DO PARAMETRO
		BeginSQL Alias "ETQZAA"

		SELECT  ZAA_CHAVE,ZAA_CODPRO,ZAA_LOCALI 
		FROM %table:ZAA% ZAA
		WHERE %NotDel% %Exp:cSQL%
		ORDER BY ZAA_FILIAL+ZAA_CHAVE
		EndSql
	Else
		//CONSULTA TODOS OS REGISTROS DA TABELA
		BeginSQL Alias "ETQZAA"

		SELECT  ZAA_CHAVE,ZAA_CODPRO,ZAA_LOCALI 
		FROM %table:ZAA% ZAA
		WHERE %NotDel%
		ORDER BY ZAA_FILIAL+ZAA_CHAVE
		EndSql
	EndIf

	ETQZAA->(DbGotop())

	//REALIZA O PROCESSO
	If ETQZAA->(!eof())
		Processa( {|| LoteZAA(Contar("ETQZAA","!Eof()")) },"Etiquetas Produtos","Atualizando aguarde...", .F. )    
		MessageBox("<html>[AVISO] - <b>Atualização concluida!</b></html>", "Aviso",01)
	EndIf

	If Select( "ETQZAA") > 0
		ETQZAA->(dbcloseArea())
		FErase( "ETQZAA" + GetDbExtension())
	End If

Return Nil

/*/{Protheus.doc} LoteZAA
@author bolognesi
@since 25/07/2017
@version 1.0
@param nReg, numeric, descricao
@type function
/*/
Static Function LoteZAA(nReg)
	ProcRegua(nReg)
	ETQZAA->(DbGotop())
	While ETQZAA->(!Eof())
		u_updZAA( ETQZAA->(ZAA_CHAVE),StrTran(ETQZAA->(ZAA_CODPRO),"."),ETQZAA->(ZAA_LOCALI) )
		IncProc("Atualizando....")
		ETQZAA->(DbSkip())
	EndDo

Return Nil

/*/{Protheus.doc} menuZAA
@author bolognesi
@since 25/07/2017
@version 1.0
@type function
@description utilizado no menu permitindo a atualizaçâo da tabela zaa(conforme alteraçâo nos produtos)
/*/
User Function menuZAA()
	Local aRet 		:= {}
	Local aPergs	:= {}
	Local cCod		:= ""

	aAdd(aPergs,{1,"Cod.Produto"  ,Space(TAMSX3("B1_COD")[1]),"","","","",50,.F.})

	If ParamBox(aPergs ,"Atualização etiquetas de produtos ",@aRet)      
		If !Empty(aRet[1])
			cCod := Transform(aRet[1],"@R 999.99.99.9.99")
		EndIf
		U_manutZAA(Alltrim(cCod))
	EndIf

Return Nil     

/*/{Protheus.doc} NextEan
@author bolognesi
@since 25/07/2017
@version 1.0
@type function
@description
Usar esta função somente em rotinas pois não tem a possibilidade
de dar um RollBack no SX8 - (NÃO USAR EM AXINCLUI)
/*/
User Function NextEan()
	_aArea1 := GetArea()

	DbSelectArea("SB1")
	_aArea2 := GetArea()
	DbSetOrder(5) // B1_FILIAL+SB1->B1_CODBAR

	DbSelectArea("SZJ")
	_aArea3 := GetArea()
	DbSetOrder(2) // ZJ_FILIAL+ZJ_CODBAR

	_cNxtEan := "789967470659" //GetSx8Num("_CB")  
	//_cNxtEan := GetSx8Num("_CB")  
	_cNxtDig := eandigito(trim(_cNxtEan))

	Do While (SB1->(DbSeek(xFilial("SB1")+_cNxtEan+_cNxtDig,.F.))) .Or. ;
	(SZJ->(DbSeek(xFilial("SZJ")+_cNxtEan+_cNxtDig,.F.)))
		// Como o número foi localizado, confirma e pega outro número
		//	ConFirmSX8()
		//	_cNxtEan := GetSx8Num("_CB")
		_cNxtEan := StrZero(Val(_cNxtEan) + 1,12)
		_cNxtDig := eandigito(trim(_cNxtEan))
	EndDo   
	//ConFirmSX8()

	RestArea(_aArea3)
	RestArea(_aArea2)
	RestArea(_aArea1)
Return(_cNxtEan+_cNxtDig)
