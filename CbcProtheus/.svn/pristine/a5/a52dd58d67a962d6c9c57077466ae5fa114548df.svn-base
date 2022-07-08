#include 'protheus.ch'

/*	Validacao do site para Acondicionamento x Produto
	Robert Santos
	13 jun 2012
	
	Retorno padrao
	x[1] := .t. => ok || .f. => nao ok
	x[2] := Mensagem em tela no caso de nao OK
	*/         
user function StVld01( _cAcondic, _nMetrage, _cProduto )

local adados	:= { .F. , "NAO INICIADO" }   
local _nmax		:= 0      
local _lret		:= .f. 
local cmsg		:= ""

default _cAcondic	:= ""
default _nMetrage	:= 0
default _cProduto	:= ""     

// inicializacao
_lret	:= .t.
cmsg	:= "OK"
        
dbselectarea("SB1") 

If !Empty(_cAcondic) .And. !Empty(_nMetrage)

	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+_cProduto,.F.))
	_nMax := 0

	If _cAcondic == "R"
		_nMax := SB1->B1_ROLO
	ElseIf _cAcondic == "B"
		_nMax := SB1->B1_BOBINA
  	ElseIf _cAcondic == "C"
   		_nMax := SB1->B1_CARRETE
  	ElseIf _cAcondic == "M"
   		_nMax := SB1->B1_CARMAD
  	ElseIf _cAcondic == "T" // Retalho
  		_nMax := 99
    EndIf            
                
    If _nMax <= 0
   		cmsg := "Produto não comercializado nesta metragem." // "Informar a Metragem Máxima para o Acondicionamento!"
   	ElseIf (_nMax < _nMetrage)
    	cmsg := ("Metragem Máxima para Esse Acondicionamento é de " + Transform(_nMax,"@E 99,999") + " Metros.")
     EndIf
     _lRet := (_nMax >= _nMetrage)

	//	If _cAcondic $ "CM" .And. SB1->B1_QTDCAR > 0 .And. _nMetrage # SB1->B1_QTDCAR
	If (_cAcondic == "C" .And. SB1->B1_CARRETE # _nMetrage)
 		cmsg := ("Esse Produto em Carretel é Obrigatório Metragem Exata em " + Transform(SB1->B1_CARRETE,"@E 99,999") + " metros.")
 		_lRet := .F.                                       
 	ELSEIF (_cAcondic == "M" .And. _nMetrage # SB1->B1_CARMAD)
 		cmsg := ("Esse Produto em Carretel Madeira é Obrigatório Metragem Exata em " + Transform(SB1->B1_CARMAD,"@E 99,999") + " metros.")
 		_lRet := .F.                                       
  	EndIf   
else
	_lret	:= .f.
	cmsg	:= "Favor preencher o campo de Acondicionamento e Metragem."
EndIf      
     
// retorno
adados[1] := _lret 
adados[2] := cmsg

return adados