#include 'protheus.ch'
#define GRP_SYSADM '000000'
#define GRP_GESTAO_VENDAS '000039'
#define GRP_DIR_COMERCIAL '000047'
#define GRP_ATENDENTES_VENDAS '000041'
#define GRP_TROCA_COMIS '000086'
#define GRP_EDIT_APROV '000087'
#define GRP_EDIT_FORNECE '000089'
#define GRP_LIBERA_EMPENHA '000110'
#define GRP_EDITA_POUSO_ALEGRE '000121'
#define GRP_EDIDOC '000123'
#define GRP_VEWFOL '000124'
#define GRP_TRANSFFULL '000125'
#define GRP_POS_CLI   '000126'
#define GRP_EMPENHA_ITU '000127'
#define GRP_EMPENHA_TL '000128'
#define GRP_EMPENHA_MG '000129'
#define GRP_NOVO_CAD_CLI '000131'

/*/{Protheus.doc} cbcAcl
@author bolognesi
@since 10/02/2017
@version 1.0
@type class
@description Classe para centralizar 
rotinas e validações de acesso.
/*/
class cbcAcl 
	data cAlert
	method newcbcAcl() constructor 
	method aclValid()
	method getAlert()
	method setAlert()
	method usrIsGrp()
endclass

method newcbcAcl() class cbcAcl
	cAlert := ''
return

/*/{Protheus.doc} aclValid
@author bolognesi
@since 10/02/2017
@version undefined
@param cCod, characters, Nome do menu
@type method
@description Utilizado no acesso aos menus do Portal
decidindo para cada menu quais grupos tem acessos
/*/
method aclValid(cCod) class cbcAcl
	local lRet		:= .F.
	local cAlert	:= '[AVISO] - ACESSO NEGADO !'

	//APROVADORES
	if cCod == 'CadAprPort'
		lRet := ::usrIsGrp({GRP_SYSADM, GRP_EDIT_APROV})
		//USUARIOS
	elseif cCod == 'CadUsrPort'
		lRet := ::usrIsGrp({GRP_SYSADM,GRP_GESTAO_VENDAS})
		//EVENTOS
	elseif cCod =='CadCfgEvt'
		lRet := ::usrIsGrp({GRP_SYSADM})
		//MENSAGENS
	elseif cCod == 'CadMsgPort'
		lRet := ::usrIsGrp({GRP_SYSADM})
		//NOTIFICAÇÔES
	elseif cCod == 'CadNotPort'
		lRet := ::usrIsGrp({GRP_SYSADM,GRP_GESTAO_VENDAS})
		//CONCORRENTES
	elseif cCod == 'CadConcor'
		lRet := ::usrIsGrp({GRP_SYSADM,GRP_GESTAO_VENDAS,GRP_DIR_COMERCIAL})
		//REGRA COND.PAGAMENTO
	elseif cCod == 'CadCondPgt'
		lRet := ::usrIsGrp({GRP_SYSADM,GRP_GESTAO_VENDAS,GRP_DIR_COMERCIAL})
		//REGRA VALOR MINIMO
	elseif cCod == 'CadVlrMin'
		lRet := ::usrIsGrp({GRP_SYSADM,GRP_GESTAO_VENDAS,GRP_DIR_COMERCIAL})
		//RESERVAS PORTAL
	elseif cCod == 'CadResPort'
		lRet := ::usrIsGrp({GRP_SYSADM,GRP_GESTAO_VENDAS,GRP_DIR_COMERCIAL,GRP_ATENDENTES_VENDAS})
		//ORÇAMENTO PORTAL
	elseif cCod == 'CadOrcPort'
		lRet := (::usrIsGrp({GRP_SYSADM,GRP_GESTAO_VENDAS,GRP_DIR_COMERCIAL,GRP_ATENDENTES_VENDAS});
		.or.  __cUserId $ GetMv("ZZ_USAPRTE"))
		//RELATORIO ORÇAMENTO PORTAL
	elseif cCod ==  'RelOrcPort'
		lRet := (::usrIsGrp({GRP_SYSADM,GRP_GESTAO_VENDAS,GRP_DIR_COMERCIAL,GRP_ATENDENTES_VENDAS}))
		//MANUTENÇÂO SCHEDULE/EMAIL
	elseif cCod == 'cbcCadSch'
		lRet := ::usrIsGrp({GRP_SYSADM})
		//TROCA COMISSÃO
	elseif cCod == 'Comissao'
		if!(lRet := ::usrIsGrp({GRP_SYSADM,GRP_TROCA_COMIS}))
			cAlert := '[AVISO] - ACESSO NEGADO - TROCA DE COMISSÃO!'
		endif
		// CADASTRO DE MEDIAS DE COND PAGAMENTO X CLIENTES
	elseif cCod == 'CadMedCondPagto'
		if!(lRet := ::usrIsGrp({GRP_SYSADM,GRP_GESTAO_VENDAS,GRP_DIR_COMERCIAL}))
			cAlert := '[AVISO] - ACESSO NEGADO!'
		endif
		// EDITAR CADASTRO FORNECEDORES
	elseif cCod == 'Mata020'
		lRet := ::usrIsGrp({GRP_SYSADM,GRP_EDIT_FORNECE})
	//ACESSAR OU REALIZAR EMPENHOS
	elseif cCod == 'LibEmpPedido'
		lRet := ::usrIsGrp({GRP_SYSADM,GRP_LIBERA_EMPENHA})
	elseif cCod == 'EmpenhaFil01' 
		lRet := ::usrIsGrp({GRP_SYSADM,GRP_EMPENHA_ITU})
	elseif cCod == 'EmpenhaFil02'
		lRet := ::usrIsGrp({GRP_SYSADM,GRP_EMPENHA_TL})
	elseif cCod == 'EmpenhaFil03'
		lRet := ::usrIsGrp({GRP_SYSADM,GRP_EMPENHA_MG})
	elseif cCod == 'EditPousoAlegre'
		if !(lRet := ::usrIsGrp({GRP_SYSADM,GRP_EDITA_POUSO_ALEGRE}))
			cAlert := '[AVISO] - Operação não permitida para o usuario!'
		endif
	// EDITAR DOCUMENTO SAIDA 
	elseif cCod == 'EditDocSaida'
		if !(lRet := ::usrIsGrp({GRP_SYSADM,GRP_EDIDOC}))
			cAlert := '[AVISO] - Operação não permitida para o usuario!'
		endif
	// VISUALIZAR CDFINA08
	elseif cCod == 'ViewPgInfo'
		if !(lRet := ::usrIsGrp({GRP_SYSADM,GRP_VEWFOL}))
			cAlert := '[AVISO] - Operação não permitida para o usuario!'
		endif
	elseif cCod == 'TransferFull'
		if !(lRet := ::usrIsGrp({GRP_SYSADM,GRP_TRANSFFULL}))
			cAlert := '[AVISO] - Operação não permitida para o usuario!'
		endif
	elseif cCod == 'posCliente'
		if !(lRet := ::usrIsGrp({GRP_POS_CLI, GRP_SYSADM}))
			cAlert := '[AVISO] - Operação não permitida para o usuario!'
		endif
	elseif cCod == 'newCadCliente'
		if !(lRet := ::usrIsGrp({GRP_NOVO_CAD_CLI, GRP_SYSADM}))
			cAlert := '[AVISO] - Operação não permitida para o usuario!'
		endif
	endif
	if !lRet
		::setAlert(cAlert)
	endif	
