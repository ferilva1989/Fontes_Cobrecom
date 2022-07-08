#include 'protheus.ch'
#include 'parmtype.ch'
#include "Totvs.ch"
#include "RPTDef.ch"
#include "FWPrintSetup.ch"

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
//#define ARRAY_CABECA	{{'NF', 55}, {'OS',50},{'CLIENTE',145},{'FARDOS',40}, {'CARRET.',40}, {'BOBINAS',40}, {'PALETES',40}, {'CAIXAS',40}, {'ROLOS',40}, {'PESO TOTAL',50}}

#define MAXBOXV	100

user function cbcRptCImp(cJson)
    private oReq        := JsonObject():new()
    default cJson       := ''

    if empty(cJson)
        cJson := u_cbcViewImpost(.F.)
    endif

    oReq:FromJson(cJson)
    if !empty(oReq:GetNames())
    //TODO IF EXCEL
        Processa({|| fMontaRel()}, "Processando...")
    endif

    FreeObj(oReq)
return(nil)

static function fMontaRel()
    local cCaminho    := ""
    local cArquivo    := ""
    local nAtual      := 0
    local nTotal      := 0
    local nY		  := 0
    local nCIni		  := 0
    local aHeader     := {}
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
    //private oFontDet  := TFont():New(cNomeFont, 9, -10, .T., .F., 5, .T., 5, .T., .F.)
    private oFontDetN := TFont():New(cNomeFont, 9, -10, .T., .T., 5, .T., 5, .T., .F.)
    private oFontRod  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
    private oFontTit  := TFont():New(cNomeFont,,16,,.T.)
    private oFontTRes := TFont():New(cNomeFont,,13,,.T.)
    private oFontDRes := TFont():New(cNomeFont,,11,,.F.)
    private oFontPar  := TFont():New(cNomeFont,,10,,.T.)
    private oFontDet  := TFont():New(cNomeFont,,06,,.F.)
    private oFontTit2 := TFont():New(cNomeFont, 9, -10, .T., .T., 5, .T., 5, .T., .F.)
    private oBrush 	  := TBrush():New( , CLR_BLACK )

    //private oFont	    := TFont():New("Arial",,15,,.F.)

    //Definindo o diretório como a temporária do S.O. e o nome do arquivo com a data e hora (sem dois pontos)
    cCaminho  := GetTempPath()
    cArquivo  := "cbcCalcImp_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')

    //Criando o objeto do FMSPrinter
    oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrintPvt, "", , , , .T.)

    //Setando os atributos necessários do relatório
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    //oPrintPvt:SetLandscape()
    oPrintPvt:SetPaperSize(DMPAPER_A4)
    oPrintPvt:SetMargin(60, 60, 60, 60)

    aHeader := {;
        {"nitem", 'Item', 20},; 
        {"cProduto",'Produto', 120},;
        {"nQuant",'Qtd',40},;
        {"nVlrUnit",'Vl.Un.',40},;
        {"nVlrTotal",'Vl.Tot.',40},;
        {"nBasICM",'Bas.Icm' ,40},;
        {"nAlqICM",'Alq.Icm',40},;
        {"nValICM",'Vl.Icm',40},;		
		{"nBasSol",'Bas.Sol',40},;
        {"nPrcUniSol", 'VUn.Sol', 40},;
        {"nValSol",'Vl.Sol', 40},;
        {"nTotSol", 'Tot.Sol', 40};		
        }

    //Imprime o cabeçalho
    fImpCab(oReq['dados']['cliente']['SA1'], oReq['impostos'], aHeader)

    //Conta o total de registros, seta o tamanho da régua, e volta pro topo
    nTotal := len(oReq['impostos']['aItm'])
    ProcRegua(nTotal)
    nAtual := 1
    //Enquanto houver registros
    While nAtual <= nTotal
        IncProc("Imprimindo..." + 'Cálculo de Impostos' + " (" + cValToChar(nAtual) + " de " + cValToChar(nTotal) + ")...")

        //Se a linha atual mais o espaço que será utilizado forem maior que a linha final, imprime rodapé e cabeçalho
        if nLinAtu + (nTamLin + 005) > nLinFin
            fImpRod()
            fImpCab(oReq['dados']['cliente']['SA1'], oReq['impostos'], aHeader)
        endif

        //Imprimindo a linha atual
        
        for nY := 1 to len(aHeader)
            nCIni := if(nY == 1, nColIni, nCIni)
            oPrintPvt:Box(nLinAtu,nCIni,nLinAtu + (nTamLin + 005), nCIni + aHeader[nY,3])
            oPrintPvt:SayAlign(nLinAtu+002, nCIni+001, iif(aHeader[nY,1] == 'cProduto',; 
                                                        cValToChar(oReq['impostos']['aItm'][nAtual][aHeader[nY,1]]) + ' ' + cValToChar(oReq['impostos']['aItm'][nAtual]['cDesc']),;
                                                        iif(aHeader[nY,1] == 'nitem',;
                                                        cValToChar(oReq['impostos']['aItm'][nAtual][aHeader[nY,1]]),;
                                                        cValToChar(Transform(oReq['impostos']['aItm'][nAtual][aHeader[nY,1]],PesqPict("SF2","F2_VALBRUT"))))),; 
                                                        oFontDet, aHeader[nY,3], (nTamLin + 005), COR_PRETO, PAD_CENTER, 0)
            nCIni += aHeader[nY,3]
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

