#Include "totvs.ch"
#Include "TopConn.ch"
#define _crlf chr(13)+Chr(10)

#define F_BLOCK  512

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCTBRA01  ºAutor  ³Lucas Flóridi Leme  º Data ³  05/07/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Razão contábil em excel                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus 11                                                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function RCTBXD03()
	//Cria o MsApp
	MsApp():New('SIGAFAT')
	oApp:CreateEnv()
	//Seta o tema do Protheus (SUNSET = Vermelho; OCEAN = Azul)
	PtSetTheme("SUNSET")
	//Define o programa de inicialização
	oApp:bMainInit:= {|| MsgRun("Configurando ambiente...","Aguarde...",;
		{|| RpcSetEnv("01","0201"), }),;
		U_RCTBR003(),;
		Final("TERMINO NORMAL")}
	//Seta Atributos
	__lInternet := .T.
	lMsFinalAuto := .F.
	oApp:lMessageBar:= .T.
	oApp:cModDesc:= 'SIGAFAT'

	//Inicia a Janela
	oApp:Activate()
Return Nil

User Function RCTBR003()
	Local cPerg		:= PadR("RCTBRR03",10)

	AjustaSx1(cPerg)
	If Pergunte(cPerg,.T.)

		Processa( {|| MexProcessa() },"Aguarde" ,"Processando...")
		//	Processa( {|| GeraExcel("TMP") },"Aguarde" ,"Gerando arquivo excel...")

	EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MexProcessºAutor  ³Microsiga           º Data ³  08/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MexProcessa()
	Local _x
	Local cTexto := ""
	Local _aStruct := {}

	createView()

	cQry := " SELECT * "
	cQry += " FROM V_MOV_ESTOQUE "
	cQry += " WHERE DT_EMISSAO BETWEEN '"+DTOS(MV_PAR01) +"' AND '"+DTOS(MV_PAR02)+"' "


	Memowrite("RCTBR003.txt",cQry)
	TcQuery cQry New Alias "QRY1"

	// TcSetField("QRY1","DEBITO","N",TamSx3("CT2_VALOR")[1],2)
	// TcSetField("QRY1","CREDITO","N",TamSx3("CT2_VALOR")[1],2)
	TcSetField("QRY1","DT_EMISSAO","D",8,0)
	TcSetField("QRY1","EMISSAO","D",8,0)

	DbSelectArea("QRY1")
	DbGotop()
	ProcRegua(QRY1->(RecCount()))
	If !QRY1->(Eof())
		_aStruct := QRY1->(DbStruct())
		cBuffer  := SPACE(F_BLOCK)
		//LOCAL nInfile    := FOPEN("Temp.txt", FO_READ)
		//LOCAL nOutfile   := FCREATE("\Newfile.txt", FC_NORMAL)
		lDone    := .F.
		nBytesR := 0
		_cArq := CRIATRAB(NIL,.F.)+".xml"
		nOutFile:=FCREATE(_carq,0)

		_aLinha := {}
		AADD(_aLinha,'<?xml version="1.0"?>')
		AADD(_aLinha,'<?mso-application progid="Excel.Sheet"?>')
		AADD(_aLinha,'<Workbook xmlns="urn:schemas-microsoft-com:office:spreadsheet"')
		AADD(_aLinha,' xmlns:o="urn:schemas-microsoft-com:office:office"')
		AADD(_aLinha,' xmlns:x="urn:schemas-microsoft-com:office:excel"')
		AADD(_aLinha,' xmlns:ss="urn:schemas-microsoft-com:office:spreadsheet"')
		AADD(_aLinha,' xmlns:html="http://www.w3.org/TR/REC-html40">')
		AADD(_aLinha,' <DocumentProperties xmlns="urn:schemas-microsoft-com:office:office">')
		AADD(_aLinha,'  <Author>Totvs</Author>')
		AADD(_aLinha,'  <LastAuthor>Totvs</LastAuthor>')
		AADD(_aLinha,'  <Created>2016-07-31T22:06:04Z</Created>')
		AADD(_aLinha,'  <Version>14.00</Version>')
		AADD(_aLinha,' </DocumentProperties>')
		AADD(_aLinha,' <OfficeDocumentSettings xmlns="urn:schemas-microsoft-com:office:office">')
		AADD(_aLinha,'  <AllowPNG/>')
		AADD(_aLinha,' </OfficeDocumentSettings>')
		AADD(_aLinha,' <ExcelWorkbook xmlns="urn:schemas-microsoft-com:office:excel">')
		AADD(_aLinha,'  <WindowHeight>12660</WindowHeight>')
		AADD(_aLinha,'  <WindowWidth>28620</WindowWidth>')
		AADD(_aLinha,'  <WindowTopX>120</WindowTopX>')
		AADD(_aLinha,'  <WindowTopY>45</WindowTopY>')
		AADD(_aLinha,'  <ProtectStructure>False</ProtectStructure>')
		AADD(_aLinha,'  <ProtectWindows>False</ProtectWindows>')
		AADD(_aLinha,' </ExcelWorkbook>')
		AADD(_aLinha,' <Styles>')
		AADD(_aLinha,'  <Style ss:ID="Default" ss:Name="Normal">')
		AADD(_aLinha,'   <Alignment ss:Vertical="Bottom"/>')
		AADD(_aLinha,'   <Borders/>')
		AADD(_aLinha,'   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>')
		AADD(_aLinha,'   <Interior/>')
		AADD(_aLinha,'   <NumberFormat/>')
		AADD(_aLinha,'   <Protection/>')
		AADD(_aLinha,'  </Style>')
		AADD(_aLinha,'  <Style ss:ID="sText">')
		AADD(_aLinha,'   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>')
		AADD(_aLinha,'   <Borders>')
		AADD(_aLinha,'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"')
		AADD(_aLinha,'     ss:Color="#B8CCE4"/>')
		AADD(_aLinha,'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"')
		AADD(_aLinha,'     ss:Color="#B8CCE4"/>')
		AADD(_aLinha,'   </Borders>')
		AADD(_aLinha,'   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>')
		AADD(_aLinha,'   <Interior/>')
		AADD(_aLinha,'  </Style>')
		AADD(_aLinha,'  <Style ss:ID="sDate">')
		AADD(_aLinha,'   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>')
		AADD(_aLinha,'   <Borders>')
		AADD(_aLinha,'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"')
		AADD(_aLinha,'     ss:Color="#B8CCE4"/>')
		AADD(_aLinha,'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"')
		AADD(_aLinha,'     ss:Color="#B8CCE4"/>')
		AADD(_aLinha,'   </Borders>')
		AADD(_aLinha,'   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>')
		AADD(_aLinha,'   <Interior/>')
		AADD(_aLinha,'   <NumberFormat ss:Format="Short Date"/>')
		AADD(_aLinha,'  </Style>')
		AADD(_aLinha,'  <Style ss:ID="sNumero">')
		AADD(_aLinha,'   <Alignment ss:Horizontal="Right" ss:Vertical="Bottom"/>')
		AADD(_aLinha,'   <Borders>')
		AADD(_aLinha,'    <Border ss:Position="Left" ss:LineStyle="Continuous" ss:Weight="1"')
		AADD(_aLinha,'     ss:Color="#B8CCE4"/>')
		AADD(_aLinha,'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"')
		AADD(_aLinha,'     ss:Color="#B8CCE4"/>')
		AADD(_aLinha,'   </Borders>')
		AADD(_aLinha,'   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#000000"/>')
		AADD(_aLinha,'   <Interior/>')
		AADD(_aLinha,'   <NumberFormat ss:Format="_-* #,##0.00_-;\-* #,##0.00_-;_-* &quot;-&quot;??_-;_-@_-"/>')
		AADD(_aLinha,'  </Style>')
		AADD(_aLinha,'  <Style ss:ID="sTitulo">')
		AADD(_aLinha,'   <Alignment ss:Horizontal="Left" ss:Vertical="Bottom"/>')
		AADD(_aLinha,'   <Borders>')
		AADD(_aLinha,'    <Border ss:Position="Right" ss:LineStyle="Continuous" ss:Weight="1"')
		AADD(_aLinha,'     ss:Color="#4F81BD"/>')
		AADD(_aLinha,'    <Border ss:Position="Top" ss:LineStyle="Continuous" ss:Weight="1"')
		AADD(_aLinha,'     ss:Color="#4F81BD"/>')
		AADD(_aLinha,'   </Borders>')
		AADD(_aLinha,'   <Font ss:FontName="Calibri" x:Family="Swiss" ss:Size="11" ss:Color="#FFFFFF"')
		AADD(_aLinha,'    ss:Bold="1"/>')
		AADD(_aLinha,'   <Interior ss:Color="#4F81BD" ss:Pattern="Solid"/>')
		AADD(_aLinha,'  </Style>')
		AADD(_aLinha,' </Styles>')
		AADD(_aLinha,' <Worksheet ss:Name="Movimento de Estoque">')
		AADD(_aLinha,'  <Table ss:ExpandedColumnCount="'+Alltrim(Str(Len(_aStruct)))+'" ss:ExpandedRowCount="1048576" x:FullColumns="1"')
		AADD(_aLinha,'   x:FullRows="1" ss:DefaultRowHeight="15">')
		AADD(_aLinha,'   <Column ss:Width="32.25"/>')

		/*
		AADD(_aLinha,'   <Column ss:Width="44.25"/>')
		AADD(_aLinha,'   <Column ss:Width="15.75"/>')
		AADD(_aLinha,'   <Column ss:Width="69"/>')
		AADD(_aLinha,'   <Column ss:Width="69"/>')
		AADD(_aLinha,'   <Column ss:Width="43.5" ss:Span="1"/>')
		AADD(_aLinha,'   <Column ss:Index="7" ss:Width="27.75"/>')
		AADD(_aLinha,'   <Column ss:Width="35.25"/>')
		AADD(_aLinha,'   <Column ss:Width="42"/>')
		AADD(_aLinha,'   <Column ss:Width="56.25"/>')
		AADD(_aLinha,'   <Column ss:Width="34.5"/>')
		AADD(_aLinha,'   <Column ss:Width="21"/>')
		AADD(_aLinha,'   <Column ss:Width="66"/>')
		AADD(_aLinha,'   <Column ss:Width="48.75"/>')
		AADD(_aLinha,'   <Column ss:Width="54.75"/>')
		AADD(_aLinha,'   <Column ss:Width="324"/>')
		AADD(_aLinha,'   <Column ss:Width="27"/>')
		AADD(_aLinha,'   <Column ss:Width="22.5"/>')
		AADD(_aLinha,'   <Column ss:Width="27.75"/>')
		AADD(_aLinha,'   <Column ss:Width="69"/>')
		AADD(_aLinha,'   <Column ss:Width="24"/>')
		AADD(_aLinha,'   <Column ss:Width="108.75"/>')
		AADD(_aLinha,'   <Column ss:Width="69.75" ss:Span="1"/>')
		AADD(_aLinha,'   <Column ss:Index="25" ss:Width="45.75"/>')
		AADD(_aLinha,'   <Column ss:Width="32.25"/>')
		AADD(_aLinha,'   <Column ss:Width="37.5"/>')
		AADD(_aLinha,'   <Column ss:Width="42" ss:Span="1"/>')
		AADD(_aLinha,'   <Column ss:Index="30" ss:Width="35.25"/>')
		AADD(_aLinha,'   <Column ss:Width="60.75"/>')
		AADD(_aLinha,'   <Column ss:Width="60.75"/>')
		*/

		For _x := 1 to Len(_aLinha)
			cBuffer := _aLinha[_x]+=CHR(10)
			FWRITE(nOutfile, cBuffer, Len(cBuffer))
		Next
		_aLinha := {}
		AADD(_aLinha,'   <Row ss:AutoFitHeight="0">')
		For _x:= 1 to Len(_aStruct)
			AADD(_aLinha,'    <Cell ss:StyleID="sTitulo"><Data ss:Type="String">'+_aStruct[_x,1]+'</Data></Cell>')
		Next
		AADD(_aLinha,'   </Row>')

		For _x := 1 to Len(_aLinha)
			cBuffer := _aLinha[_x]+=CHR(10)
			FWRITE(nOutfile, cBuffer, Len(cBuffer))
		Next
		While !QRY1->(Eof())
			_aLinha := {}
			AADD(_aLinha,'   <Row ss:AutoFitHeight="0">')
			For _x := 1 to Len(_aStruct)
				_cCpo := Alltrim(_aStruct[_x,1])
				If _cCpo $ "DT_EMISSAO11"
					AADD(_aLinha,'    <Cell ss:StyleID="sDate"><Data ss:Type="DateTime">'+STUFF(STUFF(dtos(QRY1->&(_cCpo)),7,0,"-"),5,0,"-")+'</Data></Cell>')
				ElseIf _aStruct[_x,2] == "D"
					If Empty(QRY1->&(_cCpo))
						AADD(_aLinha,'    <Cell ss:StyleID="sDate"/>')
					Else
						AADD(_aLinha,'    <Cell ss:StyleID="sDate"><Data ss:Type="DateTime">'+STUFF(STUFF(dtos(QRY1->&(_cCpo)),7,0,"-"),5,0,"-")+'</Data></Cell>')
					EndIf
				ElseIf _cCpo == "HISTORICO2"
					AADD(_aLinha,'    <Cell ss:StyleID="sText"><Data ss:Type="String">'+'teste'+'</Data></Cell>')
				ElseIf _aStruct[_x,2] == "N"
					AADD(_aLinha,'    <Cell ss:StyleID="sNumero"><Data ss:Type="Number">'+CVALTOCHAR(QRY1->&(_cCpo))+'</Data></Cell>')
				ElseIf _aStruct[_x,2] == "C"
					cTexto := UPPER(NoAcento(ALLTRIM(oemtoansi(QRY1->&(_cCpo)))))
					If "&" $ cTexto	//	27/01/25 - Substituindo "&" por "e", para evitar o ERROR.LOG
						cTexto := StrTran(cTexto, "&", "e")
					Endif
					AADD(_aLinha,'    <Cell ss:StyleID="sText"><Data ss:Type="String">'+cTexto+'</Data></Cell>')
				Else
					AADD(_aLinha,'    <Cell ss:StyleID="sText"><Data ss:Type="String">'+ALLTRIM(QRY1->&(_cCpo))+'</Data></Cell>')
				EndIf
			Next
			AADD(_aLinha,'   </Row>')
			For _x := 1 to Len(_aLinha)
				cBuffer := _aLinha[_x]+=CHR(10)
				FWRITE(nOutfile, cBuffer, Len(cBuffer))
			Next
			QRY1->(DbSkip())
		EndDo
		_aLinha := {}
		AADD(_aLinha,'  </Table>')
		AADD(_aLinha,'  <WorksheetOptions xmlns="urn:schemas-microsoft-com:office:excel">')
		AADD(_aLinha,'   <PageSetup>')
		AADD(_aLinha,'    <Header x:Margin="0.31496062000000002"/>')
		AADD(_aLinha,'    <Footer x:Margin="0.31496062000000002"/>')
		AADD(_aLinha,'    <PageMargins x:Bottom="0.78740157499999996" x:Left="0.511811024"')
		AADD(_aLinha,'     x:Right="0.511811024" x:Top="0.78740157499999996"/>')
		AADD(_aLinha,'   </PageSetup>')
		AADD(_aLinha,'   <Unsynced/>')
		AADD(_aLinha,'   <Selected/>')
		AADD(_aLinha,'   <ProtectObjects>False</ProtectObjects>')
		AADD(_aLinha,'   <ProtectScenarios>False</ProtectScenarios>')
		AADD(_aLinha,'  </WorksheetOptions>')
		AADD(_aLinha,' </Worksheet>')
		AADD(_aLinha,'</Workbook>')

		For _x := 1 to Len(_aLinha)
			cBuffer := _aLinha[_x]+=CHR(10)
			FWRITE(nOutfile, cBuffer, Len(cBuffer))
		Next
		FCLOSE(nOutfile)

		_cFileTMP := (GetTempPath() + _cArq)
		//Processa({||__CopyFile("\SIGAADV\"+_cArq , _cFileTMP),"Copiando para o seu computador!!!"})
		cpys2t("\system\"+_cArq , GetTempPath(),.T.)
		Ferase("\system\"+_cArq)
		ShellExecute("open",_cArq,"",GetTempPath(), 1 )
		showLog(GetTempPath()+_cArq)
	Else
		Alert("Não há dados!!!")
	EndIf
	QRY1->(DbCloseArea())

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1 ºAutor  ³                    º Data ³  02/06/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1(cPerg)
	Local aRea	:= GetArea()
	Local aSx1	:= {}
	Local i := 0

	DBSelectArea("SX1")
	SX1->(DBSetOrder(1))
	cPerg := PadR(cPerg, Len(SX1->X1_GRUPO))
	SX1->(DBSeek(cPerg+"01"))
	// AADD(	aSx1,{ cPerg,"01","De Filial?"		,"mv_par01"	,"C",TAMSX3("CT1_FILIAL")[1],0,0,"G","",	"mv_par01","","","","","SM0_01","" } )
	// AADD(	aSx1,{ cPerg,"02","Ate Filial?"		,"mv_par02"	,"C",TAMSX3("CT1_FILIAL")[1],0,0,"G","",	"mv_par02","","","","","SM0_01","" } )

	AADD(	aSx1,{ cPerg,"01","De Data?"		,"mv_par01"	,"D",8,0,0,"G","", 	"mv_par01","","","","","","" } )
	AADD(	aSx1,{ cPerg,"02","Ate Data?"		,"mv_par02"	,"D",8,0,0,"G","",	"mv_par02","","","","","","" } )
	// AADD(	aSx1,{ cPerg,"05","De Conta?"		,"mv_par05"	,"C",TAMSX3("CT1_CONTA")[1],0,0,"G","",	"mv_par05","","","","","CT1","" } )
	// AADD(	aSx1,{ cPerg,"06","Ate Conta?"		,"mv_par06"	,"C",TAMSX3("CT1_CONTA")[1],0,0,"G","",	"mv_par06","","","","","CT1","" } )

	If SX1->X1_GRUPO != cPerg
		For I := 1 To Len( aSx1 )
			If !SX1->( DBSeek( aSx1[I][1] + aSx1[I][2] ) )
				Reclock( "SX1", .T. )
				SX1->X1_GRUPO   := aSx1[i][1] //Grupo
				SX1->X1_ORDEM   := aSx1[i][2] //Ordem do campo
				SX1->X1_PERGUNT := aSx1[i][3] //Pergunta
				SX1->X1_PERSPA  := aSx1[i][3] //Pergunta Espanhol
				SX1->X1_PERENG  := aSx1[i][3] //Pergunta Ingles
				SX1->X1_VARIAVL := aSx1[i][4] //Variavel do campo
				SX1->X1_TIPO    := aSx1[i][5] //Tipo de valor
				SX1->X1_TAMANHO := aSx1[i][6] //Tamanho do campo
				SX1->X1_DECIMAL := aSx1[i][7] //Formato numerico
				SX1->X1_PRESEL  := aSx1[i][8] //Pre seleção do combo
				SX1->X1_GSC     := aSx1[i][9] //Tipo de componente
				SX1->X1_VAR01   := aSx1[i][10]//Variavel que carrega resposta
				SX1->X1_DEF01   := aSx1[i][11]//Definições do combo-box
				SX1->X1_DEF02   := aSx1[i][12]
				SX1->X1_DEF03   := aSx1[i][13]
				SX1->X1_DEF04   := aSx1[i][14]
				SX1->X1_VALID   := aSx1[i][15]
				SX1->X1_F3      := aSx1[i][16]
				MsUnlock()
			Endif
		Next
	Endif

	RestArea(aRea)

Return(cPerg)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³GeraExcel ºAutor  ³                    º Data ³  05/12/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Geracao de arquivo excel 						              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function GeraExcel(cAlias)
	Local _cPathExcel:="C:\MICROSIGA\"

	dbSelectArea(cAlias)

	_cTmp := CriaTrab(,.F.)

	COPY TO (_cTmp) VIA "DBFCDXADS"

	DbUseArea( .t., "DBFCDXADS", _cTmp, "EXC", .F. )

	dbSelectArea("EXC")
	dbCloseArea()

	dbSelectArea(cAlias)
	dbCloseArea()

	//Inicio da Planilha Excel
	cArqTRB := _cTmp+".DBF"
	MontaDir(_cPathExcel)

	If File(_cPathExcel+cArqTRB)
		FErase(_cPathExcel+cArqTRB)
	EndIf
	__CopyFile("\SYSTEM\"+cArqTRB,_cPathExcel+cArqTRB)
	FRename(_cPathExcel+cArqTRB,_cPathExcel+_cTmp+".xls") // Renomeia para excel
	If File(_cPathExcel+_cTmp+".xls")
		If ! ApOleClient( 'MsExcel' )
			MsgAlert( 'MsExcel nao instalado' )
		Else
			oExcelApp := MsExcel():New()
			oExcelApp:WorkBooks:Open( _cPathExcel+_cTmp+".xls") // Abre uma planilha
			oExcelApp:SetVisible(.T.)
		EndIf
	Else
		MsgAlert("Problema ao gerar o Arquivo!!!")
	EndIf
	fErase(_cTmp+GetDBExtension())
	fErase(_cTmp+OrdbagExt())

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RCTBR003  ºAutor  ³Microsiga           º Data ³  07/31/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static FUNCTION NoAcento(cString)
	Local cChar  := ""
	Local nX     := 0
	Local nY     := 0
	Local cVogal := "aeiouAEIOU"
	Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
	Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
	Local cTrema := "äëïöü"+"ÄËÏÖÜ"
	Local cCrase := "àèìòù"+"ÀÈÌÒÙ"
	Local cTio   := "ãõÃÕ"
	Local cCecid := "çÇ"
	Local cMaior := "&lt;"
	Local cMenor := "&gt;"

	For nX:= 1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
			nY:= At(cChar,cAgudo)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCircu)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTrema)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cCrase)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
			EndIf
			nY:= At(cChar,cTio)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
			EndIf
			nY:= At(cChar,cCecid)
			If nY > 0
				cString := StrTran(cString,cChar,SubStr("cC",nY,1))
			EndIf
		Endif
	Next

	If cMaior$ cString
		cString := strTran( cString, cMaior, "" )
	EndIf
	If cMenor$ cString
		cString := strTran( cString, cMenor, "" )
	EndIf

	cString := StrTran( cString, CRLF, " " )

	For nX:=1 To Len(cString)
		cChar:=SubStr(cString, nX, 1)
		If (Asc(cChar) < 32 .Or. Asc(cChar) > 123) .and. !cChar $ '|'
			cString:=StrTran(cString,cChar,".")
		Endif
	Next nX
