#include "rwmake.ch"
#INCLUDE "topconn.ch"
/*/
Esta rotina dever? tratar:

Materiais que estejam em retrabalho:
1 - Dever?o ser produzidos:
Apontar quanto falta e limpar os campos do SC6 (C6_SEMANA, C6_XQTDRET para permitir colocar em um resumo
Tratar a tabela ZZE para n?o poder mais emitir etiqueta do retrabalho.

2 - Ser?o adicionados em outro retrabalho.
A) Criar novo ID de retrabalho;
B) Adicionar a um retrabalho que possua saldo
Tratar a tabela ZZE para n?o poder mais emitir etiqueta do retrabalho anterior.


Materiais que est?o em produ??o e dever?o ser retrabalhados
A) Criar novo retrabalho
b) Adicionar a um retrabalho que possua saldo
Tratar a tabela SZ9 para n?o poder mais emitir etiqueta de produ??o.

Retrabalhar materiais do estoque:
- Criar novo retrabalho e sempre retornar ao estoque
/*/
*

/*/{Protheus.doc} CRESTR1_1
//TODO Rotina complementar a rotina de aproveitamento de lances 
                 onde poder? criar um novo retrabalho ou adicionar pedi-  
                 dos que j? tenham sido colocados em um RESUMO ou PROGRA  
                 MA??O, bem como criar novos retrabalhos sem atender a    
                 nenhum pedido, ou seja sai de um acondicionamento e re-  
                 torna em outro acondicionamento.
@author Roberto Oliveira 
@since 17/11/2015 
@version undefined

@type function
/*/
User Function CRESTR1_1()
	Local aCores := {}
	Local cAlias := "ZZE"
	
	DbSelectArea("SB1")
	DbSelectArea("SB2")
	DbSelectArea("SBF")
	DbSelectArea("SD3")
	DbSelectArea("SDA")
	
	
	DbSelectArea("SZE")
	DbSetOrder(1)
	
	DbSelectArea("SC6")
	DbSetOrder(1)
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SBF")
	DbSetOrder(1)  // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	
	DbSelectArea("SC9")
	DbSetOrder(1) //C9_FILIAL+C9_PEDIDO+C9_ITEM+C9_SEQUEN+C9_PRODUTO
	
	
	// Cria as vari?veis do cabe?alho
	/*/
	ID Retrab.: 999999      Nro.Bobina......: 9999999       C?d.Produto: 9999999999999999
	
	Acondic...: X99999      Quant.Dispon?vel: 999,999.99   Descri??o..: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
	/*/
	
	Private cCadastro := "Manuten??o em Retrabalhos"
	Private aRotina := {{"Pesquisar"    , "AxPesqui"       , 0, 1},;
						{"Visualizar"   , "AxVisual"       , 0, 2},;
						{"Manuten??o"   , "u_CRESTMAN('M')", 0, 4},;
						{"Encerr.Manual", "u_CRESTMAN('C')", 0, 4},;
						{"Encerr.Autom.", "u_CRESTENC()"   , 0, 2},;
						{"Lib.Emis.Etq.", "u_CRESTLBE()"   , 0, 2},;
						{"Enviar e-Mail", "u_CDFATW03()"   , 0, 2},;
						{"Legenda"	    , "U_EstR1Lg()"    , 0, 2}}
	
	//{"Encerrar Retrabalho"	,"U_CRESTR8B",0,6} }
	AADD(ACORES,{"ZZE_SITUAC == '1'","BR_VERDE"}) 	// Encerrado
	AADD(ACORES,{"ZZE_STATUS == '1'","BR_VERMELHO"})// AGUARD. SEPARAR
	AADD(ACORES,{"ZZE_STATUS == '2'","BR_AZUL"})	// AGUARD. ORDEM DE SERVICO
	AADD(ACORES,{"ZZE_STATUS == '3'","BR_AMARELO"}) // EM RETRABALHO ..
	AADD(ACORES,{"ZZE_STATUS == '4'","BR_PRETO"}) 	// FINALIZADO REALIZADO -> Alterei o Status 4 de FINALIZADO para REALIZADO pq a finaliza??o ser? por outro campo
	AADD(ACORES,{"ZZE_STATUS == '9'","BR_MARRON"}) 	// CANCELADO
	AADD(ACORES,{"ZZE_STATUS == 'A'","BR_VIOLETA"}) // RETORNO N?O PLANEJADO PARA ESTOQUE
	AADD(ACORES,{"ZZE_STATUS == 'B'","BR_CINZA"}) 	// FINALIZADO SEM ATENDER TODO O PEDIDO
	
	DbSelectArea(cAlias)
	DbSeek(xFilial(cAlias),.F.)
	mBrowse(6,1,22,75,cAlias,,,,,,aCores)
Return Nil


