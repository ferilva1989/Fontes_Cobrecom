#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} AltBlqPed
//TODO Permite Alterar Campos Especificos do Pedido sem estornar liberações ja realizadas.
@author juliana.leme
@since 14/07/2017
@version undefined

@type function
/*/
user function AltBlqPed()
    Local cLinok 	:= "Allwaystrue"
    Local cTudook 	:= "Allwaystrue"
    Local nOpce 	:= 4 	//define modo de alteração para a enchoice
    Local nOpcg 	:= 4 	//define modo de alteração para o grid
    Local cFieldok 	:= "Allwaystrue"
    Local lRet 		:= .T.
    Local cMensagem := ""
    Local lVirtual  := .T. 	//Mostra campos virtuais se houver
    Local nFreeze	:= 0
    Local nAlturaEnc:= 400	//Altura da Enchoice
    Local lFazMsmAssim := .T.

    Private cCadastro	:= "Pedido de Venda"
    Private aCols 		:= {}
    Private aHeader 	:= {}
    Private aCpoEnchoice:= {}
    Private aAltEnchoice:= {"C5_ZZBLVEN"}
    //Private aAltEnchoice:= {"C5_CONDPAG","C5_TPFRETE","C5_MENNOTA","C5_ZZPVCL","C5_ZZBOX","C5_ZZEQUIP","C5_ZZMOD1","C5_ZZMOD2","C5_ZZCAIXA"}
    Private cTitulo
    Private cAlias1 	:= "SC5"
    Private cAlias2 	:= "SC6"

    // Verifica se o pedido já está liberado
    If !Empty(SC5->C5_NOTA).Or.SC5->C5_LIBEROK=='E' .And. Empty(SC5->C5_BLQ)
        MsgStop("Este pedido está encerrado!")
    Else
        RegToMemory("SC5",.F.)
        RegToMemory("SC6",.F.)

        DefineCabec()
        DefineaCols(nOpcg)

        lRet:=Modelo3(cCadastro,cAlias1,cAlias2,aCpoEnchoice,cLinok,cTudook,nOpce,nOpcg,cFieldok,lVirtual,,aAltenchoice,nFreeze,,,nAlturaEnc)

        //retornará como true se clicar no botao confirmar
        If lRet
            cMensagem += "Esta rotina tem a finalidade de salvar alguns campos no PEDIDO DE VENDA LIBERADO"+CRLF+CRLF
            cMensagem += "APENAS os campos abaixo SERÃO SALVOS:"+CRLF+CRLF

            cMensagem += "Cabeçalho: "+CRLF
            cMensagem += "Bloqueio Faturamento ? (Sim/Não) "+CRLF+CRLF

            //cMensagem += "Itens:"+CRLF
            //cMensagem += "Item P.C.,Num.Ped.Comp"+CRLF+CRLF

            If MsgYesNo(cMensagem+"CONFIRMA ALTERAÇÃO DOS DADOS ?", cCadastro)
            	If SC5->C5_ZSTATUS == Padr('2',TamSX3("C5_ZSTATUS")[1]) .AND. M->C5_ZZBLVEN == 'S'
            		 If MsgYesNo("PEDIDO EM FATURAMENTO. DESEJA ALTERAR MESMO ASSIM ?", cCadastro)
            		 	_cPara := Alltrim("expedcom@cobrecom.com.br")
            		 	U_SendMail(_cPara,"Pedido Numero: "+ SC5->C5_NUM +" EM FATURAMENTO e BLOQUEADO ",+;
            		 			"Pedido Numero: "+ SC5->C5_NUM +" EM FATURAMENTO e BLOQUEADO ")
            		 	lFazMsmAssim := .T.
            		 Else
            		 	lFazMsmAssim := .F.
            		 EndIf
            	EndIf
            	If lFazMsmAssim
            		_aDadC5 := {SC5->C5_NUM,SC5->C5_CLIENTE,SC5->C5_LOJACLI,SC5->C5_ENTREG,SC5->C5_TIPO}
            		//U_CDGEN21I(6,"M->C5_ZZBLVEN",SC5->C5_ZZBLVEN,M->C5_ZZBLVEN)
            		u_CDGEN21I(2,,,,_aDadC5)
            		Processa({||Gravar()},cCadastro,"Alterando os dados, Aguarde...")
            	Else
            		Alert("Rotina Cancelada pelo Operador!")
            	EndIf
            Endif
        Else
            RollbackSx8()
        Endif
    Endif
return

/*/{Protheus.doc} DefineCabec
//TODO Define cabeçalho.
@author juliana.leme
@since 14/07/2017
@version undefined

