#include 'protheus.ch'
#define DOMINIO_EMPRESA  'COBRECOM.COM.BR'
#define END_EMAIL	2
#define ISVLD		1


/*/{Protheus.doc} emailBounce
@author bolognesi
@since 15/12/2016
@version 1.0
@type class
@description Classe para validar emails, validações realizadas
Formato de email isEmail()
Pela API externa apilayer.net
/*/
class emailBounce from errLog
	data aToValid
	data lApi
	data lStr   		//Validou a grafia do Email
	data aApiVld		//Validou o email na API
	data aStrVld		//Email com escrita errada
	data lExpKey		//Identifica se expirou consultas na chave
	data lOk			//Status Final
	data cMsg			//Mensagem status
	data lExeStr		//Executou processo validar string
	data cEmailOk		//String onde todos os emails são validos
	data lOn			//Indica se a classe esta Ativa ou não (MV_EMLBNCE)

	method newemailBounce() constructor
	method getToValid()
	method setToValid() 
	method vldStrEmail()
	method vldApiLayer()
	method allValid()
	method getResult()
	method getErrStr()

endclass

/*/{Protheus.doc} newemailBounce
@author bolognesi
@since 15/12/2016
@version 1.0
@type method
@description Construtor da classe
/*/
method newemailBounce(cEmail, lApi) class emailBounce
	Default cEmail 	:= "" //Opcional
	Default lApi 	:= .T.	
	//Inicializar Herança
	::newerrLog('Bounce')

	//Indica se consulta ou não a API
	::lApi 		:= lApi
	::lStr 		:= .F.
	::lExpKey	:= .T.
	::aApiVld 	:= {}
	::aStrVld	:= {}
	::lExeStr	:= .F.
	::lOn		:= GetNewPar('MV_EMLBNCE', .T.)

	If Empty(cEmail)
		::aToValid := {}
	Else	
		::allValid(cEmail)
	EndIf
return(self)

/*/{Protheus.doc} getResult
@author bolognesi
@since 15/12/2016
@version undefined
@type method
@description Metodo para obter o resultado do processo
/*/
method getResult() class emailBounce
	Local nX 		:= 0
	Local aEmVld	:= {}

	::lOk 		:= .T.
	::cMsg 		:= ''

	If ::lOn
		::cEmailOk 	:= ""

		//Validação de Erros
		If !::itsOk() 
			::lOk := .F.
			::cMsg := ::getMsgLog()
			::cEmailOk 	:= "wfti@cobrecom.com.br"
		Else
			//Validação da escrita do endereço
			If !::lStr
				::lOk := .F.
				For nX := 1 To Len(::aStrVld)
					If ! ::aStrVld[nX][ISVLD]
						::cMsg +=  ' [ INVÁLIDO ] -->(' + ::aStrVld[nX][END_EMAIL] + ')' + chr(13)
					EndIf
				Next nX
			EndIf
			//Validações API
			If ::lApi
				For nX := 1 To Len(::aApiVld)
					If ! ::aApiVld[nX][ISVLD]
						::lOk := .F.
						::cMsg +=  ' [ INEXISTENTE ] -->(' + ::aApiVld[nX][END_EMAIL] + ')' + chr(13)
					Else
						AAdd(aEmVld, Alltrim(lower(::aApiVld[nX][END_EMAIL])) )
					EndIf
				Next nX	
				If !Empty(aEmVld)
					For nX := 1 To Len(aEmVld)
						::cMsg +=  ' [ EMAIL OK ] -->(' +  aEmVld[nX] + ')' + chr(13)
						::cEmailOk += aEmVld[nX] + IIF(Len(aEmVld) == nX ,'',';' )
					Next nX
				EndiF
			EndIF
		EndIf
	EndIf
return(self)

/*/{Protheus.doc} getErrStr
@author bolognesi
@since 23/12/2016
@version 1.0
@type method
@description percorre o array com os emails de erro na
escrita e caso um apresente erro considera que teve um erro
eliminado os emails com erro de escrita para não enviar
invalidos a API externa
/*/
method getErrStr() class emailBounce
	Local nX		:= 0
	Local aVld		:= {}
	::lStr			:= .T.   
	For nX := 1 to Len(::aStrVld)
		If ! ::aStrVld[nX][ISVLD]
			::lStr := .F.
		Else
			AAdd(aVld,::aStrVld[nX][END_EMAIL])
		EndIf
	Next nX
	If !Empty(aVld)
		::aToValid := aVld
	EndIf
