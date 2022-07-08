#include "protheus.ch"
#define CRLF Chr(13)+Chr(10)

/*/{Protheus.doc} CDPOSTIT
@author bolognesi
@since 07/08/2017
@version 1.0
@type function
@description 
relatorios para jackson (ctas receber)
objetivo = vencidos  vencidos/a vencer
tendo apenas um totalizador (soma dos titulos)
visualizar somente os titulos tranferidos para sâo paulo (seguintes condiçôes)
e1_zzbc2 = '000' ( e1_zzbor1  <> '' and e1_zzbor1 != 'antigo'   )
	**conceito titulo a vencer
	todos os titulos cuja data de vencimento seja
	maior ou igual d data atual onde
	campo e1_status = a 
	e1_saldo > 0

	titulos receber se1
	campo e1_status a=aberto b=baixado r=reliquidade
	campo e1_saldo > 0 titulo em aberto
	campo e1_baixa = data da baixa	 
	
	*dias vencido (distancia entre datas)
	select datediff(day,e1_emissao,e1_vencto) from se1010
/*/
User Function CDPOSTIT()	
	local oReport
	local cPerg 	:= "CDPOSREL"
	local oFonteRel := TFont():New( "Arial", , 07, .F.)
	local aBox		:={}
	local aRet		:={}

	//1=Vencidos, 2=Vencidos/ a vencer
	Private nTipoRel
	Private dDtBase

	aAdd(aBox,{3,"Tipo do relatorio?",1,{"Vencidos","Vencidos/a Vencer"},90,"",.T.})
	aAdd(aBox,{1,"Data"  ,dDataBase,"","","","",50,.T.}) // Tipo data

	If ParamBox(aBox,"Relatorios contas a receber...",@aRet)
		nTipoRel    := aRet[1]
		dDtBase		:= aRet[2]
	Else
		MessageBox("Confirme os parametros","Aviso",48)
		Return nil
	EndIf

	oReport := ReportDef()

	oReport:OFONTBODY 	:= oFonteRel 	//Fonte utilizada no relatorio
	oReport:NFONTBODY 	:= 07 			//Tamanho da Fonte
	oReport:NLINEHEIGHT := 35 			//Altura da linha
	oReport:SetLandScape()
	oReport:SetTotalInLine(.F.)
	oReport:SetTotalText("Valor Total")
	oReport:PrintDialog()

Return Nil

/*/{Protheus.doc} ReportDef
@author bolognesi
@since 07/08/2017
@version 1.0
@type function
/*/
Static Function ReportDef()

	local oReport
	local oSection1

	oReport := TReport():New("TITULOS RECEBER","Consulta situação dos titulos" ,"CDPOSREL",{|oReport| PrintReport(oReport)},"Posição dos Titulos a Receber")
	oSection1 := TRSection():New(oReport,"Titulos" 					,"SE1")

	TRCell():New(oSection1,"E1_VENCTO"			,"SE1","Vencto")
	TRCell():New(oSection1,"E1_CLIENTE"			,"SE1","Cod")
	TRCell():New(oSection1,"E1_NOMCLI"			,"SE1","Cliente")
	TRCell():New(oSection1,"E1_NUM"				,"SE1","Num.Doc",,TamSX3("E1_NUM")[1]+TamSX3("E1_PREFIXO")[1]      )
	TRCell():New(oSection1,"E1_VALOR"			,"SE1","Valor")
	TRCell():New(oSection1,"E1_SALDO"			,"SE1","Saldo")
	TRCell():New(oSection1,"E1_SDDECRE"			,"SE1","Desc.")
	TRCell():New(oSection1,"NOM_BANCO"			,"","Banco",,15,,,"RIGHT",.T.,"RIGHT")
	TRCell():New(oSection1,"E1_DIA"				,"","D/A",,4,,,"RIGHT",.T.,"RIGHT")
	TRCell():New(oSection1,"RELATORIOS"			,"","Relatorios",,100,,,"LEFT",.T.,"LEFT") 
	TRCell():New(oSection1,"E1_HIST"			,"SE1","Obs",,10)

	TRFunction():New(oSection1:Cell("E1_VALOR")		,NIL,"SUM"	,NIL,"                       Valor Total ......."	,NIL,NIL,.F.,.T.,.F.)
	TRFunction():New(oSection1:Cell("E1_SALDO")		,NIL,"SUM"	,NIL,"                       Total Saldo ......."	,NIL,NIL,.F.,.T.,.F.)
	TRFunction():New(oSection1:Cell("E1_SDDECRE")	,NIL,"SUM"	,NIL,"                       Total Desc. ......."	,NIL,NIL,.F.,.T.,.F.)

