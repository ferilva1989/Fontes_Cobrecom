/*API REST*/
#DEFINE LIBERADO_EMPENHO 'LE'
#DEFINE EMPENHADO 'E'
#DEFINE LIBERADO_FINANCEIRO 'LC'
#DEFINE ANALISE_FINANCEIRO 'AC'
#DEFINE LIBERADO_LOGISTICA 'LL'
#DEFINE ANALISE_LOGISTICA 'AL'
#DEFINE ANALISE_EXPEDICAO 'AE'
#DEFINE LIBERADO_SEPARACAO 'LS'
#DEFINE SEPARANDO 'ES'
#DEFINE LIBERADO_VOLUME 'LV'
#DEFINE VOLUME 'EV'
#DEFINE LIBERADO_CARGA 'LR'
#DEFINE ANALISE_POSSEPARACAO 'AS'
#DEFINE LIBERADO_FATURAMENTO 'LF'
#DEFINE FATURANDO 'F'
#DEFINE FATURADO 'NF'
#DEFINE CANCELADO_FATURAMENTO 'CF'

#DEFINE BLOQUEADO_EXP 'BE'

#DEFINE ARRAY_STATUS {'LE','E','LC','AC','LL','AL','AE','LS','ES','LV','EV','LR','AS','LF','F','NF','CF' }

#DEFINE ARRAY_STATUS_DESC { 'P.V. Liberado','Em Empenho','Liberado Financeiro','Análise Financeira',;
							'Liberado Logística','Análise Logística','Análise Expedição',;
							'Liberado Separação','Em Separação','Liberado para Volumes','Formando Volumes',;
							'Liberado Carga','Análise Pós-Expedição','Liberado Faturamento',;
							'Em Fautamento','Faturado','Faturamento Cancelado' }

#define STS_VISION 'V'
#define STS_DETAIL 'D'
#define STS_BUTTON 'B'

#define Z8_ANALISE_EXPEDICAO 'AE'
#define Z8_LIBERADO_SEPARACAO 'C'
#define Z8_SEPARANDO 'W'
#define Z8_SEP_FECHA 'FS'
#define Z8_LIBERADO_VOLUME 'CV'
#define Z8_VOLUME 'WV'
#define Z8_VOL_FECHA 'FV'
#define Z8_FIM_EXPEDICAO 'FE'
#define Z8_LIBERADO_CARGA 'CC'
#define Z8_CARREGANDO 'WC'
#define Z8_CAR_FECHA 'FC'
#define Z8_FINALIZADO 'F'
#define Z8_FIM_PORTARIA 'FF'

#define Z8_ARRAY_STATUS {'AE','C','W','FS','CV','WV','FV','FE','CC','WC','FC','F','FF'}

#define Z8_ARRAY_STATUS_DESC {'Analise Expedição','Liberado Separação','Em Separação','Fim separação','Liberado para Volumes',;
								'Formando Volumes','Fechando Volumes','Finalizado Expedição','Liberado Carregamento',;
								'Em Carregamento','Finalizado', 'Saída da Portaria'}