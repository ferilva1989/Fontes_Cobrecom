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


	//Se parâmetros nulos, aborto a execução do PE do MVC
	If aParam != Nil
		oObjForm := aParam[1]
		cIdExec := aParam[2]
		cIdForm := aParam[3]
		
		// Validação total do modelo - MODELPOS		
		If cIdExec == 'MODELPOS'
			
			
			// Para validação de exclusão, utilizar a constante MODEL_OPERATION_INSERT e o método GetOperation()			
			If oObjForm:GetOperation() == MODEL_OPERATION_INSERT // Equivale ao FA010INC
				//Alert('Apenas para exemplificar que, na inclusão de um novo registro, essa validação pode ser utilizada para confirmar ou não a gravação')
				//xRet := .T.
			EndIf
			
			
			// Para validação de exclusão, utilizar a constante MODEL_OPERATION_UPDATE e o método GetOperation()			
			If oObjForm:GetOperation() == MODEL_OPERATION_UPDATE // Equivale ao FA010ALT
				//Alert('Apenas para exemplificar que, na alteração de um novo registro, essa validação pode ser utilizada para confirmar ou não a gravação')
				//xRet := .T.
			EndIf
			
		
			// Para validação de exclusão, utilizar a constante MODEL_OPERATION_DELETE e o método GetOperation()			
			If oObjForm:GetOperation() == MODEL_OPERATION_DELETE // Equivale ao F010CAND e ao F10NATDEL
				//Alert('Execução da pós validação do model quando executado o "Delete"')
				//Help(,,'Pontos de Entrada MVC',,'Help do pós valid do MVC após validação do ponto de entrada default do MVC',1,0)
				//xRet := .F.
			EndIf
			
		
		// Antes da gravação da tabela do formulário - FORMCOMMITTTSPRE
		ElseIf cIdExec == 'FORMCOMMITTTSPRE'
			
			
			// Para gravações adicionais antes da inclusão, utilizar a constante MODEL_OPERATION_INSERT e o método GetOperation()
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
				//Alert('A inclusão pode ter dados manipulados como gravação adicional neste momento, antes da confirmação da transação')
				xRet := Nil
			EndIf
			
			// Para gravações adicionais antes da alteração, utilizar a constante MODEL_OPERATION_INSERT e o método GetOperation()
			If oObjForm:GetOperation() == MODEL_OPERATION_UPDATE // Equivale ao FIN010ALT
				//Alert('A alteração pode ter dados manipulados como gravação adicional neste momento, antes da confirmação da transação')
				xRet := Nil
			EndIf
			
			// Para gravações adicionais antes da exclusão, utilizar a constante MODEL_OPERATION_INSERT e o método GetOperation()
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
					//1=Pesquisa //2=Visualização //3=Inclusão //4=Alteração //5=Exclusão
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
				//Alert('A exclusão pode ter dados manipulados como gravação adicional neste momento, antes da confirmação da transação')
				xRet := Nil
			EndIf 
		EndIf
	EndIf
Return xRet