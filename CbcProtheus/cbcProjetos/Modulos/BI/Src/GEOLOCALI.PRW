#INCLUDE 'TOTVS.ch'
#INCLUDE 'XMLXFUN.CH'
#define CRLF Chr(13)+Chr(10)

*************************************************************************
User Function geoLocali(cEnd,lMap) //u_geoLocali("Endereço Numero, Cidade,Estado" , Logico)
	/*
	***** RETORNO *****
	/*
	** Quando consulta OK
	aGeo[1] = .T.
	aGeo[2] = Endereço retornado Google
	aGeo[3] = Latitude
	aGeo[4] = Longitude

	** Quando erro Internet
	aGeo[1] = .F.
	aGeo[2] = Falha ao gerar Objeto XML
	aGeo[3] = Url Enviada Google

	** quando erro consulta
	aGeo[1] = .F.
	aGeo[2] = Status erro retornado pelo google
	aGeo[3] = Url Enviada Google
	*/
	*************************************************************************
	Local cUrl 			:= ""
	Local cError		:= ""
	Local cWarning		:= ""
	Local oXml			:= NIL
	Local aGeo			:= {}
	Default cEnd		:= "1600+Amphitheatre+Parkway,+Mountain+View,+CA"
	Default lMap		:= .F.

	//Cria a URL com o endereço para consulta
	//"http://maps.googleapis.com/maps/api/geocode/xml?address=1600+Amphitheatre+Parkway,+Mountain+View,+CA&sensor=false"
	cUrl := "http://maps.googleapis.com/maps/api/geocode/xml?address=" + StrTran(cEnd," ","+") + "&sensor=false"
	oXml	:=  XmlParser( HttpGet(cUrl), "_", @cError, @cWarning )

	//VERIFICAÇÃO DE ERRO (CONEXÃO)
	If oXml == NIL

		Aadd(aGeo,.F.)
		Aadd(aGeo,"Falha ao gerar Objeto XML : " +cError+" / " +cWarning)
		Aadd(aGeo,cUrl)

	Else

		/*
		*** DESCRIÇÃO DOS STATUS RETORNADO PELO GOOGLE ***
		"OK" 				= Não ocorreu erro, e pelo menos um geocodigo foi retornado
		"ZERO_RESULTS"		= Não retornou resultados
		"OVER_QUERY_LIMIT"	= Indica que você ultrapassou o limite da quota ( 2500 solicitações/dia )
		Considerar 2480 como limite - Pois se execeder o limite todo dia bloqueia
		"REQUEST_DENIED"	= Consulta foi negada, falta o parametro sensor
		"INVALID_REQUEST"	= Algum parametro (endereço) esta ausente
		*/
		If oXml:_GEOCODERESPONSE:_STATUS:TEXT == "OK"

			//Neste caso endereço retornou varios resultados(arrumar endereço cadastro)
			//Xml:_GEOCODERESPONSE:_RESULT[1]:_FORMATTED_ADDRESS:TEXT
			//Xml:_GEOCODERESPONSE:_RESULT[2]:_FORMATTED_ADDRESS:TEXT ..ETC
			//QUANDO A = VARIOS RESULTADOS 
			If valtype(oXml:_GEOCODERESPONSE:_RESULT)  == 'A'  

				//Aadd(aGeo,.F.)
				//Aadd(aGeo,"Retorno com varios resultados, arrumar cadastro")

				//Consulta OK
				Aadd(aGeo,.T.)

				//Endereço
				Aadd(aGeo , oXml:_GEOCODERESPONSE:_RESULT[1]:_FORMATTED_ADDRESS:TEXT)

				//Latitude
				Aadd(aGeo , oXml:_GEOCODERESPONSE:_RESULT[1]:_GEOMETRY:_LOCATION:_LAT:TEXT)

				//Longitude
				Aadd(aGeo , oXml:_GEOCODERESPONSE:_RESULT[1]:_GEOMETRY:_LOCATION:_LNG:TEXT)

				//**** Exibir Mapa Navegador *****
				if lMap

					mostraMapa(gerHtml(aGeo[3], aGeo[4]))

				EndIf
			Else

				//Consulta OK
				Aadd(aGeo,.T.)

				//Endereço
				Aadd(aGeo , oXml:_GEOCODERESPONSE:_RESULT:_FORMATTED_ADDRESS:TEXT)

				//Latitude
				Aadd(aGeo , oXml:_GEOCODERESPONSE:_RESULT:_GEOMETRY:_LOCATION:_LAT:TEXT)

				//Longitude
				Aadd(aGeo , oXml:_GEOCODERESPONSE:_RESULT:_GEOMETRY:_LOCATION:_LNG:TEXT)

				//**** Exibir Mapa Navegador *****
				if lMap

					mostraMapa(gerHtml(aGeo[3], aGeo[4]))

				EndIf
			EndIf
		Else

			Aadd(aGeo,.F.)
			Aadd(aGeo,oXml:_GEOCODERESPONSE:_STATUS:TEXT)
			Aadd(aGeo,cUrl)

		EndIf

	EndIF

	Return aGeo

	***********************************************
