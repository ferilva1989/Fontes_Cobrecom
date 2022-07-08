#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} CRIASDBD
//TODO Ponto de entrada utilizado para complementar a gravação de dados na tabela SDB.
@author alexandre.madeira
@since 03/09/2018
@version 1.0
@return nil
@param nRecno := ParamIxb (R_E_C_N_O_ do SDB)
@type function
/*/
User Function CRIASDBD	
	//Chamada originada pelo faturamento do CSFatur
	If FWIsInCallStack('CriaNF')
		//Acondicionamento incorreto
		If AllTrim(SDC->(DC_LOCALIZ)) <> AllTrim(DB_LOCALIZ) .And. AllTrim(DB_ORIGEM) <> "SD3" 	
			ArrumaDb()
		EndIf
	EndIf
return(nil)




/*/{Protheus.doc} ArrumaDb
//TODO Impedir movimento em Localização incorreta no SDB/SBF no momento do faturamento
, visto que SDC que está com correto. Enviar log do erro para mapeamento.
@author alexandre.madeira
@since 03/09/2018
@version 1.0
@return nil
@type function
/*/
Static Function ArrumaDb()
	local cMsg		:= ''
	local cLinha	:= chr(13) + chr(10)
	local lAltFlux	:= FWIsInCallStack('AtuSldMov')
		cMsg += if(InTransact(), 'TRANSAÇÂO', 'SEM TRANSAÇÂO') 									+ cLinha
		cMsg += if(lAltFlux, 'FLUXO ALTERNATIVO(SDC ESTÁTICO)', 'DC - OK')						+ cLinha
		cMsg += 'DC_PRODUTO ' 					+ SDC->(DC_PRODUTO) 							+ cLinha
		cMsg += 'DC_LOCALIZ ' 					+ SDC->(DC_LOCALIZ) 							+ cLinha
		cMsg += 'DC_PEDIDO ' 					+ SDC->(DC_PEDIDO) 								+ cLinha
		cMsg += 'DC_ITEM ' 						+ SDC->(DC_ITEM) 								+ cLinha
		cMsg += 'DC_SEQ ' 						+ SDC->(DC_SEQ) 								+ cLinha
		cMsg += 'DC_QUANT ' 					+ cValToChar(SDC->(DC_QUANT)) 					+ cLinha
		cMsg += 'DC.R_E_C_N_O '					+ cValToChar(SDC->(Recno()))					+ cLinha
		cMsg += 'DB_DOC '	 					+ DB_DOC		 								+ cLinha
		cMsg += 'DB_PRODUTO ' 					+ DB_PRODUTO		 							+ cLinha
		cMsg += 'DB_LOCALIZ ' 					+ DB_LOCALIZ		 							+ cLinha
		cMsg += 'DB_QUANT ' 					+ cValToChar(DB_QUANT)	 						+ cLinha
		cMsg += 'ATUAL_BF_PRODUTO ' 			+ SBF->(BF_PRODUTO) 							+ cLinha
		cMsg += 'ATUAL_BF_LOCALIZ ' 			+ SBF->(BF_LOCALIZ) 							+ cLinha
		cMsg += 'ATUAL_BF_QUANT ' 				+ cValToChar(SBF->(BF_QUANT)) 					+ cLinha
		cMsg += 'ATUAL_BF_EMPENHO ' 			+ cValToChar(SBF->(BF_EMPENHO)) 				+ cLinha
		cMsg += 'ATUAL_BF_PRIOR ' 				+ SBF->(BF_PRIOR) 								+ cLinha

		// Deixar SDB->(DB_LOCALIZ) igual SDC->(DC_LOCALIZ), se SDC->(DC_PRODUTO) igual SC9->(C9_PRODUTO)
		if AllTrim(SDC->(DC_PRODUTO)) == AllTrim(SC9->(C9_PRODUTO))
			if (Reclock('SDB',.F.)) 
				DB_LOCALIZ := Padr(SDC->(DC_LOCALIZ),TamSX3("DB_LOCALIZ")[1])
				MsUnlock()
				cMsg += 'ALTERADO ' 							 								+ cLinha
			endif
		else
			cMsg += 'SDC <> SC9 ' 								 								+ cLinha
			cMsg += 'C9.R_E_C_N_O '					+ cValToChar(SC9->(Recno()))				+ cLinha
		endif
		
		u_SendMail("wfti@cobrecom.com.br;expedcom@cobrecom.com.br","[Erro - Localização] - Erro no Processamento da Nota " + AllTrim(DB_DOC) + ".", cMsg)
		
Return(nil)
