#include 'rwmake.ch'
#include 'topconn.ch'
#INCLUDE 'Protheus.ch'
#INCLUDE 'TOTVS.ch'

User Function CDImpCTe()
	local aDados
	local n1   		:= 1
	local n2		:= 0
	local dDataInv	:= dDataBase
	local cSql 		:= ""
	local nCont 	:= 1
	local cArqErr	:= "ErrCte.txt"
	local cArqOk	:= "OkCte.txt"
	local cDestMail	:= GetNewPar('ZZ_WFCTE', "wfti@cobrecom.com.br" )
	Public cMsg		:= ""
	Public cMsg1	:= ""

	aParamBox := {}
	aRet := ""

	if (dDataBase > StoD('20200228'))
		MsgAlert("Rotna DESATIVADA! Utilize a nova rotina de Ctes!")
	else
		aAdd(aParamBox,{6,"Informe Planilha com as CTES",Space(70),"","","" ,70,.T.,"Arquivo .XLS |*.XLS"})

		If !ParamBox(aParamBox, "Parametros", @aRet)
			Return(.F.)
		EndIf
		ProcRegua(0)
		cArq 		:= Alltrim(Substr(aRet[1],rat("\",aRet[1])+1,len(aRet[1])))
		cOrigem	:= Alltrim(Substr(aRet[1],1,rat("\",aRet[1])))

		Processa( {|| aDados:= U_CargaXLS(cArq,cOrigem,,.F.)},"Aguarde, carregando planilha...Pode demorar")
		
		If Len(aDados) > 0
			If MsgBox("Confirma o Processamento na FILIAL " + FWCodFil() + "/" + Alltrim(SM0->M0_FILIAL) + " ?","Confirma?","YesNo")
				Processa({|| Importa(aDados)})
			Else
				Return
			EndIf
		Else
			Aviso("Atenção","Planilha sem informações, Processo não realizado!",{"Ok"},1)
		EndIf

		//Envia Email 
		If cMsg1 <> ""
			cMsg1 := CRLF + cMsg1
			U_ConsoleLog("CTe INCLUIDAS COM SUCESSO",cMsg1,cArqOk) //cTipo = (ERRO,CONCLUIDO,EXCESSAO) cMsg = (Mensagem destinada a informação)
			Processa({|| U_ArqPorEmail(cArqOk,Alltrim(cDestMail),"[OK]CTes Incluidas")},"Enviando Email CTe OK...")
		EndIf

		//Envia Email 
		If cMsg <> ""
			cMsg := CRLF + cMsg
			U_ConsoleLog("INTEGRACAO NAO REALIZADA - CTe  ",cMsg,cArqErr) //cTipo = (ERRO,CONCLUIDO,EXCESSAO) cMsg = (Mensagem destinada a informação)
			Processa({|| U_ArqPorEmail(cArqErr, Alltrim(cDestMail),"[ERROS]INTEGRACAO NAO REALIZADA - CTe")},"Enviando Email Erros...")
		Else
			Aviso("Atenção","Importação com exito!",{"Ok"},1)
		EndIf
	endif
Return(.T.)


Static Function Importa(_aDados)
	local n1   				:= 1
	local _cCF 				:= ""
	local _baseICMS			:= 0
	local cDctInfo			:= ""
	local cForInfo			:= ""
	local cCteSeri			:= ""
	local aErro 				:= {}
	local cMunIni				:= ''
	local cMunFim				:= ''
	local cUfIni				:= ''
	local cUfFim				:= ''
	local nTamCampo			:= 0
	private	lMsErroAuto		:= .F.
	private lMsHelpAuto		:= .T.
	private lAutoErrNoFile	:= .T.

	ProcRegua(LastRec())
	_nQtDel 	:= 0
	n2 			:= Len(_aDados)
	While n1 <= n2
		IncProc()
		If Empty(_aDados[n1][3]) .Or. "X" $ Upper(_aDados[n1][3]) .Or. "F" $ Upper(_aDados[n1][1])
			//Desconsiderar este registro
			ADel(_aDados,n1)
			-- n2
		Else
			_aDados[n1][3]:= StrZero(Val(_aDados[n1][3]),9) // Juliano solicitou deixar com 9 dígitos todos os CTRs. (18/05/15/09:23h)
			If Empty(_aDados[n1][1])
				cMsg := cMsg + Chr(13) + "FILIAL: sem informação"
			EndIf
			If Empty(_aDados[n1][8])
				cMsg := cMsg + Chr(13) + "SERIE: sem informação"
			EndIf
			If Empty(_aDados[n1][2])
				cMsg := cMsg + Chr(13) + "CNP: sem informação"
			EndIf
			If Empty(_aDados[n1][4])
				cMsg := cMsg + Chr(13) + "EMISSAO: sem informação"
			EndIf
			If Empty(_aDados[n1][5])
				cMsg := cMsg + Chr(13) + "VALOR: sem informação"
			EndIf
			If !Empty(cMsg)
				cMsg += "O Conhecimento " + AllTrim(_aDados[n1][3]) + " tem os seguintes erros " + cMsg + Chr(13) + "SERÁ DESCONSIDERADO"  + CRLF
				Alert(cMsg)
				ADel(_aDados,n1)
				-- n2
			Else
				++ n1
			EndIf
		Endif
	EndDo

	_dUltDia := dDatabase
	_nMesAtu := Month(_dUltDia)
	Do While Month(--_dUltDia) == _nMesAtu
	EndDo
	_dUltDia++
	_nDias := 0
	Do While _nDias < 5
		_dUltDia--
		If _dUltDia == DataValida(_dUltDia)
			_nDias++
		EndIf
	EndDo

	for n1:= 1 to n2
		IncProc()
		_tFILIAL  := StrZero(Val(_aDados[n1][1]),2)
		If _tFILIAL == xFilial("SF1") //cFilAnt
			_tCNPJ		:= AllTrim(StrTran(StrTran(StrTran(StrTran(_aDados[n1][2],".",""),"-",""),",",""),"/",""))
			_tCNPJ		:= StrZero(Val(_tCNPJ),14)
			_tSERIE		:= Left(AllTrim(_aDados[n1][8]) + "   ",3)
			_tNUM		:= StrZero(Val(_aDados[n1][3]),9)

			_tEMISSAO	:= CtoD(_aDados[n1][4])
			_tVALOR		:= Val(StrTran(StrTran(_aDados[n1][5],".",""),",",".")) - Val(StrTran(StrTran(_aDados[n1][6],".",""),",","."))
			_tPEDAGIO	:= Val(StrTran(StrTran(_aDados[n1][6],".",""),",","."))
			_tICMS		:= Val(StrTran(StrTran(_aDados[n1][7],".",""),",","."))
			_baseICMS	:= Val(StrTran(StrTran(_aDados[n1][12],".",""),",",".")) //[LEO]-20/09/16 - Adicionar campo base de ICMS
			_tChave		:= Alltrim(_aDados[n1][11])//Chave NFe
	            
			cDctInfo 	:= ' [INFO] - Docto. ' + _tNUM +' Serie. ' + _tSERIE + ' Chave. ' + _tChave + ' CNPJ. ' + _tCNPJ + CRLF
			cCteSeri	:=  _tNUM + "/" + _tSERIE
			
			if len(_aDados[n1]) >= 16
				if !empty(_aDados[n1, 14]) .and. !empty(_aDados[n1, 16])
					if  len(Alltrim(_aDados[n1, 14])) >=  (nTamCampo := TamSx3('F1_MUORITR')[1])
						cUfIni		:= Alltrim(_aDados[n1, 13])
						cMunIni		:= Right(Alltrim(_aDados[n1, 14]),nTamCampo)
					endif
					if  len(Alltrim(_aDados[n1, 16])) >=  (nTamCampo := TamSx3('F1_MUDESTR')[1])
						cUfFim		:= Alltrim(_aDados[n1, 15])
						cMunFim		:= Right(Alltrim(_aDados[n1, 16]), nTamCampo)
					endif
				endif
			endif
		
			// Posiciona o cadastro do fornecedor
			DbSelectArea("SA2")
			DbSetOrder(3) // A2_FILIAL+A2_CGC
			If !DbSeek(xFilial("SA2") + _tCNPJ,.F.)
				cMsg += "Cadastro do Fornecedor não encontrado, Não realizado! " + Alltrim(cDctInfo)
				Loop
			EndIf

			Do While SA2->A2_FILIAL	== xFilial("SA2") .And. SA2->A2_CGC == _tCNPJ .And. ;
					SA2->A2_MSBLQL == "1" .And. SA2->(!Eof()) // Cadastro Bloqueado
				cMsg += "Cadastro do Fornecedor Bloqueado, Não realizado!" + Alltrim(cDctInfo)
				SA2->(DbSkip())
			EndDo

			If SA2->A2_FILIAL # xFilial("SA2") .Or. SA2->A2_CGC # _tCNPJ .Or. SA2->(Eof())
				cMsg += "Cadastro do Fornecedor não encontrado, Não realizado!" + Alltrim(cDctInfo)
				Loop
			EndIf
			cForInfo := SA2->(A2_COD) + (SA2->A2_LOJA) + CRLF

			// Verifica se existe a nota no SF1
			DbSelectArea("SF1")
			DbSetOrder(1) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
			If DbSeek(xFilial("SF1") + _tNUM + _tSERIE + SA2->A2_COD + SA2->A2_LOJA + "N", .F. )
				cMsg += "CTe ja existente, Não realizado!" + cCteSeri + " Fornecedor: " + cForInfo
				Loop
			EndIf

			_tNUM2 := Left(AllTrim(Str(Val(_tNUM))) + Space(9),9)
			If DbSeek(xFilial("SF1") + _tNUM2 + _tSERIE + SA2->A2_COD + SA2->A2_LOJA + "N",.F.)
				cMsg += "CTe ja existente, Não realizado!" + cCteSeri + " Fornecedor: "+ cForInfo
				Loop
			EndIf

			If _tEMISSAO < _dUltDia // Não pode
				_cTES := If(_tICMS == 0,"072","071")
			Else // Pode
				_cTES := If(_tICMS == 0,"034","017")
			EndIf

			// Verifica CFOP na TES
			DbSelectArea("SF4")
			DbSetOrder(1) // F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
			_cCF := Posicione("SF4",1,xFilial("SF4")+_cTES,"F4_CF")

			aCabs  := {}
			aCabs :=	{{'F1_FILIAL'	, FWCodFil()	, Nil},;
				{'F1_TIPO'		, "N"     			, Nil},;
				{'F1_FORMUL'		, "N"		    		, Nil},;
				{'F1_DOC'		, _tNUM     			, Nil},;
				{'F1_SERIE'		, _tSERIE			, Nil},;
				{'F1_EMISSAO'		, _tEMISSAO			, Nil},;
				{'F1_FORNECE'		, SA2->A2_COD			, Nil},;
				{'F1_LOJA'		, SA2->A2_LOJA		, Nil},;
				{'F1_EST'		, SA2->A2_EST			, Nil},;
				{'F1_UFORITR'		, cUfIni				, Nil},;
				{'F1_MUORITR'		, cMunIni			, Nil},;
				{'F1_UFDESTR'		, cUfFim				, Nil},;
				{'F1_MUDESTR'		, cMunFim			, Nil},;
				{'F1_DESPESA'		, 0.00				, Nil},;
				{'F1_DTDIGIT'		, ddatabase			, Nil},;
				{'F1_ESPECIE'		, "CTE"        		, Nil},;
				{'F1_VALPEDG'		, _tPEDAGIO      		, Nil},;
				{'F1_TPFRETE'		, "N"		      	, Nil},;
				{'F1_TPCTE'		, "N"		     	, Nil},;
				{'F1_CHVNFE'		, _tChave			, Nil}}
			aItens	:= {}

			SB1->(DbSetOrder(1))
			cD1Cod1 := If(SB1->(DbSeek(xFilial("SB1")+"SV05000020     ",.F.)),"SV05000020     ","0000001683     ")
			cD1Cod2 := If(SB1->(DbSeek(xFilial("SB1")+"SV05000021     ",.F.)),"SV05000021     ","0000002515     ")

			_cCod := Left(If(_tICMS < 12,cD1Cod1,cD1Cod2) + Space(Len(SB1->B1_COD)),Len(SB1->B1_COD))

			SB1->(DbSetOrder(1))
			SB1->(DbSeek(xFilial("SB1")+_cCod,.F.))

			aItem := {}
			aItem:= {	{'D1_ITEM'		, Padr("01",TamSX3("D1_ITEM")[1]), Nil},;
							{'D1_COD'		, _cCod				, Nil},;
							{'D1_DESCRI'	, SB1->B1_DESC	, Nil},;
							{'D1_UM'			, SB1->B1_UM		, Nil},;
							{'D1_QUANT'	, 1.00					, Nil},;
							{'D1_TES'		, _cTES				, Nil},;  // If(_tICMS == 0,"034","017")
							{'D1_CF'			, _cCF				, Nil},;
							{'D1_VUNIT'	, _tVALOR			, Nil},;
							{'D1_TOTAL'	, _tVALOR			, Nil},;
							{'D1_PICM'		, _tICMS				, Nil},;
							{'D1_BASEICM'	, _baseICMS		, Nil},; //[LEO]-20/09/16 - Adicionar campo base de ICMS
							{'D1_LOCAL'	, "01"					, Nil},;
							{'D1_RATEIO'	, "2"					, Nil} }
			aAdd(aItens,aItem)
	
			MsAguarde( { || MSExecAuto({|x,y,z| mata103(x,y,z)},aCabs,aItens,3)},"Aguarde",;
				"Importando XML CT-e... Documento: " + Alltrim(cCteSeri) )
			If lMsErroAuto
				cMsg += "ExecAuto não realizado!:" + Alltrim(cCteSeri)
				cuidaErro()
			Else
				cMsg1 += "NF CTe incluida com sucesso : " + Alltrim(cDctInfo)
			EndIf
		EndIf
	Next
Return( .T. )

/*/{Protheus.doc} cuidaErro
@author bolognesi
@since 09/02/2017
@version 1.0
@type function
@description Função para tratar o array de erros
da rotina automatica.
/*/
static function cuidaErro()
	local aErro	:= {}
	local nX	:= 0
	aErro := GetAutoGrLog()
	if !empty(aErro)
		cMsg += aErro[1] + chr(13)
		If Len(aErro) > 1
			for nX := 2 To Len(aErro)
				if  'Invalido' $ aErro[nX] .OR. 'Erro' $ aErro[nX]
					cMsg += aErro[nX] + CRLF
				endIf
			next nX
		EndIf
	endif
return(nil)
