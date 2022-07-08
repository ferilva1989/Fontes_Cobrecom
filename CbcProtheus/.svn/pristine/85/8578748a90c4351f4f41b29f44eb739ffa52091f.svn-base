/*/{Protheus.doc} F200VAR
(long_description)
@type function
@author bolognesi
@since 15/03/2018
@version 1.0
@description O ponto de entrada F200VAR do CNAB a receber sera executado apos carregar 
os dados do arquivo de recepcao bancaria e sera utilizado para alterar os dados recebidos.
Estrutura de PARAMIXB
	Número do Título		cNumTit
	Data da Baixa 		dBaixa 
	Tipo do Título		cTipo 
	Nosso Número 			cNsNum 
	Valor da Despesa 		nDepres 
	Valor do Desconto 	nAbatim
	Valor do Abatimento 	nValRec 
	Juros 				nJuros 
	Multa 				nMulta 
	Outras Despesas 		nOutrDesp 
	Valor do Credito 		nValCred 
	Data do Credito 		dDataCred
	Ocorrência			cOcorr
	Motivo da Baixa 	 	cMotBan
	Linha Inteira 		xBuffer 
	Data de Vencimento 	dDtVc	 
/*/
user function F200VAR()
	OutrosCr()
return(.T.)


/*/{Protheus.doc} OutrosCr
@type function
@author bolognesi
@since 15/03/2018
@version 1.0
@description Transferir outros créditos considerando como Juros
/*/
static function OutrosCr()
	PARAMIXB[1,9] 	:=(PARAMIXB[1,9] + PARAMIXB[1,10] + PARAMIXB[1,11] + PARAMIXB[1,12])
	PARAMIXB[1,10]	:= 0
	PARAMIXB[1,11]	:= 0
	PARAMIXB[1,12]	:= 0
	NJUROS 			:= (NJUROS + NMULTA +  NVALCC)
	NVALCC			:= 0
	NMULTA			:= 0
return(nil)


