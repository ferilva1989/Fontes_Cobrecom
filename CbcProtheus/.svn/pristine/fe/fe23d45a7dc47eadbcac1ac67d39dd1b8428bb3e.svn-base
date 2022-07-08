#include "totvs.ch"
#include "rwmake.ch"
#include 'topconn.ch'
#include "tbiconn.ch"

/*/{Protheus.doc} CbcReserveManager
//(long_description)
@author bolognesi
@since 14/03/2016
@version 1.0
@example
( local oReserve := CbcReserveManager():newCbcReserveManager(cFil, cId, cProduct, cAddress, nQuant) )
@description Classe para manutenção das reservas no portal
/*/
class CbcReserveManager 

	data ActualDate
	data ActualHour
	data ExpireDate
	data ExpireHour
	data Result
	data Branch
	data cId
	data cProduct 
	data cAddress
	data nQuant
	data ResType
	data OperType
	data cErrorMsg
	data nQtdEmp    


	method newCbcReserveManager() constructor 
	method config()
	method getActualDate()
	method setActualDate()
	method getActualHour()
	method setActualHour()
	method getExpireDate()
	method setExpireDate()
	method getExpireHour()
	method setExpireHour()
	method getResult()
	method setResult()
	method getBranch()
	method setBranch()
	method getcId()
	method setcId()
	method getcProduct()
	method setcProduct() 
	method getcAddress()
	method setcAddress()
	method getnQuant()
	method setnQuant()
	method getResType()
	method setResType()
	method getOperType()
	method setOperType()
	method getErrorMsg()
	method getnQtdEmp()                    

	method ExpAddDay()
	method setInitialDate()
	method defExpireDate()
	method PtEmpSdc()
	method PtCanSdc()
	method SchExpire()
	method ResCancel()
	method SchResStp()

endclass


/*/{Protheus.doc} config
//Metodo construtor
@author bolognesi
@since 15/03/2016
@version 1.0
@param cFil, characters, Filial formato '0101' ou '0102'
@param cId, characters, Id da reserva
@param cProduct, characters, Codigo do produto
@param cAddress, characters, Endereço (Ex B01000)
@param nQuant, numeric, quantidade a reservar
@description Construtor da classe 
/*/
method newCbcReserveManager( cFil, cId, cProduct, cAddress, nQuant) class CbcReserveManager

	Default cFil		:= cFilAnt
	Default cId			:= ""
	Default cProduct	:= ""
	Default cAddress	:= ""
	Default	nQuant		:= ""

	::setBranch(cFil)
	::setInitialDate()
	::setcId(cId)

	//TODO DEBUG AVALIAR PARAMETROS RECEBIDOS 
	//CONOUT('[DBG]-[cFil CbcReserveManager] = ' 		+ cFil)
	//CONOUT('[DBG]-[cId CbcReserveManager] = '  		+ cId) //*
	//CONOUT('[DBG]-[cProduct CbcReserveManager] = '  + cProduct) 
	//CONOUT('[DBG]-[cAddress CbcReserveManager] = '  + cAddress) 
	//CONOUT('[DBG]-[nQuant CbcReserveManager] = '  	+ cValToChar(nQuant))
	//

	if Empty(cProduct)

		DbSelectarea("ZP4")
		ZP4->(DbSetOrder(1)) //ZP4_FILIAL+ZP4_CODIGO
		if ZP4->(DbSeek(xFilial("ZP4") + cId, .F.) )

			cProduct 	:= Alltrim(ZP4->(ZP4_CODPRO))
			cAddress	:= Alltrim(ZP4->(ZP4_LOCALI))
			nQuant		:= ZP4->(ZP4_QUANT)

		endIf
		ZP4->(DbCloseArea())

	endIf

	if !Empty(cAddress)
		::setResType(Substr(cAddress,1,1))

		if ::getResType() == 'B'
			::nQtdEmp := Val(Substr(cAddress,2,Len(cAddress)-1))
		else
			::nQtdEmp := nQuant * Val(Substr(cAddress,2,Len(cAddress)-1))
		endIf

	endIf

	::setcProduct(cProduct)
	::setcAddress(cAddress)
	::setnQuant(nQuant)

	LenX3Comp(@self)

return self

/*/{Protheus.doc} getBranch
//Obtem a filial definida para a classe
@author bolognesi
@since 15/03/2016
@version 1.0
@return Filial definida
/*/
method getBranch() class CbcReserveManager
return ::Branch

/*/{Protheus.doc} setBranch
//Define a filial
@author bolognesi
@since 15/03/2016
@version 1.0
@param cBranch, String, Código da empresa junto com a da filial (ex:'0101')
@description Defini a filial e vale para todos os metodos da classe
/*/
method setBranch(cBranch) class CbcReserveManager
	cBranch := Padr(cBranch, FWSizeFilial())
	if cBranch <> cFilAnt
		cFilAnt := cBranch
		SM0->(DbSeek(cEmpAnt+cFilAnt))
	endIf

	::Branch 	:= cBranch

return 

/*/{Protheus.doc} getActualDate
//Obtem data atual
@author bolognesi
@since 15/03/2016
@version 1.0
@return Data atual (data da construção da classe)
/*/
method getActualDate() class CbcReserveManager
return ::ActualDate 

/*/{Protheus.doc} setActualDate
//Define a data atual
@author bolognesi
@since 15/03/2016
@version 1.0
@param dsetDate, Date, data que deverá ser atribuida na propiedade
@description Definir a data atual para a propriedade
/*/
method setActualDate(dsetDate) class CbcReserveManager
	::ActualDate := dsetDate
return

/*/{Protheus.doc} getActualHour
//Obtem a hora atual
@author bolognesi
@since 15/03/2016
@version 1.0
@return retorna a hora atual definida para a propriedade
@description Obter a hora atual para a propriedade
/*/
method getActualHour() class CbcReserveManager
return ::ActualHour 

/*/{Protheus.doc} setActualDate
//Define a hora atual
@author bolognesi
@since 15/03/2016
@version 1.0
@param csetHour, String, hora que deverá ser atribuida na propiedade
@description Definir a data atual para a propriedade, como a função Time()
/*/
method setActualHour(csetHour) class CbcReserveManager
	::ActualHour := csetHour
