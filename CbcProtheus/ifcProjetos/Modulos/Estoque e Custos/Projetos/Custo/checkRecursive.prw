#include "totvs.ch"

user Function checkRecursive(cDtIni, cDtFim, cOP, cCompo, cTM) //U_checkRecursive(,,'03772301001','2010000000','504') U_checkRecursive('20210601','20210630')
    local cAliasSD3 := GetNextAlias()
    local cArqTemp	:= "" 
    local cOpVazia	:= Criavar("D3_OP",.F.)
    local cProdMNT  := SuperGetMv("MV_PRODMNT",.F.,"MANUTENCAO")
    local aArqTemp	:= {}
    local nx		:= 0
    local nRegSD3	:= 0
    local nTotReg	:= 0
    local nCount	:= 0
    local aListaReg	:= {}
    local lRet		:= .T.
    local oTempTable:= NIL
    local aRecursive:= {}
    local cGroupQry := ""
    local cOrderQry := ""
    local cQuery    := ""
    default cOP     := ""
    default cCompo  := ""
    default cTM     := ""
    default cDtIni  := "20210101"
    default cDtFim  := DtoS(dDataBase)

    cOrderQry := " ORDER BY D3_OP,D3_COD,D3_EMISSAO "
    cGroupQry := " GROUP BY D3_OP, C2_PRODUTO, D3_COD, D3_TM, D3_LOCAL, D3_EMISSAO "+CRLF
    cQuery := " SELECT DISTINCT D3_OP, C2_PRODUTO, D3_COD, D3_TM, D3_LOCAL, D3_EMISSAO,  MIN( D3_DOC ) DOC, MIN( SD3.R_E_C_N_O_ ) REG,  '01' G1NIVEL, '99' G1NIVINV "+CRLF
    cQuery += " FROM "+ RetSQLName( 'SD3' ) +" SD3 WITH(NOLOCK)"+CRLF
    cQuery += " 	INNER JOIN "+ RetSQLName( 'SC2' ) +" SC2  WITH(NOLOCK) ON D3_FILIAL = C2_FILIAL AND D3_OP = (C2_NUM + C2_ITEM + C2_SEQUEN ) AND SD3.D_E_L_E_T_ = SC2.D_E_L_E_T_ "+CRLF
    cQuery += " WHERE D3_FILIAL = '" + xFilial("SD3") + "' "
    cQuery += " AND D3_EMISSAO BETWEEN '"+ cDtIni +"' AND '"+ cDtFim +"' "+CRLF
    if cOP <> ''
        cQuery += " 		AND D3_OP = '"+ cOP +"'  "+CRLF
    else
        cQuery += " 		AND D3_OP <> '"+ cOpVazia +"'  "+CRLF
    endif
    cQuery += " 		AND D3_COD <> '"+ cProdMNT +"' "+CRLF
    cQuery += " 		AND D3_CF NOT IN ( 'PR0' , 'PR1' ) "+CRLF
    cQuery += " 		AND D3_ESTORNO <> 'S' "+CRLF
    cQuery += " 		AND SD3.D3_ESTORNO <> 'S' "+CRLF
    cQuery += " 		AND SD3.D_E_L_E_T_ = ' ' "+CRLF
    //cQuery := ChangeQuery( cQuery )

    if !empty(cCompo) .and. !empty(cOP) .and. !empty(cTM)
        cQry := " SELECT COUNT( 1 ) TOTREG FROM ( "+ cQuery + " AND D3_COD = '" + cCompo + "' AND D3_TM ='" + cTM + "' " + cGroupQry +" ) TRB3 "
        IIf( Select( 'WRK' ) > 0, WRK->( dbCloseArea() ), Nil )
        dbUseArea( .T., __cRdd, TcGenQry(,,cQry ), 'WRK', .T., .F. )
        if WRK->TOTREG > 0
            lRet := .F.
        endif
    endif

    if lRet
        // Montagem do arquivo de trabalho
        Aadd(aArqTemp,{"CODIGO"		, TamSx3( 'B1_COD' )[ 03 ]		, TamSx3( 'B1_COD' )[ 01 ]		, TamSx3( 'B1_COD' )[ 02 ] } )
        Aadd(aArqTemp,{"COMPONENTE"	, TamSx3( 'B1_COD' )[ 03 ]		, TamSx3( 'B1_COD' )[ 01 ]		, TamSx3( 'B1_COD' )[ 02 ] } )
        Aadd(aArqTemp,{"OP"			, TamSx3( 'D3_OP' )[ 03 ]		, TamSx3( 'D3_OP' )[ 01 ] 		, TamSx3( 'D3_OP' )[ 02 ] } )
        Aadd(aArqTemp,{"ARMAZEM"	, TamSx3( 'D3_LOCAL' )[ 03 ]	, TamSx3( 'D3_LOCAL' )[ 01 ]	, TamSx3( 'D3_LOCAL' )[ 02 ] } )
        Aadd(aArqTemp,{"MOVIMENTO"	, TamSx3( 'D3_TM' )[ 03 ]		, TamSx3( 'D3_TM' )[ 01 ]		, TamSx3( 'D3_TM' )[ 02 ] } )
        Aadd(aArqTemp,{"EMISSAO"	, TamSx3( 'D3_EMISSAO' )[ 03 ]	, TamSx3( 'D3_EMISSAO' )[ 01 ]	, TamSx3( 'D3_EMISSAO' )[ 02 ] } )
        Aadd(aArqTemp,{"DOCUMENTO"	, TamSx3( 'D3_DOC' )[ 03 ]		, TamSx3( 'D3_DOC' )[ 01 ]		, TamSx3( 'D3_DOC' )[ 02 ] } )
        Aadd(aArqTemp,{"REGISTRO"	, "N", 20, 00 } )
        Aadd(aArqTemp,{"G1NIVEL"	, "C", 02, 00 } )
        Aadd(aArqTemp,{"G1NIVINV"	, "C", 02, 00 } )

        cArqTemp := GetNextAlias()
        oTempTable := FWTemporaryTable():New( cArqTemp )
        oTempTable:SetFields( aArqTemp )
        oTempTable:AddIndex("indice1", {"CODIGO","COMPONENTE","OP"} )
        oTempTable:Create()
        cNameTemp := oTempTable:GetRealName()

        // Leitura para gravacao de dados no arquivo de trabalho
        dbSelectArea("SC2")
        dbSetOrder(1)

        cQry := " INSERT INTO "+ cNameTemp +" ( OP, CODIGO, COMPONENTE, MOVIMENTO, ARMAZEM, EMISSAO, DOCUMENTO, REGISTRO, G1NIVEL, G1NIVINV ) "+ cQuery + cGroupQry + cOrderQry + " "
        nRet := TcSQLExec( cQry )
        If nRet # 0
            TcSQLExec( 'ROLLBACK' )
            //ApMsgStop( TcSQLError(), 'Atencao' )
            lRet := .F.
        Else
            TcSQLExec( 'COMMIT' )
            lRet := .T.
        EndIf
        if lRet
            TcRefresh( cNameTemp )
            cQry := " SELECT COUNT( 1 ) TOTREG FROM ( "+ cQuery + cGroupQry +" ) TRB3 "
            IIf( Select( 'WRK' ) > 0, WRK->( dbCloseArea() ), Nil )
            dbUseArea( .T., __cRdd, TcGenQry(,,cQry ), 'WRK', .T., .F. )
            if (nTotReg := WRK->TOTREG) > 0
                if !empty(cCompo) .and. !empty(cOP) .and. !empty(cTM)
                    if (lRet := (SC2->(DbSeek(xFilial("SC2")+Alltrim(cOP)))))
                        cQry := " INSERT INTO "+ cNameTemp +" ( OP, CODIGO, COMPONENTE, MOVIMENTO, ARMAZEM, EMISSAO, DOCUMENTO, REGISTRO, G1NIVEL, G1NIVINV )"
                        cQry += " VALUES ('" + Padr(cOP,TamSX3("D3_OP")[01]) + "','" + SC2->C2_PRODUTO + "','" + Padr(cCompo,TamSX3("D3_COD")[01]) +  "','" + cTM + "','" + SC2->C2_LOCAL + "','" + DtoS(dDataBase)+ "','CHECK_REC',0, '01', '99')"
                        nRet := TcSQLExec( cQry )
                        If nRet # 0
                            TcSQLExec( 'ROLLBACK' )
                            //ApMsgStop( TcSQLError(), 'Atencao' )
                            lRet := .F.
                        Else
                            TcSQLExec( 'COMMIT' )
                            lRet := .T.
                        EndIf
                    endif
                endif
            endif
            if lRet
                dbSelectArea( cArqTemp )
                ( cArqTemp )->( dbGotop() )
                nCount := 0
                While (cArqTemp)->( !Eof() )
                    nCount ++
                    // Checa recursividade
                    IF G1NIVEL == "01"
                        aListaReg:={}
                        lRet := MR331Nivel( ( cArqTemp )->COMPONENTE, ( cArqTemp )->G1NIVEL, cArqTemp, aListaReg )
                        IF !lRet
                            nRegSD3 := ( cArqTemp )->( Recno() )
                            For nX := 1 To Len( aListaReg )
                                // Posiciona o registro
                                ( cArqTemp )->( dbGoto( aListaReg[ nX ] ) )	
                                if empty(cCompo) .or. empty(cOP) .or. empty(cTM)		
                                    aAdd(aRecursive, {( cArqTemp )->COMPONENTE,; 
                                                    ( cArqTemp )->ARMAZEM,; 
                                                    ( cArqTemp )->MOVIMENTO,;
                                                    ( cArqTemp )->DOCUMENTO,;
                                                    ( cArqTemp )->EMISSAO,;
                                                    ( cArqTemp )->OP,;
                                                    ( cArqTemp )->CODIGO})
                                else
                                    if ( cArqTemp )->DOCUMENTO == 'CHECK_REC'
                                        aAdd(aRecursive, {( cArqTemp )->COMPONENTE,; 
                                                    ( cArqTemp )->ARMAZEM,; 
                                                    ( cArqTemp )->MOVIMENTO,;
                                                    ( cArqTemp )->DOCUMENTO,;
                                                    ( cArqTemp )->EMISSAO,;
                                                    ( cArqTemp )->OP,;
                                                    ( cArqTemp )->CODIGO})
                                    endif
                                endif
                            Next nX
                            ( cArqTemp )->( dbGoto( nRegSD3 ) )
                        Endif
                    EndIf

                    ( cArqTemp )->( dbSkip() )
                EndDo
            endif
        endif
        oTempTable:Delete()
    endif

    IIf( Select( cAliasSD3 ) > 0, ( cAliasSD3 )->( dbCloseArea() ), Nil )
    IIf( Select( 'WRK' ) > 0, WRK->( dbCloseArea() ), Nil )
