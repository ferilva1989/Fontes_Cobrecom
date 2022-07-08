#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWEBSRV.CH'
#INCLUDE 'topconn.CH'

/*	Author: Robert Santos
Date: 31 jun 2012
Function: Validate rules of Protheus
*/

wsservice WS_REGRAPROTHEUS description "Validar regras do Protheus com possíveis alterações"

	wsdata vldAcondic as StrVldAcondic
	wsdata retpad as strRetPad
	wsmethod vldAcondicionamento description "Validar Acondicionamentos"  
	                
	//INICIO LEONARDO 10/04/2014
	wsdata getParam as STRGETPARAM
	wsdata retParam as String
	wsmethod mGetParam description "Recebe o nome do parametro e retorna seu conteudo"
	//FIM LEONARDO
	
	wsdata getComis as strGetComissao
	wsdata ncomis as float
	wsmethod getComissao description "Retornar valor da comissão por Item" 
	
	wsdata cj_num as string
	wsmethod EncerrarOrc description "Encerrar Orçamento"  
	
	wsmethod SendMailToMaterials description "Enviar e-mail apos criar um orcamento de entrega em estoque" 
	
	WSDATA c5_num as string
	wsmethod SendMailToOrders description "Enviar e-mail após incluir um Pedido de venda pelo site"
	
	wsdata lmodo as boolean
	wsmethod SendMailOrc1 description "Enviar e-mail do orcamento para gestores"
	
	wsmethod SendMailOrc2 description "Enviar e-mail do orcamento para Representantes"
	
	wsmethod SendMailOrc3 description "Enviar e-mail do orcamento para Cliente"   
	                                                                                                 
	wsdata inGetDesconto as strEntGetDesconto
	wsdata outGetDesconto as strRetGetDesconto
	wsmethod GetDesconto description "Resgatar a faixa de descontos da CARTA DE DESCONTO (SZX x SZY)" 
	        
	wsdata cA3_cod as string   
	wsdata outGetMyAlert as strRetGetMyAlert
	wsmethod GetMyAlert description "Pegar avisos de Clientes com Tit.A pagar atrasados"        
	                                                                                 
	wsdata czzb_id as string 
	wsmethod ConfirmMessage description "Sinalizar leitura do vendedor da nova mensagem"  
	
	wsdata retGetMyValidMessages as strGetMyValidMessages
	wsmethod getMyValidMessages description "Retornar as mensagens da fábrica"   
	
	wsdata nValor as float
	wsmethod SetDescEsp description "Ajustar parametro MV_DESCESP"    
	                                                                 
	wsdata CLCDESC_in as CLCDESC_in_s
	wsmethod CLCDESC description "Retornar desconto fragmentado geral"
	
	wsdata cE4_COD as string
	wsmethod ValPagar45 description "Validar a condicao de pagamento enviada em no máximo 45DDL"
	
endwsservice

// estruturas            

//INICIO LEONARDO 10/04/2014 - Estrutura que recebe os valores do portal
//para consulta de parametros
wsstruct STRGETPARAM         
	wsdata cConsultParam  as string
	wsdata cConsultfilial as string
endwsstruct
//FIM LEONARDO

wsstruct CLCDESC_in_s
	wsdata cda0_cod as string
	wsdata ca3_cod as string
	wsdata cb1_cod as string
	wsdata nprc_venda as float
endwsstruct
          
// ************GETDESCONTO   
// entrada
wsstruct strEntGetDesconto 
	wsdata ca1_cod as string 
	wsdata ca1_loja as string
	wsdata ca3_cod as string
endwsstruct  

// retorno
wsstruct strRetGetDesconto
	wsdata cErrorCode as string
	wsdata cErrorMsg as string
	wsdata aZY_DESCONT as array of string optional
endwsservice 

wsstruct strRetGetMyAlert
	wsdata cErrorCode as string
	wsdata cErrorMsg as string
	wsdata ClientesAtrasados as array of string optional
endwsservice   

wsstruct strGetMyValidMessages
	wsdata cerrorcode as string
	wsdata cerrormsg as string
	wsdata zzb as array of strZzb optional
endwsstruct            

wsstruct strZZB        
	wsdata zzb_id as string
	wsdata zzb_titulo as string
	wsdata zzb_msge as string
endwsstruct

