#include "rwmake.ch"


/*/{Protheus.doc} CDEST19
//TODO Cadastro de bobinas.
@author LEGADO Roberto Oliveira
@since 18/03/2009
@version 1.0

@type function
/*/
User Function CDEST19()


	aCores    := {{"ZE_STATUS $ 'IL'"  ,"BR_PINK"},;	//"Importada ou Laboratório"
							{"ZE_STATUS == 'C'"  ,"BR_BRANCO"},;	//"Cancelada"
							{"ZE_STATUS == 'V'"  ,"BR_AMARELO"},;	//"Com Reserva"
							{"ZE_STATUS == 'N'"  ,"DISABLE"},;	//"Com Reserva Definitiva"
							{"ZE_STATUS $  'RP'" ,"BR_CINZA"},;	//"Recebida ou A Liberar"
							{"ZE_STATUS == 'E'"  ,"BR_LARANJA"},;	//"Empenhada"
							{"ZE_STATUS $  'FD'" ,"BR_AZUL" },;	//"Faturada ou Adiantada"
							{"ZE_STATUS == 'X'"  ,"BR_PRETO" },;	//"Expedida"
							{"ZE_STATUS == 'T'"  ,"ENABLE"}}		//"Estoque Disponível"

	aRotina := {{ "Pesquisar" , "AxPesqui"  , 0 , 1,,.F. },;
						{ "Visualizar", "AxVisual"  , 0 , 2	},;
						{ "Legenda"   , "U_CDEST19X", 0 , 2,,.F. },;
						{ "Alterar"   , "u_AltBob19", 0 , 4	}}

	cCadastro := "Etiquetas de Bobinas"
	DbSelectArea("SZE")
	DbSetOrder(1)
	DbSeek(xFilial("SZE"))

	mBrowse(001,040,200,390,"SZE",,,,,,aCores)

Return(.T.)                          

/*/{Protheus.doc} IncBob19
//TODO Descrição auto-gerada.
@author LEGADO
@since 22/03/2018
@version 1.0

@type function
/*/
User Function IncBob19()
	Alert("Rotina Desativada")
Return(.T.)


/*/{Protheus.doc} AltBob19
//TODO Alteração de bobinas no cadastro SZE
		 ZE_STATUS -> I=Import..;C=Canc.;R=Recebida;P=A Liberar;E=Empenh.;F=Faturada;T=Estoque;A=Adiantada;X=Expedida;D=Devolv.;V=Reserv.;N=Res.Conf..
@author juliana.leme
@since 22/03/2018
@version 1.0

@type function
/*/
User Function AltBob19()
	Begin Transaction
		
		If SZE->ZE_DTRES+1 < Date() .And. SZE->ZE_STATUS == "V" // Expirou a data da reserva e a reserva é provisória
			RecLock("SZE",.F.)                          
			SZE->ZE_DTRES  := Ctod("//")
			SZE->ZE_STATUS := "T"
			SZE->ZE_RESP   := Space(Len(SZE->ZE_RESP))
			MsUnLock()
		EndIf
		If SZE->ZE_STATUS $ "VN" // Reservadas
			Alert("Esta Bobina Encontra-se Reservada")
		Else 
			_cStatus := SZE->ZE_STATUS
			
			
			nOpca := AxAltera("SZE",Recno(),4, , , ,)
			If SZE->ZE_STATUS # _cStatus .And. 	"C"  $ SZE->ZE_STATUS + _cStatus // Era foi foi cancelada
				If DbSeek(xFilial("SZ9")+SZE->ZE_PEDIDO+SZE->ZE_ITEM,.F.)
					RecLock("SZ9",.F.)
					If SZE->ZE_STATUS == "C" // Foi cancelada agora
						SZ9->Z9_QTDETQ := SZ9->Z9_QTDETQ - 1
						SZ9->Z9_QTDMTS := Max((SZ9->Z9_QTDMTS - SZE->ZE_QUANT),0)
					Else // Foi "descancelada"
						SZ9->Z9_QTDETQ := SZ9->Z9_QTDETQ + 1
						SZ9->Z9_QTDMTS := Max(SZ9->Z9_QTDMTS,0) + SZE->ZE_QUANT
					EndIf
					MsUnLock()
				EndIf
				DbSelectArea("SZE")	
			ElseIf SZE->ZE_STATUS ==  "T"  .and.  SZE->ZE_PEDIDO+SZE->ZE_ITEM <> "00000199"//Alterou para estoque 
				If MsgBox("Pedido Bloqueado com Reserva desta bobina. Deseja liberar o pedido desta Reserva ?","Confirma?","YesNo")
					DbSelectArea("SC6")
					DbSetOrder(1)
					If DbSeek(xFilial("SC6")+SZE->ZE_PEDIDO+SZE->ZE_ITEM,.F.)
						If RecLock("SC6",.F.)
							SC6->C6_SEMANA := "" 
							SC6->(MsUnLock())
						EndIf
					EndIf
					DbSelectArea("SZE")	
				EndIf
			EndIf
		EndIf
	End Transaction
Return(.T.)


/*/{Protheus.doc} CDEST19X
//TODO Definiçao Legenda.
@author LEGADO
@since 22/03/2018
@version 1.0

@type function
/*/
User Function CDEST19X()
	BrwLegenda(cCadastro,"Legenda",{{"DISABLE"   ,"Com Reserva Definitiva"},;
																		{"BR_AMARELO","Com Reserva"},;
																		{"BR_PINK"   ,"Importada ou Laboratório"},;
																		{"BR_BRANCO" ,"Cancelada"},;
																		{"BR_CINZA","Recebida ou A Liberar"},;
																		{"BR_LARANJA","Empenhada"},;
																		{"BR_AZUL"   ,"Faturada ou Adiantada"},;
																		{"BR_PRETO"  ,"Expedida"},;
																		{"ENABLE"    ,"Estoque Disponível"}})
Return(.T.)