/*/{Protheus.doc} CRESTMAN
//TODO Descri??o auto-gerada.
@author zzz
@since 05/06/2017
@version undefined
@param _cRotOpc, , descricao
@type function
/*/
User Function CRESTMAN(_cRotOpc)
	local oExec := nil 
	local aItens	:= {}
	local aRet	:= {}
		
	Private	_cRotOpc   //M=Manuten??o   C=Cancelamento
	
	
	
	_cLangAtu := __LANGUAGE
	__LANGUAGE := "ENGLISH"
	
	//??????????????????????????????????????????????????????????????Ŀ
	//? Cria aHeader e aCols da GetDados                             ?
	//????????????????????????????????????????????????????????????????
	
	//  Aten??o: Pela op??o 4 do aRotina, o registro que estiver posicionado no momento da chamada desta rotina,
	//  ? automaticamente travado pelo Protheus, por isso dou um msunlock()
	
	ZZE->(MsUnLock())
	
	aColsCln := {} // Crio c?pia do aCols para poder comparar se houve altera??o em alguma linha
	nUsado:=0
	aHeader:={}
	/*/
	aAdd(aHeader,{AllTrim(X3_TITULO)	, X3_CAMPO, X3_PICTURE	, X3_TAMANHO	, X3_DECIMAL,
	X3_VALID			, X3_USADO, X3_TIPO		, X3_ARQUIVO	, X3_CONTEXT })
	/*/
	//aadd(aHeader,{TITULO     ,CAMPO    ,PICT           ,TAM                     ,DEC,VALID        ,USADO ,TIPO,ARQUIVO,CONTEXTO })
	aadd(aHeader, {"Pedido"     ,"NUMPED" ,"999999"       ,TamSX3("C6_NUM"    )[1],000,"U_VldPed(1)", "?"  ,"C" , ""    ,""       })
	aadd(aHeader, {"Item"       ,"ITEMPV" ,""	          ,TamSX3("C6_ITEM"   )[1],000,"U_VldPed(2)", "?"  ,"C" , ""    ,""       })
	aadd(aHeader, {"Dt.Entr."   ,"DATENTR","@E"           ,008                    ,000,".F."        , "?"  ,"D" , ""    ,""       })
	aadd(aHeader, {"Qtd.P.V."   ,"QUANT"  ,"@E 999,999.99",009                    ,002,".F."        , "?"  ,"N" , ""    ,""       })
	aadd(aHeader, {"Acondic."   ,"LOCALIZ",""             ,TamSX3("BE_LOCALIZ")[1],000,"U_VldLoc('"+_cRotOpc+"')" , "?"  ,"C" , ""    ,""       })
	aadd(aHeader, {"Qtd.Lances" ,"QTDLANC","@E 999,999"   ,006                    ,000,"U_VldLnc('"+_cRotOpc+"')" , "?"  ,"N" , ""    ,""       })
	aadd(aHeader, {"Tot.Metros.","TOTMETR","@E 999,999.99",009                    ,002,".F."        , "?"  ,"N" , ""    ,""       })
	aadd(aHeader, {"Qtd.Devolv.","QTDDEV" ,"@E 999,999.99",009                    ,002,".F."        , "?"  ,"N" , ""    ,""       })
	aadd(aHeader, {"Semana"     ,"SEMANA" ,""             ,TamSX3("C6_SEMANA" )[1],000,".F."        , "?"  ,"C" , ""    ,""       })
	aadd(aHeader, {"Status"     ,"STATUS" ,""             ,025                    ,000,".F."        , "?"  ,"C" , ""    ,""       })
	aadd(aHeader, {"Origem"     ,"LINORIG",""             ,003                    ,000,".F."        , "?"  ,"C" , ""    ,""       })
	aadd(aHeader, {"Etq.Emit.?" ,"ETIQ"   ,""             ,001                    ,000,".F."        , "?"  ,"C" , ""    ,""       })
	aadd(aHeader, {"Num.Reg.?"  ,"NUMREG" ,""             ,010                    ,000,".F."        , "?"  ,"N" , ""    ,""       })
	nUsado:=Len(aHeader)
	
	//??????????????????????????????????????????????????????????????Ŀ
	//? Executa a Modelo 3                                           ?
	//????????????????????????????????????????????????????????????????
	cTitulo        := If(_cRotOpc=="M","Cria??o/Altera??o de Retrabalhos","Cancelamento de Retrabalhos")
	cAliasEnchoice := ""
	cAliasGetD     := ""
	cLinOk         := "u_VldLin( '" + _cRotOpc + "' )" // "AllwaysTrue()"
	cTudOk         := "u_VldTud( '" + _cRotOpc + "' )" // "AllwaysTrue()"
	cFieldOk       := "AllwaysTrue()"
	aCpoEnchoice   := {}
	nOpcE          :=3
	nOpcG          :=3
	aAltEnchoice   :={}
	aButtons       := {}
	
	Do While .T.
		_cId      := Padr(" ",TamSX3("ZZE_ID"    )[1])
		_cNumBob  := Padr(" ",TamSX3("ZE_NUMBOB" )[1])
		_cProduto := Padr(" ",TamSX3("B1_COD"    )[1])
		_cDescri  := Padr(" ",TamSX3("B1_DESC"   )[1])
		_cAcond   := Padr(" ",TamSX3("BE_LOCALIZ")[1])
		_nLances  := 0
		_nQtdDisp := 0.00
		_nQtdEnc  := 0.00
		_cObser   := Space(50)
		_cMotivo  := Padr("00",TamSX3("ZZE_MOTIVO"   )[1])
		_cDesMot  := Padr("  ",TamSX3("ZZE_DESMOV"   )[1])
		_nTotEnt  := 0.00 // Para cancelamento quanto j? foi devolvido
		_nTotDev  := 0.00 // Para cancelamento quanto j? foi devolvido
	
		aCols:={Array(nUsado+1)}
		aCols[1,01]:=Padr(" ",TamSX3("C6_NUM"    )[1])
		aCols[1,02]:=Padr(" ",TamSX3("C6_ITEM"   )[1])
		aCols[1,03]:=Ctod("  /  /  ")
		aCols[1,04]:=0.00
		aCols[1,05]:=Padr(" ",TamSX3("BE_LOCALIZ")[1])
		aCols[1,06]:=0
		aCols[1,07]:=0.00
		aCols[1,08]:=0.00
		aCols[1,09]:=Padr(" ",TamSX3("C6_SEMANA")[1])
		aCols[1,10]:="                         "
		aCols[1,11]:="   "
		aCols[1,12]:=" "
		aCols[1,13]:=0
		aCols[1,nUsado+1]:=.F.
		_lRet:=u_JanRtb01(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk ,nOpcE,nOpcG,cFieldOk,,,aAltEnchoice,,_cRotOpc)
		If _lRet
			If _cRotOpc == "C" // Confirmei um cancelamento
				_lCanc := .T.
				If _nTotDev == 0
					_lCanc := MsgBox("Nenhum Retorno Foi Realizado","Cancela Retrabalho?","YesNo")
					If _lCanc
						_lCanc := MsgBox("Destino do Saldo de  " + TransForm(_nTotEnt,"@E 999,999") + Chr(13) + Chr(13) + ;
					                "Sim - Devolve p/ Estoque " + Chr(13) + ;
					                "N?o - Envia para Sucata  ","Devolve p/ Estoque?","YesNo")
					 	If !_lCanc // Manda para Sucata
							_lCanc := .T.
							_nTotDev := -1 // Somente para n?o ser = 0
						EndIf
					EndIf
				Else
					_lCanc := MsgBox("Ser? Sucateado " + Transform((_nTotEnt-_nTotDev),"@E 999,999") + " Metros","Confirma?","YesNo")
				EndIf
				If _lCanc
					If _nTotDev == 0
						// Devolve a quantidade do 90 para o 01 e libera a bobina
						aItens := {}
	
						aAdd(aItens,{Padr("ZZE"+_cId,TamSX3("D3_DOC")[1]),dDataBase})
	
						aAdd(aItens,{Padr(Alltrim(_cProduto),TamSX3("D3_COD")[1]),;		//cProduto
						Posicione("SB1",1,xFilial("SB1")+Alltrim(_cProduto),"B1_DESC"),;//cDescProd,;
						Posicione("SB1",1,xFilial("SB1")+Alltrim(_cProduto),"B1_UM"),; 	//cUM Origem
						"90",;															//cArmOri Origem
						_cAcond,;														//cEndOri Origem
						Padr(_cProduto,TamSX3("D3_COD")[1]),;							//cProduto,;
						Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_DESC"),;			//cDescProd,;
						Posicione("SB1",1,xFilial("SB1")+_cProduto,"B1_UM"),; 			//cUM Destino
						"01",;															//cArmDest Destino
						_cAcond,;														//cEndDest Destino,;
						"",;															//cNumSer Num Serie
						"",;															//cLote
						"",;															//SubLote
						StoD(""),;														//cValidade
						0,;																//nPoten
						_nTotEnt,;														//nQuant
						0,;																//cQtSegUm
						"",;															//Estornado
						"",;						   									//cNumSeq
						"",; 															//cLoteDest
						StoD(""),;														//cValDest
						"",;															//ItemGrade
						""})                                                            //Observa??o
	
						/*
						lMsErroAuto 	:= .F.
						MSExecAuto({|x,y| mata261(x,y)},aItens,3)
						If lMsErroAuto //MostraErro()
						*/
						
						oExec := cbcExecAuto():newcbcExecAuto(aItens,/*aHdr*/,.T.)
						oExec:exAuto('MATA261',3)			
						aRet := oExec:getRet()						
						if !aRet[1]
							Alert("Erro ao Efetuar a Transfer?ncia para local 01")
							Exit
						EndIf
	
						DbSelectArea("ZZE")
						DbSetOrder(1) // ZZE_FILIAL+ZZE_ID
						DbSeek(xFilial("ZZE")+_cId,.F.)
						Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE->ZZE_ID == _cId .And. ZZE->(!Eof())
							// Atualiza Status no ZZE
							RecLock("ZZE",.F.)
							ZZE->ZZE_SITUAC := '1'	// Encerrado
							ZZE->ZZE_STATUS := '9'  // CANCELADO
							If _cObser # ZZE->ZZE_OBSERV
								ZZE->ZZE_OBSERV := _cObser
							EndIf
							MsUnLock()
							ZZE->(DbSkip())
						EndDo
	
						If !Empty(_cNumBob)
							DbSeLectArea("SZE")
							DbSetOrder(1)
							If DbSeek(xFilial("SZE")+_cNumBob,.F.)
								Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_NUMBOB == _cNumBob .And. SZE->(!Eof())
									if  SZE->ZE_STATUS == 'n'
										RecLock("SZE",.F.)
											SZE->ZE_STATUS := "T"
										MsUnLock()
										EXIT
									endif
									SZE->(DbSkip())
								EndDo
							EndIf
						EndIf
					Else
						_nTotDev := Max(_nTotDev,0)
						DbSelectArea("SB1")
						DbSetOrder(1)
						DbSeek(xFilial("SB1")+_cProduto,.F.)
	
						If SB1->B1_COR == '00' // Cobre Nu
							_cCodSuc := "SC01000001" // SUCATA DE COBRE NU
						Else
							_cCodSuc := "SC01000002" //SUCATA DE COBRE ISOLADO
						EndIf
	
						_nQtdDes := ((_nTotEnt-_nTotDev) * (SB1->B1_PESCOB+SB1->B1_PESPVC))
	
						// A fun??o PraSucata faz transfer?ncia da quantidade do c?digo normal
						// para sucata e retorna .T. se deu erro na atualiza??o
						// Par?metros:
						// PraSucata(_PrdOri    ,_PrdDes ,_LocOri,_LocDes,_LozOri,_LozDes,_Quant,Doc          ) // -> _lErrAtu
	
						If !PraSucata(SB1->B1_COD,_cCodSuc,"90","91",_cAcond,""    ,(_nTotEnt-_nTotDev), _nQtdDes,"ZZE"+_cId ) // Retorna se deu erro no execauto
	
							DbSelectArea("ZZE")
							DbSetOrder(1) // ZZE_FILIAL+ZZE_ID
							DbSeek(xFilial("ZZE")+_cId,.F.)
							Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE->ZZE_ID == _cId .And. ZZE->(!Eof())
								// Atualiza Status no ZZE
								RecLock("ZZE",.F.)
								ZZE->ZZE_SITUAC := '1'	// Encerrado
								ZZE->ZZE_STATUS := '9'  // CANCELADO
								If _cObser # ZZE->ZZE_OBSERV
									ZZE->ZZE_OBSERV := _cObser
								EndIf
								MsUnLock()
								ZZE->(DbSkip())
							EndDo
	
							If !Empty(_cNumBob)
								DbSeLectArea("SZE")
								DbSetOrder(1)
								If DbSeek(xFilial("SZE")+_cNumBob,.F.)
									Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_NUMBOB == _cNumBob .And. SZE->(!Eof())
										if  SZE->ZE_STATUS == 'n'
											RecLock("SZE",.F.)
												SZE->ZE_STATUS := "C"
											MsUnLock()
											EXIT
										endif
										SZE->(DbSkip())
									EndDo									
								EndIf
							EndIf
							Alert("Encerramento Realizado com Sucesso!")
						EndIf
					EndIf
				EndIf
			Else
				_cStatus := ""
				If Empty(_cId) // ? um retrabalho novo
					GraveNovo()
				Else // Altera??o em um retrabalho existente
					// Verificar se houve altera??o no aCols comparando com aColsCln
					cIdRetr := _cId  // Gravar com o mesmo n?mero do retrabalho
					DbSelectArea("ZZE")
					DbSetOrder(1)
					DbSeek(xFilial("ZZE")+cIdRetr,.F.)
					_cStatus := ZZE->ZZE_STATUS
					For _nCpa := 1 To Len(aCols)
						If _nCpa <= Len(aColsCln) // Estou dentro do normal
							If GDDeleted(_nCpa) //Est? deletado
								GraveAlt("E",_nCpa)   // Teve Altera??o - Excluiu
							Else
								For _nCpa2 := 1 To nUsado
									If aHeader[_nCpa2,2] $ "NUMPED//ITEMPV//LOCALIZ//QTDLANC//TOTMETR"
										If aCols[_nCpa,_nCpa2] # aColsCln[_nCpa,_nCpa2]
											GraveAlt("A",_nCpa)   // Teve Altera??o - Alterou
											Exit
										EndIf
									EndIf
								Next
								DbSelectArea("ZZE")
								DbGoTo(GDFieldGet("NUMREG" ,_nCpa))
								If ZZE->ZZE_MOTIVO # _cMotivo .Or. ZZE->ZZE_OBSERV # _cObser
									ZZE->(RecLock("ZZE",.F.))
									ZZE->ZZE_MOTIVO := _cMotivo
									ZZE->ZZE_DESMOV := _cDesMot
									ZZE->ZZE_OBSERV	:= _cObser
									MsUnLock()
								EndIf
							EndIf
						Else  // Estou com linha adicionada
							If !GDDeleted(_nCpa) //N?o est? deletado
								GraveAlt("I",_nCpa)   // Teve Altera??o - Incluiu
							EndIf
						EndIf
					Next
				EndIf
			EndIf
		Else
			Exit
		EndIf
	EndDo
	__LANGUAGE := _cLangAtu
Return(.T.)