WsStruct strRetPad
	WsData cErrorCode As String
	WsData cErrorMsg As String
	wsdata nValor as float optional
	wsdata cValor as STRING optional
EndWsStruct     

wsstruct StrVldAcondic
	wsdata cacondic as string
	wsdata nmetrage as float
	wsdata cb1_cod as string
endwsstruct        

wsstruct strGetComissao
	wsdata ca1_cod as string
	wsdata ca1_loja as string
	wsdata ca3_cod as string
	wsdata cda0_codtab as string
	wsdata cb1_cod as string
	wsdata nprcvenda as float
	wsdata cf4_cod as string
	wsdata cacondic as string
	wsdata nMetrage as float
	//INICIO LEONARDO 07/05/2014 - Utilizado para o calculo de comissão
	//Solicitado Roberto dia 07/05/2014 VejaComiss()
   	wsdata ce4_cod as String
	//FIM LEONARDO
endwsstruct


// method
wsmethod vldAcondicionamento wsreceive vldAcondic wssend retpad wsservice WS_REGRAPROTHEUS
                            
local cmsg := "NAO INICIADO"
local lok := .f.     
local aval := {}

aval	:= u_StVld01( ::vldAcondic:cacondic, ::vldAcondic:nmetrage, ::vldAcondic:cb1_cod  )      
lok		:= aval[1]
cmsg	:= aval[2]

// retornar
if lok
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "00"
else                        
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "01"
endif

return .t.     
                      
//INICIO LEONARDO 10/04/2014 - Retorna o conteudo de um parametro
wsmethod mGetParam wsreceive getParam wssend retParam wsservice WS_REGRAPROTHEUS 

if  GetMv( ::getParam:cConsultParam,.T.,) 
                                 
      ::retParam := GetMv( ::getParam:cConsultParam,.F.,)
      ::retParam := cValToChar(::retParam) 

 else
 
    ::retParam := "Parametro nao encontrado"     
 
 end if         
 	
return .t.
//FIM LEONARDO


wsmethod getComissao wsreceive getComis wssend ncomis wsservice WS_REGRAPROTHEUS // retornar comissao

local cAcond := ::getComis:cacondic + StrZero(::GetComis:nMetrage,5)             

//Temporario para debug
Local aParam := {"::getComis:ca1_cod", "::getComis:ca1_loja", "::getComis:ca3_cod", "::getComis:cda0_codtab", "::getComis:cb1_cod", "::getComis:nprcvenda", "::getComis:cf4_cod", "cAcond", "::getComis:ce4_cod"}
Local aParam1 := {::getComis:ca1_cod, ::getComis:ca1_loja, ::getComis:ca3_cod, ::getComis:cda0_codtab, ::getComis:cb1_cod, ::getComis:nprcvenda, ::getComis:cf4_cod, cAcond,::getComis:ce4_cod}
u_dbgAuxPortal("getComissao",aParam,aParam1)
//Apagar

//INICIO LEONARDO 07/05/2014 adicionei parametro "::getComis:ce4_cod"           
::ncomis := u_StVld02( ::getComis:ca1_cod, ::getComis:ca1_loja, ::getComis:ca3_cod, ::getComis:cda0_codtab, ::getComis:cb1_cod, ::getComis:nprcvenda, ::getComis:cf4_cod, cAcond,::getComis:ce4_cod) // retornar comissao
//FIM

return .t.   

// encerrar orcamento
wsmethod EncerrarOrc wsreceive cj_num wssend retpad wsservice WS_REGRAPROTHEUS

local lok := .f.
local cmsg := "NAO INICIADO"

dbselectarea("SCJ")
SCJ->( dbsetorder(1) )
if( SCJ->( dbseek(xfilial("SCJ")+::cj_num) ) )
	SCJ->( reclock("SCJ",.f.) )
	SCJ->CJ_STSITE := '4' // ENCERRADO
	SCJ->( msunlock() )
   
	cmsg := "OK"
	lok := .t.
else 
	cmsg := "PROJETO NAO ENCONTRADO"
endif

// retornar
if lok
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "00"
else
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "01"
endif

return .t.

     
wsmethod SendMailToMaterials wsreceive cj_num wssend retpad wsservice WS_REGRAPROTHEUS

