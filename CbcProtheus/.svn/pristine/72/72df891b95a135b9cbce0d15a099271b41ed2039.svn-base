#include "rwmake.ch"
#include "protheus.ch"
#INCLUDE 'tbiconn.ch'
#include "TOPCONN.ch"

/*
Programa : WF_ApvDoc
Autor    : Jeferson Gardezani
Data     : 03/03/16
Descrição: Enviar e-mail para avisar os aprovadores sobre documentos pendentes de
           aprovação.
*/

User Function WF_ApvDoc

Local cQry, i, cNome
Local aSCR  	:= {}
Local aMail 	:= {}

If Select("SX2") == 0
	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"
EndIf             

// Seleciona Documentos para Aprovação
cQry := " SELECT"
cQry += "   CR.CR_USER,"						//[1]Cod.Usuário
cQry += "   CASE"
cQry += "     WHEN CR.CR_FILIAL = '01'"
cQry += "       THEN 'ITU'"
cQry += "     WHEN CR.CR_FILIAL = '02'"
cQry += "       THEN '3 LAGOAS'"
cQry += "     ELSE 'N/I'"
cQry += "   END,"								//[2]Filial
cQry += " 	CR.CR_TIPO,"						//[3]Tipo Documento
cQry += " 	CR.CR_NUM,"							//[4]NºDocumento
cQry += " 	CR.CR_EMISSAO,"						//[5]Emissão
cQry += " 	CR.CR_TOTAL,"						//[6]Valor
cQry += " 	CASE"
cQry += "     WHEN CR.CR_STATUS = '02'"			//AGUARDANDO LIBERAÇÃO DO USUÁRIO
cQry += "       THEN 'Aguardando Aprovação'"
cQry += "     WHEN CR.CR_STATUS = '04'"			//BLOQUEADO PELO USUÁRIO
cQry += "       THEN 'Bloqueado'"
cQry += "     ELSE 'N/I'"
cQry += "   END,"								//[7]Status
cQry += "   CR.CR_OBS"							//[8]Observacao
cQry += " FROM SCR010 CR"
cQry += " WHERE"									//NÃO EXISTE ÍNDICE EXATO, CRIAR SE NECESSÁRIO
cQry += "   CR.CR_STATUS NOT IN ('01','03','05')"	//01=BLOQ.PARA O SISTEMA (AGUARD.OUTROS NÍVEIS) | 03=LIBERADO PELO USUÁRIO | 05=LIBERADO POR OUTRO USUÁRIO
cQry += "   AND CR.D_E_L_E_T_ = ''"
cQry += " ORDER BY CR.CR_USER, CR.CR_EMISSAO ASC"

aSCR := u_qryarr(cQry)

If !Empty(aSCR)

	//Inicializa código do usuário para primeira comparação
	cUser := aSCR[1][1]

	For i := 1 To Len(aSCR)

		If aSCR[i][1] <> cUser

			//Envia e-mail
			cNome := Upper(Alltrim(UsrFullName(cUser)))  
			u_envmail({U_GetUmail(cUser),"wfti@cobrecom.com.br"},;
			           "[SISTEMA COMPRAS]-Documentos para Aprovação ("+cNome+")",;
			           {"Filial","Tipo","Número","Emissão","Valor","Status","Observação"},;
			           aMail)

			//Atualiza variáveis mudança de usuário
			cUser := aSCR[i][1]
			aMail := {}
			//__CUSERID

			//Adiciona item
			//aMail: Filial, Tipo Documento, Nº Documento, Emissão, Valor, Status, Observacao
			Aadd(aMail,{aSCR[i][2],;
			            Alltrim(aSCR[i][3]),;
			            Alltrim(aSCR[i][4]),;
			            Substr(aSCR[i][5],7,2)+'/'+Substr(aSCR[i][5],5,2)+'/'+Substr(aSCR[i][5],1,4),;
			            Alltrim(Transform(aSCR[i][6],"@E 999,999,999.99")),;
			            Alltrim(aSCR[i][7]),;
			            Alltrim(aSCR[i][8])})
		Else

			//Adiciona item
			//aMail: Filial, Tipo Documento, Nº Documento, Emissão, Valor, Status, Observacao
			Aadd(aMail,{aSCR[i][2],;
			            Alltrim(aSCR[i][3]),;
			            Alltrim(aSCR[i][4]),;
			            Substr(aSCR[i][5],7,2)+'/'+Substr(aSCR[i][5],5,2)+'/'+Substr(aSCR[i][5],1,4),;
			            Alltrim(Transform(aSCR[i][6],"@E 999,999,999.99")),;
			            Alltrim(aSCR[i][7]),;
			            Alltrim(aSCR[i][8])})

		EndIf

	Next

	//Envia e-mail (último aprovador)
	cNome := Upper(Alltrim(UsrFullName(cUser)))  
	u_envmail({U_GetUmail(cUser),"wfti@cobrecom.com.br"},;
	           "[SISTEMA COMPRAS]-Documentos para Aprovação ("+cNome+")",;
	           {"Filial","Tipo","Número","Emissão","Valor","Status","Observação"},;
	           aMail)

EndIf

Return Nil
