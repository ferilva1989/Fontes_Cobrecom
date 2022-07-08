#include 'protheus.ch'
#include 'parmtype.ch'
#include "Totvs.ch"
#include "RPTDef.ch"
#include "FWPrintSetup.ch"
#include 'cbcOrdemSep.ch'
#include 'cbcOrdemCar.ch'

//Alinhamentos
#define PAD_LEFT    0
#define PAD_RIGHT   1
#define PAD_CENTER  2

//Cores
#define COR_CINZA   RGB(180, 180, 180)
#define COR_PRETO   RGB(000, 000, 000)
#define COR_BRANCO  RGB(255, 255, 255)

//Colunas
#define COL_GRUPO   0015
#define COL_DESCR   0095
#define COL_DATA   	0015
#define COL_ASSINA  0095
#define ARRAY_CABECA	{{'NF', 55}, {'OS',50},{'CLIENTE',145},{'FARDOS',40}, {'CARRET.',40}, {'BOBINAS',40}, {'PALETES',40}, {'CAIXAS',40}, {'ROLOS',40}, {'PESO TOTAL',50}}

#define MAXBOXV	100

user function cbcRptManifesto(cMyCarga, aMyVol) //cbcRptManifesto('00000007')
    Local oStatic       := IfcXFun():newIfcXFun()
    private cCarga      := ''
    private aVolumes    := {}
    private oCarga      := cbcCtrlCarga():newcbcCtrlCarga()
    private lManif      := .F.
    default cMyCarga	:= ''
    default aMyVol      := {}

    cCarga := cMyCarga
    oStatic:sP(1):callStatic('cbcPlanFatur', 'PergCarga', @cCarga)

    if !empty(cCarga)
        oCarga:define(cCarga)
        lManif := (oCarga:getStatus() == CARGA_FATURADA)
        aVolumes := oStatic:sP(2):callStatic('cbcManifesto', 'getVol', cCarga, aMyVol)
        Processa({|| fMontaRel()}, "Processando...")
    endif

    FreeObj(oCarga)
return(nil)