local lok := .f.
local cmsg := "NAO INICIADO"
local la1_opened := .f.
local la3_opened := .f.

dbselectarea("SCJ")
SCJ->( dbsetorder(1) )
if( SCJ->( dbseek(xfilial("SCJ")+::cj_num) ) )
	cmsg := "OK"
	lok := .t.
	
	dbselectarea("SA1")
	SA1->( dbsetorder(1) )
	if SA1->(dbseek(xfilial("SA1")+SCJ->(CJ_CLIENTE+CJ_LOJA)))
		la1_opened := .t.
	endif
	
	dbselectarea("SA3")
	SA3->( dbsetorder(1) )
	if SA3->(dbseek(xfilial("SA3")+SCJ->(CJ_VEND1)))
		la3_opened := .t.
	endif
	
	dbselectarea("SCK")
	SCK->( dbsetorder(1) ) // CK_FILIAL, CK_NUM, CK_ITEM, CK_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
	SCK->(dbseek(xfilial("SCK")+SCJ->(CJ_NUM)))
	
	u_cwf04( la1_opened, la3_opened )
	
else
	cmsg := "PROJETO NAO ENCONTRADO"
endif

// retornar
if lok
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "00"
else
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "01"
endif

return .t.              


wsmethod SendMailToOrders wsreceive c5_num wssend retpad wsservice WS_REGRAPROTHEUS

local lok := .f.
local cmsg := "NAO INICIADO"

aRet := u_xMailOrder( ::c5_num )
lOk := aret[1]
cmsg := aret[2]

// retornar
if lok
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "00"
else
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "01"
endif

return .t.                  


wsmethod SendMailOrc1 wsreceive cj_num, lmodo wssend retpad wsservice WS_REGRAPROTHEUS

local lok := .f.
local cmsg := "NAO INICIADO"
local cpara := lower(trim(getmv("MV_XGERENT")))

if( !empty(cpara))
	dbselectarea("SCJ")
	SCJ->( dbsetorder(1) )
	if( SCJ->( dbseek(xfilial("SCJ")+::cj_num) ) )
		cmsg := "OK"
		lok := .t.
		
		u_cwf08( cpara, ::lmodo )
		
	else
		cmsg := "ORÇAMENTO NÃO ENCONTRADO!!"
	endif
else
	cmsg := "Endereco parametro 'MV_XGERENT' com e-mail não esta preenchido!"
endif

// retornar
if lok
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "00"
else
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "01"
endif

return .t.

wsmethod SendMailOrc2 wsreceive cj_num, lmodo wssend retpad wsservice WS_REGRAPROTHEUS

local lok := .f.
local cmsg := "NAO INICIADO"

dbselectarea("SCJ")
SCJ->( dbsetorder(1) )
if( SCJ->( dbseek(xfilial("SCJ")+::cj_num) ) )
	if u_cwf09( ::lmodo )
		cmsg := "OK"
		lok := .t.
	else
		cmsg := "E-mail do representante sem preenchimento!"
	endif
else
	cmsg := "ORÇAMENTO NÃO ENCONTRADO!!"
endif

// retornar
if lok
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "00"
else
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "01"
endif

return .t.     


wsmethod SendMailOrc3 wsreceive cj_num, lmodo wssend retpad wsservice WS_REGRAPROTHEUS

local lok := .f.
local cmsg := "NAO INICIADO"

dbselectarea("SCJ")
SCJ->( dbsetorder(1) )
if( SCJ->( dbseek(xfilial("SCJ")+::cj_num) ) )
	
	// verificar modelo seco
	if ::lmodo
		if u_cwf11() 
			cmsg := "OK"
			lok := .t.
		else  
			cmsg := "E-mail do cliente sem preenchimento!"
		endif
	else
		if u_cwf10( .f. )
			cmsg := "OK"
			lok := .t.
		else
			cmsg := "E-mail do cliente sem preenchimento!"
		endif
	endif
else
	cmsg := "ORÇAMENTO NÃO ENCONTRADO!!"
endif

// retornar
if lok
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "00"
else
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "01"
endif

return .t. 


wsmethod GetDesconto wsreceive inGetDesconto wssend outGetDesconto wsservice WS_REGRAPROTHEUS

