#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch" 

//Fina070
//Rotina de Baixas a Receber 

//|--------------------------------------------------------------------------------------------------|
//|                                  BOTÃO  LOTE                                                     |
//|--------------------------------------------------------------------------------------------------|
*
***********************
User Function F070OWN()
	***********************
	*      
	//|-----------------------------------------------------------------------------------------|
	//| PE F070OWN                                                                              |     
	//| O ponto de entrada F070OWN sera executado durante a montagem                            |
	//| do filtro da baixa por lote do contas a receber                                         |
	//|-----------------------------------------------------------------------------------------|

	_cFiltro := 'E1_FILIAL=="' + xFilial("SE1") + '".And.'
	_cFiltro += 'DTOS(E1_VENCREA)>="' + DTOS(dVencDe)  + '".And.'
	_cFiltro += 'DTOS(E1_VENCREA)<="' + DTOS(dVencAte) + '".And.'
	_cFiltro += 'E1_NATUREZ>="'       + cNatDe         + '".And.'
	_cFiltro += 'E1_NATUREZ<="'       + cNatAte        + '".And.'
	_cFiltro += 'E1_PORTADO<>"000".AND.'
	_cFiltro += '!(E1_TIPO$"'+MVPROVIS+"/"+MVRECANT+"/"+MVIRABT+"/"+MVINABT+"/"+MV_CRNEG

	//Destacar Abatimentos
	If mv_par06 == 2
		_cFiltro += "/"+MVABATIM+'")'
	Else
		_cFiltro += '")'
	Endif

	// Verifica integracao com TMS e nao permite baixar titulos que tenham solicitacoes
	// de transferencias em aberto.
	_cFiltro += ' .And. Empty(E1_NUMSOL)'
	_cFiltro += ' .And. (E1_SALDO>0 .OR. E1_OK="xx")'

Return(_cFiltro)