#include 'protheus.ch'
#include 'parmtype.ch'

//Define se esta habilitado ou não a utilização do varejo
static onVarejo		:= GetNewPar('ZZ_ONVAREJ', .T.)
static ORCAMENTO 	:= IsInCallStack('MATA415')
static PEDIDO 		:= IsInCallStack('MATA410') .Or. IsInCallStack('MABXORC')

/*/{Protheus.doc} vZTPVEN
@author bolognesi
@since 14/07/2017
@version 1.0
@type function
@description Utilizada no When de edição do campo que define o tipo da venda como varejo
no orçamento CJ_ZTPVEND e no pedido C5_ZTPVEND, a validação verifica o campo A1_ZZVAREJ
do cliente, sendo o cliente varejo(S), os campos que definem o tipo da venda recebem (V=Varejo ou N=Normal)
Cliente Varejo N, não permite a edição dos campos que definem o tipo da venda. Caso o tipo da venda for varejo
e tiver itens na grid, este função tambem valida informando produtos inadequados ao Varejo.
/*/
user function vZTPVEN()
	local oCliente 		:= nil  
	local lRet			:= .F.
	local oVarProd		:= Nil
	local cTpVend		:= ''
	local cCmpTabela	:= ''
	local verItem		:= ''
	local lTemItm		:= .T.
	local cTabela		:= ''
	local cTabVar		:= Padr( GetNewPar('XX_VARTAB', '12'), TamSx3('A1_TABELA')[1] )
	local cZTpVend		:= ''
	local cTabPrcAnt	:= ''

	if onVarejo
		if Inclui
			bkArea()
			If ORCAMENTO
				oCliente 	:= cbcModClient():newcbcModClient( M->(CJ_CLIENTE), M->(CJ_LOJA) )
				cTpVend		:= 'M->(CJ_ZTPVEND)'
				cZTpVend	:= Alltrim(M->(CJ_ZTPVEND))
				lTemItm		:=  ItemOrc()
				cCmpTabela	:= 'M->(CJ_TABELA)'
				cTabPrcAnt	:=  M->(CJ_TABELA)
				cTabela		:= 'SCJ'
			elseif PEDIDO
				oCliente 	:= cbcModClient():newcbcModClient( M->(C5_CLIENTE), M->(C5_LOJACLI) )
				cTpVend		:= 'M->(C5_ZTPVEND)'
				cZTpVend	:= Alltrim(M->(C5_ZTPVEND))
				lTemItm		:=  ItemPed()
				cCmpTabela	:= 'M->(C5_TABELA)'
				cTabPrcAnt	:=  M->(C5_TABELA)
				cTabela		:= 'SC5'
			endif

			if lTemItm
				if !(lRet :=  ( oCliente:getField('A1_ZZVAREJ') == 'S'))
					&(cTpVend + ":= 'N'") 

					if cTabPrcAnt == cTabVar
						U_cbcBustab(cTabela)
					endif

				endif

				if cZTpVend == 'V'
					&(cCmpTabela + ":= '" + cTabVar + "'")
				else
					if cTabPrcAnt == cTabVar
						U_cbcBustab(cTabela)
					endif
				endif

			endif 

			FreeObj(oCliente)
			rstArea()
		endif
	endif

return(lRet)

