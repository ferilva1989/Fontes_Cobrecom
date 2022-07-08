#include "rwmake.ch"
#include "protheus.ch"
#include "tbiconn.ch" 
#define CRLF Chr(13)+Chr(10)

*
**********************
User Function MT240TOK
	**********************
	*  
	// Validações do usuário para inclusão do movimento
	lRet := u_fValidD3()

Return(lRet)