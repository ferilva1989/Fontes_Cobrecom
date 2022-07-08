#INCLUDE "TOPCONN.CH" 
#INCLUDE "RWMAKE.CH" 

/*
------------------------------------------------------------------------------------------------------------
RF Consultoria e Informatica Ltda.
------------------------------------------------------------------------------------------------------------
Nome do Módulo............: Gestão de Pessoal
Nome das Tabelas Acessadas: SRA
Nome do Programa..........: TerTurno 
Parâmetros de Entrada.....: 
Parâmetros de Saída.......: 
------------------------------------------------------------------------------------------------------------
Objetivo do Programa......: Alteracao da quantidade de horas de adicional noturno, conforme a quantidade de 
: horas normais da folha para empregados horistas do terceiro turno.
: Conforme visto com a empresa, a contabilidade, paga a mesma quantidade de horas
: de adicional noturno, que a quantidade de horas normais, fora da regra   padrao 
: da Legislacao.
:
: O campo de Terceiro Turno, no cadastro de funcionarios deve estar    preenchido
: para os participantes da regra.
------------------------------------------------------------------------------------------------------------
Histórico                                                        |    Data      |  Executado por   | Chamado
------------------------------------------------------------------------------------------------------------
- Criação (RF)                                                     08.01.2015      FABIANO CARA             
- Acerto Verbas de DSR de Adicional Fixo						   26.06.2015	   JULIANA LEME	
------------------------------------------------------------------------------------------------------------
*/                 

/*/{Protheus.doc} TerTurno
//TODO Alteracao da quantidade de horas de adicional noturno, conforme a quantidade de 
: horas normais da folha para empregados horistas do terceiro turno.
: Conforme visto com a empresa, a contabilidade, paga a mesma quantidade de horas
: de adicional noturno, que a quantidade de horas normais, fora da regra   padrao 
: da Legislacao.
:
: O campo de Terceiro Turno, no cadastro de funcionarios deve estar    preenchido
: para os participantes da regra.
@author RF Consultoria e Informatica Ltda.
@since 08/01/2015
@version undefined

@type function
/*/
User Function TerTurno()

	SetPrvt("xVlr"    , "xHrs"    , "xVal"    , "xVal1", "xSalario", "xHrsMes" )
	SetPrvt("xVlr144" , "xVlr299" , "xVlr262" , "xVlr778", "xVlr779", "xVlr780" )

	///////////////////////////////
	xVlr     := 0
	xHrs     := 0
	xVal     := 0
	xVal1    := 0
	xSalario := 0
	xHrsMes  := 0
	xVlr144  := 0
	xVlr262  := 0
	xVlr299  := 0
	xVlr778  := 0
	xVlr779  := 0
	xVlr780  := 0
	xHrs     := fBuscAPD("102", "H" )
	xVal     := SRA->RA_SALARIO                             
	xMat     := SRA->RA_MAT
	
	If SRA->RA_CATFUNC = "H" 
		If SRA->RA_TERTUR = "S" 
			fDelpd("144")
			fDelpd("299")
			fDelpd("262")     
			fDelpd("146")                                     
			If SRA->RA_SINDICA = "03" .AND. SRA->RA_FILIAL <> "02"
				// Geracao de Verba de 20%
				xHrs    := fBuscAPD("102", "H" )
				xVal    := SRA->RA_SALARIO                       
				xval1   := (xVal * 0.20) * xHrs               
				fGeraVerba("299",xVal1,xHrs,,,"H",,,,,.F.)  
				//Alimentação verbas de DSR de Adicional Noturno - Juliana 26/06/2015				
				xHrs    := fBuscAPD("103", "H" )
				xVal    := SRA->RA_SALARIO                       
				xval1   := (xVal * 0.20) * xHrs 
				fGeraVerba("146",xVal1,xHrs,,,"H",,,,,.F.)
				//Fim
			EndIf
			// Geracao de Verba de 50%
			If SRA->RA_FILIAL == "01" .and. SRA->RA_MAT == "000011"
				xHrs    := fBuscAPD("102", "H" )
				xVal    := SRA->RA_SALARIO                       
				xval1   := (xVal * 0.50) * xHrs               
				fGeraVerba("262",xVal1,xHrs,,,"H",,,,,.F.)    
				//Alimentação verbas de DSR de Adicional Noturno - Juliana 26/06/2015
				xHrs    := fBuscAPD("103", "H" )
				xVal    := SRA->RA_SALARIO                       
				xval1   := (xVal * 0.50) * xHrs               
				fGeraVerba("146",xVal1,xHrs,,,"H",,,,,.F.)
				//Fim
			EndIf
			// Geracao de Verba 35% 
			If  SRA->RA_FILIAL == "01" .AND. SRA->RA_MAT <> "000011" .AND. SRA->RA_SINDICA <> "03"
				xHrs    := fBuscAPD("102", "H" )
				xVal    := SRA->RA_SALARIO                       
				xval1   := (xVal * 0.35) * xHrs               
				fGeraVerba("144",xVal1,xHrs,,,"H",,,,,.F.) 	  
				//Alimentação verbas de DSR de Adicional Noturno - Juliana 26/06/2015 
				xHrs    := fBuscAPD("103", "H" )
				xVal    := SRA->RA_SALARIO                       
				xval1   := (xVal * 0.35) * xHrs               
				fGeraVerba("146",xVal1,xHrs,,,"H",,,,,.F.)
				//Fim
			EndIf
			// Tratamento da Filial 3 lagoas 
			If  SRA->RA_FILIAL == "02" 
				xHrs    := fBuscAPD("102", "H" )
				xVal    := SRA->RA_SALARIO                       
				xval1   := (xVal * 0.20) * xHrs              
				fGeraVerba("299",xVal1,xHrs,,,"H",,,,,.F.) 
				xHrs    := fBuscAPD("103", "H" )
				xVal    := SRA->RA_SALARIO                       
				xval1   := (xVal * 0.20) * xHrs 
				fGeraVerba("146",xVal1,xHrs,,,"H",,,,,.F.)   
				//Fim
			EndIf                               
		EndIf      
		                             
		If fBuscAPD("299", "H" ) > 0
			xHrs    := (fBuscAPD("103", "H" ) * fBuscAPD("299", "H" ))/fBuscAPD("102", "H" )
			xVal    := SRA->RA_SALARIO                       
			xval1   := (xVal * 0.20) * xHrs 
			fGeraVerba("146",xVal1,xHrs,,,"H",,,,,.F.)   
		EndIf
	EndIf
