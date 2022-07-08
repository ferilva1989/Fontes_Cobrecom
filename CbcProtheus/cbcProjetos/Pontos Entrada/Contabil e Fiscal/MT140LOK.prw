#Include 'Protheus.ch'
#define DS_MODALFRAME 128

/*/{Protheus.doc} CDGvChv
//TODO Permite visualizar para copiar Chave da NFe selecionada.
@author juliana.leme
@since 22/06/2017
@version undefined

@type function
/*/
User Function CDGvChv()
	Private oGet1
	Private cGet1 	:= SF1->F1_CHVNFE
	Private oSay1
	Private Sair
	Private oDlg

	DEFINE MSDIALOG oDlg TITLE "Visualiza a Chave NFe" FROM 000, 000 TO 100, 400 COLORS 0, 16777215 PIXEL Style DS_MODALFRAME
	@ 010, 010 SAY oSay1 PROMPT "Chave NFe" SIZE 065, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 008, 044 MSGET oGet1 VAR cGet1 SIZE 140, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, 100 BUTTON Confirmar PROMPT "Confirmar" 	SIZE 037, 012 OF oDlg PIXEL Action GrvChvNFe(cGet1)
	ACTIVATE MSDIALOG oDlg CENTERED
Return

/*/{Protheus.doc} GrvChvNFe
//TODO Grava Chave da NFe na Pré-Nota.
@author juliana.leme
@since 22/06/2017
@version undefined
@param cNumChave, characters, descricao
@type function
/*/
Static Function GrvChvNFe(cNumChave)
	Default cNumChave := ""
		If cNumChave <> ""
			RecLock("SF1",.F.)
			SF1->F1_CHVNFE := cNumChave
			MsUnLock()
			u_autoAlert("Chave Gravada com Sucesso",,'Info')
		EndIf
		oDlg:End()
Return

/*/{Protheus.doc} MT140SAI
//TODO Ponto de entrada chamado na Confirmação da Gravação da Pré_nota.
@author juliana.leme
@since 22/06/2017
@version undefined

@type function
/*/
User Function MT140SAI()
	local nOrdem 	:= nil
	local aArea	 	:= nil
	local aAreaSF1	:= nil
	//PARAMIXB[1] = Numero da operação - ( 2-Visualização, 3-Inclusão, 4-Alteração, 5-Exclusão )
	//PARAMIXB[2] = Número da nota
	//PARAMIXB[3] = Série da nota
	//PARAMIXB[4] = Fornecedor
	//PARAMIXB[5] = Loja
	//PARAMIXB[6] = Tipo
	//PARAMIXB[7] = Opção de Confirmação (1 = Confirma pré-nota; 0 = Não Confirma pré-nota)
	if !FwIsInCallStack('COMCOLGER')
		nOrdem 		:= SF1->( IndexOrd() )
		aArea	 	:= GetArea()
		aAreaSF1	:= SF1->(GetArea())
		If ParamIxb[1] == 3
			SF1->(dbSetOrder(1))
			SF1->(MsSeek( xFilial( 'SF1' ) + ParamIxb[2] + ParamIxb[3] + ParamIxb[4] + ParamIxb[5]))
			//Grava Chave Nfe
			If Alltrim(SF1->F1_DOC) <> ""
				U_CDGvChv()
			EndIf
			SF1->(dbSetOrder(nOrdem))
		EndIf
		RestArea(aAreaSF1)
		RestArea(aArea)
	endif
Return( NIL )
