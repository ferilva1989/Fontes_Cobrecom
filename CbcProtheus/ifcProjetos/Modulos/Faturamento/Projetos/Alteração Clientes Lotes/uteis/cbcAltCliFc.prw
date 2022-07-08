//Bibliotecas
#INCLUDE 'Protheus.ch'
#INCLUDE 'TOTVS.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "rwmake.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "tbiconn.ch"
#define BR Chr(10) 

user function mkA1Sel(cCampoX3,cConteudo)
    private oMark
    private aDadCli 	:= {}
    private aRotina		:= MenuDef()
    public cCpoX3		:= "",cCont := ""
    default cCampoX3 := "", cConteudo := ""
    
    cCpoX3 := cCampoX3
    cCont 	:= cConteudo
    DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
    oMark := FWMarkBrowse():New()
    oMark:SetAlias('SA1')
    oMark:SetSemaphore( .F. )
    oMark:SetDescription('Seleção de Clientes para alteração')
    oMark:SetFieldMark('A1_OK')   
    oMark:Activate()
return 

/*/{Protheus.doc} MenuDef
//TODO Criação do menu MVC.
@author juliana.leme
@since 06/03/2019
@version 1.0
@type function
/*/
static Function MenuDef()
	local aRotina := {} 
    ADD OPTION aRotina TITLE 'Processar'  ACTION 'U_ProcAlMk()' OPERATION 2 ACCESS 0
return aRotina

user function ProcAlMk()
	FWMsgRun(, {|oSay| A1MkProc() }, "Aguarde...", "Alterando os clientes selecionados ...")
return
 
/*/{Protheus.doc} A1MkProc
Rotina para processamento e verificação de quantos registros estão marcados
@author juliana.leme
@since 06/03/2019
@version 1.0
/*/
static function A1MkProc()
    local aArea		:= GetArea()
    local cMarca	:= oMark:Mark()
    local lInverte	:= oMark:IsInvert()
    local lRet 		:= .T.
    local _cAssunto	:= "Alteracao de Clientes em LOTE - " + DtoC(dDataBase)
    local cEmailMsg	:= ""
    local _cTo		:= "wfti@cobrecom.com.br"
    private cContAnt	:= ""
    private oModel, oAux, oStruct
    
    oModel := FWLoadModel('CRMA980')
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oAux 	:= oModel:GetModel('SA1MASTER')
	
    SA1->(DbGoTop())
    Begin Transaction
	    while !SA1->(EoF())
	        if oMark:IsMark(cMarca)
	        	oModel:Activate()
	        	lRet 		:= .T.
	        	lRet 		:= ProcUpd(oModel,cCpoX3, cCont)
	        	If lRet
					FWFormCommit(oModel) // Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
					cEmailMsg += "Cliente/Loja : " + SA1->A1_COD + SA1->A1_LOJA + " -  Campo Alterado : " + cCpoX3 + ;
								"Dado Anterior: " + cValToChar(cContAnt) + " Dados Atualizado: " + cValToChar(cCont) + BR
					U_GrvZZ1({SA1->A1_COD,SA1->A1_LOJA},cCpoX3, {cValToChar(cContAnt),cValToChar(cCont)}, 'Alterar', "Alteracao em lote - ROTINA: cbcAltCliLt()" )
				else
					aErro := oModel:GetErrorMessage()
					cErroMess := "ALTERAÇÃO NÃO REALIZADA PARA O CLIENTE:" + BR
					cErroMess += "Cliente/Loja: " + SA1->A1_COD + "/" + SA1->A1_LOJA + " - " + SA1->A1_NOME + BR
					cErroMess += "Id do formulário de origem:" + ' [' + AllToChar( aErro[1] ) + ']' + BR
					cErroMess += "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' + BR
					cErroMess += "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + ']' + BR
					cErroMess += "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' + BR
					cErroMess += "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' + BR
					cErroMess += "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' + BR
					cErroMess += "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' + BR
					cErroMess += "Valor atribuído: " + ' [' + AllToChar( aErro[8] ) + ']' + BR
					cErroMess += "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']' + BR
					MsgBox(cErroMess , "Atenção !!!", "INFO")
				EndIf
	        	oModel:DeActivate()
	        endif
	        SA1->(DbSkip())
	    enddo   
    end Transaction
    RestArea(aArea)
    U_SendMail(_cTo,_cAssunto,cEmailMsg)
    MsgBox("Rotina Finalizada!!" , "Informação", "INFO")
    FreeObj(oModel)
    CloseBrowse()