local lok := .f.
local cmsg := "NAO INICIADO"
local aZY_DESCONT := u_STVLD03( ::inGetDesconto:ca1_cod, ::inGetDesconto:ca1_loja, ::inGetDesconto:ca3_cod )
local ni := 0

// preencher faixa de descontos
for  ni := 1 to len(azy_descont)
	aadd( ::outGetDesconto:azy_descont, azy_descont[ni] )
next        

if len(azy_descont)>0
	lok := .t.
endif

// retornar
if lok
	::outGetDesconto:cErrorMsg := cmsg
	::outGetDesconto:cErrorCode := "00"
else
	::outGetDesconto:cErrorMsg := "CARTA DESCONTO NAO ENCONTRADA"
	::outGetDesconto:cErrorCode := "01"
endif

return .t.   


wsmethod GetMyAlert wsreceive cA3_COD wssend outGetMyAlert wsservice WS_REGRAPROTHEUS

local lok := .f.
local cmsg := "NAO INICIADO"
local nhdl       
local cnomarq := "\site\"+cempant+cfilant+::ca3_cod+".arqtxt"            
local aaux := {}

if( file( cnomarq ) )
	nhdl := ft_fuse( cnomarq )
	if nhdl > -1
		ft_fgotop()
		while !ft_feof()
			
			// A1_COD ; A1_LOJA ; A1_NOME de clientes com tit.pagar em atraso
			aadd( ::outGetMyAlert:ClientesAtrasados, ft_freadln() )
			lok := .t.
			
			ft_fskip()
		enddo
	endif 
	ft_fuse()
else 
	cmsg := "SEM PENDENCIAS"
endif

// retornar
if lok
	::outGetMyAlert:cErrorMsg := "OK"
	::outGetMyAlert:cErrorCode := "00"
else
	::outGetMyAlert:cErrorMsg := cmsg
	::outGetMyAlert:cErrorCode := "01"
endif

return .t.     

wsmethod GetMyValidMessages wsreceive cA3_COD wssend RetGetMyValidMessages wsservice WS_REGRAPROTHEUS

local lok := .f.
local cmsg := "NAO INICIADO"  

local cqry := ""
local nqry := 0
local cdata := dtos( ddatabase )    

local otemp := nil

cqry := " select R_E_C_N_O_ AS ZZB_RECNO from "+retsqlname("ZZB")+" ZB where ZB.D_E_L_E_T_ = '' "+CRLF
cqry += " and ZZB_DTINIC <= '"+cdata+"' "+CRLF
cqry += " and ZZB_DTFINA >= '"+cdata+"' "+CRLF
iif( select("QRY")>0 , QRY->(dbclosearea() ) ,   )
tcquery cqry new alias "QRY"
count to nqry
if nqry >0  

	dbselectarea("ZZB")
	
	lok := .t.
	QRY->( dbgotop() )
	while !QRY->(eof()) 
	
		ZZB->( dbgoto(QRY->(ZZB_RECNO)) )   
	
		AAdd( ::retgetmyvalidmessages:zzb , WSClassNew( "strZZB" ))

      	oTemp := aTail( ::retgetmyvalidmessages:zzb )
		oTemp:ZZB_ID := ZZB->ZZB_ID
		oTemp:ZZB_MSGE := trim(ZZB->ZZB_MSGE)
		oTemp:ZZB_TITULO := trim(ZZB->ZZB_TITULO)
		
		QRY->( dbskip() )
	enddo
else
	cmsg := "Sem mensagens"
endif

// retornar
if lok
	::RetGetMyValidMessages:cErrorMsg := "OK"
	::RetGetMyValidMessages:cErrorCode := "00"
else
	::RetGetMyValidMessages:cErrorMsg := cmsg
	::RetGetMyValidMessages:cErrorCode := "01"
endif

return .t.


wsmethod ConfirmMessage wsreceive cA3_COD, czzb_id wssend retpad wsservice WS_REGRAPROTHEUS

local lok := .f.
local cmsg := "NAO INICIADO"                

dbselectarea("ZZC")
ZZC->( reclock("ZZC", .t. ) )

ZZC->ZZC_ID := GETSXENUM("ZZC", "ZZC_ID" )
ZZC->ZZC_IDMSGE := ::czzb_id
ZZC->ZZC_IDREPR := ::ca3_cod

ZZC->( msunlock() )           