/*/{Protheus.doc} vareLiOk
@author bolognesi
@since 14/07/2017
@version 1.0
@type function
@description Utilizada nas validações e linha para o produto, quando tipo venda varejo
permitir apenas produtos de varejo.(Cadastrados na tabela ZZZ com o tipo ZZZ_TIPO = 'VAR')
Chamada pelas funções A415LIOK() e M410LIOK() 
/*/
user function vareLiOk()
	local oVarProd	:= nil 
	local cProduto	:= ''
	local cAcond	:= ''
	local cMetrage	:= ''
	local cTpVend	:= ''
	local lDelete	:= .F.
	local lRet		:= .T.
	if onVarejo
		bkArea()
		oVarProd := cbcVarejoProduto():newcbcVarejoProduto()
		If ORCAMENTO
			aArea1		:= TMP1->(getArea())
			aArea2		:= SCJ->(getArea())
			aArea3		:= SCK->(getArea())
			cDelete 	:= TMP1->(CK_FLAG)
			cTpVend		:= CJ_ZTPVEND
			cProduto 	:= TMP1->(CK_PRODUTO)
			cAcond		:= TMP1->(CK_ACONDIC)
			cMetrage	:= TMP1->(CK_METRAGE)
		elseif PEDIDO
			aArea2		:= SC5->(getArea())
			aArea3		:= SC6->(getArea())
			cDelete 	:= GDDeleted(n)
			cTpVend		:= C5_ZTPVEND
			cProduto 	:= GDFieldGet("C6_PRODUTO",n)
			cAcond		:= GDFieldGet("C6_ACONDIC",n)
			cMetrage	:= GDFieldGet("C6_METRAGE",n)
		endif

		if !cDelete
			if cTpVend == 'V'
				if	!(lRet := oVarProd:isRetail(cProduto,cAcond,cMetrage ))
					u_autoalert(oVarProd:getInfo(cProduto))
				endif
				FreeObj(oVarProd)
			endif
		endif
		rstArea()
	endif
return(lRet)

/*/{Protheus.doc} vareTdOk
@author bolognesi
@since 14/07/2017
@version 1.0
@type function
@description Utilizada nas validações final para todos produtos da grid,
permitir apenas produtos de varejo.(Cadastrados na tabela ZZZ com o tipo ZZZ_TIPO = 'VAR')
Chamada pelas funções A415TdOk() e MT410TOK()
/*/
user function vareTdOk()
	local lRet	:= .T.
	local cMsg	:= ''
	if onVarejo
		bkArea()

		If ORCAMENTO
			if M->(CJ_ZTPVEND) == 'V'
				lRet := Empty(cMsg := zVerOrc())
			endif
		elseif PEDIDO
			// u_AvalPrz("SC6", .T.)
			if M->(C5_ZTPVEND) == 'V'
				lRet := Empty(cMsg := zVarPed())
			endif
		endif

		if !lRet
			u_autoalert('[VAREJO]-Não permitido os itens: ' + chr(13) +  cMsg)
		endif
		rstArea()
	endif
return(lRet)

/*/{Protheus.doc} zVerOrc
@author bolognesi
@since 14/07/2017
@version 1.0
@type function
@description Função especifica orçamento, percorre os itens TMP1, e utilizando
a classe cbcVarejoProduto o metodo isRetail, para definir se o produto é um produto de
varejo.
/*/
static function zVerOrc()
	local cMsg		:= ''
	local oVarProd	:= nil
	local nTotVejo 		:= 0

	DbSelectArea('TMP1')
	TMP1->(DbGoTop())
	While !TMP1->(eof())
		if !TMP1->(CK_FLAG)
			if !empty(TMP1->(CK_PRODUTO))
				nTotVejo += TMP1->(CK_VALOR)
				oVarProd := cbcVarejoProduto():newcbcVarejoProduto()
				if ! oVarProd:isRetail(TMP1->(CK_PRODUTO),TMP1->(CK_ACONDIC),TMP1->(CK_METRAGE))
					cMsg += 'ITEM: ' + Alltrim(TMP1->(CK_ITEM)) + chr(13)
					cMsg += 'PRODUTO: ' + Alltrim(TMP1->(CK_PRODUTO)) + chr(13)
				endif
			endif
		endif
		TMP1->(dbSkip())
	enddo
	cMsg += totalVarej(nTotVejo)
	oGetDad:Refresh()
return(cMsg)

/*/{Protheus.doc} zVarPed
@author bolognesi
@since 14/07/2017
@version 1.0
@type function
@description Função especifica pedido, percorre os itens aCols,e utilizando
a classe cbcVarejoProduto o metodo isRetail, para definir se o produto é um produto de
varejo.
/*/
static function zVarPed()
	local cMsg			:= ''
	local nX			:= 0
	local oVarProd		:= nil
	local nTotVejo 		:= 0

	for nX := 1 To Len(aCols)
		if !GDDeleted(nX)
			if !empty(GDFieldGet("C6_PRODUTO",nX))
				nTotVejo += GDFieldGet("C6_VALOR",nX)
				oVarProd := cbcVarejoProduto():newcbcVarejoProduto()
				if ! oVarProd:isRetail(GDFieldGet("C6_PRODUTO",nX),GDFieldGet("C6_ACONDIC",nX),GDFieldGet("C6_METRAGE",nX))
					cMsg += 'ITEM: ' + Alltrim(GDFieldGet("C6_ITEM",nX)) + chr(13)
					cMsg += 'PRODUTO: ' + Alltrim(GDFieldGet("C6_PRODUTO",nX)) + chr(13)
				endif
			endif
		endif
	next nX
	cMsg += totalVarej(nTotVejo)

