#include 'protheus.ch'
#include 'parmtype.ch'
#include 'cbcOrdemSep.ch'
#include 'cbcOrdemCar.ch'

static function qryCargaView(cFilter, dDtFrom)
    local cQry := ''
    default cFilter := ''
    default dDtFrom := CtoD("01/01/20")

    cQry += " SELECT ZZ9.ZZ9_ORDCAR AS [CARGA], "
    cQry += " ZZ9.ZZ9_PRIORI AS [PRIOR], "
    cQry += " CASE "
    cQry += "   WHEN SA4.A4_NOME IS NOT NULL "
    cQry += "       THEN SA4.A4_NOME
    cQry += "   ELSE 'NÃO DEFINIDA'
    cQry += " END AS [TRANSP], "
    cQry += " MAX(ZZ9.ZZ9_DATA) AS [EMISS], "
    cQry += " MAX(ZZ9.ZZ9_HORA) AS [HORA], "
    cQry += " ZZ9.ZZ9_STATUS AS [STATUS] "
    cQry += " FROM " + RetSqlName('ZZ9') + " ZZ9 "
    cQry += " LEFT JOIN " + RetSqlName('SA4') + " SA4 ON ZZ9.ZZ9_TRANSP = SA4.A4_COD "
    cQry += "                                     AND ZZ9.D_E_L_E_T_    = SA4.D_E_L_E_T_ "
    cQry += " WHERE ZZ9.ZZ9_FILIAL = '" + xFilial('ZZ9') + "' "
    if !empty(cFilter)
        cQry += " AND ZZ9.ZZ9_STATUS IN ('" + cFilter + "') "
    endif
    cQry += " AND ZZ9.ZZ9_DATA >= '" + DtoS(dDtFrom) + "'"
    cQry += " AND ZZ9.D_E_L_E_T_ = '' "
    cQry += " GROUP BY ZZ9.ZZ9_ORDCAR, ZZ9.ZZ9_PRIORI, "
    cQry += " ZZ9.ZZ9_TRANSP, ZZ9.ZZ9_STATUS, SA4.A4_NOME "
return(cQry)

static function getRegs(cCarga, cOs, cSts, cFilOri)
    local cQry      := ''
    default cOs     := ''
    default cCarga  := ''
    default cSts    := ""
    default cFilOri := ""

    if !empty(cCarga) .or. !empty(cOs)
        cQry += " SELECT ZZ9.R_E_C_N_O_ AS [REC] "
        cQry += " FROM " + RetSqlName('ZZ9') + " ZZ9 "
        cQry += " WHERE ZZ9.ZZ9_FILIAL = '" + xFilial('ZZ9') + "' "
        if !empty(cCarga)
            cQry += " AND ZZ9.ZZ9_ORDCAR = '" + AllTrim(cCarga) + "'"
        endif
        if !empty(cOs)
            cQry += " AND ZZ9.ZZ9_ORDSEP = '" + AllTrim(cOs) + "'"
        endif
        if !empty(cSts)
            cQry += " AND ZZ9.ZZ9_STATUS = '" + AllTrim(cSts) + "'"
        endif
        if !empty(cFilOri)
            cQry += " AND ZZ9.ZZ9_FILORI = '" + AllTrim(cFilOri) + "'"
        endif
        cQry += " AND ZZ9.D_E_L_E_T_ = '' "
    endif
return(cQry)

static function getByPedido(cPed)
    local cQry      := ''
    default cPed    := ''

    cQry += " SELECT ZZ9.R_E_C_N_O_ AS [REC], "
    cQry += " ZZ9.ZZ9_ORDCAR AS [CARGA], "
    cQry += " ZZ9.ZZ9_ORDSEP AS [OS], "
    cQry += " ZZ9.ZZ9_STATUS AS [STATUS] "
    cQry += " FROM " + RetSqlName('ZZ9') + " ZZ9 "
    cQry += " INNER JOIN " + RetSqlName('ZZR') + " ZZR ON ZZ9.ZZ9_FILIAL = ZZR.ZZR_FILIAL "
    cQry += "                                           AND ZZ9.ZZ9_ORDSEP = ZZR.ZZR_OS "
    cQry += "                                           AND ZZ9.D_E_L_E_T_ = ZZR.D_E_L_E_T_ "
    cQry += " WHERE ZZ9.ZZ9_FILIAL = '" + xFilial('ZZ9') + "' "
    cQry += " AND ZZR.ZZR_PEDIDO = '" + AllTrim(cPed) + "'"
    cQry += " AND ZZ9.D_E_L_E_T_ = '' "
