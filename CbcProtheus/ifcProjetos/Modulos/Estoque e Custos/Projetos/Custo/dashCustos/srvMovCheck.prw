#include 'Totvs.ch'

static function mountTable(cOpc, cDtIni, cDtFim, cProcFun)
    local aFlds     := getFields('T', cOpc)
    local aIdx      := getFields('I', cOpc)
    local cQry      := getQry(cOpc, cDtIni, cDtFim)
    local nX        := 0
    local nY        := 0
    local aTemp     := {}

    SetPrvt("oTmp" + cOpc)
    &("oTmp" + cOpc)  := FWTemporaryTable():New(nextAlias())
    &("oTmp" + cOpc):SetFields(aFlds)
    if empty(aIdx)
        aIdx := {aFlds[1,1]}
    endif
    &("oTmp" + cOpc):AddIndex('Idx',  aIdx)
    &("oTmp" + cOpc):Create()
    cMyAls := &("oTmp" + cOpc):GetAlias()
    
    if cOpc == 'REC'
        aTemp := u_checkRecursive(cDtIni, cDtFim)
        for nX := 1 to Len(aTemp)
            (cMyAls)->(RecLock((cMyAls), .T.))
            for nY := 1 to Len(aFlds)
                (cMyAls)->(&(aFlds[nY, 01])) := aTemp[nX,nY]
            next nY
            (cMyAls)->(MsUnLock())
        next nX
    else
        //Carregar a Temp
        SQLToTrb(cQry, aFlds, (cMyAls))
    endif
    _SetNamedPrvt( "oTmp" + cOpc, &("oTmp" + cOpc) , cProcFun/*"simulate"*/ )
return("oTmp" + cOpc)

static function nextAlias()
    local cAls := ''
    while .T.
        cAls := GetNextAlias()
        if (Select(cAls) <= 0)
            exit
        endIf
    endDo
return(cAls)

