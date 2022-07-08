#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
                
/*/{Protheus.doc} CdPon070
//TODO Por forca de convencao coletiva de trabalho este cliente necessita que horas 
                            efetuadas, no horário de almoço, com 1/2 hora, sejam remuneradas com hora cheia
                            ou seja, 1 hora completa.
                            Este ponto de entrada é executado na chamada do calculo mensal, alterando o
                            Resultado, de uma só vez, das pessoas que atendam esta condicao.
                            
                            ==>> Adequacao do Ponto de Entrada para Tratamento de Horas Extras Noturnas.
                                 Adequacao ao Sistema da Contabilidade..
@author RF Consultoria
@since 23/01/2012
@version undefined

@type function
/*/
User Function PONCALM()
		
	// Execução da query principal, para filtrar os funcionarios nesta condição.
	DbSelectArea("SPC")
	DbSetOrder(1) //PC_FILIAL+PC_MAT+PC_PD+DTOS(PC_DATA)+PC_TPMARCA+PC_CC+PC_DEPTO+PC_POSTO+PC_CODFUNC
	
	_xVerba := If(xFilial("SPC") == "01","'019','094','356'","'022'")
	
	cQuery	:= " SELECT PC_FILIAL AS FILIAL, PC_MAT AS MATRICULA, PC_DATA AS XDATA, PC_PD AS VERBA, PC_QUANTC AS QTDADE, R_E_C_N_O_ as NUMREG " 
	cQuery  += " FROM " + RetSqlName("SPC")  
	cQuery  += " WHERE PC_FILIAL = '"+xFilial("SPC") + "'"
	cQuery  += " AND   PC_PD IN (" + _xVerba + ")" 
	cQuery  += " AND   PC_MAT = '" + SRA->RA_MAT + "'"
	cQuery  += " AND   PC_QUANTC >= 0.25 AND   PC_QUANTC < 1 " // Se o Resultado for maior ou igual a 0,35 transforma em uma hora. A quantidade de minutos desta verba e o Resultado
	cQuery  += " AND   D_E_L_E_T_ = ' '  " 
	
	cQuery  := ChangeQuery(cQuery)
	
	TCQUERY CQUERY NEW ALIAS "XRA"     
	
	DbSelectArea("XRA")
	DbGotop()
	
	Do While XRA->(!EOF())
		//
		SPC->(DbGoTo(XRA->NUMREG))
		RecLock("SPC",.F.)
		SPC->PC_QUANTC := 1.00
		SPC->(MsUnlock())
		XRA->(DBSKIP())
	ENDDO
	DbSelectArea("XRA")
	DbCloseArea()  
	
	u_Converte()
	     
	//Atualiza Apontamentos	
	//PONM070()                                                                                    
Return()