return(cQry)

static function qrySelected(cTbl, cFld, cMarca)
    local cQry := ''

    cQry += " SELECT TEMP.R_E_C_N_O_ AS [REC], "
    cQry += " TEMP.CARGA AS [CARGA] "
    cQry += " FROM " + cTbl + " TEMP "
    cQry += " WHERE TEMP." + cFld + " = '" + cMarca + "' "
    cQry += " AND TEMP.D_E_L_E_T_ = '' "
return(cQry)

static function qryAddView(cCarga, cRota, lFat, cSts)
    local cQry      := ''
    default cCarga  := ''
    default cRota   := ''
    default lFat    := .F.
    default cSts    := ""

    cQry += " SELECT TEMP.ROTA AS [ROTA], "
    cQry += " TEMP.OS AS [OS], "
    cQry += " TEMP.CLI AS [CLI],  "
    cQry += " TEMP.LOJA AS [LOJA],  "
    cQry += " TEMP.NOME AS [NOME], "
    cQry += " TEMP.ENDCLI AS [ENDE], "
    cQry += " TEMP.MUN AS [MUN], "
    cQry += " TEMP.UF AS [UF], "
    cQry += " TEMP.ENDENT AS [ENT],  "
    cQry += " TEMP.CONDPAG AS [PAG], "
    cQry += " TEMP.FAT AS [FAT], "
    cQry += " TEMP.REPRE AS [REP], "
    cQry += " TEMP.ATEND AS [ATE], "
    cQry += " TEMP.BLQVEN AS [BLQ], "
    cQry += " TEMP.OBS AS [OBS], "
    cQry += " SUM(TEMP.PES) AS [PES],"
    cQry += " TEMP.AGENDAR AS [AGE], "
    cQry += " TEMP.DOC AS [DOC], "
    cQry += " TEMP.SERIE AS [SERIE], "
    cQry += " TEMP.FIN AS [FIN], "
    cQry += " TEMP.FILORI AS [FILORI] "
    cQry += " FROM ( "
    cQry += " 		SELECT  "
    cQry += " 		ZZR.ZZR_OS AS [OS],				 "
    //cQry += " 		--SC5.C5_ROTA AS [ROTA],		 "
    cQry += " 		CASE "
    cQry += " 			WHEN SC5.C5_TPFRETE = 'F' "
    cQry += " 			    THEN 'FOB' "
    cQry += " 			WHEN SC5.C5_ZZCLIEN <> '' AND SC5.C5_ZZLOJEN <> '' "
    cQry += " 				THEN CASE "
    cQry += " 					WHEN ZZ7ENT.ZZ7_ROTA IS NOT NULL "
    cQry += " 						THEN REPLICATE('0', 3 - LEN(ZZ7ENT.ZZ7_ROTA)) + RTrim(ZZ7ENT.ZZ7_ROTA) "
    cQry += " 					WHEN SA1ENT.A1_ROTA <> '' "
    cQry += " 						THEN SA1ENT.A1_ROTA "
    cQry += " 					ELSE 'SEM' "
    cQry += " 				END "
    cQry += " 			WHEN SC5.C5_ENDENT1 <> '' AND ZZ7.ZZ7_ROTA IS NOT NULL "
    cQry += " 				THEN REPLICATE('0', 3 - LEN(ZZ7.ZZ7_ROTA)) + RTrim(ZZ7.ZZ7_ROTA) "
    cQry += " 			WHEN ZZ7CLI.ZZ7_ROTA IS NOT NULL "
    cQry += " 				THEN REPLICATE('0', 3 - LEN(ZZ7CLI.ZZ7_ROTA)) + RTrim(ZZ7CLI.ZZ7_ROTA) "
    cQry += " 			WHEN SC5.C5_ROTA <> '' "
    cQry += " 				THEN SC5.C5_ROTA "
    cQry += " 			ELSE 'SEM' "
    cQry += " 		END AS [ROTA],		 "
    cQry += " 		SC5.C5_CLIENTE AS [CLI], "
    cQry += " 		SC5.C5_LOJACLI AS [LOJA], "
    cQry += " 		SA1.A1_NOME AS [NOME], "
    cQry += " 		SA1.A1_EST AS [UF], "
    cQry += " 		SA1.A1_MUN AS [MUN], "
    cQry += " 		SA1.A1_END AS [ENDCLI], "
    cQry += " 		CASE  "
    cQry += " 			WHEN ZZR.ZZR_OS <> ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
    cQry += " 				THEN SA1.A1_END "
    cQry += " 			ELSE SC5.C5_ENDENT2 "
    cQry += " 		END AS [ENDENT],				 "
    cQry += " 		SE4.E4_DESCRI AS [CONDPAG], "
    cQry += " 		CASE  "
    cQry += " 			WHEN ZZR.ZZR_OS <> ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
    cQry += " 				THEN CONVERT(VarChar, getdate(), 112) "
    cQry += " 			ELSE SC5.C5_DTFAT "
    cQry += " 		END AS [FAT],				 "
    cQry += " 		CASE  "
    cQry += " 			WHEN ZZR.ZZR_OS <> ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
    cQry += " 				THEN 'N' "
    cQry += " 			ELSE SC5.C5_ZZBLVEN "
    cQry += " 		END AS [BLQVEN],				 "
    cQry += " 		ISNULL(SA3REP.A3_NOME,'') AS [REPRE], "
    cQry += " 		ISNULL(SA3ATE.A3_NOME,'') AS [ATEND], "
    cQry += " 		CASE  "
    cQry += " 			WHEN ZZR.ZZR_OS <> ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
    cQry += " 				THEN '' "
    cQry += " 			ELSE SC5.C5_OBS "
    cQry += " 		END AS [OBS],				 "
    cQry += " 		SUM(ZZR.ZZR_EMBALA + ZZR.ZZR_PESPRO) AS [PES], "
    cQry += " 		SA1.A1_XAGENTR AS [AGENDAR], "
    cQry += " 		ZZR.ZZR_DOC AS [DOC], "
    cQry += " 		ZZR.ZZR_SERIE AS [SERIE], "
    cQry += "       ISNULL(ZZ9.ZZ9_FLGFIN,'') AS [FIN], "
    cQry += "       ISNULL(ZZ9.ZZ9_FILORI,'') AS [FILORI] "
    cQry += " 		FROM " + RetSqlName('ZZR') + " ZZR "
    cQry += " 		INNER JOIN " + RetSqlName('SC5') + " SC5 ON ZZR.ZZR_FILIAL  = SC5.C5_FILIAL "
    cQry += " 								            AND ZZR.ZZR_PEDIDO		= SC5.C5_NUM "
    cQry += " 								            AND ZZR.D_E_L_E_T_		= SC5.D_E_L_E_T_ "
    cQry += " 		INNER JOIN " + RetSqlName('SA1') + " SA1 ON SC5.C5_CLIENTE  = SA1.A1_COD "
    cQry += " 								            AND SC5.C5_LOJACLI		= SA1.A1_LOJA "
    cQry += " 								            AND SC5.D_E_L_E_T_		= SA1.D_E_L_E_T_ "
    cQry += " 		LEFT JOIN " + RetSqlName('ZZ7') + " ZZ7CLI ON ''            = ZZ7CLI.ZZ7_FILIAL "
    cQry += " 							 	            AND SA1.A1_CEP			= ZZ7CLI.ZZ7_CEP "
    cQry += " 								            AND SA1.D_E_L_E_T_		= ZZ7CLI.D_E_L_E_T_   "
    cQry += " 		LEFT JOIN " + RetSqlName('SA1')+ " SA1ENT ON SC5.C5_ZZCLIEN = SA1ENT.A1_COD "
    cQry += " 								            AND SC5.C5_ZZLOJEN		= SA1ENT.A1_LOJA "
    cQry += " 								            AND SC5.D_E_L_E_T_		= SA1ENT.D_E_L_E_T_ "
    cQry += " 		LEFT JOIN " + RetSqlName('ZZ7') + " ZZ7ENT ON ''            = ZZ7ENT.ZZ7_FILIAL "
    cQry += " 								            AND SA1ENT.A1_CEP	    = ZZ7ENT.ZZ7_CEP "
    cQry += " 								            AND SA1ENT.D_E_L_E_T_	= ZZ7ENT.D_E_L_E_T_ "
    cQry += " 		LEFT JOIN " + RetSqlName('ZZ7') + " ZZ7 ON ''               = ZZ7.ZZ7_FILIAL "
    cQry += " 								            AND SC5.C5_ENDENT1		= ZZ7.ZZ7_CEP "
    cQry += " 								            AND SC5.D_E_L_E_T_		= ZZ7.D_E_L_E_T_ "
    cQry += " 		INNER JOIN " + RetSqlName('SE4') + " SE4 ON SC5.C5_CONDPAG  = SE4.E4_CODIGO "
    cQry += " 								            AND SC5.D_E_L_E_T_	    = SE4.D_E_L_E_T_ "
    cQry += " 		LEFT JOIN " + RetSqlName('SA3') + " SA3REP ON SC5.C5_VEND1  = SA3REP.A3_COD "
    cQry += " 								            AND SC5.D_E_L_E_T_		= SA3REP.D_E_L_E_T_ "
    cQry += " 		LEFT JOIN " + RetSqlName('SA3') + " SA3ATE ON SA3REP.A3_SUPER = SA3ATE.A3_COD "
    cQry += " 								            AND SA3REP.D_E_L_E_T_   = SA3ATE.D_E_L_E_T_ "
    cQry += "       LEFT JOIN " + RetSqlName('ZZ9') + " ZZ9 ON ZZR.ZZR_FILIAL   = ZZ9.ZZ9_FILIAL "
    cQry += " 								            AND " + iif(empty(cCarga), "''", cCarga) + " = ZZ9.ZZ9_ORDCAR "
    cQry += " 								            AND ZZR.ZZR_OS          = ZZ9.ZZ9_ORDSEP "
    cQry += " 								            AND ZZR.D_E_L_E_T_      = ZZ9.D_E_L_E_T_ "
    cQry += " 		WHERE ZZR.ZZR_FILIAL = '" + xFilial('ZZR') + "' "
    if empty(cCarga)
        cQry += " 		AND ZZR.ZZR_OS NOT "
    else
        cQry += " 		AND ( ZZR.ZZR_OS "
    endif
    cQry += " 		IN ( "
    cQry += " 													SELECT DISTINCT(ZZ9.ZZ9_ORDSEP) "
    cQry += " 													FROM " + RetSqlName('ZZ9') + " ZZ9 "
    cQry += " 													WHERE ZZ9.ZZ9_FILIAL = ZZR.ZZR_FILIAL "
    if !empty(cCarga)
        cQry += " 												AND ZZ9.ZZ9_ORDCAR = '" + cCarga + "' "
    endif
    cQry += " 													AND ZZ9.D_E_L_E_T_	 = ZZR.D_E_L_E_T_ "
    cQry += " 		) "
    if !empty(cCarga)
        cQry += " 		) "
    endif
    if lFat
        cQry += " 		AND ZZR.ZZR_DOC = '' "
    endif
    cQry += " 		AND ZZR.ZZR_SITUAC <> '" + OS_CANCELADA + "' "
    cQry += " 		AND ZZR.ZZR_DATA >= '20201201' "
    cQry += " 		AND ZZR.ZZR_OS <> '' "
    cQry += " 		AND ZZR.D_E_L_E_T_ = '' "
    if !empty(cSts)
        cQry += " 	AND ZZ9.ZZ9_STATUS = '" + AllTrim(cSts) + "'"
    endif
    cQry += " 		GROUP BY ZZR.ZZR_OS, ZZR.ZZR_PEDIDO, ZZR.ZZR_SEQOS, SC5.C5_CLIENTE, "
    cQry += " 		SC5.C5_LOJACLI, SA1.A1_NOME, SA1.A1_EST, SA1.A1_MUN, SC5.C5_ZZBLVEN, "
    cQry += " 		SA1.A1_END, SC5.C5_ENDENT2, SC5.C5_OBS, SE4.E4_DESCRI, SC5.C5_DTFAT,  "
    cQry += " 		SC5.C5_ROTA, ISNULL(SA3REP.A3_NOME,''), ISNULL(SA3ATE.A3_NOME,''),  "
    cQry += " 		SC5.C5_ZZCLIEN, SC5.C5_ZZLOJEN, ZZ7ENT.ZZ7_ROTA, SA1ENT.A1_ROTA, ZZ7.ZZ7_ROTA, "
    cQry += " 		SC5.C5_ENDENT1, ZZ7CLI.ZZ7_ROTA, SA1.A1_XAGENTR, SC5.C5_TPFRETE, ZZR.ZZR_DOC, ZZR.ZZR_SERIE,  "
    cQry += " 	    ISNULL(ZZ9.ZZ9_FLGFIN, ''), ISNULL(ZZ9.ZZ9_FILORI, '')"
    if !empty(cCarga)
        cQry += " 	    UNION ALL "
        cQry += " 	    SELECT "
        cQry += " 	    ZZR.ZZR_OS AS [OS], "
        cQry += " 	    'TRB' AS [ROTA], "
        cQry += " 	    SC5.C5_CLIENTE AS [CLI], "
        cQry += " 	    SC5.C5_LOJACLI AS [LOJA], "
        cQry += " 	    SA1.A1_NOME AS [NOME], "
        cQry += " 	    SA1.A1_EST AS [UF], "
        cQry += " 	    SA1.A1_MUN AS [MUN], "
        cQry += " 	    SA1.A1_END AS [ENDCLI], "
        cQry += " 	    CASE "
        cQry += " 	        WHEN ZZR.ZZR_OS <> ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
        cQry += " 	            THEN SA1.A1_END "
        cQry += " 	        ELSE SC5.C5_ENDENT2 "
        cQry += " 	    END AS [ENDENT], "
        cQry += " 	    SE4.E4_DESCRI AS [CONDPAG], "
        cQry += " 	    CASE "
        cQry += " 	        WHEN ZZR.ZZR_OS <> ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
        cQry += " 	            THEN CONVERT(VarChar, getdate(), 112) "
        cQry += " 	        ELSE SC5.C5_DTFAT "
        cQry += " 	    END AS [FAT], "
        cQry += " 	    CASE "
        cQry += " 	        WHEN ZZR.ZZR_OS <> ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
        cQry += " 	            THEN 'N' "
        cQry += " 	        ELSE SC5.C5_ZZBLVEN "
        cQry += " 	    END AS [BLQVEN], "
        cQry += " 	    ISNULL(SA3REP.A3_NOME,'') AS [REPRE], "
        cQry += " 	    ISNULL(SA3ATE.A3_NOME,'') AS [ATEND], "
        cQry += " 	    CASE "
        cQry += " 	        WHEN ZZR.ZZR_OS <> ZZR.ZZR_PEDIDO + ZZR.ZZR_SEQOS "
        cQry += " 	            THEN '' "
        cQry += " 	        ELSE SC5.C5_OBS "
        cQry += " 	    END AS [OBS], "
        cQry += " 	    SUM(ZZR.ZZR_EMBALA + ZZR.ZZR_PESPRO) AS [PES], "
        cQry += " 	    SA1.A1_XAGENTR AS [AGENDAR], "
        cQry += " 	    ZZR.ZZR_DOC AS [DOC], "
        cQry += " 	    ZZR.ZZR_SERIE AS [SERIE], "
        cQry += " 	    ISNULL(ZZ9.ZZ9_FLGFIN,'') AS [FIN], "
        cQry += " 	    ISNULL(ZZ9.ZZ9_FILORI,'') AS [FILORI] "
        cQry += " 	    FROM ZZ9010 ZZ9 "
        cQry += " 	    INNER JOIN " + RetSqlName('ZZR') + " ZZR ON ZZR.ZZR_FILIAL   = ZZ9.ZZ9_FILORI "
        cQry += " 	                            AND ZZR.ZZR_OS          = ZZ9.ZZ9_ORDSEP "
        cQry += " 	                            AND ZZR.ZZR_SITUAC 		<> '9' "
        cQry += " 	                            AND ZZR.ZZR_DATA 		>= '20201201' "
        cQry += " 	                            AND ZZR.ZZR_OS 			<> '' "
        cQry += " 	                            AND ZZR.D_E_L_E_T_      = ZZ9.D_E_L_E_T_ "
        cQry += " 	    INNER JOIN " + RetSqlName('SC5') + " SC5 ON ZZR.ZZR_FILIAL  = SC5.C5_FILIAL "
        cQry += " 	                            AND ZZR.ZZR_PEDIDO		= SC5.C5_NUM "
        cQry += " 	                            AND ZZR.D_E_L_E_T_		= SC5.D_E_L_E_T_ "
        cQry += " 	    INNER JOIN " + RetSqlName('SA1') + " SA1 ON SC5.C5_CLIENTE  = SA1.A1_COD "
        cQry += " 	                            AND SC5.C5_LOJACLI		= SA1.A1_LOJA "
        cQry += " 	                            AND SC5.D_E_L_E_T_		= SA1.D_E_L_E_T_ "
        cQry += " 	    INNER JOIN " + RetSqlName('SE4') + " SE4 ON SC5.C5_CONDPAG  = SE4.E4_CODIGO "
        cQry += " 	                            AND SC5.D_E_L_E_T_	    = SE4.D_E_L_E_T_ "
        cQry += " 	    LEFT JOIN " + RetSqlName('SA3') + " SA3REP ON SC5.C5_VEND1  = SA3REP.A3_COD "
        cQry += " 	                            AND SC5.D_E_L_E_T_		= SA3REP.D_E_L_E_T_ "
        cQry += " 	    LEFT JOIN " + RetSqlName('SA3') + " SA3ATE ON SA3REP.A3_SUPER = SA3ATE.A3_COD "
        cQry += " 	                            AND SA3REP.D_E_L_E_T_   = SA3ATE.D_E_L_E_T_ "
        cQry += " 	    WHERE ZZ9.ZZ9_FILIAL = '" + xFilial('ZZ9') + "' "
        cQry += " 	    AND ZZ9.ZZ9_FILIAL <> ZZ9.ZZ9_FILORI "
        cQry += " 	    AND ZZ9.ZZ9_ORDCAR = '" + cCarga + "' "
        cQry += " 	    AND ZZ9.D_E_L_E_T_ = '' "
        if !empty(cSts)
            cQry += " 	    AND ZZ9.ZZ9_STATUS = '" + AllTrim(cSts) + "' "
        endif
        cQry += " 	    GROUP BY ZZR.ZZR_OS, ZZR.ZZR_PEDIDO, ZZR.ZZR_SEQOS, SC5.C5_CLIENTE, "
        cQry += " 	    SC5.C5_LOJACLI, SA1.A1_NOME, SA1.A1_EST, SA1.A1_MUN, SC5.C5_ZZBLVEN, "
        cQry += " 	    SA1.A1_END, SC5.C5_ENDENT2, SC5.C5_OBS, SE4.E4_DESCRI, SC5.C5_DTFAT, "
        cQry += " 	    ISNULL(SA3REP.A3_NOME,''), ISNULL(SA3ATE.A3_NOME,''), "
        cQry += " 	    SA1.A1_XAGENTR, ZZR.ZZR_DOC, ZZR.ZZR_SERIE, ISNULL(ZZ9.ZZ9_FLGFIN, ''), ISNULL(ZZ9.ZZ9_FILORI,'') "
    endif
    cQry += " ) AS TEMP "
    if !empty(cRota)
        cQry += " WHERE TEMP.ROTA IN (" + cRota + ") "
    endif
    cQry += " GROUP BY TEMP.OS, TEMP.ROTA, TEMP.CLI, TEMP.LOJA,  "
    cQry += " TEMP.NOME, TEMP.ENDCLI, TEMP.MUN, TEMP.FAT,  "
    cQry += " TEMP.UF , TEMP.ENDENT, TEMP.OBS, TEMP.CONDPAG, "
    cQry += " TEMP.BLQVEN, TEMP.REPRE, TEMP.ATEND, TEMP.AGENDAR, TEMP.DOC, TEMP.SERIE,TEMP.FIN, TEMP.FILORI "
    cQry += " ORDER BY TEMP.ROTA, TEMP.OS "
