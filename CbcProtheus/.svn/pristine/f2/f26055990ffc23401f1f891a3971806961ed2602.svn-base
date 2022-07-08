#include "protheus.ch"
#include "topconn.ch"

user function CREST17()

	local cAlias := "ZZX"
	local cFiltro := ""
	local aIndex  := {}

	Private cCadastro 	:= "Atendente x Representantes"
	Private aRotina 	:= {}
	Private bFiltraBrw := { || FilBrowse( cAlias , @aIndex , @cFiltro ) }

	AAdd( aRotina, {"Pesquisar","AxPesqui",0,1} )
	AAdd( aRotina, {"Visualizar","AxVisual",0,2} )
	AAdd( aRotina, {"Inserir","u_CRE17Inc",0,3} )
	AAdd( aRotina, {"Editar","u_CRE17Inc",0,4} )
	AAdd( aRotina, {"Excluir","u_CRE17Inc",0,5} )

	cFiltro := "ZZX_SSL=='S'"
	Eval(bFiltraBrw)
	mBrowse(6,1,22,75,cAlias,,,,,,)
	EndFilBrw(cAlias,@aIndex)

return


user function CRE17Inc(cAlias, nreg, nopc)

	local aArea := GetArea()
	local cQry, nQry

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Opcao de acesso para o Modelo 2                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// 3,4 Permitem alterar getdados e incluir linhas
	// 6 So permite alterar getdados e nao incluir linhas
	// Qualquer outro numero so visualiza
	default nOpc:=3

	dbselectarea("SA3")
	dbsetorder(1)

	aHeader := {}
	aCols	:= {}
	AAdd( aHeader, {"Representante","ZZX_REPRE","@!",TAMSX3("ZZX_REPRE")[1],0,"","€€€€€€€€€€€€€€ ","C","SA3","R"} )
	AAdd( aHeader, {"Nome","ZZX_NOMEE","@!",TAMSX3("ZZX_REPRE")[1],0,"","€€€€€€€€€€€€€€ ","C","","R"} )

	if nOpc >= 4
		if select("TSA3") > 0
			TSA3->(dbclosearea())
		endif
		cqry := " select ZZX_REPRE, ZZX_NOMEE FROM " + RETSQLNAME("ZZX") + " WHERE D_E_L_E_T_ = ' ' AND ZZX_ATENDE = '" + ZZX->ZZX_ATENDE +"' AND ZZX_FILIAL = '" + ZZX->ZZX_FILIAL + "' AND ZZX_SSL = 'N' "
		tcquery cqry new alias "TSA3"
		count to nqry
		if nQry > 0
			TSA3->(DBGOTOP())
			WHILE !TSA3->(EOF())
				aAdd(aCols, {;
				TSA3->ZZX_REPRE,;
				TSA3->ZZX_NOMEE,;
				.F.;
				})
				TSA3->(DBSKIP())
			ENDDO
		endif
	else
		MontaAcols()
	endif

	dbselectarea("ZZX")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis do Cabecalho do Modelo 2                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAtend	:= iif(nOpc>=4,ZZX->ZZX_ATENDE,space(TamSX3("ZZX_ATENDE")[1]))
	cNomeA	:= iif(nOpc>=4,ZZX->ZZX_NOMEA,space(TamSX3("ZZX_NOMEA")[1]))
	cXSenh	:= iif(nOpc>=4,ZZX->ZZX_SENHA,space(TamSX3("ZZX_SENHA")[1]))
	cAprov	:= iif(nOpc>=4,ZZX->ZZX_APR01,space(TamSX3("ZZX_APR01")[1]))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulo da Janela                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cTitulo:="Relacionamento Atendente x Representantes"

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com descricao dos campos do Cabecalho do Modelo 2      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aC:={}
	// aC[n,1] = Nome da Variavel Ex.:"cCliente"
	// aC[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aC[n,3] = Titulo do Campo
	// aC[n,4] = Picture
	// aC[n,5] = Validacao
	// aC[n,6] = F3
	// aC[n,7] = Se campo e' editavel .t. se nao .f.
	AADD(aC,{"cAtend"	,{15,10} ,"Cod.Atendente"	,"@!"			,"ExecBlock('CRE17V3',.f.,.f.)","SA3",iif(nOpc==3,.T.,.F.)})
	AADD(aC,{"cNomeA"	,{15,200},"Nome"			,"@!"			,,,.F.})
	AADD(aC,{"cXSenh"	,{30,10} ,"Senha Acesso"	,				,,,.T.})
	AADD(aC,{"cAprov"	,{30,200},"Aprovador"		,				,"ExecBlock('CRE17V4',.f.,.f.)",,.T.})

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com descricao dos campos do Rodape do Modelo 2         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aR:={}
	// aR[n,1] = Nome da Variavel Ex.:"cCliente"
	// aR[n,2] = Array com coordenadas do Get [x,y], em Windows estao em PIXEL
	// aR[n,3] = Titulo do Campo
	// aR[n,4] = Picture
	// aR[n,5] = Validacao
	// aR[n,6] = F3
	// aR[n,7] = Se campo e' editavel .t. se nao .f.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Array com coordenadas da GetDados no modelo2                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aCGD:={80,5,118,315}

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Validacoes na GetDados da Modelo 2                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cLinhaOk:="ExecBlock('CRE17V1',.f.,.f.)" // validar a linha digitada
	cTudoOk:="ExecBlock('CRE17V2',.f.,.f.)" // validar o cabecalho informado

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Chamada da Modelo2                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// lRetMod2 = .t. se confirmou
	// lRetMod2 = .f. se cancelou
	lRetMod2:=Modelo2(cTitulo,aC,aR,aCGD,nOpc,cLinhaOk,cTudoOk ,,,,,,,.T.)

	// No Windows existe a funcao de apoio CallMOd2Obj() que retorna o
	// objeto Getdados Corrente
	If lRetMod2
		AtuData( nOpc )
	Endif

	RestArea(aArea)

