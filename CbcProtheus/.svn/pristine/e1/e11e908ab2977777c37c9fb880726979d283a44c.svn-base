#include "rwmake.ch"
#include "TOPCONN.ch"

//Programa que gera numeração automatica para Produtos que o Tipo for diferente de "MP/PI/PA"
//Juliana - 26/12/2014
User Function CDGENG03()
	Local _nNum     := ""  
	Local _cCod		:= ""
	Local cQuery    := ""    
	If !(M->B1_TIPO $ "PA,MP,PI")   
		cQuery := " SELECT MAX(B1_COD) CODIGO FROM "+RetSqlName("SB1")+"  WHERE B1_COD LIKE '"+Alltrim(M->B1_GRUPO)+"%' "
		cQuery += " AND D_E_L_E_T_ = '' "
		cQuery += " AND B1_GRUPO = '"+Alltrim(M->B1_GRUPO)+"' "  

		TcQuery cQuery New Alias "TRB"

		dbSelectArea("TRB") 
		TRB->(dbGoTop())    

		If Alltrim(TRB->CODIGO) = ""
			_cCod :=  Alltrim(M->B1_GRUPO)+"000001"   
		Else         
			_nNum := Val(SubStr(TRB->CODIGO,5,10))+1
			_cCod  := Alltrim(M->B1_GRUPO)+StrZero(_nNum,6)   
		EndIf                

		TRB->(dbCloseArea())   
	EndIf
Return(_cCod)  


//Função para tratativa do Tipo Versus o Grupo, permitindo apenas que o grupo seja pertencente ao mesmo Tipo;
//Juliana - 29/12/2014
User function ValGroup()
	Local _lVolta := .T.
	If (M->B1_TIPO <> SUBSTR(M->B1_GRUPO,1,2)) 
		MessageBox("Grupo não permitido ao tipo '"+M->B1_TIPO+"', Favor Alterar!","Aviso",16)
		If!(M->B1_TIPO $ "PA,MP,PI")
			M->B1_COD  := ""
		EndIf 
		_lVolta    := .F.
	EndIf
Return(_lVolta)                          