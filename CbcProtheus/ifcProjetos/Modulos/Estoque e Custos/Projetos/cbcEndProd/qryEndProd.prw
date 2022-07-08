#include 'Totvs.ch'

user function qryEndProd(cOpc, aParam)
    local cQry      := ""
    default cOpc    := ""
    default aParam  := {}

    if cOpc == 'D'
        //aParam -> [1] - Unimov
        cQry := qryDetUnmov(aParam)
    endif
return(cQry)

static function qryDetUnmov(cMovUn)
    local cQry := ""
    cQry += " SELECT  "
    cQry += " MOV.IDMovUn AS [UNIMOV], "
    cQry += " PROD.Code AS [PROD], "
    cQry += " SB1.B1_DESC AS [DESCRI], "
    cQry += " MOV.MovUnQty AS [QTD], "
    cQry += " CONVERT(NVARCHAR,MOV.DtTimeStamp,112) AS [ODATA], "
    cQry += " CONVERT(NVARCHAR,MOV.DtTimeStamp,108) AS [OHORA], "
    cQry += " LOTE.Code AS [LOTE] "
    cQry += " FROM [PCF_PROD].PCFactory.dbo.TBLMovUn MOV "
    cQry += " INNER JOIN [PCF_PROD].PCFactory.dbo.TBLProduct AS PROD ON MOV.IDProduct = PROD.IDProduct "
    cQry += " INNER JOIN [PCF_PROD].PCFactory.dbo.TBLLot AS LOTE ON MOV.IDLot = LOTE.IDLot "
    cQry += " INNER JOIN SB1010 SB1 WITH(NOLOCK) ON RTRIM(LTRIM(PROD.Code)) = RTRIM(LTRIM(SB1.B1_COD)) COLLATE Latin1_General_BIN  AND '' = SB1.D_E_L_E_T_ "
    cQry += " WHERE MOV.IDMovUn = " + AllTrim(cValToChar(cMovUn))
return(cQry)