/*/{Protheus.doc} JanRtb01
//TODO Janela do retrabalho (Browser).
@author zzz
@since 05/06/2017
@version undefined
@param cTitulo, characters, descricao
@param cAlias1, characters, descricao
@param cAlias2, characters, descricao
@param aMyEncho, array, descricao
@param cLinOk, characters, descricao
@param cTudoOk, characters, descricao
@param nOpcE, numeric, descricao
@param nOpcG, numeric, descricao
@param cFieldOk, characters, descricao
@param lVirtual, logical, descricao
@param nLinhas, numeric, descricao
@param aAltEnchoice, array, descricao
@param nFreeze, numeric, descricao
@param _cRotOpc, , descricao
@type function
/*/
User Function JanRtb01(cTitulo,cAlias1,cAlias2,aMyEncho,cLinOk,cTudoOk,nOpcE,nOpcG,cFieldOk,lVirtual,nLinhas,aAltEnchoice,nFreeze,_cRotOpc)
	Local lRet, nOpca := 0
	Local aSize := {}
	Local aPosObj := {}
	Local aObjects := {}
	Local aInfo := {}
	
	Private _cRotOpc
	
	aSize := MsAdvSize()
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aAdd( aObjects, { 100, 100, .t., .t. } )
	aAdd( aObjects, { 100, 100, .t., .t. } )
	aAdd( aObjects, { 100, 015, .t., .f. } )
	aPosObj := MsObjSize( aInfo, aObjects )
	aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,265}} )
	//                                            {15,2,40,355}  45,2,190,355
	nGetLin := aPosObj[3,1]
	
	Private oDlg,oGetDados
	Private lRefresh:=.T.,aTela:=Array(0,0),aGets:=Array(0)
	Private bCampo:={|nCPO|Field(nCPO)},nPosAnt:=9999,nColAnt:=9999
	Private cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,CurLen,nPosAtu:=0
	
	nOpcE    := If(nOpcE==Nil,2,nOpcE)
	nOpcG    := If(nOpcG==Nil,2,nOpcG)
	lVirtual := Iif(lVirtual==Nil,.F.,lVirtual)
	nLinhas  := Iif(nLinhas==Nil,999,nLinhas)
	
	_PSS4 := Int(aSize[5]*0.9)
	
	DEFINE MSDIALOG oDlg TITLE cTitulo From aSize[7],0 to aSize[6],_PSS4 of oMainWnd PIXEL
	
	@ 035,005 Say "ID Retrab.:"
	@ 035,035 Get _cId 		When u_FindId(_cRotOpc,.T.) Object o__cId Valid u_FindId(_cRotOpc,.F.) Picture "XXXXXX" Size 35,10
	
	@ 035,085 Say "Nro.da Bobina.:"
	@ 035,125 Get _cNumBob 	When Empty(_cId).And._cRotOpc=="M" Object o__cNumBob Valid u_FindBob(_cRotOpc) Picture "9999999" Size 35,10
	
	@ 035,185 Say "C?d.Produto:"
	@ 035,220 Get _cProduto	When (Empty(_cId).And.Empty(_cNumBob).And._cRotOpc=="M") Object o__cProd Valid u_FindPrd(_cRotOpc) F3 "SB1" Picture PesqPict("SB1","B1_COD",TamSX3("B1_COD")[1]) Size 45,10
	
	@ 035,285 Say "Descri??o..:"
	@ 035,325 Get _cDescri	When .F. Object o__cDescri Picture "@X" Size 140,10
	
	@ 055,005 Say "Acondic...:"
	@ 055,035 Get _cAcond  	When (Empty(_cId).And.Empty(_cNumBob).And.!Empty(_cProduto).And._cRotOpc=="M") Object o__cAcond Valid u_FindAcon(_cRotOpc) Picture "XXXXXX" Size 40,10
	
	@ 055,085 Say "Quant.Lances:"
	@ 055,125 Get _nLances	When (Empty(_cId) .And. Empty(_cNumBob).And.!Empty(_cProduto).And.!Empty(_cAcond).And._cRotOpc=="M") Object o__nLances Valid u_FindQtLc(_cRotOpc) Picture "@E 9,999" Size 35,10
	
	@ 055,185 Say "Quant.Disp.:"
	@ 055,220 Get _nQtdDisp	When .F. Object o__nQtdD Picture "@E 999,999.99" Size 45,10
	
	@ 055,285 Say "Observa??o:
	@ 055,325 Get _cObser	Picture "@X" Size 140,10
	
	@ 070,005 Say "Motivo:"
	@ 070,035 Get _cMotivo When _cRotOpc=="M" Valid u_FindMtv() F3 "ZT" Picture "XX" Size 45,10
	
	@ 070,085 Say "Descri??o..:"
	@ 070,125 Get _cDesMot	When .F. Object o__cDesMov Picture "@X" Size 140,10
	
	If _cRotOpc=="C"
		@ 070,285 Say "Qtd.Encerrar.:"
		@ 070,325 Get _nQtdEnc	When .F. Object o__nQtdE Picture "@E 999,999.99" Size 45,10
	EndIf
	
	_nPsc4 := Int(aPosObj[2,4]*0.9)
	
	If _cRotOpc=="M"
		//oGetDados := MsGetDados():New(60 ,aPosObj[2,2],280,aPosObj[2,4],nOpcG,cLinOk,cTudoOk,"",.T.,                       ,nFreeze,,Len(aCols),cFieldOk)
		oGetDados := MsGetDados():New(085,aPosObj[2,2],310,_nPsc4      ,nOpcG,cLinOk,cTudoOk,"",.T.,,nFreeze,,If(_cRotOpc=="M",nLinhas,Len(aCols)),cFieldOk)
	Else
		oGetDados := MsGetDados():New(085,aPosObj[2,2],310,_nPsc4      ,nOpcG,cLinOk,cTudoOk,"",.T.,If(_cRotOpc=="M","",{}),nFreeze,,If(_cRotOpc=="M",nLinhas,Len(aCols)),cFieldOk)
	EndIf
	oGetDados:oBrowse:bChange := {|| U_RefFat10()}
	
	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nOpca:=1,If(oGetDados:TudoOk(),If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End()),nOpca := 0)},{||oDlg:End()},,aButtons) CENTERED
	
	lRet:=(nOpca==1)
Return(lRet)


/*/{Protheus.doc} RefrDads
//TODO Refresh das informa??es exibidas.
@author zzz
@since 05/06/2017
@version undefined

@type function
/*/
Static Function RefrDads(cRotOpc)
	o__cNumBob:refresh()
	o__cProd:refresh()
	o__cAcond:refresh()
	o__nQtdD:refresh()
	o__nLances:refresh()
	If cRotOpc =="C"
		o__nQtdE:refresh()
	EndIf
	oGetDados:Refresh()
Return(.T.)


/*/{Protheus.doc} FindId
//TODO Procura Id de Separa??o.
@author zzz
@since 05/06/2017
@version undefined
@param _cRotOpc, , descricao
@param lAcess, logical, descricao
@type function
/*/
User Function FindId(_cRotOpc,lAcess) // 
	If lAcess   // .T. Chamada no When - .F. Chamada no Valid
		Return(.T.)
	EndIf
	
	_cNumBob  := Padr(" ",TamSX3("ZE_NUMBOB" )[1])
	_cProduto := Padr(" ",TamSX3("B1_COD"    )[1])
	_cDescri  := Padr(" ",TamSX3("B1_DESC"   )[1])
	_cAcond   := Padr(" ",TamSX3("BE_LOCALIZ")[1])
	_nLances  := 0
	_nQtdDisp := 0.00
	_nQtdEnc  := 0.00
	
	If Empty(_cId)    
		aCols:={Array(nUsado+1)}
		aCols[1,01]:=Padr(" ",TamSX3("C6_NUM"    )[1])
		aCols[1,02]:=Padr(" ",TamSX3("C6_ITEM"   )[1])
		aCols[1,03]:=Ctod("  /  /  ")
		aCols[1,04]:=0.00
		aCols[1,05]:="      "
		aCols[1,06]:=0
		aCols[1,07]:=0.00
		aCols[1,08]:=0.00
		aCols[1,09]:=Padr(" ",TamSX3("C6_SEMANA"   )[1])
		aCols[1,10]:="                         "
		aCols[1,11]:="   "
		aCols[1,12]:=" "
		aCols[1,nUsado+1]:=.F.
		RefrDads(_cRotOpc)
		o__cNumBob:SetFocus() // O foco tem que ir pro nro. da bobina
		Return(.T.)
	EndIf
	DbSelectArea("ZZE")
	//DbserOrder(2) // ZZE_FILIAL+ZZE_ID+ZZE_PEDIDO+ZZE_ITEMPV
	DbSetOrder(1) // ZZE_FILIAL+ZZE_ID
	If !DbSeek(xFilial("ZZE")+_cId,.F.)
		Alert("ID n?o Cadastrado")
		Return(.F.)
	EndIf
	// Verificar se o retrabalho est? encerrado ou em execu??o
	_lTemErro := .F.
	Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE->ZZE_ID == _cId .And. ZZE->(!Eof())
		If ZZE->ZZE_SITUAC == "1"
			Alert("Retrabalho Encerrado")
		ElseIf ZZE->ZZE_STATUS == "5"
			Alert("Retrabalho Encerrado")
		ElseIf ZZE->ZZE_STATUS == "8"
			Alert("Retrabalho Encerrado C.Q.")
		ElseIf ZZE->ZZE_STATUS == "9"
			Alert("Retrabalho Cancelado")
		EndIf
		If ZZE->ZZE_SITUAC == "1" .Or. ZZE->ZZE_STATUS $ "589" 
			_lTemErro := .T.
			Exit
		EndIf
		ZZE->(DbSkip())
	EndDo
	
	If _lTemErro
		Return(.F.)
	EndIf
	
	DbSeek(xFilial("ZZE")+_cId,.F.)
	_cNumBob := ZZE->ZZE_NUMBOB
	_cProduto:= ZZE->ZZE_PRODUT
	_cAcond  := Padr(ZZE->ZZE_ACONDE+StrZero(ZZE->ZZE_METRAE,5),TamSX3("BE_LOCALIZ")[1])
	_nQtdDisp:= ZZE->ZZE_TOTEN
	_nQtdEnc := ZZE->ZZE_TOTEN
	_nTotEnt := ZZE->ZZE_TOTEN
	_cMotivo := ZZE->ZZE_MOTIVO
	_cDesMot := ZZE->ZZE_DESMOV
	_nLances := ZZE->ZZE_LANCEE
	_cObser  := ZZE->ZZE_OBSERV
	_nQtdARt3:= 0 // Quantidade a devolver para estoque/sucata
	_nQtdARtA:= 0 // Quantidade devolvida para estoque/sucata
	_cDescri :=	Posicione("SB1",1,xFilial("SB1")+ZZE->ZZE_PRODUT,"B1_DESC")
	_nEle001 := 0
	aCols := {}
	aColsCln := {} // Crio c?pia do aCols para poder comparar se houve altera??o em alguma linha
	Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE->ZZE_ID == _cId .And. ZZE->(!Eof())
		// Carregar dados no aCols
		If ZZE->ZZE_PEDIDO == "000001" // Para estoque ou para sucata
			If ZZE->ZZE_STATUS == "A" // ? retorno n?o esperado - s? considero a devolu??o
				_nQtdARtA += ZZE->ZZE_TOTSA // Quanto devolvido para estoque/sucata
			Else
				_nQtdARt3 += ZZE->ZZE_TOTSA  // Quanto a devolver para estoque/sucata
			EndIf
		Else
			_nQtdDisp -= ZZE->ZZE_TOTSA
		EndIf
		_nQtdEnc -= ZZE->ZZE_DEVTOT
		AADD(aCols,Array(nUsado+1))
		GDFieldPut("NUMPED" ,ZZE->ZZE_PEDIDO,Len(aCols))
		GDFieldPut("ITEMPV" ,ZZE->ZZE_ITEMPV,Len(aCols))
		GDFieldPut("DATENTR",ZZE->ZZE_PVENTR,Len(aCols))
		GDFieldPut("QUANT"  ,Posicione("SC6",1,xFilial("SC6")+ZZE->ZZE_PEDIDO+ZZE->ZZE_ITEMPV,"C6_QTDVEN"),Len(aCols))
		GDFieldPut("LOCALIZ",Padr(ZZE->ZZE_ACONDS+StrZero(ZZE->ZZE_METRAS,5),TamSX3("BE_LOCALIZ")[1]),Len(aCols))
		GDFieldPut("QTDLANC",ZZE->ZZE_LANCES,Len(aCols))
		GDFieldPut("TOTMETR",ZZE->ZZE_TOTSA,Len(aCols))
		GDFieldPut("QTDDEV" ,ZZE->ZZE_DEVTOT,Len(aCols))
		GDFieldPut("SEMANA"  ,Posicione("SC6",1,xFilial("SC6")+ZZE->ZZE_PEDIDO+ZZE->ZZE_ITEMPV,"C6_SEMANA"),Len(aCols))
	
		If ZZE_SITUAC == '1'
			GDFieldPut("STATUS" ,"Retrabalho Encerrado",Len(aCols))
		ElseIf ZZE_STATUS == '1'
			GDFieldPut("STATUS" ,"Aguardando Separa??o",Len(aCols))
		ElseIf ZZE_STATUS == '2'
			GDFieldPut("STATUS" ,"Aguardando Ordem Serv.",Len(aCols))
		ElseIf ZZE_STATUS == '3'
			GDFieldPut("STATUS" ,"Em Retrabalho",Len(aCols))
		ElseIf ZZE_STATUS == '4'
			GDFieldPut("STATUS" ,"Realizado",Len(aCols))
		ElseIf ZZE_STATUS == '9'
			GDFieldPut("STATUS" ,"Cancelado",Len(aCols))
		ElseIf ZZE_STATUS == 'A'
			GDFieldPut("STATUS" ,"Retorno n?o Planejado",Len(aCols))
		ElseIf ZZE_STATUS == 'B'
			GDFieldPut("STATUS" ,"Finzdo.Sem Atender Pedido",Len(aCols))
		Else
			GDFieldPut("STATUS" ,ZZE->ZZE_STATUS,Len(aCols))
		EndIf
	
		GDFieldPut("LINORIG","ZZE",Len(aCols))
		GDFieldPut("ETIQ"   ,Left(AllTrim(ZZE->ZZE_ETIQ+"N"),1),Len(aCols))
		GDFieldPut("NUMREG" ,ZZE->(Recno()),Len(aCols))
		_nTotDev += ZZE->ZZE_DEVTOT
		aCols[Len(aCols),nUsado+1] := .F.
		_nLiAtu := Len(aCols)
		If ZZE->ZZE_PEDIDO == "000001" .And. ZZE->ZZE_STATUS # "A"
			_nEle001 := _nLiAtu
		EndIf
	
		// Fazer o mesmo para aColsCln
		AADD(aColsCln,Array(nUsado+1))
		For _nCpa := 1 To nUsado+1
			aColsCln[_nLiAtu,_nCpa] := aCols[_nLiAtu,_nCpa]
		Next
	
		ZZE->(DbSkip())
	EndDo
	
	If _nQtdEnc < 0
		Alert("Erro no Saldo do Retrabalho")
		Return(.F.)
	EndIf
	
	_nQtdDisp -= Max(_nQtdARtA,_nQtdARt3)
	
	RefrDads(_cRotOpc)
