#include 'protheus.ch'
#include 'fileio.ch'

#define AMBIENTE 6
#define FUNCAO	5
#define USUARIO 1
#define SERVIDOR 4
#define OBS		11
#define	COL_DATA	1
#define COL_HORA	2
#define COL_USUARIO	3
#define COL_ROTINA	4
#define	COL_OBS		5
#define ROTINA		2
#define ROT			1
#define OBSERVACAO	2
#define	OBSERV		4

/*/{Protheus.doc} cbcLicense
@author bolognesi
@since 13/07/2017
@version 1.0
@type class
@description Classe para obter e tratar as informações mostradas no monitor
persistindo estes registro de forma incremental em um arquivo xml(formatado para abrir Excel)
/*/
class cbcLicense 
	data cPath
	data aUserInfo
	data aTrataInf
	data nTotalLic
	data oExcel
	method newcbcLicense() constructor
	method defInfUser()
	method trataInfo()
	method initExcel() 
	method readOld()
	method addLine()
	method writeNew()
	method endExcel()
	method defaulFlow()
endclass

/*/{Protheus.doc} newcbcLicense
@author bolognesi
@since 13/07/2017
@version 1.0
@param cPath, characters, Path para a gravação o arquivo
@type method
@description Inicializador da classe
/*/
method newcbcLicense(cPath) class cbcLicense
	default cPath := "\relato_licence.xml"
	::cPath		:= cPath
	::aUserInfo := {}
	::aTrataInf	:= {}
	::nTotalLic	:= 0
	::initExcel()
return(self)

/*/{Protheus.doc} defInfUser
@author bolognesi
@since 13/07/2017
@version 1.0
@type method
@description Obter conteudo para propriedade ::aUserInfo
utilizando função interna GetUserInfoArray(), que retorna todas as
informações mostradas no monitor en forma de array.
/*/
method defInfUser() class cbcLicense
	::aUserInfo := GetUserInfoArray()
return(self)

/*/{Protheus.doc} trataInfo
@author bolognesi
@since 13/07/2017
@version 1.0
@type method
@description Trata o conteudo da propriedade ::aUserInfo
ordenando as informações por usuario e extraindo apenas algumas posições da propriedade ::aUserInfo
apos este tratamento frava o resultado na propriedade ::aTrataInf
/*/
method trataInfo() class cbcLicense
	local aInf		:= ::aUserInfo
	local nX		:= 0
	local nPos		:= 0
	local aRet		:= {}
	local nTotUsr	:= 0
	for nX := 1 to len(aInf)
		if !empty(aInf[nX, AMBIENTE]) .and. !empty(aInf[nX, FUNCAO])
			nPos := AScan(aRet,{|a| a[USUARIO] == aInf[nX,USUARIO] })
			if nPos > 0
				aadd(aRet[nPos,2],; 
				{aInf[nX,SERVIDOR],aInf[nX,FUNCAO],aInf[nX,AMBIENTE],aInf[nX,OBS]})

				aRet[nPos,3]++
				::nTotalLic++
			else
				aadd(aRet,{aInf[nX,USUARIO],;
				{{aInf[nX,SERVIDOR],aInf[nX,FUNCAO],aInf[nX,AMBIENTE],aInf[nX,OBS]}},1})

				nTotUsr++
				::nTotalLic++
			endif
		endif
	next nX
	aadd(::aTrataInf, {aRet,nTotUsr})
return(self)

/*/{Protheus.doc} initExcel
@author bolognesi
@since 13/07/2017
@version 1.0
@type method
@description Inicializa o excel, utilizando a classe FwMsExcel()
e tambem já define estrutura/cabeçalho das colunas.
/*/
method initExcel() class cbcLicense
	::oExcel := FwMsExcel():New()
	::oExcel:AddworkSheet('LICENCE')
	::oExcel:AddTable ('LICENCE','LICENCE')
	::oExcel:AddColumn('LICENCE','LICENCE',"Data",1,1)
	::oExcel:AddColumn('LICENCE','LICENCE',"Hora",2,2)
	::oExcel:AddColumn('LICENCE','LICENCE',"Usuario",2,2)
	::oExcel:AddColumn('LICENCE','LICENCE',"Rotina",2,2)
	::oExcel:AddColumn('LICENCE','LICENCE',"Obs",2,2)
