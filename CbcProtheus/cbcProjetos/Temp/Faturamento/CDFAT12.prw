#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CDFAT12  ºAutor  ³Edvar Vassaitis     º Data ³  17/11/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tabela de condições de pagamento a serem aplicados ao pedidoº±± 
±±º           de venda                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function CDFAT12()

	If Alltrim(cUserName)+"|" $ GetMv("MV_USERLIB") + GetMv("MV_USERADM")
		aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
		{ "Visualizar", "AxVisual", 0 , 2	},;
		{ "Incluir"   , "u_IncAltZX(1)", 0 , 3	},;
		{ "Alterar"   , "u_IncAltZX(2)", 0 , 4	},;
		{ "Excluir"   , "AxDeleta", 0 , 5	}}
	Else
		aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
		{ "Visualizar", "AxVisual", 0 , 2	}}
	EndIf	                                         

	cCadastro := "Condições de Pagamento por Faixa"
	DbSelectArea("SZX")
	DbSetOrder(1)
	DbSeek(xFilial("SZX"))
	mBrowse(001,040,200,390,"SZX",,,,,,)
	Return(.T.)
	*
	****************************
User Function IncAltZX(nRot)
	****************************
	*
	If nRot == 1 // Inclusao
		nOpca := AxInclui("SZX",0,3, , , ,)
	Else
		nOpca := AxAltera("SZX",Recno(),4, , , ,)
	EndIf
	If nOpca == 1
		aAreaZX := GetArea()
		_ZX_CODTAB := SZX->ZX_CODTAB
		_ZX_CARTA  := SZX->ZX_CARTA
		DbSelectArea("SZX")
		DbSetOrder(2) // ZX_FILIAL+ZX_CODTAB
		DbSeek(xFilial("SZX")+_ZX_CODTAB,.F.)
		Do While SZX->ZX_FILIAL == xFilial("SZX") .And. SZX->ZX_CODTAB == _ZX_CODTAB .And. SZX->(!Eof())
			RecLock("SZX",.F.)
			SZX->ZX_CARTA := _ZX_CARTA
			MsUnLock()
			SZX->(DbSkip())
		EndDo
		RestArea(aAreaZX)
	EndIf
Return(.T.)