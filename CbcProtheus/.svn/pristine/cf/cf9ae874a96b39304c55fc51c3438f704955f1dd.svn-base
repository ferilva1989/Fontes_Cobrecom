#include 'protheus.ch'
#include 'parmtype.ch'

user function qryTransFil(nRecSF2, cOpc)
	local cQry	 := ''
	default cOpc := 'H'
	
	if cOpc == 'H'
		cQry := qryHeader(nRecSF2)
	elseif cOpc == 'I'
		cQry := qryItems(nRecSF2)
	endif
return(cQry)

static function qryHeader(nRec)
	local cQry := ''
	
	default nRec := 0
		
	cQry += " SELECT 	SF2.F2_FILIAL	AS [FILIAL],		"
	cQry += " 			SF2.F2_DOC 		AS [DOC],          	"
	cQry += " 			SF2.F2_SERIE 	AS [SERIE],			"
	cQry += " 			SF2.F2_EMISSAO 	AS [EMISSAO],       "
	cQry += " 			SF2.F2_TIPO 	AS [TIPO],          "
	cQry += " 			SF2.F2_ESPECIE 	AS [ESPECIE],       "
	cQry += "			SF2.F2_CHVNFE 	AS [CHVNFE],        "
	cQry += " SF2.F2_FILIAL+SF2.F2_DOC+SF2.F2_SERIE+SF2.F2_CLIENTE+SF2.F2_LOJA AS [OBSTRF] "
	cQry += " FROM " + RetSqlName('SF2') + " SF2            "
	cQry += " WHERE SF2.R_E_C_N_O_ = " + cValtoChar(nRec)
	cQry += " AND SF2.D_E_L_E_T_ = ''                       "
	
return(cQry)

static function qryItems(nRec)
	local cQry := ''
	default nRec := 0
	
	cQry += " SELECT SD2.D2_FILIAL	AS [FILIAL],                              "
	cQry += " SD2.D2_ITEM			AS [ITEM],                                "
	cQry += " SD2.D2_COD			AS [COD],                                 "
	cQry += " SD2.D2_QUANT			AS [QUANT],                               "
	cQry += " SD2.D2_LOCAL			AS [LOCAL],                               "
	cQry += " SD2.D2_PRCVEN			AS [PRCVEN],                              "
	cQry += " SD2.D2_TOTAL			AS [TOTAL],                               "
	cQry += " SD2.D2_TES			AS [TES],                                 "
	cQry += " SD2.D2_PICM			AS [PICM],                                "
	cQry += " SD2.D2_VALICM			AS [VALICM],                              "
	cQry += " SD2.D2_CLASFIS		AS [CLASFIS]	                          "
	cQry += " FROM SF2010 SF2                                                 "
	cQry += " INNER JOIN " + RetSqlName('SD2') + " SD2 ON	SF2.F2_FILIAL	= SD2.D2_FILIAL "
	cQry += " 						AND SF2.F2_DOC		= SD2.D2_DOC          "
	cQry += " 						AND SF2.D_E_L_E_T_	= SD2.D_E_L_E_T_      "
	cQry += " WHERE SF2.R_E_C_N_O_ = " + cValToChar(nRec)
	cQry += " AND SF2.D_E_L_E_T_ = ''		                                  "
	
return(cQry)

user function qryTrfFindCF(cFilOri, cTpNF)
	local cQry := ''
	
	if cTpNF == 'N'
		cQry := findFornece(cFilOri)
	elseif cTpNF == 'B'
		cQry := findCliente(cFilOri)
	endif
	
return(cQry)

static function findFornece(cFilOri)
	local cQry	:= ''
	cQry += " SELECT SA2.A2_COD AS [COD],                        "
	cQry += " SA2.A2_LOJA AS [LOJA]                              "
	cQry += " FROM " + RetSqlName('SA2') + " SA2	             "
	cQry += " WHERE SA2.A2_FILIAL = '" + xFilial('SA2') + "'     "
	cQry += " AND SA2.A2_FILTRF = '" + cFilOri + "' 			 "
	cQry += " AND SA2.D_E_L_E_T_ = ''	 						 "