Return


static function MontaAcols()
	local ni, cQry, lAdd
	local acols := {}

	aadd(acols,  Array( Len( aHeader ) + 1 ) )

	for ni := 1 to len(aheader)
		acols[1][GdFieldPos(aheader[ni][02])] := iif( aheader[ni][8]=="C", space(aheader[ni][04]), iif(aheader[ni][8]=="D", ctod("//"), 0 ) )
	next
	acols[1][len(acols[1])] := .f.

return acols


user function CRE17V1 // validar a linha da digitacao

	local lOk := .F.
	local i, cqry, nqry, j, aMenor, aMaior

	if SA3->(dbseek(xFilial("SA3") + aCols[n,GdFieldPos("ZZX_REPRE")]))
		j := 0
		aMenor := {}
		aMaior := {}
		if len(aCols) > 1
			if n > 1
				for i := 1 to n
					if i < n
						aAdd(aMenor, aCols[i])
					endif
				next
				j := aScan(aMenor, {|x| x[GdFieldPos("ZZX_REPRE")] == SA3->A3_COD })
			endif


			if j == 0 // checar integridade
				if n < len(aCols) // pegar elementos depois do digitado?
					for i := n to len(aCols)
						if i > n
							aAdd(aMaior, aCols[i])
						endif
					next
				endif
				j := aScan(aMaior, {|x| x[GdFieldPos("ZZX_REPRE")] == SA3->A3_COD })
			endif
		endif

		if j == 0
			if cAprov $ "N " // Nao É aprovador
				if select("TSA3") > 0
					TSA3->(dbclosearea())
				endif
				cqry := "SELECT ZZX_REPRE FROM " + RETSQLNAME("ZZX") + " ZZX WHERE D_E_L_E_T_ = ' ' AND ZZX_APR01 <> 'S' AND ZZX_REPRE = '" + SA3->A3_COD + "' and ZZX_FILIAL = '" + xFilial('ZZX') + "' AND ZZX_ATENDE <> '" + cAtend + "'  "
				tcquery cqry new alias "TSA3"
				count to nqry
				TSA3->(dbclosearea())

				if nQry > 0
					Alert("Representante já informado para outro atendente!")
					aCols[n,GdFieldPos("ZZX_NOMEE")] := ""
				else
					lOk := .T.
					aCols[n,GdFieldPos("ZZX_NOMEE")] := SA3->A3_NOME
				endif
			else
				lOk := .T. 
				aCols[n,GdFieldPos("ZZX_NOMEE")] := SA3->A3_NOME
			endif
		else
			Alert("Representante já informado!")
			aCols[n,GdFieldPos("ZZX_REPRE")] := Space(Tamsx3("ZZX_REPRE")[1])
			aCols[n,GdFieldPos("ZZX_NOMEE")] := Space(Tamsx3("ZZX_NOMEE")[1])
		endif
	endif