Return(.T.)


/*/{Protheus.doc} FindBob
//TODO Procura Bobina.
@author zzz
@since 05/06/2017
@version undefined

@type function
/*/
User Function FindBob(cRotOpc)
	local oSql      := LibSqlObj():newLibSqlObj()
	_cProduto := Padr(" ",TamSX3("B1_COD"    )[1])
	_cDescri  := Padr(" ",TamSX3("B1_DESC"   )[1])
	_cAcond   := Padr(" ",TamSX3("BE_LOCALIZ")[1])
	_nLances  := 0
	_nQtdDisp := 0.00
	If Empty(_cNumBob)
		RefrDads(cRotOpc)
		o__cProd:SetFocus() // O foco tem que ir pro c?d produto
		Return(.T.)
	EndIf
    oSql:newAlias(qryFindBob(_cNumBob))
    if oSql:hasRecords()
        oSql:goTop()
		while oSql:notIsEof()
			DbSelectArea("SZE")
        	SZE->(DbGoTo(oSql:getValue('REC')))
			oSql:skip()
        endDo
	else
		DbSelectArea("SZE")
		SZE->(DbSetOrder(1))
		If !(SZE->(DbSeek(xFilial("SZE")+_cNumBob,.F.)))
			Alert("Bobina n?o Cadastrada")
			Return(.F.)
		ElseIf SZE->ZE_STATUS == "n" // Reservada
			DbSelectArea("SZR")
			DbSetOrder(1)           // ZR_FILIAL+ZR_NUMBOB
			If !DbSeek(xFilial("SZR") + _cNumBob,.F.)
				Alert("Bobina Reservada")
				Return(.F.)
			EndIf
		ElseIf SZE->ZE_STATUS # "T" // Reservada ou dispon?vel
			Alert("Bobina n?o Dispon?vel")
			Return(.F.)
		EndIf
    endif
    oSql:Close()
    FreeObj(oSql)
	_cProduto:= SZE->ZE_PRODUTO
	_cAcond  := Padr("B"+StrZero(SZE->ZE_QUANT,5),TamSX3("BE_LOCALIZ")[1])
	_nQtdDisp:= SZE->ZE_QUANT
	_cDescri :=	Posicione("SB1",1,xFilial("SB1")+SZE->ZE_PRODUTO,"B1_DESC")
	_nLances := 1
	RefrDads(cRotOpc)
Return(.T.)

static function qryFindBob(cNumBob)
	local cQry := ""

	cQry += " SELECT SZE.R_E_C_N_O_ AS [REC] "
	cQry += " FROM " + RetSqlName('SZE') + " SZE "
	cQry += " WHERE SZE.ZE_FILIAL = '" + xFilial('SZE') + "' "
	cQry += " AND SZE.ZE_NUMBOB = '" + AllTrim(cNumBob) + "' "
	cQry += " AND SZE.ZE_STATUS = 'T' "
	cQry += " AND SZE.D_E_L_E_T_ = '' "
return(cQry)

/*/{Protheus.doc} FindPrd
//TODO Procura Produto.
@author zzz
@since 05/06/2017
@version undefined

@type function
/*/
User Function FindPrd(cRotOpc)
	_cDescri  := Padr(" ",TamSX3("B1_DESC"   )[1])
	_cAcond   := Padr(" ",TamSX3("BE_LOCALIZ")[1])
	_nLances  := 0
	_nQtdDisp := 0.00
	If Empty(_cProduto)
		Alert("Dados Inv?lidos - Preencher Obrigatoriamente ID, Bobina ou Produto")
		RefrDads(cRotOpc)
		o__cId:SetFocus()
		Return(.T.)
	EndIf
	DbSelectArea("SB1")
	DbSetOrder(1)
	If !DbSeek(xFilial("SB1")+_cProduto,.F.)
		Alert("Produto n?o Cadastrado")
		Return(.F.)
	ElseIf SB1->B1_TIPO # "PA" .Or. SB1->B1_LOCALIZ # 'S' // Controla localiza??o
		Alert("N?o ? Produto de Estoque")
		Return(.F.)
	EndIf
	_cAcond  := Padr("  ",TamSX3("BE_LOCALIZ")[1])
	_nQtdDisp:= 0
	_cDescri :=	SB1->B1_DESC
	RefrDads(cRotOpc)
Return(.T.)


/*/{Protheus.doc} FindAcon
//TODO Procura Acondicionamento.
@author zzz
@since 05/06/2017
@version undefined

@type function
/*/
User Function FindAcon(cRotOpc)
	_nLances  := 0
	_nQtdDisp := 0.00
	If Empty(_cAcond)
		_cProduto := Padr(" ",TamSX3("B1_COD"    )[1])
		_cDescri  := Padr(" ",TamSX3("B1_DESC"   )[1])
		_cAcond   := Padr(" ",TamSX3("BE_LOCALIZ")[1])
		RefrDads(cRotOpc)
		o__cProd:SetFocus() // O foco tem que ir pro c?d produto
		Return(.T.)
	ElseIf Left(_cAcond,1) == "B"
		Alert("Retrabalho de Bobinas Somente com o N?mero da Bobina")
		Return(.F.)
	EndIf
	
	DbSelectArea("SBF")
	DbSetOrder(1) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	DbSeek(xFilial("SBF")+"01"+_cAcond+_cProduto,.F.)
	If SBF->(Eof()) .Or. (SBF->BF_QUANT-SBF->BF_EMPENHO) <= 0
		Alert("N?o H? Saldo para Este Retrabalho")
		Return(.F.)
	EndIf
	_nQtdDisp:= (SBF->BF_QUANT-SBF->BF_EMPENHO)
	RefrDads(cRotOpc)
Return(.T.)


/*/{Protheus.doc} FindQtLc
//TODO Procura Qtde de Lances.
@author zzz
@since 05/06/2017
@version undefined

@type function
/*/
User Function FindQtLc(cRotOpc)
	Local _nQtMetros
	_nQtdDisp := 0.00
	If _nLances <= 0
		Alert("Indique a Quantidade de Lances")
		Return(.F.)
	EndIf
	DbSelectArea("SBF")
	DbSetOrder(1) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
	If !Dbseek(xFilial("SBF")+"01"+_cAcond+_cProduto,.F.)
		Alert("N?o h? Saldo Dispon?vel Nesse Acondicionamento")
		Return(.F.)
	EndIf
	_nQtMetros := (_nLances * Val(Substr(_cAcond,2,5)))
	If (SBF->BF_QUANT-SBF->BF_EMPENHO) < _nQtMetros
		Alert("N?o h? Saldo Dispon?vel Nesse Acondicionamento")
		Return(.F.)
	EndIf
	_nQtdDisp := _nQtMetros
	RefrDads(cRotOpc)
Return(.T.)


/*/{Protheus.doc} VldPed
//TODO Valida Pedido.
@author zzz
@since 05/06/2017
@version undefined
@param nQuem, numeric, descricao
@type function
/*/
User Function VldPed(nQuem)
	Local nQuem,nQtdNec
	Local cVldPed := GDFieldGet("NUMPED",n)
	Local cVldIte := AllTrim(GDFieldGet("ITEMPV",n))
	Local _nCols
	
	If Left(GDFieldGet("LINORIG",n),2) == "ZZ"
		If nQuem == 1 // Digitou o Pedido
			If M->NUMPED # GDFieldGet("NUMPED",n)
				Alert("Altera??o do Pedido N?o Permitida")
				Return(.F.)
			EndIf
		ElseIf M->ITEMPV # GDFieldGet("ITEMPV",n)
			Alert("Altera??o do Pedido N?o Permitida")
			Return(.F.)
		EndIf
		// Mesmo estando OK, retornar para a grid de dados
		Return(.T.)
	EndIf
	
	If nQuem == 1 // Digitou o Pedido
		If M->NUMPED == GDFieldGet("NUMPED",n) // N?o alterou o pedido
			Return(.T.)
		EndIf
		cVldPed := M->NUMPED
	Else // Digitou o item
		cVldIte := M->ITEMPV
	EndIf
	
	If nQuem == 1 // Digitou o Pedido
		If M->NUMPED == "000001"
			GDFieldPut("ITEMPV" ,"99",n)
			cVldIte := "99"
		EndIf
	EndIf
	
	If cVldPed == "000001"
		Return(.T.)
	EndIf
	
	// Verificar se o pedido/item j? n?o foi digitado
	If nQuem == 2 // Digitou oItem
		For _nCols := 1 To Len(aCols)
			If _nCols # n .And. cVldPed == GDFieldGet("NUMPED",_nCols) .And. cVldIte == GDFieldGet("ITEMPV",_nCols)
				Alert("Pedido/Item j? Informado")
				Return(.F.)
			EndIf
		Next
	EndIf
	
	// Verificar se o Pedido existe
	DbSelectArea("SC6")
	DbSetOrder(1)
	If !DbSeek(xFilial("SC6") + cVldPed + cVldIte,.F.)
		Alert("Pedido n?o Cadastrado")
		Return(.F.)
	EndIf
	
	_nEstRes := 0 // quantidade a desconsiderar se houver reserva
	If !Empty(_cNumBob) .And. Empty(_cId) .And. !Empty(cVldPed) .And. !Empty(cVldIte)
		DbSelectArea("SZE")
		SZE->(DbSetOrder(1))
		If SZE->(DbSeek(xFilial("SZE")+_cNumBob,.F.))
			Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_NUMBOB == _cNumBob .And. SZE->(!Eof())
				if SZE->ZE_STATUS == 'n' 
					DbSelectArea("SZR")
					SZR->(DbSetOrder(1))// ZR_FILIAL+ZR_NUMBOB
					if (SZR->(DbSeek(xFilial("SZR") + _cNumBob,.F.)))
						If SZR->ZR_PEDIDO # cVldPed .Or. SZR->ZR_ITEMPV # cVldIte
							Alert("Bobina reservada para outro pedido")
							Return(.F.)
						EndIf
						_nEstRes := SZR->ZR_QTDPV
					endif
					EXIT
				endif
				SZE->(DbSkip())
			EndDo
		EndIf
	EndIf	
	If !Empty(cVldIte) // N?o sei qual item, ent?o s? aceito o pedido
		If SC6->C6_PRODUTO # _cProduto
			Alert("Produtos Diferentes!" + Chr(13) + Chr(13) + ;
			"Retrabalho: -->" + _cProduto + Chr(13) + ;
			"Pedido " + cVldPed + "-" + cVldIte + ": -->" + SC6->C6_PRODUTO)
			Return(.F.)
		EndIf
		// Verificar se o TES movimenta estoque
		If Posicione("SF4",1,xFilial("SF4")+SC6->C6_TES,"F4_ESTOQUE") # "S" // N?o movimenta estoque
			Alert("Item Inv?lido - N?o Movimenta Estoque")
			Return(.F.)
		EndIf
		nQtdNec := 0
		DbSelectArea("SC9")
		DbSetOrder(1)
		DbSeek(xFilial("SC9")+ cVldPed + cVldIte,.F.)
		Do While SC9->C9_FILIAL == xFilial("SC9") .And. SC9->C9_PEDIDO == cVldPed .And. SC9->C9_ITEM == cVldIte .And. SC9->(!Eof())
			If SC9->C9_BLEST == "02"
				nQtdNec += SC9->C9_QTDLIB
			EndIf
			SC9->(DbSkip())
		EndDo
		If nQtdNec <= 0
			Alert("Item Inv?lido - N?o H? Quantidade a Entregar")
			Return(.F.)
		EndIf
	
		nQtdNec := Min(nQtdNec,(SC6->C6_QTDVEN-SC6->C6_QTDRES+_nEstRes))
		If nQtdNec <= 0
			Alert("Item Inv?lido - N?o H? Quantidade a Entregar")
			Return(.F.)
		EndIf
		// VERIFICAR A TABELA SZ9 SE N?O EST? COM ETIQUETA EMITIDA PARA PRODU??O
		DbSelectArea("SZ9")
		DbSetOrder(7) // Z9_FILIAL+Z9_PEDIDO+Z9_ITEMPV
		If DbSeek(xFilial("SZ9")+cVldPed + cVldIte,.T.)
			If SZ9->Z9_IMPETIQ == "P" 
				Alert("Etiquetas de Produ??o Suspensas - Consulte Expedi??o")
				Return(.F.)
			ElseIf (SZ9->Z9_IMPETIQ == "S" .Or. SZ9->Z9_ETIQIMP >= SZ9->Z9_LANCES) .And. SZ9->Z9_QUANT > 0
				Alert("Etiquetas de Produ??o J? Impressas")
				Return(.F.)
			EndIf
		EndIf
		GDFieldPut("SEMANA" ,SC6->C6_SEMANA,n)
		GDFieldPut("DATENTR",SC6->C6_ENTREG,n)
		GDFieldPut("LOCALIZ",Padr(SC6->C6_ACONDIC+StrZero(SC6->C6_METRAGE,5),TamSX3("BE_LOCALIZ")[1]),n)
		GDFieldPut("QUANT"  ,nQtdNec,n)
		oGetDados:Refresh()
	EndIf
	// Verificar se est? em resumo e for bobina e tratar o SZ9
