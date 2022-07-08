#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWEBSRV.CH'

/*	Author: Robert Santos
	Date: 31 mar 2012
	Function: Verify authenticity of a user groups
*/                                                

wsservice WS_VLDUSER description "Verificar/ validar entrada do usuário"
	wsdata cuser as string
	wsdata cpass as string  
	wsdata login as StrLoginUser
	
	wsmethod vldUser description "Validar usuario"
endwsservice

// estrutura retorno do usuario
WsStruct StrLoginUser
	WsData cErrorCode   As String
	WsData cErrorMsg   As String
	WsData cID     As String optional
	WsData cUsuario    As String optional
	WsData cNomeCompleto  As String optional
	WsData cDepartamento  As String optional
	WsData cCargo    As String optional
	WsData cEmail    As String optional
	WsData nGrupo    As Float optional
	WsData lBloqueado   As Boolean optional
	WsData cAutenticacao  As String optional
	WsData cCodVendedor   As String optional
	WsData cGruposUser    As String optional
	WsData cProdGen    As String optional 
	wsdata CEMPFIL as string optional   
	wsdata TABELA as string optional  
	wsdata MV_FIOFLEX as string optional    
	wsdata MV_AVISTA as string optional    
	wsdata MV_PVLIBER as float optional
	wsdata MV_INDCOBR as float optional
	wsdata MV_INDICEC as float 
	
	wsdata MV_RELFROM as string optional
	wsdata MV_RELPSW as string optional
	wsdata MV_RELSERV as string optional
	wsdata MV_DESCESP as float optional       
	
	wsdata DESCADICIONAL as string optional
	
	wsdata dadoscli as string // A1_FILIAL+A1_COD+A1_LOJA  
	wsdata MyAlert as array of string optional
	wsdata A3_COMIS as float optional
EndWsStruct


// method
wsmethod vldUser wsreceive cuser, cpass wssend login wsservice WS_VLDUSER

local cmsg := "OK"
local lok := .f.
local agrupo := {}
local auser := {}
local aaux := {}
local i
local caux := ""  
local nhdl
local carq
//INICIO LEONARDO 15/04/201
local lDemit := .F.
//FIM LEONARDO


	// Buscar usuario
	psworder(2)
	
