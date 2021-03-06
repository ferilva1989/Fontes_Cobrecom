#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch" 

//Fina420
//Rotina de gera豫o de arquivo CNAB ao banco ( Contas a Pagar )	
*
************************
User Function F420SOMA()
	************************
	*      
	//PE que incrementa variavel nsomaValor que sera chamado por SomaValor()
	//nSomaValor += Execblock("F420SOMA",.F.,.F.)
	Return(u_PagaVlr())
	*
	************************
User Function F420ICNB()
	************************
	*
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?
	//? Ponto de entrada para tratamento da variavel cIdCnab     
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴?

	cIdCnab := ParamIXB[1]

	_aAreaX := GetArea()

	DbSelectArea("SE2")
	_aAreaSE2 := GetArea()

	DbSetOrder(13) // E2_IDCNAB  (sem a filial)
	Do While DbSeek(cIdCnab,.F.)
		ConfirmSX8() // Dou o confirm antes porque no fonte tem o confirm antes da grava豫o do E2_IDCNAB
		cIdCnab := GetSxENum("SE2", "E2_IDCNAB", "E2_IDCNAB"+cEmpAnt,13)
	EndDo
	RestArea(_aAreaSE2)
	RestArea(_aAreaX)
Return(cIdCnab)