return

/*/{Protheus.doc} getExpireDate
//Obtem a data de expiraração a reserva
@author bolognesi
@since 15/03/2016
@version 1.0
@description Obtem a data de expiração da reserva
/*/
method getExpireDate() class CbcReserveManager
return ::ExpireDate

/*/{Protheus.doc} setExpireDate
//Defini a data de expiração da reserva
@author bolognesi
@since 15/03/2016
@version 1.0
@param dSetDate, date, Data para expirar a reserva
@Description Definir a data de expiração para uma reserva
/*/
method setExpireDate(dSetDate) class CbcReserveManager
	::ExpireDate := dSetDate
return

/*/{Protheus.doc} getExpireHour
//Obtem a hora para expirar
@author bolognesi
@since 15/03/2016
@version 1.0
@Description Obtem a hora para expirar a reserva
/*/
method getExpireHour() class CbcReserveManager
return ::ExpireHour

/*/{Protheus.doc} setExpireHour
//Defini a hora de expiração para a reserva
@author bolognesi
@since 15/03/2016
@version 1.0
@param cSetHour, characters, String com hora formato (HH:MM:SS), para expirar reserva
@description Definir a hora para expirar a reserva
/*/
method setExpireHour(cSetHour) class CbcReserveManager 
	::ExpireHour := cSetHour
return

/*/{Protheus.doc} getResult
//Obtem os resultados das operações
@author bolognesi
@since 15/03/2016
@version 1.0
@description Obtem um array com os retornos das operações de reserva (  { {Logico, Mensagem} , {Logico, Mensagem}} )
/*/
method getResult()	class CbcReserveManager
return ::Result

/*/{Protheus.doc} setResult
//Definir os retornos das operações de reservas
@author bolognesi
@since 15/03/2016
@version 1.0
@param aRet, Array, Estrutura que contem Logico e uma mensagem referente aos erros
@description Resultados das operações definidas pelos metodos (PtCanSdc() e PtEmpSdc())
/*/
method setResult(cResult)	class CbcReserveManager

	::Result := cResult
return

/*/{Protheus.doc} getcId
//Obtem o Id da reserva
@author bolognesi
@since 15/03/2016
@version 1.0
@description obtem o ID da reserva, definido na propriedade
/*/
method getcId()				class CbcReserveManager
return ::cId

/*/{Protheus.doc} setcId
//Defini o id da reserva para a propriedade
@author bolognesi
@since 15/03/2016
@version 1.0
@param cParId, String, Codigo da reserva
@description definir o Id da reserva
/*/
method setcId(cId)			class CbcReserveManager
	::cId := cId
return

/*/{Protheus.doc} getcProduct
//Obtem codigo do produto definido para a propriedade
@author bolognesi
@since 15/03/2016
@version 1.0
@description Obtem codigo do produto para a propriedade
/*/
method getcProduct()		class CbcReserveManager
return ::cProduct

/*/{Protheus.doc} setcProduct
//Definir codigo do produto para a propriedade
@author bolognesi
@since 15/03/2016
@version undefined
@param cProd, String, Codigo do produto
@description Definir o codigo do produto a ser reservado 
/*/
method setcProduct(cProd) 	class CbcReserveManager
	::cProduct := cProd
return

/*/{Protheus.doc} getcAddress
//Obtem os endereços Ex B00100, R00100
@author bolognesi
@since 15/03/2016
@version 1.0
@description Obtem os endereços atribuidos para a propriedade
/*/
method getcAddress()		class CbcReserveManager
return ::cAddress

/*/{Protheus.doc} setcAddress
//Definir o endereço para a reserva
@author bolognesi
@since 15/03/2016
@version 1.0
@param cEnd, String, endereço do produto a ser reservado Ex( B01000 R0100 )
@description defini o endereço do produto
/*/
method setcAddress(cAddr)	class CbcReserveManager
	::cAddress := cAddr
return

/*/{Protheus.doc} getnQuant
//Obtem quantidade a ser reservada na propriedade
@author bolognesi
@since 15/03/2016
@version 1.0
@description Obtem quantidade a ser reservada 
/*/
method getnQuant()			class CbcReserveManager
return ::nQuant

/*/{Protheus.doc} setnQuant
//Definir a quantidade a ser reservada
@author bolognesi
@since 15/03/2016
@version undefined
@param nQt, Numerico, Quantidade a reservar de um produto em um endereço
@description Quantidade a reservar de um produto em um endereço
/*/
method setnQuant(nQtd)		class CbcReserveManager
	::nQuant := nQtd
return

/*/{Protheus.doc} getResType
//Obtem o tipo de reserva definido para a propriedade
@author bolognesi
@since 15/03/2016
@version 1.0
@description Tipo de reserva consiste em B=Bobina, C=Carretel, M=Carretel Madeira, T=Retalho, L=Blister
/*/
method getResType()			class CbcReserveManager
return ::ResType

/*/{Protheus.doc} setResType
//Definir o tipo de reserva na propriedade
@author bolognesi
@since 15/03/2016
@version 1.0
@description Tipo de reserva consiste em B=Bobina, C=Carretel, M=Carretel Madeira, T=Retalho, L=Blister
/*/
method setResType(cResTp)	class CbcReserveManager
	::ResType := cResTp
return

/*/{Protheus.doc} getOperType
//Obtem o tipo da operação
@author bolognesi
@since 15/03/2016
@version 1.0
@description Tipo de reserva consiste em INC(Incluir uma reserva) CANC(Cancelar uma reserva)
/*/
method getOperType()		class CbcReserveManager
return ::OperType

/*/{Protheus.doc} setOperType
//Definir o tipo da operação
@author bolognesi
@since 15/03/2016
@version 1.0
@description Tipo de reserva consiste em INC(Incluir uma reserva) CANC(Cancelar uma reserva)
/*/
method setOperType(cOperTp)	class CbcReserveManager
	::OperType := cOperTp
return