return lOk


user function CRE17V2 // validar o cabecalho ao salvar

	local lRet := .T.

return lRet


user function CRE17V3 // validar a digitacao do vendedor cabecalho

	local lOk := .F.
	local cqry, nqry

	if SA3->(dbseek(xFilial("SA3") + cAtend ))
		if select("TSA3") > 0
			TSA3->(dbclosearea())
		endif
		cqry := "SELECT ZZX_REPRE FROM " + RETSQLNAME("ZZX") + " ZZX WHERE D_E_L_E_T_ = ' ' AND ZZX_ATENDE = '" + SA3->A3_COD + "' and ZZX_FILIAL = '" + xFilial("ZZX") + "' "
		tcquery cqry new alias "TSA3"
		count to nqry
		TSA3->(dbclosearea())
		if nqry > 0
			Alert("Já existe cadastro para este atendente")
		else
			lOk := .T.
			cNomeA := SA3->A3_NOME
		endif
	endif

	if !lOk
		cAtend:= Space(Tamsx3("ZZX_ATENDE")[1])
		cNomeA:= ""
	endif

return lOk


Static Function AtuData( nOpc )
	local cqry, i, nExec
	local nZZX_REPRE := GdFieldPos("ZZX_REPRE")
	local nZZX_NOMEE := GdFieldPos("ZZX_NOMEE")

	nExec := 0
	if nOpc >= 4
		cqry := "DELETE " + RETSQLNAME("ZZX") + " WHERE ZZX_ATENDE = '" + ZZX->ZZX_ATENDE + "' and ZZX_FILIAL = '" + ZZX->ZZX_FILIAL + "' "
		nExec := TcSqlExec(cQry)
	endif

	if nExec < 0
		alert( tcsqlexec() )
	endif               

	if nOpc = 3 .or. nOpc = 4	
		ZZX->(reclock("ZZX",.T.))
		ZZX->ZZX_FILIAL := xFILIAL("ZZX")
		ZZX->ZZX_ATENDE := cATEND
		ZZX->ZZX_SENHA	:= cXSENH
		ZZX->ZZX_NOMEA	:= cNOMEA
		ZZX->ZZX_APR01	:= cAprov
		ZZX->ZZX_SSL	:= "S"
		ZZX->ZZX_REPRE	:= aCols[1,nZZX_REPRE]
		ZZX->ZZX_NOMEE	:= aCols[1,nZZX_NOMEE]
		ZZX->(msunlock())

		For i := 1 to len(aCols)
			If ! acols[i,len(acols[i])]
				ZZX->(reclock("ZZX",.T.))
				ZZX->ZZX_FILIAL := xFILIAL("ZZX")
				ZZX->ZZX_ATENDE := cATEND
				ZZX->ZZX_NOMEA	:= cNOMEA
				ZZX->ZZX_SSL	:= "N"
				ZZX->ZZX_REPRE	:= aCols[i,nZZX_REPRE]
				ZZX->ZZX_NOMEE	:= aCols[i,nZZX_NOMEE]
				ZZX->(msunlock())
			EndIf
		Next
		MsgRun("Aguarde","Aguarde ... Atualizando Negociações em Aberto",{||U_AtuZZV(cAtend)})
	EndIf
Return

User Function AtuZZV(cAtend)
	Local _cQuery 	:= ""
	If !Empty(Alltrim(cAtend))
		_cQuery := " UPDATE ZZV010 SET "
		_cQuery += " ZZV_SUPER = '"+Alltrim(cAtend)+"' "
		_cQuery += " FROM ZZV010 ZZV INNER JOIN SA3010 A3 ON ZZV.ZZV_VEND = A3.A3_COD " 
		_cQuery += " WHERE ZZV.ZZV_STATUS IN  (1,2,3) "
		_cQuery += " AND A3.A3_SUPER = '"+Alltrim(cAtend)+"' "
		_cQuery += " AND ZZV.ZZV_FILIAL IN ('01','02') "
		_cQuery += " AND ZZV.D_E_L_E_T = '' "	

		TcSqlExec(_cQuery)  
	EndIf
Return

User Function CRE17V4()
	if cAprov $ "SN"
		return .T.
	else
		Alert("Só é permitido digitar 'S' Sim ou 'N' Não!")
		return .F.
	endif
