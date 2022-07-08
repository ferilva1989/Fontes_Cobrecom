#include 'protheus.ch'
#include 'fileio.ch'


class FileSystem 

	data lOk
	data cMsg

	method newFileSystem() constructor 
	method compress()
	method uncompress()

endclass


method newFileSystem() class FileSystem

return (Self)

method uncompress() class FileSystem
	Local cDstPath 	:= '\espelhoPedido\decompress\'
	Local lTemZip	:= .F.
	Local bErro 
	Local aPrmBox	:= {}
	Local cExt		:= ""
	Local aRet 		:= {}

	If U_IsAuto()
		u_autoAlert('[AVISO] - Metodo uncompress() da Classe FileSystem não pode ser utilizado em rotinas automáticas.')
	Else

		lTemZip := FindFunction('FZip') 

		aAdd(aPrmBox,{6,"Arquivo compactado:",Space(50),"","","",50,.T.	,"Todos os arquivos (*.*) |*.*",'\espelhoPedido\enviado' })
		aAdd(aPrmBox,{6,"Descompactar em:"	 ,Space(50),"","","",50,.T.	,"Todos os arquivos (*.*) |*.*",'\espelhoPedido\decompress',GETF_RETDIRECTORY })

		If ParamBox(aPrmBox ,"Descompreção de Arquivos ",@aRet)      
			cExt := Right(Alltrim(aRet[1]) , 3)
			bErro	:= ErrorBlock({|oErr| HandleEr(oErr)})

			BEGIN SEQUENCE		
				If Lower(cExt) == 'mzp'
					If ! MsDecomp(Alltrim(aRet[1]), Alltrim(aRet[2]))
						u_autoAlert('Arquivo não descompactado verifique.',,'Box',,48)
					Else	
						u_autoAlert('Descompactado com sucesso.',,'Box',,1)
					EndIf
				ElseIf Lower(cExt) := 'zip'
					If !lTemZip
						u_autoAlert('Build não suporta descompactar arquivos com extenção zip.',,'Box',,48)
					Else
						If FUnZip(Alltrim(aRet[1]), Alltrim(aRet[2])) != 0
							u_autoAlert('Arquivo não descompactado verifique.',,'Box',,48)
						Else
							u_autoAlert('Descompactado com sucesso.',,'Box',,1)
						EndIf
					EndIf
				Else
					u_autoAlert('Suportado apenas arquivos com extenções (ZIP/MZP).',,'Box',,48)
				EndIf  
				RECOVER
			END SEQUENCE
			ErrorBlock(bErro)   
		EndIf
	EndIf
return (self)

method compress(cPath,cArquivo,cPathDst,cFileDst) class FileSystem
	Local Files 		:= {}
	Local cFile			:= DtoS(Date()) + '_'
	Local bErro 
	Default cPath		:= "\espelhoPedido\"
	Default cArquivo	:= ""
	Default cPathDst	:= "\espelhoPedido\enviado\" 
	Default cFileDst	:= cFile += "compress"

	::lOk 	:= .T.
	::cMsg	:= ""

	bErro	:= ErrorBlock({|oErr| HandleEr(oErr)})
	BEGIN SEQUENCE	
		If Empty(cArquivo)
			::lOk 	:= .F.
			::cMsg	:= "[ERRO] - Parametro cArquivo obrigatorio,"
		Else
			Files := {cPath + cArquivo} 
			If FindFunction('FZip')
				U_autoAlert('[AVISO] - Função FZip agora está disponivel, avisar T.I')
				If FZip(cPathDst + cFileDst ,Files) != 0
					::lOk 	:= .F.
					::cMsg	:= "[ERRO] - Arquivo não compactado"
				EndIf
			Else

				If Empty(MsCompress((cPath + cArquivo), (cPathDst + cFileDst)))
					::lOk 	:= .F.
					::cMsg	:= "[ERRO] - Arquivo não compactado"
				EndIf

			EndIf
		EndIf

		If ::lOk
			FErase(cPath + cArquivo)
		EndIf  
		RECOVER
	END SEQUENCE
	ErrorBlock(bErro) 

return (self)

Static function HandleEr(oErr)
	ConsoleLog('[' + oErr:Description + ']' + oErr:ERRORSTACK)
	u_autoAlert('[' + oErr:Description + ']' + oErr:ERRORSTACK,,'Box',,48)
	BREAK
return

static function ConsoleLog(cMsg)
	ConOut("[Descompressão arquivo - "+DtoC(Date())+" - "+Time()+" ] "+cMsg) 
return