/*/{Protheus.doc} getErrorMsg
Coleta as Mensagens de Erro do Objeto
@author bolognesi
@since 17/03/2016
@return String Mensagens de Erro do Objeto
/*/
method getErrorMsg() class CbcReserveManager
return ::cErrorMsg


/*/{Protheus.doc} getnQtdEmp
Obtem a quantidade a ser reservada
@author bolognesi
@since 17/03/2016
@return Number quantidade a ser reservada
@description Quantidade a ser empenhada ex: (100M 1000M)
/*/
method getnQtdEmp()	class CbcReserveManager
return ::nQtdEmp


/*/{Protheus.doc} PtCanSdc
//Metodo para cancelar o empenho
@author bolognesi
@since 15/03/2016
@version 1.0
@description Metodo que realiza o cancelamento da reserva
/*/
method PtCanSdc(cOri) class CbcReserveManager

	Local oService 	:= CbcOpportunityBalanceService():newCbcOpportunityBalanceService()
	Local aNmbrCoil	:= {}
	Local aRet		:= {}
	Local nX
	Local lTok		:= .T.

	Default cOri	:='canc'    

	::setOperType('CANC')

	if ::getResType() == 'B'

		aNmbrCoil := getNmbCoil(@self)

		if !Empty(aNmbrCoil)	

			BeginTran()
			for nX := 1 To Len(aNmbrCoil)

				/*TODO Util debugar*/
				//conout('[PARAMETROS_EMPSDC ----> ]' + 'Produto:' + ::getcProduct() + ' Endereço ' + ::getcAddress() + ' Qtd' + cValToChar(::getnQtdEmp()) + ' ID' + ::getcId() + ' NroBobina ' + aNmbrCoil[nX])
				AAdd(aRet , U_EmpSDC(.F.,'ZP4', ::getcProduct() , '01', ::getcAddress(), ::getnQtdEmp(), ::getcId(), aNmbrCoil[nX], .T., nX) )

				if !aRet[nX,1]
					DisarmTransaction()
				endIf

			next nX
			EndTran()
		else

			AAdd( aRet, {.F., 'NENHUMA BOBINA ENCONTRADA PARA CANCELAR'})

		endif

	else

		aAdd(aRet, U_EmpSDC(.F.,'ZP4', ::getcProduct() , '01', ::getcAddress(), ::getnQtdEmp(), ::getcId(), '', .F.,1))

	endIf

	lTok := aRet[1,1]

	if lTok .And. cOri == 'Exp'
		oService:setExpired(::getBranch(), ::getcId())
	else
		::cErrorMsg := aRet[1,2]
	endIf

	::setResult(aRet)

return lTok

/*/{Protheus.doc} PtEmpSdc
//Efetivar uma reserva
@author bolognesi
@since 15/03/2016
@version 1.0
@description Realiza o inclusão de uma reserva, empenhando o produto no sistema (SDC010 e SZE010)
/*/
method PtEmpSdc() class CbcReserveManager

	Local aNmbrCoil	:= {}
	Local aRet		:= {}	
	Local nX		:= 0
	Local lOk		:= .F.

	::setOperType('INC')

	if ::getResType() == 'B'

		aNmbrCoil := getNmbCoil(@self) 	

		if !Empty(aNmbrCoil)	

			BeginTran()
			for nX := 1 To Len(aNmbrCoil)

				AAdd(aRet , U_EmpSDC(.T.,'ZP4', ::getcProduct(), '01', ::getcAddress(), ::getnQtdEmp(), ::getcId(), aNmbrCoil[nX], .T.,nX))

				if !aRet[nX,1]
					DisarmTransaction()
				endIf

			next nX
			EndTran()

		else

			AAdd( aRet, {.F., 'BOBINAS SELECIONADAS PARA RESERVA NÂO ESTÃO MAIS DISPONIVEIS'})

		endif

	Else

		AAdd(aRet , U_EmpSDC(.T.,'ZP4', ::getcProduct(), '01', ::getcAddress(), ::getnQtdEmp(), ::getcId(), '', .F.,1))

	endIf

	::setResult(aRet)
	::setInitialDate()
	::defExpireDate()

	lOk := aRet[1,1]

	if !lOk
		::cErrorMsg := aRet[1,2]
	endIf

return lOk

/*/{Protheus.doc} ExpAddDay
//Soma um dia a data de expiração
@author bolognesi
@since 15/03/2016
@version 1.0
@description Utilizado para somar um dia a data de expiração
/*/
method ExpAddDay() class CbcReserveManager
	::setExpireDate(DaySum(::getExpireDate(), 1))
return  

/*/{Protheus.doc} setInitialDate
@author bolognesi
@since 25/04/2016
@version 1.0
@type method
@description Metodo utilizado para definir (Data e Hora), inicial para a contagem do prazo
de expiração, em definição dia 25/04/16 pela Juliana Vendas, adotamos a seguinte logica:
reservas realizadas ( fora do horario de trabalho "08h00 as 17h30", Finais de Semana ou Feriados)
devem ter suas datas inciais alteradas para 08h00 do proximo dia util, Ex: reservas realizadas sabado
ficaram somente deve iniciar a contagem do prazo de expiração na segunda(se não for feriado) as 08h00
desta forma considerando um prazo de 2 horas as reservas realizadas no final de semana irão expirar
no proximo dia util as 10h00 
/*/
method setInitialDate() class CbcReserveManager

	Local dActDate		:= Date()
	Local cActHour		:= Time()
	Local aHour			:= aTime := StrToKArr(cActHour, ':')
	Local dVldDate		:= DataValida(Date(), .T.)
	Local dVldNextDt	:= DataValida(DaySum(dActDate, 1), .T.)

	If dActDate <> dVldDate
		::setActualDate(dVldDate)
		::setActualHour("08:00:00")
	Else

		If (Val(aHour[1]) ==  17 .And. Val(aHour[2]) > 30) .Or. (Val(aHour[1]) >  17)
			::setActualDate(dVldNextDt)
			::setActualHour("08:00:00")
		Else
			::setActualDate(dActDate)
			::setActualHour(cActHour)
		EndIf  

	EndIf 

return

