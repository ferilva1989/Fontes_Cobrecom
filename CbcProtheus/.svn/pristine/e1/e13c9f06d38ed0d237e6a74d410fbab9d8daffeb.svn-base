#Include "PROTHEUS.CH"
#define CRLF Chr(13)+Chr(10)

*
****************************************
User Function CadPer()
	****************************************
	*

	/*
	Tabela ZZP -( Cadastro dos periodos para os quais serão aplicados as metas de vendas )
	ZZP_FILIAL	C	, 	02
	ZZP_PERIOD 	C	,	06
	ZZP_INICIO	D	,	08
	ZZP_FINAL	D	,	08
	ZZP_HIST	C	,	30
	*/
	Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

	Private cString := "ZZP"

	dbSelectArea("ZZP")
	dbSetOrder(1)

	AxCadastro(cString,"Cadastro de Periodos, para metas do BI",cVldExc,cVldAlt)

	Return

	*
	*******************************
User Function CadMeta()
	*******************************
	*
	/*
	Tabela ZZQ -( Cadastro de metas para os gerentes com base em periodos determinados )
	ZZQ_FILIAL	C	, 	02
	ZZQ_PERIOD 	C	,	06 - (Consulta Padrão para tabela ZZP)
	ZZQ_GEREN	C	,	20 - (Consulta Padrão X5_GET (Z6), com os nomes dos gerentes)
	ZZQ_VALOR	N	,	17,02
	ZZP_HIST	C	,	30
	*/

	Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
	Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

	Private cString := "ZZQ"

	dbSelectArea("ZZQ")
	dbSetOrder(1)

	AxCadastro(cString,"Cadastro de Metas para Vendas",cVldExc,cVldAlt)

Return