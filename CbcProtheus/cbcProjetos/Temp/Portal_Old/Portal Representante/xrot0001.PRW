#include 'totvs.ch'
/*
ROBERT SANTOS
16 DE AGOSTO DE 2012
MANUSEAR TABELA DE INFORMACOES DO GESTOR PARA OS REPRESENTANTES VIA SITE
*/
user function xrot0001()

private ccadastro := "Mensagens Via Site"

private arotina := {}
AADD( aRotina, {"Pesquisar"		,"AxPesqui" ,0,1})
AADD( aRotina, {"Visualizar"	,'AxVisual',0,2})
AADD( aRotina, {"Incluir"		,'AxInclui',0,3})
AADD( aRotina, {"Alterar"		,'AxAltera',0,4})
AADD( aRotina, {"Excluir"		,'AxDeleta',0,5})

dbselectarea("ZZJ") // apenas abrir a tabela
dbselectarea("ZZK") // apenas abrir a tabela

dbselectarea("ZZB")// tabela de mensagens do gestor
dbsetorder(1)
dbgotop()
mbrowse(,,,,"ZZB")

return nil
