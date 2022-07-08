#include "rwmake.ch"
#include "topconn.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#include "protheus.ch"
#INCLUDE "TOTVS.CH"
#include "tbiconn.ch" 


/*/{Protheus.doc} CDSendVol
//TODO Esta função é chamada pelo coletor quando solicita ao protheus dados para a montagem de volumes
Parâmetros 	cOperador	- Operador
			cNumOs 		- Número da Ordem de Separação
			cSeqOs		- Sequência da Ordem de Separação
Retorno:
	Devolver array com? 
	{	{Tipo, ID , Quantidade}
		{Tipo, ID , Quantidade}
		{Tipo, ID , Quantidade} }

	Tipo: V - Volume - P-Produto ou B-Bobina

	ID: Números do código de Barras
		Volume - Numero do Volume
		Produto - Código da etiqueta de "rolos"
		Bobina - Código da Etiqueta de Bobina

	Quantidade:
		Volume - sempre 1
		Produto - Quantidade de lances
		Bobina - sempre 1.
@author Roberto
@since 18/07/2017
@version undefined
@param cOperador, characters, descricao
@param cNumOs, characters, descricao
@param cSeqOs, characters, descricao
@type function
/*/
User Function CDSendVol(cOperador,cNumOs, cSeqOs, _lTemErro, cErrMsg) // u_CDSendVol("001","166102","06")
	Local cNumOs, cSeqOs, _aVolta := {}, _cZZR_ID, _nOSs, _aOSs
	Default cNumOs := "      "
	Default cSeqOs := "  "
	default _lTemErro := .F.
	default cErrMsg	:= ""
	
	// Verificar se a O.S. não tem um ID de separação - criar
	DbSelectArea("ZZR")
	DbSetOrder(2) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_SEQOS+ZZR_ITEMPV+ZZR_SEQUEN
	DbSeek(xFilial("ZZR")+cNumOs+cSeqOs,.F.)
	_cZZR_ID := ZZR->ZZR_ID
	If Empty(_cZZR_ID) // Não tenho um ID, então crio um
	
		_cZZR_ID := u_MVPXZZRID()
		If	_cZZR_ID == "ERRO_ID"
			// Este erro ocorre quando não tenho lacuna de ID entre 000001 e 999999
			// alterar o tamanho dos campos ZZR_ID E ZZO_ID, bem como o tratamento em impressões
			AADD(_aVolta,"Erro no Identificador -> Comunique T.I.")
			Return(_aVolta)
		EndIf
	
		cQuery := "UPDATE "+RetSqlName("ZZR") + " SET ZZR_ID = '"+_cZZR_ID+"'"
		cQuery += " WHERE ZZR_FILIAL = '"+xFilial("ZZR")+"'"
		cQuery += " AND ZZR_PEDIDO = '"+cNumOs+"'"
		cQuery += " AND ZZR_SEQOS  = '"+cSeqOs+"'"
		cQuery += " AND ZZR_SITUAC <> '9'"
		cQuery += " AND D_E_L_E_T_ = ''"
		TCSqlExec(cQuery)
	
		cQuery := "UPDATE "+RetSqlName("ZZO") + " SET ZZO_ID = '"+_cZZR_ID+"'"
		cQuery += " WHERE ZZO_FILIAL = '"+xFilial("ZZO")+"'"
		cQuery += " AND ZZO_PEDIDO = '"+cNumOs+"'"
		cQuery += " AND ZZO_SEQOS  = '"+cSeqOs+"'"
		cQuery += " AND D_E_L_E_T_ = ''"
		TCSqlExec(cQuery)
	EndIf
	
	DbSelectArea("ZAA")
	DbSetOrder(1) // ZAA_FILIAL+ZAA_CHAVE
	
	DbSelectArea("ZZO") // Volumes das O.S.
	DbSetOrder(1) // ZZO_FILIAL+ZZO_PEDIDO+ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN+ZZO_LOCALI
	
	cQuery := "SELECT ZZR_FILIAL, ZZR_PEDIDO, ZZR_SEQOS, ZZR_ITEMPV, ZZR_SEQUEN, ZZR_LOCALI, ZZR_BARINT, ZZR_QTCAIX, "
	cQuery += "	SUM(ZZR_QUAN) ZZR_QUAN, SUM(ZZR_LANCES) ZZR_LANCES, "
	cQuery += "		ISNULL((SELECT SUM(ZZO_QUANT) ZZO_QUANT"
	cQuery += "				FROM "+RetSqlName("ZZO") + " ZZO_A"
	cQuery += "					WHERE ZZO_A.ZZO_FILIAL = ZZR_FILIAL"
	cQuery += "					AND ZZO_A.ZZO_PEDIDO   = ZZR_PEDIDO"
	cQuery += "					AND ZZO_A.ZZO_SEQOS    = ZZR_SEQOS"
	cQuery += "					AND ZZO_A.ZZO_ITEMPV   = ZZR_ITEMPV"
	cQuery += "					AND ZZO_A.ZZO_SEQUEN   = ZZR_SEQUEN"
	cQuery += "					AND ZZO_A.ZZO_LOCALI   = ZZR_LOCALI"
	cQuery += "					AND ZZO_A.ZZO_NUMBOB   = ZZR_NROBOB"
	cQuery += "					AND ZZO_A.ZZO_VOLDES   = '  '"
	cQuery += "					AND ZZO_A.D_E_L_E_T_   = ''),0) ZZO_QUANT,"
	cQuery += "		ISNULL((SELECT SUM(ZZO_LANCES)"
	cQuery += "					FROM "+RetSqlName("ZZO") + " ZZO_B"
	cQuery += "						WHERE ZZO_B.ZZO_FILIAL = ZZR_FILIAL"
	cQuery += "						AND ZZO_B.ZZO_PEDIDO   = ZZR_PEDIDO"
	cQuery += "						AND ZZO_B.ZZO_SEQOS    = ZZR_SEQOS"
	cQuery += "						AND ZZO_B.ZZO_ITEMPV   = ZZR_ITEMPV"
	cQuery += "						AND ZZO_B.ZZO_SEQUEN   = ZZR_SEQUEN"
	cQuery += "						AND ZZO_B.ZZO_LOCALI   = ZZR_LOCALI"
	cQuery += "						AND ZZO_B.ZZO_NUMBOB   = ZZR_NROBOB"
	cQuery += "						AND ZZO_B.ZZO_VOLDES   = '  '"
	cQuery += "						AND ZZO_B.D_E_L_E_T_   = ''),0) ZZO_LANCES"
	cQuery += " FROM "+RetSqlName("ZZR") + " ZZR"
	cQuery += " WHERE ZZR_FILIAL = '"+xFilial("ZZR")+"'"
	cQuery += "	AND ZZR_ID = '"+_cZZR_ID+"'"
	cQuery += " AND ZZR_SITUAC <> '9'"
	cQuery += " AND ZZR.D_E_L_E_T_ = ''"
	cQuery += " GROUP BY ZZR_FILIAL, ZZR_PEDIDO, ZZR_SEQOS, ZZR_ITEMPV, ZZR_SEQUEN, ZZR_LOCALI, ZZR_BARINT,ZZR_NROBOB, ZZR_QTCAIX"
	cQuery += " ORDER BY ZZR_FILIAL, ZZR_PEDIDO, ZZR_SEQOS, ZZR_ITEMPV, ZZR_SEQUEN, ZZR_LOCALI, ZZR_BARINT,ZZR_NROBOB, ZZR_QTCAIX"
	cQuery := ChangeQuery(cQuery)
	If Select("TB_ZZR")>0    
		TB_ZZR->(dbcloseArea())
		FErase( "TB_ZZR" + GetDbExtension())
	EndIf
	TCQUERY cQuery NEW ALIAS "TB_ZZR"
	            
	// Atenção : Variável para poder localizar os dados do ZZO, uma vez que não se trata mais de uma O.S.,
	// pode ter várias O.S. aglutinadas em um processo só de formação de volumes
	_aOSs := {}
	DbSelectArea("TB_ZZR")
	 TB_ZZR->(DbGotop())
	Do While TB_ZZR->(!Eof())
		If TB_ZZR->ZZO_QUANT > TB_ZZR->ZZR_QUAN .Or. TB_ZZR->ZZO_LANCES > TB_ZZR->ZZR_LANCES
			//	Feito mais do que deveria
			AADD(_aVolta,"Qtde SUPERIOR a quantidade solicitada, Favor verificar!")
			cErrMsg	:= "Item: " + TB_ZZR->ZZR_ITEMPV + " com Qtde SUPERIOR! Solicitado: " + cValToChar(TB_ZZR->ZZR_LANCES) + " Realizado: " + cValToChar(TB_ZZR->ZZO_LANCES)
			_lTemErro := .T.
			Exit
		ElseIf ((TB_ZZR->ZZO_QUANT <  TB_ZZR->ZZR_QUAN .And. TB_ZZR->ZZO_LANCES == TB_ZZR->ZZR_LANCES) .Or.;
		        (TB_ZZR->ZZO_QUANT == TB_ZZR->ZZR_QUAN .And. TB_ZZR->ZZO_LANCES <  TB_ZZR->ZZR_LANCES))
			// Já completou quantidade ou lances... não pode fazer mais.
			AADD(_aVolta,"Qtde de lances TOTAL, Favor verificar!")
			cErrMsg	:= "Qtde de lances TOTAL, Favor verificar!"
			_lTemErro := .T.
			Exit
		ElseIf TB_ZZR->ZZO_QUANT # TB_ZZR->ZZR_QUAN .Or. TB_ZZR->ZZO_LANCES # TB_ZZR->ZZR_LANCES
			// Ainda tenho produto a coletar
			_cTipo := If(Left(TB_ZZR->ZZR_LOCALI,1) == "B","B","P")
			nPos := aScan(_aVolta, {|x|x[1] == _cTipo .And. x[2]==TB_ZZR->ZZR_BARINT})
			If nPos == 0
				If TB_ZZR->ZZR_QTCAIX > 1 // Tenho controle por Caixas (Blisters) Juliana -- 18/07/2017 
					_aDetArr := {_cTipo,TB_ZZR->ZZR_BARINT,((TB_ZZR->ZZR_LANCES-TB_ZZR->ZZO_LANCES) / TB_ZZR->ZZR_QTCAIX)} //  -> Quant. de Caixas
					AADD(_aVolta,_aDetArr)
				Else
					_aDetArr := {_cTipo,TB_ZZR->ZZR_BARINT,(TB_ZZR->ZZR_LANCES-TB_ZZR->ZZO_LANCES)} //  -> Quant. de lances 
					AADD(_aVolta,_aDetArr)
				EndIf
			Else
				If TB_ZZR->ZZR_QTCAIX > 1 // Tenho controle por Caixas (Blisters) Juliana -- 18/07/2017 
					_aVolta[nPos,3] += ((TB_ZZR->ZZR_LANCES-TB_ZZR->ZZO_LANCES) / TB_ZZR->ZZR_QTCAIX) //Blisters (Controle Caixa)
				Else
					_aVolta[nPos,3] += (TB_ZZR->ZZR_LANCES-TB_ZZR->ZZO_LANCES)
				EndIf
			EndIf
		EndIf
	    // Adiciono para ver os volumes que tenho que acrescentar no coletor.
		If aScan(_aOSs,TB_ZZR->ZZR_PEDIDO+TB_ZZR->ZZR_SEQOS) == 0 // Adiciono no array se não existir
			AADD(_aOSs,TB_ZZR->ZZR_PEDIDO+TB_ZZR->ZZR_SEQOS)
		EndIf
		TB_ZZR->(DbSkip())
	EndDo
	
	If Select("TB_ZZR")>0
		TB_ZZR->(dbcloseArea())
		FErase( "TB_ZZR" + GetDbExtension())
	EndIf
	
	// Carrega os dados da ZZO
	_cVolInc := "" // Volumes já incluidos no array - Para não incluir mais de uma vez.
	
	For _nOSs := 1 to Len(_aOSs)
		DbSelectArea("ZZO")
		DbSetOrder(1) // ZZO_FILIAL+ZZO_PEDIDO+ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN+ZZO_LOCALI
		//DbSeek(xFilial("ZZO") + cNumOs + cSeqOs,.F.)
		DbSeek(xFilial("ZZO") + _aOSs[_nOSs],.F.)
		//Do While ZZO->ZZO_FILIAL == xFilial("ZZO") .And. ZZO->ZZO_PEDIDO == cNumOs .And. ZZO->ZZO_SEQOS == cSeqOs .And. ZZO->(!Eof()) .And. !_lTemErro
		Do While ZZO->ZZO_FILIAL == xFilial("ZZO") .And. (ZZO->ZZO_PEDIDO+ZZO->ZZO_SEQOS) == _aOSs[_nOSs] .And. ZZO->(!Eof()) .And. !_lTemErro
			If Empty(ZZO->ZZO_BARINT)
				// Devido ao tipo do código de barras usado na impressão do relatório dos volumes, UPC-A, este não
				// pode iniciar com 0, então inicio a string com um 9 e o tamanho total da string fica em sete dígitos,
				// que serão tratados pelo coletor.
				ZZO->(RecLock("ZZO",.F.))
				ZZO->ZZO_BARINT := "9" + StrZero(Val(ZZO->ZZO_NUMVOL),10)
				// O cód. de barras do tipo UPCA tem que ter 11 dígitos e não pode iniciar com zero. É o próprio número do volume.
				ZZO->(MsUnLock())
			EndIf                    
			If  !(ZZO->ZZO_NUMVOL $ _cVolInc)
				If ZZO->ZZO_STATUS $ "23" .Or. ZZO->ZZO_TIPO == "A"
					// ZZO_STATUS -> 0=Não Conferido;1=Conferido;2=Carregado;3-Expedido
					// ZZO_TIPO   -> (A)berto (F)echado (S)aco}  
					//Volumes não conferidos, já carregados, já expedidos ou tipo aberto não podem fazer parte de outro volume
					_cVolInc += "//" + ZZO->ZZO_NUMVOL // Somente adiciona em _cVolInc para não entrar mais neste IF
				ElseIf Empty(ZZO->ZZO_VOLDES)
					// Indica que este volume está ativo, não foi adicionado a outro volume e ainda não inclui neste array.
					_cVolInc += "//" + ZZO->ZZO_NUMVOL // Adiciona em _cVolInc para não entrar mais neste IF
					_aDetArr := {"V",ZZO->ZZO_BARINT,1}
					AADD(_aVolta,_aDetArr) // Adiciona o volume para o coletor somente uma vez.
				EndIf
			EndIf
			ZZO->(DbSkip())
		EndDo
	Next