return(self)

/*/{Protheus.doc} allValid
@author bolognesi
@since 15/12/2016
@version 1.0
@type method
@description centraliza todas as validações
/*/
method allValid(cEmail) class emailBounce
	Default cEmail 	:= ""	
	::clearStatus()
	::aApiVld 		:= {}
	::lExpKey 		:= .T.
	::lExeStr		:= .F.

	//A Classe esta deligada pelo paramtero
	If !::lOn
		::lOk 		:= .T.
		::cMsg 		:= ''
		::cEmailOk 	:= cEmail 
	ElseIf Empty(cEmail)
		::setStatus( .F.,'CBC600' ,'[ERRO] -Allvalid(cEmail), parametro obrigatorio!')
	Else
		If ::setToValid(cEmail):itsOk()
			If ::vldStrEmail(::getToValid()):itsOk()
				::vldApiLayer()
			EndIf
		EndIf
	EndIF
	::getResult()
return (self)

/*/{Protheus.doc} getApiLayer
@author bolognesi
@since 15/12/2016
@version 1.0
@type method
@description Validar o e-mail na API externa
/*/
method vldApiLayer() class emailBounce
	Local bErro		:= Nil
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, self,)})
	BEGIN SEQUENCE
		If ::lApi
			//Não definiu email para validar
			If Empty(::getToValid())
				::setStatus( .F.,'CBC601', 'Definir email para validar utilizando metodo setToValid(cEmail)!')
			Else
				//Não Passou pela validação de String
				If !::lExeStr
					::vldStrEmail(::getToValid())
				EndIf
			EndIf
			//Chamar a API somente se estiver tudo certo
			If ::itsOk()
				getApiLayer(self)
			EndIf 
		EndIf
		RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
return(self)

/*/{Protheus.doc} vldStrEmail
@author bolognesi
@since 15/12/2016
@version 1.0
@param xEmail, , Array ou caractere contendo email para validar
@type method
/*/
method vldStrEmail(xEmail) class emailBounce
	Local bErro		:= Nil
	Local cTipo		:= ""
	Local nX		:= 0
	Default xEmail 	:= ""
	::aStrVld 		:= {}
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, self,)})
	BEGIN SEQUENCE
		If Empty(xEmail)
			::setStatus( .F.,'CBC602' ,'vldStrEmail(xEmail) -> Parametro obrigatorio!')
		Else
			cTipo := ValType(xEmail)
			If cTipo == 'A'
				For nX := 1 To Len(xEmail)
					If IsEmail(xEmail[nX])
						AAdd(::aStrVld, {.T.,xEmail[nX], 'STR' })
					Else
						AAdd(::aStrVld, {.F.,xEmail[nX], 'STR' })
					EndIF
				Next nX
			ElseIF cTipo == 'C'
				If IsEmail(xEmail)
					AAdd(::aStrVld, {.T., xEmail, 'STR' })
				Else
					AAdd(::aStrVld, {.F., xEmail, 'STR' })
				EndIF
			Else
				::setStatus( .F.,'CBC603' ,'vldStrEmail(xEmail) -> Parametro tem quer ser Caractere ou Array!')
			EndIF
		EndIf
		RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
	::getErrStr()
	::lExeStr	:= .T.
return (self)

/*/{Protheus.doc} getToValid
@author bolognesi
@since 15/12/2016
@version 1.0
@type method
@description obter a propriedade ::aToValid 
/*/
method getToValid() class emailBounce
return( ::aToValid )

/*/{Protheus.doc} setToValid
@author bolognesi
@since 15/12/2016
@version 1.0
@param cEmail, characters, Email a ser validado
@type method
@description Define o conteudo da propriedade aToValid
que é um array que contem os e-mails a serem validados
mais de um e-mail deve vir separado por ; no parametro cEmail 
/*/
method setToValid(cEmail) class emailBounce
	Local bErro		:= Nil
	Local nDotSlsh 	:= ""
	Local nPos		:= 0
	Local aTmp		:= {}
	Default cEmail 	:= ""

	::aToValid := {}

	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, self,)})
	BEGIN SEQUENCE
		If Empty(cEmail)
			::setStatus( .F.,'CBC604' ,'Parametro Obrigatorio!')
		ElseIf ValType(cEmail) != 'C'
			::setStatus( .F.,'CBC605' ,'Parametro tem que ser caractere!')
		Else
			//Transformar virgula em ponto e virgula
			StrTran(cEmail,",",";")
			//Verificar se tem ponto e virgula
			nDotSlsh 	:= U_contaChar(cEmail, ';')
			If	nDotSlsh > 0
				aTmp := StrTokArr(cEmail,';')
			Else
				AAdd(aTmp, cEmail)
			EndIf
			//Retirar do array valores repetidos
			For nX := 1 To Len(aTmp)
				nPos := AScan(::aToValid,{|a| Alltrim(a) == Alltrim(aTmp[nX]) })
				If nPos == 0
					AAdd(::aToValid, aTmp[nX] )
				EndIf
			Next nX
		EndIf
		RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