return(self)

/*/{Protheus.doc} readOld
@author bolognesi
@since 13/07/2017
@version 1.0
@type method
@description Realiza a leitura do arquivo definido na propriedade
::cPath, e caso exista carrega as informações para concatenar na nova gravação
/*/
method readOld() class cbcLicense
	local oXml		:= nil
	local cXmlErr	:= ''
	local cXmlWrn	:= ''
	local aLinhas	:= {}
	local aLinha	:= {}	
	if !empty(oXml := XmlParserFile(::cPath, ' ', @cXmlErr, @cXmlWrn))
		aLinhas := oXml:_WORKBOOK:_WORKSHEET:_TABLE:_ROW 
		for nY := 3 to len(aLinhas)
			If AttIsMemberOf(aLinhas[nY],'_CELL')
				aLinha   := aLinhas[nY]:_CELL				
				::addLine({Alltrim(AlltoChar(aLinha[COL_DATA]:_DATA:TEXT)),;
				Alltrim(AlltoChar(aLinha[COL_HORA]:_DATA:TEXT)),;
				Alltrim(AlltoChar(aLinha[COL_USUARIO]:_DATA:TEXT)),;
				Alltrim(AlltoChar(aLinha[COL_ROTINA]:_DATA:TEXT)),;
				Alltrim(AlltoChar(aLinha[COL_OBS]:_DATA:TEXT))})
			endif
		next nY
		FreeObj(oXml)
	endif
return(self)

/*/{Protheus.doc} addLine
@author bolognesi
@since 13/07/2017
@version 1.0
@param aLinha, array, Array contendo os dados equivalente aos definidos no metodo
AddColumn, chamado na classe initExcel()
@type method
/*/
method addLine(aLinha) class cbcLicense
	::oExcel:AddRow('LICENCE','LICENCE',aLinha )
return(self)

/*/{Protheus.doc} writeNew
@author bolognesi
@since 13/07/2017
@version 1.0
@type method
@description Grava as informações tratadas na propriedade ::aTrataInf
no arquivo Excel
/*/
method writeNew() class cbcLicense
	local nX 		:= 0
	local nY 		:= 0
	local aCabLin	:= {}
	local aRetFina	:= {}
	local aLinha	:= {}
	aRetFina		:= ::aTrataInf
	for nX := 1 to len(aRetFina[1,1])
		aCabLin	:= {}
		aadd(aCabLin, DtoC(Date()))
		aadd(aCabLin,Time())
		aadd(aCabLin,aRetFina[1,1,nX,1])
		for nY := 1 to len(aRetFina[1,1,nX,2])  
			aLinha := {}
			aadd(aLinha,aRetFina[1,1,nX,2,nY,ROTINA])
			aadd(aLinha,aRetFina[1,1,nX,2,nY,OBSERV])				

			::addLine({ aCabLin[COL_DATA],aCabLin[COL_HORA],aCabLin[COL_USUARIO],;
			aLinha[ROT], aLinha[OBSERVACAO] })

		next nY
	next nX
return(self)

/*/{Protheus.doc} endExcel
@author bolognesi
@since 13/07/2017
@version 1.0
@type method
@description Finaliza o Arquivo excel apagando o arquivo existente
e gravando o novo com as informações concatenadas
/*/
method endExcel() class cbcLicense
	FErase(::cPath)
	::oExcel:Activate()
	::oExcel:GetXMLFile(::cPath)
	::initExcel()
return(self)

/*/{Protheus.doc} defaulFlow
@author bolognesi
@since 13/07/2017
@version 1.0
@type method
@description Contem as chamadas em ordem defaul, ao proposito
da classe, centralizando tudo em uma chamada, isso deve atender 
a maioria dos casos de utilização desta classe.
/*/
method defaulFlow() class cbcLicense
	if !LockByName('COLETA_LICENCA', .F. , .F. )
		ConsoleLog('Outra rotina já esta utilizando a classe!!')
	else
		::defInfUser()
		::trataInfo()
		::readOld()
		::writeNew()
		::endExcel()
		UnLockByName('COLETA_LICENCA', .F. , .F. )
	endif
return(self)