Return(_aVolta)


/*/{Protheus.doc} CDFimVol
//TODO Esta função é chamada pelo coletor quando solicita ao protheus dados para a montagem de volumes
Parâmetros
		cOperador   = Código do operador Operador;
		cNumOs		= Numero da Ordem de Separação;
		cSeqOs		= Numero da Sequencia da Ordem de separação
		aVolcab {
					Peso Tara;
					Peso Bruto;
					Tipo do Volume - (A)berto (F)echado (S)aco}
		aVolDet - Array contendo
				{
					{USR, ID , Tipo, Quantidade}
					{USR, ID , Tipo, Quantidade}
					{USR, ID , Tipo, Quantidade}
				}
				Atenção: Retornar o ID e o TIPO da mesma forma que foi.
Executar:
	Processar os volumes verificando se não houve:
			Excesso nas quantidades,
			Duplicidade nas bobinas
			Duplicidade nos Volumes
			% Pesos
Retorno:
	Se tudo estiver OK - Graver no ZZO -Volumes retornar o n.T.
	{.T., NUMERO DO VOLUME} ou {.F.,MOTIVO}
@author Roberto
@since 18/07/2017
@version undefined
@param cOperador, characters, descricao
@param cNumOs, characters, descricao
@param cSeqOs, characters, descricao
@param aVolCab, array, descricao
@param aVolDet, array, descricao
@type function
@Example Local oRet := Nil

cJsStr := '{"Ordem": "16342801","Header":{"TPVOL":"F","TARA":20.50,'
cJsStr += '            "PESOBRUTO":208.50'
cJsStr += '        },'
cJsStr += '   "Itens" : ['

cJsStr += '   {'
cJsStr += '      "ID": "96011524499",'
cJsStr += '     "USR":"01000049",'
cJsStr += '      "QTD": 1,'
cJsStr += '      "TP": "P"'
cJsStr += '    },'

cJsStr += '   {'
cJsStr += '      "ID": "91830160015",'
cJsStr += '     "USR":"01000049",'
cJsStr += '      "QTD": 24,'
cJsStr += '      "TP": "P"'
cJsStr += '    }'

cJsStr += '  ]'
cJsStr += '}'

FWJsonDeserialize(cJsStr, @oRet)
aVolCab := oRet:HEADER
aVolDet := oRet:ITENS

cOperador := "01000049"
cNumOs := "163428"
cSeqOs := "01"
/*/
User Function CDFimVol(cOperador,cNumOs,cSeqOs,aVolCab,aVolDet,cFil) // U_CDFimVol()
	Local _lTemErro:=.F., _cZZR_ID := " ", _aPedsID, _nPedsID
	
	// tara, peso bruto, volume aberto ou fechadoR
	/*/
		cOperador,cNumOs,cSeqOs,aVolCab,aVolDet)
		conout( 'COPERADOR --> ' 		+  cOperador)							//Caractere
		conout( 'CNUMOS --> ' 			+  cNumOs)								//Caractere
		conout( 'CSEQOS --> ' 			+  cSeqOs)								//Caractere
		conout( 'TPVOL --> ' 	+ 		aVolCab:TPVOL					) 		//Caractere
		conout( 'TARA  --> ' 	+ 		cValToChar(aVolCab:TARA)		)		//Numerico
		conout( 'PESOBRUTO --> ' + 		cValToChar(aVolCab:PESOBRUTO)	)		//Numerico
	
		conout('<--- AVOLDET ---> '  )
	
		//Como acessar os itens coletados
		For nX := 1 To Len(aVolDet)
			conout('        '  )
			conout('ID-----> ' 	+ 		aVolDet[nX]:ID ) 						//Caractere
					Atenção: Retornar o ID da mesma forma que foi.
			conout('TP-----> ' 	+ 		aVolDet[nX]:TP	)						//Caractere
					Atenção: Retornar o TIPO da mesma forma que foi.
			conout('QTD----> ' 	+		cValToChar(aVolDet[nX]:QTD) )  			//Numerico
	
		Next nX.
	/*/
	
	// Aglutina possíveis duplicidades
	_aColetas := {} // {ID, TP , Qtd Lances(Qtd.Coletada)}
	For nX := 1 To Len(aVolDet)
		_cId := PadR(aVolDet[nX]:ID,TamSX3("ZZR_BARINT")[1])
		nPos := aScan(_aColetas, {|x|x[1] == _cId .And. x[2]==aVolDet[nX]:TP})
		If nPos == 0
			Aadd(_aColetas,{_cId,aVolDet[nX]:TP,aVolDet[nX]:QTD})
		Else
			_aColetas[nPos,3] += aVolDet[nX]:QTD // Quantidade coletada (de lances ou de caixas)
		EndIf
	Next
	
	// Pego o ID dos volumes
	DbSelectArea("ZZR")
	DbSetOrder(2) // ZZR_FILIAL+ZZR_PEDIDO+ZZR_SEQOS+ZZR_ITEMPV+ZZR_SEQUEN
	DbSeek(xFilial("ZZR")+cNumOs+cSeqOs,.F.)
	_cZZR_ID := ZZR->ZZR_ID
	
	cQuery := "SELECT DISTINCT ZZR_PEDIDO, ZZR_SEQOS"
	cQuery += " FROM "+RetSqlName("ZZR") + " ZZR"
	cQuery += " WHERE ZZR_FILIAL = '"+xFilial("ZZR")+"'"
	cQuery += " AND ZZR_ID = '"+_cZZR_ID+"'"
	cQuery += " AND ZZR_SITUAC <> '9'"
	cQuery += " AND ZZR.D_E_L_E_T_ = ''"
	cQuery += " ORDER BY ZZR_PEDIDO, ZZR_SEQOS"
	_aPedsID := u_qryarr(cQuery) // Pedidos que estão nesse ID -> {ZZR_PEDIDO, ZZR_SEQOS}
	
	DbSelectArea("ZZO")
	DbSetOrder(1) // ZZO_FILIAL+ZZO_PEDIDO+ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN+ZZO_LOCALI
	
	DbSelectArea("ZZR") // Log das Liberações
	DbSetOrder(3) // ZZR_FILIAL+ZZR_BARINT+ZZR_PEDIDO+ZZR_SEQOS
	           
	_cTpVol := " " // Tipo do Volume
	
	_aZZR_ZZO := {} // { "ZZR ou ZZO", Recno ZZR, Quant.Lances, Quant.Metros} - Registros a serem gravados no ZZO
	For nX := 1 To Len(_aColetas) // {ID, TP, Quant}
		If _aColetas[nX,2] == "V" .And. _aColetas[nX,3] # 1 // Volume - Produto - Bobina - Coletado mais do que pede
			_lTemErro := .T.
			Exit
		ElseIf _aColetas[nX,2] # "V" // Volume - Produto - Bobina
			_cId := PadR(_aColetas[nX,1],TamSX3("ZZR_BARINT")[1])
			For _nPedsID := 1 to Len(_aPedsID)
				// _aPedsID -> Pedidos que estão nesse ID -> {ZZR_PEDIDO, ZZR_SEQOS}
				
				// ZZR->(DbSeek(xFilial("ZZR") + _cId + cNumOs + cSeqOs,.F.)) // Procuro no ZZR o ID,  que pode ter mais de 1
				DbSelectArea("ZZR") // Log das Liberações
				DbSetOrder(3) // ZZR_FILIAL+ZZR_BARINT+ZZR_PEDIDO+ZZR_SEQOS
				
				ZZR->(DbSeek(xFilial("ZZR") + _cId + _aPedsID[_nPedsID,1] + _aPedsID[_nPedsID,2],.F.)) // Procuro no ZZR o ID,  que pode ter mais de 1
				Do While ZZR->ZZR_FILIAL == xFilial("ZZR") .And. ZZR->ZZR_BARINT == _cId .And. ;
					ZZR->ZZR_PEDIDO == _aPedsID[_nPedsID,1] .And. ZZR->ZZR_SEQOS == _aPedsID[_nPedsID,2] .And. ZZR->(!Eof())
					// ZZR->ZZR_PEDIDO == cNumOs .And. ZZR->ZZR_SEQOS == cSeqOs .And. ZZR->(!Eof())
					_ZZO_LANCES := 0
					
					// Localizo no ZZO quanto já tenho em outros volumes
					DbSelectArea("ZZO")
					DbSetOrder(1) // ZZO_FILIAL+ZZO_PEDIDO+ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN+ZZO_LOCALI
					DbSeek(xFilial("ZZO")+ZZR->(ZZR_PEDIDO+ZZR_SEQOS+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_LOCALI),.F.)
					Do While ZZO->ZZO_FILIAL == xFilial("ZZO") .And. ZZO->(!Eof()) .And. ;
						ZZO->(ZZO_PEDIDO+ZZO_SEQOS+ZZO_ITEMPV+ZZO_SEQUEN+ZZO_LOCALI) == ;
						ZZR->(ZZR_PEDIDO+ZZR_SEQOS+ZZR_ITEMPV+ZZR_SEQUEN+ZZR_LOCALI)
						
						If Empty(ZZO->ZZO_VOLDES) .And. ZZO->ZZO_NUMBOB == ZZR->ZZR_NROBOB // Volume válido - Não incorporado a outro volume
							_ZZO_LANCES += ZZO->ZZO_LANCES // Quantos lances já estão neste volume
							
						EndIf
						ZZO->(DbSkip())
					EndDo
					
					
					_nSldLcs := (ZZR->ZZR_LANCES - _ZZO_LANCES) // Saldo de lances = (Qtd.Lances da OS - Quant.Lances já Unitizados)
					
					If _nSldLcs > 0
						// _nSldLcs := (_nSldLcs / ZZR->ZZR_QTCAIX) // Quantas Caixas - Se não for em caixas, ZZR->ZZR_QTCAIX será 1
						// A função SendVol manda sempre quantidade de lances, mesmo sendo blisters, então não posso dividir pela quantidade na caixa
						// If _nSldLcs >= _aColetas[nX,3] // {ID, TP, Quant} - Se Saldo a coletar <= Quantidade coletada
						// By Roberto Oliveira 25/10/16
						// Na verdade não importa se é maior ou menor ou igual..... tem que subtrair até que _aColetas[nX,3] chegue a 0
						// se não chegar ai tem erro
						_nQtdZZO := Min(_nSldLcs,_aColetas[nX,3])
						_aColetas[nX,3] -= _nQtdZZO // Subtraio pra depois ver outro ZZR
						
						// Se for caixa, a quantidade se refere a caixas * quant.de lances por caixa = quantidade de lances
						// Se não for caixa, ZZR->ZZR_QTCAIX é 1.
						_nQtdLanc := (_nQtdZZO * ZZR->ZZR_QTCAIX) // Quantidade de Lances
						If Empty(ZZR->ZZR_LOCALI)
							_nQtdMtrs := _nQtdLanc
						Else
							_nQtdMtrs := (_nQtdLanc * Val(Substr(ZZR->ZZR_LOCALI,2,5)))
						EndIf
						
						// Adiciono no _aZZR_ZZO um cara que tenho que gravar no ZZO - {"ZZR ou ZZO", Recno ZZR, Quant.Lances, Quant.Metros}
						// { 1-"ZZR ou ZZO", 2-Recno ZZR, 3-Quant.Lances, 4-Quant.Metros} - Registros a serem gravados no ZZO
						_aZZRx := { "ZZR",ZZR->(Recno()), _nQtdLanc, _nQtdMtrs}
						Aadd(_aZZR_ZZO,_aZZRx)
						
						// By Roberto Oliveira 25/10/16
						If _aColetas[nX,3] == 0 // Zerou a quantidade coletada
							Exit
						EndIf
						// Fim By Roberto Oliveira 25/10/16
						
						// EndIf
					EndIf
					ZZR->(DbSkip())
				EndDo
				If _aColetas[nX,3] == 0 // Zerou a quantidade coletada
					Exit
				EndIf
			Next
			If _aColetas[nX,3] > 0 // Coletado mais do que pede
				_lTemErro := .T.
				Exit
			EndIf
		Else // É Volume
			// Ver no ZZO se o volume está livre
			DbSelectArea("ZZO")
			DbSetOrder(4) // ZZO_FILIAL+ZZO_BARINT
			_cId := PadR(_aColetas[nX,1],TamSX3("ZZO_BARINT")[1])
			DbSeek(xFilial("ZZO")+_cId ,.F.) // Procuro no ZZO o ID,  que pode ter mais de 1
			Do While ZZO->ZZO_FILIAL == xFilial("ZZO") .And. ZZO->ZZO_BARINT == _cId .And. ZZO->(!Eof())
				If !Empty(ZZO->ZZO_VOLDES) // Não é um volume válido - Incorporado a outro volume
					_lTemErro := .T.
					Exit
				EndIf
				// { 1-"ZZR ou ZZO", 2-Recno ZZR ou ZZO, 3-Quant.Lances, 4-Quant.Metros} - Registros a serem gravados no ZZO
				_aZZRx := { "ZZO",ZZO->(Recno()), 0, 0}
				Aadd(_aZZR_ZZO,_aZZRx)
				ZZO->(DbSkip())
			EndDo
			If _lTemErro
				Exit
			EndIf
		EndIf
	Next
	
	If _lTemErro
		Return({.F.,"Quantidade a Maior"})
	EndIf
	
	// Pego o Número do próximo Volume
	DbSelectArea("ZZO")
	DbSetOrder(3) // ZZO_FILIAL+ZZO_NUMVOL
	_cPrxVol := GetSx8Num("ZZO","ZZO_NUMVOL",3) // GETSX8NUM( <CALIAS>, <CCAMPO>, <CALIASSXE>, <NORDEM> )
	Do While DbSeek(xFilial("ZZO")+_cPrxVol,.F.)
		ConfirmSX8()
		_cPrxVol := GetSx8Num("ZZO","ZZO_NUMVOL",3) // GETSX8NUM( <CALIAS>, <CCAMPO>, <CALIASSXE>, <NORDEM> )
	EndDo
	
	BeginTran()
	
	_cTpVol := aVolCab:TPVOL // Se não tenho volumes já formados, assumo o informado pelo usuário
	_cTpVol := Upper(_cTpVol)
	
	// Passou sem erros, então vamos gravar o _aZZR_ZZO := {} // { "ZZR ou ZZO", Recno ZZR, Quant.Lances, Quant.Metros} - Registros a serem gravados no ZZO
	_nZZO_PesTot := 0 // Peso padrão proporcional do volume
	For nX := 1 To Len(_aZZR_ZZO) // { "ZZR ou ZZO", Recno ZZR, Quant.Lances, Quant.Metros} - Registros a serem gravados no ZZO
		If _aZZR_ZZO[nX,1] == "ZZR"
			ZZR->(DbGoTo(_aZZR_ZZO[nX,2]))
			DbSelectArea("ZZO") // Volumes das cargas
			If !RecLock("ZZO",.T.)
				_lTemErro := .T.
				Exit
			EndIf
			ZZO->ZZO_FILIAL := xFilial("ZZO")
			ZZO->ZZO_NUMVOL := _cPrxVol
			ZZO->ZZO_ID     := ZZR->ZZR_ID
			ZZO->ZZO_OPER   := cOperador // Código do operador
			ZZO->ZZO_DATA   := dDataBase
			ZZO->ZZO_HORA   := TIME()
			ZZO->ZZO_PEDIDO := ZZR->ZZR_PEDIDO
			ZZO->ZZO_ITEMPV := ZZR->ZZR_ITEMPV
			ZZO->ZZO_SEQUEN := ZZR->ZZR_SEQUEN
			ZZO->ZZO_SEQOS  := ZZR->ZZR_SEQOS
			ZZO->ZZO_PRODUT := ZZR->ZZR_PRODUT
			ZZO->ZZO_DESCRI := ZZR->ZZR_DESCRI
			ZZO->ZZO_UM     := Posicione("SB1",1,xFilial("SB1")+ZZR->ZZR_PRODUT,"B1_UM")
			ZZO->ZZO_LOCAL  := ZZR->ZZR_LOCAL
			ZZO->ZZO_LOCALI := ZZR->ZZR_LOCALI
			ZZO->ZZO_NUMBOB := ZZR->ZZR_NROBOB

			ZZO->ZZO_QUANT  := _aZZR_ZZO[nX,4]
			ZZO->ZZO_LANCES := _aZZR_ZZO[nX,3]
			ZZO->ZZO_QTCAIX := ZZR->ZZR_QTCAIX // Quantidade de lances por caixa

			ZZO->ZZO_PASPAD := If(Left(ZZR->ZZR_LOCALI,1)=="B",ZZR->ZZR_PESPRO,(_aZZR_ZZO[nX,4] * Posicione("SB1",1,xFilial("SB1")+ZZR->ZZR_PRODUT,"B1_PESCOB+B1_PESPVC")))
			ZZO->ZZO_EMBALA := If(Left(ZZR->ZZR_LOCALI,1)=="B",ZZR->ZZR_EMBALA,((ZZR->ZZR_EMBALA / ZZO->ZZO_QUANT) * _aZZR_ZZO[nX,4]))

			ZZO->ZZO_PESLIQ := (ZZO->ZZO_PASPAD+ZZO->ZZO_EMBALA)
			// Peso líquido padrão com relação ao volume e
			// Peso Bruto padrão com relação ao próprio produto

			If Upper(_cTpVol)=="F" // Upper(aVolCab:TPVOL)=="F"  // Se o volume for fechado, o palete vai na carga
				ZZO->ZZO_PALETE := aVolCab:TARA //Tipo do Volume - (A)berto (F)echado - Se Fechado, o pallet vai na carga
				ZZO->ZZO_TARAVL := 0
				ZZO->ZZO_STATUS := "1" // 0=Não Conferido;1=Conferido;2=Carregado;3-Expedido
			ElseIf Upper(_cTpVol)=="S" // Upper(aVolCab:TPVOL)  // Se o volume for saco
				ZZO->ZZO_PALETE := 0 // aVolCab:TARA //Tipo do Volume - (A)berto (F)echado - Se Fechado, o pallet vai na carga
				ZZO->ZZO_TARAVL := 0
				ZZO->ZZO_STATUS := "1" // 0=Não Conferido;1=Conferido;2=Carregado;3-Expedido
			Else
				ZZO->ZZO_PALETE := 0
				ZZO->ZZO_TARAVL := aVolCab:TARA // Peso do Pallet - Para cálculo do % de desvio do palete
				ZZO->ZZO_STATUS := "0" // 0=Não Conferido;1=Conferido;2=Carregado;3-Expedido
			EndIf
	
			ZZO->ZZO_PESBRU := (aVolCab:PESOBRUTO - aVolCab:TARA) + ZZO->ZZO_PALETE
			// Peso Bruto que efetivamente vai na carga:
			// (Peso Bruto - Tara) + Peso Palete
			ZZO->ZZO_PESVOL := aVolCab:PESOBRUTO // Peso bruto do volume, independente se o palete vai ou não na carga
			
			// Se já está faturado, tem que ser a mesma nota fiscal.
			ZZO->ZZO_SERIE  := ZZR->ZZR_SERIE
			ZZO->ZZO_DOC    := ZZR->ZZR_DOC
			ZZO->ZZO_ITEM   := ZZR->ZZR_ITEM
			
			ZZO->ZZO_BARINT := "9" + StrZero(Val(ZZO->ZZO_NUMVOL),10)
			// O cód. de barras do tipo UPCA tem que ter 11 dígitos e não pode iniciar com zero. É o próprio número do volume.
			ZZO->ZZO_RATPES := 0 // Peso deste item do volume com o rateio do pallete
			ZZO->ZZO_TIPO   := Upper(_cTpVol) // aVolCab:TPVOL   //Aberto / Fechado / Saco 
			MsUnLock()
		ElseIf _aZZR_ZZO[nX,1] == "ZZO"
			ZZO->(DbGoTo(_aZZR_ZZO[nX,2]))
			RegToMemory("ZZO",.F.)
			If !RecLock("ZZO",.F.)
				_lTemErro := .T.
				Exit
			EndIf
			ZZO->ZZO_VOLDES := _cPrxVol // Grava pra qual volume foi incorporado
			MsUnLock()
	
			M->ZZO_NUMVOL := _cPrxVol
			M->ZZO_OPER   := cOperador // Código do operador
			M->ZZO_DATA   := dDataBase
			M->ZZO_HORA   := TIME()
			M->ZZO_VOLDES := PadR(" ",TamSX3("ZZO_VOLDES")[1])
			//
			M->ZZO_PASPAD := M->ZZO_RATPES // Peso proporcional do pallete
			M->ZZO_PESLIQ := M->ZZO_RATPES // Peso proporcional do pallete
			//	obs.: M->ZZO_PASPAD e M->ZZO_PESLIQ  -> Passam a ser o peso bruto rateado do volume anterior
			M->ZZO_EMBALA := 0
			M->ZZO_RATPES := 0
			//
			If Upper(_cTpVol)=="F" // Upper(aVolcab:TpVol)=="F" // Se o volume for fechado, o palete vai na carga
				M->ZZO_PALETE := aVolcab:Tara //Tipo do Volume - (A)berto (F)echado - Se Fechado, o pallet vai na carga
				M->ZZO_TARAVL := 0
				M->ZZO_STATUS := "1" // 0=Não Conferido;1=Conferido;2=Carregado;3-Expedido
			Else
				M->ZZO_PALETE := 0
				M->ZZO_TARAVL := aVolcab:Tara  // Peso do Pallet - Para cálculo do % de desvio do palete
				M->ZZO_STATUS := "0" // 0=Não Conferido;1=Conferido;2=Carregado;3-Expedido
			EndIf
	
			M->ZZO_PESBRU := (aVolcab:PesoBruto - aVolcab:Tara) + M->ZZO_PALETE
			// Peso Bruto que efetivamente vai na carga:
			// (Peso Bruto - Tara) + Peso Palete
			M->ZZO_PESVOL := aVolcab:PesoBruto // Peso bruto do volume, independente se o palete vai ou não na carga
			M->ZZO_BARINT := "9" + StrZero(Val(M->ZZO_NUMVOL),10)
			// O cód. de barras do tipo UPCA tem que ter 11 dígitos e não pode iniciar com zero. É o próprio número do volume.
			M->ZZO_TIPO   := Upper(_cTpVol) //aVolcab:TpVol   //Aberto / Fechado / Saco 
	
			_nQtCpo := ZZO->(FCount())
			If !RecLock("ZZO",.T.)
				_lTemErro := .T.
				Exit
			EndIf
			
			// Grava os dados da memória para a tabela M-> para ZZO->
			For nCntFor := 1 To _nQtCpo
				FieldPut(nCntFor,M->&(FieldName(nCntFor)))
			Next
			ZZO->ZZO_RATPES := 0 // Peso deste item do volume com o rateio do pallete
			MsUnLock()
		EndIf
		_nZZO_PesTot += ZZO->ZZO_PESLIQ // Peso padrão total do volume
	Next
	
	_IndBase := If(Upper(_cTpVol)=="F",aVolcab:PesoBruto,(aVolcab:PesoBruto - aVolcab:Tara)) // Upper(aVolcab:TpVol)
			// Se o volume for fechado, o palete vai na carga
	_IndBase := Round((_IndBase / _nZZO_PesTot),5)
	
	DbSelectArea("ZZO")
	DbSetOrder(3) // ZZO_FILIAL+ZZO_NUMVOL
	DbSeek(xFilial("ZZO")+_cPrxVol,.F.)
	Do While ZZO->ZZO_FILIAL == xFilial("ZZO") .And. ZZO->ZZO_NUMVOL == _cPrxVol .And. ZZO->(!Eof()) .And. !_lTemErro
		_nPesRat := Round((_IndBase * ZZO->ZZO_PESLIQ),2)
		RecLock("ZZO",.F.)
		ZZO->ZZO_RATPES := _nPesRat // Peso deste item do volume com o rateio do pallete
		MsUnLock()
		ZZO->(DbSkip())
	EndDo
	If _lTemErro
		DisarmTransaction()
		RollBackSx8()
		_aVolta := {.F.,"Erro na Gravação"}
	Else
		EndTran()
		ConfirmSx8()
		_aVolta := {.T.,_cPrxVol}
	EndIf
	
	If !_lTemErro 
		oPrint := cbcPrintFromApi():newcbcPrintFromApi()
		// oPrint:defFunction('u_CDRltVol'):addParams({cOperador,_cPrxVol, FwFilial()})
		oPrint:defFunction('u_CDRltVol'):addParams({cOperador,_cPrxVol,cFil})
		oPrint:execFunc()
		FreeObj(oPrint)
	EndIf