Return oReport

/*/{Protheus.doc} PrintReport
@author bolognesi
@since 07/08/2017
@version 1.0
@param oReport, object, descricao
@type function
/*/
Static Function PrintReport(oReport)
	local oSection1 	:= oReport:Section(1)
	local cSP			:='000'
	local cVazio		:=''
	local cAntigo		:='- SIST.ANTIGO'
	local cTraco		:= '-'
	local cProt			:= 'Protestado'
	local cDesc			:= 	'DESCONTO'
	local cDesDbt		:=  'DESC. NÃO DEBITAR' 
	local cF			:= 'F'
	local cSQL			:=""
	local c250Spac		:= Space(250)
	local cDtBase		:= DtoS(dDtBase)

	oSection1:BeginQuery()

	cSQL	+= " AND E1_SALDO > 0  "
	cSQL	+= " AND E1_STATUS = 'A' "
	cSQL	+= " AND E1_ZZBC2 IN ('000', 'NNN') "
	cSQL	+= " AND E1_SITUACA <> 'F' "
	cSQL	+= " AND E1_PORTADO <> 'RAF' "
	cSQL	+= " AND E1_ZZBOR1 != 'ANTIGO' "  

	//1=Vencidos
	If nTipoRel == 1
		cSQL	+= "AND E1_VENCTO < " 
		cSQL	+= "CASE " 
		cSQL	+= "WHEN DATEPART(WeekDay,'" 	+  cDtBase 	+ "')IN (1) "
		cSQL	+= "THEN DATEADD(day,-1,'" 		+  cDtBase 	+ "') "
		cSQL	+= "WHEN DATEPART(WeekDay,'"	+  cDtBase		+"')NOT IN (1,7) "
		cSQL	+= "THEN '" + cDtBase	+ "' "
		cSQL	+= "END"
	EndIf

	cSQL 	:= "%"+cSQL+"%"

	BeginSql alias "QVCDOS" 
	%noParser%
	SELECT
	CAST(SE1.R_E_C_N_O_ AS VARCHAR) 								AS ID,
	E1_VENCTO,
	E1_CLIENTE,
	E1_NOMCLI,
	(E1_NUM+E1_PARCELA)												AS E1_NUM,
	E1_VALOR,
	(E1_SALDO - E1_SDDECRE)											AS E1_SALDO,
	ISNULL((	SELECT	SUM(ZBA.ZBA_DESCON) 
	FROM ZBA010 ZBA 
	WHERE	SE1.E1_FILIAL 	= ZBA.ZBA_FILIAL
	AND SE1.E1_PREFIXO 	= ZBA.ZBA_PREFIX
	AND SE1.E1_NUM 		= ZBA.ZBA_NUM
	AND SE1.E1_PARCELA 	= ZBA.ZBA_PARC
	AND SE1.E1_TIPO 	= ZBA.ZBA_TIPO
	AND SE1.E1_CLIENTE 	= ZBA.ZBA_CLI
	AND SE1.E1_LOJA 	= ZBA.ZBA_LOJA
	AND SE1.D_E_L_E_T_ 	= ZBA.D_E_L_E_T_
	AND ( ZBA.ZBA_OPER 	= %Exp:cDesc% OR ZBA.ZBA_OPER = %Exp:cDesDbt% )
	GROUP BY ZBA.ZBA_OPER 
	),0) 												AS E1_SDDECRE,
	%Exp:c250Spac%										AS RELATORIOS,

	CASE WHEN E1_PORTADO = %Exp:cSP%

	THEN 
	ISNULL(E1_PORTADO+%Exp:cAntigo%,%Exp:cVazio%) 
	ELSE 
		ISNULL(E1_PORTADO+%Exp:cTraco%+ A6_NOME,%Exp:cVazio%)
	END																AS NOM_BANCO,

	CASE WHEN DATEPART(WeekDay,%Exp:cDtBase%)IN (1)
	THEN
	DATEDIFF(DAY,DATEADD(day,1,E1_VENCTO),%Exp:cDtBase%)

	WHEN DATEPART(WeekDay,%Exp:cDtBase%)IN (7)
	THEN
	DATEDIFF(DAY,DATEADD(day,2,E1_VENCTO),%Exp:cDtBase%)

	WHEN DATEPART(WeekDay,%Exp:cDtBase%)NOT IN (1,7)
	THEN
	DATEDIFF(DAY,E1_VENCTO,%Exp:cDtBase%)	
	END																AS E1_DIA,

	CASE WHEN E1_SITUACA IN (%Exp:cF%)
	THEN
	%Exp:cProt%	
	ELSE
		%Exp:cVazio%
	END																AS E1_HIST 

	FROM %table:SE1% SE1

	LEFT JOIN %table:SA6% A6	ON	E1_PORTADO	= A6_COD
	AND	E1_AGEDEP	= A6_AGENCIA
	AND E1_CONTA	= A6_NUMCON

	WHERE  SE1.%NotDel% %Exp:cSQL%
	ORDER BY E1_VENCTO,E1_CLIENTE

	EndSql
	oSection1:EndQuery()
	getRelat()
	oSection1:Print()

