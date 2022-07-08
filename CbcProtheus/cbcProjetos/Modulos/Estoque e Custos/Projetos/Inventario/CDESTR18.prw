#INCLUDE "rwmake.ch"

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �NOVO5     � Autor � AP6 IDE            � Data �  02/03/09   ���
�������������������������������������������������������������������������͹��
���Descricao � Codigo gerado pelo AP6 IDE.                                ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP6 IDE                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

User Function CDESTR18()


	//���������������������������������������������������������������������Ŀ
	//� Declaracao de Variaveis                                             �
	//�����������������������������������������������������������������������

	Local cDesc1         := "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2         := "de acordo com os parametros informados pelo usuario."
	Local cDesc3         := "Comp.Saldos x Inventario"
	Local cPict          := ""     
	Local titulo       := "Comp.Saldos x Inventario"
	Local nLin         := 80

	Local Cabec1       := "Codigo     Descricao                              Acond.   Qtd.Atual  Qtd.Invent"
	Local Cabec2       := ""
	Local imprime      := .T.
	Local aOrd := {}
	Private lEnd         := .F.
	Private lAbortPrint  := .F.
	Private CbTxt        := ""
	Private limite           := 80
	Private tamanho          := "P"
	Private nomeprog         := "CDESTR18" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo            := 18
	Private aReturn          := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey        := 0
	Private cbtxt      := Space(10)
	Private cbcont     := 00
	Private CONTFL     := 01
	Private m_pag      := 01
	Private wnrel      := "CDESTR18" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cPerg       := "CDGN09"   // Pergunta Padrao Especificada

	Private cString := "SBF"
	dbSelectArea("SBF")
	dbSetOrder(1)


	//���������������������������������������������������������������������Ŀ
	//� Monta a interface padrao com o usuario...                           �
	//�����������������������������������������������������������������������
	Pergunte(cPerg, .F.)
	wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

	//���������������������������������������������������������������������Ŀ
	//� Processamento. RPTSTATUS monta janela com a regua de processamento. �
	//�����������������������������������������������������������������������

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Fun��o    �RUNREPORT � Autor � AP6 IDE            � Data �  02/03/09   ���
�������������������������������������������������������������������������͹��
���Descri��o � Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS ���
���          � monta a janela com a regua de processamento.               ���
�������������������������������������������������������������������������͹��
���Uso       � Programa principal                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

	Local nOrdem                           

	DbSelectArea("SB1")
	DbSetOrder(1) 

	DbSelectArea("SB7")
	DbSetOrder(1) // B7_FILIAL+DTOS(B7_DATA)+B7_COD+B7_LOCAL+B7_LOCALIZ+B7_NUMSERI+B7_LOTECTL+B7_NUMLOTE

	dbSelectArea("SBF")
	dbSetOrder(2) // BF_FILIAL+BF_PRODUTO+BF_LOCAL+BF_LOTECTL+BF_NUMLOTE+BF_PRIOR+BF_LOCALIZ+BF_NUMSERI

	SetRegua(RecCount())

	//���������������������������������������������������������������������Ŀ
	//� Posicionamento do primeiro registro e loop principal. Pode-se criar �
	//� a logica da seguinte maneira: Posiciona-se na filial corrente e pro �
	//� cessa enquanto a filial do registro for a filial corrente. Por exem �
	//� plo, substitua o dbGoTop() e o While !EOF() abaixo pela sintaxe:    �
	//�                                                                     �
	//� dbSeek(xFilial())                                                   �
	//� While !EOF() .And. xFilial() == A1_FILIAL                           �
	//�����������������������������������������������������������������������

	DbSeek(xFilial("SBF",.F.))
	Do While SBF->BF_FILIAL == xFilial("SBF") .And. SBF->(!EOF())

		//���������������������������������������������������������������������Ŀ
		//� Verifica o cancelamento pelo usuario...                             �
		//�����������������������������������������������������������������������

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

		//���������������������������������������������������������������������Ŀ
		//� Impressao do cabecalho do relatorio. . .                            �
		//�����������������������������������������������������������������������

		DbSelectArea("SB7")
		DbSeek(xFilial("SB7") + DTOS(MV_PAR01) + SBF->BF_PRODUTO + SBF->BF_LOCAL + SBF->BF_LOCALIZ,.F.)
		_nB7_QUANT := 0
		Do While SB7->B7_FILIAL == xFilial("SB7") .And. SB7->B7_DATA == MV_PAR01 .And. ;
		SB7->B7_COD + SB7->B7_LOCAL + SB7->B7_LOCALIZ == SBF->BF_PRODUTO + SBF->BF_LOCAL + SBF->BF_LOCALIZ .And. SB7->(!Eof())

			_nB7_QUANT += SB7->B7_QUANT
			SB7->(DbSkip())
		EndDo          
		If SBF->BF_QUANT > 0 .And. _nB7_QUANT == 0

			If nLin > 55 // Salto de P�gina. Neste caso o formulario tem 55 linhas...
				Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
				nLin := 8
			Endif

			SB1->(DbSeek(xFilial("SB1")+ SBF->BF_PRODUTO,.F.))
			@ nLin,00 PSAY Left(SBF->BF_PRODUTO,10)
			@ nLin,11 PSAY Left(u_CortaDesc(SB1->B1_DESC),38)
			@ nLin,50 PSAY Left(SB7->B7_LOCALIZ,6)
			@ nLin,58 PSAY SBF->BF_QUANT Picture "@E 99,999,999"
			@ nLin,70 PSAY _nB7_QUANT    Picture "@E 99,999,999"
			nLin := nLin + 1 // Avanca a linha de impressao
		EndIf
		SBF->(DbSkip()) // Avanca o ponteiro do registro no arquivo
	EndDo

	//���������������������������������������������������������������������Ŀ
	//� Finaliza a execucao do relatorio...                                 �
	//�����������������������������������������������������������������������

	SET DEVICE TO SCREEN

	//���������������������������������������������������������������������Ŀ
	//� Se impressao em disco, chama o gerenciador de impressao...          �
	//�����������������������������������������������������������������������

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

Return(.T.)
