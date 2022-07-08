#include 'parmtype.ch'
#include "rwmake.ch"
#include "TOPCONN.ch"
#include "protheus.ch"


User Function isDivid()
Local lRet		:= .F.
If Type('lIsJobAuto') <> 'U'
	lRet := .T.
EndIf
return lRet 



/*/{Protheus.doc} isInd
//TODO Declarar Private lIsInd:=.T. para indicar um pedido gerado de uma Industrialização/Triangulação.
@author alexandre.madeira
@since 21/09/2018
@version 1.0
@return lRet
@description Função utilizada para retornar se o pedido foi gerado de uma Industrialização/Triangulação
@type function
/*/
User Function isInd()
	Local lRet		:= .F.
	If Type('lIsInd') <> 'U'
		lRet := .T.
	EndIf
return lRet 


User Function isPortal()
Local lRet		:= .F.
If Type('lIsJobPortal') <> 'U'
	lRet := .T.
EndIf
return lRet 

/*/{Protheus.doc} isAuto
@author bolognesi
@since 19/10/2016
@version 1.0
@type function
@description Função utilizada para retornar se o processo
esta em uma rotina Automatica ou não
/*/
User Function isAuto() //U_isAuto()
return  _SetAutoMode() .Or. IsBlind()

/*/{Protheus.doc} autoAlert
@author bolognesi
@since 20/10/2016
@version 1.0
@param cMsg, characters, 	Texto contendo a mensagem 
@param lerro, logical, 		Define se a Mensagem é proveniente de um erro(Impede a execução)ou proveniente de
um simples aviso que em rotinas automaticas serão suprimidos. (Default: .T. ('Msg de Erro que parou a execução'))
@param cFunc, characters, 	Função de tela para exibir a mensagem  (Default: Alert())
@param cTit, characters, 	Titulo para função que exibe a mensagem (Default: 'Atenção!')
@param nTpBox, numeric, 	Utilizado quando cFunc definida aceita uma configuração 
para o tipo de tela e este for um numero ex:um MessageBox, define o tipo do Message Box (Default:48)
@param cStyle, characters, 	Utilizado quando cFunc definida aceita uma configuração 
para o tipo de tela e este for um caractere ex:um MsgBox, define o tipo do MsgBox (Default:'INFO')
@param lYes, logical, 		Quando tela de alerta for YesNo este parametro define YesNo Fixo para rotina automatica
sendo .T. = Yes e .F. = No, sendo este logico retornado pela função
@param xRet, characters, 	Variavel que pode ser passada como referencia, e que recebe o conteudo da
variavel xRet, este parametro tambem será retornado pela função
@type function
@description Função utilizada para tratamento de mensagens e alertas, esta rotina verifica:
se o processo esta em uma rotina automatica se não estiver mostra simplesmente o alerta na tela;
No caso de uma rotina automatica, ela não mostra a mensagem na tela, e verifica:
Se é uma mensagem de erro, se for utiliza a função interna AutoGrLog() que define a variavel lMsErroAutocomo .T.
bem como acrescenta a mensagem ao array de erros visualizados pelas funções (GetAutoGrLog() ou MostraErro()),
caso não apenas ignora o alerta em tela.
/*/
User Function autoAlert(cMsg,lerro,cFunc,cTit,nTpBox,cStyle,lYes,xRet) 
	Default cFunc		:= 'Alert'
	Default cMsg 		:= ""
	Default xRet		:= ""
	Default cTit		:= 'Atenção!'
	Default nTpBox		:= 48
	Default cStyle		:= 'INFO'
	Default lerro		:= .T.
	
	//Acertar o recebimento dos parametros
	If cFunc == 'Box'
		cFunc := 'MessageBox'
	ElseIf cFunc == 'Msg'
		cFunc := 'MsgAlert'
	ElseIf cFunc == 'MsgBox'
		cFunc := 'MsgBox'
	ElseIf cFunc == 'Info'
		cFunc := 'MsgInfo'
	Else
		cFunc	:= 'Alert'
	EndIf

	xRet := cMsg
	//Rotina automatica
	If U_isAuto()
		If lerro
			If Upper('Yes') $ Upper(cStyle)
				xRet := lYes
			Else
				//__aErrAuto -> Quando lAutoErrNoFile == .T.
				AutoGrLog("[LOG - " + DtoC(Date())+" - " + Time() + " ] " + cMsg)
			EndIf
		EndIF

	//Rotina normal
	Else
		//Definir função de mensagem adequada
		If cFunc == 'Alert'
			Alert(cMsg)
		ElseIf cFunc == 'MessageBox'
			MessageBox(cMsg,cTit,nTpBox)
		ElseIf cFunc == 'MsgAlert'
			MsgAlert(cMsg, cTit)
		ElseIf cFunc == 'MsgBox'
			If Upper('Yes') $ Upper(cStyle)
				xRet := MsgBox(cMsg, cTit, cStyle)
			Else
				MsgBox(cMsg, cTit, cStyle)
			EndIf
		ElseIf cFunc == 'MsgInfo'
			MsgInfo(cMsg, cTit)
		Else
			Alert(cMsg)
		EndIf
	EndIf