/*/{Protheus.doc} defExpireDate
//Defini a data e hora de expiração
@author bolognesi
@since 15/03/2016
@version 1.0
@description Defini com base na data de inclusão da reserva, qual será a data e hora de expiração
Utiliza o parametro MV_RESDTEX 
/*/
method defExpireDate() class CbcReserveManager
	Local nMinExp   := GetNewPar('MV_RESDTEX', 120)
	Local aTime		:= {}
	Local nI

	::setExpireDate(::getActualDate())
	::SetExpireHour(::getActualHour())

	aTime := StrToKArr(::getActualHour(), ':')

	For nI := 1 to Len(aTime)
		aTime[nI] := Val(aTime[nI]) 
	Next nI

	For nI := 1 To  nMinExp
		aTime[2] ++

		if aTime[2] == 60
			aTime[1] ++
			aTime[2] := 0
		endIf

		if aTime[1] == 24
			aTime[1] := 0
			::ExpAddDay()
		endIf 

	Next nI

	For nI := 1 to Len(aTime)
		aTime[nI] := Padl(aTime[nI],2,'0') 
	Next nI

	::SetExpireHour( Alltrim(aTime[1] + ':' + aTime[2] + ':' + aTime[3]) ) 

return

/*/{Protheus.doc} SchExpire
//Busca e expira as reservas
@author bolognesi
@since 15/03/2016
@version 1.0
@description utilizada pelo schedule monitora as reservas expiradas, cancelando-as
/*/
method SchExpire() class CbcReserveManager
	Local cQuery	:= ""
	Local aExpId	:= {}
	Local nX
	Local aMsgMail	:= {}

	If Select( "Exp") > 0
		Exp->(dbcloseArea())
		FErase( "Exp" + GetDbExtension())
	End If

	cQuery 	:= " SELECT ZP4_FILIAL AS BRAN, 
	cQuery	+= " ZP4_CODIGO AS ID, "
	cQuery 	+= " ZP4_CODPRO AS PROD, "
	cQuery	+= " ZP4_LOCALI AS ADDR, "
	cQuery	+= " ZP4_QUANT AS QTD "
	cQuery 	+= " FROM " + RETSQLNAME("ZP4")  + " ZP4 "
	cQuery 	+= " RIGHT JOIN "+ RETSQLNAME("SDC") + " SDC ON "
	cQuery 	+= " ZP4.ZP4_FILIAL		= SDC.DC_FILIAL "
	cQuery 	+= " AND 'ZP4'			= SDC.DC_ORIGEM "
	cQuery 	+= " AND ZP4.ZP4_CODIGO	= SDC.DC_PEDIDO "
	cQuery 	+= " AND ZP4.D_E_L_E_T_	= SDC.D_E_L_E_T_"
	cQuery	+= " WHERE GETDATE() >= CAST(  (CAST(ZP4_DTVAL AS VARCHAR) + ' ' + ZP4_HRVAL) AS DATETIME) "
	cQuery	+= " AND ZP4_STATUS IN ('1','3') "
	cQuery  += " AND ZP4.D_E_L_E_T_	<>	'*' " 

	cQuery := ChangeQuery(cQuery)

	TCQUERY cQuery NEW ALIAS "Exp"

	/*TODO Util debugar */
	//conout('[QUERY_SCH --->] ' + cQuery )
	//conout('[<-------->] ' + cQuery )


	DbSelectArea("Exp")
	Exp->(DbGotop())

	While !Exp->(Eof())

		::setBranch(Exp->(BRAN)) //0101; 0102
		::setcId(Exp->(ID))
		::setcProduct(Exp->(PROD))
		::setcAddress(Exp->(ADDR))
		::setnQuant(Exp->(QTD))
		::setResType(Substr(Exp->(ADDR),1,1))

		if ::getResType() == 'B'
			::nQtdEmp := Val(Substr(::getcAddress(),2,Len(::getcAddress())-1))
		else
			::nQtdEmp := ::getnQuant() * Val(Substr(::getcAddress(),2,Len(::getcAddress())-1))
		endIf

		LenX3Comp(@self)
		::PtCanSdc('Exp')

		for nX := 1 To Len(::getResult())
			if !::getResult()[nX,1]
				AAdd(aMsgMail,{ ::getcId() , ::getResult()[nX,2], cValToChar(::getActualDate()), ::getActualHour() } )
			endIf
		next nX

		Exp->(DbSkip())
	EndDo

	If Select( "Exp") > 0
		Exp->(dbcloseArea())
		FErase( "Exp" + GetDbExtension())
	End If


	if !Empty(aMsgMail)
		trataErro(aMsgMail)
	endIf

return