if pswseek( cuser , .t.)
	// validar grupo do usuario
	auser := pswret()
	
	if (pswname(cpass))
		
		// gravar informacoes do usuario
		::login:A3_COMIS := 0
		
		::login:cID := auser[1,1]
		::login:cUsuario := trim(auser[1,2])
		::login:cNomeCompleto := trim(auser[1,4])
		::login:cDepartamento := trim(auser[1,12])
		::login:cCargo := trim(auser[1,13])
		::login:cEmail := trim(auser[1,14])
		::login:nGrupo := len(auser[1,10])
		::login:lBloqueado := auser[1,17]
		::login:cAutenticacao := DTOS(date())+LEFT(TIME(),2)+SUBS(TIME(),4,2)+SUBS(TIME(),7,2)
		::login:cProdGen := ""
		::login:cempfil := cempant+cfilant
		
		// *************** validar grupos *************** //
		agrupo := auser[1,10]
		
		// validar grupos
		psworder(1)
		for i:=1 to len(agrupo)
			
			// buscar grupo de usuario
			if pswseek( agrupo[i], .f.)
				aaux := pswret()
				aaux[1,2] := ValAcess( trim(aaux[1,1]) )
				if trim(aaux[1,2]) == "Web-Vendedor"
					caux := "Web-Vendedor"
					lok := .t.
					exit
				elseif trim(aaux[1,2]) == "Web-Controlador"
					caux := "Web-Controlador"
					lok := .t.
					exit
				elseif trim(aaux[1,2]) == "Web-Cliente"
					caux := "Web-Cliente"
					lok := .t.
					exit
				elseif trim(aaux[1,2]) == "Web-Diretor"
					caux := "Web-Diretor"
					lok := .t.
					exit
				endif
			endif
		next
		
		// validar clientes
		lclie := .f.
		if caux == "Web-Cliente"
			dbselectarea("SA1")
			SA1->( dbsetorder(3) ) // FILIAL+CGC
			if( dbseek(SA1->(xfilial("SA1")+trim(::login:cNomeCompleto))) )
				::login:dadoscli := SA1->(A1_FILIAL+A1_COD+A1_LOJA)
				::login:cCodVendedor := trim(SA1->A1_VEND)
				lclie := .t.
			else
				::login:dadoscli := ""
			endif
		else
			::login:dadoscli := ""
		endif
		
		if !lok
			cmsg := "Sem direitos"
			lok := .f.
		else
			// validar se encontrou o cliente
			if (caux == "Web-Cliente") .and. !lclie
				cmsg := "Cliente não encontrado com CGC '"+trim(::login:cNomeCompleto)+"' "
				lok := .f.
			else
				// setar usuario com grupo
				::login:cGruposUser := caux
				
				// buscar codigo do vendedor
				if( caux <> "Web-Cliente" )
					dbselectarea("SA3")
					SA3->(dbsetorder(7))
					if SA3->( dbseek(xfilial("SA3")+auser[1,1]) )
						//INICIO LEONARDO 15/04/2014
						if  !EMPTY(SA3->A3_DEMISS) .And. Date() >= SA3->A3_DEMISS
							::login:cCodVendedor := ""
							::login:tabela := ""
							lDemit := .T.
						else
						//FIM LEONARDO
							::login:cCodVendedor := trim(SA3->A3_COD)
							::login:tabela := SA3->A3_TABELA
							::login:A3_COMIS := SA3->A3_COMIS
						endif
					else
						::login:cCodVendedor := ""
						::login:tabela := ""
					endif
				else
					dbselectarea("SA3")
					SA3->(dbsetorder(1))
					if SA3->( dbseek(xfilial("SA3")+::login:cCodVendedor) )
						//INICIO LEONARDO 15/04/2014
						if !EMPTY(SA3->A3_DEMISS) .And. Date() >= SA3->A3_DEMISS
							::login:cCodVendedor := ""
							::login:tabela := ""
							lDemit := .T.
						else
						//FIM LEONARDO
							::login:cCodVendedor := trim(SA3->A3_COD)
							::login:tabela := SA3->A3_TABELA
						endif
					else
						::login:cCodVendedor := ""
						::login:tabela := ""
					endif
				endif
				
				cDescAd := ""
				if(empty(::login:cCodVendedor) .and. ::login:cGruposUser == "Web-Vendedor")
					lok := .f.
					//INICIO LEONARDO 15/04/2014
					if 	lDemit
					cMsg := "Usuário sem permissão para acesso"
					else 
					cMsg := "Usuário sem vendedor associado"
					endif
					//FIM LEONARDO
				else
					cDescAd := U_CalcAdic(::login:tabela,::login:cCodVendedor,"",.F.)
				endif
				
				// parametros
				if lOk
					::login:mv_fioflex := getmv("MV_FIOFLEX")
					::login:mv_avista := getmv("MV_AVISTA")
					::login:mv_pvliber := getmv("MV_PVLIBER")
					::login:mv_indcobr := getmv("MV_INDCOBR")
					::login:mv_indicec := getmv("MV_INDICEC")
					::login:mv_relfrom := alltrim( getmv('MV_RELFROM') )
					::login:mv_relserv := alltrim( getmv('MV_RELSERV') )
					::login:mv_relpsw := alltrim( getmv('MV_RELPSW') )
					::login:MV_DESCESP := getmv("MV_DESCESP")
					::login:DESCADICIONAL := iif( empty(cDescAd), "", cDescAd)
				endif
			endif
		endif
	else//PSWNAME-SENHA
		// usuario invalido
		cmsg := "Senha inválida!"
		lok := .f.
	endif//PSWNAME
	
else//PSWSEEK-USUARIO
	cmsg := "Senha inválida!"
	lok := .f.
			endif//PSWSEEK



// pegar os alertas do usuario
if lok
	carq := "\site\"+cempant+cfilant+::login:cCodVendedor+".arqtxt"
	if file( carq )
		nhdl := ft_fuse( carq )
		if nhdl > -1
			ft_fgotop()
			while !ft_feof()
				aadd()
				ft_fskip()
			enddo
		endif
		ft_fuse()
	endif
endif

// retornar acesso resultado
if lok
	::login:cErrorMsg := cmsg
	::login:cErrorCode := "00"
else
	::login:cErrorMsg := cmsg
	::login:cErrorCode := "01"
endif

return .t.


static function ValAcess( cgrupoId )

local agru := AllGroups()
local ni := 0
local cret := ""

for ni := 1 to len( agru )
	if( cgrupoId == trim(agru[ni][1][1]) ) 
		cret := agru[ni][1][2]
		exit
	endif
next

return cret