return(cQry)

static function qryOSSelected(cTab, cFld, cMarca)
    local cQry := ''

    cQry += " SELECT TEMP.OS AS [OS], "
    cQry += " TEMP.ROTA AS [ROTA], "
    cQry += " TEMP.FILORI AS [FILORI] "
    cQry += " FROM " + cTab + " TEMP "
    cQry += " WHERE TEMP." + cFld + " = '" + cMarca + "' "
    cQry += " AND TEMP.D_E_L_E_T_ = '' "
return(cQry)

static function qryGetCli(cOS, cFili)
    local cQry := ''
    default cFili := xFilial('ZZR')

    cQry += " SELECT SA1.A1_COD + SA1.A1_LOJA + ' - ' + SA1.A1_NOME AS [CLI], "
    cQry += " SA1.A1_COD AS [COD],  "
    cQry += " SA1.A1_LOJA AS [LOJA], "
    cQry += " SA1.A1_NOME AS [NOME], "
    cQry += " SA1.R_E_C_N_O_ AS [REC], "
    cQry += " SE4.R_E_C_N_O_ AS [COND] "
    cQry += " FROM " + RetSqlName('ZZR') + " ZZR WITH(NOLOCK) "
    cQry += " INNER JOIN " + RetSqlName('SC5') + " SC5 WITH(NOLOCK) ON ZZR.ZZR_FILIAL = SC5.C5_FILIAL "
    cQry += " 					AND ZZR.ZZR_PEDIDO	= SC5.C5_NUM "
    cQry += " 					AND ZZR.D_E_L_E_T_	= SC5.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SA1') + " SA1 WITH(NOLOCK) ON SC5.C5_CLIENTE = SA1.A1_COD "
    cQry += " 					AND SC5.C5_LOJACLI	= SA1.A1_LOJA "
    cQry += " 					AND SC5.D_E_L_E_T_	= SA1.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SE4') + " SE4 WITH(NOLOCK) ON SC5.C5_CONDPAG = SE4.E4_CODIGO "
    cQry += " 					AND SC5.D_E_L_E_T_	= SE4.D_E_L_E_T_ "
    cQry += " WHERE ZZR.ZZR_FILIAL = '" + cFili + "' "
    cQry += " AND ZZR_OS = '" + AllTrim(cOS) + "' "
    cQry += " AND ZZR.ZZR_SITUAC <> '" + OS_CANCELADA + "' "
    cQry += " AND ZZR.D_E_L_E_T_ = '' "
    cQry += " GROUP BY SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME, SA1.R_E_C_N_O_,SE4.R_E_C_N_O_ "
