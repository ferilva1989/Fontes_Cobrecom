#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWEBSRV.CH'
#INCLUDE 'TOPCONN.CH'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Fun��es Auxiliares  �Autor  �Leonardo � Data �  05/08/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso Utiliza��o generica       � AP                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

user function stsPedido()  //u_stsPedido() 
	/*
	Local _nVlSaldo    := 0
	Local _Filial	   :="01"
	Local _NumPed      :="113922"
	Local _cOcorrencia := ""
	Local _Blq         := ""
	Local _lTemSC9     := .T.
	Local aRet	:= Array(2)// RETORNO - STATUS E MENSAGEM
	local cCod	:= "" // B=BLOQUEADO, A=APROVADO, F=FATURADO, E=ENCERRADO, R=REJEITADO

	dbSelectarea("SC5")
	dbSelectarea("SC9")
	dbSelectarea("SC6")

	SC5->(dbSetOrder(1)) // FILIAL+PEDIDO
	SC9->(DbSetOrder(1)) // FILIAL+PEDIDO+ITEM+SEQUEN+PRODUTO
	SC6->(dbSetOrder(1)) // FILIAL+PEDIDO+ITEM+Produto

	if SC5->(dbSeek(_Filial+_NumPed))
	if SC6->(dbSeek(_Filial+_NumPed))
	While !SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM)==_Filial+_NumPed
	If _lTemSC9
	_lTemSC9 := SC9->(DbSeek(_Filial+_NumPed+SC6->C6_ITEM,.F.))
	EndIf

	If SC5->C5_LIBEROK # "E" .And. SC6->(C6_QTDVEN-C6_QTDENT) > 0 // aqui verificar o campo C6_QTDVEN
	_nVlSaldo += SC6->(C6_QTDVEN-C6_QTDENT * C6_PRCVEN) 
	//_nVlSaldo += SC6->((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN)
	EndIF

	If SC6->C6_BLQ == "R " .And. Empty(_Blq)
	_Blq := SC6->C6_BLQ
	EndIf
	SC6->(dbSkip())
	EndDo

	EndIf

	EndIf
	*/

RETURN .T.


