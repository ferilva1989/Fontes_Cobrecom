#INCLUDE "TOTVS.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE 'Rwmake.ch'

class cbcPrintFromApi 

	data lOk
	data cMsg

	data cPath
	data cSmartClient
	data cFunction
	data cParams
	data cConnection
	data cEnv
	data lRet
	
	method newcbcPrintFromApi() constructor 
	method defFunction()
	method addParams()
	method execFunc()

endclass


method newcbcPrintFromApi(cPath, cSmart, cConn, cEnv, lRet) class cbcPrintFromApi

/* AMBIENTE PRODUÇÂO */
Default cPath	:= GetNewPar('ZZ_ACDSC', 'D:\Totvs_12\ERP\Protheus\bin\smartclient_ACD\')
Default cConn	:= "tcp_acd"
Default cEnv	:= "API_ACD"

/* AMBIENTE HOMOLOGAÇÂO */
//Default cPath 	:= "D:\Totvs_11\Microsiga\Protheus\bin\smartclient_HOM\"
//Default cConn 	:= "tcp_api"
//Default cEnv 	:= "API_ACD_HOM"


Default cSmart 	:= "Smartclient.exe"
Default lRet	:= .F.

::cPath 		:= cPath		
::cSmartClient  := cSmart + " -Q"	
::cFunction		:= ""
::cConnection	:= " -C=" + cConn + " "
::cEnv			:= " -E=" + cEnv	 +  " -M "
::cParams		:= {}
::lRet			:= lret

return (self)


method execFunc() class cbcPrintFromApi
	::lOk 			:= .T.
	::cMsg			:= ""
	If Empty(::cFunction)
		::lOk := .F.
		::cMsg := '[ERRO] - Utilize metodo defFunction(), para definir uma função!!'
	ElseIf Empty(::cParams)
		::lOk := .F.
		::cMsg := '[ERRO] - Utilize metodo addParams(), para definir os parametros da função!!'
	Else
		conout('SRV...._>' + ::cPath + ::cSmartClient + ::cFunction + ::cParams + ::cConnection + ::cEnv)
		WaitRunSrv(::cPath + ::cSmartClient + ::cFunction + ::cParams + ::cConnection + ::cEnv, ::lRet , ::cPath )
	EndIf
	
return (self)


method defFunction(cFunc) class cbcPrintFromApi
	Default cFunc 	:= ""
	::lOk 			:= .T.
	::cMsg			:= ""
	::cFunction		:= ""
	If Empty(cFunc)
		::lOk := .F.
		::cMsg := '[ERRO] - Parametro Obrigatorio!!'
	ElseIf Len(cFunc) > 10
		::lOk := .F.
		::cMsg := '[ERRO] - Funções devem conter no maximo 10 caracteres!'
			
	ElseIf Left(Upper(cFunc),2) != 'U_' 
		::lOk := .F.
		::cMsg := '[ERRO] - Funções de usuario devem iniciar-se com U_ !'
	Else
		::cFunction := '  -P=' + cFunc + ' '
	EndIf
return (self)


method addParams(aPar) class cbcPrintFromApi
	Local nX		:= 0
	default aPar 	:= {}
	::lOk 			:= .T.
	::cMsg			:= ""
	::cParams		:= ""
	If ValType(aPar) != 'A'
		::lOk := .F.
		::cMsg := '[ERRO] - Tipo do parametro deve ser Array!'
	ElseIf Empty(aPar)
		::lOk := .F.
		::cMsg := '[ERRO] - Array de parametros vazio!'
	Else
		::cParams += "  -A="
		For nX := 1 To Len(aPar)
			::cParams += aPar[nX] + ','
		Next nX 
		
		/*OBS: Cadastrar senha do usuario sempre com maiuscula*/
		/* AMBIENTE PRODUÇÂO */
		::cParams += "IFCACD,45CB63," 
		::cParams += "EST"
		
		/* AMBIENTE HOMOLOGAÇÂO */
		//::cParams += "LEO,323847,"
		//::cParams += "FAT "
		
	EndIf
return (self)

/* INSTRUÇÔES ---PARA USAR LEIA!!!!!!!!!
*****************FUNÇÂO DEVE RECEBER UNICO ARRAY PARAMETRO**********
User Function CDRltVol(aInfo)  
Local cOper
Local cNumVol

*****************COLOCAR INICIO DA FUNÇÂO****************************
If !Empty(aInfo)
	aMod 		:= StrTokArr(aInfo, ',')
	//Tratar parametros necessarios a função
	cOper 	:= aMod[1]
	cNumVol	:= aMod[2]

	PREPARE ENVIRONMENT EMPRESA '01' FILIAL aMod[3] USER aMod[4] PASSWORD aMod[5]  MODULO aMod[6]
	//conout('AMBI...._>' + ' cOper: ' + cOper + ' cNumVol: ' + cNumVol + ' FILIAL: ' + aMod[3] + ' USER: ' + aMod[4] + ' PASS: ' + aMod[5] + ' MOD: ' + aMod[6]  )
EndIf

****************COLOCAR FINAL DA FUNÇÂO********************************
If !Empty(aInfo)
	RESET ENVIRONMENT
EndIf


*/