return(cQry)

static function qryStatusCarga(cCarga, cOs)
    local cQry := ''
    default cOs:=''
    cQry += " SELECT DISTINCT(ZZ9.ZZ9_STATUS) AS [STATUS]                    "
    cQry += " FROM " + RetSqlName('ZZ9') + " ZZ9                             "
    cQry += " WHERE ZZ9.ZZ9_FILIAL = '" + xFilial('ZZ9') + "'          	     "
    cQry += " AND ZZ9.ZZ9_ORDCAR = '"+ cCarga +"'                            "
    if !empty(cOs)
        cQry += " AND ZZ9.ZZ9_ORDSEP = '" + AllTrim(cOs) + "'"
    endif
    cQry += " AND ZZ9.D_E_L_E_T_ = ''                                        "
return(cQry)

static function avalFinance(cOrdCar)
    local cQry      := ''

    cQry += " SELECT ZZ9.R_E_C_N_O_ AS [REC], "
    cQry += " SA1.A1_RISCO AS [RISCO], "
    cQry += " ZZ9.ZZ9_ORDSEP AS [SEP] "
    cQry += " FROM " + RetSqlName('ZZ9') + " ZZ9 "
    cQry += " INNER JOIN " + RetSqlName('ZZR') + " ZZR ON ZZ9.ZZ9_FILIAL = ZZR.ZZR_FILIAL  "
    cQry += " 					 AND ZZ9.ZZ9_ORDSEP = ZZR.ZZR_OS "
    cQry += " 					 AND ZZ9.D_E_L_E_T_ = ZZR.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SC5') + " SC5 ON ZZR.ZZR_FILIAL = SC5.C5_FILIAL "
    cQry += " 					 AND ZZR.ZZR_PEDIDO = SC5.C5_NUM "
    cQry += " 					 AND ZZR.D_E_L_E_T_ = SC5.D_E_L_E_T_ "
    cQry += " INNER JOIN " + RetSqlName('SA1') + " SA1 ON SC5.C5_CLIENT  = SA1.A1_COD "
    cQry += " 					 AND SC5.C5_LOJACLI = SA1.A1_LOJA "
    cQry += " 					 AND SC5.D_E_L_E_T_ = SA1.D_E_L_E_T_ "
    cQry += " WHERE ZZ9.ZZ9_FILIAL = '" + xFilial('ZZ9') + "' "
    cQry += " AND ZZ9.ZZ9_ORDCAR = '" + cOrdCar + "' "
    cQry += " AND ZZ9.ZZ9_FLGFIN IN ('N','') "
    cQry += " AND ZZ9.D_E_L_E_T_ = '' "
    cQry += " GROUP BY ZZ9.R_E_C_N_O_, SA1.A1_RISCO, ZZ9.ZZ9_ORDSEP "
