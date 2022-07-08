#include "PROTHEUS.CH"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CDFINA04  � Autor � Roberto Oliveira      � Data � 12/08/08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida��o do c�digo da Natureza Financeira                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CDFINA04(cNatureza)                                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cNatureza : Natureza a ser Pesquisada                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAFIN                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/                              
*********************************
User Function CDFINA04(cNatureza)
	*********************************
	*                                    
	SED->(DbSetOrder(1))
	_Volta := .F.
	If !SED->(DbSeek(xFilial("SED")+cNatureza,.F.))
		Alert("C�digo n�o Cadastrado")
		//ElseIf SED->ED_TIPO # "A"
	ElseIf !SED->ED_TIPO == "2"
		Alert("Use Somente Naturezas Tipo Anal�tica")
	Else
		_Volta := .T.
	EndIf
Return(_Volta)