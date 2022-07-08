#include 'protheus.ch'
#include 'parmtype.ch'

user function CBCONASI()
	Local cVerbaRot := ""
	
	Begin Sequence
	
		If cFilAnt == "01" .and. SRA->RA_SINDICA <> "03" //Diferente dos sindicato dos metalurgicos
			cVerbaRot := "484"
		ElseIF cFilAnt == "01" .and. SRA->RA_SINDICA == "03" //Do sindicato dos metalurgicos
			cVerbaRot := "482"
		Else
			cVerbaRot := "482"
		EndIf
		
		IF ( SRA->RA_ASSIST == "1" )
			FCASSIST(ACODFOL,cVerbaRot)
		EndIF
	
	End Sequence
return