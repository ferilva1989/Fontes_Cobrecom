#include "rwmake.ch"

//////////////////////////////////////////////////////////////////////////////
//                                                                          //
//   Programa ...: 			                      modulo : SIGAFIN/SIGACTB  //
//                                                                          //
//   Autor ......: GUSTAVO FUENTES ZACARIAS           Data ..: 11/04/2013   //
//                                                                          //
//   Objetivo ...: Solicitado pela Rôsangela e Juliano da Contabilidade,    //
//   para que quando for uma venda de BNDES, o histórico do Lançamento      //
//   Padrão seja preenchido com o NÚMERO do BNDES e o NÚMERO da NOTA.		//							                              
//                                                                          //
//   Uso ........: Especifico da Condusul                                   //
//////////////////////////////////////////////////////////////////////////////

User Function HISTBNDES()

	If SE5->E5_BENEF == "BNDES"
		_cCT5_HIST := Left("DT-"+"Rec.DP"+SE5->E5_NUMERO+ "/" +SE5->E5_HISTOR+"-BNDES",41)   
	Else	
		// _cCT5_HIST := Left("DT-"+"Rec.duplic. " + SE5->E5_NUMERO + "/" + AllTrim(SE5->E5_PARCELA) + "-" + AllTrim(SE1->E1_NOMCLI) + " " + If(!empty(SE1->E1_DEPOS),"Bco.: " + SE1->E1_DEPOS," "),41) 
		//LEO 27/01/2015- Diego Totvs Linha original comentada acima
		_cCT5_HIST := Left("DT-"+"Rec. " + SE5->E5_NUMERO + "/" + AllTrim(SE5->E5_PARCELA) + "-" + AllTrim(SE1->E1_NOMCLI) + " " + If(!empty(SE1->E1_DEPOS),"Bco.: " + SE1->E1_DEPOS," "),41)                         
	EndIf				Left("DS-"+"Desc. Dp. "   + SE5->E5_NUMERO + "/" + AllTrim(SE5->E5_PARCELA) + "-" + AllTrim(SE1->E1_NOMCLI) + " " + If(!empty(SE1->E1_DEPOS),"Bco.: " + SE1->E1_DEPOS," "),41)                             

	Return(_cCT5_HIST)                   
	*
	**********
	/* ESSES SÃO OS LANÇAMENTOS QUE FORAM INCLUSO A FUNÇÃO "U_HISTBNDES()" NO CAMPO CT5_HIST, E FOI RETIRADO ESSA LINHA DE CODIGO DO CAMPO .
	520: 
	004/Left("DT-"+"Rec.duplic. " + SE5->E5_NUMERO + "/" + AllTrim(SE5->E5_PARCELA) + "-" + AllTrim(SE1->E1_NOMCLI) + " " + If(!empty(SE1->E1_DEPOS),"Bco.: " + SE1->E1_DEPOS," "),41)                          

	521: 
	001/Left("DT-"+"Rec.duplic. " + SE5->E5_NUMERO + "/" + AllTrim(SE5->E5_PARCELA) + "-" + AllTrim(SE1->E1_NOMCLI) + " " + If(!empty(SE1->E1_DEPOS),"Bco.: " + SE1->E1_DEPOS," "),41)                          
	004/Left("DT-"+"Rec.duplic. " + SE5->E5_NUMERO + "/" + AllTrim(SE5->E5_PARCELA) + "-" + AllTrim(SE1->E1_NOMCLI) + " " + If(!empty(SE1->E1_DEPOS),"Bco.: " + SE1->E1_DEPOS," "),41)                          

	522:
	001/Left("DT-"+"Rec.Dp. " + SE5->E5_NUMERO + "/" + AllTrim(SE5->E5_PARCELA) + "-" + AllTrim(SE1->E1_NOMCLI) + " " + If(!empty(SE1->E1_DEPOS),"Bco.: " + SE1->E1_DEPOS," "),41)                               
	*/
	**********
	/* ESSES SÃO OS LANÇAMENTOS QUE NÃO FORAM INCLUSO A FUNÇÃO "U_HISTBNDES()" NO CAMPO CT5_HIST.
	521:
	002
	Left("DS-"+"Desc. Dp. "+ SE5->E5_NUMERO + "/" + AllTrim(SE5->E5_PARCELA) + "-" + AllTrim(SE1->E1_NOMCLI) + " " + If(!empty(SE1->E1_DEPOS),"Bco.: " + SE1->E1_DEPOS," "),41)                             

	520:
	001
	//Left("DT-"+ SE5->E5_NUMERO + "/" + AllTrim(SE5->E5_PARCELA) + "-" + AllTrim(SE1->E1_NOMCLI) + " " + If(!empty(SE1->E1_DEPOS),"Bco.: " + SE1->E1_DEPOS," "),41)                                          

	522:
	002
	Left("DS-"+"Desc. Dp. "+ SE5->E5_NUMERO + "/" + AllTrim(SE5->E5_PARCELA) + "-" + AllTrim(SE1->E1_NOMCLI) + " " + If(!empty(SE1->E1_DEPOS),"Bco.: " + SE1->E1_DEPOS," "),41)                                                                                                                                                                                                                           
	*/
	**********
*