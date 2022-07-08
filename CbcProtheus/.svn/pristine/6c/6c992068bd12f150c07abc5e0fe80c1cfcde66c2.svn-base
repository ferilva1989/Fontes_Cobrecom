
/*/{Protheus.doc} CDGrpPA
//TODO Realizar o cadastro de Grupos de Recursos por PA's. Regra utilizada para quebrar as OPS de PAs nos gruposd e acondicionamentos corretos
@author juliana.leme
@since 09/07/2015
@version 1.0
@type function
/*/
User Function CDGrpPA()
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Private cString := "ZZM"
	dbSelectArea("ZZM")
	dbSetOrder(1)

	AxCadastro(cString,"Cadastro de Grupos de Recursos PAs",cVldExc,cVldAlt)
Return

/*/{Protheus.doc} CDGrpRec
//TODO Realizar o Cadastro de Grupos de Recursos.
@author juliana.leme
@since 09/07/2015
@version 1.0
@type function
/*/
User Function CDGrpRec()
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Private cString := "SX5"

	dbSelectArea("SX5")
	dbSetOrder(1)
	set filter to X5_TABELA == 'ZU'.and. X5_FILIAL == XFILIAL("SX5")
	dbFilter()

	AxCadastro(cString,"Cadastro de Grupos de Recursos",cVldExc,cVldAlt)

Return

/*
Cadastra Grupos de Recursos X Recursos
Juliana Leme - 15/07/2015
*/
/*/{Protheus.doc} CDGrpXRec
//TODO Realizar o Cadastro de Grupos X Recursos.
@author juliana.leme
@since 09/07/2015
@version 1.0
@type function
/*/
User Function CDGrpXRec()
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Private cString := "ZZL"

	dbSelectArea("ZZL")
	dbSetOrder(1)

	AxCadastro(cString,"Cadastro de Grupos X Recursos",cVldExc,cVldAlt)
Return

/*
Cadastra Atributos para PREACTOR
Juliana Leme - 15/07/2015
*/
/*/{Protheus.doc} CDAtrib
//TODO Cadastro de Atributos Diversos.
@author juliana.leme
@since 09/07/2015
@version 1.0
@type function
/*/
User Function CDAtrib()
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Private cString := "ZAE"

	dbSelectArea("ZAE")
	dbSetOrder(1)

	AxCadastro(cString,"Cadastro de Atributos Diversos",cVldExc,cVldAlt)
Return


/*/{Protheus.doc} CDMatPrVel
//TODO Cadastra Matriz Produto Velocidade para PREACTOR.
@author juliana.leme
@since 15/07/2015
@version 1.0
@type function
/*/
User Function CDMatPrVel()
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Private cString := "ZAG"

	dbSelectArea("ZAG")
	dbSetOrder(1)

	AxCadastro(cString,"Matriz Produto Velocidade para PREACTOR",cVldExc,cVldAlt)
Return


/*/{Protheus.doc} CDMatriz
//TODO Realiza Cadastro Matriz PREACTOR.
@author juliana.leme
@since 15/07/2015
@version 1.0

@type function
/*/
User Function CDMatriz()
Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.
Private cString := "ZAF"

	dbSelectArea("ZAF")
	dbSetOrder(1)

	AxCadastro(cString,"Matriz PREACTOR",cVldExc,cVldAlt)
Return
