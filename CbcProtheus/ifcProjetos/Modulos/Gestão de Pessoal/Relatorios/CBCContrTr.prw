#INCLUDE 'PROTHEUS.CH'
#include "rwmake.ch"
#include "topconn.ch"


/*/{Protheus.doc} CBCRelGPE
//TODO Programa centraliador dos relatorios modelos de admissão.
@author juliana.leme
@since 14/11/2018
@version 6
@return ${return}, ${return_description}

@type function
/*/
user function CBCRelGPE()
	local aRet	  	:= {}
	local aPergs  := {}
	Local aCombo := {"Cont.Trab./Exper.","Solic. VT","Devol.CTPS"}
	private oFont10N	:= TFont():New( "Arial",,10,,.T.,,,,.T.,.F.)
	private oFont11N	:= TFont():New( "Arial",,11,,.T.,,,,.T.,.F.)
	private oFont12 		:= TFont():New( "Arial",,12,,.T.,,,,   ,.F.)
	private oFont14 		:= TFont():New( "Arial",,14,,.T.,,,,   ,.F.)
	private oFont14N	:= TFont():New( "Arial",,14,,.T.,,,,.T.,.F.)
	private oFont16N	:= TFont():New( "Arial",,16,,.T.,,,,.T.,.F.)
	private oFont18N	:= TFont():New( "Arial",,18,,.T.,,,,.T.,.F.)
	
	If Select("SX2")=0
		RPCSetType(3)
		RPCSetEnv("01","0101","","","","",{"SX5"})	
	Endif
	
	aAdd( aPergs ,{1,"Filial: ",Space(TamSX3("RA_FILIAL")[1]),"@!",'.T.','SRA','.T.',40,.F.})
	aAdd( aPergs ,{1,"Matricula: ",Space(TamSX3("RA_MAT")[1]),"@!",'.T.','SRA','.T.',50,.F.})
	aAdd( aPergs ,{2,"Qual Relatorio? ","Cont.Trab./Exper.",aCombo,100,"",.F.})
		
	If !ParamBox(aPergs,"Parâmetros do Relatório",aRet)
		Alert("Relatório Cancelado!")
		Return
	EndIf
	
	DbSelectArea("SRA")
	DBSetOrder(1)
	
	If RetDados(MV_PAR01, MV_PAR02)
		If MV_PAR03 == "Cont.Trab./Exper."
			ContrTrab()
		ElseIf MV_PAR03 == "Solic. VT"
			SoliVT()
		ElseIf MV_PAR03 == "Devol.CTPS"
			DevolCT()
		EndIf
	Else
		Alert("Dados Informados não encontrados, Favor verificar os parametros.")
	Endif
return