Return(.T.)


/*/{Protheus.doc} VldLoc
//TODO Valida Localiza??o.
@author zzz
@since 05/06/2017
@version undefined

@type function
/*/
User Function VldLoc(_cRotOpc)
	// Valida??o do acondicionamento
	
	If Empty(GDFieldGet("NUMPED",n)) .Or. Empty(GDFieldGet("ITEMPV",n))
		Alert("Informar Obrigatoriamente o Pedido/Item (V?lido ou 000001-99)")
		Return(.F.)
	ElseIf GDFieldGet("NUMPED",n) # "000001" // Se for um pedido v?lido
		If M->LOCALIZ # GDFieldGet("LOCALIZ",n)
			Alert("Altera??o do Acondicionamento N?o Permitida")
			Return(.F.)
		Else
			Return(.T.)
		EndIf
	EndIf
	If !Left(M->LOCALIZ,1) $ "BCMRTLS" //.Or. AllTrim(M->LOCALIZ) == AllTrim(M->_cAcond)
		Alert("Acondicionamento Inv?lido")
		Return(.F.)
	EndIf
	If Val(Substr(M->LOCALIZ,2,5)) > Val(Substr(M->_cAcond,2,5))
		Alert("Acondicionamento Inv?lido")
		Return(.F.)
	EndIf
	If GDFieldGet("QTDLANC",n) > 0
		Alert("Para Alterar o Acondicionamento Zere Qtd.Lances")
		Return(.F.)
	EndIf
	If Left(M->LOCALIZ,1) == "S"
		// Verificar se tem mais de 1 registro para sucata.
		_lVolte := .F.
		For _nSuc := 1 to Len(aCols)
			If !GDDeleted(_nSuc) .And. _nSuc <> n
				If Left(GDFieldGet("LOCALIZ",_nSuc),1) == "S"
					_lVolte := .T.
					Exit
				EndIf
			EndIf
		Next
		If _lVolte
			Alert("Usar Somente uma Linha para Sucateamento")
			Return(.F.)
		/*ElseIf Val(Substr(M->LOCALIZ,2,5)) > 50
			Alert("Aten??o Quantidade Sucata Superior a 50KG")
			//Return(.F.)*/
		EndIf
	EndIf
Return(.T.)


/*/{Protheus.doc} VldLnc
//TODO Valida Lance digitado.
@author zzz
@since 05/06/2017
@version undefined

@type function
/*/
User Function VldLnc(_cRotOpc)
	Local nTamLc, nTtMtr
	
	// Valida??o do lance
	If !(GDFieldGet("ETIQ",n) $ "N ")
		Alert("Altera??o permitida Somente se as Etiquetas n?o Estiverem Emitidas")
		Return(.F.)
	ElseIf M->QTDLANC < 0 //.Or. M->QTDLANC > _nLances
		Alert("Quantidade Inv?lida")
		Return(.F.)
	EndIf
	
	nTamLc := Val(Substr(GDFieldGet("LOCALIZ",n),2,5))
	nTtMtr := (M->QTDLANC * nTamLc)
	/*If nTtMtr > 50 .And. Left(GDFieldGet("LOCALIZ",n),1) == "S" // Para sucata mais de 50 metros
		Alert("Quantidade Inv?lida para Sucateamento")
		Return(.F.)
	EndIf*/
	
	DbSelectArea("SZ9")
	DbSetOrder(7) // Z9_FILIAL+Z9_PEDIDO+Z9_ITEMPV
	If DbSeek(xFilial("SZ9")+ GDFieldGet("NUMPED",n) + GDFieldGet("ITEMPV",n),.T.)
		If SZ9->Z9_IMPETIQ == "P" 
			Alert("Etiquetas de Produ??o Suspendas - Consulta Expedi??o")
			Return(.F.)
		ElseIf (SZ9->Z9_IMPETIQ == "S" .Or. SZ9->Z9_ETIQIMP >= SZ9->Z9_LANCES) .And. SZ9->Z9_QUANT > 0
			Alert("Etiquetas de Produ??o J? Impressas")
			Return(.F.)
		EndIf
	EndIf
	
	If nTtMtr < GDFieldGet("QTDDEV",n)
		Alert("J? Devolvido " + AllTrim(Str(GDFieldGet("QTDDEV",n))) + " lances")
		Return(.F.)
	EndIf
	_nQtdDisp += (GDFieldGet("TOTMETR",n) - nTtMtr)
	GDFieldPut("TOTMETR",nTtMtr,n)
	RefrDads(_cRotOpc)
Return(.T.)


/*/{Protheus.doc} VldLin
//TODO Valida??o da linha do grid.
@author zzz
@since 05/06/2017
@version undefined

@type function
/*/
User Function VldLin(_cRotOpc)
	Local _nCl, _nCpa
	Local _lVazio := .F.
	Local _aCols := {}
	
	If n > Len(aColsCln) .And. n == Len(aCols) // Estou na ultima linha e n?o ? a ?nica
		GDFieldPut("DATENTR",Ctod("  /  /  "),n)
	EndIf
	
	If n > 1 .And. n > Len(aColsCln) .And. n == Len(aCols) // Estou na ultima linha e n?o ? a ?nica
		_lVazio := .T.
		// Verificar se todos os itens est?o vazios
		For _nCl := 1 To Len(aCols[n])
			If !Empty(aCols[n,_nCl])
				_lVazio := .F.
				Exit
			EndIf
		Next
	EndIf
	
	If _lVazio  .Or. GDFieldGet("TOTMETR",n) <= 0
		// Transferir todos os dados para outro array
		_aCols := {}
		For _nCl := 1 To Len(aCols)-1
			AADD(_aCols,Array(nUsado+1))
			For _nCpa := 1 To nUsado+1
				_aCols[_nCl,_nCpa] := aCols[_nCl,_nCpa]
			Next
		Next
	
		//Retornar as informa??es pro aCols
		aCols := {}
		For _nCl := 1 To Len(_aCols)
			AADD(aCols,Array(nUsado+1))
			For _nCpa := 1 To nUsado+1
				aCols[_nCl,_nCpa] := _aCols[_nCl,_nCpa]
			Next
		Next
		n--
		If Len(aCols) == 0
			n:=1
			aCols:={Array(nUsado+1)}
			aCols[1,01]:=Padr(" ",TamSX3("C6_NUM"    )[1])
			aCols[1,02]:=Padr(" ",TamSX3("C6_ITEM"   )[1])
			aCols[1,03]:=Ctod("  /  /  ")
			aCols[1,04]:=0.00
			aCols[1,05]:="      "
			aCols[1,06]:=0
			aCols[1,07]:=0.00
			aCols[1,08]:=0.00
			aCols[1,09]:=Padr(" ",TamSX3("C6_SEMANA"   )[1])
			aCols[1,10]:=" "
			aCols[1,11]:="   "
			aCols[1,12]:=" "
			aCols[1,nUsado+1]:=.F.
		EndIf
		oGetDados:Refresh()
		Return(.F.)
	EndIf
	
	If  (!Empty(GDFieldGet("NUMPED",n)) .And.  Empty(GDFieldGet("ITEMPV",n))) .Or. ;
		( Empty(GDFieldGet("NUMPED",n)) .And. !Empty(GDFieldGet("ITEMPV",n)))
	
		// Assume o deletado como estava independente de como est?
		If Right(GDFieldGet("LINORIG",n),1) == "D"
			aCols[n,Len(aCols[n])] := .T.
		Else
			aCols[n,Len(aCols[n])] := .F.
		EndIf
		Alert("Informar Obrigatoriamente N?mero + Item do Pedido")
		Return(.F.)
	EndIf
	
	If GDDeleted(n)     // Est? deletado ?
		If GDFieldGet("ETIQ",n) == "S" // Esta deletado e as etiquetas est?o emitidas
			Alert("N?o ? Permitido Altera??o com Etiquetas Emitidas")
			Return(.F.)
		ElseIf GDFieldGet("QTDDEV",n) >= GDFieldGet("TOTMETR",n)
			Alert("J? Efetuada a Devolu??o Desse Retrabalho")
			Return(.F.)
		Else
			//_nQtdDisp += (GDFieldGet("TOTMETR",n)-GDFieldGet("QTDDEV",n)) // Deixo a quantidade dispov?vel para uso diferente
			// Altero a origem para saber que quando tirar a dele??o, eu saber que estava deletado
			If GDFieldGet("LINORIG",n) == "ZZE"
				GDFieldPut("LINORIG","ZZD",n)
			Else
				GDFieldPut("LINORIG","  D",n)
			EndIf
		EndIf
	ElseIf Right(GDFieldGet("LINORIG",n),1) == "D" // N?o est? deletado, mas estava. Tirou a dele??o agora.
		//_nQtdDisp -= (GDFieldGet("TOTMETR",n)-GDFieldGet("QTDDEV",n)) // Deixo a quantidade dispov?vel para uso diferente
		// Volto a origem para saber que quando tirar a dele??o, eu saber que estava deletado
		If GDFieldGet("LINORIG",n) == "ZZD"
			GDFieldPut("LINORIG","ZZE",n)
		Else
			GDFieldPut("LINORIG","   ",n)
		EndIf
	EndIf
	
	_nQtdDisp := (_nLances * Val(Substr(_cAcond,2,5)))
	For _nCls:=1 To Len(aCols)
		If !GDDeleted(_nCls) .And. AllTrim(GDFieldGet("STATUS",_nCls)) # "Retorno n?o Planejado"// Est? deletado e n?o ? um retorno n?o planejado
			_nQtdDisp -= GDFieldGet("TOTMETR",_nCls) //
		EndIf
	Next
	
	RefrDads(_cRotOpc)
	oGetDados:Refresh()
