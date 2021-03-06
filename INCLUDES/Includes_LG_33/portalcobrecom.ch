// Advpl MVC
#define MVC_MODEL_STRUCT  1
#define MVC_VIEW_STRUCT   2

// Grupos de Usu?rios
#define USER_ADMINISTRATOR		"01"
#define USER_SELLER				"02"
#define USER_PROSPECT			"03"
#define USER_CUSTOMER			"04"
#define USER_ASSISTANT			"05"
#define USER_SUPERVISOR			"06"
#define USER_MANAGER			"07"
#define USER_DIRECTOR			"08"
#define USER_SPECIAL			"09"

// Eventos do Portal
#define EVENT_USER_CREATE							"CD0001"
#define EVENT_USER_UPDATE							"CD0002"
#define EVENT_PROSPECT_CREATE						"CD0003"
#define EVENT_USER_GROUP_CHANGE						"CD0004"
#define EVENT_USER_WELCOME							"CD0005"

#define EVENT_PORTAL_LOGIN							"LG0001"
#define EVENT_PORTAL_LOGOUT							"LG0002"

#define EVENT_QUOTATION_CREATE						"OC0001"
#define EVENT_QUOTATION_UPDATE						"OC0002"
#define EVENT_QUOTATION_DELETE						"OC0003"
#define EVENT_QUOTATION_CANCEL						"OC0004"
#define EVENT_FINISH_QUOTATION_MAINTENANCE			"OC0005"
#define EVENT_SEND_QUOTATION_FOR_APPROVAL			"OC0006"
#define EVENT_ASSUME_QUOTATION_APPROVAL				"OC0007"
#define EVENT_QUOTATION_APPROVAL					"OC0008"
#define EVENT_QUOTATION_REJECTION					"OC0009"
#define EVENT_UNDO_QUOTATION_APPROVAL				"OC0010"
#define EVENT_LOCK_QUOTATION_UPDATE					"OC0011"
#define EVENT_UNLOCK_QUOTATION_UPDATE				"OC0012"
#define EVENT_GIVE_UP_QUOTATION_APPROVAL			"OC0013"
#define EVENT_QUOTATION_TEC_APPROVAL				"OC0014"
#define EVENT_QUOTATION_TEC_REJECTION				"OC0015"
#define EVENT_CONFIRM_QUOTATION						"OC0016"
#define EVENT_CREATE_QUOTATION_INVOICE				"OC0017"
#define EVENT_ERROR_PROCESSING_QUOTATION			"OC0018"

#define EVENT_PRODUCT_BALANCE_INTEREST				"RE0001"
#define EVENT_PRODUCT_BALANCE_RESERVE				"RE0002"
#define EVENT_CANCEL_PRODUCT_BALANCE_RESERVE		"RE0003"
#define EVENT_PRODUCT_BALANCE_RESERVE_EXPIRED		"RE0004"
#define EVENT_PRODUCT_BALANCE_RESERVE_CONFIRMED		"RE0005"
#define EVENT_PRODUCT_BALANCE_RESERVE_UNDO_CONFIRM	"RE0006"

#define EVENT_USE_TERMS_ACCEPT						"TU0001"
#define EVENT_USE_TERMS_REJECT						"TU0002"
			
// Filiais Cobrecom
#define BRANCH_ITU				"01"
#define BRANCH_TRES_LAGOAS		"02"			
			
// Status das Reservas de Produtos
#define RESERVE_STATUS_WAITING		"1"
#define RESERVE_STATUS_CONFIRMED	"2"
#define RESERVE_STATUS_EXPIRED		"3"
#define RESERVE_STATUS_CANCELED		"4"

// Status dos Or?amentos
#define QUOTATION_STATUS_REVISION	 				"0"
#define QUOTATION_STATUS_UNDER_MAINTENANCE 			"1"
#define QUOTATION_STATUS_WAITING_APPROVAL 			"2"
#define QUOTATION_STATUS_APPROVINGLY 				"3"
#define QUOTATION_STATUS_WAITING_CONFIRM 			"4"
#define QUOTATION_STATUS_CONFIRMED 					"5"
#define QUOTATION_STATUS_NOT_APPROVED 				"6"
#define QUOTATION_STATUS_CANCELED 					"7"
#define QUOTATION_STATUS_WAITING_TECNICAL_APPROVAL 	"8"
#define QUOTATION_STATUS_WAITING_PROCESSING		 	"9"
#define QUOTATION_STATUS_PROCESSING		 			"A"
#define QUOTATION_STATUS_ERROR_PROCESSING		 	"B"
#define QUOTATION_STATUS_TECNICAL_REJECT		 	"C"

// Tipos de Or?amentos
#define QUOTATION_TYPE_NORMAL		"1"
#define QUOTATION_TYPE_SALES_ORDER	"2"
#define QUOTATION_TYPE_BONUS		"3"

// Tipos de Documentos dos Or?amentos
#define QUOTATION_DOC_SALES_ORDER	"1"
#define QUOTATION_DOC_INVOICE		"2" 

// Tipos das Regras de Negocios dos Or?amentos
#define QUOTATION_PACKAGING_RULES		"1"
#define QUOTATION_PRICES_RULES			"2"
#define QUOTATION_MINIMUM_VALUES_RULES	"3"
#define QUOTATION_OTHER_RULES			"4"
#define QUOTATION_COLORS_RULES			"5"

// Templates HTML
#define COMPANY_WELCOME_HTML			"\portal_cobrecom\templates\company_welcome.html"
#define USER_WELCOME_HTML				"\portal_cobrecom\templates\user_welcome.html"
#define PROSPECT_TO_CUSTOMER_HTML		"\portal_cobrecom\templates\prospect_to_customer.html"
#define MESSAGE_EMAIL_HTML				"\portal_cobrecom\templates\message_email.html"
#define NOTIFICATION_EMAIL_HTML			"\portal_cobrecom\templates\notification_email.html"
#define PSW_RECOVERY_EMAIL_HTML			"\portal_cobrecom\templates\psw_recovery_email.html"
#define GENERIC_NOTIFICATION_EMAIL_HTML	"\portal_cobrecom\templates\generic_notification_email.html"
#define USER_FIRST_ACCESS_EMAIL_HTML	"\portal_cobrecom\templates\user_first_access_email.html"

// Codigo/Loja do Cliente Padr?o
#define DEFAULT_CUSTOMER_CODE	   GetNewPar("ZZ_CLIPAD", "000000")
#define DEFAULT_CUSTOMER_UNIT	   GetNewPar("ZZ_LOJPAD", "00")

// Eventos das Revis?es dos Or?amentos
#define QUOTATION_REVISION_CREATE			"1"
#define QUOTATION_REVISION_UPDATE			"2"
#define QUOTATION_REVISION_APPROVE			"3"
#define QUOTATION_REVISION_REJECTION		"4"
#define QUOTATION_REVISION_GIVE_UP_APPROVAL	"5"
#define QUOTATION_REVISION_TECNICAL_APPROVAL "6"
#define QUOTATION_REVISION_TECNICAL_REJECT 	 "7"

// Condi??o de Pagamento de Bonifica??o
#define BONUS_PAYMENT_CONDITION	   GetNewPar("ZZ_CONDBON", "002")

// Ambiente de execu??o
#define PORTAL_REST_API	 (GetSrvProfString("PORTAL_REST_API", "") == "1")