return (self)

/*/{Protheus.doc} getApiLayer
@author bolognesi
@since 15/12/2016
@version 1.0
@param oSelf, object, Objeto que representa a classe
@type function
@description realiza a chamada para a API externa
/*/
Static function getApiLayer(oSelf)
	Local oRst		:= Nil 
	Local oObj		:= Nil
	Local nPos		:= 0
	Local aErro		:= {}
	Local aKey		:= {}
	Local aEmail	:= {}
	Local nI		:= 0
	Local nX		:= 0
	Local lEsgotou	:= .F.
	Local lErro 	:= .F.
	Local cCatch	:= '1'
	Local bErro		:= Nil
	Local aDominio	:= {}
	Local lErro		:= .F.

	oself:lExpKey 	:= .T.
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr, oSelf,)})
	BEGIN SEQUENCE
		//Obter as chaves de acesso
		aKey := maBoxLyr()

		//Obter os Arrays com os Emails para validar
		aEmail := oSelf:getToValid()
		For nI := 1 To Len(aEmail)
			aDominio := StrTokArr(aEmail[nI],'@')
			If DOMINIO_EMPRESA $ Upper(aDominio[2])
				//Cobrecom não deve consultar a API externa
				AAdd(oself:aApiVld, {.T., aEmail[nI], 'API' })
			Else 
				For nX := 1 To Len(aKey)
					lEsgotou := .F.
					oRst := FWRest():New("https://apilayer.net")
					oRst:setPath("/api/check?access_key="+ aKey[nX] + "&email=" + aEmail[nI] + "&catch_all="+ cCatch +"&smtp=1&format=1")

					//Chamar a API
					If oRst:Get()
						//Obter o objeto de retorno
						FWJsonDeserialize(oRst:GetResult(), @oObj)

						//Verificar por erros
						//Tem Erro
						If AttIsMemberOf(oObj,'error')
							AAdd(aErro, {404,'Não encontrado'} )
							AAdd(aErro, {101,'Problemas com KEY'} )
							AAdd(aErro, {102,'Usuario inativo'} )
							AAdd(aErro, {103,'Função da API Invalida'} )
							AAdd(aErro, {104,'Esgotou limite'} )
							AAdd(aErro, {105,'HTTPS não suportado'} )
							AAdd(aErro, {210,'Sem email para consultar'} )
							AAdd(aErro, {310,'Problemas com plano free não suporta catch-all detection'} )
							//Obter a descrição do erro
							nPos := AScan(aErro,{|a| a[1] == oObj:ERROR:CODE })
							//Tipo do Erro
							//Limite consultas exedido (Passa proxima interação no loop)
							If oObj:ERROR:CODE == 104
								lEsgotou := .T.
								loop //Somente continua no loop se chave for invalida
								//Outros error (Não continua para outra chave, sair do loop)
							Else
								If nPos > 0
									oself:setStatus( .F.,'CBC606'  ,aErro[nPos][2])
								Else
									oself:setStatus( .F.,'CBC607' ,'getApiLayer - ERRO indefinido')
								EndIF
								exit
							EndIf
							//Não tem Erro	
						Else
							//Verificar estrutura do retorno (Tem que ter propriedade SMTP_CHECK)
							If !AttIsMemberOf(oObj,'SMTP_CHECK')
								oself:setStatus( .F.,'CBC608' ,'getApiLayer RETORNO API-SMTP-CHECK')
							Else
								//Propriedade SMTP_CHECK precisa ser do tipo logico
								If ValType(oObj:SMTP_CHECK) != 'L'
									oself:setStatus( .F.,'CBC609' ,'getApiLayer RETORNO API-SMTP_CHECK -NÃO LOGICO')
								Else
									//Obter o retorno se o e-mail é valido( .T. ) ou não ( .F. )
									If !oObj:SMTP_CHECK
										AAdd(oself:aApiVld, {.F., aEmail[nI], 'API' })
										lErro := .T.
									Else
										AAdd(oself:aApiVld, {.T., aEmail[nI], 'API' })
									EndIf
								EndIf
							EndIf
						EndIf
					Else
						oself:setStatus( .F.,'CBC610' ,'Falha na comunicação com a API MailLayer, verificar rede!')
					EndIf
					exit
				Next nX
			EndIf
			//Esgotou todas as chaves, nenhuma esta valida
			If lEsgotou
				oself:setStatus( .F.,'CBC611' ,'Esgotou o limite de todas as chaves da API MailLayer!')
				oself:lExpKey := .F.
				exit
			EndIf
		Next nI

		FreeObj(oObj)
		FreeObj(oRst)

		RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