/*/{Protheus.doc} xGetLic
@author bolognesi
@since 13/07/2017
@version 1.0
@param cTxt, characters, Complemento adicionado ao nome do arquivo em disco
@type function
@description Inicializa o processo da classe.
/*/
user function xGetLic(cTxt) //U_xGetLic()
	local cPath		:= ''
	local oLic		:= nil
	local bErro		:= Nil
	default cTxt	:= ''
	bErro	:= ErrorBlock({|oErr| HandleEr(oErr)})
	BEGIN SEQUENCE
		if !empty(cTxt)
			cPath := "\relato_licence_" + Alltrim(cTxt) + ".xml"
		else
			cPath := "\relato_licence.xml"
		endif
		oLic := cbcLicense():newcbcLicense(cPath)
		oLic:defaulFlow()
		RECOVER
	END SEQUENCE
	ErrorBlock(bErro)
	//u_autoAlert('Finalizado',.F.,'Box' )
return(nil)

/*/{Protheus.doc} xSchGLic
@author bolognesi
@since 13/07/2017
@version undefined
@param cTxt, characters, Complemento adicionado ao nome do arquivo em disco
@type function
@description Função que inicializa o ambiente e deve ser utilizada no Schedule
/*/
user function xSchGLic() //U_xSchGLic()
	local cCommand	:= ''
	local lWait		:= .F.
	local cPath 	:= ''
	local nX		:= 0
	RPCClearEnv()
	RPCSetType(3)
	RPCSetEnv('01','01',,,'FAT',GetEnvServer(),{} )
	ConsoleLog('Inicializando coleta de licenças')
	
	for nX := 1 to 5
		cCommand := "D:\Totvs_11\Microsiga\Protheus\bin\smartclient\Smartclient.exe -q -p=U_xGetLic "
		cCommand += " -c=tcp_Slv0" + cValToChar(nX) + " -e=P_11LEO -m -l "
		lWait  	 := .T.
		cPath    := "D:\Totvs_11\Microsiga\Protheus\bin\smartclient\"
		ConsoleLog('Enviando tcp_Slv0' + cValToChar(nX) + '-' + cCommand)
		WaitRunSrv( @cCommand , @lWait , @cPath )
		sleep(6000)
	next nX
	
	cCommand := "D:\Totvs_11\Microsiga\Protheus\bin\smartclient\Smartclient.exe -q -p=U_xGetLic "
	cCommand += " -c=tcp_Rmt -e=P_11LEO -m -l "
	lWait  	 := .T.
	cPath    := "D:\Totvs_11\Microsiga\Protheus\bin\smartclient\"
	ConsoleLog('Enviando tcp_Rmt' + cCommand)
	WaitRunSrv( @cCommand , @lWait , @cPath )
	sleep(6000)
	
	cCommand := "D:\Totvs_11\Microsiga\Protheus\bin\smartclient_SRV_PORTAL\Smartclient.exe -q -p=U_xGetLic "
	cCommand += " -c=tcp_port -e=P_11_PORTAL -m -l "
	lWait  	 := .T.
	cPath    := "D:\Totvs_11\Microsiga\Protheus\bin\smartclient_SRV_PORTAL\"
	ConsoleLog('Enviando Portal' + cCommand)
	WaitRunSrv( @cCommand , @lWait , @cPath )
	
	ConsoleLog('Finalizando coleta de licenças')
	RPCClearEnv()
return(nil)

/*/{Protheus.doc} HandleEr
@author bolognesi
@since 13/07/2017
@version 1.0
@param oErr, object, Objeto do erro
@type function
@description Função para tratamento de erro, no caso apenas loga no arquivo console.log
/*/
Static function HandleEr(oErr)
	ConsoleLog('[' + oErr:Description + ']' + oErr:ERRORSTACK)
	UnLockByName('COLETA_LICENCA', .F. , .F. )
	BREAK
return

/*/{Protheus.doc} ConsoleLog
@author bolognesi
@since 13/07/2017
@version 1.0
@param cMsg, characters, Mensagem para gravar no arquivo log
@type function
@description Gravar uma mensagem no arquivo de log
/*/
static function ConsoleLog(cMsg)
	ConOut("[Extração Licenças - " + DtoC(Date()) + " - " + Time()+ " ] " + cMsg)
return