Return(_aVolta)


/*/{Protheus.doc} CDFimOS
//TODO Esta função é chamada pelo coletor que informa que a OS foi finalizada, ou seja, todos os itens da OS foram montados volumes
Parâmetros 	cNumOs - Número da Ordem de Separação
			cSeqOs - Sequência da Ordem de Separação
Executar:
	Validar se todos os produtos/(bobinas ??) estão em um volume

Retornar Array(

	(.T., Finalizado com sucesso}
	ou
	{.F.,Itens com saldo}
	).
@author Roberto
@since 18/07/2017
@version undefined
@param cOperador, characters, descricao
@param cNumOs, characters, descricao
@param cSeqOs, characters, descricao
@type function
/*/
User Function CDFimOS(cOperador,cNumOs, cSeqOs)              
	Local _aVolta := {}
	Private cOperador,cNumOs, cSeqOs
	
	_aRetVol := u_CDSendVol(cOperador,cNumOs, cSeqOs)
	/* A função CDSendVol retorna array conforma abaixo:
		{	{Tipo, ID , Quantidade}
			{Tipo, ID , Quantidade}
			{Tipo, ID , Quantidade} }
		sendo que o tipo pode ser B, P ou V (Bobina, Produto, Volume)
		Se nesse array tiver algum diferente de B não completou os volumes
	*/		
	If Len(_aRetVol) == 0
		_aDetArr := {.F.,"O.S. Nao Existe"}
		AADD(_aVolta,_aDetArr)
	Else
		// Varre o array e verifica se tem itens diferentes de V
		_nQtPrd := 0
		_nQtBob := 0
		_nQtOut := 0
		For _nPos := 1 to Len(_aRetVol)
			If _aRetVol[_nPos,1] == "P"
				_nQtPrd++
			ElseIf _aRetVol[_nPos,1] == "B"
				_nQtBob++
			ElseIf _aRetVol[_nPos,1] # "V" // Nem P, nem B, nem V
				_nQtOut++
			EndIf
		Next          
		_TxtRet := ""
		If _nQtPrd > 0
			_TxtRet := AllTrim(Str(_nQtPrd)) + " Produtos" + If(_nQtBob > 0," + ","")
		EndIf
		If _nQtBob > 0
			_TxtRet +=  AllTrim(Str(_nQtBob)) + " Bobinas"
		EndIf
		If !Empty(_TxtRet)
			_aDetArr := {.F.,"Nao Coletados: " + _TxtRet}
		ElseIf _nQtOut > 0
			_aDetArr := {.F.,"O.S. Nao Finalizada"}
		Else
			_aDetArr := {.T.,"Finalizado com Sucesso"}
		EndIf
		AADD(_aVolta,_aDetArr)
	EndIf
