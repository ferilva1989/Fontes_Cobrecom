#include 'protheus.ch'
#include 'topconn.ch'

/*
Robert Santos
07.08.13
Objetivo: Gerar orçamentos usando tabelas temporárias ZZJ e ZZK informadas pela WEB
através do portal dos representantes
*/
user function xrot0003( cZZJ_ID, nOpc )

local aRet := {.t.,"INICIANDO..", ""} // 1= HOUVE SUCESSO, 2=MENSAGEM DE ERRO OU NO PEDIDO GERADO, 3= ZZJ_STATUS
local nHdl, cMsg, cCJ_NUM, aCabec, aItem, aItens, aAux1, ni, nj

default cZZJ_ID		:= ""
default nOpc		:= 3

private lmserroauto := .f.
private __ZJID

dbselectarea("SCJ")
dbsetorder(1)

dbselectarea("SCK")

dbselectarea("ZZJ")
dbsetorder(1)

dbselectarea("ZZK")
dbsetorder(1)

dbselectarea("SA1")
dbsetorder(1)

if ZZJ->(dbseek(xFilial("ZZJ")+cZZJ_ID))
/*/	// By Jeferson 04/04/14 -> Portal não deve alt.End.Cobr.no SA1
	if( !empty(ZZJ->(ZZJ_ENDCOB)) ) // atualizar endereco de cobranca do cliente
		if SA1->(dbseek(xFilial("SA1") + ZZJ->(ZZJ_CLIENT + ZZJ_LOJA)))
			if alltrim(SA1->A1_ENDCOB) != alltrim(ZZJ->ZZJ_ENDCOB)
				SA1->(reclock("SA1",.f.))
				SA1->A1_ENDCOB := ALLTRIM(UPPER(ZZJ->ZZJ_ENDCOB))
				SA1->(msunlock())
			endif
		endif
	endif
/*/	
	// PREPARAR OS DADOS
	__ZJID := cZZJ_ID // usado em MA415END
	
	// montar cabecalho
	aAux1 := {}
	
	if nOpc == 4
		aadd( aaux1, { { "CJ_NUM", ZZJ->ZZJ_CJNUM , nil } , {posicione("SX3", 2, "CJ_NUM", "X3_ORDEM")} } )
			If ZZJ->(dbseek(xFilial("ZZJ")+cZZJ_ID))
				ZZJ->(reclock("ZZJ",.f.))
		    	ZZJ->(ZZJ_STATUS) := "B"
		    	ZZJ->(MSUNLOCK())
			EndIf
	endif
	
	aadd( aaux1, { { "CJ_CLIENTE", ZZJ->ZZJ_CLIENT , nil } , {posicione("SX3", 2, "CJ_CLIENTE", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_LOJA"   , ZZJ->ZZJ_LOJA   , nil } , {posicione("SX3", 2, "CJ_LOJA"   , "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_TABELA" , ZZJ->ZZJ_TABELA , nil } , {posicione("SX3", 2, "CJ_TABELA" , "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_TRANSP" , ZZJ->ZZJ_TRANSP , nil } , {posicione("SX3", 2, "CJ_TRANSP" , "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_VEND1"  , ZZJ->ZZJ_VEND1  , nil } , {posicione("SX3", 2, "CJ_VEND1"  , "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_CONDPAG", ZZJ->ZZJ_CONDPG , nil } , {posicione("SX3", 2, "CJ_CONDPAG", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_TPFRETE", ZZJ->ZZJ_TPFRETE, nil } , {posicione("SX3", 2, "CJ_TPFRETE", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_ENDENT1", ZZJ->ZZJ_ENDENT , nil } , {posicione("SX3", 2, "CJ_ENDENT1", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_OBSAPR" , ZZJ->ZZJ_MSGAPR , nil } , {posicione("SX3", 2, "CJ_OBSAPR" , "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_OBSREPR", ZZJ->ZZJ_MSGREP , nil } , {posicione("SX3", 2, "CJ_OBSREPR", "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_XZZJID" , ZZJ->ZZJ_ID     , nil } , {posicione("SX3", 2, "CJ_XZZJID" , "X3_ORDEM")} } )
	aadd( aaux1, { { "CJ_XFILVEN", ZZJ->ZZJ_FILORI , nil } , {posicione("SX3", 2, "CJ_XFILVEN", "X3_ORDEM")} } )
	
	aaux1 := aSort( aaux1 , , , {|x,y| x[2,1] < y[2,1] }) // ordenar com SX3
	aCabec := {} // formar cabecalho ordem
	for ni:=1 to len(aaux1)
		aadd( aCabec , aaux1[ni,1] )
	next
	
	// MONTAR OS ITENS
	ZZK->(dbseek(xFilial("ZZK")+ZZJ->ZZJ_ID))
	aItens := {}
	cItem := StrZero( 0 , TamSX3("CK_ITEM")[1])
	while ZZK->(ZZK_FILIAL+ZZK_ID) == ZZJ->(ZZJ_FILIAL+ZZJ_ID)
		aAux1 := {}
		cItem := Soma1(cItem)
		aadd( aaux1, { { "CK_ITEM"   , cItem           , nil } , {posicione("SX3", 2, "CK_ITEM", "X3_ORDEM")} } )
		aadd( aaux1, { { "CK_PRODUTO", ZZK->ZZK_COD    , nil } , {posicione("SX3", 2, "CK_PRODUTO", "X3_ORDEM")} } )
		aadd( aaux1, { { "CK_PRCVEN" , ZZK->ZZK_PRCVEN , nil } , {posicione("SX3", 2, "CK_PRCVEN", "X3_ORDEM")} } )
		aadd( aaux1, { { "CK_LANCES" , ZZK->ZZK_LANCES , nil } , {posicione("SX3", 2, "CK_LANCE", "X3_ORDEM")} } )
		aadd( aaux1, { { "CK_METRAGE", ZZK->ZZK_METRAG , nil } , {posicione("SX3", 2, "CK_METRAGE", "X3_ORDEM")} } )
		aadd( aaux1, { { "CK_QTDVEN" , (ZZK->(ZZK_LANCES*ZZK_METRAG)) , nil } , {posicione("SX3", 2, "CK_QTDVEN", "X3_ORDEM")} } )
		aadd( aaux1, { { "CK_VALOR"  , ZZK->ZZK_PRCVEN*(ZZK->(ZZK_LANCES*ZZK_METRAG)) , nil } , {posicione("SX3", 2, "CK_VALOR", "X3_ORDEM")} } )
		if ZZK->ZZK_ZEROCM == "S"
			aadd( aaux1, { { "CK_COMIS1", 0 , nil } , {posicione("SX3", 2, "CK_COMIS1", "X3_ORDEM")} } )
		else
			aadd( aaux1, { { "CK_COMIS1", ZZK->ZZK_COMIS , nil } , {posicione("SX3", 2, "CK_COMIS1", "X3_ORDEM")} } )
		endif
		aadd( aaux1, { { "CK_ACONDIC", ZZK->ZZK_ACONDI , nil } , {posicione("SX3", 2, "CK_ACONDIC", "X3_ORDEM")} } )
		aadd( aaux1, { { "CK_TES"    , iif(empty(ZZK->ZZK_TES) , "501",ZZK->ZZK_TES) , nil } , {posicione("SX3", 2, "CK_TES", "X3_ORDEM")} } )
		aadd( aaux1, { { "CK_XZERACM", ZZK->ZZK_ZEROCM , nil } , {posicione("SX3", 2, "CK_XZERACM", "X3_ORDEM")} } )
		aadd( aaux1, { { "CK_XDESCDG", ZZK->ZZK_DESCDG , nil } , {posicione("SX3", 2, "CK_XDESCDG", "X3_ORDEM")} } )
		aadd( aaux1, { { "CK_STSITE" , ZZK->ZZK_STATUS , nil } , {posicione("SX3", 2, "CK_XDESCDG", "X3_ORDEM")} } )
		
		// ordenar com SX3
		aaux1 := aSort( aaux1 , , , {|x,y| x[2,1] < y[2,1] })
		
		aItem := {}
		for ni:=1 to len(aaux1)
			aadd( aItem , aaux1[ni,1] )
		next
		aAdd(aItens, aItem )
		
		ZZK->(dbskip())
	enddo
	// efetuar inclusao
	begin transaction
	mata415( acabec , aitens, nOpc ) // nOpc = 3->Incluir // 4->Alterar // 5->Exclui

	if lmserroauto
		// tratar excessao
		disarmtransaction()
		
		aRet[1] := .f.
		makedir("\system\cobrecom_execauto\")
		mostraerro("\system\cobrecom_execauto\","orcamento.txt")
		
		nhdl := ft_fuse("\system\cobrecom_execauto\orcamento.txt")
		cmsg := "Erro!"
		if nhdl > 0
			cmsg := ""
			while !ft_feof()
				cmsg += ft_freadln()+CRLF
				ft_fskip()
			enddo
		endif
		ft_fuse()
		aret[2] := cmsg
	else
		// SUCESSO
		aRet[1] := .t.
		aRet[2] := SCJ->CJ_NUM
		aret[3] := iif( nopc==3 .or. nOpc==4, ZZJ->ZZJ_STATUS, "" )      
		
		if LEN(ALLTRIM(ZZJ->ZZJ_ENDENT)) > 39
			CENDENT1 := SUBSTR(ALLTRIM(ZZJ->ZZJ_ENDENT),1,39)
			CENDENT2 := SUBSTR(ALLTRIM(ZZJ->ZZJ_ENDENT),40, LEN(ALLTRIM(ZZJ->ZZJ_ENDENT)) - 39)
		ELSE
			CENDENT1 := ALLTRIM(ZZJ->ZZJ_ENDENT)
			CENDENT2 := ""
		endif
		
		SCJ->(RECLOCK("SCJ",.F.)) // CHAMADO 017 DO JEFERSON
		SCJ->CJ_PEDCLI		:= PADR(ZZJ->ZZJ_PEDCLI,TAMSX3("CJ_PEDCLI")[1])
		SCJ->CJ_OBS	  		:= PADR(UPPER(ALLTRIM(ZZJ->ZZJ_MENPCP)),TAMSX3("CJ_OBS")[1])
		SCJ->CJ_ENDENT1	:= CENDENT1
		SCJ->CJ_ENDENT2	:= CENDENT2
		SCJ->(MSUNLOCK())
	endif
	end transaction
else
	aret := {.f., "Orçamento não encontrado!", "" }
endif

return aRet