return 
 
/*/{Protheus.doc} ProcUpd
//TODO Descrição auto-gerada.
@author juliana.leme
@since 08/03/2019
@version 1.0
@param oModel, object, descricao
@param cCampo, characters, descricao
@param cConteudo, characters, descricao
@type function
/*/
static function ProcUpd(oModel, cCampo, cConteudo)
    local lRet 		:= .T.
    default cCampo	:= "" , cConteudo := ""
    
    cContAnt := oModel:GetValue("SA1MASTER",cCampo)
    If !( lAux := oModel:LoadValue("SA1MASTER",cCampo,cConteudo))
    	lRet	:= .F. 
    else
		lRet 	:= oModel:LoadValue("SA1MASTER","A1_OK","")
	endif   
return lRet

/*/{Protheus.doc} BlqCliDt
//TODO Descrição auto-gerada.
@author juliana.leme
@since 08/03/2019
@version 1.0
@param dDateCanc, date, descricao
@type function
/*/
user function BlqCliDt(dDateCanc)
	local cQuery 		:= ""
	local oResultSQL	:= nil
	local nRecno		:= 0
	local _cAssunto		:= "Bloqueio de Clientes em LOTE - " + DtoC(dDataBase)
    local _cTo			:= "wfti@cobrecom.com.br"
    local nQtd			:= 0
    private cEmailMsg	:= ""
	default dDateCanc 	:= ""
	
	//Query onde retorn clientes ativos que não possuiram compras desde a ultima data estipulada e
	//não possuem pedidos em aberto
	cQuery := " SELECT SA1010.R_E_C_N_O_ RECNO"
	cQuery += " FROM SA1010 "
	cQuery += " WHERE (A1_COD + A1_LOJA) "
	cQuery += " IN ( "
	cQuery += " 	SELECT "
	cQuery += " 		INATIVOS.CODLOJA "
	cQuery += " 	FROM ( "
	cQuery += " 		SELECT * "
	cQuery += " 		FROM 	( "
	cQuery += " 			SELECT " 
	cQuery += " 				SA1.A1_NOME AS NOME, "
	cQuery += " 				SA1.A1_COD + SA1.A1_LOJA AS CODLOJA, "
	cQuery += " 				MAX(F2.F2_EMISSAO) AS ULTCOM "
	cQuery += "				FROM SA1010 SA1 "
	cQuery += " 			INNER JOIN SF2010 F2 "
	cQuery += " 				ON  SA1.A1_FILIAL	= '' "
	cQuery += " 				AND SA1.A1_COD		= F2.F2_CLIENTE "
	cQuery += " 				AND SA1.A1_LOJA		= F2.F2_LOJA  "
	cQuery += " 				AND SA1.D_E_L_E_T_	= F2.D_E_L_E_T_ " 
	cQuery += " 			WHERE SA1.A1_FILIAL = '' "
	cQuery += " 				AND SA1.A1_MSBLQL = 2 "
	cQuery += " 				AND SA1.D_E_L_E_T_ <> '*' "
	cQuery += " 			GROUP BY (SA1.A1_COD + SA1.A1_LOJA) , SA1.A1_NOME "
	cQuery += " 				) TAB "
	cQuery += "			WHERE TAB.ULTCOM <= '" + dDateCanc + "' "
	cQuery += " 		) INATIVOS "
	cQuery += "		WHERE INATIVOS.CODLOJA NOT IN " 
	cQuery += " 		( "
	cQuery += "			SELECT DISTINCT C5_CLIENT + C5_LOJACLI " 
	cQuery += " 		FROM SC5010 "
	cQuery += "			WHERE C5_FILIAL <> '' "
	cQuery += " 			AND (C5_LIBEROK <> 'E' AND C5_NOTA  = '') "
	cQuery += " 			AND D_E_L_E_T_ <> '*' "
	cQuery += " 		) "
	cQuery += "		) "
	cQuery += "	AND D_E_L_E_T_ <> '*' "
	
	oResultSQL := LibSqlObj():newLibSqlObj()
	oResultSQL:newAlias(cQuery)
	if oResultSQL:hasRecords()
		nQtd := oResultSQL:count()
		oResultSQL:goTop()
		while oResultSQL:notIsEof()
			nRecno := oResultSQL:getValue("RECNO")
			BloqClie(nRecno)
			oResultSQL:skip()
		enddo
	endif	
	oResultSQL:close()
	FreeObj(oResultSQL)
	U_SendMail(_cTo,_cAssunto,cEmailMsg)
    MsgBox("Rotina Finalizada!!" + BR+;
     		"Foram Bloqueados "+ Str(nQtd) + " Clientes!", "Informação", "INFO")