static function fImpCab(cDados, oImp, aHeader)
    local cTexto	:= 'CÁLCULO DE IMPOSTOS'
    local nLinCab	:= 030
    local nX		:= 0
    //local aCabec	:= ARRAY_CABECA
    local aTotais   := {"nTotMercadoria", "nBaseIcm","nValorIcm","nBaseST","nValorST","nTotZFranca","nTotVal"}
    local oDados    := JsonObject():new()

    oDados:FromJSON(cDados)
    
    //Iniciando Página
    oPrintPvt:StartPage()

    if nPagAtu == 1        
        oPrintPvt:Box(nLinCab,nColIni,(nLinCab + MAXBOXV),110)
        oPrintPvt:SayBitmap( nLinCab + 030, nColIni + 003, cLogo, 95, 30)

        oPrintPvt:Box(nLinCab,110,(nLinCab + MAXBOXV),nColFin)
        oPrintPvt:FillRect({nLinCab,110,(MAXBOXV)-050,nColFin},oBrush)
        oBrush:End()
        oPrintPvt:SayAlign(nLinCab+005, 110, cTexto, oFontTit, (nColFin - 110), 20, COR_BRANCO, PAD_CENTER, 0)
        oPrintPvt:Box(nLinCab+020,110,(nLinCab + MAXBOXV),((nColFin-110)/2)+110)
        oPrintPvt:SayAlign(nLinCab+025, 110, "CLIENTE:", oFontTit, (nColFin - 110)/2, 20, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:SayAlign(nLinCab+045, 110, AllTrim(oDados['A1_NOME']), oFontTRes, (nColFin - 110)/2, 20, COR_PRETO, PAD_CENTER, 0)
        
        //PARAMETROS
        oPrintPvt:SayAlign(nLinCab+025, 110+((nColFin - 110)/2), "PARÂMETROS:", oFontTRes, (nColFin - 110)/2, 20, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:SayAlign(nLinCab+045, 110+((nColFin - 110)/2), "UF: " + AllTrim(oDados['A1_EST']), oFontPar, ((nColFin - 110)/2)/3, 20, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:SayAlign(nLinCab+045, 110+((nColFin - 110)/2)+(((nColFin - 110)/2)/3), "GRP.TRIB: " + iif(empty(oDados['A1_GRPTRIB']),'-',AllTrim(oDados['A1_GRPTRIB'])), oFontPar, ((nColFin - 110)/2)/3, 20, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:SayAlign(nLinCab+045, 110+((nColFin - 110)/2)+((((nColFin - 110)/2)/3)*2), "TIPO: " + AllTrim(oDados['A1_TIPO']), oFontPar, ((nColFin - 110)/2)/3, 20, COR_PRETO, PAD_CENTER, 0)

        oPrintPvt:SayAlign(nLinCab+065, 110+((nColFin - 110)/2), "CONTRIB: " + iif(AllTrim(oDados['A1_CONTRIB']) == '2','N','S'), oFontPar, ((nColFin - 110)/2)/3, 20, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:SayAlign(nLinCab+065, 110+((nColFin - 110)/2)+(((nColFin - 110)/2)/3), "SIMPLES: " + iif(AllTrim(oDados['A1_SIMPNAC']) == '2','N','S'), oFontPar, ((nColFin - 110)/2)/3, 20, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:SayAlign(nLinCab+065, 110+((nColFin - 110)/2)+((((nColFin - 110)/2)/3)*2), "REIDI:" + AllTrim(oDados['A1_XREIDI']), oFontPar, ((nColFin - 110)/2)/3, 20, COR_PRETO, PAD_CENTER, 0)

        oPrintPvt:SayAlign(nLinCab+085, 110+((nColFin - 110)/2), "SIAF: " + iif(empty(oDados['A1_CODSIAF']),'-',AllTrim(oDados['A1_CODSIAF'])), oFontPar, ((nColFin - 110)/2)/3, 20, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:SayAlign(nLinCab+085, 110+((nColFin - 110)/2)+(((nColFin - 110)/2)/3), "Desc.Suf: " + AllTrim(oDados['A1_CALCSUF']), oFontPar, ((nColFin - 110)/2)/3, 20, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:SayAlign(nLinCab+085, 110+((nColFin - 110)/2)+((((nColFin - 110)/2)/3)*2), "SUF.: " + iif(empty(oDados['A1_SUFRAMA']),'-',AllTrim(oDados['A1_SUFRAMA'])), oFontPar, ((nColFin - 110)/2)/3, 20, COR_PRETO, PAD_CENTER, 0)

        //RESUMO
        nLinCab := MAXBOXV
        nLinCab += 015
        oPrintPvt:Box(nLinCab,nColIni,(nLinCab + (MAXBOXV / 3)),nColFin)
        oPrintPvt:FillRect({nLinCab,nColIni,MAXBOXV+035,nColFin},oBrush)
        oBrush:End()
        oPrintPvt:SayAlign(nLinCab+003, nColIni, 'Informações Resumidas', oFontTit, nColFin, 20, COR_BRANCO, PAD_CENTER, 0)
        nLinCab += 020
        oPrintPvt:Box(nLinCab,nColIni,(nLinCab + 015),075)
        oPrintPvt:SayAlign(nLinCab, nColIni, "Total Mer.", oFontTRes, 075, 10, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:Box(nLinCab,075,(nLinCab + 015),075*2)
        oPrintPvt:SayAlign(nLinCab, 075, "Base ICMS", oFontTRes, 075, 10, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:Box(nLinCab,075*2,(nLinCab + 015),075*3)
        oPrintPvt:SayAlign(nLinCab, 075*2, "Val.Icms", oFontTRes, 075, 10, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:Box(nLinCab,075*3,(nLinCab + 015),075*4)
        oPrintPvt:SayAlign(nLinCab, 075*3, "Base ST", oFontTRes, 075, 10, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:Box(nLinCab,075*4,(nLinCab + 015),075*5)
        oPrintPvt:SayAlign(nLinCab, 075*4, "Val. ST", oFontTRes, 075, 10, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:Box(nLinCab,075*5,(nLinCab + 015),075*6)
        oPrintPvt:SayAlign(nLinCab, 075*5, "Total ZF", oFontTRes, 075, 10, COR_PRETO, PAD_CENTER, 0)
        oPrintPvt:Box(nLinCab,075*6,(nLinCab + 015),nColFin)
        oPrintPvt:SayAlign(nLinCab, 075*6, "Val. Total", oFontTRes, nColFin - (075*6), 10, COR_PRETO, PAD_CENTER, 0)
        nLinCab += 015
        for nX := 1 to len(aTotais)
            oPrintPvt:Box(nLinCab,if(nX == 1,nColIni ,(075 * (nX-1))),nLinCab + 020,if(nX == len(aTotais),nColFin,(075 * nX)))
            oPrintPvt:SayAlign(nLinCab,(075 * (nX-1)) + 01, cValToChar(Transform(oImp[aTotais[nX]],PesqPict("SF2","F2_VALBRUT"))), oFontDRes, if(nX == len(aTotais),(nColFin-(075 * (nX-1))),075), 10, COR_PRETO, PAD_CENTER, 0)
        next nX
        nLinCab := (MAXBOXV) + (MAXBOXV / 2) + 005
    endif

    //HEADER
    nLinCab += 013
    oPrintPvt:Box(nLinCab,nColIni,(nLinCab + 040),nColFin)
    oPrintPvt:FillRect({nLinCab,nColIni,nLinCab+020,nColFin},oBrush)
    oBrush:End()
    oPrintPvt:SayAlign(nLinCab+003, nColIni, 'Itens do Cálculo', oFontTit, nColFin, 20, COR_BRANCO, PAD_CENTER, 0)
    nLinCab += 020
    nCIni := 0
    for nX := 1 to len(aHeader)
        nCIni := if(nX == 1, nColIni, nCIni)
        oPrintPvt:Box(nLinCab,nCIni,(nLinCab + 020),nCIni + aHeader[nX,3])
        oPrintPvt:SayAlign(nLinCab + 005, nCIni, aHeader[nX,2], oFontDRes, aHeader[nX,3], 015, COR_PRETO, PAD_CENTER, 0)
        nCIni += aHeader[nX,03]
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
    cTextoEsq := dToC(dDataGer) + "    " + cHoraGer + "    " + 'cbcCalcImp' + "    " + cNomeUsr
    cTextoDir := "Página " + cValToChar(nPagAtu)

    //Imprimindo os textos
    oPrintPvt:SayAlign(nLinRod, nColIni,    cTextoEsq, oFontRod, 200, 05, COR_CINZA, PAD_LEFT,  0)
    oPrintPvt:SayAlign(nLinRod, nColFin-40, cTextoDir, oFontRod, 040, 05, COR_CINZA, PAD_RIGHT, 0)

    //Finalizando a página e somando mais um
    oPrintPvt:EndPage()
    nPagAtu++
return(nil)
