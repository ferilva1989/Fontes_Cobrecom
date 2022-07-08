#include 'totvs.ch'
#include 'topconn.ch'

/*
Robert Santos
04 abr 2012
PE para enviar informacoes ao vendedor de liberacao de cliente
*/
user function MA030TOK

local cquery, nquery
local lRet		:= .T.
local la1_opened := .f.
local la3_opened := .f.
local nsaldo := 0

private aheadc6 := {}
private aHeadD4 := {}

//Leonardo 28/12/16 - a função abaixo esta no fonte MYMTA030.PRW 
lRet := U_MY030TOK()
//Fim Leonardo

// validar alteracao apenas em tela
if( type("M->A1_MSBLQL")<>"U" ) .and. lRet
	if SA1->A1_MSBLQL == "1" .and. M->A1_MSBLQL == "2" .and. !empty(SA1->A1_VEND) .and. !l030Auto
		// Enviar email de liberacao de cadastro de cliente
		u_cwf02()
	endif
	
	// liberar orcamentos bloqueado apenas pelo departamento financeiro
	// regra de desbloqueio
	if M->A1_RISCO <> 'E' .and. M->A1_LC > 0 .and. M->A1_MSBLQL <> '1'
		
		//  trazer o saldo do cliente
		nsaldo := SA1->A1_LC - sldCliente( SA1->(A1_COD+A1_LOJA) , ddatabase , 1 /*moeda*/, .t. /*verificar titulos em aberto*/ ) // saldo a ser retornado
		
		// selecionar orcamentos bloqueados apenas do financeiro
		cquery := " select SCJ.R_E_C_N_O_ AS SCJ_ID from "+retsqlname("SCJ")+" SCJ where SCJ.D_E_L_E_T_ = '' and CJ_CLIENTE+CJ_LOJA = '"+SA1->(A1_COD+A1_LOJA)+"' "
		cquery += " and CJ_XBL2 = 'S' and CJ_XBL1 <> 'S' "
		cquery += " and CJ_XTOTAL <= "+alltrim( str(nsaldo) )
		if select("QRY")>0
			QRY->( dbclosearea() )
		endif
		tcquery cquery new alias "QRY"
		count to nquery
		if nquery >0
			QRY->(dbgotop())
			while !(QRY->(EOF()))
				
				dbselectarea("SCJ")
				SCJ->( dbgoto(QRY->SCJ_ID) )
				
				// configurar parametros para exportacao automatica
				MV_PAR01 := SCJ->CJ_NUM
				MV_PAR02 := SCJ->CJ_NUM
				
				MV_PAR03 := SCJ->CJ_EMISSAO
				MV_PAR04 := SCJ->CJ_EMISSAO
				MV_PAR05 := 2 // nao liberar pedido de venda
				
				// GERAR PEDIDO DE VENDA
				// montar aheaders
				monta01()
				// rotina automatica protheus  
				Ma416Proc()
				
				// STATUS ORCAMENTO A=Aberto;B=Aprovado;C=Cancelado;D=Noo Orþado
				SCJ->( dbseek( xfilial("SCJ")+SCJ->(CJ_NUM+CJ_CLIENTE+CJ_LOJA) ) )
				if (SCJ->CJ_STATUS $ "A,B")
					// resgatar numero do pedido gerado
					cquery := "select top 1 C6_NUM from "+retsqlname("SC6")+" where C6_NUMORC like '"+SCJ->CJ_NUM+"%' and D_E_L_E_T_ = ''"
					iif( select("QRY2")>0, QRY2->(dbclosearea()), )
					tcquery cquery new alias "QRY2"
					count to nquery
					if nquery>0
						QRY2->(dbgotop())
						
						dbselectarea("SC5")
						SC5->( dbsetorder(1) )
						if( SC5->( dbseek(xfilial("SC5")+QRY2->C6_NUM) ) )
							
							dbselectarea("SA1")
							SA1->( dbsetorder(1) )
							if SA1->(dbseek(xfilial("SA1")+SCJ->(CJ_CLIENTE+CJ_LOJA)))
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
							
							u_cwf05( la1_opened, la3_opened ) // send mail to orders  
							
							// atualizar o status do orcamento     
							dbselectarea("SCK")
							SCK->( dbsetorder(1) ) // CK_FILIAL, CK_NUM, CK_ITEM, CK_PRODUTO, R_E_C_N_O_, D_E_L_E_T_
							SCK->( dbseek(xfilial("SCK")+SCJ->(CJ_NUM) ) )
							laux := .f.
							while !SCK->(eof()) .and. SCK->CK_NUM == SCJ->CJ_NUM
								if( empty(SCK->CK_NUMPV) )
									laux := .t. // possui item em aberto
									exit
								endif
								SCK->( dbskip() )
							enddo
							
							SCJ->( reclock("SCJ", .F. ))
							SCJ->CJ_XBL1 := "N"       
							
							if laux
								SCJ->CJ_STSITE := "1" // aprovado
							else
								SCJ->CJ_STSITE := "4" // encerrado
							endif                                 
							
							SCJ->( msunlock() ) 
							
						endif
					endif
					
					QRY2->( dbclosearea() )
				endif
				QRY->( dbskip() )
			enddo
		endif
	endif
endif

return lRet 

// montador de aheader auxiliar
static function monta01()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader do SC6                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SC6",.T.)
While ( !Eof() .And. (SX3->X3_ARQUIVO == "SC6") )
	If (  ((X3Uso(SX3->X3_USADO) .And. ;
			!( Trim(SX3->X3_CAMPO) == "C6_NUM" ) .And.;
			Trim(SX3->X3_CAMPO) != "C6_QTDEMP"  .And.;
			Trim(SX3->X3_CAMPO) != "C6_QTDENT") .And.;
			cNivel >= SX3->X3_NIVEL) .Or.;
			Trim(SX3->X3_CAMPO)=="C6_NUMORC" .Or. ;
			Trim(SX3->X3_CAMPO)=="C6_NUMOP"  .Or. ;
			Trim(SX3->X3_CAMPO)=="C6_ITEMOP" .Or. ;
			Trim(SX3->X3_CAMPO)=="C6_OP" .Or. ;
			Trim(SX3->X3_CAMPO)=="C6_OPC" )	
		Aadd(aHeadC6,{TRIM(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			If(Trim(SX3->X3_CAMPO)=="C6_NUMORC",".F.",SX3->X3_VALID),;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader do SD4                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
dbSetOrder(1)
MsSeek("SD4")
While ( !Eof() .And. SX3->X3_ARQUIVO == "SD4" )
	If ( X3Uso(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL )
		Aadd(aHeadD4,{ Trim(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT })
	EndIf
	dbSelectArea("SX3")
	dbSkip()
EndDo    

return