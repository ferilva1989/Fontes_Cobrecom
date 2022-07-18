#include 'protheus.ch'

/*/{Protheus.doc} User Function colsGrids
   (long_description)
    @type  Function
    @author Filipe Silva
    @since 18/07/2022
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/

User Function colsGrids()
	Local dDatPrf := POSICIONE("SC7", 6, xFilial("SC1") + C1_PRODUTO + C1_FORNECE + C1_LOJA + C1_NUM + C1_ITEM + C1_ITEMGRD, "C7_DATPRF")
Return dDatPrf