return(aRecursive)

static function MR331Nivel(cComp,cNivel,cAliasPr,aListaReg)
    local nRec   := Recno()
    local nSalRec:= 0
    local lRet   := .T.
    local lEof   := .F.
    local nAcho  := 0
    local cSeek  := ""

    dbSelectArea( cAliasPr )
    dbSetOrder( 1 )

    if dbSeek(cComp)
        while !Eof() .and. cComp==CODIGO
            nSalRec:=Recno()
            cSeek  := COMPONENTE
            dbSeek(cSeek)	
            lEof := Eof()
            dbGoto(nSalRec)

            if Val(cNivel) >= 98  // Testa Erro de estrutura
                lRet := .F.
            endif

            if Val(cNivel)+1 > Val(G1NIVEL) .and. lRet
                RecLock(cAliasPr,.F.)
                Replace G1NIVEL  With Strzero(Val(cNivel)+1,2)
                Replace G1NIVINV With Strzero(100-Val(G1NIVEL),2,0)
                MsUnLock()
                if !lEof
                    lRet := MR331NIVEL(COMPONENTE,G1NIVEL,cAliasPr,aListaReg)
                endif
            endif	
            if !lRet
                if Val(cNivel) < 98  // Houve erro (no nivel posterior)
                    nAcho  := ASCAN(aListaReg,nSalRec)
                    // Adiciona, na lista, o registro que originou o erro
                    if nAcho == 0
                        AADD(aListaReg,nSalRec)
                    endif
                endif		
                EXIT
            endif
            dbSkip()
        end
    endif
    (cAliasPr)->(dbGoto(nRec))
return(lRet)