static function fMontaRel()
    local cCaminho    := ""
    local cArquivo    := ""
    local nAtual      := 0
    local nTotal      := 0
    local nY		  := 0
    local nCIni		  := 0
    local xValue      := ''
    local aTotais	  := {}
    local aDadosDet   := {}
    Local oStatic   := IfcXFun():newIfcXFun()
    private cLogo	  := '\logo-cobrecom.png'
    //Linhas e colunas
    private nLinAtu   := 000
    private nTamLin   := 010
    private nLinFin   := 820
    private nColIni   := 010
    private nColFin   := 550
    //Objeto de Impressão
    private oPrintPvt
    //Variáveis auxiliares
    private dDataGer  := Date()
    private cHoraGer  := Time()
    private nPagAtu   := 1
    private cNomeUsr  := UsrRetName(RetCodUsr())
    //Fontes
    private cNomeFont := "Arial"
    private oFontDet  := TFont():New(cNomeFont, 9, -10, .T., .F., 5, .T., 5, .T., .F.)
    private oFontDetN := TFont():New(cNomeFont, 9, -10, .T., .T., 5, .T., 5, .T., .F.)
    private oFontRod  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
    private oFontTit  := TFont():New(cNomeFont, 9, -20, .T., .T., 5, .T., 5, .T., .F.)
    private oFontTit2 := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
    private oBrush 	  := TBrush():New( , CLR_BLACK )

    //Definindo o diretório como a temporária do S.O. e o nome do arquivo com a data e hora (sem dois pontos)
    cCaminho  := GetTempPath()
    cArquivo  := "cbcManif_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')

    //Criando o objeto do FMSPrinter
    oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrintPvt, "", , , , .T.)

    //Setando os atributos necessários do relatório
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    //oPrintPvt:SetLandscape()
    oPrintPvt:SetPaperSize(DMPAPER_A4)
    oPrintPvt:SetMargin(60, 60, 60, 60)

    //Carregar Dados
    oStatic:sP(4):callStatic('cbcManifesto', 'mntDados', 'RES', nil, @aTotais,   aVolumes)
    oStatic:sP(4):callStatic('cbcManifesto', 'mntDados', 'DET', nil, @aDadosDet, aVolumes)

    //Imprime o cabeçalho
    fImpCab(aTotais)

    //Conta o total de registros, seta o tamanho da régua, e volta pro topo
    nTotal := len(aDadosDet)
    ProcRegua(nTotal)
    nAtual := 1
    //Enquanto houver registros
    While nAtual <= nTotal
        IncProc("Imprimindo..." + 'CARGA' + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")

        //Se a linha atual mais o espaço que será utilizado forem maior que a linha final, imprime rodapé e cabeçalho
        if nLinAtu + (nTamLin + 005) > nLinFin
            fImpRod()
            fImpCab(aTotais)
        endif

        //Imprimindo a linha atual
        for nY := 1 to len(aDadosDet[nAtual])
            nCIni := if(nY == 1, nColIni, nCIni)
            oPrintPvt:Box(nLinAtu,nCIni,nLinAtu + (nTamLin + 005), nCIni + ARRAY_CABECA[nY,2])
            xValue := aDadosDet[nAtual, nY]
            if ValType(xValue) == 'N'
                xValue := Round(xValue, 2)
            endif
            if ValType(xValue) <> 'C'
                xValue := cValToChar(xValue)
            endif
            oPrintPvt:SayAlign(nLinAtu+002, nCIni+002, xValue, oFontDet, ARRAY_CABECA[nY,2], (nTamLin + 005), COR_PRETO, PAD_LEFT, 0)
            nCIni += ARRAY_CABECA[nY,2]
        next nY
        nLinAtu += (nTamLin + 005)
        nAtual++
    EndDo
    //Se ainda tiver linhas sobrando na página, imprime o rodapé final
    if nLinAtu <= nLinFin
        fImpRod()
    endif
    //Mostrando o relatório
    oPrintPvt:Preview()
return(nil)

static function fImpCab(aTotais)
    local cTexto	:= ''
    local nLinCab	:= 030
    local cTransp	:= ''
    local nX		:= 0
    local aCabec	:= ARRAY_CABECA

    //Iniciando Página
    oPrintPvt:StartPage()

    //Cabeçalho
    if lManif
        cTexto := 'MANIFESTO DE CARGA'
    else
        cTexto := 'RESUMO DE CARGA'
    endif

    cTransp := oCarga:getTransp()[2]
    //lManif := .T.
    if nPagAtu == 1
        if lManif
            oPrintPvt:Box(nLinCab,nColIni,MAXBOXV,450)
            oPrintPvt:Box(nLinCab,450,MAXBOXV,nColFin)
            //nLinCab += nTamLin
            oPrintPvt:SayAlign(nLinCab, COL_DATA, "DATA", oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinCab, COL_ASSINA, "IDENTIFICAÇÃO E ASSINATURA DO MOTORISTA", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinCab + nTamLin, 460, "Nº CARGA", oFontTit, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
            nLinCab += nTamLin
            oPrintPvt:Line(nLinCab, nColIni, nLinCab, 450, COR_PRETO)
            nLinCab := (MAXBOXV / 2) + 015
            oPrintPvt:Line(nLinCab, nColIni, nLinCab, 450, COR_PRETO)
            oPrintPvt:SayAlign(nLinCab, COL_DATA, "DATA", oFontDetN, 0080, nTamLin, COR_PRETO, PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinCab, COL_ASSINA, "IDENTIFICAÇÃO E ASSINATURA DO CONFERENTE", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
            oPrintPvt:SayAlign(nLinCab + nTamLin, 460, cCarga, oFontTit, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
            nLinCab += nTamLin

            oPrintPvt:Line(nLinCab, nColIni, nLinCab, 450, COR_PRETO)
            nLinCab := (MAXBOXV)
            oPrintPvt:SayAlign(nLinCab, 000, Replicate("- ", nColFin), oFontDetN, (nColFin + nTamLin), nTamLin, COR_PRETO, PAD_LEFT, 0)
            nLinCab += nTamLin + 005
        endif

        oPrintPvt:Box(nLinCab,nColIni,(nLinCab + MAXBOXV),110)
        oPrintPvt:SayBitmap( nLinCab + 030, nColIni + 003, cLogo, 95, 30)

        oPrintPvt:Box(nLinCab,110,(nLinCab + MAXBOXV),nColFin)
        oPrintPvt:FillRect({nLinCab,110,iif(lManif, (MAXBOXV)+035, (MAXBOXV)-050),nColFin},oBrush)
        oBrush:End()
        oPrintPvt:SayAlign(nLinCab+005, 110, cTexto, oFontTit2, (nColFin - 110), 20, COR_BRANCO, PAD_CENTER, 0)
        oPrintPvt:Box(nLinCab+020,110,(nLinCab + MAXBOXV),((nColFin-110)/2)+110)
        oPrintPvt:SayAlign(nLinCab+025, 110, "TRANSPORTE:", oFontTit2, (nColFin - 110)/2, 20, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:SayAlign(nLinCab+045, 110, RTrim(cTransp), oFontTit2, (nColFin - 110)/2, 20, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:SayAlign(nLinCab+025, 110+((nColFin - 110)/2), "Nº CARGA:" + cCarga, oFontTit2, (nColFin - 110)/2, 20, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:Code128(nLinCab+045, 120+((nColFin - 110)/2) + 045, cCarga, 50,50/*nHeigth*/,.T./*lSay*/,,110)

        nLinCab := iif(lManif, (MAXBOXV * 2), MAXBOXV)
        nLinCab += 015
        oPrintPvt:Box(nLinCab,nColIni,(nLinCab + (MAXBOXV / 3)),nColFin)
        oPrintPvt:FillRect({nLinCab,nColIni,iif(lManif, (MAXBOXV*2)+035, MAXBOXV+035),nColFin},oBrush)
        oBrush:End()
        oPrintPvt:SayAlign(nLinCab+005, nColIni, 'Informações da Carga', oFontTit2, nColFin, 20, COR_BRANCO, PAD_CENTER, 0)
        nLinCab += 020
        oPrintPvt:Box(nLinCab,nColIni,(nLinCab + 015),075)
        oPrintPvt:SayAlign(nLinCab, nColIni, "FARDOS", oFontDetN, 075, 10, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:Box(nLinCab,075,(nLinCab + 015),075*2)
        oPrintPvt:SayAlign(nLinCab, 075, "CARRETEIS", oFontDetN, 075, 10, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:Box(nLinCab,075*2,(nLinCab + 015),075*3)
        oPrintPvt:SayAlign(nLinCab, 075*2, "BOBINAS", oFontDetN, 075, 10, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:Box(nLinCab,075*3,(nLinCab + 015),075*4)
        oPrintPvt:SayAlign(nLinCab, 075*3, "PALETES", oFontDetN, 075, 10, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:Box(nLinCab,075*4,(nLinCab + 015),075*5)
        oPrintPvt:SayAlign(nLinCab, 075*4, "CAIXAS", oFontDetN, 075, 10, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:Box(nLinCab,075*5,(nLinCab + 015),075*6)
        oPrintPvt:SayAlign(nLinCab, 075*5, "ROLOS", oFontDetN, 075, 10, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:Box(nLinCab,075*6,(nLinCab + 015),nColFin)
        oPrintPvt:SayAlign(nLinCab, 075*6, "PESO TOTAL", oFontDetN, nColFin - (075*6), 10, COR_PRETO, PAD_CENTER, 0)
        nLinCab += 015
        for nX := 1 to len(aTotais[01])
            oPrintPvt:Box(nLinCab,if(nX == 1,nColIni ,(075 * (nX-1))),nLinCab + 020,if(nX == len(aTotais[01]),nColFin,(075 * nX)))
            oPrintPvt:SayAlign(nLinCab,if(nX == 1,nColIni ,(075 * (nX-1))), cValToChar(Round(aTotais[01, nX],2)), oFontTit2, if(nX == len(aTotais[01]),(nColFin-(075 * (nX-1))),075), 10, COR_PRETO, PAD_CENTER, 0)
        next nX
        nLinCab := iif(lManif, (MAXBOXV * 2) + (MAXBOXV / 2)+ 005, (MAXBOXV) + (MAXBOXV / 2) + 005)
    endif

    //Cabeçalho das colunas
    nLinCab += 013
    oPrintPvt:Box(nLinCab,nColIni,(nLinCab + 040),nColFin)
    oPrintPvt:FillRect({nLinCab,nColIni,nLinCab+020,nColFin},oBrush)
    oBrush:End()
    oPrintPvt:SayAlign(nLinCab+003, nColIni, 'Itens da Carga', oFontTit2, nColFin, 20, COR_BRANCO, PAD_CENTER, 0)
    nLinCab += 020
    nCIni := 0
    for nX := 1 to len(aCabec)
        nCIni := if(nX == 1, nColIni, nCIni)
        oPrintPvt:Box(nLinCab,nCIni,(nLinCab + 020),nCIni + aCabec[nX,2])
        oPrintPvt:SayAlign(nLinCab + 005, nCIni, aCabec[nX,1], oFontRod, aCabec[nX,2], 015, COR_PRETO, PAD_CENTER, 0)
        nCIni += aCabec[nX,2]
    next nX
    //Atualizando a linha inicial do relatório
    nLinAtu := nLinCab + 020
return(nil)

static function fImpRod()
    local nLinRod   := nLinFin + nTamLin
    local cTextoEsq := ''
    local cTextoDir := ''

    //Linha Separatória
    oPrintPvt:Line(nLinRod, nColIni, nLinRod, nColFin, COR_CINZA)
    nLinRod += 3

    //Dados da Esquerda e Direita
    cTextoEsq := dToC(dDataGer) + "    " + cHoraGer + "    " + 'cbcPrintManif' + "    " + cNomeUsr
    cTextoDir := "Página " + cValToChar(nPagAtu)

    //Imprimindo os textos
    oPrintPvt:SayAlign(nLinRod, nColIni,    cTextoEsq, oFontRod, 200, 05, COR_CINZA, PAD_LEFT,  0)
    oPrintPvt:SayAlign(nLinRod, nColFin-40, cTextoDir, oFontRod, 040, 05, COR_CINZA, PAD_RIGHT, 0)

    //Finalizando a página e somando mais um
    oPrintPvt:EndPage()
    nPagAtu++
return(nil)