Return(xVal1)                 

/*/{Protheus.doc} DescTerTun
//TODO Realiza os descontos das verbas de descontos para o adicional noturno que esta sendo pago integralmente.
@author RF Consultoria e Informatica Ltda.
@since 08/01/2015
@version undefined

@type function
/*/
User Function DescTerTun()
	SetPrvt("xVlr"    , "xHrs"    , "xVal"    , "xVal1", "xSalario", "xHrsMes" )
	xVlr     := 0
	xHrs     := 0
	xVal     := 0
	xVal1    := 0
	xSalario := 0
	xHrsMes  := 0
	xVlr144  := 0
	xVlr262  := 0
	xVlr299  := 0
	xVlr778  := 0
	xVlr779  := 0
	xVlr780  := 0
	xHrs     := 0
	xVal     := SRA->RA_SALARIO                             
	xMat     := SRA->RA_MAT                            
	xPerc	 := 0.35

	If SRA->RA_CATFUNC = "H" 
		If SRA->RA_TERTUR = "S"      
			//Validacao das porcentagens diferentes
			If SRA->RA_SINDICA = "03"
				xPerc := 0.20
			ElseIf SRC->RC_MAT == "000011"
				xPerc := 0.50
			Else
				If SRC->RC_FILIAL == "01"
					xPerc := 0.35
				Else
					xPerc := 0.20
				EndIf
			EndIf

			//Falta		
			If fBuscAPD("420", "H" ) <> 0 
				xHrs    := IIf(fBuscAPD("420", "H" )<0,fBuscAPD("420", "H" )*-1,fBuscAPD("420", "H" ))
				xVal    := SRA->RA_SALARIO                       
				xVal1   := (xVal * xPerc) * xHrs 
				fGeraVerba("543",xVal1,xHrs,,,"H",,,,,.F.) 				
			EndIf  
			//Atraso 
			If fBuscAPD("421", "H" ) <> 0
				xHrs    := IIf(fBuscAPD("421", "H" )<0,fBuscAPD("421", "H" )*-1,fBuscAPD("421", "H" ))      
				xVal    := SRA->RA_SALARIO                       
				xVal1   := (xVal * xPerc) * xHrs 
				If SRC->RC_FILIAL == "01"
					fGeraVerba("425",xVal1,xHrs,,,"H",,,,,.F.)
				Else
					fGeraVerba("580",xVal1,xHrs,,,"H",,,,,.F.)
				EndIf 				
			EndIf
			//Desconto DSR	
			If fBuscAPD("423", "H" ) <> 0
				xHrs    := IIf(fBuscAPD("423", "H" )<0,fBuscAPD("423", "H" )*-1,fBuscAPD("423", "H" ))
				xVal    := SRA->RA_SALARIO                       
				xVal1   := (xVal * xPerc) * xHrs 
				fGeraVerba("424",xVal1,xHrs,,,"H",,,,,.F.) 				
			EndIf
			//Saida Antecipada					
			If fBuscAPD("487", "H" ) <> 0
				xHrs    := IIf(fBuscAPD("487", "H" )<0,fBuscAPD("487", "H" )*-1,fBuscAPD("487", "H" ))
				xVal    := SRA->RA_SALARIO                       
				xVal1   := (xVal * xPerc) * xHrs 
				fGeraVerba("587",xVal1,xHrs,,,"H",,,,,.F.) 
			EndIf                                                                                                     ?
			//Saida Exediente
			If fBuscAPD("488", "H" ) <> 0
				xHrs    := IIf(fBuscAPD("488", "H" )<0,fBuscAPD("488", "H" )*-1,fBuscAPD("488", "H" ))
				xVal    := SRA->RA_SALARIO                       
				xVal1   := (xVal * xPerc) * xHrs 
				fGeraVerba("588",xVal1,xHrs,,,"H",,,,,.F.) 
			EndIf          
		EndIf
	EndIf
Return