return(cMsg)


/*/{Protheus.doc} totalVarej
@author bolognesi
@since 28/08/2017
@version 1.0
@param nTotal, numeric, Total Documento
@type function
@description A partir da soma total de um documento (Orçamento/Pedido)
valida os totais para um documento de varejo.
/*/
static function totalVarej(nTotal)
	local nMinVarejo	:= GetNewPar("ZZ_MINVARE", 0)
	local nMaxVarejo	:= GetNewPar("ZZ_MAXVARE", 99999999999)
	local cMsg			:= ''
	if !U_isPortal()
		if nTotal < nMinVarejo 
			cMsg += "[TOTAL] - Valor total minimo do pedido de varejo é " + cValToChar(nMinVarejo) + chr(13)
		elseif nTotal > nMaxVarejo
			cMsg += "[TOTAL] - Valor total máximo do pedido de varejo é " + cValToChar(nMaxVarejo) + chr(13)
		endif
	endif
return(cMsg)


/*/{Protheus.doc} dtEntrVar
@author bolognesi
@since 28/08/2017
@version 1.0
@type function
@description Retornar o prazo do varejo com base no parametro
/*/
user function dtEntrVar()
	local nRet := 0
	if onVarejo
		nRet := GetNewPar("ZZ_PRZEVAR", 7)
	endif
return(nRet)

/*/{Protheus.doc} varejSyn
@author bolognesi
@since 17/07/2017
@version undefined
@type function
@description Utilizada para sincronizar campos do Orçamento(SCJ/SCK) com Pedido(SC6/SC6)
chamado pelo PE(MTA416PV())
/*/
user function varejSyn()
	if IsInCallStack('MABXORC')
		M->(C5_ZTPVEND)	:= M->(CJ_ZTPVEND)
	endif
return(nil)


/*/{Protheus.doc} ItemOrc
@author bolognesi
@since 29/08/2017
@version 1.0
@type function
@description Verificar de tem item no TMP01
condição que inválida a alteração do tipo varejo
/*/
static function ItemOrc()
	local lRet 	:= .T.
	local nX	:= 0
	DbSelectArea('TMP1')
	TMP1->(DbGoTop())
	While !TMP1->(eof())
		if  !empty( TMP1->(CK_PRODUTO) )
			lRet := .F.
			exit
		endif
		TMP1->(dbSkip())
	enddo
return(lRet)


/*/{Protheus.doc} ItemPed
@author bolognesi
@since 29/08/2017
@version 1.0
@type function
@description Verificar de tem item no acols
condição que inválida a alteração do tipo varejo
/*/
static function ItemPed()
	local lRet 	:= .T.
	local nX	:= 0
	for nX := 1 To Len(aCols)
		if !empty(GDFieldGet("C6_PRODUTO",nX))
			lRet := .F.
			exit
		endif
	next nX
return(lRet)


/*/{Protheus.doc} bkArea
@author bolognesi
@since 14/07/2017
@version 1.0
@type function
@description Função generica utilizada para guardar Area 
/*/
static function bkArea()
	static aArea1	:= {}
	static aArea2	:= {}
	static aArea3	:= {}

	If ORCAMENTO
		aArea1		:= TMP1->(getArea())
		aArea2		:= SCJ->(getArea())
		aArea3		:= SCK->(getArea())
	elseif PEDIDO
		aArea2		:= SC5->(getArea())
		aArea3		:= SC6->(getArea())
	endif
return(nil)

/*/{Protheus.doc} rstArea
@author bolognesi
@since 14/07/2017
@version 1.0
@type function
@description Função generica utilizada para restaurar Area 
/*/
static function rstArea()
	RestArea(aArea3) 
	RestArea(aArea2)
	if(!empty(aArea1),RestArea(aArea1),'')
return(nil)