return(cQry)

static function qryNotaxCarga()
    local cQry := ""

    cQry += " SELECT ZZ9.R_E_C_N_O_ AS [REC], "
    cQry += " ISNULL(ZZ9S.ZZ9_ORDCAR,'') AS [CARGA] "
    cQry += " FROM SF2010 SF2 "
    cQry += " INNER JOIN ZZ9010 ZZ9 ON SF2.F2_FILIAL = ZZ9.ZZ9_FILIAL "
    cQry += " 					 AND SF2.F2_DOC	   = ZZ9.ZZ9_DOC "
    cQry += " 					 AND SF2.F2_SERIE  = ZZ9.ZZ9_SERIE "
    cQry += " 					 AND SF2.D_E_L_E_T_= ZZ9.D_E_L_E_T_ "
    cQry += " LEFT JOIN ZZ9010 ZZ9S ON '" + xFilial("ZZ9") + "' = ZZ9S.ZZ9_FILIAL "
    cQry += " 					 AND SF2.F2_DOC	   = ZZ9S.ZZ9_DOC "
    cQry += " 					 AND SF2.F2_SERIE  = ZZ9S.ZZ9_SERIE "
    cQry += " 					 AND SF2.D_E_L_E_T_= ZZ9S.D_E_L_E_T_ "
    cQry += " WHERE SF2.F2_CHVNFE = '" + cChv + "' "
    cQry += " AND SF2.D_E_L_E_T_ = '' "
return(cQry)