confirmSx8()  
lok := .t.

// retornar
if lok
	::retpad:cErrorMsg := "OK"
	::retpad:cErrorCode := "00"
else
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "01"
endif

return .t.


// resgatar o nome de acondicionamento
user function XdeAcond( cacondic, lparaCliente )

default lparacliente := .f.

do case
	case cacondic == "B"
		cacondic := "Bobina"
	case cacondic == "R"
		cacondic := "Rolo"
	case cacondic == "C"
		cacondic := "Carretel"
	case cacondic == "T"   
		if lparacliente
	    	cacondic := "Irregular"
		else
			cacondic := "Retalho"
		endif
	case cacondic == "M"
		cacondic := "Carretel Madeira"
endcase

return cacondic

// DECODE STATUS DISPONIBILIDADE
user function ckstsite( cvalue )

cvalue := alltrim( cvalue )

do case
	case cvalue == "1"
		cvalue := "Em estoque"
	case cvalue == "2"
		cvalue := "A produzir"
	otherwise
		cvalue := ""
endcase

return cvalue


wsmethod SetDescEsp wsreceive nValor wssend retpad wsservice WS_REGRAPROTHEUS

local lok := .f.
local cmsg := "NAO INICIADO" 

dbselectarea("SX6")
SX6->( dbsetorder(1) )
if( SX6->( dbseek(xfilial("SX6")+"MV_DESCESP") ) )
	SX6->( reclock("SX6",.f.) )
	SX6->X6_CONTEUD := alltrim(str(::nValor)) // ENCERRADO
	SX6->( msunlock() )
   
	cmsg := "OK"
	lok := .t.
else 
	cmsg := "PARAMETRO 'MV_DESCESP' NAO ENCONTRADO"
endif

// retornar
if lok
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "00"
else
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "01"
endif

return .t.


wsmethod ValPagar45 wsreceive cE4_COD, nValor wssend retpad wsservice WS_REGRAPROTHEUS

local lok := .T.
local cmsg := "INICIANDO.."    
local aCond, ndias, i

nDias := 0
i := 0
aCond := Condicao(::nValor, ::cE4_COD, 0, dDatabase)  
for i:=1 to len(aCond)
	nDias += aCond[i,1]-dDatabase
next

if nDias > 45
	lOk := .f.
	cMsg := "Superior a 45 dias"
else 
	lOk := .t.
	cMsg := "OK"
endif

// retornar
if lok
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "00"
else
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "01"
endif

return .t.


// Enviar email para o faturamento apos incluir/ alterar pedido pelo site
user function xMailOrder(cC5_NUM)

local la1_opened := .f.
local la3_opened := .f.   
local aRet, cMsg, lOk

dbselectarea("SC5")
SC5->( dbsetorder(1) )
lOk := .f.
if( SC5->( dbseek(xfilial("SC5")+cc5_num) ) )
	cmsg := "OK"
	lok := .t.
	
	dbselectarea("SA1")
	SA1->( dbsetorder(1) )
	if SA1->(dbseek(xfilial("SA1")+SC5->(C5_CLIENTE+C5_LOJACLI)))
		la1_opened := .t.
	endif
	
	dbselectarea("SA3")
	SA3->( dbsetorder(1) )
	if SA3->(dbseek(xfilial("SA3")+SC5->(C5_VEND1)))
		la3_opened := .t.
	endif
	
	dbselectarea("SC6")
	SC6->( dbsetorder(1) ) // C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
	SC6->(dbseek(xfilial("SC6")+SC5->(C5_NUM)))
	
	u_cwf05( la1_opened, la3_opened )
else
	cmsg := "PEDIDO VENDA NAO ENCONTRADO"
endif     

aret := { lOk , cMsg }

return aRet




wsmethod CLCDESC wsreceive CLCDESC_in wssend retpad wsservice WS_REGRAPROTHEUS

local lok := .T.
local cmsg := "OK"    

::retpad:cValor := u_CLCDESC( ::CLCDESC_in:cDa0_Cod, ::CLCDESC_in:cA3_cod, ::CLCDESC_in:cB1_cod, ::CLCDESC_in:nPrc_venda )

// retornar
if lok
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "00"
else
	::retpad:cErrorMsg := cmsg
	::retpad:cErrorCode := "01"
endif

return .t.