/*/{Protheus.doc} SchResStp
@author bolognesi
@since 06/03/2017
@version 1.0
@type method
@description [RESERVA-SCH02]-Verificar reservas não efetivadas, virou
orçamento mas não chegou a virar nota.
/*/
method SchResStp() class CbcReserveManager
	local oSch 			:= nil
	local oSql   		:= LibSqlObj():newLibSqlObj()
	local dHoje			:= ::getActualDate()
	local cReserva		:= ""
	local dDtReserva	:= ""
	local cOrcPortal	:= ""
	local cOrcInterno	:= ""
	local dDtOrc		:= ""
	local cNumPed		:= ""
	local dDtPed		:= ""
	local dDtLibPed		:= ""
	local aLinha		:= {}
	local aReg			:= {}

	//TODO talvez futuro paginação por RECNO, boa ideia
	oSql:newAlias( retQryRes() )

	if oSql:hasRecords()
		oSch := cbcSchCtrl():newcbcSchCtrl()
		oSch:setSimple( .F. )
		oSch:setIDEnvio('RESERVAS')
		oSch:addEmailTo( Alltrim(GetNewPar('MV_EMGRPTI', '')))
		oSch:addEmailCc( Alltrim(GetNewPar('XX_EMVEND', '')))
		oSch:setAssunto('[PORTAL] - RESERVAS PARADAS ANALISAR')
		oSch:setHtmlFile('\scheduleLayout\html\reservas_portal.html')

		oSql:goTop()

		while oSql:notIsEof()
			aReg 		:= {}

			cReserva	:= oSql:getValue("NR_RESERVA")
			dDtReserva	:= oSql:getValue("DT_RESERVA")
			cOrcPortal	:= oSql:getValue("NR_ORC_PORTAL")
			cOrcInterno	:= oSql:getValue("NR_ORC_INTERNO")
			dDtOrc		:= oSql:getValue("DT_CONFIRM_RESERVA")
			cNumPed		:= oSql:getValue("NR_PEDIDO")
			dDtPed		:= oSql:getValue("DT_PEDIDO")
			dDtLibPed	:= oSql:getValue("DT_LIB_PEDIDO")

			if enviaSch(dDtOrc,dDtLibPed,dDtPed,dHoje)

				aadd(aReg, {'Wf.Reserva'	,Alltrim(cReserva)			})
				aadd(aReg, {'Wf.DtReserva'	,dtoc(stod(dDtReserva))		})
				aadd(aReg, {'Wf.OrcPortal'	,Alltrim(cOrcPortal)		})
				aadd(aReg, {'Wf.OrcInterno' ,Alltrim(cOrcInterno)		})
				aadd(aReg, {'Wf.DtOrcamento',dtoc(stod(dDtOrc)) 		})
				aadd(aReg, {'Wf.Pedido'		,Alltrim(cNumPed)			})
				aadd(aReg, {'Wf.DtPedido'	,dtoc(stod(dDtPed))  		})
				aadd(aReg, {'Wf.DtLibPed'	,dtoc(stod(dDtLibPed))		})

				oSch:addDados(aReg)

			endif
			oSql:skip()
		enddo

		if !Empty(oSch:getLines())
			oSch:schedule()
		endif
		FreeObj(oSch)
	endif

	oSql:close()  
	FreeObj(oSql)

return(self)

/*/{Protheus.doc} ResCancel
@author bolognesi
@since 18/04/2016
@version 1.0
@param cReserve, string, Numero da Reserva para cancelar
@type method
@description metodo utilizado na exclusão do Orçamento ou Pedido
para os itens que tem reserva no portal deve-se estornar e cancelar a reserva
/*/
method ResCancel(cReserve) class CbcReserveManager
	Local lErro
	Local oService  := CbcOpportunityBalanceService():newCbcOpportunityBalanceService()

	DbSelectArea("ZP4")
	ZP4->(DbSetOrder(1)) 

	If ZP4->( DbSeek(xFilial("ZP4") + cReserve, .F.)  )
		If ZP4->(ZP4_STATUS) == '2'
			::setBranch( ZP4->(ZP4_FILIAL))
			::setcId( ZP4->(ZP4_CODIGO) )
			::setcProduct( ZP4->(ZP4_CODPRO) )
			::setcAddress(ZP4->(ZP4_LOCALI) )
			::setnQuant( ZP4->(ZP4_QUANT) )
			::setResType(Substr(ZP4->(ZP4_LOCALI),1,1))

			if ::getResType() == 'B'
				::nQtdEmp := Val(Substr(::getcAddress(),2,Len(::getcAddress())-1))
			else
				::nQtdEmp := ::getnQuant() * Val(Substr(::getcAddress(),2,Len(::getcAddress())-1))
			endIf
			If ::PtCanSdc()
				//TODO Cancelar ou Expirar 
				oService:undoConfirm(xFilial("ZP4"), cReserve, .T. )
				//oService:setWaiting(xFilial("ZP4"), cReserve)
			Else
				lErro:= .F.

			EndIf
		EndIf
	EndIf
return

/*/{Protheus.doc} getNmbCoil
//Retrona os numeros de bobinas para uma operação de reserva
@author bolognesi
@since 15/03/2016
@version 1.0
@param oSelf, object, objeto gerente de reservas com as propriedades preenchidas
@type function
@description Tanto para reserva quanto para cancelar obtem o numero das bobinas
/*/
static function getNmbCoil(oSelf)
	Local aNmbrCoil	:= {}
	Local aResCoil	:= {}
	Local cQuery	:= ""

	If Select( "Coil") > 0
		Coil->(dbcloseArea())
		FErase( "Coil" + GetDbExtension())
	End If

	cQuery := " SELECT ZE_NUMBOB AS NRO_BOBINA "
	cQuery += " FROM " + RETSQLNAME("SZE") + " SZE"
	cQuery += " WHERE ZE_FILIAL	IN	( '" +oSelf:getBranch()+ "' ) "

	if oSelf:getOperType() == 'INC'

		cQuery += " AND ZE_STATUS =	'T' "
		cQuery += " AND	ZE_QUANT >	0 	"

	elseif oSelf:getOperType() =='CANC'
		cQuery += " AND ZE_CTRLE =  '" + oSelf:getcId() + "' "
	endIf

	cQuery += " AND ZE_PRODUTO	=  '" + oSelf:getcProduct() + "' "   	
	cQuery += " AND 'B'+RIGHT(REPLICATE('0',5)+ CONVERT(VARCHAR(5),ZE_QUANT),5) = '" + oSelf:getcAddress() + "' "
	cQuery += " AND SZE.D_E_L_E_T_	<>	'*' "

	cQuery := ChangeQuery(cQuery)

	/*TODO Util debugar */
	//conout('[QUERY --->] ' + cQuery )
	//conout('[<-------->] ' + cQuery )

	TCQUERY cQuery NEW ALIAS "Coil"

	DbSelectArea("Coil")
	Coil->(DbGotop())

	While !Coil->(Eof())
		AAdd(aNmbrCoil, Coil->(NRO_BOBINA) )
		Coil->(DbSkip())
	EndDo

	//Verificar quantidade das possibilidades de reservas atente o que precisa 
	if Len(aNmbrCoil) >= oSelf:getnQuant()

		for nX := 1 To oSelf:getnQuant()

			AAdd(aResCoil,aNmbrCoil[nX]) 

		next nX

	endIf

	If Select( "Coil") > 0
		Coil->(dbcloseArea())
		FErase( "Coil" + GetDbExtension())
	End If

return aResCoil

