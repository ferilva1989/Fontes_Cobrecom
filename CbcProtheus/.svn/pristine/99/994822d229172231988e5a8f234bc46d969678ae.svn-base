#include 'protheus.ch'

/*/
-------------------------------------------------------------------------------
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||---------------------------------------------------------------------------||
|| FUNCAO    | StVld04    | AUTOR |Edson Fernandes       | DATA | 19/11/2013 ||
||---------------------------------------------------------------------------||
|| DESCRIÇÃO | ROTINA PARA RETORNAR O STATUS DO PEDIDO DE VENDAS             ||
||---------------------------------------------------------------------------||
|| USO       | WEB                                                           ||
||---------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-------------------------------------------------------------------------------
/*/
USER Function StVld04(_Filial,_NumPed)

Local _nVlSaldo    := 0
Local _cOcorrencia := ""
Local _Blq         := ""
Local _lTemSC9     := .T.
Local aRet	:= Array(2)// RETORNO - STATUS E MENSAGEM
local cCod	:= "" // B=BLOQUEADO, A=APROVADO, F=FATURADO, E=ENCERRADO, R=REJEITADO

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
				//_nVlSaldo += SC6->(C6_QTDVEN-C6_QTDENT * C6_PRCVEN) //Precedência dos sinais
				_nVlSaldo += SC6->((C6_QTDVEN - C6_QTDENT) * C6_PRCVEN)
			EndIF
			
			If SC6->C6_BLQ == "R " .And. Empty(_Blq)
				_Blq := SC6->C6_BLQ
			EndIf
			SC6->(dbSkip())
		EndDo
		
		If _Blq == "R "
			_cOcorrencia  := "RESIDUO"
			cCod	:= "B" // B=BLOQUEADO, A=APROVADO, F=FATURADO, E=ENCERRADO
		
		ElseIf  !_lTemSC9
			_cOcorrencia  := "Bloq. Vendas"
			cCod	:= "B" // B=BLOQUEADO, A=APROVADO, F=FATURADO, E=ENCERRADO
		
		ElseIf _nVlSaldo > 0
			_cOcorrencia  := ""
			cCod	:= "B" // B=BLOQUEADO, A=APROVADO, F=FATURADO, E=ENCERRADO
			_nOcReal := 100
			If SC9->(DbSeek(_Filial+_NumPed,.F.))
				While SC9->(!Eof()) .and. SC9->C9_FILIAL == _Filial .And. SC9->C9_PEDIDO == SC5->C5_NUM
					If SC9->C9_BLCRED == "01" .And. _nOcReal > 1
						_nOcReal := 1
						Exit
					ElseIf SC9->C9_BLCRED == "09" .And. _nOcReal > 2
						_nOcReal := 2
					ElseIf SC9->C9_BLEST == "02" .And. _nOcReal > 3
						_nOcReal := 3
					ElseIf Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLEST) .And. _nOcReal > 4
						_nOcReal := 4
					ElseIf SC9->C9_BLCRED == "10" .And. _nOcReal > 5
						_nOcReal := 5
					EndIf
					SC9->(DbSkip())
				EndDo
				If _nOcReal == 1
					_cOcorrencia  := "BLQ.CREDITO"
					cCod	:= "B" // B=BLOQUEADO, A=APROVADO, F=FATURADO, E=ENCERRADO
				ElseIf _nOcReal == 2
					_cOcorrencia  := "REJEITADO"
					cCod	:= "R" // B=BLOQUEADO, A=APROVADO, F=FATURADO, E=ENCERRADO
				ElseIf _nOcReal == 3
					_cOcorrencia  := "BLQ.ESTOQUE"
					cCod	:= "B" // B=BLOQUEADO, A=APROVADO, F=FATURADO, E=ENCERRADO
				ElseIf _nOcReal == 4
					_cOcorrencia  := "LIB.P/FATUR"
					cCod	:= "A" // B=BLOQUEADO, A=APROVADO, F=FATURADO, E=ENCERRADO
				ElseIf _nOcReal == 5
					_cOcorrencia  := "FATURADO"
					cCod	:= "F" // B=BLOQUEADO, A=APROVADO, F=FATURADO, E=ENCERRADO
				else
					_cOcorrencia  := "FALTA BL"
					cCod	:= "B" // B=BLOQUEADO, A=APROVADO, F=FATURADO, E=ENCERRADO
				EndIf
			else
				_cOcorrencia  := "FALTA C9"
				cCod	:= "B" // B=BLOQUEADO, A=APROVADO, F=FATURADO, E=ENCERRADO
			endif
		Else
			_cOcorrencia  := "ENCERRADO"
			cCod	:= "E" // B=BLOQUEADO, A=APROVADO, F=FATURADO, E=ENCERRADO
		EndIF
	else
		_cOcorrencia  := "FALTA IT"
		cCod	:= "B" // B=BLOQUEADO, A=APROVADO, F=FATURADO, E=ENCERRADO
	Endif
else
	_cOcorrencia  := "FALTA PD"
	cCod	:= "B" // B=BLOQUEADO, A=APROVADO, F=FATURADO, E=ENCERRADO
Endif

aRet[1] := cCod
aRet[2] := _cOcorrencia

Return(aRet)

// -------------------------------------------------------------------------------
// FIM
// -------------------------------------------------------------------------------