Return

/*/{Protheus.doc} getRelat
@author bolognesi
@since 07/08/2017
@version 1.0
@type function
@description A seguencia dos comandos BeginQuery criam um arquivo temporario
exclusivo, para poder acrescentar informações sobre os numeros dos relatorios 
da tabela ZBA (considerando o relacionamento ( SE1(1) <-Para-> ZBA(N)), precisamos
manipular o arquivo de trabalho gerado, para isso copio para um novo e apago a antigo
depois volto com o mesmo alias, desta forma posso aterar o arquivo e ele ainda funciona
quando volta para oSection1:Print()
/*/
static function getRelat()
	local aArea 	:= getArea()
	local cTmp		:= 'QVCDOS'
	local cQryHdr	:= ''
	local cQryFtr	:= ''
	local cQry		:= ''
	local oSql 		:=  nil
	local _cNomArq	:= ''

	cQryHdr += " SELECT "
	cQryHdr += " ZBA.ZBA_NROREL + '-' + RTRIM(LTRIM(ZBA.ZBA_OPER)) AS REL "
	cQryHdr += " FROM %ZBA.SQLNAME% "
	cQryHdr += " WHERE "
	cQryFtr += " AND %ZBA.NOTDEL% "

	DbSelectarea('SE1')

	changTrab(cTmp,"TMP")
	(cTmp)->(DbCloseArea())

	_cNomArq := changTrab("TMP",cTmp)
	if Select('TMP') > 0
		TMP->(DbCloseArea())
		FErase( _cNomArq )
	end If

	(cTmp)->(DbGoTop())

	while(cTmp)->(!Eof())
		SE1->( DbGoto( Val((cTmp)->(ID)) ) )
		if SE1->(!Eof()) 
			oSql := LibSqlObj():newLibSqlObj()
			cQry := ''
			cQry += " ZBA.ZBA_FILIAL 	 = '" + SE1->(E1_FILIAL) + "' "
			cQry += " AND ZBA.ZBA_PREFIX = '" + SE1->(E1_PREFIXO) + "' "
			cQry += " AND ZBA.ZBA_NUM 	 = '" + SE1->(E1_NUM) + "' "
			cQry += " AND ZBA.ZBA_PARC 	 = '" + SE1->(E1_PARCELA) + "' "
			cQry += " AND ZBA.ZBA_TIPO 	 = '" + SE1->(E1_TIPO) + "' "
			cQry += " AND ZBA.ZBA_CLI 	 = '" + SE1->(E1_CLIENTE) + "' "
			cQry += " AND ZBA.ZBA_LOJA 	 = '" + SE1->(E1_LOJA) + "' "
			oSql:newAlias( (cQryHdr + cQry + cQryFtr) )
			if oSql:hasRecords()
				oSql:goTop()	
				while oSql:notIsEof()
					RecLock(cTmp,.F.)
					(cTmp)->(RELATORIOS) := Alltrim((cTmp)->(RELATORIOS)) + oSql:getValue("AllTrim(REL)") + '-'
					(cTmp)->(MsUnlock())
					oSql:skip()
				endDo
			endif
			oSql:close() 
			FreeObj(oSql)
		endif
		(cTmp)->(DbSkip())
	end

	restArea(aArea)
return(nil)

/*/{Protheus.doc} changTrab
@author bolognesi
@since 07/08/2017
@version 1.0
@param cAlsDe, characters, Alias de Origem
@param cAlsPara, characters, Alias de destino
@type function
@description Auxili a função getRelat(), para copiar
arquivo de trabalho.
/*/
static function changTrab(cAlsDe,cAlsPara)
	local _cNomArq := '' 
	DbSelectarea((cAlsDe))
	_cNomArq := AllTrim(CriaTrab(,.F.))
	Copy to & _cNomArq
	DbUseArea(.T.,,_cNomArq, cAlsPara,.T.,.F.)
return(_cNomArq)
