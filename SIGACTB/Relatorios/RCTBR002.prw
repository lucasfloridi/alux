#INCLUDE 'totvs.ch'
#INCLUDE 'TOPCONN.ch'

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±Desc.     Relatatorio de notas de saida e entrada - conferencia contabil       		                     ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

User Function RCTBR002()

	Local cPerg		:= PadR("RCTBR002",10)

	AjustaSx1(cPerg)
	If Pergunte(cPerg,.T.)

		Processa( {|| Plan02() },"Aguarde" ,"Processando...")

	EndIf

Return()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±Desc.     AjustaSX1					       		                     ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/

Static Function AjustaSX1(cPerg)

	Local aRea	:= GetArea()
	Local aSx1	:= {}
	local i:=0

	DBSelectArea("SX1")
	SX1->(DBSetOrder(1))
	cPerg := PadR(cPerg, Len(SX1->X1_GRUPO))
	SX1->(DBSeek(cPerg+"01"))
	AADD(	aSx1,{ cPerg,"01","Data De?"			    ,"mv_par01"	,"D",8,0,0, "G","", 	"mv_par01","","","","","","" } )
	AADD(	aSx1,{ cPerg,"02","Data Até?"			    ,"mv_par02"	,"D",8,0,0, "G","",		"mv_par02","","","","","","" } )
	AADD(	aSx1,{ cPerg,"03","Fornec/Cliente De?"		,"mv_par03"	,"C",6,0,0, "G","",		"mv_par03","","","","","","" } )
	AADD(	aSx1,{ cPerg,"04","Fornec/Cliente Até?"		,"mv_par04"	,"C",6,0,0, "G","",		"mv_par04","","","","","","" } )
	AADD(	aSx1,{ cPerg,"05","Loja De?"				,"mv_par05"	,"C",2,0,0, "G","",		"mv_par05","","","","","","" } )
	AADD(	aSx1,{ cPerg,"06","Loja Até?"				,"mv_par06"	,"C",2,0,0, "G","",		"mv_par06","","","","","","" } )
	AADD(	aSx1,{ cPerg,"07","Produto De?"				,"mv_par07"	,"C",15,0,0, "G","",	"mv_par07","","","","","SB1","" } )
	AADD(	aSx1,{ cPerg,"08","Produto Até?"			,"mv_par08"	,"C",15,0,0, "G","",	"mv_par08","","","","","SB1","" } )
	AADD(	aSx1,{ cPerg,"09","Filial De?"		 		,"mv_par09"	,"C",4,0,0, "G","", 	"mv_par09","","","","","","" } )
	AADD(	aSx1,{ cPerg,"10","Filial Até?"				,"mv_par10"	,"C",4,0,0, "G","",		"mv_par10","","","","","","" } )

	If SX1->X1_GRUPO != cPerg
		For I := 1 To Len( aSx1 )
			If !SX1->( DBSeek( aSx1[I][1] + aSx1[I][2] ) )
				Reclock( "SX1", .T. )
				SX1->X1_GRUPO		:= aSx1[i][1] //Grupo
				SX1->X1_ORDEM		:= aSx1[i][2] //Ordem do campo
				SX1->X1_PERGUNT		:= aSx1[i][3] //Pergunta
				SX1->X1_PERSPA		:= aSx1[i][3] //Pergunta Espanhol
				SX1->X1_PERENG		:= aSx1[i][3] //Pergunta Ingles
				SX1->X1_VARIAVL		:= aSx1[i][4] //Variavel do campo
				SX1->X1_TIPO		:= aSx1[i][5] //Tipo de valor
				SX1->X1_TAMANHO		:= aSx1[i][6] //Tamanho do campo
				SX1->X1_DECIMAL		:= aSx1[i][7] //Formato numerico
				SX1->X1_PRESEL		:= aSx1[i][8] //Pre seleção do combo
				SX1->X1_GSC			:= aSx1[i][9] //Tipo de componente
				SX1->X1_VAR01		:= aSx1[i][10]//Variavel que carrega resposta
				SX1->X1_DEF01		:= aSx1[i][11]//Definições do combo-box
				SX1->X1_DEF02		:= aSx1[i][12]
				SX1->X1_DEF03		:= aSx1[i][13]
				SX1->X1_DEF04		:= aSx1[i][14]
				SX1->X1_VALID		:= aSx1[i][15]
				SX1->X1_F3			:= aSx1[i][16]
				MsUnlock()
			Endif
		Next
	Endif

	RestArea(aRea)

Return(cPerg)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±Desc.     Planilha 02					       		                     ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/