return(cQry)

static function findCliente(cFilOri)
	local cQry := ''
return(cQry)


static function qryVldEnd(cChvNFe)
	local cQry 		:= ""
	default cChvNFe := ""
	
	if !empty(cChvNFe)
		cQry := " SELECT SF1.F1_DOC		AS [NF], "
		cQry += " 		SF1.F1_SERIE	AS [SERIE_NF], "
		cQry += " 		SF1.F1_EMISSAO	AS [EMISSAO_NF], " 
		cQry += " 		SD1.D1_ITEM 	AS [ITEM_NF], "
		cQry += " 		SD1.D1_COD		AS [PRODUTO], "
		cQry += " 		SD1.D1_QUANT	AS [QTDE_NF], "
		cQry += " 		SDA.DA_SALDO	AS [SALDO_AENDER] "
		cQry += " 	FROM SD1010 SD1 WITH(NOLOCK) "
		cQry += " 		INNER JOIN SF1010 SF1 WITH(NOLOCK) "
		cQry += " 			ON SF1.F1_FILIAL	= SD1.D1_FILIAL "
		cQry += " 			AND SF1.F1_DOC		= SD1.D1_DOC "
		cQry += " 			AND SF1.F1_SERIE	= SD1.D1_SERIE "
		cQry += " 			AND SF1.D_E_L_E_T_	= SD1.D_E_L_E_T_ "
		cQry += " 		INNER JOIN SDA010 SDA WITH(NOLOCK) "
		cQry += " 			ON SD1.D1_FILIAL	= SDA.DA_FILIAL "
		cQry += " 			AND SD1.D1_COD		= SDA.DA_PRODUTO " 		
		cQry += " 			AND SD1.D1_LOCAL	= SDA.DA_LOCAL "
		cQry += " 			AND SD1.D1_NUMSEQ	= SDA.DA_NUMSEQ "
		cQry += " 			AND SD1.D_E_L_E_T_	= SDA.D_E_L_E_T_ "
		cQry += " WHERE "
		cQry += " 	SF1.F1_CHVNFE =  '" + cChvNFe + "' " 	//50200202544042000208550010000650801100261190		  
		cQry += " 	AND SD1.D_E_L_E_T_ = '' "
		cQry += " 	AND SDA.DA_SALDO > 0 "
		cQry += " ORDER BY SD1.D1_COD "
	endif
return(cQry)

