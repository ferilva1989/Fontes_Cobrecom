#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'


/*/{Protheus.doc} FINA010
//Ponto de Entrada MVC do FINA010
@author alexandre.madeira
@since 04/04/2018
@version 1.0
@return Nil
@type function
/*/
User Function FINA010()

Local aParam 		:= PARAMIXB
Local xRet 			:= .T.
Local oObjForm
Local cIdExec		:= ""
Local cIdForm		:= ""
Local _aArea
Local _aAreaCTH
Local oExec 		:= Nil 
Local aDadosAuto	:= {}
Local aRet			:= {}


	//Se par�metros nulos, aborto a execu��o do PE do MVC
	If aParam != Nil
		oObjForm := aParam[1]
		cIdExec := aParam[2]
		cIdForm := aParam[3]
		
		// Valida��o total do modelo - MODELPOS		
		If cIdExec == 'MODELPOS'
			
			
			// Para valida��o de exclus�o, utilizar a constante MODEL_OPERATION_INSERT e o m�todo GetOperation()			
			If oObjForm:GetOperation() == MODEL_OPERATION_INSERT // Equivale ao FA010INC
				//Alert('Apenas para exemplificar que, na inclus�o de um novo registro, essa valida��o pode ser utilizada para confirmar ou n�o a grava��o')
				//xRet := .T.
			EndIf
			
			
			// Para valida��o de exclus�o, utilizar a constante MODEL_OPERATION_UPDATE e o m�todo GetOperation()			
			If oObjForm:GetOperation() == MODEL_OPERATION_UPDATE // Equivale ao FA010ALT
				//Alert('Apenas para exemplificar que, na altera��o de um novo registro, essa valida��o pode ser utilizada para confirmar ou n�o a grava��o')
				//xRet := .T.
			EndIf
			
		
			// Para valida��o de exclus�o, utilizar a constante MODEL_OPERATION_DELETE e o m�todo GetOperation()			
			If oObjForm:GetOperation() == MODEL_OPERATION_DELETE // Equivale ao F010CAND e ao F10NATDEL
				//Alert('Execu��o da p�s valida��o do model quando executado o "Delete"')
				//Help(,,'Pontos de Entrada MVC',,'Help do p�s valid do MVC ap�s valida��o do ponto de entrada default do MVC',1,0)
				//xRet := .F.
			EndIf
			
		
		// Antes da grava��o da tabela do formul�rio - FORMCOMMITTTSPRE
		ElseIf cIdExec == 'FORMCOMMITTTSPRE'
			
			
			// Para grava��es adicionais antes da inclus�o, utilizar a constante MODEL_OPERATION_INSERT e o m�todo GetOperation()
			If oObjForm:GetOperation() == MODEL_OPERATION_INSERT // Equivale ao FIN010INC
				
				aDadosAuto:= { 	{'CTH_CLVL' 	 	, oObjForm:GetValue('ED_CODIGO')	, Nil},;
								{'CTH_CLASSE' 		, oObjForm:GetValue('ED_TIPO') 		, Nil},;
								{'CTH_DESC01' 		, oObjForm:GetValue('ED_DESCRIC')	, Nil},;
								{'CTH_CLSUP'  		, oObjForm:GetValue('ED_PAI') 		, Nil}}
				
				Begin Transaction
				
				//MSExecAuto({|x, y| CTBA060(x, y)},aDadosAuto, 3)
				
				oExec := cbcExecAuto():newcbcExecAuto(aDadosAuto,/*aHdr*/,.T.)
				oExec:exAuto('CTBA060',3)
				aRet := oExec:getRet()			
				If !aRet[1]
					Alert('ERRO: ' + aRet[2] )
					DisarmTransaction()
				Else
					//OK
					//Preencher o campo com o classe de valor recem criada
					oObjForm:SetValue("ED_CLVLDB", PadR(oObjForm:GetValue('ED_CODIGO'), TamSX3("ED_CLVLDB")[1]))				
				EndIf
				
				End Transaction			
				//Alert('A inclus�o pode ter dados manipulados como grava��o adicional neste momento, antes da confirma��o da transa��o')
				xRet := Nil
			EndIf
			
			// Para grava��es adicionais antes da altera��o, utilizar a constante MODEL_OPERATION_INSERT e o m�todo GetOperation()
			If oObjForm:GetOperation() == MODEL_OPERATION_UPDATE // Equivale ao FIN010ALT
				//Alert('A altera��o pode ter dados manipulados como grava��o adicional neste momento, antes da confirma��o da transa��o')
				xRet := Nil
			EndIf
			
			// Para grava��es adicionais antes da exclus�o, utilizar a constante MODEL_OPERATION_INSERT e o m�todo GetOperation()
			If oObjForm:GetOperation() == MODEL_OPERATION_DELETE // Equivale ao FIN010EXC
				_aArea   	:= GetArea()
				_aAreaCTH := CTH->(GetArea())			
				
				DbSelectArea("CTH")
				CTH->(DbSetOrder(1)) // CTH_FILIAL + CTH_CLVL
				
				If CTH->(dbseek(xFilial("CTH")+ oObjForm:GetValue('ED_CODIGO'), .F.) )
					
					aDadosAuto:= { 	{'CTH_CLVL' 	 	, oObjForm:GetValue('ED_CODIGO')	, Nil},;
									{'CTH_CLASSE' 		, oObjForm:GetValue('ED_TIPO') 		, Nil},;
									{'CTH_DESC01' 		, oObjForm:GetValue('ED_DESCRIC')	, Nil},;
									{'CTH_CLSUP'  		, oObjForm:GetValue('ED_PAI') 		, Nil}}
				
					
					Begin Transaction					
					oExec := cbcExecAuto():newcbcExecAuto(aDadosAuto,/*aHdr*/,.T.)
					//1=Pesquisa //2=Visualiza��o //3=Inclus�o //4=Altera��o //5=Exclus�o
					oExec:exAuto('CTBA060',5)
					aRet := oExec:getRet()			
					If !aRet[1]
						//Alert('ERRO: ' + aRet[2] )
						DisarmTransaction()		
					EndIf					
					End Transaction					
				EndIf				
				//Devolve as areas
				RestArea(_aArea)
				RestArea(_aAreaCTH)				
				//Alert('A exclus�o pode ter dados manipulados como grava��o adicional neste momento, antes da confirma��o da transa��o')
				xRet := Nil
			EndIf 
		EndIf
	EndIf
Return xRet