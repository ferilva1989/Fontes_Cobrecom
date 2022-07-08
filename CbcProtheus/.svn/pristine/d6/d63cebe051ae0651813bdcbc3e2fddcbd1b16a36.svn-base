#include "protheus.ch"
#include "apwebsrv.ch"


/*/{Protheus.doc} WsCbcUser

Usuários do Portal Cobrecom
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcUser
	
	wsData id as string optional
	wsData name as string optional
	wsData lastName as string optional
	wsData login as string optional
	wsData password as string optional
	wsData email as string optional
	wsData department as string optional
	wsData group as string optional
	wsData groupName as string optional
	wsData customer as WsCbcCustomer optional
	wsData seller as WsCbcSeller optional
	wsData erpId as string optional
	wsData isBlocked as boolean optional	
	wsData lastLogin as date optional
	wsData isUseTerms as boolean optional
	wsData isApprover as boolean optional
	wsData showDashboard as boolean optional
	wsData approverProfile as WsCbcApproverProfile optional
	wsData uploadToken as string optional
	
endWsStruct


/*/{Protheus.doc} WsCbcSeller

Vendedores do Portal Cobrecom
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcSeller
	
	wsData id as string optional
	wsData name as string optional
	wsData email as string optional
	wsData ddd as string optional
	wsData phone as string optional
	wsData isFired as boolean optional
	wsData branches as array of WsCbcBranch optional
	
endWsStruct


/*/{Protheus.doc} WsCbcApproverProfile

Perfil dos Aprovadores
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcApproverProfile
	
	wsData minValue as float optional
	wsData maxValue as float optional
	wsData minRg as float optional
	wsData maxRg as float optional
	wsData minDiscount as float optional
	wsData maxDiscount as float optional
	wsData minCommission as float optional
	wsData maxCommission as float optional
	wsData canStealApproval as boolean optional
	wsData canApproveBonus as boolean optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestUserById

Requisição de Usuários pelo Código
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestUserById
	
	wsData id as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseUserById

Retorno de Usuários pelo Código
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseUserById
	
	wsData status as WsCbcResponseStatus
	wsData user as WsCbcUser optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestUserByLogin

Requisição de Usuários pelo Login e Senha
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestUserByLogin
	
	wsData login as string
	wsData password as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseUserByLogin

Retorno de Usuários pelo Login e Senha
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseUserByLogin
	
	wsData status as WsCbcResponseStatus
	wsData user as WsCbcUser optional
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestCreateUser

Requisição de Criação de Usuários
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestCreateUser
	
	wsData user as WsCbcUser
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseCreateUser

Retorno de Criação de Usuários
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseCreateUser
	
	wsData status as WsCbcResponseStatus
	wsData userId as string optional	
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestUpdateUser

Requisição de Atualização de Usuários
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestUpdateUser
	
	wsData user as WsCbcUser
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseUpdateUser

Retorno de Atualização de Usuários
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseUpdateUser
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestPasswordRecovery

Requisição de Recuperação de Senha de Usuários
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestPasswordRecovery
	
	wsData email as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponsePasswordRecovery

Retorno de Recuperação de Senha de Usuários
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponsePasswordRecovery
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestAcceptUseTerms

Requisição de Aceite dos Termos de Uso
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestAcceptUseTerms
	
	wsData userId as string
	wsData accepted as boolean
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseAcceptUseTerms

Retorno de Aceite dos Termos de Uso
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseAcceptUseTerms
	
	wsData status as WsCbcResponseStatus
	
endWsStruct


/*/{Protheus.doc} WsCbcRequestLogout

Requisição de Logout do Portal
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcRequestLogout
	
	wsData userId as string
	
endWsStruct


/*/{Protheus.doc} WsCbcResponseLogout

Retorno de Logout do Portal
	
@author victorhugo
@since 24/02/2016
/*/
wsStruct WsCbcResponseLogout
	
	wsData status as WsCbcResponseStatus
	
endWsStruct