Return(.T.)


/*/{Protheus.doc} VldTud
//TODO Valida Tudo.
@author zzz
@since 05/06/2017
@version undefined

@type function
/*/
User Function VldTud(_cRotOpc)
	If _nQtdDisp # 0
		Alert("Para Encerrar a Manuten??o, a Quant.Disp. tem que ser Zero")
		Return(.F.)
	EndIf
Return(.T.)


/*/{Protheus.doc} GraveNovo
//TODO Descri??o auto-gerada.
@author zzz
@since 05/06/2017
@version undefined

@type function
/*/
Static Function GraveNovo()
	local lAchou := .F.
	// Verificar se a Bobina est? dispon?vel
	// Fazer Empenho
	BeginTran()
	
	// Verifico se ? bobina resevada e primeiro retiro a reserva
	If !Empty(_cNumBob)
		DbSelectArea("SZE")
		DbSetOrder(1)
		if DbSeek(xFilial("SZE")+_cNumBob,.F.)		
			Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_NUMBOB == _cNumBob .And. SZE->(!Eof())
				if SZE->ZE_STATUS == 'n' 
					SZE->(RecLock("SZE",.F.))
						SZE->ZE_STATUS := "T"
					SZE->(MsUnLock())
				endif
				SZE->(DbSkip())
			EndDo
		endif
		DbSelectArea("SZR")
		DbSetOrder(1)        // ZR_FILIAL+ZR_NUMBOB
		DbSeek(xFilial("SZR") + _cNumBob,.F.)
		Do While SZR->ZR_FILIAL == xFilial("SZR") .And. SZR->ZR_NUMBOB == _cNumBob .And. SZR->(!Eof())
			DbSelectArea("SC6")
			DbSetOrder(1)
			If DbSeek(xFilial("SC6") + SZR->ZR_PEDIDO + SZR->ZR_ITEMPV,.F.)
				SC6->(RecLock("SC6",.F.))
				SC6->C6_QTDRES := (SC6->C6_QTDRES - SZR->ZR_QTDPV)
				SC6->(MsUnLock())
			EndIf
			DbSelectArea("SZR")
			SZR->(RecLock("SZR",.F.))
			SZR->(DbDelete())
			SZR->(MsUnLock())
			SZR->(DbSkip())
		EndDo
	EndIf
	
	// Pegar pr?ximo ID do ZZE
	cIdRetr := GetSXENum("ZZE","ZZE_ID")
	DbSelectArea("ZZE")
	DbSetOrder(1)
	Do While DbSeek(xFilial("ZZE") + cIdRetr,.F.)
		ConfirmSX8()
		cIdRetr := GetSXENum("ZZE","ZZE_ID")
	EndDo
	
	aRet := u_EmpSDC(.T. /* .T.=Empenhar .F.=Cancelar Empenho*/,;
			"ZZF"/*Origem*/,;
			_cProduto/*Produto*/,;
			"01"/*Local*/,;
			PadR(_cAcond,TamSX3("BE_LOCALIZ")[1])/*cLocaliz*/,;
			Val(Substr(_cAcond,2,5))*_nLances/*Quant*/,;
			cIdRetr/*Docto*/,;
			_cNumBob/*Nro.Bobina*/,;
			.F. /*Trata ou n?o Transa??o*/;
			)
	
	
	DbSelectArea("SZE")
	DbSetOrder(1)
	If !Empty(_cNumBob)
		DbSeek(xFilial("SZE")+_cNumBob,.F.)
		Do While SZE->ZE_FILIAL == xFilial("SZE") .And. SZE->ZE_NUMBOB == _cNumBob .And. SZE->(!Eof())
			if SZE->ZE_STATUS == 'N' 
				lAchou := .T.
				EXIT
			endif
			SZE->(DbSkip())
		EndDo
		if !lAchou
			DbSeek(xFilial("SZE")+_cNumBob,.F.)
		endif
	EndIf
	
	If aRet[1] // Transferido com sucesso ????
		// Gerar uma ?nica separacao de retrabalho (ZZF) para todos itens deste ZZE (retrabalho)
		ZZF->( RecLock("ZZF", .T.) )
		ZZF->ZZF_FILIAL := xFilial("ZZF")
		ZZF->ZZF_ZZEID  := cIdRetr
		ZZF->ZZF_STATUS := "2" // AGUARDANDO
		ZZF->ZZF_TIPO   := "R"
		ZZF->ZZF_DTINC  := ddatabase
		ZZF->ZZF_LANCES	:= _nLances
		ZZF->ZZF_METRAS	:= Val(Substr(_cAcond,2,5))
		ZZF->ZZF_ACONDS	:= Substr(_cAcond,1,1)
		ZZF->ZZF_FILPV	:= xFilial("SC6")
		ZZF->ZZF_PRODUT	:= _cProduto
	
		
		If !Empty(_cNumBob)
			ZZF->ZZF_NUMBOB	:= _cNumBob
			ZZF->ZZF_TPBOB	:= SZE->ZE_TPBOB
		EndIf
		
	
		ZZF->(MsUnLock())
	
		_lItemZZT := 0
		For _nCols := 1 To Len(aCols)
			If GDFieldGet("NUMPED",_nCols) == "000001"
				_lItemZZT := _nCols
				If Left(GDFieldGet("LOCALIZ",_nCols),1) == "S"
					Exit
				EndIf
			EndIf
		Next
	
		DbSelectArea("ZZE")
		DbSetOrder(2)
		For _nCols := 1 To Len(aCols)
			If GDDeleted(_nCols) .Or. Empty(GDFieldGet("NUMPED",_nCols)) //Est? deletado ou Nro.Pedido est? vazio
				Loop
			EndIf
	
			If GDFieldGet("NUMPED",_nCols) # "000001"
				DbSelectArea("SC5")
				DbSetOrder(1)
				DbSeek(xFilial("SC5")+GDFieldGet("NUMPED",_nCols),.F.)
	
				DbSelectArea("SA1")
				DbSetOrder(1)
				DbSeek(xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,.F.)
			EndIf
			ZZE->(RecLock("ZZE",.T.))
			ZZE->ZZE_FILIAL	:= xFilial("ZZE")
			ZZE->ZZE_ID		:= cIdRetr
			ZZE->ZZE_PRODUT	:= _cProduto
			ZZE->ZZE_PEDIDO	:= GDFieldGet("NUMPED",_nCols)
			ZZE->ZZE_ITEMPV	:= GDFieldGet("ITEMPV",_nCols)
			If GDFieldGet("NUMPED",_nCols) # "000001"
				ZZE->ZZE_CODCLI	:= SA1->A1_COD
				ZZE->ZZE_LOJA	:= SA1->A1_LOJA
				ZZE->ZZE_NOMCLI	:= SA1->A1_NOME
			EndIf
			ZZE->ZZE_PVENTR	:= GDFieldGet("DATENTR",_nCols)
			ZZE->ZZE_DTINI	:= ddatabase
			ZZE->ZZE_NUMBOB	:= _cNumBob
			ZZE->ZZE_OBSERV	:= AllTrim(_cObser)
			ZZE->ZZE_ACONDE	:= Left(_cAcond,1)
			ZZE->ZZE_METRAE	:= Val(Substr(_cAcond,2,5))
			ZZE->ZZE_LANCEE	:= _nLances
			ZZE->ZZE_TOTEN	:= (ZZE->ZZE_METRAE*ZZE->ZZE_LANCEE)
			ZZE->ZZE_ACONDS	:= Left(GDFieldGet("LOCALIZ",_nCols),1)
			ZZE->ZZE_METRAS	:= Val(Substr(GDFieldGet("LOCALIZ",_nCols),2,5))
			ZZE->ZZE_TOTSA	:= GDFieldGet("TOTMETR",_nCols)
			ZZE->ZZE_LANCES	:= GDFieldGet("QTDLANC",_nCols)
			ZZE->ZZE_STATUS	:= "1"
			ZZE->ZZE_SALDO	:= ZZE->ZZE_TOTEN
			ZZE->ZZE_SITUAC	:= '2'
			ZZE->ZZE_MOTIVO := _cMotivo
			ZZE->ZZE_DESMOV := _cDesMot
			ZZE->(MsUnLock())
	
			If ZZE->ZZE_PEDIDO # "000001"
				SC6->(DbSetOrder(1))
				SC6->(DbSeek(xFilial("SC6") + ZZE->ZZE_PEDIDO+ZZE->ZZE_ITEMPV,.F. ))
				SC6->(RecLock("SC6",.F.))
				SC6->C6_SEMANA  := "r" + cIdRetr
				SC6->C6_QTDRES  := SC6->C6_QTDRES + ZZE->ZZE_TOTSA
				SC6->C6_XQTDRET := SC6->C6_XQTDRET + ZZE->ZZE_LANCES // Roberto Oliveira -  Estava ZZE->ZZE_TOTSA nonde agora est? ZZE->ZZE_LANCES - SC6->C6_XQTDRET tem quant. de lances e n?o em metros.
				SC6->(MsUnLock())
	
				DbSelectArea("SZ9")
				DbSetOrder(7) // Z9_FILIAL+Z9_PEDIDO+Z9_ITEMPV
				If DbSeek(xFilial("SZ9")+ZZE->ZZE_PEDIDO+ZZE->ZZE_ITEMPV,.F.)
					SZ9->(RecLock("SZ9",.F.))
					SZ9->Z9_LANCES -= ZZE->ZZE_LANCES
					If SZ9->Z9_ETIQIMP >= SZ9->Z9_LANCES .And. SZ9->Z9_IMPETIQ $ " N"
						SZ9->Z9_IMPETIQ := "S"
					EndIf
					SZ9->(MsUnLock())
				EndIf
			EndIf
	
	
			If _lItemZZT == _nCols
				// Gravar somente 1 ZZT
				cIdTrans := GetSXENum("ZZT","ZZT_ID")
	
				DbSelectArea("ZZT")	// grava tabela de ZZT SOBRAS DE RETRABALHO
				DbSetOrder(1)
				Do While ZZT->(DbSeek(xFilial("ZZT") + cIdTrans,.F.))
					ConfirmSX8()
					cIdTrans := GetSXENum("ZZT","ZZT_ID")
				EndDo
	
				ZZT->(RecLock("ZZT",.T.))
				ZZT->ZZT_FILIAL := xFilial("ZZT")
				ZZT->ZZT_ID     := cIdTrans
				ZZT->ZZT_ZZEID  := cIdRetr
				If Left(GDFieldGet("LOCALIZ",_nCols),1) == "S" // sucata
					ZZT->ZZT_STATUS := "2" // sucata
				Else
					ZZT->ZZT_STATUS := "1" // AGUARDANDO DESTINACAO
				EndIf
	
				ZZT->ZZT_TIPO   := "T" // SEPARAR MATERIAL PARA PEDIDO DE VENDA
				ZZT->ZZT_DTINC  := ddatabase
				ZZT->ZZT_PEDIDO	:= ""
				ZZT->ZZT_ITEMPV	:= ""
				ZZT->ZZT_LANCES	:= GDFieldGet("QTDLANC",_nCols)
				ZZT->ZZT_METRAS	:= Val(Substr(GDFieldGet("LOCALIZ",_nCols),2,5))
				ZZT->ZZT_ACONDS	:= Left(GDFieldGet("LOCALIZ",_nCols),1)
				ZZT->ZZT_NUMBOB := _cNumBob
				ZZT->ZZT_PRODUT := _cProduto
				ZZT->ZZT_DESCP  := POSICIONE("SB1", 1, xFilial("SB1")+_cProduto, "B1_DESC")
				ZZT->(MsUnLock())
				ConfirmSX8()
			EndIf
		Next
		DbSelectArea("ZZE")
		ConfirmSX8()
	Else
		RollBackSX8()
		DisarmTransaction()
	EndIf
	EndTran()
