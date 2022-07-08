#include 'protheus.ch'
#include 'parmtype.ch'


/*
	u_TstRM('0102', '000004', '1140904401', 'B01188', 2, 'R')
	u_TstRM('0102', '000005', '1530504401', 'B00300', 1, 'R')
	u_TstRM('0102', '000006', '1141002401', 'B00834', 2, 'R')
	u_TstRM('0102', '000006', '', '', , 'C')
	u_TstRM('', '', '', '', , 'S')
	cOper ( R=reserva, C=cancela, S=schedule)

*/



/*/{Protheus.doc} TstRM
//TODO Descrição auto-gerada.
@author bolognesi
@since 17/03/2016
@version undefined
@param cFil, characters, descricao
@param cId, characters, descricao
@param cProduct, characters, descricao
@param cAddress, characters, descricao
@param nQuant, numeric, descricao
@param cOper, characters, descricao
@type function
/*/
user function TstRM(cFil, cId, cProduct, cAddress, nQuant, cOper)
local oResInc
local oResCanc
local oResSch 

//******************** TROCAR FILIAL QUANDO NECESSARIO *******************
// ao definir a filial, todas as variaveis necessarias, SM0, serão posicinados de acordo
// valendo para todos as chamadas seguintes
// ao passar filial ao contrutor da classe tambem obtem-se o mesmo resultado
// se no construtor estiver vazio, por padrão assume o conteudo de cNumEmp
//oReserve:setBranch('0101') //Itu
//oReserve:setBranch('0102') //3L

if cOper == 'R'
	//********************* INCLUIR UMA RESERVA ******************************
	//Inicio da classe 
	oResInc := CbcReserveManager():newCbcReserveManager(cFil, cId, cProduct, cAddress, nQuant)
	
	//Realiza a reserva
	oResInc:PtEmpSdc()
	
	//Obtem array com o resultado
	oResInc:getResult()
	
	//Obtem a data/hora de expiração da reserva
	MessageBox( 'Reserva expira em: ' + cValToChar(oResInc:getExpireDate()) + 'Hora: ' +  oResInc:getExpireHour(), 'Aviso de teste', 48 )
	 

elseIf cOper == 'C'
	//********************** CANCELAR UMA RESERVA ****************************
	//Cancelar uma reserva
	oResCanc := CbcReserveManager():newCbcReserveManager(cFil, cId)

	//Cancela
	oResCanc:PtCanSdc()

	//Resultado do cancelamento
	oResCanc:getResult()
	


elseIf cOper == 'S'
	//********************* MONITORAR RESERVAS EXPIRADAS ()SCHEDULLE) ************************
	oResSch := CbcReserveManager():newCbcReserveManager()
	oResSch:SchExpire()
endIf

return





/*******************************/
/*
User Function RERPM01()

Local cDir    	:= "D:"
Local cArq    	:= "Vencimentos.txt"
Local nHandle 	:= FCreate(cDir+cArq)
Local nCount  	:= 0
Local aDt		:= {}
Local nHr		:= 0

Local dOriReserv 	:= cToD("01/01/16")
Local cOriTime		:= ""

If nHandle < 0
	MsgAlert("Erro durante criação do arquivo.")
Else

	FWrite(nHandle, "DATA_RESERVA;HORA_RESERVA;DATA_EXPIRAR;HORA_EXPIRAR" + CRLF )
	
	While dOriReserv <= cToD("31/12/16")
	
	    For nHr := 0 To 23 
	    
		    cOriTime := Padl(cValToChar(nHr),2,'0')  + ":30:00"		    
		    aDt := initDate(dOriReserv,cOriTime)
			FWrite(nHandle,cValToChar(dOriReserv) + ";" +cOriTime + ";" + cValToChar(aDt[1,1]) + ";" + aDt[1,2] + CRLF)
			
			cOriTime := Padl(cValToChar(nHr),2,'0')  + ":59:00"		    
		    aDt := initDate(dOriReserv,cOriTime)
			FWrite(nHandle,cValToChar(dOriReserv) + ";" +cOriTime + ";" + cValToChar(aDt[1,1]) + ";" + aDt[1,2] + CRLF)
		
		Next nHr
	
		dOriReserv := DaySum(dOriReserv, 1)
	
	EndDo 
	MessageBox("[FIM] - PROCESSO REALIZADO", 'UFA!!')
	FClose(nHandle)
EndIf

Return



Static Function initDate(dData,cTime) 

Local dActDate		:= dData
Local cActHour		:= cTime
Local aHour			:= aTime := StrToKArr(cActHour, ':')
Local dVldDate		:= DataValida(dData, .T.)
Local dVldNextDt	:= DataValida(DaySum(dActDate, 1), .T.)
Local dRetDate
Local cRetTime
Local aRet			:= {}

	If dActDate <> dVldDate
		dRetDate := dVldDate
		cRetTime := "08:00:00"
	Else
		
		If (Val(aHour[1]) ==  17 .And. Val(aHour[2]) > 30) .Or. (Val(aHour[1]) >  17) 
			dRetDate := dVldNextDt
			cRetTime := "08:00:00"
	
		Else
			dRetDate := dActDate
			cRetTime := cActHour
		EndIf  
		
	EndIf 
	
Aadd(aRet, {dRetDate, cRetTime} )	

return aRet


*/