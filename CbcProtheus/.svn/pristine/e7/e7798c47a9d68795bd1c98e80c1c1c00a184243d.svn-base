#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "AutomacaoColetas.ch"
#INCLUDE "CBCREST.ch" 

WSRESTFUL PROCPES DESCRIPTION "Cobrecom - Automacao e Coleta de Dados - Processar Pessagem"
	WSDATA count		AS INTEGER
	WSDATA startIndex	AS INTEGER
	
	WSMETHOD POST DESCRIPTION "Receber dados coletados, para rotina(U_ProcesBal) processar pessagem" WSSYNTAX "/PROCPES"
 
END WSRESTFUL

WSMETHOD POST WSSERVICE PROCPES
Local lPost		:= .T.
Local oOpe		:= Nil
Local cBody		:= ""
Local cHeader	:= ""
Local cFil		:= ""
Local cMsg		:= ""
Local oRes		:= cbcResponse():newcbcResponse() 	//Modelo para  Responses
Local oVldAtt	:= cbcExisteAtt():newcbcExisteAtt() //Validar Atributos da classe
Local oFil		:= cbcFiliais():newcbcFiliais()		//Manipular as filiais
Local oTkn		:= cbcToken():newcbcToken()		//Controle dos tokens
Local oReq		:= Nil
Local aUsr		:= {}
Local cTmp		:= ""
Local nCodErro	:= 0
Local lNewCol   := .F.

//Tipo do conteudo para retorno
::SetContentType("application/json")

//Obter conteudo da requisição
cBody 	:=  ::GetContent()
cFil	:=  ::GetHeader('Filial')
cHeader :=	::GetHeader('Authorization')
lNewCol :=  (::GetHeader('From') == 'newcol')

//Iniciar o processo
If Empty(cHeader) .Or. Empty(cFil)
	cMsg		:= E400
	lPost 		:= .F.
	nCodErro 	:= 400 	
Else
	If Empty(cBody)
		cMsg		:= E407
		lPost 		:= .F.
		nCodErro 	:= 407
	Else
		//Validar Token
		aUsr := oTkn:vldToken(cHeader) 
		If !aUsr[TDOK]
			cMsg		:= aUsr[MOTIVO_NAO_OK]
			lPost 		:= .F.
			nCodErro 	:= 405
		Else
			If FWJsonDeserialize(cBody, @oReq)
				If !Empty(oVldAtt:isAtt(oReq,{'COLETAS'}))
					cMsg		:= E402
					lPost 		:= .F.
					nCodErro 	:= 402
				Else
					If ValType(oReq:COLETAS) != 'A'
						cMsg		:= E408
						lPost 		:= .F.
						nCodErro 	:= 408 
					Else
						//Preparar a Filial
						If !oFil:setFilial(cFil)
							cMsg		:= E403
							lPost 		:= .F.
							nCodErro 	:= 403
						Else								    
						    If GetNewPar('ZR_NEWCOL', .F.) .And. !lNewCol
								cMsg		:= 'Pesagem somente com coletor novo'
								lPost 		:= .F.
								nCodErro 	:= 400 
							Else
								//!U_gravarPes(oReq:COLETAS)
								If  !U_PrBalCol(oReq:COLETAS, aUsr[COD_OP]) 	
									cMsg		:= E700
									lPost 		:= .F.
									nCodErro 	:= 700
								Else
									oRes:sucesso 	:= .T.
									oRes:msg		:= 'Pessagem Processada'
									oRes:body		:= EncodeUTF8('Texto retornado pela função U_ProcesBal') 		
									::SetResponse(oRes:toJson())
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
			Else
				cMsg		:= E404
				lPost 		:= .F.
				nCodErro 	:= 404
			EndIf
		EndIf
	EndIf
EndIf

//Devolve mensagem de erro
If !lPost
	SetRestFault(nCodErro,cMsg)
EndIf

FreeObj(oRes)
FreeObj(oVldAtt)
FreeObj(oFil)
FreeObj(oTkn)

Return lPost