Return(.T.)


/*/{Protheus.doc} GraveAlt
//TODO Descri??o auto-gerada.
@author zzz
@since 05/06/2017
@version undefined
@param _cTipo, , descricao
@param _nCpa, , descricao
@type function
/*/
Static Function GraveAlt(_cTipo,_nCpa)
	Local _cTipo	// "E" Excluiu - "A" Alterou - "I" Incluiu
	Local _nCpa		// Linha do aCols
	Local _nQtdZZE := 0 // Quantidade no ZZE antes da alteral?ao
	
	If GDFieldGet("NUMPED",_nCpa) # "000001"
		If _cTipo $ "AE" // Alterou ou Excluiu
			DbSelectArea("ZZE")
			DbGoTo(GDFieldGet("NUMREG" ,_nCpa))
			_nQtdZZE := ZZE->ZZE_LANCES
	
			DbSelectArea("SC6")
			DbSetOrder(1)
			If DbSeek(xFilial("SC6")+GDFieldGet("NUMPED",_nCpa)+GDFieldGet("ITEMPV",_nCpa),.F.)
				SC6->(RecLock("SC6",.F.))
				SC6->C6_SEMANA  := "      "
				SC6->C6_QTDRES  := SC6->C6_QTDRES  - ZZE->ZZE_TOTSA
				SC6->C6_XQTDRET := SC6->C6_XQTDRET - ZZE->ZZE_LANCES // Roberto Oliveira -  Estava ZZE->ZZE_TOTSA nonde agora est? ZZE->ZZE_LANCES - SC6->C6_XQTDRET tem quant. de lances e n?o em metros.
				SC6->(MsUnLock())
			EndIf
		EndIf
		If _cTipo $ "AI" // Alterou ou Incluiu
			DbSelectArea("SC6")
			DbSetOrder(1)
			DbSeek(xFilial("SC6")+GDFieldGet("NUMPED",_nCpa)+GDFieldGet("ITEMPV",_nCpa),.F.)
			SC6->(RecLock("SC6",.F.))
			SC6->C6_SEMANA  := "r" + cIdRetr
			SC6->C6_QTDRES  := SC6->C6_QTDRES  + GDFieldGet("TOTMETR",_nCpa)
			SC6->C6_XQTDRET := SC6->C6_XQTDRET + GDFieldGet("QTDLANC",_nCpa)      // By Roberto Oliveira - GDFieldGet("TOTMETR",_nCpa)
			SC6->(MsUnLock())
		EndIf
	EndIf
	
	If GDFieldGet("NUMPED",_nCpa) # "000001" .And. _cTipo $ "AI" // Alterou ou Incluiu
		DbSelectArea("SC6")
		DbSetOrder(1)
		DbSeek(xFilial("SC6")+GDFieldGet("NUMPED",_nCpa)+GDFieldGet("ITEMPV",_nCpa),.F.)
		DbSelectArea("SA1")
		DbSeek(xFilial("SA1") + SC6->C6_CLI + SC6->C6_LOJA,.F.)
	EndIf
	
	If _cTipo $ "AE" // Alterou ou Excluiu
		DbSelectArea("ZZE")
		DbGoTo(GDFieldGet("NUMREG" ,_nCpa))
		ZZE->(RecLock("ZZE",.F.))
		If _cTipo == "E" // Excluiu
			ZZE->(DbDelete())
			ZZE->(MsUnLock())
		EndIf
	Else
		ZZE->(RecLock("ZZE",.T.))
	EndIf
	If _cTipo $ "AI" // Alterou ou Incluiu
		ZZE->ZZE_FILIAL	:= xFilial("ZZE")
		ZZE->ZZE_ID		:= cIdRetr
		ZZE->ZZE_PRODUT	:= _cProduto
		ZZE->ZZE_PEDIDO	:= GDFieldGet("NUMPED",_nCpa)
		ZZE->ZZE_ITEMPV	:= GDFieldGet("ITEMPV",_nCpa)
	
		If GDFieldGet("NUMPED",_nCpa) # "000001"
			ZZE->ZZE_CODCLI	:= SA1->A1_COD
			ZZE->ZZE_LOJA	:= SA1->A1_LOJA
			ZZE->ZZE_NOMCLI	:= SA1->A1_NOME
		EndIf
		ZZE->ZZE_PVENTR	:= GDFieldGet("DATENTR",_nCpa)
		ZZE->ZZE_DTINI	:= ddatabase
		ZZE->ZZE_NUMBOB	:= _cNumBob
		ZZE->ZZE_OBSERV	:= AllTrim(_cObser)
		ZZE->ZZE_ACONDE	:= Left(_cAcond,1)
		ZZE->ZZE_METRAE	:= Val(Substr(_cAcond,2,5))
		ZZE->ZZE_LANCEE	:= _nLances
		ZZE->ZZE_TOTEN	:= (ZZE->ZZE_METRAE*ZZE->ZZE_LANCEE)
		ZZE->ZZE_ACONDS	:= Left(GDFieldGet("LOCALIZ",_nCpa),1)
		ZZE->ZZE_METRAS	:= Val(Substr(GDFieldGet("LOCALIZ",_nCpa),2,5))
		ZZE->ZZE_TOTSA	:= GDFieldGet("TOTMETR",_nCpa)
		ZZE->ZZE_LANCES	:= GDFieldGet("QTDLANC",_nCpa)
		ZZE->ZZE_STATUS	:= If(Empty(_cStatus),"1",_cStatus)
		ZZE->ZZE_SALDO	:= ZZE->ZZE_TOTEN
		ZZE->ZZE_SITUAC	:= '2'
		ZZE->ZZE_MOTIVO := _cMotivo
		ZZE->ZZE_DESMOV := _cDesMot
		ZZE->(MsUnLock())
	EndIf
	
	DbSelectArea("SZ9")
	DbSetOrder(7) // Z9_FILIAL+Z9_PEDIDO+Z9_ITEMPV
	If DbSeek(xFilial("SZ9")+GDFieldGet("NUMPED",_nCpa)+GDFieldGet("ITEMPV",_nCpa),.F.)
		SZ9->(RecLock("SZ9",.F.))
		If _cTipo $ "AE" // Alterou ou Excluiu
			SZ9->Z9_LANCES += _nQtdZZE
		EndIf
		If _cTipo $ "AI" // Alterou ou Incluiu
			SZ9->Z9_LANCES -= GDFieldGet("QTDLANC",_nCpa)
		EndIf
		SZ9->(MsUnLock())
	EndIf
Return(.T.)


/*/{Protheus.doc} CRESTENC
//TODO Descri??o auto-gerada.
@author zzz
@since 05/06/2017
@version undefined

@type function
/*/
User Function CRESTENC()
	_cLangAtu := __LANGUAGE
	__LANGUAGE := "ENGLISH"
	If dDataBase <= GetMV("MV_DBLQMOV") .Or. dDataBase <= GetMV("MV_ULMES")
		Alert("Data Anterior ao ?ltimo Fechamento")
		Return(.F.)
	ElseIf MsgBox("Deseja Iniciar o Processamento da Rotina de Encerramento de Retrabalhos?","Confirma?","YesNo")
		Processa( {|| ProcEncer() },"Ajustando Saldos de Retrabalhos...")
	EndIf
	__LANGUAGE := _cLangAtu
Return(.t.)