/*/{Protheus.doc} ContrTrab
//TODO Gera relatorio com as informações do Contrato de TRabalho conforme modelo do RH.
@author juliana.leme
@since 14/11/2018
@version 6
@return ${return}, ${return_description}

@type function
/*/
static function ContrTrab()
	local nLin 				:= 0
	local cTitulo			:= ""
	private oPrn
	
	oPrn := FWMsPrinter():New("CBCContr"+ MV_PAR01+MV_PAR02,,.T.,"\ContrTrab\",.T.,,,,.T.)
	oPrn:SetPortrait()	// Formato pagina Paisagem
	oPrn:SetPaperSize(9)	//Papel A4
	oPrn:SetMargin(GPixel(05),GPixel(05),GPixel(05),GPixel(05))
	oPrn:Setup()
	oPrn:SetViewPDF(.T.)
	
	oPrn:StartPage(,"ContrTrab" + MV_PAR01+MV_PAR02)
	
	nLin := 8
	oPrn:Say(GPixel(nLin),GPixel(00),"Cobrecom - Filial :" + FwFilial() +  " - " + FWFilialName(FwFilial()) ,oFont10N)
	oPrn:Say(GPixel(nLin),GPixel(150),"Data/Hora Imp :" + DTOC(DATE()) + " - " + TIME(),oFont10N)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin),GPixel(150),"Usuario Imp :" + UsrRetName(RetCodUsr()),oFont10N)
		
	nLin := nLin + 5
	
	cTitulo := "CONTRATO DE TRABALHO A TÍTULO DE EXPERIÊNCIA"
	oPrn:Say(GPixel(nLin),GPixel(40),AV_Justifica(cTitulo),oFont18N)	
		
	nLin := nLin + 10
	oPrn:Say(GPixel(nLin),GPixel(10),"IFC INDÚSTRIA  E  COMÉRCIO  DE  CONDUTORES  ELÉTRICOS LTDA,  com sede em Itu na  Avenida  Primo Schincariol nº 670 CNPJ/CEI 02.544.042/0001-19,",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(05),"doravante designada EMPREGADORA e " + QTEMP->NOME + "  portador(a) da Carteira Profissional nº " + QTEMP->CARTEIRA + " Série " + QTEMP->SERIE + " a seguir chamado apenas",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(05),"EMPREGADO, e celebrado o presente CONTRATO DE EXPERIÊNCIA, que terá vigência a partir de "+ DtoC(StoD(QTEMP->ADMISSAO)) +" ,inicio prestação  de  serviços, de  acordo  com" ,oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(05),"as condições a seguir especificadas na função : " + QTEMP->DESC_FUNCAO + ", conforme abaixo:",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(05),"1. R$ " + Transform(QTEMP->SALARIO,"@E 9,999,999.99") + " ( " + Extenso(QTEMP->SALARIO) + " ) por hora. ",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(10),"A circunstância, porém, de ser a função especificada não importa  na  transferibilidade  do  EMPREGADO  para  outro  serviço, no  qual  demonstre melhor",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(10),"capacidade de adaptação desde que compatível com sua condição pessoal.",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(05),"2. O horário a ser obedecido será o seguinte: " + QTEMP->DESC_TURNO,oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(05),"3. Obriga-se também o EMPREGADO a prestar serviços em horas extraordinárias, sempre que lhe for determinado pela EMPREGADORA, na forma prevista em lei.",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(10),"Na hipótese desta pela EMPREGADORA o  EMPREGADO  receberá  as horas  extraordinárias  com acréscimo legal,  salvo  a ocorrência  de compensação com a",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(10),"consequente redução da jornada em outro dia.",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(05),"4. Aceita o EMPREGADO, expressamente, a condição de prestar serviços em qualquer dos turnos de trabalho, isto é, tanto durante o  dia com a noite,  desde",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(10),"que sem simultaneidade, observadas as prescrições legais reguladoras do assunto, quanto a remuneração.",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(05),"5. Fica ajustado nos termos do que  dispõe o 1. Do  artigo 469,  da  Consolidação  das  Leis  do  Trabalho, que  o  EMPREGADO  acatará  ordem emanada da",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(10),"EMPREGADORA para a  prestação de  serviço  tanto na  localidade  de  celebração do  Contrato  de  Trabalho como qualquer outra cidade, capital ou vila do",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(10),"Território Nacional, quer essa transferência seja transitória, quer seja definitiva.",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(05),"6. No ato da assinatura deste contrato o EMPREGADO recebe o Regulamento  Interno  da  Empresa, cujas  clausulas  fazem parte  do Contrato  de Trabalho,",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(10),"e a violação de qualquer delas implicará em sanção, cuja graduação dependerá da mesma, culminando com a rescisão de Contrato.",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(05),"7. Em caso de dano causado pelo EMPREGADO, fica a EMPREGADORA, autorizada a efetivar o desconto da  importância  correspondente  ao  prejuízo, o qual",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(10),"fará, com fundamento no 1º. Do artigo 460 da Consolidação das Leis do Trabalho, já que essa possibilidade fica expressamente prevista em Contrato.",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(05),"8. O presente contrato, vigerá durante 60 dias, sendo celebrado para as  partes  verificarem  reciprocamente, a  conveniência  ou não de  se vincularem em",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(10),"caráter definitivo a um Contrato de Trabalho. A empresa passando a conhecer as aptidões do EMPREGADO e suas qualidades pessoais e morais, o EMPREGADO",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(10),"verificando se o ambiente e os métodos de trabalho atendem a sua conveniência.",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(05),"9. Opera- se a rescisão do presente contrato pela decorrência do prazo supra ou por vontade de uma das partes, rescindindo-se pela EMPREGADORA com justa",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(10),"causa, nenhuma indenização é devida, rescindindo-se sem justa causa, por  parte da  empregadora ou do empregado, antes  do término do  contrato, implicará",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(10),"em indenização de 50% dos  salários devidos  até o final,  conforme art. 479 e 480 a C.L.T.,  sem prejuízo  do  disposto no Reg. do FGTS. Nenhum aviso-prévio ",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(10),"é devido pela rescisão do presente Contrato.",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(05),"10. Na hipótese deste ajuste transformar em Contrato por Prazo Indeterminado, pelo decurso do tempo, continuarão em plena vigência as clausulas de 1 (um) a",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(10),"7 (sete), enquanto durarem as relações do EMPREGADO com a EMPREGADORA.",oFont12)
	nLin := nLin + 7
	oPrn:Say(GPixel(nLin), GPixel(05),"E por estarem de pleno acordo, as partes contratantes, assinam o presente Contrato de Experiência em duas vias, ficando a primeira em poder da EMPREGADORA",oFont12)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(05),"e a segunda com o EMPREGADO, que dela dará o competente recebido.",oFont12)
	
	nLin := nLin + 7
	oPrn:Say(GPixel(nLin), GPixel(120),"Itu/SP, " + Substr(QTEMP->ADMISSAO,7,2) + " de " + MesExtenso(StoD(QTEMP->ADMISSAO)) + " de " + Substr(QTEMP->ADMISSAO,1,4),oFont14N)
	
	nLin := nLin + 13
	oPrn:Say(GPixel(nLin), GPixel(30),"Testemunha",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(130),"Empregado ou resp. qdo. menor",oFont14N)
	nLin := nLin + 10
	oPrn:Say(GPixel(nLin), GPixel(30),"Testemunha",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(130),"Empregador",oFont14N)
	
	nLin := nLin + 15
	oPrn:Say(GPixel(nLin), GPixel(80),"Termo de Prorrogação",oFont14N)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(05),AV_Justifica("Por mútuo acordo entre as partes, fica o presente Contrato de Experiência, que deveria vencer em " + DtoC(StoD(QTEMP->VENC_1)) + "  fica prorrogado"),oFont14N)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin), GPixel(05),AV_Justifica("até: " + DtoC(StoD(QTEMP->VENC_2))),oFont14N)

	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(120),"Itu/SP, " + Substr(QTEMP->VENC_1,7,2) + " de " + MesExtenso(StoD(QTEMP->VENC_1)) + " de " + Substr(QTEMP->VENC_1,1,4),oFont14N)
	nLin := nLin + 13
	oPrn:Say(GPixel(nLin), GPixel(30),"Testemunha",oFont14N)
	oPrn:Say(GPixel(nLin), GPixel(130),"Empregado ou resp. qdo. menor",oFont14N)

	oPrn:EndPage()
	oPrn:Preview()