return (NIl)

/*/{Protheus.doc} maBoxLyr
@author bolognesi
@since 15/12/2016
@version 1.0
@type function
@description Obter a chave de acesso para consultar a API
/*/
static Function maBoxLyr()
	Local aKey := {}
	Local oFile	:= Nil
	Local cFile	:= "\mailBoxLayer\keys.json"
	Local cJson	:= ""	
	Local oJson	:= Nil

	oFile := FwFileReader():New(cFile)	

	If ! oFile:Open()
		AAdd(aKey,'4f5db2f082cfca09158bc1d722b753f2')
		AAdd(aKey,'0a39c9e5f3670f47da2936ce9b048f1f')
		AAdd(aKey,'210c9bd62c163dcad57405a427362b4b')
		AAdd(aKey,'3c95244d32ce1e2078bc7f5a17e0f57b')
	Else
		While (oFile:hasLine())
			cJson += oFile:GetLine()
		End
		oFile:Close()
		FwJsonDeserialize(cJson, @oJson)
		For nX := 1 To Len(oJson:KEY)
			If oJson:KEY[nX]:VLD
				AAdd(aKey,oJson:KEY[nX]:VALOR)
			Else
				//TODO Desenvolver a logica CASO NÂO FOR COMPRAR
				/*
				//Toda vez que bloqueia uma chave coloca a data do primeiro dia do proximo
				//mês, se a data a tual for maior ou igual ao NEXT já recarregou
				If  Date() >= oJson:KEY[nX]:NEXT
				AAdd(aKey,oJson:KEY[nX]:VALOR)
				oJson:KEY[nX]:VLD := .T.
				oJson:KEY[nX]:NEXT := ""
				EndIf
				*/
			EndIf
			//TODO salvar o oJson em disco novamente
			//oJson:KEY[nX]:NEXT := Date()
		Next nX
	EndIf

	FreeObj(oFile)
	FreeObj(oJson)
return aKey

/*/{Protheus.doc} HandleEr
@author bolognesi
@since 15/12/2016
@version 1.0
@param oErr, object, Objeto contendo o erro
@param oSelf, object, Objeto representa esta classe
@type function
@description Tratamento de erros da classe
/*/
Static function HandleEr(oErr, oSelf)
	oSelf:setStatus( .F.,'CBC612' ,'[' + oErr:Description + ']', oErr:ERRORSTACK)
	BREAK
return

/*/{Protheus.doc} zVldMail
@author bolognesi
@since 16/12/2016
@version 1.0
@param cEmail, characters, Email a ser validado
@param lApi,   logico, Indica se deve utilizar validação da API externa( .T. )
informando .F. somente irá validar mascara da string de email, informando .T.
além da mascara ira validar a existencia na API externa Default é ( .T. ).
@type function
@description Encapsular as funcionalidades da classe em um função
para utilizar onde precisar sendo o retorno um Array de 3 posições:
{logico Status, Mensagem de status, Expirou chave de acesso}
/*/
User Function zVldMail(cEmail) 	//u_zVldMail('eletrosol@hotmail.com;leonardonhesi@gmail.com')
Local oVldEmail 	:= Nil
Default cEmail		:= ""
oVldEmail 			:= emailBounce():newemailBounce()
cEmail := Alltrim(lower(cEmail))
If ! oVldEmail:allValid(cEmail):lOk
	Alert('STATUS ' + oVldEmail:cMsg )
EndIf
Alert('CORRETOS ' + oVldEmail:cEmailOk )
return(Nil)
