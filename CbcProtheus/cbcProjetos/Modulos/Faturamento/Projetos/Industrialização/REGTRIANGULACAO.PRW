#INCLUDE 'Protheus.ch'
#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "tbiconn.ch"
#define CRLF Chr(13)+Chr(10)


**************************************************************************
User Function regraTri()
	**************************************************************************
	Private oMark
	Private cMarkDestino 	:= ""
	Private oFont 		:= TFont():New( "Arial", , -12, .T.)
	Private cCadastro := "Aprova��o Regra Triangula��o"
	Private aRotina		:= MenuDef()

	DbSelectArea("SCJ")
	SCJ->(DbSetOrder(01)) //CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA

	// Instanciamento do classe
	oMark := FWMarkBrowse():New()
	// Defini��o da tabela a ser utilizada
	oMark:SetAlias('SCJ')
	//Defini a fonte utilizada
	oMark:SetFontBrowser(oFont)

	// Define a titulo do browse de marcacao
	oMark:SetDescription('Or�amentos aguardando aprova��o (Fora da Regra)')

	// Define o campo que sera utilizado para a marca��o
	oMark:SetFieldMark( 'CJ_ZZOK' )

	cFiltro := 	"  CJ_ZZSTS == 'S' " 
	cFiltro +=	" .And. (CJ_STATUS == 'A' .Or. CJ_STATUS == 'D')"

	// Defini��o do filtro de aplicacao
	oMark:SetFilterDefault( cFiltro )

	oMark:SetOnlyFields({'CJ_EMISSAO','CJ_NUM', 'CJ_NOMCLI', 'CJ_ZZDESCR',  'CJ_DTINC', 'CJ_USERINC'})

	//Definir o menu a utilizar
	oMark:SetMenuDef("REGTRIANGULACAO")

	oMark:SetSemaphore(.F.)

	//Executado logo apos a marca��o Individual
	oMark:SetAfterMark( {|| recMarca()} )

	//Desabilitando marca todos canto browser
	oMark:SetAllMark( {|| U_TudoMarca() }  )


	// Ativacao da classe
	oMark:Activate()
	Return nil

	*****************************
Static Function MenuDef()
	*****************************
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Rejeitar' 			ACTION  "U_gerMark('R')" 	OPERATION 10  ACCESS 0
	ADD OPTION aRotina TITLE 'Aprovar' 				ACTION  "U_gerMark('A')" 	OPERATION 10  ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' 			ACTION  "A415Visual" 		OPERATION 2   ACCESS 0 
	ADD OPTION aRotina TITLE 'Marca Tudo' 			ACTION  "U_TudoMarca()" 	OPERATION 10  ACCESS 0 
	ADD OPTION aRotina TITLE 'Fechar' 				ACTION  "U_fchMark()" 		OPERATION 10  ACCESS 0

	Return aRotina                          

	*************************************
User Function fchMark()
	*************************************

	CloseBrowse()	

	Return nil


	************************************
Static Function recMarca()
	//FWMarkBrowser n�o gera a marca��o como o esperado
	//Fiz a marca��o eu mesmo
	************************************

	//Verifica se o registro esta marcado
	If oMark:IsMark()

		reclock("SCJ", .F.)
		SCJ->CJ_ZZOK := oMark:Mark() //Chumba a marca
		SCJ->(Msunlock())

	Else
		reclock("SCJ", .F.)
		SCJ->CJ_ZZOK := ""  //Quando desmarcar o registro retira a marca
		SCJ->(Msunlock())
	EndIf    

	Return Nil

	************************************
User Function TudoMarca()
	�************************************
	//Utilizado para marcar quando selecionado todos
	Local nRegAtual
	Local lMarca := .T.

	oMark:SetInvert(.T.)
	oMark:AllMark()

	//Posiciona no primeiro do browser
	oMark:GoTop(.T.)
	//Obtem o numero do registro
	nRegAtual := oMark:At()

	//Percorrer os registros do browser 
	While .T.

		//Verifica se o registro esta marcado
		If oMark:IsMark()

			reclock("SCJ", .F.)
			SCJ->CJ_ZZOK := ""  //Quando desmarcar o registro retira a marca
			SCJ->(Msunlock()) 
			lMarca := .F.

		Else
			reclock("SCJ", .F.)
			SCJ->CJ_ZZOK := oMark:Mark() //Chumba a marca
			SCJ->(Msunlock()) 

		EndIf    

		//Passa para o proximo registro 
		oMark:GoDown(1, .F.)

		//Saida do loop Desceu um registro e continuou no mesmo significa que � o ultimo
		If nRegAtual == oMark:At()

			EXIT

		EndIf

		//Obtem o numero do registro para comparar se � o ultimo
		nRegAtual := oMark:At() 

	EndDo

	//Atualiza Browser e posiciona no primeiro
	oMark:Refresh(.T.)

	Return Nil

	*************************************
Static Function ModelDef()
	*************************************
	Local oStruSCJ := FWFormStruct( 1, 'SCJ' )
	Local oModel // Modelo de dados que será construído

	oModel := MPFormModel():New('COMP012M' )
	oModel:AddFields( 'SCJMASTER', /*cOwner*/, oStruSCJ)
	oModel:SetDescription( 'Regra Triangula��o' )
	oModel:GetModel( 'SCJMASTER' ):SetDescription( 'Regra Triangula��o' )

	Return oModel

	********************************