return (.F.)

static function BloqClie(nRecno)
	local aArea		:= GetArea()
    local lRet 		:= .T.
    private cContAnt:= ""
    private oModel, oAux, oStruct
	default nRecno := 0
	
	oModel := FWLoadModel('CRMA980')
	oModel:SetOperation(MODEL_OPERATION_UPDATE)
	oAux 	:= oModel:GetModel('SA1MASTER')
	
	DbSelectarea("SA1")
	SA1->(DbGoTop())
	SA1->(DbGoTo(nRecno))
	if SA1->(Recno()) == nRecno
		Begin Transaction
			oModel:Activate()
			lRet 		:= .T.
		    lRet 		:= ProcUpd(oModel,"A1_MSBLQL", "1") // 1=SIM
		    If lRet
				FWFormCommit(oModel) // Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
				cEmailMsg += "Cliente/Loja : " + SA1->A1_COD + SA1->A1_LOJA + " -  Campo Alterado : A1_MSBLQL" + ;
							"Dado Anterior: 2 - NAO  - Dados Atualizado: 1 - SIM " + BR
				U_GrvZZ1({SA1->A1_COD,SA1->A1_LOJA},"A1_MSBLQL", {"2 - NAO ","1 - SIM "}, 'Alterar', "Bloqueio em lote - ROTINA: cbcAltCliLt()" )
			else
				aErro := oModel:GetErrorMessage()
				cErroMess := "ALTERAÇÃO NÃO REALIZADA PARA O CLIENTE:" + BR
				cErroMess += "Cliente/Loja: " + SA1->A1_COD + "/" + SA1->A1_LOJA + " - " + SA1->A1_NOME + BR
				cErroMess += "Id do formulário de origem:" + ' [' + AllToChar( aErro[1] ) + ']' + BR
				cErroMess += "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' + BR
				cErroMess += "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + ']' + BR
				cErroMess += "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' + BR
				cErroMess += "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' + BR
				cErroMess += "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' + BR
				cErroMess += "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' + BR
				cErroMess += "Valor atribuído: " + ' [' + AllToChar( aErro[8] ) + ']' + BR
				cErroMess += "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']' + BR
				MsgBox(cErroMess , "Atenção !!!", "INFO")
			EndIf
			oModel:DeActivate()
		end Transaction
	endif
	DbClosearea("SA1")
    RestArea(aArea)
    FreeObj(oModel)
return(lRet)