Static Function gerHtml(cLat, cLong)
	***********************************************

	Local cHtml := ""

	cHtml += "<!DOCTYPE html>" 																							+ CRLF
	cHtml +="	<html>"																									+ CRLF
	cHtml +="  <head>"		   																							+ CRLF
	cHtml +="    <meta charset='utf-8'>"		   																		+ CRLF
	cHtml +="    <title>Street View service</title>"																	+ CRLF
	cHtml +="    <style>"																								+ CRLF
	cHtml +="      html, body, #map-canvas {"		   																	+ CRLF
	cHtml +="        height: 100%;"																						+ CRLF
	cHtml +="        margin: 0px;"		   																				+ CRLF
	cHtml +="        padding: 0px"																						+ CRLF
	cHtml +="      }"		   																							+ CRLF
	cHtml +="    </style>"		   																						+ CRLF
	cHtml +="    <script src='https://maps.googleapis.com/maps/api/js?v=3.exp&signed_in=true'></script>"				+ CRLF
	cHtml +="    <script>"		   																						+ CRLF
	cHtml +="function initialize() {"		   																			+ CRLF
	cHtml +="  var fenway = new google.maps.LatLng("+ cLat +", "+ cLong +");"		   									+ CRLF
	cHtml +="  var mapOptions = {"		   																				+ CRLF
	cHtml +="    center: fenway,"																						+ CRLF
	cHtml +="    zoom: 16"		   																						+ CRLF
	cHtml +="  };"		   																								+ CRLF
	cHtml +="  var map = new google.maps.Map("		   																	+ CRLF
	cHtml +="      document.getElementById('map-canvas'), mapOptions);"													+ CRLF
	cHtml +="  var panoramaOptions = {"		   																			+ CRLF
	cHtml +="    position: fenway,"		   																				+ CRLF
	cHtml +="    pov: {"		   																						+ CRLF
	cHtml +="      heading: 34,"		   																				+ CRLF
	cHtml +="      pitch: 10"		   																					+ CRLF
	cHtml +="    }"		   																								+ CRLF
	cHtml +="  };"		   																								+ CRLF
	cHtml +="  var panorama = new google.maps.StreetViewPanorama(document.getElementById('pano'), panoramaOptions);"	+ CRLF
	cHtml +="  map.setStreetView(panorama);"		   																	+ CRLF
	cHtml +="}"																											+ CRLF
	cHtml +="google.maps.event.addDomListener(window, 'load', initialize);"												+ CRLF
	cHtml +="    </script>"																								+ CRLF
	cHtml +="  </head>"																									+ CRLF
	cHtml +="  <body>"		   																							+ CRLF
	cHtml +="    <div id='map-canvas' style='width: 45%; height: 100%;float:left'></div>"		   						+ CRLF
	cHtml +="    <div id='pano' style='width: 45%; height: 100%;float:left'></div>"		   								+ CRLF
	cHtml +="  </body>"		   																							+ CRLF
	cHtml +="</html>"		   																							+ CRLF

	Return cHtml

	*********************************************
