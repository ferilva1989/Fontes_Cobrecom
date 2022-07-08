#include 'protheus.ch'
#include 'parmtype.ch'

static function defFldTab()
	local aFld	:= { 	{'FILIAL', 	'C', 	TamSx3('F2_FILIAL')[1], 0},;
						{'DOC', 	'C', 	TamSx3('F2_DOC')[1], 	0},;
						{'SERIE', 	'C', 	TamSx3('F2_SERIE')[1], 	0},;
						{'CLI', 	'C', 	TamSx3('F2_CLIENTE')[1],0},;
						{'LOJA', 	'C', 	TamSx3('F2_LOJA')[1],	0},;
						{'NOME', 	'C', 	TamSx3('A1_NOME')[1],	0},;
						{'EMISSAO', 'D', 	TamSx3('F2_EMISSAO')[1],0},;
		 				{'OK',		'C',	TamSx3('C9_OK')[1],		0};
		 	         }
return(aFld)

static function defFldBrw()
	local aFld	:= {	{'Filial', 	{|| (cAls)->(FILIAL)}, 	'C', PesqPict( 'SF2', 'F2_FILIAL' ), 	1, TamSx3('F2_FILIAL')[1], 	0},;
						{'Num.Doc', {|| (cAls)->(DOC)}, 	'C', PesqPict( 'SF2', 'F2_DOC' ), 	 	1, TamSx3('F2_DOC')[1], 	0},;
						{'Serie', 	{|| (cAls)->(SERIE)}, 	'C', PesqPict( 'SF2', 'F2_SERIE' ),  	1, TamSx3('F2_SERIE')[1], 	0},;
						{'Cli.', 	{|| (cAls)->(CLI)}, 	'C', PesqPict( 'SF2', 'F2_CLIENTE' ),  	1, TamSx3('F2_CLIENTE')[1], 0},;
						{'Loja', 	{|| (cAls)->(LOJA)}, 	'C', PesqPict( 'SF2', 'F2_LOJA' ),  	1, TamSx3('F2_LOJA')[1], 	0},;
						{'Nome', 	{|| (cAls)->(NOME)}, 	'C', PesqPict( 'SA1', 'A1_NOME' ),  	1, TamSx3('A1_NOME')[1], 	0},;
						{'Emissão', {|| (cAls)->(EMISSAO)}, 'D', PesqPict( 'SF2', 'F2_EMISSAO' ),  	1, TamSx3('F2_EMISSAO')[1], 0};						
					}
return(aFld)