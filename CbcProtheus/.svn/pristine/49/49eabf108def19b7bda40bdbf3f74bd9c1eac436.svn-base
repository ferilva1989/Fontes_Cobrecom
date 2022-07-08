#include "rwmake.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CDBAL06   ³ Autor ³ Roberto Oliveira      ³ Data ³20.02.2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rdmake para impressão de etiquetas para corte dos retraba-  ³±±
±±³          ³lhos da tabela ZZE.                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
***********************
User Function CDBAL06()
***********************
*
Local aCores := {}
Local cAlias := "ZZE"

Local cPict         := ""
Local nLin          := 80
Local Cabec1        := ""
Local Cabec2        := ""
Local imprime       := .T.
Local cDesc1        := "Este programa tem como objetivo imprimir relatorio "
Local cDesc2        := "de acordo com os parametros informados pelo usuario."
Local cDesc3        := "Etiquetas de Corte Retrabalho"
Local titulo        := "Etiquetas de Corte Retrabalho"
Local aOrd          := {}
Private tamanho     := "M"
Private nomeprog    := "CDBAL06"
Private cPerg       := ""
Private cString     := "ZZE"
Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt       := ""
Private limite      := 132
Private nTipo       := 15
Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey    := 0
Private cbtxt       := Space(10)
Private cbcont      := 00
Private CONTFL      := 01
Private m_pag       := 01
Private wnrel       := "CDBAL06"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
wnrel := SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)

If nLastKey == 27
	Return(.T.)
Endif

Private cCadastro 	:= "Impressão de Etiquetas de Retrabalho"
Private aRotina 	:= { {"Pesquisar" 		    ,"AxPesqui"  ,0,1} ,;
						{"Visualizar"		    ,"AxVisual"  ,0,2} ,;
						{"Legenda"	 			,"u_Bl06Leg" ,0,6} ,;
						{"Imprimir Etiqueta"	,"u_Bl06Etq" ,0,6} }


AADD(ACORES,{"ZZE_STATUS=='3'.And.ZZE_ETIQ$' N'","BR_VERDE"}) 	// A Imprimir
AADD(ACORES,{"ZZE_ETIQ  =='S'","BR_VERMELHO"})					// Já Impressa
AADD(ACORES,{"ZZE_ETIQ  # 'S'","BR_CINZA"})						// Não Imprimir

DbSelectArea(cAlias)
DbSeek(xFilial(cAlias),.F.)
mBrowse(6,1,22,75,cAlias,,,,,,aCores)

Return(.T.)
*
***********************
User Function Bl06Leg()
***********************
*
Local aLegenda	:= {}

AADD(ALEGENDA,{"BR_VERDE"	,"Etiq. a Imprmir"})
AADD(ALEGENDA,{"BR_VERMELHO","Etiq.já Impressa"})
AADD(ALEGENDA,{"BR_CINZA"	,"Não Imprimir"})

BrwLegenda("Etiq.Retrabalho", "Legenda" , aLegenda)

Return(.T.)
*
***********************
User Function Bl06Etq()
***********************
*
//  Atenção: Pela opção 4 do aRotina, o registro que estiver posicionado no momento da chamada desta rotina,
//  é automaticamente travado pelo Protheus, por isso dou um msunlock()

ZZE->(MsUnLock())