Static function mostraMapa(chtml)  
	//Abrir html LEO
	*********************************************
	Local nHandle
	nHandle := FCREATE("\index.html")

	If nHandle = -1
		conout("Erro ao criar arquivo - ferror " + Str(Ferror()))
	Else   
		FWrite(nHandle, chtml)
		FClose(nHandle)
		CpyS2T("\index.html","c:\temp\",.T.)
		SHELLEXECUTE("Open","C:\temp\index.html","","",3)

	EndIf      

	/*
	Função temporaria para atualizar clientes já existentes
	(Atualizas todos registros com o limite nas cosultas diarias google)
	*/

	*****************************************
User Function tempCoord(nVezes, cAlias)   //U_tempCoord(nVezes, cAlias)
	*****************************************
	Local nX        := 1
	Local aGeo		:= {}
	Local cMsg		:= ""

	Default nVezes	:= 10
	Default cAlias	:= "SA1"
	/*
	***** RETORNO *****
	/*
	** Quando consulta OK
	aGeo[1] = .T.
	aGeo[2] = Endereço retornado Google
	aGeo[3] = Latitude
	aGeo[4] = Longitude

	** Quando erro Internet
	aGeo[1] = .F.
	aGeo[2] = Falha ao gerar Objeto XML
	aGeo[3] = Url Enviada Google

	** quando erro consulta
	aGeo[1] = .F.
	aGeo[2] = Status erro retornado pelo google
	aGeo[3] = Url Enviada Google
	*/

	If cAlias == "SA1"

		DbSelectArea("SA1")    //Fazer tambem para SA3 - representantes
		SA1->(DbSetOrder(1)) //A1_FILIAL+A1_COD+A1_LOJA
		SA1->(DbGoTop())

		//Limitar o numero de consultas x dia (2480)
		While nX <= nVezes .AND. !SA1->(eof())

			If !SA1->(eof()) .AND. ( Empty(SA1->(A1_ZLATI)) .OR. Empty(SA1->(A1_ZLONG)) ) .AND. SA1->(A1_COD) != '000000' .AND. !Empty(SA1->(A1_END)) .AND. (Alltrim(SA1->(A1_ZGMEND)) = 'ZERO_RESULTS' .OR.  Empty(SA1->(A1_ZGMEND)) ) 

				aGeo	:={}

				If Alltrim(SA1->(A1_EST)) == 'EX' 	

					aGeo 	:= U_geoLocali(NoEspec(NoAcento(AnsiToOem(SA1->(Alltrim(StrTran(A1_END,",","") + A1_BAIRRO) + "  ," + Alltrim(A1_MUN) + " ," + Alltrim(Posicione("SYA",1,xFilial("SA1")+SA1->(A1_PAIS), "YA_DESCR")))))),.F.) 
				Else
					//u_geoLocali("Endereço Numero, Cidade,Estado" , Logico)	
					aGeo 	:= U_geoLocali(NoEspec(NoAcento(AnsiToOem(SA1->(Alltrim(StrTran(A1_END,",","") + A1_BAIRRO) + "  ," + Alltrim(A1_MUN) + " ," + Alltrim(A1_EST))))),.F.) 

				EndIf

				If  aGeo[1]

					reclock("SA1", .F.)              
					SA1->(A1_ZLATI) 	:= aGeo[3] 
					SA1->(A1_ZLONG)		:= aGeo[4]
					SA1->(A1_ZGMEND)	:= aGeo[2]
					SA1->(msunlock()) 

				Else

					CMsg	+= "*****************************************************" 						+ CRLF
					cMsg 	+=  Alltrim(SA1->(A1_COD+A1_LOJA) ) 											+ CRLF
					cMsg 	+=  Alltrim(SA1->( StrTran(A1_END,",","") + "  ," + A1_MUN + " ," + A1_EST  )) 	+ CRLF
					cMsg	+=  aGeo[2] 																	+ CRLF
					cMsg	+=  aGeo[3]                         											+ CRLF
					CMsg	+= "*****************************************************"				 + CRLF + CRLF

					//LIMTE DE QUERYS AO GOOGLE NÂO TENTAR MAIS
					If aGeo[2] == "OVER_QUERY_LIMIT"

						EXIT

						//EVITAR REPETIR CONSULTA QUE NÂO RETORNA ( MUITOS ZERO RESULT =  OVER LIMIT ) QUANDO ARRUMAR CADASTRO LIMPAR CAMPO
					ElseIf aGeo[2] == "ZERO_RESULTS"

						reclock("SA1", .F.)              
						SA1->(A1_ZGMEND)	:= "ZERO_RESULTS"
						SA1->(msunlock()) 

					EndIF                

				EndIf                      		

				nX ++
			EndIf

			SA1->(dbskip())

		EndDo          

	ElseIf cAlias == "SA3"

		DbSelectArea("SA3")
		SA3->(DbSetOrder(1)) //A3_FILIAL+A3_COD
		SA3->(DbGoTop())

		//Limitar o numero de consultas x dia (2480)
		While nX <= nVezes .AND. !SA3->(eof())

			If !SA3->(eof()) .AND. ( Empty(SA3->(A3_ZLATI)) .OR. Empty(SA3->(A3_ZLONG)) ) .AND. Len(Alltrim(SA3->(A3_END))) > 10    

				aGeo	:={}
				//u_geoLocali("Endereço Numero, Cidade,Estado" , Logico)	
				aGeo 	:= U_geoLocali(NoEspec(NoAcento(AnsiToOem(SA3->(Alltrim(StrTran(A3_END,",","") + A3_BAIRRO) + "  ," + Alltrim(A3_MUN) + " ," + Alltrim(A3_EST))))),.F.) 
				If  aGeo[1]

					reclock("SA3", .F.)              
					SA3->(A3_ZLATI) 	:= aGeo[3] 
					SA3->(A3_ZLONG)		:= aGeo[4]
					SA3->(A3_ZGMEND)	:= aGeo[2]
					SA3->(msunlock()) 

				Else

					CMsg	+= "*****************************************************" 						+ CRLF
					cMsg 	+=  Alltrim(SA3->(A3_COD) ) 													+ CRLF
					cMsg 	+=  Alltrim(SA3->( StrTran(A3_END,",","") + "  ," + A3_MUN + " ," + A3_EST  )) 	+ CRLF
					cMsg	+=  aGeo[2] 																	+ CRLF
					cMsg	+=  aGeo[3]                         											+ CRLF
					CMsg	+= "*****************************************************"				 + CRLF + CRLF                

					//LIMTE DE QUERYS AO GOOGLE NÂO TENTAR MAIS 
					If aGeo[2] = "OVER_QUERY_LIMIT"

						EXIT

					EndIF

				EndIf                      		

				nX ++
			EndIf

			SA3->(dbskip())

		EndDo

	EndIf

	//Informa os erros(Utilizando função da Juliana)
	If !Empty(cMsg)

		U_ConsoleLog("Erro",cMsg, "GeoLocali")
		U_ArqPorEmail("GeoLocali","leonardo@cobrecom.com.br","[Erros] - GeoLocalizacao" )

	EndIf

	Return Nil 


	**********************************************
Static Function NoEspec(cEntrada)
	/*Permite na String somente os caracteres (Alfa/Numericos e Espaço)*/
	**********************************************
	Local cRetorno	:= ""
	Local nX
	Local cASCII
	Local cCarac

	For nX := 1 to Len(Alltrim(cEntrada))

		cCarac := Substr(cEntrada,nX,1)
		cASCII := Asc(cCarac)

		If cASCII == 32 .OR.  cASCII == 44 .OR. ( cASCII >= 48 .AND. cASCII <=57 ) .OR. ( cASCII >= 65 .AND. cASCII <=90 ) .OR.;
		( cASCII >= 97 .AND. cASCII <=122 ) .OR. cASCII == 47  

			cRetorno += cCarac

		Else
			cRetorno += " "

		EndIf 

	Next
	Return cRetorno 


	*********************************************
User Function ManGeoPE(cAlias,aDados, lTipo)
	*********************************************
	Local aGeo		:= {}
	Local cMSG		:= ""
	Default aDados	:= {}

	If cAlias == "SA1" .AND. !Empty(SA1->(A1_END)) .AND. !Empty(SA1->(A1_BAIRRO)) .AND. !Empty(SA1->(A1_MUN)) .AND. !Empty(SA1->(A1_EST))

		If Alltrim(SA1->(A1_EST)) == 'EX'

			aGeo 	:= U_geoLocali(NoEspec(NoAcento(AnsiToOem(SA1->(Alltrim(StrTran(A1_END,",","") + A1_BAIRRO) + "  ," + Alltrim(A1_MUN) + " ," + Alltrim(Posicione("SYA",1,xFilial("SA1")+SA1->(A1_PAIS), "YA_DESCR")))))),.F.)
		Else
			//u_geoLocali("Endereço Numero, Cidade,Estado" , Logico)
			aGeo 	:= U_geoLocali(NoEspec(NoAcento(AnsiToOem(SA1->(Alltrim(StrTran(A1_END,",","") + A1_BAIRRO) + "  ," + Alltrim(A1_MUN) + " ," + Alltrim(A1_EST))))),.F.)

		EndIf

		If  aGeo[1]

			reclock("SA1", .F.)              
			SA1->(A1_ZLATI) 	:= aGeo[3] 
			SA1->(A1_ZLONG)		:= aGeo[4]
			SA1->(A1_ZGMEND)	:= aGeo[2]
			SA1->(msunlock()) 

		Else

			//LOG DO ERRO
			cMsg	+= "*****************************************************" 						+ CRLF
			cMsg 	+=  Alltrim(SA1->(A1_COD+A1_LOJA) ) 											+ CRLF
			cMsg 	+=  Alltrim(SA1->( StrTran(A1_END,",","") + "  ," + A1_MUN + " ," + A1_EST  )) 	+ CRLF
			cMsg	+=  aGeo[2] 																	+ CRLF
			cMsg	+=  aGeo[3]                         											+ CRLF
			cMsg	+= "*****************************************************"				 + CRLF + CRLF

			//GRAVA ERRO BANCO
			reclock("SA1", .F.)              
			SA1->(A1_ZGMEND)	:= aGeo[2]
			SA1->(msunlock()) 			

		EndIf                      		

	ElseIf cAlias == "SA3"
		//MESMO SA1 (copiar)


	Else
		cMsg	+= "*****************************************************" 						+ CRLF
		cMsg 	+=  aDados[1] 																	+ CRLF
		cMsg	+=  aDados[2] 																	+ CRLF
		cMsg	+=  "[ERRO]"                         											+ CRLF
		CMsg	+= "*****************************************************"				 + CRLF + CRLF    

	EndIf 

	//Informa os erros(Utilizando função da Juliana)
	If !Empty(cMsg)

		U_ConsoleLog("Erro",cMsg, "GeoLocali")
		U_ArqPorEmail("GeoLocali","leonardo@cobrecom.com.br","[Erros] - GeoLocalizacao" )

	EndIf


	Return Nil

	/*
	PONTOS DE ENTRADA PARA MANTER CADASTRO GEOLOCALIZAÇÃO

	*/

	/*CLIENTES*/
	***********************************
User Function MA030INC //INCLUSÃO
	***********************************
	Local _aArea	:= GetArea()
	Local _aAreaA1	:= SA1->(GetArea())
	Local aDados 	:={}

	Aadd(aDados, "Chave: " + Alltrim(SA1->(A1_COD+A1_LOJA) ) )
	Aadd(aDados, "Erro cadastro cliente")
	U_ManGeoPE("SA1", aDados)                

	RestArea(_aAreaA1)
	RestArea(_aArea)
	Return Nil 

	***********************************
User Function MAALTCLI //ALTERAÇÃO
	***********************************
	Local _aArea	:= GetArea()
	Local _aAreaA1	:= SA1->(GetArea())

	Aadd(aDados, "Chave: " + Alltrim(SA1->(A1_COD+A1_LOJA) ) )
	Aadd(aDados, "Erro alteração cliente")
	U_ManGeoPE("SA1", aDados)

	RestArea(_aAreaA1)
	RestArea(_aArea)
	Return Nil


	/*REPRESENTANTES*/
	***********************************
User Function MA040DIN  //INCLUSÃO
	***********************************
	Local _aArea	:= GetArea()
	Local _aAreaA3	:= SA3->(GetArea())

	//ManGeoPE(cAlias,aDados)

	RestArea(_aAreaA3)
	RestArea(_aArea)
	Return Nil 

	***********************************
User Function MA040DAL //ALTERAÇÃO
	***********************************
	Local _aArea	:= GetArea()
	Local _aAreaA3	:= SA3->(GetArea())


	//ManGeoPE(cAlias,aDados)

	RestArea(_aAreaA3)
	RestArea(_aArea)
	Return Nil


	/*  EXIBIÇÂO GEO LOCALIZAÇÂO*/
	***************************************
User Function MA040BUT()
	***************************************
	/*
	Adiciona botão tela de vebndedores 
	"Array” com as definições dos botões. 
	aBotao[1]="ICONE"
	aBotao[2]=bBloco
	aBotao[3]=Ajuda 
	*/

	Return aBotao :={{"GEOCLI",{|| U_geoCliVend()},"Mostrar Clientes Mapa"}}


	***************************************
User Function geoCliVend()
	***************************************
	Local cHtml 		:= ""
	Local cParClientes	:= ""
	Local cVendLat
	Local cVendLong
	Local cSQL 			:= ""
	Local nCli			:= 0
	Local nLoop			:= 1

	//VEM POSICIONADO NO SA3 CORRETO                
	If Empty(SA3->(A3_ZLATI)) .OR. Empty(SA3->(A3_ZLONG))

		MessageBox("[ERRO] - Nenhuma coordenada cadastrada para este vendedor", "Aviso", 48)

	Else	

		If Select( "GEO") > 0
			GEO->(dbcloseArea())
			FErase( "GEO" + GetDbExtension())
		EndIf

		cSQL :=	" AND SA1.A1_ZLATI <> '' " 
		cSQL +=	" AND SA3.A3_COD = '" + SA3->(A3_COD) + "'"  
		cSQL := "%"+cSQL+"%"

		//Consulta no banco
		BeginSQL Alias "GEO"

		SELECT	
		SA1.A1_ZLATI					AS lat,
		SA1.A1_ZLONG					AS lng,
		SA1.A1_NREDUZ					AS nome,
		SA1.A1_ZGMEND					AS morada1,
		SA1.A1_MUN + SA1.A1_EST			AS morada2,
		SA3.A3_NREDUZ					AS codpostal

		FROM %Table:SA1% SA1

		INNER JOIN %Table:SA3% SA3
		ON  SA1.A1_VEND			= SA3.A3_COD

		WHERE SA1.%NotDel% AND SA3.%NotDel% %exp:cSQL%

		EndSql

		DbSelectArea("GEO")
		GEO->(DbGotop())    

		If GEO->(EOF())

			Alert("[ERRO] - Nenhum Cliente Encontrado ou Clientes sem coordenadas")
			Return NIL	

		EndIf

		nCli	:= Contar("GEO","!Eof()")
		GEO->(DbGotop())

		//Criar primeiro marker com o vendedor
		cParClientes	+= 	"{"																					+ CRLF
		cParClientes	+= 	"	      lat:" 		+  Alltrim(SA3->(A3_ZLATI))									+","	+ CRLF
		cParClientes	+= 	"	      lng:" 		+  Alltrim(SA3->(A3_ZLONG)) 								+ ","	+ CRLF
		cParClientes	+= 	"	      nome: '" 		+  NoEspec(NoAcento(AnsiToOem(Alltrim(SA3->(A3_NREDUZ))))) 	+ "',"	+ CRLF
		cParClientes	+= 	"	      morada1:'" 	+  NoEspec(NoAcento(AnsiToOem(Alltrim(SA3->(A3_ZGMEND))))) 	+ "',"	+ CRLF
		cParClientes	+= 	"	      morada2: '" 	+  NoEspec(NoAcento(AnsiToOem(Alltrim(SA3->(A3_MUN))))) 	+ "',"	+ CRLF
		cParClientes	+= 	"	      codPostal: '" +  NoEspec(NoAcento(AnsiToOem(Alltrim(SA3->(A3_EST))))) 	+ "',"	+ CRLF
		cParClientes	+=	"		  icone:  'http://maps.google.com/mapfiles/ms/icons/green-dot.png'	
		cParClientes	+= 	"	   }"															
		cParClientes	+= ","																	+ CRLF
		//Restante clientes
		While !GEO->(EOF()) 


			cParClientes	+= 	"{"														+ CRLF
			cParClientes	+= 	"	      lat:" 		+  Alltrim(GEO->(lat))										+","	+ CRLF
			cParClientes	+= 	"	      lng:" 		+  Alltrim(GEO->(lng)) 										+ ","	+ CRLF
			cParClientes	+= 	"	      nome: '" 		+  NoEspec(NoAcento(AnsiToOem(Alltrim(GEO->(nome))))) 		+ "',"	+ CRLF
			cParClientes	+= 	"	      morada1:'" 	+  NoEspec(NoAcento(AnsiToOem(Alltrim(GEO->(morada1))))) 	+ "',"	+ CRLF
			cParClientes	+= 	"	      morada2: '" 	+  NoEspec(NoAcento(AnsiToOem(Alltrim(GEO->(morada2))))) 	+ "',"	+ CRLF
			cParClientes	+= 	"	      codPostal: '" +  NoEspec(NoAcento(AnsiToOem(Alltrim(GEO->(codPostal))))) 	+ "',"	+ CRLF
			cParClientes	+=  "		  icone:  'http://maps.google.com/mapfiles/ms/icons/red-dot.png'
			cParClientes	+= 	"	   }"															

			//Ultimo não coloca virgula
			If nCli == nLoop
				cParClientes	+= CRLF

				//Não é ultimo coloca virgula
			Else
				cParClientes	+= "," + CRLF
			EndIf

			nLoop ++
			GEO->(dbSkip())
		EndDo

		//Finaliza
		cParClientes	+= "];" + CRLF

		cHtml	+= "<!DOCTYPE html>"																							+ CRLF
		cHtml	+= "<html>"								   																		+ CRLF
		cHtml	+= "  <head>"																									+ CRLF
		cHtml	+= "  	<meta charset='utf-8'>"								   													+ CRLF
		cHtml	+= "    	<style type='text/css'>"																			+ CRLF
		cHtml	+= "		html {"																								+ CRLF
		cHtml	+= "			height: 100%;"																					+ CRLF
		cHtml	+= "		}"																									+ CRLF
		cHtml	+= "		body {"								   	   															+ CRLF
		cHtml	+= "			height: 100%;"																					+ CRLF
		cHtml	+= "			margin: 0;"								   														+ CRLF
		cHtml	+= "			padding: 0;"																					+ CRLF
		cHtml	+= "		}"																									+ CRLF
		cHtml	+= "		#map-canvas {"																						+ CRLF
		cHtml	+= "			height: 100%;"																					+ CRLF
		cHtml	+= "		}"																									+ CRLF
		cHtml	+= "		#iw_container .iw_title {"																			+ CRLF
		cHtml	+= "			font-size: 16px;"																				+ CRLF
		cHtml	+= "			font-weight: bold;"																				+ CRLF
		cHtml	+= "		}"																									+ CRLF
		cHtml	+= "		.iw_content {"																						+ CRLF
		cHtml	+= "			padding: 15px 15px 15px 0;"																		+ CRLF
		cHtml	+= "		}"								   																	+ CRLF
		cHtml	+= "	</style>"																								+ CRLF
		cHtml	+= "	<script type='text/javascript' src='https://maps.googleapis.com/maps/api/js?sensor=false'></script>"	+ CRLF
		cHtml	+= "	<script>"																								+ CRLF
		cHtml	+= "	var map;"																								+ CRLF
		cHtml	+= "	var infoWindow;"																						+ CRLF
		cHtml	+= "	var markersData = ["																					+ CRLF

		cHtml	+=	cParCliente

		cHtml	+= "	function initialize() {"																				+ CRLF
		cHtml	+= "	   var mapOptions = {"																					+ CRLF
		cHtml	+= "	      center: new google.maps.LatLng("+SA3->(A3_ZLATI)+","+ SA3->(A3_ZLONG)+"),"						+ CRLF
		cHtml	+= "	      zoom: 12,"																							+ CRLF
		cHtml	+= "	      mapTypeId: 'roadmap',"																			+ CRLF
		cHtml	+= "	   };"																									+ CRLF
		cHtml	+= "	   map = new google.maps.Map(document.getElementById('map-canvas'), mapOptions);"						+ CRLF
		cHtml	+= "	   infoWindow = new google.maps.InfoWindow();"															+ CRLF
		cHtml	+= "	   google.maps.event.addListener(map, 'click', function() {"											+ CRLF
		cHtml	+= "	      infoWindow.close();"																				+ CRLF
		cHtml	+= "	   });"																									+ CRLF
		cHtml	+= "	   displayMarkers();"																					+ CRLF
		cHtml	+= "	}"																										+ CRLF
		cHtml	+= "	google.maps.event.addDomListener(window, 'load', initialize);"											+ CRLF
		cHtml	+= "	function displayMarkers(){"																				+ CRLF
		cHtml	+= "	   var bounds = new google.maps.LatLngBounds();"														+ CRLF
		cHtml	+= "	   for (var i = 0; i < markersData.length; i++){"														+ CRLF
		cHtml	+= "	      var latlng = new google.maps.LatLng(markersData[i].lat, markersData[i].lng);"						+ CRLF
		cHtml	+= "	      var nome = markersData[i].nome;"																	+ CRLF
		cHtml	+= "	      var morada1 = markersData[i].morada1;"															+ CRLF
		cHtml	+= "	      var morada2 = markersData[i].morada2;"															+ CRLF
		cHtml	+= "	      var codPostal = markersData[i].codPostal;"														+ CRLF
		cHtml	+= "		  var icone  = 	markersData[i].icone;"																+ CRLF
		cHtml	+= "	      createMarker(latlng, nome, morada1, morada2, codPostal, icone);"									+ CRLF
		cHtml	+= "	      bounds.extend(latlng);  "																			+ CRLF
		cHtml	+= "	   }"																									+ CRLF
		cHtml	+= "	   map.fitBounds(bounds);"																				+ CRLF
		cHtml	+= "	}"																										+ CRLF
		cHtml	+= "	function createMarker(latlng, nome, morada1, morada2, codPostal, icone){"										+ CRLF
		cHtml	+= "	   var marker = new google.maps.Marker({"																+ CRLF
		cHtml	+= "	      map: map,"																						+ CRLF
		cHtml	+= "	      position: latlng,"																				+ CRLF
		cHtml	+= "	      title: nome,"																						+ CRLF
		cHtml	+= "		  icon: icone"																						+ CRLF
		cHtml	+= "	   });"																									+ CRLF
		cHtml	+= "	   google.maps.event.addListener(marker, 'click', function() {"											+ CRLF
		cHtml	+= "	      var iwContent = '" + '<div id="iw_container">' + "' +"											+ CRLF
		cHtml	+= "		    '<div class=" + ' "iw_title"' + ">' + nome + '</div>' +"										+ CRLF
		cHtml	+= "		 '<div class=" + '"iw_content"'+ ">' + morada1 + '<br />' +"										+ CRLF
		cHtml	+= "		 morada2 + '<br />' +"																				+ CRLF
		cHtml	+= "		 codPostal + '</div></div>';"																		+ CRLF
		cHtml	+= "	      infoWindow.setContent(iwContent);"																+ CRLF
		cHtml	+= "	      infoWindow.open(map, marker);"																	+ CRLF
		cHtml	+= "	   });"																									+ CRLF
		cHtml	+= "	}"																										+ CRLF
		cHtml	+= "</script> "																									+ CRLF
		cHtml	+= " </head>"																									+ CRLF
		cHtml	+= "  <body>"																									+ CRLF
		cHtml	+= "     <div id='map-canvas'/>  </body>"																		+ CRLF
		cHtml	+= "</html>"																									+ CRLF

		If Select( "GEO") > 0
			GEO->(dbcloseArea())
			FErase( "GEO" + GetDbExtension())
		End If

		mostraMapa(cHtml)

	EndIf

Return Nil