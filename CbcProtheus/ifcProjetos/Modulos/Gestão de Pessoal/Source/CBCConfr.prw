#include 'protheus.ch'
#include 'parmtype.ch'

user function CBCConfr()
	Begin Sequence
		if Empty(cVerbaRot)
			cVerbaRot:= fGetCodFol("0175")
		EndIf
		
		If SRA->RA_CONFED =="1"
			//Sindicato dos Motoristas
			IF FwFilial() == "01" .and. SRA->RA_SINDICA == "03" 
				cVerbaRot := "486"
				fCConfed(aCodFol,cVerbaRot)
			ElseIf  FwFilial() == "01" .and. SRA->RA_SINDICA == "02" 
				cVerbaRot := "486"
				fCConfed(aCodFol,cVerbaRot)
			Else
				fCConfed(aCodFol,cVerbaRot)
			EndIf
		EndIf
	End Sequence
return