Do While .T.
	aParamBox := {}
	aRet      := {}
	aAdd(aParamBox,{1,"Número do Retrabalho ",Space(06),"","","","",035,.F.})
	
	/*/
	aAdd(aParamBox,{3,"Exportar Por             ",1,{"Nro.da Programação","Nro.das O.P.s"},060,"",.F.})
	aAdd(aParamBox,{3,"Tipo das Ordens          ",1,{"Programadas","Planejadas"},060,"",.F.})
	aAdd(aParamBox,{1,"Da O.P. / Programação.   ",Space(06),"","","","",035,.F.})
	aAdd(aParamBox,{1,"Até a O.P. / Programação.",Space(06),"","","","",035,.F.})
	aAdd(aParamBox,{3,"Integra Tabela de Estruturas (SG1) ",1,{"Sim","Não"},035,"",.F.})
	aAdd(aParamBox,{3,"Integra Produtos de Embalagem (ME) ",1,{"Sim","Não"},035,"",.F.})
	aAdd(aParamBox,{3,"Compara ou Força Integração de Produtos",1,{"Compara","Força"},035,"",.F.})
	/*/
	If !ParamBox(aParamBox, "Etiquetas de Corte - Retrabalho", @aRet)
		Exit
	EndIf
	
	DbSelectArea("ZZE")
	DbSetOrder(1)
	If !DbSeek(xFilial("ZZE")+aRet[1],.F.)
		MsgBox("Retrabalho Nro. " + aRet[1] + " não Localizado!!!", "Atenção !!!", "INFO")
	ElseIf ZZE->ZZE_ETIQ == "S"
		MsgBox("Etiquetas já Emitidas para esse Retrabalho!!!", "Atenção !!!", "INFO")
	ElseIf ZZE->ZZE_STATUS == '2'
		MsgBox("O.S. Ainda não Emitida para Esse Retrabalho - Contate P.C.P.", "Atenção !!!", "INFO")
	ElseIf ZZE->ZZE_STATUS # '3' // EM RETRABALHO ..
		MsgBox("Somente Podem ser Emitidas Etiquetas para Retrabalhos com Ordens Emitidas!!!", "Atenção !!!", "INFO")
	Else
		// Verificar se todos os pedidos desse ID estão em aberto
		_lImpr := .T.
		Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE->ZZE_ID == aRet[1] .And. _lImpr .And. ZZE->(!Eof())
			If !Empty(ZZE->ZZE_PEDIDO) .And. ZZE->ZZE_PEDIDO # "000001"
				SC6->(DbSetOrder(1))
				If !SC6->(DbSeek(xFilial("SC6")+ZZE->ZZE_PEDIDO+ZZE->ZZE_ITEMPV,.F.))
					Alert("Pedido " + ZZE->ZZE_PEDIDO + "-" + ZZE->ZZE_ITEMPV + " cancelado" + Chr(13) + Chr(13) + ;
					"Comunique o PCP.")
					_lImpr := .F.
				ElseIf SC6->C6_BLQ == "R "
					Alert("Pedido " + ZZE->ZZE_PEDIDO + "-" + ZZE->ZZE_ITEMPV + " cancelado (Resíduo)" + Chr(13) + Chr(13) + ;
					"Comunique o PCP.")
					_lImpr := .F.
				ElseIf ZZE->ZZE_PRODUTO # SC6->C6_PRODUTO
					Alert("Pedido " + ZZE->ZZE_PEDIDO + "-" + ZZE->ZZE_ITEMPV + " alterado produto - Verificar com PCP.")
					_lImpr := .F.
				ElseIf ZZE->ZZE_ACONDS # SC6->C6_ACONDIC .Or. ZZE->ZZE_METRAS # SC6->C6_METRAGE
					Alert("Pedido " + ZZE->ZZE_PEDIDO + "-" + ZZE->ZZE_ITEMPV + " alterado acondicionamento" + Chr(13) + Chr(13) + ;
					"Comunique o PCP.")
					_lImpr := .F.
				EndIf
			EndIf
			ZZE->(DbSkip())
		EndDo
		If _lImpr
			ZZE->(DbSeek(xFilial("ZZE")+aRet[1],.F.))
			Do While ZZE->ZZE_FILIAL == xFilial("ZZE") .And. ZZE->ZZE_ID == aRet[1] .And. ZZE->(!Eof())
				If Empty(ZZE->ZZE_PEDIDO) .And. ZZE->ZZE_ETIQ # "S"
					ZZE->(RecLock("ZZE",.F.))
					ZZE->ZZE_ETIQ := "S"
					ZZE->(MsUnLock())
				ElseIf ZZE->ZZE_ETIQ # "S"
					U_Bal06Etq(aReturn,cString) // Esta função está no fonte CDESTR06()
					ZZE->(RecLock("ZZE",.F.))
					ZZE->ZZE_ETIQ := "S"
					ZZE->(MsUnLock())
				EndIf
				ZZE->(DbSkip())
			EndDo
		EndIf
	EndIf
	aRet := {}
EndDo
Return(.T.)