return


/*/{Protheus.doc} SoliVT
//TODO Gera reatorio com a solicitaão de Vale Transporte conforme modelo RH.
@author juliana.leme
@since 14/11/2018
@version 6
@return ${return}, ${return_description}

@type function
/*/
static function SoliVT()
	local nLin 				:= 0
	local cTitulo			:= ""
	private oPrn
	
	oPrn := FWMsPrinter():New("CBCSolicVT"+ MV_PAR01+MV_PAR02,,.T.,"\ContrTrab\",.T.,,,,.T.)
	oPrn:SetPortrait()	// Formato pagina Paisagem
	oPrn:SetPaperSize(9)	//Papel A4
	oPrn:SetMargin(GPixel(05),GPixel(05),GPixel(05),GPixel(05))
	oPrn:Setup()
	oPrn:SetViewPDF(.T.)
	
	oPrn:StartPage(,"SolicVT" + MV_PAR01+MV_PAR02)
	
	nLin := 8
	oPrn:Say(GPixel(nLin),GPixel(00),"Cobrecom - Filial :" + FwFilial() +  " - " + FWFilialName(FwFilial()) ,oFont10N)
	oPrn:Say(GPixel(nLin),GPixel(150),"Data/Hora Imp :" + DTOC(DATE()) + " - " + TIME(),oFont10N)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin),GPixel(150),"Usuario Imp :" + UsrRetName(RetCodUsr()),oFont10N)
		
	nLin := nLin + 2
	oPrn:Box (GPixel(nLin),GPixel(00),GPixel(250),GPixel(180),"-4")//( nRow, nCol, nBottom, nRight, cPixel)
	
	nLin := nLin + 5
	cTitulo := "SOLICITAÇÃO DE VALE TRANSPORTE"
	oPrn:Say(GPixel(nLin),GPixel(50),AV_Justifica(cTitulo),oFont18N)	
	
	nLin := nLin + 3
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(180))
	nLin := nLin + 2
	
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(05),"Á",oFont14N)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(05),"Empresa: " + FWFilRazSocial(FwFilial()) ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(05),"Endereço: " + SM0->M0_ENDCOB,oFont14)
	oPrn:Say(GPixel(nLin), GPixel(110),"Bairro: " + SM0->M0_BAIRCOB,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(05),"Compl: "+ SM0->M0_COMPCOB,oFont14)
	oPrn:Say(GPixel(nLin), GPixel(70),"UF: " + SM0->M0_ESTCOB,oFont14)
	oPrn:Say(GPixel(nLin), GPixel(110),"CEP: " + SM0->M0_CEPCOB,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(05),"Cidade:" + SM0->M0_CIDCOB,oFont14)
	
	nLin := nLin + 2
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(180))
	
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(05),"Empregado: " + QTEMP->NOME ,oFont14)
	oPrn:Say(GPixel(nLin), GPixel(110),"RG: " + QTEMP->RG ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(05),"Função: " + QTEMP->DESC_FUNCAO ,oFont14)
	oPrn:Say(GPixel(nLin), GPixel(80),"CTPS: " + QTEMP->CARTEIRA ,oFont14)
	oPrn:Say(GPixel(nLin), GPixel(120),"Num.Serie: " + QTEMP->SERIE ,oFont14)
	
	nLin := nLin + 2
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(180))
	
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(20),"(   ) Opto pela utilização do Vale Transporte (   ) Não Opto pela utilização do Vale-Transporte. " ,oFont14)
	nLin := nLin + 10
	oPrn:Say(GPixel(nLin), GPixel(05),"Nos termos do Artigo 7º do Dec. nº 95.247 de 17 de novembro de 1987, solicito receber o vale-transporte e comprometo-me: " ,oFont14)
	nLin := nLin + 7
	oPrn:Say(GPixel(nLin), GPixel(25),"A -  A utiliza-lo exclusivamente para meu efetivo deslocamento residência – trabalho e vice versa." ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(25),"B-) A Renovar anualmente ou sempre que ocorrer alterações no meu endereço residencial ou dos serviços e meios " ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(25),"de transportes mais adequados ao meu deslocamento residência-trabalho e vice-versa." ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(25),"C-) Autorizo descontar até 6,0 % (por cento) do meu salário –básico mensal para ocorrer o custeio do Vale – " ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(25),"Transporte ( Conforme o artigo 9º - do Decreto no. 95.247/87);" ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(25),"D-) Declaro estar ciente de que a declaração falsa ou o uso indevido do Vale-Transporte constituem falta grave (" ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(25),"conforme o inciso 3º do Artigo 7º do Decreto no. 95.247/97)" ,oFont14)
	nLin := nLin + 7
	oPrn:Say(GPixel(nLin), GPixel(05),"Minha residência atual:" ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(10),"Endereço: " + QTEMP->ENDERECO,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(10),"Compl. End.: " + QTEMP->COMPL ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(10),"Bairro: " + QTEMP->BAIRRO ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(10),"Município: " + QTEMP->MUNICIPIO ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(10),"Estado: " + QTEMP->ESTADO ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(10),"CEP: " + QTEMP->CEP ,oFont14)
	
	nLin := nLin + 2
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(180))
	
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(70),"Meio de Transporte " ,oFont16N)
	
	nLin := nLin + 2
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(180))
	
	oPrn:Line(GPixel(nLin), GPixel(50), GPixel(nLin+48),GPixel(50))
	oPrn:Line(GPixel(nLin), GPixel(130), GPixel(nLin+48),GPixel(130))
	
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(20),"Tipo " ,oFont16N)
	oPrn:Say(GPixel(nLin), GPixel(70),"Quantidade Ida e Volta " ,oFont16N)
	oPrn:Say(GPixel(nLin), GPixel(145),"Valor Unitário " ,oFont16N)
	
	nLin := nLin + 2
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(180))
	nLin := nLin + 8
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(180))
	nLin := nLin + 8
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(180))
	nLin := nLin + 8
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(180))
	nLin := nLin + 8
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(180))
	nLin := nLin + 8
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(180))
	nLin := nLin + 8
	
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(05),Alltrim(SM0->M0_CIDCOB) + "/" + SM0->M0_ESTCOB + ", " + DtoC(dDataBase),oFont14)
	
	nLin := nLin + 10
	
	oPrn:Say(GPixel(nLin), GPixel(15),"___________________________________",oFont14)
	nLin := nLin + 8

	oPrn:Say(GPixel(nLin), GPixel(15),"Nome: " + QTEMP->NOME,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(15),"RG. Nº : " + QTEMP->RG,oFont14)
	
	oPrn:EndPage()
	oPrn:Preview()