Return cString


static function createView()

	local cQry := ""
	cQry += "CREATE OR ALTER VIEW [dbo].[V_MOV_ESTOQUE] " + _crlf
	cQry += "AS " + _crlf
	cQry += "SELECT 'ESTOQUE' MODULO, D3_FILIAL AS FILIAL, 'SD3' ORIGEM, CASE WHEN D3_TM < '500' THEN 'E' ELSE 'S' END AS 'ES', '' TIPODOC, D3_DOC DOCUMENTO,ISNULL(C2_RECURSO,'') RECURSO,D3_OP OP,ISNULL(C2_BATROT,'') ROTINA,ISNULL(C2_LOCAL,'') LOCAL_OP" + _crlf
	cQry += ",'' CLIFOR, '' NOME, D3_NUMSEQ SEQUEN,D3_SEQCALC SEQCALC " + _crlf
	cQry += ",CONVERT(DATE,D3_EMISSAO) DT_EMISSAO, D3_EMISSAO AS EMISSAO, D3_LOCAL AS 'LOCAL', D3_TM TES, ISNULL(F5_VAL, '-') VALORIZADO, 'S' AS ESTOQUE,'' PODER3,'' IDENTB6, D3_COD PRODUTO, B1_DESC DESCRIC,B1_GRUPO ID_GRUPO,ISNULL(BM_DESC,'') GRUPO,B1_CONTA CONTA, B1_POSIPI NCM  " + _crlf
	cQry += ",B1_TIPO TIPO, D3_UM UM, D3_LOTECTL LOTE, CASE WHEN D3_TM < 500 THEN D3_QUANT ELSE - D3_QUANT END QUANTIDADE,D3_QTSEGUM QTSEGUM, D3_CF CFO  " + _crlf
	cQry += ",CASE WHEN D3_TM <= '499' THEN 1 ELSE - 1 END * D3_CUSTO1 CUSTO,IIF(D3_QUANT>0,D3_CUSTO1/D3_QUANT,0) CM_UNITARIO, D3_CUSTO1 AS TOTAL, 0 AS DESPESA, 0 AS FRETE, 0 AS VALPIS, 0 AS VALCOF, 0 AS VALICM, 0 AS VALIPI  " + _crlf
	cQry += ",SD3.R_E_C_N_O_ REGISTRO,  '' TIPO_DOC ,ISNULL(C2_XCODSZ2,D3_XCODSZ2) TICKET,'' NFORIG,'' SERIE_ORI,'' ITEM_ORI ,CONVERT(DATE,NULL) DT_NFORI" + _crlf
	cQry += ",(SELECT MAX(D1_CF) FROM SD1010 SD1 WHERE SD1.D_E_L_E_T_='' AND D1_XCODSZ2=ISNULL(C2_XCODSZ2,D3_XCODSZ2) AND D1_XCODSZ2<>'') CFOP_REMESSA" + _crlf
	cQry += "FROM SD3010 SD3  " + _crlf
	cQry += "	INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_ ='' AND B1_FILIAL = SUBSTRING(D3_FILIAL,1,2) AND B1_COD = D3_COD " + _crlf
	cQry += "	LEFT JOIN SBM010 SBM ON SBM.D_E_L_E_T_='' AND BM_GRUPO=B1_GRUPO" + _crlf
	cQry += "	LEFT JOIN SF5010 SF5 ON SF5.D_E_L_E_T_ ='' AND F5_FILIAL=D3_FILIAL AND F5_CODIGO = D3_TM  " + _crlf
	cQry += "	LEFT JOIN SC2010 SC2 ON SC2.D_E_L_E_T_ ='' AND C2_FILIAL=D3_FILIAL AND C2_NUM+C2_ITEM+C2_SEQUEN = D3_OP  " + _crlf
	cQry += "WHERE        SD3.D_E_L_E_T_ ='' AND D3_ESTORNO <> 'S' " + _crlf
	cQry += "UNION ALL " + _crlf
	cQry += "SELECT CASE D1_TIPO WHEN 'D' THEN 'DEVOLUCAO DE VENDAS' ELSE 'COMPRAS' END MODULO, D1_FILIAL, 'SD1' ORIGEM, F4_TIPO AS ES, D1_TIPO TIPODOC, D1_DOC,'' RECURSO,D1_OP OP ,'' ROTINA,'' LOCAL_OP " + _crlf
	cQry += ",D1_FORNECE CLIFOR,CASE D1_TIPO WHEN 'D' THEN A1_NOME WHEN 'B' THEN A1_NOME ELSE A2_NOME END NOME, D1_NUMSEQ,D1_SEQCALC SEQCALC, CONVERT(DATE, D1_DTDIGIT) DT_EMISSAO, D1_DTDIGIT AS EMISSAO, D1_LOCAL, D1_TES  " + _crlf
	cQry += ",F4_DUPLIC AS F5_VAL, F4_ESTOQUE AS ESTOQUE,F4_PODER3,D1_IDENTB6 , D1_COD, B1_DESC DESCRIC,B1_GRUPO ID_GRUPO,ISNULL(BM_DESC,'') GRUPO,B1_CONTA CONTA, B1_POSIPI NCM, B1_TIPO, D1_UM, D1_LOTECTL LOTE, D1_QUANT,D1_QTSEGUM QTSEGUM, D1_CF, D1_CUSTO,IIF(D1_QUANT>0,D1_CUSTO/D1_QUANT,0) CM_UNITARIO, D1_TOTAL AS TOTAL, D1_DESPESA  " + _crlf
	cQry += ",D1_VALFRE, D1_VALIMP6 AS VALPIS, D1_VALIMP5 AS VALCOF, D1_VALICM AS VALICM, D1_VALIPI AS VALIPI, SD1.R_E_C_N_O_,  D1_TIPO TIPO_DOC,D1_XCODSZ2 TICKET,D1_NFORI NFORIG, D1_SERIORI SERIE_ORI,D1_ITEMORI ITEMORI ,CONVERT(DATE,NULL) DT_NFORI" + _crlf
	cQry += ",'' CFOP_REMESSA" + _crlf
	cQry += "FROM SD1010 SD1  " + _crlf
	cQry += "	INNER JOIN SF4010 SF4 ON SF4.D_E_L_E_T_ ='' AND F4_FILIAL=SUBSTRING(D1_FILIAL,1,2) AND F4_CODIGO = D1_TES  " + _crlf
	cQry += "	INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_ ='' AND B1_FILIAL = SUBSTRING(D1_FILIAL,1,2) AND B1_COD = D1_COD  " + _crlf
	cQry += "	LEFT JOIN SBM010 SBM ON SBM.D_E_L_E_T_='' AND BM_GRUPO=B1_GRUPO" + _crlf
	cQry += "	LEFT OUTER JOIN SA1010 SA1 ON SA1.D_E_L_E_T_ ='' AND A1_COD = D1_FORNECE AND A1_LOJA = D1_LOJA  " + _crlf
	cQry += "	LEFT OUTER JOIN SA2010 SA2 ON SA2.D_E_L_E_T_ ='' AND A2_COD = D1_FORNECE AND A2_LOJA = D1_LOJA  " + _crlf
	cQry += "WHERE        SD1.D_E_L_E_T_ ='' " + _crlf
	cQry += "UNION ALL " + _crlf
	cQry += "SELECT        CASE D2_TIPO WHEN 'D' THEN 'DEVOLUCAO DE COMPRAS' ELSE 'VENDA' END MODULO, D2_FILIAL, 'SD2' ORIGEM, F4_TIPO AS ES, D2_TIPO TIPODOC, D2_DOC,'' RECURSO, '' OP, '' ROTINA,'' LOCAL_OP " + _crlf
	cQry += ",D2_CLIENTE CLIFOR,CASE D2_TIPO WHEN 'D' THEN A2_NOME WHEN 'F' THEN A2_NOME ELSE A1_NOME END NOME, D2_NUMSEQ,D2_SEQCALC SEQCALC, CONVERT(DATE, D2_EMISSAO) DT_EMISSAO, D2_EMISSAO AS EMISSAO, D2_LOCAL, D2_TES  " + _crlf
	cQry += ",F4_DUPLIC AS F5_VAL, F4_ESTOQUE AS ESTOQUE,F4_PODER3,D2_IDENTB6, D2_COD, B1_DESC DESCRIC,B1_GRUPO ID_GRUPO,ISNULL(BM_DESC,'') GRUPO,B1_CONTA CONTA, B1_POSIPI NCM, B1_TIPO, D2_UM, D2_LOTECTL LOTE, - D2_QUANT,D2_QTSEGUM QTSEGUM, D2_CF, D2_CUSTO1 * - 1,IIF(D2_QUANT>0,D2_CUSTO1/D2_QUANT,0) CM_UNITARIO, D2_TOTAL AS TOTAL  " + _crlf
	cQry += ",D2_DESPESA, D2_VALFRE, D2_VALIMP6 AS VALPIS, D2_VALIMP5 AS VALCOF, D2_VALICM AS VALICM, D2_VALIPI AS VALIPI, SD2.R_E_C_N_O_,  D2_TIPO TIPO_DOC,D2_XCODSZ2 TICKET,D2_NFORI NFORIG,D2_SERIORI SERIE_ORI,D2_ITEMORI ITEMORI ,CONVERT(DATE,ISNULL(D1_DTDIGIT,NULL)) DT_NFORI" + _crlf
	cQry += ",'' CFOP_REMESSA" + _crlf
	cQry += "FROM            SD2010 SD2  " + _crlf
	cQry += "	INNER JOIN SF4010 SF4 ON SF4.D_E_L_E_T_ ='' AND F4_CODIGO = D2_TES AND F4_FILIAL=SUBSTRING(D2_FILIAL,1,2) " + _crlf
	cQry += "	INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_ ='' AND B1_COD = D2_COD AND B1_FILIAL=SUBSTRING(D2_FILIAL,1,2) " + _crlf
	cQry += "	LEFT JOIN SBM010 SBM ON SBM.D_E_L_E_T_='' AND BM_GRUPO=B1_GRUPO" + _crlf
	cQry += "	LEFT JOIN SD1010 SD1 ON SD1.D_E_L_E_T_='' AND D1_FILIAL=D2_FILIAL AND D1_DOC=D2_NFORI AND D1_SERIE=D2_SERIORI AND D1_FORNECE=D2_CLIENTE AND D1_LOJA=D2_LOJA AND D1_ITEM=D2_ITEMORI" + _crlf
	cQry += "	LEFT OUTER JOIN SA1010 SA1 ON SA1.D_E_L_E_T_ ='' AND A1_COD = D2_CLIENTE AND A1_LOJA = D2_LOJA  " + _crlf
	cQry += "	LEFT OUTER JOIN SA2010 SA2 ON SA2.D_E_L_E_T_ ='' AND A2_COD = D2_CLIENTE AND A2_LOJA = D2_LOJA  " + _crlf
	cQry += "WHERE        SD2.D_E_L_E_T_ ='' " + _crlf

	If Funname() == "RMTXD01" .or. Funname() == "RPC" .or. funname() == ""
		Showlog(cQry)
	EndIf
	If TcSqlExec(cQry) < 0
		FWAlertError(TCSQLError())
	EndIF


Return
