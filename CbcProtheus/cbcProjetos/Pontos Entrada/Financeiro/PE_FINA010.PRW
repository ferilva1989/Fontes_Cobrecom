
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FIN010    ºAutor  ³Leonardo Bolognesi  º Data ³  08/15/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc. Utilizado para ao incluir uma natureza no SED utilizamdo o pontoÍ¹±±
±±ºde entrada FIN010INC para tambem incluir uma classe de valor utilizando¹±±
rotina padrão CTBA60 que inclui no CTH                                    º±±
º±±Tabelas: SED/CTH                                                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso Financeiro/Contabilidade   ³ AP                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FIN010INC  //Executa no momento da inclusão da natureza(quando em processamento)

//Preserva as areas
Local _aArea   	:= GetArea()
Local _aAreaSED := SED->(GetArea())
Local _aAreaCTH := CTH->(GetArea())
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

DbSelectArea("SED")

aDadosAuto:= { 	{'CTH_CLVL' 	 	, SED->(ED_CODIGO) 		, Nil},;
				{'CTH_CLASSE' 		, SED->(ED_TIPO) 		, Nil},;
				{'CTH_DESC01' 		, SED->(ED_DESCRIC)		, Nil},;
				{'CTH_CLSUP'  		, SED->(ED_PAI) 		, Nil}}

Begin Transaction

MSExecAuto({|x, y| CTBA060(x, y)},aDadosAuto, 3)

//Verifica se executou a rotina corretamente
If lMsErroAuto
	DisarmTransaction()
	mostraerro()
Else
	//OK
	//Preencher o campo com o classe de valor recem criada
	SED->(DbSetOrder(1)) // ED_FILIAL = ED_CODIGO
	
	If SED->(dbseek(xFilial("SED")+ SED->(ED_CODIGO), .F.) )
		reclock("SED",.F.)
		SED->(ED_CLVLDB) := SED->(ED_CODIGO)
		SED->(msunlock())
	EndIf
	
EndIf

End Transaction
//Devolve as areas
RestArea(_aArea)
RestArea(_aAreaSED)
restArea(_aAreaCTH)

Return NIL

User Function FIN010EXC //Exclusão no cadastro de naturezas

//Preserva as areas
Local _aArea   	:= GetArea()
Local _aAreaSED := SED->(GetArea())
Local _aAreaCTH := CTH->(GetArea())
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.

DbSelectArea("CTH")
CTH->(DbSetOrder(1)) // CTH_FILIAL + CTH_CLVL

If CTH->(dbseek(xFilial("CTH")+ SED->(ED_CODIGO), .F.) )
	
	aDadosAuto:= { {'CTH_CLVL'   , SED->(ED_CODIGO) , Nil},;
	{'CTH_CLASSE' , SED->(ED_TIPO) 	, Nil},;
	{'CTH_DESC01' , SED->(ED_DESCRIC), Nil},;
	{'CTH_CLSUP'  , SED->(ED_PAI) 	, Nil}}
	
	//1=Pesquisa
	//2=Visualização
	//3=Inclusão
	//4=Alteração
	//5=Exclusão
	Begin Transaction
	
	MSExecAuto({|x, y| CTBA060(x, y)},aDadosAuto, 5)
	
	//Verifica se executou a rotina corretamente
	If lMsErroAuto
		DisarmTransaction()
	EndIf
	
	End Transaction
	
EndIf

//Devolve as areas
RestArea(_aArea)
RestArea(_aAreaSED)
restArea(_aAreaCTH)

Return NIL          


//ACERTOS PONTUAIS APAGAR - UTILIZADO SOMENTE UMA VEZ
******************************************
User Function acertaNatu(lFazE2)      // U_acertaNatu(.F.) ou U_acertaNatu 
******************************************
Local cLog 			:= ""
Local aRet			:= {}
Local aPBox			:= {}
Private lMsErroAuto := .F.
Private lMsHelpAuto := .T.


DbSelectArea("CTH")
CTH->(DbSetOrder(1)) // CTH_FILIAL + CTH_CLVL

DbSelectArea("SED")
SED->(DbSetOrder(1)) // ED_FILIAL+ED_CODIGO

DbSelectArea("SE2")
SE2->(DbSetOrder(1)) // E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA

SED->( DbGoTop() )