Static Function ViewDef()
	********************************
	Local oModel := FWLoadModel( 'REGTRIANGULACAO' )
	Local oStruSCJ := FWFormStruct( 2, 'SCJ' )
	Local oView

	oView := FWFormView():New()
	oView:SetModel( oModel )
	oView:AddField( 'VIEW_SCJ', oStruSCJ, 'SCJMASTER' )
	oView:CreateHorizontalBox( 'TELA' , 100 )
	oView:SetOwnerView( 'VIEW_SCJ', 'TELA' )


	Return oView

	****************************
User Function gerMark(cStatus)
	****************************
	Local aArea 		:= GetArea()
	Local aTmpArea		:= {}
	Local cMarca 		:= oMark:Mark()
	Local aRet 			:= {}
	Local aPergs		:= {}
	Local cMsg			:= ""
	Local cRegSol		:= ""
	Local cNomCli		:= ""
	Local cAssina		:= ""
	Local dHora			:= ""
	Local cMailRet		:= ""
	Local lMsgUni		:= .T. 

	DbSelectArea("SCJ")
	SCJ->(DbSetOrder(01)) //CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA

	If Select( "TRBSCJ") > 0
		TRBSCJ->(dbcloseArea())
		FErase( "TRBSCJ" + GetDbExtension())
	End If

	cSQL := " AND SCJ.CJ_ZZOK = '" + cMarca + "'"
	cSQL := "%"+cSQL+"%"

	BeginSQL Alias "TRBSCJ"

	SELECT SCJ.CJ_ZZOK,SCJ.R_E_C_N_O_
	FROM %Table:SCJ% SCJ
	WHERE SCJ.CJ_FILIAL = %xFilial:SCJ% AND SCJ.%NotDel% %exp:cSQL%
	ORDER BY %Order:SCJ,1%

	EndSql

	DbSelectArea("SCJ")
	DbSelectArea("TRBSCJ")
	TRBSCJ->(DbGotop())

	If TRBSCJ->(EOF())

		Alert("Selecione um ao menos um or�amento")
		Return NIL	

	EndIf 

	While !TRBSCJ->(EOF())
		//Ele realiza a compara��o da marca��o do arquivo TRBSCJ
		If TRBSCJ->(CJ_ZZOK) == cMarca //oMark:IsMark(cMarca)

			SCJ->( dbgoto( TRBSCJ->(R_E_C_N_O_)  ) )

			aTmpArea := GetArea()
			cRegSol 	:= Alltrim(posicione("SX5",1,XFILIAL("SX5")+'Z7'+SCJ->CJ_ZZAPR,"X5_DESCRI"))  
			Restarea(aTmpArea)

			cAssina 	:= Alltrim( UsrRetName(__CUSERID))
			dDt			:= Alltrim(cValToChar(Date()))
			dHora		:= Alltrim(cValToChar(Time()))

			reclock("SCJ", .F.)
			SCJ->CJ_ZZSTS 	:= cStatus	

			if cStatus $ 'R'

				SCJ->CJ_ZZAPR := ""


			ElseIf cStatus $ 'A'

				SCJ->(CJ_ZZREGAP) :=  Alltrim(SCJ->(CJ_NUM)) + " ; " + cAssina + " ; " + dDt + " ; " + dHora   

			endIf

			SCJ->CJ_ZZOK	:= ""
			SCJ->(msunlock())

			aTmpArea := GetArea()
			cNomCli 	:= Alltrim(POSICIONE("SA1",1,XFILIAL("SA1")+SCJ->CJ_CLIENTE+SCJ->CJ_LOJA,"A1_NOME") )		 
			Restarea(aTmpArea)

			if cStatus $ 'A'
				cStatus := 'APROVADO'
			elseIf cStatus $ 'R'
				cStatus := 'REJEITADO'
			EndIf

			If lMsgUni
				aAdd(aPergs,{11,"Mensagem","",".T.",".T.",.F.})
				If ParamBox(aPergs ,"Mensagem do aprovador ",@aRet)      

					If !Empty(aRet[1]) 
						cMsg := Alltrim(aRet[1])
					End If

					lMsgUni := .F. //Unica mensagem para todos as aprova��es	

				EndIf
			EndIf	    

			//CJ_MAILRET		 
			If Empty( SCJ->CJ_MAILRET )
				cMailRet := "leonardo@cobrecom.com.br"
			Else
				cMailRet := Alltrim(SCJ->CJ_MAILRET)
			EndIf


			aEmail := { {Alltrim(SCJ->(CJ_NUM)), cNomCli , cRegSol, cStatus, cMsg, cAssina,dDt,dHora  }  }
			u_envmail({cMailRet}, "[ STATUS -(RETORNO DO APROVADOR) ] - OR�. NRO. " + Alltrim(SCJ->(CJ_NUM)), {"Or�amento","Cliente","Solicitado","Status","Msg Aprovador","Aprovador(a)","Data", "Hora"},aEmail)

		EndIf
		TRBSCJ->( dbSkip() )
	EndDo   


	RestArea(aArea)

Return NIL                                                        