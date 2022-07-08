#include 'protheus.ch'

class cbcSC6Itens 

	data aCampos
	
	method newcbcSC6Itens() constructor 

	method getCampo()
	method setCampo()

endclass

method newcbcSC6Itens() class cbcSC6Itens
	::aCampos := {}
return

method getCampo(cNome) class cbcSC6Itens
return(::aCampos)

method setCampo(aCmpVlr) class cbcSC6Itens
Local  oBase := Nil	
	If !Empty(aCmpVlr)
		oBase := ManBaseDados():newManBaseDados()
		If ! oBase:ExistInTab(aCmpVlr[1])
			if GetNewPar('XX_DBGCONN', .T. )
				Conout('O Campo.. ' +  aCmpVlr[1] + ' não existe na tabela de dados!')
			endif
		Else
			AAdd(::aCampos,{aCmpVlr[1], aCmpVlr[2], nil} )
			if GetNewPar('XX_DBGCONN', .T. )
				Conout('Definindo campo..' +  aCmpVlr[1] + ' com valor..' + IF( ValType(aCmpVlr[2]) == 'N',cValToChar(aCmpVlr[2]), aCmpVlr[2]))
			endif
		EndIf
		FreeObj(oBase)		
	EndiF
return(self)