While SED->(!eof())
    
    If CTH->(!dbseek(xFilial("CTH")+ SED->(ED_CODIGO), .F.) )
	
			
	    cLog +=  Alltrim( SED->(ED_CODIGO) ) + "; " + chr(13)+chr(10)
		
		aDadosAuto:= { 	{'CTH_CLVL'   , SED->(ED_CODIGO) 	, Nil},;
						{'CTH_CLASSE' , SED->(ED_TIPO) 		, Nil},;
						{'CTH_DESC01' , SED->(ED_DESCRIC)	, Nil},;
						{'CTH_CLSUP'  , SED->(ED_PAI) 		, Nil}}
		
		//1=Pesquisa
		//2=Visualização
		//3=Inclusão
		//4=Alteração
		//5=Exclusão
		Begin Transaction
		
		MSExecAuto({|x, y| CTBA060(x, y)},aDadosAuto, 3)
		 
		If  Alltrim( SED->(ED_CODIGO) ) $ "D1001/D1002/D1003" 
		
			mostraerro()
		
		EndIF
		
		//Verifica se executou a rotina corretamente
		If lMsErroAuto
			DisarmTransaction()
		EndIf
		
		
		End Transaction               

	EndIf
	
	SED->(DbSkip()) //PROXIMO REGISTRO

EndDo                 
	//Alert(cLog)
	aAdd(aPBox,{11,"Copiar Erro",cLog,".T.",".T.",.T.})
    ParamBox(aPBox,"Teste Parâmetros...",@aRet)


//ACERTOS NO SE2
If lFazE2

	SE2->( DbGoTop() )
	
	While SE2->(!eof())
		
		reclock("SE2", .F.)
		SE2->E2_CLVLDB := SE2->E2_NATUREZ
		SE2->( msunlock() )
	    
		SE2->(dbskip())
	EndDo
	
	SE2->(dbclosearea())
EndIF

Return nil

********************************************
User Function acertSED(cAntigo, cNovo)
********************************************
//ATUALIZAÇÕES NATUREZAS ANTIGAS PARA CLASSES DE VALORES NOVAS
//ACERTAR TAMBEM NOS TITULOS
//CHAMADA VIA EXCEL

Local cRetorno := ""

DbSelectArea("SED")
SED->(DbSetOrder(1)) //ED_FILIAL+ED_CODIGO

DbSelectArea("SE1")
SE1->(DbSetOrder(3))//E1_FILIAL+E1_NATUREZ+E1_NOMCLI+E1_PREFIXO+E1_NUM+E1_TIPO

DbSelectArea("SE2")
SE1->(DbSetOrder(2))//E2_FILIAL+E2_NATUREZ+E2_NOMFOR+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE
 	
    If SED->(dbseek(xFilial("SED")+ cAntigo + Space( (TamSX3("ED_CODIGO")[1] - Len(cAntigo)) ), .F.) )
    
    	SED->(RecLock("SED",.F.))
    	SED->(ED_CLVLDB) := cNovo 
        SED->(MsUnlock())
    
   		//Fechar e excluir arquivo de trabalho
		If Select( "TRBSE2") > 0
			TRBSE2->(dbcloseArea())
			FErase( "TRBSE2" + GetDbExtension())
		End If
   		
   		//ATUALIZAR OS TITULOS PAGAR 
		cSQL := " AND SE2.E2_NATUREZ =  '" + cAntigo + "'"
	   //	cSQL += " AND SE2.E2_SALDO > 0 "
		cSQL := "%"+cSQL+"%"

		//Consulta no banco
		BeginSQL Alias "TRBSE2"
	
			SELECT SE2.R_E_C_N_O_
			FROM %Table:SE2% SE2
			WHERE SE2.E2_FILIAL = %xFilial:SE2% AND SE2.%NotDel% %exp:cSQL%
			ORDER BY %Order:SE2,2%
		
		EndSql
   		
   		DbSelectArea("TRBSE2")
   		TRBSE2->(DbGoTop())
   		 
   		If TRBSE2->(EOF())
   			
   			Return "NÂO ACHOU TITULO"
   		
   		EndIf
   		
   		While TRBSE2->(!EOF())
   		
   			SE2->(DbGoto(TRBSE2->(R_E_C_N_O_) ) )
   			
   			SE2->(RecLock("SE2",.F.))
    		SE2->(E2_CLVLDB) := cNovo 
        	SE2->(MsUnlock())	
   		
   		TRBSE2->(DbSkip())
   		
   		EndDo
   		
   		cRetorno := "Antigo:  " + cAntigo + "   Novo:  " + cNovo + "CONCLUIDO"
    
    Else
    
    	cRetorno := "Antigo:  " + cAntigo + "   Novo:  " + cNovo + "NÂO ENCONTRADO"

    EndIF

Return cRetorno