/*/{Protheus.doc} tovLenComp
//Compatibilizar tamanho das Propriedades
@author bolognesi
@since 16/03/2016
@version 1.0
@param oSelf, object, Referencia propria classe
@type function
@description função para compatibilizar as propriedades de acordo com o tamanho do dicionario de dados
/*/
static function LenX3Comp(oSelf)
	oSelf:setcId(		Padr(oSelf:getcId()		, TamSx3("ZP4_CODIGO")[1] ) )
	oSelf:setcProduct(	Padr(oSelf:getcProduct(), TamSx3("B1_COD")[1] ) )
	oSelf:setcAddress( 	Padr(oSelf:getcAddress(), TamSx3("BF_LOCALIZ")[1] ) )
return

/*/{Protheus.doc} trataErro
//Realiza o tratamento dos erros do schedulle
@author bolognesi
@since 16/03/2016
@version 1.0
@param aErro, Array, Array com as linhas do e-mail
@type function
@description realiza o tratamento de erros do schedule (Mandar email)
/*/
static function trataErro(aErro) //TODO mudar email
	u_envmail({"leonardo@cobrecom.com.br"}, "[ERRO] - Schedule reservas portal", {"Reserva","Erro", "Data", "Hora"}, aErro)
return

/*/{Protheus.doc} schReservas
//Schedule expirar reservas
@author bolognesi
@since 16/03/2016
@version 1.0
@type function
@description função executada pelo schedule, para expirar as reservas
/*/
user function schExpRes()
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"

	showConsoleMsg("Iniciando o schedule de expiração de reservas")
	oResSch := CbcReserveManager():newCbcReserveManager()
	oResSch:SchExpire()
	chkSDC()
	showConsoleMsg("Finalizado o schedule de expiração de reservas")

	RESET ENVIRONMENT
return

/*/{Protheus.doc} schResStp
//Schedule para buscar reservas paradas.
@author bolognesi
@since 06/03/2017
@version 1.0
@type function
@description [RESERVA-SCH01]função executada pelo schedule, utilizada
para enviar o workflow sobre:
1-) Reservas viraram orçamento e não virou pedido.
2-) Reservas viraram orçamento que viraram pedido mas não faturadas.
/*/
user function schResStp()
	RPCClearEnv()
	RPCSetType(3)
	RPCSetEnv('01','01',,,'FAT',GetEnvServer(),{} )

	showConsoleMsg("Iniciando o schedule para verificar reservas paradas")
	oResSch := CbcReserveManager():newCbcReserveManager()
	oResSch:SchResStp()
	showConsoleMsg("Finalizado o schedule para verificar reservas paradas")

	RPCClearEnv()
return

/*/{Protheus.doc} showConsoleMsg
@author victor
@since 19/04/2016
@version 1.0
@param cMsg, characters, descricao
@type function
/*/
static function showConsoleMsg(cMsg)

	ConOut("[schExpRes - "+DtoC(Date())+" - "+Time()+" ] "+cMsg)

return

/*/{Protheus.doc} enviaSch
@author bolognesi
@since 10/03/2017
@version undefined
@param dDtOrc, date		, Data confirmação reserva virou orçamento (emissão-orçamento)
@param dDtLibPed, date	, Data liberação do pedido
@param dDtPed, date		, Data emissão do pedido
@type function
@description função para analisar as reservas e determinar se estão
em situações irregulares de acordo com definições/regras 
/*/
static function enviaSch(dDtOrc,dDtLibPed,dDtPed,dHoje)
	local lRet 			:= .F.
	local nDiasPed		:= GetNewPar('XX_DIASPED', 	3)
	local nDiaLibPed	:= GetNewPar('XX_LIBPED', 	7)

	//Reserva tem pedido
	if !empty(dDtPed)	
		//Pedido não foi liberado
		if empty(dDtLibPed)
			//Esta fora do prazo para librerar( .T. fora do prazo )
			lRet := ( u_DiffDay(StoD(dDtPed), dHoje ) >= nDiaLibPed )
		endif
		//Reserva não tem pedido
	else
		//Esta fora do prazo para virar pedido( .T. fora do prazo )
		lRet := ( u_DiffDay(StoD(dDtOrc), dHoje ) >= nDiasPed )
	endif

return(lRet)