Return(_aVolta)


/*/{Protheus.doc} CDDelVol
//TODO Esta função é chamada pelo coletor quando solicita ao protheus dados para a montagem de volumes
Parâmetros 	cBarInt - Código de barras do volume

 Executar:
	Validar:
		- O Volume pode ser excluído? (Na carga, Carregado, Faturado, Entregue)
		- Consegui excluir?

Retornar Array(
	({.T., Excluido com sucesso}
	ou
	{.F., Motivo}).
@author Roberto
@since 18/07/2017
@version undefined
@param cOperador, characters, descricao
@param cBarInt, characters, descricao
@type function
/*/
User Function CDDelVol(cOperador,cBarInt) // U_CDDelVol("000049","90000000013")
	If Empty(cBarInt) .Or. Left(cBarInt,1) # "9" .Or. Len(cBarInt) # 11
		Return({.F.,"Erro na Exclusão"})
	EndIf
	
	cNumVol := Right(cBarInt,Len(ZZO->ZZO_NUMVOL))
	 
	cQuery := "SELECT ZZO.R_E_C_N_O_ AS REGIS, ISNULL(F2_SERIE,' ') SERIE, ISNULL(F2_DOC,' ') DOC, ZZO_PEDIDO, ZZO_SEQOS "
	cQuery += " FROM "+RetSqlName("ZZO") + " ZZO"
	cQuery += " LEFT JOIN "+RetSqlName("SF2") + " F2"
	cQuery += " ON ZZO_FILIAL = F2_FILIAL"
	cQuery += " AND ZZO_SERIE = F2_SERIE"
	cQuery += " AND ZZO_DOC = F2_DOC"
	cQuery += " AND ZZO.D_E_L_E_T_ = F2.D_E_L_E_T_"
	cQuery += " WHERE ZZO_FILIAL  = '"+xFilial("ZZO")+"'"
	cQuery += "	AND (ZZO_NUMVOL = '"+cNumVol+"' OR  ZZO_VOLDES = '"+cNumVol+"')"
	cQuery += "	AND ZZO.D_E_L_E_T_ = ''"
	_aDadZZO := u_QryArr(cQuery) // Executa a Query, joga os dados num array e fecha o arquivo temporário da Query.
	
	If Len(_aDadZZO) == 0
		Return({.F.,"Volume não Existe"})
	EndIf
	
	_cMySemaf := ""
	_lTemErro := .F.
	_cMotErro := ""
	BeginTran()
	DbSelectArea("ZZO")
	For _nCtdZZO := 1 To Len(_aDadZZO)
		// Não importa a ordem de tratamento dos dados, se vai primeiro limpar o campo VOLDES e depois verificar se pode ou nao, pois
		// se não puder, com o retorno .F. ele dá um DisarmTransAction e desfaz tudo.
		ZZO->(DbGoTo(_aDadZZO[_nCtdZZO,1]))
		If ZZO->ZZO_NUMVOL == cNumVol
			If !Empty(ZZO->ZZO_VOLDES) // Este Volume foi adicionado a outro volume
				_lTemErro := .T.
				_cMotErro := "Volume não Disponível"
				Exit
			ElseIf ZZO->ZZO_STATUS == "2" .Or. ZZO->ZZO_SITCAR == "4" // 0=Nao Conferido;1=Conferido (2-Carregado;3-Expedido) - SITCAR->1=NÃO MONTADA; 2=MONTADA;3=A CARREGAR;4-CARREGADO;5-EXPEDIDO
				_lTemErro := .T.
				_cMotErro := "Volume Já Carregado"
				Exit
			ElseIf ZZO->ZZO_STATUS == "3" .Or. ZZO->ZZO_SITCAR == "5" // 0=Nao Conferido;1=Conferido (2-Carregado;3-Expedido) - SITCAR->1=NÃO MONTADA; 2=MONTADA;3=A CARREGAR;4-CARREGADO;5-EXPEDIDO
				_lTemErro := .T.
				_cMotErro := "Volume Já Expedido"
				Exit
			ElseIf ZZO->ZZO_SITCAR == "2"// 0=Nao Conferido;1=Conferido (2-Carregado;3-Expedido) - SITCAR->1=NÃO MONTADA; 2=MONTADA;3=A CARREGAR;4-CARREGADO;5-EXPEDIDO
				_lTemErro := .T.
				_cMotErro := "Volume em Carregamento"
				Exit
			ElseIf !Empty(ZZO->ZZO_CARGA) //.Or. ZZO->ZZO_SITCAR # "1" // 0=Nao Conferido;1=Conferido (2-Carregado;3-Expedido) - SITCAR->1=NÃO MONTADA; 2=MONTADA;3=A CARREGAR;4-CARREGADO;5-EXPEDIDO
				_lTemErro := .T.
				_cMotErro := "Volume Já Informado em Uma Carga"
				Exit
			Else 
				RecLock("ZZO",.F.)
				ZZO->(DbDelete())
				MsUnLock()
			EndIf
		ElseIf ZZO->ZZO_VOLDES == cNumVol
			RecLock("ZZO",.F.)
			ZZO->ZZO_VOLDES := "      "
			MsUnLock()
		EndIf
	Next
	If _lTemErro
		DisarmTransaction()
		_aVolta := {.F.,_cMotErro}
	Else
		EndTran()
		_aVolta := {.T.,"Excluído com Sucesso"}
	EndIf