static function getFields(cTipo, cOpc, cFldAls)
    local aRet      := {}
    default cFldAls := ''

    if cTipo == 'B'
        if  cOpc == "PR0" .OR. cOpc == "PR0IND" .OR.; 
            cOpc == "RE0" .OR. cOpc == "RE0IND" .OR.;
            cOpc == "ANTOP" .OR. cOpc == "POSOP"
            
            aAdd(aRet, {'PRODUTO',      {|| (cFldAls)->(PRODUTO)},   GetSx3Cache('B1_COD', 'X3_TIPO'),       PesqPict('SB1', 'B1_COD'),     1,TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',  'X3_DECIMAL')})
            aAdd(aRet, {'QTD',          {|| (cFldAls)->(QTD)},       GetSx3Cache('D3_QUANT', 'X3_TIPO'),     PesqPict('SD3', 'D3_QUANT'),   1,TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'ARMZ',         {|| (cFldAls)->(ARMZ)},      GetSx3Cache('D3_LOCAL', 'X3_TIPO'),     PesqPict('SD3', 'D3_LOCAL'),   1,TamSx3('D3_LOCAL')[1],   GetSx3Cache('D3_LOCAL','X3_DECIMAL')})
            aAdd(aRet, {'EMISSAO',      {|| (cFldAls)->(EMISSAO)},   GetSx3Cache('D3_EMISSAO', 'X3_TIPO'),   PesqPict('SD3', 'D3_EMISSAO'), 1,TamSx3('D3_EMISSAO')[1], GetSx3Cache('D3_EMISSAO','X3_DECIMAL')})
            aAdd(aRet, {'OP',           {|| (cFldAls)->(OP)},        GetSx3Cache('D3_OP', 'X3_TIPO'),        PesqPict('SD3', 'D3_OP'),      1,TamSx3('D3_OP')[1],      GetSx3Cache('D3_OP','X3_DECIMAL')})        
            aAdd(aRet, {'EMISSAO_OP',   {|| (cFldAls)->(EMISSAO_OP)},GetSx3Cache('C2_EMISSAO', 'X3_TIPO'),   PesqPict('SC2', 'C2_EMISSAO'), 1,TamSx3('C2_EMISSAO')[1], GetSx3Cache('C2_EMISSAO','X3_DECIMAL')})
            aAdd(aRet, {'ENCERRA_OP',   {|| (cFldAls)->(ENCERRA_OP)},GetSx3Cache('C2_DATRF', 'X3_TIPO'),     PesqPict('SC2', 'C2_DATRF'),   1,TamSx3('C2_DATRF')[1],   GetSx3Cache('C2_DATRF','X3_DECIMAL')})
            aAdd(aRet, {'HIST',         {|| (cFldAls)->(HIST)},      GetSx3Cache('D3_HIST', 'X3_TIPO'),      PesqPict('SD3', 'D3_HIST'),    1,TamSx3('D3_HIST')[1],    GetSx3Cache('D3_HIST','X3_DECIMAL')})
            aAdd(aRet, {'USUARIO',      {|| (cFldAls)->(USUARIO)},   GetSx3Cache('D3_USUARIO', 'X3_TIPO'),   PesqPict('SD3', 'D3_USUARIO'), 1,TamSx3('D3_USUARIO')[1], GetSx3Cache('D3_USUARIO','X3_DECIMAL')})
            aAdd(aRet, {'COBRE',        {|| (cFldAls)->(COBRE)},     GetSx3Cache('D3_QUANT', 'X3_TIPO'),     PesqPict('SD3', 'D3_QUANT'),   1,TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'PVC',          {|| (cFldAls)->(PVC)},       GetSx3Cache('D3_QUANT', 'X3_TIPO'),     PesqPict('SD3', 'D3_QUANT'),   1,TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'TPMOV',        {|| (cFldAls)->(TPMOV)},     GetSx3Cache('D3_CF', 'X3_TIPO'),        PesqPict('SD3', 'D3_CF'),      1,TamSx3('D3_CF')[1],      GetSx3Cache('D3_CF','X3_DECIMAL')})
            aAdd(aRet, {'DOC',          {|| (cFldAls)->(DOC)},       GetSx3Cache('D1_DOC', 'X3_TIPO'),       PesqPict('SD1', 'D1_DOC'),     1,TamSx3('D1_DOC')[1],     GetSx3Cache('D1_DOC','X3_DECIMAL')})
        elseif cOpc == "DEV"
            aAdd(aRet, {'PRODUTO',      {|| (cFldAls)->(PRODUTO)},   GetSx3Cache('B1_COD', 'X3_TIPO'),       PesqPict('SB1', 'B1_COD'),     1,TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',  'X3_DECIMAL')})
            aAdd(aRet, {'QTD_DEV',      {|| (cFldAls)->(QTD_DEV)},   GetSx3Cache('D3_QUANT', 'X3_TIPO'),     PesqPict('SD3', 'D3_QUANT'),   1,TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'QTD_REQ',      {|| (cFldAls)->(QTD_REQ)},   GetSx3Cache('D3_QUANT', 'X3_TIPO'),     PesqPict('SD3', 'D3_QUANT'),   1,TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'OP',           {|| (cFldAls)->(OP)},        GetSx3Cache('D3_OP', 'X3_TIPO'),        PesqPict('SD3', 'D3_OP'),      1,TamSx3('D3_OP')[1],      GetSx3Cache('D3_OP','X3_DECIMAL')})        
            aAdd(aRet, {'EMISSAO_OP',   {|| (cFldAls)->(EMISSAO_OP)},GetSx3Cache('C2_EMISSAO', 'X3_TIPO'),   PesqPict('SC2', 'C2_EMISSAO'), 1,TamSx3('C2_EMISSAO')[1], GetSx3Cache('C2_EMISSAO','X3_DECIMAL')})
            aAdd(aRet, {'ENCERRA_OP',   {|| (cFldAls)->(ENCERRA_OP)},GetSx3Cache('C2_DATRF', 'X3_TIPO'),     PesqPict('SC2', 'C2_DATRF'),   1,TamSx3('C2_DATRF')[1],   GetSx3Cache('C2_DATRF','X3_DECIMAL')})
        elseif cOpc == "POSPR0"
            aAdd(aRet, {'PRODUTO',      {|| (cFldAls)->(PRODUTO)},   GetSx3Cache('B1_COD', 'X3_TIPO'),       PesqPict('SB1', 'B1_COD'),     1,TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',  'X3_DECIMAL')})
            aAdd(aRet, {'QTD',          {|| (cFldAls)->(QTD)},       GetSx3Cache('D3_QUANT', 'X3_TIPO'),     PesqPict('SD3', 'D3_QUANT'),   1,TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'OP',           {|| (cFldAls)->(OP)},        GetSx3Cache('D3_OP', 'X3_TIPO'),        PesqPict('SD3', 'D3_OP'),      1,TamSx3('D3_OP')[1],      GetSx3Cache('D3_OP','X3_DECIMAL')})        
            aAdd(aRet, {'EMISSAO',      {|| (cFldAls)->(EMISSAO)},   GetSx3Cache('D3_EMISSAO', 'X3_TIPO'),   PesqPict('SD3', 'D3_EMISSAO'), 1,TamSx3('D3_EMISSAO')[1], GetSx3Cache('D3_EMISSAO','X3_DECIMAL')})
            aAdd(aRet, {'MAX_EMISS',    {|| (cFldAls)->(MAX_EMISS)}, GetSx3Cache('D3_EMISSAO', 'X3_TIPO'),  PesqPict('SD3', 'D3_EMISSAO'), 1,TamSx3('D3_EMISSAO')[1], GetSx3Cache('D3_EMISSAO','X3_DECIMAL')})
        elseif cOpc == "MOD"
            aAdd(aRet, {'PRODUTO',      {|| (cFldAls)->(PRODUTO)},   GetSx3Cache('B1_COD', 'X3_TIPO'),       PesqPict('SB1', 'B1_COD'),     1,TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',  'X3_DECIMAL')})
            aAdd(aRet, {'DOC',          {|| (cFldAls)->(DOC)},       GetSx3Cache('D3_DOC', 'X3_TIPO'),       PesqPict('SD3', 'D3_DOC'),     1,TamSx3('D3_DOC')[1],     GetSx3Cache('D3_DOC','X3_DECIMAL')})
            aAdd(aRet, {'QTD',          {|| (cFldAls)->(QTD)},       GetSx3Cache('D3_QUANT', 'X3_TIPO'),     PesqPict('SD3', 'D3_QUANT'),   1,TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'HIST',         {|| (cFldAls)->(HIST)},      GetSx3Cache('D3_HIST', 'X3_TIPO'),      PesqPict('SD3', 'D3_HIST'),    1,TamSx3('D3_HIST')[1],    GetSx3Cache('D3_HIST','X3_DECIMAL')})
            aAdd(aRet, {'OP',           {|| (cFldAls)->(OP)},        GetSx3Cache('D3_OP', 'X3_TIPO'),        PesqPict('SD3', 'D3_OP'),      1,TamSx3('D3_OP')[1],      GetSx3Cache('D3_OP','X3_DECIMAL')})        
            aAdd(aRet, {'EMISSAO',      {|| (cFldAls)->(EMISSAO)},   GetSx3Cache('D3_EMISSAO', 'X3_TIPO'),   PesqPict('SD3', 'D3_EMISSAO'), 1,TamSx3('D3_EMISSAO')[1], GetSx3Cache('D3_EMISSAO','X3_DECIMAL')})
            aAdd(aRet, {'LOTE',         {|| (cFldAls)->(LOTE)},      GetSx3Cache('D3_ZZLOTE', 'X3_TIPO'),    PesqPict('SD3', 'D3_ZZLOTE'),  1,TamSx3('D3_ZZLOTE')[1],  GetSx3Cache('D3_ZZLOTE','X3_DECIMAL')})
            aAdd(aRet, {'UNMOV',        {|| (cFldAls)->(UNMOV)},     GetSx3Cache('D3_ZZUNMOV', 'X3_TIPO'),   PesqPict('SD3', 'D3_ZZUNMOV'), 1,TamSx3('D3_ZZUNMOV')[1], GetSx3Cache('D3_ZZUNMOV','X3_DECIMAL')})
            aAdd(aRet, {'RECURSO',      {|| (cFldAls)->(RECURSO)},   GetSx3Cache('D3_HIST', 'X3_TIPO'),      PesqPict('SD3', 'D3_HIST'),    1,TamSx3('D3_HIST')[1],    GetSx3Cache('D3_HIST','X3_DECIMAL')})
            aAdd(aRet, {'SETOR',        {|| (cFldAls)->(SETOR)},     GetSx3Cache('D3_HIST', 'X3_TIPO'),      PesqPict('SD3', 'D3_HIST'),    1,TamSx3('D3_HIST')[1],    GetSx3Cache('D3_HIST','X3_DECIMAL')})
        elseif cOpc == "REC"
            aAdd(aRet,{"COMPONENTE"	,       {|| (cFldAls)->(COMPONENTE)},   TamSx3( 'B1_COD' )[ 03 ],       PesqPict('SB1', 'B1_COD'),      1,TamSx3( 'B1_COD' )[ 01 ]		, TamSx3( 'B1_COD' )[ 02 ] } )
            aAdd(aRet,{"ARMAZEM"	,       {|| (cFldAls)->(ARMAZEM)},      TamSx3( 'D3_LOCAL' )[ 03 ],     PesqPict('SD3', 'D3_LOCAL'),    1,TamSx3( 'D3_LOCAL' )[ 01 ]	, TamSx3( 'D3_LOCAL' )[ 02 ] } )
            aAdd(aRet,{"MOVIMENTO"	,       {|| (cFldAls)->(MOVIMENTO)},    TamSx3( 'D3_TM' )[ 03 ],        PesqPict('SD3', 'D3_TM'),       1,TamSx3( 'D3_TM' )[ 01 ]		, TamSx3( 'D3_TM' )[ 02 ] } )
            aAdd(aRet,{"DOCUMENTO"	,       {|| (cFldAls)->(DOCUMENTO)},    TamSx3( 'D3_DOC' )[ 03 ],       PesqPict('SD3', 'D3_DOC'),      1,TamSx3( 'D3_DOC' )[ 01 ]		, TamSx3( 'D3_DOC' )[ 02 ] } )
            aAdd(aRet,{"EMISSAO"	,       {|| (cFldAls)->(EMISSAO)},      TamSx3( 'D3_EMISSAO' )[ 03 ],   PesqPict('SD3', 'D3_EMISSAO'),  1,TamSx3( 'D3_EMISSAO' )[ 01 ]	, TamSx3( 'D3_EMISSAO' )[ 02 ] } )
            aAdd(aRet,{"OP"			,       {|| (cFldAls)->(OP)},           TamSx3( 'D3_OP' )[ 03 ],        PesqPict('SD3', 'D3_OP'),       1,TamSx3( 'D3_OP' )[ 01 ] 		, TamSx3( 'D3_OP' )[ 02 ] } )
            aAdd(aRet,{"CODIGO"		,       {|| (cFldAls)->(CODIGO)},       TamSx3( 'B1_COD' )[ 03 ],       PesqPict('SB1', 'B1_COD'),      1,TamSx3( 'B1_COD' )[ 01 ]		, TamSx3( 'B1_COD' )[ 02 ] } )
        elseif cOpc = "PAR"
            aAdd(aRet, {'PRODUTO',      {|| (cFldAls)->(PRODUTO)},  GetSx3Cache('B1_COD', 'X3_TIPO'),       PesqPict('SB1', 'B1_COD'),      1,TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',  'X3_DECIMAL')})
            aAdd(aRet, {'QTD',          {|| (cFldAls)->(QTD)},      GetSx3Cache('D3_QUANT', 'X3_TIPO'),     PesqPict('SD3', 'D3_QUANT'),    1,TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'ARMZ',         {|| (cFldAls)->(ARMZ)},     GetSx3Cache('D3_LOCAL', 'X3_TIPO'),     PesqPict('SD3', 'D3_LOCAL'),    1,TamSx3('D3_LOCAL')[1],   GetSx3Cache('D3_LOCAL','X3_DECIMAL')})
            aAdd(aRet, {'EMISSAO',      {|| (cFldAls)->(EMISSAO)},  GetSx3Cache('D3_EMISSAO', 'X3_TIPO'),   PesqPict('SD3', 'D3_EMISSAO'),  1,TamSx3('D3_EMISSAO')[1], GetSx3Cache('D3_EMISSAO','X3_DECIMAL')})
            aAdd(aRet, {'OP',           {|| (cFldAls)->(OP)},       GetSx3Cache('D3_OP', 'X3_TIPO'),        PesqPict('SD3', 'D3_OP'),       1,TamSx3('D3_OP')[1],      GetSx3Cache('D3_OP','X3_DECIMAL')})        
            aAdd(aRet, {'HIST',         {|| (cFldAls)->(HIST)},     GetSx3Cache('D3_HIST', 'X3_TIPO'),      PesqPict('SD3', 'D3_HIST'),     1,TamSx3('D3_HIST')[1],    GetSx3Cache('D3_HIST','X3_DECIMAL')})
            aAdd(aRet, {'USUARIO',      {|| (cFldAls)->(USUARIO)},  GetSx3Cache('D3_USUARIO', 'X3_TIPO'),   PesqPict('SD3', 'D3_USUARIO'),  1,TamSx3('D3_USUARIO')[1], GetSx3Cache('D3_USUARIO','X3_DECIMAL')})
            aAdd(aRet, {'COBRE',        {|| (cFldAls)->(COBRE)},    GetSx3Cache('D3_QUANT', 'X3_TIPO'),     PesqPict('SD3', 'D3_QUANT'),    1,TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'PVC',          {|| (cFldAls)->(PVC)},      GetSx3Cache('D3_QUANT', 'X3_TIPO'),     PesqPict('SD3', 'D3_QUANT'),    1,TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'TPMOV',        {|| (cFldAls)->(TPMOV)},    GetSx3Cache('D3_CF', 'X3_TIPO'),        PesqPict('SD3', 'D3_CF'),       1,TamSx3('D3_CF')[1],      GetSx3Cache('D3_CF','X3_DECIMAL')})
            aAdd(aRet, {'DOC',          {|| (cFldAls)->(DOC)},      GetSx3Cache('D1_DOC', 'X3_TIPO'),       PesqPict('SD1', 'D1_DOC'),      1,TamSx3('D1_DOC')[1],     GetSx3Cache('D1_DOC','X3_DECIMAL')})
            aAdd(aRet, {'SEQ',          {|| (cFldAls)->(SEQ)},      GetSx3Cache('D3_NUMSEQ', 'X3_TIPO'),    PesqPict('SD3', 'D3_NUMSEQ'),   1,TamSx3('D3_NUMSEQ')[1],  GetSx3Cache('D3_NUMSEQ','X3_DECIMAL')})
        endif
    elseif cTipo == 'T'
        if  cOpc == "PR0" .OR. cOpc == "PR0IND" .OR.; 
            cOpc == "RE0" .OR. cOpc == "RE0IND" .OR.;
            cOpc == "ANTOP" .OR. cOpc == "POSOP"

            aAdd(aRet, {'PRODUTO',      GetSx3Cache('B1_COD', 'X3_TIPO'),       TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',  'X3_DECIMAL')})
            aAdd(aRet, {'QTD',          GetSx3Cache('D3_QUANT', 'X3_TIPO'),     TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'ARMZ',         GetSx3Cache('D3_LOCAL', 'X3_TIPO'),     TamSx3('D3_LOCAL')[1],   GetSx3Cache('D3_LOCAL','X3_DECIMAL')})
            aAdd(aRet, {'EMISSAO',      GetSx3Cache('D3_EMISSAO', 'X3_TIPO'),   TamSx3('D3_EMISSAO')[1], GetSx3Cache('D3_EMISSAO','X3_DECIMAL')})
            aAdd(aRet, {'OP',           GetSx3Cache('D3_OP', 'X3_TIPO'),        TamSx3('D3_OP')[1],      GetSx3Cache('D3_OP','X3_DECIMAL')})        
            aAdd(aRet, {'EMISSAO_OP',   GetSx3Cache('C2_EMISSAO', 'X3_TIPO'),   TamSx3('C2_EMISSAO')[1], GetSx3Cache('C2_EMISSAO','X3_DECIMAL')})
            aAdd(aRet, {'ENCERRA_OP',   GetSx3Cache('C2_DATRF', 'X3_TIPO'),     TamSx3('C2_DATRF')[1],   GetSx3Cache('C2_DATRF','X3_DECIMAL')})
            aAdd(aRet, {'HIST',         GetSx3Cache('D3_HIST', 'X3_TIPO'),      TamSx3('D3_HIST')[1],    GetSx3Cache('D3_HIST','X3_DECIMAL')})
            aAdd(aRet, {'USUARIO',      GetSx3Cache('D3_USUARIO', 'X3_TIPO'),   TamSx3('D3_USUARIO')[1], GetSx3Cache('D3_USUARIO','X3_DECIMAL')})
            aAdd(aRet, {'COBRE',        GetSx3Cache('D3_QUANT', 'X3_TIPO'),     TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'PVC',          GetSx3Cache('D3_QUANT', 'X3_TIPO'),     TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'TPMOV',        GetSx3Cache('D3_CF', 'X3_TIPO'),        TamSx3('D3_CF')[1],      GetSx3Cache('D3_CF','X3_DECIMAL')})
            aAdd(aRet, {'DOC',          GetSx3Cache('D1_DOC', 'X3_TIPO'),       TamSx3('D1_DOC')[1],     GetSx3Cache('D1_DOC','X3_DECIMAL')})
            aAdd(aRet, {'REC', 'N',                                    11,                        0})
        elseif cOpc == "DEV"
            aAdd(aRet, {'PRODUTO',      GetSx3Cache('B1_COD', 'X3_TIPO'),       TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',  'X3_DECIMAL')})
            aAdd(aRet, {'QTD_DEV',      GetSx3Cache('D3_QUANT', 'X3_TIPO'),     TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'QTD_REQ',      GetSx3Cache('D3_QUANT', 'X3_TIPO'),     TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'OP',           GetSx3Cache('D3_OP', 'X3_TIPO'),        TamSx3('D3_OP')[1],      GetSx3Cache('D3_OP','X3_DECIMAL')})        
            aAdd(aRet, {'EMISSAO_OP',   GetSx3Cache('C2_EMISSAO', 'X3_TIPO'),   TamSx3('C2_EMISSAO')[1], GetSx3Cache('C2_EMISSAO','X3_DECIMAL')})
            aAdd(aRet, {'ENCERRA_OP',   GetSx3Cache('C2_DATRF', 'X3_TIPO'),     TamSx3('C2_DATRF')[1],   GetSx3Cache('C2_DATRF','X3_DECIMAL')})
        elseif cOpc == "POSPR0"
            aAdd(aRet, {'PRODUTO',      GetSx3Cache('B1_COD', 'X3_TIPO'),       TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',  'X3_DECIMAL')})
            aAdd(aRet, {'QTD',          GetSx3Cache('D3_QUANT', 'X3_TIPO'),     TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'OP',           GetSx3Cache('D3_OP', 'X3_TIPO'),        TamSx3('D3_OP')[1],      GetSx3Cache('D3_OP','X3_DECIMAL')})        
            aAdd(aRet, {'EMISSAO',      GetSx3Cache('D3_EMISSAO', 'X3_TIPO'),   TamSx3('D3_EMISSAO')[1], GetSx3Cache('D3_EMISSAO','X3_DECIMAL')})
            aAdd(aRet, {'MAX_EMISS',    GetSx3Cache('D3_EMISSAO', 'X3_TIPO'),   TamSx3('D3_EMISSAO')[1], GetSx3Cache('D3_EMISSAO','X3_DECIMAL')})
        elseif cOpc == "MOD"
            aAdd(aRet, {'PRODUTO',      GetSx3Cache('B1_COD', 'X3_TIPO'),       TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',  'X3_DECIMAL')})
            aAdd(aRet, {'DOC',          GetSx3Cache('D3_DOC', 'X3_TIPO'),       TamSx3('D3_DOC')[1],     GetSx3Cache('D3_DOC','X3_DECIMAL')})
            aAdd(aRet, {'QTD',          GetSx3Cache('D3_QUANT', 'X3_TIPO'),     TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'HIST',         GetSx3Cache('D3_HIST', 'X3_TIPO'),      TamSx3('D3_HIST')[1],    GetSx3Cache('D3_HIST','X3_DECIMAL')})
            aAdd(aRet, {'OP',           GetSx3Cache('D3_OP', 'X3_TIPO'),        TamSx3('D3_OP')[1],      GetSx3Cache('D3_OP','X3_DECIMAL')})        
            aAdd(aRet, {'EMISSAO',      GetSx3Cache('D3_EMISSAO', 'X3_TIPO'),   TamSx3('D3_EMISSAO')[1], GetSx3Cache('D3_EMISSAO','X3_DECIMAL')})
            aAdd(aRet, {'LOTE',         GetSx3Cache('D3_ZZLOTE', 'X3_TIPO'),    TamSx3('D3_ZZLOTE')[1],  GetSx3Cache('D3_ZZLOTE','X3_DECIMAL')})
            aAdd(aRet, {'UNMOV',        GetSx3Cache('D3_ZZUNMOV', 'X3_TIPO'),   TamSx3('D3_ZZUNMOV')[1], GetSx3Cache('D3_ZZUNMOV','X3_DECIMAL')})
            aAdd(aRet, {'RECURSO',      GetSx3Cache('D3_HIST', 'X3_TIPO'),      TamSx3('D3_HIST')[1],    GetSx3Cache('D3_HIST','X3_DECIMAL')})
            aAdd(aRet, {'SETOR',        GetSx3Cache('D3_HIST', 'X3_TIPO'),      TamSx3('D3_HIST')[1],    GetSx3Cache('D3_HIST','X3_DECIMAL')})
        elseif cOpc == "REC"
            aAdd(aRet,{"COMPONENTE"	, TamSx3( 'B1_COD' )[ 03 ]		, TamSx3( 'B1_COD' )[ 01 ]		, TamSx3( 'B1_COD' )[ 02 ] } )
            aAdd(aRet,{"ARMAZEM"	, TamSx3( 'D3_LOCAL' )[ 03 ]	, TamSx3( 'D3_LOCAL' )[ 01 ]	, TamSx3( 'D3_LOCAL' )[ 02 ] } )
            aAdd(aRet,{"MOVIMENTO"	, TamSx3( 'D3_TM' )[ 03 ]		, TamSx3( 'D3_TM' )[ 01 ]		, TamSx3( 'D3_TM' )[ 02 ] } )
            aAdd(aRet,{"DOCUMENTO"	, TamSx3( 'D3_DOC' )[ 03 ]		, TamSx3( 'D3_DOC' )[ 01 ]		, TamSx3( 'D3_DOC' )[ 02 ] } )
            aAdd(aRet,{"EMISSAO"	, TamSx3( 'D3_EMISSAO' )[ 03 ]	, TamSx3( 'D3_EMISSAO' )[ 01 ]	, TamSx3( 'D3_EMISSAO' )[ 02 ] } )
            aAdd(aRet,{"OP"			, TamSx3( 'D3_OP' )[ 03 ]		, TamSx3( 'D3_OP' )[ 01 ] 		, TamSx3( 'D3_OP' )[ 02 ] } )
            aAdd(aRet,{"CODIGO"		, TamSx3( 'B1_COD' )[ 03 ]		, TamSx3( 'B1_COD' )[ 01 ]		, TamSx3( 'B1_COD' )[ 02 ] } )
        elseif cOpc = "PAR"
            aAdd(aRet, {'PRODUTO',      GetSx3Cache('B1_COD', 'X3_TIPO'),       TamSx3('B1_COD')[1],     GetSx3Cache('B1_COD',  'X3_DECIMAL')})
            aAdd(aRet, {'QTD',          GetSx3Cache('D3_QUANT', 'X3_TIPO'),     TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'ARMZ',         GetSx3Cache('D3_LOCAL', 'X3_TIPO'),     TamSx3('D3_LOCAL')[1],   GetSx3Cache('D3_LOCAL','X3_DECIMAL')})
            aAdd(aRet, {'EMISSAO',      GetSx3Cache('D3_EMISSAO', 'X3_TIPO'),   TamSx3('D3_EMISSAO')[1], GetSx3Cache('D3_EMISSAO','X3_DECIMAL')})
            aAdd(aRet, {'OP',           GetSx3Cache('D3_OP', 'X3_TIPO'),        TamSx3('D3_OP')[1],      GetSx3Cache('D3_OP','X3_DECIMAL')})        
            aAdd(aRet, {'HIST',         GetSx3Cache('D3_HIST', 'X3_TIPO'),      TamSx3('D3_HIST')[1],    GetSx3Cache('D3_HIST','X3_DECIMAL')})
            aAdd(aRet, {'USUARIO',      GetSx3Cache('D3_USUARIO', 'X3_TIPO'),   TamSx3('D3_USUARIO')[1], GetSx3Cache('D3_USUARIO','X3_DECIMAL')})
            aAdd(aRet, {'COBRE',        GetSx3Cache('D3_QUANT', 'X3_TIPO'),     TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'PVC',          GetSx3Cache('D3_QUANT', 'X3_TIPO'),     TamSx3('D3_QUANT')[1],   GetSx3Cache('D3_QUANT','X3_DECIMAL')})
            aAdd(aRet, {'TPMOV',        GetSx3Cache('D3_CF', 'X3_TIPO'),        TamSx3('D3_CF')[1],      GetSx3Cache('D3_CF','X3_DECIMAL')})
            aAdd(aRet, {'DOC',          GetSx3Cache('D1_DOC', 'X3_TIPO'),       TamSx3('D1_DOC')[1],     GetSx3Cache('D1_DOC','X3_DECIMAL')})
            aAdd(aRet, {'SEQ',          GetSx3Cache('D3_NUMSEQ', 'X3_TIPO'),    TamSx3('D3_NUMSEQ')[1],  GetSx3Cache('D3_NUMSEQ','X3_DECIMAL')})
            aAdd(aRet, {'REC', 'N',                                    11,                        0})
        endif
    endif
return(aRet)

static function getQry(cOpc, cDtIni, cDtFim)
    local cQry      := ""
    Local oStatic   := IfcXFun():newIfcXFun()

    if cOpc == "PR0"
        cQry := oStatic:sP(4):callStatic('qryMovCheck', 'qryMovs', "PR", cDtIni, cDtFim, .F.)
    elseif cOpc == "RE0"
        cQry := oStatic:sP(4):callStatic('qryMovCheck', 'qryMovs', "RE", cDtIni, cDtFim, .F.)
    elseif cOpc == "PR0IND"
        cQry := oStatic:sP(4):callStatic('qryMovCheck', 'qryMovs', "PR", cDtIni, cDtFim, .T.)
    elseif cOpc == "RE0IND"
        cQry := oStatic:sP(4):callStatic('qryMovCheck', 'qryMovs', "RE", cDtIni, cDtFim, .T.)
    elseif cOpc == "DEV"
        cQry := oStatic:sP(2):callStatic('qryMovCheck', 'qryDevs', cDtIni, cDtFim)
    elseif cOpc == "POSPR0"
        cQry := oStatic:sP(2):callStatic('qryMovCheck', 'qryMovPosProd', cDtIni, cDtFim)
    elseif cOpc == "ANTOP"
        cQry := oStatic:sP(3):callStatic('qryMovCheck', 'qryMovPosOP', "INI", cDtIni, cDtFim)
    elseif cOpc == "POSOP"
        cQry := oStatic:sP(3):callStatic('qryMovCheck', 'qryMovPosOP', "FIM", cDtIni, cDtFim)
    elseif cOpc == "MOD"
        cQry := oStatic:sP(2):callStatic('qryMovCheck', 'qryMOD', cDtIni, cDtFim)
    elseif cOpc == "PAR"
        cQry := oStatic:sP(2):callStatic('qryMovCheck', 'qryPAR', cDtIni, cDtFim)
    endif
return(cQry)

static function srvCMLoad(cDtIni, cDtFim)
    /*
    local aSetProd as array

    aSetProd := {}
    aadd(aSetProd, {'113060000','ME'})
    aadd(aSetProd, {'113040000','MP'})
    aadd(aSetProd, {'113100000','OI'})
    aadd(aSetProd, {'113010000','PA'})
    aadd(aSetProd, {'113050000','PI'})
    aadd(aSetProd, {'113090000','SC'})
    aadd(aSetProd, {'113080000','SV'})
    */
    oCtrlCM:setPeriodo({cDtIni,cDtFim})
    //oCtrlCM:setupContaTipo(aSetProd)
    oCtrlCM:loadData()
return(nil)

static function initVw(cHtml)
	local oModalBrw 	:= nil
	local oFwBrw		:= nil
	local oFwBrwL		:= nil
	local oFwBrwR		:= nil
	local lCloseButt 	:= !(oAPP:lMdi)
	local oWebEngine 	:= nil
	local oBtnClose		:= nil
	local oBtnPrint		:= nil
	private oWebChannel := TWebChannel():New()
	private nPort 		:= oWebChannel:connect()
	
	oModalBrw	:= FWDialogModal():New() 
	//Seta a largura e altura da janela em pixel
	oModalBrw:setSize(350,600)
	oModalBrw:SetEscClose(.F.)
	oModalBrw:setTitle('Visualizar Detalhes')
	oModalBrw:createDialog()
	
	oFwBrw := FWLayer():New()
	oFwBrw:Init(oModalBrw:getPanelMain(), lCloseButt)
	
	//"Controles"
    oFwBrw:AddCollumn('COL_LEFT', 12, .F.)
	oFwBrw:AddWindow('COL_LEFT', 'WND_CTRL', 'Controles', 100, .T., .F.)
	oFwBrwL := oFwBrw:GetWinPanel('COL_LEFT', 'WND_CTRL')
	
	oFwBrw:SetColSplit('COL_LEFT', CONTROL_ALIGN_RIGHT)
	
	//"Detalhes"
	oFwBrw:AddCollumn('COL_RIGHT', 85, .F.)	
    oFwBrw:AddWindow('COL_RIGHT', 'WND_DET', 'Detalhes', 100, .T., .F.)
    oFwBrwR := oFwBrw:GetWinPanel('COL_RIGHT', 'WND_DET')
    
    oWebEngine 	:= TWebEngine():New(oFwBrwR, 05, 05, 350, 600,, nPort)
    oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT
    oWebEngine:setHtml(cHtml)
    
    oBtnClose := TButton():New( 05, 05, 'Fechar', 		oFwBrwL ,{|| oModalBrw:DeActivate()}, 50,20,,,.F.,.T.,.F.,,.F.,,,.F. )    
    oBtnPrint := TButton():New( 30, 5, 	'Impressão',	oFwBrwL ,{|| oWebEngine:PrintPDF()},  50,20,,,.F.,.T.,.F.,,.F.,,,.F. )
     
    
    oModalBrw:Activate()
    
	FreeObj(oBtnClose)
	FreeObj(oBtnPrint)
	FreeObj(oWebEngine)
	FreeObj(oFwBrwR)
	FreeObj(oFwBrwL)
	FreeObj(oFwBrw)
	FreeObj(oModalBrw)
return(nil)