return(xRet)


/*FUNÇÔES DE EXEMPLOS E TESTES*/

User Function tstJbA() //U_tstJbA()
	aRet := startJob('U_tstAlert', getenvserver(),.T., .T.)
	Sleep(500)
return (Nil)

User Function tstAlert(lAuto) //U_tstAlert()
	Local aRet	:= {}
	Local lRet	:= Nil
	Private	lMsErroAuto		:= .F.
	Private lMsHelpAuto		:= .T.
	//Define se grava erros log ou array ( .T. = Array/GetAutoGrLog()  - .F. = Arquivo/MostraErro() )
	Private lAutoErrNoFile	:= .T.

	Default lAuto 			:= .F.

	If lAuto
		RPCSetType(3)
		RPCSetEnv('01','01',,,'FAT',GetEnvServer(),{} )
	EndIf

	//Para Exibir o alert (Erro)
	u_autoAlert('01-Mostrando Alert de Erro')
	If lMsErroAuto
		//MostraErro()
		AAdd(aRet , GetAutoGrLog())
	EndIf

	//Para Exibir o alert (Aviso)
	u_autoAlert('02-Mostrando Alert de Aviso',.F. )

	//Para Exibir MessageBox (Erro)
	lMsErroAuto		:= .F.
	u_autoAlert('03-Mostrando MessageBox de Erro',,'Box')
	If lMsErroAuto
		AAdd(aRet , GetAutoGrLog())
		//MostraErro()
	EndIf

	//Para Exibir MessageBox (Aviso)
	u_autoAlert('04-Mostrando MessageBox de Aviso',.F.,'Box' )

	//Para Exibir MsgAlert (Erro)
	lMsErroAuto		:= .F.
	u_autoAlert('05-Mostrando MsgAlert de Erro',,'Msg')
	If lMsErroAuto
		AAdd(aRet , GetAutoGrLog())
		//MostraErro()
	EndIf

	//Para Exibir MsgAlert (Aviso)
	u_autoAlert('06-Mostrando MsgAlert de Aviso',.F.,'Msg')		

	//Para Exibir MsgBox (Erro)
	lMsErroAuto		:= .F.
	u_autoAlert('07-Mostrando MsgAlert de Aviso',,'MsgBox')
	If lMsErroAuto
		AAdd(aRet , GetAutoGrLog())
		//MostraErro()
	EndIf
	//Para Exibir MsgBox (Aviso)
	u_autoAlert('08-Mostrando MsgAlert de Aviso',.F.,'MsgBox')
	

	//Messages com retornos
	//Para axibir MsgBox do tipo YesNo (Somente mostrar, se rotina automatica ignora)
	AAdd(aRet,{'YesNo-09',u_autoAlert('09-Mostrando MsgAlert de Aviso',.F.,'MsgBox','Titulo',,'YesNo')})
	//Para axibir MsgBox do tipo YesNo (Quando rotina automatica, fixa-se o retorno no 6 parametro )
	//YesNo rotina automatica resposta fixa SIM
	AAdd(aRet,{'YesNo-10',u_autoAlert('10-Mostrando YesNo fixo Sim',.T.,'MsgBox','Titulo',,'YesNo',.T.)})
	//YesNo rotina automatica resposta fixa NÃO
	AAdd(aRet,{'YesNo-11',u_autoAlert('11-Mostrando YesNo fixo Não',.T.,'MsgBox','Titulo',,'YesNo',.F.)})		
	
		
	//Para Exibir MsgInfo (Aviso)
	u_autoAlert('12-Mostrando MsgInfo de Aviso',.F.,'Info','Titulo')
	
	//Para Exibir MsgInfo (Erro)
	lMsErroAuto		:= .F.
	u_autoAlert('13-Mostrando MsgInfo de Erro',,'Info','Titulo')
	If lMsErroAuto
		AAdd(aRet , GetAutoGrLog())
		//MostraErro()
	EndIf	
			
	If lAuto
		RPCClearEnv()
	EndIf
Return (aRet)