static function qryDivBob(cChvNFe)
	local cQry := ""
	default cChvNFe := ""
	
	if !empty(cChvNFe)
		cQry := " SELECT "
		cQry += " 	NOTA.NOTA_PRODUTO 	, "
		cQry += " 	NOTA.NOTA_ACOND		, "
		cQry += " 	NOTA.NOTA_QTD		, "
		cQry += " 	ISNULL(BOBINA.BOBINA_QTD, 0) AS QTD_SZE	 "
		cQry += " FROM "
		cQry += " 	( "
		cQry += " 		SELECT "
		cQry += " 			SD1.D1_COD			AS NOTA_PRODUTO, "
		cQry += " 			SDB.DB_LOCALIZ		AS NOTA_ACOND, "
		cQry += " 			SUM(SDB.DB_QUANT)	AS NOTA_QTD "
		cQry += " 		FROM SD1010 SD1 WITH(NOLOCK) "
		cQry += " 			INNER JOIN SF1010 SF1 WITH(NOLOCK) "
		cQry += " 				ON SF1.F1_FILIAL	= SD1.D1_FILIAL "
		cQry += " 				AND SF1.F1_DOC		= SD1.D1_DOC " 		
		cQry += " 				AND SF1.F1_SERIE	= SD1.D1_SERIE "		
		cQry += " 				AND SF1.D_E_L_E_T_	= SD1.D_E_L_E_T_ "
		cQry += " 			INNER JOIN SDA010 SDA WITH(NOLOCK) "	
		cQry += " 				ON SD1.D1_FILIAL	= SDA.DA_FILIAL " 		
		cQry += " 				AND SD1.D1_COD		= SDA.DA_PRODUTO "	 		
		cQry += " 				AND SD1.D1_LOCAL	= SDA.DA_LOCAL "	 		
		cQry += " 				AND SD1.D1_NUMSEQ	= SDA.DA_NUMSEQ " 		
		cQry += " 				AND SD1.D_E_L_E_T_	= SDA.D_E_L_E_T_ "
		cQry += " 			INNER JOIN SDB010 SDB WITH(NOLOCK) "
		cQry += " 				ON SD1.D1_FILIAL	= SDB.DB_FILIAL "
		cQry += " 				AND SD1.D1_NUMSEQ	= SDB.DB_NUMSEQ "
		cQry += " 				AND SD1.D_E_L_E_T_	= SDB.D_E_L_E_T_ "
		cQry += " 		WHERE "
		cQry += " 			SF1.F1_CHVNFE =  '" + cChvNFe + "' "
		cQry += " 			AND SD1.D_E_L_E_T_ = '' "
		cQry += " 			AND LEFT(SDB.DB_LOCALIZ,1) = 'B' "            	  			
		cQry += " 		GROUP BY SD1.D1_COD, SDB.DB_LOCALIZ "
		cQry += " 	) AS NOTA "
		cQry += "	LEFT JOIN "
		cQry += "	( "
		cQry += " 		SELECT "
		cQry += " 			SZE.ZE_PRODUTO AS BOBINA_PRODUTO, "
		cQry += " 			'B' + REPLICATE('0',(5- LEN(SZE.ZE_QUANT))) + CAST(SZE.ZE_QUANT AS VARCHAR(5)) AS BOBINA_ACOND, "
		cQry += " 			SUM(SZE.ZE_QUANT) AS BOBINA_QTD "
		cQry += " 		FROM SD1010 SD1 WITH(NOLOCK) "
		cQry += " 			INNER JOIN SF1010 SF1 WITH(NOLOCK) "
		cQry += " 				ON SF1.F1_FILIAL	= SD1.D1_FILIAL "
		cQry += " 				AND SF1.F1_DOC		= SD1.D1_DOC "   		
		cQry += " 				AND SF1.F1_SERIE	= SD1.D1_SERIE "		
		cQry += " 				AND SF1.D_E_L_E_T_	= SD1.D_E_L_E_T_ "    
		cQry += " 			INNER JOIN SZE010 SZE WITH(NOLOCK) "
		cQry += " 				ON SD1.D1_FILIAL	= SZE.ZE_FILIAL "
		cQry += " 				AND SD1.D1_NUMSEQ	= SZE.ZE_SEQORIG "
		cQry += " 				AND SD1.D_E_L_E_T_	= SZE.D_E_L_E_T_ "
		cQry += " 		WHERE  "
		cQry += " 			SF1.F1_CHVNFE			=  '" + cChvNFe + "' " 			  
		cQry += " 			AND SD1.D_E_L_E_T_		= '' "
		cQry += " 		GROUP BY  SZE.ZE_PRODUTO, 'B' + REPLICATE('0',(5- LEN(SZE.ZE_QUANT))) + CAST(SZE.ZE_QUANT AS VARCHAR(5)) "
		cQry += " 	) AS BOBINA "
		cQry += " 	ON NOTA.NOTA_PRODUTO = BOBINA.BOBINA_PRODUTO "
		cQry += " 	AND NOTA.NOTA_ACOND = BOBINA.BOBINA_ACOND "
		cQry += " 	AND NOTA_QTD <> BOBINA.BOBINA_QTD "
	endif
return(cQry)