/*/{Protheus.doc} retQryRes
@author bolognesi
@since 09/03/2017
@version 1.0
@type function
@description [RESERVA-SCH03]-Retorna a query utilizada para verificar as reservas  que
ainda não viraram pedido ou pedido não liberado.
/*/
static function retQryRes()

	local cRet := ""
	cRet += " SELECT "
	cRet += " ZP4.ZP4_CODIGO [NR_RESERVA], "
	cRet += " ZP4.ZP4_DATA	[DT_RESERVA], "
	cRet += " ISNULL(ZP5.ZP5_NUM, '')	[NR_ORC_PORTAL], "
	cRet += " ISNULL(SCJ.CJ_NUM, '')	[NR_ORC_INTERNO], "
	cRet += " CASE"
	cRet += " WHEN ZP5.ZP5_DATA IS NULL "
	cRet += " 	THEN "
	cRet += " 		CASE "
	cRet += " 			WHEN SCJ.CJ_EMISSAO IS NULL "	
	cRet += " 				THEN '' "
	cRet += " 			ELSE SCJ.CJ_EMISSAO	"
	cRet += " 		END "
	cRet += " 	ELSE ZP5.ZP5_DATA "
	cRet += " END				[DT_CONFIRM_RESERVA],	"
	cRet += " SC5.C5_EMISSAO	[DT_PEDIDO],"
	cRet += " SC6.C6_NUM		[NR_PEDIDO],"
	cRet += " SC5.C5_DATALIB	[DT_LIB_PEDIDO] "

	cRet += " FROM %ZP4.SQLNAME%  "

	/* RELACIONAMENTO COM PORTAL */
	cRet += " LEFT JOIN  %ZP6.SQLNAME% ON  "
	cRet += " %ZP6.XFILIAL%" 
	cRet += " AND ZP4.ZP4_CODIGO			= ZP6.ZP6_NUMRES "
	cRet += " AND ZP4.D_E_L_E_T_			= ZP6.D_E_L_E_T_ "
	cRet += " LEFT JOIN  %ZP5.SQLNAME%	"
	cRet += " ON  ZP6.ZP6_FILIAL			= ZP5.ZP5_FILIAL "
	cRet += " AND ZP6.ZP6_NUM				= ZP5.ZP5_NUM "
	cRet += " AND ZP6.D_E_L_E_T_			= ZP5.D_E_L_E_T_ "

	/* RELACIONAMENTO COM ORÇAMENTO */
	cRet += " LEFT JOIN %SCK.SQLNAME% ON  "
	cRet += " %SCK.XFILIAL% " 
	cRet += " AND ZP4.ZP4_CODIGO			= SCK.CK_ZZNRRES "
	cRet += " AND ZP4.D_E_L_E_T_			= SCK.D_E_L_E_T_ "
	cRet += " LEFT JOIN %SCJ.SQLNAME% ON  "
	cRet += " SCK.CK_FILIAL					= SCJ.CJ_FILIAL	"
	cRet += " AND SCK.CK_NUM				= SCJ.CJ_NUM "	
	cRet += " AND SCK.D_E_L_E_T_			= SCJ.D_E_L_E_T_ "

	/* RELACIONAMENTO COM PEDIDO */
	cRet += " LEFT JOIN %SC6.SQLNAME% ON "
	cRet += " %SC6.XFILIAL% "
	cRet += " AND ZP4.ZP4_CODIGO			= SC6.C6_ZZNRRES "
	cRet += " AND ZP4.D_E_L_E_T_			= SC6.D_E_L_E_T_ "
	cRet += " LEFT JOIN %SC5.SQLNAME% ON "
	cRet += " SC6.C6_FILIAL					= SC5.C5_FILIAL	"
	cRet += " AND SC6.C6_NUM				= SC5.C5_NUM "
	cRet += " AND SC6.D_E_L_E_T_			= SC5.D_E_L_E_T_ "

	cRet += " WHERE %ZP4.XFILIAL% "
	/* WAITING"1" CONFIRMED"2" EXPIRED"3" CANCELED"4" */
	cRet += " AND ZP4.ZP4_STATUS 			=  2 "
	cRet += " AND %ZP4.NOTDEL% "
	cRet += " ORDER BY ZP4.ZP4_DATA "

return(cRet)


/*/{Protheus.doc} chkSDC
//TODO Descrição auto-gerada.
@author bolognesi
@since 25/09/2017
@version 1.0
@type function
@description Função para validar o estorno de empenho da função de legado U_EmpSDC
/*/
static function chkSDC()
	local oSql			:= LibSqlObj():newLibSqlObj()
	local oSch 			:= nil
	local cQuery		:= ''
	local aReg			:= {}
	local lExecuta		:= GetNewPar('ZZ_RESEMP', .F.)

	if lExecuta
		cQuery := qrySDC()
		oSql:newAlias(cQuery)
		if oSql:hasRecords()
			oSch := cbcSchCtrl():newcbcSchCtrl()
			oSch:setIDEnvio('RESERVA_EMPENHO')
			oSch:addEmailTo('leonardo@cobrecom.com.br')
			oSch:setAssunto('[ Reservas Portal ] - Verificar Empenho')
			oSch:setSimple( .F. )
			oSch:setHtmlFile('\scheduleLayout\html\reservas_empenhos.html')
			while oSql:notIsEof()
				aReg := {}
				aadd(aReg, {'Wf.FilialEmpenho'		, oSql:getValue("FILIAL_EMPENHO")}) 
				aadd(aReg, {'Wf.Prod_Empenho'		, oSql:getValue("COD_PROD_EMPENHADO")}) 
				aadd(aReg, {'Wf.Acondicionamento'	, oSql:getValue("ACONDICIONAMENTO")}) 
				aadd(aReg, {'Wf.QtdEmpenhada'		, oSql:getValue("QUANTIDADE_EMPENHADA")}) 
				aadd(aReg, {'Wf.DataReserva'		, oSql:getValue("DATA_RESERVA")}) 
				aadd(aReg, {'Wf.ReservaPortal'		, oSql:getValue("NUMERO_RESERVA_PORTAL")}) 
				aadd(aReg, {'Wf.StatusReserva'		, oSql:getValue("STATUS_RESERVA")}) 
				aadd(aReg, {'Wf.PedidoPortal'		, oSql:getValue("PEDIDO_PORTAL")}) 
				aadd(aReg, {'Wf.StatusPortal'		, oSql:getValue("STATUS_PEDIDO_PORTAL")}) 
				aadd(aReg, {'Wf.PedidoInterno'		, oSql:getValue("PEDIDO_INTERNO")}) 
				aadd(aReg, {'Wf.StsPedInterno'		, oSql:getValue("STATUS_PEDIDO_INTERNO")}) 
				oSch:addDados(aReg)
				oSql:skip()
			endDo

			if !empty(aReg)
				oSch:schedule()
			endif

			FreeObj(oSch)
		endif
		oSql:close()
		FreeObj(oSql)
	endif
return(nil)