Static Function Plan02()
	Local _cPathExcel:=cGetFile( '*.xml' , 'Excel (XML)', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_LOCALFLOPPY, GETF_RETDIRECTORY ),.T., .T. )
	Local  _cPath 	  := AllTrim(GetTempPath())
	Local  _cArquivo  := CriaTrab(,.F.)
	Local oExcel := Fwmsexcel():new()
	Local oFWMsExcel
	Local cURLXML:= ''
	Local cQuery:=""

	Private _nHandle  := FCreate(_cArquivo)

	cQuery += "SELECT  " + Chr(13)
	cQuery += "'NF_SAIDA' ORIGEM, " + Chr(13)
	cQuery += "D2_FILIAL FILIAL,  " + Chr(13)
	cQuery += "SUBSTRING(D2_EMISSAO,7,2) + '/' + SUBSTRING(D2_EMISSAO,5,2) + '/' + SUBSTRING(D2_EMISSAO,1,4) DATA_NF,  " + Chr(13)
	cQuery += "D2_SERIE SERIE,  " + Chr(13)
	cQuery += "D2_DOC NOTA,  " + Chr(13)
	cQuery += "D2_TIPO TIPO_NF,  " + Chr(13)
	cQuery += "D2_CLIENTE CLI_FORN,  " + Chr(13)
	cQuery += "D2_LOJA LJ_CLI_FORN,  " + Chr(13)
	cQuery += "CASE WHEN D2_TIPO <> 'B' AND D2_TIPO <> 'D' " + Chr(13)
	cQuery += "THEN (SELECT A1_NOME FROM  SA1010  WHERE D_E_L_E_T_ ='' AND A1_COD = SD2.D2_CLIENTE AND A1_LOJA = SD2.D2_LOJA)   " + Chr(13)
	cQuery += "ELSE (SELECT A2_NOME FROM SA2010 WHERE D_E_L_E_T_ ='' AND A2_COD = SD2.D2_CLIENTE AND A2_LOJA = SD2.D2_LOJA) END N_CLI_FORN,    " + Chr(13)
	cQuery += "CASE WHEN D2_TIPO <> 'B' AND D2_TIPO <> 'D' " + Chr(13)
	cQuery += "THEN (SELECT A1_TIPO FROM  SA1010  WHERE D_E_L_E_T_ ='' AND A1_COD = SD2.D2_CLIENTE AND A1_LOJA = SD2.D2_LOJA)   " + Chr(13)
	cQuery += "ELSE (SELECT A2_TIPO FROM SA2010 WHERE D_E_L_E_T_ ='' AND A2_COD = SD2.D2_CLIENTE AND A2_LOJA = SD2.D2_LOJA) END TP_CLI_FORN,    " + Chr(13)
	cQuery += "D2_EST UF_CLI_FORN,  " + Chr(13)
	cQuery += "D2_COD COD_PROD,  " + Chr(13)
	cQuery += "B1_DESC PRODUTO,  " + Chr(13)
	cQuery += "B1_POSIPI NCM,  " + Chr(13)
	cQuery += "D2_QUANT QUANT,  " + Chr(13)
	cQuery += "D2_PRUNIT VLR_UNIT,  " + Chr(13)
	cQuery += "D2_TOTAL TOTAL,  " + Chr(13)
	cQuery += "D2_LOTECTL LOTE,  " + Chr(13)
	cQuery += "SUBSTRING(D2_DTVALID,7,2) + '/' + SUBSTRING(D2_DTVALID,5,2) + '/' + SUBSTRING(D2_DTVALID,1,4) DT_LOTE, D2_TES TES,  " + Chr(13)
	cQuery += "D2_CF CFOP,  " + Chr(13)
	cQuery += "F4_DUPLIC DUPLICATA,  " + Chr(13)
	cQuery += "F4_ESTOQUE ESTOQUE,  " + Chr(13)
	cQuery += "F4_PODER3 PODTERC,  " + Chr(13)
	cQuery += "D2_CLASFIS CLASFIS,  " + Chr(13)
	cQuery += "D2_SERIORI SERIE_ORIG,  " + Chr(13)
	cQuery += "D2_NFORI NF_ORIG,  " + Chr(13)
	cQuery += "D2_ITEMORI IT_NF_ORIG,  " + Chr(13)
	cQuery += "D2_PICM ALIQICMS,  " + Chr(13)
	cQuery += "D2_VALICM VLRICMS,  " + Chr(13)
	cQuery += "F4_CREDICM APURICMS,  " + Chr(13)
	cQuery += "D2_VALISS VLR_ISS,  " + Chr(13)
	cQuery += "D2_ICMSRET ICMS_ST,  " + Chr(13)
	cQuery += "D2_IPI ALIQIPI,  " + Chr(13)
	cQuery += "D2_VALIPI VLRIPI,  " + Chr(13)
	cQuery += "F4_CREDIPI APURIPI,  " + Chr(13)
	cQuery += "D2_ALQIMP5 ALQCOFINS,  " + Chr(13)
	cQuery += "D2_BASIMP5 BCCOFINS,  " + Chr(13)
	cQuery += "D2_VALIMP5 VLRCOFINS,  " + Chr(13)
	cQuery += "D2_ALQIMP6 ALQPIS,  " + Chr(13)
	cQuery += "D2_BASIMP6 BCPIS,  " + Chr(13)
	cQuery += "D2_VALIMP6 VLRPIS,  " + Chr(13)
	cQuery += "D2_IDENTB6 IDPTERC,  " + Chr(13)
	cQuery += "D2_VALFRE VLRFRETE,  " + Chr(13)
	cQuery += "D2_CUSTO1 VLRCUSTO,  " + Chr(13)
	cQuery += "B1_GRTRIB GRPTRIB,  " + Chr(13)
	cQuery += "SB1.B1_CONTA B1_CONTA,  " + Chr(13)
	cQuery += "CT1SB1.CT1_DESC01 B1_DESC_CONTA,  " + Chr(13)
	cQuery += "'' SD_CONTA,  " + Chr(13)
	cQuery += "'' SD_DESC_CONTA,  " + Chr(13)
	cQuery += "D2_DESC VLRDESCTO,  " + Chr(13)
	cQuery += "D2_DESPESA DESPESA, " + Chr(13)
	cQuery += "'' COFMAJOR,  " + Chr(13)
	cQuery += "D2_DIFAL D_ICMS_D,  " + Chr(13)
	cQuery += "D2_VFCPDIF V_FECP,  " + Chr(13)
	cQuery += "D2_PEDIDO + '/' + D2_ITEMPV PEDIDO, " + Chr(13)
	cQuery += "F2_CHVNFE CHAVE_NFE,  " + Chr(13)
	cQuery += "F4_PISCOF PISCOF,  " + Chr(13)
	cQuery += "F4_PISCRED PISCRED,  " + Chr(13)
	cQuery += "F4_CSTPIS CSTPIS,  " + Chr(13)
	cQuery += "F4_CSTCOF CSTCOF,  " + Chr(13)
	cQuery += "D2_BASEICM BS_ICMS,  " + Chr(13)
	cQuery += "D2_BASEIPI BS_IPI, " + Chr(13)
	cQuery += "D2_ICMSCOM D_ICMS_P,  " + Chr(13)
	cQuery += "F2_GNRDIF GNRE_DIF,  " + Chr(13)
	cQuery += "F2_GNRFECP GNRE_FECP,  " + Chr(13)
	cQuery += "CASE WHEN D2_TIPO <> 'B' AND D2_TIPO <> 'D' " + Chr(13)
	cQuery += "THEN (SELECT A1_CONTRIB FROM  SA1010  WHERE D_E_L_E_T_ ='' AND A1_COD = SD2.D2_CLIENTE AND A1_LOJA = SD2.D2_LOJA)   " + Chr(13)
	cQuery += "ELSE (SELECT A2_CONTRIB FROM SA2010 WHERE D_E_L_E_T_ ='' AND A2_COD = SD2.D2_CLIENTE AND A2_LOJA = SD2.D2_LOJA) END CONTRIB,    " + Chr(13)
	cQuery += "F2_VEND1 VEND1,  " + Chr(13)
	cQuery += "A3_NREDUZ VENDEDOR,  " + Chr(13)
	cQuery += "F2_COND + ' - '+ E4_DESCRI C_PAGTO " + Chr(13)
	cQuery += ",D2_IDENTB6 IDENTB6 " + Chr(13)
	cQuery += ",IIF(D2_TIPO IN ('N','C','I','P'),A1_CONTA,A2_CONTA) SA_CONTA " + Chr(13)
	cQuery += ",IIF(D2_TIPO IN ('N','C','I','P'),CT1SA1.CT1_DESC01,CT1SA2.CT1_DESC01) SA_DESC_CONTA " + Chr(13)
	// cQuery += ",CONVERT(DATE,SE1.E1_VENCREA) VENCREAL" + Chr(13)

	cQuery += "FROM SD2010 SD2 " + Chr(13)
	cQuery += "		INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_ ='' AND SD2.D2_COD = SB1.B1_COD " + Chr(13)
	cQuery += "		INNER JOIN SF2010 SF2 ON SF2.D_E_L_E_T_ ='' AND SF2.F2_FILIAL = SD2.D2_FILIAL AND SF2.F2_SERIE = SD2.D2_SERIE  AND SF2.F2_DOC = SD2.D2_DOC  AND SF2.F2_CLIENTE = SD2.D2_CLIENTE " + Chr(13)
	cQuery += "		INNER JOIN SF4010 SF4 ON SF4.D_E_L_E_T_ ='' AND SF4.F4_CODIGO = SD2.D2_TES " + Chr(13)
	cQuery += "		LEFT JOIN SA1010 SA1 ON SA1.D_E_L_E_T_ ='' AND A1_COD=D2_CLIENTE AND A1_LOJA=D2_LOJA  " + Chr(13)
	cQuery += "		LEFT JOIN SA2010 SA2 ON SA2.D_E_L_E_T_ ='' AND A2_COD=D2_CLIENTE AND A2_LOJA=D2_LOJA  " + Chr(13)
	cQuery += "		LEFT JOIN CT1010 CT1SB1 ON CT1SB1.D_E_L_E_T_ ='' AND CT1SB1.CT1_CONTA=B1_CONTA  " + Chr(13)
	cQuery += "		LEFT JOIN CT1010 CT1SA1 ON CT1SA1.D_E_L_E_T_ ='' AND CT1SA1.CT1_CONTA=A1_CONTA  " + Chr(13)
	cQuery += "		LEFT JOIN CT1010 CT1SA2 ON CT1SA2.D_E_L_E_T_ ='' AND CT1SA2.CT1_CONTA=A2_CONTA  " + Chr(13)
	cQuery += "		LEFT JOIN SE4010 SE4 ON SE4.D_E_L_E_T_ <>'*' AND SE4.E4_CODIGO = SF2.F2_COND " + Chr(13)
	cQuery += "		LEFT JOIN SA3010 A3 ON A3.D_E_L_E_T_='' AND A3_COD = F2_VEND1   " + Chr(13)
	// cQuery += "		LEFT JOIN "+RETSQLNAME('SE1')+" SE1 ON SE1.D_E_L_E_T_ = '' AND SE1.E1_NUM = SF2.F2_DOC AND SE1.E1_PREFIXO = SF2.F2_SERIE AND SE1.E1_CLIENTE = SF2.F2_CLIENTE AND SE1.E1_LOJA = SF2.F2_LOJA" + Chr(13)
	cQuery += "WHERE SD2.D_E_L_E_T_ =''  " + Chr(13)
	cQuery += " AND SD2.D2_EMISSAO BETWEEN '" + DToS(mv_par01) + "' AND '" + DTos(mv_par02) + "' AND " + Chr(13)
	cQuery += " SD2.D2_CLIENTE BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' AND " + Chr(13)
	cQuery += " SD2.D2_LOJA BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' AND " + Chr(13)
	cQuery += " SD2.D2_COD BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' AND " + Chr(13)
	cQuery += " SD2.D2_FILIAL BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' " + Chr(13)
	
	cQuery += "UNION ALL " + Chr(13)

	cQuery += "SELECT  " + Chr(13)
	cQuery += "'NF_ENTRADA' ORIGEM, " + Chr(13)
	cQuery += "D1_FILIAL FILIAL,  " + Chr(13)
	cQuery += "SUBSTRING(D1_DTDIGIT,7,2) + '/' + SUBSTRING(D1_DTDIGIT,5,2) + '/' + SUBSTRING(D1_DTDIGIT,1,4) DATA_NF,  " + Chr(13)
	cQuery += "D1_SERIE SERIE,  " + Chr(13)
	cQuery += "D1_DOC NOTA,  " + Chr(13)
	cQuery += "D1_TIPO TIPO_NF,  " + Chr(13)
	cQuery += "D1_FORNECE CLI_FORN,  " + Chr(13)
	cQuery += "D1_LOJA LJ_CLI_FORN,  " + Chr(13)
	cQuery += "CASE WHEN D1_TIPO = 'B' OR D1_TIPO = 'D' " + Chr(13)
	cQuery += "THEN (SELECT A1_NOME FROM  SA1010  WHERE D_E_L_E_T_ ='' AND A1_COD = SD1.D1_FORNECE AND A1_LOJA = SD1.D1_LOJA)   " + Chr(13)
	cQuery += "ELSE (SELECT A2_NOME FROM SA2010 WHERE D_E_L_E_T_ ='' AND A2_COD = SD1.D1_FORNECE AND A2_LOJA = SD1.D1_LOJA) END N_CLI_FORN,    " + Chr(13)
	cQuery += "CASE WHEN D1_TIPO = 'B' OR D1_TIPO = 'D' " + Chr(13)
	cQuery += "THEN (SELECT A1_TIPO FROM  SA1010  WHERE D_E_L_E_T_ ='' AND A1_COD = SD1.D1_FORNECE AND A1_LOJA = SD1.D1_LOJA)   " + Chr(13)
	cQuery += "ELSE (SELECT A2_TIPO FROM SA2010 WHERE D_E_L_E_T_ ='' AND A2_COD = SD1.D1_FORNECE AND A2_LOJA = SD1.D1_LOJA) END TP_CLI_FORN,    " + Chr(13)
	cQuery += "F1_EST UF_CLI_FORN,  " + Chr(13)
	cQuery += "D1_COD COD_PROD,  " + Chr(13)
	cQuery += "B1_DESC PRODUTO,  " + Chr(13)
	cQuery += "B1_POSIPI NCM,  " + Chr(13)
	cQuery += "D1_QUANT QUANT,  " + Chr(13)
	cQuery += "D1_VUNIT VLR_UNIT,  " + Chr(13)
	cQuery += "D1_TOTAL TOTAL,  " + Chr(13)
	cQuery += "D1_LOTECTL LOTE,  " + Chr(13)
	cQuery += "SUBSTRING(D1_DTVALID,7,2) + '/' + SUBSTRING(D1_DTVALID,5,2) + '/' + SUBSTRING(D1_DTVALID,1,4) DT_LOTE, " + Chr(13)
	cQuery += "D1_TES TES,  " + Chr(13)
	cQuery += "D1_CF CFOP,  " + Chr(13)
	cQuery += "F4_DUPLIC DUPLICATA,  " + Chr(13)
	cQuery += "F4_ESTOQUE ESTOQUE,  " + Chr(13)
	cQuery += "F4_PODER3 PODTERC,  " + Chr(13)
	cQuery += "D1_CLASFIS CLASFIS,  " + Chr(13)
	cQuery += "D1_SERIORI SERIE_ORIG,  " + Chr(13)
	cQuery += "D1_NFORI NF_ORIG,  " + Chr(13)
	cQuery += "D1_ITEMORI IT_NF_ORIG,  " + Chr(13)
	cQuery += "D1_PICM ALIQICMS,  " + Chr(13)
	cQuery += "D1_VALICM VLRICMS,  " + Chr(13)
	cQuery += "F4_CREDICM APURICMS,  " + Chr(13)
	cQuery += "D1_VALISS VLR_ISS,  " + Chr(13)
	cQuery += "D1_ICMSRET ICMS_ST,  " + Chr(13)
	cQuery += "D1_IPI ALIQIPI,  " + Chr(13)
	cQuery += "D1_VALIPI VLRIPI,  " + Chr(13)
	cQuery += "F4_CREDIPI APURIPI,  " + Chr(13)
	cQuery += "D1_ALQIMP5 ALQCOFINS,  " + Chr(13)
	cQuery += "D1_BASIMP5 BCCOFINS,  " + Chr(13)
	cQuery += "D1_VALIMP5 VLRCOFINS,  " + Chr(13)
	cQuery += "D1_ALQIMP6 ALQPIS,  " + Chr(13)
	cQuery += "D1_BASIMP6 BCPIS,  " + Chr(13)
	cQuery += "D1_VALIMP6 VLRPIS,  " + Chr(13)
	cQuery += "D1_IDENTB6 IDPTERC,  " + Chr(13)
	cQuery += "D1_VALFRE VLRFRETE,  " + Chr(13)
	cQuery += "D1_CUSTO VLRCUSTO,  " + Chr(13)
	cQuery += "B1_GRTRIB GRPTRIB,  " + Chr(13)
	cQuery += "SB1.B1_CONTA B1_CONTA,  " + Chr(13)
	cQuery += "CT1SB1.CT1_DESC01 B1_DESC_CONTA,  " + Chr(13)
	cQuery += "D1_CONTA SD_CONTA,  " + Chr(13)
	cQuery += "CT1SD1.CT1_DESC01 SD_DESC_CONTA,  " + Chr(13)
	cQuery += "D1_DESC VLRDESCTO,  " + Chr(13)
	cQuery += "D1_DESPESA DESPESA, " + Chr(13)
	cQuery += "D1_VALCMAJ COFMAJOR,  " + Chr(13)
	cQuery += "D1_DIFAL D_ICMS_D,  " + Chr(13)
	cQuery += "D1_VFCPDIF V_FECP,  " + Chr(13)
	cQuery += "D1_PEDIDO + '/' + D1_ITEMPC PEDIDO, " + Chr(13)
	cQuery += "F1_CHVNFE CHAVE_NFE,  " + Chr(13)
	cQuery += "F4_PISCOF PISCOF,  " + Chr(13)
	cQuery += "F4_PISCRED PISCRED,  " + Chr(13)
	cQuery += "F4_CSTPIS CSTPIS,  " + Chr(13)
	cQuery += "F4_CSTCOF CSTCOF,  " + Chr(13)
	cQuery += "D1_BASEICM BS_ICMS,  " + Chr(13)
	cQuery += "D1_BASEIPI BS_IPI, " + Chr(13)
	cQuery += "D1_ICMSCOM D_ICMS_P,  " + Chr(13)
	cQuery += "'' GNRE_DIF,  " + Chr(13)
	cQuery += "'' GNRE_FECP,  " + Chr(13)
	cQuery += "CASE WHEN D1_TIPO = 'B' OR  D1_TIPO = 'D' " + Chr(13)
	cQuery += "THEN (SELECT A1_CONTRIB FROM  SA1010  WHERE D_E_L_E_T_ ='' AND A1_COD = SD1.D1_FORNECE AND A1_LOJA = SD1.D1_LOJA)   " + Chr(13)
	cQuery += "ELSE (SELECT A2_CONTRIB FROM SA2010 WHERE D_E_L_E_T_ ='' AND A2_COD = SD1.D1_FORNECE AND A2_LOJA = SD1.D1_LOJA) END CONTRIB,    " + Chr(13)
	cQuery += "'' VEND1,  " + Chr(13)
	cQuery += "''  VENDEDOR,  " + Chr(13)
	cQuery += "F1_COND + ' - '+ E4_DESCRI C_PAGTO " + Chr(13)
	cQuery += ",D1_IDENTB6 IDENTB6 " + Chr(13)
	cQuery += ",IIF(D1_TIPO IN ('B','D'),A1_CONTA,A2_CONTA) SA_CONTA " + Chr(13)
	cQuery += ",IIF(D1_TIPO IN ('B','D'),CT1SA1.CT1_DESC01,CT1SA2.CT1_DESC01) SA_DESC_CONTA " + Chr(13)
	// cQuery += ",CONVERT(DATE,SE2.E2_VENCREA) VENCREAL" + Chr(13)

	cQuery += "FROM SD1010 SD1 " + Chr(13)
	cQuery += "		INNER JOIN SF1010 SF1 ON SF1.D_E_L_E_T_ ='' AND SF1.F1_FILIAL = SD1.D1_FILIAL AND SF1.F1_SERIE = SD1.D1_SERIE  AND SF1.F1_DOC = SD1.D1_DOC  AND SF1.F1_FORNECE = SD1.D1_FORNECE AND SF1.F1_LOJA = SD1.D1_LOJA " + Chr(13)
	cQuery += "		INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_ ='' AND SD1.D1_COD = SB1.B1_COD " + Chr(13)
	cQuery += "		INNER JOIN SF4010 SF4 ON SF4.D_E_L_E_T_ ='' AND SF4.F4_CODIGO = SD1.D1_TES " + Chr(13)
	cQuery += "		LEFT JOIN SA1010 SA1 ON SA1.D_E_L_E_T_ ='' AND A1_COD=D1_FORNECE AND A1_LOJA=D1_LOJA  " + Chr(13)
	cQuery += "		LEFT JOIN SA2010 SA2 ON SA2.D_E_L_E_T_ ='' AND A2_COD=D1_FORNECE AND A2_LOJA=D1_LOJA  " + Chr(13)
	cQuery += "		LEFT JOIN CT1010 CT1SB1 ON CT1SB1.D_E_L_E_T_ ='' AND CT1SB1.CT1_CONTA=B1_CONTA  " + Chr(13)
	cQuery += "		LEFT JOIN CT1010 CT1SA1 ON CT1SA1.D_E_L_E_T_ ='' AND CT1SA1.CT1_CONTA=A1_CONTA  " + Chr(13)
	cQuery += "		LEFT JOIN CT1010 CT1SA2 ON CT1SA2.D_E_L_E_T_ ='' AND CT1SA2.CT1_CONTA=A2_CONTA  " + Chr(13)
	cQuery += "		LEFT JOIN CT1010 CT1SD1 ON CT1SD1.D_E_L_E_T_ ='' AND CT1SD1.CT1_CONTA=D1_CONTA  " + Chr(13)
	cQuery += "		LEFT JOIN SE4010 SE4 ON SE4.D_E_L_E_T_ <>'*' AND SE4.E4_CODIGO = SF1.F1_COND " + Chr(13) 
	// cQuery += "		LEFT JOIN "+RETSQLNAME('SE2')+" SE2 ON SE2.D_E_L_E_T_ = '' AND SE2.E2_NUM = SF1.F1_DOC AND SE2.E2_PREFIXO = SF1.F1_SERIE AND SE2.E2_FORNECE = SF1.F1_FORNECE AND SE2.E2_LOJA = SF1.F1_LOJA" + Chr(13)
	cQuery += "WHERE SD1.D_E_L_E_T_ =''  " + Chr(13)
	cQuery += " AND SD1.D1_DTDIGIT BETWEEN '" + DToS(mv_par01) + "' AND '" + DTos(mv_par02) + "' AND " + Chr(13)
	cQuery += " SD1.D1_FORNECE BETWEEN '" + mv_par03 + "' AND '" + mv_par04 + "' AND " + Chr(13)
	cQuery += " SD1.D1_LOJA BETWEEN '" + mv_par05 + "' AND '" + mv_par06 + "' AND " + Chr(13)
	cQuery += " SD1.D1_COD BETWEEN '" + mv_par07 + "' AND '" + mv_par08 + "' AND " + Chr(13)
	cQuery += " SD1.D1_FILIAL BETWEEN '" + mv_par09 + "' AND '" + mv_par10 + "' " + Chr(13)
	cQuery += "ORDER BY FILIAL, ORIGEM, DATA_NF, SERIE, NOTA " + Chr(13)

	memowrite("NFUNIFIC",cQuery)

	TcQuery cQuery New Alias (cAliasD2:=GetNextAlias())

	If (cAliasD2)->(!Eof())
		_lRet := .T.
	EndIf


	oExcel:AddworkSheet("PARÂMETROS")
	oExcel:AddTable("PARÂMETROS","PARÂMETROS")
	oExcel:AddColumn("PARÂMETROS","PARÂMETROS","PARAMETROS",1,1)
	oExcel:AddColumn("PARÂMETROS","PARÂMETROS","VALOR",1,1)

	oExcel:AddRow("PARÂMETROS","PARÂMETROS",{'Data NF De',;
		DTOC(mv_par01)})

	oExcel:AddRow("PARÂMETROS","PARÂMETROS",{'Data NF Até',;
		DTOC(mv_par02)})

	oExcel:AddRow("PARÂMETROS","PARÂMETROS",{'Fornec/Cliente De',;
		mv_par03})

	oExcel:AddRow("PARÂMETROS","PARÂMETROS",{'Fornec/Cliente Até',;
		mv_par04})

	oExcel:AddRow("PARÂMETROS","PARÂMETROS",{'Loja De',;
		mv_par05})

	oExcel:AddRow("PARÂMETROS","PARÂMETROS",{'Loja Até',;
		mv_par06})

	oExcel:AddRow("PARÂMETROS","PARÂMETROS",{'Produto De',;
		mv_par07})

	oExcel:AddRow("PARÂMETROS","PARÂMETROS",{'Produto Até',;
		mv_par08})

	oExcel:AddRow("PARÂMETROS","PARÂMETROS",{'Filial De',;
		mv_par09})

	oExcel:AddRow("PARÂMETROS","PARÂMETROS",{'Filial Até',;
		mv_par10})


	oExcel:AddworkSheet("RELATÓRIO")
	oExcel:AddTable("RELATÓRIO","NF_UNIFIC")
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","ORIGEM",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","FILIAL",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","DATA_NF",1,1)
	// oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","VENCIMENTO REAL",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","SERIE",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","NOTA",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","TIPO_NF",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","CLI_FORN",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","LJ_CLI_FORN",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","N_CLI_FORN",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","TP_CLI_FORN",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","UF_CLI_FORN",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","COD_PROD",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","PRODUTO",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","NCM",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","QUANT",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","VLR_UNIT",2,2)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","TOTAL",2,2)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","LOTE",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","DT_LOTE",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","TES",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","CFOP",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","DUPLICATA",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","ESTOQUE",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","PODTERC",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","CLASFIS",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","SERIE_ORIG",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","NF_ORIG",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","IT_NF_ORIG",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","ALIQICMS",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","VLRICMS",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","APURICMS",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","VLR_ISS",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","ICMS_ST",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","ALIQIPI",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","VLRIPI",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","APURIPI",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","ALQCOFINS",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","BCCOFINS",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","VLRCOFINS",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","ALQPIS",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","BCPIS",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","VLRPIS",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","IDPTERC",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","VLRFRETE",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","VLRCUSTO",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","GRPTRIB",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","B1_CONTA",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","B1_DESC_CONTA",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","SD_CONTA",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","SD_DESC_CONTA",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","SA_CONTA",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","SA_DESC_CONTA",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","VLRDESCTO",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","DESPESA",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","COFMAJOR",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","D_ICMS_D",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","V_FECP",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","PEDIDO",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","CHAVE_NFE",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","PISCOF",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","PISCRED",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","CSTPIS",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","CSTCOF",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","BS_ICMS",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","BS_IPI",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","D_ICMS_P",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","GNRE_DIF",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","GNRE_FECP",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","CONTRIB",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","VEND1",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","VENDEDOR",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","C_PAGTO",1,1)
	oExcel:AddColumn("RELATÓRIO","NF_UNIFIC","IDENTB6",1,1)

	(cAliasD2)->(DbGotOP())

	While !(cAliasD2)->(EOF())
			/*// (cAliasD2)->VENCREAL,;*/
		oExcel:AddRow("RELATÓRIO","NF_UNIFIC",{(cAliasD2)->ORIGEM,;
			(cAliasD2)->FILIAL,;
			(cAliasD2)->DATA_NF,;
			(cAliasD2)->SERIE,;
			(cAliasD2)->NOTA,;
			(cAliasD2)->TIPO_NF	,;
			(cAliasD2)->CLI_FORN,;
			(cAliasD2)->LJ_CLI_FORN,;
			(cAliasD2)->N_CLI_FORN,;
			(cAliasD2)->TP_CLI_FORN	,;
			(cAliasD2)->UF_CLI_FORN,;
			(cAliasD2)->COD_PROD,;
			(cAliasD2)->PRODUTO,;
			(cAliasD2)->NCM	,;
			(cAliasD2)->QUANT,;
			(cAliasD2)->("R$ "+Alltrim(Transform(VLR_UNIT, "@E 9,999,999.99999"))),;
			(cAliasD2)->("R$ "+Alltrim(Transform(TOTAL, "@E 9,999,999.99"))),; 
			(cAliasD2)->LOTE,;
			(cAliasD2)->DT_LOTE,;
			(cAliasD2)->TES,;
			(cAliasD2)->CFOP,;
			(cAliasD2)->DUPLICATA,;
			(cAliasD2)->ESTOQUE,; 
			(cAliasD2)->PODTERC,;
			(cAliasD2)->CLASFIS,;
			(cAliasD2)->SERIE_ORIG,;
			(cAliasD2)->NF_ORIG,;
			(cAliasD2)->IT_NF_ORIG,;
			(cAliasD2)->ALIQICMS,;
			(cAliasD2)->VLRICMS,;
			(cAliasD2)->APURICMS,;
			(cAliasD2)->VLR_ISS,;
			(cAliasD2)->ICMS_ST,;
			(cAliasD2)->ALIQIPI,;
			(cAliasD2)->VLRIPI,;
			(cAliasD2)->APURIPI	,;
			(cAliasD2)->ALQCOFINS,;
			(cAliasD2)->BCCOFINS,;
			(cAliasD2)->VLRCOFINS,;
			(cAliasD2)->ALQPIS,;
			(cAliasD2)->BCPIS,;
			(cAliasD2)->VLRPIS,;
			(cAliasD2)->IDPTERC	,;
			(cAliasD2)->VLRFRETE,;
			(cAliasD2)->VLRCUSTO,;
			(cAliasD2)->GRPTRIB	,;
			(cAliasD2)->B1_CONTA,;
			(cAliasD2)->B1_DESC_CONTA,;
			(cAliasD2)->SD_CONTA,;
			(cAliasD2)->SD_DESC_CONTA,;
			(cAliasD2)->SA_CONTA,;
			(cAliasD2)->SA_DESC_CONTA,;
			(cAliasD2)->VLRDESCTO,;
			(cAliasD2)->DESPESA	,;
			(cAliasD2)->COFMAJOR,;
			(cAliasD2)->D_ICMS_D,;
			(cAliasD2)->V_FECP,;
			(cAliasD2)->PEDIDO,;
			(cAliasD2)->CHAVE_NFE,;
			(cAliasD2)->PISCOF,;
			(cAliasD2)->PISCRED,;
			(cAliasD2)->CSTPIS,;
			(cAliasD2)->CSTCOF,;
			(cAliasD2)->BS_ICMS	,;
			(cAliasD2)->BS_IPI,;
			(cAliasD2)->D_ICMS_P,;
			(cAliasD2)->GNRE_DIF,;
			(cAliasD2)->GNRE_FECP,;
			(cAliasD2)->CONTRIB,;
			(cAliasD2)->VEND1,;
			(cAliasD2)->VENDEDOR,;
			(cAliasD2)->C_PAGTO,;
			(cAliasD2)->IDENTB6})



		(cAliasD2)->(DbSKip())
	Enddo
	(cAliasD2)->(DbCloseArea())

	oExcel:Activate()
	oExcel:GetXMLFile(_cArquivo+".xml")

	// __CopyFile(_cArquivo+".xml",_cPathExcel+_cArquivo+".xml")

	//Processa({||__CopyFile("\SIGAADV\"+_cArq , _cFileTMP),"Copiando para o seu computador!!!"})
	cpys2t("\system\"+_cArquivo+".xml" , GetTempPath(),.T.)
	Ferase("\system\"+_cArquivo+".xml")
	ShellExecute("open",_cArquivo+".xml","",GetTempPath(), 1 )
	showLog(GetTempPath()+_cArquivo+".xml"+CHR(13)+cQuery)
	// If ! ApOleClient( 'MsExcel' )
	// 	MsgAlert( 'MsExcel nao instalado' )
	// Else
	// 	oExcelApp := MsExcel():New()
	// 	oExcelApp:WorkBooks:Open( _cPathExcel+_cArquivo+".xml") // Abre uma planilha
	// 	oExcelApp:SetVisible(.T.)
	// EndIf

Return

	


