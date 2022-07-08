#Include "Protheus.ch"
#include "tbiconn.ch"
#Define USERFUNCTION

//Define de nome da variavel global criada para a exclusao dos RPO's
#Define C_CLEANING 'AdvPlayL_Clear'

//Chave criada para ter certeza que o RPO foi gerado pelo AdvPlayL
#Define C_ADVPLAYL 'AdvPlayL'


//-------------------------------------------------------------------
/*/{Protheus.doc} RPO2
Classe RPO2, responsavel pela compilacao de fontes em ADVPL
/*/
//-------------------------------------------------------------------
Class RPO2
    Data oRPO
    Data cRPO
    Data lAberto
    Data cErrStr
    Data nErrLine
    Data cPathRPO
    Data cOriginRPO
    Data aPathInclude

    Method New() Constructor
    Method Open()
    Method Close()
    Method Reload()
    Method Compile(cFile, cSource)
    Method InitRpo()
    Method RestRpo()
EndClass


//-------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo de instancia da classe
/*/
//-------------------------------------------------------------------
Method New(cRPO) Class RPO2
    Self:cRPO     := cRPO
    Self:lAberto  := .F.
    Self:nErrLine := 0
    Self:cErrStr  := ""
    Self:oRPO     := Nil
    Self:cPathRPO     := AllTrim( GetSrvProfString( 'RPOCUSTOM'  , '' ) )  
    Self:cOriginRPO   := AllTrim( GetSrvProfString( 'SOURCEPATH' , '' ) )  
    Self:aPathInclude := StrTokArr( AllTrim( GetSrvProfString( 'DIRINCLUDE' , '' ) ) , ';' )
    If !Empty( Self:cPathRPO )
        If Right( Self:cPathRPO , 1 ) != Iif( IsSrvUnix() , '/' , '\' )
            Self:cPathRPO += Iif( IsSrvUnix() , '/' , '\' )
        EndIf
    EndIf
    If !Empty( Self:cOriginRPO )
        If Right( Self:cOriginRPO , 1 ) != Iif( IsSrvUnix() , '/' , '\' )
            Self:cOriginRPO += Iif( IsSrvUnix() , '/' , '\' )
        EndIf
    EndIf
    Self:cOriginRPO += 'tttp120.rpo'
Return Self


//-------------------------------------------------------------------
/*/{Protheus.doc} Open
Metodo de abertura do RPO

/*/
//-------------------------------------------------------------------
Method Open() Class RPO2
    Local lRet := .T.
    If ! Self:lAberto
        Self:oRPO := RPO():New(.T.)

        //Definicao dos includes
        Self:oRPO:Includes   := Self:aPathInclude
        //Define padrao para ambiente TOP, esse include ja adiciona o Protheus.ch
        Self:oRPO:MainHeader := 'PRTOPDEF.CH'

        If Self:oRPO:Open( Self:cPathRPO + Self:cRPO )
            Self:lAberto := .T.
            lRet := .T.
        Else
            lRet := .F.
        EndIf
    EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Close
Metodo responsavel por fechar voltar repositorio padrão
/*/
//-------------------------------------------------------------------
Method RestRpo() Class RPO2
     Local lRet := .T.
        Self:oRPO:Close()
        //Self:oRPO := RPO():New()
        /*
        If Self:oRPO:Open(Self:cOriginRPO)
            lRet := .T.
            Self:oRPO:Close()
        Else
            lRet := .F.
        EndIf
        */
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Close
Metodo responsavel por fechar o RPO apos o uso

/*/
//-------------------------------------------------------------------
Method Close() Class RPO2
    Local lRet := .T.
    If Self:lAberto
        If (lRet := Self:RestRpo())
            Self:lAberto := .F.
        Else
            lRet := .F.
        EndIf
    EndIf
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Reload
Metodo que efetua um refresh no RPO
/*/
//-------------------------------------------------------------------
Method Reload() Class RPO2
Return Self:Close() .And. Self:Open()

//-------------------------------------------------------------------
/*/{Protheus.doc} Compile
Metodo responsavel pela compilacao no RPO
/*/
//-------------------------------------------------------------------
Method Compile(cFile, cSource) Class RPO2
    Local cPreC := ''
    Local aDeps := {}
    Local nDate := Date() - SToD("19991231")

    If ! Self:Open()
        Return .F.
    EndIf

    If ! Self:oRPO:StartBuild( .T. )
        Self:Reload()
        Return .F.
    EndIf
    // A pre-compilacao nao e obrigatoria, porem trata diversas
    // questoes no fonte, XCOMMAND, XTRANSLATE...
    If Self:oRPO:PreComp( cFile , cSource , @cPreC , @aDeps )
        cSource := cPreC
    Else
        Self:Reload()

        If ! Self:oRPO:StartBuild( .T. )
            Return .F.
        EndIf
    EndIf
    If ! Self:oRPO:Compile( cFile , cSource , nDate , Self:oRPO:ChkSum( cSource ) )
        Self:cErrStr  := Self:oRPO:ErrStr
        Self:nErrLine := Self:oRPO:ErrLine
        Self:Reload()
        Return .F.
    EndIf
    If ! Self:oRPO:EndBuild()
        Self:Reload()
        Return .F.
    EndIf