return


/*/{Protheus.doc} DevolCT
//TODO Gera relatorio com a devolução da CTPS pelo empregado.
@author juliana.leme
@since 14/11/2018
@version 6
@return ${return}, ${return_description}

@type function
/*/
static Function DevolCT ()
	local nLin 				:= 0
	local cTitulo			:= ""
	private oPrn
	
	oPrn := FWMsPrinter():New("CBCDevCTPS"+ MV_PAR01+MV_PAR02,,.T.,"\ContrTrab\",.T.,,,,.T.)
	oPrn:SetPortrait()	// Formato pagina Paisagem
	oPrn:SetPaperSize(9)	//Papel A4
	oPrn:SetMargin(GPixel(05),GPixel(05),GPixel(05),GPixel(05))
	oPrn:Setup()
	oPrn:SetViewPDF(.T.)
	
	oPrn:StartPage(,"DevCTPS" + MV_PAR01+MV_PAR02)
	
	nLin := 8
	oPrn:Say(GPixel(nLin),GPixel(00),"Cobrecom - Filial :" + FwFilial() +  " - " + FWFilialName(FwFilial()) ,oFont10N)
	oPrn:Say(GPixel(nLin),GPixel(150),"Data/Hora Imp :" + DTOC(DATE()) + " - " + TIME(),oFont10N)
	nLin := nLin + 3
	oPrn:Say(GPixel(nLin),GPixel(150),"Usuario Imp :" + UsrRetName(RetCodUsr()),oFont10N)
		
	nLin := nLin + 2
	oPrn:Box (GPixel(nLin),GPixel(00),GPixel(250),GPixel(180),"-4")//( nRow, nCol, nBottom, nRight, cPixel)
	
	nLin := nLin + 5
	cTitulo := "COMPROVANTE DE DEVOLUÇÃO DA CARTEIRA DE TRABALHO"
	oPrn:Say(GPixel(nLin),GPixel(25),AV_Justifica(cTitulo),oFont18N)
	cTitulo := "E PREVIDÊNCIA SOCIAL"
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin),GPixel(60),AV_Justifica(cTitulo),oFont18N)
	nLin := nLin + 2
	oPrn:Line(GPixel(nLin), GPixel(00), GPixel(nLin),GPixel(180))
	
	nLin := nLin + 15
	oPrn:Say(GPixel(nLin), GPixel(15),"Nome do Empregado: " + QTEMP->NOME ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(15),"Carteira Profissional n.º: " + QTEMP->CARTEIRA + "/ " + QTEMP->SERIE+ " - " + QTEMP->UFCP,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(15),"Função: " + QTEMP->DESC_FUNCAO ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(15),"Data de Admissão: " + DtoC(StoD(QTEMP->ADMISSAO)) ,oFont14)
	
	nLin := nLin + 15
	oPrn:Say(GPixel(nLin), GPixel(15),"Recebemos a carteira de trabalho e previdência social acima, para as anotações necessárias e que será devolvida" ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(15),"dentro de 48 horas, de acordo com as disposições legais vigentes." ,oFont14)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(15),"Recebi em devolução a carteira de trabalho e previdência social acima, com as respectivas anotações." ,oFont14)
	
	nLin := nLin + 30
	oPrn:Say(GPixel(nLin), GPixel(15),Alltrim(SM0->M0_CIDCOB) + "/" + SM0->M0_ESTCOB + ", " + DtoC(dDataBase),oFont14)
	
	nLin := nLin + 20
	oPrn:Say(GPixel(nLin), GPixel(15),"_______________________________________" ,oFont14N)
	nLin := nLin + 5
	oPrn:Say(GPixel(nLin), GPixel(25),QTEMP->NOME ,oFont14N)
	
	oPrn:EndPage()
	oPrn:Preview()