@type function
/*/
Static Function DefineCabec()
    Local aSC6		:= {"C6_ITEM","C6_ITEMPC","C6_PRODUTO","C6_DESCRI","C6_ENTREG","C6_QTDVEN","C6_UNSVEN","C6_QTDLIB","C6_PRCVEN","C6_PRUNIT","C6_VALOR","C6_VALDESC","C6_DESCONT","C6_TES","C6_CF","C6_ITEMCON","C6_ENTREG","C6_BLQ"}
    Local nUsado
    aHeader		:= {}
    aCpoEnchoice:= {}

    nUsado:=0

    //Monta a enchoice
    DbSelectArea("SX3")
    SX3->(DbSetOrder(1))
    dbseek(cAlias1)
    while SX3->(!eof()) .AND. X3_ARQUIVO == cAlias1
        IF X3USO(X3_USADO) .AND. CNIVEL >= X3_NIVEL
            AADD(ACPOENCHOICE,X3_CAMPO)
        endif
        dbskip()
    enddo

    //Monta o aHeader do grid conforme os campos definidos no array aSC6 (apenas os campos que deseja)
    //Caso contrário, se quiser todos os campos é necessário trocar o "For" por While, para que este faça a leitura de toda a tabela
    DbSelectArea("SX3")
    SX3->(DbSetOrder(2))
    aHeader:={}
    For nX := 1 to Len(aSC6)
        If SX3->(DbSeek(aSC6[nX]))
            If X3USO(X3_USADO).And.cNivel>=X3_NIVEL
                nUsado:=nUsado+1
                Aadd(aHeader, {TRIM(X3_TITULO), X3_CAMPO , X3_PICTURE, X3_TAMANHO, X3_DECIMAL,X3_VALID, X3_USADO  , X3_TIPO   , X3_ARQUIVO, X3_CONTEXT})
            Endif
        Endif
    Next nX
Return


/*/{Protheus.doc} DefineaCols
//TODO Insere o conteudo no aCols do grid.
@author juliana.leme
@since 14/07/2017
@version undefined
@param nOpc, numeric, descricao
@type function
/*/
Static function DefineaCols(nOpc)
    Local nQtdcpo 	:= 0
    Local i			:= 0
    Local nCols 	:= 0
    nQtdcpo 		:= len(aHeader)
    aCols			:= {}

    dbselectarea(cAlias2)
    dbsetorder(1)
    dbseek(xfilial(cAlias2)+(cAlias1)->C5_NUM)
    while .not. eof() .and. (cAlias2)->C6_FILIAL == xfilial(cAlias2) .and. (cAlias2)->C6_NUM==(cAlias1)->C5_NUM
        aAdd(aCols,array(nQtdcpo+1))
        nCols++
        for i:= 1 to nQtdcpo
            if aHeader[i,10] <> "V"
                aCols[nCols,i] := Fieldget(Fieldpos(aHeader[i,2]))
            else
                aCols[nCols,i] := Criavar(aHeader[i,2],.T.)
            endif
        next i
        aCols[nCols,nQtdcpo+1] := .F.
        dbselectarea(cAlias2)
        dbskip()
    enddo
Return


/*/{Protheus.doc} Gravar
//TODO Gravar o conteudo dos campos.
@author juliana.leme
@since 14/07/2017
@version undefined

@type function
/*/
Static Function Gravar()
    Local bcampo 	:= { |nfield| field(nfield) }
    Local i			:= 0
    Local y			:= 0
    Local nitem 	:= 0
    Local nItem 	:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_ITEM"})
    Local nProduto 	:= aScan(aHeader,{|x| AllTrim(Upper(x[2]))=="C6_PRODUTO"})
    Local nPosCpo
    Local nCpo
    Local nI
    Local cCamposSC5	:= "C5_ZZBLVEN"
    Local cCamposSC6	:= "C6_ITEMPC" //colocar campos SC6

    Begin Transaction

        //Gravando dados da enchoice
        dbselectarea(cAlias1)
        Reclock(cAlias1,.F.)
        for i:= 1 to fcount()
            incproc()
            if "FILIAL" $ FIELDNAME(i)
                Fieldput(i,xfilial(cAlias1))
            else
                //Grava apenas os campos contidos na variavel cCamposSC5
                If ( FieldName(i) $ cCamposSC5 )
                    Fieldput(i,M->&(EVAL(bcampo,i)))
                Endif
            endif
        next i
        Msunlock()

        //Gravando dados do grid
        dbSelectArea("SC6")
        SC6->(dbSetOrder(1))
        For nI := 1 To Len(aCols)
            If !(aCols[nI, Len(aHeader)+1])
                If SC6->(dbSeek( xFilial("SC6")+M->C5_NUM+aCols[nI,nItem]+aCols[nI,nProduto] ))
                    RecLock("SC6",.F.)
                    For nCpo := 1 to fCount()
                        //Grava apenas os campos contidos na variavel $cCamposSC6
                        If (FieldName(nCpo)$cCamposSC6)
                            nPosCpo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim(FieldName(nCpo))})
                            If nPosCpo > 0
                                FieldPut(nCpo,aCols[nI,nPosCpo])
                            EndIf
                        Endif
                    Next nCpo
                    SC6->(MsUnLock())
                Endif
            Endif
        Next nI
    End Transaction
Return