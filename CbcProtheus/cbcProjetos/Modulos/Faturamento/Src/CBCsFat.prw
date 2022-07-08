#include 'protheus.ch'
#include 'parmtype.ch'

User Function ESP1NOME //SIGAESP1
Return ("CSFATUR")

user Function SIGAESP1()
	oApp:oMainWnd:CTRLREFRESH()
	U_CSFATUR()
	oApp:oMainWnd:END()
Return