/*/{Protheus.doc} ProcEncer
//TODO Esta rotina efetuar? o encerramento dos retrabalhos que j? foram realizados.
Considerar? somente os que foram realizados conforme foi solicitado, usando
como par?metro as quantidades enviadas e retornadas.
@author zzz
@since 23/06/2017
@version undefined

@type function
/*/
Static Function ProcEncer()
	Local _nQtReg := 0
	
	DbSelectArea("ZZE")
	DbSetOrder(1) //ZZE_FILIAL+ZZE_ID
	
	DbSelectArea("SD3")
	DbSetOrder(1)
	
	DbSelectArea("SB1")
	DbSetOrder(1)
	
	DbSelectArea("SBF")
	DbSetOrder(1)
	
	DbSelectArea("SDB")
	DbSetOrder(1)
	
	DbSelectArea("SDA")
	DbSetOrder(1)
	
	cQueryCon := " FROM "+RetSqlName("ZZE")"
	cQueryCon += " WHERE ZZE_FILIAL = '"+xFilial("ZZE")+"'"
	// cQueryCon += " AND ZZE_STATUS = '3'" // N?o interessa s? o que est? EM RETRABALHO, o sistema vai comparar a quantidade devolvida, se for igual, encerra.
	cQueryCon += " AND ZZE_SITUAC <> '1'"
	//cQueryCon += " AND ZZE_DTINI >= '20161204'"
	cQueryCon += " AND D_E_L_E_T_ = ''"
	
	cQuery := " SELECT COUNT(DISTINCT ZZE_ID) AS QTSZZE" + cQueryCon
	cQuery := ChangeQuery(cQuery)
	
	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"
	
	DbSelectArea("TRB")
	DbGotop()
	
	_nQtReg := TRB->QTSZZE
	
	cQuery := "SELECT DISTINCT ZZE_ID" + cQueryCon + " ORDER BY ZZE_ID"
	cQuery := ChangeQuery(cQuery)
	
	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	TCQUERY cQuery NEW ALIAS "TRB"
	ProcRegua(_nQtReg)
	
	_lVai := .T.
	DbSelectArea("TRB")
	DbGotop()
	Do While TRB->(!Eof()) .And. _lVai
		DbSelectArea("ZZE")
		DbSetOrder(1) //ZZE_FILIAL+ZZE_ID
		ZZE->(DbSeek(xFilial("ZZE") + TRB->ZZE_ID,.F.))
		_ZZE_DTINI := ZZE->ZZE_DTINI
		_cAcoEn := "" // Acondic de entrada
		_nTotEn := 0 // Total entrada
		_nTotDv := 0 // Total Sa?da
		_nTotSu := 0 // Total para Sucata
		_cProd  := ""
		_nRegSuc := 0
		_lOk := .T.
		IncProc()
		Begin Transaction
		Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE->ZZE_ID == TRB->ZZE_ID .And. ZZE->(!Eof()) .AND. _lVai
			_ZZE_DTINI := Max(ZZE->ZZE_DTINI,_ZZE_DTINI)  // Pegar a maior data
	
			If ZZE->ZZE_STATUS # "9" // N?o est? cancelado
				If	ZZE->ZZE_TOTEN > 0 .And. _nTotEn == 0 // Total entrada pego s? uma vez porque esta repetido nos registros do mesmo ID
					_cAcoEn := PadR((Left(ZZE->ZZE_ACONDE,1) + StrZero(ZZE_METRAE,5)),TamSX3("BE_LOCALIZ")[1])
					// Acondic de entrada
					_nTotEn := ZZE->ZZE_TOTEN // Total entrada
					_cProd  := ZZE->ZZE_PRODUT
				EndIf
				If ZZE->ZZE_PEDIDO == "000001" .And. ZZE->ZZE_ITEMPV = "99" .And. ZZE->ZZE_ACONDS == "S" // Sucata
					_nTotSu += ZZE->ZZE_METRAS // Total Sa?da de sucata
	 				_nRegSuc := ZZE->(Recno())
				Else
					_nTotDv += ZZE->ZZE_DEVTOT // Total Sa?da
				EndIf
			EndIf
	
			If !ZZE->(RecLock("ZZE",.F.))
				_lOk := .F.
				Exit
			Else
				ZZE->ZZE_SITUAC := '1' // Encerrado
				ZZE->ZZE_DTFIM  := dDataBase
				ZZE->(MsUnLock())
			EndIf
			ZZE->(DbSkip())
		EndDo
		If !_lOk
			DisarmTransaction()
		ElseIf _nTotDv == _nTotEn .And. _nTotSu == 0 // ok
			_lConfirma := .T. // Somente para ponto de parada
			// N?o tem o que fazer  - Basta deixar confirmar a transa??o
		ElseIf _nTotDv < _nTotEn .And. (_nTotEn-_nTotDv) <= _nTotSu .And. _nTotSu > 0 .And. (_nTotEn-_nTotDv) > 0 // .And. (_nTotEn-_nTotDv) <= 50
	
			If _ZZE_DTINI >= Ctod('04/12/2016') // Fazer o sucateamento da sobra
				// Em conversa com o Vitor, ? poss?vel enviar para sucata no m?ximo 50 metros, ent?o
				// considero que acima disso existe algum erro.
				// Fazer transfer?ncia da sobra para sucata
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1") + _cProd,.F.)
				If SB1->B1_COR == '00' // Cobre Nu
					_cCodSuc := "SC01000001" // SUCATA DE COBRE NU
				Else
					_cCodSuc := "SC01000002" //SUCATA DE COBRE ISOLADO
				EndIf
	
				_nQtdOri := (_nTotEn-_nTotDv)
				_cCodSuc := Padr(_cCodSuc,TamSX3("B1_COD")[1]) // Corrige tamanho da vari?vel.
	
				// Verifico se tenho saldo para poder transferir para sucata
				_nSaldDsp:= 0
				If SB1->B1_LOCALIZ == 'S' // Controla localiza??o, ent?o vejo o SBF
					DbSelectArea("SBF")
					DbSetOrder(1) // BF_FILIAL+BF_LOCAL+BF_LOCALIZ+BF_PRODUTO+BF_NUMSERI+BF_LOTECTL+BF_NUMLOTE
					If DbSeek(xFilial("SBF")+"90"+_cAcoEn+SB1->B1_COD,.F.)
						If SBF->BF_EMPENHO # 0 // Tem sentido ter empenho no local 90 ?
							RecLock("SBF",.F.)
							SBF->BF_EMPENHO := 0
							MsUnLock()
						EndIf
						_nSaldDsp := SBF->BF_QUANT
					EndIf
				Else // Sen?o, vejo o SB2
					Dbselectarea("SB2")
					DbsetOrder(1)
					If DbSeek(xFilial("SB2")+SB1->B1_COD+"90",.F.)
						_nSaldDsp := Max(SB2->B2_QATU,0)
					EndIf
				EndIf
	
	 			_nQtdOri := Min(_nQtdOri,_nSaldDsp)
				If _nQtdOri > 0
					_nQtdDes := (_nQtdOri * (SB1->B1_PESCOB+SB1->B1_PESPVC))
	
					// A fun??o PraSucata faz transfer?ncia da quantidade do c?digo normal
					// para sucata e retorna .T. se deu erro na atualiza??o
					// Par?metros:
					// PraSucata(_PrdOri    ,_PrdDes ,_LocOri,_LocDes,_LozOri,_LozDes,_Quant,Doc          ) // -> _lErrAtu
	
					If PraSucata(SB1->B1_COD,_cCodSuc,"90"   ,"91"   ,_cAcoEn,""    ,_nQtdOri, _nQtdDes,"ZZE"+TRB->ZZE_ID ) // Retorna se deu erro no execauto
						// Deu Erro
						DisarmTransaction()
					ElseIf _nRegSuc > 0
						// Gravar quanto foi pra sucata
						ZZE->(DbGoTo(_nRegSuc))
						ZZE->(RecLock("ZZE",.F.))
						ZZE->ZZE_DESMOV := "PraSucata " + AllTrim(Str(_nQtdOri,15,2))
						ZZE->(MsUnLock())
					EndIf
				EndIf
			Else
				_lConfirma := .T. // Somente para ponto de parada
				// N?o tem o que fazer  - Basta deixar confirmar a transa??o
			EndIf
		Else
			DisarmTransaction()
		EndIf
		End Transaction
		TRB->(DbSkip())
	EndDo
	If Select("TRB")>0
		DbSelectArea("TRB")
		DbCloseArea()
	EndIf
	Alert("Processamento Conclu?do")
Return(.T.)


/*/{Protheus.doc} PraSucata
//TODO Descri??o auto-gerada.
@author zzz
@since 05/06/2017
@version undefined
@param _PrdOri, , descricao
@param _PrdDes, , descricao
@param _LocOri, , descricao
@param _LocDes, , descricao
@param _LozOri, , descricao
@param _LozDes, , descricao
@param _Quant, , descricao
@param _nQtdDes, , descricao
@param _cDoc, , descricao
@type function
/*/
Static Function PraSucata(_PrdOri,_PrdDes,_LocOri,_LocDes,_LozOri,_LozDes,_Quant, _nQtdDes,_cDoc) // -> _lErrAtu
	// A fun??o PraSucata faz transfer?ncia da quantidade do c?digo normal
	// para sucata e retorna .T. se deu erro na atualiza??o
	// Par?metros:
	Local _PrdOri,_PrdDes,_LocOri,_LocDes,_LozOri,_LozDes,_Quant,_nQtdDes,_cDoc
	Private lAutoErrNoFile := .T.

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1") + _PrdOri,.F.)
	
	lMsErroAuto := .F.  // Assumo que est? com erro e deixo a rotina dizer a "verdade"
	
	aAutoCab := {	{"cProduto"   , _PrdOri					, Nil},;
					{"cLocOrig"   , _LocOri					, Nil},;
					{"cLocaliza"  , _LozOri					, Nil},;
					{"nQtdOrig"   , _Quant					, Nil},;
					{"cDocumento" , _cDoc					, Nil}}
	
	aAutoItens := {{{"D3_COD"    , _PrdDes					, Nil},	;	
					{"D3_LOCAL"  , _LocDes					, Nil}, ; 
					{"D3_QUANT"  , _nQtdDes					, Nil}, ;
					{"D3_USUARIO", cUserName				, Nil}, ;
					{"D3_RATEIO" , 100						, Nil}}}
	
	SB2->(DbSetOrder(1))
	If !SB2->(DbSeek(xFilial("SB2")+Pad(_PrdDes, Len(SD3->D3_COD))+_LocDes,.F.))
		CriaSB2(Pad(_PrdDes, Len(SD3->D3_COD)),_LocDes)
	EndIf
	
	DbSelectArea("SBF")
	DbSetOrder(1)
	//Posiciona
	If SBF->(DbSeek(xFilial("SBF") + _LocOri + _LozOri + _PrdOri)) //.or. Empty(_cAcond)	
		// Inclus?o
		MSExecAuto({|v,x,y,z| Mata242(v,x,y,z)},aAutoCab,aAutoItens,3,.T.)
		_aErro := GetAutoGRLog()
	Else
		Alert("Localiza??o incorreta!")
	EndIf
	
	If lMsErroAuto 
		Alert("Retrabalho n?o finalizado")
	EndIf
	
Return(lMsErroAuto)


/*/{Protheus.doc} FindMtv
//TODO Descri??o auto-gerada.
@author zzz
@since 23/06/2017
@version undefined

@type function
/*/
User Function FindMtv()
	If(_cMotivo=="00",.T.,ExistCpo("SX5","ZT"+M->_cMotivo))
	
	DbSelectArea("SX5")
	DbsetOrder(1)
	If !(DbSeek(xFilial("SX5")+"ZT"+M->_cMotivo,.F.))
		Alert("Motivo Inv?lido")
		Return(.F.)
	EndIf
	_cDesMot := Padr(SX5->X5_DESCRI,TamSX3("ZZE_DESMOV"   )[1])
	o__cDesMov:refresh()
Return(.T.)


/*/{Protheus.doc} EstR1Lg
//TODO .
@author zzz
@since 23/06/2017
@version undefined

@type function
/*/
User Function EstR1Lg()
	Local aLegenda	:= {}
	
	AADD(aLegenda, {"BR_VERDE"   , "Retrabalho Encerrado"})
	AADD(aLegenda, {"BR_VERMELHO", "Aguardando Separa??o"})
	AADD(aLegenda, {"BR_AZUL"    , "Aguardando Ordem Serv."})
	AADD(aLegenda, {"BR_AMARELO" , "Em Retrabalho"})
	AADD(aLegenda, {"BR_PRETO"   , "Realizado"})
	AADD(aLegenda, {"BR_MARROM"  , "Cancelado"})
	AADD(aLegenda, {"BR_VIOLETA" , "Retorno n?o Planejado"})
	AADD(aLegenda, {"BR_CINZA"   , "Finalizado Sem Atender Pedido"})
	
	BrwLegenda("Separa??o", "Legenda" , aLegenda)
Return .T.

/*/{Protheus.doc} CRESTLBE
//TODO Valida impress?o do Retrabalho.
@author zzz
@since 24/01/2017
@version undefined

@type function
/*/
User Function CRESTLBE()
	If ZZE->ZZE_STATUS <> '9' .and. ZZE->ZZE_SITUAC <> '1' .and. ZZE->ZZE_DEVTOT = 0
		RecLock("ZZE",.F.)
		ZZE->ZZE_ETIQ := ""
		MsUnLock()
		MsgBox("Etiqueta Liberada!", "Realizado", "INFO")
	Else
		Alert("Retrabalho ja Encerrado ou com saldo parcial devolvido!")
	EndIf
Return()