Return Self:Reload()
//-------------------------------------------------------------------
/*/{Protheus.doc} Compile
Metodo responsavel pela inicializacao no RPO
/*/
//-------------------------------------------------------------------
Method InitRpo() Class RPO2
    Self:Open()
return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} Stdout
Funcao que permite a impressao de valores no AdvPlayl
/*/
//-------------------------------------------------------------------
#IfDef USERFUNCTION
User Function Stdout(cMessage)
#Else
Function Stdout(cMessage)
#EndIf
    cOutput += AsString(cMessage)
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} SaveFile
Funcao responsavel por salvar os fontes
/*/
//-------------------------------------------------------------------
User Function SaveFile( cFilename , cContent )
    Local cFile := "./runtime/fontes"
    Local nFile := 0
    MakeDir( cFile )
    cFile += "/" + cFilename + ".prw"
    nFile := FCreate( cFile )
    FWrite( nFile , cContent )
    FClose( nFile )
Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} LoadFile
Funcao responsavel por ler um fonte ja existente
/*/
//-------------------------------------------------------------------
User Function LoadFile(__aProcParms)
    Local cContent := ""
    Local nI       := 0
    Local cName    := ""
    Local cValue   := ""
    Local cFile    := "./runtime/fontes"

    // pegando parametros do get
    For nI := 1 To  Len(__aProcParms)
        cName := Lower(__aProcParms[nI][1])
        cValue := __aProcParms[nI][2]

        If cName == "arquivo"
            cFile += "/" + cValue
        EndIf
    Next nI

    // lendo arquivo default
    If cFile == "./runtime/fontes"
        cFile += "/default.prw"
    EndIf

    // lendo conteudo do arquivo
    nFile := FOpen(cFile)
    If nFile > -1
        FRead(nFile, @cContent, 8192)
        FClose(nFile)
    EndIf
Return cContent


//-------------------------------------------------------------------
/*/{Protheus.doc} Runtime
Funcao que compila e executa o codigo ADVPL
/*/
//-------------------------------------------------------------------
User Function xzRuntime(__aCookies, __aPostParms, __nProcID, __aProcParms, __cHTTPPage)
    Local nI      := 0
    Local cName   := ""
    Local cValue  := ""
    Local cUUID   := ""
    Local cCodigo := ""
    Local oRPO2   := Nil
    Local cOutput := Nil
    
    For nI := 1 To Len(__aPostParms)
        cName := Lower(__aPostParms[nI][1])
        cValue := __aPostParms[nI][2]
        If cName == "uuidv4"
            cUUID := cValue
        ElseIf cName == "codigo"
            cCodigo := cValue
        ElseIf cName == "arquivo"
            cArquivo := cValue
        EndIf
    Next nI

    If !Empty(cArquivo)
        U_SaveFile(cArquivo, cCodigo)
    EndIf
    oRPO2 := RPO2():New( cUUID + C_ADVPLAYL + ".rpo" )
    If ! oRPO2:Compile( cUUID + C_ADVPLAYL + ".prw" , cCodigo )
        cOutput := oRPO2:cErrStr
    EndIf
    oRPO2:Close()
Return cOutput


User Function zxExRuntm(cEntry)
    local oRPO2     := nil
    local bErro     := nil
    local cOutput   := ''
    default cEntry  := 'u_xzCbTeste()'
    oRPO2 := RPO2():New( 'CUSTOM' + C_ADVPLAYL + ".rpo" )
    oRPO2:InitRpo()
    bErro := ErrorBlock( {|oError| cOutput := oError:ErrorStack} )
        Begin Sequence
            &(cEntry)
        End Sequence
    ErrorBlock(bErro)
    oRPO2:Close()
    FreeObj(oRPO2)
return cOutput


/*
    1-) Adicionar no appserver.ini 
        [HTTP]
        ENABLE=1
        PORT=8672
        PATH=D:\Totvs_12\ERP\Protheus_Data\runtime
        ENVIRONMENT=P_12RTM

    2-) Criar estrutura
        D:\Totvs_12\ERP\Protheus_Data\runtime
            apo
            fontes
            includes <- Colocar os includes neste diretorio
    3-) Compilar os fontes
        advplRunTime
            cbc_editor.aph
            cbc_explorer.aph
            cbc_runtime.prw
    
    acessar url (http://192.168.1.220:8672/h_cbc_editor.apl)
    Uma vez compilados os fontes nesta aplicação web eles são adicionados ao repositorio
    auxiliar e um arquivo fonte prw criado na pasta

*/

user function zxleoTes()
    PREPARE ENVIRONMENT EMPRESA "01" FILIAL "01"
    SE2->(DbGoto(370541))
    FRTCONPOS("SE2",370541)
    FMRGETRET()
    FMRGetArr("1")
    alert('oi')
    RESET ENVIRONMENT
return nil