Return(_aVolta)


/*/{Protheus.doc} ChAmCol
//TODO Descrição auto-gerada.
@author jRoberto
@since 18/07/2017
@version undefined

@type function
/*/
User Function ChAmCol() // U_ChAmCol()      
	oPrint := cbcPrintFromApi():newcbcPrintFromApi()
	oPrint:defFunction('u_CDRltVol'):addParams({"135","004900","01"})
	oPrint:execFunc()
	FreeObj(oPrint)
Return(.T.)


/*/{Protheus.doc} CDRltVol
//TODO 	Esta função é chamada pelo coletor quando solicita ao protheus dados para a montagem de volumes
		Atenção: Conforme discutido em reunião, Ivo, Jeferson, Claudemir e Roberto, este relatório somente será emitido se for FECHADO
		se for aberto ou saco, será emitido somente uma etiqueta..
@author Roberto
@since 18/07/2017
@version undefined
@param aInfo, array, descricao
@param cOper, characters, descricao
@param cNumVol, characters, descricao
@type function
/*/
User Function CDRltVol(aInfo,cOper,cNumVol)   // u_CDRltVol("","135","004900")
	// cBarInt = Código de barras do volume C 11
	Local aMod:={}
	Local nQuant := 1
	Local oFont3 := TFont():New( "Arial",,30,,.T.,,,,.T.,.F.) // oFont3 := TFont():New( "Arial",,18,,.T.,,,,.T.,.F.)
	Local oFont4 := TFont():New( "Arial",,15,,.T.,,,,   ,.F.) 
	Local oFont5 := TFont():New( "Arial",,12,,.T.,,,,   ,.F.) 
	Local oFont7 := TFont():New( "Arial",,10,,.T.,,,,   ,.F.) 
	Private cOper,cNumVol
	Private cFil  := ""
	Default aInfo := {}
	Default cOper := " "
	Default cNumVol := " "
	//Conout("01 - Inicio do Processo")
	If !Empty(aInfo)
		aMod 	:= StrTokArr(aInfo, ',')
		cOper 	:= aMod[1]
		cNumVol	:= aMod[2]
		cFil	:= aMod[3]
		PREPARE ENVIRONMENT EMPRESA '01' FILIAL aMod[3] USER aMod[4] PASSWORD aMod[5]  MODULO aMod[6]
	EndIf                    
	cQuery := "SELECT   ZZO_OPER, ZZO_DATA, ZZO_HORA, ZZO_PESBRU-ZZO_PALETE-ZZO_TARAVL AS PESLIQ, ZZO_PESBRU, ZZO_PEDIDO,ZZO_BARINT,"
	cQuery += " ZZO_ITEMPV, ZZO_PRODUT, ZZO_DESCRI, ZZO_LANCES, ZZO_LOCAL, ZZO_LOCALI, BE_DESCRIC, ZZO_NUMBOB, ZZO_ID, ZZO_SEQOS, ZZO_TIPO"
	cQuery += " FROM "+RetSqlName("ZZO") + " ZZO"
	cQuery += " LEFT JOIN "+RetSqlName("SBE") + " BE"
	cQuery += " ON '"+xFilial("SBE")+"' = BE_FILIAL"
	cQuery += " AND ZZO_LOCAL = BE_LOCAL"
	cQuery += " AND ZZO_LOCALI = BE_LOCALIZ"
	cQuery += " AND ZZO.D_E_L_E_T_ = BE.D_E_L_E_T_
	cQuery += " WHERE ZZO_FILIAL  = '"+xFilial("ZZO")+"'"
	cQuery += " AND ZZO_NUMVOL = '"+cNumVol+"'"
	cQuery += " AND ZZO.D_E_L_E_T_ = ''"
	cQuery += " ORDER BY ZZO_PRODUT, ZZO_LOCALI, ZZO_PEDIDO, ZZO_ITEMPV, ZZO_SEQOS"
	_aDadZZO := u_QryArr(cQuery) // Executa a Query, joga os dados num array e fecha o arquivo temporário da Query.
	
	/*/
	 _aDadZZO -> {01-ZZO_OPER  , 02-ZZO_DATA  , 03-ZZO_HORA  , 04-(ZZO_PESBRU-ZZO_PALETE-ZZO_TARAVL AS PESLIQ) , 05-ZZO_PESBRU, 
	              06-ZZO_PEDIDO, 07-ZZO_BARINT, 08-ZZO_ITEMPV, 09-ZZO_PRODUT                                   , 10-ZZO_DESCRI,
	              11-ZZO_LANCES, 12-ZZO_LOCAL , 13-ZZO_LOCALI, 14-BE_DESCRIC                                   , 15-ZZO_NUMBOB, 
	              16-ZZO_ID    , 17-ZZO_SEQOS , 18-ZZO_TIPO
	/*/
	                         
	If Len(_aDadZZO) == 0
		Return(.F.)
	EndIf
	
	// Posiciona cliente
	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek(xFilial("SC5")+_aDadZZO[01,06],.F.)
	
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial("SA1")+ SC5->C5_CLIENTE + SC5->C5_LOJACLI,.F.)
	
	_nQtPag := (Len(_aDadZZO) / 40)
	If _nQtPag > Int(_nQtPag)
		_nQtPag := Int(_nQtPag) + 1
	Else
		_nQtPag := Int(_nQtPag)
	EndIf
	_nPagAtu := 0
	_cResp := ""
	lLeg := .T.
	nLin1    := 155
	
	lAdjustToLegacy := .F.
	lDisableSetup := .T.
	
	If _aDadZZO[1,18] == "S" // 18-ZZO_TIPO - Volume Saco - Mandat para  Zebra
		_cIDVol 	:= _aDadZZO[01,16]
		_Ddtt    	:= Dtoc(Stod(_aDadZZO[01,02]))
		_cHra    	:= _aDadZZO[01,03]
		_cPesBrt 	:= Transform(_aDadZZO[1,05], "@E 99,999.99")
		_cCliEt1 	:= ''
		_cCliEt2 	:= AllTrim(SA1->A1_NOME)
		_cCdBar 	:= Left(_aDadZZO[01,07],11) // Tem que ter 11 dígitos para imprimir o tipo UPCA
		_cResp 		:= Upper(AllTrim(_aDadZZO[01,01]) + " - " + AllTrim(Posicione("SZS",1,xFilial("SZS")+_aDadZZO[01,01],"ZS_NOME")))
		
		If Len(_cCliEt2) > 50
			_cCliEt1 := Left(_cCliEt2,40)
			_cCliEt2 := AllTrim(Substr(_cCliEt2,41,100))
		EndIf    
		_cPed1 := ""
		_cPed2 := ""
		For _nPeds := 1 to Len(_aDadZZO)
			If !_aDadZZO[_nPeds,06] $ _cPed2
				_cPed2 := _cPed2 + _aDadZZO[_nPeds,06] + ", "
			EndIf
		Next
		_cPed2 := Left(_cPed2,Len(_cPed2)-2)
		If Len(_cPed2) > 62
			_cPed1 := Left(_cPed2,47)
			_cPed2 := AllTrim(Substr(_cPed2,49,100))
			If Len(_cPed2) > 62
				_cPed2 := Left(_cPed2,62) + ",+"
			EndIf
		EndIf
		_cPed2 := _cPed2 +  "."

		u_ImpZbraOld(cNumVol)
	Else // Manda para a Laser
		If xFilial("ZZO") == '02' .OR. cFil == "02"
			cImpr	:= "Sacaria-tl" // Impressora Zebra
			nQuant  := 2
		Else
			cImpr	:= "Impressora Sacaria" // Impressora Zebra
			nQuant  := 1
		EndIf
		cPorta	:= ""
		PreparePrint(.T.,cImpr, .F.,cPorta)
		InitPrint(2,"VOLUMES","080",,"VOLUMES")
		// Private oPrn := FWMSPrinter():New("volume.rel",IMP_SPOOL,lAdjustToLegacy,"\spool\",lDisableSetup,,,"Impressora Sacaria",.T. ,,,,1 )
		Private oPrn := FWMSPrinter():New("volume.rel",IMP_SPOOL,lAdjustToLegacy,"\spool\",lDisableSetup,,,cImpr,.T. ,,,,nQuant)
		oPrn:SetPortrait() // Formato pagina Retrato
		
		If _aDadZZO[1,18] == "F" // 18-ZZO_TIPO - Volume Fechado
	
			_cPed2 := ""
			For _nElem := 1 To Len(_aDadZZO)
				If 	Empty(_cResp)
					_cResp := Upper(AllTrim(_aDadZZO[_nElem,01]) + " - " + AllTrim(Posicione("SZS",1,xFilial("SZS")+_aDadZZO[_nElem,01],"ZS_NOME")))
				EndIf
				
				If _aDadZZO[_nElem,06] $ _cPed2
					_cPed2 := _cPed2 + _aDadZZO[_nElem,06] + ", "
				EndIf
	
				_nPagCalc := (_nElem / 40)
				If Int(_nPagCalc) # _nPagCalc
					_nPagCalc := Int(_nPagCalc) + 1
				EndIf
				If _nPagCalc # _nPagAtu
					If _nPagAtu > 0
						oPrn:Say(nLin1+20,0110,"RESPONSAVEL PELA MONTAGEM : " + _cResp,oFont7)				// Quantidade
						oPrn:EndPage() // Encerra a página atual
					EndIf
					oPrn:StartPage() //inicializa nova pagina
					_nPagAtu := _nPagCalc
					nLin1    := 155
			
					// Montagem do Formulário
					// 01-ZZO_OPER  , 02-ZZO_DATA  , 03-ZZO_HORA  , 04-(ZZO_PESBRU-ZZO_PALETE-ZZO_TARAVL AS PESLIQ) , 05-ZZO_PESBRU, 
					// 06-ZZO_PEDIDO, 07-ZZO_BARINT, 08-ZZO_ITEMPV, 09-ZZO_PRODUT                                   , 10-ZZO_DESCRI,
					// 11-ZZO_LANCES, 12-ZZO_LOCAL , 13-ZZO_LOCALI, 14-BE_DESCRIC                                   , 15-ZZO_NUMBOB, 
					// 16-ZZO_ID    , 17-ZZO_SEQOS
					
					// CABEÇALHO AJUSTADO PELO FWMSPRINTER
					oPrn:Box (0020,0020,0090,0570) // Box 1 Cabeçalho
					oPrn:Line(0055,0140,0055,0570) // Linha horizontal que divide o cabeçalho em dois
					
					oPrn:Line(0020,0140,0090,0140) // Linha vertical que fecha o retangulo do cód. de barras
			
					oPrn:Line(0055,0226,0090,0226) // Linha vertical que fecha o retangulo da data
					oPrn:Line(0055,0312,0090,0312) // Linha vertical que fecha o retangulo da hora
					oPrn:Line(0055,0398,0090,0398) // Linha vertical que fecha o retangulo do ID  
					oPrn:Line(0020,0484,0090,0484) // Linha vertical que fecha os retangulos da página e do peso bruto
			
			
					oPrn:Say(0050,0180,"VOLUME Nº  " + cNumVol,oFont3) // oPrn:Say(0040,0707,"VOLUME Nº  " + cNumVol,oFont3)
			
					oPrn:Say(0030,0489,"Página:"      ,oFont5)
					oPrn:Say(0065,0145,"Data:"        ,oFont5)
					oPrn:Say(0065,0231,"Hora:"        ,oFont5)
					oPrn:Say(0065,0317,"I.D.:"        ,oFont5)
					oPrn:Say(0065,0403,"Peso Liquido:",oFont5)
					oPrn:Say(0065,0489,"Peso Bruto:"  ,oFont5)
			
					oPrn:Say(0040,0530,StrZero(_nPagAtu,2) + "/" + StrZero(_nQtPag,2)  ,oFont4)      // Página
					_Ddtt := Stod(_aDadZZO[_nElem,02])
					oPrn:Say(0080,0161,Dtoc(Stod(_aDadZZO[_nElem,02])),oFont4) // Data do volume
					oPrn:Say(0080,0264,_aDadZZO[_nElem,03]      ,oFont4) // Hora
					oPrn:Say(0080,0347,_aDadZZO[_nElem,16]      ,oFont4) // I.D.
					oPrn:Say(0080,0430,Transform(_aDadZZO[_nElem,04], "@E 99,999.99")  ,oFont4) // Peso Liquido
					oPrn:Say(0080,0520,Transform(_aDadZZO[_nElem,05], "@E 99,999.99")  ,oFont4) // Peso Bruto
			
					oPrn:Say(0105,0035,"Cliente:"     ,oFont7) //oPrn:Say(0310,0552,"Cliente:"     ,oFont7)
					oPrn:Say(0120,0035,AllTrim(SA1->A1_NOME),oFont4) //oPrn:Say(0346,0132,"SELIME DISTRIBUIDORA DE EQUIPAMENTOS ELETRICOS LTD",oFont4)
					
					oPrn:Box (0130,0020,0155,0570)  // Box dos titulos e dos dados
					oPrn:Line(0130,0080,0155,0080) // Coluna da descrição
					oPrn:Line(0130,0365,0155,0365) // Coluna da quantidade
					oPrn:Line(0130,0410,0155,0410) // Coluna do acondicionamento
					// Titulos das colunas
					oPrn:Say(0145,0022,"PEDIDO-SQ-IT",oFont7)
					oPrn:Say(0145,0090,"DESCRIÇÃO",oFont7)
					oPrn:Say(0145,0375,"QUANT.",oFont7)
					oPrn:Say(0145,0420,"ACONDICIONAMENTO",oFont7)
					
					
					If _nPagAtu == 1
						_cCdBar := Left(_aDadZZO[_nElem,07],11) // Tem que ter 11 dígitos para imprimir o tipo UPCA
						nCoBr   := 3
						nLiBr   := 3
						_nTam   := 0.025
						_nAlt   := 1.0
						_lPrin  := .F.   //±±³          ³ 14 lPrint	Logico que indica se imprime ou nao            ³±±
			
						oPrn:FWMSBAR("UPCA",nLiBr,nCoBr,_cCdBar,oPrn,.F.,Nil,.T.,_nTam,_nAlt,NIL,NIL,NIL,.F.) //_lPrin)
					EndIf
				EndIf
			
				oPrn:Line(nLin1,0020,nLin1+15,0020)	// Coluna do pedido 	oPrn:Line(nLin1,0100,nLin1+15,0100
				oPrn:Line(nLin1,0080,nLin1+15,0080) // Coluna da descrição 	oPrn:Line(nLin1,0308,nLin1+15,0308
				oPrn:Line(nLin1,0365,nLin1+15,0365) // Coluna da quantidade	oPrn:Line(nLin1,1454,nLin1+15,1454
				oPrn:Line(nLin1,0410,nLin1+15,0410) // Coluna do acondic.	oPrn:Line(nLin1,1632,nLin1+15,1632
				oPrn:Line(nLin1,0570,nLin1+15,0570) // Coluna final 		oPrn:Line(nLin1,2320,nLin1+15,2320
			
				// Montagem do Formulário
				// 01-ZZO_OPER  , 02-ZZO_DATA  , 03-ZZO_HORA  , 04-(ZZO_PESBRU-ZZO_PALETE-ZZO_TARAVL AS PESLIQ) , 05-ZZO_PESBRU, 
				// 06-ZZO_PEDIDO, 07-ZZO_BARINT, 08-ZZO_ITEMPV, 09-ZZO_PRODUT                                   , 10-ZZO_DESCRI,
				// 11-ZZO_LANCES, 12-ZZO_LOCAL , 13-ZZO_LOCALI, 14-BE_DESCRIC                                   , 15-ZZO_NUMBOB, 
				// 16-ZZO_ID    , 17-ZZO_SEQOS
			
				oPrn:Say(nLin1+10,0025,_aDadZZO[_nElem,06]+"-"+_aDadZZO[_nElem,17]+"-"+_aDadZZO[_nElem,08],oFont7)  	// Pedido/Seq.O.S./Item do pedido
				oPrn:Say(nLin1+10,0085,_aDadZZO[_nElem,10],oFont7)								// Descrição do Produto
				oPrn:Say(nLin1+10,0370,Transform(_aDadZZO[_nElem,11], "@E 9,999,999"),oFont7)	// Quantidade
				
				_aDadZZO[_nElem,14] := Upper(AllTrim(_aDadZZO[_nElem,14]))
				_aDadZZO[_nElem,14] := StrTran(_aDadZZO[_nElem,14],"CARRETEL","CARR.")
				_aDadZZO[_nElem,14] := StrTran(_aDadZZO[_nElem,14],"MADEIRA","MAD.")
				_aDadZZO[_nElem,14] := StrTran(_aDadZZO[_nElem,14],"BOBINA","BOB.")
				_aDadZZO[_nElem,14] := StrTran(_aDadZZO[_nElem,14],"ROLOS","ROLO")
				_aDadZZO[_nElem,14] := StrTran(_aDadZZO[_nElem,14],"METROS","M.")
				_aDadZZO[_nElem,14] := StrTran(_aDadZZO[_nElem,14],"METRO","M.")
			
				If !Empty(_aDadZZO[_nElem,15]) // É bobina
					oPrn:Say(nLin1+10,0415,AllTrim(Upper(_aDadZZO[_nElem,14])) + " nº " + _aDadZZO[_nElem,15],oFont7)	// Descrição do acondicionamento + nro da bobina
				Else
					oPrn:Say(nLin1+10,0415,Upper(_aDadZZO[_nElem,14]),oFont7)					// Descrição do acondicionamento
				EndIf
				oPrn:Line(nLin1+15,0020,nLin1+15,0570) // Linha da Grid
				nLin1 += 15 // ERA 60
			Next
			
		ElseIf _aDadZZO[1,18] == "A" // 18-ZZO_TIPO - Volume Fechado
			// Cria string com nros dos pedidos do volume
			_nElem := 1
			_cPedsVol := _aDadZZO[_nElem,06]+"-"+_aDadZZO[_nElem,17]
			For _nElem := 2 To Len(_aDadZZO)
				_cPedAtu := _aDadZZO[_nElem,06]+"-"+_aDadZZO[_nElem,17]
				If !_cPedAtu $ _cPedsVol
					_cPedsVol += ", " + _cPedAtu
				EndIf
			Next
			_cPedsVol += "."
		
			_nElem := 1
		
			If 	Empty(_cResp)
				_cResp := Upper(AllTrim(_aDadZZO[_nElem,01]) + " - " + AllTrim(Posicione("SZS",1,xFilial("SZS")+_aDadZZO[_nElem,01],"ZS_NOME")))
			EndIf
		
			oPrn:StartPage() //inicializa nova pagina
			_nPagAtu := 1
		
			
			oPrn:Say(0440,0530,StrZero(_nPagAtu,2) ,oFont4)      // Página
			_Ddtt := Stod(_aDadZZO[_nElem,02])
			oPrn:Say(0480,0161,Dtoc(Stod(_aDadZZO[_nElem,02])),oFont4) // Data do volume
			oPrn:Say(0480,0264,_aDadZZO[_nElem,03]      ,oFont4) // Hora
			oPrn:Say(0480,0347,_aDadZZO[_nElem,16]      ,oFont4) // I.D.
			//oPrn:Say(0480,0430,Transform(_aDadZZO[_nElem,04], "@E 99,999.99")  ,oFont4) // Peso Liquido - No caso de aberto imprime o mesmo peso do peso bruto
			oPrn:Say(0480,0430,Transform(_aDadZZO[_nElem,05], "@E 99,999.99")  ,oFont4) // Peso Liquido - No caso de aberto imprime o mesmo peso do peso bruto
			oPrn:Say(0480,0520,Transform(_aDadZZO[_nElem,05], "@E 99,999.99")  ,oFont4) // Peso Bruto
		
			oPrn:Box (0490,0020,0530,0570) // Box do Cliente
			oPrn:Say(0505,0035,"Cliente:"     ,oFont7) //oPrn:Say(0310,0552,"Cliente:"     ,oFont7)
			oPrn:Say(0520,0035,AllTrim(SA1->A1_NOME),oFont4) //oPrn:Say(0346,0132,"SELIME DISTRIBUIDORA DE EQUIPAMENTOS ELETRICOS LTD",oFont4)
			
			oPrn:Box (0530,0020,0570,0570) // Box do nro dos pedidos
			If Len(_cPedsVol) > 10 // Tem + de um pedido
				oPrn:Say(0545,0035,"Pedidos:"     ,oFont7)
			Else
				oPrn:Say(0545,0035,"Pedido:"     ,oFont7)
			EndIf
			oPrn:Say(0560,0035,_cPedsVol,oFont4)
					
			_cCdBar := Left(_aDadZZO[_nElem,07],11) // Tem que ter 11 dígitos para imprimir o tipo UPCA
			nCoBr   := 3
			nLiBr   := 37
			_nTam   := 0.025
			_nAlt   := 1.0
			_lPrin  := .F.   //±±³          ³ 14 lPrint	Logico que indica se imprime ou nao            ³±±
		
			oPrn:FWMSBAR("UPCA",nLiBr,nCoBr,_cCdBar,oPrn,.F.,Nil,.T.,_nTam,_nAlt,NIL,NIL,NIL,.F.) //_lPrin)
		
			nLin1    := 575
		EndIf
		oPrn:Say(nLin1+20,0030,"RESPONSAVEL PELA MONTAGEM : " + _cResp,oFont7)				// Quantidade
		oPrn:EndPage() // Encerra a página atual
		//oPrn:End() // Encerra o relatório
		_lPrepImp := .F.
		If _lPrepImp
			oPrn:SetUp()
		Else
			oPrn:Print()
		EndIf
		
		If _aDadZZO[1,18] == "F" // 18-ZZO_TIPO - Volume Fechado Imprimir etiqueta
			_cIDVol := _aDadZZO[01,16]
			_Ddtt    := Dtoc(Stod(_aDadZZO[01,02]))
			_cHra    := _aDadZZO[01,03]
			_cPesBrt := Transform(_aDadZZO[1,05], "@E 99,999.99")
			_cCliEt1 := ''
			_cCliEt2 := AllTrim(SA1->A1_NOME)
			If Len(_cCliEt2) > 50
				_cCliEt1 := Left(_cCliEt2,40)
				_cCliEt2 := AllTrim(Substr(_cCliEt2,41,100))
			EndIf    
			_cPed1 := ""
			_cPed2 := Left(_cPed2,Len(_cPed2)-2)
			If Len(_cPed2) > 62
				_cPed1 := Left(_cPed2,47)
				_cPed2 := AllTrim(Substr(_cPed2,49,100))
				If Len(_cPed2) > 62
					_cPed2 := Left(_cPed2,62) + ",+"
				EndIf
			EndIf
			_cPed2 := _cPed2 +  "."
			//U_ImpZbra(cNumVol)
		EndIf
		//oPrn:Preview()
	EndIf
	If !Empty(aInfo)
		RESET ENVIRONMENT
	EndIf
Return(.T.)


/*/{Protheus.doc} ImprZbrSrv
//TODO Descrição auto-gerada.
@author Roberto
@since 18/07/2017
@version undefined
@param lServer, logical, descricao
@type function
/*/
User Function ImprZbrSrv(lServer) // u_ImprZbrSrv(.F.)
	//MSCBPRINTER("S4M","LPT1",,,.F.,,,,,,.T.)
	cPorta := "LPT3" // "192.168.1.140"
	lDrvWin := .F.
	cModel := "S4M"
	// MSCBPRINTER(1-Modelo,2-Porta,3-Densidade (Px/mm),4-Tam.Etiq.mm,5-Server/Cliente,6-,7-,8-,9-,10-,11-lDrvWin,12-)
	MSCBPRINTER(cModel,cPorta,,167,lServer,,,,,,lDrvWin)
	MSCBBEGIN(1,6)
	MSCBSAY(08,10,"NF.  PV.: ","N","F","030,025")
	//MSCBSAY(08,15,"Cliente: " ,"N","F","032,022")
	//MSCBSAY(08,20,"End: "     ,"N","F","032,022")
	//MSCBSAY(08,25,"Cidade.: " ,"N","F","032,022")
	//MSCBSAY(08,30,"Trans: "   ,"N","F","032,022")
	//MSCBSAY(08,35,"Volumes: " ,"N","F","002,002")
	MSCBEND()
	MSCBCLOSEPRINTER()
Return(.T.)


/*/{Protheus.doc} CDGENZZO
//TODO Descrição auto-gerada.
@author Roberto
@since 18/07/2017
@version undefined

@type function
/*/
User Function CDGENZZO()
	aRotina := {{ "Pesquisar" , "AxPesqui", 0 , 1	},;
				{ "Visualizar", "AxVisual", 0 , 2	},;
				{ "Incluir"   , "AxInclui", 0 , 3	},;
				{ "Alterar"   , "AxAltera", 0 , 4	},;
				{ "Excluir"   , "U_DelFun", 0 , 5	}}
	
	cCadastro := "Volumes dos Produtos"
	DbSelectArea("ZZO")
	DbSetOrder(1)
	DbSeek(xFilial("ZZO"))
	
	mBrowse(001,040,200,390,"ZZO",,,,,,)
Return(.T.)


/*/{Protheus.doc} MVPXZZRID
//TODO Descrição auto-gerada.
@author Roberto
@since 18/07/2017
@version undefined

@type function
/*/
User Function MVPXZZRID()
	Local _cZZR_ID, _aZZRID
	Local cQuery := " "
	
	Do While .T.
		_cZZR_ID := GetMv("MV_PXZZRID")		// Pega o conteúdo
		If "ERRO_ID" $ _cZZR_ID
			Exit
		EndIf
		PUTMV("MV_PXZZRID",Soma1(_cZZR_ID)) // Já grava o proximo
		cQuery := "SELECT DISTINCT ZZR_ID "
		cQuery += " FROM "+RetSqlName("ZZR") + " ZZR"
		cQuery += " WHERE ZZR_FILIAL = '"+xFilial("ZZR")+"'"
		cQuery += " AND ZZR_ID = '"+_cZZR_ID+"'"
		cQuery += " AND ZZR.D_E_L_E_T_ = ''"
		cQuery += " ORDER BY ZZR_ID"
		_aZZRID := u_QryArr(cQuery)
		If Len(_aZZRID) == 0 // Não achou nenhum
			Exit
		EndIf
	EndDo         
Return(_cZZR_ID)


/*/{Protheus.doc} ImpZbraOld
//TODO Descrição auto-gerada.
@author Roberto
@since 18/07/2017
@version undefined
@param cNumVol, characters, descricao
@type function
/*/
User Function ImpZbraOld(cNumVol) // u_ImpZbra( ,"004900")
	Private wnrel   := "ETIQZBA1"
	Private cString := "SA1"
	Private cPorta  := "LPT2"
	Private aReturn := {"Zebrado",1,"Administracao",1,3,cPorta,"",1}
	Default cNumVol := " "
	
	//Conout("04 - Antes do Default")
	SetDefault(aReturn,cString)                             
	//Conout("05 - Depois do Default")
	
	@ 0,0 PSAY "^XA^LH8,16^PRC^FS"
	@ 0,0 PSAY "^FO008,008^GB780,592,6^FS"
	@ 0,0 PSAY "^FO087,008^GB700,115,070^FS"
	
	@ 0,0 PSAY "^FO0257,030^A0N,90,75^FR^FD" + "I.D. " + _cIDVol + "^FS"
	
	//_cPart1 := "008,008"
	//_cPart2 := "078,592,050"
	//@ 0,0 PSAY "^FO"+_cPart1+"^GB"+_cPart2+"^FS"
	
	
	@ 0,0 PSAY "^FO0020,155^A0B,75,65^FR^FDCOBRECOM^FS"
	
	//Linha horizontal após o ID
	//@ 0,0 PSAY "^FO087,115^GB695,0,6^FS"
	
	@ 0,0 PSAY "^FO092,130^A0N,35,30^FD" + "DATA:" + "^FS"
	@ 0,0 PSAY "^FO254,115^GB0,95,6^FS"
	@ 0,0 PSAY "^FO261,130^A0N,35,30^FD" + "HORA:" + "^FS"
	@ 0,0 PSAY "^FO423,115^GB0,95,6^FS"
	@ 0,0 PSAY "^FO430,130^A0N,35,30^FD" + "VOLUME:" + "^FS"
	@ 0,0 PSAY "^FO592,115^GB0,95,6^FS"
	@ 0,0 PSAY "^FO599,130^A0N,35,30^FD" + "PESO BRUTO:" + "^FS"
	
	@ 0,0 PSAY "^FO092,170^A0N,35,30^FD" + _Ddtt + "^FS"
	@ 0,0 PSAY "^FO315,170^A0N,35,30^FD" + _cHra + "^FS"
	@ 0,0 PSAY "^FO476,170^A0N,35,30^FD" + cNumVol + "^FS"
	@ 0,0 PSAY "^FO640,170^A0N,35,30^FD" + _cPesBrt + "^FS"
	
	@ 0,0 PSAY "^FO087,210^GB695,0,6^FS"
	@ 0,0 PSAY "^FO092,225^A0N,35,30^FD" + "CLIENTE:" + "^FS"
	   
	@ 0,0 PSAY "^FO210,225^A0N,35,25^FD" + _cCliEt1 + "^FS"
	@ 0,0 PSAY "^FO100,265^A0N,35,25^FD" + _cCliEt2 + "^FS"
	
	@ 0,0 PSAY "^FO087,305^GB695,0,6^FS"
	@ 0,0 PSAY "^FO092,320^A0N,35,30^FD" + "PEDIDO(S):" + "^FS"
	   
	@ 0,0 PSAY "^FO225,320^A0N,35,25^FD" + _cPed1 + "^FS"
	@ 0,0 PSAY "^FO092,360^A0N,35,25^FD" + _cPed2 + "^FS"
	                                       
	@ 0,0 PSAY "^FO087,400^GB695,0,6^FS"
	@ 0,0 PSAY "^FO092,415^A0N,35,30^FD" + "RESPONSAVEL PELA MONTAGEM:" + "^FS"
	@ 0,0 PSAY "^FO100,455^A0N,35,25^FD" + Left(_cResp,50) + "^FS"
	
	@ 0,0 PSAY "^FO0470,490^BY3,,55^BUN,70,Y,N^FD" + _cCdBar + "^FS"
	
	//Linhas Verticais
	//@ 0,0 PSAY "^FO008,008^GB085,592,6^FS"
	@ 0,0 PSAY "^FO085,008^GB0,592,6^FS"
	
	@ 0,0 PSAY "^PQ"+"1"+"^FS"
	@ 0,0 PSAY "^MTT^FS"
	@ 0,0 PSAY "^MPE^FS"
	@ 0,0 PSAY "^JUS^FS"
	@ 0,0 PSAY "^XZ"
	
	//Conout("06 - Antes do de sair da zebra")
	
	MS_FLUSH()
	//Conout("07 - Sai da zebra")

Return(.T.)


/*/{Protheus.doc} ImpZbra
//TODO Descrição auto-gerada.
@author Roberto
@since 18/07/2017
@version undefined
@param cNumVol, characters, descricao
@type function
/*/
User Function ImpZbra(cNumVol) // u_ImpZbra("004900")
	Private cPorta  := "Impressora Zebra"
	Default cNumVol := " "

	lAdjustToLegacy := .F.
	lDisableSetup := .T.
	cImpr	:= "Impressora Zebra"
	cPorta	:= ""
	PreparePrint(.T.,cImpr, .F.,cPorta)
	InitPrint(2,"VOLUMES","080",,"VOLUMES")
	oPrn := FWMSPrinter():New("volume.rel",IMP_SPOOL,lAdjustToLegacy,"\spool\",lDisableSetup,,,"Impressora Zebra",.T. ,,,,1 )
	oPrn:SetPortrait() // Formato pagina Retrato
	oPrn:Box (0020,0020,0090,0570) // Box 1 Cabeçalho
	oPrn:Line(0055,0140,0055,0570) // Linha horizontal que divide o cabeçalho em dois
	oPrn:Say(20,0030,"RESPONSAVEL PELA MONTAGEM : " + _cResp,oFont7)				// Quantidade
	oPrn:Print()
Return(.T.)