return


/*/{Protheus.doc} GPixel
//TODO Converte Pixel em Milimetros.
@author juliana.leme
@since 03/09/2016
@version undefined
@param _nMm, numerico, converte milimetros em pixels
@type function
/*/
Static Function GPixel(_nMm)
	_nRet:=(_nMm/25.4)*300
Return(_nRet)


/*/{Protheus.doc} RetDados
//TODO Carrega dados necessarios para geração dos relatorios..
@author juliana.leme
@since 14/11/2018
@version 6
@return ${return}, ${return_description}
@param _cFilial, , descricao
@param cMatricula, characters, descricao
@type function
/*/
static function RetDados(_cFilial, cMatricula)
	Local cQuery		:= ""
	Local oSql, oMemo
	Local cItem		:= ""
	Local cItemP		:= ""
	local lRet 			:= .T.
	
	cQuery += " SELECT RA_MAT MATRICULA, RA_NOME NOME, RA_NUMCP CARTEIRA, RA_SERCP SERIE, RA_UFCP UFCP, "
	cQuery += " 			RA_ADMISSA ADMISSAO, RJ_DESC DESC_FUNCAO, RA_SALARIO SALARIO, "
	cQuery += " 			R6_DESC DESC_TURNO,	RA_VCTOEXP VENC_1, RA_VCTEXP2 VENC_2, RA_RG RG, "
	cQuery += " 			RA_ENDEREC ENDERECO,	RA_COMPLEM COMPL, RA_BAIRRO BAIRRO, RA_MUNICIP MUNICIPIO, "
	cQuery += " 			RA_ESTADO ESTADO,	RA_CEP CEP, RA_BAIRRO BAIRRO, RA_MUNICIP MUNICIPIO "
	cQuery += " FROM SRA010 "
	cQuery += " 	INNER JOIN SRJ010 ON RJ_FILIAL = '' AND RJ_FUNCAO = RA_CODFUNC "
	cQuery += " 	INNER JOIN SR6010 ON R6_FILIAL = RA_FILIAL AND R6_TURNO = RA_TNOTRAB "
	cQuery += " WHERE RA_FILIAL = '" + _cFilial + " ' "
	cQuery += " AND RA_MAT = '" + cMatricula + "' "
	cQuery += " AND SRA010.D_E_L_E_T_ = '' "
	
	If Select("QTEMP")>0
		DbSelectArea("QTEMP")
		DbCloseArea()
	EndIf
	
	TcQuery cQuery New Alias "QTEMP"
	DbSelectArea("QTEMP")
	
	If QTEMP->MATRICULA == cMatricula
		lRet := .T.
	Else
		lRet := .F.
	EndIf
return(lRet)