return(lRet)

/*/{Protheus.doc} getAlert
@author bolognesi
@since 10/02/2017
@version 1.0
@type method
@description obter a descrição do erro para mensagem
/*/
method getAlert() class cbcAcl
return(::cAlert)

/*/{Protheus.doc} setAlert
@author bolognesi
@since 10/02/2017
@version 1.0
@param cAlrt, characters, texto para atribir no alerta
@type method
@description Definir qual o texto de alerts
/*/
method setAlert(cAlrt) class cbcAcl
	default cAlrt := ''
	::cAlert := cAlrt
return (self)

/*/{Protheus.doc} usrIsGrp
@author bolognesi
@since 10/02/2017
@version undefined
@param aSchGrp, array, Array com os codigos dos grupos a pesquisar
@type method
@description Recebe um array de codigos de grupos e verifica se o usuario
atual faz parte de algum deles 
/*/
method usrIsGrp(aSchGrp) class cbcAcl
	local aGrp		:= {}
	local nPos		:= 0
	local lRet		:= .F.
	local nX		:= 0
	default aSchGrp	:= {}
	if !U_isAuto()
		aGrp		:= FWSFUsrGrps(RetCodUsr())
		for nX := 1 to len(aSchGrp)
			nPos := AScan(aGrp,{|a| a == aSchGrp[nX] })
			if nPos > 0
				lRet := .T.
				exit
			endif
		next nX
	endif
return(lRet)