/*/{Protheus.doc} qrySDC
@author bolognesi
@since 25/09/2017
@version 1.0
@type function
@description Query utilizada na função chkSDC()
/*/
static function qrySDC()
	local cQry := ''

	cQry := " SELECT " 
	cQry += " 	SDC.DC_FILIAL				[FILIAL_EMPENHO], " 
	cQry += " 	SDC.DC_PRODUTO				[COD_PROD_EMPENHADO], "  
	cQry += " 	SDC.DC_LOCALIZ				[ACONDICIONAMENTO], " 
	cQry += " 	DC_QUANT					[QUANTIDADE_EMPENHADA], " 
	cQry += " 	CAST(ZP4.ZP4_DATA AS DATE)	[DATA_RESERVA], "
	cQry += " 	ZP4.ZP4_CODIGO				[NUMERO_RESERVA_PORTAL], "
	cQry += " 	CASE "
	cQry += " 		WHEN ZP4.ZP4_STATUS = '1' "
	cQry += " 			THEN 'AGUARDANDO' "
	cQry += " 		WHEN ZP4.ZP4_STATUS = '2' "
	cQry += " 			THEN 'CONFIRMADA' "
	cQry += " 		WHEN ZP4.ZP4_STATUS = '3' "
	cQry += " 			THEN 'EXPIRADA' "
	cQry += " 		WHEN ZP4.ZP4_STATUS= '4' "
	cQry += " 			THEN 'CANCELADA' "
	cQry += " 		ELSE 'N/I' "
	cQry += " 	END								[STATUS_RESERVA], "
	cQry += " 	ISNULL(ZP6.ZP6_NUM,'NÃO')		[PEDIDO_PORTAL], "
	cQry += " 	CASE "
	cQry += " 		WHEN ZP5.ZP5_NUM IS NULL "
	cQry += " 			THEN 'NÃO' "
	cQry += " 		ELSE " 
	cQry += " 			CASE "
	cQry += " 				WHEN ZP5.ZP5_STATUS = '0' "
	cQry += " 					THEN 'REVISÃO' "
	cQry += " 				WHEN ZP5.ZP5_STATUS = '1' "
	cQry += " 					THEN 'MANUTENÇÃO' "
	cQry += " 				WHEN ZP5.ZP5_STATUS = '2' "
	cQry += " 					THEN 'AGUARDANDO APROVAÇÃO' "
	cQry += " 				WHEN ZP5.ZP5_STATUS = '3' "
	cQry += "					THEN 'EM APROVAÇÃO' "
	cQry += " 				WHEN ZP5.ZP5_STATUS = '4' "
	cQry += " 					THEN 'AGUARDANDO CONFIRMAÇÃO' "
	cQry += " 				WHEN ZP5.ZP5_STATUS = '5' "
	cQry += " 					THEN 'CONFIRMADO' "
	cQry += " 				WHEN ZP5.ZP5_STATUS = '6' "
	cQry += " 					THEN 'NÃO APROVADO' "
	cQry += " 				WHEN ZP5.ZP5_STATUS = '7' "
	cQry += " 					THEN 'CANCELADO' "
	cQry += " 				WHEN ZP5.ZP5_STATUS = '8' "
	cQry += " 					THEN 'APROVAÇÃO TECNICA' "
	cQry += " 				WHEN ZP5.ZP5_STATUS = '9' "
	cQry += " 					THEN 'AGUARDANDO PROCESSAMENTO' "
	cQry += " 				WHEN ZP5.ZP5_STATUS = 'A' "
	cQry += " 					THEN 'EM PROCESSAMENTO' "
	cQry += " 				WHEN ZP5.ZP5_STATUS = 'B' "
	cQry += " 					THEN 'ERRO PROCESSAMENTO' "
	cQry += " 			END "
	cQry += " 	END								[STATUS_PEDIDO_PORTAL], "	
	cQry += " 	ISNULL(SC6.C6_NUM, 'NÃO')		[PEDIDO_INTERNO], "
	cQry += " 	CASE "
	cQry += " 		WHEN SC5.C5_NUM IS NULL "
	cQry += " 			THEN 'NÃO' "
	cQry += " 		ELSE "
	cQry += " 			CASE "
	cQry += " 				WHEN SC5.C5_LIBEROK = 'E' OR SC5.C5_NOTA <> '' OR SC6.C6_BLQ = 'R ' OR SC6.C6_QTDENT >= SC6.C6_QTDVEN "
	cQry += " 					THEN 'ENCER./CANC./BLOQ.' "
	cQry += " 				ELSE 'EM ABERTO' "
	cQry += " 			END "											
	cQry += " 	END								[STATUS_PEDIDO_INTERNO] "
	cQry += "  FROM %SDC.SQLNAME%  "
	// RESERVAS
	cQry += " LEFT JOIN %ZP4.SQLNAME% ON "
	cQry += " SDC.DC_FILIAL			= ZP4.ZP4_FILIAL " 
	cQry += " AND SDC.DC_PEDIDO 	= ZP4.ZP4_CODIGO "
	cQry += " AND SDC.D_E_L_E_T_ 	= ZP4.D_E_L_E_T_ " 
	// ITENS PORTAL
	cQry += " LEFT JOIN %ZP6.SQLNAME% ON " 
	cQry += " ZP6.ZP6_FILIAL IN ('','01','02') "
	cQry += " AND ZP4.ZP4_CODIGO 	= ZP6.ZP6_NUMRES "
	cQry += " AND ZP4.D_E_L_E_T_ 	= ZP6.D_E_L_E_T_ "
	// CABEÇALHO PORTAL
	cQry += " LEFT JOIN %ZP5.SQLNAME% ON "
	cQry += " ZP5.ZP5_FILIAL IN ('','01','02') " 
	cQry += " AND ZP6.ZP6_NUM 		= ZP5.ZP5_NUM "
	cQry += " AND ZP6.D_E_L_E_T_ 	= ZP5.D_E_L_E_T_ "
	// ITENS PEDIDO
	cQry += " LEFT JOIN %SC6.SQLNAME% ON "
	cQry += " SDC.DC_FILIAL			= SC6.C6_FILIAL " 
	cQry += " AND ZP6.ZP6_NUMRES 	= SC6.C6_ZZNRRES "
	cQry += " AND ZP6.D_E_L_E_T_ 	= SC6.D_E_L_E_T_ "
	// CABEÇALHO PEDIDO
	cQry += " LEFT JOIN %SC5.SQLNAME% ON "
	cQry += " SC6.C6_FILIAL			= SC5.C5_FILIAL " 
	cQry += " AND SC6.C6_NUM		= SC5.C5_NUM "
	cQry += " AND SC6.D_E_L_E_T_  	= SC5.D_E_L_E_T_ "

	cQry += " WHERE SDC.DC_ORIGEM = 'ZP4' "
	cQry += " AND %SDC.NOTDEL% "
return(cQry)


user function manResSc() //U_manResSc
	oResSch := CbcReserveManager():newCbcReserveManager()
	oResSch:SchExpire()
	FreeObj(oResSch)
return(nil)
