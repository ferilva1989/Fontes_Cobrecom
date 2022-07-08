#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWEBSRV.CH'

/*	Author: Robert Santos
	Date: 31 mar 2012
	Function: Gerenciamento de Pedidos
*/                                                

wsservice ws_pedido description "Gerenciamento de pedidos"
  
	wsdata pedido as sINCPED // estrutura de entrada
	wsdata retpad as sretpad // retorno padrao
	
	wsmethod incluirPV description "Incluir Pedido Venda"
	
	wsdata FSTATUS as sFSTATUS_in
	wsdata FSTATUS_Ret as sFSTATUS_out
	wsmethod GetStatusPv description "Retornar status do pedido"
	
endwsservice

// tabelas
WSSTRUCT sINCPED
	WSDATA SC5	AS SCABEC
	WSDATA SC6	AS SITENS
ENDWSSTRUCT

wsstruct sretpad
	wsdata cerrorcode as string
	wsdata cerrormsg as string
	wsdata cc5_num as string optional 
endwsstruct                                

wsstruct sFSTATUS_in
	wsdata C5FILIAL as string
	wsdata C5NUM as string
endwsstruct

wsstruct sFSTATUS_out
	wsdata COD as string
	wsdata MSG as string
endwsstruct
       

wsmethod GetStatusPv wsreceive FStatus wsSend FSTATUS_Ret wsService Ws_Pedido

local aRet := u_StVld04(::FStatus:c5filial , ::FStatus:c5num)

::FSTATUS_Ret:COD := aRet[1]
::FSTATUS_Ret:MSG := aRet[2]

return .t.

// method
wsmethod incluirPV wsreceive pedido wssend retpad wsservice ws_pedido

//VARIAVEIS PARA INCLUIR O PEDIDO
LOCAL _aCABECPRJ := {}		//CONTEMPLAR OS CAMPOS DA SC5
LOCAL _aITENSPRJ := {}		//CONTEMPLAR OS ITENS DA SC6
LOCAL _cC5_NUM := getsxenum("SC5","C5_NUM")			//NUMERO DO PEDIDO A SER GERADO
local cmsg := ""

//CONTROLE DO MSEXECAUTO
PRIVATE lMSErroAuto := .f.

// retornar numeracao
rollbacksx8()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preencher Cabecalho                                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aCABECPRJ  := U_CONVCABEC(::pedido:SC5)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Preencher itens                                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aITENSPRJ	:=	U_CONVITENS(::pedido:SC6)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ CONTEMPLA INCLUIR PEDIDO DE VENDA                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_aCABECPRJ := U_ORDEMSX3(_aCABECPRJ,"SC5")

begin transaction

lMsErroAuto := .f.

msEXECAUTO({|x,y,z|MATA410(x,y,z)},_aCABECPRJ, _aITENSPRJ, 3)
IF lMsErroAuto
	Disarmtransaction()
	
	makedir("\system\cobrecom_execauto\")
	mostraerro("\system\cobrecom_execauto\","pedido_venda.txt")
	
	// ler arquivo de log
	nhdl := ft_fuse("\system\cobrecom_execauto\pedido_venda.txt")
	cmsg := "Erro!"
	if nhdl > 0
		cmsg := ""
		while !ft_feof()
			cmsg += ft_freadln()+CRLF
			ft_fskip()
		enddo
	endif
	ft_fuse()
	
	::retpad:cErrorCode := "01"
	::retpad:cErrorMSG  := cmsg
	::retpad:cC5_NUM    := _cC5_NUM
	
ELSE
	::retpad:cErrorCode := "00"
	::retpad:cErrorMSG  := "OK"
	::retpad:cC5_NUM    := _cC5_NUM
ENDIF

end transaction


return .t.