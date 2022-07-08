#INCLUDE "rwmake.ch"

/*/{Protheus.doc} Excel
@author legado
@since 21/07/2017
@version undefined
@param _cNomArq, , descricao
@type function
@description Função abre TRB passado pelo parametro em excel  
/*/
User Function Excel(_cNomArq)

	If MsgBox("Deseja abrir em Excel ?","Confirma?","YesNo")

		aFiles := ARRAY(ADIR("C:\INTEGRA\*.*"))
		ADIR("C:\INTEGRA\*.*",aFiles)
		If Len(aFiles) == 0
			MAKEDIR("C:\INTEGRA") //  --> Numérico
		EndIf

		// Abrir o TRB no excel
		CPYS2T(_cNomArq,"C:\INTEGRA",.F.)
		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open("C:\INTEGRA\"+_cNomArq)
		oExcelApp:SetVisible(.T.)

	EndIf

Return(.T.)